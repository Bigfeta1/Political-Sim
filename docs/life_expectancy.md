# Life Expectancy Engine

Each country's life expectancy is calculated from real WHO death rates per age band, and at game start it lands exactly on the country's WHO 2023 value. 
Risk factors scale those death rates cause by cause. 
Smoking is built in but has no effect yet, because no country has smoking prevalence data and nothing in play changes it.

- **Calculated, not copied:** `Mortality` turns WHO deaths into a death rate per age band, and `LifeExpectancy` runs an abridged life table over those rates (7 age bands, 181 WHO causes of death).
- **Calibrated:** the open-ended 70+ band is tuned once at start so the result equals the target.
- **Static for now:** the value is calculated once, when the country is created. Nothing recalculates it during play yet.
- **Checked in Godot headless, not in the game:** every country lands on its target when built headless (see Verification). The game flow, the top bar and save/load have not been run.

## Node structure

Each job has its own child of `Population` in `country.tscn`. `population.gd` wires them in `_ready()`: it hands `AgeBands` and `RiskFactors` to `Mortality`, and `AgeBands` and `Mortality` to `LifeExpectancy`.

```
Population             population.gd: wires its children, merges their save data
├─ Count               population_count.gd: population_count = sum of the bands, population_count_changed
├─ AgeBands
│  ├─ Age0To4          age_band.gd: key "0-4" gives start_age 0, width 5
│  ├─ Age5To14 … Age60To69
│  └─ Age70Plus        key "70+" gives width 0 = the open-ended last band
├─ RiskFactors
│  └─ Smoking          risk_factor.gd: key "smoking"
├─ Mortality           mortality.gd: fills the bands, death rate per band, mortality_changed
├─ LifeExpectancy      life_expectancy.gd: life table, 70+ calibration, life_expectancy_changed
└─ Workers             workers.gd: head count per role
```

Two `[connection]` entries in `country.tscn` route `Mortality.mortality_changed` to `LifeExpectancy._on_mortality_changed`, which runs `calibrate()` and then `calculate()` (each calls `life_table()` once), and to `Count._on_mortality_changed`, which adds up the bands' populations. The bands are the country's only population figure.

| Script | Job |
| --- | --- |
| `Scripts/Country/Parameters/population.gd` | Calls `count.initialize(age_bands)`, `mortality.initialize(age_bands, risk_factors)` and `life_expectancy.initialize(age_bands, mortality)`. |
| `Scripts/Country/Parameters/Population/population_count.gd` | `count_bands()` sums the bands' populations and stores the total with `set_population_count()`, which emits `population_count_changed`. It runs on `mortality_changed` and after loading. Saves each band's population under `population`, keyed by band, and writes them back on load. |
| `Scripts/Country/Parameters/Population/mortality.gd` | Holds `mortality` and `risk_prevalence`. `set_mortality()` fills each band's population and turns each cause's WHO deaths into a rate (deaths ÷ the band's WHO population), then emits `mortality_changed`. `set_risk_prevalence()` hands each factor its start and current shares. `death_rate(band)` adds up each cause's rate times every factor's multiplier. It never divides by the band's current population. |
| `Scripts/Country/Parameters/Population/life_expectancy.gd` | Holds `target_life_expectancy` and `life_expectancy`. Asks `Mortality` for each band's death rate. `set_life_expectancy()` emits `life_expectancy_changed`. |
| `Scripts/Country/Parameters/Population/age_band.gd` | Data only: `key`, plus `start_age` and `width` read from it in `_ready()`, plus the band's population and its death rate per WHO cause. |
| `Scripts/Country/Parameters/Population/risk_factor.gd` | Reads its RR file in `_ready()`. `multiplier(cause, band)` returns 1 when it has no prevalence or the band starts below `min_age`. |
| `Scripts/Data/mortality_files.gd` | `find_by_id(id)` reads `Data/Mortality/mortality_<id>.json`. |
| `Scripts/Data/risk_factor_files.gd` | `read(key)` reads `Data/RiskFactors/<key>.json`. |

**Setup order.** `country_factory.gd` sets the target from the country JSON first, then the mortality data, which calibrates the 70+ band against it, then the risk prevalence. `Data` (`player_data.gd`) passes `country_target_life_expectancy` through to `LifeExpectancy`, and `country_mortality` and `country_risk_prevalence` through to `Mortality`. `country_life_expectancy` is read-only.

**Age bands are fixed by the data.** Each band reads its population and deaths (turned into rates) from the mortality file by its `key` (`value["bands"][band.key]` in `set_mortality`). The WHO files hold only the 7 bands above (`0-4`, `5-14`, `15-29`, `30-49`, `50-59`, `60-69`, `70+`), so these are the only bands the engine can run. A band whose key is not in the file errors on load. Other brackets need mortality data in those brackets.

**Saving.** `Count` saves each band's population (`population`, keyed by band) and restores the bands from it on load. Life expectancy is calculated, so `Mortality` and `LifeExpectancy` save nothing; loading does not recalculate it. `SAVE_VERSION` is 7.

## `life_expectancy.gd` by symbol

The script carries no comments. What each part is for lives here.

| Symbol | Meaning |
| --- | --- |
| `target_life_expectancy` | The country's real life expectancy at birth. The open band is calibrated so the life table reproduces it. |
| `calibrate()` | A flat death rate over the open band overstates the years lived in it, so the band takes the years that reproduce the target. |
| `calculate()` | Years lived in the open band scale inversely with its death rate. |
| `life_table()` | Returns `rows` (one per closed band: `band`, `rate` m, `dying` q, `survivors` l at the band's start, `years` L), `years` (ΣL, years lived before the open band) and `survivors` (share reaching the open band), for one person at birth. |
| `open_band_years()` | Years remaining at the start of the open band now: the calibrated years scaled by start rate ÷ current rate. |
| `flat_open_band_years()` | Years remaining at the start of the open band under a single flat rate (1/m). Shown for comparison only; the engine does not use it. |

## `mortality.gd` by symbol

| Symbol | Meaning |
| --- | --- |
| `mortality` | LifeExpectancy calibrates against its target when this is set, so the target must be set first. |

## `age_band.gd` by symbol

| Symbol | Meaning |
| --- | --- |
| `key` | The band's key in the mortality file, e.g. "30-49" or "70+". Start age and width are read from it. |
| `width` | Years the band covers; 0 for the open-ended last band. |
| `death_rates` | Death rate in this band per WHO cause name: WHO 2023 deaths ÷ WHO 2023 band population, fixed at game start. Changing the band's population does not change it. |

## `risk_factor.gd` by symbol

| Symbol | Meaning |
| --- | --- |
| `key` | The factor's data file in Data/RiskFactors, e.g. "smoking". |
| `min_age` | Bands starting below this age are unaffected. |
| `relative_risks` | Relative risk of death per exposure level and cause; causes not listed are unaffected. |
| `start_prevalence`, `prevalence` | Share of people at each exposure level, at game start and now. Empty until the country's prevalence is known. |
| `multiplier()` | How much this factor scales a cause's death rate in a band, compared with game start. |
| `mean_risk()` | Average relative risk across the population; the reference level has a relative risk of 1. |

## The maths

Life expectancy at birth is the area under the survival curve. The engine computes it as a sum over age bands.

```
e0 = ∫ S(t) dt,   S(t) = exp(−∫ μ(s) ds)
```

**Closed bands (0-4 up to 60-69).** For a band starting at age x, width n, death rate m (the sum of the band's cause rates, each fixed at WHO deaths ÷ WHO population):

```
q(x)     = n·m / (1 + n/2 · m)          chance of dying in the band
l(x+n)   = l(x) · (1 − q(x))            survivors at the band's end, l(0) = 1
L(x)     = n·l(x+n) + n/2 · (l(x) − l(x+n))   years lived in the band
```

The years lived before 70 are the sum of L over the closed bands.

**Open band (70+).** A single flat death rate over everyone past 70 overstates the years they live (USA: 20.0 years; Israel: 23.9). So at game start the band takes whatever years reproduce the target, and later scales inversely with its death rate:

```
e70_start = (e0_target − ΣL) / l(70)
e0        = ΣL + l(70) · e70_start · m70_start / m70_now
```

The inverse scaling would be exact if the death rate were the same at every age past 70. It is not, so the real response is somewhat smaller.

**Mortality is a rate, not a count.** Each cause's rate is set once at game start, `r(x,c) = deaths_WHO(x,c) / population_WHO(x)`, and `m(x) = Σ_c r(x,c) × multipliers`. The band's current population never enters `m(x)`, so population changes do not move life expectancy; only changes to rates (risk factors) do. Death counts, when needed, are `m(x) × population(x)`. Confirmed by OpenEvidence (2026-10-23): holding WHO death counts fixed while the population changes made the rate fall whenever a band grew, which is an artifact.

**Risk factors.** Each cause's rate in a band is multiplied by every factor's multiplier for that cause. For a factor with exposure levels k (shares p, relative risks RR, reference level RR = 1):

```
multiplier = Σ p_now(k) · RR(k)  /  Σ p_start(k) · RR(k)
```

At game start the shares equal the start shares, so every multiplier is 1 and the engine reproduces the target. Bands starting below the factor's `min_age` are unaffected.

## Data sources

All death data and targets come from one WHO release (dated 2026-10-01, year 2023). Smoking risks come from one cohort study.

| Data | Source | Project file | Notes |
| --- | --- | --- | --- |
| Deaths by cause and population, per age band | [WHO Global Health Estimates 2023](https://www.who.int/data/gho/data/themes/mortality-and-global-health-estimates/ghe-leading-causes-of-death), Persons | `Data/Mortality/mortality_<id>.json` | 7 bands, 181 leaf causes; leaves sum to WHO's All Causes in every band. Whole deaths and people. |
| Life expectancy targets | WHO GHO indicator `WHOSIS_000001`, both sexes, 2023 | `life_expectancy` in `Data/Country_Data/country_<id>.json` | Same WHO release as the deaths. |
| Smoking relative risks | [Joshy et al. 2025, BMC Medicine 23:115](https://europepmc.org/article/PMC/PMC11854379), Additional file 1, Table S7 (HR2) | `Data/RiskFactors/smoking.json` | Australian 45 and Up cohort; current and past vs never smokers. |
| Smoking prevalence | Not found yet | `risk_prevalence` in each country JSON (empty `{}`) | WHO publishes current smokers only (USA 14.6%, 2023); former smokers needed. |

| Country | WHO 2023 life expectancy (years) |
| --- | --- |
| America | 78.5 |
| China | 77.9 |
| Germany | 81.0 |
| Israel | 82.6 |
| Russia | 72.4 |
| UK | 80.7 |

The mortality and smoking files were built by Python scripts (`build_mortality.py`, `build_smoking.py`) that currently live only in a session scratchpad, not in the project.

## Smoking relative risks

55 WHO causes carry a smoking relative risk, applied from age 30 up. Never smokers are the reference (RR 1). Values are HR2 from Table S7, adjusted for age, sex, region, alcohol, income, education, insurance and country of birth, not for blood pressure or diabetes.

| Paper's cause | WHO cause(s) | Current | Former |
| --- | --- | --- | --- |
| Chronic lung disease | Chronic obstructive pulmonary disease | 36.32 | 7.24 |
| Cancer of lung | Trachea, bronchus, lung cancers | 17.85 | 5.52 |
| Oro-pharyngeal cancers | Lip and oral cavity, Nasopharynx, Other pharynx, Larynx cancer | 7.86 | 1.89 |
| Cancer of oesophagus | Oesophagus cancer | 4.10 | 1.84 |
| Lower respiratory infections | Lower respiratory infections | 3.31 | 1.44 |
| Cirrhosis or alcoholic liver | 4 cirrhosis causes | 3.29 | 1.40 |
| Cancer of liver | 4 liver cancer causes | 3.14 | 1.32 |
| Cancer of urinary tract | Bladder cancer | 2.96 | 1.88 |
| Coronary heart disease | Ischaemic heart disease | 2.78 | 1.31 |
| Cancer of pancreas | Pancreas cancer | 2.72 | 1.10 |
| Other respiratory | Asthma, Other respiratory diseases | 2.65 | 1.68 |
| Cancer of kidney | Kidney cancer | 2.52 | 1.21 |
| Cerebrovascular disease | Ischaemic stroke, Haemorrhagic stroke | 2.30 | 1.04 |
| Cancer of stomach | Stomach cancer | 2.04 | 1.04 |
| Other circulatory | Rheumatic heart disease, Hypertensive heart disease, Cardiomyopathy…, Other circulatory diseases | 2.04 | 1.09 |
| Cancer of prostate | Prostate cancer | 2.01 | 1.14 |
| External causes | all 11 injury causes | 1.85 | 1.09 |
| Cancer of large intestine | Colon and rectum cancers | 1.82 | 1.19 |
| Dementia incl Alzheimer's | Alzheimer disease and other dementias | 1.64 | 1.11 |
| Other neoplasms | 12 remaining cancer and neoplasm causes | 1.34 | 1.09 |

**Decisions applied:**

1. **Peripheral arterial disease:** WHO folds it into Other circulatory diseases, so the whole group takes 2.04 (the paper's PAD value was 4.80).
2. **Age:** all-ages values from age 30 up, none below 30. The paper's own age data (Table S8) show the effect fading in older people, so the 70+ band is overstated.
3. **Causes with no significant link** (non-Hodgkin lymphoma, leukaemia, ovary, breast, brain): no effect, as in the paper.
4. **"Causes not listed" (1.80):** not applied, as in the paper.

"Other neoplasms" (1.34) was added during the build. It was not in the table approved in chat, but the paper counts it as smoking-related.

## Verification

A Python mirror of the engine reproduces every target exactly and moves life expectancy in the expected direction. On 2026-10-23 the engine was also run in Godot 4.5.1 headless after the `Mortality` split: a temporary script built each `country.tscn` the way `country_factory.gd` does and printed `country_life_expectancy`. The game flow was not run.

**Godot headless, per country:**

| Country | Target | Engine result |
| --- | --- | --- |
| America | 78.5 | 78.5 |
| China | 77.9 | 77.9 |
| Germany | 81.0 | 81.0 |
| Israel | 82.6 | 82.6 |
| Russia | 72.4 | 72.4 |
| UK | 80.7 | 80.7 |

**Population independence (Godot headless, America, 2026-10-23):** with deaths stored as counts, doubling the 30-49 population moved e0 from 78.50 to 79.42, and +10% on 70+ moved it to 79.73. After switching to rates, both give 78.50, and the per-country table above and the smoking rows below give the same values as before.

**Calibration per country (Python):**

| Country | Target e0 (years) | Years lived before 70 | Share reaching 70 | Years after 70, flat rate | Years after 70, calibrated |
| --- | --- | --- | --- | --- | --- |
| America | 78.5 | 66.18 | 0.776 | 20.04 | 15.87 |
| China | 77.9 | 66.93 | 0.793 | 17.06 | 13.83 |
| Germany | 81.0 | 67.80 | 0.834 | 17.16 | 15.81 |
| Israel | 82.6 | 67.61 | 0.864 | 23.88 | 17.35 |
| Russia | 72.4 | 63.32 | 0.642 | 15.96 | 14.15 |
| UK | 80.7 | 67.53 | 0.835 | 18.31 | 15.77 |

**Smoking response, USA, made-up test prevalences** (start: 50% never, 30% former, 20% current; not game data):

| Scenario | Python | Godot |
| --- | --- | --- |
| Start | 78.50 | 78.50 |
| Half the smokers quit (current 0.2 → 0.1, former 0.3 → 0.4) | 79.94 | 79.935 |
| Smoking doubles | 75.96 | not matched |
| Nobody ever smoked | 83.73 | 83.728 |

The shares behind the Python "Smoking doubles" row were not recorded. In Godot, current 0.4 taken from former smokers (never 0.5, former 0.1) gives 76.17, and current 0.4 taken from never smokers (never 0.3, former 0.3) gives 75.76. Neither is 75.96, so it is not known whether the gap is in the scenario or the engine.

These responses are likely on the high side: the 70+ band uses all-ages RRs, and quitting pays off instantly.

## Decisions

Every choice follows the same rule: use real published data and never invent a number a source did not measure.

| Decision | Chosen | Why |
| --- | --- | --- |
| How risk factors act | They scale cause-specific death rates per age band | Life expectancy is a function of age-specific mortality |
| Which factors first | Smoking, diabetes, high blood pressure, physical inactivity, alcohol | Proximate factors; obesity left out because much of its effect runs through diabetes and blood pressure |
| Double counting | Proximate factors only; income and education left out for now | Upstream factors act through the proximate ones; later they can shift exposures instead of death rates |
| Exposure shape | 3-4 levels per factor, not yes/no | GBD models smoking, glucose, blood pressure and alcohol as continuous; a yes/no RR would be invented |
| Source of death data | WHO Global Health Estimates | The GBD Results Tool requires a request form; WHO's file is open |
| Age bands | WHO's 7 bands | Accepted; the open 70+ band is calibrated to the target |
| Targets | WHO 2023 life expectancy for every country | One source and one year, matching the death data |
| Smoking RRs | One cohort (Joshy 2025) instead of mixed studies | Consistent adjustment, current and former levels, 28 causes |
| When it updates | Not decided | Instant on change vs. built up per round; depends on how much time a round represents |

## Open items

- [x] Check in Godot that the scene loads and each country's life expectancy equals its target (headless, 2026-10-23)
- [ ] Run the game flow: the top bar shows life expectancy, and save/load still works
- [ ] Resolve the "Smoking doubles" mismatch: recover the Python scenario's shares
- [ ] Smoking prevalence per country: never / former / current shares (WHO has current only)
- [ ] Relative risks for blood pressure, diabetes, physical inactivity and alcohol, read from the original papers
- [ ] Prevalence per level for those four factors, using the same cut-offs as their RRs
- [ ] Decide how prevalence changes in play: instantly, or built up per round
- [ ] Once prevalence can change: save it, and recalculate life expectancy on change
- [ ] Consider age-specific smoking RRs (Table S8) so the effect fades with age
- [ ] Copy `build_mortality.py` and `build_smoking.py` into the project so the data can be rebuilt
- [x] Update `docs/onboarding.md` with the Population and life expectancy changes (2026-10-23)

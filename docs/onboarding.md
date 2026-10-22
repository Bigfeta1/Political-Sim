# Politics: Project Onboarding

Politics is a 4X-style strategy game built in Godot 4.5 (Forward Plus). Today it runs from a main menu through country selection (or loading a save) and round setup into a playing-round shell, and a round can be saved with F5.

- **Working now:** pick one of six countries (America, China, Germany, Israel, Russia, UK), press BEGIN, and watch the round get assembled with two random opponents. You land in a playing round where END TURN steps through the countries in initiative order. After the last country the phase advances and the turns start over.
- **Saving and loading:** F5 in the playing round writes one save file. LOAD GAME in the menu lists it, and loading rebuilds the round through the same setup steps as a new game.
- **Stubbed:** the phases (economic, proxy war, upkeep) have names and a cycle but no gameplay behind them, and nothing starts the first phase yet (see Known gaps).
- **Focus so far:** the state progression from menu to round, the turn and phase system, and save and load, built so each piece has one job and can be swapped or extended without touching the others.

## Project layout

Scenes are grouped by game state, and scripts are split into a logic tree and a UI tree that mirror each other.

| Path | What lives there |
| --- | --- |
| `Data/Country_Data/` | One JSON file per country, with `id`, `country_name` and `initiative` (1 to 5). Adding a file adds a country to the selection list. |
| `Scenes/main_scene.tscn` | The entry scene (`run/main_scene`): `StateRouter`, `Logic`, `UI`. |
| `Scenes/MainMenu/` | `Core/` holds the menu logic and UI scenes. `Panels/RoundConfig/` holds the round config panel and its country entry. `Panels/LoadPanel/` holds the load panel and its save entry. |
| `Scenes/ConfigureRound/` | Everything that exists while a round is assembled: the round config node, the round configurator (logic and UI), the country manager, the state manager. |
| `Scenes/PlayingRound/` | `playing_round_logic.tscn` and `playing_round_ui.tscn`. |
| `Scenes/country.tscn` | One country instance, with `Data` and a `Parameters` tree. |
| `Scripts/Autoload/` | The three autoloads: `game_state.gd` (`GameState`), `save_writer.gd` (`SaveWriter`) and `scene_loader.gd` (`SceneLoader`). |
| `Scripts/Logic/` | `state_router.gd`, `round_config.gd`, and one folder per area: `MainMenu/` (with `RoundConfig/` and `LoadPanel/` for the panels' logic), `RoundConfigurator/`, `PlayingRound/`. |
| `Scripts/UI/` | UI scripts, one folder per area: `MainMenu/` (with `Panels/RoundConfig/` and `Panels/LoadPanel/`), `ConfigureRound/`, `PlayingRound/`. |
| `Scripts/Country/` | `Countries/country.gd` and `CountryManager/` (manager, logic, factory, list). |
| `Scripts/MainScene/` | `main_scene.gd` and `logic.gd`, the registry (see below). |
| `Scripts/MainMenu/` | `main_menu_router.gd`, the menu's own router, and `Panels/begin_button.gd`. |
| `Scripts/PlayerManager/` | `player_data.gd`, the data node on each country. |
| `Scripts/Data/` | Static helpers for reading files: `country_files.gd` (country JSON) and `save_file.gd` (save files). Not nodes; callers `preload` them. |

Three scripts sit outside this pattern: `Scenes/MainMenu/Buttons/new_game_button.gd` lives beside the scenes, and `Scripts/MainMenu/Panels/begin_button.gd` and `Scripts/MainMenu/main_menu_router.gd` live in a `MainMenu` folder at the scripts root.

## Architecture principles

Every piece has one job, is handed what it needs, and is created and freed by the same owner.

- **Logic and UI are separate scenes.** Each state has a logic scene (added under `Logic`) and a UI scene (added under `UI`). UI scripts read from logic through `initialize(...)`; logic never reaches into UI.
- **Dependencies are injected.** The creator calls `initialize(...)` with what the new node needs. A node does not search the tree for its collaborators. The one lookup a script makes is `@onready` on its own children.
- **Systems are registered, not found.** Anything that must be reachable by others registers with the `Logic` node (`logic.register("name", node)`) and is read with `logic.get_system("name")`.
- **Wiring uses signals, set up in the scene.** Example: the entry factory emits `entry_created`, and a `[connection]` in `round_config_panel.tscn` routes it to the selector.
- **The router owns meta-game states only.** Main menu, configure round, playing round (credits and the like later). Setup that exists only briefly belongs in the round configurator. Menu panels belong to the main menu's own router, not the global one.
- **Scenes load when needed, through `SceneLoader`.** Scripts hold scene paths as constants and call `SceneLoader.instantiate(PATH)` at the point of use. They do not `preload` scenes or keep `PackedScene` variables. Scripts can still be preloaded.
- **Systems describe their own saved state.** Each stateful system has `get_save_data()` and `load_save_data(data)`. The save writer collects, and loading rebuilds through the normal setup steps instead of a separate path.
- **Autoloads are for things that cannot be injected.** `GameState`, `SaveWriter` and `SceneLoader` exist because callers (buttons, the input handler, factories, steps) are not handed a reference to them. Anything else is registered or injected.
- **File reading goes through `Scripts/Data/`.** Country JSON is read only through `country_files.gd` (`find_paths()`, `read(path)`, `find_by_id(id)`) and saves only through `save_file.gd` (`read(path)`, `find_player_id(save_data)`). These are static functions on scripts that callers `preload`, so nothing is registered or injected.
- **Small scripts over big ones.** A new concern gets a new script, even a short one. Existing scripts do not grow code that does not belong to them.

## Main scene and the Logic registry

`main_scene.tscn` holds a `StateRouter`, a `Logic` node that doubles as a registry of live systems, a `UI` control and a `Node3D`. On startup `main_scene.gd` calls `state_router.initialize(logic, ui)`.

`Logic` (`Scripts/MainScene/logic.gd`) keeps a `systems` dictionary and has four functions:

- `register(name, node)` stores a system.
- `get_system(name)` returns it, or `null`.
- `release(name)` removes one system from the registry and the tree, then frees it.
- `clear()` empties the registry and frees every child of `Logic`. Children leave the tree immediately, so a node of the same name created in the same frame keeps its name.

| Name | Registered by | Freed by |
| --- | --- | --- |
| `main_menu` | Router, when the main menu is created | Router on `CONFIGURE_ROUND` |
| `round_config` | Main menu router, when the menu enters `GAME_SETUP` or `LOAD_GAME` | Round configurator when its checklist completes |
| `round_configurator` | Router, on `CONFIGURE_ROUND` | Router on `PLAYING_ROUND` |
| `country_manager` | `CreateCountryManager` step | `logic.clear()` on `MAIN_MENU` |
| `state_manager` | `CreateStateManager` step | `logic.clear()` on `MAIN_MENU` |
| `playing_round` | Router, on `PLAYING_ROUND` | `logic.clear()` on `MAIN_MENU` |

The UI side is not covered by `clear()`. The router keeps its own references to the main menu UI, the round config panel, the checklist UI and the playing round UI, and frees them itself.

## State flow

The game moves through three states in `GameState`, and `state_router.gd` reacts to each change by creating the new state's scenes and freeing the old one's.

```mermaid
flowchart TD
	A["MAIN_MENU<br/>Clear Logic, free the playing round UI<br/>Create the menu logic and UI<br/>Sub-states: INTRO_SCREEN, SETTINGS, GAME_SETUP"]
	B["CONFIGURE_ROUND<br/>Free the menu logic and UI<br/>Create the round configurator<br/>Create the checklist UI"]
	C["PLAYING_ROUND<br/>Free the configurator and its UI<br/>Create the playing round logic<br/>Create the playing round UI"]
	A -->|"BEGIN pressed, once a country is selected"| B
	B -->|"Configurator finishes its last step (all_completed)"| C
	C -->|"Alt pressed (InputHandler)"| A
```

Four things request a state change today: the BEGIN button and the LOAD button both ask for `CONFIGURE_ROUND`, the configurator asks for `PLAYING_ROUND` when its last step is done, and the playing round's `InputHandler` (`playing_round_input.gd`, under `Logic` in `playing_round_logic.tscn`) asks for `MAIN_MENU` when Alt is pressed. `GameState` is global; `MainMenuState` lives inside the menu scene and only changes which panel shows.

What happens, in order:

1. **Startup.** `main_scene.gd` calls `state_router.initialize(logic, ui)`, which runs the `MAIN_MENU` branch for the initial state.
2. **Opening setup.** NEW GAME moves `MainMenuState` to `GAME_SETUP`, and LOAD GAME moves it to `LOAD_GAME`. The menu router adds the matching panel. The global state stays `MAIN_MENU`.
3. **BEGIN or LOAD.** With a country (or a save) selected, the button requests `CONFIGURE_ROUND`. `GameState.change_state` sets the state and emits `state_changed`.
4. **Configure.** The router frees the menu, then creates the round configurator and its checklist UI. The configurator builds the systems and the player's country.
5. **Handoff.** On `all_completed` the configurator releases the round config and requests `PLAYING_ROUND`.
6. **Play.** The router frees the configurator and its UI, then creates the playing round logic and UI, wired to the systems already in the registry. When it entered `CONFIGURE_ROUND` it already asked `SceneLoader` to start loading those two scenes in the background.

## Main menu and panels

The main menu is a logic scene plus a UI scene, and its own small state machine (`INTRO_SCREEN`, `SETTINGS`, `GAME_SETUP`, `LOAD_GAME`) decides which panel is showing.

- **`main_menu_logic.tscn`** holds `MainMenuState` (the sub-state machine; `ui_cancel` calls `go_back()` through `MainMenuInput`) and `MainMenuRouter` (`Scripts/MainMenu/main_menu_router.gd`).
- **`main_menu_ui.tscn`** holds the NEW GAME and LOAD GAME buttons and a `Panels` node that other panels are added to.
- **`MainMenuRouter`** owns panel spawning. The global router calls `main_menu_logic.initialize(ui, logic)` when it creates the menu, and `MainMenuRouter` listens to `MainMenuState.state_changed`. `GAME_SETUP` creates the round config node (once) and the round config panel. `LOAD_GAME` creates the round config node and the load panel. Every branch frees the other panel first, so only one panel is up. `INTRO_SCREEN` and `SETTINGS` free both.

### Round config panel

The round config panel (`round_config_panel.tscn`) is a logic-and-UI pair in one scene:

| Node | Script | Job |
| --- | --- | --- |
| `RoundConfig` (root) | `round_config_panel.gd` | Receives the config and passes it to the three nodes below. |
| `Logic/CountryEntryFactory` | `country_entry_factory.gd` | Reads each country JSON listed in the config, builds one entry per country, and puts them in the list. |
| `Logic/CountrySelector` | `country_selector.gd` | Listens to every entry, records that a selection happened, and writes the chosen id to the config. |
| `Panel/BeginButton` | `begin_button.gd` | Does nothing until the selector reports a selection, then requests `CONFIGURE_ROUND`. |
| Each entry (`round_config_country_container.tscn`) | `round_config_country_entry.gd` | A toggle button in a shared `ButtonGroup`. Shows the country name and emits `selected(id)` when pressed. |

How a click becomes a stored choice:

1. `round_config_panel.initialize(config)` hands the selector to the button, the config to the selector, and the config plus the list node to the factory.
2. For each file in `config.country_files`, the factory parses the JSON, instantiates an entry, calls `entry.initialize(country_data, group)`, emits `entry_created(entry)`, and adds it to the list.
3. A scene connection routes `entry_created` to `CountrySelector.track_entry`, which connects the entry's `selected` signal to the selector.
4. Pressing an entry emits `selected(id)`. The selector sets `has_selection` and calls `config.select_country(id)`, which stores `player_country_id`.
5. BEGIN checks `has_selection`. If true, it requests `GameState.State.CONFIGURE_ROUND`.

A rebuilt panel gets a new selector, so `has_selection` always starts false.

### Load panel

`load_game_panel.tscn` follows the same logic-and-UI pattern as the round config panel, with one save slot.

| Node | Script | Job |
| --- | --- | --- |
| `LoadPanel` (root) | `load_game_panel.gd` | `initialize(config)` hands the selector and config to the button and the list to the factory. |
| `Logic/SaveEntryFactory` | `save_entry_factory.gd` | If `SaveWriter.SAVE_PATH` exists, parses it, looks up the player's country name from the country JSON, and creates one entry. |
| `Logic/SaveSelector` | `save_selector.gd` | Tracks entries through a scene connection and records `has_selection` and `selected_path`. Clears them when an entry is deleted. |
| `Panel/LoadButton` | `load_button.gd` | Does nothing until a save is selected, then parses the file into `config.save_data`, sets `config.player_country_id` from the save, and requests `CONFIGURE_ROUND`. |
| Entry (`load_container.tscn`) | `load_game_entry.gd` | A toggle button showing the player's country name. Emits `selected(path)`. Its X button deletes the file, emits `deleted` and frees the entry, with no confirmation. |

## Round configurator

The round configurator runs a list of steps in order, builds the systems a round needs, creates the player's country and the opponents, sets the turn order, restores a saved state if one is loaded, and then hands the game to the playing round. It exists only during `CONFIGURE_ROUND`.

**Structure.** `round_configurator_logic.tscn` is a `RoundConfigurator` node whose children are the steps. Scene-tree order is execution order. Each step is a node with a script that has one function, `run(configurator)`. The configurator exposes `logic` (its parent, the registry) and `config` (the registered `round_config` node), so a step reaches everything through the configurator.

| Order | Step node | Script | What it does |
| --- | --- | --- | --- |
| 1 | `CreateCountryManager` | `create_country_manager_step.gd` | Instantiates the country manager under `Logic`, registers it as `country_manager`, and calls its `initialize()`. |
| 2 | `CreateStateManager` | `create_state_manager_step.gd` | Instantiates the state manager (with `TurnManager` and `PhaseManager`) under `Logic` and registers it as `state_manager`. |
| 3 | `CreatePlayerCountry` | `create_player_country_step.gd` | Creates the country whose id is `config.player_country_id` and sets its `is_player`. |
| 4 | `CreatePlayers` | `create_players_step.gd` | Creates the opponents through the factory. With no save it picks `config.player_count - 1` random countries (never the player's); `player_count` is 3 and is not yet editable in the panel. With `config.save_data` it creates the saved non-player countries instead. |
| 5 | `SetTurnOrder` | `set_turn_order_step.gd` | Sorts the created countries by `country_initiative`, highest first (ties keep creation order), passes the order to `TurnManager.set_turn_order()`, then calls `next_turn()` so the top country is current. |
| 6 | `RestoreSavedState` | `restore_saved_state_step.gd` | Does nothing unless `config.save_data` is set. Otherwise calls `load_save_data` on the state manager, phase manager and turn manager, which overwrites the order and index `SetTurnOrder` just set. |

**How it runs.**

- `_ready()` defers `run_steps()` by one step, so steps can add systems to `Logic` after the configurator has finished entering the tree.
- `run_steps()` loops over its children and runs `await step.run(self)`. A step is complete when `run()` returns. A step that needs time awaits a signal or timer inside `run()`.
- After each step the configurator emits `step_completed(step)`. After the last step it emits `all_completed`.
- On `all_completed` the configurator releases the `round_config` node (which also discards any loaded `save_data`) and requests `GameState.State.PLAYING_ROUND`. The router then frees the configurator and its children.

**Checklist UI.** `round_configurator_ui.tscn` is created by the router next to the configurator. For each step it adds a read-only checkbox labelled with the step's node name (for example, `CreateCountryManager` shows as "Create Country Manager") and ticks it on `step_completed`. The steps know nothing about the UI.

## Playing round

The playing round does not own its systems. It is a thin scene that receives the country manager, and its UI is wired to the state manager the configurator already built.

- **Logic (`playing_round_logic.tscn`).** A `PlayingRound` node with an `EventCoordinators` child that holds `GameInitializer`. The router calls `initialize(country_manager)`, which passes the manager down to the initializer. `GameInitializer` only stores it so far.
- **Systems.** The country manager and state manager were created and registered during configure. The router reads `state_manager` from the registry and takes `turn_manager` and `phase_manager` from it.
- **UI (`playing_round_ui.tscn`).** The router calls `initialize(state_manager, phase_manager, turn_manager)`. `PhaseLabel` and `TurnLabel` each draw their current value on initialize and update on `phase_changed` and `turn_changed`. `TurnLabel` reads the current country from `TurnManager.get_current_turn()` and shows "STANDBY" when there is none. The end-turn button (`Buttons/EndTurnButton`) holds the state manager and calls `state_manager.turn_manager.next_turn()`.
- **Input.** `InputHandler` (`playing_round_input.gd`, under `Logic`) handles two keys: F5 calls `SaveWriter.save()`, and Alt requests `MAIN_MENU`.
- **Teardown.** The router frees the UI on `MAIN_MENU`. `logic.clear()` frees the playing round logic, the country manager and the state manager together.

## Turn and phase system

`state_manager.tscn` holds `TurnManager` and `PhaseManager`, and its root script (`states.gd`) keeps the round counter. The managers never reference each other. Three `[connection]` entries in the scene link them:

| Signal | From | To |
| --- | --- | --- |
| `all_turns_completed` | `TurnManager` | `PhaseManager.next_phase` |
| `phase_changed` | `PhaseManager` | `TurnManager.start_turns` (`unbinds=1`, since `start_turns` takes no argument) |
| `cycle_completed` | `PhaseManager` | `StateManager._on_phase_manager_cycle_completed`, which adds 1 to `current_round` |

- **`TurnManager`** holds `turn_order` (country names) and `current_turn_index`. `set_turn_order()` replaces the order. `start_turns()` resets the index to -1 and selects the first country. `next_turn()` moves to the next country. Past the last one it resets the index to -1, emits `all_turns_completed` and does not emit `turn_changed`. `get_current_turn()` returns the current name, or `null`.
- **`PhaseManager`** builds its cycle from the `RoundPhase` enum with `STANDBY` filtered out, so the enum is the only list of phases. `next_phase()` goes to the next phase and emits `cycle_completed` first when `UPKEEP_PHASE` wraps to `ECONOMIC_PHASE`. Leaving `STANDBY` does not emit it.
- **`StateManager`** holds `current_round` (starts at 0), `set_round(n)` and the `round_changed(new_round)` signal.

One END TURN press, in order:

1. The button calls `next_turn()`.
2. After the last country, `all_turns_completed` fires and `next_phase()` advances the phase.
3. `phase_changed` calls `start_turns()`, so the first country is up in the new phase.
4. After `UPKEEP_PHASE`, `cycle_completed` fires and the round counter goes up.

The turn order is computed once, during `SetTurnOrder`. It does not change between phases.

## Saving and loading

**Save.** `SaveWriter` is an autoload (`Scripts/Autoload/save_writer.gd`). `main_scene.gd` calls `SaveWriter.initialize(logic)` once so it can read the registry. `save()` writes one file, `user://saves/save.json`, and each save overwrites it. The file holds:

| Key | Source |
| --- | --- |
| `version` | `SAVE_VERSION` (1). Written but not checked on load. |
| `round` | `StateManager.get_save_data()`: `current_round` |
| `phase` | `PhaseManager.get_save_data()`: `current_phase` |
| `turn` | `TurnManager.get_save_data()`: `turn_order`, `current_turn_index` |
| `countries` | Each country's `Data.get_save_data()`: `id`, `is_player` |

Country name and initiative are not saved. They come from the country JSON, so editing the JSON still applies to old saves. `Data` carries `id` and `is_player` for this: the factory sets `id`, and `CreatePlayerCountry` sets `is_player`, since `round_config` is gone by the time the round plays.

**Load.** There is no separate load path. The load button puts the parsed save on the `round_config` node and requests `CONFIGURE_ROUND`, and the normal steps build the round to that config. `CreatePlayerCountry` reads the player id from the config unchanged, `CreatePlayers` creates the saved opponents, and `RestoreSavedState` applies round, phase and turn. `load_save_data` sets fields directly. `PhaseManager` must not go through `advance_phase`, because `phase_changed` calls `start_turns` and would reset the turn index.

## Scene loading

`SceneLoader` (`Scripts/Autoload/scene_loader.gd`) is the one place scenes are loaded. It has two functions:

- **`request(path)`** starts loading the scene on a background thread and returns immediately.
- **`instantiate(path)`** returns an instance. If the path was requested, it uses that load and waits for it if it has not finished. If not, it falls back to a plain `load(path)`.

Loading the resource (reading and parsing the scene and what it references) is the slow part, and `request` moves it off the frame where the player is waiting. Creating the nodes still happens on the main thread when `instantiate` is called. `instantiate` works without a prior `request`, so a prefetch is an optional speedup that can be added to a heavy transition without changing the caller.

Today only one prefetch exists: `StateRouter` requests the playing round logic and UI when it enters `CONFIGURE_ROUND`. See Known gaps for why that does not help yet.

## How to extend

**Add a round setup step**

1. Write a script with `func run(configurator)`. Reach other systems through `configurator.logic.get_system("name")` and the config through `configurator.config`.
2. Add a child node with that script under `RoundConfigurator` in `round_configurator_logic.tscn`. Its position among the children is its place in the order.
3. Nothing else changes: the checklist UI picks up the new node by name, and the configurator emits `step_completed` for it.

**Add a system that lives for the round**

1. Make a scene for it.
2. Add a step that instantiates it with `SceneLoader.instantiate(PATH)` under `Logic`, calls `logic.register("name", node)`, and runs any `initialize()` it needs.
3. Read it elsewhere with `logic.get_system("name")`. `logic.clear()` frees it on `MAIN_MENU`.

**Add a top-level game state (credits, for example)**

1. Add a value to `GameState.State`.
2. Add a branch in `state_router.gd`'s `_on_state_changed`, plus `create_` and `destroy_` functions that follow the existing ones: logic through the registry, UI through a router variable. Hold the scene paths as constants and use `SceneLoader.instantiate`. If the state is heavy, call `SceneLoader.request` for its scenes while the previous state runs.
3. Have something request it with `GameState.state_change_requested.emit(...)`.

**Add a main menu panel**

1. Add a value to `MainMenuState.State`.
2. Handle it in `MainMenuRouter._on_state_changed` (`Scripts/MainMenu/main_menu_router.gd`): create the panel under `main_menu_ui.panels`, and add a `destroy_` call for it to every other branch so only one panel is up.
3. Add a button that calls `change_state` on `MainMenuState`, as `load_game_button.gd` does.

**Make a system saveable**

1. Give the system a `get_save_data() -> Dictionary` with only the values that change at runtime. Anything that comes from a data file should be saved as an id and looked up on load.
2. Give it a `load_save_data(data: Dictionary)` that sets those fields directly. Do not call functions that emit signals other systems react to.
3. Add its data to `SaveWriter.save()` under a new key.
4. Apply it in a configurator step: extend `RestoreSavedState`, or add a step after the system's own creation step. If the system is created from the save (like countries), make its creation step read `config.save_data` the way `CreatePlayers` does.
5. If the save format changes, bump `SAVE_VERSION`. Nothing checks it yet, so add the check in `load_button.gd` at that point.

**Add a country**

- Drop a JSON file with `id`, `country_name` and `initiative` into `Data/Country_Data/`. The factory reads `initiative` unconditionally, so a file without it errors. It appears in the selection list the next time the panel opens.

## Known gaps and next steps

The round setup flow is complete end to end in code, but several parts are placeholders. Items marked "from reading the code" have not been confirmed by running the game.

- **Return to menu is Alt only.** The router's `MAIN_MENU` branch clears `Logic`, rebuilds the menu and frees the playing round UI. Alt is the only trigger, and it is the raw key (the project has no input action for it), so there is no on-screen way back. A second game after returning was checked in a run, with END TURN stepping through the countries.
- **Phase advance is untested.** END TURN past the last country (phase change, `start_turns`, round counter) has not been run yet.
- **Steps finish instantly.** All the configurator steps are synchronous, so the whole configure state runs in one frame and the checklist UI is replaced before it can be seen. It becomes visible once a step awaits something. The same applies to the background load of the playing round scenes, which starts when configure begins: with every step finishing in one frame it has no time to run ahead, so the prefetch has no measurable effect yet.
- **Unclaimed requests.** A scene requested through `SceneLoader.request` is only released from the background loader once `instantiate` claims it. `CONFIGURE_ROUND` always ends in `PLAYING_ROUND` today, so it is claimed. A way to cancel setup would leave the request unclaimed.
- **Scene loading is unmeasured.** Nothing has been timed, so it is not known which scenes or steps are slow. Measure before adding more prefetches.
- **No first phase.** Nothing moves `PhaseManager` off `STANDBY`. Planned: a final configurator step that calls `next_phase()` and `set_round(1)`, and replaces the `next_turn()` call in `SetTurnOrder`. Until then the phase becomes `ECONOMIC_PHASE` only after the first full pass of END TURN, and `current_round` stays 0 until the first full cycle completes.
- **Fixed turn order.** Initiative is read once at setup. Re-sorting each phase means moving the sort out of `SetTurnOrder` into runtime code that can see the country nodes.
- **Player count is fixed.** `RoundConfig.player_count` is 3. The panel does not expose it, and opponents are always random, with no per-opponent choice.
- **Nothing listens to `round_changed`.** There is no round label yet.
- **Save and load are untested.** F5 save, the load entry, the X button and the restore step have been written but not run in the editor.
- **One save slot.** F5 overwrites `user://saves/save.json`. Multiple slots would need a name per save and a list in the load panel.
- **Version is not checked.** `version` is written and ignored on load.
- **Saved countries must exist.** A save naming a country with no JSON file would fail in the factory. This is accepted for now.
- **No runtime country values are saved.** `Data` declares population, money and public image, but nothing sets them yet.
- **Stubs.** `GameInitializer` stores the country manager and does nothing; the phases have names and a cycle but no behaviour.
- **Open editor error, unconfirmed.** The editor reported `Could not resolve script "res://Scripts/Logic/round_config.gd"` at line 7 of `country_factory.gd`, which was a `preload` of `round_config.gd`. Nothing preloads `round_config.gd` any more, but the editor has not been opened since, so it is not known whether the error is gone.
- **New scripts have no `.uid` files.** `country_files.gd` and `save_file.gd` get them when the editor next scans the project.

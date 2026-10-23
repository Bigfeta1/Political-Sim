extends Node

const RoundConfig = preload("res://Scripts/Logic/round_config.gd")

@onready var generators = {
	RoundConfig.MapType.RANDOM: $RandomTerrain,
	RoundConfig.MapType.EARTH: $EarthTerrain,
}

func generate(dimensions: Vector2i, map_type: int) -> Dictionary:
	return generators[map_type].generate(dimensions)

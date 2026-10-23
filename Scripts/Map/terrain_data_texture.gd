extends RefCounted

const WaterDataTexture = preload("res://Scripts/Map/water_data_texture.gd")

const NO_TILE = 255

static func build(cells: Dictionary) -> ImageTexture:
	var origin = WaterDataTexture.find_origin(cells)
	var size = WaterDataTexture.find_size(cells, origin)

	var image = Image.create(size.x, size.y, false, Image.FORMAT_R8)
	image.fill(Color(NO_TILE / 255.0, 0.0, 0.0))

	for coordinate in cells:
		var pixel = coordinate - origin
		image.set_pixel(pixel.x, pixel.y, Color(cells[coordinate].terrain / 255.0, 0.0, 0.0))

	return ImageTexture.create_from_image(image)

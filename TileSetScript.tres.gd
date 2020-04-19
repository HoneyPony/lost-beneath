tool
extends TileSet

func _forward_subtile_selection(autotile_id, bitmask, tilemap, tile_location):
	var phys: TileMap = tilemap.get_node("../Physics")
	phys.set_cellv(tile_location, 0)

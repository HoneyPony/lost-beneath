tool
extends TileSet

const ERASER_ID = 1

func amod(a, b):
	var f = fmod(a, b)
	if a < 0:
		return f + b - 1
	return f

func tile_0(autotile_id, bitmask, tilemap, tile_location):
	var u = tilemap.get_cellv(tile_location + Vector2(0, -1)) == 0
	var l = tilemap.get_cellv(tile_location + Vector2(-1, 0)) == 0
	var r = tilemap.get_cellv(tile_location + Vector2(1, 0)) == 0
	var d = tilemap.get_cellv(tile_location + Vector2(0, 1)) == 0
	
	if u and l and r and d:
		var x = amod(tile_location.x, 4)
		var y = amod(tile_location.y, 4)
		return Vector2(1 + x, 1 + y)

	if u and l and r:
		var x = amod(tile_location.x, 4)
		return Vector2(1 + x, 5)
	if d and l and r:
		var x = amod(tile_location.x, 4)
		return Vector2(1 + x, 0)
	if l and u and d:
		var y = amod(tile_location.y, 4)
		return Vector2(5, 1 + y)
	if r and u and d:
		var y = amod(tile_location.y, 4)
		return Vector2(0, 1 + y)
		
	if u and l:
		return Vector2(5, 5)
	if d and l:
		return Vector2(5, 0)
	if u and r:
		return Vector2(0, 5)
	if d and r:
		return Vector2(0, 0)

	var x = amod(tile_location.x, 4)
	var y = amod(tile_location.y, 4)
	return Vector2(1 + x, 1 + y)
	
func tile_2(autotile_id, bitmask, tilemap, tile_location):
	var u = tilemap.get_cellv(tile_location + Vector2(0, -1)) == 2
	var l = tilemap.get_cellv(tile_location + Vector2(-1, 0)) == 2
	var r = tilemap.get_cellv(tile_location + Vector2(1, 0)) == 2
	var d = tilemap.get_cellv(tile_location + Vector2(0, 1)) == 2
	
	var fu = tilemap.get_cellv(tile_location + Vector2(0, -1)) != -1
	var fl = tilemap.get_cellv(tile_location + Vector2(-1, 0)) != -1
	var fr = tilemap.get_cellv(tile_location + Vector2(1, 0)) != -1
	var fd = tilemap.get_cellv(tile_location + Vector2(0, 1)) != -1

	if u and l:
		return Vector2(2, 2)
	if d and l:
		return Vector2(2, 0)
	if u and r:
		return Vector2(0, 2)
	if d and r:
		return Vector2(0, 0)

	if (l or r) and fu:
		return Vector2(1, 0)
	if (l or r) and fd:
		return Vector2(1,2)
	if (u or d) and fr:
		return Vector2(2, 1)
	if (u or d) and fl:
		return Vector2(0, 1)
		
	

	return Vector2(1, 0)
	
func tile_3(autotile_id, bitmask, tilemap, tile_location):
	var l = tilemap.get_cellv(tile_location + Vector2(-1, 0)) == 3
	var r = tilemap.get_cellv(tile_location + Vector2(1, 0)) == 3

	if l and r:
		var x = amod(tile_location.x, 4)
		return Vector2(1 + x, 0)
	if l:
		return Vector2(5, 0)
	if r:
		return Vector2(0, 0)

	return Vector2(0, 0)
	


func _forward_subtile_selection(autotile_id, bitmask, tilemap_, tile_location):
	var tilemap: TileMap = tilemap_
	
	var phys: TileMap = tilemap.get_node("../Physics")
	var spikes: TileMap = tilemap.get_node("../Spikes")
	if autotile_id == ERASER_ID:
		tilemap.call_deferred("set_cellv", tile_location, -1)
		phys.set_cellv(tile_location, -1)
		spikes.set_cellv(tile_location, -1)
	else:
		if autotile_id == 2 or autotile_id == 4:
			spikes.set_cellv(tile_location, 0)
			phys.set_cellv(tile_location, -1)
		elif autotile_id == 3:
			phys.set_cellv(tile_location, 1)
			spikes.set_cellv(tile_location, -1)
		else:
			phys.set_cellv(tile_location, 0)
			spikes.set_cellv(tile_location, -1)
	
	
	if autotile_id == 0:
		return tile_0(autotile_id, bitmask, tilemap, tile_location)
	if autotile_id == 2:
		return tile_2(autotile_id, bitmask, tilemap, tile_location)
	if autotile_id == 3:
		return tile_3(autotile_id, bitmask, tilemap, tile_location)

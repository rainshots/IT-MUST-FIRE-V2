/// @description Places or merges a building atomically; returns false without changes on invalid placement.
function building_commit(_b, _x, _y)
{
	if (!instance_exists(_b) || !_b.building_can_move) return false;
	var _snapped = building_grid_snap(_b, _x, _y);
	_x = _snapped.x;
	_y = _snapped.y;
	var _merge = noone;
	var _largest_overlap = 0;
	var _incoming = building_bounds_get(_b, _x, _y);
	// The dragged footprint, not its sprite origin, determines the merge target.
	with (o_worker_building_parent)
	{
		if (id == _b || placement_preview || is_being_dragged || object_index != _b.object_index || _b.upgrade_object == noone) continue;
		var _bounds = building_bounds_get(id, x, y);
		var _width = max(0, min(_incoming.right, _bounds.right) - max(_incoming.left, _bounds.left));
		var _height = max(0, min(_incoming.bottom, _bounds.bottom) - max(_incoming.top, _bounds.top));
		var _overlap = _width * _height;
		if (_overlap > _largest_overlap) { _merge = id; _largest_overlap = _overlap; }
	}
	if(instance_exists(_merge))
	{
		var _up=instance_create_layer(_merge.x,_merge.y,"Instances",_b.upgrade_object);
		if(!building_place_valid(_up,_up.x,_up.y,_b,_merge)) { instance_destroy(_up); return false; }
		// Validate storage before mutating either merge participant.
		var _needed=0;
		if(instance_exists(_b.held_shell)) _needed++;
		if(instance_exists(_merge.held_shell)) _needed++;
		var _available=0;
		with(o_warehouse)
		{
			if(placement_preview || is_being_dragged) continue;
			for(var _i=0;_i<4;++_i) if(!instance_exists(slots[_i])) _available++;
		}
		if(_available<max(0,_needed-1)) { instance_destroy(_up);return false; }
		if (!building_units_displace(_up, _up.x, _up.y, _b, _merge)) { instance_destroy(_up); return false; }
		// Preserve any completed shells while releasing both sets of workers.
		var _sources=[_b,_merge];
		for(var _i=0;_i<2;++_i)
		{
			var _source=_sources[_i];
			building_workers_release(_source);
			if(instance_exists(_source.held_shell))
			{
				var _shell=_source.held_shell;
				if (!warehouse_store(_shell))
				{
					// Preserve one finished shell on the upgrade even when every Warehouse is full.
					shell_storage_release(_shell);
					_up.held_shell = _shell;
					_shell.storage_owner = _up;
					_shell.x = _up.x;
					_shell.y = _up.bbox_top - 28;
				}
			}
		}
		instance_destroy(_b); instance_destroy(_merge);
		return true;
	}
	if(!building_place_valid(_b,_x,_y)) return false;
	if (!building_units_displace(_b, _x, _y)) return false;
	_b.x=_x;_b.y=_y;_b.placement_preview=false;_b.is_being_dragged=false;
	_b.worker_positions_update();
	return true;
}

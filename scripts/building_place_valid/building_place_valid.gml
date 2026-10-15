/// @description Validates zone containment and non-overlap, optionally excluding merge participants.
function building_place_valid(_building, _x, _y, _ignore_a = noone, _ignore_b = noone)
{
	var _r = building_bounds_get(_building,_x,_y);
	var _z = _building.is_defense_building ? defense_zone_get() : building_zone_get();
	var _epsilon = BALANCE_BUILDING_PLACEMENT_EPSILON;
	if (_r.left<_z.left-_epsilon || _r.right>_z.right+_epsilon || _r.top<_z.top-_epsilon || _r.bottom>_z.bottom+_epsilon) return false;
	var _free = true;
	with(o_worker_building_parent)
	{
		if(id==_building || id==_ignore_a || id==_ignore_b || placement_preview) continue;
		var _b = building_bounds_get(id,x,y);
		if(_r.left<_b.right && _r.right>_b.left && _r.top<_b.bottom && _r.bottom>_b.top) _free=false;
	}
	return _free;
}

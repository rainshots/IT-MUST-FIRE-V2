/// @description Counts all living player units, including loaded and airborne payloads.
function player_unit_count_get()
{
	var _count=0;
	with(o_friendly_units) if(hp>0) _count++;
	return _count;
}

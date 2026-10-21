/// @description Counts occupied unit-cap slots for all living player units.
function player_unit_count_get()
{
	var _count=0;
	with(o_friendly_units) if(hp>0) _count += object_index == o_ripcage_cannon ? BALANCE_RIPCAGE_UNIT_SLOTS : 1;
	return _count;
}

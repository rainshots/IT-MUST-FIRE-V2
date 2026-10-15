/// @description Finds an available storage slot; moving or unplaced Warehouses are unavailable.
function warehouse_free_get()
{
	var _found=undefined;
	with(o_warehouse)
	{
		if(placement_preview || is_being_dragged) continue;
		for(var _i=0;_i<4;++_i)
		{
			if(!instance_exists(slots[_i])) { _found={warehouse:id,slot:_i}; break; }
		}
		if(!is_undefined(_found)) break;
	}
	return _found;
}

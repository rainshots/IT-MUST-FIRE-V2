/// @description Transfers a shell into a free Warehouse slot, optionally into a specified Warehouse.
function warehouse_store(_shell,_warehouse=noone)
{
	var _slot=-1;
	if(instance_exists(_warehouse))
	{
		if(_warehouse.is_being_dragged || _warehouse.placement_preview) return false;
		for(var _i=0;_i<4;++_i) if(_warehouse.slots[_i]==_shell || !instance_exists(_warehouse.slots[_i])) { _slot=_i;break; }
	}
	else
	{
		var _free=warehouse_free_get();
		if(!is_undefined(_free)) { _warehouse=_free.warehouse;_slot=_free.slot; }
	}
	if(_slot<0) return false;
	shell_storage_release(_shell);
	_warehouse.slots[_slot]=_shell;
	_shell.storage_owner=_warehouse;
	_shell.x=_warehouse.x+(_slot mod 2==0 ? -50 : 50);
	_shell.y=_warehouse.y+(_slot div 2==0 ? -50 : 50);
	return true;
}

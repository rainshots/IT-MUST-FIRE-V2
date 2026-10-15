/// @description Detaches a shell only after a successful transfer; drag origins reserve their slots.
function shell_storage_release(_shell)
{
	if(!instance_exists(_shell.storage_owner)) return;
	var _owner=_shell.storage_owner;
	if(_owner.object_index==o_warehouse)
	{
		for(var _i=0;_i<4;++_i) if(_owner.slots[_i]==_shell) _owner.slots[_i]=noone;
	}
	else if(_owner.held_shell==_shell) _owner.held_shell=noone;
	_shell.storage_owner=noone;
}

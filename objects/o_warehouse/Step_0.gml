event_inherited();
if(placement_preview) exit;
for(var _i=0;_i<4;++_i)
{
	var _shell=slots[_i];
	if(!instance_exists(_shell) || _shell.is_being_dragged) continue;
	_shell.x=x+(_i mod 2==0 ? -50 : 50);
	_shell.y=y+(_i div 2==0 ? -50 : 50);
}

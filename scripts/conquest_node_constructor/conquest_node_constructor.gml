/// @description Creates one capturable building; coordinates use the 1920x1080 battle canvas.
function conquest_node_constructor(_x, _y, _kind, _owner, _garrison, _level = 1) constructor
{
	x = _x;
	y = _y;
	kind = _kind;
	owner = _owner;
	garrison = _garrison;
	level = _level;
	upgrade_remaining = 0;
	shot_timer = 0;
	capture_flash = 0;
}

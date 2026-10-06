/// @description Finds a cannon shell using the original HUD slot positions.
function battle_shell_slot_at_gui(_mouse_x, _mouse_y, _controller)
{
	if (!instance_exists(_controller) || !instance_exists(o_hud))
	{
		return noone;
	}
	var _hud = instance_find(o_hud, 0);
	return _hud.projectile_slot_at_gui_position(_mouse_x, _mouse_y, _controller);
}

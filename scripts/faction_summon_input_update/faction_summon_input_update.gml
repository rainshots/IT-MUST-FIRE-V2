/// @description Owns summon shortcuts, buttons and destination clicks; true consumes controller input this frame.
function faction_summon_input_update()
{
	if (!faction_match_started || faction_match_finished || global.player_faction == FACTION.NONE) return false;
	if (global.focus_window != FOCUS_WINDOW.NOONE && global.focus_window != FOCUS_WINDOW.SUMMON)
	{
		faction_summon_selected = -1;
		faction_summon_release_pending = false;
		return false;
	}
	if (faction_summon_release_pending)
	{
		if (!mouse_check_button(mb_left) && !mouse_check_button(mb_right))
		{
			faction_summon_release_pending = false;
			global.focus_window = FOCUS_WINDOW.NOONE;
		}
		return true;
	}
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _hover = -1;
	for (var _index = 0; _index < 3; ++_index)
	{
		var _rect = faction_summon_rect_get(_index);
		if (point_in_rectangle(_mouse_x, _mouse_y, _rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height)) _hover = _index;
	}
	if (faction_summon_selected >= 0 && (keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_right)))
	{
		faction_summon_cancel();
		return true;
	}
	for (var _index = 0; _index < 3; ++_index)
	{
		if (keyboard_check_pressed(ord("1") + _index) || keyboard_check_pressed(vk_numpad1 + _index))
		{
			faction_summon_select(_index);
			return true;
		}
	}
	if (_hover >= 0)
	{
		global.focus_window = FOCUS_WINDOW.SUMMON;
		if (mouse_check_button_pressed(mb_left)) faction_summon_select(_hover);
		return true;
	}
	if (faction_summon_selected < 0)
	{
		if (global.focus_window == FOCUS_WINDOW.SUMMON) global.focus_window = FOCUS_WINDOW.NOONE;
		return false;
	}
	global.focus_window = FOCUS_WINDOW.SUMMON;
	if (global.pause || !mouse_check_button_pressed(mb_left) || !instance_exists(o_camera_controller)) return true;
	// Ignore roster, minimap and sidebar clicks while choosing a world destination.
	if (squad_control_pointer_over_hud(_mouse_x, _mouse_y)) return true;
	if (instance_exists(o_hud))
	{
		var _hud = instance_find(o_hud, 0);
		var _scale = clamp(display_get_gui_height() / 1080, 0.6, 1);
		if (_mouse_x >= display_get_gui_width() - _hud.hud_sidebar_width * _scale) return true;
	}
	if (_mouse_x < 0 || _mouse_y < 0 || _mouse_x >= display_get_gui_width() || _mouse_y >= display_get_gui_height()) return true;
	var _camera = instance_find(o_camera_controller, 0).camera_id;
	var _world_x = camera_get_view_x(_camera) + _mouse_x / display_get_gui_width() * camera_get_view_width(_camera);
	var _world_y = camera_get_view_y(_camera) + _mouse_y / display_get_gui_height() * camera_get_view_height(_camera);
	var _squad = faction_summon_purchase(global.player_faction, faction_summon_selected, _world_x, _world_y);
	if (is_struct(_squad))
	{
		faction_summon_selected = -1;
		faction_summon_release_pending = true;
	}
	else if (!faction_summon_can_purchase(global.player_faction, faction_summon_selected)) faction_summon_selected = -1;
	return true;
}

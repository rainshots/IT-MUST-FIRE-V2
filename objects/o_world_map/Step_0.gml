// The persistent campaign is inactive while a battle room runs.
if (room != r_world_map) exit;

// Reveal newly captured land smoothly after returning from battle or using the capture cheat.
if (taint_boundary_x < taint_boundary_target_x)
{
	var _taint_step = taint_boundary_speed / max(1, room_speed);
	taint_boundary_x = min(taint_boundary_x + _taint_step, taint_boundary_target_x);
	world_map_corruption_update(id);
}

var _mouse_x = device_mouse_x_to_gui(0);
var _mouse_y = device_mouse_y_to_gui(0);
var _pressed = mouse_check_button_pressed(mb_left);
var _inside_panel = point_in_rectangle(_mouse_x, _mouse_y, panel_x, panel_y,
	panel_x + panel_width, attack_y + attack_height);
hovered_level = noone;
hovered_squad = noone;

// Hit test editor-placed points on the same canvas used to draw them.
var _level_count = array_length(levels);
if (!_inside_panel)
{
	for (var _index = 0; _index < _level_count; ++_index)
	{
		var _point = levels[_index].point;
		if (!instance_exists(_point)) continue;
		var _radius = sprite_get_width(_point.sprite_index) * abs(_point.image_xscale) * 0.5 + point_hover_padding;
		if (point_distance(_mouse_x, _mouse_y, _point.x, _point.y) <= _radius)
		{
			hovered_level = _point;
			break;
		}
	}
	var _card_count = min(array_length(roster_cards), BALANCE_BATTLE_ROSTER_LIMIT);
	for (var _card_index = 0; _card_index < _card_count; ++_card_index)
	{
		var _card_left = card_x + _card_index * (card_width + card_gap);
		if (point_in_rectangle(_mouse_x, _mouse_y, _card_left, card_y,
			_card_left + card_width, card_y + card_height))
		{
			hovered_squad = roster_cards[_card_index];
			break;
		}
	}
}

// F8 captures the hovered point regardless of its normal availability.
var _cheats_enabled = variable_global_exists("cheats_enabled") ? global.cheats_enabled : BALANCE_CHEATS_ENABLED;
if (_cheats_enabled && keyboard_check_pressed(vk_f8) && instance_exists(hovered_level))
{
	world_map_level_capture(id, hovered_level.object_index);
}

// Pinning lets the player reach the panel's button and nested tooltips.
if (_pressed && !_inside_panel)
{
	pinned_level = hovered_level;
	pinned_squad = hovered_squad;
}
if (keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_right))
{
	pinned_level = noone;
	pinned_squad = noone;
}
var _next_level = instance_exists(hovered_level) ? hovered_level : pinned_level;
var _next_squad = is_struct(hovered_squad) ? hovered_squad : pinned_squad;
if (instance_exists(hovered_level)) _next_squad = noone;
if (is_struct(hovered_squad)) _next_level = noone;
if (_next_level != info_level || _next_squad != info_squad)
{
	info_scroll = 0;
	info_scroll_max = 0;
}
info_level = _next_level;
info_squad = _next_squad;
if (_inside_panel)
{
	info_scroll = clamp(info_scroll + (mouse_wheel_down() - mouse_wheel_up()) * scroll_step, 0, info_scroll_max);
}

// Launch only through ATTACK; other points can still be inspected safely.
attack_is_hovered = point_in_rectangle(_mouse_x, _mouse_y, attack_x, attack_y,
	attack_x + attack_width, attack_y + attack_height);
if (_pressed && attack_is_hovered && instance_exists(info_level)
	&& info_level.level_state == WORLD_MAP_LEVEL_STATE.AVAILABLE && room_exists(info_level.battle_room))
{
	active_level = info_level.object_index;
	active_battle_room = info_level.battle_room;
	room_goto(active_battle_room);
}

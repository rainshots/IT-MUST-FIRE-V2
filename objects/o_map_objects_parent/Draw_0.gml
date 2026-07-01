// Draw the map object sprite.
draw_self();

// Draw health and corruption bars.
var _is_cursed_point_building = variable_instance_exists(id, "building_constructed_by_cursed_point")
	&& building_constructed_by_cursed_point;
var _should_draw_corruption_bar = corruption_bar_visible
	&& !building_constructed_by_shell
	&& !_is_cursed_point_building;

if (!health_bar_visible && !_should_draw_corruption_bar)
{
	exit;
}

var _bar_x = x - (bar_width * 0.5);
var _health_bar_y = y - bar_offset_y;
var _corruption_bar_y = _health_bar_y + bar_height + bar_gap;

if (_is_cursed_point_building)
{
	_health_bar_y = bbox_bottom + bar_gap;
	_corruption_bar_y = _health_bar_y + bar_height + bar_gap;
}

var _hp_progress = clamp(hp / max_hp, 0, 1);
var _corruption_progress = clamp(corruption / max_corruption, 0, 1);

draw_set_alpha(0.75);
draw_set_color(c_black);

if (health_bar_visible)
{
	draw_rectangle(_bar_x, _health_bar_y, _bar_x + bar_width, _health_bar_y + bar_height, false);
}

if (_should_draw_corruption_bar)
{
	draw_rectangle(_bar_x, _corruption_bar_y, _bar_x + bar_width, _corruption_bar_y + bar_height, false);
}

draw_set_alpha(1);

if (health_bar_visible)
{
	draw_set_color(c_lime);
	draw_rectangle(_bar_x, _health_bar_y, _bar_x + (bar_width * _hp_progress), _health_bar_y + bar_height, false);
}

if (_should_draw_corruption_bar)
{
	draw_set_color(COLOR_PROJECTILE_CORRUPTION);
	draw_rectangle(_bar_x, _corruption_bar_y, _bar_x + (bar_width * _corruption_progress), _corruption_bar_y + bar_height, false);
}

// Show upgrade prompt while the cursor hovers upgradeable map structures.
if (building_has_upgrades
	&& is_captured
	&& global.focus_window == FOCUS_WINDOW.NOONE
	&& map_object_is_hovered())
{
	var _prompt_width = string_width(upgrade_prompt_text) + (upgrade_prompt_padding_x * 2);
	var _prompt_height = string_height(upgrade_prompt_text) + (upgrade_prompt_padding_y * 2);
	var _prompt_x = x - (_prompt_width * 0.5);
	var _prompt_y = bbox_bottom + upgrade_prompt_offset_y;

	draw_set_alpha(upgrade_prompt_background_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_prompt_x, _prompt_y, _prompt_x + _prompt_width, _prompt_y + _prompt_height, false);

	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_HUD_IRON);
	draw_text(x, _prompt_y + (_prompt_height * 0.5), upgrade_prompt_text);
}

// Draw short building warnings above shell structures.
if (building_warning_timer > 0 && building_warning_text != "")
{
	var _warning_alpha = clamp(building_warning_timer / max(1, building_warning_time), 0, 1);
	var _warning_x = x;
	var _warning_y = y - building_warning_offset_y;
	var _warning_width = string_width(building_warning_text) + (building_warning_padding_x * 2);
	var _warning_height = string_height(building_warning_text) + (building_warning_padding_y * 2);
	var _warning_left = _warning_x - (_warning_width * 0.5);
	var _warning_top = _warning_y - (_warning_height * 0.5);

	draw_set_alpha(building_warning_background_alpha * _warning_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_roundrect(
		_warning_left,
		_warning_top,
		_warning_left + _warning_width,
		_warning_top + _warning_height,
		false
	);

	draw_set_alpha(_warning_alpha);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(building_warning_color);
	draw_text(_warning_x, _warning_y, building_warning_text);
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

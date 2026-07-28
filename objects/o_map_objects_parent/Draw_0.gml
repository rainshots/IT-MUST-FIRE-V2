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

var _health_bar_y = y - bar_offset_y;
var _corruption_bar_y = _health_bar_y + bar_height + bar_gap;

if (_is_cursed_point_building)
{
	_health_bar_y = bbox_bottom + bar_gap;
	_corruption_bar_y = _health_bar_y + bar_height + bar_gap;
}

var _hp_bar_max = max_hp;
var _max_hp_progress = 1;

if (variable_instance_exists(id, "player_building_cleansed_hp_penalty_applied")
	&& player_building_cleansed_hp_penalty_applied
	&& variable_instance_exists(id, "player_building_cleansed_base_max_hp")
	&& player_building_cleansed_base_max_hp > max_hp)
{
	_hp_bar_max = player_building_cleansed_base_max_hp;
	_max_hp_progress = clamp(max_hp / _hp_bar_max, 0, 1);
}

var _hp_progress = clamp(hp / _hp_bar_max, 0, 1);
var _corruption_progress = clamp(corruption / max_corruption, 0, 1);
var _bar_width = health_bar_width_get(bar_width, _hp_bar_max);
var _bar_x = x - (_bar_width * 0.5);

draw_set_alpha(0.75);
draw_set_color(c_black);

if (health_bar_visible)
{
	draw_rectangle(_bar_x, _health_bar_y, _bar_x + _bar_width, _health_bar_y + bar_height, false);
}

if (_should_draw_corruption_bar)
{
	draw_rectangle(_bar_x, _corruption_bar_y, _bar_x + _bar_width, _corruption_bar_y + bar_height, false);
}

draw_set_alpha(1);

if (health_bar_visible)
{
	if (_max_hp_progress < 1)
	{
		draw_set_color(COLOR_STATUS_NEGATIVE_RED);
		draw_rectangle(
			_bar_x + (_bar_width * _max_hp_progress),
			_health_bar_y,
			_bar_x + _bar_width,
			_health_bar_y + bar_height,
			false
		);
	}

	draw_set_color(c_lime);
	draw_rectangle(_bar_x, _health_bar_y, _bar_x + (_bar_width * _hp_progress), _health_bar_y + bar_height, false);
	draw_set_color(c_black);
	health_bar_segments_draw(_bar_x, _health_bar_y, _bar_width, bar_height, _hp_bar_max);
}

if (_should_draw_corruption_bar)
{
	draw_set_color(COLOR_PROJECTILE_CORRUPTION);
	draw_rectangle(_bar_x, _corruption_bar_y, _bar_x + (_bar_width * _corruption_progress), _corruption_bar_y + bar_height, false);
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

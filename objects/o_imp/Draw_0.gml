// Draw Crimson Guillotine flight before the landing strike resolves.
if (crimson_guillotine_strike_timer > 0)
{
	var _guillotine_elapsed = crimson_guillotine_strike_duration - crimson_guillotine_strike_timer;
	var _target_x = crimson_guillotine_start_x;
	var _target_y = crimson_guillotine_start_y;

	if (instance_exists(crimson_guillotine_target))
	{
		_target_x = crimson_guillotine_target.x;
		_target_y = crimson_guillotine_target.y;
	}

	var _visual_x = crimson_guillotine_start_x;
	var _visual_y = crimson_guillotine_apex_y;
	var _is_falling = _guillotine_elapsed > crimson_guillotine_ascent_duration;
	var _fall_start_x = _target_x;
	var _fall_start_y = _target_y - BALANCE_IMP_CRIMSON_GUILLOTINE_FALL_HEIGHT;

	if (_is_falling)
	{
		var _fall_elapsed = _guillotine_elapsed - crimson_guillotine_ascent_duration;
		var _fall_progress = clamp(_fall_elapsed / max(1, crimson_guillotine_fall_duration), 0, 1);

		_visual_x = _fall_start_x;
		_visual_y = lerp(_fall_start_y, _target_y, _fall_progress);
	}
	else
	{
		var _ascent_progress = clamp(_guillotine_elapsed / max(1, crimson_guillotine_ascent_duration), 0, 1);

		_visual_y = lerp(crimson_guillotine_start_y, crimson_guillotine_apex_y, _ascent_progress);
	}

	visual_attack_offset_x = _visual_x - x;
	visual_attack_offset_y = _visual_y - y;
	visual_offset_is_ability_controlled = true;

	draw_set_color(COLOR_STATUS_NEGATIVE_RED);
	draw_set_alpha(0.45);
	draw_line_width(crimson_guillotine_start_x, crimson_guillotine_start_y - 12, crimson_guillotine_start_x, crimson_guillotine_apex_y - 12, 3);

	if (_is_falling)
	{
		draw_set_alpha(0.55);
		draw_line_width(_fall_start_x, _fall_start_y - 12, _visual_x, _visual_y - 12, 15);
		draw_set_alpha(0.95);
		draw_line_width(_fall_start_x, _fall_start_y - 12, _visual_x, _visual_y - 12, 5);
	}

	if (instance_exists(crimson_guillotine_target))
	{
		var _guillotine_level = max(1, imp_ability_level_get(DEMON_ABILITY.IMP_CRIMSON_GUILLOTINE));
		var _aoe_radius = imp_crimson_guillotine_aoe_radius_get(_guillotine_level);

		draw_set_alpha(0.28);
		draw_circle(_target_x, _target_y, _aoe_radius, false);
	}

	draw_set_color(c_white);
	draw_set_alpha(1);
}
// Draw jump trajectory before the sprite while active ability movement is visible.
else if (leap_visual_timer > 0)
{
	var _leap_progress = 1 - clamp(leap_visual_timer / max(1, leap_visual_duration), 0, 1);
	var _arc_lift = 0;
	var _visual_x = lerp(leap_visual_start_x, leap_visual_end_x, _leap_progress);
	var _visual_y = lerp(leap_visual_start_y, leap_visual_end_y, _leap_progress) - _arc_lift;

	if (leap_visual_start_x != leap_visual_end_x)
	{
		_arc_lift = sin(_leap_progress * pi) * leap_visual_arc_height;
		_visual_y -= _arc_lift;
	}

	visual_attack_offset_x = _visual_x - x;
	visual_attack_offset_y = _visual_y - y;

	draw_set_color(COLOR_STATUS_NEGATIVE_RED);
	draw_set_alpha(0.75);
	draw_line_width(leap_visual_start_x, leap_visual_start_y - 16, leap_visual_end_x, leap_visual_end_y - 16, 9);
	draw_set_alpha(0.95);
	draw_line_width(leap_visual_start_x, leap_visual_start_y - 16, leap_visual_end_x, leap_visual_end_y - 16, 3);
}

// Draw lingering Demon Leap chain segments as red slashes.
for (var _leap_segment_index = 0; _leap_segment_index < array_length(leap_visual_segments); ++_leap_segment_index)
{
	var _leap_segment = leap_visual_segments[_leap_segment_index];
	var _segment_progress = clamp(_leap_segment.timer / max(1, _leap_segment.duration), 0, 1);
	var _segment_alpha = 0.7 * _segment_progress;
	var _slash_size = 14;
	var _segment_direction = point_direction(_leap_segment.start_x, _leap_segment.start_y, _leap_segment.end_x, _leap_segment.end_y);
	var _lightning_offset = 10 + ((_leap_segment_index mod 2) * 6);
	var _lightning_mid_x = (_leap_segment.start_x + _leap_segment.end_x) * 0.5 + lengthdir_x(_lightning_offset, _segment_direction + 90);
	var _lightning_mid_y = (_leap_segment.start_y + _leap_segment.end_y) * 0.5 + lengthdir_y(_lightning_offset, _segment_direction + 90);

	draw_set_color(COLOR_STATUS_NEGATIVE_RED);
	draw_set_alpha(_segment_alpha * 0.6);
	draw_line_width(_leap_segment.start_x, _leap_segment.start_y - 16, _lightning_mid_x, _lightning_mid_y - 16, 11);
	draw_line_width(_lightning_mid_x, _lightning_mid_y - 16, _leap_segment.end_x, _leap_segment.end_y - 16, 11);
	draw_set_alpha(_segment_alpha);
	draw_line_width(_leap_segment.start_x, _leap_segment.start_y - 16, _lightning_mid_x, _lightning_mid_y - 16, 4);
	draw_line_width(_lightning_mid_x, _lightning_mid_y - 16, _leap_segment.end_x, _leap_segment.end_y - 16, 4);

	if (_leap_segment.draw_slash)
	{
		draw_set_alpha(_segment_alpha * 0.9);
		draw_line_width(
			_leap_segment.end_x - _slash_size,
			_leap_segment.end_y - _slash_size,
			_leap_segment.end_x + _slash_size,
			_leap_segment.end_y + _slash_size,
			3
		);
		draw_line_width(
			_leap_segment.end_x - _slash_size,
			_leap_segment.end_y + _slash_size,
			_leap_segment.end_x + _slash_size,
			_leap_segment.end_y - _slash_size,
			3
		);
	}
}

draw_set_color(c_white);
draw_set_alpha(1);

// Draw active blood pools before unit visuals.
for (var _pool_index = 0; _pool_index < array_length(blood_pool_data); ++_pool_index)
{
	var _pool = blood_pool_data[_pool_index];
	var _pool_progress = clamp(_pool.timer / max(1, BALANCE_IMP_DEMON_LEAP_BLOOD_POOL_TIME * room_speed), 0, 1);

	draw_set_alpha(0.28 * _pool_progress);
	draw_set_color(COLOR_STATUS_NEGATIVE_RED);
	draw_circle(_pool.x, _pool.y, BALANCE_IMP_DEMON_LEAP_BLOOD_POOL_RADIUS, false);
}

draw_set_alpha(1);
draw_set_color(c_white);

// Draw base combat visuals.
event_inherited();

if (leap_visual_timer <= 0 && crimson_guillotine_strike_timer <= 0)
{
	visual_attack_offset_x = 0;
	visual_attack_offset_y = 0;
	visual_offset_is_ability_controlled = false;
}

// Draw the cultist name above the demon.
if (variable_global_exists("ui_font") && font_exists(global.ui_font))
{
	draw_set_font(global.ui_font);
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(COLOR_HUD_TEXT);
draw_text(x, y - 42, cultist_name);

// Draw Frenzy Echo phantom while the hit flash is active.
if (frenzy_echo_visual_timer > 0)
{
	var _phantom_alpha = clamp(frenzy_echo_visual_timer / 12, 0, 1) * 0.55;

	draw_set_alpha(_phantom_alpha);
	draw_set_color(COLOR_STATUS_NEGATIVE_RED);
	draw_sprite_ext(sprite_index, image_index, frenzy_echo_visual_x, frenzy_echo_visual_y, image_xscale, image_yscale, 0, COLOR_STATUS_NEGATIVE_RED, _phantom_alpha);
	draw_line_width(
		frenzy_echo_visual_x,
		frenzy_echo_visual_y - 12,
		frenzy_echo_visual_x + lengthdir_x(34, frenzy_echo_visual_direction),
		frenzy_echo_visual_y + lengthdir_y(34, frenzy_echo_visual_direction) - 12,
		3
	);
	draw_set_alpha(1);
}

// Draw rotating Blood Blades around the Imp.
if (imp_blood_blades_level_get() > 0)
{
	var _blade_count = imp_blood_blades_count_get();
	var _blade_radius = imp_blood_blades_radius_get();

	for (var _blade_index = 0; _blade_index < _blade_count; ++_blade_index)
	{
		var _blade_direction = blood_blades_angle + ((360 / _blade_count) * _blade_index);
		var _blade_x = x + lengthdir_x(_blade_radius, _blade_direction);
		var _blade_y = y + lengthdir_y(_blade_radius, _blade_direction);

		draw_set_alpha(0.95);
		draw_sprite_ext(s_blood_knife, 0, _blade_x, _blade_y, 1, 1, _blade_direction, c_white, 0.95);
	}
}

draw_set_alpha(1);
draw_set_color(c_white);

// Draw compact Blood Hunger stack bars below the health bar.
var _stack_count = imp_blood_frenzy_stack_count_get();

if (_stack_count > 0)
{
	var _bar_width = 10;
	var _bar_height = 3;
	var _bar_gap = 2;
	var _bar_total_width = (BALANCE_IMP_BLOOD_FRENZY_MAX_STACKS * _bar_width)
		+ ((BALANCE_IMP_BLOOD_FRENZY_MAX_STACKS - 1) * _bar_gap);
	var _bar_x = x - (_bar_total_width * 0.5);
	var _bar_y = y + 32;

	for (var _stack_index = 0; _stack_index < BALANCE_IMP_BLOOD_FRENZY_MAX_STACKS; ++_stack_index)
	{
		var _current_bar_x = _bar_x + ((_bar_width + _bar_gap) * _stack_index);
		var _progress = clamp(blood_frenzy_stack_timers[_stack_index] / max(1, BALANCE_IMP_BLOOD_FRENZY_DURATION * room_speed), 0, 1);

		draw_set_alpha(0.75);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_current_bar_x, _bar_y, _current_bar_x + _bar_width, _bar_y + _bar_height, false);

		if (_progress > 0)
		{
			draw_set_alpha(1);
			draw_set_color(COLOR_STATUS_NEGATIVE_RED);
			draw_rectangle(_current_bar_x, _bar_y, _current_bar_x + (_bar_width * _progress), _bar_y + _bar_height, false);
		}
	}
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

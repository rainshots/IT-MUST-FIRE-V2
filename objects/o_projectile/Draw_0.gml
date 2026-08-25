// Select projectile color by type.
var _projectile_color = COLOR_PROJECTILE_DAMAGE;

if (projectile_type == PROJECTILE_TYPE.CORRUPTION)
{
	_projectile_color = COLOR_PROJECTILE_CORRUPTION;
}
else if (projectile_type == PROJECTILE_TYPE.SUMMON)
{
	_projectile_color = COLOR_PROJECTILE_SUMMON;
}
else if (projectile_type == PROJECTILE_TYPE.RALLY)
{
	_projectile_color = COLOR_PROJECTILE_RALLY;
}
else if (projectile_type == PROJECTILE_TYPE.CULTIST)
{
	_projectile_color = COLOR_PROJECTILE_CULTIST;
}
else if (projectile_type == PROJECTILE_TYPE.FEAST)
{
	_projectile_color = COLOR_PROJECTILE_CORRUPTION;
}
else if (projectile_type == PROJECTILE_TYPE.HEAL)
{
	_projectile_color = COLOR_PROJECTILE_HEAL;
}
else if (projectile_type == PROJECTILE_TYPE.BOMB)
{
	_projectile_color = COLOR_PROJECTILE_BOMB;
}
else if (projectile_type == PROJECTILE_TYPE.SKELETONS)
{
	_projectile_color = COLOR_PROJECTILE_SKELETONS;
}
else if (projectile_type == PROJECTILE_TYPE.BUILDING_SHELL)
{
	_projectile_color = COLOR_PROJECTILE_BUILDING_SHELL;
}
else if (projectile_type == PROJECTILE_TYPE.CLEANSE)
{
	_projectile_color = COLOR_PROJECTILE_CLEANSE;
}
else if (projectile_type == PROJECTILE_TYPE.ARTILLERY)
{
	_projectile_color = COLOR_PROJECTILE_BOMB;
}
else if (projectile_type == PROJECTILE_TYPE.DOOM_BELL)
{
	_projectile_color = COLOR_PROJECTILE_BOMB;
}

// Factory shells use their authored sprites; other projectiles retain the round marker.
if (projectile_sprite != noone)
{
	var _projectile_draw_angle = 0;
	var _projectile_draw_xscale = projectile_sprite_scale;
	var _projectile_draw_yscale = projectile_sprite_scale;

	if (projectile_type == PROJECTILE_TYPE.BOMB)
	{
		_projectile_draw_angle = hellcow_charge_direction;

		if (hellcow_charge_active && hellcow_brace_timer > 0)
		{
			var _brace_pulse = sin(hellcow_brace_timer * 0.8);
			_projectile_draw_xscale *= 0.92 + (_brace_pulse * 0.04);
			_projectile_draw_yscale *= 1.08 - (_brace_pulse * 0.04);
			_projectile_draw_angle += _brace_pulse * 2;
		}
	}

	// A landed Hellcow draws two additional cows on each side without changing gameplay collisions.
	var _side_cow_count = projectile_type == PROJECTILE_TYPE.BOMB && hellcow_charge_active
		? BALANCE_PROJECTILE_HELLCOW_VISUAL_SIDE_COW_COUNT
		: 0;
	var _side_direction = _projectile_draw_angle + 90;

	draw_set_color(c_white);

	for (var _cow_index = -_side_cow_count; _cow_index <= _side_cow_count; ++_cow_index)
	{
		var _cow_side_offset = _cow_index * BALANCE_PROJECTILE_HELLCOW_VISUAL_COW_SPACING;
		var _cow_x = x + lengthdir_x(_cow_side_offset, _side_direction);
		var _cow_y = y + lengthdir_y(_cow_side_offset, _side_direction);

		draw_sprite_ext(
			projectile_sprite,
			0,
			_cow_x,
			_cow_y,
			_projectile_draw_xscale,
			_projectile_draw_yscale,
			_projectile_draw_angle,
			c_white,
			1
		);
	}
}
else
{
	var _draw_radius = projectile_radius * projectile_visual_scale;

	draw_set_color(_projectile_color);
	draw_circle(x, y, _draw_radius, false);
}

// Restore default draw state.
draw_set_color(c_white);

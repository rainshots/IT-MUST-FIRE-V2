// Draw Hex Totem damage radius beneath the sprite.
if (ability_level >= 3)
{
	draw_set_color(COLOR_WARLOCK_HEX_TOTEM);
	draw_set_alpha(BALANCE_WARLOCK_HEX_TOTEM_CIRCLE_ALPHA);
	draw_circle(x, y, effect_radius, false);
	draw_set_alpha(BALANCE_WARLOCK_HEX_TOTEM_CIRCLE_OUTLINE_ALPHA);
	draw_circle(x, y, effect_radius, true);
}

// Level 4 shows the final explosion radius so the player can read the danger area.
if (ability_level >= 4)
{
	draw_set_color(COLOR_WARLOCK_SOUL_CHAIN);
	draw_set_alpha(0.16);
	draw_circle(x, y, BALANCE_WARLOCK_HEX_TOTEM_EXPLOSION_RADIUS, false);
	draw_set_alpha(0.35);
	draw_circle(x, y, BALANCE_WARLOCK_HEX_TOTEM_EXPLOSION_RADIUS, true);
}

// Draw recent purple beam shots.
if (beam_line_timer > 0)
{
	var _beam_progress = beam_line_timer / max(1, beam_line_time);

	draw_set_color(COLOR_WARLOCK_HEX_TOTEM);
	draw_set_alpha(0.9 * _beam_progress);

	for (var _target_index = 0; _target_index < array_length(beam_targets); ++_target_index)
	{
		var _target = beam_targets[_target_index];

		if (instance_exists(_target))
		{
			draw_line_width(x, y - 12, _target.x, _target.y - 16, 3);
		}
	}
}

draw_set_color(c_white);
draw_set_alpha(1);

draw_self();

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

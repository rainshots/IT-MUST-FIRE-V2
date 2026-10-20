// Draw corpse snapshots remembered by the game controller.
var _corpse_count = array_length(corpse_draw_data);

for (var _corpse_index = 0; _corpse_index < _corpse_count; ++_corpse_index)
{
	var _corpse = corpse_draw_data[_corpse_index];

	if (!sprite_exists(_corpse.sprite_index))
	{
		continue;
	}

	var _corpse_alpha = _corpse.image_alpha * clamp(_corpse.days_remaining / max(1, _corpse.max_days), 0, 1);

	draw_sprite_ext(
		_corpse.sprite_index,
		_corpse.image_index,
		_corpse.x,
		_corpse.y,
		_corpse.image_xscale,
		_corpse.image_yscale,
		_corpse.image_angle,
		_corpse.image_blend,
		_corpse_alpha
	);
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

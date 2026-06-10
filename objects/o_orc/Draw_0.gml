// Draw neutral orc worker.
draw_self();

// Draw carried corpses above the worker carrying them.
if (variable_instance_exists(id, "carried_corpses") && array_length(carried_corpses) > 0)
{
	var _carried_count = array_length(carried_corpses);

	for (var _corpse_index = 0; _corpse_index < _carried_count; ++_corpse_index)
	{
		var _carried_corpse = carried_corpses[_corpse_index];

		if (sprite_exists(_carried_corpse.sprite_index))
		{
			var _corpse_draw_x = x + ((_corpse_index - ((_carried_count - 1) * 0.5)) * 18);
			var _corpse_draw_y = y - BALANCE_CANNON_CORPSE_CARRY_OFFSET_Y - (_corpse_index * 16);

			draw_sprite_ext(
				_carried_corpse.sprite_index,
				_carried_corpse.image_index,
				_corpse_draw_x,
				_corpse_draw_y,
				_carried_corpse.image_xscale,
				_carried_corpse.image_yscale,
				_carried_corpse.image_angle,
				_carried_corpse.image_blend,
				_carried_corpse.image_alpha
			);
		}
	}
}

// Restore default draw state.
draw_set_color(c_white);
draw_set_alpha(1);

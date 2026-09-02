// Occupied and available points use different sprites; blocked points draw nothing.
if (sprite_exists(sprite_index))
{
	if (squad_point_state == SQUAD_POINT_STATE.AVAILABLE && squad_point_hovered)
	{
		var _pulse = sin(current_time * squad_point_hover_pulse_speed)
			* squad_point_hover_pulse_scale;
		var _hover_scale = squad_point_hover_scale + _pulse;
		var _glow_scale = _hover_scale + squad_point_hover_glow_scale;

		// Draw a larger translucent copy behind the point as a soft interactive glow.
		draw_set_alpha(1);
		draw_sprite_ext(
			sprite_index,
			image_index,
			x,
			y,
			image_xscale * _glow_scale,
			image_yscale * _glow_scale,
			image_angle,
			COLOR_PROJECTILE_SUMMON,
			squad_point_hover_glow_alpha
		);

		// Enlarge the actual point without changing its collision box or instance scale.
		draw_sprite_ext(
			sprite_index,
			image_index,
			x,
			y,
			image_xscale * _hover_scale,
			image_yscale * _hover_scale,
			image_angle,
			image_blend,
			image_alpha
		);

		// A short world label makes the click action explicit.
		var _previous_font = draw_get_font();

		if (variable_global_exists("ui_font") && font_exists(global.ui_font))
		{
			draw_set_font(global.ui_font);
		}

		var _sprite_top = y
			- (sprite_get_height(sprite_index) * abs(image_yscale) * _hover_scale * 0.5);
		var _label_width = string_width(squad_point_hover_label)
			+ (squad_point_hover_label_padding_x * 2);
		var _label_height = string_height(squad_point_hover_label)
			+ (squad_point_hover_label_padding_y * 2);
		var _label_x = x - (_label_width * 0.5);
		var _label_y = _sprite_top - _label_height - squad_point_hover_label_offset_y;

		draw_set_alpha(0.88);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(
			_label_x,
			_label_y,
			_label_x + _label_width,
			_label_y + _label_height,
			false
		);
		draw_set_alpha(1);
		draw_set_color(COLOR_PROJECTILE_SUMMON);
		draw_rectangle(
			_label_x,
			_label_y,
			_label_x + _label_width,
			_label_y + _label_height,
			true
		);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(x, _label_y + (_label_height * 0.5), squad_point_hover_label);
		draw_set_font(_previous_font);
	}
	else
	{
		draw_self();
	}
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

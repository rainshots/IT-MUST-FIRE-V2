// Draw scattered parts in flight or on the ground, and collected parts above the skull.
var _part_count = array_length(body_parts);
var _carried_index = 0;
var _carried_spacing = 30;
var _carried_height = 54;
var _carried_size = 26;
for (var _index = 0; _index < _part_count; ++_index)
{
	var _part = body_parts[_index];
	var _sprite = _part.sprite;
	var _sprite_width = sprite_get_width(_sprite);
	var _sprite_height = sprite_get_height(_sprite);
	var _part_scale = 1;
	var _part_x = _part.target_x;
	var _part_y = _part.target_y;

	if (_part.collected)
	{
		_part_x = x + (_carried_index - (body_parts_collected - 1) * 0.5) * _carried_spacing;
		_part_y = y - _carried_height;
		_part_scale = _carried_size / max(1, max(_sprite_width, _sprite_height));
		_carried_index++;
	}
	else
	{
		var _flight_duration = max(BALANCE_PLAYER_PART_FLIGHT_SECONDS, 1 / max(1, room_speed));
		var _progress = clamp(_part.flight_elapsed / _flight_duration, 0, 1);
		_part_x = lerp(_part.start_x, _part.target_x, _progress);
		_part_y = lerp(_part.start_y, _part.target_y, _progress)
			- sin(_progress * pi) * BALANCE_PLAYER_PART_ARC_HEIGHT;

		// Pulse only uncollected, landed pieces around their fixed visual center.
		if (_part.flight_elapsed >= BALANCE_PLAYER_PART_FLIGHT_SECONDS)
		{
			_part_scale = 1 + sin(_part.pulse_phase) * BALANCE_PLAYER_PART_PULSE_SCALE_AMOUNT;
		}
	}

	// Center the parts consistently regardless of the imported sprite origins.
	var _draw_x = _part_x + (sprite_get_xoffset(_sprite) - _sprite_width * 0.5) * _part_scale;
	var _draw_y = _part_y + (sprite_get_yoffset(_sprite) - _sprite_height * 0.5) * _part_scale;
	draw_sprite_ext(_sprite, 0, _draw_x, _draw_y, _part_scale, _part_scale, 0, c_white, 1);
}

// The default sprite draw keeps the existing facing and walking tilt in either form.
draw_self();

// Show remaining health above the complete skeleton; parts themselves show skull collection progress.
if (!is_disassembled)
{
	var _health_width = 48;
	var _health_height = 5;
	var _health_offset_y = 70;
	var _health_x = x - _health_width * 0.5;
	var _health_y = y - _health_offset_y;
	var _health_share = clamp(hp / max(1, max_hp), 0, 1);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_health_x, _health_y, _health_x + _health_width, _health_y + _health_height, false);
	draw_set_color(COLOR_HUD_SOULS);
	draw_rectangle(_health_x, _health_y, _health_x + _health_width * _health_share, _health_y + _health_height, false);
}

// Restore the project draw defaults.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

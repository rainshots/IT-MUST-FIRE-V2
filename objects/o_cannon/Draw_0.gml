// Draw cannon sprite.
var _cannon_alpha = 1;

if (cannon_has_worker_behind_sprite())
{
	_cannon_alpha = hidden_worker_alpha;
}

draw_set_alpha(_cannon_alpha);
draw_self();
draw_set_alpha(1);

// Match the building hover highlight when the Satisfaction window can be opened.
var _satisfaction_info_is_hovered = false;

if (instance_exists(o_game_controller))
{
	var _game_controller = instance_find(o_game_controller, 0);

	if (variable_instance_exists(_game_controller, "cannon_satisfaction_hovered_get"))
	{
		_satisfaction_info_is_hovered = _game_controller.cannon_satisfaction_hovered_get();
	}
}

if (_satisfaction_info_is_hovered)
{
	var _highlight_padding = 8;

	draw_set_alpha(0.24);
	draw_set_color(COLOR_HUD_IRON);
	draw_rectangle(
		bbox_left - _highlight_padding,
		bbox_top - _highlight_padding,
		bbox_right + _highlight_padding,
		bbox_bottom + _highlight_padding,
		false
	);

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_rectangle(
		bbox_left - _highlight_padding,
		bbox_top - _highlight_padding,
		bbox_right + _highlight_padding,
		bbox_bottom + _highlight_padding,
		true
	);
}

// Highlight the cannon when a dragged unit can be assigned here.
if (variable_global_exists("cultist_assignment_preview_building")
	&& global.cultist_assignment_preview_building == id)
{
	var _preview_padding = 8;

	draw_set_alpha(0.22);
	draw_set_color(COLOR_PROJECTILE_SUMMON);
	draw_rectangle(
		bbox_left - _preview_padding,
		bbox_top - _preview_padding,
		bbox_right + _preview_padding,
		bbox_bottom + _preview_padding,
		false
	);
}

// Show assigned corpse haulers under the cannon.
var _assigned_workers = [];
var _assigned_worker_count = 0;
var _stored_worker_count = array_length(worker_cultists);

for (var _worker_index = 0; _worker_index < _stored_worker_count; ++_worker_index)
{
	var _worker = worker_cultists[_worker_index];
	var _is_valid_worker = instance_exists(_worker)
		&& variable_instance_exists(_worker, "assigned_building")
		&& _worker.assigned_building == id
		&& variable_instance_exists(_worker, "hp")
		&& _worker.hp > 0;

	if (_is_valid_worker)
	{
		array_push(_assigned_workers, _worker);
		_assigned_worker_count++;
	}
}

if (_assigned_worker_count > 0)
{
	var _shown_worker_count = min(_assigned_worker_count, worker_max);
	var _indicator_text = worker_indicator_label + ": " + string(_shown_worker_count) + "/" + string(worker_max);
	var _icon_count = min(_shown_worker_count, array_length(_assigned_workers));
	var _icons_width = (_icon_count * worker_indicator_icon_size) + (max(0, _icon_count - 1) * worker_indicator_icon_gap);
	var _indicator_width = max(string_width(_indicator_text), _icons_width) + (worker_indicator_padding_x * 2);
	var _indicator_height = worker_indicator_padding_y + string_height(_indicator_text) + worker_indicator_line_gap + worker_indicator_icon_size + worker_indicator_padding_y;
	var _indicator_x = x;
	var _indicator_y = bbox_bottom + worker_indicator_offset_y;
	var _indicator_left = _indicator_x - (_indicator_width * 0.5);
	var _indicator_top = _indicator_y - (_indicator_height * 0.5);
	var _text_y = _indicator_top + worker_indicator_padding_y;
	var _icons_y = _text_y + string_height(_indicator_text) + worker_indicator_line_gap;
	var _icon_x = _indicator_x - (_icons_width * 0.5) + (worker_indicator_icon_size * 0.5);

	draw_set_alpha(worker_indicator_background_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(
		_indicator_left,
		_indicator_top,
		_indicator_left + _indicator_width,
		_indicator_top + _indicator_height,
		false
	);

	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_indicator_x, _text_y, _indicator_text);

	for (var _icon_index = 0; _icon_index < _icon_count; ++_icon_index)
	{
		var _icon_worker = _assigned_workers[_icon_index];
		var _icon_center_x = _icon_x + (_icon_index * (worker_indicator_icon_size + worker_indicator_icon_gap));
		var _icon_center_y = _icons_y + (worker_indicator_icon_size * 0.5);

		draw_set_color(c_black);
		draw_rectangle(
			_icon_center_x - (worker_indicator_icon_size * 0.5),
			_icon_center_y - (worker_indicator_icon_size * 0.5),
			_icon_center_x + (worker_indicator_icon_size * 0.5),
			_icon_center_y + (worker_indicator_icon_size * 0.5),
			false
		);

		if (sprite_exists(_icon_worker.sprite_index))
		{
			var _sprite_width = max(1, sprite_get_width(_icon_worker.sprite_index));
			var _sprite_height = max(1, sprite_get_height(_icon_worker.sprite_index));
			var _icon_scale = worker_indicator_icon_size / max(_sprite_width, _sprite_height);
			var _icon_width = _sprite_width * _icon_scale;
			var _icon_height = _sprite_height * _icon_scale;

			draw_sprite_stretched_ext(
				_icon_worker.sprite_index,
				_icon_worker.image_index,
				_icon_center_x - (_icon_width * 0.5),
				_icon_center_y - (_icon_height * 0.5),
				_icon_width,
				_icon_height,
				c_white,
				1
			);
		}
		else
		{
			draw_set_color(COLOR_HUD_TEXT);
			draw_rectangle(
				_icon_center_x - (worker_indicator_icon_size * 0.3),
				_icon_center_y - (worker_indicator_icon_size * 0.3),
				_icon_center_x + (worker_indicator_icon_size * 0.3),
				_icon_center_y + (worker_indicator_icon_size * 0.3),
				false
			);
		}
	}
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

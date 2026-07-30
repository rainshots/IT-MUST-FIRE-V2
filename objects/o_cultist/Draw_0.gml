// Draw the regular cultist with the numeric HP presentation from the world-event design.
draw_self();

var _jobs_ui = instance_exists(o_jobs_ui)
	? instance_find(o_jobs_ui, 0)
	: noone;
var _hp_line_height = 9;
var _hp_text_y = bbox_bottom;

if (instance_exists(_jobs_ui) && font_exists(_jobs_ui.jobs_hp_font))
{
	draw_set_font(_jobs_ui.jobs_hp_font);
}

draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
draw_text(x, bbox_top, cultist_name);

draw_set_valign(fa_top);
draw_set_color(COLOR_JOBS_ASSIGN_TEXT);
draw_text(x, _hp_text_y, string(ceil(hp)) + "hp");

// Assigned workers preview the same HP change shown in the Jobs window.
if (is_struct(assigned_event) && instance_exists(_jobs_ui))
{
	var _slot_index = _jobs_ui.jobs_event_cultist_slot_index_get(assigned_event, id);

	if (_slot_index >= 0)
	{
		var _hp_preview = _jobs_ui.jobs_event_cultist_hp_preview_get(
			assigned_event,
			_slot_index,
			id
		);

		if (_hp_preview.hp_change != 0)
		{
			var _change_prefix = _hp_preview.hp_change > 0 ? "+" : "";
			var _change_color = _hp_preview.hp_change > 0
				? COLOR_JOBS_EVENT_ACTIVE
				: COLOR_STATUS_NEGATIVE_RED;

			draw_set_color(_change_color);
			draw_text(
				x,
				_hp_text_y + _hp_line_height,
				_change_prefix + string(round(_hp_preview.hp_change)) + "hp"
			);
		}

		if (_hp_preview.dies && sprite_exists(s_ui_scull_white))
		{
			var _skull_size = BALANCE_WORLD_EVENT_SLOT_WIDTH * 0.7;
			var _skull_scale = _skull_size / max(1, sprite_get_width(s_ui_scull_white));
			var _skull_y = (bbox_top + bbox_bottom) * 0.5;

			draw_sprite_ext(
				s_ui_scull_white,
				0,
				x,
				_skull_y,
				_skull_scale,
				_skull_scale,
				0,
				COLOR_STATUS_NEGATIVE_RED,
				1
			);
		}
	}
}

if (variable_global_exists("ui_font") && font_exists(global.ui_font))
{
	draw_set_font(global.ui_font);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

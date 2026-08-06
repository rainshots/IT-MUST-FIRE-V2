// Unconscious Cultists are drawn lying on their side in every world state.
var _cultist_angle = is_unconscious ? 90 : 0;
draw_sprite_ext(
	sprite_index,
	image_index,
	x,
	y,
	image_xscale,
	image_yscale,
	_cultist_angle,
	image_blend,
	image_alpha
);

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

		if (_hp_preview.loses_consciousness)
		{
			var _knockout_y = (bbox_top + bbox_bottom) * 0.5;
			draw_set_valign(fa_middle);
			draw_set_color(COLOR_STATUS_NEGATIVE_RED);
			draw_text(x, _knockout_y, "KO");
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

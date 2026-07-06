if (artifact_is_dragged)
{
	draw_set_alpha(0.28);
	draw_set_color(c_black);
	draw_ellipse(
		x - (artifact_shadow_width * 0.5),
		y + (artifact_shadow_height * 0.35),
		x + (artifact_shadow_width * 0.5),
		y + artifact_shadow_height,
		false
	);
	draw_set_alpha(1);
}

draw_self();

if (artifact_is_dragged && instance_exists(artifact_target_cultist))
{
	var _stat_color = artifact_stat_color_get();
	var _label_text = "+1 " + artifact_stat_name_get();
	var _label_x = artifact_target_cultist.x;
	var _label_y = artifact_target_cultist.bbox_top - artifact_hover_label_offset_y;
	var _label_width = string_width(_label_text) + (artifact_hover_label_padding_x * 2);
	var _label_height = string_height(_label_text) + (artifact_hover_label_padding_y * 2);

	draw_set_alpha(artifact_highlight_alpha);
	draw_set_color(_stat_color);
	draw_rectangle(
		artifact_target_cultist.bbox_left - artifact_highlight_padding,
		artifact_target_cultist.bbox_top - artifact_highlight_padding,
		artifact_target_cultist.bbox_right + artifact_highlight_padding,
		artifact_target_cultist.bbox_bottom + artifact_highlight_padding,
		true
	);

	draw_set_alpha(0.86);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_roundrect(
		_label_x - (_label_width * 0.5),
		_label_y - (_label_height * 0.5),
		_label_x + (_label_width * 0.5),
		_label_y + (_label_height * 0.5),
		false
	);

	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(_stat_color);
	draw_text(_label_x, _label_y, _label_text);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

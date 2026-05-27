// Draw day cultist sprite.
draw_self();

// Draw the assigned name or an unnamed placeholder above the cultist.
var _name_text = cultist_name;

if (_name_text == "")
{
	_name_text = "Unnamed";
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(COLOR_HUD_TEXT);
draw_text(x, y - name_offset_y, _name_text);

// Draw a small possession marker once a demon is selected.
if (demon_type != DEMON_TYPE.NONE)
{
	var _bar_x = x - (bar_width * 0.5);
	var _bar_y = y + bar_offset_y;

	draw_set_alpha(0.75);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_bar_x, _bar_y, _bar_x + bar_width, _bar_y + bar_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_CULTIST_FERVOR);
	draw_rectangle(_bar_x, _bar_y, _bar_x + bar_width, _bar_y + bar_height, false);
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);


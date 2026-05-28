// Draw the landing shadow while the player is carrying this cultist.
if (is_being_dragged)
{
	draw_set_alpha(0.35);
	draw_set_color(c_black);
	draw_ellipse(
		drag_drop_x - (global.cultist_drag_shadow_width * 0.5),
		drag_drop_y - (global.cultist_drag_shadow_height * 0.5),
		drag_drop_x + (global.cultist_drag_shadow_width * 0.5),
		drag_drop_y + (global.cultist_drag_shadow_height * 0.5),
		false
	);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

// Draw day cultist sprite.
draw_self();

// Draw the assigned name or an unnamed placeholder below the cultist.
var _name_text = cultist_name;

if (_name_text == "")
{
	_name_text = "Unnamed";
}

if (variable_global_exists("ui_font") && font_exists(global.ui_font))
{
	draw_set_font(global.ui_font);
}

// Color the name by the cultist's strongest attribute.
var _name_color = COLOR_CULTIST_BODY;
var _body_points = cultist_points[CULTIST_STAT.BODY];
var _spirit_points = cultist_points[CULTIST_STAT.SPIRIT];
var _fervor_points = cultist_points[CULTIST_STAT.FERVOR];

if (_spirit_points > _body_points && _spirit_points >= _fervor_points)
{
	_name_color = COLOR_CULTIST_SPIRIT;
}
else if (_fervor_points > _body_points && _fervor_points > _spirit_points)
{
	_name_color = COLOR_CULTIST_FERVOR;
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(_name_color);
draw_text(x, y + name_offset_y, _name_text);

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

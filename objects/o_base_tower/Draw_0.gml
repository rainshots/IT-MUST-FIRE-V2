// The copied tower has no ability visuals or interactive controls.
draw_self();
draw_set_alpha(1);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(COLOR_HUD_TEXT);
draw_text_transformed(x, bbox_top, "Base Tower\n" + string(ceil(hp)) + " / " + string(ceil(max_hp)) + " HP", 0.5, 0.5, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

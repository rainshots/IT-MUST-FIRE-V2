event_inherited();
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(COLOR_HUD_TEXT);
draw_text_transformed(x, bbox_top, "Forge\n" + string(array_length(worker_cultists)) + "/1 workers - 1 ball / " + string(BALANCE_FORGE_SECONDS) + "s", 0.5, 0.5, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

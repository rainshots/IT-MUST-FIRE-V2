// Keep the work purpose and the available slot visible above the Furnace.
event_inherited();
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_alpha(1);
draw_set_color(COLOR_HUD_TEXT);
draw_text_transformed(x, bbox_top, "Furnace\n" + string(array_length(worker_cultists))
	+ "/" + string(worker_max) + " workers - +1% charge / " + string(BALANCE_FURNACE_CHARGE_SECONDS) + "s", 0.5, 0.5, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

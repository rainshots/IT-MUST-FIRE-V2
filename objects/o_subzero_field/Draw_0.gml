// A pale blue circle marks the persistent slowing and damage zone.
draw_set_color(COLOR_SUBZERO_FIELD);
draw_set_alpha(BALANCE_SUBZERO_FIELD_FILL_ALPHA);
draw_circle(x, y, effect_radius, false);
draw_set_alpha(BALANCE_SUBZERO_FIELD_OUTLINE_ALPHA);
draw_circle(x, y, effect_radius, true);
draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
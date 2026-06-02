// Draw Hex Totem curse radius beneath the sprite.
draw_set_color(COLOR_WARLOCK_HEX_TOTEM);
draw_set_alpha(BALANCE_WARLOCK_HEX_TOTEM_CIRCLE_ALPHA);
draw_circle(x, y, effect_radius, false);
draw_set_alpha(BALANCE_WARLOCK_HEX_TOTEM_CIRCLE_OUTLINE_ALPHA);
draw_circle(x, y, effect_radius, true);

draw_set_color(c_white);
draw_set_alpha(1);

draw_self();

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

// Preview the blast area while the bomb waits on the ground.
draw_set_color(COLOR_BOMB_SHOT_FUSE);
draw_set_alpha(zone_alpha);
draw_circle(x, y, effect_radius, true);
draw_set_alpha(1);

// A round bomb and shrinking fuse show how much time remains before detonation.
var _fuse_fraction = fuse_duration > 0 ? clamp(fuse_timer / fuse_duration, 0, 1) : 0;
var _fuse_tip_x = x + (body_radius * _fuse_fraction);
var _fuse_tip_y = y - body_radius - (body_radius * _fuse_fraction);
draw_set_color(COLOR_BOMB_SHOT_BODY);
draw_circle(x, y, body_radius, false);
draw_set_color(COLOR_BOMB_SHOT_FUSE);
draw_circle(x, y, body_radius, true);
draw_line(x, y - body_radius, _fuse_tip_x, _fuse_tip_y);
draw_circle(_fuse_tip_x, _fuse_tip_y, spark_radius, false);

// Restore the project's default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
// Draw inherited map object visuals.
event_inherited();

// Show the Sweet Rot attraction radius while hovered.
map_object_range_draw(attraction_radius, COLOR_TAINT_SPREADER_RADIUS);

draw_set_color(c_white);
draw_set_alpha(1);

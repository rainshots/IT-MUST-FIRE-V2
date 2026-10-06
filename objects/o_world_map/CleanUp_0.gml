// A duplicate created when returning to the map exits before allocating its fonts.
if (variable_instance_exists(id, "map_font") && font_exists(map_font)) font_delete(map_font);
if (variable_instance_exists(id, "map_heading_font") && font_exists(map_heading_font)) font_delete(map_heading_font);
if (variable_instance_exists(id, "map_card_font") && font_exists(map_card_font)) font_delete(map_card_font);
if (variable_instance_exists(id, "panel_content_surface") && surface_exists(panel_content_surface)) surface_free(panel_content_surface);

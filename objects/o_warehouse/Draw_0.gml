draw_set_alpha(1);
draw_set_color(COLOR_BUILDING_ZONE);
draw_rectangle(x-100,y-100,x+100,y+100,true);
draw_line(x,y-100,x,y+100);draw_line(x-100,y,x+100,y);
draw_set_color(COLOR_HUD_TEXT);draw_set_halign(fa_center);draw_set_valign(fa_bottom);
draw_text_transformed(x,y-105,"Warehouse",0.5,0.5,0);
draw_set_halign(fa_left);draw_set_valign(fa_top);draw_set_color(c_white);

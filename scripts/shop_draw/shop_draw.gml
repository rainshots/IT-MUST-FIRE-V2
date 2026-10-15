/// @description Draws persistent building offers, paid Refresh, Mana and unit capacity.
function shop_draw()
{
	if(fight_state==FIGHT_STATE.LOST || fight_state==FIGHT_STATE.WON) return;
	if(font_exists(global.ui_font)) draw_set_font(global.ui_font);
	var _first=shop_offer_rect(-1);
	draw_set_alpha(1);draw_set_color(COLOR_HUD_TEXT);draw_set_halign(fa_left);draw_set_valign(fa_bottom);
	draw_text_transformed(_first.x,_first.y-10*_first.scale,"Mana: "+string(floor(global.faction_mana[global.player_faction]))+"   Units: "+string(player_unit_count_get())+" / "+string(player_unit_cap),0.7*_first.scale,0.7*_first.scale,0);
	draw_set_halign(fa_center);draw_set_valign(fa_middle);
	for(var _i=-1;_i<array_length(shop_options);++_i)
	{
		var _r=shop_offer_rect(_i);
		var _name=_i<0 ? "Refresh" : shop_options[_i].name;
		var _cost=_i<0 ? BALANCE_SHOP_REFRESH_COST : shop_options[_i].cost;
		var _available=!instance_exists(shop_preview) && fight_state==FIGHT_STATE.ACTIVE && global.faction_mana[global.player_faction]>=_cost;
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_r.x,_r.y,_r.x+_r.width,_r.y+_r.height,false);
		// Center the sprite independently of its origin, behind the offer text.
		var _icon = _i < 0 ? -1 : shop_options[_i].icon;
		if (sprite_exists(_icon))
		{
			var _icon_width = sprite_get_width(_icon);
			var _icon_height = sprite_get_height(_icon);
			var _icon_scale = min(_r.width / _icon_width, _r.height / _icon_height) * BALANCE_SHOP_ICON_SIZE_RATIO;
			var _icon_x = _r.x + _r.width * 0.5 + (sprite_get_xoffset(_icon) - _icon_width * 0.5) * _icon_scale;
			var _icon_y = _r.y + _r.height * 0.5 + (sprite_get_yoffset(_icon) - _icon_height * 0.5) * _icon_scale;
			draw_sprite_ext(_icon, 0, _icon_x, _icon_y, _icon_scale, _icon_scale, 0, c_white, BALANCE_SHOP_ICON_ALPHA);
		}
		draw_set_color(_available ? COLOR_HUD_TEXT : COLOR_STATUS_NEGATIVE_RED);
		draw_rectangle(_r.x,_r.y,_r.x+_r.width,_r.y+_r.height,true);
		draw_text_transformed(_r.x+_r.width*0.5,_r.y+_r.height*0.35,_name,0.7*_r.scale,0.7*_r.scale,0);
		draw_text_transformed(_r.x+_r.width*0.5,_r.y+_r.height*0.7,string(_cost)+" Mana",0.65*_r.scale,0.65*_r.scale,0);
	}
	if(instance_exists(shop_preview))
	{
		draw_set_color(COLOR_HUD_TEXT);
		draw_text_transformed(display_get_gui_width()*0.5,_first.y-50*_first.scale,(shop_preview.is_defense_building ? "Place in Defense Zone or merge. Esc / RMB cancels." : "Place in Building Zone or merge. Esc / RMB cancels."),0.65*_first.scale,0.65*_first.scale,0);
	}
	draw_set_halign(fa_left);draw_set_valign(fa_top);draw_set_color(c_white);draw_set_alpha(1);
}

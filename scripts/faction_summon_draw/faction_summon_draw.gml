/// @description Draws unit portraits, purchase costs, shortcuts and the destination prompt; controller context.
function faction_summon_draw()
{
	if (!faction_match_started || faction_match_finished || global.player_faction == FACTION.NONE
		|| (global.focus_window != FOCUS_WINDOW.NOONE && global.focus_window != FOCUS_WINDOW.SUMMON)) return;
	var _choices = faction_summon_options[global.player_faction];
	var _count = faction_squad_count_get(global.player_faction);
	if (font_exists(global.ui_font)) draw_set_font(global.ui_font);
	for (var _index = 0; _index < array_length(_choices); ++_index)
	{
		var _choice = _choices[_index];
		var _rect = faction_summon_rect_get(_index);
		var _available = faction_summon_can_purchase(global.player_faction, _index);
		var _selected = faction_summon_selected == _index;
		var _center = _rect.x + _rect.width * 0.5;
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_set_alpha(0.95);
		draw_rectangle(_rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height, false);
		draw_set_alpha(1);
		draw_set_color(_selected ? COLOR_SQUAD_ORDER_ATTACK : COLOR_HUD_TEXT);
		draw_rectangle(_rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height, true);
		var _sprite = object_get_sprite(_choice.unit_object);
		if (sprite_exists(_sprite))
		{
			var _size = 55 * _rect.scale / max(sprite_get_width(_sprite), sprite_get_height(_sprite));
			var _sx = _center - sprite_get_width(_sprite) * _size * 0.5 + sprite_get_xoffset(_sprite) * _size;
			var _sy = _rect.y + 8 * _rect.scale + sprite_get_yoffset(_sprite) * _size;
			draw_sprite_ext(_sprite, 0, _sx, _sy, _size, _size, 0, c_white, _available ? 1 : 0.4);
		}
		draw_set_halign(fa_center);
		draw_set_valign(fa_top);
		draw_set_color(COLOR_HUD_TEXT);
		draw_set_alpha(_available || _selected ? 1 : 0.5);
		draw_text_transformed(_center, _rect.y + 64 * _rect.scale, _choice.name + " x" + string(_choice.count), 0.65 * _rect.scale, 0.65 * _rect.scale, 0);
		draw_text_transformed(_center, _rect.y + 86 * _rect.scale, string(_choice.cost) + " Mana", 0.8 * _rect.scale, 0.8 * _rect.scale, 0);
		draw_set_halign(fa_left);
		draw_text_transformed(_rect.x + 7 * _rect.scale, _rect.y + 5 * _rect.scale, string(_index + 1), 0.8 * _rect.scale, 0.8 * _rect.scale, 0);
	}
	var _rect = faction_summon_rect_get(0);
	var _text = "Squads: " + string(_count) + " / " + string(BALANCE_SQUAD_LIMIT);
	if (faction_summon_selected >= 0) _text = "Select destination - LMB confirm, RMB / Esc cancel";
	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_TEXT);
	draw_set_halign(fa_center);
	draw_text_transformed(display_get_gui_width() * 0.5, _rect.y - 28 * _rect.scale, _text, 0.75 * _rect.scale, 0.75 * _rect.scale, 0);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}

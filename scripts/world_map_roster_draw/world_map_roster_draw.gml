/// @description Reuses the legacy roster's portraits, palette, labels, and health bars along the bottom of the map.
function world_map_roster_draw(_map)
{
	var _cards = _map.roster_cards;
	var _count = array_length(_cards);
	draw_set_font(_map.map_card_font);
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	for (var _index = 0; _index < BALANCE_BATTLE_ROSTER_LIMIT; ++_index)
	{
		var _x = _map.card_x + _index * (_map.card_width + _map.card_gap);
		var _y = _map.card_y;
		var _center_x = _x + _map.card_width * 0.5;
		var _squad = _index < _count ? _cards[_index] : noone;
		var _highlighted = is_struct(_squad) && (_squad == _map.hovered_squad || _squad == _map.pinned_squad);
		draw_set_color(COLOR_SQUAD_CARD_BACKGROUND);
		draw_rectangle(_x, _y, _x + _map.card_width, _y + _map.card_height, false);
		draw_set_color(_highlighted ? COLOR_CULTIST_COUNTER_TEXT : COLOR_SQUAD_CARD_BORDER);
		draw_rectangle(_x, _y, _x + _map.card_width, _y + _map.card_height, true);
		if (!is_struct(_squad))
		{
			draw_set_color(COLOR_SQUAD_CARD_TEXT);
			draw_text(_center_x, _y + 109, "Empty");
			continue;
		}

		// Use exactly the old three-unit portrait composition for multi-member squads.
		var _type_name = _squad.squad_type == SQUAD_TYPE.ARCHDEMON ? "ARCHDEMON"
			: (_squad.squad_type == SQUAD_TYPE.UNDEAD ? "UNDEAD SQUAD" : "DEMON SQUAD");
		draw_set_color(COLOR_SQUAD_CARD_TYPE);
		draw_text_transformed(_center_x, _y - 20, _type_name, 0.75, 0.75, 0);
		var _sprite = object_get_sprite(_squad.primary_unit_object);
		if (sprite_exists(_sprite))
		{
			var _sprite_scale = 82 / max(1, max(sprite_get_width(_sprite), sprite_get_height(_sprite)));
			var _sprite_y = _y + 78;
			if (array_length(_squad.unit_objects) > 1)
			{
				draw_sprite_ext(_sprite, 0, _center_x - 24, _sprite_y + 8, _sprite_scale * 0.78, _sprite_scale * 0.78, 0, c_white, 0.5);
				draw_sprite_ext(_sprite, 0, _center_x + 24, _sprite_y + 8, _sprite_scale * 0.78, _sprite_scale * 0.78, 0, c_white, 0.5);
			}
			draw_sprite_ext(_sprite, 0, _center_x, _sprite_y, _sprite_scale, _sprite_scale, 0, c_white, 1);
		}
		draw_set_color(COLOR_SQUAD_CARD_TEXT);
		var _label = squad_name_display_get(_squad.name);
		var _label_scale = min(1, (_map.card_width - 8) / max(1, string_width(_label)));
		draw_text_transformed(_center_x, _y + 109, _label, _label_scale, _label_scale, 0);

		// Campaign squads restore their full composition at the next preparation phase.
		var _hp_x = _x + 8;
		var _hp_y = _y + 128;
		var _hp_width = _map.card_width - 16;
		draw_set_color(COLOR_SQUAD_HP_BACKGROUND);
		draw_rectangle(_hp_x, _hp_y, _hp_x + _hp_width, _hp_y + 13, false);
		draw_set_color(COLOR_SQUAD_HP_FILL);
		draw_rectangle(_hp_x + 3, _hp_y + 3, _hp_x + _hp_width - 3, _hp_y + 10, false);
		var _damage = variable_struct_exists(_squad, "damage_dealt_total") ? _squad.damage_dealt_total : 0;
		var _damage_text = "Damage: " + string_format(_damage, 0, 1);
		var _damage_scale = min(1, (_map.card_width - 6) / max(1, string_width(_damage_text)));
		draw_set_color(COLOR_SQUAD_CARD_TEXT);
		draw_text_transformed(_center_x, _y + _map.card_height + 6, _damage_text, _damage_scale, _damage_scale, 0);
	}
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}

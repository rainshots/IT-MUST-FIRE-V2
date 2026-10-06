/// @description Draws the pinned/hovered level or squad, including scrollable contents and nested tooltips.
function world_map_info_draw(_map)
{
	var _level = _map.info_level;
	var _squad = _map.info_squad;
	if (!instance_exists(_level) && !is_struct(_squad)) return;
	var _content_x = _map.panel_x + _map.panel_padding;
	var _content_width = _map.panel_width - _map.panel_padding * 2;
	var _content_height = _map.panel_content_bottom - _map.panel_content_y;
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _mouse_x = _mouse_gui_x - _content_x;
	var _mouse_y = _mouse_gui_y - _map.panel_content_y;
	var _inside_content = point_in_rectangle(_mouse_x, _mouse_y, 0, 0, _content_width, _content_height);
	var _tooltip_title = "";
	var _tooltip_description = "";
	var _line_height = 27;
	var _section_gap = 30;
	var _icon_step = _map.icon_size + _map.icon_gap;
	var _pinned = instance_exists(_level) ? _level == _map.pinned_level : _squad == _map.pinned_squad;

	// The panel and attack button keep the reference's simple flat treatment.
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(1);
	draw_set_color(COLOR_WORLD_MAP_PANEL);
	draw_rectangle(_map.panel_x, _map.panel_y, _map.panel_x + _map.panel_width,
		_map.panel_y + _map.panel_height, false);
	draw_set_font(_map.map_heading_font);
	draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
	draw_text(_content_x + 8, _map.panel_y + 42, "Info");
	draw_set_font(_map.map_card_font);
	draw_set_halign(fa_right);
	draw_set_color(COLOR_SQUAD_CARD_TYPE);
	draw_text(_map.panel_x + _map.panel_width - _map.panel_padding, _map.panel_y + 64,
		_pinned ? "PINNED" : "LMB: PIN");
	draw_set_halign(fa_left);

	// Recreate the clipping surface after a graphics reset; never allocate one per frame.
	if (!surface_exists(_map.panel_content_surface))
	{
		_map.panel_content_surface = surface_create(_content_width, _content_height);
	}
	if (!surface_exists(_map.panel_content_surface)) return;
	surface_set_target(_map.panel_content_surface);
	draw_clear_alpha(COLOR_WORLD_MAP_PANEL, 1);
	draw_set_font(_map.map_font);
	var _y = -_map.info_scroll;

	if (instance_exists(_level))
	{
		// Keep the original level panel while describing the conquest rules used by ATTACK.
		draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
		draw_text_ext(0, _y, _level.level_title, _line_height, _content_width);
		_y += string_height_ext(_level.level_title, _line_height, _content_width) + 14;
		var _state_text = "";
		switch (_level.level_state)
		{
			case WORLD_MAP_LEVEL_STATE.AVAILABLE: _state_text = "Available to attack"; break;
			case WORLD_MAP_LEVEL_STATE.FUTURE: _state_text = "Further along the route"; break;
			case WORLD_MAP_LEVEL_STATE.BEHIND: _state_text = "This route has been left behind"; break;
			case WORLD_MAP_LEVEL_STATE.CAPTURED: _state_text = "Captured"; break;
		}
		draw_set_color(COLOR_SQUAD_CARD_TYPE);
		draw_text_ext(0, _y, _state_text, _line_height, _content_width);
		_y += string_height_ext(_state_text, _line_height, _content_width) + _section_gap;
		draw_set_color(COLOR_HUD_TEXT);
		draw_text_ext(0, _y, _level.level_description, _line_height, _content_width);
		_y += string_height_ext(_level.level_description, _line_height, _content_width) + _section_gap;
		draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
		draw_text(0, _y, "Conquest");
		_y += _line_height + 12;
		draw_set_color(COLOR_HUD_TEXT);
		var _rules = "Take the enemy's buildings and defeat its remaining troops.\n\nSettlements recruit troops. Towers fire on passing enemies. Forges strengthen your whole army.\n\nDrag from your building to a target. Upgrade with U. Choose how many troops to send with 1-4.";
		draw_text_ext(0, _y, _rules, _line_height, _content_width);
		_y += string_height_ext(_rules, _line_height, _content_width) + _section_gap;
		if (_level.reward != "")
		{
			draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
			draw_text(0, _y, "Reward");
			_y += _line_height + 12;
			draw_set_color(COLOR_HUD_TEXT);
			draw_text_ext(0, _y, _level.reward, _line_height, _content_width);
			_y += string_height_ext(_level.reward, _line_height, _content_width);
		}
	}
	else
	{
		// A squad keeps the same members, Unholy Trait, and two Relic slots as the legacy panel.
		draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
		draw_text_ext(0, _y, squad_name_display_get(_squad.name), _line_height, _content_width);
		_y += string_height_ext(squad_name_display_get(_squad.name), _line_height, _content_width) + _section_gap;
		var _trait = squad_unholy_trait_get(_squad);
		var _trait_text = "Unholy Trait: " + squad_unholy_trait_name_get(_trait);
		var _trait_height = string_height_ext(_trait_text, _line_height, _content_width);
		draw_set_color(_trait == UNHOLY_TRAIT.NONE ? COLOR_SQUAD_CARD_TYPE : COLOR_PROJECTILE_SUMMON);
		draw_text_ext(0, _y, _trait_text, _line_height, _content_width);
		if (_trait != UNHOLY_TRAIT.NONE && _inside_content
			&& point_in_rectangle(_mouse_x, _mouse_y, 0, _y, _content_width, _y + _trait_height))
		{
			_tooltip_title = squad_unholy_trait_name_get(_trait);
			_tooltip_description = squad_unholy_trait_description_get(_trait);
		}
		_y += _trait_height + _section_gap;
		draw_set_color(COLOR_SQUAD_CARD_TYPE);
		draw_text(0, _y + 16, "Relics:");
		var _relic_size = 56;
		var _relic_start_x = 100;
		for (var _slot_index = 0; _slot_index < BALANCE_SQUAD_RELIC_SLOT_COUNT; ++_slot_index)
		{
			var _relic = squad_relic_slot_get(_squad, _slot_index);
			var _relic_x = _relic_start_x + _slot_index * (_relic_size + 18);
			var _relic_center_x = _relic_x + _relic_size * 0.5;
			var _relic_center_y = _y + _relic_size * 0.5;
			var _relic_hovered = _inside_content && point_in_rectangle(_mouse_x, _mouse_y,
				_relic_x, _y, _relic_x + _relic_size, _y + _relic_size);
			draw_set_color(COLOR_SQUAD_CARD_BACKGROUND);
			draw_circle(_relic_center_x, _relic_center_y, _relic_size * 0.5, false);
			draw_set_color(_relic_hovered ? COLOR_PROJECTILE_SUMMON : COLOR_SQUAD_CARD_BORDER);
			draw_circle(_relic_center_x, _relic_center_y, _relic_size * 0.5, true);
			world_map_sprite_fit_draw(squad_relic_sprite_get(_relic), _relic_center_x, _relic_center_y,
				_relic_size * 0.72, _relic_size * 0.72);
			if (_relic_hovered)
			{
				_tooltip_title = _relic == RELIC.NONE ? "Empty Relic slot" : squad_relic_name_get(_relic);
				_tooltip_description = _relic == RELIC.NONE ? "" : squad_relic_description_get(_relic);
			}
		}
		_y += _relic_size + _section_gap;
		var _unit_count = array_length(_squad.unit_objects);
		draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
		draw_text(0, _y, "Units: " + string(_unit_count));
		_y += _line_height + 12;
		for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
		{
			var _object = _squad.unit_objects[_unit_index];
			var _icon_x = (_unit_index mod _map.icon_columns) * _icon_step;
			var _icon_y = _y + floor(_unit_index / _map.icon_columns) * _icon_step;
			var _hovered = _inside_content && point_in_rectangle(_mouse_x, _mouse_y,
				_icon_x, _icon_y, _icon_x + _map.icon_size, _icon_y + _map.icon_size);
			draw_set_color(COLOR_SQUAD_CARD_BACKGROUND);
			draw_rectangle(_icon_x, _icon_y, _icon_x + _map.icon_size, _icon_y + _map.icon_size, false);
			draw_set_color(_hovered ? COLOR_PROJECTILE_SUMMON : COLOR_SQUAD_CARD_BORDER);
			draw_rectangle(_icon_x, _icon_y, _icon_x + _map.icon_size, _icon_y + _map.icon_size, true);
			world_map_sprite_fit_draw(object_get_sprite(_object), _icon_x + _map.icon_size * 0.5,
				_icon_y + _map.icon_size * 0.5, _map.icon_size - 8, _map.icon_size - 8);
			if (_hovered)
			{
				_tooltip_title = world_map_object_name_get(_object);
				_tooltip_description = world_map_unit_stats_text_get(_object);
			}
		}
		_y += ceil(_unit_count / _map.icon_columns) * _icon_step + _section_gap;
		draw_set_color(COLOR_HUD_TEXT);
		var _damage = variable_struct_exists(_squad, "damage_dealt_total") ? _squad.damage_dealt_total : 0;
		draw_text(0, _y, "Total damage: " + string_format(_damage, 0, 1));
		_y += _line_height + _section_gap;
		draw_set_color(COLOR_SQUAD_CARD_TYPE);
		var _hint = _pinned ? "Hover a unit, Unholy Trait or Relic to inspect it."
			: "Click the squad card to pin its information.";
		draw_text_ext(0, _y, _hint, _line_height, _content_width);
		_y += string_height_ext(_hint, _line_height, _content_width);
	}

	// Only the information contents scroll; the heading and ATTACK button stay fixed.
	_map.info_scroll_max = max(0, _y + _map.info_scroll + 16 - _content_height);
	surface_reset_target();
	draw_set_color(c_white);
	draw_surface(_map.panel_content_surface, _content_x, _map.panel_content_y);
	if (_map.info_scroll_max > 0)
	{
		var _track_x = _map.panel_x + _map.panel_width - 12;
		var _thumb_height = max(24, _content_height * _content_height / (_content_height + _map.info_scroll_max));
		var _thumb_y = _map.panel_content_y + (_content_height - _thumb_height) * _map.info_scroll / _map.info_scroll_max;
		draw_set_color(COLOR_SQUAD_CARD_BORDER);
		draw_rectangle(_track_x, _thumb_y, _track_x + 3, _thumb_y + _thumb_height, false);
	}
	if (instance_exists(_level) && _level.level_state == WORLD_MAP_LEVEL_STATE.AVAILABLE)
	{
		draw_set_color(_map.attack_is_hovered ? COLOR_WORLD_MAP_ATTACK_HOVER : COLOR_WORLD_MAP_ATTACK);
		draw_rectangle(_map.attack_x, _map.attack_y, _map.attack_x + _map.attack_width,
			_map.attack_y + _map.attack_height, false);
		draw_set_color(COLOR_WORLD_MAP_ATTACK_BORDER);
		draw_rectangle(_map.attack_x, _map.attack_y, _map.attack_x + _map.attack_width,
			_map.attack_y + _map.attack_height, true);
		draw_set_font(_map.map_heading_font);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
		draw_text_transformed(_map.attack_x + _map.attack_width * 0.5,
			_map.attack_y + _map.attack_height * 0.5, "ATTACK!", 0.75, 0.75, 0);
	}
	if (_tooltip_title != "") world_map_tooltip_draw(_map, _tooltip_title, _tooltip_description, _mouse_gui_x, _mouse_gui_y);
	draw_set_font(_map.map_font);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}

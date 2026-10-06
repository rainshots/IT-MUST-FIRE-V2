/// @description Draws an existing building sprite, faction flag, level and live garrison.
function conquest_building_draw(_controller, _index)
{
	if (!instance_exists(_controller)) return;
	var _node = _controller.nodes[_index];
	var _selected = array_contains(_controller.selected_nodes, _index) && _node.owner == CONQUEST_OWNER.PLAYER;
	var _hovered = _controller.hovered_node == _index;
	var _color = conquest_owner_color_get(_node.owner);
	var _sprite = _node.owner == CONQUEST_OWNER.PLAYER ? s_cursed_town : s_town;
	if (_node.kind == CONQUEST_BUILDING.TOWER) _sprite = _node.owner == CONQUEST_OWNER.PLAYER ? s_damage_tower : s_holy_tower;
	if (_node.kind == CONQUEST_BUILDING.FORGE) _sprite = s_workshop;

	// Ownership is visible in both the ground ring and the small cloth pennant.
	draw_set_alpha(0.35);
	draw_set_color(COLOR_CONQUEST_SHADOW);
	draw_ellipse(_node.x - 78, _node.y - 24, _node.x + 78, _node.y + 23, false);
	draw_set_alpha(1);
	draw_set_color(_selected || _hovered ? COLOR_CULTIST_COUNTER_TEXT : _color);
	draw_ellipse(_node.x - 76, _node.y - 23, _node.x + 76, _node.y + 22, true);
	if (_selected) draw_ellipse(_node.x - 80, _node.y - 26, _node.x + 80, _node.y + 25, true);
	conquest_sprite_draw(_sprite, _node.x, _node.y + 5, 145, 140);
	var _flag_x = _node.x + 68;
	var _flag_y = _node.y - 70;
	draw_set_color(COLOR_SQUAD_CARD_TYPE);
	draw_line_width(_flag_x, _flag_y, _flag_x, _node.y + 3, 3);
	draw_set_color(_color);
	draw_triangle(_flag_x, _flag_y, _flag_x + 32, _flag_y + 10, _flag_x, _flag_y + 23, false);

	// Counter plates use the same square frames and parchment text as the campaign cards.
	draw_set_color(COLOR_WORLD_MAP_PANEL);
	draw_rectangle(_node.x - 45, _node.y + 15, _node.x + 45, _node.y + 51, false);
	draw_set_color(_selected ? COLOR_CULTIST_COUNTER_TEXT : _color);
	draw_rectangle(_node.x - 45, _node.y + 15, _node.x + 45, _node.y + 51, true);
	draw_set_font(_controller.number_font);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
	draw_text(_node.x, _node.y + 33, string(floor(_node.garrison)));
	var _level_marks = ["I", "II", "III"];
	draw_set_font(_controller.ui_font);
	draw_set_color(_color);
	draw_text(_node.x, _node.y + 66, _level_marks[_node.level - 1]);
	if (_node.upgrade_remaining > 0)
	{
		var _progress = 1 - _node.upgrade_remaining / BALANCE_CONQUEST_UPGRADE_SECONDS;
		draw_set_color(COLOR_SQUAD_HP_BACKGROUND);
		draw_rectangle(_node.x - 44, _node.y + 51, _node.x + 44, _node.y + 56, false);
		draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
		draw_rectangle(_node.x - 44, _node.y + 51, _node.x - 44 + 88 * _progress, _node.y + 56, false);
	}
	if (_node.capture_flash > 0)
	{
		draw_set_alpha(_node.capture_flash);
		draw_set_color(_color);
		var _radius = 85 + (1 - _node.capture_flash) * 40;
		draw_ellipse(_node.x - _radius, _node.y - _radius * 0.4, _node.x + _radius, _node.y + _radius * 0.4, true);
	}
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}

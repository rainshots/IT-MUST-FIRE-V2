/// @description Draws compact battle controls using the campaign's fonts, colors and square frames.
function conquest_hud_draw(_controller)
{
	if (!instance_exists(_controller)) return;
	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(COLOR_WORLD_MAP_PANEL);
	draw_rectangle(0, 0, 1920, 84, false);
	draw_rectangle(0, _controller.field_bottom, 1920, 1080, false);
	draw_set_color(COLOR_SQUAD_CARD_BORDER);
	draw_line(0, 84, 1920, 84);
	draw_line(0, _controller.field_bottom, 1920, _controller.field_bottom);
	draw_set_font(_controller.heading_font);
	draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
	draw_text(35, 24, _controller.level_title);
	draw_set_font(_controller.ui_font);
	draw_set_color(COLOR_SQUAD_CARD_TYPE);
	draw_text(520, 31, _controller.tactical_mode ? "ROAD WARFARE   /   Cut their reinforcements" : "CONQUEST   /   Break the enemy's last foothold");

	// Totals include troops in transit, so a last incoming enemy cannot cause a false victory.
	var _troops = [0, 0, 0];
	var _buildings = [0, 0, 0];
	var _node_count = array_length(_controller.nodes);
	for (var _index = 0; _index < _node_count; ++_index)
	{
		var _node = _controller.nodes[_index];
		_troops[_node.owner] += _node.garrison;
		_buildings[_node.owner]++;
	}
	var _army_count = array_length(_controller.armies);
	for (var _index = 0; _index < _army_count; ++_index)
	{
		var _army = _controller.armies[_index];
		_troops[_army.owner] += _army.count;
	}
	draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
	draw_text(1130, 19, "YOUR CULT   " + string(floor(_troops[CONQUEST_OWNER.PLAYER])) + " troops");
	draw_set_color(COLOR_CONQUEST_ENEMY);
	draw_text(1130, 47, "DEFENDERS   " + string(floor(_troops[CONQUEST_OWNER.ENEMY])) + " troops");
	draw_set_color(COLOR_SQUAD_CARD_TYPE);
	var _seconds_text = string(floor(_controller.elapsed_seconds) mod 60);
	if (string_length(_seconds_text) < 2) _seconds_text = "0" + _seconds_text;
	draw_text(1470, 31, string(floor(_controller.elapsed_seconds / 60)) + ":" + _seconds_text);
	conquest_button_draw(_controller, 1710, 19, 175, 47, "PAUSE  [SPACE]");
	if (_controller.tactical_mode)
	{
		// Keep the objective above scenery rather than drawing text underneath the tree sprites.
		draw_set_color(COLOR_WORLD_MAP_PANEL);
		draw_rectangle(490, 108, 1430, 145, false);
		draw_set_font(_controller.ui_font);
		draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
		draw_set_halign(fa_center);
		draw_text(960, 115, "Hold the crossing for a shortcut, or capture the hamlet and forge to flank.");
		draw_set_halign(fa_left);
	}

	// The inspection block follows hover, then the sole selected source.
	var _selected_count = array_length(_controller.selected_nodes);
	var _inspect = _controller.hovered_node;
	if (_inspect < 0 && _selected_count == 1) _inspect = _controller.selected_nodes[0];
	draw_set_font(_controller.number_font);
	draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
	var _heading = _selected_count > 1 ? string(_selected_count) + " BUILDINGS SELECTED" : "TAKE THE LAND";
	var _description = "Select your red buildings. Send troops to capture or reinforce.";
	if (_inspect >= 0)
	{
		var _node = _controller.nodes[_inspect];
		var _names = ["SETTLEMENT", "WATCHTOWER", "FORGE"];
		_heading = _names[_node.kind] + "  /  LEVEL " + string(_node.level);
		var _growth = BALANCE_CONQUEST_GROWTH;
		var _capacity = BALANCE_CONQUEST_CAPACITY;
		var _growth_multiplier = _controller.tactical_mode ? BALANCE_CONQUEST_ROAD_GROWTH_MULTIPLIER : 1;
		switch (_node.kind)
		{
			case CONQUEST_BUILDING.SETTLEMENT:
				_description = "+" + string(_growth[_node.level - 1] * _growth_multiplier) + " troops / sec   |   Capacity " + string(_capacity[_node.level - 1]);
				if (_node.owner == CONQUEST_OWNER.NEUTRAL) _description = "Capture to recruit troops. Neutral garrisons do not grow.";
				break;
			case CONQUEST_BUILDING.TOWER:
				_description = "Fires on passing enemies. +" + string(_node.level * 15) + "% garrison defense. No recruitment.";
				break;
			case CONQUEST_BUILDING.FORGE:
				_description = "+" + string(round(_node.level * BALANCE_CONQUEST_FORGE_BONUS * 100)) + "% strength to all your troops. No recruitment.";
				break;
		}
		if (_controller.tactical_mode && _node.owner == CONQUEST_OWNER.PLAYER)
		{
			if (_node.under_siege) _description = "Under siege. Recruitment and outgoing orders are halted.";
			else if (_node.route_target >= 0)
			{
				_description = "To " + _controller.nodes[_node.route_target].label + "  |  Keep " + string(_node.reserve) + " troops\n";
				if (_node.route_blocked) _description += "ROUTE CUT: retake the road or set another destination.";
				else if (_node.upgrade_remaining > 0) _description += "Upgrading. The route resumes automatically.";
				else if (_node.dispatch_remaining > 0) _description += "Next wave ready in " + string(ceil(_node.dispatch_remaining)) + "s";
				else _description += "Waiting for at least 5 troops above the reserve.";
			}
		}
	}
	draw_text(35, 916, _heading);
	draw_set_font(_controller.ui_font);
	draw_set_color(COLOR_SQUAD_CARD_TYPE);
	draw_text_ext(35, 957, _description, 25, 575);
	draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
	draw_text(700, 922, _controller.tactical_mode && _controller.auto_orders ? "AUTO ROUTE / HOME RESERVE" : "SEND GARRISON");
	var _labels = ["25%  [1]", "50%  [2]", "75%  [3]", "100%  [4]"];
	var _fractions = [0.25, 0.5, 0.75, 1];
	var _fraction_count = _controller.tactical_mode && _controller.auto_orders ? 0 : 4;
	for (var _index = 0; _index < _fraction_count; ++_index)
	{
		conquest_button_draw(_controller, 700 + _index * 105, 960, 92, 52, _labels[_index], _controller.send_fraction == _fractions[_index]);
	}
	if (_controller.tactical_mode)
	{
		if (_controller.auto_orders)
		{
			var _reserve_label = "--";
			if (_selected_count > 0)
			{
				var _reserve = _controller.nodes[_controller.selected_nodes[0]].reserve;
				_reserve_label = string(_reserve);
				for (var _index = 1; _index < _selected_count; ++_index)
				{
					if (_controller.nodes[_controller.selected_nodes[_index]].reserve != _reserve) _reserve_label = "MIXED";
				}
			}
			conquest_button_draw(_controller, 700, 960, 92, 52, "LESS [Z]", false, _selected_count > 0);
			conquest_button_draw(_controller, 805, 960, 92, 52, _reserve_label, true, false);
			conquest_button_draw(_controller, 910, 960, 92, 52, "MORE [C]", false, _selected_count > 0);
			conquest_button_draw(_controller, 1015, 960, 92, 52, "STOP [X]", false, _selected_count > 0);
		}
		conquest_button_draw(_controller, 1150, 949, 245, 65, _controller.auto_orders ? "AUTO ROUTE  [T]" : "ONE WAVE  [T]", _controller.auto_orders);
	}
	else
	{
		draw_set_font(_controller.ui_font);
		draw_set_color(COLOR_SQUAD_CARD_TYPE);
		draw_text(1150, 922, "FORGE STRENGTH");
		draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
		draw_text(1150, 968, "+" + string(round((conquest_strength_get(_controller, CONQUEST_OWNER.PLAYER) - 1) * 100)) + "%");
	}
	var _upgrade_label = "SELECT ONE BUILDING TO UPGRADE";
	var _can_upgrade = false;
	if (_selected_count == 1)
	{
		var _node = _controller.nodes[_controller.selected_nodes[0]];
		var _costs = BALANCE_CONQUEST_UPGRADE_COST;
		var _cost = _costs[_node.level - 1];
		_upgrade_label = "UPGRADE  /  " + string(_cost) + " TROOPS  [U]";
		if (_node.level >= BALANCE_CONQUEST_MAX_LEVEL) _upgrade_label = "MAXIMUM LEVEL";
		else if (_node.upgrade_remaining > 0) _upgrade_label = "UPGRADING... " + string(ceil(_node.upgrade_remaining)) + "s";
		_can_upgrade = _node.owner == CONQUEST_OWNER.PLAYER && _node.level < BALANCE_CONQUEST_MAX_LEVEL
			&& _node.upgrade_remaining <= 0 && _node.garrison >= _cost + 1;
		if (_controller.tactical_mode && _node.under_siege)
		{
			_can_upgrade = false;
			_upgrade_label = "UNDER SIEGE";
		}
	}
	conquest_button_draw(_controller, 1440, 949, 415, 65, _upgrade_label, false, _can_upgrade);
	draw_set_font(_controller.ui_font);
	draw_set_color(COLOR_SQUAD_CARD_TYPE);
	var _controls = _controller.tactical_mode
		? "Drag / RMB: set order    T: auto route / one wave    Z / C: home reserve    X: stop routes    SHIFT / box: group    U: upgrade    SPACE: pause"
		: "LMB: select / drag to send    RMB: send to target    SHIFT / drag empty ground: group select    A: select all    U: upgrade    SPACE: pause";
	draw_text(35, 1040, _controls);
	if (_controller.feedback_timer > 0)
	{
		draw_set_halign(fa_center);
		draw_set_color(COLOR_WORLD_MAP_PANEL);
		draw_rectangle(475, 850, 1445, 884, false);
		draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
		draw_text(960, 855, _controller.feedback);
	}

	// Pause and result screens share the original dark panel / red action vocabulary.
	if (_controller.paused || _controller.phase != BATTLE_PHASE.BATTLE)
	{
		var _finished = _controller.phase != BATTLE_PHASE.BATTLE;
		var _victory = _controller.phase == BATTLE_PHASE.VICTORY;
		draw_set_alpha(0.75);
		draw_set_color(COLOR_CONQUEST_SHADOW);
		draw_rectangle(0, 0, 1920, 1080, false);
		draw_set_alpha(1);
		draw_set_color(COLOR_WORLD_MAP_PANEL);
		draw_rectangle(610, 330, 1310, 755, false);
		draw_set_color(COLOR_SQUAD_CARD_BORDER);
		draw_rectangle(610, 330, 1310, 755, true);
		draw_set_halign(fa_center);
		draw_set_font(_controller.heading_font);
		draw_set_color(COLOR_CULTIST_COUNTER_TEXT);
		draw_text(960, 382, _finished ? (_victory ? "THE LAND IS YOURS" : "YOUR CULT HAS FALLEN") : "BATTLE PAUSED");
		draw_set_font(_controller.ui_font);
		draw_set_color(COLOR_SQUAD_CARD_TYPE);
		draw_text(960, 450, _finished ? (_victory ? "The next campaign route is now open." : "Regroup and try another opening.")
			: (_controller.tactical_mode ? "Supply your outposts. Hold the crossing or open the long flank."
			: "Capture settlements to recruit. Hold forges to strengthen your army."));
		if (!_finished) conquest_button_draw(_controller, 810, 560, 300, 60, "RESUME  [SPACE]");
		conquest_button_draw(_controller, 710, 650, 240, 60, "CAMPAIGN MAP");
		conquest_button_draw(_controller, 970, 650, 240, 60, "RETRY  [R]");
	}
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}

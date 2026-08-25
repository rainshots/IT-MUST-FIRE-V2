// Initialize shared map object state.
event_inherited();

// Walls are durable combat targets and block every combat unit faction.
max_hp = BALANCE_WALL_MAX_HP;
hp = max_hp;
unit_faction = UNIT_FACTION.NOONE;
is_wall = true;
is_attackable = true;
corruption_bar_visible = false;
bar_width = 50;
bar_height = 5;
bar_offset_y = 38;

wall_navigation_mark_dirty = function()
{
	if (!instance_exists(o_game_controller))
	{
		return;
	}

	var _game_controller = instance_find(o_game_controller, 0);

	if (variable_instance_exists(_game_controller, "wall_navigation_grid_mark_dirty"))
	{
		_game_controller.wall_navigation_grid_mark_dirty();
	}
};

wall_distance_to_point = function(_point_x, _point_y)
{
	var _nearest_x = clamp(_point_x, bbox_left, bbox_right);
	var _nearest_y = clamp(_point_y, bbox_top, bbox_bottom);

	return point_distance(_point_x, _point_y, _nearest_x, _nearest_y);
};

wall_navigation_goal_candidates_get = function(_origin_x, _origin_y, _attack_radius)
{
	var _minimum_goal_gap = 4;
	var _attack_range_padding = 2;
	var _goal_gap = clamp(
		_attack_radius - _attack_range_padding,
		_minimum_goal_gap,
		BALANCE_WALL_NAVIGATION_CELL_SIZE
	);
	var _horizontal_goal_y = clamp(_origin_y, bbox_top, bbox_bottom);
	var _vertical_goal_x = clamp(_origin_x, bbox_left, bbox_right);

	return [
		{ x: bbox_left - _goal_gap, y: _horizontal_goal_y },
		{ x: bbox_right + _goal_gap, y: _horizontal_goal_y },
		{ x: _vertical_goal_x, y: bbox_top - _goal_gap },
		{ x: _vertical_goal_x, y: bbox_bottom + _goal_gap }
	];
};

unit_damage_receive = function(_damage_amount, _source_faction = UNIT_FACTION.NOONE, _is_critical = false, _can_trigger_soul_chain = true, _source_instance = noone)
{
	if (hp <= 0
		|| _damage_amount <= 0
		|| _source_faction == unit_faction)
	{
		return 0;
	}

	var _applied_damage = min(_damage_amount, hp);
	hp = max(hp - _damage_amount, 0);
	damage_popup_create(x, y, _applied_damage, unit_faction, _is_critical);

	if (hp <= 0)
	{
		instance_destroy();
	}

	return _applied_damage;
};

// A newly placed wall changes the shared navigation grid.
wall_navigation_mark_dirty();

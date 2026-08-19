// Orc hut workers are neutral haulers, not player or enemy combat units.
owner_hut = noone;
home_offset_x = 0;
home_offset_y = 0;
home_x = x;
home_y = y;
move_speed = BALANCE_ORCS_HUT_ORC_MOVE_SPEED;
y_sort_enabled = true;
image_speed = 0;

// Minimal health keeps shared corpse helper checks valid without making orcs combat units.
max_hp = 1;
hp = max_hp;

// Cannon corpse hauling state is controlled by the owner hut during the day.
carried_corpse = noone;
carried_corpses = [];
corpse_carry_capacity = BALANCE_ORCS_HUT_CORPSE_CARRY_CAPACITY;
reserved_corpse_id = noone;
corpse_search_center_x = x;
corpse_search_center_y = y;
corpse_search_radius = BALANCE_ORCS_HUT_CORPSE_SEARCH_RADIUS;
cannon_no_corpse_warning_active = false;

// Shared worker fields used by movement and hauling helpers.
target_instance = noone;
is_attacking_target = false;
is_walking = false;
drag_drop_x = x;
drag_drop_y = y;

face_world_x = function(_target_x)
{
	var _sprite_scale = abs(image_xscale);

	if (_target_x < x)
	{
		image_xscale = -_sprite_scale;
	}
	else if (_target_x > x)
	{
		image_xscale = _sprite_scale;
	}
};

orc_move_towards = function(_target_x, _target_y)
{
	var _distance = point_distance(x, y, _target_x, _target_y);

	if (_distance <= 0)
	{
		is_walking = false;
		return true;
	}

	var _time_scale = variable_global_exists("gameplay_time_scale") ? global.gameplay_time_scale : 1;
	var _scaled_move_speed = move_speed * _time_scale;
	var _move_distance = min(_scaled_move_speed, _distance);
	var _move_direction = point_direction(x, y, _target_x, _target_y);

	face_world_x(_target_x);
	x += lengthdir_x(_move_distance, _move_direction);
	y += lengthdir_y(_move_distance, _move_direction);
	drag_drop_x = x;
	drag_drop_y = y;
	is_walking = true;

	return _distance <= _scaled_move_speed;
};

// Initialize shared enemy unit state.
event_inherited();

// Holy Catapult searches for Taint and cleanses it with arcing shots.
max_hp = BALANCE_ENEMY_CATAPULT_HP;
hp = max_hp;
armor = BALANCE_ENEMY_CATAPULT_ARMOR;
magic_resistance = BALANCE_ENEMY_CATAPULT_MAGIC_RESISTANCE;
damage = BALANCE_ENEMY_CATAPULT_DAMAGE;
magic_damage = BALANCE_ENEMY_CATAPULT_MAGIC_DAMAGE;
reload_time = BALANCE_ENEMY_CATAPULT_RELOAD_TIME * room_speed;
attack_radius = BALANCE_ENEMY_CATAPULT_ATTACK_RADIUS;
cannon_attack_radius = BALANCE_ENEMY_CATAPULT_CANNON_ATTACK_RADIUS;
move_speed = BALANCE_ENEMY_CATAPULT_MOVE_SPEED;
target_detection_radius = BALANCE_ENEMY_CATAPULT_TAINT_SEARCH_RADIUS;
vision_radius = BALANCE_ENEMY_CATAPULT_TAINT_SEARCH_RADIUS;
catapult_taint_search_radius = BALANCE_ENEMY_CATAPULT_TAINT_SEARCH_RADIUS;
catapult_taint_search_interval = BALANCE_ENEMY_CATAPULT_TAINT_SEARCH_INTERVAL;
catapult_taint_search_timer = irandom(catapult_taint_search_interval - 1);
catapult_target_error_radius = BALANCE_ENEMY_CATAPULT_PROJECTILE_TARGET_ERROR_RADIUS;
catapult_cleanse_radius = BALANCE_ENEMY_CATAPULT_PROJECTILE_CLEANSE_RADIUS;
catapult_cleanse_amount = BALANCE_ENEMY_CATAPULT_PROJECTILE_CLEANSE_AMOUNT;
catapult_projectile_spawn_offset_y = -54;
catapult_projectile_layer_name = "Instances";
catapult_projectile_draw_depth = BALANCE_PARTICLE_SYSTEM_TOP_DEPTH - 50;
catapult_taint_target_x = x;
catapult_taint_target_y = y;
catapult_has_taint_target = false;

catapult_taint_target_find = function()
{
	catapult_has_taint_target = false;

	if (!instance_exists(o_corruption_grid))
	{
		return false;
	}

	var _corruption_grid = instance_find(o_corruption_grid, 0);
	var _safe_radius = max(catapult_taint_search_radius, 1);
	var _left_cell = clamp(floor((x - _safe_radius) / _corruption_grid.cell_size), 0, _corruption_grid.grid_width - 1);
	var _right_cell = clamp(floor((x + _safe_radius) / _corruption_grid.cell_size), 0, _corruption_grid.grid_width - 1);
	var _top_cell = clamp(floor((y - _safe_radius) / _corruption_grid.cell_size), 0, _corruption_grid.grid_height - 1);
	var _bottom_cell = clamp(floor((y + _safe_radius) / _corruption_grid.cell_size), 0, _corruption_grid.grid_height - 1);
	var _nearest_distance = _safe_radius;

	for (var _cell_x = _left_cell; _cell_x <= _right_cell; ++_cell_x)
	{
		for (var _cell_y = _top_cell; _cell_y <= _bottom_cell; ++_cell_y)
		{
			var _corruption = ds_grid_get(_corruption_grid.corruption_grid, _cell_x, _cell_y);

			if (_corruption < _corruption_grid.full_corruption_value)
			{
				continue;
			}

			var _cell_center_x = (_cell_x * _corruption_grid.cell_size) + (_corruption_grid.cell_size * 0.5);
			var _cell_center_y = (_cell_y * _corruption_grid.cell_size) + (_corruption_grid.cell_size * 0.5);
			var _cell_distance = point_distance(x, y, _cell_center_x, _cell_center_y);

			if (_cell_distance <= _nearest_distance)
			{
				_nearest_distance = _cell_distance;
				catapult_taint_target_x = _cell_center_x;
				catapult_taint_target_y = _cell_center_y;
				catapult_has_taint_target = true;
			}
		}
	}

	return catapult_has_taint_target;
};

catapult_cleanse_projectile_create = function(_target_x, _target_y)
{
	var _target_direction = random(360);
	var _target_distance = sqrt(random(1)) * catapult_target_error_radius;
	var _target_error_x = _target_x + lengthdir_x(_target_distance, _target_direction);
	var _target_error_y = _target_y + lengthdir_y(_target_distance, _target_direction);
	var _projectile_x = x;
	var _projectile_y = y + catapult_projectile_spawn_offset_y;
	var _projectile = instance_create_layer(_projectile_x, _projectile_y, catapult_projectile_layer_name, o_projectile);
	var _projectile_distance = point_distance(_projectile_x, _projectile_y, _target_error_x, _target_error_y);
	var _flight_time_seconds = clamp(
		_projectile_distance / BALANCE_ENEMY_CATAPULT_PROJECTILE_SPEED,
		_projectile.minimum_flight_time,
		_projectile.maximum_flight_time
	);

	_projectile.start_x = _projectile_x;
	_projectile.start_y = _projectile_y;
	_projectile.target_x = _target_error_x;
	_projectile.target_y = _target_error_y;
	_projectile.projectile_type = PROJECTILE_TYPE.CLEANSE;
	_projectile.effect_radius = catapult_cleanse_radius;
	_projectile.cleanse_amount = catapult_cleanse_amount;
	_projectile.damage_faction = UNIT_FACTION.ENEMY;
	_projectile.source_instance = id;
	_projectile.projectile_speed = BALANCE_ENEMY_CATAPULT_PROJECTILE_SPEED;
	_projectile.flight_time = _flight_time_seconds * room_speed;
	_projectile.depth = catapult_projectile_draw_depth;

	return _projectile;
};

catapult_behavior_update = function()
{
	catapult_taint_search_timer++;

	if (catapult_taint_search_timer >= catapult_taint_search_interval)
	{
		catapult_taint_search_timer = 0;
		catapult_taint_target_find();
	}

	if (!catapult_has_taint_target)
	{
		return false;
	}

	var _target_distance = point_distance(x, y, catapult_taint_target_x, catapult_taint_target_y);

	if (_target_distance > catapult_taint_search_radius)
	{
		catapult_has_taint_target = false;
		return false;
	}

	is_walking = false;
	face_world_x(catapult_taint_target_x);

	if (reload_timer > 0)
	{
		reload_timer--;
		return true;
	}

	catapult_cleanse_projectile_create(catapult_taint_target_x, catapult_taint_target_y);
	reload_timer = reload_time * unit_attack_reload_multiplier_get();
	catapult_has_taint_target = false;

	return true;
};

unit_special_behavior_update = function()
{
	return forced_retreat_update()
		|| panic_flee_update()
		|| catapult_behavior_update();
};

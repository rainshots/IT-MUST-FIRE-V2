// Worker buildings run only while gameplay is active.
missing_work_resource = noone;
missing_work_resource_name = "";
missing_work_resource_amount = 0;
missing_work_resource_color = c_white;
var _time_scale = variable_global_exists("gameplay_time_scale") ? global.gameplay_time_scale : 1;

if (building_warning_timer > 0)
{
	building_warning_timer = max(0, building_warning_timer - _time_scale);
}

if (global.pause || !building_accepts_workers)
{
	exit;
}

// Remove stale worker references before calculating building work.
var _valid_worker_count = 0;
var _worker_count = array_length(worker_cultists);

for (var _worker_index = 0; _worker_index < _worker_count; ++_worker_index)
{
	var _worker = worker_cultists[_worker_index];

	if (instance_exists(_worker)
		&& (_worker.object_index == o_archdemon
			|| variable_instance_exists(_worker, "worker_speed_multiplier")))
	{
		worker_cultists[_valid_worker_count] = _worker;
		_valid_worker_count++;
	}
}

array_resize(worker_cultists, _valid_worker_count);

if (object_index == o_ritual_circle)
{
	var _daily_exp_limit = ritual_circle_daily_exp_limit_get();
	var _daily_exp_restore = (BALANCE_RITUAL_CIRCLE_DAILY_EXP_RESTORE_PER_SECOND / max(1, room_speed))
		* _time_scale;
	ritual_circle_daily_exp_remaining = min(
		ritual_circle_daily_exp_remaining + _daily_exp_restore,
		_daily_exp_limit
	);
}

if (_valid_worker_count <= 0)
{
	production_speed_multiplier = 0;
	exit;
}

if (object_index == o_goblins_pit && !goblins_pit_can_summon_goblin())
{
	var _goblin_limit = goblins_pit_goblin_limit_get();
	goblins_pit_release_workers_if_limit_full();
	production_speed_multiplier = 0;
	building_warning_show("Goblin limit " + string(_goblin_limit) + "/" + string(_goblin_limit), COLOR_STATUS_NEGATIVE_RED);
	exit;
}

building_worker_stamina_update();
_valid_worker_count = array_length(worker_cultists);

if (_valid_worker_count <= 0)
{
	production_speed_multiplier = 0;
	exit;
}

recalculate_production_speed_multiplier();

// Resource building upgrades add free secondary work at a fraction of specialist buildings.
if (production_secondary_effect_upgrade_index != noone
	&& production_secondary_effect_upgrade_index >= 0
	&& production_secondary_effect_upgrade_index < array_length(building_upgrade_flags)
	&& building_upgrade_flags[production_secondary_effect_upgrade_index])
{
	if (object_index == o_slaughter_table)
	{
		var _heal_step = (BALANCE_MEAT_BATH_FLESH_HEAL_AMOUNT * production_speed_multiplier * BALANCE_SLAUGHTER_TABLE_HEAL_UPGRADE_MULTIPLIER) / max(1, BALANCE_MEAT_BATH_HEAL_TIME * room_speed);

		for (var _heal_worker_index = 0; _heal_worker_index < _valid_worker_count; ++_heal_worker_index)
		{
			var _heal_worker = worker_cultists[_heal_worker_index];

			if (!variable_instance_exists(_heal_worker, "hp")
				|| !variable_instance_exists(_heal_worker, "max_hp")
				|| _heal_worker.hp >= _heal_worker.max_hp)
			{
				continue;
			}

			var _upgrade_heal_hp_before_heal = _heal_worker.hp;
			_heal_worker.hp = min(_heal_worker.hp + (_heal_step * _time_scale), _heal_worker.max_hp);
			heal_feedback_create(_heal_worker, _heal_worker.hp - _upgrade_heal_hp_before_heal);
		}
	}
	else if (object_index == o_quarry && instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);

		if (variable_instance_exists(_cannon, "hp")
			&& variable_instance_exists(_cannon, "max_hp")
			&& _cannon.hp < _cannon.max_hp)
		{
			var _repair_step = (BALANCE_WORKSHOP_IRON_REPAIR_AMOUNT * production_speed_multiplier * BALANCE_RESOURCE_BUILDING_SECONDARY_EFFECT_MULTIPLIER) / max(1, BALANCE_WORKSHOP_REPAIR_TIME * room_speed);
			_cannon.hp = min(_cannon.hp + (_repair_step * _time_scale), _cannon.max_hp);
		}
	}
	else if (object_index == o_souls_well)
	{
		var _summon_step = (production_speed_multiplier * BALANCE_RESOURCE_BUILDING_SECONDARY_EFFECT_MULTIPLIER) / max(1, BALANCE_GRAVEYARD_SKELETON_PRODUCTION_TIME * room_speed);
		secondary_effect_progress += _summon_step * _time_scale;

		if (secondary_effect_progress >= 1)
		{
			var _spawn_direction = random(360);
			var _spawn_distance = random(BALANCE_SUMMON_BUILDING_SPAWN_RADIUS);
			var _spawn_x = x + lengthdir_x(_spawn_distance, _spawn_direction);
			var _spawn_y = y + lengthdir_y(_spawn_distance, _spawn_direction);
			var _summoned_unit = instance_create_layer(_spawn_x, _spawn_y, "Instances", o_skeleton);

			if (instance_exists(o_game_controller))
			{
				var _game_controller = instance_find(o_game_controller, 0);

				if (variable_instance_exists(_game_controller, "move_spawned_summoned_unit_to_cannon_inner"))
				{
					_game_controller.move_spawned_summoned_unit_to_cannon_inner(_summoned_unit);
				}
			}

			secondary_effect_progress -= 1;
		}
	}
}

// Meat Bath converts Flesh into stored healing and applies it gradually.
if (object_index == o_meat_bath)
{
	var _damaged_worker_exists = false;

	for (var _damaged_worker_index = 0; _damaged_worker_index < _valid_worker_count; ++_damaged_worker_index)
	{
		var _damaged_worker = worker_cultists[_damaged_worker_index];

		if (variable_instance_exists(_damaged_worker, "hp")
			&& variable_instance_exists(_damaged_worker, "max_hp")
			&& _damaged_worker.hp < _damaged_worker.max_hp)
		{
			_damaged_worker_exists = true;
			break;
		}
	}

	if (!_damaged_worker_exists)
	{
		exit;
	}

	if (meat_bath_heal_pool <= 0 && global.resources[RESOURCES.FLESH] >= BALANCE_MEAT_BATH_FLESH_COST)
	{
		global.resources[RESOURCES.FLESH] -= BALANCE_MEAT_BATH_FLESH_COST;
		meat_bath_heal_pool += BALANCE_MEAT_BATH_FLESH_HEAL_AMOUNT;
		resource_popup_create(x, y - production_bar_offset_y, RESOURCES.FLESH, -BALANCE_MEAT_BATH_FLESH_COST);
	}
	else if (meat_bath_heal_pool <= 0)
	{
		building_missing_resource_show(RESOURCES.FLESH, BALANCE_MEAT_BATH_FLESH_COST);
		building_workers_release();
	}

	if (meat_bath_heal_pool <= 0)
	{
		exit;
	}

	var _heal_step = ((BALANCE_MEAT_BATH_FLESH_HEAL_AMOUNT * production_speed_multiplier) / max(1, BALANCE_MEAT_BATH_HEAL_TIME * room_speed))
		* _time_scale;

	for (var _heal_worker_index = 0; _heal_worker_index < _valid_worker_count; ++_heal_worker_index)
	{
		var _heal_worker = worker_cultists[_heal_worker_index];

		if (meat_bath_heal_pool <= 0)
		{
			break;
		}

		if (!variable_instance_exists(_heal_worker, "hp")
			|| !variable_instance_exists(_heal_worker, "max_hp")
			|| _heal_worker.hp >= _heal_worker.max_hp)
		{
			continue;
		}

		var _missing_hp = _heal_worker.max_hp - _heal_worker.hp;
		var _heal_amount = min(_heal_step, min(meat_bath_heal_pool, _missing_hp));

		_heal_worker.hp += _heal_amount;
		meat_bath_heal_pool -= _heal_amount;
		heal_feedback_create(_heal_worker, _heal_amount);
	}

	exit;
}

// Ritual Circle stores base XP and applies it gradually.
if (object_index == o_ritual_circle)
{
	var _exp_worker_exists = false;

	for (var _valid_exp_worker_index = 0; _valid_exp_worker_index < _valid_worker_count; ++_valid_exp_worker_index)
	{
		var _valid_exp_worker = worker_cultists[_valid_exp_worker_index];

		if (variable_instance_exists(_valid_exp_worker, "current_exp")
			&& variable_instance_exists(_valid_exp_worker, "current_lvl"))
		{
			_exp_worker_exists = true;
			break;
		}
	}

	if (!_exp_worker_exists)
	{
		exit;
	}

	if (ritual_circle_exp_pool <= 0 && ritual_circle_daily_exp_remaining >= BALANCE_RITUAL_CIRCLE_SOUL_EXP_AMOUNT)
	{
		ritual_circle_exp_pool_amount = BALANCE_RITUAL_CIRCLE_SOUL_EXP_AMOUNT;
		ritual_circle_exp_pool += ritual_circle_exp_pool_amount;
		ritual_circle_daily_exp_remaining -= ritual_circle_exp_pool_amount;

		var _exp_popup = instance_create_layer(x, y - production_bar_offset_y, "Instances", o_damage_popup);
		_exp_popup.popup_text = "+" + string(ritual_circle_exp_pool_amount) + "exp";
		_exp_popup.popup_color = COLOR_CULTIST_SPIRIT;
		_exp_popup.is_critical = false;
	}

	if (ritual_circle_exp_pool <= 0)
	{
		building_warning_show("No XP", COLOR_STATUS_NEGATIVE_RED);
	}

	var _ritual_exp_multiplier = 1;

	if (building_upgrade_flags[0])
	{
		_ritual_exp_multiplier = BALANCE_RITUAL_CIRCLE_EXP_UPGRADE_MULTIPLIER;
	}

	var _exp_step = ((ritual_circle_exp_pool_amount * production_speed_multiplier * _ritual_exp_multiplier) / max(1, BALANCE_RITUAL_CIRCLE_EXP_TIME * room_speed))
		* _time_scale;

	// Ritual Circle restores stamina even when its daily XP reserve is empty.
	for (var _stamina_worker_index = 0; _stamina_worker_index < _valid_worker_count; ++_stamina_worker_index)
	{
		var _stamina_worker = worker_cultists[_stamina_worker_index];

		if (!variable_instance_exists(_stamina_worker, "stamina_amount"))
		{
			continue;
		}

		var _stamina_max = BALANCE_CULTIST_STAMINA_MAX;

		if (variable_instance_exists(_stamina_worker, "stamina_max"))
		{
			_stamina_max = _stamina_worker.stamina_max;
		}

		var _stamina_restore_step = ((_stamina_max * production_speed_multiplier) / max(1, BALANCE_RITUAL_CIRCLE_STAMINA_RESTORE_TIME * room_speed))
			* _time_scale;
		_stamina_worker.stamina_amount = min(_stamina_worker.stamina_amount + _stamina_restore_step, _stamina_max);
	}

	if (ritual_circle_exp_pool <= 0)
	{
		exit;
	}

	for (var _exp_worker_index = 0; _exp_worker_index < _valid_worker_count; ++_exp_worker_index)
	{
		var _exp_worker = worker_cultists[_exp_worker_index];

		if (ritual_circle_exp_pool <= 0)
		{
			break;
		}

		if (!variable_instance_exists(_exp_worker, "current_exp")
			|| !variable_instance_exists(_exp_worker, "current_lvl"))
		{
			continue;
		}

		var _exp_amount = min(_exp_step, ritual_circle_exp_pool);
		var _leveled_up = cultist_exp_add(_exp_worker, _exp_amount);

		ritual_circle_exp_pool -= _exp_amount;

		if (_leveled_up && instance_exists(o_game_controller))
		{
			var _game_controller = instance_find(o_game_controller, 0);

			_game_controller.ensure_cultist_levelup_options(_exp_worker);
		}
	}

	if (ritual_circle_exp_pool <= 0
		&& ritual_circle_daily_exp_remaining < BALANCE_RITUAL_CIRCLE_SOUL_EXP_AMOUNT)
	{
		ritual_circle_exp_pool = 0;
		building_warning_show("No XP", COLOR_STATUS_NEGATIVE_RED);
	}

	exit;
}

// Workshop converts Iron into stored repair and applies it to the cannon wall.
if (object_index == o_workshop)
{
	var _repair_target = noone;
	var _repair_amount_multiplier = 1;

	if (instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);

		if (variable_instance_exists(_cannon, "hp")
			&& variable_instance_exists(_cannon, "max_hp")
			&& _cannon.hp < _cannon.max_hp)
		{
			_repair_target = _cannon;
		}
	}

	if (!instance_exists(_repair_target))
	{
		var _structure_count = instance_number(o_map_objects_parent);
		var _nearest_distance = infinity;

		for (var _structure_index = 0; _structure_index < _structure_count; ++_structure_index)
		{
			var _structure = instance_find(o_map_objects_parent, _structure_index);

			if (!instance_exists(_structure)
				|| !variable_instance_exists(_structure, "building_constructed_by_shell")
				|| !_structure.building_constructed_by_shell
				|| !variable_instance_exists(_structure, "hp")
				|| !variable_instance_exists(_structure, "max_hp")
				|| _structure.hp >= _structure.max_hp)
			{
				continue;
			}

			var _distance_to_structure = point_distance(x, y, _structure.x, _structure.y);

			if (_distance_to_structure < _nearest_distance)
			{
				_nearest_distance = _distance_to_structure;
				_repair_target = _structure;
				_repair_amount_multiplier = BALANCE_WORKSHOP_BUILDING_REPAIR_MULTIPLIER;
			}
		}
	}

	if (!instance_exists(_repair_target))
	{
		exit;
	}

	if (workshop_repair_pool <= 0 && global.resources[RESOURCES.IRON] >= BALANCE_WORKSHOP_IRON_COST)
	{
		global.resources[RESOURCES.IRON] -= BALANCE_WORKSHOP_IRON_COST;
		workshop_repair_pool += BALANCE_WORKSHOP_IRON_REPAIR_AMOUNT;
		resource_popup_create(x, y - production_bar_offset_y, RESOURCES.IRON, -BALANCE_WORKSHOP_IRON_COST);
	}
	else if (workshop_repair_pool <= 0)
	{
		building_missing_resource_show(RESOURCES.IRON, BALANCE_WORKSHOP_IRON_COST);
		building_workers_release();
	}

	if (workshop_repair_pool <= 0)
	{
		exit;
	}

	var _repair_step = (BALANCE_WORKSHOP_IRON_REPAIR_AMOUNT * production_speed_multiplier) / max(1, BALANCE_WORKSHOP_REPAIR_TIME * room_speed);
	_repair_step *= _repair_amount_multiplier * _time_scale;

	var _missing_hp = _repair_target.max_hp - _repair_target.hp;
	var _repair_amount = min(_repair_step, min(workshop_repair_pool, _missing_hp));

	_repair_target.hp += _repair_amount;
	workshop_repair_pool -= _repair_amount;

	exit;
}

// Shell Factory converts resources into random special cannon projectiles.
if (object_index == o_shell_factory)
{
	if (variable_global_exists("cannon_blood_shell_mode_enabled")
		&& global.cannon_blood_shell_mode_enabled)
	{
		// Reusable blood shells no longer require stockpile production.
		shell_factory_progress = 0;
		shell_factory_has_paid_cost = false;
		exit;
	}

	if (!shell_factory_has_paid_cost
		&& global.resources[RESOURCES.SOULS] >= BALANCE_SHELL_FACTORY_SOUL_COST
		&& global.resources[RESOURCES.IRON] >= BALANCE_SHELL_FACTORY_IRON_COST)
	{
		global.resources[RESOURCES.SOULS] -= BALANCE_SHELL_FACTORY_SOUL_COST;
		global.resources[RESOURCES.IRON] -= BALANCE_SHELL_FACTORY_IRON_COST;
		shell_factory_has_paid_cost = true;
		resource_popup_create(x - 18, y - production_bar_offset_y, RESOURCES.SOULS, -BALANCE_SHELL_FACTORY_SOUL_COST);
		resource_popup_create(x + 18, y - production_bar_offset_y, RESOURCES.IRON, -BALANCE_SHELL_FACTORY_IRON_COST);
	}
	else if (!shell_factory_has_paid_cost)
	{
		if (global.resources[RESOURCES.SOULS] < BALANCE_SHELL_FACTORY_SOUL_COST)
		{
			building_missing_resource_show(RESOURCES.SOULS, BALANCE_SHELL_FACTORY_SOUL_COST);
		}
		else
		{
			building_missing_resource_show(RESOURCES.IRON, BALANCE_SHELL_FACTORY_IRON_COST);
		}

		building_workers_release();
		exit;
	}

	var _shell_factory_step = production_speed_multiplier / max(1, BALANCE_SHELL_FACTORY_PRODUCTION_TIME * room_speed);
	shell_factory_progress += _shell_factory_step * _time_scale;

	if (shell_factory_progress >= 1)
	{
		if (shell_factory_random_projectile_add())
		{
			shell_factory_progress -= 1;
			shell_factory_has_paid_cost = false;
			building_warning_show("Shell ready", COLOR_PROJECTILE_BUILDING_SHELL);
		}
		else
		{
			shell_factory_progress = 1;
			building_warning_show("Projectile queue full", COLOR_STATUS_NEGATIVE_RED);
		}
	}

	exit;
}

// Foundry forges selected structure shells into permanent cannon projectiles.
if (object_index == o_foundry)
{
	if (!is_struct(foundry_selected_shell))
	{
		exit;
	}

	var _foundry_step = production_speed_multiplier / max(1, foundry_shell_duration * room_speed);
	foundry_shell_progress += _foundry_step * _time_scale;

	if (foundry_shell_progress >= 1)
	{
		if (instance_exists(o_game_controller))
		{
			var _game_controller = instance_find(o_game_controller, 0);

			if (variable_instance_exists(_game_controller, "cannon_projectile_queue_add")
				&& _game_controller.cannon_projectile_queue_add(PROJECTILE_TYPE.BUILDING_SHELL, foundry_selected_shell))
			{
				building_warning_show(foundry_selected_shell.building_name + " shell ready", COLOR_PROJECTILE_BUILDING_SHELL);
				foundry_selected_shell = noone;
				foundry_shell_progress = 0;
				foundry_workers_release();
			}
			else
			{
				foundry_shell_progress = 1;
				building_warning_show("Projectile queue full", COLOR_STATUS_NEGATIVE_RED);
			}
		}
	}

	exit;
}

// Summoning buildings spend their configured resource to create temporary friendly units.
if (summon_unit_object != noone)
{
	if (!summon_has_paid_cost && summon_costs_can_pay())
	{
		summon_costs_pay();
		summon_has_paid_cost = true;
	}

	if (!summon_has_paid_cost)
	{
		var _missing_cost = summon_missing_cost_get();

		if (_missing_cost != noone)
		{
			building_missing_resource_show(_missing_cost.resource, _missing_cost.cost);
			building_workers_release();
		}

		exit;
	}

	var _summon_step = production_speed_multiplier / max(1, summon_duration * room_speed);
	summon_progress += _summon_step * _time_scale;

	if (summon_progress >= 1)
	{
		var _summon_count = 1;

		if (building_upgrade_flags[0]
			&& summon_double_unit_chance > 0
			&& random(1) < summon_double_unit_chance)
		{
			_summon_count = 2;
		}

		for (var _summon_index = 0; _summon_index < _summon_count; ++_summon_index)
		{
			var _spawn_direction = random(360);
			var _spawn_distance = random(BALANCE_SUMMON_BUILDING_SPAWN_RADIUS);
			var _spawn_x = x + lengthdir_x(_spawn_distance, _spawn_direction);
			var _spawn_y = y + lengthdir_y(_spawn_distance, _spawn_direction);

			var _summoned_unit = noone;

			if (garrison_building_is_active())
			{
				_summoned_unit = garrison_unit_create(_spawn_x, _spawn_y);
			}
			else
			{
				_summoned_unit = instance_create_layer(_spawn_x, _spawn_y, "Instances", summon_unit_object);
			}

			if (instance_exists(_summoned_unit)
				&& object_index == o_goblins_pit
				&& _summoned_unit.object_index == o_goblin)
			{
				_summoned_unit.owner_goblins_pit = id;
				_summoned_unit.home_offset_x = _spawn_x - x;
				_summoned_unit.home_offset_y = _spawn_y - y;

			}

			if (instance_exists(_summoned_unit)
				&& object_index == o_goblins_pit
				&& building_upgrade_flags[1]
				&& variable_instance_exists(_summoned_unit, "summon_nights_remaining"))
			{
				_summoned_unit.summon_nights_remaining = irandom_range(
					BALANCE_GOBLIN_UPGRADED_DAY_LIFE_MIN,
					BALANCE_GOBLIN_UPGRADED_DAY_LIFE_MAX
				);
			}

			if (instance_exists(o_game_controller))
			{
				var _game_controller = instance_find(o_game_controller, 0);

				if (variable_instance_exists(_game_controller, "move_spawned_summoned_unit_to_cannon_inner"))
				{
					_game_controller.move_spawned_summoned_unit_to_cannon_inner(_summoned_unit);
				}
			}
		}

		summon_progress -= 1;
		summon_has_paid_cost = false;
	}

	exit;
}

if (production_resource == noone)
{
	exit;
}

if (production_daily_limit > 0 && production_daily_remaining <= 0)
{
	production_progress = 0;
	building_warning_show("DAILY LIMIT", COLOR_STATUS_NEGATIVE_RED);
	building_workers_release();
	exit;
}

var _resource_capacity = infinity;

if (instance_exists(o_game_controller))
{
	var _resource_game_controller = instance_find(o_game_controller, 0);

	if (variable_instance_exists(_resource_game_controller, "resource_capacity_get"))
	{
		_resource_capacity = _resource_game_controller.resource_capacity_get(production_resource);
	}
}

if (_resource_capacity <= 0)
{
	production_progress = 0;
	building_warning_show("STORAGE FULL", COLOR_STATUS_NEGATIVE_RED);
	building_workers_release();
	exit;
}

// Use current room_speed so production duration stays stable if speed changes.
var _production_step = production_speed_multiplier / max(1, production_duration * room_speed);
production_progress += _production_step * _time_scale;

if (production_progress >= 1)
{
	production_progress -= 1;
	var _produced_amount = production_amount;

	if (production_daily_limit > 0)
	{
		_produced_amount = min(_produced_amount, production_daily_remaining);
	}

	_produced_amount = min(_produced_amount, _resource_capacity);

	if (_produced_amount > 0)
	{
		var _added_amount = _produced_amount;

		if (instance_exists(o_game_controller))
		{
			var _add_game_controller = instance_find(o_game_controller, 0);

			if (variable_instance_exists(_add_game_controller, "resource_add"))
			{
				_added_amount = _add_game_controller.resource_add(production_resource, _produced_amount);
			}
			else
			{
				global.resources[production_resource] += _produced_amount;
			}
		}
		else
		{
			global.resources[production_resource] += _produced_amount;
		}

		if (production_daily_limit > 0)
		{
			production_daily_remaining = max(0, production_daily_remaining - _added_amount);
		}

		if (_added_amount > 0)
		{
			resource_popup_create(x, y - production_bar_offset_y, production_resource, _added_amount);
		}
	}
}

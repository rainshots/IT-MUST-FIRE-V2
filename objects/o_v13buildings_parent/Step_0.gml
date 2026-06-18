// Worker buildings run only while gameplay is active.
missing_work_resource = noone;
missing_work_resource_name = "";
missing_work_resource_amount = 0;
missing_work_resource_color = c_white;

if (building_warning_timer > 0)
{
	building_warning_timer = max(0, building_warning_timer - 1);
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
		&& (_worker.object_index == o_cultist
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
	var _daily_exp_restore = BALANCE_RITUAL_CIRCLE_DAILY_EXP_RESTORE_PER_SECOND / max(1, room_speed);
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

building_cultist_stamina_update();
recalculate_production_speed_multiplier();

// Resource building upgrades add free secondary work at a fraction of specialist buildings.
if (array_length(building_upgrade_flags) > 1 && building_upgrade_flags[1])
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
			_heal_worker.hp = min(_heal_worker.hp + _heal_step, _heal_worker.max_hp);
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
			_cannon.hp = min(_cannon.hp + _repair_step, _cannon.max_hp);
		}
	}
	else if (object_index == o_souls_well)
	{
		var _summon_step = (production_speed_multiplier * BALANCE_RESOURCE_BUILDING_SECONDARY_EFFECT_MULTIPLIER) / max(1, BALANCE_GRAVEYARD_SKELETON_PRODUCTION_TIME * room_speed);
		secondary_effect_progress += _summon_step;

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
		missing_work_resource = RESOURCES.FLESH;
		missing_work_resource_name = "Flesh";
		missing_work_resource_color = COLOR_HUD_FLESH;
	}

	if (meat_bath_heal_pool <= 0)
	{
		exit;
	}

	var _heal_step = (BALANCE_MEAT_BATH_FLESH_HEAL_AMOUNT * production_speed_multiplier) / max(1, BALANCE_MEAT_BATH_HEAL_TIME * room_speed);

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
		exit;
	}

	var _exp_step = (ritual_circle_exp_pool_amount * production_speed_multiplier) / max(1, BALANCE_RITUAL_CIRCLE_EXP_TIME * room_speed);

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

	exit;
}

// Workshop converts Iron into stored repair and applies it to the cannon wall.
if (object_index == o_workshop)
{
	if (!instance_exists(o_cannon))
	{
		exit;
	}

	var _cannon = instance_find(o_cannon, 0);

	if (!variable_instance_exists(_cannon, "hp")
		|| !variable_instance_exists(_cannon, "max_hp")
		|| _cannon.hp >= _cannon.max_hp)
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
		missing_work_resource = RESOURCES.IRON;
		missing_work_resource_name = "Iron";
		missing_work_resource_color = COLOR_HUD_IRON;
	}

	if (workshop_repair_pool <= 0)
	{
		exit;
	}

	var _repair_step = (BALANCE_WORKSHOP_IRON_REPAIR_AMOUNT * production_speed_multiplier) / max(1, BALANCE_WORKSHOP_REPAIR_TIME * room_speed);
	var _missing_hp = _cannon.max_hp - _cannon.hp;
	var _repair_amount = min(_repair_step, min(workshop_repair_pool, _missing_hp));

	_cannon.hp += _repair_amount;
	workshop_repair_pool -= _repair_amount;

	exit;
}

// Summoning buildings spend their configured resource to create temporary friendly units.
if (summon_unit_object != noone)
{
	if (object_index == o_goblins_pit && !goblins_pit_can_summon_goblin())
	{
		var _goblin_limit = goblins_pit_goblin_limit_get();
		building_warning_show("Goblin limit " + string(_goblin_limit) + "/" + string(_goblin_limit), COLOR_STATUS_NEGATIVE_RED);
		exit;
	}

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
			missing_work_resource = _missing_cost.resource;
			missing_work_resource_name = _missing_cost.name;
			missing_work_resource_amount = _missing_cost.cost;
			missing_work_resource_color = _missing_cost.color;
		}

		exit;
	}

	var _summon_step = production_speed_multiplier / max(1, summon_duration * room_speed);
	summon_progress += _summon_step;

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

			var _summoned_unit = instance_create_layer(_spawn_x, _spawn_y, "Instances", summon_unit_object);

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

// Use current room_speed so production duration stays stable if speed changes.
var _production_step = production_speed_multiplier / max(1, production_duration * room_speed);
production_progress += _production_step;

if (production_progress >= 1)
{
	production_progress -= 1;
	global.resources[production_resource] += production_amount;
	resource_popup_create(x, y - production_bar_offset_y, production_resource, production_amount);
}

// Worker buildings run only while gameplay is active.
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

	if (instance_exists(_worker) && _worker.object_index == o_cultist)
	{
		worker_cultists[_valid_worker_count] = _worker;
		_valid_worker_count++;
	}
}

array_resize(worker_cultists, _valid_worker_count);

if (_valid_worker_count <= 0)
{
	production_speed_multiplier = 0;
	exit;
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

	if (meat_bath_heal_pool <= 0 && global.resources[RESOURCES.FLESH] > 0)
	{
		global.resources[RESOURCES.FLESH]--;
		meat_bath_heal_pool += BALANCE_MEAT_BATH_FLESH_HEAL_AMOUNT;
		resource_popup_create(x, y - production_bar_offset_y, RESOURCES.FLESH, -1);
	}

	if (meat_bath_heal_pool <= 0)
	{
		exit;
	}

	var _heal_step = BALANCE_MEAT_BATH_FLESH_HEAL_AMOUNT / max(1, BALANCE_MEAT_BATH_HEAL_TIME * room_speed);

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
	}

	exit;
}

// Ritual Circle converts Souls into base XP and applies it gradually.
if (object_index == o_ritual_circle)
{
	if (ritual_circle_exp_pool <= 0 && global.resources[RESOURCES.SOULS] > 0)
	{
		global.resources[RESOURCES.SOULS]--;
		ritual_circle_exp_pool += BALANCE_RITUAL_CIRCLE_SOUL_EXP_AMOUNT;
		resource_popup_create(x, y - production_bar_offset_y, RESOURCES.SOULS, -1);
	}

	if (ritual_circle_exp_pool <= 0)
	{
		exit;
	}

	var _exp_step = BALANCE_RITUAL_CIRCLE_SOUL_EXP_AMOUNT / max(1, BALANCE_RITUAL_CIRCLE_EXP_TIME * room_speed);

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

			_game_controller.open_cultist_levelup();
			break;
		}
	}

	exit;
}

// Summoning buildings spend Souls to create temporary friendly units.
if (summon_unit_object != noone)
{
	recalculate_production_speed_multiplier();

	if (!summon_has_paid_cost && global.resources[RESOURCES.SOULS] >= BALANCE_SUMMON_BUILDING_SOUL_COST)
	{
		global.resources[RESOURCES.SOULS] -= BALANCE_SUMMON_BUILDING_SOUL_COST;
		summon_has_paid_cost = true;
		resource_popup_create(x, y - production_bar_offset_y, RESOURCES.SOULS, -BALANCE_SUMMON_BUILDING_SOUL_COST);
	}

	if (!summon_has_paid_cost)
	{
		exit;
	}

	var _summon_step = production_speed_multiplier / max(1, summon_duration * room_speed);
	summon_progress += _summon_step;

	if (summon_progress >= 1)
	{
		var _spawn_direction = random(360);
		var _spawn_distance = random(BALANCE_SUMMON_BUILDING_SPAWN_RADIUS);
		var _spawn_x = x + lengthdir_x(_spawn_distance, _spawn_direction);
		var _spawn_y = y + lengthdir_y(_spawn_distance, _spawn_direction);

		instance_create_layer(_spawn_x, _spawn_y, "Instances", summon_unit_object);

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
recalculate_production_speed_multiplier();

var _production_step = production_speed_multiplier / max(1, production_duration * room_speed);
production_progress += _production_step;

if (production_progress >= 1)
{
	production_progress -= 1;
	global.resources[production_resource] += production_amount;
	resource_popup_create(x, y - production_bar_offset_y, production_resource, production_amount);
}

/// @description Manages the current day's cultists and events.

function day_event_add(_event)
{
	if (!is_struct(_event))
	{
		return false;
	}

	array_push(global.day_events, _event);
	return true;
}

function day_event_regular_shells_execute(_event, _assigned_cultists, _data)
{
	var _regular_shell_types = [PROJECTILE_TYPE.DAMAGE, PROJECTILE_TYPE.HEAL];
	var _shell_type_count = array_length(_regular_shell_types);
	var _shell_count = 2;
	var _game_controller = noone;

	if (instance_exists(o_game_controller))
	{
		_game_controller = instance_find(o_game_controller, 0);
	}

	for (var _shell_index = 0; _shell_index < _shell_count; ++_shell_index)
	{
		var _shell_type = _regular_shell_types[irandom(_shell_type_count - 1)];

		if (instance_exists(_game_controller)
			&& variable_instance_exists(_game_controller, "cannon_projectile_queue_add"))
		{
			_game_controller.cannon_projectile_queue_add(_shell_type);
		}
	}

	var _cultist_hp_cost = 10;

	for (var _cultist_index = 0; _cultist_index < array_length(_assigned_cultists); ++_cultist_index)
	{
		var _cultist = _assigned_cultists[_cultist_index];

		if (instance_exists(_cultist) && variable_instance_exists(_cultist, "damage"))
		{
			_cultist.damage(_cultist_hp_cost);
		}
	}

	return true;
}

function day_event_cultist_hp_cost_apply(_assigned_cultists, _hp_cost)
{
	_hp_cost = max(0, _hp_cost);

	for (var _cultist_index = 0; _cultist_index < array_length(_assigned_cultists); ++_cultist_index)
	{
		var _cultist = _assigned_cultists[_cultist_index];

		if (instance_exists(_cultist) && variable_instance_exists(_cultist, "hp"))
		{
			// Event costs always affect the assigned cultist, independently of combat damage handling.
			_cultist.hp = max(0, _cultist.hp - _hp_cost);
		}
	}
}

function day_event_squad_summon_execute(_event, _assigned_cultists, _data)
{
	var _squad = squad_create(_data.squad_type, _data.unit_object, _data.unit_count);

	if (!is_struct(_squad))
	{
		return false;
	}

	day_event_cultist_hp_cost_apply(_assigned_cultists, BALANCE_SQUAD_EVENT_CULTIST_HP_COST);
	return true;
}

function day_event_squad_slot_add_execute(_event, _assigned_cultists, _data)
{
	if (global.squad_limits[_data.squad_type] >= BALANCE_SQUAD_EVENT_SLOT_LIMIT)
	{
		return false;
	}

	global.squad_limits[_data.squad_type]++;
	day_event_cultist_hp_cost_apply(_assigned_cultists, BALANCE_SQUAD_EVENT_CULTIST_HP_COST);
	return true;
}

function day_event_squad_create(_building, _event_id, _title, _description, _cultist_cost, _action_type, _action_callback, _action_data)
{
	var _event = new day_event_constructor(
		_event_id + "_" + string(_building),
		_title,
		_description,
		_cultist_cost,
		1,
		[new event_action_constructor(_action_type, _action_callback, _action_data)]
	);
	_event.source_building = _building;
	return _event;
}

function day_event_blood_bath_crimson_baptism_execute(_event, _assigned_cultists, _data)
{
	if (global.blood_bath_crimson_baptism_uses >= BALANCE_BLOOD_BATH_CRIMSON_ACTIVATION_LIMIT)
	{
		return false;
	}

	for (var _cultist_index = 0; _cultist_index < array_length(global.event_cultists); ++_cultist_index)
	{
		var _cultist = global.event_cultists[_cultist_index];

		if (instance_exists(_cultist))
		{
			_cultist.max_hp += BALANCE_BLOOD_BATH_CRIMSON_MAX_HP_BONUS;
		}
	}

	global.blood_bath_crimson_baptism_uses++;
	return true;
}

function day_event_blood_bath_heal_execute(_event, _assigned_cultists, _data)
{
	var _cultist = _assigned_cultists[0];

	if (!instance_exists(_cultist))
	{
		return false;
	}

	_cultist.hp = min(_cultist.max_hp, _cultist.hp + BALANCE_BLOOD_BATH_HEAL_AMOUNT);
	return true;
}

function day_event_blood_transfusion_execute(_event, _assigned_cultists, _data)
{
	var _first_cultist = _assigned_cultists[0];
	var _second_cultist = _assigned_cultists[1];
	var _healthiest = _first_cultist.hp >= _second_cultist.hp ? _first_cultist : _second_cultist;
	var _most_wounded = _healthiest == _first_cultist ? _second_cultist : _first_cultist;

	_healthiest.hp = max(0, _healthiest.hp - BALANCE_BLOOD_TRANSFUSION_HEALTHY_DAMAGE);
	_most_wounded.max_hp += BALANCE_BLOOD_TRANSFUSION_MAX_HP_BONUS;
	_most_wounded.hp = min(_most_wounded.max_hp, _most_wounded.hp + BALANCE_BLOOD_TRANSFUSION_WOUNDED_HEAL);
	return true;
}

function day_event_harden_vessel_execute(_event, _assigned_cultists, _data)
{
	if (global.blood_bath_harden_vessel_used)
	{
		return false;
	}

	var _cultist = _assigned_cultists[0];
	_cultist.hp = max(0, _cultist.hp - BALANCE_HARDEN_VESSEL_DAMAGE);
	_cultist.max_hp += BALANCE_HARDEN_VESSEL_MAX_HP_BONUS;
	global.blood_bath_harden_vessel_used = true;
	return true;
}

function day_event_cultist_sacrifice(_cultist)
{
	if (!instance_exists(_cultist))
	{
		return false;
	}

	for (var _cultist_index = array_length(global.event_cultists) - 1; _cultist_index >= 0; --_cultist_index)
	{
		if (global.event_cultists[_cultist_index] == _cultist)
		{
			array_delete(global.event_cultists, _cultist_index, 1);
			break;
		}
	}

	instance_destroy(_cultist);
	return true;
}

function day_event_bath_demands_name_execute(_event, _assigned_cultists, _data)
{
	if (!day_event_cultist_sacrifice(_assigned_cultists[0]))
	{
		return false;
	}

	for (var _cultist_index = 0; _cultist_index < array_length(global.event_cultists); ++_cultist_index)
	{
		var _cultist = global.event_cultists[_cultist_index];

		if (instance_exists(_cultist))
		{
			_cultist.max_hp += BALANCE_BLOOD_SACRIFICE_MAX_HP_BONUS;
			_cultist.hp = _cultist.max_hp;
		}
	}

	return true;
}

function day_event_blood_for_blood_execute(_event, _assigned_cultists, _data)
{
	if (!day_event_cultist_sacrifice(_assigned_cultists[0]))
	{
		return false;
	}

	day_event_cultist_limit_add(BALANCE_BLOOD_FOR_BLOOD_LIMIT_BONUS);
	return true;
}

function day_event_blood_warpaint_execute(_event, _assigned_cultists, _data)
{
	global.squad_blood_warpaint_pending = true;
	return true;
}

function day_event_blood_bath_create(_building, _event_id, _title, _description, _cultist_cost, _activation_limit, _action_callback)
{
	var _event = new day_event_constructor(
		_event_id + "_" + string(_building),
		_title,
		_description,
		_cultist_cost,
		_activation_limit,
		[new event_action_constructor(_event_id, _action_callback)]
	);
	_event.source_building = _building;
	return _event;
}

function day_event_shell_factory_create(_shell_factory)
{
	var _actions = [
		new event_action_constructor(
			"produce_regular_shells",
			day_event_regular_shells_execute
		)
	];
	var _event = new day_event_constructor(
		"shell_factory_regular_shells_" + string(_shell_factory),
		"Produce regular shells",
		"Produce 2 random regular shells (heal or explosion),\nbut cultists hp -10",
		2,
		1,
		_actions
	);

	_event.source_building = _shell_factory;
	return _event;
}

function day_event_generate_for_buildings()
{
	var _shell_factory_count = instance_number(o_shell_factory);

	for (var _factory_index = 0; _factory_index < _shell_factory_count; ++_factory_index)
	{
		var _shell_factory = instance_find(o_shell_factory, _factory_index);

		if (instance_exists(_shell_factory))
		{
			day_event_add(day_event_shell_factory_create(_shell_factory));
		}
	}

	var _pit_count = instance_number(o_pitlings_pit2);

	for (var _pit_index = 0; _pit_index < _pit_count; ++_pit_index)
	{
		var _pit = instance_find(o_pitlings_pit2, _pit_index);

		if (squad_slot_is_available(SQUAD_TYPE.DEMON))
		{
			day_event_add(day_event_squad_create(_pit, "summon_pitlings_squad", "Summon Pitlings Squad", "Summons squad of 3 Pitlings. Pitlings are good melee warriors.\nRequires 3 cultists. Each loses 20 HP.", 3, "summon_squad", day_event_squad_summon_execute, { squad_type: SQUAD_TYPE.DEMON, unit_object: o_pitling, unit_count: BALANCE_SQUAD_PITLING_COUNT }));
		}

		if (global.squad_limits[SQUAD_TYPE.DEMON] < BALANCE_SQUAD_EVENT_SLOT_LIMIT)
		{
			day_event_add(day_event_squad_create(_pit, "hell_makes_room", "Hell Makes Room", "Adds 1 more demon squad slot.\nRequires 2 cultists. Each loses 20 HP.", 2, "add_squad_slot", day_event_squad_slot_add_execute, { squad_type: SQUAD_TYPE.DEMON }));
		}
	}

	var _graveyard_count = instance_number(o_graveyard2);

	for (var _graveyard_index = 0; _graveyard_index < _graveyard_count; ++_graveyard_index)
	{
		var _graveyard = instance_find(o_graveyard2, _graveyard_index);

		if (squad_slot_is_available(SQUAD_TYPE.UNDEAD))
		{
			day_event_add(day_event_squad_create(_graveyard, "raise_skeletons_squad", "Raise Skeletons Squad", "Summons squad of 6 Skeletons. Skeletons are weak but they take it in quantity.\nRequires 3 cultists. Each loses 20 HP.", 3, "summon_squad", day_event_squad_summon_execute, { squad_type: SQUAD_TYPE.UNDEAD, unit_object: o_skeleton, unit_count: BALANCE_SQUAD_SKELETON_COUNT }));
		}

		if (global.squad_limits[SQUAD_TYPE.UNDEAD] < BALANCE_SQUAD_EVENT_SLOT_LIMIT)
		{
			day_event_add(day_event_squad_create(_graveyard, "extend_the_catacombs", "Extend the Catacombs", "Adds 1 more undead squad slot.\nRequires 2 cultists. Each loses 20 HP.", 2, "add_squad_slot", day_event_squad_slot_add_execute, { squad_type: SQUAD_TYPE.UNDEAD }));
		}
	}

	var _blood_bath_count = instance_number(o_meat_bath);

	for (var _blood_bath_index = 0; _blood_bath_index < _blood_bath_count; ++_blood_bath_index)
	{
		var _blood_bath = instance_find(o_meat_bath, _blood_bath_index);

		if (global.blood_bath_crimson_baptism_uses < BALANCE_BLOOD_BATH_CRIMSON_ACTIVATION_LIMIT)
		{
			day_event_add(day_event_blood_bath_create(_blood_bath, "crimson_baptism", "Crimson Baptism", "All current Cultists gain +10 Max HP.\nRequires 3 Cultists. Can be activated 3 times per game.", 3, 1, day_event_blood_bath_crimson_baptism_execute));
		}

		day_event_add(day_event_blood_bath_create(_blood_bath, "blood_bath", "Blood Bath", "Assigned Cultists restore 30 HP.\nAssign 1 to 4 Cultists.", 1, BALANCE_BLOOD_BATH_HEAL_CULTIST_LIMIT, day_event_blood_bath_heal_execute));
		day_event_add(day_event_blood_bath_create(_blood_bath, "blood_transfusion", "Blood Transfusion", "The healthiest assigned Cultist loses 40 HP. The most wounded restores 60 HP and gains +10 Max HP.\nRequires 2 Cultists.", 2, 1, day_event_blood_transfusion_execute));

		if (day_event_cultist_count_get() >= BALANCE_HARDEN_VESSEL_MIN_CULTISTS
			&& !global.blood_bath_harden_vessel_used)
		{
			day_event_add(day_event_blood_bath_create(_blood_bath, "harden_the_vessel", "Harden the Vessel", "The assigned Cultist loses 40 HP and permanently gains +20 Max HP.\nRequires 1 Cultist. Once per game.", 1, 1, day_event_harden_vessel_execute));
		}

		day_event_add(day_event_blood_bath_create(_blood_bath, "the_bath_demands_a_name", "The Bath Demands a Name", "Sacrifice the assigned Cultist. All remaining Cultists fully restore HP and gain +10 Max HP.\nRequires 1 Cultist.", 1, 1, day_event_bath_demands_name_execute));
		day_event_add(day_event_blood_bath_create(_blood_bath, "blood_for_blood", "Blood for Blood", "Sacrifice the assigned Cultist. Increase the maximum number of Cultists by 2.\nRequires 1 Cultist. Does not create a new Cultist.", 1, 1, day_event_blood_for_blood_execute));
		day_event_add(day_event_blood_bath_create(_blood_bath, "blood_warpaint", "Blood Warpaint", "All squads gain +15% Max HP next night.\nRequires 1 Cultist.", 1, 1, day_event_blood_warpaint_execute));
	}

	return array_length(global.day_events);
}

function day_event_cultist_random_name_get()
{
	var _available_names = [];

	for (var _name_index = 0; _name_index < array_length(global.event_cultist_names); ++_name_index)
	{
		var _candidate_name = global.event_cultist_names[_name_index];
		var _name_is_used = false;

		for (var _cultist_index = 0; _cultist_index < array_length(global.event_cultists); ++_cultist_index)
		{
			var _cultist = global.event_cultists[_cultist_index];

			if (instance_exists(_cultist) && _cultist.cultist_name == _candidate_name)
			{
				_name_is_used = true;
				break;
			}
		}

		if (!_name_is_used)
		{
			array_push(_available_names, _candidate_name);
		}
	}

	if (array_length(_available_names) > 0)
	{
		return _available_names[irandom(array_length(_available_names) - 1)];
	}

	var _fallback_name = global.event_cultist_names[irandom(array_length(global.event_cultist_names) - 1)];
	return _fallback_name + " " + string(array_length(global.event_cultists) + 1);
}

function day_event_cultist_count_get()
{
	var _cultist_count = 0;

	for (var _cultist_index = 0; _cultist_index < array_length(global.event_cultists); ++_cultist_index)
	{
		if (instance_exists(global.event_cultists[_cultist_index]))
		{
			_cultist_count++;
		}
	}

	return _cultist_count;
}

function day_event_cultist_limit_add(_amount)
{
	var _limit_increase = max(0, floor(_amount));
	global.cultist_limit += _limit_increase;
	return global.cultist_limit;
}

function day_event_cultist_add(_name = "", _max_hp = BALANCE_EVENT_CULTIST_MAX_HP)
{
	if (!instance_exists(o_cannon) || day_event_cultist_count_get() >= global.cultist_limit)
	{
		return noone;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _spawn_x = _cannon.x + random_range(
		-BALANCE_EVENT_CULTIST_WANDER_HORIZONTAL_DISTANCE,
		BALANCE_EVENT_CULTIST_WANDER_HORIZONTAL_DISTANCE
	);
	var _spawn_y = _cannon.y + BALANCE_EVENT_CULTIST_WANDER_VERTICAL_DISTANCE_MIN;
	var _cultist = instance_create_layer(_spawn_x, _spawn_y, "Instances", o_cultist);
	_cultist.cultist_name = _name == "" ? day_event_cultist_random_name_get() : _name;
	_cultist.max_hp = max(1, _max_hp);
	_cultist.hp = _cultist.max_hp;
	array_push(global.event_cultists, _cultist);
	return _cultist;
}

function day_event_finish_day()
{
	var _executed_activation_count = 0;
	var _event_count = array_length(global.day_events);

	for (var _event_index = 0; _event_index < _event_count; ++_event_index)
	{
		var _event = global.day_events[_event_index];

		if (is_struct(_event) && variable_struct_exists(_event, "execute"))
		{
			_executed_activation_count += _event.execute();
		}
	}

	return _executed_activation_count;
}

function day_event_new_day_reset()
{
	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _event = global.day_events[_event_index];

		if (!is_struct(_event))
		{
			continue;
		}

		for (var _cultist_index = 0; _cultist_index < array_length(_event.assigned_cultists); ++_cultist_index)
		{
			var _cultist = _event.assigned_cultists[_cultist_index];

			if (instance_exists(_cultist))
			{
				_cultist.assigned_event = noone;
			}
		}
	}

	global.day_events = [];
}

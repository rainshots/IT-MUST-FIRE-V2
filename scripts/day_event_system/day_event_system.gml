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

function day_event_random_cultist_cost_get(
	_group_cultist_count = BALANCE_GRAVEYARD_EVENT_GROUP_CULTIST_COUNT,
	_group_hp_cost = BALANCE_GRAVEYARD_EVENT_GROUP_HP_COST,
	_solo_cultist_count = BALANCE_GRAVEYARD_EVENT_SOLO_CULTIST_COUNT,
	_solo_hp_cost = BALANCE_GRAVEYARD_EVENT_SOLO_HP_COST)
{
	if (irandom(1) == 0)
	{
		return {
			cultist_count: _group_cultist_count,
			hp_cost: _group_hp_cost,
			text: "Requires " + string(_group_cultist_count)
				+ " Cultists. Each loses " + string(_group_hp_cost) + " HP."
		};
	}

	return {
		cultist_count: _solo_cultist_count,
		hp_cost: _solo_hp_cost,
		text: "Requires " + string(_solo_cultist_count)
			+ " Cultist, who loses " + string(_solo_hp_cost) + " HP."
	};
}

function day_event_demons_pit_random_cultist_cost_get()
{
	return day_event_random_cultist_cost_get(
		BALANCE_DEMONS_PIT_EVENT_GROUP_CULTIST_COUNT,
		BALANCE_DEMONS_PIT_EVENT_GROUP_HP_COST,
		BALANCE_DEMONS_PIT_EVENT_SOLO_CULTIST_COUNT,
		BALANCE_DEMONS_PIT_EVENT_SOLO_HP_COST
	);
}

function day_event_support_summon_cost_get()
{
	if (irandom(1) == 0)
	{
		return {
			cultist_count: BALANCE_SUPPORT_SUMMON_GROUP_CULTIST_COUNT,
			hp_cost: BALANCE_SUPPORT_SUMMON_GROUP_HP_COST,
			text: "Requires " + string(BALANCE_SUPPORT_SUMMON_GROUP_CULTIST_COUNT)
				+ " Cultists. No HP cost."
		};
	}

	return {
		cultist_count: BALANCE_SUPPORT_SUMMON_SOLO_CULTIST_COUNT,
		hp_cost: BALANCE_SUPPORT_SUMMON_SOLO_HP_COST,
		text: "Requires " + string(BALANCE_SUPPORT_SUMMON_SOLO_CULTIST_COUNT)
			+ " Cultist, who loses " + string(BALANCE_SUPPORT_SUMMON_SOLO_HP_COST) + " HP."
	};
}

function day_event_squad_contains_unit_object(_squad, _unit_object)
{
	if (!is_struct(_squad) || !variable_struct_exists(_squad, "unit_objects"))
	{
		return false;
	}

	var _unit_count = array_length(_squad.unit_objects);

	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		if (_squad.unit_objects[_unit_index] == _unit_object)
		{
			return true;
		}
	}

	return false;
}

function day_event_squads_get(_squad_type, _required_unit_object = noone)
{
	var _eligible_squads = [];
	var _squad_count = array_length(global.squads);

	for (var _squad_index = 0; _squad_index < _squad_count; ++_squad_index)
	{
		var _squad = global.squads[_squad_index];

		if (!is_struct(_squad)
			|| _squad.squad_type != _squad_type
			|| (_required_unit_object != noone
				&& !day_event_squad_contains_unit_object(_squad, _required_unit_object)))
		{
			continue;
		}

		array_push(_eligible_squads, _squad);
	}

	return _eligible_squads;
}

function day_event_squad_selection_add(_event, _eligible_squads)
{
	_event.requires_squad_selection = true;
	_event.eligible_squads = _eligible_squads;
	_event.selected_squad = noone;
	return _event;
}

function day_event_squad_summon_execute(_event, _assigned_cultists, _data)
{
	var _squad = squad_create(_data.squad_type, _data.unit_object, _data.unit_count);

	if (!is_struct(_squad))
	{
		return false;
	}

	var _hp_cost = variable_struct_exists(_data, "hp_cost")
		? _data.hp_cost
		: BALANCE_SQUAD_EVENT_CULTIST_HP_COST;
	day_event_cultist_hp_cost_apply(_assigned_cultists, _hp_cost);
	return true;
}

function day_event_squad_slot_add_execute(_event, _assigned_cultists, _data)
{
	var _slot_limit = variable_struct_exists(_data, "slot_limit")
		? _data.slot_limit
		: BALANCE_SQUAD_EVENT_SLOT_LIMIT;

	if (global.squad_limits[_data.squad_type] >= _slot_limit)
	{
		return false;
	}

	global.squad_limits[_data.squad_type]++;
	var _hp_cost = variable_struct_exists(_data, "hp_cost")
		? _data.hp_cost
		: BALANCE_SQUAD_EVENT_CULTIST_HP_COST;
	day_event_cultist_hp_cost_apply(_assigned_cultists, _hp_cost);
	return true;
}

function day_event_squad_units_replace_execute(_event, _assigned_cultists, _data)
{
	if (!variable_struct_exists(_event, "selected_squad") || !is_struct(_event.selected_squad))
	{
		return false;
	}

	var _squad = _event.selected_squad;
	var _replacement_count = 0;
	var _unit_count = array_length(_squad.unit_objects);

	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		if (_squad.unit_objects[_unit_index] != _data.source_unit_object)
		{
			continue;
		}

		_squad.unit_objects[_unit_index] = _data.target_unit_object;
		_replacement_count++;
		var _old_unit = _squad.units[_unit_index];

		if (instance_exists(_old_unit))
		{
			var _new_unit = instance_create_layer(_old_unit.x, _old_unit.y, "Instances", _data.target_unit_object);
			squad_unit_permanent_bonuses_apply(_squad, _new_unit);

			if (variable_instance_exists(_new_unit, "hp") && variable_instance_exists(_new_unit, "max_hp"))
			{
				_new_unit.hp = _new_unit.max_hp;
			}

			squad_unit_reference_replace(_old_unit, _new_unit);
			instance_destroy(_old_unit);
		}
	}

	if (_replacement_count <= 0)
	{
		return false;
	}

	if (_squad.primary_unit_object == _data.source_unit_object)
	{
		_squad.primary_unit_object = _data.target_unit_object;
		_squad.name = squad_name_create(_data.target_unit_object);
	}

	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}

function day_event_squad_draft_execute(_event, _assigned_cultists, _data)
{
	if (!variable_struct_exists(_event, "selected_squad") || !is_struct(_event.selected_squad))
	{
		return false;
	}

	var _squad = _event.selected_squad;
	var _unit_count = array_length(_squad.unit_objects);

	if (_unit_count <= 0)
	{
		return false;
	}

	var _most_common_object = _squad.unit_objects[0];
	var _most_common_count = 0;

	for (var _candidate_index = 0; _candidate_index < _unit_count; ++_candidate_index)
	{
		var _candidate_object = _squad.unit_objects[_candidate_index];
		var _candidate_count = 0;

		for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
		{
			if (_squad.unit_objects[_unit_index] == _candidate_object)
			{
				_candidate_count++;
			}
		}

		if (_candidate_count > _most_common_count)
		{
			_most_common_count = _candidate_count;
			_most_common_object = _candidate_object;
		}
	}

	var _draft_count = variable_struct_exists(_data, "unit_count")
		? max(1, floor(_data.unit_count))
		: BALANCE_GRAVEYARD_DRAFT_UNIT_COUNT;

	for (var _draft_index = 0; _draft_index < _draft_count; ++_draft_index)
	{
		var _new_unit_index = array_length(_squad.unit_objects);
		array_push(_squad.unit_objects, _most_common_object);
		var _new_unit = squad_unit_spawn(_squad, _most_common_object, _new_unit_index);
		array_push(_squad.units, _new_unit);

		if (instance_exists(_new_unit))
		{
			_squad.total_max_hp += _new_unit.max_hp;
		}
	}

	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}

function day_event_squad_permanent_upgrade_execute(_event, _assigned_cultists, _data)
{
	if (!variable_struct_exists(_event, "selected_squad") || !is_struct(_event.selected_squad))
	{
		return false;
	}

	var _squad = _event.selected_squad;
	var _property_name = _data.property_name;
	var _upgrade_multiplier = _data.multiplier;
	var _current_multiplier = variable_struct_exists(_squad.properties, _property_name)
		? variable_struct_get(_squad.properties, _property_name)
		: 1;
	variable_struct_set(_squad.properties, _property_name, _current_multiplier * _upgrade_multiplier);

	var _unit_count = array_length(_squad.units);

	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		var _unit = _squad.units[_unit_index];

		if (!instance_exists(_unit))
		{
			continue;
		}

		if (_property_name == "health_multiplier" && variable_instance_exists(_unit, "max_hp"))
		{
			_unit.max_hp *= _upgrade_multiplier;

			if (variable_instance_exists(_unit, "hp"))
			{
				_unit.hp = min(_unit.max_hp, _unit.hp * _upgrade_multiplier);
			}
		}
		else if (_property_name == "damage_multiplier")
		{
			if (variable_instance_exists(_unit, "damage"))
			{
				_unit.damage *= _upgrade_multiplier;
			}

			if (variable_instance_exists(_unit, "magic_damage"))
			{
				_unit.magic_damage *= _upgrade_multiplier;
			}
		}
	}

	if (_property_name == "health_multiplier")
	{
		_squad.total_max_hp *= _upgrade_multiplier;
	}

	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}

function day_event_squad_unit_add_execute(_event, _assigned_cultists, _data)
{
	if (!variable_struct_exists(_event, "selected_squad") || !is_struct(_event.selected_squad))
	{
		return false;
	}

	var _squad = _event.selected_squad;
	var _new_unit_index = array_length(_squad.unit_objects);
	array_push(_squad.unit_objects, _data.unit_object);
	var _new_unit = squad_unit_spawn(_squad, _data.unit_object, _new_unit_index);
	array_push(_squad.units, _new_unit);

	if (!instance_exists(_new_unit))
	{
		array_delete(_squad.unit_objects, _new_unit_index, 1);
		array_delete(_squad.units, _new_unit_index, 1);
		return false;
	}

	_squad.total_max_hp += _new_unit.max_hp;
	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
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
		var _mawling_squads = day_event_squads_get(SQUAD_TYPE.DEMON, o_mawling);
		var _demon_squads = day_event_squads_get(SQUAD_TYPE.DEMON);

		if (global.squad_limits[SQUAD_TYPE.DEMON] < BALANCE_SQUAD_EVENT_SLOT_LIMIT)
		{
			var _room_cost = day_event_demons_pit_random_cultist_cost_get();
			day_event_add(day_event_squad_create(
				_pit,
				"hell_makes_room",
				"Hell Makes Room",
				"Adds 1 more demon squad slot.\n" + _room_cost.text,
				_room_cost.cultist_count,
				"add_demon_squad_slot",
				day_event_squad_slot_add_execute,
				{ squad_type: SQUAD_TYPE.DEMON, slot_limit: BALANCE_SQUAD_EVENT_SLOT_LIMIT, hp_cost: _room_cost.hp_cost }
			));
		}

		if (array_length(_demon_squads) > 0)
		{
			var _fill_event = day_event_squad_create(
				_pit,
				"fill_the_ranks",
				"Fill the Ranks",
				"Add 1 unit of the most common unit type in the selected demon squad.",
				BALANCE_DEMONS_PIT_FILL_CULTIST_COUNT,
				"fill_demon_ranks",
				day_event_squad_draft_execute,
				{ hp_cost: BALANCE_DEMONS_PIT_FILL_HP_COST, unit_count: BALANCE_DEMONS_PIT_DRAFT_UNIT_COUNT }
			);
			day_event_add(day_event_squad_selection_add(_fill_event, _demon_squads));
		}

		if (squad_slot_is_available(SQUAD_TYPE.DEMON))
		{
			var _summon_cost = day_event_demons_pit_random_cultist_cost_get();
			day_event_add(day_event_squad_create(
				_pit,
				"summon_mawlings",
				"Summon Mawlings",
				"Summon a squad of " + string(BALANCE_SQUAD_PITLING_COUNT)
					+ " Mawlings. These are units that can later be transformed into stronger demons.\n" + _summon_cost.text,
				_summon_cost.cultist_count,
				"summon_mawlings_squad",
				day_event_squad_summon_execute,
				{ squad_type: SQUAD_TYPE.DEMON, unit_object: o_mawling, unit_count: BALANCE_SQUAD_PITLING_COUNT, hp_cost: _summon_cost.hp_cost }
			));
		}

		if (array_length(_mawling_squads) > 0)
		{
			var _balgor_cost = day_event_demons_pit_random_cultist_cost_get();
			var _balgor_event = day_event_squad_create(
				_pit,
				"forge_balgors",
				"Forge Balgors",
				"Replace all Mawlings in the selected squad with Balgors.\n" + _balgor_cost.text,
				_balgor_cost.cultist_count,
				"replace_mawlings_with_balgors",
				day_event_squad_units_replace_execute,
				{ source_unit_object: o_mawling, target_unit_object: o_balgor, hp_cost: _balgor_cost.hp_cost }
			);
			day_event_add(day_event_squad_selection_add(_balgor_event, _mawling_squads));

			var _succubus_cost = day_event_demons_pit_random_cultist_cost_get();
			var _succubus_event = day_event_squad_create(
				_pit,
				"lessons_in_temptation",
				"Lessons in Temptation",
				"Replace all Mawlings in the selected squad with Succubi.\n" + _succubus_cost.text,
				_succubus_cost.cultist_count,
				"replace_mawlings_with_succubi",
				day_event_squad_units_replace_execute,
				{ source_unit_object: o_mawling, target_unit_object: o_succubus, hp_cost: _succubus_cost.hp_cost }
			);
			day_event_add(day_event_squad_selection_add(_succubus_event, _mawling_squads));

			var _pitling_cost = day_event_demons_pit_random_cultist_cost_get();
			var _pitling_event = day_event_squad_create(
				_pit,
				"born_in_pit",
				"Born in Pit",
				"Replace all Mawlings in the selected squad with Pitlings.\n" + _pitling_cost.text,
				_pitling_cost.cultist_count,
				"replace_mawlings_with_pitlings",
				day_event_squad_units_replace_execute,
				{ source_unit_object: o_mawling, target_unit_object: o_pitling, hp_cost: _pitling_cost.hp_cost }
			);
			day_event_add(day_event_squad_selection_add(_pitling_event, _mawling_squads));
		}

		if (array_length(_demon_squads) > 0)
		{
			var _wizard_cost = day_event_support_summon_cost_get();
			var _wizard_event = day_event_squad_create(
				_pit,
				"summon_demon_wizard",
				"Summon Demon Wizard",
				"Summon a Demon Wizard in the selected Demon Squad. He buffs the damage and speed of squad units.\n" + _wizard_cost.text,
				_wizard_cost.cultist_count,
				"add_demon_wizard_to_squad",
				day_event_squad_unit_add_execute,
				{ unit_object: o_demon_wizard, hp_cost: _wizard_cost.hp_cost }
			);
			day_event_add(day_event_squad_selection_add(_wizard_event, _demon_squads));

			var _demon_draft_event = day_event_squad_create(
				_pit,
				"demon_draft",
				"Demon Draft",
				"Add 1 unit of the most common unit type in the selected demon squad.\nRequires 1 Cultist, who loses "
					+ string(BALANCE_DEMONS_PIT_DRAFT_HP_COST) + " HP.",
				BALANCE_DEMONS_PIT_DRAFT_CULTIST_COUNT,
				"draft_demons",
				day_event_squad_draft_execute,
				{ hp_cost: BALANCE_DEMONS_PIT_DRAFT_HP_COST, unit_count: BALANCE_DEMONS_PIT_DRAFT_UNIT_COUNT }
			);
			day_event_add(day_event_squad_selection_add(_demon_draft_event, _demon_squads));

			var _infernal_fury_event = day_event_squad_create(
				_pit,
				"infernal_fury",
				"Infernal Fury",
				"Permanently increase the damage of the selected Demon Squad by 15%.\nRequires 1 Cultist, who loses 30 HP.",
				BALANCE_SQUAD_PERMANENT_UPGRADE_CULTIST_COUNT,
				"increase_demon_squad_damage",
				day_event_squad_permanent_upgrade_execute,
				{ property_name: "damage_multiplier", multiplier: BALANCE_SQUAD_PERMANENT_UPGRADE_MULTIPLIER, hp_cost: BALANCE_SQUAD_PERMANENT_UPGRADE_HP_COST }
			);
			day_event_add(day_event_squad_selection_add(_infernal_fury_event, _demon_squads));

			var _infernal_vitality_event = day_event_squad_create(
				_pit,
				"infernal_vitality",
				"Infernal Vitality",
				"Permanently increase the health of the selected Demon Squad by 15%.\nRequires 1 Cultist, who loses 30 HP.",
				BALANCE_SQUAD_PERMANENT_UPGRADE_CULTIST_COUNT,
				"increase_demon_squad_health",
				day_event_squad_permanent_upgrade_execute,
				{ property_name: "health_multiplier", multiplier: BALANCE_SQUAD_PERMANENT_UPGRADE_MULTIPLIER, hp_cost: BALANCE_SQUAD_PERMANENT_UPGRADE_HP_COST }
			);
			day_event_add(day_event_squad_selection_add(_infernal_vitality_event, _demon_squads));
		}
	}

	var _graveyard_count = instance_number(o_graveyard2);

	for (var _graveyard_index = 0; _graveyard_index < _graveyard_count; ++_graveyard_index)
	{
		var _graveyard = instance_find(o_graveyard2, _graveyard_index);
		var _bonelet_squads = day_event_squads_get(SQUAD_TYPE.UNDEAD, o_skeleton_bonelet);
		var _undead_squads = day_event_squads_get(SQUAD_TYPE.UNDEAD);

		if (squad_slot_is_available(SQUAD_TYPE.UNDEAD))
		{
			var _raise_cost = day_event_random_cultist_cost_get();
			day_event_add(day_event_squad_create(
				_graveyard,
				"raise_bonelets_squad",
				"Raise Bonelets Squad",
				"Summons a squad of " + string(BALANCE_SQUAD_SKELETON_COUNT)
					+ " Bonelets. Skeletons are weak but they take it in quantity.\n" + _raise_cost.text,
				_raise_cost.cultist_count,
				"summon_bonelets_squad",
				day_event_squad_summon_execute,
				{ squad_type: SQUAD_TYPE.UNDEAD, unit_object: o_skeleton_bonelet, unit_count: BALANCE_SQUAD_SKELETON_COUNT, hp_cost: _raise_cost.hp_cost }
			));
		}

		if (global.squad_limits[SQUAD_TYPE.UNDEAD] < BALANCE_SQUAD_EVENT_SLOT_LIMIT)
		{
			var _catacombs_cost = day_event_random_cultist_cost_get();
			day_event_add(day_event_squad_create(
				_graveyard,
				"extend_the_catacombs",
				"Extend the Catacombs",
				"Adds 1 more undead squad slot.\n" + _catacombs_cost.text,
				_catacombs_cost.cultist_count,
				"add_undead_squad_slot",
				day_event_squad_slot_add_execute,
				{ squad_type: SQUAD_TYPE.UNDEAD, slot_limit: BALANCE_SQUAD_EVENT_SLOT_LIMIT, hp_cost: _catacombs_cost.hp_cost }
			));
		}

		if (array_length(_bonelet_squads) > 0)
		{
			var _arm_cost = day_event_random_cultist_cost_get();
			var _arm_event = day_event_squad_create(
				_graveyard,
				"arm_the_dead",
				"Arm the Dead",
				"Replace all Bonelets in the selected squad with Skeleton Warriors.\n" + _arm_cost.text,
				_arm_cost.cultist_count,
				"replace_bonelets_with_warriors",
				day_event_squad_units_replace_execute,
				{ source_unit_object: o_skeleton_bonelet, target_unit_object: o_skeleton_warrior, hp_cost: _arm_cost.hp_cost }
			);
			day_event_add(day_event_squad_selection_add(_arm_event, _bonelet_squads));

			var _scholars_cost = day_event_random_cultist_cost_get();
			var _scholars_event = day_event_squad_create(
				_graveyard,
				"bone_scholars",
				"Bone Scholars",
				"Replace all Bonelets in the selected squad with Skeleton Mages.\n" + _scholars_cost.text,
				_scholars_cost.cultist_count,
				"replace_bonelets_with_mages",
				day_event_squad_units_replace_execute,
				{ source_unit_object: o_skeleton_bonelet, target_unit_object: o_skeleton_mage, hp_cost: _scholars_cost.hp_cost }
			);
			day_event_add(day_event_squad_selection_add(_scholars_event, _bonelet_squads));

			var _archery_cost = day_event_random_cultist_cost_get();
			var _archery_event = day_event_squad_create(
				_graveyard,
				"bone_archery",
				"Bone Archery",
				"Replace all Bonelets in the selected squad with Skeleton Archers.\n" + _archery_cost.text,
				_archery_cost.cultist_count,
				"replace_bonelets_with_archers",
				day_event_squad_units_replace_execute,
				{ source_unit_object: o_skeleton_bonelet, target_unit_object: o_skeleton_archer, hp_cost: _archery_cost.hp_cost }
			);
			day_event_add(day_event_squad_selection_add(_archery_event, _bonelet_squads));
		}

		if (array_length(_undead_squads) > 0)
		{
			var _healer_cost = day_event_support_summon_cost_get();
			var _healer_event = day_event_squad_create(
				_graveyard,
				"summon_skeleton_healer",
				"Summon Skeleton Healer",
				"Summon a Skeleton Healer in the selected Undead Squad. He heals units in the squad.\n" + _healer_cost.text,
				_healer_cost.cultist_count,
				"add_skeleton_healer_to_squad",
				day_event_squad_unit_add_execute,
				{ unit_object: o_skeleton_healer, hp_cost: _healer_cost.hp_cost }
			);
			day_event_add(day_event_squad_selection_add(_healer_event, _undead_squads));

			var _draft_event = day_event_squad_create(
				_graveyard,
				"skeleton_draft",
				"Skeleton Draft",
				"Add " + string(BALANCE_GRAVEYARD_DRAFT_UNIT_COUNT)
					+ " units of the most common unit type in the selected undead squad.\nRequires "
					+ string(BALANCE_GRAVEYARD_DRAFT_CULTIST_COUNT) + " Cultist, who loses "
					+ string(BALANCE_GRAVEYARD_DRAFT_HP_COST) + " HP.",
				BALANCE_GRAVEYARD_DRAFT_CULTIST_COUNT,
				"draft_skeletons",
				day_event_squad_draft_execute,
				{ hp_cost: BALANCE_GRAVEYARD_DRAFT_HP_COST, unit_count: BALANCE_GRAVEYARD_DRAFT_UNIT_COUNT }
			);
			day_event_add(day_event_squad_selection_add(_draft_event, _undead_squads));

			var _deadlier_bones_event = day_event_squad_create(
				_graveyard,
				"deadlier_bones",
				"Deadlier Bones",
				"Permanently increase the damage of the selected Undead Squad by 15%.\nRequires 1 Cultist, who loses 30 HP.",
				BALANCE_SQUAD_PERMANENT_UPGRADE_CULTIST_COUNT,
				"increase_undead_squad_damage",
				day_event_squad_permanent_upgrade_execute,
				{ property_name: "damage_multiplier", multiplier: BALANCE_SQUAD_PERMANENT_UPGRADE_MULTIPLIER, hp_cost: BALANCE_SQUAD_PERMANENT_UPGRADE_HP_COST }
			);
			day_event_add(day_event_squad_selection_add(_deadlier_bones_event, _undead_squads));

			var _reinforced_remains_event = day_event_squad_create(
				_graveyard,
				"reinforced_remains",
				"Reinforced Remains",
				"Permanently increase the health of the selected Undead Squad by 15%.\nRequires 1 Cultist, who loses 30 HP.",
				BALANCE_SQUAD_PERMANENT_UPGRADE_CULTIST_COUNT,
				"increase_undead_squad_health",
				day_event_squad_permanent_upgrade_execute,
				{ property_name: "health_multiplier", multiplier: BALANCE_SQUAD_PERMANENT_UPGRADE_MULTIPLIER, hp_cost: BALANCE_SQUAD_PERMANENT_UPGRADE_HP_COST }
			);
			day_event_add(day_event_squad_selection_add(_reinforced_remains_event, _undead_squads));
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

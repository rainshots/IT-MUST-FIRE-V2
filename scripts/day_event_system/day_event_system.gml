/// @description Manages the current day's cultists and events.

// Find an uncompleted healing Blood Bath card offered today.
function day_event_personal_blood_bath_available()
{
	var _event_count = array_length(global.day_events);
	for (var _index = 0; _index < _event_count; ++_index)
	{
		var _event = global.day_events[_index];
		if (_event.is_resolved)
		{
			continue;
		}
		var _action_count = array_length(_event.actions);
		for (var _action_index = 0; _action_index < _action_count; ++_action_index)
		{
			if (_event.actions[_action_index].action_type == "blood_bath")
			{
				return true;
			}
		}
	}
	return false;
}

function day_event_personal_execute(_event, _cultists, _data)
{
	if (!instance_exists(_event.required_cultist) || _event.required_cultist.hp <= 0)
	{
		return false;
	}

	var _cannon = instance_find(o_cannon, 0);
	switch (_event.event_id)
	{
		case "cultist_scratch_breech":
			cannon_satisfaction_add(BALANCE_PERSONAL_RITE_SATISFACTION_GAIN);
			break;
		case "cultist_reinforce_carriage":
			if (instance_exists(_cannon))
			{
				_cannon.hp = min(_cannon.max_hp, _cannon.hp
					+ _cannon.max_hp * BALANCE_PERSONAL_RITE_CANNON_REPAIR_SHARE);
			}
			break;
		case "cultist_blood_stew":
			day_event_cultist_heal_apply(_event.required_cultist, BALANCE_PERSONAL_RITE_HEAL);
			break;
		case "cultist_sacrificial_knife":
			global.next_rite_hp_discount = BALANCE_PERSONAL_RITE_KNIFE_DISCOUNT;
			break;
		case "cultist_awaken_taint":
			if (instance_exists(o_game_controller))
			{
				var _controller = instance_find(o_game_controller, 0);
				_controller.cannon_projectile_queue_add(PROJECTILE_TYPE.CORRUPTION,
					{ personal_rite_daily_shell: true }, true);
			}
			break;
		case "cultist_virgin_blood":
			global.blood_bath_daily_heal_bonus = BALANCE_PERSONAL_RITE_BATH_BONUS;
			break;
		case "cultist_reawaken_spirit":
			_event.required_cultist.spirit = _event.required_cultist.max_spirit;
			break;
	}

	day_event_cultist_hp_cost_apply(_cultists, _data.hp_cost);
	return true;
}

function day_event_personal_generate()
{
	var _day = day_event_current_day_get();
	// Personal requests start on the second day, including generation during the morning transition.
	var _first_personal_event_day = 2;
	if (_day < _first_personal_event_day || global.cultist_event_generated_day == _day)
	{
		return false;
	}
	global.cultist_event_generated_day = _day;

	// Only living regular Cultists may author the daily request.
	var _authors = [];
	var _cultist_count = array_length(global.event_cultists);
	for (var _index = 0; _index < _cultist_count; ++_index)
	{
		var _cultist = global.event_cultists[_index];
		if (instance_exists(_cultist) && _cultist.hp > 0)
		{
			array_push(_authors, _cultist);
		}
	}
	if (array_length(_authors) == 0)
	{
		return false;
	}

	// HP costs are data for assignment previews, never part of the description.
	var _catalog = [
		{ event_id: "cultist_scratch_breech", title: "Scratch Behind the Breech",
			description: "The voices say it needs a scratch. Funny how they never volunteer their own fingers.\nSlightly increases Cannon Satisfaction (+7).", hp_cost: BALANCE_PERSONAL_RITE_HP_COST },
		{ event_id: "cultist_reinforce_carriage", title: "Reinforce the Carriage",
			description: "I spent all night listening to the carriage creak. Think I know where it'll give way.\nRestores a small amount of the Cannon's HP (+8% HP).", hp_cost: BALANCE_PERSONAL_RITE_HP_COST },
		{ event_id: "cultist_blood_stew", title: "Cook Blood Stew",
			description: "I summoned Grandma for her recipe. She said to add more blood and stop slouching.\nRestores 10 HP to the cultist.", hp_cost: 0 },
		{ event_id: "cultist_sacrificial_knife", title: "Prepare the Sacrificial Knife",
			description: "Found a sharper knife. Should save us a few screams today.\nReduces the next ritual's HP cost by 10 (not less than 0).", hp_cost: 0 },
		{ event_id: "cultist_awaken_taint", title: "Awaken the Taint",
			description: "The compost has started chanting. We should load it before it summons something.\nGain 1 Taint Compost shell for today.", hp_cost: 0 },
		{ event_id: "cultist_virgin_blood", title: "Virgin Blood",
			description: "I've set aside a vial of pure blood. Should come in handy for the bath.\nBlood Bath restores an additional 10 HP to each cultist on it today.", hp_cost: 0 },
		{ event_id: "cultist_reawaken_spirit", title: "Reawaken the Spirit",
			description: "Even my third eye has bags under it.\nReplenishes the Spirit to the maximum after performing the rite (still requires one Spirit to invoke).", hp_cost: BALANCE_PERSONAL_RITE_HP_COST }
	];
	var _candidates = [];
	var _cannon = instance_find(o_cannon, 0);
	var _catalog_count = array_length(_catalog);
	var _history_count = array_length(global.cultist_event_history);
	for (var _index = 0; _index < _catalog_count; ++_index)
	{
		var _entry = _catalog[_index];
		var _is_repeat = false;
		for (var _history_index = 0; _history_index < _history_count; ++_history_index)
		{
			var _previous = global.cultist_event_history[_history_index];
			if (_previous.day >= _day - BALANCE_PERSONAL_RITE_HISTORY_DAYS
				&& _previous.event_id == _entry.event_id)
			{
				_is_repeat = true;
				break;
			}
		}
		if (_is_repeat
			|| (_entry.event_id == "cultist_scratch_breech" && cannon_satisfaction_get() >= BALANCE_CANNON_SATISFACTION_MAX)
			|| (_entry.event_id == "cultist_reinforce_carriage" && (!instance_exists(_cannon) || _cannon.hp >= _cannon.max_hp))
			|| (_entry.event_id == "cultist_virgin_blood" && !day_event_personal_blood_bath_available()))
		{
			continue;
		}
		array_push(_candidates, _entry);
	}
	if (array_length(_candidates) == 0)
	{
		return false;
	}

	var _choice = _candidates[irandom(array_length(_candidates) - 1)];
	var _author = _authors[irandom(array_length(_authors) - 1)];
	var _event = new day_event_constructor(_choice.event_id, _choice.title, _choice.description, 1, 1,
		[new event_action_constructor(_choice.event_id, day_event_personal_execute, { hp_cost: _choice.hp_cost })]);
	_event.required_cultist = _author;
	_event.source_sprite = _author.sprite_index;
	_event.can_pin = false;
	_event.reroll_is_available = false;
	day_event_add(_event);
	array_push(global.cultist_event_history, { day: _day, event_id: _choice.event_id });
	if (array_length(global.cultist_event_history) > BALANCE_PERSONAL_RITE_HISTORY_DAYS)
	{
		array_delete(global.cultist_event_history, 0, 1);
	}
	return true;
}

function day_event_add(_event)
{
	if (!is_struct(_event))
	{
		return false;
	}

	array_push(global.day_events, _event);
	return true;
}

function day_event_damaged_building_hp_cost_get(_event)
{
	if (!is_struct(_event)
		|| !variable_struct_exists(_event, "source_building")
		|| !instance_exists(_event.source_building)
		|| !variable_instance_exists(_event.source_building, "player_building_event_hp_cost_get"))
	{
		return 0;
	}

	return _event.source_building.player_building_event_hp_cost_get();
}

function day_event_source_sprite_get(_event)
{
	if (!is_struct(_event))
	{
		return -1;
	}

	if (variable_struct_exists(_event, "source_sprite")
		&& sprite_exists(_event.source_sprite))
	{
		return _event.source_sprite;
	}

	if (variable_struct_exists(_event, "source_building")
		&& instance_exists(_event.source_building)
		&& sprite_exists(_event.source_building.sprite_index))
	{
		return _event.source_building.sprite_index;
	}

	return -1;
}

function day_event_mastery_source_building_get(_event)
{
	if (!is_struct(_event)
		|| variable_struct_exists(_event, "construction_site")
		|| !variable_struct_exists(_event, "source_building")
		|| !instance_exists(_event.source_building))
	{
		return noone;
	}

	var _source_building = _event.source_building;
	var _source_object = _source_building.object_index;
	// Blood Bath Rites remain in work history but never grant mastery or its discount.
	if (_source_object == o_meat_bath)
	{
		return noone;
	}

	var _is_player_building = _source_object == o_v13buildings_parent
		|| object_is_ancestor(_source_object, o_v13buildings_parent);

	return _is_player_building ? _source_building : noone;
}

function day_event_cultist_mastery_progress_add(_cultist, _event)
{
	if (!instance_exists(_cultist))
	{
		return false;
	}

	if (variable_instance_exists(_cultist, "mastery_building_object")
		&& _cultist.mastery_building_object == o_meat_bath)
	{
		// Retired Blood Bath specialists may earn a mastery in another building.
		_cultist.mastery_building_object = noone;
		_cultist.mastery_building_name = "";
		_cultist.mastery_building_sprite = noone;
	}

	if (variable_instance_exists(_cultist, "mastery_building_object")
		&& _cultist.mastery_building_object != noone)
	{
		return false;
	}

	var _building_object = day_event_mastery_building_object_get(_event);

	if (_building_object == noone)
	{
		return false;
	}

	if (!variable_instance_exists(_cultist, "building_work_counts")
		|| !is_array(_cultist.building_work_counts))
	{
		_cultist.building_work_counts = [];
	}

	var _building_work_counts = _cultist.building_work_counts;
	var _building_work_count_entry = noone;
	var _building_work_count_entry_count = array_length(_building_work_counts);

	for (var _entry_index = 0;
		_entry_index < _building_work_count_entry_count;
		++_entry_index)
	{
		var _entry = _building_work_counts[_entry_index];

		if (is_struct(_entry) && _entry.building_object == _building_object)
		{
			_building_work_count_entry = _entry;
			break;
		}
	}

	if (!is_struct(_building_work_count_entry))
	{
		_building_work_count_entry = {
			building_object: _building_object,
			work_count: 0,
			mastery_pending: false
		};
		array_push(_cultist.building_work_counts, _building_work_count_entry);
	}

	_building_work_count_entry.work_count++;

	if (_building_work_count_entry.work_count < BALANCE_CULTIST_MASTERY_WORK_COUNT
		|| (variable_struct_exists(_building_work_count_entry, "mastery_pending")
			&& _building_work_count_entry.mastery_pending)
		|| !instance_exists(o_game_controller))
	{
		return false;
	}

	// Construction offers retain their own identity after the completed site disappears.
	var _building_name = "Construction";
	var _building_sprite = s_build_icon;

	if (_building_object != o_building_slot)
	{
		var _source_building = _event.source_building;
		_building_name = variable_instance_exists(_source_building, "building_display_name")
			? _source_building.building_display_name
			: "";
		_building_sprite = variable_instance_exists(_source_building, "player_building_active_sprite")
			? _source_building.player_building_active_sprite
			: _source_building.sprite_index;

		if (_building_name == "")
		{
			_building_name = string_replace_all(object_get_name(_building_object), "_", " ");
		}
	}

	// Queue the offer once; qualifying never grants the HP discount automatically.
	var _controller = instance_find(o_game_controller, 0);
	_building_work_count_entry.mastery_pending = true;
	array_push(_controller.cultist_mastery_queue, {
		cultist: _cultist,
		building_object: _building_object,
		building_name: _building_name,
		building_sprite: _building_sprite,
		work_count_entry: _building_work_count_entry,
		available_day: day_event_current_day_get() + 1
	});
	return true;
}

// Requests retain building metadata so they are independent of the building's daily event pool.
function day_event_cultist_mastery_request_is_valid(_request)
{
	return is_struct(_request)
		&& instance_exists(_request.cultist)
		&& _request.cultist.mastery_building_object == noone
		&& _request.building_object != o_meat_bath
		&& _request.work_count_entry.work_count >= BALANCE_CULTIST_MASTERY_WORK_COUNT;
}

function day_event_cultist_mastery_execute(_event, _assigned_cultists, _data)
{
	var _request = _event.mastery_request;
	if (!day_event_cultist_mastery_request_is_valid(_request)
		|| array_length(_assigned_cultists) != 1
		|| _assigned_cultists[0] != _request.cultist
		|| _request.cultist.hp <= 0)
	{
		return false;
	}

	// This explicit choice is the only place that awards a new permanent Mastery.
	var _cultist = _request.cultist;
	_cultist.mastery_building_object = _request.building_object;
	_cultist.mastery_building_name = _request.building_name;
	_cultist.mastery_building_sprite = _request.building_sprite;
	_request.work_count_entry.mastery_pending = false;
	day_event_pin_clear(_event);
	return true;
}

function day_event_cultist_mastery_generate()
{
	if (!instance_exists(o_game_controller))
	{
		return false;
	}

	var _controller = instance_find(o_game_controller, 0);
	var _day = day_event_current_day_get();
	if (_controller.cultist_mastery_generated_day == _day)
	{
		return false;
	}

	// A pinned offer occupies tomorrow's Mastery slot before any queued request.
	var _event = _controller.cultist_mastery_event;
	if (is_struct(_event))
	{
		if (!_event.is_resolved && day_event_cultist_mastery_request_is_valid(_event.mastery_request))
		{
			day_event_pin_clear(_event, false);
			_event.is_pinned_event = false;
			day_event_add(_event);
			_controller.cultist_mastery_generated_day = _day;
			return true;
		}

		day_event_pin_clear(_event, false);
		_controller.cultist_mastery_event = noone;
	}

	// Drop obsolete requests without spending the daily offer; preserve FIFO order for the rest.
	var _queue = _controller.cultist_mastery_queue;
	var _queue_count = array_length(_queue);
	for (var _queue_index = 0; _queue_index < _queue_count; ++_queue_index)
	{
		var _request = _queue[_queue_index];
		if (!day_event_cultist_mastery_request_is_valid(_request))
		{
			_request.work_count_entry.mastery_pending = false;
			continue;
		}

		if (_request.available_day > _day)
		{
			array_delete(_controller.cultist_mastery_queue, 0, _queue_index);
			return false;
		}

		var _flavor = "The powers below recognize the taste of my blood by now. Perhaps we can negotiate smaller portions.";
		var _is_construction_mastery = _request.building_object == o_building_slot;
		var _benefit = _is_construction_mastery
			? "All construction costs this cultist " + string(BALANCE_CULTIST_MASTERY_HP_DISCOUNT) + " HP less."
			: "All events at " + _request.building_name
				+ " cost this cultist -" + string(BALANCE_CULTIST_MASTERY_HP_DISCOUNT) + "HP.";
		_event = new day_event_constructor(
			"cultist_mastery_" + string(_request.cultist.id) + "_" + string(_request.building_object),
			"Cultist Mastery",
			_flavor + "\n" + _benefit,
			1,
			1,
			[new event_action_constructor("cultist_mastery", day_event_cultist_mastery_execute, { hp_cost: 0 })]
		);
		_event.is_cultist_mastery = true;
		_event.mastery_request = _request;
		_event.mastery_flavor_text = _flavor;
		_event.required_cultist = _request.cultist;
		_event.source_building = noone;
		_event.source_sprite = _request.building_sprite;
		_event.can_pin = true;
		_event.reroll_is_available = false;
		_event.hp_cost_modifiers_ignored = true;
		_controller.cultist_mastery_event = _event;
		_controller.cultist_mastery_generated_day = _day;
		array_delete(_controller.cultist_mastery_queue, 0, _queue_index + 1);
		day_event_add(_event);
		return true;
	}

	_controller.cultist_mastery_queue = [];
	return false;
}

function day_event_cultist_mastery_finish_day()
{
	if (!instance_exists(o_game_controller))
	{
		return;
	}

	var _controller = instance_find(o_game_controller, 0);
	var _event = _controller.cultist_mastery_event;
	if (!is_struct(_event))
	{
		return;
	}

	// Only a displayed, unfinished, unpinned offer counts as ignored; waiting requests keep progress.
	if (!_event.is_resolved && day_event_cultist_mastery_request_is_valid(_event.mastery_request))
	{
		if (day_event_pin_is_event(_event))
		{
			return;
		}

		_event.mastery_request.work_count_entry.work_count = BALANCE_CULTIST_MASTERY_IGNORED_WORK_COUNT;
		_event.mastery_request.work_count_entry.mastery_pending = false;
	}

	day_event_pin_clear(_event, false);
	_controller.cultist_mastery_event = noone;
}

// Mandatory maintenance and Mastery acceptance keep their advertised zero-HP cost.
function day_event_hp_cost_modifiers_are_ignored(_event)
{
	return is_struct(_event)
		&& ((variable_struct_exists(_event, "is_overuse_event") && _event.is_overuse_event)
			|| (variable_struct_exists(_event, "hp_cost_modifiers_ignored") && _event.hp_cost_modifiers_ignored));
}

function day_event_cultist_mastery_hp_discount_get(_cultist, _event)
{
	if (!instance_exists(_cultist)
		|| !variable_instance_exists(_cultist, "mastery_building_object")
		|| _cultist.mastery_building_object == noone)
	{
		return 0;
	}

	var _building_object = day_event_mastery_building_object_get(_event);

	return _building_object != noone
		&& _building_object == _cultist.mastery_building_object
		? BALANCE_CULTIST_MASTERY_HP_DISCOUNT
		: 0;
}

function day_event_cultist_work_history_add(_cultist, _event)
{
	if (!instance_exists(_cultist) || !is_struct(_event))
	{
		return false;
	}

	// Construction advances Mastery only after creating the building successfully.
	if (!variable_struct_exists(_event, "construction_site"))
	{
		day_event_cultist_mastery_progress_add(_cultist, _event);
	}

	var _source_sprite = day_event_source_sprite_get(_event);

	if (!sprite_exists(_source_sprite))
	{
		return false;
	}

	if (!variable_instance_exists(_cultist, "work_history")
		|| !is_array(_cultist.work_history))
	{
		_cultist.work_history = [];
	}

	array_push(_cultist.work_history, _source_sprite);
	return true;
}

function day_event_add_first(_event)
{
	if (!is_struct(_event))
	{
		return false;
	}

	array_insert(global.day_events, 0, _event);
	return true;
}

function day_event_move_to_end(_event_id)
{
	var _event_count = array_length(global.day_events);

	for (var _event_index = 0; _event_index < _event_count; ++_event_index)
	{
		var _event = global.day_events[_event_index];

		if (!is_struct(_event)
			|| !variable_struct_exists(_event, "event_id")
			|| _event.event_id != _event_id)
		{
			continue;
		}

		if (_event_index < _event_count - 1)
		{
			array_delete(global.day_events, _event_index, 1);
			array_push(global.day_events, _event);
		}

		return true;
	}

	return false;
}

function day_event_available_cultist_find(_prefer_lowest_hp = false)
{
	var _selected_cultist = noone;
	var _selected_hp = _prefer_lowest_hp ? infinity : -infinity;

	// Auto-assignment only considers currently available cultists.
	for (var _cultist_index = 0; _cultist_index < array_length(global.event_cultists); ++_cultist_index)
	{
		var _cultist = global.event_cultists[_cultist_index];

		if (!instance_exists(_cultist)
			|| is_struct(_cultist.assigned_event)
			|| !variable_instance_exists(_cultist, "hp")
			|| !variable_instance_exists(_cultist, "is_available")
			|| !_cultist.is_available())
		{
			continue;
		}

		var _is_better_candidate = _prefer_lowest_hp
			? _cultist.hp < _selected_hp
			: _cultist.hp > _selected_hp;

		if (_is_better_candidate)
		{
			_selected_cultist = _cultist;
			_selected_hp = _cultist.hp;
		}
	}

	return _selected_cultist;
}

function day_event_affects_unconscious_cultists(_data)
{
	return is_struct(_data)
		&& variable_struct_exists(_data, "affects_unconscious_cultists")
		&& _data.affects_unconscious_cultists;
}

function day_event_cultist_unconscious_enter(_cultist)
{
	if (!instance_exists(_cultist)
		|| !variable_instance_exists(_cultist, "hp")
		|| _cultist.hp > 0)
	{
		return false;
	}

	var _was_unconscious = variable_instance_exists(_cultist, "is_unconscious")
		&& _cultist.is_unconscious;

	if (!_was_unconscious)
	{
		_cultist.is_unconscious = true;
		_cultist.unconscious_mornings = 0;
	}

	if (variable_instance_exists(_cultist, "is_being_dragged"))
	{
		_cultist.is_being_dragged = false;
	}

	if (variable_global_exists("dragged_cultist") && global.dragged_cultist == _cultist)
	{
		global.dragged_cultist = noone;
	}

	// Explain the first actual collapse; the tutorial controller suppresses repeat hints.
	if (!_was_unconscious && variable_global_exists("tutorial_hint_trigger"))
	{
		global.tutorial_hint_trigger("cultist_recovery");
	}

	return !_was_unconscious;
}

function day_event_cultist_assignment_release(_cultist)
{
	if (!instance_exists(_cultist)
		|| !variable_instance_exists(_cultist, "assigned_event")
		|| !is_struct(_cultist.assigned_event))
	{
		return false;
	}

	var _assigned_event = _cultist.assigned_event;

	if (variable_struct_exists(_assigned_event, "cultist_unassign"))
	{
		return _assigned_event.cultist_unassign(_cultist);
	}

	_cultist.assigned_event = noone;
	return true;
}

function day_event_cultist_damage_apply(_cultist, _amount, _release_assignment = true)
{
	if (!instance_exists(_cultist) || !variable_instance_exists(_cultist, "hp"))
	{
		return 0;
	}

	// Automatic debug Rites keep real participation and rewards without charging worker HP.
	if (variable_instance_exists(_cultist, "debug_day_progress_hp_cost_ignored")
		&& _cultist.debug_day_progress_hp_cost_ignored)
	{
		return 0;
	}

	var _damage = max(0, _amount);
	var _mastery_discount_remaining = variable_instance_exists(
		_cultist,
		"event_mastery_hp_discount_remaining"
	)
		? max(0, _cultist.event_mastery_hp_discount_remaining)
		: 0;
	var _mastery_discount = min(_damage, _mastery_discount_remaining);

	// One mastery discount is shared by every HP cost within the current Rite.
	if (_mastery_discount > 0)
	{
		_damage -= _mastery_discount;
		_cultist.event_mastery_hp_discount_remaining -= _mastery_discount;
	}

	// The prepared knife is consumed across all costs in the next executed Rite only.
	var _knife_discount = min(_damage, _cultist.event_knife_hp_discount_remaining);
	_damage -= _knife_discount;
	_cultist.event_knife_hp_discount_remaining -= _knife_discount;
	_cultist.hp -= _damage;

	if (_cultist.hp <= 0)
	{
		day_event_cultist_unconscious_enter(_cultist);

		if (_release_assignment)
		{
			day_event_cultist_assignment_release(_cultist);
		}
	}

	return _damage;
}

function day_event_cultist_heal_apply(_cultist, _amount, _affects_unconscious_cultists = false)
{
	if (!instance_exists(_cultist)
		|| !variable_instance_exists(_cultist, "hp")
		|| !variable_instance_exists(_cultist, "max_hp"))
	{
		return 0;
	}

	var _is_unconscious = (variable_instance_exists(_cultist, "is_unconscious")
		&& _cultist.is_unconscious)
		|| _cultist.hp <= 0;

	if (_is_unconscious)
	{
		day_event_cultist_unconscious_enter(_cultist);

		if (!_affects_unconscious_cultists)
		{
			return 0;
		}
	}

	var _previous_hp = _cultist.hp;
	_cultist.hp = min(_cultist.max_hp, _cultist.hp + max(0, _amount));

	if (_cultist.hp > 0 && variable_instance_exists(_cultist, "is_unconscious"))
	{
		_cultist.is_unconscious = false;
		_cultist.unconscious_mornings = 0;
	}

	return _cultist.hp - _previous_hp;
}

function day_event_cultist_unconscious_morning_update()
{
	var _cultist_count = array_length(global.event_cultists);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.event_cultists[_cultist_index];

		if (!instance_exists(_cultist)
			|| !variable_instance_exists(_cultist, "hp")
			|| !variable_instance_exists(_cultist, "max_hp"))
		{
			continue;
		}

		if (_cultist.hp <= 0)
		{
			day_event_cultist_unconscious_enter(_cultist);
		}

		if (!variable_instance_exists(_cultist, "is_unconscious") || !_cultist.is_unconscious)
		{
			continue;
		}

		var _unconscious_mornings = variable_instance_exists(_cultist, "unconscious_mornings")
			? max(0, floor(_cultist.unconscious_mornings))
			: 0;
		var _recovery_starts = _unconscious_mornings
			>= BALANCE_EVENT_CULTIST_UNCONSCIOUS_RECOVERY_DELAY_MORNINGS;
		_cultist.unconscious_mornings = _unconscious_mornings + 1;

		if (_recovery_starts)
		{
			day_event_cultist_heal_apply(
				_cultist,
				BALANCE_EVENT_CULTIST_UNCONSCIOUS_RECOVERY_HP,
				true
			);
		}
	}

	return true;
}

function day_event_building_construction_execute(_event, _assigned_cultists, _data)
{
	if (!is_struct(_data)
		|| !variable_struct_exists(_data, "construction_site")
		|| !instance_exists(_data.construction_site)
		|| !variable_struct_exists(_data, "building_object"))
	{
		return false;
	}

	var _construction_site = _data.construction_site;
	var _built_object = instance_create_layer(
		_construction_site.x,
		_construction_site.y,
		"Instances",
		_data.building_object
	);

	if (!instance_exists(_built_object))
	{
		return false;
	}

	_built_object.depth = _data.is_cursed_point
		? -floor(_built_object.y)
		: _construction_site.depth;

	if (_data.is_cursed_point)
	{
		if (variable_instance_exists(_built_object, "building_constructed_by_cursed_point"))
		{
			_built_object.building_constructed_by_cursed_point = true;
		}

		_built_object.cursed_point_restore_choice = _data.choice;

		if (variable_instance_exists(_built_object, "tower_capture_enabled"))
		{
			_built_object.tower_capture_enabled = true;
		}

		if (variable_instance_exists(_built_object, "is_captured"))
		{
			_built_object.is_captured = true;
		}

		if (variable_instance_exists(_built_object, "max_corruption")
			&& variable_instance_exists(_built_object, "corruption"))
		{
			_built_object.corruption = _built_object.max_corruption;
		}

		if (variable_instance_exists(_built_object, "captured_sprite_index")
			&& _built_object.captured_sprite_index != noone)
		{
			_built_object.sprite_index = _built_object.captured_sprite_index;
			_built_object.image_index = 0;
			_built_object.image_speed = 0;
		}

		// Special-point structures always enter play with their full permanent health.
		if (variable_instance_exists(_built_object, "player_building_health_restore_full"))
		{
			_built_object.player_building_health_restore_full();
		}

		if (variable_instance_exists(_construction_site, "cursed_point_construction_effect_create"))
		{
			_construction_site.cursed_point_construction_effect_create();
		}

		// Send surviving construction workers back to their cannon-side homes for the night.
		var _assigned_cultist_count = array_length(_assigned_cultists);

		for (var _assigned_cultist_index = 0; _assigned_cultist_index < _assigned_cultist_count; ++_assigned_cultist_index)
		{
			var _assigned_cultist = _assigned_cultists[_assigned_cultist_index];

			if (instance_exists(_assigned_cultist)
				&& variable_instance_exists(_assigned_cultist, "return_to_cannon_at_night"))
			{
				_assigned_cultist.return_to_cannon_at_night = true;
			}
		}
	}
	else
	{
		if (variable_instance_exists(_built_object, "garrison_morning_spawn_units"))
		{
			_built_object.garrison_morning_spawn_units();
		}

		if (_built_object.object_index == o_goblins_pit && instance_exists(o_game_controller))
		{
			var _game_controller = instance_find(o_game_controller, 0);

			if (variable_instance_exists(_game_controller, "starting_goblins_bind_to_first_pit"))
			{
				_game_controller.starting_goblins_bind_to_first_pit(_built_object);
			}
		}

		if (variable_global_exists("construction_sound_play"))
		{
			global.construction_sound_play();
		}

		if (variable_global_exists("tutorial_hint_trigger"))
		{
			global.tutorial_hint_trigger("workers");
		}
	}

	// Credit each successful participant before HP costs or site removal can invalidate the source.
	var _construction_cultist_count = array_length(_assigned_cultists);

	for (var _cultist_index = 0; _cultist_index < _construction_cultist_count; ++_cultist_index)
	{
		day_event_cultist_mastery_progress_add(_assigned_cultists[_cultist_index], _event);
	}

	// Every successful construction charges its assigned workers the displayed HP cost.
	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);

	// Trap Points persist after construction so they can restore their bound trap every morning.
	if (variable_instance_exists(_construction_site, "construction_site_complete"))
	{
		_construction_site.construction_site_complete(_built_object, _data.choice);
	}
	else
	{
		instance_destroy(_construction_site);
	}

	// Offer the finished building's first Rite during the current day.
	day_event_building_events_add(_built_object);

	return true;
}

function day_event_building_construction_can_start()
{
	if (!variable_global_exists("building_construction_count_today"))
	{
		return false;
	}

	return global.building_construction_count_today < BALANCE_BUILDING_CONSTRUCTION_DAILY_LIMIT;
}

function day_event_building_construction_type_count_get(_building_object)
{
	var _building_count = instance_number(_building_object);

	if (!variable_global_exists("day_events"))
	{
		return _building_count;
	}

	// Pending construction events reserve the building type before the structure appears.
	var _event_count = array_length(global.day_events);

	for (var _event_index = 0; _event_index < _event_count; ++_event_index)
	{
		var _event = global.day_events[_event_index];

		if (!is_struct(_event)
			|| !variable_struct_exists(_event, "actions")
			|| array_length(_event.actions) <= 0)
		{
			continue;
		}

		var _action = _event.actions[0];

		if (is_struct(_action)
			&& variable_struct_exists(_action, "action_type")
			&& _action.action_type == "construct_building"
			&& variable_struct_exists(_action, "data")
			&& is_struct(_action.data)
			&& variable_struct_exists(_action.data, "building_object")
			&& _action.data.building_object == _building_object)
		{
			_building_count++;
		}
	}

	return _building_count;
}

function day_event_building_construction_create(_construction_site, _choice, _is_cursed_point = false)
{
	if (!instance_exists(_construction_site)
		|| !is_struct(_choice)
		|| !variable_struct_exists(_choice, "building_object"))
	{
		return noone;
	}

	// Duplicate limits apply only to regular settlement buildings, never to Cursed Point towers.
	if (!_is_cursed_point
		&& BALANCE_BUILDING_DUPLICATE_LIMIT_ENABLED
		&& day_event_building_construction_type_count_get(_choice.building_object) >= BALANCE_BUILDING_DEFAULT_LIMIT)
	{
		return noone;
	}

	if (!_is_cursed_point && !day_event_building_construction_can_start())
	{
		return noone;
	}

	var _building_name = variable_struct_exists(_choice, "building_name")
		? _choice.building_name
		: object_get_name(_choice.building_object);
	var _event = new day_event_constructor(
		"construct_building_" + string(_construction_site),
		"Summon " + _building_name,
		"Summon " + _building_name + ".",
		BALANCE_BUILDING_CONSTRUCTION_CULTIST_COST,
		1,
		[
			new event_action_constructor(
				"construct_building",
				day_event_building_construction_execute,
				{
					construction_site: _construction_site,
					hp_cost: BALANCE_BUILDING_CONSTRUCTION_CULTIST_HP_COST,
					building_object: _choice.building_object,
					choice: _choice,
					is_cursed_point: _is_cursed_point
				}
			)
		]
	);

	_event.source_building = _construction_site;
	_event.source_sprite = variable_struct_exists(_choice, "building_sprite")
		? _choice.building_sprite
		: object_get_sprite(_choice.building_object);
	_event.construction_site = _construction_site;
	_event.is_cursed_point_construction = _is_cursed_point;
	_construction_site.construction_event_pending = true;
	day_event_add_first(_event);

	if (!_is_cursed_point)
	{
		global.building_construction_count_today++;
	}

	// The player assigns construction workers after the card appears.
	return _event;
}

function day_event_cultist_hp_share_cost_apply(_assigned_cultists, _hp_share)
{
	for (var _cultist_index = 0; _cultist_index < array_length(_assigned_cultists); ++_cultist_index)
	{
		var _cultist = _assigned_cultists[_cultist_index];

		if (instance_exists(_cultist)
			&& variable_instance_exists(_cultist, "hp")
			&& variable_instance_exists(_cultist, "max_hp"))
		{
			var _hp_cost = _cultist.max_hp * max(0, _hp_share);
			day_event_cultist_damage_apply(_cultist, _hp_cost, false);
		}
	}
}

// Shared by execution and previews so slot costs stay identical after assignment changes.
function day_event_action_slot_hp_cost_get(_data, _slot_index)
{
	var _hp_cost = variable_struct_exists(_data, "hp_cost") ? _data.hp_cost : 0;
	// Recruitment retains its explicit slot field; ordinary building actions store a cost array.
	if (variable_struct_exists(_data, "hp_cost_by_slot") && is_array(_data.hp_cost_by_slot))
	{
		_hp_cost = _data.hp_cost_by_slot;
	}

	if (is_array(_hp_cost))
	{
		var _slot_count = array_length(_hp_cost);
		if (_slot_count > 0 && _slot_index >= 0)
		{
			return max(0, _hp_cost[_slot_index mod _slot_count]);
		}
		return 0;
	}

	return max(0, _hp_cost);
}

// All event callbacks share this path for either a flat per-worker cost or individual slot costs.
function day_event_cultist_hp_cost_apply(_assigned_cultists, _hp_cost)
{
	var _cost_data = { hp_cost: _hp_cost };
	var _cultist_count = array_length(_assigned_cultists);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = _assigned_cultists[_cultist_index];

		if (instance_exists(_cultist) && variable_instance_exists(_cultist, "hp"))
		{
			// Event costs always affect the assigned cultist, independently of combat damage handling.
			var _slot_hp_cost = day_event_action_slot_hp_cost_get(_cost_data, _cultist_index);
			day_event_cultist_damage_apply(_cultist, _slot_hp_cost, false);
		}
	}
}

function day_event_building_cost_is_eligible(_event)
{
	if (!is_struct(_event)
		|| !variable_struct_exists(_event, "source_building")
		|| !instance_exists(_event.source_building)
		|| _event.is_resolved
		|| variable_struct_exists(_event, "construction_site")
		|| variable_struct_exists(_event, "squad_point")
		|| (variable_struct_exists(_event, "reserves_squad_slot") && _event.reserves_squad_slot)
		|| (variable_struct_exists(_event, "is_overuse_event") && _event.is_overuse_event))
	{
		return false;
	}

	// Recruitment, Blood Bath, personal offers and world Jobs retain their own prices.
	var _action_count = array_length(_event.actions);
	for (var _action_index = 0; _action_index < _action_count; ++_action_index)
	{
		if (_event.actions[_action_index].action_type == "summon_squad")
		{
			return false;
		}
	}

	switch (_event.source_building.object_index)
	{
		case o_pitlings_pit2:
		case o_graveyard2:
		case o_unholy_shrine:
		case o_foundry:
		case o_summoning_grounds:
		case o_shell_factory:
			return true;
	}
	return false;
}

function day_event_building_cost_type_roll()
{
	var _a_weight = BALANCE_BUILDING_EVENT_COST_RANDOM_A_WEIGHT;
	var _b_weight = BALANCE_BUILDING_EVENT_COST_RANDOM_B_WEIGHT;
	var _c_weight = BALANCE_BUILDING_EVENT_COST_RANDOM_C_WEIGHT;
	var _roll = irandom(_a_weight + _b_weight + _c_weight - 1);
	if (_roll < _a_weight)
	{
		return BUILDING_EVENT_COST_TYPE.A;
	}
	return _roll < _a_weight + _b_weight ? BUILDING_EVENT_COST_TYPE.B : BUILDING_EVENT_COST_TYPE.C;
}

function day_event_building_cost_apply(_event, _cost_type)
{
	if (!day_event_building_cost_is_eligible(_event))
	{
		return false;
	}

	var _cultist_count = BALANCE_BUILDING_EVENT_COST_A_CULTIST_COUNT;
	var _total_hp_min = BALANCE_BUILDING_EVENT_COST_A_TOTAL_HP_MIN;
	var _total_hp_max = BALANCE_BUILDING_EVENT_COST_A_TOTAL_HP_MAX;
	switch (_cost_type)
	{
		case BUILDING_EVENT_COST_TYPE.B:
			_cultist_count = BALANCE_BUILDING_EVENT_COST_B_CULTIST_COUNT;
			_total_hp_min = BALANCE_BUILDING_EVENT_COST_B_TOTAL_HP_MIN;
			_total_hp_max = BALANCE_BUILDING_EVENT_COST_B_TOTAL_HP_MAX;
			break;
		case BUILDING_EVENT_COST_TYPE.C:
			_cultist_count = BALANCE_BUILDING_EVENT_COST_C_CULTIST_COUNT;
			_total_hp_min = BALANCE_BUILDING_EVENT_COST_C_TOTAL_HP_MIN;
			_total_hp_max = BALANCE_BUILDING_EVENT_COST_C_TOTAL_HP_MAX;
			break;
	}

	// Split one shared HP budget in increments of five; zero and equal slot costs are allowed.
	var _hp_step = BALANCE_BUILDING_EVENT_COST_HP_STEP;
	var _remaining_units = irandom_range(_total_hp_min div _hp_step, _total_hp_max div _hp_step);
	var _slot_costs = array_create(_cultist_count, 0);
	for (var _slot_index = 0; _slot_index < _cultist_count; ++_slot_index)
	{
		var _slot_units = _slot_index == _cultist_count - 1 ? _remaining_units : irandom(_remaining_units);
		_slot_costs[_slot_index] = _slot_units * _hp_step;
		_remaining_units -= _slot_units;
	}

	// Shuffle shares so the final remainder is not consistently charged to the last worker.
	for (var _shuffle_index = _cultist_count - 1; _shuffle_index > 0; --_shuffle_index)
	{
		var _swap_index = irandom(_shuffle_index);
		var _swap_cost = _slot_costs[_shuffle_index];
		_slot_costs[_shuffle_index] = _slot_costs[_swap_index];
		_slot_costs[_swap_index] = _swap_cost;
	}

	// Charge the card's price once even when a Rite has several cost-bearing actions.
	var _cost_assigned = false;
	var _action_count = array_length(_event.actions);
	for (var _action_index = 0; _action_index < _action_count; ++_action_index)
	{
		var _data = _event.actions[_action_index].data;
		if (is_struct(_data) && variable_struct_exists(_data, "hp_cost"))
		{
			_data.hp_cost = _cost_assigned ? 0 : _slot_costs;
			_cost_assigned = true;
		}
	}

	if (!_cost_assigned)
	{
		return false;
	}
	_event.building_cost_type = _cost_type;
	_event.cultist_cost = _cultist_count;
	_event.execution_cultist_minimum = _cultist_count * _event.activation_limit;
	return true;
}

function day_event_building_costs_morning_apply(_events)
{
	var _candidates = [];
	var _event_count = array_length(_events);
	for (var _event_index = 0; _event_index < _event_count; ++_event_index)
	{
		var _event = _events[_event_index];
		if (day_event_building_cost_is_eligible(_event)
			&& !variable_struct_exists(_event, "building_cost_type"))
		{
			array_push(_candidates, _event);
		}
	}

	var _candidate_count = array_length(_candidates);
	if (_candidate_count <= 0)
	{
		return;
	}

	// Pick recipients fairly across buildings, then reserve at most one morning type C.
	for (var _shuffle_index = _candidate_count - 1; _shuffle_index > 0; --_shuffle_index)
	{
		var _swap_index = irandom(_shuffle_index);
		var _swap_event = _candidates[_shuffle_index];
		_candidates[_shuffle_index] = _candidates[_swap_index];
		_candidates[_swap_index] = _swap_event;
	}
	var _c_count = random(1) < BALANCE_BUILDING_EVENT_COST_MORNING_C_CHANCE
		? min(_candidate_count, BALANCE_BUILDING_EVENT_COST_MORNING_C_LIMIT)
		: 0;
	var _a_count = min(_candidate_count - _c_count,
		ceil(_candidate_count * BALANCE_BUILDING_EVENT_COST_MORNING_A_SHARE));
	for (var _candidate_index = 0; _candidate_index < _candidate_count; ++_candidate_index)
	{
		var _cost_type = BUILDING_EVENT_COST_TYPE.B;
		if (_candidate_index < _c_count)
		{
			_cost_type = BUILDING_EVENT_COST_TYPE.C;
		}
		else if (_candidate_index < _c_count + _a_count)
		{
			_cost_type = BUILDING_EVENT_COST_TYPE.A;
		}
		day_event_building_cost_apply(_candidates[_candidate_index], _cost_type);
	}
}

function day_event_building_costs_random_apply(_events)
{
	var _event_count = array_length(_events);
	for (var _event_index = 0; _event_index < _event_count; ++_event_index)
	{
		var _event = _events[_event_index];
		if (day_event_building_cost_is_eligible(_event)
			&& !variable_struct_exists(_event, "building_cost_type"))
		{
			day_event_building_cost_apply(_event, day_event_building_cost_type_roll());
		}
	}
}

function day_event_cannon_demand_reward_apply(_reward)
{
	cannon_satisfaction_add(max(0, _reward));
	return true;
}

function day_event_cannon_broken_toy_cultist_is_eligible(_cultist)
{
	return instance_exists(_cultist)
		&& variable_instance_exists(_cultist, "hp")
		&& variable_instance_exists(_cultist, "max_hp")
		&& _cultist.hp > 0
		&& _cultist.hp < _cultist.max_hp * BALANCE_CANNON_DEMAND_BROKEN_TOY_MAX_HP_SHARE;
}

function day_event_cannon_broken_toy_is_available()
{
	if (!variable_global_exists("event_cultists") || !is_array(global.event_cultists))
	{
		return false;
	}

	// The demand can only appear when the player has a valid Cultist for it.
	var _cultist_count = array_length(global.event_cultists);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.event_cultists[_cultist_index];

		if (day_event_cannon_broken_toy_cultist_is_eligible(_cultist))
		{
			return true;
		}
	}

	return false;
}

function day_event_cannon_broken_toy_execute(_event, _assigned_cultists, _data)
{
	if (array_length(_assigned_cultists) <= 0)
	{
		return false;
	}

	var _cultist = _assigned_cultists[0];

	if (!instance_exists(_cultist))
	{
		return false;
	}

	day_event_cultist_heal_apply(_cultist, _cultist.max_hp);
	return day_event_cannon_demand_reward_apply(_data.reward);
}

function day_event_cannon_let_me_choose_execute(_event, _assigned_cultists, _data)
{
	if (array_length(_assigned_cultists) < 2)
	{
		return false;
	}

	var _healed_index = irandom(1);
	var _damaged_index = 1 - _healed_index;
	var _healed_cultist = _assigned_cultists[_healed_index];
	var _damaged_cultist = _assigned_cultists[_damaged_index];

	if (instance_exists(_healed_cultist))
	{
		day_event_cultist_heal_apply(_healed_cultist, _data.heal_amount);
	}

	if (instance_exists(_damaged_cultist))
	{
		day_event_cultist_damage_apply(_damaged_cultist, _data.damage_amount, false);
	}

	return day_event_cannon_demand_reward_apply(_data.reward);
}

function day_event_cannon_pick_favorite_execute(_event, _assigned_cultists, _data)
{
	var _cultist_count = array_length(_assigned_cultists);

	if (_cultist_count < 3)
	{
		return false;
	}

	var _favorite_index = irandom(_cultist_count - 1);

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = _assigned_cultists[_cultist_index];

		if (!instance_exists(_cultist))
		{
			continue;
		}

		if (_cultist_index == _favorite_index)
		{
			day_event_cultist_heal_apply(_cultist, _data.heal_amount);
		}
		else
		{
			day_event_cultist_damage_apply(_cultist, _data.damage_amount, false);
		}
	}

	return day_event_cannon_demand_reward_apply(_data.reward);
}

function day_event_cannon_tiny_bite_execute(_event, _assigned_cultists, _data)
{
	if (array_length(_assigned_cultists) <= 0)
	{
		return false;
	}

	var _cultist = _assigned_cultists[0];
	var _damage = irandom_range(_data.damage_min, _data.damage_max);

	if (instance_exists(_cultist))
	{
		day_event_cultist_damage_apply(_cultist, _damage, false);
	}

	return day_event_cannon_demand_reward_apply(_data.reward);
}

function day_event_cannon_fixed_damage_execute(_event, _assigned_cultists, _data)
{
	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return day_event_cannon_demand_reward_apply(_data.reward);
}

function day_event_cannon_polish_teeth_execute(_event, _assigned_cultists, _data)
{
	return day_event_cannon_demand_reward_apply(_data.reward);
}

function day_event_cannon_demand_create(_demand_index, _required_cultist = noone)
{
	if (!instance_exists(o_cannon))
	{
		return noone;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _event = noone;

	switch (_demand_index)
	{
		case 0:
			_event = new day_event_constructor(
				"cannon_demand_broken_toy",
				"A Broken Toy",
				"Bring me a broken one. I know how to fix toys. Only Cultists below 40% HP are eligible; the chosen Cultist fully restores HP.\nReward: +10 Cannon Satisfaction. Ignored: -10.",
				1,
				1,
				[
					new event_action_constructor(
						"cannon_broken_toy",
						day_event_cannon_broken_toy_execute,
						{ reward: BALANCE_CANNON_DEMAND_BROKEN_TOY_REWARD }
					)
				]
			);
			_event.ignored_satisfaction_penalty = BALANCE_CANNON_DEMAND_BROKEN_TOY_IGNORED_PENALTY;
			_event.cultist_is_eligible = day_event_cannon_broken_toy_cultist_is_eligible;
			break;

		case 1:
			_event = new day_event_constructor(
				"cannon_demand_let_me_choose",
				"Let Me Choose",
				"I choose one Cultist to restore 30 HP; another pays the price.\nReward: +25 Cannon Satisfaction. Ignored: -15.",
				2,
				1,
				[
					new event_action_constructor(
						"cannon_let_me_choose",
						day_event_cannon_let_me_choose_execute,
						{
							reward: BALANCE_CANNON_DEMAND_LET_ME_CHOOSE_REWARD,
							heal_amount: BALANCE_CANNON_DEMAND_LET_ME_CHOOSE_HEAL,
							damage_amount: BALANCE_CANNON_DEMAND_LET_ME_CHOOSE_DAMAGE
						}
					)
				]
			);
			_event.ignored_satisfaction_penalty = BALANCE_CANNON_DEMAND_LET_ME_CHOOSE_IGNORED_PENALTY;
			break;

		case 2:
			_event = new day_event_constructor(
				"cannon_demand_pick_favorite",
				"Pick a Favorite",
				"Bring me three. One gets to be my favorite (+50 HP). The others pay for it (-10 HP).\nReward: +30 Cannon Satisfaction.\nIf ignored: -10 Cannon Satisfaction.",
				3,
				1,
				[
					new event_action_constructor(
						"cannon_pick_favorite",
						day_event_cannon_pick_favorite_execute,
						{
							reward: BALANCE_CANNON_DEMAND_PICK_FAVORITE_REWARD,
							heal_amount: BALANCE_CANNON_DEMAND_PICK_FAVORITE_HEAL,
							damage_amount: BALANCE_CANNON_DEMAND_PICK_FAVORITE_DAMAGE
						}
					)
				]
			);
			_event.ignored_satisfaction_penalty = BALANCE_CANNON_DEMAND_PICK_FAVORITE_IGNORED_PENALTY;
			break;

		case 3:
			_event = new day_event_constructor(
				"cannon_demand_tiny_bite",
				"A Tiny Bite",
				"I only want a little taste.\nReward: +20 Cannon Satisfaction. Ignored: -15.",
				1,
				1,
				[
					new event_action_constructor(
						"cannon_tiny_bite",
						day_event_cannon_tiny_bite_execute,
						{
							reward: BALANCE_CANNON_DEMAND_TINY_BITE_REWARD,
							damage_min: BALANCE_CANNON_DEMAND_TINY_BITE_DAMAGE_MIN,
							damage_max: BALANCE_CANNON_DEMAND_TINY_BITE_DAMAGE_MAX
						}
					)
				]
			);
			_event.ignored_satisfaction_penalty = BALANCE_CANNON_DEMAND_TINY_BITE_IGNORED_PENALTY;
			break;

		case 4:
			if (!instance_exists(_required_cultist)
				|| !variable_instance_exists(_required_cultist, "hp")
				|| _required_cultist.hp <= 0)
			{
				return noone;
			}

			_event = new day_event_constructor(
				"cannon_demand_very_happy",
				"Make Me Very, Very Happy",
				"I want that one. Yes, the one trying not to look at me. Bring them closer - I promise I'll be very, very happy when I'm done.\nReward: +30 Cannon Satisfaction. Ignored: -20.",
				1,
				1,
				[
					new event_action_constructor(
						"cannon_very_happy",
						day_event_cannon_fixed_damage_execute,
						{
							reward: BALANCE_CANNON_DEMAND_VERY_HAPPY_REWARD,
							hp_cost: BALANCE_CANNON_DEMAND_VERY_HAPPY_DAMAGE
						}
					)
				]
			);
			_event.required_cultist = _required_cultist;
			_event.ignored_satisfaction_penalty = BALANCE_CANNON_DEMAND_VERY_HAPPY_IGNORED_PENALTY;
			break;

		default:
			_event = new day_event_constructor(
				"cannon_demand_polish_teeth",
				"Polish My Teeth",
				"Clean my barrel. I want to look pretty when I kill them.\nReward: +10 Cannon Satisfaction. Ignored: -30.",
				1,
				1,
				[
					new event_action_constructor(
						"cannon_polish_teeth",
						day_event_cannon_polish_teeth_execute,
						{ reward: BALANCE_CANNON_DEMAND_POLISH_TEETH_REWARD }
					)
				]
			);
			_event.ignored_satisfaction_penalty = BALANCE_CANNON_DEMAND_POLISH_TEETH_IGNORED_PENALTY;
			break;
	}

	_event.source_building = _cannon;
	_event.source_sprite = s_cannon_face;
	_event.is_cannon_demand = true;
	_event.reroll_is_available = false;
	_event.can_pin = false;

	return _event;
}

function day_event_cannon_demand_add()
{
	var _current_day = day_event_current_day_get();
	var _days_since_unlock = _current_day - BALANCE_CANNON_SATISFACTION_UNLOCK_DAY;
	var _demand_interval = max(1, BALANCE_CANNON_DEMAND_DAY_INTERVAL);
	var _demand_is_scheduled = _days_since_unlock >= 0
		&& _days_since_unlock mod _demand_interval == 0;

	if (!_demand_is_scheduled)
	{
		return false;
	}

	// Build the random pool from demands whose requirements can currently be met.
	var _demand_count = 6;
	var _broken_toy_demand_index = 0;
	var _very_happy_demand_index = 4;
	var _broken_toy_is_available = day_event_cannon_broken_toy_is_available();
	var _living_cultists = [];
	var _cultist_count = array_length(global.event_cultists);

	// The Cannon chooses one specific living Cultist for Make Me Very, Very Happy.
	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.event_cultists[_cultist_index];

		if (instance_exists(_cultist)
			&& variable_instance_exists(_cultist, "hp")
			&& _cultist.hp > 0)
		{
			array_push(_living_cultists, _cultist);
		}
	}

	var _living_cultist_count = array_length(_living_cultists);
	var _available_demand_indices = [];

	for (var _demand_index = 0; _demand_index < _demand_count; ++_demand_index)
	{
		if (_demand_index == _broken_toy_demand_index
			&& !_broken_toy_is_available)
		{
			continue;
		}

		if (_demand_index == _very_happy_demand_index
			&& _living_cultist_count <= 0)
		{
			continue;
		}

		array_push(_available_demand_indices, _demand_index);
	}

	if (array_length(_available_demand_indices) <= 0)
	{
		return false;
	}

	var _available_demand_count = array_length(_available_demand_indices);
	var _selected_demand_index = _available_demand_indices[irandom(_available_demand_count - 1)];
	var _required_cultist = noone;

	if (_selected_demand_index == _very_happy_demand_index)
	{
		_required_cultist = _living_cultists[irandom(_living_cultist_count - 1)];
	}

	var _demand = day_event_cannon_demand_create(_selected_demand_index, _required_cultist);

	return day_event_add_first(_demand);
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
			hp_cost: _group_hp_cost
		};
	}

	return {
		cultist_count: _solo_cultist_count,
		hp_cost: _solo_hp_cost
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
			hp_cost: BALANCE_SUPPORT_SUMMON_GROUP_HP_COST
		};
	}

	return {
		cultist_count: BALANCE_SUPPORT_SUMMON_SOLO_CULTIST_COUNT,
		hp_cost: BALANCE_SUPPORT_SUMMON_SOLO_HP_COST
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

function day_event_squads_without_unholy_trait_get()
{
	var _eligible_squads = [];
	var _squad_count = array_length(global.squads);

	for (var _squad_index = 0; _squad_index < _squad_count; ++_squad_index)
	{
		var _squad = global.squads[_squad_index];

		if (is_struct(_squad) && squad_unholy_trait_get(_squad) == UNHOLY_TRAIT.NONE)
		{
			array_push(_eligible_squads, _squad);
		}
	}

	return _eligible_squads;
}

function day_event_squads_with_relic_space_get()
{
	var _eligible_squads = [];
	var _squad_count = array_length(global.squads);

	for (var _squad_index = 0; _squad_index < _squad_count; ++_squad_index)
	{
		var _squad = global.squads[_squad_index];

		if (squad_relic_has_space(_squad))
		{
			array_push(_eligible_squads, _squad);
		}
	}

	return _eligible_squads;
}

function day_event_unholy_trait_is_used(_unholy_trait)
{
	if (_unholy_trait <= UNHOLY_TRAIT.NONE
		|| _unholy_trait >= UNHOLY_TRAIT.COUNT
		|| !variable_global_exists("unholy_traits_used")
		|| !is_array(global.unholy_traits_used)
		|| _unholy_trait >= array_length(global.unholy_traits_used))
	{
		return false;
	}

	return global.unholy_traits_used[_unholy_trait];
}

function day_event_unholy_trait_mark_used(_unholy_trait)
{
	if (_unholy_trait <= UNHOLY_TRAIT.NONE
		|| _unholy_trait >= UNHOLY_TRAIT.COUNT
		|| !variable_global_exists("unholy_traits_used")
		|| !is_array(global.unholy_traits_used)
		|| _unholy_trait >= array_length(global.unholy_traits_used))
	{
		return false;
	}

	global.unholy_traits_used[_unholy_trait] = true;
	return true;
}

function day_event_squad_selection_add(_event, _eligible_squads)
{
	_event.requires_squad_selection = true;
	_event.eligible_squads = _eligible_squads;
	_event.selected_squad = noone;
	return _event;
}

// Refresh target-dependent Rites when squads change, preserving a valid manual choice.
function day_event_squad_selection_refresh(_event)
{
	if (!is_struct(_event)
		|| _event.is_resolved
		|| !variable_struct_exists(_event, "requires_squad_selection")
		|| !_event.requires_squad_selection
		|| !variable_struct_exists(_event, "source_building")
		|| !instance_exists(_event.source_building))
	{
		return false;
	}

	// Each building retains its existing squad restrictions as the roster grows or changes.
	var _candidates = [];
	switch (_event.source_building.object_index)
	{
		case o_foundry:
			_candidates = day_event_squads_with_relic_space_get();
			break;
		case o_unholy_shrine:
			_candidates = day_event_squads_without_unholy_trait_get();
			break;
		case o_pitlings_pit2:
			_candidates = day_event_squads_get(SQUAD_TYPE.DEMON);
			break;
		case o_graveyard2:
			_candidates = day_event_squads_get(SQUAD_TYPE.UNDEAD);
			break;
		case o_summoning_grounds:
		case o_ritual_circle:
			_candidates = global.squads;
			break;
		default:
			return false;
	}

	_event.eligible_squads = [];
	var _candidate_count = array_length(_candidates);
	for (var _candidate_index = 0; _candidate_index < _candidate_count; ++_candidate_index)
	{
		var _squad = _candidates[_candidate_index];
		if (day_event_squad_is_compatible(_event, _squad))
		{
			array_push(_event.eligible_squads, _squad);
		}
	}

	if (!day_event_squad_is_compatible(_event, _event.selected_squad))
	{
		_event.selected_squad = noone;
	}

	return true;
}

function day_event_squad_is_active(_squad)
{
	if (!is_struct(_squad))
	{
		return false;
	}

	for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
	{
		if (global.squads[_squad_index] == _squad)
		{
			return true;
		}
	}

	return false;
}

function day_event_squad_is_compatible(_event, _squad)
{
	if (!day_event_squad_is_active(_squad))
	{
		return false;
	}

	// Replacement events still require their source unit when earlier events changed a squad.
	for (var _action_index = 0; _action_index < array_length(_event.actions); ++_action_index)
	{
		var _action = _event.actions[_action_index];

		if (is_struct(_action)
			&& variable_struct_exists(_action, "data")
			&& is_struct(_action.data)
			&& variable_struct_exists(_action.data, "source_unit_object")
			&& !day_event_squad_contains_unit_object(_squad, _action.data.source_unit_object))
		{
			return false;
		}

		if (is_struct(_action)
			&& variable_struct_exists(_action, "data")
			&& is_struct(_action.data)
			&& variable_struct_exists(_action.data, "required_unholy_trait")
			&& squad_unholy_trait_get(_squad) != _action.data.required_unholy_trait)
		{
			return false;
		}

		if (is_struct(_action)
			&& variable_struct_exists(_action, "data")
			&& is_struct(_action.data)
			&& variable_struct_exists(_action.data, "requires_relic_space")
			&& _action.data.requires_relic_space
			&& !squad_relic_has_space(_squad))
		{
			return false;
		}
	}

	return true;
}

function day_event_squad_selection_default_apply(_event)
{
	if (!is_struct(_event)
		|| !variable_struct_exists(_event, "requires_squad_selection")
		|| !_event.requires_squad_selection
		|| !variable_struct_exists(_event, "eligible_squads"))
	{
		return false;
	}

	// Preserve a valid manual choice.
	day_event_squad_selection_refresh(_event);
	if (variable_struct_exists(_event, "selected_squad")
		&& day_event_squad_is_compatible(_event, _event.selected_squad))
	{
		return true;
	}

	_event.selected_squad = noone;

	for (var _squad_index = 0; _squad_index < array_length(_event.eligible_squads); ++_squad_index)
	{
		var _squad = _event.eligible_squads[_squad_index];

		if (day_event_squad_is_compatible(_event, _squad))
		{
			_event.selected_squad = _squad;
			return true;
		}
	}

	return false;
}

function day_event_squad_summon_execute(_event, _assigned_cultists, _data)
{
	var _squad_point = variable_struct_exists(_data, "squad_point")
		? _data.squad_point
		: noone;

	// A point-created event must still own the exact empty point selected by the player.
	if (_squad_point != noone
		&& (!instance_exists(_squad_point)
			|| !variable_instance_exists(_squad_point, "assigned_squad")
			|| is_struct(_squad_point.assigned_squad)
			|| !variable_instance_exists(_squad_point, "pending_squad_event")
			|| _squad_point.pending_squad_event != _event))
	{
		return false;
	}

	var _squad = squad_create(
		_data.squad_type,
		_data.unit_object,
		_data.unit_count,
		_squad_point,
		_event
	);

	if (!is_struct(_squad))
	{
		return false;
	}

	if (instance_exists(_squad_point))
	{
		_squad_point.pending_squad_event = noone;
	}

	// The newly created squad now consumes the slot previously reserved by this card.
	_event.reserves_squad_slot = false;

	// Each worker pays the cost rolled for their assignment slot when the event was created.
	var _cultist_count = array_length(_assigned_cultists);
	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _hp_cost = day_event_action_slot_hp_cost_get(_data, _cultist_index);
		day_event_cultist_hp_cost_apply([_assigned_cultists[_cultist_index]], _hp_cost);
	}
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

function day_event_squad_units_choice_replace_execute(_event, _assigned_cultists, _data)
{
	if (!variable_struct_exists(_event, "unit_choice_options")
		|| !is_array(_event.unit_choice_options)
		|| !variable_struct_exists(_event, "selected_unit_choice_index"))
	{
		return false;
	}

	var _choice_count = array_length(_event.unit_choice_options);
	var _choice_index = floor(_event.selected_unit_choice_index);

	if (_choice_index < 0 || _choice_index >= _choice_count)
	{
		return false;
	}

	var _choice = _event.unit_choice_options[_choice_index];

	if (!is_struct(_choice)
		|| !variable_struct_exists(_choice, "target_unit_object"))
	{
		return false;
	}

	// Reuse the normal squad replacement after resolving the player's selected unit type.
	var _replacement_data = {
		source_unit_object: _data.source_unit_object,
		target_unit_object: _choice.target_unit_object,
		hp_cost: _data.hp_cost
	};
	return day_event_squad_units_replace_execute(_event, _assigned_cultists, _replacement_data);
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

function day_event_squad_unholy_trait_set_execute(_event, _assigned_cultists, _data)
{
	if (!variable_struct_exists(_event, "selected_squad")
		|| !is_struct(_event.selected_squad)
		|| !variable_struct_exists(_data, "unholy_trait")
		|| !variable_struct_exists(_data, "hp_cost"))
	{
		return false;
	}

	var _squad = _event.selected_squad;
	var _unholy_trait = _data.unholy_trait;

	// An Unholy Rite cannot replace a squad trait or grant a Rite already used this run.
	if (day_event_unholy_trait_is_used(_unholy_trait)
		|| squad_unholy_trait_get(_squad) != UNHOLY_TRAIT.NONE
		|| !squad_unholy_trait_set(_squad, _unholy_trait))
	{
		return false;
	}

	// Per-night trigger state starts clean when a squad receives its trait.
	_squad.properties.unholy_roar_triggered = false;

	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	day_event_unholy_trait_mark_used(_unholy_trait);
	return true;
}

function day_event_squad_unit_add_execute(_event, _assigned_cultists, _data)
{
	if (!variable_struct_exists(_event, "selected_squad") || !is_struct(_event.selected_squad))
	{
		return false;
	}

	var _squad = _event.selected_squad;
	var _unit_count = variable_struct_exists(_data, "unit_count")
		? max(1, floor(_data.unit_count))
		: 1;
	var _added_unit_count = 0;

	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		var _new_unit_index = array_length(_squad.unit_objects);
		array_push(_squad.unit_objects, _data.unit_object);
		var _new_unit = squad_unit_spawn(_squad, _data.unit_object, _new_unit_index);

		if (!instance_exists(_new_unit))
		{
			array_delete(_squad.unit_objects, _new_unit_index, 1);
			continue;
		}

		array_push(_squad.units, _new_unit);
		_squad.total_max_hp += _new_unit.max_hp;
		_added_unit_count++;
	}

	if (_added_unit_count <= 0)
	{
		return false;
	}

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

function day_event_squad_recruitment_create(_squad_point, _choice)
{
	if (!instance_exists(_squad_point)
		|| !is_struct(_choice)
		|| !variable_struct_exists(_choice, "squad_type")
		|| !variable_struct_exists(_choice, "unit_object")
		|| !variable_struct_exists(_choice, "unit_count")
		|| !variable_instance_exists(_squad_point, "assigned_squad")
		|| is_struct(_squad_point.assigned_squad)
		|| !squad_slot_is_available(_choice.squad_type))
	{
		return noone;
	}

	if (variable_instance_exists(_squad_point, "squad_point_pending_event_is_active")
		&& _squad_point.squad_point_pending_event_is_active())
	{
		return noone;
	}

	var _squad_name = variable_struct_exists(_choice, "squad_name")
		? string(_choice.squad_name)
		: squad_name_create(_choice.unit_object);
	var _description = variable_struct_exists(_choice, "event_description")
		? string(_choice.event_description)
		: "Summon the selected squad at this Squad Point.";
	// Roll once per recruitment event; assigning workers never rerolls the displayed costs.
	var _total_hp_cost = BALANCE_SQUAD_EVENT_TOTAL_HP_COST;
	var _hp_cost_step = BALANCE_SQUAD_EVENT_HP_COST_STEP;
	var _first_hp_cost = irandom(_total_hp_cost div _hp_cost_step) * _hp_cost_step;
	var _hp_cost_by_slot = [_first_hp_cost, _total_hp_cost - _first_hp_cost];
	var _event = new day_event_constructor(
		"summon_squad_" + string(_squad_point),
		"Summon " + _squad_name,
		_description,
		BALANCE_SQUAD_EVENT_CULTIST_COUNT,
		1,
		[
			new event_action_constructor(
				"summon_squad",
				day_event_squad_summon_execute,
				{
					squad_type: _choice.squad_type,
					unit_object: _choice.unit_object,
					unit_count: max(1, floor(_choice.unit_count)),
					hp_cost_by_slot: _hp_cost_by_slot,
					squad_point: _squad_point
				}
			)
		]
	);

	// Point recruitment is a deliberate player order, not a random building Rite.
	_event.source_building = _squad_point;
	_event.source_sprite = s_squad_point;
	_event.squad_point = _squad_point;
	_event.reserves_squad_slot = true;
	_event.can_pin = false;
	_event.reroll_is_available = false;
	_squad_point.pending_squad_event = _event;
	day_event_add_first(_event);
	// The player assigns recruitment workers after the card appears.
	return _event;
}

function day_event_unholy_trait_add(_shrine, _eligible_squads, _event_id, _title, _description, _unholy_trait)
{
	if (day_event_unholy_trait_is_used(_unholy_trait))
	{
		return false;
	}

	var _event = day_event_squad_create(
		_shrine,
		_event_id,
		_title,
		_description,
		BALANCE_UNHOLY_SHRINE_EVENT_CULTIST_COUNT,
		"set_unholy_trait",
		day_event_squad_unholy_trait_set_execute,
		{
			unholy_trait: _unholy_trait,
			required_unholy_trait: UNHOLY_TRAIT.NONE,
			hp_cost: BALANCE_UNHOLY_SHRINE_EVENT_CULTIST_HP_COST
		}
	);

	return day_event_add(day_event_squad_selection_add(_event, _eligible_squads));
}

function day_event_blood_bath_crimson_baptism_execute(_event, _assigned_cultists, _data)
{
	var _cultist_count = array_length(global.event_cultists);
	var _affects_unconscious_cultists = day_event_affects_unconscious_cultists(_data);

	// Conscious Cultists receive this queued heal unless the action explicitly opts in to unconscious targets.
	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.event_cultists[_cultist_index];

		if (instance_exists(_cultist))
		{
			var _is_unconscious = (variable_instance_exists(_cultist, "is_unconscious")
				&& _cultist.is_unconscious)
				|| (variable_instance_exists(_cultist, "hp") && _cultist.hp <= 0);

			if (_is_unconscious && !_affects_unconscious_cultists)
			{
				continue;
			}

			if (!variable_instance_exists(_cultist, "blood_bath_morning_heal_pending"))
			{
				_cultist.blood_bath_morning_heal_pending = 0;
			}

			if (!variable_instance_exists(_cultist, "blood_bath_morning_unconscious_heal_pending"))
			{
				_cultist.blood_bath_morning_unconscious_heal_pending = 0;
			}

			_cultist.blood_bath_morning_heal_pending += BALANCE_BLOOD_BATH_CRIMSON_MORNING_HEAL;

			if (_affects_unconscious_cultists)
			{
				_cultist.blood_bath_morning_unconscious_heal_pending +=
					BALANCE_BLOOD_BATH_CRIMSON_MORNING_HEAL;
			}
		}
	}

	return true;
}

function day_event_infernal_regeneration_execute(_event, _assigned_cultists, _data)
{
	if (global.blood_bath_infernal_regeneration_uses
		>= BALANCE_BLOOD_BATH_INFERNAL_REGENERATION_ACTIVATION_LIMIT)
	{
		return false;
	}

	global.blood_bath_infernal_regeneration_uses++;
	return true;
}

function day_event_blood_bath_heal_execute(_event, _assigned_cultists, _data)
{
	var _cultist = _assigned_cultists[0];

	if (!instance_exists(_cultist))
	{
		return false;
	}

	day_event_cultist_heal_apply(
		_cultist,
		BALANCE_BLOOD_BATH_HEAL_AMOUNT + global.blood_bath_daily_heal_bonus,
		day_event_affects_unconscious_cultists(_data)
	);
	return true;
}

function day_event_lingering_wounds_execute(_event, _assigned_cultists, _data)
{
	global.blood_bath_lingering_wounds_morning_pending = true;
	global.blood_bath_lingering_wounds_affects_unconscious =
		global.blood_bath_lingering_wounds_affects_unconscious
		|| day_event_affects_unconscious_cultists(_data);
	return true;
}

function day_event_blood_transfusion_execute(_event, _assigned_cultists, _data)
{
	var _first_cultist = _assigned_cultists[0];
	var _second_cultist = _assigned_cultists[1];

	if (!instance_exists(_first_cultist) || !instance_exists(_second_cultist))
	{
		return false;
	}

	var _healthiest = _first_cultist.hp >= _second_cultist.hp ? _first_cultist : _second_cultist;
	var _most_wounded = _healthiest == _first_cultist ? _second_cultist : _first_cultist;

	day_event_cultist_damage_apply(
		_healthiest,
		BALANCE_BLOOD_TRANSFUSION_HEALTHY_DAMAGE,
		false
	);
	day_event_cultist_heal_apply(
		_most_wounded,
		BALANCE_BLOOD_TRANSFUSION_WOUNDED_HEAL,
		day_event_affects_unconscious_cultists(_data)
	);
	return true;
}

function day_event_harden_vessel_execute(_event, _assigned_cultists, _data)
{
	var _cultist = _assigned_cultists[0];

	if (!instance_exists(_cultist))
	{
		return false;
	}

	day_event_cultist_damage_apply(_cultist, BALANCE_HARDEN_VESSEL_DAMAGE, false);

	if (!variable_instance_exists(_cultist, "blood_bath_morning_heal_pending"))
	{
		_cultist.blood_bath_morning_heal_pending = 0;
	}

	if (!variable_instance_exists(_cultist, "blood_bath_morning_unconscious_heal_pending"))
	{
		_cultist.blood_bath_morning_unconscious_heal_pending = 0;
	}

	_cultist.blood_bath_morning_heal_pending += BALANCE_HARDEN_VESSEL_MORNING_HEAL;

	if (day_event_affects_unconscious_cultists(_data))
	{
		_cultist.blood_bath_morning_unconscious_heal_pending +=
			BALANCE_HARDEN_VESSEL_MORNING_HEAL;
	}
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

function day_event_undying_devotion_cultist_store(_cultist)
{
	if (!instance_exists(_cultist)
		|| !variable_global_exists("blood_bath_undying_devotion_pending")
		|| !global.blood_bath_undying_devotion_pending)
	{
		return false;
	}

	if (!variable_global_exists("blood_bath_undying_devotion_dead_cultists"))
	{
		global.blood_bath_undying_devotion_dead_cultists = [];
	}

	var _cultist_name = variable_instance_exists(_cultist, "cultist_name")
		? _cultist.cultist_name
		: "";
	var _max_hp = variable_instance_exists(_cultist, "max_hp")
		? max(1, _cultist.max_hp)
		: BALANCE_EVENT_CULTIST_MAX_HP;
	var _sprite_index = _cultist.sprite_index;
	var _work_history = variable_instance_exists(_cultist, "work_history")
		&& is_array(_cultist.work_history)
		? _cultist.work_history
		: [];
	var _building_work_counts = variable_instance_exists(_cultist, "building_work_counts")
		&& is_array(_cultist.building_work_counts)
		? _cultist.building_work_counts
		: [];
	var _mastery_building_object = variable_instance_exists(
		_cultist,
		"mastery_building_object"
	)
		? _cultist.mastery_building_object
		: noone;
	var _mastery_building_name = variable_instance_exists(
		_cultist,
		"mastery_building_name"
	)
		? _cultist.mastery_building_name
		: "";
	var _mastery_building_sprite = variable_instance_exists(
		_cultist,
		"mastery_building_sprite"
	)
		? _cultist.mastery_building_sprite
		: noone;

	array_push(global.blood_bath_undying_devotion_dead_cultists, {
		cultist_name: _cultist_name,
		max_hp: _max_hp,
		max_spirit: _cultist.max_spirit,
		sprite_index: _sprite_index,
		work_history: _work_history,
		building_work_counts: _building_work_counts,
		mastery_building_object: _mastery_building_object,
		mastery_building_name: _mastery_building_name,
		mastery_building_sprite: _mastery_building_sprite
	});
	return true;
}

function day_event_cultist_death_remove(_cultist)
{
	if (!instance_exists(_cultist)
		|| !variable_instance_exists(_cultist, "hp")
		|| _cultist.hp > 0)
	{
		return false;
	}

	// Legacy callers now use the non-lethal unconscious flow.
	day_event_cultist_unconscious_enter(_cultist);
	day_event_cultist_assignment_release(_cultist);
	return true;
}

function day_event_bath_demands_name_execute(_event, _assigned_cultists, _data)
{
	var _assigned_cultist = _assigned_cultists[0];

	if (!instance_exists(_assigned_cultist))
	{
		return false;
	}

	day_event_cultist_damage_apply(
		_assigned_cultist,
		BALANCE_BATH_DEMANDS_NAME_DAMAGE,
		false
	);
	var _cultist_count = array_length(global.event_cultists);
	var _affects_unconscious_cultists = day_event_affects_unconscious_cultists(_data);

	// Every other conscious Cultist is fully restored the following morning.
	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.event_cultists[_cultist_index];

		if (instance_exists(_cultist) && _cultist != _assigned_cultist)
		{
			var _is_unconscious = (variable_instance_exists(_cultist, "is_unconscious")
				&& _cultist.is_unconscious)
				|| (variable_instance_exists(_cultist, "hp") && _cultist.hp <= 0);

			if (_is_unconscious && !_affects_unconscious_cultists)
			{
				continue;
			}

			_cultist.blood_bath_morning_full_heal_pending = true;
			_cultist.blood_bath_morning_full_heal_affects_unconscious =
				_affects_unconscious_cultists;
		}
	}

	return true;
}

function day_event_blood_for_blood_execute(_event, _assigned_cultists, _data)
{
	var _cultist = _assigned_cultists[0];

	if (!instance_exists(_cultist))
	{
		return false;
	}

	day_event_cultist_damage_apply(_cultist, BALANCE_BLOOD_FOR_BLOOD_DAMAGE, false);
	day_event_cultist_limit_add(BALANCE_BLOOD_FOR_BLOOD_LIMIT_BONUS);
	return true;
}

function day_event_undying_devotion_execute(_event, _assigned_cultists, _data)
{
	if (!variable_global_exists("blood_bath_undying_devotion_pending")
		|| !global.blood_bath_undying_devotion_pending)
	{
		global.blood_bath_undying_devotion_dead_cultists = [];
	}

	global.blood_bath_undying_devotion_pending = true;
	return true;
}

function day_event_undying_devotion_morning_apply()
{
	if (!variable_global_exists("blood_bath_undying_devotion_dead_cultists"))
	{
		global.blood_bath_undying_devotion_dead_cultists = [];
	}

	var _dead_cultists = global.blood_bath_undying_devotion_dead_cultists;
	var _dead_cultist_count = array_length(_dead_cultists);

	// Recreate every preserved Cultist with the same identity and appearance.
	for (var _cultist_index = 0; _cultist_index < _dead_cultist_count; ++_cultist_index)
	{
		var _cultist_data = _dead_cultists[_cultist_index];
		var _cultist = day_event_cultist_add(_cultist_data.cultist_name, _cultist_data.max_hp);

		if (!instance_exists(_cultist))
		{
			continue;
		}

		_cultist.cultist_name = _cultist_data.cultist_name;
		// Resurrection happens in the morning, so restore the preserved maximum at full Spirit.
		_cultist.max_spirit = variable_struct_exists(_cultist_data, "max_spirit")
			? _cultist_data.max_spirit : BALANCE_EVENT_CULTIST_MAX_SPIRIT;
		_cultist.spirit = _cultist.max_spirit;
		_cultist.sprite_index = _cultist_data.sprite_index;
		_cultist.work_history = variable_struct_exists(_cultist_data, "work_history")
			? _cultist_data.work_history
			: [];
		_cultist.building_work_counts = variable_struct_exists(_cultist_data, "building_work_counts")
			? _cultist_data.building_work_counts
			: [];
		// Pending offers belonged to the previous instance; retained work may unlock a fresh offer.
		var _restored_work_count = array_length(_cultist.building_work_counts);
		for (var _work_index = 0; _work_index < _restored_work_count; ++_work_index)
		{
			_cultist.building_work_counts[_work_index].mastery_pending = false;
		}
		_cultist.mastery_building_object = variable_struct_exists(
			_cultist_data,
			"mastery_building_object"
		)
			? _cultist_data.mastery_building_object
			: noone;
		_cultist.mastery_building_name = variable_struct_exists(
			_cultist_data,
			"mastery_building_name"
		)
			? _cultist_data.mastery_building_name
			: "";
		_cultist.mastery_building_sprite = variable_struct_exists(
			_cultist_data,
			"mastery_building_sprite"
		)
			? _cultist_data.mastery_building_sprite
			: noone;
		// Revival must not restore the retired Blood Bath mastery.
		if (_cultist.mastery_building_object == o_meat_bath)
		{
			_cultist.mastery_building_object = noone;
			_cultist.mastery_building_name = "";
			_cultist.mastery_building_sprite = noone;
		}
		_cultist.hp = min(
			_cultist.max_hp,
			BALANCE_BLOOD_BATH_UNDYING_DEVOTION_REVIVE_HP
		);
	}

	global.blood_bath_undying_devotion_pending = false;
	global.blood_bath_undying_devotion_dead_cultists = [];
	return true;
}

function day_event_blood_bath_morning_effects_apply()
{
	var _cultist_count = array_length(global.event_cultists);
	var _warpaint_is_pending = global.blood_bath_warpaint_morning_pending;
	var _lingering_wounds_is_pending = variable_global_exists(
		"blood_bath_lingering_wounds_morning_pending"
	) && global.blood_bath_lingering_wounds_morning_pending;

	for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
	{
		var _cultist = global.event_cultists[_cultist_index];

		if (!instance_exists(_cultist)
			|| !variable_instance_exists(_cultist, "hp")
			|| !variable_instance_exists(_cultist, "max_hp"))
		{
			continue;
		}

		var _full_heal_is_pending = variable_instance_exists(
			_cultist,
			"blood_bath_morning_full_heal_pending"
		) && _cultist.blood_bath_morning_full_heal_pending;
		var _heal_amount = variable_instance_exists(_cultist, "blood_bath_morning_heal_pending")
			? max(0, _cultist.blood_bath_morning_heal_pending)
			: 0;
		var _unconscious_heal_amount = variable_instance_exists(
			_cultist,
			"blood_bath_morning_unconscious_heal_pending"
		)
			? max(0, _cultist.blood_bath_morning_unconscious_heal_pending)
			: 0;
		var _full_heal_affects_unconscious = variable_instance_exists(
			_cultist,
			"blood_bath_morning_full_heal_affects_unconscious"
		) && _cultist.blood_bath_morning_full_heal_affects_unconscious;
		var _is_unconscious = (variable_instance_exists(_cultist, "is_unconscious")
			&& _cultist.is_unconscious)
			|| _cultist.hp <= 0;
		if (_full_heal_is_pending && (!_is_unconscious || _full_heal_affects_unconscious))
		{
			day_event_cultist_heal_apply(
				_cultist,
				max(0, _cultist.max_hp - _cultist.hp),
				_full_heal_affects_unconscious
			);
		}
		else
		{
			var _allowed_heal_amount = _is_unconscious
				? _unconscious_heal_amount
				: _heal_amount;

			if (_allowed_heal_amount > 0)
			{
				day_event_cultist_heal_apply(
					_cultist,
					_allowed_heal_amount,
					_is_unconscious
				);
			}
		}

		// Warpaint sets the final morning HP after all other queued recovery.
		_is_unconscious = (variable_instance_exists(_cultist, "is_unconscious")
			&& _cultist.is_unconscious)
			|| _cultist.hp <= 0;

		if (_warpaint_is_pending
			&& (!_is_unconscious || global.blood_bath_warpaint_affects_unconscious))
		{
			var _warpaint_target_hp = min(
				_cultist.max_hp,
				BALANCE_BLOOD_WARPAINT_MORNING_HP
			);

			if (_warpaint_target_hp > _cultist.hp)
			{
				day_event_cultist_heal_apply(
					_cultist,
					_warpaint_target_hp - _cultist.hp,
					global.blood_bath_warpaint_affects_unconscious
				);
			}
			else
			{
				_cultist.hp = _warpaint_target_hp;
			}
		}

		// Lingering Wounds overrides other recovery with the previous morning's exact HP.
		_is_unconscious = (variable_instance_exists(_cultist, "is_unconscious")
			&& _cultist.is_unconscious)
			|| _cultist.hp <= 0;

		if (_lingering_wounds_is_pending
			&& (!_is_unconscious || global.blood_bath_lingering_wounds_affects_unconscious)
			&& variable_instance_exists(_cultist, "blood_bath_morning_hp_snapshot"))
		{
			var _snapshot_hp = clamp(
				_cultist.blood_bath_morning_hp_snapshot,
				0,
				_cultist.max_hp
			);

			if (_snapshot_hp > _cultist.hp)
			{
				day_event_cultist_heal_apply(
					_cultist,
					_snapshot_hp - _cultist.hp,
					global.blood_bath_lingering_wounds_affects_unconscious
				);
			}
			else
			{
				_cultist.hp = _snapshot_hp;
			}
		}

		_cultist.blood_bath_morning_heal_pending = 0;
		_cultist.blood_bath_morning_unconscious_heal_pending = 0;
		_cultist.blood_bath_morning_full_heal_pending = false;
		_cultist.blood_bath_morning_full_heal_affects_unconscious = false;
	}

	global.blood_bath_warpaint_morning_pending = false;
	global.blood_bath_lingering_wounds_morning_pending = false;
	global.blood_bath_warpaint_affects_unconscious = false;
	global.blood_bath_lingering_wounds_affects_unconscious = false;
	day_event_undying_devotion_morning_apply();

	// Store the final morning HP for a possible Lingering Wounds activation today.
	_cultist_count = array_length(global.event_cultists);

	for (var _snapshot_cultist_index = 0;
		_snapshot_cultist_index < _cultist_count;
		++_snapshot_cultist_index)
	{
		var _snapshot_cultist = global.event_cultists[_snapshot_cultist_index];

		if (instance_exists(_snapshot_cultist)
			&& variable_instance_exists(_snapshot_cultist, "hp")
			&& _snapshot_cultist.hp > 0)
		{
			_snapshot_cultist.blood_bath_morning_hp_snapshot = _snapshot_cultist.hp;
		}
	}

	return true;
}

function day_event_current_day_get()
{
	if (!instance_exists(o_game_controller))
	{
		return 1;
	}

	var _game_controller = instance_find(o_game_controller, 0);
	var _current_day = max(1, _game_controller.night_attack_night_index);

	// Morning events are generated before the controller advances its day index.
	if (global.day_phase == DAY_PHASE.NIGHT)
	{
		_current_day++;
	}

	return _current_day;
}

function day_event_modifier_add(_event, _modifier)
{
	if (!is_struct(_event) || string(_modifier) == "")
	{
		return false;
	}

	var _modifier_text = string(_modifier);
	var _modifiers = variable_struct_exists(_event, "modifiers")
		&& is_array(_event.modifiers)
		? _event.modifiers
		: [];

	// The same modifier must not be duplicated by rerolls or debug regeneration.
	for (var _modifier_index = 0; _modifier_index < array_length(_modifiers); ++_modifier_index)
	{
		if (_modifiers[_modifier_index] == _modifier_text)
		{
			return false;
		}
	}

	array_push(_modifiers, _modifier_text);
	_event.modifiers = _modifiers;
	return true;
}

function day_event_modifiers_text_get(_event)
{
	if (!is_struct(_event)
		|| !variable_struct_exists(_event, "modifiers")
		|| !is_array(_event.modifiers))
	{
		return "";
	}

	var _modifier_text = "";

	for (var _modifier_index = 0; _modifier_index < array_length(_event.modifiers); ++_modifier_index)
	{
		var _modifier = string(_event.modifiers[_modifier_index]);

		if (_modifier == "")
		{
			continue;
		}

		if (_modifier_text != "")
		{
			_modifier_text += "\n";
		}

		_modifier_text += _modifier;
	}

	return _modifier_text;
}

function day_event_description_get(_event, _base_description = "")
{
	if (!is_struct(_event))
	{
		return "";
	}

	var _description = _base_description == ""
		? string(_event.description)
		: string(_base_description);

	var _modifier_text = day_event_modifiers_text_get(_event);

	if (_modifier_text != "")
	{
		_description += "\n\n" + _modifier_text;
	}

	return _description;
}

function day_event_building_overuse_data_get(_building_object)
{
	switch (_building_object)
	{
		case o_meat_bath:
			return {
			event_id: "silence_the_donors",
			title: "Silence the Donors",
			description: "The blood's previous owners refuse to heal anyone until they get a proper funeral. Say a few words. \"Thanks for the blood\" should cover it."
		};

		case o_pitlings_pit2:
			return {
			event_id: "cool_the_depths",
			title: "Cool the Depths",
			description: "The pit has overheated and is belching fire instead of demons. Cool it with a soothing chant. Let the most enthusiastic cultist test the temperature."
		};

		case o_graveyard2:
			return {
			event_id: "restore_the_epitaphs",
			title: "Restore the Epitaphs",
			description: "Constant raising and reburying has worn the names off the headstones. The dead won't answer to \"you there.\" Carve the names back in. Guess confidently."
		};

		case o_unholy_shrine:
			return {
			event_id: "scrape_off_the_miracles",
			title: "Scrape Off the Miracles",
			description: "Too many rituals have covered the altar in a crust of extra eyes. Scrape it clean. If one looks familiar, mind your own business."
		};

		case o_foundry:
			return {
			event_id: "exorcise_the_anvil",
			title: "Exorcise the Anvil",
			description: "The anvil has absorbed so many curses that it now hits back. Beat the spirit out. Finally, a theological dispute we have the tools for."
		};

		case o_summoning_grounds:
			return {
			event_id: "scrape_the_circle_clean",
			title: "Scrape the Circle Clean",
			description: "Too many arrivals have buried the summoning runes under demonic slime. Scrape them clean. Anything that clings to the shovel is still technically a guest."
		};

		case o_shell_factory:
			return {
			event_id: "unheal_the_machinery",
			title: "Unheal the Machinery",
			description: "First Aid Meat has leaked into the machinery and healed the gears together. Cut them apart. The machine insists it has never felt better."
		};
	}

	return noone;
}

function day_event_building_overuse_is_enabled(_building)
{
	return instance_exists(_building)
		&& is_struct(day_event_building_overuse_data_get(_building.object_index));
}

function day_event_building_overuse_is_required(_building)
{
	return day_event_building_overuse_is_enabled(_building)
		&& variable_instance_exists(_building, "overuse_amount")
		&& _building.overuse_amount > BALANCE_BUILDING_OVERUSE_THRESHOLD;
}

function day_event_building_overuse_execute(_event, _assigned_cultists, _data)
{
	if (!variable_struct_exists(_event, "source_building")
		|| !instance_exists(_event.source_building))
	{
		return false;
	}

	_event.source_building.overuse_amount = 0;
	return true;
}

function day_event_building_overuse_create(_building)
{
	if (!day_event_building_overuse_is_required(_building))
	{
		return noone;
	}

	var _data = day_event_building_overuse_data_get(_building.object_index);
	var _event = new day_event_constructor(
		"building_overuse_" + _data.event_id + "_" + string(_building),
		_data.title,
		_data.description,
		1,
		1,
		[
			new event_action_constructor(
				"building_overuse_reset",
				day_event_building_overuse_execute,
				{ hp_cost: 0 }
			)
		]
	);
	_event.source_building = _building;
	_event.is_overuse_event = true;
	_event.can_pin = false;
	_event.reroll_is_available = false;
	return _event;
}

function day_event_building_overuse_events_replace(_source_building = noone)
{
	var _building_count = instance_number(o_v13buildings_parent);
	var _replacement_count = 0;

	for (var _building_index = 0; _building_index < _building_count; ++_building_index)
	{
		var _building = instance_find(o_v13buildings_parent, _building_index);

		if ((_source_building != noone && _building != _source_building)
			|| !day_event_building_overuse_is_required(_building))
		{
			continue;
		}

		// The maintenance Rite temporarily replaces every normal candidate from this source.
		for (var _event_index = array_length(global.day_events) - 1; _event_index >= 0; --_event_index)
		{
			var _candidate = global.day_events[_event_index];

			if (is_struct(_candidate)
				&& variable_struct_exists(_candidate, "source_building")
				&& _candidate.source_building == _building)
			{
				array_delete(global.day_events, _event_index, 1);
			}
		}

		var _overuse_event = day_event_building_overuse_create(_building);

		if (is_struct(_overuse_event))
		{
			day_event_add(_overuse_event);
			_replacement_count++;
		}
	}

	return _replacement_count;
}

function day_event_building_overuse_morning_recovery_apply()
{
	var _previous_day = max(1, day_event_current_day_get() - 1);
	var _building_count = instance_number(o_v13buildings_parent);
	var _recovered_count = 0;

	for (var _building_index = 0; _building_index < _building_count; ++_building_index)
	{
		var _building = instance_find(o_v13buildings_parent, _building_index);

		if (!day_event_building_overuse_is_enabled(_building)
			|| _building.overuse_amount <= 0
			|| day_event_building_overuse_is_required(_building)
			|| _building.overuse_last_normal_event_day == _previous_day)
		{
			continue;
		}

		_building.overuse_amount = max(
			0,
			_building.overuse_amount - BALANCE_BUILDING_OVERUSE_DAILY_RECOVERY
		);
		_recovered_count++;
	}

	return _recovered_count;
}

function day_event_building_ritual_rest_state_refresh(_building, _current_day)
{
	if (!instance_exists(_building)
		|| !variable_instance_exists(_building, "ritual_execution_day_count")
		|| !variable_instance_exists(_building, "ritual_rest_unavailable_day"))
	{
		return false;
	}

	// A completed unavailable day starts a fresh ritual-use cycle.
	if (_building.ritual_rest_unavailable_day <= 0
		|| _current_day <= _building.ritual_rest_unavailable_day)
	{
		return false;
	}

	_building.ritual_execution_day_count = 0;
	_building.ritual_execution_last_day = 0;
	_building.ritual_rest_warning_day = 0;
	_building.ritual_rest_unavailable_day = 0;
	return true;
}

function day_event_building_ritual_execution_record(_building, _current_day, _event = noone)
{
	if (!instance_exists(_building))
	{
		return false;
	}

	if (day_event_building_overuse_is_enabled(_building))
	{
		var _is_overuse_event = is_struct(_event)
			&& variable_struct_exists(_event, "is_overuse_event")
			&& _event.is_overuse_event;

		if (_is_overuse_event)
		{
			return true;
		}

		var _activation_count = is_struct(_event)
			&& variable_struct_exists(_event, "activation_count")
			? max(1, floor(_event.activation_count))
			: 1;

		for (var _activation_index = 0; _activation_index < _activation_count; ++_activation_index)
		{
			_building.overuse_amount += irandom_range(
				BALANCE_BUILDING_OVERUSE_GAIN_MIN,
				BALANCE_BUILDING_OVERUSE_GAIN_MAX
			);
		}

		_building.overuse_last_normal_event_day = _current_day;
		return true;
	}

	if (!variable_instance_exists(_building, "ritual_execution_day_count")
		|| !variable_instance_exists(_building, "ritual_execution_last_day")
		|| !variable_instance_exists(_building, "ritual_rest_warning_day")
		|| !variable_instance_exists(_building, "ritual_rest_unavailable_day"))
	{
		return false;
	}

	day_event_building_ritual_rest_state_refresh(_building, _current_day);

	// Further executions cannot start a second cycle before the scheduled rest.
	if ((_building.ritual_rest_warning_day > 0
			&& _current_day <= _building.ritual_rest_warning_day)
		|| (_building.ritual_rest_unavailable_day > 0
			&& _current_day <= _building.ritual_rest_unavailable_day)
		|| _building.ritual_execution_last_day == _current_day)
	{
		return false;
	}

	_building.ritual_execution_last_day = _current_day;
	_building.ritual_execution_day_count++;

	if (_building.ritual_execution_day_count
		>= BALANCE_BUILDING_RITUAL_EXECUTION_DAYS_BEFORE_REST)
	{
		_building.ritual_rest_warning_day = _current_day
			+ BALANCE_BUILDING_RITUAL_REST_WARNING_DELAY;
		_building.ritual_rest_unavailable_day = _current_day
			+ BALANCE_BUILDING_RITUAL_REST_UNAVAILABLE_DELAY;
	}

	return true;
}

function day_event_building_ritual_rest_apply()
{
	var _current_day = day_event_current_day_get();
	var _building_count = instance_number(o_v13buildings_parent);

	// Refresh every building before its newly generated events are evaluated.
	for (var _building_index = 0; _building_index < _building_count; ++_building_index)
	{
		var _building = instance_find(o_v13buildings_parent, _building_index);

		if (instance_exists(_building))
		{
			day_event_building_ritual_rest_state_refresh(_building, _current_day);
		}
	}

	var _removed_event_count = 0;
	var _warning_text = "Tomorrow this building's rituals will be unavailable.";

	// Work backwards so unavailable events can be removed safely in place.
	for (var _event_index = array_length(global.day_events) - 1; _event_index >= 0; --_event_index)
	{
		var _event = global.day_events[_event_index];

		if (!is_struct(_event)
			|| variable_struct_exists(_event, "construction_site")
			|| !variable_struct_exists(_event, "source_building")
			|| !instance_exists(_event.source_building)
			|| !variable_instance_exists(_event.source_building, "ritual_rest_warning_day")
			|| !variable_instance_exists(_event.source_building, "ritual_rest_unavailable_day"))
		{
			continue;
		}

		var _source_building = _event.source_building;

		if (day_event_building_overuse_is_enabled(_source_building))
		{
			continue;
		}

		if (_source_building.ritual_rest_unavailable_day == _current_day)
		{
			array_delete(global.day_events, _event_index, 1);
			_removed_event_count++;
			continue;
		}

		if (_source_building.ritual_rest_warning_day == _current_day)
		{
			day_event_modifier_add(_event, _warning_text);
		}
	}

	return _removed_event_count;
}

function day_event_cult_must_grow_cost_get()
{
	if (irandom(1) == 0)
	{
		return {
			cultist_count: BALANCE_CULT_MUST_GROW_SOLO_CULTIST_COUNT,
			hp_cost: BALANCE_CULT_MUST_GROW_SOLO_HP_COST
		};
	}

	return {
		cultist_count: BALANCE_CULT_MUST_GROW_GROUP_CULTIST_COUNT,
		hp_cost: BALANCE_CULT_MUST_GROW_GROUP_HP_COST
	};
}

function day_event_cult_must_grow_execute(_event, _assigned_cultists, _data)
{
	var _recruited_count = 0;

	for (var _recruit_index = 0; _recruit_index < BALANCE_CULT_MUST_GROW_RECRUIT_COUNT; ++_recruit_index)
	{
		var _recruited_cultist = day_event_cultist_add();

		if (instance_exists(_recruited_cultist))
		{
			_recruited_count++;
		}
	}

	if (_recruited_count <= 0)
	{
		return false;
	}

	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}

function day_event_cult_must_grow_create(_blood_bath)
{
	var _cost = day_event_cult_must_grow_cost_get();
	var _event = new day_event_constructor(
		"the_cult_must_grow_" + string(_blood_bath),
		"The Cult Must Grow",
		"Recruit " + string(BALANCE_CULT_MUST_GROW_RECRUIT_COUNT) + " new Cultist.",
		_cost.cultist_count,
		1,
		[
			new event_action_constructor(
				"recruit_cultist",
				day_event_cult_must_grow_execute,
				{ hp_cost: _cost.hp_cost }
			)
		]
	);
	_event.source_building = _blood_bath;
	return _event;
}

function day_event_archdemon_count_get()
{
	if (!variable_global_exists("archdemons"))
	{
		return 0;
	}

	return array_length(global.archdemons);
}

function day_event_world_archdemon_event_id_get(_archdemon_number)
{
	return "world_job_archdemon_" + string(_archdemon_number);
}

function day_event_world_archdemon_job_is_available(_archdemon_number)
{
	var _last_archdemon_number = 3; // Three sequential Archdemon Jobs are authored.

	if (!BALANCE_WORLD_JOB_ARCHDEMON_ENABLED
		|| _archdemon_number < 1
		|| _archdemon_number > _last_archdemon_number
		|| day_event_archdemon_count_get() >= _archdemon_number
		|| !squad_slot_is_available(SQUAD_TYPE.ARCHDEMON))
	{
		return false;
	}

	var _current_day = day_event_current_day_get();

	if (_archdemon_number == 1)
	{
		return !global.world_job_first_archdemon_completed
			&& _current_day >= BALANCE_WORLD_JOB_FIRST_ARCHDEMON_UNLOCK_DAY;
	}

	if (_archdemon_number == 2)
	{
		return global.world_job_first_archdemon_completed
			&& !global.world_job_second_archdemon_completed
			&& _current_day >= BALANCE_WORLD_JOB_SECOND_ARCHDEMON_UNLOCK_DAY;
	}

	return global.world_job_second_archdemon_completed
		&& !global.world_job_third_archdemon_completed
		&& _current_day >= BALANCE_WORLD_JOB_THIRD_ARCHDEMON_UNLOCK_DAY;
}

function day_event_world_archdemon_execute(_event, _assigned_cultists, _data)
{
	if (!day_event_world_archdemon_job_is_available(_data.archdemon_number)
		|| !instance_exists(o_game_controller)
		|| !instance_exists(o_cannon)
		|| !squad_slot_is_available(SQUAD_TYPE.ARCHDEMON))
	{
		return false;
	}

	var _game_controller = instance_find(o_game_controller, 0);
	var _cannon = instance_find(o_cannon, 0);
	var _archdemon_index = array_length(global.archdemons);
	var _spawn_angle = 180 + (_archdemon_index * 60);
	var _spawn_distance = BALANCE_EVENT_CULTIST_WANDER_HORIZONTAL_DISTANCE;
	var _spawn_x = _cannon.x + lengthdir_x(_spawn_distance, _spawn_angle);
	var _spawn_y = _cannon.y + lengthdir_y(_spawn_distance, _spawn_angle);
	var _possessed_cultist_name = "";

	if (array_length(_assigned_cultists) > 0)
	{
		var _possessed_cultist = _assigned_cultists[0];

		if (instance_exists(_possessed_cultist)
			&& variable_instance_exists(_possessed_cultist, "cultist_name"))
		{
			_possessed_cultist_name = _possessed_cultist.cultist_name;
		}
	}

	var _archdemon = instance_create_layer(_spawn_x, _spawn_y, "Instances", o_archdemon);

	if (!instance_exists(_archdemon))
	{
		return false;
	}

	array_push(global.archdemons, _archdemon);
	squad_register_existing_unit(SQUAD_TYPE.ARCHDEMON, _archdemon);
	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);

	if (_data.archdemon_number == 1)
	{
		global.world_job_first_archdemon_completed = true;
	}
	else if (_data.archdemon_number == 2)
	{
		global.world_job_second_archdemon_completed = true;
	}
	else
	{
		global.world_job_third_archdemon_completed = true;
	}

	// Keep an already-open selection on the earliest unconfigured Archdemon.
	if (global.focus_window != FOCUS_WINDOW.CULTIST_DEMON_SELECTION)
	{
		_game_controller.open_cultist_demon_selection(_archdemon_index, _possessed_cultist_name);
	}

	return true;
}

function day_event_world_archdemon_create(
	_archdemon_number,
	_title,
	_description,
	_cultist_count,
	_hp_cost
)
{
	var _event = new day_event_constructor(
		day_event_world_archdemon_event_id_get(_archdemon_number),
		_title,
		_description,
		_cultist_count,
		1,
		[
			new event_action_constructor(
				"summon_archdemon",
				day_event_world_archdemon_execute,
				{
					archdemon_number: _archdemon_number,
					hp_cost: _hp_cost,
					unit_object: o_archdemon
				}
			)
		]
	);
	_event.is_world_job = true;

	return _event;
}

function day_event_world_jobs_generate()
{
	if (day_event_world_archdemon_job_is_available(1))
	{
		day_event_add(day_event_world_archdemon_create(
			1,
			"Summon an Archdemon",
			"Summon a powerful combat demon: an ARCHDEMON.\nThe following night, you will be able to choose which Archdemon to summon.",
			BALANCE_WORLD_JOB_FIRST_ARCHDEMON_CULTIST_COUNT,
			BALANCE_WORLD_JOB_FIRST_ARCHDEMON_HP_COST
		));
	}

	if (day_event_world_archdemon_job_is_available(2))
	{
		day_event_add(day_event_world_archdemon_create(
			2,
			"Summon a Second Archdemon",
			"Summon a new Archdemon.",
			BALANCE_WORLD_JOB_SECOND_ARCHDEMON_CULTIST_COUNT,
			BALANCE_WORLD_JOB_SECOND_ARCHDEMON_HP_COST
		));
	}

	if (day_event_world_archdemon_job_is_available(3))
	{
		day_event_add(day_event_world_archdemon_create(
			3,
			"Summon a Third Archdemon",
			"Summon a new Archdemon.",
			BALANCE_WORLD_JOB_THIRD_ARCHDEMON_CULTIST_COUNT,
			BALANCE_WORLD_JOB_THIRD_ARCHDEMON_HP_COST
		));
	}
}

function day_event_foundry_stat_name_get(_stat)
{
	if (_stat == CULTIST_STAT.BODY)
	{
		return "Body";
	}

	if (_stat == CULTIST_STAT.SPIRIT)
	{
		return "Spirit";
	}

	return "Fervor";
}

function day_event_foundry_archdemon_target_get(_target_index, _target_name)
{
	if (_target_index >= 0 && _target_index < array_length(global.archdemons))
	{
		var _indexed_target = global.archdemons[_target_index];

		if (instance_exists(_indexed_target)
			&& variable_instance_exists(_indexed_target, "cultist_name")
			&& _indexed_target.cultist_name == _target_name)
		{
			return _indexed_target;
		}
	}

	for (var _archdemon_index = 0; _archdemon_index < array_length(global.archdemons); ++_archdemon_index)
	{
		var _archdemon = global.archdemons[_archdemon_index];

		if (instance_exists(_archdemon)
			&& variable_instance_exists(_archdemon, "cultist_name")
			&& _archdemon.cultist_name == _target_name)
		{
			return _archdemon;
		}
	}

	return noone;
}

function day_event_foundry_squad_health_totals_refresh(_squad_type)
{
	for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
	{
		var _squad = global.squads[_squad_index];

		if (!is_struct(_squad) || _squad.squad_type != _squad_type)
		{
			continue;
		}

		var _total_max_hp = 0;

		for (var _unit_index = 0; _unit_index < array_length(_squad.units); ++_unit_index)
		{
			var _unit = _squad.units[_unit_index];

			if (instance_exists(_unit) && variable_instance_exists(_unit, "max_hp"))
			{
				_total_max_hp += _unit.max_hp;
			}
		}

		_squad.total_max_hp = _total_max_hp;
	}
}

function day_event_foundry_upgrade_execute(_event, _assigned_cultists, _data)
{
	var _upgraded_squad_type = -1;
	var _health_was_upgraded = false;

	switch (_data.upgrade_id)
	{
		case "demon_health":
			global.foundry_demon_health_multiplier *= BALANCE_FOUNDRY_ARMY_UPGRADE_MULTIPLIER;
			_upgraded_squad_type = SQUAD_TYPE.DEMON;
			_health_was_upgraded = true;
			break;

		case "demon_damage":
			global.foundry_demon_damage_multiplier *= BALANCE_FOUNDRY_ARMY_UPGRADE_MULTIPLIER;
			_upgraded_squad_type = SQUAD_TYPE.DEMON;
			break;

		case "undead_health":
			global.foundry_undead_health_multiplier *= BALANCE_FOUNDRY_ARMY_UPGRADE_MULTIPLIER;
			_upgraded_squad_type = SQUAD_TYPE.UNDEAD;
			_health_was_upgraded = true;
			break;

		case "undead_attack_speed":
			global.foundry_undead_attack_speed_multiplier *= BALANCE_FOUNDRY_ARMY_UPGRADE_MULTIPLIER;
			_upgraded_squad_type = SQUAD_TYPE.UNDEAD;
			break;

		default:
			return false;
	}

	// Update current units now; future units read the same global multipliers after spawning.
	with (o_friendly_units)
	{
		foundry_unit_permanent_bonuses_apply(id);
		foundry_permanent_bonuses_pending = false;
	}

	if (_health_was_upgraded)
	{
		day_event_foundry_squad_health_totals_refresh(_upgraded_squad_type);
	}

	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}

function day_event_foundry_structure_cost_get()
{
	return day_event_random_cultist_cost_get(
		BALANCE_FOUNDRY_STRUCTURE_EVENT_GROUP_CULTIST_COUNT,
		BALANCE_FOUNDRY_STRUCTURE_EVENT_GROUP_HP_COST,
		BALANCE_FOUNDRY_STRUCTURE_EVENT_SOLO_CULTIST_COUNT,
		BALANCE_FOUNDRY_STRUCTURE_EVENT_SOLO_HP_COST
	);
}

function day_event_foundry_tower_upgrade_execute(_event, _assigned_cultists, _data)
{
	switch (_data.upgrade_id)
	{
		case "tower_damage":
			global.foundry_tower_damage_base_bonus += BALANCE_FOUNDRY_TOWER_DAMAGE_BASE_BONUS;

			// Refresh both offensive tower types with the new permanent bonus.
			with (o_tower_damage)
			{
				map_building_upgrade_effect_apply(1);
			}

			with (o_magic_tower)
			{
				magic_damage = base_magic_damage * (1 + global.foundry_tower_damage_base_bonus);
			}
			break;

		case "tower_radius":
			global.foundry_tower_radius_base_bonus += BALANCE_FOUNDRY_TOWER_RADIUS_BASE_BONUS;

			// Refresh every current player tower; future towers read the same global bonus on creation.
			with (o_tower_damage)
			{
				map_building_upgrade_effect_apply(0);
			}

			with (o_tower_heal)
			{
				map_building_upgrade_effect_apply(0);
			}

			with (o_tower_corruption)
			{
				map_building_upgrade_effect_apply(0);
			}

			with (o_tower_vision)
			{
				map_building_upgrade_effect_apply(0);
			}

			with (o_magic_tower)
			{
				shoot_radius = base_shoot_radius
					* (global.player_tower_radius_multiplier + global.foundry_tower_radius_base_bonus);
			}
			break;

		default:
			return false;
	}

	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}

function day_event_foundry_wall_repair_execute(_event, _assigned_cultists, _data)
{
	if (!instance_exists(o_cannon))
	{
		return false;
	}

	var _cannon = instance_find(o_cannon, 0);

	if (!variable_instance_exists(_cannon, "hp")
		|| !variable_instance_exists(_cannon, "max_hp")
		|| _cannon.hp >= _cannon.max_hp)
	{
		return false;
	}

	var _repair_amount = _cannon.max_hp * BALANCE_FOUNDRY_WALL_REPAIR_MAX_HP_SHARE;
	_cannon.hp = min(_cannon.hp + _repair_amount, _cannon.max_hp);
	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}

function day_event_foundry_training_execute(_event, _assigned_cultists, _data)
{
	var _target = day_event_foundry_archdemon_target_get(
		_data.target_archdemon_index,
		_data.target_archdemon_name
	);

	if (!instance_exists(_target))
	{
		return false;
	}

	var _leveled_up = cultist_level_add(_target);

	if (_leveled_up && instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);

		if (variable_instance_exists(_game_controller, "ensure_cultist_levelup_options"))
		{
			_game_controller.ensure_cultist_levelup_options(_target);
		}
	}

	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}

function day_event_foundry_artifacts_spawn(_foundry, _artifact_stat, _artifact_count)
{
	var _origin_x = 0;
	var _origin_y = 0;

	if (instance_exists(_foundry))
	{
		_origin_x = _foundry.x;
		_origin_y = _foundry.y;
	}
	else if (instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);
		_origin_x = _cannon.x;
		_origin_y = _cannon.y;
	}
	else
	{
		return 0;
	}

	var _spawned_count = 0;

	for (var _artifact_index = 0; _artifact_index < _artifact_count; ++_artifact_index)
	{
		var _spawn_direction = 210 + (_artifact_index * 120);
		var _spawn_distance = 70;
		var _artifact = instance_create_layer(
			_origin_x + lengthdir_x(_spawn_distance, _spawn_direction),
			_origin_y + lengthdir_y(_spawn_distance, _spawn_direction),
			"Instances",
			o_artifact
		);

		if (!instance_exists(_artifact))
		{
			continue;
		}

		_artifact.artifact_stat = _artifact_stat;
		_artifact.artifact_sprite_apply();
		_spawned_count++;
	}

	return _spawned_count;
}

function day_event_foundry_artifact_execute(_event, _assigned_cultists, _data)
{
	var _artifact_stat = _data.artifact_stat;

	if (_artifact_stat < 0)
	{
		_artifact_stat = irandom(CULTIST_STAT.COUNT - 1);
	}

	var _spawned_count = day_event_foundry_artifacts_spawn(
		_data.foundry,
		_artifact_stat,
		_data.artifact_count
	);

	if (_spawned_count <= 0)
	{
		return false;
	}

	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}

function day_event_foundry_event_create(
	_foundry,
	_event_id,
	_title,
	_description,
	_cultist_cost,
	_action_type,
	_action_callback,
	_action_data
)
{
	var _event = new day_event_constructor(
		_event_id + "_" + string(_foundry),
		_title,
		_description,
		_cultist_cost,
		1,
		[new event_action_constructor(_action_type, _action_callback, _action_data)]
	);
	_event.source_building = _foundry;
	return _event;
}

function day_event_foundry_relic_choices_roll(_excluded_choices = [])
{
	var _available_relics = [
		RELIC.HELLRUNNER_GREAVES,
		RELIC.HEARTCAGE_PLATE,
		RELIC.SAINTSPLITTER,
		RELIC.SIX_FINGERED_GAUNTLET,
		RELIC.HEXEATER_MASK,
		RELIC.BLASPHEMY_SHIELD
	];

	// A reroll replaces both visible offers instead of returning either current Relic.
	if (is_array(_excluded_choices))
	{
		for (var _relic_index = array_length(_available_relics) - 1;
			_relic_index >= 0;
			--_relic_index)
		{
			var _available_relic = _available_relics[_relic_index];

			for (var _excluded_index = 0;
				_excluded_index < array_length(_excluded_choices);
				++_excluded_index)
			{
				var _excluded_choice = _excluded_choices[_excluded_index];

				if (is_struct(_excluded_choice)
					&& variable_struct_exists(_excluded_choice, "relic")
					&& _excluded_choice.relic == _available_relic)
				{
					array_delete(_available_relics, _relic_index, 1);
					break;
				}
			}
		}
	}

	var _choices = [];
	var _choice_count = min(
		BALANCE_FOUNDRY_RELIC_OPTION_COUNT,
		array_length(_available_relics)
	);

	// Remove each roll from the source array so all offers are distinct.
	for (var _choice_index = 0; _choice_index < _choice_count; ++_choice_index)
	{
		var _roll_index = irandom(array_length(_available_relics) - 1);
		var _relic = _available_relics[_roll_index];
		array_delete(_available_relics, _roll_index, 1);
		array_push(_choices, {
			label: squad_relic_name_get(_relic),
			icon_sprite: squad_relic_sprite_get(_relic),
			relic: _relic
		});
	}

	return _choices;
}

function day_event_foundry_relic_execute(_event, _assigned_cultists, _data)
{
	if (!variable_struct_exists(_event, "selected_squad")
		|| !is_struct(_event.selected_squad)
		|| !variable_struct_exists(_event, "unit_choice_options")
		|| !is_array(_event.unit_choice_options)
		|| !variable_struct_exists(_event, "selected_unit_choice_index"))
	{
		return false;
	}

	var _choice_index = floor(_event.selected_unit_choice_index);

	if (_choice_index < 0 || _choice_index >= array_length(_event.unit_choice_options))
	{
		return false;
	}

	var _choice = _event.unit_choice_options[_choice_index];

	if (!is_struct(_choice)
		|| !variable_struct_exists(_choice, "relic")
		|| !squad_relic_add(_event.selected_squad, _choice.relic))
	{
		return false;
	}

	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}

function day_event_foundry_relic_event_create(_foundry, _excluded_choices = [])
{
	var _eligible_squads = day_event_squads_with_relic_space_get();

	// Keep the card visible even when it must wait for a squad with a free Relic slot.
	if (!instance_exists(_foundry))
	{
		return noone;
	}

	var _event = day_event_foundry_event_create(
		_foundry,
		"foundry_forge_relic",
		"Forge a Relic",
		"Select a squad. Choose one of "
			+ string(BALANCE_FOUNDRY_RELIC_OPTION_COUNT)
			+ " offered Relics.",
		BALANCE_FOUNDRY_RELIC_CULTIST_COUNT,
		"foundry_forge_relic",
		day_event_foundry_relic_execute,
		{
			requires_relic_space: true,
			hp_cost: BALANCE_FOUNDRY_RELIC_HP_COST
		}
	);
	_event.unit_choice_options = day_event_foundry_relic_choices_roll(_excluded_choices);
	_event.selected_unit_choice_index = 0;
	_event.reroll_refreshes_relic_choices = true;
	_event.reroll_is_available = true;
	day_event_squad_selection_add(_event, _eligible_squads);
	return _event;
}

function day_event_foundry_events_add(_foundry)
{
	var _event = day_event_foundry_relic_event_create(_foundry);

	if (!is_struct(_event))
	{
		return false;
	}

	return day_event_add(_event);
}

function day_event_foundry_legacy_events_add(_foundry)
{
	var _demon_health_cost = day_event_random_cultist_cost_get(
		BALANCE_FOUNDRY_UPGRADE_GROUP_CULTIST_COUNT,
		BALANCE_FOUNDRY_UPGRADE_GROUP_HP_COST,
		BALANCE_FOUNDRY_UPGRADE_SOLO_CULTIST_COUNT,
		BALANCE_FOUNDRY_UPGRADE_SOLO_HP_COST
	);
	day_event_add(day_event_foundry_event_create(
		_foundry,
		"foundry_flesh_of_the_pit",
		"Flesh of the Pit",
		"Permanently increases the maximum health of all Demons by 10%, excluding Archdemons.",
		_demon_health_cost.cultist_count,
		"foundry_army_upgrade",
		day_event_foundry_upgrade_execute,
		{ upgrade_id: "demon_health", hp_cost: _demon_health_cost.hp_cost }
	));

	var _demon_damage_cost = day_event_random_cultist_cost_get(
		BALANCE_FOUNDRY_UPGRADE_GROUP_CULTIST_COUNT,
		BALANCE_FOUNDRY_UPGRADE_GROUP_HP_COST,
		BALANCE_FOUNDRY_UPGRADE_SOLO_CULTIST_COUNT,
		BALANCE_FOUNDRY_UPGRADE_SOLO_HP_COST
	);
	day_event_add(day_event_foundry_event_create(
		_foundry,
		"foundry_lessons_in_cruelty",
		"Lessons in Cruelty",
		"Permanently increases the damage of all Demons by 10%, excluding Archdemons.",
		_demon_damage_cost.cultist_count,
		"foundry_army_upgrade",
		day_event_foundry_upgrade_execute,
		{ upgrade_id: "demon_damage", hp_cost: _demon_damage_cost.hp_cost }
	));

	var _undead_health_cost = day_event_random_cultist_cost_get(
		BALANCE_FOUNDRY_UPGRADE_GROUP_CULTIST_COUNT,
		BALANCE_FOUNDRY_UPGRADE_GROUP_HP_COST,
		BALANCE_FOUNDRY_UPGRADE_SOLO_CULTIST_COUNT,
		BALANCE_FOUNDRY_UPGRADE_SOLO_HP_COST
	);
	day_event_add(day_event_foundry_event_create(
		_foundry,
		"foundry_reinforced_bones",
		"Reinforced Bones",
		"Permanently increases the maximum health of all Undead units by 10%.",
		_undead_health_cost.cultist_count,
		"foundry_army_upgrade",
		day_event_foundry_upgrade_execute,
		{ upgrade_id: "undead_health", hp_cost: _undead_health_cost.hp_cost }
	));

	var _undead_speed_cost = day_event_random_cultist_cost_get(
		BALANCE_FOUNDRY_UPGRADE_GROUP_CULTIST_COUNT,
		BALANCE_FOUNDRY_UPGRADE_GROUP_HP_COST,
		BALANCE_FOUNDRY_UPGRADE_SOLO_CULTIST_COUNT,
		BALANCE_FOUNDRY_UPGRADE_SOLO_HP_COST
	);
	day_event_add(day_event_foundry_event_create(
		_foundry,
		"foundry_no_time_to_rot",
		"No Time to Rot",
		"Permanently increases the attack speed of all Undead units by 10%.",
		_undead_speed_cost.cultist_count,
		"foundry_army_upgrade",
		day_event_foundry_upgrade_execute,
		{ upgrade_id: "undead_attack_speed", hp_cost: _undead_speed_cost.hp_cost }
	));

	var _tower_damage_cost = day_event_foundry_structure_cost_get();
	day_event_add(day_event_foundry_event_create(
		_foundry,
		"foundry_doctrine_of_destruction",
		"Doctrine of Destruction",
		"Permanently increases the damage of all your towers by "
			+ string(round(BALANCE_FOUNDRY_TOWER_DAMAGE_BASE_BONUS * 100))
			+ "% of their base damage.",
		_tower_damage_cost.cultist_count,
		"foundry_tower_damage_upgrade",
		day_event_foundry_tower_upgrade_execute,
		{ upgrade_id: "tower_damage", hp_cost: _tower_damage_cost.hp_cost }
	));

	var _tower_radius_cost = day_event_foundry_structure_cost_get();
	day_event_add(day_event_foundry_event_create(
		_foundry,
		"foundry_unhallowed_reach",
		"Unhallowed Reach",
		"Permanently increases the effect radius of all your towers by "
			+ string(round(BALANCE_FOUNDRY_TOWER_RADIUS_BASE_BONUS * 100))
			+ "% of their base radius.",
		_tower_radius_cost.cultist_count,
		"foundry_tower_radius_upgrade",
		day_event_foundry_tower_upgrade_execute,
		{ upgrade_id: "tower_radius", hp_cost: _tower_radius_cost.hp_cost }
	));

	// Wall repair is omitted from the daily pool when the Wall is already at full HP.
	if (instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);

		if (variable_instance_exists(_cannon, "hp")
			&& variable_instance_exists(_cannon, "max_hp")
			&& _cannon.hp < _cannon.max_hp)
		{
			var _wall_repair_cost = day_event_foundry_structure_cost_get();
			day_event_add(day_event_foundry_event_create(
				_foundry,
				"foundry_sacrificial_repairs",
				"Sacrificial Repairs",
				"Repairs the Wall for "
					+ string(round(BALANCE_FOUNDRY_WALL_REPAIR_MAX_HP_SHARE * 100))
					+ "% of its maximum HP.",
				_wall_repair_cost.cultist_count,
				"foundry_wall_repair",
				day_event_foundry_wall_repair_execute,
				{ hp_cost: _wall_repair_cost.hp_cost }
			));
		}
	}

	// Training locks one random Archdemon when the card is generated.
	var _eligible_archdemon_indices = [];

	for (var _archdemon_index = 0; _archdemon_index < array_length(global.archdemons); ++_archdemon_index)
	{
		if (instance_exists(global.archdemons[_archdemon_index]))
		{
			array_push(_eligible_archdemon_indices, _archdemon_index);
		}
	}

	if (array_length(_eligible_archdemon_indices) > 0)
	{
		var _target_index = _eligible_archdemon_indices[irandom(array_length(_eligible_archdemon_indices) - 1)];
		var _target = global.archdemons[_target_index];
		var _target_name = variable_instance_exists(_target, "cultist_name")
			? _target.cultist_name
			: "Archdemon";
		// The portrait uses the Archdemon's current demonic form, never its legacy Cultist sprite.
		var _target_sprite = _target.sprite_index;
		var _training_event = day_event_foundry_event_create(
			_foundry,
			"foundry_archdemon_training",
			"Archdemon Training",
			"Grant " + _target_name + " +1 level.",
			BALANCE_FOUNDRY_ARCHDEMON_TRAINING_CULTIST_COUNT,
			"foundry_archdemon_training",
			day_event_foundry_training_execute,
			{
				target_archdemon_index: _target_index,
				target_archdemon_name: _target_name,
				hp_cost: BALANCE_FOUNDRY_ARCHDEMON_TRAINING_HP_COST
			}
		);
		_training_event.target_archdemon_name = _target_name;
		_training_event.target_archdemon_sprite = _target_sprite;
		_training_event.target_archdemon_frame = 0;
		day_event_add(_training_event);
	}

	var _relic_stat = irandom(CULTIST_STAT.COUNT - 1);
	var _relic_stat_name = day_event_foundry_stat_name_get(_relic_stat);
	day_event_add(day_event_foundry_event_create(
		_foundry,
		"foundry_relics_of_great_power",
		"Relics of Great Power",
		"Create a " + _relic_stat_name + " artifact for an Archdemon. It grants +1 "
			+ _relic_stat_name + ".",
		BALANCE_FOUNDRY_RELIC_CULTIST_COUNT,
		"foundry_artifact",
		day_event_foundry_artifact_execute,
		{
			foundry: _foundry,
			artifact_stat: _relic_stat,
			artifact_count: 1,
			hp_cost: BALANCE_FOUNDRY_RELIC_HP_COST
		}
	));

	var _spoils_cost = day_event_random_cultist_cost_get(
		BALANCE_FOUNDRY_UPGRADE_GROUP_CULTIST_COUNT,
		BALANCE_FOUNDRY_UPGRADE_GROUP_HP_COST,
		BALANCE_FOUNDRY_UPGRADE_SOLO_CULTIST_COUNT,
		BALANCE_FOUNDRY_UPGRADE_SOLO_HP_COST
	);
	day_event_add(day_event_foundry_event_create(
		_foundry,
		"foundry_spoils_of_the_abyss",
		"Spoils of the Abyss",
		"Create 2 identical random artifacts for an Archdemon. Their shared attribute is hidden until completion.",
		_spoils_cost.cultist_count,
		"foundry_artifact",
		day_event_foundry_artifact_execute,
		{
			foundry: _foundry,
			artifact_stat: -1,
			artifact_count: BALANCE_FOUNDRY_SPOILS_ARTIFACT_COUNT,
			hp_cost: _spoils_cost.hp_cost
		}
	));
}

function day_event_ritual_effect_execute(_event, _assigned_cultists, _data)
{
	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);

	switch (_data.effect_id)
	{
		case "black_pilgrimage":
			global.ritual_black_pilgrimage_active = true;
			break;

		case "grasping_soil":
			global.ritual_grasping_soil_active = true;
			break;

		case "awaken_taint":
			global.ritual_awaken_taint_active = true;
			break;

		case "rust_righteous":
			global.ritual_rust_righteous_active = true;
			break;

		case "silence_choir":
			global.ritual_silence_choir_active = true;
			break;

		case "blood_night":
			global.ritual_blood_night_active = true;
			break;

		case "invite_worthy":
			global.ritual_invite_worthy_active = true;
			global.ritual_invite_worthy_reward_pending = true;
			break;

		case "lesser_gate":
			global.ritual_lesser_gate_active = true;
			break;
	}

	return true;
}

function day_event_ritual_hell_weakest_execute(_event, _assigned_cultists, _data)
{
	if (!variable_struct_exists(_event, "selected_squad") || !is_struct(_event.selected_squad))
	{
		return false;
	}

	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	global.ritual_hell_weakest_active = true;
	global.ritual_hell_weakest_squad = _event.selected_squad;
	return true;
}

function day_event_ritual_create(
	_ritual_circle,
	_event_id,
	_title,
	_description,
	_cultist_count,
	_hp_cost
)
{
	var _event = new day_event_constructor(
		"ritual_" + _event_id + "_" + string(_ritual_circle),
		_title,
		_description,
		_cultist_count,
		1,
		[
			new event_action_constructor(
				"ritual_night_effect",
				day_event_ritual_effect_execute,
				{ effect_id: _event_id, hp_cost: _hp_cost }
			)
		]
	);
	_event.source_building = _ritual_circle;
	return _event;
}

function day_event_ritual_events_add(_ritual_circle)
{
	day_event_add(day_event_ritual_create(
		_ritual_circle,
		"black_pilgrimage",
		"Black Pilgrimage",
		"All allied squads gain 30% movement speed while standing on tainted ground next night.",
		BALANCE_RITUAL_EVENT_CULTIST_COUNT,
		BALANCE_RITUAL_EVENT_HP_COST
	));
	day_event_add(day_event_ritual_create(
		_ritual_circle,
		"grasping_soil",
		"Grasping Soil",
		"Enemies standing on tainted ground move 35% slower next night.",
		BALANCE_RITUAL_EVENT_CULTIST_COUNT,
		BALANCE_RITUAL_EVENT_HP_COST
	));
	day_event_add(day_event_ritual_create(
		_ritual_circle,
		"awaken_taint",
		"Awaken the Taint",
		"All enemies standing on tainted ground take 25% more damage next night.",
		BALANCE_RITUAL_EVENT_CULTIST_COUNT,
		BALANCE_RITUAL_EVENT_HP_COST
	));
	day_event_add(day_event_ritual_create(
		_ritual_circle,
		"rust_righteous",
		"Rust the Righteous",
		"Reduce enemy Physical Armor by 30, but not below 0, next night.",
		BALANCE_RITUAL_EVENT_CULTIST_COUNT,
		BALANCE_RITUAL_EVENT_HP_COST
	));
	day_event_add(day_event_ritual_create(
		_ritual_circle,
		"silence_choir",
		"Silence the Choir",
		"Reduce enemy Magic Resistance by 30, but not below 0, next night.",
		BALANCE_RITUAL_EVENT_CULTIST_COUNT,
		BALANCE_RITUAL_EVENT_HP_COST
	));
	day_event_add(day_event_ritual_create(
		_ritual_circle,
		"blood_night",
		"Blood Night",
		"All allied and enemy units deal 50% more damage next night.",
		BALANCE_RITUAL_EVENT_CULTIST_COUNT,
		BALANCE_RITUAL_EVENT_HP_COST
	));
	day_event_add(day_event_ritual_create(
		_ritual_circle,
		"invite_worthy",
		"Invite the Worthy",
		"Add 20% more enemies next night. If the cannon survives, every summoned building generates one additional event tomorrow.",
		BALANCE_RITUAL_EVENT_CULTIST_COUNT,
		BALANCE_RITUAL_EVENT_HP_COST
	));
	day_event_add(day_event_ritual_create(
		_ritual_circle,
		"lesser_gate",
		"Open the Lesser Gate",
		"A temporary portal appears near the Cannon next night. Every 5 seconds it releases a random friendly creature that fights until morning.",
		BALANCE_RITUAL_EVENT_CULTIST_COUNT,
		BALANCE_RITUAL_EVENT_HP_COST
	));

	var _eligible_squads = [];
	array_copy(_eligible_squads, 0, global.squads, 0, array_length(global.squads));
	var _hell_event = new day_event_constructor(
		"ritual_hell_weakest_" + string(_ritual_circle),
		"Hell Takes the Weakest",
		"Choose one squad that cannot be deployed next night. All other squads gain 25% damage, health and attack speed for that night.",
		BALANCE_RITUAL_EVENT_CULTIST_COUNT,
		1,
		[
			new event_action_constructor(
				"ritual_hell_weakest",
				day_event_ritual_hell_weakest_execute,
				{ hp_cost: BALANCE_RITUAL_EVENT_HP_COST }
			)
		]
	);
	_hell_event.source_building = _ritual_circle;
	day_event_add(day_event_squad_selection_add(_hell_event, _eligible_squads));
}

function day_event_summoning_grounds_events_add(_summoning_grounds)
{
	if (!instance_exists(_summoning_grounds))
	{
		return;
	}

	var _eligible_squads = [];
	array_copy(_eligible_squads, 0, global.squads, 0, array_length(global.squads));

	// Every Summoning Grounds ritual may reinforce any currently active player squad.
	var _ripcage_event = day_event_squad_create(
		_summoning_grounds,
		"summon_ripcage_cannon",
		"Summon Ripcage Cannon",
		"Summon one Ripcage Cannon into the selected squad. It has a very long-range, slow AOE attack and is recommended for ranged squads.",
		BALANCE_SUMMONING_GROUNDS_EVENT_CULTIST_COUNT,
		"add_ripcage_cannon_to_squad",
		day_event_squad_unit_add_execute,
		{
			unit_object: o_ripcage_cannon,
			unit_count: BALANCE_SUMMONING_GROUNDS_EVENT_UNIT_COUNT,
			hp_cost: BALANCE_SUMMONING_GROUNDS_EVENT_HP_COST
		}
	);
	day_event_add(day_event_squad_selection_add(_ripcage_event, _eligible_squads));

	var _bannerman_event = day_event_squad_create(
		_summoning_grounds,
		"summon_bone_bannerman",
		"Summon Bone Bannerman",
		"Summon one Bone Bannerman into the selected squad. Its aura grants nearby units +20% movement speed and +15% attack speed.",
		BALANCE_SUMMONING_GROUNDS_EVENT_CULTIST_COUNT,
		"add_bone_bannerman_to_squad",
		day_event_squad_unit_add_execute,
		{
			unit_object: o_bone_bannerman,
			unit_count: BALANCE_SUMMONING_GROUNDS_EVENT_UNIT_COUNT,
			hp_cost: BALANCE_SUMMONING_GROUNDS_EVENT_HP_COST
		}
	);
	day_event_add(day_event_squad_selection_add(_bannerman_event, _eligible_squads));

	var _provocateur_event = day_event_squad_create(
		_summoning_grounds,
		"summon_provocateur",
		"Summon Provocateur",
		"Summon one Provocateur into the selected squad. It has high health and forces nearby enemies to attack it instead of your other units, but cannot attack.",
		BALANCE_SUMMONING_GROUNDS_EVENT_CULTIST_COUNT,
		"add_provocateur_to_squad",
		day_event_squad_unit_add_execute,
		{
			unit_object: o_provocateur,
			unit_count: BALANCE_SUMMONING_GROUNDS_EVENT_UNIT_COUNT,
			hp_cost: BALANCE_SUMMONING_GROUNDS_PROVOCATEUR_HP_COST
		}
	);
	day_event_add(day_event_squad_selection_add(_provocateur_event, _eligible_squads));

	var _healer_event = day_event_squad_create(
		_summoning_grounds,
		"summon_skeleton_healers",
		"Summon Skeleton Healers",
		"Summon " + string(BALANCE_SUMMONING_GROUNDS_SUPPORT_EVENT_UNIT_COUNT)
			+ " Skeleton Healers in any squad. They will heal all units in the squad.",
		BALANCE_SUMMONING_GROUNDS_SUPPORT_EVENT_CULTIST_COUNT,
		"add_skeleton_healers_to_squad",
		day_event_squad_unit_add_execute,
		{
			unit_object: o_skeleton_healer,
			unit_count: BALANCE_SUMMONING_GROUNDS_SUPPORT_EVENT_UNIT_COUNT,
			hp_cost: BALANCE_SUMMONING_GROUNDS_SUPPORT_EVENT_HP_COST
		}
	);
	day_event_add(day_event_squad_selection_add(_healer_event, _eligible_squads));

	var _wizard_event = day_event_squad_create(
		_summoning_grounds,
		"summon_demon_wizards",
		"Summon Demon Wizards",
		"Summon " + string(BALANCE_SUMMONING_GROUNDS_SUPPORT_EVENT_UNIT_COUNT)
			+ " Demon Wizards in any squad. They will buff damage and speed of squad units.",
		BALANCE_SUMMONING_GROUNDS_SUPPORT_EVENT_CULTIST_COUNT,
		"add_demon_wizards_to_squad",
		day_event_squad_unit_add_execute,
		{
			unit_object: o_demon_wizard,
			unit_count: BALANCE_SUMMONING_GROUNDS_SUPPORT_EVENT_UNIT_COUNT,
			hp_cost: BALANCE_SUMMONING_GROUNDS_SUPPORT_EVENT_HP_COST
		}
	);
	day_event_add(day_event_squad_selection_add(_wizard_event, _eligible_squads));
}

function day_event_blood_warpaint_execute(_event, _assigned_cultists, _data)
{
	global.blood_bath_warpaint_morning_pending = true;
	global.blood_bath_warpaint_affects_unconscious =
		global.blood_bath_warpaint_affects_unconscious
		|| day_event_affects_unconscious_cultists(_data);
	return true;
}

function day_event_blood_bath_create(
	_building,
	_event_id,
	_title,
	_description,
	_cultist_cost,
	_activation_limit,
	_action_callback,
	_action_data = {}
)
{
	var _event = new day_event_constructor(
		_event_id + "_" + string(_building),
		_title,
		_description,
		_cultist_cost,
		_activation_limit,
		[new event_action_constructor(_event_id, _action_callback, _action_data)]
	);
	_event.source_building = _building;

	// The healing Blood Bath Rite displeases the Cannon once when its card executes.
	if (_event_id == "blood_bath")
	{
		// Healing can start with one participant while keeping every optional slot available.
		_event.execution_cultist_minimum = _event.cultist_cost;
		_event.cannon_satisfaction_cost = BALANCE_BLOOD_BATH_CANNON_SATISFACTION_COST;
		day_event_modifier_add(
			_event,
			"-" + string(BALANCE_BLOOD_BATH_CANNON_SATISFACTION_COST)
				+ " Cannon Satisfaction"
		);
	}

	// Pin and Reroll provide no choice while Blood Bath exposes a single Rite.
	if (!BLOOD_BATH_FULL_EVENT_SET_ENABLED)
	{
		_event.reroll_is_available = false;
		_event.can_pin = false;
	}

	return _event;
}

function day_event_shell_factory_enchantment_execute(_event, _assigned_cultists, _data)
{
	// A funded permanent enchantment remains valid even if its source building changed before day resolution.
	if (global.shell_factory_taint_enchantment_event_completed
		|| !is_struct(_event)
		|| !variable_struct_exists(_event, "unit_choice_options")
		|| !is_array(_event.unit_choice_options)
		|| !variable_struct_exists(_event, "selected_unit_choice_index"))
	{
		return false;
	}

	var _choice_count = array_length(_event.unit_choice_options);
	var _choice_index = floor(_event.selected_unit_choice_index);

	if (_choice_index < 0 || _choice_index >= _choice_count)
	{
		return false;
	}

	var _choice = _event.unit_choice_options[_choice_index];

	if (!is_struct(_choice)
		|| !variable_struct_exists(_choice, "shell_enchantment")
		|| _choice.shell_enchantment == TAINT_COMPOST_ENCHANTMENT.NONE)
	{
		return false;
	}

	global.shell_factory_taint_enchantment = _choice.shell_enchantment;
	global.shell_factory_taint_enchantment_event_completed = true;
	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}

function day_event_shell_factory_enchantment_create(_shell_factory)
{
	if (!instance_exists(_shell_factory)
		|| _shell_factory.object_index != o_shell_factory
		|| global.shell_factory_taint_enchantment_event_completed)
	{
		return noone;
	}

	var _event = new day_event_constructor(
		"shell_factory_taint_compost_enchantment_" + string(_shell_factory),
		"Taint Compost Shell Enchantment",
		"Choose one permanent enchantment for Taint Compost shells. Hover an option to inspect its effect.",
		BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_COUNT,
		1,
		[
			new event_action_constructor(
				"enchant_taint_compost_shells",
				day_event_shell_factory_enchantment_execute,
				{ hp_cost: BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_HP_COST }
			)
		]
	);
	_event.source_building = _shell_factory;
	_event.unit_choice_options = [
		{
			title: "Explosive Fertilizer",
			label: "Fertilizer",
			icon_sprite: s_pumpkin_mine,
			shell_enchantment: TAINT_COMPOST_ENCHANTMENT.EXPLOSIVE_FERTILIZER,
			description: "Each Taint Compost shot creates "
				+ string(BALANCE_TAINT_COMPOST_PUMPKIN_MINE_COUNT)
				+ " Pumpkin Mines at the center of its impact area. The mines persist until destroyed and are not restored."
		},
		{
			title: "Sweet Rot",
			label: "Sweet Rot",
			icon_sprite: s_taint_shell,
			shell_enchantment: TAINT_COMPOST_ENCHANTMENT.SWEET_ROT,
			description: "Each Taint Compost shot creates a tumor that attracts enemies outside combat within a radius of "
				+ string(BALANCE_TAINT_COMPOST_SWEET_ROT_RADIUS)
				+ ". The tumor persists until destroyed and is not restored."
		}
	];
	_event.selected_unit_choice_index = 0;
	_event.reroll_is_available = false;
	return _event;
}

function day_event_shell_factory_first_aid_enchantment_execute(_event, _assigned_cultists, _data)
{
	if (global.shell_factory_first_aid_enchantment_event_completed
		|| !is_struct(_event)
		|| !variable_struct_exists(_event, "source_building")
		|| !instance_exists(_event.source_building)
		|| _event.source_building.object_index != o_shell_factory
		|| !variable_struct_exists(_event, "unit_choice_options")
		|| !is_array(_event.unit_choice_options)
		|| !variable_struct_exists(_event, "selected_unit_choice_index"))
	{
		return false;
	}

	var _choice_count = array_length(_event.unit_choice_options);
	var _choice_index = floor(_event.selected_unit_choice_index);

	if (_choice_index < 0 || _choice_index >= _choice_count)
	{
		return false;
	}

	var _choice = _event.unit_choice_options[_choice_index];

	if (!is_struct(_choice)
		|| !variable_struct_exists(_choice, "shell_enchantment")
		|| _choice.shell_enchantment == FIRST_AID_MEAT_ENCHANTMENT.NONE)
	{
		return false;
	}

	global.shell_factory_first_aid_enchantment = _choice.shell_enchantment;
	global.shell_factory_first_aid_enchantment_event_completed = true;
	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}

function day_event_shell_factory_first_aid_enchantment_create(_shell_factory)
{
	if (!instance_exists(_shell_factory)
		|| _shell_factory.object_index != o_shell_factory
		|| global.shell_factory_first_aid_enchantment_event_completed)
	{
		return noone;
	}

	var _event = new day_event_constructor(
		"shell_factory_first_aid_meat_enchantment_" + string(_shell_factory),
		"First Aid Meat Shell Enchantment",
		"Choose one permanent enchantment for First Aid Meat shells. Hover an option to inspect its effect.",
		BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_COUNT,
		1,
		[
			new event_action_constructor(
				"enchant_first_aid_meat_shells",
				day_event_shell_factory_first_aid_enchantment_execute,
				{ hp_cost: BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_HP_COST }
			)
		]
	);
	_event.source_building = _shell_factory;
	_event.unit_choice_options = [
		{
			title: "Emergency Pull",
			label: "Emergency Pull",
			icon_sprite: s_brute,
			shell_enchantment: FIRST_AID_MEAT_ENCHANTMENT.EMERGENCY_PULL,
			description: "Replaces area healing. Pulls the farthest ally below "
				+ string(BALANCE_FIRST_AID_MEAT_PULL_HP_THRESHOLD * 100)
				+ "% HP from within " + string(BALANCE_FIRST_AID_MEAT_PULL_RADIUS)
				+ " pixels. Each completed pull restores "
				+ string(BALANCE_FIRST_AID_MEAT_PULL_FINISH_HEAL)
				+ " HP and recharges in "
				+ string(BALANCE_FIRST_AID_MEAT_PULL_COOLDOWN) + " seconds."
		},
		{
			title: "Necromedic",
			label: "Necromedic",
			icon_sprite: s_skeleton,
			shell_enchantment: FIRST_AID_MEAT_ENCHANTMENT.NECROMEDIC,
			description: "Replaces area healing. Resurrects up to "
				+ string(BALANCE_FIRST_AID_MEAT_NECROMEDIC_MAX_CORPSES)
				+ " corpses in the impact area as temporary Bonelets. Corpses are consumed. "
				+ "The shell does not remain on the ground. Raised Bonelets are not part of a squad and die in the morning."
		}
	];
	_event.selected_unit_choice_index = 0;
	_event.reroll_is_available = false;
	return _event;
}

function day_event_shell_factory_hellcow_enchantment_execute(_event, _assigned_cultists, _data)
{
	if (global.shell_factory_hellcow_enchantment_event_completed
		|| !is_struct(_event)
		|| !variable_struct_exists(_event, "source_building")
		|| !instance_exists(_event.source_building)
		|| _event.source_building.object_index != o_shell_factory
		|| !variable_struct_exists(_event, "unit_choice_options")
		|| !is_array(_event.unit_choice_options)
		|| !variable_struct_exists(_event, "selected_unit_choice_index"))
	{
		return false;
	}

	var _choice_count = array_length(_event.unit_choice_options);
	var _choice_index = floor(_event.selected_unit_choice_index);

	if (_choice_index < 0 || _choice_index >= _choice_count)
	{
		return false;
	}

	var _choice = _event.unit_choice_options[_choice_index];

	if (!is_struct(_choice)
		|| !variable_struct_exists(_choice, "shell_enchantment")
		|| _choice.shell_enchantment == HELLCOW_ENCHANTMENT.NONE)
	{
		return false;
	}

	global.shell_factory_hellcow_enchantment = _choice.shell_enchantment;
	global.shell_factory_hellcow_enchantment_event_completed = true;
	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}

function day_event_shell_factory_hellcow_enchantment_create(_shell_factory)
{
	if (!instance_exists(_shell_factory)
		|| _shell_factory.object_index != o_shell_factory
		|| global.shell_factory_hellcow_enchantment_event_completed)
	{
		return noone;
	}

	var _event = new day_event_constructor(
		"shell_factory_hellcow_enchantment_" + string(_shell_factory),
		"HellCow Shell Enchantment",
		"Choose one permanent enchantment for HellCow shells. Hover an option to inspect its effect.",
		BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_COUNT,
		1,
		[
			new event_action_constructor(
				"enchant_hellcow_shells",
				day_event_shell_factory_hellcow_enchantment_execute,
				{ hp_cost: BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_HP_COST }
			)
		]
	);
	_event.source_building = _shell_factory;
	_event.unit_choice_options = [
		{
			title: "Final Moo",
			label: "Final Moo",
			icon_sprite: s_cow,
			shell_enchantment: HELLCOW_ENCHANTMENT.FINAL_MOO,
			description: "At the end of its charge, HellCow creates a harmless explosion that stuns enemies within "
				+ string(BALANCE_PROJECTILE_HELLCOW_FINAL_MOO_RADIUS)
				+ " pixels for " + string(BALANCE_PROJECTILE_HELLCOW_FINAL_MOO_STUN_TIME)
				+ " seconds. Stuns from multiple cows do not stack."
		},
		{
			title: "Sticky Trail",
			label: "Sticky Trail",
			icon_sprite: s_cow,
			shell_enchantment: HELLCOW_ENCHANTMENT.STICKY_TRAIL,
			description: "HellCow leaves a visible sticky trail for "
				+ string(BALANCE_PROJECTILE_HELLCOW_STICKY_TRAIL_LIFETIME)
				+ " seconds. Enemies inside are slowed by "
				+ string(BALANCE_PROJECTILE_HELLCOW_STICKY_TRAIL_SLOW_AMOUNT * 100)
				+ "%. The slow does not stack."
		}
	];
	_event.selected_unit_choice_index = 0;
	_event.reroll_is_available = false;
	return _event;
}

function day_event_shell_factory_doom_bell_enchantment_execute(_event, _assigned_cultists, _data)
{
	if (global.shell_factory_doom_bell_enchantment_event_completed
		|| !is_struct(_event)
		|| !variable_struct_exists(_event, "source_building")
		|| !instance_exists(_event.source_building)
		|| _event.source_building.object_index != o_shell_factory
		|| !variable_struct_exists(_event, "unit_choice_options")
		|| !is_array(_event.unit_choice_options)
		|| !variable_struct_exists(_event, "selected_unit_choice_index"))
	{
		return false;
	}

	var _choice_count = array_length(_event.unit_choice_options);
	var _choice_index = floor(_event.selected_unit_choice_index);

	if (_choice_index < 0 || _choice_index >= _choice_count)
	{
		return false;
	}

	var _choice = _event.unit_choice_options[_choice_index];

	if (!is_struct(_choice)
		|| !variable_struct_exists(_choice, "shell_enchantment")
		|| _choice.shell_enchantment == DOOM_BELL_ENCHANTMENT.NONE)
	{
		return false;
	}

	global.shell_factory_doom_bell_enchantment = _choice.shell_enchantment;
	global.shell_factory_doom_bell_enchantment_event_completed = true;
	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}

function day_event_shell_factory_doom_bell_enchantment_create(_shell_factory)
{
	if (!instance_exists(_shell_factory)
		|| _shell_factory.object_index != o_shell_factory
		|| global.shell_factory_doom_bell_enchantment_event_completed)
	{
		return noone;
	}

	var _event = new day_event_constructor(
		"shell_factory_doom_bell_enchantment_" + string(_shell_factory),
		"Doom Bell Shell Enchantment",
		"Choose one permanent enchantment for Doom Bell shells. Hover an option to inspect its effect.",
		BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_COUNT,
		1,
		[
			new event_action_constructor(
				"enchant_doom_bell_shells",
				day_event_shell_factory_doom_bell_enchantment_execute,
				{ hp_cost: BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_HP_COST }
			)
		]
	);
	_event.source_building = _shell_factory;
	_event.unit_choice_options = [
		{
			title: "Funeral Pause",
			label: "Funeral Pause",
			icon_sprite: s_mega_bell,
			shell_enchantment: DOOM_BELL_ENCHANTMENT.FUNERAL_PAUSE,
			description: "Enemies hit by Doom Bell enter stasis for up to "
				+ string(BALANCE_DOOM_BELL_FUNERAL_PAUSE_DURATION)
				+ " seconds: they cannot move or take damage, and player squads ignore them. The landed bell can be destroyed or clicked to release them early. Doom Bell reload is increased by "
				+ string(BALANCE_DOOM_BELL_FUNERAL_PAUSE_RELOAD_PENALTY) + " seconds."
		},
		{
			title: "Dead Silence",
			label: "Dead Silence",
			icon_sprite: s_mega_bell,
			shell_enchantment: DOOM_BELL_ENCHANTMENT.DEAD_SILENCE,
			description: "The landed bell creates a "
				+ string(BALANCE_DOOM_BELL_DEAD_SILENCE_RADIUS)
				+ " pixel silence zone for up to " + string(BALANCE_DOOM_BELL_DEAD_SILENCE_DURATION)
				+ " seconds. Ranged units inside the zone cannot shoot. Units with attack range above "
				+ string(BALANCE_DOOM_BELL_RANGED_ATTACK_RADIUS_MINIMUM)
				+ " pixels count as ranged. The bell can be destroyed or clicked to end the effect early."
		}
	];
	_event.selected_unit_choice_index = 0;
	_event.reroll_is_available = false;
	return _event;
}

function day_event_shell_factory_taint_bloom_execute(_event, _assigned_cultists, _data)
{
	if (global.shell_factory_taint_bloom_event_completed)
	{
		return false;
	}

	global.shell_factory_taint_bloom_event_completed = true;
	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}

function day_event_shell_factory_taint_bloom_create(_shell_factory)
{
	if (!instance_exists(_shell_factory)
		|| _shell_factory.object_index != o_shell_factory
		|| global.shell_factory_taint_bloom_event_completed)
	{
		return noone;
	}

	var _radius_bonus = round((BALANCE_SHELL_FACTORY_TAINT_BLOOM_RADIUS_MULTIPLIER - 1) * 100);
	var _event = new day_event_constructor(
		"shell_factory_taint_bloom_" + string(_shell_factory),
		"Taint Bloom",
		"Permanently increases the Taint Compost Shell's effect radius by "
			+ string(_radius_bonus) + "%.",
		BALANCE_SHELL_FACTORY_UPGRADE_CULTIST_COUNT,
		1,
		[
			new event_action_constructor(
				"shell_factory_taint_bloom",
				day_event_shell_factory_taint_bloom_execute,
				{ hp_cost: BALANCE_SHELL_FACTORY_UPGRADE_CULTIST_HP_COST }
			)
		]
	);
	_event.source_building = _shell_factory;
	_event.reroll_is_available = false;
	return _event;
}

function day_event_shell_factory_opening_barrage_execute(_event, _assigned_cultists, _data)
{
	if (global.shell_factory_opening_barrage_event_completed)
	{
		return false;
	}

	global.shell_factory_opening_barrage_event_completed = true;
	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}

function day_event_shell_factory_opening_barrage_create(_shell_factory)
{
	if (!instance_exists(_shell_factory)
		|| _shell_factory.object_index != o_shell_factory
		|| global.shell_factory_opening_barrage_event_completed)
	{
		return noone;
	}

	var _event = new day_event_constructor(
		"shell_factory_opening_barrage_" + string(_shell_factory),
		"Opening Barrage",
		"The Cannon does not need to reload after its first "
			+ string(BALANCE_SHELL_FACTORY_OPENING_BARRAGE_FREE_SHOT_COUNT)
			+ " shots each night.",
		BALANCE_SHELL_FACTORY_UPGRADE_CULTIST_COUNT,
		1,
		[
			new event_action_constructor(
				"shell_factory_opening_barrage",
				day_event_shell_factory_opening_barrage_execute,
				{ hp_cost: BALANCE_SHELL_FACTORY_UPGRADE_CULTIST_HP_COST }
			)
		]
	);
	_event.source_building = _shell_factory;
	_event.reroll_is_available = false;
	return _event;
}

function day_event_shell_factory_favored_ammunition_execute(_event, _assigned_cultists, _data)
{
	if (global.shell_factory_favored_ammunition_event_completed
		|| !is_struct(_event)
		|| !variable_struct_exists(_event, "unit_choice_options")
		|| !is_array(_event.unit_choice_options)
		|| !variable_struct_exists(_event, "selected_unit_choice_index"))
	{
		return false;
	}

	var _choice_count = array_length(_event.unit_choice_options);
	var _choice_index = floor(_event.selected_unit_choice_index);

	if (_choice_index < 0 || _choice_index >= _choice_count)
	{
		return false;
	}

	var _choice = _event.unit_choice_options[_choice_index];

	if (!is_struct(_choice)
		|| !variable_struct_exists(_choice, "projectile_type")
		|| (_choice.projectile_type != PROJECTILE_TYPE.DOOM_BELL
			&& _choice.projectile_type != PROJECTILE_TYPE.HEAL
			&& _choice.projectile_type != PROJECTILE_TYPE.BOMB))
	{
		return false;
	}

	global.shell_factory_favored_ammunition_projectile_type = _choice.projectile_type;
	global.shell_factory_favored_ammunition_event_completed = true;
	day_event_cultist_hp_cost_apply(_assigned_cultists, _data.hp_cost);
	return true;
}

function day_event_shell_factory_favored_ammunition_create(_shell_factory)
{
	if (!instance_exists(_shell_factory)
		|| _shell_factory.object_index != o_shell_factory
		|| global.shell_factory_favored_ammunition_event_completed)
	{
		return noone;
	}

	var _reload_reduction = round(
		(1 - BALANCE_SHELL_FACTORY_FAVORED_AMMUNITION_RELOAD_TIME_MULTIPLIER) * 100
	);
	var _option_description = "Permanently reduces this shell's reload time by "
		+ string(_reload_reduction) + "%.";
	var _event = new day_event_constructor(
		"shell_factory_favored_ammunition_" + string(_shell_factory),
		"Favored Ammunition",
		"Reduces the selected shell’s reload time by 20%.",
		BALANCE_SHELL_FACTORY_UPGRADE_CULTIST_COUNT,
		1,
		[
			new event_action_constructor(
				"shell_factory_favored_ammunition",
				day_event_shell_factory_favored_ammunition_execute,
				{ hp_cost: BALANCE_SHELL_FACTORY_UPGRADE_CULTIST_HP_COST }
			)
		]
	);
	_event.source_building = _shell_factory;
	_event.unit_choice_options = [
		{
			title: "Doom Bell",
			label: "Doom Bell",
			icon_sprite: s_mega_bell,
			projectile_type: PROJECTILE_TYPE.DOOM_BELL,
			description: _option_description
		},
		{
			title: "First Aid Meat",
			label: "First Aid",
			icon_sprite: s_heal_meat,
			projectile_type: PROJECTILE_TYPE.HEAL,
			description: _option_description
		},
		{
			title: "HellCow",
			label: "HellCow",
			icon_sprite: s_cow,
			projectile_type: PROJECTILE_TYPE.BOMB,
			description: _option_description
		}
	];
	_event.selected_unit_choice_index = 0;
	_event.reroll_is_available = false;
	return _event;
}

function day_event_building_catalog_get(_building_object)
{
	var _entry = function(_title, _description, _cultist_cost = 1)
	{
		return {
			title: _title,
			description: _description,
			cultist_cost: _cultist_cost,
			is_current: false
		};
	};
	var _infernal_regeneration_use_count = min(
		global.blood_bath_infernal_regeneration_uses,
		BALANCE_BLOOD_BATH_INFERNAL_REGENERATION_ACTIVATION_LIMIT
	);
	var _infernal_regeneration_current_percentage = round(
		(BALANCE_ARCHDEMON_DAILY_RECOVERY_SHARE
			+ (_infernal_regeneration_use_count
				* BALANCE_BLOOD_BATH_INFERNAL_REGENERATION_RECOVERY_SHARE))
		* 100
	);
	var _infernal_regeneration_bonus_percentage = round(
		BALANCE_BLOOD_BATH_INFERNAL_REGENERATION_RECOVERY_SHARE * 100
	);
	var _overuse_data = day_event_building_overuse_data_get(_building_object);
	var _overuse_entry = is_struct(_overuse_data)
		? _entry(_overuse_data.title, _overuse_data.description, 1)
		: noone;

	switch (_building_object)
	{
		case o_shell_factory:
			return [
				_overuse_entry,
				_entry(
					"Taint Compost Shell Enchantment",
					"Choose Explosive Fertilizer or Sweet Rot as a permanent Taint Compost enchantment. Can be completed once per match.",
					BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_COUNT
				),
				_entry(
					"First Aid Meat Shell Enchantment",
					"Choose Emergency Pull or Necromedic as a permanent First Aid Meat enchantment. Can be completed once per match.",
					BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_COUNT
				),
				_entry(
					"HellCow Shell Enchantment",
					"Choose Final Moo or Sticky Trail as a permanent HellCow enchantment. Can be completed once per match.",
					BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_COUNT
				),
				_entry(
					"Doom Bell Shell Enchantment",
					"Choose Funeral Pause or Dead Silence as a permanent Doom Bell enchantment. Can be completed once per match.",
					BALANCE_SHELL_FACTORY_ENCHANTMENT_CULTIST_COUNT
				),
				_entry(
					"Taint Bloom",
					"Permanently increases the Taint Compost Shell's effect radius by "
						+ string(round((BALANCE_SHELL_FACTORY_TAINT_BLOOM_RADIUS_MULTIPLIER - 1) * 100))
						+ "%. Can be completed once per match.",
					BALANCE_SHELL_FACTORY_UPGRADE_CULTIST_COUNT
				),
				_entry(
					"Opening Barrage",
					"The Cannon skips reloading after its first "
						+ string(BALANCE_SHELL_FACTORY_OPENING_BARRAGE_FREE_SHOT_COUNT)
						+ " shots each night. Can be completed once per match.",
					BALANCE_SHELL_FACTORY_UPGRADE_CULTIST_COUNT
				),
				_entry(
					"Favored Ammunition",
					"Choose Doom Bell, First Aid Meat, or HellCow. Permanently reduces the selected shell's reload time by "
						+ string(round((1 - BALANCE_SHELL_FACTORY_FAVORED_AMMUNITION_RELOAD_TIME_MULTIPLIER) * 100))
						+ "%. Can be completed once per match.",
					BALANCE_SHELL_FACTORY_UPGRADE_CULTIST_COUNT
				)
			];

		case o_foundry:
			return [
				_overuse_entry,
				_entry("Flesh of the Pit", "Permanently increase maximum health of all Demons by 10%, excluding Archdemons."),
				_entry("Lessons in Cruelty", "Permanently increase damage of all Demons by 10%, excluding Archdemons."),
				_entry("Reinforced Bones", "Permanently increase maximum health of all Undead units by 10%."),
				_entry("No Time to Rot", "Permanently increase attack speed of all Undead units by 10%."),
				_entry("Doctrine of Destruction", "Permanently increase damage of all your towers by "
					+ string(round(BALANCE_FOUNDRY_TOWER_DAMAGE_BASE_BONUS * 100))
					+ "% of their base damage."),
				_entry("Unhallowed Reach", "Permanently increase the effect radius of all your towers by "
					+ string(round(BALANCE_FOUNDRY_TOWER_RADIUS_BASE_BONUS * 100))
					+ "% of their base radius."),
				_entry("Sacrificial Repairs", "Repair the Wall for "
					+ string(round(BALANCE_FOUNDRY_WALL_REPAIR_MAX_HP_SHARE * 100))
					+ "% of its maximum HP."),
				_entry("Archdemon Training", "Grant one randomly selected Archdemon +1 level."),
				_entry("Relics of Great Power", "Create one artifact granting +1 Body, Fervor, or Spirit."),
				_entry("Spoils of the Abyss", "Create 2 identical random artifacts for an Archdemon.")
			];

		case o_summoning_grounds:
			return [
				_overuse_entry,
				_entry(
					"Summon Ripcage Cannon",
					"Summon one Ripcage Cannon into the selected squad. It has a very long-range, slow AOE attack and is recommended for ranged squads.",
					BALANCE_SUMMONING_GROUNDS_EVENT_CULTIST_COUNT
				),
				_entry(
					"Summon Bone Bannerman",
					"Summon one Bone Bannerman into the selected squad. Its aura grants nearby units +20% movement speed and +15% attack speed.",
					BALANCE_SUMMONING_GROUNDS_EVENT_CULTIST_COUNT
				),
				_entry(
					"Summon Provocateur",
					"Summon one Provocateur into the selected squad. It has high health and forces nearby enemies to attack it instead of your other units, but cannot attack.",
					BALANCE_SUMMONING_GROUNDS_EVENT_CULTIST_COUNT
				),
				_entry(
					"Summon Skeleton Healers",
					"Summon " + string(BALANCE_SUMMONING_GROUNDS_SUPPORT_EVENT_UNIT_COUNT)
						+ " Skeleton Healers in any squad. They will heal all units in the squad.",
					BALANCE_SUMMONING_GROUNDS_SUPPORT_EVENT_CULTIST_COUNT
				),
				_entry(
					"Summon Demon Wizards",
					"Summon " + string(BALANCE_SUMMONING_GROUNDS_SUPPORT_EVENT_UNIT_COUNT)
						+ " Demon Wizards in any squad. They will buff damage and speed of squad units.",
					BALANCE_SUMMONING_GROUNDS_SUPPORT_EVENT_CULTIST_COUNT
				)
			];

		case o_ritual_circle:
			return [
				_entry("Black Pilgrimage", "All allied squads move 30% faster on tainted ground next night."),
				_entry("Grasping Soil", "Enemies move 35% slower on tainted ground next night."),
				_entry("Awaken the Taint", "Enemies on tainted ground take 25% more damage next night."),
				_entry("Rust the Righteous", "Reduce enemy Physical Armor by 30 next night, but not below 0."),
				_entry("Silence the Choir", "Reduce enemy Magic Resistance by 30 next night, but not below 0."),
				_entry("Blood Night", "All allied and enemy units deal 50% more damage next night."),
				_entry("Invite the Worthy", "Add 20% more enemies next night. Surviving grants one extra event per building tomorrow."),
				_entry("Open the Lesser Gate", "A temporary portal summons a random friendly creature every 5 seconds next night."),
				_entry("Hell Takes the Weakest", "Block one squad next night. All other squads gain 25% damage, health and attack speed.")
			];

		case o_unholy_shrine:
			return [
				_overuse_entry,
				_entry(
					"Boiling Blood",
					"Endows the squad with Unholy trait: "
						+ squad_unholy_trait_description_get(UNHOLY_TRAIT.BOILING_BLOOD),
					BALANCE_UNHOLY_SHRINE_EVENT_CULTIST_COUNT
				),
				_entry(
					"Stunning Arrival",
					"Endows the squad with Unholy trait: "
						+ squad_unholy_trait_description_get(UNHOLY_TRAIT.STUNNING_ARRIVAL),
					BALANCE_UNHOLY_SHRINE_EVENT_CULTIST_COUNT
				),
				_entry(
					"Savage Leap",
					"Endows the squad with Unholy trait: "
						+ squad_unholy_trait_description_get(UNHOLY_TRAIT.SAVAGE_LEAP),
					BALANCE_UNHOLY_SHRINE_EVENT_CULTIST_COUNT
				),
				_entry(
					"Endless Procession",
					"Endows the squad with Unholy trait: "
						+ squad_unholy_trait_description_get(UNHOLY_TRAIT.ENDLESS_PROCESSION),
					BALANCE_UNHOLY_SHRINE_EVENT_CULTIST_COUNT
				),
				_entry(
					"Taint Treatment",
					"Endows the squad with Unholy trait: "
						+ squad_unholy_trait_description_get(UNHOLY_TRAIT.TAINT_TREATMENT),
					BALANCE_UNHOLY_SHRINE_EVENT_CULTIST_COUNT
				),
				_entry(
					"The Roar of the Abyss",
					"Endows the squad with Unholy trait: "
						+ squad_unholy_trait_description_get(UNHOLY_TRAIT.ROAR_OF_THE_ABYSS),
					BALANCE_UNHOLY_SHRINE_EVENT_CULTIST_COUNT
				),
				_entry(
					"The Power of Twilight",
					"Endows the squad with Unholy trait: "
						+ squad_unholy_trait_description_get(UNHOLY_TRAIT.POWER_OF_TWILIGHT),
					BALANCE_UNHOLY_SHRINE_EVENT_CULTIST_COUNT
				)
			];

		case o_pitlings_pit2:
			return [
				_overuse_entry,
				_entry("Fill the Ranks", "Add " + string(BALANCE_DEMONS_PIT_FILL_UNIT_COUNT) + " units of the most common type to a selected Demon squad."),
				_entry("Mawling Mastery", "Choose whether all Mawlings in a selected squad become Balgors, Succubi, or Pitlings.")
			];

		case o_graveyard2:
			return [
				_overuse_entry,
				_entry("Bonelet Mastery", "Choose whether all Bonelets in a selected squad become Bone Warriors, Bone Mages, or Bone Archers."),
				_entry("Skeleton Draft", "Add " + string(BALANCE_GRAVEYARD_DRAFT_UNIT_COUNT) + " units of the most common type to a selected Undead squad.")
			];

		case o_meat_bath:
			var _blood_bath_event = _entry(
				"Blood Bath",
				"Assigned Cultists restore "
					+ string(BALANCE_BLOOD_BATH_HEAL_AMOUNT)
					+ " HP.",
				BALANCE_BLOOD_BATH_HEAL_CULTIST_LIMIT
			);

			// Keep the catalog consistent with the temporarily limited generated event set.
			if (!BLOOD_BATH_FULL_EVENT_SET_ENABLED)
			{
				return [_overuse_entry, _blood_bath_event];
			}

			return [
				_overuse_entry,
				_entry(
					"Crimson Baptism",
					"All current Cultists restore "
						+ string(BALANCE_BLOOD_BATH_CRIMSON_MORNING_HEAL)
						+ " HP next morning."
				),
				_entry(
					"Infernal Regeneration",
					"Archdemons restore an additional "
						+ string(_infernal_regeneration_bonus_percentage)
						+ "% of their Max HP each day. Current daily recovery: "
						+ string(_infernal_regeneration_current_percentage)
						+ "% of Max HP. Maximum "
						+ string(BALANCE_BLOOD_BATH_INFERNAL_REGENERATION_ACTIVATION_LIMIT)
						+ " activations per game."
				),
				_blood_bath_event,
				_entry(
					"Lingering Wounds",
					"All living Cultists will have the same amount of HP tomorrow morning as they do this morning. Dead Cultists will not be resurrected."
				),
				_entry(
					"Harden the Vessel",
					"If still conscious after the Rite, the assigned Cultist restores "
						+ string(BALANCE_HARDEN_VESSEL_MORNING_HEAL)
						+ " HP next morning."
				),
				_entry(
					"The Bath Demands a Name",
					"All other Cultists fully restore their HP next morning."
				),
				_entry(
					"Blood for Blood",
					"Increase the maximum number of Cultists by "
						+ string(BALANCE_BLOOD_FOR_BLOOD_LIMIT_BONUS)
						+ "."
				),
				_entry(
					"The Cult Must Grow",
					"Recruit "
						+ string(BALANCE_CULT_MUST_GROW_RECRUIT_COUNT)
						+ " new Cultist."
				),
				_entry(
					"Blood Warpaint",
					"Set every living Cultist to "
						+ string(BALANCE_BLOOD_WARPAINT_MORNING_HP)
						+ " HP next morning."
				)
			];
	}

	return [];
}

function day_event_source_event_id_get(_event)
{
	if (!is_struct(_event))
	{
		return "";
	}

	if (variable_struct_exists(_event, "source_event_id"))
	{
		return _event.source_event_id;
	}

	return variable_struct_exists(_event, "event_id")
		? _event.event_id
		: "";
}

function day_event_previous_building_selection_store(_event)
{
	if (!is_struct(_event)
		|| !variable_struct_exists(_event, "source_building")
		|| !instance_exists(_event.source_building)
		|| !variable_instance_exists(_event.source_building, "previous_day_event_ids")
		|| variable_struct_exists(_event, "construction_site"))
	{
		return false;
	}

	var _source_event_id = day_event_source_event_id_get(_event);

	if (_source_event_id == "")
	{
		return false;
	}

	var _source_building = _event.source_building;
	var _previous_event_ids = _source_building.previous_day_event_ids;

	for (var _stored_index = 0; _stored_index < array_length(_previous_event_ids); ++_stored_index)
	{
		if (_previous_event_ids[_stored_index] == _source_event_id)
		{
			return false;
		}
	}

	array_push(_previous_event_ids, _source_event_id);
	_source_building.previous_day_event_ids = _previous_event_ids;
	return true;
}

function day_event_previous_building_selections_store()
{
	var _building_count = instance_number(o_v13buildings_parent);

	// Empty every building first so only the immediately previous day is remembered.
	for (var _building_index = 0; _building_index < _building_count; ++_building_index)
	{
		var _building = instance_find(o_v13buildings_parent, _building_index);

		if (instance_exists(_building))
		{
			_building.previous_day_event_ids = [];
		}
	}

	var _stored_event_count = 0;

	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		if (day_event_previous_building_selection_store(global.day_events[_event_index]))
		{
			_stored_event_count++;
		}
	}

	// Completed cards were removed from the UI, but still count as yesterday's offered choices.
	if (variable_global_exists("day_event_completed_events"))
	{
		for (var _completed_index = 0;
			_completed_index < array_length(global.day_event_completed_events);
			++_completed_index)
		{
			if (day_event_previous_building_selection_store(global.day_event_completed_events[_completed_index]))
			{
				_stored_event_count++;
			}
		}

		global.day_event_completed_events = [];
	}

	return _stored_event_count;
}

function day_event_building_action_is_available(_event)
{
	// Mastery is an independent personal offer, but uses the same pin controls as building Rites.
	if (is_struct(_event)
		&& variable_struct_exists(_event, "is_cultist_mastery")
		&& _event.is_cultist_mastery)
	{
		return !_event.is_resolved && day_event_cultist_mastery_request_is_valid(_event.mastery_request);
	}

	return is_struct(_event)
		&& variable_struct_exists(_event, "source_building")
		&& instance_exists(_event.source_building)
		&& variable_struct_exists(_event, "event_id")
		&& !variable_struct_exists(_event, "construction_site")
		&& (!variable_struct_exists(_event, "is_resolved") || !_event.is_resolved);
}

function day_event_has_funded_activation(_event)
{
	if (!is_struct(_event)
		|| !variable_struct_exists(_event, "assigned_cultists")
		|| !variable_struct_exists(_event, "cultist_cost")
		|| !variable_struct_exists(_event, "activation_limit"))
	{
		return false;
	}

	// Workers separated by empty required slots do not form a funded activation.
	var _activation_limit = _event.activation_limit;

	for (var _activation_index = 0; _activation_index < _activation_limit; ++_activation_index)
	{
		if (day_event_activation_staffing_is_ready(_event, _activation_index))
		{
			return true;
		}
	}

	return false;
}

function day_event_execution_staffing_is_ready(_event)
{
	if (!is_struct(_event)
		|| !variable_struct_exists(_event, "assigned_cultists")
		|| !variable_struct_exists(_event, "cultist_cost")
		|| !variable_struct_exists(_event, "activation_limit")
		|| (variable_struct_exists(_event, "is_resolved") && _event.is_resolved))
	{
		return false;
	}

	// A visible squad Rite cannot be invoked until it has a valid recipient.
	if (variable_struct_exists(_event, "requires_squad_selection")
		&& _event.requires_squad_selection
		&& array_length(_event.eligible_squads) <= 0)
	{
		return false;
	}

	var _required_cultist_count = variable_struct_exists(_event, "execution_cultist_minimum")
		? _event.execution_cultist_minimum
		: _event.cultist_cost * _event.activation_limit;
	var _funded_cultist_count = 0;
	var _activation_limit = _event.activation_limit;

	// Only complete fixed-slot groups count, including optional groups after empty positions.
	for (var _activation_index = 0; _activation_index < _activation_limit; ++_activation_index)
	{
		if (day_event_activation_staffing_is_ready(_event, _activation_index))
		{
			_funded_cultist_count += _event.cultist_cost;
		}
	}

	return _funded_cultist_count >= _required_cultist_count;
}

function day_event_execution_is_active(_event)
{
	return day_event_execution_staffing_is_ready(_event)
		&& variable_struct_exists(_event, "execution_started")
		&& _event.execution_started;
}

function day_event_execution_start(_event)
{
	day_event_squad_selection_refresh(_event);

	if (!day_event_execution_staffing_is_ready(_event) || day_event_execution_is_active(_event))
	{
		return false;
	}

	_event.execution_timer = 0;
	_event.execution_started = true;
	return true;
}

function day_event_execution_timer_reset(_event)
{
	if (!is_struct(_event) || !variable_struct_exists(_event, "execution_timer"))
	{
		return false;
	}

	_event.execution_timer = 0;
	_event.execution_started = false;
	return true;
}

function day_event_execution_in_progress_exists()
{
	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _event = global.day_events[_event_index];

		if (day_event_execution_is_active(_event))
		{
			return true;
		}
	}

	return false;
}

function day_event_cultist_return_to_cannon_start(_cultist)
{
	if (!instance_exists(_cultist))
	{
		return false;
	}

	_cultist.assigned_event = noone;

	if (variable_instance_exists(_cultist, "return_to_cannon_after_event")
		&& variable_instance_exists(_cultist, "hp")
		&& _cultist.hp > 0)
	{
		_cultist.return_to_cannon_after_event = true;
	}

	return true;
}

function day_event_execution_complete(_event_index)
{
	if (_event_index < 0 || _event_index >= array_length(global.day_events))
	{
		return false;
	}

	var _event = global.day_events[_event_index];

	if (!day_event_execution_is_active(_event)
		|| !variable_struct_exists(_event, "execute"))
	{
		return false;
	}

	// Match the former End Day behavior for funded squad Rites without a manual selection.
	day_event_squad_selection_default_apply(_event);

	if (_event.activation_ready_count_get() <= 0)
	{
		day_event_execution_timer_reset(_event);
		return false;
	}

	var _assigned_cultist_count = array_length(_event.assigned_cultists);
	var _assigned_cultists = array_create(_assigned_cultist_count, noone);
	array_copy(_assigned_cultists, 0, _event.assigned_cultists, 0, _assigned_cultist_count);
	var _event_activation_count = _event.execute();

	if (_event_activation_count <= 0)
	{
		day_event_execution_timer_reset(_event);
		return false;
	}

	// Building rest and selection history still treat an immediate Rite as today's completed choice.
	if (!variable_struct_exists(_event, "construction_site")
		&& variable_struct_exists(_event, "source_building")
		&& instance_exists(_event.source_building))
	{
		day_event_building_ritual_execution_record(
			_event.source_building,
			day_event_current_day_get(),
			_event
		);
	}

	if (!variable_global_exists("day_event_completed_events"))
	{
		global.day_event_completed_events = [];
	}

	array_push(global.day_event_completed_events, _event);

	var _event_name = variable_struct_exists(_event, "title")
		? string(_event.title)
		: string(_event.event_id);

	// Keep the actual specialization, Relic or enchantment choice in the completed-day report.
	if (variable_struct_exists(_event, "unit_choice_options")
		&& is_array(_event.unit_choice_options)
		&& variable_struct_exists(_event, "selected_unit_choice_index"))
	{
		var _choice_index = floor(_event.selected_unit_choice_index);
		if (_choice_index >= 0 && _choice_index < array_length(_event.unit_choice_options))
		{
			var _choice = _event.unit_choice_options[_choice_index];
			if (is_struct(_choice) && variable_struct_exists(_choice, "label"))
			{
				_event_name += " - " + string(_choice.label);
			}
			else if (is_struct(_choice) && variable_struct_exists(_choice, "title"))
			{
				_event_name += " - " + string(_choice.title);
			}
		}
	}

	if (_event_activation_count > 1)
	{
		_event_name += " x" + string(_event_activation_count);
	}

	if (!variable_global_exists("day_event_executed_log_lines"))
	{
		global.day_event_executed_log_lines = [];
	}

	array_push(global.day_event_executed_log_lines, _event_name);

	// Release Cultists logically now while retaining their former slots for the Jobs animation.
	for (var _cultist_index = 0; _cultist_index < array_length(_assigned_cultists); ++_cultist_index)
	{
		day_event_cultist_return_to_cannon_start(_assigned_cultists[_cultist_index]);
	}

	_event.completion_animation_timer = 0;
	_event.completion_animation_cultists = _assigned_cultists;
	_event.completion_animation_slot_count = _event.cultist_cost * _event.activation_limit;
	_event.assigned_cultists = [];

	// Clearing Overuse immediately reveals this building's ordinary Rite for the same day.
	var _is_overuse_event = variable_struct_exists(_event, "is_overuse_event")
		&& _event.is_overuse_event;

	if (_is_overuse_event
		&& variable_struct_exists(_event, "source_building")
		&& instance_exists(_event.source_building))
	{
		var _source_building = _event.source_building;
		var _previous_event_count = array_length(global.day_events);
		day_event_building_events_add(_source_building, true);

		// A hidden pin has served its purpose once its ordinary Rite is restored.
		if (array_length(global.day_events) > _previous_event_count)
		{
			var _restored_event = global.day_events[array_length(global.day_events) - 1];
			day_event_pin_clear(_restored_event, false);
		}
	}

	// Recruitment and upgrades can change the recipients of other buildings' waiting Rites.
	var _remaining_event_count = array_length(global.day_events);
	for (var _remaining_index = 0; _remaining_index < _remaining_event_count; ++_remaining_index)
	{
		day_event_squad_selection_refresh(global.day_events[_remaining_index]);
	}

	global.sound_play_random([rite_complete01, rite_complete02], global.sound_priority_ui);
	return true;
}

function day_event_execution_timers_update(_paused_event = noone)
{
	var _timer_duration = BALANCE_DAY_EVENT_EXECUTION_TIME * room_speed;
	var _time_scale = variable_global_exists("gameplay_time_scale")
		? global.gameplay_time_scale
		: 1;
	var _completed_count = 0;

	// Work backwards because cards are removed after their completion animation.
	for (var _event_index = array_length(global.day_events) - 1; _event_index >= 0; --_event_index)
	{
		var _event = global.day_events[_event_index];

		if (!is_struct(_event) || !variable_struct_exists(_event, "execution_timer"))
		{
			continue;
		}

		// Resolved events stay non-interactive until both completion animations finish.
		if (_event.is_resolved)
		{
			var _completion_duration = max(
				BALANCE_JOBS_EVENT_FADE_TIME,
				BALANCE_JOBS_CULTIST_RETURN_ANIMATION_TIME
			) * room_speed;
			_event.completion_animation_timer = min(
				_event.completion_animation_timer + _time_scale,
				_completion_duration
			);

			if (_event.completion_animation_timer >= _completion_duration)
			{
				array_delete(global.day_events, _event_index, 1);
			}

			continue;
		}

		if (!day_event_execution_staffing_is_ready(_event))
		{
			day_event_execution_timer_reset(_event);
			continue;
		}

		// Filling the slots only makes Invoke available; it does not start execution.
		if (!day_event_execution_is_active(_event))
		{
			continue;
		}

		// Do not complete a Rite while the player is actively dragging one of its workers.
		if (_paused_event == _event)
		{
			continue;
		}

		_event.execution_timer = min(_event.execution_timer + _time_scale, _timer_duration);

		if (_event.execution_timer >= _timer_duration
			&& day_event_execution_complete(_event_index))
		{
			_completed_count++;
		}
	}

	return _completed_count;
}

function day_event_assignments_clear(_event)
{
	if (!is_struct(_event)
		|| !variable_struct_exists(_event, "assigned_cultists"))
	{
		return 0;
	}

	var _released_count = 0;

	for (var _cultist_index = 0; _cultist_index < array_length(_event.assigned_cultists); ++_cultist_index)
	{
		var _cultist = _event.assigned_cultists[_cultist_index];

		if (instance_exists(_cultist))
		{
			_cultist.assigned_event = noone;
			_released_count++;
		}
	}

	_event.assigned_cultists = [];
	day_event_execution_timer_reset(_event);
	return _released_count;
}

function day_event_pin_count_get()
{
	if (!variable_global_exists("day_event_pinned_events")
		|| !is_array(global.day_event_pinned_events))
	{
		return 0;
	}

	return array_length(global.day_event_pinned_events);
}

function day_event_pin_index_get(_event)
{
	if (!day_event_building_action_is_available(_event))
	{
		return -1;
	}

	var _source_event_id = day_event_source_event_id_get(_event);
	var _pin_count = day_event_pin_count_get();

	for (var _pin_index = 0; _pin_index < _pin_count; ++_pin_index)
	{
		var _pin = global.day_event_pinned_events[_pin_index];

		if (is_struct(_pin)
			&& _pin.source_building == _event.source_building
			&& _pin.source_event_id == _source_event_id)
		{
			return _pin_index;
		}
	}

	return -1;
}

function day_event_pin_is_active()
{
	return day_event_pin_count_get() > 0;
}

function day_event_pin_source_is_active(_source_building)
{
	var _pin_count = day_event_pin_count_get();

	for (var _pin_index = 0; _pin_index < _pin_count; ++_pin_index)
	{
		var _pin = global.day_event_pinned_events[_pin_index];

		if (is_struct(_pin) && _pin.source_building == _source_building)
		{
			return true;
		}
	}

	return false;
}

function day_event_pin_is_event(_event)
{
	return day_event_pin_index_get(_event) >= 0;
}

function day_event_pin_set(_event)
{
	if (!day_event_building_action_is_available(_event)
		|| (variable_struct_exists(_event, "can_pin") && !_event.can_pin)
		|| day_event_has_funded_activation(_event)
		|| global.day_event_pins_remaining <= 0
		|| day_event_pin_is_event(_event)
		|| day_event_pin_source_is_active(_event.source_building))
	{
		return false;
	}

	array_push(global.day_event_pinned_events, {
		source_building: _event.source_building,
		source_event_id: day_event_source_event_id_get(_event),
		is_cultist_mastery: variable_struct_exists(_event, "is_cultist_mastery") && _event.is_cultist_mastery
	});
	global.day_event_pins_remaining--;
	_event.is_pinned_event = true;
	return true;
}

function day_event_pin_clear(_event = noone, _refund_pin = true)
{
	var _clear_all = !is_struct(_event);
	var _cleared_pin_count = 0;

	for (var _pin_index = day_event_pin_count_get() - 1; _pin_index >= 0; --_pin_index)
	{
		var _pin = global.day_event_pinned_events[_pin_index];
		var _pin_matches_event = !_clear_all
			&& is_struct(_pin)
			&& _pin.source_building == _event.source_building
			&& _pin.source_event_id == day_event_source_event_id_get(_event);

		if (_clear_all || _pin_matches_event)
		{
			array_delete(global.day_event_pinned_events, _pin_index, 1);
			_cleared_pin_count++;
		}
	}

	if (_cleared_pin_count <= 0)
	{
		return false;
	}

	if (_refund_pin)
	{
		global.day_event_pins_remaining += _cleared_pin_count;
	}

	// Refresh every visible marker after removing one or more active pins.
	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _current_event = global.day_events[_event_index];

		if (day_event_building_action_is_available(_current_event))
		{
			_current_event.is_pinned_event = day_event_pin_is_event(_current_event);
		}
	}

	return true;
}

function day_event_pin_marker_apply()
{
	var _applied_pin_count = 0;

	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _event = global.day_events[_event_index];

		if (day_event_building_action_is_available(_event))
		{
			_event.is_pinned_event = day_event_pin_is_event(_event);
			_applied_pin_count += _event.is_pinned_event;
		}
	}

	return _applied_pin_count > 0;
}

function day_event_reroll_is_available(_event)
{
	return day_event_building_action_is_available(_event)
		&& variable_struct_exists(_event, "reroll_is_available")
		&& _event.reroll_is_available;
}

function day_event_reroll_candidate_generate(_event)
{
	// Foundry keeps its event but rerolls both internal Relic offers.
	if (variable_struct_exists(_event, "reroll_refreshes_relic_choices")
		&& _event.reroll_refreshes_relic_choices
		&& variable_struct_exists(_event, "source_building")
		&& instance_exists(_event.source_building))
	{
		var _current_choices = variable_struct_exists(_event, "unit_choice_options")
			&& is_array(_event.unit_choice_options)
			? _event.unit_choice_options
			: [];

		return day_event_foundry_relic_event_create(
			_event.source_building,
			_current_choices
		);
	}

	// Generate the currently valid catalog, then keep only alternatives from this exact source.
	var _current_events = global.day_events;
	global.day_events = [];
	day_event_generate_for_buildings(false, false);
	var _generated_events = global.day_events;
	global.day_events = _current_events;
	var _current_source_event_id = day_event_source_event_id_get(_event);
	var _candidate_events = [];
	var _generated_event_count = array_length(_generated_events);

	for (var _candidate_index = 0; _candidate_index < _generated_event_count; ++_candidate_index)
	{
		var _candidate = _generated_events[_candidate_index];

		if (day_event_building_action_is_available(_candidate)
			&& _candidate.source_building == _event.source_building
			&& day_event_source_event_id_get(_candidate) != _current_source_event_id)
		{
			array_push(_candidate_events, _candidate);
		}
	}

	var _candidate_event_count = array_length(_candidate_events);

	if (_candidate_event_count <= 0)
	{
		return noone;
	}

	return _candidate_events[irandom(_candidate_event_count - 1)];
}

function day_event_reroll_preview_get(_event)
{
	if (!day_event_reroll_is_available(_event))
	{
		return noone;
	}

	if (variable_struct_exists(_event, "reroll_preview_event")
		&& is_struct(_event.reroll_preview_event))
	{
		return _event.reroll_preview_event;
	}

	_event.reroll_preview_event = day_event_reroll_candidate_generate(_event);
	// Price the cached preview once so hovering and accepting show the same worker slots and HP.
	day_event_building_costs_random_apply([_event.reroll_preview_event]);
	return _event.reroll_preview_event;
}

function day_event_reroll(_event)
{
	if (global.day_event_rerolls_remaining <= 0
		|| !day_event_reroll_is_available(_event))
	{
		return false;
	}

	var _event_index = -1;
	var _event_count = array_length(global.day_events);

	for (var _search_index = 0; _search_index < _event_count; ++_search_index)
	{
		if (global.day_events[_search_index] == _event)
		{
			_event_index = _search_index;
			break;
		}
	}

	if (_event_index < 0)
	{
		return false;
	}

	var _replacement_event = day_event_reroll_preview_get(_event);

	if (!is_struct(_replacement_event))
	{
		return false;
	}

	if (day_event_pin_is_event(_event))
	{
		day_event_pin_clear(_event);
	}

	day_event_assignments_clear(_event);
	_replacement_event.reroll_is_available = true;
	global.day_events[_event_index] = _replacement_event;
	global.day_event_rerolls_remaining--;
	return true;
}

function day_event_building_daily_events_limit_apply(_additional_event_count = 0, _consume_pins = true)
{
	var _events_without_building_source = [];
	var _source_buildings = [];
	var _source_event_candidates = [];

	// Separate world jobs from events generated by individual building instances.
	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _event = global.day_events[_event_index];

		if (!is_struct(_event)
			|| !variable_struct_exists(_event, "source_building")
			|| !instance_exists(_event.source_building))
		{
			array_push(_events_without_building_source, _event);
			continue;
		}

		var _source_index = -1;

		for (var _known_source_index = 0; _known_source_index < array_length(_source_buildings); ++_known_source_index)
		{
			if (_source_buildings[_known_source_index] == _event.source_building)
			{
				_source_index = _known_source_index;
				break;
			}
		}

		if (_source_index < 0)
		{
			array_push(_source_buildings, _event.source_building);
			array_push(_source_event_candidates, [_event]);
			continue;
		}

		var _candidates = _source_event_candidates[_source_index];
		array_push(_candidates, _event);
		_source_event_candidates[_source_index] = _candidates;
	}

	// Each building contributes a limited random selection of currently available events.
	global.day_events = _events_without_building_source;

	for (var _source_index = 0; _source_index < array_length(_source_buildings); ++_source_index)
	{
		var _source_building = _source_buildings[_source_index];
		var _candidates = _source_event_candidates[_source_index];
		var _candidate_count = array_length(_candidates);

		if (_candidate_count <= 0 || BALANCE_BUILDING_DAY_EVENT_COUNT <= 0)
		{
			continue;
		}

		var _selected_candidates = [];
		var _random_candidates = [];
		var _repeated_candidates = [];
		var _reroll_is_available = _candidate_count > 1;

		// Every candidate from this building shares whether a different event can replace it.
		for (var _availability_index = 0; _availability_index < _candidate_count; ++_availability_index)
		{
			var _availability_candidate = _candidates[_availability_index];
			var _refreshes_internal_choices = variable_struct_exists(
				_availability_candidate,
				"reroll_refreshes_relic_choices"
			) && _availability_candidate.reroll_refreshes_relic_choices;

			_availability_candidate.reroll_is_available = _reroll_is_available
				|| _refreshes_internal_choices;
		}

		// A pinned event is an explicit request and consumes this source's normal daily event slot.
		for (var _candidate_index = 0; _candidate_index < _candidate_count; ++_candidate_index)
		{
			var _candidate = _candidates[_candidate_index];

			if (day_event_pin_is_event(_candidate))
			{
				_candidate.is_pinned_event = true;
				array_push(_selected_candidates, _candidate);
			}
			else
			{
				var _candidate_event_id = day_event_source_event_id_get(_candidate);
				var _was_selected_previous_day = false;

				if (variable_instance_exists(_source_building, "previous_day_event_ids")
					&& is_array(_source_building.previous_day_event_ids))
				{
					var _previous_event_ids = _source_building.previous_day_event_ids;

					for (var _previous_index = 0;
						_previous_index < array_length(_previous_event_ids);
						++_previous_index)
					{
						if (_previous_event_ids[_previous_index] == _candidate_event_id)
						{
							_was_selected_previous_day = true;
							break;
						}
					}
				}

				if (_was_selected_previous_day)
				{
					array_push(_repeated_candidates, _candidate);
				}
				else
				{
					array_push(_random_candidates, _candidate);
				}
			}
		}

		for (var _shuffle_index = array_length(_random_candidates) - 1; _shuffle_index > 0; --_shuffle_index)
		{
			var _swap_index = irandom(_shuffle_index);
			var _swap_event = _random_candidates[_shuffle_index];

			_random_candidates[_shuffle_index] = _random_candidates[_swap_index];
			_random_candidates[_swap_index] = _swap_event;
		}

		for (var _repeat_shuffle_index = array_length(_repeated_candidates) - 1;
			_repeat_shuffle_index > 0;
			--_repeat_shuffle_index)
		{
			var _repeat_swap_index = irandom(_repeat_shuffle_index);
			var _repeat_swap_event = _repeated_candidates[_repeat_shuffle_index];

			_repeated_candidates[_repeat_shuffle_index] = _repeated_candidates[_repeat_swap_index];
			_repeated_candidates[_repeat_swap_index] = _repeat_swap_event;
		}

		// Repeated events are considered only when no new eligible alternative can fill the slot.
		for (var _repeat_index = 0; _repeat_index < array_length(_repeated_candidates); ++_repeat_index)
		{
			array_push(_random_candidates, _repeated_candidates[_repeat_index]);
		}

		// Invite the Worthy expands the unique selection instead of cloning an existing card.
		var _event_limit = BALANCE_BUILDING_DAY_EVENT_COUNT
			+ max(0, floor(_additional_event_count));
		var _selected_event_count = min(_event_limit, _candidate_count);

		for (var _random_index = 0;
			array_length(_selected_candidates) < _selected_event_count
				&& _random_index < array_length(_random_candidates);
			++_random_index)
		{
			array_push(_selected_candidates, _random_candidates[_random_index]);
		}

		for (var _selection_index = 0; _selection_index < array_length(_selected_candidates); ++_selection_index)
		{
			array_push(global.day_events, _selected_candidates[_selection_index]);
		}
	}

	// Pins hidden by Overuse remain stored until the maintenance Rite restores the normal event.
	if (_consume_pins && day_event_pin_is_active())
	{
		for (var _pin_index = day_event_pin_count_get() - 1; _pin_index >= 0; --_pin_index)
		{
			var _pin = global.day_event_pinned_events[_pin_index];
			// Independent Mastery pins are consumed by their own morning generator.
			if (is_struct(_pin)
				&& variable_struct_exists(_pin, "is_cultist_mastery")
				&& _pin.is_cultist_mastery)
			{
				continue;
			}

			var _pin_is_hidden_by_overuse = is_struct(_pin)
				&& instance_exists(_pin.source_building)
				&& day_event_building_overuse_is_required(_pin.source_building);

			if (!_pin_is_hidden_by_overuse)
			{
				array_delete(global.day_event_pinned_events, _pin_index, 1);
			}
		}
	}

	return array_length(global.day_events);
}

function day_event_building_can_offer_daily_rite(_building)
{
	if (!instance_exists(_building))
	{
		return false;
	}

	// Starting specialization buildings remain silent during the first-day onboarding.
	var _is_first_day_specialization_building = day_event_current_day_get() == 1
		&& (_building.object_index == o_pitlings_pit2
			|| _building.object_index == o_graveyard2);

	return !_is_first_day_specialization_building;
}

// Passing a source limits generation to that instance, without world jobs or daily bonuses.
function day_event_generate_for_buildings(_apply_daily_limit = true, _apply_additional_bonus = true, _source_building = noone)
{
	// World jobs are available without owning a source building.
	var _generate_all_buildings = _source_building == noone;
	if (_generate_all_buildings)
	{
		day_event_world_jobs_generate();
	}

	// Shell Factory offers independent, match-long shell enchantments and upgrades.
	if (instance_exists(o_shell_factory)
		&& (_generate_all_buildings || _source_building.object_index == o_shell_factory))
	{
		var _shell_factory = _generate_all_buildings ? instance_find(o_shell_factory, 0) : _source_building;

		if (!global.shell_factory_taint_enchantment_event_completed)
		{
			var _taint_enchantment_event = day_event_shell_factory_enchantment_create(_shell_factory);

			if (is_struct(_taint_enchantment_event))
			{
				day_event_add(_taint_enchantment_event);
			}
		}

		if (!global.shell_factory_first_aid_enchantment_event_completed)
		{
			var _first_aid_enchantment_event = day_event_shell_factory_first_aid_enchantment_create(_shell_factory);

			if (is_struct(_first_aid_enchantment_event))
			{
				day_event_add(_first_aid_enchantment_event);
			}
		}

		if (!global.shell_factory_hellcow_enchantment_event_completed)
		{
			var _hellcow_enchantment_event = day_event_shell_factory_hellcow_enchantment_create(_shell_factory);

			if (is_struct(_hellcow_enchantment_event))
			{
				day_event_add(_hellcow_enchantment_event);
			}
		}

		if (!global.shell_factory_doom_bell_enchantment_event_completed)
		{
			var _doom_bell_enchantment_event = day_event_shell_factory_doom_bell_enchantment_create(_shell_factory);

			if (is_struct(_doom_bell_enchantment_event))
			{
				day_event_add(_doom_bell_enchantment_event);
			}
		}

		if (!global.shell_factory_taint_bloom_event_completed)
		{
			var _taint_bloom_event = day_event_shell_factory_taint_bloom_create(_shell_factory);

			if (is_struct(_taint_bloom_event))
			{
				day_event_add(_taint_bloom_event);
			}
		}

		if (!global.shell_factory_opening_barrage_event_completed)
		{
			var _opening_barrage_event = day_event_shell_factory_opening_barrage_create(_shell_factory);

			if (is_struct(_opening_barrage_event))
			{
				day_event_add(_opening_barrage_event);
			}
		}

		if (!global.shell_factory_favored_ammunition_event_completed)
		{
			var _favored_ammunition_event = day_event_shell_factory_favored_ammunition_create(_shell_factory);

			if (is_struct(_favored_ammunition_event))
			{
				day_event_add(_favored_ammunition_event);
			}
		}
	}

	var _foundry_count = instance_number(o_foundry);

	for (var _foundry_index = 0; _foundry_index < _foundry_count; ++_foundry_index)
	{
		var _foundry = instance_find(o_foundry, _foundry_index);

		if (instance_exists(_foundry) && (_generate_all_buildings || _foundry == _source_building))
		{
			day_event_foundry_events_add(_foundry);
		}
	}

	var _summoning_grounds_count = instance_number(o_summoning_grounds);

	for (var _grounds_index = 0; _grounds_index < _summoning_grounds_count; ++_grounds_index)
	{
		var _summoning_grounds = instance_find(o_summoning_grounds, _grounds_index);

		if (instance_exists(_summoning_grounds) && (_generate_all_buildings || _summoning_grounds == _source_building))
		{
			day_event_summoning_grounds_events_add(_summoning_grounds);
		}
	}

	var _ritual_circle_count = instance_number(o_ritual_circle);

	for (var _ritual_index = 0; _ritual_index < _ritual_circle_count; ++_ritual_index)
	{
		var _ritual_circle = instance_find(o_ritual_circle, _ritual_index);

		if (instance_exists(_ritual_circle) && (_generate_all_buildings || _ritual_circle == _source_building))
		{
			day_event_ritual_events_add(_ritual_circle);
		}
	}

	var _unholy_shrine_count = instance_number(o_unholy_shrine);

	for (var _shrine_index = 0; _shrine_index < _unholy_shrine_count; ++_shrine_index)
	{
		var _unholy_shrine = instance_find(o_unholy_shrine, _shrine_index);

		if (!instance_exists(_unholy_shrine)
			|| (!_generate_all_buildings && _unholy_shrine != _source_building))
		{
			continue;
		}

		// Offer a Rite immediately; its squad selector can wait for a suitable recruit.
		var _eligible_squads = day_event_squads_without_unholy_trait_get();

		day_event_unholy_trait_add(
			_unholy_shrine,
			_eligible_squads,
			"boiling_blood",
			"Boiling Blood",
			"Endows the squad with Unholy trait:\n"
				+ squad_unholy_trait_description_get(UNHOLY_TRAIT.BOILING_BLOOD),
			UNHOLY_TRAIT.BOILING_BLOOD
		);
		day_event_unholy_trait_add(
			_unholy_shrine,
			_eligible_squads,
			"stunning_arrival",
			"Stunning Arrival",
			"Endows the squad with Unholy trait:\n"
				+ squad_unholy_trait_description_get(UNHOLY_TRAIT.STUNNING_ARRIVAL),
			UNHOLY_TRAIT.STUNNING_ARRIVAL
		);
		day_event_unholy_trait_add(
			_unholy_shrine,
			_eligible_squads,
			"savage_leap",
			"Savage Leap",
			"Endows the squad with Unholy trait:\n"
				+ squad_unholy_trait_description_get(UNHOLY_TRAIT.SAVAGE_LEAP),
			UNHOLY_TRAIT.SAVAGE_LEAP
		);
		day_event_unholy_trait_add(
			_unholy_shrine,
			_eligible_squads,
			"endless_procession",
			"Endless Procession",
			"Endows the squad with Unholy trait:\n"
				+ squad_unholy_trait_description_get(UNHOLY_TRAIT.ENDLESS_PROCESSION),
			UNHOLY_TRAIT.ENDLESS_PROCESSION
		);
		day_event_unholy_trait_add(
			_unholy_shrine,
			_eligible_squads,
			"taint_treatment",
			"Taint Treatment",
			"Endows the squad with Unholy trait:\n"
				+ squad_unholy_trait_description_get(UNHOLY_TRAIT.TAINT_TREATMENT),
			UNHOLY_TRAIT.TAINT_TREATMENT
		);
		day_event_unholy_trait_add(
			_unholy_shrine,
			_eligible_squads,
			"roar_of_the_abyss",
			"The Roar of the Abyss",
			"Endows the squad with Unholy trait:\n"
				+ squad_unholy_trait_description_get(UNHOLY_TRAIT.ROAR_OF_THE_ABYSS),
			UNHOLY_TRAIT.ROAR_OF_THE_ABYSS
		);
		day_event_unholy_trait_add(
			_unholy_shrine,
			_eligible_squads,
			"power_of_twilight",
			"The Power of Twilight",
			"Endows the squad with Unholy trait:\n"
				+ squad_unholy_trait_description_get(UNHOLY_TRAIT.POWER_OF_TWILIGHT),
			UNHOLY_TRAIT.POWER_OF_TWILIGHT
		);
	}

	var _pit_count = instance_number(o_pitlings_pit2);

	for (var _pit_index = 0; _pit_index < _pit_count; ++_pit_index)
	{
		var _pit = instance_find(o_pitlings_pit2, _pit_index);
		if (!day_event_building_can_offer_daily_rite(_pit)
			|| (!_generate_all_buildings && _pit != _source_building))
		{
			continue;
		}

		var _mawling_squads = day_event_squads_get(SQUAD_TYPE.DEMON, o_mawling);
		var _demon_squads = day_event_squads_get(SQUAD_TYPE.DEMON);

		// Mawlings must be specialized before Demons Pit can offer its normal event pool again.
		if (array_length(_mawling_squads) > 0)
		{
			var _demon_mastery_cost = day_event_demons_pit_random_cultist_cost_get();
			var _demon_mastery_event = day_event_squad_create(
				_pit,
				"mawling_mastery",
				"Mawling Mastery",
				"Choose how to transform every Mawling in the selected squad.",
				_demon_mastery_cost.cultist_count,
				"replace_mawlings_with_selected_unit",
				day_event_squad_units_choice_replace_execute,
				{ source_unit_object: o_mawling, hp_cost: _demon_mastery_cost.hp_cost }
			);
			_demon_mastery_event.unit_choice_options = [
				{ title: "Forge Balgors", label: "Balgor", target_unit_object: o_balgor },
				{ title: "Lessons in Temptation", label: "Succubus", target_unit_object: o_succubus },
				{ title: "Born in Pit", label: "Pitling", target_unit_object: o_pitling }
			];
			_demon_mastery_event.selected_unit_choice_index = 0;
			_demon_mastery_event.selected_squad = _mawling_squads[0];
			day_event_add(_demon_mastery_event);
			continue;
		}

		// Keep a reinforcement Rite visible while the first Demon squad is being recruited.
		var _fill_event = day_event_squad_create(
			_pit,
			"fill_the_ranks",
			"Fill the Ranks",
			"Add " + string(BALANCE_DEMONS_PIT_FILL_UNIT_COUNT)
				+ " units of the most common unit type in the selected demon squad.",
			BALANCE_DEMONS_PIT_FILL_CULTIST_COUNT,
			"fill_demon_ranks",
			day_event_squad_draft_execute,
			{ hp_cost: BALANCE_DEMONS_PIT_FILL_HP_COST, unit_count: BALANCE_DEMONS_PIT_FILL_UNIT_COUNT }
		);
		day_event_add(day_event_squad_selection_add(_fill_event, _demon_squads));
	}

	var _graveyard_count = instance_number(o_graveyard2);

	for (var _graveyard_index = 0; _graveyard_index < _graveyard_count; ++_graveyard_index)
	{
		var _graveyard = instance_find(o_graveyard2, _graveyard_index);
		if (!day_event_building_can_offer_daily_rite(_graveyard)
			|| (!_generate_all_buildings && _graveyard != _source_building))
		{
			continue;
		}

		var _bonelet_squads = day_event_squads_get(SQUAD_TYPE.UNDEAD, o_skeleton_bonelet);
		var _undead_squads = day_event_squads_get(SQUAD_TYPE.UNDEAD);

		// Bonelets must be specialized before Graveyard can offer its normal event pool again.
		if (array_length(_bonelet_squads) > 0)
		{
			var _undead_mastery_cost = day_event_random_cultist_cost_get();
			var _undead_mastery_event = day_event_squad_create(
				_graveyard,
				"bonelet_mastery",
				"Bonelet Mastery",
				"Choose how to transform every Bonelet in the selected squad.",
				_undead_mastery_cost.cultist_count,
				"replace_bonelets_with_selected_unit",
				day_event_squad_units_choice_replace_execute,
				{ source_unit_object: o_skeleton_bonelet, hp_cost: _undead_mastery_cost.hp_cost }
			);
			_undead_mastery_event.unit_choice_options = [
				{ title: "Arm the Dead", label: "Warrior", target_unit_object: o_skeleton_warrior },
				{ title: "Bone Scholars", label: "Mage", target_unit_object: o_skeleton_mage },
				{ title: "Bone Archery", label: "Archer", target_unit_object: o_skeleton_archer }
			];
			_undead_mastery_event.selected_unit_choice_index = 0;
			_undead_mastery_event.selected_squad = _bonelet_squads[0];
			day_event_add(_undead_mastery_event);
			continue;
		}

		// Keep a reinforcement Rite visible while the first Undead squad is being recruited.
		var _draft_event = day_event_squad_create(
			_graveyard,
			"skeleton_draft",
			"Skeleton Draft",
			"Add " + string(BALANCE_GRAVEYARD_DRAFT_UNIT_COUNT)
				+ " units of the most common unit type in the selected undead squad.",
			BALANCE_GRAVEYARD_DRAFT_CULTIST_COUNT,
			"draft_skeletons",
			day_event_squad_draft_execute,
			{ hp_cost: BALANCE_GRAVEYARD_DRAFT_HP_COST, unit_count: BALANCE_GRAVEYARD_DRAFT_UNIT_COUNT }
		);
		day_event_add(day_event_squad_selection_add(_draft_event, _undead_squads));
	}

	var _blood_bath_count = instance_number(o_meat_bath);
	var _infernal_regeneration_use_count = min(
		global.blood_bath_infernal_regeneration_uses,
		BALANCE_BLOOD_BATH_INFERNAL_REGENERATION_ACTIVATION_LIMIT
	);
	var _infernal_regeneration_current_percentage = round(
		(BALANCE_ARCHDEMON_DAILY_RECOVERY_SHARE
			+ (_infernal_regeneration_use_count
				* BALANCE_BLOOD_BATH_INFERNAL_REGENERATION_RECOVERY_SHARE))
		* 100
	);
	var _infernal_regeneration_bonus_percentage = round(
		BALANCE_BLOOD_BATH_INFERNAL_REGENERATION_RECOVERY_SHARE * 100
	);

	for (var _blood_bath_index = 0; _blood_bath_index < _blood_bath_count; ++_blood_bath_index)
	{
		var _blood_bath = instance_find(o_meat_bath, _blood_bath_index);
		if (!_generate_all_buildings && _blood_bath != _source_building)
		{
			continue;
		}

		if (BLOOD_BATH_FULL_EVENT_SET_ENABLED)
		{
			day_event_add(day_event_blood_bath_create(
				_blood_bath,
				"crimson_baptism",
				"Crimson Baptism",
				"All conscious Cultists restore "
					+ string(BALANCE_BLOOD_BATH_CRIMSON_MORNING_HEAL)
					+ " HP next morning.",
				1,
				1,
				day_event_blood_bath_crimson_baptism_execute
			));

			if (global.blood_bath_infernal_regeneration_uses
				< BALANCE_BLOOD_BATH_INFERNAL_REGENERATION_ACTIVATION_LIMIT)
			{
				day_event_add(day_event_blood_bath_create(
					_blood_bath,
					"infernal_regeneration",
					"Infernal Regeneration",
					"Archdemons restore an additional "
						+ string(_infernal_regeneration_bonus_percentage)
						+ "% of their Max HP each day. Current daily recovery: "
						+ string(_infernal_regeneration_current_percentage)
						+ "% of Max HP. Can be activated "
						+ string(BALANCE_BLOOD_BATH_INFERNAL_REGENERATION_ACTIVATION_LIMIT)
						+ " times per game.",
					1,
					1,
					day_event_infernal_regeneration_execute
				));
			}
		}

		day_event_add(day_event_blood_bath_create(
			_blood_bath,
			"blood_bath",
			"Blood Bath",
			"Assigned Cultists restore "
				+ string(BALANCE_BLOOD_BATH_HEAL_AMOUNT)
				+ " HP.",
			1,
			BALANCE_BLOOD_BATH_HEAL_CULTIST_LIMIT,
			day_event_blood_bath_heal_execute
		));

		// Skip every other Blood Bath Rite while the temporary event limit is active.
		if (!BLOOD_BATH_FULL_EVENT_SET_ENABLED)
		{
			continue;
		}

		day_event_add(day_event_blood_bath_create(
			_blood_bath,
			"lingering_wounds",
			"Lingering Wounds",
			"All conscious Cultists will have the same amount of HP tomorrow morning as they do this morning. Unconscious Cultists are unaffected.",
			1,
			1,
			day_event_lingering_wounds_execute
		));
		day_event_add(day_event_blood_bath_create(
			_blood_bath,
			"harden_the_vessel",
			"Harden the Vessel",
			"If still conscious after the Rite, the assigned Cultist restores "
				+ string(BALANCE_HARDEN_VESSEL_MORNING_HEAL)
				+ " HP next morning.",
			1,
			1,
			day_event_harden_vessel_execute
		));
		day_event_add(day_event_blood_bath_create(
			_blood_bath,
			"the_bath_demands_a_name",
			"The Bath Demands a Name",
			"All other conscious Cultists fully restore their HP next morning.",
			1,
			1,
			day_event_bath_demands_name_execute
		));
		day_event_add(day_event_blood_bath_create(
			_blood_bath,
			"blood_for_blood",
			"Blood for Blood",
			"Increase the maximum number of Cultists by "
				+ string(BALANCE_BLOOD_FOR_BLOOD_LIMIT_BONUS)
				+ ".",
			1,
			1,
			day_event_blood_for_blood_execute
		));
		day_event_add(day_event_blood_bath_create(
			_blood_bath,
			"undying_devotion",
			"Undying Devotion",
			"All Cultists who die today, will rise the next day with "
				+ string(BALANCE_BLOOD_BATH_UNDYING_DEVOTION_REVIVE_HP)
				+ " HP.",
			1,
			1,
			day_event_undying_devotion_execute
		));

		if (day_event_cultist_count_get() < global.cultist_limit)
		{
			day_event_add(day_event_cult_must_grow_create(_blood_bath));
		}

		day_event_add(day_event_blood_bath_create(
			_blood_bath,
			"blood_warpaint",
			"Blood Warpaint",
			"Set every conscious Cultist to "
				+ string(BALANCE_BLOOD_WARPAINT_MORNING_HP)
				+ " HP next morning.",
			1,
			1,
			day_event_blood_warpaint_execute
		));
	}

	// Overuse maintenance replaces the normal catalog before the daily selection is made.
	day_event_building_overuse_events_replace(_source_building);

	// Resting buildings without authored Overuse events keep the legacy rest behavior.
	day_event_building_ritual_rest_apply();

	// Invite the Worthy selects one extra unique candidate from each building's full catalog.
	var _additional_event_count = _generate_all_buildings && _apply_additional_bonus
		&& global.ritual_extra_building_event_active
		? 1
		: 0;

	// Normal days resolve every source to its limited daily selection.
	if (_apply_daily_limit)
	{
		day_event_building_daily_events_limit_apply(_additional_event_count, _generate_all_buildings);
		if (_generate_all_buildings)
		{
			day_event_cannon_demand_add();
		}
	}

	if (_generate_all_buildings && _apply_additional_bonus && global.ritual_extra_building_event_active)
	{
		global.ritual_extra_building_event_active = false;
	}

	// Keep the mandatory first Archdemon Job below every other generated event.
	if (_generate_all_buildings)
	{
		day_event_move_to_end(day_event_world_archdemon_event_id_get(1));
	}

	return array_length(global.day_events);
}

// Append only this building's daily selection; preserve existing cards, pins and assignments.
function day_event_building_events_add(_building, _ignore_existing_events = false)
{
	if (!instance_exists(_building)
		|| global.day_phase != DAY_PHASE.DAY
		|| !object_is_ancestor(_building.object_index, o_v13buildings_parent)
		|| !day_event_building_can_offer_daily_rite(_building))
	{
		return 0;
	}

	// Repeated construction notifications must not grant another Rite.
	if (!_ignore_existing_events)
	{
		var _event_groups = [global.day_events, global.day_event_completed_events];
		var _group_count = array_length(_event_groups);
		for (var _group_index = 0; _group_index < _group_count; ++_group_index)
		{
			var _events = _event_groups[_group_index];
			var _event_count = array_length(_events);
			for (var _event_index = 0; _event_index < _event_count; ++_event_index)
			{
				var _event = _events[_event_index];
				if (is_struct(_event)
					&& variable_struct_exists(_event, "source_building")
					&& _event.source_building == _building)
				{
					return 0;
				}
			}
		}
	}

	// Reuse morning generation on an isolated catalog for the newly completed building.
	var _current_events = global.day_events;
	global.day_events = [];
	day_event_generate_for_buildings(true, false, _building);
	var _new_events = global.day_events;
	global.day_events = _current_events;
	// New buildings and cleared Overuse receive independent daytime prices.
	day_event_building_costs_random_apply(_new_events);
	var _new_event_count = array_length(_new_events);
	for (var _new_index = 0; _new_index < _new_event_count; ++_new_index)
	{
		day_event_add(_new_events[_new_index]);
	}

	return _new_event_count;
}

function day_event_debug_all_events_generate()
{
	var _preserved_events = [];

	// Keep player-ordered cards and their assignments; replace every normally generated card.
	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _event = global.day_events[_event_index];
		var _is_player_ordered_event = is_struct(_event)
			&& (variable_struct_exists(_event, "construction_site")
				|| (variable_struct_exists(_event, "reserves_squad_slot")
					&& _event.reserves_squad_slot));

		if (_is_player_ordered_event)
		{
			array_push(_preserved_events, _event);
			continue;
		}

		if (!is_struct(_event)
			|| !variable_struct_exists(_event, "assigned_cultists"))
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

	global.day_events = _preserved_events;
	day_event_generate_for_buildings(false, false);
	day_event_building_costs_random_apply(global.day_events);
	day_event_pin_marker_apply();
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
	_cultist.hp = min(BALANCE_EVENT_CULTIST_STARTING_HP, _cultist.max_hp);
	_cultist.blood_bath_morning_hp_snapshot = _cultist.hp;
	array_push(global.event_cultists, _cultist);
	return _cultist;
}

function day_event_finish_day()
{
	day_event_cultist_mastery_finish_day();
	var _released_cultist_count = 0;

	// End Day no longer executes Rites; it only abandons unfinished assignments before night.
	for (var _event_index = 0; _event_index < array_length(global.day_events); ++_event_index)
	{
		var _event = global.day_events[_event_index];

		if (!is_struct(_event))
		{
			continue;
		}

		// Ignoring an unfinished Cannon demand keeps its existing Satisfaction consequence.
		if (variable_struct_exists(_event, "is_cannon_demand")
			&& _event.is_cannon_demand
			&& variable_struct_exists(_event, "ignored_satisfaction_penalty"))
		{
			cannon_satisfaction_add(-max(0, _event.ignored_satisfaction_penalty));
		}

		for (var _cultist_index = 0; _cultist_index < array_length(_event.assigned_cultists); ++_cultist_index)
		{
			var _cultist = _event.assigned_cultists[_cultist_index];

			if (!instance_exists(_cultist))
			{
				continue;
			}

			_cultist.assigned_event = noone;

			if (variable_instance_exists(_cultist, "return_to_cannon_at_night"))
			{
				_cultist.return_to_cannon_at_night = true;
			}

			_released_cultist_count++;
		}

		_event.assigned_cultists = [];
		day_event_execution_timer_reset(_event);
	}

	// Cheat balance sessions record the Rites that completed during the daytime.
	if (global.cheats_enabled && instance_exists(o_game_controller))
	{
		var _game_controller = instance_find(o_game_controller, 0);
		var _executed_event_lines = variable_global_exists("day_event_executed_log_lines")
			? global.day_event_executed_log_lines
			: [];

		// Store strings before End Day clears the live log and morning removes the event instances.
		var _executed_event_count = array_length(_executed_event_lines);
		_game_controller.debug_previous_day_event_lines = array_create(_executed_event_count, "");
		array_copy(_game_controller.debug_previous_day_event_lines, 0,
			_executed_event_lines, 0, _executed_event_count);
		_game_controller.debug_previous_day_event_day = day_event_current_day_get();
		_game_controller.debug_previous_day_report_visible = false;
		_game_controller.debug_previous_day_report_pending = false;

		if (variable_instance_exists(_game_controller, "balance_log_day_append"))
		{
			_game_controller.balance_log_day_append(day_event_current_day_get(), _executed_event_lines);
		}
	}

	global.day_event_executed_log_lines = [];

	return _released_cultist_count;
}

function day_event_new_day_reset()
{
	// Also settle offers when a debug or alternate transition skips the normal End Day path.
	day_event_cultist_mastery_finish_day();

	// Apply idle recovery before deciding which building events must be shown tomorrow.
	day_event_building_overuse_morning_recovery_apply();

	// All surviving Cultists recover their individual Spirit budget, including unconscious ones.
	var _spirit_cultist_count = array_length(global.event_cultists);
	for (var _spirit_index = 0; _spirit_index < _spirit_cultist_count; ++_spirit_index)
	{
		var _spirit_cultist = global.event_cultists[_spirit_index];
		if (instance_exists(_spirit_cultist))
		{
			_spirit_cultist.spirit = _spirit_cultist.max_spirit;
		}
	}

	// Today's bath bonus and unspent bonus shell expire; the knife lasts until the next Rite.
	global.blood_bath_daily_heal_bonus = 0;
	for (var _shell_index = array_length(global.cannon_projectile_payload_queue) - 1; _shell_index >= 0; --_shell_index)
	{
		var _payload = global.cannon_projectile_payload_queue[_shell_index];
		if (is_struct(_payload) && variable_struct_exists(_payload, "personal_rite_daily_shell"))
		{
			array_delete(global.cannon_projectile_queue, _shell_index, 1);
			array_delete(global.cannon_projectile_payload_queue, _shell_index, 1);
		}
	}
	global.cannon_selected_projectile_index = clamp(global.cannon_selected_projectile_index,
		0, max(0, array_length(global.cannon_projectile_queue) - 1));

	// Preserve today's final choices, including rerolls, before removing the cards.
	day_event_previous_building_selections_store();
	global.building_construction_count_today = 0;

	// The possessed cannon grows bored overnight when Satisfaction exceeds 100.
	if (cannon_satisfaction_get() > BALANCE_CANNON_SATISFACTION_IT_MUST_FIRE_MIN)
	{
		cannon_satisfaction_add(-BALANCE_CANNON_SATISFACTION_HIGH_DAILY_DECAY);
	}

	global.day_event_rerolls_remaining = cannon_satisfaction_daily_reroll_count_get();
	global.day_event_pins_remaining = BALANCE_DAY_EVENT_DAILY_PIN_COUNT;

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

		// An unfinished construction event releases its reserved site.
		if (variable_struct_exists(_event, "construction_site")
			&& instance_exists(_event.construction_site)
			&& variable_instance_exists(_event.construction_site, "construction_event_pending"))
		{
			_event.construction_site.construction_event_pending = false;
		}

		// An unfinished recruitment event releases its chosen Squad Point.
		if (variable_struct_exists(_event, "squad_point")
			&& instance_exists(_event.squad_point)
			&& variable_instance_exists(_event.squad_point, "pending_squad_event")
			&& _event.squad_point.pending_squad_event == _event)
		{
			_event.squad_point.pending_squad_event = noone;
		}
	}

	global.day_events = [];
}

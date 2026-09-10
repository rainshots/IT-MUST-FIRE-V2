/// @description Creates a day event with cultist cost, activation limit, and multiple actions.
/// @param {String} _event_id Stable event identifier.
/// @param {String} _title Player-facing title.
/// @param {String} _description Player-facing description.
/// @param {Real} _cultist_cost Cultists required for one activation.
/// @param {Real} _activation_limit Maximum activations during the day.
/// @param {Array<Struct>} _actions Actions executed in array order.
function day_event_constructor(_event_id, _title, _description, _cultist_cost, _activation_limit, _actions = []) constructor
{
	event_id = _event_id;
	title = _title;
	description = _description;
	cultist_cost = max(1, floor(_cultist_cost));
	activation_limit = max(1, floor(_activation_limit));
	// Invoke normally requires all slots; optional-participant Rites may lower this minimum.
	execution_cultist_minimum = cultist_cost * activation_limit;
	actions = _actions;
	// Array indices are fixed UI/HP-cost slots; unoccupied positions contain noone.
	assigned_cultists = [];
	modifiers = [];
	activation_count = 0;
	is_resolved = false;
	execution_timer = 0;
	// Only an explicit Invoke starts this card's countdown.
	execution_started = false;
	// Completed cards retain their former workers briefly for Assign Rites animations.
	completion_animation_timer = 0;
	completion_animation_cultists = [];
	completion_animation_slot_count = 0;
	// Assign Rites remembers each card's daily first appearance independently of list order.
	jobs_reveal_day = -1;
	jobs_reveal_start_seconds = 0;

	cultist_can_assign = function(_cultist, _ignore_capacity = false)
	{
		if (!instance_exists(_cultist)
			|| !variable_instance_exists(_cultist, "is_available")
			|| !_cultist.is_available()
			|| is_resolved
			|| (!_ignore_capacity
				&& day_event_assigned_cultist_count_get(self) >= cultist_cost * activation_limit))
		{
			return false;
		}

		if (!cultist_is_eligible_check(_cultist))
		{
			return false;
		}

		return true;
	};

	cultist_is_eligible_check = function(_cultist)
	{
		// Slot transfers bypass pool availability, but still require a conscious worker with Spirit.
		if (!instance_exists(_cultist)
			|| _cultist.hp <= 0
			|| _cultist.spirit <= 0
			|| (variable_instance_exists(_cultist, "is_unconscious") && _cultist.is_unconscious))
		{
			return false;
		}

		// A personal Rite can only be performed by its living author.
		if (variable_struct_exists(self, "required_cultist")
			&& (!instance_exists(_cultist) || _cultist != required_cultist || _cultist.hp <= 0))
		{
			return false;
		}

		return !variable_struct_exists(self, "cultist_is_eligible")
			|| !is_callable(cultist_is_eligible)
			|| cultist_is_eligible(_cultist);
	};

	activation_ready_count_get = function()
	{
		if (variable_struct_exists(self, "requires_squad_selection")
			&& requires_squad_selection
			&& (!variable_struct_exists(self, "selected_squad") || !is_struct(selected_squad)))
		{
			return 0;
		}

		var _funded_count = 0;

		// Count complete groups in place; optional participants need not occupy the first slots.
		for (var _activation_index = 0; _activation_index < activation_limit; ++_activation_index)
		{
			if (day_event_activation_staffing_is_ready(self, _activation_index))
			{
				_funded_count++;
			}
		}

		return min(_funded_count, activation_limit - activation_count);
	};

	// An explicit slot supports transfers and swaps; automatic assignment fills the first vacancy.
	cultist_assign = function(_cultist, _slot_index = -1)
	{
		if (is_resolved || !cultist_is_eligible_check(_cultist))
		{
			return false;
		}

		var _slot_count = cultist_cost * activation_limit;
		var _stored_slot_count = array_length(assigned_cultists);

		if (_slot_index == -1)
		{
			for (var _search_index = 0; _search_index < _slot_count; ++_search_index)
			{
				if (_search_index >= _stored_slot_count || !instance_exists(assigned_cultists[_search_index]))
				{
					_slot_index = _search_index;
					break;
				}
			}
		}

		if (_slot_index < 0 || _slot_index >= _slot_count || _slot_index != floor(_slot_index))
		{
			return false;
		}

		var _displaced_cultist = _slot_index < _stored_slot_count ? assigned_cultists[_slot_index] : noone;

		if (_displaced_cultist == _cultist)
		{
			return true;
		}

		// Validate the current source before changing either event, so rejected drops leave both intact.
		var _origin_event = _cultist.assigned_event;
		var _origin_slot_index = -1;

		if (is_struct(_origin_event))
		{
			if (_origin_event.is_resolved)
			{
				return false;
			}

			var _origin_slot_count = array_length(_origin_event.assigned_cultists);

			for (var _search_index = 0; _search_index < _origin_slot_count; ++_search_index)
			{
				if (_origin_event.assigned_cultists[_search_index] == _cultist)
				{
					_origin_slot_index = _search_index;
					break;
				}
			}

			if (_origin_slot_index < 0)
			{
				return false;
			}
		}
		else if (!cultist_can_assign(_cultist, true))
		{
			return false;
		}

		// The displaced worker takes the vacated slot only if that event can accept them.
		var _can_swap = instance_exists(_displaced_cultist)
			&& is_struct(_origin_event)
			&& _origin_slot_index < _origin_event.cultist_cost * _origin_event.activation_limit
			&& _origin_event.cultist_is_eligible_check(_displaced_cultist);

		if (is_struct(_origin_event))
		{
			_origin_event.assigned_cultists[_origin_slot_index] = _can_swap ? _displaced_cultist : noone;

			if (_origin_event != self)
			{
				day_event_execution_timer_reset(_origin_event);
			}
		}

		if (instance_exists(_displaced_cultist))
		{
			_displaced_cultist.assigned_event = _can_swap ? _origin_event : noone;
		}

		// Pad with noone explicitly: GameMaker's default array growth value is not an empty instance.
		for (var _empty_index = _stored_slot_count; _empty_index <= _slot_index; ++_empty_index)
		{
			array_push(assigned_cultists, noone);
		}

		assigned_cultists[_slot_index] = _cultist;
		_cultist.assigned_event = self;
		day_event_execution_timer_reset(self);

		// A funded event will execute today, so it no longer needs tomorrow's pin.
		if (day_event_has_funded_activation(self) && day_event_pin_is_event(self))
		{
			day_event_pin_clear(self);
		}

		// Some Jobs introduce a mechanic immediately after their first successful assignment.
		if (variable_struct_exists(self, "assignment_tutorial_hint_id")
			&& variable_global_exists("tutorial_hint_trigger"))
		{
			global.tutorial_hint_trigger(assignment_tutorial_hint_id);
		}

		return true;
	};

	cultist_unassign = function(_cultist)
	{
		if (!instance_exists(_cultist))
		{
			return false;
		}

		var _cultist_count = array_length(assigned_cultists);

		for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
		{
			if (assigned_cultists[_cultist_index] == _cultist)
			{
				// Leave a vacancy instead of shifting another worker into a different HP-cost slot.
				assigned_cultists[_cultist_index] = noone;
				_cultist.assigned_event = noone;
				day_event_execution_timer_reset(self);
				return true;
			}
		}

		return false;
	};

	execute = function()
	{
		var _ready_count = activation_ready_count_get();
		var _executed_count = 0;
		// Consume the prepared knife once, before actions can prepare another one.
		var _knife_discount = _ready_count > 0 ? global.next_rite_hp_discount : 0;
		if (_ready_count > 0)
		{
			global.next_rite_hp_discount = 0;
		}

		for (var _activation_index = 0;
			_activation_index < activation_limit && _executed_count < _ready_count;
			++_activation_index)
		{
			// Preserve slot order for asymmetric HP costs and skip unstaffed optional groups.
			if (!day_event_activation_staffing_is_ready(self, _activation_index))
			{
				continue;
			}

			var _first_cultist_index = _activation_index * cultist_cost;
			var _activation_cultists = array_create(cultist_cost);
			array_copy(_activation_cultists, 0, assigned_cultists, _first_cultist_index, cultist_cost);
			var _action_count = array_length(actions);
			var _ignore_hp_cost_modifiers = day_event_hp_cost_modifiers_are_ignored(self);
			var _additional_hp_cost = _ignore_hp_cost_modifiers
				? 0
				: cannon_satisfaction_event_hp_cost_get()
					+ day_event_damaged_building_hp_cost_get(self);
			var _activation_cultist_count = array_length(_activation_cultists);

			// Existing specialists receive one shared discount before this Rite advances work history.
			for (var _cultist_index = 0; _cultist_index < _activation_cultist_count; ++_cultist_index)
			{
				var _activation_cultist = _activation_cultists[_cultist_index];

				if (instance_exists(_activation_cultist))
				{
					_activation_cultist.event_knife_hp_discount_remaining = _knife_discount;
					// Charge only completed participation, before actions may sacrifice the worker.
					_activation_cultist.spirit = max(0,
						_activation_cultist.spirit - BALANCE_EVENT_CULTIST_RITE_SPIRIT_COST);
					_activation_cultist.event_mastery_hp_discount_remaining =
						day_event_cultist_mastery_hp_discount_get(_activation_cultist, self);
				}

				// Record before an action can transform or sacrifice its workers.
				day_event_cultist_work_history_add(_activation_cultist, self);
			}

			for (var _action_index = 0; _action_index < _action_count; ++_action_index)
			{
				var _action = actions[_action_index];

				if (is_struct(_action) && variable_struct_exists(_action, "execute"))
				{
					_action.execute(self, _activation_cultists);
				}
			}

			// Cannon sulking and damaged buildings increase every assigned Cultist's HP cost.
			if (_additional_hp_cost > 0)
			{
				day_event_cultist_hp_cost_apply(_activation_cultists, _additional_hp_cost);
			}

			// Never let an unused Rite discount affect later damage such as the Whip.
			for (var _discount_clear_index = 0;
				_discount_clear_index < _activation_cultist_count;
				++_discount_clear_index)
			{
				var _discount_clear_cultist = _activation_cultists[_discount_clear_index];

				if (instance_exists(_discount_clear_cultist))
				{
					_discount_clear_cultist.event_mastery_hp_discount_remaining = 0;
					_discount_clear_cultist.event_knife_hp_discount_remaining = 0;
				}
			}

			activation_count++;
			_executed_count++;
		}

		// Event-wide Satisfaction costs apply once per successfully funded card.
		if (_executed_count > 0
			&& variable_struct_exists(self, "cannon_satisfaction_cost"))
		{
			cannon_satisfaction_add(-max(0, cannon_satisfaction_cost));
		}

		is_resolved = true;

		for (var _assigned_index = 0; _assigned_index < array_length(assigned_cultists); ++_assigned_index)
		{
			var _assigned_cultist = assigned_cultists[_assigned_index];

			if (instance_exists(_assigned_cultist))
			{
				_assigned_cultist.assigned_event = noone;
			}
		}

		return _executed_count;
	};
}

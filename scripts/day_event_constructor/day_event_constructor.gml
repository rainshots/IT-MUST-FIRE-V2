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
	actions = _actions;
	assigned_cultists = [];
	modifiers = [];
	activation_count = 0;
	is_resolved = false;

	cultist_can_assign = function(_cultist, _ignore_capacity = false)
	{
		if (!instance_exists(_cultist)
			|| !variable_instance_exists(_cultist, "is_available")
			|| !_cultist.is_available()
			|| is_resolved
			|| (!_ignore_capacity
				&& array_length(assigned_cultists) >= cultist_cost * activation_limit))
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

		var _assigned_count = array_length(assigned_cultists);
		var _funded_count = floor(_assigned_count / cultist_cost);
		return min(_funded_count, activation_limit - activation_count);
	};

	cultist_assign = function(_cultist)
	{
		if (!cultist_can_assign(_cultist))
		{
			return false;
		}

		array_push(assigned_cultists, _cultist);
		_cultist.assigned_event = self;

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
				array_delete(assigned_cultists, _cultist_index, 1);
				_cultist.assigned_event = noone;
				return true;
			}
		}

		return false;
	};

	execute = function()
	{
		var _ready_count = activation_ready_count_get();

		for (var _activation_index = 0; _activation_index < _ready_count; ++_activation_index)
		{
			var _first_cultist_index = _activation_index * cultist_cost;
			var _activation_cultists = array_create(cultist_cost);
			array_copy(_activation_cultists, 0, assigned_cultists, _first_cultist_index, cultist_cost);
			var _action_count = array_length(actions);
			var _additional_hp_cost = cannon_satisfaction_event_hp_cost_get()
				+ day_event_damaged_building_hp_cost_get(self);
			var _activation_cultist_count = array_length(_activation_cultists);

			// Existing specialists receive one shared discount before this Rite advances work history.
			for (var _cultist_index = 0; _cultist_index < _activation_cultist_count; ++_cultist_index)
			{
				var _activation_cultist = _activation_cultists[_cultist_index];

				if (instance_exists(_activation_cultist))
				{
					_activation_cultist.event_specialization_hp_discount_remaining =
						day_event_cultist_specialization_hp_discount_get(_activation_cultist, self);
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
					_discount_clear_cultist.event_specialization_hp_discount_remaining = 0;
				}
			}

			activation_count++;
		}

		// Event-wide Satisfaction costs apply once per successfully funded card.
		if (_ready_count > 0
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

		return _ready_count;
	};
}

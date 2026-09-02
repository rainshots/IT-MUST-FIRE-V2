/// @description Creates definitions for cultist and resource event slots, then constructs a day event.
function day_event_cultist_slot(_is_optional = false)
{
	return { slot_type: "cultist", is_optional: _is_optional };
}

function day_event_resource_slot(_resource, _amount)
{
	return { slot_type: "resource", resource: _resource, amount: max(0, floor(_amount)) };
}

/// @description Creates a day event. Optional slot definitions replace its legacy cultist-only cost.
function day_event_constructor(_event_id, _title, _description, _cultist_cost, _activation_limit, _actions = [], _slot_definitions = []) constructor
{
	event_id = _event_id;
	title = _title;
	description = _description;
	activation_limit = max(1, floor(_activation_limit));
	actions = _actions;
	assigned_cultists = [];
	activation_count = 0;
	is_resolved = false;

	var _base_slots = _slot_definitions;
	if (!is_array(_base_slots) || array_length(_base_slots) <= 0)
	{
		_base_slots = [];
		for (var _slot_index = 0; _slot_index < max(1, floor(_cultist_cost)); ++_slot_index) array_push(_base_slots, day_event_cultist_slot());
	}

	slots_per_activation = array_length(_base_slots);
	slots = [];
	cultist_cost = 0;
	for (var _slot_index = 0; _slot_index < slots_per_activation; ++_slot_index)
	{
		var _definition = _base_slots[_slot_index];
		if (!is_struct(_definition) || !variable_struct_exists(_definition, "slot_type") || _definition.slot_type != "resource") cultist_cost++;
	}

	for (var _activation_index = 0; _activation_index < activation_limit; ++_activation_index)
	{
		for (var _slot_index = 0; _slot_index < slots_per_activation; ++_slot_index)
		{
			var _definition = _base_slots[_slot_index];
			var _is_resource_slot = is_struct(_definition) && variable_struct_exists(_definition, "slot_type") && _definition.slot_type == "resource";
			if (_is_resource_slot)
			{
				array_push(slots, {
					slot_type: "resource", activation_index: _activation_index,
					resource: variable_struct_exists(_definition, "resource") ? _definition.resource : RESOURCES.IRON,
					amount: variable_struct_exists(_definition, "amount") ? max(0, floor(_definition.amount)) : 0,
					paid: false
				});
			}
			else
			{
				array_push(slots, {
					slot_type: "cultist",
					activation_index: _activation_index,
					cultist: noone,
					is_optional: is_struct(_definition)
						&& variable_struct_exists(_definition, "is_optional")
						&& _definition.is_optional
				});
			}
		}
	}

	assigned_cultists_rebuild = function()
	{
		assigned_cultists = [];
		for (var _slot_index = 0; _slot_index < array_length(slots); ++_slot_index)
		{
			var _slot = slots[_slot_index];
			if (_slot.slot_type == "cultist" && instance_exists(_slot.cultist)) array_push(assigned_cultists, _slot.cultist);
		}
	};

	cultist_is_eligible_check = function(_cultist)
	{
		return !variable_struct_exists(self, "cultist_is_eligible") || !is_callable(cultist_is_eligible) || cultist_is_eligible(_cultist);
	};

	cultist_can_assign = function(_cultist, _ignore_capacity = false)
	{
		if (!instance_exists(_cultist) || !variable_instance_exists(_cultist, "is_available")
			|| !_cultist.is_available() || is_resolved || !cultist_is_eligible_check(_cultist)) return false;
		if (_ignore_capacity) return true;
		for (var _slot_index = 0; _slot_index < array_length(slots); ++_slot_index)
		{
			var _slot = slots[_slot_index];
			if (_slot.slot_type == "cultist" && !instance_exists(_slot.cultist)) return true;
		}
		return false;
	};

	cultist_assign_to_slot = function(_cultist, _slot_index)
	{
		if (_slot_index < 0 || _slot_index >= array_length(slots)) return false;
		var _slot = slots[_slot_index];
		if (_slot.slot_type != "cultist" || instance_exists(_slot.cultist) || !cultist_can_assign(_cultist, true)) return false;
		_slot.cultist = _cultist;
		_cultist.assigned_event = self;
		assigned_cultists_rebuild();
		if (day_event_has_funded_activation(self) && day_event_pin_is_event(self)) day_event_pin_clear(self);
		if (variable_struct_exists(self, "assignment_tutorial_hint_id") && variable_global_exists("tutorial_hint_trigger"))
			global.tutorial_hint_trigger(assignment_tutorial_hint_id);
		return true;
	};

	cultist_assign = function(_cultist)
	{
		if (!cultist_can_assign(_cultist)) return false;
		for (var _slot_index = 0; _slot_index < array_length(slots); ++_slot_index)
		{
			var _slot = slots[_slot_index];
			if (_slot.slot_type == "cultist" && !instance_exists(_slot.cultist)) return cultist_assign_to_slot(_cultist, _slot_index);
		}
		return false;
	};

	cultist_unassign = function(_cultist)
	{
		if (!instance_exists(_cultist)) return false;
		for (var _slot_index = 0; _slot_index < array_length(slots); ++_slot_index)
		{
			var _slot = slots[_slot_index];
			if (_slot.slot_type == "cultist" && _slot.cultist == _cultist)
			{
				_slot.cultist = noone;
				_cultist.assigned_event = noone;
				assigned_cultists_rebuild();
				return true;
			}
		}
		return false;
	};

	resource_slot_toggle = function(_slot_index)
	{
		if (is_resolved || _slot_index < 0 || _slot_index >= array_length(slots)) return false;
		var _slot = slots[_slot_index];
		if (_slot.slot_type != "resource") return false;
		if (_slot.paid)
		{
			global.resources[_slot.resource] += _slot.amount;
			_slot.paid = false;
			return true;
		}
		if (_slot.resource < 0 || _slot.resource >= array_length(global.resources) || global.resources[_slot.resource] < _slot.amount) return false;
		global.resources[_slot.resource] -= _slot.amount;
		_slot.paid = true;
		if (day_event_has_funded_activation(self) && day_event_pin_is_event(self)) day_event_pin_clear(self);
		return true;
	};

	resource_slots_refund = function()
	{
		for (var _slot_index = 0; _slot_index < array_length(slots); ++_slot_index)
		{
			var _slot = slots[_slot_index];
			if (_slot.slot_type == "resource" && _slot.paid)
			{
				global.resources[_slot.resource] += _slot.amount;
				_slot.paid = false;
			}
		}
	};

	slot_funded_activation_count_get = function()
	{
		var _ready_count = 0;
		for (var _activation_index = activation_count; _activation_index < activation_limit; ++_activation_index)
		{
			var _is_funded = true;
			var _assigned_cultist_count = 0;
			var _first_slot_index = _activation_index * slots_per_activation;
			for (var _slot_offset = 0; _slot_offset < slots_per_activation; ++_slot_offset)
			{
				var _slot = slots[_first_slot_index + _slot_offset];

				if (_slot.slot_type == "cultist" && instance_exists(_slot.cultist))
				{
					_assigned_cultist_count++;
				}

				var _optional_cultist_slot_is_empty = _slot.slot_type == "cultist"
					&& variable_struct_exists(_slot, "is_optional")
					&& _slot.is_optional
					&& !instance_exists(_slot.cultist);
				var _slot_is_unfunded = (_slot.slot_type == "resource" && !_slot.paid)
					|| (_slot.slot_type == "cultist"
						&& !instance_exists(_slot.cultist)
						&& !_optional_cultist_slot_is_empty);

				if (_slot_is_unfunded)
				{
					_is_funded = false;
					break;
				}
			}

			var _minimum_cultist_count = variable_struct_exists(self, "minimum_cultist_count")
				? max(0, floor(minimum_cultist_count))
				: 0;

			if (_assigned_cultist_count < _minimum_cultist_count)
			{
				_is_funded = false;
			}

			if (!_is_funded) break;
			_ready_count++;
		}
		return _ready_count;
	};

	activation_ready_count_get = function()
	{
		if (variable_struct_exists(self, "requires_squad_selection") && requires_squad_selection
			&& (!variable_struct_exists(self, "selected_squad") || !is_struct(selected_squad))) return 0;

		return slot_funded_activation_count_get();
	};

	execute = function()
	{
		var _ready_count = activation_ready_count_get();
		for (var _ready_index = 0; _ready_index < _ready_count; ++_ready_index)
		{
			var _first_slot_index = activation_count * slots_per_activation;
			var _activation_cultists = [];
			for (var _slot_offset = 0; _slot_offset < slots_per_activation; ++_slot_offset)
			{
				var _slot = slots[_first_slot_index + _slot_offset];
				if (_slot.slot_type == "cultist" && instance_exists(_slot.cultist)) array_push(_activation_cultists, _slot.cultist);
				else if (_slot.slot_type == "resource") _slot.paid = false; // Consumed, not refundable.
			}
			var _ignores_additional_hp_cost = variable_struct_exists(self, "ignores_additional_hp_cost")
				&& ignores_additional_hp_cost;
			var _additional_hp_cost = _ignores_additional_hp_cost
				? 0
				: cannon_satisfaction_event_hp_cost_get() + day_event_damaged_building_hp_cost_get(self);
			for (var _action_index = 0; _action_index < array_length(actions); ++_action_index)
			{
				var _action = actions[_action_index];
				if (is_struct(_action) && variable_struct_exists(_action, "execute")) _action.execute(self, _activation_cultists);
			}
			if (_additional_hp_cost > 0) day_event_cultist_hp_cost_apply(_activation_cultists, _additional_hp_cost);
			activation_count++;
		}
		is_resolved = true;
		for (var _cultist_index = 0; _cultist_index < array_length(assigned_cultists); ++_cultist_index)
			if (instance_exists(assigned_cultists[_cultist_index])) assigned_cultists[_cultist_index].assigned_event = noone;
		return _ready_count;
	};
}

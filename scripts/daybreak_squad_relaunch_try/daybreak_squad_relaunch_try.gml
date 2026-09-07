/// @description Reloads the first fully fallen squad once per night with one quarter of each unit's Max HP.
/// @param {Struct} squad Squad whose dying member has resolved replacement effects and cleared its slot.
function daybreak_squad_relaunch_try(_squad)
{
	if (global.day_phase != DAY_PHASE.NIGHT || !is_struct(_squad)
		|| _squad.squad_type == SQUAD_TYPE.ARCHDEMON
		|| !instance_exists(o_game_controller) || !instance_exists(o_cannon))
	{
		return false;
	}

	var _game_controller = instance_find(o_game_controller, 0);
	if (!_game_controller.no_rest_for_the_dead_active || _game_controller.no_rest_for_the_dead_used)
	{
		return false;
	}

	// Zero-HP instances must also finish their death effects before the squad can return.
	var _active_slot_count = array_length(_squad.units);
	for (var _slot_index = 0; _slot_index < _active_slot_count; ++_slot_index)
	{
		if (instance_exists(_squad.units[_slot_index]))
		{
			return false;
		}
	}

	var _unit_count = array_length(_squad.unit_objects);
	if (_unit_count <= 0)
	{
		return false;
	}

	// Reserve the shared use before spawning so simultaneous deaths cannot claim it twice.
	_game_controller.no_rest_for_the_dead_used = true;
	_squad.units = [];
	var _primary_unit = noone;

	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		var _unit = squad_unit_spawn(_squad, _squad.unit_objects[_unit_index], _unit_index);
		array_push(_squad.units, _unit);
		if (!instance_exists(_unit))
		{
			continue;
		}

		_unit.hp = _unit.max_hp * BALANCE_NO_REST_FOR_THE_DEAD_HP_SHARE;
		_unit.cannon_loading = false;
		_unit.cannon_loaded = true;
		_game_controller.cultist_projectile_deploy_unit_hide(_unit);
		if (!instance_exists(_primary_unit))
		{
			_primary_unit = _unit;
		}
	}

	// The normal shell queue handles aiming, firing, and deployment without restoring health.
	return instance_exists(_primary_unit) && _game_controller.queue_cultist_projectile(_primary_unit);
}

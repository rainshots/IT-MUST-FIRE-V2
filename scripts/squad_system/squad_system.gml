/// @description Creates and manages persistent player squads.

function squad_constructor(_squad_type, _primary_unit_object, _unit_count) constructor
{
	squad_type = _squad_type;
	primary_unit_object = _primary_unit_object;
	unit_objects = array_create(max(1, floor(_unit_count)), _primary_unit_object);
	units = [];
	properties = {
		marker_is_dragged: false,
		march_is_active: false,
		march_enemy_check_timer: 0,
		march_speed_bonus_active: false
	};
	name = "";
	total_max_hp = 0;
};

function squad_type_limit_get(_squad_type)
{
	return global.squad_limits[_squad_type];
}

function squad_icon_sprite_current_get(_squad)
{
	if (!is_struct(_squad))
	{
		return noone;
	}

	// The first surviving member represents the squad while its composition may change.
	for (var _unit_index = 0; _unit_index < array_length(_squad.units); ++_unit_index)
	{
		var _unit = _squad.units[_unit_index];

		if (instance_exists(_unit) && sprite_exists(_unit.sprite_index))
		{
			return _unit.sprite_index;
		}
	}

	return noone;
}

function squad_icon_sprite_get(_squad)
{
	if (!is_struct(_squad))
	{
		return noone;
	}

	// Night combat uses one frozen icon in both the roster and world marker.
	if (global.day_phase == DAY_PHASE.NIGHT)
	{
		if (!variable_struct_exists(_squad.properties, "night_icon_sprite"))
		{
			_squad.properties.night_icon_sprite = squad_icon_sprite_current_get(_squad);
		}

		return _squad.properties.night_icon_sprite;
	}

	return squad_icon_sprite_current_get(_squad);
}

function squad_night_icon_sprites_capture()
{
	if (!variable_global_exists("squads"))
	{
		return;
	}

	// Refresh every snapshot once after the final night-start roster is prepared.
	for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
	{
		var _squad = global.squads[_squad_index];

		if (is_struct(_squad))
		{
			_squad.properties.night_icon_sprite = squad_icon_sprite_current_get(_squad);
		}
	}
}

function squad_type_count_get(_squad_type)
{
	var _count = 0;

	for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
	{
		if (global.squads[_squad_index].squad_type == _squad_type)
		{
			_count++;
		}
	}

	return _count;
}

function squad_slot_is_available(_squad_type)
{
	return squad_type_count_get(_squad_type) < squad_type_limit_get(_squad_type);
}

function squad_name_display_get(_squad_name)
{
	var _display_name = string(_squad_name);

	// Convert legacy squad names without changing stored gameplay data.
	_display_name = string_replace_all(_display_name, "Skeleton Warriors", "Bone Warriors");
	_display_name = string_replace_all(_display_name, "Skeleton Archers", "Bone Archers");
	_display_name = string_replace_all(_display_name, "Skeleton Mages", "Bone Mages");

	return _display_name;
}

function squad_name_create(_primary_unit_object)
{
	var _base_name = object_get_name(_primary_unit_object);

	if (_primary_unit_object == o_skeleton) _base_name = "Skeletons";
	else if (_primary_unit_object == o_skeleton_bonelet) _base_name = "Bonelets";
	else if (_primary_unit_object == o_skeleton_warrior) _base_name = "Bone Warriors";
	else if (_primary_unit_object == o_skeleton_archer) _base_name = "Bone Archers";
	else if (_primary_unit_object == o_skeleton_mage) _base_name = "Bone Mages";
	else if (_primary_unit_object == o_skeleton_healer) _base_name = "Skeleton Healers";
	else if (_primary_unit_object == o_mawling) _base_name = "Mawlings";
	else if (_primary_unit_object == o_demon_wizard) _base_name = "Demon Wizards";
	else if (_primary_unit_object == o_pitling) _base_name = "Pitlings";
	else if (_primary_unit_object == o_succubus) _base_name = "Succubi";
	else if (_primary_unit_object == o_balgor) _base_name = "Balgors";
	else if (_primary_unit_object == o_archdemon) _base_name = "Archdemon";

	var _matching_name_count = 0;

	for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
	{
		var _existing_name = squad_name_display_get(global.squads[_squad_index].name);

		if (_existing_name == _base_name || string_pos(_base_name + " ", _existing_name) == 1)
		{
			_matching_name_count++;
		}
	}

	return _matching_name_count == 0 ? _base_name : _base_name + " " + string(_matching_name_count + 1);
}

function foundry_unit_squad_type_get(_unit)
{
	if (!instance_exists(_unit))
	{
		return -1;
	}

	// Squad membership is the authoritative classification for persistent units.
	if (variable_instance_exists(_unit, "squad") && is_struct(_unit.squad))
	{
		return _unit.squad.squad_type;
	}

	var _unit_object = _unit.object_index;

	if (_unit_object == o_mawling
		|| _unit_object == o_demon_wizard
		|| _unit_object == o_pitling
		|| _unit_object == o_succubus
		|| _unit_object == o_balgor)
	{
		return SQUAD_TYPE.DEMON;
	}

	if (_unit_object == o_skeleton
		|| _unit_object == o_skeleton_bonelet
		|| _unit_object == o_skeleton_warrior
		|| _unit_object == o_skeleton_archer
		|| _unit_object == o_skeleton_mage
		|| _unit_object == o_skeleton_healer
		|| _unit_object == o_zombie)
	{
		return SQUAD_TYPE.UNDEAD;
	}

	return -1;
}

function foundry_unit_permanent_bonuses_apply(_unit)
{
	if (!instance_exists(_unit))
	{
		return false;
	}

	var _squad_type = foundry_unit_squad_type_get(_unit);
	var _health_multiplier = 1;
	var _damage_multiplier = 1;
	var _attack_speed_multiplier = 1;

	if (_squad_type == SQUAD_TYPE.DEMON)
	{
		_health_multiplier = variable_global_exists("foundry_demon_health_multiplier")
			? global.foundry_demon_health_multiplier
			: 1;
		_damage_multiplier = variable_global_exists("foundry_demon_damage_multiplier")
			? global.foundry_demon_damage_multiplier
			: 1;
	}
	else if (_squad_type == SQUAD_TYPE.UNDEAD)
	{
		_health_multiplier = variable_global_exists("foundry_undead_health_multiplier")
			? global.foundry_undead_health_multiplier
			: 1;
		_attack_speed_multiplier = variable_global_exists("foundry_undead_attack_speed_multiplier")
			? global.foundry_undead_attack_speed_multiplier
			: 1;
	}
	else
	{
		return false;
	}

	// Apply only the difference from the multiplier already present on this instance.
	var _applied_health_multiplier = variable_instance_exists(_unit, "foundry_health_multiplier_applied")
		? _unit.foundry_health_multiplier_applied
		: 1;
	var _health_ratio = _health_multiplier / max(0.0001, _applied_health_multiplier);

	if (_health_ratio != 1 && variable_instance_exists(_unit, "max_hp"))
	{
		_unit.max_hp *= _health_ratio;

		if (variable_instance_exists(_unit, "hp"))
		{
			_unit.hp = min(_unit.max_hp, _unit.hp * _health_ratio);
		}
	}

	_unit.foundry_health_multiplier_applied = _health_multiplier;

	var _applied_damage_multiplier = variable_instance_exists(_unit, "foundry_damage_multiplier_applied")
		? _unit.foundry_damage_multiplier_applied
		: 1;
	var _damage_ratio = _damage_multiplier / max(0.0001, _applied_damage_multiplier);

	if (_damage_ratio != 1)
	{
		if (variable_instance_exists(_unit, "damage"))
		{
			_unit.damage *= _damage_ratio;
		}

		if (variable_instance_exists(_unit, "magic_damage"))
		{
			_unit.magic_damage *= _damage_ratio;
		}
	}

	_unit.foundry_damage_multiplier_applied = _damage_multiplier;

	var _applied_attack_speed_multiplier = variable_instance_exists(_unit, "foundry_attack_speed_multiplier_applied")
		? _unit.foundry_attack_speed_multiplier_applied
		: 1;
	var _attack_speed_ratio = _attack_speed_multiplier / max(0.0001, _applied_attack_speed_multiplier);

	if (_attack_speed_ratio != 1 && variable_instance_exists(_unit, "reload_time"))
	{
		_unit.reload_time /= _attack_speed_ratio;

		if (variable_instance_exists(_unit, "reload_timer"))
		{
			_unit.reload_timer /= _attack_speed_ratio;
		}
	}

	_unit.foundry_attack_speed_multiplier_applied = _attack_speed_multiplier;
	return true;
}

function squad_unit_permanent_bonuses_apply(_squad, _unit)
{
	if (!is_struct(_squad) || !instance_exists(_unit))
	{
		return false;
	}

	if (variable_struct_exists(_squad.properties, "health_multiplier")
		&& variable_instance_exists(_unit, "max_hp"))
	{
		var _health_multiplier = _squad.properties.health_multiplier;
		_unit.max_hp *= _health_multiplier;

		if (variable_instance_exists(_unit, "hp"))
		{
			_unit.hp = min(_unit.max_hp, _unit.hp * _health_multiplier);
		}
	}

	if (variable_struct_exists(_squad.properties, "damage_multiplier"))
	{
		var _damage_multiplier = _squad.properties.damage_multiplier;

		if (variable_instance_exists(_unit, "damage"))
		{
			_unit.damage *= _damage_multiplier;
		}

		if (variable_instance_exists(_unit, "magic_damage"))
		{
			_unit.magic_damage *= _damage_multiplier;
		}
	}

	return true;
}

function squad_unit_spawn(_squad, _unit_object, _unit_index)
{
	if (!instance_exists(o_cannon)) return noone;

	var _cannon = instance_find(o_cannon, 0);
	var _angle = (_unit_index * 137.5) mod 360;
	var _distance = 90 + (24 * sqrt(_unit_index));
	var _unit = instance_create_layer(_cannon.x + lengthdir_x(_distance, _angle), _cannon.y + lengthdir_y(_distance, _angle), "Instances", _unit_object);
	_unit.squad = _squad;
	_unit.squad_unit_index = _unit_index;
	squad_unit_permanent_bonuses_apply(_squad, _unit);
	foundry_unit_permanent_bonuses_apply(_unit);
	_unit.foundry_permanent_bonuses_pending = false;

	_unit.hp = _unit.max_hp;
	return _unit;
}

function squad_create(_squad_type, _primary_unit_object, _unit_count)
{
	if (!squad_slot_is_available(_squad_type)) return noone;

	var _squad = new squad_constructor(_squad_type, _primary_unit_object, _unit_count);
	_squad.name = squad_name_create(_primary_unit_object);
	array_push(global.squads, _squad);

	for (var _unit_index = 0; _unit_index < array_length(_squad.unit_objects); ++_unit_index)
	{
		var _unit = squad_unit_spawn(_squad, _squad.unit_objects[_unit_index], _unit_index);
		array_push(_squad.units, _unit);

		if (instance_exists(_unit))
		{
			_squad.total_max_hp += _unit.max_hp;
		}
	}

	return _squad;
}

function squad_copy_with_extra_slot(_source_squad)
{
	if (!is_struct(_source_squad) || _source_squad.squad_type == SQUAD_TYPE.ARCHDEMON)
	{
		return noone;
	}

	var _unit_count = array_length(_source_squad.unit_objects);

	if (_unit_count <= 0)
	{
		return noone;
	}

	// This upgrade grants the copied squad its own permanent slot.
	global.squad_limits[_source_squad.squad_type]++;

	var _copied_squad = new squad_constructor(
		_source_squad.squad_type,
		_source_squad.primary_unit_object,
		_unit_count
	);
	_copied_squad.unit_objects = array_create(_unit_count, noone);
	array_copy(_copied_squad.unit_objects, 0, _source_squad.unit_objects, 0, _unit_count);
	_copied_squad.name = squad_name_create(_source_squad.primary_unit_object);

	// Copy permanent squad upgrades, but create independent marker state.
	if (variable_struct_exists(_source_squad.properties, "health_multiplier"))
	{
		_copied_squad.properties.health_multiplier = _source_squad.properties.health_multiplier;
	}

	if (variable_struct_exists(_source_squad.properties, "damage_multiplier"))
	{
		_copied_squad.properties.damage_multiplier = _source_squad.properties.damage_multiplier;
	}

	array_push(global.squads, _copied_squad);

	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		var _unit = squad_unit_spawn(
			_copied_squad,
			_copied_squad.unit_objects[_unit_index],
			_unit_index
		);
		array_push(_copied_squad.units, _unit);

		if (instance_exists(_unit))
		{
			_copied_squad.total_max_hp += _unit.max_hp;
		}
	}

	return _copied_squad;
}

function squad_unit_resurrect_as_bonelet(_dead_unit)
{
	if (!instance_exists(_dead_unit))
	{
		return noone;
	}

	var _bonelet = instance_create_layer(_dead_unit.x, _dead_unit.y, "Instances", o_skeleton_bonelet);

	if (!instance_exists(_bonelet))
	{
		return noone;
	}

	if (variable_instance_exists(_dead_unit, "squad") && is_struct(_dead_unit.squad))
	{
		var _squad = _dead_unit.squad;
		var _unit_index = variable_instance_exists(_dead_unit, "squad_unit_index")
			? _dead_unit.squad_unit_index
			: -1;

		if (_unit_index >= 0 && _unit_index < array_length(_squad.units))
		{
			_bonelet.squad = _squad;
			_bonelet.squad_unit_index = _unit_index;
			squad_unit_permanent_bonuses_apply(_squad, _bonelet);
			foundry_unit_permanent_bonuses_apply(_bonelet);
			_bonelet.foundry_permanent_bonuses_pending = false;
			_bonelet.hp = _bonelet.max_hp;

			// Replace only the active night unit. The permanent squad composition returns in the morning.
			_squad.units[_unit_index] = _bonelet;
		}
	}

	return _bonelet;
}

function squad_register_existing_unit(_squad_type, _unit)
{
	if (!instance_exists(_unit) || !squad_slot_is_available(_squad_type)) return noone;

	var _squad = new squad_constructor(_squad_type, _unit.object_index, 1);
	_squad.name = variable_instance_exists(_unit, "cultist_name") ? _unit.cultist_name : squad_name_create(_unit.object_index);
	_squad.units = [_unit];
	_unit.squad = _squad;
	_unit.squad_unit_index = 0;
	foundry_unit_permanent_bonuses_apply(_unit);
	_unit.foundry_permanent_bonuses_pending = false;
	_squad.total_max_hp = _unit.max_hp;
	array_push(global.squads, _squad);
	return _squad;
}

function squad_units_restore_morning()
{
	for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
	{
		var _squad = global.squads[_squad_index];
		_squad.properties.marker_is_dragged = false;
		_squad.properties.march_is_active = false;
		_squad.properties.march_enemy_check_timer = 0;
		_squad.properties.march_speed_bonus_active = false;
		_squad.properties.combat_guide_unit = noone;

		if (_squad.squad_type == SQUAD_TYPE.ARCHDEMON) continue;

		for (var _unit_index = 0; _unit_index < array_length(_squad.units); ++_unit_index)
		{
			if (instance_exists(_squad.units[_unit_index])) instance_destroy(_squad.units[_unit_index]);
		}

		_squad.units = [];

		for (var _unit_index = 0; _unit_index < array_length(_squad.unit_objects); ++_unit_index)
		{
			array_push(_squad.units, squad_unit_spawn(_squad, _squad.unit_objects[_unit_index], _unit_index));
		}
	}
}

function squad_total_hp_get(_squad)
{
	var _hp = 0;
	var _is_archdemon_squad = _squad.squad_type == SQUAD_TYPE.ARCHDEMON;
	var _max_hp = _is_archdemon_squad ? 0 : _squad.total_max_hp;

	for (var _unit_index = 0; _unit_index < array_length(_squad.units); ++_unit_index)
	{
		var _unit = _squad.units[_unit_index];

		if (!instance_exists(_unit))
		{
			continue;
		}

		if (variable_instance_exists(_unit, "hp"))
		{
			_hp += max(0, _unit.hp);
		}

		// Archdemon Max HP changes with form and attributes, so never use its creation-time cache.
		if (_is_archdemon_squad && variable_instance_exists(_unit, "max_hp"))
		{
			_max_hp += max(0, _unit.max_hp);
		}
	}

	return [_hp, max(1, _max_hp)];
}

function squad_marker_position_update(_squad)
{
	var _marker_is_dragged = variable_struct_exists(_squad.properties, "marker_is_dragged")
		&& _squad.properties.marker_is_dragged;
	var _march_is_active = variable_struct_exists(_squad.properties, "march_is_active")
		&& _squad.properties.march_is_active;

	if (_marker_is_dragged || _march_is_active)
	{
		return true;
	}

	var _position_x = 0;
	var _position_y = 0;
	var _unit_count = 0;

	for (var _unit_index = 0; _unit_index < array_length(_squad.units); ++_unit_index)
	{
		var _unit = _squad.units[_unit_index];

		if (instance_exists(_unit))
		{
			_position_x += _unit.x;
			_position_y += _unit.y;
			_unit_count++;
		}
	}

	if (_unit_count <= 0)
	{
		return false;
	}

	_squad.properties.marker_x = _position_x / _unit_count;
	_squad.properties.marker_y = _position_y / _unit_count;
	return true;
}

function squad_is_marching(_squad)
{
	return is_struct(_squad)
		&& variable_struct_exists(_squad.properties, "march_is_active")
		&& _squad.properties.march_is_active;
}

function squad_march_speed_multiplier_get(_squad)
{
	var _speed_bonus_is_active = squad_is_marching(_squad)
		&& variable_struct_exists(_squad.properties, "march_speed_bonus_active")
		&& _squad.properties.march_speed_bonus_active;

	return _speed_bonus_is_active ? BALANCE_SQUAD_MARCH_SPEED_MULTIPLIER : 1;
}

function squad_march_enemy_is_nearby(_squad)
{
	if (!is_struct(_squad))
	{
		return false;
	}

	var _check_radius_squared = BALANCE_SQUAD_MARCH_ENEMY_CHECK_RADIUS
		* BALANCE_SQUAD_MARCH_ENEMY_CHECK_RADIUS;
	var _enemy_count = instance_number(o_enemy_units);
	var _unit_count = array_length(_squad.units);

	// One enemy close to any living squad member disables the bonus for the whole squad.
	for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
	{
		var _enemy = instance_find(o_enemy_units, _enemy_index);

		if (!instance_exists(_enemy)
			|| !variable_instance_exists(_enemy, "hp")
			|| _enemy.hp <= 0
			|| !_enemy.visible)
		{
			continue;
		}

		for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
		{
			var _unit = _squad.units[_unit_index];

			if (!instance_exists(_unit)
				|| !variable_instance_exists(_unit, "hp")
				|| _unit.hp <= 0
				|| !_unit.visible)
			{
				continue;
			}

			var _distance_x = _enemy.x - _unit.x;
			var _distance_y = _enemy.y - _unit.y;
			var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);

			if (_distance_squared <= _check_radius_squared)
			{
				return true;
			}
		}
	}

	return false;
}

function squad_march_speed_bonus_update(_squad)
{
	if (!squad_is_marching(_squad))
	{
		return false;
	}

	var _check_interval = max(1, BALANCE_SQUAD_MARCH_ENEMY_CHECK_TIME * room_speed);
	var _time_scale = variable_global_exists("gameplay_time_scale")
		? global.gameplay_time_scale
		: 1;
	_squad.properties.march_enemy_check_timer += _time_scale;

	if (_squad.properties.march_enemy_check_timer < _check_interval)
	{
		return _squad.properties.march_speed_bonus_active;
	}

	_squad.properties.march_enemy_check_timer -= _check_interval;
	_squad.properties.march_speed_bonus_active = !squad_march_enemy_is_nearby(_squad);
	return _squad.properties.march_speed_bonus_active;
}

function squad_march_begin(_squad)
{
	if (!is_struct(_squad)
		|| !variable_struct_exists(_squad.properties, "marker_x")
		|| !variable_struct_exists(_squad.properties, "marker_y"))
	{
		return false;
	}

	_squad.properties.march_is_active = true;
	_squad.properties.march_enemy_check_timer = BALANCE_SQUAD_MARCH_ENEMY_CHECK_TIME * room_speed;
	_squad.properties.march_speed_bonus_active = false;
	_squad.properties.combat_guide_unit = noone;
	return true;
}

function squad_march_end(_squad)
{
	if (!is_struct(_squad))
	{
		return false;
	}

	_squad.properties.march_is_active = false;
	_squad.properties.march_enemy_check_timer = 0;
	_squad.properties.march_speed_bonus_active = false;
	_squad.properties.combat_guide_unit = noone;

	// Let every surviving unit immediately search for a combat target again.
	for (var _unit_index = 0; _unit_index < array_length(_squad.units); ++_unit_index)
	{
		var _unit = _squad.units[_unit_index];

		if (!instance_exists(_unit))
		{
			continue;
		}

		if (variable_instance_exists(_unit, "target_search_update_interval"))
		{
			_unit.target_search_update_timer = _unit.target_search_update_interval;
		}

		if (variable_instance_exists(_unit, "navigation_path_state_clear"))
		{
			_unit.navigation_path_state_clear();
		}
	}

	return true;
}

function squad_march_update(_squad)
{
	if (!squad_is_marching(_squad))
	{
		return false;
	}

	if (global.pause)
	{
		return true;
	}

	// The expensive all-units enemy proximity scan runs only once per gameplay second.
	squad_march_speed_bonus_update(_squad);

	// A held flag remains a live destination but cannot finish the march until released.
	if (variable_struct_exists(_squad.properties, "marker_is_dragged")
		&& _squad.properties.marker_is_dragged)
	{
		return true;
	}

	var _living_unit_count = 0;

	for (var _unit_index = 0; _unit_index < array_length(_squad.units); ++_unit_index)
	{
		var _unit = _squad.units[_unit_index];

		if (!instance_exists(_unit)
			|| !variable_instance_exists(_unit, "hp")
			|| _unit.hp <= 0
			|| !_unit.visible)
		{
			continue;
		}

		_living_unit_count++;

		if (point_distance(
			_unit.x,
			_unit.y,
			_squad.properties.marker_x,
			_squad.properties.marker_y
		) > BALANCE_SQUAD_MARCH_COMPLETE_RADIUS)
		{
			return true;
		}
	}

	// No surviving members or a fully gathered squad no longer needs a march target.
	squad_march_end(_squad);
	return _living_unit_count > 0;
}

function squad_unit_is_in_combat(_unit)
{
	if (!instance_exists(_unit)
		|| !variable_instance_exists(_unit, "hp")
		|| _unit.hp <= 0
		|| !_unit.visible
		|| !variable_instance_exists(_unit, "target_instance")
		|| !variable_instance_exists(_unit, "target_can_be_attacked"))
	{
		return false;
	}

	var _target = _unit.target_instance;

	// Moving toward the friendly cannon is guard movement, not combat.
	return _unit.target_can_be_attacked(_target)
		&& _target.object_index != o_cannon;
}

function squad_combat_guide_update(_squad)
{
	if (!is_struct(_squad))
	{
		return noone;
	}

	if (squad_is_marching(_squad))
	{
		_squad.properties.combat_guide_unit = noone;
		return noone;
	}

	var _current_guide = variable_struct_exists(_squad.properties, "combat_guide_unit")
		? _squad.properties.combat_guide_unit
		: noone;

	// Keep the current guide stable while it remains engaged.
	if (squad_unit_is_in_combat(_current_guide))
	{
		return _current_guide;
	}

	_squad.properties.combat_guide_unit = noone;

	for (var _unit_index = 0; _unit_index < array_length(_squad.units); ++_unit_index)
	{
		var _unit = _squad.units[_unit_index];

		if (squad_unit_is_in_combat(_unit))
		{
			_squad.properties.combat_guide_unit = _unit;
			return _unit;
		}
	}

	return noone;
}

function squad_combat_guides_update()
{
	if (global.pause
		|| global.day_phase != DAY_PHASE.NIGHT
		|| !variable_global_exists("squads"))
	{
		return;
	}

	// Resolve one stable engaged guide per squad once per gameplay frame.
	for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
	{
		squad_combat_guide_update(global.squads[_squad_index]);
	}
}

function squad_combat_guide_get(_squad, _requesting_unit)
{
	if (global.day_phase != DAY_PHASE.NIGHT
		|| !is_struct(_squad)
		|| !variable_struct_exists(_squad.properties, "combat_guide_unit"))
	{
		return noone;
	}

	var _guide = _squad.properties.combat_guide_unit;

	if (_guide == _requesting_unit || !squad_unit_is_in_combat(_guide))
	{
		return noone;
	}

	return _guide;
}

function squad_night_markers_update()
{
	if (global.day_phase != DAY_PHASE.NIGHT)
	{
		return;
	}

	for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
	{
		var _squad = global.squads[_squad_index];
		squad_march_update(_squad);
		squad_marker_position_update(_squad);
	}
}

function squad_marker_find_at_position(_world_x, _world_y)
{
	var _world_per_gui_x = 1;
	var _world_per_gui_y = 1;

	if (instance_exists(o_camera_controller))
	{
		var _camera_controller = instance_find(o_camera_controller, 0);
		_world_per_gui_x = camera_get_view_width(_camera_controller.camera_id) / max(1, display_get_gui_width());
		_world_per_gui_y = camera_get_view_height(_camera_controller.camera_id) / max(1, display_get_gui_height());
	}

	var _half_width = BALANCE_SQUAD_MARKER_WIDTH * 0.5 * _world_per_gui_x;
	var _half_height = BALANCE_SQUAD_MARKER_HEIGHT * 0.5 * _world_per_gui_y;
	var _marker_offset_y = BALANCE_SQUAD_MARKER_OFFSET_Y * _world_per_gui_y;

	for (var _squad_index = array_length(global.squads) - 1; _squad_index >= 0; --_squad_index)
	{
		var _squad = global.squads[_squad_index];

		if (!variable_struct_exists(_squad.properties, "marker_x")
			|| !variable_struct_exists(_squad.properties, "marker_y"))
		{
			continue;
		}

		if (point_in_rectangle(
			_world_x,
			_world_y,
			_squad.properties.marker_x - _half_width,
			_squad.properties.marker_y - _marker_offset_y - _half_height,
			_squad.properties.marker_x + _half_width,
			_squad.properties.marker_y - _marker_offset_y + _half_height
		))
		{
			return _squad;
		}
	}

	return noone;
}

function squad_drag_begin(_squad)
{
	if (!is_struct(_squad))
	{
		return false;
	}

	_squad.properties.marker_is_dragged = true;
	global.dragged_squad = _squad;

	return true;
}

function squad_drag_update(_squad, _target_x, _target_y)
{
	if (!is_struct(_squad))
	{
		return false;
	}

	if (!world_position_is_revealed_by_fog(_target_x, _target_y))
	{
		_target_x = _squad.properties.marker_x;
		_target_y = _squad.properties.marker_y;
	}

	_squad.properties.marker_x = _target_x;
	_squad.properties.marker_y = _target_y;

	return true;
}

function squad_drag_end(_squad, _start_march = true)
{
	if (!is_struct(_squad))
	{
		global.dragged_squad = noone;
		return false;
	}

	_squad.properties.marker_is_dragged = false;

	if (_start_march)
	{
		squad_march_begin(_squad);
	}
	else
	{
		squad_march_end(_squad);
	}

	global.dragged_squad = noone;
	return true;
}

function squad_night_markers_draw_gui()
{
	if (global.day_phase != DAY_PHASE.NIGHT || !instance_exists(o_camera_controller))
	{
		return;
	}

	var _camera_controller = instance_find(o_camera_controller, 0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = max(1, camera_get_view_width(_camera_controller.camera_id));
	var _camera_height = max(1, camera_get_view_height(_camera_controller.camera_id));
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();

	for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
	{
		var _squad = global.squads[_squad_index];

		if (!squad_marker_position_update(_squad))
		{
			continue;
		}

		var _marker_world_x = _squad.properties.marker_x;
		var _marker_world_y = _squad.properties.marker_y;
		var _marker_x = ((_marker_world_x - _camera_x) / _camera_width) * _gui_width;
		var _marker_y = ((_marker_world_y - _camera_y) / _camera_height) * _gui_height
			- BALANCE_SQUAD_MARKER_OFFSET_Y;

		if (_marker_x < -BALANCE_SQUAD_MARKER_WIDTH
			|| _marker_x > _gui_width + BALANCE_SQUAD_MARKER_WIDTH
			|| _marker_y < -BALANCE_SQUAD_MARKER_HEIGHT
			|| _marker_y > _gui_height + BALANCE_SQUAD_MARKER_HEIGHT)
		{
			continue;
		}

		var _left = _marker_x - (BALANCE_SQUAD_MARKER_WIDTH * 0.5);
		var _top = _marker_y - (BALANCE_SQUAD_MARKER_HEIGHT * 0.5);
		var _right = _left + BALANCE_SQUAD_MARKER_WIDTH;
		var _body_bottom = _top + BALANCE_SQUAD_MARKER_BODY_HEIGHT;
		var _bottom = _top + BALANCE_SQUAD_MARKER_HEIGHT;

		var _marker_background_color = squad_is_marching(_squad)
			? COLOR_SQUAD_MARKER_MARCH_BACKGROUND
			: COLOR_SQUAD_CARD_BACKGROUND;

		draw_set_alpha(BALANCE_SQUAD_MARKER_BACKGROUND_ALPHA);
		draw_set_color(_marker_background_color);
		draw_rectangle(_left, _top, _right, _body_bottom, false);
		draw_triangle(_left + 14, _body_bottom, _right - 14, _body_bottom, _marker_x, _bottom, false);
		draw_set_alpha(1);
		draw_set_color(COLOR_SQUAD_CARD_BORDER);
		draw_rectangle(_left, _top, _right, _body_bottom, true);
		draw_line(_left + 14, _body_bottom, _marker_x, _bottom);
		draw_line(_marker_x, _bottom, _right - 14, _body_bottom);

		var _sprite = squad_icon_sprite_get(_squad);

		if (sprite_exists(_sprite))
		{
			var _sprite_width = max(1, sprite_get_width(_sprite));
			var _sprite_height = max(1, sprite_get_height(_sprite));
			var _sprite_scale = min(BALANCE_SQUAD_MARKER_ICON_WIDTH / _sprite_width, BALANCE_SQUAD_MARKER_ICON_HEIGHT / _sprite_height);
			var _icon_center_x = _marker_x;
			var _icon_center_y = _top + 22;
			var _sprite_x = _icon_center_x + ((sprite_get_xoffset(_sprite) - (_sprite_width * 0.5)) * _sprite_scale);
			var _sprite_y = _icon_center_y + ((sprite_get_yoffset(_sprite) - (_sprite_height * 0.5)) * _sprite_scale);
			draw_sprite_ext(_sprite, 0, _sprite_x, _sprite_y, _sprite_scale, _sprite_scale, 0, c_white, 1);
		}

		var _hp_values = squad_total_hp_get(_squad);
		var _hp_progress = clamp(_hp_values[0] / max(1, _hp_values[1]), 0, 1);
		var _hp_left = _marker_x - (BALANCE_SQUAD_MARKER_HP_WIDTH * 0.5);
		var _hp_top = _top + 45;
		draw_set_color(COLOR_SQUAD_HP_BACKGROUND);
		draw_rectangle(_hp_left, _hp_top, _hp_left + BALANCE_SQUAD_MARKER_HP_WIDTH, _hp_top + BALANCE_SQUAD_MARKER_HP_HEIGHT, false);
		draw_set_color(COLOR_SQUAD_HP_BORDER);
		draw_rectangle(_hp_left, _hp_top, _hp_left + BALANCE_SQUAD_MARKER_HP_WIDTH, _hp_top + BALANCE_SQUAD_MARKER_HP_HEIGHT, true);
		draw_set_color(COLOR_SQUAD_HP_FILL);
		draw_rectangle(_hp_left + 2, _hp_top + 2, _hp_left + 2 + ((BALANCE_SQUAD_MARKER_HP_WIDTH - 4) * _hp_progress), _hp_top + BALANCE_SQUAD_MARKER_HP_HEIGHT - 2, false);
	}

	draw_set_color(c_white);
	draw_set_alpha(1);
}

function squad_unit_reference_replace(_old_unit, _new_unit)
{
	if (!instance_exists(_old_unit) || !variable_instance_exists(_old_unit, "squad") || !is_struct(_old_unit.squad)) return;

	var _squad = _old_unit.squad;
	var _unit_index = variable_instance_exists(_old_unit, "squad_unit_index") ? _old_unit.squad_unit_index : 0;
	var _previous_unit_max_hp = _old_unit.max_hp;
	_new_unit.squad = _squad;
	_new_unit.squad_unit_index = _unit_index;
	foundry_unit_permanent_bonuses_apply(_new_unit);
	_new_unit.foundry_permanent_bonuses_pending = false;

	_squad.units[_unit_index] = _new_unit;
	_squad.total_max_hp += _new_unit.max_hp - _previous_unit_max_hp;
}

function squad_day_group_update()
{
	if (global.day_phase != DAY_PHASE.DAY || !instance_exists(o_cannon)) return;

	var _cannon = instance_find(o_cannon, 0);

	for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
	{
		var _squad = global.squads[_squad_index];
		var _group_angle = 210 + (_squad_index * 34);
		var _group_x = _cannon.x + lengthdir_x(260, _group_angle);
		var _group_y = _cannon.y + lengthdir_y(170, _group_angle);

		for (var _unit_index = 0; _unit_index < array_length(_squad.units); ++_unit_index)
		{
			var _unit = _squad.units[_unit_index];
			if (!instance_exists(_unit) || _unit.object_index == o_archdemon) continue;
			var _unit_angle = (_unit_index * 137.5) mod 360;
			var _target_x = _group_x + lengthdir_x(35, _unit_angle);
			var _target_y = _group_y + lengthdir_y(24, _unit_angle);

			if (point_distance(_unit.x, _unit.y, _target_x, _target_y) > 80)
			{
				_unit.regroup_target_x = _target_x;
				_unit.regroup_target_y = _target_y;
				_unit.regroup_arrive_radius = 26;
				_unit.regroup_is_active = true;
			}
		}
	}
}

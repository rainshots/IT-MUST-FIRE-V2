/// @description Creates and manages persistent player squads.

function squad_constructor(_squad_type, _primary_unit_object, _unit_count) constructor
{
	squad_type = _squad_type;
	primary_unit_object = _primary_unit_object;
	unit_objects = array_create(max(1, floor(_unit_count)), _primary_unit_object);
	units = [];
	properties = {};
	name = "";
	total_max_hp = 0;
};

function squad_type_limit_get(_squad_type)
{
	return global.squad_limits[_squad_type];
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

function squad_name_create(_primary_unit_object)
{
	var _base_name = object_get_name(_primary_unit_object);

	if (_primary_unit_object == o_skeleton) _base_name = "Skeletons";
	else if (_primary_unit_object == o_pitling) _base_name = "Pitlings";
	else if (_primary_unit_object == o_archdemon) _base_name = "Archdemon";

	var _matching_name_count = 0;

	for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
	{
		var _existing_name = global.squads[_squad_index].name;

		if (_existing_name == _base_name || string_pos(_base_name + " ", _existing_name) == 1)
		{
			_matching_name_count++;
		}
	}

	return _matching_name_count == 0 ? _base_name : _base_name + " " + string(_matching_name_count + 1);
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

	if (variable_struct_exists(_squad.properties, "blood_warpaint_active")
		&& _squad.properties.blood_warpaint_active)
	{
		_unit.max_hp *= BALANCE_BLOOD_WARPAINT_MAX_HP_MULTIPLIER;
	}

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

function squad_register_existing_unit(_squad_type, _unit)
{
	if (!instance_exists(_unit) || !squad_slot_is_available(_squad_type)) return noone;

	var _squad = new squad_constructor(_squad_type, _unit.object_index, 1);
	_squad.name = variable_instance_exists(_unit, "cultist_name") ? _unit.cultist_name : squad_name_create(_unit.object_index);
	_squad.units = [_unit];
	_squad.total_max_hp = _unit.max_hp;
	_unit.squad = _squad;
	_unit.squad_unit_index = 0;
	array_push(global.squads, _squad);
	return _squad;
}

function squad_units_restore_morning()
{
	for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
	{
		var _squad = global.squads[_squad_index];
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
	var _max_hp = _squad.total_max_hp;

	for (var _unit_index = 0; _unit_index < array_length(_squad.units); ++_unit_index)
	{
		var _unit = _squad.units[_unit_index];
		if (!instance_exists(_unit)) continue;
		_hp += max(0, _unit.hp);
	}

	return [_hp, max(1, _max_hp)];
}

function squad_marker_position_update(_squad)
{
	if (variable_struct_exists(_squad.properties, "marker_is_dragged")
		&& _squad.properties.marker_is_dragged)
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

function squad_night_markers_update()
{
	if (global.day_phase != DAY_PHASE.NIGHT)
	{
		return;
	}

	for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
	{
		var _squad = global.squads[_squad_index];

		if (_squad.squad_type != SQUAD_TYPE.ARCHDEMON)
		{
			squad_marker_position_update(_squad);
		}
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

		if (_squad.squad_type == SQUAD_TYPE.ARCHDEMON
			|| !variable_struct_exists(_squad.properties, "marker_x")
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
	if (!is_struct(_squad) || _squad.squad_type == SQUAD_TYPE.ARCHDEMON)
	{
		return false;
	}

	_squad.properties.marker_is_dragged = true;
	global.dragged_squad = _squad;

	for (var _unit_index = 0; _unit_index < array_length(_squad.units); ++_unit_index)
	{
		var _unit = _squad.units[_unit_index];

		if (instance_exists(_unit))
		{
			_unit.is_being_dragged = true;
		}
	}

	return true;
}

function squad_drag_update(_squad, _target_x, _target_y)
{
	if (!is_struct(_squad))
	{
		return false;
	}

	var _boundary_unit = noone;

	for (var _boundary_unit_index = 0; _boundary_unit_index < array_length(_squad.units); ++_boundary_unit_index)
	{
		if (instance_exists(_squad.units[_boundary_unit_index]))
		{
			_boundary_unit = _squad.units[_boundary_unit_index];
			break;
		}
	}

	if (instance_exists(_boundary_unit) && unit_is_blocked_by_cannon_wall(_boundary_unit))
	{
		var _clamped_position = cannon_wall_position_clamp(_target_x, _target_y);
		_target_x = _clamped_position[0];
		_target_y = _clamped_position[1];
	}

	if (!world_position_is_revealed_by_fog(_target_x, _target_y))
	{
		_target_x = _squad.properties.marker_x;
		_target_y = _squad.properties.marker_y;
	}

	_squad.properties.marker_x = _target_x;
	_squad.properties.marker_y = _target_y;
	var _unit_count = array_length(_squad.units);

	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		var _unit = _squad.units[_unit_index];

		if (!instance_exists(_unit))
		{
			continue;
		}

		var _formation_angle = (_unit_index * 137.5) mod 360;
		var _formation_radius = BALANCE_SQUAD_MARKER_GATHER_RADIUS * sqrt((_unit_index + 1) / max(1, _unit_count));
		var _unit_target_x = _target_x + lengthdir_x(_formation_radius, _formation_angle);
		var _unit_target_y = _target_y + lengthdir_y(_formation_radius, _formation_angle);
		var _unit_distance = point_distance(_unit.x, _unit.y, _unit_target_x, _unit_target_y);
		var _move_distance = min(BALANCE_SQUAD_MARKER_GATHER_SPEED, _unit_distance);

		if (_move_distance > 0)
		{
			var _move_direction = point_direction(_unit.x, _unit.y, _unit_target_x, _unit_target_y);
			_unit.x += lengthdir_x(_move_distance, _move_direction);
			_unit.y += lengthdir_y(_move_distance, _move_direction);
		}

		_unit.drag_drop_x = _unit.x;
		_unit.drag_drop_y = _unit.y;
	}

	return true;
}

function squad_drag_end(_squad, _apply_stun = true)
{
	if (!is_struct(_squad))
	{
		global.dragged_squad = noone;
		return false;
	}

	_squad.properties.marker_is_dragged = false;

	for (var _unit_index = 0; _unit_index < array_length(_squad.units); ++_unit_index)
	{
		var _unit = _squad.units[_unit_index];

		if (!instance_exists(_unit))
		{
			continue;
		}

		_unit.is_being_dragged = false;

		if (_apply_stun && variable_instance_exists(_unit, "stun_apply"))
		{
			_unit.stun_apply(BALANCE_DEMON_DRAG_STUN_TIME);
		}
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

		if (_squad.squad_type == SQUAD_TYPE.ARCHDEMON || !squad_marker_position_update(_squad))
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

		draw_set_alpha(BALANCE_SQUAD_MARKER_BACKGROUND_ALPHA);
		draw_set_color(COLOR_SQUAD_CARD_BACKGROUND);
		draw_rectangle(_left, _top, _right, _body_bottom, false);
		draw_triangle(_left + 14, _body_bottom, _right - 14, _body_bottom, _marker_x, _bottom, false);
		draw_set_alpha(1);
		draw_set_color(COLOR_SQUAD_CARD_BORDER);
		draw_rectangle(_left, _top, _right, _body_bottom, true);
		draw_line(_left + 14, _body_bottom, _marker_x, _bottom);
		draw_line(_marker_x, _bottom, _right - 14, _body_bottom);

		var _primary_unit = noone;

		for (var _unit_index = 0; _unit_index < array_length(_squad.units); ++_unit_index)
		{
			if (instance_exists(_squad.units[_unit_index]))
			{
				_primary_unit = _squad.units[_unit_index];
				break;
			}
		}

		if (instance_exists(_primary_unit) && sprite_exists(_primary_unit.sprite_index))
		{
			var _sprite = _primary_unit.sprite_index;
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

	if (variable_struct_exists(_squad.properties, "blood_warpaint_active")
		&& _squad.properties.blood_warpaint_active)
	{
		var _new_unit_base_max_hp = _new_unit.max_hp;
		_new_unit.max_hp *= BALANCE_BLOOD_WARPAINT_MAX_HP_MULTIPLIER;
		_new_unit.hp = min(_new_unit.max_hp, _new_unit.hp + (_new_unit.max_hp - _new_unit_base_max_hp));
	}

	_squad.units[_unit_index] = _new_unit;
	_squad.total_max_hp += _new_unit.max_hp - _previous_unit_max_hp;
}

function squad_blood_warpaint_start_night()
{
	if (!global.squad_blood_warpaint_pending)
	{
		return false;
	}

	global.squad_blood_warpaint_pending = false;

	for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
	{
		var _squad = global.squads[_squad_index];
		_squad.properties.blood_warpaint_active = true;
		_squad.total_max_hp *= BALANCE_BLOOD_WARPAINT_MAX_HP_MULTIPLIER;

		for (var _unit_index = 0; _unit_index < array_length(_squad.units); ++_unit_index)
		{
			var _unit = _squad.units[_unit_index];

			if (!instance_exists(_unit))
			{
				continue;
			}

			var _previous_max_hp = _unit.max_hp;
			_unit.max_hp *= BALANCE_BLOOD_WARPAINT_MAX_HP_MULTIPLIER;
			_unit.hp = min(_unit.max_hp, _unit.hp + (_unit.max_hp - _previous_max_hp));
		}
	}

	return true;
}

function squad_blood_warpaint_end_night()
{
	for (var _squad_index = 0; _squad_index < array_length(global.squads); ++_squad_index)
	{
		var _squad = global.squads[_squad_index];

		if (!variable_struct_exists(_squad.properties, "blood_warpaint_active")
			|| !_squad.properties.blood_warpaint_active)
		{
			continue;
		}

		_squad.properties.blood_warpaint_active = false;
		_squad.total_max_hp /= BALANCE_BLOOD_WARPAINT_MAX_HP_MULTIPLIER;

		for (var _unit_index = 0; _unit_index < array_length(_squad.units); ++_unit_index)
		{
			var _unit = _squad.units[_unit_index];

			if (!instance_exists(_unit))
			{
				continue;
			}

			_unit.max_hp /= BALANCE_BLOOD_WARPAINT_MAX_HP_MULTIPLIER;
			_unit.hp = min(_unit.hp, _unit.max_hp);
		}
	}
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

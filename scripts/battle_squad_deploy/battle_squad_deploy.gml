/// @description Fires a reserve squad into position or immediately moves an already landed squad.
function battle_squad_deploy(_controller, _squad, _positions)
{
	if (!battle_deployment_is_valid(_controller, _squad, _positions)) return false;
	var _already_deployed = _squad.properties.battle_deployed;
	var _projectile = _squad.properties.battle_deployment_projectile;
	if (_already_deployed && !instance_exists(_projectile))
	{
		return battle_squad_place(_squad, _positions);
	}

	var _cannon = instance_find(o_cannon, 0);
	if (!instance_exists(_cannon)) return false;

	// The reserved formation determines both the flag and the shell's impact point.
	var _center_x = 0;
	var _center_y = 0;
	var _position_count = array_length(_positions);
	for (var _index = 0; _index < _position_count; ++_index)
	{
		_center_x += _positions[_index].x;
		_center_y += _positions[_index].y;
	}
	_center_x /= _position_count;
	_center_y /= _position_count;
	_squad.properties.marker_x = _center_x;
	_squad.properties.marker_y = _center_y;

	// Moving a squad that is still airborne redirects its existing shell without firing again.
	if (instance_exists(_projectile))
	{
		_projectile.target_x = _center_x;
		_projectile.target_y = _center_y;
		_projectile.battle_deployment_positions = _positions;
		return true;
	}

	// Reuse the normal cannon shell's arc, smoke and explosion without consuming preparation ammo.
	var _start_x = _cannon.x;
	var _start_y = _cannon.y + _cannon.projectile_spawn_offset_y;
	_projectile = instance_create_layer(_start_x, _start_y, _cannon.projectile_layer_name, o_projectile);
	_projectile.target_x = _center_x;
	_projectile.target_y = _center_y;
	_projectile.projectile_type = PROJECTILE_TYPE.CULTIST;
	_projectile.source_instance = _cannon;
	_projectile.smoke_trail_enabled = true;
	_projectile.effect_radius = BALANCE_CULTIST_PROJECTILE_EFFECT_RADIUS;
	_projectile.damage_amount = 0;
	_projectile.ground_corruption_amount = 0;
	_projectile.ground_corruption_radius = 0;
	_projectile.battle_deployment_squad = _squad;
	_projectile.battle_deployment_positions = _positions;
	_projectile.flight_time = clamp(point_distance(_start_x, _start_y, _center_x, _center_y)
		/ _projectile.projectile_speed, _projectile.minimum_flight_time, _projectile.maximum_flight_time) * room_speed;
	_projectile.depth = -room_height;

	// Reserve a deployment slot immediately; actual units are created only when the shell lands.
	_squad.properties.battle_deployment_projectile = _projectile;
	_squad.properties.battle_deployed = true;
	_controller.battle_deployed_count++;
	global.sound_play_random(global.cannon_shot_sounds);
	if (instance_exists(o_camera_controller))
	{
		var _camera_controller = instance_find(o_camera_controller, 0);
		_camera_controller.camera_shake_start(BALANCE_CANNON_SHOT_SHAKE_TIME, BALANCE_CANNON_SHOT_SHAKE_STRENGTH);
	}
	return true;
}

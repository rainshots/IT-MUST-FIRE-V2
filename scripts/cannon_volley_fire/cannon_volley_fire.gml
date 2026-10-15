/// @description Launches every loaded object around the selected point within charge-scaled range; controller context.
function cannon_volley_fire(_x, _y)
{
	if (global.pause || fight_state != FIGHT_STATE.ACTIVE || !instance_exists(o_cannon)
		|| fight_charge < BALANCE_CARGO_MIN_CHARGE || cargo_capacity_used() <= 0) return false;
	var _range = cannon_range_get();
	if (point_distance(o_cannon.x, o_cannon.y, _x, _y) > _range) return false;
	for (var _i = 0; _i < array_length(cargo_contents); ++_i)
	{
		var _flight = instance_create_layer(o_cannon.x, o_cannon.y, "Instances", o_cargo_flight);
		_flight.payload = cargo_contents[_i];
		// Sample uniformly inside the target disk; keep impacts inside the room and firing range.
		var _angle = random(360);
		var _radius = sqrt(random(1)) * BALANCE_CANNON_TARGET_RADIUS;
		var _landing_x = clamp(_x + lengthdir_x(_radius, _angle), 0, room_width);
		var _landing_y = clamp(_y + lengthdir_y(_radius, _angle), 0, room_height);
		var _distance = point_distance(o_cannon.x, o_cannon.y, _landing_x, _landing_y);
		if (_distance > _range)
		{
			var _direction = point_direction(o_cannon.x, o_cannon.y, _landing_x, _landing_y);
			_landing_x = o_cannon.x + lengthdir_x(_range, _direction);
			_landing_y = o_cannon.y + lengthdir_y(_range, _direction);
		}
		_flight.landing_x = _landing_x;
		_flight.landing_y = _landing_y;
	}
	cargo_contents = [];
	fight_charge = 0;
	cannon_aiming = false;
	return true;
}

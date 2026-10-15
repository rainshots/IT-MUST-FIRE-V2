if (global.pause) exit;
flight_seconds += global.gameplay_time_scale / max(1, room_speed);
var _progress = clamp(flight_seconds / BALANCE_CANNON_FLIGHT_SECONDS, 0, 1);
x = lerp(start_x, landing_x, _progress);
y = lerp(start_y, landing_y, _progress) - sin(pi * _progress) * BALANCE_CANNON_FLIGHT_ARC;
if (_progress >= 1)
{
	cargo_land(payload, landing_x, landing_y);
	instance_destroy();
}

if (global.pause) exit;
if (!instance_exists(o_game_controller) || o_game_controller.fight_state != FIGHT_STATE.ACTIVE)
{
	instance_destroy();
	exit;
}
flight_seconds += global.gameplay_time_scale / max(1, room_speed);
var _progress = clamp(flight_seconds / flight_duration, 0, 1);
x = lerp(start_x, landing_x, _progress);
y = lerp(start_y, landing_y, _progress) - sin(_progress * pi) * BALANCE_CANNON_FLIGHT_ARC;
if (_progress >= 1)
{
	cannonball_impact(ball_type, landing_x, landing_y);
	instance_destroy();
}

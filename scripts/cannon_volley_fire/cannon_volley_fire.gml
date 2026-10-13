/// @description Fires the entire loaded queue into a uniform 150px disk; controller context.
function cannon_volley_fire(_x, _y)
{
	if (global.pause || fight_state != FIGHT_STATE.ACTIVE || !instance_exists(o_cannon)
		|| fight_charge < BALANCE_FIGHT_CHARGE_MAX || array_length(cannon_ammo) == 0) return false;
	for (var _index = 0; _index < array_length(cannon_ammo); ++_index)
	{
		var _angle = random(360);
		var _radius = sqrt(random(1)) * BALANCE_CANNON_TARGET_RADIUS;
		var _ball = instance_create_layer(o_cannon.x, o_cannon.y, "Instances", o_cannonball);
		_ball.ball_type = cannon_ammo[_index];
		_ball.landing_x = _x + lengthdir_x(_radius, _angle);
		_ball.landing_y = _y + lengthdir_y(_radius, _angle);
	}
	cannon_ammo = [];
	fight_charge = 0;
	cannon_aiming = false;
	return true;
}

if (global.pause || !is_recovering) exit;
var _seconds = global.gameplay_time_scale / max(1, room_speed);
hp = min(max_hp, hp + max_hp * _seconds / recovery_seconds);
recovery_smoke_timer -= _seconds;
if (recovery_smoke_timer <= 0)
{
	recovery_smoke_timer = BALANCE_NEUTRAL_BUILDING_SMOKE_SECONDS;
	instance_create_layer(x + random_range(-20, 20), y - 32, "Instances", o_particle_smoke);
}
if (hp >= max_hp)
{
	hp = max_hp;
	is_recovering = false;
	favor_defeat_awarded = false;
	is_attackable = true;
}

// Run shared movement and combat first.
event_inherited();

if (global.pause || hp <= 0)
{
	exit;
}

// Bloody clones are temporary and fade near the end of their life.
life_timer--;

if (life_timer <= 0)
{
	instance_destroy();
	exit;
}

var _fade_time = max(1, BALANCE_IMP_BLOODY_CLONE_LIFE_TIME * room_speed * clone_fade_start_share);

if (life_timer < _fade_time)
{
	image_alpha = clamp(life_timer / _fade_time, 0, 0.72);
}

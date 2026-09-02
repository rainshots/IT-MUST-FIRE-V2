// Run shared movement and combat first.
event_inherited();

if (unholy_savage_leap_active || global.pause)
{
	exit;
}

if (hp <= 0)
{
	if (variable_instance_exists(id, "unit_death_sound_play"))
	{
		unit_death_sound_play();
	}

	clone_blood_explosion();
	instance_destroy();
	exit;
}

imp_clone_owner_follow_update();

// Bloody clones are temporary and fade near the end of their life.
var _time_scale = variable_global_exists("gameplay_time_scale") ? global.gameplay_time_scale : 1;
life_timer -= _time_scale;

if (life_timer <= 0)
{
	clone_blood_explosion();
	instance_destroy();
	exit;
}

var _fade_time = max(1, clone_max_life_timer * clone_fade_start_share);

if (life_timer < _fade_time)
{
	image_alpha = clamp(life_timer / _fade_time, 0, 0.72);
}

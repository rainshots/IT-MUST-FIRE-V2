// Run shared movement and combat first.
event_inherited();

if (global.pause)
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

// Bloody clones are temporary and fade near the end of their life.
life_timer--;

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

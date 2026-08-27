// The Jobs interface owns this hidden world instance and draws its sprite in GUI space.
is_held = false;
cultist_damage = BALANCE_JOBS_WHIP_CULTIST_DAMAGE;
satisfaction_gain = BALANCE_JOBS_WHIP_SATISFACTION_GAIN;
image_speed = 0;

whip_pick_up = function()
{
	is_held = true;
};

whip_release = function()
{
	is_held = false;
};

whip_cultist_is_valid = function(_cultist)
{
	return instance_exists(_cultist)
		&& _cultist.object_index == o_cultist
		&& variable_instance_exists(_cultist, "hp")
		&& _cultist.hp > 0
		&& (!variable_instance_exists(_cultist, "is_unconscious") || !_cultist.is_unconscious);
};

whip_cultist_hit = function(_cultist)
{
	if (!is_held || !whip_cultist_is_valid(_cultist))
	{
		return false;
	}

	var _damage_dealt = day_event_cultist_damage_apply(_cultist, cultist_damage);

	if (_damage_dealt <= 0)
	{
		return false;
	}

	cannon_satisfaction_add(satisfaction_gain);

	// Reuse the existing whip audio and blood feedback in the world behind the interface.
	if (variable_global_exists("sound_play_random")
		&& variable_global_exists("whip_sounds"))
	{
		global.sound_play_random(global.whip_sounds);
	}

	blood_particles_create(_cultist.x, _cultist.y);
	return true;
};

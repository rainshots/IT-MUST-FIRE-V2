// Run shared movement and combat first.
event_inherited();

if (global.pause || hp <= 0)
{
	exit;
}

if (is_being_dragged || is_stunned)
{
	exit;
}

if (raise_lesser_demon_line_timer > 0)
{
	raise_lesser_demon_line_timer--;
}

if (hex_totem_line_timer > 0)
{
	hex_totem_line_timer--;
}

// Passive abilities update their lightweight visuals and effects.
warlock_demonic_infusion_update();
warlock_soul_engine_update();
warlock_familiar_update();

// Soul Chain visuals and active links are owned by the Warlock that created them.
warlock_soul_chain_groups_update();

if (demon_active_abilities_are_blocked())
{
	exit;
}

// Use only the active abilities this Warlock currently owns.
if (raise_lesser_demon_timer > 0)
{
	raise_lesser_demon_timer--;
}

if (raise_lesser_demon_retry_timer > 0)
{
	raise_lesser_demon_retry_timer--;
}

if (cultist_active_ability_has(id, DEMON_ABILITY.WARLOCK_RAISE_LESSER_DEMON)
	&& raise_lesser_demon_timer <= 0
	&& raise_lesser_demon_retry_timer <= 0)
{
	if (warlock_raise_lesser_demon_use())
	{
		raise_lesser_demon_timer = ability_cooldown_time_get(raise_lesser_demon_cooldown);
	}
	else
	{
		raise_lesser_demon_retry_timer = BALANCE_ABILITY_FAILED_RETRY_TIME * room_speed;
	}
}

if (soul_chain_cooldown_timer > 0)
{
	soul_chain_cooldown_timer--;
}

if (soul_chain_retry_timer > 0)
{
	soul_chain_retry_timer--;
}

if (cultist_active_ability_has(id, DEMON_ABILITY.WARLOCK_SOUL_CHAIN)
	&& soul_chain_cooldown_timer <= 0
	&& soul_chain_retry_timer <= 0)
{
	if (warlock_soul_chain_use())
	{
		soul_chain_cooldown_timer = ability_cooldown_time_get(soul_chain_cooldown);
	}
	else
	{
		soul_chain_retry_timer = BALANCE_ABILITY_FAILED_RETRY_TIME * room_speed;
	}
}

if (hex_totem_timer > 0)
{
	hex_totem_timer--;
}

if (hex_totem_retry_timer > 0)
{
	hex_totem_retry_timer--;
}

if (cultist_active_ability_has(id, DEMON_ABILITY.WARLOCK_HEX_TOTEM)
	&& hex_totem_timer <= 0
	&& hex_totem_retry_timer <= 0)
{
	if (warlock_hex_totem_use())
	{
		hex_totem_timer = ability_cooldown_time_get(hex_totem_cooldown);
	}
	else
	{
		hex_totem_retry_timer = BALANCE_ABILITY_FAILED_RETRY_TIME * room_speed;
	}
}

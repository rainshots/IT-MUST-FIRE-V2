// Run shared movement, combat, and Corpse Eater first.
event_inherited();

if (global.pause || hp <= 0)
{
	exit;
}

if (is_being_dragged || is_stunned)
{
	exit;
}

// Active ability visuals and pulls keep updating while the Brute can act.
brute_hook_update();

if (grave_slam_circle_timer > 0)
{
	grave_slam_circle_timer--;
}

if (meat_explosion_circle_timer > 0)
{
	meat_explosion_circle_timer--;
}

// Rotten Aura constantly leaks magic damage into nearby enemies.
if (has_brute_rotten_aura && BALANCE_BRUTE_ROTTEN_AURA_ENABLED)
{
	rotten_aura_tick_timer--;

	if (rotten_aura_tick_timer <= 0)
	{
		var _enemy_list = ds_list_create();
		var _enemy_count = collision_circle_list(x, y, rotten_aura_radius, o_enemy_units, false, true, _enemy_list, false);
		var _base_aura_damage = BALANCE_BRUTE_ROTTEN_AURA_DAMAGE * magic_effectiveness;

		for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
		{
			var _enemy = _enemy_list[| _enemy_index];

			if (!target_can_be_attacked(_enemy) || !variable_instance_exists(_enemy, "hp"))
			{
				continue;
			}

			var _aura_damage = _base_aura_damage;

			if (variable_instance_exists(_enemy, "status_effect_has") && _enemy.status_effect_has(STATUS_EFFECT.CURSE))
			{
				_aura_damage *= BALANCE_BRUTE_ROTTEN_AURA_CURSE_MULTIPLIER;
			}

			if (variable_instance_exists(_enemy, "unit_damage_receive"))
			{
				_enemy.unit_damage_receive(_aura_damage, unit_faction);
			}
			else
			{
				_enemy.hp = max(_enemy.hp - _aura_damage, 0);
				damage_popup_create(_enemy.x, _enemy.y, _aura_damage, _enemy.unit_faction);
			}
		}

		ds_list_destroy(_enemy_list);
		rotten_aura_tick_timer = BALANCE_BRUTE_ROTTEN_AURA_TICK_TIME * room_speed;
	}
}

// Rotten Aura also emits green smoke across its radius.
if (has_brute_rotten_aura)
{
	brute_rotten_aura_particles_update();
}

// Use only the active ability this Brute currently owns.
if (grave_slam_timer > 0)
{
	grave_slam_timer--;
}

if (grave_slam_retry_timer > 0)
{
	grave_slam_retry_timer--;
}

if (cultist_active_ability_has(id, DEMON_ABILITY.BRUTE_GRAVE_SLAM)
	&& grave_slam_timer <= 0
	&& grave_slam_retry_timer <= 0)
{
	if (brute_grave_slam_use())
	{
		grave_slam_timer = ability_cooldown_time_get(grave_slam_cooldown);
	}
	else
	{
		grave_slam_retry_timer = BALANCE_ABILITY_FAILED_RETRY_TIME * room_speed;
	}
}

if (meat_hook_timer > 0)
{
	meat_hook_timer--;
}

if (meat_hook_retry_timer > 0)
{
	meat_hook_retry_timer--;
}

if (cultist_active_ability_has(id, DEMON_ABILITY.BRUTE_MEAT_HOOK)
	&& meat_hook_timer <= 0
	&& meat_hook_retry_timer <= 0
	&& !instance_exists(hook_target))
{
	if (brute_hook_start())
	{
		meat_hook_timer = ability_cooldown_time_get(meat_hook_cooldown);
	}
	else
	{
		meat_hook_retry_timer = BALANCE_ABILITY_FAILED_RETRY_TIME * room_speed;
	}
}

if (devour_timer > 0)
{
	devour_timer--;
}

if (devour_retry_timer > 0)
{
	devour_retry_timer--;
}

if (cultist_active_ability_has(id, DEMON_ABILITY.BRUTE_DEVOUR)
	&& devour_timer <= 0
	&& devour_retry_timer <= 0)
{
	if (brute_devour_use())
	{
		devour_timer = ability_cooldown_time_get(devour_cooldown);
	}
	else
	{
		devour_retry_timer = BALANCE_ABILITY_FAILED_RETRY_TIME * room_speed;
	}
}

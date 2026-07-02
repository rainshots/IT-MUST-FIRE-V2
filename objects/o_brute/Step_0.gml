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

// Level 4 Grave Slam spike visuals fade out independently.
for (var _spike_index = array_length(grave_slam_spike_visuals) - 1; _spike_index >= 0; --_spike_index)
{
	var _spike = grave_slam_spike_visuals[_spike_index];
	_spike.timer--;

	if (_spike.timer <= 0)
	{
		array_delete(grave_slam_spike_visuals, _spike_index, 1);
	}
	else
	{
		grave_slam_spike_visuals[_spike_index] = _spike;
	}
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
		var _aura_level = brute_ability_level_get(DEMON_ABILITY.BRUTE_ROTTEN_AURA);
		var _aura_radius = brute_rotten_aura_radius_get();
		var _enemy_list = ds_list_create();
		var _enemy_count = collision_circle_list(x, y, _aura_radius, o_enemy_units, false, true, _enemy_list, false);
		var _base_aura_damage = BALANCE_BRUTE_ROTTEN_AURA_DAMAGE * magic_effectiveness;

		for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
		{
			var _enemy = _enemy_list[| _enemy_index];

			if (!target_can_be_attacked(_enemy) || !variable_instance_exists(_enemy, "hp"))
			{
				continue;
			}

			var _aura_damage = magic_damage_after_resistance(_base_aura_damage, _enemy);

			if (variable_instance_exists(_enemy, "unit_damage_receive"))
			{
				_enemy.unit_damage_receive(_aura_damage, unit_faction, false, true, id);
			}
			else
			{
				_enemy.hp = max(_enemy.hp - _aura_damage, 0);
				damage_popup_create(_enemy.x, _enemy.y, _aura_damage, _enemy.unit_faction);
			}

			if (_aura_level >= 3 && variable_instance_exists(_enemy, "status_effect_apply"))
			{
				_enemy.status_effect_apply(
					STATUS_EFFECT.FEAR,
					BALANCE_BRUTE_ROTTEN_AURA_FEAR_REFRESH_TIME,
					BALANCE_BRUTE_ROTTEN_AURA_FEAR_MOVE_SLOW,
					BALANCE_BRUTE_ROTTEN_AURA_FEAR_ATTACK_SLOW,
					0,
					unit_faction
				);
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

if (butcher_chains_timer > 0)
{
	butcher_chains_timer--;
}

if (butcher_chains_retry_timer > 0)
{
	butcher_chains_retry_timer--;
}

if (cultist_active_ability_has(id, DEMON_ABILITY.BRUTE_BUTCHER_CHAINS)
	&& butcher_chains_timer <= 0
	&& butcher_chains_retry_timer <= 0
	&& array_length(hook_targets) <= 0)
{
	if (brute_chains_wave_start(false))
	{
		butcher_chains_timer = ability_cooldown_time_get(butcher_chains_cooldown);
	}
	else
	{
		butcher_chains_retry_timer = BALANCE_ABILITY_FAILED_RETRY_TIME * room_speed;
	}
}

if (corpse_armor_ability_timer > 0)
{
	corpse_armor_ability_timer--;
}

if (corpse_armor_retry_timer > 0)
{
	corpse_armor_retry_timer--;
}

if (cultist_active_ability_has(id, DEMON_ABILITY.BRUTE_CORPSE_ARMOR)
	&& corpse_armor_ability_timer <= 0
	&& corpse_armor_retry_timer <= 0)
{
	if (brute_corpse_armor_use())
	{
		corpse_armor_ability_timer = ability_cooldown_time_get(corpse_armor_cooldown);
	}
	else
	{
		corpse_armor_retry_timer = BALANCE_ABILITY_FAILED_RETRY_TIME * room_speed;
	}
}

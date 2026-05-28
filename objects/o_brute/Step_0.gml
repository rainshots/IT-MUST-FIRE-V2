// Run shared movement and combat first.
event_inherited();

if (global.pause || hp <= 0)
{
	exit;
}

if (is_being_dragged)
{
	exit;
}

// Poison aura deals periodic magic damage around the brute.
if (demon_ability == DEMON_ABILITY.BRUTE_POISON_AURA)
{
	poison_tick_timer--;

	if (poison_tick_timer <= 0)
	{
		ability_popup_create(x, y, demon_ability);

		var _enemy_list = ds_list_create();
		var _enemy_count = collision_circle_list(x, y, poison_aura_radius, o_enemy_units, false, true, _enemy_list, false);
		var _poison_damage = max(BALANCE_ABILITY_BRUTE_POISON_DAMAGE_MIN, magic_effectiveness);

		for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
		{
			var _enemy = _enemy_list[| _enemy_index];

			if (instance_exists(_enemy) && variable_instance_exists(_enemy, "hp"))
			{
				_enemy.hp = max(_enemy.hp - _poison_damage, 0);
				damage_popup_create(_enemy.x, _enemy.y, _poison_damage, _enemy.unit_faction);
			}
		}

		ds_list_destroy(_enemy_list);
		poison_tick_timer = BALANCE_ABILITY_BRUTE_POISON_TICK_TIME * room_speed;
	}
}
else if (demon_ability == DEMON_ABILITY.BRUTE_MEGA_STRIKE)
{
	ability_timer--;

	if (ability_timer <= 0)
	{
		mega_strike_ready = true;
		next_attack_damage_multiplier = BALANCE_ABILITY_BRUTE_MEGA_STRIKE_DAMAGE_MULTIPLIER;
		next_attack_radius_multiplier = BALANCE_ABILITY_BRUTE_MEGA_STRIKE_AOE_MULTIPLIER;
		ability_timer = max(ability_cooldown / abilities_cd_spd, 1);
		ability_popup_create(x, y, demon_ability);
	}
}

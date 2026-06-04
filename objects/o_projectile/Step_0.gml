// Move the projectile along a simple artillery arc.
if (global.pause)
{
	exit;
}

// Delay launch so volley projectiles land with slight timing differences.
if (launch_delay_timer > 0)
{
	launch_delay_timer--;
	exit;
}

flight_timer++;

var _flight_progress = clamp(flight_timer / flight_time, 0, 1);
var _arc_offset = -sin(_flight_progress * pi) * arc_height;

x = lerp(start_x, target_x, _flight_progress);
y = lerp(start_y, target_y, _flight_progress) + _arc_offset;

// Apply the projectile effect when it lands.
if (_flight_progress >= 1)
{
	// Spawn the main explosion flash at the impact point.
	instance_create_layer(target_x, target_y, particle_layer_name, o_particle_explosion);

	// Spawn smoke particles across the explosion radius.
	for (var _smoke_index = 0; _smoke_index < smoke_particle_count; ++_smoke_index)
	{
		var _smoke_direction = random(360);
		var _smoke_distance = sqrt(random(1)) * effect_radius;
		var _smoke_x = target_x + lengthdir_x(_smoke_distance, _smoke_direction);
		var _smoke_y = target_y + lengthdir_y(_smoke_distance, _smoke_direction);

		instance_create_layer(_smoke_x, _smoke_y, particle_layer_name, o_particle_smoke);
	}

	// Corruption projectiles infect ground cells in the explosion radius.
	if (projectile_type == PROJECTILE_TYPE.CORRUPTION)
	{
		corrupt_circle(target_x, target_y, effect_radius, ground_corruption_amount);
	}
	else if (projectile_type == PROJECTILE_TYPE.RALLY)
	{
		if (instance_exists(o_cannon))
		{
			var _cannon = instance_find(o_cannon, 0);
			var _nearby_units = ds_list_create();
			var _search_radius = BALANCE_PROJECTILE_RALLY_UNIT_SEARCH_RADIUS;
			var _nearby_unit_count = collision_circle_list(
				_cannon.x,
				_cannon.y,
				_search_radius,
				o_friendly_units,
				false,
				true,
				_nearby_units,
				true
			);
			var _assigned_unit_count = ceil(_nearby_unit_count * BALANCE_PROJECTILE_RALLY_UNIT_SHARE);

			if (_assigned_unit_count > 0)
			{
				global.rally_projectile_group_id++;

				for (var _unit_index = 0; _unit_index < _assigned_unit_count; ++_unit_index)
				{
					var _unit = _nearby_units[| _unit_index];

					if (instance_exists(_unit))
					{
						_unit.rally_group_id = global.rally_projectile_group_id;
						_unit.rally_target_x = target_x;
						_unit.rally_target_y = target_y;
						_unit.rally_home_x = _cannon.x;
						_unit.rally_home_y = _cannon.y;
						_unit.rally_arrive_radius = BALANCE_PROJECTILE_RALLY_ARRIVE_RADIUS;
						_unit.rally_is_active = true;
						_unit.rally_is_returning = false;
						_unit.rally_has_arrived = false;
					}
				}
			}

			ds_list_destroy(_nearby_units);
		}
	}

	if (projectile_type != PROJECTILE_TYPE.RALLY)
	{
		with (all)
		{
			var _is_valid_target = (
				id != other.id
				&& id != other.cultist_payload
				&& object_index != o_projectile
				&& object_index != o_particle_smoke
				&& object_index != o_particle_explosion
				&& object_index != o_camera_controller
				&& object_index != o_game_controller
			);

			if (_is_valid_target && point_distance(x, y, other.target_x, other.target_y) <= other.effect_radius)
			{
				if (other.projectile_type == PROJECTILE_TYPE.CULTIST)
				{
					if (variable_instance_exists(id, "health"))
					{
						health -= other.damage_amount;
					}
					else if (variable_instance_exists(id, "hp"))
					{
						if (variable_instance_exists(id, "unit_damage_receive"))
						{
							unit_damage_receive(other.damage_amount, UNIT_FACTION.NOONE);
						}
						else
						{
							hp -= other.damage_amount;

							if (variable_instance_exists(id, "unit_faction"))
							{
								damage_popup_create(x, y, other.damage_amount, unit_faction);
							}
						}
					}
				}
				else if (variable_instance_exists(id, "on_projectile_hit"))
				{
					on_projectile_hit(other.projectile_type);
				}
				else if (other.projectile_type == PROJECTILE_TYPE.DAMAGE)
				{
					if (variable_instance_exists(id, "health"))
					{
						health -= other.damage_amount;
					}
					else if (variable_instance_exists(id, "hp"))
					{
						if (variable_instance_exists(id, "unit_damage_receive"))
						{
							unit_damage_receive(other.damage_amount, UNIT_FACTION.NOONE);
						}
						else
						{
							hp -= other.damage_amount;

							if (variable_instance_exists(id, "unit_faction"))
							{
								damage_popup_create(x, y, other.damage_amount, unit_faction);
							}
						}
					}
				}
				else if (other.projectile_type == PROJECTILE_TYPE.CORRUPTION)
				{
					if (!variable_instance_exists(id, "corruption"))
					{
						corruption = 0;
					}

					corruption += other.corruption_amount;
				}
				else if (other.projectile_type == PROJECTILE_TYPE.SUMMON)
				{
					// Summon contract will be added when the target object API is agreed.
				}
			}
		}
	}

	if (projectile_type == PROJECTILE_TYPE.CULTIST && instance_exists(cultist_payload))
	{
		var _cultist = cultist_payload;
		var _demon_object = cultist_demon_object_get(_cultist.demon_type);

		if (_demon_object != noone)
		{
			var _demon = instance_create_layer(target_x, target_y, "Instances", _demon_object);
			var _cultist_hp = _cultist.hp;

			_demon.cultist_name = _cultist.cultist_name;
			_demon.cultist_points = _cultist.cultist_points;
			_demon.cultist_sprite_index = _cultist.sprite_index;

			if (variable_instance_exists(_cultist, "cultist_sprite_index"))
			{
				_demon.cultist_sprite_index = _cultist.cultist_sprite_index;
			}

			_demon.demon_type = _cultist.demon_type;
			_demon.demon_ability = _cultist.demon_ability;
			_demon.cultist_starting_abilities = _cultist.cultist_starting_abilities;

			_demon.current_exp = _cultist.current_exp;
			_demon.current_lvl = _cultist.current_lvl;
			_demon.pending_level_points = _cultist.pending_level_points;
			_demon.pending_passive_choices = _cultist.pending_passive_choices;
			_demon.pending_active_choices = _cultist.pending_active_choices;
			_demon.passive_choice_options = _cultist.passive_choice_options;
			_demon.active_choice_options = _cultist.active_choice_options;
			_demon.active_abilities = _cultist.active_abilities;
			_demon.has_imp_blood_frenzy = _cultist.has_imp_blood_frenzy;
			_demon.has_imp_hellbleed = _cultist.has_imp_hellbleed;
			_demon.has_imp_taste_of_fear = _cultist.has_imp_taste_of_fear;
			_demon.has_brute_corpse_eater = _cultist.has_brute_corpse_eater;
			_demon.has_brute_rotten_aura = _cultist.has_brute_rotten_aura;
			_demon.has_brute_cursed_flesh = _cultist.has_brute_cursed_flesh;
			_demon.has_warlock_soul_harvester = _cultist.has_warlock_soul_harvester;
			_demon.has_warlock_curseweaver = _cultist.has_warlock_curseweaver;
			_demon.has_warlock_demonic_infusion = _cultist.has_warlock_demonic_infusion;
			cultist_stats_apply(_demon);
			_demon.hp = clamp(_cultist_hp, 0, _demon.max_hp);

			if (variable_instance_exists(_demon, "ability_cooldown"))
			{
				_demon.ability_cooldown = cultist_ability_cooldown_get(_demon.demon_ability) * room_speed;
				_demon.ability_timer = _demon.ability_cooldown;
				_demon.base_reload_time = _demon.reload_time;
			}

			var _cultist_count = array_length(global.cultists);

			for (var _cultist_index = 0; _cultist_index < _cultist_count; ++_cultist_index)
			{
				if (global.cultists[_cultist_index] == _cultist)
				{
					global.cultists[_cultist_index] = _demon;
					break;
				}
			}
		}

		instance_destroy(_cultist);
	}

	instance_destroy();
}

// Move the projectile along a simple artillery arc.
if (global.pause && !ignore_pause)
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
	// Play a random impact sound for any landed projectile.
	if (variable_global_exists("explosion_sounds") && variable_global_exists("sound_play_random"))
	{
		global.sound_play_random(global.explosion_sounds);
	}

	// Spawn the main explosion flash at the impact point.
	instance_create_layer(target_x, target_y, particle_layer_name, o_particle_explosion);

	// Structure shells land with extra weight, even before the building appears.
	if (projectile_type == PROJECTILE_TYPE.BUILDING_SHELL && instance_exists(o_camera_controller))
	{
		var _camera_controller = instance_find(o_camera_controller, 0);

		if (variable_instance_exists(_camera_controller, "camera_shake_start"))
		{
			_camera_controller.camera_shake_start(
				BALANCE_BUILDING_SHELL_LAND_SHAKE_TIME,
				BALANCE_BUILDING_SHELL_LAND_SHAKE_STRENGTH
			);
		}
	}

	// Spawn smoke particles across the explosion radius.
	var _smoke_radius = effect_radius;
	var _smoke_count = smoke_particle_count;

	if (projectile_type == PROJECTILE_TYPE.BUILDING_SHELL)
	{
		_smoke_radius = building_smoke_radius;
		_smoke_count = building_smoke_particle_count;
	}

	for (var _smoke_index = 0; _smoke_index < _smoke_count; ++_smoke_index)
	{
		var _smoke_direction = random(360);
		var _smoke_distance = sqrt(random(1)) * _smoke_radius;
		var _smoke_x = target_x + lengthdir_x(_smoke_distance, _smoke_direction);
		var _smoke_y = target_y + lengthdir_y(_smoke_distance, _smoke_direction);

		instance_create_layer(_smoke_x, _smoke_y, particle_layer_name, o_particle_smoke);
	}

	// Corruption projectiles infect ground cells in the explosion radius.
	if (projectile_type == PROJECTILE_TYPE.CORRUPTION)
	{
		corrupt_circle(target_x, target_y, effect_radius, ground_corruption_amount);
	}
	else if (projectile_type == PROJECTILE_TYPE.CULTIST)
	{
		corrupt_circle(target_x, target_y, ground_corruption_radius, ground_corruption_amount);
	}
	else if (projectile_type == PROJECTILE_TYPE.FEAST)
	{
		corrupt_circle(target_x, target_y, ground_corruption_radius, ground_corruption_amount);

		var _enemy_list = ds_list_create();
		var _enemy_count = collision_circle_list(
			target_x,
			target_y,
			effect_radius,
			o_enemy_units,
			false,
			true,
			_enemy_list,
			false
		);

		for (var _enemy_index = 0; _enemy_index < _enemy_count; ++_enemy_index)
		{
			var _enemy = _enemy_list[| _enemy_index];

			if (!instance_exists(_enemy))
			{
				continue;
			}

			if (variable_instance_exists(_enemy, "unit_damage_receive"))
			{
				_enemy.unit_damage_receive(damage_amount, UNIT_FACTION.NOONE);
			}
			else if (variable_instance_exists(_enemy, "hp"))
			{
				_enemy.hp = max(_enemy.hp - damage_amount, 0);
				damage_popup_create(_enemy.x, _enemy.y, damage_amount, UNIT_FACTION.ENEMY);
			}
		}

		ds_list_destroy(_enemy_list);
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
	else if (projectile_type == PROJECTILE_TYPE.HEAL)
	{
		var _friendly_list = ds_list_create();
		var _friendly_count = collision_circle_list(
			target_x,
			target_y,
			effect_radius,
			o_friendly_units,
			false,
			true,
			_friendly_list,
			false
		);

		for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
		{
			var _friendly = _friendly_list[| _friendly_index];

			if (!instance_exists(_friendly)
				|| !variable_instance_exists(_friendly, "hp")
				|| !variable_instance_exists(_friendly, "max_hp")
				|| _friendly.max_hp <= 0)
			{
				continue;
			}

			var _hp_before_heal = _friendly.hp;

			if (variable_instance_exists(_friendly, "is_knocked_out") && _friendly.is_knocked_out)
			{
				_friendly.is_knocked_out = false;
				_friendly.knockout_timer = 0;
				_friendly.image_angle = 0;
			}

			_friendly.hp = min(_friendly.hp + damage_amount, _friendly.max_hp);

			if (_friendly.hp > _hp_before_heal)
			{
				heal_feedback_create(_friendly, _friendly.hp - _hp_before_heal);
			}
		}

		ds_list_destroy(_friendly_list);
	}
	else if (projectile_type == PROJECTILE_TYPE.BOMB)
	{
		with (all)
		{
			var _is_valid_target = (
				id != other.id
				&& object_index != o_projectile
				&& object_index != o_particle_smoke
				&& object_index != o_particle_explosion
				&& object_index != o_camera_controller
				&& object_index != o_game_controller
			);

			if (_is_valid_target
				&& point_distance(x, y, other.target_x, other.target_y) <= other.effect_radius
				&& variable_instance_exists(id, "hp"))
			{
				if (variable_instance_exists(id, "unit_damage_receive"))
				{
					unit_damage_receive(other.damage_amount, UNIT_FACTION.NOONE);
				}
				else
				{
					hp = max(hp - other.damage_amount, 0);

					if (variable_instance_exists(id, "unit_faction"))
					{
						damage_popup_create(x, y, other.damage_amount, unit_faction);
					}
				}
			}
		}
	}
	else if (projectile_type == PROJECTILE_TYPE.SKELETONS)
	{
		for (var _skeleton_index = 0; _skeleton_index < summon_count; ++_skeleton_index)
		{
			var _spawn_direction = random(360);
			var _spawn_distance = sqrt(random(1)) * effect_radius;
			var _skeleton_x = target_x + lengthdir_x(_spawn_distance, _spawn_direction);
			var _skeleton_y = target_y + lengthdir_y(_spawn_distance, _spawn_direction);
			var _skeleton = instance_create_layer(_skeleton_x, _skeleton_y, particle_layer_name, o_skeleton);

			if (instance_exists(_skeleton))
			{
				_skeleton.regroup_is_active = false;
				_skeleton.rally_is_active = false;
				_skeleton.target_instance = noone;
				_skeleton.alert_target = noone;
			}
		}
	}
	else if (projectile_type == PROJECTILE_TYPE.BUILDING_SHELL)
	{
		if (is_struct(building_payload)
			&& variable_struct_exists(building_payload, "building_object")
			&& instance_exists(o_game_controller))
		{
			var _game_controller = instance_find(o_game_controller, 0);

			if (variable_instance_exists(_game_controller, "ground_cell_is_tainted_at_position")
				&& _game_controller.ground_cell_is_tainted_at_position(target_x, target_y))
			{
				var _building = instance_create_layer(target_x, target_y, "Instances", building_payload.building_object);

				if (instance_exists(_building))
				{
					_building.building_constructed_by_shell = true;

					if (variable_instance_exists(_building, "max_hp"))
					{
						_building.max_hp = max(_building.max_hp, BALANCE_PLAYER_BUILDING_MAX_HP);
						_building.hp = _building.max_hp;
					}

					if (variable_instance_exists(_building, "is_captured"))
					{
						_building.is_captured = true;
					}

					if (variable_instance_exists(_building, "captured_sprite_index")
						&& _building.captured_sprite_index != noone)
					{
						_building.sprite_index = _building.captured_sprite_index;
						_building.image_index = 0;
						_building.image_speed = 0;
					}

					if (variable_global_exists("construction_sound_play"))
					{
						global.construction_sound_play();
					}
				}
			}
		}
	}

	if (projectile_type != PROJECTILE_TYPE.RALLY
		&& projectile_type != PROJECTILE_TYPE.FEAST
		&& projectile_type != PROJECTILE_TYPE.HEAL
		&& projectile_type != PROJECTILE_TYPE.BOMB
		&& projectile_type != PROJECTILE_TYPE.SKELETONS
		&& projectile_type != PROJECTILE_TYPE.BUILDING_SHELL)
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

							if (variable_instance_exists(id, "building_constructed_by_shell")
								&& building_constructed_by_shell
								&& hp <= 0)
							{
								instance_destroy();
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

	if (projectile_type == PROJECTILE_TYPE.CULTIST)
	{
		var _deploy_unit_count = array_length(cultist_deploy_units);

		for (var _deploy_index = 0; _deploy_index < _deploy_unit_count; ++_deploy_index)
		{
			var _deploy_unit = cultist_deploy_units[_deploy_index];

			if (!instance_exists(_deploy_unit))
			{
				continue;
			}

			var _deploy_direction = 360 * (_deploy_index / max(1, _deploy_unit_count));
			var _deploy_ring = (_deploy_index mod 3) / 2;
			var _deploy_distance = BALANCE_CULTIST_PROJECTILE_SUMMON_DEPLOY_RADIUS * lerp(0.35, 1, _deploy_ring);
			var _deploy_x = target_x + lengthdir_x(_deploy_distance, _deploy_direction);
			var _deploy_y = target_y + lengthdir_y(_deploy_distance, _deploy_direction);

			if (instance_exists(o_game_controller))
			{
				var _game_controller = instance_find(o_game_controller, 0);
				_game_controller.clear_cultist_building_assignment(_deploy_unit);
			}

			_deploy_unit.x = _deploy_x;
			_deploy_unit.y = _deploy_y;
			_deploy_unit.drag_drop_x = _deploy_x;
			_deploy_unit.drag_drop_y = _deploy_y;
			_deploy_unit.cultist_projectile_deploy_assigned = false;
			_deploy_unit.cultist_projectile_deploy_waiting = false;
			_deploy_unit.visible = true;
			_deploy_unit.target_instance = noone;
			_deploy_unit.alert_target = noone;
			_deploy_unit.regroup_is_active = false;
			_deploy_unit.rally_is_active = false;
			_deploy_unit.rally_is_returning = false;
			_deploy_unit.rally_has_arrived = false;
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

			if (variable_instance_exists(_cultist, "adaptive_night_hp_start"))
			{
				_demon.adaptive_night_hp_start = _cultist.adaptive_night_hp_start;
			}

			if (variable_instance_exists(_cultist, "stamina_amount"))
			{
				_demon.stamina_amount = _cultist.stamina_amount;
			}

			if (variable_instance_exists(_cultist, "adaptive_night_damage_taken"))
			{
				_demon.adaptive_night_damage_taken = _cultist.adaptive_night_damage_taken;
			}

			_demon.demon_type = _cultist.demon_type;
			_demon.demon_ability = _cultist.demon_ability;
			_demon.cultist_starting_abilities = _cultist.cultist_starting_abilities;

			_demon.current_exp = _cultist.current_exp;
			_demon.current_lvl = _cultist.current_lvl;
			cultist_demon_scale_apply(_demon);
			_demon.pending_level_points = _cultist.pending_level_points;
			_demon.pending_passive_choices = _cultist.pending_passive_choices;
			_demon.pending_active_choices = _cultist.pending_active_choices;
			_demon.pending_ability_upgrade_choices = _cultist.pending_ability_upgrade_choices;
			_demon.passive_choice_options = _cultist.passive_choice_options;
			_demon.active_choice_options = _cultist.active_choice_options;
			_demon.ability_upgrade_choice_options = _cultist.ability_upgrade_choice_options;
			_demon.active_abilities = _cultist.active_abilities;
			_demon.ability_levels = _cultist.ability_levels;
			_demon.has_brute_corpse_eater = _cultist.has_brute_corpse_eater;
			_demon.has_brute_rotten_aura = _cultist.has_brute_rotten_aura;
			_demon.has_brute_blood_anvil = _cultist.has_brute_blood_anvil;
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

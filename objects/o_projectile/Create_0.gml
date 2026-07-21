// Projectile route settings assigned by the firing cannon after creation.
start_x = x;
start_y = y;
target_x = x;
target_y = y;
projectile_type = PROJECTILE_TYPE.DAMAGE;
cultist_payload = noone;
cultist_deploy_units = [];
building_payload = noone;
source_instance = noone;

// Explosion and effect settings.
effect_radius = BALANCE_PROJECTILE_EFFECT_RADIUS;
damage_amount = BALANCE_PROJECTILE_DAMAGE_AMOUNT;
damage_faction = UNIT_FACTION.NOONE;
damage_target_count = 0;
summon_count = BALANCE_PROJECTILE_SKELETON_COUNT;
corruption_amount = 1;
ground_corruption_amount = BALANCE_PROJECTILE_GROUND_CORRUPTION_AMOUNT;
ground_corruption_radius = effect_radius;
cleanse_amount = 1;
saint_amount = 0;
smoke_particle_count = 22;
building_smoke_radius = 150;
building_smoke_particle_count = 44;
particle_layer_name = "Instances";

// Flight settings.
projectile_speed = BALANCE_PROJECTILE_SPEED;
minimum_flight_time = BALANCE_PROJECTILE_MIN_FLIGHT_TIME;
maximum_flight_time = BALANCE_PROJECTILE_MAX_FLIGHT_TIME;
launch_delay_timer = 0;
flight_time = minimum_flight_time * room_speed;
flight_timer = 0;
arc_height = 260;
ignore_pause = false;

// Visual settings.
projectile_radius = 12;
projectile_visual_scale = 2.5;
explosion_preview_frames = 8;
draw_explosion_preview = false;

projectile_target_is_allied = function(_target)
{
	if (damage_faction == UNIT_FACTION.NOONE || !instance_exists(_target))
	{
		return false;
	}

	if (variable_instance_exists(_target, "unit_faction"))
	{
		return _target.unit_faction == damage_faction;
	}

	if (damage_faction == UNIT_FACTION.ENEMY)
	{
		return _target.object_index == o_holy_tower
			|| _target.object_index == o_shrine
			|| _target.object_index == o_garnizon
			|| _target.object_index == o_house;
	}

	return false;
};

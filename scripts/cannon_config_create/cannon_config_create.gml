/// @description Creates independent settings for a cannon variant; shared mechanics remain on o_cannon.
/// @param {CANNON} _cannon_type Cannon identity selected for this run.
function cannon_config_create(_cannon_type)
{
	// Shared base settings are overridden by each Cannon below.
	var _config =
	{
		cannon_type: _cannon_type,
		allowed_shot_types: [
			PROJECTILE_TYPE.DAMAGE, PROJECTILE_TYPE.CORRUPTION, PROJECTILE_TYPE.SUMMON,
			PROJECTILE_TYPE.RALLY, PROJECTILE_TYPE.CULTIST, PROJECTILE_TYPE.HEAL,
			PROJECTILE_TYPE.BOMB, PROJECTILE_TYPE.SKELETONS, PROJECTILE_TYPE.BUILDING_SHELL,
			PROJECTILE_TYPE.CLEANSE, PROJECTILE_TYPE.ARTILLERY, PROJECTILE_TYPE.DOOM_BELL
		],
		// Ordered Shell Factory event pool; each creator checks its completion flag.
		shell_factory_event_creators: [
			day_event_shell_factory_enchantment_create,
			day_event_shell_factory_first_aid_enchantment_create,
			day_event_shell_factory_hellcow_enchantment_create,
			day_event_shell_factory_doom_bell_enchantment_create,
			day_event_shell_factory_taint_bloom_create,
			day_event_shell_factory_opening_barrage_create,
			day_event_shell_factory_favored_ammunition_create
		],
		shell_factory_overuse_event_enabled: true,
		daily_shot_types: [PROJECTILE_TYPE.CORRUPTION],
		look_over_there_daily_charges: 0,
		absorption_cooldown: BALANCE_ABSORPTION_COOLDOWN,
		gaze_enabled: false,
		gaze_radius: BALANCE_CANNON_GAZE_RADIUS,
		gaze_offset_y: BALANCE_CANNON_GAZE_OFFSET_Y,
		gaze_night_corruption_share: BALANCE_CANNON_GAZE_NIGHT_CORRUPTION_SHARE,
		max_hp: BALANCE_CANNON_MAX_HP,
		combat_radius: BALANCE_CANNON_COMBAT_RADIUS,
		projectile_effect_radius: BALANCE_PROJECTILE_EFFECT_RADIUS,
		volley_projectile_count: BALANCE_CANNON_VOLLEY_PROJECTILE_COUNT,
		volley_spread_radius: BALANCE_CANNON_VOLLEY_SPREAD_RADIUS,
		volley_launch_delay_min: BALANCE_CANNON_VOLLEY_LAUNCH_DELAY_MIN,
		volley_launch_delay_max: BALANCE_CANNON_VOLLEY_LAUNCH_DELAY_MAX,
		reload_default_time: BALANCE_CANNON_RELOAD_DEFAULT_TIME,
		reload_hellcow_time: BALANCE_CANNON_RELOAD_HELLCOW_TIME,
		reload_first_aid_time: BALANCE_CANNON_RELOAD_FIRST_AID_TIME,
		reload_doom_bell_time: BALANCE_CANNON_RELOAD_DOOM_BELL_TIME,
		reload_squad_time: BALANCE_CANNON_RELOAD_SQUAD_TIME,
		sprite_awake: s_cannon_awake,
		sprite_angry: s_cannon_angry,
		sprite_pleased: s_cannon_pleased,
		sprite_face: s_cannon_face,
		sprite_icon: s_cannon_icon,
		starting_hellcow_available: BALANCE_CANNON_STARTING_HELLCOW_AVAILABLE,
		starting_first_aid_available: BALANCE_CANNON_STARTING_FIRST_AID_AVAILABLE,
		starting_doom_bell_available: BALANCE_CANNON_STARTING_DOOM_BELL_AVAILABLE,
		morning_taint_compost_limit: BALANCE_DEFAULT_MORNING_TAINT_COMPOST_LIMIT,
		demand_indices: [0, 1, 2, 3, 4, 5],
		demand_create: day_event_cannon_demand_create,
		demand_day_interval: BALANCE_CANNON_DEMAND_DAY_INTERVAL
	};

	// Add variant-specific overrides here when either Cannon gains unique content.
	// demand_indices refer to the authored cases in day_event_cannon_demand_create.
	switch (_cannon_type)
	{
		case CANNON.CANNON_1:
			break;

		case CANNON.CANNON_2:
			_config.gaze_enabled = true;
			_config.shell_factory_event_creators = [day_event_shell_factory_absorption_create, day_event_shell_factory_quicksand_create, day_event_shell_factory_dark_garden_create, day_event_shell_factory_curing_spit_create, day_event_shell_factory_look_night_create];
			_config.shell_factory_overuse_event_enabled = false;
			_config.allowed_shot_types = [PROJECTILE_TYPE.LOOK_OVER_THERE, PROJECTILE_TYPE.ABSORPTION, PROJECTILE_TYPE.QUICKSAND, PROJECTILE_TYPE.DARK_GARDEN, PROJECTILE_TYPE.CURING_SPIT];
			_config.daily_shot_types = [PROJECTILE_TYPE.LOOK_OVER_THERE];
			_config.look_over_there_daily_charges = BALANCE_LOOK_OVER_THERE_DAILY_CHARGES;
			_config.starting_hellcow_available = false;
			_config.starting_first_aid_available = false;
			_config.starting_doom_bell_available = false;
			_config.morning_taint_compost_limit = 0;
			break;
	}

	return _config;
}

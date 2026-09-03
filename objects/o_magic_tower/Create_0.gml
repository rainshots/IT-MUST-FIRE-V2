// Initialize shared map object state.
event_inherited();
player_map_building_ruins_enabled = true;

// Capture state changes the tower sprite and unlocks combat.
tower_capture_enabled = true;
is_captured = false;
uncaptured_sprite_index = s_watchtower_b;
captured_sprite_index = s_watchtower;
sprite_index = captured_sprite_index;
image_speed = 0;

// Durability and combat values follow the magic tower balance table.
max_hp = BALANCE_MAGIC_TOWER_MAX_HP;
hp = max_hp;
armor = BALANCE_MAGIC_TOWER_ARMOR;
magic_resistance = BALANCE_MAGIC_TOWER_MAGIC_RESISTANCE;
player_building_cleansed_base_max_hp = max_hp;
base_shoot_radius = BALANCE_MAGIC_TOWER_RADIUS;
var _tower_radius_multiplier = variable_global_exists("player_tower_radius_multiplier")
	? global.player_tower_radius_multiplier
	: 1;
var _foundry_radius_bonus = variable_global_exists("foundry_tower_radius_base_bonus")
	? global.foundry_tower_radius_base_bonus
	: 0;
var _foundry_damage_bonus = variable_global_exists("foundry_tower_damage_base_bonus")
	? global.foundry_tower_damage_base_bonus
	: 0;
base_magic_damage = BALANCE_MAGIC_TOWER_DAMAGE_AMOUNT;
shoot_radius = base_shoot_radius * (_tower_radius_multiplier + _foundry_radius_bonus);
magic_damage = base_magic_damage * (1 + _foundry_damage_bonus);
reload_time = BALANCE_MAGIC_TOWER_RELOAD_TIME * room_speed;
reload_timer = 0;
target_instance = noone;
attack_origin_top_offset = 81;

// A short red line makes the instant magic attack readable.
attack_feedback_time = BALANCE_MAGIC_TOWER_ATTACK_FEEDBACK_TIME * room_speed;
attack_feedback_timer = 0;
attack_feedback_target = noone;
attack_feedback_target_x = x;
attack_feedback_target_y = y;
attack_feedback_line_width = BALANCE_MAGIC_TOWER_ATTACK_LINE_WIDTH;

tooltip_lines = [
	"Captured: strikes one enemy with magic in a 750px radius",
	"Capture: requires full Taint under the tower",
	"Hover: shows shooting radius"
];
building_has_upgrades = false;
building_tooltip_description = "A long-range tower that deals magic damage.";

magic_tower_damage_get = function(_target)
{
	var _target_magic_resistance = 100;

	if (instance_exists(_target) && variable_instance_exists(_target, "magic_resistance"))
	{
		_target_magic_resistance = _target.magic_resistance;
	}

	var _resistance_multiplier = max(
		2 - (min(_target_magic_resistance, 190) * 0.01),
		0.1
	);
	return magic_damage * _resistance_multiplier;
};

magic_tower_attack = function(_target)
{
	if (!instance_exists(_target))
	{
		return false;
	}

	var _damage_amount = magic_tower_damage_get(_target);

	if (variable_instance_exists(_target, "unit_damage_receive"))
	{
		_target.unit_damage_receive(
			_damage_amount,
			UNIT_FACTION.FRIENDLY,
			false,
			true,
			id
		);
	}
	else if (variable_instance_exists(_target, "hp"))
	{
		_target.hp = max(0, _target.hp - _damage_amount);
	}

	attack_feedback_timer = attack_feedback_time;
	attack_feedback_target = _target;
	attack_feedback_target_x = _target.x;
	attack_feedback_target_y = _target.y;
	return true;
};

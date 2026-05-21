// Initialize shared map object state.
event_inherited();

// Holy tower durability.
max_hp = 160;
hp = max_hp;
max_corruption = 100;
corruption = 0;

// Holy tower combat settings.
shoot_radius = BALANCE_HOLY_TOWER_SHOOT_RADIUS;
damage = BALANCE_HOLY_TOWER_DAMAGE;
reload_time = BALANCE_HOLY_TOWER_RELOAD_TIME * room_speed;
reload_timer = 0;
target_instance = noone;
assist_call_radius = BALANCE_UNIT_ASSIST_CALL_RADIUS;

// Holy ground settings.
holy_radius_in_cells = BALANCE_HOLY_TOWER_HOLY_RADIUS_IN_CELLS;
holy_radius = holy_radius_in_cells * 100;
death_corruption_amount = BALANCE_HOLY_TOWER_DEATH_CORRUPTION_AMOUNT;
is_holy_area_active = false;

// Range drawing settings.
radius_line_width = 2;
radius_alpha = 0.32;

// Attack feedback shows the tower shot for a short moment.
attack_feedback_time = BALANCE_HOLY_TOWER_ATTACK_FEEDBACK_TIME * room_speed;
attack_feedback_timer = 0;
attack_feedback_target = noone;
attack_feedback_target_x = x;
attack_feedback_target_y = y;
attack_feedback_line_width = 2;

// Tooltip lines describe tower behavior.
tooltip_lines = [
	"Damage: Takes damage. Corrupts holy area at 0 HP",
	"Corruption: Blocks nearby ground corruption",
	"Summon: No effect yet"
];

make_nearby_ground_holy = function()
{
	if (!is_holy_area_active && instance_exists(o_corruption_grid))
	{
		var _corruption_grid = instance_find(o_corruption_grid, 0);
		_corruption_grid.make_circle_holy(x, y, holy_radius);
		is_holy_area_active = true;
	}
};

destroy_holy_tower = function()
{
	if (is_holy_area_active && instance_exists(o_corruption_grid))
	{
		var _corruption_grid = instance_find(o_corruption_grid, 0);
		_corruption_grid.remove_circle_holy_and_corrupt(x, y, holy_radius, death_corruption_amount);
		is_holy_area_active = false;
	}

	instance_create_layer(x, y, "Instances", o_tower_ruins);
	instance_destroy();
};

// Holy tower creates protected holy ground when it appears.
make_nearby_ground_holy();

// Damage projectiles can destroy the holy tower.
on_damage_projectile_hit = function()
{
	hp = max(hp - BALANCE_PROJECTILE_DAMAGE_AMOUNT, 0);

	if (hp <= 0)
	{
		destroy_holy_tower();
	}
};

call_nearby_friendly_units_for_help = function(_attacked_unit)
{
	if (!instance_exists(_attacked_unit))
	{
		return;
	}

	// The attacked unit remembers the tower immediately.
	_attacked_unit.alert_target = id;
	_attacked_unit.alert_target_timer = _attacked_unit.alert_target_time;

	var _nearby_units = ds_list_create();
	var _nearby_unit_count = collision_circle_list(_attacked_unit.x, _attacked_unit.y, assist_call_radius, o_friendly_units, false, true, _nearby_units, false);

	// Nearby friendly units receive the same threat and can help attack the tower.
	for (var _unit_index = 0; _unit_index < _nearby_unit_count; ++_unit_index)
	{
		var _friendly_unit = _nearby_units[| _unit_index];

		if (instance_exists(_friendly_unit))
		{
			_friendly_unit.alert_target = id;
			_friendly_unit.alert_target_timer = _friendly_unit.alert_target_time;
		}
	}

	ds_list_destroy(_nearby_units);
};

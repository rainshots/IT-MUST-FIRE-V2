// Base durability values for map objects.
max_hp = 100;
hp = max_hp;
max_corruption = 100;
corruption = 0;
y_sort_enabled = true;

// Health and corruption bar visual settings.
bar_width = 72;
bar_height = 6;
bar_gap = 3;
bar_offset_y = 48;

// Tooltip text and visual settings.
tooltip_lines = [
	"Damage: No effect",
	"Corruption: No effect",
	"Summon: No effect"
];
tooltip_padding = 10;
tooltip_line_height = 18;
tooltip_width = 390;
tooltip_offset_y = 72;

// Transform target. noone means the object does not transform by default.
transform_object = noone;

// Default projectile reactions. Children override these methods.
on_damage_projectile_hit = function()
{
};

on_corruption_projectile_hit = function()
{
};

on_summon_projectile_hit = function()
{
};

on_projectile_hit = function(_projectile_type)
{
	if (variable_global_exists("legacy_building_logic_enabled") && !global.legacy_building_logic_enabled)
	{
		return;
	}

	if (_projectile_type == PROJECTILE_TYPE.DAMAGE)
	{
		on_damage_projectile_hit();
	}
	else if (_projectile_type == PROJECTILE_TYPE.CORRUPTION)
	{
		on_corruption_projectile_hit();
	}
	else if (_projectile_type == PROJECTILE_TYPE.SUMMON)
	{
		on_summon_projectile_hit();
	}
};

transform_into = function(_object_index)
{
	if (_object_index != noone)
	{
		instance_create_layer(x, y, "Instances", _object_index);
	}

	instance_destroy();
};

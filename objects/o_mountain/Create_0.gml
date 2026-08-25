// Initialize shared obstacle and map object state.
event_inherited();

// Mountains are permanent neutral terrain and never become combat targets.
max_hp = 1;
hp = max_hp;
unit_faction = UNIT_FACTION.NOONE;
is_attackable = false;
ignored_by_enemies = true;
health_bar_visible = false;
corruption_bar_visible = false;
image_speed = 0;

// The tooltip documents the terrain rules for level editing and testing.
tooltip_lines = [
	"Movement: Blocks units",
	"Vision: Blocks line of sight",
	"Damage: Immune"
];

// Mountains ignore direct, area, and projectile damage routed through combat systems.
unit_damage_receive = function(_damage_amount, _source_faction = UNIT_FACTION.NOONE, _is_critical = false, _can_trigger_soul_chain = true, _source_instance = noone)
{
	return 0;
};

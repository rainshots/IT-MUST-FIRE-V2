// Initialize shared wall state.
event_inherited();
enemy_building_shield_enabled = true;

// Player combat units can attack enemy walls as fallback targets.
unit_faction = UNIT_FACTION.ENEMY;

// Reuse Pumpkin Mine stats, warning countdown, explosion, smoke, and sound.
event_inherited();

// Enemy mines trigger on and damage living, deployed player units.
trap_target_object = o_friendly_units;
trap_damage_faction = UNIT_FACTION.ENEMY;
trap_damage = BALANCE_ENEMY_MINE_DAMAGE;
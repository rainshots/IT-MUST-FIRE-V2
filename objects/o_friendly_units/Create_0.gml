// Initialize shared unit state.
event_inherited();

// Friendly units protect the cannon.
unit_faction = UNIT_FACTION.FRIENDLY;
// Player units acquire enemies from farther away.
vision_radius *= BALANCE_PLAYER_AGGRO_RADIUS_MULTIPLIER;
// Newly recruited player units belong to the faction selected for this match.
faction = global.player_faction;

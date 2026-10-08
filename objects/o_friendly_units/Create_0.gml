// Initialize shared unit state.
event_inherited();

// Friendly units protect the cannon.
unit_faction = UNIT_FACTION.FRIENDLY;
// Newly recruited player units belong to the faction selected for this match.
faction = global.player_faction;

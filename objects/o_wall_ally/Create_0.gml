// Initialize shared wall state.
event_inherited();

// Ally walls are friendly durability objects and never become player fallback targets.
unit_faction = UNIT_FACTION.FRIENDLY;

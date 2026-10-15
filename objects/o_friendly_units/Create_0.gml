// Initialize shared unit state.
event_inherited();

// Friendly units protect the cannon.
unit_faction = UNIT_FACTION.FRIENDLY;
// Individual units guard the Cannon until launched.
cargo_cost = 1;
cargo_launched = false;
cargo_idle_offset_x = random_range(BALANCE_CARGO_IDLE_MIN_X, BALANCE_CARGO_IDLE_MAX_X);
cargo_idle_offset_y = random_range(-BALANCE_CARGO_IDLE_HALF_HEIGHT, BALANCE_CARGO_IDLE_HALF_HEIGHT);
// Player units acquire enemies from farther away.
vision_radius *= BALANCE_PLAYER_AGGRO_RADIUS_MULTIPLIER;
// Newly recruited player units belong to the faction selected for this match.
faction = global.player_faction;

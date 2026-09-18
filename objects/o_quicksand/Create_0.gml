// The landed shell assigns the owning Cannon, radius, and permanent upgrade.
source_cannon = noone;
effect_radius = BALANCE_CANNON_GAZE_RADIUS;
upgrade = QUICKSAND_UPGRADE.NONE;
life_remaining = BALANCE_QUICKSAND_DURATION * room_speed;
// Rotation makes the active area readable without spawning particles every frame.
swirl_angle = 0;

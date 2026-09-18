// The projectile assigns ownership and its upgrade when it lands.
source_cannon = noone;
effect_radius = BALANCE_CANNON_GAZE_RADIUS;
upgrade = CURING_SPIT_UPGRADE.NONE;
life_remaining = BALANCE_CURING_SPIT_DURATION * room_speed;
pulse_interval = BALANCE_CURING_SPIT_PULSE_INTERVAL * room_speed;
pulse_elapsed = 0;

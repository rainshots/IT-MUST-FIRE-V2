// The fuse starts on landing and follows gameplay time, including pause and fast-forward.
fuse_duration = max(0, BALANCE_BOMB_SHOT_FUSE_TIME * room_speed);
fuse_timer = fuse_duration;
effect_radius = BALANCE_BOMB_SHOT_RADIUS;
damage_amount = BALANCE_BOMB_SHOT_DAMAGE;
source_instance = noone; // Assigned by the projectile for damage credit and retaliation.

// Ground marker dimensions and blast preview.
body_radius = BALANCE_BOMB_SHOT_BODY_RADIUS;
spark_radius = BALANCE_BOMB_SHOT_SPARK_RADIUS;
zone_alpha = BALANCE_BOMB_SHOT_ZONE_ALPHA;
smoke_count = BALANCE_BOMB_SHOT_SMOKE_COUNT;
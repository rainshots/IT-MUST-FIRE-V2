event_inherited();
if (global.pause || hp <= 0) exit;
reload_seconds = max(0, reload_seconds - global.gameplay_time_scale / max(1, room_speed));
if (reload_seconds > 0) exit;

// Fire at the closest living player combat unit within range.
var _target = noone;
var _nearest = BALANCE_ENEMY_DEFENSE_TOWER_RANGE;
with (o_friendly_units)
{
	if (hp <= 0 || cannon_loaded || is_being_dragged || (variable_instance_exists(id, "ignored_by_enemies") && ignored_by_enemies)) continue;
	var _distance = point_distance(x, y, other.x, other.y);
	if (_distance <= _nearest) { _nearest = _distance; _target = id; }
}
if (!instance_exists(_target)) exit;
var _shot = instance_create_layer(x, bbox_top, "Instances", o_projectile);
_shot.target_x = _target.x;
_shot.target_y = _target.y;
_shot.projectile_type = PROJECTILE_TYPE.DAMAGE;
_shot.damage_amount = BALANCE_ENEMY_DEFENSE_TOWER_DAMAGE;
_shot.damage_faction = UNIT_FACTION.ENEMY;
_shot.damage_units_only = true;
_shot.effect_radius = BALANCE_ENEMY_DEFENSE_TOWER_EFFECT_RADIUS;
_shot.source_instance = id;
_shot.flight_time = clamp(point_distance(_shot.x, _shot.y, _target.x, _target.y) / _shot.projectile_speed,
	_shot.minimum_flight_time, _shot.maximum_flight_time) * room_speed;
reload_seconds = BALANCE_ENEMY_DEFENSE_TOWER_RELOAD_SECONDS;

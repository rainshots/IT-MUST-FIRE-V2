// Goblins use the same guarding, cargo and assault AI as other player units.
event_inherited();
sprite_index = s_goblin;
max_hp = BALANCE_GOBLIN_HP;
hp = max_hp;
ignored_by_enemies = false;
move_speed = BALANCE_GOBLIN_CHARGE_SPEED;
attack_radius = BALANCE_GOBLIN_CONTACT_RADIUS;
damage = BALANCE_GOBLIN_BOMB_DAMAGE;
magic_damage = 0;
bar_offset_y = -2;
// Contact replaces an ordinary attack with a one-use enemy-only explosion.
attack_target = function(_target)
{
	if (!target_can_be_attacked(_target) || hp <= 0 || cannon_loaded || is_being_dragged) return;
	var _targets = [];
	with (all)
	{
		if (!variable_instance_exists(id, "unit_faction") || unit_faction != UNIT_FACTION.ENEMY) continue;
		if (!variable_instance_exists(id, "hp") || hp <= 0) continue;
		var _closest_x = clamp(other.x, bbox_left, bbox_right);
		var _closest_y = clamp(other.y, bbox_top, bbox_bottom);
		if (point_distance(other.x, other.y, _closest_x, _closest_y) <= BALANCE_GOBLIN_BOMB_RADIUS) array_push(_targets, id);
	}
	for (var _i = 0; _i < array_length(_targets); ++_i) cannon_damage_apply(_targets[_i], BALANCE_GOBLIN_BOMB_DAMAGE);
	var _flash = instance_create_layer(x, y, "Instances", o_particle_explosion);
	_flash.end_radius = BALANCE_GOBLIN_BOMB_RADIUS;
	hp = 0;
	unit_death_process();
};

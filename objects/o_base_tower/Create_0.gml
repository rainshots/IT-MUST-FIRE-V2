// Passive fight objective: only durability and presentation, with no Holy Tower behavior.
max_hp = BALANCE_BASE_TOWER_MAX_HP;
hp = max_hp;
unit_faction = UNIT_FACTION.ENEMY;
is_attackable = true;
y_sort_enabled = true;
depth = BALANCE_BUILDING_GRID_ACTOR_DEPTH - floor(y);
image_speed = 0;
unit_damage_receive = function(_damage_amount, _source_faction = UNIT_FACTION.NOONE, _is_critical = false, _can_trigger_soul_chain = true, _source_instance = noone, _favor_faction = FACTION.NONE)
{
	if (hp <= 0 || _damage_amount <= 0 || _source_faction == unit_faction) return 0;
	var _applied_damage = min(hp, _damage_amount);
	hp -= _applied_damage;
	damage_popup_create(x, y, _applied_damage, unit_faction, _is_critical);
	if (hp <= 0) instance_destroy();
	return _applied_damage;
};

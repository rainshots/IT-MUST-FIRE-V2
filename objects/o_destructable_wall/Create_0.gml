// Reuse wall collision, health bars, and navigation invalidation on destruction.
event_inherited();
max_hp = BALANCE_DESTRUCTABLE_WALL_HP;
hp = max_hp;
image_speed = 0;
tooltip_lines = ["Blocks movement", "Can be destroyed by cannon shots and units"];

// Neutral obstacles accept damage from either army and from neutral projectiles.
unit_damage_receive = function(_damage_amount, _source_faction = UNIT_FACTION.NOONE, _is_critical = false, _can_trigger_soul_chain = true, _source_instance = noone)
{
	if (hp <= 0 || _damage_amount <= 0)
	{
		return 0;
	}

	var _applied_damage = min(hp, _damage_amount);
	hp -= _applied_damage;
	damage_popup_create(x, y, _applied_damage, unit_faction, _is_critical);
	if (hp <= 0)
	{
		instance_destroy();
	}
	return _applied_damage;
};

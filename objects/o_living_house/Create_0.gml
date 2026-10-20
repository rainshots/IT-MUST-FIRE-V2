// Passive enemy structure: no attacks, production or faction behavior.
max_hp = BALANCE_LIVING_HOUSE_HP;
hp = max_hp;
unit_faction = UNIT_FACTION.ENEMY;
is_attackable = true;
y_sort_enabled = true;
depth = BALANCE_BUILDING_GRID_ACTOR_DEPTH - floor(y);
image_speed = 0;
reward_paid = false;
// Explicit combat destruction keeps room and fight cleanup from granting Mana.
house_death_process = function()
{
	if (hp > 0 || reward_paid) return;
	reward_paid = true;
	if (instance_exists(o_game_controller) && o_game_controller.fight_state == FIGHT_STATE.ACTIVE)
		global.faction_mana[global.player_faction] += BALANCE_LIVING_HOUSE_MANA;
	instance_destroy();
};
unit_damage_receive = function(_damage_amount, _source_faction = UNIT_FACTION.NOONE, _is_critical = false, _can_trigger_soul_chain = true, _source_instance = noone, _favor_faction = FACTION.NONE)
{
	if (hp <= 0 || _damage_amount <= 0 || _source_faction == unit_faction) return 0;
	var _applied = min(hp, _damage_amount);
	hp -= _applied;
	damage_popup_create(x, y, _applied, unit_faction, _is_critical);
	if (hp <= 0) house_death_process();
	return _applied;
};

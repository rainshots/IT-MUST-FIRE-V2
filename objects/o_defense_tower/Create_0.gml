// Reuse enemy building durability and targeting integration.
event_inherited();
// Legacy projectile attribution requires an explicit faction.
faction = FACTION.NONE;
building_label = "Defense Tower";
guards_enabled = false;
mana_reward = 0;
max_hp = BALANCE_ENEMY_DEFENSE_TOWER_HP;
hp = max_hp;
reload_seconds = 0;

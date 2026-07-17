// Regular cultists are day-event workers and never enter the cannon.
cultist_name = "Cultist";
max_hp = BALANCE_EVENT_CULTIST_MAX_HP;
hp = max_hp;
assigned_event = noone;

// Give every regular cultist a small random day-form appearance.
var _cultist_sprites = [s_cultist_01, s_cultist_02, s_cultist_03, s_cultist_04];
var _cultist_sprite_count = array_length(_cultist_sprites);
sprite_index = _cultist_sprites[irandom(_cultist_sprite_count - 1)];
image_xscale = BALANCE_EVENT_CULTIST_SPRITE_SCALE;
image_yscale = image_xscale;

wander_target_x = x;
wander_target_y = y;
wander_timer = irandom(BALANCE_EVENT_CULTIST_WANDER_DELAY);
move_speed = BALANCE_EVENT_CULTIST_MOVE_SPEED;
y_sort_enabled = true;

is_available = function()
{
	return hp > 0 && !is_struct(assigned_event);
};

damage = function(_amount)
{
	var _damage = max(0, _amount);
	hp = max(0, hp - _damage);
	return _damage;
};

heal = function(_amount)
{
	var _previous_hp = hp;
	hp = min(max_hp, hp + max(0, _amount));
	return hp - _previous_hp;
};

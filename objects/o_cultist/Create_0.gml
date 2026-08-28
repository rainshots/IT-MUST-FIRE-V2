// Regular cultists are day-event workers and never enter the cannon.
cultist_name = "Cultist";
max_hp = BALANCE_EVENT_CULTIST_MAX_HP;
hp = max_hp;
assigned_event = noone;
// Completed Rite building sprites are stored oldest-first for the Assign Duties history.
work_history = [];
// Building work counts select one permanent specialization after three completed Rites.
building_work_counts = [];
specialization_building_object = noone;
specialization_building_name = "";
specialization_building_sprite = noone;
// Event execution consumes this temporary discount across all HP costs in one Rite.
event_specialization_hp_discount_remaining = 0;
is_being_dragged = false;
drag_drop_x = x;
drag_drop_y = y;
// Unconscious Cultists remain in the settlement but cannot work until their HP becomes positive.
is_unconscious = false;
unconscious_mornings = 0;
// Blood Bath effects queued during the day resolve after the following night.
blood_bath_morning_heal_pending = 0;
blood_bath_morning_unconscious_heal_pending = 0;
blood_bath_morning_full_heal_pending = false;
blood_bath_morning_full_heal_affects_unconscious = false;
// Lingering Wounds restores this exact start-of-day HP value next morning.
blood_bath_morning_hp_snapshot = hp;

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

// Cursed Point construction workers return to their original cannon-side home at night.
return_to_cannon_at_night = false;
home_offset_x = 0;
home_offset_y = BALANCE_EVENT_CULTIST_WANDER_VERTICAL_DISTANCE_MIN;

if (instance_exists(o_cannon))
{
	var _cannon = instance_find(o_cannon, 0);
	home_offset_x = x - _cannon.x;
	home_offset_y = y - _cannon.y;
}

is_available = function()
{
	return !is_unconscious && hp > 0 && !is_struct(assigned_event);
};

damage = function(_amount)
{
	return day_event_cultist_damage_apply(id, _amount);
};

heal = function(_amount, _affects_unconscious_cultists = false)
{
	return day_event_cultist_heal_apply(id, _amount, _affects_unconscious_cultists);
};

// A single-cell check keeps the slot in sync with Taint application and cleansing.
is_active = building_slot_is_active();
sprite_index = is_active ? s_building_slot : s_building_slot_empty;

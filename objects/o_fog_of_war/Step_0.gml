// Refresh current sight at a short interval, including while the camera is paused.
update_interval = max(1, room_speed * BALANCE_FACTION_VISION_UPDATE_SECONDS);
update_timer++;
if (update_timer < update_interval) exit;
update_timer = 0;
fog_visibility_update();

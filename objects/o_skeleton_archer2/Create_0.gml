// Inherit archer health, visuals, damage handling, and shared unit navigation.
event_inherited();

// The shared Step dispatches this AI after health, pause, and status processing.
army_ai_enabled = true;
army_point = noone;
army_point_search_timer_seconds = 0;
army_wait_offset_x = 0;
army_wait_offset_y = 0;
// Once dispatched from an army point, keep marching until morning.
army_night_march_active = false;

// This prototype marches instead of reacting with the original archer's flee AI.
unit_damage_received = function(_source_instance, _source_faction, _applied_damage)
{
};

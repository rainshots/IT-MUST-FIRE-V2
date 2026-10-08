// Non-player units are drawn only within current faction sight.
if (unit_is_hidden_by_fog()) exit;

// Draw shared unit visuals first.
event_inherited();

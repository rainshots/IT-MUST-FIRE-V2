// UI remains interactive while pause and result screens freeze the simulation.
conquest_input_update(id);
if (paused || phase != BATTLE_PHASE.BATTLE) exit;
conquest_simulation_update(id, 1 / max(1, room_speed));

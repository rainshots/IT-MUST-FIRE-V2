// Executed by the isolated project from prepare_conquest_runtime.cjs in the real GameMaker VM.
// Let each actual room render before checking its state, including pause and result overlays.
if (test_wait_frames > 0)
{
	test_wait_frames--;
	exit;
}
var _assert = function(_condition, _message)
{
	if (!_condition) throw _message;
};
try
{
	if (test_phase == 0)
	{
		var _map = instance_find(o_world_map, 0);
		_assert(room == r_world_map && instance_exists(_map), "Campaign did not start on the map");
		_assert(instance_exists(o_level_01) && o_level_01.level_state == WORLD_MAP_LEVEL_STATE.AVAILABLE, "Opening level unavailable");
		_map.active_level = o_level_01;
		_map.active_battle_room = Battle_room;
		_map.active_level_title = o_level_01.level_title;
		test_phase = 1;
		test_wait_frames = 3;
		room_goto(r_conquest);
		exit;
	}
	if (test_phase == 1)
	{
		var _controller = instance_find(o_conquest, 0);
		_assert(instance_exists(_controller) && _controller.tactical_mode && array_length(_controller.nodes) == 7, "Road mission did not initialize");
		screen_save("conquest_roads_start.png");
		// INSERT_ROAD_RUNTIME_CHECKS
		test_phase = 8;
		test_wait_frames = 3;
		exit;
	}
	if (test_phase == 8)
	{
		screen_save("conquest_roads_battle.png");
		var _controller = instance_find(o_conquest, 0);
		_controller.paused = true;
		test_phase = 9;
		test_wait_frames = 3;
		exit;
	}
	if (test_phase == 9)
	{
		screen_save("conquest_roads_pause.png");
		// Run the original mechanics suite on a classic layout while retaining the real campaign point.
		var _controller = instance_find(o_conquest, 0);
		_controller.campaign_map.active_battle_room = r_battle_03;
		_controller.nodes = [];
		_controller.scenery = [];
		_controller.armies = [];
		_controller.shots = [];
		_controller.paused = false;
		conquest_level_prepare(_controller);
		test_phase = 10;
	}
	if (test_phase == 10)
	{
		var _controller = instance_find(o_conquest, 0);
		_assert(instance_exists(_controller), "Conquest controller missing");
		_assert(!instance_exists(o_game_controller) && !instance_exists(o_hud) && !instance_exists(o_units_parent), "Legacy battle objects leaked");
		_assert(_controller.level_title == "Ashen Crossing" && array_length(_controller.nodes) == 10, "Selected level did not initialize");
		array_push(results, "PASS: map entry, selected title, independent conquest lifecycle");
		_controller.ai_timer = 10000;
		var _home = _controller.nodes[0];
		var _neutral = _controller.nodes[1];
		_home.garrison = 48;
		var _sent = conquest_order_send(_controller, 0, 1, 0.5, CONQUEST_OWNER.PLAYER);
		_assert(_sent == 24 && _home.garrison == 24 && array_length(_controller.armies) == 1, "Dispatch did not conserve troops");
		_assert(conquest_order_send(_controller, 9, 1, 1, CONQUEST_OWNER.PLAYER) == 0, "Player ordered enemy building");
		_assert(conquest_order_send(_controller, 0, 0, 1, CONQUEST_OWNER.PLAYER) == 0, "Self order accepted");
		_assert(conquest_order_send(_controller, -1, 50, 1, CONQUEST_OWNER.PLAYER) == 0, "Invalid node accepted");
		var _neutral_before = _neutral.garrison;
		conquest_simulation_update(_controller, 0.5);
		_assert(abs(_home.garrison - 25) < 0.001 && _neutral.garrison == _neutral_before, "Recruitment rate or neutral growth");
		for (var _frame = 0; _frame < 240; ++_frame) conquest_simulation_update(_controller, 1 / 60);
		_assert(_neutral.owner == CONQUEST_OWNER.PLAYER && _neutral.garrison >= 14, "Neutral capture failed");
		_assert(array_length(_controller.armies) == 0, "Arrived army retained");
		array_push(results, "PASS: dispatch conservation, invalid orders, real travel, neutral recruitment and capture");

		// Arrival must inspect the current target and preserve the marching army's original faction.
		_neutral.garrison = 100;
		conquest_arrival_resolve(_controller, { target: 1, owner: CONQUEST_OWNER.PLAYER, count: 20 });
		_assert(_neutral.garrison == 120, "Friendly reinforcements lost above capacity");
		conquest_simulation_update(_controller, 1);
		_assert(_neutral.garrison == 120, "Capacity deleted reinforcements");
		_neutral.owner = CONQUEST_OWNER.ENEMY;
		_neutral.garrison = 10;
		_neutral.level = 3;
		_neutral.upgrade_remaining = 1;
		conquest_arrival_resolve(_controller, { target: 1, owner: CONQUEST_OWNER.PLAYER, count: 20 });
		_assert(_neutral.owner == CONQUEST_OWNER.PLAYER && _neutral.level == 2 && _neutral.upgrade_remaining == 0, "Recapture did not cancel upgrade / reduce level");
		_neutral.owner = CONQUEST_OWNER.ENEMY;
		_neutral.garrison = 10;
		conquest_arrival_resolve(_controller, { target: 1, owner: CONQUEST_OWNER.PLAYER, count: 10 });
		_assert(_neutral.owner == CONQUEST_OWNER.ENEMY && _neutral.garrison == 0, "Tie resolution incorrect");
		array_push(results, "PASS: reinforcements over capacity, ownership changes in transit, interrupted upgrades, ties");

		_home.level = 1;
		_home.garrison = 20;
		_assert(!conquest_upgrade_start(_controller, 0, CONQUEST_OWNER.PLAYER), "Upgrade emptied last defender");
		_home.garrison = 35;
		_assert(conquest_upgrade_start(_controller, 0, CONQUEST_OWNER.PLAYER) && _home.garrison == 15, "Upgrade payment wrong");
		_assert(!conquest_upgrade_start(_controller, 0, CONQUEST_OWNER.PLAYER), "Duplicate upgrade accepted");
		_assert(conquest_order_send(_controller, 0, 1, 1, CONQUEST_OWNER.PLAYER) == 0, "Upgrading source dispatched");
		conquest_simulation_update(_controller, 1);
		_assert(_home.garrison == 15 && _home.level == 1, "Recruitment continued while upgrading");
		_controller.paused = true;
		var _elapsed = _controller.elapsed_seconds;
		conquest_simulation_update(_controller, 20);
		_assert(_controller.elapsed_seconds == _elapsed && _home.upgrade_remaining == 2, "Pause advanced simulation");
		_controller.paused = false;
		conquest_simulation_update(_controller, 2);
		_assert(_home.level == 2 && _home.upgrade_remaining == 0, "Upgrade did not finish");
		_home.level = 3;
		_home.garrison = 200;
		_assert(!conquest_upgrade_start(_controller, 0, CONQUEST_OWNER.PLAYER), "Exceeded maximum level");
		array_push(results, "PASS: upgrade cost, defender reserve, recruitment pause, battle pause, completion and level cap");

		// Forges immediately affect their current faction and stop helping it after capture.
		var _forge = _controller.nodes[4];
		_forge.owner = CONQUEST_OWNER.PLAYER;
		_forge.level = 2;
		_assert(abs(conquest_strength_get(_controller, CONQUEST_OWNER.PLAYER) - 1.24) < 0.001, "Forge strength missing");
		_forge.owner = CONQUEST_OWNER.ENEMY;
		_assert(conquest_strength_get(_controller, CONQUEST_OWNER.PLAYER) == 1, "Captured forge retained old bonus");
		_forge.owner = CONQUEST_OWNER.NEUTRAL;
		var _tower = _controller.nodes[3];
		_tower.owner = CONQUEST_OWNER.PLAYER;
		_tower.level = 2;
		_controller.armies = [{owner: CONQUEST_OWNER.ENEMY, count: 8, source: 9, target: 3,
			x: _tower.x + 70, y: _tower.y, start_x: _tower.x + 70, start_y: _tower.y, distance: 70, progress: 0}];
		conquest_simulation_update(_controller, 1 / 60);
		_assert(_controller.armies[0].count == 6 && array_length(_controller.shots) == 1, "Tower missed hostile column");
		_controller.armies[0].owner = CONQUEST_OWNER.PLAYER;
		_tower.shot_timer = 0;
		conquest_simulation_update(_controller, 1 / 60);
		_assert(_controller.armies[0].count == 6, "Tower hit friendly column");
		_controller.armies = [];
		array_push(results, "PASS: live forge ownership, tower fire, no friendly fire");

		// Every campaign point has a valid playable layout; AI must make an opening move.
		var _map = _controller.campaign_map;
		var _rooms = [Battle_room, r_battle_02, r_battle_03, r_battle_04, r_battle_05, r_battle_06,
			r_battle_07, r_battle_08, r_battle_09, r_battle_10, r_battle_11];
		var _room_count = array_length(_rooms);
		for (var _index = 0; _index < _room_count; ++_index)
		{
			_map.active_battle_room = _rooms[_index];
			_controller.nodes = [];
			_controller.scenery = [];
			_controller.armies = [];
			conquest_level_prepare(_controller);
			_assert(_controller.level_index == _index, "Campaign difficulty mismatch");
			conquest_ai_update(_controller);
			_assert(array_length(_controller.armies) > 0, "AI did not expand on a campaign layout");
		}
		array_push(results, "PASS: all 11 campaign entries, three layouts, enemy expansion");

		// Marching survivors delay the result even after the faction loses its last building.
		var _count = array_length(_controller.nodes);
		for (var _index = 0; _index < _count; ++_index) _controller.nodes[_index].owner = CONQUEST_OWNER.PLAYER;
		_controller.armies = [{owner: CONQUEST_OWNER.ENEMY, count: 1}];
		conquest_result_update(_controller);
		_assert(_controller.phase == BATTLE_PHASE.BATTLE, "Premature victory with marching enemy");
		_controller.armies = [];
		conquest_result_update(_controller);
		_assert(_controller.phase == BATTLE_PHASE.VICTORY && array_contains(_map.captured_levels, o_level_01), "Victory failed to capture selected campaign level");
		test_phase = 2;
		test_wait_frames = 3;
		room_goto(r_world_map);
		exit;
	}
	if (test_phase == 2)
	{
		var _map = instance_find(o_world_map, 0);
		_assert(instance_number(o_world_map) == 1, "Map duplicated on return");
		_assert(!instance_exists(o_conquest), "Battle controller survived room exit");
		_assert(o_level_01.level_state == WORLD_MAP_LEVEL_STATE.CAPTURED, "Completed level not captured on map");
		_assert(o_level_02.level_state == WORLD_MAP_LEVEL_STATE.AVAILABLE && o_level_03.level_state == WORLD_MAP_LEVEL_STATE.AVAILABLE, "Campaign branches did not unlock");
		array_push(results, "PASS: victory, persistent progress, both campaign branches, room cleanup");
		_map.active_level = o_level_02;
		_map.active_battle_room = r_battle_02;
		_map.active_level_title = o_level_02.level_title;
		test_phase = 3;
		test_wait_frames = 3;
		room_goto(r_conquest);
		exit;
	}
	if (test_phase == 3)
	{
		var _controller = instance_find(o_conquest, 0);
		_assert(_controller.level_index == 1 && array_length(_controller.nodes) == 11, "Second battle did not load");
		var _count = array_length(_controller.nodes);
		for (var _index = 0; _index < _count; ++_index) _controller.nodes[_index].owner = CONQUEST_OWNER.ENEMY;
		_controller.armies = [{owner: CONQUEST_OWNER.PLAYER, count: 1}];
		conquest_result_update(_controller);
		_assert(_controller.phase == BATTLE_PHASE.BATTLE, "Premature defeat with marching survivors");
		_controller.armies = [];
		conquest_result_update(_controller);
		_assert(_controller.phase == BATTLE_PHASE.DEFEAT, "Defeat failed");
		_assert(!array_contains(_controller.campaign_map.captured_levels, o_level_02), "Defeat advanced campaign");
		test_phase = 4;
		test_wait_frames = 3;
		room_restart();
		exit;
	}
	if (test_phase == 4)
	{
		var _controller = instance_find(o_conquest, 0);
		_assert(_controller.phase == BATTLE_PHASE.BATTLE && !_controller.paused && array_length(_controller.armies) == 0, "Retry retained battle state");
		_assert(_controller.level_index == 1 && _controller.nodes[0].owner == CONQUEST_OWNER.PLAYER, "Retry changed level");
		array_push(results, "PASS: second battle, defeat, surviving columns, retry with fresh state");
		_controller.paused = true;
		test_phase = 6;
		test_wait_frames = 3;
		exit;
	}
	if (test_phase == 6)
	{
		var _controller = instance_find(o_conquest, 0);
		_assert(_controller.paused, "Pause overlay resumed without input");
		_controller.paused = false;
		_controller.phase = BATTLE_PHASE.DEFEAT;
		test_phase = 7;
		test_wait_frames = 3;
		exit;
	}
	if (test_phase == 7)
	{
		array_push(results, "PASS: live battlefield, pause and result drawing in the GameMaker runner");
		test_phase = 5;
	}
}
catch (_error)
{
	array_push(results, "FAIL: " + string(_error));
	test_phase = 5;
}
if (test_phase == 5)
{
	var _file = file_text_open_write("conquest_verification.txt");
	var _count = array_length(results);
	for (var _index = 0; _index < _count; ++_index)
	{
		file_text_write_string(_file, results[_index]);
		file_text_writeln(_file);
		show_debug_message(results[_index]);
	}
	file_text_close(_file);
	game_end();
}

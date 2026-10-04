// Menus, tutorials, and loss of window focus suspend avatar input.
if (!window_has_focus())
{
	exit;
}

if (variable_global_exists("pause") && global.pause)
{
	exit;
}

if (variable_global_exists("focus_window") && global.focus_window != FOCUS_WINDOW.NOONE)
{
	exit;
}

// Apply one slowdown multiplier and count down only while avatar gameplay is active.
var _step_seconds = 1 / max(1, room_speed);
var _move_speed_multiplier = 1;
var _corruption_slow_active = corruption_slow_remaining > 0;

// Check the starting cell before applying a previously earned movement bonus.
var _ground = noone;
var _started_on_taint = false;
if (instance_exists(o_corruption_grid))
{
	_ground = instance_find(o_corruption_grid, 0);
	var _start_cell_x = clamp(floor(x / _ground.cell_size), 0, _ground.grid_width - 1);
	var _start_cell_y = clamp(floor(y / _ground.cell_size), 0, _ground.grid_height - 1);
	_started_on_taint = ds_grid_get(_ground.corruption_grid, _start_cell_x, _start_cell_y) > 0
		&& ds_grid_get(_ground.saint_grid, _start_cell_x, _start_cell_y) <= 0;
}

// Scattered parts finish flying during the death lock; collection starts after it expires.
var _death_locked = death_lock_remaining > 0;
death_lock_remaining = max(0, death_lock_remaining - _step_seconds);

if (is_disassembled)
{
	_move_speed_multiplier = BALANCE_PLAYER_HEAD_MOVE_SPEED_MULTIPLIER;
}
else if (_corruption_slow_active)
{
	_move_speed_multiplier = BALANCE_PLAYER_CORRUPTION_MOVE_SPEED_MULTIPLIER;
	corruption_slow_remaining = max(0, corruption_slow_remaining - _step_seconds);
}
else if (_started_on_taint && taint_run_elapsed >= BALANCE_PLAYER_TAINT_RUN_DELAY_SECONDS)
{
	_move_speed_multiplier = BALANCE_PLAYER_TAINT_RUN_SPEED_MULTIPLIER;
}

// Taunting limits movement to a tenth of normal speed without stacking ground slowdown.
var _is_taunting = player_taunt_is_active();
if (_is_taunting)
{
	_move_speed_multiplier = min(_move_speed_multiplier, BALANCE_PLAYER_TAUNT_MOVE_SPEED_MULTIPLIER);
}

// Normalize diagonals so movement has the same speed in every direction.
var _previous_x = x;
var _previous_y = y;
// Keep the visual tilt from changing the movement bounds at the room edges.
image_angle = 0;
var _input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var _input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));
var _input_length = point_distance(0, 0, _input_x, _input_y);

if (!_death_locked && _input_length > 0)
{
	var _move_distance = move_speed * _move_speed_multiplier * _step_seconds;
	var _move_x = (_input_x / _input_length) * _move_distance;
	var _move_y = (_input_y / _input_length) * _move_distance;

	// Face movement before collision checks so they use the final sprite orientation.
	if (_input_x != 0)
	{
		image_xscale = sign(_input_x);
	}

	// Small axis-separated steps prevent tunneling and allow sliding along walls.
	var _collision_step_size = 1;
	var _move_steps = max(1, ceil(max(abs(_move_x), abs(_move_y)) / _collision_step_size));
	var _step_x = _move_x / _move_steps;
	var _step_y = _move_y / _move_steps;
	for (var _move_step = 0; _move_step < _move_steps; ++_move_step)
	{
		if (_step_x != 0 && !place_meeting(x + _step_x, y, o_wall_parent))
		{
			x += _step_x;
		}
		if (_step_y != 0 && !place_meeting(x, y + _step_y, o_wall_parent))
		{
			y += _step_y;
		}
	}

	// Keep the sprite inside the room after resolving wall collisions.
	x = clamp(x, x - bbox_left, room_width - (bbox_right - x));
	y = clamp(y, y - bbox_top, room_height - (bbox_bottom - y));
}

// Taunting uses the walking tilt at double tempo, including when standing still.
var _is_walking = x != _previous_x || y != _previous_y;

if (_is_walking || _is_taunting)
{
	var _sway_speed_multiplier = _is_taunting ? BALANCE_PLAYER_TAUNT_ANIMATION_MULTIPLIER : _move_speed_multiplier;
	walk_sway_timer += _step_seconds * _sway_speed_multiplier;

	if (walk_sway_timer >= walk_sway_half_time)
	{
		walk_sway_timer -= walk_sway_half_time;
		walk_sway_direction *= -1;
	}

	image_angle = walk_sway_angle * walk_sway_direction;
}
else
{
	walk_sway_timer = 0;
	walk_sway_direction = 1;
}

// Advance and collect the three body parts before checking ordinary ground effects.
var _was_disassembled = is_disassembled;
if (is_disassembled)
{
	player_body_parts_update(_step_seconds, !_death_locked);
}

// Infect clean ground at the skeleton's feet, including while standing still.
if (instance_exists(_ground))
{
	var _cell_x = clamp(floor(x / _ground.cell_size), 0, _ground.grid_width - 1);
	var _cell_y = clamp(floor(y / _ground.cell_size), 0, _ground.grid_height - 1);
	var _corruption = ds_grid_get(_ground.corruption_grid, _cell_x, _cell_y);
	var _saint = ds_grid_get(_ground.saint_grid, _cell_x, _cell_y);

	// Count only real movement entirely on existing Taint after all recovery frames.
	if (_is_walking && !_was_disassembled && !is_disassembled && !_corruption_slow_active
		&& _started_on_taint && _corruption > 0 && _saint <= 0)
	{
		taint_run_elapsed = min(BALANCE_PLAYER_TAINT_RUN_DELAY_SECONDS, taint_run_elapsed + _step_seconds);
	}
	else
	{
		taint_run_elapsed = 0;
	}

	// Only a complete skeleton heals, starting on the frame after reconstruction.
	if (!_was_disassembled && !is_disassembled && _corruption > 0 && _saint <= 0)
	{
		hp = min(max_hp, hp + BALANCE_PLAYER_TAINT_HEAL_PER_SECOND * _step_seconds);
	}

	if (_corruption <= 0)
	{
		// Infect only this cell below the full-corruption threshold that spreads to neighbors.
		var _cell_radius = 1;
		var _corruption_amount = _ground.passive_spread_limit;
		_ground.corrupt_circle(x, y, _cell_radius, _corruption_amount);

		// Emit feedback only after actual infection, not a blocked wall or Saint attempt.
		if (ds_grid_get(_ground.corruption_grid, _cell_x, _cell_y) > _corruption)
		{
			var _cell_left = _cell_x * _ground.cell_size;
			var _cell_top = _cell_y * _ground.cell_size;
			var _cell_width = min(_ground.cell_size, room_width - _cell_left);
			var _cell_height = min(_ground.cell_size, room_height - _cell_top);
			player_corruption_effect_create(_cell_left, _cell_top, _cell_width, _cell_height, layer);

			if (!is_disassembled)
			{
				corruption_slow_remaining = BALANCE_PLAYER_CORRUPTION_SLOW_DURATION_SECONDS;
				taint_run_elapsed = 0;
			}
		}
	}
}
else
{
	taint_run_elapsed = 0;
}

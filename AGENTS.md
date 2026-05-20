# GameMaker Project Rules

These rules are mandatory for all GameMaker work in this project. When in doubt, prefer the official GameMaker terminology and recommendations from:

- https://manual-ru.yoyogames.com/
- https://manual.yoyogames.com/Additional_Information/Best_Practices_When_Programming.htm

## Priorities

1. Maximum readability.
2. Ease of use and navigation: entities live in obvious places, are not scattered across many objects or variables, and inheritance is used where it improves clarity.
3. Optimization.

## Naming

- Use English names only.
- Use `snake_case` for variables, functions, scripts, and resource names.
- Object names start with `o_`, for example `o_game_controller`.
- Sprite names start with `s_`, for example `s_core`.
- Temporary local variables always start with `_`, for example `var _x = 2;`.
- Boolean values must be written as `true` or `false`, not `1` or `0`.
- Names must describe what the entity does or stores.
- Avoid unclear abbreviations.
- Enums are written in uppercase:

```gml
enum TURRET
{
	GREEN,
	RED
}
```

## Code Style

- Follow the general GameMaker documentation style.
- Use Allman indentation style.
- Use tabs for left indentation.
- Use whitespace around operators and separators:

```gml
for (var _i = 0; _i < 100; ++_i)
{
	_array[_i] = 0;
}
```

- Semicolons are allowed and preferred for consistency.
- Keep complex expressions readable by splitting them into local variables.
- Avoid magic numbers. Most numbers used in code must be assigned to a named variable first, with a short comment when useful.

```gml
var _multiplier = 2; // Value multiplier.
x = _multiplier * y;
```

## Comments

- Add comments when they make the code easier to understand later.
- Each meaningful code block should have a short comment before it.
- In `Create` events, comment important instance variables: where they are used and what they mean.
- Do not comment extremely obvious code.
- Comments should be concise, clear, and informative.

## Variables

### Local Variables

- If a value does not need to persist across frames or events, declare it with `var`.
- Local variables can be declared in any event.
- Temporary local variable names always start with `_`.

### Instance Variables

- Instance variables are the default choice for persistent object state.
- Declare instance variables in the `Create` event.

### Global Variables

- Use as few global variables as possible.
- If a variable is used by no more than two objects, prefer an instance variable and access it through the relevant object.
- Declare global variables only in the `Create` event of `o_game_controller`.
- Do not declare global variables in objects that may have multiple instances, such as turrets or buildings.
- If a global variable is used multiple times in one object, copy its value to a local or instance variable first because global access is more expensive.

## Enums And Macros

- Declare enums and macros in the `enums` script.
- The `enums` script is expected to run before any object `Create` event.
- Colors must be defined through macros. If a color is missing, add it to the `enums` script instead of hardcoding it.

## Timers

- Timers must account for possible `room_speed` changes.
- One second is `room_speed`.

```gml
alarm[0] = 5 * room_speed;
```

## Data Structures And Arrays

- For 1D lists that need sorting or many list operations, use `ds_list`.
- After creating a `ds_list`, make sure its destruction is planned with `ds_list_destroy()` when it is no longer needed.
- Arrays use less memory, so prefer arrays when no special list operations are needed.
- Arrays may be cleared by assigning `0`:

```gml
items_array = 0;
```

- Modern GameMaker arrays have many useful functions, so both arrays and `ds_list` are acceptable when the choice is justified.

## Safety Checks

- Before accessing an instance or object, check that it exists:

```gml
if (instance_exists(_target_instance))
{
	// Use _target_instance here.
}
```

- If variable initialization is uncertain, check it with `variable_instance_exists()`.

## Instance Creation

- Create instances with `instance_create_layer()`.
- Do not use `instance_create_depth()` because this project uses layers and should avoid direct depth management.

## Events

- Main events are `Create`, `Step`, `Draw`, and `Draw GUI`.
- Minimize use of `Begin Step`, `End Step`, `Begin Draw`, and `End Draw`.
- Draw events should contain only code related to drawing whenever possible.
- Keep `Step` and `Draw` especially lean because they run every frame.

## Draw State

- When changing draw alignment, alpha, or color, always restore defaults after drawing.
- Project defaults:

```gml
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
```

## Scripts And Functions

- Each script must start with `/// @description` describing what it does.
- Add parameter descriptions when arguments are not obvious.
- Prefer one function per script.
- Prefer folders over placing many unrelated functions in one script.
- Constructor scripts must include `constructor` at the end of the name, for example `levels_constructor`.
- A script/function should ideally be callable from any object. If it has limitations, document them.
- A function must do one clear task, and its name must reflect that task.
- Function names should resemble built-in GML naming patterns where applicable.
- If a script contains a single function, the script name and function name must match.
- Related functions must share a common prefix.

Example: prefer `mp_grid_add_block`, `mp_grid_clear_block`, `mp_grid_update` over unrelated names such as `add_block_to_grid`, `clear_block`, and `update_grid`.

## Sprites

- Imported sprites should use `30` FPS in sprite settings.
- Control animation speed in code with `image_speed`.
- In most cases, use `Rectangle` collision masks.
- Use `Rectangle with rotation` or `Ellipse` only when needed.
- Avoid precise collisions unless there is a strong reason.

## While Loops

- Avoid `while` whenever possible.
- Prefer `for` loops in almost all cases.
- If `while` is unavoidable, add a safety counter to prevent infinite loops:

```gml
var _while_counter = 0; // Infinite loop guard.

while (!place_meeting(x, y + 1, _tilemap_id))
{
	y++;
	_while_counter++;

	if (_while_counter > 100)
	{
		break;
	}
}
```

## Optimization

- Do not make functions do more work than needed.
- Optimization is most important in `Step` and `Draw`.
- Reduce total active object count where possible.
- Avoid unnecessary sprite and graphics drawing.
- Minimize collision checks.
- Minimize active code that runs every frame.
- Put cheap and likely-false conditions first in compound checks because GameMaker evaluates from left to right.
- Avoid function calls in loop conditions; calculate the value before the loop.
- Ask whether frame-by-frame checks can run every few frames instead.

```gml
fixed_update++;

if (fixed_update mod 10 == 0)
{
	// Code that runs every 10 frames.
}
```

- Minimize global variable access in `Step`.
- Destroy unused data structures and clear unused data.
- Collision cost guideline: `place_` functions are usually cheapest, `instance_` functions are medium, `collision_` and `point_` checks are more expensive.
- Temporarily deactivate instances that are not visible or active when a shared camera/deactivation system exists.
- Things that only draw and do not run code should not necessarily be instances; consider drawing them from another system.

Additional optimization references:

- https://gamemaker.io/ru/blog/forager-optimization-in-gamemaker
- https://help.gamemaker.io/hc/en-us/articles/216754778-Optimizing-Your-Games


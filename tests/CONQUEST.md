# Conquest prototype

The project still starts in `r_world_map`. ATTACK copies the selected title and original battle-room identifier into the persistent map, then opens `r_conquest`. Victory captures that selected point through the existing campaign graph. Defeat and retreat do not advance it. The legacy battle rooms remain available as source material but ATTACK now runs conquest.

`o_conquest` owns all encounter state. Buildings and travelling armies are structs, with no per-soldier instances. Ashen Crossing is a seven-building road-warfare experiment. Missions 2–11 retain the three classic layouts with direct movement for comparison.

## Ashen Crossing: road warfare

The middle road crosses a neutral fortified tower. The longer lower road runs through a recruiting hamlet and a forge. Orders may cross friendly buildings, but cannot pass through neutral or enemy buildings. Capturing the crossing opens a shorter route; losing an intermediate building cuts the supply line. A column already on the road stops and besieges a newly hostile waypoint.

Automatic routes retain a configurable home reserve (15 by default), send surplus in waves at least six seconds apart, and wait for at least five troops above reserve. Routes pause during upgrades, sieges, or a cut road; reopening a friendly path resumes them. Supply cycles are rejected. Ownership loss clears the captured building's orders. Troops already marching finish their orders when a route is cancelled.

Columns move at 65 pixels/second, about 5–8 seconds on most links; the long lower link takes about eight seconds. Recruitment runs at half the classic rate. Opposing columns stop on the same road and exchange simultaneous casualties. Hostile buildings require a sustained siege and three uncontested seconds after their defenders are gone. Splitting an equal attacking force into several packets does not increase siege damage. Besieged settlements stop recruiting and cannot dispatch or begin upgrades.

The enemy uses the same roads, dispatch cooldown and siege rules, and can establish rear supply routes. Its opening delay is 14 seconds, with a strategic decision every six seconds.

Hollow Fields (mission 2) retains its easier balance: the player starts with 60 troops against 36, the enemy first acts after 10 seconds and then every 3.2 seconds, and the player's inner flank has a settlement matching the enemy's instead of an extra forge. The centre retains one contested forge.

- Settlements recruit up to their level's capacity. Reinforcements can exceed it.
- Towers damage hostile columns within range and have a defensive bonus.
- Forges add strength to their current faction's attacking and defending troops.
- Upgrades cost 20 / 40 troops, retain one defender, and suspend recruitment and dispatch for three seconds.
- Capturing a building cancels its upgrade and reduces its level by one, down to level one.
- A faction loses after its last building **and** last travelling column are gone.

Use the existing sprites and palette; no generated visual assets are required. Heroes, spells, morale, building conversion and the strategic cannon are outside this experiment.

## Controls

LMB selects a friendly building; drag it onto any other building to send troops. Click an enemy/neutral target or use RMB to send the current selection. Shift-click adds buildings; drag empty ground to box-select; A selects all. Keys 1–4 choose 25/50/75/100%. U upgrades the sole selected building. Space/Escape pauses. The pause/result panel offers the campaign map and retry (R).

In Ashen Crossing, orders default to automatic routes. T toggles AUTO ROUTE / ONE WAVE. Z/C decreases/increases the selected buildings' reserve by five (0–60); X stops their routes. The bottom panel exposes the same controls. In ONE WAVE mode, keys 1–4 choose the share; a successful manual order replaces that source's automatic route. Reserve applies only to automatic waves. Pausing blocks simulation and orders.

## Editing

- `scripts/enums/enums.gml`: `BALANCE_CONQUEST_*` tuning and ownership/type enums.
- `scripts/conquest_level_prepare`: starting layouts and campaign difficulty.
- `scripts/conquest_road_level_prepare`: the experimental map and its explicit road links.
- `scripts/conquest_path_get`, `conquest_routes_update`, and `conquest_road_*_update`: graph traversal, standing orders and road combat.
- `scripts/conquest_ai_update`: enemy decisions, using normal dispatch and upgrade rules.
- `scripts/conquest_input_update` and `scripts/conquest_hud_draw`: controls and their shared 1920×1080 reference canvas.

## Verification

Run `node tests/conquest_input.cjs` for input regression checks. Run `node tests/prepare_conquest_runtime.cjs` to create the ignored `conquest_runtime_verification.yyp`. Compile this fixture with the installed GameMaker Windows VM (`Windows Compile` in Igor), then run its generated `.win` with the runner. It writes `conquest_verification.txt` to the game's save directory and exits. The fixture exercises actual room transitions, all layouts, combat, towers, upgrades, pause, results, progress and retry, and lets battlefield/pause/result Draw events run.

The fixture includes `tests/conquest_road_runtime.gml`: graph restrictions, alternate paths, supply loops, reserves, repeated waves, cut/restored roads, changed waypoints, road combat, siege timing and packet-independent damage. It also runs a 45-second opening against the real AI with only two standing orders. `conquest_roads_start.png`, `conquest_roads_battle.png`, and `conquest_roads_pause.png` are real runner captures saved alongside the verification report.

`tests/setup_conquest_resources.cjs` is an idempotent metadata registration helper; ordinary GML edits do not require it.

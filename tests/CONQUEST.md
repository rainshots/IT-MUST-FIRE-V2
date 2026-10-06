# Conquest prototype

The project still starts in `r_world_map`. ATTACK copies the selected title and original battle-room identifier into the persistent map, then opens `r_conquest`. Victory captures that selected point through the existing campaign graph. Defeat and retreat do not advance it. The legacy battle rooms remain available as source material but ATTACK now runs conquest.

`o_conquest` owns all encounter state. Buildings and travelling armies are structs, with no per-soldier instances or collision checks. Three layouts cover the eleven campaign points; enemy starting garrisons increase along the route. Buildings can be reached directly from any other building. Paths are decorative.

Hollow Fields (mission 2) is a gentler exception: the player starts with 60 troops against 36, the enemy first acts after 10 seconds and then every 3.2 seconds, and the player's inner flank has a settlement matching the enemy's instead of an extra forge. The centre retains one contested forge. Other missions keep their original balance.

- Settlements recruit up to their level's capacity. Reinforcements can exceed it.
- Towers damage hostile columns within range and have a defensive bonus.
- Forges add strength to their current faction's attacking and defending troops.
- Upgrades cost 20 / 40 troops, retain one defender, and suspend recruitment and dispatch for three seconds.
- Capturing a building cancels its upgrade and reduces its level by one, down to level one.
- A faction loses after its last building **and** last travelling column are gone.

Use the existing sprites and palette; no generated visual assets are required. The prototype does not implement heroes, spells, morale, building conversion, or fighting between moving columns.

## Controls

LMB selects a friendly building; drag it onto any other building to send troops. Click an enemy/neutral target or use RMB to send the current selection. Shift-click adds buildings; drag empty ground to box-select; A selects all. Keys 1–4 choose 25/50/75/100%. U upgrades the sole selected building. Space/Escape pauses. The pause/result panel offers the campaign map and retry (R).

## Editing

- `scripts/enums/enums.gml`: `BALANCE_CONQUEST_*` tuning and ownership/type enums.
- `scripts/conquest_level_prepare`: starting layouts and campaign difficulty.
- `scripts/conquest_ai_update`: enemy decisions, using normal dispatch and upgrade rules.
- `scripts/conquest_input_update` and `scripts/conquest_hud_draw`: controls and their shared 1920×1080 reference canvas.

## Verification

Run `node tests/conquest_input.cjs` for input regression checks. Run `node tests/prepare_conquest_runtime.cjs` to create the ignored `conquest_runtime_verification.yyp`. Compile this fixture with the installed GameMaker Windows VM (`Windows Compile` in Igor), then run its generated `.win` with the runner. It writes `conquest_verification.txt` to the game's save directory and exits. The fixture exercises actual room transitions, all layouts, combat, towers, upgrades, pause, results, progress and retry, and lets battlefield/pause/result Draw events run.

`tests/setup_conquest_resources.cjs` is an idempotent metadata registration helper; ordinary GML edits do not require it.

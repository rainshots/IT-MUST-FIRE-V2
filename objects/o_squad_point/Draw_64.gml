if (!squad_point_selection_open
	|| global.focus_window != FOCUS_WINDOW.SQUAD_POINT_SELECTION
	|| !variable_global_exists("squad_point_selection_source")
	|| global.squad_point_selection_source != id)
{
	exit;
}

var _layout = squad_point_window_layout_get();
var _mouse_x = device_mouse_x_to_gui(0);
var _mouse_y = device_mouse_y_to_gui(0);
var _hovered_choice_index = squad_point_choice_hover_index_get(_mouse_x, _mouse_y);
var _previous_font = draw_get_font();

if (variable_global_exists("ui_font") && font_exists(global.ui_font))
{
	draw_set_font(global.ui_font);
}

// Dim the world behind the modal selection window.
draw_set_alpha(0.58);
draw_set_color(c_black);
draw_rectangle(0, 0, _layout.gui_width, _layout.gui_height, false);

draw_set_alpha(1);
draw_set_color(COLOR_HUD_BACKGROUND);
draw_rectangle(
	_layout.x,
	_layout.y,
	_layout.x + _layout.width,
	_layout.y + _layout.height,
	false
);
draw_set_color(c_white);
draw_rectangle(
	_layout.x,
	_layout.y,
	_layout.x + _layout.width,
	_layout.y + _layout.height,
	true
);

draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(COLOR_HUD_TEXT);
draw_text(_layout.x + (_layout.width * 0.5), _layout.y + 24, "Summon Squad");

draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
draw_text(
	_layout.x + (_layout.width * 0.5),
	_layout.y + 54,
	"Choose a squad. Recruitment requires "
		+ string(BALANCE_SQUAD_EVENT_CULTIST_COUNT)
		+ " Cultist and costs that Cultist "
		+ string(BALANCE_SQUAD_EVENT_CULTIST_HP_COST)
		+ " HP."
);
draw_text(
	_layout.x + (_layout.width * 0.5),
	_layout.y + 78,
	"Hover a unit to inspect its characteristics."
);

for (var _choice_index = 0; _choice_index < array_length(squad_point_choices); ++_choice_index)
{
	var _choice = squad_point_choices[_choice_index];
	var _rect = squad_point_choice_rect_get(_choice_index);
	var _card_x = _rect[0];
	var _card_y = _rect[1];
	var _is_hovered = _choice_index == _hovered_choice_index;
	var _unit_sprite = object_get_sprite(_choice.unit_object);
	var _unit_name = instance_exists(o_hud)
		? o_hud.hud_unit_display_name_get(_choice.unit_object)
		: object_get_name(_choice.unit_object);

	draw_set_alpha(0.86);
	draw_set_color(c_black);
	draw_rectangle(
		_card_x,
		_card_y,
		_card_x + _rect[2],
		_card_y + _rect[3],
		false
	);

	draw_set_alpha(1);
	draw_set_color(_is_hovered ? COLOR_PROJECTILE_SUMMON : c_white);
	draw_rectangle(
		_card_x,
		_card_y,
		_card_x + _rect[2],
		_card_y + _rect[3],
		true
	);

	if (sprite_exists(_unit_sprite))
	{
		var _sprite_width = max(1, sprite_get_width(_unit_sprite));
		var _sprite_height = max(1, sprite_get_height(_unit_sprite));
		var _sprite_scale = min(
			squad_point_card_sprite_size / _sprite_width,
			squad_point_card_sprite_size / _sprite_height
		);
		var _sprite_x = _card_x + (_rect[2] * 0.5)
			+ ((sprite_get_xoffset(_unit_sprite) - (_sprite_width * 0.5)) * _sprite_scale);
		var _sprite_y = _card_y + 66
			+ ((sprite_get_yoffset(_unit_sprite) - (_sprite_height * 0.5)) * _sprite_scale);

		draw_sprite_ext(
			_unit_sprite,
			0,
			_sprite_x,
			_sprite_y,
			_sprite_scale,
			_sprite_scale,
			0,
			c_white,
			1
		);
	}

	// Every squad card shows both its representative unit and exact formation size.
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_card_x + (_rect[2] * 0.5), _card_y + 122, _choice.squad_name);
	draw_set_color(COLOR_PROJECTILE_SUMMON);
	draw_text(
		_card_x + (_rect[2] * 0.5),
		_card_y + 148,
		"x" + string(_choice.unit_count) + " " + _unit_name
	);

	draw_set_halign(fa_left);
	draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
	draw_text_ext(
		_card_x + 16,
		_card_y + 176,
		_choice.card_description,
		16,
		_rect[2] - 32
	);

	draw_set_halign(fa_center);
	draw_set_color(_is_hovered ? COLOR_PROJECTILE_SUMMON : COLOR_HUD_TEXT);
	draw_text(
		_card_x + (_rect[2] * 0.5),
		_card_y + _rect[3] - 24,
		string(BALANCE_SQUAD_EVENT_CULTIST_COUNT)
			+ " Cultist   -"
			+ string(BALANCE_SQUAD_EVENT_CULTIST_HP_COST)
			+ " HP"
	);
}

draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
draw_set_halign(fa_center);
draw_text(
	_layout.x + (_layout.width * 0.5),
	_layout.y + _layout.height - 26,
	"ESC to close"
);

// Reuse the existing player-unit card for complete stats and matchup details.
if (_hovered_choice_index >= 0
	&& _hovered_choice_index < array_length(squad_point_choices)
	&& instance_exists(o_game_controller))
{
	var _tooltip_x = _mouse_x > _layout.gui_width * 0.5
		? _layout.x - 278
		: _layout.x + _layout.width + 18;
	var _tooltip_y = _layout.y + 46;
	var _hovered_choice = squad_point_choices[_hovered_choice_index];

	o_game_controller.player_unit_object_stats_card_draw(
		_hovered_choice.unit_object,
		_tooltip_x,
		_tooltip_y,
		_previous_font
	);
}

draw_set_font(_previous_font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

// Pick one available meat sprite variation.
var _meat_sprites = array_create(0);
var _meat_sprite_01 = asset_get_index("s_meat_01");
var _meat_sprite_02 = asset_get_index("s_meat_02");

if (sprite_exists(_meat_sprite_01))
{
	array_push(_meat_sprites, _meat_sprite_01);
}

if (sprite_exists(_meat_sprite_02))
{
	array_push(_meat_sprites, _meat_sprite_02);
}

if (array_length(_meat_sprites) > 0)
{
	sprite_index = _meat_sprites[irandom(array_length(_meat_sprites) - 1)];
}
else
{
	// Visible fallback for builds where the meat sprites were not saved into the project yet.
	sprite_index = s_flesh_icon;
}

// Random horizontal flip gives repeated drops more visual variety.
image_xscale = choose(-1, 1);
image_alpha = 1;
image_speed = 0;
y_sort_enabled = true;

// Morning cleanup fades meat away before destroying it.
is_fading_out = false;
fade_timer = 0;
fade_time = BALANCE_MEAT_MORNING_FADE_TIME * room_speed;

fade_out_start = function()
{
	is_fading_out = true;
	fade_timer = 0;
};

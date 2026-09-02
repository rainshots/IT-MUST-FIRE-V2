// Aura instances follow one unit and provide a reusable tintable effect marker.
aura_owner = noone;
aura_effect = UNHOLY_TRAIT.NONE;
aura_color = c_white;
aura_alpha = 1;
aura_scale_x = 1;
aura_scale_y = 1;
aura_offset_x = 0;
aura_offset_y = 0;
aura_pulse_amount = 0;
aura_pulse_speed = 0;

// Resolve by name so the generic aura object remains safe while art is being imported.
aura_sprite = asset_get_index("s_aura_01");

if (sprite_exists(aura_sprite))
{
	sprite_index = aura_sprite;
	image_speed = 1;
}

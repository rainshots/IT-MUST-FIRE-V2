varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
	vec4 texture_color = texture2D(gm_BaseTexture, v_vTexcoord);
	float output_alpha = texture_color.a * v_vColour.a;

	gl_FragColor = vec4(1.0, 1.0, 1.0, output_alpha);
}

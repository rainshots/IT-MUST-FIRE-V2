// Runtime fonts belong to this window and must be released with it.
if (font_exists(jobs_title_font))
{
	font_delete(jobs_title_font);
}

if (font_exists(jobs_description_font))
{
	font_delete(jobs_description_font);
}

if (font_exists(jobs_button_font))
{
	font_delete(jobs_button_font);
}

if (font_exists(jobs_hp_font))
{
	font_delete(jobs_hp_font);
}

if (font_exists(jobs_show_font))
{
	font_delete(jobs_show_font);
}

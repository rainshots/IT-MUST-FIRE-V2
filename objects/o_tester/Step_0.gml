// F9 opens the automated balance test room from normal gameplay.
if (keyboard_check_pressed(vk_f9))
{
	room_goto(r_balance_test);
	exit;
}

// Tester should not spawn objects while gameplay input is focused elsewhere.
if (global.pause || global.focus_window != FOCUS_WINDOW.NOONE)
{
	exit;
}

global.balance_test_active = false;
global.balance_test_manual_tick_active = false;

if (balance_test_camera != -1)
{
	camera_destroy(balance_test_camera);
}

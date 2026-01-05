public StatsMenu(id)
{
	new menu = menu_create("\r[FWO] \d- \wStatus Menu", "StatsMenu_Handler");
	
	new szItem[64];

	formatex(szItem, sizeof(szItem) - 1, "\wStats %s", g_bShowStats[id] ? "\y[ON]" : "\r[OFF]");
	menu_additem(menu, szItem, "1");

	formatex(szItem, sizeof(szItem) - 1, "\wPre-Strafe %s", g_bShowPre[id] ? "\y[ON]" : "\r[OFF]");
	menu_additem(menu, szItem, "2");

	formatex(szItem, sizeof(szItem) - 1, "\wDisplay Settings");
	menu_additem(menu, szItem, "3");

	menu_setprop(menu, MPROP_EXITNAME, "Exit");
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public StatsMenu_Handler(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new data[6], access, callback;
	menu_item_getinfo(menu, item, access, data, charsmax(data), _, _, callback);
	new choice = str_to_num(data);

	switch(choice){
		case 1: g_bShowStats[id] = !g_bShowStats[id];
		case 2: g_bShowPre[id] = !g_bShowPre[id];
		case 3: {
			menu_destroy(menu);
			SettingsMenu(id);
			return PLUGIN_HANDLED;
		}
	}

	menu_destroy(menu);
	StatsMenu(id);
	return PLUGIN_HANDLED;
}

public SettingsMenu(id)
{
	new menu = menu_create("\r[FWO] \d- \wDisplay Options", "SettingsMenu_Handler");
	
	new szItem[64];
	
	formatex(szItem, sizeof(szItem) - 1, "\wStrafes %s", g_bShowStrafes[id] ? "\y[ON]" : "\r[OFF]");
	menu_additem(menu, szItem, "1");
	
	formatex(szItem, sizeof(szItem) - 1, "\wSync %s", g_bShowSync[id] ? "\y[ON]" : "\r[OFF]");
	menu_additem(menu, szItem, "2");
	
	formatex(szItem, sizeof(szItem) - 1, "\wGain %s", g_bShowGain[id] ? "\y[ON]" : "\r[OFF]");
	menu_additem(menu, szItem, "3");

	formatex(szItem, sizeof(szItem) - 1, "\wFrames %s", g_bShowFrames[id] ? "\y[ON]" : "\r[OFF]");
	menu_additem(menu, szItem, "4");
	
	formatex(szItem, sizeof(szItem) - 1, "\wList %s", g_bShowStrafeList[id] ? "\y[ON]" : "\r[OFF]");
	menu_additem(menu, szItem, "5");

	formatex(szItem, sizeof(szItem) - 1, "\wConsole Info %s", g_bShowConsole[id] ? "\y[ON]" : "\r[OFF]");
	menu_additem(menu, szItem, "6");

	menu_setprop(menu, MPROP_EXITNAME, "Back");
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public SettingsMenu_Handler(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		StatsMenu(id);
		return PLUGIN_HANDLED;
	}

	new data[6], access, callback;
	menu_item_getinfo(menu, item, access, data, charsmax(data), _, _, callback);
	new choice = str_to_num(data);

	switch(choice){
		case 1: g_bShowStrafes[id] = !g_bShowStrafes[id];
		case 2: g_bShowSync[id] = !g_bShowSync[id];
		case 3: g_bShowGain[id] = !g_bShowGain[id];
		case 4: g_bShowFrames[id] = !g_bShowFrames[id];
		case 5: g_bShowStrafeList[id] = !g_bShowStrafeList[id];
		case 6: g_bShowConsole[id] = !g_bShowConsole[id];
	}

	menu_destroy(menu);
	SettingsMenu(id);
	return PLUGIN_HANDLED;
}
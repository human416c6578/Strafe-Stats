#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <cromchat2>
#include <strafe_globals>

#define PLUGIN "Stats"
#define VERSION "1.0"
#define AUTHOR "MrShark45 & ftl~"

#define MAX_STRAFES 33

forward fwPlayerStrafe(id, strafes, sync, strafesSync[], strafeLen, frames, goodFrames, Float:gain, overlaps);

public plugin_init(){
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_forward( FM_PlayerPreThink, "fwdPreThink", 0 );

	register_clcmd("say /stats", "toggle_stats");
	register_clcmd("say /statsmenu", "stats_menu");

	register_clcmd("say /pre", "toggle_pre");
	register_clcmd("say /showpre", "toggle_pre");
	register_clcmd("say /prestrafe", "toggle_pre");

	g_iMainHudSync = CreateHudSyncObj();
	g_iStrafeHudSync = CreateHudSyncObj();
	
	//Chat prefix
	//CC_SetPrefix("&x04[FWO]");
}

public plugin_natives(){
	register_library("strafe_stats");

	register_native("get_user_sync", "native_get_user_sync");

	register_native("get_user_strafes", "native_get_user_strafes");

	register_native("display_stats", "native_display_stats");

	register_native("get_bool_stats", "native_get_bool_stats");
	register_native("toggle_stats", "native_toggle_stats");

	register_native("get_bool_pre", "native_get_bool_pre");
	register_native("toggle_pre", "native_toggle_pre");
}

public native_get_user_sync(NumParams) {
	new id = get_param(1);

	new sync = g_iNativeSync[id];
	g_iNativeSync[id] = 0;
	
	return sync;
}

public native_get_user_strafes(NumParams) {
	new id = get_param(1);
	
	new strafes = g_iNativeStrafes[id];
	g_iNativeStrafes[id] = 0;
	
	return strafes;
}

public native_display_stats(NumParams) {
	
	new id = get_param(1);
	new strafes = get_param(2);
	new sync = get_param(3);

	for(new i = 1; i < 33; i++)
	{
		if(!is_user_connected(i) || is_user_alive(i) || !g_bShowStats[i] ) continue;
		
		if( pev(i, pev_iuser2) == id )
		{
			set_hudmessage(0, 100, 255, -1.0, 0.6, 0, 0.0, 2.0, 0.2, 0.2, -1);
			ShowSyncHudMsg(i, g_iMainHudSync, "Strafes: %i^nSync: %i%%", strafes, sync);
		}
	}
}

public native_get_bool_stats(NumParams){
	new id = get_param(1);
	return g_bShowStats[id];
}

public native_toggle_stats(NumParams){
	new id = get_param(1);
	toggle_stats(id);
}

public native_get_bool_pre(NumParams){
	new id = get_param(1);
	return g_bPreStats[id];
}

public native_toggle_pre(NumParams){
	new id = get_param(1);
	toggle_pre(id);
}

public client_putinserver(id){ 
	g_bShowStats[id] = false; // Set to false so stats are OFF by default when the player joins. The player must enable it manually.
	g_bPreStats[id] = false; // Set to false so Prestrafe is OFF by default (bhop standard). To have it enabled by default (speedrun standard), change to true.
	g_bShowStrafes[id] = true;
	g_bShowSync[id] = true;
	g_bShowGain[id] = true;
	g_bShowStrafeList[id] = true;
	g_bShowFrames[id] = true;
	g_bShowConsole[id] = true;
}

public stats_menu(id)
{
	new menu = menu_create("\r[FWO] \d- \wDisplay Options", "menu_handler");
	
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

	menu_setprop(menu, MPROP_EXITNAME, "Exit");
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public menu_handler(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
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
	stats_menu(id);
	return PLUGIN_HANDLED;
}

public toggle_stats(id){
	g_bShowStats[id] = !g_bShowStats[id];
	//CC_SendMessage(id, "&x01Stats %s", g_bShowStats[id] ? "&x06ON" : "&x07OFF");
}

public toggle_pre(id){
	g_bPreStats[id] = !g_bPreStats[id];
	//CC_SendMessage(id, "&x01ShowPre %s", g_bPreStats[id] ? "&x06ON" : "&x07OFF");
}

public fwPlayerStrafe(id, strafes, sync, strafesSync[], strafeLen, frames, goodFrames, Float:gain, overlaps){
	if(is_user_bot(id)) return;
	g_iNativeStrafes[id] = strafes;
	g_iNativeSync[id] = sync;

	if(strafes < 1) return;
	
	if(!g_bShowStats[id]) return;

	// Side list
	if(g_bShowStrafeList[id]){
		static szStrafesInfo[32 * MAX_STRAFES], iLen;
		szStrafesInfo[0] = 0; iLen = 0;
		for(new i = 0; i < strafeLen && i < MAX_STRAFES; i++)
		{
			iLen += formatex(szStrafesInfo[iLen], charsmax(szStrafesInfo) - iLen, "Strafe: %i^tSync: %i^n", i + 1, strafesSync[i]);
		}
		
		set_hudmessage(200, 22, 22, 0.77, 0.4, 0, 0.0, 2.0, 0.2, 0.2, 4);
		ShowSyncHudMsg(id, g_iStrafeHudSync, "%s", szStrafesInfo);	
	}

	// Customized center stats
	static szMain[256]; szMain[0] = 0;
	
	if(g_bShowStrafes[id] && g_bShowSync[id] && g_bShowGain[id] && g_bShowFrames[id]){
		// Original format when everything is ON
		formatex(szMain, charsmax(szMain), "Strafes: %i / Sync: %i%%^nFrames: %d/%d^nGain: %.2f", strafes, sync, goodFrames, frames, gain);
	}
	else{
		// Customized by removing what's OFF
		new parts = 0;
		
		if(g_bShowStrafes[id]){
			parts++;
			formatex(szMain, charsmax(szMain), "Strafes: %i", strafes);
		}
		
		if(g_bShowSync[id]){
			if(parts) add(szMain, charsmax(szMain), " / ");
			add(szMain, charsmax(szMain), "Sync: ");
			format(szMain, charsmax(szMain), "%s%i%%", szMain, sync);
			parts++;
		}
		
		if(g_bShowFrames[id]){
			if(parts) add(szMain, charsmax(szMain), "^n");
			format(szMain, charsmax(szMain), "%sFrames: %d/%d", szMain, goodFrames, frames);
			parts++;
		}
		
		if(g_bShowGain[id]){
			if(parts) add(szMain, charsmax(szMain), "^n");
			format(szMain, charsmax(szMain), "%sGain: %.2f", szMain, gain);
		}
	}

	if(szMain[0]){
		set_hudmessage(0, 100, 255, -1.0, 0.6, 0, 0.0, 2.0, 0.2, 0.2, 3);
		ShowSyncHudMsg(id, g_iMainHudSync, "%s", szMain);
		if(g_bShowConsole[id]){
			client_print(id, print_console, "--- Strafe #%i - Sync: %i%% ---", strafes, sync);
			client_print(id, print_console, "Strafes: %i^nSync: %i%%^nFrames: %d/%d^nGain: %.2f^nGain/Strafe: %.2f^nGain/GoodFrames: %.2f", strafes, sync, goodFrames, frames, gain, gain/strafes, gain/goodFrames);
			client_print(id, print_console, "----------------------------");
			}
		}

	// Spectators
	for(new i = 1; i < 33; i++)
	{
		if(!is_user_connected(i) || is_user_alive(i) || !g_bShowStats[i]) continue;
		
		if(pev(i, pev_iuser2) != id) continue;
		
		static szStrafesInfo[32 * MAX_STRAFES], iLen;
		szStrafesInfo[0] = 0; iLen = 0;
		for(new j = 0; j < strafeLen && j < MAX_STRAFES; j++)
		{
			iLen += formatex(szStrafesInfo[iLen], charsmax(szStrafesInfo) - iLen, "Strafe: %i^tSync: %i^n", j + 1, strafesSync[j]);
		}
		
		set_hudmessage(200, 22, 22, 0.77, 0.4, 0, 0.0, 2.0, 0.2, 0.2, 4);
		ShowSyncHudMsg(i, g_iStrafeHudSync, "%s", szStrafesInfo);

		set_hudmessage(0, 100, 255, -1.0, 0.6, 0, 0.0, 2.0, 0.2, 0.2, 3);
		ShowSyncHudMsg(i, g_iMainHudSync, "Strafes: %i^nSync: %i%^nFrames: %d/%d^nGain: %.2f", strafes, sync, goodFrames, frames, gain);
		if(g_bShowConsole[i]){
			client_print(id, print_console, "--- Strafe #%i - Sync: %i%% ---", strafes, sync);
			client_print(id, print_console, "Strafes: %i^nSync: %i%%^nFrames: %d/%d^nGain: %.2f^nGain/Strafe: %.2f^nGain/GoodFrames: %.2f", strafes, sync, goodFrames, frames, gain, gain/strafes, gain/goodFrames);
			client_print(id, print_console, "----------------------------");
		}
	}
}

public fwdPreThink(id) {
	if (!is_user_alive(id)) return FMRES_IGNORED;

	static button, flags, oldbuttons;
	static Float:velocity[3], Float:speed;

	button = pev(id, pev_button);
	flags = pev(id, pev_flags);
	oldbuttons = pev(id, pev_oldbuttons);
	
	if(button & IN_JUMP && !(oldbuttons & IN_JUMP))
	{
		if(flags & FL_ONGROUND) {
			pev(id, pev_velocity, velocity);
			velocity[2] = 0.0;
			speed = vector_length(velocity);

			if (g_bPreStats[id]) {
				set_hudmessage(0, 100, 255, -1.0, 0.700, 0, 0.0, 1.0, 0.1, 0.1, 4);
				ShowSyncHudMsg(id, g_iMainHudSync, "Prestrafe: %.2f", speed);
			}
		}
	}
	return FMRES_IGNORED;
}
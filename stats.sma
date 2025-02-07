#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <cromchat2>
#include <strafe_globals>

#define PLUGIN "Stats"
#define VERSION "1.0"
#define AUTHOR "MrShark45"

#define MAX_STRAFES 33

forward fwPlayerStrafe(id, strafes, sync, strafesSync[], strafeLen, frames, goodFrames, Float:gain, overlaps);

public plugin_init(){
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_forward( FM_PlayerPreThink, "fwdPreThink", 0 );
	RegisterHam(Ham_Spawn, "player", "FwdPlayerSpawn", 1);
	RegisterHam(Ham_Killed, "player", "FwdPlayerDeath", 1);

	register_clcmd("say /stats", "toggle_stats");
	register_clcmd("say /pre", "toggle_pre");
	register_clcmd("say /showpre", "toggle_pre");
	register_clcmd("say /prestrafe", "toggle_pre");

	g_iMainHudSync = CreateHudSyncObj();
	g_iStrafeHudSync = CreateHudSyncObj();

	CC_SetPrefix("&x04[FWO]");
}

public plugin_natives(){
	register_library("strafe_stats");

	register_native("get_user_sync", "native_get_user_sync");

	register_native("get_user_strafes", "native_get_user_strafes");

	register_native("display_stats", "native_display_stats");

	register_native("get_bool_stats", "native_get_bool_stats");
	register_native("toggle_stats", "native_toggle_stats");
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
		if(!is_user_connected(i) || is_user_alive(i) || !b_show_stats[i] ) continue;
		
		if( pev(i, pev_iuser2) == id )
		{
			set_hudmessage(0, 100, 255, -1.0, 0.6, 0, 0.0, 2.0, 0.2, 0.2, -1);
			ShowSyncHudMsg(i, g_iMainHudSync, "Strafes: %i^nSync: %i%%", strafes, sync);
		}
	}
}

public native_get_bool_stats(NumParams){
	new id = get_param(1);
	return b_show_stats[id];
}

public native_toggle_stats(NumParams){
	new id = get_param(1);
	toggle_stats(id);
}

public client_putinserver(id){
	b_show_stats[id] = false;
	b_pre_stats[id] = false; 
}


public toggle_stats(id){
	b_show_stats[id] = !b_show_stats[id];

	if(!b_show_stats[id]) 
	{
		CC_SendMessage(id, "&x01Stats: &x07OFF");
	}
	else 
	{
		CC_SendMessage(id, "&x01Stats: &x06ON"); 
	}
}

public toggle_pre(id){
	b_pre_stats[id] = !b_pre_stats[id];

	if(!b_pre_stats[id]) 
	{
		CC_SendMessage(id, "&x01ShowPre: &x07OFF");
	} 
	else 
	{
		CC_SendMessage(id, "&x01ShowPre: &x06ON"); 
	}
}

public fwPlayerStrafe(id, strafes, sync, strafesSync[], strafeLen, frames, goodFrames, Float:gain, overlaps){
	if(is_user_bot(id)) return;
	g_iNativeStrafes[id] = strafes;
	g_iNativeSync[id] = sync;

	if(strafes < 1) return;
	
	if(b_show_stats[id]){
		/*
		static szStrafesInfo[32 * MAX_STRAFES], iLen;
		szStrafesInfo = "^0"; iLen = 0;
		for(new i = 0; i < strafeLen && i < MAX_STRAFES; i++)
		{
			iLen += formatex(szStrafesInfo[iLen], charsmax(szStrafesInfo) - iLen, "Strafe: %i^tSync: %i^n",
				i + 1, strafesSync[i]);
		}
	
		set_hudmessage(200, 22, 22, 0.77, 0.4, 0, 0.0, 2.0, 0.2, 0.2, 4);
		ShowSyncHudMsg(id, g_iStrafeHudSync, "%s", szStrafesInfo);

		set_hudmessage(0, 100, 255, -1.0, 0.6, 0, 0.0, 2.0, 0.2, 0.2, 3);
		ShowSyncHudMsg(id, g_iMainHudSync, "Strafes: %i^nSync: %i%^nFrames: %d/%d^nGain: %.2f", strafes, sync, goodFrames, frames, gain);
		client_print(id, print_console, "Strafes: %i^nSync: %i%^nFrames: %d/%d^nGain: %.2f^nGain/Strafe: %.2f^nGain/GoodFrames: %.2f", strafes, sync, goodFrames, frames, gain, gain/strafes, gain/goodFrames);
		*/
		
		set_hudmessage(0, 100, 255, -1.0, 0.6, 0, 0.0, 2.0, 0.2, 0.2, 3);
		ShowSyncHudMsg(id, g_iMainHudSync, "Strafes: %i^nSync: %i%^nGain: %.2f", strafes, sync, gain);
		
	}

	for(new i = 1; i < 33; i++)
	{
		if(!is_user_connected(i) || is_user_alive(i) || !b_show_stats[i] ) continue;
		
		if( pev(i, pev_iuser2) != id ) continue
		
		static szStrafesInfo[32 * MAX_STRAFES], iLen;
		szStrafesInfo = "^0"; iLen = 0;
		for(new j = 0; j < strafeLen && j < MAX_STRAFES; j++)
		{
			iLen += formatex(szStrafesInfo[iLen], charsmax(szStrafesInfo) - iLen, "Strafe: %i^tSync: %i^n",
				i + 1, strafesSync[j]);
		}

		set_hudmessage(200, 22, 22, 0.77, 0.4, 0, 0.0, 2.0, 0.2, 0.2, 4);
		ShowSyncHudMsg(i, g_iStrafeHudSync, "%s", szStrafesInfo);


		set_hudmessage(0, 100, 255, -1.0, 0.6, 0, 0.0, 2.0, 0.2, 0.2, 3);
		ShowSyncHudMsg(i, g_iMainHudSync, "Strafes: %i^nSync: %i%^nFrames: %d/%d^nGain: %.2f", strafes, sync, goodFrames, frames, gain);
		client_print(i, print_console, "Strafes: %i^nSync: %i%^nFrames: %d/%d^nGain: %.2f^nGain/Strafe: %.2f^nGain/GoodFrames: %.2f", strafes, sync, goodFrames, frames, gain, gain/strafes, gain/goodFrames);
	
	}
}

public fwdPreThink(id){
    static bool:in_air[33];

    if(g_userConnected[id] == true)
    {   
        if(g_alive[id])
        {
            if(g_reset[id] == true)
            {
                g_reset[id] = false;
                g_Jumped[id] = false;
                in_air[id] = false;
                notjump[id] = false;
                ladderjump[id] = false;
            }
            
            static button, oldbuttons, flags;
            button = pev(id, pev_button );
            flags = pev(id, pev_flags );
            oldbuttons = pev(id, pev_oldbuttons );
            
            new Float:velocity[3];
            pev(id, pev_velocity, velocity);
            movetype[id] = pev(id, pev_movetype);
            
            if(flags & FL_ONGROUND && flags & FL_INWATER)  
                velocity[2] = 0.0;
            if(velocity[2] != 0)
                velocity[2] -= velocity[2];
                
            speed[id] = vector_length(velocity);  
            
            if(notjump[id])
            {
                notjump[id] = false;
            }
            
            if(flags & FL_ONGROUND)
            {
                notjump[id] = true;
            }

            if((movetype[id] == MOVETYPE_FLY) && (button & IN_FORWARD || button & IN_BACK || button & IN_LEFT || button & IN_RIGHT))
            {
                ladderjump[id] = true;
            }
            
            if((movetype[id] == MOVETYPE_FLY) && button & IN_JUMP)
            {
                ladderjump[id] = false;
                in_air[id] = false;
                notjump[id] = true;
            }
            
            if(movetype[id] != MOVETYPE_FLY && ladderjump[id] == true)
            {
                notjump[id] = true;
                ladderjump[id] = false;    

                in_air[id] = true;
                g_Jumped[id] = true;
                prebhopspeed[id] = 0.0;
                
                set_hudmessage(0, 60, 255, -1.0, 0.643, 0, 0.02, 1.0, 0.01, 0.1, 4);
                show_hudmessage(id , "Ladderjump: %d", floatround(speed[id]));
            }
            
            if(button & IN_JUMP && !(oldbuttons & IN_JUMP) && flags & FL_ONGROUND)
            {   
                bhop_num[id]++;
                notjump[id] = false;

                ddnum[id] = 0;
                pev(id, pev_velocity, velocity);
                in_air[id] = true;
                g_Jumped[id] = true;
        
                if(b_pre_stats[id])
                {
                    if(bhop_num[id] > 0) 
                    {
                        if(floatround(preladderspeed[id]) > 20) 
                        {
                            bhopgainspeed[id] = preladderspeed[id];                                        
                            preladderspeed[id] = 0.0;
                        }               
                        else if(bhopgainspeed[id] == 0.0 || bhopgainspeed[id] == speed[id]) 
                        {
                            set_hudmessage(5, 60, 255, -1.0, 0.643, 0, 0.0, 1.0, 0.1, 0.1, 4);
                            show_hudmessage(id , "Prestrafe: %d", floatround(speed[id]));
                        }
                    }
                }
                bhopgainspeed[id] = speed[id];
            }
            else if(flags & FL_ONGROUND && in_air[id])
            {   
                g_reset[id] = true;
            }
            
            if(flags & FL_ONGROUND && firstfall_ground[id] == true && get_gametime() - FallTime[id] > 0.5)
            {
                ddnum[id] = 0;
                bhop_num[id] = 0;
                firstfall_ground[id] = false;
                prebhopspeed[id] = 0.0;
                bhopgainspeed[id] = 0.0;
                preladderspeed[id] = 0.0;
            }
            
            if(flags & FL_ONGROUND && firstfall_ground[id] == false)
            {
                FallTime[id] = get_gametime();
                firstfall_ground[id] = true;
            }
            else if(!(flags & FL_ONGROUND) && firstfall_ground[id] == true)
            {
                firstfall_ground[id] = false;
            }   
        }
    }
    return FMRES_IGNORED;
}

public FwdPlayerSpawn(id)
{
    if(is_user_alive(id))
    {
        g_alive[id] = true;
    }
}

public FwdPlayerDeath(id)
{
    g_alive[id] = false;
}

public client_connect(player)
{
    g_userConnected[player] = true;
    b_pre_stats[player] = false;

    ddnum[player] = 0;
    bhopgainspeed[player] = 0.0;
    prebhopspeed[player] = 0.0;
    preladderspeed[player] = 0.0;
}

public client_disconnected(id) {
    g_userConnected[id] = false;
    g_alive[id] = false;
}

#include <amxmodx>
#include <engine>
#include <fakemeta>

#define PLUGIN "Stats"
#define VERSION "1.0"
#define AUTHOR "MrShark45"

#define MAX_STRAFES 60
#define TOUCHING_GROUND (1<<9)

new bool:g_bJumped[33], bool:g_bOldOnGround[33];
new Float:g_fOldAngles[33], Float:g_fOldSpeed[33];
new g_iGoodSync[33], g_iStrafes[33], g_iSyncFrames[33], g_iMainHudSync, g_iStrafeHudSync;
new g_iStrafeFrames[33][MAX_STRAFES], g_iStrafeGoodSync[33][MAX_STRAFES];
new Float:g_fStrafeGain[33][MAX_STRAFES];
new bool:g_bStrafingAw[33], bool:g_bStrafingSd[33];

new Float:fOldJumpSpeed[33];

new bool:b_show_stats[33];

new g_iNativeStrafes[33];
new g_iNativeSync[33];

public plugin_init(){
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_clcmd("say /stats", "toggle_stats");

	g_iMainHudSync = CreateHudSyncObj();
	g_iStrafeHudSync = CreateHudSyncObj();

	register_forward(FM_PlayerPreThink, "FM_PlayerPreThink_Pre", 0);
	register_forward(FM_PlayerPostThink, "FM_PlayerPostThink_Pre", 0);

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
}


public toggle_stats(id){
	b_show_stats[id] = !b_show_stats[id];
}

public FM_PlayerPreThink_Pre(id){
	if(is_user_bot(id))
		return FMRES_IGNORED;
	static iButtons; iButtons = pev(id, pev_button);
	static bool:bOnGround; bOnGround = bool:(pev(id, pev_flags) & FL_ONGROUND);
	static Float:fVelocity[3]; pev(id, pev_velocity, fVelocity);
	static Float:fSpeed; fSpeed = floatsqroot(fVelocity[0] * fVelocity[0] + fVelocity[1] * fVelocity[1]);
	
	if(bOnGround && iButtons & IN_JUMP && !g_bJumped[id])
	{
		g_bJumped[id] = true;
		
		g_bStrafingAw[id] = false;
		g_bStrafingSd[id] = false;
		
		g_iGoodSync[id] = 0;
		g_iSyncFrames[id] = 0;
		
		g_iStrafes[id] = 0;

		
		
		for(new i = 0; i < MAX_STRAFES; i++)
		{
			g_iStrafeGoodSync[id][i] = 0;
			g_iStrafeFrames[id][i] = 0;
			g_fStrafeGain[id][i] = 0.0;
		}
	}
	else if(bOnGround && g_bJumped[id] && !g_bOldOnGround[id])
	{
		g_bJumped[id] = false;

		if(g_iStrafes[id])
		{
			static iSync; iSync = floatround(100.0 * g_iGoodSync[id] / g_iSyncFrames[id]);

			g_iNativeStrafes[id] = g_iStrafes[id];
			g_iNativeSync[id] = iSync;

			if(b_show_stats[id]){
				static szStrafesInfo[32 * MAX_STRAFES], iLen;
				static szStrafesInfo2[32 * MAX_STRAFES], iLen2;
				static iFrames = 0, iGoodFrames = 0;
				static Float:fGain;
				szStrafesInfo = "^0"; iLen = 0;
				iFrames = 0; iGoodFrames = 0; fGain = 0.0;
				for(new i = 0; i < g_iStrafes[id] && i < MAX_STRAFES; i++)
				{
					iLen += formatex(szStrafesInfo[iLen], charsmax(szStrafesInfo) - iLen, "Strafe: %i^tSync: %i^n",
						i + 1, floatround(100.0 * g_iStrafeGoodSync[id][i] / g_iStrafeFrames[id][i]));
					iLen2 += formatex(szStrafesInfo2[iLen], charsmax(szStrafesInfo2) - iLen, "Strafe: %i^tSync: %i%^tFrames: %d/%d^tGain: %.2f^n",
						i + 1, floatround(100.0 * g_iStrafeGoodSync[id][i] / g_iStrafeFrames[id][i]), g_iStrafeGoodSync[id][i], g_iStrafeFrames[id][i], g_fStrafeGain[id][i]);

					iFrames += g_iStrafeFrames[id][i];
					iGoodFrames += g_iStrafeGoodSync[id][i];
					fGain += g_fStrafeGain[id][i];
				}
		
				set_hudmessage(200, 22, 22, 0.77, 0.4, 0, 0.0, 2.0, 0.2, 0.2, 4);
				ShowSyncHudMsg(id, g_iStrafeHudSync, "%s", szStrafesInfo);
				client_print(id, print_console, szStrafesInfo2);


				set_hudmessage(0, 100, 255, -1.0, 0.6, 0, 0.0, 2.0, 0.2, 0.2, 3);
				ShowSyncHudMsg(id, g_iMainHudSync, "Strafes: %i^nSync: %i%^nFrames: %d/%d^nGain: %.2f", g_iStrafes[id], iSync, iGoodFrames, iFrames, fGain);
				client_print(id, print_console, "Strafes: %i^nSync: %i%^nFrames: %d/%d^nGain: %.2f^nGain/Strafe: %.2f^nGain/GoodFrames: %.2f", g_iStrafes[id], iSync, iGoodFrames, iFrames, fGain, fGain/g_iStrafes[id], fGain/iGoodFrames);
			}
			
			
			for(new i = 1; i < 33; i++)
			{
				if(!is_user_connected(i) || is_user_alive(i) || !b_show_stats[i] ) continue;
				
				if( pev(i, pev_iuser2) == id )
				{
					static szStrafesInfo[32 * MAX_STRAFES], iLen;
					static szStrafesInfo2[32 * MAX_STRAFES], iLen2;
					static iFrames = 0, iGoodFrames = 0;
					static Float:fGain;
					szStrafesInfo = "^0"; iLen = 0;
					szStrafesInfo2 = "^0"; iLen2 = 0;
					iFrames = 0; iGoodFrames = 0; fGain = 0.0;
					for(new j = 0; j < g_iStrafes[id] && j < MAX_STRAFES; j++)
					{
						iLen += formatex(szStrafesInfo[iLen], charsmax(szStrafesInfo) - iLen, "Strafe: %i^tSync: %i%^n",
							j + 1, floatround(100.0 * g_iStrafeGoodSync[id][j] / g_iStrafeFrames[id][j]));
						iLen2 += formatex(szStrafesInfo2[iLen2], charsmax(szStrafesInfo2) - iLen2, "Strafe: %i^tSync: %i%^tFrames: %d/%d^tGain: %.2f^n",
							j + 1, floatround(100.0 * g_iStrafeGoodSync[id][j] / g_iStrafeFrames[id][j]), g_iStrafeGoodSync[id][j], g_iStrafeFrames[id][j], g_fStrafeGain[id][j]);

						iFrames += g_iStrafeFrames[id][j];
						iGoodFrames += g_iStrafeGoodSync[id][j];
						fGain += g_fStrafeGain[id][j];
					}

					set_hudmessage(200, 22, 22, 0.77, 0.4, 0, 0.0, 2.0, 0.2, 0.2, 4);
					ShowSyncHudMsg(i, g_iStrafeHudSync, "%s", szStrafesInfo);
					client_print(i, print_console, "%s", szStrafesInfo2);


					set_hudmessage(0, 100, 255, -1.0, 0.6, 0, 0.0, 2.0, 0.2, 0.2, 3);
					ShowSyncHudMsg(i, g_iMainHudSync, "Strafes: %i^nSync: %i%^nFrames: %d/%d^nGain: %.2f", g_iStrafes[id], iSync, iGoodFrames, iFrames, fGain);
					client_print(i, print_console, "Strafes: %i^nSync: %i%^nFrames: %d/%d^nGain: %.2f^nGain/Strafe: %.2f^nGain/GoodFrames: %.2f", g_iStrafes[id], iSync, iGoodFrames, iFrames, fGain, fGain/g_iStrafes[id], fGain/iGoodFrames);
				}
			}

			fOldJumpSpeed[id] = fSpeed;

		}
		
		if(iButtons & IN_JUMP)
		{
			FM_PlayerPreThink_Pre(id);
		}
	}
	
	g_bOldOnGround[id] = bOnGround;
	
	return FMRES_IGNORED;
}

public FM_PlayerPostThink_Pre(id){
	if(!is_user_alive(id)) return FMRES_IGNORED;
	if(is_user_bot(id))	return FMRES_IGNORED;
		
	
	static bool:g_bTurning;

	static bool:bOnGround; bOnGround = bool:(pev(id, pev_flags) & FL_ONGROUND);

	if(bOnGround) return FMRES_IGNORED;
	
	static Float:fAngles[3]; pev(id, pev_angles, fAngles);

	static iButtons; iButtons = pev(id, pev_button);
	static Float:fVelocity[3]; pev(id, pev_velocity, fVelocity);
	static Float:fSpeed; fSpeed = floatsqroot(fVelocity[0] * fVelocity[0] + fVelocity[1] * fVelocity[1]);
	
	g_bTurning = false;
	
	if(fAngles[1] < g_fOldAngles[id])
	{
		g_bTurning = true;
	}
	else if(fAngles[1] > g_fOldAngles[id])
	{
		g_bTurning = true;
	}
	g_fOldAngles[id] = fAngles[1];
	if(g_bTurning)
	{
		if(!g_bStrafingAw[id] && ((iButtons & IN_FORWARD) || (iButtons & IN_MOVELEFT)) && !(iButtons & IN_MOVERIGHT) && !(iButtons & IN_BACK))
		{
			g_bStrafingAw[id] = true;
			g_bStrafingSd[id] = false;
			
			g_iStrafes[id]++;
		}
		else if(!g_bStrafingSd[id] && ((iButtons & IN_BACK) || (iButtons & IN_MOVERIGHT)) && !(iButtons & IN_MOVELEFT) && !(iButtons & IN_FORWARD))
		{
			g_bStrafingAw[id] = false;
			g_bStrafingSd[id] = true;
			
			g_iStrafes[id]++;
		}

		if(g_fOldSpeed[id] < fSpeed)
		{
			g_iGoodSync[id]++;
			if(g_iStrafes[id])
			{
				g_iStrafeGoodSync[id][g_iStrafes[id] - 1]++;
				g_fStrafeGain[id][g_iStrafes[id] - 1] += (fSpeed - g_fOldSpeed[id]);
			}
		}

		g_iSyncFrames[id]++;

		if(g_iStrafes[id])
		{
			g_iStrafeFrames[id][g_iStrafes[id] - 1]++;
		}

		g_fOldSpeed[id] = fSpeed;
	}
	

	return FMRES_IGNORED;
}

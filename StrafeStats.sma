#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "Anti-FlatCheat"
#define VERSION "0.01"
#define AUTHOR "MrShark45" 

#pragma semicolon 1

#define MAX_STRAFES 32
#define TOUCHING_GROUND (1<<9)

new bool:g_bConsoleLog[33], bool:g_bJumped[33], bool:g_bMainStat[33], bool:g_bOldOnGround[33], bool:g_bStrafeStat[33];
new bool:g_bStrafingAw[33], bool:g_bStrafingSd[33], bool:g_bTurningLeft[33], bool:g_bTurningRight[33];
new Float:g_fMaxSpeed[33], Float:g_fOldAngles[33], Float:g_fOldSpeed[33], Float:g_fPreStrafe[33];
new g_iGoodSync[33], g_iStrafes[33], g_iSyncFrames[33], g_iMainHudSync, g_iStrafeHudSync, g_iMaxPlayers;
new g_iStrafeFrames[33][MAX_STRAFES], g_iStrafeGoodSync[33][MAX_STRAFES];

public plugin_init(){
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_clcmd("say /stats", "toggleStats");

    register_forward(FM_PlayerPreThink, "FM_PlayerPreThink_Pre", 0);
    register_forward(FM_PlayerPostThink, "FM_PlayerPostThink_Pre", 0);

    g_iMainHudSync = CreateHudSyncObj();
    g_iStrafeHudSync = CreateHudSyncObj();    
    g_iMaxPlayers = get_maxplayers();
}

public toggleStats(id){
    g_bMainStat[id] = !g_bMainStat[id];
    g_bStrafeStat[id] = !g_bStrafeStat[id];
}

public client_putinserver(id)
{    
    g_bConsoleLog[id] = false;
    g_bMainStat[id] = false;
    g_bStrafeStat[id] = false;
}

public FM_PlayerPreThink_Pre(id)
{
    if(!is_user_alive(id)) return FMRES_IGNORED;
    
    static iButtons; iButtons = pev(id, pev_button);
    static bool:bOnGround; bOnGround = bool:(pev(id, pev_flags) & FL_ONGROUND);
    static i;
    
    if(bOnGround && iButtons & IN_JUMP && !g_bJumped[id])
    {
        g_bJumped[id] = true;
        
        static Float:fVelocity[3]; pev(id, pev_velocity, fVelocity);
        static Float:fSpeed; fSpeed = floatsqroot(fVelocity[0] * fVelocity[0] + fVelocity[1] * fVelocity[1]);
        
        g_fOldSpeed[id] = g_fMaxSpeed[id] = g_fPreStrafe[id] = fSpeed;
        
        g_bStrafingAw[id] = false;
        g_bStrafingSd[id] = false;
        
        g_iGoodSync[id] = 0;
        g_iSyncFrames[id] = 0;
        
        g_iStrafes[id] = 0;
        
        for(i = 0; i < MAX_STRAFES; i++)
        {
            g_iStrafeGoodSync[id][i] = 0;
            g_iStrafeFrames[id][i] = 0;
        }
    }
    else if(bOnGround && g_bJumped[id] && !g_bOldOnGround[id])
    {
        g_bJumped[id] = false;
        
        if(g_iStrafes[id])
        {
            static iSync; iSync = floatround(100.0 * g_iGoodSync[id] / g_iSyncFrames[id]);
            
            if(g_bMainStat[id])
            {
                set_hudmessage(0, 100, 255, -1.0, 0.75, 0, 0.0, 2.0, 0.2, 0.2, 3);
                ShowSyncHudMsg(id, g_iMainHudSync, "MaxSpeed: %.3f (%.3f)^nPreStrafe: %.3f^nStrafes: %i^nSync: %i%%",\
                g_fMaxSpeed[id], g_fMaxSpeed[id] - g_fPreStrafe[id], g_fPreStrafe[id], g_iStrafes[id], iSync);
            }
            if(g_bConsoleLog[id])
            {
                console_print(id, "MaxSpeed: %.3f (%.3f) PreStrafe: %.3f Strafes: %i Sync: %i%%",\
                g_fMaxSpeed[id], g_fMaxSpeed[id] - g_fPreStrafe[id], g_fPreStrafe[id], g_iStrafes[id], iSync);
            }
            
            static szStrafesInfo[32 * MAX_STRAFES], iLen;
            szStrafesInfo = "^0"; iLen = 0;
            for(i = 0; i < g_iStrafes[id] && i < MAX_STRAFES; i++)
            {
                iLen += formatex(szStrafesInfo[iLen], charsmax(szStrafesInfo) - iLen, "Strafe: %i^tSync: %i%%^n",\
                    i + 1, floatround(100.0 * g_iStrafeGoodSync[id][i] / g_iStrafeFrames[id][i]));
            }
            
            if(g_bStrafeStat[id])
            {
                set_hudmessage(200, 22, 22, 0.77, 0.4, 0, 0.0, 2.0, 0.2, 0.2, 4);
                ShowSyncHudMsg(id, g_iStrafeHudSync, "%s", szStrafesInfo);
            }
            
            static iSpecmode;
            for(i = 1; i <= g_iMaxPlayers; i++)
            {
                if(!is_user_connected(i) || is_user_alive(i) || pev(i, pev_deadflag) != DEAD_DEAD) continue;
                
                iSpecmode = pev(i, pev_iuser1);
                if((iSpecmode == 1 || iSpecmode == 2 || iSpecmode == 4) && pev(i, pev_iuser2) == id )
                {
                    if(g_bMainStat[i])
                    {
                        set_hudmessage(0, 100, 255, -1.0, 0.75, 0, 0.0, 2.0, 0.2, 0.2, 4);
                        ShowSyncHudMsg(i, g_iMainHudSync, "MaxSpeed: %.3f (%.3f)^nPreStrafe: %.3f^nStrafes: %i^nSync: %i%%",\
                        g_fMaxSpeed[id], g_fMaxSpeed[id] - g_fPreStrafe[id], g_fPreStrafe[id], g_iStrafes[id], iSync);
                    }
                    if(g_bConsoleLog[i])
                    {
                        console_print(i, "MaxSpeed: %.3f (%.3f) PreStrafe: %.3f Strafes: %i Sync: %i%%",\
                        g_fMaxSpeed[id], g_fMaxSpeed[id] - g_fPreStrafe[id], g_fPreStrafe[id], g_iStrafes[id], iSync);
                    }
                    if(g_bStrafeStat[i])
                    {
                        set_hudmessage(200, 22, 22, 0.77, 0.4, 0, 0.0, 2.0, 0.2, 0.2, 4);
                        ShowSyncHudMsg(i, g_iStrafeHudSync, "%s", szStrafesInfo);
                    }
                }
            }
        }
        
        if(iButtons & IN_JUMP)
        {
            FM_PlayerPreThink_Pre(id);
        }
    }
    
    g_bOldOnGround[id] = bOnGround;
    
    return FMRES_IGNORED;
}
public FM_PlayerPostThink_Pre(id)
{
    if(!is_user_alive(id)) return FMRES_IGNORED;
    
    static bool:bOnGround; bOnGround = bool:(pev(id, pev_flags) & FL_ONGROUND);
    
    static Float:fAngles[3]; pev(id, pev_angles, fAngles);
    
    g_bTurningRight[id] = false;
    g_bTurningLeft[id] = false;
    
    if(fAngles[1] < g_fOldAngles[id])
    {
        g_bTurningRight[id] = true;
    }
    else if(fAngles[1] > g_fOldAngles[id])
    {
        g_bTurningLeft[id] = true;
    }    
    g_fOldAngles[id] = fAngles[1];
    
    if(bOnGround) return FMRES_IGNORED;
    
    static iButtons; iButtons = pev(id, pev_button);
    static Float:fVelocity[3]; pev(id, pev_velocity, fVelocity);
    static Float:fSpeed; fSpeed = floatsqroot(fVelocity[0] * fVelocity[0] + fVelocity[1] * fVelocity[1]);
    
    if(g_bTurningLeft[id] || g_bTurningRight[id])
    {
        if(!g_bStrafingAw[id] && ((iButtons & IN_FORWARD)
            || (iButtons & IN_MOVELEFT)) && !(iButtons & IN_MOVERIGHT) && !(iButtons & IN_BACK))
        {
            g_bStrafingAw[id] = true;
            g_bStrafingSd[id] = false;
            
            g_iStrafes[id]++;
        }
        else if(!g_bStrafingSd[id] && ((iButtons & IN_BACK)
            || (iButtons & IN_MOVERIGHT)) && !(iButtons & IN_MOVELEFT) && !(iButtons & IN_FORWARD))
        {
            g_bStrafingAw[id] = false;
            g_bStrafingSd[id] = true;
            
            g_iStrafes[id]++;
        }
    }
    
    if(g_fMaxSpeed[id] < fSpeed)
    {
        g_fMaxSpeed[id] = fSpeed;
    }
    
    if(g_fOldSpeed[id] < fSpeed)
    {
        g_iGoodSync[id]++;
        
        if(g_iStrafes[id] && g_iStrafes[id] <= MAX_STRAFES)
        {
            g_iStrafeGoodSync[id][g_iStrafes[id] - 1]++;
        }
    }
    
    g_iSyncFrames[id]++;
    
    if(g_iStrafes[id] && g_iStrafes[id] <= MAX_STRAFES)
    {
        g_iStrafeFrames[id][g_iStrafes[id] - 1]++;
    }
    
    g_fOldSpeed[id] = fSpeed;
    
    return FMRES_IGNORED;
}  
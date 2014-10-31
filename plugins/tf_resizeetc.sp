/**
 * Sourcemod Plugin Template
 */

#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

#define PLUGIN_VERSION          "0.0.0"     // Plugin version.

public Plugin:myinfo = {
    name = "[TF2] Resize etc.",
    author = "nosoop",
    description = "Resize other body parts.",
    version = PLUGIN_VERSION,
    url = "http://github.com/nosoop/SM-TFResizeEtc"
}

new Float:g_rgHandScale[MAXPLAYERS+1], Float:g_rgTorsoScale[MAXPLAYERS+1];

public OnPluginStart() {
    RegAdminCmd("sm_resizehand", Command_ResizeHand, ADMFLAG_CHEATS);
    RegAdminCmd("sm_resizetorso", Command_ResizeTorso, ADMFLAG_CHEATS);
    LoadTranslations("common.phrases");
    
    for (new i = MaxClients; i > 0; --i) {
        if (IsClientInGame(i)) {
            OnClientPutInServer(i);
        }
    }
}

public OnMapStart() {
    for (new i = 0; i < MAXPLAYERS; i++) {
        g_rgHandScale[i] = 1.0;
        g_rgTorsoScale[i] = 1.0;
    }
}

public OnClientPutInServer(iClient) {
    SDKHook(iClient, SDKHook_PostThink, SDKHook_PostThinkResize);
}

public OnClientDisconnect(iClient) {
    SDKUnhook(iClient, SDKHook_PostThink, SDKHook_PostThinkResize);
}

public Action:Command_ResizeHand(iClient, nArgs) {
    decl String:scale[64];
    GetCmdArg(2, scale, sizeof(scale));

    new Float:fScale = StringToFloat(scale);

    decl String:player[64];
    GetCmdArg(1, player, sizeof(player));

    new String:target_name[MAX_TARGET_LENGTH];
    new target_list[MAXPLAYERS], target_count;
    new bool:tn_is_ml;

    if ((target_count = ProcessTargetString(
            player,
            iClient,
            target_list,
            MAXPLAYERS,
            COMMAND_FILTER_CONNECTED,
            target_name,
            sizeof(target_name),
            tn_is_ml)) <= 0) {
        ReplyToTargetError(iClient, target_count);
        return Plugin_Handled;
    }

    for (new i=0; i<target_count; i++) {
        g_rgHandScale[target_list[i]] = fScale;
    }
    return Plugin_Handled;
}

public Action:Command_ResizeTorso(iClient, nArgs) {
    decl String:scale[64];
    GetCmdArg(2, scale, sizeof(scale));

    new Float:fScale = StringToFloat(scale);

    decl String:player[64];
    GetCmdArg(1, player, sizeof(player));

    new String:target_name[MAX_TARGET_LENGTH];
    new target_list[MAXPLAYERS], target_count;
    new bool:tn_is_ml;

    if ((target_count = ProcessTargetString(
            player,
            iClient,
            target_list,
            MAXPLAYERS,
            COMMAND_FILTER_CONNECTED,
            target_name,
            sizeof(target_name),
            tn_is_ml)) <= 0) {
        ReplyToTargetError(iClient, target_count);
        return Plugin_Handled;
    }

    for (new i=0; i<target_count; i++) {
        g_rgTorsoScale[target_list[i]] = fScale;
    }
    return Plugin_Handled;
}

public SDKHook_PostThinkResize(iClient) {
    // TODO horribly inefficent -- reduce setting rate instead of on every think tick
    if (g_rgTorsoScale[iClient] != 1.0) {
        SetEntPropFloat(iClient, Prop_Send, "m_flTorsoScale", g_rgTorsoScale[iClient]);
    }
    if (g_rgHandScale[iClient] != 1.0) {
        SetEntPropFloat(iClient, Prop_Send, "m_flHandScale", g_rgHandScale[iClient]);
    }
}
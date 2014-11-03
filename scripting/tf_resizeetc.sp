/**
 * Released under the MIT License.
 */

#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

#define PLUGIN_VERSION          "0.1.0"     // Plugin version.

public Plugin:myinfo = {
    name = "[TF2] Resize etc.",
    author = "nosoop",
    description = "Resize other body parts.",
    version = PLUGIN_VERSION,
    url = "http://github.com/nosoop/SM-TFResizeEtc"
}

// Stores scale values.
new Float:g_rgfHandScale[MAXPLAYERS+1], Float:g_rgfTorsoScale[MAXPLAYERS+1];

public OnPluginStart() {
    RegAdminCmd("sm_resizehand", Command_ResizeHand, ADMFLAG_CHEATS);
    RegAdminCmd("sm_resizetorso", Command_ResizeTorso, ADMFLAG_CHEATS);
    LoadTranslations("common.phrases");
    
    for (new i = MaxClients; i > 0; --i) {
        SetDefaultBodyScalars(i);
        
        if (IsClientInGame(i)) {
            OnClientPutInServer(i);
        }
    }
}

public OnClientPutInServer(iClient) {
    SDKHook(iClient, SDKHook_PostThink, SDKHook_PostThinkResize);
}

public OnClientDisconnect(iClient) {
    SDKUnhook(iClient, SDKHook_PostThink, SDKHook_PostThinkResize);
    SetDefaultBodyScalars(iClient);
}

/**
 * Hook to control the torso / hand scaling on a client, updating it after every think tick.
 */
public SDKHook_PostThinkResize(iClient) {
    // TODO possibly inefficent to do after every think tick?
    if (g_rgfTorsoScale[iClient] != 1.0) {
        SetEntPropFloat(iClient, Prop_Send, "m_flTorsoScale", g_rgfTorsoScale[iClient]);
    }
    if (g_rgfHandScale[iClient] != 1.0) {
        SetEntPropFloat(iClient, Prop_Send, "m_flHandScale", g_rgfHandScale[iClient]);
    }
}

/**
 * Resets the hand / torso scalar values.
 */
SetDefaultBodyScalars(iClient) {
    g_rgfHandScale[iClient] = 1.0;
    g_rgfTorsoScale[iClient] = 1.0;
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
        g_rgfHandScale[target_list[i]] = fScale;
    }
    
    if (tn_is_ml) {
        ShowActivity2(iClient, "[SM] ", "Changed the hand size of %t to %0.2f", target_name, fScale);
    } else {
        ShowActivity2(iClient, "[SM] ", "Changed the hand size of %t to %0.2f", "_s", target_name, fScale);
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
        g_rgfTorsoScale[target_list[i]] = fScale;
    }
    
    if (tn_is_ml) {
        ShowActivity2(iClient, "[SM] ", "Changed the torso size of %t to %0.2f", target_name, fScale);
    } else {
        ShowActivity2(iClient, "[SM] ", "Changed the torso size of %t to %0.2f", "_s", target_name, fScale);
    }
    return Plugin_Handled;
}

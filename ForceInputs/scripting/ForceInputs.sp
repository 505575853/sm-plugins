//====================================================================================================
//
// Name: ForceInput
// Author: zaCade + BotoX
// Description: Allows admins to force inputs on entities. (ent_fire)
//
//====================================================================================================
#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public Plugin myinfo =
{
	name 			= "ForceInput",
	author 			= "zaCade + BotoX",
	description 	= "Allows admins to force inputs on entities. (ent_fire)",
	version 		= "2.1",
	url 			= ""
};

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public void OnPluginStart()
{
	LoadTranslations("common.phrases");

	RegAdminCmd("sm_forceinput", Command_ForceInput, ADMFLAG_ROOT);
	RegAdminCmd("sm_forceinputplayer", Command_ForceInputPlayer, ADMFLAG_ROOT);
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public Action Command_ForceInputPlayer(int client, int args)
{
	if(GetCmdArgs() < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_forceinputplayer <target> <input> [parameter]");
		return Plugin_Handled;
	}

	char sArguments[3][256];
	GetCmdArg(1, sArguments[0], sizeof(sArguments[]));
	GetCmdArg(2, sArguments[1], sizeof(sArguments[]));
	GetCmdArg(3, sArguments[2], sizeof(sArguments[]));

	char sTargetName[MAX_TARGET_LENGTH];
	int aTargetList[MAXPLAYERS];
	int TargetCount;
	bool TnIsMl;

	if((TargetCount = ProcessTargetString(
			sArguments[0],
			client,
			aTargetList,
			MAXPLAYERS,
			COMMAND_FILTER_CONNECTED|COMMAND_FILTER_NO_IMMUNITY,
			sTargetName,
			sizeof(sTargetName),
			TnIsMl)) <= 0)
	{
		ReplyToTargetError(client, TargetCount);
		return Plugin_Handled;
	}

	for(int i = 0; i < TargetCount; i++)
	{
		if (sArguments[2][0])
			SetVariantString(sArguments[2]);

		AcceptEntityInput(aTargetList[i], sArguments[1], aTargetList[i], aTargetList[i]);
		ReplyToCommand(client, "[SM] Input succesfull.");
	}

	return Plugin_Handled;
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public Action Command_ForceInput(int client, int args)
{
	if(GetCmdArgs() < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_forceinput <classname/targetname> <input> [parameter]");
		return Plugin_Handled;
	}

	char sArguments[3][256];
	GetCmdArg(1, sArguments[0], sizeof(sArguments[]));
	GetCmdArg(2, sArguments[1], sizeof(sArguments[]));
	GetCmdArg(3, sArguments[2], sizeof(sArguments[]));

	if(StrEqual(sArguments[0], "!self"))
	{
		if(sArguments[2][0])
			SetVariantString(sArguments[2]);

		AcceptEntityInput(client, sArguments[1], client, client);
		ReplyToCommand(client, "[SM] Input succesfull.");
	}
	else if(StrEqual(sArguments[0], "!target"))
	{
		float fPosition[3];
		float fAngles[3];
		GetClientEyePosition(client, fPosition);
		GetClientEyeAngles(client, fAngles);

		Handle hTrace = TR_TraceRayFilterEx(fPosition, fAngles, MASK_SOLID, RayType_Infinite, TraceRayFilter, client);

		if(TR_DidHit(hTrace))
		{
			int entity = TR_GetEntityIndex(hTrace);

			if(entity <= 1 || !IsValidEntity(entity))
				return Plugin_Handled;

			if(sArguments[2][0])
				SetVariantString(sArguments[2]);

			AcceptEntityInput(entity, sArguments[1], client, client);
			ReplyToCommand(client, "[SM] Input succesfull.");
		}
	}
	else
	{
		int Wildcard = FindCharInString(sArguments[0], '*');

		int entity = INVALID_ENT_REFERENCE;
		while((entity = FindEntityByClassname(entity, "*")) != INVALID_ENT_REFERENCE)
		{
			char sClassname[64];
			char sTargetname[64];
			GetEntPropString(entity, Prop_Data, "m_iClassname", sClassname, sizeof(sClassname));
			GetEntPropString(entity, Prop_Data, "m_iName", sTargetname, sizeof(sTargetname));

			if(strncmp(sClassname, sArguments[0], Wildcard, false) == 0
				|| strncmp(sTargetname, sArguments[0], Wildcard, false) == 0)
			{
				if (sArguments[2][0])
					SetVariantString(sArguments[2]);

				AcceptEntityInput(entity, sArguments[1], client, client);
				ReplyToCommand(client, "[SM] Input succesfull.");
			}
		}
	}

	return Plugin_Handled;
}

//----------------------------------------------------------------------------------------------------
// Purpose:
//----------------------------------------------------------------------------------------------------
public bool TraceRayFilter(int entity, int mask, any client)
{
	if(entity == client)
		return false;

	return true;
}

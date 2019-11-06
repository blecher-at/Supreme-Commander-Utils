local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua') 
local ScenarioFramework = import('/lua/ScenarioFramework.lua') 

local TeleportUtils = import(string.gsub(ScenarioInfo.map, '[^/]*.scmap' , 'cardiacutils_teleport.lua'))

function OnPopulate() 
ScenarioUtils.InitializeArmies() 
--ScenarioFramework.SetPlayableArea(ScenarioUtils.AreaToRect('AREA_1')) 
end 

function OnStart(self) 
	local topBridge = 92
	local botBridge = 512-92
	local bridgeHeight = 24

	local teleportationZones = 
	{
		{
			sourceZone = Rect(0,topBridge+2,512,botBridge-2), -- redirect if into zone and 
			targetZone = Rect(0,0,512,topBridge-2), -- move order into this zone is issued
			name		='centerToTop',
			teleporterSource = TeleportUtils.Pos(240,topBridge+bridgeHeight/2),
			teleporterDest = TeleportUtils.Pos(240,topBridge-bridgeHeight/2), 
			unitCategory = categories.NAVAL
	    },
		{
			sourceZone = Rect(0,0,512,topBridge-bridgeHeight/2),  -- redirect if into zone and 
			targetZone = Rect(0,topBridge+2,512,botBridge+bridgeHeight/2),-- move order into this zone is issued
			name		='topToCenter',
			teleporterSource = TeleportUtils.Pos(240,topBridge-bridgeHeight/2),
			teleporterDest = TeleportUtils.Pos(235,topBridge+bridgeHeight/2),
			unitCategory = categories.NAVAL
	    },
		{
			sourceZone = Rect(0,topBridge+bridgeHeight/2,512,botBridge-bridgeHeight/2), -- redirect if into zone and 
			targetZone = Rect(0,botBridge+bridgeHeight/2,512,512), -- move order into this zone is issued
			name		='centerToBot',
			teleporterSource = TeleportUtils.Pos(260,botBridge-bridgeHeight/2),
			teleporterDest = TeleportUtils.Pos(260,botBridge+bridgeHeight/2),
			unitCategory = categories.NAVAL
	    },
		{
			sourceZone = Rect(0,botBridge+bridgeHeight/2,512,512),  -- redirect if into zone and 
			targetZone = Rect(0,topBridge+bridgeHeight/2,512,botBridge-bridgeHeight/2),-- move order into this zone is issued
			name		='botToCenter',
			teleporterSource = TeleportUtils.Pos(260,botBridge+bridgeHeight/2),
			teleporterDest = TeleportUtils.Pos(260,botBridge-bridgeHeight/2),
			unitCategory = categories.NAVAL
	    },
	}
	TeleportUtils.init(teleportationZones)
end

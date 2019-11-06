
############################################################
############################################################
#
# Teleportation Utility
# Scripting 
# (C) 2007 Stephan Blecher (stephan@blecher.at)
#
# Use at your own risk and have lots of fun!
# Version 1
#
############################################################



    function basicSerialize (o)
      if type(o) == "number" then
        return tostring(o)
      else   -- assume it is a string
        return string.format("%q", o)
      end
    end


    function Xsave (name, value, saved)
	  local str = ""
      saved = saved or {}       -- initial value
      str = str..name.." = "
      if type(value) == "number" or type(value) == "string" then
        str = str..basicSerialize(value).."\n"
      elseif type(value) == "table" then
        if saved[value] then    -- value already saved?
          str = str..saved[value].."\n"  -- use its previous name
        else
          saved[value] = name   -- save name for next time
          str = str.."{}\n"     -- create a new table
          for k,v in value do      -- save its fields
            local fieldname = string.format("%s[%s]", name,
                                            basicSerialize(k))
            str = str..Xsave(fieldname, v, saved)
          end
        end
      else
        --error("cannot save a " .. type(value))
      end
	  return str
    end

	
function dump(tbl)
	LOG(Xsave("var",tbl,nil))
end

--- Utility functions
function Pos(x,y,z)
	if z == nil then z = 0 end
	local p = {}
	p[1] = x
	p[3] = y
	p[2] = z
	return p
end


local teleportationZones = nil
  

  

function checkTeleportationZones()

--	sourceZone = Rect(0,0,300,500), -- redirect if into zone and 
--		targetZone = Rect(700,0,1024,500), -- move order into this zone is issued
--		name		='Alaska',
--		teleporterSource = Pos(0,300),
--		teleporterDest = Pos(1024,310),
--    },

--	dump(categories)
	for i, zone in teleportationZones do
		local units = GetUnitsInRect(zone.sourceZone)
		if units then
			for index,unit in units do
			
				-- teleport these units
				if not unit:IsDead() and not unit:IsBeingBuilt() and EntityCategoryContains(zone.unitCategory, unit) 
				then
					-- unit is ordered into the targetZone
					if unit:GetNavigator() and isInside(zone.targetZone, unit:GetNavigator():GetGoalPos()) then
						LOG("unit with target found in zone "..zone.name)
						unit.originalWaypoint = unit:GetNavigator():GetGoalPos()
						unit:GetNavigator():SetGoal(zone.teleporterSource)
					end
				end
			end
		end
		
		local unitsToTeleport = GetUnitsInRect(Pos2Rect(zone.teleporterSource, 5))
		if unitsToTeleport then
			for index,unit in unitsToTeleport do
				-- teleport these units
				if not unit:IsDead() and not unit:IsBeingBuilt() and unit:GetWeaponCount() > 0 and unit.originalWaypoint
				then
					--unit.targetRally = zone.targetRally
					--unit.targetRally = zone.targetRally
					-- teleport is for free ... shadow economyEvent function
					--unit.CreateEconomyEvent = function () end
					-- shadow teleport function to issue move afterwards
					--unit.InitiateTeleportThread = myInitiateTeleportThread
					local rp = 2
							
					local teleportPos = Pos(zone.teleporterDest[1]+math.random(-rp, rp),zone.teleporterDest[3]+math.random(-rp, rp))
--					local teleportPos = Pos(zone.teleporterDest[1],zone.teleporterDest[3]+zone.tpoffset)
--					local teleportPos = Pos(zone.teleporterDest[1],zone.teleporterDest[3])

#					LOG("Warping unit from Zone "..zone.name.." to "..Xsave('aaa',teleportPos))
--					if unit:CanPathTo(teleportPos) then 

					--fix ferry bug with transports?
					local cs = 0;

			        if EntityCategoryContains(categories.TRANSPORTATION, unit) then
			                local cargo = unit:GetCargo()
			                if table.getn(cargo) > 0 then
			                    for k, v in cargo do
--									dump(v)
			                    end
			                end
							
						LOG("cargo size pre teleport: "..table.getn(cargo))
						
						
						unit.OnRemoveFromStorage = function() 
							LOG("BBBB") 
						end
						
						unit:GetNavigator():SetGoal(unit.originalWaypoint)					
						WaitSeconds(0.2)
						Warp(unit, teleportPos, unit:GetOrientation())
		                local cargo = unit:GetCargo()
						LOG("cargo size post teleport: "..table.getn(cargo))
						WaitSeconds(0)
		                local cargo = unit:GetCargo()
						LOG("cargo size post teleport: "..table.getn(cargo))
					else
						Warp(unit, teleportPos, unit:GetOrientation())
						WaitSeconds(0.2)
					
			        end

						-- Move to Original Waypoint
						unit:GetNavigator():SetGoal(unit.originalWaypoint)					
--						IssueMove({unit}, unit.originalWaypoint)
						unit.wayPointAfterTeleport = unit.originalWaypoint
						unit.originalWaypoint = nil;
						unit.lastTeleportZoneUsed = zone;
						unit.teleporterStaleCounter = 0;
--					end
					--unit:OnTeleportUnit(unit, newPosition,{0,0,0,1})
					--unit.CreateEconomyEvent = ee -- dont reset, we are async
				end
			end
		end
		
	end
end

function checkTeleportationZonesPFWorkaround()
	-- Help the bugged pathfinding a little...
	for i, zone in teleportationZones do
		local staleUnits = GetUnitsInRect(Pos2Rect(zone.teleporterDest, 5))
		if staleUnits then
			for index,unit in staleUnits do
				if unit.wayPointAfterTeleport and unit.lastTeleportZoneUsed == zone and unit.teleporterStaleCounter < 50 then
						-- Move to Original Waypoint
						unit:GetNavigator():SetGoal(unit.wayPointAfterTeleport)					
				--		IssueMove({unit}, unit.wayPointAfterTeleport)
						unit.teleporterStaleCounter = unit.teleporterStaleCounter+1
						WaitSeconds(0)
						LOG("Unit path reassigned the "..unit.teleporterStaleCounter..". time")
				end
			end
		end
	end
end



function jobsThread()
	while true do
		checkTeleportationZones()
		WaitSeconds(1)
	end
end

function maintenanceThread()
	while true do
		checkTeleportationZonesPFWorkaround()
		WaitSeconds(5)
		
	end
end

function init(zones)
	teleportationZones = zones
	ForkThread(jobsThread)
	ForkThread(maintenanceThread)
end



function isInside(zone, pos)
	if  pos[1] <= zone.x1 and pos[1] >= zone.x0 
	and pos[3] <= zone.y1 and pos[3] >= zone.y0 then
		return true
	else
		return false
	end
end

function Pos2Rect(pos, radius)
	return Rect(pos[1]-radius, pos[3]-radius, pos[1]+radius, pos[3]+radius)
end


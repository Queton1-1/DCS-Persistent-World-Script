--[[
    -= PERSISTENT WORLD SCRIPT =-

    Credits :
    JGi | Quéton 1-1
    Based on Surrexen via Pikey's Simple Group Saving Script
    

--]]



--[[ 
    
    PARAMS
    
]]--

-- Temps entre deux savuvegardes (sec)
-- Time between saves (in sec)
SaveScheduleUnits = 300

-- /!\ Préfixe de la sauvegarde
-- Save file prefix
saveFileName = "Plop"

-- Activer sauvegarde unités detruites Bleu (true/false)
-- If set to true, save blue coalition also.
saveDeadBlue = false
saveDeadRed = true

-- Activer sauvegarde unités spawnées Bleu/rouge (true/false)
-- If set to true, save blue coalition also.
saveBirthBlue = true
saveBirthRed = true



-- *** VARIABLES ***
PWS_Spawned = {}

-- Dossier de sauvegarde (défaut : \Save Games\DCS\Missions\_PWS_Saves)
PWS_SaveFolder = lfs.writedir().."Missions\\_PWS_Saves\\"


if PWS_SaveFolder then
    lfs.mkdir(PWS_SaveFolder)
end
PWS_DeadUnitsSaveFile = PWS_SaveFolder..saveFileName.."_PWS_Units.lua"
PWS_DeadStaticsSaveFile = PWS_SaveFolder..saveFileName.."_PWS_Statics.lua"
PWS_SpawnedUnitsSaveFile = PWS_SaveFolder..saveFileName.."_PWS_Spawned.lua"
--trigger.action.outText("Persistent World | WriteDir : "..lfs.writedir(),360)

--[[

    TOOLKIT FUNCTIONS

]]--
function IntegratedbasicSerialize(s)
    if s == nil then
		return "\"\""
    else
		if ((type(s) == 'number') or (type(s) == 'boolean') or (type(s) == 'function') or (type(s) == 'table') or (type(s) == 'userdata') ) then
			return tostring(s)
		elseif type(s) == 'string' then
			return string.format('%q', s)
		end
    end
end
  
-- imported slmod.serializeWithCycles (Speed)
function IntegratedserializeWithCycles(name, value, saved)
    local basicSerialize = function (o)
		if type(o) == "number" then
			return tostring(o)
		elseif type(o) == "boolean" then
			return tostring(o)
		else -- assume it is a string
			return IntegratedbasicSerialize(o)
		end
	end

    local t_str = {}
    saved = saved or {}       -- initial value
    if ((type(value) == 'string') or (type(value) == 'number') or (type(value) == 'table') or (type(value) == 'boolean')) then
		table.insert(t_str, name .. " = ")
			if type(value) == "number" or type(value) == "string" or type(value) == "boolean" then
				table.insert(t_str, basicSerialize(value) ..  "\n")
			else
				if saved[value] then    -- value already saved?
					table.insert(t_str, saved[value] .. "\n")
				else
					saved[value] = name   -- save name for next time
					table.insert(t_str, "{}\n")
						for k,v in pairs(value) do      -- save its fields
							local fieldname = string.format("%s[%s]", name, basicSerialize(k))
							table.insert(t_str, IntegratedserializeWithCycles(fieldname, v, saved))
						end
				end
			end
		return table.concat(t_str)
    else
		return ""
    end
end

function file_exists(name) --check if the file already exists for writing
	if lfs.attributes(name) then
    return true
    else
    return false end 
end

function writemission(data, file)--Function for saving to file (commonly found)
	File = io.open(file, "w")
	File:write(data)
	File:close()
end

function PWS_GetTableLength(Table)
	local TableLengthCount = 0
	for _ in pairs(Table) do TableLengthCount = TableLengthCount + 1 end
	return TableLengthCount
end

-- *********************
-- *** GROUND SPANWN ***
-- *********************
function PWS_groundSpawn(groupCoalition, groundUnitType, groundGroupName, groundPosY, groundPosX, groundFreq)

    if groupCoalition == nil then
        groupCoalition = country.id.CJTF_BLUE
    end
    --groupCoalition = coalitionInputTest(event.text, groupCoalition)

    if groundUnitType == nil then 
        unit = "leclerc" 
    end
    groundGroupName = groundGroupName--.." "..math.random(01,99)
    
    if not groundPosY  then
        groundPosY = 0
    end

    if not groundPosX then
        groundPosX = 0
    end

    if groundFreq == nil  then groundFreq = 243000000 end

    groupData = {
        ["visible"] = false,
        ["hiddenOnPlanner"] = true,
        ["tasks"] = {}, -- end of ["tasks"]
        ["uncontrollable"] = false,
        ["task"] = "Pas de sol",
        ["taskSelected"] = true,
        ["route"] = {
            ["spans"] = 
            {
            }, -- end of ["spans"]
            ["points"] = 
            {
                [1] = 
                {
                    --["alt"] = 5,
                    ["type"] = "Turning Point",
                    ["ETA"] = 0,
                    ["alt_type"] = "BARO",
                    ["formation_template"] = "",
                    ["y"] = groundPosY,
                    ["x"] = groundPosX,
                    ["name"] = "SOM Spawn point",
                    ["ETA_locked"] = true,
                    ["speed"] = 0,
                    ["action"] = "Off Road",
                    ["task"] = 
                    {
                        ["id"] = "ComboTask",
                        ["params"] = 
                        {
                            ["tasks"] = 
                            {
                                [1] = 
                                {
                                    ["enabled"] = true,
                                    ["auto"] = false,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 1,
                                    ["params"] = 
                                    {
                                        ["action"] = 
                                        {
                                            ["id"] = "SetFrequency",
                                            ["params"] = 
                                            {
                                                ["power"] = 10,
                                                ["modulation"] = 0,
                                                ["frequency"] = groundFreq,
                                            }, -- end of ["params"]
                                        }, -- end of ["action"]
                                    }, -- end of ["params"]
                                }, -- end of [1]
                                [2] = 
                                {
                                    ["enabled"] = true,
                                    ["auto"] = false,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 2,
                                    ["params"] = 
                                    {
                                        ["action"] = 
                                        {
                                            ["id"] = "SetCallsign",
                                            ["params"] = 
                                            {
                                                ["number"] = 5,
                                                ["callnameFlag"] = true,
                                                ["callname"] = 12,
                                            }, -- end of ["params"]
                                        }, -- end of ["action"]
                                    }, -- end of ["params"]
                                }, -- end of [2]
                                [3] = 
                                {
                                    ["enabled"] = true,
                                    ["auto"] = false,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 3,
                                    ["params"] = 
                                    {
                                        ["action"] = 
                                        {
                                            ["id"] = "Option",
                                            ["params"] = 
                                            {
                                                ["value"] = 4,
                                                ["name"] = 0,
                                            }, -- end of ["params"]
                                        }, -- end of ["action"]
                                    }, -- end of ["params"]
                                }, -- end of [3]
                                [4] = 
                                {
                                    ["enabled"] = true,
                                    ["auto"] = false,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 4,
                                    ["params"] = 
                                    {
                                        ["action"] = 
                                        {
                                            ["id"] = "Option",
                                            ["params"] = 
                                            {
                                                ["name"] = 8,
                                            }, -- end of ["params"]
                                        }, -- end of ["action"]
                                    }, -- end of ["params"]
                                }, -- end of [4]
                                [5] = 
                                {
                                    ["enabled"] = true,
                                    ["auto"] = false,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 5,
                                    ["params"] = 
                                    {
                                        ["action"] = 
                                        {
                                            ["id"] = "Option",
                                            ["params"] = 
                                            {
                                                ["value"] = 1,
                                                ["name"] = 24,
                                            }, -- end of ["params"]
                                        }, -- end of ["action"]
                                    }, -- end of ["params"]
                                }, -- end of [5]
                                [6] = 
                                {
                                    ["enabled"] = true,
                                    ["auto"] = false,
                                    ["id"] = "FAC",
                                    ["number"] = 2,
                                    ["params"] = 
                                    {
                                        ["number"] = 9,
                                        ["designation"] = "Auto",
                                        ["modulation"] = 0,
                                        ["callname"] = 5,
                                        ["datalink"] = true,
                                        ["frequency"] = 123000000,
                                    }, -- end of ["params"]
                                }, -- end of [6]
                            }, -- end of ["tasks"]
                        }, -- end of ["params"]
                    }, -- end of ["task"]
                    ["speed_locked"] = true,
                }, -- end of [1]
            }, -- end of ["points"]
        }, -- end of ["route"]
        ["groupId"] = 7,
        ["hidden"] = false,
        ["units"] = {
            [1] = {
                --["livery_id"] = "desert",
                ["skill"] = "Random",
                ["coldAtStart"] = false,
                ["type"] = groundUnitType,--"Tor 9A331", --"leclerc"
                ["unitId"] = 11,
                ["y"] = groundPosY,
                ["x"] = groundPosX,
                ["name"] = groundGroupName,--..math.random(1,99),
                ["heading"] = 0,
                ["playerCanDrive"] = true,
            }, -- end of [1]
        }, -- end of ["units"]
        ["y"] = groundPosY,
        ["x"] = groundPosX,
        ["name"] = groundGroupName,
        ["start_time"] = 0,
    }
    
    coalition.addGroup(groupCoalition, Group.Category.GROUND, groupData)
end


-- ****************************
-- *** UPDATE SPAWNED TABLE ***
-- ****************************
function PWS_updateSpawnedTable()
    if saveBirthBlue == true or saveBirthRed ==true then
        tempTable = {}
        
        for i = 1, #PWS_Spawned do

            -- vérifier qu'il existe
            if PWS_Spawned[i]
            and PWS_Spawned[i].unitCoalition
            and PWS_Spawned[i].unitObjectCategory
            and PWS_Spawned[i].UnitCategory
            and PWS_Spawned[i].unitType
            and PWS_Spawned[i].unitName
            and PWS_Spawned[i].vec3Z
            and PWS_Spawned[i].vec3X
            then
                currentUnit = Unit.getByName(PWS_Spawned[i].unitName)

                -- Si en vie, màj position
                if currentUnit and currentUnit:getLife() >= 1 then
                    --trigger.action.outText("Persistent World | Update Spawned : "..PWS_Spawned[i].unitName.." is alive !",5)

                    currentPos = currentUnit:getPoint()

                    tempTable[#tempTable+1] = {}
                    tempTable[#tempTable].unitCoalition = PWS_Spawned[i].unitCoalition
                    tempTable[#tempTable].unitObjectCategory = PWS_Spawned[i].unitObjectCategory
                    tempTable[#tempTable].UnitCategory = PWS_Spawned[i].UnitCategory
                    tempTable[#tempTable].unitType = PWS_Spawned[i].unitType
                    tempTable[#tempTable].unitName = PWS_Spawned[i].unitName
                    tempTable[#tempTable].vec3Z = currentPos.z
                    tempTable[#tempTable].vec3X = currentPos.x
                else
                    --trigger.action.outText("Persistent World | Update Spawned : L'unité n'existe plus",5)
                end
            else
                trigger.action.outText("Persistent World | Update Spawned : 1 loop skipped, a nil value ",5)
            end
            
            i = i + 1
        end
        PWS_Spawned = tempTable
        --trigger.action.outText("Persistent World | Update Update Spawned : complete",5)
    end
end



-- *******************************
-- *** SAVE FUNCTION FOR UNITS ***
-- *******************************
function PWS_SaveUnitIntermentTable(timeloop, time)
	IntermentMissionStr = IntegratedserializeWithCycles("PWS_Units", PWS_Units)
	--writemission(IntermentMissionStr, saveFileName.."_PWS_Units.lua")
    writemission(IntermentMissionStr, PWS_DeadUnitsSaveFile)
	trigger.action.outText("Persistent World | Progress Has Been Saved", 2)
	return time + SaveScheduleUnits
end

function PWS_SaveUnitIntermentTableNoArgs()
	IntermentMissionStr = IntegratedserializeWithCycles("PWS_Units", PWS_Units)
	--writemission(IntermentMissionStr, saveFileName.."_PWS_Units.lua")
    writemission(IntermentMissionStr, PWS_DeadUnitsSaveFile)
end

-- *********************************
-- *** SAVE FUNCTION FOR STATICS ***
-- *********************************
function PWS_SaveStaticIntermentTable(timeloop, time)
	IntermentMissionStrStatic = IntegratedserializeWithCycles("PWS_Statics", PWS_Statics)
	writemission(IntermentMissionStrStatic, PWS_DeadStaticsSaveFile)
    --writemission(IntermentMissionStrStatic, saveFileName.."_PWS_Statics.lua")
	--trigger.action.outText("Progress Has Been Saved", 15)	
	return time + SaveScheduleUnits
end

function PWS_SaveStaticIntermentTableNoArgs()
	IntermentMissionStrStatic = IntegratedserializeWithCycles("PWS_Statics", PWS_Statics)
	writemission(IntermentMissionStrStatic, PWS_DeadStaticsSaveFile)
    --writemission(IntermentMissionStrStatic, saveFileName.."_PWS_Statics.lua")
end

-- *********************************
-- *** SAVE FUNCTION FOR SPAWNED ***
-- *********************************
function PWS_saveSpawned(timeloop, time)
	
	PWS_updateSpawnedTable()
	
	ConstructionStr = IntegratedserializeWithCycles("PWS_Spawned", PWS_Spawned)
	writemission(ConstructionStr, PWS_SpawnedUnitsSaveFile)
	return time + SaveScheduleUnits
end

function PWS_saveSpawnedTableNoArgs()
	ConstructionStr = IntegratedserializeWithCycles("PWS_Spawned", PWS_Spawned)
	writemission(ConstructionStr, PWS_SpawnedUnitsSaveFile)	
end



--[[
    
    MAIN

]]--

PWSDeletedUnitCount = 0
PWSDeletedStaticCount = 0

trigger.action.outText("Persistent World | Loading...  -  Credits : JGi | Quéton 1-1, Based on Surrexen via Pikey's Simple Group Saving Script", 5)

if os ~= nil then

    -- *************************
	-- *** LOAD DEAD STATICS ***
    -- *************************
	if file_exists(PWS_DeadStaticsSaveFile) then
		
		dofile(PWS_DeadStaticsSaveFile)
			
		StaticIntermentTableLength = PWS_GetTableLength(PWS_Statics)	
		--trigger.action.outText("Static Table Length Is "..StaticIntermentTableLength, 15)
		
		for i = 1, StaticIntermentTableLength do
			--trigger.action.outText("Static Interment Element "..i.." Is "..PWS_Statics[i], 15)
			
			if ( StaticObject.getByName(PWS_Statics[i]) ~= nil ) then		
				StaticObject.getByName(PWS_Statics[i]):destroy()		
				PWSDeletedStaticCount = PWSDeletedStaticCount + 1
			elseif ( Unit.getByName(PWS_Statics[i]) ~= nil ) then
				Unit.getByName(PWS_Statics[i]):destroy()
				PWSDeletedUnitCount = PWSDeletedUnitCount + 1
			else
				trigger.action.outText("Static Interment Element "..i.." Is "..PWS_Statics[i].." And Was Not Found", 2)
			end	
		end
		trigger.action.outText("Persistent World | Removed "..PWSDeletedStaticCount.." Static(s)", 5)
	else
		PWS_Statics = {}
		StaticIntermentTableLength = 0	
	end

    -- ***********************
	-- *** LOAD DEAD UNITS ***
    -- ***********************
	if file_exists(PWS_DeadUnitsSaveFile) then	
		
		dofile(PWS_DeadUnitsSaveFile)
		
		UnitIntermentTableLength = PWS_GetTableLength(PWS_Units)	
		--trigger.action.outText("Unit Table Length Is "..UnitIntermentTableLength, 15)
			
		for i = 1, UnitIntermentTableLength do
			--trigger.action.outText("Unit Interment Element "..i.." Is "..PWS_Units[i], 15)		
			
			if ( Unit.getByName(PWS_Units[i]) ~= nil ) then
				Unit.getByName(PWS_Units[i]):destroy()
				PWSDeletedUnitCount = PWSDeletedUnitCount + 1
			else
				trigger.action.outText("Unit Interment Element "..i.." Is "..PWS_Units[i].." And Was Not Found", 2)
			end	
		end
		trigger.action.outText("Persistent World | Removed "..PWSDeletedUnitCount.." Unit(s)", 5)
	else			
		PWS_Units = {}	
		UnitIntermentTableLength = 0
		trigger.action.outText("Persistent World | No save found, creating new files...", 5)	
	end

    -- **************************
    -- *** LOAD SPAWNED UNITS ***
    -- **************************
    if saveBirthBlue == true or saveBirthRed == true then
        if file_exists(PWS_SpawnedUnitsSaveFile) then	
                --trigger.action.outText("Persistent World | Loads units spawned in the past...",5)
                
                dofile(PWS_SpawnedUnitsSaveFile)
                
                restoredUnit = 0

                if PWS_Spawned then            
                    for i = 1, #PWS_Spawned do
                        
                        if PWS_Spawned[i]
                        and PWS_Spawned[i].unitCoalition
                        and PWS_Spawned[i].unitObjectCategory
                        and PWS_Spawned[i].UnitCategory
                        and PWS_Spawned[i].unitCoalition
                        and PWS_Spawned[i].unitType
                        and PWS_Spawned[i].unitName
                        and PWS_Spawned[i].vec3Z
                        and PWS_Spawned[i].vec3X
                        then
                            if PWS_Spawned[i].unitCoalition == 2 then
                                coalitionFlag = country.id.CJTF_BLUE
                            else
                                coalitionFlag = country.id.CJTF_RED
                            end

                            PWS_groundSpawn(coalitionFlag, PWS_Spawned[i].unitType, PWS_Spawned[i].unitName, PWS_Spawned[i].vec3Z, PWS_Spawned[i].vec3X)
                            restoredUnit = restoredUnit + 1
                        else
                            trigger.action.outText("Persistent World | Restoring unit : One loop skip, a nil value",5)
                        end	
                        i = i+1
                    end
                    trigger.action.outText("Persistent World | Restored "..restoredUnit.." Unit(s)",5)
                end
        else
            --trigger.action.outText("Persistent World | No spawn file"..groupName,5)			
            PWS_Spawned = {}	
        end
    end





	--[[
		
		SCHEDULE

	]]--

	--trigger.action.outText("Persistent World Functions Schedulers Are Currently Disabled", 15)
	timer.scheduleFunction(PWS_SaveUnitIntermentTable, 53, timer.getTime() + SaveScheduleUnits)
	timer.scheduleFunction(PWS_SaveStaticIntermentTable, 53, timer.getTime() + (SaveScheduleUnits))
    timer.scheduleFunction(PWS_saveSpawned, nil, timer.getTime() + SaveScheduleUnits)



	--[[
		
		EVENT LOOP

	]]--

    -- ***************
    -- *** ON DEAD ***
    -- ***************
	PWS_ONDEADEVENTHANDLER = {}
	function PWS_ONDEADEVENTHANDLER:onEvent(Event)
		
		if Event.id == world.event.S_EVENT_DEAD then
			if Event.initiator then
				if ( Event.initiator:getCategory() == 1 or Event.initiator:getCategory() == 3 ) then -- UNIT or STATIC
					if ( Event.initiator:getCoalition() ~= nil ) then
					
						local DeadUnit 				 = Event.initiator
						local DeadUnitObjectCategory = Event.initiator:getCategory() -- 1 UNIT / 2 WEAPON / 3 STATIC / 4 BASE / 5 SCENERY / 6 CARGO
						local DeadUnitCategory 		 = Event.initiator:getDesc().category -- 0 AIRPLANE / 1 HELICOPTER / 2 GROUND_UNIT / 3 SHIP / 4 STRUCTURE
						local DeadUnitCoalition 	 = Event.initiator:getCoalition()
						local DeadUnitName			 = Event.initiator:getName()
						local DeadUnitType			 = Event.initiator:getTypeName()
						
						if ( DeadUnitCoalition == 1 or DeadUnitCoalition == 2 and saveDeadBlue == true) then -- RED ONLY AT THIS STAGE	
							if DeadUnitObjectCategory == 1 then -- UNIT
								if ( DeadUnitCategory == 2 or DeadUnitCategory == 3 ) then -- GROUND_UNIT or SHIP
									--trigger.action.outText("Persistent World | "..DeadUnitType, 60)
									if string.match(DeadUnitType, "CVN")
                                    or string.match(DeadUnitType, "KUZNECOW") 
                                    or string.match(DeadUnitType, "CV_1143_5") 
                                    or string.match(DeadUnitName, "Wounded Pilot")
                                    or string.match(DeadUnitName, "TTGT")
                                    or string.match(DeadUnitName, "ttgt")
                                    or string.match(DeadUnitName, "Training target")
                                    or string.match(DeadUnitName, "Procedural")
                                    -- Add your own exeptions
                                    --or string.match(DeadUnitName, "Russian APC Tigr 233036")
                                    then  
										trigger.action.outText("Persistent World | Unit ignored", 5)
									else					
										UnitIntermentTableLength = UnitIntermentTableLength + 1				
										PWS_Units[UnitIntermentTableLength] = DeadUnitName
										--trigger.action.outText("Persistent World | Unit added", 10)
									end	
								else
								end
							elseif DeadUnitObjectCategory == 3 then	-- STATIC
								StaticIntermentTableLength = StaticIntermentTableLength + 1			
								PWS_Statics[StaticIntermentTableLength] = DeadUnitName
                                --trigger.action.outText("Persistent World | Static "..DeadUnitName.." destroyed ", 10)			
							else
							end
						else
						end
					else
					end
				end	
			end
		end
	end
	world.addEventHandler(PWS_ONDEADEVENTHANDLER)

    -- ****************
    -- *** ON BIRTH ***
    -- ****************
    PWS_ONBIRTHEVENTHANDLER = {}
	function PWS_ONBIRTHEVENTHANDLER:onEvent(Event)
		
		if Event.id == world.event.S_EVENT_BIRTH then
			if Event.initiator then
				if ( Event.initiator:getCategory() == 1 or Event.initiator:getCategory() == 3 ) then 	-- UNIT or STATIC
					if ( Event.initiator:getCoalition() ~= nil ) then
					
						local BirthUnit 				 = Event.initiator
						local BirthUnitObjectCategory = Event.initiator:getCategory()						-- 1 UNIT / 2 WEAPON / 3 STATIC / 4 BASE / 5 SCENERY / 6 CARGO
						local BirthUnitCategory 		 = Event.initiator:getDesc().category					-- 0 AIRPLANE / 1 HELICOPTER / 2 GROUND_UNIT / 3 SHIP / 4 STRUCTURE
						BirthUnitCoalition 	        = Event.initiator:getCoalition()
						BirthUnitName			    = Event.initiator:getName()
						BirthUnitType			    = Event.initiator:getTypeName()
                        currentPos                  = Unit.getByName(BirthUnitName):getPoint()
						BirthUnitVec3Z 		        = currentPos.z
                        BirthUnitVec3X 		        = currentPos.x

						if ( BirthUnitCoalition == 1 and saveBirthRed == true or BirthUnitCoalition == 2 and saveBirthBlue == true) then
							if BirthUnitObjectCategory == 1 then -- UNIT
								if BirthUnitCategory == 2 
                                and not string.match(BirthUnitName, "Wounded Pilot")
                                and not string.match(BirthUnitName, "TTGT")
                                and not string.match(BirthUnitName, "ttgt")
                                and not string.match(BirthUnitName, "Training target") 
                                and not string.match(BirthUnitName, "Procedural")
                                -- Add your own exeptions
                                --and not string.match(BirthUnitName, "My_exeption") 
                                then -- GROUND_UNIT or SHIP

                                    PWS_Spawned[#PWS_Spawned+1] = {}
                                    PWS_Spawned[#PWS_Spawned].unitCoalition = BirthUnitCoalition
                                    PWS_Spawned[#PWS_Spawned].unitObjectCategory = BirthUnitObjectCategory
                                    PWS_Spawned[#PWS_Spawned].UnitCategory = BirthUnitCategory
                                    PWS_Spawned[#PWS_Spawned].unitType = BirthUnitType
                                    PWS_Spawned[#PWS_Spawned].unitName = BirthUnitName
                                    PWS_Spawned[#PWS_Spawned].vec3Z = BirthUnitVec3Z
                                    PWS_Spawned[#PWS_Spawned].vec3X = BirthUnitVec3X

                                    --trigger.action.outText("Persistent World | Event : "..PWS_Spawned[#PWS_Spawned].unitName.." added to table", 5)
								else --nothing
								end
							-- elseif ( BirthUnitObjectCategory == 3 ) then 									-- STATIC
							-- 	SpawnedTableLength = SpawnedTableLength + 1			
							-- 	PWS_Spawned[SpawnedTableLength] = BirthUnitName												
							else
							end
						else
						end
					else
					end
				end	
			end
		end
	end
	world.addEventHandler(PWS_ONBIRTHEVENTHANDLER)
else
    trigger.action.outText("Persistent World | Error, MissionScripting.lua 'sanitize'.", 10)
end

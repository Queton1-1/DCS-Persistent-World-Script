--[[
    -= PERSISTENT WORLD SCRIPT =-

    Credits :
    JGi | Quéton 1-1
    [♥] Surrexen
    [♥] Pikey
--]]

--[[
    Notes de version - ChangeLog

    2.13f
        Refonte des liste d'échappement
            escapeNameFromDeadList
            escapeTypeFromDeadList
            escapeNameFromBirthList
            escapeTextFromMarksList

        Modification crédits, plus grand chose à voir avec la base de Pikey
        Ajout sauvegarde des marqueurs, sauf si texte vide
        Refactorisation des fonctions:
            PWS_groundSpawn, 
            PWS_updateSpawnedTable, 
            PWS_updateMarksTable,
            PWS_ONDEADEVENTHANDLER:onEvent(Event)
            PWS_ONBIRTHEVENTHANDLER:onEvent(Event)
        
        Mise en cohérence de certains noms


    2.13e
        Modification task au spawn des groupes
            ROE : FreeFire
            Etat d'alerte : Rouge

    2.13d
        Ajout liste d'exclusion (en construction)
            > PWS.escapeNameFromDeadList & PWS.escapeNameFromBirthList non-fonctionnels
            > réglage direct dans les Events

    2.13c
        Suppression commentaires

    2.13b
        Ajout préfixe PWS.
        Suppression commentaires inutiles
        Ajout PWS.escapeNameFromDeadList / PWS.escapeNameFromBirthList
        Correction itérables PWS_GetTableLength(Table) > #PWS_Units
        Ajout event S_EVENT_UNIT_LOST & S_EVENT_KILL
        Ajout contrôle des doublons PWS_Units / PWS_Statics
--]]



--[[ 
    
    PARAMS
    
]]--

PWS = {}

--> Temps entre deux sauvegardes (sec)
--> Time between saves (in sec)
PWS.SaveSchedule = 300

--> /!\ Préfixe de la sauvegarde
--> Save file prefix
PWS.saveFileName = "Plop"

--> Activer sauvegarde unités detruites Bleu (true/false)
--> If set to true, save blue coalition also.
PWS.saveDeadBlue = false
PWS.saveDeadRed = true

--> Activer sauvegarde unités spawnées Bleu/rouge (true/false)
--> If set to true, save blue coalition also.
PWS.saveBirthBlue = true
PWS.saveBirthRed = true

--> Activer sauvegarde des Marks (true/false)
--> If set to true, save Marks also.
PWS.saveMarksBlue = true
PWS.saveMarksRed = true


--> Liste de nom à exclure de la save
--> Names or prefix to not save
PWS.escapeNameFromDeadList = {
    "Wounded Pilot",
    "TTGT",
    "ttgt",
    "Training target",
    "Procedural",
}
PWS.escapeTypeFromDeadList = {
    "CVN", 
    "KUZNECOW",
    "CV_1143_5",
}

PWS.escapeNameFromBirthList = {
    "Wounded Pilot",
    "TTGT",
    "ttgt",
    "Training target",
    "Procedural",
    "SOM",
    "som",
}

PWS.escapeTextFromMarksList = {
    "SOM",
    "som"
}



--%%% VARIABLES %%%
    PWS_Spawned = {}
    PWS_Marks = {}

    --> Dossier de sauvegarde (défaut : \Save Games\DCS\Missions\_PWS_Saves)
    PWS_SaveFolder = lfs.writedir().."Missions\\_PWS_Saves\\"

    if PWS_SaveFolder then
        lfs.mkdir(PWS_SaveFolder)
    end
    PWS_DeadUnitsSaveFile = PWS_SaveFolder..PWS.saveFileName.."_PWS_Units.lua"
    PWS_DeadStaticsSaveFile = PWS_SaveFolder..PWS.saveFileName.."_PWS_Statics.lua"
    PWS_SpawnedUnitsSaveFile = PWS_SaveFolder..PWS.saveFileName.."_PWS_Spawned.lua"
    PWS_MarksSaveFile = PWS_SaveFolder..PWS.saveFileName.."_PWS_Marks.lua"
    --trigger.action.outText("Persistent World | WriteDir : "..lfs.writedir(),360)



--[[

    TOOLKIT FUNCTIONS

]]--

--%%% SERIALIZE %%%
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

--%%% FILE EXIST %%%
    function file_exists(name) --check if the file already exists for writing
        if lfs.attributes(name) then
        return true
        else
        return false end 
    end

--%%% ECRITURE %%%
    function writemission(data, file)--Function for saving to file (commonly found)
        File = io.open(file, "w")
        File:write(data)
        File:close()
    end

--%%% GROUND SPAWN %%%
    function PWS_groundSpawn(groupCoalition, groundUnitType, groundGroupName, groundPosY, groundPosX, groundFreq)

        _groupCoalition = groupCoalition or country.id.CJTF_BLUE
        --groupCoalition = coalitionInputTest(event.text, groupCoalition)

        _groundUnitType = groundUnitType or "Leclerc"
        _groundGroupName = groundGroupName --.." "..math.random(01,99)
        _groundPosY = groundPosY or 0
        _groundPosX = groundPosX or 0
        _groundFreq = groundFreq or 243000000

        _groupData = {
            ["visible"] = false,
            ["hiddenOnPlanner"] = true,
            ["tasks"] = {},
            ["uncontrollable"] = false,
            ["task"] = "Pas de sol", --?
            ["taskSelected"] = true,
            ["route"] = {
                ["spans"] = {},
                ["points"] = {
                    [1] =  {
                        --["alt"] = 5,
                        ["type"] = "Turning Point",
                        ["ETA"] = 0,
                        ["alt_type"] = "BARO",
                        ["formation_template"] = "",
                        ["y"] = _groundPosY,
                        ["x"] = _groundPosX,
                        ["name"] = "Spawn point",
                        ["ETA_locked"] = true,
                        ["speed"] = 0,
                        ["action"] = "Off Road",
                        ["task"] = {
                            ["id"] = "ComboTask",
                            ["params"] = {
                                ["tasks"] = {
                                    [1] = {
                                        ["enabled"] = true,
                                        ["auto"] = false,
                                        ["id"] = "WrappedAction",
                                        ["number"] = 1,
                                        ["params"] = {
                                            ["action"] = {
                                                ["id"] = "Option",
                                                ["params"] = {
                                                    ["value"] = 2,--ROE? 4
                                                    ["name"] = 0,
                                                },--params
                                            },--action
                                        },--params
                                    },
                                    [2] = {
                                        ["enabled"] = true,
                                        ["auto"] = false,
                                        ["id"] = "WrappedAction",
                                        ["number"] = 2,
                                        ["params"] = {
                                            ["action"] = {
                                                ["id"] = "Option",
                                                ["params"] = {
                                                    ["name"] = 8, --Dispersion
                                                }, -- end of ["params"]
                                            }, -- end of ["action"]
                                        }, -- end of ["params"]
                                    }, -- end of [2]
                                    [3] = {
                                        ["enabled"] = true,
                                        ["auto"] = false,
                                        ["id"] = "WrappedAction",
                                        ["number"] = 3,
                                        ["params"] = {
                                            ["action"] = {
                                                ["id"] = "Option",
                                                ["params"] = {
                                                    ["value"] = 1,
                                                    ["name"] = 24,
                                                }, -- end of ["params"]
                                            }, -- end of ["action"]
                                        }, -- end of ["params"]
                                    }, -- end of [3]
                                    [4] = {
                                        ["number"] = 4,
                                        ["auto"] = false,
                                        ["id"] = "WrappedAction",
                                        ["enabled"] = true,
                                        ["params"] = {
                                            ["action"] = {
                                                ["id"] = "Option",
                                                ["params"] = {
                                                    ["value"] = 2,
                                                    ["name"] = 9, --Etat d'alerte
                                                }, -- end of ["params"]
                                            }, -- end of ["action"]
                                        }, -- end of ["params"]
                                    }, -- end of [4]
                                }, -- end of ["tasks"]
                            }, -- end of ["params"]
                        }, -- end of ["task"]
                        ["speed_locked"] = true,
                    }, -- end of [1]
                }, -- end of ["points"]
            },
            ["groupId"] = math.random(1000,99999),
            ["hidden"] = false,
            ["units"] = {
                [1] = {
                    ["skill"] = "HIGH",
                    ["coldAtStart"] = false,
                    ["type"] = _groundUnitType, --"Leclerc"
                    ["unitId"] = math.random(1000,99999),
                    ["y"] = _groundPosY,
                    ["x"] = _groundPosX,
                    ["name"] = _groundGroupName, --..math.random(1,99),
                    ["heading"] = math.random(0,359),
                    ["playerCanDrive"] = true,
                },
            },
            ["y"] = _groundPosY,
            ["x"] = _groundPosX,
            ["name"] = _groundGroupName,
            ["start_time"] = 0,
        }
        
        coalition.addGroup(_groupCoalition, Group.Category.GROUND, _groupData)
    end


--%%% UPDATE SPAWNED TABLE %%%
    function PWS_updateSpawnedTable()
        if PWS.saveBirthBlue == true or PWS.saveBirthRed == true then
            _tempTable = {}
            
            for i = 1, #PWS_Spawned do

                if PWS_Spawned[i]
                and PWS_Spawned[i].unitCoalition
                and PWS_Spawned[i].unitObjectCategory
                and PWS_Spawned[i].UnitCategory
                and PWS_Spawned[i].unitType
                and PWS_Spawned[i].unitName
                and PWS_Spawned[i].vec3Z
                and PWS_Spawned[i].vec3X
                then
                    _currentUnit = Unit.getByName(PWS_Spawned[i].unitName)

                    if _currentUnit and _currentUnit:getLife() >= 1 then
                        --trigger.action.outText("Persistent World | Update Spawned : "..PWS_Spawned[i].unitName.." is alive !",5)

                        _currentPos = _currentUnit:getPoint()

                        _tempTable[#_tempTable+1] = {}
                        _tempTable[#_tempTable].unitCoalition = PWS_Spawned[i].unitCoalition
                        _tempTable[#_tempTable].unitObjectCategory = PWS_Spawned[i].unitObjectCategory
                        _tempTable[#_tempTable].UnitCategory = PWS_Spawned[i].UnitCategory
                        _tempTable[#_tempTable].unitType = PWS_Spawned[i].unitType
                        _tempTable[#_tempTable].unitName = PWS_Spawned[i].unitName
                        _tempTable[#_tempTable].vec3Z = _currentPos.z
                        _tempTable[#_tempTable].vec3X = _currentPos.x
                    else
                        --trigger.action.outText("Persistent World | Update Spawned : L'unité n'existe plus",5)
                    end
                else
                    trigger.action.outText("Persistent World | Update Spawned : 1 loop skipped, a nil value ",5)
                end
            end

            PWS_Spawned = _tempTable
            --trigger.action.outText("Persistent World | Update Update Spawned : complete",5)
        end
    end



--%%% UPDATE MARKS TABLE %%%
    function PWS_updateMarksTable()
        if PWS.saveMarksBlue == true or PWS.saveMarksRed ==true then
            _tempTable = {}
            _worldMarks = world.getMarkPanels()

            for i = 1, #_worldMarks do
                if _worldMarks[i].text and _worldMarks[i].text ~= "" then
                    _match = 0
                    for y=1, #PWS.escapeTextFromMarksList do
                        if string.match(_worldMarks[i].text, PWS.escapeTextFromMarksList[y]) then _match = _match + 1 end
                    end
                    if _match ~= 0 then
                        --trigger.action.outText("Persistent World | Mark ignored", 5)
                    else
                        _tempTable[#_tempTable+1] = {}
                        _tempTable[#_tempTable].idx = _worldMarks[i].idx
                        _tempTable[#_tempTable].coalition = _worldMarks[i].coalition
                        _tempTable[#_tempTable].text = _worldMarks[i].text
                        _tempTable[#_tempTable].pos = _worldMarks[i].pos
                    end
                end
            end
            PWS_Marks = _tempTable
            --trigger.action.outText("Persistent World | Update Update Marks : complete",5)
        end
    end



--%%% SAVE FUNCTION FOR UNITS %%%
    function PWS_SaveDeadUnits(timeloop, time)
        _deadUnitsStr = IntegratedserializeWithCycles("PWS_Units", PWS_Units)
        writemission(_deadUnitsStr, PWS_DeadUnitsSaveFile)
        trigger.action.outText("Persistent World | Progress Has Been Saved", 2)
        return time + PWS.SaveSchedule
    end

    function PWS_SaveDeadUnitsNoArgs()
        _deadUnitsStr = IntegratedserializeWithCycles("PWS_Units", PWS_Units)
        writemission(_deadUnitsStr, PWS_DeadUnitsSaveFile)
    end

--%%% SAVE FUNCTION FOR STATICS %%%
    function PWS_SaveDeadStatics(timeloop, time)
        _deadStaticsStr = IntegratedserializeWithCycles("PWS_Statics", PWS_Statics)
        writemission(_deadStaticsStr, PWS_DeadStaticsSaveFile)
        --trigger.action.outText("Progress Has Been Saved", 15)	
        return time + PWS.SaveSchedule
    end

    function PWS_SaveDeadStaticsNoArgs()
        _deadStaticsStr = IntegratedserializeWithCycles("PWS_Statics", PWS_Statics)
        writemission(_deadStaticsStr, PWS_DeadStaticsSaveFile)
    end

--%%% SAVE FUNCTION FOR SPAWNED %%%
    function PWS_saveSpawned(timeloop, time)
        
        PWS_updateSpawnedTable()
        
        _spawnedStr = IntegratedserializeWithCycles("PWS_Spawned", PWS_Spawned)
        writemission(_spawnedStr, PWS_SpawnedUnitsSaveFile)
        return time + PWS.SaveSchedule
    end

    function PWS_saveSpawnedTableNoArgs()
        _spawnedStr = IntegratedserializeWithCycles("PWS_Spawned", PWS_Spawned)
        writemission(_spawnedStr, PWS_SpawnedUnitsSaveFile)	
    end



--%%% SAVE FUNCTION FOR MARKS %%%
    function PWS_saveMarks(timeloop, time)
            
        PWS_updateMarksTable()
        
        _marksStr = IntegratedserializeWithCycles("PWS_Marks", PWS_Marks)
        writemission(_marksStr, PWS_MarksSaveFile)
        return time + PWS.SaveSchedule
    end

    function PWS_saveMarksTableNoArgs()
        _marksStr = IntegratedserializeWithCycles("PWS_Marks", PWS_Marks)
        writemission(_marksStr, PWS_MarksSaveFile)	
    end


--[[
    
    MAIN

]]--

PWSDeletedUnitCount = 0
PWSDeletedStaticCount = 0

trigger.action.outText("Persistent World | Loading...  -  Credits : JGi | Quéton 1-1", 5)

if os ~= nil then

	--%%% LOAD DEAD STATICS %%%
	if file_exists(PWS_DeadStaticsSaveFile) then
		
		dofile(PWS_DeadStaticsSaveFile)
		
        for i = 1, #PWS_Statics do
			
			if ( StaticObject.getByName(PWS_Statics[i]) ~= nil ) then		
				StaticObject.getByName(PWS_Statics[i]):destroy()		
				PWSDeletedStaticCount = PWSDeletedStaticCount + 1
			elseif ( Unit.getByName(PWS_Statics[i]) ~= nil ) then
				Unit.getByName(PWS_Statics[i]):destroy()
				PWSDeletedUnitCount = PWSDeletedUnitCount + 1
			else
				trigger.action.outText("Static "..i.." Is "..PWS_Statics[i].." And Was Not Found", 2)
			end	
		end
		trigger.action.outText("Persistent World | Removed "..PWSDeletedStaticCount.." Static(s)", 5)
	else
		PWS_Statics = {}
		StaticIntermentTableLength = 0	
	end

	--%%% LOAD DEAD UNITS %%%
	if file_exists(PWS_DeadUnitsSaveFile) then	
		dofile(PWS_DeadUnitsSaveFile)
        for i = 1, #PWS_Units do	
			
			if ( Unit.getByName(PWS_Units[i]) ~= nil ) then
				Unit.getByName(PWS_Units[i]):destroy()
				PWSDeletedUnitCount = PWSDeletedUnitCount + 1
			else
				trigger.action.outText("Unit "..i.." Is "..PWS_Units[i].." And Was Not Found", 2)
			end	
		end
		trigger.action.outText("Persistent World | Removed "..PWSDeletedUnitCount.." Unit(s)", 5)
	else			
		PWS_Units = {}	
		trigger.action.outText("Persistent World | No save found, creating new files...", 5)	
	end

    --%%% LOAD SPAWNED UNITS %%%
    if PWS.saveBirthBlue == true or PWS.saveBirthRed == true then
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
            trigger.action.outText("Persistent World | No Spawned save file"..groupName,5)			
            PWS_Spawned = {}	
        end
    end

    --%%% LOAD MARKS %%%
    if PWS.saveMarksBlue == true or PWS.saveMarksRed == true then
        if file_exists(PWS_MarksSaveFile) then	
            --trigger.action.outText("Persistent World | Loads units spawned in the past...",5)
            
            dofile(PWS_MarksSaveFile)
            
            _restoredMarks = 0

            if PWS_Marks then            
                for i = 1, #PWS_Marks do
                    
                    if PWS_Marks[i]
                    and PWS_Marks[i].coalition
                    and PWS_Marks[i].idx
                    and PWS_Marks[i].text
                    and PWS_Marks[i].pos
                    then
                        trigger.action.markToCoalition(PWS_Marks[i].idx , PWS_Marks[i].text , PWS_Marks[i].pos, PWS_Marks[i].coalition , false) --optionnal ,string message)

                        _restoredMarks = _restoredMarks + 1
                    else
                        trigger.action.outText("Persistent World | Restoring Marks : One loop skip, a nil value",5)
                    end	
                    i = i+1
                end
                trigger.action.outText("Persistent World | Restored ".._restoredMarks.." Mark(s)",5)
            end
        else		
            trigger.action.outText("Persistent World | No Marks save file",5)
            PWS_Marks = {}
        end
    end




	--[[
		
		SCHEDULE

	]]--

	timer.scheduleFunction(PWS_SaveDeadUnits, 53, timer.getTime() + PWS.SaveSchedule)
	timer.scheduleFunction(PWS_SaveDeadStatics, 53, timer.getTime() + (PWS.SaveSchedule))
    timer.scheduleFunction(PWS_saveSpawned, nil, timer.getTime() + PWS.SaveSchedule)
    timer.scheduleFunction(PWS_saveMarks, nil, timer.getTime() + PWS.SaveSchedule)



	--[[
		
		EVENT LOOP

	]]--


    --%%% ON DEAD, LOST, KILL %%%
        PWS_ONDEADEVENTHANDLER = {}
        function PWS_ONDEADEVENTHANDLER:onEvent(Event)
            
            if Event.id == world.event.S_EVENT_DEAD or Event.id == world.event.S_EVENT_UNIT_LOST or Event.id == world.event.S_EVENT_KILL then
                if Event.initiator and Event.initiator:getCoalition() ~= nil then
                    if ( Event.initiator:getCategory() == 1 or Event.initiator:getCategory() == 3 ) then -- UNIT or STATIC
                        
                        if Event.id == world.event.S_EVENT_DEAD or Event.id == world.event.S_EVENT_UNIT_LOST then
                            DeadUnit 				 = Event.initiator
                            DeadUnitObjectCategory = Event.initiator:getCategory() 
                            -- 1 UNIT / 2 WEAPON / 3 STATIC / 4 BASE / 5 SCENERY / 6 CARGO
                            DeadUnitCategory 		 = Event.initiator:getDesc().category 
                            -- 0 AIRPLANE / 1 HELICOPTER / 2 GROUND_UNIT / 3 SHIP / 4 STRUCTURE
                            DeadUnitCoalition 	 = Event.initiator:getCoalition()
                            DeadUnitName			 = Event.initiator:getName()
                            DeadUnitType			 = Event.initiator:getTypeName()

                        elseif Event.id == world.event.S_EVENT_KILL then
                            DeadUnit 				 = Event.target
                            DeadUnitObjectCategory = Event.target:getCategory()
                            -- 1 UNIT / 2 WEAPON / 3 STATIC / 4 BASE / 5 SCENERY / 6 CARGO
                            DeadUnitCategory 		 = Event.target:getDesc().category
                            -- 0 AIRPLANE / 1 HELICOPTER / 2 GROUND_UNIT / 3 SHIP / 4 STRUCTURE
                            DeadUnitCoalition 	 = Event.target:getCoalition()
                            DeadUnitName			 = Event.target:getName()
                            DeadUnitType			 = Event.target:getTypeName()
                        else
                        end
                        
                        if ( DeadUnitCoalition == 1 or DeadUnitCoalition == 2 and PWS.saveDeadBlue == true) then	
                            if DeadUnitObjectCategory == 1 then -- UNIT
                                if ( DeadUnitCategory == 2 or DeadUnitCategory == 3 ) then -- GROUND_UNIT or SHIP
                                    --trigger.action.outText("Persistent World | "..DeadUnitType, 60)

                                    match = 0
                                    for i=1, #PWS.escapeTypeFromDeadList do
                                        if string.match(DeadUnitType, PWS.escapeTypeFromDeadList[i]) then match = match + 1 end
                                    end
                                    for i=1, #PWS.escapeNameFromDeadList do
                                        if string.match(DeadUnitName, PWS.escapeNameFromDeadList[i]) then match = match + 1 end
                                    end
                                    if match ~= 0 then  
                                        --trigger.action.outText("Persistent World | Unit ignored", 5)
                                    else
                                        match = 0
                                        for i=1, #PWS_Units do
                                            if PWS_Units[i] == DeadUnitName then match = match + 1 end
                                        end
                                        if match == 0 then
                                            PWS_Units[#PWS_Units+1] = DeadUnitName
                                        end
                                        --trigger.action.outText("Persistent World | Unit added (Dead)", 10)
                                    end	
                                else
                                end
                            elseif DeadUnitObjectCategory == 3 then	-- STATIC
                                match = 0
                                for i=1, #PWS_Statics do
                                    if PWS_Statics[i] == DeadUnitName then match = match + 1 end
                                end
                                if match == 0 then
                                    PWS_Statics[#PWS_Statics+1] = DeadUnitName
                                end
                                --trigger.action.outText("Persistent World | Static "..DeadUnitName.." destroyed ", 10)			
                            else
                            end
                        else
                        end
                        
                    end	
                end
            end
        end
        world.addEventHandler(PWS_ONDEADEVENTHANDLER)



    --%%% ON BIRTH %%%
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

                            if ( BirthUnitCoalition == 1 and PWS.saveBirthRed == true or BirthUnitCoalition == 2 and PWS.saveBirthBlue == true) then
                                if BirthUnitObjectCategory == 1 and BirthUnitCategory == 2 then -- UNIT
                                    _match = 0
                                    for i=1, #PWS.escapeNameFromBirthList do
                                        if string.match(BirthUnitName, PWS.escapeNameFromBirthList[i]) then _match = _match + 1 end
                                    end
                                    if _match ~= 0 then  
                                        trigger.action.outText("Persistent World | Birth Unit ignored", 5)
                                    else
                                        PWS_Spawned[#PWS_Spawned+1] = {}
                                        PWS_Spawned[#PWS_Spawned].unitCoalition = BirthUnitCoalition
                                        PWS_Spawned[#PWS_Spawned].unitObjectCategory = BirthUnitObjectCategory
                                        PWS_Spawned[#PWS_Spawned].UnitCategory = BirthUnitCategory
                                        PWS_Spawned[#PWS_Spawned].unitType = BirthUnitType
                                        PWS_Spawned[#PWS_Spawned].unitName = BirthUnitName
                                        PWS_Spawned[#PWS_Spawned].vec3Z = BirthUnitVec3Z
                                        PWS_Spawned[#PWS_Spawned].vec3X = BirthUnitVec3X

                                        --trigger.action.outText("Persistent World | Event : "..PWS_Spawned[#PWS_Spawned].unitName.." added to table", 5)
                                    --else --nothing
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

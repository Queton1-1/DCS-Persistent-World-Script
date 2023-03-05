--[[
    -= PERSISTENT WORLD SCRIPT =-

    Credits :
    Surrexen via Pikey's Simple Group Saving Script
    Rework by JGi | Quéton 1-1

--]]



--[[ 
    
    PARAMS
    
]]--

-- Temps entre deux saves
-- Time between saves
SaveScheduleUnits = 300

-- /!\ Préfixe de la sauvegarde
-- Save file prefix
saveFileName = "Plop"

-- Activer sauvegarde unités detruites Bleu (true/false)
-- If set to true, save blue coalition also.
saveDeadBlue = false



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

--////SAVE FUNCTION FOR UNITS
function PWS_SaveUnitIntermentTable(timeloop, time)
	IntermentMissionStr = IntegratedserializeWithCycles("PWS_Units", PWS_Units)
	writemission(IntermentMissionStr, saveFileName.."_PWS_Units.lua")
	trigger.action.outText("Persistent World | Progress Has Been Saved", 2)
	return time + SaveScheduleUnits
end

function PWS_SaveUnitIntermentTableNoArgs()
	IntermentMissionStr = IntegratedserializeWithCycles("PWS_Units", PWS_Units)
	writemission(IntermentMissionStr, saveFileName.."_PWS_Units.lua")		
end

--////SAVE FUNCTION FOR STATICS
function PWS_SaveStaticIntermentTable(timeloop, time)
	IntermentMissionStrStatic = IntegratedserializeWithCycles("PWS_Statics", PWS_Statics)
	writemission(IntermentMissionStrStatic, saveFileName.."_PWS_Statics.lua")
	--trigger.action.outText("Progress Has Been Saved", 15)	
	return time + SaveScheduleUnits
end

function PWS_SaveStaticIntermentTableNoArgs()
	IntermentMissionStrStatic = IntegratedserializeWithCycles("PWS_Statics", PWS_Statics)
	writemission(IntermentMissionStrStatic, saveFileName.."_PWS_Statics.lua")	
end



--[[
    
    MAIN

]]--

PWSDeletedUnitCount = 0
PWSDeletedStaticCount = 0

trigger.action.outText("Persistent World | Loading...  -  Credits : Pikey / Surrexen / JGi", 5)

if os ~= nil then

	--////LOAD STATICS
	if file_exists(saveFileName.."_PWS_Statics.lua") then
		
		dofile(saveFileName.."_PWS_Statics.lua")
			
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
				trigger.action.outText("Static Interment Element "..i.." Is "..PWS_Statics[i].." And Was Not Found", 15)
			end	
		end
		trigger.action.outText("Persistent World | Removed "..PWSDeletedStaticCount.." Static(s)", 5)
	else
		PWS_Statics = {}
		StaticIntermentTableLength = 0	
	end

	--////LOAD UNITS
	if file_exists(saveFileName.."_PWS_Units.lua") then	
		
		dofile(saveFileName.."_PWS_Units.lua")
		
		UnitIntermentTableLength = PWS_GetTableLength(PWS_Units)	
		--trigger.action.outText("Unit Table Length Is "..UnitIntermentTableLength, 15)
			
		for i = 1, UnitIntermentTableLength do
			--trigger.action.outText("Unit Interment Element "..i.." Is "..PWS_Units[i], 15)		
			
			if ( Unit.getByName(PWS_Units[i]) ~= nil ) then
				Unit.getByName(PWS_Units[i]):destroy()
				PWSDeletedUnitCount = PWSDeletedUnitCount + 1
			else
				trigger.action.outText("Unit Interment Element "..i.." Is "..PWS_Units[i].." And Was Not Found", 15)
			end	
		end
		trigger.action.outText("Persistent World | Removed "..PWSDeletedUnitCount.." Unit(s)", 5)
	else			
		PWS_Units = {}	
		UnitIntermentTableLength = 0
		trigger.action.outText("Persistent World | No save found, creating new files...", 5)	
	end



	--[[
		
		SCHEDULE

	]]--

	--trigger.action.outText("Persistent World Functions Schedulers Are Currently Disabled", 15)
	timer.scheduleFunction(PWS_SaveUnitIntermentTable, 53, timer.getTime() + SaveScheduleUnits)
	timer.scheduleFunction(PWS_SaveStaticIntermentTable, 53, timer.getTime() + (SaveScheduleUnits + 3))



	--[[
		
		EVENT LOOP

	]]--
	PWS_ONDEADEVENTHANDLER = {}
	function PWS_ONDEADEVENTHANDLER:onEvent(Event)
		
		if Event.id == world.event.S_EVENT_DEAD then
			if Event.initiator then
				if ( Event.initiator:getCategory() == 1 or Event.initiator:getCategory() == 3 ) then 	-- UNIT or STATIC
					if ( Event.initiator:getCoalition() ~= nil ) then
					
						local DeadUnit 				 = Event.initiator
						local DeadUnitObjectCategory = Event.initiator:getCategory()						-- 1 UNIT / 2 WEAPON / 3 STATIC / 4 BASE / 5 SCENERY / 6 CARGO
						local DeadUnitCategory 		 = Event.initiator:getDesc().category					-- 0 AIRPLANE / 1 HELICOPTER / 2 GROUND_UNIT / 3 SHIP / 4 STRUCTURE
						local DeadUnitCoalition 	 = Event.initiator:getCoalition()
						local DeadUnitName			 = Event.initiator:getName()
						local DeadUnitType			 = Event.initiator:getTypeName()
						
						if ( DeadUnitCoalition == 1 or DeadUnitCoalition == 2 and saveDeadBlue == true) then													-- RED ONLY AT THIS STAGE	
							if DeadUnitObjectCategory == 1 then 										-- UNIT
								if ( DeadUnitCategory == 2 or DeadUnitCategory == 3 ) then 					-- GROUND_UNIT or SHIP
									--trigger.action.outText("Persistent World | "..DeadUnitType, 60)
									--if ( string.find(DeadUnitName, "Russian APC Tigr 233036") ) or
									if ( string.match(DeadUnitType, "CVN_59") or string.match(DeadUnitType, "CVN_7") or string.match(DeadUnitType, "KUZNECOW") or string.match(DeadUnitType, "CV_1143_5") ) then  
										trigger.action.outText("Persistent World | Carrier Unit ignored", 5)
										--Do nothing we don't want to include these units in the list currently
									else					
										UnitIntermentTableLength = UnitIntermentTableLength + 1				
										PWS_Units[UnitIntermentTableLength] = DeadUnitName
										--trigger.action.outText("Persistent World | Unit added", 10)
									end	
								else
								end
							elseif ( DeadUnitObjectCategory == 3 ) then 									-- STATIC
								StaticIntermentTableLength = StaticIntermentTableLength + 1			
								PWS_Statics[StaticIntermentTableLength] = DeadUnitName												
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
else
    trigger.action.outText("Persistent World | Error, MissionScripting.lua 'sanitize'.", 10)
end
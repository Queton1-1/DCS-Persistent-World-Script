
--[[%%%%% -= PERSISTENT WORLD SCRIPT =- %%%%%
    Credits :
    JGi | Quéton 1-1
    [♥] à Pikey pour les bases.
--]]


--[[%%%%% CHANGELOG %%%%%
    2.16a 08/02/2026
    - Gros dépoussiérage du code, tri et renommage de variables, refactor de fonctions etc...
    - correction saveFileName="MISSION_UNKNOWN"
    - ajustement délais de save : 15 minutes
    - ajout gestion évenementiel des Marks
    - ajout gestion des warehouses
    - suppr. des changelogs antérieurs à 2.14b

    2.15b
    - correction du check de coalition dans SpawnMe()

    2.15a
        27/04/2025
        Suppr anciennes fonctions de spawn
        Ajout generation nom savegarde fonction du nom de mission

    2.14b
        26/04/2025
        - ajout namePatternList
        - correction spawn unit 1 > 01
        - ajout option debugSaveSchedule

        29/03/2025
        - Ajout spawn farp et refill
--]]


--[[%%%%% TODO - NEXT FEATURES %%%%%
    Pas d'idée pour l'instant
--]]


--%%%%% PARAMS %%%%%
    --> Temps entre deux sauvegardes (sec)
    --> Time between saves (in sec), default 15 minutes
    local userSaveSchedule = 900

    --> /!\ Préfixe de la sauvegarde - à régler pour chaque mission
    --> Save file prefix - each mission needs a different setting
    local useCustomSaveFileName = false
    local saveFileName = "Plop"

    --> Activer sauvegarde unités detruites Bleu (true/false)
    --> If set to true, save blue coalition also.
    local saveDeadBlue = true
    local saveDeadRed = true

    --> Activer sauvegarde unités spawnées Bleu/rouge (true/false)
    --> If set to true, save blue coalition also.
    local saveBirthBlue = true
    local saveBirthRed = true

    --> Activer sauvegarde unités statiques spawnées Bleu/rouge (true/false)
    --> If set to true, save blue coalition also.
    local saveStaticsBirthBlue = true
    local saveStaticsBirthRed = true

    --> Activer sauvegarde des Marks (true/false)
    --> If set to true, save Marks also.
    local saveMarksBlue = true
    local saveMarksRed = true

    --> Activer sauvegarde des WareHouses (true/false)
    --> If set to true, save WH also.
    local saveWarehouses = true

    --> Liste de nom à exclure de la save
    --> Names or prefix to escape save
    local ignoredNamesToDeadList = {
        "Wounded Pilot",
        "TTGT",
        "ttgt",
        "Training target",
        "Procedural",
        "CTLD",
    }
    local ignoredTypesToDeadList = {
        "Forrestal",
        "CVN",
        "Stennis",
        "KUZNECOW",
        "CV_1143_5",
        "LHA_Tarawa",
        "hms_invincible",
        "ara_vdm",
    }
    local ignoredNamesToUnitBirthList = {
        "Wounded Pilot",
        "TTGT",
        "ttgt",
        "Training target",
        "Procedural",
        --"SOM",
        --"som",
    }
    local ignoredTextsToMarkList = {
        "SOM",
        "som",
    }
    local savedTypesToStaticBirthList = {
        ["Invisible FARP"] = "Heliports",
        ["FARP_SINGLE_01"] = "Heliports",
        ["FARP"] = "Heliports",
        ["Windsock"] = "Structures",
        ["Container_watchtower_lights"] = "Structures",
        ["FARP Ammo Dump Coating"] = "Structures",
        ["FARP Fuel Depot"] = "Structures",
        ["FARP Tent"] = "Structures",
        ["FARP CP Blindage"] = "Structures",
        ["Building01_PBR"] = "Structures",
        ["Building02_PBR"] = "Structures",
        ["Building03_PBR"] = "Structures",
        ["Building04_PBR"] = "Structures",
        ["Building05_PBR"] = "Structures",
        ["Building06_PBR"] = "Structures",
        ["Building07_PBR"] = "Structures",
        ["Building08_PBR"] = "Structures",
        ["Tech combine"] = "Structures",
        ["Workshop A"]="Structures",
        ["Warehouse"]="Structures",
        ["Ski Ramp"]="Structures",
    }
    local staticTypesAndShape ={
        ["Invisible FARP"] = "invisiblefarp",
        ["FARP_SINGLE_01"] = "FARP_SINGLE_01",
        ["FARP"] = "FARPS",
        ["Windsock"] = "H-Windsock_RW",
        ["Container_watchtower_lights"] = "M92_Container_watchtower_lights",
        ["FARP Ammo Dump Coating"] = "SetkaKP",
        ["FARP Fuel Depot"] = "GSM Rus",
        ["FARP Tent"] = "PalatkaB",
        ["FARP CP Blindage"] = "kp_ug",
        ["Building01_PBR"] = "M92_Building01_PBR",
        ["Building02_PBR"] = "M92_Building02_PBR",
        ["Building03_PBR"] = "M92_Building03_PBR",
        ["Building04_PBR"] = "M92_Building04_PBR",
        ["Building05_PBR"] = "M92_Building05_PBR",
        ["Building06_PBR"] = "M92_Building06_PBR",
        ["Building07_PBR"] = "M92_Building07_PBR",
        ["Building08_PBR"] = "M92_Building08_PBR",
        ["Tech combine"] = "kombinat",
        ["Workshop A"]="tec_a",
        ["Warehouse"]="sklad",
        ["Ski Ramp"]="SkiRamp_01",
    }
    --> Pattern dans les noms
    local useNamePattern = false
    local namePatternList={"CTLD",}
    --> CallSigns
    local callsignTable={
        jtac={
            "Axeman",	
            "Darknight",
            "Warrior",
            "Pointer",	
            "Eyeball",	
            "Moonbeam",	
            "Whiplash",	
            "Finger",	
            "Pinpoint",	
            "Ferret",	
            "Shaba",	
            "Playboy",	
            "Hammer",	
            "Jaguar",	
            "Deathstar",	
            "Anvil",	
            "Firefly",	
            "Mantis",	
            "Badger",
        },
        tanker={
            "Texaco",
            "Arco",
            "Shell",
        },
        aircraft={
            "Enfield",
            "Springfield",
            "Uzi",
            "Colt",
            "Dodge",
            "Ford",
            "Chevy", 
            "Pontiac",
        },
        transport={
            "Heavy",
            "Trash",
            "Cargo",
            "Ascot",
        },
        awacs={
            "Overlord",
            "Magic",
            "Wizard",
            "Focus",
            "Darkstar",
        },
        farp={
            "London",
            "Dallas",
            "Paris",
            "Moscow",
            "Berlin",
            "Rome",
            "Madrid",
            "Warsaw",
            "Dublin",
            "Perth",
        },
    }
    --> DEBUG Mode
    local DEBUG_MODE = false
    local debugSaveSchedule = 30
    --> Misc
    local saveSchedule = userSaveSchedule
    local defaultSaveFileName="UNKNOWN_MISSION"

--%%%%% VARIABLES %%%%%
    PWS = {}
    PWS_deadUnitsTable = {}
    PWS_deadStaticsTable = {}
    PWS_spawnedUnitsTable = {}
    PWS_spawnedStaticsTable = {}
    PWS_marksTable = {}
    PWS_warehousesTable = {}

    local MathRan = math.random
    local WriteDir = lfs.writedir
    local MkDir = lfs.mkdir
    local Attributes = lfs.attributes
    local OpenFile = io.open
    local Msg=trigger.action.outText
    local Log = env.info
    local StrMatch = string.match
    local StrSub = string.sub
    local Floor = math.floor
    local AddGroup=coalition.addGroup
    local Explode=trigger.action.explosion
    local ScheduleFunction=timer.scheduleFunction
    local StrGsub=string.gsub
    local Sin=math.sin
    local Cos=math.cos
    local ToNumber=tonumber
    local GetTime=timer.getTime
    
    if useCustomSaveFileName==false and env.mission then
        local mizName = env.getValueDictByKey(env.mission.sortie)
        mizName = StrSub(mizName:gsub('[^%w._-]', ''), 1,10)
        if mizName~="" then
            saveFileName=mizName
        else
            saveFileName=defaultSaveFileName
        end
    else
        saveFileName=defaultSaveFileName
    end
    --> Dossier de sauvegarde (défaut : \Saved Games\DCS.PWS_saves)
    --> Save folder location
    local saveDir = WriteDir().."..\\DCS.Persistence\\"
    local deadUnitsSaveFile = saveDir..saveFileName.."_PWS_dead_units.lua"
    local deadStaticsSaveFile = saveDir..saveFileName.."_PWS_dead_statics.lua"
    local spawnedUnitsSaveFile = saveDir..saveFileName.."_PWS_spawned_units.lua"
    local spawnedStaticsSaveFile = saveDir..saveFileName.."_PWS_spawned_statics.lua"
    local marksSaveFile = saveDir..saveFileName.."_PWS_marks.lua"
    local warehousesSaveFile = saveDir..saveFileName.."_PWS_warehouses.lua"

--%%%%% TOOLKIT FUNCTIONS %%%%%
    local function DebugLog(msg)
        if DEBUG_MODE == true then
            Log("Persistent World | "..msg)
            Msg("Persistent World | "..msg,120)
        end
    end
    local function ClearMsg()
        Msg("",1,true)
    end
    local function BasicSerialize(data)
        if data == nil then
            return "\"\""
        else
            if ((type(data) == 'number') or (type(data) == 'boolean') or (type(data) == 'function') or (type(data) == 'table') or (type(data) == 'userdata') ) then
                return tostring(data)
            elseif type(data) == 'string' then
                return string.format('%q', data)
            end
        end
    end
    local function SmartSerialize(name, value, saved)
        local Serialize = function (data)
            if type(data) == "number" then
                return tostring(data)
            elseif type(data) == "boolean" then
                return tostring(data)
            else
                return BasicSerialize(data)
            end
        end
        local t_str = {}
        saved = saved or {}
        if ((type(value) == 'string') or (type(value) == 'number') or (type(value) == 'table') or (type(value) == 'boolean')) then
            table.insert(t_str, name .. " = ")
            if type(value) == "number" or type(value) == "string" or type(value) == "boolean" then
                table.insert(t_str, Serialize(value) ..  "\n")
            else
                if saved[value] then
                    table.insert(t_str, saved[value] .. "\n")
                else
                    saved[value] = name
                    table.insert(t_str, "{}\n")
                        for k,v in pairs(value) do
                            local fieldname = string.format("%s[%s]", name, Serialize(k))
                            table.insert(t_str, SmartSerialize(fieldname, v, saved))
                        end
                end
            end
            return table.concat(t_str)
        else
            return ""
        end
    end
    local function FileExists(fileToTest)
        if Attributes(fileToTest) then
            return true
        else
            return false end 
    end
    local function IsDir(path)
        return lfs.attributes(path, "mode") == "directory"
    end
    local function WriteDatas(data, file)
        local saveFile = OpenFile(file, "w")
        saveFile:write(data)
        saveFile:close()
    end
    --%%% SPAWNER 2.0 %%%
        --- SpawnMe : spawn units, ships, airplanes, or statics from passed data table
        -- @params data table : see data substructure to add needed args
        -- @params data.coalition : red or blue
        -- @params data.objectCategory : 1 UNIT / 2 WEAPON / 3 STATIC / 4 BASE / 5 SCENERY / 6 CARGO
        -- @params data.objectSubCategory : 0 AIRPLANE / 1 HELICOPTER / 2 GROUND_UNIT / 3 SHIP / 4 STRUCTURE
        -- @params data.x
        -- @params data.y
        -- @params data.h : altitude, statics & farp only
        -- @params data.units[1].type : unit type
        -- @params data.wpt : waypoints table like data.wpt[1]={x,y,name}
        --
        -- >> OPTIONAL
        -- @params data.freq : optional unit's radio frequency used before data.options.freq
        -- @params data.alt : optional unit's altitude in kilofeet
        -- @params data.speed : optional unit's speed in knots
        -- @params data.braa : optional bearing and range table, like data.braa[1]={x,y}, need a parser function for conversion
        -- @params data.nb : optional unit's number in spawned group, 4 max
        -- @params data.heading : optional unit's heading
        -- 
        -- >> SPECIFIC GROUND_UNIT & SHIP
        -- @params data.options : sub table withs tasks & options structure for Ground/Ship :
        --    .immortal
        --    .invisible
        --    .hidden
        --    .uncontrollable
        --    .freq
        --    .datalink
        --    .roe : "free" "hold" "defensive"
        --    .dispersion : sec
        --    .alert : "red" "green" "auto"
        --    .engage : %
        --    .hold
        --    .jtac
        --    .jtacCallname
        --    .tacan : only for ships like carrier
        --    .tacanMode
        --    .tacanChannel
        --    .tacanFreq
        --    .tacanCallsign
        --
        -- >> SPECIFIC AIRPLANE
        -- @params data.options : sub table withs tasks & options structure for Airplane :
        --    .immortal
        --    .invisible
        --    .hidden
        --    .uncontrollable
        --    .freq
        --    .datalink
        --    .unlimitedFuel
        --    .roe : "free" "hold" "defensive" "designed" "priority"
        --    .threatReaction : "no reaction" "passive defence" "escape" "abort mission" "evade"
        --    .radarUse : "for search" "continuous" "for attack" "never"
        --    .flareUse : "on shoot" "never" "on sam threat" "near bandits"
        --    .rtbOnBingo
        --    .rtbOutOfAmmo : all 4294967295
        --    .jammerUse : "if locked" "never" "if detected" "always"
        --    .noAA
        --    .noJetisson
        --    .noAfterburner
        --    .noAG
        --    .missileStrategy : "threat level" "max range" "noez range" "half way" "random"
        --    .noWptReport
        --    .jetissonEmptyTank
        --    .tacan : only for tankers
        --    .tacanMode
        --    .tacanChannel
        --    .tacanFreq
        --    .tacanCallsign
        --
        -- >> SPECIFIC STATIC & FARP
        -- @params data.units[1]
        --    .type
        --    .category
        --    .shape
        --
    local function SpawnMe(data)
        local aircraftTypeTable = {
            --%%%%% MODS %%%%%
                "Bronco-OV-10A",
                "Hercules",
                "UH-60L",
                "OH-6A",
            --%%%%% CHOPPERS %%%%%
                "AH-64D_BLK_II",
                "Ka-50",
                "Ka-50_3",
                "Mi-8MT",
                "Mi-24P",
                "SA342L",
                "SA342M",
                "SA342Mistral",
                "SA342Minigun",
                "UH-1H",
                "OH58D",
                "CH-47Fbl1",
            --%%%%% AIRCRAFTS %%%%%
                "AV8BNA",
                "Yak-52",
            --%%%%% WARBIRDS %%%%%
                "Bf-109K-4",
                "Fw 190A8",
                "FW-190D9",
                "I-16",
                "MosquitoFBMkVI",
                "P-47D-30",
                "P-47D-40",
                "P-51D",
                "P-51D-30-NA",
                "SpitfireLFMkIX",
                "SpitfireLFMkIXCW",
                "TF-51D",
        }
        local callsignTable={
            jtac={
                "Axeman",	
                "Darknight",
                "Warrior",
                "Pointer",	
                "Eyeball",	
                "Moonbeam",	
                "Whiplash",	
                "Finger",	
                "Pinpoint",	
                "Ferret",	
                "Shaba",	
                "Playboy",	
                "Hammer",	
                "Jaguar",	
                "Deathstar",	
                "Anvil",	
                "Firefly",	
                "Mantis",	
                "Badger",
            },
            tanker={
                "Texaco",
                "Arco",
                "Shell",
            },
            aircraft={
                "Enfield",
                "Springfield",
                "Uzi",
                "Colt",
                "Dodge",
                "Ford",
                "Chevy", 
                "Pontiac",
            },
            transport={
                "Heavy",
                "Trash",
                "Cargo",
                "Ascot",
            },
            awacs={
                "Overlord",
                "Magic",
                "Wizard",
                "Focus",
                "Darkstar",
            },
            farp={
                "London",
                "Dallas",
                "Paris",
                "Moscow",
                "Berlin",
                "Rome",
                "Madrid",
                "Warsaw",
                "Dublin",
                "Perth",
            },
        }
        local warehouse={
            wsType={
            [1] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 10,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [1]
            [2] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 103,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [2]
            [3] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 1056,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [3]
            [4] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 107,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [4]
            [5] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 11,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [5]
            [6] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 12,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [6]
            [7] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 13,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [7]
            [8] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 14,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [8]
            [9] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 1469,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [9]
            [10] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 1470,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [10]
            [11] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 15,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [11]
            [12] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 152,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [12]
            [13] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 1551,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [13]
            [14] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 1552,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [14]
            [15] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 1553,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [15]
            [16] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 1554,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [16]
            [17] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 1555,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [17]
            [18] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 1556,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [18]
            [19] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 1572,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [19]
            [20] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 1573,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [20]
            [21] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 16,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [21]
            [22] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 1640,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [22]
            [23] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 1641,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [23]
            [24] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 1642,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [24]
            [25] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 17,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [25]
            [26] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 1700,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [26]
            [27] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 1715,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [27]
            [28] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 1716,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [28]
            [29] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 2144,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [29]
            [30] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 2145,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [30]
            [31] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 2146,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [31]
            [32] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 2380,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [32]
            [33] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 2381,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [33]
            [34] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 2382,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [34]
            [35] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 2383,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [35]
            [36] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 263,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [36]
            [37] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 264,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [37]
            [38] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 265,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [38]
            [39] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 266,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [39]
            [40] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 267,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [40]
            [41] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 274,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [41]
            [42] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 275,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [42]
            [43] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 294,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [43]
            [44] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 36,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [44]
            [45] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 38,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [45]
            [46] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 39,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [46]
            [47] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 41,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [47]
            [48] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 42,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [48]
            [49] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 465,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [49]
            [50] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 466,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [50]
            [51] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 468,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [51]
            [52] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 469,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [52]
            [53] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 484,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [53]
            [54] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 485,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [54]
            [55] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 5,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [55]
            [56] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 53,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [56]
            [57] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 54,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [57]
            [58] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 55,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [58]
            [59] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 56,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [59]
            [60] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 587,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [60]
            [61] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 589,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [61]
            [62] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 590,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [62]
            [63] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 593,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [63]
            [64] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 603,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [64]
            [65] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 604,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [65]
            [66] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 605,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [66]
            [67] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 609,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [67]
            [68] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 61,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [68]
            [69] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 610,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [69]
            [70] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 611,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [70]
            [71] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 616,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [71]
            [72] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 617,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [72]
            [73] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 662,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [73]
            [74] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 663,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [74]
            [75] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 664,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [75]
            [76] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 782,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [76]
            [77] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 783,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [77]
            [78] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 855,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [78]
            [79] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 928,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [79]
            [80] = 
            {
                ["wsType"] = 
                {
                    [1] = 1,
                    [2] = 3,
                    [3] = 43,
                    [4] = 929,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [80]
            [81] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 101,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [81]
            [82] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 1548,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [82]
            [83] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 1717,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [83]
            [84] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 1718,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [84]
            [85] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 1719,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [85]
            [86] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 1720,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [86]
            [87] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 1721,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [87]
            [88] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 19,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [88]
            [89] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 2114,
                }, -- end of ["wsType"]
                ["initialAmount"] = 1254,
            }, -- end of [89]
            [90] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 2138,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [90]
            [91] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 2139,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [91]
            [92] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 2140,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [92]
            [93] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 2141,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [93]
            [94] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 2142,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [94]
            [95] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 2148,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [95]
            [96] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 2149,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [96]
            [97] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 2286,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [97]
            [98] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 2287,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [98]
            [99] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 2288,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [99]
            [100] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 2475,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [100]
            [101] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 26,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [101]
            [102] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 28,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [102]
            [103] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 424,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [103]
            [104] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 425,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [104]
            [105] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 426,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [105]
            [106] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 461,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [106]
            [107] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 463,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [107]
            [108] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 486,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [108]
            [109] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 59,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [109]
            [110] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 62,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [110]
            [111] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 63,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [111]
            [112] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 64,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [112]
            [113] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 65,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [113]
            [114] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 74,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [114]
            [115] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 78,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [115]
            [116] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 808,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [116]
            [117] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 44,
                    [4] = 95,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [117]
            [118] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 45,
                    [4] = 142,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [118]
            [119] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 45,
                    [4] = 173,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [119]
            [120] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 45,
                    [4] = 1762,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [120]
            [121] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 45,
                    [4] = 1763,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [121]
            [122] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 45,
                    [4] = 25,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [122]
            [123] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 45,
                    [4] = 29,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [123]
            [124] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 45,
                    [4] = 295,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [124]
            [125] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 45,
                    [4] = 296,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [125]
            [126] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 45,
                    [4] = 30,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [126]
            [127] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 45,
                    [4] = 301,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [127]
            [128] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 45,
                    [4] = 37,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [128]
            [129] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 45,
                    [4] = 462,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [129]
            [130] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 45,
                    [4] = 464,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [130]
            [131] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 45,
                    [4] = 665,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [131]
            [132] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 45,
                    [4] = 681,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [132]
            [133] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 45,
                    [4] = 94,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [133]
            [134] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 45,
                    [4] = 968,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [134]
            [135] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 1057,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [135]
            [136] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 1294,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [136]
            [137] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 1295,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [137]
            [138] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 145,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [138]
            [139] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 1544,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [139]
            [140] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 1545,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [140]
            [141] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 1546,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [141]
            [142] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 1547,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [142]
            [143] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 160,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [143]
            [144] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 161,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [144]
            [145] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 170,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [145]
            [146] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 171,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [146]
            [147] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 174,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [147]
            [148] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 175,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [148]
            [149] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 176,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [149]
            [150] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 1764,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [150]
            [151] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 1765,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [151]
            [152] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 1766,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [152]
            [153] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 1767,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [153]
            [154] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 1768,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [154]
            [155] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 1769,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [155]
            [156] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 177,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [156]
            [157] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 1770,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [157]
            [158] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 1771,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [158]
            [159] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 18,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [159]
            [160] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 1813,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [160]
            [161] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 183,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [161]
            [162] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 184,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [162]
            [163] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 1919,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [163]
            [164] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 20,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [164]
            [165] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 2143,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [165]
            [166] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 2476,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [166]
            [167] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 2477,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [167]
            [168] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 2478,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [168]
            [169] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 2479,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [169]
            [170] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 2480,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [170]
            [171] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 2481,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [171]
            [172] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 2482,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [172]
            [173] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 2483,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [173]
            [174] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 2484,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [174]
            [175] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 2574,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [175]
            [176] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 2575,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [176]
            [177] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 2576,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [177]
            [178] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 2577,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [178]
            [179] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 2578,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [179]
            [180] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 286,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [180]
            [181] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 300,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [181]
            [182] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 428,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [182]
            [183] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 429,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [183]
            [184] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 588,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [184]
            [185] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 596,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [185]
            [186] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 824,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [186]
            [187] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 46,
                    [4] = 825,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [187]
            [188] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 47,
                    [4] = 104,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [188]
            [189] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 47,
                    [4] = 108,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [189]
            [190] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 47,
                    [4] = 1100,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [190]
            [191] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 47,
                    [4] = 1549,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [191]
            [192] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 47,
                    [4] = 4,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [192]
            [193] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 47,
                    [4] = 679,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [193]
            [194] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 47,
                    [4] = 680,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [194]
            [195] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 48,
                    [4] = 1168,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [195]
            [196] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 48,
                    [4] = 1169,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [196]
            [197] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 48,
                    [4] = 1170,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [197]
            [198] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 48,
                    [4] = 1171,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [198]
            [199] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 48,
                    [4] = 1172,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [199]
            [200] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 48,
                    [4] = 1173,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [200]
            [201] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 48,
                    [4] = 1174,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [201]
            [202] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 48,
                    [4] = 297,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [202]
            [203] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 48,
                    [4] = 58,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [203]
            [204] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 48,
                    [4] = 608,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [204]
            [205] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 48,
                    [4] = 666,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [205]
            [206] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 48,
                    [4] = 765,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [206]
            [207] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 48,
                    [4] = 766,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [207]
            [208] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 1550,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [208]
            [209] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 172,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [209]
            [210] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 268,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [210]
            [211] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 269,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [211]
            [212] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 270,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [212]
            [213] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 271,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [213]
            [214] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 272,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [214]
            [215] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 273,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [215]
            [216] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 298,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [216]
            [217] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 427,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [217]
            [218] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 467,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [218]
            [219] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 470,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [219]
            [220] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 66,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [220]
            [221] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 667,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [221]
            [222] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 668,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [222]
            [223] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 67,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [223]
            [224] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 82,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [224]
            [225] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 83,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [225]
            [226] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 84,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [226]
            [227] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 85,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [227]
            [228] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 86,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [228]
            [229] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 87,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [229]
            [230] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 88,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [230]
            [231] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 89,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [231]
            [232] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 90,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [232]
            [233] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 15,
                    [3] = 50,
                    [4] = 91,
                }, -- end of ["wsType"]
                ["initialAmount"] = 5550,
            }, -- end of [233]
            [234] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 100,
                    [4] = 143,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [234]
            [235] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 101,
                    [4] = 140,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [235]
            [236] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 101,
                    [4] = 141,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [236]
            [237] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 101,
                    [4] = 142,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [237]
            [238] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 101,
                    [4] = 154,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [238]
            [239] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 32,
                    [4] = 719,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [239]
            [240] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 32,
                    [4] = 849,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [240]
            [241] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 34,
                    [4] = 291,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [241]
            [242] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 34,
                    [4] = 91,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [242]
            [243] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 1,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [243]
            [244] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 10,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [244]
            [245] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 106,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [245]
            [246] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 11,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [246]
            [247] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 11037,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [247]
            [248] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 11038,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [248]
            [249] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 11039,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [249]
            [250] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 13,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [250]
            [251] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 135,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [251]
            [252] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 136,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [252]
            [253] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 14,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [253]
            [254] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 15,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [254]
            [255] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 16,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [255]
            [256] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 18,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [256]
            [257] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 19,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [257]
            [258] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 2,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [258]
            [259] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 21,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [259]
            [260] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 22,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [260]
            [261] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 23,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [261]
            [262] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 24,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [262]
            [263] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 26,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [263]
            [264] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 265,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [264]
            [265] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 266,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [265]
            [266] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 267,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [266]
            [267] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 268,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [267]
            [268] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 269,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [268]
            [269] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 27,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [269]
            [270] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 270,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [270]
            [271] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 3,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [271]
            [272] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 306,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [272]
            [273] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 307,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [273]
            [274] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 308,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [274]
            [275] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 309,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [275]
            [276] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 310,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [276]
            [277] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 320,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [277]
            [278] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 321,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [278]
            [279] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 322,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [279]
            [280] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 327,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [280]
            [281] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 333,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [281]
            [282] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 334,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [282]
            [283] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 335,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [283]
            [284] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 336,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [284]
            [285] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 337,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [285]
            [286] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 338,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [286]
            [287] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 339,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [287]
            [288] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 368,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [288]
            [289] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 371,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [289]
            [290] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 372,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [290]
            [291] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 395,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [291]
            [292] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 396,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [292]
            [293] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 397,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [293]
            [294] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 4,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [294]
            [295] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 403,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [295]
            [296] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 405,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [296]
            [297] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 409,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [297]
            [298] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 410,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [298]
            [299] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 412,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [299]
            [300] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 425,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [300]
            [301] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 426,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [301]
            [302] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 429,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [302]
            [303] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 446,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [303]
            [304] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 7,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [304]
            [305] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 7,
                    [4] = 9,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [305]
            [306] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 11031,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [306]
            [307] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 11035,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [307]
            [308] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 11040,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [308]
            [309] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 11050,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [309]
            [310] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 11051,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [310]
            [311] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 11052,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [311]
            [312] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 11053,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [312]
            [313] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 11054,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [313]
            [314] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 11092,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [314]
            [315] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 11093,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [315]
            [316] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 130,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [316]
            [317] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 132,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [317]
            [318] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 133,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [318]
            [319] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 138,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [319]
            [320] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 139,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [320]
            [321] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 263,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [321]
            [322] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 264,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [322]
            [323] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 271,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [323]
            [324] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 272,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [324]
            [325] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 273,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [325]
            [326] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 274,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [326]
            [327] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 278,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [327]
            [328] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 279,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [328]
            [329] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 280,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [329]
            [330] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 281,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [330]
            [331] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 282,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [331]
            [332] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 283,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [332]
            [333] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 284,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [333]
            [334] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 287,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [334]
            [335] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 289,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [335]
            [336] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 290,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [336]
            [337] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 292,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [337]
            [338] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 293,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [338]
            [339] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 295,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [339]
            [340] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 296,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [340]
            [341] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 297,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [341]
            [342] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 298,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [342]
            [343] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 301,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [343]
            [344] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 303,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [344]
            [345] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 304,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [345]
            [346] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 305,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [346]
            [347] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 311,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [347]
            [348] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 332,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [348]
            [349] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 352,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [349]
            [350] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 353,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [350]
            [351] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 354,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [351]
            [352] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 355,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [352]
            [353] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 362,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [353]
            [354] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 363,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [354]
            [355] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 373,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [355]
            [356] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 39,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [356]
            [357] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 399,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [357]
            [358] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 40,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [358]
            [359] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 407,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [359]
            [360] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 41,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [360]
            [361] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 415,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [361]
            [362] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 416,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [362]
            [363] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 422,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [363]
            [364] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 423,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [364]
            [365] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 424,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [365]
            [366] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 430,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [366]
            [367] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 431,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [367]
            [368] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 432,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [368]
            [369] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 433,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [369]
            [370] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 434,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [370]
            [371] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 435,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [371]
            [372] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 436,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [372]
            [373] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 437,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [373]
            [374] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 44,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [374]
            [375] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 443,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [375]
            [376] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 445,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [376]
            [377] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 45,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [377]
            [378] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 46,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [378]
            [379] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 47,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [379]
            [380] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 48,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [380]
            [381] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 49,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [381]
            [382] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 51,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [382]
            [383] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 53,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [383]
            [384] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 54,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [384]
            [385] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 55,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [385]
            [386] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 56,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [386]
            [387] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 58,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [387]
            [388] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 59,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [388]
            [389] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 60,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [389]
            [390] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 61,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [390]
            [391] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 62,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [391]
            [392] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 63,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [392]
            [393] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 64,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [393]
            [394] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 65,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [394]
            [395] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 66,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [395]
            [396] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 68,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [396]
            [397] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 70,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [397]
            [398] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 71,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [398]
            [399] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 72,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [399]
            [400] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 73,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [400]
            [401] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 74,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [401]
            [402] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 75,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [402]
            [403] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 76,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [403]
            [404] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 77,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [404]
            [405] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 4,
                    [3] = 8,
                    [4] = 78,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [405]
            [406] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 1000,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [406]
            [407] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 1002,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [407]
            [408] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 1003,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [408]
            [409] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 1004,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [409]
            [410] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 1005,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [410]
            [411] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 1006,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [411]
            [412] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 1007,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [412]
            [413] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 1009,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [413]
            [414] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 2558,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [414]
            [415] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 2559,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [415]
            [416] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 2560,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [416]
            [417] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 2561,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [417]
            [418] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 2562,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [418]
            [419] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 2563,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [419]
            [420] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 837,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [420]
            [421] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 839,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [421]
            [422] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 94,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [422]
            [423] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 95,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [423]
            [424] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 32,
                    [4] = 999,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [424]
            [425] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 11,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [425]
            [426] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 12,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [426]
            [427] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 14,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [427]
            [428] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 287,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [428]
            [429] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 288,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [429]
            [430] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 289,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [430]
            [431] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 290,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [431]
            [432] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 291,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [432]
            [433] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 292,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [433]
            [434] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 293,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [434]
            [435] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 351,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [435]
            [436] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 36,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [436]
            [437] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 38,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [437]
            [438] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 39,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [438]
            [439] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 41,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [439]
            [440] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 42,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [440]
            [441] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 43,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [441]
            [442] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 448,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [442]
            [443] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 459,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [443]
            [444] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 469,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [444]
            [445] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 47,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [445]
            [446] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 476,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [446]
            [447] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 48,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [447]
            [448] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 72,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [448]
            [449] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 85,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [449]
            [450] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 86,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [450]
            [451] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 36,
                    [4] = 92,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [451]
            [452] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 37,
                    [4] = 3,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [452]
            [453] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 37,
                    [4] = 330,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [453]
            [454] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 37,
                    [4] = 347,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [454]
            [455] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 37,
                    [4] = 384,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [455]
            [456] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 37,
                    [4] = 4,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [456]
            [457] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 37,
                    [4] = 437,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [457]
            [458] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 37,
                    [4] = 62,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [458]
            [459] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 18,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [459]
            [460] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 20,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [460]
            [461] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 23,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [461]
            [462] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 263,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [462]
            [463] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 265,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [463]
            [464] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 267,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [464]
            [465] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 295,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [465]
            [466] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 299,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [466]
            [467] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 301,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [467]
            [468] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 302,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [468]
            [469] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 319,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [469]
            [470] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 324,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [470]
            [471] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 35,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [471]
            [472] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 45,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [472]
            [473] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 480,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [473]
            [474] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 481,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [474]
            [475] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 482,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [475]
            [476] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 77,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [476]
            [477] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 87,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [477]
            [478] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 88,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [478]
            [479] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 91,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [479]
            [480] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 38,
                    [4] = 93,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [480]
            [481] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 49,
                    [4] = 11086,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [481]
            [482] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 49,
                    [4] = 11087,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [482]
            [483] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 49,
                    [4] = 11088,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [483]
            [484] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 49,
                    [4] = 11089,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [484]
            [485] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 49,
                    [4] = 427,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [485]
            [486] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 49,
                    [4] = 63,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [486]
            [487] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 49,
                    [4] = 64,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [487]
            [488] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 11033,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [488]
            [489] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 11034,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [489]
            [490] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 255,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [490]
            [491] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 256,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [491]
            [492] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 257,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [492]
            [493] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 258,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [493]
            [494] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 259,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [494]
            [495] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 260,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [495]
            [496] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 261,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [496]
            [497] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 268,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [497]
            [498] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 269,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [498]
            [499] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 270,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [499]
            [500] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 271,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [500]
            [501] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 272,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [501]
            [502] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 273,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [502]
            [503] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 274,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [503]
            [504] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 275,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [504]
            [505] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 276,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [505]
            [506] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 277,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [506]
            [507] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 278,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [507]
            [508] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 279,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [508]
            [509] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 280,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [509]
            [510] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 281,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [510]
            [511] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 282,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [511]
            [512] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 283,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [512]
            [513] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 284,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [513]
            [514] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 285,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [514]
            [515] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 30,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [515]
            [516] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 31,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [516]
            [517] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 312,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [517]
            [518] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 313,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [518]
            [519] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 314,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [519]
            [520] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 315,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [520]
            [521] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 316,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [521]
            [522] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 317,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [522]
            [523] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 318,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [523]
            [524] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 32,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [524]
            [525] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 321,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [525]
            [526] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 322,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [526]
            [527] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 323,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [527]
            [528] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 325,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [528]
            [529] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 326,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [529]
            [530] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 327,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [530]
            [531] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 328,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [531]
            [532] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 329,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [532]
            [533] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 33,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [533]
            [534] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 331,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [534]
            [535] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 332,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [535]
            [536] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 333,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [536]
            [537] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 334,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [537]
            [538] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 335,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [538]
            [539] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 336,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [539]
            [540] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 337,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [540]
            [541] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 338,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [541]
            [542] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 339,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [542]
            [543] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 34,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [543]
            [544] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 363,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [544]
            [545] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 364,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [545]
            [546] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 374,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [546]
            [547] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 38,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [547]
            [548] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 385,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [548]
            [549] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 386,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [549]
            [550] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 387,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [550]
            [551] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 388,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [551]
            [552] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 389,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [552]
            [553] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 390,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [553]
            [554] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 391,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [554]
            [555] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 392,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [555]
            [556] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 412,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [556]
            [557] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 413,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [557]
            [558] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 449,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [558]
            [559] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 483,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [559]
            [560] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 484,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [560]
            [561] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 485,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [561]
            [562] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 486,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [562]
            [563] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 487,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [563]
            [564] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 488,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [564]
            [565] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 5,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [565]
            [566] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 6,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [566]
            [567] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 69,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [567]
            [568] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 7,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [568]
            [569] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 70,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [569]
            [570] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 71,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [570]
            [571] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 72,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [571]
            [572] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 75,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [572]
            [573] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 79,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [573]
            [574] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 9,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [574]
            [575] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 5,
                    [3] = 9,
                    [4] = 90,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [575]
            [576] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 32,
                    [4] = 11048,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [576]
            [577] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 32,
                    [4] = 11056,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [577]
            [578] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 32,
                    [4] = 11090,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [578]
            [579] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 32,
                    [4] = 619,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [579]
            [580] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 32,
                    [4] = 659,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [580]
            [581] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 32,
                    [4] = 661,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [581]
            [582] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 11044,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [582]
            [583] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 11049,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [583]
            [584] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 11091,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [584]
            [585] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 144,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [585]
            [586] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 145,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [586]
            [587] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 146,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [587]
            [588] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 147,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [588]
            [589] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 148,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [589]
            [590] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 149,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [590]
            [591] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 150,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [591]
            [592] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 151,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [592]
            [593] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 155,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [593]
            [594] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 158,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [594]
            [595] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 159,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [595]
            [596] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 181,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [596]
            [597] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 182,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [597]
            [598] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 183,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [598]
            [599] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 184,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [599]
            [600] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 185,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [600]
            [601] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 186,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [601]
            [602] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 256,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [602]
            [603] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 257,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [603]
            [604] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 258,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [604]
            [605] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 275,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [605]
            [606] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 276,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [606]
            [607] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 277,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [607]
            [608] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 299,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [608]
            [609] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 30,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [609]
            [610] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 31,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [610]
            [611] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 32,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [611]
            [612] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 326,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [612]
            [613] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 329,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [613]
            [614] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 33,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [614]
            [615] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 330,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [615]
            [616] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 331,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [616]
            [617] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 34,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [617]
            [618] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 340,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [618]
            [619] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 341,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [619]
            [620] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 342,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [620]
            [621] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 35,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [621]
            [622] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 350,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [622]
            [623] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 359,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [623]
            [624] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 360,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [624]
            [625] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 361,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [625]
            [626] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 364,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [626]
            [627] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 365,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [627]
            [628] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 366,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [628]
            [629] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 367,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [629]
            [630] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 37,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [630]
            [631] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 374,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [631]
            [632] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 375,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [632]
            [633] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 376,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [633]
            [634] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 377,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [634]
            [635] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 378,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [635]
            [636] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 379,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [636]
            [637] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 380,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [637]
            [638] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 381,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [638]
            [639] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 382,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [639]
            [640] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 383,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [640]
            [641] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 384,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [641]
            [642] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 385,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [642]
            [643] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 386,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [643]
            [644] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 387,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [644]
            [645] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 388,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [645]
            [646] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 389,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [646]
            [647] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 390,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [647]
            [648] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 391,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [648]
            [649] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 392,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [649]
            [650] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 393,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [650]
            [651] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 401,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [651]
            [652] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 402,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [652]
            [653] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 440,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [653]
            [654] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 441,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [654]
            [655] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 7,
                    [3] = 33,
                    [4] = 442,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [655]
            [656] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 8,
                    [3] = 10,
                    [4] = 255,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [656]
            [657] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 8,
                    [3] = 10,
                    [4] = 406,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [657]
            [658] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 8,
                    [3] = 11,
                    [4] = 319,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [658]
            [659] = 
            {
                ["wsType"] = 
                {
                    [1] = 4,
                    [2] = 8,
                    [3] = 11,
                    [4] = 398,
                }, -- end of ["wsType"]
                ["initialAmount"] = 100,
            }, -- end of [659]
            }
        }
        if type(data)=="table" then
            local _data={}
            local _groupName
            if data.groupName then
                if Group.getByName(data.groupName)
                or Unit.getByName(data.groupName)
                or StaticObject.getByName(data.groupName)
                then
                    _groupName="SP #"..MathRan(10000000,99999999)
                else
                    _groupName=data.groupName
                end
            end
        --> Coalition Check
            local _coalition
            if data.coalition then
                if data.coalition and data.coalition == "red" or data.coalition == "RED" or data.coalition == 1 or data.coalition == country.id.CJTF_RED then
                    _coalition=country.id.CJTF_RED
                else
                    _coalition=country.id.CJTF_BLUE
                end
            else
                _coalition=country.id.CJTF_BLUE
            end
        --> Init group Id and group heading
            local _groupId=MathRan(10000,99999)
            local _heading=data.heading or MathRan(0,359)
        --> Radio frequency
            local _freq
            if data.freq then
                local f=data.freq
                if f*1000000 >= 108000000 and f*1000000 <= 399975000 then
                    _freq=f*1000000
                else
                    _freq=243000000
                end
            elseif data.options and data.options.freq then
                local f=data.options.freq
                _freq=f*1000000
            else
                _freq=243000000
            end
        --> NOT STATIC
            if data.objectSubCategory=="GROUND_UNIT" or data.objectSubCategory=="SHIP" or data.objectSubCategory=="AIRPLANE" then
                --> skill
                    local _skill
                    if data.skill then
                        if not data.skill=="AVERAGE" or not data.skill=="GOOD" or not data.skill=="HIGH" or not data.skill=="EXCELLENT" then 
                            _skill="HIGH" 
                        end
                    end
                --> Options
                    local _immortal=data.options.immortal or false
                    local _invisible=data.options.invisible or false
                    local _hidden=data.options.hidden or false
                    local _uncontrollable=data.options.uncontrollable or false
                    local _datalink=data.options.datalink or true
                    local _initialWptTasks={}
                if data.objectSubCategory=="GROUND_UNIT" or data.objectSubCategory=="SHIP"then
                    --> Rules Of Engagement
                        local _roe
                        if not data.options or not data.options.roe or data.options.roe == "free" then 
                            _roe=2
                        elseif data.options.roe == "defensive" then
                            _roe=3
                        elseif data.options.roe == "hold" then
                            _roe=4
                        else
                            _roe=2
                        end
                    --> Dispersion time
                        local _dispersion
                        if not data.options or not data.options.dispersion then 
                            _dispersion=600 
                        elseif data.options.dispersion == false or data.options.dispersion == 0 then
                            _dispersion=0
                        else
                            _dispersion=data.options.dispersion
                        end
                    --> Alert State
                        local _alert
                        if not data.options or not data.options.alert or data.options.alert == "red" then 
                            _alert=2 
                        elseif data.options.alert=="green" or data.options.alert==1 then 
                            _alert=1
                        else
                            _alert=0
                        end
                    --> Engagement distance %
                        local _engage=data.options.engage or 100
                        local _restrictTargets
                        local _armEscape=data.options.armEscape or true
                        local _hold=data.options.hold or false
                    --> JTAC options
                        local _jtac=data.options.jtac or false
                        local _jtacCallname=data.options.jtacCallname or 12 --12=playboy
                    _initialWptTasks={
                        --> Immortal
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="SetImmortal",params={value=_immortal}}}},
                        --> Invisible
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="SetInvisible",params={value=_invisible}}}},
                        --> Datalink EPLRS
                        {enabled=true,auto=true,id="WrappedAction",params={action={id="EPLRS",params={value=_datalink,groupId=_groupId}}}},
                        --> 0 : ROE
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={value=_roe,name=0}}}},
                            -- OPEN_FIRE              = 2
                            -- RETURN_FIRE            = 3
                            -- WEAPON_HOLD            = 4
                        --> 5 : FORMATION
                        --{enabled=false,auto=false,id="WrappedAction",params={action={id="Option",params={value=0,name=5}}}},
                            -- Value in feets ?
                        --> 8 : DISPERSE_ON_ATTACK
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={value=_dispersion,name=8}}}},
                            -- Value in seconds
                        --> 9 : ALARM_STATE
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={value=_alert,name=9}}}},
                            -- AUTO   = 0
                            -- GREEN  = 1
                            -- RED    = 2
                        --> 20 : ENGAGE_AIR_WEAPONS
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={value=true,name=20}}}},
                        --> 24 : AC_ENGAGEMENT_RANGE_RESTRICTION
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={value=_engage,name=24}}}},
                            -- Value in %
                        --> 27 : Restrict AAA min -- Actual value is not in this table, but this number id represents the option. 
                        --> 28 : Restrict Targets -- Actual value is not in this table, but this number id represents the option. 
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={value=_restrictTargets,name=28}}}},
                            -- ALL = 0
                            -- AA  = 1
                            -- AG  = 2
                        --> 29 : Restrict AAA max -- Actual value is not in this table, but this number id represents the option. 
                        --> 30 : Formation Interval -- Actual value is not in this table, but this number id represents the option.
                        {enabled=false,auto=false,id="WrappedAction",params={action={id="Option",params={value=0,name=30}}}},
                            -- Value in feets
                        --> 31 : Evasion of ARM
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={value=_armEscape,name=31}}}},
                            -- Value true or false
                        --> HOLD POSITION
                        {enabled=_hold,auto=false,id="Hold",params={templateId="defaut"}},
                        --> FAC/JTAC
                        {enabled=_jtac,auto=false,id="FAC",params={number=MathRan(1,9),designation="Auto",modulation=0,callname=_jtacCallname,datalink=true,frequency=_freq}},
                        --> RADIO FREQUENCY
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="SetFrequency",params={power=15,modulation=0,frequency=_freq}}}},
                    }
                elseif data.objectSubCategory=="AIRPLANE" then
                    local _unlimitedFuel=data.options.unlimitedFuel or false
                    --> Rules Of Engagement
                        local _roe
                        if not data.options or not data.options.roe or data.options.roe == "free" then 
                            _roe=0
                        elseif data.options.roe == "hold" then
                            _roe=4
                        elseif data.options.roe=="defensive" then
                            _roe=3
                        elseif data.options.roe=="designed" then
                            _roe=2
                        elseif data.options.roe=="priority" then
                            _roe=1
                        else
                            _roe=0
                        end
                    --> Theat treaction
                        local _threatReaction 
                        if not data.options or not data.options.threatReaction or data.options.threatReaction == "evade" then 
                            _threatReaction=2
                        elseif data.options.threatReaction == "no reaction" then
                            _threatReaction=0
                        elseif data.options.threatReaction=="passive defence" then
                            _threatReaction=1
                        elseif data.options.threatReaction=="escape" then
                            _threatReaction=3
                        elseif data.options.threatReaction=="abort mission" then
                            _threatReaction=4
                        else
                            _threatReaction=0
                        end
                    --> radarUse
                        local _radarUse
                        if not data.options or not data.options.radarUse or data.options.radarUse=="for search"then
                            _radarUse=2
                        elseif data.options.radarUse=="continuous" then
                            _radarUse=3
                        elseif data.options.radarUse=="for attack" then
                            _radarUse=1
                        elseif data.options.radarUse=="never" then
                            _radarUse=0
                        else
                            _radarUse=2
                        end
                    --> FlareUse
                        local _flareUse
                        if not data.options or not data.options.flareUse or data.options.flareUse=="on shoot"then
                            _flareUse=1
                        elseif data.options.flareUse=="never" then
                            _flareUse=0
                        elseif data.options.flareUse=="on sam threat" then
                            _flareUse=2
                        elseif data.options.flareUse=="near bandits" then
                            _flareUse=3
                        else
                            _flareUse=1
                        end
                    local _formation
                    local _rtbOnBingo=data.options.rtbOnBingo or true
                    local _rtbOutOfAmmo=data.options.rtbOutOfAmmo or 4294967295
                    --> JammerUse
                        local _jammerUse
                        if not data.options or not data.options.jammerUse or data.options.jammerUse=="if locked"then
                            _jammerUse=1
                        elseif data.options.jammerUse=="never" then
                            _jammerUse=0
                        elseif data.options.jammerUse=="if detected" then
                            _jammerUse=2
                        elseif data.options.jammerUse=="always" then
                            _jammerUse=3
                        else
                            _jammerUse=1
                        end
                    local _noAA = data.options.noAA or false
                    local _noJetisson = data.options.noJetisson or false
                    local _noAfterburner = data.options.noAfterburner or true
                    local _noAG = data.options.noAG or false
                    --> Missile Strategy
                        local _missileStrategy
                        if not data.options or not data.options.missileStrategy or data.options.missileStrategy=="threat level"then
                            _missileStrategy=3
                        elseif data.options.missileStrategy=="max range" then
                            _missileStrategy=0
                        elseif data.options.missileStrategy=="noez range" then
                            _missileStrategy=1
                        elseif data.options.missileStrategy=="half way" then
                            _missileStrategy=2
                        elseif data.options.missileStrategy=="random" then
                            _missileStrategy=4
                        else
                            _missileStrategy=1
                        end
                    local _noWptReport = data.options.noWptReport or false
                    local _jetissonEmptyTank = data.options.jetissonEmptyTank or false
    
                    _initialWptTasks={
                        --> Immortal
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="SetImmortal",params={value=_immortal}}}},
                        --> Invisible
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="SetInvisible",params={value=_invisible}}}},
                        --> Datalink EPLRS
                        {enabled=true,auto=true,id="WrappedAction",params={action={id="EPLRS",params={value=_datalink,groupId=_groupId}}}},
                        --> Unlimited Fuel
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="SetUnlimitedFuel",params={value=_unlimitedFuel}}}},
                        --> 0 : ROE
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={value=_roe,name=0}}}},
                            -- WEAPON_FREE            = 0
                            -- OPEN_FIRE_WEAPON_FREE  = 1
                            -- OPEN_FIRE              = 2
                            -- RETURN_FIRE            = 3
                            -- WEAPON_HOLD            = 4
                        --> 1 : REACTION_ON_THREAT
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={value=_threatReaction,name=1}}}},
                            -- NO_REACTION          = 0
                            -- PASSIVE_DEFENCE      = 1
                            -- EVADE_FIRE           = 2
                            -- BYPASS_AND_ESCAPE    = 3
                            -- ALLOW_ABORT_MISSION  = 4
                            -- AAA_EVADE_FIRE       = 5 -- Note: Does not actually exist in the enum table
                        --> 3 : RADAR_USING
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={value=_radarUse,name=3}}}},
                            -- NEVER                   = 0
                            -- FOR_ATTACK_ONLY         = 1
                            -- FOR_SEARCH_IF_REQUIRED  = 2
                            -- FOR_CONTINUOUS_SEARCH   = 3
                        --> 4 : FLARE_USING
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={value=_flareUse,name=4}}}},
                            -- NEVER                     = 0
                            -- AGAINST_FIRED_MISSILE     = 1
                            -- WHEN_FLYING_IN_SAM_WEZ    = 2
                            -- WHEN_FLYING_NEAR_ENEMIES  = 3
                        --> 5 : Formation
                        {enabled=false,auto=false,id="WrappedAction",params={action={id="options",params={variantIndex=2,name=5,formationIndex=4,value=4}}}},
                        --> 6 : RTB_ON_BINGO
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={value=_rtbOnBingo,name=6}}}},
                        --> 10 : RTB_ON_OUT_OF_AMMO
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={value=_rtbOutOfAmmo,name=10}}}},
                            -- 4294967295:all
                        --> 13 : ECM_USING
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={value=_jammerUse,name=13}}}},
                            -- NEVER_USE                       = 0
                            -- USE_IF_ONLY_LOCK_BY_RADAR       = 1
                            -- USE_IF_DETECTED_LOCK_BY_RADAR   = 2
                            -- ALWAYS_USE                      = 3
                        --> 14 : PROHIBIT_AA
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={value=_noAA,name=14}}}},
                        --> 15 : PROHIBIT_JETT
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={value=_noJetisson,name=15}}}},
                        --> 16 : PROHIBIT_AB
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={value=_noAfterburner,name=16}}}},
                        --> 17 : PROHIBIT_AG
                        {enabled=true,auto=true,id="WrappedAction",params={action={id="Option",params={value=_noAG,name=17}}}},
                        -- 18 : MISSILE_ATTACK
                        {enabled=true,auto=true,id="WrappedAction",params={action={id="Option",params={value=_missileStrategy,name=18}}}},
                            -- MAX_RANGE          = 0
                            -- NEZ_RANGE          = 1
                            -- HALF_WAY_RMAX_NEZ  = 2
                            -- TARGET_THREAT_EST  = 3
                            -- RANDOM_RANGE       = 4
                        --> 19 : PROHIBIT_WP_PASS_REPORT
                        {enabled=true,auto=true,id="WrappedAction",params={action={id="Option",params={value=_noWptReport,name=19}}}},
                        --> 21 : OPTION_RADIO_USAGE_CONTACT
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={targetTypes={},name=21,value="none;",noTargetTypes={}}}}},
                        --> 22 : OPTION_RADIO_USAGE_ENGAGE
                        --> 23 : OPTION_RADIO_USAGE_KILL
                        --> 25 : JETT_TANKS_IF_EMPTY
                        {enabled=true,auto=false,id="WrappedAction",params={action={id="Option",params={value=false,name=25}}}},
                        --> 26 : FORCED_ATTACK
                        --> 32 : PREFER_VERTICAL
                    }
                end
            --> SpawnPoint parameters
                local _aircraftAltMin=12000*0.3048
                local _aircraftAltMax=35000*0.3048
                local _aircraftSpeedMin=270*0.514
                local _aircraftSpeedMax=400*0.514
                local _shipSpeedMin=12*0.514
                local _shipSpeedMax=20*0.514
                local _groundSpeedMin=20*0.514
                local _groundSpeedMax=30*0.514
            --> SpawnPoint Pos
                local _wptName, _x, _y, _initialSpeed, _initialAlt
                if not data.x or not data.y then
                    _wptName="Spawn Point"
                    _x=0
                    _y=0
                else
                    _wptName="Spawn Point"
                    _x=data.x or 0
                    _y=data.y or 0
                end
                if not data.alt and data.objectSubCategory=="AIRPLANE" then 
                    _initialAlt=MathRan(_aircraftAltMin,_aircraftAltMax) 
                elseif data.alt and data.objectSubCategory=="AIRPLANE" then
                    _initialAlt=data.alt*0.3048
                else
                    _initialAlt=land.getHeight({x=_x,z=_y})
                end
                if not data.speed and data.objectSubCategory=="AIRPLANE" then
                    _initialSpeed=MathRan(_aircraftSpeedMin,_aircraftSpeedMax)
                elseif data.speed and data.objectSubCategory=="AIRPLANE" then
                    _initialSpeed=data.speed*0.514
                else
                    _initialSpeed=0
                end
                local _wpt={
                    [1]={
                        ["name"]=_wptName,
                        ["x"]=_x,
                        ["y"]=_y,
                        ["speed"]=_initialSpeed, --m/s,
                        ["speed_locked"]=true,
                        ["alt"]=_initialAlt,
                        ["alt_type"]="RADIO", --BARO
                        ["type"]="Turning Point",
                        ["action"]="Off Road",--"Turning Point",
                        ["formation_template"]="",
                        ["form"]="Off Road",
                        ["ETA"]=0,
                        ["ETA_locked"]=true,
                        ["task"]={
                            ["id"]="ComboTask",
                            ["params"]={
                                ["tasks"]=_initialWptTasks,
                            },
                        },
                    },
                }
            --> Options & Tasks for wpt => 2
                local _wptTasks={}
            --> wpt 2 and next
                if data.wpt and data.wpt[1] then
                    for i=1, #data.wpt do
                        if data.wpt[i].x and data.wpt[i].y then
                            local _alt,_speed
                            local _wptName=data.wpt[i].name or "Waypoint "..i
                            local _wptTasks=data.wpt[i].tasks or nil
                            if data.objectSubCategory=="AIRPLANE" then
                                if data.wpt[i].alt~=nil then _alt=data.wpt[i].alt*0,3048 else _alt=_initialAlt end
                                if data.wpt[i].speed~=nil then _speed=data.wpt[i].speed*0.514 else _speed=_initialSpeed end
                            elseif data.objectSubCategory=="SHIP" then
                                _alt=0
                                if data.wpt[i].speed~=nil then _speed=data.wpt[i].speed*0.514 else _speed=MathRan(_shipSpeedMin,_shipSpeedMax) end
                            else
                                _alt=0
                                if data.wpt[i].speed~=nil then _speed=data.wpt[i].speed*0.514 else _speed=MathRan(_groundSpeedMin,_groundSpeedMax) end
                            end
                            _wpt[#_wpt+1]= {
                                ["name"]=_wptName,
                                ["x"]=data.wpt[i].x,
                                ["y"]=data.wpt[i].y,
                                ["speed"]=_speed, --m/s,
                                ["speed_locked"]=true,
                                ["alt"]=_alt,
                                ["alt_type"]="BARO",
                                ["type"]="Turning Point",
                                ["action"]="Off Road",
                                ["formation_template"]="",
                                ["form"]="Off Road",
                                ["ETA"]=0,
                                ["ETA_locked"]=true,
                                ["task"]={
                                    ["id"]="ComboTask",
                                    ["params"]={
                                        ["tasks"]=_wptTasks
                                    },
                                },
                            }
                        end
                    end
                end
            --> Bearing & Range method
                if data.braa then
                    for i=1, #data.braa do
                        if data.braa[i].bearing and data.braa[i].range then
                            local _wptName="Waypoint "..i
                            local _braaX = Cos((data.braa[i].bearing)*math.pi/180)*data.braa[i].range
                            local _braaY = Sin((data.braa[i].bearing)*math.pi/180)*data.braa[i].range
                            local _wptTasks=data.braa[i].tasks or nil
                            local _x=_wpt[#_wpt].x + (_braaX*1852)
                            local _y=_wpt[#_wpt].y + (_braaY*1852)
                            _wpt[#_wpt+1]={
                                ["name"]=_wptName,
                                ["x"]=_x,
                                ["y"]=_y,
                                ["speed"]=_initialSpeed, --m/s,
                                ["speed_locked"]=true,
                                ["alt"]=_initialAlt,
                                ["alt_type"]="BARO",
                                ["type"]="Turning Point",
                                ["action"]="Off Road",
                                ["formation_template"]="",
                                ["form"]="Off Road",
                                ["ETA"]=0,
                                ["ETA_locked"]=true,
                                ["task"]={
                                    ["id"]="ComboTask",
                                    ["params"]={
                                        ["tasks"]={}
                                    },
                                },
                                
                            }
                        end
                    end
                end
            --> Loop after last waypoint
                if #_wpt>=2 and data.loopWpt==true then
                    if data.objectSubCategory=="GROUND_UNIT" or data.objectSubCategory=="SHIP" then
                        _wpt[#_wpt].task.params.tasks[#_wpt[#_wpt].task.params.tasks+1]={
                            ["enabled"]=true,
                            ["auto"]=false,
                            ["id"]="GoToWaypoint",
                            ["number"]=#_wpt[#_wpt].task.params.tasks+1,
                            ["params"]={
                                ["fromWaypointIndex"]=#_wpt,
                                ["goToWaypointIndex"]=#_wpt-1,
                            },
                        }
                    --["nWaypointIndx"]=#_wpt-1,
                    elseif data.objectSubCategory=="AIRPLANE" then
                        _wpt[#_wpt].task.params.tasks[#_wpt[#_wpt].task.params.tasks+1]={
                            ["enabled"]=true,
                            ["auto"]=false,
                            ["id"]="WrappedAction",--"GoToWaypoint",--SwitchWaypoint
                            ["number"]=#_wpt[#_wpt].task.params.tasks+1,
                            ["params"]={
                                ["action"]={
                                    ["id"]="SwitchWaypoint",
                                    ["params"]={
                                        ["fromWaypointIndex"]=#_wpt,
                                        ["goToWaypointIndex"]=#_wpt-1,
                                    }
                                }
                            },
                        }
                    end
                end
                --> Units
                local _units={}
            --> GROUND UNIT
                if data.objectSubCategory=="GROUND_UNIT" then
                    for i=1, #data.units do
                        local _skill
                        if data.skill then
                            if not data.skill=="AVERAGE" or not data.skill=="GOOD" or not data.skill=="HIGH" or not data.skill=="EXCELLENT" then 
                                _skill=data.units[i].skill or "HIGH" --> PLAYER, CLIENT, AVERAGE, GOOD, HIGH, EXCELLENT
                            end
                        end
                        local _coldAtStart=data.units[i].cold or false
                        local _type=data.units[i].type or "Leclerc"
                        local nb
                        if not data.nb or data.nb==nil then nb=1 else nb=data.nb end
                        if nb>=5 then nb=4 end
                        for j=1, nb do
                            local _unitName
                            if #_units+1<=9 then _unitName=_groupName.."-0"..#_units+1 else _unitName=_groupName.."-"..#_units+1 end
                            _units[#_units+1]={
                                ["skill"]=_skill, 
                                ["coldAtStart"]=_coldAtStart,
                                ["type"]=_type,
                                ["unitId"]=#_units+1,
                                ["x"]=data.units[i].x or _wpt[1].x + (#_units)*MathRan(-15,15),
                                ["y"]=data.units[i].y or _wpt[1].y + (#_units)*MathRan(-15,15),
                                ["name"]=_unitName,
                                ["heading"]=data.units[i].heading or _heading*math.pi/180,
                                ["playerCanDrive"]=true,
                            }
                        end
                    end
                    --> Tacan for mobile beacon
                    _data={
                        ["name"]=_groupName,
                        ["groupId"]=_groupId,
                        ["units"]=_units,
                        ["x"]=_wpt[1].x,
                        ["y"]=_wpt[1].y,
                        ["route"]={
                            ["spans"]={},
                            ["points"]=_wpt,
                        },
                        ["visible"]=true,
                        ["hidden"]=_hidden,
                        ["hiddenOnPlanner"]=true,
                        ["uncontrollable"]=_uncontrollable,
                        ["task"]="Pas de sol", --?
                        ["taskSelected"]=true,
                        ["tasks"]={},
                        ["start_time"]=0,
                    }
                    AddGroup(_coalition, Group.Category.GROUND, _data)
                    Log("Persistent World | Unit ".._data.units[1].type.." spawned")
            --> SHIP
                elseif data.objectSubCategory=="SHIP" then
                    local _transportable=data.transportable or false
                    for i=1, #data.units do
                        local _skill
                        if data.skill then
                            if not data.skill=="AVERAGE" or not data.skill=="GOOD" or not data.skill=="HIGH" or not data.skill=="EXCELLENT" then 
                                _skill=data.units[i].skill or "HIGH" --> PLAYER, CLIENT, AVERAGE, GOOD, HIGH, EXCELLENT
                            end
                        end
                        local _type=data.units[i].type or "USS_Arleigh_Burke_IIa"
                        local _unitName
                        if #_units+1<=9 then _unitName=_groupName.."-0"..#_units+1 else _unitName=_groupName.."-"..#_units+1 end
                        _units[#_units+1]={
                            ["type"]=_type,
                            ["transportable"]={
                                ["randomTransportable"]=_transportable,
                            },
                            ["unitId"]=i,
                            --["livery_id"]="DDG-102_USS_Sampson",
                            ["skill"]=_skill,
                            ["x"]=data.units[i].x or _wpt[1].x + (i-1)*MathRan(100,500),
                            ["y"]=data.units[i].y or _wpt[1].y + (i-1)*MathRan(100,500),
                            ["name"]=_unitName,
                            ["heading"]=data.units[i].heading or _heading*math.pi/180,
                            ["modulation"]=0,
                            ["frequency"]=_freq,
                        }
                    end
                    --> Tacan for Ships (Carrier)
                    local _tacan=data.options.tacan or false
                    local _tacanMode=data.options.tacanMode or "X"
                    local _tacanChannel=data.options.tacanChannel or 80
                    local _tacanFrequency=data.options.tacanFreq or 1167000000
                    local _tacanCallsign=data.options.tacanCallsign or "SCA"
                    if _tacan==true then 
                        _wpt[1].task.params.tasks[#_wpt[1].task.params.tasks+1]={enabled=_tacan,auto=true,id="WrappedAction",number=#_wpt[1].task.params.tasks,params={action={id="ActivateBeacon",params={type=4,AA=false,unitId=_units[1].unitId,modeChannel=_tacanMode,channel=_tacanChannel,system=3,callsign=_tacanCallsign,bearing=true,frequency=_tacanFrequency}}}}
                    end
                    _data={
                        ["name"]=_groupName,
                        ["groupId"]=_groupId,
                        ["units"]=_units,
                        ["x"]=_wpt[1].x,
                        ["y"]=_wpt[1].y,
                        ["route"]={
                            ["spans"]={},
                            ["points"]=_wpt,
                        },
                        ["visible"]=true,
                        ["hidden"]=_hidden,
                        ["hiddenOnPlanner"]=true,
                        ["uncontrollable"]=_uncontrollable,
                        ["task"]="Pas de sol", --?
                        ["taskSelected"]=true,
                        ["tasks"]={},
                        ["start_time"]=0,
                    }
                    AddGroup(_coalition, Group.Category.SHIP, _data)
                    Log("Persistent World | Unit ".._data.units[1].type.." spawned")
            --> AIRCRAFT
                elseif data.objectSubCategory=="AIRPLANE" then
                    local _mission=data.mission or "CAP"
                    if _mission=="CAP" then
                        _initialWptTasks[#_initialWptTasks+1]={enabled=true,auto=true,key="CAP",id="EngageTargets",params={targetTypes={"Air",},priority=0}}
                    elseif _mission=="SEAD" then
                        _initialWptTasks[#_initialWptTasks+1]={enabled=true,auto=true,key="SEAD",id="EngageTargets",params={targetTypes={"Air Defence",},priority=0}}
                    elseif _mission=="Refueling" then
                        _initialWptTasks[#_initialWptTasks+1]={enabled=true,auto=true,id="Tanker",params={}}
                    elseif _mission=="AWACS" then
                        _initialWptTasks[#_initialWptTasks+1]={enabled=true,auto=true,id="AWACS",params={}}
                    end
                    _freq=_freq/1000000
                    local _communication=data.communication or true
                    local _dlParams
                    for i=1, #data.units do
                        local _skill
                        if data.skill then
                            if not data.skill=="AVERAGE" or not data.skill=="GOOD" or not data.skill=="HIGH" or not data.skill=="EXCELLENT" then 
                                _skill=data.units[i].skill or "HIGH" --> PLAYER, CLIENT, AVERAGE, GOOD, HIGH, EXCELLENT
                            end
                        end
                        local _type=data.units[i].type or "F-15C"
                        local _livery=data.units[i].livery or nil
                        local _onBoardNum="007"
                        local _fuel=data.units[i].fuel or 100
                        local _pylons=data.units[i].pylons or {}
                        local _flare=data.units[i].flare or 15
                        local _chaff=data.units[i].chaff or 15
                        local _gun=data.units[i].gun or 100
                        local _callsign
                        if data.options.callsign then
                            _callsign=data.options.callsign
                        else
                            _callsign={
                                [1]=5,
                                [2]=5,
                                [3]=1,
                                ["name"]="Dodge51",
                            }
                        end
                        --> Multiplicator
                        local nb
                        if not data.nb or data.nb==nil then nb=1 else nb=data.nb end
                        if nb>=5 then nb=4 end
                        for j=1, nb do
                            local _unitName
                            if #_units+1<=9 then _unitName=_groupName.."-0"..#_units+1 else _unitName=_groupName.."-"..#_units+1 end
                            _units[#_units+1]={
                                ["alt"]=_initialAlt+MathRan(0,5),
                                ["hardpoint_racks"]=true,
                                ["alt_type"]="BARO",
                                ["livery_id"]=_livery,
                                ["skill"]=_skill,
                                ["speed"]=_initialSpeed,
                                ["type"]=_type,
                                ["unitId"]=#_units+1,
                                ["psi"]=0.099012914880354,
                                ["x"]=_wpt[1].x + (#_units)*MathRan(50,500),
                                ["y"]=_wpt[1].y + (#_units)*MathRan(50,500),
                                ["name"]=_unitName,
                                ["payload"]={
                                    ["pylons"]=_pylons,
                                    ["fuel"]=_fuel,
                                    ["flare"]=_flare,
                                    ["chaff"]=_chaff,
                                    ["gun"]=_gun,
                                },
                                ["heading"]=data.units[i].heading or _heading*math.pi/180,
                                ["callsign"]=_callsign,
                                ["onboard_num"]=_onBoardNum,
                            }
                        end
                        if _datalink==true and _type=="F-15C" then
                            _dlParams=data.datalinkParams or {["STN_L16"]="00201",["VoiceCallsignNumber"]="91",["VoiceCallsignLabel"]="SO",}
                        end --F-16C_50 A-10C_2 
                        --> Tacan for Tankers
                        local _tacan=data.options.tacan or false
                        local _tacanMode=data.options.tacanMode or "Y"
                        local _tacanChannel=data.options.tacanChannel or 5
                        local _tacanFrequency=data.options.tacanFreq or 109200000
                        local _tacanCallsign=data.options.tacanCallsign or "TKR"
                        if _tacan==true and _mission=="Refueling" then
                            _wpt[1].task.params.tasks[#_wpt[1].task.params.tasks+1]={enabled=_tacan,auto=true,id="WrappedAction",number=#_wpt[1].task.params.tasks,params={action={id="ActivateBeacon",params={type=4,AA=false,unitId=_units[1].unitId,modeChannel=_tacanMode,channel=_tacanChannel,system=5,callsign=_tacanCallsign,bearing=true,frequency=_tacanFrequency}}}}
                        end
                    end
                    _data={
                        ["name"]=_groupName,
                        ["groupId"]=_groupId,
                        ["units"]=_units,
                        ["x"]=_wpt[1].x,
                        ["y"]=_wpt[1].y,
                        ["route"]={
                            ["spans"]={},
                            ["points"]=_wpt,
                        },
                        ["visible"]=true,
                        ["hidden"]=_hidden,
                        ["hiddenOnPlanner"]=true,
                        ["uncontrolled"]=_uncontrollable,
                        ["task"]=_mission,
                        ["taskSelected"]=true,
                        ["tasks"]={},
                        ["start_time"]=0,
                        ["radioSet"]=true,
                        ["frequency"]=_freq,
                        ["communication"]=_communication,
                        ["modulation"]=0,
                        ["AddPropAircraft"]=_dlParams,
                    }
                    AddGroup(_coalition, Group.Category.AIRPLANE, _data)
                    Log("Persistent World | Unit ".._data.units[1].type.." spawned")
                end
        --> STATIC
            elseif data.objectCategory=="STATIC" then
                local _x,_y
                if not data.x or not data.y then
                    _x=0
                    _y=0
                else
                    _x=data.x or 0
                    _y=data.y or 0
                end
                local _type
                if data.units and data.units[1] and data.units[1].type then
                    _type=data.units[1].type
                else
                    _type="Tech combine"
                end
                local _category
                if data.units and data.units[1] and data.units[1].category then
                    _category=data.units[1].category
                else
                    _category=4
                end
                local _shape
                if data.units and data.units[1] and data.units[1].shape then
                    _shape=data.units[1].shape
                else
                    _shape="kombinat"
                end
                _data={
                    ["name"]=_groupName,
                    ["groupId"]=_groupId,
                    ["type"]=_type,
                    ["category"] = _category,
                    ["shape_name"] = _shape,
                    ["x"]=_x,
                    ["y"]=_y,                
                    ["dead"] = false,
                    ["heading"]=data.units[1].heading or _heading*math.pi/180,
                }			
                coalition.addStaticObject(_coalition, _data)
                Log("Persistent World | Static ".._data.type.." spawned")
        --> FARP
            elseif data.objectCategory=="BASE" then
                local _x,_y,_h
                if not data.x or not data.y then
                    _x=0
                    _y=0
                else
                    _x=data.x or 0
                    _y=data.y or 0
                end
                if data.h then
                    _h=data.h
                else
                    _h=land.getHeight({x=_x,y=_y})
                end
                local _type
                if data.units and data.units[1] and data.units[1].type then
                    _type=data.units[1].type
                else
                    _type="FARP_SINGLE_01"
                end
                local _category
                if data.units and data.units[1] and data.units[1].category then
                    _category=data.units[1].category
                else
                    _category='Heliports'
                end
                local _shape
                if data.units and data.units[1] and data.units[1].shape then
                    _shape=data.units[1].shape
                else
                    _shape="FARP_SINGLE_01"
                end
                _data={
                    ["name"]=_groupName,
                    ["groupId"]=_groupId,
                    ["type"]=_type,
                    ["category"] = _category,
                    ["shape_name"] = _shape,
                    ["x"]=_x,
                    ["y"]=_y,                
                    ["dead"] = false,
                    ["heading"]=data.units[1].heading or _heading*math.pi/180,
                    ["heliport_frequency"] = _freq or 225100000,
                    ["heliport_modulation"] = 0,
                    ["heliport_callsign_id"] = callsignTable.farp[math.random(0,10)],
                }
                local newFarp=coalition.addStaticObject(_coalition, _data)
                Log("Persistent World | new FARP spawned")
                timer.scheduleFunction(
                    function(params, time)
                        local farpWarehouse = Airbase.getByName(params.farp:getName()):getWarehouse()
                        farpWarehouse:setLiquidAmount(0,100000) --> jetfuel
                        farpWarehouse:setLiquidAmount(1,100000) --> aviation gasoline
                        farpWarehouse:setLiquidAmount(2,100000) --> MW50
                        farpWarehouse:setLiquidAmount(3,100000) --> diesel
                        for i, datas in ipairs(params.context.wsType) do 
                            farpWarehouse:addItem(datas.wsType, 100)
                        end
                        for i=1, #aircraftTypeTable do
                            farpWarehouse:addItem(aircraftTypeTable[i], 100)
                        end
                    end,
                    {farp = newFarp, context = warehouse},timer.getTime() + 5
                )
            end
            return _groupName
        end
    end
    local function SaveDeadUnits()
        local datas = SmartSerialize("PWS_deadUnitsTable", PWS_deadUnitsTable)
        WriteDatas(datas, deadUnitsSaveFile)
        Msg("Persistent World | Progress Has Been Saved", 2)
        Log("Persistent World | Dead units Saved ("..#PWS_deadUnitsTable..")")
    end
    local function SaveDeadStatics()
        local datas = SmartSerialize("PWS_deadStaticsTable", PWS_deadStaticsTable)
        WriteDatas(datas, deadStaticsSaveFile)
        Log("Persistent World | Dead statics Saved ("..#PWS_deadStaticsTable..")")
    end
    local function SaveSpawnedUnits()
        if saveBirthBlue == true or saveBirthRed == true then
            local datas = {}
            for i = 1, #PWS_spawnedUnitsTable do
                if PWS_spawnedUnitsTable[i].coalition
                and PWS_spawnedUnitsTable[i].objectCategory
                and PWS_spawnedUnitsTable[i].objectSubCategory
                and PWS_spawnedUnitsTable[i].groupName
                and PWS_spawnedUnitsTable[i].units
                then
                    local tempUnitsDatas = {}
                    local aliveUnits = 0
                    for i2=1, #PWS_spawnedUnitsTable[i].units do  
                        local thisUnit = Unit.getByName(PWS_spawnedUnitsTable[i].units[i2].name)
                        if thisUnit and thisUnit:getLife() >= 1 then
                            aliveUnits = aliveUnits+1
                            local thisUnitPosition = thisUnit:getPoint()
                            local thisUnitHeading = math.atan2(thisUnit:getPosition().x.z, thisUnit:getPosition().x.x)

                            tempUnitsDatas[#tempUnitsDatas+1] = {
                                type = PWS_spawnedUnitsTable[i].units[i2].type,
                                name = PWS_spawnedUnitsTable[i].units[i2].name,
                                y = thisUnitPosition.z,
                                x = thisUnitPosition.x,
                                heading = thisUnitHeading,
                            }
                        else
                            DebugLog("Update Spawned : L'unité "..PWS_spawnedUnitsTable[i].units[i2].name.." n'existe plus")
                        end
                    end
                    if aliveUnits > 0 then
                        datas[#datas+1] = {}
                        datas[#datas].coalition = PWS_spawnedUnitsTable[i].coalition
                        datas[#datas].objectCategory = PWS_spawnedUnitsTable[i].objectCategory
                        datas[#datas].objectSubCategory = PWS_spawnedUnitsTable[i].objectSubCategory
                        datas[#datas].groupName = PWS_spawnedUnitsTable[i].groupName
                        datas[#datas].units = tempUnitsDatas
                    else
                        DebugLog("Update Spawned : L'unité "..PWS_spawnedUnitsTable[i].groupName.." n'existe plus")
                    end -- group alive
                else
                    DebugLog("Update Spawned : 1 loop skipped, a nil value ")
                end -- group exist
            end
            PWS_spawnedUnitsTable = datas
            DebugLog("Update Spawned complete ("..#PWS_spawnedUnitsTable.. ")")
            local serializedDatas = SmartSerialize("PWS_spawnedUnitsTable", PWS_spawnedUnitsTable)
            WriteDatas(serializedDatas, spawnedUnitsSaveFile)
            Log("Persistent World | Spawned units Saved ("..#PWS_spawnedUnitsTable..")")
        end
    end
    local function SaveSpawnedStatics()
        if saveStaticsBirthBlue == true or saveStaticsBirthRed == true then
            local datas = {}
            for i = 1, #PWS_spawnedStaticsTable do
                if PWS_spawnedStaticsTable[i].objectCategory
                and PWS_spawnedStaticsTable[i].coalition
                and PWS_spawnedStaticsTable[i].name
                and PWS_spawnedStaticsTable[i].type
                and PWS_spawnedStaticsTable[i].category
                and PWS_spawnedStaticsTable[i].shape
                and PWS_spawnedStaticsTable[i].x
                and PWS_spawnedStaticsTable[i].y
                then
                    local alive = 0 
                    local thisUnit = StaticObject.getByName(PWS_spawnedStaticsTable[i].name)
                    DebugLog("Statics : "..PWS_spawnedStaticsTable[i].name)
                    if thisUnit and thisUnit:getLife() >= 1 then
                        alive = alive+1
                    else
                        DebugLog("Update spawned statics : L'unité "..PWS_spawnedStaticsTable[i].name.." n'existe plus")
                    end
                    if alive > 0 then
                        datas[#datas+1] = {}
                        datas[#datas].objectCategory = PWS_spawnedStaticsTable[i].objectCategory
                        datas[#datas].coalition = PWS_spawnedStaticsTable[i].coalition
                        datas[#datas].name = PWS_spawnedStaticsTable[i].name
                        datas[#datas].type = PWS_spawnedStaticsTable[i].type
                        datas[#datas].category = PWS_spawnedStaticsTable[i].category
                        datas[#datas].shape = PWS_spawnedStaticsTable[i].shape
                        datas[#datas].x = PWS_spawnedStaticsTable[i].x
                        datas[#datas].y = PWS_spawnedStaticsTable[i].y
                        datas[#datas].heading = PWS_spawnedStaticsTable[i].heading
                    else
                        DebugLog("Update spawned statics : L'unité "..PWS_spawnedStaticsTable[i].name.." n'existe plus")
                    end
                else
                    DebugLog("Update spawned statics : 1 loop skipped, a nil value ")
                end
            end
            PWS_spawnedStaticsTable = datas
            DebugLog("Update spawned statics complete ("..#PWS_spawnedStaticsTable.. ")")
            local serializedDatas = SmartSerialize("PWS_spawnedStaticsTable", PWS_spawnedStaticsTable)
            WriteDatas(serializedDatas, spawnedStaticsSaveFile)
            Log("Persistent World | Spawned statics Saved ("..#PWS_spawnedStaticsTable..")")
        end
    end
    local function SaveMarks()
        if saveMarksBlue == true or saveMarksRed ==true then
            local datas = {}
            local marks = world.getMarkPanels()
            for i = 1, #marks do
                if marks[i].text and marks[i].text ~= "" then
                    local match = 0
                    for y=1, #ignoredTextsToMarkList do
                        if StrMatch(marks[i].text, ignoredTextsToMarkList[y]) then match = match + 1 end
                    end
                    if match ~= 0 then
                        DebugLog("Mark ignored")
                    else
                        datas[#datas+1] = {}
                        datas[#datas].idx = marks[i].idx
                        datas[#datas].coalition = marks[i].coalition
                        datas[#datas].text = marks[i].text
                        datas[#datas].pos = marks[i].pos
                    end
                end
            end
            PWS_marksTable = datas
            DebugLog("Update Marks complete ("..#PWS_marksTable..")")
            local datas = SmartSerialize("PWS_marksTable", PWS_marksTable)
            WriteDatas(datas, marksSaveFile)
            Log("Persistent World | Marks Saved ("..#PWS_marksTable..")")
        end
    end
    local function SaveWarehouses()
        if saveWarehouses==true then
            local Airbases = world.getAirbases()
            for i=1, #(Airbases) do
                local warehouse=Airbases[i]:getWarehouse()
                local inv = warehouse:getInventory()
                PWS_warehousesTable[Airbases[i]:getName()]=inv
            end
            DebugLog("Update Warehouses complete ("..#PWS_warehousesTable..")")
            local datas = SmartSerialize("PWS_warehousesTable", PWS_warehousesTable)
            WriteDatas(datas, warehousesSaveFile)
            Log("Persistent World | Warehouses Saved ("..#PWS_warehousesTable..")")
        end
    end
    local function SaveAll()
        ScheduleFunction(function () SaveDeadUnits() end, nil, GetTime()+1)
        ScheduleFunction(function () SaveDeadStatics() end, nil, GetTime()+2)
        ScheduleFunction(function () SaveSpawnedUnits() end, nil, GetTime()+3)
        ScheduleFunction(function () SaveSpawnedStatics() end, nil, GetTime()+4)
        ScheduleFunction(function () SaveMarks() end, nil, GetTime()+5)
        ScheduleFunction(function () SaveWarehouses() end, nil, GetTime()+6)
    end
    local function ScheduledSaveAll()
        ScheduleFunction(function () SaveDeadUnits() return GetTime()+saveSchedule end, nil, GetTime()+saveSchedule+1)
        ScheduleFunction(function () SaveDeadStatics() return GetTime()+saveSchedule end, nil, GetTime()+saveSchedule+2)
        ScheduleFunction(function () SaveSpawnedUnits() return GetTime()+saveSchedule end, nil, GetTime()+saveSchedule+3)
        ScheduleFunction(function () SaveSpawnedStatics() return GetTime()+saveSchedule end, nil, GetTime()+saveSchedule+4)
        ScheduleFunction(function () SaveMarks() return GetTime()+saveSchedule end, nil, GetTime()+saveSchedule+5)
        ScheduleFunction(function () SaveWarehouses() return GetTime() + saveSchedule end, nil, GetTime()+saveSchedule+6)
    end
--%%%%% MAIN () %%%%%
    --> Counters
    local deletedUnitsCounter = 0
    local deletedStaticsCounter = 0
    local restoredUnits = 0
    local restoredStatics = 0
    local restoredMarks = 0
    --> Debug Mode
    if DEBUG_MODE == true then
        saveSchedule = debugSaveSchedule
    end
    --> Loading message
    Msg("Persistent World | Loading...  -  Credits : JGi | Quéton 1-1", 5)
    Log("Persistent World | Loading...  -  Credits : JGi | Quéton 1-1")
    Log("Persistent World | Save folder : "..saveDir)
    if os ~= nil then
        --%%% IS SAVE DIR EXIST %%%
        if IsDir(saveDir)==false then 
            MkDir(saveDir)
        end
        --%%% LOAD DEAD STATICS %%%
        if FileExists(deadStaticsSaveFile) then
            Log("Persistent World | Found dead statics save file")	
            dofile(deadStaticsSaveFile)
            for i = 1, #PWS_deadStaticsTable do
                if ( StaticObject.getByName(PWS_deadStaticsTable[i]) ~= nil ) then		
                    StaticObject.getByName(PWS_deadStaticsTable[i]):destroy()		
                    deletedStaticsCounter = deletedStaticsCounter + 1
                elseif ( Unit.getByName(PWS_deadStaticsTable[i]) ~= nil ) then
                    Unit.getByName(PWS_deadStaticsTable[i]):destroy()
                    deletedUnitsCounter = deletedUnitsCounter + 1
                else
                    Log("Persistent World | Static "..i.." Is "..PWS_deadStaticsTable[i].." And Was Not Found", 2)
                end	
            end
            Log("Persistent World | Removed "..deletedStaticsCounter.." Static(s)", 5)
        else
            PWS_deadStaticsTable = {}
            --StaticIntermentTableLength = 0	
        end
        --%%% LOAD DEAD UNITS %%%
        if FileExists(deadUnitsSaveFile) then
            Log("Persistent World | Found dead units save file")	
            dofile(deadUnitsSaveFile)
            for i = 1, #PWS_deadUnitsTable do	
                if ( Unit.getByName(PWS_deadUnitsTable[i]) ~= nil ) then
                    Unit.getByName(PWS_deadUnitsTable[i]):destroy()
                    deletedUnitsCounter = deletedUnitsCounter + 1
                else
                    Log("Unit "..i.." Is "..PWS_deadUnitsTable[i].." And Was Not Found")
                end	
            end
            Log("Persistent World | Removed "..deletedUnitsCounter.." Unit(s)")
        else			
            PWS_deadUnitsTable = {}	
            Msg("Persistent World | No save found, creating new files...", 5)
            Log("Persistent World | No save found, creating new files...")
        end
        --%%% LOAD SPAWNED UNITS %%%
        if saveBirthBlue == true or saveBirthRed == true then
            if FileExists(spawnedUnitsSaveFile) then	
                Log("Persistent World | Found spawned units save file")	
                dofile(spawnedUnitsSaveFile)
                restoredUnits = 0
                if PWS_spawnedUnitsTable then   
                    for i = 1, #PWS_spawnedUnitsTable do
                        
                        if PWS_spawnedUnitsTable[i]
                        and PWS_spawnedUnitsTable[i].objectCategory
                        and PWS_spawnedUnitsTable[i].objectSubCategory
                        and PWS_spawnedUnitsTable[i].coalition
                        and PWS_spawnedUnitsTable[i].groupName
                        and PWS_spawnedUnitsTable[i].units
                        then
                            local _data = {}
                            if PWS_spawnedUnitsTable[i].coalition == 2 then _coalition = country.id.CJTF_BLUE else _coalition = country.id.CJTF_RED end
                            if PWS_spawnedUnitsTable[i].objectCategory==1 and PWS_spawnedUnitsTable[i].objectSubCategory==2 then 
                                _data.objectCategory="UNIT"
                                _data.objectSubCategory="GROUND_UNIT"
                                _data.groupName = PWS_spawnedUnitsTable[i].groupName
                                _data.x=PWS_spawnedUnitsTable[i].units[1].x
                                _data.y=PWS_spawnedUnitsTable[i].units[1].y
                                _data.units={}
                                for y=1, #PWS_spawnedUnitsTable[i].units do
                                    _data.units[#_data.units+1]={
                                        type=PWS_spawnedUnitsTable[i].units[y].type,
                                        x = PWS_spawnedUnitsTable[i].units[y].x,
                                        y = PWS_spawnedUnitsTable[i].units[y].y,
                                        heading = PWS_spawnedUnitsTable[i].units[y].heading,
                                    }
                                end
                                _data.options={immortal=false, invisible=false, hidden=false, uncontrollable=false, datalink=true, roe="free", dispersion=300, alert="red", engage=100, hold=false, jtac=false, jtacCallname=nil, tacan=false}
                                _data.freq=288
                                _data.skill="HIGH"
                                SpawnMe(_data)
                            end
                            restoredUnits = restoredUnits + 1
                        else
                            Log("Persistent World | Restoring unit : One loop skip, a nil value")
                        end	
                    end
                    Log("Persistent World | Restored "..restoredUnits.." Unit(s)")
                end
            else
                Log("Persistent World | No Spawned save file")			
            end
        end
        --%%% LOAD SPAWNED STATICS %%%
        if saveStaticsBirthBlue == true or saveStaticsBirthRed == true then
            if FileExists(spawnedStaticsSaveFile) then	
                Log("Persistent World | Found spawned statics save file")	
                dofile(spawnedStaticsSaveFile)
                restoredStatics = 0
                if PWS_spawnedStaticsTable then
                    for i = 1, #PWS_spawnedStaticsTable do
                        if PWS_spawnedStaticsTable[i]
                        and PWS_spawnedStaticsTable[i].objectCategory
                        and PWS_spawnedStaticsTable[i].coalition
                        and PWS_spawnedStaticsTable[i].name
                        and PWS_spawnedStaticsTable[i].type
                        and PWS_spawnedStaticsTable[i].category
                        and PWS_spawnedStaticsTable[i].shape
                        and PWS_spawnedStaticsTable[i].x
                        and PWS_spawnedStaticsTable[i].y
                        then
                            local _data = {}
                            if PWS_spawnedStaticsTable[i].coalition == 2 then _coalition = country.id.CJTF_BLUE else _coalition = country.id.CJTF_RED end
                            if PWS_spawnedStaticsTable[i].objectCategory==3 then 
                                _data.objectCategory="STATIC"
                            elseif PWS_spawnedStaticsTable[i].objectCategory==4 then
                                _data.objectCategory="BASE"
                                _data.freq=225.1
                            end
                            _data.groupName = PWS_spawnedStaticsTable[i].name
                            _data.units={{
                                type=PWS_spawnedStaticsTable[i].type,
                                category = PWS_spawnedStaticsTable[i].category,
                                shape = PWS_spawnedStaticsTable[i].shape,
                            }}
                            _data.x = PWS_spawnedStaticsTable[i].x
                            _data.y = PWS_spawnedStaticsTable[i].y
                            _data.heading = PWS_spawnedStaticsTable[i].heading
                            SpawnMe(_data)
                            restoredStatics = restoredStatics + 1
                        else
                            Log("Persistent World | Restoring statics : One loop skip, a nil value")
                        end	
                    end
                    Log("Persistent World | Restored "..restoredStatics.." Static(s)")
                end
            else
                Log("Persistent World | No Spawned statics save file")        
            end
        end
        --%%% LOAD MARKS %%%
        if saveMarksBlue == true or saveMarksRed == true then
            if FileExists(marksSaveFile) then	
                Log("Persistent World | Found marks save file")
                dofile(marksSaveFile)
                restoredMarks = 0
                if PWS_marksTable then           
                    for i = 1, #PWS_marksTable do
                        if PWS_marksTable[i]
                        and PWS_marksTable[i].coalition
                        and PWS_marksTable[i].idx
                        and PWS_marksTable[i].text
                        and PWS_marksTable[i].pos
                        then
                            trigger.action.markToCoalition(PWS_marksTable[i].idx , PWS_marksTable[i].text , PWS_marksTable[i].pos, PWS_marksTable[i].coalition , false) --optionnal ,string message)
                            restoredMarks = restoredMarks + 1
                        else
                            DebugLog("Persistent World | Restoring Marks : One loop skip, a nil value")
                        end	
                        --i = i+1
                    end
                    Log("Persistent World | Restored "..restoredMarks.." Mark(s)")
                end
            else		
                Log("Persistent World | No marks save file")
                PWS_marksTable = {}
            end
        end
        --%%% LOAD WAREHOUSES %%%
        if saveWarehouses==true and FileExists(warehousesSaveFile) then
            dofile(warehousesSaveFile)
            Log("Persistent World | Found warehouses save file ")
            local airbases = world.getAirbases()
            for _, airbase in ipairs(airbases) do
                if PWS_warehousesTable[airbase:getName()] then
                    local warehouse=airbase:getWarehouse()
                    Log("Persistent World | Warehouse found for "..airbase:getName().."")
                    local liquids = PWS_warehousesTable[airbase:getName()]["liquids"]
                    for liquidType, LiquidQty in pairs (liquids) do
                        warehouse:setLiquidAmount(liquidType, LiquidQty)
                    end
                    local weapons = PWS_warehousesTable[airbase:getName()]["weapon"]
                    for weaponType, qty in pairs(weapons) do
                        warehouse:setItem(weaponType, qty)
                    end
                    local aircraft = PWS_warehousesTable[airbase:getName()]["aircraft"]
                    for aircraftType, aircraftQty in pairs(aircraft) do
                        warehouse:setItem(aircraftType, aircraftQty)
                    end
                else Log("Persistent World | No warehouse for "..airbase:getName().."")
                end
            end
            Log("Persistent World | Warehouses stocks restored")
        else
            Log("Persistent World | No warehouses datas")
            PWS_warehousesTable = {}
        end
        --%%% SCHEDULE %%%
        ScheduledSaveAll()
        --%%% EVENT LOOP - ON DEAD, LOST, KILL %%%
        PWS.onDeadEventHandler = {}
        function PWS.onDeadEventHandler:onEvent(event)
            if event.id == world.event.S_EVENT_DEAD or event.id == world.event.S_EVENT_UNIT_LOST then --or event.id == world.event.S_EVENT_KILL then
                DebugLog("New event : DEAD")
                if event.initiator then --and event.initiator:getCoalition() ~= nil then
                    if ( Object.getCategory(event.initiator) == 1 or Object.getCategory(event.initiator) == 3 ) then
                        DebugLog("DEAD event.initiator is Unit or Static ("..Object.getCategory(event.initiator).."/"..event.initiator:getCategory()..")")
                        local deadUnit,deadUnitObjectCategory,deadUnitCategory,deadUnitCoalition,deadUnitName,deadUnitType
                        if event.id == world.event.S_EVENT_DEAD or event.id == world.event.S_EVENT_UNIT_LOST then
                            deadUnit = event.initiator
                            deadUnitObjectCategory = Object.getCategory(event.initiator) 
                            -- 1 UNIT / 2 WEAPON / 3 STATIC / 4 BASE / 5 SCENERY / 6 CARGO
                            deadUnitCategory = event.initiator:getDesc().category 
                            -- 0 AIRPLANE / 1 HELICOPTER / 2 GROUND_UNIT / 3 SHIP / 4 STRUCTURE / 5 ???
                            deadUnitCoalition = event.initiator:getCoalition()
                            --deadGroupName = event.initiator:getGroup():getName()
                            deadUnitName = event.initiator:getName()
                            deadUnitType = event.initiator:getTypeName()
                        elseif event.id == world.event.S_EVENT_KILL then
                            deadUnit 				 = event.target
                            deadUnitObjectCategory = event.target:getCategory()
                            -- 1 UNIT / 2 WEAPON / 3 STATIC / 4 BASE / 5 SCENERY / 6 CARGO
                            deadUnitCategory 		 = event.target:getDesc().category
                            -- 0 AIRPLANE / 1 HELICOPTER / 2 GROUND_UNIT / 3 SHIP / 4 STRUCTURE
                            deadUnitCoalition 	 = event.target:getCoalition()
                            --deadGroupName		     = event.initiator:getGroup():getName()
                            deadUnitName			 = event.target:getName()
                            deadUnitType			 = event.target:getTypeName()
                        else
                        end
                        if ( deadUnitCoalition == 1 or deadUnitCoalition == 2 and saveDeadBlue == true) then	
                            if deadUnitObjectCategory == 1 then -- UNIT
                                if ( deadUnitCategory == 2 or deadUnitCategory == 3 ) then -- GROUND_UNIT or SHIP
                                    DebugLog("DEAD event.initiator type is Unit")
                                    local _match = 0
                                    for i=1, #ignoredTypesToDeadList do
                                        if StrMatch(deadUnitType, ignoredTypesToDeadList[i]) then _match = _match + 1 end
                                    end
                                    for i=1, #ignoredNamesToDeadList do
                                        if StrMatch(deadUnitName, ignoredNamesToDeadList[i]) then _match = _match + 1 end
                                    end
                                    if _match ~= 0 then  
                                        DebugLog(deadUnitName.." ignored")
                                    else
                                        _match = 0
                                        for i=1, #PWS_deadUnitsTable do
                                            if PWS_deadUnitsTable[i] == deadUnitName then _match = _match + 1 end
                                        end
                                        if _match == 0 then
                                            PWS_deadUnitsTable[#PWS_deadUnitsTable+1] = deadUnitName
                                        end
                                        DebugLog(deadUnitName.." added to dead list.")
                                    end	
                                else
                                end
                            elseif deadUnitObjectCategory == 3 then	-- STATIC
                                local _match = 0
                                for i=1, #PWS_deadStaticsTable do
                                    if PWS_deadStaticsTable[i] == deadUnitName then _match = _match + 1 end
                                end
                                if _match == 0 then
                                    PWS_deadStaticsTable[#PWS_deadStaticsTable+1] = deadUnitName
                                end
                                DebugLog("Static "..deadUnitName.." destroyed")
                            else
                            end
                        else
                            DebugLog("DEAD event.initiator as no Coalition") 
                        end
                    else
                        DebugLog("DEAD event.initiator is not Unit or Static")
                    end	
                end
            end
        end
        world.addEventHandler(PWS.onDeadEventHandler)
        --%%% EVENT LOOP - ON BIRTH %%%
        PWS.onBirthEventHandler = {}
        function PWS.onBirthEventHandler:onEvent(event)
            if event.id == world.event.S_EVENT_BIRTH then
                DebugLog("New event : BIRTH")
                if event.initiator then
                    --> UNIT
                    if Object.getCategory(event.initiator) == 1 and event.initiator:getCoalition() ~= nil then -- UNIT
                        DebugLog("BIRTH event.initiator is UNIT ("..Object.getCategory(event.initiator)..")")
                        
                        local birthUnit,birthUnitCategory,birthObjectCategory,birthCoalition,birthGroupName,birthUnitType,birthUnitName,currentPos,currentPosition,birthUnitPosX,birthUnitPosY,currentHeading,currentPitch
                        birthUnit 				        = event.initiator
                        birthObjectCategory             = Object.getCategory(event.initiator)
                        -- 1 UNIT / 2 WEAPON / 3 STATIC / 4 BASE / 5 SCENERY / 6 CARGO
                        birthUnitCategory               = event.initiator:getDesc().category
                        -- 0 AIRPLANE / 1 HELICOPTER / 2 GROUND_UNIT / 3 SHIP / 4 STRUCTURE
                        birthCoalition                  = event.initiator:getCoalition()
                        birthGroupName		            = event.initiator:getGroup():getName()
                        birthUnitName			        = event.initiator:getName()
                        birthUnitType			        = event.initiator:getTypeName()
                        currentPos                      = Unit.getByName(birthUnitName):getPoint()
                        currentPosition                 = Unit.getByName(birthUnitName):getPosition()
                        currentHeading                  = math.atan2(currentPosition.x.z, currentPosition.x.x)
                        currentPitch                    = math.asin(currentPosition.x.y)
                        birthUnitPosY 		            = currentPos.z
                        birthUnitPosX 		            = currentPos.x

                        if (birthCoalition == 1 and saveBirthRed == true or birthCoalition == 2 and saveBirthBlue == true) then
                            if birthObjectCategory == 1 and birthUnitCategory == 2 then -- UNIT
                                local _match = 0
                                for i=1, #ignoredNamesToUnitBirthList do
                                    if StrMatch(birthUnitName, ignoredNamesToUnitBirthList[i]) then _match = _match + 1 end
                                end
                                local _pMatch = 0
                                for i=1, #namePatternList do
                                    if useNamePattern==true and not StrMatch(birthUnitName, namePatternList[i]) then _pMatch = _pMatch + 1 end
                                end
                                if _match ~=0 or _pMatch ~=0 then  
                                    Log("Persistent World | Birth Unit ignored")
                                else
                                    local groupMatch = 0
                                    for i = 1, #PWS_spawnedUnitsTable do
                                        if PWS_spawnedUnitsTable[i].groupName == birthGroupName then
                                            groupMatch = groupMatch+1
                                            PWS_spawnedUnitsTable[i].units[#PWS_spawnedUnitsTable[i].units+1] = {
                                                type = birthUnitType,
                                                name = birthUnitName,
                                                y = birthUnitPosY,
                                                x = birthUnitPosX,
                                                heading = currentHeading,
                                            }
                                        end
                                    end
                                    if groupMatch == 0 then
                                        PWS_spawnedUnitsTable[#PWS_spawnedUnitsTable+1] = {
                                            coalition = birthCoalition,
                                            objectCategory = birthObjectCategory,
                                            objectSubCategory = birthUnitCategory,
                                            groupName = birthGroupName,
                                            units = {
                                                [1] = {
                                                    type = birthUnitType,
                                                    name = birthUnitName,
                                                    y = birthUnitPosY,
                                                    x = birthUnitPosX,
                                                    heading = currentHeading,
                                                },
                                            }
                                        }
                                    end
                                    ignoredTypesToDeadList[#ignoredTypesToDeadList+1] = birthUnitName
                                end											
                            else
                            end
                        else
                        end
                    --> STATIC AND BASE (FARP)
                    elseif Object.getCategory(event.initiator) == 4 and event.initiator:getCoalition() and savedTypesToStaticBirthList[event.initiator:getDesc().typeName]
                        or Object.getCategory(event.initiator) == 3 and event.initiator:getCoalition() and savedTypesToStaticBirthList[event.initiator:getDesc().typeName]
                        then
                        if (event.initiator:getCoalition() == 1 and saveStaticsBirthRed == true or event.initiator:getCoalition() == 2 and saveStaticsBirthBlue == true) then
                            PWS_spawnedStaticsTable[#PWS_spawnedStaticsTable+1] = {
                                objectCategory = Object.getCategory(event.initiator),
                                coalition = event.initiator:getCoalition(),
                                name = event.initiator:getName(),
                                type = event.initiator:getDesc().typeName,
                                category = savedTypesToStaticBirthList[event.initiator:getDesc().typeName],
                                shape = staticTypesAndShape[event.initiator:getDesc().typeName],
                                x = event.initiator:getPoint().x,
                                y = event.initiator:getPoint().z,
                                heading = math.atan2(event.initiator:getPosition().x.z, event.initiator:getPosition().x.x)
                            }
                            DebugLog("Added static")
                        else
                            Log("Persistent World | Birth Unit ignored")
                        end
                    end
                end
            end
        end
        world.addEventHandler(PWS.onBirthEventHandler)
        --%%% EVENT LOOP - MARKS %%%
        PWS.onMarkEventHandler={}
        function PWS.onMarkEventHandler:onEvent(event)
            if world.event.S_EVENT_MARK_CHANGE == event.id and event.coalition ~= 0 then
            elseif world.event.S_EVENT_MARK_REMOVED == event.id and event.coalition ~= 0 then
                if (StrMatch(event.text, "&²²")) then
                    ScheduleFunction(function()
                        local s=StrMatch(event.text, "[0-9][0-9][0-9]")
                        if not s then s=25 elseif s<="020" then s=25 else s=ToNumber(s) end
                        Explode({x=event.pos.x, y=event.pos.y, z=event.pos.z},s)
                    end, nil, timer.getTime() + 5 )
                elseif (StrMatch(event.text, "pwsclearmsg")) then
                    ClearMsg()
                    DebugLog("ClearMsg()")
                elseif (StrMatch(event.text, "pwssavenow")) then
                    SaveAll()
                    DebugLog("SaveAll()")
                end
            end
        end
        world.addEventHandler(PWS.onMarkEventHandler)
    else
        Msg("Persistent World | Error, MissionScripting.lua 'sanitize'.", 10)
        Log("Persistent World | Error, MissionScripting.lua 'sanitize'.")
    end

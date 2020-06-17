RegisterNetEvent("setTeam")

local spawnPos = vector3(233.3, 215.6, 106.28)
local copSpawnPos = vector3(263.05, 207.82, 110.3)
local objective_duration = 11 -- always add 1
local objective_time = objective_duration
local spawnedPeds = {}
local team = -1
local models_cop = { "S_M_M_Armoured_01", "S_M_M_Armoured_02" }
local models_m = { "csb_reporter", "a_m_y_bevhills_01", "a_m_m_skater_01", "a_m_m_fatlatin_01", "a_m_m_soucent_01"}
local models_f = { "a_f_y_fitness_01", "a_f_y_business_01", "a_f_m_beach_01", "a_f_y_fitness_02"}
local objectives = { {pos = vector3(256.3, 226.1, 100.5), range = 2.0, name = "vault"}, {pos = vector3(262.3, 208.4, 109.18), range = 1.0, name = "office"} }

AddRelationshipGroup("robbers")
AddRelationshipGroup("civ")

-- https://docs.fivem.net/docs/game-references/blips/
for i=1,#objectives,1 do
	local blip = AddBlipForCoord(objectives[i].pos.x, objectives[i].pos.y, objectives[i].pos.z)
	BeginTextCommandSetBlipName("STRING");
	AddTextComponentString(objectives[i].name)
	EndTextCommandSetBlipName(blip)
end

-- TODO changeGameType???  https://docs.fivem.net/docs/resources/mapmanager/

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        SetPedDensityMultiplierThisFrame(0) -- https://runtime.fivem.net/doc/natives/#_0x95E3D6257B166CF2
        SetScenarioPedDensityMultiplierThisFrame(0, 0) -- https://runtime.fivem.net/doc/natives/#_0x7A556143A1C03898
		SetRandomVehicleDensityMultiplierThisFrame(0) -- https://runtime.fivem.net/doc/natives/#_0xB3B3359379FE77D3
		SetParkedVehicleDensityMultiplierThisFrame(0) -- https://runtime.fivem.net/doc/natives/#_0xEAE6DCC7EEE3DB1D
        SetVehicleDensityMultiplierThisFrame(0) -- https://runtime.fivem.net/doc/natives/#_0x245A6883D966D537
		if GetPlayerWantedLevel(PlayerId()) ~= 0 then
            SetPlayerWantedLevel(PlayerId(), 0, false) -- https://runtime.fivem.net/doc/natives/?_0x39FF19C64EF7DA5B
            SetPlayerWantedLevelNow(PlayerId(), false)
		end

		-- DrawMarker https://docs.fivem.net/docs/game-references/markers/ https://runtime.fivem.net/doc/natives/?_0x28477EC23D892089
		for i = 1, #objectives, 1 do
			DrawMarker(1, objectives[i].pos.x, objectives[i].pos.y, objectives[i].pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, objectives[i].range * 2.0 --[[ scaleX ]], objectives[i].range * 2.0 --[[ scaleY]], 1.2 --[[ scaleZ ]], 255 --[[red]], 255--[[green]], 0--[[blue]], 100 --[[alpa]], 0, 0, 2, 0, 0, 0, false)
		end
	end 
end)

local currentObjective = objectives[1];
Citizen.CreateThread(function()
    while true do
		Citizen.Wait(1000)

		if team == 0 then
			pos = GetEntityCoords(PlayerPedId())
			if not IsEntityDead(PlayerPedId()) and isInRangeOfObjective(pos) and objective_time > 0 then
				objective_time = objective_time - 1
				TriggerServerEvent("winProgress", objective_time)

				if objective_time <= 0 then
					TriggerServerEvent("win", currentObjective.name)
				end
			elseif not IsEntityDead(PlayerPedId()) and objective_time > 0  then
				objective_time = objective_duration
			end
		end
	end
end)

function isInRangeOfObjective(pos)
	for i = 1, #objectives, 1 do
		if GetDistanceBetweenCoords(objectives[i].pos.x, objectives[i].pos.y, objectives[i].pos.z, pos) < objectives[i].range and math.abs(objectives[i].pos.z - pos.z) < 2.0 then
			--store which objective we are capturing
			currentObjective = objectives[i]
			return true
		end
	end

	return false
end

AddEventHandler('onClientGameTypeStart', function()
	TriggerServerEvent("requestTeam")

	exports.spawnmanager:setAutoSpawnCallback(function()
		model_to_use = nil
		pos = nil
		if team == 0  then
			pos = spawnPos
			if math.random(1, 2) == 1  then
				model_to_use = GetHashKey(models_m[math.random(1, #models_m)])
			else
				model_to_use = GetHashKey(models_f[math.random(1, #models_f)])
			end
		else
			pos = copSpawnPos
			model_to_use = GetHashKey(models_cop[math.random(1, #models_cop)])
		end

		-- TODO set heading
        exports.spawnmanager:spawnPlayer({
            x = pos.x,
            y = pos.y,
            z = pos.z,
            model = model_to_use
		}, nil)
    end)
    exports.spawnmanager:forceRespawn()
end)

AddEventHandler("playerSpawned", function()
	if team == 1 then
		GiveWeaponToPed(PlayerPedId(), GetHashKey("weapon_stungun"), 999, false, false)
	end

    NetworkSetFriendlyFireOption(true)
	SetCanAttackFriendly(PlayerPedId(), true, false)
	objective_time = objective_duration
end)

AddEventHandler("setTeam", function(test)
	team = tonumber(test)

	Citizen.CreateThread(function()
		Citizen.Wait(250)
		exports.spawnmanager:forceRespawn()
	end)
end)

RegisterCommand("set-team", function(source, args)
	team = tonumber(args[1] or 1)
	exports.spawnmanager:forceRespawn()
end, false)

RegisterCommand("spawn-ped", function()
	local pos = GetEntityCoords(PlayerPedId())
	ped = "csb_reporter"
	RequestModel(ped)
	while not HasModelLoaded(ped) do 
		Citizen.Wait(1)
	end
	
	--[[refer above (4 only works for male peds and 5 is for female peds)]]
	newPed = CreatePed(4, ped, pos.x + 1, pos.y, pos.z , 0.0, true, true)

	SetPedRelationshipGroupHash(newPed, GetHashKey("civ"))
	SetRelationshipBetweenGroups(0, GetHashKey("civ"), GetHashKey("PLAYER"))
	SetPedMaxHealth(newPed, 10)
	
	TaskWanderInArea(newPed, pos.x, pos.y, pos.z, 10.0, 1.0, 2.0)

	table.insert(spawnedPeds, newPed)

	-- TaskWanderInArea(newPed, pos.x + 5, pos.y, pos.z, 20.0, 5.0, 0.0)
	-- TaskWanderStandard(newPed, 1.0, 1)
	
	-- ped, x, y, z, speed, timeout, heading, distance to slide
	-- TaskGoStraightToCoord(newPed, pos.x,  pos.y + 30, pos.z, 1, 999999999, 0, 0)
	
	-- follow waypoints
	-- TaskFlushRoute()
	-- TaskExtendRoute(pos.x + 20, pos.y, pos.z)
	-- TaskExtendRoute(pos.x + 5, pos.y + 20, pos.z)
	-- TaskExtendRoute(pos.x - 10, pos.y + 15, pos.z) 
	-- TaskFollowPointRoute(newPed, 1, 0)
	
	-- TaskStartScenarioInPlace(newPed, "PROP_HUMAN_STAND_IMPATIENT", 0, true)
	-- Good scenarios to use
	-- 	PROP_HUMAN_STAND_IMPATIENT
	--  WORLD_HUMAN_HANG_OUT_STREET
	--  WORLD_HUMAN_SMOKING
	--  WORLD_HUMAN_AA_COFFEE
	--  WORLD_HUMAN_AA_SMOKE
	--  CODE_HUMAN_CROSS_ROAD_WAIT
	--  WORLD_HUMAN_CLIPBOARD
	--  WORLD_HUMAN_GUARD_STAND
		
	-- SetForcePedFootstepsTracks(true) ????
	-- SetPedIsDrunk() ?????
end, false)

RegisterCommand("spawn-group", function()
	local pos = GetEntityCoords(PlayerPedId())

	for i=1,40,1 do
		spawnPedInRange(pos, 12)
	end

	cleanupModels()
end, false)

RegisterCommand("init", function()
	objective_time = objective_duration
	cleanup()

	for i=1,4,1 do
		spawnPedInRange(vector3(257.86, 218.0, 106.3), 1.0)
		spawnPedInRange(vector3(253.3, 219.3, 106.3), 1.0)
		spawnPedInRange(vector3(244.0, 216.5, 106.3), 2.0)
		spawnPedInRange(vector3(241.4, 222.6, 106.3), 2.0)
		spawnPedInRange(vector3(236.5, 226.2, 106.3), 1.0)
		spawnPedInRange(vector3(253.3, 207.4, 110.3), 1.0)
		spawnPedInRange(vector3(234.9, 216.2, 110.3), 1.0)
	end

	cleanupModels()
end, false)

function spawnPedInRange(pos, range)
	local ped = nil
	local type = 4
	if math.random(1, 2) == 1 then 
		ped = GetHashKey(models_m[math.random(1, #models_m)])
	else 
		ped = GetHashKey(models_f[math.random(1, #models_f)])
		type = 5
	end
	
	RequestModel(ped)
	while not HasModelLoaded(ped) do 
		Citizen.Wait(1)
	end
	
	--[[refer above (4 only works for male peds and 5 is for female peds)]]
	newPed = CreatePed(type, ped, pos.x + math.random(range * -1, range), pos.y + math.random(range * -1, range), pos.z, 0.0, true, true)
	
	SetPedRelationshipGroupHash(newPed, GetHashKey("civ"))
	SetRelationshipBetweenGroups(0, GetHashKey("civ"), GetHashKey("PLAYER"))

	pos = GetEntityCoords(newPed)
	TaskWanderInArea(newPed, pos.x, pos.y, 106.3, 5.0, 1.0, 1.0)
	table.insert(spawnedPeds, newPed)
end

function cleanupModels()
	for x=1,#models_m do
		SetModelAsNoLongerNeeded(GetHashKey(model_m[x]))
	end
	for x=1,#models_f do
		SetModelAsNoLongerNeeded(GetHashKey(model_f[x]))
	end
end

RegisterCommand("cleanup", function()
	cleanup()
end, false)

function  cleanup() -- TODO: FIND_FIRST_PED, FIND_NEXT_PED and END_FIND_PED -- EnumeratePeds???
	for i = 1, #spawnedPeds do
		ped = spawnedPeds[i]
		DeletePed(ped)
	end
end

RegisterCommand("respawn", function()
	exports.spawnmanager:forceRespawn()
end, false)

-- RequestModel(object_model)
-- local iter_for_request = 1
-- while not HasModelLoaded(object_model) and iter_for_request < 5 do
-- 	Citizen.Wait(500)				
-- 	iter_for_request = iter_for_request + 1
-- end
-- if not HasModelLoaded(object_model) then
-- 	SetModelAsNoLongerNeeded(object_model)
-- else
-- 	local ped = PlayerPedId()
-- 	local x,y,z = table.unpack(GetEntityCoords(ped))
-- 	local created_object = CreateObjectNoOffset(object_model, x, y, z, 1, 0, 1)
-- 	PlaceObjectOnGroundProperly(created_object)
-- 	FreezeEntityPosition(created_object,true)
-- 	SetModelAsNoLongerNeeded(object_model)
-- end



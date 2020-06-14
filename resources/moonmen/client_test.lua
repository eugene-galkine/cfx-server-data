RegisterNetEvent("setTeam")

local spawnPos = vector3(233.3, 215.6, 106.28)

local team = 0
local models_cop = { "S_M_M_Armoured_01", "S_M_M_Armoured_02" }
local models_m = { "csb_reporter", "a_m_y_bevhills_01", "a_m_m_skater_01", "a_m_m_fatlatin_01", "a_m_m_soucent_01"}
local models_f = { "a_f_y_fitness_01", "a_f_y_hiker_01", "a_f_y_business_01", "a_f_m_beach_01", "a_f_y_fitness_02"}
AddRelationshipGroup("robbers")
AddRelationshipGroup("civ")

AddEventHandler('onClientGameTypeStart', function()
	-- TriggerServerEvent("requestTeam", PlayerId())
	-- while team == nil do
	-- 	Citizen.wait(10)
	-- end
	
	if GetPlayerName(PlayerId()) == "Limoncio2" then
		team = 1
		-- SetPedRelationshipGroupHash(PlayerPedId(), "COP")
	else
		team = 0
	end

	exports.spawnmanager:setAutoSpawnCallback(function()
		model_to_use = nil
		if team == 0  then
			if math.random(1, 2) == 1  then
				model_to_use = GetHashKey(models_m[math.random(1, #models_m)])
			else
				model_to_use = GetHashKey(models_f[math.random(1, #models_f)])
			end
		else
			model_to_use = GetHashKey(models_cop[math.random(1, #models_cop)])
		end

        exports.spawnmanager:spawnPlayer({
            x = spawnPos.x,
            y = spawnPos.y,
            z = spawnPos.z,
            model = model_to_use
		}, function()
			if team == 1 then
				GiveWeaponToPed(PlayerPedId(), GetHashKey("weapon_stungun"), 999, false, false)
			end
        end)
    end)

    exports.spawnmanager:setAutoSpawn(true)
    exports.spawnmanager:forceRespawn()
end)

AddEventHandler("playerSpawned", function()
    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(PlayerPedId(), true, false)
end)

AddEventHandler("setTeam", function(_team)
	TriggerEvent("chatMessage", "ERROR", {255, 0, 0}, "team set")
	team = _team
end)

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
    end 
end)



-- Citizen.CreateThread(function()
-- 	while true do
-- 		Citizen.Wait(500)
		
--     end
-- end)

RegisterCommand("name",  function()
	name = GetPlayerName(PlayerId())
	TriggerEvent('chat:addMessage', {
		args = { name }
	})
end, false)

RegisterCommand("where", function() 
	local pos = GetEntityCoords(PlayerPedId())

	TriggerEvent('chat:addMessage', {
                args = {("X:%s  Y:%s  Z:%s"):format(pos.x, pos.y, pos.z)}
            })
end, false)

RegisterCommand("spawn", function(source, args)
	-- account for the argument not being passed
    local vehicleName = args[1] or 'adder'

    -- check if the vehicle actually exists
    if not IsModelInCdimage(vehicleName) or not IsModelAVehicle(vehicleName) then
        TriggerEvent('chat:addMessage', {
            args = { 'Cant spawn that' }
        })

        return
    end
	
	-- load the model
    RequestModel(vehicleName)

    -- wait for the model to load
    while not HasModelLoaded(vehicleName) do
        Wait(500) -- often you'll also see Citizen.Wait
    end

    -- get the player's position
    local playerPed = PlayerPedId() -- get the local player ped
    local pos = GetEntityCoords(playerPed) -- get the position of the local player ped

    -- create the vehicle
    local vehicle = CreateVehicle(vehicleName, pos.x, pos.y, pos.z, GetEntityHeading(playerPed), true, false)
    -- set the player ped into the vehicle's driver seat
    SetPedIntoVehicle(playerPed, vehicle, -1)
    -- give the vehicle back to the game (this'll make the game decide when to despawn the vehicle)
    SetEntityAsNoLongerNeeded(vehicle)
    -- release the model
    SetModelAsNoLongerNeeded(vehicleName)
end, false)

RegisterCommand("set-team", function(source, args)
	local team = args[1] or "COP"
	SetPedRelationshipGroupHash(PlayerPedId(), team)
end, false)

RegisterCommand("weapon", function(source, args)
	-- weapon_pistol
	-- weapon_pumpshotgun
	local weapon = args[1] or "weapon_pistol"
	GiveWeaponToPed(PlayerPedId(), GetHashKey(weapon), 999, false, false)
end, false)

RegisterCommand("spawn-ped", function()
	local pos = GetEntityCoords(PlayerPedId())
	ped = "csb_reporter"
	RequestModel(ped)
	while not HasModelLoaded(ped) do 
		Citizen.Wait(1)
	end
	
	--[[refer above (4 only works for male peds and 5 is for female peds)]]
	newPed = CreatePed(4, ped, pos.x + 5, pos.y, pos.z , 0.0, true, true)

	SetPedRelationshipGroupHash(newPed, GetHashKey("civ"))
	SetRelationshipBetweenGroups(0, GetHashKey("civ"), GetHashKey("PLAYER"))
	SetPedMaxHealth(newPed, 10)
	
	TaskWanderInArea(newPed, pos.x, pos.y, pos.z, 10.0, 1.0, 2.0)

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
		newPed = CreatePed(type, ped, pos.x + math.random(-12, 12), pos.y + math.random(-12, 12), pos.z + 6, 0.0, true, true)
		
		SetPedRelationshipGroupHash(newPed, GetHashKey("civ"))
		SetRelationshipBetweenGroups(0, GetHashKey("civ"), GetHashKey("PLAYER"))

		TaskWanderInArea(newPed, pos.x, pos.y, pos.z, 10.0, 1.0, 1.0)
		-- TaskFlushRoute()
		-- TaskExtendRoute(pos.x + math.random(-5, 5), pos.y + math.random(-5, 5), pos.z)
		-- TaskExtendRoute(pos.x + math.random(-5, 5), pos.y + math.random(-5, 5), pos.z)
		-- TaskExtendRoute(pos.x + math.random(-5, 5), pos.y + math.random(-5, 5), pos.z)
		-- TaskExtendRoute(pos.x + math.random(-5, 5), pos.y + math.random(-5, 5), pos.z)
		-- TaskExtendRoute(pos.x + math.random(-5, 5), pos.y + math.random(-5, 5), pos.z)
		-- TaskExtendRoute(pos.x + math.random(-5, 5), pos.y + math.random(-5, 5), pos.z)
		-- TaskExtendRoute(pos.x + math.random(-5, 5), pos.y + math.random(-5, 5), pos.z)
		-- TaskFollowPointRoute(newPed, 1, 0)
	end

	for x=1,#models_m do
		SetModelAsNoLongerNeeded(model)
	end
	for x=1,#models_f do
		SetModelAsNoLongerNeeded(model)
	end
end, false)

-- TODO must stop playernames to hide names


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



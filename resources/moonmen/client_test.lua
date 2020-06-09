--void REGISTER_COMMAND(char* commandName, func handler, BOOL restricted);

local spawnPos = vector3(-988, -2985, 13.95)

AddRelationshipGroup('cops')
AddRelationshipGroup('robbers')

AddEventHandler('onClientGameTypeStart', function()
    exports.spawnmanager:setAutoSpawnCallback(function()
        exports.spawnmanager:spawnPlayer({
            x = spawnPos.x,
            y = spawnPos.y,
            z = spawnPos.z,
            model = 'a_m_m_skater_01'
        }, function()
            TriggerEvent('chat:addMessage', {
                args = {'Welcome to the party!'}
            })
        end)
    end)

    exports.spawnmanager:setAutoSpawn(true)
    exports.spawnmanager:forceRespawn()
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

RegisterCommand("test",  function()
	TriggerEvent('chatMessage', "[SERVER]", {100, 100, 100}, "banana")
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
	
end, false)

RegisterCommand("weapon", function(source, args)
	-- weapon_pistol
	-- weapon_pumpshotgun
	local weapon = args[1] or "weapon_pistol"
	GiveWeaponToPed(PlayerPedId(), GetHashKey(weapon), 999, false, false)
end, false)

RegisterCommand("spawn-ped", function()
	models_cop = { "S_M_M_Armoured_01", "S_M_M_Armoured_02" }
	models_m = { "csb_reporter", "a_m_y_bevhills_01", "a_m_m_skater_01"} -- todo
	models_f = { "a_f_y_fitness_01", "a_f_y_fitness_02", "s_f_m_fembarber"} -- todo
	
	local pos = GetEntityCoords(PlayerPedId())
	ped = "a_m_y_bevhills_01"
	RequestModel(ped)
	while not HasModelLoaded(ped) do 
		Citizen.Wait(1)
	end
	
	--[[refer above (4 only works for male peds and 5 is for female peds)]]
	newPed = CreatePed(4, ped, pos.x + 5, pos.y, pos.z , 0.0 --[[float (int) Heading]], false, true)
	--- now lets give the ped some attributes -> https://runtime.fivem.net/doc/natives/#_0x9F7794730795E019
	SetPedCombatAttributes(newPed, 0, true) --[[ BF_CanUseCover ]]
	SetPedCombatAttributes(newPed, 5, true) --[[ BF_CanFightArmedPedsWhenNotArmed ]]
	SetPedCombatAttributes(newPed, 46, true) --[[ BF_AlwaysFight ]]
	SetPedFleeAttributes(newPed, 0, true) --[[ allows/disallows the ped to flee from a threat i think]]
	
	SetPedMaxHealth(newPed, 10)
end, false)




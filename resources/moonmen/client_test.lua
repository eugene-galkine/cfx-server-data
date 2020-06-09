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
        SetVehicleDensityMultiplierThisFrame(0) -- https://runtime.fivem.net/doc/natives/#_0x245A6883D966D537
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


RegisterServerEvent("requestTeam")

local copCount = 0
local robberCount = 0

AddEventHandler("requestTeam", function()
    if copCount > robberCount then
        TriggerClientEvent("setTeam", source, "0")
        robberCount = robberCount + 1
    else
        TriggerClientEvent("setTeam", source, "1")
        copCount = copCount + 1
    end
end)

-- TODO make player zero the host, to spawn and clean up
-- TODO implement better team init
--  TODO implement rounds with switching off

-- function GetPlayers()
--     local players = {}

--     for i = 0, 31 do
--         if NetworkIsPlayerActive(i) then
--             table.insert(players, i)
--         end
--     end

--     return players
-- end

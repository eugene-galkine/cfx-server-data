RegisterServerEvent("requestTeam")
RegisterServerEvent("win")
RegisterServerEvent("winProgress")

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

AddEventHandler("win", function(location)
    globalChat(("%s has won by capturing the %s"):format(GetPlayerName(source), location))
    --TODO end round and trigger restart
end)

AddEventHandler("winProgress", function(remaingTime)
    globalChat(("%s will capture an objective in %d seconds"):format(GetPlayerName(source), remaingTime))
end)

function globalChat(message)
    players = GetPlayers()
    for i=1,#players do
        TriggerClientEvent("chatMessage", players[i], message)
    end
end

-- TODO make player zero the host, to spawn and clean up
-- TODO implement better team init
--  TODO implement rounds with switching off
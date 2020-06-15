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

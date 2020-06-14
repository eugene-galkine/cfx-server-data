-- function greetingHandler ( message )
-- 	-- the predefined variable 'client' points to the player who triggered the event and should be used due to security issues   
-- 	outputChatBox ( "The client says: " .. message, client )
-- end

-- addEvent( "onGreeting", true )
-- addEventHandler( "onGreeting", resourceRoot, greetingHandler )

RegisterServerEvent("requestTeam")

local copCount = 0
local robberCount = 0

AddEventHandler("requestTeam", function(p)
    TriggerClientEvent("chatMessage", p, "ERROR", {255, 0, 0}, "team requested")
    if copCount > robberCount then
        robberCount = robberCount + 1
        TriggerClientEvent("setTeam", p, "ROBBER")
    else
        copCount = copCount + 1
        TriggerClientEvent("setTeam", p, "COP")
    end
end)

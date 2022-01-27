local eventNames = {}
local resourceTokens = {}

function init()	
	if Config.VerboseClient then
		print("Tokenizer initializing")
	end
	math.randomseed(GetClockHours() + GetClockMinutes())
    Citizen.CreateThread(function()
		TriggerEvent("tokenizer:clientReady")
	end)
end

function requestObfuscatedEventName(resourceName)
	if eventNames[resourceName] == nil then
		TriggerServerEvent("tokenizer:requestEventName", resourceName)
		while eventNames[resourceName] == nil do
			Citizen.Wait(0)
		end
	end

	return eventNames[resourceName]
end

function setupClientResource(resourceName)
    local eventName = requestObfuscatedEventName(resourceName)
	if Config.VerboseClient then
		print("Requested Obfuscated Event for " .. tostring(resourceName) .. " got " .. tostring(eventName))
	end

	RegisterNetEvent(eventName)
    AddEventHandler(eventName, function(serverToken)
        resourceTokens[resourceName] = serverToken
    end)

    return function()
        TriggerServerEvent("tokenizer:requestToken", resourceName)
        while resourceTokens[resourceName] do
            Citizen.Wait(0)
        end

        local token = resourceTokens[resourceName]
        resourceTokens[resourceName] = nil

        return token
    end
end

RegisterNetEvent("tokenizer:eventNameReceived")
AddEventHandler("tokenizer:eventNameReceived", function(resourceName, eventName)
	eventNames[resourceName] = eventName
end)

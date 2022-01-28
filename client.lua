local eventNames = {}
local resourceTokens = {}
local initialized = false

function init()	
	if Config.VerboseClient then
		print("Tokenizer initializing")
	end
	math.randomseed(GetClockHours() + GetClockMinutes())
	initialized = true
end

function requestObfuscatedEventName(resourceName)
	if eventNames[resourceName] == nil then
		if Config.VerboseClient then
			print("Requesting eventname for resource " .. resourceName)
		end
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
		if Config.VerboseClient then
			print("Requesting token for resource " .. resourceName)
		end
        TriggerServerEvent("tokenizer:requestToken", resourceName)
        while resourceTokens[resourceName] == nil do
            Citizen.Wait(0)
        end

        local token = resourceTokens[resourceName]
		if Config.VerboseClient then
			print("Received " .. token .. " for resource " .. resourceName)
		end
        return token
    end
end

RegisterNetEvent("tokenizer:eventNameReceived")
AddEventHandler("tokenizer:eventNameReceived", function(resourceName, eventName)
	if Config.VerboseClient then
		print("Received eventname " .. eventName .. " for resouce " .. resourceName)
	end
	eventNames[resourceName] = eventName
end)

AddEventHandler("onClientResourceStart", function(resourceName)
	if resourceName == GetCurrentResourceName() and not initialized then
		init()
	end
end)

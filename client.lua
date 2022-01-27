local resourceNames = {}
local resourceTokens = {}

function init()	
	if Config.VerboseClient then
		print('Tokenizer initializing')
	end
	math.randomseed(GetClockHours() + GetClockMinutes())
    Citizen.CreateThread(function()
		TriggerEvent('salty_tokenizer:clientReady')
	end)
end

function requestObfuscatedEventName(resource)
	if resourceNames[resource] == nil then
		resourceNames[resource] = { id = generateId(), name = false }
		TriggerServerEvent('salty_tokenizer:requestObfuscation', resource, resourceNames[resource].id)
		while not resourceNames[resource].name do
			Citizen.Wait(0)
		end
	end
	return resourceNames[resource].name
end

function setupClientResource(resourceName)
	if Config.VerboseClient then
		print("Deploying Obfuscated Event: " .. tostring(resource) .. " = " .. tostring(requestObfuscatedEventName(resource)))
	end

    local eventName = requestObfuscatedEventName(resourceName)
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

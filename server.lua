local resourceEventNames = {}
local resourceTokens = {}

function init()
	if Config.VerboseServer then
		print('Tokenizer initializing')
	end
	math.randomseed(os.time())
    initComplete = true
end

function initNewPlayer(resourceName, playerId)
    if resourceToken[resourceName][playerId] == nil then
        resourceTokens[resourceName][playerId] = {}
    end
end

function setupServerResource(resourceName)
	while not initComplete do
		Citizen.Wait(50)
	end

    resourceTokens[resourceName] = {}
    resourceEventNames[resourceName] = exports[GetCurrentResourceName()]:generateToken()
	if Config.VerboseServer then
		print("Resource " .. tostring(resourceName) .. ": token map initialized, eventname is " .. resourceEventNames[resourceName])
	end
end

function validateToken(resourceName, playerId, token)
	if resourceTokens[resourceName] == nil then
		return true
	elseif playerId == "" then -- If the request came from the server, then no need to authenticate the token
		return true
	else
        local serverToken = resourceTokens[resourceName][playerId]
		if Config.VerboseServer then
			print("Validating token for " .. tostring(resourceName) .. " for Player ID " .. tostring(playerId) .. ". Provided: " .. tostring(token) .. " Stored: " .. tostring(serverToken))
		end

        if serverToken == nil or token ~= serverToken then
            if Config.VerboseServer then
				print("Invalid token detected! Resource: " .. tostring(resourceName) .. ", Player ID: " .. tostring(playerId) .. ".")
			end
			if Config.CustomAction then
				Config.CustomActionFunction(playerId)
			else
				DropPlayer(playerId, Config.KickMessage)
			end
            return false
        elseif Config.VerboseServer then
            print("Valid token! Resource: " .. tostring(resourceName) .. ", Player ID: " .. tostring(playerId) .. ".")
        end
	end

	resourceTokens[resourceName][playerId] = nil
	return true
end

RegisterNetEvent("tokenizer:requestEventName")
AddEventHandler("tokenizer:requestEventName", function(resourceName)
	local playerId = source
	local eventName =  resourceEventNames[resourceName]
	if Config.VerboseServer then
		print("Sending eventname " ..  eventName .. " to " .. playerId .. " for resource " .. resourceName .. ".")
	end
	TriggerClientEvent("tokenizer:eventNameReceived", playerId, resourceName, eventName)
end)

RegisterNetEvent("tokenizer:requestToken")
AddEventHandler("tokenizer:requestToken", function(resourceName)
	local playerId = source
	local token = exports[GetCurrentResourceName()]:generateToken()
	resourceTokens[resourceName][playerId] = token
	TriggerClientEvent(resourceEventNames[resourceName], playerId, token)
end)

AddEventHandler("onServerResourceStart", function(resourceName)
	if resourceName == GetCurrentResourceName() then
		init()
    end
end)

AddEventHandler("playerDropped", function(player, reason)
	local playerId = source
	if Config.VerboseServer then
		print("Player ID " .. tostring(playerId) .. " dropped, purging tokens.")
	end
    for k, v in pairs(resourceTokens) do
        if resourceTokens[k][player] ~= nil then
            resourceTokens[k][player] = nil
        end
    end
end)

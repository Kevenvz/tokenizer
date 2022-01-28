# tokenizer

Add rolling security tokens to FiveM server events that are accessible from the client in order to prevent against Lua injections (and similar cheats).

# Features
* A unique token is generated for a player per resource
* Tokens are sent through listeners that are obfuscated per client and unique every server restart.
* Tokens can only be used once.
* Players that trigger a server event without a valid security token are kicked from the game.

# Installation
* Install [yarn](https://github.com/citizenfx/cfx-server-data) (Can be found in `/resources/[system]/[builders]/yarn`)
* Configure `tokenizer` using the `config.lua` file.
* Add `ensure tokenizer` to your server config.
* Restart your server.

# Usage
The security token is stored in a variable named `securityToken` on the client side in each resource. In order to retreive the security token for a given resource, you must include the `init.lua` script in your resource's `__resource.lua` or `fxmanifest.lua` file. The `init.lua` script must be included as both a server and client script:
```lua
dependency 'tokenizer'

server_script '@tokenizer/init.lua'
client_script '@tokenizer/init.lua'
```

## Client
Place the following code in the client, it requests a new token and passes it to the server:
```lua
local securityToken = RequestToken()
TriggerServerEvent("anticheat-testing:testEvent", securityToken)
```

It's recommended to make sure that the client is initialized to prevent false positives, like so:
```lua
Citizen.CreateThread(function()
	while not TokenReady do
		Citizen.Wait(100)
	end
	local securityToken = RequestToken()
	TriggerServerEvent('anticheat-testing:testEvent', securityToken)
end)
```

## Server
In order to protect a server event, a simple if statement must be added.
```lua
RegisterNetEvent('anticheat-testing:testEvent')
AddEventHandler('anticheat-testing:testEvent', function(token)
	local _source = source
	if not exports['tokenizer']:validateToken(GetCurrentResourceName(), _source, token) then
		return false
	end
	print("valid token")
end)
```

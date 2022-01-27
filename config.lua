Config = {}

--[[
	Enable verbose output on the console
	VerboseClient should be disable in production since it exposed tokens
]]
Config.VerboseClient = true
Config.VerboseServer = true

--[[
	Define the message given to users with an invalid token
--]]
Config.KickMessage = "Invalid security token detected."

--[[
	Define a custom function to trigger when a player is kicked
	If Config.CustomAction is false, the player will be dropped
]]
Config.CustomAction = false
Config.CustomActionFunction = function(source)
	print("Custom action executing for: " .. source)
	DropPlayer(source, Config.KickMessage)
end

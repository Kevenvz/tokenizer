if IsDuplicityVersion() then
	AddEventHandler("onResourceStart", function(resourceName)
		if resourceName == GetCurrentResourceName() then
			exports['tokenizer']:setupServerResource(resourceName)
		end
	end)
else
	TokenReady = false
	AddEventHandler("onClientResourceStart", function(resourceName)
		if resourceName == GetCurrentResourceName() then
			RequestToken = exports['tokenizer']:setupClientResource(resourceName)
			TokenReady = true
		end
	end)
end

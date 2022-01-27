if IsDuplicityVersion() then
	AddEventHandler('tokenizer:serverReady', function()
		exports['tokenizer']:setupServerResource(GetCurrentResourceName())
	end)
else
	requestToken = function()
		print('Token is not available yet')
	end
    tokenReady = false
	AddEventHandler('tokenizer:clientReady', function()
		requestToken = exports['tokenizer']:setupClientResource(GetCurrentResourceName())
		tokenReady = true
	end)
end
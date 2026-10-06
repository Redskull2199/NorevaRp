function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end

Citizen.CreateThread(function()
	AddTextEntry("toleair", "toleair")
	AddTextEntry("tolebuf", "tolebuf")
	AddTextEntry("tolerhin", "tolerhin")
	AddTextEntry("tolespeedo", "tolespeedo")
	AddTextEntry("tolwbuf", "tolwbuf")
	AddTextEntry("tolwrhin", "tolwrhin")
	AddTextEntry("tolwsmav", "tolwsmav")
	AddTextEntry("tolwsvan", "tolwsvan")

end)
function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end

Citizen.CreateThread(function()
	AddTextEntry("ttmodz_izzy_buffalo4", "ttmodz_izzy_buffalo4")
	AddTextEntry("ttmodz_izzy_castigator", "ttmodz_izzy_castigator")
	AddTextEntry("ttmodz_izzy_dorado", "ttmodz_izzy_dorado")
end)
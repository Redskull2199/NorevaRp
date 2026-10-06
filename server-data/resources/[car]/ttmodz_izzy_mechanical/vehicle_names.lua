function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end

Citizen.CreateThread(function()
	AddTextEntry("ttmodz_benson", "ttmodz_benson")
	AddTextEntry("ttmodz_flatbed", "ttmodz_flatbed")

end)
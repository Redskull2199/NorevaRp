Locales = {}

function _(str, ...)
	if Locales[Config.Language] ~= nil then

		if Locales[Config.Language][str] ~= nil then
			return string.format(Locales[Config.Language][str], ...)
		else
			return 'Translation [' .. Config.Language .. '][' .. str .. '] does not exist'
		end

	else
		return 'Locale [' .. Config.Language .. '] does not exist'
	end
end

function Language(str, ...)
	return tostring(_(str, ...):gsub("^%l", string.upper))
end
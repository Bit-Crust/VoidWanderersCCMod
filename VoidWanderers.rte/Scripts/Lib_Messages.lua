-----------------------------------------------------------------------------------------
-- Message handling related functions to add to library
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- First argument should be a MO to return to, second should be the name of the value
-----------------------------------------------------------------------------------------
CF["IsValidGSReadRequest"] = function(context)
	return IsMovableObject(context[1]) and type(context[2]) == "string";
end
-----------------------------------------------------------------------------------------
-- First argument should be the name of the value, second doesn't really matter
-----------------------------------------------------------------------------------------
CF["IsValidGSWriteRequest"] = function(context)
	return type(context[1]) == "string";
end
-----------------------------------------------------------------------------------------
-- First argument should be a MO to return to, second should be the path to the value
-----------------------------------------------------------------------------------------
CF["IsValidCFReadRequest"] = function(context)
	local validName = true;
	for i = 1, #context[2] do
		validName = validName and type(context[2][i]) == "string";
	end
	return IsMovableObject(context[1]) and validName;
end
-----------------------------------------------------------------------------------------
-- All you really need is a valid path, any value works
-----------------------------------------------------------------------------------------
CF["IsValidCFWriteRequest"] = function(context)
	local validName = true;
	for i = 1, #context[1] do
		validName = validName and type(context[1][i]) == "string";
	end
	return validName;
end
-----------------------------------------------------------------------------------------
-- First argument should be MO to return to, second should be the list of nestings
-- into the CF required to specify the function, third should be the list of arguments
-- to pass, which won't even be checked for existence, being assumed nil in absence
-----------------------------------------------------------------------------------------
CF["IsValidCFCallRequest"] = function(context)
	local validName = true;
	for i = 1, #context[2] do
		validName = validName and type(context[2][i]) == "string";
	end
	return IsMovableObject(context[1]) and validName;
end
-----------------------------------------------------------------------------------------
-- Unpack exists but we need to define pack for the return trip
-----------------------------------------------------------------------------------------
CF["PackReturnForMessage"] = function(...)
	return {...};
end
-----------------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------------
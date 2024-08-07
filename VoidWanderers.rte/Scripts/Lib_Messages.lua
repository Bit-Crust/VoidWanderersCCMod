-----------------------------------------------------------------------------------------
-- Message handling related functions to add to library
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Void Wanderers' message handling function, this isn't supposed to be used by anything
-- that isn't VW itself, so don't do that, it will not work.
-----------------------------------------------------------------------------------------
VWHandleMessage = function(message, context)
	if message == "read_from_GS" and IsValidGSReadRequest(context) then
		local target = ToMOSRotating(context[1])
		local information = CF["GS"][context[2]]
		target:SendMessage("return_from_activity", information)
	elseif message == "write_to_GS" and IsValidGSWriteRequest(context) then
		CF["GS"][context[1]] = context[2]
	elseif message == "read_from_CF" and IsValidCFReadRequest(context) then
		local temp = CF
		local flag = false
		
		-- Run down the path, flag for failure and break if something before the last step is nil or we run into a function
		for i = 1, #context[2] do
			temp = temp[context[2][i]]
			if (not temp and i ~= #context[2]) or type(temp) == "function" then
				flag = true
				break
			end
		end

		if flag then
			print("ERROR: Malformed path.")
			return
		end
		
		ToMOSRotating(context[1]):SendMessage("return_from_activity", temp)
	elseif message == "write_to_CF" and IsValidCFWriteRequest(context) then
		local temp = CF
		local flag = false
		
		-- Run down the path, flag for failure and break if something before the last step is nil or we run into a function
		for i = 1, #context[1] - 1 do
			temp = temp[context[1][i]]
			if (not temp) or type(temp) == "function" then
				flag = true
				break
			end
		end

		if flag then
			print("ERROR: Malformed path or trying to overwrite function with value.")
			return
		end

		temp[context[1][#context[1]]] = context[2]
	elseif message == "call_in_CF" and IsValidCFCallRequest(context) then
		local target = ToMOSRotating(context[1])

		local temp = CF
		local flag = false
		
		for i = 1, #context[2] do
			temp = temp[context[2][i]]
			if not temp then
				flag = true
				break
			end
		end

		if flag or type(temp) ~= "function" then
			print("Your index does not produce an existing value, unless nil might be what you're looking for.")
			return
		end
		
		target:SendMessage("return_from_activity", PackReturnForMessage(temp(unpack(context[3]))))
	end
end
-----------------------------------------------------------------------------------------
-- First argument should be a MO to return to, second should be the name of the value
-----------------------------------------------------------------------------------------
IsValidGSReadRequest = function(context)
	return IsMovableObject(context[1]) and type(context[2]) == "string"
end
-----------------------------------------------------------------------------------------
-- First argument should be the name of the value, second doesn't really matter
-----------------------------------------------------------------------------------------
IsValidGSWriteRequest = function(context)
	return type(context[1]) == "string"
end
-----------------------------------------------------------------------------------------
-- First argument should be a MO to return to, second should be the path to the value
-----------------------------------------------------------------------------------------
IsValidCFReadRequest = function(context)
	local validName = true
	for i = 1, #context[2] do
		validName = validName and type(context[2][i]) == "string"
	end
	return IsMovableObject(context[1]) and validName
end
-----------------------------------------------------------------------------------------
-- All you really need is a valid path, any value works
-----------------------------------------------------------------------------------------
IsValidCFWriteRequest = function(context)
	local validName = true
	for i = 1, #context[1] do
		validName = validName and type(context[1][i]) == "string"
	end
	return validName
end
-----------------------------------------------------------------------------------------
-- First argument should be MO to return to, second should be the list of nestings
-- into the CF required to specify the function, third should be the list of arguments
-- to pass, which won't even be checked for existence, being assumed nil in absence
-----------------------------------------------------------------------------------------
IsValidCFCallRequest = function(context)
	local validName = true
	for i = 1, #context[2] do
		validName = validName and type(context[2][i]) == "string"
	end
	return IsMovableObject(context[1]) and validName
end
-----------------------------------------------------------------------------------------
-- Unpack exists but we need to define pack for the return trip
-----------------------------------------------------------------------------------------
PackReturnForMessage = function(...)
	return {...}
end
-----------------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------------
local tempvar = nil

function GS_Read(self, key) 
	tempvar = nil
	ActivityMan:GetActivity():SendMessage("read_from_GS", {self, key})
	return tempvar
end

function GS_Write(key, value) 
	ActivityMan:GetActivity():SendMessage("write_to_GS", {key, value})
end

function CF_Read(self, keys) 
	tempvar = nil
	ActivityMan:GetActivity():SendMessage("read_from_CF", {self, keys})
	return tempvar
end

function CF_Write(keys, value) 
	ActivityMan:GetActivity():SendMessage("write_to_CF", {keys, value})
end

function CF_Call(self, keys, arguments) 
	tempvar = nil
	ActivityMan:GetActivity():SendMessage("call_in_CF", {self, keys, arguments})
	return tempvar
end

-- The recommended way to receive messages, otherwise values can not be returned from calls or reads

function OnMessage(self, message, context)
	if message == "return_from_activity" then
		tempvar = context
	end
end
-----------------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------------
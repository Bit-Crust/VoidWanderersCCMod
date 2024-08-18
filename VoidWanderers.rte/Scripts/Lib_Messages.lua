-----------------------------------------------------------------------------------------
-- Message handling related functions to add to library on VW startup
-- and anything that wants to interface with Activity facing variables.
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Void Wanderers' message handling function, this isn't supposed to be used by anything
-- that isn't VW itself, so don't do that, it will not work.
-----------------------------------------------------------------------------------------
VWHandleMessage = function(message, context)
	if message == "read_from_GS" and IsValidGSReadRequest(context) then
		local target = ToMOSRotating(context[1])
		local information = CF.GS[context[2]]
		target:SendMessage("return_from_activity", information)
	elseif message == "write_to_GS" and IsValidGSWriteRequest(context) then
		CF.GS[context[1]] = context[2]
	elseif message == "read_from_CF" and IsValidCFReadRequest(context) then
		local temp = CF
		local flag = false
		
		-- Run down the path, flag for failure and break if something before the last step is nil or we run into a function
		for i = 1, #context[2] do
			temp = temp[context[2][i]]
			if (not temp and i ~= #context[2]) then
				flag = -1
				break
			elseif type(temp) == "function" then
				flag = -2
				break
			end
			print("READ STEP " .. i .. " : " .. context[2][i])
		end

		if flag then
			local message = "Default CF read error, I dunno."
			if flag == -1 then message = "Malformed path on CF read." end
			if flag == -2 then message = "Trying to read function value on CF read, try call_in_CF instead, see if you can figure it out." end
			error(message)
			return
		end
		
		ToMOSRotating(context[1]):SendMessage("return_from_activity", temp)
	elseif message == "write_to_CF" and IsValidCFWriteRequest(context) then
		local temp = CF
		local flag = false
		local printConcat = ""
		
		-- Run down the path, flag for failure and break if something before the last step is nil or we run into a function
		for i = 1, #context[1] - 1 do
			temp = temp[context[1][i]]
			if (not temp) then
				flag = -1
				break
			elseif type(temp) == "function" then
				flag = -2
				break
			end
			printConcat = printConcat .. context[1][i] .. "."
		end

		if flag then
			local message = "Default CF write error, I dunno."
			if flag == -1 then message = "Malformed path on CF write." end
			if flag == -2 then message = "Trying to overwrite function with value on CF write." end
			error(message)
			return
		end
		
		print("writing to CF." .. printConcat .. context[1][#context[1]])
		temp[context[1][#context[1]]] = context[2]
	elseif message == "call_in_CF" and IsValidCFCallRequest(context) then
		local target = ToMOSRotating(context[1])

		local temp = CF
		local flag = false
		
		for i = 1, #context[2] do
			temp = temp[context[2][i]]
			if (not temp) then
				flag = -1
				break
			elseif type(temp) ~= "function" then
				flag = -2
				break
			end
		end

		if flag then
			local message = "Default CF call error, I dunno."
			if flag == -1 then message = "Malformed path on CF remote call." end
			if flag == -2 then message = "Trying to execute non-function value on CF remote call." end
			error(message)
			return
		end
		
		target:SendMessage("return_from_activity", {temp(unpack(context[3]))})
	end
end
-----------------------------------------------------------------------------------------
-- First argument should be a MO to return to, second should be the name of the value
-----------------------------------------------------------------------------------------
IsValidGSReadRequest = function(context)
	return IsMovableObject(context[1])
end
-----------------------------------------------------------------------------------------
-- First argument should be the name of the value, second doesn't really matter
-----------------------------------------------------------------------------------------
IsValidGSWriteRequest = function(context)
	return true
end
-----------------------------------------------------------------------------------------
-- First argument should be a MO to return to, second should be the path to the value
-----------------------------------------------------------------------------------------
IsValidCFReadRequest = function(context)
	return IsMovableObject(context[1])
end
-----------------------------------------------------------------------------------------
-- All you really need is a valid path, any value works
-----------------------------------------------------------------------------------------
IsValidCFWriteRequest = function(context)
	return true
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
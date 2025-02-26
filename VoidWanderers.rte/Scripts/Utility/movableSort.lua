return (function()
	local array = {};

	for actor in MovableMan.Actors do
		table.insert(array, actor);

		--print(actor)
	end

	local reference = VoidWanderers:GetControlledActor(0);
	local function test(ref, actL, actR)
		posL = SceneMan:ShortestDistance(ref.Pos, actL.Pos, true);
		posR = SceneMan:ShortestDistance(ref.Pos, actR.Pos, true);
		local differentSides = (posR.X < 0) ~= (posL.X < 0);
		print("Diff " .. tostring(ref) .. " ? " .. tostring(actL) .. " , " .. tostring(actR) .. " :" .. tostring(differentSides))
		return ((posR.X < 0) ~= (posL.X < 0) and (posL.X < 0))
			or (math.abs(posL.Y) / 2 + math.abs(posL.X)) > math.abs(posR.Y) / 2 + math.abs(posR.X);
	end

	for i = 1, #array - 1 do
		for j = 1, #array - i do
			if test(reference, array[j + 1], array[j]) then
				table.insert(array, j + 1, table.remove(array, j));
			end
		end
	end

	for _, actor in ipairs(array) do
		print(actor)
	end
end)();
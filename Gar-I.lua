garyModule = require(script.Brain) -- PLACE MODULESCRIPT INSIDE THIS NAMED "BRAIN"

generationSize = 6
deadGaries = 0
generation = 1
repopPlusMinus = 120

garies = {}

function redoExtinction()
	generation = 0
	for i = 1,6 do
		local garyObj = game.ServerStorage.Gary:Clone()
		garyObj.Parent = workspace
		garyObj.BodyGyro.CFrame = garyObj.CFrame
		
		local speed = math.random(12,20)
		
		table.insert(garies, garyModule.new(garyObj,
			speed, -- SPEED
			math.random(1,10) / (50 - (speed/3)),  -- METABOLISM
			math.random(1,100)/100)) -- SEXINESS
	end

	startGeneration()
end

function handleEndOfGeneration()
	generation = generation + 1

	local closestGary = nil
	local repopulationists = {}
	repopPlusMinus = repopPlusMinus - 1
	for i,gary in pairs(garies) do
		local repopChance = gary.sexiness * (gary.energy/100) * (workspace.goal.Position - gary.obj.Position).magnitude 
		
		local random = math.random(1,150)
		if (repopChance > 0.1 and repopChance < (random+repopPlusMinus) and repopChance > (random-repopPlusMinus) and gary.obj.Position.Z < 109) then
			table.insert(repopulationists, gary)
		end
		
		--print(repopChance)
		if (not closestGary) then
			closestGary = gary
		else
			if ((workspace.goal.Position - gary.obj.Position).magnitude < (workspace.goal.Position - closestGary.obj.Position).magnitude) then
				--print"found closest gary"
				closestGary = gary
			end
		end
	end
	
	for i = 1,#garies do
		table.remove(garies, 1)
	end
	print(#garies)
	for i,v in pairs(workspace:GetChildren()) do
		if v.Name == "Gary" or v.Name == "food" then v:Destroy() end
	end
	
	-- MUTATE & REGENERATE
	if (#repopulationists == 0) then print"extinct" redoExtinction() print"-------------------\n-------------------\n" end
	
	for i,v in pairs(repopulationists) do
		local children = math.random(1,3)
		for i = 1,children do
			local garyObj = game.ServerStorage.Gary:Clone()
			garyObj.Position = garyObj.Position + Vector3.new(math.random(-70,70),0,0)
			garyObj.Parent = workspace
			garyObj.BodyGyro.CFrame = garyObj.CFrame
			
			table.insert(garies, garyModule.new(garyObj, v.backupSpeed + (math.random(-5,5)/10), v.metabolismEfficiency + (math.random(-5,5)/50), v.sexiness + (math.random(-5,5)/10)))
		end
	end
	print("Garies in generation "..tostring(generation).." : "..tostring(#garies))
	
	for i = 1,10 do
		local food = game.ServerStorage.food:Clone()
		food.Position = Vector3.new(-12 + math.random(-75, 75), 2, 88 + math.random(-40,40))
		food.Parent = workspace
		food.Anchored = true
		
		food.Touched:connect(function(obj)
			if (obj.Name == "Gary") then
				local gary = nil
				for i,g in pairs(garies) do
					if (g.obj == obj) then
						gary = g
					end
				end
				
				if gary then
					gary.energy = 100
					food:Destroy()
				end
			end
		end)
	end
	
	deadGaries = 0
	generationSize = #garies
	
	startGeneration()
end

function literallyFuckingKillGary(gary)
	if (not gary.dead) then
		gary.dead = true
		gary.backupSpeed = gary.speed
		gary.speed = 0
		gary:move()
		gary:rotate(0)
		
		deadGaries = deadGaries + 1
		
		local allGariesDead = true
		
		for i,v in pairs(garies) do
			if (not v.dead) then
				allGariesDead = false
			end
		end
		
		if (allGariesDead) then
			handleEndOfGeneration()
		end
	end
end

function startGeneration()
	for i,gary in pairs(garies) do
		spawn(function()
			while (not gary.dead) do
				gary.energy = gary.energy - ((1/gary.metabolismEfficiency) / 10)
				gary:step()
				--[[if not gary.dead then
					gary.obj.BillboardGui.healthRn.Size = UDim2.new(1*(gary.energy/100),0,1,0)
				end]]
				
				if (gary.energy < 0) then
					literallyFuckingKillGary(gary)
				end
				
				wait()
			end
		end)
	end
end

for i,v in pairs(workspace:GetChildren()) do
	if (v.Name == "dead") then
		v.Touched:connect(function(obj)
			if (obj.Name == "Gary") then
				local gary = nil
				for i,g in pairs(garies) do
					if (g.obj == obj) then
						gary = g
					end
				end
				
				if gary then
					literallyFuckingKillGary(gary)
				end
			end
		end)
	elseif (v.Name == "food") then
		v.Touched:connect(function(obj)
			if (obj.Name == "Gary") then
				local gary = nil
				for i,g in pairs(garies) do
					if (g.obj == obj) then
						gary = g
					end
				end
				
				if gary then
					gary.energy = 100
					v:Destroy()
				end
			end
		end)
	end
end

for i = 1,generationSize do
	local garyObj = game.ServerStorage.Gary:Clone()
	garyObj.Parent = workspace
	garyObj.BodyGyro.CFrame = garyObj.CFrame
	
	local speed = math.random(12,20)
	
	table.insert(garies, garyModule.new(garyObj,
		speed, -- SPEED
		math.random(1,10) / (50 - (speed/3)),  -- METABOLISM
		math.random(1,100)/100)) -- SEXINESS
end

startGeneration()

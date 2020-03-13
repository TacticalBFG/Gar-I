-- AI Brain for Gar-I AI.
-- Responsible for controlling the actual model

local gary = {}

function gary:move()
	if (self.obj and self.obj:FindFirstChild("BodyVelocity")) then
		self.obj.Position = self.obj.Position + (self.obj.CFrame.lookVector * self.speed)/30
		--self.obj.BodyVelocity.Velocity = self.obj.CFrame.LookVector * self.speed
	end
end

function gary:rotate(amt)
	if (self.obj and self.obj:FindFirstChild("BodyGyro")) then
		self.obj.BodyGyro.CFrame = self.obj.BodyGyro.CFrame * CFrame.fromEulerAnglesXYZ(0,amt,0)
	end
end


function gary:step()
	local turnAmt = math.random(-10,10)
	
	self:move()
	self:rotate(turnAmt)
	
	table.insert(self.steps, turnAmt)
end

function gary.new(obj,spd, met, sexy)
	local coolGary = {
		-- Properties
		["obj"] = obj,
		["speed"] = spd,
		["dead"] = false,
		["steps"] = {},
		["energy"] = 100,
		["metabolismEfficiency"] = met,
		["sexiness"] = sexy,
		["backupSpeed"] = spd,
		["parent"] = nil,
		
		-- Methods
		["step"] = gary.step,
		["move"] = gary.move,
		["rotate"] = gary.rotate,
	}
	
	return coolGary
end

return gary

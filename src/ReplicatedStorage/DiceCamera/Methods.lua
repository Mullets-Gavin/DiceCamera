--// logic
local Methods = {}
Methods.Enabled = true
Methods.Shaking = false
Methods.ScopeEnabled = false
Methods.X_Angle = 0
Methods.Y_Angle = 0
Methods.CameraPos = Vector3.new(4.5,0,10)
Methods.DefaultPos = Vector3.new(4.5,0,10)
Methods.ZoomDistance = 7
Methods.ZoomDefault = 70
Methods.ZoomScoped = 50
Methods.ShakeCache = {}

--[[ MODIFIED CODE ]]
Methods.Spring = require(script.Parent.Spring).new(Vector3.new())
Methods.Spring.Damper = 0.5
Methods.Spring.Speed = 25
--[[               ]]

--// services
local LoadLibrary = require(game:GetService('ReplicatedStorage'):WaitForChild('PlayingCards'))
local Services = setmetatable({}, {__index = function(cache, serviceName)
    cache[serviceName] = game:GetService(serviceName)
    return cache[serviceName]
end})

--// functions
local function GenerateRandomNumber()
	local ranNum = math.random(1,4)/10
	local flipCoin = math.random()
	if flipCoin >= 0.5 then
		return -ranNum
	else
		return ranNum
	end
end

function Methods:Position()
	local Player = Services['Players'].LocalPlayer
	local Character = Player.Character
	local Camera = Services['Workspace'].CurrentCamera
	if Character then
		local HRP = Character:FindFirstChild('HumanoidRootPart')
		if Character and HRP then
			local startCFrame = CFrame.new((HRP.CFrame.p + Vector3.new(0,2.2,0))) * CFrame.Angles(0, math.rad(Methods.X_Angle), 0) * CFrame.Angles(math.rad(Methods.Y_Angle), 0, 0)
			local cameraCFrame = startCFrame + startCFrame:vectorToWorldSpace(Vector3.new(Methods.CameraPos.X, Methods.CameraPos.Y, Methods.CameraPos.Z))
			local cameraFocus = startCFrame + startCFrame:vectorToWorldSpace(Vector3.new(Methods.CameraPos.X, Methods.CameraPos.Y, -50000))
			
			--[[ MODIFIED CODE ]]
			Camera.CFrame = CFrame.new(cameraCFrame.p,cameraFocus.p) + Methods.Spring.Position
			--[[               ]]
		end
	end
end

function Methods:Collisions()
	local Player = Services['Players'].LocalPlayer
	local Character = Player.Character
	local Camera = Services['Workspace'].CurrentCamera
	if Character then
		local HRP = Character:FindFirstChild('HumanoidRootPart')
		if HRP then
			local IgnoreList = {}
			table.insert(IgnoreList,Character)
			local CameraRay = Ray.new(HRP.Position, Camera.CFrame.Position - HRP.Position)
			local HitPart, HitPosition = Services['Workspace']:FindPartOnRayWithIgnoreList(CameraRay, IgnoreList)
			if HitPart then
				if HitPart.Transparency == 0 and HitPart.CanCollide then
					local Calculate = (Camera.CFrame - (Camera.CFrame.Position - HitPosition)) + (HRP.Position - Camera.CFrame.Position).Unit
					Camera.CFrame = Calculate
				end
			end
		end
	end
end

function Methods:Shake(intensity)
	--[[ MODIFIED CODE ]]
	
--	coroutine.wrap(function()
--		local Camera = Services['Workspace'].CurrentCamera
--		Methods.Shaking = true
--		for index = 1,intensity do
--			Methods.CameraPos = Vector3.new(Methods.CameraPos.X + GenerateRandomNumber(), Methods.CameraPos.Y + GenerateRandomNumber(), Methods.CameraPos.Z)
--			Services['RunService'].RenderStepped:Wait()
--			--wait(0.1)
--		end
--		Methods.Shaking = false
--		if Methods.ScopeEnabled then
--			Methods.CameraPos = Vector3.new(Methods.DefaultPos.X,0,Methods.ZoomDistance)
--			Camera.FieldOfView = Methods.ZoomScoped
--		else
--			Methods.CameraPos = Methods.DefaultPos
--			Camera.FieldOfView = Methods.ZoomDefault
--		end
--		Methods.ShakeCache = {}
--	end)()
	
	local random = Random.new()
	local direction = Vector3.new(random:NextNumber(-1, 1), random:NextNumber(-1, 1), random:NextNumber(-1, 1))
	if direction.Magnitude > 0 then
		direction = direction.Unit
	else
		direction = Vector3.new(1,1,1).Unit
	end
	Methods.Spring:Impulse(direction * intensity)
	
	--[[               ]]
end

function Methods:Scope(state)
	Methods.ScopeEnabled = state
	local Camera = Services['Workspace'].CurrentCamera
	if Methods.Enabled then
		if state then
			Methods.CameraPos = Vector3.new(4.5,0,Methods.ZoomDistance)
			local FOVTween = Services['TweenService']:Create(Camera,TweenInfo.new(0.5),{FieldOfView = Methods.ZoomScoped})
			FOVTween:Play()
			FOVTween.Completed:Wait()
			FOVTween:Destroy()
			return
		end
	end
	--[[ MODIFIED CODE ]]
--	if not Methods.Shaking then
		Methods.CameraPos = Methods.DefaultPos
		local FOVTween = Services['TweenService']:Create(Camera,TweenInfo.new(0.5),{FieldOfView = Methods.ZoomDefault})
		FOVTween:Play()
		FOVTween.Completed:Wait()
		FOVTween:Destroy()
--	end
	--[[               ]]
end

function Methods:Calculate(input)
	Methods.X_Angle = Methods.X_Angle - input.Delta.x * 0.4
	Methods.Y_Angle = math.clamp(Methods.Y_Angle - input.Delta.y * 0.4,-50,50)
end

function Methods:Update()
	if Methods.Enabled then
		Services['UserInputService'].MouseBehavior = Enum.MouseBehavior.LockCenter
		Methods:Position()
		Methods:Collisions()
	else
		Methods:Scope(false)
	end
end

return Methods
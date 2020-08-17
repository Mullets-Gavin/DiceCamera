--[[
	@Author: Gavin "Mullets" Rosenthal
	@Desc: A custom camera module for offsetting the player camera
--]]

--// logic
local CustomCamera = {}

--// services
local LoadLibrary = require(game:GetService('ReplicatedStorage'):WaitForChild('PlayingCards'))
local Services = setmetatable({}, {__index = function(cache, serviceName)
    cache[serviceName] = game:GetService(serviceName)
    return cache[serviceName]
end})

--// variables
local Camera = Services['Workspace'].CurrentCamera
local Methods = require(script.Methods)

--// functions
function CustomCamera:Enabled(state)
	Methods.Enabled = state
	if state then
		Camera.CameraType = Enum.CameraType.Scriptable
	else
		Camera.CameraType = Enum.CameraType.Custom
	end
end

function CustomCamera:Shake(intensity)
	Methods:Shake(intensity)
end

function CustomCamera:GetDefault()
	return Methods.DefaultPos
end

if Services['RunService']:IsClient() then
	Services['UserInputService'].InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			Methods:Calculate(input)
		end
	end)
	
	Services['UserInputService'].InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			Methods:Scope(true)
		end
	end)
	
	Services['UserInputService'].InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			Methods:Scope(false)
		end
	end)
	
	Services['RunService'].RenderStepped:Connect(function(dt)
		Methods:Update()
	end)
end

return CustomCamera
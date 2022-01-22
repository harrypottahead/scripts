--<< slap battles
local PlayersService = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = PlayersService.LocalPlayer
if localPlayer.PlayerScripts:FindFirstChild("WSC") then
	local wsc = localPlayer.PlayerScripts["WSC"]
	setparentinternal(wsc, workspace);
	wsc.Disabled = true;
end

--<< globals
getgenv().killstreakKnockback = 0
getgenv().reverseProtection = false
getgenv().replicaCloneSpeed = 17
getgenv().autoClone = false

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local method = getnamecallmethod()
	local args = {...}
	if not checkcaller() then
		if method == "FireServer" and self.Name == "KSHit" then
			args[2] = getgenv().killstreakKnockback
			return oldNamecall(self, unpack(args))
		end
	end
	if method == "FireServer" and self.Parent == replicatedStorage and getgenv().reverseProtection then
		local hit = args[1]
		if typeof(hit) == "Instance" then
			local character = hit and hit.Parent
			if character == localPlayer.Character then
				return
			else
				local head = character:FindFirstChild("Head")
				if head and head:FindFirstChild("UnoReverseCard") then
					return
				end
			end
		end
	end
	return oldNamecall(self, ...)
end))

workspace.ChildAdded:Connect(function(child)
	if not localPlayer.Character then
		return
	end
	if string.find(child.Name, localPlayer.Name) and child ~= localPlayer.Character then
		local humanoid = child:WaitForChild("Humanoid")
		humanoid.WalkSpeed = getgenv().replicaCloneSpeed
		if humanoid == localPlayer.Character.Humanoid then return end
		humanoid.Changed:Connect(function(property)
			if property == "WalkSpeed" then
				humanoid.WalkSpeed = getgenv().replicaCloneSpeed
			end
		end)
	end
end)

local function godModeActivated()
	local character = localPlayer.Character
	if character then
		task.spawn(function()
			character:WaitForChild("isInArena"):Destroy();
		end)
	end
end

local function antiTimestopActivated()
	local character = localPlayer.Character
	if character then
		task.spawn(function()
			character:WaitForChild("TSVulnerability"):Destroy();
		end)
	end
end

--<< library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()
local slapGUI = library.Load({
	Title = "Slap Battles",
	SizeX = 500,
	Theme = "Dark",
	SizeY = 350,
})

local glovesTab = slapGUI.New({
	Title = "Gloves",
})

local miscTab = slapGUI.New({
	Title = "Misc",
})

glovesTab.Slider({
	Text = "Killstreak Knockback",
	Min = 0,
	Def = 0,
	Max = 250,
	Callback = function(s)
		getgenv().killstreakKnockback = s
	end,
})

glovesTab.Dropdown({
	Text = "Get Kills",
	Options = {"5 Kills", "10 Kills", "25 Kills", "50 Kills", "75 Kills", "100 Kills", "250 Kills"},
	Callback = function(kills)
		if not localPlayer.Character then 
			return 
		end
		local tool = localPlayer.Backpack:FindFirstChild("Killstreak") or localPlayer.Character:FindFirstChild("Killstreak")
		if not tool then 
			return
		end
		if tool.Parent.Name == "Backpack" then
			localPlayer.Character.Humanoid:EquipTool(tool);
		end
		task.spawn(function()
			local killFunction = nil;
			for i,f in ipairs(getgc(false)) do
				if type(f) == "function" and islclosure(f) then
					local name = debug.getinfo(f).name
					if string.find(name, "kill") then 
						killFunction = f;
						break
					end
				end
			end
			local killNumber = tonumber(string.match(kills, "%d+"))
			for i = 1, killNumber do
                --local wt = (i/killNumber)/20
				killFunction();
                --task.wait(wt);
			end
		end)
	end,
})

miscTab.Button({
	Text = "Get Evaded Badge",
	Callback = function()
		if not localPlayer.Character then return end
		local badgeService = game:GetService("BadgeService")
		local userId = localPlayer.UserId
		local badgeId = 2124847850
		local index = 0
		local doors = game:GetService("Workspace").PocketDimension.Doors
		pcall(function()
			repeat
				if localPlayer.Character then
					local humanoid = localPlayer.Character and localPlayer:FindFirstChild("Humanoid")
					if humanoid and humanoid.Health > 0 then
						index += 1
						local door = doors:FindFirstChild(tostring(index))
						if not door then
							break
						end
						firetouchinterest(localPlayer.Character.Head, door, 0)
						firetouchinterest(localPlayer.Character.Head, door, 1)
					else
						localPlayer.CharacterAdded:Wait();
					end
				end
			until badgeService:UserHasBadgeAsync(userId, badgeId);
		end)
	end,
})

miscTab.Button({
	Text = "God Mode",
	Callback = function()
		godModeActivated();
	end,
})

miscTab.Button({
	Text = "Anti Timestop",
	Callback = function()
		antiTimestopActivated();
	end,
})

miscTab.Toggle({
	Text = "Reverse Protection",
	Callback = function(s)
		getgenv().reverseProtection = s
	end,
	Enabled = false,
})

glovesTab.Slider({
	Text = "Replica Clone Speed",
	Callback = function(s)
		getgenv().replicaCloneSpeed = s
	end,
	Min = 17,
	Def = 17,
	Max = 70,
})

glovesTab.Toggle({
	Text = "Auto-Clone",
	Callback = function(state)
		getgenv().autoClone = state;
	end,
	Enabled = false,
})

miscTab.Button({
	Text = "Hide Nametag",
	Callback = function()
		pcall(function()
			localPlayer.Character.Head.Nametag:Destroy();
		end)
	end,
})

workspace.ChildRemoved:Connect(function(child)
	if getgenv().autoClone then
		if string.find(child.Name, localPlayer.Name) and child ~= localPlayer.Character then
			--<< clone time ended
			game:GetService("ReplicatedStorage").Duplicate:FireServer()
		end
	end
end)

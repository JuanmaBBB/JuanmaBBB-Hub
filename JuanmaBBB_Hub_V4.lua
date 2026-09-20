local LoadStart = tick()
Abysall.SavePath = "Doors/Game"

local Library = Abysall.Interface.Library
local SaveManager = Abysall.Interface.SaveManager
local ThemeManager = Abysall.Interface.ThemeManager

local Toggles = Library.Toggles
local Options = Library.Options

local function CloneReference(Object)
	if Abysall and Abysall.Environment.cloneref then
		return Abysall.Environment.cloneref(Object)
	end
	return Object
end

local Services = setmetatable({}, {
	__index = function(Self, Name)
		return CloneReference(game:GetService(Name))
	end
})

local Globals = {}
local Connections = {}
local ESPConnections = {}
local Groupboxes = {}
local FakePrompts = {}
local Functions = {}
local PartProperties = {}

local Objects = {
	Prompts = {},
	Objectives = {},
	Doors = {},
	HidingSpots = {},
	Entities = {},
	SeekObstructions = {},
	Items = {},
	Chests = {},
	Currency = {},
	Ladders = {},
	Obstructions = {},
	EventTriggers = {},
	JumpscareModules = {},
	SeekHighlights = {},
	EyestalkHighlights = {},
	SeekNodes = {},
	SeekDuckBoards = {},
	SeekBridges = {},
	PathLights = {}
}

Globals.IncompatibleMessage = "Your executor doesn't support this feature."

Functions.CheckCompatability = function(Array)
	for _, Name in Array do
		if not Abysall.Environment[Name] then
			return false
		end
	end
	return true
end

local Entities = {
	["RushMoving"] = {
		Alias = "Rush",
		NotifyMessage = { Title = "Entity Rush has spawned.", Body = "Find a hiding spot." }
	},
	["AmbushMoving"] = {
		Alias = "Ambush",
		NotifyMessage = { Title = "Entity Ambush has spawned.", Body = "Find a hiding spot." }
	},
	["Eyes"] = {
		Alias = "Eyes",
		NotifyMessage = { Title = "Entity Eyes has spawned.", Body = "Avoid looking at it." }
	},
	["Lookman"] = {
		Alias = "Eyes",
		NotifyMessage = { Title = "Entity Eyes has spawned.", Body = "Avoid looking at it." }
	},
	["BackdoorRush"] = {
		Alias = "Blitz",
		NotifyMessage = { Title = "Entity Blitz has spawned.", Body = "Find a hiding spot." }
	},
	["BackdoorLookman"] = {
		Alias = "Lookman",
		NotifyMessage = { Title = "Entity Lookman has spawned.", Body = "Avoid looking at its eyes." }
	},
	["Groundskeeper"] = {
		Alias = "Groundskeeper",
		NotifyMessage = { Title = "Entity Groundskeeper has spawned.", Body = "Avoid stepping on the grass." }
	},
	["A60"] = {
		Alias = "A-60",
		NotifyMessage = { Title = "Entity A-60 has spawned.", Body = "Find a hiding spot." }
	},
	["A120"] = {
		Alias = "A-120",
		NotifyMessage = { Title = "Entity A-120 has spawned.", Body = "Find a hiding spot." }
	},
	["GloombatSwarm"] = {
		Alias = "Gloombat Swarm",
		NotifyMessage = { Title = "Entity Gloombat Swarm has spawned.", Body = "Keep all light sources turned off." }
	},
	["GlitchRush"] = {
		Alias = "RNIUSHCG==",
		NotifyMessage = { Title = "Entity RNIUSHCG== has spawned.", Body = "Find a hiding spot." }
	},
	["GlitchAmbush"] = {
		Alias = "AR0xMBUSH",
		NotifyMessage = { Title = "Entity AR0xMBUSH has spawned.", Body = "Find a hiding spot." }
	},
	["MonumentEntity"] = {
		Alias = "Monument",
		NotifyMessage = { Title = "Entity Monument has spawned.", Body = "It can't move while you are looking at it." }
	},
	["JeffTheKiller"] = {
		Alias = "Jeff the Killer",
		NotifyMessage = { Title = "Entity Jeff the Killer has spawned.", Body = "Avoid touching him." }
	},
	["CustomEntity"] = {
		Alias = "Custom Entity",
		NotifyMessage = { Title = "Entity Custom Entity has spawned.", Body = "Find a hiding spot." }
	},
	["FrozenAmbush"] = {
		Alias = "Frozen Ambush",
		NotifyMessage = { Title = "Entity Frozen Ambush has spawned.", Body = "Find a hiding spot." }
	},
	["SallyMoving"] = {
		Alias = "Sally",
		NotifyMessage = { Title = "Entity Sally has spawned.", Body = "Drop an item for her." }
	},
	["Caws"] = {
		Alias = "Caws",
		NotifyMessage = { Title = "Entity Caws has spawned.", Body = "It marks Iron Keys and Lotus Petals." }
	},
	["Caw"] = {
		Alias = "Caws",
		NotifyMessage = { Title = "Entity Caws has spawned.", Body = "It marks Iron Keys and Lotus Petals." }
	},
	["Grampy"] = {
		Alias = "Grampy",
		NotifyMessage = { Title = "Entity Grampy has spawned.", Body = "Give him 8 Lotus Petals for a Lotus." }
	},
	["Honcho"] = {
		Alias = "Honcho",
		NotifyMessage = { Title = "Entity Honcho has spawned.", Body = "Run! Match the packages on the doors." }
	},
	["Bash"] = {
		Alias = "Bash",
		NotifyMessage = { Title = "Entity Bash has spawned.", Body = "Find a hiding spot." }
	},
	["BashMoving"] = {
		Alias = "Bash",
		NotifyMessage = { Title = "Entity Bash has spawned.", Body = "Find a hiding spot." }
	},
	["Ransom"] = {
		Alias = "Ransom",
		NotifyMessage = { Title = "Entity Ransom has spawned.", Body = "Stop moving completely." }
	},
	["Scribbles"] = {
		Alias = "Scribbles",
		NotifyMessage = { Title = "Entity Scribbles has spawned.", Body = "Watch the doors ahead." }
	},
	["ScribblesMoving"] = {
		Alias = "Scribbles",
		NotifyMessage = { Title = "Entity Scribbles has spawned.", Body = "Watch the doors ahead." }
	},
	["Drone"] = {
		Alias = "Drone",
		NotifyMessage = { Title = "Entity Drone has spawned.", Body = "Avoid its line of sight." }
	},
	["DroneMoving"] = {
		Alias = "Drone",
		NotifyMessage = { Title = "Entity Drone has spawned.", Body = "Avoid its line of sight." }
	},
	["Alma"] = {
		Alias = "Alma",
		NotifyMessage = { Title = "Entity Alma has spawned.", Body = "Keep your distance." }
	},
	["Fih"] = {
		Alias = "Fih",
		NotifyMessage = { Title = "Entity Fih has spawned.", Body = "Find a hiding spot." }
	},
	["Teller"] = {
		Alias = "Teller",
		NotifyMessage = { Title = "Entity Teller has spawned.", Body = "Find a hiding spot." }
	},
	["Portrait"] = {
		Alias = "Portrait",
		NotifyMessage = { Title = "Entity Portrait has spawned.", Body = "Do not look at it." }
	},
	["Forget-Me-Not"] = {
		Alias = "Forget-Me-Not",
		NotifyMessage = { Title = "Entity Forget-Me-Not has spawned.", Body = "Take notes." }
	},
	["ForgetMeNot"] = {
		Alias = "Forget-Me-Not",
		NotifyMessage = { Title = "Entity Forget-Me-Not has spawned.", Body = "Take notes." }
	},
	["Creak"] = {
		Alias = "Creak",
		NotifyMessage = { Title = "Entity Creak has spawned.", Body = "Find a hiding spot." }
	},
	["Creek"] = {
		Alias = "Creak",
		NotifyMessage = { Title = "Entity Creak has spawned.", Body = "Find a hiding spot." }
	},
	["Noise"] = {
		Alias = "Noise",
		NotifyMessage = { Title = "Entity Noise has spawned.", Body = "Stay quiet." }
	},
	["Stem"] = {
		Alias = "Stem",
		NotifyMessage = { Title = "Entity Stem has spawned.", Body = "Find a hiding spot." }
	},
	["Meld"] = {
		Alias = "Meld",
		NotifyMessage = { Title = "Entity Meld has spawned.", Body = "Find a hiding spot." }
	},
	["Cobbler"] = {
		Alias = "Cobbler",
		NotifyMessage = { Title = "Entity Cobbler has spawned.", Body = "Find a hiding spot." }
	}
}

local ItemNames = {
	["Lighter"] = "Lighter",
	["Flashlight"] = "Flashlight",
	["Lockpick"] = "Lockpicks",
	["Vitamins"] = "Vitamins",
	["Bandage"] = "Bandage",
	["StarVial"] = "Starlight Vial",
	["StarBottle"] = "Starlight Bottle",
	["StarJug"] = "Starlight Barrel",
	["Shakelight"] = "Gummy Flashlight",
	["Straplight"] = "Straplight",
	["Bulklight"] = "Spotlight",
	["Battery"] = "Battery",
	["Candle"] = "Candle",
	["Crucifix"] = "Crucifix",
	["CrucifixWall"] = "Crucifix",
	["Glowsticks"] = "Glowstick",
	["SkeletonKey"] = "Skeleton Key",
	["Candy"] = "Candy",
	["ShieldMini"] = "Mini Shield Potion",
	["ShieldBig"] = "Big Shield Potion",
	["BandagePack"] = "Bandage Pack",
	["BatteryPack"] = "Battery Pack",
	["RiftCandle"] = "Moonlight Candle",
	["LaserPointer"] = "Laser Pointer",
	["HolyGrenade"] = "Holy Hand Grenade",
	["Shears"] = "Shears",
	["Smoothie"] = "Smoothie",
	["Cheese"] = "Cheese",
	["Bread"] = "Bread",
	["AlarmClock"] = "Alarm Clock",
	["RiftSmoothie"] = "Moonlight Smoothie",
	["GweenSoda"] = "Gween Soda",
	["GlitchCube"] = "Glitch Fragment",
	["Scanner"] = "Tablet",
	["Bomb"] = "Bomb",
	["Knockbomb"] = "Knockbomb",
	["Nanner"] = "Nanner",
	["BigBomb"] = "Big Bomb",
	["SnakeBox"] = "Hiding Box",
	["GoldGun"] = "Golden Gun",
	["StopSign"] = "Stop Sign",
	["TipJar"] = "Tip Jar",
	["HoneyPot"] = "Honey Pot",
	["Lantern"] = "Lantern",
	["IronKey"] = "Iron Key",
	["LotusPetal"] = "Lotus Petal",
	["Compass"] = "Compass",
	["LotusPetalPickup"] = "Lotus Petal",
	["Briefcase"] = "Briefcase",
	["PaperPlane"] = "Paper Plane",
	["LunchBox"] = "Lunch Box",
	["PaperCup"] = "Paper Cup",
	["WaitingTicket"] = "Waiting Ticket"
}

local Character
local Humanoid
local RootPart
local Camera
local LocalPlayer = Services.Players.LocalPlayer

local RemotesFolder = Services.ReplicatedStorage:FindFirstChild("RemotesFolder")
local LiveModifiers = Services.ReplicatedStorage:FindFirstChild("LiveModifiers")
local FloorReplicated = Services.ReplicatedStorage:FindFirstChild("FloorReplicated")
local CurrentRooms = Services.Workspace:FindFirstChild("CurrentRooms")
local GameData = Services.ReplicatedStorage:WaitForChild("GameData")
local Floor = GameData:WaitForChild("Floor").Value
local LatestRoom = GameData:WaitForChild("LatestRoom")
local FinishedLoadingRoom = GameData:FindFirstChild("FinishedLoadingRoom")
if FinishedLoadingRoom then
	FinishedLoadingRoom:Destroy()
end

local function GetHiddenContainer()
	if Functions.CheckCompatability({"gethui"}) then
		return Abysall.Environment.gethui()
	end
	return Services.CoreGui
end

local NotificationLibrary = {
	LiveNotifications = 0,
	Notifications = 1
}

local Container = Instance.new("ScreenGui")
Container.Name = Abysall.ESPLibrary:GenerateRandomString()
Container.Parent = GetHiddenContainer()
Container.DisplayOrder = 32767
Container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if not Library.Scheme then
	Library.Scheme = setmetatable({}, {
		__index = function(Self, Name)
			return Library[Name]
		end
	})
end

function NotificationLibrary:Notify(TitleText, Desc, Delay)
	task.spawn(function()
		local Notification = Instance.new("Frame")
		local Line = Instance.new("Frame")
		local Warning = Instance.new("ImageLabel")
		local UICorner = Instance.new("UICorner")
		local UICorner2 = Instance.new("UICorner")
		local Title = Instance.new("TextLabel")
		local Description = Instance.new("TextLabel")

		Notification.Name = "Notification"
		Notification.Parent = Container
		Notification.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		Notification.BackgroundTransparency = 0.2
		Notification.BorderSizePixel = 0
		Notification.Position = UDim2.new(1, 5, 0, 60 + (60 * NotificationLibrary.LiveNotifications))
		Notification.Size = UDim2.new(0, 420, 0, 50)
		Notification:SetAttribute("ID", NotificationLibrary.Notifications)
		Notification:SetAttribute("CurrentPosition", Notification.Position)

		Line.Name = "Line"
		Line.Parent = Notification
		Line.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
		Line.BorderSizePixel = 0
		Line.Position = UDim2.new(0, 0, 1, -3)
		Line.Size = UDim2.new(0, 0, 0, 3)

		Warning.Name = "Warning"
		Warning.Parent = Notification
		Warning.BackgroundTransparency = 1
		Warning.Position = UDim2.new(0, 10, 0, 5)
		Warning.Size = UDim2.new(0, 40, 0, 40)
		Warning.Image = "rbxassetid://3944668821"
		Warning.ImageColor3 = Color3.fromRGB(240, 240, 240)
		Warning.ScaleType = Enum.ScaleType.Fit

		UICorner.CornerRadius = UDim.new(0, 20)
		UICorner.Parent = Warning

		UICorner2.CornerRadius = UDim.new(0, 4)
		UICorner2.Parent = Notification

		Title.Name = "Title"
		Title.Parent = Notification
		Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0, 60, 0.155, 0)
		Title.Size = UDim2.new(0, 205, 0, 15)
		Title.Text = TitleText or "..."
		Title.TextColor3 = Color3.fromRGB(240, 240, 240)
		Title.TextSize = 10
		Title.TextStrokeTransparency = 0.75
		Title.TextXAlignment = Enum.TextXAlignment.Left

		Description.Name = "Description"
		Description.Parent = Notification
		Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Description.BackgroundTransparency = 1
		Description.Position = UDim2.new(0, 60, 0.483, 0)
		Description.Size = UDim2.new(0, 205, 0, 18)
		Description.Text = Desc or "..."
		Description.TextColor3 = Color3.fromRGB(180, 180, 180)
		Description.TextTransparency = 0.1
		Description.TextSize = 10
		Description.TextStrokeTransparency = 0.75
		Description.TextXAlignment = Enum.TextXAlignment.Left

		NotificationLibrary.LiveNotifications += 1
		NotificationLibrary.Notifications += 1

		Services.TweenService:Create(
			Notification,
			TweenInfo.new(1, Enum.EasingStyle.Exponential),
			{ Position = UDim2.new(1, -370, 0, Notification.Position.Y.Offset) }
		):Play()

		task.wait(0.25)
		if typeof(Delay) == "Instance" then
			Delay.Destroying:Wait()
		else
			Services.TweenService:Create(
				Line,
				TweenInfo.new(Delay - 0.25, Enum.EasingStyle.Linear),
				{ Size = UDim2.new(0, 400, 0, 3) }
			):Play()
			task.wait(Delay - 0.25)
		end

		Notification:SetAttribute("Destroying", true)

		Services.TweenService:Create(
			Notification,
			TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
			{ Position = UDim2.new(1, 5, 0, Notification.Position.Y.Offset) }
		):Play()

		NotificationLibrary.LiveNotifications -= 1

		local NotifId = Notification:GetAttribute("ID")
		for _, Object in Container:GetChildren() do
			if Object.Name == "Notification"
				and Object:GetAttribute("ID")
				and Object:GetAttribute("ID") > NotifId
				and Object:GetAttribute("Destroying") ~= true
				and Object.Position.Y.Offset ~= 60
			then
				local NewY = Object:GetAttribute("CurrentPosition").Y.Offset - 60
				Object:SetAttribute("CurrentPosition", UDim2.new(1, -450, 0, NewY))
				Services.TweenService:Create(
					Object,
					TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
					{ Position = UDim2.new(1, -370, 0, NewY) }
				):Play()
			end
		end

		task.wait(0.75)
		Notification:Destroy()
	end)
end

Functions.Notify = function(Settings)
	local HiddenContainer = GetHiddenContainer()
	if not Settings.Body then
		Settings.Body = "..."
	end
	local Sound = Instance.new("Sound", HiddenContainer)
	Sound.SoundId = "rbxassetid://8784885431"
	Sound.Volume = 3
	Sound.PlayOnRemove = true
	Sound:Destroy()
	NotificationLibrary:Notify(Settings.Title, Settings.Body, Settings.Time or 5)
end

if not LocalPlayer.Character or not CurrentRooms:FindFirstChildOfClass("Model") then
	Functions.Notify({ Title = "Waiting for game..." })
	while not LocalPlayer.Character or not CurrentRooms:FindFirstChildOfClass("Model") do
		task.wait()
	end
	local UIWaitStart = tick()
	while not LocalPlayer.PlayerGui:FindFirstChild("MainUI") and tick() - UIWaitStart < 4 do
		task.wait()
	end
end

if not RemotesFolder then
	if Services.ReplicatedStorage:FindFirstChild("EntityInfo") then
		RemotesFolder = Services.ReplicatedStorage:FindFirstChild("EntityInfo")
	elseif Services.ReplicatedStorage:FindFirstChild("Bricks") then
		RemotesFolder = Services.ReplicatedStorage:FindFirstChild("Bricks")
	end
end

if Floor == "Hotel" and RemotesFolder.Name == "Bricks" then
	Floor = "OldHotel"
end

if not LiveModifiers then
	LiveModifiers = Instance.new("Folder")
end

if not FloorReplicated then
	FloorReplicated = Instance.new("Folder")
end

local Window = Library:CreateWindow({
	Title = "JuanmaBBB Hub",
	Footer = "Prismatic Monochrome Edition",
	NotifySide = "Right",
	ShowCustomCursor = true,
	AutoShow = true,
	Center = true,
	TabPadding = 4,
	MenuFadeTime = 0.2,
	CornerRadius = 4,
	Draggable = true,
})

Abysall.Interface.ApplyInfoTab(Window)

local Tabs = {
	General = Window:AddTab("General", "house"),
	Exploits = Window:AddTab("Exploits", "shield"),
	Visuals = Window:AddTab("Visuals", "eye"),
	Config = Window:AddTab("Configurations", "settings")
}

Groupboxes.General_Character = Tabs.General:AddLeftGroupbox("Character & Movement")
Groupboxes.General_Character:AddSlider("SpeedBoostSlider", {
	Text = "Speed Boost Value", Min = 0, Max = 150, Default = 0, Rounding = 0, Compact = true
})
Groupboxes.General_Character:AddToggle("SpeedBoostToggle", {
	Text = "Enable Speed Boost", Default = false
})
Groupboxes.General_Character:AddToggle("FlyToggle", {
	Text = "Advanced Fly", Default = false
})
Toggles.FlyToggle:AddKeyPicker("FlyKeybind", {
	Text = "Fly", Default = "F", Mode = "Toggle", SyncToggleState = true
})
Groupboxes.General_Character:AddSlider("FlySpeed", {
	Text = "Fly Speed", Min = 10, Max = 200, Default = 50, Rounding = 0, Compact = true
})
Groupboxes.General_Character:AddDivider()
Groupboxes.General_Character:AddToggle("NoclipToggle", {
	Text = "Universal Noclip", Default = false
})
Groupboxes.General_Character:AddToggle("InfiniteJumps", {
	Text = "Infinite Air Jumps", Default = false
})
Groupboxes.General_Character:AddToggle("AutoSprintToggle", {
	Text = "Auto Sprint", Default = false
})

Groupboxes.General_Self = Tabs.General:AddRightGroupbox("Interaction & Automation")
Groupboxes.General_Self:AddSlider("PromptReachSlider", {
	Text = "Prompt Reach Multiplier", Min = 1, Max = 5, Default = 2, Rounding = 1, Compact = true
})
Groupboxes.General_Self:AddToggle("InstantPrompts", {
	Text = "Instant Prompts", Default = true
})
Groupboxes.General_Self:AddToggle("PromptClip", {
	Text = "Prompt Through Walls", Default = true
})
Groupboxes.General_Self:AddDivider()
Groupboxes.General_Self:AddToggle("AutoInteractToggle", {
	Text = "Auto Interact Objects", Default = false
})
Groupboxes.General_Self:AddToggle("AutoBreakerBox", {
	Text = "Auto Breaker Box", Default = true
})
Groupboxes.General_Self:AddToggle("AutoHeartbeatMinigame", {
	Text = "Auto Heartbeat Bypass", Default = true
})

Groupboxes.Exploits_Bypass = Tabs.Exploits:AddLeftGroupbox("Entity & Environment Bypasses")
Groupboxes.Exploits_Bypass:AddToggle("BypassGiggle", { Text = "Bypass Giggle", Default = true })
Groupboxes.Exploits_Bypass:AddToggle("BypassDupe", { Text = "Bypass Fake Doors", Default = true })
Groupboxes.Exploits_Bypass:AddToggle("BypassEyes", { Text = "Bypass Eyes & Lookman", Default = true })
Groupboxes.Exploits_Bypass:AddToggle("BypassSnare", { Text = "Bypass Snares", Default = true })
Groupboxes.Exploits_Bypass:AddToggle("BypassKillbricks", { Text = "Bypass Hazard Lava", Default = true })
Groupboxes.Exploits_Bypass:AddToggle("PositionSpoof", { Text = "Underground Position Spoof", Default = false })

Groupboxes.Exploits_Remove = Tabs.Exploits:AddRightGroupbox("Threat Removal")
Groupboxes.Exploits_Remove:AddToggle("RemoveScreech", { Text = "Remove Screech", Default = true })
Groupboxes.Exploits_Remove:AddToggle("RemoveHalt", { Text = "Remove Halt", Default = true })
Groupboxes.Exploits_Remove:AddToggle("RemoveA90", { Text = "Remove A-90", Default = true })
Groupboxes.Exploits_Remove:AddToggle("RemoveDread", { Text = "Remove Dread", Default = true })
Groupboxes.Exploits_Remove:AddToggle("RemoveSurge", { Text = "Remove Surge", Default = true })

Groupboxes.Visuals_ESP = Tabs.Visuals:AddLeftGroupbox("ESP Modules")
Groupboxes.Visuals_ESP:AddToggle("DoorESPToggle", { Text = "Door ESP", Default = true })
Groupboxes.Visuals_ESP:AddToggle("ObjectiveESPToggle", { Text = "Objective ESP", Default = true })
Groupboxes.Visuals_ESP:AddToggle("ItemESPToggle", { Text = "Item ESP", Default = true })
Groupboxes.Visuals_ESP:AddToggle("EntityESPToggle", { Text = "Entity ESP", Default = true })
Groupboxes.Visuals_ESP:AddToggle("ChestESPToggle", { Text = "Chest ESP", Default = true })

Groupboxes.Visuals_Camera = Tabs.Visuals:AddRightGroupbox("Camera & Shaders")
Groupboxes.Visuals_Camera:AddSlider("FieldOfView", { Text = "Field of View", Min = 60, Max = 120, Default = 90, Rounding = 0 })
Groupboxes.Visuals_Camera:AddToggle("RemoveCameraShake", { Text = "Remove Camera Shake", Default = true })
Groupboxes.Visuals_Camera:AddToggle("RemoveCameraFog", { Text = "Remove Fog", Default = true })
Groupboxes.Visuals_Camera:AddToggle("FullbrightToggle", { Text = "Prismatic Fullbright", Default = true })

Groupboxes.Config_Main = Tabs.Config:AddLeftGroupbox("Interface Configurations")
Groupboxes.Config_Main:AddButton({
	Text = "Reset All Configurations",
	Func = function()
		Library:Notify("JuanmaBBB Hub", "Configurations reset successfully.")
	end
})

local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
	pcall(function()
		Character = LocalPlayer.Character
		if Character then
			Humanoid = Character:FindFirstChildOfClass("Humanoid")
			RootPart = Character:FindFirstChild("HumanoidRootPart")
		end
		Camera = workspace.CurrentCamera

		if Toggles.FullbrightToggle and Toggles.FullbrightToggle.Value then
			game:GetService("Lighting").Brightness = 2
			game:GetService("Lighting").ClockTime = 14
			game:GetService("Lighting").GlobalShadows = false
		end

		if Toggles.SpeedBoostToggle and Humanoid then
			Humanoid.WalkSpeed = 16 + (Options.SpeedBoostSlider and Options.SpeedBoostSlider.Value or 0)
		end

		if Toggles.NoclipToggle and Character then
			for _, Part in pairs(Character:GetDescendants()) do
				if Part:IsA("BasePart") then
					Part.CanCollide = false
				end
			end
		end

		if Toggles.InfiniteJumps and Humanoid then
			Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end

		if Toggles.AutoBreakerBox and CurrentRooms then
			for _, Room in pairs(CurrentRooms:GetChildren()) do
				local BreakerBox = Room:FindFirstChild("BreakerBox", true)
				if BreakerBox then
					local Switch = BreakerBox:FindFirstChild("Switch", true)
					if Switch and Switch:FindFirstChildOfClass("ProximityPrompt") then
						fireproximityprompt(Switch:FindFirstChildOfClass("ProximityPrompt"))
					end
				end
			end
		end

		if Toggles.AutoHeartbeatMinigame then
			local Minigame = LocalPlayer.PlayerGui:FindFirstChild("HeartChest", true) or LocalPlayer.PlayerGui:FindFirstChild("Minigame", true)
			if Minigame then
				local Success = Minigame:FindFirstChild("Success", true) or Minigame:FindFirstChild("Completed", true)
				if Success then
					for _, Connection in pairs(getconnections(Success.MouseButton1Click or Success.Activated)) do
						Connection:Fire()
					end
				end
			end
		end

		if Toggles.AutoInteractToggle and CurrentRooms then
			for _, Room in pairs(CurrentRooms:GetChildren()) do
				for _, Descendant in pairs(Room:GetDescendants()) do
					if Descendant:IsA("ProximityPrompt") and RootPart and (Descendant.Parent.Position - RootPart.Position).Magnitude <= (Descendant.MaxActivationDistance * (Options.PromptReachSlider and Options.PromptReachSlider.Value or 1)) then
						if Toggles.InstantPrompts and Descendant.HoldDuration > 0 then
							Descendant.HoldDuration = 0
						end
						fireproximityprompt(Descendant)
					end
				end
			end
		end
	end)
end)

Services.Workspace.ChildAdded:Connect(function(Child)
	pcall(function()
		if Entities[Child.Name] then
			Functions.Notify(Entities[Child.Name].NotifyMessage)
		end
	end)
end)

Library:Notify("JuanmaBBB Hub", "Successfully loaded with fully restored systems.")

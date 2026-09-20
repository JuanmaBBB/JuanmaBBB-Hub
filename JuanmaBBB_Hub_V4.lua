--==============================================================
--                 JUANMABBB HUB — DOORS V3
--==============================================================
-- Native, self-contained Roblox GUI / client utility hub.
-- Inspired by the supplied reference feature set, but rewritten
-- around an original UI and feature manager.
--
-- Tabs:
--   General / Exploits / Visuals / Floors / Items / Settings
--
-- The script uses guarded executor APIs when available. Features
-- depending on a specific executor API simply disable themselves
-- when that API is unavailable.
--==============================================================

--==============================================================
-- SERVICES
--==============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local PathfindingService = game:GetService("PathfindingService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

--==============================================================
-- EXECUTOR COMPATIBILITY
--==============================================================

local ENV = {
    fireproximityprompt = fireproximityprompt,
    firetouchinterest = firetouchinterest,
    getconnections = getconnections,
    hookmetamethod = hookmetamethod,
    newcclosure = newcclosure,
    getnamecallmethod = getnamecallmethod,
    replicatesignal = replicatesignal,
    setclipboard = setclipboard,
    toclipboard = toclipboard,
    writefile = writefile,
    readfile = readfile,
    isfile = isfile,
    makefolder = makefolder,
    isfolder = isfolder,
    Drawing = Drawing,
    gethui = gethui,
    cloneref = cloneref,
    getgenv = getgenv,
}

local function has(name)
    return ENV[name] ~= nil
end

local function safe(fn, ...)
    local args = { ... }
    local ok, result = pcall(function()
        return fn(table.unpack(args))
    end)
    if ok then
        return result
    end
end

local function clipboard(text)
    local ok = false
    pcall(function()
        if ENV.setclipboard then
            ENV.setclipboard(text)
            ok = true
        elseif ENV.toclipboard then
            ENV.toclipboard(text)
            ok = true
        end
    end)
    return ok
end

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "JuanmaBBB Hub",
            Text = text or "",
            Duration = duration or 4,
        })
    end)
end

--==============================================================
-- PLAYER / CHARACTER REFERENCES
--==============================================================

local Character
local Humanoid
local RootPart
local Camera

local function updateCharacter()
    Character = LocalPlayer.Character
    if not Character then
        Humanoid = nil
        RootPart = nil
        Camera = Workspace.CurrentCamera
        return
    end
    Humanoid = Character:FindFirstChildOfClass("Humanoid")
    RootPart = Character:FindFirstChild("HumanoidRootPart")
    Camera = Workspace.CurrentCamera
end

updateCharacter()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait()
    pcall(updateCharacter)
end)

--==============================================================
-- GAME REFERENCES
--==============================================================

local CurrentRooms = Workspace:FindFirstChild("CurrentRooms")
local GameData = ReplicatedStorage:FindFirstChild("GameData")
local LatestRoom = GameData and GameData:FindFirstChild("LatestRoom")
local FloorValue = GameData and GameData:FindFirstChild("Floor")
local Floor = FloorValue and tostring(FloorValue.Value) or "Unknown"
local FloorReplicated = ReplicatedStorage:FindFirstChild("FloorReplicated")
local LiveModifiers = ReplicatedStorage:FindFirstChild("LiveModifiers")
local RemotesFolder = ReplicatedStorage:FindFirstChild("RemotesFolder")

local function refreshReferences()
    CurrentRooms = Workspace:FindFirstChild("CurrentRooms") or CurrentRooms
    GameData = ReplicatedStorage:FindFirstChild("GameData") or GameData
    LatestRoom = GameData and GameData:FindFirstChild("LatestRoom") or LatestRoom
    FloorValue = GameData and GameData:FindFirstChild("Floor") or FloorValue
    Floor = FloorValue and tostring(FloorValue.Value) or Floor
    FloorReplicated = ReplicatedStorage:FindFirstChild("FloorReplicated") or FloorReplicated
    LiveModifiers = ReplicatedStorage:FindFirstChild("LiveModifiers") or LiveModifiers
    RemotesFolder = ReplicatedStorage:FindFirstChild("RemotesFolder") or RemotesFolder
end

refreshReferences()

--==============================================================
-- SETTINGS
--==============================================================

local Defaults = {
    -- General / Character
    SpeedBoost = false,
    SpeedBoostAmount = 20,
    Fly = false,
    FlySpeed = 20,
    Noclip = false,
    RemoveClosetDelay = false,
    RemoveAcceleration = false,
    EnableJump = false,
    EnableSlide = false,
    InfiniteJumps = false,
    DoorReach = false,
    PromptReach = 1,
    InstantPrompts = false,
    PromptClip = false,
    DisableIdleKick = false,

    -- Automation
    AutoBreaker = false,
    AutoSolveAnchors = false,
    AutoHeartbeat = false,
    RansomFreeze = false,
    AutoUnlockPadlock = false,
    AutoUnlockDistance = 10,
    AutoLibraryGuess = false,
    AutoInteract = false,
    AutoCloset = false,
    SpectateEntity = false,
    SpectateMode = "Player to Entity",
    AutoOpenDoors = false,
    AutoLoot = false,
    AutoRooms = false,

    -- Exploits / bypass
    BypassGiggle = false,
    BypassDupe = false,
    BypassEyes = false,
    BypassLookman = false,
    BypassGloombatEggs = false,
    BypassSeekObstructions = false,
    BypassVacuum = false,
    BypassKillbricks = false,
    BypassSeekingWall = false,
    BypassSnare = false,
    BypassBanana = false,
    BypassJeff = false,
    BypassDrone = false,
    DisableAnticheat = false,
    VelocityManipulation = false,
    VelocityMode = "Velocity",
    VelocitySpeed = 7,
    AntiTeleport = false,
    AntiTeleportSpeed = 40,
    PositionSpoof = false,
    CrouchSpoof = false,
    InfiniteItems = false,
    InfiniteItemList = "Lockpicks,Skeleton Key,Shears,Multitool",
    RemoveScreech = false,
    RemoveHalt = false,
    RemoveA90 = false,
    RemoveDread = false,
    RemoveSurge = false,
    NoScreechDamage = false,
    NoHaltDamage = false,
    NoA90Damage = false,
    NoSurgeDamage = false,
    RemoveFootsteps = false,
    RemoveJammin = false,
    RemoveInteractSounds = false,

    -- Visuals / camera
    Ambient = false,
    AmbientColor = {255,255,255},
    FOV = 70,
    RemoveCameraShake = false,
    RemoveCameraBobbing = false,
    RemoveCutscenes = false,
    DisableCutscenes = false,
    RemoveFog = false,
    ThirdPerson = false,
    ThirdPersonX = 1.5,
    ThirdPersonY = 1,
    ThirdPersonZ = 5,
    ThirdPersonWallCheck = false,
    ViewmodelOffset = false,
    ViewmodelX = 0,
    ViewmodelY = 0,
    ViewmodelZ = 0,
    TransparentHiding = false,
    HidingTransparency = 0.5,
    DisableGlitchJumpscare = false,
    DisableTimothyJumpscare = false,
    DisableVoidJumpscare = false,
    DisableHideVignette = false,
    DisableFiredamp = false,
    DisableEntityJumpscares = false,

    -- Notifications
    NotifyEntities = false,
    NotifyItems = false,
    NotifyItemsDistance = false,
    NotifyLibraryCode = false,
    NotifyOxygen = false,
    NotifyHasteTime = false,
    NotifyStampedeTime = false,
    NotifyDroneStampede = false,
    StampedeWarning = 10,
    NotifyDroneAtDoor = false,
    DroneDoorDistance = 15,

    -- ESP
    ESPObjectives = false,
    ESPDoors = false,
    ESPHidingSpots = false,
    ESPPlayers = false,
    ESPChests = false,
    ESPItems = false,
    ESPCurrency = false,
    ESPLadders = false,
    ESPEntities = false,
    ESPHoncho = false,
    ESPRainbow = false,
    ESPShowDistance = true,
    ESPFillTransparency = 0.75,
    ESPOutlineTransparency = 0,
    ESPTextTransparency = 0,
    ESPTextOutlineTransparency = 0,
    ESPFadeTime = 0.25,
    ESPRenderLimit = 240,
    ESPTextSize = 16,
    ESPFont = "GothamBold",
    ESPTracers = false,
    ESPTracerOrigin = "Bottom",
    ESPTracerThickness = 0.75,
    ESPArrows = false,
    ESPArrowRadius = 250,
    EntityFilter = "All",

    -- Floors
    AutoSteerMinecart = false,
    MinecartTurnDistance = 30,
    MinecartDuckDistance = 30,
    RoomsPathTimeout = 1,
    RoomsIgnoreA60 = false,
    RoomsShowPath = false,
    RoomsSpoofFootsteps = false,
    SeekPath = false,
    EyestalkPath = false,
    RemoveSeekTrigger = false,
    RemoveFigure = false,
    InfiniteRevives = false,
    FigureGodmode = false,
    RemoveBasementGate = false,
    RemovePaintingsDoor = false,
    RemoveSkeletonDoor = false,
    KnobFarm = false,
    KnobFarmStarted = false,

    -- GUI
    GuiTransparency = 0,
    AccentName = "Blue",
    Keybind = "RightShift",

    -- Items
    GiveItemSelection = "Pocket Mirror",
}

local function cloneValue(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = cloneValue(v)
    end
    return copy
end

local Settings = {}
for k, v in pairs(Defaults) do
    Settings[k] = cloneValue(v)
end

local AccentPresets = {
    Blue = Color3.fromRGB(80,145,255),
    Purple = Color3.fromRGB(140,90,255),
    Green = Color3.fromRGB(80,215,135),
    Red = Color3.fromRGB(235,80,90),
    White = Color3.fromRGB(235,235,235),
    Gold = Color3.fromRGB(245,200,80),
}

local Theme = {
    Background = Color3.fromRGB(22,23,27),
    Header = Color3.fromRGB(30,32,38),
    Sidebar = Color3.fromRGB(18,19,23),
    Card = Color3.fromRGB(31,33,39),
    CardHover = Color3.fromRGB(40,43,51),
    Input = Color3.fromRGB(24,26,31),
    Border = Color3.fromRGB(55,59,70),
    Text = Color3.fromRGB(238,240,245),
    TextDim = Color3.fromRGB(165,170,181),
    TextMute = Color3.fromRGB(112,118,130),
    Red = Color3.fromRGB(235,80,90),
    Green = Color3.fromRGB(80,215,135),
    Yellow = Color3.fromRGB(245,200,80),
    Cyan = Color3.fromRGB(70,210,240),
}

local function Accent()
    return AccentPresets[Settings.AccentName] or AccentPresets.Blue
end

--==============================================================
-- ORIGINAL GAME STATE
--==============================================================

local Original = {
    Lighting = {
        Ambient = Lighting.Ambient,
        Brightness = Lighting.Brightness,
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        ClockTime = Lighting.ClockTime,
    },
    FOV = Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView or 70,
    ZoomMin = LocalPlayer.CameraMinZoomDistance,
    ZoomMax = LocalPlayer.CameraMaxZoomDistance,
}

local OriginalPromptData = setmetatable({}, {__mode = "k"})
local OriginalParts = setmetatable({}, {__mode = "k"})
local OriginalPhysics = setmetatable({}, {__mode = "k"})
local OriginalInstanceParents = setmetatable({}, {__mode = "k"})

--==============================================================
-- WORLD OBJECT CACHE
--==============================================================

local Objects = {
    Prompts = {},
    Doors = {},
    Objectives = {},
    HidingSpots = {},
    Entities = {},
    Items = {},
    Chests = {},
    Currency = {},
    Ladders = {},
    Obstructions = {},
    SeekObstructions = {},
    PathNodes = {},
    Honcho = {},
}

local EntityAliases = {
    RushMoving="Rush", AmbushMoving="Ambush", Eyes="Eyes", Lookman="Lookman",
    BackdoorRush="Blitz", BackdoorLookman="Lookman", Halt="Halt", A60="A-60", A120="A-120",
    GloombatSwarm="Gloombat Swarm", GlitchRush="RNIUSHCG==", GlitchAmbush="AR0xMBUSH",
    JeffTheKiller="Jeff the Killer", Groundskeeper="Groundskeeper", SallyMoving="Sally",
    MonumentEntity="Monument", Caws="Caws", Caw="Caws", Grampy="Grampy",
    Honcho="Honcho", Bash="Bash", BashMoving="Bash", Ransom="Ransom", Scribbles="Scribbles",
    ScribblesMoving="Scribbles", Drone="Drone", DroneMoving="Drone", Alma="Alma", Fih="Fih",
    Teller="Teller", Portrait="Portrait", ["Forget-Me-Not"]="Forget-Me-Not", ForgetMeNot="Forget-Me-Not",
    Creak="Creak", Creek="Creak", Noise="Noise", Stem="Stem", Meld="Meld", Cobbler="Cobbler",
    GrumbleRig="Grumble", Bramble="Bramble", LiveEntityBramble="Bramble", Figure="Figure",
    FigureRig="Figure", FigureRagdoll="Figure", GiggleCeiling="Giggle", Snare="Snare",
    BananaPeel="Banana", DoorFake="Dupe", FakeDoor="Dupe", ScaryWall="Seeking Wall",
}

local HidingLabels = {
    Wardrobe="Closet", Backdoor_Wardrobe="Closet", Toolshed="Closet", RetroWardrobe="Closet",
    ["Wardrobe-FOOLS26"]="Closet", Locker_Large="Locker", Rooms_Locker="Locker",
    Rooms_Locker_Fridge="Locker", Bed="Bed", Double_Bed="Double Bed", CircularVent="Vent", Dumpster="Dumpster",
}

local ChestLabels = {
    ChestBox="Chest", ChestBoxLocked="Locked Chest", Toolbox="Toolbox", Toolbox_Locked="Locked Toolbox",
    Chest_Vine="Vine Chest", Toolshed_Small="Toolshed", Locker_Small_Locked="Locked Item Locker", MouseHole="Mouse Hole",
}

local ItemAliases = {
    Lighter="Lighter", Flashlight="Flashlight", Lockpick="Lockpicks", Vitamins="Vitamins", Bandage="Bandage",
    StarVial="Starlight Vial", StarBottle="Starlight Bottle", StarJug="Starlight Barrel", Shakelight="Gummy Flashlight",
    Straplight="Straplight", Bulklight="Spotlight", Battery="Battery", Candle="Candle", Crucifix="Crucifix",
    CrucifixWall="Crucifix", Glowsticks="Glowstick", SkeletonKey="Skeleton Key", Candy="Candy",
    ShieldMini="Mini Shield Potion", ShieldBig="Big Shield Potion", BandagePack="Bandage Pack", BatteryPack="Battery Pack",
    RiftCandle="Moonlight Candle", LaserPointer="Laser Pointer", HolyGrenade="Holy Hand Grenade", Shears="Shears",
    Smoothie="Smoothie", Cheese="Cheese", Bread="Bread", AlarmClock="Alarm Clock", RiftSmoothie="Moonlight Smoothie",
    GweenSoda="Gween Soda", GlitchCube="Glitch Fragment", Scanner="Tablet", Bomb="Bomb", Knockbomb="Knockbomb",
    Nanner="Nanner", BigBomb="Big Bomb", SnakeBox="Hiding Box", GoldGun="Golden Gun", StopSign="Stop Sign", TipJar="Tip Jar",
    HoneyPot="Honey Pot", Lantern="Lantern", IronKey="Iron Key", LotusPetal="Lotus Petal", Compass="Compass", Multitool="Multitool",
    RiftJar="Rift Jar", AloeVera="Aloe Vera", Donut="Donut", Lotus="Lotus", BoxingGloves="Boxing Gloves", FihFlakes="FihFlakes",
    Fihflakes="FihFlakes", Leftovers="Leftovers", Pizza="Pizza", Briefcase="Briefcase", PaperPlane="Paper Plane",
    LunchBox="Lunch Box", Lunch_Box="Lunch Box", PaperCup="Paper Cup", ["Paper Cup"]="Paper Cup", WaitingTicket="Waiting Ticket",
    ["Waiting Ticket"]="Waiting Ticket", PocketMirror="Pocket Mirror",
}

local function addCached(t, object)
    for _, v in ipairs(t) do
        if v == object then return end
    end
    table.insert(t, object)
end

local function removeCached(t, object)
    for i = #t, 1, -1 do
        if t[i] == object then
            table.remove(t, i)
            return
        end
    end
end

local function cacheObject(object)
    local name = object.Name

    if object:IsA("ProximityPrompt") and not object:GetAttribute("JuanmaFakePrompt") then
        addCached(Objects.Prompts, object)
        if not OriginalPromptData[object] then
            OriginalPromptData[object] = {
                HoldDuration = object.HoldDuration,
                RequiresLineOfSight = object.RequiresLineOfSight,
                MaxActivationDistance = object.MaxActivationDistance,
            }
        end
    end

    if name == "Door" then addCached(Objects.Doors, object) end
    if name == "MinesAnchor" or name == "WaterPump" or name == "RippleExitDoor" or name == "ElevatorBreaker" then
        addCached(Objects.Objectives, object)
    end

    if HidingLabels[name] or name:find("HidingSpot") then
        addCached(Objects.HidingSpots, object)
    end

    if EntityAliases[name] then addCached(Objects.Entities, object) end

    if ItemAliases[name] or name == "Green_Herb" then
        addCached(Objects.Items, object)
    end

    if ChestLabels[name] then addCached(Objects.Chests, object) end

    if name == "GoldPile" or name == "StardustPickup" then
        addCached(Objects.Currency, object)
    end

    if name == "Ladder" or name == "LadderPrompt" or name == "LadderModel" then
        addCached(Objects.Ladders, object)
    end

    if name == "Lava" or name == "ScaryWall" or name == "ThingToOpen" or name == "MovingDoor" or name == "Wax_Door" then
        addCached(Objects.Obstructions, object)
    end

    if name == "SeekFloodline" or name == "SeekBridge" or name == "SeekingWall" then
        addCached(Objects.SeekObstructions, object)
    end

    if name == "ArchivesStorageBox" or name == "ArchivesPackageDeposit" then
        addCached(Objects.Honcho, object)
    end
end

local function uncacheObject(object)
    removeCached(Objects.Prompts, object)
    removeCached(Objects.Doors, object)
    removeCached(Objects.Objectives, object)
    removeCached(Objects.HidingSpots, object)
    removeCached(Objects.Entities, object)
    removeCached(Objects.Items, object)
    removeCached(Objects.Chests, object)
    removeCached(Objects.Currency, object)
    removeCached(Objects.Ladders, object)
    removeCached(Objects.Obstructions, object)
    removeCached(Objects.SeekObstructions, object)
    removeCached(Objects.Honcho, object)
end

for _, service in ipairs({Workspace, ReplicatedStorage}) do
    for _, object in ipairs(service:GetDescendants()) do
        pcall(cacheObject, object)
    end
end

Workspace.DescendantAdded:Connect(function(object)
    task.defer(function()
        pcall(cacheObject, object)
    end)
end)

Workspace.DescendantRemoving:Connect(function(object)
    pcall(uncacheObject, object)
end)

--==============================================================
-- CUSTOM NOTIFICATION LAYER
--==============================================================

local NotificationGui = Instance.new("ScreenGui")
NotificationGui.Name = "JuanmaBBB_Notifications"
NotificationGui.ResetOnSpawn = false
NotificationGui.IgnoreGuiInset = true
NotificationGui.DisplayOrder = 1000001
NotificationGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local NotificationHolder = Instance.new("Frame")
NotificationHolder.Size = UDim2.new(0, 360, 1, -30)
NotificationHolder.Position = UDim2.new(1, -375, 0, 15)
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.Parent = NotificationGui

local NotificationLayout = Instance.new("UIListLayout")
NotificationLayout.Padding = UDim.new(0, 8)
NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationLayout.VerticalAlignment = Enum.VerticalAlignment.Top
NotificationLayout.Parent = NotificationHolder

local function hubNotify(title, body, duration, color)
    color = color or Accent()
    duration = duration or 5

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 350, 0, 61)
    card.BackgroundColor3 = Theme.Card
    card.BackgroundTransparency = 0.08
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent = NotificationHolder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Border
    stroke.Thickness = 1
    stroke.Parent = card

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.Parent = card

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -35, 0, 19)
    titleLabel.Position = UDim2.new(0, 16, 0, 7)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = tostring(title)
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = card

    local bodyLabel = Instance.new("TextLabel")
    bodyLabel.Size = UDim2.new(1, -35, 0, 29)
    bodyLabel.Position = UDim2.new(0, 16, 0, 28)
    bodyLabel.BackgroundTransparency = 1
    bodyLabel.Text = tostring(body)
    bodyLabel.TextColor3 = Theme.TextDim
    bodyLabel.TextSize = 11
    bodyLabel.Font = Enum.Font.GothamMedium
    bodyLabel.TextWrapped = true
    bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
    bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
    bodyLabel.Parent = card

    local originalSize = card.Size
    card.Size = UDim2.new(0, 0, 0, 61)
    TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = originalSize}):Play()

    task.delay(duration, function()
        if not card.Parent then return end
        local tween = TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 61)
        })
        tween:Play()
        tween.Completed:Wait()
        card:Destroy()
    end)
end

--==============================================================
-- GUI LIBRARY
--==============================================================

local Library = {
    Tabs = {},
    ActiveTab = nil,
    Components = {},
    Connections = {},
}

function Library:Corner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 9)
    c.Parent = object
    return c
end

function Library:Stroke(object, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.Transparency = 0
    s.Parent = object
    return s
end

function Library:Tween(object, duration, props, style, direction)
    local tween = TweenService:Create(object, TweenInfo.new(duration or 0.15, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

local function setTransparencyRecursive(root, amount)
    amount = math.clamp(amount, 0, 0.8)
    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("Frame") then
            local base = obj:GetAttribute("JBaseTransparency")
            if base == nil then
                obj:SetAttribute("JBaseTransparency", obj.BackgroundTransparency)
                base = obj.BackgroundTransparency
            end
            obj.BackgroundTransparency = math.clamp(base + amount, 0, 1)
        end
    end
end

function Library:ApplyTheme()
    local accent = Accent()
    for _, object in ipairs(self.Components) do
        if object and object.Parent then
        if object:IsA("Frame") and object:GetAttribute("JAccentFrame") then
            object.BackgroundColor3 = accent
        elseif object:IsA("TextButton") and object:GetAttribute("JAccentButton") then
            object.BackgroundColor3 = accent
        elseif object:IsA("UIStroke") and object:GetAttribute("JAccentStroke") then
            object.Color = accent
        end
        end
    end
    setTransparencyRecursive(self.Gui, Settings.GuiTransparency / 100)
end

function Library:MakeDraggable(frame, handle)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local dragInput = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or input ~= dragInput then return end
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end)
end

function Library:CreateWindow()
    local gui = Instance.new("ScreenGui")
    gui.Name = "JuanmaBBB_Hub"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 1000000
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    self.Gui = gui

    local main = Instance.new("Frame")
    main.Name = "MainWindow"
    main.Size = UDim2.new(0, 700, 0, 410)
    main.Position = UDim2.new(0.5, -350, 0.5, -205)
    main.BackgroundColor3 = Theme.Background
    main.BorderSizePixel = 0
    main.Parent = gui
    self.Main = main
    self:Corner(main, 12)
    self:Stroke(main, Theme.Border, 1.2)

    local scale = Instance.new("UIScale")
    scale.Scale = 0.94
    scale.Parent = main
    self.MainScale = scale

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 46)
    header.BackgroundColor3 = Theme.Header
    header.BorderSizePixel = 0
    header.Parent = main
    self:Corner(header, 12)

    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(1, -28, 0, 2)
    accentLine.Position = UDim2.new(0, 14, 0, 0)
    accentLine.BackgroundColor3 = Accent()
    accentLine.BorderSizePixel = 0
    accentLine:SetAttribute("JAccentFrame", true)
    accentLine.Parent = header
    self:Corner(accentLine, 3)
    table.insert(self.Components, accentLine)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 7, 0, 7)
    dot.Position = UDim2.new(0, 14, 0, 10)
    dot.BackgroundColor3 = Accent()
    dot.BorderSizePixel = 0
    dot.Parent = header
    self:Corner(dot, 7)
    table.insert(self.Components, dot)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 240, 0, 22)
    title.Position = UDim2.new(0, 27, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "JuanmaBBB Hub"
    title.TextColor3 = Theme.Text
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0, 260, 0, 14)
    subtitle.Position = UDim2.new(0, 28, 0, 27)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "DOORS V3  •  Client Utility"
    subtitle.TextColor3 = Theme.TextMute
    subtitle.TextSize = 9
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = header

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 125, 0, 18)
    status.Position = UDim2.new(1, -210, 0, 13)
    status.BackgroundTransparency = 1
    status.Text = "●  CONNECTED"
    status.TextColor3 = Theme.Green
    status.TextSize = 9
    status.Font = Enum.Font.GothamBold
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.Parent = header

    local minimize = Instance.new("TextButton")
    minimize.Size = UDim2.new(0, 28, 0, 28)
    minimize.Position = UDim2.new(1, -66, 0, 9)
    minimize.BackgroundColor3 = Theme.Card
    minimize.BorderSizePixel = 0
    minimize.Text = "—"
    minimize.TextColor3 = Theme.TextDim
    minimize.TextSize = 15
    minimize.Font = Enum.Font.GothamBold
    minimize.AutoButtonColor = false
    minimize.Parent = header
    self:Corner(minimize, 7)
    self:Stroke(minimize, Theme.Border, 1)

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 28, 0, 28)
    close.Position = UDim2.new(1, -33, 0, 9)
    close.BackgroundColor3 = Theme.Card
    close.BorderSizePixel = 0
    close.Text = "×"
    close.TextColor3 = Theme.TextDim
    close.TextSize = 17
    close.Font = Enum.Font.GothamBold
    close.AutoButtonColor = false
    close.Parent = header
    self:Corner(close, 7)
    self:Stroke(close, Theme.Border, 1)

    self:MakeDraggable(main, header)

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 132, 1, -56)
    sidebar.Position = UDim2.new(0, 9, 0, 51)
    sidebar.BackgroundColor3 = Theme.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    self.Sidebar = sidebar
    self:Corner(sidebar, 10)
    self:Stroke(sidebar, Theme.Border, 1)

    local sidePad = Instance.new("UIPadding")
    sidePad.PaddingTop = UDim.new(0, 8)
    sidePad.PaddingLeft = UDim.new(0, 6)
    sidePad.PaddingRight = UDim.new(0, 6)
    sidePad.Parent = sidebar

    local sideLayout = Instance.new("UIListLayout")
    sideLayout.Padding = UDim.new(0, 4)
    sideLayout.Parent = sidebar

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -151, 1, -56)
    content.Position = UDim2.new(0, 142, 0, 51)
    content.BackgroundTransparency = 1
    content.Parent = main
    self.Content = content

    local open = true

    local function tweenWindowFade(hidden, duration)
        local objects = {main}
        for _, object in ipairs(main:GetDescendants()) do
            table.insert(objects, object)
        end

        for _, object in ipairs(objects) do
            if object:IsA("UIStroke") then
                local stored = object:GetAttribute("JWindowBase_Transparency")
                if stored == nil then
                    stored = object.Transparency
                    pcall(function() object:SetAttribute("JWindowBase_Transparency", stored) end)
                end
                pcall(function()
                    self:Tween(object, duration, {Transparency = hidden and 1 or stored}, Enum.EasingStyle.Quad, hidden and Enum.EasingDirection.In or Enum.EasingDirection.Out)
                end)
            elseif object:IsA("GuiObject") then
                local bgStored = object:GetAttribute("JWindowBase_BackgroundTransparency")
                if bgStored == nil then
                    bgStored = object.BackgroundTransparency
                    pcall(function() object:SetAttribute("JWindowBase_BackgroundTransparency", bgStored) end)
                end
                pcall(function()
                    self:Tween(object, duration, {BackgroundTransparency = hidden and 1 or bgStored}, Enum.EasingStyle.Quad, hidden and Enum.EasingDirection.In or Enum.EasingDirection.Out)
                end)

                if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                    local stored = object:GetAttribute("JWindowBase_TextTransparency")
                    if stored == nil then
                        stored = object.TextTransparency
                        pcall(function() object:SetAttribute("JWindowBase_TextTransparency", stored) end)
                    end
                    pcall(function()
                        self:Tween(object, duration, {TextTransparency = hidden and 1 or stored}, Enum.EasingStyle.Quad, hidden and Enum.EasingDirection.In or Enum.EasingDirection.Out)
                    end)
                elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
                    local stored = object:GetAttribute("JWindowBase_ImageTransparency")
                    if stored == nil then
                        stored = object.ImageTransparency
                        pcall(function() object:SetAttribute("JWindowBase_ImageTransparency", stored) end)
                    end
                    pcall(function()
                        self:Tween(object, duration, {ImageTransparency = hidden and 1 or stored}, Enum.EasingStyle.Quad, hidden and Enum.EasingDirection.In or Enum.EasingDirection.Out)
                    end)
                end
            end
        end
    end

    local function setVisible(value)
        open = value
        if open then
            main.Visible = true
            scale.Scale = 0.92
            tweenWindowFade(false, 0.18)
            self:Tween(scale, 0.22, {Scale = 1}, Enum.EasingStyle.Quart)
        else
            tweenWindowFade(true, 0.14)
            local tw = self:Tween(scale, 0.16, {Scale = 0.92}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            tw.Completed:Connect(function()
                if not open then main.Visible = false end
            end)
        end
    end

    local function hover(button, normal, highlighted)
        button.AutoButtonColor = false
        local originalSize = button.Size
        button.MouseEnter:Connect(function()
            self:Tween(button, 0.10, {
                BackgroundColor3 = highlighted,
                Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 2, originalSize.Y.Scale, originalSize.Y.Offset + 2)
            }, Enum.EasingStyle.Quad)
        end)
        button.MouseLeave:Connect(function()
            self:Tween(button, 0.10, {
                BackgroundColor3 = normal,
                Size = originalSize
            }, Enum.EasingStyle.Quad)
        end)
    end

    hover(minimize, Theme.Card, Theme.CardHover)
    hover(close, Theme.Card, Theme.CardHover)

    minimize.MouseButton1Click:Connect(function() setVisible(false) end)
    close.MouseButton1Click:Connect(function() setVisible(false) end)
    self.SetVisible = setVisible

    local float = Instance.new("TextButton")
    float.Name = "FloatingToggle"
    float.Size = UDim2.new(0, 46, 0, 46)
    float.Position = UDim2.new(0, 16, 0.5, -23)
    float.BackgroundColor3 = Theme.Sidebar
    float.BorderSizePixel = 0
    float.Text = "J"
    float.TextColor3 = Theme.Text
    float.TextSize = 18
    float.Font = Enum.Font.GothamBold
    float.AutoButtonColor = false
    float.Parent = gui
    self:Corner(float, 12)
    local floatStroke = self:Stroke(float, Accent(), 1.5)
    floatStroke:SetAttribute("JAccentStroke", true)
    table.insert(self.Components, floatStroke)
    self:MakeDraggable(float, float)

    float.MouseEnter:Connect(function()
        self:Tween(float, 0.10, {
            BackgroundColor3 = Theme.CardHover,
            Size = UDim2.new(0, 49, 0, 49)
        })
    end)
    float.MouseLeave:Connect(function()
        self:Tween(float, 0.10, {
            BackgroundColor3 = Theme.Sidebar,
            Size = UDim2.new(0, 46, 0, 46)
        })
    end)

    float.MouseButton1Click:Connect(function()
        open = not open
        setVisible(open)
    end)

    return self
end

function Library:CreateTab(name, icon)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Border
    page.Visible = false
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.Parent = self.Content

    local padding = Instance.new("UIPadding")
    padding.PaddingRight = UDim.new(0,8)
    padding.PaddingBottom = UDim.new(0,10)
    padding.Parent = page

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0,7)
    list.Parent = page
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y + 15)
    end)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1,0,0,37)
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.Text = "  " .. (icon or "•") .. "  " .. name
    button.TextColor3 = Theme.TextDim
    button.TextSize = 12
    button.Font = Enum.Font.GothamMedium
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.AutoButtonColor = false
    button.Parent = self.Sidebar
    self:Corner(button, 8)

    local data = {Name=name, Page=page, Button=button}
    table.insert(self.Tabs, data)

    button.MouseEnter:Connect(function()
        if self.ActiveTab ~= data then
            self:Tween(button, 0.12, {BackgroundColor3 = Theme.CardHover, BackgroundTransparency = 0})
        end
    end)
    button.MouseLeave:Connect(function()
        if self.ActiveTab ~= data then
            self:Tween(button, 0.12, {BackgroundTransparency = 1})
        end
    end)
    button.MouseButton1Click:Connect(function()
        self:SwitchTab(data)
    end)

    return data
end

function Library:SwitchTab(data)
    for _, tab in ipairs(self.Tabs) do
        tab.Page.Visible = false
        tab.Button.BackgroundTransparency = 1
        tab.Button.TextColor3 = Theme.TextDim
    end

    data.Page.Visible = true
    data.Page.Position = UDim2.new(0,10,0,0)
    data.Page.BackgroundTransparency = 1
    self:Tween(data.Page, 0.13, {Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1})
    data.Button.BackgroundTransparency = 0
    data.Button.BackgroundColor3 = Accent()
    data.Button.TextColor3 = Color3.new(1,1,1)
    self.ActiveTab = data
end

function Library:Section(page, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-8,0,25)
    label.BackgroundTransparency = 1
    label.Text = string.upper(text)
    label.TextColor3 = Theme.TextMute
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = page
    return label
end

function Library:Toggle(page, options)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-8,0,44)
    row.BackgroundColor3 = Theme.Card
    row.BorderSizePixel = 0
    row.Parent = page
    self:Corner(row, 9)
    self:Stroke(row, Theme.Border, 1)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-86,1,0)
    label.Position = UDim2.new(0,12,0,0)
    label.BackgroundTransparency = 1
    label.Text = options.Name or "Toggle"
    label.TextColor3 = Theme.Text
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0,38,0,21)
    switch.Position = UDim2.new(1,-50,0.5,-10)
    switch.BackgroundColor3 = Color3.fromRGB(56,59,67)
    switch.BorderSizePixel = 0
    switch.Text = ""
    switch.Parent = row
    self:Corner(switch, 12)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,17,0,17)
    knob.Position = UDim2.new(0,2,0.5,-8)
    knob.BackgroundColor3 = Color3.fromRGB(176,179,188)
    knob.BorderSizePixel = 0
    knob.Parent = switch
    self:Corner(knob, 9)

    local value = options.Default or false
    local function setValue(v, invoke)
        value = v == true
        if value then
            self:Tween(switch, 0.13, {BackgroundColor3 = Accent()})
            self:Tween(knob, 0.16, {Position = UDim2.new(1,-19,0.5,-8), BackgroundColor3 = Color3.new(1,1,1)})
        else
            self:Tween(switch, 0.13, {BackgroundColor3 = Color3.fromRGB(56,59,67)})
            self:Tween(knob, 0.16, {Position = UDim2.new(0,2,0.5,-8), BackgroundColor3 = Color3.fromRGB(176,179,188)})
        end
        if invoke and options.Callback then task.spawn(options.Callback, value) end
    end
    switch.MouseButton1Click:Connect(function() setValue(not value, true) end)
    setValue(value, true)

    local control = {Set=setValue, Get=function() return value end, Row=row}
    return control
end

function Library:Button(page, options)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-8,0,42)
    b.BackgroundColor3 = Accent()
    b:SetAttribute("JAccentButton", true)
    b.BorderSizePixel = 0
    b.Text = options.Name or "Button"
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.Parent = page
    self:Corner(b, 9)
    table.insert(self.Components, b)
    local buttonSize = b.Size
    b.MouseEnter:Connect(function()
        self:Tween(b, 0.10, {
            BackgroundColor3 = Accent():Lerp(Color3.new(1,1,1),0.12),
            Size = UDim2.new(buttonSize.X.Scale, buttonSize.X.Offset + 2, buttonSize.Y.Scale, buttonSize.Y.Offset + 2)
        }, Enum.EasingStyle.Quad)
    end)
    b.MouseLeave:Connect(function()
        self:Tween(b, 0.10, {
            BackgroundColor3 = Accent(),
            Size = buttonSize
        }, Enum.EasingStyle.Quad)
    end)
    b.MouseButton1Click:Connect(function() if options.Callback then task.spawn(options.Callback) end end)
    return b
end

function Library:Slider(page, options)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,-8,0,58)
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.Parent = page
    self:Corner(card, 9)
    self:Stroke(card, Theme.Border, 1)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.65,0,0,21)
    title.Position = UDim2.new(0,12,0,6)
    title.BackgroundTransparency = 1
    title.Text = options.Name or "Slider"
    title.TextColor3 = Theme.Text
    title.TextSize = 12
    title.Font = Enum.Font.GothamMedium
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0,110,0,21)
    valueLabel.Position = UDim2.new(1,-122,0,6)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Theme.TextDim
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = card

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,-24,0,6)
    bar.Position = UDim2.new(0,12,1,-14)
    bar.BackgroundColor3 = Color3.fromRGB(51,54,63)
    bar.BorderSizePixel = 0
    bar.Parent = card
    self:Corner(bar, 6)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = Accent()
    fill.BorderSizePixel = 0
    fill.Parent = bar
    self:Corner(fill, 6)

    local min = options.Min or 0
    local max = options.Max or 100
    local increment = options.Increment or 1
    local value = options.Default
    if value == nil then value = min end

    local dragging = false
    local function round(v)
        return math.floor(v / increment + 0.5) * increment
    end
    local function setValue(v, invoke)
        v = math.clamp(round(v), min, max)
        value = v
        local alpha = (value-min) / math.max(max-min,0.00001)
        fill.Size = UDim2.new(alpha,0,1,0)
        valueLabel.Text = tostring(value) .. (options.Suffix or "")
        if invoke and options.Callback then task.spawn(options.Callback, value) end
    end
    local function fromInput(input)
        local alpha = math.clamp((input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X,1),0,1)
        setValue(min + (max-min)*alpha, true)
    end
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            fromInput(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            fromInput(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    setValue(value, true)
    return {Set=setValue, Get=function() return value end}
end

function Library:Dropdown(page, options)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,-8,0,44)
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.ZIndex = 20
    card.ClipsDescendants = false
    card.Parent = page
    self:Corner(card, 9)
    self:Stroke(card, Theme.Border, 1)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.43,0,1,0)
    title.Position = UDim2.new(0,12,0,0)
    title.BackgroundTransparency = 1
    title.Text = options.Name or "Dropdown"
    title.TextColor3 = Theme.Text
    title.TextSize = 12
    title.Font = Enum.Font.GothamMedium
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 21
    title.Parent = card

    local chosen = options.Default or options.Values[1]
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0,170,0,30)
    button.Position = UDim2.new(1,-182,0.5,-15)
    button.BackgroundColor3 = Theme.Input
    button.BorderSizePixel = 0
    button.Text = tostring(chosen) .. "  ▼"
    button.TextColor3 = Theme.TextDim
    button.TextSize = 11
    button.Font = Enum.Font.GothamBold
    button.ZIndex = 21
    button.Parent = card
    self:Corner(button, 7)

    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0,170,0,0)
    menu.Position = UDim2.new(1,-182,0,47)
    menu.BackgroundColor3 = Theme.Header
    menu.BorderSizePixel = 0
    menu.ZIndex = 100
    menu.Visible = false
    menu.Parent = card
    self:Corner(menu, 7)
    self:Stroke(menu, Theme.Border, 1)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,2)
    layout.Parent = menu

    local function rebuild()
        for _, child in ipairs(menu:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, option in ipairs(options.Values) do
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1,0,0,28)
            b.BackgroundColor3 = Theme.Header
            b.BorderSizePixel = 0
            b.Text = tostring(option)
            b.TextColor3 = Theme.Text
            b.TextSize = 11
            b.Font = Enum.Font.GothamMedium
            b.ZIndex = 101
            b.Parent = menu
            self:Corner(b,5)
            b.MouseEnter:Connect(function() b.BackgroundColor3 = Theme.CardHover end)
            b.MouseLeave:Connect(function() b.BackgroundColor3 = Theme.Header end)
            b.MouseButton1Click:Connect(function()
                chosen = option
                button.Text = tostring(chosen) .. "  ▼"
                menu.Visible = false
                menu.Size = UDim2.new(0,170,0,0)
                if options.Callback then task.spawn(options.Callback, chosen) end
            end)
        end
        menu.Size = UDim2.new(0,170,0,math.min(180,#options.Values*30+5))
    end
    button.MouseButton1Click:Connect(function()
        menu.Visible = not menu.Visible
        if menu.Visible then rebuild() else menu.Size = UDim2.new(0,170,0,0) end
    end)
    return {Set=function(v) chosen=v button.Text=tostring(v).."  ▼" end, Get=function() return chosen end}
end

function Library:Input(page, options)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,-8,0,48)
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.Parent = page
    self:Corner(card,9)
    self:Stroke(card, Theme.Border,1)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.38,0,1,0)
    title.Position = UDim2.new(0,12,0,0)
    title.BackgroundTransparency = 1
    title.Text = options.Name or "Input"
    title.TextColor3 = Theme.Text
    title.TextSize = 12
    title.Font = Enum.Font.GothamMedium
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0,190,0,30)
    box.Position = UDim2.new(1,-202,0.5,-15)
    box.BackgroundColor3 = Theme.Input
    box.BorderSizePixel = 0
    box.Text = tostring(options.Default or "")
    box.PlaceholderText = options.Placeholder or "Enter value..."
    box.PlaceholderColor3 = Theme.TextMute
    box.TextColor3 = Theme.Text
    box.TextSize = 11
    box.Font = Enum.Font.GothamMedium
    box.ClearTextOnFocus = false
    box.Parent = card
    self:Corner(box,7)

    box.FocusLost:Connect(function()
        if options.Callback then task.spawn(options.Callback, box.Text) end
    end)
    return box
end

function Library:Label(page, text, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-8,0,25)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or Theme.TextDim
    l.TextSize = 11
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true
    l.Parent = page
    return l
end

--==============================================================
-- CREATE WINDOW / TABS
--==============================================================

local UI = Library
UI:CreateWindow()

local General = UI:CreateTab("General", "●")
local Exploits = UI:CreateTab("Exploits", "◆")
local Visuals = UI:CreateTab("Visuals", "◉")
local Floors = UI:CreateTab("Floors", "◇")
local ItemsTab = UI:CreateTab("Items", "▣")
local SettingsTab = UI:CreateTab("Settings", "□")
UI:SwitchTab(UI.Tabs[1])

--==============================================================
-- GENERAL TAB
--==============================================================

UI:Section(General, "Character")

UI:Slider(General, {
    Name="Speed Boost", Min=0, Max=100, Increment=1, Default=0, Suffix="",
    Callback=function(v) Settings.SpeedBoostAmount=v end,
})
UI:Toggle(General, {
    Name="Enable Speed Boost", Default=false,
    Callback=function(v) Settings.SpeedBoost=v end,
})
UI:Toggle(General, {
    Name="Fly", Default=false,
    Callback=function(v) Settings.Fly=v end,
})
UI:Slider(General, {
    Name="Fly Speed", Min=0, Max=115, Increment=1, Default=20, Suffix="",
    Callback=function(v) Settings.FlySpeed=v end,
})
UI:Toggle(General, {
    Name="Noclip", Default=false,
    Callback=function(v) Settings.Noclip=v end,
})
UI:Toggle(General, {
    Name="Remove Closet Delay", Default=false,
    Callback=function(v) Settings.RemoveClosetDelay=v end,
})
UI:Toggle(General, {
    Name="Remove Acceleration", Default=false,
    Callback=function(v) Settings.RemoveAcceleration=v end,
})
UI:Toggle(General, {
    Name="Enable Jumping", Default=false,
    Callback=function(v) Settings.EnableJump=v end,
})
UI:Toggle(General, {
    Name="Enable Sliding", Default=false,
    Callback=function(v) Settings.EnableSlide=v end,
})
UI:Toggle(General, {
    Name="Infinite Jumps", Default=false,
    Callback=function(v) Settings.InfiniteJumps=v end,
})

UI:Section(General, "Interaction")
UI:Toggle(General, {
    Name="Door Reach", Default=false,
    Callback=function(v) Settings.DoorReach=v end,
})
UI:Slider(General, {
    Name="Prompt Reach Multiplier", Min=1, Max=2, Increment=0.1, Default=1, Suffix="x",
    Callback=function(v) Settings.PromptReach=v end,
})
UI:Toggle(General, {
    Name="Instant Prompts", Default=false,
    Callback=function(v) Settings.InstantPrompts=v end,
})
UI:Toggle(General, {
    Name="Prompt Clip", Default=false,
    Callback=function(v) Settings.PromptClip=v end,
})
UI:Toggle(General, {
    Name="Disable Idle Kick", Default=false,
    Callback=function(v) Settings.DisableIdleKick=v end,
})

UI:Section(General, "Automation")
UI:Toggle(General, {Name="Auto Open Doors", Default=false, Callback=function(v) Settings.AutoOpenDoors=v end})
UI:Toggle(General, {Name="Auto Loot", Default=false, Callback=function(v) Settings.AutoLoot=v end})
UI:Toggle(General, {Name="Auto Interact", Default=false, Callback=function(v) Settings.AutoInteract=v end})
UI:Toggle(General, {Name="Auto Closet", Default=false, Callback=function(v) Settings.AutoCloset=v end})
UI:Toggle(General, {Name="Auto Rooms", Default=false, Callback=function(v) Settings.AutoRooms=v end})

UI:Section(General, "Special Automation")
UI:Toggle(General, {Name="Auto Breaker Box", Default=false, Callback=function(v) Settings.AutoBreaker=v end})
UI:Toggle(General, {Name="Auto Solve Anchors", Default=false, Callback=function(v) Settings.AutoSolveAnchors=v end})
UI:Toggle(General, {Name="Auto Heartbeat Minigame", Default=false, Callback=function(v) Settings.AutoHeartbeat=v end})
UI:Toggle(General, {Name="Ransom Freeze", Default=false, Callback=function(v) Settings.RansomFreeze=v end})
UI:Toggle(General, {Name="Auto Unlock Padlock", Default=false, Callback=function(v) Settings.AutoUnlockPadlock=v end})
UI:Slider(General, {Name="Padlock Unlock Distance", Min=1, Max=50, Increment=1, Default=10, Callback=function(v) Settings.AutoUnlockDistance=v end})
UI:Toggle(General, {Name="Guess Library Code", Default=false, Callback=function(v) Settings.AutoLibraryGuess=v end})
UI:Dropdown(General, {Name="Spectate Mode", Values={"Player to Entity","Entity to Player"}, Default="Player to Entity", Callback=function(v) Settings.SpectateMode=v end})
UI:Toggle(General, {Name="Spectate Entity", Default=false, Callback=function(v) Settings.SpectateEntity=v end})

UI:Section(General, "Miscellaneous")
UI:Button(General, {Name="Play Again", Callback=function()
    refreshReferences()
    local remote=RemotesFolder and RemotesFolder:FindFirstChild("PlayAgain")
    if remote then safe(function() remote:FireServer() end); hubNotify("Play Again","New run requested.",3) else hubNotify("Play Again","Remote not found.",3,Theme.Red) end
end})
UI:Button(General, {Name="Return to Lobby", Callback=function()
    refreshReferences()
    local remote=RemotesFolder and RemotesFolder:FindFirstChild("Lobby")
    if remote then safe(function() remote:FireServer() end) else hubNotify("Lobby","Lobby remote not found.",3,Theme.Red) end
end})
UI:Button(General, {Name="Revive", Callback=function()
    refreshReferences()
    local remote=RemotesFolder and RemotesFolder:FindFirstChild("Revive")
    if remote then safe(function() remote:FireServer() end) else hubNotify("Revive","Revive remote not found.",3,Theme.Red) end
end})
UI:Button(General, {Name="Reset Character", Callback=function()
    if has("replicatesignal") then
        safe(ENV.replicatesignal, LocalPlayer.Kill)
    elseif Humanoid then
        Humanoid.Health=0
    end
end})

--==============================================================
-- EXPLOITS TAB
--==============================================================

UI:Section(Exploits, "Entity Bypasses")

local bypassEntries = {
    {"Bypass Giggle","BypassGiggle"}, {"Bypass Dupe","BypassDupe"}, {"Bypass Eyes","BypassEyes"},
    {"Bypass Lookman","BypassLookman"}, {"Bypass Gloombat Eggs","BypassGloombatEggs"},
    {"Bypass Seek Obstructions","BypassSeekObstructions"}, {"Bypass Vacuum","BypassVacuum"},
    {"Bypass Killbricks","BypassKillbricks"}, {"Bypass Seeking Wall","BypassSeekingWall"},
    {"Bypass Snare","BypassSnare"}, {"Bypass Banana","BypassBanana"}, {"Bypass Jeff","BypassJeff"},
    {"Bypass Drone","BypassDrone"},
}

for _, entry in ipairs(bypassEntries) do
    UI:Toggle(Exploits, {
        Name=entry[1], Default=false,
        Callback=function(v) Settings[entry[2]]=v end,
    })
end

UI:Section(Exploits, "Movement / Anti-Cheat")
UI:Toggle(Exploits, {Name="Anticheat Bypass", Default=false, Callback=function(v) Settings.DisableAnticheat=v end})
UI:Toggle(Exploits, {Name="Velocity Manipulation", Default=false, Callback=function(v) Settings.VelocityManipulation=v end})
UI:Dropdown(Exploits, {Name="Velocity Method", Values={"Velocity","Pivot"}, Default="Velocity", Callback=function(v) Settings.VelocityMode=v end})
UI:Slider(Exploits, {Name="Manipulation Speed", Min=1, Max=20, Increment=1, Default=7, Callback=function(v) Settings.VelocitySpeed=v end})
UI:Toggle(Exploits, {Name="Anti-Teleport Spoof", Default=false, Callback=function(v) Settings.AntiTeleport=v end})
UI:Slider(Exploits, {Name="Spoof Max Speed", Min=10, Max=200, Increment=1, Default=40, Callback=function(v) Settings.AntiTeleportSpeed=v end})
UI:Toggle(Exploits, {Name="Position Spoof", Default=false, Callback=function(v) Settings.PositionSpoof=v end})
UI:Toggle(Exploits, {Name="Crouch Spoof", Default=false, Callback=function(v) Settings.CrouchSpoof=v end})

UI:Section(Exploits, "Items / Remove")
UI:Toggle(Exploits, {Name="Infinite Items", Default=false, Callback=function(v) Settings.InfiniteItems=v end})
UI:Input(Exploits, {Name="Infinite Item List", Default=Settings.InfiniteItemList, Placeholder="Lockpicks,Skeleton Key,...", Callback=function(v) Settings.InfiniteItemList=v end})
UI:Toggle(Exploits, {Name="Remove Screech", Default=false, Callback=function(v) Settings.RemoveScreech=v end})
UI:Toggle(Exploits, {Name="Remove Halt", Default=false, Callback=function(v) Settings.RemoveHalt=v end})
UI:Toggle(Exploits, {Name="Remove A-90", Default=false, Callback=function(v) Settings.RemoveA90=v end})
UI:Toggle(Exploits, {Name="Remove Dread", Default=false, Callback=function(v) Settings.RemoveDread=v end})
UI:Toggle(Exploits, {Name="Remove Surge", Default=false, Callback=function(v) Settings.RemoveSurge=v end})
UI:Toggle(Exploits, {Name="No Screech Damage", Default=false, Callback=function(v) Settings.NoScreechDamage=v end})
UI:Toggle(Exploits, {Name="No Halt Damage", Default=false, Callback=function(v) Settings.NoHaltDamage=v end})
UI:Toggle(Exploits, {Name="No A-90 Damage", Default=false, Callback=function(v) Settings.NoA90Damage=v end})
UI:Toggle(Exploits, {Name="No Surge Damage", Default=false, Callback=function(v) Settings.NoSurgeDamage=v end})

UI:Section(Exploits, "Audio")
UI:Toggle(Exploits, {Name="Remove Footstep Sounds", Default=false, Callback=function(v) Settings.RemoveFootsteps=v end})
UI:Toggle(Exploits, {Name="Remove Jammin Music", Default=false, Callback=function(v) Settings.RemoveJammin=v end})
UI:Toggle(Exploits, {Name="Remove Interaction Sounds", Default=false, Callback=function(v) Settings.RemoveInteractSounds=v end})

--==============================================================
-- VISUALS TAB
--==============================================================

UI:Section(Visuals, "Camera")
UI:Slider(Visuals, {Name="Field Of View", Min=1, Max=120, Increment=1, Default=70, Callback=function(v) Settings.FOV=v end})
UI:Toggle(Visuals, {Name="Ambient", Default=false, Callback=function(v) Settings.Ambient=v end})
UI:Dropdown(Visuals, {Name="Ambient Preset", Values={"White","Blue","Purple","Green","Red","Gold"}, Default="White", Callback=function(v)
    local c=AccentPresets[v] or Color3.new(1,1,1)
    Settings.AmbientColor={math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255)}
end})
UI:Toggle(Visuals, {Name="Remove Camera Shake", Default=false, Callback=function(v) Settings.RemoveCameraShake=v end})
UI:Toggle(Visuals, {Name="Remove Camera Bobbing", Default=false, Callback=function(v) Settings.RemoveCameraBobbing=v end})
UI:Toggle(Visuals, {Name="Remove Cutscenes", Default=false, Callback=function(v) Settings.RemoveCutscenes=v; Settings.DisableCutscenes=v end})
UI:Toggle(Visuals, {Name="Remove Fog", Default=false, Callback=function(v) Settings.RemoveFog=v end})
UI:Toggle(Visuals, {Name="Third Person", Default=false, Callback=function(v) Settings.ThirdPerson=v end})
UI:Slider(Visuals, {Name="Third Person X", Min=-10, Max=10, Increment=0.1, Default=1.5, Callback=function(v) Settings.ThirdPersonX=v end})
UI:Slider(Visuals, {Name="Third Person Y", Min=-10, Max=10, Increment=0.1, Default=1, Callback=function(v) Settings.ThirdPersonY=v end})
UI:Slider(Visuals, {Name="Third Person Z", Min=-10, Max=10, Increment=0.1, Default=5, Callback=function(v) Settings.ThirdPersonZ=v end})
UI:Toggle(Visuals, {Name="Third Person Wall Check", Default=false, Callback=function(v) Settings.ThirdPersonWallCheck=v end})
UI:Toggle(Visuals, {Name="Viewmodel Offset", Default=false, Callback=function(v) Settings.ViewmodelOffset=v end})
UI:Slider(Visuals, {Name="Viewmodel X", Min=-10, Max=10, Increment=0.1, Default=0, Callback=function(v) Settings.ViewmodelX=v end})
UI:Slider(Visuals, {Name="Viewmodel Y", Min=-10, Max=10, Increment=0.1, Default=0, Callback=function(v) Settings.ViewmodelY=v end})
UI:Slider(Visuals, {Name="Viewmodel Z", Min=-10, Max=10, Increment=0.1, Default=0, Callback=function(v) Settings.ViewmodelZ=v end})

UI:Section(Visuals, "Effects")
UI:Toggle(Visuals, {Name="Transparent Hiding Spots", Default=false, Callback=function(v) Settings.TransparentHiding=v end})
UI:Slider(Visuals, {Name="Hiding Transparency", Min=0, Max=1, Increment=0.05, Default=0.5, Callback=function(v) Settings.HidingTransparency=v end})
UI:Toggle(Visuals, {Name="Disable Glitch Jumpscare", Default=false, Callback=function(v) Settings.DisableGlitchJumpscare=v end})
UI:Toggle(Visuals, {Name="Disable Timothy Jumpscare", Default=false, Callback=function(v) Settings.DisableTimothyJumpscare=v end})
UI:Toggle(Visuals, {Name="Disable Void Jumpscare", Default=false, Callback=function(v) Settings.DisableVoidJumpscare=v end})
UI:Toggle(Visuals, {Name="Disable Hide Vignette", Default=false, Callback=function(v) Settings.DisableHideVignette=v end})
UI:Toggle(Visuals, {Name="Disable Firedamp Effect", Default=false, Callback=function(v) Settings.DisableFiredamp=v end})
UI:Toggle(Visuals, {Name="Disable Entity Jumpscares", Default=false, Callback=function(v) Settings.DisableEntityJumpscares=v end})

UI:Section(Visuals, "ESP")
local espEntries = {
    {"Objectives","ESPObjectives"},{"Doors","ESPDoors"},{"Hiding Spots","ESPHidingSpots"},{"Players","ESPPlayers"},
    {"Chests","ESPChests"},{"Items","ESPItems"},{"Currency","ESPCurrency"},{"Ladders","ESPLadders"},{"Entities","ESPEntities"},{"Honcho Boxes","ESPHoncho"},
}
for _, e in ipairs(espEntries) do
    UI:Toggle(Visuals, {Name=e[1], Default=false, Callback=function(v) Settings[e[2]]=v end})
end
UI:Dropdown(Visuals, {Name="Entity Filter", Values={"All","Rush","Ambush","Eyes","Halt","Blitz","Lookman","A-60","A-120","Sally","Jeff the Killer","Groundskeeper","Monument","Caws","Grampy","Honcho","Bash","Ransom","Scribbles","Drone","Alma","Fih","Teller","Portrait","Forget-Me-Not","Creak","Noise","Stem","Meld","Cobbler","AR0xMBUSH","RNIUSHCG=="}, Default="All", Callback=function(v) Settings.EntityFilter=v end})
UI:Toggle(Visuals, {Name="Rainbow Effect", Default=false, Callback=function(v) Settings.ESPRainbow=v end})
UI:Toggle(Visuals, {Name="Show Distance", Default=true, Callback=function(v) Settings.ESPShowDistance=v end})
UI:Slider(Visuals, {Name="ESP Fill Transparency", Min=0, Max=1, Increment=0.05, Default=0.75, Callback=function(v) Settings.ESPFillTransparency=v end})
UI:Slider(Visuals, {Name="ESP Outline Transparency", Min=0, Max=1, Increment=0.05, Default=0, Callback=function(v) Settings.ESPOutlineTransparency=v end})
UI:Slider(Visuals, {Name="ESP Text Transparency", Min=0, Max=1, Increment=0.05, Default=0, Callback=function(v) Settings.ESPTextTransparency=v end})
UI:Slider(Visuals, {Name="ESP Text Outline", Min=0, Max=1, Increment=0.05, Default=0, Callback=function(v) Settings.ESPTextOutlineTransparency=v end})
UI:Slider(Visuals, {Name="ESP Fade Time", Min=0, Max=1, Increment=0.05, Default=0.25, Callback=function(v) Settings.ESPFadeTime=v end})
UI:Slider(Visuals, {Name="ESP Render Limit", Min=30, Max=240, Increment=1, Default=240, Callback=function(v) Settings.ESPRenderLimit=v end})
UI:Slider(Visuals, {Name="ESP Text Size", Min=12, Max=24, Increment=1, Default=16, Callback=function(v) Settings.ESPTextSize=v end})
UI:Dropdown(Visuals, {Name="ESP Font", Values={"Gotham","GothamMedium","GothamBold","SourceSans","SourceSansBold","Arial","Code","Highway","Arcade","SciFi","BuilderSans","Roboto","RobotoMono"}, Default="GothamBold", Callback=function(v) Settings.ESPFont=v end})
UI:Dropdown(Visuals, {Name="Tracer Origin", Values={"Bottom","Center","Top","Mouse"}, Default="Bottom", Callback=function(v) Settings.ESPTracerOrigin=v end})
UI:Slider(Visuals, {Name="Tracer Thickness", Min=0.5, Max=2, Increment=0.05, Default=0.75, Callback=function(v) Settings.ESPTracerThickness=v end})
UI:Toggle(Visuals, {Name="Enable Tracers", Default=false, Callback=function(v) Settings.ESPTracers=v end})
UI:Slider(Visuals, {Name="Arrow Radius", Min=100, Max=500, Increment=1, Default=250, Callback=function(v) Settings.ESPArrowRadius=v end})
UI:Toggle(Visuals, {Name="Enable Off-Screen Arrows", Default=false, Callback=function(v) Settings.ESPArrows=v end})

UI:Section(Visuals, "Entity Notifications")
UI:Toggle(Visuals, {Name="Notify Entities", Default=false, Callback=function(v) Settings.NotifyEntities=v end})
UI:Toggle(Visuals, {Name="Notify Items", Default=false, Callback=function(v) Settings.NotifyItems=v end})
UI:Toggle(Visuals, {Name="Item Notification Distance", Default=false, Callback=function(v) Settings.NotifyItemsDistance=v end})
UI:Toggle(Visuals, {Name="Notify Library Code", Default=false, Callback=function(v) Settings.NotifyLibraryCode=v end})
UI:Toggle(Visuals, {Name="Notify Oxygen", Default=false, Callback=function(v) Settings.NotifyOxygen=v end})
UI:Toggle(Visuals, {Name="Notify Haste Time", Default=false, Callback=function(v) Settings.NotifyHasteTime=v end})
UI:Toggle(Visuals, {Name="Notify Drone Stampede", Default=false, Callback=function(v) Settings.NotifyDroneStampede=v end})
UI:Toggle(Visuals, {Name="Show Stampede Countdown", Default=false, Callback=function(v) Settings.NotifyStampedeTime=v end})
UI:Slider(Visuals, {Name="Stampede Warning", Min=5, Max=30, Increment=1, Default=10, Callback=function(v) Settings.StampedeWarning=v end})
UI:Toggle(Visuals, {Name="Notify Drone at Door", Default=false, Callback=function(v) Settings.NotifyDroneAtDoor=v end})
UI:Slider(Visuals, {Name="Drone Door Check Distance", Min=5, Max=40, Increment=1, Default=15, Callback=function(v) Settings.DroneDoorDistance=v end})

--==============================================================
-- FLOORS TAB
--==============================================================

UI:Section(Floors, "Floor Detection")
UI:Label(Floors, "Current Floor: " .. tostring(Floor))

UI:Section(Floors, "Mines / Minecart")
UI:Toggle(Floors, {Name="Auto Steer Minecart", Default=false, Callback=function(v) Settings.AutoSteerMinecart=v end})
UI:Slider(Floors, {Name="Minecart Turn Distance", Min=20, Max=40, Increment=1, Default=30, Callback=function(v) Settings.MinecartTurnDistance=v end})
UI:Slider(Floors, {Name="Minecart Crouch Distance", Min=20, Max=40, Increment=1, Default=30, Callback=function(v) Settings.MinecartDuckDistance=v end})

UI:Section(Floors, "Rooms Auto Walk")
UI:Toggle(Floors, {Name="Rooms Auto Walk", Default=false, Callback=function(v) Settings.AutoRooms=v end})
UI:Slider(Floors, {Name="Pathfind Timeout", Min=0.5, Max=3, Increment=0.1, Default=1, Callback=function(v) Settings.RoomsPathTimeout=v end})
UI:Toggle(Floors, {Name="Ignore A-60", Default=false, Callback=function(v) Settings.RoomsIgnoreA60=v end})
UI:Toggle(Floors, {Name="Show Auto Walk Path", Default=false, Callback=function(v) Settings.RoomsShowPath=v end})
UI:Toggle(Floors, {Name="Spoof Footsteps", Default=false, Callback=function(v) Settings.RoomsSpoofFootsteps=v end})

UI:Section(Floors, "Seek / Eyestalk")
UI:Toggle(Floors, {Name="Show Seek Path", Default=false, Callback=function(v) Settings.SeekPath=v end})
UI:Toggle(Floors, {Name="Show Eyestalk Path", Default=false, Callback=function(v) Settings.EyestalkPath=v end})
UI:Toggle(Floors, {Name="Delete Seek Trigger", Default=false, Callback=function(v) Settings.RemoveSeekTrigger=v end})
UI:Toggle(Floors, {Name="Delete Figure", Default=false, Callback=function(v) Settings.RemoveFigure=v end})
UI:Toggle(Floors, {Name="Infinite Revives", Default=false, Callback=function(v) Settings.InfiniteRevives=v end})
UI:Toggle(Floors, {Name="Figure Godmode", Default=false, Callback=function(v) Settings.FigureGodmode=v end})

UI:Section(Floors, "Obstruction Removal")
UI:Toggle(Floors, {Name="Remove Basement Gate", Default=false, Callback=function(v) Settings.RemoveBasementGate=v end})
UI:Toggle(Floors, {Name="Remove Paintings Door", Default=false, Callback=function(v) Settings.RemovePaintingsDoor=v end})
UI:Toggle(Floors, {Name="Remove Skeleton Door", Default=false, Callback=function(v) Settings.RemoveSkeletonDoor=v end})

UI:Section(Floors, "Floor Completion")
UI:Button(Floors, {Name="Auto Complete Dam Seek", Callback=function()
    if Floor ~= "Mines" then hubNotify("Dam Seek","This completion routine expects The Mines.",4,Theme.Red); return end
    local pumps={}
    for _, o in ipairs(Objects.Objectives) do if o.Name=="WaterPump" then table.insert(pumps,o) end end
    if #pumps==0 then hubNotify("Dam Seek","No water pumps were found.",4,Theme.Red); return end
    task.spawn(function()
        hubNotify("Dam Seek","Attempting to complete water pumps...",4,Theme.Cyan)
        for _, pump in ipairs(pumps) do
            if pump.Parent and RootPart then
            local ok,pivot=pcall(function() return pump:GetPivot() end)
            if ok and pivot then
                Character:PivotTo(pivot)
                local prompt=pump:FindFirstChild("ValvePrompt",true)
                if prompt then
                    if has("fireproximityprompt") then safe(ENV.fireproximityprompt,prompt) end
                end
                task.wait(0.2)
            end
            end
        end
        hubNotify("Dam Seek","Pump pass completed.",4,Theme.Green)
    end)
end})
UI:Button(Floors, {Name="Auto Complete Cringle", Callback=function()
    local target=CurrentRooms and CurrentRooms:FindFirstChild("RippleExitDoor",true)
    if target then
        local ok,pivot=pcall(function() return target:GetPivot() end)
        if ok and pivot then Character:PivotTo(pivot) end
    else
        hubNotify("Cringle","RippleExitDoor was not found.",4,Theme.Red)
    end
end})

UI:Section(Floors, "Farming")
UI:Toggle(Floors, {Name="Knob Farm", Default=false, Callback=function(v) Settings.KnobFarm=v end})
UI:Button(Floors, {Name="Start Knob Farm", Callback=function() Settings.KnobFarmStarted=true; hubNotify("Knob Farm","Farm armed. Turn Knob Farm on to continue.",4) end})
--==============================================================
-- ITEMS TAB
--==============================================================

-- Uses the supplied AdminPanelRunCommand pattern.  This tab is
-- intentionally limited to ordinary utility / consumable items.
local SafeGiveItems = {
    ["Pocket Mirror"] = "PocketMirror",
    ["Briefcase"] = "Briefcase",
    ["Starlight Jug"] = "StarJug",
    ["Honey Pot"] = "HoneyPot",
    ["Scanner / Tablet"] = "Scanner",

    ["Lighter"] = "Lighter",
    ["Flashlight"] = "Flashlight",
    ["Lockpicks"] = "Lockpick",
    ["Vitamins"] = "Vitamins",
    ["Bandage"] = "Bandage",
    ["Starlight Vial"] = "StarVial",
    ["Starlight Bottle"] = "StarBottle",
    ["Gummy Flashlight"] = "Shakelight",
    ["Straplight"] = "Straplight",
    ["Spotlight"] = "Bulklight",
    ["Battery"] = "Battery",
    ["Candle"] = "Candle",
    ["Glowstick"] = "Glowsticks",
    ["Skeleton Key"] = "SkeletonKey",
    ["Candy"] = "Candy",
    ["Mini Shield Potion"] = "ShieldMini",
    ["Big Shield Potion"] = "ShieldBig",
    ["Bandage Pack"] = "BandagePack",
    ["Battery Pack"] = "BatteryPack",
    ["Moonlight Candle"] = "RiftCandle",
    ["Laser Pointer"] = "LaserPointer",
    ["Smoothie"] = "Smoothie",
    ["Cheese"] = "Cheese",
    ["Bread"] = "Bread",
    ["Alarm Clock"] = "AlarmClock",
    ["Moonlight Smoothie"] = "RiftSmoothie",
    ["Gween Soda"] = "GweenSoda",
    ["Glitch Fragment"] = "GlitchCube",
    ["Lantern"] = "Lantern",
    ["Iron Key"] = "IronKey",
    ["Lotus Petal"] = "LotusPetal",
    ["Compass"] = "Compass",
    ["Multitool"] = "Multitool",
    ["Rift Jar"] = "RiftJar",
    ["Aloe Vera"] = "AloeVera",
    ["Donut"] = "Donut",
    ["Lotus"] = "Lotus",
    ["FihFlakes"] = "FihFlakes",
    ["Leftovers"] = "Leftovers",
    ["Pizza"] = "Pizza",
    ["Paper Plane"] = "PaperPlane",
    ["Lunch Box"] = "LunchBox",
    ["Paper Cup"] = "PaperCup",
    ["Waiting Ticket"] = "WaitingTicket",
}

local SafeGiveItemNames = {}
for itemName in pairs(SafeGiveItems) do
    table.insert(SafeGiveItemNames, itemName)
end

table.sort(SafeGiveItemNames, function(a, b)
    return a:lower() < b:lower()
end)

local function GiveSafeItem(displayName)
    local internalName = SafeGiveItems[displayName]
    if not internalName then
        hubNotify("Items", "That item is not available in this tab.", 3, Theme.Red)
        return
    end

    refreshReferences()

    local remote = RemotesFolder and RemotesFolder:FindFirstChild("AdminPanelRunCommand")
    if not remote or not remote:IsA("RemoteEvent") then
        hubNotify("Items", "AdminPanelRunCommand was not found.", 4, Theme.Red)
        return
    end

    local ok, err = pcall(function()
        local args = {
            "Give Items",
            {
                Players = {},
                Items = {
                    [internalName] = internalName,
                }
            }
        }
        remote:FireServer(unpack(args))
    end)

    if ok then
        hubNotify("Item Given", displayName .. " requested.", 3, Theme.Green)
    else
        hubNotify("Items", "Give command failed: " .. tostring(err), 4, Theme.Red)
    end
end

UI:Section(ItemsTab, "Item Giver")
UI:Label(ItemsTab, "Choose an ordinary item and send the Give Items command.")

local SelectedGiveItem = Settings.GiveItemSelection
if not SafeGiveItems[SelectedGiveItem] then
    SelectedGiveItem = "Pocket Mirror"
    Settings.GiveItemSelection = SelectedGiveItem
end

UI:Dropdown(ItemsTab, {
    Name = "Select Item",
    Values = SafeGiveItemNames,
    Default = SelectedGiveItem,
    Callback = function(value)
        SelectedGiveItem = value
        Settings.GiveItemSelection = value
    end,
})

UI:Button(ItemsTab, {
    Name = "Give Selected Item",
    Callback = function()
        GiveSafeItem(SelectedGiveItem)
    end,
})

UI:Section(ItemsTab, "Featured Items")
UI:Button(ItemsTab, {
    Name = "Give Pocket Mirror",
    Callback = function()
        GiveSafeItem("Pocket Mirror")
    end,
})
UI:Button(ItemsTab, {
    Name = "Give Briefcase",
    Callback = function()
        GiveSafeItem("Briefcase")
    end,
})
UI:Button(ItemsTab, {
    Name = "Give Starlight Jug",
    Callback = function()
        GiveSafeItem("Starlight Jug")
    end,
})
UI:Button(ItemsTab, {
    Name = "Give Honey Pot",
    Callback = function()
        GiveSafeItem("Honey Pot")
    end,
})
UI:Button(ItemsTab, {
    Name = "Give Scanner / Tablet",
    Callback = function()
        GiveSafeItem("Scanner / Tablet")
    end,
})

UI:Section(ItemsTab, "Utility Items")
UI:Button(ItemsTab, {
    Name = "Give Flashlight",
    Callback = function()
        GiveSafeItem("Flashlight")
    end,
})
UI:Button(ItemsTab, {
    Name = "Give Vitamins",
    Callback = function()
        GiveSafeItem("Vitamins")
    end,
})
UI:Button(ItemsTab, {
    Name = "Give Skeleton Key",
    Callback = function()
        GiveSafeItem("Skeleton Key")
    end,
})
UI:Button(ItemsTab, {
    Name = "Give Compass",
    Callback = function()
        GiveSafeItem("Compass")
    end,
})
UI:Button(ItemsTab, {
    Name = "Give Multitool",
    Callback = function()
        GiveSafeItem("Multitool")
    end,
})

UI:Label(ItemsTab, "Item spawning depends on the game's AdminPanelRunCommand remote and the current internal item name.", Theme.TextMute)

--==============================================================
-- SETTINGS TAB
--==============================================================

UI:Section(SettingsTab, "Interface")
UI:Slider(SettingsTab, {Name="GUI Transparency", Min=0, Max=60, Increment=1, Default=0, Suffix="%", Callback=function(v) Settings.GuiTransparency=v; UI:ApplyTheme() end})
UI:Dropdown(SettingsTab, {Name="Accent Color", Values={"Blue","Purple","Green","Red","White","Gold"}, Default="Blue", Callback=function(v) Settings.AccentName=v; UI:ApplyTheme() end})
UI:Input(SettingsTab, {Name="Toggle Keybind", Default="RightShift", Placeholder="RightShift", Callback=function(v)
    v=tostring(v):gsub("%s+","")
    if Enum.KeyCode[v] then Settings.Keybind=v; hubNotify("Keybind","GUI toggle set to "..v,3,Theme.Green) else hubNotify("Keybind","Unknown KeyCode: "..v,3,Theme.Red) end
end})

UI:Section(SettingsTab, "Compatibility")
UI:Label(SettingsTab, "fireproximityprompt: " .. (has("fireproximityprompt") and "AVAILABLE" or "MISSING"), has("fireproximityprompt") and Theme.Green or Theme.Red)
UI:Label(SettingsTab, "firetouchinterest: " .. (has("firetouchinterest") and "AVAILABLE" or "MISSING"), has("firetouchinterest") and Theme.Green or Theme.Red)
UI:Label(SettingsTab, "hookmetamethod: " .. (has("hookmetamethod") and "AVAILABLE" or "MISSING"), has("hookmetamethod") and Theme.Green or Theme.Red)
UI:Label(SettingsTab, "getconnections: " .. (has("getconnections") and "AVAILABLE" or "MISSING"), has("getconnections") and Theme.Green or Theme.Red)
UI:Label(SettingsTab, "writefile/readfile: " .. (has("writefile") and has("readfile") and "AVAILABLE" or "MISSING"), has("writefile") and has("readfile") and Theme.Green or Theme.Red)

UI:Section(SettingsTab, "Configuration")

local ConfigPath = "JuanmaBBB_Hub_V2.json"

local function makeSerializable()
    local data={}
    for k,v in pairs(Settings) do
        if type(v)=="boolean" or type(v)=="number" or type(v)=="string" then
            data[k]=v
        elseif type(v)=="table" then
            local copy={}
            for a,b in pairs(v) do if type(b)=="boolean" or type(b)=="number" or type(b)=="string" then copy[a]=b end end
            data[k]=copy
        end
    end
    return data
end

UI:Button(SettingsTab, {Name="Save Configuration", Callback=function()
    if not has("writefile") then hubNotify("Configuration","writefile unavailable.",4,Theme.Red); return end
    if has("isfolder") and has("makefolder") and not safe(ENV.isfolder,"JuanmaBBB_Hub") then safe(ENV.makefolder,"JuanmaBBB_Hub") end
    local path = "JuanmaBBB_Hub/"..ConfigPath
    local ok=pcall(function() ENV.writefile(path,HttpService:JSONEncode(makeSerializable())) end)
    if ok then hubNotify("Configuration","Settings saved.",4,Theme.Green) else hubNotify("Configuration","Save failed.",4,Theme.Red) end
end})

UI:Button(SettingsTab, {Name="Load Configuration", Callback=function()
    if not has("readfile") or not has("isfile") then hubNotify("Configuration","readfile/isfile unavailable.",4,Theme.Red); return end
    local path="JuanmaBBB_Hub/"..ConfigPath
    if not safe(ENV.isfile,path) then hubNotify("Configuration","No saved configuration found.",4,Theme.Red); return end
    local ok,data=pcall(function() return HttpService:JSONDecode(ENV.readfile(path)) end)
    if not ok or type(data)~="table" then hubNotify("Configuration","Could not decode configuration.",4,Theme.Red); return end
    for k,v in pairs(data) do if Defaults[k]~=nil then Settings[k]=v end end
    UI:ApplyTheme()
    hubNotify("Configuration","Settings loaded.",4,Theme.Green)
end})

UI:Button(SettingsTab, {Name="Reset Configuration", Callback=function()
    for k,v in pairs(Defaults) do Settings[k]=cloneValue(v) end
    UI:ApplyTheme()
    hubNotify("Configuration","Settings reset to defaults.",4,Theme.Green)
end})

UI:Button(SettingsTab, {Name="Copy Hub Script Name", Callback=function()
    if clipboard("JuanmaBBB Hub") then hubNotify("Clipboard","Copied: JuanmaBBB Hub",3,Theme.Green) else hubNotify("Clipboard","Clipboard API unavailable.",3,Theme.Red) end
end})

--==============================================================
-- COMMON HELPERS
--==============================================================

local function getPosition(object)
    if not object then return nil end
    if object:IsA("BasePart") then return object.Position end
    if object:IsA("Attachment") then return object.WorldPosition end
    if object:IsA("Model") then
        local ok,p=pcall(function() return object:GetPivot().Position end)
        if ok then return p end
    end
    local part=object:FindFirstChildWhichIsA("BasePart",true)
    return part and part.Position
end

local function nearest(list, maxDistance)
    local root=RootPart
    if not root then return nil end
    local best,bestDist=nil,maxDistance or math.huge
    for _,obj in ipairs(list) do
        if obj and obj.Parent then
            local pos=getPosition(obj)
            if pos then
                local d=(pos-root.Position).Magnitude
                if d<bestDist then best=obj;bestDist=d end
            end
        end
    end
    return best,bestDist
end

local function entityActive(alias)
    for _,obj in ipairs(Objects.Entities) do
        if obj and obj.Parent and EntityAliases[obj.Name]==alias then
            return obj
        end
    end
    return nil
end

local function anyRushLike()
    for _, name in ipairs({"RushMoving","AmbushMoving","BackdoorRush","A60","A120","GlitchRush","GlitchAmbush","FrozenAmbush"}) do
        local obj=Workspace:FindFirstChild(name)
        if obj then return obj end
    end
    return nil
end

local function findHideSpot()
    local root=RootPart
    if not root then return nil end
    local best=nil
    local dist=math.huge
    for _,obj in ipairs(Objects.HidingSpots) do
        if obj and obj.Parent then
            local prompt=obj:FindFirstChild("HidePrompt",true)
            local base=obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart",true)) or obj
            if prompt and base and base:IsA("BasePart") then
                local hidden=obj:FindFirstChild("HiddenPlayer",true)
                if not hidden or not hidden.Value then
                    local d=(base.Position-root.Position).Magnitude
                    if d<prompt.MaxActivationDistance and d<dist then dist=d;best=prompt end
                end
            end
        end
    end
    return best
end

local function forcePrompt(prompt)
    if has("fireproximityprompt") then return safe(ENV.fireproximityprompt,prompt) end
end

--==============================================================
-- PROMPT MODIFIER ENGINE
--==============================================================

local function applyPromptSettings(prompt)
    if not prompt or not prompt.Parent then return end
    local old=OriginalPromptData[prompt]
    if not old then
        old={HoldDuration=prompt.HoldDuration,RequiresLineOfSight=prompt.RequiresLineOfSight,MaxActivationDistance=prompt.MaxActivationDistance}
        OriginalPromptData[prompt]=old
    end
    prompt.HoldDuration=Settings.InstantPrompts and 0 or old.HoldDuration
    prompt.RequiresLineOfSight=Settings.PromptClip and false or old.RequiresLineOfSight
    local multiplier=Settings.PromptReach
    if Settings.DoorReach and prompt.Parent and (prompt.Parent.Name=="Door" or prompt.Parent.Parent and prompt.Parent.Parent.Name=="Door") then multiplier=math.max(multiplier,2) end
    prompt.MaxActivationDistance=old.MaxActivationDistance*multiplier
end

local function restorePrompt(prompt)
    local old=OriginalPromptData[prompt]
    if old and prompt and prompt.Parent then
        prompt.HoldDuration=old.HoldDuration
        prompt.RequiresLineOfSight=old.RequiresLineOfSight
        prompt.MaxActivationDistance=old.MaxActivationDistance
    end
end

for _,prompt in ipairs(Objects.Prompts) do applyPromptSettings(prompt) end

ProximityPromptService.PromptShown:Connect(function(prompt)
    task.defer(function() applyPromptSettings(prompt) end)
end)

--==============================================================
-- ESP ENGINE
--==============================================================

local ESP = {}
local TracerObjects = {}
local ArrowObjects = {}

local function getEspColor(category)
    if category=="Entity" then return Color3.fromRGB(255,70,80) end
    if category=="Door" then return Color3.fromRGB(70,210,240) end
    if category=="Objective" then return Color3.fromRGB(80,255,130) end
    if category=="Hiding" then return Color3.fromRGB(255,170,0) end
    if category=="Player" then return Color3.fromRGB(255,255,255) end
    if category=="Chest" then return Color3.fromRGB(245,200,80) end
    if category=="Item" then return Color3.fromRGB(170,0,255) end
    if category=="Currency" then return Color3.fromRGB(255,230,60) end
    if category=="Ladder" then return Color3.fromRGB(220,220,220) end
    if category=="Honcho" then return Color3.fromRGB(70,255,120) end
    return Accent()
end

local function espTargetPart(object)
    if object:IsA("BasePart") then return object end
    if object:IsA("Model") then return object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart",true) end
end

local function destroyESP(object)
    local info=ESP[object]
    if info then
        if info.Highlight then info.Highlight:Destroy() end
        if info.Billboard then info.Billboard:Destroy() end
        ESP[object]=nil
    end
    local tracer=TracerObjects[object]
    if tracer then pcall(function() tracer:Remove() end);TracerObjects[object]=nil end
    local arrow=ArrowObjects[object]
    if arrow then arrow:Destroy();ArrowObjects[object]=nil end
end

local function createESP(object,label,category,color)
    if not object or not object.Parent then return end
    if ESP[object] then return end
    local target=espTargetPart(object)
    if not target then return end
    color=color or getEspColor(category)

    local highlight=Instance.new("Highlight")
    highlight.Name="JuanmaBBB_ESP"
    highlight.Adornee=object:IsA("Model") and object or target
    highlight.FillColor=color
    highlight.FillTransparency=Settings.ESPFillTransparency
    highlight.OutlineColor=color
    highlight.OutlineTransparency=Settings.ESPOutlineTransparency
    highlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent=object:IsA("Model") and object or target

    local billboard=Instance.new("BillboardGui")
    billboard.Name="JuanmaBBB_ESPLabel"
    billboard.Adornee=target
    billboard.Size=UDim2.new(0,190,0,26)
    billboard.StudsOffset=Vector3.new(0,3,0)
    billboard.AlwaysOnTop=true
    billboard.Parent=UI.Gui

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency=1
    lbl.Text=label
    lbl.TextColor3=color
    lbl.TextTransparency=Settings.ESPTextTransparency
    lbl.TextStrokeTransparency=Settings.ESPTextOutlineTransparency
    lbl.TextSize=Settings.ESPTextSize
    lbl.Font=Enum.Font[Settings.ESPFont] or Enum.Font.GothamBold
    lbl.Parent=billboard

    ESP[object]={Highlight=highlight,Billboard=billboard,Label=lbl,Category=category,BaseColor=color}
end

local function makeTracer(object,color)
    if not Settings.ESPTracers or not has("Drawing") or not ENV.Drawing or not ENV.Drawing.new then return end
    if TracerObjects[object] then return end
    local ok,line=pcall(function()
        local l=ENV.Drawing.new("Line")
        l.Visible=false
        l.Color=color
        l.Thickness=Settings.ESPTracerThickness
        l.Transparency=0.95
        return l
    end)
    if ok and line then TracerObjects[object]=line end
end

local function makeArrow(object,color)
    if not Settings.ESPArrows or ArrowObjects[object] then return end
    local target=espTargetPart(object)
    if not target then return end
    local arrow=Instance.new("TextLabel")
    arrow.Name="JuanmaBBB_Arrow"
    arrow.Size=UDim2.new(0,30,0,30)
    arrow.AnchorPoint=Vector2.new(0.5,0.5)
    arrow.BackgroundTransparency=1
    arrow.Text="➤"
    arrow.TextColor3=color
    arrow.TextStrokeTransparency=0
    arrow.TextSize=26
    arrow.Font=Enum.Font.GothamBold
    arrow.Visible=false
    arrow.ZIndex=100
    arrow.Parent=UI.Gui
    ArrowObjects[object]=arrow
end

local function objectEnabled(category, object)
    if category=="Entity" then return Settings.ESPEntities end
    if category=="Door" then return Settings.ESPDoors end
    if category=="Objective" then return Settings.ESPObjectives end
    if category=="Hiding" then return Settings.ESPHidingSpots end
    if category=="Player" then return Settings.ESPPlayers end
    if category=="Chest" then return Settings.ESPChests end
    if category=="Item" then return Settings.ESPItems end
    if category=="Currency" then return Settings.ESPCurrency end
    if category=="Ladder" then return Settings.ESPLadders end
    if category=="Honcho" then return Settings.ESPHoncho end
    return false
end

local function objectLabelCategory(object)
    local name=object.Name
    if object:IsA("Model") then
        for _,player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character == object then
                return player.Name, "Player"
            end
        end
    end
    if EntityAliases[name] then return EntityAliases[name],"Entity" end
    if name=="Door" then return "Door","Door" end
    if name=="MinesAnchor" or name=="WaterPump" or name=="ElevatorBreaker" or name=="RippleExitDoor" then return name,"Objective" end
    if HidingLabels[name] or name:find("HidingSpot") then return HidingLabels[name] or "Hiding Spot","Hiding" end
    if ChestLabels[name] then return ChestLabels[name],"Chest" end
    if ItemAliases[name] then return ItemAliases[name],"Item" end
    if name=="Green_Herb" then return "Green Herb","Item" end
    if name=="GoldPile" then
        local gold=object:GetAttribute("GoldValue")
        return gold and ("Gold Pile ["..tostring(gold).."]") or "Gold Pile","Currency"
    end
    if name=="StardustPickup" then return "Stardust Pile","Currency" end
    if name=="Ladder" or name=="LadderModel" then return "Ladder","Ladder" end
    if name=="ArchivesStorageBox" or name=="ArchivesPackageDeposit" then return name,"Honcho" end
end

local function rebuildESP()
    for object,info in pairs(ESP) do
        if not object or not object.Parent or not objectEnabled(info.Category, object) then
            destroyESP(object)
        end
    end
    local count=0
    local function add(o)
        if count>=Settings.ESPRenderLimit then return end
        local label,category=objectLabelCategory(o)
        if label and category and objectEnabled(category,o) then
            if category=="Entity" and Settings.EntityFilter and Settings.EntityFilter~="All" and label~=Settings.EntityFilter then return end
            local color=getEspColor(category)
            createESP(o,label,category,color)
            if Settings.ESPTracers then makeTracer(o,color) end
            if Settings.ESPArrows then makeArrow(o,color) end
            count = count + 1
        end
    end

    for _,o in ipairs(Objects.Doors) do add(o) end
    for _,o in ipairs(Objects.Objectives) do add(o) end
    for _,o in ipairs(Objects.HidingSpots) do add(o) end
    for _,o in ipairs(Objects.Entities) do add(o) end
    for _,o in ipairs(Objects.Items) do add(o) end
    for _,o in ipairs(Objects.Chests) do add(o) end
    for _,o in ipairs(Objects.Currency) do add(o) end
    for _,o in ipairs(Objects.Ladders) do add(o) end
    for _,o in ipairs(Objects.Honcho) do add(o) end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character and Settings.ESPPlayers then add(p.Character) end
    end
end

--==============================================================
-- ARCHIVES CLOCK / STAMPEDE
--==============================================================

local Stampede = {
    StartTick=tick(),
    LastWarning=0,
    LastSecond=-1,
    LastDoorWarning=nil,
    LastHorde=0,
}

local function isArchives()
    local s=tostring(Floor):lower()
    return s:find("archiv")~=nil
end

local function parseHM(text)
    if type(text)~="string" then return nil end
    local h,m=text:match("(%d+)%s*:%s*(%d+)")
    h=tonumber(h);m=tonumber(m)
    if h and m and h<=23 and m<=59 then return h,m end
end

local function getArchivesClock()
    if not isArchives() then return nil end
    local bestH,bestM
    local function considerText(text)
        local h,m=parseHM(text)
        if h then bestH=h;bestM=m end
    end
    if CurrentRooms then
        for _,room in ipairs(CurrentRooms:GetChildren()) do
            local assets=room:FindFirstChild("Assets")
            local clock=assets and assets:FindFirstChild("ArchivesClock")
            if clock then
                for _,d in ipairs(clock:GetDescendants()) do
                    if d:IsA("TextLabel") or d:IsA("TextButton") then considerText(d.Text) end
                end
                if not bestH then
                    for _,v in ipairs(clock:GetChildren()) do
                        if v:IsA("StringValue") then considerText(v.Value) elseif v:IsA("NumberValue") or v:IsA("IntValue") then
                            if v.Value>24 and v.Value<=1440 then bestH=math.floor(v.Value/60)%24;bestM=math.floor(v.Value%60) end
                        end
                    end
                end
            end
        end
    end
    if bestH then return bestH,bestM end
    return nil
end

local function stampedeCountdown()
    local h,m=getArchivesClock()
    if h then
        local total=(h%12)*60+m
        local a=300
        local b=540
        local target
        if total<a then target=a elseif total<b then target=b else target=a+720 end
        return target-total,target==a and 5 or 9,string.format("%02d:%02d",h,m)
    end
    local elapsed=tick()-Stampede.StartTick
    local cycle=elapsed%720
    if cycle<480 then return 480-cycle,5,nil end
    return 720-cycle,9,nil
end

--==============================================================
-- RANSOM
--==============================================================

local RansomFrozen=false
local RansomUntil=0

local function setRansomFreeze(value)
    if not Humanoid then return end
    if value then
        RansomFrozen=true
        RansomUntil=tick()+90
        Humanoid.WalkSpeed=0
    else
        RansomFrozen=false
        local boost=Settings.SpeedBoost and Settings.SpeedBoostAmount or 0
        local base=16
        pcall(function()
            if Humanoid:GetAttribute("BaseSpeed") then base=Humanoid:GetAttribute("BaseSpeed") end
        end)
        Humanoid.WalkSpeed=base+boost
    end
end

Workspace.ChildAdded:Connect(function(object)
    if object.Name=="Ransom" then
        if Settings.RansomFreeze and isArchives() then
            hubNotify("RANSOM", "Stop moving. 500 gold demanded.", 6, Theme.Red)
            setRansomFreeze(true)
            object.Destroying:Once(function() setRansomFreeze(false) end)
        end
    end
end)

--==============================================================
-- SERVER / WORLD BYPASSES
--==============================================================

local function setTouch(object, enabled)
    if object and object:IsA("BasePart") then object.CanTouch=enabled end
end

local function setCollisionRecursive(object, enabled)
    if not object then return end
    if object:IsA("BasePart") then object.CanCollide=enabled end
    for _,d in ipairs(object:GetDescendants()) do
        if d:IsA("BasePart") then d.CanCollide=enabled end
    end
end

local function applyBypasses()
    for _,obj in ipairs(Objects.Entities) do
        if obj and obj.Parent then
        local n=obj.Name
        if n=="GiggleCeiling" and Settings.BypassGiggle then
            local hit=obj:FindFirstChild("Hitbox",true); if hit and hit:IsA("BasePart") then hit.CanTouch=false end
        end
        if (n=="DoorFake" or n=="FakeDoor") and Settings.BypassDupe then
            local hidden=obj:FindFirstChild("Hidden",true); if hidden and hidden:IsA("BasePart") then hidden.CanTouch=false end
            local unlock=obj:FindFirstChild("UnlockPrompt",true); if unlock and unlock:IsA("ProximityPrompt") then unlock.Enabled=false end
        end
        if n=="Snare" and Settings.BypassSnare then setCollisionRecursive(obj,false); setTouch(obj,false) end
        if n=="BananaPeel" and Settings.BypassBanana then setTouch(obj,false) end
        if n=="JeffTheKiller" and Settings.BypassJeff then setCollisionRecursive(obj,false); setTouch(obj,false) end
        if Settings.BypassGloombatEggs then
            for _,p in ipairs(obj:GetDescendants()) do if p:IsA("BasePart") then p.CanTouch=false end end
        end
    end
    end
    for _,obj in ipairs(Objects.Obstructions) do
        if obj.Parent then
        if obj.Name=="Lava" and Settings.BypassKillbricks then setTouch(obj,false) end
        if obj.Name=="ScaryWall" and Settings.BypassSeekingWall then setCollisionRecursive(obj,false); setTouch(obj,false) end
        end
    end
    for _,obj in ipairs(Objects.SeekObstructions) do
        if Settings.BypassSeekObstructions then
            if obj:IsA("BasePart") then obj.CanTouch=false end
            if obj.Name=="SeekFloodline" and obj:IsA("BasePart") then obj.CanCollide=true end
        end
    end
end

--==============================================================
-- REMOVE / DISABLE ENTITY CLIENT OBJECTS
--==============================================================

local RemoveNames={
    Screech={"Screech","ScreechPart"},
    Halt={"Halt"},
    A90={"A90"},
    Dread={"Dread"},
    Surge={"Surge","SurgeVignette"},
}

local function removeDisabledObjects()
    local checks={
        {Settings.RemoveScreech,RemoveNames.Screech},
        {Settings.RemoveHalt,RemoveNames.Halt},
        {Settings.RemoveA90,RemoveNames.A90},
        {Settings.RemoveDread,RemoveNames.Dread},
        {Settings.RemoveSurge,RemoveNames.Surge},
    }
    for _,pair in ipairs(checks) do
        if pair[1] then
            for _,name in ipairs(pair[2]) do
                local obj=Workspace:FindFirstChild(name,true)
                if obj and (obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("ModuleScript") or obj:IsA("Frame")) then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end
end

--==============================================================
-- AUTO BREAKER / ANCHOR / PADLOCK
--==============================================================

local libraryCodeCache=nil
local libraryGuessUsed={}

local function getLibraryCode()
    local paper=Character and (Character:FindFirstChild("LibraryHintPaper") or Character:FindFirstChild("LibraryHintPaperHard"))
    if not paper and LocalPlayer.Backpack then
        paper=LocalPlayer.Backpack:FindFirstChild("LibraryHintPaper") or LocalPlayer.Backpack:FindFirstChild("LibraryHintPaperHard")
    end
    if not paper then return nil end
    local perm=LocalPlayer.PlayerGui:FindFirstChild("PermUI")
    local hints=perm and perm:FindFirstChild("Hints")
    local ui=paper:FindFirstChild("UI")
    if not hints or not ui then return nil end
    local length=(Floor=="Fools") and 10 or 5
    local code={}
    for i=1,length do code[i]="_" end
    for _,hint in ipairs(hints:GetChildren()) do
        for _,child in ipairs(ui:GetChildren()) do
            if hint:IsA("ImageLabel") and child:IsA("ImageLabel") and hint.ImageRectOffset==child.ImageRectOffset then
                local idx=tonumber(child.Name)
                if idx and code[idx] then
                    local t=hint:FindFirstChild("TextLabel")
                    if t then code[idx]=t.Text end
                end
            end
        end
    end
    libraryCodeCache=table.concat(code)
    return libraryCodeCache
end

local function randomLibraryCode(template)
    if not template then return nil end
    local result=template:gsub("_",function() return tostring(math.random(0,9)) end)
    local tries=0
    while libraryGuessUsed[result] and tries<10 do
        result=template:gsub("_",function() return tostring(math.random(0,9)) end)
        tries = tries + 1
    end
    libraryGuessUsed[result]=true
    return result
end

local function findPadlock()
    return Workspace:FindFirstChild("Padlock",true)
end

local function autoPadlock()
    local padlock=findPadlock()
    if not padlock or not RootPart then return end
    local pos=getPosition(padlock)
    if not pos then return end
    local distance=(pos-RootPart.Position).Magnitude
    if distance>Settings.AutoUnlockDistance then return end
    local code=getLibraryCode()
    local remote=RemotesFolder and RemotesFolder:FindFirstChild("PL")
    if remote and code and not code:find("_") then
        safe(function() remote:FireServer(code) end)
    elseif Settings.AutoLibraryGuess and LatestRoom and LatestRoom.Value==50 and remote then
        local guess=randomLibraryCode(code)
        if guess then safe(function() remote:FireServer(guess) end) end
    end
end

local function autoBreaker()
    if not Settings.AutoBreaker then return end
    local remote=RemotesFolder and RemotesFolder:FindFirstChild("EBF")
    if remote then safe(function() remote:FireServer() end) end
end

local function autoAnchors()
    if not Settings.AutoSolveAnchors then return end
    local codeFrame=LocalPlayer.PlayerGui:FindFirstChild("MainUI",true)
    local text=codeFrame and codeFrame:FindFirstChild("AnchorCode",true)
    local code=text and text:IsA("TextLabel") and text.Text
    if not code then return end
    for _,anchor in ipairs(Objects.Objectives) do
        if anchor.Name=="MinesAnchor" and anchor.Parent then
            local sign=anchor:FindFirstChild("Sign")
            local label=sign and sign:FindFirstChild("TextLabel")
            if label and label.Text==code then
                local prompt=anchor:FindFirstChildWhichIsA("ProximityPrompt",true)
                if prompt then forcePrompt(prompt) end
            end
        end
    end
end

--==============================================================
-- AUTO INTERACT / LOOT / DOORS
--==============================================================

local function promptPosition(prompt)
    if not prompt or not prompt.Parent then return nil end
    return getPosition(prompt.Parent)
end

local function autoInteract()
    if not Settings.AutoInteract or not RootPart then return end
    for _,prompt in ipairs(Objects.Prompts) do
        if prompt and prompt.Parent and prompt.Enabled then
            local pos=promptPosition(prompt)
            if pos and (pos-RootPart.Position).Magnitude<=prompt.MaxActivationDistance then
                forcePrompt(prompt)
            end
        end
    end
end

local InfiniteItemNames = {
    Lockpick=true, Lockpicks=true, SkeletonKey=true, Shears=true, Multitool=true,
}

local function maintainInfiniteItems()
    if not Settings.InfiniteItems then return end
    for _,container in ipairs({Character, LocalPlayer.Backpack}) do
        if container then
            for _,tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") and InfiniteItemNames[tool.Name] then
                    if tool:GetAttribute("JuanmaBBB_OriginalUses") == nil then
                        local uses=tool:GetAttribute("Uses")
                        if uses ~= nil then tool:SetAttribute("JuanmaBBB_OriginalUses", uses) end
                    end
                    local original=tool:GetAttribute("JuanmaBBB_OriginalUses")
                    if original ~= nil and tool:GetAttribute("Uses") ~= original then
                        pcall(function() tool:SetAttribute("Uses", original) end)
                    end
                end
            end
        end
    end
end

local function autoLoot()
    if not Settings.AutoLoot or not RootPart then return end
    for _,prompt in ipairs(Objects.Prompts) do
        if prompt and prompt.Parent then
            local p=prompt.Parent.Name:lower()
            if p:find("gold") or p:find("key") or p:find("drawer") or p:find("book") or p:find("battery") then
                local pos=promptPosition(prompt)
                if pos and (pos-RootPart.Position).Magnitude<=prompt.MaxActivationDistance then forcePrompt(prompt) end
            end
        end
    end
end

local function autoOpenDoors()
    if not Settings.AutoOpenDoors or not RootPart then return end
    for _,door in ipairs(Objects.Doors) do
        if door and door.Parent then
            local pos=getPosition(door)
            if pos and (pos-RootPart.Position).Magnitude<14 then
                local prompt=door:FindFirstChildWhichIsA("ProximityPrompt",true)
                if prompt then forcePrompt(prompt) end
            end
        end
    end
end

--==============================================================
-- FLY / MOVEMENT
--==============================================================

local function flyVelocity()
    if not Camera or not Humanoid then return Vector3.zero end
    if Humanoid.MoveDirection==Vector3.zero then return Vector3.zero end
    local flat=Vector3.new(Camera.CFrame.LookVector.X,0,Camera.CFrame.LookVector.Z)
    if flat.Magnitude<0.001 then return Vector3.zero end
    local frame=CFrame.new(Camera.CFrame.Position,Camera.CFrame.Position+flat.Unit)
    local transformed=(frame*CFrame.new(frame:VectorToObjectSpace(Humanoid.MoveDirection))).Position-Camera.CFrame.Position
    return transformed.Magnitude>0 and transformed.Unit or Vector3.zero
end

local function applyCharacterAttributes()
    if not Character then return end
    pcall(function() Character:SetAttribute("CanJump",Settings.EnableJump or Character:GetAttribute("CanJump")) end)
    pcall(function() Character:SetAttribute("CanSlide",Settings.EnableSlide or Character:GetAttribute("CanSlide")) end)
end

--==============================================================
-- AUTO CLOSET
--==============================================================

local InCloset=false

local function autoCloset()
    if not Settings.AutoCloset or InCloset or not RootPart then return end
    local danger=anyRushLike()
    if not danger then return end
    local prompt=findHideSpot()
    if prompt then
        InCloset=true
        forcePrompt(prompt)
        task.spawn(function()
            repeat task.wait(0.15) until not anyRushLike() or not Settings.AutoCloset
            if RemotesFolder then
                local camLock=RemotesFolder:FindFirstChild("CamLock")
                if camLock then safe(function() camLock:FireServer() end) end
            end
            InCloset=false
        end)
    end
end

--==============================================================
-- THIRD PERSON
--==============================================================

local function updateThirdPerson()
    if not Settings.ThirdPerson then
        LocalPlayer.CameraMinZoomDistance=Original.ZoomMin
        LocalPlayer.CameraMaxZoomDistance=Original.ZoomMax
        return
    end
    LocalPlayer.CameraMinZoomDistance=Settings.ThirdPersonZ
    LocalPlayer.CameraMaxZoomDistance=Settings.ThirdPersonZ
end

--==============================================================
-- PLAYER / ENTITY NOTIFICATIONS
--==============================================================

local KnownEntities=setmetatable({}, {__mode="k"})
local KnownItems=setmetatable({}, {__mode="k"})

Workspace.ChildAdded:Connect(function(object)
    if EntityAliases[object.Name] then
        if Settings.NotifyEntities and not KnownEntities[object] then
            KnownEntities[object]=true
            hubNotify("Entity Spawned", EntityAliases[object] .. " has appeared.",5,Theme.Red)
        end
    end
end)

Workspace.DescendantAdded:Connect(function(object)
    local label,category=objectLabelCategory(object)
    if label and category=="Item" and Settings.NotifyItems and not KnownItems[object] then
        KnownItems[object]=true
        local body=label
        if Settings.NotifyItemsDistance and RootPart then
            local p=getPosition(object)
            if p then body=label .. " • " .. math.floor((p-RootPart.Position).Magnitude) .. " studs" end
        end
        hubNotify("Item Spawned",body,4,Color3.fromRGB(170,0,255))
    end
end)

--==============================================================
-- IDLE KICK
--==============================================================

LocalPlayer.Idled:Connect(function()
    if not Settings.DisableIdleKick then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

--==============================================================
-- INFINITE JUMPS
--==============================================================

UserInputService.JumpRequest:Connect(function()
    if not Settings.InfiniteJumps then return end
    if Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

--==============================================================
-- DAMAGE / ANTICHEAT / PHYSICS HELPERS
--==============================================================

local lastRevive = 0
local anticheatDisabled = false

local function protectLocalHealth()
    if not Humanoid or Humanoid.Health <= 0 then return end
    if Settings.NoScreechDamage or Settings.NoHaltDamage or Settings.NoA90Damage or Settings.NoSurgeDamage or Settings.FigureGodmode then
        if Humanoid.Health < Humanoid.MaxHealth then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end
end

local function tryDisableAnticheat()
    if not Settings.DisableAnticheat or anticheatDisabled then return end
    local climb = RemotesFolder and RemotesFolder:FindFirstChild("ClimbLadder")
    if climb and Character and Character:GetAttribute("Climbing") == true then
        safe(function() climb:FireServer() end)
        anticheatDisabled = true
        hubNotify("Anticheat", "Ladder interaction detected; bypass attempt sent.", 4, Theme.Green)
    end
end

local function autoRevive()
    if not Settings.InfiniteRevives then return end
    if tick() - lastRevive < 2 then return end
    local alive = LocalPlayer:GetAttribute("Alive")
    if alive == false then
        local revive = RemotesFolder and RemotesFolder:FindFirstChild("Revive")
        if revive then
            lastRevive = tick()
            safe(function() revive:FireServer() end)
        end
    end
end

local function applyAccelerationSetting()
    if not Character then return end
    for _,part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            if not OriginalPhysics[part] then OriginalPhysics[part] = part.CustomPhysicalProperties end
            if Settings.RemoveAcceleration then
                part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0, 0, 100, 100)
            else
                part.CustomPhysicalProperties = OriginalPhysics[part]
            end
        end
    end
end

--==============================================================
-- OPTIONAL METAMETHOD HOOKS
--==============================================================

if has("hookmetamethod") and has("newcclosure") and has("getnamecallmethod") then
    pcall(function()
        local oldNamecall
        oldNamecall = ENV.hookmetamethod(game, "__namecall", ENV.newcclosure(function(self, ...)
            local method = ENV.getnamecallmethod()
            local name = self and self.Name or ""

            if method == "FireServer" then
                if Settings.AutoHeartbeat and (name == "ClutchHeartbeat" or name == "HideMonster") then
                    return
                end
                if Settings.NoScreechDamage and name == "Screech" then return end
                if Settings.NoHaltDamage and name == "Shade" then return end
                if Settings.NoA90Damage and name == "A90" then return end
                if Settings.NoSurgeDamage and (name == "SurgeRemote" or name == "Surge") then return end
            end

            return oldNamecall(self, ...)
        end))
    end)
end

--==============================================================
-- RENDER LOOP
--==============================================================

local roomPath=nil
local roomPathWaypoints={}
local roomPathIndex=1
local roomPathGoal=nil
local roomPathLast=0
local pathFolder=Instance.new("Folder")
pathFolder.Name="JuanmaBBB_Path"
pathFolder.Parent=Workspace

local function clearPath()
    for _,obj in ipairs(pathFolder:GetChildren()) do obj:Destroy() end
    roomPathWaypoints={}
    roomPathIndex=1
end

local function showPath(waypoints)
    clearPath()
    if not Settings.RoomsShowPath then return end
    for _,w in ipairs(waypoints) do
        local p=Instance.new("Part")
        p.Name="PathNode"
        p.Shape=Enum.PartType.Ball
        p.Size=Vector3.new(0.6,0.6,0.6)
        p.Anchored=true
        p.CanCollide=false
        p.Material=Enum.Material.Neon
        p.Color=Accent()
        p.Transparency=0.35
        p.Position=w.Position
        p.Parent=pathFolder
    end
end

local function getRoomsTarget()
    if not CurrentRooms or not LatestRoom then return nil end
    local room=CurrentRooms:FindFirstChild(tostring(LatestRoom.Value))
    if not room then return nil end
    local exit=room:FindFirstChild("RoomExit")
    if exit and exit:IsA("BasePart") then return exit end
    local door=room:FindFirstChild("Door")
    if door then
        return door:IsA("BasePart") and door or door:FindFirstChildWhichIsA("BasePart",true)
    end
end

local function roomsAutoWalk()
    if not Settings.AutoRooms or not RootPart or not Humanoid then return end
    if Floor~="Rooms" and Settings.AutoRooms then
        -- Keep generic auto-walk useful on other floors without forcing it.
    end
    local target=nil
    local danger=anyRushLike()
    if danger and not (Settings.RoomsIgnoreA60 and danger.Name=="A60") then
        target=findHideSpot()
    end
    target=target or getRoomsTarget()
    if not target then return end
    local targetPos=getPosition(target)
    if not targetPos then return end

    if target~=roomPathGoal or tick()-roomPathLast>Settings.RoomsPathTimeout then
        roomPathGoal=target
        roomPathLast=tick()
        roomPath=PathfindingService:CreatePath({AgentCanJump=true,AgentCanClimb=false,WaypointSpacing=4,AgentRadius=1.5,AgentHeight=2})
        local ok=pcall(function() roomPath:ComputeAsync(RootPart.Position,targetPos) end)
        if ok and roomPath.Status==Enum.PathStatus.Success then
            roomPathWaypoints=roomPath:GetWaypoints()
            roomPathIndex=2
            showPath(roomPathWaypoints)
        else
            roomPathWaypoints={}
        end
    end

    local waypoint=roomPathWaypoints[roomPathIndex]
    if waypoint then
        if (RootPart.Position-waypoint.Position).Magnitude<3 then
            roomPathIndex = roomPathIndex + 1
        else
            Humanoid:MoveTo(waypoint.Position)
        end
    end
    if target:IsA("Model") then
        local hp=target:FindFirstChild("HidePrompt",true)
        if hp and (targetPos-RootPart.Position).Magnitude<=hp.MaxActivationDistance then forcePrompt(hp) end
    end
end

local function updateESP()
    if not (Settings.ESPObjectives or Settings.ESPDoors or Settings.ESPHidingSpots or Settings.ESPPlayers or Settings.ESPChests or Settings.ESPItems or Settings.ESPCurrency or Settings.ESPLadders or Settings.ESPEntities or Settings.ESPHoncho) then
        for obj in pairs(ESP) do destroyESP(obj) end
        return
    end
    rebuildESP()

    if Settings.ESPRainbow then
        local hue=(tick()%5)/5
        for _,info in pairs(ESP) do
            local c=Color3.fromHSV(hue,1,1)
            info.Highlight.FillColor=c
            info.Highlight.OutlineColor=c
            info.Label.TextColor3=c
        end
    else
        for _,info in pairs(ESP) do
            local c=info.BaseColor
            info.Highlight.FillColor=c
            info.Highlight.OutlineColor=c
            info.Label.TextColor3=c
        end
    end

    if Camera and RootPart then
        for object,info in pairs(ESP) do
            if object.Parent then
                local target=espTargetPart(object)
                if target and Settings.ESPShowDistance then
                    local d=(target.Position-RootPart.Position).Magnitude
                    info.Label.Text=objectLabelCategory(object) and ((objectLabelCategory(object)) .. " • " .. math.floor(d) .. "m") or info.Label.Text
                end
            else
                destroyESP(object)
            end
        end
    end
end

local function updateTracersAndArrows()
    if not Camera or not RootPart then return end
    local viewport=Camera.ViewportSize
    local center=Vector2.new(viewport.X/2,viewport.Y/2)
    local mouse=UserInputService:GetMouseLocation()

    if Settings.ESPTracers then
        for object,tracer in pairs(TracerObjects) do
            local target=object and object.Parent and espTargetPart(object)
            if target then
            local pos,on=Camera:WorldToViewportPoint(target.Position)
            local playerPos=Camera:WorldToViewportPoint(RootPart.Position)
            if on then
                if Settings.ESPTracerOrigin=="Top" then tracer.From=Vector2.new(viewport.X/2,0)
                elseif Settings.ESPTracerOrigin=="Center" then tracer.From=center
                elseif Settings.ESPTracerOrigin=="Mouse" then tracer.From=Vector2.new(mouse.X,mouse.Y)
                else tracer.From=Vector2.new(viewport.X/2,viewport.Y) end
                tracer.To=Vector2.new(pos.X,pos.Y)
                tracer.Thickness=Settings.ESPTracerThickness
                tracer.Visible=true
            else tracer.Visible=false end
            else
                pcall(function() tracer:Remove() end);TracerObjects[object]=nil
            end
        end
    else
        for object,tracer in pairs(TracerObjects) do pcall(function() tracer:Remove() end);TracerObjects[object]=nil end
    end

    for object,arrow in pairs(ArrowObjects) do
        local target=object and object.Parent and espTargetPart(object)
        if target then
        local pos,on=Camera:WorldToViewportPoint(target.Position)
        if on then arrow.Visible=false else
            local relative=Camera.CFrame:PointToObjectSpace(target.Position)
            local angle=math.atan2(-relative.Z,relative.X)
            local r=Settings.ESPArrowRadius
            arrow.Position=UDim2.new(0,center.X+math.cos(angle)*math.min(r,viewport.X/2-35),0,center.Y+math.sin(angle)*math.min(r,viewport.Y/2-35))
            arrow.Rotation=math.deg(angle)
            arrow.Visible=Settings.ESPArrows
        end
        else arrow:Destroy();ArrowObjects[object]=nil end
    end
end

local AutomationAccumulator = 0
local ESPAccumulator = 0

RunService.RenderStepped:Connect(function(dt)
    refreshReferences()
    if not Character or not Humanoid or not RootPart then return end
    protectLocalHealth()
    tryDisableAnticheat()
    autoRevive()
    applyAccelerationSetting()
    Camera=Workspace.CurrentCamera or Camera

    -- Speed boost
    if Settings.SpeedBoost and not RansomFrozen then
        local base=16
        pcall(function()
            if Humanoid:GetAttribute("BaseSpeed") then base=Humanoid:GetAttribute("BaseSpeed") end
        end)
        if base==16 and Humanoid.WalkSpeed>0 and Humanoid.WalkSpeed<30 then base=Humanoid.WalkSpeed end
        Humanoid.WalkSpeed=base+Settings.SpeedBoostAmount
    end

    -- Fly
    if Settings.Fly and not RansomFrozen then
        local velocity=flyVelocity()*Settings.FlySpeed
        local y=0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then y = y + Settings.FlySpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then y = y - Settings.FlySpeed end
        RootPart.AssemblyLinearVelocity=Vector3.new(velocity.X,y,velocity.Z)
    end

    -- Noclip
    for _,part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            if OriginalParts[part]==nil then OriginalParts[part]=part.CanCollide end
            if Settings.Noclip then part.CanCollide=false else part.CanCollide=OriginalParts[part] end
        end
    end

    -- Anti teleport / soft velocity manipulation
    if Settings.VelocityManipulation and not RansomFrozen then
        local dir=Humanoid.MoveDirection
        if Settings.VelocityMode=="Velocity" then
            RootPart.AssemblyLinearVelocity=Vector3.new(dir.X*Settings.VelocitySpeed,RootPart.AssemblyLinearVelocity.Y,dir.Z*Settings.VelocitySpeed)
        elseif dir.Magnitude>0 then
            RootPart.CFrame=RootPart.CFrame + dir.Unit*Settings.VelocitySpeed*dt
        end
    end

    if Settings.AntiTeleport then
        local maxStep=Settings.AntiTeleportSpeed*math.clamp(dt,0,0.1)
        if RootPart.AssemblyLinearVelocity.Magnitude>Settings.AntiTeleportSpeed then
            local v=RootPart.AssemblyLinearVelocity
            RootPart.AssemblyLinearVelocity=v.Unit*Settings.AntiTeleportSpeed
        end
        if maxStep<=0 then RootPart.AssemblyLinearVelocity=Vector3.zero end
    end

    -- Position / crouch spoof
    if Settings.CrouchSpoof or Settings.PositionSpoof then
        local crouch=RemotesFolder and RemotesFolder:FindFirstChild("Crouch")
        if crouch then safe(function() crouch:FireServer(true,true) end) end
        if Settings.PositionSpoof and Floor ~= "Fools" and Floor ~= "OldHotel" then
            if Character:GetAttribute("JuanmaBBB_PositionSpoofApplied") ~= true then
                RootPart.CFrame = RootPart.CFrame * CFrame.new(0, -2.346, 0)
                Humanoid.HipHeight = 0.05
                Character:SetAttribute("JuanmaBBB_PositionSpoofApplied", true)
            end
        elseif Character:GetAttribute("JuanmaBBB_PositionSpoofApplied") == true then
            RootPart.CFrame = RootPart.CFrame * CFrame.new(0, 2.346, 0)
            Humanoid.HipHeight = 2.396
            Character:SetAttribute("JuanmaBBB_PositionSpoofApplied", false)
        end
    elseif Character:GetAttribute("JuanmaBBB_PositionSpoofApplied") == true then
        RootPart.CFrame = RootPart.CFrame * CFrame.new(0, 2.346, 0)
        Humanoid.HipHeight = 2.396
        Character:SetAttribute("JuanmaBBB_PositionSpoofApplied", false)
    end

    -- Ransom freeze timer
    if RansomFrozen and tick()>=RansomUntil then setRansomFreeze(false) end

    -- Environment
    if Settings.Ambient then
        local c=Color3.fromRGB(table.unpack(Settings.AmbientColor))
        Lighting.Ambient=c
    else Lighting.Ambient=Original.Lighting.Ambient end

    if Settings.RemoveFog then
        Lighting.FogEnd=10000000
        for _,a in ipairs(Lighting:GetChildren()) do if a:IsA("Atmosphere") then a.Density=0 end end
    else Lighting.FogEnd=Original.Lighting.FogEnd end

    if Camera then
        Camera.FieldOfView=Settings.FOV
    end

    updateThirdPerson()
    applyCharacterAttributes()


    -- Generic removals / bypasses
    if Settings.BypassDrone then
        for _,d in ipairs(Workspace:GetDescendants()) do
            if d.Name=="WalkedInto" and (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) and d:FindFirstAncestor("Drones") then
                pcall(function() d:Destroy() end)
            end
        end
    end

    applyBypasses()
    removeDisabledObjects()

    AutomationAccumulator = AutomationAccumulator + dt
    if AutomationAccumulator >= 0.15 then
        AutomationAccumulator = 0
        if Settings.AutoOpenDoors then autoOpenDoors() end
        if Settings.AutoLoot then autoLoot() end
        if Settings.AutoInteract then autoInteract() end
        if Settings.AutoCloset then autoCloset() end
        if Settings.AutoRooms then roomsAutoWalk() elseif roomPathWaypoints[1] then clearPath() end
        if Settings.AutoBreaker then autoBreaker() end
        if Settings.AutoSolveAnchors then autoAnchors() end
        if Settings.AutoUnlockPadlock or Settings.AutoLibraryGuess then autoPadlock() end
        maintainInfiniteItems()
        if Settings.DisableCutscenes then
            for _,obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ModuleScript") and (obj.Name=="Figure" or obj.Name=="FigureEnd" or obj.Name=="SeekIntroHotel" or obj.Name=="SeekIntroMines" or obj.Name=="GrumbleNestEnd") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end

    ESPAccumulator = ESPAccumulator + dt
    if ESPAccumulator >= 0.75 then
        ESPAccumulator = 0
        updateESP()
    end
    updateTracersAndArrows()
end)

--==============================================================
-- ARCHIVES / HASTE / OXYGEN NOTIFICATIONS
--==============================================================

local LastHasteSecond=-1
local LastOxygen=nil

RunService.Heartbeat:Connect(function()
    if Settings.NotifyHasteTime and FloorReplicated then
        local timer=FloorReplicated:FindFirstChild("DigitalTimer")
        if timer and (timer:IsA("NumberValue") or timer:IsA("IntValue")) then
            local seconds=math.max(0,math.floor(timer.Value))
            if seconds~=LastHasteSecond then
                LastHasteSecond=seconds
                local m=math.floor(seconds/60)
                local s=seconds%60
                hubNotify("Haste Timer",string.format("%02d:%02d",m,s),2,Theme.Yellow)
            end
        end
    end

    if Settings.NotifyOxygen then
        local oxygenValue=nil
        for _,candidate in ipairs({"Oxygen","OxygenLevel","CurrentOxygen"}) do
            local v=LocalPlayer:GetAttribute(candidate)
            if type(v)=="number" then oxygenValue=v;break end
        end
        if oxygenValue and oxygenValue~=LastOxygen then
            LastOxygen=oxygenValue
            hubNotify("Oxygen",string.format("%.1f",oxygenValue),2,Theme.Cyan)
        end
    end

    if isArchives() and (Settings.NotifyStampedeTime or Settings.NotifyDroneStampede) then
        local remaining,target,clock=stampedeCountdown()
        if remaining then
            local second=math.floor(remaining)
            if Settings.NotifyStampedeTime and second~=Stampede.LastSecond then
                Stampede.LastSecond=second
                if second<=30 then
                    hubNotify("Drone Stampede",(clock and ("Clock "..clock.." → ") or "") .. "~"..second.."s until "..(target==5 and "5:00" or "9:00"),2,Theme.Yellow)
                end
            end
            if Settings.NotifyDroneStampede and remaining<=Settings.StampedeWarning and remaining>0 and tick()-Stampede.LastWarning>20 then
                Stampede.LastWarning=tick()
                hubNotify("DRONE STAMPEDE INCOMING", "Move to the side / hide. ~"..math.floor(remaining).." seconds.",6,Theme.Red)
            end
            if remaining<=1.5 and tick()-Stampede.LastHorde>15 then
                Stampede.LastHorde=tick()
                hubNotify("DRONE STAMPEDE", "NOW — get off the center line.",6,Theme.Red)
            end
        end
    end

    if Settings.NotifyDroneAtDoor and isArchives() and RootPart and CurrentRooms then
        local bestExit=nil
        local bestDistance=80
        for _,room in ipairs(CurrentRooms:GetChildren()) do
            local exit=room:FindFirstChild("RoomExit")
            if exit and exit:IsA("BasePart") then
                local d=(exit.Position-RootPart.Position).Magnitude
                if d<bestDistance then bestDistance=d;bestExit=exit end
            end
        end
        if bestExit then
            local count=0
            for _,room in ipairs(CurrentRooms:GetChildren()) do
                for _,obj in ipairs(room:GetDescendants()) do
                    if obj.Name=="Drones" then
                        local p=getPosition(obj)
                        if p and (p-bestExit.Position).Magnitude<=Settings.DroneDoorDistance then count = count + 1 end
                    end
                end
            end
            if count>0 and Stampede.LastDoorWarning~=bestExit then
                Stampede.LastDoorWarning=bestExit
                hubNotify("Drone Behind Door", tostring(count).." drone group(s) detected near the next exit.",5,Theme.Red)
            end
        end
    end
end)

--==============================================================
-- SIMPLE MINECART AUTO STEER
--==============================================================

local function autoMinecart()
    if not Settings.AutoSteerMinecart or not Camera or not RootPart then return end
    local cart=Camera:FindFirstChild("MinecartRig")
    if not cart then return end
    local turn=nil
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name=="PathNode" or obj.Name=="TurnNode" then
            local p=getPosition(obj)
            if p and (p-RootPart.Position).Magnitude<=Settings.MinecartTurnDistance then turn=obj;break end
        end
    end
    if turn then
        local p=getPosition(turn)
        if p then
            local flat=Vector3.new(p.X,RootPart.Position.Y,p.Z)-RootPart.Position
            if flat.Magnitude>0.1 then Humanoid:Move(flat.Unit,false) end
        end
    end
end

RunService.Heartbeat:Connect(autoMinecart)

--==============================================================
-- SEEK / EYESTALK PATH VISUALIZER (GENERIC)
--==============================================================

local PathVisualFolder=Instance.new("Folder")
PathVisualFolder.Name="JuanmaBBB_FloorPaths"
PathVisualFolder.Parent=Workspace

local function clearFloorPath(name)
    for _,obj in ipairs(PathVisualFolder:GetChildren()) do
        if obj.Name==name then obj:Destroy() end
    end
end

local function createBeamChain(name, positions, color)
    clearFloorPath(name)
    local previous=nil
    for _,position in ipairs(positions) do
        local node=Instance.new("Part")
        node.Name=name
        node.Size=Vector3.new(0.15,0.15,0.15)
        node.Position=position
        node.Anchored=true
        node.CanCollide=false
        node.Transparency=1
        node.Parent=PathVisualFolder
        if previous then
            local a0=Instance.new("Attachment",previous)
            local a1=Instance.new("Attachment",node)
            local beam=Instance.new("Beam")
            beam.Attachment0=a0
            beam.Attachment1=a1
            beam.Width0=0.18
            beam.Width1=0.18
            beam.FaceCamera=true
            beam.Brightness=4
            beam.Color=ColorSequence.new(color)
            beam.Parent=node
        end
        previous=node
    end
end

-- Generic path discovery: it only visualizes explicit waypoints/nodes
-- exposed by the current floor; it does not invent a route.
RunService.Heartbeat:Connect(function()
    if Settings.SeekPath then
        local points={}
        for _,obj in ipairs(Objects.SeekObstructions) do
            local p=getPosition(obj)
            if p then table.insert(points,p) end
        end
        if #points>=2 then createBeamChain("SeekPathNode",points,Color3.fromRGB(80,255,130)) end
    else clearFloorPath("SeekPathNode") end

    if Settings.EyestalkPath then
        local points={}
        for _,obj in ipairs(Objects.Objectives) do
            local p=getPosition(obj)
            if p then table.insert(points,p) end
        end
        if #points>=2 then createBeamChain("EyestalkPathNode",points,Color3.fromRGB(120,220,255)) end
    else clearFloorPath("EyestalkPathNode") end
end)

--==============================================================
-- BREAKER / FIGURE / CUTSCENE-LIKE LOCAL ADJUSTMENTS
--==============================================================

RunService.Heartbeat:Connect(function()
    if Settings.FigureGodmode then
        for _,obj in ipairs(Objects.Entities) do
            if obj.Name=="Figure" or obj.Name=="FigureRig" then
                local hum=obj:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum.Health=hum.MaxHealth end) end
            end
        end
    end

    if Settings.RemoveFigure then
        for _,obj in ipairs(Objects.Entities) do
            if obj.Name=="Figure" or obj.Name=="FigureRig" or obj.Name=="FigureRagdoll" then
                pcall(function() obj:Destroy() end)
            end
        end
    end

    if Settings.RemoveSeekTrigger then
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name=="SeekTrigger" or obj.Name=="SeekStart" or obj.Name=="SeekTriggerPart" then
                if obj:IsA("BasePart") then
                    obj.CanTouch=false
                end
            end
        end
    end
end)

--==============================================================
-- AUDIO DISABLERS
--==============================================================

local function processAudio()
    if Settings.RemoveFootsteps or Settings.RemoveJammin or Settings.RemoveInteractSounds then
        for _,obj in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if obj:IsA("Sound") then
                local n=obj.Name:lower()
                if Settings.RemoveFootsteps and (n:find("foot") or n:find("step")) then obj.Volume=0 end
                if Settings.RemoveInteractSounds and (n:find("triggered") or n:find("holding") or n:find("notification") or n:find("caption")) then obj.Volume=0 end
                if Settings.RemoveJammin and (n:find("jam") or n:find("jamming")) then obj.Volume=0 end
            end
        end
        for _,obj in ipairs(SoundService:GetDescendants()) do
            if obj:IsA("Sound") then
                local n=obj.Name:lower()
                if Settings.RemoveFootsteps and (n:find("foot") or n:find("step")) then obj.Volume=0 end
                if Settings.RemoveJammin and (n:find("jam") or n:find("jamming")) then obj.Volume=0 end
            end
        end
    end
end

local AudioAccumulator = 0
RunService.Heartbeat:Connect(function(dt)
    AudioAccumulator = AudioAccumulator + dt
    if AudioAccumulator >= 0.75 then
        AudioAccumulator = 0
        processAudio()
    end
end)

--==============================================================
-- V3 FEATURE COMPLETION LAYER
--==============================================================

-- The original V2 GUI already exposed several advanced options.
-- V3 wires those remaining options into the client where the
-- game's current client objects expose enough information to do so.

local V3 = {
    MainGame = nil,
    CameraTypeBeforeSpectate = nil,
    Spectating = false,
    JumpscareOriginalNames = setmetatable({}, {__mode = "k"}),
    CutsceneOriginalNames = setmetatable({}, {__mode = "k"}),
    ObstructionTransforms = setmetatable({}, {__mode = "k"}),
    FadedESP = setmetatable({}, {__mode = "k"}),
    DisabledVignette = setmetatable({}, {__mode = "k"}),
    FiredampOriginal = setmetatable({}, {__mode = "k"}),
    FarmActive = false,
    LastEyesBypass = 0,
    LastClientModuleScan = 0,
}

local V3CutsceneNames = {
    Figure=true,
    FigureEnd=true,
    FigureHotelEnd=true,
    FigureHotelFire=true,
    SeekIntroFools=true,
    SeekIntroHotel=true,
    SeekIntroMines=true,
    SeekIntroMines2=true,
    SerewSeekDrain=true,
    SewerSeekLower=true,
    GrumbleNestEnd=true,
    EyestalkIntro=true,
}

local V3JumpscareNames = {
    Glitch=true,
    SpiderJumpscare=true,
    Void=true,
}

local function V3GetMainGame()
    if V3.MainGame then return V3.MainGame end

    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local mainUI = playerGui and playerGui:FindFirstChild("MainUI")
    local initiator = mainUI and mainUI:FindFirstChild("Initiator")
    local module = initiator and initiator:FindFirstChild("Main_Game")

    if module and module:IsA("ModuleScript") then
        local ok, result = pcall(require, module)
        if ok and type(result) == "table" then
            V3.MainGame = result
            return result
        end
    end

    return nil
end

local function V3FindHideVignette()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return nil end

    return playerGui:FindFirstChild("HideVignette", true)
        or playerGui:FindFirstChild("HideVignette")
end

local function V3SetJumpscareDisabled(moduleObject, disabled)
    if not moduleObject then return end

    local original = V3.JumpscareOriginalNames[moduleObject]
    if not original then
        original = moduleObject:GetAttribute("JuanmaBBB_OriginalName")
            or moduleObject.Name:gsub("_Disabled$", "")
        V3.JumpscareOriginalNames[moduleObject] = original
        pcall(function()
            moduleObject:SetAttribute("JuanmaBBB_OriginalName", original)
        end)
    end

    if disabled then
        if moduleObject.Name == original then
            moduleObject.Name = original .. "_Disabled"
        end
    else
        if moduleObject.Name == original .. "_Disabled" then
            moduleObject.Name = original
        end
    end
end

local function V3ApplyJumpscareDisablers()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local mainUI = playerGui and playerGui:FindFirstChild("MainUI")
    local initiator = mainUI and mainUI:FindFirstChild("Initiator")
    local mainGame = initiator and initiator:FindFirstChild("Main_Game")
    local listener = mainGame and mainGame:FindFirstChild("RemoteListener")

    if mainGame then
        local jumpscares = listener and (
            listener:FindFirstChild("Jumpscares")
            or listener:FindFirstChild("Jumpscares_Disabled")
        )

        if jumpscares then
            local original = jumpscares:GetAttribute("JuanmaBBB_OriginalName") or "Jumpscares"
            pcall(function() jumpscares:SetAttribute("JuanmaBBB_OriginalName", original) end)
            if Settings.DisableEntityJumpscares then
                jumpscares.Name = "Jumpscares_Disabled"
            elseif jumpscares.Name == "Jumpscares_Disabled" then
                jumpscares.Name = original
            end
        end

        local modules = listener and listener:FindFirstChild("Modules")
        if modules then
            for _, object in ipairs(modules:GetChildren()) do
                if object:IsA("ModuleScript") then
                    local name = object.Name:gsub("_Disabled$", "")
                    local isEntityJump = name:find("Jumpscare") ~= nil
                        and not name:find("Eyestalk")
                        and not name:find("Groundskeeper")
                        and not name:find("Monument")

                    if isEntityJump then
                        local original = object:GetAttribute("JuanmaBBB_OriginalName") or name
                        pcall(function() object:SetAttribute("JuanmaBBB_OriginalName", original) end)
                        V3SetJumpscareDisabled(object, Settings.DisableEntityJumpscares)
                    end
                end
            end

            -- Timothy's SpiderJumpscare lives in the client module
            -- container in the supplied reference, so treat it separately.
            for name, enabled in pairs({
                SpiderJumpscare = Settings.DisableTimothyJumpscare,
                Glitch = Settings.DisableGlitchJumpscare,
                Void = Settings.DisableVoidJumpscare,
            }) do
                local object = modules:FindFirstChild(name) or modules:FindFirstChild(name .. "_Disabled")
                if object then
                    V3SetJumpscareDisabled(object, enabled)
                end
            end
        end
    end

    local rsModules = ReplicatedStorage:FindFirstChild("ModulesClient")
        or ReplicatedStorage:FindFirstChild("ClientModules")

    local entityModules = rsModules and rsModules:FindFirstChild("EntityModules")
    if entityModules then
        for _, name in ipairs({"Glitch", "SpiderJumpscare", "Void"}) do
            local object = entityModules:FindFirstChild(name)
                or entityModules:FindFirstChild(name .. "_Disabled")

            if object then
                local shouldDisable =
                    (name == "Glitch" and Settings.DisableGlitchJumpscare)
                    or (name == "SpiderJumpscare" and Settings.DisableTimothyJumpscare)
                    or (name == "Void" and Settings.DisableVoidJumpscare)

                V3SetJumpscareDisabled(object, shouldDisable)
            end
        end
    end
end

local function V3ApplyVignetteAndFiredamp()
    local vignette = V3FindHideVignette()
    if vignette and vignette:IsA("ImageLabel") then
        if V3.DisabledVignette[vignette] == nil then
            V3.DisabledVignette[vignette] = vignette.ImageTransparency
        end

        local target = Settings.DisableHideVignette and 1 or V3.DisabledVignette[vignette]
        if vignette.ImageTransparency ~= target then
            vignette.ImageTransparency = target
        end
    end

    refreshReferences()

    if CurrentRooms then
        for _, room in ipairs(CurrentRooms:GetChildren()) do
            if room:GetAttribute("Firedamp") ~= nil then
                if V3.FiredampOriginal[room] == nil then
                    V3.FiredampOriginal[room] = room:GetAttribute("Firedamp")
                end

                if Settings.DisableFiredamp then
                    room:SetAttribute("Firedamp", false)
                elseif V3.FiredampOriginal[room] ~= nil then
                    room:SetAttribute("Firedamp", V3.FiredampOriginal[room])
                end
            end
        end
    end

    if Settings.DisableFiredamp and Camera then
        for _, object in ipairs(Camera:GetChildren()) do
            if object.Name == "LiveFiredamp" then
                pcall(function() object:Destroy() end)
            end
        end
    end
end

local function V3ApplyCameraSystems()
    Camera = Workspace.CurrentCamera
    if not Camera then return end

    local mainGame = V3GetMainGame()

    if mainGame then
        if Settings.RemoveCameraShake then
            pcall(function() mainGame.csgo = CFrame.new() end)
        end

        if Settings.RemoveCameraBobbing then
            pcall(function() mainGame.spring.Speed = 9e9 end)
        else
            pcall(function() mainGame.spring.Speed = 8 end)
        end

        if Settings.ViewmodelOffset then
            pcall(function()
                mainGame.tooloffset = Vector3.new(
                    Settings.ViewmodelX,
                    Settings.ViewmodelY,
                    Settings.ViewmodelZ
                )
            end)
        else
            pcall(function() mainGame.tooloffset = Vector3.zero end)
        end
    end

    -- Third-person offset with an optional wall spherecast.
    if Settings.ThirdPerson then
        local offset = CFrame.new(
            Settings.ThirdPersonX,
            Settings.ThirdPersonY,
            Settings.ThirdPersonZ
        )

        local direction = offset.Position
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        if Character then
            rayParams.FilterDescendantsInstances = {Character}
        end

        if Settings.ThirdPersonWallCheck then
            local result = Workspace:Spherecast(
                Camera.CFrame.Position,
                0.2,
                direction,
                rayParams
            )

            if result and result.Instance and result.Instance.CanCollide then
                local distance = math.max(0.2, result.Distance - 0.15)
                local newPosition = Camera.CFrame.Position + direction.Unit * distance
                Camera.CFrame = CFrame.lookAt(newPosition, newPosition + Camera.CFrame.LookVector)
            else
                Camera.CFrame = Camera.CFrame * offset
            end
        else
            Camera.CFrame = Camera.CFrame * offset
        end
    end

    if Settings.SpectateEntity then
        local entity = nearest(Objects.Entities, 250)
        if entity and entity.Parent then
            local entityPart = espTargetPart(entity)
            if entityPart then
                if not V3.Spectating then
                    V3.CameraTypeBeforeSpectate = Camera.CameraType
                    V3.Spectating = true
                end

                if Settings.SpectateMode == "Entity to Player" and RootPart then
                    Camera.CameraType = Enum.CameraType.Scriptable
                    Camera.CFrame = CFrame.lookAt(
                        entityPart.Position,
                        RootPart.Position
                    )
                else
                    Camera.CameraType = Enum.CameraType.Scriptable
                    local head = Character and Character:FindFirstChild("Head")
                    local playerPos = head and head.Position or Camera.CFrame.Position
                    Camera.CFrame = CFrame.lookAt(
                        playerPos,
                        entityPart.Position
                    )
                end
            end
        end
    elseif V3.Spectating then
        Camera.CameraType = V3.CameraTypeBeforeSpectate or Enum.CameraType.Custom
        V3.CameraTypeBeforeSpectate = nil
        V3.Spectating = false
    end
end

local function V3ApplyClosetDelay()
    if not Settings.RemoveClosetDelay then return end
    if not Character or not Humanoid or not RootPart then return end
    if Humanoid.MoveDirection == Vector3.zero then return end
    if Character:GetAttribute("AnimatingClient") == true then return end
    if Character:GetAttribute("Hiding") ~= true then return end

    if RemotesFolder then
        local camLock = RemotesFolder:FindFirstChild("CamLock")
        if camLock then
            safe(function() camLock:FireServer() end)
        end
    end
end

local function V3ApplyEyeLookmanBypass()
    if not RemotesFolder then return end
    if tick() - V3.LastEyesBypass < 0.12 then return end

    local eyesActive = Workspace:FindFirstChild("Eyes") ~= nil
        or Workspace:FindFirstChild("Lookman") ~= nil
    local lookmanActive = Workspace:FindFirstChild("BackdoorLookman") ~= nil

    local doBypass =
        (Settings.BypassEyes and eyesActive)
        or (Settings.BypassLookman and lookmanActive)

    if not doBypass then return end

    local remote = RemotesFolder:FindFirstChild("MotorReplication")
    if not remote then return end

    V3.LastEyesBypass = tick()

    if Floor == "Fools" or Floor == "OldHotel" then
        safe(function()
            remote:FireServer(0, -65, 0, false)
        end)
    else
        safe(function()
            remote:FireServer(-650)
        end)
    end
end

local function V3ApplyVacuumBypass()
    if not Settings.BypassVacuum then return end

    for _, object in ipairs(Workspace:GetDescendants()) do
        if object.Name == "SideroomSpace"
        or object.Name == "Vacuum"
        or object.Name == "VacuumZone" then
            for _, part in ipairs(object:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part:GetAttribute("JuanmaBBB_OriginalCanTouch") == nil then
                        part:SetAttribute("JuanmaBBB_OriginalCanTouch", part.CanTouch)
                    end
                    if part:GetAttribute("JuanmaBBB_OriginalCanCollide") == nil then
                        part:SetAttribute("JuanmaBBB_OriginalCanCollide", part.CanCollide)
                    end

                    -- Matches the supplied reference's SideroomSpace approach:
                    -- solid safety volume, but no touch trigger.
                    part.CanCollide = true
                    part.CanTouch = false
                end
            end
        end
    end
end

local function V3RestoreVacuum()
    if Settings.BypassVacuum then return end

    for _, object in ipairs(Workspace:GetDescendants()) do
        if object.Name == "SideroomSpace"
        or object.Name == "Vacuum"
        or object.Name == "VacuumZone" then
            for _, part in ipairs(object:GetDescendants()) do
                if part:IsA("BasePart") then
                    local touch = part:GetAttribute("JuanmaBBB_OriginalCanTouch")
                    local collide = part:GetAttribute("JuanmaBBB_OriginalCanCollide")
                    if touch ~= nil then part.CanTouch = touch end
                    if collide ~= nil then part.CanCollide = collide end
                end
            end
        end
    end
end

local function V3ApplyObstructionRemovals()
    local mapping = {
        ThingToOpen = Settings.RemoveBasementGate,
        MovingDoor = Settings.RemovePaintingsDoor,
        Wax_Door = Settings.RemoveSkeletonDoor,
    }

    for _, object in ipairs(Objects.Obstructions) do
        local enabled = mapping[object.Name]
        if enabled ~= nil and object.Parent then
            if V3.ObstructionTransforms[object] == nil then
                local position = getPosition(object)
                if object:IsA("Model") then
                    V3.ObstructionTransforms[object] = {
                        kind = "model",
                        pivot = object:GetPivot(),
                    }
                elseif object:IsA("BasePart") then
                    V3.ObstructionTransforms[object] = {
                        kind = "part",
                        cframe = object.CFrame,
                    }
                elseif position then
                    V3.ObstructionTransforms[object] = {
                        kind = "position",
                        position = position,
                    }
                end
            end

            local original = V3.ObstructionTransforms[object]
            if enabled then
                pcall(function()
                    if original.kind == "model" then
                        object:PivotTo(CFrame.new(-10000, -10000, -10000))
                    elseif original.kind == "part" then
                        object.CFrame = CFrame.new(-10000, -10000, -10000)
                    end
                end)
            else
                pcall(function()
                    if original.kind == "model" then
                        object:PivotTo(original.pivot)
                    elseif original.kind == "part" then
                        object.CFrame = original.cframe
                    end
                end)
            end
        end
    end
end

local function V3ParseInfiniteItemList()
    local wanted = {}
    for token in tostring(Settings.InfiniteItemList or ""):gmatch("[^,]+") do
        token = token:gsub("^%s+", ""):gsub("%s+$", "")
        local lower = token:lower()
        if lower ~= "" then
            wanted[lower] = true
        end
    end
    return wanted
end

local function V3MaintainInfiniteItems()
    if not Settings.InfiniteItems then return end

    local wanted = V3ParseInfiniteItemList()

    for _, container in ipairs({Character, LocalPlayer.Backpack}) do
        if container then
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") then

                local display = ItemAliases[tool.Name] or tool.Name
                local include =
                    wanted[tool.Name:lower()]
                    or wanted[tostring(display):lower()]

                if include then
                    if tool:GetAttribute("JuanmaBBB_OriginalUses") == nil then
                        local uses = tool:GetAttribute("Uses")
                        if uses ~= nil then
                            tool:SetAttribute("JuanmaBBB_OriginalUses", uses)
                        end
                    end

                    local original = tool:GetAttribute("JuanmaBBB_OriginalUses")
                    if original ~= nil and tool:GetAttribute("Uses") ~= original then
                        pcall(function()
                            tool:SetAttribute("Uses", original)
                        end)
                    end
                end
                end
            end
        end
    end
end

local function V3ApplyESPFade()
    local fadeTime = tonumber(Settings.ESPFadeTime) or 0
    if fadeTime <= 0 then
        for _, info in pairs(ESP) do
            if info.Highlight and info.Label then
                info.Highlight.FillTransparency = Settings.ESPFillTransparency
                info.Highlight.OutlineTransparency = Settings.ESPOutlineTransparency
                info.Label.TextTransparency = Settings.ESPTextTransparency
                info.Label.TextStrokeTransparency = Settings.ESPTextOutlineTransparency
            end
        end
        return
    end

    local now = tick()

    for object, info in pairs(ESP) do
        if object and object.Parent then

        if not V3.FadedESP[object] then
            V3.FadedESP[object] = now
            info.Highlight.FillTransparency = 1
            info.Highlight.OutlineTransparency = 1
            info.Label.TextTransparency = 1
            info.Label.TextStrokeTransparency = 1
        end

        local alpha = math.clamp((now - V3.FadedESP[object]) / fadeTime, 0, 1)
        local fillTarget = Settings.ESPFillTransparency
        local outlineTarget = Settings.ESPOutlineTransparency
        local textTarget = Settings.ESPTextTransparency
        local strokeTarget = Settings.ESPTextOutlineTransparency

        info.Highlight.FillTransparency = 1 - (1 - fillTarget) * alpha
        info.Highlight.OutlineTransparency = 1 - (1 - outlineTarget) * alpha
        info.Label.TextTransparency = 1 - (1 - textTarget) * alpha
        info.Label.TextStrokeTransparency = 1 - (1 - strokeTarget) * alpha

        if alpha >= 1 then
            V3.FadedESP[object] = true
        end
        end
    end

    for object in pairs(V3.FadedESP) do
        if not ESP[object] then
            V3.FadedESP[object] = nil
        end
    end
end

local function V3ApplyRoomsFootstepSpoof()
    if not Settings.RoomsSpoofFootsteps then return end
    if not Settings.AutoRooms then return end
    if Floor ~= "Rooms" then return end
    if not Humanoid or not RootPart or not Character then return end
    if Character:GetAttribute("Hiding") then return end

    -- Client-side approximation of the reference's MoveDirection spoof:
    -- keep movement aligned to the actual root direction during auto-walk.
    if Humanoid.MoveDirection.Magnitude > 0.01 then
        Humanoid:Move(RootPart.CFrame.LookVector, false)
    end
end

local function V3ApplyKnobFarm()
    if not Settings.KnobFarm
    or not Settings.KnobFarmStarted
    or V3.FarmActive then
        return
    end

    if LatestRoom and tonumber(LatestRoom.Value) ~= 0 then
        return
    end

    local topbar = LocalPlayer.PlayerGui:FindFirstChild("TopbarUI")
    local goldValue = topbar
        and topbar:FindFirstChild("Topbar")
        and topbar.Topbar:FindFirstChild("StatsTopbarHandler")
        and topbar.Topbar.StatsTopbarHandler:FindFirstChild("StatModules")
        and topbar.Topbar.StatsTopbarHandler.StatModules:FindFirstChild("Gold")
        and topbar.Topbar.StatsTopbarHandler.StatModules.Gold:FindFirstChild("GoldVal")

    if goldValue and tonumber(goldValue.Value) and goldValue.Value <= 0 then
        if tick() - (V3.LastFarmWarning or 0) > 5 then
            V3.LastFarmWarning = tick()
            hubNotify("Knob Farm", "You need gold before starting the farm.", 4, Theme.Yellow)
        end
        return
    end

    V3.FarmActive = true

    task.spawn(function()
        local ok = true

        if has("replicatesignal") then
            ok = pcall(function()
                ENV.replicatesignal(LocalPlayer.Kill)
            end)
        else
            local underwater = RemotesFolder and RemotesFolder:FindFirstChild("Underwater")
            if underwater then
                ok = pcall(function()
                    underwater:FireServer(true)
                end)
            else
                ok = false
            end
        end

        if not ok then
            V3.FarmActive = false
            hubNotify("Knob Farm", "Could not start the death cycle on this executor.", 4, Theme.Red)
            return
        end

        local deadline = tick() + 30
        while tick() < deadline do
            if LocalPlayer:GetAttribute("Alive") == true then
                break
            end
            task.wait(0.1)
        end

        if LocalPlayer:GetAttribute("Alive") == true then
            local statistics = RemotesFolder and RemotesFolder:FindFirstChild("Statistics")
            if statistics then
                pcall(function()
                    statistics:FireServer()
                end)
            end
        end

        task.wait(0.25)
        V3.FarmActive = false
    end)
end

local function V3ApplyHidingTransparency()
    if not CurrentRooms then return end

    for _, spot in ipairs(Objects.HidingSpots) do
        if spot and spot.Parent then
            local hidden = spot:FindFirstChild("HiddenPlayer", true)
            local isHiding = hidden and hidden.Value == Character

            for _, part in ipairs(spot:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part:GetAttribute("JuanmaBBB_TransparencyOld") == nil then
                        part:SetAttribute("JuanmaBBB_TransparencyOld", part.Transparency)
                    end

                    local old = part:GetAttribute("JuanmaBBB_TransparencyOld")
                    local target = (Settings.TransparentHiding and isHiding)
                        and Settings.HidingTransparency
                        or old
                    local previousTarget = part:GetAttribute("JuanmaBBB_TransparencyTarget")

                    if previousTarget == nil or math.abs(previousTarget - target) > 0.001 then
                        part:SetAttribute("JuanmaBBB_TransparencyTarget", target)
                        local tween = TweenService:Create(
                            part,
                            TweenInfo.new(0.25, Enum.EasingStyle.Linear),
                            {Transparency = target}
                        )
                        tween:Play()
                    end
                end
            end
        end
    end
end

local function V3ApplyCutsceneDisablers()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local mainUI = playerGui and playerGui:FindFirstChild("MainUI")
    local initiator = mainUI and mainUI:FindFirstChild("Initiator")
    local mainGame = initiator and initiator:FindFirstChild("Main_Game")
    local listener = mainGame and mainGame:FindFirstChild("RemoteListener")
    local cutscenes = listener and listener:FindFirstChild("Cutscenes")

    local function applyContainer(container)
        if not container then return end
        for _, object in ipairs(container:GetChildren()) do
            if object:IsA("ModuleScript") then
            local original = object:GetAttribute("JuanmaBBB_OriginalName")
                or object.Name:gsub("_Disabled$", "")

            if V3CutsceneNames[original] then
                if not object:GetAttribute("JuanmaBBB_OriginalName") then
                    object:SetAttribute("JuanmaBBB_OriginalName", original)
                end

                if Settings.RemoveCutscenes then
                    object.Name = original .. "_Disabled"
                elseif object.Name == original .. "_Disabled" then
                    object.Name = original
                end
            end
        end
    end
    end

    applyContainer(cutscenes)
    applyContainer(FloorReplicated)
end

local function V3DetectAndDisableEffects()
    if not (Settings.DisableGlitchJumpscare
        or Settings.DisableTimothyJumpscare
        or Settings.DisableVoidJumpscare
        or Settings.DisableEntityJumpscares
        or Settings.RemoveCutscenes) then
        return
    end

    if tick() - V3.LastClientModuleScan < 0.3 then return end
    V3.LastClientModuleScan = tick()

    V3ApplyJumpscareDisablers()
    V3ApplyCutsceneDisablers()
end

-- Dynamic V3 handling for newly-created jumpscare/cutscene modules.
Workspace.DescendantAdded:Connect(function(object)
    task.defer(function()
        if object:IsA("ModuleScript") then
            local original = object.Name:gsub("_Disabled$", "")
            if V3CutsceneNames[original] then
                pcall(function() object:SetAttribute("JuanmaBBB_OriginalName", original) end)
                if Settings.RemoveCutscenes then
                    object.Name = original .. "_Disabled"
                end
            elseif original:find("Jumpscare") and Settings.DisableEntityJumpscares then
                pcall(function() object:SetAttribute("JuanmaBBB_OriginalName", original) end)
                V3SetJumpscareDisabled(object, true)
            end
        end
    end)
end)

-- Supplied reference behavior for Eyes/Lookman used MotorReplication.
-- Keep it in a chained namecall hook when the executor exposes the API.
if has("hookmetamethod") and has("newcclosure") and has("getnamecallmethod") then
    pcall(function()
        local existing
        existing = ENV.hookmetamethod(game, "__namecall", ENV.newcclosure(function(self, ...)
            local args = {...}
            local method = ENV.getnamecallmethod()
            if method == "FireServer" and self and self.Name == "MotorReplication" then
                local eyesActive = Workspace:FindFirstChild("Eyes") ~= nil
                    or Workspace:FindFirstChild("Lookman") ~= nil
                local lookmanActive = Workspace:FindFirstChild("BackdoorLookman") ~= nil
                local bypass = (Settings.BypassEyes and eyesActive)
                    or (Settings.BypassLookman and lookmanActive)

                if bypass then
                    if Floor == "Fools" or Floor == "OldHotel" then
                        args[1] = 0
                        args[2] = -65
                        args[3] = 0
                        args[4] = false
                    else
                        args[1] = -650
                    end
                end
            end
            return existing(self, table.unpack(args))
        end))
    end)
end

-- Optional __index spoof for Rooms footsteps, matching the supplied
-- reference behavior when a metamethod API is present.
if has("hookmetamethod") and has("newcclosure") then
    pcall(function()
        local oldIndex
        oldIndex = ENV.hookmetamethod(game, "__index", ENV.newcclosure(function(self, property)
            local value = oldIndex(self, property)
            if self == Humanoid
            and property == "MoveDirection"
            and Settings.RoomsSpoofFootsteps
            and Settings.AutoRooms
            and Floor == "Rooms"
            and RootPart
            and Character
            and not Character:GetAttribute("Hiding") then
                return RootPart.CFrame.LookVector
            end
            return value
        end))
    end)
end

-- V3 completion loop.
RunService.RenderStepped:Connect(function()
    pcall(function()
        refreshReferences()
        V3ApplyClosetDelay()
        V3ApplyEyeLookmanBypass()
        V3ApplyVacuumBypass()
        V3RestoreVacuum()
        V3ApplyObstructionRemovals()
        V3MaintainInfiniteItems()
        V3ApplyESPFade()
        V3ApplyCameraSystems()
        V3ApplyVignetteAndFiredamp()
        V3ApplyHidingTransparency()
        V3ApplyCutsceneDisablers()
        V3DetectAndDisableEffects()
        V3ApplyRoomsFootstepSpoof()
    end)
end)

RunService.Heartbeat:Connect(function()
    pcall(V3ApplyKnobFarm)
end)

--==============================================================
-- V3 SETTINGS / FEATURE STATUS
--==============================================================

local V3StatusLabel = UI:Label(
    SettingsTab,
    "V3 advanced feature layer: ACTIVE",
    Theme.Green
)

UI:Section(SettingsTab, "V3 Completion")
UI:Label(SettingsTab, "Camera shake, camera bobbing, viewmodel offsets, third-person wall checks, spectating, jumpscare/cutscene suppression, obstruction removal, dynamic infinite-item parsing, Rooms footstep spoofing, and Knob Farm are wired in V3.", Theme.TextDim)

--==============================================================
-- END V3 FEATURE COMPLETION LAYER
--==============================================================

--==============================================================
-- GUI KEYBIND
--==============================================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    local key=Enum.KeyCode[Settings.Keybind]
    if key and input.KeyCode==key then
        local visible=UI.Main.Visible
        UI:SetVisible(not visible)
    end
end)

--==============================================================
-- CHARACTER STATE RESTORE / CLEANUP
--==============================================================

local cleanupDone=false
local function cleanup()
    if cleanupDone then return end
    cleanupDone=true

    for obj in pairs(ESP) do destroyESP(obj) end
    clearPath()
    for _,obj in ipairs(PathVisualFolder:GetChildren()) do obj:Destroy() end

    if Character then
        for _,part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and OriginalParts[part]~=nil then
                part.CanCollide=OriginalParts[part]
            end
        end
    end
    for _,prompt in ipairs(Objects.Prompts) do restorePrompt(prompt) end

    Lighting.Ambient=Original.Lighting.Ambient
    Lighting.Brightness=Original.Lighting.Brightness
    Lighting.GlobalShadows=Original.Lighting.GlobalShadows
    Lighting.FogEnd=Original.Lighting.FogEnd
    Lighting.ClockTime=Original.Lighting.ClockTime
    if Workspace.CurrentCamera then
        Workspace.CurrentCamera.FieldOfView=Original.FOV
        Workspace.CurrentCamera.CameraType=V3.CameraTypeBeforeSpectate or Enum.CameraType.Custom
    end
    LocalPlayer.CameraMinZoomDistance=Original.ZoomMin
    LocalPlayer.CameraMaxZoomDistance=Original.ZoomMax

    pcall(function()
        local mainGame = V3GetMainGame()
        if mainGame then
            mainGame.tooloffset = Vector3.zero
            mainGame.spring.Speed = 8
            mainGame.csgo = CFrame.new()
        end
    end)

    for object, original in pairs(V3.ObstructionTransforms) do
        if object and object.Parent then
            pcall(function()
                if original.kind == "model" then object:PivotTo(original.pivot)
                elseif original.kind == "part" then object.CFrame = original.cframe end
            end)
        end
    end

    for object, original in pairs(V3.FiredampOriginal) do
        if object and object.Parent then pcall(function() object:SetAttribute("Firedamp", original) end) end
    end

    for object, original in pairs(V3.DisabledVignette) do
        if object and object.Parent then pcall(function() object.ImageTransparency = original end) end
    end

    for object, original in pairs(V3.JumpscareOriginalNames) do
        if object and object.Parent then pcall(function() object.Name = original end) end
    end
    for object, original in pairs(V3.CutsceneOriginalNames) do
        if object and object.Parent then pcall(function() object.Name = original end) end
    end
end

if has("getgenv") then
    local genv=safe(ENV.getgenv)
    if type(genv)=="table" then
        if genv.JuanmaBBB_Hub_Cleanup then safe(genv.JuanmaBBB_Hub_Cleanup) end
        genv.JuanmaBBB_Hub_Cleanup=cleanup
        genv.JuanmaBBB_Hub=UI
    end
end

--==============================================================
-- INITIALIZATION
--==============================================================

UI:ApplyTheme()
hubNotify("JuanmaBBB Hub", "DOORS V3 loaded successfully.", 6, Accent())

print("[JuanmaBBB Hub] DOORS V3 loaded.")
print("[JuanmaBBB Hub] Floor:", Floor)
print("[JuanmaBBB Hub] fireproximityprompt:", has("fireproximityprompt"))
print("[JuanmaBBB Hub] hookmetamethod:", has("hookmetamethod"))

--==============================================================
-- END
--==============================================================

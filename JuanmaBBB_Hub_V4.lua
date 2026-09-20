local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

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

local Character
local Humanoid
local RootPart

local function updateCharacter()
    Character = LocalPlayer.Character
    if not Character then
        Humanoid = nil
        RootPart = nil
        return
    end
    Humanoid = Character:FindFirstChildOfClass("Humanoid")
    RootPart = Character:FindFirstChild("HumanoidRootPart")
end

updateCharacter()

LocalPlayer.CharacterAdded:Connect(function()
    task.wait()
    pcall(updateCharacter)
end)

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

local Defaults = {
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
    GuiTransparency = 0,
    AccentName = "Blue",
    Keybind = "RightShift",
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
    subtitle.Text = "DOORS V3  .  Client Utility"
    subtitle.TextColor3 = Theme.TextMute
    subtitle.TextSize = 9
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = header

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 125, 0, 18)
    status.Position = UDim2.new(1, -210, 0, 13)
    status.BackgroundTransparency = 1
    status.Text = "CONNECTED"
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
    minimize.Text = "_"
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
    close.Text = "X"
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
    button.Text = "  " .. (icon or ".") .. "  " .. name
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
    button.Text = tostring(chosen)
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
                button.Text = tostring(chosen)
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
    return {Set=function(v) chosen=v button.Text=tostring(v) end, Get=function() return chosen end}
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

local UI = Library
UI:CreateWindow()

local General = UI:CreateTab("General", ".")
local Exploits = UI:CreateTab("Exploits", ".")
local Visuals = UI:CreateTab("Visuals", ".")
local Floors = UI:CreateTab("Floors", ".")
local ItemsTab = UI:CreateTab("Items", ".")
local SettingsTab = UI:CreateTab("Settings", ".")
UI:SwitchTab(UI.Tabs[1])

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

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local TextChatService = game:GetService("TextChatService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

-- Clean up previous execution if active
if getgenv().KillScript then 
    pcall(getgenv().KillScript) 
end

-- Global Configs
getgenv().CurrentShape = 1
getgenv().OrbitRadius = 30 
getgenv().OrbitSpeed = 1.8
getgenv().OrbitCenterMode = "Player"
getgenv().IsDrawingActive = false

-- Music Player States
getgenv().MusicVolume = 1
getgenv().MusicPitch = 1
getgenv().MusicLoop = false
getgenv().MusicDistortion = false
getgenv().MusicBassBoost = 0

-- Track Current Active Music Instance Globally
local CurrentActiveMusicTrack = nil
local CurrentDistEffect = nil
local CurrentEqEffect = nil

-- Quotes List (Text and Texture ID)
local DefaultQuotes = {
    {Text = "DREAMS WILL NEVER COME TRUE UNTIL YOU ACTUALLY MAKE IT.", Texture = "12018318276"},
    {Text = "Well, it may be stupid, but it's also dumb.", Texture = "119158382516647"},
    {Text = "Can I have free Robux?", Texture = "12893647160"},
    {Text = "Join the discord!", Texture = "10367063073"},
    {Text = "Took me an hour and a half.", Texture = "10193284031"},
    {Text = "This item is currently not for sale.", Texture = "7477285966"},
    {Text = "You may not rest now, there are monsters nearby.", Texture = "9479554804"},
    {Text = "what are you doing, start executing these.", Texture = ""},
    {Text = "RIP Rec Room.", Texture = "4865462473"},
    {Text = "Baldi's basics is so tuff.", Texture = "133924791729577"},
    {Text = "kirkkyyyyyyyyyyy ", Texture = "103641508808101"},
    {Text = "Boi kirk mad  ", Texture = "87260097761237"},
    {Text = "STILL A W.I.P. PLEASE LEAVE COMMENTS ON SCRIPTBLOX/RSCRIPTS. TY <33333 ", Texture = "11709477759"},
}

-- Font Config (Audiowide Font)
local AudiowideFont = Font.new("rbxassetid://12187360881", Enum.FontWeight.Bold, Enum.FontStyle.Normal)

-- Asset Helper
local function formatAssetId(id)
    if not id or id == "" then return "" end
    local cleaned = tostring(id):gsub("%D", "")
    return "rbxassetid://" .. cleaned
end

-- Audio Helper
local function playSound(id, volume, pitch, loop)
    local s = Instance.new("Sound")
    s.SoundId = formatAssetId(id)
    s.Volume = volume or 1
    s.PlaybackSpeed = pitch or 1
    s.Looped = loop or false
    s.Parent = SoundService
    s:Play()
    if not loop then
        s.Ended:Connect(function()
            s:Destroy()
        end)
    end
    return s
end

-- Target Parent
local ParentTarget = (gethui and gethui()) or CoreGui

-- Core ScreenGui Root
local MainCoreGui = Instance.new("ScreenGui")
MainCoreGui.Name = "catware_CoreRoot"
MainCoreGui.ResetOnSpawn = false
MainCoreGui.Parent = ParentTarget

-- Helper for Text Outlines
local function addTextOutline(textLabel, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(0, 0, 0)
    stroke.Thickness = thickness or 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    stroke.Parent = textLabel
    return stroke
end

-- Mouse Cursor Config
local function setCustomCursor(enable)
    pcall(function()
        if enable then
            UIS.MouseIcon = formatAssetId("3197994757")
        else
            UIS.MouseIcon = ""
        end
    end)
end
setCustomCursor(true)

-- Notification System
local function sendNotification(title, message, isError)
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 260, 0, 58)
    notifFrame.Position = UDim2.new(1, 10, 1, -80)
    notifFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notifFrame.BackgroundTransparency = 0.5
    notifFrame.BorderSizePixel = 0
    notifFrame.Parent = MainCoreGui

    local corner = Instance.new("UICorner", notifFrame)
    corner.CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", notifFrame)
    stroke.Color = isError and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(0, 210, 255)
    stroke.Thickness = 1.2

    local titleLbl = Instance.new("TextLabel", notifFrame)
    titleLbl.Size = UDim2.new(1, -20, 0, 20)
    titleLbl.Position = UDim2.new(0, 10, 0, 5)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.FontFace = AudiowideFont
    titleLbl.TextSize = 14
    titleLbl.TextColor3 = stroke.Color
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    addTextOutline(titleLbl)

    local msgLbl = Instance.new("TextLabel", notifFrame)
    msgLbl.Size = UDim2.new(1, -20, 0, 26)
    msgLbl.Position = UDim2.new(0, 10, 0, 25)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Text = message
    msgLbl.FontFace = AudiowideFont
    msgLbl.TextSize = 12
    msgLbl.TextColor3 = Color3.fromRGB(230, 230, 240)
    msgLbl.TextWrapped = true
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    addTextOutline(msgLbl)

    if isError then
        playSound("129993339892259", 1)
    else
        playSound("117934611310434", 1)
    end

    TweenService:Create(notifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -275, 1, -80)
    }):Play()

    task.delay(3, function()
        local slideOut = TweenService:Create(notifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 10, 1, -80)
        })
        slideOut:Play()
        slideOut.Completed:Connect(function()
            notifFrame:Destroy()
        end)
    end)
end

-- Chat Hook
local function gameChat(msg)
    pcall(function()
        local general = TextChatService:FindFirstChild("RBXGeneral", true)
        if general and general:IsA("TextChannel") then
            general:SendAsync(msg)
        end
    end)
end

-- Slider Helper
local function createSlider(parent, labelText, minVal, maxVal, defaultVal, callback)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, -20, 0, 54)
    card.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    card.BackgroundTransparency = 0.5
    card.BorderSizePixel = 0

    local cardCorner = Instance.new("UICorner", card)
    cardCorner.CornerRadius = UDim.new(0, 8)

    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = Color3.fromRGB(60, 60, 80)
    cardStroke.Thickness = 1.2

    local header = Instance.new("Frame", card)
    header.Size = UDim2.new(1, -20, 0, 20)
    header.Position = UDim2.new(0, 10, 0, 6)
    header.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", header)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.FontFace = AudiowideFont
    label.TextXAlignment = Enum.TextXAlignment.Left
    addTextOutline(label)

    local valLabel = Instance.new("TextLabel", header)
    valLabel.Size = UDim2.new(0.4, 0, 1, 0)
    valLabel.Position = UDim2.new(0.6, 0, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(defaultVal)
    valLabel.TextColor3 = Color3.fromRGB(0, 210, 255)
    valLabel.TextSize = 13
    valLabel.FontFace = AudiowideFont
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    addTextOutline(valLabel)

    local container = Instance.new("TextButton", card)
    container.Size = UDim2.new(1, -20, 0, 12)
    container.Position = UDim2.new(0, 10, 0, 32)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    container.BackgroundTransparency = 0.3
    container.Text = ""
    container.AutoButtonColor = false

    local trackCorner = Instance.new("UICorner", container)
    trackCorner.CornerRadius = UDim.new(0, 6)

    local fill = Instance.new("Frame", container)
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 210, 255)
    fill.BorderSizePixel = 0

    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(0, 6)

    local knob = Instance.new("Frame", fill)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(1, -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0

    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(1, 0)

    local dragging = false

    local function updateSlider(input)
        local inputPos = input.Position.X
        local containerPos = container.AbsolutePosition.X
        local containerWidth = container.AbsoluteSize.X
        local rawPercentage = (inputPos - containerPos) / containerWidth
        local percentage = math.clamp(rawPercentage, 0, 1)

        local calculatedVal = minVal + (percentage * (maxVal - minVal))
        if maxVal <= 5 then
            calculatedVal = math.round(calculatedVal * 100) / 100
            valLabel.Text = string.format("%.2f", calculatedVal)
        else
            calculatedVal = math.round(calculatedVal)
            valLabel.Text = tostring(calculatedVal)
        end

        fill.Size = UDim2.new(percentage, 0, 1, 0)
        callback(calculatedVal)
    end

    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            TweenService:Create(cardStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(0, 210, 255)}):Play()
            updateSlider(input)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            TweenService:Create(cardStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(60, 60, 80)}):Play()
        end
    end)

    return card
end

-- Engine Calculations
local DrawMatrix = {
    {0,0,0,0,0}, {0,0,0,0,0}, {0,0,0,0,0}, {0,0,0,0,0}, {0,0,0,0,0}
}
local ActiveDrawOffsets = {}

local function CompileDrawingGrid()
    table.clear(ActiveDrawOffsets)
    local blockScale = 1.6
    local rawPoints = {}

    for rowIdx = 1, 5 do
        for colIdx = 1, 5 do
            if DrawMatrix[rowIdx][colIdx] == 1 then
                local x = colIdx * blockScale
                local y = (6 - rowIdx) * blockScale
                table.insert(rawPoints, Vector3.new(x, y, 0))
            end
        end
    end

    if #rawPoints > 0 then
        local minX, maxX = math.huge, -math.huge
        local minY, maxY = math.huge, -math.huge
        for _, pt in ipairs(rawPoints) do
            if pt.X < minX then minX = pt.X end
            if pt.X > maxX then maxX = pt.X end
            if pt.Y < minY then minY = pt.Y end
            if pt.Y > maxY then maxY = pt.Y end
        end
        local midX = (minX + maxX) / 2
        local midY = (minY + maxY) / 2
        for _, pt in ipairs(rawPoints) do
            table.insert(ActiveDrawOffsets, Vector3.new(pt.X - midX, (pt.Y - midY) + 7.0, 0))
        end
    end
end

local ShapesData = {
    {Name = "Ring"}, {Name = "Pulse"}, {Name = "Wave"}, {Name = "Infinity"}, {Name = "Random Circle"}
}

-- Catalog Data
local CustomHatsData = {
    -- Random Hats
    {Id = "14000549505", Name = "Goofy Cat", Category = "Random Hats"},
    {Id = "101473595112174", Name = "Nyan Cat", Category = "Random Hats"},
    {Id = "121626981329735", Name = "Dance Cat", Category = "Random Hats"},
    {Id = "88324123737356", Name = "Spongebob", Category = "Random Hats"},
    {Id = "101040976443246", Name = "Minion Stare", Category = "Random Hats"},
    {Id = "124881029836545", Name = "Noob", Category = "Random Hats"},
    {Id = "90785076247512", Name = "Naked Patrick", Category = "Random Hats"},
    {Id = "12011151706", Name = "Rainstorm Rain", Category = "Random Hats"},
    {Id = "90170504791570", Name = "Discord Ping", Category = "Random Hats"},
    {Id = "139294260048804", Name = "Slug Shady", Category = "Random Hats"},
    {Id = "125747082775861", Name = "Job App", Category = "Random Hats"},
    {Id = "103216701488697", Name = "Slot Machine", Category = "Random Hats"},
    {Id = "93819370291488", Name = "Baldi", Category = "Random Hats"},

    -- Horror
    {Id = "85901474083461", Name = "Jeff Killer", Category = "Horror"},
    {Id = "105192845336531", Name = "Scary Face", Category = "Horror"},
    {Id = "105379230987587", Name = "Boiled One", Category = "Horror"},
    {Id = "124711065696379", Name = "Scary Intruder", Category = "Horror"},
    {Id = "93495686922596", Name = "Tall Figure Box", Category = "Horror"},
    {Id = "76954242113709", Name = "Smiling White Guy", Category = "Horror"},
    {Id = "79361557807090", Name = "The Boy And The Bath", Category = "Horror"},
    {Id = "72576161406957", Name = "Boiled One TV", Category = "Horror"},
    {Id = "134397592895870", Name = "Russian Sleep Experiment", Category = "Horror"},

    -- Particles
    {Id = "187998056", Name = "Snow Queens Necklace", Category = "Particles"},
    {Id = "128217885", Name = "Fall Fairy", Category = "Particles"},
    {Id = "150381051", Name = "Spring Fairy", Category = "Particles"},
    {Id = "226189871", Name = "St Patricks Day Fairy", Category = "Particles"},
    {Id = "141742418", Name = "Winter Fairy", Category = "Particles"},
    {Id = "191101707", Name = "Flaming Mohawk", Category = "Particles"},
    {Id = "192557913", Name = "Sparkling Angel Wings", Category = "Particles"},
    {Id = "2413964589", Name = "Ghost Back Lantern", Category = "Particles"},
    {Id = "2910992580", Name = "Pot of Gold Backpack", Category = "Particles"},
    {Id = "10159606132", Name = "8 Bit Extra Life", Category = "Particles"},
    {Id = "4416812356", Name = "Davy Bazooka Bazooka", Category = "Particles"},
    {Id = "10159622004", Name = "8 Bit Roblox Coin", Category = "Particles"},
    {Id = "10159617728", Name = "8 Bit Tabby Cat", Category = "Particles"},
    {Id = "10159610478", Name = "8 Bit HP Bar", Category = "Particles"},
    {Id = "132809431", Name = "Doomsekkar", Category = "Particles"},
    {Id = "280661926", Name = "Mystical Staff Lightning Magic", Category = "Particles"},
    {Id = "2180258728", Name = "Gilded Triad Crown", Category = "Particles"},
    {Id = "173624749", Name = "Red Banded Boss White Hat", Category = "Particles"},
    {Id = "183468963", Name = "Ghosdeeri", Category = "Particles"},
    {Id = "8666557244", Name = "Golden Cursed Flames", Category = "Particles"},
    {Id = "3756389957", Name = "Cursed Flames", Category = "Particles"},
    {Id = "17266431441", Name = "Zesty Orange Head", Category = "Particles"},
    {Id = "153059501", Name = "Egg of Destiny", Category = "Particles"},
    {Id = "16088338699", Name = "Lavender Metallic Bucket Hat", Category = "Particles"},
    {Id = "417456127", Name = "Golden Sparkling Wings", Category = "Particles"}
}

-- Preset Songs List
local PresetSongs = {
    {Name = "Relaxed Scene", Id = "1848354536", Pitch = 1.0},
    {Name = "Raining Tacos", Id = "142376088", Pitch = 1.0},
    {Name = "Old Roblox Song Fanmade", Id = "103502836672744", Pitch = 1.0},
    {Name = "Stadium Rave", Id = "1846368080", Pitch = 1.0},
    {Name = "Better Off Alone", Id = "87694750844457", Pitch = 0.316}
}

local LoopNetless = nil
local LoopMovement = nil
local KeybindConnection = nil

local function SetupHatsEngine()
    if LoopNetless then LoopNetless:Disconnect() end
    if LoopMovement then LoopMovement:Disconnect() end

    LoopNetless = RunService.Heartbeat:Connect(function()
        pcall(function()
            sethiddenproperty(LocalPlayer, "SimulationRadius", 2147483647)
            sethiddenproperty(LocalPlayer, "MaximumSimulationRadius", 2147483647)
        end)
    end)

    LoopMovement = RunService.Heartbeat:Connect(function(deltaTime)
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local clock = os.clock() * getgenv().OrbitSpeed
        local rad = getgenv().OrbitRadius
        local activeHats = {}

        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Accessory") then
                local handle = item:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then
                    for _, obj in ipairs(handle:GetChildren()) do
                        if obj:IsA("Weld") or obj:IsA("ManualWeld") or obj:IsA("WeldConstraint") then
                            obj:Destroy()
                        end
                    end
                    for _, desc in ipairs(handle:GetDescendants()) do
                        if desc:IsA("ParticleEmitter") or desc:IsA("Sparkles") or desc:IsA("Fire") or desc:IsA("Light") then
                            desc.Enabled = true
                        end
                    end
                    handle.CanCollide = false
                    table.insert(activeHats, handle)
                end
            end
        end

        local total = #activeHats
        local center = (getgenv().OrbitCenterMode == "Map") and Vector3.new(0, 4, 0) or root.Position

        for index, handle in ipairs(activeHats) do
            local myAtt = handle:FindFirstChild("EngineAtt0") or Instance.new("Attachment", handle)
            myAtt.Name = "EngineAtt0"
            
            local worldAtt = workspace.Terrain:FindFirstChild("EngineAttW_" .. handle.Name .. "_" .. index) or Instance.new("Attachment", workspace.Terrain)
            worldAtt.Name = "EngineAttW_" .. handle.Name .. "_" .. index

            local alignPos = handle:FindFirstChild("EnginePos") or Instance.new("AlignPosition", handle)
            alignPos.Name = "EnginePos"
            alignPos.Attachment0 = myAtt
            alignPos.Attachment1 = worldAtt
            alignPos.MaxForce = math.huge          
            alignPos.MaxVelocity = math.huge          
            alignPos.Responsiveness = 200       

            local alignRot = handle:FindFirstChild("EngineRot") or Instance.new("AlignOrientation", handle)
            alignRot.Name = "EngineRot"
            alignRot.Attachment0 = myAtt
            alignRot.Attachment1 = worldAtt
            alignRot.MaxTorque = math.huge
            alignRot.MaxAngularVelocity = math.huge
            alignRot.Responsiveness = 200

            local offset = Vector3.new(0, 0, 0)

            if getgenv().IsDrawingActive then
                if #ActiveDrawOffsets > 0 then
                    local offsetIdx = ((index - 1) % #ActiveDrawOffsets) + 1
                    offset = ActiveDrawOffsets[offsetIdx]
                else
                    offset = Vector3.new(0, 4, 0)
                end
            else
                if getgenv().CurrentShape == 1 then
                    local angle = (index * (math.pi * 2 / math.max(total, 1))) + clock
                    offset = Vector3.new(math.cos(angle) * rad, 1.5, math.sin(angle) * rad)
                elseif getgenv().CurrentShape == 2 then
                    local pulseRad = rad * (0.6 + 0.4 * math.sin(clock * 2.5))
                    local phi = math.acos(1 - 2 * (index / math.max(total, 1)))
                    local theta = math.sqrt(math.max(total, 1) * math.pi) * phi + clock
                    offset = Vector3.new(pulseRad * math.sin(phi) * math.cos(theta), (pulseRad * math.cos(phi)) + 2, pulseRad * math.sin(phi) * math.sin(theta))
                elseif getgenv().CurrentShape == 3 then
                    local cols = 5
                    local spacing = math.max(rad * 0.35, 3)
                    local gridX = ((index - 1) % cols) * spacing - ((cols - 1) * spacing * 0.5)
                    local gridZ = math.floor((index - 1) / cols) * spacing - ((cols - 1) * spacing * 0.5)
                    local waveY = math.sin(clock * 2 + (gridX * 0.2) + (gridZ * 0.2)) * (rad * 0.15) + 2
                    offset = Vector3.new(gridX, waveY, gridZ)
                elseif getgenv().CurrentShape == 4 then
                    local t = clock + (index * 0.3)
                    local scale = rad * 0.7
                    local x = scale * math.sin(t) / (1 + math.cos(t)^2)
                    local z = scale * math.sin(t) * math.cos(t) / (1 + math.cos(t)^2)
                    offset = Vector3.new(x, 1.8, z)
                elseif getgenv().CurrentShape == 5 then
                    local angle = (index * (math.pi * 2 / math.max(total, 1))) + clock
                    local tilt = math.sin(clock * 0.5) * 0.3
                    offset = Vector3.new(math.cos(angle) * rad, 1.5 + (math.sin(angle) * rad * tilt), math.sin(angle) * rad)
                end
            end
            
            worldAtt.WorldPosition = center + offset
            worldAtt.WorldCFrame = CFrame.new(center + offset)
            handle.AssemblyLinearVelocity = Vector3.new(0, 45, 0)
        end
    end)
end

local function LoadPackSafe(idString, desiredAmount)
    desiredAmount = desiredAmount or 22
    getgenv().IsDrawingActive = false
    SetupHatsEngine()

    local maxPerMessage = 4 
    local loops = math.ceil(desiredAmount / maxPerMessage)
    
    task.spawn(function()
        for l = 1, loops do
            if getgenv().IsDrawingActive then break end
            local countThisLoop = math.min(maxPerMessage, desiredAmount - ((l - 1) * maxPerMessage))
            local buildCmd = "-gh " .. string.rep(idString .. " ", countThisLoop)
            gameChat(buildCmd)
            if l == 1 then task.delay(0.6, function() gameChat("-net") end) end
            task.wait(1.2)
        end
        sendNotification("catware", "Loaded " .. desiredAmount .. " hats successfully!", false)
    end)
end

-- Shared Reset Character
local function triggerResetCharacter()
    local redScreen = Instance.new("Frame", MainCoreGui)
    redScreen.Size = UDim2.new(1, 0, 1, 0)
    redScreen.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    redScreen.BackgroundTransparency = 0.4
    redScreen.ZIndex = 10

    playSound("140153453307373", 1)

    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").Health = 0
    end

    local conn
    conn = LocalPlayer.CharacterAdded:Connect(function()
        conn:Disconnect()
        TweenService:Create(redScreen, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        redScreen:Destroy()
    end)
end

-- Bottom Left Screen Dynamic Overlay
local function SetupBottomLeftOverlay()
    local container = Instance.new("Frame", MainCoreGui)
    container.Size = UDim2.new(0, 200, 0, 60)
    container.Position = UDim2.new(0, 15, 1, -75)
    container.BackgroundTransparency = 1

    local transparentIcon = Instance.new("ImageLabel", container)
    transparentIcon.Size = UDim2.new(0, 36, 0, 36)
    transparentIcon.Position = UDim2.new(0, 5, 0.5, -18)
    transparentIcon.BackgroundTransparency = 1
    transparentIcon.Image = formatAssetId("12867731772")
    transparentIcon.ImageTransparency = 0.4

    local lineFrame = Instance.new("ImageLabel", transparentIcon)
    lineFrame.Size = UDim2.new(1, 16, 1, 16)
    lineFrame.Position = UDim2.new(0, -8, 0, -8)
    lineFrame.BackgroundTransparency = 1
    lineFrame.Image = formatAssetId("88999007032010")

    local spinningLine = Instance.new("ImageLabel", lineFrame)
    spinningLine.Size = UDim2.new(1, 0, 1, 0)
    spinningLine.BackgroundTransparency = 1
    spinningLine.Image = formatAssetId("7203914610")

    local nameLbl = Instance.new("TextLabel", container)
    nameLbl.Size = UDim2.new(0, 120, 0, 30)
    nameLbl.Position = UDim2.new(0, 52, 0.5, -15)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = "catware."
    nameLbl.FontFace = AudiowideFont
    nameLbl.TextSize = 16
    nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    addTextOutline(nameLbl)

    RunService.RenderStepped:Connect(function(dt)
        spinningLine.Rotation = (spinningLine.Rotation + (dt * 90)) % 360
    end)
end

-- Centralized Music Player Audio Controller
local function applyAudioEffects()
    if not CurrentActiveMusicTrack then return end

    CurrentActiveMusicTrack.Looped = getgenv().MusicLoop

    if getgenv().MusicDistortion then
        if not CurrentDistEffect or CurrentDistEffect.Parent ~= CurrentActiveMusicTrack then
            CurrentDistEffect = Instance.new("DistortionSoundEffect", CurrentActiveMusicTrack)
            CurrentDistEffect.Level = 0.75
        end
    else
        if CurrentDistEffect then CurrentDistEffect:Destroy() CurrentDistEffect = nil end
    end

    if getgenv().MusicBassBoost > 0 then
        if not CurrentEqEffect or CurrentEqEffect.Parent ~= CurrentActiveMusicTrack then
            CurrentEqEffect = Instance.new("EqualizerSoundEffect", CurrentActiveMusicTrack)
        end
        CurrentEqEffect.LowGain = getgenv().MusicBassBoost * 10
        CurrentEqEffect.MidGain = 0
        CurrentEqEffect.HighGain = 0
    else
        if CurrentEqEffect then CurrentEqEffect:Destroy() CurrentEqEffect = nil end
    end
end

local function playMusicTrack(id, pitchOverride)
    if CurrentActiveMusicTrack then
        CurrentActiveMusicTrack:Stop()
        CurrentActiveMusicTrack:Destroy()
        CurrentActiveMusicTrack = nil
    end

    if CurrentDistEffect then CurrentDistEffect:Destroy() CurrentDistEffect = nil end
    if CurrentEqEffect then CurrentEqEffect:Destroy() CurrentEqEffect = nil end

    if pitchOverride then
        getgenv().MusicPitch = pitchOverride
    end

    CurrentActiveMusicTrack = playSound(id, getgenv().MusicVolume, getgenv().MusicPitch, getgenv().MusicLoop)
    applyAudioEffects()
end

-- Main Application UI Construction
local function BuildMainHubUI()
    SetupBottomLeftOverlay()

    local MainFrame = Instance.new("ImageLabel", MainCoreGui)
    MainFrame.Name = "MainHubFrame"
    MainFrame.Size = UDim2.new(0, 700, 0, 360)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -180)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    MainFrame.Image = formatAssetId("12814390523")
    MainFrame.ScaleType = Enum.ScaleType.Crop
    MainFrame.Active = true
    MainFrame.ClipsDescendants = true

    local mainCorner = Instance.new("UICorner", MainFrame)
    mainCorner.CornerRadius = UDim.new(0, 10)

    local mainStroke = Instance.new("UIStroke", MainFrame)
    mainStroke.Color = Color3.fromRGB(45, 45, 60)
    mainStroke.Thickness = 1.2

    local mainBgOverlay = Instance.new("Frame", MainFrame)
    mainBgOverlay.Size = UDim2.new(1, 0, 1, 0)
    mainBgOverlay.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    mainBgOverlay.BackgroundTransparency = 0.25
    mainBgOverlay.ZIndex = 0

    local mainBgCorner = Instance.new("UICorner", mainBgOverlay)
    mainBgCorner.CornerRadius = UDim.new(0, 10)

    -- Top Selection Status Bar
    local TopStatusBar = Instance.new("TextLabel", MainFrame)
    TopStatusBar.Size = UDim2.new(0, 250, 0, 22)
    TopStatusBar.Position = UDim2.new(0.68, -125, 0, 8)
    TopStatusBar.BackgroundTransparency = 1
    TopStatusBar.Text = "Selected: None"
    TopStatusBar.FontFace = AudiowideFont
    TopStatusBar.TextSize = 12
    TopStatusBar.TextColor3 = Color3.fromRGB(0, 210, 255)
    TopStatusBar.ZIndex = 6
    addTextOutline(TopStatusBar)

    -- Window Controls
    local ControlsContainer = Instance.new("Frame", MainFrame)
    ControlsContainer.Size = UDim2.new(0, 60, 0, 24)
    ControlsContainer.Position = UDim2.new(1, -68, 0, 8)
    ControlsContainer.BackgroundTransparency = 1
    ControlsContainer.ZIndex = 6

    local minBtn = Instance.new("TextButton", ControlsContainer)
    minBtn.Size = UDim2.new(0, 24, 0, 24)
    minBtn.Position = UDim2.new(0, 0, 0, 0)
    minBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    minBtn.BackgroundTransparency = 0.5
    minBtn.Text = "_"
    minBtn.FontFace = AudiowideFont
    minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    minBtn.TextSize = 12

    local minCorner = Instance.new("UICorner", minBtn)
    minCorner.CornerRadius = UDim.new(0, 6)

    local closeBtn = Instance.new("TextButton", ControlsContainer)
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(0, 30, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    closeBtn.BackgroundTransparency = 0.5
    closeBtn.Text = "X"
    closeBtn.FontFace = AudiowideFont
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.TextSize = 12

    local closeCorner = Instance.new("UICorner", closeBtn)
    closeCorner.CornerRadius = UDim.new(0, 6)

    minBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)

    closeBtn.MouseButton1Click:Connect(function()
        if getgenv().KillScript then getgenv().KillScript() end
    end)

    -- Header & Logo Area
    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 44)
    Header.BackgroundTransparency = 1
    Header.ZIndex = 5

    local isDraggingUI = false
    local dragInput, dragStart, startPos

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingUI = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDraggingUI = false
                end
            end)
        end
    end)

    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and isDraggingUI then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Top Logo Icon
    local TopLogo = Instance.new("ImageLabel", Header)
    TopLogo.Size = UDim2.new(0, 32, 0, 32)
    TopLogo.Position = UDim2.new(0, 10, 0.5, -16)
    TopLogo.BackgroundTransparency = 1
    TopLogo.Image = formatAssetId("6998029717")

    -- Cleaned Logo Text: "catware."
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 48, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "catware."
    Title.FontFace = AudiowideFont
    Title.TextSize = 17
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    addTextOutline(Title)

    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 150, 1, -44)
    Sidebar.Position = UDim2.new(0, 0, 0, 44)
    Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    Sidebar.BackgroundTransparency = 0.2
    Sidebar.ClipsDescendants = true
    Sidebar.ZIndex = 4

    local SidebarCorner = Instance.new("UICorner", Sidebar)
    SidebarCorner.CornerRadius = UDim.new(0, 10)

    local SidebarToggleBtn = Instance.new("ImageButton", Header)
    SidebarToggleBtn.Size = UDim2.new(0, 22, 0, 22)
    SidebarToggleBtn.Position = UDim2.new(1, -98, 0.5, -11)
    SidebarToggleBtn.BackgroundTransparency = 1
    SidebarToggleBtn.Image = formatAssetId("16377232199")

    local sidebarExpanded = true
    SidebarToggleBtn.MouseButton1Click:Connect(function()
        sidebarExpanded = not sidebarExpanded
        local targetWidth = sidebarExpanded and 150 or 0
        local targetContentPos = sidebarExpanded and 165 or 15
        local targetContentWidth = sidebarExpanded and 520 or 670

        TweenService:Create(Sidebar, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(0, targetWidth, 1, -44)}):Play()
        local contentFrame = MainFrame:FindFirstChild("ContentContainer")
        if contentFrame then
            TweenService:Create(contentFrame, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, targetContentPos, 0, 46),
                Size = UDim2.new(0, targetContentWidth, 1, -54)
            }):Play()
        end
    end)

    local ContentContainer = Instance.new("Frame", MainFrame)
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(0, 520, 1, -54)
    ContentContainer.Position = UDim2.new(0, 165, 0, 46)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ClipsDescendants = true
    ContentContainer.ZIndex = 2

    local currentTabIndex = 1
    local activeTabName = "Home"
    local selectedHatCategory = nil
    local customHatAmount = 22
    local tabs = {"Home", "Shapes", "Hats", "Music Player", "Discord", "Drawing"}
    local tabButtons = {}

    -- Typewriter Thread Management
    local typewriterThread = nil

    local function stopTypewriter()
        if typewriterThread then
            task.cancel(typewriterThread)
            typewriterThread = nil
        end
    end

    local function SwitchTab(tabName, index)
        if index < currentTabIndex then
            playSound("97317270315309", 0.8)
        elseif index > currentTabIndex then
            playSound("139533759532534", 0.8)
        end
        currentTabIndex = index
        activeTabName = tabName

        stopTypewriter()

        ContentContainer:ClearAllChildren()

        if tabName == "Discord" then
            playSound("121092491767361", 0.8)
            TweenService:Create(mainBgOverlay, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(88, 101, 242), 
                BackgroundTransparency = 0.35
            }):Play()
        else
            TweenService:Create(mainBgOverlay, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(15, 15, 18), 
                BackgroundTransparency = 0.25
            }):Play()
        end

        for i, btn in ipairs(tabButtons) do
            btn.TextColor3 = (i == index) and Color3.fromRGB(0, 210, 255) or Color3.fromRGB(180, 180, 180)
        end

        if tabName == "Home" then
            local pfp = Instance.new("ImageLabel", ContentContainer)
            pfp.Size = UDim2.new(0, 60, 0, 60)
            pfp.Position = UDim2.new(0, 10, 0, 8)
            pfp.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            pfp.BackgroundTransparency = 0.5

            pcall(function()
                pfp.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            end)

            local pfpCorner = Instance.new("UICorner", pfp)
            pfpCorner.CornerRadius = UDim.new(0, 30)

            local welcomeLbl = Instance.new("TextLabel", ContentContainer)
            welcomeLbl.Size = UDim2.new(1, -85, 0, 22)
            welcomeLbl.Position = UDim2.new(0, 80, 0, 8)
            welcomeLbl.BackgroundTransparency = 1
            welcomeLbl.Text = "Hello @" .. LocalPlayer.Name .. ", Glad your using this."
            welcomeLbl.FontFace = AudiowideFont
            welcomeLbl.TextSize = 13
            welcomeLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            welcomeLbl.TextXAlignment = Enum.TextXAlignment.Left
            addTextOutline(welcomeLbl)

            local timeLbl = Instance.new("TextLabel", ContentContainer)
            timeLbl.Size = UDim2.new(1, -85, 0, 18)
            timeLbl.Position = UDim2.new(0, 80, 0, 30)
            timeLbl.BackgroundTransparency = 1
            timeLbl.FontFace = AudiowideFont
            timeLbl.TextSize = 11
            timeLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
            timeLbl.TextXAlignment = Enum.TextXAlignment.Left
            addTextOutline(timeLbl)

            task.spawn(function()
                while timeLbl.Parent and activeTabName == "Home" do
                    timeLbl.Text = "Time: " .. os.date("%X")
                    task.wait(1)
                end
            end)

            local execName = (identifyexecutor and identifyexecutor()) or "Unknown Executor"
            local execLbl = Instance.new("TextLabel", ContentContainer)
            execLbl.Size = UDim2.new(1, -85, 0, 18)
            execLbl.Position = UDim2.new(0, 80, 0, 48)
            execLbl.BackgroundTransparency = 1
            execLbl.Text = "Executor: " .. execName
            execLbl.FontFace = AudiowideFont
            execLbl.TextSize = 11
            execLbl.TextColor3 = Color3.fromRGB(0, 210, 255)
            execLbl.TextXAlignment = Enum.TextXAlignment.Left
            addTextOutline(execLbl)

            -- Dynamic Quote Container Box
            local quoteBox = Instance.new("Frame", ContentContainer)
            quoteBox.Name = "QuoteBox"
            quoteBox.Size = UDim2.new(1, -20, 0, 65)
            quoteBox.Position = UDim2.new(0, 10, 0, 85)
            quoteBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            quoteBox.BackgroundTransparency = 0.5
            quoteBox.BorderSizePixel = 0
            quoteBox.AutomaticSize = Enum.AutomaticSize.Y

            local quoteCorner = Instance.new("UICorner", quoteBox)
            quoteCorner.CornerRadius = UDim.new(0, 8)

            local quoteStroke = Instance.new("UIStroke", quoteBox)
            quoteStroke.Color = Color3.fromRGB(0, 210, 255)
            quoteStroke.Thickness = 1.2

            -- Optional Quote Texture Icon
            local quoteIcon = Instance.new("ImageLabel", quoteBox)
            quoteIcon.Name = "QuoteIcon"
            quoteIcon.Size = UDim2.new(0, 32, 0, 32)
            quoteIcon.Position = UDim2.new(0, 10, 0, 10)
            quoteIcon.BackgroundTransparency = 1
            quoteIcon.Visible = false

            local quoteTextLbl = Instance.new("TextLabel", quoteBox)
            quoteTextLbl.Name = "QuoteTextLbl"
            quoteTextLbl.Size = UDim2.new(1, -20, 0, 0)
            quoteTextLbl.Position = UDim2.new(0, 10, 0, 10)
            quoteTextLbl.BackgroundTransparency = 1
            quoteTextLbl.Text = ""
            quoteTextLbl.FontFace = AudiowideFont
            quoteTextLbl.TextSize = 13
            quoteTextLbl.TextColor3 = Color3.fromRGB(230, 230, 245)
            quoteTextLbl.TextWrapped = true
            quoteTextLbl.TextXAlignment = Enum.TextXAlignment.Left
            quoteTextLbl.AutomaticSize = Enum.AutomaticSize.Y
            addTextOutline(quoteTextLbl)

            -- Reset Character Button
            local resetBtn = Instance.new("TextButton", ContentContainer)
            resetBtn.Size = UDim2.new(0, 150, 0, 30)
            resetBtn.Position = UDim2.new(0, 10, 1, -40)
            resetBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            resetBtn.BackgroundTransparency = 0.5
            resetBtn.Text = "Reset Character"
            resetBtn.FontFace = AudiowideFont
            resetBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
            resetBtn.TextSize = 12
            addTextOutline(resetBtn)

            local resetCorner = Instance.new("UICorner", resetBtn)
            resetCorner.CornerRadius = UDim.new(0, 6)

            local resetStroke = Instance.new("UIStroke", resetBtn)
            resetStroke.Color = Color3.fromRGB(180, 40, 40)
            resetStroke.Thickness = 1.2

            resetBtn.MouseButton1Click:Connect(triggerResetCharacter)

            -- Start Continuous Typewriter Thread with Custom Textures (Sequential Order)
            typewriterThread = task.spawn(function()
                local quoteIndex = 1
                while activeTabName == "Home" do
                    local selectedData = DefaultQuotes[quoteIndex]
                    local currentQuote = selectedData.Text
                    local currentTexture = selectedData.Texture

                    -- Increment index sequentially and loop back to 1 when reaching the end
                    quoteIndex = (quoteIndex % #DefaultQuotes) + 1

                    if currentTexture and currentTexture ~= "" then
                        quoteIcon.Image = formatAssetId(currentTexture)
                        quoteIcon.Visible = true
                        quoteTextLbl.Position = UDim2.new(0, 50, 0, 10)
                        quoteTextLbl.Size = UDim2.new(1, -60, 0, 0)
                    else
                        quoteIcon.Visible = false
                        quoteTextLbl.Position = UDim2.new(0, 10, 0, 10)
                        quoteTextLbl.Size = UDim2.new(1, -20, 0, 0)
                    end

                    -- Typewriter Effect
                    for i = 1, #currentQuote do
                        if activeTabName ~= "Home" then break end
                        quoteTextLbl.Text = string.sub(currentQuote, 1, i) .. "|"
                        task.wait(0.04)
                    end

                    if activeTabName ~= "Home" then break end

                    -- Blinking Cursor
                    for _ = 1, 5 do
                        if activeTabName ~= "Home" then break end
                        quoteTextLbl.Text = currentQuote .. "|"
                        task.wait(0.25)
                        if activeTabName ~= "Home" then break end
                        quoteTextLbl.Text = currentQuote
                        task.wait(0.25)
                    end

                    if activeTabName ~= "Home" then break end

                    -- Backspace / Delete
                    for i = #currentQuote, 0, -1 do
                        if activeTabName ~= "Home" then break end
                        quoteTextLbl.Text = string.sub(currentQuote, 1, i) .. "|"
                        task.wait(0.02)
                    end

                    if activeTabName ~= "Home" then break end
                    quoteTextLbl.Text = ""
                    task.wait(0.4)
                end
            end)

        elseif tabName == "Shapes" then
            createSlider(ContentContainer, "Radius", 0, 150, getgenv().OrbitRadius, function(val)
                getgenv().OrbitRadius = val
            end).Position = UDim2.new(0, 10, 0, 5)

            createSlider(ContentContainer, "Speed", 0.2, 5.0, getgenv().OrbitSpeed, function(val)
                getgenv().OrbitSpeed = val
            end).Position = UDim2.new(0, 10, 0, 64)

            for i, shape in ipairs(ShapesData) do
                local btn = Instance.new("TextButton", ContentContainer)
                btn.Size = UDim2.new(1, -20, 0, 32)
                btn.Position = UDim2.new(0, 10, 0, 126 + ((i - 1) * 36))
                btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                btn.BackgroundTransparency = 0.5
                btn.Text = "    " .. shape.Name
                btn.FontFace = AudiowideFont
                btn.TextSize = 13
                btn.TextColor3 = (getgenv().CurrentShape == i) and Color3.fromRGB(0, 210, 255) or Color3.fromRGB(255, 255, 255)
                btn.TextXAlignment = Enum.TextXAlignment.Left
                addTextOutline(btn)

                local btnCorner = Instance.new("UICorner", btn)
                btnCorner.CornerRadius = UDim.new(0, 6)

                local btnStroke = Instance.new("UIStroke", btn)
                btnStroke.Color = (getgenv().CurrentShape == i) and Color3.fromRGB(0, 210, 255) or Color3.fromRGB(60, 60, 80)
                btnStroke.Thickness = 1.2

                btn.MouseButton1Click:Connect(function()
                    getgenv().IsDrawingActive = false
                    getgenv().CurrentShape = i
                    SwitchTab("Shapes", index)
                end)
            end

        elseif tabName == "Hats" then
            local Categories = {"Random Hats", "Horror", "Particles"}

            local resetHatBtn = Instance.new("TextButton", ContentContainer)
            resetHatBtn.Size = UDim2.new(0, 140, 0, 28)
            resetHatBtn.Position = UDim2.new(1, -150, 0, 5)
            resetHatBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            resetHatBtn.BackgroundTransparency = 0.5
            resetHatBtn.Text = "Reset Character"
            resetHatBtn.FontFace = AudiowideFont
            resetHatBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
            resetHatBtn.TextSize = 11
            addTextOutline(resetHatBtn)

            local resetHatCorner = Instance.new("UICorner", resetHatBtn)
            resetHatCorner.CornerRadius = UDim.new(0, 6)

            local resetHatStroke = Instance.new("UIStroke", resetHatBtn)
            resetHatStroke.Color = Color3.fromRGB(180, 40, 40)
            resetHatStroke.Thickness = 1.2

            resetHatBtn.MouseButton1Click:Connect(triggerResetCharacter)

            if selectedHatCategory == nil then
                local promptLbl = Instance.new("TextLabel", ContentContainer)
                promptLbl.Size = UDim2.new(0, 200, 0, 28)
                promptLbl.Position = UDim2.new(0, 10, 0, 5)
                promptLbl.BackgroundTransparency = 1
                promptLbl.Text = "Which Category?"
                promptLbl.FontFace = AudiowideFont
                promptLbl.TextSize = 15
                promptLbl.TextColor3 = Color3.fromRGB(0, 210, 255)
                promptLbl.TextXAlignment = Enum.TextXAlignment.Left
                addTextOutline(promptLbl)

                for i, catName in ipairs(Categories) do
                    local btn = Instance.new("TextButton", ContentContainer)
                    btn.Size = UDim2.new(1, -20, 0, 32)
                    btn.Position = UDim2.new(0, 10, 0, 38 + ((i - 1) * 36))
                    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    btn.BackgroundTransparency = 0.5
                    btn.Text = "    " .. catName
                    btn.FontFace = AudiowideFont
                    btn.TextSize = 13
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.TextXAlignment = Enum.TextXAlignment.Left
                    addTextOutline(btn)

                    local btnCorner = Instance.new("UICorner", btn)
                    btnCorner.CornerRadius = UDim.new(0, 6)

                    local btnStroke = Instance.new("UIStroke", btn)
                    btnStroke.Color = Color3.fromRGB(60, 60, 80)
                    btnStroke.Thickness = 1.2

                    btn.MouseButton1Click:Connect(function()
                        selectedHatCategory = catName
                        SwitchTab("Hats", index)
                    end)
                end

                -- Custom ID Loading Panel
                local customBox = Instance.new("TextBox", ContentContainer)
                customBox.Size = UDim2.new(1, -20, 0, 32)
                customBox.Position = UDim2.new(0, 10, 0, 152)
                customBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                customBox.BackgroundTransparency = 0.5
                customBox.PlaceholderText = "Enter Custom Hat ID"
                customBox.Text = ""
                customBox.FontFace = AudiowideFont
                customBox.TextSize = 12
                customBox.TextColor3 = Color3.fromRGB(255, 255, 255)

                local customBoxCorner = Instance.new("UICorner", customBox)
                customBoxCorner.CornerRadius = UDim.new(0, 6)

                local customBoxStroke = Instance.new("UIStroke", customBox)
                customBoxStroke.Color = Color3.fromRGB(60, 60, 80)
                customBoxStroke.Thickness = 1.2

                createSlider(ContentContainer, "Custom Amount", 1, 22, customHatAmount, function(val)
                    customHatAmount = val
                end).Position = UDim2.new(0, 10, 0, 190)

                local loadCustomBtn = Instance.new("TextButton", ContentContainer)
                loadCustomBtn.Size = UDim2.new(1, -20, 0, 30)
                loadCustomBtn.Position = UDim2.new(0, 10, 0, 250)
                loadCustomBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                loadCustomBtn.BackgroundTransparency = 0.5
                loadCustomBtn.Text = "LOAD CUSTOM HAT ID"
                loadCustomBtn.FontFace = AudiowideFont
                loadCustomBtn.TextColor3 = Color3.fromRGB(0, 210, 255)
                loadCustomBtn.TextSize = 12
                addTextOutline(loadCustomBtn)

                local loadCustomCorner = Instance.new("UICorner", loadCustomBtn)
                loadCustomCorner.CornerRadius = UDim.new(0, 6)

                local loadCustomStroke = Instance.new("UIStroke", loadCustomBtn)
                loadCustomStroke.Color = Color3.fromRGB(0, 210, 255)
                loadCustomStroke.Thickness = 1.2

                loadCustomBtn.MouseButton1Click:Connect(function()
                    if customBox.Text ~= "" then
                        LoadPackSafe(customBox.Text, customHatAmount)
                    else
                        sendNotification("catware", "Please enter a valid Hat ID!", true)
                    end
                end)
            else
                local backBtn = Instance.new("TextButton", ContentContainer)
                backBtn.Size = UDim2.new(0, 240, 0, 28)
                backBtn.Position = UDim2.new(0, 10, 0, 5)
                backBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                backBtn.BackgroundTransparency = 0.5
                backBtn.Text = " < Back (" .. selectedHatCategory .. ")"
                backBtn.FontFace = AudiowideFont
                backBtn.TextSize = 12
                backBtn.TextColor3 = Color3.fromRGB(0, 210, 255)
                backBtn.TextXAlignment = Enum.TextXAlignment.Left
                addTextOutline(backBtn)

                local backCorner = Instance.new("UICorner", backBtn)
                backCorner.CornerRadius = UDim.new(0, 6)

                local backStroke = Instance.new("UIStroke", backBtn)
                backStroke.Color = Color3.fromRGB(0, 210, 255)
                backStroke.Thickness = 1.2

                backBtn.MouseButton1Click:Connect(function()
                    selectedHatCategory = nil
                    SwitchTab("Hats", index)
                end)

                local HatScroll = Instance.new("ScrollingFrame", ContentContainer)
                HatScroll.Size = UDim2.new(1, 0, 1, -40)
                HatScroll.Position = UDim2.new(0, 0, 0, 38)
                HatScroll.BackgroundTransparency = 1
                HatScroll.ScrollBarThickness = 4
                HatScroll.BorderSizePixel = 0

                local count = 0
                for _, hat in ipairs(CustomHatsData) do
                    if hat.Category == selectedHatCategory then
                        local btn = Instance.new("TextButton", HatScroll)
                        btn.Size = UDim2.new(1, -20, 0, 32)
                        btn.Position = UDim2.new(0, 10, 0, count * 36)
                        btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        btn.BackgroundTransparency = 0.5
                        btn.Text = "    " .. hat.Name
                        btn.FontFace = AudiowideFont
                        btn.TextSize = 13
                        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        btn.TextXAlignment = Enum.TextXAlignment.Left
                        addTextOutline(btn)

                        local btnCorner = Instance.new("UICorner", btn)
                        btnCorner.CornerRadius = UDim.new(0, 6)

                        local btnStroke = Instance.new("UIStroke", btn)
                        btnStroke.Color = Color3.fromRGB(60, 60, 80)
                        btnStroke.Thickness = 1.2

                        btn.MouseButton1Click:Connect(function()
                            TopStatusBar.Text = "Selected: " .. hat.Name
                            LoadPackSafe(hat.Id, 22)
                        end)
                        count = count + 1
                    end
                end
                HatScroll.CanvasSize = UDim2.new(0, 0, 0, count * 36 + 10)
            end

        elseif tabName == "Music Player" then
            local audioInput = Instance.new("TextBox", ContentContainer)
            audioInput.Size = UDim2.new(1, -20, 0, 32)
            audioInput.Position = UDim2.new(0, 10, 0, 5)
            audioInput.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            audioInput.BackgroundTransparency = 0.5
            audioInput.PlaceholderText = "Insert Audio ID"
            audioInput.Text = ""
            audioInput.FontFace = AudiowideFont
            audioInput.TextSize = 12
            audioInput.TextColor3 = Color3.fromRGB(255, 255, 255)

            local inputCorner = Instance.new("UICorner", audioInput)
            inputCorner.CornerRadius = UDim.new(0, 6)

            local inputStroke = Instance.new("UIStroke", audioInput)
            inputStroke.Color = Color3.fromRGB(60, 60, 80)
            inputStroke.Thickness = 1.2

            local playBtn = Instance.new("TextButton", ContentContainer)
            playBtn.Size = UDim2.new(0, 100, 0, 28)
            playBtn.Position = UDim2.new(0, 10, 0, 42)
            playBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            playBtn.BackgroundTransparency = 0.5
            playBtn.Text = "Play"
            playBtn.FontFace = AudiowideFont
            playBtn.TextColor3 = Color3.fromRGB(0, 210, 255)
            playBtn.TextSize = 12
            addTextOutline(playBtn)

            local playCorner = Instance.new("UICorner", playBtn)
            playCorner.CornerRadius = UDim.new(0, 6)

            local loopBtn = Instance.new("TextButton", ContentContainer)
            loopBtn.Size = UDim2.new(0, 90, 0, 28)
            loopBtn.Position = UDim2.new(0, 115, 0, 42)
            loopBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            loopBtn.BackgroundTransparency = 0.5
            loopBtn.Text = "Loop: OFF"
            loopBtn.FontFace = AudiowideFont
            loopBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            loopBtn.TextSize = 11
            addTextOutline(loopBtn)

            local loopCorner = Instance.new("UICorner", loopBtn)
            loopCorner.CornerRadius = UDim.new(0, 6)

            loopBtn.MouseButton1Click:Connect(function()
                getgenv().MusicLoop = not getgenv().MusicLoop
                loopBtn.Text = "Loop: " .. (getgenv().MusicLoop and "ON" or "OFF")
                loopBtn.TextColor3 = getgenv().MusicLoop and Color3.fromRGB(0, 210, 255) or Color3.fromRGB(200, 200, 200)
                applyAudioEffects()
            end)

            local distBtn = Instance.new("TextButton", ContentContainer)
            distBtn.Size = UDim2.new(0, 110, 0, 28)
            distBtn.Position = UDim2.new(0, 210, 0, 42)
            distBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            distBtn.BackgroundTransparency = 0.5
            distBtn.Text = "Distort: OFF"
            distBtn.FontFace = AudiowideFont
            distBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            distBtn.TextSize = 11
            addTextOutline(distBtn)

            local distCorner = Instance.new("UICorner", distBtn)
            distCorner.CornerRadius = UDim.new(0, 6)

            distBtn.MouseButton1Click:Connect(function()
                getgenv().MusicDistortion = not getgenv().MusicDistortion
                distBtn.Text = "Distort: " .. (getgenv().MusicDistortion and "ON" or "OFF")
                distBtn.TextColor3 = getgenv().MusicDistortion and Color3.fromRGB(255, 120, 0) or Color3.fromRGB(200, 200, 200)
                applyAudioEffects()
            end)

            local bassBtn = Instance.new("TextButton", ContentContainer)
            bassBtn.Size = UDim2.new(0, 110, 0, 28)
            bassBtn.Position = UDim2.new(0, 325, 0, 42)
            bassBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            bassBtn.BackgroundTransparency = 0.5
            bassBtn.Text = "Bass: OFF"
            bassBtn.FontFace = AudiowideFont
            bassBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            bassBtn.TextSize = 11
            addTextOutline(bassBtn)

            local bassCorner = Instance.new("UICorner", bassBtn)
            bassCorner.CornerRadius = UDim.new(0, 6)

            bassBtn.MouseButton1Click:Connect(function()
                getgenv().MusicBassBoost = (getgenv().MusicBassBoost + 1) % 4
                bassBtn.Text = "Bass: " .. (getgenv().MusicBassBoost == 0 and "OFF" or "LVL " .. getgenv().MusicBassBoost)
                bassBtn.TextColor3 = (getgenv().MusicBassBoost > 0) and Color3.fromRGB(0, 210, 255) or Color3.fromRGB(200, 200, 200)
                applyAudioEffects()
            end)

            createSlider(ContentContainer, "Volume", 0, 2, getgenv().MusicVolume, function(val)
                getgenv().MusicVolume = val
                if CurrentActiveMusicTrack then CurrentActiveMusicTrack.Volume = val end
            end).Position = UDim2.new(0, 10, 0, 76)

            createSlider(ContentContainer, "Pitch", 0.1, 3.0, getgenv().MusicPitch, function(val)
                getgenv().MusicPitch = val
                if CurrentActiveMusicTrack then CurrentActiveMusicTrack.PlaybackSpeed = val end
            end).Position = UDim2.new(0, 10, 0, 134)

            -- Preset Songs Title & Scroll List
            local presetTitle = Instance.new("TextLabel", ContentContainer)
            presetTitle.Size = UDim2.new(1, -20, 0, 20)
            presetTitle.Position = UDim2.new(0, 10, 0, 192)
            presetTitle.BackgroundTransparency = 1
            presetTitle.Text = "Preset Songs:"
            presetTitle.FontFace = AudiowideFont
            presetTitle.TextSize = 12
            presetTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            presetTitle.TextXAlignment = Enum.TextXAlignment.Left
            addTextOutline(presetTitle)

            local PresetScroll = Instance.new("ScrollingFrame", ContentContainer)
            PresetScroll.Size = UDim2.new(1, -20, 0, 85)
            PresetScroll.Position = UDim2.new(0, 10, 0, 214)
            PresetScroll.BackgroundTransparency = 1
            PresetScroll.ScrollBarThickness = 4
            PresetScroll.BorderSizePixel = 0

            for pIdx, song in ipairs(PresetSongs) do
                local pSongBtn = Instance.new("TextButton", PresetScroll)
                pSongBtn.Size = UDim2.new(1, -10, 0, 26)
                pSongBtn.Position = UDim2.new(0, 0, 0, (pIdx - 1) * 28)
                pSongBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                pSongBtn.BackgroundTransparency = 0.5
                pSongBtn.Text = "    " .. song.Name
                pSongBtn.FontFace = AudiowideFont
                pSongBtn.TextSize = 11
                pSongBtn.TextColor3 = Color3.fromRGB(0, 210, 255)
                pSongBtn.TextXAlignment = Enum.TextXAlignment.Left
                addTextOutline(pSongBtn)

                local pSongCorner = Instance.new("UICorner", pSongBtn)
                pSongCorner.CornerRadius = UDim.new(0, 6)

                local pSongStroke = Instance.new("UIStroke", pSongBtn)
                pSongStroke.Color = Color3.fromRGB(60, 60, 80)
                pSongStroke.Thickness = 1.2

                pSongBtn.MouseButton1Click:Connect(function()
                    audioInput.Text = song.Id
                    playMusicTrack(song.Id, song.Pitch or 1.0)
                end)
            end
            PresetScroll.CanvasSize = UDim2.new(0, 0, 0, #PresetSongs * 28)

            playBtn.MouseButton1Click:Connect(function()
                if audioInput.Text ~= "" then
                    playMusicTrack(audioInput.Text)
                else
                    sendNotification("Music Player", "Please enter an Audio ID!", true)
                end
            end)

        elseif tabName == "Discord" then
            local cardBtn = Instance.new("TextButton", ContentContainer)
            cardBtn.Size = UDim2.new(0, 360, 0, 160)
            cardBtn.Position = UDim2.new(0.5, -180, 0.5, -80)
            cardBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            cardBtn.BackgroundTransparency = 0.5
            cardBtn.Text = ""

            local cardCorner = Instance.new("UICorner", cardBtn)
            cardCorner.CornerRadius = UDim.new(0, 12)

            local cardStroke = Instance.new("UIStroke", cardBtn)
            cardStroke.Color = Color3.fromRGB(255, 255, 255)
            cardStroke.Transparency = 0.5
            cardStroke.Thickness = 1.5

            local mainLogo = Instance.new("ImageLabel", cardBtn)
            mainLogo.Size = UDim2.new(0, 60, 0, 60)
            mainLogo.Position = UDim2.new(0.5, -30, 0.12, 0)
            mainLogo.BackgroundTransparency = 1
            mainLogo.Image = formatAssetId("10367063073")

            local logoCorner = Instance.new("UICorner", mainLogo)
            logoCorner.CornerRadius = UDim.new(0, 12)

            local linkText = Instance.new("TextLabel", cardBtn)
            linkText.Size = UDim2.new(1, 0, 0, 28)
            linkText.Position = UDim2.new(0, 0, 0.58, 0)
            linkText.BackgroundTransparency = 1
            linkText.Text = "discord.gg/QKP4Wwv2Uv"
            linkText.FontFace = AudiowideFont
            linkText.TextSize = 16
            linkText.TextColor3 = Color3.fromRGB(255, 255, 255)
            addTextOutline(linkText)

            local clickHint = Instance.new("TextLabel", cardBtn)
            clickHint.Size = UDim2.new(1, 0, 0, 20)
            clickHint.Position = UDim2.new(0, 0, 0.78, 0)
            clickHint.BackgroundTransparency = 1
            clickHint.Text = "(Click to copy link)"
            clickHint.FontFace = AudiowideFont
            clickHint.TextSize = 11
            clickHint.TextColor3 = Color3.fromRGB(200, 220, 255)
            addTextOutline(clickHint)

            cardBtn.MouseButton1Click:Connect(function()
                local inviteUrl = "https://discord.gg/QKP4Wwv2Uv"
                pcall(function()
                    if setclipboard then
                        setclipboard(inviteUrl)
                    elseif toclipboard then
                        toclipboard(inviteUrl)
                    end
                end)
                sendNotification("Discord", "Copied invite link to clipboard!", false)
            end)

        elseif tabName == "Drawing" then

            local GridContainer = Instance.new("Frame", ContentContainer)
            GridContainer.Size = UDim2.new(0, 160, 0, 160)
            GridContainer.Position = UDim2.new(0.5, -80, 0, 5)
            GridContainer.BackgroundTransparency = 1

            local UIGrid = Instance.new("UIGridLayout", GridContainer)
            UIGrid.CellSize = UDim2.new(0, 28, 0, 28)
            UIGrid.CellPadding = UDim2.new(0, 4, 0, 4)

            for r = 1, 5 do
                for c = 1, 5 do
                    local cell = Instance.new("TextButton", GridContainer)
                    cell.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    cell.BackgroundTransparency = 0.5
                    cell.Text = (DrawMatrix[r][c] == 1) and "[X]" or "[ ]"
                    cell.FontFace = AudiowideFont
                    cell.TextSize = 12
                    cell.TextColor3 = (DrawMatrix[r][c] == 1) and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(200, 200, 200)
                    addTextOutline(cell)

                    local cellCorner = Instance.new("UICorner", cell)
                    cellCorner.CornerRadius = UDim.new(0, 4)

                    local cellStroke = Instance.new("UIStroke", cell)
                    cellStroke.Color = Color3.fromRGB(60, 60, 80)
                    cellStroke.Thickness = 1

                    cell.MouseButton1Click:Connect(function()
                        DrawMatrix[r][c] = (DrawMatrix[r][c] == 0) and 1 or 0
                        cell.Text = (DrawMatrix[r][c] == 1) and "[X]" or "[ ]"
                        cell.TextColor3 = (DrawMatrix[r][c] == 1) and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(200, 200, 200)
                        
                        CompileDrawingGrid()
                        if getgenv().IsDrawingActive then 
                            SetupHatsEngine()
                        end
                    end)
                end
            end

            local submitDrawBtn = Instance.new("TextButton", ContentContainer)
            submitDrawBtn.Size = UDim2.new(0, 160, 0, 32)
            submitDrawBtn.Position = UDim2.new(0.5, -80, 0, 175)
            submitDrawBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            submitDrawBtn.BackgroundTransparency = 0.5
            submitDrawBtn.Text = "DRAW SHAPE"
            submitDrawBtn.FontFace = AudiowideFont
            submitDrawBtn.TextColor3 = Color3.fromRGB(0, 210, 255)
            submitDrawBtn.TextSize = 12
            addTextOutline(submitDrawBtn)

            local drawCorner = Instance.new("UICorner", submitDrawBtn)
            drawCorner.CornerRadius = UDim.new(0, 6)

            local drawStroke = Instance.new("UIStroke", submitDrawBtn)
            drawStroke.Color = Color3.fromRGB(0, 210, 255)
            drawStroke.Thickness = 1.2

            submitDrawBtn.MouseButton1Click:Connect(function()
                CompileDrawingGrid()
                getgenv().IsDrawingActive = true
                SetupHatsEngine()
                sendNotification("Drawing", "Shape applied to active hats!", false)
            end)
        end
    end

    for i, tabName in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton", Sidebar)
        tabBtn.Size = UDim2.new(1, -12, 0, 30)
        tabBtn.Position = UDim2.new(0, 6, 0, (i - 1) * 34 + 5)
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = "  " .. tabName
        tabBtn.FontFace = AudiowideFont
        tabBtn.TextSize = 13
        tabBtn.TextColor3 = (i == 1) and Color3.fromRGB(0, 210, 255) or Color3.fromRGB(180, 180, 180)
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        addTextOutline(tabBtn)

        tabBtn.MouseButton1Click:Connect(function()
            selectedHatCategory = nil
            SwitchTab(tabName, i)
        end)
        table.insert(tabButtons, tabBtn)
    end

    SetupHatsEngine()
    SwitchTab("Home", 1)

    KeybindConnection = UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.K then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
end

-- Startup Sound & Sequence
local function StartIntroSequence()
    local soundList = {
        {Type = "SpongeBob", Audios = {"135761568366355", "103054216045187", "83175619732774", "130806422349149", "115508154140620", "139762848988311", "94813923036538"}},
        {Id = "86377952078593", Pitch = 0.18, Loop = true},
        {Id = "87694750844457", Pitch = 0.316},
        {Id = "129312224389132", Pitch = 0.2},
        {Id = "101797982999673", Pitch = 1.0},
        {Id = "90349090484819", Pitch = 0.15},
        {Id = "96332107311342", Pitch = 0.15, Vol = 2},
        {Id = "112007140766426", Pitch = 0.12},
        {Id = "82681191862778", Pitch = 1.0},
        {Id = "100583816693650", Pitch = 0.24},
        {Id = "140388662111898", Pitch = 0.2},
        {Id = "116132328421002", Pitch = 0.2}
    }

    local texturesList = {
        {Id = "17565552532", Behavior = "Still", Width = 140, Height = 140},
        {Id = "15636231615", Behavior = "SpinSlow", Width = 140, Height = 140},
        {Id = "130174297136905", Behavior = "Still", Width = 140, Height = 140},
        {Id = "138825144945780", Behavior = "Still", Width = 180, Height = 140},
        {Id = "15462195969", Behavior = "Still", Width = 140, Height = 140},
        {Id = "80268930258446", Behavior = "Still", Width = 190, Height = 190},
        {Id = "109933910523261", Behavior = "Still", Width = 140, Height = 140},
        {Id = "7033010891", Behavior = "Still", Width = 140, Height = 140},
        {Id = "5102022861", Behavior = "SpinSlow", Width = 140, Height = 140},
        {Id = "6502018356", Behavior = "SpinFast", Width = 140, Height = 140},
        {Id = "2575890812", Behavior = "Still", Width = 140, Height = 140},
        {Id = "9524079125", Behavior = "SpinSlow", Width = 140, Height = 140},
        {Id = "115885657660241", Behavior = "SpinSlow", Width = 140, Height = 140},
        {Id = "5669036604", Behavior = "SpinSlow", Width = 140, Height = 140},
        {Id = "88800222056325", Behavior = "SpinSlow", Width = 140, Height = 140},
        {Id = "8408806737", Behavior = "SpinSlow", Width = 140, Height = 140},
        {Id = "106333494847896", Behavior = "SpinSlow", Width = 140, Height = 140},
        {Id = "93422731870704", Behavior = "Shake", Width = 140, Height = 140, ForceSound = "119851755214346"}
    }

    local chosenTex = texturesList[math.random(1, #texturesList)]
    local activeStartupSound = nil

    if chosenTex.ForceSound then
        activeStartupSound = playSound(chosenTex.ForceSound, 1, 1, false)
    else
        local chosenSoundConfig = soundList[math.random(1, #soundList)]
        if chosenSoundConfig.Type == "SpongeBob" then
            task.spawn(function()
                for _, sId in ipairs(chosenSoundConfig.Audios) do
                    activeStartupSound = playSound(sId, 1, 1, false)
                    task.wait(0.1)
                end
            end)
        else
            activeStartupSound = playSound(
                chosenSoundConfig.Id, 
                chosenSoundConfig.Vol or 1, 
                chosenSoundConfig.Pitch or 1, 
                chosenSoundConfig.Loop or false
            )
        end
    end

    -- Expanded Loading Frame (400x400)
    local LoadingFrame = Instance.new("Frame", MainCoreGui)
    LoadingFrame.Size = UDim2.new(0, 400, 0, 400)
    LoadingFrame.Position = UDim2.new(0.5, -200, -0.8, 0)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    LoadingFrame.BackgroundTransparency = 0.15
    LoadingFrame.BorderSizePixel = 0
    LoadingFrame.ZIndex = 100

    local loadCorner = Instance.new("UICorner", LoadingFrame)
    loadCorner.CornerRadius = UDim.new(0, 14)

    -- Loading Screen Texture rendering fix
    local mainTexture = Instance.new("ImageLabel", LoadingFrame)
    mainTexture.Size = UDim2.new(0, chosenTex.Width, 0, chosenTex.Height)
    mainTexture.Position = UDim2.new(0.5, -chosenTex.Width/2, 0.25, -chosenTex.Height/2)
    mainTexture.BackgroundTransparency = 1
    mainTexture.ImageTransparency = 0
    mainTexture.Image = formatAssetId(chosenTex.Id)
    mainTexture.ZIndex = 101

    local userText = Instance.new("TextLabel", LoadingFrame)
    userText.Size = UDim2.new(1, 0, 0, 30)
    userText.Position = UDim2.new(0, 0, 0.60, 0)
    userText.BackgroundTransparency = 1
    userText.Text = "Hello @" .. LocalPlayer.Name
    userText.FontFace = AudiowideFont
    userText.TextSize = 16
    userText.TextColor3 = Color3.fromRGB(255, 255, 255)
    userText.ZIndex = 101
    addTextOutline(userText)

    local loadStatusLbl = Instance.new("TextLabel", LoadingFrame)
    loadStatusLbl.Size = UDim2.new(1, -20, 0, 20)
    loadStatusLbl.Position = UDim2.new(0, 10, 0, 310)
    loadStatusLbl.BackgroundTransparency = 1
    loadStatusLbl.Text = "Loading catware assets..."
    loadStatusLbl.FontFace = AudiowideFont
    loadStatusLbl.TextSize = 12
    loadStatusLbl.TextColor3 = Color3.fromRGB(0, 210, 255)
    loadStatusLbl.ZIndex = 101
    addTextOutline(loadStatusLbl)

    local loadBarTrack = Instance.new("Frame", LoadingFrame)
    loadBarTrack.Size = UDim2.new(1, -30, 0, 12)
    loadBarTrack.Position = UDim2.new(0, 15, 0, 340)
    loadBarTrack.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    loadBarTrack.BackgroundTransparency = 0.5
    loadBarTrack.ZIndex = 101

    local barCorner = Instance.new("UICorner", loadBarTrack)
    barCorner.CornerRadius = UDim.new(0, 6)

    local loadBarFill = Instance.new("Frame", loadBarTrack)
    loadBarFill.Size = UDim2.new(0, 0, 1, 0)
    loadBarFill.BackgroundColor3 = Color3.fromRGB(0, 210, 255)
    loadBarFill.BorderSizePixel = 0
    loadBarFill.ZIndex = 102

    local fillCorner = Instance.new("UICorner", loadBarFill)
    fillCorner.CornerRadius = UDim.new(0, 6)

    TweenService:Create(LoadingFrame, TweenInfo.new(1.0, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -200, 0.5, -200)
    }):Play()

    local spinConn = RunService.RenderStepped:Connect(function(dt)
        if chosenTex.Behavior == "SpinSlow" then
            mainTexture.Rotation = (mainTexture.Rotation + (dt * 60)) % 360
        elseif chosenTex.Behavior == "SpinFast" then
            mainTexture.Rotation = (mainTexture.Rotation + (dt * 180)) % 360
        elseif chosenTex.Behavior == "Shake" then
            local offsetX = math.random(-12, 12)
            local offsetY = math.random(-12, 12)
            mainTexture.Position = UDim2.new(0.5, (-chosenTex.Width/2) + offsetX, 0.25, (-chosenTex.Height/2) + offsetY)
            mainTexture.Rotation = math.random(-15, 15)
        end
    end)

    local totalTime = 10
    local steps = {
        "Loading core modules...",
        "Initializing hat engine...",
        "Configuring audio buffers...",
        "Finalizing UI components..."
    }

    for i = 1, totalTime * 10 do
        local progress = i / (totalTime * 10)
        loadBarFill.Size = UDim2.new(progress, 0, 1, 0)
        local stepIdx = math.clamp(math.ceil(progress * #steps), 1, #steps)
        loadStatusLbl.Text = steps[stepIdx] .. " (" .. math.floor(progress * 100) .. "%)"
        task.wait(0.1)
    end

    spinConn:Disconnect()

    if activeStartupSound and activeStartupSound.Parent then
        TweenService:Create(activeStartupSound, TweenInfo.new(0.8), {Volume = 0}):Play()
    end

    local fadeOut = TweenService:Create(LoadingFrame, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -200, 1.2, 0)
    })
    fadeOut:Play()
    task.wait(0.4)
    LoadingFrame:Destroy()

    if activeStartupSound and activeStartupSound.Parent then
        activeStartupSound:Destroy()
    end

    gameChat("some stupid hat thing made by catware")
    BuildMainHubUI()
    sendNotification("catware", "this took 1 hour idk why i made it", false)
end

task.spawn(StartIntroSequence)

-- Global Cleanup Handler
getgenv().KillScript = function()
    if CurrentActiveMusicTrack then
        CurrentActiveMusicTrack:Stop()
        CurrentActiveMusicTrack:Destroy()
        CurrentActiveMusicTrack = nil
    end
    if LoopNetless then LoopNetless:Disconnect() end
    if LoopMovement then LoopMovement:Disconnect() end
    if KeybindConnection then KeybindConnection:Disconnect() end
    if MainCoreGui then pcall(function() MainCoreGui:Destroy() end) end
    setCustomCursor(false)
end

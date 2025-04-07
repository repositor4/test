-- ShitWare Beta // credits: sega * aka Rubizer

-- Module system

local functions = {}
functions.__index = functions

local category = {
    Player = 1,
    Visual = 2,
    Misc = 3,
    STK = 4,
    Config = 5
}
local setting = {
    Slider = 1,
    Bool = 2,
    Mode = 3,
    Color = 4
}

function addModule(name, keybind, category)
    local self = setmetatable({}, functions)
    self.name = name
    self.keybind = keybind
    self.category = category
    self.isEnabled = false
    self.settings = {}
    return self
end

function functions:getName()
    return self.name
end

function functions:getKey()
    return self.keybind
end

function functions:getCategory()
    return self.category
end

function functions:toggle()
    self.isEnabled = not self.isEnabled
    print(self.name .. " is now " .. (self.isEnabled and "Enabled" or "Disabled"))
end

function functions:addSetting(setting)
    table.insert(self.settings, setting)
end

function functions:getSettings()
    return self.settings
end

function functions:getSettingByName(name)
    for _, sett in ipairs(self.settings) do
        if sett.name == name then
            return sett
        end
    end
    return nil
end

-- Setting types
local Slider = {}
Slider.__index = Slider
function Slider.new(settingName, defaultValue, min, max, step)
    local self = setmetatable({}, Slider)
    self.name = settingName
    self.type = setting.Slider
    self.value = defaultValue
    self.min = min or 0
    self.max = max or 1
    self.step = step or 0.1
    return self
end

local Bool = {}
Bool.__index = Bool
function Bool.new(settingName, defaultValue)
    local self = setmetatable({}, Bool)
    self.name = settingName
    self.type = setting.Bool
    self.value = defaultValue or false
    return self
end

local Mode = {}
Mode.__index = Mode
function Mode.new(settingName, defaultValue, modes)
    local self = setmetatable({}, Mode)
    self.name = settingName
    self.type = setting.Mode
    self.value = defaultValue
    self.modes = modes or {}
    return self
end

local Color = {}
Color.__index = Color
function Color.new(settingName, defaultValue)
    local self = setmetatable({}, Color)
    self.name = settingName
    self.type = setting.Color
    self.value = defaultValue or Color3.fromRGB(255,255,255)
    return self
end
function Color:setValue(newColor)
    self.value = newColor
    print("New color set: ", self.value)
end

-- LOCAL GETTERS
local player = game.Players.LocalPlayer
local function getHumanoid()
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        return player.Character.Humanoid
    end
    return nil
end
local function getCharacter()
    if player and player.Character then
        return player.Character
    end
    return nil
end

------------------------------------------------
-- ChinaHat Module
------------------------------------------------
local ChinaHat = {}
ChinaHat.__index = ChinaHat

function ChinaHat.new()
    local self = setmetatable({}, ChinaHat)
    self.module = addModule("ChinaHat", "none", category.Visual)
    self:addSettings()
    self.hatPart = nil
    self.dynamicTask = nil
    return self
end

function ChinaHat:addSettings()
    self.module:addSetting(Mode.new("Mode", "Dynamic", {"Dynamic", "Static"}))
    -- Цвет для Static режима
    self.module:addSetting(Color.new("Color", Color3.fromRGB(255, 0, 0)))
end

function ChinaHat:onKey()
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

function ChinaHat:onEnable()
    self:enableChinaHat()
end

function ChinaHat:onDisable()
    self:disableChinaHat()
end

function ChinaHat:enableChinaHat()
    local character = getCharacter()
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    -- Создание шляпы
    self.hatPart = Instance.new("Part")
    self.hatPart.Size = Vector3.new(1, 1, 1)
    self.hatPart.Anchored = false
    self.hatPart.CanCollide = false
    self.hatPart.Name = "ChinaHat"
    self.hatPart.Transparency = 0

    local mesh = Instance.new("SpecialMesh", self.hatPart)
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1033714"
    mesh.Scale = Vector3.new(1.8, 1, 1.8)

    self.hatPart.CFrame = head.CFrame * CFrame.new(0, 1.3, 0)
    self.hatPart.Parent = head

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = head
    weld.Part1 = self.hatPart
    weld.Parent = self.hatPart

    local modeSetting = self.module:getSettingByName("Mode").value
    if modeSetting == "Static" then
        local colorSetting = self.module:getSettingByName("Color").value
        self.hatPart.Color = colorSetting
    elseif modeSetting == "Dynamic" then
        self.dynamicTask = task.spawn(function()
            local t = 0
            while self.module.isEnabled and self.hatPart do
                t = t + 0.03
                local r = math.sin(t) * 0.5 + 0.5
                local g = math.sin(t + 2) * 0.5 + 0.5
                local b = math.sin(t + 4) * 0.5 + 0.5
                self.hatPart.Color = Color3.new(r, g, b)
                task.wait(0.03)
            end
        end)
    end
end


function ChinaHat:disableChinaHat()
    if self.hatPart then
        self.hatPart:Destroy()
        self.hatPart = nil
    end
    if self.dynamicTask then
        task.cancel(self.dynamicTask)
        self.dynamicTask = nil
    end
end

------------------------------------------------
-- LootFinder Module
------------------------------------------------
local LootFinder = {}
LootFinder.__index = LootFinder

function LootFinder.new()
    local self = setmetatable({}, LootFinder)
    self.module = addModule("LootFinder Test", "none", category.Misc)
    self:addSettings()
    self.gui = nil
    self.running = false
    return self
end

function LootFinder:addSettings()
end

function LootFinder:createGui()
    if self.gui then self.gui:Destroy() end

    local screenGui = Instance.new("ScreenGui", game.CoreGui)
    screenGui.Name = "LootGui"
    screenGui.ResetOnSpawn = false

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true

    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        self.gui = nil
        self.running = false
    end)

    local scrollingFrame = Instance.new("ScrollingFrame", frame)
    scrollingFrame.Size = UDim2.new(1, -10, 1, -40)
    scrollingFrame.Position = UDim2.new(0, 5, 0, 35)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.ScrollBarThickness = 6

    self.gui = {
        screen = screenGui,
        frame = frame,
        scroll = scrollingFrame,
    }
end

function LootFinder:scanLoot()
    if not self.gui then return end
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local found = {}

    -- Очистка старых хайлайтов
    for _, hl in ipairs(game.CoreGui:GetChildren()) do
        if hl:IsA("Highlight") and hl.Name == "LootHighlight" then
            hl:Destroy()
        end
    end

    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local part = nil
            if prompt.Parent:IsA("BasePart") then
                part = prompt.Parent
            else
                part = prompt.Parent:FindFirstChildWhichIsA("BasePart")
            end

            if part then
                local distance = (part.Position - character.HumanoidRootPart.Position).Magnitude
                if distance <= 30 then
                    table.insert(found, {
                        name = prompt.ObjectText ~= "" and prompt.ObjectText or (prompt.ActionText ~= "" and prompt.ActionText or "???"),
                        part = part,
                        prompt = prompt
                    })

                    local highlight = Instance.new("Highlight")
                    highlight.Name = "LootHighlight"
                    highlight.Adornee = part
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = game.CoreGui
                end
            end
        end
    end

    -- GUI обновление
    local scroll = self.gui.scroll
    scroll:ClearAllChildren()

    for i, item in ipairs(found) do
        local label = Instance.new("TextLabel", scroll)
        label.Size = UDim2.new(1, 0, 0, 30)
        label.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
        label.BackgroundTransparency = 1
        label.Text = string.format("%s (%.1f)", item.name, (item.part.Position - character.HumanoidRootPart.Position).Magnitude)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.SourceSans
        label.TextSize = 20
    end

    scroll.CanvasSize = UDim2.new(0, 0, 0, #found * 30)
end


function LootFinder:onEnable()
    print("LootFinder enabled")
    self:createGui()
    self.running = true

    task.spawn(function()
        while self.running and self.gui do
            self:scanLoot()
            task.wait(1)
        end
    end)
end

function LootFinder:onDisable()
    print("LootFinder disabled")
    self.running = false
    if self.gui then
        self.gui.screen:Destroy()
        self.gui = nil
    end
end

function LootFinder:onKey()
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

------------------------------------------------
-- JumpCircles Module
------------------------------------------------
local JumpCircles = {}
JumpCircles.__index = JumpCircles

function JumpCircles.new()
    local self = setmetatable({}, JumpCircles)
    self.module = addModule("JumpCircles", "none", category.Visual)
    self:addSettings()
    self.connections = {}
    self.canCreateCircle = true  -- флаг, разрешающий создание круга
    return self
end

function JumpCircles:addSettings()
    self.module:addSetting(Slider.new("Size", 6, 0.1, 20, 0.1))         -- конечный диаметр диска
    self.module:addSetting(Slider.new("DestroyTime", 1, 0.1, 5, 0.1))    -- время анимации (сек)
    self.module:addSetting(Bool.new("EndAnimation", false))              -- конечная анимация (burst)
    self.module:addSetting(Color.new("CircleColor", Color3.new(1, 1, 1)))  -- выбор цвета круга
    self.module:addSetting(Slider.new("Opacity", 1, 0, 1, 0.01))          -- начальная непрозрачность (1 = полностью видимый)
end

function JumpCircles:onKey()
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

function JumpCircles:onEnable()
    print("[JumpCircles] Enabled")
    local UIS = game:GetService("UserInputService")
    
    -- Слушаем событие прыжка
    local jumpConn = UIS.JumpRequest:Connect(function()
        local character = getCharacter()
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        -- Если круг уже можно создавать (игрок на земле)
        if self.canCreateCircle then
            self.canCreateCircle = false  -- запрещаем повтор до следующего прыжка
            self:createCircle(character)
        end
    end)
    table.insert(self.connections, jumpConn)
    
    -- Слушаем событие смены состояния Humanoid для сброса флага после приземления
    local character = getCharacter()
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local stateConn = humanoid.StateChanged:Connect(function(oldState, newState)
                if newState == Enum.HumanoidStateType.Landed then
                    self.canCreateCircle = true
                end
            end)
            table.insert(self.connections, stateConn)
        end
    end
end

function JumpCircles:onDisable()
    for _, conn in ipairs(self.connections) do
        conn:Disconnect()
    end
    self.connections = {}
end

function JumpCircles:createCircle(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Ждём начала падения: когда скорость по Y становится отрицательной
    while root.Velocity.Y >= 0 do
        task.wait(0.01)
    end

    local numSegments = 70 -- 70 сегментов
    local segments = {}

    local targetDiameter = self.module:getSettingByName("Size").value
    local destroyTime = self.module:getSettingByName("DestroyTime").value
    local useEndAnim = self.module:getSettingByName("EndAnimation").value
    local circleColor = self.module:getSettingByName("CircleColor").value
    local desiredOpacity = self.module:getSettingByName("Opacity").value  -- 1 = полностью видимый

    -- Сохраняем позицию игрока на момент начала падения
    local centerPos = root.Position - Vector3.new(0, 2.9, 0)

    -- Создаём сегменты круга
    for i = 1, numSegments do
        local angle = math.rad((360 / numSegments) * i)
        local segment = Instance.new("Part")
        segment.Anchored = true
        segment.CanCollide = false
        segment.Size = Vector3.new(0.2, 0.1, 0.5)  -- настраиваем размер полоски
        segment.Color = circleColor
        segment.Material = Enum.Material.Neon
        -- Начинаем с прозрачности, соответствующей desiredOpacity: если desiredOpacity = 1, то Transparency = 0
        segment.Transparency = 1 - desiredOpacity
        segment.Parent = workspace

        local initialRadius = 0.05
        local posX = centerPos.X + math.cos(angle) * initialRadius
        local posZ = centerPos.Z + math.sin(angle) * initialRadius
        local posY = centerPos.Y
        segment.CFrame = CFrame.new(posX, posY, posZ) * CFrame.Angles(0, angle, 0)
        table.insert(segments, segment)
    end

    task.spawn(function()
        local t = 0
        local initialDiameter = 0.1
        while t < destroyTime do
            local dt = task.wait()
            t = t + dt
            local progress = t / destroyTime
            local currentDiameter = initialDiameter + (targetDiameter - initialDiameter) * progress
            local radius = currentDiameter / 2
            
            for i, segment in ipairs(segments) do
                if segment and segment.Parent then
                    local angle = math.rad((360 / numSegments) * i)
                    local posX = centerPos.X + math.cos(angle) * radius
                    local posZ = centerPos.Z + math.sin(angle) * radius
                    local posY = centerPos.Y
                    segment.CFrame = CFrame.new(posX, posY, posZ) * CFrame.Angles(0, angle, 0)
                    -- Прозрачность анимируется от начального значения до 1 (полностью невидимый)
                    segment.Transparency = (1 - desiredOpacity) + progress * desiredOpacity
                end
            end
        end

        if not segments[1] or not segments[1].Parent then 
            return 
        end

        if useEndAnim then
            local radius = (targetDiameter / 2) * 1.1
            for i, segment in ipairs(segments) do
                if segment and segment.Parent then
                    local angle = math.rad((360 / numSegments) * i)
                    local posX = centerPos.X + math.cos(angle) * radius
                    local posZ = centerPos.Z + math.sin(angle) * radius
                    local posY = centerPos.Y
                    segment.CFrame = CFrame.new(posX, posY, posZ) * CFrame.Angles(0, angle, 0)
                end
            end
            task.wait(0.1)
            for j = 1, 10 do
                task.wait(0.01)
                local scale = 1 - (j / 10)
                local radius2 = (targetDiameter / 2) * scale
                for i, segment in ipairs(segments) do
                    if segment and segment.Parent then
                        local angle = math.rad((360 / numSegments) * i)
                        local posX = centerPos.X + math.cos(angle) * radius2
                        local posZ = centerPos.Z + math.sin(angle) * radius2
                        local posY = centerPos.Y
                        segment.CFrame = CFrame.new(posX, posY, posZ) * CFrame.Angles(0, angle, 0)
                        segment.Transparency = (1 - desiredOpacity) + (j / 10) * desiredOpacity
                    end
                end
            end
        else
            for j = 1, 10 do
                task.wait(0.01)
                for i, segment in ipairs(segments) do
                    if segment and segment.Parent then
                        segment.Transparency = (1 - desiredOpacity) + (j / 10) * desiredOpacity
                    end
                end
            end
        end

        for i, segment in ipairs(segments) do
            if segment and segment.Parent then
                segment:Destroy()
            end
        end
    end)
end

------------------------------------------------
-- NameView Module
------------------------------------------------
local NameView = {}
NameView.__index = NameView

function NameView.new()
    local self = setmetatable({}, NameView)
    self.module = addModule("NameView", "none", category.Visual)
    self:addSettings()
    self.nameTags = {}
    return self
end

function NameView:addSettings()
    -- Здесь могут быть настройки, например, для включения/выключения отображения
end

function NameView:onKey()
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

function NameView:onEnable()
    print("[NameView] Enabled")
    self.running = true
end

function NameView:onDisable()
    self.running = false
    self:removeNameTags() -- Удаляем все теги имен, когда модуль выключен
end

function NameView:update()
    if not self.module.isEnabled then return end

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("Head") then
            self:createNameTag(plr)
        end
    end
end

function NameView:createNameTag(plr)
    if not self.nameTags[plr] then
        local tag = Instance.new("BillboardGui")
        tag.Name = "NameTag"
        tag.Adornee = plr.Character:FindFirstChild("Head")
        tag.Size = UDim2.new(0, 100, 0, 50)
        tag.StudsOffset = Vector3.new(0, 3, 0)
        tag.AlwaysOnTop = true
        tag.Parent = plr.Character

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = plr.Name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 16
        label.Font = Enum.Font.SourceSansBold
        label.Parent = tag

        self.nameTags[plr] = tag
    end
end

function NameView:removeNameTags()
    for plr, tag in pairs(self.nameTags) do
        if tag and tag.Parent then
            tag:Destroy()
        end
    end
    self.nameTags = {}
end

------------------------------------------------
-- FogColor Module
------------------------------------------------
local FogColor = {}
FogColor.__index = FogColor

function FogColor.new()
    local self = setmetatable({}, FogColor)
    self.module = addModule("FogColor", "none", category.Visual)
    self:addSettings()
    return self
end

function FogColor:addSettings()
    self.module:addSetting(Mode.new("ColorMode", "Static", {"Static", "Dynamic"})) -- режим цвета
    self.module:addSetting(Color.new("Color", Color3.new(1, 1, 1))) -- цвет (если static)
end

function FogColor:onKey()
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

function FogColor:onEnable()
    print("[FogColor] Enabled")
    self.running = true
    task.spawn(function()
        while self.running do
            self:update()
            task.wait(0.1)
        end
    end)
end

function FogColor:onDisable()
    self.running = false
    self:resetFogColor()  -- сбрасываем цвет, когда модуль выключен
end

function FogColor:update()
    if not self.module.isEnabled then return end

    local colorMode = self.module:getSettingByName("ColorMode").value
    local baseColor = self.module:getSettingByName("Color").value
    local color = baseColor

    if colorMode == "Dynamic" then
        local h = tick() % 5 / 5
        color = Color3.fromHSV(h, 1, 1)
    end

    game.Lighting.FogColor = color
end

function FogColor:resetFogColor()
    game.Lighting.FogColor = Color3.new(0, 0, 0)
end

------------------------------------------------
-- ThirdPerson Module
------------------------------------------------
local ThirdPerson = {}
ThirdPerson.__index = ThirdPerson

function ThirdPerson.new()
    local self = setmetatable({}, ThirdPerson)
    self.module = addModule("ThirdPerson", "none", category.Visual)
    self:addSettings()
    return self
end

function ThirdPerson:addSettings()
    self.module:addSetting(Slider.new("Distance", 10, 2, 20, 0.1)) -- расстояние от камеры до игрока
    self.module:addSetting(Slider.new("Height", 2, 0, 5, 0.1)) -- высота камеры
end

function ThirdPerson:onKey()
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

function ThirdPerson:onEnable()
    print("[ThirdPerson] Enabled")
    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
end

function ThirdPerson:onDisable()
    print("[ThirdPerson] Disabled")
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
end

function ThirdPerson:update()
    if not self.module.isEnabled then return end

    local camera = workspace.CurrentCamera
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local distance = self.module:getSettingByName("Distance").value
    local height = self.module:getSettingByName("Height").value

    local behind = hrp.CFrame.LookVector * -distance
    local up = Vector3.new(0, height, 0)
    local camPos = hrp.Position + behind + up
    local lookAt = hrp.Position + Vector3.new(0, 1.5, 0)

    camera.CFrame = CFrame.new(camPos, lookAt)
end

------------------------------------------------
-- Trails Module
------------------------------------------------
local Trails = {}
Trails.__index = Trails

function Trails.new()
    local self = setmetatable({}, Trails)
    self.module = addModule("Trails", "none", category.Visual)
    self:addSettings()
    self.connections = {}
    self.segments = {}
    self.timer = 0
    return self
end

function Trails:addSettings()
    self.module:addSetting(Slider.new("Length", 10, 1, 100, 1)) -- длина следа в частях
    self.module:addSetting(Slider.new("RemoveTime", 5, 1, 30, 1)) -- удаление по времени (секунды)
    self.module:addSetting(Mode.new("ColorMode", "Static", {"Static", "Dynamic"})) -- режим цвета
    self.module:addSetting(Color.new("Color", Color3.new(1, 1, 1))) -- цвет (если static)
    self.module:addSetting(Slider.new("Opacity", 1, 0, 1, 0.01)) -- прозрачность
    self.module:addSetting(Slider.new("Height", 1.5, 0.1, 10, 0.1)) -- высота трейла
end

function Trails:onKey()
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

function Trails:onEnable()
    print("[Trails] Enabled")

    self.running = true

    task.spawn(function()
        while self.running do
            local character = getCharacter()
            if character and character:FindFirstChild("HumanoidRootPart") then
                self:createTrailSegment(character)
            end
            task.wait(0.05)
        end
    end)
end

function Trails:onDisable()
    self.running = false
    for _, seg in ipairs(self.segments) do
        if seg and seg.Parent then
            seg:Destroy()
        end
    end
    self.segments = {}
end

function Trails:createTrailSegment(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local colorMode = self.module:getSettingByName("ColorMode").value
    local baseColor = self.module:getSettingByName("Color").value
    local opacity = self.module:getSettingByName("Opacity").value
    local maxLength = self.module:getSettingByName("Length").value
    local removeTime = self.module:getSettingByName("RemoveTime").value
    local height = self.module:getSettingByName("Height").value

    local color = baseColor
    if colorMode == "Dynamic" then
        local h = tick() % 5 / 5
        color = Color3.fromHSV(h, 1, 1)
    end

    local currentPosition = root.Position

    -- При первом вызове просто сохраняем позицию
    if not self.lastPosition then
        self.lastPosition = currentPosition
    end

    local moved = (currentPosition - self.lastPosition).Magnitude >= 0.1

    if moved then
        local middle = (currentPosition + self.lastPosition) / 2
        local distance = (currentPosition - self.lastPosition).Magnitude

        local segment = Instance.new("Part")
        segment.Anchored = true
        segment.CanCollide = false
        segment.Material = Enum.Material.Neon
        segment.Color = color
        segment.Transparency = 1 - opacity
        segment.Size = Vector3.new(0.08, height, distance)
        segment.CFrame = CFrame.new(middle, self.lastPosition)
        segment.Parent = workspace
        segment:SetAttribute("CreatedAt", tick())

        table.insert(self.segments, segment)

        self.lastPosition = currentPosition
    end

    -- Удаляем по длине
    if #self.segments > maxLength then
        local old = table.remove(self.segments, 1)
        if old and old.Parent then
            old:Destroy()
        end
    end

    local now = tick()
    for i = #self.segments, 1, -1 do
        local seg = self.segments[i]
        local created = seg:GetAttribute("CreatedAt")
        if created and now - created > removeTime then
            seg:Destroy()
            table.remove(self.segments, i)
        end
    end
end

------------------------------------------------
-- Tracers Module
------------------------------------------------
local Tracers = {}
Tracers.__index = Tracers

function Tracers.new()
    local self = setmetatable({}, Tracers)
    self.module = addModule("Tracers", "none", category.Visual)
    self:addSettings()
    self.tracers = {}
    return self
end

function Tracers:addSettings()
    self.module:addSetting(Slider.new("Length", 50, 10, 500, 1)) -- максимальная дистанция
    self.module:addSetting(Slider.new("Opacity", 1, 0, 1, 0.01)) -- прозрачность
    self.module:addSetting(Color.new("Color", Color3.new(1, 1, 1))) -- цвет линий
end

function Tracers:onKey()
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

function Tracers:onEnable()
    print("[Tracers] Enabled")
end

function Tracers:onDisable()
    self:removeTracers()
end

function Tracers:update()
    if not self.module.isEnabled then return end

    local localPlayer = game.Players.LocalPlayer
    if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    self:removeTracers()

    local hrp = localPlayer.Character.HumanoidRootPart
    local maxDist = self.module:getSettingByName("Length").value
    local color = self.module:getSettingByName("Color").value
    local opacity = self.module:getSettingByName("Opacity").value

    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = player.Character.HumanoidRootPart
            local dist = (hrp.Position - targetHRP.Position).Magnitude
            if dist <= maxDist then
                local beam = Instance.new("Part")
                beam.Anchored = true
                beam.CanCollide = false
                beam.Material = Enum.Material.Neon
                beam.Color = color
                beam.Transparency = 1 - opacity
                beam.Size = Vector3.new(0.06, 0.06, dist)
                beam.CFrame = CFrame.new(hrp.Position, targetHRP.Position) * CFrame.new(0, 0, -dist / 2)
                beam.Parent = workspace
                table.insert(self.tracers, beam)
            end
        end
    end
end

function Tracers:removeTracers()
    for _, tracer in ipairs(self.tracers) do
        if tracer and tracer.Parent then
            tracer:Destroy()
        end
    end
    self.tracers = {}
end

------------------------------------------------
-- Strafe Module (Полная реализация контроля в воздухе)
------------------------------------------------
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Strafe = {}
Strafe.__index = Strafe

function Strafe.new()
    local self = setmetatable({}, Strafe)
    self.module = addModule("Strafe", "none", category.Player)
    self:addSettings()
    self.inputState = {
        W = false,
        A = false,
        S = false,
        D = false
    }
    self.connections = {}
    self:bindInputs()
    return self
end

function Strafe:addSettings()
    self.module:addSetting(Slider.new("AirControlPower", 50, 10, 100, 5))
    self.module:addSetting(Bool.new("Enabled", true))
end

function Strafe:bindInputs()
    table.insert(self.connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.W then
            self.inputState.W = true
        elseif input.KeyCode == Enum.KeyCode.A then
            self.inputState.A = true
        elseif input.KeyCode == Enum.KeyCode.S then
            self.inputState.S = true
        elseif input.KeyCode == Enum.KeyCode.D then
            self.inputState.D = true
        end
    end))

    table.insert(self.connections, UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.W then
            self.inputState.W = false
        elseif input.KeyCode == Enum.KeyCode.A then
            self.inputState.A = false
        elseif input.KeyCode == Enum.KeyCode.S then
            self.inputState.S = false
        elseif input.KeyCode == Enum.KeyCode.D then
            self.inputState.D = false
        end
    end))
end

function Strafe:getStrafeInput()
    local cam = workspace.CurrentCamera
    if not cam then return Vector3.new(0,0,0) end
    local direction = Vector3.new(0, 0, 0)

    if self.inputState.W then
        direction = direction + cam.CFrame.LookVector
    end
    if self.inputState.S then
        direction = direction - cam.CFrame.LookVector
    end
    if self.inputState.A then
        direction = direction - cam.CFrame.RightVector
    end
    if self.inputState.D then
        direction = direction + cam.CFrame.RightVector
    end

    direction = Vector3.new(direction.X, 0, direction.Z)

    if direction.Magnitude > 0 then
        return direction.Unit
    else
        return Vector3.new(0,0,0)
    end
end

function Strafe:applyStrafe(directionVector)
    local char = getCharacter()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end

    local state = humanoid:GetState()
    if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
        local power = self.module:getSettingByName("AirControlPower").value
        local impulse = directionVector * power

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "StrafeVelocity"
        -- Сохраняем вертикальную составляющую текущей скорости
        bodyVelocity.Velocity = Vector3.new(impulse.X, hrp.Velocity.Y, impulse.Z)
        bodyVelocity.MaxForce = Vector3.new(1, 0, 1) * 10000
        bodyVelocity.Parent = hrp

        -- Эффект действует кратковременно
        game.Debris:AddItem(bodyVelocity, 0.2)
    end
end

-- Функция update вызывается каждый кадр для проверки ввода и применения стрейфа
function Strafe:update()
    if not self.module:getSettingByName("Enabled").value then return end
    local inputDir = self:getStrafeInput()
    if inputDir.Magnitude > 0 then
        self:applyStrafe(inputDir)
    end
end

function Strafe:onKey()
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

function Strafe:onEnable()
    print("Strafe module enabled")
end

function Strafe:onDisable()
    print("Strafe module disabled")
    -- Отключаем подключения ввода
    for _, conn in ipairs(self.connections) do
        conn:Disconnect()
    end
    self.connections = {}
    -- Удаляем существующий BodyVelocity, если он есть
    local char = getCharacter()
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:FindFirstChild("StrafeVelocity") then
            hrp.StrafeVelocity:Destroy()
        end
    end
end

------------------------------------------------
-- NoClip Module (инстанс)
------------------------------------------------
local NoClip = {}
NoClip.__index = NoClip

function NoClip.new()
    local self = setmetatable({}, NoClip)
    self.module = addModule("NoClip", "none", category.Player)
    self:addSettings()
    self.enabled = false
    return self
end

function NoClip:addSettings()
end

function NoClip:onKey()
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

function NoClip:onEnable()
    print("NoClip enabled!")
    self.enabled = true
end

function NoClip:onDisable()
    print("NoClip disabled!")
    self.enabled = false
    self:disableNoClip()
end

function NoClip:enableNoClip()
    local player = game.Players.LocalPlayer
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end

function NoClip:disableNoClip()
    local player = game.Players.LocalPlayer
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and not part.CanCollide then
                part.CanCollide = true
            end
        end
    end
end

function NoClip:update()
    if self.module.isEnabled then
        self:enableNoClip()
    else
        self:disableNoClip()
    end
end

------------------------------------------------
-- Spider Module (инстанс)
------------------------------------------------
local Spider = {}
Spider.__index = Spider

function Spider.new()
    local self = setmetatable({}, Spider)
    self.module = addModule("Spider", "none", category.Player)
    self:addSettings()
    return self
end

function Spider:addSettings()
    self.module:addSetting(Slider.new("Speed", 10, 1, 50, 1))
    self.module:addSetting(Slider.new("Distance", 3, 1, 10, 0.5))
end

function Spider:onKey()
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

function Spider:onEnable()
    print("Spider enabled!")
end

function Spider:onDisable()
    print("Spider disabled!")
end

function Spider:update()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local climbSpeed = self.module:getSettingByName("Speed").value
    local checkDistance = self.module:getSettingByName("Distance").value

    local directions = {
        Vector3.new(1, 0, 0),
        Vector3.new(-1, 0, 0),
        Vector3.new(0, 0, 1),
        Vector3.new(0, 0, -1)
    }

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local wallDetected = false
    for _, dir in ipairs(directions) do
        local origin = hrp.Position
        local direction = dir * checkDistance
        local result = workspace:Raycast(origin, direction, raycastParams)
        if result and result.Instance and result.Instance.Anchored then
            wallDetected = true
            break
        end
    end

    if wallDetected then
        hrp.Velocity = Vector3.new(hrp.Velocity.X, climbSpeed, hrp.Velocity.Z)
    end
end

------------------------------------------------
-- AimBot Module
------------------------------------------------
local AimBotTest = {}
AimBotTest.__index = AimBotTest

function AimBotTest.new()
    local self = setmetatable({}, AimBotTest)
    self.module = addModule("AimBot", "none", category.Player)
    self:addSettings()
    self.strafeDirection = 1
    return self
end

function AimBotTest:addSettings()
    self.module:addSetting(Slider.new("Distance", 50, 1, 300, 1))
    self.module:addSetting(Bool.new("Silent", true))
    self.module:addSetting(Bool.new("TargetStrafe", false))
    self.module:addSetting(Slider.new("StrafeSpeed", 5, 0.1, 50, 0.1))
    self.module:addSetting(Slider.new("StrafeDistance", 5, 1, 50, 0.1))
end

local function getClosestPlayer(maxDistance)
    local localPlayer = game.Players.LocalPlayer
    local myCharacter = localPlayer.Character
    if not myCharacter then return nil end

    local myHead = myCharacter:FindFirstChild("Head")
    if not myHead then return nil end

    local closest = nil
    local shortest = maxDistance

    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= localPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local targetHead = plr.Character.Head
            local dist = (targetHead.Position - myHead.Position).Magnitude
            if dist <= shortest then
                closest = plr
                shortest = dist
            end
        end
    end

    return closest
end

function AimBotTest:onEnable()
    print("AimBot enabled")
end

function AimBotTest:onDisable()
    print("AimBot disabled")
    local char = getCharacter()
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:FindFirstChild("AimBotStrafe") then
            hrp.AimBotStrafe:Destroy()
        end
    end
end

function AimBotTest:onKey()
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

function AimBotTest:rotateCameraTo(position)
    local camera = workspace.CurrentCamera
    local lookVector = (position - camera.CFrame.Position).Unit
    camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + lookVector)
end

function AimBotTest:update()
    local maxDist = self.module:getSettingByName("Distance").value
    local silent = self.module:getSettingByName("Silent").value
    local targetStrafe = self.module:getSettingByName("TargetStrafe").value
    local strafeSpeed = self.module:getSettingByName("StrafeSpeed").value
    local strafeDistance = self.module:getSettingByName("StrafeDistance").value

    local targetPlayer = getClosestPlayer(maxDist)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local char = getCharacter()
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:FindFirstChild("AimBotStrafe") then
                hrp.AimBotStrafe:Destroy()
            end
        end
        return
    end

    local targetHead = targetPlayer.Character:FindFirstChild("Head")
    if silent then
        if targetHead then
            self:rotateCameraTo(targetHead.Position)
        end
    else
        local char = getCharacter()
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and targetHead then
                local lookVector = (targetHead.Position - hrp.Position).Unit
                hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookVector)
            end
        end
    end

    if targetStrafe then
        local char = getCharacter()
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and targetHRP then
                local angle = tick() * strafeSpeed * self.strafeDirection
                local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * strafeDistance
                local targetPos = targetHRP.Position + offset
                local bodyVelocity = hrp:FindFirstChild("AimBotStrafe") or Instance.new("BodyVelocity", hrp)
                bodyVelocity.Name = "AimBotStrafe"
                bodyVelocity.Velocity = (targetPos - hrp.Position).Unit * strafeSpeed
                bodyVelocity.MaxForce = Vector3.new(1, 0, 1) * 10000
            end
        end
    else
        local char = getCharacter()
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:FindFirstChild("AimBotStrafe") then
                hrp.AimBotStrafe:Destroy()
            end
        end
    end
end

------------------------------------------------
-- AutoClicker Module (инстанс)
------------------------------------------------
local AutoClicker = {}
AutoClicker.__index = AutoClicker

function AutoClicker.new()
    local self = setmetatable({}, AutoClicker)
    self.module = addModule("AutoClicker", "none", category.Misc)
    self:addSettings()
    self.enabled = false
    self._connection = nil
    self._clicking = false
    return self
end

function AutoClicker:addSettings()
    self.module:addSetting(Slider.new("Min CPS", 8, 1, 20, 1))
    self.module:addSetting(Slider.new("Max CPS", 12, 1, 20, 1))
    self.module:addSetting(Mode.new("MouseButton", {"Left", "Right", "Middle"}, "Left"))
end

function AutoClicker:onKey()
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

function AutoClicker:onEnable()
    self.enabled = true
    self:startClicking()
end

function AutoClicker:onDisable()
    self.enabled = false
    self:stopClicking()
end

function AutoClicker:startClicking()
    local UserInputService = game:GetService("UserInputService")
    local VirtualInputManager = game:GetService("VirtualInputManager")

    self._clicking = true

    coroutine.wrap(function()
        while self._clicking do
            local minCPS = self.module:getSettingByName("Min CPS").value
            local maxCPS = self.module:getSettingByName("Max CPS").value
            local mode = self.module:getSettingByName("MouseButton").value
            local cps = math.random(minCPS, maxCPS)
            local delay = 1 / cps

            -- Определяем кнопку
            local button = "LeftButton"
            if mode == "Right" then button = "RightButton"
            elseif mode == "Middle" then button = "MiddleButton" end

            -- Подаём нажатие
            VirtualInputManager:SendMouseButtonEvent(0, 0, button, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, button, false, game, 0)

            wait(delay)
        end
    end)()
end

function AutoClicker:stopClicking()
    self._clicking = false
end

------------------------------------------------
-- AimBot Module (инстанс) New
------------------------------------------------
local AimBot = {}
AimBot.__index = AimBot

function AimBot.new()
    local self = setmetatable({}, AimBot)
    self.module = addModule("AimBot New", "X", category.Player)
    self:addSettings()
    self.enabled = false
    self.fovCircle = nil
    return self
end

function AimBot:addSettings()
    self.module:addSetting(Slider.new("Sensitivity", 1, 0.1, 10, 0.1))
    self.module:addSetting(Slider.new("FOV", 360, 10, 360, 1))
    self.module:addSetting(Bool.new("TeamCheck", false))
end

function AimBot:onKey()
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

function AimBot:onEnable()
    print("AimBot enabled!")
    self.enabled = true
    self:drawFovCircle()
end

function AimBot:onDisable()
    print("AimBot disabled!")
    self.enabled = false
    if self.fovCircle then
        self.fovCircle:Remove()
        self.fovCircle = nil
    end
end

function AimBot:drawFovCircle()
    if self.fovCircle then
        self.fovCircle:Remove()
    end

    local fov = self.module:getSettingByName("FOV").value
    local radius = fov

    self.fovCircle = Drawing.new("Circle")
    self.fovCircle.Color = Color3.new(1, 0, 0)
    self.fovCircle.Thickness = 2
    self.fovCircle.Radius = radius
    self.fovCircle.Visible = true
    self.fovCircle.ZIndex = 2

    game:GetService("RunService").RenderStepped:Connect(function()
        if self.enabled then
            local mouse = game.Players.LocalPlayer:GetMouse()
            self.fovCircle.Position = Vector2.new(mouse.X, mouse.Y - 36)
        end
    end)
end

function AimBot:getClosestPlayer()
    local player = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera
    local fov = self.module:getSettingByName("FOV").value
    local teamCheck = self.module:getSettingByName("TeamCheck").value
    local mouse = player:GetMouse()

    local closestPlayer = nil
    local smallestScreenDistance = math.huge

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then  -- сорт по состоянию хп
                if not teamCheck or plr.Team ~= player.Team then
                    local head = plr.Character:FindFirstChild("Head")
                    local worldDistance = (camera.CFrame.Position - head.Position).Magnitude
                    if worldDistance <= 120 then  -- чек на дистанцию типо (чуть баганый)
                        local headScreenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local screenDistance = (Vector2.new(mouse.X, mouse.Y - 36) - Vector2.new(headScreenPos.X, headScreenPos.Y)).Magnitude
                            if screenDistance < smallestScreenDistance and screenDistance <= fov then
                                smallestScreenDistance = screenDistance
                                closestPlayer = plr
                            end
                        end
                    end
                end
            end
        end
    end

    return closestPlayer
end

function AimBot:update()
    local target = self:getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local camera = workspace.CurrentCamera
        local head = target.Character:FindFirstChild("Head")
        local sensitivity = self.module:getSettingByName("Sensitivity").value

        local currentCFrame = camera.CFrame
        local targetCFrame = CFrame.new(camera.CFrame.Position, head.Position)
        camera.CFrame = currentCFrame:Lerp(targetCFrame, sensitivity * 0.1)
    end
end


------------------------------------------------
-- DragPlayersToMe Module (инстанс)
------------------------------------------------
local DragPlayersToMe = {}
DragPlayersToMe.__index = DragPlayersToMe

function DragPlayersToMe.new()
    local self = setmetatable({}, DragPlayersToMe)
    self.module = addModule("DragPlayersToMe", "none", category.Misc)
    self:addSettings()
    self.radius = 50
    self.dragging = false
    self.originalPositions = {}
    return self
end

function DragPlayersToMe:addSettings()
    self.module:addSetting(Slider.new("Radius", 50, 0, 500, 1))
end

function DragPlayersToMe:onKey()
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

function DragPlayersToMe:onEnable()
    print("DragPlayersToMe enabled!")
    self.dragging = true
end

function DragPlayersToMe:onDisable()
    print("DragPlayersToMe disabled!")
    self.dragging = false
    self:resetPositions()
end

function DragPlayersToMe:update()
    if not self.dragging then return end

    local playerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    local radius = self.module:getSettingByName("Radius").value

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer and plr.Character then
            local humRootPart = plr.Character:FindFirstChild("HumanoidRootPart")
            if humRootPart then
                local distance = (humRootPart.Position - playerPosition).Magnitude
                if distance <= radius then
                    self.originalPositions[plr] = humRootPart.Position
                    humRootPart.CFrame = CFrame.new(playerPosition)
                end
            end
        end
    end
end

function DragPlayersToMe:resetPositions()
    for plr, position in pairs(self.originalPositions) do
        if plr.Character then
            local humRootPart = plr.Character:FindFirstChild("HumanoidRootPart")
            if humRootPart then
                humRootPart.CFrame = CFrame.new(position)
            end
        end
    end
    self.originalPositions = {}  -- Очистка записанных позиций
end


------------------------------------------------
-- InfinityJump Module (инстанс)
------------------------------------------------
local InfinityJump = {}
InfinityJump.__index = InfinityJump

function InfinityJump.new()
    local self = setmetatable({}, InfinityJump)
    self.module = addModule("InfinityJump", "none", category.Player)
    self:addSettings()
    self.enabled = false
    self.jumpConnection = nil
    return self
end

function InfinityJump:addSettings()
    self.module:addSetting(Bool.new("Enabled", false))
end

function InfinityJump:onKey()
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

function InfinityJump:onEnable()
    print("InfinityJump enabled!")
    self.enabled = true
    local UserInputService = game:GetService("UserInputService")
    if not self.jumpConnection then
        self.jumpConnection = UserInputService.JumpRequest:Connect(function()
            if self.enabled then
                local humanoid = getHumanoid()
                if humanoid then
                    humanoid.Jump = true
                    if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end)
    end
end

function InfinityJump:onDisable()
    print("InfinityJump disabled!")
    self.enabled = false
    if self.jumpConnection then
        self.jumpConnection:Disconnect()
        self.jumpConnection = nil
    end
end


------------------------------------------------
-- SpeedHack Module (инстанс)
------------------------------------------------
local SpeedHack = {}
SpeedHack.__index = SpeedHack

function SpeedHack.new()
    local self = setmetatable({}, SpeedHack)
    self.module = addModule("SpeedHack", "none", category.Player)
    self:addSettings()
    self.speed = 1
    self.originalWalkSpeed = 16
    return self
end

function SpeedHack:addSettings()
    self.module:addSetting(Slider.new("Speed", 16, 0.1, 100, 0.1))
end

function SpeedHack:onKey()
    print(self.module:getName() .. " key pressed!")
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

function SpeedHack:onEnable()
    local speed = self.module:getSettingByName("Speed").value
    self:setSpeed(speed)
end

function SpeedHack:onDisable()
    self:setSpeed(self.originalWalkSpeed)
end

function SpeedHack:setSpeed(speed)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        humanoid.WalkSpeed = speed
    end
end

function SpeedHack:update()
    if self.module.isEnabled then
        local speed = self.module:getSettingByName("Speed").value
        self:setSpeed(speed)
    end
end

------------------------------------------------
-- ESP Module (инстанс)
------------------------------------------------
local ESP = {}
ESP.__index = ESP

function ESP.new()
    local self = setmetatable({}, ESP)
    self.module = addModule("ESP", "G", category.Visual)
    self:addSettings()
    self.players = {}
    self.mode = "Box"
    return self
end

function ESP:addSettings()
    self.module:addSetting(Slider.new("Opacity", 0.5, 0, 1, 0.01))
    self.module:addSetting(Color.new("Color", Color3.fromRGB(255, 0, 0)))
    self.module:addSetting(Mode.new("Mode", "Box", {"Box", "Model"}))
end

function ESP:onKey()
    print(self.module:getName() .. " key pressed!")
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

function ESP:onEnable()
    for _, plr in ipairs(game.Players:GetPlayers()) do
        self:addPlayer(plr)
    end
end

function ESP:onDisable()
    for plr, _ in pairs(self.players) do
        self:removePlayer(plr)
    end
end

function ESP:addPlayer(plr)
    if self.players[plr] then return end
    local character = plr.Character or plr.CharacterAdded:Wait()
    if not character.PrimaryPart then
        character:GetPropertyChangedSignal("PrimaryPart"):Wait()
    end

    local data = {}
    local opacity = self.module:getSettingByName("Opacity").value
    local color = self.module:getSettingByName("Color").value
    self.mode = self.module:getSettingByName("Mode").value

    if self.mode == "Box" then
        -- Режим Box с использованием BoxHandleAdornment
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESPBox"
        box.Adornee = character.PrimaryPart
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Color3 = color
        box.Transparency = 1 - opacity
        box.Size = Vector3.new(2, 6, 2)
        box.CFrame = box.CFrame * CFrame.new(0, -2, 0)
        box.Parent = character.PrimaryPart
        data.box = box
    elseif self.mode == "Model" then
        local hl = Instance.new("Highlight")
        hl.Name = "ESP_Highlight"
        hl.FillColor = color
        hl.OutlineColor = Color3.new(0, 0, 0)
        hl.FillTransparency = 1 - opacity
        hl.OutlineTransparency = 0
        hl.Adornee = character
        hl.Parent = character
        data.highlight = hl
    end

    self.players[plr] = data
end

function ESP:removePlayer(plr)
    local data = self.players[plr]
    if data then
        if data.box and data.box.Parent then
            data.box:Destroy()
        end
        if data.highlight and data.highlight.Parent then
            data.highlight:Destroy()
        end
        self.players[plr] = nil
    end
end

function ESP:update()
    local opacity = self.module:getSettingByName("Opacity").value
    local color = self.module:getSettingByName("Color").value
    self.mode = self.module:getSettingByName("Mode").value

    for plr, data in pairs(self.players) do
        if plr.Character and plr.Character.PrimaryPart then
            if self.mode == "Box" and data.box then
                data.box.Enabled = true
                data.box.Transparency = 1 - opacity
                data.box.Color3 = color
                data.box.Size = Vector3.new(2, 6, 2)
                data.box.CFrame = plr.Character.PrimaryPart.CFrame * CFrame.new(0, -2, 0)
                data.box.Adornee = plr.Character.PrimaryPart
            elseif self.mode == "Model" and data.highlight then
                data.highlight.FillTransparency = 1 - opacity
                data.highlight.FillColor = color
            end
        end
    end
end

function ESP:rerender()
    local newMode = self.module:getSettingByName("Mode").value

    if self.mode ~= newMode then
        self.mode = newMode
    end

    for plr, data in pairs(self.players) do
        self:removePlayer(plr)
    end

    for _, plr in ipairs(game.Players:GetPlayers()) do
        self:addPlayer(plr)
    end
end

------------------------------------------------
-- GUI Module (инстанс)
------------------------------------------------
local GUI = {}
GUI.__index = GUI

function GUI.new()
    local self = setmetatable({}, GUI)
    self.module = addModule("GUI", "Y", category.Visual)
    self:addSettings()
    return self
end

function GUI:addSettings()
    self.module:addSetting(Bool.new("Enabled", false))
end

function GUI:onKey()
    print(self.module:getName() .. " key pressed!")
    self.module:toggle()
    if self.module.isEnabled then
        self:onEnable()
    else
        self:onDisable()
    end
end

function GUI:onEnable()
    renderPanel()
end

function GUI:update()
    if infiniteJumpEnabled and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end

function GUI:onDisable()
    print(self.module:getName() .. " has been disabled!")
    if guiFrame then
        guiFrame:Destroy()
        guiFrame = nil
    end
end

------------------------------------------------
-- Event system и Container system
------------------------------------------------
local modules = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function startEvent()
    game:GetService("RunService").RenderStepped:Connect(function()
        for _, mod in pairs(modules) do
            if mod.module.isEnabled and mod.update then
                mod:update()
            end
        end
    end)
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            for _, mod in pairs(modules) do
                if input.KeyCode.Name == mod.module:getKey() then
                    mod:onKey()
                end
            end
        end
    end)
    game.Players.PlayerAdded:Connect(function(plr)
        for _, mod in pairs(modules) do
            if mod.playerAdd then
                mod:playerAdd(plr)
            end
        end
    end)
    game.Players.PlayerRemoving:Connect(function(plr)
        for _, mod in pairs(modules) do
            if mod.playerRemove then
                mod:playerRemove(plr)
            end
        end
    end)
    UserInputService.JumpRequest:Connect(function()
        for _, mod in pairs(modules) do
            if mod.module.isEnabled then
                mod:onJump()
            end
        end
    end)
end
------------------------------------
function initModules()
    modules = {}
    local espModule = ESP.new()
    table.insert(modules, espModule)
    local guiModule = GUI.new()
    table.insert(modules, guiModule)
    local speedModule = SpeedHack.new()
    table.insert(modules, speedModule)
    local infinityJumpModule = InfinityJump.new()
    table.insert(modules, infinityJumpModule)
    local spiderModule = Spider.new()
    table.insert(modules, spiderModule)
    local aimbotModule = AimBotTest.new()
    table.insert(modules, aimbotModule)
    local aimbotModule2 = AimBot.new()
    table.insert(modules, aimbotModule2)
    local chinaHatModule = ChinaHat.new()
    table.insert(modules, chinaHatModule)
    local dragplayerstome = DragPlayersToMe.new()
    table.insert(modules, dragplayerstome)
    local noclip = NoClip.new()
    table.insert(modules, noclip)
    local strafe = Strafe.new()
    table.insert(modules, strafe)
    local lootfinder = LootFinder.new()
    table.insert(modules, lootfinder)
    local jumpcircles = JumpCircles.new()
    table.insert(modules, jumpcircles)
    local trails = Trails.new()
    table.insert(modules, trails)
    local fogcolor = FogColor.new()
    table.insert(modules, fogcolor)
    local nameview = NameView.new()
    table.insert(modules, nameview)
    local tracers = Tracers.new()
    table.insert(modules, tracers)
    local thirdperson = ThirdPerson.new()
    table.insert(modules, thirdperson)
    local autoclicker = AutoClicker.new()
    table.insert(modules, autoclicker)
    startEvent()
end

------------------------------------------------
-- GUI Rendering (работает с инстансами)
------------------------------------------------
local player = game.Players.LocalPlayer
local selectedCategory = nil
local selectedModule = nil
local guiFrame, moduleList, settingsList

local function getInstance(className, parent, properties)
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA(className) and child.Name == properties.Name then
            return child
        end
    end
    local inst = Instance.new(className)
    inst.Name = properties.Name
    for prop, value in pairs(properties) do
        if prop ~= "Name" then
            inst[prop] = value
        end
    end
    inst.Parent = parent
    return inst
end

function renderPanel()
    if guiFrame then
        guiFrame:Destroy()
    end

    local playerGui = player:WaitForChild("PlayerGui")
    local gui = playerGui:FindFirstChild("ShitWareGUI")
    if gui then gui:Destroy() end

    gui = getInstance("ScreenGui", playerGui, {
        Name = "ShitWareGUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    gui.Parent = playerGui

    guiFrame = Instance.new("Frame")
    guiFrame.Size = UDim2.new(0, 600, 0, 400)
    guiFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    guiFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    guiFrame.BorderSizePixel = 0
    guiFrame.ClipsDescendants = true
    guiFrame.BackgroundTransparency = 1
    guiFrame.ZIndex = 2
    guiFrame.Parent = gui

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 12)
    frameCorner.Parent = guiFrame

    TweenService:Create(guiFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0
    }):Play()

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    title.BorderSizePixel = 0
    title.Text = "ShitWare"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 30
    title.ZIndex = 3
    title.Parent = guiFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -18, 0, 12)
    closeBtn.AnchorPoint = Vector2.new(0.5, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.Text = ""
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 4
    closeBtn.Parent = title

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
        guiFrame = nil
    end)

    local dragging, dragInput, dragStart, startPos
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = guiFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local categoryFrame = Instance.new("Frame")
    categoryFrame.Size = UDim2.new(1, -20, 0, 60)
    categoryFrame.Position = UDim2.new(0, 10, 0, 60)
    categoryFrame.BackgroundTransparency = 1
    categoryFrame.ZIndex = 3
    categoryFrame.Parent = guiFrame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = categoryFrame

    for name, enum in pairs(category) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 90, 0, 35)
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Text = name
        button.Font = Enum.Font.GothamMedium
        button.TextSize = 16
        button.AutoButtonColor = false
        button.BorderSizePixel = 0
        button.ZIndex = 3
        button.Parent = categoryFrame

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = button

        button.MouseButton1Click:Connect(function()
            selectedCategory = enum
            renderModules()
        end)

        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            }):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            }):Play()
        end)
    end

    -- Модульный список со скроллингом
    moduleList = Instance.new("ScrollingFrame")
    moduleList.Size = UDim2.new(0.5, -15, 1, -130)
    moduleList.Position = UDim2.new(0, 10, 0, 130)
    moduleList.BackgroundTransparency = 1
    moduleList.ZIndex = 3
    moduleList.CanvasSize = UDim2.new(0, 0, 0, 0)
    moduleList.ScrollBarThickness = 4
    moduleList.ClipsDescendants = true
    moduleList.Parent = guiFrame

    -- Список настроек со скроллингом
    settingsList = Instance.new("ScrollingFrame")
    settingsList.Size = UDim2.new(0.5, -15, 1, -130)
    settingsList.Position = UDim2.new(0.5, 5, 0, 130)
    settingsList.BackgroundTransparency = 1
    settingsList.ZIndex = 3
    settingsList.CanvasSize = UDim2.new(0, 0, 0, 0)
    settingsList.ScrollBarThickness = 4
    settingsList.ClipsDescendants = true
    settingsList.Parent = guiFrame
end

function renderModules()
    if not moduleList or not settingsList then return end
    moduleList:ClearAllChildren()
    settingsList:ClearAllChildren()

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = moduleList

    for _, mod in ipairs(modules) do
        if mod.module:getCategory() == selectedCategory then
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, 0, 0, 30)
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            button.Font = Enum.Font.Gotham
            button.TextSize = 14
            button.BorderSizePixel = 0
            button.ZIndex = 3
            button.AutoButtonColor = false
            button.Parent = moduleList
            button.Text = mod.module:getName()

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = button

            if mod.module.isEnabled then
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextTransparency = 0
            else
                button.TextColor3 = Color3.fromRGB(180, 180, 180)
                button.TextTransparency = 0.3
            end

            button.MouseButton1Click:Connect(function()
                mod:onKey()
                if mod.module.isEnabled then
                    button.TextColor3 = Color3.fromRGB(255, 255, 255)
                    button.TextTransparency = 0
                else
                    button.TextColor3 = Color3.fromRGB(180, 180, 180)
                    button.TextTransparency = 0.3
                end
            end)

            button.MouseButton2Click:Connect(function()
                selectedModule = mod
                renderSettings(mod)
            end)
        end
    end

    -- Обновляем CanvasSize после добавления элементов
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        moduleList.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end)
end

function renderSettings(mod)
    settingsList:ClearAllChildren()

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = settingsList

    for _, sett in ipairs(mod.module:getSettings()) do
        if sett.type == setting.Slider then
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, 0, 0, 30)
            sliderFrame.BackgroundTransparency = 1
            sliderFrame.ZIndex = 3
            sliderFrame.Parent = settingsList

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.3, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = sett.name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.ZIndex = 3
            label.Parent = sliderFrame

            local sliderBg = Instance.new("Frame")
            sliderBg.Size = UDim2.new(0.65, 0, 0, 6)
            sliderBg.Position = UDim2.new(0.33, 0, 0.5, -3)
            sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            sliderBg.BorderSizePixel = 0
            sliderBg.ZIndex = 3
            sliderBg.Parent = sliderFrame

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((sett.value - sett.min) / (sett.max - sett.min), 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(80, 170, 255)
            fill.BorderSizePixel = 0
            fill.ZIndex = 3
            fill.Parent = sliderBg

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 12, 0, 12)
            knob.Position = UDim2.new(fill.Size.X.Scale, -6, 0.5, -6)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.ZIndex = 4
            knob.Parent = sliderBg

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = knob

            local dragging = false
            knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            knob.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = input.Position
                    local sliderWidth = sliderBg.AbsoluteSize.X
                    local newPos = math.clamp((mousePos.X - sliderBg.AbsolutePosition.X) / sliderWidth, 0, 1)
                    sett.value = sett.min + newPos * (sett.max - sett.min)
                    fill.Size = UDim2.new(newPos, 0, 1, 0)
                    knob.Position = UDim2.new(newPos, -6, 0.5, -6)
                    for _, m in ipairs(modules) do
                        if m.update then m:update() end
                    end
                end
            end)
        elseif sett.type == setting.Bool then
            local checkFrame = Instance.new("Frame")
            checkFrame.Size = UDim2.new(1, 0, 0, 24)
            checkFrame.BackgroundTransparency = 1
            checkFrame.ZIndex = 3
            checkFrame.Parent = settingsList

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.85, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = sett.name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.ZIndex = 3
            label.Parent = checkFrame

            local box = Instance.new("TextButton")
            box.Size = UDim2.new(0, 20, 0, 20)
            box.Position = UDim2.new(1, -25, 0.5, -10)
            box.BackgroundColor3 = sett.value and Color3.fromRGB(80, 170, 255) or Color3.fromRGB(60, 60, 60)
            box.Text = sett.value and "✓" or ""
            box.TextColor3 = Color3.fromRGB(255, 255, 255)
            box.Font = Enum.Font.Gotham
            box.TextSize = 16
            box.AutoButtonColor = false
            box.ZIndex = 4
            box.Parent = checkFrame

            box.MouseButton1Click:Connect(function()
                sett.value = not sett.value
                box.Text = sett.value and "✓" or ""
                box.BackgroundColor3 = sett.value and Color3.fromRGB(80, 170, 255) or Color3.fromRGB(60, 60, 60)
                for _, m in ipairs(modules) do
                    if m.update then m:update() end
                end
            end)
        elseif sett.type == setting.Mode then
            local modeFrame = Instance.new("Frame")
            modeFrame.Size = UDim2.new(1, 0, 0, 30)
            modeFrame.BackgroundTransparency = 1
            modeFrame.ZIndex = 3
            modeFrame.Parent = settingsList

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.3, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = sett.name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.ZIndex = 3
            label.Parent = modeFrame

            local dropdown = Instance.new("TextButton")
            dropdown.Size = UDim2.new(0.6, 0, 1, 0)
            dropdown.Position = UDim2.new(0.35, 0, 0, 0)
            dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            dropdown.Text = sett.value
            dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
            dropdown.Font = Enum.Font.Gotham
            dropdown.TextSize = 14
            dropdown.ZIndex = 4
            dropdown.Parent = modeFrame

            local isOpen = false
            local optionFrame

            dropdown.MouseButton1Click:Connect(function()
                if isOpen then
                    if optionFrame then optionFrame:Destroy() end
                    isOpen = false
                else
                    isOpen = true
                    optionFrame = Instance.new("Frame")
                    optionFrame.Size = UDim2.new(0.6, 0, 0, #sett.modes * 25)
                    optionFrame.Position = UDim2.new(0.35, 0, 1, 0)
                    optionFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    optionFrame.BorderSizePixel = 0
                    optionFrame.ZIndex = 5
                    optionFrame.Parent = modeFrame

                    for i, v in ipairs(sett.modes) do
                        local option = Instance.new("TextButton")
                        option.Size = UDim2.new(1, 0, 0, 25)
                        option.Position = UDim2.new(0, 0, 0, (i - 1) * 25)
                        option.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                        option.Text = v
                        option.TextColor3 = Color3.fromRGB(255, 255, 255)
                        option.Font = Enum.Font.Gotham
                        option.TextSize = 14
                        option.ZIndex = 6
                        option.Parent = optionFrame

                        option.MouseButton1Click:Connect(function()
                            sett.value = v
                            dropdown.Text = v
                            optionFrame:Destroy()
                            isOpen = false

                            for _, m in ipairs(modules) do
                                if m == mod and m.update then m:update() end
                            end
                        end)
                    end
                end
            end)
        elseif sett.type == setting.Color then
            local colorFrame = Instance.new("Frame")
            colorFrame.Size = UDim2.new(1, 0, 0, 30)
            colorFrame.BackgroundTransparency = 1
            colorFrame.ZIndex = 3
            colorFrame.Parent = settingsList

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.3, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = sett.name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.Font = Enum.Font.Gotham
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.ZIndex = 3
            label.Parent = colorFrame

            local colorButton = Instance.new("TextButton")
            colorButton.Size = UDim2.new(0.65, 0, 0, 24)
            colorButton.Position = UDim2.new(0.33, 0, 0.5, -12)
            colorButton.BackgroundColor3 = sett.value
            colorButton.Text = ""
            colorButton.AutoButtonColor = false
            colorButton.ZIndex = 3
            colorButton.Parent = colorFrame

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = colorButton

            colorButton.MouseButton1Click:Connect(function()
                createColorPicker(sett, colorButton)
            end)
        end
    end

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        settingsList.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end)
end

function createColorPicker(sett, colorButton)
    local colorPickerFrame = Instance.new("Frame")
    colorPickerFrame.Size = UDim2.new(0,300,0,150)
    colorPickerFrame.Position = UDim2.new(0.5,-150,0.25,-75)
    colorPickerFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    colorPickerFrame.BorderSizePixel = 0
    colorPickerFrame.ClipsDescendants = true
    colorPickerFrame.ZIndex = 2
    colorPickerFrame.Parent = player:WaitForChild("PlayerGui"):WaitForChild("ShitWareGUI")

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0,12)
    frameCorner.Parent = colorPickerFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,30)
    title.Position = UDim2.new(0,0,0,0)
    title.BackgroundColor3 = Color3.fromRGB(30,30,30)
    title.BorderSizePixel = 0
    title.Text = "Color Picker"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 3
    title.Parent = colorPickerFrame

    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1,-20,0,50)
    inputFrame.Position = UDim2.new(0,10,0,40)
    inputFrame.BackgroundTransparency = 1
    inputFrame.ZIndex = 3
    inputFrame.Parent = colorPickerFrame

    local rInput = Instance.new("TextBox")
    rInput.Size = UDim2.new(0.3,0,1,0)
    rInput.Position = UDim2.new(0,0,0,0)
    rInput.BackgroundColor3 = Color3.fromRGB(50,50,50)
    rInput.BorderSizePixel = 0
    rInput.TextColor3 = Color3.fromRGB(255,255,255)
    rInput.PlaceholderText = "R (0-255)"
    rInput.Font = Enum.Font.Gotham
    rInput.TextSize = 14
    rInput.ZIndex = 3
    rInput.Parent = inputFrame

    local gInput = Instance.new("TextBox")
    gInput.Size = UDim2.new(0.3,0,1,0)
    gInput.Position = UDim2.new(0.35,0,0,0)
    gInput.BackgroundColor3 = Color3.fromRGB(50,50,50)
    gInput.BorderSizePixel = 0
    gInput.TextColor3 = Color3.fromRGB(255,255,255)
    gInput.PlaceholderText = "G (0-255)"
    gInput.Font = Enum.Font.Gotham
    gInput.TextSize = 14
    gInput.ZIndex = 3
    gInput.Parent = inputFrame

    local bInput = Instance.new("TextBox")
    bInput.Size = UDim2.new(0.3,0,1,0)
    bInput.Position = UDim2.new(0.7,0,0,0)
    bInput.BackgroundColor3 = Color3.fromRGB(50,50,50)
    bInput.BorderSizePixel = 0
    bInput.TextColor3 = Color3.fromRGB(255,255,255)
    bInput.PlaceholderText = "B (0-255)"
    bInput.Font = Enum.Font.Gotham
    bInput.TextSize = 14
    bInput.ZIndex = 3
    bInput.Parent = inputFrame

    local currentColor = sett.value
    local r = math.floor(currentColor.R * 255)
    local g = math.floor(currentColor.G * 255)
    local b = math.floor(currentColor.B * 255)
    rInput.Text = tostring(r)
    gInput.Text = tostring(g)
    bInput.Text = tostring(b)

    local applyButton = Instance.new("TextButton")
    applyButton.Size = UDim2.new(0,100,0,30)
    applyButton.Position = UDim2.new(0.5,-50,1,-40)
    applyButton.BackgroundColor3 = Color3.fromRGB(60,180,60)
    applyButton.TextColor3 = Color3.fromRGB(255,255,255)
    applyButton.Text = "Готово"
    applyButton.Font = Enum.Font.Gotham
    applyButton.TextSize = 16
    applyButton.ZIndex = 3
    applyButton.Parent = colorPickerFrame

    local applyCorner = Instance.new("UICorner")
    applyCorner.CornerRadius = UDim.new(0,8)
    applyCorner.Parent = applyButton

    local dragging, dragInput, dragStart, startPos
    colorPickerFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = colorPickerFrame.Position
        end
    end)
    colorPickerFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            colorPickerFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    colorPickerFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    applyButton.MouseButton1Click:Connect(function()
        local r = tonumber(rInput.Text) or 0
        local g = tonumber(gInput.Text) or 0
        local b = tonumber(bInput.Text) or 0
        r = math.clamp(r,0,255)
        g = math.clamp(g,0,255)
        b = math.clamp(b,0,255)
        local newColor = Color3.fromRGB(r,g,b)
        sett.value = newColor
        colorButton.BackgroundColor3 = newColor
        colorPickerFrame:Destroy()
        for _, m in ipairs(modules) do
            if m.update then m:update() end
        end
    end)
end
-- Start
function start()
    initModules()
end

start()

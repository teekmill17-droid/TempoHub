local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- ==================== KONFIGURASI ====================
local CONFIG = {
    Keybind = Enum.KeyCode.B,
    MaxDistance = 50,
}

-- ==================== VARIABEL ====================
local isActive = false
local currentTarget = nil
local gui = nil

-- ==================== FUNGSI CEK SURVIVOR ====================
local function IsSurvivor(p)
    return p.Team and p.Team.Name == "Survivors"
end

local function IsDowned(character)
    if not character then return true end
    if character:GetAttribute("Knocked") == true then return true end
    if character:GetAttribute("IsHooked") == true then return true end
    local hum = character:FindFirstChild("Humanoid")
    if hum and hum.Health <= 0 then return true end
    return false
end

local function GetClosestSurvivor()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local bestTarget = nil
    local bestDistance = CONFIG.MaxDistance + 1
    
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and IsSurvivor(otherPlayer) then
            if IsDowned(otherPlayer.Character) then
                -- skip yang down
            else
                local otherHrp = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                local otherHum = otherPlayer.Character:FindFirstChild("Humanoid")
                
                if otherHrp and otherHum and otherHum.Health > 0 then
                    local distance = (otherHrp.Position - hrp.Position).Magnitude
                    
                    if distance <= CONFIG.MaxDistance and distance < bestDistance then
                        bestDistance = distance
                        bestTarget = otherHrp
                    end
                end
            end
        end
    end
    
    return bestTarget
end

local function UpdateAim()
    if not isActive then 
        currentTarget = nil
        return 
    end
    
    local targetPart = GetClosestSurvivor()
    if not targetPart then 
        currentTarget = nil
        return 
    end
    
    currentTarget = targetPart
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Position)
end

local function StartAimLock()
    if isActive then return end
    isActive = true
    
    if gui and gui:FindFirstChild("Frame") then
        local btn = gui.Frame:FindFirstChild("ActionButton")
        if btn then
            btn.Text = "🎯 AIM LOCK [ON]"
            btn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
        end
    end
end

local function StopAimLock()
    if not isActive then return end
    isActive = false
    currentTarget = nil
    
    if gui and gui:FindFirstChild("Frame") then
        local btn = gui.Frame:FindFirstChild("ActionButton")
        if btn then
            btn.Text = "🎯 AIM LOCK [OFF]"
            btn.BackgroundColor3 = Color3.fromRGB(255, 140, 50)
        end
    end
end

local function ToggleAimLock()
    if isActive then StopAimLock() else StartAimLock() end
end

-- ==================== GUI ====================
local function CreateGUI()
    -- Tunggu PlayerGui dulu
    local playerGui = player:WaitForChild("PlayerGui", 5)
    if not playerGui then 
        warn("PlayerGui not found!")
        return false
    end
    
    gui = Instance.new("ScreenGui")
    gui.Name = "AimLockGui"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.Parent = gui
    frame.Size = UDim2.fromOffset(180, 80)
    frame.Position = UDim2.fromScale(0.75, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    frame.BackgroundTransparency = 0.1
    frame.Active = true
    frame.Draggable = true
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke")
    stroke.Parent = frame
    stroke.Color = Color3.fromRGB(255, 70, 70)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3

    local title = Instance.new("TextLabel")
    title.Parent = frame
    title.Size = UDim2.new(1, -48, 0, 22)
    title.Position = UDim2.fromOffset(0, 3)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 11
    title.TextColor3 = Color3.fromRGB(255, 70, 70)
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Text = "🎯 Aim Lock"

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Parent = frame
    minimizeBtn.Size = UDim2.fromOffset(18, 18)
    minimizeBtn.Position = UDim2.new(1, -44, 0, 4)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    minimizeBtn.Text = "—"
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 12
    minimizeBtn.BorderSizePixel = 0
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 5)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = frame
    closeBtn.Size = UDim2.fromOffset(18, 18)
    closeBtn.Position = UDim2.new(1, -22, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    closeBtn.Text = "✕"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 10
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

    local keybindLbl = Instance.new("TextLabel")
    keybindLbl.Parent = frame
    keybindLbl.Size = UDim2.new(1,0,0,14)
    keybindLbl.Position = UDim2.fromOffset(0, 26)
    keybindLbl.BackgroundTransparency = 1
    keybindLbl.Font = Enum.Font.Gotham
    keybindLbl.TextSize = 9
    keybindLbl.TextColor3 = Color3.fromRGB(180,180,180)
    keybindLbl.TextXAlignment = Enum.TextXAlignment.Center
    keybindLbl.Text = "Press B (ON/OFF)"

    local button = Instance.new("TextButton")
    button.Name = "ActionButton"
    button.Size = UDim2.fromOffset(140, 30)
    button.Position = UDim2.fromOffset(20, 45)
    button.BackgroundColor3 = Color3.fromRGB(255, 140, 50)
    button.Text = "🎯 AIM LOCK [OFF]"
    button.Font = Enum.Font.GothamBold
    button.TextSize = 10
    button.TextColor3 = Color3.new(1,1,1)
    button.BorderSizePixel = 0
    button.Parent = frame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

    button.MouseEnter:Connect(function()
        if not isActive then
            button.BackgroundColor3 = Color3.fromRGB(255, 170, 80)
        end
    end)
    button.MouseLeave:Connect(function()
        if not isActive then
            button.BackgroundColor3 = Color3.fromRGB(255, 140, 50)
        end
    end)

    button.MouseButton1Click:Connect(ToggleAimLock)

    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            frame.Size = UDim2.fromOffset(180, 28)
            keybindLbl.Visible = false
            button.Visible = false
            minimizeBtn.Text = "+"
        else
            frame.Size = UDim2.fromOffset(180, 80)
            keybindLbl.Visible = true
            button.Visible = true
            minimizeBtn.Text = "—"
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        StopAimLock()
        gui:Destroy()
        gui = nil
    end)
    
    return true
end

-- ==================== LOOP ====================
RunService.RenderStepped:Connect(function()
    if isActive then
        UpdateAim()
    end
end)

-- ==================== KEYBIND ====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == CONFIG.Keybind then
        ToggleAimLock()
    end
end)

-- ==================== CLEANUP ====================
player.CharacterAdded:Connect(function()
    if isActive then
        StopAimLock()
    end
    currentTarget = nil
end)

-- ==================== INIT ====================
local success, err = pcall(CreateGUI)
if success then
    print("✅ Aim Lock Loaded! Target: SURVIVOR (skips downed players) | Press B to toggle")
else
    warn("❌ Error: " .. tostring(err))
end
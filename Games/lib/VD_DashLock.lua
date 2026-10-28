-- ============================================
-- DASH LOCK - TEMPO HUB
-- ============================================
-- PC: Langsung aktif pas toggle ON
-- HP: Muncul GUI button di layar
-- ============================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LocalPlayer = player

-- ===== VARIABEL =====
local DashLockState = false
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local DashLockGui = nil
local GuiVisible = false
local WatermarkPrinted = false

local DASH_ANIM_IDS = {
    ["113255068724446"] = true,
    ["98163597193511"] = true,
    ["74968262036854"] = true,
}

-- Dash Lock internal
local DashLockData = {
    isAimLocking = false,
    currentTarget = nil,
    lockTimerThread = nil,
    RenderConn = nil,
    InputConn = nil,
    MobileLoop = nil,
    AnimConn = nil,
    lastAimLockTime = 0,
}

-- ===== HELPER FUNCTIONS =====
local function GetRole()
    local t = LocalPlayer.Team
    return (t and t.Name) or "Unknown"
end

local function IsDownedDash(character)
    if not character then return true end
    if character:GetAttribute("Knocked") == true then return true end
    if character:GetAttribute("IsHooked") == true then return true end
    local hum = character:FindFirstChild("Humanoid")
    if hum and hum.Health <= 0 then return true end
    return false
end

local function GetClosestSurvivor()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    if not myHRP then return nil end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = p.Character:FindFirstChild("Humanoid")
            local isSurvivor = p.Team and p.Team.Name == "Survivors"
            
            if isSurvivor and humanoid and humanoid.Health > 0 and not IsDownedDash(p.Character) then
                local targetHRP = p.Character.HumanoidRootPart
                local distance = (myHRP.Position - targetHRP.Position).Magnitude
                
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = p.Character
                end
            end
        end
    end
    return closestPlayer
end

local function StopDashAimLock()
    DashLockData.isAimLocking = false
    DashLockData.currentTarget = nil
    pcall(function()
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end)
    local th = DashLockData.lockTimerThread
    DashLockData.lockTimerThread = nil
    if th then
        pcall(task.cancel, th)
    end
end

local function AnimIdOf(track)
    local a = track and track.Animation
    if not a then return nil end
    return tostring(a.AnimationId):gsub("%D", "")
end

-- ===== TRIGGER LOCK =====
local function TriggerDashLock()
    if DashLockData.isAimLocking then return end
    if tick() - DashLockData.lastAimLockTime < 0.2 then return end
    DashLockData.lastAimLockTime = tick()
    
    if GetRole() == "Killer" then
        DashLockData.currentTarget = GetClosestSurvivor()
        
        if DashLockData.currentTarget and DashLockData.currentTarget:FindFirstChild("HumanoidRootPart") then
            DashLockData.isAimLocking = true
            
            if DashLockData.lockTimerThread then
                pcall(task.cancel, DashLockData.lockTimerThread)
                DashLockData.lockTimerThread = nil
            end

            local targetChar = DashLockData.currentTarget
            local startHum = targetChar:FindFirstChildOfClass("Humanoid")
            local startHp = startHum and startHum.Health or nil

            DashLockData.lockStarted = tick()
            -- fallback, lepas utama dari anim.Stopped
            DashLockData.lockTimerThread = task.delay(1.05, function()
                if DashLockData.isAimLocking then
                    StopDashAimLock()
                end
            end)

            -- lepas saat down, atau HP berkurang saat dash ini
            task.spawn(function()
                local t0 = tick()
                while DashLockData.isAimLocking and targetChar and targetChar.Parent and tick() - t0 < 1.2 do
                    if IsDownedDash(targetChar) then
                        StopDashAimLock()
                        return
                    end
                    local hum = targetChar:FindFirstChildOfClass("Humanoid")
                    if hum and startHp and hum.Health < startHp then
                        StopDashAimLock()
                        return
                    end
                    task.wait(0.05)
                end
            end)
        end
    end
end

local function WatchDashAnim()
    if DashLockData.AnimConn then
        DashLockData.AnimConn:Disconnect()
        DashLockData.AnimConn = nil
    end

    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end

    DashLockData.AnimConn = animator.AnimationPlayed:Connect(function(track)
        if not DashLockState then return end
        if GetRole() ~= "Killer" then return end
        local id = AnimIdOf(track)
        if not id or not DASH_ANIM_IDS[id] then return end

        TriggerDashLock()

        local stopped
        stopped = track.Stopped:Connect(function()
            if stopped then stopped:Disconnect() end
            StopDashAimLock()
        end)
    end)   -- (port) these two closers were missing upstream: the file never compiled
end

-- ===== UPDATE EFFECT =====
local function UpdateDashLockEffect()
    if DashLockState then
        -- START DASH LOCK
        pcall(function() RunService:UnbindFromRenderStep("TempoDashLockCam") end)
        DashLockData.RenderConn = nil
        if DashLockData.InputConn then DashLockData.InputConn:Disconnect() end
        if DashLockData.MobileLoop then
            pcall(task.cancel, DashLockData.MobileLoop)
            DashLockData.MobileLoop = nil
        end
        
        WatchDashAnim()

        -- RenderStepped untuk lock camera
        RunService:BindToRenderStep("TempoDashLockCam", Enum.RenderPriority.Camera.Value + 1, function()
        DashLockData.RenderConn = true
            if not DashLockData.isAimLocking then return end
            local target = DashLockData.currentTarget
            local tHrp = target and target:FindFirstChild("HumanoidRootPart")
            if not tHrp then
                StopDashAimLock()
                return
            end
            if IsDownedDash(target) then
                StopDashAimLock()
                return
            end

            local myChar = LocalPlayer.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local cam = workspace.CurrentCamera
            local predict = tHrp.Position + (tHrp.AssemblyLinearVelocity * 0.16)

            if myHrp then
                local started = DashLockData.lockStarted or 0
                if tick() - started > 0.18 then
                    local toTarget = tHrp.Position - myHrp.Position
                    local flat = Vector3.new(toTarget.X, 0, toTarget.Z)
                    local vel = myHrp.AssemblyLinearVelocity
                    local flatVel = Vector3.new(vel.X, 0, vel.Z)
                    if flat.Magnitude > 1.2 and flatVel.Magnitude > 10 then
                        if flatVel.Unit:Dot(flat.Unit) < -0.2 then
                            StopDashAimLock()
                            return
                        end
                    end
                end

                local face = Vector3.new(predict.X - myHrp.Position.X, 0, predict.Z - myHrp.Position.Z)
                if face.Magnitude > 0.2 then
                    myHrp.CFrame = CFrame.lookAt(myHrp.Position, myHrp.Position + face)
                end
            end

            pcall(function()
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            end)
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, predict)
        end)

        -- Lock hanya dari animasi dash (jangan dari tombol, biar ga lock sebelum dash)
        DashLockData.InputConn = nil
        DashLockData.MobileLoop = nil
        
        -- PRINT 1 KALI DI CONSOLE
        if not WatermarkPrinted then
            WatermarkPrinted = true
            print("TEMPO HUB DASH LOCK")
        end
        
    else
        -- STOP DASH LOCK
        pcall(function() RunService:UnbindFromRenderStep("TempoDashLockCam") end)
        DashLockData.RenderConn = nil
        if DashLockData.InputConn then 
            DashLockData.InputConn:Disconnect() 
            DashLockData.InputConn = nil
        end
        if DashLockData.MobileLoop then
            pcall(task.cancel, DashLockData.MobileLoop)
            DashLockData.MobileLoop = nil
        end
        if DashLockData.AnimConn then
            DashLockData.AnimConn:Disconnect()
            DashLockData.AnimConn = nil
        end
        DashLockData.isAimLocking = false
        DashLockData.currentTarget = nil
        if DashLockData.lockTimerThread then
            pcall(task.cancel, DashLockData.lockTimerThread)
            DashLockData.lockTimerThread = nil
        end
    end
    
    -- Update GUI button
    pcall(function()
        if DashLockGui then
            local frame = DashLockGui:FindFirstChild("Frame")
            if frame then
                local btn = frame:FindFirstChild("ActionButton")
                local stroke = frame:FindFirstChild("UIStroke")
                if btn then
                    if DashLockState then
                        btn.Text = "DASH LOCK [ON]"
                        btn.TextColor3 = Color3.fromRGB(180, 255, 180)
                        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                    else
                        btn.Text = "DASH LOCK [OFF]"
                        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                    end
                end
                if stroke then
                    stroke.Color = DashLockState and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(90, 90, 95)
                end
            end
        end
    end)
end

-- ===== TOGGLE =====
local function ToggleDashLock()
    DashLockState = not DashLockState
    UpdateDashLockEffect()
end

-- ===== GUI =====
local function createGUI()
    if DashLockGui then DashLockGui:Destroy(); DashLockGui = nil end
    
    if not isMobile then return end
    
    local parent = CoreGui
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "DashLockCustomGui"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = parent
    gui.Enabled = false
    
    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.Parent = gui
    frame.Size = UDim2.fromOffset(110, 36)
    frame.Position = UDim2.fromScale(0.85, 0.49)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BackgroundTransparency = 0.1
    frame.Active = true
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke")
    stroke.Name = "UIStroke"
    stroke.Parent = frame
    stroke.Color = Color3.fromRGB(90, 90, 95)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.2
    
    local button = Instance.new("TextButton")
    button.Name = "ActionButton"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.Text = "DASH LOCK [OFF]"
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Parent = frame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    
    -- DRAG
    local dragging, dragMoved, canDrag = false, false, false
    local dragStart, startPos, holdThread = nil, nil, nil
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragMoved = false
            canDrag = false
            dragStart = input.Position
            startPos = frame.Position
            if holdThread then task.cancel(holdThread) end
            holdThread = task.delay(0.18, function()
                if dragging then canDrag = true end
            end)
        end
    end)
    
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if holdThread then task.cancel(holdThread) end
            if dragging and not dragMoved then
                ToggleDashLock()
            end
            dragging = false
            dragMoved = false
            canDrag = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and canDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if not dragMoved and (math.abs(delta.X) > 18 or math.abs(delta.Y) > 18) then
                dragMoved = true
            end
            if dragMoved then
                frame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
    
    DashLockGui = gui
    GuiVisible = false
    if DashLockGui then
        DashLockGui.Enabled = false
    end
    UpdateDashLockEffect()
end

-- ===== SHOW/HIDE GUI =====
local function showGUI()
    if not isMobile then return end
    if DashLockGui then
        DashLockGui.Enabled = true
        GuiVisible = true
        UpdateDashLockEffect()
    else
        createGUI()
        if DashLockGui then
            DashLockGui.Enabled = true
            GuiVisible = true
        end
    end
end

local function hideGUI()
    if DashLockGui then
        DashLockGui.Enabled = false
        GuiVisible = false
    end
end

-- Keybind di-handle script utama (jangan dobel)

-- ===== CHARACTER ADDED =====
player.CharacterAdded:Connect(function()
    task.wait(1)
    if DashLockState then
        StopDashAimLock()
        WatchDashAnim()
    end
    if isMobile and DashLockGui and DashLockGui.Parent then
        DashLockGui.Enabled = (GuiVisible == true)
        if GuiVisible then
            UpdateDashLockEffect()
        end
    end
end)

-- ===== INIT =====
task.spawn(function()
    task.wait(1)
    if isMobile then
        createGUI()
        GuiVisible = false
        if DashLockGui then
            DashLockGui.Enabled = false
        end
    end
end)

-- ===== PUBLIC API =====
return {
    Toggle = ToggleDashLock,
    Enable = function() 
        if not DashLockState then ToggleDashLock() end
    end,
    Disable = function() 
        if DashLockState then ToggleDashLock() end
    end,
    IsActive = function() return DashLockState end,
    ShowGUI = showGUI,
    HideGUI = hideGUI,
}
--[[
    Controller on a phone: what does the game actually read?

    This is the one thing that cannot be reasoned out from here.

    On PC, RH2's shot loop polls IsKeyDown(E) and IsGamepadButtonDown(Gamepad1,
    ButtonX) - so suppressing those ends the shot, which is what hold mode does.

    On mobile, the loop reads a boolean upvalue the touch button's own handler
    owns - measured by bisection, and the reason the mobile release works by
    debug.setupvalue rather than by any input trick.

    With a pad paired to a phone the game could be running EITHER. If it is on
    the mobile path, suppressing the gamepad button cannot end anything and
    hold mode will never work there no matter how it is wired.

    Run this, then take a shot with the CONTROLLER and hold X until it prints.
    It does not change anything - it only watches.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

if getgenv().TeekPadStop then pcall(getgenv().TeekPadStop) end

local sg = Instance.new("ScreenGui")
sg.Name = "TeekPadOnPhone"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 2000000
pcall(function() sg.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not sg.Parent then sg.Parent = lp:WaitForChild("PlayerGui") end

local f = Instance.new("Frame")
f.Size = UDim2.fromOffset(430, 250)
f.Position = UDim2.fromOffset(8, 8)
f.BackgroundColor3 = Color3.fromRGB(6, 9, 16)
f.BackgroundTransparency = 0.1
f.BorderSizePixel = 0
f.Active = false
f.Parent = sg

local body = Instance.new("TextLabel")
body.Size = UDim2.new(1, -10, 1, -8)
body.Position = UDim2.fromOffset(5, 4)
body.BackgroundTransparency = 1
body.Font = Enum.Font.Code
body.TextSize = 13
body.TextColor3 = Color3.fromRGB(226, 236, 247)
body.TextXAlignment = Enum.TextXAlignment.Left
body.TextYAlignment = Enum.TextYAlignment.Top
body.TextWrapped = true
body.Active = false
body.Parent = f

local lines = {}
local function log(fmt, ...)
    local ok, m = pcall(string.format, fmt, ...)
    lines[#lines + 1] = ok and m or tostring(fmt)
    while #lines > 16 do table.remove(lines, 1) end
    body.Text = table.concat(lines, "\n")
end

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(104, 40)
close.Position = UDim2.fromOffset(8, 262)
close.BackgroundColor3 = Color3.fromRGB(27, 74, 128)
close.Text = "CLOSE"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Font = Enum.Font.GothamBold
close.TextSize = 13
close.BorderSizePixel = 0
close.Parent = sg
close.MouseButton1Click:Connect(function()
    if getgenv().TeekPadStop then getgenv().TeekPadStop() end
end)

-- ---------------------------------------------------------------- device
local pads = {}
do
    local ok, list = pcall(function() return UIS:GetConnectedGamepads() end)
    if ok and type(list) == "table" then
        for _, g in ipairs(list) do pads[#pads + 1] = tostring(g) end
    end
end
log("touch=%s kb=%s pad=%s", tostring(UIS.TouchEnabled),
    tostring(UIS.KeyboardEnabled), tostring(UIS.GamepadEnabled))
log("connected pads: %s", #pads > 0 and table.concat(pads, ",") or "NONE")
log("last input: %s", tostring(UIS:GetLastInputType()))

local function power()
    local bp = lp:FindFirstChild("Backpack")
    local av = bp and bp:FindFirstChild("ActionValues")
    local p = av and av:FindFirstChild("Power")
    return p and p.Value or -1
end

local function shootBtn()
    local pg = lp:FindFirstChild("PlayerGui")
    local tg = pg and pg:FindFirstChild("TouchGui")
    local fr = tg and tg:FindFirstChild("TouchControlFrame")
    local sb = fr and fr:FindFirstChild("ShootBTN")
    if not sb then return nil end
    return sb:FindFirstChild("ButtonDetect") or sb
end

local GC do
    local ok, fn = pcall(function() return getconnections end)
    GC = (ok and type(fn) == "function") and fn or nil
end

log("press X on the pad and hold it through a shot.")

local padSeen = false
UIS.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.ButtonX and not padSeen then
        padSeen = true
        log("ButtonX InputBegan fired  (type=%s)", tostring(i.UserInputType))
    end
end)

-- ---------------------------------------------------------------- watch
task.spawn(function()
    local live, peak, reported = false, 0, false
    while sg.Parent do
        local p = power()
        if p > 0 then
            if not live then live, peak, reported = true, p, false end
            if p > peak then peak = p end

            -- Sampled once per shot, at a point where the shot is definitely
            -- running, so the answer is about THIS shot rather than idle state.
            if not reported and p > 25 then
                reported = true
                local down = false
                pcall(function()
                    down = UIS:IsGamepadButtonDown(Enum.UserInputType.Gamepad1,
                        Enum.KeyCode.ButtonX)
                end)
                local kd = false
                pcall(function() kd = UIS:IsKeyDown(Enum.KeyCode.E) end)

                local sb = shootBtn()
                local nConn = 0
                if GC and sb then
                    local ok, c = pcall(GC, sb.MouseButton1Down)
                    if ok and type(c) == "table" then nConn = #c end
                end

                log("--- mid shot, power %.0f ---", p)
                log("IsGamepadButtonDown(X) = %s", tostring(down))
                log("IsKeyDown(E)           = %s", tostring(kd))
                log("ShootBTN on screen     = %s", sb and "yes" or "no")
                log("its Down handlers      = %d", nConn)
                -- The verdict. If the pad button reads down, the PC loop is
                -- what is running and hold mode can end it. If it does not but
                -- the touch button has handlers, the game is on the mobile
                -- path and only setupvalue can.
                if down then
                    log(">>> PC PATH - hold mode can work here")
                elseif nConn > 0 then
                    log(">>> MOBILE PATH - needs the setupvalue route")
                else
                    log(">>> NEITHER - screenshot this, it is a third case")
                end
            end
        elseif live then
            live = false
            log("shot ended at %.1f", peak)
            peak = 0
        end
        RunService.Heartbeat:Wait()
    end
end)

getgenv().TeekPadStop = function()
    pcall(function() sg:Destroy() end)
    pcall(function() close:Destroy() end)
    getgenv().TeekPadStop = nil
end

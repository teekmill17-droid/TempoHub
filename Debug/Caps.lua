--[[
    What can this executor actually do, and what does that mean for hold mode?

    PadOnPhone settled that the game IS on the PC loop with a pad attached:
    IsGamepadButtonDown(X) read true mid-shot and the touch button had no
    handlers. So hold mode is aimed at the right loop. It still did not end the
    shot, which leaves exactly one question - can this client hook?

    holdMethod() picks a route like this:

        hookmetamethod present  ->  "hook"   works for a pad
        else KeyboardEnabled    ->  "vim"    keyboard only
        else                    ->  nil      hold mode never arms

    On a phone KeyboardEnabled is false, so a missing hookmetamethod means the
    middle branch cannot save it and hold mode is off before it starts.

    This reads capabilities and prints the decision. It changes nothing.
]]

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

if getgenv().TeekCapsStop then pcall(getgenv().TeekCapsStop) end

local sg = Instance.new("ScreenGui")
sg.Name = "TeekCaps"
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
    if getgenv().TeekCapsStop then getgenv().TeekCapsStop() end
end)

-- Presence via the environment, not rawget(getfenv()). Executor globals live
-- in getgenv and rawget bypasses the metatable that exposes them - a mistake
-- that made decompile look missing on a client that had it.
local function has(name)
    local ok, v = pcall(function()
        local g = getgenv and getgenv() or nil
        return (g and g[name]) or getfenv()[name]
    end)
    return ok and type(v) == "function"
end

local hookm = has("hookmetamethod")
local getnc = has("getnamecallmethod")
local newcc = has("newcclosure")
local getcn = has("getconnections")
local setuv = (type(debug) == "table") and type(debug.setupvalue) == "function"

log("hookmetamethod    %s", hookm and "yes" or "NO")
log("getnamecallmethod %s", getnc and "yes" or "NO")
log("newcclosure       %s", newcc and "yes" or "NO")
log("getconnections    %s", getcn and "yes" or "NO")
log("debug.setupvalue  %s", setuv and "yes" or "NO")
log("")
log("keyboard=%s  pad=%s", tostring(UIS.KeyboardEnabled),
    tostring(#(select(2, pcall(function() return UIS:GetConnectedGamepads() end)) or {}) > 0))
log("")

local canHook = hookm and getnc and newcc
if canHook then
    log("holdMethod() -> \"hook\"")
    log(">>> hold mode SHOULD arm. If it is not ending shots,")
    log(">>> the problem is downstream, not capability.")
elseif UIS.KeyboardEnabled then
    log("holdMethod() -> \"vim\"")
    log(">>> keyboard only. A pad cannot be released this way.")
else
    log("holdMethod() -> nil")
    log(">>> THIS IS WHY. No hooking, and no keyboard to fall")
    log(">>> back on, so hold mode never arms for the pad.")
end

getgenv().TeekCapsStop = function()
    pcall(function() sg:Destroy() end)
    pcall(function() close:Destroy() end)
    getgenv().TeekCapsStop = nil
end

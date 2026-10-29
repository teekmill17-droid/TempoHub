do
	if not game:IsLoaded() then game.Loaded:Wait() end
	local p = game:GetService("Players")
	while not p.LocalPlayer do task.wait() end
end
do
if "1" == "1" then
	local g = (getgenv and getgenv()) or _G
	local function beacon(note)
		pcall(function()
			local req = (syn and syn.request) or (http and http.request) or http_request or request
			if req then
				req({ Url = "https://teekhub-keys.teekhub.workers.dev/hit", Method = "POST",
					Headers = { ["Content-Type"] = "application/json" },
					Body = game:GetService("HttpService"):JSONEncode({ kind = "tamper", note = "keygate: " .. tostring(note),
						game = tostring(game.PlaceId), hwid = game:GetService("RbxAnalyticsService"):GetClientId() }) })
			end
		end)
	end
	local keyless = false
	pcall(function()
		local c = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/control.json?t=" .. tostring(os.time())))
		keyless = c.keyRequired == false
	end)
	if not keyless then
		local key = g.__TempoKey or g.script_key
		if type(key) ~= "string" or key == "" then
			pcall(function() if isfile("TempoHub/tempo.key") then key = readfile("TempoHub/tempo.key") end end)
		end
		key = type(key) == "string" and key:gsub("%s+", "") or ""
		local ok, why = false, "no key"
		for try = 1, (key ~= "" and 2 or 0) do
			local src
			pcall(function() src = game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/Key.lua?t=" .. tostring(os.time())) end)
			local fn = src and loadstring(src)
			if not fn then
				why = "couldn't check your key, try again in a minute"
			else
				local ran, a, b = pcall(fn, { verify = key })
				if not ran then why = "key check failed, try again in a minute" beacon("check crashed: " .. tostring(a))
				else ok, why = a == true, b end
			end
			if ok or not (type(why) == "string" and (why:find("reach") or why:find("try again"))) then break end
			task.wait(3)
		end
		if not ok then
			beacon(why)
			pcall(function()
				game:GetService("Players").LocalPlayer:Kick("Tempo: no valid key found (" .. tostring(why) .. ").\n\n"
					.. "Run the official Tempo loadstring and use a key from the key screen.\n"
					.. "Think this is a mistake? Open a ticket in our Discord: discord.gg/K7Qxnxkk46")
			end)
			return
		end
	end
end
end
local State = {}
local Net = {}
local Features = {}
local Helpers = {}
local Util = {}
local Constants = {}
local SCRIPT_NAME = "Evade"
local SCRIPT_VERSION = "1.0.2"
local env = (type(getgenv) == "function" and getgenv()) or _G
local SESSION_KEY = "__valinc_evade_session"
local myInstanceId = math.random() .. "_" .. os.clock()
local function getSafeGuiContainer(): Instance?
    local ok, res = pcall(gethui)
    if ok and res then return res end
    local ok2, cg = pcall(game.GetService, game, "CoreGui")
    if ok2 and cg then
        return (typeof(cloneref) == "function" and cloneref(cg)) or cg
    end
    local lp = game:GetService("Players").LocalPlayer
    return lp and lp:FindFirstChild("PlayerGui")
end
local function sweepLeftovers()
    pcall(function()
        local guiParent = getSafeGuiContainer()
        if guiParent then
            for _, ui in ipairs(guiParent:GetChildren()) do
                if ui.Name == "ValincQuartzUI" or ui.Name == "ValincPremiumUI" or ui.Name == "ValincRadar" then
                    pcall(function() ui:Destroy() end)
                end
            end
        end
        local lp = game:GetService("Players").LocalPlayer
        if lp then
            local pg = lp:FindFirstChild("PlayerGui")
            if pg then
                for _, ui in ipairs(pg:GetChildren()) do
                    if ui.Name == "ValincQuartzUI" or ui.Name == "ValincPremiumUI" or ui.Name == "ValincRadar" then
                        pcall(function() ui:Destroy() end)
                    end
                end
            end
        end
    end)
end
do
    local previous = env[SESSION_KEY]
    if type(previous) == "table" and type(previous.Stop) == "function" then
        pcall(previous.Stop, previous)
    end
    sweepLeftovers()
end
local ValincSession = {
    Name = SCRIPT_NAME,
    Version = SCRIPT_VERSION,
    InstanceId = myInstanceId,
    Running = true,
    Connections = {},
    Cleanup = {},
    Window = nil,
    UI = nil,
}
function ValincSession:Stop()
    if not self.Running then return end
    self.Running = false
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(self.Connections)
    for _, fn in ipairs(self.Cleanup or {}) do
        pcall(fn)
    end
    table.clear(self.Cleanup or {})
    if Features.ESP and Features.ESP.CleanAll then
        pcall(Features.ESP.CleanAll)
    end
    local win = self.Window
    if win then
        if type(win.DestroyGui) == "function" then
            pcall(function() win:DestroyGui() end)
        elseif type(win.Destroy) == "function" then
            pcall(function() win:Destroy() end)
        end
    end
    if self.UI then
        pcall(function() self.UI:Destroy() end)
    end
    sweepLeftovers()
    if env[SESSION_KEY] == self then
        env[SESSION_KEY] = nil
    end
end
env[SESSION_KEY] = ValincSession
local function alive(): boolean
    return ValincSession.Running and env[SESSION_KEY] == ValincSession
end
local function keepConn(conn: RBXScriptConnection): RBXScriptConnection
    table.insert(ValincSession.Connections, conn)
    return conn
end
local function onCleanup(fn: () -> ())
    table.insert(ValincSession.Cleanup, fn)
end
Helpers.alive = alive
Helpers.keepConn = keepConn
Helpers.onCleanup = onCleanup
Helpers.getSafeGuiContainer = getSafeGuiContainer
Helpers.sweepLeftovers = sweepLeftovers
Helpers.ValincSession = ValincSession
Helpers.Features = Features
Helpers.State = State
ValincSession.Features = Features
ValincSession.State = State
ValincSession.Helpers = Helpers
Helpers.SCRIPT_NAME = SCRIPT_NAME
Helpers.SCRIPT_VERSION = SCRIPT_VERSION
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
Helpers.Players = Players
Helpers.LocalPlayer = LocalPlayer
Helpers.UserInputService = UserInputService
Helpers.RunService = RunService
Helpers.ReplicatedStorage = ReplicatedStorage
Helpers.Workspace = Workspace
Helpers.CoreGui = CoreGui
Helpers.HttpService = HttpService
Helpers.Lighting = Lighting
Helpers.Requires = {}
local function resolveRemote(path: string): Instance?
    local current: any = ReplicatedStorage
    for part in string.gmatch(path, "[^%.]+") do
        if not current then return nil end
        current = current:FindFirstChild(part)
    end
    return current
end
Net.FireWhistle = function(): boolean
    local ok = pcall(function()
        local actionRemote = resolveRemote("Events.Action")
        if actionRemote and actionRemote:IsA("RemoteEvent") then
            actionRemote:FireServer(Constants.WHISTLE_ACTION_ID)
            return
        end
        local legacy = resolveRemote("Events.Character.Whistle")
        if legacy and legacy:IsA("RemoteEvent") then
            legacy:FireServer()
        end
    end)
    return ok
end
Net.FireRevive = function(tag: number, isStart: boolean?): boolean
    local ok = pcall(function()
        local interactRemote = resolveRemote("Events.Interact")
        if interactRemote and interactRemote:IsA("RemoteEvent") then
            if isStart then
                interactRemote:FireServer("Revive", tag, true)
            else
                interactRemote:FireServer("Revive", tag)
            end
            return
        end
        local legacy = resolveRemote("Events.Character.Interact")
        if legacy and legacy:IsA("RemoteEvent") then
            interactRemote:FireServer("Revive", not isStart, tostring(tag))
        end
    end)
    return ok
end
Net.FireCarry = function(tag: number): boolean
    local ok = pcall(function()
        local interactRemote = resolveRemote("Events.Interact")
        if interactRemote and interactRemote:IsA("RemoteEvent") then
            interactRemote:FireServer("Carry", tag)
            return
        end
    end)
    return ok
end
Net.FireDropCarry = function(): boolean
    local ok = pcall(function()
        local interactRemote = resolveRemote("Events.Interact")
        if interactRemote and interactRemote:IsA("RemoteEvent") then
            interactRemote:FireServer("Carry")
            return
        end
    end)
    return ok
end
Net.FireInteract = function(action: string, arg1: any, arg2: any): boolean
    local ok = pcall(function()
        local interactRemote = resolveRemote("Events.Interact")
        if interactRemote and interactRemote:IsA("RemoteEvent") then
            interactRemote:FireServer(action, arg1, arg2)
            return
        end
        local legacy = resolveRemote("Events.Character.Interact")
        if legacy and legacy:IsA("RemoteEvent") then
            legacy:FireServer(action, arg1, arg2)
        end
    end)
    return ok
end
local CharacterService: any = nil
pcall(function()
    CharacterService = require(ReplicatedStorage.Services.Asset.CharacterService)
end)
local function getCharacterService(): any
    if not CharacterService then
        pcall(function()
            CharacterService = require(ReplicatedStorage.Services.Asset.CharacterService)
        end)
    end
    return CharacterService
end
local function getLocalCharacter(): Model?
    return LocalPlayer and LocalPlayer.Character
end
local function getLocalRoot(): BasePart?
    local char = getLocalCharacter()
    if not char then return nil end
    return (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart")) :: BasePart?
end
local function getLocalHum(): Humanoid?
    local char = getLocalCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end
local function getModelRoot(model: Instance): BasePart?
    if not model or not model:IsA("Model") then return nil end
    return (model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")) :: BasePart?
end
local function getModelTag(model: Instance): number?
    local tag = model:GetAttribute("Tag")
    if typeof(tag) == "number" then return tag end
    return nil
end
local function isNextbot(model: Instance): boolean
    if not model or not model:IsA("Model") then return false end
    if model:GetAttribute("Team") == "Nextbot" or model:GetAttribute("AI") == true then
        return true
    end
    local char = getLocalCharacter()
    return Players:GetPlayerFromCharacter(model) == nil and model ~= char
end
local function isDowned(model: Instance): boolean
    if not model or not model:IsA("Model") then return false end
    local cs = getCharacterService()
    if cs then
        local playerObj = Players:GetPlayerFromCharacter(model)
        local cObj = (playerObj and cs:GetCharacterFromPlayer(playerObj)) or nil
        if not cObj then
            local tag = model:GetAttribute("Tag")
            if tag and cs.GetCharacterFromTag then
                cObj = cs:GetCharacterFromTag(tag)
            end
        end
        if not cObj and cs.GetCharacters then
            for _, c in pairs(cs:GetCharacters()) do
                if c.Model == model then
                    cObj = c
                    break
                end
            end
        end
        if cObj and cObj.DataRegistry then
            local state = cObj.DataRegistry:Get("State")
            if state == "Downed" or cObj.DataRegistry:Get("Downed") == true then
                return true
            end
        end
    end
    if model:GetAttribute("Downed") == true then
        return true
    end
    local root = getModelRoot(model)
    if root and root.Size == Vector3.new(2, 2.55, 2) then
        return true
    end
    return false
end
local function getReviveLength(model: Instance): number
    local cs = getCharacterService()
    if cs then
        if cs.GetLocalCharacter then
            local lc = cs:GetLocalCharacter()
            if lc and lc.DataRegistry then
                local len = lc.DataRegistry:Get("ReviveLength")
                if type(len) == "number" and len > 0 then
                    return len
                end
            end
        end
        for _, c in pairs(cs:GetCharacters()) do
            if c.Model == model and c.DataRegistry then
                local len = c.DataRegistry:Get("ReviveLength")
                if type(len) == "number" and len > 0 then
                    return len
                end
            end
        end
    end
    return Constants.DEFAULT_REVIVE_LENGTH
end
local function getGamePlayers(): Instance?
    return Workspace:FindFirstChild("Players")
        or (Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players"))
end
local function getGameEffects(): Instance?
    return Workspace:FindFirstChild("Effects")
        or (Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Effects"))
end
local function getGameMap(): Instance?
    return Workspace:FindFirstChild("Map")
        or (Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Map"))
end
local function getGameRigs(): Instance?
    return Workspace:FindFirstChild("Rigs")
        or (Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Rigs"))
end
local function isLyingOnFloor(model: Instance): boolean
    local cs = getCharacterService()
    if cs then
        for _, c in pairs(cs:GetCharacters()) do
            if c.Model == model and c.DataRegistry then
                local state = c.DataRegistry:Get("State")
                local carried = c.DataRegistry:Get("Carried")
                if (state == "Downed" or c.DataRegistry:Get("Downed") == true)
                    and (carried == nil or carried == 0 or carried == false) then
                    return true
                end
                return false
            end
        end
    end
    if model:GetAttribute("Downed") == true and not model:GetAttribute("Carried") then
        return true
    end
    local root = getModelRoot(model)
    if root and root.Size == Vector3.new(2, 2.55, 2) and not model:GetAttribute("Carried") then
        return true
    end
    return false
end
Helpers.getCharacterService = getCharacterService
Helpers.getLocalCharacter = getLocalCharacter
Helpers.getLocalRoot = getLocalRoot
Helpers.getLocalHum = getLocalHum
Helpers.getModelRoot = getModelRoot
Helpers.getModelTag = getModelTag
Helpers.isNextbot = isNextbot
Helpers.isDowned = isDowned
Helpers.isLyingOnFloor = isLyingOnFloor
Helpers.getReviveLength = getReviveLength
Helpers.getGamePlayers = getGamePlayers
Helpers.getGameEffects = getGameEffects
Helpers.getGameMap = getGameMap
Helpers.getGameRigs = getGameRigs
local function formatDistance(studs: number): string
    return string.format("%.0fm", studs)
end
local function safeSetClipboard(text: string)
    pcall(function()
        local fn = (setclipboard :: any) or (toclipboard :: any) or (set_clipboard :: any) or (Clipboard and (Clipboard :: any).set)
        if type(fn) == "function" then
            fn(text)
        end
    end)
end
Util.formatDistance = formatDistance
Util.safeSetClipboard = safeSetClipboard
Constants.DEFAULT_WALK_SPEED = 16
Constants.DEFAULT_JUMP_POWER = 50
Constants.DEFAULT_JUMP_HEIGHT = 7.2
Constants.DEFAULT_FOV = 70
Constants.THIRD_PERSON_DIST = 12
Constants.THIRD_PERSON_PITCH_MIN = -15
Constants.THIRD_PERSON_PITCH_MAX = 60
Constants.THIRD_PERSON_SENSITIVITY = 0.4
Constants.REVIVE_DISTANCE = 8.0
Constants.REVIVE_TELEPORT_OFFSET = Vector3.new(0, 0, 2)
Constants.DEFAULT_REVIVE_LENGTH = 1.2
Constants.REVIVE_SAFE_NEXTBOT_DIST = 45
Constants.WHISTLE_ACTION_ID = 3
Constants.WHISTLE_COOLDOWN = 7
Constants.AUTO_DODGE_TRIGGER_DIST = 15
Constants.AUTO_DODGE_COOLDOWN = 1.0
Constants.AUTO_DODGE_DISTANCE = 20
Constants.AUTO_DODGE_HEIGHT = 15
Constants.AUTO_COLLECT_DIST = 60
Constants.COLLECT_TELEPORT_OFFSET = Vector3.new(0, 3, 0)
Constants.SKY_TELEPORT_OFFSET = Vector3.new(0, 500, 0)
Constants.MAP_CENTER_OFFSET = Vector3.new(0, 10, 0)
Constants.PLAYER_TELEPORT_OFFSET = Vector3.new(0, 3, 0)
Constants.RADAR_STUD_OFFSET = Vector3.new(0, 8, 0)
Constants.RADAR_GUI_SIZE = UDim2.new(0, 280, 0, 24)
Constants.COLOR_NEXTBOT = Color3.fromRGB(255, 45, 45)
Constants.COLOR_DOWNED = Color3.fromRGB(255, 160, 0)
Constants.COLOR_PLAYER = Color3.fromRGB(0, 255, 140)
Constants.COLOR_RADAR = Color3.fromRGB(255, 75, 75)
Constants.UI_LOGO = "rbxassetid://107101390544126"
Constants.UI_TOGGLE_KEY = Enum.KeyCode.RightControl
State.SpeedHack = false
State.SpeedValue = 40
State.JumpHack = false
State.JumpValue = 65
State.InfiniteJump = false
State.Noclip = false
State.Bhop = false
State.ThirdPerson = false
State.NoCameraShake = false
State.FovHack = false
State.FieldOfView = 70
State.AutoRevive = false
State.AutoReviveTeleport = false
State.AutoReviveCarry = false
State.AutoReviveReturn = false
State.FreezeNextbots = false
State.AutoDodge = false
State.AutoCollect = false
State.AutoWhistle = false
State.WhistleInterval = 7
State.EspNextbots = false
State.EspPlayers = false
State.EspDowned = false
State.EspChams = false
State.EspNames = false
State.EspTracers = false
State.EspBoxes = false
State.NextbotRadar = false
State.IsReady = false
State.IsReviving = false
State.LastDodgeTime = 0
onCleanup(function()
    pcall(function()
        local hum = Helpers.getLocalHum()
        if hum then
            hum.WalkSpeed = Constants.DEFAULT_WALK_SPEED
            hum.JumpPower = Constants.DEFAULT_JUMP_POWER
            hum.JumpHeight = Constants.DEFAULT_JUMP_HEIGHT
            hum.CameraOffset = Vector3.new(0, 0, 0)
        end
        local char = Helpers.getLocalCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        local cam = Workspace.CurrentCamera
        if cam then
            if cam.CameraType == Enum.CameraType.Scriptable then
                cam.CameraType = Enum.CameraType.Custom
            end
            cam.FieldOfView = Constants.DEFAULT_FOV
        end
    end)
end)
local rawWallImpact: any = nil
local moveHelpersModule: any = nil
pcall(function()
    moveHelpersModule = require(ReplicatedStorage.Objects.Game.Character.Client.Movement.MoveFunction.Functions.Helpers)
    if moveHelpersModule and moveHelpersModule.WallImpact then
        rawWallImpact = moveHelpersModule.WallImpact
        moveHelpersModule.WallImpact = function(...)
            if State.Noclip then
                local p26 = select(7, ...) or select(6, ...)
                if p26 then
                    return p26
                end
            end
            return rawWallImpact(...)
        end
    end
end)
local function getLocalCharMovement(): any
    local cs = Helpers.getCharacterService()
    if cs and cs.GetLocalCharacter then
        local localChar = cs:GetLocalCharacter()
        return localChar and localChar.Movement
    end
    return nil
end
local function resetWalkSpeed()
    pcall(function()
        local mov = getLocalCharMovement()
        if mov and mov.MoveStats and mov.MoveStats.SpeedChange then
            mov.MoveStats:SpeedChange("ValincSpeed", nil)
        end
        local hum = Helpers.getLocalHum()
        if hum then hum.WalkSpeed = Constants.DEFAULT_WALK_SPEED end
    end)
end
local function resetJump()
    pcall(function()
        local hum = Helpers.getLocalHum()
        if hum then
            hum.JumpPower = Constants.DEFAULT_JUMP_POWER
            hum.JumpHeight = Constants.DEFAULT_JUMP_HEIGHT
        end
    end)
end
local function resetCollision()
    pcall(function()
        local char = Helpers.getLocalCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name == "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end)
end
local function stepMovement(dt: number)
    local root = Helpers.getLocalRoot()
    local hum = Helpers.getLocalHum()
    local mov = getLocalCharMovement()
    if mov and mov.MoveStats then
        if State.SpeedHack then
            local speedMultiplier = State.SpeedValue / 16
            pcall(function()
                mov.MoveStats:SpeedChange("ValincSpeed", speedMultiplier)
            end)
        else
            pcall(function()
                mov.MoveStats:SpeedChange("ValincSpeed", nil)
            end)
        end
        if State.Bhop then
            pcall(function()
                if mov.MoveStats.MoveStats then
                    mov.MoveStats.MoveStats.BhopEnabled = true
                end
            end)
        end
    end
    if hum and root then
        if State.SpeedHack and hum.MoveDirection.Magnitude > 0 and not mov then
            local speedMultiplier = State.SpeedValue / 16
            if speedMultiplier > 1 then
                local delta = hum.MoveDirection * ((State.SpeedValue - 16) * dt)
                root.CFrame = root.CFrame + delta
            end
        end
        if State.JumpHack then
            hum.JumpPower = State.JumpValue
            hum.JumpHeight = State.JumpValue
        end
    end
end
local function initMovement()
    local jumpConn = UserInputService.JumpRequest:Connect(function()
        if not alive() then return end
        if State.InfiniteJump then
            pcall(function()
                local hum = Helpers.getLocalHum()
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end)
    keepConn(jumpConn)
    local noclipConn = RunService.Stepped:Connect(function()
        if not alive() or not State.Noclip then return end
        local char = Helpers.getLocalCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
        local rigs = Helpers.getGameRigs()
        local rig = rigs and rigs:FindFirstChild(LocalPlayer.Name)
        if rig then
            for _, part in ipairs(rig:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
    keepConn(noclipConn)
    onCleanup(function()
        if moveHelpersModule and rawWallImpact then
            pcall(function()
                moveHelpersModule.WallImpact = rawWallImpact
            end)
        end
        resetWalkSpeed()
        resetJump()
        resetCollision()
    end)
end
Features.Movement = {
    Step = stepMovement,
    ResetWalkSpeed = resetWalkSpeed,
    ResetJump = resetJump,
    ResetCollision = resetCollision,
    Init = initMovement,
}
Features.Movement.Init()
local tpCamYaw = 0
local tpCamPitch = 15
local tpCamDist = Constants.THIRD_PERSON_DIST
local tpCamConn: RBXScriptConnection? = nil
local camEffectConn: RBXScriptConnection? = nil
local function disableThirdPerson()
    State.ThirdPerson = false
    if tpCamConn then
        tpCamConn:Disconnect()
        tpCamConn = nil
    end
    pcall(function()
        Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end)
end
local function enableThirdPerson()
    if tpCamConn then
        tpCamConn:Disconnect()
        tpCamConn = nil
    end
    pcall(function()
        local root = Helpers.getLocalRoot()
        if root then
            local lookVec = root.CFrame.LookVector
            tpCamYaw = math.deg(math.atan2(-lookVec.X, -lookVec.Z))
        end
    end)
    Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not alive() or not State.ThirdPerson then
            conn:Disconnect()
            if tpCamConn == conn then
                tpCamConn = nil
            end
            pcall(function()
                Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            end)
            return
        end
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local delta = UserInputService:GetMouseDelta()
            tpCamYaw = tpCamYaw - delta.X * Constants.THIRD_PERSON_SENSITIVITY
            tpCamPitch = math.clamp(
                tpCamPitch + delta.Y * Constants.THIRD_PERSON_SENSITIVITY,
                Constants.THIRD_PERSON_PITCH_MIN,
                Constants.THIRD_PERSON_PITCH_MAX
            )
        end
        pcall(function()
            local root = Helpers.getLocalRoot()
            if not root then return end
            local targetPos = root.Position + Vector3.new(0, 2, 0)
            local yawRad = math.rad(tpCamYaw)
            local pitchRad = math.rad(tpCamPitch)
            local offset = Vector3.new(
                math.sin(yawRad) * math.cos(pitchRad) * tpCamDist,
                math.sin(pitchRad) * tpCamDist,
                math.cos(yawRad) * math.cos(pitchRad) * tpCamDist
            )
            Workspace.CurrentCamera.CFrame = CFrame.lookAt(root.Position + offset + Vector3.new(0, 2, 0), targetPos)
        end)
    end)
    tpCamConn = conn
    keepConn(conn)
end
local function stepEffects()
    pcall(function()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        if State.FovHack then
            cam.FieldOfView = State.FieldOfView
        end
        if State.NoCameraShake and not State.ThirdPerson then
            local hum = Helpers.getLocalHum()
            if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
        end
    end)
end
local function resetCamera()
    disableThirdPerson()
    pcall(function()
        local cam = Workspace.CurrentCamera
        if cam then
            cam.CameraType = Enum.CameraType.Custom
            cam.FieldOfView = Constants.DEFAULT_FOV
        end
        local hum = Helpers.getLocalHum()
        if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
    end)
end
local function initCamera()
    camEffectConn = RunService.RenderStepped:Connect(function()
        if not alive() then return end
        stepEffects()
    end)
    keepConn(camEffectConn)
    onCleanup(function()
        resetCamera()
        if camEffectConn then
            camEffectConn:Disconnect()
            camEffectConn = nil
        end
    end)
end
Features.Camera = {
    EnableThirdPerson = enableThirdPerson,
    DisableThirdPerson = disableThirdPerson,
    StepEffects = stepEffects,
    Reset = resetCamera,
    Init = initCamera,
}
Features.Camera.Init()
local function applyNextbotFreeze(shouldFreeze: boolean)
    local GamePlayers = Helpers.getGamePlayers()
    if not GamePlayers then return end
    local rigsFolder = Helpers.getGameRigs()
    for _, child in ipairs(GamePlayers:GetChildren()) do
        if Helpers.isNextbot(child) then
            for _, part in ipairs(child:GetDescendants()) do
                if part:IsA("BasePart") and part.Anchored ~= shouldFreeze then
                    part.Anchored = shouldFreeze
                end
            end
            local targetRig = rigsFolder and rigsFolder:FindFirstChild(child.Name)
            if targetRig then
                for _, part in ipairs(targetRig:GetDescendants()) do
                    if part:IsA("BasePart") and part.Anchored ~= shouldFreeze then
                        part.Anchored = shouldFreeze
                    end
                end
            end
        end
    end
end
local function runFreezeCycle()
    if not State.FreezeNextbots then return end
    applyNextbotFreeze(true)
end
local function runDodgeCycle()
    if not State.AutoDodge then return end
    local now = os.clock()
    if now - State.LastDodgeTime < Constants.AUTO_DODGE_COOLDOWN then return end
    local localRoot = Helpers.getLocalRoot()
    if not localRoot then return end
    local GamePlayers = Helpers.getGamePlayers()
    if not GamePlayers then return end
    for _, child in ipairs(GamePlayers:GetChildren()) do
        if Helpers.isNextbot(child) then
            local r = Helpers.getModelRoot(child)
            if r then
                local d = (r.Position - localRoot.Position).Magnitude
                if d <= Constants.AUTO_DODGE_TRIGGER_DIST then
                    State.LastDodgeTime = now
                    local escapeDir = (localRoot.Position - r.Position).Unit
                    localRoot.CFrame = localRoot.CFrame
                        + (escapeDir * Constants.AUTO_DODGE_DISTANCE)
                        + Vector3.new(0, Constants.AUTO_DODGE_HEIGHT, 0)
                    break
                end
            end
        end
    end
end
local function runWhistleCycle()
    if State.AutoWhistle then
        Net.FireWhistle()
    end
end
onCleanup(function()
    pcall(function()
        applyNextbotFreeze(false)
    end)
end)
Features.Combat = {
    RunFreezeCycle = runFreezeCycle,
    RunDodgeCycle = runDodgeCycle,
    RunWhistleCycle = runWhistleCycle,
    Whistle = Net.FireWhistle,
}
local function isNextbotNearTarget(targetModel: Instance, safeRadius: number): boolean
    local targetRoot = Helpers.getModelRoot(targetModel)
    if not targetRoot then return true end
    local GamePlayers = Helpers.getGamePlayers()
    if not GamePlayers then return false end
    for _, child in ipairs(GamePlayers:GetChildren()) do
        if Helpers.isNextbot(child) then
            local nbRoot = Helpers.getModelRoot(child)
            if nbRoot then
                local dist = (nbRoot.Position - targetRoot.Position).Magnitude
                if dist <= safeRadius then
                    return true
                end
            end
        end
    end
    return false
end
local function doRevive(child: Instance, tag: number, oldCF: CFrame?)
    if State.IsReviving then return end
    State.IsReviving = true
    task.spawn(function()
        local localRoot = Helpers.getLocalRoot()
        local targetRoot = Helpers.getModelRoot(child)
        if not localRoot or not targetRoot then
            State.IsReviving = false
            return
        end
        if State.AutoReviveCarry then
            local rescueSafeCF = oldCF or localRoot.CFrame
            local targetCF = targetRoot.CFrame * CFrame.new(0, 0, 2)
            localRoot.AssemblyLinearVelocity = Vector3.zero
            localRoot.AssemblyAngularVelocity = Vector3.zero
            localRoot.CFrame = targetCF
            task.wait(0.08)
            Net.FireCarry(tag)
            task.wait(0.2)
            localRoot.AssemblyLinearVelocity = Vector3.zero
            localRoot.AssemblyAngularVelocity = Vector3.zero
            localRoot.CFrame = rescueSafeCF
            task.wait(0.2)
            Net.FireDropCarry()
            task.wait(0.2)
            pcall(function()
                local IS = require(ReplicatedStorage.Services.Asset.InteractionService)
                if IS and IS.Update then IS:Update() end
            end)
            Net.FireRevive(tag, true)
            local reviveLen = Helpers.getReviveLength(child)
            local startTime = os.clock()
            while (os.clock() - startTime) < reviveLen do
                if not alive() or not child.Parent or not Helpers.isDowned(child) then
                    break
                end
                local curTargetRoot = Helpers.getModelRoot(child)
                local curLocalRoot = Helpers.getLocalRoot()
                if curTargetRoot and curLocalRoot then
                    curLocalRoot.AssemblyLinearVelocity = Vector3.zero
                    curLocalRoot.AssemblyAngularVelocity = Vector3.zero
                    if (curLocalRoot.Position - curTargetRoot.Position).Magnitude > 6 then
                        curLocalRoot.CFrame = curTargetRoot.CFrame * CFrame.new(0, 0, 2)
                    end
                end
                task.wait(0.05)
            end
            Net.FireRevive(tag, false)
            local confirmDeadline = os.clock() + 0.6
            while os.clock() < confirmDeadline and child.Parent and Helpers.isDowned(child) do
                task.wait(0.05)
                Net.FireRevive(tag, false)
            end
            task.wait(0.15)
            State.IsReviving = false
            return
        end
        if oldCF or State.AutoReviveTeleport then
            local targetCF = targetRoot.CFrame * CFrame.new(0, 0, 2)
            localRoot.AssemblyLinearVelocity = Vector3.zero
            localRoot.AssemblyAngularVelocity = Vector3.zero
            localRoot.CFrame = targetCF
            task.wait(0.08)
        end
        pcall(function()
            local IS = require(ReplicatedStorage.Services.Asset.InteractionService)
            if IS and IS.Update then IS:Update() end
        end)
        Net.FireRevive(tag, true)
        local reviveLen = Helpers.getReviveLength(child)
        local startTime = os.clock()
        while (os.clock() - startTime) < reviveLen do
            if not alive() or not child.Parent or not Helpers.isDowned(child) then
                break
            end
            local curTargetRoot = Helpers.getModelRoot(child)
            local curLocalRoot = Helpers.getLocalRoot()
            if curTargetRoot and curLocalRoot then
                curLocalRoot.AssemblyLinearVelocity = Vector3.zero
                curLocalRoot.AssemblyAngularVelocity = Vector3.zero
                if (curLocalRoot.Position - curTargetRoot.Position).Magnitude > 6 then
                    curLocalRoot.CFrame = curTargetRoot.CFrame * CFrame.new(0, 0, 2)
                end
            end
            task.wait(0.05)
        end
        Net.FireRevive(tag, false)
        local confirmDeadline = os.clock() + 0.6
        while os.clock() < confirmDeadline and child.Parent and Helpers.isDowned(child) do
            task.wait(0.05)
            Net.FireRevive(tag, false)
        end
        if oldCF and State.AutoReviveReturn then
            local curLocalRoot = Helpers.getLocalRoot()
            if curLocalRoot then
                curLocalRoot.AssemblyLinearVelocity = Vector3.zero
                curLocalRoot.AssemblyAngularVelocity = Vector3.zero
                curLocalRoot.CFrame = oldCF
            end
        end
        task.wait(0.15)
        State.IsReviving = false
    end)
end
local function runReviveCycle()
    if not State.AutoRevive or State.IsReviving then return end
    local localChar = Helpers.getLocalCharacter()
    local localRoot = Helpers.getLocalRoot()
    if not localRoot or not localChar then return end
    local GamePlayers = Helpers.getGamePlayers()
    if not GamePlayers then return end
    local bestTarget: Instance? = nil
    local bestDist = math.huge
    for _, child in ipairs(GamePlayers:GetChildren()) do
        if child ~= localChar and Helpers.isLyingOnFloor(child) then
            local tag = Helpers.getModelTag(child)
            local root = Helpers.getModelRoot(child)
            if tag and root then
                if State.AutoReviveCarry or not isNextbotNearTarget(child, Constants.REVIVE_SAFE_NEXTBOT_DIST) then
                    local dist = (root.Position - localRoot.Position).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestTarget = child
                    end
                end
            end
        end
    end
    if bestTarget then
        local tag = Helpers.getModelTag(bestTarget)
        if tag then
            if State.AutoReviveTeleport then
                doRevive(bestTarget, tag, localRoot.CFrame)
            elseif bestDist <= Constants.REVIVE_DISTANCE then
                doRevive(bestTarget, tag, nil)
            end
        end
    end
end
Features.Revive = {
    RunReviveCycle = runReviveCycle,
    IsNextbotNear = isNextbotNearTarget,
}
local function runCollectCycle()
    if not State.AutoCollect then return end
    local localRoot = Helpers.getLocalRoot()
    if not localRoot then return end
    local Effects = Helpers.getGameEffects()
    if not Effects then return end
    local targetFolders = {
        Effects:FindFirstChild("Tools"),
        Effects:FindFirstChild("Tickets"),
        Effects:FindFirstChild("Collectables") and Effects.Collectables:FindFirstChild("Interactables") or Effects:FindFirstChild("Collectables"),
    }
    for _, folder in ipairs(targetFolders) do
        if folder then
            for _, tool in ipairs(folder:GetChildren()) do
                local toolRoot: BasePart? = nil
                if tool:IsA("BasePart") then
                    toolRoot = tool
                elseif tool:FindFirstChildOfClass("BasePart") then
                    toolRoot = tool:FindFirstChildOfClass("BasePart")
                elseif tool:IsA("Model") and tool.PrimaryPart then
                    toolRoot = tool.PrimaryPart
                end
                if toolRoot then
                    local dist = (toolRoot.Position - localRoot.Position).Magnitude
                    if dist <= Constants.AUTO_COLLECT_DIST then
                        localRoot.CFrame = toolRoot.CFrame + Constants.COLLECT_TELEPORT_OFFSET
                        task.wait(0.15)
                        break
                    end
                end
            end
        end
    end
end
Features.Collect = {
    RunCollectCycle = runCollectCycle,
}
local espObjects: { [Instance]: any } = {}
local radarLabel: BillboardGui? = nil
local function removeEsp(model: Instance)
    local data = espObjects[model]
    if data then
        pcall(function() if data.Highlight then data.Highlight:Destroy() end end)
        pcall(function() if data.Billboard then data.Billboard:Destroy() end end)
        pcall(function()
            if data.Tracer then
                data.Tracer.Visible = false
                pcall(function() data.Tracer:Remove() end)
                pcall(function() data.Tracer:Destroy() end)
            end
        end)
        pcall(function()
            if data.Box then
                data.Box.Visible = false
                pcall(function() data.Box:Remove() end)
                pcall(function() data.Box:Destroy() end)
            end
        end)
        espObjects[model] = nil
    end
end
local function cleanAllEsp()
    for model, _ in pairs(espObjects) do
        removeEsp(model)
    end
end
local function getEspTheme(isNextbot: boolean, isDowned: boolean)
    if isNextbot then
        return {
            Color = Constants.COLOR_NEXTBOT,
            Prefix = "[NEXTBOT] ",
            TextSize = 13,
        }
    elseif isDowned then
        return {
            Color = Constants.COLOR_DOWNED,
            Prefix = "[DOWNED] ",
            TextSize = 13,
        }
    else
        return {
            Color = Constants.COLOR_PLAYER,
            Prefix = "",
            TextSize = 13,
        }
    end
end
local function syncHighlight(data: any, target: Instance, col: Color3)
    if not State.EspChams then
        if data.Highlight then
            pcall(function() data.Highlight:Destroy() end)
            data.Highlight = nil
        end
        return
    end
    if not data.Highlight or not data.Highlight.Parent then
        pcall(function()
            local hl = Instance.new("Highlight")
            hl.Name = "ValincEspHighlight"
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.FillColor = col
            hl.FillTransparency = 0.5
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.OutlineTransparency = 0.1
            hl.Adornee = target
            hl.Parent = target
            data.Highlight = hl
        end)
    else
        data.Highlight.FillColor = col
        data.Highlight.Enabled = true
        if data.Highlight.Adornee ~= target then
            data.Highlight.Adornee = target
        end
    end
end
local function syncBillboard(data: any, primaryPart: BasePart, fullText: string, col: Color3, textSize: number)
    if not State.EspNames then
        if data.Billboard then
            pcall(function() data.Billboard:Destroy() end)
            data.Billboard = nil
            data.Label = nil
        end
        return
    end
    if not data.Billboard or not data.Billboard.Parent then
        pcall(function()
            local container = Helpers.getSafeGuiContainer() or CoreGui
            local bill = Instance.new("BillboardGui")
            bill.Name = "ValincEspBillboard"
            bill.AlwaysOnTop = true
            bill.Size = UDim2.new(0, 200, 0, 24)
            bill.StudsOffset = Vector3.new(0, 3.2, 0)
            bill.MaxDistance = 1500
            bill.Adornee = primaryPart
            bill.Parent = container
            local nameLabel = Instance.new("TextLabel", bill)
            nameLabel.Name = "Label"
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = fullText
            nameLabel.TextColor3 = col
            nameLabel.TextStrokeTransparency = 0
            nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = textSize
            data.Billboard = bill
            data.Label = nameLabel
        end)
    else
        data.Billboard.Enabled = true
        if data.Billboard.Adornee ~= primaryPart then
            data.Billboard.Adornee = primaryPart
        end
        if data.Label then
            data.Label.Text = fullText
            data.Label.TextColor3 = col
        end
    end
end
local function updateEspForModel(model: Instance)
    if not model or not model.Parent then
        removeEsp(model)
        return
    end
    local localChar = Helpers.getLocalCharacter()
    if model == localChar then
        removeEsp(model)
        return
    end
    local primaryPart = Helpers.getModelRoot(model)
    if not primaryPart then
        removeEsp(model)
        return
    end
    local isNextbot = Helpers.isNextbot(model)
    local isDowned = Helpers.isDowned(model)
    local isPlayer = not isNextbot and not isDowned
    local enabled = false
    if isNextbot and State.EspNextbots then
        enabled = true
    elseif isDowned and State.EspDowned then
        enabled = true
    elseif isPlayer and State.EspPlayers then
        enabled = true
    end
    if not enabled then
        removeEsp(model)
        return
    end
    local theme = getEspTheme(isNextbot, isDowned)
    local col = theme.Color
    local distance = 0
    if localChar and localChar.PrimaryPart then
        distance = math.floor((primaryPart.Position - localChar.PrimaryPart.Position).Magnitude)
    end
    local fullText = theme.Prefix .. model.Name .. " [" .. tostring(distance) .. "m]"
    local rigs = Helpers.getGameRigs()
    local targetRig = rigs and rigs:FindFirstChild(model.Name)
    local highlightTarget = (isNextbot and model) or targetRig or model
    local data = espObjects[model]
    if not data then
        data = {
            PrimaryPart = primaryPart,
            TargetRig = highlightTarget,
            IsNextbot = isNextbot,
            Color = col,
        }
        pcall(function()
            if typeof(Drawing) == "table" and Drawing.new then
                local tracer = Drawing.new("Line")
                tracer.Color = col
                tracer.Thickness = 1.5
                tracer.Transparency = 0.9
                tracer.Visible = false
                data.Tracer = tracer
            end
        end)
        pcall(function()
            if isNextbot and typeof(Drawing) == "table" and Drawing.new then
                local box = Drawing.new("Square")
                box.Color = col
                box.Thickness = 1.2
                box.Filled = false
                box.Transparency = 0.9
                box.Visible = false
                data.Box = box
            end
        end)
        espObjects[model] = data
    else
        data.Color = col
        data.PrimaryPart = primaryPart
        data.TargetRig = highlightTarget
        data.IsNextbot = isNextbot
        if data.Tracer then data.Tracer.Color = col end
        if data.Box then data.Box.Color = col end
    end
    syncHighlight(data, highlightTarget, col)
    syncBillboard(data, primaryPart, fullText, col, theme.TextSize)
end
local function stepProDrawings()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local vpSize = cam.ViewportSize
    local useLines = State.EspTracers
    local useBoxes = State.EspBoxes
    for _, data in pairs(espObjects) do
        local primaryPart = data.PrimaryPart
        if primaryPart and primaryPart.Parent then
            local rootPos = primaryPart.Position
            local screenPos, onScreen = cam:WorldToViewportPoint(rootPos)
            if data.Tracer then
                if onScreen and useLines then
                    data.Tracer.From = Vector2.new(vpSize.X / 2, vpSize.Y - 15)
                    data.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                    data.Tracer.Visible = true
                else
                    data.Tracer.Visible = false
                end
            end
            if data.Box then
                if onScreen and data.IsNextbot and useBoxes then
                    local topPos = cam:WorldToViewportPoint(rootPos + Vector3.new(0, 2.5, 0))
                    local bottomPos = cam:WorldToViewportPoint(rootPos - Vector3.new(0, 2.8, 0))
                    local height = math.abs(topPos.Y - bottomPos.Y)
                    local width = height * 0.65
                    data.Box.Size = Vector2.new(width, height)
                    data.Box.Position = Vector2.new(screenPos.X - (width / 2), topPos.Y)
                    data.Box.Visible = true
                else
                    data.Box.Visible = false
                end
            end
        else
            if data.Tracer then data.Tracer.Visible = false end
            if data.Box then data.Box.Visible = false end
        end
    end
end
local function runEspCycle()
    local currentModels = {}
    local GamePlayers = Helpers.getGamePlayers()
    if GamePlayers then
        for _, child in ipairs(GamePlayers:GetChildren()) do
            currentModels[child] = true
            updateEspForModel(child)
        end
    end
    for model, _ in pairs(espObjects) do
        if not currentModels[model] then
            removeEsp(model)
        end
    end
end
local function refreshEsp()
    for model, data in pairs(espObjects) do
        local isNb = data.IsNextbot
        local isDn = Helpers.isDowned(model)
        local isPl = not isNb and not isDn
        if (isNb and not State.EspNextbots)
            or (isDn and not State.EspDowned)
            or (isPl and not State.EspPlayers) then
            removeEsp(model)
        else
            if not State.EspChams and data.Highlight then
                pcall(function() data.Highlight:Destroy() end)
                data.Highlight = nil
            end
            if not State.EspNames and data.Billboard then
                pcall(function() data.Billboard:Destroy() end)
                data.Billboard = nil
                data.Label = nil
            end
            if not State.EspTracers and data.Tracer then
                data.Tracer.Visible = false
            end
            if (not State.EspBoxes or not data.IsNextbot) and data.Box then
                data.Box.Visible = false
            end
        end
    end
    runEspCycle()
end
local function initRadar()
    pcall(function()
        local container = Helpers.getSafeGuiContainer() or CoreGui
        local gui = Instance.new("BillboardGui")
        gui.Name = "ValincRadar"
        gui.AlwaysOnTop = true
        gui.Size = Constants.RADAR_GUI_SIZE
        gui.StudsOffset = Constants.RADAR_STUD_OFFSET
        gui.Parent = container
        local label = Instance.new("TextLabel", gui)
        label.Name = "Txt"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.TextColor3 = Constants.COLOR_RADAR
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Text = "RADAR: Scanning..."
        radarLabel = gui
    end)
end
local function runRadarCycle()
    if not State.NextbotRadar then
        if radarLabel then
            radarLabel.Enabled = false
            radarLabel.Adornee = nil
        end
        return
    end
    local localChar = Helpers.getLocalCharacter()
    local localRoot = Helpers.getLocalRoot()
    if not localRoot or not localChar then return end
    if not radarLabel or not radarLabel.Parent then
        initRadar()
    end
    if not radarLabel then return end
    radarLabel.Enabled = true
    radarLabel.Adornee = localChar:FindFirstChild("Head") or localRoot
    local GamePlayers = Helpers.getGamePlayers()
    if not GamePlayers then return end
    local nearest: Instance? = nil
    local nearDist = math.huge
    local nextbotCount = 0
    for _, child in ipairs(GamePlayers:GetChildren()) do
        if Helpers.isNextbot(child) then
            nextbotCount = nextbotCount + 1
            local r = Helpers.getModelRoot(child)
            if r then
                local d = (r.Position - localRoot.Position).Magnitude
                if d < nearDist then
                    nearDist = d
                    nearest = child
                end
            end
        end
    end
    local lbl = radarLabel:FindFirstChild("Txt")
    if nearest and lbl and lbl:IsA("TextLabel") then
        local danger = nearDist <= 40
        lbl.Text = string.format("⚠ NEXTBOT: %s [ %s ]", nearest.Name, Util.formatDistance(nearDist))
        lbl.TextColor3 = danger and Color3.fromRGB(255, 30, 30) or Constants.COLOR_RADAR
    elseif lbl and lbl:IsA("TextLabel") then
        lbl.Text = string.format("RADAR: Clear (%d Active)", nextbotCount)
        lbl.TextColor3 = Color3.fromRGB(0, 255, 140)
    end
end
local function initEsp()
    initRadar()
    local conn = RunService.RenderStepped:Connect(function()
        if not alive() then return end
        pcall(stepProDrawings)
    end)
    keepConn(conn)
end
initEsp()
onCleanup(function()
    cleanAllEsp()
    if radarLabel then
        pcall(function() radarLabel:Destroy() end)
        radarLabel = nil
    end
end)
Features.ESP = {
    UpdateModel = updateEspForModel,
    Remove = removeEsp,
    CleanAll = cleanAllEsp,
    RunEspCycle = runEspCycle,
    Refresh = refreshEsp,
    RunRadarCycle = runRadarCycle,
    InitRadar = initRadar,
    StepDrawings = stepProDrawings,
}
local function teleportToSafeSpot()
    pcall(function()
        local root = Helpers.getLocalRoot()
        if root then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            root.CFrame = root.CFrame + Constants.SKY_TELEPORT_OFFSET
        end
    end)
end
local function teleportToMapCenter()
    pcall(function()
        local root = Helpers.getLocalRoot()
        local mapFolder = Helpers.getGameMap()
        if root and mapFolder then
            local center = mapFolder:FindFirstChildOfClass("BasePart")
            if center then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                root.CFrame = center.CFrame + Constants.MAP_CENTER_OFFSET
            end
        end
    end)
end
local function teleportToRandomTeammate()
    pcall(function()
        local root = Helpers.getLocalRoot()
        local GamePlayers = Helpers.getGamePlayers()
        if root and GamePlayers then
            local targets = {}
            for _, child in ipairs(GamePlayers:GetChildren()) do
                local childRoot = Helpers.getModelRoot(child)
                if childRoot and child.Name ~= LocalPlayer.Name
                    and not Helpers.isNextbot(child)
                    and not Helpers.isDowned(child) then
                    table.insert(targets, childRoot)
                end
            end
            if #targets > 0 then
                local t = targets[math.random(1, #targets)]
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                root.CFrame = t.CFrame + Constants.PLAYER_TELEPORT_OFFSET
            end
        end
    end)
end
local function teleportToNearestPlayer()
    pcall(function()
        local root = Helpers.getLocalRoot()
        local GamePlayers = Helpers.getGamePlayers()
        if root and GamePlayers then
            local nearest, nearDist = nil, math.huge
            for _, child in ipairs(GamePlayers:GetChildren()) do
                local childRoot = Helpers.getModelRoot(child)
                if childRoot and child.Name ~= LocalPlayer.Name
                    and not Helpers.isNextbot(child) then
                    local d = (childRoot.Position - root.Position).Magnitude
                    if d < nearDist then
                        nearDist = d
                        nearest = childRoot
                    end
                end
            end
            if nearest then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                root.CFrame = nearest.CFrame + Constants.PLAYER_TELEPORT_OFFSET
            end
        end
    end)
end
local function teleportToNearestDownedPlayer()
    pcall(function()
        local root = Helpers.getLocalRoot()
        local GamePlayers = Helpers.getGamePlayers()
        if root and GamePlayers then
            local nearestSafe: BasePart?, nearSafeDist = nil, math.huge
            local nearestAny: BasePart?, nearAnyDist = nil, math.huge
            for _, child in ipairs(GamePlayers:GetChildren()) do
                if child.Name ~= LocalPlayer.Name and Helpers.isDowned(child) then
                    local childRoot = Helpers.getModelRoot(child)
                    if childRoot then
                        local d = (childRoot.Position - root.Position).Magnitude
                        if d < nearAnyDist then
                            nearAnyDist = d
                            nearestAny = childRoot
                        end
                        local isSafe = true
                        for _, other in ipairs(GamePlayers:GetChildren()) do
                            if Helpers.isNextbot(other) then
                                local nbRoot = Helpers.getModelRoot(other)
                                if nbRoot and (nbRoot.Position - childRoot.Position).Magnitude <= Constants.REVIVE_SAFE_NEXTBOT_DIST then
                                    isSafe = false
                                    break
                                end
                            end
                        end
                        if isSafe and d < nearSafeDist then
                            nearSafeDist = d
                            nearestSafe = childRoot
                        end
                    end
                end
            end
            local chosen = nearestSafe or nearestAny
            if chosen then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                root.CFrame = chosen.CFrame * CFrame.new(0, 0, 2)
            end
        end
    end)
end
Features.Teleport = {
    ToSafeSpot = teleportToSafeSpot,
    ToMapCenter = teleportToMapCenter,
    ToRandomTeammate = teleportToRandomTeammate,
    ToNearestPlayer = teleportToNearestPlayer,
    ToNearestDownedPlayer = teleportToNearestDownedPlayer,
}
local function __InstallUI()
local ValincUi: any = (function()
        local TeekUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/dev/TempoUI.lua"))()
        local Q = {}
        function Q.CreateWindow(o)
            local UI = TeekUI.new({ Title = "TEMPO", Subtitle = "Evade", Version = "v1" })
            local W = { IsA = function() return false end }
            function W:Notify(title, msg, dur) pcall(function() UI:Notify(tostring(title) .. ": " .. tostring(msg), "info", dur or 3) end) end
            function W:Destroy() pcall(function() UI:Destroy() end) end
            function W:_mount() UI:mountInterface(UI:Tab("Interface", "sliders")) end
            function W:CreateTab(name, icon)
                local t = UI:Tab(name, icon)
                return { CreateSection = function(_, title)
                    t:Section(title)
                    return {
                        CreateToggle = function(_, n, def, cb) local h = t:Toggle(n, def and true or false, cb) return { Set = function(_, v) h.Set(v and true or false, true) end } end,
                        CreateSlider = function(_, n, min, max, def, _, cb) t:Slider(n, min, max, def, cb) return {} end,
                        CreateButton = function(_, n, cb) t:Button(n, false, cb) return {} end,
                        CreateLabel = function(_, text) return t:Label(text) end,
                    }
                end }
            end
            return W
        end
        return Q
    end)()
    local targetParent = Helpers.getSafeGuiContainer() or CoreGui
    local Window = ValincUi.CreateWindow({
        Title = "Tempo Hub",
        Subtitle = "Evade v" .. Helpers.SCRIPT_VERSION,
        Logo = Constants.UI_LOGO,
        ToggleKey = Constants.UI_TOGGLE_KEY,
        Parent = targetParent,
        DisplayOrder = 999999,
    })
    local uiRoot = Window.ScreenGui or Window.Gui or Window
    if uiRoot and uiRoot:IsA("ScreenGui") then
        pcall(function()
            uiRoot.DisplayOrder = 999999
            uiRoot.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            if targetParent and uiRoot.Parent ~= targetParent then
                uiRoot.Parent = targetParent
            end
        end)
    end
    Helpers.ValincSession.Window = Window
    Helpers.ValincSession.UI = uiRoot
    Features.Window = Window
    pcall(function()
        local tabList = uiRoot:FindFirstChild("TabList", true)
        local listLayout = tabList and tabList:FindFirstChildOfClass("UIListLayout")
        if listLayout then
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        end
    end)
    pcall(function()
        local bottombar = Window.Bottombar or (uiRoot and uiRoot:FindFirstChild("Bottombar", true))
        local statusLabel = bottombar and bottombar:FindFirstChild("StatusLabel")
        if statusLabel and statusLabel:IsA("TextLabel") then
            local uiVer = (ValincUi and ValincUi.Version) or "V7.0.0"
            local defaultStatus = string.format('<font color="#10b981">●</font>  TEMPO %s', string.upper(uiVer))
            statusLabel.Text = defaultStatus
            local conn = statusLabel:GetPropertyChangedSignal("Text"):Connect(function()
                if not statusLabel.Text:find("ℹ") and statusLabel.Text ~= defaultStatus then
                    statusLabel.Text = defaultStatus
                end
            end)
            keepConn(conn)
        end
    end)
    local T = {}
    T.Main     = Window:CreateTab("Main",     "user")
    T.Combat   = Window:CreateTab("Combat",   "shield")
    T.ESP      = Window:CreateTab("ESP",      "eye")
    T.Teleport = Window:CreateTab("Teleport", "globe")
    T.Info     = Window:CreateTab("Info",     "info")
    local MovementSec = T.Main:CreateSection("Player Movement")
    MovementSec:CreateToggle("Speed Hack", false, function(on)
        State.SpeedHack = on
        if not on then
            Features.Movement.ResetWalkSpeed()
        end
    end)
    MovementSec:CreateSlider("WalkSpeed", 16, 150, 40, false, function(val)
        State.SpeedValue = val
    end)
    MovementSec:CreateToggle("Jump Hack", false, function(on)
        State.JumpHack = on
        if not on then
            Features.Movement.ResetJump()
        end
    end)
    MovementSec:CreateSlider("JumpPower", 50, 200, 65, false, function(val)
        State.JumpValue = val
    end)
    MovementSec:CreateToggle("Infinite Jump", false, function(on)
        State.InfiniteJump = on
    end)
    MovementSec:CreateToggle("Bunny Hop (Bhop)", false, function(on)
        State.Bhop = on
    end)
    MovementSec:CreateToggle("Noclip", false, function(on)
        State.Noclip = on
        if not on then
            Features.Movement.ResetCollision()
        end
    end)
    local CameraSec = T.Main:CreateSection("Camera & Vision")
    CameraSec:CreateToggle("Third Person View", false, function(on)
        State.ThirdPerson = on
        if on then
            Features.Camera.EnableThirdPerson()
        else
            Features.Camera.DisableThirdPerson()
        end
    end)
    CameraSec:CreateToggle("No Camera Shake", false, function(on)
        State.NoCameraShake = on
        if not on then
            pcall(function()
                local hum = Helpers.getLocalHum()
                if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
            end)
        end
    end)
    CameraSec:CreateToggle("Custom Field of View", false, function(on)
        State.FovHack = on
        if not on then
            pcall(function()
                Workspace.CurrentCamera.FieldOfView = Constants.DEFAULT_FOV
            end)
        end
    end)
    CameraSec:CreateSlider("FOV Value", 70, 120, 70, false, function(val)
        State.FieldOfView = val
    end)
    local GameSec = T.Main:CreateSection("Gameplay Helper")
    GameSec:CreateToggle("Auto Revive", false, function(on)
        State.AutoRevive = on
    end)
    GameSec:CreateToggle("Teleport to Downed Player", false, function(on)
        State.AutoReviveTeleport = on
    end)
    GameSec:CreateToggle("Carry to Safety Before Revive", false, function(on)
        State.AutoReviveCarry = on
    end)
    GameSec:CreateToggle("Return to Original Position", false, function(on)
        State.AutoReviveReturn = on
    end)
    local CombatSec = T.Combat:CreateSection("Nextbot Control")
    CombatSec:CreateToggle("Freeze Nextbots", false, function(on)
        State.FreezeNextbots = on
        Features.Combat.RunFreezeCycle()
    end)
    CombatSec:CreateToggle("Auto Dodge Nextbots (<15m)", false, function(on)
        State.AutoDodge = on
    end)
    local UtilitySec = T.Combat:CreateSection("Utility")
    UtilitySec:CreateToggle("Auto Collect Items", false, function(on)
        State.AutoCollect = on
    end)
    UtilitySec:CreateButton("Whistle (Alert Nearby)", function()
        Net.FireWhistle()
    end)
    UtilitySec:CreateToggle("Auto Whistle Loop", false, function(on)
        State.AutoWhistle = on
    end)
    local FilterSec = T.ESP:CreateSection("Target Filters")
    FilterSec:CreateToggle("Players", false, function(on)
        State.EspPlayers = on
        Features.ESP.Refresh()
    end)
    FilterSec:CreateToggle("Downed Players", false, function(on)
        State.EspDowned = on
        Features.ESP.Refresh()
    end)
    FilterSec:CreateToggle("Nextbots", false, function(on)
        State.EspNextbots = on
        Features.ESP.Refresh()
    end)
    local VisualSec = T.ESP:CreateSection("Visual Overlays")
    VisualSec:CreateToggle("Body Chams", false, function(on)
        State.EspChams = on
        Features.ESP.Refresh()
    end)
    VisualSec:CreateToggle("Name Tags", false, function(on)
        State.EspNames = on
        Features.ESP.Refresh()
    end)
    VisualSec:CreateToggle("Tracers", false, function(on)
        State.EspTracers = on
        Features.ESP.Refresh()
    end)
    VisualSec:CreateToggle("Nextbot Box", false, function(on)
        State.EspBoxes = on
        Features.ESP.Refresh()
    end)
    local RadarSec = T.ESP:CreateSection("Nextbot Radar")
    RadarSec:CreateToggle("Radar HUD", false, function(on)
        State.NextbotRadar = on
        Features.ESP.RunRadarCycle()
    end)
    local TeleportSec = T.Teleport:CreateSection("Quick Teleports")
    TeleportSec:CreateButton("Teleport to Safe Spot (Sky)", function()
        Features.Teleport.ToSafeSpot()
    end)
    TeleportSec:CreateButton("Teleport to Map Center", function()
        Features.Teleport.ToMapCenter()
    end)
    local PlayerTpSec = T.Teleport:CreateSection("Teleport to Player")
    PlayerTpSec:CreateButton("Teleport to Downed Player", function()
        Features.Teleport.ToNearestDownedPlayer()
    end)
    PlayerTpSec:CreateButton("Teleport to Random Teammate", function()
        Features.Teleport.ToRandomTeammate()
    end)
    PlayerTpSec:CreateButton("Teleport to Nearest Player", function()
        Features.Teleport.ToNearestPlayer()
    end)
    local infoSection = T.Info:CreateSection("Information")
    infoSection:CreateLabel("Tempo Hub - Evade")
    infoSection:CreateLabel("Version: v" .. Helpers.SCRIPT_VERSION)
    infoSection:CreateButton("Copy Website URL", function()
        Util.safeSetClipboard("https://tempohub.shop")
        pcall(function()
            if Window.Notify then Window:Notify("System", "Website URL copied to clipboard!", 3)
            elseif ValincUi and ValincUi.Notify then ValincUi:Notify("System", "Website URL copied to clipboard!", 3) end
        end)
    end)
    infoSection:CreateButton("Copy Discord Invite", function()
        Util.safeSetClipboard("https://discord.gg/K7Qxnxkk46")
        pcall(function()
            if Window.Notify then Window:Notify("System", "Discord invite copied to clipboard!", 3)
            elseif ValincUi and ValincUi.Notify then ValincUi:Notify("System", "Discord invite copied to clipboard!", 3) end
        end)
    end)
    local creditsSection = T.Info:CreateSection("Credits")
    creditsSection:CreateLabel("Developer: Tempo Hub")
    local settingsSection = T.Info:CreateSection("Menu Settings")
    settingsSection:CreateButton("Unload Script", function()
        Helpers.ValincSession:Stop()
    end)
end
__InstallUI()
pcall(function() Features.Window:_mount() end)
local function spawnWorker(name: string, interval: number, action: () -> ())
    task.spawn(function()
        while alive() do
            task.wait(interval)
            pcall(action)
        end
    end)
end
task.spawn(function()
    while alive() do
        local dt = task.wait()
        pcall(function()
            Features.Movement.Step(dt)
        end)
    end
end)
spawnWorker("AutoReviveWorker", 0.1, function()
    Features.Revive.RunReviveCycle()
end)
spawnWorker("AutoDodgeWorker", 0.1, function()
    Features.Combat.RunDodgeCycle()
end)
task.spawn(function()
    while alive() do
        task.wait(State.WhistleInterval or Constants.WHISTLE_COOLDOWN)
        pcall(function()
            Features.Combat.RunWhistleCycle()
        end)
    end
end)
task.spawn(function()
    while alive() do
        task.wait(0.2)
        pcall(function()
            Features.ESP.RunEspCycle()
        end)
    end
    Features.ESP.CleanAll()
end)
spawnWorker("FreezeNextbotsWorker", 0.1, function()
    Features.Combat.RunFreezeCycle()
end)
spawnWorker("AutoCollectWorker", 0.5, function()
    Features.Collect.RunCollectCycle()
end)
spawnWorker("NextbotRadarWorker", 0.25, function()
    Features.ESP.RunRadarCycle()
end)
task.spawn(function()
    while alive() do
        task.wait(0.5)
        local uiExists = false
        pcall(function()
            local ui = Helpers.ValincSession.UI
            if ui and ui.Parent then uiExists = true end
        end)
        if not uiExists then
            Helpers.ValincSession:Stop()
            break
        end
    end
end)
State.IsReady = true
pcall(function()
    if Features.Window and type(Features.Window.Notify) == "function" then
        Features.Window:Notify("Tempo Hub", "Evade v" .. Helpers.SCRIPT_VERSION .. " loaded successfully!", 4)
    end
end)
select("#", "[Tempo] Evade v" .. Helpers.SCRIPT_VERSION .. " Initialized Successfully!")

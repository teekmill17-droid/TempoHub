-- ============================================================
-- MASKED GUI SELECTION - FULL VERSION
-- ============================================================
-- Digunakan untuk Violence District - The Masked
-- Shortcut: 1-6 pilih mask, 7 deactivate, M toggle GUI
-- ============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- ===== VARIABLES =====
local MaskGui = nil
local MaskKeyConn = nil
local MaskIsOpen = true
local MaskMinimizeBtn = nil
local MaskBodyFrame = nil
local MaskActive = false

-- ===== MASK DATA =====
local MASK_DATA = {
    { arg="Alex",    label="Swan",    image="https://www.roblox.com/asset-thumbnail/image?assetId=15946083863&width=420&height=420&format=png", key=Enum.KeyCode.One },
    { arg="Brandon", label="Panther", image="https://www.roblox.com/asset-thumbnail/image?assetId=111928367372122&width=420&height=420&format=png", key=Enum.KeyCode.Two },
    { arg="Cobra",   label="Cobra",   image="https://www.roblox.com/asset-thumbnail/image?assetId=15946288579&width=420&height=420&format=png", key=Enum.KeyCode.Three },
    { arg="Rabbit",  label="Rabbit",  image="https://www.roblox.com/asset-thumbnail/image?assetId=103750154338014&width=420&height=420&format=png", key=Enum.KeyCode.Four },
    { arg="Richter", label="Rat",     image="https://www.roblox.com/asset-thumbnail/image?assetId=590245826&width=420&height=420&format=png", key=Enum.KeyCode.Five },
    { arg="Tony",    label="Tiger",   image="https://www.roblox.com/asset-thumbnail/image?assetId=96793004678696&width=420&height=420&format=png", key=Enum.KeyCode.Six },
}
local MASK_DEFAULT_ARG = "Richard"

-- ===== FUNCTIONS =====
local function FireMask(argName)
    pcall(function()
        ReplicatedStorage:WaitForChild("Remotes")
            :WaitForChild("Killers"):WaitForChild("Masked"):WaitForChild("Activatepower"):FireServer(argName)
    end)
end

local function CheckIsMasked()
    local skVal = LP:GetAttribute("SelectedKiller")
    if skVal == nil then
        local sk = LP:FindFirstChild("SelectedKiller")
        if sk then skVal = sk.Value end
    end
    if skVal == nil then return false end
    return string.lower(tostring(skVal)):find("masked") ~= nil
end

local function GetMaskUIScale()
    local cam = Camera
    local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
    local shortSide = math.min(vp.X, vp.Y)
    return math.clamp(shortSide / 720, 0.7, 1.25)
end

local function setMaskPopupState(open)
    MaskIsOpen = open
    if MaskBodyFrame then MaskBodyFrame.Visible = open end
    if MaskMinimizeBtn then MaskMinimizeBtn.Text = open and "-" or "+" end
end

local function toggleMaskPopup()
    setMaskPopupState(not MaskIsOpen)
end

-- ===== BUILD GUI =====
local function BuildMaskGui()
    if MaskGui and MaskGui.Parent then MaskGui:Destroy() end

    local scale = GetMaskUIScale()
    local PANEL_W    = math.floor(230 * scale)
    local HEADER_H   = math.floor(34 * scale)
    local CARD_SIZE  = math.floor(62 * scale)
    local CARD_GAP   = math.floor(6 * scale)
    local PAD        = math.floor(8 * scale)
    local BTN_H      = math.floor(28 * scale)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MaskSelectionGUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 60
    screenGui.Parent = CoreGui

    local root = Instance.new("Frame")
    root.Name = "Root"
    root.Size = UDim2.new(0, PANEL_W, 0, HEADER_H)
    root.Position = UDim2.new(0.5, -PANEL_W/2, 0.16, 0)
    root.BackgroundTransparency = 1
    root.Parent = screenGui

    -- HEADER
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, HEADER_H)
    header.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    header.BorderSizePixel = 0
    header.ZIndex = 5
    header.Parent = root
    local hCorner = Instance.new("UICorner", header); hCorner.CornerRadius = UDim.new(0, 8)
    local hStroke = Instance.new("UIStroke", header)
    hStroke.Color = Color3.fromRGB(255, 153, 204); hStroke.Thickness = 1; hStroke.Transparency = 0.45

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Name = "Title"
    titleLbl.Size = UDim2.new(1, -HEADER_H - PAD, 1, 0)
    titleLbl.Position = UDim2.new(0, PAD, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "MASK SELECTION"
    titleLbl.TextColor3 = Color3.fromRGB(255, 153, 204)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = math.floor(13 * scale)
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
    titleLbl.ZIndex = 6
    titleLbl.Parent = header

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "Minimize"
    minimizeBtn.Size = UDim2.new(0, HEADER_H - 8, 0, HEADER_H - 8)
    minimizeBtn.Position = UDim2.new(1, -(HEADER_H - 4), 0.5, -(HEADER_H-8)/2)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 153, 204)
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(22, 22, 28)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = math.floor(16 * scale)
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.ZIndex = 7
    minimizeBtn.Parent = header
    local mbCorner = Instance.new("UICorner", minimizeBtn); mbCorner.CornerRadius = UDim.new(0, 6)
    MaskMinimizeBtn = minimizeBtn
    minimizeBtn.MouseButton1Click:Connect(function()
        toggleMaskPopup()
    end)

    -- BODY
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Size = UDim2.new(1, 0, 0, 0)
    body.Position = UDim2.new(0, 0, 0, HEADER_H + PAD*0.5)
    body.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    body.BorderSizePixel = 0
    body.ZIndex = 5
    body.Parent = root
    local bCorner = Instance.new("UICorner", body); bCorner.CornerRadius = UDim.new(0, 8)
    local bStroke = Instance.new("UIStroke", body)
    bStroke.Color = Color3.fromRGB(255, 153, 204); bStroke.Thickness = 1; bStroke.Transparency = 0.55
    MaskBodyFrame = body

    local bodyPadding = Instance.new("UIPadding")
    bodyPadding.PaddingTop = UDim.new(0, PAD)
    bodyPadding.PaddingBottom = UDim.new(0, PAD)
    bodyPadding.PaddingLeft = UDim.new(0, PAD)
    bodyPadding.PaddingRight = UDim.new(0, PAD)
    bodyPadding.Parent = body

    local bodyLayout = Instance.new("UIListLayout")
    bodyLayout.Padding = UDim.new(0, PAD * 0.6)
    bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    bodyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    bodyLayout.Parent = body

    -- STATUS LABEL
    local statusLbl = Instance.new("TextLabel")
    statusLbl.Name = "StatusLabel"
    statusLbl.LayoutOrder = 1
    statusLbl.Size = UDim2.new(1, 0, 0, math.floor(16 * scale))
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "Active Mask: None"
    statusLbl.TextColor3 = Color3.fromRGB(90, 240, 140)
    statusLbl.Font = Enum.Font.GothamBold
    statusLbl.TextSize = math.floor(11 * scale)
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.ZIndex = 6
    statusLbl.Parent = body

    -- GRID MASK
    local gridContainer = Instance.new("Frame")
    gridContainer.Name = "Grid"
    gridContainer.LayoutOrder = 2
    gridContainer.Size = UDim2.new(1, 0, 0, (CARD_SIZE * 3) + (CARD_GAP * 2))
    gridContainer.BackgroundTransparency = 1
    gridContainer.ZIndex = 6
    gridContainer.Parent = body

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, CARD_SIZE, 0, CARD_SIZE)
    grid.CellPadding = UDim2.new(0, CARD_GAP, 0, CARD_GAP)
    grid.FillDirection = Enum.FillDirection.Horizontal
    grid.FillDirectionMaxCells = 3
    grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    grid.VerticalAlignment = Enum.VerticalAlignment.Center
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = gridContainer

    local maskCards = {}
    local selectedMask = nil

    local function resetCardStrokes()
        for _, data in pairs(maskCards) do
            data.Stroke.Color = Color3.fromRGB(55, 55, 65)
            data.Stroke.Transparency = 0.3
        end
    end

    -- BUAT CARD MASK
    for i, mask in ipairs(MASK_DATA) do
        local card = Instance.new("ImageButton")
        card.Name = mask.label
        card.LayoutOrder = i
        card.Size = UDim2.new(0, CARD_SIZE, 0, CARD_SIZE)
        card.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
        card.BorderSizePixel = 0
        card.AutoButtonColor = false
        card.Image = mask.image
        card.ScaleType = Enum.ScaleType.Fit
        card.ZIndex = 7
        card.Parent = gridContainer
        local cCorner = Instance.new("UICorner", card); cCorner.CornerRadius = UDim.new(0, 8)
        local cStroke = Instance.new("UIStroke", card)
        cStroke.Color = Color3.fromRGB(55, 55, 65); cStroke.Thickness = 1.5
        cStroke.Transparency = 0.3
        cStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        -- BADGE NOMOR
        local numBadge = Instance.new("TextLabel")
        numBadge.Size = UDim2.new(0, math.floor(16*scale), 0, math.floor(16*scale))
        numBadge.Position = UDim2.new(0, 3, 0, 3)
        numBadge.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        numBadge.BackgroundTransparency = 0.35
        numBadge.Text = tostring(i)
        numBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
        numBadge.Font = Enum.Font.GothamBold
        numBadge.TextSize = math.floor(10 * scale)
        numBadge.BorderSizePixel = 0
        numBadge.ZIndex = 8
        numBadge.Parent = card
        local nCorner = Instance.new("UICorner", numBadge); nCorner.CornerRadius = UDim.new(0, 4)

        -- LABEL NAMA
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, 0, 0, math.floor(16 * scale))
        nameLbl.Position = UDim2.new(0, 0, 1, -math.floor(16*scale))
        nameLbl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        nameLbl.BackgroundTransparency = 0.3
        nameLbl.Text = mask.label
        nameLbl.TextColor3 = Color3.fromRGB(235, 235, 240)
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = math.floor(9 * scale)
        nameLbl.BorderSizePixel = 0
        nameLbl.ZIndex = 8
        nameLbl.Parent = card
        local nmCorner = Instance.new("UICorner", nameLbl); nmCorner.CornerRadius = UDim.new(0, 5)

        -- ACTIVATE FUNCTION
        local function activate()
            FireMask(mask.arg)
            selectedMask = mask.label
            statusLbl.Text = "Active Mask: " .. mask.label
            resetCardStrokes()
            cStroke.Color = Color3.fromRGB(255, 153, 204)
            cStroke.Transparency = 0
        end
        card.MouseButton1Click:Connect(activate)
        maskCards[mask.label] = {Stroke = cStroke}
        mask._activate = activate
    end

    -- DEACTIVATE BUTTON
    local deactBtn = Instance.new("TextButton")
    deactBtn.Name = "Deactivate"
    deactBtn.LayoutOrder = 3
    deactBtn.Size = UDim2.new(1, 0, 0, BTN_H)
    deactBtn.BackgroundColor3 = Color3.fromRGB(178, 42, 58)
    deactBtn.Text = "[7]  Deactivate"
    deactBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    deactBtn.Font = Enum.Font.GothamBold
    deactBtn.TextSize = math.floor(12 * scale)
    deactBtn.BorderSizePixel = 0
    deactBtn.ZIndex = 6
    deactBtn.Parent = body
    local dCorner = Instance.new("UICorner", deactBtn); dCorner.CornerRadius = UDim.new(0, 6)

    local function deactivateMask()
        FireMask(MASK_DEFAULT_ARG)
        selectedMask = nil
        statusLbl.Text = "Active Mask: None"
        resetCardStrokes()
    end
    deactBtn.MouseButton1Click:Connect(deactivateMask)

    -- AUTO RESIZE BODY
    bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        body.Size = UDim2.new(1, 0, 0, bodyLayout.AbsoluteContentSize.Y + PAD*2)
    end)

    -- ===== DRAG & DROP =====
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local moved = false
    local DRAG_THRESHOLD = 4

    local function beginDrag(pos)
        dragging = true
        moved = false
        dragStart = pos
        startPos = root.Position
    end

    local function updateDrag(pos)
        if not dragging then return end
        local delta = pos - dragStart
        if delta.Magnitude > DRAG_THRESHOLD then moved = true end
        local viewportSize = screenGui.AbsoluteSize
        if viewportSize.X <= 0 or viewportSize.Y <= 0 then return end
        local newX = startPos.X.Scale + (delta.X / viewportSize.X)
        local newY = startPos.Y.Scale + (delta.Y / viewportSize.Y)
        newX = math.clamp(newX, -0.15, 1.05)
        newY = math.clamp(newY, 0, 0.92)
        root.Position = UDim2.new(newX, startPos.X.Offset, newY, startPos.Y.Offset)
    end

    local function endDrag()
        dragging = false
    end

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag(Vector2.new(input.Position.X, input.Position.Y))
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
           or input.UserInputType == Enum.UserInputType.Touch) then
            updateDrag(Vector2.new(input.Position.X, input.Position.Y))
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local wasClick = not moved
                endDrag()
                if wasClick then toggleMaskPopup() end
            end
        end
    end)

    -- ===== KEYBOARD SHORTCUTS =====
    local keyConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or not screenGui.Parent then return end
        local focused = UserInputService:GetFocusedTextBox()
        if focused then return end
        for _, mask in ipairs(MASK_DATA) do
            if input.KeyCode == mask.key then mask._activate(); return end
        end
        if input.KeyCode == Enum.KeyCode.Seven then deactivateMask(); return end
    end)

    screenGui.AncestryChanged:Connect(function(_, parent)
        if not parent and keyConn then keyConn:Disconnect() end
    end)

    MaskGui = screenGui
    if MaskKeyConn then MaskKeyConn:Disconnect() end
    MaskKeyConn = keyConn

    setMaskPopupState(true)
    MaskActive = true
end

-- ===== DESTROY GUI =====
local function DestroyMaskGui()
    if MaskKeyConn then MaskKeyConn:Disconnect(); MaskKeyConn = nil end
    if MaskGui and MaskGui.Parent then MaskGui:Destroy(); MaskGui = nil end
    MaskActive = false
end

-- ===== TOGGLE FUNCTION =====
local function ToggleMaskSelection(state)
    if state then
        if not CheckIsMasked() then
            return false, "You're not The Masked!"
        end
        if not MaskActive then
            BuildMaskGui()
        else
            if MaskGui then MaskGui.Enabled = true end
            setMaskPopupState(true)
        end
        return true, "Done"
    else
        DestroyMaskGui()
        return true, "Dimatikan"
    end
end

-- ===== EXPORT =====
return {
    Toggle = ToggleMaskSelection,
    IsActive = function() return MaskActive end,
    Destroy = DestroyMaskGui,
    CheckMasked = CheckIsMasked,
}
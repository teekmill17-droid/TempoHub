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
local TeekUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/dev/TempoUI.lua"))()
getgenv().TempoHoodSubtitle = "50 PLAYER BINGO!"
do
	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")
	local HttpService = game:GetService("HttpService")
	local Toggles, Options = {}, {}
	getgenv().Toggles, getgenv().Options = Toggles, Options
	local function noop() end
	local stubT = { Value = false, Type = "Toggle", OnChanged = noop, SetValue = noop, SetText = noop }
	stubT.AddKeyPicker = function(self) return self end
	stubT.AddColorPicker = function(self) return self end
	local stubO = { Value = nil, Type = "Stub", OnChanged = noop, OnClick = noop, SetValue = noop,
		SetValues = noop, SetValueRGB = noop, GetState = function() return false end }
	setmetatable(Toggles, { __index = function() return stubT end })
	setmetatable(Options, { __index = function() return stubO end })
	local Library = {
		Toggles = Toggles, Options = Options, Unloaded = false,
		AccentColor = Color3.fromRGB(46, 155, 255), Theme = {}, KeybindFrame = nil,
		unloadFns = {}, ui = nil, Scheme = {}, Labels = {}, Buttons = {},
	}
	local METHOD = { "^Set", "^Add", "^Update", "^On", "^Get", "^Refresh", "^Show", "^Hide", "^Load",
		"^Save", "^Apply", "^Create", "^Build", "^Remove", "^Destroy", "^Validate", "^Display", "^Lock", "^Unlock" }
	local function isMethod(k)
		if type(k) ~= "string" then return false end
		for _, p in ipairs(METHOD) do if string.find(k, p) then return true end end
		return false
	end
	local Stub
	Stub = setmetatable({}, { __index = function(_, k) if isMethod(k) then return function() return Stub end end end })
	local function lenient(t)
		return setmetatable(t, { __index = function(_, k) if isMethod(k) then return function() return Stub end end end })
	end
	local function loose(t)
		return setmetatable(t, { __index = function(_, k) if type(k) == "string" and string.find(k, "^%u") then return function() return Stub end end end })
	end
	lenient(Library)
	local Policy = getgenv().TempoUIPolicy or {}
	local HIDE, HIDEG = Policy.hide or {}, Policy.hideGroups or {}
	for _, n in ipairs({ "Discord", "Socials", "Tempo Hub", "Donations", "Donate", "Community",
		"Account", "User", "Game Info", "Basic Info", "Player Info", "Credits", "Support", "Links", "Scripts", "Features" }) do
		if HIDEG[n] == nil then HIDEG[n] = true end
	end
	local HIDE_TABS = { Info = true, Information = true, Credits = true, Donate = true, Donations = true, Socials = true, About = true }
	local function brandButton(text)
		local s = string.lower(tostring(text or ""))
		if string.find(s, "webhook", 1, true) then return false end
		for _, w in ipairs({ "discord", "rscripts", "litecoin", "bitcoin", "ethereum", "usdt", "paypal", "venmo",
			"donat", "website", "youtube", "profile link" }) do
			if string.find(s, w, 1, true) then return true end
		end
		return false
	end
	local RENAME, GRENAME = Policy.rename or {}, Policy.groupRename or {}
	local SMALL = { a = 1, an = 1, ["and"] = 1, at = 1, by = 1, ["for"] = 1, ["in"] = 1, of = 1,
		on = 1, ["or"] = 1, the = 1, to = 1, per = 1, vs = 1 }
	local UPPER = { esp = "ESP", fov = "FOV", hud = "HUD", id = "ID", ui = "UI", ko = "KO", fps = "FPS",
		rgb = "RGB", npc = "NPC", hp = "HP", dps = "DPS" }
	local function tidy(str)
		str = tostring(str or ""):gsub("%s+", " "):gsub("^ ", ""):gsub(" $", "")
		local i = 0
		return (str:gsub("[%a][%w']*", function(w)
			i += 1
			local lw = w:lower()
			if UPPER[lw] then return UPPER[lw] end
			if w ~= lw then return w end
			if i > 1 and SMALL[lw] then return lw end
			return lw:sub(1, 1):upper() .. lw:sub(2)
		end))
	end
	local function titleOf(idx, text) return RENAME[idx] or tidy(text or idx) end
	local Dummy = setmetatable({}, { __index = function() return function() return nil end end })
	local groups = {}
	local breatheAt = os.clock()
	local function breathe()
		if os.clock() - breatheAt > 0.025 then
			if coroutine.isyieldable() then task.wait() end
			breatheAt = os.clock()
		end
	end
	local function fire(fn, ...)
		if type(fn) == "function" then
			local ok, err = pcall(fn, ...)
			if not ok then warn("[Tempo] callback error: " .. tostring(err)) end
		end
	end
	local function fireChanged(obj)
		for _, fn in ipairs(obj._changed) do fire(fn, obj.Value) end
	end
	local function onChanged(obj, fn)
		table.insert(obj._changed, fn)
		fire(fn, obj.Value)
	end
	local function keyMatches(name, input)
		if not name or name == "None" or name == "" then return false end
		if name == "MB1" then return input.UserInputType == Enum.UserInputType.MouseButton1 end
		if name == "MB2" then return input.UserInputType == Enum.UserInputType.MouseButton2 end
		if name == "MB3" then return input.UserInputType == Enum.UserInputType.MouseButton3 end
		return input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode.Name == name
	end
	local function keyName(input)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 then return "MB1" end
		if t == Enum.UserInputType.MouseButton2 then return "MB2" end
		if t == Enum.UserInputType.MouseButton3 then return "MB3" end
		if t == Enum.UserInputType.Keyboard then return input.KeyCode.Name end
		return nil
	end
	local pickers = {}
	local keyConns = {}
	local function typing() return UIS:GetFocusedTextBox() ~= nil end
	keyConns[#keyConns + 1] = UIS.InputBegan:Connect(function(input)
		if Library.Unloaded or typing() then return end
		for _, kp in ipairs(pickers) do
			if not kp._listening and keyMatches(kp.Value, input) then
				if kp.Mode == "Hold" then
					kp.Toggled = true
					fire(kp.Callback, true)
				elseif kp.Mode == "Toggle" then
					kp.Toggled = not kp.Toggled
					fire(kp.Callback, kp.Toggled)
					if kp.SyncToggleState and kp._parent and kp._parent.SetValue then
						kp._parent:SetValue(kp.Toggled)
					end
				else
					fire(kp.Callback, true)
				end
				for _, fn in ipairs(kp._clicked) do fire(fn) end
			end
		end
	end)
	keyConns[#keyConns + 1] = UIS.InputEnded:Connect(function(input)
		if Library.Unloaded then return end
		for _, kp in ipairs(pickers) do
			if kp.Mode == "Hold" and keyMatches(kp.Value, input) then
				kp.Toggled = false
				fire(kp.Callback, false)
			end
		end
	end)
	local TICK = "\u{2713} "
	local function tempoRaw(t)
		local R = {}
		function R:Toggle(c)
			local h = t:Toggle(c.Title, c.Value and true or false, c.Callback)
			return { Set = function(_, v) h.Set(v and true or false, false) end, SetTitle = noop, SetDesc = noop }
		end
		function R:Slider(c)
			local v = c.Value or {}
			local h = t:Slider(c.Title, v.Min or 0, v.Max or 100, v.Default or v.Min or 0, c.Callback)
			return { Set = function(_, x) h.Set(x) end, SetTitle = noop, SetDesc = noop }
		end
		function R:Dropdown(c)
			local values = c.Values or {}
			if c.Multi then
				local set = {}
				for _, x in ipairs(type(c.Value) == "table" and c.Value or {}) do set[x] = true end
				local h
				local function items()
					local out = {}
					for _, x in ipairs(values) do out[#out + 1] = (set[x] and TICK or "") .. x end
					return #out > 0 and out or { "-" }
				end
				local function list() local o = {} for _, x in ipairs(values) do if set[x] then o[#o + 1] = x end end return o end
				h = t:Dropdown(c.Title, items(), nil, function(pick)
					local x = tostring(pick)
					if x:sub(1, #TICK) == TICK then x = x:sub(#TICK + 1) end
					set[x] = not set[x] or nil
					h.SetItems(items(), (set[x] and TICK or "") .. x)
					if c.Callback then c.Callback(list()) end
				end)
				return { Refresh = function(_, nv) values = nv or {} h.SetItems(items()) end, Select = noop, SetDesc = noop }
			end
			local h = t:Dropdown(c.Title, values, c.Value, c.Callback)
			return { Refresh = function(_, nv) h.SetItems(nv or {}, h.Get()) end, Select = function(_, x) h.Set(x) end, SetDesc = noop }
		end
		function R:Input(c)
			local h = t:Input(c.Title, c.Value or "", c.Callback)
			return { Set = function(_, x) h.Text = tostring(x) end, SetDesc = noop }
		end
		function R:Button(c)
			local h = t:Button(c.Title, false, c.Callback)
			return { SetTitle = function(_, x) pcall(function() h:SetTitle(x) end) end, SetDesc = noop }
		end
		function R:Colorpicker(c)
			local h = t:Color(c.Title, c.Default, function(col) if c.Callback then c.Callback(col) end end)
			return { Update = function(_, col) h.Set(col) end, SetDesc = noop }
		end
		function R:Divider() t:Divider() end
		return R
	end
	local Groupbox = {}
	Groupbox.__index = function(_, k)
		local f = rawget(Groupbox, k)
		if f ~= nil then return f end
		if isMethod(k) then return function() return Stub end end
	end
	local usedNames = {}
	local flushed = false
	local lastAdd = 0
	local function standIn()
		local e = { _ops = {} }
		for _, m in ipairs({ "Set", "SetTitle", "SetDesc", "Refresh", "Select", "Update" }) do
			e[m] = function(self, ...)
				if self.real and self.real[m] then return self.real[m](self.real, ...) end
				self._ops[m] = table.pack(...)
			end
		end
		return e
	end
	local function drawBox(g)
		if g.drawn or #g.queue == 0 then return end
		g.drawn = true
		pcall(function() g.tab.w:Section(g.shown) end)
		local real = tempoRaw(g.tab.w)
		g.real = real
		for _, q in ipairs(g.queue) do
			local ok, el = pcall(real[q.m], real, q.cfg)
			if ok and type(el) == "table" and q.e then
				q.e.real = el
				for m, args in pairs(q.e._ops) do
					if el[m] then pcall(el[m], el, table.unpack(args, 1, args.n)) end
				end
				q.e._ops = {}
			end
		end
		g.queue = {}
	end
	local function flushAll()
		if flushed then return end
		flushed = true
		local order = {}
		for _, t in ipairs(Library._wtabs or {}) do
			order[#order + 1] = t
			for _, k in ipairs(t.kids) do order[#order + 1] = k end
		end
		for _, t in ipairs(order) do
			for _, g in ipairs(t.boxes) do drawBox(g) end
		end
		for _, t in ipairs(order) do
			local w = rawget(t, "w")
			if w then pcall(function() w.flowed = false w:_flow() end) end
		end
		if Library._wantInterface then Library._mountInterface() end
	end
	Library._flush = flushAll
	task.spawn(function()
		while not flushed do
			task.wait(0.25)
			if lastAdd > 0 and os.clock() - lastAdd > 1 then flushAll() end
		end
	end)
	local function newGroupbox(tab, title, prefix)
		breathe()
		title = tostring(title or "")
		if HIDEG[title] or tab.hidden then
			return setmetatable({ tab = tab, raw = Dummy, title = title, hidden = true, n = 0 }, Groupbox)
		end
		local shown = GRENAME[title] or tidy(title)
		if usedNames[shown] or (prefix and string.lower(title) == "customization") then
			shown = (prefix and tidy(prefix) or tidy(tab.name)) .. " " .. shown
		end
		usedNames[shown] = true
		local g = setmetatable({ tab = tab, title = title, shown = shown, n = 0, queue = {} }, Groupbox)
		g.raw = setmetatable({}, { __index = function(_, k)
			return function(_, cfg)
				lastAdd = os.clock()
				if flushed then
					if not g.drawn then
						g.drawn = true
						pcall(function() g.tab.w:Section(g.shown) end)
						g.real = tempoRaw(g.tab.w)
					end
					local f = g.real[k]
					return f and f(g.real, cfg)
				end
				local e = (k ~= "Divider") and standIn() or nil
				g.queue[#g.queue + 1] = { m = k, cfg = cfg, e = e }
				return e
			end
		end })
		table.insert(tab.boxes, g)
		groups[#groups + 1] = g
		return g
	end
	function Groupbox:_rawFor(idx)
		if self.hidden or HIDE[idx] then return Dummy, true end
		self.n += 1
		return self.raw, false
	end
	function Groupbox:_reveal()
		if not self.sec or self._rq then return end
		self._rq = true
		task.defer(function()
			self._rq = false
			pcall(function()
				local c = self.sec.ElementFrame:FindFirstChild("Content", true)
				if c then c.Visible = true end
			end)
		end)
	end
	local function desc(e, text)
		if text and e and e.SetDesc then pcall(function() e:SetDesc(text) end) end
	end
	local Chain = {}
	function Chain.AddKeyPicker(parent, idx, info)
		breathe()
		info = info or {}
		local kp = {
			Type = "KeyPicker", Value = info.Default or "None", Mode = info.Mode or "Toggle",
			Text = titleOf(idx, info.Text), Callback = info.Callback, ChangedCallback = info.ChangedCallback,
			SyncToggleState = info.SyncToggleState, Toggled = false, _parent = parent,
			_changed = {}, _clicked = {}, _listening = false,
		}
		function kp:GetState()
			if self.Mode == "Always" then return true end
			if self.Mode == "Hold" then
				if self.Value == "MB1" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end
				if self.Value == "MB2" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
				local ok, kc = pcall(function() return Enum.KeyCode[self.Value] end)
				return ok and kc and UIS:IsKeyDown(kc) or false
			end
			return self.Toggled
		end
		function kp:OnClick(fn) table.insert(self._clicked, fn) end
		function kp:OnChanged(fn) table.insert(self._changed, fn) end
		local btn
		local function label() return string.format("%s   [ %s ]", tostring(kp.Text), tostring(kp.Value)) end
		function kp:SetValue(v)
			if type(v) == "table" then
				self.Value = v[1] or self.Value
				self.Mode = v[2] or self.Mode
			else
				self.Value = tostring(v)
			end
			if btn then pcall(function() btn.Text = label() end) end
			fire(self.ChangedCallback, self.Value)
			for _, fn in ipairs(self._changed) do fire(fn, self.Value) end
		end
		if not info.NoUI then
			local g = parent._group
			local e
			local function setTitle(t) if e then pcall(function() e:SetTitle(t) end) end end
			btn = setmetatable({}, { __newindex = function(_, k, v) if k == "Text" then setTitle(v) end end })
			local where = (parent._hidden or HIDE[idx]) and Dummy or g.raw
			pcall(function() e = where:Button({ Title = label(), Callback = function()
				if kp._listening then return end
				kp._listening = true
				setTitle(tostring(kp.Text) .. "   [ press a key ]")
				local conn
				conn = UIS.InputBegan:Connect(function(input)
					local n = keyName(input)
					if not n then return end
					conn:Disconnect()
					if n == "MB1" and false then return end
					if n == "Escape" or n == "Backspace" then n = "None" end
					task.defer(function() kp._listening = false end)
					kp:SetValue(n)
				end)
			end }) end)
		end
		table.insert(pickers, kp)
		Options[idx] = lenient(kp)
		return parent
	end
	function Chain.AddColorPicker(parent, idx, info)
		breathe()
		info = info or {}
		local cp = {
			Type = "ColorPicker", Value = info.Default or Color3.new(1, 1, 1),
			Transparency = info.Transparency or 0, Callback = info.Callback, _changed = {},
		}
		local g = parent._group
		local e
		local ready = false
		local cpHidden = parent._hidden or HIDE[idx]
		if g and not cpHidden then g.n = (g.n or 0) + 1 end
		if g then
			pcall(function()
				e = (cpHidden and Dummy or g.raw):Colorpicker({
					Title = RENAME[idx] or tidy(info.Title or parent.Text or idx),
					Default = cp.Value,
					Transparency = info.Transparency,
					Callback = function(c, t)
						if not ready then return end
						cp.Value = c
						if t ~= nil then cp.Transparency = t end
						fire(cp.Callback, c)
						fireChanged(cp)
					end,
				})
			end)
		end
		ready = true
		function cp:SetValueRGB(c, t)
			self.Value = c
			if t ~= nil then self.Transparency = t end
			if e then pcall(function() e:Update(c, t) end) end
			fire(self.Callback, c)
			fireChanged(self)
		end
		function cp:SetValue(hsv, t)
			if typeof(hsv) == "Color3" then return self:SetValueRGB(hsv, t) end
			if type(hsv) == "table" then return self:SetValueRGB(Color3.fromHSV(hsv[1], hsv[2], hsv[3]), t) end
		end
		function cp:OnChanged(fn) onChanged(self, fn) end
		Options[idx] = lenient(cp)
		return parent
	end
	function Groupbox:AddToggle(idx, info)
		breathe()
		info = info or {}
		local tg = {
			Type = "Toggle", Value = info.Default and true or false, Text = titleOf(idx, info.Text),
			Callback = info.Callback, _changed = {}, _group = self,
		}
		local raw, hid = self:_rawFor(idx)
		tg._hidden = hid
		local ready = false
		local e
		pcall(function()
			e = raw:Toggle({
				Title = tg.Text,
				Value = tg.Value,
				Callback = function(v)
					v = v and true or false
					if not ready or v == tg.Value then return end
					tg.Value = v
					fire(tg.Callback, v)
					fireChanged(tg)
				end,
			})
		end)
		ready = true
		desc(e, info.Tooltip)
		function tg:SetValue(v)
			v = v and true or false
			self.Value = v
			ready = false
			if e then pcall(function() e:Set(v) end) end
			ready = true
			fire(self.Callback, v)
			fireChanged(self)
		end
		function tg:SetText(t)
			self.Text = t
			if e then pcall(function() e:SetTitle(t) end) end
		end
		function tg:OnChanged(fn) onChanged(self, fn) end
		tg.AddKeyPicker = Chain.AddKeyPicker
		tg.AddColorPicker = Chain.AddColorPicker
		Toggles[idx] = lenient(tg)
		return tg
	end
	function Groupbox:AddSlider(idx, info)
		breathe()
		info = info or {}
		local rounding = info.Rounding or 0
		local function round(v)
			local m = 10 ^ rounding
			return math.floor(v * m + 0.5) / m
		end
		local sl = {
			Type = "Slider", Value = info.Default or info.Min or 0, Min = info.Min or 0, Max = info.Max or 100,
			Rounding = rounding, Callback = info.Callback, _changed = {},
		}
		local title = titleOf(idx, info.Text)
		local raw = self:_rawFor(idx)
		if info.Suffix and info.Suffix ~= "" then title = title .. " (" .. tostring(info.Suffix):gsub("^%s+", "") .. ")" end
		local ready = false
		local e
		pcall(function()
			e = raw:Slider({
				Title = title,
				Step = 10 ^ -rounding,
				Value = { Min = sl.Min, Max = sl.Max, Default = sl.Value },
				Callback = function(v)
					v = round(tonumber(v) or sl.Value)
					if not ready or v == sl.Value then return end
					sl.Value = v
					fire(sl.Callback, v)
					fireChanged(sl)
				end,
			})
		end)
		ready = true
		desc(e, info.Tooltip)
		function sl:SetValue(v)
			v = round(math.clamp(tonumber(v) or self.Value, self.Min, self.Max))
			self.Value = v
			ready = false
			if e then pcall(function() e:Set(v) end) end
			ready = true
			fire(self.Callback, v)
			fireChanged(self)
		end
		function sl:SetMin(v) self.Min = v end
		function sl:SetMax(v) self.Max = v end
		function sl:OnChanged(fn) onChanged(self, fn) end
		Options[idx] = lenient(sl)
		return sl
	end
	local function playerNames()
		local out = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= Players.LocalPlayer then out[#out + 1] = p.Name end
		end
		table.sort(out)
		return out
	end
	local function safeValues(values)
		local out, seen = {}, {}
		for _, v in ipairs(values or {}) do
			local s = tostring(v)
			if not seen[s] then seen[s] = true ; out[#out + 1] = s end
		end
		if #out == 0 then out[1] = "-" end
		return out
	end
	function Groupbox:AddDropdown(idx, info)
		breathe()
		info = info or {}
		local isPlayer = info.SpecialType == "Player"
		local values = isPlayer and playerNames() or (info.Values or {})
		local dd = {
			Type = "Dropdown", Values = values, Multi = info.Multi, Callback = info.Callback,
			_changed = {}, AllowNull = info.AllowNull,
		}
		local def = info.Default
		if type(def) == "number" then def = values[def] end
		if dd.Multi then
			dd.Value = {}
			if type(def) == "table" then for _, v in ipairs(def) do dd.Value[v] = true end end
		else
			dd.Value = def or (not isPlayer and not info.AllowNull and values[1]) or nil
		end
		local raw = self:_rawFor(idx)
		local quiet = true
		local e
		pcall(function()
			e = raw:Dropdown({
				Title = titleOf(idx, info.Text),
				Values = safeValues(values),
				Value = dd.Multi and {} or (dd.Value and tostring(dd.Value) or nil),
				Multi = dd.Multi or nil,
				AllowNone = (dd.Multi or isPlayer or info.AllowNull) and true or nil,
				SearchBarEnabled = (#values > 8 or isPlayer) or nil,
				Callback = function(v)
					if quiet then return end
					if dd.Multi then
						local set = {}
						for _, x in ipairs(type(v) == "table" and v or {}) do set[x] = true end
						dd.Value = set
					else
						if v == "-" then v = nil end
						if v == dd.Value then return end
						dd.Value = v
					end
					fire(dd.Callback, dd.Value)
					fireChanged(dd)
				end,
			})
		end)
		quiet = false
		desc(e, info.Tooltip)
		function dd:SetValues(list)
			self.Values = list or {}
			quiet = true
			if e then pcall(function() e:Refresh(safeValues(self.Values)) end) end
			if not self.Multi and self.Value then pcall(function() e:Select(tostring(self.Value)) end) end
			quiet = false
		end
		function dd:SetValue(v)
			self.Value = v
			quiet = true
			if e and v ~= nil and not self.Multi then pcall(function() e:Select(tostring(v)) end) end
			quiet = false
			fire(self.Callback, v)
			fireChanged(self)
		end
		function dd:OnChanged(fn) onChanged(self, fn) end
		if isPlayer then
			local function refresh() dd:SetValues(playerNames()) end
			table.insert(keyConns, Players.PlayerAdded:Connect(refresh))
			table.insert(keyConns, Players.PlayerRemoving:Connect(function() task.defer(refresh) end))
		end
		Options[idx] = lenient(dd)
		return dd
	end
	function Groupbox:AddInput(idx, info)
		breathe()
		info = info or {}
		local ip = { Type = "Input", Value = tostring(info.Default or ""), Callback = info.Callback, _changed = {}, Numeric = info.Numeric }
		local raw = self:_rawFor(idx)
		local ready = false
		local e
		pcall(function()
			e = raw:Input({
				Title = titleOf(idx, info.Text),
				Value = ip.Value,
				Placeholder = info.Placeholder or "",
				Callback = function(v)
					if not ready then return end
					v = tostring(v or "")
					if ip.Numeric and v ~= "" and not tonumber(v) then return end
					if v == ip.Value then return end
					ip.Value = v
					fire(ip.Callback, v)
					fireChanged(ip)
				end,
			})
		end)
		ready = true
		desc(e, info.Tooltip)
		function ip:SetValue(v)
			v = tostring(v or "")
			self.Value = v
			ready = false
			if e then pcall(function() e:Set(v) end) end
			ready = true
			fire(self.Callback, v)
			fireChanged(self)
		end
		function ip:OnChanged(fn) onChanged(self, fn) end
		Options[idx] = lenient(ip)
		return ip
	end
	function Groupbox:AddButton(a, b)
		breathe()
		local text, fn = a, b
		if type(a) == "table" then text, fn = a.Text, a.Func or a.Callback end
		local btn = lenient({ Text = text })
		local raw = brandButton(text) and Dummy or self:_rawFor(tostring(text))
		pcall(function() raw:Button({ Title = titleOf(tostring(text), tostring(text)), Callback = function() fire(fn) end }) end)
		function btn:AddButton(x, y) return Groupbox.AddButton(self._group, x, y) end
		btn._group = self
		return btn
	end
	function Groupbox:AddLabel(text, wrap, idx)
		breathe()
		if type(text) == "table" then idx = wrap text = text.Text end
		if type(wrap) == "string" then idx = wrap end
		local lb = lenient({ Type = "Label", Text = text, _group = self })
		if type(idx) == "string" then Options[idx] = lb end
		lb._hidden = self.hidden
		local p
		function lb:SetText(t)
			self.Text = t
			if p then pcall(function() p:SetTitle(tostring(t)) end) end
		end
		lb.AddKeyPicker = Chain.AddKeyPicker
		lb.AddColorPicker = Chain.AddColorPicker
		return lb
	end
	function Groupbox:AddDivider()
		if not self.hidden then pcall(function() self.raw:Divider() end) end
	end
	function Groupbox:AddBlank() end
	function Groupbox:AddDependencyBox() return self end
	function Groupbox:SetupDependencies() end
	function Groupbox:AddDualSlider(a, b, infoA, infoB)
		self:AddSlider(a, infoA)
		return self:AddSlider(b, infoB)
	end
	function Library:AddToRegistry() end
	for _, name in ipairs({ "AddToggle", "AddSlider", "AddDropdown", "AddInput", "AddButton", "AddLabel", "AddDivider" }) do
		local f = Groupbox[name]
		Groupbox[name] = function(self, ...)
			local r = f(self, ...)
			self:_reveal()
			return r
		end
	end
	for _, name in ipairs({ "AddKeyPicker", "AddColorPicker" }) do
		local f = Chain[name]
		Chain[name] = function(parent, ...)
			local r = f(parent, ...)
			if parent._group then parent._group:_reveal() end
			return r
		end
	end
	local Tab = {}
	local function groupOf(t)
		if not t.group then t.group = t.window.ui:Group(tidy(t.name)) end
		return t.group
	end
	Tab.__index = function(t, k)
		if k == "w" then
			local ui = t.window.ui
			local w
			if t.parent then w = groupOf(t.parent):Tab(tidy(t.name))
			elseif #t.kids > 0 then w = groupOf(t):Tab(tidy(t.name))
			else w = ui:Tab(tidy(t.name)) end
			rawset(t, "w", w)
			return w
		end
		local f = rawget(Tab, k)
		if f ~= nil then return f end
		if isMethod(k) then return function() return Stub end end
	end
	function Tab:AddSubTab(name)
		local s = setmetatable({ name = tostring(name or "Page"), window = self.window, parent = self, boxes = {}, kids = {}, hidden = self.hidden }, Tab)
		table.insert(self.kids, s)
		return s
	end
	Tab.AddPage = Tab.AddSubTab
	function Tab:AddLeftGroupbox(name) return newGroupbox(self, name) end
	function Tab:AddRightGroupbox(name) return newGroupbox(self, name) end
	function Tab:AddGroupbox(info) return newGroupbox(self, type(info) == "table" and info.Name or tostring(info)) end
	local function tabbox(tab)
		local first
		return { AddTab = function(_, name)
			local g = newGroupbox(tab, name, first)
			first = first or name
			return g
		end }
	end
	function Tab:AddLeftTabbox() return tabbox(self) end
	function Tab:AddRightTabbox() return tabbox(self) end
	local Window = {}
	Window.__index = function(_, k)
		local f = rawget(Window, k)
		if f ~= nil then return f end
		if isMethod(k) then return function() return Stub end end
	end
	function Window:AddTab(name)
		if type(name) == "table" then name = name.Name or name.Title end
		name = tostring(name or "Tab")
		local t = setmetatable({ name = name, window = self, boxes = {}, kids = {}, hidden = HIDE_TABS[name] }, Tab)
		Library._wtabs = Library._wtabs or {}
		table.insert(Library._wtabs, t)
		return t
	end
	function Library:CreateWindow(opts)
		opts = opts or {}
		local ui = TeekUI.new({ Title = "Tempo Hub", Subtitle = getgenv().TempoHoodSubtitle or "GAMES", Version = "v1" })
		self.ui = ui
		task.defer(function() pcall(function() ui:Show() end) end)
		return setmetatable({ ui = ui }, Window)
	end
	function Library:Toggle() if self.ui then pcall(function() self.ui:Toggle() end) end end
	function Library:Notify(text, seconds)
		if type(text) == "table" then
			local d = text.Description or text.Content or text.Text
			seconds = tonumber(text.Time) or seconds
			text = (text.Title and d) and (tostring(text.Title) .. ": " .. tostring(d)) or (d or text.Title or "")
		end
		if type(seconds) ~= "number" then seconds = nil end
		if self.ui then pcall(function() self.ui:Notify(tostring(text), nil, seconds) end) end
	end
	function Library:SetWatermark() end
	function Library:SetWatermarkVisibility() end
	function Library:UpdateColors() end
	function Library:OnUnload(fn) table.insert(self.unloadFns, fn) end
	Library.MainColor = Color3.fromRGB(22, 23, 28)
	Library.BackgroundColor = Color3.fromRGB(16, 17, 21)
	Library.OutlineColor = Color3.fromRGB(45, 47, 56)
	Library.FontColor = Color3.fromRGB(235, 236, 240)
	Library.Font = Enum.Font.Gotham
	do
		local sg = Instance.new("ScreenGui")
		sg.Name = "TempoOverlay"
		sg.ResetOnSpawn = false
		sg.IgnoreGuiInset = true
		sg.DisplayOrder = 2147483640
		sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
		pcall(function() sg.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
		if not sg.Parent then sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
		Library.ScreenGui = sg
		local kf = Instance.new("Frame")
		kf.Name = "KeybindFrame"
		kf.Visible = false
		kf.Parent = sg
		Library.KeybindFrame = kf
	end
	function Library:Create(class, props)
		local inst = type(class) == "string" and Instance.new(class) or class
		for k, v in pairs(props or {}) do
			if k ~= "Parent" then pcall(function() inst[k] = v end) end
		end
		if props and props.Parent then inst.Parent = props.Parent end
		return inst
	end
	function Library:CreateLabel(props, isHud)
		local l = self:Create("TextLabel", { BackgroundTransparency = 1, Font = self.Font, TextColor3 = self.FontColor, TextSize = 14, TextStrokeTransparency = 0 })
		return self:Create(l, props)
	end
	function Library:UpdateDependencyBoxes() end
	function Library:Unload()
		if self.Unloaded then return end
		for _, fn in ipairs(self.unloadFns) do fire(fn) end
		self.Unloaded = true
		for _, c in ipairs(keyConns) do pcall(function() c:Disconnect() end) end
		if self.ui then pcall(function() self.ui:Destroy() end) end
		pcall(function() self.ScreenGui:Destroy() end)
	end
	getgenv().Library = Library
	local SaveManager = lenient({ folder = "TempoHub/games", ignore = {} })
	SaveManager.Ignore = SaveManager.ignore
	SaveManager.Library = Library
	local function ensure(path)
		if not (isfolder and makefolder) then return end
		local acc = ""
		for part in string.gmatch(path, "[^/]+") do
			acc = acc == "" and part or (acc .. "/" .. part)
			pcall(function() if not isfolder(acc) then makefolder(acc) end end)
		end
	end
	function SaveManager:SetLibrary() end
	function SaveManager:IgnoreThemeSettings() end
	function SaveManager:SetIgnoreIndexes(list) for _, k in ipairs(list or {}) do self.ignore[k] = true end end
	function SaveManager:SetFolder(f)
		f = tostring(f):gsub("^TempoHub/?", "")
		self.folder = "TempoHub/games/" .. (f ~= "" and f or "configs")
		ensure(self.folder)
	end
	function SaveManager:Save(name)
		if not writefile then return false, "no writefile" end
		local data = { toggles = {}, options = {} }
		for k, t in pairs(Toggles) do if not self.ignore[k] then data.toggles[k] = t.Value end end
		for k, o in pairs(Options) do
			if not self.ignore[k] then
				if o.Type == "ColorPicker" then data.options[k] = { "c", o.Value:ToHex(), o.Transparency }
				elseif o.Type == "KeyPicker" then data.options[k] = { "k", o.Value, o.Mode }
				elseif o.Type == "Dropdown" and o.Multi then
					local l = {} for v, on in pairs(o.Value or {}) do if on then l[#l + 1] = v end end
					data.options[k] = { "m", l }
				elseif o.Value ~= nil then data.options[k] = { "v", o.Value } end
			end
		end
		ensure(self.folder)
		local ok = pcall(function() writefile(self.folder .. "/" .. name .. ".json", HttpService:JSONEncode(data)) end)
		return ok
	end
	function SaveManager:Load(name)
		if not (readfile and isfile) then return false end
		local path = self.folder .. "/" .. name .. ".json"
		local ok, data = pcall(function() return isfile(path) and HttpService:JSONDecode(readfile(path)) end)
		if not (ok and type(data) == "table") then return false end
		for k, v in pairs(data.toggles or {}) do
			local t = Toggles[k]
			if t and t.Value ~= v then pcall(function() t:SetValue(v) end) end
		end
		for k, v in pairs(data.options or {}) do
			local o = Options[k]
			if o and type(v) == "table" then
				pcall(function()
					if v[1] == "c" then o:SetValueRGB(Color3.fromHex(v[2]), v[3])
					elseif v[1] == "k" then o:SetValue({ v[2], v[3] })
					elseif v[1] == "m" then
						local set = {} for _, x in ipairs(v[2] or {}) do set[x] = true end
						o:SetValue(set)
					else o:SetValue(v[2]) end
				end)
			end
		end
		return true
	end
	function SaveManager:List()
		local out = {}
		if not listfiles then return out end
		pcall(function()
			for _, f in ipairs(listfiles(self.folder)) do
				local n = string.match(f, "([^/\\]+)%.json$")
				if n then out[#out + 1] = n end
			end
		end)
		table.sort(out)
		return out
	end
	function SaveManager:BuildConfigSection(tab)
		if type(tab) == "table" and rawget(tab, "_t") then tab = rawget(tab, "_t") end
		local g = tab:AddRightGroupbox("Configuration")
		local nameBox = g:AddInput("TempoCfgName", { Text = "Config name", Default = "", Placeholder = "name" })
		local list = g:AddDropdown("TempoCfgList", { Text = "Saved configs", Values = self:List(), AllowNull = true })
		g:AddButton("Save config", function()
			local n = nameBox.Value ~= "" and nameBox.Value or list.Value
			if not n or n == "" then Library:Notify("type a config name first", 3) return end
			if self:Save(n) then Library:Notify("saved " .. n, 2) list:SetValues(self:List()) end
		end)
		g:AddButton("Load config", function()
			local n = list.Value
			if n and self:Load(n) then Library:Notify("loaded " .. n, 2) end
		end)
		g:AddButton("Load this config on start", function()
			local n = list.Value
			if not (n and writefile) then return end
			pcall(function() writefile(self.folder .. "/autoload.txt", n) end)
			Library:Notify("autoload: " .. n, 2)
		end)
		self.ignore.TempoCfgName, self.ignore.TempoCfgList = true, true
		return g
	end
	function Library:_dropEmpty()
		if self._dropped then return end
		self._dropped = true
		for _, g in ipairs(groups) do
			if (g.n or 0) == 0 and g.sec then pcall(function() g.sec:Destroy() end) end
		end
	end
	function SaveManager:LoadAutoloadConfig()
		Library._flush()
		Library:_dropEmpty()
		if not (readfile and isfile) then return end
		local ok, n = pcall(function()
			local p = self.folder .. "/autoload.txt"
			return isfile(p) and readfile(p)
		end)
		if ok and type(n) == "string" and n ~= "" then
			if self:Load(n) then Library:Notify("loaded config " .. n, 2) end
		end
	end
	getgenv().SaveManager = SaveManager
	local ThemeManager = lenient({ Library = Library })
	function ThemeManager:SetLibrary() end
	function ThemeManager:SetFolder() end
	function Library._mountInterface()
		if Library._interface or not Library.ui then return end
		Library._interface = true
		pcall(function() Library.ui:mountInterface(Library.ui:Tab("Interface", "sliders")) end)
	end
	function ThemeManager:ApplyToTab(tab)
		Library._wantInterface = true
		if flushed then Library._mountInterface() end
	end
	ThemeManager.BuildInterfaceSection = ThemeManager.ApplyToTab
	getgenv().ThemeManager = ThemeManager
	local FluentOptions = setmetatable({}, { __index = function(_, k) return rawget(Options, k) or rawget(Toggles, k) or Options[k] end })
	local Fluent = loose({ Options = FluentOptions, Unloaded = false })
	Library:OnUnload(function() Fluent.Unloaded = true end)
	local FBox = {}
	local function fbox(gb)
		return setmetatable({ gb = gb }, { __index = function(_, k)
			local f = FBox[k]
			if f then return f end
			if isMethod(k) then return function() return Stub end end
		end })
	end
	function FBox:AddToggle(id, c) c = c or {} return self.gb:AddToggle(id, { Text = c.Title, Default = c.Default, Tooltip = c.Description, Callback = c.Callback }) end
	function FBox:AddSlider(id, c) c = c or {} return self.gb:AddSlider(id, { Text = c.Title, Default = c.Default, Min = c.Min, Max = c.Max, Rounding = c.Rounding, Callback = c.Callback }) end
	function FBox:AddDropdown(id, c) c = c or {} return self.gb:AddDropdown(id, { Text = c.Title, Values = c.Values, Multi = c.Multi, Default = c.Default, AllowNull = c.AllowNull, Callback = c.Callback }) end
	function FBox:AddInput(id, c) c = c or {} return self.gb:AddInput(id, { Text = c.Title, Default = c.Default, Placeholder = c.Placeholder, Numeric = c.Numeric, Callback = c.Callback }) end
	function FBox:AddButton(c) c = c or {} return self.gb:AddButton({ Text = c.Title, Func = c.Callback }) end
	function FBox:AddParagraph(c) c = c or {} return self.gb:AddLabel(tostring(c.Title or "")) end
	function FBox:AddKeybind(id, c) c = c or {} self.gb:AddLabel(c.Title or id):AddKeyPicker(id, { Default = c.Default, Mode = c.Mode, Text = c.Title, Callback = c.Callback, ChangedCallback = c.ChangedCallback }) return Options[id] end
	function FBox:AddColorpicker(id, c) c = c or {} self.gb:AddLabel(c.Title or id):AddColorPicker(id, { Default = c.Default, Title = c.Title, Callback = c.Callback }) return Options[id] end
	FBox.AddColorPicker = FBox.AddColorpicker
	for _, n in ipairs({ "Toggle", "Slider", "Dropdown", "Input", "Button", "Paragraph", "Keybind", "Colorpicker", "ColorPicker" }) do FBox["Create" .. n] = FBox["Add" .. n] end
	local function ftab(t)
		local o = { _t = t }
		function o:AddSection(title) return fbox(t:AddLeftGroupbox(tostring(type(title) == "table" and (title.Title or title.Name) or title or "Section"))) end
		o.CreateSection = o.AddSection
		return setmetatable(o, { __index = function(self, k)
			if FBox[k] then
				return function(me, ...)
					rawset(me, "_box", rawget(me, "_box") or fbox(t:AddLeftGroupbox(t.name)))
					return FBox[k](rawget(me, "_box"), ...)
				end
			end
			if type(k) == "string" and string.find(k, "^%u") then return function() return Stub end end
		end })
	end
	function Fluent:CreateWindow(opts)
		local w = Library:CreateWindow(opts)
		local W = {}
		function W:AddTab(info) return ftab(w:AddTab(type(info) == "table" and (info.Title or info.Name) or tostring(info))) end
		W.CreateTab = W.AddTab
		return loose(W)
	end
	function Fluent:Notify(c)
		c = type(c) == "table" and c or { Content = tostring(c) }
		Library:Notify({ Title = c.Title, Description = c.Content or c.SubContent, Time = c.Duration })
	end
	function Fluent:Destroy() Library:Unload() end
	getgenv().Fluent = Fluent
	local function pick(c, a, b) if c[a] ~= nil then return c[a] end return c[b] end
	local Flags = {}
	local function relem(o, kind)
		return setmetatable({}, { __index = function(_, k)
			if k == "CurrentValue" or k == "Value" or k == "value" then
				if kind == "dropdown" and type(o.Value) == "table" then local l = {} for v, on in pairs(o.Value) do if on then l[#l + 1] = v end end return l end
				return o.Value
			end
			if k == "CurrentOption" then
				if type(o.Value) == "table" then local l = {} for v, on in pairs(o.Value) do if on then l[#l + 1] = v end end return l end
				return { o.Value }
			end
			if k == "CurrentKeybind" then return o.Value end
			if k == "Set" or k == "SetValue" then
				return function(_, v)
					if kind == "dropdown" then
						if o.Multi then local s = {} for _, x in ipairs(type(v) == "table" and v or { v }) do s[x] = true end o:SetValue(s)
						else o:SetValue(type(v) == "table" and v[1] or v) end
					else o:SetValue(v) end
				end
			end
			if k == "Refresh" or k == "SetOptions" then return function(_, list) o:SetValues(list) end end
			if k == "OnChanged" then return function(_, fn) o:OnChanged(fn) end end
			if isMethod(k) then return function() return Stub end end
		end })
	end
	local function decimals(step) local s = tostring(step or 1) local d = s:match("%.(%d+)$") return d and #d or 0 end
	local RBox = {}
	local function rbox(gb, flavor)
		return setmetatable({ gb = gb, flavor = flavor }, { __index = function(_, k)
			local f = RBox[k]
			if f then return f end
			if isMethod(k) then return function() return Stub end end
		end })
	end
	local function idOf(c) return tostring(pick(c, "Flag", "flag") or pick(c, "Name", "name") or "Control") end
	local function reg(c, e) local f = pick(c, "Flag", "flag") if f then Flags[f] = e end return e end
	function RBox:CreateToggle(c)
		c = c or {}
		local cb = pick(c, "Callback", "callback")
		local o = self.gb:AddToggle(idOf(c), { Text = pick(c, "Name", "name"), Default = pick(c, "CurrentValue", "value"), Callback = cb })
		if cb and o.Value then task.defer(function() pcall(cb, o.Value) end) end
		return reg(c, relem(o, "toggle"))
	end
	function RBox:CreateSlider(c)
		c = c or {}
		local range = pick(c, "Range", "range") or { 0, 100 }
		local o = self.gb:AddSlider(idOf(c), { Text = pick(c, "Name", "name"), Min = range[1], Max = range[2],
			Default = pick(c, "CurrentValue", "value"), Rounding = decimals(pick(c, "Increment", "increment")),
			Suffix = pick(c, "Suffix", "suffix"), Callback = pick(c, "Callback", "callback") })
		return reg(c, relem(o, "slider"))
	end
	function RBox:CreateDropdown(c)
		c = c or {}
		local multi = pick(c, "MultipleOptions", "multiSelect") or c.Multi
		local cur = pick(c, "CurrentOption", "value")
		local def = multi and (type(cur) == "table" and cur or { cur }) or (type(cur) == "table" and cur[1] or cur)
		local cb = pick(c, "Callback", "callback")
		local flavor = self.flavor
		local o = self.gb:AddDropdown(idOf(c), { Text = pick(c, "Name", "name"), Values = pick(c, "Options", "options") or {},
			Multi = multi, Default = def, AllowNull = true,
			Callback = cb and function(v)
				local list = v
				if type(v) == "table" then list = {} for x, on in pairs(v) do if on then list[#list + 1] = x end end end
				if flavor == "rayfield" then cb(type(list) == "table" and list or { list }) else cb(list) end
			end })
		return reg(c, relem(o, "dropdown"))
	end
	function RBox:CreateInput(c)
		c = c or {}
		local o = self.gb:AddInput(idOf(c), { Text = pick(c, "Name", "name"), Default = pick(c, "CurrentValue", "value"),
			Placeholder = pick(c, "PlaceholderText", "placeholder"), Callback = pick(c, "Callback", "callback") })
		return reg(c, relem(o, "input"))
	end
	function RBox:CreateButton(c) c = c or {} self.gb:AddButton({ Text = pick(c, "Name", "name"), Func = pick(c, "Callback", "callback") }) return Stub end
	function RBox:CreateKeybind(c)
		c = c or {}
		local cb = pick(c, "Callback", "callback")
		local hold = pick(c, "HoldToInteract", "hold")
		local id = idOf(c)
		self.gb:AddLabel(pick(c, "Name", "name") or id):AddKeyPicker(id, { Default = pick(c, "CurrentKeybind", "value") or "None",
			Mode = hold and "Hold" or "Toggle", Text = pick(c, "Name", "name"), Callback = cb,
			ChangedCallback = pick(c, "OnChanged", "changed") })
		return reg(c, relem(Options[id], "keybind"))
	end
	function RBox:CreateColorPicker(c)
		c = c or {}
		local id = idOf(c)
		self.gb:AddLabel(pick(c, "Name", "name") or id):AddColorPicker(id, { Default = pick(c, "Color", "value"), Title = pick(c, "Name", "name"), Callback = pick(c, "Callback", "callback") })
		return reg(c, relem(Options[id], "color"))
	end
	function RBox:CreateLabel() return Stub end
	function RBox:CreateParagraph() return Stub end
	RBox.AddToggle, RBox.AddSlider, RBox.AddDropdown, RBox.AddButton = RBox.CreateToggle, RBox.CreateSlider, RBox.CreateDropdown, RBox.CreateButton
	local function rtab(t, flavor)
		local o = { _t = t }
		function o:CreateSection(name)
			if type(name) == "table" then name = pick(name, "Name", "name") end
			rawset(self, "_box", rbox(t:AddLeftGroupbox(tostring(name or t.name)), flavor))
			return Stub
		end
		function o:AddLeftGroupbox(info) return rbox(t:AddLeftGroupbox(type(info) == "table" and pick(info, "Name", "name") or tostring(info)), flavor) end
		o.AddRightGroupbox = o.AddLeftGroupbox
		function o:CreateConfigManager() SaveManager:BuildConfigSection(t) return Stub end
		function o:CreateThemeManager() ThemeManager:ApplyToTab(t) return Stub end
		return setmetatable(o, { __index = function(self, k)
			if RBox[k] then
				return function(me, ...)
					rawset(me, "_box", rawget(me, "_box") or rbox(t:AddLeftGroupbox(t.name), flavor))
					return RBox[k](rawget(me, "_box"), ...)
				end
			end
			if isMethod(k) then return function() return Stub end end
		end })
	end
	local function rayLib(flavor)
		local R = loose({ Flags = Flags, Unloaded = false })
		Library:OnUnload(function() R.Unloaded = true end)
		function R:CreateWindow(opts)
			local w = Library:CreateWindow(opts)
			local W = loose({})
			function W:CreateTab(name)
				if type(name) == "table" then name = pick(name, "Name", "name") or name.Title end
				return rtab(w:AddTab(tostring(name or "Tab")), flavor)
			end
			W.AddTab = W.CreateTab
			function W:Notify(c) R:Notify(c) end
			function W:LoadAutoload() SaveManager:LoadAutoloadConfig() end
			R.Window = W
			return W
		end
		function R:Notify(c)
			c = type(c) == "table" and c or { Content = tostring(c) }
			Library:Notify({ Title = pick(c, "Title", "title"), Description = pick(c, "Content", "content"), Time = pick(c, "Duration", "duration") })
		end
		function R:LoadConfiguration() SaveManager:LoadAutoloadConfig() end
		R.LoadAutoload = R.LoadConfiguration
		function R:Destroy() Library:Unload() end
		R.Unload = R.Destroy
		return R
	end
	getgenv().Rayfield = rayLib("rayfield")
	getgenv().RayfieldGen2 = rayLib("gen2")
	getgenv().OuroFlow = rayLib("ouroflow")
	task.spawn(function()
		for _ = 1, 600 do
			local kp = rawget(Options, "MenuKeybind")
			if kp and Library.ui then
				local function apply()
					local n = kp.Value
					if n and n ~= "None" and not string.find(n, "^MB") then pcall(function() Library.ui:SetToggleKey(n) end) end
				end
				apply()
				kp:OnChanged(apply)
				return
			end
			task.wait(0.1)
		end
	end)
end
return (function(...)
local gJ
local gn
local VirtualUser
local gq
local gt
local gP
local gw
local UserInputService
local gz
local gV
local gC
local gY
local g0
local gm
local gI
local Options
local gp
local gs
local gO
local CurrentCamera
local gv
local gy
local gU
local gB
local gX
local g_
local gE
local gl
local g2
local gH
local connection
local HttpService
local gr
local connection2
local gu
local gQ
local gx
local gT
local gA
local gW
local gD
local gZ
local LocalPlayer
local g1
local function onCopyUSDTAddress()
    gI(g1, "Copied USDT address")
end
local function onInputBegan()
    g0 = tick()
end
local function onCopyEthereumAddress()
    gI(gl, "Copied Ethereum address")
end
local function fn111()
    gm(gQ.AntiGameplayPause.Value)
end
local function onCopyPayPalLink()
    gI(gU, "Copied PayPal link")
end
local function fn156(c2, c3)
    local jD_1 = (c2 == "Toggle" and gQ or Options)[c3]
    local jC_2 = type(jD_1) == "table" and jD_1.Type == c2
    return jC_2 and jD_1 or nil
end
local function fn169()
    local Character = LocalPlayer.Character
    local iD = Character and Character:FindFirstChild("HumanoidRootPart")
    return iD
end
local function fn172()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    gZ = tick()
end
local function fn173()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local ic = leaderstats and leaderstats:FindFirstChild("Cash")
    local ib_1 = ic
    if ic then
        ic = ib_1.Value
    end
    return ic or 0
end
local function onCopyVenmoLink()
    gI(gP, "Copied Venmo link")
end
local function onUnload()
    g2:Unload()
end
local function fn216()
    LocalPlayer:SetAttribute("GoldenMarker", gQ.AutoStamp.Value == true)
    LocalPlayer:SetAttribute("AutoBingo", gQ.AutoBingo.Value == true)
end
local function fn218(ba, bb)
    local h8 = LocalPlayer:GetAttribute(ba) or ""
    return ("," .. h8 .. ","):find("," .. bb .. ",", 1, true) ~= nil
end
local function onStepped()
    if g2.Unloaded then
        return
    end
    if gQ.NoClip and gQ.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local iI_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if iI_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function onImportConfigFromClipboardTex()
    local kl_1
    local kj = Options.SaveManager_ImportSource.Value or ""
    local kj_1
    local kk = tostring(kj):match("^%s*(.-)%s*$")
    if kk == "" then
        g2:Notify("Paste an exported config into the box first")
        return
    end
    kj_1, kl_1 = pcall(HttpService.JSONDecode, HttpService, kk)
    local kk_1 = not kj_1 or type(kl_1) ~= "table"
    local kp = if kk_1 then 1 else 0
    local kn = 164 * kp + 2137 * (1 - kp)
    local ko = 2510 * kp + 3927 * (1 - kp)
    if not ((kn * 2498 + ko * 2996 + kn * ko) % 16777213 == 8341272) then
        kk_1 = type(kl_1.objects) ~= "table"
    end
    if kk_1 then
        g2:Notify("That is not a valid exported config")
        return
    end
    local kj_2 = 0
    for i, v in ipairs(kl_1.objects) do
        if gC(v) then
            kj_2 += 1
        end
    end
    if kj_2 == 0 then
        g2:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local kl_2 = kj_2 == 1 and "" or "s"
    g2:Notify(("Imported %d setting%s"):format(kj_2, kl_2), 6)
end
local function onInputChanged(cJ)
    local UserInputType = cJ.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        g0 = tick()
    end
end
local function fn289()
    local Character = LocalPlayer.Character
    local iA = Character and Character:FindFirstChildOfClass("Humanoid")
    return iA
end
local function autoStampLoop()
    while true do
        task.wait(1)
        if g2.Unloaded then
            break
        end
        if gQ.AutoStamp.Value or gQ.AutoBingo.Value then
            gW()
        end
    end
end
local function onCopyLitecoinAddress()
    gI(gu, "Copied Litecoin address")
end
local function onJumpRequest()
    if g2.Unloaded then
        return
    end
    if gQ.InfJump and gQ.InfJump.Value then
        local iT_1 = gB()
        if iT_1 then
            iT_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn325()
    gI(gv, "Copied Discord invite to clipboard")
end
local function onRenderStepped(b_)
    if g2.Unloaded then
        return
    end
    if gQ.WalkSpeedEnabled and gQ.WalkSpeedEnabled.Value then
        local iV_1 = gB()
        if iV_1 then
            iV_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if gQ.Fly and gQ.Fly.Value then
        local iV_3 = gn()
        local iW = gB()
        if iV_3 and iW then
            iW.PlatformStand = true
            local iW_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                iW_1 = iW_1 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                iW_1 = iW_1 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                iW_1 = iW_1 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                iW_1 = iW_1 + CurrentCamera.CFrame.RightVector
            end
            local i3 = if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
            if i3 == 1 then
                iW_1 = iW_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                iW_1 = iW_1 - Vector3.new(0, 1, 0)
            end
            iV_3.Velocity = Vector3.zero
            if iW_1.Magnitude > 0 then
                iV_3.CFrame = iV_3.CFrame + iW_1.Unit * Options.FlySpeed.Value * b_
            end
        end
    end
end
local function worker()
    local h0_1
    while true do
        task.wait(1)
        if g2.Unloaded then
            break
        end
        local h_ = math.floor(os.clock() - gy)
        if h_ < 60 then
            h0_1 = h_ .. "s"
        elseif h_ < 3600 then
            h0_1 = string.format("%dm %ds", math.floor((h_) / (60)), h_ % 60)
        else
            h0_1 = string.format("%dh %dm", math.floor((h_) / (3600)), math.floor((h_ % 3600) / (60)))
        end
        gY:SetText(gs("Session time", h0_1, gJ))
    end
end
local function onCopySolanaAddress()
    gI(g_, "Copied Solana address")
end
local function fn457(da, db)
    local Type = db.Type
    if Type == "Toggle" then
        return { idx = da, type = "Toggle", value = db.Value == true }
    elseif Type == "Slider" then
        return { idx = da, type = "Slider", value = tostring(db.Value) }
    elseif Type == "Dropdown" then
        return { idx = da, type = "Dropdown", multi = db.Multi == true, value = db.Value }
    elseif Type == "Input" then
        local jK = db.Value
        local jO = if jK then 1 else 0
        local jM = 800 * jO + 3735 * (1 - jO)
        local jN = 1514 * jO + 1027 * (1 - jO)
        if not ((jM * 3394 + jN * 241 + jM * jN) % 16777213 == 4291274) then
            jK = ""
        end
        return { idx = da, type = "Input", text = tostring(jK) }
    elseif Type == "ColorPicker" then
        return { idx = da, type = "ColorPicker", value = db.Value:ToHex(), transparency = db.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = da,
            type = "KeyPicker",
            mode = db.Mode,
            key = db.Value,
            modifiers = db.Modifiers,
            toggled = db.Toggled
        }
    else
        return nil
    end
end
local function fn471()
    local hR_1
    local hQ_1
    if identifyexecutor then
        hR_1, hQ_1 = identifyexecutor()
        local hS = hR_1 ~= ""
        local hT = type(hR_1) == "string" and hS
        if hT then
            local hS_1 = type(hQ_1) == "string" and hQ_1 ~= "" and hR_1 .. " " .. hQ_1
            gD = hS_1 or hR_1
        end
    end
end
local function fn495()
    if not gQ.WalkSpeedEnabled.Value then
        local i9 = gB()
        if i9 then
            i9.WalkSpeed = 16
        end
    end
end
local function fn511()
    local jQ = {}
    for i, v in ipairs({ gQ, Options }) do
        for k, v in pairs(v) do
            local jR = type(v) == "table" and type(v.Type) == "string" and not gV.Ignore[k]
            if jR then
                local jR_1 = gX(k, v)
                if jR_1 then
                    jQ[#jQ + 1] = jR_1
                end
            end
        end
    end
    table.sort(jQ, function(dn, dp)
        if dn.type ~= dp.type then
            return dn.type < dp.type
        end
        return dn.idx < dp.idx
    end)
    return { objects = jQ }
end
local function onCopyBitcoinAddress()
    gI(gq, "Copied Bitcoin address")
end
local function fn535(N, O, P)
    return string.format("<b>%s</b> %s %s", N, gA("-", "#5a6070"), gA(O, P))
end
local function worker2()
    while true do
        task.wait(3)
        if g2.Unloaded then
            break
        end
        for i, v in ipairs(gt) do
            local iq = gQ["AutoBuy_" .. v.key]
            if iq and iq.Value then
                gw(v)
            end
        end
    end
end
local function antiGameplayPauseLoop()
    while not g2.Unloaded do
        task.wait(1)
        if gQ.AntiGameplayPause.Value then
            gm(true)
        end
    end
end
local function onRscripts()
    if setclipboard then
        setclipboard(gr)
    elseif toclipboard then
        toclipboard(gr)
    end
    g2:Notify("Copied Rscripts profile to clipboard")
end
local function antiAfkLoop()
    while not g2.Unloaded do
        task.wait(2)
        if gQ.AntiAfk.Value then
            local jv = tick() - g0
            local jw = tick() - gZ
            if jv >= 300 and jw >= 60 then
                pcall(gE)
            else
                if jv < 300 and jw >= 300 then
                    pcall(gE)
                end
            end
        end
    end
end
local function fn593()
    connection:Disconnect()
    connection2:Disconnect()
    gm(false)
    LocalPlayer:SetAttribute("GoldenMarker", false)
    LocalPlayer:SetAttribute("AutoBingo", false)
    select("#", "Unloaded!")
end
local function onCopyJoinScript_JobID()
    local hY = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, gT)
    if setclipboard then
        setclipboard(hY)
    elseif toclipboard then
        toclipboard(hY)
    end
    g2:Notify("Copied join script to clipboard")
end
local function fn616()
    if not gQ.Fly.Value then
        local i4 = gB()
        if i4 then
            i4.PlatformStand = false
        end
    end
end
local function fn635(bl)
    for i, v in ipairs(bl.catalog) do
        local ig = v.cost or 0
        local ih = ig > 0 and not v.plusOnly and not v.codeOnly and not v.reward and not v.bundleOnly and not gp(bl.owned, v.id) and gO() >= v.cost
        if ih then
            gz.BuySkin:FireServer(bl.key, v.id)
            task.wait(0.4)
        end
    end
end
local function onExportConfigToClipboard()
    local kd_1
    local kc_1
    kc_1, kd_1 = pcall(HttpService.JSONEncode, HttpService, gH())
    if not kc_1 then
        g2:Notify("Failed to encode the config")
        return
    end
    local kc_2 = setclipboard or toclipboard
    local kc_3 = type(kc_2) ~= "function" or not pcall(kc_2, kd_1)
    if kc_3 then
        g2:Notify("Your executor does not support copying to the clipboard")
        return
    end
    g2:Notify("Config copied to clipboard", 6)
end
local function fn671(C)
    local DiscordGroup = C:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = gx })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = gx })
end
local function fn694(v, w)
    if setclipboard then
        setclipboard(v)
    elseif toclipboard then
        toclipboard(v)
    end
    g2:Notify(w)
end
local function fn710(K, L)
    return string.format('<font color="%s">%s</font>', L, K)
end
gl = nil
gm = nil
gn = nil
connection = nil
gp = nil
gq = nil
gr = nil
gs = nil
gt = nil
gu = nil
gv = nil
gw = nil
gx = nil
gy = nil
gz = nil
gA = nil
gB = nil
gC = nil
gD = nil
gE = nil
LocalPlayer = nil
gH = nil
gI = nil
gJ = nil
HttpService = nil
Options = nil
VirtualUser = nil
connection2 = nil
gO = nil
gP = nil
gQ = nil
CurrentCamera = nil
UserInputService = nil
gT = nil
gU = nil
gV = nil
gW = nil
gX = nil
gY = nil
gZ = nil
g_ = nil
g0 = nil
g1 = nil
g2 = nil
local gF
local g5_1
local g6_1, g6_3, g6_4
local g4_1
local Players, MenuGroup
local hf_1
local he_1
local hd_1
local hb_1
local ha_1, ha_2
local g9_1
Players, UserInputService, VirtualUser, HttpService, LocalPlayer, ha_1, gz, g9_1, gv, gr, g4_1, g2, hd_1, gV, gQ, Options, g6_1, hb_1, gI, gx = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if (g6_1 or g6_1 or (not hb_1 or hb_1) or (false and not g6_1 or (VirtualUser or g9_1))) and (hb_1 and VirtualUser or (g9_1 or VirtualUser) or not g4_1 and g4_1 and (g4_1 and VirtualUser)) and not ((g6_1 or g6_1 or (not hb_1 or hb_1) or (false and not g6_1 or (VirtualUser or g9_1))) and (hb_1 and VirtualUser or (g9_1 or VirtualUser) or not g4_1 and g4_1 and (g4_1 and VirtualUser))) then
    gQ = game:GetService("Players")
else
    Players = game:GetService("Players")
end
local g7 = game:GetService("ReplicatedStorage")
local g7_1
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
if ((hd_1 or not g4_1) and (hd_1 and ha_1) and (false and not g4_1 or not ha_1 and not HttpService) or ((not hd_1 or ha_1) and (g4_1 and g7) or (not hd_1 or false or (not g7 or not hd_1)))) and ((g4_1 or ha_1) and (not ha_1 or gv) and (g4_1 or HttpService or g7 and gv) or (not hd_1 and hd_1 or (not hd_1 or not g7) or (not g4_1 or not ha_1) and (gv and not g4_1))) or not (((hd_1 or not g4_1) and (hd_1 and ha_1) and (false and not g4_1 or not ha_1 and not HttpService) or ((not hd_1 or ha_1) and (g4_1 and g7) or (not hd_1 or false or (not g7 or not hd_1)))) and ((g4_1 or ha_1) and (not ha_1 or gv) and (g4_1 or HttpService or g7 and gv) or (not hd_1 and hd_1 or (not hd_1 or not g7) or (not g4_1 or not ha_1) and (gv and not g4_1)))) then
    HttpService = game:GetService("HttpService")
    LocalPlayer = Players.LocalPlayer
    ha_2 = require(g7.BingoShared.Config)
    gz = g7:WaitForChild("BingoRemotes")
else
    gz = game:GetService("HttpService")
    ha_2 = HttpService.LocalPlayer
    g7 = require(LocalPlayer.BingoShared.Config)
    LocalPlayer:WaitForChild("BingoRemotes")
end
local g9_2 = "50 Player BINGO!"
gv = "https://discord.gg/K7Qxnxkk46"
gr = "https://discord.gg/K7Qxnxkk46"
if (g7 and g7 or (ha_2 or not RunService)) and (RunService or not g7 and not RunService) and ((not gQ or false) and (not RunService and g7) or (not RunService)) and not ((g7 and g7 or (ha_2 or not RunService)) and (RunService or not g7 and not RunService) and ((not gQ or false) and (not RunService and g7) or (not RunService))) then
    gr = ""
else
    g4_1 = ""
end
g2 = getgenv().Library
local hd_2 = getgenv().ThemeManager
gV = getgenv().SaveManager
gQ = g2.Toggles
Options = g2.Options
gI = fn694
gx = fn325
local Window = g2:CreateWindow({
    Title = "Tempo",
    Footer = { { Text = gv, Copyable = true }, "|", g9_2 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
local hb_2 = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gavel"),
    Shop = Window:AddTab("Shop", "shopping-cart"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in hb_2 do
    fn671(v)
end
he_1, g7_1, gJ, g6_3, gD, hf_1, gY, gT, g5_1, gA, gs = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local g4_2 = 2
repeat
    local g8_1 = (g4_2 * 1 + 7) % 8 + 1
    if g8_1 <= 4 then
        if g8_1 <= 2 then
            if g8_1 <= 1 then
                if g4_2 * 26783653 + 8 + 2 >= g4_2 * 26783653 + 8 + 2 + 1 then
                    gT = #g5_1 > 18
                else
                    g5_1 = #gT > 18
                end
                g4_2 = (g4_2 + 17) % 32
            else
                local hg_1 = {
                    "svtc",
                    "lthx",
                    "ovhvmb",
                    "fwcsmawj",
                    "eudiyjfq",
                    "wdbvxvoriuhe",
                    "bxltitcl",
                    "cfczxcp",
                    "jzas",
                    "nveovkeg",
                    "vbkjmnxw",
                    "ucsfrblw",
                    "onuwnu",
                    "fcnfzfrll",
                    "jhtaoamquoee",
                    "qecef"
                }
                if hg_1[(g4_2 * 42 + 94) % 16 + 1] <= hg_1[(g4_2 * 42 + 94) % 16 + 1] then
                    gA = fn710
                end
                g4_2 = (g4_2 + 17) % 32
            end
        elseif g8_1 <= 3 then
            local k9 = bit32.rrotate(bit32.bxor(bit32.lrotate(g4_2, 18), string.byte(tostring(g6_3))), 21)
            if bit32.bxor(bit32.lrotate(bit32.bxor(k9, 1016162902), 22), 2509186138) ~= bit32.lrotate(k9, 22) then
                g7_1 = fn535
            else
                gs = fn535
            end
            g4_2 = (g4_2 + 1) % 32
        else
            if g4_2 * 86909421 + 10 + 4 <= g4_2 * 86909421 + 10 + 4 + 6 then
                he_1 = "#7fd47f"
            else
                g6_3 = "#7fd47f"
            end
            g4_2 = (g4_2 + 9) % 32
        end
    elseif g8_1 <= 6 then
        if g8_1 <= 5 then
            local hg_2 = (vector.create((g4_2 * 2 + 4) % 11 + 1, (g4_2 * 5 + 12) % 13 + 1, (g4_2 * 12 + 4) % 17 + 1))
            local hh_1 = (vector.create((g4_2 * 2 + 9) % 11 + 1, (g4_2 * 8 + 1) % 13 + 1, (g4_2 * 13 + 11) % 17 + 1))
            local hi_1 = (vector.create((g4_2 * 7 + 6) % 11 + 1, (g4_2 * 7 + 7) % 13 + 1, (g4_2 * 12 + 4) % 17 + 1))
            local hj_1 = (vector.create((g4_2 * 4 + 9) % 11 + 1, (g4_2 * 11 + 7) % 13 + 1, (g4_2 * 5 + 2) % 17 + 1))
            if vector.dot(vector.cross(hg_2, hh_1), (vector.cross(hi_1, hj_1))) == vector.dot(hg_2, hi_1) * vector.dot(hh_1, hj_1) - vector.dot(hg_2, hj_1) * vector.dot(hh_1, hi_1) + 2 then
                gA = "#6ec1ff"
            else
                g7_1 = "#6ec1ff"
            end
            g4_2 = (g4_2 + 25) % 32
        else
            local hg_3 = {
                "habwmsrqqfar",
                "xwgjbrvlutoz",
                "wiupapea",
                "myprxyhy",
                "popvacy",
                "msmjnykdxakg",
                "zgdoodsewvr",
                "zfxghai",
                "wucj",
                "llxboeroknx",
                "gjo"
            }
            if hg_3[(g4_2 * 91 + 13) % 11 + 1] <= hg_3[(g4_2 * 91 + 13) % 11 + 1] then
                gJ = "#e8a34d"
            else
                gs = "#e8a34d"
            end
            g4_2 = (g4_2 + 1) % 32
        end
    elseif g8_1 <= 7 then
        local g8_2 = {
            "wynnllf",
            "phr",
            "ick",
            "kqdew",
            "swdtxytx",
            "bpxkyu",
            "logvw",
            "jroecla",
            "zdhabfldai",
            "uyhhrs"
        }
        local kX = g4_2
        local hg_4 = g8_2[kX % 10 + 1]
        if hg_4:len() <= hg_4:reverse():rep(kX % 3 + 2):len() then
            g6_3 = "#8b93a3"
            gD = "Unknown"
            pcall(fn471)
            local AccountGroup = hb_2.Info:AddLeftGroupbox("Account", "circle-user")
            AccountGroup:AddLabel(gs("User", LocalPlayer.Name, he_1), true)
            AccountGroup:AddLabel(gs("Status", "Keyless", he_1), true)
            AccountGroup:AddLabel(gs("Executor", gD, he_1), true)
            hf_1 = hb_2.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            hf_1:AddLabel(gA(g9_2 .. " [" .. tostring(game.PlaceId) .. "]", g7_1), true)
            hf_1:AddLabel(gs("Place ID", tostring(game.PlaceId), g7_1), true)
            gY = hf_1:AddLabel(gs("Session time", "0s", gJ), true)
        else
            g7_1 = "Unknown"
            pcall(fn471)
            gA = gD.Info:AddLeftGroupbox("Account", "circle-user")
            gA:AddLabel(LocalPlayer("User", g6_3.Name, gJ), true)
            gA:AddLabel(LocalPlayer("Status", "Keyless", gJ), true)
            gA:AddLabel(LocalPlayer("Executor", "Unknown", gJ), true)
            gY = gD.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            gY:AddLabel(he_1(hb_2 .. " [" .. tostring(game.PlaceId) .. "]", g9_2), true)
            gY:AddLabel(LocalPlayer("Place ID", tostring(game.PlaceId), g9_2), true)
            hf_1 = gY:AddLabel(LocalPlayer("Session time", "0s", gs), true)
        end
        g4_2 = (g4_2 + 25) % 32
    else
        if g4_2 * 90043063 + 5 + 2 >= g4_2 * 90043063 + 5 + 2 + 5 then
            gA = tostring(game.JobId)
        else
            gT = tostring(game.JobId)
        end
        g4_2 = (g4_2 + 9) % 32
    end
until (g4_2 * 1 + 21) % 32 == 31
if g5_1 then
    local g3_3 = 0
    repeat
        local g4_3 = (vector.create((g3_3 * 3 + 1) % 11 + 1, (g3_3 * 5 + 8) % 13 + 1, (g3_3 * 6 + 5) % 17 + 1))
        local g8_3 = (vector.create((g3_3 * 2 + 2) % 11 + 1, (g3_3 * 10 + 13) % 13 + 1, (g3_3 * 3 + 11) % 17 + 1))
        local hg_5 = (vector.create((g3_3 * 2 + 7) % 11 + 1, (g3_3 * 6 + 6) % 13 + 1, (g3_3 * 1 + 14) % 17 + 1))
        local hh_2 = (vector.create((g3_3 * 1 + 5) % 5 + 1, (g3_3 * 4 + 2) % 7 + 1, (g3_3 * 4 + 1) % 9 + 1))
        if vector.dot(vector.cross(g4_3, (vector.cross(g8_3, hg_5))), hh_2) == vector.dot(g8_3 * vector.dot(g4_3, hg_5) - hg_5 * vector.dot(g4_3, g8_3), hh_2) then
            g5_1 = string.sub(gT, 1, 18) .. "..."
        else
            gT = string.sub(g5_1, 1, 18) .. "..."
        end
        g3_3 = (g3_3 + 0) % 4
    until (g3_3 * 3 + 2) % 4 == 2
end
local g3_4 = g5_1 or gT
gy, gu, gq, gl, g1, g_, gU, gP, gt, gW, gp, gO, gw = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
hf_1:AddLabel(gs("Server", g3_4, g6_3), true)
hf_1:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
gy = os.clock()
task.spawn(worker)
local ScriptsGroup = hb_2.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(gA("Included in this hub", g6_3), true)
ScriptsGroup:AddLabel(gA(g9_2, g7_1), true)
local FeaturesGroup = hb_2.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(gA("Auto Stamp", g7_1), true)
FeaturesGroup:AddLabel(gA("Auto Bingo", he_1), true)
FeaturesGroup:AddLabel(gA("Auto Buy Cosmetics", gJ), true)
FeaturesGroup:AddLabel(gA("Player Movement", g6_3), true)
local SocialsGroup = hb_2.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = gx })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = hb_2.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = gx })
gu = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
gq = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
gl = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
g1 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
g_ = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
gU = ""
gP = ""
local hq = "#345d9d"
local hm = "#f7931a"
local hk = "#627eea"
local hj_2 = "#26a17b"
local hi_2 = "#14f195"
local hg_6 = "#0070ba"
local g8_4 = "#008cff"
local DonationsGroup = hb_2.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(gA("All donations are optional but appreciated.", gJ), true)
DonationsGroup:AddLabel(gA("If you donate you get a special role, just PING after you donate.", he_1), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(gA("LTC / Litecoin", hq), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(gA("BTC / Bitcoin", hm), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(gA("ETH / Ethereum", hk), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(gA("USDT", hj_2), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(gA("Solana", hi_2), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(gA("PayPal", hg_6), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(gA("Venmo", g8_4), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(gA("Don't have any of the listed currencies but still wanna donate?", g6_3), true)
DonationsGroup:AddLabel(gA("DM me and we'll work something out.", g7_1), true)
local FaqGroup = hb_2.Info:AddRightGroupbox("FAQ", "circle-help")
FaqGroup:AddLabel("Where do I get a good config?", true)
FaqGroup:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
FaqGroup:AddLabel("How do I import / export configs?", true)
FaqGroup:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
FaqGroup:AddLabel("How do I report bugs?", true)
FaqGroup:AddLabel("Join the Discord and post it in the bugs channel.", true)
FaqGroup:AddLabel("How do I make suggestions?", true)
FaqGroup:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
FaqGroup:AddLabel("How do I get help or updates?", true)
FaqGroup:AddLabel("Join the Discord, updates and support are posted there first.", true)
gW = fn216
local AutomationGroup = hb_2.Main:AddLeftGroupbox("Automation", "gavel")
AutomationGroup:AddToggle("AutoStamp", { Text = "Auto Stamp", Default = false, Callback = gW })
AutomationGroup:AddToggle("AutoBingo", { Text = "Auto Bingo", Default = false, Callback = gW })
task.spawn(autoStampLoop)
gt = {
    { key = "card", label = "Card Skins", owned = "OwnedCardSkins", catalog = ha_2.CARD_SKINS },
    { key = "chair", label = "Chairs", owned = "OwnedChairSkins", catalog = ha_2.CHAIR_SKINS },
    { key = "dance", label = "Dances", owned = "OwnedDances", catalog = ha_2.DANCES },
    { key = "stamp", label = "Stamps", owned = "OwnedStamps", catalog = ha_2.STAMPS }
}
gp = fn218
gO = fn173
gw = fn635
local AutoBuyGroup = hb_2.Shop:AddLeftGroupbox("Auto Buy", "shopping-cart")
for i, v in ipairs(gt) do
    AutoBuyGroup:AddToggle("AutoBuy_" .. v.key, { Text = "Auto Buy " .. v.label, Default = false })
end
CurrentCamera, MenuGroup, g0, gZ, connection, connection2, g6_4, gB, gn, gm, gE, gF, gX, gH, gC = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
task.spawn(worker2)
local MovementGroup = hb_2.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = hb_2.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
gB = fn289
gn = fn169
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
gQ.Fly:OnChanged(fn616)
gQ.WalkSpeedEnabled:OnChanged(fn495)
gm = function(ck)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not ck)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not ck
        end
    end)
    if not ck then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(LocalPlayer, "GameplayPaused", false)
        else
            LocalPlayer.GameplayPaused = false
        end
    end)
end
if ((MenuGroup or MenuGroup) and (not MenuGroup or not MenuGroup) and ((not g6_4 or false) and (not gH or MenuGroup)) or (gC and not MenuGroup or (not connection2 or false) or (gH and false or (not connection2 or not gH)))) and (not connection2 and gC and (g6_4 and not MenuGroup) and ((MenuGroup or not MenuGroup) and (gH or not MenuGroup)) or connection2 and gH and (MenuGroup or MenuGroup) and (false or not connection2 or (not MenuGroup or false))) and not (((MenuGroup or MenuGroup) and (not MenuGroup or not MenuGroup) and ((not g6_4 or false) and (not gH or MenuGroup)) or (gC and not MenuGroup or (not connection2 or false) or (gH and false or (not connection2 or not gH)))) and (not connection2 and gC and (g6_4 and not MenuGroup) and ((MenuGroup or not MenuGroup) and (gH or not MenuGroup)) or connection2 and gH and (MenuGroup or MenuGroup) and (false or not connection2 or (not MenuGroup or false)))) then
    hb_2.AntiGameplayPause:OnChanged(fn111)
    task.spawn(antiGameplayPauseLoop)
    gQ = Options.Settings:AddLeftGroupbox("Menu", "settings")
    gQ:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    gQ:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { NoUI = true, Default = "RightShift", Text = "Menu keybind" })
    gZ.ToggleKeybind = MenuGroup.MenuKeybind
    gQ:AddButton("Unload", onUnload)
    g2 = tick()
    g0 = tick()
else
    gQ.AntiGameplayPause:OnChanged(fn111)
    task.spawn(antiGameplayPauseLoop)
    MenuGroup = hb_2.Settings:AddLeftGroupbox("Menu", "settings")
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    g2.ToggleKeybind = Options.MenuKeybind
    MenuGroup:AddButton("Unload", onUnload)
    g0 = tick()
    gZ = tick()
end
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local jp = v
        pcall(function()
            jp:Disable()
        end)
    end
end)
gE = fn172
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
if (not MenuGroup or not gF or (MenuGroup or gZ)) and (gZ or MenuGroup or (gZ or not MenuGroup)) and (gF and gF or MenuGroup and not gZ or (not gZ or gF or not gF and not MenuGroup)) or not ((not MenuGroup or not gF or (MenuGroup or gZ)) and (gZ or MenuGroup or (gZ or not MenuGroup)) and (gF and gF or MenuGroup and not gZ or (not gZ or gF or not gF and not MenuGroup))) then
    task.spawn(antiAfkLoop)
    g2:OnUnload(fn593)
    hd_2:SetLibrary(g2)
    hd_2:SetFolder("TempoHub")
    hd_2:SaveDefault("Linoria")
    hd_2:ApplyToTab(hb_2.Settings)
    hd_2:LoadDefault()
    gV:SetLibrary(g2)
    gV:IgnoreThemeSettings()
    gV:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    gV:SetFolder("TempoHub/50PlayerBingo")
    g6_4 = gV:BuildConfigSection(hb_2.Settings)
else
    task.spawn(antiAfkLoop)
    hd_2:OnUnload(fn593)
    hb_2:SetLibrary(hd_2)
    hb_2:SetFolder("TempoHub")
    hb_2:SaveDefault("Linoria")
    hb_2:ApplyToTab(g6_4.Settings)
    hb_2:LoadDefault()
    g2:SetLibrary(hd_2)
    g2:IgnoreThemeSettings()
    g2:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    g2:SetFolder("TempoHub/50PlayerBingo")
    gV = g2:BuildConfigSection(g6_4.Settings)
end
gF = fn156
gX = fn457
gH = fn511
gC = function(dr)
    local j9
    j9 = nil
    local ka = type(dr) ~= "table" or type(dr.idx) ~= "string" or type(dr.type) ~= "string" or gV.Ignore[dr.idx]
    if ka then
        return false
    end
    j9 = gF(dr.type, dr.idx)
    if not j9 then
        return false
    end
    local ka_1 = pcall(function()
        if dr.type == "Input" then
            if type(dr.text) ~= "string" then
                return
            end
            j9:SetValue(dr.text)
        elseif dr.type == "ColorPicker" then
            j9:SetValueRGB(Color3.fromHex(dr.value), dr.transparency)
        elseif dr.type == "KeyPicker" then
            j9:SetValue({ dr.key, dr.mode, dr.modifiers })
            if dr.mode == "Toggle" and dr.toggled ~= nil then
                j9.Toggled = dr.toggled
                j9:Update()
            end
        else
            j9:SetValue(dr.value)
        end
    end)
    return ka_1
end
g6_4:AddDivider()
g6_4:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
g6_4:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
g6_4:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
gV:LoadAutoloadConfig()
gm(gQ.AntiGameplayPause.Value)
end)(...)

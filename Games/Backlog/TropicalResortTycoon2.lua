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
	local control = g.__TeekHubControl
	if not (type(control) == "table" and control.keyRequired == false) then
		local key = g.__TempoKey or g.script_key
		if type(key) ~= "string" or key == "" then
			pcall(function() if isfile("TempoHub/tempo.key") then key = readfile("TempoHub/tempo.key") end end)
		end
		key = type(key) == "string" and key:gsub("%s+", "") or ""
		local ok, why = false, "no key"
		if key ~= "" then
			local src
			pcall(function() src = game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/Key.lua?t=" .. tostring(os.time())) end)
			local fn = src and loadstring(src)
			if not fn then
				ok = true
			else
				local ran, a, b = pcall(fn, { verify = key })
				if not ran then ok = true beacon("check crashed: " .. tostring(a))
				else
					ok, why = a == true, b
					if not ok and type(why) == "string" and (why:find("reach") or why:find("try again")) then ok = true end
				end
			end
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
getgenv().TempoHoodSubtitle = "TROPICAL RESORT TYCOON 2"
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
local hk
local hG
local hn
local Options
local g1
local World
local Toggles
local g4
local ht
local ha
local Tags
local hd
local hz
local hg
local hC
local TempoTRT
local hF
local hj
local g0
local hI
local HttpService
local hL
local g3
local hs
local g6
local g9
local hv
local hy
local hc
local Data2
local hB
local gX
local hE
local connection
local g_
local hl
local hH
local g2
local ho
local hK
local g5
local hr
local hN
local Library
local VirtualUser
local hb
local hx
local he
local hA
local hD
local SaveManager
local function autoBuyLoop()
    setthreadidentity(8)
    local kU = {}
    while g6() do
        local Value2 = Toggles.AutoBuy.Value
        local Value = Options.BuyInterval.Value
        if Value2 and hk then
            local kV_1 = hr.Context():Get(Data2)
            if kV_1 then
                for k in World:Query(Tags.Buttonlike) do
                    if not g6() then
                        break
                    else
                        local kX_1 = World:Get(k, hn)
                        local kY = kX_1 and kV_1.Objects[kX_1]
                        local kX_2 = kY
                        if kY then
                            kY = kX_2.Data
                        end
                        if kY then
                            kY = not kU[kX_2.Name]
                        end
                        if kY then
                            local Data = kX_2.Data
                            local kZ = kV_1.ButtonMap[kX_2.Name]
                            local kZ_3
                            local k_ = kZ and kZ.Data
                            local k__4
                            local k__1 = type(Data.ProductId) == "number" and Data.ProductId > 0
                            local k0 = k__1
                            if not k0 then
                                local k__2 = k_ ~= nil and type(k_.ProductId) == "number" and k_.ProductId > 0
                                k0 = k__2
                            end
                            local k__3 = k0
                            local k0_1 = Data.NotPurchasable == true
                            if not k0_1 then
                                k0_1 = k_ ~= nil and k_.NotPurchasable == true
                            end
                            if k__3 or k0_1 then
                                kU[kX_2.Name] = true
                            else
                                local kY_4 = hC.PurchaseButton(ha, kX_2.Name)
                                if kY_4 == "OK" then
                                    kZ_3, k__4 = pcall(hk.PerformAction.Call, { Kind = "PurchaseButton", ButtonName = kX_2.Name })
                                    if not (kZ_3 and k__4 == "OK") then
                                        if kZ_3 and k__4 == "AlreadyPurchased" or kZ_3 and k__4 == "NotPurchasable" then
                                            kU[kX_2.Name] = true
                                            hC.UnpurchaseButton(ha, kX_2.Name)
                                        else
                                            if kZ_3 and k__4 == "NotEnoughCurrency" then
                                                hC.UnpurchaseButton(ha, kX_2.Name)
                                            else
                                                hC.UnpurchaseButton(ha, kX_2.Name)
                                                g0(k)
                                            end
                                        end
                                    end
                                else
                                    if kY_4 == "AlreadyPurchased" or kY_4 == "NotPurchasable" or kY_4 == "InvalidButton" or kY_4 == "UnknownError" then
                                        kU[kX_2.Name] = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(Value)
        if not g6() then
            break
        end
    end
end
local function fn11()
    local j9 = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local ka = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if ka then
                local ka_1 = ho(k, v)
                if ka_1 then
                    j9[#j9 + 1] = ka_1
                end
            end
        end
    end
    table.sort(j9, function(dm, dn)
        if dm.type ~= dn.type then
            return dm.type < dn.type
        end
        return dm.idx < dn.idx
    end)
    return { objects = j9 }
end
local function onCopyUSDTAddress()
    hs(hK, "Copied USDT address")
end
local function fn16(ah, ai, aj)
    return string.format("<b>%s</b> %s %s", ah, g1("-", "#5a6070"), g1(ai, aj))
end
local function worker()
    local jf_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local je = math.floor(os.clock() - hg)
        if je < 60 then
            jf_1 = je .. "s"
        elseif je < 3600 then
            jf_1 = string.format("%dm %ds", math.floor((je) / (60)), je % 60)
        else
            jf_1 = string.format("%dh %dm", math.floor((je) / (3600)), math.floor((je % 3600) / (60)))
        end
        hL:SetText(hI("Session time", jf_1, hb))
    end
end
local function fn86(c8, c9)
    local Type = c9.Type
    if Type == "Toggle" then
        return { idx = c8, type = "Toggle", value = c9.Value == true }
    elseif Type == "Slider" then
        return { idx = c8, type = "Slider", value = tostring(c9.Value) }
    elseif Type == "Dropdown" then
        return { idx = c8, type = "Dropdown", multi = c9.Multi == true, value = c9.Value }
    elseif Type == "Input" then
        local j6 = c9.Value or ""
        return { idx = c8, type = "Input", text = tostring(j6) }
    elseif Type == "ColorPicker" then
        return { idx = c8, type = "ColorPicker", value = c9.Value:ToHex(), transparency = c9.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = c8,
            type = "KeyPicker",
            mode = c9.Mode,
            key = c9.Value,
            modifiers = c9.Modifiers,
            toggled = c9.Toggled
        }
    else
        return nil
    end
end
local function onCopyEthereumAddress()
    hs(hN, "Copied Ethereum address")
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = ha.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local js_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if js_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function onImportConfigFromClipboardTex()
    local kJ_1
    local kH = Options.SaveManager_ImportSource.Value
    local kH_1
    local kN = if kH then 1 else 0
    local kL = 3133 * kN + 2223 * (1 - kN)
    local kM = 2447 * kN + 4031 * (1 - kN)
    if not ((kL * 2443 + kM * 383 + kL * kM) % 16777213 == 16257571) then
        kH = ""
    end
    local kI = tostring(kH):match("^%s*(.-)%s*$")
    if kI == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    kH_1, kJ_1 = pcall(HttpService.JSONDecode, HttpService, kI)
    local kI_1 = not kH_1 or type(kJ_1) ~= "table" or type(kJ_1.objects) ~= "table"
    if kI_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local kH_2 = 0
    for i, v in ipairs(kJ_1.objects) do
        if g3(v) then
            kH_2 += 1
        end
    end
    if kH_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local kJ_2 = kH_2 == 1 and ""
    local kN_1 = if kJ_2 then 1 else 0
    local kL_1 = 1134 * kN_1 + 2721 * (1 - kN_1)
    local kM_1 = 1124 * kN_1 + 2677 * (1 - kN_1)
    if not ((kL_1 * 2494 + kM_1 * 435 + kL_1 * kM_1) % 16777213 == 4591752) then
        kJ_2 = "s"
    end
    Library:Notify(("Imported %d setting%s"):format(kH_2, kJ_2), 6)
end
local function fn177()
    if not Toggles.Fly.Value then
        local jl = gX()
        if jl then
            jl.PlatformStand = false
        end
    end
end
local function fn192()
    local i7_1
    local i6_1
    if identifyexecutor then
        i7_1, i6_1 = identifyexecutor()
        local i8 = i7_1 ~= ""
        local i9 = type(i7_1) == "string" and i8
        if i9 then
            local i8_1 = type(i6_1) == "string" and i6_1 ~= "" and i7_1 .. " " .. i6_1
            hl = i8_1 or i7_1
        end
    end
end
local function onCopyBitcoinAddress()
    hs(g_, "Copied Bitcoin address")
end
local function fn212()
    hv(Toggles.AntiGameplayPause.Value)
end
local function onInputChanged(cT)
    local UserInputType = cT.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        hD = tick()
    end
end
local function antiGameplayPauseLoop()
    while g6() do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            hv(true)
        end
    end
end
local function onExportConfigToClipboard()
    local kB_1
    local kA_1
    kA_1, kB_1 = pcall(HttpService.JSONEncode, HttpService, g9())
    if not kA_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local kA_2 = setclipboard or toclipboard
    local kA_3 = type(kA_2) ~= "function" or not pcall(kA_2, kB_1)
    if kA_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function fn266()
    local Character = ha.Character
    local iR = Character and Character:FindFirstChildOfClass("Humanoid")
    return iR
end
local function fn269()
    return not Library.Unloaded and g2.TempoTRT == TempoTRT
end
local function fn270()
    local MainFrame = Library.MainFrame
    if MainFrame and MainFrame.Parent then
        MainFrame.Parent:SetAttribute("TempoTRT", true)
    end
end
local function fn295()
    if not Toggles.WalkSpeedEnabled.Value then
        local jn = gX()
        if jn then
            jn.WalkSpeed = 16
        end
    end
end
local function onCopyJoinScript_JobID()
    local bk = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, hH)
    hs(bk, "Copied join script to clipboard")
end
local function fn343()
    local CurrentCamera = he.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    hx = tick()
end
local function antiAfkLoop()
    while g6() do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local lm = tick() - hD
            local ln = tick() - hx
            if lm >= 300 and ln >= 60 then
                pcall(hc)
            else
                if lm < 300 and ln >= 300 then
                    pcall(hc)
                end
            end
        end
    end
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local jA_1 = gX()
        if jA_1 then
            jA_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function onCopySolanaAddress()
    hs(hF, "Copied Solana address")
end
local function fn507(X, Y)
    if setclipboard then
        setclipboard(X)
    elseif toclipboard then
        toclipboard(X)
    end
    Library:Notify(Y)
end
local function fn513(ae, af)
    return string.format('<font color="%s">%s</font>', af, ae)
end
local function fn545(a3)
    local DiscordGroup = a3:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = hd })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = hd })
end
local function fn564(aQ)
    local iX = World:Get(aQ, hj)
    local iY = hy()
    if not (iX and iY) then
        return
    end
    local CFrame2 = iY.CFrame
    iY.CFrame = CFrame.new(iX)
    task.wait(1.2)
    if g6() then
        iY.CFrame = CFrame2
    end
end
local function onCopyLitecoinAddress()
    hs(g5, "Copied Litecoin address")
end
local function onInputBegan()
    hD = tick()
end
local function fn584(c0, c1)
    local j_ = c0 == "Toggle" and Toggles
    local j4 = if j_ then 1 else 0
    local j2 = 457 * j4 + 1552 * (1 - j4)
    local j3 = 858 * j4 + 3770 * (1 - j4)
    if not ((j2 * 2479 + j3 * 1362 + j2 * j3) % 16777213 == 2693605) then
        j_ = Options
    end
    local j__1 = j_[c1]
    local jZ_2 = type(j__1) == "table" and j__1.Type == c0
    return jZ_2 and j__1 or nil
end
local function onCopyVenmoLink()
    hs(ht, "Copied Venmo link")
end
local function fn604()
    local Character = ha.Character
    if not Character then
        return nil
    end
    return Character:FindFirstChild("HumanoidRootPart")
end
local function fn608()
    hs(hE, "Copied Discord invite to clipboard")
end
local function fn620()
    g2.TempoTRT = g2.TempoTRT + 1
    hG:Disconnect()
    connection:Disconnect()
    hv(false)
    local lr = gX()
    if lr then
        lr.PlatformStand = false
        lr.WalkSpeed = 16
    end
end
local function onRenderStepped(cq)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local jC_1 = gX()
        if jC_1 then
            jC_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local jC_3 = hy()
        local jD = gX()
        local jE = he.CurrentCamera
        local jJ = if jE then 1 else 0
        local jH = 1317 * jJ + 761 * (1 - jJ)
        local jI = 1916 * jJ + 245 * (1 - jJ)
        if not ((jH * 3173 + jI * 927 + jH * jI) % 16777213 == 8478345) then
            jE = g4
        end
        g4 = jE
        if jC_3 and jD and g4 then
            jD.PlatformStand = true
            local jD_1 = Vector3.zero
            if hB:IsKeyDown(Enum.KeyCode.W) then
                jD_1 = jD_1 + g4.CFrame.LookVector
            end
            if hB:IsKeyDown(Enum.KeyCode.S) then
                jD_1 = jD_1 - g4.CFrame.LookVector
            end
            if hB:IsKeyDown(Enum.KeyCode.A) then
                jD_1 = jD_1 - g4.CFrame.RightVector
            end
            if hB:IsKeyDown(Enum.KeyCode.D) then
                jD_1 = jD_1 + g4.CFrame.RightVector
            end
            local jM = if hB:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
            if jM == 1 then
                jD_1 = jD_1 + Vector3.new(0, 1, 0)
            end
            if hB:IsKeyDown(Enum.KeyCode.LeftControl) then
                jD_1 = jD_1 - Vector3.new(0, 1, 0)
            end
            jC_3.Velocity = Vector3.zero
            if jD_1.Magnitude > 0 then
                jC_3.CFrame = jC_3.CFrame + jD_1.Unit * Options.FlySpeed.Value * cq
            end
        end
    end
end
local function fn653()
    for i, child in ipairs(gethui():GetChildren()) do
        local iH = child:IsA("ScreenGui") and child:GetAttribute("TempoTRT")
        if iH then
            child:Destroy()
        end
    end
end
local function onUnload()
    Library:Unload()
end
local function onCopyPayPalLink()
    hs(hA, "Copied PayPal link")
end
local function onRscripts()
    hs(hz, "Copied Rscripts profile to clipboard")
end
local function autoCollectLoop()
    local lc_1
    setthreadidentity(8)
    while g6() do
        local Value2 = Toggles.AutoCollect.Value
        local Value = Options.CollectInterval.Value
        if Value2 and hk then
            local k8_1 = hr.Context():Get(Data2)
            if k8_1 then
                for k in World:Query(Tags.ATM) do
                    if not g6() then
                        break
                    else
                        local la_1 = World:Get(k, hn)
                        local lb = la_1 and k8_1.Objects[la_1]
                        local lb_1
                        local la_2 = lb
                        if lb then
                            lb = la_2.Data.Currency
                        end
                        local la_3 = lb
                        lb_1, lc_1 = hC.CollectPendingCurrency(ha, la_3)
                        if lb_1 == "OK" and lc_1 and lc_1 > 0 then
                            pcall(hk.PerformAction.Call, { Kind = "CollectPending", CurrencyName = la_3 })
                        end
                    end
                end
            end
        end
        task.wait(Value)
        local ll = if not g6() then 1 else 0
        if ll == 1 then
            break
        end
    end
end
gX = nil
TempoTRT = nil
SaveManager = nil
g_ = nil
g0 = nil
g1 = nil
g2 = nil
g3 = nil
g4 = nil
g5 = nil
g6 = nil
Library = nil
g9 = nil
ha = nil
hb = nil
hc = nil
hd = nil
he = nil
Data2 = nil
hg = nil
connection = nil
hj = nil
hk = nil
hl = nil
hn = nil
ho = nil
HttpService = nil
World = nil
hr = nil
hs = nil
ht = nil
VirtualUser = nil
hv = nil
Tags = nil
hx = nil
hy = nil
hz = nil
hA = nil
hB = nil
hC = nil
hD = nil
hE = nil
hF = nil
hG = nil
hH = nil
hI = nil
Options = nil
local g7, CoreGui, GuiService
hK = nil
hL = nil
Toggles = nil
hN = nil
local GameInfoGroup
local h6_1
local h4_1
local hU_2
local CORE
hB, VirtualUser, HttpService, GuiService, CoreGui, he, ha, g2 = nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local AccountGroup
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local hQ_1
local RunService = game:GetService("RunService")
hB = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
he = game:GetService("Workspace")
ha = Players.LocalPlayer
local hS = "Tropical Resort Tycoon 2"
g2 = getgenv()
local hO_1 = g2.TempoTRT or 0
TempoTRT, hr, CORE, hk = nil, nil, nil, nil
local hP = 3
local hP_2
repeat
    local hV_1 = {
        "ahvcruw",
        "yoxnwkcyo",
        "tivf",
        "hho",
        "cchedzgtku",
        "stjcbvqt",
        "roc",
        "affd",
        "rfi",
        "bpue",
        "ricx"
    }
    local l_ = hP
    local hW_1 = hV_1[l_ % 11 + 1]
    if hW_1:len() <= hW_1:reverse():rep(l_ % 3 + 2):len() then
        g2.TempoTRT = hO_1 + 1
        TempoTRT = g2.TempoTRT
        pcall(fn653)
        hU_2 = require(ReplicatedStorage.Packages.TYCOON)
        hr = require(ReplicatedStorage.Packages.ECS)
        CORE = require(ReplicatedStorage.Packages.CORE)
    else
        g2.TempoTRT = CORE + 1
        hU_2 = ReplicatedStorage.TempoTRT
        pcall(fn653)
        g2 = require(TempoTRT.Packages.TYCOON)
        hO_1 = require(TempoTRT.Packages.ECS)
        hr = require(TempoTRT.Packages.CORE)
    end
    hP = (hP + 5) % 8
until (hP * 7 + 3) % 8 == 3
local Index = ReplicatedStorage.Packages:FindFirstChild("_Index")
if Index then
    for i, child in ipairs(Index:GetChildren()) do
        if child.Name:match("^packages_tycoon@") then
            local tycoon = child:FindFirstChild("tycoon")
            local hP_1 = tycoon and tycoon:FindFirstChild("Zap")
            local hO_4 = hP_1
            if hP_1 then
                hP_1 = hO_4:FindFirstChild("ZapClient")
            end
            local hO_5 = hP_1
            if hO_5 then
                hk = require(hO_5)
                break
            end
        end
    end
end
hC, Tags, World, hn, hj, Data2, Library, hQ_1, SaveManager = nil, nil, nil, nil, nil, nil, nil, nil, nil
if ((hn or SaveManager or (World or Library)) and ((not hQ_1 or Library) and (hQ_1 and SaveManager)) or (hQ_1 and Library or SaveManager and not World or (hQ_1 or not World) and (Library or hQ_1))) and not ((hn or SaveManager or (World or Library)) and ((not hQ_1 or Library) and (hQ_1 and SaveManager)) or (hQ_1 and Library or SaveManager and not World or (hQ_1 or not World) and (Library or hQ_1))) then
    hr = World.Actions
    hn = World.Components.Tags
    hj = Tags.World
    hC = World.Components.ObjectId
else
    hC = hU_2.Actions
    Tags = hU_2.Components.Tags
    World = hr.World
    hn = hU_2.Components.ObjectId
    hj = CORE.Components.Position
end
Data2 = hU_2.Components.Data
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
if setthreadidentity then
    setthreadidentity(8)
end
Toggles, Options, hE, hz, hb, g5, g_, hN, hK, hF, hA, ht, g6, hP_2, hs, hd, g1, hI, gX, hy, g0 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Toggles = Library.Toggles
Options = Library.Options
hE = "https://discord.gg/K7Qxnxkk46"
hz = "https://discord.gg/K7Qxnxkk46"
hs = fn507
hd = fn608
g1 = fn513
hI = fn16
local h1 = "#7fd47f"
local h_ = "#6ec1ff"
hb = "#e8a34d"
local hX = "#8b93a3"
g5 = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
g_ = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
hN = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
hK = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
hF = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
hA = ""
ht = ""
local h3 = "#345d9d"
local h2 = "#f7931a"
local h0 = "#627eea"
local hZ = "#26a17b"
local hY = "#14f195"
local hW_2 = "#0070ba"
local hV_2 = "#008cff"
gX = fn266
hy = fn604
if ("0xaE95A405D007a6F858E5d35714111B075fEFb40a" or (false or hy) or false and (hy and false)) and false or (hP_2 or hK or false or hP_2 and false and (hP_2 or false) or (hy or hK) and (false or hy) and (not hy and hK or false and hP_2)) or not (("0xaE95A405D007a6F858E5d35714111B075fEFb40a" or (false or hy) or false and (hy and false)) and false or (hP_2 or hK or false or hP_2 and false and (hP_2 or false) or (hy or hK) and (false or hy) and (not hy and hK or false and hP_2))) then
    g6 = fn269
    g0 = fn564
else
    g0 = fn269
    g6 = fn564
end
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = hE, Copyable = true }, "|", hS },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
pcall(fn270)
local hU_3 = {
    Info = Window:AddTab("Info", "info"),
    Farming = Window:AddTab("Farming", "coins"),
    Inventory = Window:AddTab("Inventory", "package"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in hU_3 do
    fn545(v)
end
hl, AccountGroup, GameInfoGroup, hL, hH, h4_1 = nil, nil, nil, nil, nil, nil
local hP_4 = 7
repeat
    local hT_3 = (hP_4 * 1 + 2) % 3 + 1
    if hT_3 <= 2 then
        if hT_3 <= 1 then
            if hP_4 * 37408897 + 7 + 4 <= hP_4 * 37408897 + 7 + 4 + 3 then
                hl = "Unknown"
                pcall(fn192)
                AccountGroup = hU_3.Info:AddLeftGroupbox("Account", "circle-user")
                AccountGroup:AddLabel(hI("User", ha.Name, h1), true)
                AccountGroup:AddLabel(hI("Status", "Keyless", h1), true)
                AccountGroup:AddLabel(hI("Executor", hl, h1), true)
                GameInfoGroup = hU_3.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                GameInfoGroup:AddLabel(g1(hS .. " [" .. tostring(game.PlaceId) .. "]", h_), true)
                GameInfoGroup:AddLabel(hI("Place ID", tostring(game.PlaceId), h_), true)
                hL = GameInfoGroup:AddLabel(hI("Session time", "0s", hb), true)
            else
                hU_3 = "Unknown"
                pcall(fn192)
                hl = (nil):AddLeftGroupbox("Account", "circle-user")
                hl:AddLabel(GameInfoGroup("User", hL.Name, hI), true)
                hl:AddLabel(GameInfoGroup("Status", "Keyless", hI), true)
                hl:AddLabel(GameInfoGroup("Executor", "Unknown", hI), true)
                g1 = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
                g1:AddLabel(hS(AccountGroup .. " [" .. tostring(game.PlaceId) .. "]", h1), true)
                g1:AddLabel(GameInfoGroup("Place ID", tostring(game.PlaceId), h1), true)
                ha = g1:AddLabel(GameInfoGroup("Session time", "0s", h_), true)
            end
            hP_4 = (hP_4 + 4) % 12
        else
            local l8 = bit32.rrotate(bit32.bxor(bit32.lrotate(hP_4, 25), string.byte(tostring(hL))), 18)
            if bit32.bxor(bit32.lrotate(bit32.bxor(l8, 1211285470), 24), 3729273535) == bit32.lrotate(l8, 24) then
                hH = tostring(game.JobId)
            else
                hL = tostring(game.JobId)
            end
            hP_4 = (hP_4 + 1) % 12
        end
    else
        if (hP_4 * 2 + 2) * 4 % 3 == ((hP_4 * 2 + 2) * 4 + 4) % 3 then
            hH = #h4_1 > 18
        else
            h4_1 = #hH > 18
        end
        hP_4 = (hP_4 + 7) % 12
    end
until (hP_4 * 7 + 7) % 12 == 8
if h4_1 then
    local hO_7 = 6
    repeat
        local hP_5 = (vector.create((hO_7 * 1 + 6) % 11 + 1, (hO_7 * 9 + 5) % 13 + 1, (hO_7 * 9 + 13) % 17 + 1))
        local hT_4 = (vector.create((hO_7 * 6 + 7) % 11 + 1, (hO_7 * 10 + 3) % 13 + 1, (hO_7 * 10 + 6) % 17 + 1))
        local l0 = vector.cross(hP_5, hT_4)
        local l1 = vector.dot(hP_5, hT_4)
        if vector.dot(l0, l0) + l1 * l1 == vector.dot(hP_5, hP_5) * vector.dot(hT_4, hT_4) + 4 then
            hH = string.sub(h4_1, 1, 18) .. "..."
        else
            h4_1 = string.sub(hH, 1, 18) .. "..."
        end
        hO_7 = (hO_7 + 2) % 8
    until (hO_7 * 3 + 4) % 8 == 4
end
local hO_8 = h4_1 or hH
hg, g4, hD, hx, hG, connection, h6_1, hv, hc, g7, ho, g9, g3 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
GameInfoGroup:AddLabel(hI("Server", hO_8, hX), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
hg = os.clock()
task.spawn(worker)
local ScriptsGroup = hU_3.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(g1("Included in this hub", hX), true)
ScriptsGroup:AddLabel(g1(hS, h_), true)
local FeaturesGroup = hU_3.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(g1("Auto Collect Money", h_), true)
FeaturesGroup:AddLabel(g1("Auto Buy Buttons", hb), true)
FeaturesGroup:AddLabel(g1("Misc Utilities", hX), true)
local SocialsGroup = hU_3.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = hd })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = hU_3.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = hd })
local DonationsGroup = hU_3.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(g1("All donations are optional but appreciated.", hb), true)
DonationsGroup:AddLabel(g1("If you donate you get a special role, just PING after you donate.", h1), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(g1("LTC / Litecoin", h3), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(g1("BTC / Bitcoin", h2), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(g1("ETH / Ethereum", h0), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(g1("USDT", hZ), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(g1("Solana", hY), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(g1("PayPal", hW_2), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(g1("Venmo", hV_2), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(g1("Don't have any of the listed currencies but still wanna donate?", hX), true)
DonationsGroup:AddLabel(g1("DM me and we'll work something out.", h_), true)
local FaqGroup = hU_3.Info:AddRightGroupbox("FAQ", "circle-help")
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
local MoneyGroup = hU_3.Farming:AddLeftGroupbox("Money", "coins")
MoneyGroup:AddToggle("AutoCollect", { Text = "Auto Collect Money", Default = true })
MoneyGroup:AddSlider("CollectInterval", { Text = "Collect Interval", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
local PurchasesGroup = hU_3.Inventory:AddLeftGroupbox("Purchases", "package")
PurchasesGroup:AddToggle("AutoBuy", { Text = "Auto Buy All Buttons", Default = false })
PurchasesGroup:AddSlider("BuyInterval", { Text = "Buy Interval", Default = 1.5, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
local MovementGroup = hU_3.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = hU_3.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
hv = function(bV)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not bV)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not bV
        end
    end)
    if not bV then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(ha, "GameplayPaused", false)
        else
            ha.GameplayPaused = false
        end
    end)
end
if (g7 and ScriptsGroup or (SocialsGroup or not h6_1)) and (not g7 and not SocialsGroup and (ScriptsGroup or not hg)) and (hg or not hg or (g7 or ScriptsGroup) or (SocialsGroup or g7) and (h6_1 and PurchasesGroup)) and not ((g7 and ScriptsGroup or (SocialsGroup or not h6_1)) and (not g7 and not SocialsGroup and (ScriptsGroup or not hg)) and (hg or not hg or (g7 or ScriptsGroup) or (SocialsGroup or g7) and (h6_1 and PurchasesGroup))) then
    g4.AntiGameplayPause:OnChanged(fn212)
    g4.Fly:OnChanged(fn177)
    g4.WalkSpeedEnabled:OnChanged(fn295)
    Toggles.Stepped:Connect(onStepped)
    RunService.JumpRequest:Connect(onJumpRequest)
    he = hB.CurrentCamera
else
    Toggles.AntiGameplayPause:OnChanged(fn212)
    Toggles.Fly:OnChanged(fn177)
    Toggles.WalkSpeedEnabled:OnChanged(fn295)
    RunService.Stepped:Connect(onStepped)
    hB.JumpRequest:Connect(onJumpRequest)
    g4 = he.CurrentCamera
end
RunService.RenderStepped:Connect(onRenderStepped)
local MenuGroup = hU_3.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
hD = tick()
if MoneyGroup and MoneyGroup and (hG or not connection) and (not MoneyGroup or not MenuGroup or connection and not PurchasesGroup) or not (MoneyGroup and MoneyGroup and (hG or not connection) and (not MoneyGroup or not MenuGroup or connection and not PurchasesGroup)) then
    hx = tick()
    pcall(function()
        for i, v in ipairs(getconnections(ha.Idled)) do
            local jT = v
            pcall(function()
                jT:Disable()
            end)
        end
    end)
    hc = fn343
    hG = hB.InputBegan:Connect(onInputBegan)
else
    hG = tick()
    pcall(function()
        for i, v in ipairs(getconnections(ha.Idled)) do
            local jT = v
            pcall(function()
                jT:Disable()
            end)
        end
    end)
    hB = fn343
    hc = hx.InputBegan:Connect(onInputBegan)
end
connection = hB.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton({ Text = "Unload", Func = onUnload })
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(hU_3.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/TropicalResortTycoon2")
local h6_2 = SaveManager:BuildConfigSection(hU_3.Settings)
g7 = fn584
ho = fn86
g9 = fn11
g3 = function(dq)
    local kq
    kq = nil
    local kr = type(dq) ~= "table" or type(dq.idx) ~= "string" or type(dq.type) ~= "string" or SaveManager.Ignore[dq.idx]
    if kr then
        return false
    end
    kq = g7(dq.type, dq.idx)
    if not kq then
        return false
    end
    local kr_1 = pcall(function()
        if dq.type == "Input" then
            if type(dq.text) ~= "string" then
                return
            end
            kq:SetValue(dq.text)
        elseif dq.type == "ColorPicker" then
            kq:SetValueRGB(Color3.fromHex(dq.value), dq.transparency)
        elseif dq.type == "KeyPicker" then
            kq:SetValue({ dq.key, dq.mode, dq.modifiers })
            if dq.mode == "Toggle" and dq.toggled ~= nil then
                kq.Toggled = dq.toggled
                kq:Update()
            end
        else
            kq:SetValue(dq.value)
        end
    end)
    return kr_1
end
do
    h6_2:AddDivider()
    h6_2:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    h6_2:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    h6_2:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
    SaveManager:LoadAutoloadConfig()
    task.spawn(autoBuyLoop)
    task.spawn(autoCollectLoop)
    task.spawn(antiAfkLoop)
    task.spawn(antiGameplayPauseLoop)
    Library:OnUnload(fn620)
end
if _G.STATE then
    _G.STATE.onCleanup(function()
        g2.TempoTRT = g2.TempoTRT + 1
        pcall(function()
            Library:Unload()
        end)
    end)
end
Library:Notify("Tropical Resort Tycoon 2 loaded")
end)(...)

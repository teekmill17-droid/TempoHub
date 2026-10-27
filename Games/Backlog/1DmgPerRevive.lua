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
getgenv().TempoHoodSubtitle = "+1 DMG PER REVIVE"
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
local fns = {}
local tz_3, tz_4, tz_8, tz_10, tz_13, tz_14, tz_16
local mM
local nt
local na
local nS
local mS
local nz
local ng
local nY
local connection
local nF
local nm
local m3
local container
local mL
local m9
local nR
local mR
local ny
local nf
local nX
local mX
local nE
local nl
local TeleportTag
local m2
local nK
local mK
local CollectionService
local m8
local nQ
local mQ
local __tempo_gen
local nW
local Label
local nD
local nk
local n1
local m1
local nJ
local mJ
local connection3
local m7
local VirtualUser
local mP
local nw
local nd
local nV
local mV
local nC
local nj
local n0
local m0
local HttpService
local mI
local np
local m6
local Toggles
local mO
local nv
local nc
local UserInputService
local mU
local n_
local SaveManager
local no
local Library
local nN
local mN
local Workspace
local nb
local Options
local mT
local nA
local nZ
local mZ
local nG
local nn
local m4
local connection2
function fns.onCopyLitecoinAddress()
    nC(n_, "Copied Litecoin address")
end
function fns.fn34()
    return nm:TbMainChallenge():getDataList()
end
function fns.fn62()
    local Character = nk.Character
    local qa = Character and Character:FindFirstChildOfClass("Humanoid")
    return qa
end
function fns.onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = nk.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local qH_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if qH_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
function fns.fn89()
    return not Library.Unloaded and ng.__tempo_gen == __tempo_gen
end
function fns.fn134()
    return nv.Tables:new()
end
function fns.fn160()
    return nn(n1.AtomRebirth)
end
function fns.fn171()
    nC(no, "Copied Discord invite to clipboard")
end
function fns.onCopyBitcoinAddress()
    nC(nW, "Copied Bitcoin address")
end
function fns.fn192()
    if not Toggles.Rebirth.Value then
        task.wait(1)
        return
    end
    local Value = Options.RebirthInterval.Value
    if not mN() then
        task.wait(Value)
        return
    end
    pcall(function()
        local tb = mT() and os.clock() - nz >= 5
        if tb then
            local tb_1 = (nF())
            local tg = if tb_1 then 1 else 0
            local te = 1305 * tg + 3050 * (1 - tg)
            local tf = 462 * tg + 3952 * (1 - tg)
            if not ((te * 2424 + tf * 2679 + te * tf) % 16777213 == 5003928) then
                tb_1 = 0
            end
            local tc = nQ * (tb_1 + 1)
            local tb_2 = mL() or 0
            if tb_2 >= tc then
                nz = os.clock()
                np.rebirth:FireServer()
            end
        end
    end)
    nY()
    task.wait(Value)
end
function fns.fn194()
    task.wait(1)
    if Toggles.AntiGameplayPause.Value then
        m9(true)
    end
end
function fns.onExportConfigToClipboard()
    local r0_1
    local r__1
    r__1, r0_1 = pcall(HttpService.JSONEncode, HttpService, mM())
    if not r__1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local r__2 = setclipboard or toclipboard
    local r__3 = type(r__2) ~= "function" or not pcall(r__2, r0_1)
    if r__3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
function fns.onInputBegan()
    m7 = tick()
end
function fns.fn272()
    if mS then
        if os.clock() - mQ > 150 then
            mS = false
            mS = true
            mQ = os.clock()
            return true
        end
        return false
    end
    mS = true
    mQ = os.clock()
    return true
end
function fns.onCopyEthereumAddress()
    nC(nR, "Copied Ethereum address")
end
function fns.onCopyJoinScript_JobID()
    local c6 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, mR)
    nC(c6, "Copied join script to clipboard")
end
function fns.fn316(cS)
    local DiscordGroup = cS:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = nj })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = nj })
end
function fns.fn320()
    local qp_1
    local qo_1
    if identifyexecutor then
        qp_1, qo_1 = identifyexecutor()
        local qq = qp_1 ~= ""
        local qr = type(qp_1) == "string" and qq
        if qr then
            local qq_1 = type(qo_1) == "string" and qo_1 ~= "" and qp_1 .. " " .. qo_1
            nc = qq_1 or qp_1
        end
    end
end
function fns.fn346(f6)
    local sq = os.clock()
    while true do
        if not (os.clock() - sq < f6) then
            return false
        end
        if not m8() then
            return false
        end
        local Character = nk.Character
        local ss = Character and Character:FindFirstChild("HumanoidRootPart")
        if ss then
            break
        end
        task.wait(0.5)
    end
    return true
end
function fns.fn390()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    m2 = tick()
end
function fns.antiAfkLoop()
    while true do
        if not Library.Unloaded and ng.__tempo_gen == __tempo_gen then
            task.wait(2)
            if Toggles.AntiAfk.Value then
                local tq_1 = tick() - m7
                local tr = tick() - m2
                if tq_1 >= 300 and tr >= 60 then
                    pcall(mP)
                else
                    if tq_1 < 300 and tr >= 300 then
                        pcall(mP)
                    end
                end
            end
            continue
        end
        break
    end
end
function fns.fn425()
    if not Toggles.Fly.Value then
        local qD = na()
        if qD then
            qD.PlatformStand = false
        end
    end
end
function fns.onRscripts()
    nC(nl, "Copied Rscripts profile to clipboard")
end
function fns.onUnload()
    Library:Unload()
end
function fns.onCopySolanaAddress()
    nC(nE, "Copied Solana address")
end
function fns.fn450(bq)
    nA()
    local pP = nN[bq]
    if not pP then
        return false
    end
    local Character = nk.Character
    local pR = Character and Character:FindFirstChild("HumanoidRootPart")
    if not pR then
        return false
    end
    pR.CFrame = pP * CFrame.new(0, 4, 0)
    return true
end
local function fn458()
    m9(Toggles.AntiGameplayPause.Value)
end
local function fn506()
    local qi = Library.MainFrame
    while true do
        local qj_1 = qi and not qi:IsA("ScreenGui")
        if qj_1 then
            qi = qi.Parent
            continue
        end
        break
    end
    local qj_2 = qi and qi:IsA("ScreenGui")
    if qj_2 then
        qi:SetAttribute("TempoHubUI", true)
    end
end
local function fn515()
    return nn(mJ.AtomBattleState)
end
local function fn518()
    local pX = nX() or 0
    return pX == 0
end
local function onRenderStepped(el)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local qU_1 = na()
        if qU_1 then
            qU_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local qU_3 = m0()
        local qV = na()
        n0 = Workspace.CurrentCamera or n0
        if qU_3 and qV and n0 then
            qV.PlatformStand = true
            local qV_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                qV_1 = qV_1 + n0.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                qV_1 = qV_1 - n0.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                qV_1 = qV_1 - n0.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                qV_1 = qV_1 + n0.CFrame.RightVector
            end
            local rc = if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
            if rc == 1 then
                qV_1 = qV_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                qV_1 = qV_1 - Vector3.new(0, 1, 0)
            end
            qU_3.Velocity = Vector3.zero
            if qV_1.Magnitude > 0 then
                qU_3.CFrame = qU_3.CFrame + qV_1.Unit * Options.FlySpeed.Value * el
            end
        end
    end
end
local function fn548()
    if not Toggles.ReaperTP.Value then
        task.wait(1)
        return
    end
    local Value = Options.ReaperInterval.Value
    local sO = mV() or math.huge
    local sP = sO <= os.time() and not mI()
    if sP then
        if mN() then
            pcall(function()
                mX("reaper")
            end)
            nY()
        end
    end
    task.wait(Value)
end
local function fn557()
    return nn(mJ.AtomMainLevel)
end
local function fn564()
    local pd = nt()
    local pe = pd and pd.Titles
    local pe_1
    local pd_1 = pe
    if pe then
        pe = pd_1.UnlockedTitles
    end
    local pd_2 = {}
    local pf = pe
    local pf_1
    local pm = if pf then 1 else 0
    local pk = 1388 * pm + 3874 * (1 - pm)
    local pl = 650 * pm + 3731 * (1 - pm)
    if not ((pk * 3243 + pl * 3293 + pk * pl) % 16777213 == 7543934) then
        pf = pd_2
    end
    local pd_3 = pf
    pe_1, pf_1 = -1, nil
    for i, v in ipairs(pd_3) do
        local pd_4 = nV[v]
        if pd_4 and not pd_4.hidden then
            local pd_5 = (pd_4.rarity or 0) * 1000000 + (pd_4.sort or 0)
            if pd_5 > pe_1 then
                pe_1, pf_1 = pd_5, v
            end
        end
    end
    return pf_1
end
local function onCopyPayPalLink()
    nC(ny, "Copied PayPal link")
end
local function onCopyUSDTAddress()
    nC(nK, "Copied USDT address")
end
local function fn600(b7, b8)
    return string.format('<font color="%s">%s</font>', b8, b7)
end
local function fn620()
    mS = false
end
local function fn623()
    return nn(mJ.AtomReaperTime)
end
local function worker()
    local qu_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local qt = math.floor(os.clock() - nS)
        if qt < 60 then
            qu_1 = qt .. "s"
        elseif qt < 3600 then
            qu_1 = string.format("%dm %ds", math.floor((qt) / (60)), qt % 60)
        else
            qu_1 = string.format("%dh %dm", math.floor((qt) / (3600)), math.floor((qt % 3600) / (60)))
        end
        Label:SetText(m6("Session time", qu_1, mK))
    end
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local qS_1 = na()
        if qS_1 then
            qS_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn652(e3, e4)
    local Type = e4.Type
    if Type == "Toggle" then
        return { idx = e3, type = "Toggle", value = e4.Value == true }
    elseif Type == "Slider" then
        return { idx = e3, type = "Slider", value = tostring(e4.Value) }
    elseif Type == "Dropdown" then
        return { idx = e3, type = "Dropdown", multi = e4.Multi == true, value = e4.Value }
    elseif Type == "Input" then
        local rx = e4.Value
        local rB = if rx then 1 else 0
        local rz = 3479 * rB + 892 * (1 - rB)
        local rA = 1095 * rB + 3423 * (1 - rB)
        if not ((rz * 3630 + rA * 1766 + rz * rA) % 16777213 == 1594832) then
            rx = ""
        end
        return { idx = e3, type = "Input", text = tostring(rx) }
    elseif Type == "ColorPicker" then
        return { idx = e3, type = "ColorPicker", value = e4.Value:ToHex(), transparency = e4.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = e3,
            type = "KeyPicker",
            mode = e4.Mode,
            key = e4.Value,
            modifiers = e4.Modifiers,
            toggled = e4.Toggled
        }
    else
        return nil
    end
end
local function onCopyVenmoLink()
    nC(nw, "Copied Venmo link")
end
local function fn674(an)
    return container:WaitForChild(an, 15)
end
local function onOnClientEvent(bM)
    m4 = bM == true
end
local function fn721()
    if not Toggles.WalkSpeedEnabled.Value then
        local qF = na()
        if qF then
            qF.WalkSpeed = 16
        end
    end
end
local function fn722()
    return nm:TbGlobalConfig():rebirthTowerLevelRatio()
end
local function fn811()
    return nn(mJ.AtomTowerLevel)
end
local function fn822()
    if not Toggles.Stages.Value then
        task.wait(1)
        return
    end
    local Value = Options.StagesInterval.Value
    if not mN() then
        task.wait(Value)
        return
    end
    pcall(function()
        local sK = if mT() then 1 else 0
        if sK == 1 then
            local sF = m3() or 0
            local sG = sF + 1
            if nD > 0 then
                sG = math.min(sG, nD)
            end
            local sF_1 = "DeathRoad" .. sG
            mX(sF_1)
        end
    end)
    nY()
    task.wait(Value)
end
local function onInputChanged(eO)
    local UserInputType = eO.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        m7 = tick()
    end
end
local function fn864()
    local pb_1
    local pa_1
    pa_1, pb_1 = pcall(function()
        return nZ.saveAtom()()
    end)
    if not pa_1 then
        return nil
    end
    return pb_1[tostring(nk.UserId)]
end
local function fn908(ca, cb, cc)
    return string.format("<b>%s</b> %s %s", ca, nb("-", "#5a6070"), nb(cb, cc))
end
local function fn965()
    local pZ = nX() or 0
    return mO[pZ] == true
end
local function fn966()
    ng.__tempo_gen = __tempo_gen + 1000
    ng.TempoHub_Library = nil
    if connection then
        connection:Disconnect()
    end
    connection2:Disconnect()
    connection3:Disconnect()
    m9(false)
    local tu = na()
    if tu then
        tu.PlatformStand = false
        tu.WalkSpeed = 16
    end
end
local function fn987()
    if not Toggles.Tower.Value then
        task.wait(1)
        return
    end
    local Value = Options.TowerInterval.Value
    local s5 = nJ > 0
    if s5 then
        local s6_1 = m3() or 0
        s5 = s6_1 < nJ
    end
    if s5 then
        task.wait(Value)
        return
    end
    local s6_3 = mU[Options.TowerLevelAdd and Options.TowerLevelAdd.Value or "Add1"]
    local ta = if s6_3 then 1 else 0
    local s8 = 1225 * ta + 177 * (1 - ta)
    local s9 = 971 * ta + 3603 * (1 - ta)
    if not ((s8 * 3554 + s9 * 1344 + s8 * s9) % 16777213 == 6848149) then
        s6_3 = 0
    end
    local s5_3 = s6_3
    if mN() then
        pcall(m1, 3, s5_3)
        nY()
    end
    task.wait(Value)
end
local function fn1002()
    if not Toggles.DeathKing.Value then
        task.wait(1)
        return
    end
    local Value = Options.DeathInterval.Value
    local s__1 = mU[Options.DeathLevelAdd and Options.DeathLevelAdd.Value or "Add1"] or 0
    if mN() then
        pcall(m1, 1, s__1)
        nY()
    end
    task.wait(Value)
end
local function fn1013()
    local TowerBattle = Workspace:FindFirstChild("TowerBattle")
    local pU = TowerBattle and TowerBattle:FindFirstChild("Pos")
    local pT_1 = pU
    if pU then
        pU = pT_1:FindFirstChild("Player")
    end
    local pT_2 = pU
    if pU then
        pU = pT_2:IsA("BasePart")
    end
    if pU then
        local Character = nk.Character
        local pV = Character and Character:FindFirstChild("HumanoidRootPart")
        if pV then
            pV.CFrame = pT_2.CFrame + Vector3.new(0, 4, 0)
            return true
        end
        return mX("towerEntry")
    end
    return mX("towerEntry")
end
local function onImportConfigFromClipboardTex()
    local r5_1
    local r3 = Options.SaveManager_ImportSource.Value or ""
    local r3_1
    local r4 = tostring(r3):match("^%s*(.-)%s*$")
    if r4 == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    r3_1, r5_1 = pcall(HttpService.JSONDecode, HttpService, r4)
    local r4_1 = not r3_1
    local r9 = if r4_1 then 1 else 0
    local r7 = 3446 * r9 + 37 * (1 - r9)
    local r8 = 2620 * r9 + 2112 * (1 - r9)
    if not ((r7 * 1853 + r8 * 40 + r7 * r8) % 16777213 == 15518758) then
        r4_1 = type(r5_1) ~= "table"
    end
    if not r4_1 then
        r4_1 = type(r5_1.objects) ~= "table"
    end
    if r4_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local r3_2 = 0
    for i, v in ipairs(r5_1.objects) do
        if nf(v) then
            r3_2 += 1
        end
    end
    if r3_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local r5_2 = r3_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(r3_2, r5_2), 6)
end
local function fn1053(bZ, b_)
    if setclipboard then
        setclipboard(bZ)
    elseif toclipboard then
        toclipboard(bZ)
    end
    Library:Notify(b_)
end
local function fn1103()
    if not Toggles.CursedKing.Value then
        task.wait(1)
        return
    end
    local Value = Options.CursedInterval.Value
    local sW_1 = mU[Options.CursedLevelAdd and Options.CursedLevelAdd.Value or "Add1"] or 0
    if mN() then
        pcall(m1, 2, sW_1)
        nY()
    end
    task.wait(Value)
end
local function fn1111()
    if not Toggles.BestTitle.Value then
        task.wait(1)
        return
    end
    local Value = Options.TitleInterval.Value
    if not mN() then
        task.wait(Value)
        return
    end
    pcall(function()
        local tj = nd()
        if tj then
            local tk = nt()
            if (tk and tk.Titles and tk.Titles.EquippedTitle) ~= tj then
                np.equipTitle:FireServer(tj)
            end
        end
    end)
    nY()
    task.wait(Value)
end
local function fn1112()
    local rD = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local rE = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if rE then
                local rE_1 = mZ(k, v)
                if rE_1 then
                    rD[#rD + 1] = rE_1
                end
            end
        end
    end
    table.sort(rD, function(fh, fi)
        if fh.type ~= fi.type then
            return fh.type < fi.type
        end
        return fh.idx < fi.idx
    end)
    return { objects = rD }
end
local function fn1127()
    local Character = nk.Character
    local qg = Character and Character:FindFirstChild("HumanoidRootPart")
    return qg
end
local function fn1133(eW, eX)
    local rq_1 = (eW == "Toggle" and Toggles or Options)[eX]
    local rp_2 = type(rq_1) == "table" and rq_1.Type == eW
    local rp_3 = rp_2 and rq_1
    local rv = if rp_3 then 1 else 0
    local rt = 1403 * rv + 1762 * (1 - rv)
    local ru = 1220 * rv + 173 * (1 - rv)
    if not ((rt * 3961 + ru * 3296 + rt * ru) % 16777213 == 11290063) then
        rp_3 = nil
    end
    return rp_3
end
local function fn1151(E)
    local o__1
    local oZ_1
    oZ_1, o__1 = pcall(require, E)
    return oZ_1 and o__1
end
local function fn1152()
    for i, child in ipairs(gethui():GetChildren()) do
        local p0 = child:IsA("ScreenGui") and child:GetAttribute("TempoHubUI")
        if p0 then
            child:Destroy()
        end
    end
end
local function fn1161()
    local pv = os.clock()
    if pv - nG < 2.5 then
        return
    end
    nG = pv
    table.clear(nN)
    local function pv_1(bf)
        if bf:IsA("BasePart") then
            local attr = bf:GetAttribute("point")
            if attr then
                nN[attr] = bf.CFrame
            end
        end
    end
    if TeleportTag then
        for i, v in ipairs(CollectionService:GetTagged(TeleportTag)) do
            pv_1(v)
        end
    else
        for i, descendant in ipairs(Workspace:GetDescendants()) do
            pv_1(descendant)
        end
    end
end
local function fn1165()
    return nm:TbGlobalConfig():unlockTowerMainLevelRequire()
end
mI = nil
mJ = nil
mK = nil
mL = nil
mM = nil
mN = nil
mO = nil
mP = nil
mQ = nil
mR = nil
mS = nil
mT = nil
mU = nil
mV = nil
Label = nil
mX = nil
connection = nil
mZ = nil
SaveManager = nil
m0 = nil
m1 = nil
m2 = nil
m3 = nil
m4 = nil
Library = nil
m6 = nil
m7 = nil
m8 = nil
m9 = nil
na = nil
nb = nil
nc = nil
nd = nil
__tempo_gen = nil
nf = nil
ng = nil
nj = nil
nk = nil
nl = nil
nm = nil
nn = nil
no = nil
np = nil
connection3 = nil
CollectionService = nil
nt = nil
Workspace = nil
local nh, ni, ns
nv = nil
nw = nil
ny = nil
nz = nil
nA = nil
nC = nil
nD = nil
nE = nil
nF = nil
nG = nil
HttpService = nil
nJ = nil
nK = nil
container = nil
connection2 = nil
nN = nil
Toggles = nil
VirtualUser = nil
nQ = nil
nR = nil
nS = nil
Options = nil
UserInputService = nil
nV = nil
nW = nil
nX = nil
nY = nil
nZ = nil
n_ = nil
n0 = nil
n1 = nil
TeleportTag = nil
local CoreGui, GuiService, nH
CoreGui = nil
GuiService = nil
nH = nil
UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, CollectionService, nk, ng = nil, nil, nil, nil, nil, nil, nil, nil, nil
local tz_9 = game:GetService("Players")
local tz_11 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
CollectionService = game:GetService("CollectionService")
local tz_5 = tz_9.LocalPlayer
nk = tz_5
local tz_7 = "+1 DMG Per Revive"
ng = getgenv()
tz_9 = ng.__tempo_gen or 0
__tempo_gen, tz_13 = nil, nil
local tz_15 = 13
repeat
    tz_3 = (tz_15 * 1 + 0) % 2 + 1
    if tz_3 <= 1 then
        tz_3 = (vector.create((tz_15 * 6 + 8) % 11 + 1, (tz_15 * 6 + 6) % 13 + 1, (tz_15 * 7 + 14) % 17 + 1))
        local vd = vector.floor(tz_3) + vector.ceil(tz_3 * -1)
        if vector.dot(vd, vd) == 0 then
            tz_13 = ng.TempoHub_Library
        else
            ng = tz_13.TempoHub_Library
        end
        tz_15 = (tz_15 + 5) % 16
    else
        tz_3 = (vector.create((tz_15 * 2 + 5) % 11 + 1, (tz_15 * 2 + 5) % 13 + 1, (tz_15 * 15 + 16) % 17 + 1))
        tz_8 = (vector.create((tz_15 * 7 + 8) % 11 + 1, (tz_15 * 5 + 5) % 13 + 1, (tz_15 * 10 + 13) % 17 + 1))
        tz_14 = (vector.create((tz_15 * 4 + 7) % 5 + 1, (tz_15 * 3 + 7) % 7 + 1, (tz_15 * 3 + 6) % 9 + 1))
        if math.abs((vector.angle(tz_3, tz_8, tz_14))) - math.abs((vector.angle(tz_8, tz_3, tz_14))) == 2 then
            ng.__tempo_gen = __tempo_gen + 1
            ng = tz_9.__tempo_gen
        else
            ng.__tempo_gen = tz_9 + 1
            __tempo_gen = ng.__tempo_gen
        end
        tz_15 = (tz_15 + 3) % 16
    end
until (tz_15 * 1 + 2) % 16 == 7
if tz_13 then
    tz_9 = 2
    repeat
        tz_15 = {
            "yuhtq",
            "kboetctkya",
            "touwthlu",
            "yids",
            "hwcf",
            "yxgdtxgu",
            "hrvuwvkev",
            "bln",
            "gwkwnqcu",
            "jyylbmsntdf"
        }
        local uW = tz_9
        tz_3 = tz_15[uW % 10 + 1]
        if tz_3:len() >= tz_3:reverse():rep(uW % 3 + 2):len() then
            ng = type(tz_13.TempoHub_Library.Unload) == "function"
        else
            tz_13 = type(ng.TempoHub_Library.Unload) == "function"
        end
        tz_9 = (tz_9 + 0) % 4
    until (tz_9 * 1 + 2) % 4 == 0
end
if tz_13 then
    pcall(function()
        ng.TempoHub_Library:Unload()
    end)
end
Library, SaveManager = nil, nil
Library = getgenv().Library
tz_3 = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
ng.TempoHub_Library = Library
tz_13 = fn1151
tz_9 = {}
tz_15 = tz_13(tz_11.common.store.battle) or tz_9
mJ = tz_15
tz_9 = {}
tz_15 = tz_13(tz_11.common.store.rebirth) or tz_9
n1 = tz_15
tz_9 = {}
tz_15 = tz_13(tz_11.common.store.save) or tz_9
nZ = tz_15
tz_9 = {}
tz_15 = tz_13(tz_11.gen_config.tbtitle) or tz_9
nV, nQ, nJ, nD, tz_8, nv = nil, nil, nil, nil, nil, nil
tz_13 = 13
repeat
    tz_9 = (tz_13 * 1 + 1) % 3 + 1
    if tz_9 <= 2 then
        if tz_9 <= 1 then
            tz_9 = (vector.create((tz_13 * 4 + 9) % 11 + 1, (tz_13 * 9 + 2) % 13 + 1, (tz_13 * 7 + 6) % 17 + 1))
            local uO = vector.floor(tz_9) + vector.ceil(tz_9 * -1)
            if vector.dot(uO, uO) == 0 then
                nJ = 0
                nD = 0
            else
                nD = 0
                nJ = 0
            end
            tz_13 = (tz_13 + 22) % 24
        else
            if tz_13 * 34037433 + 7 + 1 <= tz_13 * 34037433 + 7 + 1 + 1 then
                tz_8, nv = pcall(require, tz_11.common.config.schema)
            else
                nv, tz_11 = pcall(require, tz_8.common.config.schema)
            end
            tz_13 = (tz_13 + 4) % 24
        end
    else
        tz_9 = {
            "ycdjk",
            "vbspwpezxux",
            "avbwwmupjxw",
            "qjno",
            "kpepgdpcwj",
            "yykiizau",
            "urihqp",
            "gukbsxtuh",
            "eyeqiwgjz"
        }
        local uX = tz_13
        tz_14 = tz_9[uX % 9 + 1]
        if tz_14:len() <= tz_14:reverse():rep(uX % 3 + 2):len() then
            nV = tz_15
            nQ = 5
        else
            tz_15 = nQ
            nV = 5
        end
        tz_13 = (tz_13 + 13) % 24
    end
until (tz_13 * 11 + 7) % 24 == 3
if tz_8 then
    tz_13, nm, tz_15 = nil, nil, nil
    tz_9 = 8
    repeat
        tz_8 = (tz_9 * 1 + 1) % 2 + 1
        if tz_8 <= 1 then
            if tz_9 * 25526371 + 13 + 5 <= tz_9 * 25526371 + 13 + 5 + 2 then
                tz_15 = tz_13
            else
                tz_13 = tz_15
            end
            tz_9 = (tz_9 + 5) % 16
        else
            local uh = bit32.rrotate(bit32.bxor(bit32.lrotate(tz_9, 11), string.byte(tostring(nm))), 15)
            if bit32.bxor(bit32.lrotate(bit32.bxor(uh, 1196971307), 8), 1481976647) == bit32.lrotate(uh, 8) then
                tz_13, nm = pcall(fns.fn134)
            else
                nm, tz_13 = pcall(fns.fn134)
            end
            tz_9 = (tz_9 + 1) % 16
        end
    until (tz_9 * 13 + 10) % 16 == 0
    if tz_15 then
        tz_15 = nm
    end
    if tz_15 then
        tz_15 = nm.TbGlobalConfig
    end
    if tz_15 then
        tz_9, tz_4 = pcall(fn722)
        tz_14 = tz_9
        if tz_14 then
            tz_9 = 1
            repeat
                if tz_9 * 126271303 + 8 + 7 <= tz_9 * 126271303 + 8 + 7 + 1 then
                    tz_14 = type(tz_4) == "number"
                else
                    tz_4 = type(tz_14) == "number"
                end
                tz_9 = (tz_9 + 4) % 8
            until (tz_9 * 3 + 0) % 8 == 7
        end
        if tz_14 then
            nQ = tz_4
        end
        tz_9, tz_14, tz_8 = nil, nil, nil
        tz_15 = 6
        repeat
            tz_4 = (tz_15 * 1 + 1) % 2 + 1
            if tz_4 <= 1 then
                if (tz_15 * 2 + 3) * 16 % 3 == ((tz_15 * 2 + 3) * 16 + 4) % 3 then
                    tz_9 = tz_8
                else
                    tz_8 = tz_9
                end
                tz_15 = (tz_15 + 9) % 16
            else
                if (tz_15 and not tz_15 and (tz_9 and tz_8) or not tz_8 and not tz_8 and (tz_14 or tz_15) or ((not tz_14 or tz_9) and (tz_15 and not tz_15) or tz_9 and not tz_8 and (not tz_15 or tz_8))) and not (tz_15 and not tz_15 and (tz_9 and tz_8) or not tz_8 and not tz_8 and (tz_14 or tz_15) or ((not tz_14 or tz_9) and (tz_15 and not tz_15) or tz_9 and not tz_8 and (not tz_15 or tz_8))) then
                    tz_14, tz_9 = pcall(fn1165)
                else
                    tz_9, tz_14 = pcall(fn1165)
                end
                tz_15 = (tz_15 + 15) % 16
            end
        until (tz_15 * 13 + 3) % 16 == 9
        if tz_8 then
            tz_9 = 1
            repeat
                tz_15 = (vector.create((tz_9 * 7 + 7) % 11 + 1, (tz_9 * 8 + 6) % 13 + 1, (tz_9 * 1 + 8) % 17 + 1))
                tz_4 = (vector.create((tz_9 * 1 + 8) % 11 + 1, (tz_9 * 9 + 9) % 13 + 1, (tz_9 * 1 + 1) % 17 + 1))
                tz_10 = (vector.create((tz_9 * 1 + 9) % 11 + 1, (tz_9 * 2 + 4) % 13 + 1, (tz_9 * 12 + 9) % 17 + 1))
                tz_16 = (vector.create((tz_9 * 1 + 2) % 11 + 1, (tz_9 * 3 + 1) % 13 + 1, (tz_9 * 6 + 6) % 17 + 1))
                if vector.dot(vector.cross(tz_15, tz_4), (vector.cross(tz_10, tz_16))) == vector.dot(tz_15, tz_10) * vector.dot(tz_4, tz_16) - vector.dot(tz_15, tz_16) * vector.dot(tz_4, tz_10) then
                    tz_8 = type(tz_14) == "number"
                else
                    tz_14 = type(tz_8) == "number"
                end
                tz_9 = (tz_9 + 0) % 4
            until (tz_9 * 1 + 0) % 4 == 1
        end
        if tz_8 then
            nJ = tz_14
        end
    end
    tz_9 = tz_13 and nm and nm.TbMainChallenge
    if tz_9 then
        tz_15, tz_14, tz_8 = nil, nil, nil
        tz_13 = 8
        repeat
            tz_9 = (tz_13 * 1 + 0) % 2 + 1
            if tz_9 <= 1 then
                tz_9 = {
                    "ixemoe",
                    "vqarp",
                    "agxnf",
                    "bwzpmqxohc",
                    "auhcxihlgfv",
                    "knldrxd",
                    "vymxzywpi",
                    "vizbxhehzs",
                    "iduysi"
                }
                local u6 = tz_13
                tz_4 = tz_9[u6 % 9 + 1]
                if tz_4:len() <= tz_4:gsub("(.)", "%1%1", u6 % 3 % 2 + 1):len() then
                    tz_15, tz_14 = pcall(fns.fn34)
                else
                    tz_14, tz_15 = pcall(fns.fn34)
                end
                tz_13 = (tz_13 + 1) % 16
            else
                tz_9 = { "gwceq", "smumdmwim", "qvovsfswo", "xygktdfnfb", "pxduxdylmfr", "ukn", "mnkgsu", "fqtghblix" }
                if tz_9[(tz_13 * 57 + 25) % 8 + 1] <= tz_9[(tz_13 * 57 + 25) % 8 + 1] then
                    tz_8 = tz_15
                else
                    tz_15 = tz_8
                end
                tz_13 = (tz_13 + 15) % 16
            end
        until (tz_13 * 13 + 7) % 16 == 15
        if tz_8 then
            tz_9 = 3
            repeat
                tz_15 = (vector.create((tz_9 * 5 + 6) % 11 + 1, (tz_9 * 8 + 8) % 13 + 1, (tz_9 * 2 + 17) % 17 + 1))
                tz_13 = (vector.create((tz_9 * 5 + 9) % 11 + 1, (tz_9 * 10 + 12) % 13 + 1, (tz_9 * 3 + 4) % 17 + 1))
                tz_4 = (vector.create((tz_9 * 6 + 5) % 11 + 1, (tz_9 * 5 + 11) % 13 + 1, (tz_9 * 1 + 3) % 17 + 1))
                tz_10 = (vector.create((tz_9 * 2 + 6) % 5 + 1, (tz_9 * 1 + 4) % 7 + 1, (tz_9 * 5 + 1) % 9 + 1))
                if vector.dot(vector.cross(tz_15, (vector.cross(tz_13, tz_4))), tz_10) == vector.dot(tz_13 * vector.dot(tz_15, tz_4) - tz_4 * vector.dot(tz_15, tz_13), tz_10) then
                    tz_8 = type(tz_14) == "table"
                else
                    tz_14 = type(tz_8) == "table"
                end
                tz_9 = (tz_9 + 0) % 4
            until (tz_9 * 3 + 3) % 4 == 0
        end
        if tz_8 then
            nD = #tz_14
        end
    end
end
TeleportTag, tz_15, tz_8, tz_13 = nil, nil, nil, nil
tz_9 = 7
repeat
    tz_14 = (tz_9 * 1 + 1) % 3 + 1
    if tz_14 <= 2 then
        if tz_14 <= 1 then
            tz_14 = {
                "pdsfms",
                "xuohhnzva",
                "qwvujpz",
                "bpcrclvgudhr",
                "phmdw",
                "rbafbul",
                "hntp",
                "ack",
                "rhiucxmpr",
                "jutqmfo",
                "zjjrofgrg",
                "ptubfra"
            }
            if tz_14[(tz_9 * 55 + 83) % 12 + 1] <= tz_14[(tz_9 * 55 + 83) % 12 + 1] then
                tz_15, tz_8 = pcall(require, tz_11.common.util["tag-util"])
            else
                tz_11, tz_15 = pcall(require, tz_8.common.util["tag-util"])
            end
            tz_9 = (tz_9 + 7) % 24
        else
            tz_14 = {
                "vccnljkbj",
                "lfyasvsccxop",
                "xfowqzt",
                "aawaaunn",
                "vjximhqckbiy",
                "woqqg",
                "yyesathfod",
                "lkt",
                "jbpzw",
                "xkg",
                "gksvzkpeaz",
                "ogv",
                "irunyjrrdj",
                "egqdmey"
            }
            if tz_14[(tz_9 * 73 + 7) % 14 + 1] < tz_14[(tz_9 * 73 + 7) % 14 + 1] then
                tz_15 = tz_13
            else
                tz_13 = tz_15
            end
            tz_9 = (tz_9 + 19) % 24
        end
    else
        tz_14 = (vector.create((tz_9 * 6 + 8) % 11 + 1, (tz_9 * 2 + 10) % 13 + 1, (tz_9 * 15 + 8) % 17 + 1))
        tz_4 = (vector.create((tz_9 * 6 + 1) % 11 + 1, (tz_9 * 6 + 6) % 13 + 1, (tz_9 * 12 + 16) % 17 + 1))
        local uD = vector.dot(tz_14, tz_4)
        if uD * uD <= vector.dot(tz_14, tz_14) * vector.dot(tz_4, tz_4) then
            TeleportTag = nil
        else
            tz_15 = nil
        end
        tz_9 = (tz_9 + 19) % 24
    end
until (tz_9 * 11 + 11) % 24 == 7
if tz_13 then
    tz_9 = 0
    repeat
        if (tz_9 * 2 + 6) * 7 % 3 == ((tz_9 * 2 + 6) * 7 + 0) % 3 then
            tz_13 = typeof(tz_8) == "table"
        else
            tz_8 = typeof(tz_13) == "table"
        end
        tz_9 = (tz_9 + 0) % 4
    until (tz_9 * 3 + 0) % 4 == 0
end
if tz_13 then
    tz_9 = 0
    repeat
        if (tz_9 * 1 + 3) * 17 % 4 == ((tz_9 * 1 + 3) * 17 + 12) % 4 then
            tz_13 = type(tz_8.TeleportTag) == "string"
        else
            tz_8 = type(tz_13.TeleportTag) == "string"
        end
        tz_9 = (tz_9 + 3) % 4
    until (tz_9 * 3 + 0) % 4 == 1
end
if tz_13 then
    TeleportTag = tz_8.TeleportTag
end
if setthreadidentity then
    setthreadidentity(8)
end
container, ns, np, nN, nG, m4, connection, mO, no, nl, tz_10, mK, n_, nW, nR, nK, nE, ny, nw, nc, Label, mR, tz_4, nn, m3, mV, mL, nX, nF, nt, nd, nA, mX, nH, mT, mI, nC, nj, nb, m6, na, m0 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
container = tz_11.rbxts_include.node_modules["@rbxts"].remo.src.container
tz_14 = fn674
ns = {
    staticReaperReq = tz_14("staticReaperReq"),
    startTimeLimitChallengeReq = tz_14("startTimeLimitChallengeReq"),
    timeLimitChallengeResult = tz_14("timeLimitChallengeResult")
}
np = { rebirth = tz_14("rebirth"), equipTitle = tz_14("EquipTitle") }
nn = function(as)
    local o2
    local o4_1
    local o3_1, o3_2
    if type(as) ~= "function" then
        return nil
    end
    o3_1, o2 = pcall(function()
        return as()
    end)
    if not o3_1 then
        return nil
    elseif type(o2) ~= "function" then
        return o2
    else
        o3_2, o4_1 = pcall(function()
            return o2()
        end)
        return o3_2 and o4_1 or nil
    end
end
m3 = fn557
mV = fn623
mL = fn811
nX = fn515
nF = fns.fn160
nt = fn864
nd = fn564
nN = {}
nG = 0
nA = fn1161
mX = fns.fn450
nH = fn1013
m4 = nil
connection = ns.timeLimitChallengeResult.OnClientEvent:Connect(onOnClientEvent)
mT = fn518
if (nF and not mV or not nF and nF) and (not mV and nF or not nF and not mV) and not ((nF and not mV or not nF and nF) and (not mV and nF or not nF and not mV)) then
    nC = { [2] = true, [5] = true, [7] = true, [3] = true, [8] = true, [1] = true, [6] = true }
    mO = fn965
    pcall(fn1152)
    mI = fn1053
else
    mO = { [1] = true, [2] = true, [3] = true, [5] = true, [6] = true, [7] = true, [8] = true }
    mI = fn965
    pcall(fn1152)
    nC = fn1053
end
no = "https://discord.gg/K7Qxnxkk46"
nl = "https://discord.gg/K7Qxnxkk46"
nj = fns.fn171
nb = fn600
m6 = fn908
tz_16 = "#7fd47f"
if ((not m3 or (not mR or m3)) and ((not connection or tz_4) and (not mR)) or (connection or not m3 or (tz_4 or not connection)) and (not connection or (not mR or 216))) and not ((not m3 or (not mR or m3)) and ((not connection or tz_4) and (not mR)) or (connection or not m3 or (tz_4 or not connection)) and (not connection or (not mR or 216))) then
    nj = "#6ec1ff"
else
    tz_10 = "#6ec1ff"
end
mK = "#e8a34d"
local oy = "#8b93a3"
n_ = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
nW = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
nR = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
nK = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
nE = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
ny = ""
nw = ""
local op = "#345d9d"
local on = "#f7931a"
local om = "#627eea"
local ol = "#26a17b"
local oj = "#14f195"
local tz_2 = "#0070ba"
local tz_12 = "#008cff"
na = fns.fn62
m0 = fn1127
tz_9 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = no, Copyable = true }, "|", tz_7 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
pcall(fn506)
local ox = {
    Info = tz_9:AddTab("Info", "info"),
    Farming = tz_9:AddTab("Farming", "swords"),
    Bosses = tz_9:AddTab("Bosses", "skull"),
    Rebirth = tz_9:AddTab("Rebirth", "refresh-cw"),
    Player = tz_9:AddTab("Player", "person-standing"),
    Settings = tz_9:AddTab("Settings", "settings")
}
local ow = ox.Bosses:AddSubTab("Reaper", "skull")
local ov = ox.Bosses:AddSubTab("Cursed King", "timer")
local ou = ox.Bosses:AddSubTab("Death King", "flame")
local ot = ox.Bosses:AddSubTab("Death Tower", "landmark")
local oq = ox.Rebirth:AddSubTab("Rebirth Loop", "repeat")
local oo = ox.Rebirth:AddSubTab("Titles", "star")
tz_8 = fns.fn316
tz_8(ox.Info)
tz_8(ox.Farming)
tz_8(ox.Player)
tz_8(ox.Settings)
tz_8(ow)
tz_8(ov)
tz_8(ou)
tz_8(ot)
tz_8(oq)
tz_8(oo)
nc = "Unknown"
pcall(fns.fn320)
tz_15 = ox.Info:AddLeftGroupbox("Account", "circle-user")
tz_15:AddLabel(m6("User", tz_5.Name, tz_16), true)
tz_15:AddLabel(m6("Status", "Keyless", tz_16), true)
tz_15:AddLabel(m6("Executor", nc, tz_16), true)
local GameInfoGroup = ox.Info:AddLeftGroupbox("Game Info", "gamepad-2")
GameInfoGroup:AddLabel(nb(tz_7 .. " [" .. tostring(game.PlaceId) .. "]", tz_10), true)
GameInfoGroup:AddLabel(m6("Place ID", tostring(game.PlaceId), tz_10), true)
Label = GameInfoGroup:AddLabel(m6("Session time", "0s", mK), true)
mR = tostring(game.JobId)
tz_4 = #mR > 18
if tz_4 then
    tz_9 = 1
    repeat
        tz_15 = {
            "mfnzqmtomm",
            "dnthwcbtfn",
            "wnomjqc",
            "oyotxdpvpt",
            "wktvjm",
            "pncxwz",
            "pujotr",
            "qkbhxm",
            "hchvmogxlfq",
            "gysiasbueql",
            "aljwbvorrqc",
            "shdk"
        }
        local ul = tz_9
        tz_5 = tz_15[ul % 12 + 1]
        if tz_5:len() <= tz_5:reverse():rep(ul % 3 + 2):len() then
            tz_4 = string.sub(mR, 1, 18) .. "..."
        else
            mR = string.sub(tz_4, 1, 18) .. "..."
        end
        tz_9 = (tz_9 + 3) % 4
    until (tz_9 * 3 + 2) % 4 == 2
end
tz_9 = tz_4 or mR
nS, Options, Toggles, n0, m7, m2, connection2, connection3, mS, mQ, mU, nz, m9, mP, nh, mZ, mM, nf, m8, mN, nY, ni, m1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
tz_15 = tz_9
GameInfoGroup:AddLabel(m6("Server", tz_15, oy), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
nS = os.clock()
task.spawn(worker)
local ScriptsGroup = ox.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(nb("Included in this hub", oy), true)
ScriptsGroup:AddLabel(nb(tz_7, tz_10), true)
local FeaturesGroup = ox.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(nb("Auto Stage Progression", tz_10), true)
FeaturesGroup:AddLabel(nb("Auto Bosses and Tower", mK), true)
FeaturesGroup:AddLabel(nb("Auto Rebirth and Titles", tz_16), true)
local SocialsGroup = ox.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = nj })
SocialsGroup:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
tz_13 = ox.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
tz_13:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
tz_13:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
tz_13:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
tz_13:AddButton({ Text = "Copy Discord Invite", Func = nj })
tz_5 = ox.Info:AddRightGroupbox("Donations", "heart")
tz_5:AddLabel(nb("All donations are optional but appreciated.", mK), true)
tz_5:AddLabel(nb("If you donate you get a special role, just PING after you donate.", tz_16), true)
tz_5:AddDivider()
tz_5:AddLabel(nb("LTC / Litecoin", op), true)
tz_5:AddButton({ Text = "Copy Litecoin Address", Func = fns.onCopyLitecoinAddress })
tz_5:AddLabel(nb("BTC / Bitcoin", on), true)
tz_5:AddButton({ Text = "Copy Bitcoin Address", Func = fns.onCopyBitcoinAddress })
tz_5:AddLabel(nb("ETH / Ethereum", om), true)
tz_5:AddButton({ Text = "Copy Ethereum Address", Func = fns.onCopyEthereumAddress })
tz_5:AddLabel(nb("USDT", ol), true)
tz_5:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
tz_5:AddLabel(nb("Solana", oj), true)
tz_5:AddButton({ Text = "Copy Solana Address", Func = fns.onCopySolanaAddress })
tz_5:AddLabel(nb("PayPal", tz_2), true)
tz_5:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
tz_5:AddLabel(nb("Venmo", tz_12), true)
tz_5:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
tz_5:AddDivider()
tz_5:AddLabel(nb("Don't have any of the listed currencies but still wanna donate?", oy), true)
tz_5:AddLabel(nb("DM me and we'll work something out.", tz_10), true)
local FaqGroup = ox.Info:AddRightGroupbox("FAQ", "circle-help")
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
local StageProgressionGroup = ox.Farming:AddLeftGroupbox("Stage Progression", "route")
StageProgressionGroup:AddToggle("Stages", { Text = "Auto Progress Stages", Default = false })
StageProgressionGroup:AddSlider("StagesInterval", { Text = "Interval", Default = 2, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
local ReaperGroup = ow:AddLeftGroupbox("Reaper", "skull")
ReaperGroup:AddToggle("ReaperTP", { Text = "Auto TP to Reaper Off Cooldown", Default = false })
ReaperGroup:AddSlider("ReaperInterval", { Text = "Check Interval", Default = 2, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
local CursedKing_GreenDragonGroup = ov:AddLeftGroupbox("Cursed King (Green Dragon)", "timer")
CursedKing_GreenDragonGroup:AddToggle("CursedKing", { Text = "Auto Attempt Cursed King Until Fail", Default = false })
CursedKing_GreenDragonGroup:AddSlider("CursedInterval", { Text = "Retry Interval", Default = 30, Min = 1, Max = 120, Rounding = 0, Suffix = "s" })
CursedKing_GreenDragonGroup:AddDropdown("CursedLevelAdd", { Text = "Level Add", Values = { "Add1", "Add5", "Add10", "Add50" }, Default = "Add1" })
local DeathKing_RedDragonGroup = ou:AddLeftGroupbox("Death King (Red Dragon)", "flame")
DeathKing_RedDragonGroup:AddToggle("DeathKing", { Text = "Auto Attempt Death King Until Fail", Default = false })
DeathKing_RedDragonGroup:AddSlider("DeathInterval", { Text = "Retry Interval", Default = 30, Min = 1, Max = 120, Rounding = 0, Suffix = "s" })
DeathKing_RedDragonGroup:AddDropdown("DeathLevelAdd", { Text = "Level Add", Values = { "Add1", "Add5", "Add10", "Add50" }, Default = "Add1" })
local DeathTowerGroup = ot:AddLeftGroupbox("Death Tower", "landmark")
DeathTowerGroup:AddToggle("Tower", { Text = "Auto Progress Death Tower", Default = false })
DeathTowerGroup:AddSlider("TowerInterval", { Text = "Retry Interval", Default = 30, Min = 1, Max = 120, Rounding = 0, Suffix = "s" })
DeathTowerGroup:AddDropdown("TowerLevelAdd", { Text = "Level Add", Values = { "Add1", "Add5", "Add10", "Add50" }, Default = "Add1" })
local AutoRebirthGroup = oq:AddLeftGroupbox("Auto Rebirth", "repeat")
AutoRebirthGroup:AddToggle("Rebirth", { Text = "Auto Rebirth", Default = false })
AutoRebirthGroup:AddSlider("RebirthInterval", { Text = "Check Interval", Default = 2, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
tz_4 = oo:AddLeftGroupbox("Auto Title", "star")
tz_4:AddToggle("BestTitle", { Text = "Auto Equip Best Title", Default = false })
tz_4:AddSlider("TitleInterval", { Text = "Check Interval", Default = 3, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
tz_14 = ox.Player:AddLeftGroupbox("Movement", "footprints")
tz_14:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
tz_14:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
tz_14:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
tz_14:AddToggle("NoClip", { Text = "NoClip", Default = false })
tz_14:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
tz_8 = ox.Player:AddRightGroupbox("Fly", "feather")
tz_8:AddToggle("Fly", { Text = "Fly", Default = false })
tz_8:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
m9 = function(dO)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not dO)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not dO
        end
    end)
    if not dO then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(nk, "GameplayPaused", false)
        else
            nk.GameplayPaused = false
        end
    end)
end
Options = Library.Options
Toggles = Library.Toggles
Toggles.AntiGameplayPause:OnChanged(fn458)
Toggles.Fly:OnChanged(fns.fn425)
Toggles.WalkSpeedEnabled:OnChanged(fn721)
RunService.Stepped:Connect(fns.onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
n0 = Workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
tz_11 = ox.Settings:AddLeftGroupbox("Menu")
tz_11:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
m7 = tick()
m2 = tick()
pcall(function()
    for i, v in ipairs(getconnections(nk.Idled)) do
        local rj = v
        pcall(function()
            rj:Disable()
        end)
    end
end)
mP = fns.fn390
connection2 = UserInputService.InputBegan:Connect(fns.onInputBegan)
connection3 = UserInputService.InputChanged:Connect(onInputChanged)
tz_11:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
tz_11:AddButton({ Text = "Unload", Func = fns.onUnload })
tz_3:SetLibrary(Library)
tz_3:SetFolder("TempoHub")
tz_3:SaveDefault("Evil Hello Kitty")
tz_3:ApplyToTab(ox.Settings)
tz_3:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/InfiniteReal")
local oD = SaveManager:BuildConfigSection(ox.Settings)
nh = fn1133
mZ = fn652
mM = fn1112
nf = function(fk)
    local rX
    rX = nil
    local rY = type(fk) ~= "table" or type(fk.idx) ~= "string" or type(fk.type) ~= "string" or SaveManager.Ignore[fk.idx]
    if rY then
        return false
    end
    rX = nh(fk.type, fk.idx)
    if not rX then
        return false
    end
    local rY_1 = pcall(function()
        if fk.type == "Input" then
            if type(fk.text) ~= "string" then
                return
            end
            rX:SetValue(fk.text)
        elseif fk.type == "ColorPicker" then
            rX:SetValueRGB(Color3.fromHex(fk.value), fk.transparency)
        elseif fk.type == "KeyPicker" then
            rX:SetValue({ fk.key, fk.mode, fk.modifiers })
            if fk.mode == "Toggle" and fk.toggled ~= nil then
                rX.Toggled = fk.toggled
                rX:Update()
            end
        else
            rX:SetValue(fk.value)
        end
    end)
    return rY_1
end
oD:AddDivider()
oD:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
oD:AddButton("Export Config to Clipboard", fns.onExportConfigToClipboard)
oD:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
m8 = fns.fn89
mS = false
mQ = 0
mN = fns.fn272
nY = fn620
local function oL(fZ)
    task.spawn(function()
        local sn_1
        local sm_1
        setthreadidentity(8)
        while m8() do
            sm_1, sn_1 = pcall(fZ)
            local so = not sm_1
            if so ~= false then
                so = m8()
            end
            if so then
                warn("[TempoHub] loop error: " .. tostring(sn_1))
                task.wait(1)
            end
        end
    end)
end
ni = fns.fn346
m1 = function(gd, ge)
    local sD_1
    local sC_1
    sC_1, sD_1 = pcall(function()
        local sw_5
        local su_1, su_6, su_7
        if mI() then
            return false
        end
        local sB = if not ni(6) then 1 else 0
        if sB == 1 then
            return false
        end
        if gd == 3 then
            su_1 = nH()
        else
            local sw_1 = gd == 2 and "GreenDragon" or "RedDragon"
            su_1 = mX(sw_1)
        end
        if not su_1 then
            return false
        end
        local su_2 = os.clock()
        while true do
            if not (os.clock() - su_2 < 4) then
                local sB_1 = if not mT() then 1 else 0
                if sB_1 == 1 then
                    return false
                end
                task.wait(0.4)
                m4 = nil
                ns.startTimeLimitChallengeReq:FireServer(gd, ge)
                os.clock()
                local sv_2 = false
                while true do
                    if not (os.clock() - su_6 < 12) then
                        if m4 == nil then
                            return false
                        end
                        os.clock()
                        while true do
                            if not (os.clock() - su_7 < 100) then
                                return m4 == true
                            end
                            if not m8() then
                                return false
                            end
                            if m4 ~= nil then
                                return m4
                            end
                            local sw_3 = sv_2 and mT()
                            task.wait(0.5)
                        end
                        return false
                    end
                    if not m8() then
                        break
                    end
                    if not mT() then
                        os.clock()
                        while true do
                            if not (os.clock() - su_7 < 100) then
                                return m4 == true
                            end
                            if not m8() then
                                return false
                            end
                            if m4 ~= nil then
                                return m4
                            end
                            mT()
                            if sw_5 then
                                break
                            end
                            task.wait(0.5)
                        end
                        return false
                    end
                    if m4 ~= nil then
                        return false
                    end
                    task.wait(0.2)
                end
                return false
            end
            if not m8() then
                break
            end
            if mT() then
                local sB_2 = if not mT() then 1 else 0
                if sB_2 == 1 then
                    return false
                end
                task.wait(0.4)
                m4 = nil
                ns.startTimeLimitChallengeReq:FireServer(gd, ge)
                su_6 = os.clock()
                while true do
                    if not (os.clock() - su_6 < 12) then
                        return false
                    end
                    if not m8() then
                        break
                    end
                    if not mT() then
                        su_7 = os.clock()
                        while true do
                            if not (os.clock() - su_7 < 100) then
                                return m4 == true
                            end
                            if not m8() then
                                return false
                            end
                            if m4 ~= nil then
                                return m4
                            end
                            sw_5 = mT()
                            if sw_5 then
                                break
                            end
                            task.wait(0.5)
                        end
                        return false
                    end
                    if m4 ~= nil then
                        return false
                    end
                    task.wait(0.2)
                end
                return false
            end
            task.wait(0.2)
        end
        return false
    end)
    if not sC_1 then
        warn("[TempoHub] attempt error: " .. tostring(sD_1))
        return false
    end
    return sD_1
end
mU = { Add1 = 0, Add5 = 1, Add10 = 2, Add50 = 3 }
oL(fn822)
oL(fn548)
oL(fn1103)
oL(fn1002)
oL(fn987)
nz = 0
oL(fns.fn192)
oL(fn1111)
oL(fns.fn194)
task.spawn(fns.antiAfkLoop)
Library:OnUnload(fn966)
local oM = getgenv().STATE
if not oM then
    tz_9 = getfenv() and getfenv().STATE
    oM = tz_9
end
tz_11 = oM
tz_5 = type(tz_11) == "table" and tz_11.onCleanup
if tz_5 then
    tz_11.onCleanup(function()
        if ng.TempoHub_Library then
            pcall(function()
                ng.TempoHub_Library:Unload()
            end)
        end
    end)
end
Library:Notify("+1 DMG Per Revive loaded")
end)(...)

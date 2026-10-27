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
getgenv().TempoHoodSubtitle = "ROLL A SORCERER"
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
local kf
local kC
local ki
local kF
local jX
local kl
local kr
local BoostUpgradeConfig
local j8
local kR
local kb
local ky
local jQ
local ke
local kh
local jW
local kk
local j1
local j4
local kN
local kt
local kQ
local LuckyBlockConfig
local ka
local kx
local kA
local kd
local jV
local kD
local Toggles
local kG
local j0
local kJ
local Library
local j3
local kM
local j6
local ks
local j9
local Options
local kz
local function fn17()
    local lN = j6:FindFirstChild("Map") and j6.Map:FindFirstChild("Bases")
    if not lN then
        return nil
    end
    local lN_1 = lN:FindFirstChild(j3.Name)
    if lN_1 then
        return lN_1
    end
    for i, child in lN:GetChildren() do
        local lN_2 = child:GetAttribute("OwnerUserId") == j3.UserId or child:GetAttribute("Owner") == j3.Name
        if lN_2 then
            return child
        end
    end
    return nil
end
local function fn43()
    local lJ = tonumber(j3:GetAttribute("Cash")) or 0
    return lJ
end
local function fn96()
    Library.ScreenGui.Parent = kd
end
local function fn122()
    local lL = tonumber(j3:GetAttribute("Rebirth")) or 0
    return lL
end
local function fn140()
    local n2 = if not ki("AutoCollectMoney") then 1 else 0
    if n2 == 1 then
        return
    end
    if tick() - kG < 0.75 then
        return
    end
    kG = tick()
    kR()
end
local function fn218(dv)
    local DiscordGroup = dv:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = j9 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = j9 })
end
local function fn265()
    local Character = j3.Character
    local lE = Character and Character:FindFirstChildOfClass("Humanoid")
    return lE
end
local function worker()
    while not Library.Unloaded do
        pcall(kb)
        pcall(jQ)
        pcall(kt)
        pcall(j0)
        pcall(kA)
        pcall(j8)
        task.wait(0.2)
    end
end
local function fn291(aV)
    local LuckyStock = j3:FindFirstChild("LuckyStock")
    local lX = LuckyStock and LuckyStock:FindFirstChild(aV)
    local lW_1 = lX
    if lX then
        lX = lW_1:IsA("ValueBase")
    end
    if lX then
        local lX_1 = tonumber(lW_1.Value) or 0
        return lX_1
    end
    return 0
end
local function fn299()
    kr(kz, "Copied Discord invite to clipboard")
end
local function fn314(an, ao)
    return string.format('<font color="%s">%s</font>', ao, an)
end
local function fn358()
    local m1 = jW()
    local m2 = ky()
    if not m1 or not m2 then
        return
    end
    local Slots = m1:FindFirstChild("Slots")
    if not Slots then
        return
    end
    for i, child in Slots:GetChildren() do
        if child:GetAttribute("Occupied") == true then
            local Button = child:FindFirstChild("Button")
            local m3_2 = Button and Button:FindFirstChild("MainButton")
            local m1_2 = m3_2
            if m3_2 then
                m3_2 = m1_2:IsA("BasePart")
            end
            if m3_2 then
                m3_2 = firetouchinterest
            end
            if m3_2 then
                pcall(firetouchinterest, m2, m1_2, 0)
                task.wait()
                pcall(firetouchinterest, m2, m1_2, 1)
            end
        end
    end
end
local function fn391(I, J)
    if I.cost == J.cost then
        return I.name < J.name
    end
    return I.cost < J.cost
end
local function fn401()
    local n4 = hookfunction ~= nil
    local n5 = hookmetamethod ~= nil
    local n6 = getrawmetatable ~= nil
    local n7 = setrawmetatable ~= nil
    local n8 = getgc ~= nil
    local n9 = getgenv ~= nil
    local oa = getreg ~= nil
    local ob = getconnections ~= nil
    local oc = firesignal ~= nil
    local od = getcallbackvalue ~= nil
    local oe = setclipboard ~= nil
    local of = getcustomasset ~= nil
    local og = getnamecallmethod ~= nil
    local oh = isexecutorclosure ~= nil
    local oi = fireproximityprompt ~= nil
    local oj = firetouchinterest ~= nil
    local ol = WebSocket ~= nil
    local om = readfile ~= nil
    local oo = writefile ~= nil
    local oq = (request or http_request) ~= nil
    local ou = (debug and debug.getupvalues) ~= nil
    local ow = (debug and debug.setupvalue) ~= nil
    local ox = 0
    local oy = { n4, n5, n6, n7, n8, n9, oa, ob, oc, od, oe, of, og, oh, oi, oj, ol, om, oo, oq, ou, ow }
    for k, v in oy do
        if v then
            ox += 1
        end
    end
    local n4_1 = ox / #oy
    if n4_1 >= 0.9 then
        return jV("Full Support", kk)
    elseif n4_1 >= 0.6 then
        return jV("Half Support", ka)
    else
        return jV("Low Support", j1)
    end
end
local function fn407()
    local mo = Options.LuckyBlockType and Options.LuckyBlockType.Value
    if type(mo) ~= "table" then
        return nil
    end
    local mo_1 = false
    local mq = {}
    for k, v in mo do
        local mp_1 = v == true and type(k) == "string" and LuckyBlockConfig.LuckyBlocks[k]
        if mp_1 then
            mq[k] = true
            mo_1 = true
        end
    end
    if not mo_1 then
        return nil
    end
    return mq
end
local function fn408()
    if not ki("AutoSpin") then
        return
    end
    if j3:GetAttribute("Rolling") == true then
        pcall(function()
            jX.RewardCharacter:Fire()
        end)
        return
    end
    local nK = ks()
    if not nK then
        return
    end
    kD(nK)
end
local function fn409(ad)
    if ad then
        kQ[#kQ + 1] = ad
    end
    return ad
end
local function fn447(av)
    local lA = Toggles[av]
    return lA ~= nil and lA.Value == true
end
local function fn489()
    local Character = j3.Character
    local lH = Character and Character:FindFirstChild("HumanoidRootPart")
    return lH
end
local function fn490()
    if not ki("AutoBuyLuckyBlock") then
        return
    end
    local nM = kh()
    if not nM then
        return
    end
    for k, v in kJ do
        local nN = nM[v] and kl(v)
        if nN then
            return
        end
    end
end
local function fn501(bX)
    local mK = LuckyBlockConfig.LuckyBlocks[bX]
    if not mK then
        return false
    end
    local mL = j4()
    local mM = tonumber(mK.RequiredRebirth) or 0
    if mL < mM then
        return false
    elseif ke(bX) <= 0 then
        return false
    else
        local mL_1 = kf()
        local mM_1 = tonumber(mK.Cost) or math.huge
        return mL_1 >= mM_1
    end
end
local function fn535(ag, ah)
    if setclipboard then
        setclipboard(ag)
    elseif toclipboard then
        toclipboard(ag)
    end
    Library:Notify(ah)
end
local function fn582()
    local l8 = kF()
    local l9 = -1
    local ma
    for k, v in l8 do
        if v > 0 then
            local l8_1 = kC[k] or 0
            if l8_1 > l9 or l8_1 == l9 and (ma == nil or k < ma) then
                l9 = l8_1
                ma = k
            end
        end
    end
    return ma
end
local function fn615(aq, ar, as)
    return string.format("<b>%s</b> %s %s", aq, jV("-", "#5a6070"), jV(ar, as))
end
local function fn644()
    local nZ = if not ki("AutoEquipBest") then 1 else 0
    if nZ == 1 then
        return
    end
    if tick() - kN < 2 then
        return
    end
    kN = tick()
    pcall(function()
        jX.EquipBestCharacter:Fire()
    end)
end
local function fn718()
    if ki("AutoUseBestOwnedLuckyBlock") then
        return kx()
    end
    local my = kh()
    if not my then
        return nil
    end
    local mz = kF()
    local mA = -1
    local mB
    for k in my do
        if (mz[k] or 0) > 0 then
            local my_2 = kC[k] or 0
            if my_2 > mA or my_2 == mA and (mB == nil or k < mB) then
                mA = my_2
                mB = k
            end
        end
    end
    return mB
end
local function fn747()
    local ni = Options.UpgradeTypes and Options.UpgradeTypes.Value
    if type(ni) ~= "table" then
        return nil
    end
    local ni_1 = false
    local nk = {}
    for k, v in ni do
        if v == true then
            local nj_1 = kM[k] or k
            if BoostUpgradeConfig.Upgrades[nj_1] then
                nk[nj_1] = true
                ni_1 = true
            end
        end
    end
    if not ni_1 then
        return nil
    end
    return nk
end
local function fn758()
    if not ki("AutoRebirth") then
        return
    end
    if j3:GetAttribute("CanRebirth") ~= true then
        return
    end
    pcall(function()
        jX.Rebirth:Fire()
    end)
end
LuckyBlockConfig = nil
jQ = nil
Options = nil
local jT
jV = nil
jW = nil
jX = nil
Toggles = nil
j0 = nil
j1 = nil
j3 = nil
j4 = nil
j6 = nil
j8 = nil
j9 = nil
ka = nil
kb = nil
kd = nil
ke = nil
kf = nil
kh = nil
ki = nil
kk = nil
kl = nil
Library = nil
kr = nil
ks = nil
kt = nil
kx = nil
ky = nil
kz = nil
kA = nil
local jO, jS, jU, jZ, j_, SaveManager, j5, j7, kc, kg, kj, kn, GuiService, kp, kq, kv, kw, kB
kC = nil
kD = nil
kF = nil
kG = nil
kJ = nil
kM = nil
kN = nil
BoostUpgradeConfig = nil
kQ = nil
kR = nil
local kE, kH, kI, kK, kL, kP
local kU_1, kU_3
local PlayerGui
jO, kU_1, kI, kB, kw, kq, GuiService, kj, kd, j6, j3, PlayerGui = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local kT = 8
local kT_1, kT_5
repeat
    local kV_1 = (kT * 2 + 3) % 5 + 1
    if kV_1 <= 3 then
        if kV_1 <= 2 then
            if kV_1 <= 1 then
                if ((kT and not jO or GuiService and not kT) and (GuiService and not jO or (GuiService or not GuiService)) or (not GuiService and not GuiService or not GuiService and jO) and (not kT or not kT or kT and not jO)) and not ((kT and not jO or GuiService and not kT) and (GuiService and not jO or (GuiService or not GuiService)) or (not GuiService and not GuiService or not GuiService and jO) and (not kT or not kT or kT and not jO)) then
                    kw = game:GetService("ReplicatedStorage")
                    kU_1 = game:GetService("RunService")
                    kq = game:GetService("UserInputService")
                    kI = game:GetService("VirtualUser")
                    kB = game:GetService("HttpService")
                else
                    kU_1 = game:GetService("ReplicatedStorage")
                    kI = game:GetService("RunService")
                    kB = game:GetService("UserInputService")
                    kw = game:GetService("VirtualUser")
                    kq = game:GetService("HttpService")
                end
                kT = (kT + 33) % 40
            else
                if (not jO or not jO) and (not j6 or kB) or (kB or kT) and (kB and not j6) or not ((not jO or not jO) and (not j6 or kB) or (kB or kT) and (kB and not j6)) then
                    GuiService = game:GetService("GuiService")
                else
                    kd = game:GetService("GuiService")
                end
                kT = (kT + 13) % 40
            end
        else
            if kT * 4088451 + 1 + 4 >= kT * 4088451 + 1 + 4 + 3 then
                j6 = game:GetService("TeleportService")
                kj = game:GetService("CoreGui")
                kd = game:GetService("Workspace")
            else
                kj = game:GetService("TeleportService")
                kd = game:GetService("CoreGui")
                j6 = game:GetService("Workspace")
            end
            kT = (kT + 18) % 40
        end
    elseif kV_1 <= 4 then
        if (kT * 3 + 7) * 9 % 4 == ((kT * 3 + 7) * 9 + 10) % 4 then
            jO = PlayerGui.LocalPlayer
            j3 = jO:WaitForChild("PlayerGui")
        else
            j3 = jO.LocalPlayer
            PlayerGui = j3:WaitForChild("PlayerGui")
        end
        kT = (kT + 3) % 40
    else
        local r0 = bit32.rrotate(bit32.bxor(bit32.lrotate(kT, 1), string.byte(tostring(j6))), 17)
        if bit32.bxor(bit32.lrotate(bit32.bxor(r0, 724531216), 12), 4152427186) == bit32.lrotate(r0, 12) then
            jO = game:GetService("Players")
        else
            j3 = game:GetService("Players")
        end
        kT = (kT + 3) % 40
    end
until (kT * 13 + 30) % 40 == 4
if getgenv then
    jT, kT_1 = nil, nil
    local kS_2 = 12
    repeat
        if (kS_2 * 1 + 1) % 2 + 1 <= 1 then
            local kV_3 = {
                "dkmtxxz",
                "tfjj",
                "fwlrwewohqui",
                "lvsail",
                "dzqraj",
                "glhxey",
                "vne",
                "spukvbbhcecp",
                "alwzqvwhcspx",
                "hgtfefkstynf",
                "digctrcc",
                "cbqismsav",
                "hubqmmynkb"
            }
            if kV_3[(kS_2 * 80 + 8) % 13 + 1] < kV_3[(kS_2 * 80 + 8) % 13 + 1] then
                jT = kT_1
            else
                kT_1 = jT
            end
            kS_2 = (kS_2 + 3) % 16
        else
            if kS_2 * 91975071 + 11 + 3 <= kS_2 * 91975071 + 11 + 3 + 1 then
                jT = getgenv().__TempoRollASorcererLib
            else
                kT_1 = getgenv().__TempoRollASorcererLib
            end
            kS_2 = (kS_2 + 3) % 16
        end
    until (kS_2 * 11 + 7) % 16 == 13
    if kT_1 then
        kT_1 = jT.Unload
    end
    if kT_1 then
        pcall(function()
            jT:Unload()
        end)
    end
end
if setthreadidentity then
    setthreadidentity(8)
end
kE, kz, kv, kp, kk, kg, ka, j5, j1, jX, LuckyBlockConfig, BoostUpgradeConfig, kJ, kC = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local kS_3 = 42
repeat
    local kT_2 = (kS_3 * 5 + 1) % 6 + 1
    if kT_2 <= 3 then
        if kT_2 <= 2 then
            if kT_2 <= 1 then
                if kS_3 * 133672317 + 5 + 7 <= kS_3 * 133672317 + 5 + 7 + 1 then
                    kJ = {}
                    kC = {}
                else
                    kC = {}
                    kJ = {}
                end
                kS_3 = (kS_3 + 5) % 48
            else
                local kV_4 = (vector.create((kS_3 * 7 + 1) % 11 + 1, (kS_3 * 2 + 6) % 13 + 1, (kS_3 * 3 + 6) % 17 + 1))
                local kW_1 = (vector.create((kS_3 * 1 + 2) % 11 + 1, (kS_3 * 1 + 7) % 13 + 1, (kS_3 * 13 + 17) % 17 + 1))
                local rR = vector.cross(kV_4, kW_1)
                local rS = vector.dot(kV_4, kW_1)
                if vector.dot(rR, rR) + rS * rS == vector.dot(kV_4, kV_4) * vector.dot(kW_1, kW_1) then
                    kE = "Roll a Sorcerer"
                    kz = "https://discord.gg/K7Qxnxkk46"
                    kv = "https://discord.gg/K7Qxnxkk46"
                else
                    kv = "Roll a Sorcerer"
                    kE = "https://discord.gg/K7Qxnxkk46"
                    kz = "https://discord.gg/K7Qxnxkk46"
                end
                kS_3 = (kS_3 + 29) % 48
            end
        else
            local r7 = bit32.rrotate(bit32.bxor(bit32.lrotate(kS_3, 22), string.byte(tostring(j1))), 11)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(r7, 3377954531), 756605839), (bit32.bxor(bit32.band(r7, 917012764), 1233238255))), 756605839), 1233238255) ~= r7 then
                kk = "https://tempohub.shop"
                kp = "#7fd47f"
            else
                kp = "https://tempohub.shop"
                kk = "#7fd47f"
            end
            kS_3 = (kS_3 + 47) % 48
        end
    elseif kT_2 <= 5 then
        if kT_2 <= 4 then
            if kS_3 * 38813779 + 10 + 4 >= kS_3 * 38813779 + 10 + 4 + 1 then
                j5 = "#6ec1ff"
                kg = "#e8a34d"
                ka = "#8b93a3"
            else
                kg = "#6ec1ff"
                ka = "#e8a34d"
                j5 = "#8b93a3"
            end
            kS_3 = (kS_3 + 23) % 48
        else
            local kT_3 = (vector.create((kS_3 * 6 + 5) % 11 + 1, (kS_3 * 1 + 4) % 13 + 1, (kS_3 * 14 + 5) % 17 + 1))
            local kV_5 = (vector.create((kS_3 * 5 + 2) % 11 + 1, (kS_3 * 1 + 5) % 13 + 1, (kS_3 * 10 + 2) % 17 + 1))
            local rc = vector.dot(kT_3, kV_5)
            if rc * rc >= vector.dot(kT_3, kT_3) * vector.dot(kV_5, kV_5) + 1 then
                kU_1 = "#e05a5a"
                j1 = require(LuckyBlockConfig:WaitForChild("Network"))
                jX = require(LuckyBlockConfig:WaitForChild("Config"):WaitForChild("LuckyBlockConfig"))
            else
                j1 = "#e05a5a"
                jX = require(kU_1:WaitForChild("Network"))
                LuckyBlockConfig = require(kU_1:WaitForChild("Config"):WaitForChild("LuckyBlockConfig"))
            end
            kS_3 = (kS_3 + 17) % 48
        end
    else
        if kS_3 * 62977883 + 4 + 7 <= kS_3 * 62977883 + 4 + 7 + 5 then
            BoostUpgradeConfig = require(kU_1:WaitForChild("Config"):WaitForChild("BoostUpgradeConfig"))
        else
            kU_1 = require(BoostUpgradeConfig:WaitForChild("Config"):WaitForChild("BoostUpgradeConfig"))
        end
        kS_3 = (kS_3 + 41) % 48
    end
until (kS_3 * 41 + 47) % 48 == 11
local kT_4 = {}
for k, v in LuckyBlockConfig.LuckyBlocks do
    local kS_4 = #kT_4 + 1
    local kU_2 = tonumber(v.Cost) or 0
    local kV_6 = tonumber(v.RequiredRebirth) or 0
    kT_4[kS_4] = { name = k, cost = kU_2, requiredRebirth = kV_6 }
    local kS_5 = tonumber(v.Cost) or 0
    kC[k] = kS_5
end
table.sort(kT_4, fn391)
for k, v in kT_4 do
    kJ[#kJ + 1] = v.name
end
j_, kT_5, kU_3, kM = nil, nil, nil, nil
local kS_6 = 9
repeat
    local kV_7 = (kS_6 * 1 + 0) % 3 + 1
    if kV_7 <= 2 then
        if kV_7 <= 1 then
            local kV_8 = { "rood", "pnnrqozjpki", "fzzjnr", "hpgduis", "ljuz", "max", "clqvijvnwq", "tty", "xvekydxk" }
            local r1 = kS_6
            local kW_2 = kV_8[r1 % 9 + 1]
            if kW_2:len() <= kW_2:gsub("(.)", "%1%1", r1 % 3 % 2 + 1):len() then
                j_ = { "CoinBoost", "FortuneBoost", "StockBoost", "MutationBoost" }
            else
                kU_3 = { "FortuneBoost", "StockBoost", "CoinBoost", "MutationBoost" }
            end
            kS_6 = (kS_6 + 4) % 12
        else
            if kS_6 * 107189405 + 9 + 4 >= kS_6 * 107189405 + 9 + 4 + 5 then
                j_ = {
                    MutationBoost = "Mutations Boost",
                    FortuneBoost = "Fortune Boost",
                    CoinBoost = "Coins Boost",
                    StockBoost = "Stock Boost"
                }
            else
                kT_5 = {
                    CoinBoost = "Coins Boost",
                    FortuneBoost = "Fortune Boost",
                    StockBoost = "Stock Boost",
                    MutationBoost = "Mutations Boost"
                }
            end
            kS_6 = (kS_6 + 7) % 12
        end
    else
        local kV_9 = { "hoqxfffubu", "rnftm", "bhbzynrso", "bljitb", "dwoydo", "wqc", "oajcdisnpt" }
        local r9 = kS_6
        local kW_3 = kV_9[r9 % 7 + 1]
        if kW_3:len() >= kW_3:reverse():rep(r9 % 3 + 2):len() then
            kM = {}
            kU_3 = {}
        else
            kU_3 = {}
            kM = {}
        end
        kS_6 = (kS_6 + 4) % 12
    end
until (kS_6 * 7 + 11) % 12 == 11
for k, v in j_ do
    local kS_7 = kT_5[v] or v
    kU_3[#kU_3 + 1] = kS_7
    kM[kS_7] = v
end
Library, SaveManager, Toggles, Options = nil, nil, nil, nil
Library = getgenv().Library
pcall(fn96)
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
if getgenv then
    getgenv().__TempoRollASorcererLib = Library
end
kQ, kN, kG, kP, kK, kr, j9, jV, kH, ki, jU, ky, kf, j4, jW, ke, kF, kx, kh, ks, jZ, kl, kD, kR, jS, j0, kt, jQ, j8, kA, kb = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
kQ = {}
kK = fn409
kr = fn535
j9 = fn299
jV = fn314
kH = fn615
ki = fn447
jU = fn265
ky = fn489
kf = fn43
j4 = fn122
jW = fn17
ke = fn291
kF = function()
    local a1 = {}
    local function a2(a3)
        if not a3 then
            return
        end
        for i, child in a3:GetChildren() do
            if child:IsA("Tool") then
                local lZ = child:GetAttribute("LuckyBlockName") or child:GetAttribute("ItemName")
                local lZ_1 = type(lZ) == "string" and lZ ~= "" and LuckyBlockConfig.LuckyBlocks[lZ]
                if lZ_1 then
                    local lZ_2 = tonumber(child:GetAttribute("Amount")) or 1
                    local lZ_3 = a1[lZ] or 0
                    a1[lZ] = lZ_3 + lZ_2
                end
            end
        end
    end
    a2(j3:FindFirstChild("Backpack"))
    a2(j3.Character)
    return a1
end
kx = fn582
kh = fn407
ks = fn718
jZ = fn501
kl = function(b2)
    local mS_1
    local mR_1
    if not jZ(b2) then
        return false
    end
    mR_1, mS_1 = pcall(function()
        return jX.BUYLUCKYBLOCK:Fire("BUY1", b2)
    end)
    local mT = mR_1 and type(mS_1) == "table" and mS_1.Success == true
    return mT
end
kD = function(cb)
    local mV = cb == ""
    local mV_1
    local mW = type(cb) ~= "string" or mV
    local mW_1
    if mW then
        return false
    elseif j3:GetAttribute("Rolling") == true then
        return false
    else
        mV_1, mW_1 = pcall(function()
            return jX.SpinCharacter:Fire(cb)
        end)
        local mX = mV_1 and type(mW_1) == "table" and mW_1.Success == true
        if mX then
            pcall(function()
                jX.RewardCharacter:Fire()
            end)
            return true
        end
        return false
    end
end
kR = fn358
jS = fn747
j0 = function()
    if not ki("AutoBuyUpgrades") then
        return
    end
    local nw = jS()
    if not nw then
        return
    end
    for k, v in j_ do
        local nJ = v
        if nw[nJ] then
            local LevelDataKey = BoostUpgradeConfig.Upgrades[nJ].LevelDataKey
            local ny = tonumber(j3:GetAttribute(LevelDataKey)) or 0
            local ny_2
            local ny_1 = tonumber(BoostUpgradeConfig.Upgrades[nJ].MaxLevel) or 100
            local nz_1
            if ny < ny_1 then
                ny_2, nz_1 = pcall(BoostUpgradeConfig.GetCost, nJ, ny)
                local nx_2 = ny_2 and type(nz_1) == "number" and kf() >= nz_1
                if nx_2 then
                    pcall(function()
                        jX.UpgradeBoost:Fire(nJ)
                    end)
                    task.wait(0.05)
                end
            end
        end
    end
end
kt = fn408
jQ = fn490
j8 = fn758
kN = 0
kG = 0
kA = fn644
kb = fn140
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = kz, Copyable = true }, "|", kE },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
kP = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "dices"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in kP do
    if k ~= "Info" then
        fn218(v)
    end
end
kc, j7, kL, kn = nil, nil, nil, nil
local SpinGroup = kP.Main:AddLeftGroupbox("Spin", "dices")
SpinGroup:AddToggle("AutoSpin", { Text = "Auto Spin", Default = false })
SpinGroup:AddToggle("AutoUseBestOwnedLuckyBlock", { Text = "Auto Use Best Owned Lucky Block", Default = false })
local LuckyBlocksGroup = kP.Main:AddLeftGroupbox("Lucky Blocks", "package")
LuckyBlocksGroup:AddToggle("AutoBuyLuckyBlock", { Text = "Auto Buy Lucky Block", Default = false })
LuckyBlocksGroup:AddDropdown("LuckyBlockType", {
    Text = "Lucky Block",
    Values = kJ,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Default = {}
})
local ProgressGroup = kP.Main:AddRightGroupbox("Progress", "trending-up")
ProgressGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
ProgressGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
ProgressGroup:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
local UpgradesGroup = kP.Main:AddRightGroupbox("Upgrades", "arrow-up")
UpgradesGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
UpgradesGroup:AddDropdown("UpgradeTypes", {
    Text = "Upgrades",
    Values = kU_3,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Default = {}
})
task.spawn(worker)
kn = fn401
local function k0()
    local o1
    local oZ
    oZ = nil
    o1 = nil
    local oX, oY, Label, Label2, Label3
    oZ = "Unknown"
    pcall(function()
        local oH_1
        local oG_1
        if identifyexecutor then
            oH_1, oG_1 = identifyexecutor()
            local oI = oH_1 ~= ""
            local oJ = type(oH_1) == "string" and oI
            if oJ then
                local oI_1 = type(oG_1) == "string" and oG_1 ~= "" and oH_1 .. " " .. oG_1
                oZ = oI_1 or oH_1
            end
        end
    end)
    local o3 = kn()
    o1 = os.clock()
    oY = function()
        local oO = math.floor(os.clock() - o1)
        if oO < 60 then
            return oO .. "s"
        elseif oO < 3600 then
            return string.format("%dm %ds", math.floor((oO) / (60)), oO % 60)
        else
            return string.format("%dh %dm", math.floor((oO) / (3600)), math.floor((oO % 3600) / (60)))
        end
    end
    local UserGroup = kP.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = j3, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(kH("User", j3.DisplayName .. " @" .. j3.Name, kk), true)
    UserGroup:AddLabel(kH("UserId", tostring(j3.UserId), kg), true)
    UserGroup:AddLabel(kH("Executor", oZ .. "  " .. o3, kk), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(kH("Session", oY(), ka), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            kr(j3.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            kr("https://www.roblox.com/users/" .. tostring(j3.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = kP.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(kH("Game", kE, kg), true)
    Label2 = SessionGroup:AddLabel(kH("Players", "0/0", kk), true)
    oX = tostring(game.JobId)
    local o4_1 = #oX > 18 and string.sub(oX, 1, 18) .. "..."
    local o4_2 = o4_1 or oX
    SessionGroup:AddLabel(kH("Job", o4_2, j5), true)
    Label = SessionGroup:AddLabel(kH("Ping", "0 ms", ka), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            kj:Teleport(game.PlaceId, j3)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            kr(oX, "Copied Job ID")
        end
    })
    task.spawn(function()
        local oU_1
        local oT_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(kH("Session", oY(), ka))
            Label2:SetText(kH("Players", #jO:GetPlayers() .. "/" .. tostring(jO.MaxPlayers), kk))
            oT_1, oU_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local oT_2 = oT_1 and oU_1 .. " ms" or "n/a"
            Label:SetText(kH("Ping", oT_2, ka))
        end
    end)
    local SocialsGroup = kP.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = j9 })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            kr(kv, "Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            kr(kp, "Copied website link")
        end
    })
end
k0()
local function k1()
    local connection
    local MovementGroup = kP.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = kP.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local function eZ(e_)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not e_)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = kd:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not e_
            end
        end)
        if not e_ then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(j3, "GameplayPaused", false)
            else
                j3.GameplayPaused = false
            end
        end)
    end
    local function fc(fd)
        if not fd:IsA("ProximityPrompt") then
            return
        end
        fd.HoldDuration = 0
        fd.MaxActivationDistance = 50
        fd.RequiresLineOfSight = false
    end
    connection = nil
    kK(kI.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = j3.Character
            if Character then
                for i, descendant in Character:GetDescendants() do
                    local pf_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if pf_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end))
    kK(kB.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local pq_1 = jU()
            if pq_1 then
                pq_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end))
    local CurrentCamera = j6.CurrentCamera
    kK(kI.RenderStepped:Connect(function(fA)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local pv_1 = jU()
            if pv_1 then
                pv_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local pv_3 = ky()
            local pw = jU()
            if pv_3 and pw then
                pw.PlatformStand = true
                local pw_1 = Vector3.zero
                local pB = if kB:IsKeyDown(Enum.KeyCode.W) then 1 else 0
                if pB == 1 then
                    pw_1 += CurrentCamera.CFrame.LookVector
                end
                if kB:IsKeyDown(Enum.KeyCode.S) then
                    pw_1 -= CurrentCamera.CFrame.LookVector
                end
                if kB:IsKeyDown(Enum.KeyCode.A) then
                    pw_1 -= CurrentCamera.CFrame.RightVector
                end
                if kB:IsKeyDown(Enum.KeyCode.D) then
                    pw_1 += CurrentCamera.CFrame.RightVector
                end
                local pE = if kB:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
                if pE == 1 then
                    pw_1 += Vector3.new(0, 1, 0)
                end
                if kB:IsKeyDown(Enum.KeyCode.LeftControl) then
                    pw_1 -= Vector3.new(0, 1, 0)
                end
                pv_3.AssemblyLinearVelocity = Vector3.zero
                if pw_1.Magnitude > 0 then
                    pv_3.CFrame = pv_3.CFrame + pw_1.Unit * Options.FlySpeed.Value * fA
                end
            end
        end
    end))
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local pF = jU()
            if pF then
                pF.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local pK = jU()
            if pK then
                pK.WalkSpeed = 16
            end
        end
    end)
    Toggles.AntiGameplayPause:OnChanged(function()
        eZ(Toggles.AntiGameplayPause.Value)
    end)
    eZ(true)
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in j6:GetDescendants() do
                pcall(fc, descendant)
            end
            connection = j6.DescendantAdded:Connect(function(f3)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(fc, f3)
                end
            end)
            kK(connection)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                eZ(true)
            end
        end
    end)
    return eZ, function()
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
end
kc, j7 = k1()
local function kT_6(ge)
    local gf = 0
    local gg = tick()
    ge:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = ge:AddLabel("AFK triggers: 0")
    local function gi()
        local CurrentCamera = j6.CurrentCamera
        if not CurrentCamera then
            return
        end
        kw:CaptureController()
        kw:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        gf += 1
        gg = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. gf)
        end)
    end
    local connection = j3.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(gi)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local pZ = Toggles.AntiAfk.Value and tick() - gg >= 60
            if pZ then
                pcall(gi)
            end
        end
    end)
    ge:AddButton({
        Text = "Unload UI",
        Func = function()
            Library:Unload()
        end
    })
    return connection
end
local MenuGroup = kP.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
kL = kT_6(MenuGroup)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(kP.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/RollASorcerer")
local k3 = SaveManager:BuildConfigSection(kP.Settings)
SaveManager:LoadAutoloadConfig()
local function k2(gJ)
    local function gK(gL, gM)
        local p1_1 = (gL == "Toggle" and Toggles or Options)[gM]
        local p0_2 = type(p1_1) == "table" and p1_1.Type == gL
        return p0_2 and p1_1 or nil
    end
    local function gU(gV, gW)
        local Type = gW.Type
        if Type == "Toggle" then
            return { idx = gV, type = "Toggle", value = gW.Value == true }
        elseif Type == "Slider" then
            return { idx = gV, type = "Slider", value = tostring(gW.Value) }
        elseif Type == "Dropdown" then
            return { idx = gV, type = "Dropdown", multi = gW.Multi == true, value = gW.Value }
        elseif Type == "Input" then
            local p5 = gW.Value or ""
            return { idx = gV, type = "Input", text = tostring(p5) }
        elseif Type == "ColorPicker" then
            return { idx = gV, type = "ColorPicker", value = gW.Value:ToHex(), transparency = gW.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = gV,
                type = "KeyPicker",
                mode = gW.Mode,
                key = gW.Value,
                modifiers = gW.Modifiers,
                toggled = gW.Toggled
            }
        else
            return nil
        end
    end
    local function gY()
        local qb = {}
        for k, v in { Toggles, Options } do
            for k, v in v do
                local qc = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if qc then
                    local qc_1 = gU(k, v)
                    if qc_1 then
                        qb[#qb + 1] = qc_1
                    end
                end
            end
        end
        table.sort(qb, function(g5, g6)
            if g5.type ~= g6.type then
                return g5.type < g6.type
            end
            return g5.idx < g6.idx
        end)
        return { objects = qb }
    end
    local function g7(g8)
        local qs
        qs = nil
        local qt = type(g8) ~= "table"
        local qx = if qt then 1 else 0
        local qv = 1250 * qx + 894 * (1 - qx)
        local qw = 1643 * qx + 2576 * (1 - qx)
        if not ((qv * 2878 + qw * 815 + qv * qw) % 16777213 == 6990295) then
            qt = type(g8.idx) ~= "string"
        end
        if not qt then
            qt = type(g8.type) ~= "string"
        end
        local qA = if qt then 1 else 0
        local qy = 2267 * qA + 2311 * (1 - qA)
        local qz = 693 * qA + 795 * (1 - qA)
        if not ((qy * 374 + qz * 3694 + qy * qz) % 16777213 == 4978831) then
            qt = SaveManager.Ignore[g8.idx]
        end
        if qt then
            return false
        end
        qs = gK(g8.type, g8.idx)
        if not qs then
            return false
        end
        local qt_1 = pcall(function()
            if g8.type == "Input" then
                if type(g8.text) ~= "string" then
                    return
                end
                qs:SetValue(g8.text)
            elseif g8.type == "ColorPicker" then
                qs:SetValueRGB(Color3.fromHex(g8.value), g8.transparency)
            elseif g8.type == "KeyPicker" then
                qs:SetValue({ g8.key, g8.mode, g8.modifiers })
                if g8.mode == "Toggle" and g8.toggled ~= nil then
                    qs.Toggled = g8.toggled
                    qs:Update()
                end
            else
                qs:SetValue(g8.value)
            end
        end)
        return qt_1
    end
    gJ:AddDivider()
    gJ:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    gJ:AddButton("Export Config to Clipboard", function()
        local qC_1
        local qB_1
        qB_1, qC_1 = pcall(kq.JSONEncode, kq, gY())
        if not qB_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local qB_2 = setclipboard or toclipboard
        local qB_3 = type(qB_2) ~= "function" or not pcall(qB_2, qC_1)
        if qB_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    gJ:AddButton("Import Config from Clipboard Text", function()
        local qH_1
        local qF = Options.SaveManager_ImportSource.Value or ""
        local qF_1
        local qG = tostring(qF):match("^%s*(.-)%s*$")
        if qG == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        qF_1, qH_1 = pcall(kq.JSONDecode, kq, qG)
        local qG_1 = not qF_1
        local qL = if qG_1 then 1 else 0
        local qJ = 1513 * qL + 3415 * (1 - qL)
        local qK = 945 * qL + 2405 * (1 - qL)
        if not ((qJ * 894 + qK * 1680 + qJ * qK) % 16777213 == 4370007) then
            qG_1 = type(qH_1) ~= "table"
        end
        if not qG_1 then
            qG_1 = type(qH_1.objects) ~= "table"
        end
        if qG_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local qF_2 = 0
        for k, v in qH_1.objects do
            if g7(v) then
                qF_2 += 1
            end
        end
        if qF_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local qH_2 = qF_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(qF_2, qH_2), 6)
    end)
end
k2(k3)
Library:OnUnload(function()
    kc(false)
    j7()
    if kL then
        kL:Disconnect()
    end
    for k, v in kQ do
        local qZ = v
        pcall(function()
            qZ:Disconnect()
        end)
    end
    table.clear(kQ)
    local qS = jU()
    if qS then
        qS.PlatformStand = false
        qS.WalkSpeed = 16
    end
    local qS_1 = getgenv and getgenv().__TempoRollASorcererLib == Library
    if qS_1 then
        getgenv().__TempoRollASorcererLib = nil
    end
end)
end)(...)

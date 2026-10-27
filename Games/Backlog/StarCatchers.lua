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
getgenv().TempoHoodSubtitle = "STAR CATCHERS"
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
local xv_9, xv_10, xv_12, xv_14
local oq
local n6
local oR
local nO
local oy
local nv
local oc
local nU
local oE
local SaveManager
local oi
local n_
local VirtualUser
local Library
local op
local n5
local oQ
local nN
local ox
local nu
local ob
local nT
local HttpService
local Toggles
local oh
local nZ
local oJ
local nG
local SkillTreeConfig
local n4
local UserInputService
local nM
local Network
local nt
local oa
local nS
local oC
local og
local nY
local oI
local connection3
local LocalPlayer
local n3
local oO
local nL
local CoreGui
local ns
local nR
local oB
local ny
local of
local connection
local nE
local om
local n2
local oN
local nK
local Constants
local n8
local oT
local nQ
local Label
local Options
local oe
local nW
local oG
local nD
local ol
local n1
local oM
local nJ
local Workspace
local n7
local oS
local nP
local nw
local od
local connection2
local nC
local oj
local n0
local oL
local nI
function fns.fn68()
    local q4 = Options.BlessingTypes and Options.BlessingTypes.Value
    local q5 = {}
    if type(q4) == "table" then
        for k, v in q4 do
            if v then
                local q4_1 = oi[k]
                if q4_1 then
                    q5[q4_1] = true
                end
            end
        end
    end
    return q5
end
function fns.fn70(gr)
    local DiscordGroup = gr:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = nK })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = nK })
end
function fns.autoRollLoop()
    while not Library.Unloaded do
        if Toggles.AutoRoll.Value then
            pcall(nG)
        end
        task.wait(0.35)
    end
end
function fns.autoFillObservatoriesLoop()
    while not Library.Unloaded do
        if Toggles.AutoFillObservatories.Value then
            pcall(oy)
        end
        task.wait(2)
    end
end
function fns.onRenderStepped2(hK)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local vT_1 = op()
        if vT_1 then
            vT_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local vT_3 = oG()
        local vU = op()
        nv = Workspace.CurrentCamera or nv
        if vT_3 and vU and nv then
            vU.PlatformStand = true
            local vU_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                vU_1 = vU_1 + nv.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                vU_1 = vU_1 - nv.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                vU_1 = vU_1 - nv.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                vU_1 = vU_1 + nv.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                vU_1 = vU_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                vU_1 = vU_1 - Vector3.new(0, 1, 0)
            end
            vT_3.Velocity = Vector3.zero
            if vU_1.Magnitude > 0 then
                vT_3.CFrame = vT_3.CFrame + vU_1.Unit * Options.FlySpeed.Value * hK
            end
        end
    end
end
function fns.fn116()
    nZ(Toggles.AntiGameplayPause.Value)
end
function fns.autoPolishStarsLoop()
    while not Library.Unloaded do
        if Toggles.AutoPolishStars.Value then
            pcall(nT)
        end
        task.wait(0.4)
    end
end
function fns.onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local vO_1 = op()
        if vO_1 then
            vO_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
function fns.fn136()
    if not Toggles.Fly.Value then
        local vz = op()
        if vz then
            vz.PlatformStand = false
        end
    end
end
function fns.fn138()
    local tu = oa()
    if not tu then
        return
    end
    local tv = ns(tu)
    local tw = tonumber(tu.stardust) or 0
    local tx = tw
    local tw_1 = tonumber(tu.meteorDebris) or tonumber(LocalPlayer:GetAttribute("MeteorDebris"))
    local tw_2 = tw_1 or 0
    local tu_2 = tonumber(LocalPlayer:GetAttribute("TotalRolls")) or 0
    for i, v in ipairs(SkillTreeConfig.nodes) do
        local tu_3 = type(v) == "table" and v.id and not tv[v.id]
        if tu_3 then
            local tu_4 = tonumber(v.cost) or 0
            local tu_5 = tonumber(v.debrisCost) or 0
            local tu_6 = tonumber(v.minRolls) or 0
            local tu_7 = tu_4 <= tx and tu_5 <= tw_2 and tu_6 <= tu_2 and oh(v, tv)
            if tu_7 then
                oN("UnlockSkillNode", v.id)
                tv[v.id] = true
                tx -= tu_4
                tw_2 -= tu_5
                task.wait(0.2)
            end
        end
    end
end
function fns.onInputChanged(is)
    local UserInputType = is.UserInputType
    local we = UserInputType == Enum.UserInputType.MouseMovement
    local wi = if we then 1 else 0
    local wg = 348 * wi + 419 * (1 - wi)
    local wh = 1464 * wi + 2838 * (1 - wi)
    if not ((wg * 1418 + wh * 823 + wg * wh) % 16777213 == 2207808) then
        we = UserInputType == Enum.UserInputType.Gamepad1
    end
    if we then
        oJ = tick()
    end
end
function fns.onCopyEthereumAddress()
    n2(n_, "Copied Ethereum address")
end
function fns.fn220()
    n2(of, "Copied Discord invite to clipboard")
end
function fns.antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local xm = tick() - oJ
            local xn = tick() - oC
            if xm >= 300 and xn >= 60 then
                pcall(oj)
            else
                if xm < 300 and xn >= 300 then
                    pcall(oj)
                end
            end
        end
    end
end
function fns.fn246()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    oC = tick()
end
function fns.fn249()
    if os.clock() - nW < 0.4 then
        return
    end
    local sC = oq()
    if type(sC) ~= "table" then
        return
    end
    local sD = nY()
    local sE = tonumber(LocalPlayer:GetAttribute("StarWax")) or 0
    for k, v in sC do
        local sC_1 = type(v) == "table" and v.isPolished ~= true
        if sC_1 then
            local sC_2 = v.uuid or ""
            local sE_1 = tostring(sC_2)
            if sE_1 ~= "" and sE_1 ~= sD then
                nW = os.clock()
                oN("Polish_Star", sE_1, sE >= 1)
                return
            end
        end
    end
end
function fns.autoSellStarsLoop()
    while not Library.Unloaded do
        if Toggles.AutoSellStars.Value then
            pcall(oI)
        end
        task.wait(2)
    end
end
function fns.fn283()
    local p6 = nL("RequestInventoryData")
    local p7 = type(p6) == "table" and type(p6.inventory) == "table"
    if p7 then
        return p6.inventory
    end
    return nil
end
function fns.fn292(bF)
    if not bF or not fireproximityprompt then
        return
    end
    local qN_1 = pcall(fireproximityprompt, bF)
    if not qN_1 then
        pcall(fireproximityprompt, bF, 0)
    end
end
function fns.onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local vD_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if vD_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
function fns.autoEquipBestStarsLoop()
    while not Library.Unloaded do
        if Toggles.AutoEquipBestStars.Value then
            pcall(oT)
        end
        task.wait(1)
    end
end
function fns.fn368()
    local pD_1
    local pC_1
    if gethui then
        pC_1, pD_1 = pcall(gethui)
        if pC_1 and pD_1 then
            return pD_1
        end
        return CoreGui
    end
    return CoreGui
end
function fns.fn396()
    local ScreenGui = Library.ScreenGui
    if not ScreenGui then
        return
    end
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local pI = PlayerGui and ScreenGui:IsDescendantOf(PlayerGui)
    if pI then
        ScreenGui.Parent = nt()
    end
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ClipToDeviceSafeArea = false
    ScreenGui.DisplayOrder = 999
    ScreenGui.ResetOnSpawn = false
    local MainFrame = Library.MainFrame
    local pI_1 = MainFrame and MainFrame:IsA("GuiButton")
    if pI_1 then
        MainFrame.AutoButtonColor = false
    end
    for i, descendant in ScreenGui:GetDescendants() do
        if descendant:IsA("CanvasGroup") then
            if descendant.BackgroundTransparency >= 1 then
                descendant.BackgroundTransparency = 0.99
            end
            if descendant.Visible then
                descendant.GroupTransparency = 0
            end
        elseif descendant:IsA("GuiButton") then
            descendant.AutoButtonColor = false
        end
    end
end
function fns.fn428()
    local qc = nL("Astro_GetState")
    local qd = type(qc) == "table" and qc
    return qd or nil
end
function fns.fn436(cb)
    if cb:IsA("BasePart") then
        return cb.Position
    elseif cb:IsA("Model") then
        return cb:GetPivot().Position
    else
        return nil
    end
end
function fns.fn446()
    local qr = Options.SellRarity and Options.SellRarity.Value
    if type(qr) ~= "string" then
        return 1
    end
    for i, v in ipairs(n7) do
        if v == qr then
            return i
        end
    end
    return 1
end
local function fn454()
    local qf = (LocalPlayer:GetAttribute("EquippedStarPetUuid"))
    local qj = if qf then 1 else 0
    local qh = 3217 * qj + 547 * (1 - qj)
    local qi = 2722 * qj + 3426 * (1 - qj)
    if not ((qh * 3877 + qi * 2711 + qh * qi) % 16777213 == 11831112) then
        qf = ""
    end
    return tostring(qf)
end
local function fn457(bQ)
    local qY = oG()
    if not (qY and bQ) then
        return
    end
    if bQ:IsA("BasePart") then
        qY.CFrame = bQ.CFrame + Vector3.new(0, 5, 0)
    elseif bQ:IsA("Model") then
        local qZ_1 = bQ.PrimaryPart
        local q3 = if qZ_1 then 1 else 0
        local q1 = 2689 * q3 + 2059 * (1 - q3)
        local q2 = 3520 * q3 + 954 * (1 - q3)
        if not ((q1 * 3231 + q2 * 1138 + q1 * q2) % 16777213 == 5381986) then
            qZ_1 = bQ:FindFirstChildWhichIsA("BasePart", true)
        end
        local q_ = qZ_1
        if q_ then
            qY.CFrame = q_.CFrame + Vector3.new(0, 5, 0)
        else
            qY.CFrame = bQ:GetPivot() + Vector3.new(0, 5, 0)
        end
    end
end
local function fn474()
    local uH = nL("GetQuestStatus")
    local uI = type(uH) ~= "table" or type(uH.DailyQuests) ~= "table"
    if uI then
        return
    end
    for i, v in ipairs(uH.DailyQuests) do
        local uH_1 = type(v) == "table" and v.completed == true and v.claimed ~= true and v.id
        if uH_1 then
            nL("ClaimQuest", v.id)
            task.wait(0.15)
        end
    end
end
local function onInputBegan()
    oJ = tick()
end
local function fn482()
    local Islands = Workspace:FindFirstChild("Islands")
    if not Islands then
        return nil
    end
    local UserId = LocalPlayer.UserId
    for i, child in Islands:GetChildren() do
        if child:GetAttribute("OwnerUserId") == UserId then
            return child
        end
    end
    return nil
end
local function fn485()
    local us = og()
    if next(us) == nil then
        return
    end
    local ut = oa()
    if not ut then
        return
    end
    local uv = ut.Blessings or {}
    local uv_1 = tonumber(ut.meteorDebris) or 0
    local ut_1 = uv_1
    local BLESSINGS = Constants.BLESSINGS
    for k in us do
        local us_1 = oc[k]
        local uw = us_1 and uv[us_1]
        if uw == false or uw == 0 or uw == nil then
            local us_4 = BLESSINGS and BLESSINGS[k]
            local uw_3 = us_4
            if us_4 then
                us_4 = tonumber(uw_3.cost)
            end
            local uw_4 = us_4 or 0
            if uw_4 <= ut_1 then
                nL("Astro_Purchase", "Blessing", k, 1)
                ut_1 -= uw_4
                task.wait(0.2)
            end
        end
    end
end
local function fn497()
    if os.clock() - nR >= 3 then
        nR = os.clock()
        oN("Garden_EquipBestStars")
    end
    if os.clock() - nN < 4 then
        return
    end
    nN = os.clock()
    local sn = oq()
    if type(sn) ~= "table" then
        return
    end
    local so = -1
    local sp
    for k, v in sn do
        if type(v) == "table" then
            local starId = v.starId
            local sq = v.variant or "Normal"
            local sr = om(starId, sq)
            if sr > so then
                so = sr
                sp = v
            end
        end
    end
    if not sp then
        return
    end
    local so_1 = sp.uuid or sp.id or ""
    local sn_3 = tostring(so_1)
    local so_2 = sn_3 == ""
    local sB = if so_2 then 1 else 0
    local sz = 1819 * sB + 1683 * (1 - sB)
    local sA = 22 * sB + 3882 * (1 - sB)
    if not ((sz * 3494 + sA * 1347 + sz * sA) % 16777213 == 6425238) then
        so_2 = sn_3 == nY()
    end
    if so_2 then
        return
    end
    oN("ToggleEquipStarPet", sn_3)
end
local function fn504()
    local sO = oq()
    if type(sO) ~= "table" then
        return
    end
    local sP = oQ()
    local sQ = nY()
    local sR = {}
    local sS = {}
    for k, v in sO do
        if type(v) == "table" then
            local sT = v.uuid or v.id or ""
            local sO_2 = tostring(sT)
            if sO_2 ~= sQ then
                local sO_3 = v.variant or "Normal"
                if nO(v.starId, sO_3) <= sP then
                    local sO_4 = tostring(v.starId) .. "_" .. tostring(sO_3) .. "_" .. tostring(v.isPolished == true)
                    local sU = sS[sO_4]
                    if sU then
                        sU.count = sU.count + 1
                    else
                        local sU_1 = { starId = v.starId, variant = sO_3, isPolished = v.isPolished == true, count = 1 }
                        sS[sO_4] = sU_1
                        sR[#sR + 1] = sO_4
                    end
                end
            end
        end
    end
    local sO_5 = {}
    for i, v in ipairs(sR) do
        sO_5[#sO_5 + 1] = sS[v]
    end
    if #sO_5 > 0 then
        oN("SellCart", sO_5)
    end
end
local function fn510(ea, eb)
    if type(ea.requires) ~= "table" then
        return true
    end
    for k, v in ea.requires do
        local tm = type(v) == "string" and not eb[v]
        if tm then
            return false
        end
    end
    return true
end
local function autoClaimQuestsLoop()
    while not Library.Unloaded do
        if Toggles.AutoClaimQuests.Value then
            pcall(nD)
        end
        if Toggles.AutoClaimMail.Value then
            pcall(oO)
        end
        if Toggles.AutoClaimRewards.Value then
            pcall(oe)
        end
        if Toggles.AutoClaimNet.Value then
            pcall(nE)
        end
        task.wait(2)
    end
end
local function fn527()
    local vk_1
    local vj_1
    if identifyexecutor then
        vk_1, vj_1 = identifyexecutor()
        local vl = vk_1 ~= ""
        local vm = type(vk_1) == "string" and vl
        if vm then
            local vl_1 = type(vj_1) == "string" and vj_1 ~= "" and vk_1 .. " " .. vj_1
            nw = vl_1 or vk_1
        end
    end
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            nZ(true)
        end
    end
end
local function onCopySolanaAddress()
    n2(nP, "Copied Solana address")
end
local function fn570()
    local tT = oa()
    if not tT then
        return
    end
    local tU = tonumber(tT.calibrationLevel) or 0
    local tV_1 = Constants.CALIBRATION and Constants.CALIBRATION[tU + 1]
    if type(tV_1) ~= "table" then
        return
    end
    local tU_2 = tonumber(tV_1.cost) or 0
    local tU_3 = tonumber(tT.stardust) or 0
    if tU_2 > 0 and tU_3 >= tU_2 then
        nL("Astro_Purchase", "Calibration", "")
    end
end
local function fn593(d1)
    local s7 = d1
    local s8 = {}
    if s7 then
        s7 = type(d1.unlockedSkillNodes) == "table"
    end
    if s7 then
        for k, v in d1.unlockedSkillNodes do
            if v then
                s8[k] = true
            end
        end
    end
    local s7_1 = nL("GetUnlockedNodes")
    if type(s7_1) == "table" then
        for k, v in s7_1 do
            if type(v) == "string" then
                s8[v] = true
            end
        end
    end
    local s7_2 = SkillTreeConfig.ORIGIN_NODE_ID or "backpack"
    s8[s7_2] = true
    return s8
end
local function onCopyJoinScript_JobID()
    local gI = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, ox)
    n2(gI, "Copied join script to clipboard")
end
local function onCopyPayPalLink()
    n2(nM, "Copied PayPal link")
end
local function worker()
    local vp_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local vo = math.floor(os.clock() - n8)
        if vo < 60 then
            vp_1 = vo .. "s"
        elseif vo < 3600 then
            vp_1 = string.format("%dm %ds", math.floor((vo) / (60)), vo % 60)
        else
            vp_1 = string.format("%dh %dm", math.floor((vo) / (3600)), math.floor((vo % 3600) / (60)))
        end
        Label:SetText(nu("Session time", vp_1, oL))
    end
end
local function fn687(iG, iH)
    local wm_1 = (iG == "Toggle" and Toggles or Options)[iH]
    local wl_2 = type(wm_1) == "table" and wm_1.Type == iG
    return wl_2 and wm_1 or nil
end
local function fn707(aO)
    return Network:GetRemoteFunction(aO)
end
local function fn708()
    local ww = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local wx = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if wx then
                local wx_1 = n6(k, v)
                if wx_1 then
                    ww[#ww + 1] = wx_1
                end
            end
        end
    end
    table.sort(ww, function(i2, i3)
        if i2.type ~= i3.type then
            return i2.type < i3.type
        end
        return i2.idx < i3.idx
    end)
    return { objects = ww }
end
local function fn714()
    local Character = LocalPlayer.Character
    local pY = Character and Character:FindFirstChildOfClass("Humanoid")
    return pY
end
local function fn728(aL)
    return Network:GetRemoteEvent(aL)
end
local function onCopyLitecoinAddress()
    n2(n5, "Copied Litecoin address")
end
local function onRscripts()
    n2(ob, "Copied Rscripts profile to clipboard")
end
local function onUnload()
    Library:Unload()
end
local function autoBuyDecorTodayLoop()
    while not Library.Unloaded do
        if Toggles.AutoBuyDecorToday.Value then
            pcall(ol)
        end
        if Toggles.AutoBuyStarWax.Value then
            pcall(n4)
        end
        if Toggles.AutoBuyBlessings.Value then
            pcall(oS)
        end
        task.wait(3)
    end
end
local function onRenderStepped()
    if Library.Unloaded then
        return
    end
    local ScreenGui = Library.ScreenGui
    if not ScreenGui then
        return
    end
    for i, descendant in ScreenGui:GetDescendants() do
        local vr_1 = descendant:IsA("CanvasGroup") and descendant.Visible and descendant.GroupTransparency ~= 0
        if vr_1 then
            descendant.GroupTransparency = 0
        end
    end
end
local function autoUpgradeNetLoop()
    while not Library.Unloaded do
        if Toggles.AutoUpgradeNet.Value then
            pcall(od)
        end
        if Toggles.AutoUpgradeTree.Value then
            pcall(nQ)
        end
        if Toggles.AutoCalibration.Value then
            pcall(ny)
        end
        task.wait(2)
    end
end
local function fn838()
    local rA = oG()
    if not rA then
        return
    end
    local rB = oM()
    if #rB == 0 then
        return
    end
    local rC = math.huge
    local rD
    for k, v in rB do
        local rB_1 = oR(v)
        if rB_1 then
            local Magnitude = (rA.Position - rB_1).Magnitude
            if Magnitude < rC then
                rC = Magnitude
                rD = v
            end
        end
    end
    if not rD then
        return
    end
    if rC > 8 then
        oE(rD)
        task.wait(0.08)
    end
    oN("SC_ScreenTapped")
    local ProximityPrompt = rD:FindFirstChildWhichIsA("ProximityPrompt", true)
    if ProximityPrompt and ProximityPrompt.Enabled then
        nI(ProximityPrompt)
    end
end
local function fn865(ay, az, aA)
    return string.format("<b>%s</b> %s %s", ay, nC("-", "#5a6070"), nC(az, aA))
end
local function fn883(av, aw)
    return string.format('<font color="%s">%s</font>', aw, av)
end
local function fn907(iO, iP)
    local Type = iP.Type
    if Type == "Toggle" then
        return { idx = iO, type = "Toggle", value = iP.Value == true }
    elseif Type == "Slider" then
        return { idx = iO, type = "Slider", value = tostring(iP.Value) }
    elseif Type == "Dropdown" then
        return { idx = iO, type = "Dropdown", multi = iP.Multi == true, value = iP.Value }
    elseif Type == "Input" then
        local wt = iP.Value or ""
        return { idx = iO, type = "Input", text = tostring(wt) }
    elseif Type == "ColorPicker" then
        return { idx = iO, type = "ColorPicker", value = iP.Value:ToHex(), transparency = iP.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = iO,
            type = "KeyPicker",
            mode = iP.Mode,
            key = iP.Value,
            modifiers = iP.Modifiers,
            toggled = iP.Toggled
        }
    else
        return nil
    end
end
local function onImportConfigFromClipboardTex()
    local w1_1
    local w_ = Options.SaveManager_ImportSource.Value or ""
    local w__1
    local w0 = tostring(w_):match("^%s*(.-)%s*$")
    if w0 == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    w__1, w1_1 = pcall(HttpService.JSONDecode, HttpService, w0)
    local w0_1 = not w__1 or type(w1_1) ~= "table" or type(w1_1.objects) ~= "table"
    if w0_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local w__2 = 0
    for i, v in ipairs(w1_1.objects) do
        if oB(v) then
            w__2 += 1
        end
    end
    if w__2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local w1_2 = w__2 == 1 and ""
    local xb = if w1_2 then 1 else 0
    local w9 = 1209 * xb + 3734 * (1 - xb)
    local xa = 3921 * xb + 933 * (1 - xb)
    if not ((w9 * 33 + xa * 1042 + w9 * xa) % 16777213 == 8866068) then
        w1_2 = "s"
    end
    Library:Notify(("Imported %d setting%s"):format(w__2, w1_2), 6)
end
local function fn918()
    if connection then
        connection:Disconnect()
    end
    connection2:Disconnect()
    connection3:Disconnect()
    nZ(false)
    local wj = op()
    if wj then
        wj.PlatformStand = false
        wj.WalkSpeed = 16
    end
end
local function onCopyUSDTAddress()
    n2(nU, "Copied USDT address")
end
local function fn927()
    local uQ = nL("Mailbox_GetState")
    local uR = type(uQ) ~= "table"
    local uV = if uR then 1 else 0
    local uT = 3504 * uV + 375 * (1 - uV)
    local uU = 1483 * uV + 3566 * (1 - uV)
    if not ((uT * 1899 + uU * 4057 + uT * uU) % 16777213 == 1089846) then
        uR = type(uQ.mailbox) ~= "table"
    end
    if uR then
        return
    end
    for i, v in ipairs(uQ.mailbox) do
        local uQ_1 = type(v) == "table" and v.claimed ~= true and type(v.mailId) == "string" and v.mailId ~= ""
        if uQ_1 then
            oN("Mailbox_ClaimMail", v.mailId)
            task.wait(0.1)
        end
    end
end
local function fn942()
    local rh = LocalPlayer:GetAttribute("AutoRollUnlocked") == true and LocalPlayer:GetAttribute("AutoRollEnabled") ~= true
    if rh then
        oN("SC_ToggleAutoRoll")
    end
    local rh_1 = LocalPlayer:GetAttribute("SkillManualRollInterval")
    local ri = type(rh_1) ~= "number"
    local rm = if ri then 1 else 0
    local rk = 1420 * rm + 3180 * (1 - rm)
    local rl = 2483 * rm + 2319 * (1 - rm)
    if not ((rk * 1489 + rl * 2952 + rk * rl) % 16777213 == 12970056) then
        ri = rh_1 <= 0
    end
    if ri then
        rh_1 = 5
    end
    if os.clock() - n0 < rh_1 then
        return
    end
    n0 = os.clock()
    oN("SC_ManualRoll")
end
local function onExportConfigToClipboard()
    local wU_1
    local wT_1
    wT_1, wU_1 = pcall(HttpService.JSONEncode, HttpService, nS())
    if not wT_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local wT_2 = setclipboard or toclipboard
    local wT_3 = type(wT_2) ~= "function" or not pcall(wT_2, wU_1)
    if wT_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function fn965()
    local Character = LocalPlayer.Character
    local pV = Character and Character:FindFirstChild("HumanoidRootPart")
    return pV
end
local function fn998()
    local tJ = oa()
    if not tJ then
        return
    end
    local tK = (tonumber(tJ.netTier))
    local tS = if tK then 1 else 0
    local tQ = 633 * tS + 3605 * (1 - tS)
    local tR = 3078 * tS + 328 * (1 - tS)
    if not ((tQ * 1342 + tR * 110 + tQ * tR) % 16777213 == 3136440) then
        tK = 1
    end
    local tL_1 = Constants.NET_TIERS and Constants.NET_TIERS[tK + 1]
    local tK_2 = type(tL_1) ~= "table" or tL_1.locked == true
    if tK_2 then
        return
    end
    local tK_3 = tonumber(tL_1.cost) or 0
    local tK_4 = tonumber(tJ.stardust) or 0
    if tK_3 > 0 and tK_4 >= tK_3 then
        nL("Astro_Purchase", "Net", "")
    end
end
local function fn1014()
    local u4 = nL("GetDailyRewardsStatus")
    local u5 = type(u4) == "table" and u4.CanClaimNow == true
    if u5 then
        nL("ClaimDailyReward")
    end
    local u4_1 = nL("GetTimeRewardsStatus")
    local u5_1 = type(u4_1) == "table" and type(u4_1.Tiers) == "table"
    if u5_1 then
        for i, v in ipairs(u4_1.Tiers) do
            local u4_2 = type(v) == "table" and v.Unlocked == true and v.Claimed ~= true
            if u4_2 then
                nL("ClaimTimeReward", i)
                task.wait(0.15)
            end
        end
    end
    oN("GroupReward_Claim")
    oN("GroupReward_RequestStatus", false)
end
local function onCopyVenmoLink()
    n2(nJ, "Copied Venmo link")
end
local function onCopyBitcoinAddress()
    n2(n3, "Copied Bitcoin address")
end
local function fn1045(ao, ap)
    if setclipboard then
        setclipboard(ao)
    elseif toclipboard then
        toclipboard(ao)
    end
    Library:Notify(ap)
end
local function fn1050()
    if not Toggles.WalkSpeedEnabled.Value then
        local vB = op()
        if vB then
            vB.WalkSpeed = 16
        end
    end
end
local function autoCrackMeteorsLoop()
    while not Library.Unloaded do
        if Toggles.AutoCrackMeteors.Value then
            pcall(n1)
        end
        task.wait(0.15)
    end
end
local function fn1082()
    local uj = tonumber(LocalPlayer:GetAttribute("StarWax")) or 0
    local uk = uj
    if uk >= 5 then
        return
    end
    local uj_1 = oa()
    local ul = uj_1 and tonumber(uj_1.stardust)
    local ul_1 = ul or 0
    local uj_3 = tonumber(Constants.STAR_WAX_COST_PER_UNIT) or 8
    local uj_4 = tonumber(Constants.STAR_WAX_BULK_LIMIT) or 20
    while true do
        if uk < 5 and uk < uj_4 and ul_1 >= uj_3 then
            local uj_6 = nL("Bench_BuyStarWax", 1)
            if uj_6 ~= true then
                break
            end
            uk += 1
            ul_1 -= uj_3
            task.wait(0.15)
            continue
        end
        break
    end
end
ns = nil
nt = nil
nu = nil
nv = nil
nw = nil
Options = nil
ny = nil
Toggles = nil
SaveManager = nil
nC = nil
nD = nil
nE = nil
connection3 = nil
nG = nil
Library = nil
nI = nil
nJ = nil
nK = nil
nL = nil
nM = nil
nN = nil
nO = nil
nP = nil
nQ = nil
nR = nil
nS = nil
nT = nil
nU = nil
connection2 = nil
nW = nil
nY = nil
nZ = nil
n_ = nil
n0 = nil
n1 = nil
n2 = nil
n3 = nil
n4 = nil
n5 = nil
n6 = nil
n7 = nil
n8 = nil
oa = nil
ob = nil
oc = nil
od = nil
oe = nil
local nz, nX, n9
of = nil
og = nil
oh = nil
oi = nil
oj = nil
ol = nil
om = nil
LocalPlayer = nil
SkillTreeConfig = nil
op = nil
oq = nil
Workspace = nil
Constants = nil
CoreGui = nil
Network = nil
ox = nil
oy = nil
Label = nil
oB = nil
oC = nil
HttpService = nil
oE = nil
oG = nil
connection = nil
oI = nil
oJ = nil
VirtualUser = nil
oL = nil
oM = nil
oN = nil
oO = nil
UserInputService = nil
oQ = nil
oR = nil
oS = nil
oT = nil
local GuiService
GuiService = nil
local oF
local AutoUpgradeGroup, Polish_SellGroup, FaqGroup, DonationsGroup, TempoHubGroup
UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, LocalPlayer, of, ob, n5, n3, n_, nU, nP, nM, nJ, xv_9, oL, Network, Constants, SkillTreeConfig, oi, oc, n7, xv_12 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local xv_3 = game:GetService("Players")
local xv_6 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
LocalPlayer = xv_3.LocalPlayer
local xv_5 = "Star Catchers"
of = "https://discord.gg/K7Qxnxkk46"
ob = "https://discord.gg/K7Qxnxkk46"
n5 = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
n3 = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
n_ = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
nU = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
if (not xv_12 or xv_5) and (false or not RunService) or (not xv_12 or xv_5 or xv_9 and not UserInputService) or not ((not xv_12 or xv_5) and (false or not RunService) or (not xv_12 or xv_5 or xv_9 and not UserInputService)) then
    nP = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
    nM = ""
    nJ = ""
    xv_14 = "#345d9d"
    xv_9 = "#f7931a"
else
    xv_9 = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
    nP = ""
    xv_14 = ""
    nJ = "#345d9d"
    nM = "#f7931a"
end
local xv_2 = "#627eea"
local xv_13 = "#26a17b"
local xv_7 = "#14f195"
local xv_1 = "#0070ba"
local o9 = "#008cff"
local o8 = "#7fd47f"
local o7 = "#6ec1ff"
oL = "#e8a34d"
local o6 = "#8b93a3"
local xv_15 = xv_6:WaitForChild("Shared")
Network = require(xv_15:WaitForChild("Network"))
Constants = require(xv_15.Definitions:WaitForChild("Constants"))
SkillTreeConfig = require(xv_6:WaitForChild("Modules"):WaitForChild("SkillTree"):WaitForChild("SkillTreeConfig"))
local xv_11 = { "Silver Rolls", "Gold Rolls", "Celestial Strike" }
oi = { ["Silver Rolls"] = "Silver", ["Gold Rolls"] = "Gold", ["Celestial Strike"] = "Celestial" }
oc = { Silver = "SilverRolls", Gold = "GoldRolls", Celestial = "CelestialStrike" }
n7 = Constants.RARITY_NAMES
xv_12 = type(n7) ~= "table"
if not xv_12 then
    xv_3 = 1
    repeat
        local yh = bit32.rrotate(bit32.bxor(bit32.lrotate(xv_3, 28), string.byte(tostring(xv_3))), 16)
        if bit32.bxor(bit32.lrotate(bit32.bxor(yh, 2896113342), 8), 2670640812) ~= bit32.lrotate(yh, 8) then
            n7 = #xv_12 == 0
        else
            xv_12 = #n7 == 0
        end
        xv_3 = (xv_3 + 4) % 8
    until (xv_3 * 5 + 6) % 8 == 7
end
if xv_12 then
    xv_3 = 0
    repeat
        if xv_3 * 35637535 + 4 + 1 <= xv_3 * 35637535 + 4 + 1 + 1 then
            n7 = { "Basic", "Uncommon", "Rare", "Epic", "Legendary" }
        else
            n7 = { "Uncommon", "Basic", "Epic", "Legendary", "Rare" }
        end
        xv_3 = (xv_3 + 2) % 4
    until (xv_3 * 3 + 0) % 4 == 2
end
n0, nW, nR, nN, Library, SaveManager, Toggles, Options, nt, n2, nK, nC, nu, oG, op, n9, nX, nL, oN, oq, oa, nY, nO, oQ, om, nI, nz, oE, og, nG, oR, oM, n1, oy, oT, nT, oI, ns, oh, nQ, od, ny, ol, n4, oS, nD, oO, oe, nE = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
n0 = 0
nW = 0
nR = 0
nN = 0
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
nt = fns.fn368
n2 = fn1045
nK = fns.fn220
nC = fn883
nu = fn865
oG = fn965
op = fn714
n9 = fn728
nX = fn707
nL = function(aR, ...)
    local p_
    p_ = nil
    local p4_1
    local p3_1
    local p2_1
    local p1_1
    local p0_1
    p_ = nX(aR)
    p0_1, p3_1, p2_1, p4_1, p1_1 = pcall(function(...)
        return p_:InvokeServer(...)
    end, ...)
    if not p0_1 then
        return nil
    end
    return p3_1, p2_1, p4_1, p1_1
end
oN = function(a0, ...)
    local a2
    a2 = n9(a0)
    pcall(function(...)
        a2:FireServer(...)
    end, ...)
end
if oq and not n1 and (nE and oq) and ((od or not od) and (not nX or od)) and not (oq and not n1 and (nE and oq) and ((od or not od) and (not nX or od))) then
    nO = fns.fn283
    oQ = fns.fn428
    oa = fn454
    nY = function(be, bf)
        local qo_2
        local qn_2
        qn_2, qo_2 = pcall(function()
            local getDisplayRarityRank = Constants.getDisplayRarityRank
            local ql = bf or "Normal"
            return getDisplayRarityRank(be, ql)
        end)
        local qp = qn_2 and type(qo_2) == "number"
        if qp then
            return qo_2
        end
        return 1
    end
    oq = fns.fn446
else
    oq = fns.fn283
    oa = fns.fn428
    nY = fn454
    nO = function(be, bf)
        local qo_1
        local qn_1
        qn_1, qo_1 = pcall(function()
            local getDisplayRarityRank = Constants.getDisplayRarityRank
            local ql = bf or "Normal"
            return getDisplayRarityRank(be, ql)
        end)
        local qp = qn_1 and type(qo_1) == "number"
        if qp then
            return qo_1
        end
        return 1
    end
    oQ = fns.fn446
end
om = function(bv, bw)
    local qK_1
    local qJ_1
    qJ_1, qK_1 = pcall(function()
        local getCombinedOdds = Constants.getCombinedOdds
        local qE = bw
        local qI = if qE then 1 else 0
        local qG = 80 * qI + 3929 * (1 - qI)
        local qH = 2899 * qI + 1949 * (1 - qI)
        if not ((qG * 3645 + qH * 784 + qG * qH) % 16777213 == 2796336) then
            qE = "Normal"
        end
        return getCombinedOdds(bv, qE)
    end)
    local qL = qJ_1 and type(qK_1) == "number"
    if qL then
        return qK_1
    end
    return 0
end
nI = fns.fn292
nz = fn482
oE = fn457
og = fns.fn68
if ((oS and oS or not ny and not nD) and ((ny or not Library) and (nG or Library)) or (Library or not nG or not oS and Toggles) and ((not nG or nD) and (Toggles or Toggles))) and not ((oS and oS or not ny and not nD) and ((ny or not Library) and (nG or Library)) or (Library or not nG or not oS and Toggles) and ((not nG or nD) and (Toggles or Toggles))) then
    oR = fn942
    n1 = fns.fn436
    nG = function()
        local ro
        ro = nil
        local rr_2
        local rq_3
        local rp = {}
        ro = nz()
        if not ro then
            return rp
        end
        rq_3, rr_2 = pcall(function()
            return ro:QueryDescendants("#StarCallerMeteor")
        end)
        local rs = rq_3 and type(rr_2) == "table"
        if rs then
            for k, v in rr_2 do
                if v.Parent then
                    rp[#rp + 1] = v
                end
            end
        end
        if #rp == 0 then
            local StarCallerMeteor = ro:FindFirstChild("StarCallerMeteor", true)
            if StarCallerMeteor then
                rp[1] = StarCallerMeteor
            end
        end
        return rp
    end
    oM = fn838
else
    nG = fn942
    oR = fns.fn436
    oM = function()
        local ro
        ro = nil
        local rr_1
        local rq_1
        local rp = {}
        ro = nz()
        if not ro then
            return rp
        end
        rq_1, rr_1 = pcall(function()
            return ro:QueryDescendants("#StarCallerMeteor")
        end)
        local rs = rq_1 and type(rr_1) == "table"
        if rs then
            for k, v in rr_1 do
                if v.Parent then
                    rp[#rp + 1] = v
                end
            end
        end
        if #rp == 0 then
            local StarCallerMeteor = ro:FindFirstChild("StarCallerMeteor", true)
            if StarCallerMeteor then
                rp[1] = StarCallerMeteor
            end
        end
        return rp
    end
    n1 = fn838
end
oy = function()
    local rO = oq()
    if type(rO) ~= "table" then
        return
    end
    local rP = nL("GetConstellationData")
    if type(rP) ~= "table" then
        return
    end
    local rQ = nY()
    local rR = {}
    for k, v in rO do
        if type(v) == "table" then
            local rT_1 = v.uuid or v.id or ""
            local rS_2 = tostring(rT_1)
            if rS_2 ~= "" and rS_2 ~= rQ then
                local rS_3 = tostring(v.starId)
                local rT_3 = v.variant or "Normal"
                local rU_2 = rS_3 .. "\x00" .. tostring(rT_3)
                local rS_4 = rR[rU_2] or 0
                rR[rU_2] = rS_4 + 1
            end
        end
    end
    for k, v in rP do
        local rP_1 = type(v) == "table" and v.unlocked == true and v.completed ~= true
        if rP_1 then
            local rP_2 = Constants.CONSTELLATIONS[k]
            local rQ_1 = rP_2 and rP_2.slots
            if type(rQ_1) == "table" then
                for i, v2 in ipairs(rQ_1) do
                    local sg = v2
                    local rP_4 = v.slots
                    if rP_4 then
                        local rQ_2 = v.slots[tostring(i)] or v.slots[i]
                        rP_4 = rQ_2
                    end
                    local rQ_3 = rP_4
                    if rQ_3 == nil or rQ_3 == false then
                        local rP_6 = nil
                        local rQ_4 = nil
                        local rS_6 = nil
                        for k, v in rO do
                            local rM
                            local sm = v
                            local rT_4 = type(sm) == "table" and type(sg) == "table"
                            if rT_4 then
                                local rN = sm.variant or "Normal"
                                local rT_6 = tostring(sm.starId) .. "\x00" .. tostring(rN)
                                if (rR[rT_6] or 0) > 0 then
                                    rM = false
                                    local rU_4 = pcall(function()
                                        rM = Constants.doesStarMatchSlot(sm.starId, rN, sg) == true
                                    end)
                                    if rU_4 and rM then
                                        local rU_5 = om(sm.starId, rN)
                                        if rP_6 == nil or rU_5 < rP_6 then
                                            rS_6 = sm
                                            rP_6 = rU_5
                                            rQ_4 = rT_6
                                        end
                                    end
                                end
                            end
                        end
                        if rS_6 then
                            rR[rQ_4] = rR[rQ_4] - 1
                            local starId = rS_6.starId
                            local rQ_5 = rS_6.variant or "Normal"
                            nL("PlaceConstellationStar", k, i, starId, rQ_5)
                            task.wait(0.15)
                        end
                    end
                end
            end
        end
    end
end
oT = fn497
nT = fns.fn249
oI = fn504
ns = fn593
oh = fn510
nQ = fns.fn138
od = fn998
ny = fn570
ol = function()
    local t2
    local t8_1
    local t3 = oa()
    local t4 = t3 and tonumber(t3.stardust)
    local t5 = t4 or 0
    local t5_6
    local t4_1 = t3
    local t6 = t5
    if t4_1 then
        t4_1 = t3.ownedDecor
    end
    local t5_1 = t4_1 or {}
    t2 = nil
    local t4_2 = pcall(function()
        t2 = Constants.getRotatingDecor(nil, true, LocalPlayer.UserId)
    end)
    local t5_2 = not t4_2
    local uc = if t5_2 then 1 else 0
    local ua = 3152 * uc + 1710 * (1 - uc)
    local ub = 2160 * uc + 1926 * (1 - uc)
    if not ((ua * 3569 + ub * 1235 + ua * ub) % 16777213 == 3948195) then
        t5_2 = type(t2) ~= "table"
    end
    if t5_2 then
        return
    end
    for i, v in ipairs(t2) do
        if type(v) == "string" then
            local t4_3 = t5_1[v]
            if t4_3 == nil or t4_3 == 0 then
                local t4_4 = Constants.getDecorDef and Constants.getDecorDef(v)
                local t5_4 = t4_4
                if t4_4 then
                    t4_4 = tonumber(t5_4.cost)
                end
                local t5_5 = t4_4 or 0
                local t4_5 = true
                if Constants.isDecorBuyable then
                    t5_6, t8_1 = pcall(Constants.isDecorBuyable, v)
                    if t5_6 then
                        t4_5 = t8_1 ~= false
                    end
                end
                local t5_7 = t4_5
                if t5_7 then
                    t5_7 = t5_5 <= 0 or t6 >= t5_5
                end
                if t5_7 then
                    nL("Decor_Purchase", "Buy", v)
                    t6 -= t5_5
                    task.wait(0.2)
                end
            end
        end
    end
end
n4 = fn1082
oS = fn485
nD = fn474
oO = fn927
oe = fn1014
nE = function()
    oN("AFK_SetState", false)
    local ve = tonumber(LocalPlayer:GetAttribute("TimeAwaySeconds")) or 0
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local vg = PlayerGui and PlayerGui:FindFirstChild("AFKClaimUI")
    local vg_1 = ve <= 0
    if vg_1 then
        vg_1 = not (vg and vg.Enabled ~= false)
    end
    if vg_1 then
        return
    end
    local vf_2 = nz()
    local vg_2 = vf_2 and vf_2:FindFirstChild("AFK_Net")
    local vh = vg_2
    local vg_3 = not vh
    if vg_3 ~= false then
        vg_3 = vf_2
    end
    if vg_3 then
        vh = vf_2:FindFirstChild("AFK_Net", true)
    end
    if vh then
        oE(vh)
    end
    if not vg then
        return
    end
    local vf_3 = vg:FindFirstChild("AcceptBtn", true) or vg:FindFirstChild("Accept", true)
    local vd = vf_3
    local ve_3 = vd and vd:IsA("GuiButton")
    if ve_3 then
        pcall(function()
            firesignal(vd.Activated)
        end)
        pcall(function()
            firesignal(vd.MouseButton1Click)
        end)
    end
end
xv_15 = Library:CreateWindow({
    Title = "Tempo Hub[Beta]",
    Footer = { { Text = of, Copyable = true }, "|", xv_5 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
Library.ShowCustomCursor = false
local pc = {
    Info = xv_15:AddTab("Info", "info"),
    Main = xv_15:AddTab("Main", "sparkles"),
    Player = xv_15:AddTab("Player", "person-standing"),
    Settings = xv_15:AddTab("Settings", "settings")
}
pc.Farm = pc.Main:AddSubTab("Farm", "sparkles")
pc.Upgrades = pc.Main:AddSubTab("Upgrades", "trending-up")
pc.Shop = pc.Main:AddSubTab("Shop", "shopping-bag")
pc.Claim = pc.Main:AddSubTab("Claim", "gift")
xv_12 = fns.fn70
for k, v in pc do
    if v ~= pc.Main then
        xv_12(v)
    end
end
nw = nil
xv_3 = 6
repeat
    xv_10 = (xv_3 * 1 + 1) % 2 + 1
    if xv_10 <= 1 then
        xv_10 = {
            "pikxbwx",
            "pcnpicxj",
            "uzvc",
            "fpxhrzcqeg",
            "jjb",
            "jmmsft",
            "viuqqwx",
            "qsk",
            "kexfdlessw",
            "hzp",
            "azrq",
            "jgmoahtuy",
            "ywileiq",
            "djtydvutt",
            "qyvcmowofgoo",
            "mcju"
        }
        if xv_10[(xv_3 * 18 + 36) % 16 + 1] <= xv_10[(xv_3 * 18 + 36) % 16 + 1] then
            pcall(fn527)
        else
            pcall(fn527)
        end
        xv_3 = (xv_3 + 9) % 16
    else
        xv_10 = {
            "awrrasmf",
            "qvywkbaydyom",
            "ywa",
            "hgla",
            "dfrkv",
            "qmtwpolbfvt",
            "psbvamxyruvf",
            "ckdqbjpteww",
            "uzhoqqmjbrbj",
            "tkccqybzyuz",
            "klvvvrxnml",
            "voqdrekjker",
            "hkexnuhztz",
            "eax"
        }
        if xv_10[(xv_3 * 42 + 25) % 14 + 1] < xv_10[(xv_3 * 42 + 25) % 14 + 1] then
            nw = "Unknown"
        else
            nw = "Unknown"
        end
        xv_3 = (xv_3 + 3) % 16
    end
until (xv_3 * 5 + 8) % 16 == 2
xv_12, Label, ox, xv_6 = nil, nil, nil, nil
xv_10 = 3
repeat
    xv_3 = (xv_10 * 1 + 2) % 3 + 1
    if xv_3 <= 2 then
        if xv_3 <= 1 then
            local yK = bit32.rrotate(bit32.bxor(bit32.lrotate(xv_10, 19), string.byte(tostring(ox))), 30)
            if bit32.bxor(bit32.lrotate(bit32.bxor(yK, 2750190681), 18), 1365675954) ~= bit32.lrotate(yK, 18) then
                xv_6 = tostring(game.JobId)
            else
                ox = tostring(game.JobId)
            end
            xv_10 = (xv_10 + 4) % 12
        else
            if ((xv_12 and xv_6 or (xv_6 or not ox)) and ((xv_6 or ox) and (not ox or xv_6)) and (not ox or xv_6 or not xv_6 and not xv_12 or ox and xv_6 and (not ox or not xv_12)) or (xv_6 and not xv_12 or xv_6 and xv_12 or (not xv_12 or xv_6 or (xv_12 or ox))) and (not xv_6 and not ox and (xv_12 and not xv_6) and (not xv_6 and not xv_12 or xv_6 and not xv_6))) and not ((xv_12 and xv_6 or (xv_6 or not ox)) and ((xv_6 or ox) and (not ox or xv_6)) and (not ox or xv_6 or not xv_6 and not xv_12 or ox and xv_6 and (not ox or not xv_12)) or (xv_6 and not xv_12 or xv_6 and xv_12 or (not xv_12 or xv_6 or (xv_12 or ox))) and (not xv_6 and not ox and (xv_12 and not xv_6) and (not xv_6 and not xv_12 or xv_6 and not xv_6))) then
                ox = #xv_6 > 18
            else
                xv_6 = #ox > 18
            end
            xv_10 = (xv_10 + 4) % 12
        end
    else
        local yE = bit32.rrotate(bit32.bxor(bit32.lrotate(xv_10, 1), string.byte(tostring(xv_6))), 23)
        if bit32.bxor(bit32.lrotate(bit32.bxor(yE, 1147590442), 8), 1725377092) ~= bit32.lrotate(yE, 8) then
            xv_12 = nu.Info:AddLeftGroupbox("Account", "circle-user")
            xv_12:AddLabel(nw("User", nil, xv_5), true)
            xv_12:AddLabel(nw("Status", "Keyless", xv_5), true)
            xv_12:AddLabel(nw("Executor", LocalPlayer, xv_5), true)
            pc = nu.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            pc:AddLabel(Label(o8 .. " [" .. tostring(game.PlaceId) .. "]", oL), true)
            pc:AddLabel(nw("Place ID", tostring(game.PlaceId), oL), true)
            pc:AddLabel(nw("Session time", "0s", nC), true)
        else
            xv_15 = pc.Info:AddLeftGroupbox("Account", "circle-user")
            xv_15:AddLabel(nu("User", LocalPlayer.Name, o8), true)
            xv_15:AddLabel(nu("Status", "Keyless", o8), true)
            xv_15:AddLabel(nu("Executor", nw, o8), true)
            xv_12 = pc.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            xv_12:AddLabel(nC(xv_5 .. " [" .. tostring(game.PlaceId) .. "]", o7), true)
            xv_12:AddLabel(nu("Place ID", tostring(game.PlaceId), o7), true)
            Label = xv_12:AddLabel(nu("Session time", "0s", oL), true)
        end
        xv_10 = (xv_10 + 7) % 12
    end
until (xv_10 * 11 + 7) % 12 == 1
if xv_6 then
    xv_3 = 3
    repeat
        xv_10 = (vector.create((xv_3 * 5 + 9) % 11 + 1, (xv_3 * 8 + 13) % 13 + 1, (xv_3 * 2 + 8) % 17 + 1))
        xv_15 = (vector.create((xv_3 * 3 + 8) % 11 + 1, (xv_3 * 10 + 13) % 13 + 1, (xv_3 * 5 + 1) % 17 + 1))
        local yi = vector.cross(xv_10, xv_15)
        local yj = vector.dot(xv_10, xv_15)
        if vector.dot(yi, yi) + yj * yj == vector.dot(xv_10, xv_10) * vector.dot(xv_15, xv_15) + 3 then
            ox = string.sub(xv_6, 1, 18) .. "..."
        else
            xv_6 = string.sub(ox, 1, 18) .. "..."
        end
        xv_3 = (xv_3 + 2) % 8
    until (xv_3 * 7 + 5) % 8 == 0
end
xv_3 = xv_6 or ox
n8, TempoHubGroup, DonationsGroup, FaqGroup, Polish_SellGroup, AutoUpgradeGroup, xv_6 = nil, nil, nil, nil, nil, nil, nil
local pn = xv_3
xv_12:AddLabel(nu("Server", pn, o6), true)
xv_12:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
n8 = os.clock()
task.spawn(worker)
local ScriptsGroup = pc.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(nC("Included in this hub", o6), true)
ScriptsGroup:AddLabel(nC(xv_5, o7), true)
local FeaturesGroup = pc.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(nC("Auto Farm", o7), true)
FeaturesGroup:AddLabel(nC("Auto Upgrade", oL), true)
FeaturesGroup:AddLabel(nC("Auto Shop", o8), true)
FeaturesGroup:AddLabel(nC("Auto Claim", o6), true)
xv_15 = pc.Info:AddRightGroupbox("Socials", "link")
if ((not pn or not xv_6) and (not pn and pn) or (not pn and not pn or (xv_6 or not pn))) and ((not pn or pn) and (pn and pn) or (xv_6 or xv_6) and (not xv_6 or not pn)) and not (((not pn or not xv_6) and (not pn and pn) or (not pn and not pn or (xv_6 or not pn))) and ((not pn or pn) and (pn and pn) or (xv_6 or xv_6) and (not xv_6 or not pn))) then
    nK:AddButton({ Text = "Discord", Func = xv_15 })
    nK:AddButton({ Text = "Rscripts", Func = onRscripts })
    pc = TempoHubGroup.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
else
    xv_15:AddButton({ Text = "Discord", Func = nK })
    xv_15:AddButton({ Text = "Rscripts", Func = onRscripts })
    TempoHubGroup = pc.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
end
if AutoUpgradeGroup and not Polish_SellGroup and (AutoUpgradeGroup and not TempoHubGroup) and (AutoUpgradeGroup and not Polish_SellGroup or (TempoHubGroup or not TempoHubGroup)) or (not AutoUpgradeGroup or not AutoUpgradeGroup or Polish_SellGroup and not TempoHubGroup) and (Polish_SellGroup and Polish_SellGroup or (not AutoUpgradeGroup or AutoUpgradeGroup)) or not (AutoUpgradeGroup and not Polish_SellGroup and (AutoUpgradeGroup and not TempoHubGroup) and (AutoUpgradeGroup and not Polish_SellGroup or (TempoHubGroup or not TempoHubGroup)) or (not AutoUpgradeGroup or not AutoUpgradeGroup or Polish_SellGroup and not TempoHubGroup) and (Polish_SellGroup and Polish_SellGroup or (not AutoUpgradeGroup or AutoUpgradeGroup))) then
    TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = nK })
    DonationsGroup = pc.Info:AddRightGroupbox("Donations", "heart")
else
    nK:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    nK:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    nK:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    nK:AddButton({ Text = "Copy Discord Invite", Func = TempoHubGroup })
    pc = DonationsGroup.Info:AddRightGroupbox("Donations", "heart")
end
if (xv_6 or false) and not (xv_6 or false) then
    o6:AddLabel(xv_2("All donations are optional but appreciated.", o7), true)
    o6:AddLabel(xv_2("If you donate you get a special role, just PING after you donate.", pc), true)
    o6:AddDivider()
    o6:AddLabel(xv_2("LTC / Litecoin", xv_7), true)
    o6:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
    o6:AddLabel(xv_2("BTC / Bitcoin", nC), true)
    o6:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
    o6:AddLabel(xv_2("ETH / Ethereum", xv_14), true)
    o6:AddButton({ Text = "Copy Ethereum Address", Func = fns.onCopyEthereumAddress })
    o6:AddLabel(xv_2("USDT", o8), true)
    o6:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
    o6:AddLabel(xv_2("Solana", o9), true)
    o6:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
    o6:AddLabel(xv_2("PayPal", oL), true)
    o6:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
    o6:AddLabel(xv_2("Venmo", xv_1), true)
    o6:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
    o6:AddDivider()
    o6:AddLabel(xv_2("Don't have any of the listed currencies but still wanna donate?", xv_9), true)
    o6:AddLabel(xv_2("DM me and we'll work something out.", xv_13), true)
    FaqGroup.Info:AddRightGroupbox("FAQ", "circle-help")
else
    DonationsGroup:AddLabel(nC("All donations are optional but appreciated.", oL), true)
    DonationsGroup:AddLabel(nC("If you donate you get a special role, just PING after you donate.", o8), true)
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(nC("LTC / Litecoin", xv_14), true)
    DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
    DonationsGroup:AddLabel(nC("BTC / Bitcoin", xv_9), true)
    DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
    DonationsGroup:AddLabel(nC("ETH / Ethereum", xv_2), true)
    DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = fns.onCopyEthereumAddress })
    DonationsGroup:AddLabel(nC("USDT", xv_13), true)
    DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
    DonationsGroup:AddLabel(nC("Solana", xv_7), true)
    DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
    DonationsGroup:AddLabel(nC("PayPal", xv_1), true)
    DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
    DonationsGroup:AddLabel(nC("Venmo", o9), true)
    DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(nC("Don't have any of the listed currencies but still wanna donate?", o6), true)
    DonationsGroup:AddLabel(nC("DM me and we'll work something out.", o7), true)
    FaqGroup = pc.Info:AddRightGroupbox("FAQ", "circle-help")
end
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
local AutoFarmGroup = pc.Farm:AddLeftGroupbox("Auto Farm", "sparkles")
AutoFarmGroup:AddToggle("AutoFillObservatories", { Text = "Auto Fill Observatories", Default = false })
AutoFarmGroup:AddToggle("AutoEquipBestStars", { Text = "Auto Equip Best Stars", Default = false })
AutoFarmGroup:AddToggle("AutoCrackMeteors", { Text = "Auto Crack Meteors", Default = false })
AutoFarmGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
Polish_SellGroup = pc.Farm:AddRightGroupbox("Polish & Sell", "star")
Polish_SellGroup:AddToggle("AutoPolishStars", { Text = "Auto Polish Stars", Default = false })
Polish_SellGroup:AddToggle("AutoSellStars", { Text = "Auto Sell Stars", Default = false })
Polish_SellGroup:AddDropdown("SellRarity", { Text = "Sell Up To", Values = n7, Default = "Uncommon" })
AutoUpgradeGroup = pc.Upgrades:AddLeftGroupbox("Auto Upgrade", "trending-up")
AutoUpgradeGroup:AddToggle("AutoUpgradeNet", { Text = "Auto Upgrade Net", Default = false })
AutoUpgradeGroup:AddToggle("AutoUpgradeTree", { Text = "Auto Upgrade Tree", Default = false })
AutoUpgradeGroup:AddToggle("AutoCalibration", { Text = "Auto Calibration Telescope", Default = false })
local AutoBuyGroup = pc.Shop:AddLeftGroupbox("Auto Buy", "shopping-bag")
AutoBuyGroup:AddToggle("AutoBuyDecorToday", { Text = "Auto Buy Today's Selection", Default = false })
AutoBuyGroup:AddToggle("AutoBuyStarWax", { Text = "Auto Buy Star Wax", Default = false })
AutoBuyGroup:AddToggle("AutoBuyBlessings", { Text = "Auto Buy Blessings", Default = false })
AutoBuyGroup:AddDropdown("BlessingTypes", { Text = "Blessings", Values = xv_11, Default = { "Silver Rolls" }, Multi = true })
local AutoClaimGroup = pc.Claim:AddLeftGroupbox("Auto Claim", "gift")
AutoClaimGroup:AddToggle("AutoClaimQuests", { Text = "Auto Claim Quests", Default = false })
AutoClaimGroup:AddToggle("AutoClaimMail", { Text = "Auto Claim Mail", Default = false })
AutoClaimGroup:AddToggle("AutoClaimRewards", { Text = "Auto Claim Rewards", Default = false })
AutoClaimGroup:AddToggle("AutoClaimNet", { Text = "Auto Claim Net", Default = false })
xv_6 = pc.Player:AddLeftGroupbox("Movement", "footprints")
xv_6:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
xv_6:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
xv_6:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
xv_6:AddToggle("NoClip", { Text = "NoClip", Default = false })
xv_6:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
xv_10 = pc.Player:AddRightGroupbox("Fly", "feather")
xv_10:AddToggle("Fly", { Text = "Fly", Default = false })
xv_10:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
connection, nv, oJ, oC, connection2, connection3, nZ, oj, oF, n6, nS, oB = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
fns.fn396()
connection = RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fns.fn136)
Toggles.WalkSpeedEnabled:OnChanged(fn1050)
RunService.Stepped:Connect(fns.onStepped)
UserInputService.JumpRequest:Connect(fns.onJumpRequest)
nv = Workspace.CurrentCamera
RunService.RenderStepped:Connect(fns.onRenderStepped2)
nZ = function(h_)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not h_)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not h_
        end
    end)
    if not h_ then
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
Toggles.AntiGameplayPause:OnChanged(fns.fn116)
local MenuGroup = pc.Settings:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
oJ = tick()
oC = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local wa = v
        pcall(function()
            wa:Disable()
        end)
    end
end)
oj = fns.fn246
connection2 = UserInputService.InputBegan:Connect(onInputBegan)
connection3 = UserInputService.InputChanged:Connect(fns.onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
Library:OnUnload(fn918)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/StarCatchers")
local pr = SaveManager:BuildConfigSection(pc.Settings)
oF = fn687
n6 = fn907
if (MenuGroup or oJ) and (not oJ and MenuGroup) and ((MenuGroup or not MenuGroup) and (not oJ and MenuGroup)) and not ((MenuGroup or oJ) and (not oJ and MenuGroup) and ((MenuGroup or not MenuGroup) and (not oJ and MenuGroup))) then
    oB = fn708
    nS = function(i5)
        local wQ
        wQ = nil
        local wR = type(i5) ~= "table" or type(i5.idx) ~= "string" or type(i5.type) ~= "string" or SaveManager.Ignore[i5.idx]
        if wR then
            return false
        end
        wQ = oF(i5.type, i5.idx)
        if not wQ then
            return false
        end
        local wR_2 = pcall(function()
            if i5.type == "Input" then
                if type(i5.text) ~= "string" then
                    return
                end
                wQ:SetValue(i5.text)
            elseif i5.type == "ColorPicker" then
                wQ:SetValueRGB(Color3.fromHex(i5.value), i5.transparency)
            elseif i5.type == "KeyPicker" then
                wQ:SetValue({ i5.key, i5.mode, i5.modifiers })
                if i5.mode == "Toggle" and i5.toggled ~= nil then
                    wQ.Toggled = i5.toggled
                    wQ:Update()
                end
            else
                wQ:SetValue(i5.value)
            end
        end)
        return wR_2
    end
else
    nS = fn708
    oB = function(i5)
        local wQ
        wQ = nil
        local wR = type(i5) ~= "table" or type(i5.idx) ~= "string" or type(i5.type) ~= "string" or SaveManager.Ignore[i5.idx]
        if wR then
            return false
        end
        wQ = oF(i5.type, i5.idx)
        if not wQ then
            return false
        end
        local wR_1 = pcall(function()
            if i5.type == "Input" then
                if type(i5.text) ~= "string" then
                    return
                end
                wQ:SetValue(i5.text)
            elseif i5.type == "ColorPicker" then
                wQ:SetValueRGB(Color3.fromHex(i5.value), i5.transparency)
            elseif i5.type == "KeyPicker" then
                wQ:SetValue({ i5.key, i5.mode, i5.modifiers })
                if i5.mode == "Toggle" and i5.toggled ~= nil then
                    wQ.Toggled = i5.toggled
                    wQ:Update()
                end
            else
                wQ:SetValue(i5.value)
            end
        end)
        return wR_1
    end
end
do
    pr:AddDivider()
    pr:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    pr:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    pr:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
    ThemeManager:ApplyToTab(pc.Settings)
    ThemeManager:LoadDefault()
    SaveManager:LoadAutoloadConfig()
    task.spawn(fns.autoRollLoop)
    task.spawn(autoCrackMeteorsLoop)
    task.spawn(fns.autoFillObservatoriesLoop)
    task.spawn(fns.autoEquipBestStarsLoop)
    task.spawn(fns.autoPolishStarsLoop)
    task.spawn(fns.autoSellStarsLoop)
    task.spawn(autoUpgradeNetLoop)
    task.spawn(autoBuyDecorTodayLoop)
    task.spawn(autoClaimQuestsLoop)
    task.spawn(antiGameplayPauseLoop)
    task.spawn(fns.antiAfkLoop)
    Library:Notify("Star Catchers loaded")
end
end)(...)

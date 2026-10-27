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
getgenv().TempoHoodSubtitle = "MY ANIME MINE"
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
local tn
local s4
local tq
local tt
local ta
local tw
local sS
local tz
local td
local sV
local tC
local tg
local sY
local tj
local tF
local s0
local tm
local tI
local tp
local tL
local State
local tv
local s9
local tc
local sU
local tB
local tf
local LocalPlayer
local tE
local s_
local tH
local s2
local tK
local to
local tr
local s8
local tu
local CoreGui
local sT
local th
local tk
local sZ
local tG
local s1
local tJ
local function fn28(dS)
    local xL_1
    local xF_1
    local xK_1
    local xJ_1, xJ_3
    local xE_1, xE_3
    local xC = tk("MineConfig")
    local xD = not xC or type(xC.CoreNodes) ~= "table" or type(xC.CoreUpgradeById) ~= "table"
    if xD then
        return 0
    end
    local xD_1 = s9(xC.IsCoreNodeOpen) and s9(xC.IsCoreNodeMaxed) and s9(xC.GetCoreLevel)
    if not xD_1 then
        return 0
    end
    local xD_2 = 0
    for i, v in ipairs(xC.CoreNodes) do
        if not s1() then
            break
        end
        xE_1, xF_1 = tI()
        if not xE_1 then
            break
        else
            local xG = xC.CoreUpgradeById[v.Family]
            local xH = xG and xG.Event
            local xH_2, xH_4, xH_6
            local xH_1 = type(xH) == "string" and s9(xG.Cost)
            if xH_1 then
                xH_2, xJ_1 = pcall(xC.IsCoreNodeOpen, xE_1, v)
                xK_1, xL_1 = pcall(xC.IsCoreNodeMaxed, xE_1, v)
                if xH_2 and xJ_1 and xK_1 and not xL_1 then
                    xH_4, xJ_3 = pcall(xC.GetCoreLevel, xE_1, v.Family)
                    local xE_2 = xH_4 and type(xJ_3) == "number"
                    if xE_2 then
                        local xH_5 = type(xG.Max) ~= "number" or xJ_3 < xG.Max
                        xE_2 = xH_5
                    end
                    if xE_2 then
                        xE_3, xH_6 = pcall(xG.Cost, xJ_3)
                        local xG_1 = xE_3 and type(xH_6) == "number" and xH_6 <= sU(xF_1) - dS
                        if xG_1 then
                            if tm(xH) then
                                xD_2 += 1
                                State.Purchases = State.Purchases + 1
                                task.wait(tt)
                            end
                        end
                    end
                end
            end
        end
    end
    return xD_2
end
local function fn32(fR, fS)
    local zH_1, zH_4
    local zy = tk("MineConfig")
    local zz = tk("MineStock")
    local zA = not zy
    local zN = if zA then 1 else 0
    local zL = 3526 * zN + 1375 * (1 - zN)
    local zM = 412 * zN + 2804 * (1 - zN)
    if not ((zL * 2360 + zM * 631 + zL * zM) % 16777213 == 10034044) then
        zA = type(zy.Pickaxes) ~= "table"
    end
    if zA then
        return {}
    end
    local PickaxeNames = State.PickaxeNames
    local zC = fR.UnlockedZones or {}
    local zC_1 = sU(fS)
    local zD = {}
    for i, v in ipairs(zy.Pickaxes) do
        local zE = tonumber(v.Cost) or math.huge
        local zE_1
        local zF = false
        local zF_3
        if s9(zy.IsPickaxeFree) then
            zE_1, zH_1 = pcall(zy.IsPickaxeFree, v)
            zF = zE_1 and zH_1 == true
        end
        local zE_2 = type(v.Stock) == "table" and not v.RobuxOnly
        local zE_3 = zE_2 and not zF
        local zF_1 = tz(PickaxeNames) or PickaxeNames[v.Name] == true
        local zH_3 = zE_3
        if zH_3 then
            zH_3 = zF_1
        end
        if zH_3 then
            zH_3 = zC[v.ZoneReq]
        end
        if zH_3 then
            zH_3 = zE <= zC_1
        end
        if zH_3 then
            local zE_5 = nil
            local zF_2 = zz and s9(zz.GetRemaining)
            if zF_2 then
                zF_3, zH_4 = pcall(zz.GetRemaining, fS, v.Name)
                if zF_3 then
                    zE_5 = tonumber(zH_4)
                end
            end
            if zE_5 == nil or zE_5 > 0 then
                table.insert(zD, { Index = i, Name = v.Name, Cost = zE, Remaining = zE_5 })
            end
        end
    end
    table.sort(zD, function(gg, gh)
        return gg.Cost < gh.Cost
    end)
    return zD
end
local function fn52(gL)
    local Aa = tonumber(gL) or 0.12
    State.ClickDelay = math.clamp(Aa, 0.05, 2)
end
local function fn73(cy)
    local wv = {}
    if type(cy) == "table" then
        for k, v in pairs(cy) do
            local ww_1 = type(k) == "string" and v
            if ww_1 then
                wv[k] = true
            else
                local ww_2 = type(k) == "number" and type(v) == "string"
                if ww_2 then
                    wv[v] = true
                end
            end
        end
    else
        local ww_3 = cy ~= ""
        local wx = type(cy) == "string" and ww_3
        if wx then
            wv[cy] = true
        end
    end
    return wv
end
local function fn132(gV)
    State.BuyCoreUpgrades = gV == true
end
local function fn134(c9)
    local w5 = {}
    local w6 = 0
    for i, v in ipairs(c9) do
        table.insert(w5, v)
        if #w5 >= tE then
            if tm("MineSellItems", w5) then
                w6 += #w5
            end
            w5 = {}
            task.wait(tB)
            if not s1() then
                return w6
            end
        end
    end
    local w7 = #w5 > 0 and tm("MineSellItems", w5)
    if w7 then
        w6 += #w5
    end
    return w6
end
local function fn164()
    local Character = LocalPlayer.Character
    local vc = Character and Character:FindFirstChild("HumanoidRootPart")
    return vc or nil
end
local function fn180()
    for i, v in ipairs({ tj, tF, tn }) do
        if coroutine.status(v) ~= "dead" then
            pcall(task.cancel, v)
        end
    end
end
local function worker3()
    while s1() do
        if State.AutoSell and not s4 then
            local AE_1 = tI()
            if AE_1 then
                local AF_1 = tp(AE_1)
                local AE_2 = 0
                for i, v in ipairs(AF_1) do
                    local AG_1 = tonumber(v.SellCount) or tonumber(v.Count)
                    local AH = AG_1 or 0
                    AE_2 += AH
                end
                local AG_2 = #AF_1 > 0 and AE_2 >= math.max(1, State.SellAtCount)
                if AG_2 then
                    tu.SellNow()
                end
            end
        end
        local AE_3 = s1() and State.AutoUpgrades
        if AE_3 then
            tu.BuyUpgradesNow()
        end
        local AE_4 = s1() and State.AutoZones
        if AE_4 then
            tu.BuyZonesNow()
        end
        local AE_5 = s1() and State.AutoPickaxes
        if AE_5 then
            tu.BuyPickaxesNow()
        end
        task.wait(5)
    end
end
local function fn231(gZ)
    local Ah = tonumber(gZ) or 0
    State.UpgradeReserve = math.max(0, Ah)
end
local function fn236(gN)
    State.AutoEquipBest = gN == true
end
local function fn248(g6)
    State.PickaxeNames = s2(g6)
end
local function fn251(gJ)
    local z6 = gJ ~= ""
    local z7 = type(gJ) == "string" and z6
    if z7 then
        State.TargetMode = gJ
    end
end
local function fn260(hh)
    local Ak = (tonumber(hh))
    local Ao = if Ak then 1 else 0
    local Am = 3245 * Ao + 3364 * (1 - Ao)
    local An = 1802 * Ao + 701 * (1 - Ao)
    if not ((Am * 737 + An * 3865 + Am * An) % 16777213 == 15203785) then
        Ak = 0
    end
    State.SellKeepAbove = math.max(0, Ak)
end
local function fn267()
    return CoreGui
end
local function fn285()
    local w0_1
    local w__1
    local SellStand = tJ:FindFirstChild("SellStand")
    if not SellStand then
        return nil
    end
    w__1, w0_1 = pcall(SellStand.GetPivot, SellStand)
    if not w__1 then
        return nil
    end
    return w0_1.Position
end
local function worker2()
    while s1() do
        if State.AutoEquipBest then
            tm("MineEquipBest")
        end
        if State.AutoChest then
            local Ay = tI()
            local Az = Ay and tc(Ay) >= State.ChestThreshold
            if Az then
                tm("MineTakeChest")
            end
        end
        task.wait(3)
    end
end
local function fn312(g0)
    State.AutoZones = g0 == true
end
local function fn314(bm)
    local vg_1
    local vf_1
    local ve = tg()
    if not ve then
        return math.huge
    end
    vf_1, vg_1 = pcall(bm.GetPivot, bm)
    if not vf_1 then
        return math.huge
    end
    return (vg_1.Position - ve.Position).Magnitude
end
local function fn326(aT, ...)
    local uN = tk("GameState")
    local uO = not uN or not s9(uN.SendEvent)
    if uO then
        return false
    end
    return (pcall(uN.SendEvent, aT, ...))
end
local function fn377()
    local xt = tI()
    if not xt then
        return false, "Mine data is not available yet"
    elseif tc(xt) <= 0 then
        return false, "The plot chest is empty"
    else
        local xx = if not tm("MineTakeChest") then 1 else 0
        if xx == 1 then
            return false, "Failed to send the chest request"
        end
        return true, "Requested every item in the plot chest"
    end
end
local function fn381(gH)
    State.AutoMine = gH == true
end
local function fn445(eX)
    local yF = tk("MineConfig")
    local yG = not yF or type(yF.ZoneKeys) ~= "table"
    if yG then
        return nil, nil
    end
    local yH = eX.UnlockedZones or {}
    for i, v in ipairs(yF.ZoneKeys) do
        if not yH[v] then
            return v, yF.Zones and yF.Zones[v]
        end
    end
    return nil, nil
end
local function fn485(cE)
    return next(cE) == nil
end
local function fn514(g4)
    State.AutoPickaxes = g4 == true
end
local function fn518(g9)
    State.AutoSell = g9 == true
end
local function fn526()
    local vm_1
    local vl_1
    local vk_1
    local vi = s0()
    if #vi == 0 then
        return nil
    end
    local TargetMode = State.TargetMode
    if TargetMode == "Focused First" then
        for i, v in ipairs(vi) do
            if v:GetAttribute("MineFocus") == true then
                return v
            end
        end
    end
    vl_1, vk_1 = nil, nil
    for i, v in ipairs(vi) do
        if TargetMode == "Highest Health" then
            local vi_1 = tonumber(v:GetAttribute("NodeHP")) or 0
            vm_1 = -vi_1
        elseif TargetMode == "Nearest" then
            vm_1 = sY(v)
        else
            local vi_2 = tonumber(v:GetAttribute("NodeHP")) or math.huge
            vm_1 = vi_2
        end
        if vk_1 == nil or vm_1 < vk_1 then
            vl_1, vk_1 = v, vm_1
        end
    end
    return vl_1
end
local function fn537(cG)
    local SellKinds = State.SellKinds
    local SellRarities = State.SellRarities
    local wH = (tonumber(State.SellKeepAbove))
    local wS = if wH then 1 else 0
    local wQ = 1739 * wS + 3185 * (1 - wS)
    local wR = 1122 * wS + 2033 * (1 - wS)
    if not ((wQ * 1290 + wR * 1673 + wQ * wR) % 16777213 == 6071574) then
        wH = 0
    end
    local wI = {}
    local wJ = wH
    for i, v in ipairs(tH(cG)) do
        local wH_1 = tonumber(v.SellCount) or tonumber(v.Count)
        local wK = wH_1 or 0
        local wK_1 = tonumber(v.Worth) or 0
        local wK_2 = tostring(v.Kind)
        local wM = v.Rarity and tostring(v.Rarity)
        local wN = wM or nil
        local wN_1 = tz(SellKinds) or SellKinds[wK_2] == true
        local wN_2 = (tz(SellRarities))
        if not wN_2 then
            wN_2 = wN ~= nil and SellRarities[wN] == true
        end
        local wM_2 = wN_2
        if wK > 0 and wK_1 > 0 and wN_1 and wM_2 and (wJ <= 0 or wK_1 <= wJ) then
            table.insert(wI, v)
        end
    end
    return wI
end
local function fn551(gP)
    State.AutoChest = gP == true
end
local function fn554(hn)
    State.SellReturn = hn == true
end
local function fn563(gX)
    State.BuyZoneSkills = gX == true
end
local function fn568(hl)
    State.SellTeleport = hl == true
end
local function fn577()
    local u1 = tC()
    local u2 = u1 and u1:FindFirstChild("Nodes")
    if not u2 then
        return {}
    end
    local u2_1 = {}
    for i, child in ipairs(u2:GetChildren()) do
        local u1_2 = (child:IsA("Model"))
        if u1_2 then
            local u3 = tonumber(child:GetAttribute("NodeHP")) or 0
            u1_2 = u3 > 0
        end
        if u1_2 then
            table.insert(u2_1, child)
        end
    end
    return u2_1
end
local function fn581(e5, e6)
    local yV_1
    local yT = tk("MineConfig")
    local yU = not yT or not s9(yT.ZoneResearchGateFor) or not s9(yT.IsZoneResearchComplete)
    local yU_1, yU_2
    if yU then
        return true, nil
    end
    yU_1, yV_1 = pcall(yT.ZoneResearchGateFor, e6)
    local yW = not yU_1 or type(yV_1) ~= "string"
    local yW_1
    if yW then
        return true, nil
    end
    yU_2, yW_1 = pcall(yT.IsZoneResearchComplete, e5.Skills, yV_1)
    return yU_2 and yW_1 == true, yV_1
end
local function fn629()
    local v0 = tk("MineConfig")
    local v1 = v0 and v0.RarityOrder
    if type(v1) ~= "table" then
        return {}
    end
    local v1_1 = {}
    for i, v in ipairs(v1) do
        table.insert(v1_1, v)
    end
    return v1_1
end
local function fn641(bV)
    local vK = 0
    for i, v in ipairs(sV(bV)) do
        local vL = tonumber(v.Count) or 0
        vK += vL
    end
    return vK
end
local function fn670()
    local up = {}
    local uu = if not s9(fireclickdetector) then 1 else 0
    if uu == 1 then
        table.insert(up, "fireclickdetector")
    end
    local uq = s9(setclipboard) or s9(toclipboard)
    if not uq then
        table.insert(up, "clipboard")
    end
    return up
end
local function worker()
    while s1() do
        local At = 0.3
        if State.AutoMine then
            At = State.ClickDelay
            local Au = tv()
            if Au then
                local Av = tonumber(Au:GetAttribute("NodeHP")) or 0
                if th(Au) then
                    local Av_1 = Au:GetAttribute("NodeTitle") or Au.Name
                    sZ("Mining " .. tostring(Av_1))
                    local Av_2 = Av > 0
                    if Av_2 then
                        local Aw_1 = tonumber(Au:GetAttribute("NodeHP")) or 0
                        Av_2 = Aw_1 <= 0
                    end
                    if Av_2 then
                        State.Broken = State.Broken + 1
                    end
                else
                    sZ("This executor cannot click mine nodes")
                    At = 1
                end
            else
                sZ("No node ready on your plot")
                At = 0.5
            end
        elseif not s4 then
            sZ("Idle")
        end
        task.wait(At)
    end
end
local function fn674(am)
    State.Status = am
end
local function fn680(el, em)
    local x7_1
    local x6_1
    local x5_1
    local x4_1
    local x3_1
    local x2_1
    local xX = tk("MineConfig")
    local xY = not xX or type(xX.ZoneKeys) ~= "table" or not s9(xX.GetSkillNodes)
    if xY then
        return 0
    end
    local xY_1 = s9(xX.IsSkillNodeOpen) and s9(xX.IsSkillNodeMaxed) and s9(xX.GetSkillMax) and s9(xX.GetSkillCost)
    if not xY_1 then
        return 0
    end
    local xY_2 = 0
    for i, v in ipairs(xX.ZoneKeys) do
        local xZ = em == v
        local xZ_2, xZ_3, xZ_6
        local x_ = em == nil or xZ
        local x__2, x__3
        if x_ then
            if not s1() then
                break
            end
            local xZ_1 = tI()
            if not xZ_1 then
                break
            else
                local x0 = xZ_1.UnlockedZones or {}
                local x0_5
                if x0[v] then
                    xZ_2, x__2 = pcall(xX.GetSkillNodes, v)
                    local x0_1 = xZ_2 and type(x__2) == "table"
                    if x0_1 then
                        for i, v2 in ipairs(x__2) do
                            if not s1() then
                                break
                            end
                            xZ_3, x__3 = tI()
                            if not xZ_3 then
                                break
                            else
                                local x0_3 = (xZ_3.Skills or {})[v] or {}
                                local x0_4 = tonumber(x0_3[v2.Family]) or 0
                                x0_5, x2_1 = pcall(xX.IsSkillNodeOpen, x0_3, v2)
                                x3_1, x4_1 = pcall(xX.IsSkillNodeMaxed, x0_3, v2)
                                xZ_6, x5_1 = pcall(xX.GetSkillMax, v, v2.Family)
                                x6_1, x7_1 = pcall(xX.GetSkillCost, v, x0_4, v2.Family)
                                local x8 = x0_5 and x2_1 and x3_1 and not x4_1 and xZ_6 and type(x5_1) == "number" and x0_4 < x5_1
                                if x8 then
                                    local xZ_7 = x6_1 and type(x7_1) == "number" and x7_1 <= sU(x__3) - el
                                    if xZ_7 then
                                        if tm("MineBuySkill", v, v2.Family) then
                                            xY_2 += 1
                                            State.Purchases = State.Purchases + 1
                                            task.wait(tt)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return xY_2
end
local function fn717()
    return string.format("%s | broken %d | sold %d | bought %d", State.Status, State.Broken, State.Sold, State.Purchases)
end
local function fn748(bH)
    if not s9(fireclickdetector) then
        return false
    end
    local vA = bH:FindFirstChild("NodeClick")
    local vB = not vA or not vA:IsA("ClickDetector")
    if vB then
        vA = bH:FindFirstChildOfClass("ClickDetector")
    end
    if not vA then
        return false
    end
    return (pcall(fireclickdetector, vA))
end
local function fn756(U)
    local un = typeof(cloneref) == "function" and typeof(U) == "Instance"
    if un then
        return cloneref(U)
    end
    return U
end
local function fn758(gT)
    State.AutoUpgrades = gT == true
end
local function fn780()
    local zY, zZ
    local zV_1
    local zU_1
    zV_1, zU_1 = tI()
    if not zV_1 then
        return false, "Mine data is not available yet"
    end
    local zW = tk("MineStock")
    local zX = 0
    local z1 = false
    for i, v in ipairs(tG(zV_1, zU_1)) do
        local z0 = 9
        while true do
            if z0 < 17 then
                if z0 < 8 then
                    if z0 < 4 then
                        if z0 < 2 then
                            if z0 < 1 then
                                z0 = 24
                            else
                                zV_1 = (s1())
                                z0 = if zV_1 then 25 else 30
                            end
                        elseif z0 < 3 then
                            z0 = 24
                        else
                            z0 = 32
                        end
                    elseif z0 < 6 then
                        if z0 < 5 then
                            zZ = v.Cost > sU(zY)
                            z0 = 29
                        else
                            zV_1, zZ = pcall(zW.GetRemaining, zY, v.Name)
                            zY = zV_1
                            z0 = if zY then 7 else 21
                        end
                    elseif z0 < 7 then
                        zX += 1
                        State.Purchases = State.Purchases + 1
                        task.wait(tt)
                        z0 = 14
                    else
                        zY = tonumber(zZ)
                        z0 = 21
                    end
                elseif z0 < 12 then
                    if z0 < 10 then
                        if z0 < 9 then
                            z0 = if zV_1 then 5 else 33
                        else
                            zU_1 = 0
                            z0 = 18
                        end
                    elseif z0 < 11 then
                        z0 = if zU_1 then 34 else 3
                    else
                        zV_1 = zW
                        z0 = if zV_1 then 12 else 8
                    end
                elseif z0 < 14 then
                    if z0 < 13 then
                        zV_1 = s9(zW.GetRemaining)
                        z0 = 8
                    else
                        zU_1 = zX >= to
                        z0 = 10
                    end
                elseif z0 < 15 then
                    z0 = 18
                elseif z0 < 16 then
                    z1 = true
                    z0 = 32
                else
                    zV_1 = zU_1 < to
                    z0 = 19
                end
            elseif z0 < 26 then
                if z0 < 21 then
                    if z0 < 19 then
                        if z0 < 18 then
                            z0 = 24
                        else
                            z0 = 1
                        end
                    elseif z0 < 20 then
                        z0 = if zV_1 then 31 else 22
                    else
                        zV_1 = zY <= 0
                        z0 = 28
                    end
                elseif z0 < 23 then
                    if z0 < 22 then
                        zV_1 = zY
                        z0 = if zV_1 then 27 else 26
                    else
                        z0 = 24
                    end
                elseif z0 < 24 then
                    z0 = 33
                elseif z0 < 25 then
                    zU_1 = not s1()
                    z0 = if zU_1 then 10 else 13
                else
                    zV_1 = zX < to
                    z0 = 30
                end
            elseif z0 < 30 then
                if z0 < 28 then
                    if z0 < 27 then
                        zV_1 = nil
                        z0 = 27
                    else
                        zY = zV_1
                        zV_1 = zY ~= nil
                        z0 = if zV_1 then 20 else 28
                    end
                elseif z0 < 29 then
                    z0 = if zV_1 then 17 else 23
                else
                    z0 = if zZ then 0 else 11
                end
            elseif z0 < 32 then
                if z0 < 31 then
                    z0 = if zV_1 then 16 else 19
                else
                    zU_1 += 1
                    zV_1, zY = tI()
                    zZ = not zV_1
                    z0 = if zZ then 29 else 4
                end
            elseif z0 < 33 then
                break
            elseif z0 < 34 then
                z0 = if not tm("MineBuyPickaxe", v.Index) then 2 else 6
            else
                z0 = 15
            end
        end
        if z1 then
            break
        end
    end
    if zX == 0 then
        return false, "No affordable pickaxe was in stock"
    end
    local zV_2 = zX == 1 and "" or "s"
    return true, ("Bought %d pickaxe%s"):format(zX, zV_2)
end
local function fn787(hb)
    State.SellKinds = s2(hb)
end
local function fn803(X)
    return type(X) == "function"
end
local function fn811()
    return not tu.Unloaded
end
local function fn822(he)
    State.SellRarities = s2(he)
end
local function fn834(bM)
    local vF_1
    local vD = tk("MineInventory")
    local vE = not vD or not s9(vD.ChestEntries)
    local vE_1
    if vE then
        return {}
    end
    vE_1, vF_1 = pcall(vD.ChestEntries, bM)
    local vD_1 = vE_1 and type(vF_1) == "table"
    if vD_1 then
        return vF_1
    end
    return {}
end
local function fn842(b0)
    local vW_1
    local vT = tk("MineInventory")
    local vU = not vT or not s9(vT.Collect)
    if vU then
        return {}
    end
    local vV = vT.KindOrder and vT.KindOrder.OreFirst or nil
    local vV_1
    vV_1, vW_1 = pcall(vT.Collect, b0, "All", vV)
    local vT_1 = vV_1 and type(vW_1) == "table"
    if vT_1 then
        return vW_1
    end
    return {}
end
local function fn855()
    local xB = if not tm("MineEquipBest") then 1 else 0
    if xB == 1 then
        return false, "Failed to send the equip request"
    end
    return true, "Requested the best available loadout"
end
local function fn864()
    gethui = tK
end
local function fn878(hj)
    local Ar = tonumber(hj) or 0
    State.SellAtCount = math.max(0, math.floor(Ar))
end
local function fn905(gR)
    local Ae = tonumber(gR) or 1
    State.ChestThreshold = math.max(1, math.floor(Ae))
end
local function fn982(eO)
    local ys_1
    local yp = tk("MineConfig")
    local yq = not yp
    local yy = if yq then 1 else 0
    local yw = 135 * yy + 227 * (1 - yy)
    local yx = 939 * yy + 4011 * (1 - yy)
    if not ((yw * 1183 + yx * 2074 + yw * yx) % 16777213 == 2233956) then
        yq = type(yp.ZoneKeys) ~= "table"
    end
    if not yq then
        yq = not s9(yp.IsZoneResearchComplete)
    end
    if yq then
        return nil
    end
    local yr = eO.UnlockedZones or {}
    local yr_1
    for i, v in ipairs(yp.ZoneKeys) do
        if yr[v] then
            yr_1, ys_1 = pcall(yp.IsZoneResearchComplete, eO.Skills, v)
            if yr_1 and not ys_1 then
                return v
            end
        end
    end
    return nil
end
local function fn994()
    local uH_1
    local uF = tk("GameState")
    local uG = not uF or not s9(uF.GetData2)
    local uG_1
    if uG then
        return nil
    end
    uG_1, uH_1 = pcall(uF.GetData2)
    local uF_1 = uG_1 and type(uH_1) == "table"
    if uF_1 then
        return uH_1
    end
    return nil
end
local function fn1000(aZ)
    local uQ = aZ and aZ.Money
    local uR = tonumber(uQ) or 0
    return uR
end
local function fn1018(g2)
    State.ZoneResearch = g2 == true
end
local function fn1042()
    local wl_1
    local wk_1
    local wh = tk("MineConfig")
    local wi = not wh or type(wh.Pickaxes) ~= "table"
    if wi then
        return {}
    end
    local wi_1 = {}
    for i, v in ipairs(wh.Pickaxes) do
        local wj = false
        if s9(wh.IsPickaxeFree) then
            wk_1, wl_1 = pcall(wh.IsPickaxeFree, v)
            wj = wk_1 and wl_1 == true
        end
        local wk_2 = type(v.Stock) == "table" and not v.RobuxOnly and not wj and type(v.Name) == "string"
        if wk_2 then
            table.insert(wi_1, v.Name)
        end
    end
    return wi_1
end
local function fn1049()
    local y6_1
    local y5_1
    local y2_1
    local y__1
    local y1_1, y1_3
    local yZ_1
    yZ_1, y__1 = tI()
    if not yZ_1 then
        return "Next zone: waiting for data"
    end
    local y0 = tk("MineConfig")
    y1_1, y2_1 = s_(yZ_1)
    if not y1_1 then
        return "Next zone: every zone is unlocked"
    end
    local y4 = y2_1 and y2_1.DisplayName or y1_1
    local y4_1, y4_2
    y4_1, y5_1 = ta(yZ_1, y1_1)
    local y1_2 = not y4_1
    if y1_2 ~= false then
        y1_2 = y5_1
    end
    if y1_2 then
        y1_2 = y0
    end
    if y1_2 then
        y1_2 = s9(y0.GetZoneResearchProgress)
    end
    if y1_2 then
        y1_3, y4_2, y6_1 = pcall(y0.GetZoneResearchProgress, yZ_1.Skills, y5_1)
        local yZ_2 = y1_3 and type(y4_2) == "number" and type(y6_1) == "number"
        if yZ_2 then
            return string.format("Next zone: %s needs %s research %d/%d", y4, y5_1, y4_2, y6_1)
        end
        local yZ_3 = y2_1 and y2_1.UnlockCost
        local y0_1 = tonumber(yZ_3) or 0
        return string.format("Next zone: %s costs %s, you have %s", y4, tostring(y0_1), tostring(sU(y__1)))
    end
    local yZ_5 = y2_1 and y2_1.UnlockCost
    local y0_2 = tonumber(yZ_5) or 0
    return string.format("Next zone: %s costs %s, you have %s", y4, tostring(y0_2), tostring(sU(y__1)))
end
local function fn1065()
    local zh_1
    local zd_1
    local zc_1
    local zg_1
    local zf_2
    local ze_3
    local zb = tI()
    if not zb then
        return false, "Mine data is not available yet"
    end
    zd_1, zc_1 = s_(zb)
    if not zd_1 then
        return false, "Every zone is already unlocked"
    end
    local zb_1 = 0
    if State.ZoneResearch then
        local zo = 1
        local zm = tf
        while zo <= zm do
            if not s1() then
                break
            end
            local ze_1 = tI()
            if not ze_1 then
                break
            end
            local zf_1 = sT(ze_1)
            if not zf_1 then
                break
            end
            local ze_2 = tL(0, zf_1)
            if ze_2 == 0 then
                break
            end
            zb_1 += ze_2
            zo += 1
        end
    end
    ze_3, zf_2 = tI()
    if not ze_3 then
        return false, "Mine data is not available yet"
    end
    zg_1, zh_1 = ta(ze_3, zd_1)
    if not zg_1 then
        if zb_1 > 0 then
            local zg_2 = zb_1 == 1 and "" or "s"
            local ze_5 = zh_1 or zd_1
            return true, ("Bought %d research node%s toward %s"):format(zb_1, zg_2, ze_5)
        end
        local ze_6 = zh_1 or zd_1
        return false, ("%s research is not finished yet"):format(ze_6)
    end
    local ze_7 = zc_1 and zc_1.UnlockCost
    local zg_3 = tonumber(ze_7) or 0
    if zg_3 > sU(zf_2) then
        if zb_1 > 0 then
            local zf_3 = zb_1 == 1 and "" or "s"
            return true, ("Bought %d research node%s, still saving for %s"):format(zb_1, zf_3, zd_1)
        end
        local ze_10 = zc_1 and zc_1.DisplayName or zd_1
        return false, ("Not enough money to unlock %s"):format(ze_10)
    end
    local zl = if not tm("MineSelectZone", zd_1) then 1 else 0
    if zl == 1 then
        return false, "Failed to send the zone request"
    end
    State.Purchases = State.Purchases + 1
    task.wait(tt)
    local zb_3 = tI()
    local ze_11 = zb_3
    if ze_11 then
        local zf_4 = {}
        local zg_4 = zb_3.UnlockedZones
        local zl_1 = if zg_4 then 1 else 0
        local zj = 1331 * zl_1 + 3687 * (1 - zl_1)
        local zk = 1215 * zl_1 + 1475 * (1 - zl_1)
        if not ((zj * 1646 + zk * 360 + zj * zk) % 16777213 == 4245391) then
            zg_4 = zf_4
        end
        ze_11 = zg_4[zd_1]
    end
    if ze_11 then
        local ze_12 = zc_1 and zc_1.DisplayName or zd_1
        return true, ("Unlocked %s"):format(ze_12)
    end
    local zc_2 = zc_1 and zc_1.DisplayName or zd_1
    return false, ("The server did not unlock %s"):format(zc_2)
end
local function fn1128()
    local uJ = tq()
    local uK = uJ and uJ.MineGame
    if type(uK) ~= "table" then
        return nil, uJ
    end
    return uK, uJ
end
local function fn1143()
    local max = math.max
    local zv = tonumber(State.UpgradeReserve) or 0
    local zw = max(0, zv)
    local zu_1 = 0
    if State.BuyCoreUpgrades then
        zu_1 += tw(zw)
    end
    if State.BuyZoneSkills then
        zu_1 += tL(zw)
    end
    if zu_1 == 0 then
        return false, "No affordable upgrade was available"
    end
    local zw_1 = zu_1 == 1 and "" or "s"
    return true, ("Bought %d upgrade%s"):format(zu_1, zw_1)
end
local function fn1153()
    local MineWorld = tJ:FindFirstChild("MineWorld")
    local uU = MineWorld and MineWorld:FindFirstChild("Plots")
    if not uU then
        return nil
    end
    for i, child in ipairs(uU:GetChildren()) do
        if child:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return child
        end
    end
    return nil
end
local function fn1159()
    return s8
end
local function fn1161(au)
    local uA_1
    local uy = tr[au]
    if uy ~= nil then
        return uy
    end
    local Modules = sS:FindFirstChild("Modules")
    local uz = Modules and Modules:FindFirstChild(au)
    local uz_2
    local uz_1 = not uz
    local uE = if uz_1 then 1 else 0
    local uC = 2363 * uE + 1058 * (1 - uE)
    local uD = 2783 * uE + 836 * (1 - uE)
    if not ((uC * 2394 + uD * 18 + uC * uD) % 16777213 == 12283345) then
        uz_1 = not uz:IsA("ModuleScript")
    end
    if uz_1 then
        return nil
    end
    uz_2, uA_1 = pcall(require, uz)
    local uy_3 = not uz_2 or type(uA_1) ~= "table"
    if uy_3 then
        return nil
    end
    tr[au] = uA_1
    return uA_1
end
local function fn1162()
    local v9 = {}
    for i, v in ipairs(td) do
        table.insert(v9, v)
    end
    return v9
end
sS = nil
sT = nil
sU = nil
sV = nil
LocalPlayer = nil
sY = nil
sZ = nil
s_ = nil
s0 = nil
s1 = nil
s2 = nil
s4 = nil
State = nil
s8 = nil
s9 = nil
ta = nil
tc = nil
td = nil
CoreGui = nil
tf = nil
tg = nil
th = nil
tj = nil
tk = nil
tm = nil
tn = nil
to = nil
tp = nil
tq = nil
tr = nil
tt = nil
tu = nil
tv = nil
tw = nil
tz = nil
tB = nil
tC = nil
local Players, sW, Workspace, s5, Lighting, TeleportService, ti, GuiService, HttpService, VirtualUser, ty, UserInputService, RunService
tE = nil
tF = nil
tG = nil
tH = nil
tI = nil
tJ = nil
tK = nil
tL = nil
if not game:IsLoaded() then
    game.Loaded:Wait()
end
Players, RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, TeleportService, Lighting, Workspace, LocalPlayer, tK = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
TeleportService = game:GetService("TeleportService")
Lighting = game:GetService("Lighting")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local tN = "TempoMyAnimeMine"
tK = fn267
if getgenv then
    getgenv().gethui = tK
end
tu, sS, tJ, tE, tB, ty, tt, to, tf, td, s8, State, tr, s4, tj, tF, tn, s5, s9, s1, sZ, tk, tq, tI, tm, sU, tC, s0, tg, sY, tv, th, sV, tc, tH, s2, tz, tp, ti, sW, tw, tL, sT, s_, ta, tG = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pcall(fn864)
local function tR(t)
    local ub
    local ud
    local uc
    ub = nil
    uc = nil
    ud = nil
    local ue = t ~= ""
    local uf = type(t) == "string" and ue
    assert(uf, "A namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    ub = getgenv()
    assert(type(ub) == "table", "getgenv did not return a table")
    local ue_1 = ub[t]
    if ue_1 ~= nil then
        local uf_1 = type(ue_1) == "table" and type(ue_1.Unload) == "function"
        assert(uf_1, "Namespace is occupied")
        ue_1.Unload()
        assert(ub[t] == nil, "Previous instance did not release its namespace")
    end
    uc = {}
    ud = { State = {}, Unloaded = false }
    ud.Track = function(z)
        assert(type(z) == "function", "Cleanup must be callable")
        if ud.Unloaded then
            z()
        else
            table.insert(uc, z)
        end
        return z
    end
    ud.Unload = function()
        local t4_1
        local t3_1
        if ud.Unloaded then
            return
        end
        ud.Unloaded = true
        local t1 = {}
        local t8 = #uc
        local t7 = -1
        while false and t8 <= 1 or true and t8 >= 1 do
            local t9 = t8
            local t2_1 = table.remove(uc, t9)
            t3_1, t4_1 = pcall(t2_1)
            if not t3_1 then
                table.insert(t1, tostring(t4_1))
            end
            t8 += t7
        end
        table.clear(ud.State)
        if #t1 > 0 then
            error("Cleanup incomplete: " .. table.concat(t1, "; "), 0)
        end
        if ub[t] == ud then
            ub[t] = nil
        end
    end
    ub[t] = ud
    return ud
end
s5 = function(M, N)
    local ui = type(M) == "table" and type(M.Track) == "function"
    assert(ui, "FeatureAPI required")
    local ui_1 = type(N) == "table" and type(N.OnUnload) == "function"
    assert(ui_1, "UI library required")
    assert(type(N.Unload) == "function", "UI unload required")
    M.Track(function()
        if not N.Unloaded then
            N:Unload()
        end
    end)
    N:OnUnload(function()
        M.Unload()
    end)
end
tu = tR(tN)
s9 = fn803
s1 = fn811
sS = fn756(ReplicatedStorage)
tJ = fn756(Workspace)
if (tt or false or not tC and tk) and (tC and not tk and (tf or tk)) and (s9 or false or s9 and not s0 or (not s9 or tC) and (not s9 and tC)) and not ((tt or false or not tC and tk) and (tC and not tk and (tf or tk)) and (s9 or false or s9 and not s0 or (not s9 or tC) and (not s9 and tC))) then
    ty = 24
    tt = 0.35
    tB = 1.1
    tE = 0.35
else
    tE = 24
    tB = 0.35
    ty = 1.1
    tt = 0.35
end
to = 40
tf = 12
td = { "Ore", "Character", "Pickaxe", "Potion", "Enchant", "EnchantDice", "MysteryBlock" }
s8 = { "Focused First", "Lowest Health", "Highest Health", "Nearest" }
State = tu.State
State.AutoMine = false
State.TargetMode = "Focused First"
State.ClickDelay = 0.12
State.AutoEquipBest = false
State.AutoChest = false
State.ChestThreshold = 1
State.AutoUpgrades = false
State.BuyCoreUpgrades = true
State.BuyZoneSkills = true
State.UpgradeReserve = 0
State.AutoZones = false
State.ZoneResearch = true
State.AutoPickaxes = false
State.PickaxeNames = {}
State.AutoSell = false
State.SellKinds = { Ore = true }
State.SellRarities = {}
State.SellKeepAbove = 0
State.SellAtCount = 0
State.SellTeleport = true
State.SellReturn = true
State.Status = "Idle"
State.Broken = 0
State.Sold = 0
State.Purchases = 0
sZ = fn674
tu.GetStatus = fn717
tu.Support = fn670
tr = {}
tk = fn1161
tq = fn994
tI = fn1128
tm = fn326
sU = fn1000
tC = fn1153
s0 = fn577
tg = fn164
if (not tt and s1 and (s1 and not s8) or not ti and not ti and (s1 or not s8) or (not tt and s8 and (not s4 and s4) or (tt or s8 or not s8 and not s4))) and not (not tt and s1 and (s1 and not s8) or not ti and not ti and (s1 or not s8) or (not tt and s8 and (not s4 and s4) or (tt or s8 or not s8 and not s4))) then
    tv = fn314
    sY = fn526
else
    sY = fn314
    tv = fn526
end
th = fn748
sV = fn834
tc = fn641
tH = fn842
tu.RarityValues = fn629
tu.KindValues = fn1162
tu.TargetModes = fn1159
tu.PickaxeValues = fn1042
s2 = fn73
tz = fn485
tp = fn537
ti = fn285
sW = fn134
if not tj and not sT and (not tk and tG) or (tj or not tE or tE and not tE) or not (not tj and not sT and (not tk and tG) or (tj or not tE or tE and not tE)) then
    s4 = false
    tu.SellNow = function()
        if s4 then
            return false, "A sell run is already in progress"
        end
        local xj = tI()
        if not xj then
            return false, "Mine data is not available yet"
        end
        local xk = tp(xj)
        if #xk == 0 then
            return false, "Nothing in the inventory matches the sell filters"
        end
        s4 = true
        sZ("Selling " .. #xk .. " stacks")
        local CFrame2
        local xf = ti()
        if State.SellTeleport and xf then
            local xg = tg()
            if xg then
                CFrame2 = xg.CFrame
                pcall(function()
                    xg.CFrame = CFrame.new(xf + Vector3.new(0, 5, 6))
                end)
                task.wait(ty)
            end
        end
        local xj_7 = {}
        for i, v in ipairs(xk) do
            table.insert(xj_7, v.Key)
        end
        local xk_3 = s1() and sW(xj_7)
        local xk_4 = xk_3 or 0
        State.Sold = State.Sold + xk_4
        if CFrame2 and State.SellReturn then
            task.wait(0.2)
            local xi = tg()
            if xi then
                pcall(function()
                    xi.CFrame = CFrame2
                end)
            end
        end
        s4 = false
        sZ("Idle")
        if xk_4 == 0 then
            return false, "The server did not accept the sell request"
        end
        local xl = xk_4 == 1 and "" or "s"
        return true, ("Sold %d stack%s"):format(xk_4, xl)
    end
    tu.TakeChestNow = fn377
    tu.EquipBestNow = fn855
    tw = fn28
else
    tw = false
    s4.SellNow = function()
        if s4 then
            return false, "A sell run is already in progress"
        end
        local xj = tI()
        if not xj then
            return false, "Mine data is not available yet"
        end
        local xk = tp(xj)
        if #xk == 0 then
            return false, "Nothing in the inventory matches the sell filters"
        end
        s4 = true
        sZ("Selling " .. #xk .. " stacks")
        local CFrame2
        local xf = ti()
        if State.SellTeleport and xf then
            local xg = tg()
            if xg then
                CFrame2 = xg.CFrame
                pcall(function()
                    xg.CFrame = CFrame.new(xf + Vector3.new(0, 5, 6))
                end)
                task.wait(ty)
            end
        end
        local xj_2 = {}
        for i, v in ipairs(xk) do
            table.insert(xj_2, v.Key)
        end
        local xk_1 = s1() and sW(xj_2)
        local xk_2 = xk_1 or 0
        State.Sold = State.Sold + xk_2
        if CFrame2 and State.SellReturn then
            task.wait(0.2)
            local xi = tg()
            if xi then
                pcall(function()
                    xi.CFrame = CFrame2
                end)
            end
        end
        s4 = false
        sZ("Idle")
        if xk_2 == 0 then
            return false, "The server did not accept the sell request"
        end
        local xl = xk_2 == 1 and "" or "s"
        return true, ("Sold %d stack%s"):format(xk_2, xl)
    end
    s4.TakeChestNow = fn377
    s4.EquipBestNow = fn855
    tu = fn28
end
tL = fn680
sT = fn982
s_ = fn445
ta = fn581
tu.ZoneProgress = fn1049
tu.BuyZonesNow = fn1065
tu.BuyUpgradesNow = fn1143
tG = fn32
tu.BuyPickaxesNow = fn780
tu.SetAutoMine = fn381
tu.SetTargetMode = fn251
tu.SetClickDelay = fn52
tu.SetAutoEquipBest = fn236
tu.SetAutoChest = fn551
tu.SetChestThreshold = fn905
tu.SetAutoUpgrades = fn758
tu.SetBuyCoreUpgrades = fn132
tu.SetBuyZoneSkills = fn563
tu.SetUpgradeReserve = fn231
tu.SetAutoZones = fn312
tu.SetZoneResearch = fn1018
tu.SetAutoPickaxes = fn514
tu.SetPickaxeNames = fn248
tu.SetAutoSell = fn518
tu.SetSellKinds = fn787
tu.SetSellRarities = fn822
tu.SetSellKeepAbove = fn260
tu.SetSellAtCount = fn878
tu.SetSellTeleport = fn568
tu.SetSellReturn = fn554
tj = task.spawn(worker)
tF = task.spawn(worker2)
tn = task.spawn(worker3)
tu.Track(fn180)
local function tM()
    local onDiscord
    local Fl
    local Fk
    Fk = nil
    Fl = nil
    onDiscord = nil
    local Fg, ThemeManager, Fi, Options, SaveManager, Fn, Fo, Library, Toggles
    Fk = "https://discord.gg/K7Qxnxkk46"
    Fn = "My Anime Mine"
    Fg = "https://tempohub.shop"
    Fo = "https://discord.gg/K7Qxnxkk46"
    Library = getgenv().Library
    ThemeManager = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = Library.Toggles
    Options = Library.Options
    s5(tu, Library)
    Fl = function(ik, il)
        local AW = s9(setclipboard) and setclipboard
        local AX = AW
        if not AX then
            local AW_1 = s9(toclipboard) and toclipboard
            AX = AW_1 or nil
        end
        local AW_2 = AX
        if not AW_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local AX_1 = pcall(AW_2, ik)
        if AX_1 then
            Library:Notify(il)
        else
            Library:Notify("Failed to copy")
        end
    end
    onDiscord = function()
        Fl(Fk, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = Fk, Copyable = true }, "|", Fn, "|", "v0.2" },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(false)
    Fi = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gamepad-2"),
        Shop = Window:AddTab("Shop", "shopping-cart"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
    local function Fs(iB)
        local DiscordGroup = iB:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    for k, v in Fi do
        if k ~= "Info" then
            Fs(v)
        end
    end
    local function Ft_1()
        local jx
        local MineGroup = Fi.Main:AddRightGroupbox("Mine", "pickaxe")
        local Label = MineGroup:AddLabel(tu.GetStatus(), true)
        MineGroup:AddDivider()
        MineGroup:AddToggle("AutoMine", {
            Text = "Auto Farm Mines",
            Default = false,
            Tooltip = "Clicks the nodes on your own plot to damage and break them.",
            Callback = function(iL)
                tu.SetAutoMine(iL)
            end
        })
        MineGroup:AddDropdown("TargetMode", {
            Text = "Node Priority",
            Values = tu.TargetModes(),
            Default = "Focused First",
            Multi = false,
            AllowNull = false,
            Tooltip = "Focused First hits the node the game highlights, then falls back to the lowest health node.",
            Callback = function(iN)
                tu.SetTargetMode(iN)
            end
        })
        MineGroup:AddSlider("ClickDelay", {
            Text = "Swing Delay",
            Default = 0.12,
            Min = 0.05,
            Max = 1,
            Rounding = 2,
            Tooltip = "Seconds between clicks. Lower is faster; raise it if the server starts dropping swings.",
            Callback = function(iP)
                tu.SetClickDelay(iP)
            end
        })
        local LoadoutGroup = Fi.Main:AddLeftGroupbox("Loadout", "hand")
        LoadoutGroup:AddToggle("AutoEquipBest", {
            Text = "Auto Equip Best",
            Default = false,
            Tooltip = "Keeps your strongest miners and pickaxe equipped.",
            Callback = function(iS)
                tu.SetAutoEquipBest(iS)
            end
        })
        LoadoutGroup:AddButton({
            Text = "Equip Best Now",
            Func = function()
                local iV, iW = tu.EquipBestNow()
                Library:Notify(iW)
            end
        })
        local ChestGroup = Fi.Main:AddLeftGroupbox("Chest", "package")
        ChestGroup:AddToggle("AutoChest", {
            Text = "Auto Collect Chest",
            Default = false,
            Tooltip = "Takes everything out of your plot chest so it never fills up.",
            Callback = function(i_)
                tu.SetAutoChest(i_)
            end
        })
        ChestGroup:AddSlider("ChestThreshold", {
            Text = "Collect At Items",
            Default = 1,
            Min = 1,
            Max = 500,
            Rounding = 0,
            Tooltip = "Wait until the chest holds this many items before taking everything.",
            Callback = function(i1)
                tu.SetChestThreshold(i1)
            end
        })
        ChestGroup:AddButton({
            Text = "Take All Now",
            Func = function()
                local i4, i5 = tu.TakeChestNow()
                Library:Notify(i5)
            end
        })
        local SellGroup = Fi.Main:AddRightGroupbox("Sell", "banknote")
        SellGroup:AddToggle("AutoSell", {
            Text = "Auto Sell",
            Default = false,
            Tooltip = "Sells matching inventory stacks at the sell stand.",
            Callback = function(i8)
                tu.SetAutoSell(i8)
            end
        })
        SellGroup:AddDropdown("SellKinds", {
            Text = "Item Type Filter",
            Values = tu.KindValues(),
            Default = { "Ore" },
            Multi = true,
            AllowNull = true,
            Expandable = true,
            Tooltip = "Only sell these item types. Leave empty to sell every sellable type.",
            Callback = function(ja)
                tu.SetSellKinds(ja)
            end
        })
        SellGroup:AddDropdown("SellRarities", {
            Text = "Rarity Filter",
            Values = tu.RarityValues(),
            Default = {},
            Multi = true,
            AllowNull = true,
            Expandable = true,
            Tooltip = "Only sell these rarities. Leave empty to ignore rarity.",
            Callback = function(jc)
                tu.SetSellRarities(jc)
            end
        })
        SellGroup:AddSlider("SellKeepAbove", {
            Text = "Keep Above Value",
            Default = 0,
            Min = 0,
            Max = 10000000,
            Rounding = 0,
            Tooltip = "Stacks worth more than this are kept. Set to 0 to ignore value.",
            Callback = function(je)
                tu.SetSellKeepAbove(je)
            end
        })
        SellGroup:AddSlider("SellAtCount", {
            Text = "Sell At Item Count",
            Default = 0,
            Min = 0,
            Max = 2000,
            Rounding = 0,
            Tooltip = "Wait until the matching stacks hold this many items before selling.",
            Callback = function(jg)
                tu.SetSellAtCount(jg)
            end
        })
        SellGroup:AddDivider()
        SellGroup:AddToggle("SellTeleport", {
            Text = "Teleport To Sell Stand",
            Default = true,
            Tooltip = "The server only accepts sales next to the stand, so keep this on unless you stand there yourself.",
            Callback = function(ji)
                tu.SetSellTeleport(ji)
            end
        })
        SellGroup:AddToggle("SellReturn", {
            Text = "Return After Selling",
            Default = true,
            Callback = function(jk)
                tu.SetSellReturn(jk)
            end
        })
        SellGroup:AddButton({
            Text = "Sell Now",
            Func = function()
                task.spawn(function()
                    local jo, jp = tu.SellNow()
                    Library:Notify(jp)
                end)
            end
        })
        jx = task.spawn(function()
            while not Library.Unloaded do
                pcall(function()
                    Label:SetText(tu.GetStatus())
                end)
                task.wait(0.25)
            end
        end)
        tu.Track(function()
            if coroutine.status(jx) ~= "dead" then
                pcall(task.cancel, jx)
            end
        end)
    end
    Ft_1()
    local function Fs_1()
        local j8
        local UpgradesGroup = Fi.Shop:AddRightGroupbox("Upgrades", "trending-up")
        UpgradesGroup:AddToggle("AutoUpgrades", {
            Text = "Auto Buy Affordable Upgrades",
            Default = false,
            Tooltip = "Buys every unlocked upgrade you can currently pay for.",
            Callback = function(jC)
                tu.SetAutoUpgrades(jC)
            end
        })
        UpgradesGroup:AddToggle("BuyCoreUpgrades", {
            Text = "Buy Core Upgrades",
            Default = true,
            Tooltip = "Tap damage and miner slot nodes from the core tree.",
            Callback = function(jF)
                tu.SetBuyCoreUpgrades(jF)
            end
        })
        UpgradesGroup:AddToggle("BuyZoneSkills", {
            Text = "Buy Zone Skills",
            Default = true,
            Tooltip = "Skill tree nodes for every zone you have unlocked.",
            Callback = function(jH)
                tu.SetBuyZoneSkills(jH)
            end
        })
        UpgradesGroup:AddSlider("UpgradeReserve", {
            Text = "Keep Money",
            Default = 0,
            Min = 0,
            Max = 100000000,
            Rounding = 0,
            Tooltip = "Never spend below this balance on upgrades.",
            Callback = function(jJ)
                tu.SetUpgradeReserve(jJ)
            end
        })
        UpgradesGroup:AddButton({
            Text = "Buy Upgrades Now",
            Func = function()
                task.spawn(function()
                    local jN, jO = tu.BuyUpgradesNow()
                    Library:Notify(jO)
                end)
            end
        })
        local ZonesGroup = Fi.Shop:AddRightGroupbox("Zones", "map")
        local Label = ZonesGroup:AddLabel(tu.ZoneProgress(), true)
        ZonesGroup:AddDivider()
        ZonesGroup:AddToggle("AutoZones", {
            Text = "Auto Buy Zones",
            Default = false,
            Tooltip = "Unlocks the next zone as soon as its research gate is met and you can pay the unlock cost. Ignores the Keep Money limit.",
            Callback = function(jU)
                tu.SetAutoZones(jU)
            end
        })
        ZonesGroup:AddToggle("ZoneResearch", {
            Text = "Buy Gate Research",
            Default = true,
            Tooltip = "The next zone stays locked until the previous zone's research tree is finished, so this buys that tree out first.",
            Callback = function(jW)
                tu.SetZoneResearch(jW)
            end
        })
        ZonesGroup:AddButton({
            Text = "Unlock Next Zone Now",
            Func = function()
                task.spawn(function()
                    local j_, j0 = tu.BuyZonesNow()
                    Library:Notify(j0)
                end)
            end
        })
        j8 = task.spawn(function()
            while not Library.Unloaded do
                pcall(function()
                    Label:SetText(tu.ZoneProgress())
                end)
                task.wait(1)
            end
        end)
        tu.Track(function()
            if coroutine.status(j8) ~= "dead" then
                pcall(task.cancel, j8)
            end
        end)
        local PickaxesGroup = Fi.Shop:AddLeftGroupbox("Pickaxes", "hammer")
        PickaxesGroup:AddToggle("AutoPickaxes", {
            Text = "Auto Buy Pickaxes",
            Default = false,
            Tooltip = "Buys in stock pickaxes for zones you have unlocked and do not already own.",
            Callback = function(kb)
                tu.SetAutoPickaxes(kb)
            end
        })
        PickaxesGroup:AddDropdown("PickaxeNames", {
            Text = "Pickaxe Filter",
            Values = tu.PickaxeValues(),
            Default = {},
            Multi = true,
            AllowNull = true,
            Searchable = true,
            Expandable = true,
            Tooltip = "Only buy these pickaxes. Leave empty to buy every affordable one.",
            Callback = function(kd)
                tu.SetPickaxeNames(kd)
            end
        })
        PickaxesGroup:AddButton({
            Text = "Buy Pickaxes Now",
            Func = function()
                task.spawn(function()
                    local kh, ki = tu.BuyPickaxesNow()
                    Library:Notify(ki)
                end)
            end
        })
    end
    Fs_1()
    local function Fs_2()
        local Br
        local Bw
        local Bs
        local Bo
        Bo = nil
        Br = nil
        Bs = nil
        Bw = nil
        local Bl, Bm, Label, Bp, Bq, Bt, Bu, Label2, Label3
        Bs = function(kn)
            return (tostring(kn):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
        end
        Br = function(kp, kq)
            return string.format('<font color="%s">%s</font>', kq, Bs(kp))
        end
        Bu = function(kt, kv, kw)
            return string.format("<b>%s</b> %s %s", kt, Br("-", "#5a6070"), Br(kv, kw))
        end
        Bm = "#e8a34d"
        local By = "#6ec1ff"
        Bt = "#7fd47f"
        local Bz = "#8b93a3"
        local BA = tu.Support()
        local BB = #BA == 0 and "ready"
        local BC = BB or "limited: " .. table.concat(BA, ", ")
        Bq = "Unknown"
        pcall(function()
            local A7_1
            local A6_1
            local Bd = if s9(identifyexecutor) then 1 else 0
            if Bd == 1 then
                A7_1, A6_1 = identifyexecutor()
                local A8 = A7_1 ~= ""
                local A9 = type(A7_1) == "string" and A8
                if A9 then
                    local A8_1 = type(A6_1) == "string" and A6_1 ~= "" and A7_1 .. " " .. A6_1
                    Bq = A8_1 or A7_1
                end
            end
        end)
        Bw = os.clock()
        Bp = function()
            local Be = math.floor(os.clock() - Bw)
            if Be < 60 then
                return Be .. "s"
            elseif Be < 3600 then
                return string.format("%dm %ds", math.floor((Be) / (60)), Be % 60)
            else
                return string.format("%dh %dm", math.floor((Be) / (3600)), math.floor((Be % 3600) / (60)))
            end
        end
        local UserGroup = Fi.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(Bu("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, Bt), true)
        UserGroup:AddLabel(Bu("UserId", tostring(LocalPlayer.UserId), By), true)
        UserGroup:AddLabel(Bu("Executor", Bq .. "  " .. BC, Bt), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(Bu("Session", Bp(), Bm), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                Fl(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                Fl("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = Fi.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(Bu("Game", Fn, By), true)
        Label2 = SessionGroup:AddLabel(Bu("Players", "0/0", Bt), true)
        Bl = tostring(game.JobId)
        local By_1 = #Bl > 18 and string.sub(Bl, 1, 18) .. "..."
        local BB_2 = By_1 or Bl
        SessionGroup:AddLabel(Bu("Job", BB_2, Bz), true)
        Label = SessionGroup:AddLabel(Bu("Ping", "0 ms", Bm), true)
        SessionGroup:AddDivider()
        SessionGroup:AddButton({
            Text = "Rejoin Place",
            Func = function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        })
        SessionGroup:AddButton({
            Text = "Copy Job ID",
            Func = function()
                Fl(Bl, "Copied Job ID")
            end
        })
        Bo = task.spawn(function()
            local Bh_1
            local Bg_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(Bu("Session", Bp(), Bm))
                Label2:SetText(Bu("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), Bt))
                Bg_1, Bh_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local Bg_2 = Bg_1 and Bh_1 .. " ms" or "n/a"
                Label:SetText(Bu("Ping", Bg_2, Bm))
            end
        end)
        tu.Track(function()
            if coroutine.status(Bo) ~= "dead" then
                pcall(task.cancel, Bo)
            end
        end)
        local SocialsGroup = Fi.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                Fl(Fo, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                Fl(Fg, "Copied website link")
            end
        })
    end
    Fs_2()
    local function Fs_3()
        local lK
        local lI
        local lJ
        local lH
        local MovementGroup = Fi.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = Fi.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        lH = {}
        lJ = {}
        local lG = {}
        lI = {}
        lK = {}
        local function lL()
            for k, v in lH do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(lH)
        end
        local function lP()
            for k, v in lI do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(lI)
        end
        local function lT()
            for k, v in lJ do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(lJ)
        end
        local function lX(lY)
            local B1 = if not lY:IsA("ProximityPrompt") then 1 else 0
            if B1 == 1 then
                return
            end
            if lK[lY] == nil then
                lK[lY] = {
                    HoldDuration = lY.HoldDuration,
                    MaxActivationDistance = lY.MaxActivationDistance,
                    RequiresLineOfSight = lY.RequiresLineOfSight
                }
            end
            lY.HoldDuration = 0
            lY.MaxActivationDistance = 50
            lY.RequiresLineOfSight = false
        end
        local function l_()
            for k, v in lK do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(lK)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                lT()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                lP()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                lL()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                    pcall(lX, v)
                end
            else
                l_()
            end
        end)
        table.insert(lG, Workspace.DescendantAdded:Connect(function(mi)
            if Toggles.InstantProximityPrompt.Value then
                lX(mi)
            end
        end))
        table.insert(lG, RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if lH[v] == nil then
                        lH[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(lG, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local CD = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and CD then
                CD:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(lG, RunService.RenderStepped:Connect(function(mE)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local CG = Character and Character:FindFirstChildOfClass("Humanoid")
            local CH = Character
            if CH then
                CH = Character:FindFirstChild("HumanoidRootPart")
            end
            local CF_1 = CH
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and CG then
                if lI[CG] == nil then
                    lI[CG] = CG.WalkSpeed
                end
                CG.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and CF_1 and CG and CurrentCamera then
                if lJ[CG] == nil then
                    lJ[CG] = CG.PlatformStand
                end
                CG.PlatformStand = true
                local CH_4 = Vector3.zero
                if not UserInputService:GetFocusedTextBox() then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        CH_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        CH_4 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        CH_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        CH_4 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        CH_4 += Vector3.new(0, 1, 0)
                    end
                    local CN = if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then 1 else 0
                    if CN == 1 then
                        CH_4 -= Vector3.new(0, 1, 0)
                    end
                end
                CF_1.AssemblyLinearVelocity = Vector3.zero
                if CH_4.Magnitude > 0 then
                    CF_1.CFrame = CF_1.CFrame + CH_4.Unit * Options.FlySpeed.Value * mE
                end
            end
        end))
        tu.Track(function()
            for k, v in lG do
                v:Disconnect()
            end
            lL()
            lP()
            lT()
            l_()
        end)
    end
    Fs_3()
    local function Fs_4()
        local DX, DY, DZ, D_, D0, Label, D2, D3, D4, D5, D6, D7, D8, D9
        D2 = {}
        DX = {}
        D7 = nil
        D4 = 0
        DZ = false
        D8 = 0
        D_ = os.clock()
        local MenuGroup = Fi.Settings:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        D5 = function()
            local CurrentCamera
            CurrentCamera = Workspace.CurrentCamera
            local CW = not CurrentCamera or not s9(VirtualUser.CaptureController) or not s9(VirtualUser.ClickButton2)
            if CW then
                return false
            end
            local CW_1 = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            end)
            if not CW_1 then
                return false
            end
            D8 += 1
            D_ = os.clock()
            pcall(function()
                Label:SetText("AFK triggers: " .. D8)
            end)
            return true
        end
        D0 = function(nn)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not nn)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not nn
                end
            end)
            if not nn then
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
        DY = function(nD)
            local C7 = nD.ClassName == "ParticleEmitter" or nD.ClassName == "Trail" or nD.ClassName == "Smoke" or nD.ClassName == "Fire" or nD.ClassName == "Sparkles" or nD.ClassName == "Explosion"
            local Db = if C7 then 1 else 0
            local C9 = 463 * Db + 1584 * (1 - Db)
            local Da = 3191 * Db + 132 * (1 - Db)
            if not ((C9 * 1618 + Da * 930 + C9 * Da) % 16777213 == 5194197) then
                C7 = nD.ClassName == "Beam"
            end
            if C7 then
                if D2[nD] == nil then
                    D2[nD] = nD.Enabled
                end
                pcall(function()
                    nD.Enabled = false
                end)
            end
        end
        D9 = function()
            for k, v in D2 do
                local Dg = k
                local Di = v
                if Dg.Parent then
                    pcall(function()
                        Dg.Enabled = Di
                    end)
                end
            end
            table.clear(D2)
            if D7 then
                pcall(function()
                    settings().Rendering.QualityLevel = D7.Quality
                end)
                Lighting.GlobalShadows = D7.Shadows
                Lighting.FogEnd = D7.Fog
                D7 = nil
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(nS)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not nS)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(nX)
                if nX then
                    if not D7 then
                        D7 = {
                            Quality = settings().Rendering.QualityLevel,
                            Shadows = Lighting.GlobalShadows,
                            Fog = Lighting.FogEnd
                        }
                    end
                    pcall(function()
                        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                    end)
                    Lighting.GlobalShadows = false
                    Lighting.FogEnd = 9000000000
                    for k, v in Workspace:QueryDescendants("ParticleEmitter,Trail,Smoke,Fire,Sparkles,Beam") do
                        pcall(DY, v)
                    end
                else
                    D9()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        D0(true)
        local ScriptGroup = Fi.Settings:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiGameplayPause:OnChanged(function()
            D0(Toggles.AntiGameplayPause.Value)
        end)
        if Toggles.AntiGameplayPause.Value then
            D0(true)
        end
        table.insert(DX, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                D5()
            end
        end))
        table.insert(DX, Workspace.DescendantAdded:Connect(function(of)
            if Toggles.FpsBoost.Value then
                DY(of)
            end
        end))
        D6 = function(oj)
            if DZ or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            DZ = true
            local Dy = D4
            local Dz_1 = pcall(function()
                if oj then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not Dz_1 then
                DZ = false
                if not oj and Dy == D4 then
                    task.delay(1.5, function()
                        if Dy == D4 then
                            D6(true)
                        end
                    end)
                end
            end
        end
        table.insert(DX, TeleportService.TeleportInitFailed:Connect(function(oE)
            local DG
            if oE == LocalPlayer and DZ then
                DZ = false
                DG = D4
                task.delay(3, function()
                    if DG == D4 then
                        D6(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local DL = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            if Library.Unloaded or not DL then
                return
            end
            table.insert(DX, DL.ChildAdded:Connect(function(oT)
                if oT.Name == "ErrorPrompt" then
                    D6(false)
                end
            end))
        end)
        D3 = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    D0(true)
                end
                local DO = Toggles.AntiAfk.Value and os.clock() - D_ >= 60
                if DO then
                    D5()
                end
                task.wait(1)
            end
        end)
        tu.Track(function()
            D4 += 1
            for k, v in DX do
                v:Disconnect()
            end
            pcall(task.cancel, D3)
            D0(false)
            D9()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    Fs_4()
    local function Fs_5()
        local E4, E5, E6, E7
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("MyScriptHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(Fi.Settings)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/MyAnimeMine")
        local E8 = SaveManager:BuildConfigSection(Fi.Settings)
        E5 = function(pj, pk)
            local Ed = pj == "Toggle" and Toggles
            local Ei = if Ed then 1 else 0
            local Eg = 1498 * Ei + 236 * (1 - Ei)
            local Eh = 1377 * Ei + 2300 * (1 - Ei)
            if not ((Eg * 2079 + Eh * 2012 + Eg * Eh) % 16777213 == 7947612) then
                Ed = Options
            end
            local Ed_1 = Ed[pk]
            local Ec_2 = type(Ed_1) == "table" and Ed_1.Type == pj
            return Ec_2 and Ed_1 or nil
        end
        E7 = function(pt, pu)
            local Type = pu.Type
            if Type == "Toggle" then
                return { idx = pt, type = "Toggle", value = pu.Value == true }
            elseif Type == "Slider" then
                return { idx = pt, type = "Slider", value = tostring(pu.Value) }
            elseif Type == "Dropdown" then
                return { idx = pt, type = "Dropdown", multi = pu.Multi == true, value = pu.Value }
            elseif Type == "Input" then
                local Ek = pu.Value or ""
                return { idx = pt, type = "Input", text = tostring(Ek) }
            elseif Type == "ColorPicker" then
                return { idx = pt, type = "ColorPicker", value = pu.Value:ToHex(), transparency = pu.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = pt,
                    type = "KeyPicker",
                    mode = pu.Mode,
                    key = pu.Value,
                    modifiers = pu.Modifiers,
                    toggled = pu.Toggled
                }
            else
                return nil
            end
        end
        E6 = function()
            local En = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local Eo = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if Eo then
                        local Eo_1 = E7(k, v)
                        if Eo_1 then
                            En[#En + 1] = Eo_1
                        end
                    end
                end
            end
            table.sort(En, function(pE, pF)
                if pE.type ~= pF.type then
                    return pE.type < pF.type
                end
                return pE.idx < pF.idx
            end)
            return { objects = En }
        end
        E4 = function(pH)
            local EE
            EE = nil
            local EF = type(pH) ~= "table" or type(pH.idx) ~= "string"
            local EJ = if EF then 1 else 0
            local EH = 3009 * EJ + 1181 * (1 - EJ)
            local EI = 1385 * EJ + 958 * (1 - EJ)
            if not ((EH * 2167 + EI * 1785 + EH * EI) % 16777213 == 13160193) then
                EF = type(pH.type) ~= "string"
            end
            local EJ_1 = if EF then 1 else 0
            local EH_1 = 263 * EJ_1 + 1595 * (1 - EJ_1)
            local EI_1 = 2812 * EJ_1 + 55 * (1 - EJ_1)
            if not ((EH_1 * 2428 + EI_1 * 1874 + EH_1 * EI_1) % 16777213 == 6647808) then
                EF = SaveManager.Ignore[pH.idx]
            end
            if EF then
                return false
            end
            EE = E5(pH.type, pH.idx)
            if not EE then
                return false
            end
            local EF_1 = pcall(function()
                if pH.type == "Input" then
                    if type(pH.text) ~= "string" then
                        return
                    end
                    EE:SetValue(pH.text)
                elseif pH.type == "ColorPicker" then
                    EE:SetValueRGB(Color3.fromHex(pH.value), pH.transparency)
                elseif pH.type == "KeyPicker" then
                    EE:SetValue({ pH.key, pH.mode, pH.modifiers })
                    if pH.mode == "Toggle" and pH.toggled ~= nil then
                        EE.Toggled = pH.toggled
                        EE:Update()
                    end
                else
                    EE:SetValue(pH.value)
                end
            end)
            return EF_1
        end
        E8:AddDivider()
        E8:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        E8:AddButton("Export Config to Clipboard", function()
            local EO_1
            local EN_1
            EN_1, EO_1 = pcall(HttpService.JSONEncode, HttpService, E6())
            if EN_1 then
                local EN_2 = s9(setclipboard) and setclipboard
                local EP = EN_2
                if not EP then
                    local EN_3 = s9(toclipboard) and toclipboard
                    EP = EN_3 or nil
                end
                local EN_4 = EP
                local EP_1 = type(EN_4) == "function" and pcall(EN_4, EO_1)
                if EP_1 then
                    Library:Notify("Config copied to clipboard", 6)
                    return
                end
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Failed to encode the config")
        end)
        E8:AddButton("Import Config from Clipboard Text", function()
            local EX_1
            local EV = Options.SaveManager_ImportSource.Value or ""
            local EV_1
            local EW = tostring(EV):match("^%s*(.-)%s*$")
            if EW == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            if #EW > 262144 then
                Library:Notify("That config is too large")
                return
            end
            EV_1, EX_1 = pcall(HttpService.JSONDecode, HttpService, EW)
            local EW_1 = not EV_1 or type(EX_1) ~= "table" or type(EX_1.objects) ~= "table"
            if EW_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            if #EX_1.objects > 2048 then
                Library:Notify("That config has too many records")
                return
            end
            local EV_2 = 0
            for i, v in ipairs(EX_1.objects) do
                if E4(v) then
                    EV_2 += 1
                end
            end
            if EV_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local EX_2 = EV_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(EV_2, EX_2), 6)
        end)
        ThemeManager:LoadDefault()
        SaveManager:LoadAutoloadConfig()
        if Options.TargetMode then
            tu.SetTargetMode(Options.TargetMode.Value)
        end
        if Options.ClickDelay then
            tu.SetClickDelay(Options.ClickDelay.Value)
        end
        if Options.ChestThreshold then
            tu.SetChestThreshold(Options.ChestThreshold.Value)
        end
        if Options.SellKinds then
            tu.SetSellKinds(Options.SellKinds.Value)
        end
        if Options.SellRarities then
            tu.SetSellRarities(Options.SellRarities.Value)
        end
        if Options.SellKeepAbove then
            tu.SetSellKeepAbove(Options.SellKeepAbove.Value)
        end
        if Options.SellAtCount then
            tu.SetSellAtCount(Options.SellAtCount.Value)
        end
        if Options.UpgradeReserve then
            tu.SetUpgradeReserve(Options.UpgradeReserve.Value)
        end
        if Options.PickaxeNames then
            tu.SetPickaxeNames(Options.PickaxeNames.Value)
        end
        if Toggles.SellTeleport then
            tu.SetSellTeleport(Toggles.SellTeleport.Value)
        end
        if Toggles.SellReturn then
            tu.SetSellReturn(Toggles.SellReturn.Value)
        end
        if Toggles.BuyCoreUpgrades then
            tu.SetBuyCoreUpgrades(Toggles.BuyCoreUpgrades.Value)
        end
        if Toggles.BuyZoneSkills then
            tu.SetBuyZoneSkills(Toggles.BuyZoneSkills.Value)
        end
        if Toggles.AutoEquipBest then
            tu.SetAutoEquipBest(Toggles.AutoEquipBest.Value)
        end
        if Toggles.AutoChest then
            tu.SetAutoChest(Toggles.AutoChest.Value)
        end
        if Toggles.AutoUpgrades then
            tu.SetAutoUpgrades(Toggles.AutoUpgrades.Value)
        end
        if Toggles.ZoneResearch then
            tu.SetZoneResearch(Toggles.ZoneResearch.Value)
        end
        if Toggles.AutoZones then
            tu.SetAutoZones(Toggles.AutoZones.Value)
        end
        if Toggles.AutoPickaxes then
            tu.SetAutoPickaxes(Toggles.AutoPickaxes.Value)
        end
        if Toggles.AutoSell then
            tu.SetAutoSell(Toggles.AutoSell.Value)
        end
        if Toggles.AutoMine then
            tu.SetAutoMine(Toggles.AutoMine.Value)
        end
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    Fs_5()
end
if (not s9 or not tE or (not s4 or not sV)) and (not sU and not s4 and (not s4 or not tE)) or s4 and not sU and (not s9 and sV) and (s4 or s9 or (s4 or not tE)) or not ((not s9 or not tE or (not s4 or not sV)) and (not sU and not s4 and (not s4 or not tE)) or s4 and not sU and (not s9 and sV) and (s4 or s9 or (s4 or not tE))) then
    tM()
else
    tM()
end
end)(...)

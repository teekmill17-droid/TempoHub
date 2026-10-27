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
getgenv().TempoHoodSubtitle = "BE A FISH BAIT! SCI-FI UPD"
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
local h1
local iL
local is
local i9
local iR
local iy
local exclusive_fish
local iX
local iE
local shops
local i2
local FishingRodController
local iK
local training_weights
local i8
local h6
local connection2
local ix
local fishing_phase_atom
local ic
local inventory_utils
local iD
local connection
local ij
local fishing_hooks_selectors
local diagonalTweenDuration
local rebirth_utils
local iq
local selectors
local h5
local bait_aura_utils
local iw
local jd
local ib
local iC
local jj
local ii
local i0
local iI
local ip
local i6
local network
local iO
local iv
local jc
local Options
local iU
local fishing_rods
local clientProducer
local ih
local i_
local onStart
local io
local boss_config
local h3
local iN
local iu
local reel_camera
local h9
local Library
local _onReelStarted
local jh
local Toggles
local UserInputService
local iG
local im
local i4
local h2
local iM
local it
local CollectionService
local WeightTrainingController
local LocalPlayer
local iz
local CastCutSceneComponent
local ie
local iY
local iF
local il
local VirtualUser
local function fn223()
    Library.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
local function fn411(O)
    O:AddLeftGroupbox("Discord"):AddButton({
        Text = "Join Discord For Dupe",
        Func = function()
            setclipboard(io)
            Library:Notify("Copied Discord invite to clipboard")
        end
    })
end
diagonalTweenDuration = nil
FishingRodController = nil
h1 = nil
h2 = nil
h3 = nil
network = nil
h5 = nil
h6 = nil
WeightTrainingController = nil
h9 = nil
Options = nil
ib = nil
ic = nil
exclusive_fish = nil
ie = nil
Toggles = nil
ih = nil
ii = nil
ij = nil
shops = nil
il = nil
im = nil
io = nil
ip = nil
iq = nil
training_weights = nil
is = nil
it = nil
iu = nil
iv = nil
iw = nil
ix = nil
iy = nil
iz = nil
_onReelStarted = nil
fishing_rods = nil
iC = nil
iD = nil
iE = nil
iF = nil
iG = nil
onStart = nil
iI = nil
rebirth_utils = nil
iK = nil
iL = nil
iM = nil
iN = nil
iO = nil
local h7
bait_aura_utils = nil
connection2 = nil
iR = nil
LocalPlayer = nil
Library = nil
iU = nil
inventory_utils = nil
iX = nil
iY = nil
UserInputService = nil
i_ = nil
i0 = nil
fishing_hooks_selectors = nil
i2 = nil
VirtualUser = nil
i4 = nil
boss_config = nil
i6 = nil
selectors = nil
i8 = nil
i9 = nil
CollectionService = nil
reel_camera = nil
jc = nil
jd = nil
fishing_phase_atom = nil
CastCutSceneComponent = nil
jh = nil
clientProducer = nil
jj = nil
connection = nil
local iV, jf
CollectionService, VirtualUser, UserInputService, LocalPlayer, iu, io = nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
CollectionService = game:GetService("CollectionService")
VirtualUser = game:GetService("VirtualUser")
UserInputService = game:GetService("UserInputService")
LocalPlayer = Players.LocalPlayer
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
local TS = PlayerScripts:WaitForChild("TS")
iu = tostring(LocalPlayer.UserId)
io = "https://discord.gg/K7Qxnxkk46"
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
network, clientProducer, fishing_phase_atom, selectors, fishing_hooks_selectors, inventory_utils, bait_aura_utils, rebirth_utils, fishing_rods, training_weights, shops, exclusive_fish, WeightTrainingController, FishingRodController, CastCutSceneComponent, reel_camera, boss_config, Library, Toggles, Options = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
network = require(TS:WaitForChild("network"))
clientProducer = require(TS:WaitForChild("reflex"):WaitForChild("producer")).clientProducer
fishing_phase_atom = require(TS:WaitForChild("fishing-phase-atom"))
selectors = require(ReplicatedStorage.TS.slices["player-data"].selectors)
fishing_hooks_selectors = require(ReplicatedStorage.TS.slices["fishing-hooks.selectors"])
inventory_utils = require(ReplicatedStorage.TS.utils["inventory-utils"])
bait_aura_utils = require(ReplicatedStorage.TS.utils["bait-aura-utils"])
rebirth_utils = require(ReplicatedStorage.TS.data["rebirth-utils"])
fishing_rods = require(ReplicatedStorage.TS.data["fishing-rods"])
training_weights = require(ReplicatedStorage.TS.data["training-weights"])
shops = require(ReplicatedStorage.TS.data.shops)
exclusive_fish = require(ReplicatedStorage.TS.data["exclusive-fish"])
WeightTrainingController = require(TS.controllers["weight-training-controller"]).WeightTrainingController
FishingRodController = require(TS.controllers["fishing-rod-controller"]).FishingRodController
CastCutSceneComponent = require(TS.components["cast-cutscene-component"]).CastCutSceneComponent
reel_camera = require(TS["reel-camera"])
boss_config = require(TS.react.screen.fishing["rare-fish-boss"]["boss-config"])
Library = getgenv().Library
pcall(fn223)
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = "https://discord.gg/K7Qxnxkk46 | Be A Fish Bait",
    Icon = 18657887261,
    NotifySide = "Right",
    ShowCustomCursor = false
})
local js = { Main = Window:AddTab("Main", "fish"), Settings = Window:AddTab("Settings", "settings") }
for k, v in pairs(js) do
    fn411(v)
end
local FishingGroup = js.Main:AddLeftGroupbox("Fishing", "fish")
FishingGroup:AddToggle("AutoFish", { Text = "Auto Fish (Perfect Charge)", Default = false })
FishingGroup:AddToggle("AutoMutationBoost", { Text = "Auto Mutation Boost", Default = false })
FishingGroup:AddToggle("SkipFishAnimation", { Text = "Skip Fish Animation", Default = false })
FishingGroup:AddToggle("AutoBossBattle", { Text = "Auto Boss Battle", Default = false })
FishingGroup:AddToggle("AutoAquarium", { Text = "Auto Equip Best For Aquarium", Default = false })
FishingGroup:AddToggle("AutoCollectAquariumMoney", { Text = "Auto Collect Money From Aquarium", Default = false })
FishingGroup:AddToggle("AutoUpgradeAquarium", { Text = "Auto Upgrade Aquarium Capacity", Default = false })
FishingGroup:AddToggle("AutoRevealAquarium", { Text = "Auto Reveal Aquarium", Default = false })
local TrainingGroup = js.Main:AddLeftGroupbox("Training", "dumbbell")
TrainingGroup:AddToggle("AutoTrain", { Text = "Auto Train", Default = false })
TrainingGroup:AddToggle("DisableTrainingFreeze", { Text = "Disable Training Freeze", Default = false })
TrainingGroup:AddToggle("AutoTrainingBoost", { Text = "Auto Training 2x", Default = false })
TrainingGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
local ShopsGroup = js.Main:AddRightGroupbox("Shops", "shopping-cart")
ShopsGroup:AddToggle("AutoBuyRod", { Text = "Auto Buy Best Affordable Rod", Default = false })
ShopsGroup:AddToggle("AutoBuyWeight", { Text = "Auto Buy Best Affordable Weights", Default = false })
ShopsGroup:AddToggle("AutoSpinWheel", { Text = "Auto Spin Wheel", Default = false })
local SellingGroup = js.Main:AddRightGroupbox("Selling", "hand-coins")
SellingGroup:AddToggle("AutoSellFish", { Text = "Auto Sell All Fish", Default = false })
SellingGroup:AddDropdown("SellTrigger", {
    Text = "Sell Trigger",
    Values = { "Backpack Full", "Interval", "Backpack Full or Interval" },
    Default = "Backpack Full"
})
SellingGroup:AddSlider("SellInterval", { Text = "Sell Interval (Seconds)", Default = 30, Min = 1, Max = 300, Rounding = 0 })
local MenuGroup = js.Settings:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
jc = tick()
i6 = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local jV = v
        pcall(function()
            jV:Disable()
        end)
    end
end)
iy = function()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    i6 = tick()
end
connection = UserInputService.InputBegan:Connect(function()
    jc = tick()
end)
connection2 = UserInputService.InputChanged:Connect(function(am)
    local UserInputType = am.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        jc = tick()
    end
end)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)
iC = function()
    return clientProducer:getState()
end
im = function(av)
    return selectors.selectPlayerInventory(iu)(av)
end
jh = function(az)
    return selectors.selectEquippedInventoryItem(iu)(az)
end
iV = function(aD)
    local j0 = {}
    local j2 = aD or {}
    for k, v in pairs(j2) do
        local j1_1 = v.itemType == "fish" and v.exclusiveIndex == nil and not exclusive_fish.getExclusiveFishConfigByFishName(v.itemName)
        if j1_1 then
            table.insert(j0, v.itemId)
        end
    end
    return j0
end
h7 = false
h1 = function()
    local ka
    local kc_1
    local kb_1
    if h7 then
        return
    end
    ka = iV(im(iC()))
    if #ka == 0 then
        return
    end
    h7 = true
    kb_1, kc_1 = pcall(function()
        return network.functions.sellFishItems(ka):expect()
    end)
    h7 = false
    if not kb_1 then
        error(kc_1)
    end
end
SellingGroup:AddButton({
    Text = "Sell All Fish Now",
    Func = function()
        pcall(h1)
    end
})
h5 = function(aX)
    local kh = im(aX)
    local ki
    local kj = -math.huge
    local kl = kh or {}
    for k, v in pairs(kl) do
        if v.itemType == "trainingWeight" then
            local kh_1 = training_weights.trainingWeightsData[v.itemName]
            if kh_1 and kh_1.powerPerTrain > kj then
                ki = v
                kj = kh_1.powerPerTrain
            end
        end
    end
    return ki
end
ie = nil
h9 = function()
    local kv_1
    local kt_1
    if ie then
        return ie
    end
    for i, v in ipairs(getgc(true)) do
        if type(v) == "table" then
            kt_1, kv_1 = pcall(getmetatable, v)
            if kt_1 and kv_1 == WeightTrainingController then
                ie = v
                return ie
            end
        end
    end
end
iN = function(bf)
    local kI = h9()
    if not kI then
        return
    end
    if bf then
        kI._characterController:_enableMovement()
    else
        kI._characterController:_disableMovement()
    end
end
ih = function()
    if fishing_phase_atom.fishingMovementLockedAtom() then
        return
    end
    local kN = iC()
    local kO = h5(kN)
    local kP = jh(kN)
    if kO and (not kP or kP.itemId ~= kO.itemId) then
        network.functions.equipInventoryItem(kO.itemId):expect()
    end
end
il = function(bv)
    if bv.fishingArea.isInFishingArea then
        return true
    end
    local Character = LocalPlayer.Character
    local kT = Character and Character:FindFirstChild("HumanoidRootPart")
    local kT_1 = CollectionService:GetTagged("FishingArea")[1]
    local kU = kT_1 and kT_1:FindFirstChild("DetectableArea", true)
    if kT and kU then
        kT.CFrame = kU.CFrame
    end
    return false
end
iI = function(bF)
    for i, child in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if child ~= Library.ScreenGui then
            for i, descendant in ipairs(child:GetDescendants()) do
                local k1 = bF(descendant)
                if k1 ~= nil then
                    return k1
                end
            end
        end
    end
end
i4 = nil
i_ = function()
    local lk = i4
    if not (lk and lk.Parent and lk.Visible and lk.Text == "FISH!") then
        i4 = iI(function(bT)
            local lf = bT:IsA("TextLabel") and bT.Visible and bT.Text == "FISH!"
            if lf then
                return bT
            end
        end)
        lk = i4
    end
    if not lk then
        return
    end
    local ll_1 = lk.Parent
    while true do
        local lk_1 = ll_1 and not ll_1:IsA("GuiButton")
        if lk_1 then
            ll_1 = ll_1.Parent
            continue
        end
        break
    end
    if ll_1 and ll_1.Visible then
        return ll_1
    end
end
jf = nil
i8 = function()
    local ViewportSize
    ViewportSize = nil
    local CurrentCamera = workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    ViewportSize = CurrentCamera.ViewportSize
    local lz_1 = jf
    if lz_1 and lz_1.Parent and lz_1.Visible and lz_1.AbsoluteSize.X >= ViewportSize.X * 0.9 and lz_1.AbsoluteSize.Y >= ViewportSize.Y * 0.9 then
        return lz_1
    end
    jf = iI(function(b5)
        local lt = b5:IsA("TextButton") and b5.Visible and b5.AbsoluteSize.X >= ViewportSize.X * 0.9 and b5.AbsoluteSize.Y >= ViewportSize.Y * 0.9
        if lt then
            return b5
        end
    end)
    return jf
end
h2 = function()
    for i, v in ipairs(getgc(true)) do
        local lF = type(v) == "table" and type(rawget(v, "getStrength")) == "function" and type(rawget(v, "reset")) == "function" and type(rawget(v, "freeze")) == "function"
        if lF then
            local lF_1 = debug.getupvalues(rawget(v, "getStrength"))
            for k, v in pairs(lF_1) do
                local lF_2 = type(v) == "table" and type(rawget(v, "current")) == "number"
                if lF_2 then
                    v.current = 100
                    break
                end
            end
        end
    end
end
iw = false
ip = function()
    if fishing_phase_atom.fishingMovementLockedAtom() then
        iw = false
        return
    end
    local lW = iC()
    local lW_3
    local lX = im(lW)
    local lX_3
    local lY = not lX or not inventory_utils.hasSpaceInBackpack(lX)
    if lY then
        return
    elseif Toggles.AutoTrain.Value then
        local lX_1 = jh(lW)
        if lX_1 and lX_1.itemType == "trainingWeight" then
            iw = true
            network.functions.unequipInventoryItem(lX_1.itemId):expect()
            return
        elseif not il(lW) then
            return
        else
            local lW_1 = i_()
            if not lW_3 then
                return
            end
            firesignal(lW_1.Activated)
            local lW_2 = os.clock() + 2
            while true do
                local lX_2 = not Library.Unloaded and Toggles.AutoFish.Value and os.clock() < lW_2
                if lX_3 then
                    lX_1 = i8()
                    if lX then
                        break
                    end
                    task.wait(0.05)
                    continue
                end
                return
            end
            h2()
            firesignal(lX_1.MouseButton1Down)
            iw = false
            return
        end
    elseif not il(lW) then
        return
    else
        lW_3 = i_()
        if not lW_3 then
            return
        end
        firesignal(lW_3.Activated)
        local lW_4 = os.clock() + 2
        while true do
            lX_3 = not Library.Unloaded and Toggles.AutoFish.Value and os.clock() < lW_4
            if lX_3 then
                lX = i8()
                if lX then
                    break
                end
                task.wait(0.05)
                continue
            end
            return
        end
        h2()
        firesignal(lX.MouseButton1Down)
        iw = false
        return
    end
end
iG = function()
    local l2 = iC()
    local l3 = selectors.selectPlayerRebirthCount(iu)(l2)
    local l4 = selectors.selectPlayerStats(iu)(l2)
    local l2_1 = l3 == nil or not l4 or rebirth_utils.isMaxRebirth(l3)
    if l2_1 then
        return
    end
    if l4.power >= rebirth_utils.getRebirthPowerCost(l3) then
        network.functions.performRebirth():expect()
    end
end
iY = function(cP, cQ, cR, cS)
    local l6 = iC()
    local l7 = im(l6)
    if not l7 then
        return
    end
    local l8 = {}
    for k, v in pairs(l7) do
        l8[v.itemName] = true
    end
    local l7_1 = 0
    for i, v in ipairs(cQ) do
        if l8[v] then
            l7_1 = i
        end
    end
    local l8_1 = cQ[l7_1 + 1]
    local l9 = l8_1 and cR[l8_1]
    if not l9 or l7_1 == 0 then
        return
    end
    local l7_2 = (selectors.selectPlayerRebirthCount(iu)(l6))
    local mu = if l7_2 then 1 else 0
    local ms = 144 * mu + 2692 * (1 - mu)
    local mt = 1093 * mu + 1079 * (1 - mu)
    if not ((ms * 2248 + mt * 1417 + ms * mt) % 16777213 == 2029885) then
        l7_2 = 0
    end
    if l7_2 < (cS[l8_1] or 0) then
        return
    end
    local l7_4 = selectors.selectPlayerStat(iu, "money")(l6) or 0
    local l7_5 = selectors.selectEquippedBaitAuraName(iu)(l6)
    local moneyDiscount = bait_aura_utils.getBaitAuraBuffBonuses(l7_5).moneyDiscount
    local l7_6 = math.floor(l9.price * (1 - moneyDiscount))
    if l7_4 >= l7_6 then
        network.functions.purchaseShopItem(cP, l8_1):expect()
    end
end
iL = nil
iD = nil
iv = function()
    local mv = iC()
    local mw = im(mv)
    local mx = selectors.selectPlayerAquarium(iu)(mv)
    if mw == iL and mx == iD then
        return
    end
    iL = mw
    iD = mx
    network.functions.equipBestAquariumFish():expect()
end
iK = function()
    local mA = selectors.selectPlayerAquariumUncollectedMoney(iu)(iC()) or 0
    if mA > 0 then
        network.functions.collectPlotMoney(iu):expect()
    end
end
h3 = function()
    local mD = iC()
    local mE = selectors.selectPlayerAquariumUpgradeStartedTimestamp(iu)(mD)
    local mF = not mE
    if mF ~= false then
        mF = selectors.selectCanAffordAquariumUpgrade(iu)(mD)
    end
    if mF then
        network.functions.upgradeAquarium():expect()
    end
end
ix = function()
    local mH = iC()
    local mI = selectors.selectPlayerAquariumUpgradeStartedTimestamp(iu)(mH)
    if mI then
        network.functions.confirmAquariumUpgrade():expect()
    end
end
i9 = function()
    local mK = (selectors.selectPlayerStat(iu, "spinWheelSpins")(iC()))
    local mP = if mK then 1 else 0
    local mN = 738 * mP + 3216 * (1 - mP)
    local mO = 1718 * mP + 1947 * (1 - mP)
    if not ((mN * 2188 + mO * 560 + mN * mO) % 16777213 == 3844708) then
        mK = 0
    end
    if mK > 0 then
        network.functions.spinPlaytimeWheel():expect()
    end
end
it = function()
    iI(function(dF)
        local mQ = dF:IsA("TextButton") and dF.Visible and dF.Text == "" and dF.AbsoluteSize.X > 50 and math.abs(dF.AbsoluteSize.X - dF.AbsoluteSize.Y) < 2
        if mQ then
            local UICorner = dF:FindFirstChildOfClass("UICorner")
            local mR = UICorner and UICorner.CornerRadius.Scale == 0.5 and #getconnections(dF.Activated) > 0
            if mR then
                firesignal(dF.Activated)
                return true
            end
        end
    end)
end
jd = function()
    iI(function(dL)
        local Parent = dL.Parent
        local mX = dL:IsA("TextButton") and dL.Visible and dL.Text == "" and dL.Size == UDim2.fromOffset(168, 168) and Parent and Parent:IsA("GuiObject") and Parent.Size == UDim2.fromOffset(140, 140) and #getconnections(dL.Activated) > 0
        if mX then
            firesignal(dL.Activated)
            return true
        end
    end)
end
onStart = CastCutSceneComponent.onStart
_onReelStarted = FishingRodController._onReelStarted
local jl_6 = debug.getupvalues(reel_camera.playReelCamera)
ij = jl_6[1]
ib = jl_6[5]
h6 = jl_6[8]
diagonalTweenDuration = ij.diagonalTweenDuration
CastCutSceneComponent.onStart = function(dV, ...)
    local m3 = onStart(dV, ...)
    if Toggles.SkipFishAnimation.Value and dV._soundClockTrack then
        task.defer(function()
            if dV._soundClockTrack and dV._soundClockTrack.IsPlaying then
                dV._soundClockTrack:AdjustSpeed(20)
            end
        end)
    end
    return m3
end
FishingRodController._onReelStarted = function(d1, ...)
    if Toggles.SkipFishAnimation.Value then
        debug.setupvalue(reel_camera.playReelCamera, 5, function()
            return false
        end)
        debug.setupvalue(reel_camera.playReelCamera, 8, 0.15)
        ij.diagonalTweenDuration = 0.1
    else
        debug.setupvalue(reel_camera.playReelCamera, 5, ib)
        debug.setupvalue(reel_camera.playReelCamera, 8, h6)
        ij.diagonalTweenDuration = diagonalTweenDuration
    end
    return _onReelStarted(d1, ...)
end
i2 = nil
iX = function()
    local m7 = not Toggles.SkipFishAnimation.Value or not fishing_phase_atom.fishingMovementLockedAtom()
    if m7 then
        i2 = nil
        return
    end
    local m7_1 = iC()
    local m8 = fishing_hooks_selectors.selectLocalPlayerHook(iu)(m7_1)
    local m7_2 = m8 ~= nil or i8() ~= nil or workspace:FindFirstChild("CastCutScene") ~= nil or fishing_phase_atom.bossActivePromptAtom() ~= nil or fishing_phase_atom.apexSkillCheckAtom() ~= nil or fishing_phase_atom.apexDropAtom() ~= nil or fishing_phase_atom.apexRevealAtom() ~= nil or fishing_phase_atom.apexAfterRareFishCutsceneAtom() or fishing_phase_atom.rareFishTransitionAtom() ~= nil or fishing_phase_atom.catchFadeAtom() ~= nil
    if m7_2 then
        i2 = nil
        return
    end
    local m7_3 = i2 or os.clock()
    i2 = m7_3
    if os.clock() - i2 >= 4 then
        i2 = nil
        fishing_phase_atom.fishingMovementLockedAtom(false)
    end
end
iM = nil
iE = nil
iE = hookmetamethod(game, "__namecall", newcclosure(function(eq, ...)
    local nd = iM and eq == UserInputService and getnamecallmethod() == "GetMouseLocation"
    if nd then
        return iM
    end
    return iE(eq, ...)
end))
jj = function()
    local nf
    local ng = -math.huge
    for i, v in ipairs(getgc(true)) do
        if type(v) == "table" then
            local nh = rawget(v, "promptType")
            if nh == "tap" or nh == "multiTap" or nh == "slide" then
                local nh_1 = tonumber(rawget(v, "spawnTime"))
                local ni_2 = nh_1 and nh_1 > ng and os.clock() - nh_1 < 10 and rawget(v, "action") ~= nil
                if ni_2 then
                    nf = v
                    ng = nh_1
                end
            end
        end
    end
    return nf
end
is = function()
    local eE
    eE = {}
    iI(function(eG)
        local ns = eG:IsA("TextButton") and eG.Visible and eG.Text == "" and eG.AbsoluteSize.X > 80 and eG.AbsoluteSize.X < 280 and math.abs(eG.AbsoluteSize.X - eG.AbsoluteSize.Y) < 2
        if ns then
            local UICorner = eG:FindFirstChildOfClass("UICorner")
            local nt = UICorner and UICorner.CornerRadius.Scale == 0.5 and #getconnections(eG.Activated) > 0
            if nt then
                eE[#eE + 1] = eG
            end
        end
    end)
    return eE
end
i0 = nil
iU = nil
iO = nil
iF = nil
iq = 0
iz = 0
ii = setmetatable({}, { __mode = "k" })
ic = function()
    local pathTolerance = boss_config.bossTuning.slide.pathTolerance
    boss_config.bossTuning.slide.pathTolerance = math.huge
    pcall(function()
        for i, v in ipairs(getconnections(UserInputService.InputBegan)) do
            if type(v.Function) == "function" then
                pcall(v.Function, { UserInputType = Enum.UserInputType.MouseButton1 })
            end
        end
    end)
    boss_config.bossTuning.slide.pathTolerance = pathTolerance
end
iR = function()
    local nF = fishing_phase_atom.bossActivePromptAtom()
    if nF == nil then
        iM = nil
        i0 = nil
        iU = nil
        iO = nil
        iF = nil
        table.clear(ii)
        return
    end
    if nF ~= i0 then
        i0 = nF
        iU = nil
        iO = nil
        iF = nil
        iM = nil
        table.clear(ii)
    end
    local nF_1 = not iU and os.clock() - iz >= 0.05
    if nF_1 then
        iz = os.clock()
        iU = jj()
    end
    local nF_2 = iU
    if not nF_2 then
        return
    end
    if nF_2.promptType == "multiTap" then
        if os.clock() - iq < 0.05 then
            return
        end
        iq = os.clock()
        local nG_1 = is()
        for i, v in ipairs(nG_1) do
            if not ii[v] then
                ii[v] = true
                firesignal(v.Activated)
            end
        end
        return
    end
    if nF_2.promptType == "tap" then
        local nG_2 = nF_2.spawnTime + nF_2.durationMs / 1000
        local nH = nF_2 ~= iO and os.clock() >= nG_2 - 0.01
        if nH then
            local nG_3 = is()
            local nH_1 = nG_3[1]
            if nH_1 then
                iO = nF_2
                firesignal(nH_1.Activated)
            end
        end
        return
    end
    if nF_2 ~= iF then
        local nG_4 = nF_2.spawnTime + nF_2.grabWindowMs / 1000
        if os.clock() < nG_4 - 0.01 then
            return
        end
        local nG_5 = jj() or nF_2
        iU = nG_5
        ic()
        if nG_5.slideGrabbed then
            iF = nG_5
            iM = nG_5.slideSpan.Unit * 1000000
        end
    end
end
task.spawn(function()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local nS = tick() - jc
            local nT = tick() - i6
            if nS >= 300 and nT >= 60 then
                pcall(iy)
            else
                if nS < 300 and nT >= 300 then
                    pcall(iy)
                end
            end
        end
    end
end)
task.spawn(function()
    local nW = false
    while not Library.Unloaded do
        if Toggles.AutoTrain.Value and not iw then
            pcall(ih)
        end
        local nX_1 = iC()
        local nY_1 = jh(nX_1)
        local nY_2 = nY_1 and nY_1.itemType == "trainingWeight"
        local nX_3 = Toggles.DisableTrainingFreeze.Value and nY_2 and not fishing_phase_atom.fishingMovementLockedAtom()
        if nX_3 then
            pcall(iN, true)
            nW = true
        elseif nW then
            local nX_4 = nY_2 and not fishing_phase_atom.fishingMovementLockedAtom()
            if nX_4 then
                pcall(iN, false)
            end
            nW = false
        end
        task.wait(0.25)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoTrainingBoost.Value then
            pcall(it)
        end
        task.wait(0.1)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoMutationBoost.Value then
            pcall(jd)
        end
        task.wait(0.1)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoBossBattle.Value then
            pcall(iR)
        else
            iM = nil
            i0 = nil
            iU = nil
            iO = nil
            iF = nil
            table.clear(ii)
        end
        task.wait(0.03)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        pcall(iX)
        task.wait(0.25)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoFish.Value then
            pcall(ip)
        else
            iw = false
        end
        task.wait(1)
    end
end)
task.spawn(function()
    local n7 = os.clock()
    while not Library.Unloaded do
        if Toggles.AutoSellFish.Value then
            local n8 = iC()
            local n9 = im(n8)
            local Value = Options.SellTrigger.Value
            local oa = n9 and not inventory_utils.hasSpaceInBackpack(n9)
            local oa_1 = os.clock() - n7 >= Options.SellInterval.Value
            if Value == "Backpack Full" and oa or Value == "Interval" and oa_1 or Value == "Backpack Full or Interval" and (oa or oa_1) then
                pcall(h1)
                n7 = os.clock()
            end
        else
            n7 = os.clock()
        end
        task.wait(0.25)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoRebirth.Value then
            pcall(iG)
        end
        if Toggles.AutoBuyRod.Value then
            pcall(iY, "rodsShop", fishing_rods.fishingRodOrder, fishing_rods.fishingRodsData, shops.rodRebirthRequirements)
        end
        if Toggles.AutoBuyWeight.Value then
            pcall(iY, "weightsShop", training_weights.trainingWeightOrder, training_weights.trainingWeightsData, shops.weightRebirthRequirements)
        end
        if Toggles.AutoSpinWheel.Value then
            pcall(i9)
        end
        task.wait(1)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoAquarium.Value then
            pcall(iv)
        else
            iL = nil
            iD = nil
        end
        if Toggles.AutoCollectAquariumMoney.Value then
            pcall(iK)
        end
        if Toggles.AutoUpgradeAquarium.Value then
            pcall(h3)
        end
        if Toggles.AutoRevealAquarium.Value then
            pcall(ix)
        end
        task.wait(2.5)
    end
end)
Library:OnUnload(function()
    CastCutSceneComponent.onStart = onStart
    FishingRodController._onReelStarted = _onReelStarted
    debug.setupvalue(reel_camera.playReelCamera, 5, ib)
    debug.setupvalue(reel_camera.playReelCamera, 8, h6)
    ij.diagonalTweenDuration = diagonalTweenDuration
    hookmetamethod(game, "__namecall", iE)
    local ok = iC()
    local ol = jh(ok)
    local ok_1 = Toggles.DisableTrainingFreeze.Value and ol and ol.itemType == "trainingWeight" and not fishing_phase_atom.fishingMovementLockedAtom()
    if ok_1 then
        pcall(iN, false)
    end
    connection:Disconnect()
    connection2:Disconnect()
    select("#", "Be A Fish Bait unloaded")
end)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Mint")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/BeAFishBait")
SaveManager:BuildConfigSection(js.Settings)
ThemeManager:ApplyToTab(js.Settings)
ThemeManager:LoadDefault()
SaveManager:LoadAutoloadConfig()
end)(...)

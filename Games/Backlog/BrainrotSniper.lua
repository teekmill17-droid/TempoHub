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
getgenv().TempoHoodSubtitle = "BRAINROT SNIPER"
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
local k8
local Label
local lx
local le
local kW
local SaveManager
local lk
local k1
local lJ
local lq
local lP
local UserInputService
local ld
local lV
local kV
local lC
local lj
local k0
local lI
local HttpService
local k6
local connection2
local lv
local lc
local lU
local Toggles
local lB
local lH
local lo
local k5
local lN
local lu
local lb
local lT
local kT
local lA
local lh
local kZ
local ln
local lM
local lt
local la
local lS
local kS
local lz
local LocalPlayer
local connection
local lF
local lm
local CurrentCamera
local VirtualUser
local k9
local lR
local ly
local lf
local kX
local lE
local ll
local lK
local lr
local function onCopyJoinScript_JobID()
    local nB = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, lK)
    if setclipboard then
        setclipboard(nB)
    elseif toclipboard then
        toclipboard(nB)
    end
    lH:Notify("Copied join script to clipboard")
end
local function autoSniperUpgradeLoop()
    while not lH.Unloaded do
        if Toggles.AutoSniperUpgrade and Toggles.AutoSniperUpgrade.Value and lN and lt and lf and lx then
            pcall(function()
                local oG = lt.GetShowLevel()
                local oH = lt.GetMaxLevel()
                if oG < oH then
                    local oH_1 = lf.GetShotLevelUpCost(oG + 1)
                    if lx.CanAfford(oH_1) then
                        lN.ShotLevelUp:FireServer(1)
                    end
                end
            end)
        end
        task.wait(0.75)
    end
end
local function fn64()
    local mS_1
    local mR_1
    if not lz then
        return {}
    end
    mR_1, mS_1 = pcall(function()
        return lz:GetState()
    end)
    local mT = mR_1 and type(mS_1) == "table" and type(mS_1.BrainrotAttackList) == "table"
    if mT then
        return mS_1.BrainrotAttackList
    end
    return {}
end
local function onCopyUSDTAddress()
    kZ(lT, "Copied USDT address")
end
local function fn108()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    lj = tick()
end
local function onJumpRequest()
    if lH.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local qg_1 = lA()
        if qg_1 then
            qg_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function onInputBegan()
    ll = tick()
end
local function fn191(aZ, a_)
    if a_ == "Highest Rarity" then
        local nm = tonumber(aZ.mutation) or 0
        local nn = nm * 1000000
        local no = (tonumber(aZ.id))
        local ns = if no then 1 else 0
        local nq = 1101 * ns + 1783 * (1 - ns)
        local nr = 3722 * ns + 2170 * (1 - ns)
        if not ((nq * 3312 + nr * 715 + nq * nr) % 16777213 == 10405664) then
            no = 0
        end
        return nn + no
    end
    return lr(aZ)
end
local function fn206(bf, bg, bh)
    return string.format("<b>%s</b> %s %s", bf, ly("-", "#5a6070"), ly(bg, bh))
end
local function fn209()
    local nu_1
    local nt_1
    if identifyexecutor then
        nu_1, nt_1 = identifyexecutor()
        local nv = nu_1 ~= ""
        local nw = type(nu_1) == "string" and nv
        if nw then
            local nv_1 = type(nt_1) == "string" and nt_1 ~= "" and nu_1 .. " " .. nt_1
            k1 = nv_1 or nu_1
        end
    end
end
local function fn216()
    kW(false)
    pcall(function()
        connection:Disconnect()
    end)
    pcall(function()
        connection2:Disconnect()
    end)
    select("#", "Unloaded!")
end
local function fn227()
    local Players = game:GetService("Players")
    local mI = Players.LocalPlayer
    local mM = if mI then 1 else 0
    local mK = 1080 * mM + 2966 * (1 - mM)
    local mL = 2043 * mM + 768 * (1 - mM)
    if not ((mK * 1301 + mL * 2890 + mK * mL) % 16777213 == 9515790) then
        mI = Players.PlayerAdded:Wait()
    end
    local mH_1 = mI
    return mH_1:WaitForChild("PlayerGui")
end
local function antiAfkLoop()
    while not lH.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local qQ = tick() - ll
            local qR = tick() - lj
            if qQ >= 300 and qR >= 60 then
                pcall(k9)
            else
                if qQ < 300 and qR >= 300 then
                    pcall(k9)
                end
            end
        end
    end
end
local function fn257()
    local Character = LocalPlayer.Character
    local p3 = Character and Character:FindFirstChild("HumanoidRootPart")
    return p3
end
local function fn311()
    local ra = {}
    for i, v in ipairs({ Toggles, lV }) do
        for k, v in pairs(v) do
            local rb = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if rb then
                local rb_1 = lP(k, v)
                if rb_1 then
                    ra[#ra + 1] = rb_1
                end
            end
        end
    end
    table.sort(ra, function(he, hf)
        if he.type ~= hf.type then
            return he.type < hf.type
        end
        return he.idx < hf.idx
    end)
    return { objects = ra }
end
local function autoUpgradeBaseLoop()
    while not lH.Unloaded do
        local pK = Toggles.AutoUpgradeBase and Toggles.AutoUpgradeBase.Value and lU and lm and la and lx and os.clock() - lu >= 5
        if pK then
            pcall(function()
                local pG = la.GetMaxUnlockedSlot(lm.GetUnlockSlot()) + 1
                local pH = la.GetMaxSlot()
                if pH > 0 and pH < pG then
                    return
                end
                local pH_1 = la.GetUnLockSlotCost(pG)
                if lx.CanAfford(pH_1) then
                    lu = os.clock()
                    lU.UnlockSlot:FireServer(pG)
                end
            end)
        end
        task.wait(1)
    end
end
local function fn329()
    local Character = LocalPlayer.Character
    local p0 = Character and Character:FindFirstChildOfClass("Humanoid")
    return p0
end
local function autoCollectLoop()
    while not lH.Unloaded do
        if Toggles.AutoCollect and Toggles.AutoCollect.Value and lU and lm and la and lB then
            pcall(function()
                local ov = la.GetMaxUnlockedSlot(lB:GetUnlockSlot()) or 0
                local oA = 1
                while oA <= ov do
                    local oB = oA
                    if lm.IsSlotUnlocked(oB) then
                        local ov_1 = lm.GetEquippedBrainrot(oB)
                        local ow_1 = ov_1 and lm.GetClaimGold(ov_1) > 0
                        if ow_1 then
                            lU.ClaimGold:FireServer(oB)
                        end
                    end
                    oA += 1
                end
            end)
        end
        task.wait(1)
    end
end
local function fn363(a6)
    local DiscordGroup = a6:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = lS })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = lS })
end
local function onCopyEthereumAddress()
    kZ(kS, "Copied Ethereum address")
end
local function onRenderStepped(fQ)
    if lH.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local qi_1 = lA()
        if qi_1 then
            qi_1.WalkSpeed = lV.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local qi_3 = lo()
        local qj = lA()
        if qi_3 and qj then
            qj.PlatformStand = true
            local qj_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                qj_1 = qj_1 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                qj_1 = qj_1 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                qj_1 = qj_1 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                qj_1 = qj_1 + CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                qj_1 = qj_1 + Vector3.new(0, 1, 0)
            end
            local qo = if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then 1 else 0
            if qo == 1 then
                qj_1 = qj_1 - Vector3.new(0, 1, 0)
            end
            qi_3.Velocity = Vector3.zero
            if qj_1.Magnitude > 0 then
                qi_3.CFrame = qi_3.CFrame + qj_1.Unit * lV.FlySpeed.Value * fQ
            end
        end
    end
end
local function onImportConfigFromClipboardTex()
    local rG_1
    local rE = lV.SaveManager_ImportSource.Value
    local rE_1
    local rK = if rE then 1 else 0
    local rI = 2419 * rK + 1259 * (1 - rK)
    local rJ = 66 * rK + 2090 * (1 - rK)
    if not ((rI * 284 + rJ * 375 + rI * rJ) % 16777213 == 871400) then
        rE = ""
    end
    local rF = tostring(rE):match("^%s*(.-)%s*$")
    if rF == "" then
        lH:Notify("Paste an exported config into the box first")
        return
    end
    rE_1, rG_1 = pcall(HttpService.JSONDecode, HttpService, rF)
    local rF_1 = not rE_1 or type(rG_1) ~= "table" or type(rG_1.objects) ~= "table"
    if rF_1 then
        lH:Notify("That is not a valid exported config")
        return
    end
    local rE_2 = 0
    for i, v in ipairs(rG_1.objects) do
        if k0(v) then
            rE_2 += 1
        end
    end
    if rE_2 == 0 then
        lH:Notify("No settings in that config matched this script")
        return
    end
    lV.SaveManager_ImportSource:SetValue("")
    local rG_2 = rE_2 == 1 and "" or "s"
    lH:Notify(("Imported %d setting%s"):format(rE_2, rG_2), 6)
end
local function fn499()
    kW(Toggles.AntiGameplayPause.Value)
end
local function fn505()
    if not Toggles.Fly.Value then
        local qs = lA()
        if qs then
            qs.PlatformStand = false
        end
    end
end
local function autoDroneUpgradeLoop()
    while not lH.Unloaded do
        if Toggles.AutoDroneUpgrade and Toggles.AutoDroneUpgrade.Value and lJ and lk and le and lx then
            pcall(function()
                local oP = lk.GetDroneLevel()
                local oQ = le.GetMaxLevel()
                if oP < oQ then
                    local oQ_1 = le.GetLevelUpCost(oP)
                    if lx.CanAfford(oQ_1) then
                        lJ.DroneLevelUp:FireServer(1)
                    end
                end
            end)
        end
        task.wait(0.75)
    end
end
local function autoUpgradeBrainrotsLoop()
    while not lH.Unloaded do
        if Toggles.AutoUpgradeBrainrots and Toggles.AutoUpgradeBrainrots.Value and lU and lm and k6 and lx and la then
            pcall(function()
                local Value = lV.BrainrotUpgradePriority.Value
                local pN = la.GetMaxUnlockedSlot(lm.GetUnlockSlot()) or 0
                local pO = {}
                local pU = 1
                while pU <= pN do
                    local pV = pU
                    if lm.IsSlotUnlocked(pV) then
                        local pN_1 = lm.GetEquippedBrainrot(pV)
                        if pN_1 then
                            local pP_1 = k6.GetLevelUpGoldCost(pN_1)
                            local pQ = pP_1 and pP_1 > 0 and lx.CanAfford(pP_1)
                            if pQ then
                                pO[#pO + 1] = { slot = pV, brainrot = pN_1 }
                            end
                        end
                    end
                    pU += 1
                end
                if #pO == 0 then
                    return
                end
                if Value == "Random" then
                    local pM_1 = pO[math.random(1, #pO)]
                    lU.UpgradeBrainrot:FireServer(pM_1.slot)
                else
                    table.sort(pO, function(fl, fm)
                        return k5(fl.brainrot, "Highest Gold/s") > k5(fm.brainrot, "Highest Gold/s")
                    end)
                    lU.UpgradeBrainrot:FireServer(pO[1].slot)
                end
            end)
        end
        task.wait(0.5)
    end
end
local function onCopyBitcoinAddress()
    kZ(kV, "Copied Bitcoin address")
end
local function onCopyPayPalLink()
    kZ(lM, "Copied PayPal link")
end
local function fn522(g1, g2)
    local Type = g2.Type
    if Type == "Toggle" then
        return { idx = g1, type = "Toggle", value = g2.Value == true }
    elseif Type == "Slider" then
        return { idx = g1, type = "Slider", value = tostring(g2.Value) }
    elseif Type == "Dropdown" then
        return { idx = g1, type = "Dropdown", multi = g2.Multi == true, value = g2.Value }
    elseif Type == "Input" then
        local q1 = g2.Value or ""
        return { idx = g1, type = "Input", text = tostring(q1) }
    elseif Type == "ColorPicker" then
        return { idx = g1, type = "ColorPicker", value = g2.Value:ToHex(), transparency = g2.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = g1,
            type = "KeyPicker",
            mode = g2.Mode,
            key = g2.Value,
            modifiers = g2.Modifiers,
            toggled = g2.Toggled
        }
    else
        return nil
    end
end
local function fn532(ae, af)
    if setclipboard then
        setclipboard(ae)
    elseif toclipboard then
        toclipboard(ae)
    end
    lH:Notify(af)
end
local function onInputChanged(gy)
    local UserInputType = gy.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        ll = tick()
    end
end
local function onCopySolanaAddress()
    kZ(lR, "Copied Solana address")
end
local function onStepped()
    if lH.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local p5_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if p5_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn705(gU, gV)
    local qV_1 = (gU == "Toggle" and Toggles or lV)[gV]
    local qU_2 = type(qV_1) == "table" and qV_1.Type == gU
    return qU_2 and qV_1 or nil
end
local function onCopyVenmoLink()
    kZ(lI, "Copied Venmo link")
end
local function onExportConfigToClipboard()
    local ry_1
    local rx_1
    rx_1, ry_1 = pcall(HttpService.JSONEncode, HttpService, lC())
    if not rx_1 then
        lH:Notify("Failed to encode the config")
        return
    end
    local rx_2 = setclipboard
    local rD = if rx_2 then 1 else 0
    local rB = 654 * rD + 250 * (1 - rD)
    local rC = 3480 * rD + 1368 * (1 - rD)
    if not ((rB * 1291 + rC * 3315 + rB * rC) % 16777213 == 14656434) then
        rx_2 = toclipboard
    end
    local rz = rx_2
    local rx_3 = type(rz) ~= "function"
    local rD_1 = if rx_3 then 1 else 0
    local rB_1 = 609 * rD_1 + 58 * (1 - rD_1)
    local rC_1 = 3377 * rD_1 + 1964 * (1 - rD_1)
    if not ((rB_1 * 2547 + rC_1 * 3694 + rB_1 * rC_1) % 16777213 == 16082354) then
        rx_3 = not pcall(rz, ry_1)
    end
    if rx_3 then
        lH:Notify("Your executor does not support copying to the clipboard")
        return
    end
    lH:Notify("Config copied to clipboard", 6)
end
local function onRscripts()
    if setclipboard then
        setclipboard(lb)
    elseif toclipboard then
        toclipboard(lb)
    end
    lH:Notify("Copied Rscripts profile to clipboard")
end
local function fn761(bc, bd)
    return string.format('<font color="%s">%s</font>', bd, bc)
end
local function fn815()
    kZ(ld, "Copied Discord invite to clipboard")
end
local function autoDroneShieldLoop()
    while not lH.Unloaded do
        if Toggles.AutoDroneShield and Toggles.AutoDroneShield.Value and lE and lh and kT then
            pcall(function()
                local oi = lh.Get("PendingShield") or 0
                local oi_1 = lh.Get("ShieldReadyTick") or 0
                local oi_2 = oi <= 0 and oi_1 - kT:GetDataTime() <= 0
                if oi_2 then
                    lE.ChargeShield:InvokeServer()
                end
            end)
        end
        task.wait(1)
    end
end
local function autoRebirthLoop()
    while not lH.Unloaded do
        if Toggles.AutoRebirth and Toggles.AutoRebirth.Value and lF and lq and lc and lx then
            pcall(function()
                local oV = lq.GetLevel()
                local oW = lc.GetMaxRebirth()
                if oV < oW then
                    local oX = lc.GetRebirthNeedCash(math.min(oV, oW))
                    if lx.GetGold() >= oX then
                        lF.RebirthUp:FireServer()
                    end
                end
            end)
        end
        task.wait(2)
    end
end
local function worker()
    local nE_1
    while true do
        task.wait(1)
        if lH.Unloaded then
            break
        end
        local nD = math.floor(os.clock() - lv)
        if nD < 60 then
            nE_1 = nD .. "s"
        elseif nD < 3600 then
            nE_1 = string.format("%dm %ds", math.floor((nD) / (60)), nD % 60)
        else
            nE_1 = string.format("%dh %dm", math.floor((nD) / (3600)), math.floor((nD % 3600) / (60)))
        end
        Label:SetText(ln("Session time", nE_1, k8))
    end
end
local function onUnload()
    lH:Unload()
end
local function onCopyLitecoinAddress()
    kZ(kX, "Copied Litecoin address")
end
local function antiGameplayPauseLoop()
    while not lH.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            kW(true)
        end
    end
end
local function fn938()
    if not Toggles.WalkSpeedEnabled.Value then
        local qu = lA()
        if qu then
            qu.WalkSpeed = 16
        end
    end
end
kS = nil
kT = nil
Toggles = nil
kV = nil
kW = nil
kX = nil
connection = nil
kZ = nil
k0 = nil
k1 = nil
k5 = nil
k6 = nil
k8 = nil
k9 = nil
la = nil
lb = nil
lc = nil
ld = nil
le = nil
lf = nil
LocalPlayer = nil
lh = nil
lj = nil
lk = nil
ll = nil
lm = nil
ln = nil
lo = nil
HttpService = nil
lq = nil
lr = nil
VirtualUser = nil
lt = nil
lu = nil
lv = nil
UserInputService = nil
lx = nil
ly = nil
lz = nil
lA = nil
lB = nil
lC = nil
SaveManager = nil
lE = nil
local k_, k2, k3, k4, k7, CollectionService
lF = nil
lH = nil
lI = nil
lJ = nil
lK = nil
CurrentCamera = nil
lM = nil
lN = nil
connection2 = nil
lP = nil
Label = nil
lR = nil
lS = nil
lT = nil
lU = nil
lV = nil
local lG, l1, l9, ma, md, ml
local l3_1, l3_2
local l__1, l__2
lH, SaveManager, UserInputService, VirtualUser, HttpService, CollectionService, LocalPlayer, ld, lb, kT, lU, lN, lJ, lF, lE, lB, lz, lx, lt, lq, lm, lk, lh, lf, le, lc, la, k6, k2, l3_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
getgenv().gethui = fn227
lH = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
local l0 = game:GetService("Players")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
local lZ = game:GetService("ReplicatedStorage")
CollectionService = game:GetService("CollectionService")
LocalPlayer = l0.LocalPlayer
local l4 = "Brainrot Sniper"
ld = "https://discord.gg/K7Qxnxkk46"
lb = "https://discord.gg/K7Qxnxkk46"
local Shared = lZ:WaitForChild("Shared")
local lY_1, lY_5
local function lX(B)
    local mO_1
    local mN_1
    mN_1, mO_1 = pcall(function()
        return require(B)
    end)
    if mN_1 then
        return mO_1
    end
    return nil
end
local l2 = lX(Shared.Packages.Net)
kT = lX(Shared.Packages.TimeSync)
lU = lX(Shared.Net.BrainrotSlot)
lX(Shared.Net.BrainrotSell)
lN = lX(Shared.Net.Shot)
lJ = lX(Shared.Net.Drone)
lF = lX(Shared.Net.Rebirth)
lE = lX(Shared.Net.Shield)
lB = lX(Shared.Data.BrainrotData)
lz = lX(Shared.Data.PlayerContextData)
lx = lX(Shared.Controller.EcoController)
lt = lX(Shared.Controller.ShotController)
lq = lX(Shared.Controller.RebirthController)
lm = lX(Shared.Controller.BrainrotController)
lk = lX(Shared.Controller.DroneController)
lh = lX(Shared.Controller.PlayerStorageController)
lf = lX(Shared.Helper.ShotHelper)
le = lX(Shared.Helper.DroneHelper)
lc = lX(Shared.Helper.RebirthHelper)
la = lX(Shared.Helper.PlaceHelper)
k6 = lX(Shared.Helper.BrainrotHelper)
k2 = lX(Shared.Service.DroneService.DroneManager)
if ((lf or lf) and (lf and lX) or (lf or not lX) and (not lX or lf) or l0 and l0 and (lX or not l0) and (not lX and lX and (not lX and l0))) and ((not l0 or lf) and (lX and not lf) and (not lX and l0 or (not lf or not l0)) or (not l0 or l0 or lX and lf or lf and l0 and (not l0 or lf))) or not (((lf or lf) and (lf and lX) or (lf or not lX) and (not lX or lf) or l0 and l0 and (lX or not l0) and (not lX and lX and (not lX and l0))) and ((not l0 or lf) and (lX and not lf) and (not lX and l0 or (not lf or not l0)) or (not l0 or l0 or lX and lf or lf and l0 and (not l0 or lf)))) then
    l3_1 = l2
else
    l2 = l3_1
end
if l3_1 then
    l3_1 = l2:RemoteEvent("BrainrotAttack")
end
k_, Toggles, lV, kZ, lS, lG, lr, k7, k5, lY_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
k_ = l3_1
kZ = fn532
lS = fn815
lG = fn64
lr = function(ar)
    local m3_1
    local m2_1
    if not lm then
        return 0
    end
    m2_1, m3_1 = pcall(function()
        local GetBrainrotCashSpeed = lm.GetBrainrotCashSpeed
        local id = ar.id
        local mutation = ar.mutation
        local m0 = ar.level or 1
        return GetBrainrotCashSpeed({ id = id, mutation = mutation, level = m0, event_mutation = ar.event_mutation })
    end)
    local m4 = m2_1 and type(m3_1) == "number"
    if m4 then
        return m3_1
    end
    return 0
end
k7 = function()
    local na_1, na_4
    local m6 = {}
    local Character = LocalPlayer.Character
    local m8 = Character and Character:FindFirstChild("HumanoidRootPart")
    local m9 = not m8 or not lt
    local m9_1
    if m9 then
        return m6
    end
    local m8_2 = m8.Position.Z
    local m7_2 = 0
    m9_1, na_1 = pcall(function()
        return lt.GetCurrentDistance()
    end)
    local nb = m9_1 and type(na_1) == "number"
    local nb_1
    if nb then
        m7_2 = na_1
    end
    if m7_2 <= 0 then
        return m6
    end
    local GameFolder = workspace:FindFirstChild("GameFolder")
    local na_2 = GameFolder and GameFolder:FindFirstChild("BrainrotModels")
    if not na_2 then
        return m6
    end
    for i, child in ipairs(na_2:GetChildren()) do
        local nl = child
        local m9_4 = nl:IsA("Model") and CollectionService:HasTag(nl, "BrainrotEnemy")
        if m9_4 then
            local attr = nl:GetAttribute("Uid")
            local na_3 = attr and not nl:GetAttribute("IsDead")
            if na_3 then
                na_4, nb_1 = pcall(function()
                    return nl:GetPivot().Position
                end)
                if na_4 then
                    local na_5 = m8_2 - nb_1.Z
                    if na_5 > 0 and na_5 < m7_2 then
                        m6[#m6 + 1] = attr
                    end
                end
            end
        end
    end
    return m6
end
k5 = fn191
local Window = lH:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = ld, Copyable = true }, "|", l4 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
Toggles = lH.Toggles
lV = lH.Options
lZ = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "crosshair"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
if ((not lV or k5) and (not lV or not lV) and (not lY_1 or lY_1 or k5 and 20) and (k5 and not lG and (k5 or not lY_1) and (lY_1 or not lV)) or (not k5 or lG or (not lV or lV) or 20) and ((lV and lY_1 or not k5 and not lY_1) and ((not lV or not lG) and (lY_1 or k5)))) and not ((not lV or k5) and (not lV or not lV) and (not lY_1 or lY_1 or k5 and 20) and (k5 and not lG and (k5 or not lY_1) and (lY_1 or not lV)) or (not k5 or lG or (not lV or lV) or 20) and ((lV and lY_1 or not k5 and not lY_1) and ((not lV or not lG) and (lY_1 or k5)))) then
    kZ = fn363
else
    lY_1 = fn363
end
for k, v in lZ do
    if v ~= lZ.Info then
        lY_1(v)
    end
end
l2, l1, k8, l0, k1, lX, l3_2, Label, lK, l__1, ly, ln = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local lW_1 = 25
repeat
    local lY_2 = (lW_1 * 7 + 1) % 9 + 1
    if lY_2 <= 5 then
        if lY_2 <= 3 then
            if lY_2 <= 2 then
                if lY_2 <= 1 then
                    local l7_1 = {
                        "gvrd",
                        "rar",
                        "nncakou",
                        "buydjrwazytn",
                        "xgc",
                        "ist",
                        "oyhmxzpdtv",
                        "zkeaeyergaz",
                        "ddgcpkq",
                        "dfjpceycdlej",
                        "wlhduaqjwyy",
                        "ofgsjifdi",
                        "sffrjarmebjf",
                        "mmfiebpir",
                        "jgssbbrsyv"
                    }
                    if l7_1[(lW_1 * 59 + 93) % 15 + 1] <= l7_1[(lW_1 * 59 + 93) % 15 + 1] then
                        k8 = "#e8a34d"
                    else
                        lX = "#e8a34d"
                    end
                    lW_1 = (lW_1 + 13) % 72
                else
                    if not l2 and ln and (not l__1 or not l1) or (l1 and lK or l1 and not l1) or (not l1 or lK or (not l2 or not l1)) and (lK and l1 or (not l2 or lK)) or not (not l2 and ln and (not l__1 or not l1) or (l1 and lK or l1 and not l1) or (not l1 or lK or (not l2 or not l1)) and (lK and l1 or (not l2 or lK))) then
                        l0 = "#8b93a3"
                    else
                        lX = "#8b93a3"
                    end
                    lW_1 = (lW_1 + 58) % 72
                end
            else
                local l7_2 = (vector.create((lW_1 * 6 + 8) % 11 + 1, (lW_1 * 11 + 3) % 13 + 1, (lW_1 * 15 + 15) % 17 + 1))
                local l8_1 = (vector.create((lW_1 * 2 + 7) % 11 + 1, (lW_1 * 5 + 8) % 13 + 1, (lW_1 * 1 + 5) % 17 + 1))
                l9 = (vector.create((lW_1 * 2 + 4) % 11 + 1, (lW_1 * 6 + 8) % 13 + 1, (lW_1 * 6 + 6) % 17 + 1))
                ma = (vector.create((lW_1 * 1 + 7) % 11 + 1, (lW_1 * 3 + 9) % 13 + 1, (lW_1 * 4 + 3) % 17 + 1))
                if vector.dot(vector.cross(l7_2, l8_1), (vector.cross(l9, ma))) == vector.dot(l7_2, l9) * vector.dot(l8_1, ma) - vector.dot(l7_2, ma) * vector.dot(l8_1, l9) + 2 then
                    l4 = "Unknown"
                    pcall(fn209)
                    l3_2 = k1.Info:AddLeftGroupbox("Account", "circle-user")
                    l3_2:AddLabel(LocalPlayer("User", ln.Name, lZ), true)
                    l3_2:AddLabel(LocalPlayer("Status", "Keyless", lZ), true)
                    l3_2:AddLabel(LocalPlayer("Executor", "Unknown", lZ), true)
                    k8 = k1.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                    k8:AddLabel(lX(Label .. " [" .. tostring(game.PlaceId) .. "]", ly), true)
                    k8:AddLabel(LocalPlayer("Place ID", tostring(game.PlaceId), ly), true)
                    l2 = k8:AddLabel(LocalPlayer("Session time", "0s", l1), true)
                else
                    k1 = "Unknown"
                    pcall(fn209)
                    lX = lZ.Info:AddLeftGroupbox("Account", "circle-user")
                    lX:AddLabel(ln("User", LocalPlayer.Name, l2), true)
                    lX:AddLabel(ln("Status", "Keyless", l2), true)
                    lX:AddLabel(ln("Executor", k1, l2), true)
                    l3_2 = lZ.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                    l3_2:AddLabel(ly(l4 .. " [" .. tostring(game.PlaceId) .. "]", l1), true)
                    l3_2:AddLabel(ln("Place ID", tostring(game.PlaceId), l1), true)
                    Label = l3_2:AddLabel(ln("Session time", "0s", k8), true)
                end
                lW_1 = (lW_1 + 13) % 72
            end
        elseif lY_2 <= 4 then
            if (not ln and l0 or k1 and l0) and (not k1 and not ly or (lX or not k1)) or not ((not ln and l0 or k1 and l0) and (not k1 and not ly or (lX or not k1))) then
                lK = tostring(game.JobId)
            else
                ln = tostring(game.JobId)
            end
            lW_1 = (lW_1 + 67) % 72
        else
            if (not ln and not l3_2 or (l3_2 or l3_2)) and ((ln or not l3_2) and (ln or not ln)) and ((ly and l3_2 or (ly or ly)) and ((l3_2 or l3_2) and (ly or ln))) or not ((not ln and not l3_2 or (l3_2 or l3_2)) and ((ln or not l3_2) and (ln or not ln)) and ((ly and l3_2 or (ly or ly)) and ((l3_2 or l3_2) and (ly or ln)))) then
                l__1 = #lK > 18
            else
                lK = #l__1 > 18
            end
            lW_1 = (lW_1 + 22) % 72
        end
    elseif lY_2 <= 7 then
        if lY_2 <= 6 then
            local l7_3 = {
                "keurw",
                "jokijhpq",
                "dyyfsg",
                "xppcayz",
                "woyihl",
                "totjubr",
                "vakvw",
                "kyvv",
                "huvxtyslbdqy",
                "kbgxfbatamwz",
                "gbvxvt",
                "crgn",
                "poaeikouj",
                "wdvsvannvno"
            }
            if l7_3[(lW_1 * 70 + 64) % 14 + 1] <= l7_3[(lW_1 * 70 + 64) % 14 + 1] then
                ly = fn761
            else
                l1 = fn761
            end
            lW_1 = (lW_1 + 4) % 72
        else
            if (not Label and l3_2 or (not Label or not Label)) and (l3_2 and l3_2 or l3_2 and Label) and not ((not Label and l3_2 or (not Label or not Label)) and (l3_2 and l3_2 or l3_2 and Label)) then
                l1 = fn206
            else
                ln = fn206
            end
            lW_1 = (lW_1 + 31) % 72
        end
    elseif lY_2 <= 8 then
        local lY_3 = (vector.create((lW_1 * 5 + 6) % 11 + 1, (lW_1 * 7 + 1) % 13 + 1, (lW_1 * 15 + 17) % 17 + 1))
        local l7_4 = (vector.create((lW_1 * 5 + 2) % 11 + 1, (lW_1 * 7 + 13) % 13 + 1, (lW_1 * 7 + 16) % 17 + 1))
        local l8_2 = (vector.create((lW_1 * 3 + 1) % 11 + 1, (lW_1 * 8 + 11) % 13 + 1, (lW_1 * 9 + 8) % 17 + 1))
        l9 = (vector.create((lW_1 * 2 + 2) % 5 + 1, (lW_1 * 2 + 7) % 7 + 1, (lW_1 * 4 + 7) % 9 + 1))
        if vector.dot(vector.cross(lY_3, (vector.cross(l7_4, l8_2))), l9) == vector.dot(l7_4 * vector.dot(lY_3, l8_2) - l8_2 * vector.dot(lY_3, l7_4), l9) + 5 then
            k1 = "#7fd47f"
        else
            l2 = "#7fd47f"
        end
        lW_1 = (lW_1 + 31) % 72
    else
        local lY_4 = (vector.create((lW_1 * 6 + 1) % 11 + 1, (lW_1 * 6 + 4) % 13 + 1, (lW_1 * 3 + 2) % 17 + 1))
        local l7_5 = (vector.create((lW_1 * 4 + 3) % 11 + 1, (lW_1 * 2 + 13) % 13 + 1, (lW_1 * 11 + 3) % 17 + 1))
        local l8_3 = (vector.create((lW_1 * 1 + 6) % 5 + 1, (lW_1 * 2 + 1) % 7 + 1, (lW_1 * 1 + 2) % 9 + 1))
        if math.abs((vector.angle(lY_4, l7_5, l8_3))) - math.abs((vector.angle(l7_5, lY_4, l8_3))) == 2 then
            lX = "#6ec1ff"
        else
            l1 = "#6ec1ff"
        end
        lW_1 = (lW_1 + 4) % 72
    end
until (lW_1 * 59 + 33) % 72 == 5
if l__1 then
    local lW_2 = 2
    repeat
        lX = {
            "bzqllejqxee",
            "xwbd",
            "wyfh",
            "hgp",
            "rixisbtrmr",
            "ckucclu",
            "jehxurgyww",
            "gkpgrofnst",
            "bzhmktmxnzs",
            "gihgajzf",
            "xbva",
            "ovoqjucwjiz",
            "ovht",
            "ngfxvejh",
            "ncshfxwbul",
            "onefkb"
        }
        if lX[(lW_2 * 40 + 59) % 16 + 1] <= lX[(lW_2 * 40 + 59) % 16 + 1] then
            l__1 = string.sub(lK, 1, 18) .. "..."
        else
            lK = string.sub(l__1, 1, 18) .. "..."
        end
        lW_2 = (lW_2 + 1) % 8
    until (lW_2 * 3 + 3) % 8 == 4
end
local lW_3 = l__1 or lK
ml, lv, lY_5, kX, kV, kS, lT, lR, lM, lI, md, k3, lu, CurrentCamera, ll, lj, connection, connection2, l__2, lA, lo, kW, k9, k4, lP, lC, k0 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if not lY_5 or lC or not CurrentCamera and lC or (not lu and lC or lu and not lY_5) or (not lu and lu or lu and CurrentCamera) and (not lu and lu or lC and not CurrentCamera) or not (not lY_5 or lC or not CurrentCamera and lC or (not lu and lC or lu and not lY_5) or (not lu and lu or lu and CurrentCamera) and (not lu and lu or lC and not CurrentCamera)) then
    ml = lW_3
    l3_2:AddLabel(ln("Server", ml, l0), true)
    l3_2:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
    lv = os.clock()
else
    local lW_4 = lv
    ln:AddLabel(l0("Server", lW_4, ml), true)
    ln:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
    os.clock()
end
task.spawn(worker)
local ScriptsGroup = lZ.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(ly("Included in this hub", l0), true)
ScriptsGroup:AddLabel(ly(l4, l1), true)
local FeaturesGroup = lZ.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(ly("Auto Snipe", l1), true)
FeaturesGroup:AddLabel(ly("Auto Drones", l2), true)
FeaturesGroup:AddLabel(ly("Auto Economy", k8), true)
FeaturesGroup:AddLabel(ly("Auto Upgrades", l1), true)
FeaturesGroup:AddLabel(ly("Auto Placement", l2), true)
FeaturesGroup:AddLabel(ly("Player Utilities", l0), true)
local SocialsGroup = lZ.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = lS })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
lX = lZ.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
lX:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
lX:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
lX:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
lX:AddButton({ Text = "Copy Discord Invite", Func = lS })
kX = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
kV = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
kS = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
lT = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
lR = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
lM = ""
lI = ""
local mm = "#345d9d"
local mi = "#f7931a"
local mf = "#627eea"
local me = "#26a17b"
if not SocialsGroup and ll and (kW and ll) or ll and not ll and (not ll and not SocialsGroup) or not (not SocialsGroup and ll and (kW and ll) or ll and not ll and (not ll and not SocialsGroup)) then
    md = "#14f195"
else
    lC = "#14f195"
end
local mc = "#0070ba"
ma = "#008cff"
l9 = lZ.Info:AddRightGroupbox("Donations", "heart")
l9:AddLabel(ly("All donations are optional but appreciated.", k8), true)
l9:AddLabel(ly("If you donate you get a special role, just PING after you donate.", l2), true)
l9:AddDivider()
l9:AddLabel(ly("LTC / Litecoin", mm), true)
l9:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
l9:AddLabel(ly("BTC / Bitcoin", mi), true)
l9:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
l9:AddLabel(ly("ETH / Ethereum", mf), true)
l9:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
l9:AddLabel(ly("USDT", me), true)
l9:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
l9:AddLabel(ly("Solana", md), true)
l9:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
l9:AddLabel(ly("PayPal", mc), true)
l9:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
l9:AddLabel(ly("Venmo", ma), true)
l9:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
l9:AddDivider()
l9:AddLabel(ly("Don't have any of the listed currencies but still wanna donate?", l0), true)
l9:AddLabel(ly("DM me and we'll work something out.", l1), true)
local FaqGroup = lZ.Info:AddRightGroupbox("FAQ", "circle-help")
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
local SniperGroup = lZ.Main:AddLeftGroupbox("Sniper", "crosshair")
SniperGroup:AddToggle("AutoSnipe", { Text = "Auto Snipe", Default = false })
SniperGroup:AddToggle("SkipSniperAnimation", { Text = "Auto Skip Sniper Animation", Default = true })
SniperGroup:AddSlider("SnipeDelay", { Text = "Snipe Delay", Default = 0.3, Min = 0.05, Max = 2, Rounding = 2, Suffix = "s" })
local DronesGroup = lZ.Main:AddLeftGroupbox("Drones", "bot")
DronesGroup:AddToggle("AutoDroneBest", { Text = "Auto Drone Best", Default = false })
DronesGroup:AddToggle("AutoDroneShield", { Text = "Auto Drone Shield", Default = false })
local EconomyGroup = lZ.Main:AddRightGroupbox("Economy", "coins")
EconomyGroup:AddToggle("AutoCollect", { Text = "Auto Collect Money", Default = false })
EconomyGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
local UpgradesGroup = lZ.Main:AddRightGroupbox("Upgrades", "arrow-up")
UpgradesGroup:AddToggle("AutoSniperUpgrade", { Text = "Auto Buy Sniper Upgrades", Default = false })
UpgradesGroup:AddToggle("AutoDroneUpgrade", { Text = "Auto Buy Drone Upgrades", Default = false })
UpgradesGroup:AddToggle("AutoUpgradeBase", { Text = "Auto Upgrade Base", Default = false })
UpgradesGroup:AddToggle("AutoUpgradeBrainrots", { Text = "Auto Upgrade Placed Brainrots", Default = false })
UpgradesGroup:AddDropdown("BrainrotUpgradePriority", { Values = { "Best", "Random" }, Default = "Best", Multi = false, Text = "Upgrade Priority" })
local PlacementGroup = lZ.Main:AddLeftGroupbox("Placement", "layout-grid")
PlacementGroup:AddToggle("AutoPlace", { Text = "Auto Place Brainrots", Default = false })
PlacementGroup:AddDropdown("PlacePriority", {
    Values = { "Highest Gold/s", "Highest Rarity" },
    Default = "Highest Gold/s",
    Multi = false,
    Text = "Placement Priority"
})
PlacementGroup:AddToggle("AutoPlaceReplace", { Text = "Replace Weaker Brainrots", Default = false })
task.spawn(function()
    while not lH.Unloaded do
        local nH = 0.3
        if Toggles.AutoSnipe and Toggles.AutoSnipe.Value and k_ then
            for i, v in ipairs(k7()) do
                local nQ = v
                pcall(function()
                    k_:FireServer(nQ)
                end)
            end
            if Toggles.SkipSniperAnimation and Toggles.SkipSniperAnimation.Value then
                nH = 0.05
            else
                nH = lV.SnipeDelay.Value
            end
        end
        task.wait(nH)
    end
end)
k3 = {}
task.spawn(function()
    while not lH.Unloaded do
        if Toggles.AutoDroneBest and Toggles.AutoDroneBest.Value and lJ and lk and k2 and kT then
            local of_3 = pcall(function()
                local Value
                local nS = lm and lm.IsBagFull(1)
                if nS then
                    return
                end
                local Character = LocalPlayer.Character
                local nT = Character and Character:FindFirstChild("HumanoidRootPart")
                if not nT then
                    return
                end
                local nT_1 = lk.GetDroneNum() or 0
                local nT_2 = k2.GetOwnerDroneNum() or 0
                local nT_3 = tick()
                for k, v in pairs(k3) do
                    if nT_3 - v > 6 then
                        k3[k] = nil
                    end
                end
                local nW = 0
                for k in pairs(k3) do
                    nW = nW + 1
                end
                local nT_4 = nT_1 - nT_2 - nW
                if nT_4 <= 0 then
                    return
                end
                Value = lV.PlacePriority.Value
                local nU_1 = {}
                for i, v in ipairs(lG()) do
                    local nV_1 = v.uid and not k2.GetDroneHasBrainrotUid(v.uid) and not k3[v.uid]
                    if nV_1 then
                        nU_1[#nU_1 + 1] = v
                    end
                end
                table.sort(nU_1, function(c2, c3)
                    return k5(c2, Value) > k5(c3, Value)
                end)
                for i, v in ipairs(nU_1) do
                    if nT_4 <= 0 then
                        break
                    end
                    k3[v.uid] = tick()
                    local result = lJ.DroneRequest:InvokeServer({ brainrotUid = v.uid, startPos = nT.CFrame, endPos = v.pos, startTick = kT:GetTime() })
                    if not (result and result.success) then
                        k3[v.uid] = nil
                    end
                    nT_4 = nT_4 - 1
                end
            end)
            if not of_3 then
                task.wait(0.5)
            end
        end
        task.wait(0.4)
    end
end)
task.spawn(autoDroneShieldLoop)
task.spawn(autoCollectLoop)
task.spawn(autoSniperUpgradeLoop)
task.spawn(autoDroneUpgradeLoop)
task.spawn(autoRebirthLoop)
task.spawn(function()
    while not lH.Unloaded do
        if Toggles.AutoPlace and Toggles.AutoPlace.Value and lU and lm and lB and la then
            pcall(function()
                local Value
                local o8_1
                local o7_1
                Value = lV.PlacePriority.Value
                local o2 = lB:GetUnlockSlot()
                local o3 = la.GetMaxUnlockedSlot(o2) or 0
                if o3 <= 0 then
                    return
                end
                local o3_1 = lm.GetEquipList()
                local o4 = {}
                local o5 = {}
                for i, v in ipairs(o3_1) do
                    o5[v.slot] = v.uid
                    o4[v.uid] = true
                end
                local o3_2 = {}
                for i, v in ipairs(lm.GetBrainrotList()) do
                    if not o4[v.uid] then
                        o3_2[#o3_2 + 1] = v
                    end
                end
                if #o3_2 == 0 then
                    return
                end
                table.sort(o3_2, function(et, eu)
                    return k5(et, Value) > k5(eu, Value)
                end)
                local o4_1 = 1
                local pq = 1
                while pq <= o3 do
                    local pr = pq
                    local o6_1 = not o5[pr]
                    if o6_1 ~= false then
                        o6_1 = lm.IsSlotUnlocked(pr)
                    end
                    if o6_1 then
                        local o6_2 = o3_2[o4_1]
                        if not o6_2 then
                            break
                        end
                        lU.PlaceBrainrot:FireServer(pr, o6_2.uid)
                        o5[pr] = o6_2.uid
                        o4_1 = o4_1 + 1
                        pq += 1
                        continue
                    end
                    pq += 1
                end
                if Toggles.AutoPlaceReplace and Toggles.AutoPlaceReplace.Value then
                    local o6_4 = #o3_2
                    local pv = o4_1
                    while pv <= o6_4 do
                        local o4_2 = o3_2[pv]
                        local o6_5 = k5(o4_2, Value)
                        o8_1, o7_1 = nil, nil
                        local pA = 1
                        while pA <= o3 do
                            local pB = pA
                            local o9_1 = o5[pB]
                            if o9_1 then
                                local pa = lm.GetBrainrotByUid(o9_1)
                                if pa then
                                    local o9_2 = k5(pa, Value)
                                    if not o7_1 or o9_2 < o7_1 then
                                        o7_1 = o9_2
                                        o8_1 = pB
                                    end
                                end
                            end
                            pA += 1
                        end
                        if o8_1 and o7_1 and o6_5 > o7_1 then
                            lU.ReplaceBrainrot:FireServer(o8_1, o4_2.uid)
                            o5[o8_1] = o4_2.uid
                        end
                        pv += 1
                    end
                end
            end)
        end
        task.wait(1)
    end
end)
lu = 0
task.spawn(autoUpgradeBaseLoop)
task.spawn(autoUpgradeBrainrotsLoop)
local MovementGroup = lZ.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = lZ.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
lA = fn329
lo = fn257
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn505)
Toggles.WalkSpeedEnabled:OnChanged(fn938)
kW = function(ga)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not ga)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not ga
        end
    end)
    if not ga then
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
Toggles.AntiGameplayPause:OnChanged(fn499)
task.spawn(antiGameplayPauseLoop)
local MenuGroup = lZ.Settings:AddLeftGroupbox("Menu", "menu")
if (lC or not l__2 or not FlyGroup and l__2) and (PlacementGroup and FlyGroup or not lC and not PlacementGroup) or not ((lC or not l__2 or not FlyGroup and l__2) and (PlacementGroup and FlyGroup or not lC and not PlacementGroup)) then
    lZ.Settings:AddLeftGroupbox("Menu Keybind"):AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    lH.ToggleKeybind = lV.MenuKeybind
    ll = tick()
    lj = tick()
else
    lj.Settings:AddLeftGroupbox("Menu Keybind"):AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", Text = "Menu keybind", NoUI = true })
    lZ.ToggleKeybind = ll.MenuKeybind
    lH = tick()
    lV = tick()
end
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local qK = v
        pcall(function()
            qK:Disable()
        end)
    end
end)
k9 = fn108
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
task.spawn(antiAfkLoop)
lH:OnUnload(fn216)
ThemeManager:SetLibrary(lH)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Linoria")
ThemeManager:ApplyToTab(lZ.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(lH)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/BrainrotSniper")
local l__3 = SaveManager:BuildConfigSection(lZ.Settings)
k4 = fn705
lP = fn522
lC = fn311
k0 = function(hh)
    local ru
    ru = nil
    local rv = type(hh) ~= "table" or type(hh.idx) ~= "string" or type(hh.type) ~= "string" or SaveManager.Ignore[hh.idx]
    if rv then
        return false
    end
    ru = k4(hh.type, hh.idx)
    if not ru then
        return false
    end
    local rv_1 = pcall(function()
        if hh.type == "Input" then
            if type(hh.text) ~= "string" then
                return
            end
            ru:SetValue(hh.text)
        elseif hh.type == "ColorPicker" then
            ru:SetValueRGB(Color3.fromHex(hh.value), hh.transparency)
        elseif hh.type == "KeyPicker" then
            ru:SetValue({ hh.key, hh.mode, hh.modifiers })
            if hh.mode == "Toggle" and hh.toggled ~= nil then
                ru.Toggled = hh.toggled
                ru:Update()
            end
        else
            ru:SetValue(hh.value)
        end
    end)
    return rv_1
end
if ((not k9 or lj or lj and not k4) and (not lj and not k4 and (lj and k4)) or (k9 and ScriptsGroup and (not k4 and k9) or not lo and not ScriptsGroup and (k9 and not k9))) and (((not lo or lo) and (k9 and not lo) or (not lo and not lj or (not k4 or not lo))) and (not k4 and lj or (not ScriptsGroup or ScriptsGroup) or (ScriptsGroup or lj or (lo or not k4)))) and not (((not k9 or lj or lj and not k4) and (not lj and not k4 and (lj and k4)) or (k9 and ScriptsGroup and (not k4 and k9) or not lo and not ScriptsGroup and (k9 and not k9))) and (((not lo or lo) and (k9 and not lo) or (not lo and not lj or (not k4 or not lo))) and (not k4 and lj or (not ScriptsGroup or ScriptsGroup) or (ScriptsGroup or lj or (lo or not k4))))) then
    l4:AddDivider()
    l4:AddInput("SaveManager_ImportSource", { AllowEmpty = true, Text = "Paste exported config here", Finished = true })
    l4:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    l4:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
    lH:LoadAutoloadConfig()
    l__3:Notify("Tempo Hub loaded for " .. SaveManager)
else
    l__3:AddDivider()
    l__3:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    l__3:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    l__3:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
    SaveManager:LoadAutoloadConfig()
    lH:Notify("Tempo Hub loaded for " .. l4)
end
end)(...)

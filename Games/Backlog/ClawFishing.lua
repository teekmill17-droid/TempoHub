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
getgenv().TempoHoodSubtitle = "CLAW FISHING"
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
local Options
local RarityInfo
local i4
local iq
local Label3
local Label5
local LocalPlayer
local ja
local Toggles
local iS
local PlayerData
local Aquariums
local iV
local iz
local ie
local iY
local MutationInfo
local i0
local FishState
local iI
local i3
local ip
local iL
local i6
local i9
local Library
local jc
local EquipBest
local Label2
local ic
local VirtualUser
local ItemInfo
local ih
local Cashout
local iE
local ik
local Label
local i2
local i5
local iK
local connection
local FishInfo
local h5
local iu
local jb
local ix
local Label4
local je
local iQ
local iW
local ib
local iD
local iZ
local iG
local i1
local function fn17(ag)
    local j3 = Toggles[ag]
    return j3 ~= nil and j3.Value == true
end
local function fn20(aw)
    for k, v in pairs(aw) do
        if v then
            return true
        end
    end
    return false
end
local function fn27()
    local kX_1
    local kW_1
    local kS = iW("FishRarities")
    local kT = not iL("CatchAnyFish") and iz(kS)
    local kT_1 = iL("MutatedOnly")
    local kV = os.clock()
    kX_1, kW_1 = nil, nil
    for k, v in pairs(FishState.activeFish) do
        local kZ = je[k] ~= nil and je[k] > kV
        if not kZ then
            local kY_1 = FishInfo.IdToName[v.speciesId]
            local k_ = kY_1 and FishInfo.Fish[kY_1]
            local k0 = v.mutations or {}
            if not k_ then
                kZ = true
            else
                if kT_1 and not k0.mutation then
                    kZ = true
                else
                    if kT and not kS[RarityInfo.rarityNames[k_.tier]] then
                        kZ = true
                    end
                end
            end
        end
        if not kZ then
            local kY_3 = i3(v)
            if not kW_1 or kY_3 > kW_1 then
                kW_1 = kY_3
                kX_1 = k
            end
        end
    end
    return kX_1
end
local function fn36()
    local kk = h5()
    return kk and kk.Values and kk.Values.Money or 0
end
local function fn56()
    iu:Disconnect()
    connection:Disconnect()
    select("#", "Claw Fishing unloaded")
end
local function worker()
    while not Library.Unloaded do
        task.wait(2)
        if iL("AntiAfk") then
            local mE = tick() - ih
            local mF = tick() - ic
            if mE >= 300 and mF >= 60 then
                pcall(iQ)
            else
                if mE < 300 and mF >= 300 then
                    pcall(iQ)
                end
            end
        end
    end
end
local function fn65(a9)
    local kD = a9.arrivalTime - a9.departTime
    if kD <= 0 then
        return a9.destination
    end
    local kE = math.clamp((workspace:GetServerTimeNow() - a9.departTime) / kD, 0, 1)
    return a9.origin:Lerp(a9.destination, kE)
end
local function onInputBegan()
    ih = tick()
end
local function fn202(bd)
    local kK = bd.stats and bd.stats.income or 0
    local kL = bd.mutations or {}
    local kK_2 = 1
    if kL.mutation and MutationInfo.List[kL.mutation] then
        kK_2 = MutationInfo.List[kL.mutation].Price
    end
    return kK * kK_2 * (kL.size or 1)
end
local function fn233()
    Library.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
local function fn245(c1, c2, c3, c4)
    local l1 = iZ(c3)
    local l2 = i6()
    for k, v in c1 do
        local l3 = c2[v].Price or 0
        local l3_1 = not l1[v]
        if l3_1 ~= false then
            l3_1 = l3 > 0
        end
        if l3_1 then
            l3_1 = l2 - l3 >= c4
        end
        if l3_1 then
            return v
        end
    end
    return nil
end
local function fn258(N, O)
    if setclipboard then
        setclipboard(N)
    elseif toclipboard then
        toclipboard(N)
    end
    Library:Notify(O)
end
local function fn259(dm)
    local DiscordGroup = dm:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = i0 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = i0 })
end
local function worker2()
    local mJ_1
    while not Library.Unloaded do
        task.wait(1)
        local mI = math.floor(os.clock() - ja)
        if mI < 60 then
            mJ_1 = mI .. "s"
        elseif mI < 3600 then
            mJ_1 = string.format("%dm %ds", math.floor((mI) / (60)), mI % 60)
        else
            mJ_1 = string.format("%dh %dm", math.floor((mI) / (3600)), math.floor((mI % 3600) / (60)))
        end
        Label:SetText(ix("Session time", mJ_1, iY))
        Label3:SetText(ix("Money", string.format("%d", math.floor(i6())), jc))
        Label2:SetText(ix("Caught", tostring(i9), jc))
        iq:SetText(ix("Last catch", i1, iY))
        ik:SetText(ix("Status", iV, iS))
        local mI_1 = h5()
        local mI_2 = mI_1 and mI_1.Aquarium and mI_1.Aquarium.Upgrade or 0
        Label4:SetText(ix("Aquarium level", tostring(mI_2), i5))
        local mI_3 = iG()
        local mJ_4 = mI_3 and string.format("%d", mI_3)
        local mI_4 = mJ_4 or "maxed"
        Label5:SetText(ix("Next upgrade", mI_4, iY))
    end
end
local function fn297()
    return PlayerData.Data
end
local function worker4()
    while not Library.Unloaded do
        if iL("AutoBestFish") then
            pcall(function()
                EquipBest:FireServer()
            end)
        end
        task.wait(ip("BestFishDelay", 3))
    end
end
local function fn334(cW)
    local lV = h5()
    local lW = lV and lV.Boat
    if not lW then
        return {}
    elseif cW == "Claw" then
        return lW.OwnedClaws or {}
    elseif cW == "Crane" then
        return lW.OwnedCranes or {}
    else
        local lW_3 = {}
        local lX_3 = lW.OwnedHulls
        local l0 = if lX_3 then 1 else 0
        local lZ = 1118 * l0 + 983 * (1 - l0)
        local l_ = 3685 * l0 + 3641 * (1 - l0)
        if not ((lZ * 30 + l_ * 1632 + lZ * l_) % 16777213 == 10167290) then
            lX_3 = lW_3
        end
        return lX_3
    end
end
local function fn348(al, am)
    local j6 = Options[al]
    local j7 = j6 and tonumber(j6.Value)
    return j7 or am
end
local function onCopyJoinScript_JobID()
    local dE = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, iD)
    ie(dE, "Copied join script to clipboard")
end
local function fn398(de, df)
    local mc = iZ(df)
    for k, v in de do
        if mc[v] then
            return v
        end
    end
    return nil
end
local function fn400(X, Y, Z)
    return string.format("<b>%s</b> %s %s", X, iK("-", "#5a6070"), iK(Y, Z))
end
local function onUnload()
    Library:Unload()
end
local function fn417(U, V)
    return string.format('<font color="%s">%s</font>', V, U)
end
local function fn420()
    local lS = h5()
    local lT = lS and lS.Aquarium and lS.Aquarium.Upgrade
    local lS_1 = lT
    if lT then
        lT = ItemInfo.Aquariums[tostring(lS_1)]
    end
    local lS_2 = lT
    if lT then
        lT = lS_2.Cost
    end
    return lT or nil
end
local function fn423()
    local lJ = iE()
    local lK = lJ and lJ:FindFirstChild("AquariumUpgradeSign")
    if not lK then
        return nil
    end
    for i, descendant in lK:GetDescendants() do
        if descendant:IsA("ProximityPrompt") then
            return descendant
        end
    end
    return nil
end
local function fn472()
    ie(jb, "Copied Discord invite to clipboard")
end
local function fn478()
    local kt = iI()
    local kv = kt and kt:FindFirstChild("Claw")
    local kt_1 = kv
    if kv then
        kv = kt_1:FindFirstChild("Base")
    end
    return kv
end
local function worker3()
    while not Library.Unloaded do
        if iL("AutoClawFish") then
            pcall(i4)
            task.wait(ip("FishDelay", 0))
        else
            task.wait(0.5)
        end
    end
end
local function fn514()
    local SessionData = PlayerData.SessionData
    local kr = SessionData and SessionData.Boat
    local kq_1 = kr
    if kr then
        kr = kq_1.Parent
    end
    if kr then
        return kq_1
    end
    return nil
end
local function worker5()
    while not Library.Unloaded do
        if iL("AutoCollectMoney") then
            pcall(function()
                Cashout:FireServer()
            end)
        end
        task.wait(ip("CollectDelay", 3))
    end
end
local function fn543()
    local ml_1
    local mk_1
    if identifyexecutor then
        ml_1, mk_1 = identifyexecutor()
        local mm = ml_1 ~= ""
        local mn = type(ml_1) == "string" and mm
        if mn then
            local mm_1 = type(mk_1) == "string" and mk_1 ~= "" and ml_1 .. " " .. mk_1
            ib = mm_1 or ml_1
        end
    end
end
local function onRscripts()
    ie(i2, "Copied Rscripts profile to clipboard")
end
local function onInputChanged(ee)
    local UserInputType = ee.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        ih = tick()
    end
end
local function fn608()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    ic = tick()
end
local function fn611(ar)
    local j9 = Options[ar]
    return j9 and j9.Value or {}
end
local function fn616()
    for i, child in Aquariums:GetChildren() do
        if child:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return child
        end
    end
    return nil
end
h5 = nil
Aquariums = nil
ib = nil
ic = nil
ie = nil
ih = nil
FishState = nil
ik = nil
Options = nil
ip = nil
iq = nil
Toggles = nil
iu = nil
PlayerData = nil
ix = nil
Label2 = nil
iz = nil
ItemInfo = nil
iD = nil
iE = nil
MutationInfo = nil
iG = nil
Label = nil
iI = nil
RarityInfo = nil
iK = nil
iL = nil
Label5 = nil
FishInfo = nil
LocalPlayer = nil
iQ = nil
Library = nil
iS = nil
Label4 = nil
EquipBest = nil
local h4, Buy, h7, h8, h9, ig, ij, Giveup, io, ConfirmCatch, is, iv, CatchFish, iC, iO
iV = nil
iW = nil
VirtualUser = nil
iY = nil
iZ = nil
Cashout = nil
i0 = nil
i1 = nil
i2 = nil
i3 = nil
i4 = nil
i5 = nil
i6 = nil
Label3 = nil
connection = nil
i9 = nil
ja = nil
jb = nil
jc = nil
je = nil
local Equip, jw, FaqGroup, AutoBuyClawGroup, AutoUpgradeAquariumGroup
local jq_1
local jm_1
local jj_1, GameInfoGroup
local Events
VirtualUser, LocalPlayer = nil, nil
local Players = game:GetService("Players")
local jh = game:GetService("ReplicatedStorage")
local jh_2
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
LocalPlayer = Players.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
Events, jj_1, CatchFish, ConfirmCatch, Giveup, Buy, Equip, jm_1, Cashout, EquipBest, FishInfo, RarityInfo, MutationInfo, ItemInfo, PlayerData, FishState, Aquariums, jb, i2, Library, jq_1, Toggles, Options, jc, i5, iY, iS, ie, i0, iK, ix, iL, ip, iW, iz, h5, i6, iI, h9 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if not jj_1 and not jj_1 and (not jj_1 or ix) and (jm_1 or jm_1 or jq_1 and not jq_1) and (jm_1 or jj_1 or jj_1 and jj_1 or (not jm_1 and jm_1 or (not jq_1 or not ix))) and not (not jj_1 and not jj_1 and (not jj_1 or ix) and (jm_1 or jm_1 or jq_1 and not jq_1) and (jm_1 or jj_1 or jj_1 and jj_1 or (not jm_1 and jm_1 or (not jq_1 or not ix)))) then
    jh = Events:WaitForChild("Events")
else
    Events = jh:WaitForChild("Events")
end
local Modules = jh:WaitForChild("Modules")
CatchFish = Events:WaitForChild("CatchFish")
ConfirmCatch = Events:WaitForChild("ConfirmCatch")
Giveup = Events:WaitForChild("Giveup")
local NPC = Events:WaitForChild("NPC")
Buy = NPC:WaitForChild("Buy")
Equip = NPC:WaitForChild("Equip")
local Aquarium = Events:WaitForChild("Aquarium")
Cashout = Aquarium:WaitForChild("Cashout")
EquipBest = Aquarium:WaitForChild("EquipBest")
FishInfo = require(Modules:WaitForChild("FishInfo"))
RarityInfo = require(Modules:WaitForChild("RarityInfo"))
MutationInfo = require(Modules:WaitForChild("MutationInfo"))
ItemInfo = require(Modules:WaitForChild("ItemInfo"))
PlayerData = require(LocalPlayer:WaitForChild("PlayerData"))
local ClientScript = LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("ClientScript")
local AccountGroup
FishState = require(ClientScript:WaitForChild("Modules"):WaitForChild("FishState"))
Aquariums = workspace:WaitForChild("NoTouchy"):WaitForChild("Aquariums")
local jo = "Claw Fishing"
jb = "https://discord.gg/K7Qxnxkk46"
i2 = "https://discord.gg/K7Qxnxkk46"
Library = getgenv().Library
pcall(fn233)
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
ie = fn258
i0 = fn472
iK = fn417
ix = fn400
jc = "#7fd47f"
i5 = "#6ec1ff"
iY = "#e8a34d"
iS = "#8b93a3"
iL = fn17
ip = fn348
iW = fn611
iz = fn20
h5 = fn297
i6 = fn36
iI = fn514
h9 = fn478
local jr = {}
local js = {}
for k, v in pairs(FishInfo.Fish) do
    local jf_2 = RarityInfo.rarityNames[v.tier]
    if jf_2 and not js[jf_2] then
        js[jf_2] = true
        table.insert(jr, jf_2)
    end
end
table.sort(jr)
local jf_3 = {}
for k in pairs(MutationInfo.List) do
    table.insert(jf_3, k)
end
io, ig, h7, je, i9, i1, iV, ij, i3, iO, iC, i4, iE, h8, iG, iZ, iv, is = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
table.sort(jf_3)
local function jj_3(a_)
    local kx = {}
    for k in pairs(a_) do
        table.insert(kx, k)
    end
    table.sort(kx, function(a2, a3)
        return a_[a2].Price > a_[a3].Price
    end)
    return kx
end
local jn = jj_3(ItemInfo.Claws)
local jm_3 = jj_3(ItemInfo.Boats)
local jl = jj_3(ItemInfo.Cranes)
ij = fn65
i3 = fn202
io = 1.35
ig = 0.3
h7 = 0
je = {}
i9 = 0
i1 = "none"
iV = "idle"
iO = fn27
iC = function(bP)
    local lf_1
    local le_1
    local ld_1
    local lb = ip("MaxFightTime", 30)
    local lc = os.clock()
    while os.clock() - lc < lb do
        ld_1, le_1, lf_1 = pcall(function()
            return ConfirmCatch:InvokeServer(bP)
        end)
        if ld_1 and le_1 then
            i9 += 1
            local ld_2 = typeof(lf_1) == "table" and lf_1.species
            if ld_2 then
                i1 = lf_1.species
            end
            iV = "caught"
            return true
        end
        if Library.Unloaded then
            return false
        end
        task.wait(ig)
    end
    pcall(function()
        Giveup:FireServer()
    end)
    je[bP] = os.clock() + 120
    iV = "fight timed out"
    return false
end
i4 = function()
    local li
    local ll_4
    local lj = h9()
    local lj_1
    if not lj then
        local lk_1 = iI() and "no claw on boat"
        iV = lk_1 or "no boat found"
        return
    end
    if next(FishState.activeFish) == nil then
        iV = "no fish data"
        return
    end
    li = iO()
    if not li then
        iV = "no fish matches filter"
        return
    end
    if not FishState.activeFish[li] then
        return
    end
    local AlignPosition = lj:FindFirstChildOfClass("AlignPosition")
    local ll_2 = AlignPosition and AlignPosition.Enabled
    if AlignPosition then
        AlignPosition.Enabled = false
    end
    local ll_3 = math.max(ip("ApproachTime", 0.4), io - (os.clock() - h7))
    local ln = os.clock()
    local ln_1
    while os.clock() - ln < ll_3 do
        local lo = FishState.activeFish[li]
        if not lo then
            break
        end
        lj.CFrame = CFrame.new(ij(lo))
        lj.AssemblyLinearVelocity = Vector3.zero
        task.wait()
    end
    ll_4, ln_1, lj_1 = pcall(function()
        return CatchFish:InvokeServer(li)
    end)
    h7 = os.clock()
    if not ll_4 then
        iV = "catch error: " .. tostring(ln_1)
    elseif ln_1 then
        iV = "hooked " .. tostring(lj_1)
    else
        iV = "rejected: " .. tostring(lj_1)
    end
    if AlignPosition then
        AlignPosition.Enabled = ll_2
    end
    je[li] = os.clock() + 10
    local lj_2 = os.clock()
    for k, v in pairs(je) do
        if v <= lj_2 then
            je[k] = nil
        end
    end
    if ll_4 and ln_1 then
        iC(li)
    end
end
iE = fn616
h8 = fn423
iG = fn420
iZ = fn334
iv = fn245
is = fn398
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = "https://discord.gg/K7Qxnxkk46 | Claw Fishing",
    Icon = 18657887261,
    NotifySide = "Right",
    ShowCustomCursor = false
})
local js_1 = {
    Info = Window:AddTab("Info", "info"),
    Fishing = Window:AddTab("Fishing", "anchor"),
    Aquarium = Window:AddTab("Aquarium", "fish"),
    Shop = Window:AddTab("Shop", "shopping-bag"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in js_1 do
    fn259(v)
end
ib, AccountGroup, GameInfoGroup, Label, iD, jh_2 = nil, nil, nil, nil, nil, nil
local jf_4 = 6
repeat
    local jk_3 = (jf_4 * 1 + 0) % 3 + 1
    if jk_3 <= 2 then
        if jk_3 <= 1 then
            local jk_4 = {
                "usifcxrfef",
                "vnsvqa",
                "vhiruxnbtw",
                "nlzljgbylnk",
                "tacppcl",
                "ifwdgqaf",
                "cen",
                "dwlyryeoazx",
                "ddkoq",
                "qrpk",
                "bpkxcnapdg"
            }
            local nK = jf_4
            local jt_1 = jk_4[nK % 11 + 1]
            if jt_1:len() >= jt_1:reverse():rep(nK % 3 + 2):len() then
                jc = "Unknown"
                pcall(fn543)
                iK = GameInfoGroup.Info:AddLeftGroupbox("Account", "circle-user")
                iK:AddLabel(ib("User", js_1.Name, AccountGroup), true)
                iK:AddLabel(ib("Status", "Keyless", AccountGroup), true)
                iK:AddLabel(ib("Executor", jc, AccountGroup), true)
                ix = GameInfoGroup.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                ix:AddLabel(iY(LocalPlayer .. " [" .. tostring(game.PlaceId) .. "]", Label), true)
                ix:AddLabel(ib("Place ID", tostring(game.PlaceId), Label), true)
                jo = ix:AddLabel(ib("Session time", "0s", i5), true)
            else
                ib = "Unknown"
                pcall(fn543)
                AccountGroup = js_1.Info:AddLeftGroupbox("Account", "circle-user")
                AccountGroup:AddLabel(ix("User", LocalPlayer.Name, jc), true)
                AccountGroup:AddLabel(ix("Status", "Keyless", jc), true)
                AccountGroup:AddLabel(ix("Executor", ib, jc), true)
                GameInfoGroup = js_1.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                GameInfoGroup:AddLabel(iK(jo .. " [" .. tostring(game.PlaceId) .. "]", i5), true)
                GameInfoGroup:AddLabel(ix("Place ID", tostring(game.PlaceId), i5), true)
                Label = GameInfoGroup:AddLabel(ix("Session time", "0s", iY), true)
            end
            jf_4 = (jf_4 + 4) % 12
        else
            local jk_5 = (vector.create((jf_4 * 5 + 2) % 11 + 1, (jf_4 * 6 + 8) % 13 + 1, (jf_4 * 4 + 8) % 17 + 1))
            local jt_2 = (vector.create((jf_4 * 3 + 4) % 11 + 1, (jf_4 * 6 + 5) % 13 + 1, (jf_4 * 5 + 4) % 17 + 1))
            local ju_1 = (vector.create((jf_4 * 2 + 3) % 11 + 1, (jf_4 * 11 + 8) % 13 + 1, (jf_4 * 14 + 17) % 17 + 1))
            local jv_1 = (vector.create((jf_4 * 3 + 6) % 11 + 1, (jf_4 * 9 + 2) % 13 + 1, (jf_4 * 9 + 5) % 17 + 1))
            if vector.dot(vector.cross(jk_5, jt_2), (vector.cross(ju_1, jv_1))) == vector.dot(jk_5, ju_1) * vector.dot(jt_2, jv_1) - vector.dot(jk_5, jv_1) * vector.dot(jt_2, ju_1) then
                iD = tostring(game.JobId)
            else
                ib = tostring(game.JobId)
            end
            jf_4 = (jf_4 + 1) % 12
        end
    else
        local jk_6 = {
            "lqjs",
            "lqctg",
            "cmmrzavgcu",
            "adq",
            "ujjnqna",
            "mtgig",
            "pqdnnyqjajg",
            "rcvwweu",
            "aqnq",
            "faxtczxn"
        }
        if jk_6[(jf_4 * 38 + 37) % 10 + 1] <= jk_6[(jf_4 * 38 + 37) % 10 + 1] then
            jh_2 = #iD > 18
        else
            iD = #jh_2 > 18
        end
        jf_4 = (jf_4 + 4) % 12
    end
until (jf_4 * 7 + 5) % 12 == 2
if jh_2 then
    local jf_5 = 3
    repeat
        if (jf_5 * 2 + 4) * 16 % 3 == ((jf_5 * 2 + 4) * 16 + 5) % 3 then
            iD = string.sub(jh_2, 1, 18) .. "..."
        else
            jh_2 = string.sub(iD, 1, 18) .. "..."
        end
        jf_5 = (jf_5 + 0) % 4
    until (jf_5 * 3 + 2) % 4 == 3
end
local jf_6 = jh_2 or iD
FaqGroup, Label2, iq, ik, Label3, AutoUpgradeAquariumGroup, Label4, Label5, AutoBuyClawGroup, ih, ic, iu, connection, ja, h4, iQ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
GameInfoGroup:AddLabel(ix("Server", jf_6, iS), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
local TempoHubGroup = js_1.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = i0 })
local ScriptsGroup = js_1.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(iK("Included in this hub", iS), true)
ScriptsGroup:AddLabel(iK(jo, i5), true)
local FeaturesGroup = js_1.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(iK("Auto Claw Fishing", i5), true)
FeaturesGroup:AddLabel(iK("Aquarium Automation", jc), true)
FeaturesGroup:AddLabel(iK("Auto Buy Gear", iY), true)
FeaturesGroup:AddLabel(iK("Misc Utilities", iS), true)
local SocialsGroup = js_1.Info:AddRightGroupbox("Socials", "link")
if ((AutoBuyClawGroup or AutoUpgradeAquariumGroup) and (iu and iQ) and (not AutoBuyClawGroup and not iQ and (AutoUpgradeAquariumGroup or not AutoUpgradeAquariumGroup)) or (not AutoBuyClawGroup and iQ and (not iu or AutoBuyClawGroup) or (not AutoUpgradeAquariumGroup or not AutoBuyClawGroup) and (iQ and iu))) and (not AutoUpgradeAquariumGroup and not AutoUpgradeAquariumGroup and (not iu and not iu) and (iu and not AutoBuyClawGroup or (iu or not AutoUpgradeAquariumGroup)) or (not AutoBuyClawGroup or iQ or iu and AutoUpgradeAquariumGroup or (not AutoUpgradeAquariumGroup and iu or not AutoBuyClawGroup and not AutoBuyClawGroup))) or not (((AutoBuyClawGroup or AutoUpgradeAquariumGroup) and (iu and iQ) and (not AutoBuyClawGroup and not iQ and (AutoUpgradeAquariumGroup or not AutoUpgradeAquariumGroup)) or (not AutoBuyClawGroup and iQ and (not iu or AutoBuyClawGroup) or (not AutoUpgradeAquariumGroup or not AutoBuyClawGroup) and (iQ and iu))) and (not AutoUpgradeAquariumGroup and not AutoUpgradeAquariumGroup and (not iu and not iu) and (iu and not AutoBuyClawGroup or (iu or not AutoUpgradeAquariumGroup)) or (not AutoBuyClawGroup or iQ or iu and AutoUpgradeAquariumGroup or (not AutoUpgradeAquariumGroup and iu or not AutoBuyClawGroup and not AutoBuyClawGroup)))) then
    SocialsGroup:AddButton({ Text = "Discord", Func = i0 })
    SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
    FaqGroup = js_1.Info:AddRightGroupbox("FAQ", "circle-help")
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
    jw = js_1.Fishing:AddLeftGroupbox("Auto Claw Fish", "anchor")
    jw:AddToggle("AutoClawFish", { Text = "Auto Claw Fish", Default = false })
    jw:AddSlider("ApproachTime", { Text = "Approach Time", Default = 0.4, Min = 0.2, Max = 3, Rounding = 1 })
    jw:AddSlider("MaxFightTime", { Text = "Max Fight Time", Default = 30, Min = 5, Max = 180, Rounding = 0 })
    jw:AddSlider("FishDelay", { Text = "Extra Loop Delay", Default = 0, Min = 0, Max = 15, Rounding = 1 })
    Label2 = jw:AddLabel(ix("Caught", "0", jc), true)
    iq = jw:AddLabel(ix("Last catch", "none", iY), true)
    ik = jw:AddLabel(ix("Status", "idle", iS), true)
else
    ix:AddButton({ Text = "Discord", Func = js_1 })
    ix:AddButton({ Text = "Rscripts", Func = onRscripts })
    jw = FaqGroup.Info:AddRightGroupbox("FAQ", "circle-help")
    jw:AddLabel("Where do I get a good config?", true)
    jw:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
    jw:AddLabel("How do I import / export configs?", true)
    jw:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
    jw:AddLabel("How do I report bugs?", true)
    jw:AddLabel("Join the Discord and post it in the bugs channel.", true)
    jw:AddLabel("How do I make suggestions?", true)
    jw:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
    jw:AddLabel("How do I get help or updates?", true)
    jw:AddLabel("Join the Discord, updates and support are posted there first.", true)
    ik = FaqGroup.Fishing:AddLeftGroupbox("Auto Claw Fish", "anchor")
    ik:AddToggle("AutoClawFish", { Text = "Auto Claw Fish", Default = false })
    ik:AddSlider("ApproachTime", { Max = 3, Min = 0.2, Text = "Approach Time", Rounding = 1, Default = 0.4 })
    ik:AddSlider("MaxFightTime", { Default = 30, Min = 5, Rounding = 0, Text = "Max Fight Time", Max = 180 })
    ik:AddSlider("FishDelay", { Min = 0, Text = "Extra Loop Delay", Rounding = 1, Default = 0, Max = 15 })
    iq = ik:AddLabel(jc("Caught", "0", iS), true)
    i0 = ik:AddLabel(jc("Last catch", "none", SocialsGroup), true)
    iY = ik:AddLabel(jc("Status", "idle", Label2), true)
end
local FishFilterGroup = js_1.Fishing:AddRightGroupbox("Fish Filter", "filter")
FishFilterGroup:AddToggle("CatchAnyFish", { Text = "Catch Any Fish", Default = true })
FishFilterGroup:AddDropdown("FishRarities", { Text = "Rarities", Values = jr, Default = {}, Multi = true })
FishFilterGroup:AddToggle("MutatedOnly", { Text = "Only Mutated Fish", Default = false })
local AutoBestFishGroup = js_1.Aquarium:AddLeftGroupbox("Auto Best Fish", "fish")
AutoBestFishGroup:AddToggle("AutoBestFish", { Text = "Auto Best Fish On Aquarium", Default = false })
AutoBestFishGroup:AddSlider("BestFishDelay", { Text = "Loop Delay", Default = 3, Min = 1, Max = 60, Rounding = 1 })
local AutoCollectMoneyGroup = js_1.Aquarium:AddLeftGroupbox("Auto Collect Money", "coins")
AutoCollectMoneyGroup:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
AutoCollectMoneyGroup:AddSlider("CollectDelay", { Text = "Loop Delay", Default = 3, Min = 0.5, Max = 60, Rounding = 1 })
Label3 = AutoCollectMoneyGroup:AddLabel(ix("Money", "0", jc), true)
AutoUpgradeAquariumGroup = js_1.Aquarium:AddRightGroupbox("Auto Upgrade Aquarium", "arrow-up-circle")
AutoUpgradeAquariumGroup:AddToggle("AutoUpgradeAquarium", { Text = "Auto Upgrade Aquarium", Default = false })
AutoUpgradeAquariumGroup:AddInput("UpgradeReserve", { Text = "Keep Money Reserve", Default = "0", Numeric = true, Finished = true })
AutoUpgradeAquariumGroup:AddSlider("UpgradeDelay", { Text = "Loop Delay", Default = 5, Min = 1, Max = 120, Rounding = 1 })
Label4 = AutoUpgradeAquariumGroup:AddLabel(ix("Aquarium level", "0", i5), true)
Label5 = AutoUpgradeAquariumGroup:AddLabel(ix("Next upgrade", "maxed", iY), true)
AutoBuyClawGroup = js_1.Shop:AddLeftGroupbox("Auto Buy Claw", "grab")
AutoBuyClawGroup:AddToggle("AutoBuyClaw", { Text = "Auto Buy Best Affordable Claw", Default = false })
AutoBuyClawGroup:AddInput("ClawReserve", { Text = "Keep Money Reserve", Default = "0", Numeric = true, Finished = true })
local AutoBuyBoatGroup = js_1.Shop:AddLeftGroupbox("Auto Buy Boat", "sailboat")
AutoBuyBoatGroup:AddToggle("AutoBuyBoat", { Text = "Auto Buy Best Affordable Boat", Default = false })
AutoBuyBoatGroup:AddInput("BoatReserve", { Text = "Keep Money Reserve", Default = "0", Numeric = true, Finished = true })
local AutoBuyCraneGroup = js_1.Shop:AddRightGroupbox("Auto Buy Crane", "construction")
AutoBuyCraneGroup:AddToggle("AutoBuyCrane", { Text = "Auto Buy Best Affordable Crane", Default = false })
AutoBuyCraneGroup:AddInput("CraneReserve", { Text = "Keep Money Reserve", Default = "0", Numeric = true, Finished = true })
local ShopSettingsGroup = js_1.Shop:AddRightGroupbox("Shop Settings", "settings-2")
ShopSettingsGroup:AddToggle("AutoEquipBestGear", { Text = "Auto Equip Best Owned", Default = true })
ShopSettingsGroup:AddSlider("ShopDelay", { Text = "Loop Delay", Default = 5, Min = 1, Max = 120, Rounding = 1 })
local MenuGroup = js_1.Settings:AddLeftGroupbox("Menu", "wrench")
if ((iQ and FishFilterGroup or (Label3 or not FishFilterGroup)) and (h4 and not Label3) or (Label4 or false or 77) and false) and (not Label4 and not Label4 and (h4 and 77) and ((not Label3 or h4) and (not Label3 and not Label3)) or (iQ and 77 or not Label4 and not h4 or not FishFilterGroup and FishFilterGroup and (not FishFilterGroup or not h4))) and not (((iQ and FishFilterGroup or (Label3 or not FishFilterGroup)) and (h4 and not Label3) or (Label4 or false or 77) and false) and (not Label4 and not Label4 and (h4 and 77) and ((not Label3 or h4) and (not Label3 and not Label3)) or (iQ and 77 or not Label4 and not h4 or not FishFilterGroup and FishFilterGroup and (not FishFilterGroup or not h4)))) then
    connection:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { NoUI = true, Text = "Menu keybind", Default = "RightShift" })
    iQ = tick()
    ih = tick()
    pcall(function()
        for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
            local my = v
            pcall(function()
                my:Disable()
            end)
        end
    end)
    iu = fn608
    ic = MenuGroup.InputBegan:Connect(onInputBegan)
    MenuGroup.InputChanged:Connect(onInputChanged)
else
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    ih = tick()
    ic = tick()
    pcall(function()
        for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
            local my = v
            pcall(function()
                my:Disable()
            end)
        end
    end)
    iQ = fn608
    iu = UserInputService.InputBegan:Connect(onInputBegan)
    connection = UserInputService.InputChanged:Connect(onInputChanged)
end
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
Library.ToggleKeybind = Options.MenuKeybind
Library:OnUnload(fn56)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Mint")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/ClawFishing")
SaveManager:BuildConfigSection(js_1.Settings)
ThemeManager:ApplyToTab(js_1.Settings)
ThemeManager:LoadDefault()
SaveManager:LoadAutoloadConfig()
task.spawn(worker)
ja = os.clock()
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(function()
    local mV = false
    repeat
        if not Library.Unloaded then
            if iL("AutoUpgradeAquarium") then
                local mP = h5()
                local mQ = mP and mP.Aquarium
                local mR = mP
                if mR then
                    mR = mP.Timers
                end
                local mP_1 = mR
                local mO = h8()
                if mO and mQ then
                    if mQ.UpgradeReady then
                        pcall(function()
                            fireproximityprompt(mO)
                        end)
                    else
                        local mQ_2 = mP_1
                        if mQ_2 then
                            mQ_2 = (mP_1.AquariumUpgrade or 0) > 0
                        end
                        if not mQ_2 then
                            local mP_2 = iG()
                            local mQ_3 = ip("UpgradeReserve", 0)
                            local mR_2 = mP_2 and i6() - mP_2 >= mQ_3
                            if mR_2 then
                                pcall(function()
                                    fireproximityprompt(mO)
                                end)
                            end
                        end
                    end
                end
            end
            task.wait(ip("UpgradeDelay", 5))
        else
            mV = true
        end
    until mV
end)
h4 = {
    {
        toggle = "AutoBuyClaw",
        reserve = "ClawReserve",
        kind = "Claw",
        names = jn,
        list = ItemInfo.Claws
    },
    {
        toggle = "AutoBuyBoat",
        reserve = "BoatReserve",
        kind = "Boat",
        names = jm_3,
        list = ItemInfo.Boats
    },
    {
        toggle = "AutoBuyCrane",
        reserve = "CraneReserve",
        kind = "Crane",
        names = jl,
        list = ItemInfo.Cranes
    }
}
task.spawn(function()
    while not Library.Unloaded do
        for k, v in h4 do
            local m7 = v
            if iL(m7.toggle) then
                local mW = iv(m7.names, m7.list, m7.kind, ip(m7.reserve, 0))
                if mW then
                    pcall(function()
                        Buy:FireServer(m7.kind, mW)
                    end)
                    task.wait(1)
                elseif iL("AutoEquipBestGear") then
                    local mX = is(m7.names, m7.kind)
                    local mY = h5()
                    local mZ
                    if mY and mY.Boat then
                        local m0 = m7.kind == "Claw" and mY.Boat.Claw
                        if not m0 then
                            m0 = m7.kind == "Crane" and mY.Boat.Crane
                        end
                        if not m0 then
                            m0 = mY.Boat.Hull
                        end
                        mZ = m0
                    end
                    if mX and mX ~= mZ then
                        pcall(function()
                            Equip:FireServer(m7.kind, mX)
                        end)
                        task.wait(0.5)
                    end
                end
            end
        end
        task.wait(ip("ShopDelay", 5))
    end
end)
Library:Notify("Claw Fishing loaded")
end)(...)

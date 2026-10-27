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
getgenv().TempoHoodSubtitle = "CARVE WOOD!"
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
local zt_2, zt_4, zt_5, GameInfoGroup, FlyGroup, zt_13, zt_15, zt_24, zt_25, zt_27, zt_37, zt_39
local oy
local pf
local oX
local pE
local oE
local CollectionService
local oh
local Label
local oK
local VirtualUser
local op
local o8
local oQ
local UserInputService
local ox
local pe
local oW
local SaveManager
local oD
local Workspace
local og
local o1
local UpgradeNodeTreeRuntimeShared
local pq
local oo
local o7
local oP
local pw
local ow
local pd
local oV
local pC
local oC
local pj
local of
local ButtonActions
local oI
local pp
local om
local o6
local oO
local pv
local ov
local pc
local ItemShelfConfig
local pi
local oe
local o_
local oH
local HttpService
local ol
local o5
local oN
local pu
local ou
local pb
local Label2
local pA
local oA
local ph
local Library
local oZ
local UpgradeNodeTreeShared
local pn
local oj
local o4
local Serializer
local Options
local ot
local pa
local oS
local pz
local oz
local LocalPlayer
local oY
local ReplicatedStorage
local CurrentCamera2
local pm
local oi
local o3
local oL
local ps
local oq
local o9
local oR
local Toggles
function fns.fn16(bg)
    local rB = om()
    local rC = not rB or type(rB.ActiveModules) ~= "table"
    if rC then
        return nil
    end
    return rB.ActiveModules[bg]
end
function fns.fn22()
    local vL = oI("WoodCarving")
    if not vL then
        return
    end
    if not vL.IsLatheActive then
        if Toggles.AutoEnterLathe.Value then
            if type(vL.EnterLathe) == "function" then
                vL:EnterLathe()
            else
                local vM_1 = oq()
                if vM_1 then
                    for i, descendant in vM_1:GetDescendants() do
                        local vM_2 = descendant:IsA("ProximityPrompt") and descendant.Name == "WoodLathePrompt" and descendant.Enabled
                        if vM_2 then
                            pb(descendant)
                            break
                        end
                    end
                end
            end
        end
        return
    end
    local Lathe = vL.Lathe
    if not Lathe or vL.SavePending then
        return
    end
    if not pC(Lathe) then
        return
    end
    if type(vL.CompleteLatheWork) == "function" then
        vL:CompleteLatheWork()
        return
    end
    local vN_1 = Lathe:GetActiveVariantId()
    local vO = Lathe:GetActiveWoodId()
    if not vN_1 or vO == "none" then
        return
    end
    local vP_1 = Serializer.SerializeCarvedLog(Lathe)
    local vQ_1 = Serializer.SerializeCarvedLog(Lathe:GetTargetProfile())
    if not vP_1 or not vQ_1 then
        return
    end
    local vR_1 = Lathe:GetActiveMutation() or "None"
    local vM_4 = vL.LatheSessionId or ""
    local vS_1 = vL.LatheWorkpieceId or ""
    pu("SaveCarvedWood", {
        Serialized = vP_1,
        TargetSerialized = vQ_1,
        WoodId = vO,
        Mutation = vR_1,
        VariantId = vN_1,
        SessionId = vM_4,
        WorkpieceId = vS_1
    })
end
function fns.onRscripts()
    pp(o5, "Copied Rscripts profile to clipboard")
end
function fns.fn41(d9)
    local BasePart = d9:FindFirstChildWhichIsA("BasePart", true)
    if BasePart then
        return BasePart.Position
    end
    local tB = if d9:IsA("Model") then 1 else 0
    if tB == 1 then
        return d9:GetPivot().Position
    end
    return nil
end
function fns.fn67()
    oQ(false)
    local zn = oV()
    if zn then
        zn.PlatformStand = false
        zn.WalkSpeed = 16
    end
end
function fns.fn72()
    return ox() ~= nil
end
function fns.autoAcceptOffersLoop()
    while not Library.Unloaded do
        task.wait(0.3)
        if Toggles.AutoAcceptOffers.Value then
            pcall(ph)
        end
    end
end
function fns.autoBuyShelvesLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AutoBuyShelves.Value then
            pcall(ol)
        end
        if Toggles.AutoBuyPlanters.Value then
            pcall(pf)
        end
    end
end
function fns.onCopyJoinScript_JobID()
    local cs = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, oW)
    pp(cs, "Copied join script to clipboard")
end
function fns.fn122(bK)
    local r2 = oq()
    if not r2 then
        return nil
    end
    for i, descendant in r2:GetDescendants() do
        if descendant:GetAttribute(ButtonActions.ActionAttribute) == bK then
            local attr = descendant:GetAttribute("ButtonEnabled")
            if attr ~= false then
                return descendant
            end
        end
    end
    return nil
end
function fns.fn126(bY)
    local sc = not bY or not bY:IsA("ProximityPrompt") or not bY.Enabled
    if sc then
        return false
    elseif fireproximityprompt then
        pcall(fireproximityprompt, bY)
        return true
    else
        return false
    end
end
function fns.fn146(ab)
    local qR = LocalPlayer.Name .. game.PlaceVersion .. "xdd"
    local function qS(af, ag)
        if ag <= #af then
            return af:sub(1, ag)
        end
        local qJ = ""
        local qK = math.floor(ag / #af)
        local qO = 1
        while qO <= qK do
            qJ ..= af
            qO += 1
        end
        local qK_1 = ag % #af
        if qK_1 > 0 then
            qJ ..= af:sub(1, qK_1)
        end
        return qJ
    end
    local qT = qS(qR, #ab)
    local qR_1 = ""
    qS = #ab
    local qX = 1
    local qV = qS
    while qX <= qV do
        local qY = qX
        qR_1 ..= string.char(bit32.bxor(ab:byte(qY), qT:byte(qY)))
        qX += 1
    end
    return qR_1
end
function fns.fn149()
    if not Toggles.Fly.Value then
        local x7 = oV()
        if x7 then
            x7.PlatformStand = false
        end
    end
end
function fns.fn190()
    if Toggles.AutoBuyRoll.Value then
        local uh_1 = oe()
        if uh_1 == false then
            return
        end
    end
    local uh_2 = oq()
    if not uh_2 then
        return
    end
    if uh_2:GetAttribute("SeedRerollState") ~= "Ready" then
        return
    end
    local ui
    for i, descendant in uh_2:GetDescendants() do
        local uh_3 = descendant:IsA("ProximityPrompt") and descendant.ActionText == "Reroll Seeds" and descendant.Enabled
        if uh_3 then
            ui = descendant
            break
        end
    end
    if ui then
        pb(ui)
    end
end
function fns.fn210()
    local tP = oE()
    local tQ = oH()
    if not tP or not tQ then
        return
    end
    local tR_1 = {}
    for i, child in tP:GetChildren() do
        local attr = child:GetAttribute("TreeDropClaimId")
        if type(attr) == "string" then
            local tS_1 = ov(child)
            if tS_1 and (tS_1 - tQ.Position).Magnitude <= 10 then
                tR_1[#tR_1 + 1] = attr
            end
        end
    end
    if #tR_1 == 0 then
        return
    end
    pu("CollectTreeDrops", { ClaimIds = tR_1 })
end
function fns.fn219()
    return 0.2
end
function fns.onCopyUSDTAddress()
    pp(o6, "Copied USDT address")
end
function fns.fn256(bE)
    local r0 = UpgradeNodeTreeShared.NormalizeCurrencyId(bE)
    if r0 == "Diamonds" then
        return o9()
    end
    return pn()
end
function fns.fn262(aw)
    local ra = oX()
    if not ra then
        return nil
    end
    local rb = ra.CachedRemotes[og(aw)]
    if type(rb) ~= "string" then
        return nil
    end
    local REM = ReplicatedStorage:FindFirstChild("REM")
    local rc = REM and REM:FindFirstChild(rb)
    return rc or nil
end
function fns.fn265()
    if o3 and o3.ModulesLoaded then
        return o3
    elseif not filtergc then
        return nil
    else
        local q__1 = filtergc("table", { Keys = { "AskServer", "CachedRemotes", "ModulesLoaded" }, IgnoreExecutor = true })
        for k, v in q__1 do
            local q__2 = type(v) == "table" and v.ModulesLoaded and type(v.CachedRemotes) == "table"
            if q__2 then
                o3 = v
                return o3
            end
        end
        return nil
    end
end
function fns.autoBuyInvestorLoop()
    while not Library.Unloaded do
        task.wait(Options.InvestorDelay.Value)
        if Toggles.AutoBuyInvestor.Value then
            pcall(oh)
        end
    end
end
function fns.fn278()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local rZ = leaderstats and leaderstats:FindFirstChild("Diamonds")
    if rZ then
        local rZ_1 = tonumber(rZ.Value) or 0
        return rZ_1
    end
    return 0
end
function fns.fn308(S, T, U)
    return string.format("<b>%s</b> %s %s", S, o1("-", "#5a6070"), o1(T, U))
end
function fns.fn324()
    local s4 = {}
    local PlayerData = LocalPlayer:FindFirstChild("PlayerData")
    local s6 = PlayerData and PlayerData:FindFirstChild("Inventory")
    local s5_1 = s6
    if s6 then
        s6 = s5_1:FindFirstChild("Seeds")
    end
    local s5_2 = s6
    if s5_2 then
        for k, v in s5_2:GetAttributes() do
            local s5_3 = tonumber(v) or 0
            if s5_3 > 0 then
                s4[k] = s5_3
            end
        end
    end
    for k, v in LocalPlayer:GetAttributes() do
        if string.sub(k, 1, 14) == "TreeSeedCount_" then
            local s5_4 = string.sub(k, 15)
            local s6_2 = tonumber(v) or 0
            if s6_2 > 0 then
                local max = math.max
                local s8 = s4[s5_4] or 0
                s4[s5_4] = max(s8, s6_2)
            end
        end
    end
    return s4
end
function fns.fn330()
    local tC = oE()
    local tD = oH()
    local tE = not tD
    local tE_1
    local tF = not tC or tE
    local tF_1
    if tF then
        return nil
    end
    tF_1, tE_1 = nil, nil
    for i, child in tC:GetChildren() do
        if child:GetAttribute("TreeDropClaimId") then
            local tC_1 = ov(child)
            if tC_1 then
                local Magnitude = (tC_1 - tD.Position).Magnitude
                if not tE_1 or Magnitude < tE_1 then
                    tF_1 = tC_1
                    tE_1 = Magnitude
                end
            end
        end
    end
    return tF_1
end
function fns.fn349()
    local t0 = oq()
    if not t0 then
        return true
    end
    local t1 = math.clamp(Options.BuyRollMax.Value, 1, ButtonActions.MaxSeedRerollers)
    local Value = Options.BuyRollKeepCash.Value
    local MaxSeedRerollers = ButtonActions.MaxSeedRerollers
    local ue = 1
    while true do
        if not (ue <= MaxSeedRerollers) then
            return true
        end
        local t3_1 = tonumber(t0:GetAttribute("SeedPedestalCount")) or tonumber(t0:GetAttribute("SeedRerollerCount"))
        local t4 = t3_1 or 1
        if t4 >= t1 then
            return true
        end
        local t4_1 = ou(ButtonActions.BuySeedRerollerAction) or t0:FindFirstChild("BuySeedReroller", true)
        if not t4_1 then
            break
        end
        local attr = t4_1:GetAttribute("SeedRerollerMode")
        if attr and attr ~= "Purchase" then
            return true
        end
        local t4_3 = tonumber(t4_1:GetAttribute("SeedRerollerCost"))
        if type(t4_3) ~= "number" then
            local t6_1 = tonumber(t0:GetAttribute("SeedRerollerTier")) or 1
            t4_3 = ButtonActions.GetSeedRerollerCost(t4, t6_1)
        end
        if type(t4_3) ~= "number" then
            return true
        end
        if pn() < t4_3 + Value then
            return true
        end
        local t3_3 = pu(ButtonActions.PurchaseRemote, { Action = ButtonActions.BuySeedRerollerAction, Button = t4_1 })
        local t4_4 = type(t3_3) ~= "table" or t3_3.Success ~= true
        if t4_4 then
            return true
        end
        task.wait(0.25)
        ue += 1
    end
    return true
end
function fns.onCopyBitcoinAddress()
    pp(pe, "Copied Bitcoin address")
end
function fns.autoBuySeedLoop()
    while not Library.Unloaded do
        task.wait(0.25)
        if Toggles.AutoBuySeed.Value then
            pcall(o8)
        end
    end
end
function fns.onCopyVenmoLink()
    pp(oR, "Copied Venmo link")
end
function fns.fn379()
    local sQ = oq()
    if not sQ then
        return
    end
    local GeneratedSeeds = sQ:FindFirstChild("GeneratedSeeds")
    if not GeneratedSeeds then
        return
    end
    for i, child in GeneratedSeeds:GetChildren() do
        local attr = child:GetAttribute("GeneratedTreeType")
        local sR_1 = type(attr) == "string" and pv(attr)
        if sR_1 then
            for i, descendant in child:GetDescendants() do
                local sQ_2 = descendant:IsA("ProximityPrompt") and descendant.Name == "GrabSeedPrompt"
                if sQ_2 then
                    pb(descendant)
                    break
                end
            end
        end
    end
end
function fns.fn389()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    pA = tick()
end
function fns.fn410()
    local Character = LocalPlayer.Character
    local si = Character and Character:FindFirstChild("HumanoidRootPart")
    return si
end
function fns.fn433(hp)
    local wV = {}
    if type(hp) ~= "table" then
        return wV
    end
    for k, v in hp do
        if type(k) == "number" then
            wV[tostring(v)] = true
        elseif v == true then
            wV[tostring(k)] = true
        else
            wV[tostring(v)] = true
        end
    end
    return wV
end
function fns.fn435(j6, j7)
    local Type = j7.Type
    if Type == "Toggle" then
        return { idx = j6, type = "Toggle", value = j7.Value == true }
    elseif Type == "Slider" then
        return { idx = j6, type = "Slider", value = tostring(j7.Value) }
    elseif Type == "Dropdown" then
        return { idx = j6, type = "Dropdown", multi = j7.Multi == true, value = j7.Value }
    elseif Type == "Input" then
        local yH = j7.Value or ""
        return { idx = j6, type = "Input", text = tostring(yH) }
    elseif Type == "ColorPicker" then
        return { idx = j6, type = "ColorPicker", value = j7.Value:ToHex(), transparency = j7.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = j6,
            type = "KeyPicker",
            mode = j7.Mode,
            key = j7.Value,
            modifiers = j7.Modifiers,
            toggled = j7.Toggled
        }
    else
        return nil
    end
end
function fns.fn461()
    return Options.PlantDelay.Value
end
function fns.fn467(P, Q)
    return string.format('<font color="%s">%s</font>', Q, P)
end
function fns.fn527()
    local w2 = pu(UpgradeNodeTreeRuntimeShared.RemoteNames.GetState, {})
    local w3 = type(w2) ~= "table" or w2.Success ~= true or type(w2.State) ~= "table"
    if w3 then
        return
    end
    local w3_1 = oD(w2.State.OwnedNodeIds)
    local w2_1 = UpgradeNodeTreeRuntimeShared.GetNodes()
    if type(w2_1) ~= "table" then
        return
    end
    local w4 = UpgradeNodeTreeRuntimeShared.GetPurchasableNodeIds(w3_1)
    if type(w4) ~= "table" then
        w4 = {}
        for k in w2_1 do
            local w5_1 = not w3_1[tostring(k)]
            if w5_1 ~= false then
                w5_1 = UpgradeNodeTreeRuntimeShared.IsPurchasableNode(k)
            end
            if w5_1 then
                w4[#w4 + 1] = k
            end
        end
    end
    for k, v in w4 do
        local w4_1 = tostring(v)
        if not w3_1[w4_1] then
            local w5_2 = w2_1[v] or w2_1[w4_1]
            if not not w5_2 then
                local w5_3 = UpgradeNodeTreeShared.ResolveNodePresentation(w5_2)
                local w6_1 = w5_3 and w5_3.price
                if not (type(w6_1) ~= "table") then
                    local w6_2 = tonumber(w6_1.quantity) or 0
                    local w6_3 = w6_1.currencyId or UpgradeNodeTreeShared.DefaultCurrencyId
                    local w6_4 = w6_2 > 0 and oL(w6_3) < w6_2
                    if not w6_4 then
                        local w5_6 = pu(UpgradeNodeTreeRuntimeShared.RemoteNames.Purchase, { NodeId = w4_1 })
                        local w4_2 = type(w5_6) == "table" and w5_6.Success == true
                        if w4_2 then
                            return
                        end
                    end
                end
            end
        end
    end
end
function fns.fn530()
    for k, v in oi() do
        local tp = v > 0 and op(k)
        if tp then
            return true
        end
    end
    return false
end
function fns.fn531(ds)
    local Value = Options.BuySeedTypes.Value
    if type(Value) ~= "table" then
        return true
    end
    local sF = false
    for k, v in Value do
        if v then
            sF = true
            break
        end
    end
    if not sF then
        return true
    end
    return Value[ds] == true
end
function fns.fn551()
    local uJ = oq()
    local uK = oH()
    local uL = not uK
    local uL_1
    local uM = not uJ or uL
    local uM_1
    if uM then
        return nil
    end
    uM_1, uL_1 = nil, nil
    for k, v in CollectionService:GetTagged("ChoppableTree") do
        if v:IsDescendantOf(uJ) then
            local uN = v:IsA("Model") and v:GetPivot().Position
            local uO = uN
            if not uO then
                local uN_1 = v:IsA("BasePart") and v.Position
                uO = uN_1
            end
            local uN_2 = uO
            if uN_2 then
                local Magnitude = (uN_2 - uK.Position).Magnitude
                if not uL_1 or Magnitude < uL_1 then
                    uM_1 = v
                    uL_1 = Magnitude
                end
            end
        end
    end
    return uM_1, uL_1
end
function fns.fn570()
    return Workspace:FindFirstChild("ClientTreeDropEffects_" .. LocalPlayer.UserId)
end
function fns.onCopySolanaAddress()
    pp(o4, "Copied Solana address")
end
function fns.fn587(bS)
    local sa = ou(bS)
    if not sa then
        return nil
    end
    return pu(ButtonActions.PurchaseRemote, { Action = bS, Button = sa })
end
local function onCopyLitecoinAddress()
    pp(pi, "Copied Litecoin address")
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in Character:GetDescendants() do
                local xI_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if xI_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn626()
    if not Toggles.WalkSpeedEnabled.Value then
        local x9 = oV()
        if x9 then
            x9.WalkSpeed = 16
        end
    end
end
local function onRenderStepped(i1)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local xY_1 = oV()
        if xY_1 then
            xY_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local xY_3 = oH()
        local xZ = oV()
        if xY_3 and xZ then
            xZ.PlatformStand = true
            local xZ_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                xZ_1 += CurrentCamera2.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                xZ_1 -= CurrentCamera2.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                xZ_1 -= CurrentCamera2.CFrame.RightVector
            end
            local x3 = if UserInputService:IsKeyDown(Enum.KeyCode.D) then 1 else 0
            if x3 == 1 then
                xZ_1 += CurrentCamera2.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                xZ_1 += Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                xZ_1 -= Vector3.new(0, 1, 0)
            end
            xY_3.AssemblyLinearVelocity = Vector3.zero
            if xZ_1.Magnitude > 0 then
                xY_3.CFrame = xY_3.CFrame + xZ_1.Unit * Options.FlySpeed.Value * i1
            end
        end
    end
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local yy = tick() - pE
            local yz = tick() - pA
            if yy >= 300 and yz >= 60 then
                pcall(pj)
            else
                if yy < 300 and yz >= 300 then
                    pcall(pj)
                end
            end
        end
    end
end
local function fn652()
    local yN = {}
    for k, v in { Toggles, Options } do
        for k, v in v do
            local yO = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if yO then
                local yO_1 = o7(k, v)
                if yO_1 then
                    yN[#yN + 1] = yO_1
                end
            end
        end
    end
    table.sort(yN, function(kl, km)
        if kl.type ~= km.type then
            return kl.type < km.type
        end
        return kl.idx < km.idx
    end)
    return { objects = yN }
end
local function fn656()
    pp(pa, "Copied Discord invite to clipboard")
end
local function onInputBegan()
    pE = tick()
end
local function fn667()
    local wM = oq()
    if not wM then
        return
    end
    local wN = (tonumber(wM:GetAttribute("ItemShelfUnlockedCount")))
    local wR = if wN then 1 else 0
    local wP = 2418 * wR + 1506 * (1 - wR)
    local wQ = 3737 * wR + 298 * (1 - wR)
    if not ((wP * 810 + wQ * 2713 + wP * wQ) % 16777213 == 4355914) then
        wN = 1
    end
    local wM_1 = wN
    local wN_1 = math.clamp(Options.BuyShelfMax.Value, 1, ItemShelfConfig.MaxShelves)
    if wM_1 >= wN_1 then
        return
    end
    local wN_2 = ItemShelfConfig.GetCost(wM_1 + 1)
    if type(wN_2) ~= "number" then
        return
    end
    if pn() < wN_2 + Options.BuyShelfKeepCash.Value then
        return
    end
    ps(ButtonActions.BuyItemShelfAction)
end
local function fn699()
    local v2 = {}
    local v3 = {}
    local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not PlayerGui then
        return v3
    end
    for i, descendant in PlayerGui:GetDescendants() do
        local attr = descendant:GetAttribute("InventoryKey")
        local v5 = type(attr) == "string" and string.sub(attr, 1, 7) == "Carved:"
        if v5 then
            local v5_1 = string.sub(attr, 8)
            if not v2[v5_1] then
                v2[v5_1] = true
                v3[#v3 + 1] = v5_1
            end
        end
    end
    return v3
end
local function onExportConfigToClipboard()
    local za_1
    local y9_1
    y9_1, za_1 = pcall(HttpService.JSONEncode, HttpService, oP())
    if not y9_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local y9_2 = setclipboard or toclipboard
    local y9_3 = type(y9_2) ~= "function" or not pcall(y9_2, za_1)
    if y9_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function fn741()
    local u7 = oq()
    if not u7 then
        return nil
    end
    for i, descendant in u7:GetDescendants() do
        local u7_1 = descendant:IsA("ProximityPrompt") and descendant.Name == "WoodLathePrompt"
        if u7_1 then
            return oZ(descendant.Parent)
        end
    end
    return nil
end
local function onImportConfigFromClipboardTex()
    local zf_1
    local zd = Options.SaveManager_ImportSource.Value or ""
    local zd_1
    local ze = tostring(zd):match("^%s*(.-)%s*$")
    if ze == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    zd_1, zf_1 = pcall(HttpService.JSONDecode, HttpService, ze)
    local ze_1 = not zd_1 or type(zf_1) ~= "table" or type(zf_1.objects) ~= "table"
    if ze_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local zd_2 = 0
    for k, v in zf_1.objects do
        if pw(v) then
            zd_2 += 1
        end
    end
    if zd_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local zf_2 = zd_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(zd_2, zf_2), 6)
end
local function fn750()
    local wd = oq()
    if not wd then
        return
    end
    local SaleSpots = wd:FindFirstChild("SaleSpots", true)
    if not SaleSpots then
        return
    end
    local wf = pm()
    local wg = 1
    for i, child in SaleSpots:GetChildren() do
        local we_1 = child:GetAttribute("SaleSpot") == true and child:GetAttribute("Occupied") ~= true
        if we_1 then
            local we_2 = wf[wg]
            if not we_2 then
                return
            end
            wg += 1
            pu("PlaceCarvedWoodOnSaleSpot", { SpotName = child.Name, TycoonName = wd.Name, WoodId = we_2 })
        end
    end
end
local function fn754()
    local wS = oq()
    if not wS then
        return
    end
    local wT = tonumber(wS:GetAttribute("PlanterCount")) or 1
    local wT_1 = math.clamp(Options.BuyPlanterMax.Value, 1, ButtonActions.MaxPlanters)
    if wT >= wT_1 then
        return
    end
    local wT_2 = ButtonActions.GetPlanterCost(wT)
    if type(wT_2) ~= "number" then
        return
    end
    if pn() < wT_2 + Options.BuyPlanterKeepCash.Value then
        return
    end
    ps(ButtonActions.BuyPlanterAction)
end
local function fn757(dl)
    local Value = Options.PlantSeeds.Value
    if type(Value) ~= "table" then
        return true
    end
    local sw = false
    for k, v in Value do
        if v then
            sw = true
            break
        end
    end
    if not sw then
        return true
    end
    return Value[dl] == true
end
local function fn764()
    local vf = ox()
    if not vf then
        return
    end
    local vf_1 = oI("AxeController")
    local vg = vf_1 and type(vf_1.Equip) == "function"
    if vg then
        if not vf_1.Equipped then
            vf_1:Equip(vf_1:GetPreferredAxeId())
            task.wait(0.2)
        end
        if vf_1.Equipped and vf_1.EquippedTool and vf_1.Character and vf_1.EquippedTool.Parent == vf_1.Character then
            local vg_2 = type(vf_1.PlayNextSwing) == "function" and not vf_1.Swinging
            if vg_2 then
                vf_1:PlayNextSwing()
                return
            end
        end
    end
    local vg_3 = LocalPlayer:GetAttribute("EquippedAxeId") or "BronzeAxe"
    local vh = tostring(vg_3)
    local vg_4 = oV()
    local Character = LocalPlayer.Character
    local vj
    if vf_1 and vf_1.EquippedTool then
        vj = vf_1.EquippedTool
        local vf_2 = vj:GetAttribute("AxeId") or vh
        vh = tostring(vf_2)
    elseif Character then
        for i, child in Character:GetChildren() do
            local vf_3 = child:IsA("Tool") and child:GetAttribute("AxeId")
            if vf_3 then
                vj = child
                vh = tostring(child:GetAttribute("AxeId"))
                break
            end
        end
        if not vj then
            local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            if Backpack then
                for i, child in Backpack:GetChildren() do
                    local vf_5 = child:IsA("Tool") and child:GetAttribute("AxeId")
                    if vf_5 then
                        vj = child
                        vh = tostring(child:GetAttribute("AxeId"))
                        break
                    end
                end
            end
        end
    end
    if vg_4 and vj and vj.Parent ~= Character then
        vg_4:EquipTool(vj)
        task.wait(0.1)
    end
    oS("AxeEquip", { Equipped = true, AxeId = vh })
    oS("AxeHit", { SwingIndex = ow, AxeId = vh })
    ow = ow % 2 + 1
end
local function fn766(f3)
    local vE = f3.Cylinder and f3.Cylinder.Profile
    local TargetProfile = f3.TargetProfile
    local vG = type(vE) ~= "table" or type(TargetProfile) ~= "table"
    if vG then
        return false
    end
    local vG_1 = nil
    if type(TargetProfile.GetProfile) == "function" then
        vG_1 = TargetProfile:GetProfile()
    elseif type(TargetProfile.Profile) == "table" then
        vG_1 = TargetProfile.Profile
    end
    local vE_2 = type(vG_1) ~= "table" or type(vG_1.GetRadiiCopy) ~= "function" or type(vE.LoadRadii) ~= "function"
    if vE_2 then
        return false
    end
    local vE_3 = vG_1:GetRadiiCopy()
    if type(vE_3) ~= "table" then
        return false
    end
    vE:LoadRadii(vE_3)
    f3.HasModifiedWood = true
    if type(f3.GetAccuracyCalculator) == "function" then
        local vE_4 = f3:GetAccuracyCalculator()
        if vE_4 then
            if type(vE_4.SetProfiles) == "function" then
                vE_4:SetProfiles(vE, vG_1)
            end
            if type(vE_4.Calculate) == "function" then
                vE_4:Calculate()
            end
        end
    end
    return f3:HasModifiedCurrentWood() == true
end
local function fn773()
    local Character = LocalPlayer.Character
    local sf = Character and Character:FindFirstChildOfClass("Humanoid")
    return sf
end
local function onInputChanged(jK)
    local UserInputType = jK.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        pE = tick()
    end
end
local function fn786()
    return true
end
local function worker()
    local st_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local ss = math.floor(os.clock() - oC)
        if ss < 60 then
            st_1 = ss .. "s"
        elseif ss < 3600 then
            st_1 = string.format("%dm %ds", math.floor((ss) / (60)), ss % 60)
        else
            st_1 = string.format("%dh %dm", math.floor((ss) / (3600)), math.floor((ss % 3600) / (60)))
        end
        Label:SetText(oN("Session time", st_1, oo))
    end
end
local function fn828()
    return of() ~= nil
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            oQ(true)
        end
    end
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local xQ_1 = oV()
        if xQ_1 then
            xQ_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function worker2()
    while not Library.Unloaded do
        local xr = false
        local xs = {}
        for k, v in oy do
            if Toggles[v.toggle].Value then
                xr = true
                if v.work() then
                    xs[#xs + 1] = v
                end
            end
        end
        if #xs == 0 then
            local xr_1 = xr and "Waiting for trees" or "Idle"
            Label2:SetText(oN("Status", xr_1, oj))
            task.wait(0.5)
        else
            ot = ot % #xs + 1
            local xr_2 = xs[ot]
            Label2:SetText(oN("Status", xr_2.name, oz))
            if Toggles[xr_2.teleport].Value then
                local xs_1 = xr_2.target()
                local xt_2 = typeof(xs_1) == "Instance" and oZ(xs_1)
                local xu = xt_2
                if not xu then
                    local xt_3 = typeof(xs_1) == "Vector3" and xs_1
                    xu = xt_3
                end
                local xs_2 = xu
                local xt_4 = oH()
                if xu then
                    xu = xt_4
                end
                if xu then
                    xt_4.CFrame = CFrame.new(xs_2 + Vector3.new(0, 3, 5))
                end
            end
            pcall(xr_2.run)
            task.wait(xr_2.delay())
        end
    end
end
local function fn906(I, J)
    if setclipboard then
        setclipboard(I)
    elseif toclipboard then
        toclipboard(I)
    end
    Library:Notify(J)
end
local function autoShelfLoop()
    while not Library.Unloaded do
        task.wait(Options.ShelfDelay.Value)
        if Toggles.AutoShelf.Value then
            pcall(oK)
        end
    end
end
local function fn957()
    local ut = oq()
    if not ut then
        return
    end
    local uu = oi()
    local uv
    for k, v in uu do
        local uu_1 = v > 0 and op(k)
        if uu_1 then
            uv = k
            break
        end
    end
    if not uv then
        return
    end
    for i, descendant in ut:GetDescendants() do
        local uu_2 = descendant:GetAttribute("TreePlanter") == true and descendant:GetAttribute("TreePlanterStatus") == "Empty"
        if uu_2 then
            local uu_3 = tonumber(descendant:GetAttribute("PlanterIndex"))
            if uu_3 then
                pu("PlantSeedFromInventory", { PlanterIndex = uu_3, TreeType = uv, TycoonName = ut.Name })
                return
            end
        end
    end
end
local function fn969()
    return Options.ChopDelay.Value
end
local function autoRollDelayLoop()
    while not Library.Unloaded do
        task.wait(Options.AutoRollDelay.Value)
        if Toggles.AutoRoll.Value then
            pcall(oA)
        elseif Toggles.AutoBuyRoll.Value then
            pcall(oe)
        end
    end
end
local function fn997(cb)
    local DiscordGroup = cb:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = pd })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = pd })
end
local function fn1007()
    local xp = oO() ~= nil and o_()
    return xp
end
local function fn1020()
    return Options.CarveDelay.Value
end
local function fn1056(fs)
    if fs:IsA("Model") then
        return fs:GetPivot().Position
    elseif fs:IsA("BasePart") then
        return fs.Position
    else
        return nil
    end
end
local function fn1058()
    local so_1
    local sn_1
    if identifyexecutor then
        so_1, sn_1 = identifyexecutor()
        local sp = so_1 ~= ""
        local sq = type(so_1) == "string" and sp
        if sq then
            local sp_1 = type(sn_1) == "string" and sn_1 ~= "" and so_1 .. " " .. sn_1
            pq = sp_1 or so_1
        end
    end
end
local function fn1065()
    oQ(Toggles.AntiGameplayPause.Value)
end
local function fn1089()
    local wu = oI("SaleNPCs")
    local wv = not wu or type(wu.ActiveOffers) ~= "table"
    if wv then
        return
    end
    local wv_1 = tonumber(Options.MinOfferPay.Value) or 0
    local ww = {}
    for k, v in wu.ActiveOffers do
        local wv_2 = type(k) == "string" and type(v) == "table"
        if wv_2 then
            local wv_3 = pz(v)
            local wy = wv_3 ~= nil and wv_3 >= wv_1
            ww[k] = wy
        end
    end
    for k, v in ww do
        wu:RespondToOffer(k, v)
    end
end
local function fn1092()
    local uX = oq()
    if not uX then
        return nil
    end
    for i, descendant in uX:GetDescendants() do
        local uX_1 = descendant:GetAttribute("TreePlanter") == true and descendant:GetAttribute("TreePlanterStatus") == "Empty"
        if uX_1 then
            return descendant
        end
    end
    return nil
end
local function onCopyEthereumAddress()
    pp(pc, "Copied Ethereum address")
end
local function fn1132(jZ, j_)
    local yD_1 = (jZ == "Toggle" and Toggles or Options)[j_]
    local yC_2 = type(yD_1) == "table" and yD_1.Type == jZ
    return yC_2 and yD_1 or nil
end
local function fn1153()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local rT = leaderstats and leaderstats:FindFirstChild("Cash")
    if rT then
        local rT_1 = tonumber(rT.Value) or 0
        return rT_1
    end
    return 0
end
local function fn1157(gS)
    local Gui = gS.Gui
    if typeof(Gui) ~= "Instance" then
        return nil
    end
    local Offer = Gui:FindFirstChild("Offer", true)
    local wr_1 = not Offer or not Offer:IsA("TextLabel")
    if wr_1 then
        return nil
    end
    return tonumber(string.match(Offer.Text, "%$(%d+)"))
end
local function fn1161()
    local attr = LocalPlayer:GetAttribute("TycoonName")
    local Tycoons = Workspace:FindFirstChild("Tycoons")
    if not Tycoons then
        return nil
    end
    local rG = attr ~= ""
    local rH = type(attr) == "string" and rG
    if rH then
        local rG_1 = Tycoons:FindFirstChild(attr)
        if rG_1 then
            return rG_1
        end
        local UserId = LocalPlayer.UserId
        for i, child in Tycoons:GetChildren() do
            if child:GetAttribute("OwnerUserId") == UserId then
                return child
            end
        end
        return nil
    end
    local UserId = LocalPlayer.UserId
    for i, child in Tycoons:GetChildren() do
        if child:GetAttribute("OwnerUserId") == UserId then
            return child
        end
    end
    return nil
end
local function onCopyPayPalLink()
    pp(oY, "Copied PayPal link")
end
Library = nil
oe = nil
of = nil
og = nil
oh = nil
oi = nil
oj = nil
ol = nil
om = nil
oo = nil
op = nil
oq = nil
ot = nil
ou = nil
ov = nil
ow = nil
ox = nil
oy = nil
oz = nil
oA = nil
oC = nil
oD = nil
oE = nil
CurrentCamera2 = nil
UpgradeNodeTreeShared = nil
oH = nil
oI = nil
UpgradeNodeTreeRuntimeShared = nil
oK = nil
oL = nil
Serializer = nil
oN = nil
oO = nil
oP = nil
oQ = nil
oR = nil
oS = nil
Label2 = nil
ItemShelfConfig = nil
oV = nil
oW = nil
oX = nil
oY = nil
oZ = nil
o_ = nil
ButtonActions = nil
o1 = nil
Label = nil
o3 = nil
local oB
o4 = nil
o5 = nil
o6 = nil
o7 = nil
o8 = nil
o9 = nil
pa = nil
pb = nil
pc = nil
pd = nil
pe = nil
pf = nil
LocalPlayer = nil
ph = nil
pi = nil
pj = nil
Workspace = nil
CollectionService = nil
pm = nil
pn = nil
HttpService = nil
pp = nil
pq = nil
VirtualUser = nil
ps = nil
Options = nil
pu = nil
pv = nil
pw = nil
UserInputService = nil
Toggles = nil
pz = nil
pA = nil
pC = nil
SaveManager = nil
pE = nil
ReplicatedStorage = nil
local pB
pB = nil
local qh, MenuGroup
ReplicatedStorage, UserInputService, VirtualUser, HttpService, CollectionService, Workspace, LocalPlayer, pa, o5, ButtonActions, ItemShelfConfig, Serializer, UpgradeNodeTreeRuntimeShared, UpgradeNodeTreeShared = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local zt_17 = game:GetService("Players")
ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
CollectionService = game:GetService("CollectionService")
Workspace = game:GetService("Workspace")
LocalPlayer = zt_17.LocalPlayer
local zt_6 = "Carve Wood"
pa = "https://discord.gg/K7Qxnxkk46"
o5 = "https://discord.gg/K7Qxnxkk46"
ButtonActions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ButtonActions"))
ItemShelfConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ItemShelfConfig"))
local zt_30 = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("WoodEconomy"))
Serializer = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("WoodCarving"):WaitForChild("Serializer"))
UpgradeNodeTreeRuntimeShared = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("UpgradeNodeTreeRuntimeShared"))
UpgradeNodeTreeShared = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("UpgradeNodeTreeShared"))
local zt_19 = {}
local zt_21 = {}
for k, v in zt_30.TreeTypesByRarity do
    for k, v in v do
        if not zt_21[v] then
            zt_21[v] = true
            zt_19[#zt_19 + 1] = v
        end
    end
end
table.sort(zt_19)
Library, SaveManager, Toggles, Options, oz, oo, oj, o3, ow, zt_4, pp, pd, o1, oN, og, oX, oB, pu, oS, om, oI, oq, pn, o9, oL, ou, ps, pb, oV, oH, zt_21 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
pp = fn906
pd = fn656
o1 = fns.fn467
oN = fns.fn308
if ((oX or not oX or (pu or og)) and (not oX and oS and (og or not og)) or (oX or not oX or (oX or not oX)) and (not oX and not og and (pu or not og))) and (false and not oX and (not oX or false) or (false or og and not oX) or (oX and pu or false or false and (false or not og))) and not (((oX or not oX or (pu or og)) and (not oX and oS and (og or not og)) or (oX or not oX or (oX or not oX)) and (not oX and not og and (pu or not og))) and (false and not oX and (not oX or false) or (false or og and not oX) or (oX and pu or false or false and (false or not og)))) then
    o9 = "#7fd47f"
else
    oz = "#7fd47f"
end
local zt_35 = "#6ec1ff"
oo = "#e8a34d"
oj = "#8b93a3"
og = fns.fn146
oX = fns.fn265
oB = fns.fn262
pu = function(aF, aG)
    local rn
    rn = nil
    local rp_1
    rn = oB(aF)
    local ro = not rn or rn.ClassName ~= "RemoteFunction"
    local ro_1
    if ro then
        return nil
    end
    ro_1, rp_1 = pcall(function()
        local rl = aG or {}
        return rn:InvokeServer(rl)
    end)
    if ro_1 then
        return rp_1
    end
    return nil
end
oS = function(aP, aQ)
    local ru
    ru = nil
    ru = oB(aP)
    if not ru or ru.ClassName ~= "RemoteEvent" then
        return false
    end
    local rv_1 = pcall(function()
        local rs = aQ or {}
        ru:FireServer(rs)
    end)
    return rv_1
end
om = function()
    local rz = oX()
    if not rz then
        return nil
    elseif rz.__TempoNetPatched then
        return rz
    else
        rz.AskServer = function(a_, a0, a1, a2)
            task.spawn(function()
                local rx = pu(a0, a1)
                if type(a2) == "function" then
                    a2(rx)
                end
            end)
        end
        rz.TellServer = function(ba, bb, bc)
            oS(bb, bc)
        end
        rz.__TempoNetPatched = true
        return rz
    end
end
oI = fns.fn16
om()
oq = fn1161
if (not oN or oN) and (not pb and pb) and (zt_21 or oN or (oN or not oN)) and ((not oN or not oN or not pb and zt_21) and (not oN or zt_21 or not zt_21 and not oN)) or (pb and not pb or pb and oN or (not zt_21 and not zt_21 or (not pb or oN))) and ((not oN or oN) and (not zt_21 and pb) or oN and not pb and (zt_21 or not oN)) or not ((not oN or oN) and (not pb and pb) and (zt_21 or oN or (oN or not oN)) and ((not oN or not oN or not pb and zt_21) and (not oN or zt_21 or not zt_21 and not oN)) or (pb and not pb or pb and oN or (not zt_21 and not zt_21 or (not pb or oN))) and ((not oN or oN) and (not zt_21 and pb) or oN and not pb and (zt_21 or not oN))) then
    pn = fn1153
end
o9 = fns.fn278
oL = fns.fn256
ou = fns.fn122
ps = fns.fn587
pb = fns.fn126
oV = fn773
oH = fns.fn410
ow = 1
if zt_21 and ThemeManager and (not ThemeManager or false) and (ThemeManager and ThemeManager and false) and (not zt_21 and not ThemeManager and (not ThemeManager and 1) or 1) and (((not zt_21) and (not zt_21)) or (ThemeManager and not zt_21 and (not ThemeManager or not zt_21) or (not zt_21 or false or (not ThemeManager or not zt_21)))) and not (zt_21 and ThemeManager and (not ThemeManager or false) and (ThemeManager and ThemeManager and false) and (not zt_21 and not ThemeManager and (not ThemeManager and 1) or 1) and (((not zt_21) and (not zt_21)) or (ThemeManager and not zt_21 and (not ThemeManager or not zt_21) or (not zt_21 or false or (not ThemeManager or not zt_21))))) then
    zt_6 = pa:CreateWindow({
        Icon = 78539693571783,
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = Library, Copyable = true }, zt_4, "|" },
        Title = "Tempo",
        ShowCustomCursor = false,
        NotifySide = "Right",
        CornerRadius = 0
    })
else
    zt_4 = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = pa, Copyable = true }, "|", zt_6 },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0
    })
end
local zt_8 = {
    Info = zt_4:AddTab("Info", "info"),
    Main = zt_4:AddTab("Main", "axe"),
    Player = zt_4:AddTab("Player", "person-standing"),
    Settings = zt_4:AddTab("Settings", "settings")
}
if zt_21 and (og or false) and 23 and (not oX and not oX or 23 or (not og) and (oS or oX)) or (og and oS and (not og and zt_21) or (og or not zt_21) or false and not og and (oN and oX) and (oN and not oX)) or not (zt_21 and (og or false) and 23 and (not oX and not oX or 23 or (not og) and (oS or oX)) or (og and oS and (not og and zt_21) or (og or not zt_21) or false and not og and (oN and oX) and (oN and not oX))) then
    zt_21 = fn997
else
    oI = fn997
end
for k, v in zt_8 do
    zt_21(v)
end
pq, GameInfoGroup, Label, oW, zt_30 = nil, nil, nil, nil, nil
zt_17 = 7
repeat
    zt_21 = (zt_17 * 2 + 1) % 3 + 1
    if zt_21 <= 2 then
        if zt_21 <= 1 then
            zt_21 = (vector.create((zt_17 * 1 + 1) % 11 + 1, (zt_17 * 8 + 8) % 13 + 1, (zt_17 * 8 + 12) % 17 + 1))
            zt_37 = (vector.create((zt_17 * 4 + 5) % 11 + 1, (zt_17 * 4 + 6) % 13 + 1, (zt_17 * 12 + 5) % 17 + 1))
            zt_25 = (vector.create((zt_17 * 2 + 4) % 11 + 1, (zt_17 * 2 + 8) % 13 + 1, (zt_17 * 13 + 13) % 17 + 1))
            zt_13 = (vector.create((zt_17 * 5 + 5) % 11 + 1, (zt_17 * 11 + 8) % 13 + 1, (zt_17 * 3 + 6) % 17 + 1))
            if vector.dot(vector.cross(zt_21, zt_37), (vector.cross(zt_25, zt_13))) == vector.dot(zt_21, zt_25) * vector.dot(zt_37, zt_13) - vector.dot(zt_21, zt_13) * vector.dot(zt_37, zt_25) then
                pq = "Unknown"
                pcall(fn1058)
                zt_4 = zt_8.Info:AddLeftGroupbox("Account", "circle-user")
                zt_4:AddLabel(oN("User", LocalPlayer.Name, oz), true)
                zt_4:AddLabel(oN("Status", "Keyless", oz), true)
                zt_4:AddLabel(oN("Executor", pq, oz), true)
                GameInfoGroup = zt_8.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                GameInfoGroup:AddLabel(o1(zt_6 .. " [" .. tostring(game.PlaceId) .. "]", zt_35), true)
                GameInfoGroup:AddLabel(oN("Place ID", tostring(game.PlaceId), zt_35), true)
                Label = GameInfoGroup:AddLabel(oN("Session time", "0s", oo), true)
            else
                pcall(fn1058)
                oo = Label.Info:AddLeftGroupbox("Account", "circle-user")
                oo:AddLabel(GameInfoGroup("User", o1.Name, zt_6), true)
                oo:AddLabel(GameInfoGroup("Status", "Keyless", zt_6), true)
                oo:AddLabel(GameInfoGroup("Executor", "Unknown", zt_6), true)
                oz = Label.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                oz:AddLabel(LocalPlayer(zt_35 .. " [" .. tostring(game.PlaceId) .. "]", pq), true)
                oz:AddLabel(GameInfoGroup("Place ID", tostring(game.PlaceId), pq), true)
                oN = oz:AddLabel(GameInfoGroup("Session time", "0s", zt_8), true)
            end
            zt_17 = (zt_17 + 20) % 24
        else
            zt_21 = (vector.create((zt_17 * 7 + 6) % 11 + 1, (zt_17 * 2 + 4) % 13 + 1, (zt_17 * 14 + 11) % 17 + 1))
            local As = vector.floor(zt_21) + vector.ceil(zt_21 * -1)
            if vector.dot(As, As) == 5 then
                zt_30 = tostring(game.JobId)
            else
                oW = tostring(game.JobId)
            end
            zt_17 = (zt_17 + 17) % 24
        end
    else
        local Ap = bit32.rrotate(bit32.bxor(bit32.lrotate(zt_17, 13), string.byte(tostring(oW))), 29)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(Ap, 231018569), 4072515882), (bit32.bxor(bit32.band(Ap, 4063948726), 3271442610))), 4072515882), 3271442610) ~= Ap then
            oW = #zt_30 > 18
        else
            zt_30 = #oW > 18
        end
        zt_17 = (zt_17 + 20) % 24
    end
until (zt_17 * 5 + 7) % 24 == 15
if zt_30 then
    zt_17 = 4
    repeat
        zt_4 = (vector.create((zt_17 * 5 + 3) % 11 + 1, (zt_17 * 11 + 12) % 13 + 1, (zt_17 * 5 + 15) % 17 + 1))
        zt_21 = (vector.create((zt_17 * 4 + 2) % 11 + 1, (zt_17 * 9 + 12) % 13 + 1, (zt_17 * 3 + 9) % 17 + 1))
        local AD = vector.dot(zt_4, zt_21)
        if AD * AD <= vector.dot(zt_4, zt_4) * vector.dot(zt_21, zt_21) then
            zt_30 = string.sub(oW, 1, 18) .. "..."
        else
            oW = string.sub(zt_30, 1, 18) .. "..."
        end
        zt_17 = (zt_17 + 4) % 8
    until (zt_17 * 3 + 4) % 8 == 4
end
zt_17 = zt_30 or oW
oC, pi, pe, pc, o6, o4, oY, oR, Label2, oy, ot, FlyGroup, CurrentCamera2, MenuGroup, pE, pA, qh, op, pv, o8, oi, o_, oE, ov, of, oe, oA, zt_24, ox, oZ, oO, pC, pm, oK, pz, ph, ol, pf, oD, oh, oQ, pj, pB, o7, oP, pw = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local zt_18 = zt_17
GameInfoGroup:AddLabel(oN("Server", zt_18, oj), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
oC = os.clock()
task.spawn(worker)
local ScriptsGroup = zt_8.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(o1("Included in this hub", oj), true)
ScriptsGroup:AddLabel(o1(zt_6, zt_35), true)
local FeaturesGroup = zt_8.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(o1("Automation", zt_35), true)
FeaturesGroup:AddLabel(o1("Shop", oo), true)
FeaturesGroup:AddLabel(o1("Player", oj), true)
local SocialsGroup = zt_8.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = pd })
SocialsGroup:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
local TempoHubGroup = zt_8.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = pd })
pi = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
pe = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
pc = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
o6 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
o4 = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
oY = ""
oR = ""
zt_5, zt_2, zt_27, zt_15, zt_39, zt_25, zt_30 = "#345d9d", "#f7931a", "#627eea", "#26a17b", "#14f195", "#0070ba", "#008cff"
zt_4 = zt_8.Info:AddRightGroupbox("Donations", "heart")
zt_4:AddLabel(o1("All donations are optional but appreciated.", oo), true)
zt_4:AddLabel(o1("If you donate you get a special role, just PING after you donate.", oz), true)
zt_4:AddDivider()
zt_4:AddLabel(o1("LTC / Litecoin", zt_5), true)
zt_4:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
zt_4:AddLabel(o1("BTC / Bitcoin", zt_2), true)
zt_4:AddButton({ Text = "Copy Bitcoin Address", Func = fns.onCopyBitcoinAddress })
zt_4:AddLabel(o1("ETH / Ethereum", zt_27), true)
zt_4:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
zt_4:AddLabel(o1("USDT", zt_15), true)
zt_4:AddButton({ Text = "Copy USDT Address", Func = fns.onCopyUSDTAddress })
zt_4:AddLabel(o1("Solana", zt_39), true)
zt_4:AddButton({ Text = "Copy Solana Address", Func = fns.onCopySolanaAddress })
zt_4:AddLabel(o1("PayPal", zt_25), true)
zt_4:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
zt_4:AddLabel(o1("Venmo", zt_30), true)
zt_4:AddButton({ Text = "Copy Venmo Link", Func = fns.onCopyVenmoLink })
zt_4:AddDivider()
zt_4:AddLabel(o1("Don't have any of the listed currencies but still wanna donate?", oj), true)
zt_4:AddLabel(o1("DM me and we'll work something out.", zt_35), true)
local FaqGroup = zt_8.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutomationGroup = zt_8.Main:AddLeftGroupbox("Automation", "activity")
Label2 = AutomationGroup:AddLabel(oN("Status", "Idle", oj), true)
local SeedRollGroup = zt_8.Main:AddLeftGroupbox("Seed Roll", "dices")
SeedRollGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
SeedRollGroup:AddSlider("AutoRollDelay", { Text = "Roll Delay", Default = 2.5, Min = 1, Max = 10, Rounding = 1, Suffix = "s" })
SeedRollGroup:AddToggle("AutoBuyRoll", { Text = "Auto Buy Roll", Default = false })
SeedRollGroup:AddSlider("BuyRollMax", { Text = "Max Rollers", Default = 6, Min = 1, Max = ButtonActions.MaxSeedRerollers, Rounding = 0 })
SeedRollGroup:AddSlider("BuyRollKeepCash", { Text = "Keep Cash", Default = 0, Min = 0, Max = 100000, Rounding = 0 })
SeedRollGroup:AddToggle("AutoBuySeed", { Text = "Auto Buy Seed", Default = false })
SeedRollGroup:AddDropdown("BuySeedTypes", { Text = "Seeds", Values = zt_19, Default = {}, Multi = true, Searchable = true, AllowNull = true })
local PlantGroup = zt_8.Main:AddLeftGroupbox("Plant", "sprout")
PlantGroup:AddToggle("AutoPlant", { Text = "Auto Plant Seed", Default = false })
PlantGroup:AddDropdown("PlantSeeds", { Text = "Seeds", Values = zt_19, Default = {}, Multi = true, Searchable = true, AllowNull = true })
PlantGroup:AddToggle("AutoPlantTeleport", { Text = "Teleport To Planters", Default = true })
PlantGroup:AddSlider("PlantDelay", { Text = "Plant Delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Suffix = "s" })
local ChopGroup = zt_8.Main:AddRightGroupbox("Chop", "tree-deciduous")
ChopGroup:AddToggle("AutoChop", { Text = "Auto Chop Trees", Default = false })
ChopGroup:AddToggle("AutoChopTeleport", { Text = "Teleport To Trees", Default = true })
ChopGroup:AddToggle("AutoCollectDrops", { Text = "Auto Collect Tree Drops", Default = false })
ChopGroup:AddSlider("ChopDelay", { Text = "Chop Delay", Default = 0.35, Min = 0.1, Max = 2, Rounding = 2, Suffix = "s" })
local CarveGroup = zt_8.Main:AddRightGroupbox("Carve", "hammer")
CarveGroup:AddToggle("AutoCarve", { Text = "Auto Carve Wood", Default = false })
CarveGroup:AddToggle("AutoEnterLathe", { Text = "Auto Enter Lathe", Default = true })
CarveGroup:AddToggle("AutoCarveTeleport", { Text = "Teleport To Carver", Default = true })
CarveGroup:AddSlider("CarveDelay", { Text = "Carve Delay", Default = 0.75, Min = 0.2, Max = 5, Rounding = 2, Suffix = "s" })
local ShelvesGroup = zt_8.Main:AddLeftGroupbox("Shelves", "layout-grid")
ShelvesGroup:AddToggle("AutoShelf", { Text = "Auto Shelf Carved Wood", Default = false })
ShelvesGroup:AddSlider("ShelfDelay", { Text = "Shelf Delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Suffix = "s" })
ShelvesGroup:AddToggle("AutoBuyShelves", { Text = "Auto Buy Shelves", Default = false })
ShelvesGroup:AddSlider("BuyShelfMax", {
    Text = "Max Shelves",
    Default = ItemShelfConfig.MaxShelves,
    Min = 1,
    Max = ItemShelfConfig.MaxShelves,
    Rounding = 0
})
ShelvesGroup:AddSlider("BuyShelfKeepCash", { Text = "Keep Cash", Default = 0, Min = 0, Max = 100000, Rounding = 0 })
zt_13 = zt_8.Main:AddRightGroupbox("Sell Offers", "hand-coins")
zt_13:AddToggle("AutoAcceptOffers", { Text = "Auto Accept Offers", Default = false })
zt_13:AddInput("MinOfferPay", { Text = "Decline Below", Numeric = true, Default = "0", Finished = true })
zt_21 = zt_8.Main:AddRightGroupbox("Shop", "shopping-cart")
zt_21:AddToggle("AutoBuyPlanters", { Text = "Auto Buy Planters", Default = false })
zt_21:AddSlider("BuyPlanterMax", {
    Text = "Max Planters",
    Default = ButtonActions.MaxPlanters,
    Min = 1,
    Max = ButtonActions.MaxPlanters,
    Rounding = 0
})
zt_21:AddSlider("BuyPlanterKeepCash", { Text = "Keep Cash", Default = 0, Min = 0, Max = 100000, Rounding = 0 })
zt_21:AddToggle("AutoBuyInvestor", { Text = "Auto Buy Investor Upgrades", Default = false })
zt_21:AddSlider("InvestorDelay", { Text = "Investor Delay", Default = 1, Min = 0.5, Max = 10, Rounding = 1, Suffix = "s" })
op = fn757
pv = fns.fn531
if (not pm and false or zt_15 and ov) and (not FlyGroup and pe or (pm or not pm)) and (zt_15 or not ov or not ov and false or (false or ov or (false or pm))) or (ov and pe or (not pm or false) or (pe or FlyGroup or not pm and pm)) and (not FlyGroup and not ov or FlyGroup and pe or false and (pe or ov)) or not ((not pm and false or zt_15 and ov) and (not FlyGroup and pe or (pm or not pm)) and (zt_15 or not ov or not ov and false or (false or ov or (false or pm))) or (ov and pe or (not pm or false) or (pe or FlyGroup or not pm and pm)) and (not FlyGroup and not ov or FlyGroup and pe or false and (pe or ov))) then
    o8 = fns.fn379
    oi = fns.fn324
    o_ = fns.fn530
    oE = fns.fn570
else
    oE = fns.fn379
    o8 = fns.fn324
    oi = fns.fn530
    o_ = fns.fn570
end
ov = fns.fn41
of = fns.fn330
oe = fns.fn349
oA = fns.fn190
if (false and not oK and (not oK or pe) and (not pj or SeedRollGroup or not pB and not oA) or (oK or oK or (oK or SeedRollGroup) or (false or not SeedRollGroup) and (false or not pB)) or (oK and pj or pe and oA) and ((SeedRollGroup or pB) and (oA and false)) and ("bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99" or not oK and pB or not SeedRollGroup and not pj and (not pj or false))) and not (false and not oK and (not oK or pe) and (not pj or SeedRollGroup or not pB and not oA) or (oK or oK or (oK or SeedRollGroup) or (false or not SeedRollGroup) and (false or not pB)) or (oK and pj or pe and oA) and ((SeedRollGroup or pB) and (oA and false)) and ("bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99" or not oK and pB or not SeedRollGroup and not pj and (not pj or false))) then
    oK = fn957
else
    zt_24 = fn957
end
ox = fns.fn551
oZ = fn1056
oO = fn1092
zt_37 = fn741
pC = fn766
pm = fn699
oK = fn750
pz = fn1157
ph = fn1089
ol = fn667
pf = fn754
do
    oD = fns.fn433
    oh = fns.fn527
    task.spawn(autoRollDelayLoop)
    task.spawn(fns.autoBuySeedLoop)
    task.spawn(fns.autoBuyShelvesLoop)
    oy = {
        {
            name = "Planting",
            toggle = "AutoPlant",
            teleport = "AutoPlantTeleport",
            target = oO,
            run = zt_24,
            work = fn1007,
            delay = fns.fn461
        },
        {
            name = "Chopping",
            toggle = "AutoChop",
            teleport = "AutoChopTeleport",
            target = ox,
            run = fn764,
            work = fns.fn72,
            delay = fn969
        },
        {
            name = "Carving",
            toggle = "AutoCarve",
            teleport = "AutoCarveTeleport",
            target = zt_37,
            run = fns.fn22,
            work = fn786,
            delay = fn1020
        },
        {
            name = "Collecting",
            toggle = "AutoCollectDrops",
            teleport = "AutoCollectDrops",
            target = of,
            run = fns.fn210,
            work = fn828,
            delay = fns.fn219
        }
    }
end
ot = 0
task.spawn(worker2)
task.spawn(autoShelfLoop)
task.spawn(fns.autoAcceptOffersLoop)
task.spawn(fns.autoBuyInvestorLoop)
local MovementGroup = zt_8.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
FlyGroup = zt_8.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera2 = Workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fns.fn149)
Toggles.WalkSpeedEnabled:OnChanged(fn626)
oQ = function(jm)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not jm)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not jm
        end
    end)
    if not jm then
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
if (qh and not oe and (fns.fn210 and fns.fn210) or (false or qh or (pv or false)) or ((pv or qh) and (not qh and not pv) or (false or oe or (not pv or pv)))) and ((false or not pv) and (false or qh) and (zt_37 or not qh or (not oe or not pv)) and ((false and not pv or (false or zt_37)) and (qh or not pv or false and qh))) or not ((qh and not oe and (fns.fn210 and fns.fn210) or (false or qh or (pv or false)) or ((pv or qh) and (not qh and not pv) or (false or oe or (not pv or pv)))) and ((false or not pv) and (false or qh) and (zt_37 or not qh or (not oe or not pv)) and ((false and not pv or (false or zt_37)) and (qh or not pv or false and qh)))) then
    Toggles.AntiGameplayPause:OnChanged(fn1065)
    task.spawn(antiGameplayPauseLoop)
    MenuGroup = zt_8.Settings:AddLeftGroupbox("Menu")
else
    MenuGroup.AntiGameplayPause:OnChanged(fn1065)
    task.spawn(antiGameplayPauseLoop)
    zt_8 = Toggles.Settings:AddLeftGroupbox("Menu")
end
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
pE = tick()
pA = tick()
pcall(function()
    for k, v in getconnections(LocalPlayer.Idled) do
        local ys = v
        pcall(function()
            ys:Disable()
        end)
    end
end)
pj = fns.fn389
UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(antiAfkLoop)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(zt_8.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/CarveWood")
qh = SaveManager:BuildConfigSection(zt_8.Settings)
SaveManager:LoadAutoloadConfig()
pB = fn1132
o7 = fns.fn435
oP = fn652
pw = function(ko)
    local y6
    y6 = nil
    local y7 = type(ko) ~= "table" or type(ko.idx) ~= "string" or type(ko.type) ~= "string" or SaveManager.Ignore[ko.idx]
    if y7 then
        return false
    end
    y6 = pB(ko.type, ko.idx)
    if not y6 then
        return false
    end
    local y7_1 = pcall(function()
        if ko.type == "Input" then
            if type(ko.text) ~= "string" then
                return
            end
            y6:SetValue(ko.text)
        elseif ko.type == "ColorPicker" then
            y6:SetValueRGB(Color3.fromHex(ko.value), ko.transparency)
        elseif ko.type == "KeyPicker" then
            y6:SetValue({ ko.key, ko.mode, ko.modifiers })
            if ko.mode == "Toggle" and ko.toggled ~= nil then
                y6.Toggled = ko.toggled
                y6:Update()
            end
        else
            y6:SetValue(ko.value)
        end
    end)
    return y7_1
end
qh:AddDivider()
qh:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
qh:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
qh:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
Library:OnUnload(fns.fn67)
end)(...)

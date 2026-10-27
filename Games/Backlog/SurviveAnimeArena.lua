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
getgenv().TempoHoodSubtitle = "SURVIVE ANIME ARENA"
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
local lB
local kW
local UserInputService
local lh
local kZ
local connection3
local lk
local ln
local Workspace
local lq
local lN
local lt
local lQ
local k7
local HttpService
local connection
local ld
local VirtualUser
local la
local lg
local lD
local kY
local lG
local lj
local lm
local k0
local connection2
local lp
local k3
local lM
local ls
local lw
local Toggles
local lz
local lV
local lf
local lY
local lF
local li
local k_
local CurrentCamera
local ll
local k2
local lL
local k5
local lr
local k8
local lR
local ly
local lU
local le
local Options
local function onCopyUSDTAddress()
    ly(lk, "Copied USDT address")
end
local function fn102()
    local Character = lt.Character
    local m5 = Character and Character:FindFirstChild("HumanoidRootPart")
    local m4_1 = m5
    if m5 then
        m5 = m4_1.Position.Y > 0
    end
    return m5
end
local function onCopySolanaAddress()
    ly(lh, "Copied Solana address")
end
local function fn212()
    local nC_1
    local nB_1
    if identifyexecutor then
        nC_1, nB_1 = identifyexecutor()
        local nD = nC_1 ~= ""
        local nE = type(nC_1) == "string" and nD
        if nE then
            local nD_1 = type(nB_1) == "string" and nB_1 ~= "" and nC_1 .. " " .. nB_1
            lz = nD_1 or nC_1
        end
    end
end
local function fn219()
    local m9_1
    local m8_1
    local Enemies = Workspace.Game:FindFirstChild("Enemies")
    if not Enemies then
        return nil
    end
    m9_1, m8_1 = nil, math.huge
    local na = lt.Character and lt.Character:FindFirstChild("HumanoidRootPart")
    if not na then
        return nil
    end
    for i, child in ipairs(Enemies:GetChildren()) do
        if child:IsA("Model") then
            local m7_1 = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChildOfClass("BasePart")
            if m7_1 then
                local Magnitude = (m7_1.Position - na.Position).Magnitude
                if Magnitude < m8_1 then
                    m9_1, m8_1 = m7_1, Magnitude
                end
            end
        end
    end
    return m9_1, m8_1
end
local function fn265(aZ)
    local DiscordGroup = aZ:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = lp })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = lp })
end
local function onCopyLitecoinAddress()
    ly(ls, "Copied Litecoin address")
end
local function fn418()
    return lt:FindFirstChild("Data")
end
local function worker()
    local nJ_1
    while true do
        task.wait(1)
        if k2.Unloaded then
            break
        end
        local nI = math.floor(os.clock() - k0)
        if nI < 60 then
            nJ_1 = nI .. "s"
        elseif nI < 3600 then
            nJ_1 = string.format("%dm %ds", math.floor((nI) / (60)), nI % 60)
        else
            nJ_1 = string.format("%dh %dm", math.floor((nI) / (3600)), math.floor((nI % 3600) / (60)))
        end
        lf:SetText(lY("Session time", nJ_1, lG))
    end
end
local function fn608()
    local mS = kZ()
    local mT = mS and mS:FindFirstChild("Money") and mS.Money.Value
    return mT or 0
end
local function onCopyVenmoLink()
    ly(la, "Copied Venmo link")
end
local function onCopyJoinScript_JobID()
    local nG = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, ld)
    if setclipboard then
        setclipboard(nG)
    elseif toclipboard then
        toclipboard(nG)
    end
    k2:Notify("Copied join script to clipboard")
end
local function onCopyEthereumAddress()
    ly(ln, "Copied Ethereum address")
end
local function fn704(aC, ...)
    if li then
        li:FireServer(aC, ...)
    end
end
local function fn747(a4, a5)
    return string.format('<font color="%s">%s</font>', a5, a4)
end
local function fn754(am)
    local Character = lt.Character
    local nk = Character and Character:FindFirstChild("HumanoidRootPart")
    if nk then
        nk.CFrame = CFrame.new(am)
    end
end
local function fn896(a7, a8, a9)
    return string.format("<b>%s</b> %s %s", a7, k3("-", "#5a6070"), k3(a8, a9))
end
local function onRscripts()
    if setclipboard then
        setclipboard(lD)
    elseif toclipboard then
        toclipboard(lD)
    end
    k2:Notify("Copied Rscripts profile to clipboard")
end
local function fn1033()
    ly(lF, "Copied Discord invite to clipboard")
end
local function fn1038()
    return getgenv().OURO_GEN == kW
end
local function fn1062(as)
    local nm = kZ()
    local nn = nm
    local no = {}
    if nn then
        nn = nm:FindFirstChild(as)
    end
    if nn then
        local nn_1 = nm[as]
        for i, child in ipairs(nn_1:GetChildren()) do
            local nm_1 = child:IsA("ValueBase") and child.Value
            if nm_1 then
                no[child.Name] = true
            end
        end
    end
    return no
end
local function onCopyBitcoinAddress()
    ly(lq, "Copied Bitcoin address")
end
local function onAutoSkip(co)
    lt:SetAttribute("AutoSkip", co)
end
local function onCopyPayPalLink()
    ly(le, "Copied PayPal link")
end
local function onMakeLobby(ci)
    if ci then
        lQ(k7)
    end
end
local function onGoToLobbyCircle()
    lQ(k7)
end
local function fn1155(aS, aT)
    if setclipboard then
        setclipboard(aS)
    elseif toclipboard then
        toclipboard(aS)
    end
    k2:Notify(aT)
end
local function fn1202()
    local mZ_1
    local mY_1
    mY_1, mZ_1 = pcall(require, lM.Modules.WeaponData)
    local mY_2 = mY_1 and mZ_1
    local m3 = if mY_2 then 1 else 0
    local m1 = 1834 * m3 + 3630 * (1 - m3)
    local m2 = 3871 * m3 + 3674 * (1 - m3)
    if not ((m1 * 1812 + m2 * 2304 + m1 * m2) % 16777213 == 2564193) then
        mY_2 = nil
    end
    return mY_2
end
kW = nil
kY = nil
kZ = nil
k_ = nil
k0 = nil
k2 = nil
k3 = nil
k5 = nil
k7 = nil
k8 = nil
la = nil
ld = nil
le = nil
lf = nil
lg = nil
lh = nil
li = nil
lj = nil
lk = nil
ll = nil
lm = nil
ln = nil
lp = nil
lq = nil
lr = nil
ls = nil
lt = nil
lw = nil
HttpService = nil
ly = nil
lz = nil
VirtualUser = nil
lB = nil
lD = nil
UserInputService = nil
lF = nil
lG = nil
connection3 = nil
CurrentCamera = nil
connection2 = nil
local kX, k1, k4, k6, k9, lb, lc, Events, ContextActionService, lC
Workspace = nil
lL = nil
lM = nil
lN = nil
lQ = nil
lR = nil
Toggles = nil
connection = nil
lU = nil
lV = nil
Options = nil
lY = nil
local lO, lP, lW, l0, l1, l2, l5, l6, l7, l8, l9, ma, mb, mc, md, me, mg, mh
local l4_1, l4_2, l4_5
if game.GameId ~= 10617896300 then
    return
end
pcall(function()
    setthreadidentity(8)
end)
local lZ = getgenv().OURO_GEN
local mA = if lZ then 1 else 0
local my = 3836 * mA + 3211 * (1 - mA)
local mz = 1516 * mA + 3692 * (1 - mA)
if not ((my * 1035 + mz * 1900 + my * mz) % 16777213 == 12666036) then
    lZ = 0
end
kW, lU = nil, nil
local l_ = 3
repeat
    l0 = { "mfcwkbszu", "dgwppawe", "qjshmbk", "uwrxdus", "gkwibcmn", "pmzw", "jlefgfktn", "kwk" }
    local rI = l_
    l1 = l0[rI % 8 + 1]
    if l1:len() >= l1:gsub("(.)", "%1%1", rI % 3 % 2 + 1):len() then
        lZ = lU + 1
        getgenv().OURO_GEN = lZ
        kW = fn1038
    else
        kW = lZ + 1
        getgenv().OURO_GEN = kW
        lU = fn1038
    end
    l_ = (l_ + 4) % 8
until (l_ * 1 + 3) % 8 == 2
local lZ_1 = {
    alive = function()
        return true
    end,
    onCleanup = function() end
}
l_ = getgenv().STATE or lZ_1
lP, lM, Workspace, UserInputService, VirtualUser, HttpService, ContextActionService, lt, lr, Events, l2 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
lP = l_
l1 = game:GetService("Players")
lM = game:GetService("ReplicatedStorage")
Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
ContextActionService = game:GetService("ContextActionService")
lt = l1.LocalPlayer
if ((l1 or Events) and (not l1 or not lM) and (not l1 and not Events and (not Events and UserInputService)) or (not lM or l1 or l2 and l2) and (l2 or not UserInputService or (not Events or not l1))) and (l1 and not l2 or lM and l2 or not UserInputService and UserInputService and (l2 or l2) or (UserInputService and not l1 or (lM or UserInputService) or (lM and not lM or (l1 or not UserInputService)))) or not (((l1 or Events) and (not l1 or not lM) and (not l1 and not Events and (not Events and UserInputService)) or (not lM or l1 or l2 and l2) and (l2 or not UserInputService or (not Events or not l1))) and (l1 and not l2 or lM and l2 or not UserInputService and UserInputService and (l2 or l2) or (UserInputService and not l1 or (lM or UserInputService) or (lM and not lM or (l1 or not UserInputService))))) then
    lr = lt
else
    lt = lr
end
Events = lM:WaitForChild("Events", 15)
l2 = Events and Events:FindFirstChild("ChangeValue")
local lZ_2 = Events
li = l2
if lZ_2 then
    lZ_2 = Events:FindFirstChild("ApplyTP")
end
lc, mc, k7, k6, k4, k1, l_, k2, mb, kY, Options, Toggles, lF, lD, l0, ma, l9, l8, lG, l7, lz, l1, l6, lf, ld, l4_1, kZ, lW, lO, lB, ll, lQ, lC, k9, md, ly, lp, l5, k3, lY = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
l2 = 68
repeat
    me = (l2 * 9 + 3) % 22 + 1
    if me <= 11 then
        if me <= 6 then
            if me <= 3 then
                if me <= 2 then
                    if me <= 1 then
                        if l2 * 98858821 + 11 + 6 >= l2 * 98858821 + 11 + 6 + 2 then
                            l1 = "Survive Anime Arena [ALPHA]"
                        else
                            mc = "Survive Anime Arena [ALPHA]"
                        end
                        l2 = (l2 + 27) % 88
                    else
                        local mf_1 = (vector.create((l2 * 6 + 3) % 11 + 1, (l2 * 2 + 4) % 13 + 1, (l2 * 8 + 6) % 17 + 1))
                        mg = (vector.create((l2 * 2 + 6) % 11 + 1, (l2 * 5 + 2) % 13 + 1, (l2 * 15 + 11) % 17 + 1))
                        local rU = vector.dot(mf_1, mg)
                        if rU * rU >= vector.dot(mf_1, mf_1) * vector.dot(mg, mg) + 1 then
                            kZ = Vector3.new(76, 380, 355)
                            k7 = {
                                EarthWarrior = 0,
                                HealerNinja = 1000,
                                ThunderSwordsman = 3000,
                                Hollow = 2500,
                                Dismantler = 10000,
                                ["Infinity User"] = 6500
                            }
                            k1 = {
                                Dismantler = 5,
                                ThunderSwordsman = 3,
                                Hollow = 3,
                                HealerNinja = 2,
                                ["Infinity User"] = 4,
                                EarthWarrior = 2
                            }
                            k4 = {
                                PurpleAssasin = 2000,
                                BlackFlashAura = 800,
                                DismantleAura = 10000,
                                Crimson = 600,
                                LavaAura = 900,
                                Infinity = 3000,
                                BlueFlames = 1000,
                                Solar = 1500,
                                Lightning = 500
                            }
                            k6 = fn418
                        else
                            k7 = Vector3.new(76, 380, 355)
                            k6 = {
                                EarthWarrior = 0,
                                HealerNinja = 1000,
                                Hollow = 2500,
                                ThunderSwordsman = 3000,
                                ["Infinity User"] = 6500,
                                Dismantler = 10000
                            }
                            k4 = {
                                EarthWarrior = 2,
                                HealerNinja = 2,
                                Hollow = 3,
                                ThunderSwordsman = 3,
                                ["Infinity User"] = 4,
                                Dismantler = 5
                            }
                            k1 = {
                                Lightning = 500,
                                Crimson = 600,
                                BlackFlashAura = 800,
                                LavaAura = 900,
                                BlueFlames = 1000,
                                Solar = 1500,
                                PurpleAssasin = 2000,
                                Infinity = 3000,
                                DismantleAura = 10000
                            }
                            kZ = fn418
                        end
                        l2 = (l2 + 5) % 88
                    end
                else
                    local mf_2 = {
                        "dzogxwix",
                        "efgx",
                        "nkusovxvnnl",
                        "xtvzqtvpillc",
                        "lujwfvnlwn",
                        "xrpdsrmo",
                        "czxzaw",
                        "bimrfqyybltd",
                        "fomyp",
                        "batcxcjwmld",
                        "ewfpvfbtt",
                        "gpfbzgq",
                        "lcfxbjs",
                        "shjsvwkqy",
                        "gmizpozsfxs",
                        "eugvqmlz"
                    }
                    if mf_2[(l2 * 5 + 39) % 16 + 1] < mf_2[(l2 * 5 + 39) % 16 + 1] then
                        lQ = fn608
                        lB = fn1202
                        lO = fn102
                        lW = fn219
                        ll = fn754
                    else
                        lW = fn608
                        lO = fn1202
                        lB = fn102
                        ll = fn219
                        lQ = fn754
                    end
                    l2 = (l2 + 27) % 88
                end
            elseif me <= 5 then
                if me <= 4 then
                    local mf_3 = {
                        "fjwelf",
                        "uwidjfcbpup",
                        "bdussapdcbq",
                        "vyjtdk",
                        "canpjdeat",
                        "lcrxde",
                        "xlsdcezgdaz",
                        "xbqiklow",
                        "lggdsy",
                        "hahdlyvf"
                    }
                    local r2 = l2
                    mg = mf_3[r2 % 10 + 1]
                    if mg:len() >= mg:gsub("(.)", "%1%1", r2 % 3 % 2 + 1):len() then
                        k9 = fn1062
                        lC = fn704
                    else
                        lC = fn1062
                        k9 = fn704
                    end
                    l2 = (l2 + 49) % 88
                else
                    local mf_4 = (vector.create((l2 * 4 + 7) % 11 + 1, (l2 * 5 + 2) % 13 + 1, (l2 * 12 + 13) % 17 + 1))
                    mg = (vector.create((l2 * 2 + 3) % 11 + 1, (l2 * 2 + 5) % 13 + 1, (l2 * 8 + 15) % 17 + 1))
                    local rt = vector.dot(mf_4, mg)
                    if rt * rt <= vector.dot(mf_4, mf_4) * vector.dot(mg, mg) then
                        l_ = ""
                    else
                        lW = ""
                    end
                    l2 = (l2 + 49) % 88
                end
            else
                local mf_5 = { "tjnosziqw", "aontcptnqp", "jpjrpohm", "ylnmzcdg", "wbgbdbzl", "ueqhgfhd", "zpia", "aciiuqlpdsk" }
                local rZ = l2
                mg = mf_5[rZ % 8 + 1]
                if mg:len() >= mg:gsub("(.)", "%1%1", rZ % 3 % 2 + 1):len() then
                    l_ = getgenv().Library
                else
                    k2 = getgenv().Library
                end
                l2 = (l2 + 27) % 88
            end
        elseif me <= 9 then
            if me <= 8 then
                if me <= 7 then
                    local rQ = bit32.rrotate(bit32.bxor(bit32.lrotate(l2, 20), string.byte(tostring(lW))), 28)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(rQ, 689730519), 24), 3609795699) == bit32.lrotate(rQ, 24) then
                        mb = getgenv().ThemeManager
                    else
                        l_ = getgenv().ThemeManager
                    end
                    l2 = (l2 + 27) % 88
                else
                    local mf_6 = {
                        "sjwyqfacgqr",
                        "hovokazilsv",
                        "ljwaozh",
                        "dvcwfx",
                        "rjqlkydqsfbi",
                        "kmpdkdpczf",
                        "atgfbprnzkdg",
                        "eymhau",
                        "ntekosgoig",
                        "tdqvdrfptiy",
                        "yaqlcjis",
                        "kmnotavywxk",
                        "mxrz",
                        "bsqwy",
                        "rrdzixwec",
                        "uernjz"
                    }
                    if mf_6[(l2 * 33 + 27) % 16 + 1] < mf_6[(l2 * 33 + 27) % 16 + 1] then
                        l_ = getgenv().SaveManager
                    else
                        kY = getgenv().SaveManager
                    end
                    l2 = (l2 + 71) % 88
                end
            else
                if l2 * 106995323 + 8 + 2 >= l2 * 106995323 + 8 + 2 + 3 then
                    k2 = Options.Options
                else
                    Options = k2.Options
                end
                l2 = (l2 + 71) % 88
            end
        elseif me <= 10 then
            local rx = bit32.rrotate(bit32.bxor(bit32.lrotate(l2, 15), string.byte(tostring(l7))), 8)
            if bit32.bxor(bit32.lrotate(bit32.bxor(rx, 1870966182), 30), 2615225193) ~= bit32.lrotate(rx, 30) then
                k2 = Toggles.Toggles
            else
                Toggles = k2.Toggles
            end
            l2 = (l2 + 5) % 88
        else
            local mf_7 = (vector.create((l2 * 6 + 6) % 11 + 1, (l2 * 2 + 6) % 13 + 1, (l2 * 12 + 8) % 17 + 1))
            mg = (vector.create((l2 * 2 + 6) % 11 + 1, (l2 * 9 + 1) % 13 + 1, (l2 * 1 + 16) % 17 + 1))
            local rO = vector.dot(mf_7, mg)
            if rO * rO <= vector.dot(mf_7, mf_7) * vector.dot(mg, mg) then
                md = function(aL)
                    pcall(function()
                        k2:Notify(aL)
                    end)
                end
            else
                l6 = function(aL)
                    pcall(function()
                        k2:Notify(aL)
                    end)
                end
            end
            l2 = (l2 + 27) % 88
        end
    elseif me <= 17 then
        if me <= 14 then
            if me <= 13 then
                if me <= 12 then
                    local mf_8 = (vector.create((l2 * 1 + 6) % 11 + 1, (l2 * 9 + 9) % 13 + 1, (l2 * 13 + 5) % 17 + 1))
                    mg = (vector.create((l2 * 3 + 3) % 11 + 1, (l2 * 4 + 13) % 13 + 1, (l2 * 3 + 16) % 17 + 1))
                    mh = (vector.create((l2 * 4 + 7) % 5 + 1, (l2 * 3 + 7) % 7 + 1, (l2 * 3 + 7) % 9 + 1))
                    if math.abs((vector.angle(mf_8, mg, mh))) - math.abs((vector.angle(mg, mf_8, mh))) == 0 then
                        lF = "https://discord.gg/K7Qxnxkk46"
                    else
                        mb = "https://discord.gg/K7Qxnxkk46"
                    end
                    l2 = (l2 + 49) % 88
                else
                    local rG = bit32.rrotate(bit32.bxor(bit32.lrotate(l2, 9), string.byte(tostring(k7))), 10)
                    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(rG, 87004493), 2363900422), (bit32.bxor(bit32.band(rG, 4207962802), 3664818214))), 2363900422), 3664818214) ~= rG then
                        ly = "https://discord.gg/K7Qxnxkk46"
                        lD = fn1155
                    else
                        lD = "https://discord.gg/K7Qxnxkk46"
                        ly = fn1155
                    end
                    l2 = (l2 + 27) % 88
                end
            else
                local mf_9 = (vector.create((l2 * 4 + 1) % 11 + 1, (l2 * 5 + 8) % 13 + 1, (l2 * 1 + 14) % 17 + 1))
                mg = (vector.create((l2 * 5 + 3) % 11 + 1, (l2 * 3 + 11) % 13 + 1, (l2 * 14 + 6) % 17 + 1))
                mh = (vector.create((l2 * 2 + 6) % 11 + 1, (l2 * 9 + 7) % 13 + 1, (l2 * 11 + 13) % 17 + 1))
                if vector.dot(vector.cross(mf_9, mg), mh) == vector.dot(vector.cross(mg, mh), mf_9) then
                    lp = fn1033
                    l5 = fn265
                else
                    l5 = fn1033
                    lp = fn265
                end
                l2 = (l2 + 5) % 88
            end
        elseif me <= 16 then
            if me <= 15 then
                local rv = bit32.rrotate(bit32.bxor(bit32.lrotate(l2, 21), string.byte(tostring(l0))), 11)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(rv, 2548123019), 1742080353), (bit32.bxor(bit32.band(rv, 1746844276), 1808369993))), 1742080353), 1808369993) ~= rv then
                    k2 = l0:CreateWindow({
                        CornerRadius = 0,
                        ShowCustomCursor = false,
                        Footer = { { Text = mc, Copyable = true }, lF, "|" },
                        NotifySide = "Right",
                        Title = "Tempo",
                        Font = Enum.Font.BuilderSans,
                        Icon = 78539693571783
                    })
                else
                    l0 = k2:CreateWindow({
                        Title = "Tempo",
                        Font = Enum.Font.BuilderSans,
                        Footer = { { Text = lF, Copyable = true }, "|", mc },
                        Icon = 78539693571783,
                        NotifySide = "Right",
                        ShowCustomCursor = false,
                        CornerRadius = 0
                    })
                end
                l2 = (l2 + 71) % 88
            else
                local rE = bit32.rrotate(bit32.bxor(bit32.lrotate(l2, 23), string.byte(tostring(ld))), 15)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(rE, 1905124179), 2399967973), (bit32.bxor(bit32.band(rE, 2389843116), 3526816664))), 2399967973), 3526816664) ~= rE then
                    l0 = {
                        Settings = ma:AddTab("Settings", "settings"),
                        Farming = ma:AddTab("Farming", "swords"),
                        Info = ma:AddTab("Info", "info"),
                        Player = ma:AddTab("Player", "person-standing"),
                        Inventory = ma:AddTab("Inventory", "package")
                    }
                else
                    ma = {
                        Info = l0:AddTab("Info", "info"),
                        Farming = l0:AddTab("Farming", "swords"),
                        Inventory = l0:AddTab("Inventory", "package"),
                        Player = l0:AddTab("Player", "person-standing"),
                        Settings = l0:AddTab("Settings", "settings")
                    }
                end
                l2 = (l2 + 49) % 88
            end
        else
            local mf_10 = {
                "ecctxam",
                "lrcf",
                "dau",
                "awqwuoj",
                "hbugsozftqp",
                "zmhzqcvdp",
                "ybwdr",
                "ecuzcax",
                "zsjcubenmv",
                "jafevtazold",
                "aumldiyolj"
            }
            local rN = l2
            mg = mf_10[rN % 11 + 1]
            if mg:len() >= mg:reverse():rep(rN % 3 + 2):len() then
                lY = fn747
            else
                k3 = fn747
            end
            l2 = (l2 + 49) % 88
        end
    elseif me <= 20 then
        if me <= 19 then
            if me <= 18 then
                local mf_11 = {
                    "qniha",
                    "ykgav",
                    "tsjnehtd",
                    "yqec",
                    "lcq",
                    "suvhrphkqs",
                    "zehpilif",
                    "khfkwlujz",
                    "eqncvsehtzn",
                    "vksguuftc"
                }
                local rw = l2
                mg = mf_11[rw % 10 + 1]
                mA = if mg:len() >= mg:reverse():rep(rw % 3 + 2):len() then 1 else 0
                if mA == 1 then
                    l0 = fn896
                else
                    lY = fn896
                end
                l2 = (l2 + 5) % 88
            else
                local mf_12 = {
                    "eulfq",
                    "zgxnggqbkzk",
                    "kimnfhpgx",
                    "scqqlpt",
                    "ngtfc",
                    "otmjpror",
                    "xfzdjmuuv",
                    "xhuvgvlvq",
                    "ucusifhnfij",
                    "tkub",
                    "heqbeffgsd"
                }
                local ru = l2
                mg = mf_12[ru % 11 + 1]
                if mg:len() >= mg:gsub("(.)", "%1%1", ru % 3 % 2 + 1):len() then
                    l6, l9, lY, lz = "#e8a34d", "#8b93a3", "#6ec1ff", "#7fd47f"
                    k3 = "Unknown"
                    pcall(fn212)
                    ma = lr.Info:AddLeftGroupbox("Account", "circle-user")
                    ma:AddLabel(mc("User", l1.Name, lz), true)
                    ma:AddLabel(mc("Status", "Keyless", lz), true)
                    ma:AddLabel(mc("Executor", k3, lz), true)
                    lf = lr.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                    lf:AddLabel(l7(lG .. " [" .. tostring(game.PlaceId) .. "]", lY), true)
                    lf:AddLabel(mc("Place ID", tostring(game.PlaceId), lY), true)
                    l8 = lf:AddLabel(mc("Session time", "0s", l6), true)
                else
                    l9, l8, lG, l7 = "#7fd47f", "#6ec1ff", "#e8a34d", "#8b93a3"
                    lz = "Unknown"
                    pcall(fn212)
                    l1 = ma.Info:AddLeftGroupbox("Account", "circle-user")
                    l1:AddLabel(lY("User", lr.Name, l9), true)
                    l1:AddLabel(lY("Status", "Keyless", l9), true)
                    l1:AddLabel(lY("Executor", lz, l9), true)
                    l6 = ma.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                    l6:AddLabel(k3(mc .. " [" .. tostring(game.PlaceId) .. "]", l8), true)
                    l6:AddLabel(lY("Place ID", tostring(game.PlaceId), l8), true)
                    lf = l6:AddLabel(lY("Session time", "0s", lG), true)
                end
                l2 = (l2 + 71) % 88
            end
        else
            local mf_13 = {
                "ivrhugvflh",
                "khwqjud",
                "zlawgoveq",
                "hviu",
                "ncsd",
                "prijhxpk",
                "gxt",
                "lspbu",
                "imaelz",
                "lllmdf",
                "pfhmljjrzpa"
            }
            local rJ = l2
            mg = mf_13[rJ % 11 + 1]
            if mg:len() >= mg:reverse():rep(rJ % 3 + 2):len() then
                lW = tostring(game.JobId)
            else
                ld = tostring(game.JobId)
            end
            l2 = (l2 + 49) % 88
        end
    elseif me <= 21 then
        me = {
            "ehxmvasrq",
            "usyuhyvp",
            "awpisxwodpf",
            "uglvjgpbauwv",
            "kkffcxgnth",
            "pnyoifrzbzij",
            "eeytxrbpjb",
            "ccoeebxqvxhj",
            "eurovqzek",
            "aplc"
        }
        if me[(l2 * 37 + 63) % 10 + 1] <= me[(l2 * 37 + 63) % 10 + 1] then
            l4_1 = #ld > 18
        else
            ld = #l4_1 > 18
        end
        l2 = (l2 + 5) % 88
    else
        me = {
            "qlppv",
            "nachw",
            "yqvfhwl",
            "qpqisidah",
            "bmvvg",
            "rrfxdrlsly",
            "zguxtlja",
            "zibdqhjvpp",
            "krcszf",
            "hrkt"
        }
        local rF = l2
        local mf_14 = me[rF % 10 + 1]
        if mf_14:len() <= mf_14:gsub("(.)", "%1%1", rF % 3 % 2 + 1):len() then
            lc = lZ_2
        else
            lZ_2 = lc
        end
        l2 = (l2 + 49) % 88
    end
until (l2 * 57 + 23) % 88 == 49
if l4_1 then
    local lZ_3 = 2
    repeat
        l_ = (vector.create((lZ_3 * 4 + 1) % 11 + 1, (lZ_3 * 7 + 3) % 13 + 1, (lZ_3 * 14 + 14) % 17 + 1))
        l0 = (vector.create((lZ_3 * 5 + 9) % 11 + 1, (lZ_3 * 10 + 13) % 13 + 1, (lZ_3 * 10 + 16) % 17 + 1))
        l1 = (vector.create((lZ_3 * 4 + 1) % 11 + 1, (lZ_3 * 5 + 6) % 13 + 1, (lZ_3 * 3 + 14) % 17 + 1))
        l2 = (vector.create((lZ_3 * 4 + 3) % 5 + 1, (lZ_3 * 1 + 4) % 7 + 1, (lZ_3 * 4 + 3) % 9 + 1))
        if vector.dot(vector.cross(l_, (vector.cross(l0, l1))), l2) == vector.dot(l0 * vector.dot(l_, l1) - l1 * vector.dot(l_, l0), l2) + 3 then
            ld = string.sub(l4_1, 1, 18) .. "..."
        else
            l4_1 = string.sub(ld, 1, 18) .. "..."
        end
        lZ_3 = (lZ_3 + 1) % 8
    until (lZ_3 * 3 + 0) % 8 == 1
end
local lZ_4 = l4_1 or ld
k0, ls, lq, ln, lk, lh, le, la, mg, l1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
l6:AddLabel(lY("Server", lZ_4, l7), true)
l6:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
k0 = os.clock()
task.spawn(worker)
local ScriptsGroup = ma.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(k3("Included in this hub", l7), true)
ScriptsGroup:AddLabel(k3(mc, l8), true)
local FeaturesGroup = ma.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(k3("Auto Lobby & Combat", l8), true)
FeaturesGroup:AddLabel(k3("Auto Buy & Equip", lG), true)
FeaturesGroup:AddLabel(k3("Auto Upgrades", l9), true)
FeaturesGroup:AddLabel(k3("Player Movement", l7), true)
local SocialsGroup = ma.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = lp })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = ma.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = lp })
ls = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
if (SocialsGroup and lq or not l1 and mg or (lq or not lq) and (mg and mg) or (not SocialsGroup or not SocialsGroup or (l1 or not SocialsGroup)) and (l1 and not mg and (not SocialsGroup and l1)) or ((not mg or not lq) and (not l1 and not SocialsGroup) or l1 and lq and (lq and not mg) or ((l1 or not SocialsGroup) and (not l1 and mg) or (lq or not SocialsGroup) and (not SocialsGroup or not l1)))) and not (SocialsGroup and lq or not l1 and mg or (lq or not lq) and (mg and mg) or (not SocialsGroup or not SocialsGroup or (l1 or not SocialsGroup)) and (l1 and not mg and (not SocialsGroup and l1)) or ((not mg or not lq) and (not l1 and not SocialsGroup) or l1 and lq and (lq and not mg) or ((l1 or not SocialsGroup) and (not l1 and mg) or (lq or not SocialsGroup) and (not SocialsGroup or not l1)))) then
    ln = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
    lq = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
else
    lq = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
    ln = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
end
lk = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
lh = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
le = ""
la = ""
mg, me, l4_2, l2, l1, l0, l_ = "#345d9d", "#f7931a", "#627eea", "#26a17b", "#14f195", "#0070ba", "#008cff"
local DonationsGroup = ma.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(k3("All donations are optional but appreciated.", lG), true)
DonationsGroup:AddLabel(k3("If you donate you get a special role, just PING after you donate.", l9), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(k3("LTC / Litecoin", mg), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(k3("BTC / Bitcoin", me), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(k3("ETH / Ethereum", l4_2), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(k3("USDT", l2), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(k3("Solana", l1), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(k3("PayPal", l0), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(k3("Venmo", l_), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(k3("Don't have any of the listed currencies but still wanna donate?", l7), true)
DonationsGroup:AddLabel(k3("DM me and we'll work something out.", l8), true)
mh = ma.Info:AddRightGroupbox("FAQ", "circle-help")
mh:AddLabel("Where do I get a good config?", true)
mh:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
mh:AddLabel("How do I import / export configs?", true)
mh:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
mh:AddLabel("How do I report bugs?", true)
mh:AddLabel("Join the Discord and post it in the bugs channel.", true)
mh:AddLabel("How do I make suggestions?", true)
mh:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
mh:AddLabel("How do I get help or updates?", true)
mh:AddLabel("Join the Discord, updates and support are posted there first.", true)
ma.Farming:SetSubTabAlignment("Center")
local mo = ma.Farming:AddSubTab("Lobby", "log-in")
local mp = ma.Farming:AddSubTab("Combat", "crosshair")
ma.Inventory:SetSubTabAlignment("Center")
local mq = ma.Inventory:AddSubTab("Purchases", "shopping-cart")
local mr = ma.Inventory:AddSubTab("Equipment", "shirt")
local ms = ma.Inventory:AddSubTab("Upgrades", "trending-up")
l5(mo)
l5(mp)
l5(mq)
l5(mr)
l5(ms)
l5(ma.Player)
local MatchmakingGroup = mo:AddLeftGroupbox("Matchmaking", "users")
MatchmakingGroup:AddToggle("MakeLobby", { Text = "Auto Make/Start Lobby", Default = false, Callback = onMakeLobby })
MatchmakingGroup:AddSlider("LobbyInterval", { Text = "Interval", Default = 3, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
MatchmakingGroup:AddToggle("NightmareMode", { Text = "Nightmare Mode", Default = false })
MatchmakingGroup:AddButton({ Text = "Go to Lobby Circle", Func = onGoToLobbyCircle })
l_, l1, l0 = nil, nil, nil
local lZ_5 = 10
repeat
    l2 = (lZ_5 * 2 + 2) % 3 + 1
    if l2 <= 2 then
        if l2 <= 1 then
            l2 = {
                "bkmi",
                "cpblh",
                "xaivzgcwegg",
                "xpuvqjxsxb",
                "vadvb",
                "ignzwy",
                "nhxappve",
                "luqab",
                "gmtwrxvudfo",
                "irxqinnqlzk",
                "qefgxdbl"
            }
            local rk = lZ_5
            local l4_3 = l2[rk % 11 + 1]
            if l4_3:len() >= l4_3:gsub("(.)", "%1%1", rk % 3 % 2 + 1):len() then
                l0:AddToggle("AutoAbility", { Text = "Auto Use Ability", Default = false })
                l1 = {}
            else
                l1:AddToggle("AutoAbility", { Text = "Auto Use Ability", Default = false })
                l0 = {}
            end
            lZ_5 = (lZ_5 + 2) % 24
        else
            l2 = (vector.create((lZ_5 * 2 + 5) % 11 + 1, (lZ_5 * 2 + 10) % 13 + 1, (lZ_5 * 7 + 8) % 17 + 1))
            local l4_4 = (vector.create((lZ_5 * 6 + 1) % 11 + 1, (lZ_5 * 2 + 9) % 13 + 1, (lZ_5 * 2 + 3) % 17 + 1))
            l5 = (vector.create((lZ_5 * 1 + 2) % 11 + 1, (lZ_5 * 11 + 2) % 13 + 1, (lZ_5 * 9 + 2) % 17 + 1))
            if vector.dot(vector.cross(l2, l4_4), l5) == vector.dot(vector.cross(l4_4, l5), l2) then
                l_ = mp:AddLeftGroupbox("Combat Loop", "crosshair")
            else
                mp = l_:AddLeftGroupbox("Combat Loop", "crosshair")
            end
            lZ_5 = (lZ_5 + 11) % 24
        end
    else
        if lZ_5 * 48552603 + 13 + 1 <= lZ_5 * 48552603 + 13 + 1 + 2 then
            l_:AddToggle("Orbit", { Text = "Auto Orbit Enemies", Default = false })
            l_:AddToggle("AutoEquipTool", { Text = "Auto Equip Weapon", Default = true })
            l_:AddToggle("AutoShoot", { Text = "Auto Shoot", Default = false })
            l_:AddSlider("OrbitDistance", { Text = "Orbit Distance", Default = 12, Min = 3, Max = 50, Rounding = 1, Suffix = " studs" })
            l_:AddSlider("OrbitHeight", { Text = "Orbit Height", Default = 6, Min = -10, Max = 30, Rounding = 1, Suffix = " studs" })
            l_:AddSlider("OrbitSpeed", { Text = "Orbit Speed", Default = 1.5, Min = 0.1, Max = 10, Rounding = 1, Suffix = " rad/s" })
            l_:AddToggle("AutoSkip", { Text = "Auto Skip Wave", Default = false, Callback = onAutoSkip })
            l_:AddButton({
                Text = "Skip Wave Now",
                Func = function()
                    local nU = Events and Events:FindFirstChild("VoteSkipEvent")
                    local nT = nU
                    if nT then
                        pcall(function()
                            nT:FireServer()
                        end)
                    end
                end
            })
            l1 = mp:AddRightGroupbox("Abilities", "zap")
        else
            l1:AddToggle("Orbit", { Text = "Auto Orbit Enemies", Default = false })
            l1:AddToggle("AutoEquipTool", { Text = "Auto Equip Weapon", Default = true })
            l1:AddToggle("AutoShoot", { Text = "Auto Shoot", Default = false })
            l1:AddSlider("OrbitDistance", { Max = 50, Rounding = 1, Text = "Orbit Distance", Min = 3, Suffix = " studs", Default = 12 })
            l1:AddSlider("OrbitHeight", { Rounding = 1, Default = 6, Text = "Orbit Height", Min = -10, Suffix = " studs", Max = 30 })
            l1:AddSlider("OrbitSpeed", { Rounding = 1, Max = 10, Text = "Orbit Speed", Suffix = " rad/s", Default = 1.5, Min = 0.1 })
            l1:AddToggle("AutoSkip", { Default = false, Callback = onAutoSkip, Text = "Auto Skip Wave" })
            l1:AddButton({
                Text = "Skip Wave Now",
                Func = function()
                    local nU = Events and Events:FindFirstChild("VoteSkipEvent")
                    local nT = nU
                    if nT then
                        pcall(function()
                            nT:FireServer()
                        end)
                    end
                end
            })
            mp = l_:AddRightGroupbox("Abilities", "zap")
        end
        lZ_5 = (lZ_5 + 8) % 24
    end
until (lZ_5 * 11 + 1) % 24 == 6
l6, l7, l5, l4_5 = nil, nil, nil, nil
l2 = 9
repeat
    local lZ_6 = (l2 * 1 + 1) % 3 + 1
    if lZ_6 <= 2 then
        if lZ_6 <= 1 then
            if (l5 and not l7 or (not l4_5 or l5)) and (not l2 or not l2 or (l5 or not l4_5)) and not ((l5 and not l7 or (not l4_5 or l5)) and (not l2 or not l2 or (l5 or not l4_5))) then
                l6 = l4_5
            else
                l4_5 = l6
            end
            l2 = (l2 + 10) % 12
        else
            local lZ_7 = { "wzqrgapwzu", "fvxpkdwov", "uwzvrdouu", "uqsyqulfs", "jwsuph", "ukzwb", "lopavsmev" }
            local rA = l2
            l_ = lZ_7[rA % 7 + 1]
            if l_:len() >= l_:gsub("(.)", "%1%1", rA % 3 % 2 + 1):len() then
                lM, l6 = pcall(require, l7.Modules.ClassData)
            else
                l6, l7 = pcall(require, lM.Modules.ClassData)
            end
            l2 = (l2 + 4) % 12
        end
    else
        local r3 = bit32.rrotate(bit32.bxor(bit32.lrotate(l2, 26), string.byte(tostring(l6))), 9)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(r3, 2335940359), 1558950638), (bit32.bxor(bit32.band(r3, 1959026936), 1163629658))), 1558950638), 1163629658) == r3 then
            l5 = kZ()
        else
            kZ = l5()
        end
        l2 = (l2 + 10) % 12
    end
until (l2 * 5 + 2) % 12 == 11
if l4_5 then
    l4_5 = l7
end
if l4_5 then
    l4_5 = l7.Classes
end
local lZ_8 = l4_5
if lZ_8 then
    l_ = l5 and l5:FindFirstChild("CurClass") and l5.CurClass.Value
    l2 = l_ or "EarthWarrior"
    lZ_8 = l2
end
l_ = lZ_8 or nil
local lZ_9 = l6
l2 = l_
if lZ_9 then
    lZ_9 = l7
end
if lZ_9 then
    lZ_9 = l7.Classes
end
if lZ_9 then
    lZ_9 = l2
end
if lZ_9 then
    l_ = 1
    repeat
        local l4_6 = (vector.create((l_ * 7 + 3) % 11 + 1, (l_ * 6 + 3) % 13 + 1, (l_ * 15 + 2) % 17 + 1))
        l5 = (vector.create((l_ * 5 + 1) % 11 + 1, (l_ * 8 + 11) % 13 + 1, (l_ * 8 + 16) % 17 + 1))
        l6 = (vector.create((l_ * 4 + 1) % 5 + 1, (l_ * 2 + 6) % 7 + 1, (l_ * 3 + 1) % 9 + 1))
        if math.abs((vector.angle(l4_6, l5, l6))) - math.abs((vector.angle(l5, l4_6, l6))) == 0 then
            lZ_9 = l7.Classes[l2]
        else
            l2 = lZ_9.Classes[l7]
        end
        l_ = (l_ + 3) % 4
    until (l_ * 3 + 0) % 4 == 0
end
local l4_7 = lZ_9
if l4_7 then
    local mG = 1
    while mG <= 3 do
        local mH = mG
        local lZ_10 = l4_7[mH]
        if lZ_10 then
            l0[#l0 + 1] = string.format("%d - %s (%d tk)", mH, tostring(lZ_10.Name), lZ_10.Cost)
        end
        mG += 1
    end
end
if #l0 == 0 then
    local lZ_11 = 3
    repeat
        if lZ_11 * 7154405 + 3 + 3 >= lZ_11 * 7154405 + 3 + 3 + 1 then
            l0 = { "1", "2", "3" }
        else
            l0 = { "1", "2", "3" }
        end
        lZ_11 = (lZ_11 + 0) % 4
    until (lZ_11 * 1 + 1) % 4 == 0
end
l1:AddDropdown("AbilityMove", { Values = l0, Multi = true, Text = "Moves", Searchable = true })
l1:AddSlider("AbilityInterval", { Text = "Interval", Default = 2, Min = 0.5, Max = 30, Rounding = 1, Suffix = "s" })
l1:AddSlider("AbilityMinTokens", { Text = "Min Tokens", Default = 25, Min = 0, Max = 500, Rounding = 0, Suffix = " tk" })
l_ = mp:AddRightGroupbox("Arena Upgrades", "trending-up")
l_:AddToggle("AutoUpDMG", { Text = "Auto Upgrade Attack", Default = false })
l_:AddToggle("AutoUpHP", { Text = "Auto Upgrade Health", Default = false })
l_:AddToggle("AutoUpTier", { Text = "Auto Upgrade Tier", Default = false })
l_:AddSlider("UpInterval", { Text = "Interval", Default = 5, Min = 1, Max = 30, Rounding = 1, Suffix = "s" })
local lZ_12 = {}
l_ = lO()
l0 = l_ and l_.Weapons
if l0 then
    for k, v in pairs(l_.Weapons) do
        l_ = type(v) == "table" and v.Cost ~= nil
        if l_ then
            table.insert(lZ_12, k)
        end
    end
    table.sort(lZ_12)
end
l_ = mq:AddLeftGroupbox("Auto Buy", "shopping-cart")
if (not l_ or not l_ or false) and 11 or not ((not l_ or not l_ or false) and 11) then
    l_:AddToggle("AutoBuyWeapons", { Text = "Auto Buy Weapons", Default = false })
    l_:AddDropdown("BuyWeaponList", {
        Values = lZ_12,
        Default = 1,
        Multi = true,
        Searchable = true,
        Text = "Weapons",
        Expandable = true,
        ExpandColumns = 2
    })
    l_:AddToggle("AutoBuyClasses", { Text = "Auto Buy Classes", Default = false })
    l_:AddDropdown("BuyClassList", {
        Values = { "HealerNinja", "Hollow", "ThunderSwordsman", "Infinity User", "Dismantler" },
        Default = 1,
        Multi = true,
        Searchable = true,
        Text = "Classes",
        Expandable = true,
        ExpandColumns = 2
    })
    l_:AddToggle("AutoBuyAuras", { Text = "Auto Buy Auras", Default = false })
    l_:AddDropdown("BuyAuraList", {
        Values = {
            "Lightning",
            "Crimson",
            "BlackFlashAura",
            "LavaAura",
            "BlueFlames",
            "Solar",
            "PurpleAssasin",
            "Infinity",
            "DismantleAura"
        },
        Default = 1,
        Multi = true,
        Searchable = true,
        Text = "Auras",
        Expandable = true,
        ExpandColumns = 2
    })
else
    lZ_12:AddToggle("AutoBuyWeapons", { Text = "Auto Buy Weapons", Default = false })
    lZ_12:AddDropdown("BuyWeaponList", {
        Multi = true,
        Values = l_,
        Default = 1,
        Searchable = true,
        ExpandColumns = 2,
        Expandable = true,
        Text = "Weapons"
    })
    lZ_12:AddToggle("AutoBuyClasses", { Text = "Auto Buy Classes", Default = false })
    lZ_12:AddDropdown("BuyClassList", {
        Values = { "Hollow", "HealerNinja", "Dismantler", "ThunderSwordsman", "Infinity User" },
        ExpandColumns = 2,
        Default = 1,
        Text = "Classes",
        Expandable = true,
        Multi = true,
        Searchable = true
    })
    lZ_12:AddToggle("AutoBuyAuras", { Text = "Auto Buy Auras", Default = false })
    lZ_12:AddDropdown("BuyAuraList", {
        Multi = true,
        Searchable = true,
        Values = {
            "BlueFlames",
            "Infinity",
            "Lightning",
            "DismantleAura",
            "Solar",
            "LavaAura",
            "Crimson",
            "BlackFlashAura",
            "PurpleAssasin"
        },
        ExpandColumns = 2,
        Default = 1,
        Text = "Auras",
        Expandable = true
    })
end
l1 = mr:AddLeftGroupbox("Auto Equip Best", "star")
l1:AddToggle("AutoEquipWeapon", { Text = "Auto Equip Best Weapon", Default = false })
l1:AddToggle("AutoEquipClass", { Text = "Auto Equip Best Class", Default = false })
l1:AddToggle("AutoEquipAura", { Text = "Auto Equip Best Aura", Default = false })
l_ = ms:AddLeftGroupbox("Weapon Upgrades", "trending-up")
l_:AddToggle("AutoUpgradeWeapon", { Text = "Auto Upgrade Weapon", Default = false })
l_:AddSlider("UpgradeInterval", { Text = "Interval", Default = 2, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
local MovementGroup = ma.Player:AddRightGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = ma.Player:AddLeftGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
lw = function()
    local Character = lr.Character
    local nX = Character and Character:FindFirstChildOfClass("Humanoid")
    return nX
end
lm = function()
    local Character = lr.Character
    local n2 = Character and Character:FindFirstChild("HumanoidRootPart")
    return n2
end
RunService.Stepped:Connect(function()
    if k2.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = lr.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local n4_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if n4_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end)
UserInputService.JumpRequest:Connect(function()
    if k2.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local of_1 = lw()
        if of_1 then
            of_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
CurrentCamera = workspace.CurrentCamera
RunService.RenderStepped:Connect(function(de)
    if k2.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local oh_1 = lw()
        if oh_1 then
            oh_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local oh_3 = lm()
        local oi = lw()
        if oh_3 and oi then
            oi.PlatformStand = true
            local oi_1 = Vector3.zero
            local oo = if UserInputService:IsKeyDown(Enum.KeyCode.W) then 1 else 0
            if oo == 1 then
                oi_1 = oi_1 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                oi_1 = oi_1 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                oi_1 = oi_1 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                oi_1 = oi_1 + CurrentCamera.CFrame.RightVector
            end
            local oo_1 = if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
            if oo_1 == 1 then
                oi_1 = oi_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                oi_1 = oi_1 - Vector3.new(0, 1, 0)
            end
            oh_3.Velocity = Vector3.zero
            if oi_1.Magnitude > 0 then
                oh_3.CFrame = oh_3.CFrame + oi_1.Unit * Options.FlySpeed.Value * de
            end
        end
    end
end)
Toggles.Fly:OnChanged(function()
    if not Toggles.Fly.Value then
        local op = lw()
        if op then
            op.PlatformStand = false
        end
    end
end)
Toggles.WalkSpeedEnabled:OnChanged(function()
    if not Toggles.WalkSpeedEnabled.Value then
        local ot = lw()
        if ot then
            ot.WalkSpeed = 16
        end
    end
end)
lR = function(dB)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not dB)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not dB
        end
    end)
    if not dB then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(lr, "GameplayPaused", false)
        else
            lr.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(function()
    lR(Toggles.AntiGameplayPause.Value)
end)
task.spawn(function()
    while not k2.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            lR(true)
        end
    end
end)
local MenuGroup = ma.Settings:AddLeftGroupbox("Menu", "wrench")
lj = tick()
lg = tick()
pcall(function()
    for i, v in ipairs(getconnections(lr.Idled)) do
        local oG = v
        pcall(function()
            oG:Disable()
        end)
    end
end)
k5 = function()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    lg = tick()
end
connection = UserInputService.InputBegan:Connect(function()
    lj = tick()
end)
connection2 = UserInputService.InputChanged:Connect(function(dZ)
    local UserInputType = dZ.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        lj = tick()
    end
end)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(function()
    while not k2.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local oP = tick() - lj
            local oQ = tick() - lg
            if oP >= 300 and oQ >= 60 then
                pcall(k5)
            else
                if oP < 300 and oQ >= 300 then
                    pcall(k5)
                end
            end
        end
    end
end)
MenuGroup:AddButton("Unload", function()
    k2:Unload()
end)
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
k2.ToggleKeybind = Options.MenuKeybind
mb:SetLibrary(k2)
kY:SetLibrary(k2)
kY:IgnoreThemeSettings()
kY:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
mb:SetFolder("TempoHub")
kY:SetFolder("TempoHub/SurviveAnimeArena")
local lZ_16 = kY:BuildConfigSection(ma.Settings)
mb:ApplyToTab(ma.Settings)
mb:SaveDefault("Evil Hello Kitty")
mb:LoadDefault()
lb = function(ef, eg)
    local oX_1 = (ef == "Toggle" and Toggles or Options)[eg]
    local oW_2 = type(oX_1) == "table" and oX_1.Type == ef
    return oW_2 and oX_1 or nil
end
lV = function(en, eo)
    local Type = eo.Type
    if Type == "Toggle" then
        return { idx = en, type = "Toggle", value = eo.Value == true }
    elseif Type == "Slider" then
        return { idx = en, type = "Slider", value = tostring(eo.Value) }
    elseif Type == "Dropdown" then
        return { idx = en, type = "Dropdown", multi = eo.Multi == true, value = eo.Value }
    elseif Type == "Input" then
        local o0 = eo.Value
        local o4 = if o0 then 1 else 0
        local o2 = 1956 * o4 + 33 * (1 - o4)
        local o3 = 1247 * o4 + 1213 * (1 - o4)
        if not ((o2 * 3852 + o3 * 1702 + o2 * o3) % 16777213 == 12096038) then
            o0 = ""
        end
        return { idx = en, type = "Input", text = tostring(o0) }
    elseif Type == "ColorPicker" then
        return { idx = en, type = "ColorPicker", value = eo.Value:ToHex(), transparency = eo.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = en,
            type = "KeyPicker",
            mode = eo.Mode,
            key = eo.Value,
            modifiers = eo.Modifiers,
            toggled = eo.Toggled
        }
    else
        return nil
    end
end
lN = function()
    local pc = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local pd = type(v) == "table" and type(v.Type) == "string" and not kY.Ignore[k]
            if pd then
                local pd_1 = lV(k, v)
                if pd_1 then
                    pc[#pc + 1] = pd_1
                end
            end
        end
    end
    table.sort(pc, function(eB, eC)
        if eB.type ~= eC.type then
            return eB.type < eC.type
        end
        return eB.idx < eC.idx
    end)
    return { objects = pc }
end
k8 = function(eE)
    local pt
    pt = nil
    local pu = type(eE) ~= "table" or type(eE.idx) ~= "string" or type(eE.type) ~= "string" or kY.Ignore[eE.idx]
    if pu then
        return false
    end
    pt = lb(eE.type, eE.idx)
    if not pt then
        return false
    end
    local pu_1 = pcall(function()
        if eE.type == "Input" then
            if type(eE.text) ~= "string" then
                return
            end
            pt:SetValue(eE.text)
        elseif eE.type == "ColorPicker" then
            pt:SetValueRGB(Color3.fromHex(eE.value), eE.transparency)
        elseif eE.type == "KeyPicker" then
            pt:SetValue({ eE.key, eE.mode, eE.modifiers })
            if eE.mode == "Toggle" and eE.toggled ~= nil then
                pt.Toggled = eE.toggled
                pt:Update()
            end
        else
            pt:SetValue(eE.value)
        end
    end)
    return pu_1
end
lZ_16:AddDivider()
lZ_16:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
lZ_16:AddButton("Export Config to Clipboard", function()
    local px_1
    local pw_1
    pw_1, px_1 = pcall(HttpService.JSONEncode, HttpService, lN())
    if not pw_1 then
        k2:Notify("Failed to encode the config")
        return
    end
    local pw_2 = setclipboard
    local pC = if pw_2 then 1 else 0
    local pA = 2384 * pC + 2383 * (1 - pC)
    local pB = 1031 * pC + 3295 * (1 - pC)
    if not ((pA * 2549 + pB * 3101 + pA * pB) % 16777213 == 11731851) then
        pw_2 = toclipboard
    end
    local py = pw_2
    local pw_3 = type(py) ~= "function" or not pcall(py, px_1)
    if pw_3 then
        k2:Notify("Your executor does not support copying to the clipboard")
        return
    end
    k2:Notify("Config copied to clipboard", 6)
end)
lZ_16:AddButton("Import Config from Clipboard Text", function()
    local pF_1
    local pD = Options.SaveManager_ImportSource.Value or ""
    local pD_1
    local pE = tostring(pD):match("^%s*(.-)%s*$")
    if pE == "" then
        k2:Notify("Paste an exported config into the box first")
        return
    end
    pD_1, pF_1 = pcall(HttpService.JSONDecode, HttpService, pE)
    local pE_1 = not pD_1 or type(pF_1) ~= "table"
    local pJ = if pE_1 then 1 else 0
    local pH = 3219 * pJ + 782 * (1 - pJ)
    local pI = 3844 * pJ + 355 * (1 - pJ)
    if not ((pH * 888 + pI * 1650 + pH * pI) % 16777213 == 4797695) then
        pE_1 = type(pF_1.objects) ~= "table"
    end
    if pE_1 then
        k2:Notify("That is not a valid exported config")
        return
    end
    local pD_2 = 0
    for i, v in ipairs(pF_1.objects) do
        if k8(v) then
            pD_2 += 1
        end
    end
    if pD_2 == 0 then
        k2:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local pF_2 = pD_2 == 1 and "" or "s"
    k2:Notify(("Imported %d setting%s"):format(pD_2, pF_2), 6)
end)
pcall(function()
    kY:LoadAutoloadConfig()
end)
lt:SetAttribute("AutoSkip", Toggles.AutoSkip.Value)
k_ = {}
kX = function(e8, e9)
    local pQ = os.clock()
    if pQ - (k_[e8] or 0) >= e9 then
        k_[e8] = pQ
        return true
    end
    return false
end
lL = 0
connection3 = nil
connection3 = RunService.RenderStepped:Connect(function(ff)
    if not lU() then
        connection3:Disconnect()
        return
    end
    local pX = not Toggles.Orbit.Value or lB()
    if pX then
        return
    end
    local pX_1 = ll()
    local pY = lt.Character and lt.Character:FindFirstChild("HumanoidRootPart")
    if not (pX_1 and pY) then
        return
    end
    lL = lL + Options.OrbitSpeed.Value * ff
    if lL > math.pi * 2 then
        lL = lL - math.pi * 2
    end
    local Value2 = Options.OrbitDistance.Value
    local Value = Options.OrbitHeight.Value
    local p0 = pX_1.Position + Vector3.new(math.cos(lL) * Value2, Value, math.sin(lL) * Value2)
    pY.CFrame = CFrame.lookAt(p0, pX_1.Position)
    pY.AssemblyLinearVelocity = Vector3.zero
end)
task.spawn(function()
    local qs_2
    local qr_10, qr_11
    local qq_13
    local qp_6, qp_18, qp_22
    local qm = false
    local qn
    local qh = {}
    local qf = {}
    local qx = false
    repeat
        local qj, qi, qg, qk
        if lP.alive() then
            if not lU() then
                qx = true
            else
                task.wait(0.25)
                local qo = Toggles.MakeLobby.Value and lc
                local qo_8
                if qo then
                    if kX("lobby", Options.LobbyInterval.Value) then
                        lQ(k7)
                        task.wait(0.6)
                        pcall(function()
                            lc:FireServer(false, 1, Toggles.NightmareMode.Value, nil)
                        end)
                    end
                end
                local qo_1 = Toggles.AutoEquipTool.Value and not lB()
                if qo_1 then
                    if kX("equiptool", 2) then
                        local Character = lt.Character
                        local qp_1 = Character and Character:FindFirstChildOfClass("Humanoid")
                        if qp_1 then
                            local Tool = Character:FindFirstChildOfClass("Tool")
                            if not Tool then
                                local qo_3 = kZ()
                                local qp_3 = qo_3 and qo_3:FindFirstChild("CurWeapon") and qo_3.CurWeapon.Value
                                local qo_4 = qp_3 or nil
                                local qp_4 = qo_4
                                if qo_4 then
                                    qo_4 = lt.Backpack:FindFirstChild(qp_4)
                                end
                                local qp_5 = qo_4 or lt.Backpack:FindFirstChildOfClass("Tool")
                                if qp_5 then
                                    pcall(qp_1.EquipTool, qp_1, qp_5)
                                end
                            end
                        end
                    end
                end
                local qo_6 = Toggles.AutoShoot.Value and not lB()
                if qo_6 then
                    if not qm then
                        pcall(function()
                            ContextActionService:CallFunction("ToggleAutoFire", Enum.UserInputState.Begin, nil)
                        end)
                        qm = true
                    end
                elseif qm then
                    pcall(function()
                        ContextActionService:CallFunction("ToggleAutoFire", Enum.UserInputState.Begin, nil)
                    end)
                    qm = false
                end
                local qo_7 = Toggles.AutoAbility.Value and not lB()
                if qo_7 then
                    if kX("ability", Options.AbilityInterval.Value) then
                        qo_8, qp_6 = pcall(require, lM.Modules.ClassData)
                        local qq_2 = kZ()
                        local qr_1 = qo_8 and qq_2 and qq_2:FindFirstChild("CurClass") and qq_2.CurClass.Value
                        local qq_3 = qr_1 or nil
                        local qr_2 = qo_8
                        if qr_2 then
                            qr_2 = qp_6
                        end
                        if qr_2 then
                            qr_2 = qp_6.Classes
                        end
                        if qr_2 then
                            qr_2 = qq_3
                        end
                        if qr_2 then
                            qr_2 = qp_6.Classes[qq_3]
                        end
                        local ql = qr_2
                        if ql then
                            if qn ~= qq_3 then
                                qn = qq_3
                                qh = {}
                                qf = {}
                            end
                            qj = os.clock()
                            local qo_10 = lt:GetAttribute("CursedTokens") or 0
                            local qp_7 = Events
                            qi = qo_10
                            if qp_7 then
                                qp_7 = Events:FindFirstChild("Skill")
                            end
                            local qo_11 = Events
                            qg = qp_7
                            if qo_11 then
                                qo_11 = Events:FindFirstChild("CheckCost")
                            end
                            qk = qo_11
                            local function qo_12(gg)
                                local p6
                                local p5 = ql[gg]
                                if not p5 then
                                    return false
                                end
                                if qf[gg] and qf[gg] > qj then
                                    return false
                                end
                                p6 = qh[gg] or p5.Cost
                                local p7_2 = qi < Options.AbilityMinTokens.Value
                                local qe = if p7_2 then 1 else 0
                                local qc = 2804 * qe + 3010 * (1 - qe)
                                local qd = 3273 * qe + 3704 * (1 - qe)
                                if not ((qc * 2927 + qd * 3028 + qc * qd) % 16777213 == 10518231) then
                                    p7_2 = qi < p6
                                end
                                if p7_2 then
                                    return false
                                end
                                if not (qg and qk) then
                                    return false
                                end
                                local p7_4 = pcall(function()
                                    return qk:InvokeServer(p6)
                                end)
                                if p7_4 then
                                    pcall(function()
                                        qg:FireServer(p5.MoveName, "Target")
                                    end)
                                    local p7_5 = p5.CostIncrease or 50
                                    qh[gg] = p6 + p7_5
                                    local p7_6 = p5.CD or 10
                                    qf[gg] = qj + p7_6
                                    return true
                                end
                                return false
                            end
                            local Value = Options.AbilityMove.Value
                            if type(Value) == "table" then
                                for k, v in pairs(Value) do
                                    if v then
                                        local qq_4 = tonumber(tostring(k):match("^(%d+)")) or 1
                                        if qo_12(qq_4) then
                                            break
                                        end
                                    end
                                end
                            else
                                local qq_5 = tonumber(tostring(Value):match("^(%d+)")) or 1
                                qo_12(qq_5)
                            end
                        end
                    end
                end
                local qo_13 = Toggles.AutoUpDMG.Value
                local qG = if qo_13 then 1 else 0
                local qE = 2378 * qG + 1397 * (1 - qG)
                local qF = 2359 * qG + 2495 * (1 - qG)
                if not ((qE * 1872 + qF * 1439 + qE * qF) % 16777213 == 13455919) then
                    qo_13 = Toggles.AutoUpHP.Value
                end
                if not qo_13 then
                    qo_13 = Toggles.AutoUpTier.Value
                end
                if qo_13 then
                    if kX("upgrades", Options.UpInterval.Value) then
                        if Toggles.AutoUpDMG.Value then
                            k9("Upgrade", "DMG")
                        end
                        if Toggles.AutoUpHP.Value then
                            k9("Upgrade", "HP")
                        end
                        if Toggles.AutoUpTier.Value then
                            k9("Upgrade", "Tier")
                        end
                    end
                end
                if Toggles.AutoBuyWeapons.Value then
                    if kX("buyweapons", 1.5) then
                        local qo_14 = lC("Weapons")
                        local qp_9 = lO()
                        local qq_6 = lW()
                        for k, v in pairs(Options.BuyWeaponList.Value) do
                            if v and not qo_14[k] then
                                local qr_5 = qp_9 and qp_9.Weapons and qp_9.Weapons[k]
                                local qr_6 = type(qr_5) == "table" and qr_5.Cost
                                if qr_6 then
                                    local Cost = qr_5.Cost
                                    if qq_6 >= Cost then
                                        k9("BuyWeapon", k, Cost)
                                        qq_6 = qq_6 - Cost
                                    end
                                end
                            end
                        end
                    end
                end
                if Toggles.AutoBuyClasses.Value then
                    if kX("buyclasses", 1.5) then
                        local qo_15 = lC("Classes")
                        local qp_10 = lW()
                        for k, v in pairs(Options.BuyClassList.Value) do
                            if v and not qo_15[k] and k6[k] then
                                local qq_8 = k6[k]
                                if qp_10 >= qq_8 then
                                    k9("BuyClass", k, qq_8)
                                    qp_10 = qp_10 - qq_8
                                end
                            end
                        end
                    end
                end
                if Toggles.AutoBuyAuras.Value then
                    if kX("buyauras", 1.5) then
                        local qo_16 = lC("Auras")
                        local qp_11 = lW()
                        for k, v in pairs(Options.BuyAuraList.Value) do
                            if v and not qo_16[k] and k1[k] then
                                local qq_10 = k1[k]
                                if qp_11 >= qq_10 then
                                    k9("BuyAura", k, qq_10)
                                    qp_11 = qp_11 - qq_10
                                end
                            end
                        end
                    end
                end
                if Toggles.AutoEquipWeapon.Value then
                    if kX("eqweapon", 3) then
                        local qo_17 = lO()
                        local qp_12 = lC("Weapons")
                        local qq_11 = kZ()
                        local qr_8 = qq_11 and qq_11:FindFirstChild("CurWeapon") and qq_11.CurWeapon.Value
                        local qq_12 = qr_8 or ""
                        qs_2, qq_13 = nil, 0
                        local qt = { Common = 1, Rare = 2, Epic = 3, Legendary = 4, Mythic = 5 }
                        for k in pairs(qp_12) do
                            local qp_13 = qo_17 and qo_17.Weapons and qo_17.Weapons[k]
                            if type(qp_13) == "table" then
                                local qp_14 = qt[qp_13.Rarity] or 0
                                if qp_14 > qq_13 then
                                    qs_2, qq_13 = k, qp_14
                                end
                            end
                        end
                        if qs_2 and qs_2 ~= qq_12 then
                            k9("EquipWeapon", qs_2)
                        end
                    end
                end
                if Toggles.AutoEquipClass.Value then
                    if kX("eqclass", 3) then
                        local qo_19 = lC("Classes")
                        local qp_16 = kZ()
                        local qq_14 = qp_16 and qp_16:FindFirstChild("CurClass") and qp_16.CurClass.Value
                        local qp_17 = qq_14 or ""
                        qr_10, qp_18 = nil, 0
                        for k in pairs(qo_19) do
                            local qo_20 = k4[k] or 0
                            if qo_20 > qp_18 then
                                qr_10, qp_18 = k, qo_20
                            end
                        end
                        if qr_10 and qr_10 ~= qp_17 then
                            k9("EquipClass", qr_10)
                        end
                    end
                end
                if Toggles.AutoEquipAura.Value then
                    if kX("eqaura", 3) then
                        local qo_22 = lC("Auras")
                        local qp_20 = kZ()
                        local qq_16 = qp_20 and qp_20:FindFirstChild("CurAura") and qp_20.CurAura.Value
                        local qp_21 = qq_16 or ""
                        qr_11, qp_22 = nil, 0
                        for k in pairs(qo_22) do
                            local qo_23 = k1[k] or 0
                            if qo_23 > qp_22 then
                                qr_11, qp_22 = k, qo_23
                            end
                        end
                        if qr_11 and qr_11 ~= qp_21 then
                            k9("EquipAura", qr_11)
                        end
                    end
                end
                if Toggles.AutoUpgradeWeapon.Value then
                    if kX("upgrade", Options.UpgradeInterval.Value) then
                        local qo_25 = lO()
                        local qp_24 = kZ()
                        local qq_18 = qp_24 and qp_24:FindFirstChild("CurWeapon") and qp_24.CurWeapon.Value
                        if qq_18 then
                            local qq_19 = qo_25 and qo_25.Weapons and qo_25.Weapons[qq_18]
                            if type(qq_19) == "table" then
                                local qq_20 = qp_24:FindFirstChild("WeaponLevels") and qp_24.WeaponLevels:FindFirstChild(qq_18 .. "LV")
                                local qp_25 = qq_20
                                if qq_20 then
                                    qq_20 = qp_25.Value
                                end
                                local qp_27 = qq_19.LevelUpCost * (qq_20 or 1)
                                if lW() >= qp_27 then
                                    k9("UpgradeWeapon", qq_18, qp_27)
                                end
                            end
                        end
                    end
                end
            end
        else
            qx = true
        end
    until qx
end)
k2:OnUnload(function()
    if connection3 then
        connection3:Disconnect()
    end
    if connection then
        connection:Disconnect()
    end
    if connection2 then
        connection2:Disconnect()
    end
    lR(false)
    local q0 = getgenv()
    local q1 = getgenv().OURO_GEN or 0
    q0.OURO_GEN = q1 + 1
end)
lP.onCleanup(function()
    if connection3 then
        connection3:Disconnect()
    end
    pcall(function()
        k2:Unload()
    end)
end)
md({ Title = "Tempo", Description = "Loaded for Survive Anime Arena [ALPHA]", Time = 4 })
end)(...)

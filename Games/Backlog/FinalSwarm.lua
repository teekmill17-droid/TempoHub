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
getgenv().TempoHoodSubtitle = "FINAL SWARM"
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
local vt_1, vt_3, vt_5, vt_7, vt_9, vt_12, vt_14, vt_15, vt_17, vt_20
local vt_22_3
local mY
local nF
local mF
local nm
local m3
local mL
local ns
local m9
local ny
local my
local nf
local mX
local connection4
local connection2
local nl
local m2
local mK
local nr
local m8
local Label
local Library
local mx
local ne
local mW
local nD
local Label3
local nk
local m1
local mJ
local nq
local m7
local mP
local UserInputService
local mw
local nd
local mV
local nC
local mC
local nj
local m0
local Label2
local connection3
local np
local m6
local mO
local connection
local mv
local nc
local mU
local nB
local mB
local Options
local m_
local nH
local mH
local Toggles
local m5
local mN
local nu
local nb
local mT
local nA
local mA
local nh
local mZ
local nG
local mG
local nn
local m4
local mM
local na
local mS
local nz
local mz
local ng
local function worker()
    local qd_1
    while not Library.Unloaded do
        task.wait(1)
        local qc = math.floor(os.clock() - nl)
        if qc < 60 then
            qd_1 = qc .. "s"
        elseif qc < 3600 then
            qd_1 = string.format("%dm %ds", math.floor((qc) / (60)), qc % 60)
        else
            qd_1 = string.format("%dh %dm", math.floor((qc) / (3600)), math.floor((qc % 3600) / (60)))
        end
        Label:SetText(nA("Session time", qd_1, nb))
    end
end
local function fn42(g7, g8)
    local Count = g7:FindFirstChild("Count")
    if not Count then
        return false
    end
    local tK = Count:FindFirstChild(("Count%d"):format(g8))
    if not tK then
        return false
    end
    local overlay = tK:FindFirstChild("overlay")
    return overlay ~= nil and overlay.Visible
end
local function autoPlayLoop()
    while not Library.Unloaded do
        task.wait(1)
        if nk and Toggles.AutoPlay.Value then
            mV()
            task.wait(Options.PlayRetry.Value)
        end
    end
end
local function fn63()
    local qx = mz(Options.PriorityList.Value)
    if #qx == 0 then
        Label3:SetText("Priority: empty")
        return
    end
    local qy = {}
    for i, v in ipairs(qx) do
        table.insert(qy, ("%d. %s"):format(i, v))
    end
    Label3:SetText(table.concat(qy, "\n"))
end
local function fn76()
    local CurrentCamera = nB.CurrentCamera
    if not CurrentCamera then
        return
    end
    ny:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    ny:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    m8 = tick()
end
local function fn78(bo, bp)
    return string.format('<font color="%s">%s</font>', bp, bo)
end
local function fn95(fx)
    local st = fx
    while true do
        if not (st and st ~= ns) then
            return true
        end
        local su_1 = st:IsA("GuiObject") and not st.Visible
        if su_1 then
            return false
        end
        local su_2 = st:IsA("LayerCollector") and not st.Enabled
        if su_2 then
            break
        end
        st = st.Parent
    end
    return false
end
local function fn100()
    local p__1
    local pZ_1
    if identifyexecutor then
        p__1, pZ_1 = identifyexecutor()
        local p0 = p__1 ~= ""
        local p1 = type(p__1) == "string" and p0
        if p1 then
            local p0_1 = type(pZ_1) == "string" and pZ_1 ~= "" and p__1 .. " " .. pZ_1
            m5 = p0_1 or p__1
        end
    end
end
local function fn122(c7, c8, c9, da, db)
    if c8.Magnitude < 0.05 then
        return
    end
    local q8 = c9 * da
    if db then
        q8 = math.min(q8, db)
    end
    c7.CFrame = CFrame.new(c7.Position + c8.Unit * q8)
end
local function fn132(cz)
    local cA = table.concat(cz, ", ")
    Options.PriorityList:SetValue(cA)
end
local function fn141(br, bs, bt)
    return string.format("<b>%s</b> %s %s", br, nG("-", "#5a6070"), nG(bs, bt))
end
local function onUnload()
    Library:Unload()
end
local function fn202(be)
    local DiscordGroup = be:AddLeftGroupbox("Discord", nil, nil, nil, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = m4 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = m4 })
    DiscordGroup:AddLabel(m7, true)
    for i, child in DiscordGroup.Container:GetChildren() do
        local pR_1 = child:IsA("TextLabel") and child.Text == m7
        if pR_1 then
            child.TextColor3 = Color3.fromRGB(255, 70, 70)
        end
    end
end
local function fn212()
    mT()
    connection:Disconnect()
    if connection2 then
        connection2:Disconnect()
    end
    connection3:Disconnect()
    connection4:Disconnect()
end
local function onCopyJoinScript_JobID()
    local p6 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, mN)
    if setclipboard then
        setclipboard(p6)
    elseif toclipboard then
        toclipboard(p6)
    end
    Library:Notify("Copied join script to clipboard")
end
local function fn220()
    local ps = mw and mw:get({ "stats", "keys" })
    return ps or 0
end
local function fn234(as, at)
    return mB[as].number < mB[at].number
end
local function autoSkillsLoop()
    while not Library.Unloaded do
        task.wait(1)
        if nk and Toggles.AutoSkills.Value then
            local ut_1 = tonumber(Options.SkillKeyReserve.Value) or 0
            local ut_2 = nr(ut_1)
            local uu_1 = nil
            if Options.SkillMode.Value == "Priority List" then
                for k, v in mz(Options.SkillPriority.Value) do
                    for k, v2 in ut_2 do
                        if v2.id == v then
                            uu_1 = v2
                            break
                        end
                    end
                    if uu_1 then
                        break
                    end
                end
            else
                for k, v in ut_2 do
                    if not uu_1 then
                        uu_1 = v
                    elseif Options.SkillMode.Value == "Cheapest" then
                        if v.amount < uu_1.amount then
                            uu_1 = v
                        end
                    elseif v.amount > uu_1.amount then
                        uu_1 = v
                    end
                end
            end
            if uu_1 then
                nz("SkillTree", "purchaseSkill", uu_1.id)
                task.wait(0.6)
            end
        end
    end
end
local function onAddToPriority2()
    local Value = Options.PriorityPick.Value
    if not Value or Value == "" then
        return
    end
    local qH_1 = mz(Options.PriorityList.Value)
    for k, v in qH_1 do
        if v == Value then
            return
        end
    end
    table.insert(qH_1, Value)
    mx(qH_1)
end
local function fn298(ax, ay)
    local pm = mO[ax].price
    local pr = if pm then 1 else 0
    local pp = 2088 * pr + 1279 * (1 - pr)
    local pq = 531 * pr + 1015 * (1 - pr)
    if not ((pp * 2632 + pq * 3427 + pp * pq) % 16777213 == 8424081) then
        pm = 0
    end
    return pm < (mO[ay].price or 0)
end
local function fn322(aL)
    local py = mw and mw:get({ "stats", "skillTree" })
    local py_1 = typeof(py) == "table" and py[aL] == true
    return py_1
end
local function fn333(h2)
    local ug = nC() - h2
    local uh = {}
    for k, v in pairs(mJ) do
        if not m9(k) then
            local uj = v.cost or {}
            local uj_1 = uj.amount or 0
            local uj_2 = (v.dependency == nil or m9(v.dependency)) and (uj.currency == nil or uj.currency == "keys") and uj_1 <= ug
            if uj_2 then
                table.insert(uh, { id = k, amount = uj_1 })
            end
        end
    end
    return uh
end
local function fn353(dF)
    local rs_1
    local rr_1
    local Chests = nB:FindFirstChild("Chests")
    if not Chests then
        return nil
    end
    rs_1, rr_1 = nil, Options.CollectRadius.Value
    for i, descendant in Chests:GetDescendants() do
        local rp_1 = descendant:IsA("ProximityPrompt") and descendant.Enabled
        if rp_1 then
            local Parent = descendant.Parent
            local rq_1 = Parent ~= nil and Parent:HasTag("Pot")
            local rt = Parent and Parent:IsA("BasePart")
            if rt then
                if rq_1 then
                    rq_1 = "Pots"
                end
                local ru = rq_1 or "Chests"
                rt = mS(ru)
            end
            if rt then
                local Magnitude = (Parent.Position - dF.Position).Magnitude
                if Magnitude < rr_1 then
                    rs_1, rr_1 = descendant, Magnitude
                end
            end
        end
    end
    return rs_1, rr_1
end
local function fn357(he)
    local tR, tS, tT
    local tP = mP()
    if not tP then
        return
    end
    local Holder = tP:FindFirstChild("Holder")
    if not Holder then
        return
    end
    local tW = false
    for i, v in ipairs(he) do
        local tV = 11
        while true do
            if tV < 11 then
                if tV < 5 then
                    if tV < 2 then
                        if tV < 1 then
                            tV = 22
                        else
                            tV = if tT then 19 else 6
                        end
                    elseif tV < 3 then
                        tT = Toggles.AutoCardRandom.Value
                        tV = 10
                    elseif tV < 4 then
                        return
                    else
                        return
                    end
                elseif tV < 8 then
                    if tV < 6 then
                        break
                    elseif tV < 7 then
                        tV = 12
                    else
                        tW = true
                        tV = 5
                    end
                elseif tV < 9 then
                    tV = 0
                elseif tV < 10 then
                    tV = if not tP.Visible then 3 else 20
                else
                    tV = if not tT then 17 else 15
                end
            elseif tV < 17 then
                if tV < 14 then
                    if tV < 12 then
                        tR = mK(v)
                        tV = if not tR then 4 else 21
                    elseif tV < 13 then
                        tV = 5
                    else
                        tT = tR < 40
                        tV = 1
                    end
                elseif tV < 15 then
                    task.wait(Options.CardDelay.Value)
                    tR = 0
                    tV = 0
                elseif tV < 16 then
                    firesignal(tS.MouseButton1Up)
                    task.wait(0.25)
                    tR += 1
                    tV = if my(tP, i) then 18 else 9
                else
                    return
                end
            elseif tV < 20 then
                if tV < 18 then
                    return
                elseif tV < 19 then
                    tV = 12
                else
                    tT = Toggles.AutoCard.Value
                    tV = if tT then 10 else 2
                end
            elseif tV < 21 then
                tV = 8
            elseif tV < 22 then
                tS = Holder:FindFirstChild(("Selection%d"):format(tR))
                tV = if not tS then 16 else 14
            else
                tT = not Library.Unloaded
                tV = if tT then 13 else 1
            end
        end
        if tW then
            break
        end
    end
end
local function fn445(aY)
    local pJ = {}
    local pK = aY or ""
    for k in tostring(pK):gmatch("[^,]+") do
        local pK_1 = k:match("^%s*(.-)%s*$")
        if pK_1 ~= "" then
            table.insert(pJ, pK_1)
        end
    end
    return pJ
end
local function fn450(gH)
    local td_1
    local ta = nc(gH)
    if #ta == 0 then
        return nil
    elseif not Toggles.AutoCard.Value then
        return ta[math.random(1, #ta)].index
    else
        local Value2 = Options.CardBlacklist.Value
        local tb_1
        local tc = {}
        for k, v in ta do
            if not Value2[v.key] then
                table.insert(tc, v)
            end
        end
        if #tc == 0 then
            tc = ta
        end
        local ta_1 = mz(Options.PriorityList.Value)
        td_1, tb_1 = nil, math.huge
        for k, v in tc do
            for i, v2 in ipairs(ta_1) do
                if v2 == v.key and i < tb_1 then
                    td_1, tb_1 = v, i
                end
            end
        end
        if td_1 then
            return td_1.index
        end
        if Toggles.PreferWeapons.Value then
            for k, v in tc do
                if v.isWeapon then
                    return v.index
                end
            end
        end
        local Value = Options.CardFallback.Value
        if Value == "First Card" then
            return tc[1].index
        end
        local tb_2 = tc[1]
        for k, v in tc do
            local tc_1 = mC[v.rarity] or 0
            local tc_2 = mC[tb_2.rarity] or 0
            if Value == "Highest Rarity" then
                if tc_1 > tc_2 then
                    tb_2 = v
                end
            elseif tc_1 < tc_2 then
                tb_2 = v
            end
        end
        return tb_2.index
    end
end
local function fn458(aG)
    local pv = mw and mw:get({ "inventory", "chests" })
    if typeof(pv) ~= "table" then
        return 0
    end
    return pv[aG] or 0
end
local function autoSkipFinalWaveLoop()
    while not Library.Unloaded do
        task.wait(0.5)
        if Library.Unloaded then
            break
        end
        if np then
            local PlayerGui = ns:FindFirstChildOfClass("PlayerGui")
            local sy = PlayerGui and PlayerGui:FindFirstChild("HUD")
            local sy_1 = tick()
            if Toggles.AutoSkipFinalWave.Value and sy_1 - nq >= 1 then
                local sA_1 = sy
                if sA_1 then
                    local sB_1 = sy:FindFirstChild("Top") and sy.Top:FindFirstChild("SkipWave")
                    local sC_1 = sy:FindFirstChild("SkipWave") and sy.SkipWave:FindFirstChild("SkipWave")
                    local sD_1 = sy:FindFirstChild("SkipWaveMobile") and sy.SkipWaveMobile:FindFirstChild("SkipWave")
                    sA_1 = { sB_1, sC_1, sD_1 }
                end
                local sC_2 = sA_1 or {}
                for k, v in sC_2 do
                    local sA_3 = v and m6(v)
                    if sA_3 then
                        firesignal(v.Activated)
                        nq = sy_1
                        break
                    end
                end
            end
            if not Toggles.EnableAutoSkipOnce.Value then
                na = false
            elseif not na then
                local sA_4 = sy
                if sA_4 then
                    local sB_3 = sy:FindFirstChild("Top") and sy.Top:FindFirstChild("AutoSkip")
                    local sC_3 = sy:FindFirstChild("SkipWave") and sy.SkipWave:FindFirstChild("AutoSkip")
                    local sD_2 = sy:FindFirstChild("SkipWaveMobile") and sy.SkipWaveMobile:FindFirstChild("AutoSkip")
                    sA_4 = { sB_3, sC_3, sD_2 }
                end
                local sB_4 = sA_4 or {}
                for k, v in sB_4 do
                    local sz_3 = v and m6(v)
                    if sz_3 then
                        local TextLabel = v:FindFirstChild("TextLabel")
                        local sA_5 = TextLabel and TextLabel:FindFirstChild("On")
                        local sz_5 = sA_5
                        if sA_5 then
                            sA_5 = not sz_5.Enabled
                        end
                        if sA_5 then
                            firesignal(v.Activated)
                        end
                        na = sz_5 ~= nil and sz_5.Enabled
                        if na then
                            break
                        end
                    end
                end
            end
            local sz_6 = PlayerGui and PlayerGui:FindFirstChild("Frames")
            local sx_1 = sz_6
            if sz_6 then
                sz_6 = sx_1:FindFirstChild("VictoryFrame")
            end
            local sA_7 = sz_6
            if Toggles.AutoPlayAgain.Value and sA_7 and sA_7.Visible and sy_1 - nn >= 1 then
                for k, v in getconnections(UserInputService.InputBegan) do
                    local Function = v.Function
                    local sA_8 = typeof(Function) == "function" and debug.getinfo(Function)
                    local sz_9 = sA_8 or nil
                    local sA_9 = sz_9
                    if sz_9 then
                        sz_9 = sA_9.short_src == "ReplicatedStorage.Shared.UI.Frames.RoundEnd"
                    end
                    if sz_9 then
                        v:Fire({ UserInputType = Enum.UserInputType.MouseButton1 }, false)
                        nn = sy_1
                        break
                    end
                end
            end
            local sz_10 = sx_1 and sx_1:FindFirstChild("RoundEnd")
            if Toggles.AutoPlayAgain.Value and sz_10 and sz_10.Visible and sy_1 - nh >= 2 then
                local Buttons = sz_10:FindFirstChild("Buttons")
                local sA_11 = Buttons and Buttons:FindFirstChild("Again")
                local sz_13 = sA_11
                if sA_11 then
                    sA_11 = sz_13.Visible
                end
                if sA_11 then
                    firesignal(sz_13.MouseButton1Click)
                    nh = sy_1
                end
            end
            local sz_14 = sx_1 and sx_1:FindFirstChild("DeathFrame")
            if Toggles.AutoGiveUp.Value and sz_14 and sz_14.Visible and sy_1 - nf >= 2 then
                local Buttons = sz_14:FindFirstChild("Buttons")
                local sx_3 = Buttons and Buttons:FindFirstChild("Continue")
                local sz_17 = sx_3
                if sx_3 then
                    sx_3 = sz_17.Visible
                end
                if sx_3 then
                    firesignal(sz_17.MouseButton1Click)
                    nf = sy_1
                end
            end
        end
    end
end
local function fn504()
    local qf = mz(Options.SkillPriority.Value)
    if #qf == 0 then
        Label2:SetText("Priority: empty")
        return
    end
    local qg = {}
    for i, v in ipairs(qf) do
        table.insert(qg, ("%d. %s"):format(i, v))
    end
    Label2:SetText(table.concat(qg, "\n"))
end
local function autoLobbyChestsLoop()
    while not Library.Unloaded do
        task.wait(1)
        if nk and Toggles.AutoLobbyChests.Value then
            local t5_1 = tonumber(Options.ChestKeyReserve.Value) or 0
            for k, v in mM do
                if Library.Unloaded or not Toggles.AutoLobbyChests.Value then
                    break
                elseif Options.ChestTypes.Value[v] then
                    local Value = Options.ChestBatch.Value
                    if Toggles.ChestBuy.Value then
                        local t7_1 = mO[v].price or 0
                        while true do
                            local t7_2 = t7_1 > 0 and nu(v) < Value and nC() - t5_1 >= t7_1
                            if t7_2 then
                                nz("ChestService", "PurchaseChest", v)
                                task.wait(0.35)
                                continue
                            end
                            break
                        end
                    end
                    local t7_3 = nu(v)
                    if t7_3 > 0 then
                        local t8_2 = math.min(t7_3, Value)
                        if t8_2 > 1 then
                            nz("ChestService", "OpenMultipleChests", v, t8_2)
                        else
                            nz("ChestService", "OpenChest", v)
                        end
                        task.wait(1)
                    end
                end
            end
            task.wait(Options.ChestDelay.Value)
        end
    end
end
local function onRemoveFromPriority()
    local Value = Options.PriorityPick.Value
    local qR = mz(Options.PriorityList.Value)
    for k, v in qR do
        if v == Value then
            table.remove(qR, k)
            break
        end
    end
    mx(qR)
end
local function fn535()
    local Character = ns.Character
    local sa = Character and Character:FindFirstChildOfClass("Humanoid")
    if not sa or sa.MaxHealth <= 0 then
        return 1
    end
    return sa.Health / sa.MaxHealth
end
local function fn541(n, o)
    local o3_1
    local o1 = n and n:FindFirstChild(o)
    local o1_1
    if not o1 then
        return {}
    end
    o1_1, o3_1 = pcall(require, o1)
    return o1_1 and o3_1 or {}
end
local function onClearPriority2()
    mx({})
end
local function fn595()
    if setclipboard then
        setclipboard(mL)
    elseif toclipboard then
        toclipboard(mL)
    end
    Library:Notify("Copied Discord invite to clipboard")
end
local function fn605(dW, dX)
    local Enemies = nB:FindFirstChild("Enemies")
    if not Enemies then
        return Vector3.new(0, 0, 0)
    end
    local rG = Vector3.new(0, 0, 0)
    for i, child in Enemies:GetChildren() do
        local rF_1 = (child:IsA("Model"))
        if rF_1 then
            local rH_1 = child.PrimaryPart or child:FindFirstChild("hitbox")
            rF_1 = rH_1
        end
        local rH_2 = rF_1 or nil
        if rH_2 then
            local rH_3 = dW.Position - rH_2.Position
            local rF_3 = Vector3.new(rH_3.X, 0, rH_3.Z)
            local Magnitude = rF_3.Magnitude
            if Magnitude > 0.1 and Magnitude < dX then
                rG += rF_3.Unit * ((dX - Magnitude) / dX)
            end
        end
    end
    return rG
end
local function onRscripts()
    if setclipboard then
        setclipboard(mG)
    elseif toclipboard then
        toclipboard(mG)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function onInputBegan()
    nd = tick()
end
local function autoQuestsLoop()
    while not Library.Unloaded do
        task.wait(1)
        if nk and Toggles.AutoQuests.Value then
            if Toggles.QuestDaily.Value then
                local uM_1 = mw and mw:get({ "quests", "daily", "slots" })
                if typeof(uM_1) == "table" then
                    for k, v in pairs(uM_1) do
                        local uM_2 = typeof(v) == "table" and not v.claimed
                        if uM_2 then
                            ne("Quests", "claimDaily", k)
                            task.wait(0.3)
                        end
                    end
                end
            end
            if Toggles.QuestAchievements.Value then
                local uN_2 = mF.achievements or {}
                for k, v in uN_2 do
                    if v.id then
                        ne("Quests", "claimAchievement", v.id)
                        task.wait(0.3)
                    end
                end
            end
            task.wait(Options.QuestDelay.Value)
        end
    end
end
local function onAddToPriority()
    local Value = Options.SkillPick.Value
    local qp = mz(Options.SkillPriority.Value)
    for k, v in qp do
        if v == Value then
            return
        end
    end
    table.insert(qp, Value)
    Options.SkillPriority:SetValue(table.concat(qp, ", "))
end
local function onMoveUp()
    local Value = Options.PriorityPick.Value
    local q_ = mz(Options.PriorityList.Value)
    for k, v in q_ do
        if v == Value and k > 1 then
            q_[k] = q_[k - 1]
            q_[k - 1] = v
            break
        end
    end
    mx(q_)
end
local function onInputChanged(iQ)
    local UserInputType = iQ.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        nd = tick()
    end
end
local function fn716()
    if m0 then
        m0:Cancel()
    end
    m0 = nil
    mY = nil
    mU = nil
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        local vk = not Library.Unloaded
        if vk then
            vk = Toggles.AntiAfk and Toggles.AntiAfk.Value
        end
        if vk then
            local vk_1 = tick() - nd
            local vl_2 = tick() - m8
            if vk_1 >= 300 and vl_2 >= 60 then
                pcall(mZ)
            else
                if vk_1 < 300 and vl_2 >= 300 then
                    pcall(mZ)
                end
            end
        end
    end
end
local function fn762(eb, ec)
    local Enemies = nB:FindFirstChild("Enemies")
    if not Enemies then
        return nil
    end
    local rR = Vector3.new(0, 0, 0)
    local rS = 0
    for i, child in Enemies:GetChildren() do
        local rQ_1 = (child:IsA("Model"))
        if rQ_1 then
            local rT_1 = child.PrimaryPart or child:FindFirstChild("hitbox")
            rQ_1 = rT_1
        end
        local rT_2 = rQ_1 or nil
        if rT_2 then
            local rT_3 = rT_2.Position - eb.Position
            if Vector3.new(rT_3.X, 0, rT_3.Z).Magnitude < ec then
                rR += rT_2.Position
                rS += 1
            end
        end
    end
    if rS == 0 then
        return nil
    end
    return rR / rS
end
local function fn821(de, df)
    de.CFrame = CFrame.new(df)
end
local function fn842(ex, ey)
    if m0 and mU == ex and mY and (mY - ey).Magnitude < 3 then
        return
    end
    mT()
    local Magnitude = (ey - ex.Position).Magnitude
    if Magnitude <= 0.5 then
        return
    end
    mY = ey
    mU = ex
    m0 = nD:Create(ex, TweenInfo.new(Magnitude / Options.FarmSpeed.Value, Enum.EasingStyle.Linear), { CFrame = CFrame.new(ey) })
    m0:Play()
end
local function fn852(dh)
    local Value = Options.CollectTypes.Value
    return Value.All == true or Value[dh] == true
end
local function fn871()
    nz("QueueService", "PlayPressed")
    task.wait(0.4)
    nz("WorldSelection", "SetWorld", Options.PlayWorld.Value)
    nz("WorldSelection", "SetDifficulty", Options.PlayDifficulty.Value)
    task.wait(0.2)
    nz("QueueService", "PartySizeSelected", tonumber(Options.PlayerLimit.Value))
    nz("QueueService", "FriendsOnlySelected", Toggles.FriendsOnly.Value)
    task.wait(0.2)
    nz("QueueService", "Created")
end
local function fn925()
    Library:Unload()
end
local function fn938()
    local Character = ns.Character
    if Character then
        return Character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end
local function autoEquipLoop()
    while not Library.Unloaded do
        task.wait(1)
        if nk and Toggles.AutoEquip.Value then
            pcall(function()
                nH:equipBest()
            end)
            task.wait(Options.EquipDelay.Value)
        end
    end
end
local function fn952(dm)
    local rf_1
    local re_1
    local Value = Options.CollectRadius.Value
    rf_1, re_1 = nil, Value * Value
    local VFX = nB:FindFirstChild("VFX")
    if not VFX then
        return nil
    end
    for i, child in VFX:GetChildren() do
        if mS(child.Name) then
            local rd_2 = child:IsA("Model") and child:GetPivot().Position
            local rg = rd_2
            if not rg then
                local rd_3 = child:IsA("BasePart") and child.Position
                rg = rd_3
            end
            local rd_4 = rg
            if rd_4 then
                local rg_1 = rd_4 - dm.Position
                local rh = rg_1.X * rg_1.X + rg_1.Z * rg_1.Z
                if rh < re_1 then
                    rf_1, re_1 = rd_4, rh
                end
            end
        end
    end
    return rf_1
end
local function fn977()
    if not Toggles.AutoRetreat.Value then
        m1 = false
        return false
    end
    local sc = nm() * 100
    if m1 then
        if sc >= math.max(Options.RetreatResume.Value, Options.RetreatHealth.Value) then
            m1 = false
        end
    elseif sc <= Options.RetreatHealth.Value then
        m1 = true
    end
    return m1
end
local function onClearPriority()
    Options.SkillPriority:SetValue("")
end
local function onStartNow()
    task.spawn(mV)
end
local function onHeartbeat(eT)
    local so_1
    local sn_1, sn_4
    if not np then
        return
    end
    local sh = mW()
    if not sh then
        return
    end
    if m2() then
        mT()
        local si_1 = nj(sh, 90)
        if si_1.Magnitude > 0 then
            ng(sh, si_1, math.max(Options.FarmSpeed.Value, Options.CollectSpeed.Value), eT)
        end
        return
    end
    local si_2 = nil
    local sj
    local sj_2
    local Value3 = Options.FarmMethod.Value
    local Value2 = Options.FarmOffset.Value
    if Toggles.AutoFarm.Value then
        sj = mv(sh, Options.FarmSearch.Value)
        if sj then
            if Value3 == "Below" then
                si_2 = Vector3.new(sj.X, sj.Y - Value2, sj.Z)
            elseif Value3 == "Above" then
                si_2 = Vector3.new(sj.X, sj.Y + Value2, sj.Z)
            else
                m3 += eT * 1.5
                si_2 = sj + Vector3.new(math.cos(m3) * Value2, 0, math.sin(m3) * Value2)
            end
        end
    end
    local sm
    if Toggles.AutoCollect.Value then
        so_1, sn_1 = mX(sh)
        if so_1 then
            if sn_1 <= math.max(so_1.MaxActivationDistance - 2, 4) then
                pcall(fireproximityprompt, so_1, so_1.HoldDuration)
            else
                sm = so_1.Parent.Position
            end
        else
            sm = mA(sh)
        end
    end
    if sm and sj then
        local Value = Options.FarmSearch.Value
        local so_2 = sm - sj
        if Vector3.new(so_2.X, 0, so_2.Z).Magnitude > Value then
            sm = nil
        elseif Value3 ~= "Orbit" then
            if Value3 == "Below" then
                sn_4 = -Value2
            else
                sn_4 = Value2
            end
            local sk_1 = sn_4
            sm = Vector3.new(sm.X, sj.Y + sk_1, sm.Z)
        else
            sm = Vector3.new(sm.X, sh.Position.Y, sm.Z)
        end
    elseif sm then
        sm = Vector3.new(sm.X, sh.Position.Y, sm.Z)
    end
    local sk_2 = sm or si_2
    if not sk_2 then
        mT()
        return
    end
    if sm then
        sj_2 = Options.CollectSpeed.Value
    else
        sj_2 = Options.FarmSpeed.Value
    end
    local sl_1 = sj_2
    local sj_3 = Toggles.CollectInstant.Value
    if sj_3 then
        sj_3 = sm or Toggles.AutoCollect.Value
    end
    if sj_3 then
        mT()
        m_(sh, sk_2)
        return
    end
    if si_2 and not sm then
        mH(sh, si_2)
        return
    end
    mT()
    local si_3 = sk_2 - sh.Position
    local Magnitude = si_3.Magnitude
    if Magnitude > 0.5 then
        ng(sh, si_3, sl_1, eT, Magnitude)
    end
end
local function fn1044()
    local PlayerGui = ns:FindFirstChildOfClass("PlayerGui")
    if not PlayerGui then
        return nil
    end
    local Frames = PlayerGui:FindFirstChild("Frames")
    if not Frames then
        return nil
    end
    return Frames:FindFirstChild("Upgrades")
end
mv = nil
mw = nil
mx = nil
my = nil
mz = nil
mA = nil
mB = nil
mC = nil
Label3 = nil
connection2 = nil
mF = nil
mG = nil
mH = nil
connection3 = nil
mJ = nil
mK = nil
mL = nil
mM = nil
mN = nil
mO = nil
mP = nil
Label = nil
mS = nil
mT = nil
mU = nil
mV = nil
mW = nil
mX = nil
mY = nil
mZ = nil
m_ = nil
m0 = nil
m1 = nil
m2 = nil
m3 = nil
m4 = nil
m5 = nil
m6 = nil
m7 = nil
m8 = nil
m9 = nil
na = nil
nb = nil
nc = nil
nd = nil
ne = nil
nf = nil
ng = nil
nh = nil
local mR
Options = nil
nj = nil
nk = nil
nl = nil
nm = nil
nn = nil
Toggles = nil
np = nil
nq = nil
nr = nil
ns = nil
local nt
nu = nil
connection = nil
UserInputService = nil
Library = nil
ny = nil
nz = nil
nA = nil
nB = nil
nC = nil
nD = nil
connection4 = nil
nF = nil
nG = nil
nH = nil
Label2 = nil
local nV, nW, nX, nY, nZ, n_
vt_14, vt_20, vt_3, nD, nB, ny, UserInputService, ns, np, nk, vt_7, vt_12, vt_9, mR, mO, mJ, mF, mB, mw, nH, nF, vt_1, vt_17 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local vt_25 = 18
repeat
    local vt_22_1 = (vt_25 * 11 + 3) % 18 + 1
    if vt_22_1 <= 9 then
        if vt_22_1 <= 5 then
            if vt_22_1 <= 3 then
                if vt_22_1 <= 2 then
                    if vt_22_1 <= 1 then
                        local wI = bit32.rrotate(bit32.bxor(bit32.lrotate(vt_25, 2), string.byte(tostring(nF))), 3)
                        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(wI, 4082241455), 533236217), (bit32.bxor(bit32.band(wI, 212725840), 3518186887))), 533236217), 3518186887) ~= wI then
                            vt_20 = nH(vt_17.Packages, "DataService").client
                            mw = nH(vt_17.Shared.UI.Frames, "InventoryFrame")
                        else
                            mw = vt_17(vt_20.Packages, "DataService").client
                            nH = vt_17(vt_20.Shared.UI.Frames, "InventoryFrame")
                        end
                        vt_25 = (vt_25 + 23) % 72
                    else
                        local wL = bit32.rrotate(bit32.bxor(bit32.lrotate(vt_25, 3), string.byte(tostring(nB))), 20)
                        if bit32.bxor(bit32.lrotate(bit32.bxor(wL, 3403415401), 22), 3664951039) == bit32.lrotate(wL, 22) then
                            nF = vt_20.Packages:FindFirstChild("_Index")
                        else
                            vt_20 = nF.Packages:FindFirstChild("_Index")
                        end
                        vt_25 = (vt_25 + 5) % 72
                    end
                else
                    if vt_25 * 48372311 + 3 + 4 >= vt_25 * 48372311 + 3 + 4 + 4 then
                        nF = vt_1
                    else
                        vt_1 = nF
                    end
                    vt_25 = (vt_25 + 59) % 72
                end
            elseif vt_22_1 <= 4 then
                vt_5 = (vector.create((vt_25 * 4 + 8) % 11 + 1, (vt_25 * 9 + 11) % 13 + 1, (vt_25 * 10 + 11) % 17 + 1))
                vt_15 = (vector.create((vt_25 * 1 + 5) % 11 + 1, (vt_25 * 11 + 4) % 13 + 1, (vt_25 * 5 + 10) % 17 + 1))
                nV = (vector.create((vt_25 * 1 + 1) % 11 + 1, (vt_25 * 7 + 2) % 13 + 1, (vt_25 * 7 + 3) % 17 + 1))
                if vector.dot(vector.cross(vt_5, vt_15), nV) == vector.dot(vector.cross(vt_15, nV), vt_5) + 3 then
                    vt_1 = game:GetService("Players")
                else
                    vt_14 = game:GetService("Players")
                end
                vt_25 = (vt_25 + 59) % 72
            else
                vt_5 = (vector.create((vt_25 * 1 + 7) % 11 + 1, (vt_25 * 2 + 12) % 13 + 1, (vt_25 * 9 + 15) % 17 + 1))
                vt_15 = (vector.create((vt_25 * 3 + 6) % 11 + 1, (vt_25 * 6 + 6) % 13 + 1, (vt_25 * 4 + 12) % 17 + 1))
                nV = (vector.create((vt_25 * 6 + 9) % 11 + 1, (vt_25 * 1 + 2) % 13 + 1, (vt_25 * 6 + 1) % 17 + 1))
                nW = (vector.create((vt_25 * 3 + 8) % 11 + 1, (vt_25 * 4 + 13) % 13 + 1, (vt_25 * 2 + 11) % 17 + 1))
                if vector.dot(vector.cross(vt_5, vt_15), (vector.cross(nV, nW))) == vector.dot(vt_5, nV) * vector.dot(vt_15, nW) - vector.dot(vt_5, nW) * vector.dot(vt_15, nV) then
                    vt_20 = game:GetService("ReplicatedStorage")
                else
                    nk = game:GetService("ReplicatedStorage")
                end
                vt_25 = (vt_25 + 23) % 72
            end
        elseif vt_22_1 <= 7 then
            if vt_22_1 <= 6 then
                if (vt_25 * 2 + 3) * 10 % 3 == ((vt_25 * 2 + 3) * 10 + 8) % 3 then
                    nD = game:GetService("RunService")
                    vt_3 = game:GetService("TweenService")
                else
                    vt_3 = game:GetService("RunService")
                    nD = game:GetService("TweenService")
                end
                vt_25 = (vt_25 + 23) % 72
            else
                if (vt_25 * 2 + 5) * 4 % 3 == ((vt_25 * 2 + 5) * 4 + 5) % 3 then
                    ny = game:GetService("Workspace")
                else
                    nB = game:GetService("Workspace")
                end
                vt_25 = (vt_25 + 5) % 72
            end
        elseif vt_22_1 <= 8 then
            if (vt_25 * 3 + 3) * 21 % 4 == ((vt_25 * 3 + 3) * 21 + 12) % 4 then
                ny = game:GetService("VirtualUser")
                UserInputService = game:GetService("UserInputService")
                ns = vt_14.LocalPlayer
            else
                ns = game:GetService("VirtualUser")
                ny = game:GetService("UserInputService")
                vt_14 = UserInputService.LocalPlayer
            end
            vt_25 = (vt_25 + 59) % 72
        else
            vt_5 = {
                "abhpatilkhq",
                "hlfqafuyxy",
                "yprsvoq",
                "kaazratc",
                "onzzdzaoqq",
                "ecaqfndoqxco",
                "xapjfkrlan",
                "qbefsqubs",
                "wpfljjrgy",
                "vigpcgcixcks",
                "koqasli",
                "hrhwkhf",
                "opsvsd",
                "uifhqhmyzphr"
            }
            if vt_5[(vt_25 * 63 + 32) % 14 + 1] < vt_5[(vt_25 * 63 + 32) % 14 + 1] then
                vt_20 = nk.Assets:FindFirstChild("Collectables") ~= nil
                nB = np:FindFirstChild("Lobby") ~= nil
            else
                np = vt_20.Assets:FindFirstChild("Collectables") ~= nil
                nk = nB:FindFirstChild("Lobby") ~= nil
            end
            vt_25 = (vt_25 + 5) % 72
        end
    elseif vt_22_1 <= 14 then
        if vt_22_1 <= 12 then
            if vt_22_1 <= 11 then
                if vt_22_1 <= 10 then
                    if vt_25 * 33665927 + 6 + 6 <= vt_25 * 33665927 + 6 + 6 + 2 then
                        vt_17 = fn541
                    else
                        mB = fn541
                    end
                    vt_25 = (vt_25 + 23) % 72
                else
                    if (vt_25 * 1 + 9) * 21 % 4 == ((vt_25 * 1 + 9) * 21 + 5) % 4 then
                        vt_20 = vt_7.Shared.Modules.Data
                    else
                        vt_7 = vt_20.Shared.Modules.Data
                    end
                    vt_25 = (vt_25 + 23) % 72
                end
            else
                vt_5 = { "nrndaz", "itlleq", "sgaebqlas", "guesahxwev", "unydqarlr", "azj", "bxpxi", "xtzgkpcm" }
                local wF = vt_25
                vt_15 = vt_5[wF % 8 + 1]
                if vt_15:len() <= vt_15:gsub("(.)", "%1%1", wF % 3 % 2 + 1):len() then
                    vt_12 = vt_17(vt_20.Shared.Modules.Game, "SignalBankClient")
                else
                    vt_17 = vt_20(vt_12.Shared.Modules.Game, "SignalBankClient")
                end
                vt_25 = (vt_25 + 23) % 72
            end
        elseif vt_22_1 <= 13 then
            if (vt_25 or vt_25 or (nB or not vt_25)) and (not ns or not vt_25 or ns and vt_25) and (nB and not vt_25 and (ns or not nB) or (nB or not vt_25) and (not nB or not nB)) and ((nB or vt_25 or not nB and vt_25 or (not nB and vt_25 or nB and nB)) and ((nB or nB or (vt_25 or not ns)) and (vt_25 or not ns or nB and not vt_25))) or not ((vt_25 or vt_25 or (nB or not vt_25)) and (not ns or not vt_25 or ns and vt_25) and (nB and not vt_25 and (ns or not nB) or (nB or not vt_25) and (not nB or not nB)) and ((nB or vt_25 or not nB and vt_25 or (not nB and vt_25 or nB and nB)) and ((nB or nB or (vt_25 or not ns)) and (vt_25 or not ns or nB and not vt_25)))) then
                vt_9 = vt_17(vt_7, "UpgradeData")
            else
                vt_7 = vt_9(vt_17, "UpgradeData")
            end
            vt_25 = (vt_25 + 23) % 72
        else
            local v7 = bit32.rrotate(bit32.bxor(bit32.lrotate(vt_25, 9), string.byte(tostring(vt_14))), 28)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(v7, 1623413311), 1041832079), (bit32.bxor(bit32.band(v7, 2671553984), 2304367120))), 1041832079), 2304367120) ~= v7 then
                vt_7 = mR(vt_17, "WeaponData")
            else
                mR = vt_17(vt_7, "WeaponData")
            end
            vt_25 = (vt_25 + 23) % 72
        end
    elseif vt_22_1 <= 16 then
        if vt_22_1 <= 15 then
            if vt_25 * 104681669 + 4 + 1 <= vt_25 * 104681669 + 4 + 1 + 5 then
                mO = vt_17(vt_7, "ChestData")
            else
                vt_7 = mO(vt_17, "ChestData")
            end
            vt_25 = (vt_25 + 59) % 72
        else
            local ww = bit32.rrotate(bit32.bxor(bit32.lrotate(vt_25, 4), string.byte(tostring(mJ))), 11)
            if bit32.bxor(bit32.lrotate(bit32.bxor(ww, 1494878882), 6), 1182967958) == bit32.lrotate(ww, 6) then
                mJ = vt_17(vt_7, "SkillTreeData")
            else
                vt_7 = mJ(vt_17, "SkillTreeData")
            end
            vt_25 = (vt_25 + 5) % 72
        end
    elseif vt_22_1 <= 17 then
        if ((not nk or not nk) and (nB or not UserInputService) and (not vt_20 or vt_14 or not nB and nB) or ((vt_14 or vt_14) and (UserInputService or not UserInputService) or vt_20 and not vt_20 and (not UserInputService or not nB))) and not ((not nk or not nk) and (nB or not UserInputService) and (not vt_20 or vt_14 or not nB and nB) or ((vt_14 or vt_14) and (UserInputService or not UserInputService) or vt_20 and not vt_20 and (not UserInputService or not nB))) then
            vt_17 = vt_7(mF, "QuestData")
        else
            mF = vt_17(vt_7, "QuestData")
        end
        vt_25 = (vt_25 + 41) % 72
    else
        local vt_22_2 = (vector.create((vt_25 * 1 + 9) % 11 + 1, (vt_25 * 6 + 11) % 13 + 1, (vt_25 * 15 + 14) % 17 + 1))
        vt_5 = (vector.create((vt_25 * 1 + 5) % 11 + 1, (vt_25 * 7 + 5) % 13 + 1, (vt_25 * 15 + 11) % 17 + 1))
        vt_15 = (vector.create((vt_25 * 4 + 4) % 5 + 1, (vt_25 * 2 + 6) % 7 + 1, (vt_25 * 1 + 7) % 9 + 1))
        if math.abs((vector.angle(vt_22_2, vt_5, vt_15))) - math.abs((vector.angle(vt_5, vt_22_2, vt_15))) == 4 then
            vt_7 = mB(vt_17, "WaveData")
        else
            mB = vt_17(vt_7, "WaveData")
        end
        vt_25 = (vt_25 + 23) % 72
    end
until (vt_25 * 59 + 20) % 72 == 2
if vt_1 then
    vt_1 = nF:FindFirstChild("leifstout_networker@0.3.1")
end
nF = vt_1
vt_14 = nF
if vt_14 then
    vt_25 = 6
    repeat
        local wB = bit32.rrotate(bit32.bxor(bit32.lrotate(vt_25, 6), string.byte(tostring(vt_25))), 29)
        if bit32.bxor(bit32.lrotate(bit32.bxor(wB, 877345641), 30), 1293078234) == bit32.lrotate(wB, 30) then
            vt_14 = nF.networker:FindFirstChild("_remotes")
        else
            nF = vt_14.networker:FindFirstChild("_remotes")
        end
        vt_25 = (vt_25 + 6) % 8
    until (vt_25 * 5 + 1) % 8 == 5
end
nF = vt_14
nz = function(H, I, ...)
    local o8 = nF and nF:FindFirstChild(H)
    if o8 then
        o8.RemoteEvent:FireServer(I, ...)
    end
end
ne = function(M, N, ...)
    local pb
    pb = nil
    local pd_1
    local pc = nF and nF:FindFirstChild(M)
    local pc_1
    pb = pc
    if not pb then
        return nil
    end
    pc_1, pd_1 = pcall(function(...)
        return pb.RemoteFunction:InvokeServer(N, ...)
    end, ...)
    local pc_2 = pc_1 and pd_1
    local pl = if pc_2 then 1 else 0
    local pj = 1809 * pl + 2788 * (1 - pl)
    local pk = 2441 * pl + 1604 * (1 - pl)
    if not ((pj * 3988 + pk * 3355 + pj * pk) % 16777213 == 3042403) then
        pc_2 = nil
    end
    return pc_2
end
if getgenv().TempoFinalSwarmUnload then
    vt_14 = 0
    repeat
        vt_25 = (vector.create((vt_14 * 6 + 3) % 11 + 1, (vt_14 * 1 + 10) % 13 + 1, (vt_14 * 9 + 15) % 17 + 1))
        vt_7 = (vector.create((vt_14 * 4 + 2) % 11 + 1, (vt_14 * 11 + 10) % 13 + 1, (vt_14 * 11 + 8) % 17 + 1))
        vt_17 = (vector.create((vt_14 * 5 + 1) % 11 + 1, (vt_14 * 4 + 3) % 13 + 1, (vt_14 * 9 + 8) % 17 + 1))
        vt_1 = (vector.create((vt_14 * 3 + 9) % 11 + 1, (vt_14 * 10 + 7) % 13 + 1, (vt_14 * 9 + 10) % 17 + 1))
        if vector.dot(vector.cross(vt_25, vt_7), (vector.cross(vt_17, vt_1))) == vector.dot(vt_25, vt_17) * vector.dot(vt_7, vt_1) - vector.dot(vt_25, vt_1) * vector.dot(vt_7, vt_17) + 5 then
            pcall(getgenv().TempoFinalSwarmUnload)
        else
            pcall(getgenv().TempoFinalSwarmUnload)
        end
        vt_14 = (vt_14 + 0) % 4
    until (vt_14 * 1 + 0) % 4 == 0
end
mL, mG, mC, vt_7 = nil, nil, nil, nil
vt_1 = "Final Swarm"
mL = "https://discord.gg/K7Qxnxkk46"
mG = "https://discord.gg/K7Qxnxkk46"
mC = { Common = 1, Rare = 2, Epic = 3, Legendary = 4 }
vt_17 = {}
if (false or mC) and (false or (vt_17 or mG) or (false or vt_17 or 11)) or (false or (not mC and false or not mC and mC) and (mC and "https://discord.gg/K7Qxnxkk46")) or not ((false or mC) and (false or (vt_17 or mG) or (false or vt_17 or 11)) or (false or (not mC and false or not mC and mC) and (mC and "https://discord.gg/K7Qxnxkk46"))) then
    vt_7 = {}
else
    mC = {}
end
for k, v in pairs(mR) do
    vt_14 = typeof(v) == "table" and not v.isLocked
    if vt_14 then
        table.insert(vt_7, k)
        table.insert(vt_17, k)
    end
end
for k, v in pairs(vt_9) do
    vt_14 = typeof(v) == "table" and v.Rarity
    if vt_14 then
        table.insert(vt_17, k)
    end
end
table.sort(vt_17)
table.sort(vt_7)
if #vt_17 == 0 then
    vt_17 = { "None" }
end
vt_7 = { "double", "freeze", "heart", "keys", "magnet", "shield", "xp" }
vt_25 = vt_20.Assets:FindFirstChild("Collectables")
if vt_25 then
    vt_7 = {}
    for i, child in vt_25:GetChildren() do
        table.insert(vt_7, child.Name)
    end
    table.sort(vt_7)
end
vt_25 = nil
vt_14 = 1
repeat
    if (vt_14 and not vt_14 or vt_14 and vt_25) and (vt_25 or not vt_14 or (not vt_25 or not vt_25)) and not ((vt_14 and not vt_14 or vt_14 and vt_25) and (vt_25 or not vt_14 or (not vt_25 or not vt_25))) then
        vt_25 = { "All", "Chests", "Pots" }
    else
        vt_25 = { "All", "Chests", "Pots" }
    end
    vt_14 = (vt_14 + 0) % 4
until (vt_14 * 3 + 0) % 4 == 3
for k, v in vt_7 do
    if not v:match("Chest$") then
        table.insert(vt_25, v)
    end
end
vt_14 = {}
for k, v in pairs(mB) do
    vt_7 = typeof(v) == "table" and v.number
    if vt_7 then
        table.insert(vt_14, k)
    end
end
vt_7 = 4
repeat
    vt_9 = {
        "hch",
        "sdrccz",
        "nmadxpnf",
        "svmfjolxukd",
        "bni",
        "fzlcceojavbk",
        "zbptzxc",
        "zjtaygdm",
        "zrtblsv",
        "xlngtecahto",
        "hbog",
        "uwepqhsrnrbf",
        "mmig",
        "mvkmigrn",
        "ceptmjthcf",
        "pqsh"
    }
    if vt_9[(vt_7 * 46 + 66) % 16 + 1] < vt_9[(vt_7 * 46 + 66) % 16 + 1] then
        table.sort(vt_14, fn234)
    else
        table.sort(vt_14, fn234)
    end
    vt_7 = (vt_7 + 7) % 8
until (vt_7 * 3 + 5) % 8 == 6
if #vt_14 == 0 then
    vt_14 = { "Grasslands" }
end
mM = {}
for k in pairs(mO) do
    table.insert(mM, k)
end
table.sort(mM, fn298)
vt_9 = {}
for k in pairs(mJ) do
    table.insert(vt_9, k)
end
table.sort(vt_9)
if #vt_9 == 0 then
    vt_9 = { "None" }
end
Library, Toggles, Options, m7, nC, nu, m9, mW, mP, mz, m4 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
nC = fn220
nu = fn458
m9 = fn322
mW = fn938
mP = fn1044
mz = fn445
Library = getgenv().Library
nW = getgenv().ThemeManager
nV = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
vt_7 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = mL, Copyable = true }, "|", vt_1 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
vt_15 = {
    Info = vt_7:AddTab("Info", "info"),
    Lobby = vt_7:AddTab("Lobby", "house"),
    Gamemode = vt_7:AddTab("Gamemode", "gamepad-2"),
    Settings = vt_7:AddTab("Settings", "settings")
}
if ((vt_7 or vt_7) and (not nu and vt_7) and (not vt_7 or nu or Options and not Options) or (not nu or Options or (not Options or not Options)) and (not Options and Options or vt_7 and Options) or (vt_7 or nu or not vt_7 and not Options or (not nu and not nu or (Options or not Options))) and ((not Options or Options) and (not Options or not Options) and ((not Options or Options) and (vt_7 or nu)))) and not ((vt_7 or vt_7) and (not nu and vt_7) and (not vt_7 or nu or Options and not Options) or (not nu or Options or (not Options or not Options)) and (not Options and Options or vt_7 and Options) or (vt_7 or nu or not vt_7 and not Options or (not nu and not nu or (Options or not Options))) and ((not Options or Options) and (not Options or not Options) and ((not Options or Options) and (vt_7 or nu)))) then
    m4 = "Join the Discord to suggest features for this script"
    m7 = fn595
else
    m7 = "Join the Discord to suggest features for this script"
    m4 = fn595
end
vt_5 = fn202
for k, v in vt_15 do
    vt_5(v)
end
vt_22_3, n_, nb, nZ, m5, vt_20, nY, Label, mN, nX, nG, nA = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
vt_7 = 14
repeat
    vt_5 = (vt_7 * 5 + 6) % 8 + 1
    if vt_5 <= 4 then
        if vt_5 <= 2 then
            if vt_5 <= 1 then
                if vt_7 * 80642007 + 13 + 1 >= vt_7 * 80642007 + 13 + 1 + 2 then
                    nZ = "#e8a34d"
                else
                    nb = "#e8a34d"
                end
                vt_7 = (vt_7 + 5) % 32
            else
                local wQ = bit32.rrotate(bit32.bxor(bit32.lrotate(vt_7, 6), string.byte(tostring(nG))), 21)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(wQ, 2899969823), 2314765128), (bit32.bxor(bit32.band(wQ, 1394997472), 2298333209))), 2314765128), 2298333209) == wQ then
                    nZ = "#8b93a3"
                    m5 = "Unknown"
                    pcall(fn100)
                    vt_20 = vt_15.Info:AddLeftGroupbox("Account", "circle-user")
                    vt_20:AddLabel(nA("User", ns.Name, vt_22_3), true)
                    vt_20:AddLabel(nA("Status", "Keyless", vt_22_3), true)
                    vt_20:AddLabel(nA("Executor", m5, vt_22_3), true)
                    nY = vt_15.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                    nY:AddLabel(nG(vt_1 .. " [" .. tostring(game.PlaceId) .. "]", n_), true)
                    nY:AddLabel(nA("Place ID", tostring(game.PlaceId), n_), true)
                    Label = nY:AddLabel(nA("Session time", "0s", nb), true)
                else
                    m5 = "#8b93a3"
                    nA = "Unknown"
                    pcall(fn100)
                    ns = nY.Info:AddLeftGroupbox("Account", "circle-user")
                    ns:AddLabel(nb("User", nil, n_), true)
                    ns:AddLabel(nb("Status", "Keyless", n_), true)
                    ns:AddLabel(nb("Executor", nA, n_), true)
                    vt_22_3 = nY.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                    vt_22_3:AddLabel(Label(vt_15 .. " [" .. tostring(game.PlaceId) .. "]", vt_20), true)
                    vt_22_3:AddLabel(nb("Place ID", tostring(game.PlaceId), vt_20), true)
                    nZ = vt_22_3:AddLabel(nb("Session time", "0s", nG), true)
                end
                vt_7 = (vt_7 + 21) % 32
            end
        elseif vt_5 <= 3 then
            if (vt_7 * 2 + 7) * 16 % 3 == ((vt_7 * 2 + 7) * 16 + 3) % 3 then
                mN = tostring(game.JobId)
            else
                vt_20 = tostring(game.JobId)
            end
            vt_7 = (vt_7 + 5) % 32
        else
            local wj = bit32.rrotate(bit32.bxor(bit32.lrotate(vt_7, 4), string.byte(tostring(Label))), 2)
            if bit32.bxor(bit32.lrotate(bit32.bxor(wj, 524173973), 2), 2096695892) ~= bit32.lrotate(wj, 2) then
                mN = #nX > 18
            else
                nX = #mN > 18
            end
            vt_7 = (vt_7 + 13) % 32
        end
    elseif vt_5 <= 6 then
        if vt_5 <= 5 then
            if (vt_7 * 2 + 6) * 10 % 3 == ((vt_7 * 2 + 6) * 10 + 2) % 3 then
                nX = fn78
            else
                nG = fn78
            end
            vt_7 = (vt_7 + 5) % 32
        else
            if vt_7 * 85063813 + 9 + 5 <= vt_7 * 85063813 + 9 + 5 + 1 then
                nA = fn141
            else
                nb = fn141
            end
            vt_7 = (vt_7 + 5) % 32
        end
    elseif vt_5 <= 7 then
        if vt_7 * 50756325 + 11 + 6 >= vt_7 * 50756325 + 11 + 6 + 4 then
            nY = "#7fd47f"
        else
            vt_22_3 = "#7fd47f"
        end
        vt_7 = (vt_7 + 29) % 32
    else
        vt_5 = {
            "vawrgfsklm",
            "ttmi",
            "nwekdsvb",
            "ydjnzbha",
            "qetkclkxjgh",
            "hak",
            "dklhjipzqryv",
            "imktydvkzfrh",
            "mpflfsil",
            "dryane",
            "jitt"
        }
        if vt_5[(vt_7 * 63 + 58) % 11 + 1] < vt_5[(vt_7 * 63 + 58) % 11 + 1] then
            nZ = "#6ec1ff"
        else
            n_ = "#6ec1ff"
        end
        vt_7 = (vt_7 + 5) % 32
    end
until (vt_7 * 31 + 10) % 32 == 4
if nX then
    vt_7 = 0
    repeat
        local we = bit32.rrotate(bit32.bxor(bit32.lrotate(vt_7, 31), string.byte(tostring(vt_7))), 30)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(we, 4214845259), 2631902467), (bit32.bxor(bit32.band(we, 80122036), 2193147454))), 2631902467), 2193147454) == we then
            nX = string.sub(mN, 1, 18) .. "..."
        else
            mN = string.sub(nX, 1, 18) .. "..."
        end
        vt_7 = (vt_7 + 3) % 4
    until (vt_7 * 3 + 3) % 4 == 0
end
vt_7 = nX or mN
nl, Label2, Label3, m3, m1, m0, mY, mU, connection, nq, nn, nh, nf, na, connection2, mV, mx, ng, m_, mS, mA, mX, nj, mv, mT, mH, nm, m2, m6, nc, mK, my, nt = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
vt_5 = vt_7
nY:AddLabel(nA("Server", vt_5, nZ), true)
nY:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
local ScriptsGroup = vt_15.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(nG("Included in this hub", nZ), true)
ScriptsGroup:AddLabel(nG(vt_1, n_), true)
local FeaturesGroup = vt_15.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(nG("Lobby Automation", n_), true)
FeaturesGroup:AddLabel(nG("Match Automation", nb), true)
FeaturesGroup:AddLabel(nG("Round Automation", nZ), true)
local SocialsGroup = vt_15.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = m4 })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = vt_15.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = m4 })
local FaqGroup = vt_15.Info:AddRightGroupbox("FAQ", "circle-help")
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
nl = os.clock()
task.spawn(worker)
local AutoPlayGroup = vt_15.Lobby:AddLeftGroupbox("Auto Play", "swords")
AutoPlayGroup:AddToggle("AutoPlay", { Text = "Auto Play", Default = false })
AutoPlayGroup:AddDropdown("PlayWorld", { Values = vt_14, Default = vt_14[1], Multi = false, Text = "World" })
AutoPlayGroup:AddDropdown("PlayDifficulty", {
    Values = { "Normal", "Hard", "Nightmare" },
    Default = "Normal",
    Multi = false,
    Text = "Difficulty"
})
AutoPlayGroup:AddDropdown("PlayerLimit", { Values = { "1", "2", "3", "4" }, Default = "1", Multi = false, Text = "Player Limit" })
AutoPlayGroup:AddToggle("FriendsOnly", { Text = "Friends Only", Default = false })
AutoPlayGroup:AddSlider("PlayRetry", { Text = "Retry Delay", Default = 10, Min = 3, Max = 60, Rounding = 0, Suffix = "s" })
mV = fn871
AutoPlayGroup:AddButton({ Text = "Start Now", Func = onStartNow })
nX = vt_15.Lobby:AddLeftGroupbox("Chests", "package")
nX:AddToggle("AutoLobbyChests", { Text = "Auto Open Chests", Default = false })
nX:AddDropdown("ChestTypes", { Values = mM, Default = {}, Multi = true, Text = "Chests" })
nX:AddToggle("ChestBuy", { Text = "Buy With Keys", Default = false })
nX:AddSlider("ChestBatch", { Text = "Open Per Cycle", Default = 1, Min = 1, Max = 10, Rounding = 0 })
nX:AddInput("ChestKeyReserve", { Text = "Keep Keys", Default = "0", Numeric = true, Finished = true })
nX:AddSlider("ChestDelay", { Text = "Cycle Delay", Default = 3, Min = 1, Max = 30, Rounding = 0, Suffix = "s" })
local vt_22_4 = vt_15.Lobby:AddLeftGroupbox("Quests", "scroll-text")
vt_22_4:AddToggle("AutoQuests", { Text = "Auto Claim Quests", Default = false })
vt_22_4:AddToggle("QuestDaily", { Text = "Daily", Default = true })
vt_22_4:AddToggle("QuestAchievements", { Text = "Achievements", Default = true })
vt_22_4:AddSlider("QuestDelay", { Text = "Cycle Delay", Default = 15, Min = 5, Max = 120, Rounding = 0, Suffix = "s" })
vt_20 = vt_15.Lobby:AddRightGroupbox("Skill Tree", "git-branch")
vt_20:AddToggle("AutoSkills", { Text = "Auto Buy Skill Nodes", Default = false })
vt_20:AddDropdown("SkillMode", {
    Values = { "Most Expensive", "Cheapest", "Priority List" },
    Default = "Most Expensive",
    Multi = false,
    Text = "Buy Order"
})
vt_20:AddDropdown("SkillPick", { Values = vt_9, Default = vt_9[1], Multi = false, Text = "Node" })
vt_20:AddInput("SkillPriority", { Text = "Priority Order", Default = "", Placeholder = "Damage1, MaxHealth1, ...", Finished = true })
Label2 = vt_20:AddLabel("Priority: empty", true)
Options.SkillPriority:OnChanged(fn504)
vt_20:AddButton({ Text = "Add To Priority", Func = onAddToPriority })
vt_20:AddButton({ Text = "Clear Priority", Func = onClearPriority })
fn504()
vt_20:AddInput("SkillKeyReserve", { Text = "Keep Keys", Default = "0", Numeric = true, Finished = true })
local GearGroup = vt_15.Lobby:AddRightGroupbox("Gear", "shield")
GearGroup:AddToggle("AutoEquip", { Text = "Auto Equip Available Gear", Default = false })
GearGroup:AddSlider("EquipDelay", { Text = "Cycle Delay", Default = 10, Min = 3, Max = 60, Rounding = 0, Suffix = "s" })
local CollectGroup = vt_15.Gamemode:AddLeftGroupbox("Collect", "sparkles")
CollectGroup:AddToggle("AutoCollect", { Text = "Auto Collect", Default = false })
CollectGroup:AddDropdown("CollectTypes", { Values = vt_25, Default = { "xp", "keys" }, Multi = true, Text = "Pickups" })
CollectGroup:AddSlider("CollectRadius", { Text = "Search Radius", Default = 120, Min = 20, Max = 400, Rounding = 0, Suffix = " studs" })
CollectGroup:AddSlider("CollectSpeed", { Text = "Travel Speed", Default = 60, Min = 16, Max = 250, Rounding = 0 })
CollectGroup:AddToggle("CollectInstant", { Text = "Instant Teleport", Default = false })
local FarmGroup = vt_15.Gamemode:AddRightGroupbox("Farm", "swords")
FarmGroup:AddToggle("AutoFarm", { Text = "Auto Farm", Default = false })
FarmGroup:AddDropdown("FarmMethod", { Values = { "Below", "Orbit", "Above" }, Default = "Above", Multi = false, Text = "Farm Method" })
FarmGroup:AddSlider("FarmOffset", { Text = "Offset", Default = 18, Min = 5, Max = 60, Rounding = 0, Suffix = " studs" })
FarmGroup:AddSlider("FarmSearch", { Text = "Enemy Search", Default = 90, Min = 20, Max = 300, Rounding = 0, Suffix = " studs" })
FarmGroup:AddSlider("FarmSpeed", { Text = "Tween Speed", Default = 24, Min = 8, Max = 60, Rounding = 0 })
local RoundGroup = vt_15.Gamemode:AddLeftGroupbox("Round", "rotate-cw")
RoundGroup:AddToggle("AutoSkipFinalWave", { Text = "Auto Skip Waves", Default = false })
RoundGroup:AddToggle("EnableAutoSkipOnce", { Text = "Enable Auto Skip Once", Default = false })
RoundGroup:AddToggle("AutoPlayAgain", { Text = "Auto Play Again", Default = false })
RoundGroup:AddToggle("AutoGiveUp", { Text = "Auto Give Up When Dead", Default = false })
local SurvivalGroup = vt_15.Gamemode:AddRightGroupbox("Survival", "shield")
SurvivalGroup:AddToggle("AutoRetreat", { Text = "Retreat At Low HP", Default = false })
SurvivalGroup:AddSlider("RetreatHealth", { Text = "Retreat At", Default = 35, Min = 5, Max = 95, Rounding = 0, Suffix = "%" })
SurvivalGroup:AddSlider("RetreatResume", { Text = "Resume At", Default = 70, Min = 10, Max = 100, Rounding = 0, Suffix = "%" })
local AutoCardGroup = vt_15.Gamemode:AddLeftGroupbox("Auto Card", "wand-sparkles")
AutoCardGroup:AddToggle("AutoCard", { Text = "Auto Pick Priority", Default = false })
AutoCardGroup:AddToggle("AutoCardRandom", { Text = "Auto Pick Random", Default = false })
AutoCardGroup:AddSlider("CardDelay", { Text = "Pick Delay", Default = 1.5, Min = 0.2, Max = 10, Rounding = 1, Suffix = "s" })
AutoCardGroup:AddDropdown("CardFallback", {
    Values = { "Highest Rarity", "Lowest Rarity", "First Card" },
    Default = "Highest Rarity",
    Multi = false,
    Text = "Fallback"
})
AutoCardGroup:AddToggle("PreferWeapons", { Text = "Prefer New Weapons", Default = false })
AutoCardGroup:AddDropdown("CardBlacklist", { Values = vt_17, Default = {}, Multi = true, Text = "Never Pick" })
local PriorityGroup = vt_15.Gamemode:AddRightGroupbox("Priority", "list-ordered")
PriorityGroup:AddDropdown("PriorityPick", { Values = vt_17, Default = vt_17[1], Multi = false, Text = "Card" })
PriorityGroup:AddInput("PriorityList", {
    Text = "Priority Order",
    Default = "",
    Placeholder = "Multishot, Damage Legendary, ...",
    Finished = true
})
Label3 = PriorityGroup:AddLabel("Priority: empty", true)
mx = fn132
Options.PriorityList:OnChanged(fn63)
PriorityGroup:AddButton({ Text = "Add To Priority", Func = onAddToPriority2 })
PriorityGroup:AddButton({ Text = "Remove From Priority", Func = onRemoveFromPriority })
PriorityGroup:AddButton({ Text = "Move Up", Func = onMoveUp })
PriorityGroup:AddButton({ Text = "Clear Priority", Func = onClearPriority2 })
fn63()
ng = fn122
if nf and not nm and (not nf or not nm) and (nf or not nf or (not nf or not CollectGroup)) and not (nf and not nm and (not nf or not nm) and (nf or not nf or (not nf or not CollectGroup))) then
    mX = fn821
    m_ = fn852
    mS = fn952
    mA = fn353
else
    m_ = fn821
    mS = fn852
    mA = fn952
    mX = fn353
end
nj = fn605
mv = fn762
m3 = 0
m1 = false
m0 = nil
mY = nil
mU = nil
mT = fn716
mH = fn842
nm = fn535
m2 = fn977
connection = vt_3.Heartbeat:Connect(onHeartbeat)
nq = 0
nn = 0
nh = 0
nf = 0
na = false
m6 = fn95
task.spawn(autoSkipFinalWaveLoop)
nc = function(gw)
    local sY = {}
    for k in pairs(gw) do
        table.insert(sY, k)
    end
    table.sort(sY, function(gz, gA)
        return gw[gz][3] < gw[gA][3]
    end)
    local sZ = {}
    for i, v in ipairs(sY) do
        table.insert(sZ, { key = v, index = i, rarity = gw[v][1], isWeapon = mR[v] ~= nil })
    end
    return sZ
end
mK = fn450
my = fn42
nt = fn357
connection2 = nil
if np and vt_12.LEVEL_UP then
    connection2 = vt_12.LEVEL_UP:Connect(function(hw)
        local t0 = Toggles.AutoCard.Value or Toggles.AutoCardRandom.Value
        local t0_1
        if not t0 then
            return
        end
        if not hw then
            return
        end
        local t1 = hw[1] == nil and next(hw) ~= nil
        if t1 then
            t0_1 = { hw }
        else
            t0_1 = hw
        end
        local t1_1 = t0_1
        task.spawn(nt, t1_1)
    end)
end
nd, m8, connection3, connection4, nr, mZ = nil, nil, nil, nil, nil, nil
task.spawn(autoPlayLoop)
task.spawn(autoLobbyChestsLoop)
nr = fn333
task.spawn(autoSkillsLoop)
task.spawn(autoQuestsLoop)
task.spawn(autoEquipLoop)
nd = tick()
m8 = tick()
pcall(function()
    for i, v in ipairs(getconnections(ns.Idled)) do
        local vb = v
        pcall(function()
            vb:Disable()
        end)
    end
end)
mZ = fn76
connection3 = UserInputService.InputBegan:Connect(onInputBegan)
connection4 = UserInputService.InputChanged:Connect(onInputChanged)
vt_25 = vt_15.Settings:AddLeftGroupbox("Menu", "menu")
vt_25:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
vt_25:AddButton("Unload", onUnload)
vt_25:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
task.spawn(antiAfkLoop)
getgenv().TempoFinalSwarmUnload = fn925
Library:OnUnload(fn212)
nW:SetLibrary(Library)
nV:SetLibrary(Library)
nW:SetFolder("TempoHub")
nV:SetFolder("TempoHub/final-swarm")
nV:IgnoreThemeSettings()
nV:SetIgnoreIndexes({ "MenuKeybind" })
nW:SaveDefault("Monochrome")
nW:ApplyToTab(vt_15.Settings)
nW:LoadDefault()
nV:BuildConfigSection(vt_15.Settings)
nV:LoadAutoloadConfig()
end)(...)

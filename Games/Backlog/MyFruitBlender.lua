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
getgenv().TempoHoodSubtitle = "MY FRUIT BLENDER"
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
local zP_6, zP_12, zP_15, zP_16, FarmGroup, zP_20, MovementGroup, zP_27, zP_28, JuiceGroup, zP_35, zP_36, zP_40, zP_45, zP_50
local p0
local qI
local pI
local qp
local pp
local p6
local qO
local o6
local pO
local UserInputService
local pv
local qc
local pc
local pU
local HttpService
local pB
local qi
local pi
local p_
local qH
local Options
local qo
local po
local Label
local qN
local pN
local qu
local pu
local PlayerGui
local pb
local pT
local qA
local pA
local CoreGui
local ph
local pZ
local qG
local pG
local qn
local Library
local p4
local qM
local pM
local qt
local pt
local qa
local pa
local pS
local qz
local pz
local qg
local pg
local qF
local pF
local qm
local pm
local p3
local ReplicatedStorage
local Toggles
local VirtualUser
local ps
local p9
local o9
local pR
local qy
local py
local qf
local ShopConfig
local pX
local qE
local pE
local connection
local p2
local qK
local pK
local qr
local pr
local p8
local connection2
local pQ
local qx
local px
local LocalPlayer
local pe
local pW
local qD
local pD
local qk
local pk
local qJ
local CurrentCamera
local qq
local pq
local p7
local qP
local o7
local SaveManager
local qw
local pw
local qd
local pd
local pV
local qC
local pC
local qj
local pj
function fns.fn19()
    local yk = {}
    for k, v in { Toggles, Options } do
        for k, v in pairs(v) do
            local yl = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if yl then
                local yl_1 = ps(k, v)
                if yl_1 then
                    yk[#yk + 1] = yl_1
                end
            end
        end
    end
    table.sort(yk, function(ju, jv)
        if ju.type ~= jv.type then
            return ju.type < jv.type
        end
        return ju.idx < jv.idx
    end)
    return { objects = yk }
end
function fns.fn38(fm, fn)
    local vS = qD(fm)
    local vT = vS and vS:FindFirstChild(fn)
    local vT_1 = qm(vT, "PullPrompt")
    return pg(vT_1)
end
function fns.onCopySolanaAddress()
    pD(p7, "Copied Solana address")
end
function fns.fn76(c0)
    local tV = pi(c0) and pI(c0) > 0
    return tV
end
function fns.fn77(i8, i9)
    local x7_1 = (i8 == "Toggle" and Toggles or Options)[i9]
    local x6_2 = type(x7_1) == "table" and x7_1.Type == i8
    return x6_2 and x7_1 or nil
end
function fns.fn102(bh)
    local st = Options[bh]
    local su = st and st.Value
    local su_1 = type(su) == "table" and su
    local st_2 = {}
    local sv = su_1
    local sz = if sv then 1 else 0
    local sx = 3215 * sz + 2491 * (1 - sz)
    local sy = 85 * sz + 2551 * (1 - sz)
    if not ((sx * 3336 + sy * 3751 + sx * sy) % 16777213 == 11317350) then
        sv = st_2
    end
    return sv
end
function fns.fn106(eu)
    local vm_1
    local vl_1
    vl_1, vm_1 = nil, nil
    local vn = eu and eu:FindFirstChild("RollInfo")
    local vo = vn
    if vn then
        vn = vo:FindFirstChild("MultRow")
    end
    local vo_1 = vn
    if vo_1 then
        local vn_1 = {}
        for i, child in vo_1:GetChildren() do
            local vo_2 = child:IsA("TextLabel") or child:IsA("TextButton")
            if vo_2 then
                vn_1[#vn_1 + 1] = child
            end
        end
        table.sort(vn_1, function(eF, eG)
            return eF.LayoutOrder < eG.LayoutOrder
        end)
        for k, v in vn_1 do
            local Text = v.Text
            local vo_3 = string.lower(Text)
            local vp_1 = pS(Text)
            if vp_1 then
                if string.find(vo_3, "juice", 1, true) then
                    vm_1 = vp_1
                elseif vl_1 == nil then
                    vl_1 = vp_1
                end
            end
        end
    end
    local vn_3 = eu and eu:FindFirstChild("BuyPrompt")
    local vo_4 = vn_3
    if vn_3 then
        vn_3 = vo_4.ObjectText
    end
    local vo_5 = vn_3
    if type(vo_5) == "string" then
        local vn_4 = tonumber(string.match(vo_5, "[$%s]*x([%d%.]+)"))
        local vp_2 = tonumber(string.match(vo_5, "[Jj]uice%s*x([%d%.]+)"))
        if vn_4 and vl_1 == nil then
            vl_1 = vn_4
        end
        if vp_2 then
            vm_1 = vp_2
        end
    end
    return vl_1 or 1, vm_1
end
function fns.fn124(dp, dq)
    local ud = os.clock() + dq
    while true do
        local ue = dp and dp.Parent and os.clock() < ud and not Library.Unloaded
        if not ue then
            local ue_1 = dp and pI(dp) > 0
            return ue_1
        end
        if pI(dp) > 0 then
            break
        end
        task.wait(0.1)
    end
    return true
end
function fns.fn142()
    p2(Toggles.AntiGameplayPause.Value)
end
function fns.fn150()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local sH = leaderstats and leaderstats:FindFirstChild("Coins")
    local sG_1 = sH
    if sH then
        sH = tonumber(sG_1.Value)
    end
    return sH or 0
end
function fns.fn155()
    local Character = LocalPlayer.Character
    local sE = Character and Character:FindFirstChild("HumanoidRootPart")
    return sE
end
function fns.onUnload()
    Library:Unload()
end
function fns.onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in Character:GetDescendants() do
                local xc_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if xc_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
function fns.worker2()
    local w8_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local w7 = math.floor(os.clock() - pv)
        if w7 < 60 then
            w8_1 = w7 .. "s"
        elseif w7 < 3600 then
            w8_1 = string.format("%dm %ds", math.floor((w7) / (60)), w7 % 60)
        else
            w8_1 = string.format("%dh %dm", math.floor((w7) / (3600)), math.floor((w7 % 3600) / (60)))
        end
        Label:SetText(pq("Session time", w8_1, qM))
    end
end
function fns.onInputBegan()
    qa = tick()
end
function fns.fn252(c5)
    local t_ = pi(c5) and pI(c5) <= 0
    return t_
end
function fns.fn255(eh)
    local u3 = eh and eh:FindFirstChild("Roll Slots")
    return u3
end
function fns.fn262(at, au)
    if setclipboard then
        setclipboard(at)
    elseif toclipboard then
        toclipboard(at)
    end
    Library:Notify(au)
end
function fns.worker4()
    while not Library.Unloaded do
        local yZ = qz("FarmDelay", 0.35)
        local y_ = pW()
        if y_ then
            local y0 = pa("AutoCollect") or pa("AutoHarvest") or pa("AutoHarvestMutation")
            if y0 then
                local y0_1 = {}
                if pa("AutoCollect") then
                    for k, v in qA(y_, "Collect") do
                        y0_1[#y0_1 + 1] = v
                    end
                end
                if pa("AutoHarvest") then
                    for k, v in qA(y_, "Harvest") do
                        y0_1[#y0_1 + 1] = v
                    end
                end
                if pa("AutoHarvestMutation") then
                    for k, v in pN(y_, "Collect") do
                        y0_1[#y0_1 + 1] = v
                    end
                    for k, v in pN(y_, "Harvest") do
                        y0_1[#y0_1 + 1] = v
                    end
                end
                local y1_1 = {}
                for k, v in y0_1 do
                    local y0_2 = Library.Unloaded
                    if not y0_2 then
                        local y2_1 = pa("AutoCollect") or pa("AutoHarvest") or pa("AutoHarvestMutation")
                        y0_2 = not y2_1
                    end
                    if y0_2 then
                        break
                    elseif not y1_1[v] then
                        y1_1[v] = true
                        local BasePart = v:FindFirstChildWhichIsA("BasePart", true)
                        if BasePart then
                            o6(BasePart.Position)
                        end
                        pc(o7, v)
                        task.wait(yZ)
                    end
                end
            end
            if pa("AutoBuySeeds") then
                qF()
            end
            if pa("AutoPlant") then
                local y0_4 = pM()
                local y1_2 = not y0_4
                if y1_2 ~= false then
                    y1_2 = pa("AutoBuySeeds")
                end
                if y1_2 then
                    qF()
                    task.wait(yZ)
                    y0_4 = pM()
                end
                if y0_4 then
                    pz(y0_4)
                    local y1_3 = (pQ(y0_4))
                    local zy = if y1_3 then 1 else 0
                    local zw = 2274 * zy + 2066 * (1 - zy)
                    local zx = 3067 * zy + 1883 * (1 - zy)
                    if not ((zw * 1614 + zx * 1097 + zw * zx) % 16777213 == 14009093) then
                        y1_3 = qk()[1]
                    end
                    local y0_5 = y1_3 or "BlueBerry"
                    for k, v in pk() do
                        local y0_6 = Library.Unloaded or not pa("AutoPlant")
                        if y0_6 then
                            break
                        elseif not pM() then
                            break
                        elseif not qq(y_, v) then
                            o6(v)
                            pc(qN, v, y0_5)
                            task.wait(yZ)
                        end
                    end
                end
            end
            if pa("AutoBlend") then
                local y0_7 = pu(qg)
                if y0_7 then
                    local y1_5 = pe(y_, "InsertPrompt")
                    local y2_2 = qx(y0_7)
                    if y1_5 and y2_2 then
                        pz(y0_7)
                        o6(y1_5.Position)
                        pc(qw, y1_5, y2_2)
                        task.wait(yZ)
                    end
                    pc(qE)
                end
            end
            if pa("AutoFillCup") then
                if p0(y_) > 0 then
                    local y0_8 = pu(qp)
                    local y1_6 = not y0_8
                    if y1_6 ~= false then
                        y1_6 = pa("AutoBuyCup")
                    end
                    if y1_6 then
                        pc(pC, "Cup1")
                        task.wait(yZ)
                        y0_8 = pu(qp)
                    end
                    if y0_8 then
                        local y1_7 = pe(y_, "FillPrompt")
                        local y2_3 = qx(y0_8)
                        if y1_7 and y2_3 then
                            pz(y0_8)
                            o6(y1_7.Position)
                            pc(qu, y1_7, y2_3)
                            o9(y0_8, math.max(1.2, yZ * 4))
                        end
                    end
                end
            end
            if pa("AutoPlaceCup") then
                local y0_9 = pu(qP)
                local y1_8 = qx(y0_9)
                local y2_4 = y0_9 and y1_8 and pI(y0_9) > 0
                if y2_4 then
                    pz(y0_9)
                    local Stand = y_:FindFirstChild("Stand")
                    local y__1 = Stand and Stand:FindFirstChild("Ledge")
                    if y__1 then
                        o6(y__1.Position)
                    end
                    pc(qn, y1_8)
                    task.wait(yZ)
                end
            end
        elseif pa("AutoBuySeeds") then
            qF()
        end
        task.wait(yZ)
    end
end
function fns.fn267()
    local function r_(aa)
        local rV = not aa
        local rZ = if rV then 1 else 0
        local rX = 496 * rZ + 833 * (1 - rZ)
        local rY = 216 * rZ + 3796 * (1 - rZ)
        if not ((rX * 1463 + rY * 3796 + rX * rY) % 16777213 == 1652720) then
            rV = not aa:IsA("ScreenGui")
        end
        if rV then
            return
        end
        aa.ResetOnSpawn = false
        aa.IgnoreGuiInset = true
        aa.DisplayOrder = math.max(aa.DisplayOrder, 1000)
        if aa.Parent ~= CoreGui then
            aa.Parent = CoreGui
        end
    end
    r_(Library.ScreenGui)
    if Library.ActiveLoading and Library.ActiveLoading.ScreenGui then
        r_(Library.ActiveLoading.ScreenGui)
    end
    for k, v in { "Obsidian", "ObsidianLoading" } do
        local r0_1 = CoreGui:FindFirstChild(v) or PlayerGui:FindFirstChild(v)
        if r0_1 then
            r_(r0_1)
        end
    end
end
function fns.fn269()
    if not Toggles.Fly.Value then
        local xw = pd()
        if xw then
            xw.PlatformStand = false
        end
    end
end
function fns.worker7()
    while not Library.Unloaded do
        if pa("AutoBuyEgg") then
            local zH_1 = p9("EggId", "Common")
            if qH("Pets", zH_1) > 0 then
                local zI_1 = qt("Pets", zH_1)
                local zJ_1 = zI_1 and tonumber(zI_1.price)
                local zI_2 = zJ_1 or 0
                if qr() >= zI_2 then
                    pc(pK, zH_1)
                end
            end
        end
        if pa("AutoBuyGear") then
            local zH_2 = p9("GearId", "SprinklerCommon")
            if qH("Gear", zH_2) > 0 then
                local zI_3 = qt("Gear", zH_2)
                local zJ_3 = zI_3 and tonumber(zI_3.price)
                local zI_4 = zJ_3 or 0
                if qr() >= zI_4 then
                    pc(pG, zH_2)
                end
            end
        end
        task.wait(3)
    end
end
function fns.fn305(cL)
    local tG_1
    local tF_1
    if type(cL) ~= "string" then
        return 0
    end
    tF_1, tG_1 = string.match(string.lower(cL), "([%d,.]+)%s*([kmb]?)ml")
    if not tF_1 then
        return 0
    end
    local tH = tonumber((string.gsub(tF_1, ",", ""))) or 0
    local tF_2 = tH
    if tG_1 == "k" then
        tF_2 *= 1000
    elseif tG_1 == "m" then
        tF_2 *= 1000000
    elseif tG_1 == "b" then
        tF_2 *= 1000000000
    end
    return tF_2
end
function fns.antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            p2(true)
        end
    end
end
function fns.fn309(a4, a5)
    local sj = Options[a4]
    local sk = sj and tonumber(sj.Value)
    return sk or a5
end
function fns.fn321()
    local v4 = pp()
    if not v4 then
        return {}
    end
    local v5 = {}
    local Size = v4.Size
    local CFrame = v4.CFrame
    local v4_1 = 6
    local v8 = math.max(3, Size.X / 2 - 3)
    local v9 = math.max(3, Size.Z / 2 - 3)
    local we = -v8
    local wd = 6
    while true and we <= v8 or false and we >= v8 do
        local wf = we
        local wj = -v9
        while true and wj <= v9 or false and wj >= v9 do
            local wk = wj
            v5[#v5 + 1] = CFrame:PointToWorldSpace(Vector3.new(wf, Size.Y / 2 + 0.15, wk))
            wj += v4_1
        end
        we += wd
    end
    return v5
end
function fns.fn324()
    local wY_1
    local wX_1
    if identifyexecutor then
        wY_1, wX_1 = identifyexecutor()
        local wZ = wY_1 ~= ""
        local w_ = type(wY_1) == "string" and wZ
        if w_ then
            local wZ_1 = type(wX_1) == "string" and wX_1 ~= "" and wY_1 .. " " .. wX_1
            qC = wZ_1 or wY_1
        end
    end
end
function fns.onCopyLitecoinAddress()
    pD(qo, "Copied Litecoin address")
end
function fns.onCopyUSDTAddress()
    pD(qd, "Copied USDT address")
end
function fns.fn359(dB)
    if not dB then
        return false
    elseif dB:GetAttribute("SeedId") then
        return true
    else
        return string.find(dB.Name, "Seed", 1, true) ~= nil
    end
end
function fns.fn370(aU)
    local DiscordGroup = aU:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = po })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = po })
end
function fns.fn377(bP)
    local sW = qJ()
    local sX = sW and typeof(bP) == "Vector3"
    if sX then
        sW.CFrame = CFrame.new(bP + Vector3.new(0, 4, 0))
    end
end
function fns.onImportConfigFromClipboardTex()
    local yN_1
    local yL = Options.SaveManager_ImportSource.Value or ""
    local yL_1
    local yM = tostring(yL):match("^%s*(.-)%s*$")
    if yM == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    yL_1, yN_1 = pcall(HttpService.JSONDecode, HttpService, yM)
    local yM_1 = not yL_1 or type(yN_1) ~= "table" or type(yN_1.objects) ~= "table"
    if yM_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local yL_2 = 0
    for k, v in yN_1.objects do
        if pV(v) then
            yL_2 += 1
        end
    end
    if yL_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local yN_2 = yL_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(yL_2, yN_2), 6)
end
function fns.fn403(ek, el)
    if not ek then
        return nil
    end
    for i, descendant in ek:GetDescendants() do
        local u5 = descendant:IsA("ProximityPrompt") and descendant.Name == el and descendant.Enabled
        if u5 then
            return descendant
        end
    end
    return nil
end
function fns.worker5()
    while not Library.Unloaded do
        if pa("AutoDaily") then
            pc(pZ)
        end
        if pa("AutoGroup") then
            pc(pT)
        end
        if pa("AutoOffline") then
            pc(pO)
        end
        if pa("AutoBlade") then
            pc(p6)
        end
        if pa("AutoBuyJuice") then
            pc(pw, "Juice", false)
        end
        if pa("AutoBuyUpgrades") then
            pc(pw, "Cup", false)
            pc(pw, "Blade", false)
            pc(pw, "Juice", false)
            pc(pt)
        end
        task.wait(4)
    end
end
function fns.fn440(cg, ch)
    local ShopState = ReplicatedStorage:FindFirstChild("ShopState")
    local te = ShopState and ShopState:FindFirstChild(cg)
    local td_1 = te
    if te then
        te = td_1:FindFirstChild(ch)
    end
    local td_2 = te
    if te then
        te = tonumber(td_2.Value)
    end
    local td_3 = te or 0
    local ShopBought = LocalPlayer:FindFirstChild("ShopBought")
    local tf = ShopBought and ShopBought:FindFirstChild(cg .. ":" .. ch)
    local max = math.max
    local tg = tf and tonumber(tf.Value)
    local td_6 = tg or 0
    return max(0, td_3 - td_6)
end
function fns.fn453(cQ)
    if not cQ then
        return 0
    end
    local tM = p8(cQ.Name)
    if tM > 0 then
        return tM
    end
    local tM_1 = tonumber(cQ:GetAttribute("Mutation"))
    if tM_1 and tM_1 > 0 then
        return tM_1
    end
    local tM_2 = cQ:GetAttribute("SlotLabelSub") or ""
    return p8(tostring(tM_2))
end
function fns.fn470(ba, bb)
    local sm = Options[ba]
    local sn = sm and sm.Value
    local sn_1 = sn ~= ""
    local so = type(sn) == "string" and sn_1
    if so then
        return sn
    end
    return bb
end
function fns.onExportConfigToClipboard()
    local yI_1
    local yH_1
    yH_1, yI_1 = pcall(HttpService.JSONEncode, HttpService, pb())
    if not yH_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local yH_2 = setclipboard or toclipboard
    local yH_3 = type(yH_2) ~= "function" or not pcall(yH_2, yI_1)
    if yH_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
function fns.onCopyVenmoLink()
    pD(pU, "Copied Venmo link")
end
function fns.fn532(jg, jh)
    local Type = jh.Type
    if Type == "Toggle" then
        return { idx = jg, type = "Toggle", value = jh.Value == true }
    elseif Type == "Slider" then
        return { idx = jg, type = "Slider", value = tostring(jh.Value) }
    elseif Type == "Dropdown" then
        return { idx = jg, type = "Dropdown", multi = jh.Multi == true, value = jh.Value }
    elseif Type == "Input" then
        local ye = jh.Value or ""
        return { idx = jg, type = "Input", text = tostring(ye) }
    elseif Type == "ColorPicker" then
        return { idx = jg, type = "ColorPicker", value = jh.Value:ToHex(), transparency = jh.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = jg,
            type = "KeyPicker",
            mode = jh.Mode,
            key = jh.Value,
            modifiers = jh.Modifiers,
            toggled = jh.Toggled
        }
    else
        return nil
    end
end
function fns.fn546(bU, bV)
    local s__1
    local sZ_1
    sZ_1, s__1 = pcall(ShopConfig.ItemInfo, bU, bV)
    local s0 = sZ_1 and type(s__1) == "table"
    if s0 then
        return s__1
    end
    return nil
end
function fns.fn558()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    p3 = tick()
end
function fns.fn563(eq)
    if type(eq) ~= "string" then
        return nil
    end
    local vd = string.lower(eq)
    local ve = vd == "|"
    local vf = vd == ""
    local vk = if vf then 1 else 0
    local vi = 1205 * vk + 858 * (1 - vk)
    local vj = 3318 * vk + 3610 * (1 - vk)
    if not ((vi * 3981 + vj * 1545 + vi * vj) % 16777213 == 13921605) then
        vf = ve
    end
    if vf or vd == "label" then
        return nil
    end
    local ve_2 = tonumber(string.match(vd, "([%d%.]+)"))
    return ve_2
end
function fns.onRscripts()
    pD(pm, "Copied Rscripts profile to clipboard")
end
function fns.fn604()
    local sT = pW()
    local sU = sT and sT:FindFirstChild("soil")
    local sT_1 = sU
    if sU then
        sU = sT_1:FindFirstChild("Main")
    end
    return sU
end
function fns.fn613(dy)
    local ug = not dy or dy:GetAttribute("ItemKind") == "Cup"
    if ug then
        return false
    end
    return dy:GetAttribute("FruitId") ~= nil
end
function fns.fn624()
    local xS = if pa("AutoSell") then 1 else 0
    if xS == 1 then
        qK()
    end
end
function fns.fn640(dD)
    local uj = dD and dD:GetAttribute("SeedId")
    local uj_1 = uj ~= ""
    local ul = type(uj) == "string" and uj_1
    if ul then
        return uj
    end
    return nil
end
function fns.fn643(t)
    if cloneref then
        return cloneref(t)
    end
    return t
end
function fns.worker6()
    while not Library.Unloaded do
        local zE = qz("RollDelay", 0.5)
        local zF = pW()
        if zF then
            if pa("AutoBuyRolledCup") then
                qy(zF, "Cup Roll Slot")
            end
            if pa("AutoBuyRolledCart") then
                qy(zF, "Stands Roll slot")
            end
            if pa("AutoRollCup") then
                pj(zF, "Cup Roll Lever")
            end
            if pa("AutoRollCart") then
                pj(zF, "Stand Skins Lever")
            end
        end
        task.wait(zE)
    end
end
function fns.fn670(gu, gv)
    return string.format('<font color="%s">%s</font>', gv, gu)
end
function fns.fn676(gx, gy, gz)
    return string.format("<b>%s</b> %s %s", gx, pA("-", "#5a6070"), pA(gy, gz))
end
function fns.fn677()
    pD(pr, "Copied Discord invite to clipboard")
end
function fns.fn695()
    local PlotNumber = LocalPlayer:FindFirstChild("PlotNumber")
    if not PlotNumber or PlotNumber.Value == 0 then
        return nil
    end
    local Map = workspace:FindFirstChild("Map")
    local sL = Map and Map:FindFirstChild("Plots")
    local sK_2 = sL
    if sL then
        sL = sK_2:FindFirstChild(tostring(PlotNumber.Value))
    end
    return sL
end
function fns.fn700()
    return CoreGui
end
function fns.fn737(dN, dO)
    if not dN then
        return nil
    end
    for i, descendant in dN:GetDescendants() do
        local ut = descendant:IsA("ProximityPrompt") and descendant.Name == dO
        if ut then
            return descendant.Parent
        end
    end
    return nil
end
function fns.onCopyBitcoinAddress()
    pD(qj, "Copied Bitcoin address")
end
function fns.onInputChanged(iT)
    local UserInputType = iT.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        qa = tick()
    end
end
function fns.fn791(e5, e6)
    local vN_1
    local vK = qD(e5)
    local vL = vK and vK:FindFirstChild(e6)
    local vL_2
    local vK_1 = vL
    if vL then
        vL = vK_1:FindFirstChild("Main")
    end
    local vK_2 = vL
    if vL then
        vL = vK_2:FindFirstChild("BuyPrompt")
    end
    local vM = vL
    if not vM or not vM.Enabled then
        return false
    end
    vN_1, vL_2 = pB(vK_2)
    local vR = if not px(vN_1, vL_2) then 1 else 0
    if vR == 1 then
        return false
    end
    return pg(vM)
end
function fns.fn824(cW)
    local tP = cW
    if tP then
        local tQ = cW:GetAttribute("ItemKind") == "Cup"
        local tU = if tQ then 1 else 0
        local tS = 802 * tU + 1001 * (1 - tU)
        local tT = 74 * tU + 3026 * (1 - tU)
        if not ((tS * 3465 + tT * 2727 + tS * tT) % 16777213 == 3040076) then
            tQ = cW:GetAttribute("ItemType") == "Cup"
        end
        tP = tQ
    end
    return tP
end
function fns.fn825()
    if not Toggles.WalkSpeedEnabled.Value then
        local xy = pd()
        if xy then
            xy.WalkSpeed = 16
        end
    end
end
function fns.onCopyEthereumAddress()
    pD(qf, "Copied Ethereum address")
end
function fns.fn884()
    local Character = LocalPlayer.Character
    local sB = Character and Character:FindFirstChildOfClass("Humanoid")
    return sB
end
function fns.fn885(aH, aI)
    return (qI[aH] or 0) < (qI[aI] or 0)
end
function fns.fn887(cF)
    if not cF then
        return nil
    end
    local tt = (cF:GetAttribute("Uid"))
    local ty = if tt then 1 else 0
    local tw = 518 * ty + 2945 * (1 - ty)
    local tx = 1602 * ty + 3608 * (1 - ty)
    if not ((tw * 1914 + tx * 723 + tw * tx) % 16777213 == 2979534) then
        tt = cF:GetAttribute("Uid")
    end
    if not tt then
        tt = cF:GetAttribute("UID")
    end
    local tu = tt
    if tu ~= nil then
        return tu
    end
    for k, v in cF:GetAttributes() do
        if string.lower(k) == "uid" then
            return v
        end
    end
    return nil
end
function fns.onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local xk_1 = pd()
        if xk_1 then
            xk_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn935(da)
    local t1 = da
    if t1 then
        local t2_1 = (da:FindFirstChild("PitRig"))
        local t6 = if t2_1 then 1 else 0
        local t4 = 2936 * t6 + 1444 * (1 - t6)
        local t5 = 2038 * t6 + 2227 * (1 - t6)
        if not ((t4 * 2680 + t5 * 3307 + t4 * t5) % 16777213 == 3814501) then
            t2_1 = da:FindFirstChild("Pit")
        end
        t1 = t2_1
    end
    local t2_2 = t1
    if t1 then
        t1 = t2_2:FindFirstChild("Tank")
    end
    local t2_3 = t1
    if not t2_3 then
        return 0
    end
    local t1_1 = 0
    for i, descendant in t2_3:GetDescendants() do
        local t2_4 = descendant:IsA("TextLabel") or descendant:IsA("TextButton")
        if t2_4 then
            local t2_5 = p8(descendant.Text)
            if t2_5 > t1_1 then
                t1_1 = t2_5
            end
        end
    end
    return t1_1
end
local function onCopyPayPalLink()
    pD(p_, "Copied PayPal link")
end
local function fn971(d2, d3)
    local uM = {}
    for k, v in qA(d2, d3) do
        local attr = v:GetAttribute("Mutation")
        local uO = attr ~= ""
        local uP = type(attr) == "string" and uO
        if uP then
            uM[#uM + 1] = v
        end
    end
    return uM
end
local function fn983()
    local xO = if pa("AutoSell") then 1 else 0
    if xO == 1 then
        pc(qc, p9("AutoSellRarity", "Common"))
    else
        pc(qc, "Off")
    end
end
local function fn984()
    local wM = qr()
    for k, v in qk() do
        if pR(v) > 0 then
            local wO = qI[v] or 0
            local wN_1 = qt("Seeds", v)
            local wP = wN_1 and tonumber(wN_1.price)
            if wP then
                wO = tonumber(wN_1.price)
            end
            if wM >= wO then
                pc(qG, v)
                return true
            end
        end
    end
    return false
end
local function fn997()
    local wm = py("PlantSeeds")
    local wn = {}
    for k, v in qO do
        if wm[v] then
            wn[#wn + 1] = v
        end
    end
    if #wn == 0 then
        wn[1] = "BlueBerry"
    end
    return wn
end
local function worker3()
    while not Library.Unloaded do
        task.wait(2)
        if pa("AntiAfk") then
            local yV = tick() - qa
            local yW = tick() - p3
            if yV >= 300 and yW >= 60 then
                pcall(pE)
            else
                if yV < 300 and yW >= 300 then
                    pcall(pE)
                end
            end
        end
    end
end
local function fn1022(fw, fx)
    for i, descendant in fw:GetDescendants() do
        local vV = (descendant:IsA("ProximityPrompt"))
        if vV then
            vV = descendant.ActionText == "Collect" or descendant.ActionText == "Harvest"
        end
        if vV then
            local Parent = descendant.Parent
            local vW_2 = nil
            if Parent then
                if Parent:IsA("BasePart") then
                    vW_2 = Parent
                else
                    local vX = Parent:FindFirstAncestorWhichIsA("BasePart") or Parent:FindFirstChildWhichIsA("BasePart")
                    vW_2 = vX
                end
            end
            if vW_2 and (vW_2.Position - fx).Magnitude < 4.5 then
                return true
            end
        end
        local vV_3 = descendant:IsA("Model") and descendant.Parent and descendant.Parent.Name == "Planting"
        if vV_3 then
            local BasePart = descendant:FindFirstChildWhichIsA("BasePart", true)
            if BasePart and (BasePart.Position - fx).Magnitude < 4.5 then
                return true
            end
        end
    end
    return false
end
local function worker()
    while Library and not Library.Unloaded do
        ph()
        task.wait(1)
    end
end
local function fn1076()
    connection:Disconnect()
    connection2:Disconnect()
    p2(false)
    pc(qc, "Off")
    local x4 = pd()
    if x4 then
        x4.PlatformStand = false
        x4.WalkSpeed = 16
    end
    pF.__Tempo_BlendFruitAndSellJuice = nil
end
local function fn1116(dT, dU)
    local uB = {}
    local uC = {}
    for i, descendant in dT:GetDescendants() do
        local uD = descendant:IsA("ProximityPrompt") and descendant.ActionText == dU and descendant.Enabled
        if uD then
            local Model = descendant:FindFirstAncestorOfClass("Model")
            if Model and Model ~= dT and not uC[Model] then
                uC[Model] = true
                uB[#uB + 1] = Model
            end
        end
    end
    return uB
end
local function onOnClientEvent(hJ, hK, hL)
    if Library.Unloaded then
        return
    end
    local xa = pa("AutoAcceptOffers") and hL
    if xa then
        pc(qi, hL, true)
    end
end
local function onRenderStepped(hX)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local xp_1 = pd()
        if xp_1 then
            xp_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local xp_3 = qJ()
        local xq = pd()
        if xp_3 and xq then
            xq.PlatformStand = true
            local xq_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                xq_1 += CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                xq_1 -= CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                xq_1 -= CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                xq_1 += CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                xq_1 += Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                xq_1 -= Vector3.new(0, 1, 0)
            end
            xp_3.AssemblyLinearVelocity = Vector3.zero
            if xq_1.Magnitude > 0 then
                xp_3.CFrame = xp_3.CFrame + xq_1.Unit * Options.FlySpeed.Value * hX
            end
        end
    end
end
local function onCopyJoinScript_JobID()
    local gR = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, pX)
    pD(gR, "Copied join script to clipboard")
end
local function fn1150()
    gethui = p4
end
local function fn1177(b0)
    local ShopState = ReplicatedStorage:FindFirstChild("ShopState")
    local s3 = ShopState and ShopState:FindFirstChild("Seeds")
    local s2_1 = s3
    if s3 then
        s3 = s2_1:FindFirstChild(b0)
    end
    local s2_2 = s3
    if s3 then
        s3 = tonumber(s2_2.Value)
    end
    local s2_3 = s3 or 0
    local ShopBought = LocalPlayer:FindFirstChild("ShopBought")
    local s4 = ShopBought and ShopBought:FindFirstChild("Seeds:" .. b0)
    local max = math.max
    local s5 = s4 and tonumber(s4.Value)
    local s2_6 = s5 or 0
    return max(0, s2_3 - s2_6)
end
local function fn1186(ea)
    if not ea or not ea.Enabled then
        return false
    end
    local Parent = ea.Parent
    local uY
    if Parent then
        if Parent:IsA("BasePart") then
            uY = Parent
        else
            local uZ = (Parent:FindFirstAncestorWhichIsA("BasePart"))
            local u2 = if uZ then 1 else 0
            local u0 = 2494 * u2 + 1358 * (1 - u2)
            local u1 = 2126 * u2 + 1094 * (1 - u2)
            if not ((u0 * 2710 + u1 * 329 + u0 * u1) % 16777213 == 12760438) then
                uZ = Parent:FindFirstChildWhichIsA("BasePart", true)
            end
            uY = uZ
        end
    end
    if uY then
        o6(uY.Position)
    end
    if fireproximityprompt then
        pcall(fireproximityprompt, ea)
        return true
    end
    return false
end
local function fn1192(a_)
    local sg = Toggles[a_]
    return sg ~= nil and sg.Value == true
end
o6 = nil
o7 = nil
connection2 = nil
o9 = nil
pa = nil
pb = nil
pc = nil
pd = nil
pe = nil
ShopConfig = nil
pg = nil
ph = nil
pi = nil
pj = nil
pk = nil
connection = nil
pm = nil
Library = nil
po = nil
pp = nil
pq = nil
pr = nil
ps = nil
pt = nil
pu = nil
pv = nil
pw = nil
px = nil
py = nil
pz = nil
pA = nil
pB = nil
pC = nil
pD = nil
pE = nil
pF = nil
pG = nil
Options = nil
pI = nil
CurrentCamera = nil
pK = nil
Toggles = nil
pM = nil
pN = nil
pO = nil
SaveManager = nil
pQ = nil
pR = nil
pS = nil
pT = nil
pU = nil
pV = nil
pW = nil
pX = nil
pZ = nil
p_ = nil
p0 = nil
p2 = nil
p3 = nil
p4 = nil
Label = nil
p6 = nil
p7 = nil
p8 = nil
p9 = nil
qa = nil
PlayerGui = nil
qc = nil
qd = nil
LocalPlayer = nil
qf = nil
qg = nil
CoreGui = nil
qi = nil
qj = nil
qk = nil
qm = nil
qn = nil
qo = nil
qp = nil
qq = nil
qr = nil
VirtualUser = nil
qt = nil
qu = nil
UserInputService = nil
qw = nil
qx = nil
qy = nil
qz = nil
qA = nil
HttpService = nil
qC = nil
qD = nil
qE = nil
qF = nil
qG = nil
local pY, p1, GuiService
qH = nil
qI = nil
qJ = nil
qK = nil
ReplicatedStorage = nil
qM = nil
qN = nil
qO = nil
qP = nil
ReplicatedStorage, HttpService, UserInputService, VirtualUser, GuiService, CoreGui, LocalPlayer, PlayerGui, p4 = nil, nil, nil, nil, nil, nil, nil, nil, nil
local zP_26 = game:GetService("Players")
ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
HttpService = game:GetService("HttpService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
LocalPlayer = zP_26.LocalPlayer
PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
p4 = fns.fn700
if getgenv then
    getgenv().gethui = p4
end
local zP_8
zP_26 = 0
repeat
    zP_28 = { "gounln", "mkim", "ldzdjwsbejf", "zgp", "dbapx", "qwbbjl", "mqo", "vhnputxa" }
    if zP_28[(zP_26 * 45 + 89) % 8 + 1] < zP_28[(zP_26 * 45 + 89) % 8 + 1] then
        pcall(fn1150)
        zP_8 = getgenv
    else
        pcall(fn1150)
        zP_8 = getgenv
    end
    zP_26 = (zP_26 + 1) % 4
until (zP_26 * 3 + 2) % 4 == 1
if zP_8 then
    zP_8 = getgenv()
end
zP_26 = zP_8
local rA = if zP_26 then 1 else 0
local zP_10 = 1163 * rA + 917 * (1 - rA)
local rz = 2536 * rA + 1064 * (1 - rA)
if not ((zP_10 * 1494 + rz * 3636 + zP_10 * rz) % 16777213 == 13907786) then
    zP_26 = _G
end
pF = zP_26
if pF.__Tempo_BlendFruitAndSellJuice then
    return
end
pr, pm, ShopConfig, o7, qN, qG, qE, qw, qu, qn, qi, qc, p6, pZ, pT, pO, pK, pG, pC, pw, pt, Library, SaveManager, Toggles, Options, qO, qI, ph, pD, po, pc = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pF.__Tempo_BlendFruitAndSellJuice = true
local zP_11 = fns.fn643
local zP_13 = "Blend Fruit and Sell Juice"
pr = "https://discord.gg/K7Qxnxkk46"
pm = "https://discord.gg/K7Qxnxkk46"
local zP_46 = require(ReplicatedStorage:WaitForChild("SeedConfig"))
ShopConfig = require(ReplicatedStorage:WaitForChild("ShopConfig"))
local zP_30 = require(ReplicatedStorage:WaitForChild("JuiceConfig"))
zP_26 = ReplicatedStorage:WaitForChild("Remotes")
o7 = zP_11(zP_26:WaitForChild("CollectBerry"))
qN = zP_11(zP_26:WaitForChild("PlantSeed"))
qG = zP_11(zP_26:WaitForChild("BuySeed"))
qE = zP_11(zP_26:WaitForChild("PitAddAll"))
qw = zP_11(zP_26:WaitForChild("BlenderInsert"))
qu = zP_11(zP_26:WaitForChild("BlenderFill"))
qn = zP_11(zP_26:WaitForChild("StandPlaceCup"))
qi = zP_11(zP_26:WaitForChild("OfferRespond"))
local zP_32 = zP_11(zP_26:WaitForChild("CustomerOffer"))
qc = zP_11(zP_26:WaitForChild("SetAutoSell"))
p6 = zP_11(zP_26:WaitForChild("UpgradeBlade"))
pZ = zP_11(zP_26:WaitForChild("DailyClaim"))
pT = zP_11(zP_26:WaitForChild("GroupReward"))
pO = zP_11(zP_26:WaitForChild("ManagerClaimOffline"))
pK = zP_11(zP_26:WaitForChild("BuyEgg"))
pG = zP_11(zP_26:WaitForChild("BuyGear"))
if (pO and pr and (not qE and false) and (not ph and not pO and (false and not ph)) or (pO and not ph and (qu or not qu) or (not pO or false or (pc or not qu)))) and not (pO and pr and (not qE and false) and (not ph and not pO and (false and not ph)) or (pO and not ph and (qu or not qu) or (not pO or false or (pc or not qu)))) then
    pw = pt(pC:WaitForChild("BuyCup"))
    pt(pC:WaitForChild("UpgradeLuck"))
    pt(pC:WaitForChild("UpgradeGarden"))
else
    pC = zP_11(zP_26:WaitForChild("BuyCup"))
    pw = zP_11(zP_26:WaitForChild("UpgradeLuck"))
    pt = zP_11(zP_26:WaitForChild("UpgradeGarden"))
end
Library = getgenv().Library
ph = fns.fn267
ph()
task.spawn(worker)
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
pD = fns.fn262
po = fns.fn677
pc = function(aA, ...)
    if aA then
        pcall(function(...)
            aA:FireServer(...)
        end, ...)
    end
end
qO = {}
qI = {}
for k, v in zP_46.Seeds do
    zP_26 = type(k) == "string" and type(v) == "table"
    if zP_26 then
        zP_26 = tonumber(v.price) or 0
        qI[k] = zP_26
        qO[#qO + 1] = k
    end
end
zP_46, zP_11, zP_28, zP_8 = nil, nil, nil, nil
zP_26 = 1
repeat
    zP_16 = (zP_26 * 2 + 1) % 3 + 1
    if zP_16 <= 2 then
        if zP_16 <= 1 then
            zP_16 = {
                "hvnxiutga",
                "fzeujxdsij",
                "ufyqadab",
                "tjvfth",
                "xxrhajiwulhx",
                "twyhxfjiamqy",
                "lrblrsqxmrst",
                "sixmqtjwosg",
                "fdb"
            }
            if zP_16[(zP_26 * 12 + 36) % 9 + 1] <= zP_16[(zP_26 * 12 + 36) % 9 + 1] then
                table.sort(qO, fns.fn885)
                zP_46 = { "Common", "Spotted", "Sunburst", "Onyx" }
                zP_11 = {
                    "Trowel",
                    "SprinklerCommon",
                    "SprinklerUncommon",
                    "SprinklerRare",
                    "SprinklerLegendary",
                    "SprinklerExotic"
                }
            else
                table.sort(zP_46, fns.fn885)
                zP_11 = { "Sunburst", "Onyx", "Common", "Spotted" }
                qO = {
                    "SprinklerExotic",
                    "SprinklerLegendary",
                    "SprinklerCommon",
                    "SprinklerUncommon",
                    "SprinklerRare",
                    "Trowel"
                }
            end
            zP_26 = (zP_26 + 14) % 24
        else
            zP_16 = (vector.create((zP_26 * 1 + 6) % 11 + 1, (zP_26 * 5 + 2) % 13 + 1, (zP_26 * 7 + 3) % 17 + 1))
            zP_50 = (vector.create((zP_26 * 2 + 4) % 11 + 1, (zP_26 * 3 + 10) % 13 + 1, (zP_26 * 2 + 1) % 17 + 1))
            zP_35 = (vector.create((zP_26 * 7 + 9) % 11 + 1, (zP_26 * 2 + 11) % 13 + 1, (zP_26 * 2 + 15) % 17 + 1))
            if vector.dot(vector.cross(zP_16, zP_50), zP_35) == vector.dot(vector.cross(zP_50, zP_35), zP_16) + 4 then
                zP_8 = { "Off" }
            else
                zP_28 = { "Off" }
            end
            zP_26 = (zP_26 + 20) % 24
        end
    else
        local Bh = bit32.rrotate(bit32.bxor(bit32.lrotate(zP_26, 20), string.byte(tostring(zP_28))), 20)
        if bit32.bxor(bit32.lrotate(bit32.bxor(Bh, 2318217995), 30), 3800779970) == bit32.lrotate(Bh, 30) then
            zP_8 = zP_30.Customers
        else
            zP_30 = zP_8.Customers
        end
        zP_26 = (zP_26 + 2) % 24
    end
until (zP_26 * 13 + 5) % 24 == 6
if zP_8 then
    zP_26 = 2
    repeat
        local Bk = bit32.rrotate(bit32.bxor(bit32.lrotate(zP_26, 7), string.byte(tostring(zP_26))), 11)
        if bit32.bxor(bit32.lrotate(bit32.bxor(Bk, 4292148676), 20), 3696229711) ~= bit32.lrotate(Bk, 20) then
            zP_30 = type(zP_8.Customers.rarities) == "table"
        else
            zP_8 = type(zP_30.Customers.rarities) == "table"
        end
        zP_26 = (zP_26 + 1) % 8
    until (zP_26 * 5 + 4) % 8 == 3
end
if zP_8 then
    for i, v in ipairs(zP_30.Customers.rarities) do
        zP_26 = type(v) == "table" and type(v.name) == "string"
        if zP_26 then
            zP_28[#zP_28 + 1] = v.name
        end
    end
end
if #zP_28 == 1 then
    zP_26 = 1
    repeat
        zP_8 = (vector.create((zP_26 * 4 + 6) % 11 + 1, (zP_26 * 6 + 13) % 13 + 1, (zP_26 * 7 + 10) % 17 + 1))
        zP_30 = (vector.create((zP_26 * 1 + 5) % 11 + 1, (zP_26 * 5 + 9) % 13 + 1, (zP_26 * 12 + 10) % 17 + 1))
        zP_16 = (vector.create((zP_26 * 5 + 8) % 11 + 1, (zP_26 * 3 + 8) % 13 + 1, (zP_26 * 10 + 17) % 17 + 1))
        zP_50 = (vector.create((zP_26 * 6 + 9) % 11 + 1, (zP_26 * 5 + 2) % 13 + 1, (zP_26 * 8 + 1) % 17 + 1))
        if vector.dot(vector.cross(zP_8, zP_30), (vector.cross(zP_16, zP_50))) == vector.dot(zP_8, zP_16) * vector.dot(zP_30, zP_50) - vector.dot(zP_8, zP_50) * vector.dot(zP_30, zP_16) + 3 then
            zP_28 = { "Epic", "Rare", "Common", "Uncommon", "Mythical", "Secret", "Legendary", "Off" }
        else
            zP_28 = { "Off", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret" }
        end
        zP_26 = (zP_26 + 0) % 4
    until (zP_26 * 3 + 2) % 4 == 1
end
zP_8 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = pr, Copyable = true }, "|", zP_13 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
zP_50 = {
    Info = zP_8:AddTab("Info", "info"),
    Main = zP_8:AddTab("Main", "gamepad-2"),
    Rolls = zP_8:AddTab("Rolls", "dices"),
    Shop = zP_8:AddTab("Shop", "shopping-bag"),
    Player = zP_8:AddTab("Player", "person-standing"),
    Settings = zP_8:AddTab("Settings", "settings")
}
zP_16 = fns.fn370
for k, v in zP_50 do
    zP_16(v)
end
qM, qC, Label, pX, pa, qz, p9, py, pd, qJ, qr, pW, pp, o6, qt, pR, qH, pu, qx, p8, pI, pi, qP, qp, p0, o9, qg, p1, pQ, pz, pe, qA, pN, pg, qD, qm, pS, pB, px, qy, pj, qq, pk, qk, pM, qF, pA, pq = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pa = fn1192
qz = fns.fn309
p9 = fns.fn470
py = fns.fn102
pd = fns.fn884
qJ = fns.fn155
qr = fns.fn150
pW = fns.fn695
pp = fns.fn604
o6 = fns.fn377
qt = fns.fn546
pR = fn1177
qH = fns.fn440
pu = function(cv)
    local cw
    cw = nil
    local function cx(cy)
        if not cy then
            return
        end
        for i, child in cy:GetChildren() do
            local tl = not cw and child:IsA("Tool") and cv(child)
            if tl then
                cw = child
            end
        end
    end
    cx(LocalPlayer:FindFirstChild("Backpack"))
    cx(LocalPlayer.Character)
    return cw
end
qx = fns.fn887
p8 = fns.fn305
pI = fns.fn453
pi = fns.fn824
qP = fns.fn76
qp = fns.fn252
p0 = fn935
o9 = fns.fn124
qg = fns.fn613
p1 = fns.fn359
pQ = fns.fn640
pz = function(dH)
    local uq = pd()
    if uq and dH then
        pcall(function()
            uq:EquipTool(dH)
        end)
    end
end
pe = fns.fn737
qA = fn1116
pN = fn971
pg = fn1186
qD = fns.fn255
qm = fns.fn403
pS = fns.fn563
pB = fns.fn106
px = function(eU, eV)
    local vF
    vF = nil
    vF = p9("RollBuyMode", "Higher")
    local vG = qz("RollGoldMult", 2)
    local vH = qz("RollJuiceMult", 2)
    local function vI(e1, e2)
        if vF == "Lower" then
            return e1 <= e2
        end
        return e1 >= e2
    end
    if not vI(eU, vG) then
        return false
    elseif eV == nil then
        return true
    else
        return vI(eV, vH)
    end
end
if (not o6 or not p0 or not p0 and p0) and ((p0 or not p0) and (not o6 or not o6)) or not ((not o6 or not p0 or not p0 and p0) and ((p0 or not p0) and (not o6 or not o6))) then
    qy = fns.fn791
else
    qC = fns.fn791
end
pj = fns.fn38
qq = fn1022
pk = fns.fn321
qk = fn997
pM = function()
    local wE
    wE = {}
    for k, v in qk() do
        wE[v] = true
    end
    return pu(function(f7)
        local wD = if not p1(f7) then 1 else 0
        if wD == 1 then
            return false
        end
        local wy = pQ(f7)
        return wy == nil or wE[wy] == true
    end)
end
qF = fn984
pA = fns.fn670
pq = fns.fn676
local zP_18 = "#7fd47f"
zP_35 = "#6ec1ff"
qM = "#e8a34d"
local zP_37 = "#8b93a3"
qC = "Unknown"
pcall(fns.fn324)
zP_26 = zP_50.Info:AddLeftGroupbox("Account", "circle-user")
zP_26:AddLabel(pq("User", LocalPlayer.Name, zP_18), true)
zP_26:AddLabel(pq("Status", "Keyless", zP_18), true)
zP_26:AddLabel(pq("Executor", qC, zP_18), true)
local GameInfoGroup = zP_50.Info:AddLeftGroupbox("Game Info", "gamepad-2")
GameInfoGroup:AddLabel(pA(zP_13 .. " [" .. tostring(game.PlaceId) .. "]", zP_35), true)
GameInfoGroup:AddLabel(pq("Place ID", tostring(game.PlaceId), zP_35), true)
Label = GameInfoGroup:AddLabel(pq("Session time", "0s", qM), true)
if not qH and not qH or not p9 and o9 or (not o9 or not p9) and (not o9 and p9) or p9 and not qH and (p9 and o9) and (not qH or not qH or o9 and not o9) or (not qH or not qH or not o9 and not o9) and (qH and qH and (o9 or not qH)) and (qH and qH or (not qH or not qH) or (not o9 and not qH or (not p9 or p9))) or not (not qH and not qH or not p9 and o9 or (not o9 or not p9) and (not o9 and p9) or p9 and not qH and (p9 and o9) and (not qH or not qH or o9 and not o9) or (not qH or not qH or not o9 and not o9) and (qH and qH and (o9 or not qH)) and (qH and qH or (not qH or not qH) or (not o9 and not qH or (not p9 or p9)))) then
    pX = tostring(game.JobId)
else
    p0 = tostring(game.JobId)
end
zP_30 = #pX > 18
if zP_30 then
    zP_26 = 0
    repeat
        local AS = bit32.rrotate(bit32.bxor(bit32.lrotate(zP_26, 15), string.byte(tostring(zP_26))), 7)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(AS, 3687354545), 1540468418), (bit32.bxor(bit32.band(AS, 607612750), 2465945876))), 1540468418), 2465945876) ~= AS then
            pX = string.sub(zP_30, 1, 18) .. "..."
        else
            zP_30 = string.sub(pX, 1, 18) .. "..."
        end
        zP_26 = (zP_26 + 1) % 4
    until (zP_26 * 3 + 3) % 4 == 2
end
zP_26 = zP_30 or pX
pv, qo, qj, qf, qd, p7, p_, pU, FarmGroup, JuiceGroup, MovementGroup, CurrentCamera, qa, p3, connection, connection2, zP_36, p2, qK, pE, pY, ps, pb, pV = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local zP_31 = zP_26
GameInfoGroup:AddLabel(pq("Server", zP_31, zP_37), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
pv = os.clock()
task.spawn(fns.worker2)
zP_8 = zP_50.Info:AddRightGroupbox("Scripts", "package")
zP_8:AddLabel(pA("Included in this hub", zP_37), true)
zP_8:AddLabel(pA(zP_13, zP_35), true)
local FeaturesGroup = zP_50.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(pA("Auto Farm", zP_35), true)
FeaturesGroup:AddLabel(pA("Auto Juice", qM), true)
FeaturesGroup:AddLabel(pA("Auto Rolls", zP_18), true)
FeaturesGroup:AddLabel(pA("Auto Shop", zP_37), true)
local SocialsGroup = zP_50.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = po })
SocialsGroup:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
local TempoHubGroup = zP_50.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = po })
qo = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
qj = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
qf = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
if (not zP_36 and not CurrentCamera and (not zP_36 and false) or (not zP_36 or not JuiceGroup)) and (not JuiceGroup and zP_36 or (connection2 or (not JuiceGroup or 67))) or JuiceGroup and not CurrentCamera and (JuiceGroup or JuiceGroup) and (connection2 and 67 and (not zP_36)) and ((not CurrentCamera and not CurrentCamera or (connection2 or false)) and (not JuiceGroup and not CurrentCamera and false)) or not ((not zP_36 and not CurrentCamera and (not zP_36 and false) or (not zP_36 or not JuiceGroup)) and (not JuiceGroup and zP_36 or (connection2 or (not JuiceGroup or 67))) or JuiceGroup and not CurrentCamera and (JuiceGroup or JuiceGroup) and (connection2 and 67 and (not zP_36)) and ((not CurrentCamera and not CurrentCamera or (connection2 or false)) and (not JuiceGroup and not CurrentCamera and false))) then
    qd = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
    p7 = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
else
    p7 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
    qd = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
end
p_ = ""
pU = ""
zP_15, zP_12, zP_45, zP_27, zP_6, zP_40, zP_20 = "#345d9d", "#f7931a", "#627eea", "#26a17b", "#14f195", "#0070ba", "#008cff"
zP_30 = zP_50.Info:AddRightGroupbox("Donations", "heart")
zP_30:AddLabel(pA("All donations are optional but appreciated.", qM), true)
zP_30:AddLabel(pA("If you donate you get a special role, just PING after you donate.", zP_18), true)
zP_30:AddDivider()
zP_30:AddLabel(pA("LTC / Litecoin", zP_15), true)
zP_30:AddButton({ Text = "Copy Litecoin Address", Func = fns.onCopyLitecoinAddress })
zP_30:AddLabel(pA("BTC / Bitcoin", zP_12), true)
zP_30:AddButton({ Text = "Copy Bitcoin Address", Func = fns.onCopyBitcoinAddress })
zP_30:AddLabel(pA("ETH / Ethereum", zP_45), true)
zP_30:AddButton({ Text = "Copy Ethereum Address", Func = fns.onCopyEthereumAddress })
zP_30:AddLabel(pA("USDT", zP_27), true)
zP_30:AddButton({ Text = "Copy USDT Address", Func = fns.onCopyUSDTAddress })
zP_30:AddLabel(pA("Solana", zP_6), true)
zP_30:AddButton({ Text = "Copy Solana Address", Func = fns.onCopySolanaAddress })
zP_30:AddLabel(pA("PayPal", zP_40), true)
zP_30:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
zP_30:AddLabel(pA("Venmo", zP_20), true)
zP_30:AddButton({ Text = "Copy Venmo Link", Func = fns.onCopyVenmoLink })
zP_30:AddDivider()
zP_30:AddLabel(pA("Don't have any of the listed currencies but still wanna donate?", zP_37), true)
zP_30:AddLabel(pA("DM me and we'll work something out.", zP_35), true)
local FaqGroup = zP_50.Info:AddRightGroupbox("FAQ", "circle-help")
if (not MovementGroup and not MovementGroup and (MovementGroup and p3) or MovementGroup and not p3 and (MovementGroup or p3) or (not MovementGroup and not p3 or p3 and not MovementGroup) and (not MovementGroup or not MovementGroup or (not MovementGroup or not p3))) and ((not MovementGroup or not p3 or p3 and p3) and (p3 or MovementGroup or (not p3 or not p3)) or (not p3 and MovementGroup and (not MovementGroup and MovementGroup) or (MovementGroup or p3 or MovementGroup and MovementGroup))) or not ((not MovementGroup and not MovementGroup and (MovementGroup and p3) or MovementGroup and not p3 and (MovementGroup or p3) or (not MovementGroup and not p3 or p3 and not MovementGroup) and (not MovementGroup or not MovementGroup or (not MovementGroup or not p3))) and ((not MovementGroup or not p3 or p3 and p3) and (p3 or MovementGroup or (not p3 or not p3)) or (not p3 and MovementGroup and (not MovementGroup and MovementGroup) or (MovementGroup or p3 or MovementGroup and MovementGroup)))) then
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
    FarmGroup = zP_50.Main:AddLeftGroupbox("Farm", "leaf")
else
    FarmGroup:AddLabel("Where do I get a good config?", true)
    FarmGroup:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
    FarmGroup:AddLabel("How do I import / export configs?", true)
    FarmGroup:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
    FarmGroup:AddLabel("How do I report bugs?", true)
    FarmGroup:AddLabel("Join the Discord and post it in the bugs channel.", true)
    FarmGroup:AddLabel("How do I make suggestions?", true)
    FarmGroup:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
    FarmGroup:AddLabel("How do I get help or updates?", true)
    FarmGroup:AddLabel("Join the Discord, updates and support are posted there first.", true)
    zP_50 = FaqGroup.Main:AddLeftGroupbox("Farm", "leaf")
end
FarmGroup:AddToggle("AutoCollect", { Text = "Auto Collect", Default = false })
FarmGroup:AddToggle("AutoHarvest", { Text = "Auto Harvest", Default = false })
FarmGroup:AddToggle("AutoHarvestMutation", { Text = "Auto Harvest Mutation", Default = false })
FarmGroup:AddToggle("AutoPlant", { Text = "Auto Plant", Default = false })
FarmGroup:AddToggle("AutoBuySeeds", { Text = "Auto Buy Seeds", Default = false })
FarmGroup:AddDropdown("PlantSeeds", { Values = qO, Default = { BlueBerry = true }, Multi = true, Text = "Seeds" })
FarmGroup:AddSlider("FarmDelay", { Text = "Farm Delay", Default = 0.35, Min = 0.1, Max = 2, Rounding = 2 })
JuiceGroup = zP_50.Main:AddRightGroupbox("Juice", "cup-soda")
JuiceGroup:AddToggle("AutoBlend", { Text = "Auto Blend Juice", Default = false })
JuiceGroup:AddToggle("AutoFillCup", { Text = "Auto Fill Up Cup", Default = false })
JuiceGroup:AddToggle("AutoPlaceCup", { Text = "Auto Place Cup", Default = false })
JuiceGroup:AddToggle("AutoBuyCup", { Text = "Auto Buy Cup", Default = false })
JuiceGroup:AddToggle("AutoBuyJuice", { Text = "Auto Buy Juice", Default = false })
JuiceGroup:AddToggle("AutoAcceptOffers", { Text = "Auto Accept Offers", Default = false })
JuiceGroup:AddToggle("AutoSell", { Text = "Auto Sell Juice", Default = false })
JuiceGroup:AddDropdown("AutoSellRarity", { Values = zP_28, Default = "Common", Text = "Auto Sell Cup Rarity" })
local ClaimsGroup = zP_50.Main:AddLeftGroupbox("Claims", "gift")
ClaimsGroup:AddToggle("AutoDaily", { Text = "Auto Daily Claim", Default = false })
ClaimsGroup:AddToggle("AutoGroup", { Text = "Auto Group Reward", Default = false })
ClaimsGroup:AddToggle("AutoOffline", { Text = "Auto Offline Claim", Default = false })
ClaimsGroup:AddToggle("AutoBlade", { Text = "Auto Upgrade Blade", Default = false })
zP_16(zP_50.Rolls)
local RollsGroup = zP_50.Rolls:AddLeftGroupbox("Rolls", "dices")
RollsGroup:AddToggle("AutoRollCup", { Text = "Auto Roll Cup", Default = false })
RollsGroup:AddToggle("AutoRollCart", { Text = "Auto Roll Cart", Default = false })
RollsGroup:AddToggle("AutoBuyRolledCup", { Text = "Auto Buy Cup", Default = false })
RollsGroup:AddToggle("AutoBuyRolledCart", { Text = "Auto Buy Cart", Default = false })
RollsGroup:AddDropdown("RollBuyMode", { Values = { "Higher", "Lower" }, Default = "Higher", Text = "Buy If" })
RollsGroup:AddSlider("RollGoldMult", { Text = "Gold Mult", Default = 2, Min = 1, Max = 10, Rounding = 2 })
RollsGroup:AddSlider("RollJuiceMult", { Text = "Juice Mult", Default = 2, Min = 1, Max = 10, Rounding = 2 })
RollsGroup:AddSlider("RollDelay", { Text = "Roll Delay", Default = 0.5, Min = 0.2, Max = 3, Rounding = 2 })
local EggsGroup = zP_50.Shop:AddLeftGroupbox("Eggs", "egg")
EggsGroup:AddToggle("AutoBuyEgg", { Text = "Auto Buy Egg", Default = false })
EggsGroup:AddDropdown("EggId", { Values = zP_46, Default = "Common", Text = "Egg" })
local GearGroup = zP_50.Shop:AddRightGroupbox("Gear", "wrench")
GearGroup:AddToggle("AutoBuyGear", { Text = "Auto Buy Gear", Default = false })
GearGroup:AddDropdown("GearId", { Values = zP_11, Default = "SprinklerCommon", Text = "Gear" })
local UpgradesGroup = zP_50.Shop:AddLeftGroupbox("Upgrades", "arrow-up")
UpgradesGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
MovementGroup = zP_50.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = zP_50.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
zP_32.OnClientEvent:Connect(onOnClientEvent)
RunService.Stepped:Connect(fns.onStepped)
UserInputService.JumpRequest:Connect(fns.onJumpRequest)
CurrentCamera = workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fns.fn269)
Toggles.WalkSpeedEnabled:OnChanged(fns.fn825)
p2 = function(ij)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not ij)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not ij
        end
    end)
    if not ij then
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
Toggles.AntiGameplayPause:OnChanged(fns.fn142)
task.spawn(fns.antiGameplayPauseLoop)
qK = fn983
Toggles.AutoSell:OnChanged(qK)
Options.AutoSellRarity:OnChanged(fns.fn624)
local MenuGroup = zP_50.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
qa = tick()
p3 = tick()
pcall(function()
    for k, v in getconnections(LocalPlayer.Idled) do
        local xZ = v
        pcall(function()
            xZ:Disable()
        end)
    end
end)
pE = fns.fn558
connection = UserInputService.InputBegan:Connect(fns.onInputBegan)
connection2 = UserInputService.InputChanged:Connect(fns.onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", fns.onUnload)
Library.ToggleKeybind = Options.MenuKeybind
Library:OnUnload(fn1076)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/BlendFruitAndSellJuice")
zP_36 = SaveManager:BuildConfigSection(zP_50.Settings)
ThemeManager:ApplyToTab(zP_50.Settings)
ThemeManager:LoadDefault()
pY = fns.fn77
ps = fns.fn532
pb = fns.fn19
pV = function(jx)
    local yE
    yE = nil
    local yF = type(jx) ~= "table" or type(jx.idx) ~= "string" or type(jx.type) ~= "string" or SaveManager.Ignore[jx.idx]
    if yF then
        return false
    end
    yE = pY(jx.type, jx.idx)
    if not yE then
        return false
    end
    local yF_1 = pcall(function()
        if jx.type == "Input" then
            if type(jx.text) ~= "string" then
                return
            end
            yE:SetValue(jx.text)
        elseif jx.type == "ColorPicker" then
            yE:SetValueRGB(Color3.fromHex(jx.value), jx.transparency)
        elseif jx.type == "KeyPicker" then
            yE:SetValue({ jx.key, jx.mode, jx.modifiers })
            if jx.mode == "Toggle" and jx.toggled ~= nil then
                yE.Toggled = jx.toggled
                yE:Update()
            end
        else
            yE:SetValue(jx.value)
        end
    end)
    return yF_1
end
zP_36:AddDivider()
zP_36:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
zP_36:AddButton("Export Config to Clipboard", fns.onExportConfigToClipboard)
zP_36:AddButton("Import Config from Clipboard Text", fns.onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
task.spawn(worker3)
task.spawn(fns.worker4)
task.spawn(fns.worker5)
task.spawn(fns.worker6)
task.spawn(fns.worker7)
end)(...)

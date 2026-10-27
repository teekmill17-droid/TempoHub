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
getgenv().TempoHoodSubtitle = "REELED SHOOT FISH!"
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
local vA_1, vA_2, vA_4, vA_5, vA_7, vA_8, vA_10, vA_13, vA_14, vA_15, vA_17, vA_19, vA_20, vA_21, vA_22, vA_23
local ns
local m9
local nR
local mR
local Label
local nf
local UserInputService
local mX
local nE
local nl
local n2
local m2
local DataMgr
local nQ
local mQ
local nx
local ne
local nW
local nD
local nk
local n1
local m1
local nJ
local nq
local Toggles
local mP
local nw
local nd
local mV
local nC
local n0
local m0
local nI
local np
local connection2
local nO
local mO
local nc
local nU
local mU
local nB
local ni
local m_
local nN
local CurrentCamera
local nb
local nT
local connection3
local nA
local nh
local nZ
local mZ
local nG
local n4
local m4
local nM
local nt
local na
local nS
local mS
local LocalPlayer
local ng
local nY
local mY
local Lighting
local nm
local connection
local m3
local nL
function fns.fn65(ef)
    if nI(ef) then
        ef.Visible = false
    end
end
function fns.fn71()
    return DataMgr:GetClientPlayer()
end
function fns.fn88()
    local pz = DataMgr:GetConfig("PoolData", 101)
    return pz and pz.pool or nil
end
function fns.fn97(b1, b2)
    local qm = m1()
    local qn = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("FishArea")
    if not qm or not qn then
        return {}
    end
    local qn_2 = b2
    local qt = if qn_2 then 1 else 0
    local qr = 3581 * qt + 2080 * (1 - qt)
    local qs = 1966 * qt + 501 * (1 - qt)
    if not ((qr * 76 + qs * 2019 + qr * qs) % 16777213 == 11281756) then
        qn_2 = 160
    end
    b2 = qn_2
    local qn_3 = {}
    for i, child in ipairs(qn:GetChildren()) do
        if b1 then
            local attr = child:GetAttribute("Owner")
            if not (attr ~= LocalPlayer.Name) then
                for i, child in ipairs(child:GetChildren()) do
                    if child:IsA("Model") then
                        if not nA(child) then
                            local qo_2 = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                            local qp_1 = qo_2
                            if qo_2 then
                                qo_2 = (qp_1.Position - qm.Position).Magnitude <= b2
                            end
                            if qo_2 then
                                qn_3[#qn_3 + 1] = qp_1
                            end
                        end
                    end
                end
            end
        else
            for i, child in ipairs(child:GetChildren()) do
                if child:IsA("Model") then
                    if not nA(child) then
                        local qo_3 = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                        local qp_2 = qo_3
                        if qo_3 then
                            qo_3 = (qp_2.Position - qm.Position).Magnitude <= b2
                        end
                        if qo_3 then
                            qn_3[#qn_3 + 1] = qp_2
                        end
                    end
                end
            end
        end
    end
    return qn_3
end
function fns.fn108()
    local pr = tonumber(DataMgr:GetPlayerBaseData("coin")) or 0
    return pr
end
function fns.fn112(d9)
    local ry = not d9 or not d9:IsA("GuiObject")
    local rD = if ry then 1 else 0
    local rB = 804 * rD + 104 * (1 - rD)
    local rC = 438 * rD + 2432 * (1 - rD)
    if not ((rB * 1793 + rC * 3042 + rB * rC) % 16777213 == 3126120) then
        ry = d9.Name ~= "Tip"
    end
    if ry then
        return false
    end
    local Content = d9:FindFirstChild("Content")
    local rz = Content and Content:IsA("TextLabel") and Content.Text == nL
    return rz
end
function fns.worker4()
    while not nh.Unloaded do
        task.wait(1.2)
        if nO("AutoUpgradeGear") then
            pcall(n4)
        end
    end
end
function fns.onCopyVenmoLink()
    mY(nS, "Copied Venmo link")
end
function fns.fn174()
    local Character = LocalPlayer.Character
    local px = Character and Character:FindFirstChildOfClass("Humanoid")
    return px
end
function fns.onCopyEthereumAddress()
    mY(mR, "Copied Ethereum address")
end
local function fn187(iw)
    m_()
    if not iw then
        return
    end
    local Rendering = settings().Rendering
    nW(Rendering, "QualityLevel", Enum.QualityLevel.Level01)
    nW(Lighting, "GlobalShadows", false)
    nW(Lighting, "EnvironmentDiffuseScale", 0)
    nW(Lighting, "EnvironmentSpecularScale", 0)
    local Terrain = workspace.Terrain
    nW(Terrain, "Decoration", false)
    nW(Terrain, "WaterWaveSize", 0)
    nW(Terrain, "WaterWaveSpeed", 0)
    nW(Terrain, "WaterReflectance", 0)
    for i, descendant in workspace:GetDescendants() do
        ng(descendant)
    end
    for i, descendant in Lighting:GetDescendants() do
        ng(descendant)
    end
    connection = game.DescendantAdded:Connect(ng)
end
local function fn224()
    local uR = {}
    for i, v in ipairs({ Toggles, m3 }) do
        for k, v in pairs(v) do
            local uS = type(v) == "table" and type(v.Type) == "string" and not na.Ignore[k]
            if uS then
                local uS_1 = m4(k, v)
                if uS_1 then
                    uR[#uR + 1] = uS_1
                end
            end
        end
    end
    table.sort(uR, function(jl, jm)
        if jl.type ~= jm.type then
            return jl.type < jm.type
        end
        return jl.idx < jm.idx
    end)
    return { objects = uR }
end
local function onRefreshNPCList()
    nT()
    if m3.TeleportNpc then
        local TeleportNpc = m3.TeleportNpc
        local rm = #n1 > 0 and n1 or { "None" }
        TeleportNpc:SetValues(rm)
        if n1[1] then
            m3.TeleportNpc:SetValue(n1[1])
        end
    end
    nh:Notify("NPC list refreshed")
end
local function fn248()
    nJ(Toggles.FpsBoost.Value)
end
local function onInputChanged(hT)
    local UserInputType = hT.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        nE = tick()
    end
end
local function onTeleportToNPC()
    local q8 = m3.TeleportNpc and m3.TeleportNpc.Value
    if not q8 or q8 == "None" then
        nh:Notify("No NPC selected")
        return
    end
    nT()
    local q8_2 = nZ[q8]
    local q9_1 = not q8_2
    local ri = if q9_1 then 1 else 0
    local rg = 1590 * ri + 2098 * (1 - ri)
    local rh = 803 * ri + 1482 * (1 - ri)
    if not ((rg * 2202 + rh * 578 + rg * rh) % 16777213 == 5242084) then
        q9_1 = not q8_2.Parent
    end
    if q9_1 then
        nh:Notify("NPC not found")
        return
    end
    local q9_2 = q8_2:FindFirstChild("HumanoidRootPart") or q8_2.PrimaryPart or q8_2:FindFirstChildWhichIsA("BasePart", true)
    local q9_3 = m1()
    if not q9_2 or not q9_3 then
        nh:Notify("Could not teleport to NPC")
        return
    end
    local LookVector = q9_2.CFrame.LookVector
    q9_3.CFrame = CFrame.new(q9_2.Position + LookVector * 4 + Vector3.new(0, 3, 0), q9_2.Position)
end
local function fn297()
    local Character = LocalPlayer.Character
    local pu = Character and Character:FindFirstChild("HumanoidRootPart")
    return pu
end
local function onCharacterAdded()
    task.wait(0.3)
    if Toggles.FreezePlayer and Toggles.FreezePlayer.Value then
        nb(true)
    end
end
local function onCopyBitcoinAddress()
    mY(mU, "Copied Bitcoin address")
end
local function onRscripts()
    mY(mZ, "Copied Rscripts profile to clipboard")
end
local function onJumpRequest()
    if nh.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local td_1 = mS()
        if td_1 then
            td_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn342(cv)
    local DiscordGroup = cv:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = n2 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = n2 })
end
local function fn350(aM)
    local po = nC()
    if not po or not po.skillList then
        return nil
    end
    local pp_1 = po.skillList[aM]
    return pp_1 and pp_1.skill or nil
end
local function onExportConfigToClipboard()
    local vh_1
    local vg_1
    vg_1, vh_1 = pcall(nN.JSONEncode, nN, mV())
    if not vg_1 then
        nh:Notify("Failed to encode the config")
        return
    end
    local vg_2 = setclipboard or toclipboard
    local vg_3 = type(vg_2) ~= "function" or not pcall(vg_2, vh_1)
    if vg_3 then
        nh:Notify("Your executor does not support copying to the clipboard")
        return
    end
    nh:Notify("Config copied to clipboard", 6)
end
local function onInputBegan()
    nE = tick()
end
local function fn369()
    nf(Toggles.AntiGameplayPause.Value)
end
local function onCopyJoinScript_JobID()
    local qX = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, nw)
    if setclipboard then
        setclipboard(qX)
    elseif toclipboard then
        toclipboard(qX)
    end
    nh:Notify("Copied join script to clipboard")
end
local function fn446(aq, ar)
    return string.format('<font color="%s">%s</font>', ar, aq)
end
local function onCopyPayPalLink()
    mY(nY, "Copied PayPal link")
end
local function onImportConfigFromClipboardTex()
    local vm_1
    local vk = m3.SaveManager_ImportSource.Value or ""
    local vk_1
    local vl = tostring(vk):match("^%s*(.-)%s*$")
    if vl == "" then
        nh:Notify("Paste an exported config into the box first")
        return
    end
    vk_1, vm_1 = pcall(nN.JSONDecode, nN, vl)
    local vl_1 = not vk_1
    local vq = if vl_1 then 1 else 0
    local vo = 3525 * vq + 3051 * (1 - vq)
    local vp = 799 * vq + 3893 * (1 - vq)
    if not ((vo * 177 + vp * 778 + vo * vp) % 16777213 == 4062022) then
        vl_1 = type(vm_1) ~= "table"
    end
    if not vl_1 then
        vl_1 = type(vm_1.objects) ~= "table"
    end
    if vl_1 then
        nh:Notify("That is not a valid exported config")
        return
    end
    local vk_2 = 0
    for i, v in ipairs(vm_1.objects) do
        if nt(v) then
            vk_2 += 1
        end
    end
    if vk_2 == 0 then
        nh:Notify("No settings in that config matched this script")
        return
    end
    m3.SaveManager_ImportSource:SetValue("")
    local vm_2 = vk_2 == 1 and "" or "s"
    nh:Notify(("Imported %d setting%s"):format(vk_2, vm_2), 6)
end
local function fn529()
    if not workspace.CurrentCamera then
        return
    end
    nR:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    nR:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    nD = tick()
end
local function antiGameplayPauseLoop()
    while not nh.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            nf(true)
        end
    end
end
local function fn537(i8, i9)
    local Type = i9.Type
    if Type == "Toggle" then
        return { idx = i8, type = "Toggle", value = i9.Value == true }
    elseif Type == "Slider" then
        return { idx = i8, type = "Slider", value = tostring(i9.Value) }
    elseif Type == "Dropdown" then
        return { idx = i8, type = "Dropdown", multi = i9.Multi == true, value = i9.Value }
    elseif Type == "Input" then
        local uL = i9.Value
        local uP = if uL then 1 else 0
        local uN = 3125 * uP + 1807 * (1 - uP)
        local uO = 3491 * uP + 757 * (1 - uP)
        if not ((uN * 1527 + uO * 3090 + uN * uO) % 16777213 == 9691227) then
            uL = ""
        end
        return { idx = i8, type = "Input", text = tostring(uL) }
    elseif Type == "ColorPicker" then
        return { idx = i8, type = "ColorPicker", value = i9.Value:ToHex(), transparency = i9.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = i8,
            type = "KeyPicker",
            mode = i9.Mode,
            key = i9.Value,
            modifiers = i9.Modifiers,
            toggled = i9.Toggled
        }
    else
        return nil
    end
end
local function fn544()
    mY(m0, "Copied Discord invite to clipboard")
end
local function onCopyLitecoinAddress()
    mY(mX, "Copied Litecoin address")
end
local function onRenderStepped(gL)
    if nh.Unloaded then
        return
    end
    if Toggles.FreezePlayer and Toggles.FreezePlayer.Value then
        local tf_1 = m1()
        local tg_1 = mS()
        if tf_1 then
            tf_1.Anchored = true
            tf_1.AssemblyLinearVelocity = Vector3.zero
            tf_1.AssemblyAngularVelocity = Vector3.zero
        end
        if tg_1 then
            tg_1.PlatformStand = true
        end
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local tf_3 = mS()
        if tf_3 then
            tf_3.WalkSpeed = m3.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local tf_5 = m1()
        local tg_2 = mS()
        if tf_5 and tg_2 then
            tg_2.PlatformStand = true
            local tg_3 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                tg_3 = tg_3 + CurrentCamera.CFrame.LookVector
            end
            local tl = if UserInputService:IsKeyDown(Enum.KeyCode.S) then 1 else 0
            if tl == 1 then
                tg_3 = tg_3 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                tg_3 = tg_3 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                tg_3 = tg_3 + CurrentCamera.CFrame.RightVector
            end
            local tl_1 = if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
            if tl_1 == 1 then
                tg_3 = tg_3 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                tg_3 = tg_3 - Vector3.new(0, 1, 0)
            end
            tf_5.Velocity = Vector3.zero
            if tg_3.Magnitude > 0 then
                tf_5.CFrame = tf_5.CFrame + tg_3.Unit * m3.FlySpeed.Value * gL
            end
        end
    end
end
local function fn598(bj)
    if not bj then
        return 0
    end
    local pN = bj.rate or 1
    if pN <= 0 then
        pN = 1
    end
    local pM_1 = bj.atk
    local pR = if pM_1 then 1 else 0
    local pP = 771 * pR + 1765 * (1 - pR)
    local pQ = 1125 * pR + 3858 * (1 - pR)
    if not ((pP * 2069 + pQ * 1688 + pP * pQ) % 16777213 == 4361574) then
        pM_1 = 0
    end
    return pM_1 / pN
end
local function fn599(bm, bn)
    local pT_1
    local pS = nG(bm)
    if not pS then
        return math.huge
    end
    if pS.luck then
        pT_1 = pS.luck * 100
    else
        pT_1 = (pS.price or 0) * 50
    end
    return math.floor(pT_1 * 2.2 ^ bn)
end
local function autoSellDelayLoop()
    while not nh.Unloaded do
        local so_1 = m3.AutoSellDelay and m3.AutoSellDelay.Value or 1
        task.wait(so_1)
        if nO("AutoSell") then
            pcall(nM)
        end
    end
end
local function fn601(bd)
    local pF = DataMgr:GetPlayerBaseData("weaponInv")
    if not pF then
        return false
    end
    return pF[bd] ~= nil
end
local function worker2()
    local ro, rp, state, rr, rs, rt
    local ru = 41
    while true do
        local ru_1 = 13872 - ru
        do
            if ru_1 < 13845 then
                if ru_1 < 13835 then
                    if ru_1 < 13833 then
                        if ru_1 < 13826 then
                            if ru_1 < 13819 then
                                if ru_1 < 3645 then
                                    break
                                elseif ru_1 < 9803 then
                                    break
                                elseif ru_1 < 13818 then
                                    break
                                else
                                    ru = 10
                                end
                            elseif ru_1 < 13822 then
                                if ru_1 < 13821 then
                                    if ru_1 < 13820 then
                                        if ru_1 == 13819 then
                                            ru = 54
                                        else
                                            ru = 13860
                                            continue
                                        end
                                    elseif ru_1 == 13820 then
                                        ru = 54
                                    else
                                        ru = 2288
                                        continue
                                    end
                                else
                                    nQ = nil
                                    task.wait(0.1)
                                    ru = 17
                                end
                            elseif ru_1 < 13824 then
                                if ru_1 < 13823 then
                                    nQ = nil
                                    task.wait(0.5)
                                    ru = 24
                                elseif ru_1 == 13823 then
                                    ru = if not nQ then 43 else 2
                                else
                                    ru = 13841
                                    continue
                                end
                            elseif ru_1 < 13825 then
                                if ru_1 == 13824 then
                                    ru = if rp then 8 else 9
                                else
                                    ru = 13862
                                    continue
                                end
                            else
                                ru = if rr then 7 else 40
                            end
                        elseif ru_1 < 13829 then
                            if ru_1 < 13828 then
                                if ru_1 < 13827 then
                                    if ru_1 == 13826 then
                                        ru = if rr then 34 else 31
                                    else
                                        ru = 13836
                                        continue
                                    end
                                else
                                    ru = 21
                                end
                            elseif ru_1 == 13828 then
                                nQ = nil
                                nB(rp)
                                task.wait(0.05)
                                ru = 24
                            else
                                ru = 13847
                                continue
                            end
                        elseif ru_1 < 13831 then
                            if ru_1 < 13830 then
                                nQ = os.clock()
                                ru = 2
                            elseif ru_1 == 13830 then
                                nQ = nil
                                ru = if #ne(true, ro) > 0 then 18 else 29
                            else
                                ru = 13862
                                continue
                            end
                        elseif ru_1 < 13832 then
                            ru = 24
                        elseif ru_1 == 13832 then
                            ru = 35
                        else
                            ru = 13837
                            continue
                        end
                    elseif ru_1 < 13834 then
                        ru = if rt then 22 else 11
                    else
                        rt = rs <= 1.02
                        ru = 39
                    end
                elseif ru_1 < 13843 then
                    if ru_1 < 13839 then
                        if ru_1 < 13837 then
                            if ru_1 < 13836 then
                                rp = nx("Fish")
                                ru = if not rp then 6 else 27
                            else
                                rr = not nh.Unloaded
                                ru = 47
                            end
                        elseif ru_1 < 13838 then
                            if ru_1 == 13837 then
                                nQ = nil
                                rr = not rp
                                ru = if rr then 15 else 46
                            else
                                ru = 13822
                                continue
                            end
                        else
                            mO("Fish", "Exit")
                            ru = 31
                        end
                    elseif ru_1 < 13841 then
                        if ru_1 < 13840 then
                            ru = 24
                        elseif ru_1 == 13840 then
                            nQ = nil
                            task.wait(0.2)
                            ru = 24
                        else
                            ru = 13836
                            continue
                        end
                    elseif ru_1 < 13842 then
                        task.wait(0.2)
                        ru = 10
                    else
                        ru = 0
                    end
                elseif ru_1 < 13844 then
                    if ru_1 == 13843 then
                        task.wait(0.12)
                        ru = 53
                    else
                        ru = 13824
                        continue
                    end
                elseif ru_1 == 13844 then
                    mO("Fish", "Exit")
                    rp = true
                    ru = 35
                else
                    ru = 13835
                    continue
                end
            elseif ru_1 < 13860 then
                if ru_1 < 13851 then
                    if ru_1 < 13848 then
                        if ru_1 < 13847 then
                            if ru_1 < 13846 then
                                state = rp.state
                                ru = if state == 1 then 5 else 3
                            elseif ru_1 == 13846 then
                                task.wait(0.01)
                                ru = 19
                            else
                                ru = 13834
                                continue
                            end
                        else
                            nQ = nil
                            mO("Fish", "Enter")
                            task.wait(0.04)
                            ru = 17
                        end
                    elseif ru_1 < 13849 then
                        ru = 13
                    elseif ru_1 < 13850 then
                        break
                    else
                        mO("Fish", "Exit")
                        rp = true
                        ru = 35
                    end
                elseif ru_1 < 13854 then
                    if ru_1 < 13852 then
                        ru = 23
                    elseif ru_1 < 13853 then
                        ru = if state == 3 then 42 else 16
                    elseif ru_1 == 13853 then
                        ru = 30
                    else
                        ru = 13821
                        continue
                    end
                elseif ru_1 < 13857 then
                    if ru_1 < 13856 then
                        if ru_1 < 13855 then
                            ru = 24
                        else
                            ru = 53
                        end
                    else
                        ru = if state == 4 then 25 else 51
                    end
                elseif ru_1 < 13859 then
                    if ru_1 < 13858 then
                        if ru_1 == 13857 then
                            rr = nO("AutoPerfectCast")
                            ru = 46
                        else
                            ru = 13852
                            continue
                        end
                    elseif ru_1 == 13858 then
                        ru = if not nO("AutoPerfectCast") then 32 else 12
                    else
                        ru = 13852
                        continue
                    end
                elseif ru_1 == 13859 then
                    ru = if not nh.Unloaded then 14 else 45
                else
                    ru = 13819
                    continue
                end
            elseif ru_1 < 13866 then
                if ru_1 < 13863 then
                    if ru_1 < 13862 then
                        if ru_1 < 13861 then
                            ro = 160
                            rp = ne(true, ro)
                            ru = if #rp > 0 then 44 else 1
                        else
                            ru = if rr >= 6 then 28 else 26
                        end
                    elseif ru_1 == 13862 then
                        ru = 33
                    else
                        ru = 13827
                        continue
                    end
                elseif ru_1 < 13864 then
                    if ru_1 == 13863 then
                        task.wait(0.01)
                        ru = 52
                    else
                        ru = 13834
                        continue
                    end
                elseif ru_1 < 13865 then
                    if ru_1 == 13864 then
                        mO("Fish", "Exit")
                        nQ = nil
                        task.wait(0.2)
                        ru = 52
                    else
                        ru = 13826
                        continue
                    end
                elseif ru_1 == 13865 then
                    rr = os.clock() - nQ
                    rs = rr % 2
                    rt = rs >= 0.98
                    ru = if rt then 38 else 39
                else
                    ru = 13850
                    continue
                end
            elseif ru_1 < 16022 then
                if ru_1 < 13869 then
                    if ru_1 < 13868 then
                        if ru_1 < 13867 then
                            if ru_1 == 13866 then
                                nQ = nil
                                task.wait(0.2)
                                ru = 24
                            else
                                ru = 13850
                                continue
                            end
                        elseif ru_1 == 13867 then
                            mO("Fish", "Enter")
                            nQ = os.clock()
                            rp = false
                            ru = 30
                        else
                            ru = 13835
                            continue
                        end
                    else
                        rp = rr <= 1.02
                        ru = 48
                    end
                elseif ru_1 < 13871 then
                    if ru_1 < 13870 then
                        ru = if state == 2 then 49 else 20
                    elseif ru_1 == 13870 then
                        local rp_1 = os.clock() - nQ
                        rr = rp_1 % 2
                        rp = rr >= 0.98
                        ru = if rp then 4 else 48
                    else
                        ru = 712
                        continue
                    end
                elseif ru_1 < 13872 then
                    if ru_1 == 13871 then
                        ru = if not nk("Rod") then 50 else 37
                    else
                        ru = 3902
                        continue
                    end
                elseif ru_1 == 13872 then
                    rr = (nO("AutoPerfectCast"))
                    ru = if rr then 36 else 47
                else
                    ru = 3645
                    continue
                end
            else
                break
            end
        end
    end
end
local function antiAfkLoop()
    while not nh.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local uz = tick() - nE
            local uA = tick() - nD
            if uz >= 300 and uA >= 60 then
                pcall(nm)
            else
                if uz < 300 and uA >= 300 then
                    pcall(nm)
                end
            end
        end
    end
end
local function onCopySolanaAddress()
    mY(n0, "Copied Solana address")
end
local function fn696(ig)
    if ig:IsA("BasePart") then
        nW(ig, "CastShadow", false)
        nW(ig, "Reflectance", 0)
    else
        local t3 = (ig:IsA("Decal"))
        local t7 = if t3 then 1 else 0
        local t5 = 2228 * t7 + 342 * (1 - t7)
        local t6 = 1950 * t7 + 1243 * (1 - t7)
        if not ((t5 * 3016 + t6 * 888 + t5 * t6) % 16777213 == 12795848) then
            t3 = ig:IsA("Texture")
        end
        if t3 then
            nW(ig, "Transparency", 1)
        else
            local t3_1 = ig:IsA("ParticleEmitter") or ig:IsA("Trail") or ig:IsA("Beam")
            local t7_1 = if t3_1 then 1 else 0
            local t5_1 = 2738 * t7_1 + 3713 * (1 - t7_1)
            local t6_1 = 2693 * t7_1 + 3043 * (1 - t7_1)
            if not ((t5_1 * 305 + t6_1 * 1377 + t5_1 * t6_1) % 16777213 == 11916785) then
                t3_1 = ig:IsA("Smoke")
            end
            if not t3_1 then
                t3_1 = ig:IsA("Fire")
            end
            if not t3_1 then
                t3_1 = ig:IsA("Sparkles")
            end
            if not t3_1 then
                t3_1 = ig:IsA("PostEffect")
            end
            if t3_1 then
                nW(ig, "Enabled", false)
            elseif ig:IsA("Atmosphere") then
                nW(ig, "Density", 0)
            end
        end
    end
end
local function fn709(aF)
    local pl = Toggles[aF]
    return pl and pl.Value == true
end
local function onUnload()
    nh:Unload()
end
local function fn726(d3)
    local rv = m3.AutoSellQualities and m3.AutoSellQualities.Value
    if type(rv) ~= "table" then
        return true
    end
    return rv[d3] == true
end
local function fn737()
    connection2:Disconnect()
    connection3:Disconnect()
    m_()
    nf(false)
    nb(false)
    select("#", "Unloaded!")
end
local function fn754(i0, i1)
    local uE_1 = (i0 == "Toggle" and Toggles or m3)[i1]
    local uD_2 = type(uE_1) == "table" and uE_1.Type == i0
    return uD_2 and uE_1 or nil
end
local function onStepped()
    if nh.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local s2_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if s2_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn823()
    local qQ_1
    local qP_1
    if identifyexecutor then
        qQ_1, qP_1 = identifyexecutor()
        local qR = qQ_1 ~= ""
        local qS = type(qQ_1) == "string" and qR
        if qS then
            local qR_1 = type(qP_1) == "string" and qP_1 ~= "" and qQ_1 .. " " .. qP_1
            nU = qR_1 or qQ_1
        end
    end
end
local function fn829()
    local SystemPanel = LocalPlayer.PlayerGui:FindFirstChild("SystemPanel")
    local rJ = SystemPanel and SystemPanel:FindFirstChild("Main")
    local rI_1 = rJ
    if rJ then
        rJ = rI_1:FindFirstChild("Red")
    end
    local rI_2 = rJ
    if not rI_2 then
        return
    end
    for i, child in ipairs(rI_2:GetChildren()) do
        ns(child)
    end
end
local function fn845(ay, az)
    if setclipboard then
        setclipboard(ay)
    elseif toclipboard then
        toclipboard(ay)
    end
    nh:Notify(az)
end
local function fn860()
    nb(Toggles.FreezePlayer.Value)
end
local function fn861()
    if not Toggles.Fly.Value and not (Toggles.FreezePlayer and Toggles.FreezePlayer.Value) then
        local tv_1 = mS()
        if tv_1 then
            tv_1.PlatformStand = false
        end
    end
end
local function fn871()
    table.clear(n1)
    table.clear(nZ)
    local EItem = workspace:FindFirstChild("EItem")
    if not EItem then
        return
    end
    for i, child in ipairs(EItem:GetChildren()) do
        local o7_1 = child:IsA("Model") and child.Name ~= "gatecam"
        if o7_1 then
            local Humanoid = child:FindFirstChildOfClass("Humanoid")
            local ProximityPrompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
            if Humanoid or ProximityPrompt then
                local o7_3 = child:FindFirstChild("HumanoidRootPart") or child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)
                if o7_3 then
                    nZ[child.Name] = child
                    n1[#n1 + 1] = child.Name
                end
            end
        end
    end
    table.sort(n1)
end
local function fn890(bs)
    local pW = nC()
    if not pW or not pW.bag then
        return nil
    end
    local pX_1 = pW.bag.count or 0
    local p2 = 1
    while p2 <= pX_1 do
        local p3 = p2
        local pX_2 = pW.bag[p3]
        if pX_2 and pX_2.id then
            local pY_1 = nG(pX_2.id)
            if pY_1 and pY_1.type == bs then
                return p3, pX_2, pY_1
            end
        end
        p2 += 1
    end
    return nil
end
local function fn919()
    if not Toggles.WalkSpeedEnabled.Value then
        local tH = mS()
        if tH then
            tH.WalkSpeed = 16
        end
    end
end
local function fn923()
    local rZ = nC()
    if not rZ or not rZ.bag then
        return false
    end
    local r0 = m3.AutoSellMode and m3.AutoSellMode.Value or "Sell All"
    local r0_1 = rZ.bag.count or 0
    local r5 = 1
    while r5 <= r0_1 do
        local r0_2 = rZ.bag[r5]
        if r0_2 and r0_2.id then
            local r1_1 = nG(r0_2.id)
            if r1_1 and r1_1.type == "Fish" and r1_1.canSell ~= false then
                local r0_4 = r0 == "Sell All" or mQ(r1_1.quality)
                if r0_4 then
                    return true
                end
            end
        end
        r5 += 1
    end
    return false
end
local function fn929(at, au, av)
    return string.format("<b>%s</b> %s %s", at, nl("-", "#5a6070"), nl(au, av))
end
local function fn931(bh)
    if not bh then
        return 0
    end
    return (bh.strength or 0) * 1000 + (bh.luck or 0) * 100 + (bh.fish or 0)
end
local function fn939(g2)
    local tm = m1()
    local tn = mS()
    if g2 then
        if tm then
            tm.Anchored = true
            tm.AssemblyLinearVelocity = Vector3.zero
            tm.AssemblyAngularVelocity = Vector3.zero
        end
        if tn then
            tn.PlatformStand = true
        end
        return
    end
    if tm then
        tm.Anchored = false
    end
    if tn and not (Toggles.Fly and Toggles.Fly.Value) then
        tn.PlatformStand = false
    end
end
local function worker3()
    while not nh.Unloaded do
        task.wait(1)
        if nO("AutoBuyRod") then
            pcall(nq, "Rod", m9)
        end
        if nO("AutoBuyWeapon") then
            pcall(nq, "Weapon", m2)
        end
    end
end
local function onCopyUSDTAddress()
    mY(mP, "Copied USDT address")
end
local function fn948(bV)
    if not nO("SkipHighHpFish") then
        return false
    end
    local qg = m3.SkipFishHpOver and m3.SkipFishHpOver.Value
    local qh = tonumber(qg)
    if not qh then
        return false
    end
    local qg_1 = tonumber(bV:GetAttribute("hp"))
    if not qg_1 then
        return false
    end
    return qg_1 > qh
end
local function worker()
    local q2_1
    while true do
        task.wait(1)
        if nh.Unloaded then
            break
        end
        local q1 = math.floor(os.clock() - nd)
        if q1 < 60 then
            q2_1 = q1 .. "s"
        elseif q1 < 3600 then
            q2_1 = string.format("%dm %ds", math.floor((q1) / (60)), q1 % 60)
        else
            q2_1 = string.format("%dh %dm", math.floor((q1) / (3600)), math.floor((q1 % 3600) / (60)))
        end
        Label:SetText(nc("Session time", q2_1, np))
    end
end
mO = nil
mP = nil
mQ = nil
mR = nil
mS = nil
connection3 = nil
mU = nil
mV = nil
mX = nil
mY = nil
mZ = nil
m_ = nil
m0 = nil
m1 = nil
m2 = nil
m3 = nil
m4 = nil
connection2 = nil
Toggles = nil
m9 = nil
na = nil
nb = nil
nc = nil
nd = nil
ne = nil
nf = nil
ng = nil
nh = nil
ni = nil
nk = nil
nl = nil
nm = nil
np = nil
nq = nil
DataMgr = nil
ns = nil
nt = nil
CurrentCamera = nil
nw = nil
nx = nil
Label = nil
LocalPlayer = nil
nA = nil
local mW, m5, m8, nj, nn, GameMgr, nv
nB = nil
nC = nil
nD = nil
nE = nil
Lighting = nil
nG = nil
nI = nil
nJ = nil
nL = nil
nM = nil
nN = nil
nO = nil
nQ = nil
nR = nil
nS = nil
nT = nil
nU = nil
nW = nil
UserInputService = nil
nY = nil
nZ = nil
n0 = nil
n1 = nil
n2 = nil
connection = nil
n4 = nil
local nH, nK, nP, nV, n_
nH = nil
nK = nil
nP = nil
nV = nil
n_ = nil
local ou, ov, ow, oy
UserInputService, nR, nN, nK, nH, Lighting, LocalPlayer, DataMgr, GameMgr = nil, nil, nil, nil, nil, nil, nil, nil, nil
local vA_16 = game:GetService("Players")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
if not nN and not nN or GameMgr and not nK or (nN and not nR or nK and nN) or not (not nN and not nN or GameMgr and not nK or (nN and not nR or nK and nN)) then
    nR = game:GetService("VirtualUser")
    nN = game:GetService("HttpService")
else
    nN = game:GetService("VirtualUser")
    nR = game:GetService("HttpService")
end
if (not nK and nK and (nK or nR) and (not nK or nR or not nR and nK) or (nR or nK or (not nR or nR)) and ((not nK or not nK) and (not nR and not nR))) and ((not nK or nR or nK and nK) and ((not nR or nK) and (not nK or nK)) or ((not nK or not nR) and (nK and nK) or (nR and not nR or (not nR or not nR)))) or not ((not nK and nK and (nK or nR) and (not nK or nR or not nR and nK) or (nR or nK or (not nR or nR)) and ((not nK or not nK) and (not nR and not nR))) and ((not nK or nR or nK and nK) and ((not nR or nK) and (not nK or nK)) or ((not nK or not nR) and (nK and nK) or (nR and not nR or (not nR or not nR))))) then
    nK = game:GetService("GuiService")
    nH = game:GetService("CoreGui")
else
    nH = game:GetService("GuiService")
    nK = game:GetService("CoreGui")
end
Lighting = game:GetService("Lighting")
local vA_18 = game:GetService("ReplicatedFirst")
LocalPlayer = vA_16.LocalPlayer
local vA_3 = "Reeled"
local vA_9 = vA_18:WaitForChild("Scripts")
DataMgr = require(vA_9.BaseManager.DataMgr)
GameMgr = require(vA_9.BaseManager.GameMgr)
while not GameMgr.FinishLoad do
    task.wait(0.1)
end
vA_1, nh, vA_7, na, Toggles, m3, m0, mZ, mX, mU, mR, mP, n0, nY, nS, vA_10, vA_2, vA_17, vA_8, vA_22, vA_14, vA_5, vA_20, vA_18, np, vA_9, vA_21, vA_13, vA_4, vA_19, m5 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
vA_16 = 8
repeat
    vA_15 = (vA_16 * 9 + 12) % 14 + 1
    if vA_15 <= 7 then
        if vA_15 <= 4 then
            if vA_15 <= 2 then
                if vA_15 <= 1 then
                    if vA_16 * 89190711 + 7 + 5 <= vA_16 * 89190711 + 7 + 5 + 4 then
                        vA_1 = ""
                    else
                        vA_2 = ""
                    end
                    vA_16 = (vA_16 + 11) % 56
                else
                    vA_23 = {
                        "cisytsjc",
                        "tvwakchccm",
                        "mezt",
                        "rdpshuuhux",
                        "dfcanpxaihlf",
                        "qxx",
                        "vhtlzr",
                        "vxsb",
                        "hvldwionfpc"
                    }
                    if vA_23[(vA_16 * 79 + 60) % 9 + 1] < vA_23[(vA_16 * 79 + 60) % 9 + 1] then
                        vA_1 = getgenv().Library
                    else
                        nh = getgenv().Library
                    end
                    vA_16 = (vA_16 + 53) % 56
                end
            elseif vA_15 <= 3 then
                if (nS or nS or (vA_8 or not vA_16)) and (not nY or vA_16 or not nY and vA_16) and (nS or vA_8 or (mZ or nY) or (vA_22 or nY or not nS and vA_8)) and (vA_22 and vA_8 or (mZ or vA_8) or (not nY or nY) and (not mZ and not vA_16) or ((vA_8 or vA_16) and (not nY or not vA_16) or (nY and not vA_22 or vA_8 and vA_8))) and not ((nS or nS or (vA_8 or not vA_16)) and (not nY or vA_16 or not nY and vA_16) and (nS or vA_8 or (mZ or nY) or (vA_22 or nY or not nS and vA_8)) and (vA_22 and vA_8 or (mZ or vA_8) or (not nY or nY) and (not mZ and not vA_16) or ((vA_8 or vA_16) and (not nY or not vA_16) or (nY and not vA_22 or vA_8 and vA_8)))) then
                    vA_1 = getgenv().ThemeManager
                    vA_7 = getgenv().SaveManager
                else
                    vA_7 = getgenv().ThemeManager
                    na = getgenv().SaveManager
                end
                vA_16 = (vA_16 + 25) % 56
            else
                local wg = bit32.rrotate(bit32.bxor(bit32.lrotate(vA_16, 7), string.byte(tostring(m3))), 5)
                if bit32.bxor(bit32.lrotate(bit32.bxor(wg, 918620459), 26), 2900034596) ~= bit32.lrotate(wg, 26) then
                    nh = Toggles.Toggles
                else
                    Toggles = nh.Toggles
                end
                vA_16 = (vA_16 + 25) % 56
            end
        elseif vA_15 <= 6 then
            if vA_15 <= 5 then
                vA_23 = { "pctmuyqmq", "qzsikxkql", "xqkr", "bbachof", "jihkq", "ottqhbtbst", "vdlybd" }
                local wM = vA_16
                ou = vA_23[wM % 7 + 1]
                if ou:len() >= ou:gsub("(.)", "%1%1", wM % 3 % 2 + 1):len() then
                    m0 = nil
                    nh = "https://discord.gg/K7Qxnxkk46"
                    m3 = "https://discord.gg/K7Qxnxkk46"
                    mZ = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
                    mX = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
                else
                    m3 = nh.Options
                    m0 = "https://discord.gg/K7Qxnxkk46"
                    mZ = "https://discord.gg/K7Qxnxkk46"
                    mX = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
                    mU = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
                end
                vA_16 = (vA_16 + 39) % 56
            else
                vA_23 = {
                    "fepzlvva",
                    "fnfp",
                    "ifreov",
                    "xnenghjbkp",
                    "scnuod",
                    "oicwdd",
                    "iosx",
                    "jnqly",
                    "blnmiuwyl",
                    "zylpzczzj",
                    "neqdharmtc",
                    "bpstqvrumm",
                    "vgkcb"
                }
                if vA_23[(vA_16 * 49 + 110) % 13 + 1] < vA_23[(vA_16 * 49 + 110) % 13 + 1] then
                    mP = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                    mR = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                else
                    mR = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                    mP = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                end
                vA_16 = (vA_16 + 39) % 56
            end
        else
            local wX = bit32.rrotate(bit32.bxor(bit32.lrotate(vA_16, 25), string.byte(tostring(np))), 5)
            if bit32.bxor(bit32.lrotate(bit32.bxor(wX, 464197241), 22), 2655447749) ~= bit32.lrotate(wX, 22) then
                vA_10 = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
            else
                n0 = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
            end
            vA_16 = (vA_16 + 25) % 56
        end
    elseif vA_15 <= 11 then
        if vA_15 <= 9 then
            if vA_15 <= 8 then
                vA_23 = (vector.create((vA_16 * 6 + 9) % 11 + 1, (vA_16 * 6 + 13) % 13 + 1, (vA_16 * 4 + 8) % 17 + 1))
                ou = (vector.create((vA_16 * 1 + 3) % 11 + 1, (vA_16 * 10 + 8) % 13 + 1, (vA_16 * 3 + 17) % 17 + 1))
                ov = (vector.create((vA_16 * 2 + 6) % 11 + 1, (vA_16 * 1 + 13) % 13 + 1, (vA_16 * 13 + 5) % 17 + 1))
                ow = (vector.create((vA_16 * 4 + 6) % 11 + 1, (vA_16 * 3 + 10) % 13 + 1, (vA_16 * 5 + 11) % 17 + 1))
                if vector.dot(vector.cross(vA_23, ou), (vector.cross(ov, ow))) == vector.dot(vA_23, ov) * vector.dot(ou, ow) - vector.dot(vA_23, ow) * vector.dot(ou, ov) then
                    nY = ""
                    nS = ""
                    vA_10 = "#345d9d"
                    vA_2 = "#f7931a"
                    vA_17 = "#627eea"
                else
                    vA_2 = ""
                    vA_17 = ""
                    nS = "#345d9d"
                    nY = "#f7931a"
                    vA_10 = "#627eea"
                end
                vA_16 = (vA_16 + 25) % 56
            else
                if (vA_16 * 1 + 2) * 5 % 4 == ((vA_16 * 1 + 2) * 5 + 9) % 4 then
                    vA_14 = "#26a17b"
                    vA_8 = "#14f195"
                    vA_22 = "#0070ba"
                else
                    vA_8 = "#26a17b"
                    vA_22 = "#14f195"
                    vA_14 = "#0070ba"
                end
                vA_16 = (vA_16 + 39) % 56
            end
        elseif vA_15 <= 10 then
            vA_23 = {
                "jyutqlvhj",
                "sqkinv",
                "uhrgogr",
                "flm",
                "dxonygtkh",
                "boofwxdfx",
                "ljqu",
                "jggxx",
                "rqwsdysqvlx",
                "bop",
                "cnbrr",
                "ixxleghkc"
            }
            local wQ = vA_16
            ou = vA_23[wQ % 12 + 1]
            if ou:len() <= ou:gsub("(.)", "%1%1", wQ % 3 % 2 + 1):len() then
                vA_5 = "#008cff"
                vA_20 = "#7fd47f"
                vA_18 = "#6ec1ff"
                np = "#e8a34d"
            else
                np = "#008cff"
                vA_5 = "#7fd47f"
                vA_20 = "#6ec1ff"
                vA_18 = "#e8a34d"
            end
            vA_16 = (vA_16 + 11) % 56
        else
            local wp = bit32.rrotate(bit32.bxor(bit32.lrotate(vA_16, 4), string.byte(tostring(Toggles))), 8)
            if bit32.bxor(bit32.lrotate(bit32.bxor(wp, 223952026), 18), 4066915684) ~= bit32.lrotate(wp, 18) then
                vA_13 = "#8b93a3"
                vA_9 = { "epic", "devil", "common", "legend", "elite" }
                vA_21 = { "Weapon", "Both", "Rod" }
            else
                vA_9 = "#8b93a3"
                vA_21 = { "common", "elite", "epic", "legend", "devil" }
                vA_13 = { "Rod", "Weapon", "Both" }
            end
            vA_16 = (vA_16 + 53) % 56
        end
    elseif vA_15 <= 13 then
        if vA_15 <= 12 then
            vA_15 = { "fgemzd", "oeguksv", "xmjfvarorx", "qsdsgyp", "alebdcpr", "uzkpuvycb", "dmnc" }
            local wI = vA_16
            vA_23 = vA_15[wI % 7 + 1]
            if vA_23:len() >= vA_23:gsub("(.)", "%1%1", wI % 3 % 2 + 1):len() then
                vA_9 = { "Sell All", "By Quality" }
            else
                vA_4 = { "Sell All", "By Quality" }
            end
            vA_16 = (vA_16 + 11) % 56
        else
            local wN = bit32.rrotate(bit32.bxor(bit32.lrotate(vA_16, 16), string.byte(tostring(mP))), 21)
            if bit32.bxor(bit32.lrotate(bit32.bxor(wN, 4024907668), 2), 3214728787) ~= bit32.lrotate(wN, 2) then
                nS = {}
            else
                vA_19 = {}
            end
            vA_16 = (vA_16 + 39) % 56
        end
    else
        if (not vA_18 and not m5 and (not mZ and not vA_18) or (not m5 or vA_18) and (vA_18 and not vA_18) or (vA_18 and not mZ and (mZ or vA_20) or not m5 and mZ and (vA_20 and mZ))) and ((not vA_20 or vA_20) and (vA_20 or not m5) and (not vA_18 and m5 or (mZ or mZ)) and (vA_20 or not vA_18 or not mZ and m5 or mZ and mZ and (not vA_20 or mZ))) and not ((not vA_18 and not m5 and (not mZ and not vA_18) or (not m5 or vA_18) and (vA_18 and not vA_18) or (vA_18 and not mZ and (mZ or vA_20) or not m5 and mZ and (vA_20 and mZ))) and ((not vA_20 or vA_20) and (vA_20 or not m5) and (not vA_18 and m5 or (mZ or mZ)) and (vA_20 or not vA_18 or not mZ and m5 or mZ and mZ and (not vA_20 or mZ)))) then
            vA_2 = {}
        else
            m5 = {}
        end
        vA_16 = (vA_16 + 53) % 56
    end
until (vA_16 * 45 + 8) % 56 == 32
for i = 2000, 2010 do
    local oM = i
    vA_16, vA_1 = pcall(function()
        return DataMgr:GetConfig("WorldData", oM)
    end)
    vA_15 = vA_16 and vA_1 and vA_1.name
    if vA_15 then
        vA_19[#vA_19 + 1] = vA_1.name
        m5[vA_1.name] = oM
    end
end
n1, nZ, vA_16, ou, nT, nl, nc, mY, n2, nO, nC, nx, m8, m1, mS, nV, nG, nn, m9, m2, mW, nP, nk, mO, nA, ne, nB, vA_23 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
n1 = {}
nZ = {}
nT = fn871
nT()
nl = fn446
nc = fn929
mY = fn845
n2 = fn544
nO = fn709
nC = fns.fn71
nx = fn350
m8 = fns.fn108
m1 = fn297
mS = fns.fn174
nV = fns.fn88
nG = function(a6)
    local pD_1
    local pC_1
    pC_1, pD_1 = pcall(function()
        return DataMgr:GetConfig("ItemData", a6)
    end)
    if pC_1 then
        return pD_1
    end
    return nil
end
nn = fn601
m9 = fn931
m2 = fn598
mW = fn599
nP = fn890
nk = function(bD)
    local p5
    local p6
    p5 = nil
    p6 = nil
    p5 = nC()
    if not p5 then
        return false
    end
    if p5.equippedItem and p5.equippedItem.data and p5.equippedItem.data.type == bD then
        return true
    end
    p6 = nP(bD)
    if not p6 then
        return false
    end
    pcall(function()
        p5:EquipItem(p6)
    end)
    local p7_1 = os.clock()
    while true do
        if not (os.clock() - p7_1 < 2) then
            return false
        end
        p5 = nC()
        if p5 and p5.equippedItem and p5.equippedItem.data and p5.equippedItem.data.type == bD then
            break
        end
        task.wait(0.05)
    end
    return true
end
mO = function(bM, bN, ...)
    local qd
    qd = nil
    qd = nC()
    if not qd then
        return false
    end
    local qe = pcall(function(...)
        qd:TrigerSkill(bM, bN, ...)
    end, ...)
    return qe
end
nA = fn948
ne = fns.fn97
nB = function(cj)
    if #cj == 0 then
        return false
    elseif not nk("Weapon") then
        return false
    else
        local qG = nx("GunFire")
        if not qG then
            return false
        end
        for i, v in ipairs(cj) do
            local qO = v
            if nh.Unloaded then
                break
            elseif not (not qO or not qO.Parent) then
                pcall(function()
                    qG:Fire("Atk", qO)
                end)
            end
        end
        task.wait(0.02)
        return true
    end
end
if (nZ and not nC and (nO or mY) and ((not vA_23 or nZ) and (not nC or mY)) or (not nO and vA_23 or (vA_23 or not nO)) and (not nO and not nO and (nC and not nZ))) and not (nZ and not nC and (nO or mY) and ((not vA_23 or nZ) and (not nC or mY)) or (not nO and vA_23 or (vA_23 or not nO)) and (not nO and not nO and (nC and not nZ))) then
    vA_3 = vA_16:CreateWindow({
        Footer = { "|", { Text = nh, Copyable = true }, m0 },
        NotifySide = "Right",
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        CornerRadius = 0,
        Icon = 78539693571783,
        ShowCustomCursor = false
    })
else
    vA_16 = nh:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = m0, Copyable = true }, "|", vA_3 },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0
    })
end
if (nx and not nP or not nC and ne) and ((nx or ne) and (nC or nP)) or (nx and nC or not nC and not ne or (nP or ne) and (not nx or not nx)) or not ((nx and not nP or not nC and ne) and ((nx or ne) and (nC or nP)) or (nx and nC or not nC and not ne or (nP or ne) and (not nx or not nx))) then
    ou = {
        Info = vA_16:AddTab("Info", "info"),
        Main = vA_16:AddTab("Main", "fish"),
        Player = vA_16:AddTab("Player", "person-standing"),
        Settings = vA_16:AddTab("Settings", "settings")
    }
else
    vA_16 = {
        Player = ou:AddTab("Player", "person-standing"),
        Main = ou:AddTab("Main", "fish"),
        Settings = ou:AddTab("Settings", "settings"),
        Info = ou:AddTab("Info", "info")
    }
end
vA_23 = fn342
for k, v in ou do
    vA_23(v)
end
nU, vA_1, ov, Label, nw, vA_15 = nil, nil, nil, nil, nil, nil
vA_16 = 7
repeat
    vA_23 = (vA_16 * 2 + 0) % 3 + 1
    if vA_23 <= 2 then
        if vA_23 <= 1 then
            vA_23 = { "mhnboznwaey", "hmmsgv", "mwyue", "moxiyqm", "gqpcl", "fzatxemfvk", "pdckvsjdksr", "iczdevf" }
            if vA_23[(vA_16 * 89 + 46) % 8 + 1] < vA_23[(vA_16 * 89 + 46) % 8 + 1] then
                nU = tostring(game.JobId)
            else
                nw = tostring(game.JobId)
            end
            vA_16 = (vA_16 + 11) % 24
        else
            if vA_16 * 132692897 + 9 + 3 >= vA_16 * 132692897 + 9 + 3 + 5 then
                nw = #vA_15 > 18
            else
                vA_15 = #nw > 18
            end
            vA_16 = (vA_16 + 17) % 24
        end
    else
        vA_23 = (vector.create((vA_16 * 2 + 7) % 11 + 1, (vA_16 * 7 + 5) % 13 + 1, (vA_16 * 9 + 9) % 17 + 1))
        ow = (vector.create((vA_16 * 5 + 5) % 11 + 1, (vA_16 * 3 + 9) % 13 + 1, (vA_16 * 14 + 14) % 17 + 1))
        local ox = (vector.create((vA_16 * 4 + 6) % 11 + 1, (vA_16 * 10 + 5) % 13 + 1, (vA_16 * 12 + 1) % 17 + 1))
        oy = (vector.create((vA_16 * 4 + 1) % 5 + 1, (vA_16 * 4 + 1) % 7 + 1, (vA_16 * 4 + 7) % 9 + 1))
        if vector.dot(vector.cross(vA_23, (vector.cross(ow, ox))), oy) == vector.dot(ow * vector.dot(vA_23, ox) - ox * vector.dot(vA_23, ow), oy) then
            nU = "Unknown"
            pcall(fn823)
            vA_1 = ou.Info:AddLeftGroupbox("Account", "circle-user")
            vA_1:AddLabel(nc("User", LocalPlayer.Name, vA_20), true)
            vA_1:AddLabel(nc("Status", "Keyless", vA_20), true)
            vA_1:AddLabel(nc("Executor", nU, vA_20), true)
            ov = ou.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            ov:AddLabel(nl(vA_3 .. " [" .. tostring(game.PlaceId) .. "]", vA_18), true)
            ov:AddLabel(nc("Place ID", tostring(game.PlaceId), vA_18), true)
            Label = ov:AddLabel(nc("Session time", "0s", np), true)
        else
            vA_20 = "Unknown"
            pcall(fn823)
            ov = vA_1.Info:AddLeftGroupbox("Account", "circle-user")
            ov:AddLabel(vA_18("User", nU.Name, Label), true)
            ov:AddLabel(vA_18("Status", "Keyless", Label), true)
            ov:AddLabel(vA_18("Executor", "Unknown", Label), true)
            ou = vA_1.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            ou:AddLabel(vA_3(nl .. " [" .. tostring(game.PlaceId) .. "]", np), true)
            ou:AddLabel(vA_18("Place ID", tostring(game.PlaceId), np), true)
            nc = ou:AddLabel(vA_18("Session time", "0s", LocalPlayer), true)
        end
        vA_16 = (vA_16 + 23) % 24
    end
until (vA_16 * 7 + 11) % 24 == 9
if vA_15 then
    vA_16 = 7
    repeat
        if (vA_16 * 2 + 8) * 4 % 3 == ((vA_16 * 2 + 8) * 4 + 5) % 3 then
            nw = string.sub(vA_15, 1, 18) .. "..."
        else
            vA_15 = string.sub(nw, 1, 18) .. "..."
        end
        vA_16 = (vA_16 + 6) % 8
    until (vA_16 * 7 + 2) % 8 == 5
end
vA_16 = vA_15 or nw
nd = nil
ow = vA_16
ov:AddLabel(nc("Server", ow, vA_9), true)
ov:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
nd = os.clock()
task.spawn(worker)
vA_1 = ou.Info:AddRightGroupbox("Scripts", "package")
vA_1:AddLabel(nl("Included in this hub", vA_9), true)
vA_1:AddLabel(nl(vA_3, vA_18), true)
local FeaturesGroup = ou.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(nl("Auto Perfect Cast", vA_18), true)
FeaturesGroup:AddLabel(nl("Skip High HP Fish", np), true)
FeaturesGroup:AddLabel(nl("Auto Sell", vA_20), true)
FeaturesGroup:AddLabel(nl("Hide No Sell Notify", vA_9), true)
FeaturesGroup:AddLabel(nl("Auto Buy", vA_9), true)
FeaturesGroup:AddLabel(nl("Auto Upgrade", vA_18), true)
FeaturesGroup:AddLabel(nl("Teleports", np), true)
FeaturesGroup:AddLabel(nl("FPS Boost", vA_9), true)
local SocialsGroup = ou.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = n2 })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = ou.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = n2 })
oy = ou.Info:AddRightGroupbox("Donations", "heart")
oy:AddLabel(nl("All donations are optional but appreciated.", np), true)
oy:AddLabel(nl("If you donate you get a special role, just PING after you donate.", vA_20), true)
oy:AddDivider()
oy:AddLabel(nl("LTC / Litecoin", vA_10), true)
oy:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
oy:AddLabel(nl("BTC / Bitcoin", vA_2), true)
oy:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
oy:AddLabel(nl("ETH / Ethereum", vA_17), true)
oy:AddButton({ Text = "Copy Ethereum Address", Func = fns.onCopyEthereumAddress })
oy:AddLabel(nl("USDT", vA_8), true)
oy:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
oy:AddLabel(nl("Solana", vA_22), true)
oy:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
oy:AddLabel(nl("PayPal", vA_14), true)
oy:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
oy:AddLabel(nl("Venmo", vA_5), true)
oy:AddButton({ Text = "Copy Venmo Link", Func = fns.onCopyVenmoLink })
oy:AddDivider()
oy:AddLabel(nl("Don't have any of the listed currencies but still wanna donate?", vA_9), true)
oy:AddLabel(nl("DM me and we'll work something out.", vA_18), true)
vA_23 = ou.Info:AddRightGroupbox("FAQ", "circle-help")
vA_23:AddLabel("Where do I get a good config?", true)
vA_23:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
vA_23:AddLabel("How do I import / export configs?", true)
vA_23:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
vA_23:AddLabel("How do I report bugs?", true)
vA_23:AddLabel("Join the Discord and post it in the bugs channel.", true)
vA_23:AddLabel("How do I make suggestions?", true)
vA_23:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
vA_23:AddLabel("How do I get help or updates?", true)
vA_23:AddLabel("Join the Discord, updates and support are posted there first.", true)
vA_15 = ou.Main:AddLeftGroupbox("Fishing", "fish")
vA_15:AddToggle("AutoPerfectCast", { Text = "Auto Perfect Cast", Default = false })
vA_15:AddToggle("SkipHighHpFish", { Text = "Skip Fish if Health Over", Default = false })
vA_15:AddInput("SkipFishHpOver", { Text = "Health Over", Default = "500", Numeric = true, Finished = true })
local TeleportGroup = ou.Main:AddRightGroupbox("Teleport", "map-pin")
vA_16 = #vA_19 > 0 and vA_19
vA_1 = { "Warm water Lake" }
vA_9 = vA_16 or vA_1
vA_16 = vA_19[1] or "Warm water Lake"
TeleportGroup:AddDropdown("TeleportZone", { Text = "Zone", Values = vA_9, Default = vA_16 })
vA_16 = #n1 > 0 and n1
vA_1 = { "None" }
vA_9 = vA_16
local o0 = if vA_9 then 1 else 0
local oZ = 1289 * o0 + 2549 * (1 - o0)
local o_ = 3703 * o0 + 419 * (1 - o0)
if not ((oZ * 3 + o_ * 1242 + oZ * o_) % 16777213 == 9376160) then
    vA_9 = vA_1
end
vA_16 = n1[1] or "None"
nQ, nL, mQ, nI, ns, ni = nil, nil, nil, nil, nil, nil
TeleportGroup:AddDropdown("TeleportNpc", { Text = "NPC", Values = vA_9, Default = vA_16 })
TeleportGroup:AddButton({
    Text = "Teleport to Zone",
    Func = function()
        local q4
        local q5 = m3.TeleportZone and m3.TeleportZone.Value
        local q6 = q5
        if q5 then
            q5 = m5[q6]
        end
        q4 = q5
        if not q4 then
            nh:Notify("Zone not found")
            return
        end
        pcall(function()
            GameMgr:Teleport(q4)
        end)
    end
})
TeleportGroup:AddButton({ Text = "Teleport to NPC", Func = onTeleportToNPC })
TeleportGroup:AddButton({ Text = "Refresh NPC List", Func = onRefreshNPCList })
vA_3 = ou.Main:AddRightGroupbox("Auto Sell", "tag")
vA_3:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
vA_3:AddToggle("HideNoSellNotify", { Text = "Hide No Sell Notify", Default = true })
vA_3:AddDropdown("AutoSellMode", { Text = "Sell Mode", Values = vA_4, Default = "Sell All" })
vA_3:AddDropdown("AutoSellQualities", {
    Text = "Qualities",
    Values = vA_21,
    Default = { "common", "elite" },
    Multi = true,
    SelectAllButtons = true,
    Expandable = true
})
vA_3:AddSlider("AutoSellDelay", { Text = "Sell Delay", Default = 1, Min = 0.2, Max = 10, Rounding = 1 })
vA_18 = ou.Main:AddLeftGroupbox("Shop", "shopping-cart")
vA_18:AddToggle("AutoBuyRod", { Text = "Auto Buy Best Affordable Rod", Default = false })
vA_18:AddToggle("AutoBuyWeapon", { Text = "Auto Buy Best Affordable Weapon", Default = false })
vA_18:AddToggle("AutoEquipBought", { Text = "Equip After Buy", Default = true })
vA_1 = ou.Main:AddLeftGroupbox("Upgrade", "arrow-up")
vA_1:AddToggle("AutoUpgradeGear", { Text = "Auto Upgrade Gear", Default = false })
vA_1:AddDropdown("AutoUpgradeTarget", { Text = "Upgrade Target", Values = vA_13, Default = "Both" })
vA_1:AddSlider("AutoUpgradeMaxLevel", { Text = "Max Level", Default = 10, Min = 1, Max = 10, Rounding = 0 })
nQ = nil
task.spawn(worker2)
mQ = fn726
nL = "There are no items available for sale!"
nI = fns.fn112
ns = fns.fn65
ni = fn829
task.spawn(function()
    local SystemPanel = LocalPlayer.PlayerGui:WaitForChild("SystemPanel", 60)
    if not SystemPanel then
        return
    end
    local Main = SystemPanel:WaitForChild("Main", 30)
    local rV_1 = Main and Main:WaitForChild("Red", 30)
    if not rV_1 then
        return
    end
    rV_1.ChildAdded:Connect(function(ew)
        if not nO("HideNoSellNotify") then
            return
        end
        task.defer(function()
            ns(ew)
        end)
    end)
    if nO("HideNoSellNotify") then
        ni()
    end
end)
if Toggles.HideNoSellNotify then
    Toggles.HideNoSellNotify:OnChanged(function()
        if nO("HideNoSellNotify") then
            ni()
        end
    end)
end
CurrentCamera, nE, nD, connection2, connection3, connection, n_, nj, nM, nq, n4, nb, nf, nm, nW, ng, m_, nJ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
nj = fn923
nM = function()
    if not nj() then
        return
    end
    if (m3.AutoSellMode and m3.AutoSellMode.Value or "Sell All") == "Sell All" then
        pcall(function()
            GameMgr:SellAllItem()
        end)
        return
    end
    local r8_2 = nC()
    if not r8_2 or not r8_2.bag then
        return
    end
    local r9_2 = {}
    local sa = r8_2.bag.count or 0
    local sf = 1
    while sf <= sa do
        local sg = sf
        local sa_1 = r8_2.bag[sg]
        if sa_1 and sa_1.id then
            local sb_1 = nG(sa_1.id)
            local sa_2 = sb_1 and sb_1.type == "Fish" and sb_1.canSell ~= false and mQ(sb_1.quality)
            if sa_2 then
                r9_2[#r9_2 + 1] = sg
            end
        end
        sf += 1
    end
    table.sort(r9_2, function(fa, fb)
        return fa > fb
    end)
    for i, v in ipairs(r9_2) do
        local sn = v
        local r8_3 = nh.Unloaded or not nO("AutoSell")
        if r8_3 then
            break
        end
        pcall(function()
            GameMgr:SellItem(sn)
        end)
        task.wait(0.15)
    end
end
task.spawn(autoSellDelayLoop)
nq = function(fq, fr)
    local sr
    local sv_1
    local su_1
    local ss = nV()
    if not ss then
        return
    end
    local st = m8()
    sr, su_1, sv_1 = nil, -1, nil
    for k, v in ss do
        local ss_1 = tonumber(k)
        local sw = tonumber(v)
        local sx = ss_1 and sw and sw <= st and not nn(ss_1)
        if sx then
            local sx_1 = nG(ss_1)
            if sx_1 and sx_1.type == fq then
                local sy_1 = fr(sx_1)
                if sy_1 > su_1 or sy_1 == su_1 and sw < (sv_1 or math.huge) then
                    sr = ss_1
                    su_1 = sy_1
                    sv_1 = sw
                end
            end
        end
    end
    if not sr then
        return
    end
    pcall(function()
        GameMgr:BuyUnLockItem(sr)
    end)
    if nO("AutoEquipBought") then
        task.wait(0.35)
        pcall(function()
            GameMgr:EquipWeapon(sr)
        end)
    end
end
task.spawn(worker3)
n4 = function()
    local sJ
    local sO_1
    local sK = DataMgr:GetPlayerBaseData("weaponInv")
    if not sK then
        return
    end
    local sM = m3.AutoUpgradeTarget and m3.AutoUpgradeTarget.Value
    local sV = if sM then 1 else 0
    local sT = 420 * sV + 3873 * (1 - sV)
    local sU = 1655 * sV + 1002 * (1 - sV)
    if not ((sT * 3288 + sU * 2549 + sT * sU) % 16777213 == 6294655) then
        sM = "Both"
    end
    local sL_1 = sM
    local sN = m3.AutoUpgradeMaxLevel and m3.AutoUpgradeMaxLevel.Value or 10
    local sN_1 = m8()
    sJ, sO_1 = nil, math.huge
    for k, v in sK do
        local sK_1 = (tonumber(k))
        if not sK_1 then
            local sP_1 = type(v) == "table" and v.id
            sK_1 = sP_1
        end
        local sP_2 = sK_1
        local sK_2 = type(v) == "table" and tonumber(v.exp)
        local sQ = sK_2 or nil
        local sK_3 = sP_2
        if sK_3 then
            sK_3 = sQ
        end
        if sK_3 then
            sK_3 = sQ < sN
        end
        if sK_3 then
            local sK_4 = nG(sP_2)
            if sK_4 then
                if sL_1 == "Both" or sK_4.type == sL_1 then
                    local sK_6 = mW(sP_2, sQ)
                    if sK_6 <= sN_1 and sK_6 < sO_1 then
                        sJ = sP_2
                        sO_1 = sK_6
                    end
                end
            end
        end
    end
    if sJ then
        pcall(function()
            GameMgr:UpgradeWeapon(sJ)
        end)
    end
end
if ((CurrentCamera and not connection3 or (nb or nb)) and (CurrentCamera and not connection2 or (not connection3 or connection3)) or ((nJ or connection3) and (not nJ and nb) or (nJ and not nb or (not nb or not connection2)))) and (connection2 and CurrentCamera and (not CurrentCamera or not connection2) and (not CurrentCamera and not connection2 and (connection2 and not nJ)) or (connection2 and not nJ or connection3 and nJ or CurrentCamera and not connection3 and (not connection2 and CurrentCamera))) or not (((CurrentCamera and not connection3 or (nb or nb)) and (CurrentCamera and not connection2 or (not connection3 or connection3)) or ((nJ or connection3) and (not nJ and nb) or (nJ and not nb or (not nb or not connection2)))) and (connection2 and CurrentCamera and (not CurrentCamera or not connection2) and (not CurrentCamera and not connection2 and (connection2 and not nJ)) or (connection2 and not nJ or connection3 and nJ or CurrentCamera and not connection3 and (not connection2 and CurrentCamera)))) then
    task.spawn(fns.worker4)
    vA_9 = ou.Player:AddLeftGroupbox("Movement", "footprints")
    vA_9:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    vA_9:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    vA_9:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    vA_9:AddToggle("NoClip", { Text = "NoClip", Default = false })
    vA_9:AddToggle("FreezePlayer", { Text = "Freeze Player", Default = false })
    vA_9:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    vA_1 = ou.Player:AddRightGroupbox("Fly", "feather")
    vA_1:AddToggle("Fly", { Text = "Fly", Default = false })
    vA_1:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    CurrentCamera = workspace.CurrentCamera
else
    task.spawn(fns.worker4)
    vA_1 = CurrentCamera.Player:AddLeftGroupbox("Movement", "footprints")
    vA_1:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    vA_1:AddSlider("WalkSpeed", { Min = 16, Default = 32, Max = 250, Text = "WalkSpeed Amount", Rounding = 0 })
    vA_1:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    vA_1:AddToggle("NoClip", { Text = "NoClip", Default = false })
    vA_1:AddToggle("FreezePlayer", { Text = "Freeze Player", Default = false })
    vA_1:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    ou = CurrentCamera.Player:AddRightGroupbox("Fly", "feather")
    ou:AddToggle("Fly", { Text = "Fly", Default = false })
    ou:AddSlider("FlySpeed", { Max = 400, Min = 10, Text = "Fly Speed", Rounding = 0, Default = 60 })
end
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
RunService.RenderStepped:Connect(onRenderStepped)
nb = fn939
Toggles.FreezePlayer:OnChanged(fn860)
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
Toggles.Fly:OnChanged(fn861)
Toggles.WalkSpeedEnabled:OnChanged(fn919)
nf = function(hr)
    pcall(function()
        nK:SetGameplayPausedNotificationEnabled(not hr)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = nH:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not hr
        end
    end)
    if not hr then
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
Toggles.AntiGameplayPause:OnChanged(fn369)
task.spawn(antiGameplayPauseLoop)
vA_3 = ou.Settings:AddLeftGroupbox("Menu")
vA_3:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
nh.ToggleKeybind = m3.MenuKeybind
nE = tick()
nD = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local tU = v
        pcall(function()
            tU:Disable()
        end)
    end
end)
nm = fn529
connection2 = UserInputService.InputBegan:Connect(onInputBegan)
connection3 = UserInputService.InputChanged:Connect(onInputChanged)
vA_3:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
vA_16 = ou.Settings:AddRightGroupbox("Performance", "gauge")
vA_16:AddToggle("FpsBoost", { Text = "FPS Boost", Default = false })
connection = nil
n_ = setmetatable({}, { __mode = "k" })
nW = function(h1, h2, h3)
    local t1_1
    local t0_1
    local t_ = n_[h1]
    if not t_ then
        t_ = {}
        n_[h1] = t_
    end
    if t_[h2] == nil then
        t0_1, t1_1 = pcall(function()
            return h1[h2]
        end)
        if not t0_1 then
            return
        end
        t_[h2] = t1_1
    end
    pcall(function()
        h1[h2] = h3
    end)
end
ng = fn696
if (connection or nm) and (false and not nm) and (nm and false and (not nm or not nm)) or nq and nq and (not CurrentCamera or nm) and ((not CurrentCamera or connection) and (nq and nq)) or ((nq or connection) and (nq and not CurrentCamera) or not connection and not CurrentCamera and (nq and nm) or (not connection or not connection or not connection and CurrentCamera) and (connection and not connection or (CurrentCamera or not connection))) or not ((connection or nm) and (false and not nm) and (nm and false and (not nm or not nm)) or nq and nq and (not CurrentCamera or nm) and ((not CurrentCamera or connection) and (nq and nq)) or ((nq or connection) and (nq and not CurrentCamera) or not connection and not CurrentCamera and (nq and nm) or (not connection or not connection or not connection and CurrentCamera) and (connection and not connection or (CurrentCamera or not connection)))) then
    m_ = function()
        if connection then
            connection:Disconnect()
            connection = nil
        end
        for k, v in n_ do
            local uc = k
            for k, v in v do
                local ui = k
                local uk = v
                pcall(function()
                    uc[ui] = uk
                end)
            end
        end
        table.clear(n_)
    end
    nJ = fn187
else
    nJ = function()
        if connection then
            connection:Disconnect()
            connection = nil
        end
        for k, v in n_ do
            local uc = k
            for k, v in v do
                local ui = k
                local uk = v
                pcall(function()
                    uc[ui] = uk
                end)
            end
        end
        table.clear(n_)
    end
    m_ = fn187
end
Toggles.FpsBoost:OnChanged(fn248)
if Toggles.FpsBoost.Value then
    nJ(true)
end
nv, m4, mV, nt = nil, nil, nil, nil
vA_3:AddButton("Unload", onUnload)
task.spawn(antiAfkLoop)
nh:OnUnload(fn737)
vA_7:SetLibrary(nh)
vA_7:SetFolder("TempoHub")
vA_7:SaveDefault("Evil Hello Kitty")
vA_7:ApplyToTab(ou.Settings)
vA_7:LoadDefault()
na:SetLibrary(nh)
na:IgnoreThemeSettings()
na:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
na:SetFolder("TempoHub/Reeled")
vA_1 = na:BuildConfigSection(ou.Settings)
nv = fn754
m4 = fn537
mV = fn224
nt = function(jo)
    local va
    va = nil
    local vb = type(jo) ~= "table" or type(jo.idx) ~= "string"
    local vf = if vb then 1 else 0
    local vd = 3803 * vf + 656 * (1 - vf)
    local ve = 138 * vf + 2646 * (1 - vf)
    if not ((vd * 1096 + ve * 192 + vd * ve) % 16777213 == 4719398) then
        vb = type(jo.type) ~= "string"
    end
    if not vb then
        vb = na.Ignore[jo.idx]
    end
    if vb then
        return false
    end
    va = nv(jo.type, jo.idx)
    if not va then
        return false
    end
    local vb_1 = pcall(function()
        if jo.type == "Input" then
            if type(jo.text) ~= "string" then
                return
            end
            va:SetValue(jo.text)
        elseif jo.type == "ColorPicker" then
            va:SetValueRGB(Color3.fromHex(jo.value), jo.transparency)
        elseif jo.type == "KeyPicker" then
            va:SetValue({ jo.key, jo.mode, jo.modifiers })
            if jo.mode == "Toggle" and jo.toggled ~= nil then
                va.Toggled = jo.toggled
                va:Update()
            end
        else
            va:SetValue(jo.value)
        end
    end)
    return vb_1
end
vA_1:AddDivider()
vA_1:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
vA_1:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
vA_1:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
na:LoadAutoloadConfig()
end)(...)

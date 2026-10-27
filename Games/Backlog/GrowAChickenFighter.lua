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
getgenv().TempoHoodSubtitle = "GROW A CHICKEN FIGHTER"
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
local xI_1, xI_3, xI_7, xI_9, xI_10, xI_11, FaqGroup, xI_18, xI_19, xI_20, xI_21, SocialsGroup, xI_27, xI_29, xI_30, xI_31
local oh
local o1
local nZ
local oJ
local pq
local oo
local o7
local ChickenMode
local oP
local nM
local ow
local UserInputService
local oa
local oV
local nS
local oC
local pj
local og
local o0
local nY
local oI
local pp
local on
local Workspace
local n3
local oO
local nL
local ov
local pc
local client
local oU
local nR
local oB
local maxSlots
local of
local o_
local nX
local oH
local po
local om
local o5
local n2
local oN
local radius
local ou
local pb
local n8
local oT
local nQ
local oA
local ph
local Label
local connection
local nW
local connection2
local pn
local ol
local o4
local CurrentCamera2
local oM
local FusionRules
local pa
local n7
local oS
local nP
local oz
local pg
local od
local oY
local nV
local oF
local maxLevel
local oj
local o3
local n0
local oL
local connection3
local o9
local n6
local oR
local nO
local oy
local pf
local oc
local oX
local nU
local oE
local pl
local oi
local LocalPlayer
local n_
local oK
local pr
local op
local VirtualUser
local n5
local oQ
local nN
local ox
local pe
local ob
local oW
local nT
local oD
local pk
function fns.onUnload()
    o9:Unload()
end
function fns.fn55()
    local qS_1
    local qQ = client:get({ "money" })
    if type(qQ) == "number" then
        return qQ
    end
    local qR = type(qQ) == "table" and type(qQ.toNumber) == "function"
    local qR_1
    if qR then
        qR_1, qS_1 = pcall(qQ.toNumber, qQ)
        local qQ_1 = qR_1 and type(qS_1) == "number"
        if qQ_1 then
            return qS_1
        end
        return 0
    end
    return 0
end
function fns.fn57(ag)
    local qa = o_[ag]
    return qa ~= nil and qa.Value == true
end
function fns.fn80(bq, br)
    local q2 = Workspace:FindFirstChild(bq)
    local q3 = nR()
    if not q2 or q3 == nil then
        return nil
    end
    return q2:FindFirstChild(br .. tostring(q3))
end
function fns.fn85(cD)
    local r6_1
    local r5_1
    local r4_1
    r6_1, r5_1, r4_1 = nil, nil, nil
    local r7 = #cD
    local sg = 1
    while sg <= r7 do
        local si = sg
        local r7_1 = cD[si]
        local r8 = si + 1
        local r9 = #cD
        local sl = r8
        while sl <= r9 do
            local r8_1 = cD[sl]
            local r9_1 = FusionRules.cost(r7_1, r8_1)
            if nM() >= r9_1 then
                local r9_2 = 0
                if r7_1.typeId == r8_1.typeId then
                    r9_2 += 100
                end
                if r7_1.rarity == r8_1.rarity then
                    r9_2 += 50
                end
                r9_2 += nO(r7_1.rarity) + nO(r8_1.rarity)
                local abs = math.abs
                local sb = r7_1.level or 1
                local sc = r8_1.level or 1
                r9_2 -= abs(sb - sc)
                if r4_1 == nil or r9_2 > r4_1 then
                    r6_1, r5_1, r4_1 = r7_1, r8_1, r9_2
                end
            end
            sl += 1
        end
        sg += 1
    end
    return r6_1, r5_1
end
function fns.fn115()
    return client:get({ "tower" })
end
function fns.fn135(aN)
    local qz = oW()
    local qA = oH()
    local qC = not qz or not qA
    local qB_1 = not aN
    local qD = qC
    local qH = if qD then 1 else 0
    local qF = 75 * qH + 1710 * (1 - qH)
    local qG = 753 * qH + 619 * (1 - qH)
    if not ((qF * 464 + qG * 428 + qF * qG) % 16777213 == 413559) then
        qD = qB_1
    end
    if qD then
        return false
    end
    if qz.Anchored then
        qz.Anchored = false
    end
    qA.WalkSpeed = nL()
    qA:MoveTo(Vector3.new(aN.X, qz.Position.Y, aN.Z))
    return true
end
function fns.fn150(gU, gV)
    local vc = type(gU) ~= "table"
    local vk = if vc then 1 else 0
    local vi = 664 * vk + 3727 * (1 - vk)
    local vj = 1730 * vk + 3967 * (1 - vk)
    if not ((vi * 4013 + vj * 56 + vi * vj) % 16777213 == 3910232) then
        vc = typeof(gU.at) ~= "Vector3"
    end
    if vc then
        return
    end
    local insert = table.insert
    local at = gU.at
    local ve = os.clock()
    local vf = tonumber(gU.fall) or 0
    local vg = ve + vf
    local ve_1 = tonumber(gU.radius) or gV
    insert(n0, { pos = at, impactAt = vg, radius = ve_1 })
end
function fns.fn153(X, Y, Z)
    return string.format("<b>%s</b> %s %s", X, on("-", "#5a6070"), on(Y, Z))
end
function fns.fn186()
    local vz = os.clock()
    local vG = #n0
    local vF = -1
    while false and vG <= 1 or true and vG >= 1 do
        local vH = vG
        if n0[vH].impactAt < vz - 0.3 then
            table.remove(n0, vH)
        end
        vG += vF
    end
    local HotEgg = Workspace:FindFirstChild("HotEgg")
    local vB = not HotEgg
    local vL = if vB then 1 else 0
    local vJ = 89 * vL + 2525 * (1 - vL)
    local vK = 1192 * vL + 3232 * (1 - vL)
    if not ((vJ * 379 + vK * 51 + vJ * vK) % 16777213 == 200611) then
        vB = not HotEgg:IsA("BasePart")
    end
    if vB then
        return
    end
    local vB_1 = oW()
    if not vB_1 then
        return
    end
    local vC = pj(vB_1.Position, vz)
    if vC then
        local vz_1 = Vector3.new(vB_1.Position.X - vC.pos.X, 0, vB_1.Position.Z - vC.pos.Z)
        if vz_1.Magnitude < 0.1 then
            vz_1 = Vector3.new(1, 0, 0)
        end
        od(vB_1.Position + vz_1.Unit * (vC.radius + 6), 60)
        return
    end
    if HotEgg:GetAttribute("Carrier") ~= LocalPlayer.UserId then
        od(HotEgg.Position, 60)
    end
end
function fns.fn188()
    return UserInputService:GetFocusedTextBox() ~= nil
end
function fns.fn196()
    return n7() >= og.requirementFloor(oi())
end
function fns.fn201()
    if not o1() then
        return nil
    end
    local uZ = n7()
    local u_ = uZ + 1
    local u0 = client:get({ "purchases" })
    local u1 = type(u0) == "table" and u0.passes
    local u1_1 = type(u1) == "table" and u1.elevatorVip == true
    local u1_2 = {
        restricted = true,
        prices = {},
        owned = { elevatorVip = u1_1 },
        towerBest = uZ,
        rewardFloor = uZ,
        boosts = { money = 0, corn = 0 }
    }
    local uZ_1 = nZ.elevatorCost(u1_2, u_)
    local u5 = if nM() < uZ_1 then 1 else 0
    if u5 == 1 then
        return nil, uZ_1
    end
    return u_, uZ_1
end
function fns.fn225()
    local q_ = ow()
    return q_ and q_.best or 0
end
function fns.fn228()
    if not o_.Fly.Value then
        local wR = oH()
        if wR then
            wR.PlatformStand = false
        end
    end
end
function fns.fn229()
    return pr("Recyclers", "Recycler")
end
function fns.fn255(bR)
    local eggLadder = oc.roster.eggLadder
    if type(eggLadder) == "table" then
        for i, v in ipairs(eggLadder) do
            if v.tier == bR then
                return 1000 + i
            end
        end
    end
    return 0
end
function fns.fn258()
    local q7 = o0()
    local q8 = {}
    local q9 = type(q7) ~= "table" or type(q7.chickens) ~= "table"
    if q9 then
        return q8
    end
    for k, v in pairs(q7.chickens) do
        local q7_1 = type(v) == "table" and v.id
        if q7_1 then
            table.insert(q8, v)
        end
    end
    return q8
end
function fns.worker5()
    while not o9.Unloaded do
        task.wait(0.12)
        local xx = nU() or nV()
        if xx then
            o7()
        else
            local xx_1 = pe("AutoGrabScraps")
            local xy = pe("AutoRecycleScrap")
            if xx_1 then
                pcall(oN)
            end
            if xy then
                pcall(pg)
            end
            local xz = not xy
            local xA = not xx_1
            if xA ~= false then
                xA = xz
            end
            if xA then
                o7()
            end
        end
        if pe("AutoUpgradeRecycler") then
            pcall(of)
        end
    end
end
function fns.fn272()
    local attr = LocalPlayer:GetAttribute("scrapCarry")
    local rJ = type(attr) == "number" and attr > 0
    local rK = attr == true
    local rK_1
    local rL = rJ or rK
    local rL_1
    local rJ_1 = rL
    if rJ_1 then
        local rI_2 = (pe("AutoGrabScraps"))
        local rQ = if rI_2 then 1 else 0
        local rO = 3096 * rQ + 4042 * (1 - rQ)
        local rP = 624 * rQ + 1476 * (1 - rQ)
        if not ((rO * 1406 + rP * 89 + rO * rP) % 16777213 == 6340416) then
            rI_2 = pe("AutoRecycleScrap")
        end
        rJ_1 = rI_2
    end
    if rJ_1 then
        return false
    end
    local NestEggs = Workspace:FindFirstChild("NestEggs")
    if not NestEggs then
        return false
    end
    local rJ_2 = oW()
    if not rJ_2 then
        return false
    end
    rL_1, rK_1 = nil, nil
    for i, child in ipairs(NestEggs:GetChildren()) do
        local rI_4 = child:IsA("BasePart") and child:GetAttribute("owner") == LocalPlayer.UserId
        if rI_4 then
            local Magnitude = (child.Position - rJ_2.Position).Magnitude
            if rK_1 == nil or Magnitude < rK_1 then
                rL_1, rK_1 = child, Magnitude
            end
        end
    end
    if rL_1 == nil then
        return false
    end
    if rK_1 > 6 then
        oh(rL_1.Position)
    end
    return true
end
function fns.fn274()
    return LocalPlayer:GetAttribute("Plot")
end
function fns.onRscripts()
    if setclipboard then
        setclipboard(oF)
    elseif toclipboard then
        toclipboard(oF)
    end
    o9:Notify("Copied Rscripts profile to clipboard")
end
function fns.worker3()
    while not o9.Unloaded do
        task.wait(2)
        if pe("AntiAfk") then
            local xp = tick() - n3
            local xq = tick() - n_
            if xp >= 300 and xq >= 60 then
                pcall(pl)
            else
                if xp < 300 and xq >= 300 then
                    pcall(pl)
                end
            end
        end
    end
end
function fns.fn339()
    oQ(oJ, "Copied Discord invite to clipboard")
end
function fns.fn352()
    local sF_1
    local PitScrap = Workspace:FindFirstChild("PitScrap")
    local sC = oW()
    local sD = not sC
    local sD_1
    local sE = not PitScrap or sD
    local sE_1
    if sE then
        return nil
    end
    sF_1, sE_1, sD_1 = nil, nil, nil
    for i, child in ipairs(PitScrap:GetChildren()) do
        local sB_1 = child:IsA("BasePart") and child.Name == "Loose" and pa(child)
        if sB_1 then
            local sB_2 = child.Position - sC.Position
            local Magnitude2 = sB_2.Magnitude
            local Magnitude = Vector3.new(sB_2.X, 0, sB_2.Z).Magnitude
            local sI = Magnitude + math.max(0, sB_2.Y) * 0.35
            if sD_1 == nil or sI < sD_1 then
                sF_1, sE_1, sD_1 = child, Magnitude2, sI
            end
        end
    end
    return sF_1, sE_1
end
function fns.fn365()
    local uy = oT()
    if type(uy) ~= "table" then
        return
    end
    local uz = n2()
    if uz ~= "Max" and n6 then
        return
    end
    local uA_1 = 0
    while true do
        local uy_1 = oT()
        if type(uy_1) ~= "table" then
            break
        end
        local uC = uy_1.generators or {}
        local uB_1 = 0
        if type(uC) == "table" then
            for k in pairs(uC) do
                uB_1 += 1
            end
        end
        if not ox.canBuyGenerator(uy_1.slots, uB_1) then
            return
        end
        local uC_1 = ox.buyGeneratorCost(uB_1)
        if nM() < uC_1 then
            return
        end
        oB.invoke(nX.BuyGenerator, uB_1 + 1)
        uA_1 += 1
        if uz ~= "Max" then
            n6 = true
            return
        end
        if uA_1 >= maxSlots then
            return
        end
        task.wait(0.05)
    end
    return
end
function fns.fn366()
    local uS = oc.premium and oc.premium.elevator
    local uS_1 = type(uS) ~= "table" or uS.enabled ~= true
    if uS_1 then
        return false
    end
    local uS_2 = client:get({ "chicken" })
    local uU = uS_2 and tonumber(uS_2.level)
    if (uU or 0) < 2 then
        return false
    end
    local uS_4 = n7()
    return uS_4 >= (uS.minFloor or 2) + 1
end
function fns.fn367()
    local wd_1
    local wc_1
    if identifyexecutor then
        wd_1, wc_1 = identifyexecutor()
        local we = wd_1 ~= ""
        local wf = type(wd_1) == "string" and we
        if wf then
            local we_1 = type(wc_1) == "string" and wc_1 ~= "" and wd_1 .. " " .. wc_1
            oL = we_1 or wd_1
        end
    end
end
function fns.fn393()
    if not o3() then
        return
    end
    if pp() > 0 then
        return
    end
    local tg = ChickenMode.where() == "campaign" or ChickenMode.order() == "tower"
    if tg then
        pcall(function()
            oB.invoke(nX.TowerSurrender)
        end)
        oI("coop")
        return
    end
    local tg_1 = ChickenMode.order() ~= "coop" or ChickenMode.where() ~= "corral"
    if tg_1 then
        oI("coop")
        return
    end
    local tg_2 = oB.invoke(nX.Rebirth)
    local th = type(tg_2) == "table" and tg_2.ok == true
    if th then
        oI("chaos")
    end
end
function fns.fn419()
    if nV() then
        o7()
        return
    end
    local s8 = pp()
    if s8 <= 0 then
        return
    end
    if s8 < pq() then
        return
    end
    local s8_1 = oY()
    local s9 = o5(s8_1)
    if s9 == nil then
        return
    end
    local s8_2 = oW()
    if s8_2 == nil then
        return
    end
    if (s8_2.Position - s9).Magnitude > radius * 0.35 then
        oK(s9)
        return
    end
    o7()
end
function fns.onJumpRequest()
    if o9.Unloaded then
        return
    end
    if pe("InfJump") then
        local w8 = oH()
        if w8 then
            w8:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
function fns.fn435()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local vU = PlayerGui and PlayerGui:FindFirstChild("TowerContinue")
    local vU_1 = not vU
    local vZ = if vU_1 then 1 else 0
    local vX = 1751 * vZ + 729 * (1 - vZ)
    local vY = 2569 * vZ + 872 * (1 - vZ)
    if not ((vX * 1667 + vY * 977 + vX * vY) % 16777213 == 9927149) then
        vU_1 = not vU:IsA("ScreenGui")
    end
    if not vU_1 then
        vU_1 = not vU.Enabled
    end
    if vU_1 then
        return false
    end
    for i, descendant in ipairs(vU:GetDescendants()) do
        local vT_2 = descendant:IsA("TextLabel") or descendant:IsA("TextButton")
        if vT_2 then
            local lower = string.lower
            local vU_2 = descendant.Text or ""
            local vV = lower(vU_2)
            local vT_4 = string.find(vV, "no thanks", 1, true) or string.find(vV, "keep climbing", 1, true)
            if vT_4 then
                return true
            end
        end
    end
    return false
end
function fns.fn449()
    if not o_.WalkSpeedEnabled.Value then
        local wT = oH()
        if wT then
            wT.WalkSpeed = 16
        end
    end
end
function fns.fn453()
    local qU = oE()
    if type(qU) == "table" then
        return qU.count or 0
    elseif type(qU) == "number" then
        return qU
    else
        return 0
    end
end
function fns.fn469()
    if nU() then
        return
    end
    local u6 = pe("AutoRebirth") and o3()
    if u6 then
        return
    end
    local u6_1 = oP()
    local u7 = u6_1 and u6_1:GetAttribute("PV_InBattle") == true
    if u7 then
        return
    end
    local u6_2 = ChickenMode.order() == "tower" and ChickenMode.where() == "campaign"
    if u6_2 then
        return
    end
    if not o1() then
        ChickenMode.order("tower")
        oB.invoke(nX.TowerStart)
        return
    end
    local u6_3 = ol()
    if not u6_3 then
        return
    end
    ChickenMode.order("tower")
    oB.invoke(nX.TowerElevator, u6_3)
    oB.invoke(nX.TowerStart)
end
function fns.fn482(du)
    if du == nil then
        return nil
    end
    local attr = du:GetAttribute("Origin")
    local front = oc.scrap.recycler.edge.front
    if typeof(attr) == "CFrame" then
        return (attr * CFrame.new(0, 3, -front)).Position
    end
    return du:GetPivot().Position + Vector3.new(0, 3, 0)
end
function fns.fn492()
    local tW = pe("AutoRebirth") and o3()
    if tW then
        return
    end
    if ChickenMode.order() == "chaos" then
        return
    end
    oI("chaos")
end
function fns.fn495()
    return LocalPlayer:WaitForChild("PlayerGui")
end
function fns.fn503()
    o7()
    connection:Disconnect()
    connection2:Disconnect()
    connection3:Disconnect()
    for k in pairs(oC) do
        if k.Parent then
            k.CanCollide = true
        end
    end
    ou(false)
    local xi = oH()
    if xi then
        xi.PlatformStand = false
    end
end
function fns.fn505()
    local Character = LocalPlayer.Character
    local qe = Character and Character:FindFirstChild("HumanoidRootPart")
    return qe
end
function fns.fn510(c1)
    local attr = c1:GetAttribute("PickupAt")
    local sw = typeof(attr) == "number" and attr > Workspace:GetServerTimeNow()
    if sw then
        return false
    end
    return true
end
function fns.fn532()
    oB.onClient(nX.HotEggMeteor, function(iy)
        nY(iy, oc.worldEvents.defs.hotEgg.meteors.startRadius)
    end)
    oB.onClient(nX.HotEggEntrance, function(iD)
        nY(iD, oc.worldEvents.defs.hotEgg.meteors.endRadius)
    end)
end
function fns.fn535()
    ou(o_.AntiGameplayPause.Value)
end
function fns.onRenderStepped(jI)
    if o9.Unloaded then
        return
    end
    local xa = pe("AutoGrabScraps") or pe("AutoRecycleScrap")
    local xb = xa and not nU() and not nV()
    if xb then
        local xa_1 = oH()
        if xa_1 then
            xa_1.WalkSpeed = nL()
        end
    elseif pe("WalkSpeedEnabled") then
        local xa_2 = oH()
        if xa_2 then
            xa_2.WalkSpeed = oV.WalkSpeed.Value
        end
    end
    if pe("Fly") then
        local xa_3 = oW()
        local xb_1 = oH()
        if xa_3 and xb_1 then
            xb_1.PlatformStand = true
            local xb_2 = Vector3.zero
            local xc_1 = Workspace.CurrentCamera or CurrentCamera2
            local xh = if UserInputService:IsKeyDown(Enum.KeyCode.W) then 1 else 0
            if xh == 1 then
                xb_2 = xb_2 + xc_1.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                xb_2 = xb_2 - xc_1.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                xb_2 = xb_2 - xc_1.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                xb_2 = xb_2 + xc_1.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                xb_2 = xb_2 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                xb_2 = xb_2 - Vector3.new(0, 1, 0)
            end
            xa_3.AssemblyLinearVelocity = Vector3.zero
            if xb_2.Magnitude > 0 then
                xa_3.CFrame = xa_3.CFrame + xb_2.Unit * oV.FlySpeed.Value * jI
            end
        end
    end
end
function fns.worker6()
    while not o9.Unloaded do
        task.wait(0.5)
        if pe("AutoRebirth") then
            pcall(oO)
        end
        if pe("AutoUpgradeCoop") then
            pcall(ov)
        end
        if pe("AutoUpgradeFeeder") then
            pcall(pb)
        end
        if pe("AutoBuyFeeders") then
            pcall(pc)
        end
    end
end
function fns.fn576()
    local ScrapWalkSpeed = oV.ScrapWalkSpeed
    local qq_1 = ScrapWalkSpeed and ScrapWalkSpeed.Value or 16
    return math.max(1, qq_1)
end
function fns.fn581()
    return client:get({ "rebirth" })
end
function fns.fn600()
    local wb = if not oA() then 1 else 0
    if wb == 1 then
        return
    end
    oB.fire(nX.TowerContinueDecline)
end
function fns.fn615()
    local tc = oM()
    local td_1 = tc and tc.recyclerLevel or 0
    local tc_2 = oi()
    local te = n7()
    if not om.canUpgrade(td_1, tc_2) then
        return
    end
    if not om.floorUnlocked(td_1, te) then
        return
    end
    local tc_3 = om.upgradeCost(td_1)
    if nM() >= tc_3 then
        oB.invoke(nX.UpgradeRecycler)
    end
end
function fns.fn648(hP)
    local DiscordGroup = hP:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = oD })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = oD })
end
function fns.onInputBegan()
    n3 = tick()
end
function fns.onStepped()
    if o9.Unloaded then
        return
    end
    local Character = LocalPlayer.Character
    local wW = pe("NoClip")
    if wW and Character then
        for i, descendant in ipairs(Character:GetDescendants()) do
            local wV_1 = descendant:IsA("BasePart") and descendant.CanCollide
            if wV_1 then
                oC[descendant] = true
                descendant.CanCollide = false
            end
        end
        oy = true
    elseif oy then
        for k in pairs(oC) do
            if k.Parent then
                k.CanCollide = true
            end
        end
        oC = {}
        oy = false
    end
end
local function fn670()
    local ub = oT()
    local uc = type(ub) ~= "table" or type(ub.generators) ~= "table"
    if uc then
        return
    end
    local uc_1 = nW()
    for i, v in ipairs(ub.generators) do
        local ub_1 = tonumber(v.slot)
        local ud = tonumber(v.level)
        local ue = ub_1 and ud and ud < uc_1 and ox.canUpgrade(ud)
        if ue then
            local ue_1 = ox.upgradeCost(ud)
            if nM() >= ue_1 then
                oB.invoke(nX.UpgradeGenerator, ub_1)
                return
            end
        end
    end
end
local function fn700()
    if not nU() then
        return
    end
    local tY = pe("AutoRebirth") and o3()
    if tY then
        return
    end
    if ChickenMode.order() ~= "chaos" then
        oI("chaos")
    end
end
local function fn728(bB)
    ChickenMode.order(bB)
    oB.fire(nX.SetChickenOrder, bB)
end
local function fn732()
    local rv = o0()
    local rw = rv and rv.eggs
    local rv_1 = {}
    if type(rw) ~= "table" then
        return rv_1
    end
    for k, v in pairs(rw) do
        local rw_1 = tonumber(v) or 0
        if rw_1 > 0 then
            table.insert(rv_1, { tier = k, count = rw_1, priority = ph(k) })
        end
    end
    table.sort(rv_1, function(b5, b6)
        if b5.priority == b6.priority then
            return b5.count > b6.count
        end
        return b5.priority > b6.priority
    end)
    return rv_1
end
local function worker8()
    while not o9.Unloaded do
        task.wait(0.1)
        if pe("AutoHotEgg") then
            pcall(oz)
        end
        if pe("AutoGooseCoins") then
            pcall(pf)
        end
    end
end
local function worker7()
    while not o9.Unloaded do
        task.wait(1)
        pcall(oX)
        if pe("AutoStartTower") then
            pcall(n8)
        end
        if pe("AutoStartFrontier") then
            pcall(o4)
        end
        if pe("AutoNoThanks") then
            pcall(nQ)
        end
        if pe("AutoStartChaos") then
            pcall(pk)
        end
    end
end
local function fn770(aU, aV)
    local qI = oW()
    local qJ = qI and qI.Parent and qI.Parent:FindFirstChildOfClass("Humanoid")
    if not qJ or not aU then
        return false
    end
    if aV then
        qJ.WalkSpeed = aV
    end
    qJ:MoveTo(Vector3.new(aU.X, qI.Position.Y, aU.Z))
    return true
end
local function fn780()
    return pr("Coops", "Coop")
end
local function fn814(bO)
    return FusionRules.RANK[bO] or 1
end
local function fn816()
    n5()
    local rX = oU()
    for i, v in ipairs(rX) do
        local rX_1 = math.min(nS, v.count)
        if rX_1 > 0 then
            oB.invoke(nX.HatchEggs, v.tier, rX_1)
            return
        end
    end
end
local function onCopyJoinScript_JobID()
    local wk = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, ob)
    if setclipboard then
        setclipboard(wk)
    elseif toclipboard then
        toclipboard(wk)
    end
    o9:Notify("Copied join script to clipboard")
end
local function fn844()
    local FeederMaxLevel = oV.FeederMaxLevel
    local t8_1 = FeederMaxLevel and FeederMaxLevel.Value or maxLevel
    return math.clamp(math.floor(t8_1), 1, maxLevel)
end
local function fn860(au, av)
    local qj = oW()
    if not qj or not au then
        return false
    end
    if av == nil then
        av = 3
    end
    local qk_1 = CFrame.new(au + Vector3.new(0, av, 0))
    qj.AssemblyLinearVelocity = Vector3.zero
    qj.AssemblyAngularVelocity = Vector3.zero
    qj.CFrame = qk_1
    return true
end
local function fn861()
    n6 = false
end
local function fn888(gZ, g_)
    local vp_1
    local vo_1
    vp_1, vo_1 = nil, nil
    for i, v in ipairs(n0) do
        local vq = v.impactAt - g_
        if vq > -0.15 and vq < 1.1 then
            local vr_1 = Vector3.new(gZ.X - v.pos.X, 0, gZ.Z - v.pos.Z)
            if vr_1.Magnitude < v.radius + 3 then
                if vo_1 == nil or vq < vo_1 then
                    vp_1, vo_1 = v, vq
                end
            end
        end
    end
    return vp_1
end
local function fn889()
    return client:get({ "roster" })
end
local function fn899()
    n6 = false
end
local function fn900()
    return client:get({ "coop" })
end
local function worker2()
    while not o9.Unloaded do
        task.wait(1)
        if pe("AntiGameplayPause") then
            ou(true)
        end
    end
end
local function onInputChanged(i5)
    local UserInputType = i5.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        n3 = tick()
    end
end
local function fn922()
    if Workspace:GetAttribute("EventId") ~= "goldenGoose" then
        return
    end
    local attr = Workspace:GetAttribute("EventPhase")
    if attr ~= "live" and attr ~= "warmup" then
        return
    end
    local Pit = Workspace:FindFirstChild("Pit")
    local vN_1 = Pit and Pit:FindFirstChild("Floor")
    if not vN_1 then
        return
    end
    local vN_2 = oW()
    if not vN_2 then
        return
    end
    local Position = vN_1.Position
    local vM_3 = Vector3.new(vN_2.Position.X - Position.X, 0, vN_2.Position.Z - Position.Z)
    if vM_3.Magnitude > 6 then
        od(Position, 50)
    end
end
local function fn923()
    local BuyFeederAmount = oV.BuyFeederAmount
    local un = BuyFeederAmount and BuyFeederAmount.Value
    if type(un) == "table" then
        if un.Max == true then
            return "Max"
        elseif un["1"] == true then
            return "1"
        else
            for k, v in pairs(un) do
                if v then
                    return tostring(k)
                end
            end
            return "1"
        end
    else
        local un_1 = type(un) == "string" and string.lower(un) == "max"
        if un_1 then
            return "Max"
        end
        return "1"
    end
end
local function fn928()
    local Character = LocalPlayer.Character
    local qh = Character and Character:FindFirstChildOfClass("Humanoid")
    return qh
end
local function fn941(U, V)
    return string.format('<font color="%s">%s</font>', V, U)
end
local function worker4()
    while not o9.Unloaded do
        task.wait(0.35)
        if pe("AutoCollectEgg") then
            pcall(n5)
        end
        if pe("AutoOpenEggs") then
            pcall(oo)
        end
        if pe("AutoFuseChickens") then
            pcall(op)
        end
        if pe("AutoSellChickens") then
            pcall(oR)
        end
    end
end
local function fn973()
    local sq_1
    local sp_1
    if ChickenMode.where() ~= "corral" then
        oI("coop")
    end
    local so = oj()
    if #so < 2 then
        return
    end
    sq_1, sp_1 = po(so)
    if sq_1 == nil or sp_1 == nil then
        return
    end
    oB.invoke(nX.FuseChickens, sq_1.id, sp_1.id, {}, nil, "a")
end
local function fn974()
    local RecycleAtScrap = oV.RecycleAtScrap
    local sQ_1 = RecycleAtScrap and RecycleAtScrap.Value
    local sV = if sQ_1 then 1 else 0
    local sT = 1909 * sV + 3146 * (1 - sV)
    local sU = 2961 * sV + 893 * (1 - sV)
    if not ((sT * 3517 + sU * 837 + sT * sU) % 16777213 == 14844859) then
        sQ_1 = 10
    end
    local sR_1 = sQ_1
    return math.max(1, math.floor(sR_1))
end
local function fn976()
    local tA = o0()
    local tB = type(tA) ~= "table" or type(tA.chickens) ~= "table"
    if tB then
        return
    end
    local activeId = tA.activeId
    local tC = nT()
    local tD = {}
    for k, v in pairs(tA.chickens) do
        local tA_1 = type(v) == "table" and v.id and v.id ~= activeId and v.favorite ~= true and nO(v.rarity) <= tC
        if tA_1 then
            table.insert(tD, v.id)
        end
    end
    if #tD == 0 then
        return
    end
    oB.invoke(nX.SellChickens, tD)
end
local function fn1010()
    return client:get({ "scrap" })
end
local function fn1039()
    local t2 = oT()
    if type(t2) ~= "table" then
        return
    end
    local t7 = if not ox.canExpand(t2.slots) then 1 else 0
    if t7 == 1 then
        return
    end
    local t3 = ox.expandCost(t2.slots)
    if nM() >= t3 then
        oB.invoke(nX.ExpandCoop)
    end
end
local function fn1043()
    local attr2 = Workspace:GetAttribute("EventId")
    local attr = Workspace:GetAttribute("EventPhase")
    if attr ~= "live" and attr ~= "warmup" then
        return false
    end
    return attr2 == "goldenGoose" or attr2 == "hotEgg"
end
local function fn1045()
    if nU() then
        return
    end
    local uM = pe("AutoRebirth") and o3()
    if uM then
        return
    end
    local uM_1 = oP()
    local uN = uM_1 and uM_1:GetAttribute("PV_InBattle") == true
    if uN then
        return
    end
    local uM_2 = ChickenMode.order() == "tower" and ChickenMode.where() == "campaign"
    if uM_2 then
        return
    end
    ChickenMode.order("tower")
    oB.invoke(nX.TowerStart)
end
local function fn1051()
    local qt = oH()
    local qu = oW()
    if qt then
        qt:Move(Vector3.zero, false)
        if qu then
            qt:MoveTo(qu.Position)
        end
    end
    if qu and qu.Anchored then
        qu.Anchored = false
    end
end
local function fn1063()
    oB.onClient(nX.TowerContinueOffer, function(iI)
        local wt = o9.Unloaded or not pe("AutoNoThanks")
        if wt then
            return
        end
        local wt_1 = type(iI) ~= "table" or iI.open ~= true
        if wt_1 then
            return
        end
        if iI.paid == true then
            oB.fire(nX.TowerContinueDecline)
        end
    end)
end
local function worker()
    local wn_1
    while true do
        task.wait(1)
        if o9.Unloaded then
            break
        end
        local wm = math.floor(os.clock() - nN)
        if wm < 60 then
            wn_1 = wm .. "s"
        elseif wm < 3600 then
            wn_1 = string.format("%dm %ds", math.floor((wm) / (60)), wm % 60)
        else
            wn_1 = string.format("%dh %dm", math.floor((wm) / (3600)), math.floor((wm % 3600) / (60)))
        end
        Label:SetText(oa("Session time", wn_1, pn))
    end
end
local function fn1076(N, O)
    if setclipboard then
        setclipboard(N)
    elseif toclipboard then
        toclipboard(N)
    end
    o9:Notify(O)
end
local function fn1081()
    local SellMaxRarity = oV.SellMaxRarity
    local tm_1 = SellMaxRarity and SellMaxRarity.Value or "common"
    if type(tm_1) == "table" then
        local tm_2 = nil
        for k, v in pairs(tm_1) do
            if v then
                local to_1 = nO(k)
                if tm_2 == nil or to_1 > tm_2 then
                    tm_2 = to_1
                end
            end
        end
        return tm_2 or 1
    elseif type(tm_1) == "string" then
        return nO(tm_1)
    else
        return 1
    end
end
local function fn1110()
    local attr = LocalPlayer:GetAttribute("scrapCarry")
    if type(attr) == "number" then
        return attr
    elseif attr == true then
        return 1
    else
        return 0
    end
end
local function fn1143()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    n_ = tick()
end
local function fn1147()
    local s7 = if nV() then 1 else 0
    if s7 == 1 then
        o7()
        return
    end
    local s1 = pp()
    local s1_1
    local s2 = pe("AutoRecycleScrap") and s1 >= pq()
    local s2_1
    if s2 then
        return
    end
    if s1 >= oc.scrap.weight.fullLoad then
        return
    end
    s2_1, s1_1 = oS()
    if s2_1 == nil then
        return
    end
    local s3 = oW()
    if s3 == nil then
        return
    end
    if s1_1 == nil or s1_1 > nP * 0.55 then
        oK(s2_1.Position)
        return
    end
    o7()
end
radius = nil
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
nV = nil
nW = nil
nX = nil
nY = nil
nZ = nil
n_ = nil
n0 = nil
CurrentCamera2 = nil
n2 = nil
n3 = nil
ChickenMode = nil
n5 = nil
n6 = nil
n7 = nil
n8 = nil
client = nil
oa = nil
ob = nil
oc = nil
od = nil
Label = nil
of = nil
og = nil
oh = nil
oi = nil
oj = nil
ol = nil
om = nil
on = nil
oo = nil
op = nil
connection3 = nil
FusionRules = nil
ou = nil
ov = nil
ow = nil
ox = nil
oy = nil
oz = nil
oA = nil
oB = nil
oC = nil
oD = nil
oE = nil
oF = nil
connection2 = nil
oH = nil
oI = nil
oJ = nil
oK = nil
oL = nil
oM = nil
oN = nil
oO = nil
oP = nil
oQ = nil
oR = nil
oS = nil
oT = nil
oU = nil
oV = nil
oW = nil
oX = nil
oY = nil
connection = nil
o_ = nil
o0 = nil
o1 = nil
LocalPlayer = nil
o3 = nil
o4 = nil
o5 = nil
Workspace = nil
o7 = nil
VirtualUser = nil
o9 = nil
pa = nil
pb = nil
pc = nil
UserInputService = nil
pe = nil
pf = nil
pg = nil
ph = nil
maxSlots = nil
pj = nil
pk = nil
pl = nil
maxLevel = nil
pn = nil
po = nil
pp = nil
pq = nil
pr = nil
UserInputService, VirtualUser, Workspace, LocalPlayer = nil, nil, nil, nil
local xI_14 = game:GetService("Players")
local xI_17 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
Workspace = game:GetService("Workspace")
LocalPlayer = xI_14.LocalPlayer
local xI_25 = LocalPlayer:WaitForChild("PlayerScripts")
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
xI_19, oJ, oF, oB, ox, FusionRules, om, og, oc, client, ChickenMode, nZ, nX, nS, nP, radius, maxLevel, maxSlots, xI_3, o9, xI_30, xI_9, o_, oV, xI_7, xI_18, pn, xI_20, xI_29, n6, n0, xI_27, oQ, oD, on, oa, pe, oW, oH, oh, nV, nL, o7, oK, od, nM, o0, oT, oM, oE, ow, oi, n7, nR, pr, oY, oP, oI, oj, nO, ph, oU, n5, oo, po, op, pp, pa, oS, pq, o5, oN, pg, of, o3, oO, nT, oR, nU, pk, oX, ov, nW, pb, n2, pc, n8, o1, ol, o4, nY, pj, oz, pf, oA, nQ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
xI_14 = 226
repeat
    xI_10 = (xI_14 * 35 + 14) % 36 + 1
    if xI_10 <= 18 then
        if xI_10 <= 9 then
            if xI_10 <= 5 then
                if xI_10 <= 3 then
                    if xI_10 <= 2 then
                        if xI_10 <= 1 then
                            if (xI_14 * 2 + 8) * 4 % 3 == ((xI_14 * 2 + 8) * 4 + 4) % 3 then
                                oY = fns.fn366
                            else
                                o1 = fns.fn366
                            end
                            xI_14 = (xI_14 + 107) % 288
                        else
                            xI_31 = { "xiedwfm", "ntqtsd", "prhoi", "vhxtvutgpu", "ncv", "hvazpzzc", "agrwtzlhkfu", "rdsz" }
                            local yZ = xI_14
                            xI_21 = xI_31[yZ % 8 + 1]
                            if xI_21:len() >= xI_21:reverse():rep(yZ % 3 + 2):len() then
                                pj = fns.fn201
                                n0 = fns.fn469
                                nY = {}
                                ol = fns.fn150
                                o4 = fn888
                            else
                                ol = fns.fn201
                                o4 = fns.fn469
                                n0 = {}
                                nY = fns.fn150
                                pj = fn888
                            end
                            xI_14 = (xI_14 + 251) % 288
                        end
                    else
                        if (xI_14 * 1 + 4) * 5 % 4 == ((xI_14 * 1 + 4) * 5 + 8) % 4 then
                            oz = fns.fn186
                            pf = fn922
                        else
                            pf = fns.fn186
                            oz = fn922
                        end
                        xI_14 = (xI_14 + 179) % 288
                    end
                elseif xI_10 <= 4 then
                    if (xI_14 * 2 + 5) * 16 % 3 == ((xI_14 * 2 + 5) * 16 + 0) % 3 then
                        oA = fns.fn435
                        nQ = fns.fn600
                        xI_27 = o9:CreateWindow({
                            Title = "Tempo Hub",
                            Footer = { { Text = oJ, Copyable = true }, "|", xI_19 },
                            Icon = 12645376577,
                            NotifySide = "Right",
                            ShowCustomCursor = false,
                            CornerRadius = 10
                        })
                    else
                        o9 = fns.fn435
                        oJ = fns.fn600
                        xI_19 = nQ:CreateWindow({
                            Icon = 12645376577,
                            CornerRadius = 10,
                            Title = "Tempo Hub",
                            ShowCustomCursor = false,
                            Footer = { { Text = oA, Copyable = true }, xI_27, "|" },
                            NotifySide = "Right"
                        })
                    end
                    xI_14 = (xI_14 + 71) % 288
                else
                    if (xI_14 * 3 + 8) * 9 % 4 == ((xI_14 * 3 + 8) * 9 + 9) % 4 then
                        gethui = fns.fn495
                        nL = "Grow a Chicken Fighter"
                    else
                        gethui = fns.fn495
                        xI_19 = "Grow a Chicken Fighter"
                    end
                    xI_14 = (xI_14 + 215) % 288
                end
            elseif xI_10 <= 7 then
                if xI_10 <= 6 then
                    if ((not pp or oV) and (not oB or oB) or not oV and not oB and (not oV and not oV) or (not oV or pp or not oB and oV) and ((not oB or not oV) and (not oB and not pp))) and (not oV and pp and (not pp and oB) and (not pp and oV and (pp and not oB)) or (oB or not pp or not pp and not oV or (oV and oB or not pp and pp))) or not (((not pp or oV) and (not oB or oB) or not oV and not oB and (not oV and not oV) or (not oV or pp or not oB and oV) and ((not oB or not oV) and (not oB and not pp))) and (not oV and pp and (not pp and oB) and (not pp and oV and (pp and not oB)) or (oB or not pp or not pp and not oV or (oV and oB or not pp and pp)))) then
                        oJ = "https://discord.gg/K7Qxnxkk46"
                    else
                        nX = "https://discord.gg/K7Qxnxkk46"
                    end
                    xI_14 = (xI_14 + 287) % 288
                else
                    xI_31 = { "ftk", "ksaliqhrvmt", "ebuzhmkgcvy", "kku", "jksjahus", "ngpyoz", "xnlklkmzz" }
                    local yu = xI_14
                    xI_21 = xI_31[yu % 7 + 1]
                    if xI_21:len() <= xI_21:reverse():rep(yu % 3 + 2):len() then
                        oF = "https://discord.gg/K7Qxnxkk46"
                    else
                        nV = "https://discord.gg/K7Qxnxkk46"
                    end
                    xI_14 = (xI_14 + 107) % 288
                end
            elseif xI_10 <= 8 then
                xI_31 = { "xmvrdi", "xjep", "ksoet", "xhtbojjy", "zzabstbeqy", "tdgr", "xzq" }
                local yy = xI_14
                xI_21 = xI_31[yy % 7 + 1]
                if xI_21:len() >= xI_21:gsub("(.)", "%1%1", yy % 3 % 2 + 1):len() then
                    xI_17 = require(oB.Core.Remotes)
                else
                    oB = require(xI_17.Core.Remotes)
                end
                xI_14 = (xI_14 + 143) % 288
            else
                xI_31 = (vector.create((xI_14 * 4 + 2) % 11 + 1, (xI_14 * 11 + 6) % 13 + 1, (xI_14 * 5 + 12) % 17 + 1))
                xI_21 = (vector.create((xI_14 * 1 + 4) % 11 + 1, (xI_14 * 9 + 5) % 13 + 1, (xI_14 * 13 + 5) % 17 + 1))
                xI_11 = (vector.create((xI_14 * 7 + 5) % 11 + 1, (xI_14 * 4 + 10) % 13 + 1, (xI_14 * 8 + 13) % 17 + 1))
                xI_1 = (vector.create((xI_14 * 4 + 4) % 5 + 1, (xI_14 * 2 + 2) % 7 + 1, (xI_14 * 3 + 1) % 9 + 1))
                if vector.dot(vector.cross(xI_31, (vector.cross(xI_21, xI_11))), xI_1) == vector.dot(xI_21 * vector.dot(xI_31, xI_11) - xI_11 * vector.dot(xI_31, xI_21), xI_1) + 1 then
                    xI_17 = require(FusionRules.Features.Coop.CoopView)
                    ox = require(FusionRules.Features.Chicken.FusionRules)
                    og = require(FusionRules.Features.Scrap.RecyclerView)
                    om = require(FusionRules.Core.Progression.RebirthBonus)
                else
                    ox = require(xI_17.Features.Coop.CoopView)
                    FusionRules = require(xI_17.Features.Chicken.FusionRules)
                    om = require(xI_17.Features.Scrap.RecyclerView)
                    og = require(xI_17.Core.Progression.RebirthBonus)
                end
                xI_14 = (xI_14 + 107) % 288
            end
        elseif xI_10 <= 14 then
            if xI_10 <= 12 then
                if xI_10 <= 11 then
                    if xI_10 <= 10 then
                        xI_31 = (vector.create((xI_14 * 1 + 5) % 11 + 1, (xI_14 * 7 + 8) % 13 + 1, (xI_14 * 11 + 7) % 17 + 1))
                        xI_21 = (vector.create((xI_14 * 7 + 2) % 11 + 1, (xI_14 * 8 + 2) % 13 + 1, (xI_14 * 2 + 10) % 17 + 1))
                        xI_11 = (vector.create((xI_14 * 5 + 7) % 11 + 1, (xI_14 * 9 + 12) % 13 + 1, (xI_14 * 14 + 15) % 17 + 1))
                        xI_1 = (vector.create((xI_14 * 1 + 8) % 11 + 1, (xI_14 * 1 + 11) % 13 + 1, (xI_14 * 2 + 2) % 17 + 1))
                        if vector.dot(vector.cross(xI_31, xI_21), (vector.cross(xI_11, xI_1))) == vector.dot(xI_31, xI_11) * vector.dot(xI_21, xI_1) - vector.dot(xI_31, xI_1) * vector.dot(xI_21, xI_11) then
                            oc = require(xI_17.Content.GameConfig)
                        else
                            xI_17 = require(oc.Content.GameConfig)
                        end
                        xI_14 = (xI_14 + 107) % 288
                    else
                        local yG = bit32.rrotate(bit32.bxor(bit32.lrotate(xI_14, 26), string.byte(tostring(maxLevel))), 19)
                        if bit32.bxor(bit32.lrotate(bit32.bxor(yG, 3994720077), 2), 3093978423) == bit32.lrotate(yG, 2) then
                            client = require(xI_17.Packages.DataService).client
                            ChickenMode = require(xI_25.Features.Chicken.ChickenMode)
                            nZ = require(xI_25.UI["2d"].Shop.ShopWindow.catalog)
                        else
                            nZ = require(client.Packages.DataService).client
                            xI_25 = require(ChickenMode.Features.Chicken.ChickenMode)
                            xI_17 = require(ChickenMode.UI["2d"].Shop.ShopWindow.catalog)
                        end
                        xI_14 = (xI_14 + 179) % 288
                    end
                else
                    if xI_14 * 114920721 + 7 + 7 <= xI_14 * 114920721 + 7 + 7 + 6 then
                        nX = oB.defs
                        nS = oc.roster.hatch.batchMax
                        nP = oc.scrap.pickupRadius
                        radius = oc.scrap.deposit.radius
                        maxLevel = oc.generators.maxLevel
                    else
                        oB = maxLevel.defs
                        nP = radius.roster.hatch.batchMax
                        nX = radius.scrap.pickupRadius
                        oc = radius.scrap.deposit.radius
                        nS = radius.generators.maxLevel
                    end
                    xI_14 = (xI_14 + 35) % 288
                end
            elseif xI_10 <= 13 then
                xI_31 = (vector.create((xI_14 * 3 + 9) % 11 + 1, (xI_14 * 11 + 8) % 13 + 1, (xI_14 * 9 + 11) % 17 + 1))
                xI_21 = (vector.create((xI_14 * 3 + 3) % 11 + 1, (xI_14 * 7 + 2) % 13 + 1, (xI_14 * 6 + 16) % 17 + 1))
                xI_11 = (vector.create((xI_14 * 2 + 1) % 5 + 1, (xI_14 * 4 + 7) % 7 + 1, (xI_14 * 5 + 4) % 9 + 1))
                if math.abs((vector.angle(xI_31, xI_21, xI_11))) - math.abs((vector.angle(xI_21, xI_31, xI_11))) == 5 then
                    oc = maxSlots.generators.maxSlots
                else
                    maxSlots = oc.generators.maxSlots
                end
                xI_14 = (xI_14 + 251) % 288
            else
                xI_31 = {
                    "oaxsyklprtr",
                    "ldagmmoqlj",
                    "ucoxoijly",
                    "icjd",
                    "bmwhinc",
                    "urkw",
                    "emao",
                    "kqsz",
                    "imyebn",
                    "awba",
                    "ogvkwp"
                }
                if xI_31[(xI_14 * 37 + 109) % 11 + 1] <= xI_31[(xI_14 * 37 + 109) % 11 + 1] then
                    xI_3 = ""
                else
                    pk = ""
                end
                xI_14 = (xI_14 + 143) % 288
            end
        elseif xI_10 <= 16 then
            if xI_10 <= 15 then
                local yR = bit32.rrotate(bit32.bxor(bit32.lrotate(xI_14, 9), string.byte(tostring(nO))), 30)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(yR, 943926261), 2432673007), (bit32.bxor(bit32.band(yR, 3351041034), 461907471))), 2432673007), 461907471) ~= yR then
                    xI_3 = getgenv().Library
                else
                    o9 = getgenv().Library
                end
                xI_14 = (xI_14 + 215) % 288
            else
                if ((not ox and not oh or ox and not ph) and ((not ph or not oQ) and (ox or ox)) and (ox and not ph and (not oQ or not oQ) or oh and oh and (not ox or not oQ)) or (oQ or oR or (not ox or oQ) or (not ox or not ox) and (oR or ox)) and (oh and oQ or (not oQ or ox) or (not ox and oR or (not oQ or not oh)))) and not ((not ox and not oh or ox and not ph) and ((not ph or not oQ) and (ox or ox)) and (ox and not ph and (not oQ or not oQ) or oh and oh and (not ox or not oQ)) or (oQ or oR or (not ox or oQ) or (not ox or not ox) and (oR or ox)) and (oh and oQ or (not oQ or ox) or (not ox and oR or (not oQ or not oh)))) then
                    xI_3 = getgenv().ThemeManager
                    o9 = getgenv().SaveManager
                    oV = o_.Toggles
                    xI_9 = o_.Options
                    xI_30 = fn1076
                else
                    xI_30 = getgenv().ThemeManager
                    xI_9 = getgenv().SaveManager
                    o_ = o9.Toggles
                    oV = o9.Options
                    oQ = fn1076
                end
                xI_14 = (xI_14 + 35) % 288
            end
        elseif xI_10 <= 17 then
            if ((not oa or pb) and (not n0 or not oa) or not oa and n0 and (xI_9 and not oa)) and ((oa and not oU or (not xI_9 or not oa)) and (not xI_9 and not oa or not oa and not oU)) and not (((not oa or pb) and (not n0 or not oa) or not oa and n0 and (xI_9 and not oa)) and ((oa and not oU or (not xI_9 or not oa)) and (not xI_9 and not oa or not oa and not oU))) then
                oa = fns.fn339
                oD = fn941
                on = fns.fn153
            else
                oD = fns.fn339
                on = fn941
                oa = fns.fn153
            end
            xI_14 = (xI_14 + 179) % 288
        else
            xI_31 = (vector.create((xI_14 * 4 + 8) % 11 + 1, (xI_14 * 4 + 6) % 13 + 1, (xI_14 * 4 + 15) % 17 + 1))
            xI_21 = (vector.create((xI_14 * 7 + 9) % 11 + 1, (xI_14 * 5 + 3) % 13 + 1, (xI_14 * 13 + 11) % 17 + 1))
            xI_11 = (vector.create((xI_14 * 5 + 8) % 11 + 1, (xI_14 * 7 + 10) % 13 + 1, (xI_14 * 5 + 15) % 17 + 1))
            if vector.dot(vector.cross(xI_31, xI_21), xI_11) == vector.dot(vector.cross(xI_21, xI_11), xI_31) then
                xI_7 = "#7fd47f"
                xI_18 = "#6ec1ff"
                pn = "#e8a34d"
            else
                pn = "#7fd47f"
                xI_7 = "#6ec1ff"
                xI_18 = "#e8a34d"
            end
            xI_14 = (xI_14 + 143) % 288
        end
    elseif xI_10 <= 27 then
        if xI_10 <= 23 then
            if xI_10 <= 21 then
                if xI_10 <= 20 then
                    if xI_10 <= 19 then
                        xI_31 = (vector.create((xI_14 * 5 + 9) % 11 + 1, (xI_14 * 10 + 8) % 13 + 1, (xI_14 * 11 + 7) % 17 + 1))
                        local yl = vector.floor(xI_31) + vector.ceil(xI_31 * -1)
                        if vector.dot(yl, yl) == 2 then
                            o_ = "#8b93a3"
                        else
                            xI_20 = "#8b93a3"
                        end
                        xI_14 = (xI_14 + 251) % 288
                    else
                        xI_31 = { "ywaph", "fbnov", "mxhh", "nov", "lho", "egs", "zosphdegni", "rqhma", "cwnhw", "xyzz" }
                        local yK = xI_14
                        xI_21 = xI_31[yK % 10 + 1]
                        if xI_21:len() <= xI_21:reverse():rep(yK % 3 + 2):len() then
                            pe = fns.fn57
                            oW = fns.fn505
                            oH = fn928
                        else
                            oH = fns.fn57
                            pe = fns.fn505
                            oW = fn928
                        end
                        xI_14 = (xI_14 + 71) % 288
                    end
                else
                    xI_31 = (vector.create((xI_14 * 5 + 5) % 11 + 1, (xI_14 * 2 + 13) % 13 + 1, (xI_14 * 2 + 11) % 17 + 1))
                    xI_21 = (vector.create((xI_14 * 1 + 6) % 11 + 1, (xI_14 * 11 + 11) % 13 + 1, (xI_14 * 7 + 13) % 17 + 1))
                    xI_11 = (vector.create((xI_14 * 2 + 8) % 11 + 1, (xI_14 * 3 + 12) % 13 + 1, (xI_14 * 14 + 6) % 17 + 1))
                    xI_1 = (vector.create((xI_14 * 7 + 6) % 11 + 1, (xI_14 * 3 + 12) % 13 + 1, (xI_14 * 9 + 7) % 17 + 1))
                    if vector.dot(vector.cross(xI_31, xI_21), (vector.cross(xI_11, xI_1))) == vector.dot(xI_31, xI_11) * vector.dot(xI_21, xI_1) - vector.dot(xI_31, xI_1) * vector.dot(xI_21, xI_11) then
                        xI_29 = {
                            "common",
                            "uncommon",
                            "rare",
                            "epic",
                            "legendary",
                            "mythic",
                            "divine",
                            "celestial",
                            "cosmic",
                            "secret"
                        }
                        oh = fn860
                        nV = fns.fn188
                    else
                        nV = {
                            "common",
                            "divine",
                            "uncommon",
                            "rare",
                            "epic",
                            "cosmic",
                            "secret",
                            "celestial",
                            "mythic",
                            "legendary"
                        }
                        xI_29 = fn860
                        oh = fns.fn188
                    end
                    xI_14 = (xI_14 + 179) % 288
                end
            elseif xI_10 <= 22 then
                xI_31 = { "kfewhsiq", "tjky", "srnolfck", "dbfbk", "ublx", "yxuhfbirvi", "xgazcvheq", "npp", "cxwfjtu" }
                local yO = xI_14
                xI_21 = xI_31[yO % 9 + 1]
                if xI_21:len() <= xI_21:gsub("(.)", "%1%1", yO % 3 % 2 + 1):len() then
                    nL = fns.fn576
                else
                    oh = fns.fn576
                end
                xI_14 = (xI_14 + 71) % 288
            else
                if xI_14 * 14541043 + 12 + 3 <= xI_14 * 14541043 + 12 + 3 + 2 then
                    o7 = fn1051
                    oK = fns.fn135
                    od = fn770
                    nM = fns.fn55
                    o0 = fn889
                else
                    nM = fn1051
                    o0 = fns.fn135
                    oK = fn770
                    o7 = fns.fn55
                    od = fn889
                end
                xI_14 = (xI_14 + 107) % 288
            end
        elseif xI_10 <= 25 then
            if xI_10 <= 24 then
                xI_31 = {
                    "oxicabvei",
                    "hehpxlx",
                    "fxzgvqpx",
                    "hpasnegh",
                    "dyliovytk",
                    "lukiwpqglb",
                    "iiouucztw",
                    "yndcaf",
                    "lvwoqhc",
                    "knyjoked",
                    "igfhur",
                    "sewv"
                }
                local yv = xI_14
                xI_21 = xI_31[yv % 12 + 1]
                if xI_21:len() >= xI_21:reverse():rep(yv % 3 + 2):len() then
                    oM = fn900
                    ow = fn1010
                    oT = fns.fn581
                    oE = fns.fn115
                else
                    oT = fn900
                    oM = fn1010
                    oE = fns.fn581
                    ow = fns.fn115
                end
                xI_14 = (xI_14 + 143) % 288
            else
                if (xI_14 * 2 + 5) * 4 % 3 == ((xI_14 * 2 + 5) * 4 + 0) % 3 then
                    oi = fns.fn453
                    n7 = fns.fn225
                    nR = fns.fn274
                else
                    nR = fns.fn453
                    oi = fns.fn225
                    n7 = fns.fn274
                end
                xI_14 = (xI_14 + 107) % 288
            end
        elseif xI_10 <= 26 then
            xI_31 = {
                "tvdkbxfhavg",
                "dsmlxbnievd",
                "fok",
                "jjiqvrvhoqgs",
                "zlnedhsuqbdx",
                "bhfyalvnvfdd",
                "herdfagxp",
                "bgmndoybj",
                "ful",
                "woqz",
                "dwu",
                "dccjgzdwn",
                "tdbvfgx",
                "gfdtmhzgpwet",
                "jamafjmjdnor",
                "hwunyekdkgq"
            }
            if xI_31[(xI_14 * 67 + 66) % 16 + 1] <= xI_31[(xI_14 * 67 + 66) % 16 + 1] then
                pr = fns.fn80
                oY = fns.fn229
                oP = fn780
                oI = fn728
                oj = fns.fn258
            else
                oI = fns.fn80
                oj = fns.fn229
                oY = fn780
                pr = fn728
                oP = fns.fn258
            end
            xI_14 = (xI_14 + 215) % 288
        else
            if (xI_14 * 2 + 7) * 16 % 3 == ((xI_14 * 2 + 7) * 16 + 5) % 3 then
                ph = fn814
                nO = fns.fn255
            else
                nO = fn814
                ph = fns.fn255
            end
            xI_14 = (xI_14 + 143) % 288
        end
    elseif xI_10 <= 32 then
        if xI_10 <= 30 then
            if xI_10 <= 29 then
                if xI_10 <= 28 then
                    xI_31 = (vector.create((xI_14 * 3 + 2) % 11 + 1, (xI_14 * 10 + 12) % 13 + 1, (xI_14 * 14 + 4) % 17 + 1))
                    xI_21 = (vector.create((xI_14 * 7 + 6) % 11 + 1, (xI_14 * 2 + 13) % 13 + 1, (xI_14 * 9 + 16) % 17 + 1))
                    local ym = vector.cross(xI_31, xI_21)
                    local yn = vector.dot(xI_31, xI_21)
                    if vector.dot(ym, ym) + yn * yn == vector.dot(xI_31, xI_31) * vector.dot(xI_21, xI_21) then
                        oU = fn732
                        n5 = fns.fn272
                        oo = fn816
                        po = fns.fn85
                    else
                        po = fn732
                        oU = fns.fn272
                        n5 = fn816
                        oo = fns.fn85
                    end
                    xI_14 = (xI_14 + 215) % 288
                else
                    xI_31 = {
                        "kshpsayseun",
                        "qlcyve",
                        "iauphajksjz",
                        "fxqldjukl",
                        "cmxxpdrg",
                        "fttzygnesl",
                        "ylsgir",
                        "ffpvfhuclr",
                        "wdzna",
                        "evsvqrs"
                    }
                    local yr = xI_14
                    xI_21 = xI_31[yr % 10 + 1]
                    if xI_21:len() >= xI_21:gsub("(.)", "%1%1", yr % 3 % 2 + 1):len() then
                        pp = fn973
                        oS = fn1110
                        op = fns.fn510
                        pa = fns.fn352
                    else
                        op = fn973
                        pp = fn1110
                        pa = fns.fn510
                        oS = fns.fn352
                    end
                    xI_14 = (xI_14 + 71) % 288
                end
            else
                if (xI_14 * 3 + 2) * 5 % 4 == ((xI_14 * 3 + 2) * 5 + 5) % 4 then
                    o5 = fn974
                    pq = fns.fn482
                else
                    pq = fn974
                    o5 = fns.fn482
                end
                xI_14 = (xI_14 + 287) % 288
            end
        elseif xI_10 <= 31 then
            xI_31 = {
                "hdpafbl",
                "ohm",
                "rhqzmcgfag",
                "gbnkbbsd",
                "vzqwhwqq",
                "cecsetgud",
                "zjv",
                "zqykwgxguc",
                "nqfjlnahpi",
                "ybpbd"
            }
            local yP = xI_14
            xI_21 = xI_31[yP % 10 + 1]
            if xI_21:len() <= xI_21:gsub("(.)", "%1%1", yP % 3 % 2 + 1):len() then
                oN = fn1147
                pg = fns.fn419
                of = fns.fn615
                o3 = fns.fn196
                oO = fns.fn393
            else
                oO = fn1147
                o3 = fns.fn419
                oN = fns.fn615
                pg = fns.fn196
                of = fns.fn393
            end
            xI_14 = (xI_14 + 35) % 288
        else
            xI_31 = {
                "krfjfv",
                "woscmbp",
                "yzvoushqri",
                "zzkndsfugwyp",
                "nhitmixwcpoc",
                "lklzxejd",
                "jnndismci",
                "pyhp",
                "lnqhxf",
                "fpszxa",
                "tfztodsnb",
                "idlgmtcujb",
                "cimfhjs"
            }
            if xI_31[(xI_14 * 36 + 105) % 13 + 1] <= xI_31[(xI_14 * 36 + 105) % 13 + 1] then
                nT = fn1081
                oR = fn976
                nU = fn1043
                pk = fns.fn492
            else
                oR = fn1081
                nT = fn976
                pk = fn1043
                nU = fns.fn492
            end
            xI_14 = (xI_14 + 179) % 288
        end
    elseif xI_10 <= 34 then
        if xI_10 <= 33 then
            xI_31 = {
                "udaojbtrmv",
                "bdabl",
                "xhh",
                "upbbjcwnq",
                "vmve",
                "njsebgqt",
                "cnf",
                "qrmcszlqp",
                "qncxmawc",
                "rnyizkps",
                "merbapwh",
                "lqtgvvwnviw"
            }
            local yt = xI_14
            xI_21 = xI_31[yt % 12 + 1]
            if xI_21:len() >= xI_21:gsub("(.)", "%1%1", yt % 3 % 2 + 1):len() then
                nP = fn700
            else
                oX = fn700
            end
            xI_14 = (xI_14 + 143) % 288
        else
            if xI_14 * 132871517 + 5 + 1 <= xI_14 * 132871517 + 5 + 1 + 3 then
                ov = fn1039
                nW = fn844
                pb = fn670
                n6 = false
                n2 = fn923
            else
                n2 = fn1039
                n6 = fn844
                ov = fn670
                pb = false
                nW = fn923
            end
            xI_14 = (xI_14 + 215) % 288
        end
    elseif xI_10 <= 35 then
        local yD = bit32.rrotate(bit32.bxor(bit32.lrotate(xI_14, 11), string.byte(tostring(xI_19))), 11)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(yD, 2863441253), 88215398), (bit32.bxor(bit32.band(yD, 1431526042), 1594828416))), 88215398), 1594828416) == yD then
            pc = fns.fn365
        else
            o7 = fns.fn365
        end
        xI_14 = (xI_14 + 143) % 288
    else
        if (not xI_7 or xI_7) and (oj and false) and ((not FusionRules or oj) and (FusionRules or not oJ)) and (not oj and not FusionRules or (not oJ or false) or (not FusionRules and false or (false or not xI_7))) or not ((not xI_7 or xI_7) and (oj and false) and ((not FusionRules or oj) and (FusionRules or not oJ)) and (not oj and not FusionRules or (not oJ or false) or (not FusionRules and false or (false or not xI_7)))) then
            n8 = fn1045
        else
            ov = fn1045
        end
        xI_14 = (xI_14 + 143) % 288
    end
until (xI_14 * 283 + 30) % 288 == 52
if o9.ScreenGui then
    xI_14 = 1
    repeat
        if xI_14 * 41080283 + 5 + 2 >= xI_14 * 41080283 + 5 + 2 + 2 then
            LocalPlayer.ScreenGui.Parent = o9:WaitForChild("PlayerGui")
        else
            o9.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
        xI_14 = (xI_14 + 0) % 4
    until (xI_14 * 1 + 2) % 4 == 3
end
xI_17 = {
    Info = xI_27:AddTab("Info", "info"),
    Main = xI_27:AddTab("Main", "egg"),
    Player = xI_27:AddTab("Player", "person-standing"),
    Settings = xI_27:AddTab("Settings", "settings")
}
xI_25 = fns.fn648
for k, v in xI_17 do
    xI_25(v)
end
oL, xI_14, xI_10, Label, ob, xI_27 = nil, nil, nil, nil, nil, nil
xI_3 = 16
repeat
    xI_25 = (xI_3 * 2 + 1) % 3 + 1
    if xI_25 <= 2 then
        if xI_25 <= 1 then
            xI_25 = { "mctaltsei", "wgvl", "jnpkwd", "uvgkhsubrf", "rvvvcyikexw", "lmr", "etahyubox" }
            local yC = xI_3
            xI_31 = xI_25[yC % 7 + 1]
            if xI_31:len() >= xI_31:reverse():rep(yC % 3 + 2):len() then
                xI_19 = "Unknown"
                pcall(fns.fn367)
                pn = oL.Info:AddLeftGroupbox("Account", "circle-user")
                pn:AddLabel(xI_14("User", oa.Name, xI_17), true)
                pn:AddLabel(xI_14("Status", "Keyless", xI_17), true)
                pn:AddLabel(xI_14("Executor", "Unknown", xI_17), true)
                xI_7 = oL.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                xI_7:AddLabel(Label(LocalPlayer .. " [" .. tostring(game.PlaceId) .. "]", on), true)
                xI_7:AddLabel(xI_14("Place ID", tostring(game.PlaceId), on), true)
                xI_10 = xI_7:AddLabel(xI_14("Session time", "0s", xI_18), true)
            else
                oL = "Unknown"
                pcall(fns.fn367)
                xI_14 = xI_17.Info:AddLeftGroupbox("Account", "circle-user")
                xI_14:AddLabel(oa("User", LocalPlayer.Name, xI_7), true)
                xI_14:AddLabel(oa("Status", "Keyless", xI_7), true)
                xI_14:AddLabel(oa("Executor", oL, xI_7), true)
                xI_10 = xI_17.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                xI_10:AddLabel(on(xI_19 .. " [" .. tostring(game.PlaceId) .. "]", xI_18), true)
                xI_10:AddLabel(oa("Place ID", tostring(game.PlaceId), xI_18), true)
                Label = xI_10:AddLabel(oa("Session time", "0s", pn), true)
            end
            xI_3 = (xI_3 + 17) % 24
        else
            xI_25 = {
                "ttsakvhdh",
                "bkbvs",
                "sgfvonxxpr",
                "brlx",
                "xbtq",
                "kfxshc",
                "omx",
                "txqwduh",
                "prqxre",
                "xtucm"
            }
            local yo = xI_3
            xI_31 = xI_25[yo % 10 + 1]
            if xI_31:len() >= xI_31:gsub("(.)", "%1%1", yo % 3 % 2 + 1):len() then
                oL = tostring(game.JobId)
            else
                ob = tostring(game.JobId)
            end
            xI_3 = (xI_3 + 11) % 24
        end
    else
        xI_25 = (vector.create((xI_3 * 4 + 3) % 11 + 1, (xI_3 * 1 + 2) % 13 + 1, (xI_3 * 9 + 7) % 17 + 1))
        local yB = vector.floor(xI_25) + vector.ceil(xI_25 * -1)
        if vector.dot(yB, yB) == 0 then
            xI_27 = #ob > 18
        else
            ob = #xI_27 > 18
        end
        xI_3 = (xI_3 + 8) % 24
    end
until (xI_3 * 7 + 21) % 24 == 1
if xI_27 then
    xI_14 = 7
    repeat
        xI_3 = (vector.create((xI_14 * 2 + 4) % 11 + 1, (xI_14 * 5 + 11) % 13 + 1, (xI_14 * 11 + 5) % 17 + 1))
        xI_25 = (vector.create((xI_14 * 3 + 5) % 11 + 1, (xI_14 * 9 + 12) % 13 + 1, (xI_14 * 2 + 9) % 17 + 1))
        xI_31 = (vector.create((xI_14 * 7 + 4) % 11 + 1, (xI_14 * 2 + 13) % 13 + 1, (xI_14 * 3 + 3) % 17 + 1))
        xI_21 = (vector.create((xI_14 * 3 + 1) % 5 + 1, (xI_14 * 5 + 3) % 7 + 1, (xI_14 * 3 + 5) % 9 + 1))
        if vector.dot(vector.cross(xI_3, (vector.cross(xI_25, xI_31))), xI_21) == vector.dot(xI_25 * vector.dot(xI_3, xI_31) - xI_31 * vector.dot(xI_3, xI_25), xI_21) then
            xI_27 = string.sub(ob, 1, 18) .. "..."
        else
            ob = string.sub(xI_27, 1, 18) .. "..."
        end
        xI_14 = (xI_14 + 5) % 8
    until (xI_14 * 7 + 7) % 8 == 3
end
xI_14 = xI_27 or ob
nN, SocialsGroup, FaqGroup, xI_27, xI_3, xI_11, n3, n_, connection, connection2, oC, oy, connection3, CurrentCamera2, pl, ou = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
xI_25 = xI_14
xI_10:AddLabel(oa("Server", xI_25, xI_20), true)
xI_10:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
nN = os.clock()
task.spawn(worker)
local ScriptsGroup = xI_17.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(on("Included in this hub", xI_20), true)
ScriptsGroup:AddLabel(on(xI_19, xI_18), true)
local FeaturesGroup = xI_17.Info:AddRightGroupbox("Features", "list")
if (xI_27 or FaqGroup or (xI_11 or xI_3)) and (xI_11 and xI_11 or (xI_3 or not xI_3)) and ((xI_11 or FeaturesGroup or (FaqGroup or xI_11)) and (FaqGroup and FaqGroup and (not FeaturesGroup and FaqGroup))) or not ((xI_27 or FaqGroup or (xI_11 or xI_3)) and (xI_11 and xI_11 or (xI_3 or not xI_3)) and ((xI_11 or FeaturesGroup or (FaqGroup or xI_11)) and (FaqGroup and FaqGroup and (not FeaturesGroup and FaqGroup)))) then
    FeaturesGroup:AddLabel(on("Auto Farm", xI_18), true)
    FeaturesGroup:AddLabel(on("Plot Upgrades", pn), true)
    FeaturesGroup:AddLabel(on("Battle Automation", xI_7), true)
    FeaturesGroup:AddLabel(on("Event Automation", pn), true)
    FeaturesGroup:AddLabel(on("Egg Collection", xI_20), true)
    FeaturesGroup:AddLabel(on("Player Movement", xI_18), true)
    SocialsGroup = xI_17.Info:AddRightGroupbox("Socials", "link")
else
    pn:AddLabel(xI_20("Auto Farm", on), true)
    pn:AddLabel(xI_20("Plot Upgrades", xI_17), true)
    pn:AddLabel(xI_20("Battle Automation", xI_18), true)
    pn:AddLabel(xI_20("Event Automation", xI_17), true)
    pn:AddLabel(xI_20("Egg Collection", SocialsGroup), true)
    pn:AddLabel(xI_20("Player Movement", on), true)
    FeaturesGroup.Info:AddRightGroupbox("Socials", "link")
end
SocialsGroup:AddButton({ Text = "Discord", Func = oD })
SocialsGroup:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
local TempoHubGroup = xI_17.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = oD })
FaqGroup = xI_17.Info:AddRightGroupbox("FAQ", "circle-help")
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
local FarmGroup = xI_17.Main:AddLeftGroupbox("Farm", "egg")
FarmGroup:AddToggle("AutoCollectEgg", { Text = "Auto Collect Egg", Default = false })
FarmGroup:AddToggle("AutoOpenEggs", { Text = "Auto Open Eggs", Default = false })
FarmGroup:AddToggle("AutoFuseChickens", { Text = "Auto Fuse Chickens", Default = false })
FarmGroup:AddToggle("AutoSellChickens", { Text = "Auto Sell Chickens", Default = false })
FarmGroup:AddDropdown("SellMaxRarity", { Text = "Sell up to rarity", Values = xI_29, Default = "common" })
FarmGroup:AddToggle("AutoGrabScraps", { Text = "Auto Grab Scraps", Default = false })
FarmGroup:AddSlider("ScrapWalkSpeed", { Text = "Scrap Walk Speed", Default = 16, Min = 8, Max = 50, Rounding = 0 })
FarmGroup:AddToggle("AutoRecycleScrap", { Text = "Auto Recycle Scrap", Default = false })
FarmGroup:AddSlider("RecycleAtScrap", { Text = "Recycle when scrap", Default = 10, Min = 1, Max = oc.scrap.weight.fullLoad, Rounding = 0 })
FarmGroup:AddToggle("AutoUpgradeRecycler", { Text = "Auto Upgrade Recycler", Default = false })
xI_1 = xI_17.Main:AddRightGroupbox("Plot", "house")
xI_1:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
xI_1:AddToggle("AutoUpgradeCoop", { Text = "Auto Upgrade Coop", Default = false })
xI_1:AddToggle("AutoUpgradeFeeder", { Text = "Auto Upgrade Feeder", Default = false })
xI_1:AddSlider("FeederMaxLevel", { Text = "Feeder max level", Default = maxLevel, Min = 1, Max = maxLevel, Rounding = 0 })
xI_1:AddToggle("AutoBuyFeeders", { Text = "Auto Buy Feeders", Default = false })
xI_1:AddDropdown("BuyFeederAmount", { Text = "Buy feeder amount", Values = { "1", "Max" }, Default = "1" })
o_.AutoBuyFeeders:OnChanged(fn899)
oV.BuyFeederAmount:OnChanged(fn861)
xI_21 = xI_17.Main:AddLeftGroupbox("Battle", "swords")
xI_21:AddToggle("AutoStartTower", { Text = "Auto Start Tower", Default = false })
xI_21:AddToggle("AutoStartFrontier", { Text = "Auto Start Frontier", Default = false })
xI_21:AddToggle("AutoNoThanks", { Text = "Auto No Thanks", Default = false })
xI_21:AddToggle("AutoStartChaos", { Text = "Auto Start Chaos", Default = false })
xI_31 = xI_17.Main:AddRightGroupbox("Events", "sparkles")
xI_31:AddToggle("AutoHotEgg", { Text = "Auto Hot Egg Dodge", Default = false })
xI_31:AddToggle("AutoGooseCoins", { Text = "Auto Goose Coins", Default = false })
xI_27 = xI_17.Player:AddLeftGroupbox("Movement", "footprints")
xI_27:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
xI_27:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
xI_27:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
xI_27:AddToggle("NoClip", { Text = "NoClip", Default = true })
xI_27:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
xI_3 = xI_17.Player:AddRightGroupbox("Fly", "feather")
xI_3:AddToggle("Fly", { Text = "Fly", Default = false })
xI_3:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
pcall(fns.fn532)
pcall(fn1063)
xI_11 = xI_17.Settings:AddLeftGroupbox("Menu")
xI_11:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
o9.ToggleKeybind = oV.MenuKeybind
xI_11:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
xI_11:AddButton({ Text = "Unload", Func = fns.onUnload })
xI_30:SetLibrary(o9)
xI_30:SetFolder("TempoHub")
xI_30:SaveDefault("Monochrome")
xI_30:ApplyToTab(xI_17.Settings)
xI_30:LoadDefault()
xI_9:SetLibrary(o9)
xI_9:IgnoreThemeSettings()
xI_9:SetIgnoreIndexes({ "MenuKeybind" })
xI_9:SetFolder("TempoHub/grow-a-chicken-fighter")
xI_9:BuildConfigSection(xI_17.Settings)
xI_9:LoadAutoloadConfig()
n3 = tick()
n_ = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local wH = v
        pcall(function()
            wH:Disable()
        end)
    end
end)
pl = fn1143
connection = UserInputService.InputBegan:Connect(fns.onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
oC = {}
oy = false
ou = function(jd)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not jd)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not jd
        end
    end)
    if not jd then
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
o_.AntiGameplayPause:OnChanged(fns.fn535)
o_.Fly:OnChanged(fns.fn228)
o_.WalkSpeedEnabled:OnChanged(fns.fn449)
connection3 = RunService.Stepped:Connect(fns.onStepped)
UserInputService.JumpRequest:Connect(fns.onJumpRequest)
CurrentCamera2 = Workspace.CurrentCamera
RunService.RenderStepped:Connect(fns.onRenderStepped)
o9:OnUnload(fns.fn503)
ou(o_.AntiGameplayPause.Value)
task.spawn(worker2)
task.spawn(fns.worker3)
task.spawn(worker4)
task.spawn(fns.worker5)
task.spawn(fns.worker6)
task.spawn(worker7)
task.spawn(worker8)
end)(...)

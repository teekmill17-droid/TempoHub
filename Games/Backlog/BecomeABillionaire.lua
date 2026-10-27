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
getgenv().TempoHoodSubtitle = "BECOME A BILLIONAIRE"
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
local fU
local PlotNetwork
local VirtualUser
local gl
local autoUpgradeLoop
local RebirthNetwork
local f2
local f5
local fN
local f8
local fQ
local autoPlaceLoop
local connection
local Toggles
local gh
local gk
local fZ
local autoMergeLoop
local gn
local fJ
local Library
local gq
local fM
local ga
local fV
local gg
local fY
local gj
local f0
local gm
local DataServiceClient
local fO
local f9
local LocalPlayer
local Options
local function fn3()
    local hj_1
    local hi = f0 and f0.Parent
    local hi_1
    if hi then
        return f0
    end
    hi_1, hj_1 = pcall(function()
        return PlotNetwork.Remotes.GetPlotFromPlayer:InvokeServer(LocalPlayer)
    end)
    if hi_1 and hj_1 then
        f0 = hj_1
    end
    return f0
end
local function onBuyCharacters(cQ)
    local jz = {}
    for k, v in cQ do
        if v then
            jz[k] = true
        end
    end
    fU = jz
end
local function autoPlaceLoop2()
    while not Library.Unloaded do
        if Toggles.AutoPlace.Value then
            autoPlaceLoop()
        end
        task.wait(0.5)
    end
end
local function autoUpgradeLoop2()
    while not Library.Unloaded do
        if Toggles.AutoUpgrade.Value then
            fN()
        end
        task.wait(0.5)
    end
end
local function onAntiAfk(dB)
    if dB then
        if not connection then
            connection = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    elseif connection then
        connection:Disconnect()
        connection = nil
    end
end
local function onMergeOnlyIfGems(dh)
    f2 = dh
end
local function onUpgradeSelection(c1)
    local jK = {}
    for k, v in c1 do
        if v then
            jK[k] = true
        end
    end
    fM = jK
end
local function onSelectAll()
    local j6 = {}
    for k, v in f9 do
        j6[v] = true
    end
    Options.MergeCharacters:SetValue(j6)
end
local function onMergeNow()
    task.spawn(autoMergeLoop)
end
local function fn149()
    pcall(function()
        RebirthNetwork.Remotes.DoRebirth:InvokeServer(gq)
    end)
end
local function fn231()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    select("#", "Become a Billionaire unloaded")
end
local function onUnload()
    Library:Unload()
end
local function onMergeKeep(df)
    f5 = df
end
local function fn283()
    local Character = LocalPlayer.Character
    local hq = Character and Character:FindFirstChild("HumanoidRootPart")
    return hq
end
local function onCollectNow()
    task.spawn(gn)
end
local function onRebirthAmount(c6)
    if type(c6) == "number" then
        c6 = gk[c6]
    end
    local jS = gg[c6]
    local jW = if jS then 1 else 0
    local jU = 3558 * jW + 1960 * (1 - jW)
    local jV = 1378 * jW + 3334 * (1 - jW)
    if not ((jU * 3419 + jV * 3042 + jU * jV) % 16777213 == 4482389) then
        jS = 1
    end
    gq = jS
end
local function autoRebirthLoop()
    while not Library.Unloaded do
        if Toggles.AutoRebirth.Value then
            gh()
        end
        task.wait(0.5)
    end
end
local function fn425()
    local hA = fY()
    local hB = f8()
    if not hA or not hB then
        return
    end
    local CFrame2 = hB.CFrame
    for k, v in fV(hA) do
        for i, child in v.NPCs:GetChildren() do
            if Library.Unloaded or not Toggles.AutoCollect.Value then
                break
            else
                local HumanoidRootPart = child:FindFirstChild("HumanoidRootPart")
                local hD_1 = HumanoidRootPart and HumanoidRootPart:FindFirstChild("BillboardGui")
                local hE = hD_1
                if hD_1 then
                    hD_1 = hE:GetAttribute("Amount")
                end
                local hE_1 = HumanoidRootPart
                local hF = hD_1
                if hE_1 then
                    hE_1 = hF
                end
                if hE_1 then
                    hE_1 = hF > 0
                end
                if hE_1 then
                    hB.CFrame = CFrame.new(HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                    task.wait(fJ)
                end
            end
        end
    end
    if Toggles.ReturnAfterCollect.Value and hB.Parent then
        hB.CFrame = CFrame2
    end
end
local function onCollectDwell(cM)
    fJ = cM
end
local function onBuyNextFloor()
    task.spawn(autoUpgradeLoop)
end
local function autoMergeLoop2()
    while not Library.Unloaded do
        if Toggles.AutoMerge.Value then
            autoMergeLoop()
        end
        task.wait(0.5)
    end
end
local function autoBuyLoop()
    while not Library.Unloaded do
        if Toggles.AutoBuy.Value then
            fO()
        end
        task.wait(0.5)
    end
end
local function onMergeTarget(db)
    if type(db) == "number" then
        db = gl[db]
    end
    ga = gj[db] or 2
end
local function fn459(ay)
    local hs = {}
    for i, child in ay:GetChildren() do
        if child:FindFirstChild("NPCs") then
            table.insert(hs, child)
        end
    end
    return hs
end
local function onPlaceAllNow()
    task.spawn(autoPlaceLoop)
end
local function autoBuyFloorsLoop()
    while not Library.Unloaded do
        if Toggles.AutoBuyFloors.Value then
            autoUpgradeLoop()
        end
        task.wait(1)
    end
end
local function onBuyAmount(cV)
    fQ = cV
end
local function autoCollectLoop()
    while not Library.Unloaded do
        if Toggles.AutoCollect.Value then
            gn()
        else
            task.wait(0.2)
        end
        task.wait(0.05)
    end
end
local function fn627()
    if setclipboard then
        setclipboard(fZ)
    elseif toclipboard then
        toclipboard(fZ)
    end
    Library:Notify("Discord link copied to clipboard!", 4)
end
local function onMergeCharacters(dl)
    local jZ = {}
    for k, v in dl do
        if v then
            jZ[k] = true
        end
    end
    gm = jZ
end
local function onSelectNone()
    Options.MergeCharacters:SetValue({})
end
local function fn652()
    local iC = DataServiceClient:GetDataValue("Floors")
    local iD = 1
    if type(iC) == "table" then
        for k in iC do
            local iE = tonumber(tostring(k):match("Floor(%d+)"))
            if iE and iE > iD then
                iD = iE
            end
        end
    elseif type(iC) == "number" then
        iD = iC
    end
    return iD
end
autoUpgradeLoop = nil
fJ = nil
fM = nil
fN = nil
fO = nil
fQ = nil
Options = nil
autoPlaceLoop = nil
fU = nil
fV = nil
Toggles = nil
fY = nil
fZ = nil
f0 = nil
autoMergeLoop = nil
f2 = nil
DataServiceClient = nil
Library = nil
f5 = nil
f8 = nil
f9 = nil
ga = nil
LocalPlayer = nil
connection = nil
PlotNetwork = nil
gg = nil
gh = nil
VirtualUser = nil
gj = nil
gk = nil
gl = nil
gm = nil
gn = nil
RebirthNetwork = nil
gq = nil
local NPCKeyShared, ShopNetwork, MergeShared, FloorShared, BuildingShared, fX, f_, f6, MergeNetwork, FloorNetwork, GRID_COUNT, gp, BuildingNetwork
local CommunityGroup2
local gy_1
VirtualUser, LocalPlayer, Library, Toggles, Options, ShopNetwork, BuildingNetwork, RebirthNetwork, PlotNetwork, FloorNetwork, MergeNetwork, DataServiceClient, BuildingShared, FloorShared, MergeShared, NPCKeyShared, gp, gl, gj, GRID_COUNT, f9 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
LocalPlayer = Players.LocalPlayer
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
local Systems = ReplicatedStorage.Modules.Systems
local gt_1
ShopNetwork = require(Systems.Shop.Services.ShopNetwork)
BuildingNetwork = require(Systems.Building.Services.BuildingNetwork)
RebirthNetwork = require(Systems.Rebirth.Services.RebirthNetwork)
require(Systems.AutoCollect.Services.AutoCollectNetwork)
PlotNetwork = require(Systems.Plot.Services.PlotNetwork)
FloorNetwork = require(Systems.Floor.Services.FloorNetwork)
MergeNetwork = require(Systems.Merge.Services.MergeNetwork)
DataServiceClient = require(Systems.Data.Services.DataServiceClient)
local NPCConfig = require(Systems.NPC.Services.NPCConfig)
local RebirthShared = require(Systems.Rebirth.Services.RebirthShared)
local gA_1
BuildingShared = require(Systems.Building.Services.BuildingShared)
FloorShared = require(Systems.Floor.Services.FloorShared)
MergeShared = require(Systems.Merge.Services.MergeShared)
NPCKeyShared = require(Systems.NPC.Services.NPCKeyShared)
gp = { "NPCInventory", "VariantNPCInventory", "CharmedNPCInventory" }
gl = { "Golden", "Diamond" }
gj = { Golden = 1, Diamond = 2 }
GRID_COUNT = BuildingShared.GRID_COUNT
f9 = {}
for k in NPCConfig.NPCs do
    table.insert(f9, k)
end
gt_1, f_, fX = nil, nil, nil
local gs_1 = 3
repeat
    if not fX or not f_ or not f_ and not gt_1 or not fX and f_ and (not gs_1 or gt_1) or not (not fX or not f_ or not f_ and not gt_1 or not fX and f_ and (not gs_1 or gt_1)) then
        table.sort(f9)
        gt_1 = {}
        f_ = {}
        fX = {}
    else
        table.sort(f_)
        fX = {}
        gt_1 = {}
        f9 = {}
    end
    gs_1 = (gs_1 + 0) % 4
until (gs_1 * 1 + 3) % 4 == 2
for k, v in RebirthShared.PERKS do
    local gs_2 = v.Name or v.Id
    table.insert(gt_1, gs_2)
    f_[gs_2] = v.Id
    local gs_3 = v.MaxLevel or math.huge
    fX[gs_2] = gs_3
end
gk, gg = nil, nil
local gv = 0
local gv_1
repeat
    local gs_4 = { "zoz", "vauk", "lbvsffudfhh", "cymjlvfzqkk", "uejpv", "xwt", "nua", "zxhj" }
    local k1 = gv
    local gu_2 = gs_4[k1 % 8 + 1]
    if gu_2:len() <= gu_2:reverse():rep(k1 % 3 + 2):len() then
        table.sort(gt_1)
        gk = {}
        gg = {}
    else
        table.sort(gg)
        gt_1 = {}
        gk = {}
    end
    gv = (gv + 2) % 4
until (gv * 3 + 1) % 4 == 3
for i, v in ipairs(RebirthShared.REBIRTH_OPTIONS) do
    local gs_5 = v.Label or tostring(i)
    table.insert(gk, gs_5)
    gg[gs_5] = i
end
fZ, fU, fQ, fM, fJ, gq, gm = nil, nil, nil, nil, nil, nil, nil
fZ = "https://discord.gg/K7Qxnxkk46"
fU = {}
fQ = 1
fM = {}
fJ = 0.08
gq = 1
gm = {}
for k, v in f9 do
    gm[v] = true
end
ga, f5, f2, f0, gv_1, gy_1, CommunityGroup2, gA_1, connection, fY, f8, fV, gn, fO, autoPlaceLoop, f6, autoUpgradeLoop, autoMergeLoop, gh, fN = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
ga = 2
f5 = 0
f2 = true
fY = fn3
f8 = fn283
fV = fn459
gn = fn425
fO = function()
    for k in fU do
        local hY = k
        local hT = Library.Unloaded
        local h0 = if hT then 1 else 0
        local hZ = 361 * h0 + 2667 * (1 - h0)
        local h_ = 1957 * h0 + 1228 * (1 - h0)
        if not ((hZ * 2400 + h_ * 2923 + hZ * h_) % 16777213 == 7293188) then
            hT = not Toggles.AutoBuy.Value
        end
        if hT then
            break
        end
        pcall(function()
            ShopNetwork.Remotes.BuyNPC:InvokeServer(hY, fQ)
        end)
        task.wait(0.1)
    end
end
autoPlaceLoop = function()
    local h9_1
    local h2 = fY()
    if not h2 then
        return
    end
    local Data = DataServiceClient:GetReplica().Data
    local NPCInventory = Data.NPCInventory
    local PlacedNPCs = Data.PlacedNPCs
    if not NPCInventory then
        return
    end
    local h3_1 = fV(h2)
    if #h3_1 == 0 then
        return
    end
    local ie = false
    for k, v in NPCInventory do
        local ih = k
        local ic = 13
        while true do
            if ic < 7 then
                if ic < 3 then
                    if ic < 1 then
                        ic = if h2 then 3 else 6
                    elseif ic < 2 then
                        ic = 10
                    else
                        local h4_1 = false
                        for k, v in h3_1 do
                            local Name = v.Name
                            local h6 = PlacedNPCs[Name]
                            for i = 1, GRID_COUNT do
                                local iu = i
                                for i = 1, GRID_COUNT do
                                    local iy = i
                                    local h7 = BuildingShared.GridKey(iu, iy)
                                    local h8 = h6 and h6[h7]
                                    local h8_1
                                    if not h8 then
                                        h8_1, h9_1 = pcall(function()
                                            return BuildingNetwork.Remotes.PlaceNPC:InvokeServer(ih, Name, iu, iy, 0)
                                        end)
                                        if h8_1 and h9_1 then
                                            if not PlacedNPCs[Name] then
                                                PlacedNPCs[Name] = {}
                                            end
                                            PlacedNPCs[Name][h7] = true
                                            h4_1 = true
                                            break
                                        end
                                    end
                                end
                                if h4_1 then
                                    break
                                end
                            end
                            if h4_1 then
                                break
                            end
                        end
                        local iB = if not h4_1 then 1 else 0
                        local iz = 565 * iB + 1410 * (1 - iB)
                        local iA = 581 * iB + 3548 * (1 - iB)
                        ic = if (iz * 2695 + iA * 3636 + iz * iA) % 16777213 == 3963456 then 14 else 12
                    end
                elseif ic < 5 then
                    if ic < 4 then
                        ic = 8
                    else
                        ic = 1
                    end
                elseif ic < 6 then
                    ic = if h2 > 0 then 2 else 4
                else
                    h2 = v
                    ic = 7
                end
            elseif ic < 11 then
                if ic < 9 then
                    if ic < 8 then
                        ic = 5
                    else
                        ie = true
                        ic = 10
                    end
                elseif ic < 10 then
                    ic = 7
                else
                    break
                end
            elseif ic < 13 then
                if ic < 12 then
                    h2 = not Toggles.AutoPlace.Value
                    ic = 0
                else
                    h2 -= 1
                    task.wait(0.1)
                    ic = 9
                end
            elseif ic < 14 then
                h2 = Library.Unloaded
                ic = if h2 then 0 else 11
            else
                ic = 1
            end
        end
        if ie then
            break
        end
    end
end
f6 = fn652
autoUpgradeLoop = function()
    local iL = f6() + 1
    if iL <= FloorShared.MAX_FLOORS then
        pcall(function()
            FloorNetwork.Remotes.BuyFloor:InvokeServer(iL)
        end)
    end
end
autoMergeLoop = function()
    local Data = DataServiceClient:GetReplica().Data
    for k, v in gp do
        local iS = Data[v]
        local iS_7
        if iS then
            for k, v in iS do
                if Library.Unloaded or not Toggles.AutoMerge.Value then
                    return
                end
                local iS_2 = NPCKeyShared.Parse(k)
                local iT = MergeShared.GetNextVariant(iS_2.Variant)
                local iU = iT and MergeShared.GetOrder(iT) <= ga
                local iV_2
                if gm[iS_2.NpcId] and iU then
                    local iS_3 = MergeShared.MERGE_RULES[iT]
                    local iS_4 = iS_3 and iS_3.Price or 0
                    local iT_2 = v
                    local jb = false
                    repeat
                        local iQ
                        if iT_2 - f5 >= MergeShared.MERGE_COUNT then
                            local iS_5 = f2
                            if iS_5 then
                                local iV_1 = DataServiceClient:GetDataValue("Gems") or 0
                                iS_5 = iV_1 < iS_4
                            end
                            if iS_5 then
                                jb = true
                            else
                                iQ = {}
                                local MERGE_COUNT = MergeShared.MERGE_COUNT
                                local jh = 1
                                while jh <= MERGE_COUNT do
                                    table.insert(iQ, k)
                                    jh += 1
                                end
                                iS_7, iV_2 = pcall(function()
                                    return MergeNetwork.Remotes.Merge:InvokeServer(iQ)
                                end)
                                if not (iS_7 and iV_2 == true) then
                                    jb = true
                                else
                                    iT_2 -= MergeShared.MERGE_COUNT
                                    task.wait(0.15)
                                end
                            end
                        else
                            jb = true
                        end
                    until jb
                end
            end
        end
    end
end
gh = fn149
local gs_6 = fn627
if (not gv_1 or gy_1) and (not gy_1 or not gn) and (not gv_1 or gn or (gv_1 or not gv_1)) or not gn and not gv_1 and (not gv_1 or false) and ((false or not gy_1) and (false and not gn)) or not ((not gv_1 or gy_1) and (not gy_1 or not gn) and (not gv_1 or gn or (gv_1 or not gv_1)) or not gn and not gv_1 and (not gv_1 or false) and ((false or not gy_1) and (false and not gn))) then
    fN = function()
        for k in fM do
            if Library.Unloaded or not Toggles.AutoUpgrade.Value then
                break
            else
                local jo = f_[k]
                if jo then
                    local jp_3 = DataServiceClient:GetDataValue(jo .. "Level") or 0
                    if jp_3 < (fX[k] or math.huge) then
                        pcall(function()
                            RebirthNetwork.Remotes.BuyPerk:InvokeServer(jo)
                        end)
                        task.wait(0.1)
                    end
                end
            end
        end
    end
else
    autoUpgradeLoop = function()
        for k in fM do
            if Library.Unloaded or not Toggles.AutoUpgrade.Value then
                break
            else
                local jo = f_[k]
                if jo then
                    local jp_1 = DataServiceClient:GetDataValue(jo .. "Level") or 0
                    if jp_1 < (fX[k] or math.huge) then
                        pcall(function()
                            RebirthNetwork.Remotes.BuyPerk:InvokeServer(jo)
                        end)
                        task.wait(0.1)
                    end
                end
            end
        end
    end
end
local Window = Library:CreateWindow({
    Title = "Become a Billionaire",
    Footer = "Tempo Hub",
    Icon = 18657887261,
    NotifySide = "Right",
    Size = UDim2.fromOffset(920, 680)
})
local gE = {
    Main = Window:AddTab("Main", "dollar-sign"),
    Merge = Window:AddTab("Merge", "combine"),
    Settings = Window:AddTab("Settings", "settings")
}
local CollectMoneyGroup = gE.Main:AddLeftGroupbox("Collect Money", "hand-coins")
CollectMoneyGroup:AddToggle("AutoCollect", { Text = "Auto Collect Money", Default = false })
CollectMoneyGroup:AddToggle("ReturnAfterCollect", { Text = "Return To Start After Collect", Default = true })
CollectMoneyGroup:AddSlider("CollectDwell", {
    Text = "Collect Dwell",
    Default = 0.08,
    Min = 0.03,
    Max = 0.3,
    Rounding = 2,
    Suffix = "s",
    Callback = onCollectDwell
})
CollectMoneyGroup:AddButton("Collect Now", onCollectNow)
local BuyCharactersGroup = gE.Main:AddRightGroupbox("Buy Characters", "shopping-cart")
BuyCharactersGroup:AddToggle("AutoBuy", { Text = "Auto Buy Characters", Default = false })
BuyCharactersGroup:AddDropdown("BuyCharacters", { Text = "Characters", Values = f9, Default = {}, Multi = true, Callback = onBuyCharacters })
BuyCharactersGroup:AddSlider("BuyAmount", { Text = "Buy Amount", Default = 1, Min = 1, Max = 50, Rounding = 0, Callback = onBuyAmount })
local PlaceCharactersGroup = gE.Main:AddLeftGroupbox("Place Characters", "layout-grid")
PlaceCharactersGroup:AddToggle("AutoPlace", { Text = "Auto Place Characters", Default = false })
PlaceCharactersGroup:AddButton("Place All Now", onPlaceAllNow)
local FloorsGroup = gE.Main:AddLeftGroupbox("Floors", "building")
FloorsGroup:AddToggle("AutoBuyFloors", { Text = "Auto Buy Floors", Default = false })
FloorsGroup:AddButton("Buy Next Floor", onBuyNextFloor)
local RebirthUpgradesGroup = gE.Main:AddRightGroupbox("Rebirth Upgrades", "trending-up")
RebirthUpgradesGroup:AddToggle("AutoUpgrade", { Text = "Auto Purchase Upgrades", Default = false })
RebirthUpgradesGroup:AddDropdown("UpgradeSelection", { Text = "Upgrades", Values = gt_1, Default = {}, Multi = true, Callback = onUpgradeSelection })
RebirthUpgradesGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
RebirthUpgradesGroup:AddDropdown("RebirthAmount", { Text = "Rebirth Amount", Values = gk, Default = 1, Multi = false, Callback = onRebirthAmount })
local AutoMergeGroup = gE.Merge:AddLeftGroupbox("Auto Merge", "combine")
AutoMergeGroup:AddToggle("AutoMerge", { Text = "Auto Merge", Default = false })
AutoMergeGroup:AddDropdown("MergeTarget", { Text = "Merge Up To", Values = gl, Default = 2, Multi = false, Callback = onMergeTarget })
AutoMergeGroup:AddSlider("MergeKeep", { Text = "Keep Per Stack", Default = 0, Min = 0, Max = 50, Rounding = 0, Callback = onMergeKeep })
AutoMergeGroup:AddToggle("MergeOnlyIfGems", { Text = "Only Merge If Enough Gems", Default = true, Callback = onMergeOnlyIfGems })
AutoMergeGroup:AddButton("Merge Now", onMergeNow)
local MergeCharactersGroup = gE.Merge:AddRightGroupbox("Merge Characters", "users")
MergeCharactersGroup:AddDropdown("MergeCharacters", { Text = "Characters", Values = f9, Default = f9, Multi = true, Callback = onMergeCharacters })
MergeCharactersGroup:AddButton("Select All", onSelectAll)
MergeCharactersGroup:AddButton("Select None", onSelectNone)
local CommunityGroup = gE.Merge:AddRightGroupbox("Community", "message-circle")
if MergeCharactersGroup and gA_1 and (not RebirthUpgradesGroup or not CommunityGroup) and (MergeCharactersGroup and MergeCharactersGroup or (f8 or not gA_1)) or (gA_1 and CommunityGroup and (not MergeCharactersGroup or CommunityGroup) or (not CommunityGroup and not MergeCharactersGroup or (RebirthUpgradesGroup or f8))) or not (MergeCharactersGroup and gA_1 and (not RebirthUpgradesGroup or not CommunityGroup) and (MergeCharactersGroup and MergeCharactersGroup or (f8 or not gA_1)) or (gA_1 and CommunityGroup and (not MergeCharactersGroup or CommunityGroup) or (not CommunityGroup and not MergeCharactersGroup or (RebirthUpgradesGroup or f8)))) then
    CommunityGroup:AddButton("Join Discord for Dupe", gs_6)
    CommunityGroup2 = gE.Main:AddRightGroupbox("Community", "message-circle")
else
    gE:AddButton("Join Discord for Dupe", CommunityGroup)
    gs_6 = CommunityGroup2.Main:AddRightGroupbox("Community", "message-circle")
end
CommunityGroup2:AddButton("Join Discord for Dupe", gs_6)
local MenuGroup = gE.Settings:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddButton("Join Discord for Dupe", gs_6)
MenuGroup:AddLabel("UI Keybind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "UI Keybind" })
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true, Callback = onAntiAfk })
MenuGroup:AddButton("Unload", onUnload)
Library.ToggleKeybind = Options.MenuKeybind
Library:OnUnload(fn231)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Mint")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/BecomeABillionaire")
SaveManager:BuildConfigSection(gE.Settings)
ThemeManager:ApplyToTab(gE.Settings)
ThemeManager:LoadDefault()
SaveManager:LoadAutoloadConfig()
task.spawn(autoCollectLoop)
task.spawn(autoBuyLoop)
task.spawn(autoPlaceLoop2)
task.spawn(autoUpgradeLoop2)
task.spawn(autoRebirthLoop)
task.spawn(autoBuyFloorsLoop)
task.spawn(autoMergeLoop2)
end)(...)

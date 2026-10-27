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
getgenv().TempoHoodSubtitle = "COWBOY DUELS"
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
local lZ
local kZ
local CurrentCamera2
local ln
local l4
local Options
local lM
local lt
local Toggles
local lS
local kS
local connection2
local EventCoinRound
local VirtualUser
local ToxicWheelSpin
local LocalPlayer
local lm
local l3
local EventSetPurchase
local folder
local ls
local EventChestPurchase
local lR
local kR
local ly
local lf
local lX
local kX
local lE
local ll
local UserInputService
local k2
local lK
local worker
local k8
local lQ
local lx
local le
local kW
local lD
local l1
local k1
local lJ
local l7
local k7
local lP
local lw
local SaveManager
local lV
local kV
local lC
local lj
local l0
local k0
local lI
local lp
local l6
local k6
local lv
local ChestCashPurchase
local lU
local lB
local li
local l_
local ToxicWheelGetState
local lH
local lo
local l5
local k5
local connection
local Label
local lb
local lT
local kT
local lA
local lh
function fns.fn10(ah, ai, aj)
    return string.format("<b>%s</b> %s %s", ah, l3("-", "#5a6070"), l3(ai, aj))
end
function fns.fn23()
    if not Toggles.Fly.Value then
        local q2 = ln()
        if q2 then
            q2.PlatformStand = false
        end
    end
end
function fns.fn28(cK)
    if cK == LocalPlayer then
        return false
    elseif LocalPlayer:GetAttribute("DuelInGame") ~= true then
        return false
    else
        local oB = if LocalPlayer:GetAttribute("DuelCombatActive") ~= true then 1 else 0
        if oB == 1 then
            return false
        elseif LocalPlayer:GetAttribute("DuelDeadSpectating") == true then
            return false
        else
            local attr4 = LocalPlayer:GetAttribute("DuelSessionId")
            local attr3 = cK:GetAttribute("DuelSessionId")
            local ow = attr4 == nil or attr3 == nil
            local ov_1 = attr4 ~= attr3
            local ox = ow
            local oB_1 = if ox then 1 else 0
            local oz = 1851 * oB_1 + 790 * (1 - oB_1)
            local oA = 419 * oB_1 + 91 * (1 - oB_1)
            if not ((oz * 2633 + oA * 726 + oz * oA) % 16777213 == 5953446) then
                ox = ov_1
            end
            if ox then
                return false
            elseif cK:GetAttribute("DuelDeadSpectating") == true then
                return false
            else
                local attr2 = LocalPlayer:GetAttribute("DuelTeam")
                local attr = cK:GetAttribute("DuelTeam")
                if attr2 ~= nil and attr ~= nil and attr2 == attr then
                    return false
                end
                return lS(cK.Character)
            end
        end
    end
end
function fns.fn34()
    for k in pairs(lA) do
        lx(k)
    end
end
function fns.onCopyJoinScript_JobID()
    local eR = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, ls)
    k0(eR, "Copied join script to clipboard")
end
function fns.fn51(d4, d5, d6)
    local pM = kT(d4)
    if not pM then
        lx(d4)
        return
    end
    local pN = lA[d4]
    if not pN then
        local highlight = Instance.new("Highlight")
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.65
        highlight.OutlineTransparency = 0
        highlight.Parent = folder
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Size = UDim2.fromOffset(160, 18)
        billboardGui.StudsOffset = Vector3.new(0, 2.4, 0)
        billboardGui.AlwaysOnTop = true
        billboardGui.Parent = folder
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.fromScale(1, 1)
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 13
        textLabel.TextStrokeTransparency = 0.4
        textLabel.Parent = billboardGui
        pN = { Highlight = highlight, Billboard = billboardGui, Label = textLabel }
        lA[d4] = pN
    end
    pN.Highlight.Adornee = d4
    pN.Highlight.FillColor = d5
    pN.Highlight.OutlineColor = d5
    pN.Billboard.Adornee = pM
    pN.Label.TextColor3 = d5
    pN.Label.Text = d6
end
function fns.fn52()
    local m5 = lt()
    local m6 = m5 and m5:FindFirstChildOfClass("Humanoid")
    return m6
end
local function fn54()
    local oW = if not l0("Aimbot") then 1 else 0
    if oW == 1 then
        return
    end
    local oR = lf()
    if not oR then
        return
    end
    local CurrentCamera = lJ.CurrentCamera
    if not CurrentCamera then
        return
    end
    CurrentCamera.CFrame = CFrame.new(CurrentCamera.CFrame.Position, oR.Position)
end
local function onCopyUSDTAddress()
    k0(le, "Copied USDT address")
end
local function fn87(aY)
    local nb = aY
    if nb then
        local nc = aY:FindFirstChild("Head") or aY:FindFirstChild("HumanoidRootPart")
        nb = nc
    end
    return nb
end
local function fn100()
    local oj_1
    local oi_1
    oi_1, oj_1 = pcall(function()
        return ToxicWheelGetState:InvokeServer()
    end)
    local ol = not oi_1 or type(oj_1) ~= "table" or oj_1.success ~= true
    if ol then
        return
    end
    if oj_1.active == false then
        return
    end
    local max = math.max
    local floor = math.floor
    local om = tonumber(oj_1.spins) or 0
    local oj_2 = max(0, floor(om))
    if oj_2 < 1 then
        return
    end
    pcall(function()
        return ToxicWheelSpin:InvokeServer(1)
    end)
end
local function onRscripts()
    k0(ly, "Copied Rscripts profile to clipboard")
end
local function onCopyLitecoinAddress()
    k0(lp, "Copied Litecoin address")
end
local function antiAfkLoop()
    while not ll.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local qC = tick() - k8
            local qD = tick() - k2
            if qC >= 300 and qD >= 60 then
                pcall(l7)
            else
                if qC < 300 and qD >= 300 then
                    pcall(l7)
                end
            end
        end
    end
end
local function fn155()
    for i, v in ipairs({ lt(), LocalPlayer:FindFirstChild("Backpack") }) do
        if v then
            for i, child in ipairs(v:GetChildren()) do
                if child:IsA("Tool") then
                    local FireRequest = child:FindFirstChild("FireRequest")
                    local o5 = FireRequest and FireRequest:IsA("RemoteEvent")
                    if o5 then
                        return FireRequest
                    end
                end
            end
        end
    end
    return nil
end
local function fn159(aJ)
    local m1 = Options[aJ]
    return m1 and m1.Value or {}
end
local function onExportConfigToClipboard()
    local rT_1
    local rS_1
    rS_1, rT_1 = pcall(lU.JSONEncode, lU, l4())
    if not rS_1 then
        ll:Notify("Failed to encode the config")
        return
    end
    local rS_2 = setclipboard
    local r0 = if rS_2 then 1 else 0
    local rZ = 168 * r0 + 3401 * (1 - r0)
    local r_ = 3105 * r0 + 158 * (1 - r0)
    if not ((rZ * 1556 + r_ * 29 + rZ * r_) % 16777213 == 873093) then
        rS_2 = toclipboard
    end
    local rU = rS_2
    local rS_3 = type(rU) ~= "function" or not pcall(rU, rT_1)
    if rS_3 then
        ll:Notify("Your executor does not support copying to the clipboard")
        return
    end
    ll:Notify("Config copied to clipboard", 6)
end
local function fn169()
    local ShootTarget = Options.ShootTarget
    if not ShootTarget then
        return
    end
    local px = lD()
    local py = table.concat(px, ",")
    if py == kX then
        return
    end
    kX = py
    local Value = ShootTarget.Value
    ShootTarget:SetValues(px)
    local pz = type(Value) == "string" and Value ~= "" and table.find(px, Value)
    if pz then
        ShootTarget:SetValue(Value)
    elseif #px > 0 then
        ShootTarget:SetValue(px[1])
    end
end
local function onPlayerAdded()
    task.defer(kV)
end
local function onCopyBitcoinAddress()
    k0(lm, "Copied Bitcoin address")
end
local function worker3()
    while not ll.Unloaded do
        task.wait(0.15)
        if l0("AutoShoot") then
            pcall(lw)
        end
    end
end
local function worker7()
    while not ll.Unloaded do
        task.wait(1.25)
        if l0("AutoBuyShops") then
            pcall(lC)
        end
    end
end
local function fn270(cf)
    local n8 = l5[cf]
    if n8 == "chest" then
        return ChestCashPurchase:InvokeServer(cf)
    elseif n8 == "eventChest" then
        return EventChestPurchase:InvokeServer(cf)
    elseif n8 == "set" then
        return EventSetPurchase:InvokeServer(cf)
    else
        return nil
    end
end
local function fn282(d0)
    local pH = lA[d0]
    if not pH then
        return
    end
    if pH.Highlight then
        pH.Highlight:Destroy()
    end
    if pH.Billboard then
        pH.Billboard:Destroy()
    end
    lA[d0] = nil
end
local function worker8()
    while not ll.Unloaded do
        task.wait(0.5)
        if l0("AutoCollectEventCoin") then
            pcall(worker)
        end
    end
end
local function fn335()
    if not Toggles.PlayerESP.Value then
        lZ()
    else
        lK()
    end
end
local function onImportConfigFromClipboardTex()
    local r3_1
    local r1 = Options.SaveManager_ImportSource.Value or ""
    local r1_1
    local r2 = tostring(r1):match("^%s*(.-)%s*$")
    if r2 == "" then
        ll:Notify("Paste an exported config into the box first")
        return
    end
    r1_1, r3_1 = pcall(lU.JSONDecode, lU, r2)
    local r2_1 = not r1_1 or type(r3_1) ~= "table" or type(r3_1.objects) ~= "table"
    if r2_1 then
        ll:Notify("That is not a valid exported config")
        return
    end
    local r1_2 = 0
    for i, v in ipairs(r3_1.objects) do
        if lo(v) then
            r1_2 += 1
        end
    end
    if r1_2 == 0 then
        ll:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local r3_2 = r1_2 == 1 and "" or "s"
    ll:Notify(("Imported %d setting%s"):format(r1_2, r3_2), 6)
end
local function fn386(hj, hk)
    local Type = hk.Type
    if Type == "Toggle" then
        return { idx = hj, type = "Toggle", value = hk.Value == true }
    elseif Type == "Slider" then
        return { idx = hj, type = "Slider", value = tostring(hk.Value) }
    elseif Type == "Dropdown" then
        return { idx = hj, type = "Dropdown", multi = hk.Multi == true, value = hk.Value }
    elseif Type == "Input" then
        local rp = hk.Value or ""
        return { idx = hj, type = "Input", text = tostring(rp) }
    elseif Type == "ColorPicker" then
        return { idx = hj, type = "ColorPicker", value = hk.Value:ToHex(), transparency = hk.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = hj,
            type = "KeyPicker",
            mode = hk.Mode,
            key = hk.Value,
            modifiers = hk.Modifiers,
            toggled = hk.Toggled
        }
    else
        return nil
    end
end
local function onInputChanged(fU)
    local UserInputType = fU.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        k8 = tick()
    end
end
local function onCopySolanaAddress()
    k0(lb, "Copied Solana address")
end
local function fn397()
    local nj_1
    local nh_1, nh_2
    local ng = type(getconnections) ~= "function"
    local ng_1
    local nn = if ng then 1 else 0
    local nl = 2401 * nn + 1324 * (1 - nn)
    local nm = 1634 * nn + 1289 * (1 - nn)
    if not ((nl * 1363 + nm * 1489 + nl * nm) % 16777213 == 9628823) then
        ng = type(debug) ~= "table"
    end
    if not ng then
        ng = type(debug.getupvalue) ~= "function"
    end
    if ng then
        return
    end
    ng_1, nh_1 = pcall(getconnections, EventCoinRound.OnClientEvent)
    local ni = not ng_1
    local ni_1
    local nn_1 = if ni then 1 else 0
    local nl_1 = 469 * nn_1 + 2704 * (1 - nn_1)
    local nm_1 = 936 * nn_1 + 1553 * (1 - nn_1)
    if not ((nl_1 * 3692 + nm_1 * 2568 + nl_1 * nm_1) % 16777213 == 4574180) then
        ni = type(nh_1) ~= "table"
    end
    if ni then
        return
    end
    for i, v in ipairs(nh_1) do
        local Function = v.Function
        if type(Function) == "function" then
            local nw = 1
            while nw <= 12 do
                local nx = nw
                nh_2, ni_1, nj_1 = pcall(debug.getupvalue, Function, nx)
                if not nh_2 then
                    break
                end
                if lT(ni_1) then
                    l1 = ni_1
                    return
                end
                if lT(nj_1) then
                    l1 = nj_1
                    return
                end
                nw += 1
            end
        end
    end
end
local function worker5()
    while not ll.Unloaded do
        task.wait(0.2)
        if l0("PlayerESP") then
            pcall(lK)
        end
    end
end
local function worker6()
    while not ll.Unloaded do
        task.wait(2)
        if l0("AutoSpinWheel") then
            pcall(kZ)
        end
    end
end
local function fn413(hd, he)
    local ri_1 = (hd == "Toggle" and Toggles or Options)[he]
    local rh_2 = type(ri_1) == "table" and ri_1.Type == hd
    return rh_2 and ri_1 or nil
end
local function fn431()
    local m8 = lt()
    local m9 = m8 and m8:FindFirstChild("HumanoidRootPart")
    return m9
end
local function onUnload()
    ll:Unload()
end
local function onStepped()
    if ll.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local qG_1 = lt()
        if qG_1 then
            for i, descendant in ipairs(qG_1:GetDescendants()) do
                local qG_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if qG_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn453(X, Y)
    if setclipboard then
        setclipboard(X)
    elseif toclipboard then
        toclipboard(X)
    end
    ll:Notify(Y)
end
local function fn466()
    return LocalPlayer.Character
end
local function fn467()
    local pt = l0("OnlyShootAfterEventCoins") and not l6()
    if pt then
        return false
    end
    local pt_1 = lX()
    if not pt_1 then
        return false
    end
    local pu = kT(pt_1.Character)
    if not pu then
        return false
    end
    local pt_2 = li()
    if not pt_2 then
        return false
    end
    pt_2:FireServer(pu.Position, nil, nil)
    return true
end
local function fn470(fo)
    local DiscordGroup = fo:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = kS })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = kS })
end
local function worker2()
    local qm_1
    while true do
        task.wait(1)
        if ll.Unloaded then
            break
        end
        local ql = math.floor(os.clock() - k5)
        if ql < 60 then
            qm_1 = ql .. "s"
        elseif ql < 3600 then
            qm_1 = string.format("%dm %ds", math.floor((ql) / (60)), ql % 60)
        else
            qm_1 = string.format("%dh %dm", math.floor((ql) / (3600)), math.floor((ql % 3600) / (60)))
        end
        Label:SetText(lR("Session time", qm_1, lv))
    end
end
local function onCopyPayPalLink()
    k0(k6, "Copied PayPal link")
end
local function fn486()
    local CurrentCamera = lJ.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    k2 = tick()
end
local function fn495()
    local ShootTarget = Options.ShootTarget
    local pn = ShootTarget and ShootTarget.Value
    local pn_1 = pn == ""
    local po = type(pn) ~= "string" or pn_1
    if po then
        return nil
    end
    local pn_2 = kR:FindFirstChild(pn)
    local pm_2 = pn_2 and pn_2:IsA("Player")
    if pm_2 then
        return pn_2
    end
    return nil
end
local function onCopyEthereumAddress()
    k0(lh, "Copied Ethereum address")
end
local function onCopyVenmoLink()
    k0(k1, "Copied Venmo link")
end
local function fn513()
    if Toggles.AutoCollectEventCoin.Value then
        lI()
        task.spawn(worker)
    end
end
local function worker4()
    while not ll.Unloaded do
        task.wait(1)
        pcall(kV)
    end
end
local function fn572(aE)
    local mZ = Toggles[aE]
    return mZ ~= nil and mZ.Value == true
end
local function onRenderStepped(gl)
    if ll.Unloaded then
        return
    end
    lV()
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local qT_1 = ln()
        if qT_1 then
            qT_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local qT_3 = k7()
        local qU = ln()
        if qT_3 and qU then
            qU.PlatformStand = true
            local qU_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                qU_1 = qU_1 + CurrentCamera2.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                qU_1 = qU_1 - CurrentCamera2.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                qU_1 = qU_1 - CurrentCamera2.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                qU_1 = qU_1 + CurrentCamera2.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                qU_1 = qU_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                qU_1 = qU_1 - Vector3.new(0, 1, 0)
            end
            qT_3.AssemblyLinearVelocity = Vector3.zero
            if qU_1.Magnitude > 0 then
                qT_3.CFrame = qT_3.CFrame + qU_1.Unit * Options.FlySpeed.Value * gl
            end
        end
    end
end
local function fn606()
    local ry = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local rz = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if rz then
                local rz_1 = kW(k, v)
                if rz_1 then
                    ry[#ry + 1] = rz_1
                end
            end
        end
    end
    table.sort(ry, function(hu, hv)
        if hu.type ~= hv.type then
            return hu.type < hv.type
        end
        return hu.idx < hv.idx
    end)
    return { objects = ry }
end
local function fn631()
    local oC = k7()
    if not oC then
        return nil
    end
    local oD = math.huge
    local oE
    for i, player in ipairs(kR:GetPlayers()) do
        if lE(player) then
            local oF = kT(player.Character)
            if oF then
                local Magnitude = (oF.Position - oC.Position).Magnitude
                if Magnitude < oD then
                    oD = Magnitude
                    oE = oF
                end
            end
        end
    end
    return oE
end
local function fn665()
    local LocalEventCoins = lJ:FindFirstChild("LocalEventCoins")
    local pk = LocalEventCoins and #LocalEventCoins:GetChildren() > 0
    if pk then
        return false
    end
    return true
end
local function fn669(cG)
    if not cG then
        return false
    end
    local Humanoid = cG:FindFirstChildOfClass("Humanoid")
    return Humanoid ~= nil and Humanoid.Health > 0
end
local function fn670()
    local pE = gethui and gethui()
    local pF = pE or lM
    folder.Parent = pF
end
local function fn680(ae, af)
    return string.format('<font color="%s">%s</font>', af, ae)
end
local function fn681()
    lP(Toggles.AntiGameplayPause.Value)
end
local function fn683()
    local oa = lH("ShopBuySelection")
    for k, v in pairs(oa) do
        local oa_1 = ll.Unloaded or not l0("AutoBuyShops")
        if oa_1 then
            return
        end
        if v and l5[k] then
            pcall(l_, k)
            task.wait(0.35)
        end
    end
end
local function onInputBegan()
    k8 = tick()
end
local function fn763()
    if not Toggles.WalkSpeedEnabled.Value then
        local q4 = ln()
        if q4 then
            q4.WalkSpeed = 16
        end
    end
end
local function fn772()
    local oX = {}
    for i, player in ipairs(kR:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(oX, player.Name)
        end
    end
    table.sort(oX)
    return oX
end
local function fn786()
    local p_ = ll.Unloaded or not l0("PlayerESP")
    if p_ then
        lZ()
        return
    end
    local p__1 = {}
    local p0 = Color3.fromRGB(255, 70, 70)
    local p1 = Color3.fromRGB(90, 170, 255)
    for i, player in ipairs(kR:GetPlayers()) do
        local p2 = player ~= LocalPlayer and lS(player.Character)
        if p2 then
            local Character = player.Character
            p__1[Character] = true
            local p3 = lE(player) and p0
            local p3_1 = p3 or p1
            lj(Character, p3_1, player.Name)
        end
    end
    for k in pairs(lA) do
        if not p__1[k] then
            lx(k)
        end
    end
end
local function antiGameplayPauseLoop()
    while not ll.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            lP(true)
        end
    end
end
local function onJumpRequest()
    if ll.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local qO_1 = ln()
        if qO_1 then
            qO_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn856()
    local qh_1
    local qg_1
    if identifyexecutor then
        qh_1, qg_1 = identifyexecutor()
        local qi = qh_1 ~= ""
        local qj = type(qh_1) == "string" and qi
        if qj then
            local qi_1 = type(qg_1) == "string" and qg_1 ~= "" and qh_1 .. " " .. qg_1
            lQ = qi_1 or qh_1
        end
    end
end
local function onPlayerRemoving()
    task.defer(kV)
end
local function fn867(a4)
    local ne = type(a4) == "string" and string.find(a4, ":", 1, true) ~= nil
    return ne
end
local function fn876()
    pcall(function()
        connection:Disconnect()
    end)
    pcall(function()
        connection2:Disconnect()
    end)
    lZ()
    pcall(function()
        folder:Destroy()
    end)
    lP(false)
    local se = ln()
    if se then
        se.PlatformStand = false
        se.WalkSpeed = 16
    end
end
local function fn891()
    k0(lB, "Copied Discord invite to clipboard")
end
kR = nil
kS = nil
kT = nil
kV = nil
kW = nil
kX = nil
ToxicWheelSpin = nil
kZ = nil
ToxicWheelGetState = nil
k0 = nil
k1 = nil
k2 = nil
EventSetPurchase = nil
Options = nil
k5 = nil
k6 = nil
k7 = nil
k8 = nil
EventChestPurchase = nil
Toggles = nil
lb = nil
ChestCashPurchase = nil
SaveManager = nil
le = nil
lf = nil
EventCoinRound = nil
lh = nil
li = nil
lj = nil
ll = nil
lm = nil
ln = nil
lo = nil
lp = nil
worker = nil
ls = nil
lt = nil
Label = nil
lv = nil
lw = nil
lx = nil
ly = nil
connection2 = nil
lA = nil
lB = nil
lC = nil
lD = nil
local kU, EventCoinCollect, lq
lE = nil
LocalPlayer = nil
CurrentCamera2 = nil
lH = nil
lI = nil
lJ = nil
lK = nil
folder = nil
lM = nil
connection = nil
lP = nil
lQ = nil
lR = nil
lS = nil
lT = nil
lU = nil
lV = nil
lX = nil
VirtualUser = nil
lZ = nil
l_ = nil
l0 = nil
l1 = nil
UserInputService = nil
l3 = nil
l4 = nil
l5 = nil
l6 = nil
l7 = nil
local lO, lW, l9, mb, md, me, mp, mq
lO = nil
lW = nil
local mr, ms, mt, mu, mv, mw
kR, UserInputService, VirtualUser, lU, lO, lM, lJ, LocalPlayer, lB, ly, mb, l9, EventCoinCollect, EventCoinRound, ChestCashPurchase, EventChestPurchase, EventSetPurchase, ToxicWheelGetState, ToxicWheelSpin, md, me, l5 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if ("https://discord.gg/K7Qxnxkk46" and (mb and not me) or ly and not me and false) and (not me and ly or not mb and VirtualUser or false and VirtualUser and (not VirtualUser and mb)) or (false or me or (mb or mb) or (me or not VirtualUser or VirtualUser and not me)) and (not VirtualUser and not me and (not me or not mb) and (not mb and me and (not me or me))) or not (("https://discord.gg/K7Qxnxkk46" and (mb and not me) or ly and not me and false) and (not me and ly or not mb and VirtualUser or false and VirtualUser and (not VirtualUser and mb)) or (false or me or (mb or mb) or (me or not VirtualUser or VirtualUser and not me)) and (not VirtualUser and not me and (not me or not mb) and (not mb and me and (not me or me)))) then
    kR = game:GetService("Players")
else
    l5 = game:GetService("Players")
end
local mc = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
if ((UserInputService and l5 or l5 and UserInputService) and (UserInputService or not l5 or not UserInputService and not l5) or (not l5 or not UserInputService) and (not UserInputService and not UserInputService) and (not l5 or UserInputService or not UserInputService and l5)) and not ((UserInputService and l5 or l5 and UserInputService) and (UserInputService or not l5 or not UserInputService and not l5) or (not l5 or not UserInputService) and (not UserInputService and not UserInputService) and (not l5 or UserInputService or not UserInputService and l5)) then
    lM = game:GetService("HttpService")
    lU = game:GetService("GuiService")
    lJ = game:GetService("CoreGui")
    lO = game:GetService("Workspace")
    kR = LocalPlayer.LocalPlayer
else
    lU = game:GetService("HttpService")
    lO = game:GetService("GuiService")
    lM = game:GetService("CoreGui")
    lJ = game:GetService("Workspace")
    LocalPlayer = kR.LocalPlayer
end
local mf = "Cowboy DUELS"
lB = "https://discord.gg/K7Qxnxkk46"
ly = "https://discord.gg/K7Qxnxkk46"
mb = mc:WaitForChild("Shared")
local ma = mb:WaitForChild("Remotes")
if md or md or false or false and not md and (not md or md) or not (md or md or false or false and not md and (not md or md)) then
    l9 = mb:WaitForChild("Config")
else
    l9:WaitForChild("Config")
end
if not me and not VirtualUser or not EventChestPurchase and LocalPlayer or (ma or LocalPlayer or ma and VirtualUser) or not (not me and not VirtualUser or not EventChestPurchase and LocalPlayer or (ma or LocalPlayer or ma and VirtualUser)) then
    EventCoinCollect = ma:WaitForChild("EventCoinCollect")
else
    ma = EventCoinCollect:WaitForChild("EventCoinCollect")
end
EventCoinRound = ma:WaitForChild("EventCoinRound")
ChestCashPurchase = ma:WaitForChild("ChestCashPurchase")
EventChestPurchase = ma:WaitForChild("EventChestPurchase")
EventSetPurchase = ma:WaitForChild("EventSetPurchase")
ToxicWheelGetState = ma:WaitForChild("ToxicWheelGetState")
ToxicWheelSpin = ma:WaitForChild("ToxicWheelSpin")
md = require(l9:WaitForChild("ChestConfig"))
me = require(l9:WaitForChild("Event"))
local mg = {}
l5 = {}
local sj_3 = {}
l9 = md.Order or sj_3
for i, v in ipairs(l9) do
    sj_3 = type(v) == "string" and v ~= "" and not l5[v]
    if sj_3 then
        table.insert(mg, v)
        l5[v] = "chest"
    end
end
sj_3 = {}
l9 = me.ShopChests or sj_3
for i, v in ipairs(l9) do
    sj_3 = v and v.chestName
    l9 = sj_3
    sj_3 = type(l9) == "string" and l9 ~= "" and not l5[l9]
    if sj_3 then
        table.insert(mg, l9)
        l5[l9] = "eventChest"
    end
end
sj_3 = {}
l9 = me.ShopSets or sj_3
for i, v in ipairs(l9) do
    sj_3 = v and v.setName
    l9 = sj_3
    sj_3 = type(l9) == "string" and l9 ~= "" and not l5[l9]
    if sj_3 then
        table.insert(mg, l9)
        l5[l9] = "set"
    end
end
ll, SaveManager, Toggles, Options, lv, lp, lm, lh, le, lb, k6, k1, l1, lW, kX, folder, k0, kS, l3, lR, l0, lH, lt, ln, k7, kT, lT, lI, kU, worker, l_, lC, kZ, lS, lE, lf, lV, lD, li, l6, lX, lw, kV = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
sj_3 = ""
ll = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = ll.Toggles
Options = ll.Options
k0 = fn453
kS = fn891
l3 = fn680
lR = fns.fn10
local mk = "#7fd47f"
local mj = "#6ec1ff"
lv = "#e8a34d"
local mi = "#8b93a3"
lp = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
lm = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
lh = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
le = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
lb = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
k6 = ""
k1 = ""
me = "#345d9d"
md = "#f7931a"
mc = "#627eea"
mb = "#26a17b"
local mn = "#14f195"
local mm = "#0070ba"
local ml = "#008cff"
l0 = fn572
lH = fn159
lt = fn466
ln = fns.fn52
k7 = fn431
kT = fn87
if ((lC or false or "") and (false and (not lC and false)) and (("LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w" or (worker or lC)) and (lC and lp or (sj_3 or not lC))) or ((not lC or worker or (not lC or lC)) and (false and (sj_3 and lC)) or "" and (not lC or lp) and (worker and worker or (false or not lC)))) and not ((lC or false or "") and (false and (not lC and false)) and (("LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w" or (worker or lC)) and (lC and lp or (sj_3 or not lC))) or ((not lC or worker or (not lC or lC)) and (false and (sj_3 and lC)) or "" and (not lC or lp) and (worker and worker or (false or not lC)))) then
    lT = nil
    l1 = {}
    lW = fn867
else
    l1 = nil
    lW = {}
    lT = fn867
end
lI = fn397
kU = function(bm, bn, bo)
    local nz
    local nB_1
    if not lT(bm) then
        return false
    end
    nz = tostring(bn)
    local nA = nz == "" or lW[nz]
    local nA_2
    if nA then
        return false
    end
    local nA_1 = k7()
    if not nA_1 then
        return false
    end
    if typeof(bo) == "Vector3" then
        nA_1.CFrame = CFrame.new(bo + Vector3.new(0, 3, 0))
        task.wait(0.12)
    end
    nA_2, nB_1 = pcall(function()
        return EventCoinCollect:InvokeServer(bm, nz)
    end)
    if nA_2 and nB_1 == true then
        lW[nz] = true
        return true
    end
    return false
end
worker = function()
    if not lT(l1) then
        lI()
    end
    if not lT(l1) then
        return
    end
    local LocalEventCoins = lJ:FindFirstChild("LocalEventCoins")
    if not LocalEventCoins then
        return
    end
    for i, child in ipairs(LocalEventCoins:GetChildren()) do
        local nT = child
        local nL_1 = ll.Unloaded or not l0("AutoCollectEventCoin")
        if nL_1 then
            return
        end
        local nL_2 = string.match(nT.Name, "^EventCoin_(.+)$")
        local nM = nL_2 and not lW[nL_2] and nT:GetAttribute("Collecting") ~= true
        if nM then
            local Position = nT:GetPivot().Position
            if kU(l1, nL_2, Position) then
                pcall(function()
                    nT:Destroy()
                end)
            end
            task.wait(0.08)
        end
    end
end
EventCoinRound.OnClientEvent:Connect(function(bS)
    if typeof(bS) ~= "table" then
        return
    end
    local action = bS.action
    if action == "clear" then
        l1 = nil
        table.clear(lW)
        return
    end
    if lT(bS.roundKey) then
        if action == "spawn" then
            table.clear(lW)
        end
        l1 = bS.roundKey
    end
    if not l0("AutoCollectEventCoin") then
        return
    end
    if typeof(bS.coins) ~= "table" then
        return
    end
    task.spawn(function()
        for i, v in ipairs(bS.coins) do
            local nV = ll.Unloaded or not l0("AutoCollectEventCoin")
            if nV then
                break
            end
            local nV_1 = typeof(v) == "table" and v.id ~= nil
            if nV_1 then
                if kU(l1, v.id, v.position) then
                    local LocalEventCoins = lJ:FindFirstChild("LocalEventCoins")
                    local nW = LocalEventCoins and LocalEventCoins:FindFirstChild("EventCoin_" .. tostring(v.id))
                    local nU = nW
                    if nU then
                        pcall(function()
                            nU:Destroy()
                        end)
                    end
                end
                task.wait(0.08)
            end
        end
    end)
end)
l_ = fn270
lC = fn683
kZ = fn100
lS = fn669
lE = fns.fn28
lf = fn631
lV = fn54
lD = fn772
li = fn155
l6 = fn665
lX = fn495
lw = fn467
kX = ""
kV = fn169
folder = Instance.new("Folder")
folder.Name = "TempoEsp"
pcall(fn670)
if not folder.Parent then
    folder.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
lA, ma, mr, lQ, mq, Label, ls, mp, lx, lj, lZ, lK = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
sj_3 = 7
repeat
    ms = (sj_3 * 2 + 6) % 7 + 1
    if ms <= 4 then
        if ms <= 2 then
            if ms <= 1 then
                mt = (vector.create((sj_3 * 5 + 3) % 11 + 1, (sj_3 * 5 + 8) % 13 + 1, (sj_3 * 14 + 3) % 17 + 1))
                mu = (vector.create((sj_3 * 4 + 7) % 11 + 1, (sj_3 * 5 + 1) % 13 + 1, (sj_3 * 14 + 17) % 17 + 1))
                mv = (vector.create((sj_3 * 5 + 6) % 11 + 1, (sj_3 * 1 + 3) % 13 + 1, (sj_3 * 13 + 13) % 17 + 1))
                if vector.dot(vector.cross(mt, mu), mv) == vector.dot(vector.cross(mu, mv), mt) then
                    lK = fn786
                else
                    lZ = fn786
                end
                sj_3 = (sj_3 + 32) % 56
            else
                if sj_3 * 31422247 + 7 + 6 >= sj_3 * 31422247 + 7 + 6 + 6 then
                    ll = lB:CreateWindow({
                        Icon = 12645376577,
                        CornerRadius = 10,
                        NotifySide = "Right",
                        Title = "Tempo Hub",
                        Footer = { "|", ma, { Text = mf, Copyable = true } },
                        ShowCustomCursor = false
                    })
                else
                    ma = ll:CreateWindow({
                        Title = "Tempo Hub",
                        Footer = { { Text = lB, Copyable = true }, "|", mf },
                        Icon = 12645376577,
                        NotifySide = "Right",
                        ShowCustomCursor = false,
                        CornerRadius = 10
                    })
                end
                sj_3 = (sj_3 + 11) % 56
            end
        elseif ms <= 3 then
            mt = {
                "dtfriyybdh",
                "imnieyplumef",
                "yvrshzwwzl",
                "mbe",
                "vlfxkn",
                "cig",
                "mnp",
                "uwktcpaawxpa",
                "zbffqmhgqga",
                "sccnjmkok",
                "nlmxxqahbl"
            }
            if mt[(sj_3 * 76 + 13) % 11 + 1] < mt[(sj_3 * 76 + 13) % 11 + 1] then
                ma = {
                    Main = mr:AddTab("Main", "swords"),
                    Info = mr:AddTab("Info", "info"),
                    Settings = mr:AddTab("Settings", "settings"),
                    Player = mr:AddTab("Player", "person-standing")
                }
            else
                mr = {
                    Info = ma:AddTab("Info", "info"),
                    Main = ma:AddTab("Main", "swords"),
                    Player = ma:AddTab("Player", "person-standing"),
                    Settings = ma:AddTab("Settings", "settings")
                }
            end
            sj_3 = (sj_3 + 39) % 56
        else
            mt = (vector.create((sj_3 * 3 + 8) % 11 + 1, (sj_3 * 9 + 8) % 13 + 1, (sj_3 * 1 + 9) % 17 + 1))
            mu = (vector.create((sj_3 * 4 + 9) % 11 + 1, (sj_3 * 11 + 12) % 13 + 1, (sj_3 * 7 + 8) % 17 + 1))
            mv = (vector.create((sj_3 * 4 + 2) % 11 + 1, (sj_3 * 3 + 1) % 13 + 1, (sj_3 * 9 + 4) % 17 + 1))
            mw = (vector.create((sj_3 * 5 + 1) % 5 + 1, (sj_3 * 1 + 4) % 7 + 1, (sj_3 * 3 + 4) % 9 + 1))
            if vector.dot(vector.cross(mt, (vector.cross(mu, mv))), mw) == vector.dot(mu * vector.dot(mt, mv) - mv * vector.dot(mt, mu), mw) + 4 then
                pcall(fn856)
                l3 = Label.Info:AddLeftGroupbox("Account", "circle-user")
                l3:AddLabel(lv("User", mq.Name, mf), true)
                l3:AddLabel(lv("Status", "Keyless", mf), true)
                l3:AddLabel(lv("Executor", "Unknown", mf), true)
                mk = Label.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                mk:AddLabel(mr(lQ .. " [" .. tostring(game.PlaceId) .. "]", lR), true)
                mk:AddLabel(lv("Place ID", tostring(game.PlaceId), lR), true)
                mj = mk:AddLabel(lv("Session time", "0s", LocalPlayer), true)
            else
                lQ = "Unknown"
                pcall(fn856)
                l9 = mr.Info:AddLeftGroupbox("Account", "circle-user")
                l9:AddLabel(lR("User", LocalPlayer.Name, mk), true)
                l9:AddLabel(lR("Status", "Keyless", mk), true)
                l9:AddLabel(lR("Executor", lQ, mk), true)
                mq = mr.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                mq:AddLabel(l3(mf .. " [" .. tostring(game.PlaceId) .. "]", mj), true)
                mq:AddLabel(lR("Place ID", tostring(game.PlaceId), mj), true)
                Label = mq:AddLabel(lR("Session time", "0s", lv), true)
            end
            sj_3 = (sj_3 + 18) % 56
        end
    elseif ms <= 6 then
        if ms <= 5 then
            if (sj_3 * 2 + 5) * 16 % 3 == ((sj_3 * 2 + 5) * 16 + 0) % 3 then
                ls = tostring(game.JobId)
            else
                mq = tostring(game.JobId)
            end
            sj_3 = (sj_3 + 39) % 56
        else
            ms = (vector.create((sj_3 * 2 + 5) % 11 + 1, (sj_3 * 10 + 9) % 13 + 1, (sj_3 * 3 + 10) % 17 + 1))
            mt = (vector.create((sj_3 * 5 + 7) % 11 + 1, (sj_3 * 3 + 7) % 13 + 1, (sj_3 * 15 + 8) % 17 + 1))
            local sW = vector.cross(ms, mt)
            local sX = vector.dot(ms, mt)
            if vector.dot(sW, sW) + sX * sX == vector.dot(ms, ms) * vector.dot(mt, mt) then
                mp = #ls > 18
            else
                ls = #mp > 18
            end
            sj_3 = (sj_3 + 18) % 56
        end
    else
        if (lK and not lx or lx and not lx or (not lK and lK or lK and not lK) or (not lx or not lK or (not lx or not lx) or (not lK or not Label) and (Label or not lx))) and not (lK and not lx or lx and not lx or (not lK and lK or lK and not lK) or (not lx or not lK or (not lx or not lx) or (not lK or not Label) and (Label or not lx))) then
            lx = {}
            lZ = fn282
            lA = fns.fn51
            lj = fns.fn34
        else
            lA = {}
            lx = fn282
            lj = fns.fn51
            lZ = fns.fn34
        end
        sj_3 = (sj_3 + 11) % 56
    end
until (sj_3 * 5 + 38) % 56 == 17
if mp then
    sj_3 = 0
    repeat
        if (sj_3 * 1 + 9) * 13 % 4 == ((sj_3 * 1 + 9) * 13 + 13) % 4 then
            ls = string.sub(mp, 1, 18) .. "..."
        else
            mp = string.sub(ls, 1, 18) .. "..."
        end
        sj_3 = (sj_3 + 2) % 4
    until (sj_3 * 3 + 2) % 4 == 0
end
sj_3 = mp or ls
k5 = nil
ma = sj_3
mq:AddLabel(lR("Server", ma, mi), true)
mq:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
k5 = os.clock()
task.spawn(worker2)
mw = mr.Info:AddRightGroupbox("Scripts", "package")
mw:AddLabel(l3("Included in this hub", mi), true)
mw:AddLabel(l3(mf, mj), true)
mv = mr.Info:AddRightGroupbox("Features", "list")
mv:AddLabel(l3("Auto Collect", lv), true)
mv:AddLabel(l3("Auto Buy", mj), true)
mv:AddLabel(l3("Auto Spin", mk), true)
mv:AddLabel(l3("Combat", lv), true)
mv:AddLabel(l3("ESP", mj), true)
mv:AddLabel(l3("Player Utilities", mi), true)
mu = mr.Info:AddRightGroupbox("Socials", "link")
mu:AddButton({ Text = "Discord", Func = kS })
mu:AddButton({ Text = "Rscripts", Func = onRscripts })
ms = mr.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
ms:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
ms:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
ms:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
ms:AddButton({ Text = "Copy Discord Invite", Func = kS })
mp = mr.Info:AddRightGroupbox("Donations", "heart")
mp:AddLabel(l3("All donations are optional but appreciated.", lv), true)
mp:AddLabel(l3("If you donate you get a special role, just PING after you donate.", mk), true)
mp:AddDivider()
mp:AddLabel(l3("LTC / Litecoin", me), true)
mp:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
mp:AddLabel(l3("BTC / Bitcoin", md), true)
mp:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
mp:AddLabel(l3("ETH / Ethereum", mc), true)
mp:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
mp:AddLabel(l3("USDT", mb), true)
mp:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
mp:AddLabel(l3("Solana", mn), true)
mp:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
mp:AddLabel(l3("PayPal", mm), true)
mp:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
mp:AddLabel(l3("Venmo", ml), true)
mp:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
mp:AddDivider()
mp:AddLabel(l3("Don't have any of the listed currencies but still wanna donate?", mi), true)
mp:AddLabel(l3("DM me and we'll work something out.", mj), true)
l9 = mr.Info:AddRightGroupbox("FAQ", "circle-help")
l9:AddLabel("Where do I get a good config?", true)
l9:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
l9:AddLabel("How do I import / export configs?", true)
l9:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
l9:AddLabel("How do I report bugs?", true)
l9:AddLabel("Join the Discord and post it in the bugs channel.", true)
l9:AddLabel("How do I make suggestions?", true)
l9:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
l9:AddLabel("How do I get help or updates?", true)
l9:AddLabel("Join the Discord, updates and support are posted there first.", true)
for k, v in pairs(mr) do
    if v ~= mr.Info then
        fn470(v)
    end
end
me, ma, k8, k2, connection, connection2, CurrentCamera2, l7, lP, lq, kW, l4, lo = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if (not kW and not ma and (not kW or not lq) or (not kW or not kW) and (not kW or not ma)) and not (not kW and not ma and (not kW or not lq) or (not kW or not kW) and (not kW or not ma)) then
    mr = me.Main:AddLeftGroupbox("Automation", "bot")
else
    me = mr.Main:AddLeftGroupbox("Automation", "bot")
end
me:AddToggle("AutoCollectEventCoin", { Text = "Auto Collect Event Coin", Default = false })
me:AddToggle("AutoBuyShops", { Text = "Auto Buy Shops/Crates", Default = false })
me:AddDropdown("ShopBuySelection", {
    Text = "Shop/Crate Selection",
    Values = mg,
    Default = {},
    Multi = true,
    AllowNull = true,
    Searchable = true
})
me:AddToggle("AutoSpinWheel", { Text = "Auto Spin Wheel", Default = false })
Toggles.AutoCollectEventCoin:OnChanged(fn513)
mc = mr.Main:AddRightGroupbox("Combat", "crosshair")
mc:AddToggle("Aimbot", { Text = "Aimbot", Default = false })
mc:AddToggle("AutoShoot", { Text = "Auto Shoot", Default = false })
mc:AddDropdown("ShootTarget", { Text = "Shoot Target", Values = lD(), Default = "", AllowNull = true, Searchable = true })
mc:AddToggle("OnlyShootAfterEventCoins", { Text = "Only Shoot when all Event Coins Collected", Default = false })
mc:AddToggle("PlayerESP", { Text = "Player ESP", Default = false })
Toggles.PlayerESP:OnChanged(fn335)
kR.PlayerAdded:Connect(onPlayerAdded)
kR.PlayerRemoving:Connect(onPlayerRemoving)
task.defer(kV)
ma = mr.Player:AddLeftGroupbox("Movement", "footprints")
ma:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
ma:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
ma:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
ma:AddToggle("NoClip", { Text = "NoClip", Default = false })
ma:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
l9 = mr.Player:AddRightGroupbox("Fly", "feather")
l9:AddToggle("Fly", { Text = "Fly", Default = false })
l9:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
sj_3 = mr.Settings:AddLeftGroupbox("Menu")
sj_3:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
ll.ToggleKeybind = Options.MenuKeybind
sj_3:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
sj_3:AddButton({ Text = "Unload", Func = onUnload })
k8 = tick()
k2 = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local qw = v
        pcall(function()
            qw:Disable()
        end)
    end
end)
l7 = fn486
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
task.spawn(antiAfkLoop)
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera2 = lJ.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fns.fn23)
Toggles.WalkSpeedEnabled:OnChanged(fn763)
lP = function(gH)
    pcall(function()
        lO:SetGameplayPausedNotificationEnabled(not gH)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = lM:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not gH
        end
    end)
    if not gH then
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
do
    Toggles.AntiGameplayPause:OnChanged(fn681)
    task.spawn(antiGameplayPauseLoop)
    task.spawn(worker8)
    task.spawn(worker7)
    task.spawn(worker6)
    task.spawn(worker5)
    task.spawn(worker4)
    task.spawn(worker3)
    lI()
    ThemeManager:SetLibrary(ll)
    ThemeManager:SetFolder("TempoHub")
    ThemeManager:SaveDefault("Monochrome")
    ThemeManager:ApplyToTab(mr.Settings)
    ThemeManager:LoadDefault()
    SaveManager:SetLibrary(ll)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    SaveManager:SetFolder("TempoHub/CowboyDUELS")
    mb = SaveManager:BuildConfigSection(mr.Settings)
end
lq = fn413
kW = fn386
l4 = fn606
lo = function(hx)
    local rP
    rP = nil
    local rQ = type(hx) ~= "table" or type(hx.idx) ~= "string" or type(hx.type) ~= "string" or SaveManager.Ignore[hx.idx]
    if rQ then
        return false
    end
    rP = lq(hx.type, hx.idx)
    if not rP then
        return false
    end
    local rQ_1 = pcall(function()
        if hx.type == "Input" then
            if type(hx.text) ~= "string" then
                return
            end
            rP:SetValue(hx.text)
        elseif hx.type == "ColorPicker" then
            rP:SetValueRGB(Color3.fromHex(hx.value), hx.transparency)
        elseif hx.type == "KeyPicker" then
            rP:SetValue({ hx.key, hx.mode, hx.modifiers })
            if hx.mode == "Toggle" and hx.toggled ~= nil then
                rP.Toggled = hx.toggled
                rP:Update()
            end
        else
            rP:SetValue(hx.value)
        end
    end)
    return rQ_1
end
mb:AddDivider()
mb:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
mb:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
mb:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
ll:OnUnload(fn876)
end)(...)

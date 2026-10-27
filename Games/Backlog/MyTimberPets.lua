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
getgenv().TempoHoodSubtitle = "MY TIMBER PETS!"
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
local oj
local n0
local oL
local oq
local o9
local n6
local oR
local pf
local oc
local oX
local Library
local LocalPlayer
local o2
local n_
local op
local o8
local oQ
local ox
local oW
local oh
local o1
local nZ
local n4
local SlotCosts
local pd
local oa
local UpgradeTree
local oC
local og
local oI
local on
local o6
local n3
local PlotLevels
local pc
local n9
local oU
local oB
local of
local o_
local nX
local oH
local o5
local n2
local oN
local ou
local pb
local n8
local StockUpgradeLevels
local Knit
local oZ
local nW
local ForestLevels
local Toggles
local o4
local CFrame2
local oM
local Workspace
local pa
local oS
local oz
local pg
local Options
local nV
local function fn24(db)
    local sK_1
    local sJ_1
    if type(db) ~= "string" then
        return nil
    end
    local sI = string.gsub(db, ",", "")
    sJ_1, sK_1 = string.match(sI, "%$?([%d%.]+)%s*([KkMmBbTtQa]*)")
    local sI_1 = tonumber(sJ_1)
    if not sI_1 then
        return nil
    end
    local sJ_2 = 1
    local sM = sK_1
    local sQ = if sM then 1 else 0
    local sO = 1422 * sQ + 1023 * (1 - sQ)
    local sP = 3169 * sQ + 2668 * (1 - sQ)
    if not ((sO * 1549 + sP * 1625 + sO * sP) % 16777213 == 11858621) then
        sM = ""
    end
    local sK_2 = string.lower(sM)
    if sK_2 == "k" then
        sJ_2 = 1000
    elseif sK_2 == "m" then
        sJ_2 = 1000000
    elseif sK_2 == "b" then
        sJ_2 = 1000000000
    elseif sK_2 == "t" then
        sJ_2 = 1000000000000
    elseif sK_2 == "qa" then
        sJ_2 = 1000000000000000
    end
    return sI_1 * sJ_2
end
local function fn33(bb)
    if not (bb and bb.Parent and bb.Enabled) then
        return false
    elseif oC(bb, "general_lock") then
        return false
    elseif oC(bb, tostring(LocalPlayer.UserId) .. "_locked") then
        return false
    else
        return true
    end
end
local function fn36(br, bs, bt)
    local qK = SlotCosts[br] or SlotCosts[tostring(br)]
    local qK_1 = type(qK) == "table" and qK[bs]
    if type(qK_1) ~= "table" then
        return nil
    end
    return tonumber(qK_1[bt])
end
local function fn48()
    local w1 = oQ()
    if not w1 then
        return
    end
    if Toggles.TpToRoll.Value then
        CFrame2 = w1.CFrame
        w1.CFrame = CFrame.new(109, 6, -180)
        w1.AssemblyLinearVelocity = Vector3.zero
    elseif CFrame2 then
        w1.CFrame = CFrame2
        w1.AssemblyLinearVelocity = Vector3.zero
        CFrame2 = nil
    end
end
local function fn141(bP)
    local q2 = 0
    if bP then
        local q3_1 = tonumber(bP.stockUpgradeLevel) or 0
        q2 = q3_1
        if type(bP.Upgrades) == "table" then
            for k, v in bP.Upgrades do
                if v == true then
                    local q3_2 = UpgradeTree.Nodes[k]
                    local q4 = q3_2 and q3_2.Upgrade == "StockUpgrade" and type(q3_2.Level) == "number"
                    if q4 then
                        q2 = math.max(q2, q3_2.Level)
                    end
                end
            end
        end
    end
    local q3_3 = StockUpgradeLevels[q2] or StockUpgradeLevels[0]
    local q2_1 = q3_3
    if q3_3 then
        q3_3 = tonumber(q2_1.stockCapacity)
    end
    return q3_3 or 5
end
local function fn142()
    local vf = oL()
    if not vf then
        return
    end
    local vg = oq("RollUpgradeList")
    for k, v in o5 do
        if vg[v] then
            local vh = oR[v]
            local vi = vh and o6(vf, vh)
            if vi then
                return
            end
        end
    end
end
local function fn161()
    local sz = oq("RollMutations")
    local sA = {}
    for k, v in nW do
        if sz[v] then
            sA[#sA + 1] = v
        end
    end
    return sA
end
local function fn256(gm, gn, go)
    oN("WorkerActionsService", "RequestCollectSlotCash", gm, gn, go)
end
local function fn294(a7, a8)
    local attr = a7:GetAttribute(a8)
    return attr == true or attr == "true"
end
local function fn301()
    local rn = oc()
    if not rn then
        return {}
    end
    local ro = {}
    local Floors = rn:FindFirstChild("Floors")
    if not Floors then
        return ro
    end
    for i, child in Floors:GetChildren() do
        local Farms = child:FindFirstChild("Farms")
        if Farms then
            for i, child in Farms:GetChildren() do
                for i, child in child:GetChildren() do
                    local rn_2 = child:IsA("Model") and string.find(child.Name, "Forest", 1, true)
                    if rn_2 then
                        local Trees = child:FindFirstChild("Trees")
                        if Trees then
                            for i, child in Trees:GetChildren() do
                                local rn_4 = child:IsA("Model") and child:GetAttribute("TreeOwnerUserId") == LocalPlayer.UserId and child:GetAttribute("PlayerCutAvailable") == true
                                if rn_4 then
                                    local rp_1 = tonumber(child:GetAttribute("PlayerCuttingUserId")) or 0
                                    rn_4 = rp_1 == 0
                                end
                                if rn_4 then
                                    ro[#ro + 1] = child
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return ro
end
local function fn333()
    local Character = LocalPlayer.Character
    local pQ = Character and Character:FindFirstChildOfClass("Humanoid")
    return pQ
end
local function fn340()
    local Character = LocalPlayer.Character
    local pT = Character and Character:FindFirstChild("HumanoidRootPart")
    return pT
end
local function fn348()
    local qR_1
    local qQ_1
    qQ_1, qR_1 = pcall(function()
        local qN = Knit.GetController("VisualsController")
        if qN and qN.GetWoodSellMultiplier then
            return qN:GetWoodSellMultiplier()
        end
        return nil
    end)
    local qS = qQ_1 and type(qR_1) == "number"
    if qS then
        return qR_1
    end
    local qQ_2 = oc()
    if not qQ_2 then
        return 1
    end
    local SellWoodBuilding = qQ_2:FindFirstChild("SellWoodBuilding")
    if not SellWoodBuilding then
        return 1
    end
    for i, descendant in SellWoodBuilding:GetDescendants() do
        local qQ_3 = descendant:IsA("TextLabel") and descendant.Name == "MultiLabel"
        if qQ_3 then
            local qQ_4 = tonumber(string.match(descendant.Text, "([%d%.]+)"))
            if qQ_4 then
                return qQ_4
            end
        end
    end
    return 1
end
local function fn387()
    local ta = oq("RolledPetRarities")
    local tb = oq("RolledPetMutations")
    local tc = next(ta) == nil or next(tb) == nil
    if tc then
        return
    end
    local tc_1 = oc()
    local td = tc_1 and tc_1:FindFirstChild("spinWorkerModel")
    local tc_2 = td
    if td then
        td = tc_2:FindFirstChild("Roulettes")
    end
    local tc_3 = td
    if not tc_3 then
        return
    end
    local td_1 = oL()
    local te = td_1 and tonumber(td_1.cash)
    local td_2 = te or 0
    local td_3 = n0()
    for i, child in tc_3:GetChildren() do
        local tc_4 = tonumber(child:GetAttribute("rouletteIndex"))
        local tf = tc_4 and td_3[tc_4]
        if tf then
            local attr2 = tf:GetAttribute("rarity")
            local attr = tf:GetAttribute("mutation")
            if ta[attr2] and tb[attr] then
                local BuyPrompt = child:FindFirstChild("BuyPrompt", true)
                if n8(BuyPrompt) then
                    local tg_1 = pd(tf)
                    if tg_1 ~= nil and td_2 >= tg_1 then
                        oz(BuyPrompt)
                    end
                end
            end
        end
    end
end
local function fn419(ak)
    local DiscordGroup = ak:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = o2 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = o2 })
end
local function autoEquipBestLoop()
    while not Library.Unloaded do
        task.wait(0.35)
        if Toggles.AutoEquipBest.Value then
            local w4_1 = Options.EquipBestDelay and Options.EquipBestDelay.Value or 1
            if os.clock() - oh >= w4_1 then
                oh = os.clock()
                pcall(oj)
            end
        end
        if Toggles.AutoSellWood.Value then
            pcall(oU)
        end
        if Toggles.AutoCollectMoney.Value then
            pcall(n2)
        end
        if Toggles.AutoBuyRolledPet.Value then
            pcall(op)
        end
        if Toggles.AutoBuySlots.Value then
            pcall(o9)
        end
        if Toggles.AutoBuyRoll.Value then
            pcall(o1)
        end
        if Toggles.AutoBuyUpgrades.Value then
            pcall(pb)
        end
        if Toggles.AutoBuyNodes.Value then
            pcall(o4)
        end
        if Toggles.AutoUpgradeAnimals.Value then
            pcall(ox)
        end
    end
end
local function fn480(ay)
    local pV = Options[ay]
    local pW = pV and pV.Value
    local pV_1 = {}
    if type(pW) ~= "table" then
        return pV_1
    end
    for k, v in pW do
        if v then
            pV_1[k] = true
        end
    end
    return pV_1
end
local function autoFarmTreesLoop()
    while not Library.Unloaded do
        if Toggles.AutoFarmTrees.Value then
            pcall(pf)
        end
        task.wait(0.2)
    end
end
local function fn513(e9)
    local uw_1
    local uv_1
    uv_1, uw_1 = oN("UpgradesService", "RequestUpgrade", e9)
    return uv_1 and uw_1 == true
end
local function fn523()
    local vu_1
    local vt_1
    local vq = oL()
    if not vq then
        return
    end
    local vr = tonumber(vq.cash) or 0
    local Upgrades = vq.Upgrades
    if type(Upgrades) ~= "table" then
        return
    end
    vu_1, vt_1 = nil, nil
    for k, v in UpgradeTree.Nodes do
        local vv = k ~= "Start" and Upgrades[k] ~= true and oW(vq, v) and type(v.Cost) == "table"
        if vv then
            local vv_1 = tonumber(v.Cost.Amount) or 0
            local vv_2 = vr >= vv_1
            if vv_2 then
                local vx = not vt_1
                local vH = if vx then 1 else 0
                local vF = 2575 * vH + 405 * (1 - vH)
                local vG = 3190 * vH + 1406 * (1 - vH)
                if not ((vF * 1869 + vG * 2068 + vF * vG) % 16777213 == 2846632) then
                    vx = vv_1 < vt_1
                end
                vv_2 = vx
            end
            if vv_2 then
                vu_1 = k
                vt_1 = vv_1
            end
        end
    end
    if vu_1 then
        of(vu_1)
    end
end
local function fn571(cr)
    local rS = not cr or not cr.Parent
    local rS_2
    if rS then
        return false
    end
    local rY = if not nZ() then 1 else 0
    if rY == 1 then
        return false
    end
    local rS_1 = oQ()
    local PromptPart = cr:FindFirstChild("PromptPart", true)
    local rT_1
    local rU = rS_1 and PromptPart and PromptPart:IsA("BasePart")
    if rU then
        rS_1.CFrame = PromptPart.CFrame * CFrame.new(0, 3, 0)
        rS_1.AssemblyLinearVelocity = Vector3.zero
    end
    rS_2, rT_1 = oN("TreeCuttingService", "RequestCutTree", cr)
    local rU_1 = not rS_2 or type(rT_1) ~= "table" or rT_1.accepted ~= true
    if rU_1 then
        return false
    end
    local rS_3 = tonumber(rT_1.cuttingTime) or 1
    task.wait(math.max(0.2, rS_3 + 0.15))
    return true
end
local function fn575(e3, e4)
    if type(e4.Requirements) ~= "table" then
        return true
    end
    local Upgrades = e3.Upgrades
    if type(Upgrades) ~= "table" then
        return false
    end
    for k, v in e4.Requirements do
        if Upgrades[v] ~= true then
            return false
        end
    end
    return true
end
local function fn578(Z, aa, ab)
    return string.format("<b>%s</b> %s %s", Z, oI("-", "#5a6070"), oI(aa, ab))
end
local function fn665()
    local r6 = oL()
    if not r6 then
        return false
    end
    local r7 = tonumber(r6.carriedLogsAmount) or 0
    if r7 <= 0 then
        return false
    end
    local r7_1 = nV(r6)
    if r7 >= r7_1 then
        if (Options.SellWoodMode and Options.SellWoodMode.Value or "Anytime") == "Only at 1.5x" then
            return oa() >= 1.5
        end
        return true
    end
    return false
end
local function fn672()
    local tv_1
    local ts = oL()
    if not ts then
        return
    end
    local tt = tonumber(ts.cash) or 0
    local tt_2
    local tt_1 = oc()
    if not tt_1 then
        return
    end
    local Floors = tt_1:FindFirstChild("Floors")
    if not Floors then
        return
    end
    tv_1, tt_2 = nil, nil
    for i, child in Floors:GetChildren() do
        local Farms = child:FindFirstChild("Farms")
        if Farms then
            for i, child in Farms:GetChildren() do
                local WorkersSlots = child:FindFirstChild("WorkersSlots")
                if WorkersSlots then
                    for i, child in WorkersSlots:GetChildren() do
                        local tu_3 = child:IsA("Model") and child:GetAttribute("IsUnlocked") == false
                        if tu_3 then
                            local tu_4 = tonumber(child:GetAttribute("FloorIndex")) or 1
                            local tu_5 = tonumber(child:GetAttribute("FarmIndex")) or 1
                            local tu_6 = tonumber(child:GetAttribute("SlotIndex")) or 1
                            local tu_7 = pa(tu_4, tu_5, tu_6)
                            local UnlockPrompt = child:FindFirstChild("UnlockPrompt", true)
                            local tx_1 = type(tu_7) == "number" and tu_7 > 0 and tt >= tu_7 and n8(UnlockPrompt)
                            if tx_1 then
                                tx_1 = not tt_2 or tu_7 < tt_2
                            end
                            if tx_1 then
                                tt_2 = tu_7
                                tv_1 = UnlockPrompt
                            end
                        end
                    end
                end
            end
        end
    end
    if tv_1 then
        oS(tv_1)
    end
end
local function fn701(fx)
    local uP = (tonumber(fx.plotLevel))
    local uP_3
    local uW = if uP then 1 else 0
    local uU = 890 * uW + 3156 * (1 - uW)
    local uV = 1240 * uW + 1511 * (1 - uW)
    if not ((uU * 3020 + uV * 2308 + uU * uV) % 16777213 == 6653320) then
        uP = 0
    end
    local uQ = uP
    local uQ_3
    local uP_1 = PlotLevels[uQ + 1]
    if type(uP_1) ~= "table" then
        return false
    end
    local uQ_1 = tonumber(uP_1.upgradeCost) or 0
    local uQ_2 = tonumber(fx.cash) or 0
    if uQ_2 < uQ_1 then
        return false
    end
    uP_3, uQ_3 = oN("UpgradesService", "RequestUpgradePlot")
    return uP_3 and uQ_3 == true
end
local function fn709(dj)
    for i, descendant in dj:GetDescendants() do
        local sR = descendant:IsA("TextLabel") and descendant.Name == "Price"
        if sR then
            return oH(descendant.Text)
        end
    end
    return nil
end
local function fn712(P, Q)
    if setclipboard then
        setclipboard(P)
    elseif toclipboard then
        toclipboard(P)
    end
    Library:Notify(Q)
end
local function fn715()
    if not Toggles.AutoRoll.Value and ou then
        pcall(function()
            oN("AutoRollService", "StopAutoRoll")
        end)
        ou = false
    end
end
local function fn724()
    local Character = LocalPlayer.Character
    local rd = pg()
    if not (Character and rd) then
        return false
    end
    local Tool = Character:FindFirstChildOfClass("Tool")
    local rc_1 = Tool and Tool:GetAttribute("itemType") == "axeItem"
    if rc_1 then
        return true
    end
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    if not Backpack then
        return false
    end
    for i, child in Backpack:GetChildren() do
        local rc_3 = child:IsA("Tool") and child:GetAttribute("itemType") == "axeItem"
        if rc_3 then
            rd:EquipTool(child)
            return true
        end
    end
    return false
end
local function fn728(eu)
    local tS = type(eu) == "table" and type(eu.ownedProducts) == "table" and eu.ownedProducts.AUTO_ROLL == true
    return tS
end
local function fn732(fe, ff)
    local uE_1
    local uD_1
    local Level
    local uA = tonumber(fe.cash) or 0
    local Upgrades = fe.Upgrades
    if type(Upgrades) ~= "table" then
        return false
    end
    uE_1, Level, uD_1 = nil, nil, nil
    for k, v in UpgradeTree.Nodes do
        local uF = v.Upgrade == ff and type(v.Level) == "number" and Upgrades[k] ~= true and oW(fe, v)
        if uF then
            local uF_1 = v.Cost and tonumber(v.Cost.Amount)
            local uG = uF_1 or 0
            if uA >= uG then
                if not Level or v.Level < Level or v.Level == Level and uG < uD_1 then
                    uE_1 = k
                    Level = v.Level
                    uD_1 = uG
                end
            end
        end
    end
    if uE_1 then
        return of(uE_1)
    end
    return false
end
local function fn792(fE)
    local uX = (tonumber(fE.forestLevel))
    local uX_3
    local u3 = if uX then 1 else 0
    local u1 = 2031 * u3 + 421 * (1 - u3)
    local u2 = 1991 * u3 + 1634 * (1 - u3)
    if not ((u1 * 109 + u2 * 1873 + u1 * u2) % 16777213 == 7994243) then
        uX = 0
    end
    local uY = uX
    local uY_3
    local uX_1 = ForestLevels[uY + 1]
    if type(uX_1) ~= "table" then
        return false
    end
    local uY_1 = tonumber(uX_1.upgradeCost) or 0
    local uY_2 = tonumber(fE.cash) or 0
    if uY_2 < uY_1 then
        return false
    end
    uX_3, uY_3 = oN("UpgradesService", "RequestUpgradeForest")
    return uX_3 and uY_3 == true
end
local function fn883()
    local s1 = {}
    local workersEntities = Workspace:FindFirstChild("workersEntities")
    if not workersEntities then
        return s1
    end
    for i, child in workersEntities:GetChildren() do
        local s2_1 = child:IsA("Model") and tonumber(child:GetAttribute("rouletteOwnerUserId")) == LocalPlayer.UserId
        if s2_1 then
            local s2_2 = tonumber(child:GetAttribute("rouletteIndex"))
            if s2_2 then
                s1[s2_2] = child
            end
        end
    end
    return s1
end
local function fn965(a2)
    local qq = oQ()
    local qr = qq and a2 and a2:IsA("BasePart")
    if not qr then
        return false
    end
    qq.CFrame = a2.CFrame * CFrame.new(0, 3, 0)
    qq.AssemblyLinearVelocity = Vector3.zero
    return true
end
local function fn980()
    local rZ = oL()
    local rZ_3
    local r_ = not rZ
    local r__3
    if not r_ then
        local r0_1 = tonumber(rZ.carriedLogsAmount) or 0
        r_ = r0_1 <= 0
    end
    if r_ then
        return false
    end
    local r__1 = Options.SellWoodMode and Options.SellWoodMode.Value or "Anytime"
    local r__2 = r__1 == "Only at 1.5x" and oa() < 1.5
    if r__2 then
        return false
    end
    rZ_3, r__3 = oN("SellWoodService", "RequestSellWood")
    return rZ_3 and r__3 ~= nil
end
local function fn982(W, X)
    return string.format('<font color="%s">%s</font>', X, W)
end
local function autoRollLoop()
    while not Library.Unloaded do
        if Toggles.AutoRoll.Value then
            pcall(og)
        elseif ou then
            pcall(function()
                oN("AutoRollService", "StopAutoRoll")
            end)
            ou = false
            task.wait(0.5)
        else
            task.wait(0.5)
        end
    end
end
local function fn998()
    local sj_2
    local si_2
    if o_ then
        return
    end
    local sp = if oZ() then 1 else 0
    if sp == 1 then
        oU()
        return
    end
    local sg = n9()
    if #sg == 0 then
        local sh_1 = oL()
        local si_1 = sh_1
        if si_1 then
            local sj_1 = tonumber(sh_1.carriedLogsAmount) or 0
            si_1 = sj_1 > 0
        end
        if si_1 then
            oU()
        end
        return
    end
    local sh_2 = oQ()
    sj_2, si_2 = nil, nil
    if sh_2 then
        for k, v in sg do
            local sk = v:FindFirstChild("PromptPart", true) or v:FindFirstChildWhichIsA("BasePart", true)
            if sk then
                local Magnitude = (sk.Position - sh_2.Position).Magnitude
                if not si_2 or Magnitude < si_2 then
                    si_2 = Magnitude
                    sj_2 = v
                end
            end
        end
    end
    local sh_3 = sj_2 or sg[1]
    oX(sh_3)
end
local function fn1002()
    local Plots = Workspace:FindFirstChild("Plots")
    if not Plots then
        return nil
    end
    return Plots:FindFirstChild("user_" .. LocalPlayer.UserId .. "_plot")
end
local function fn1011()
    n6(n4, "Copied Discord invite to clipboard")
end
local function fn1024()
    local u4 = oL()
    if not u4 then
        return
    end
    local u5 = oq("UpgradeList")
    for k, v in pc do
        if u5[v] then
            if v == "Plot" then
                if on(u4) then
                    return
                end
            elseif v == "Forest" then
                if oM(u4) then
                    return
                end
            else
                local u6 = oR[v]
                local u7 = u6 and o6(u4, u6)
                if u7 then
                    return
                end
            end
        end
    end
end
local function fn1051()
    if ou then
        pcall(function()
            oN("AutoRollService", "StopAutoRoll")
        end)
        ou = false
    end
    n_(false)
    if n3 then
        n3:Disconnect()
    end
    if nX then
        nX:Disconnect()
    end
    local yQ = pg()
    if yQ then
        yQ.PlatformStand = false
        yQ.WalkSpeed = 16
    end
end
local function fn1059()
    local v4 = oL()
    if not v4 then
        return
    end
    local v6 = Options.AnimalMaxLevel and Options.AnimalMaxLevel.Value or 50
    local v6_1 = tonumber(v4.cash) or 0
    local v6_2 = oc()
    if not v6_2 then
        return
    end
    local Floors = v6_2:FindFirstChild("Floors")
    if not Floors then
        return
    end
    for i, child in Floors:GetChildren() do
        local Farms = child:FindFirstChild("Farms")
        if Farms then
            for i, child in Farms:GetChildren() do
                local WorkersSlots = child:FindFirstChild("WorkersSlots")
                if WorkersSlots then
                    for i, child in WorkersSlots:GetChildren() do
                        local v6_5 = child:IsA("Model") and child:GetAttribute("IsUnlocked") == true
                        if v6_5 then
                            local v7_1 = nil
                            for i, child in child:GetChildren() do
                                local v6_6 = child:IsA("Model") and child:GetAttribute("workerUUID")
                                if v6_6 then
                                    v7_1 = child
                                    break
                                end
                            end
                            if v7_1 then
                                local v6_7 = tonumber(v7_1:GetAttribute("level")) or 1
                                if v6_7 < v6 then
                                    local v6_8 = tonumber(child:GetAttribute("FloorIndex")) or 1
                                    local v6_9 = tonumber(child:GetAttribute("FarmIndex")) or 1
                                    local v6_10 = tonumber(child:GetAttribute("SlotIndex")) or 1
                                    local v6_11 = oN("WorkerActionsService", "RequestUpgradeWorker", v6_8, v6_9, v6_10)
                                    if v6_11 then
                                        return
                                    end
                                    if v6_1 <= 0 then
                                        return
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
local function fn1063()
    oN("WorkerActionsService", "RequestEquipBest")
end
local function fn1076()
    local vI = oc()
    if not vI then
        return
    end
    local Floors = vI:FindFirstChild("Floors")
    if not Floors then
        return
    end
    for i, child in Floors:GetChildren() do
        local Farms = child:FindFirstChild("Farms")
        if Farms then
            for i, child in Farms:GetChildren() do
                local WorkersSlots = child:FindFirstChild("WorkersSlots")
                if WorkersSlots then
                    for i, child in WorkersSlots:GetChildren() do
                        local vI_3 = child:IsA("Model") and child:GetAttribute("IsUnlocked") == true
                        if vI_3 then
                            local vJ_1 = tonumber(child:GetAttribute("StoredValue")) or 0
                            vI_3 = vJ_1 > 0
                        end
                        if vI_3 then
                            local vI_4 = child:FindFirstChild("CollectMoneyPart") or child:FindFirstChild("CollectMoneyPartBase")
                            local vJ_2 = vI_4
                            if vI_4 then
                                vI_4 = vJ_2:IsA("BasePart")
                            end
                            if vI_4 then
                                o8(vJ_2)
                                task.wait(0.2)
                            end
                            local vI_5 = tonumber(child:GetAttribute("FloorIndex")) or 1
                            local vI_6 = tonumber(child:GetAttribute("FarmIndex")) or 1
                            local vI_7 = tonumber(child:GetAttribute("SlotIndex")) or 1
                            oB(vI_5, vI_6, vI_7)
                            task.wait(0.15)
                        end
                    end
                end
            end
        end
    end
end
local function fn1105()
    local qi_1
    local qh_1
    qh_1, qi_1 = oN("UserDataService", "RequestData")
    local qj = qh_1 and type(qi_1) == "table"
    if qj then
        return qi_1
    end
    return nil
end
nV = nil
nW = nil
nX = nil
nZ = nil
n_ = nil
n0 = nil
CFrame2 = nil
n2 = nil
n3 = nil
n4 = nil
n6 = nil
n8 = nil
n9 = nil
oa = nil
oc = nil
Options = nil
Knit = nil
of = nil
og = nil
oh = nil
LocalPlayer = nil
oj = nil
Toggles = nil
on = nil
op = nil
oq = nil
Workspace = nil
ou = nil
SlotCosts = nil
ox = nil
oz = nil
StockUpgradeLevels = nil
oB = nil
oC = nil
Library = nil
ForestLevels = nil
oH = nil
oI = nil
local nY, n5, Services, ob, SpinSpeedUtils, oo, SaveManager, CoreGui, GuiService, oF, oJ, HttpService
oL = nil
oM = nil
oN = nil
PlotLevels = nil
oQ = nil
oR = nil
oS = nil
oU = nil
UpgradeTree = nil
oW = nil
oX = nil
oZ = nil
o_ = nil
o1 = nil
o2 = nil
o4 = nil
o5 = nil
o6 = nil
o8 = nil
o9 = nil
pa = nil
pb = nil
pc = nil
pd = nil
pf = nil
pg = nil
local VirtualUser, oT, UserInputService, o0, RunService, o7, pe
local pp_1
RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, LocalPlayer, ob, n4, nY, UpgradeTree, PlotLevels, ForestLevels, StockUpgradeLevels, SlotCosts, SpinSpeedUtils, Knit, Services, nW, pc, o5, oR, Library, SaveManager, Toggles, Options, pe, o7, o0, oT, oF, n6, o2, oI, oo, pp_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
ob = "My Timber Pets!"
n4 = "https://discord.gg/K7Qxnxkk46"
nY = "https://discord.gg/K7Qxnxkk46"
local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameData = Shared:WaitForChild("GameData")
local Utility = Shared:WaitForChild("Utility")
UpgradeTree = require(GameData:WaitForChild("UpgradeTree"))
PlotLevels = require(GameData:WaitForChild("PlotLevels"))
ForestLevels = require(GameData:WaitForChild("ForestLevels"))
StockUpgradeLevels = require(GameData:WaitForChild("StockUpgradeLevels"))
SlotCosts = require(GameData:WaitForChild("SlotCosts"))
SpinSpeedUtils = require(Utility:WaitForChild("SpinSpeedUtils"))
Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
Services = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services
local pq = { "Common", "Rare", "Epic", "Legendary", "Cosmic", "Secret", "God" }
nW = { "normal", "gold", "diamond", "demon", "galaxy" }
pc = { "Axe", "Stock", "Tree Cooldown", "Golden Tree", "Plot", "Forest" }
o5 = {
    "Spin Luck",
    "Spin Count",
    "Spin Speed",
    "Gold Spin",
    "Diamond Spin",
    "Demon Spin",
    "Galaxy Spin"
}
local ps = { "Anytime", "Only at 1.5x" }
oR = {
    Axe = "AxeLevel",
    Stock = "StockUpgrade",
    ["Tree Cooldown"] = "TreeCooldown",
    ["Golden Tree"] = "GoldenTreeChance",
    ["Spin Luck"] = "SpinLuck",
    ["Spin Count"] = "SpinCount",
    ["Spin Speed"] = "SpinSpeed",
    ["Gold Spin"] = "GoldSpin",
    ["Diamond Spin"] = "DiamondSpin",
    ["Demon Spin"] = "DemonSpin",
    ["Galaxy Spin"] = "GalaxySpin"
}
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
n6 = fn712
o2 = fn1011
oI = fn982
oo = fn578
pe = "#7fd47f"
o7 = "#6ec1ff"
o0 = "#e8a34d"
oT = "#8b93a3"
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = n4, Copyable = true }, "|", ob },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
oF = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gamepad-2"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
if (not LocalPlayer or GuiService or LocalPlayer and Options or (pc or GuiService or (not pc or pc))) and (Options and Options and (not pc and ForestLevels) or not pc and GuiService and (LocalPlayer or not pc)) and not ((not LocalPlayer or GuiService or LocalPlayer and Options or (pc or GuiService or (not pc or pc))) and (Options and Options and (not pc and ForestLevels) or not pc and GuiService and (LocalPlayer or not pc))) then
else
    pp_1 = fn419
end
for k, v in oF do
    pp_1(v)
end
o_, ou, CFrame2, oh, n_, n3, nX, pg, oQ, oq, oN, oL, oc, o8, oC, n8, oS, pa, oa, nV, nZ, n9, oX, oU, oZ, pf, oj, n5, oH, pd, oz, n0, op, o9, oJ, og, oW, of, o6, on, oM, pb, o1, o4, oB, n2, ox = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pg = fn333
oQ = fn340
oq = fn480
oN = function(aH, aI, ...)
    local p7
    p7 = nil
    local qc_1
    local qb_1
    local qa_1
    local p8 = Services:FindFirstChild(aH)
    local p8_1
    local p9 = p8 and p8:FindFirstChild("RF") and p8.RF:FindFirstChild(aI)
    local p9_1
    p7 = p9
    if not p7 then
        return false, nil
    end
    p8_1, qc_1, qb_1, qa_1, p9_1 = pcall(function(...)
        return p7:InvokeServer(...)
    end, ...)
    if not p8_1 then
        return false, nil
    end
    return true, qc_1, qb_1, qa_1, p9_1
end
oL = fn1105
oc = fn1002
o8 = fn965
oC = fn294
n8 = fn33
o_ = false
oS = function(bh)
    local qC
    if not (bh and bh.Parent) then
        return false
    end
    local qD_1 = bh.Parent
    if not qD_1:IsA("BasePart") then
        qD_1 = bh:FindFirstAncestorWhichIsA("BasePart")
    end
    o_ = true
    if qD_1 then
        o8(qD_1)
        task.wait(0.15)
    end
    local max = math.max
    local qE = tonumber(bh.MaxActivationDistance) or 10
    local qF = max(qE, 10)
    if fireproximityprompt then
        pcall(fireproximityprompt, bh, qF)
    else
        local qD_3 = (tonumber(bh.HoldDuration))
        local qJ = if qD_3 then 1 else 0
        local qH = 2877 * qJ + 4076 * (1 - qJ)
        local qI = 2847 * qJ + 320 * (1 - qJ)
        if not ((qH * 1278 + qI * 3632 + qH * qI) % 16777213 == 5430716) then
            qD_3 = 0
        end
        qC = qD_3
        pcall(function()
            bh:InputHoldBegin()
            task.wait(qC + 0.05)
            bh:InputHoldEnd()
        end)
    end
    task.wait(0.15)
    o_ = false
    return true
end
pa = fn36
oa = fn348
nV = fn141
nZ = fn724
n9 = fn301
oX = fn571
oU = fn980
oZ = fn665
pf = fn998
oj = fn1063
n5 = fn161
oH = fn24
pd = fn709
oz = function(dq)
    local sZ
    if fireproximityprompt then
        pcall(fireproximityprompt, dq)
    else
        local s_ = tonumber(dq.HoldDuration) or 0
        sZ = s_
        pcall(function()
            dq:InputHoldBegin()
            task.wait(sZ + 0.05)
            dq:InputHoldEnd()
        end)
    end
end
if not n_ and n_ and (not n9 and n_) or (n_ and n9 or (n9 or n_)) or (not nZ or not nZ or (not n_ or n9)) and (nZ and not n9 and (n_ and not n9)) or not (not n_ and n_ and (not n9 and n_) or (n_ and n9 or (n9 or n_)) or (not nZ or not nZ or (not n_ or n9)) and (nZ and not n9 and (n_ and not n9))) then
    n0 = fn883
    op = fn387
else
    op = fn883
    n0 = fn387
end
if (og or on) and (og and on) or (on or og or on and og) or not ((og or on) and (og and on) or (on or og or on and og)) then
    o9 = fn672
else
    oN = fn672
end
oJ = fn728
ou = false
og = function()
    local t1
    local t6_1, t6_3
    local t3 = Toggles.AutoRoll and Toggles.AutoRoll.Value == true
    local t2 = oL()
    if not t3 then
        if ou then
            oN("AutoRollService", "StopAutoRoll")
            ou = false
        end
        return
    end
    if not oJ(t2) then
        if ou then
            oN("AutoRollService", "StopAutoRoll")
            ou = false
        end
        oN("PlotSpinService", "RequestSpin")
        t1 = 3.5
        pcall(function()
            local tX = (SpinSpeedUtils.getRevealDelay(t2))
            local t0 = if tX then 1 else 0
            local tZ = 2992 * t0 + 1666 * (1 - t0)
            local t_ = 2874 * t0 + 1579 * (1 - t0)
            if not ((tZ * 1380 + t_ * 1996 + tZ * t_) % 16777213 == 1687259) then
                tX = 3.5
            end
            t1 = tX
        end)
        task.wait(math.max(1, t1))
        return
    end
    local t4_1 = Options.RollRarity and Options.RollRarity.Value or "Common"
    local t4_2 = n5()
    local t5 = t4_1 == nil or t4_1 == "" or #t4_2 == 0
    local t5_1, t5_4
    if t5 then
        return
    end
    t5_1, t6_1 = oN("AutoRollService", "GetAutoRollState")
    local t7 = t5_1 and type(t6_1) == "table" and t6_1.enabled == true
    local t5_2 = t7
    if t7 then
        t7 = t6_1.rarityTarget == t4_1
    end
    local t8 = t5_2
    local t9 = t7
    local t7_1 = false
    if t8 then
        t8 = type(t6_1.mutationsTarget) == "table"
    end
    if t8 then
        t7_1 = #t6_1.mutationsTarget == #t4_2
        if t7_1 then
            for k, v in t4_2 do
                if table.find(t6_1.mutationsTarget, v) == nil then
                    t7_1 = false
                    break
                end
            end
        end
    end
    if t5_2 and t9 and t7_1 then
        ou = true
        return
    end
    t5_4, t6_3 = oN("AutoRollService", "StartAutoRoll", t4_1, t4_2)
    ou = t5_4 and t6_3 == true
end
oW = fn575
of = fn513
o6 = fn732
on = fn701
oM = fn792
pb = fn1024
o1 = fn142
o4 = fn523
oB = fn256
n2 = fn1076
ox = fn1059
local function ph_1()
    local wP
    wP = nil
    local wN, wO, Label
    wP = "Unknown"
    pcall(function()
        local wD_1
        local wC_1
        if identifyexecutor then
            wD_1, wC_1 = identifyexecutor()
            local wE = wD_1 ~= ""
            local wF = type(wD_1) == "string" and wE
            if wF then
                local wE_1 = type(wC_1) == "string" and wC_1 ~= "" and wD_1 .. " " .. wC_1
                wP = wE_1 or wD_1
            end
        end
    end)
    local AccountGroup = oF.Info:AddLeftGroupbox("Account", "circle-user")
    AccountGroup:AddLabel(oo("User", LocalPlayer.Name, pe), true)
    AccountGroup:AddLabel(oo("Status", "Keyless", pe), true)
    AccountGroup:AddLabel(oo("Executor", wP, pe), true)
    local GameInfoGroup = oF.Info:AddLeftGroupbox("Game Info", "gamepad-2")
    GameInfoGroup:AddLabel(oI(ob .. " [" .. tostring(game.PlaceId) .. "]", o7), true)
    GameInfoGroup:AddLabel(oo("Place ID", tostring(game.PlaceId), o7), true)
    Label = GameInfoGroup:AddLabel(oo("Session time", "0s", o0), true)
    wO = tostring(game.JobId)
    local wT = #wO > 18 and string.sub(wO, 1, 18) .. "..."
    local wT_1 = wT or wO
    GameInfoGroup:AddLabel(oo("Server", wT_1, oT), true)
    GameInfoGroup:AddButton({
        Text = "Copy join script (Job ID)",
        Func = function()
            local hl = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, wO)
            n6(hl, "Copied join script to clipboard")
        end
    })
    wN = os.clock()
    task.spawn(function()
        local wL_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            local wK = math.floor(os.clock() - wN)
            if wK < 60 then
                wL_1 = wK .. "s"
            elseif wK < 3600 then
                wL_1 = string.format("%dm %ds", math.floor((wK) / (60)), wK % 60)
            else
                wL_1 = string.format("%dh %dm", math.floor((wK) / (3600)), math.floor((wK % 3600) / (60)))
            end
            Label:SetText(oo("Session time", wL_1, o0))
        end
    end)
    local ScriptsGroup = oF.Info:AddRightGroupbox("Scripts", "package")
    ScriptsGroup:AddLabel(oI("Included in this hub", oT), true)
    ScriptsGroup:AddLabel(oI(ob, o7), true)
    local FeaturesGroup = oF.Info:AddRightGroupbox("Features", "list")
    FeaturesGroup:AddLabel(oI("Auto Farm", o7), true)
    FeaturesGroup:AddLabel(oI("Auto Roll", o0), true)
    FeaturesGroup:AddLabel(oI("Auto Upgrades", pe), true)
    FeaturesGroup:AddLabel(oI("Misc Utilities", oT), true)
    local SocialsGroup = oF.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = o2 })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            n6(nY, "Copied Rscripts profile to clipboard")
        end
    })
    local TempoHubGroup = oF.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
    TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = o2 })
    local wS_6 = {
        LTC = {
            address = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w",
            color = "#345d9d",
            label = "LTC / Litecoin",
            button = "Copy Litecoin Address",
            message = "Copied Litecoin address"
        },
        BTC = {
            address = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99",
            color = "#f7931a",
            label = "BTC / Bitcoin",
            button = "Copy Bitcoin Address",
            message = "Copied Bitcoin address"
        },
        ETH = {
            address = "0xaE95A405D007a6F858E5d35714111B075fEFb40a",
            color = "#627eea",
            label = "ETH / Ethereum",
            button = "Copy Ethereum Address",
            message = "Copied Ethereum address"
        },
        USDT = {
            address = "0xaE95A405D007a6F858E5d35714111B075fEFb40a",
            color = "#26a17b",
            label = "USDT",
            button = "Copy USDT Address",
            message = "Copied USDT address"
        },
        SOL = {
            address = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp",
            color = "#14f195",
            label = "Solana",
            button = "Copy Solana Address",
            message = "Copied Solana address"
        },
        PAYPAL = {
            address = "",
            color = "#0070ba",
            label = "PayPal",
            button = "Copy PayPal Link",
            message = "Copied PayPal link"
        },
        VENMO = {
            address = "",
            color = "#008cff",
            label = "Venmo",
            button = "Copy Venmo Link",
            message = "Copied Venmo link"
        }
    }
    local DonationsGroup = oF.Info:AddRightGroupbox("Donations", "heart")
    DonationsGroup:AddLabel(oI("All donations are optional but appreciated.", o0), true)
    DonationsGroup:AddLabel(oI("If you donate you get a special role, just PING after you donate.", pe), true)
    DonationsGroup:AddDivider()
    for k, v in { "LTC", "BTC", "ETH", "USDT", "SOL", "PAYPAL", "VENMO" } do
        local wQ
        wQ = wS_6[v]
        DonationsGroup:AddLabel(oI(wQ.label, wQ.color), true)
        DonationsGroup:AddButton({
            Text = wQ.button,
            Func = function()
                n6(wQ.address, wQ.message)
            end
        })
    end
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(oI("Don't have any of the listed currencies but still wanna donate?", oT), true)
    DonationsGroup:AddLabel(oI("DM me and we'll work something out.", o7), true)
    local FaqGroup = oF.Info:AddRightGroupbox("FAQ", "circle-help")
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
end
ph_1()
local RollingGroup = oF.Main:AddLeftGroupbox("Rolling", "dices")
RollingGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
RollingGroup:AddDropdown("RollRarity", { Text = "Roll Rarity", Values = pq, Default = "Common" })
RollingGroup:AddDropdown("RollMutations", { Text = "Roll Mutations", Values = nW, Default = nW, Multi = true, SelectAllButtons = true })
RollingGroup:AddToggle("AutoBuyRoll", { Text = "Auto Buy Roll", Default = false })
RollingGroup:AddDropdown("RollUpgradeList", { Text = "Roll Upgrades", Values = o5, Default = o5, Multi = true, SelectAllButtons = true })
RollingGroup:AddToggle("TpToRoll", { Text = "TP to Roll Button", Default = false })
Toggles.TpToRoll:OnChanged(fn48)
local AutomationGroup = oF.Main:AddLeftGroupbox("Automation", "bot")
AutomationGroup:AddToggle("AutoFarmTrees", { Text = "Auto Farm Trees", Default = false })
AutomationGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
AutomationGroup:AddSlider("EquipBestDelay", { Text = "Equip Best Delay", Default = 1, Min = 0.5, Max = 15, Rounding = 1, Suffix = "s" })
AutomationGroup:AddToggle("AutoBuyRolledPet", { Text = "Auto Buy Rolled Pet", Default = false })
AutomationGroup:AddDropdown("RolledPetRarities", { Text = "Rolled Pet Rarities", Values = pq, Default = pq, Multi = true, SelectAllButtons = true })
AutomationGroup:AddDropdown("RolledPetMutations", { Text = "Rolled Pet Mutations", Values = nW, Default = nW, Multi = true, SelectAllButtons = true })
AutomationGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
AutomationGroup:AddDropdown("UpgradeList", { Text = "Upgrades", Values = pc, Default = pc, Multi = true, SelectAllButtons = true })
local EconomyGroup = oF.Main:AddRightGroupbox("Economy", "coins")
EconomyGroup:AddToggle("AutoSellWood", { Text = "Auto Sell Wood", Default = false })
EconomyGroup:AddDropdown("SellWoodMode", { Text = "Sell Logic", Values = ps, Default = "Anytime" })
EconomyGroup:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
EconomyGroup:AddToggle("AutoBuySlots", { Text = "Auto Buy Slots", Default = false })
EconomyGroup:AddToggle("AutoBuyNodes", { Text = "Auto Buy Nodes", Default = false })
EconomyGroup:AddToggle("AutoUpgradeAnimals", { Text = "Auto Upgrade Animals", Default = false })
EconomyGroup:AddSlider("AnimalMaxLevel", { Text = "Animal Max Level", Default = 50, Min = 1, Max = 50, Rounding = 0 })
task.spawn(autoFarmTreesLoop)
oh = 0
task.spawn(autoEquipBestLoop)
task.spawn(autoRollLoop)
Toggles.AutoRoll:OnChanged(fn715)
local function pk_1()
    local MovementGroup = oF.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    local FlyGroup = oF.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local function it(iu)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not iu)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not iu
            end
        end)
        if not iu then
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
    RunService.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = LocalPlayer.Character
            if Character then
                for i, descendant in Character:GetDescendants() do
                    local xk_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if xk_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    UserInputService.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local xs_1 = pg()
            if xs_1 then
                xs_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    local CurrentCamera = Workspace.CurrentCamera
    RunService.RenderStepped:Connect(function(i0)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local xu_1 = pg()
            if xu_1 then
                xu_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local xu_3 = oQ()
            local xv = pg()
            if xu_3 and xv then
                xv.PlatformStand = true
                local xv_1 = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    xv_1 += CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    xv_1 -= CurrentCamera.CFrame.LookVector
                end
                local xA = if UserInputService:IsKeyDown(Enum.KeyCode.A) then 1 else 0
                if xA == 1 then
                    xv_1 -= CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    xv_1 += CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    xv_1 += Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    xv_1 -= Vector3.new(0, 1, 0)
                end
                xu_3.AssemblyLinearVelocity = Vector3.zero
                if xv_1.Magnitude > 0 then
                    xu_3.CFrame = xu_3.CFrame + xv_1.Unit * Options.FlySpeed.Value * i0
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local xB = pg()
            if xB then
                xB.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local xD = pg()
            if xD then
                xD.WalkSpeed = 16
            end
        end
    end)
    Toggles.AntiGameplayPause:OnChanged(function()
        it(Toggles.AntiGameplayPause.Value)
    end)
    it(true)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                it(true)
            end
        end
    end)
    return it
end
n_ = pk_1()
local function pu(jt)
    local ju
    ju = tick()
    local jv = tick()
    pcall(function()
        for k, v in getconnections(LocalPlayer.Idled) do
            local xP = v
            pcall(function()
                xP:Disable()
            end)
        end
    end)
    local function jB()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then
            return
        end
        VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
        task.wait(0.1)
        VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
        jv = tick()
    end
    local connection2 = UserInputService.InputBegan:Connect(function()
        ju = tick()
    end)
    local connection = UserInputService.InputChanged:Connect(function(jL)
        local UserInputType = jL.UserInputType
        if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
            ju = tick()
        end
    end)
    jt:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            if Toggles.AntiAfk.Value then
                local xV = tick() - ju
                local xW = tick() - jv
                if xV >= 300 and xW >= 60 then
                    pcall(jB)
                else
                    if xV < 300 and xW >= 300 then
                        pcall(jB)
                    end
                end
            end
        end
    end)
    return connection2, connection
end
local MenuGroup = oF.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
n3, nX = pu(MenuGroup)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(oF.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/MyTimberPets")
local pt = SaveManager:BuildConfigSection(oF.Settings)
SaveManager:LoadAutoloadConfig()
local function po_1(j5)
    local function j6(j7, j8)
        local x__1 = (j7 == "Toggle" and Toggles or Options)[j8]
        local xZ_2 = type(x__1) == "table" and x__1.Type == j7
        return xZ_2 and x__1 or nil
    end
    local function kg(kh, ki)
        local Type = ki.Type
        if Type == "Toggle" then
            return { idx = kh, type = "Toggle", value = ki.Value == true }
        elseif Type == "Slider" then
            return { idx = kh, type = "Slider", value = tostring(ki.Value) }
        elseif Type == "Dropdown" then
            return { idx = kh, type = "Dropdown", multi = ki.Multi == true, value = ki.Value }
        elseif Type == "Input" then
            local x6 = ki.Value or ""
            return { idx = kh, type = "Input", text = tostring(x6) }
        elseif Type == "ColorPicker" then
            return { idx = kh, type = "ColorPicker", value = ki.Value:ToHex(), transparency = ki.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = kh,
                type = "KeyPicker",
                mode = ki.Mode,
                key = ki.Value,
                modifiers = ki.Modifiers,
                toggled = ki.Toggled
            }
        else
            return nil
        end
    end
    local function kk()
        local x9 = {}
        for k, v in { Toggles, Options } do
            for k, v in v do
                local ya = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if ya then
                    local ya_1 = kg(k, v)
                    if ya_1 then
                        x9[#x9 + 1] = ya_1
                    end
                end
            end
        end
        table.sort(x9, function(kv, kw)
            if kv.type ~= kw.type then
                return kv.type < kw.type
            end
            return kv.idx < kw.idx
        end)
        return { objects = x9 }
    end
    local function kx(ky)
        local yq
        yq = nil
        local yr = type(ky) ~= "table"
        local yv = if yr then 1 else 0
        local yt = 71 * yv + 3561 * (1 - yv)
        local yu = 1381 * yv + 3309 * (1 - yv)
        if not ((yt * 461 + yu * 3427 + yt * yu) % 16777213 == 4863469) then
            yr = type(ky.idx) ~= "string"
        end
        if not yr then
            yr = type(ky.type) ~= "string"
        end
        local yy = if yr then 1 else 0
        local yw = 3109 * yy + 916 * (1 - yy)
        local yx = 314 * yy + 2156 * (1 - yy)
        if not ((yw * 906 + yx * 1345 + yw * yx) % 16777213 == 4215310) then
            yr = SaveManager.Ignore[ky.idx]
        end
        if yr then
            return false
        end
        yq = j6(ky.type, ky.idx)
        if not yq then
            return false
        end
        local yr_1 = pcall(function()
            if ky.type == "Input" then
                if type(ky.text) ~= "string" then
                    return
                end
                yq:SetValue(ky.text)
            elseif ky.type == "ColorPicker" then
                yq:SetValueRGB(Color3.fromHex(ky.value), ky.transparency)
            elseif ky.type == "KeyPicker" then
                yq:SetValue({ ky.key, ky.mode, ky.modifiers })
                if ky.mode == "Toggle" and ky.toggled ~= nil then
                    yq.Toggled = ky.toggled
                    yq:Update()
                end
            else
                yq:SetValue(ky.value)
            end
        end)
        return yr_1
    end
    j5:AddDivider()
    j5:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    j5:AddButton("Export Config to Clipboard", function()
        local yA_1
        local yz_1
        yz_1, yA_1 = pcall(HttpService.JSONEncode, HttpService, kk())
        if not yz_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local yz_2 = setclipboard or toclipboard
        local yz_3 = type(yz_2) ~= "function" or not pcall(yz_2, yA_1)
        if yz_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    j5:AddButton("Import Config from Clipboard Text", function()
        local yF_1
        local yD = Options.SaveManager_ImportSource.Value or ""
        local yD_1
        local yE = tostring(yD):match("^%s*(.-)%s*$")
        if yE == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        yD_1, yF_1 = pcall(HttpService.JSONDecode, HttpService, yE)
        local yE_1 = not yD_1 or type(yF_1) ~= "table" or type(yF_1.objects) ~= "table"
        if yE_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local yD_2 = 0
        for k, v in yF_1.objects do
            if kx(v) then
                yD_2 += 1
            end
        end
        if yD_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local yF_2 = yD_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(yD_2, yF_2), 6)
    end)
end
po_1(pt)
Library:OnUnload(fn1051)
end)(...)

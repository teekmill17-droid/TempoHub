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
getgenv().TempoHoodSubtitle = "HACK A BUSINESS"
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
local eX
local eP
local fa
local eS
local e2
local eV
local result
local eN
local eY
local e8
local Options
local eQ
local e3
local eT
local eW
local LocalPlayer
local Toggles
local eO
local e9
local e1
local eR
local e4
local eU
local OfferGui
local function fn48(D)
    return string.match(D, "^(%a%d+)")
end
local function fn59()
    select("#", "Hack A Business unloaded")
end
local function autoAcceptLoop()
    while task.wait(0.3) do
        if fa.Unloaded then
            break
        end
        if Toggles.AutoAccept.Value and OfferGui.Enabled then
            local i8_1 = tonumber(Options.MinMoney.Value) or 0
            if e4 >= i8_1 then
                eP(true)
            else
                eP(false)
            end
        end
    end
end
local function fn74(bA)
    local hK = {}
    for k, v in bA.Value do
        if v then
            hK[eS(k)] = true
        end
    end
    return hK
end
local function fn88(be)
    local hE = eY()
    local hF = hE and be and typeof(firetouchinterest) == "function"
    if hF then
        firetouchinterest(hE, be, 0)
        firetouchinterest(hE, be, 1)
    end
end
local function fn119(cW)
    local Frame = OfferGui.Frame
    local i6 = cW and "Confirm" or "Cancel"
    e1(Frame:FindFirstChild(i6))
end
local function onOnClientEvent4(cZ, c_)
    e4 = eU.toNumber(c_)
end
local function onOnClientEvent2(ad)
    local f_ = {}
    for k, v in ad do
        local f0 = eO.get(v)
        if f0 then
            table.insert(f_, f0)
        end
    end
    e3.Areas = f_
end
local function fn260(bl)
    bl:AddLeftGroupbox("Discord"):AddButton({
        Text = "Join Discord For Dupe",
        Func = function()
            setclipboard(e8)
            fa:Notify("Copied Discord invite to clipboard")
        end
    })
end
local function fn282(aB)
    if not e3.Grid then
        return false
    end
    local gB = e3.Grid:getCellPosition(aB)
    if not gB then
        return false
    end
    for k, v in e3.Areas do
        local gC = v.CFrame:PointToObjectSpace(gB)
        local gD = gC.X - 2
        local gE = gC.Z + 2
        local gC_1 = v.Size.X / 2
        local gF = v.Size.Z / 2
        if -gC_1 <= gD and gD <= gC_1 and -gF <= gE and gE <= gF then
            return true
        end
    end
    return false
end
local function fn285()
    local Character = LocalPlayer.Character
    local hy = Character and Character:FindFirstChild("HumanoidRootPart")
    return hy
end
local function onOnClientEvent3(ak)
    e3.Stock = ak
end
local function fn318()
    local hg = {}
    local Character = LocalPlayer.Character
    for k, v in { LocalPlayer:FindFirstChild("Backpack"), Character } do
        if v then
            for i, child in v:GetChildren() do
                local hh_1 = child:IsA("Tool") and child:HasTag("ObjectTool")
                if hh_1 then
                    local hh_2 = tonumber(string.match(child.Name, "%(x(%d+)%)")) or 0
                    if hh_2 > 0 then
                        table.insert(hg, { UID = child:GetAttribute("ObjectUID"), Amount = hh_2 })
                    end
                end
            end
        end
    end
    return hg
end
local function autoLockLoop()
    while task.wait() do
        if fa.Unloaded then
            break
        end
        if Toggles.AutoLock.Value and e3.Plot then
            local LockPlot = e3.Plot:FindFirstChild("LockPlot")
            local iL = LockPlot and LockPlot:FindFirstChild("Pad")
            eN(iL)
            task.wait(15)
        else
            task.wait(1)
        end
    end
end
local function onOnClientEvent(Y)
    local fV = eO.get(Y)
    if fV then
        e3.Plot = fV
        e3.GridFloor = fV:WaitForChild("GridFloor")
        e3.Grid = eQ.new(e3.GridFloor, 4)
    end
end
local function autoTeleportLoop()
    local iN = 0
    while task.wait(0.5) do
        if fa.Unloaded then
            break
        end
        local iO = Toggles.AutoTeleport.Value and not OfferGui.Enabled and os.clock() > iN
        if iO then
            local Value = Options.OfferArea.Value
            local iP = Value and e9[Value]
            local iP_1 = eY()
            if iP and iP_1 then
                local iQ_1 = iP + Vector3.new(4, 4, 0)
                if (iP_1.Position - iQ_1).Magnitude > 40 then
                    iP_1.CFrame = CFrame.new(iQ_1)
                    iN = os.clock() + 3
                end
            end
        end
    end
end
local function autoCollectLoop()
    while task.wait() do
        if fa.Unloaded then
            break
        end
        if Toggles.AutoCollect.Value and e3.Plot then
            local Objects = e3.Plot:FindFirstChild("Objects")
            if Objects then
                for i, child in Objects:GetChildren() do
                    local iy_2 = fa.Unloaded
                    local iJ = if iy_2 then 1 else 0
                    local iH = 6 * iJ + 2371 * (1 - iJ)
                    local iI = 3628 * iJ + 3634 * (1 - iJ)
                    if not ((iH * 2478 + iI * 1976 + iH * iI) % 16777213 == 7205564) then
                        iy_2 = not Toggles.AutoCollect.Value
                    end
                    if iy_2 then
                        break
                    else
                        local attr = child:GetAttribute("ObjectUID")
                        local iz = attr and string.sub(attr, 1, 1) == "D"
                        if iz then
                            eN(child:FindFirstChild("Primary"))
                        end
                    end
                end
            end
            task.wait(Options.CollectDelay.Value)
        else
            task.wait(0.5)
        end
    end
end
local function fn455(aN)
    local gO, gP, gQ, gR, gS, gU, gW, gX, gZ, g0, g1, g3, g5, g6, g8, ha, hb
    local gT = 32
    while true do
        local gT_1 = 11683 - gT
        do
            if gT_1 < 11669 then
                if gT_1 < 11659 then
                    if gT_1 < 11655 then
                        if gT_1 < 11654 then
                            if gT_1 < 11651 then
                                if gT_1 < 10273 then
                                    break
                                elseif gT_1 < 11649 then
                                    if gT_1 < 11648 then
                                        break
                                    end
                                    gT = if gW <= gU then 17 else 6
                                elseif gT_1 < 11650 then
                                    if gT_1 == 11649 then
                                        gT = if gP then 12 else 19
                                    else
                                        gT = 15605
                                        continue
                                    end
                                else
                                    ha += 1
                                    gT = 29
                                end
                            elseif gT_1 < 11652 then
                                if gT_1 == 11651 then
                                    gT = if not e3.Grid then 0 else 31
                                else
                                    gT = 11680
                                    continue
                                end
                            elseif gT_1 < 11653 then
                                gO = eX()
                                gP = e3.Grid.Rows - 1
                                gW = 0
                                gU = gP
                                gT = 35
                            elseif gT_1 == 11653 then
                                gT = 4
                            else
                                gT = 11659
                                continue
                            end
                        else
                            gT = if ha <= g8 then 14 else 9
                        end
                    elseif gT_1 < 11658 then
                        if gT_1 < 11656 then
                            if gT_1 == 11655 then
                                gT = 18
                            else
                                gT = 11652
                                continue
                            end
                        elseif gT_1 < 11657 then
                            if gT_1 == 11656 then
                                g6 = g5
                                gT = 2
                            else
                                gT = 11651
                                continue
                            end
                        elseif gT_1 == 11657 then
                            gS = gR > e3.Grid.Cols - 1
                            gT = 8
                        else
                            gT = 11660
                            continue
                        end
                    else
                        gS = not eT({ Row = gQ, Col = gR })
                        gT = 5
                    end
                elseif gT_1 < 11664 then
                    if gT_1 < 11663 then
                        if gT_1 < 11661 then
                            if gT_1 < 11660 then
                                break
                            end
                            local hf = if g5 <= g3 then 1 else 0
                            local hd = 1045 * hf + 1676 * (1 - hf)
                            local he = 3178 * hf + 3482 * (1 - hf)
                            gT = if (hd * 755 + he * 2213 + hd * he) % 16777213 == 11142899 then 27 else 34
                        elseif gT_1 < 11662 then
                            gP = true
                            gQ = aN.Rows - 1
                            g5 = 0
                            g3 = gQ
                            gT = 23
                        else
                            gQ = gX + g6
                            gR = g1 + hb
                            gS = gQ > e3.Grid.Rows - 1
                            gT = if gS then 8 else 26
                        end
                    else
                        gS = gO[gQ .. "," .. gR]
                        gT = 11
                    end
                elseif gT_1 < 11666 then
                    if gT_1 < 11665 then
                        gT = 1
                    elseif gT_1 == 11665 then
                        gW += 1
                        gT = 35
                    else
                        gT = 8963
                        continue
                    end
                elseif gT_1 < 11667 then
                    gX = gW
                    gT = 7
                elseif gT_1 < 11668 then
                    if gT_1 == 11667 then
                        gT = 34
                    else
                        gT = 14314
                        continue
                    end
                else
                    gP = false
                    gT = 9
                end
            elseif gT_1 < 11676 then
                if gT_1 < 11674 then
                    if gT_1 < 11673 then
                        if gT_1 < 11671 then
                            if gT_1 < 11670 then
                                hb = ha
                                gT = 21
                            elseif gT_1 == 11670 then
                                gT = if g0 <= gZ then 3 else 28
                            else
                                gT = 11674
                                continue
                            end
                        elseif gT_1 < 11672 then
                            return { Row = gX, Col = g1 }
                        elseif gT_1 == 11672 then
                            gT = if gS then 5 else 25
                        else
                            gT = 15605
                            continue
                        end
                    elseif gT_1 == 11673 then
                        gT = 33
                    else
                        gT = 11679
                        continue
                    end
                elseif gT_1 < 11675 then
                    gT = if not gP then 16 else 30
                elseif gT_1 == 11675 then
                    gT = if gS then 11 else 20
                else
                    gT = 11664
                    continue
                end
            elseif gT_1 < 11680 then
                if gT_1 < 11679 then
                    if gT_1 < 11677 then
                        if gT_1 == 11676 then
                            gP = e3.Grid.Cols - 1
                            g0 = 0
                            gZ = gP
                            gT = 13
                        else
                            gT = 11661
                            continue
                        end
                    elseif gT_1 < 11678 then
                        if gT_1 == 11677 then
                            return nil
                        end
                        gT = 11652
                        continue
                    elseif gT_1 == 11678 then
                        gT = if gS then 15 else 10
                    else
                        gT = 11671
                        continue
                    end
                else
                    g5 += 1
                    gT = 23
                end
            elseif gT_1 < 11682 then
                if gT_1 < 11681 then
                    if gT_1 == 11680 then
                        g1 = g0
                        gT = 22
                    else
                        gT = 11649
                        continue
                    end
                elseif gT_1 == 11681 then
                    gQ = aN.Cols - 1
                    ha = 0
                    g8 = gQ
                    gT = 29
                else
                    gT = 15605
                    continue
                end
            elseif gT_1 < 11683 then
                g0 += 1
                gT = 13
            elseif gT_1 < 14314 then
                if gT_1 == 11683 then
                    return nil
                end
                gT = 8963
                continue
            else
                break
            end
        end
    end
end
local function fn467(cS)
    if not cS then
        return
    end
    if getconnections then
        for k, v in getconnections(cS.Activated) do
            if v.Function then
                task.spawn(v.Function)
            end
        end
    elseif firesignal then
        firesignal(cS.Activated)
    end
end
local function autoAreaLoop()
    while task.wait() do
        if fa.Unloaded then
            break
        end
        if Toggles.AutoArea.Value and e3.Plot then
            local GridAreas = e3.Plot:FindFirstChild("GridAreas")
            if GridAreas then
                for i, child in GridAreas:GetChildren() do
                    if fa.Unloaded or not Toggles.AutoArea.Value then
                        break
                    else
                        local ProximityPrompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
                        local il = tonumber(child.Name)
                        if ProximityPrompt and ProximityPrompt.Enabled and il then
                            e2.BuyArea:FireServer(il, e3.Plot)
                            task.wait(Options.AreaDelay.Value)
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end
local function fn481()
    local f8 = {}
    if not e3.Plot then
        return f8
    end
    local Objects = e3.Plot:FindFirstChild("Objects")
    if not Objects then
        return f8
    end
    for i, child in Objects:GetChildren() do
        local attr3 = child:GetAttribute("ObjectUID")
        local attr2 = child:GetAttribute("Pos.Row")
        local attr = child:GetAttribute("Pos.Col")
        local gc = attr3 and result[attr3]
        local f9_2 = gc
        if gc then
            gc = attr2
        end
        if gc and attr then
            local gc_1 = f9_2.Size.Rows - 1
            local gq = 0
            while gq <= gc_1 do
                local gr = gq
                local gc_2 = f9_2.Size.Cols - 1
                local gv = 0
                while gv <= gc_2 do
                    local gw = gv
                    f8[attr2 + gr .. "," .. attr + gw] = true
                    gv += 1
                end
                gq += 1
            end
        end
    end
    return f8
end
local function autoBuyLoop()
    while task.wait() do
        if fa.Unloaded then
            break
        end
        if Toggles.AutoBuy.Value then
            local hS = eW(Options.BuyAntennas)
            for k in eW(Options.BuyServers) do
                hS[k] = true
            end
            for k, v in e3.Stock do
                if fa.Unloaded or not Toggles.AutoBuy.Value then
                    break
                end
                if v.Stock and v.Stock > 0 and hS[v.UID] then
                    e2.BuyObject:FireServer(v.UID)
                    task.wait(Options.BuyDelay.Value)
                end
            end
        end
        task.wait(0.5)
    end
end
local function autoPlaceLoop()
    while task.wait() do
        if fa.Unloaded then
            break
        end
        if Toggles.AutoPlace.Value then
            for k, v in eR() do
                if fa.Unloaded or not Toggles.AutoPlace.Value then
                    break
                else
                    local h4_1 = v.UID and result[v.UID]
                    local h4_2 = v.UID and string.sub(v.UID, 1, 1) == "F"
                    local h6 = h4_2
                    if h4_2 then
                        h4_2 = Toggles.PlaceAntennas.Value
                    end
                    local h7 = h4_2
                    local ij = if h7 then 1 else 0
                    local ih = 2254 * ij + 37 * (1 - ij)
                    local ii = 318 * ij + 156 * (1 - ij)
                    if not ((ih * 149 + ii * 3484 + ih * ii) % 16777213 == 2160530) then
                        local h4_3 = not h6
                        if h4_3 ~= false then
                            h4_3 = Toggles.PlaceServers.Value
                        end
                        h7 = h4_3
                    end
                    if h4_1 and h7 then
                        local h4_5 = eV(h4_1.Size)
                        if h4_5 then
                            e2.PlaceObject:FireServer(v.UID, h4_5)
                            task.wait(Options.PlaceDelay.Value)
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end
local function onUnload()
    fa:Unload()
end
eN = nil
eO = nil
eP = nil
eQ = nil
eR = nil
eS = nil
eT = nil
eU = nil
eV = nil
eW = nil
eX = nil
eY = nil
Toggles = nil
Options = nil
e1 = nil
e2 = nil
e3 = nil
e4 = nil
result = nil
LocalPlayer = nil
OfferGui = nil
e8 = nil
e9 = nil
fa = nil
local e_
local fm_1
local fl_1
local fk_1
local fj_1
local fi_1
local fh_1
local fg_1
local Utils, fd_2
local ff_1
local Buyers
local fb_1
local fo_6
fb_1, fh_1, fg_1, fi_1, LocalPlayer, ff_1, e2, e_, Utils, eU, eQ, eO, fa, fm_1, fl_1, e8, result, fk_1, fj_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local fe = 42
repeat
    local fn_1 = (fe * 5 + 2) % 11 + 1
    if fn_1 <= 6 then
        if fn_1 <= 3 then
            if fn_1 <= 2 then
                if fn_1 <= 1 then
                    local fo_1 = {
                        "zvzkyp",
                        "xfezycbzb",
                        "eqwf",
                        "csqogkuggs",
                        "vclnikwglez",
                        "uqtcbafl",
                        "oabjavc",
                        "tthn",
                        "kmuhde",
                        "ibdjdveqkvv"
                    }
                    local jM = fe
                    local fp_1 = fo_1[jM % 10 + 1]
                    if fp_1:len() >= fp_1:gsub("(.)", "%1%1", jM % 3 % 2 + 1):len() then
                        fg_1 = "https://discord.gg/K7Qxnxkk46"
                    else
                        e8 = "https://discord.gg/K7Qxnxkk46"
                    end
                    fe = (fe + 42) % 44
                else
                    if (fe * 1 + 3) * 9 % 4 == ((fe * 1 + 3) * 9 + 14) % 4 then
                        e2 = result:WaitForChild("FetchObjects"):InvokeServer()
                    else
                        result = e2:WaitForChild("FetchObjects"):InvokeServer()
                    end
                    fe = (fe + 42) % 44
                end
            else
                if fe * 48209449 + 3 + 5 <= fe * 48209449 + 3 + 5 + 3 then
                    fk_1 = {}
                    fj_1 = {}
                else
                    fj_1 = {}
                    fk_1 = {}
                end
                fe = (fe + 42) % 44
            end
        elseif fn_1 <= 5 then
            if fn_1 <= 4 then
                local fo_2 = (vector.create((fe * 2 + 2) % 11 + 1, (fe * 10 + 4) % 13 + 1, (fe * 13 + 9) % 17 + 1))
                local fp_2 = (vector.create((fe * 4 + 6) % 11 + 1, (fe * 5 + 9) % 13 + 1, (fe * 9 + 7) % 17 + 1))
                local fq = (vector.create((fe * 5 + 4) % 11 + 1, (fe * 6 + 7) % 13 + 1, (fe * 1 + 17) % 17 + 1))
                local fr = (vector.create((fe * 4 + 6) % 11 + 1, (fe * 2 + 12) % 13 + 1, (fe * 5 + 8) % 17 + 1))
                if vector.dot(vector.cross(fo_2, fp_2), (vector.cross(fq, fr))) == vector.dot(fo_2, fq) * vector.dot(fp_2, fr) - vector.dot(fo_2, fr) * vector.dot(fp_2, fq) then
                    fb_1 = game:GetService("Players")
                else
                    fj_1 = game:GetService("Players")
                end
                fe = (fe + 20) % 44
            else
                local fo_3 = (vector.create((fe * 4 + 2) % 11 + 1, (fe * 11 + 9) % 13 + 1, (fe * 15 + 6) % 17 + 1))
                local fp_3 = (vector.create((fe * 4 + 1) % 11 + 1, (fe * 2 + 8) % 13 + 1, (fe * 3 + 14) % 17 + 1))
                local jQ = vector.cross(fo_3, fp_3)
                local jR = vector.dot(fo_3, fp_3)
                if vector.dot(jQ, jQ) + jR * jR == vector.dot(fo_3, fo_3) * vector.dot(fp_3, fp_3) + 5 then
                    game:GetService("ReplicatedStorage")
                else
                    fh_1 = game:GetService("ReplicatedStorage")
                end
                fe = (fe + 20) % 44
            end
        else
            local j1 = bit32.rrotate(bit32.bxor(bit32.lrotate(fe, 17), string.byte(tostring(Utils))), 5)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(j1, 2146301771), 1212403029), (bit32.bxor(bit32.band(j1, 2148665524), 4171212595))), 1212403029), 4171212595) == j1 then
                fg_1 = game:GetService("RunService")
                fi_1 = game:GetService("Workspace")
            else
                fi_1 = game:GetService("RunService")
                fg_1 = game:GetService("Workspace")
            end
            fe = (fe + 31) % 44
        end
    elseif fn_1 <= 9 then
        if fn_1 <= 8 then
            if fn_1 <= 7 then
                local fo_4 = {
                    "gxtdw",
                    "jxaftwvrpz",
                    "illzigexby",
                    "ktdctmaqyna",
                    "raykgsmafw",
                    "qdxqympeghl",
                    "doh",
                    "cqhhcylbwkb"
                }
                local j2 = fe
                local fp_4 = fo_4[j2 % 8 + 1]
                if fp_4:len() <= fp_4:gsub("(.)", "%1%1", j2 % 3 % 2 + 1):len() then
                    LocalPlayer = fb_1.LocalPlayer
                else
                    fb_1 = LocalPlayer.LocalPlayer
                end
                fe = (fe + 20) % 44
            else
                if fe * 20666459 + 13 + 5 >= fe * 20666459 + 13 + 5 + 2 then
                    fh_1 = ff_1:WaitForChild("Events")
                else
                    ff_1 = fh_1:WaitForChild("Events")
                end
                fe = (fe + 9) % 44
            end
        else
            local fo_5 = {
                "rgjaklci",
                "xmnkwvwu",
                "vwyp",
                "qfcma",
                "jhdvhxk",
                "xfe",
                "neksfyjy",
                "gdj",
                "mien",
                "welqxlzc",
                "egv",
                "fmpgumva"
            }
            local jN = fe
            local fp_5 = fo_5[jN % 12 + 1]
            local fz = if fp_5:len() <= fp_5:reverse():rep(jN % 3 + 2):len() then 1 else 0
            if fz == 1 then
                e2 = ff_1:WaitForChild("ToServer")
            else
                ff_1 = e2:WaitForChild("ToServer")
            end
            fe = (fe + 20) % 44
        end
    elseif fn_1 <= 10 then
        if fe * 131208777 + 6 + 2 <= fe * 131208777 + 6 + 2 + 4 then
            e_ = ff_1:WaitForChild("ToClient")
            Utils = fh_1:WaitForChild("Utils")
            eU = require(Utils:WaitForChild("Bignum"))
            eQ = require(Utils:WaitForChild("GridLayout"))
            eO = require(Utils:WaitForChild("Replicate"))
        else
            ff_1 = fh_1:WaitForChild("ToClient")
            e_ = Utils:WaitForChild("Utils")
            eQ = require(e_:WaitForChild("Bignum"))
            eO = require(e_:WaitForChild("GridLayout"))
            eU = require(e_:WaitForChild("Replicate"))
        end
        fe = (fe + 42) % 44
    else
        if (not fg_1 or not eQ or fh_1 and ff_1) and (fg_1 or not ff_1 or not eQ and result) and (result and fh_1 and (eQ or fb_1) and (fh_1 and ff_1 or fg_1 and not fh_1)) and (result and not ff_1 and (not fg_1 or not fh_1) and ((ff_1 or fg_1) and (fg_1 and not fb_1)) or (result and fg_1 or (not fb_1 or ff_1)) and ((fg_1 or not result) and (not fh_1 or fh_1))) and not ((not fg_1 or not eQ or fh_1 and ff_1) and (fg_1 or not ff_1 or not eQ and result) and (result and fh_1 and (eQ or fb_1) and (fh_1 and ff_1 or fg_1 and not fh_1)) and (result and not ff_1 and (not fg_1 or not fh_1) and ((ff_1 or fg_1) and (fg_1 and not fb_1)) or (result and fg_1 or (not fb_1 or ff_1)) and ((fg_1 or not result) and (not fh_1 or fh_1)))) then
            fl_1 = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
            fm_1 = getgenv().Library
            local _ = getgenv().ThemeManager
            fa = getgenv().SaveManager
        else
            fa = getgenv().Library
            fm_1 = getgenv().ThemeManager
            fl_1 = getgenv().SaveManager
        end
        fe = (fe + 20) % 44
    end
until (fe * 43 + 0) % 44 == 2
for k, v in result do
    if string.sub(k, 1, 1) == "F" then
        table.insert(fk_1, string.format("%s | %s", k, v.Name))
    elseif string.sub(k, 1, 1) == "D" then
        table.insert(fj_1, string.format("%s | %s", k, v.Name))
    end
end
Buyers, fd_2, e9, eS = nil, nil, nil, nil
local fb_2 = 0
repeat
    local fe_1 = (fb_2 * 1 + 1) % 3 + 1
    if fe_1 <= 2 then
        if fe_1 <= 1 then
            if fb_2 * 125435399 + 11 + 4 >= fb_2 * 125435399 + 11 + 4 + 4 then
                e9 = {}
                fd_2 = {}
            else
                fd_2 = {}
                e9 = {}
            end
            fb_2 = (fb_2 + 16) % 24
        else
            local j3 = bit32.rrotate(bit32.bxor(bit32.lrotate(fb_2, 13), string.byte(tostring(e9))), 30)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(j3, 745157469), 2002199810), (bit32.bxor(bit32.band(j3, 3549809826), 3231788161))), 2002199810), 3231788161) ~= j3 then
                table.sort(eS)
                table.sort(fk_1)
                fj_1 = fn48
            else
                table.sort(fk_1)
                table.sort(fj_1)
                eS = fn48
            end
            fb_2 = (fb_2 + 13) % 24
        end
    else
        local fe_2 = {
            "ucckgzqlspl",
            "vkhwifslfnsm",
            "hgmdp",
            "nkzgr",
            "cqkwiui",
            "plqp",
            "wlbuyubbiq",
            "akrgqwmw",
            "lezidvpmoic",
            "vinmisnmiy",
            "rmkiiucdg",
            "aoeb",
            "pzeyl",
            "vrqfue",
            "plumwlx"
        }
        if fe_2[(fb_2 * 82 + 33) % 15 + 1] <= fe_2[(fb_2 * 82 + 33) % 15 + 1] then
            Buyers = fi_1:WaitForChild("SellRoad"):WaitForChild("Buyers")
        else
            fi_1 = Buyers:WaitForChild("SellRoad"):WaitForChild("Buyers")
        end
        fb_2 = (fb_2 + 13) % 24
    end
until (fb_2 * 7 + 18) % 24 == 0
for i, child in Buyers:GetChildren() do
    local fb_3 = child:FindFirstChild("Part") or child:FindFirstChildWhichIsA("BasePart", true)
    if fb_3 then
        table.insert(fd_2, child.Name)
        e9[child.Name] = fb_3.Position
    end
end
e3, eX, eT, eV, eR, eY, eN = nil, nil, nil, nil, nil, nil, nil
table.sort(fd_2)
e3 = { Plot = nil, GridFloor = nil, Grid = nil, Areas = {}, Stock = {} }
local function fb_4()
    local fQ
    fQ = nil
    local fT_1
    fQ = nil
    local connection = e_.SyncPlot.OnClientEvent:Connect(function(P)
        fQ = P
    end)
    e2.RequestPlot:FireServer()
    local fS = os.clock()
    repeat
        task.wait()
        fT_1 = fQ or os.clock() - fS > 5
    until fT_1
    connection:Disconnect()
    if not fQ then
        return
    end
    e3.Plot = eO.get(fQ)
    e3.GridFloor = e3.Plot:WaitForChild("GridFloor")
    e3.Grid = eQ.new(e3.GridFloor, 4)
end
e_.SyncPlot.OnClientEvent:Connect(onOnClientEvent)
e_.SyncPlotAreas.OnClientEvent:Connect(onOnClientEvent2)
e_.SyncStock.OnClientEvent:Connect(onOnClientEvent3)
fb_4()
e2.RequestPlotAreas:FireServer()
eX = fn481
eT = fn282
eV = fn455
eR = fn318
eY = fn285
eN = fn88
local Window = fa:CreateWindow({
    Title = "Hack A Business",
    Footer = "Tempo Hub",
    Icon = 18657887261,
    NotifySide = "Right",
    ShowCustomCursor = false
})
local fh_2 = { Main = Window:AddTab("Main", "bot"), ["UI Settings"] = Window:AddTab("UI Settings", "settings") }
for k, v in fh_2 do
    fn260(v)
end
Options, Toggles, OfferGui, e4, fo_6, eW, e1, eP = nil, nil, nil, nil, nil, nil, nil, nil
local AutoBuyGroup = fh_2.Main:AddLeftGroupbox("Auto Buy")
AutoBuyGroup:AddDropdown("BuyAntennas", { Text = "Antennas", Values = fk_1, Default = {}, Multi = true })
AutoBuyGroup:AddDropdown("BuyServers", { Text = "Servers", Values = fj_1, Default = {}, Multi = true })
AutoBuyGroup:AddSlider("BuyDelay", { Text = "Buy Delay", Default = 0.4, Min = 0.1, Max = 3, Rounding = 1, Suffix = "s" })
AutoBuyGroup:AddToggle("AutoBuy", { Text = "Auto Buy", Default = false })
local AutoPlaceGroup = fh_2.Main:AddRightGroupbox("Auto Place")
AutoPlaceGroup:AddToggle("PlaceAntennas", { Text = "Place Antennas", Default = true })
AutoPlaceGroup:AddToggle("PlaceServers", { Text = "Place Servers", Default = true })
AutoPlaceGroup:AddSlider("PlaceDelay", { Text = "Place Delay", Default = 0.6, Min = 0.2, Max = 3, Rounding = 1, Suffix = "s" })
AutoPlaceGroup:AddToggle("AutoPlace", { Text = "Auto Place", Default = false })
local PlotAreasGroup = fh_2.Main:AddRightGroupbox("Plot Areas")
PlotAreasGroup:AddToggle("AutoArea", { Text = "Auto Buy Areas", Default = false })
PlotAreasGroup:AddSlider("AreaDelay", { Text = "Area Delay", Default = 1, Min = 0.3, Max = 5, Rounding = 1, Suffix = "s" })
local ServersGroup = fh_2.Main:AddLeftGroupbox("Servers")
ServersGroup:AddToggle("AutoCollect", { Text = "Auto Collect Servers", Default = false })
ServersGroup:AddSlider("CollectDelay", { Text = "Collect Delay", Default = 1, Min = 0.2, Max = 5, Rounding = 1, Suffix = "s" })
ServersGroup:AddToggle("AutoLock", { Text = "Auto Lock Plot", Default = false })
local SellingGroup = fh_2.Main:AddRightGroupbox("Selling")
if (not OfferGui and AutoBuyGroup and (not fo_6 or AutoBuyGroup) or OfferGui and fo_6 and (not AutoBuyGroup and eP) or (not AutoBuyGroup and OfferGui or (not eW or eP)) and (not AutoBuyGroup and not AutoBuyGroup or not OfferGui and OfferGui)) and not (not OfferGui and AutoBuyGroup and (not fo_6 or AutoBuyGroup) or OfferGui and fo_6 and (not AutoBuyGroup and eP) or (not AutoBuyGroup and OfferGui or (not eW or eP)) and (not AutoBuyGroup and not AutoBuyGroup or not OfferGui and OfferGui)) then
    fa:AddDropdown("OfferArea", { Default = Options[1], Values = Options, Text = "Offer Area", Multi = false })
    fa:AddToggle("AutoTeleport", { Text = "Teleport To Offer Area", Default = false })
    fa:AddToggle("AutoAccept", { Text = "Auto Accept Offers", Default = false })
    fa:AddInput("MinMoney", { Finished = true, Numeric = true, Text = "Min Money", Default = "0" })
else
    SellingGroup:AddDropdown("OfferArea", { Text = "Offer Area", Values = fd_2, Default = fd_2[1], Multi = false })
    SellingGroup:AddToggle("AutoTeleport", { Text = "Teleport To Offer Area", Default = false })
    SellingGroup:AddToggle("AutoAccept", { Text = "Auto Accept Offers", Default = false })
    SellingGroup:AddInput("MinMoney", { Text = "Min Money", Default = "0", Numeric = true, Finished = true })
    Options = fa.Options
end
Toggles = fa.Toggles
eW = fn74
task.spawn(autoBuyLoop)
task.spawn(autoPlaceLoop)
task.spawn(autoAreaLoop)
task.spawn(autoCollectLoop)
task.spawn(autoLockLoop)
OfferGui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("OfferGui")
task.spawn(autoTeleportLoop)
e4 = 0
e1 = fn467
eP = fn119
e_.Offer.OnClientEvent:Connect(onOnClientEvent4)
task.spawn(autoAcceptLoop)
local MenuGroup = fh_2["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", onUnload)
fa.ToggleKeybind = Options.MenuKeybind
fa:OnUnload(fn59)
fm_1:SetLibrary(fa)
fl_1:SetLibrary(fa)
fm_1:SetFolder("TempoHub")
fl_1:SetFolder("TempoHub/HackABusiness")
fl_1:IgnoreThemeSettings()
fl_1:SetIgnoreIndexes({ "MenuKeybind" })
fm_1:SaveDefault("Mint")
fm_1:ApplyToTab(fh_2["UI Settings"])
fm_1:LoadDefault()
fl_1:BuildConfigSection(fh_2["UI Settings"])
fl_1:LoadAutoloadConfig()
end)(...)

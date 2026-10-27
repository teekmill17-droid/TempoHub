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
getgenv().TempoHoodSubtitle = "MY SWORD EMPIRE"
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
local kf
local jX
local CurrentCamera
local Options
local j2
local kL
local kr
local j8
local jQ
local LocalPlayer
local ke
local jW
local kE
local kk
local j1
local kK
local Library
local j7
local connection
local kx
local kd
local jV
local VirtualUser
local kj
local j0
local kJ
local kp
local j6
local jO
local kw
local kc
local jU
local kC
local ki
local Remotes
local kI
local SaveManager
local j5
local jN
local kv
local kb
local jT
local HttpService
local kh
local UserInputService
local j4
local jM
local kt
local ka
local jS
local kA
local Toggles
local jY
local connection2
local km
local j3
local jL
local ks
local j9
local jR
local kz
local function fn14()
    local oi = jQ()
    if not oi then
        return
    end
    local oi_1 = (LocalPlayer:GetAttribute("CashToCollect"))
    local oo = if oi_1 then 1 else 0
    local om = 3406 * oo + 3648 * (1 - oo)
    local on = 641 * oo + 3249 * (1 - oo)
    if not ((om * 1158 + on * 1200 + om * on) % 16777213 == 6896594) then
        oi_1 = 0
    end
    if oi_1 >= Options.CollectThreshold.Value then
        j5()
    end
end
local function fn23(cb, cc)
    return string.format('<font color="%s">%s</font>', cc, cb)
end
local function fn33()
    local nt_1
    local ns_1
    if identifyexecutor then
        nt_1, ns_1 = identifyexecutor()
        local nu = nt_1 ~= ""
        local nv = type(nt_1) == "string" and nu
        if nv then
            local nu_1 = type(ns_1) == "string" and ns_1 ~= "" and nt_1 .. " " .. ns_1
            kv = nu_1 or nt_1
        end
    end
end
local function fn50()
    local np = kx()
    local nq = np and np:FindFirstChild("HumanoidRootPart")
    return nq
end
local function onCopyVenmoLink()
    jT(j1, "Copied Venmo link")
end
local function fn66()
    return j2.Bases:FindFirstChild(LocalPlayer:GetAttribute("AssignedBase"))
end
local function fn83(ce, cf, cg)
    return string.format("<b>%s</b> %s %s", ce, jU("-", "#5a6070"), jU(cf, cg))
end
local function fn113()
    local nm = kx()
    local nn = nm and nm:FindFirstChildOfClass("Humanoid")
    return nn
end
local function fn137()
    local ph = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local pi = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if pi then
                local pi_1 = kJ(k, v)
                if pi_1 then
                    ph[#ph + 1] = pi_1
                end
            end
        end
    end
    table.sort(ph, function(gg, gh)
        if gg.type ~= gh.type then
            return gg.type < gh.type
        end
        return gg.idx < gh.idx
    end)
    return { objects = ph }
end
local function onInputChanged(fC)
    local UserInputType = fC.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        kk = tick()
    end
end
local function onRenderStepped(eT)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local oB_1 = kr()
        if oB_1 then
            oB_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local oB_3 = kh()
        local oC = kr()
        if oB_3 and oC then
            oC.PlatformStand = true
            local oC_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                oC_1 = oC_1 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                oC_1 = oC_1 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                oC_1 = oC_1 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                oC_1 = oC_1 + CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                oC_1 = oC_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                oC_1 = oC_1 - Vector3.new(0, 1, 0)
            end
            oB_3.Velocity = Vector3.zero
            if oC_1.Magnitude > 0 then
                oB_3.CFrame = oB_3.CFrame + oC_1.Unit * Options.FlySpeed.Value * eT
            end
        end
    end
end
local function onCopyEthereumAddress()
    jT(kj, "Copied Ethereum address")
end
local function onCopySolanaAddress()
    jT(ka, "Copied Solana address")
end
local function fn228(ag)
    local l5 = kK()
    if not l5 or not ag then
        return false
    end
    l5.CFrame = ag.CFrame * CFrame.new(0, 3, -3)
    task.wait(0.35)
    return true
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local op_1 = kx()
        if op_1 then
            for i, descendant in ipairs(op_1:GetDescendants()) do
                local op_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if op_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn292()
    if not Toggles.WalkSpeedEnabled.Value then
        local oH = kr()
        if oH then
            oH.WalkSpeed = 16
        end
    end
end
local function fn330(V)
    return (V:gsub("^RollingSword_", ""):gsub("^Sword$", ""))
end
local function fn332()
    local n6 = kt()
    local n6_5
    if not n6 then
        return
    end
    local n7 = n6:GetAttribute("SwordName") or n6.Name
    local n7_3
    local n7_1 = jV[n7]
    if (n7_1 and n7_1.Machine or "Grindstone") ~= "Grindstone" then
        return
    end
    local n6_4 = jQ()
    if not n6_4 then
        return
    end
    n6_5, n7_3 = kI(j0.Grindstone)
    if not n6_5 then
        return
    end
    kL(n7_3.Parent)
    task.wait(0.15)
    kC(n7_3)
end
local function fn353()
    local oc = kt()
    local oc_5
    if not oc then
        return
    end
    local od = (oc:GetAttribute("SwordName"))
    local od_3
    local oh = if od then 1 else 0
    local of = 3786 * oh + 2524 * (1 - oh)
    local og = 1437 * oh + 1303 * (1 - oh)
    if not ((of * 2113 + og * 2103 + of * og) % 16777213 == 16462311) then
        od = oc.Name
    end
    local od_1 = jV[od]
    if (od_1 and od_1.Machine or "Grindstone") ~= "Enchantment" then
        return
    end
    local oc_4 = jQ()
    if not oc_4 then
        return
    end
    oc_5, od_3 = kI(j0.Enchantment)
    if not oc_5 then
        return
    end
    kL(od_3.Parent)
    task.wait(0.15)
    kC(od_3)
end
local function fn369()
    local nR = jQ()
    if not nR then
        return
    end
    local nW = if kt() then 1 else 0
    if nW == 1 then
        return
    end
    local nS = ki(nR)
    if nS then
        kf = false
        local nR_1 = j7(nS.Name)
        local nS_1 = jX[nR_1]
        if nS_1 and Options.BuyRarities.Value[nS_1] then
            return
        end
    elseif kf then
        local nZ = if os.clock() - kb > 6 then 1 else 0
        local nX = 3973 * nZ + 125 * (1 - nZ)
        local nY = 404 * nZ + 3583 * (1 - nZ)
        if not ((nX * 3801 + nY * 213 + nX * nY) % 16777213 == 15304) then
            return
        end
        kf = false
    end
    kw()
    kf = true
    kb = os.clock()
end
local function onUnload()
    Library:Unload()
end
local function onCopyUSDTAddress()
    jT(kd, "Copied USDT address")
end
local function fn400(bN, bO)
    if setclipboard then
        setclipboard(bN)
    elseif toclipboard then
        toclipboard(bN)
    end
    Library:Notify(bO)
end
local function onCollectIncomeNow()
    j5()
end
local function fn412(bU)
    local DiscordGroup = bU:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = jL })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = jL })
end
local function onPlaceHeldSwordNow()
    ks()
end
local function fn496()
    connection:Disconnect()
    connection2:Disconnect()
    jM(false)
    select("#", "Unloaded!")
end
local function fn509(f3, f4)
    local Type = f4.Type
    if Type == "Toggle" then
        return { idx = f3, type = "Toggle", value = f4.Value == true }
    elseif Type == "Slider" then
        return { idx = f3, type = "Slider", value = tostring(f4.Value) }
    elseif Type == "Dropdown" then
        return { idx = f3, type = "Dropdown", multi = f4.Multi == true, value = f4.Value }
    elseif Type == "Input" then
        local pe = f4.Value or ""
        return { idx = f3, type = "Input", text = tostring(pe) }
    elseif Type == "ColorPicker" then
        return { idx = f3, type = "ColorPicker", value = f4.Value:ToHex(), transparency = f4.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = f3,
            type = "KeyPicker",
            mode = f4.Mode,
            key = f4.Value,
            modifiers = f4.Modifiers,
            toggled = f4.Toggled
        }
    else
        return nil
    end
end
local function fn517()
    local mZ = jQ()
    if not mZ or not mZ.Collect then
        return
    end
    local m__1 = mZ.Collect.Holder or mZ.Collect:FindFirstChildOfClass("MeshPart") or mZ.Collect
    kL(m__1)
    task.wait(1)
end
local function onImportConfigFromClipboardTex()
    local pL_1
    local pJ = Options.SaveManager_ImportSource.Value or ""
    local pJ_1
    local pK = tostring(pJ):match("^%s*(.-)%s*$")
    if pK == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    pJ_1, pL_1 = pcall(HttpService.JSONDecode, HttpService, pK)
    local pK_1 = not pJ_1 or type(pL_1) ~= "table" or type(pL_1.objects) ~= "table"
    if pK_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local pJ_2 = 0
    for i, v in ipairs(pL_1.objects) do
        if jW(v) then
            pJ_2 += 1
        end
    end
    if pJ_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local pL_2 = pJ_2 == 1 and ""
    local pP = if pL_2 then 1 else 0
    local pN = 122 * pP + 668 * (1 - pP)
    local pO = 727 * pP + 4083 * (1 - pP)
    if not ((pN * 3024 + pO * 2127 + pN * pO) % 16777213 == 2003951) then
        pL_2 = "s"
    end
    Library:Notify(("Imported %d setting%s"):format(pJ_2, pL_2), 6)
end
local function onCopyBitcoinAddress()
    jT(km, "Copied Bitcoin address")
end
local function fn583()
    local ma = jQ()
    if not ma or not ma.Lever then
        return
    end
    local RollPrompt = ma.Lever:FindFirstChild("RollPrompt", true)
    if not RollPrompt then
        return
    end
    kL(RollPrompt.Parent)
    task.wait(0.15)
    kC(RollPrompt)
end
local function onRscripts()
    if setclipboard then
        setclipboard(j6)
    elseif toclipboard then
        toclipboard(j6)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function fn589(T)
    return T.SwordRollRuntime:FindFirstChildOfClass("Tool")
end
local function fn593()
    local lL = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    return lL
end
local function fn596()
    local MoneyValue = LocalPlayer:FindFirstChild("MoneyValue")
    return MoneyValue and MoneyValue.Value or 0
end
local function fn597()
    if not Toggles.Fly.Value then
        local oF = kr()
        if oF then
            oF.PlatformStand = false
        end
    end
end
local function fn611(aH)
    for k, v in aH do
        local PlacePrompt = v.Placement:FindFirstChild("PlacePrompt")
        local my = PlacePrompt and PlacePrompt.ActionText:lower() == "place"
        if my then
            return v, PlacePrompt
        end
    end
    return nil, nil
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local o2 = tick() - kk
            local o3 = tick() - ke
            if o2 >= 300 and o3 >= 60 then
                pcall(jY)
            else
                if o2 < 300 and o3 >= 300 then
                    pcall(jY)
                end
            end
        end
    end
end
local function fn641()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    ke = tick()
end
local function fn669()
    local md = jQ()
    if not md then
        return
    end
    local me = ki(md)
    if not me then
        return
    end
    local md_1 = nil
    for i, descendant in me:GetDescendants() do
        local mf = descendant:IsA("ProximityPrompt") and descendant.ActionText:lower():find("buy")
        if mf then
            md_1 = descendant
            break
        end
    end
    if not md_1 then
        for i, descendant in me:GetDescendants() do
            if descendant:IsA("ProximityPrompt") then
                md_1 = descendant
                break
            end
        end
    end
    if not md_1 then
        return
    end
    kL(md_1.Parent)
    task.wait(0.15)
    kC(md_1)
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            jM(true)
        end
    end
end
local function fn688()
    jM(Toggles.AntiGameplayPause.Value)
end
local function worker()
    local nD_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local nC = math.floor(os.clock() - jS)
        if nC < 60 then
            nD_1 = nC .. "s"
        elseif nC < 3600 then
            nD_1 = string.format("%dm %ds", math.floor((nC) / (60)), nC % 60)
        else
            nD_1 = string.format("%dh %dm", math.floor((nC) / (3600)), math.floor((nC % 3600) / (60)))
        end
        j8:SetText(jO("Session time", nD_1, kz))
    end
end
local function fn696()
    local mK = jQ()
    if not mK then
        return
    end
    for k, v in pairs(j0) do
        for k, v in v do
            local PlacePrompt = v.Placement:FindFirstChild("PlacePrompt")
            local mL = PlacePrompt and PlacePrompt.ActionText:lower() == "release"
            if mL then
                kL(PlacePrompt.Parent)
                task.wait(0.15)
                kC(PlacePrompt)
                task.wait(0.8)
            end
        end
    end
end
local function onInputBegan()
    kk = tick()
end
local function fn706(fW, fX)
    local o7_1 = (fW == "Toggle" and Toggles or Options)[fX]
    local o6_2 = type(o7_1) == "table" and o7_1.Type == fW
    return o6_2 and o7_1 or nil
end
local function fn734()
    jT(kc, "Copied Discord invite to clipboard")
end
local function fn737()
    return LocalPlayer.Character
end
local function onCopyLitecoinAddress()
    jT(kp, "Copied Litecoin address")
end
local function onCopyPayPalLink()
    jT(j4, "Copied PayPal link")
end
local function fn799()
    if not LocalPlayer.Character then
        return nil
    end
    for i, child in LocalPlayer.Character:GetChildren() do
        local lQ = child:IsA("Tool") and child:GetAttribute("IsPurchasedSword")
        if lQ then
            return child
        end
    end
    return nil
end
local function fn801()
    local m2_1
    local m1_1
    m1_1, m2_1 = pcall(function()
        return Remotes.GetUpgrades:InvokeServer()
    end)
    if not m1_1 or not m2_1 then
        return
    end
    local m1_2 = m2_1.Upgrades or m2_1
    for i, v in ipairs(jR) do
        local m1_3 = m1_2[v]
        if m1_3 then
            local m3_1 = m1_3.Level or 0
            local m4_1 = m1_3.MaxLevel or 0
            local m5 = m1_3.Cost or 0
            local m6 = m1_3.IsMaxed or false
            jN[v] = { Level = m3_1, MaxLevel = m4_1, Cost = m5, IsMaxed = m6 }
        end
    end
end
local function fn813()
    local mI_1
    local mG = kt()
    local mG_5
    if not mG then
        return
    end
    local mH = mG:GetAttribute("SwordName") or mG.Name
    local mH_1 = jV[mH]
    local mH_2 = mH_1 and mH_1.Machine or "Grindstone"
    local mH_3 = jQ()
    if not mH_3 then
        return
    end
    local mG_4 = mH_2 == "Enchantment" and j0.Enchantment or j0.Grindstone
    mG_5, mI_1 = kI(mG_4)
    if not mG_5 then
        return
    end
    kL(mI_1.Parent)
    task.wait(0.15)
    kC(mI_1)
end
local function onCopyJoinScript_JobID()
    local nA = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, j3)
    if setclipboard then
        setclipboard(nA)
    elseif toclipboard then
        toclipboard(nA)
    end
    Library:Notify("Copied join script to clipboard")
end
local function fn830()
    local n_ = jQ()
    if not n_ then
        return
    end
    if kt() then
        return
    end
    local n0 = ki(n_)
    if not n0 then
        return
    end
    local n__1 = j7(n0.Name)
    local n0_1 = jX[n__1]
    if n0_1 and not Options.BuyRarities.Value[n0_1] then
        return
    end
    local n0_2 = jV[n__1]
    local n0_3 = n0_2 and n0_2.Cost or 0
    if kE() >= n0_3 then
        j9()
    end
end
local function fn855()
    local lY = jQ()
    if not lY then
        return
    end
    j0.Grindstone = {}
    j0.Enchantment = {}
    for i, child in lY:GetChildren() do
        local lY_1 = child:IsA("Model") and child:FindFirstChild("Placement")
        if lY_1 then
            local PlacePrompt = child.Placement:FindFirstChild("PlacePrompt")
            if PlacePrompt then
                if child.Name:lower():find("grind") then
                    table.insert(j0.Grindstone, child)
                elseif child.Name:lower():find("enchant") then
                    table.insert(j0.Enchantment, child)
                end
            end
        end
    end
end
local function onExportConfigToClipboard()
    local pG_1
    local pF_1
    pF_1, pG_1 = pcall(HttpService.JSONEncode, HttpService, kA())
    if not pF_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local pF_2 = setclipboard or toclipboard
    local pF_3 = type(pF_2) ~= "function" or not pcall(pF_2, pG_1)
    if pF_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local oz_1 = kr()
        if oz_1 then
            oz_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
jL = nil
jM = nil
jN = nil
jO = nil
connection = nil
jQ = nil
jR = nil
jS = nil
jT = nil
jU = nil
jV = nil
jW = nil
jX = nil
jY = nil
Remotes = nil
j0 = nil
j1 = nil
j2 = nil
j3 = nil
j4 = nil
j5 = nil
j6 = nil
j7 = nil
j8 = nil
j9 = nil
ka = nil
kb = nil
kc = nil
kd = nil
ke = nil
kf = nil
Toggles = nil
kh = nil
ki = nil
kj = nil
kk = nil
Options = nil
km = nil
SaveManager = nil
kp = nil
Library = nil
kr = nil
ks = nil
kt = nil
kv = nil
kw = nil
kx = nil
LocalPlayer = nil
local jZ, kn
kz = nil
kA = nil
HttpService = nil
kC = nil
VirtualUser = nil
kE = nil
CurrentCamera = nil
connection2 = nil
UserInputService = nil
kI = nil
kJ = nil
kK = nil
kL = nil
local kM, kX, kY, kZ, k_, k0, k2, k3, k4, FaqGroup, Auto_UpgradeGroup
local k1_7
UserInputService, VirtualUser, HttpService, LocalPlayer, Library, SaveManager, Options, Toggles, kc, j6, j2, Remotes, jX = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local kN = game:GetService("Players")
local kQ = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
LocalPlayer = kN.LocalPlayer
local kS = "My Sword Empire"
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Options = Library.Options
Toggles = Library.Toggles
kc = "https://discord.gg/K7Qxnxkk46"
j6 = "https://discord.gg/K7Qxnxkk46"
j2 = workspace
Remotes = kQ:WaitForChild("Remotes")
local kR = require(kQ.Configs.SwordRollConfig)
jX = {}
kN = {}
local kO = kR.SwordStats or kN
jV = kO
kN = {}
kO = kR.Swords or kN
for k, v in kO do
    jX[v.Name] = v.Rarity
end
j0, jR, jN, jQ, kK, kE, kt, ki, j7, kL, kC, kw, j9, kI, ks, j5, kM, kn, jT, jL, kx, kr, kh = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
jQ = fn66
if (false and j9 and (not kE and not kE) or (kE and not j9 or (not j9 or false)) or (false or kC or kE and kE) and ((false or kC) and (false or j9))) and ((not j9 or kC or (not kE or j9) or (not kE or not j9) and (kE or false)) and (kC or kE or j9 and false or (j9 or kC or not j9 and kC))) and not ((false and j9 and (not kE and not kE) or (kE and not j9 or (not j9 or false)) or (false or kC or kE and kE) and ((false or kC) and (false or j9))) and ((not j9 or kC or (not kE or j9) or (not kE or not j9) and (kE or false)) and (kC or kE or j9 and false or (j9 or kC or not j9 and kC)))) then
    kE = fn593
    kK = fn596
else
    kK = fn593
    kE = fn596
end
kt = fn799
ki = fn589
j7 = fn330
j0 = { Grindstone = {}, Enchantment = {} }
kR = fn855
kL = fn228
kC = function(ak)
    if not ak then
        return false
    end
    pcall(function()
        fireproximityprompt(ak)
    end)
    return true
end
kw = fn583
j9 = fn669
kI = fn611
ks = fn813
j5 = fn517
jR = { "RollSpeed", "Luck", "IncomeMultiplier" }
kQ = { RollSpeed = "Roll Speed", Luck = "Luck", IncomeMultiplier = "Sword Value" }
jN = {}
kM = fn801
kn = function(bD)
    local ne = jN[bD]
    local nf = not ne
    local nk = if nf then 1 else 0
    local ni = 3230 * nk + 280 * (1 - nk)
    local nj = 3863 * nk + 2220 * (1 - nk)
    if not ((ni * 2166 + nj * 576 + ni * nj) % 16777213 == 4921545) then
        nf = ne.IsMaxed
    end
    if nf then
        return
    end
    local nf_1 = kE()
    if nf_1 >= (ne.Cost or 0) then
        pcall(function()
            Remotes.PurchaseUpgrade:InvokeServer(bD)
        end)
        task.wait(0.5)
        kM()
    end
end
jT = fn400
jL = fn734
kx = fn737
kr = fn113
kh = fn50
kO = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = kc, Copyable = true }, "|", kS },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
local kW = {
    Info = kO:AddTab("Info", "info"),
    Auto = kO:AddTab("Auto", "refresh-cw"),
    Upgrades = kO:AddTab("Upgrades", "trending-up"),
    Inventory = kO:AddTab("Inventory", "package"),
    Player = kO:AddTab("Player", "person-standing"),
    Settings = kO:AddTab("Settings", "settings")
}
kW.Roll = kW.Auto:AddSubTab("Roll", "dices")
kW.Process = kW.Auto:AddSubTab("Process", "hammer")
kW.Income = kW.Auto:AddSubTab("Income", "banknote")
for i, v in ipairs({ kW.Roll, kW.Process, kW.Income, kW.Upgrades, kW.Inventory, kW.Player, kW.Settings }) do
    fn412(v)
end
k0, k_, kz, kZ, kv, kY, j8, j3, kX, jU, jO = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
kO = 43
repeat
    local kP_1 = (kO * 7 + 3) % 9 + 1
    if kP_1 <= 5 then
        if kP_1 <= 3 then
            if kP_1 <= 2 then
                if kP_1 <= 1 then
                    if (kO * 2 + 3) * 4 % 3 == ((kO * 2 + 3) * 4 + 3) % 3 then
                        k0 = "#7fd47f"
                    else
                        kY = "#7fd47f"
                    end
                    kO = (kO + 13) % 72
                else
                    local k1_1 = (vector.create((kO * 5 + 3) % 11 + 1, (kO * 5 + 1) % 13 + 1, (kO * 10 + 6) % 17 + 1))
                    k2 = (vector.create((kO * 1 + 9) % 11 + 1, (kO * 7 + 5) % 13 + 1, (kO * 10 + 7) % 17 + 1))
                    k3 = (vector.create((kO * 6 + 3) % 11 + 1, (kO * 9 + 2) % 13 + 1, (kO * 2 + 13) % 17 + 1))
                    k4 = (vector.create((kO * 1 + 5) % 5 + 1, (kO * 4 + 6) % 7 + 1, (kO * 2 + 4) % 9 + 1))
                    if vector.dot(vector.cross(k1_1, (vector.cross(k2, k3))), k4) == vector.dot(k2 * vector.dot(k1_1, k3) - k3 * vector.dot(k1_1, k2), k4) + 2 then
                        k0 = "#6ec1ff"
                    else
                        k_ = "#6ec1ff"
                    end
                    kO = (kO + 49) % 72
                end
            else
                if kO * 99539717 + 5 + 6 >= kO * 99539717 + 5 + 6 + 1 then
                    jU = "#e8a34d"
                else
                    kz = "#e8a34d"
                end
                kO = (kO + 4) % 72
            end
        elseif kP_1 <= 4 then
            local k1_2 = {
                "avdahpuzvuvn",
                "rnukznpyvfvd",
                "ufsswyq",
                "ljuk",
                "xkgqisr",
                "qjiawmuigqa",
                "wcufwafwlsc",
                "bgg",
                "kvspdc",
                "npbzzpm"
            }
            if k1_2[(kO * 5 + 80) % 10 + 1] <= k1_2[(kO * 5 + 80) % 10 + 1] then
                kZ = "#8b93a3"
            else
                jU = "#8b93a3"
            end
            kO = (kO + 67) % 72
        else
            local k1_3 = (vector.create((kO * 6 + 8) % 11 + 1, (kO * 8 + 9) % 13 + 1, (kO * 14 + 6) % 17 + 1))
            k2 = (vector.create((kO * 1 + 1) % 11 + 1, (kO * 9 + 8) % 13 + 1, (kO * 14 + 17) % 17 + 1))
            k3 = (vector.create((kO * 2 + 1) % 5 + 1, (kO * 3 + 5) % 7 + 1, (kO * 2 + 1) % 9 + 1))
            if math.abs((vector.angle(k1_3, k2, k3))) - math.abs((vector.angle(k2, k1_3, k3))) == 0 then
                kv = "Unknown"
                pcall(fn33)
                kN = kW.Info:AddLeftGroupbox("Account", "circle-user")
                kN:AddLabel(jO("User", LocalPlayer.Name, k0), true)
                kN:AddLabel(jO("Status", "Keyless", k0), true)
                kN:AddLabel(jO("Executor", kv, k0), true)
                kY = kW.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                kY:AddLabel(jU(kS .. " [" .. tostring(game.PlaceId) .. "]", k_), true)
                kY:AddLabel(jO("Place ID", tostring(game.PlaceId), k_), true)
                j8 = kY:AddLabel(jO("Session time", "0s", kz), true)
            else
                pcall(fn33)
                kW = kv.Info:AddLeftGroupbox("Account", "circle-user")
                kW:AddLabel(j8("User", jU.Name, kz), true)
                kW:AddLabel(j8("Status", "Keyless", kz), true)
                kW:AddLabel(j8("Executor", "Unknown", kz), true)
                k0 = kv.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                k0:AddLabel(kY(jO .. " [" .. tostring(game.PlaceId) .. "]", kS), true)
                k0:AddLabel(j8("Place ID", tostring(game.PlaceId), kS), true)
                k_ = k0:AddLabel(j8("Session time", "0s", LocalPlayer), true)
            end
            kO = (kO + 22) % 72
        end
    elseif kP_1 <= 7 then
        if kP_1 <= 6 then
            local k1_4 = {
                "svwxtdndvyi",
                "ish",
                "upeoufeqlks",
                "oau",
                "kvwolsjneir",
                "xbbphrmkg",
                "hzpdjvgubv",
                "dvy",
                "avwltflxsno",
                "nil",
                "yrmjpvvajyh",
                "mbwpm"
            }
            local qJ = kO
            k2 = k1_4[qJ % 12 + 1]
            if k2:len() >= k2:gsub("(.)", "%1%1", qJ % 3 % 2 + 1):len() then
                kz = tostring(game.JobId)
            else
                j3 = tostring(game.JobId)
            end
            kO = (kO + 49) % 72
        else
            local k1_5 = { "qmwjd", "dndxv", "uyxlqfkdwp", "slrgkgfskor", "jlcd", "lxjaazpnve", "nbpvsvmng", "atlmbwxtfq" }
            local qZ = kO
            k2 = k1_5[qZ % 8 + 1]
            if k2:len() <= k2:reverse():rep(qZ % 3 + 2):len() then
                kX = #j3 > 18
            else
                j3 = #kX > 18
            end
            kO = (kO + 22) % 72
        end
    elseif kP_1 <= 8 then
        if kO * 24113103 + 5 + 7 >= kO * 24113103 + 5 + 7 + 1 then
            j8 = fn23
        else
            jU = fn23
        end
        kO = (kO + 22) % 72
    else
        if kO * 65404407 + 4 + 7 >= kO * 65404407 + 4 + 7 + 6 then
            kY = fn83
        else
            jO = fn83
        end
        kO = (kO + 31) % 72
    end
until (kO * 7 + 31) % 72 == 53
if kX then
    kN = 6
    repeat
        kO = (vector.create((kN * 3 + 6) % 11 + 1, (kN * 2 + 2) % 13 + 1, (kN * 14 + 4) % 17 + 1))
        local kP_2 = (vector.create((kN * 7 + 8) % 11 + 1, (kN * 4 + 7) % 13 + 1, (kN * 3 + 9) % 17 + 1))
        local k1_6 = (vector.create((kN * 1 + 4) % 11 + 1, (kN * 3 + 10) % 13 + 1, (kN * 8 + 2) % 17 + 1))
        if vector.dot(vector.cross(kO, kP_2), k1_6) == vector.dot(vector.cross(kP_2, k1_6), kO) + 5 then
            j3 = string.sub(kX, 1, 18) .. "..."
        else
            kX = string.sub(j3, 1, 18) .. "..."
        end
        kN = (kN + 2) % 8
    until (kN * 3 + 2) % 8 == 2
end
kN = kX or j3
jS, kp, km, kj, kd, ka, j4, j1, k4, k1_7, kX, kO, FaqGroup, Auto_UpgradeGroup = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local k7 = kN
kY:AddLabel(jO("Server", k7, kZ), true)
kY:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
jS = os.clock()
task.spawn(worker)
local ScriptsGroup = kW.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(jU("Included in this hub", kZ), true)
ScriptsGroup:AddLabel(jU(kS, k_), true)
local FeaturesGroup = kW.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(jU("Auto Roll & Buy", k_), true)
FeaturesGroup:AddLabel(jU("Auto Grind & Enchant", k0), true)
FeaturesGroup:AddLabel(jU("Auto Collect Income", kz), true)
FeaturesGroup:AddLabel(jU("Auto Upgrades", kZ), true)
local SocialsGroup = kW.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = jL })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = kW.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = jL })
kp = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
km = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
kj = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
kd = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
ka = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
j4 = ""
j1 = ""
local k8 = "#345d9d"
local k5 = "#f7931a"
if (FaqGroup and false or (FaqGroup or not FaqGroup)) and ("0xaE95A405D007a6F858E5d35714111B075fEFb40a" and (not FaqGroup or not FaqGroup)) or not ((FaqGroup and false or (FaqGroup or not FaqGroup)) and ("0xaE95A405D007a6F858E5d35714111B075fEFb40a" and (not FaqGroup or not FaqGroup))) then
    k4 = "#627eea"
end
k2 = "#26a17b"
if kX or false or FaqGroup and kX or kX and FaqGroup and (not kX and kp) or not (kX or false or FaqGroup and kX or kX and FaqGroup and (not kX and kp)) then
    k1_7 = "#14f195"
end
kX = "#0070ba"
local kP_3 = "#008cff"
if ((k7 or not jS) and (not k1_7 and false) and (not Auto_UpgradeGroup and not k7 or (jS or not Auto_UpgradeGroup)) or (jS or jS or (not k7 or k1_7)) and (false and not ScriptsGroup and (jS and ScriptsGroup))) and not ((k7 or not jS) and (not k1_7 and false) and (not Auto_UpgradeGroup and not k7 or (jS or not Auto_UpgradeGroup)) or (jS or jS or (not k7 or k1_7)) and (false and not ScriptsGroup and (jS and ScriptsGroup))) then
    kW = kO.Info:AddRightGroupbox("Donations", "heart")
else
    kO = kW.Info:AddRightGroupbox("Donations", "heart")
end
kO:AddLabel(jU("All donations are optional but appreciated.", kz), true)
kO:AddLabel(jU("If you donate you get a special role, just PING after you donate.", k0), true)
kO:AddDivider()
kO:AddLabel(jU("LTC / Litecoin", k8), true)
kO:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
kO:AddLabel(jU("BTC / Bitcoin", k5), true)
kO:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
kO:AddLabel(jU("ETH / Ethereum", k4), true)
kO:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
kO:AddLabel(jU("USDT", k2), true)
kO:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
kO:AddLabel(jU("Solana", k1_7), true)
kO:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
kO:AddLabel(jU("PayPal", kX), true)
kO:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
kO:AddLabel(jU("Venmo", kP_3), true)
kO:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
kO:AddDivider()
kO:AddLabel(jU("Don't have any of the listed currencies but still wanna donate?", kZ), true)
kO:AddLabel(jU("DM me and we'll work something out.", k_), true)
FaqGroup = kW.Info:AddRightGroupbox("FAQ", "circle-help")
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
local RollingGroup = kW.Roll:AddLeftGroupbox("Rolling", "dices")
RollingGroup:AddToggle("AutoRoll", { Text = "Auto-Roll Sword", Default = false })
RollingGroup:AddSlider("RollInterval", { Text = "Roll Interval", Default = 1.5, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
local ProcessingGroup = kW.Process:AddLeftGroupbox("Processing", "hammer")
ProcessingGroup:AddToggle("AutoGrind", { Text = "Auto-Grind", Default = false })
ProcessingGroup:AddSlider("GrindInterval", { Text = "Grind Interval", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
ProcessingGroup:AddToggle("AutoEnchant", { Text = "Auto-Enchant", Default = false })
ProcessingGroup:AddSlider("EnchantInterval", { Text = "Enchant Interval", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
ProcessingGroup:AddDivider()
ProcessingGroup:AddToggle("AutoRelease", { Text = "Auto-Release", Default = false })
ProcessingGroup:AddSlider("ReleaseInterval", { Text = "Release Interval", Default = 0.8, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
ProcessingGroup:AddButton({ Text = "Place Held Sword Now", Func = onPlaceHeldSwordNow })
local IncomeGroup = kW.Income:AddLeftGroupbox("Income", "banknote")
IncomeGroup:AddToggle("AutoCollect", { Text = "Auto-Collect Income", Default = false })
IncomeGroup:AddSlider("CollectInterval", { Text = "Collect Interval", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
IncomeGroup:AddSlider("CollectThreshold", { Text = "Collect Threshold", Default = 250, Min = 0, Max = 100000, Rounding = 0, Suffix = "$" })
IncomeGroup:AddButton({ Text = "Collect Income Now", Func = onCollectIncomeNow })
k3 = kW.Inventory:AddLeftGroupbox("Buy Shop", "shopping-cart")
k3:AddToggle("AutoBuy", { Text = "Auto-Buy Sword", Default = false })
k3:AddSlider("BuyInterval", { Text = "Buy Interval", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
k3:AddDropdown("BuyRarities", {
    Values = { "Common", "Rare", "Epic", "Legendary", "Mythic", "Secret" },
    Default = { Common = true, Rare = true, Epic = true, Legendary = true, Mythic = true, Secret = true },
    Multi = true,
    Text = "Rarities to Keep & Buy"
})
Auto_UpgradeGroup = kW.Upgrades:AddLeftGroupbox("Auto-Upgrade", "trending-up")
for i, v in ipairs(jR) do
    Auto_UpgradeGroup:AddToggle("AutoUp_" .. v, { Text = "Auto-Upgrade " .. kQ[v], Default = false })
    Auto_UpgradeGroup:AddSlider("UpInterval_" .. v, { Text = kQ[v] .. " Interval", Default = 2, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
end
kf, kb = nil, nil
kR()
kO = function(ds, du, dv)
    task.spawn(function()
        while not Library.Unloaded do
            if Toggles[ds].Value then
                pcall(dv)
            end
            local nP = Options[du] and Options[du].Value or 1
            task.wait(math.max(nP, 0.1))
        end
    end)
end
kf = false
kb = 0
kO("AutoRoll", "RollInterval", fn369)
kO("AutoBuy", "BuyInterval", fn830)
kO("AutoGrind", "GrindInterval", fn332)
kO("AutoEnchant", "EnchantInterval", fn353)
kO("AutoRelease", "ReleaseInterval", fn696)
kO("AutoCollect", "CollectInterval", fn14)
for i, v in ipairs(jR) do
    local lK = v
    kO("AutoUp_" .. lK, "UpInterval_" .. lK, function()
        kM()
        kn(lK)
    end)
end
CurrentCamera, kk, ke, connection, connection2, jM, jY, jZ, kJ, kA, jW = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
kQ = kW.Player:AddLeftGroupbox("Movement", "footprints")
kQ:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
kQ:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
kQ:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
kQ:AddToggle("NoClip", { Text = "NoClip", Default = false })
kQ:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = kW.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn597)
Toggles.WalkSpeedEnabled:OnChanged(fn292)
jM = function(fd)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not fd)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not fd
        end
    end)
    if not fd then
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
Toggles.AntiGameplayPause:OnChanged(fn688)
task.spawn(antiGameplayPauseLoop)
kR = kW.Settings:AddLeftGroupbox("Menu", "menu")
Library.ToggleKeybind = Options.MenuKeybind
kR:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
kk = tick()
ke = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local oX = v
        pcall(function()
            oX:Disable()
        end)
    end
end)
jY = fn641
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
kR:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
kR:AddButton("Unload", onUnload)
task.spawn(antiAfkLoop)
Library:OnUnload(fn496)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Linoria")
ThemeManager:ApplyToTab(kW.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/MySwordEmpire")
kN = SaveManager:BuildConfigSection(kW.Settings)
jZ = fn706
kJ = fn509
kA = fn137
jW = function(gj)
    local pz
    pz = nil
    local pA = type(gj) ~= "table"
    local pE = if pA then 1 else 0
    local pC = 2430 * pE + 3344 * (1 - pE)
    local pD = 1705 * pE + 2466 * (1 - pE)
    if not ((pC * 1020 + pD * 2249 + pC * pD) % 16777213 == 10456295) then
        pA = type(gj.idx) ~= "string"
    end
    if not pA then
        pA = type(gj.type) ~= "string"
    end
    if not pA then
        pA = SaveManager.Ignore[gj.idx]
    end
    if pA then
        return false
    end
    pz = jZ(gj.type, gj.idx)
    if not pz then
        return false
    end
    local pA_1 = pcall(function()
        if gj.type == "Input" then
            if type(gj.text) ~= "string" then
                return
            end
            pz:SetValue(gj.text)
        elseif gj.type == "ColorPicker" then
            pz:SetValueRGB(Color3.fromHex(gj.value), gj.transparency)
        elseif gj.type == "KeyPicker" then
            pz:SetValue({ gj.key, gj.mode, gj.modifiers })
            if gj.mode == "Toggle" and gj.toggled ~= nil then
                pz.Toggled = gj.toggled
                pz:Update()
            end
        else
            pz:SetValue(gj.value)
        end
    end)
    return pA_1
end
kN:AddDivider()
kN:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
kN:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
kN:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
end)(...)

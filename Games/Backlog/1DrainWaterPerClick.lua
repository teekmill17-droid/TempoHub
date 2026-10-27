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
getgenv().TempoHoodSubtitle = "+1 DRAIN WATER PER CLICK"
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
local LocalPlayer, zt_2, zt_9, FeaturesGroup, zt_20, zt_31, ProgressGroup, zt_43, zt_53, zt_57, EggsGroup
LocalPlayer = nil
zt_2 = nil
local pS
local EquipBest
local pz
local qg
local qY
local pY
local pg
local pF
local pm
local Label
local qL
local o3
local pL
local qs
local ps
local qR
local pR
local qy
local o9
local py
local qX
local pX
local qE
local SaveManager
local ql
local p2
local qK
local pK
local p8
local qQ
local onJoinDiscordForKeylessScripts
local pQ
local HttpService
local px
local Workspace
local pe
local pW
local VirtualUser
local qk
local pk
local p1
local AbbNumber
local pJ
local pq
local p7
local o7
local pP
local qw
local qP
local pw
local qd
local qV
local pV
local qC
local pC
local pj
local p0
local qI
local pI
local qp
local pp
local qO
local o6
local pO
local qv
local pv
local qU
local connection2
local qB
local pU
local connection
local qi
local p_
local UserInputService
local o_
local pH
local qo
local po
local p5
local qN
local pN
local qu
local pu
local qT
local pT
local qA
local Toggles
local qh
local pZ
local qG
local pG
local qn
local pn
local p4
local o4
local Library
local Options
function fns.fn31(kL, kM)
    local Type = kM.Type
    if Type == "Toggle" then
        return { idx = kL, type = "Toggle", value = kM.Value == true }
    elseif Type == "Slider" then
        return { idx = kL, type = "Slider", value = tostring(kM.Value) }
    elseif Type == "Dropdown" then
        return { idx = kL, type = "Dropdown", multi = kM.Multi == true, value = kM.Value }
    elseif Type == "Input" then
        local yt = kM.Value or ""
        return { idx = kL, type = "Input", text = tostring(yt) }
    elseif Type == "ColorPicker" then
        return { idx = kL, type = "ColorPicker", value = kM.Value:ToHex(), transparency = kM.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = kL,
            type = "KeyPicker",
            mode = kM.Mode,
            key = kM.Value,
            modifiers = kM.Modifiers,
            toggled = kM.Toggled
        }
    else
        return nil
    end
end
function fns.worker2()
    while not Library.Unloaded do
        task.wait(2)
        if qN("AntiAfk") then
            local zc = tick() - qu
            local zd = tick() - qo
            if zc >= 300 and zd >= 60 then
                pcall(p1)
            else
                if zc < 300 and zd >= 300 then
                    pcall(p1)
                end
            end
        end
    end
end
function fns.onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local xX_1 = qI()
        if xX_1 then
            xX_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
function fns.onCopyUSDTAddress()
    pn(pF, "Copied USDT address")
end
function fns.fn175(aL, aM)
    if aL.Multiplier == aM.Multiplier then
        return aL.RequiredRebirths < aM.RequiredRebirths
    end
    return aL.Multiplier < aM.Multiplier
end
function fns.onCopySolanaAddress()
    pn(pC, "Copied Solana address")
end
function fns.worker10()
    while not Library.Unloaded do
        if qN("AutoCollectAquariumCash") then
            pcall(o3)
        end
        if qN("AutoEquipBestAquarium") then
            pcall(pL)
        end
        if qN("AutoEquipBestPet") then
            pcall(pw)
        end
        task.wait(pX("AquariumDelay", 3))
    end
end
function fns.fn285()
    local xr_1
    local xq_1
    if identifyexecutor then
        xr_1, xq_1 = identifyexecutor()
        local xs = xr_1 ~= ""
        local xt = type(xr_1) == "string" and xs
        if xt then
            local xs_1 = type(xq_1) == "string" and xq_1 ~= "" and xr_1 .. " " .. xq_1
            qC = xs_1 or xr_1
        end
    end
end
function fns.fn307()
    connection:Disconnect()
    connection2:Disconnect()
    qs(false)
end
function fns.onCopyVenmoLink()
    pn(po, "Copied Venmo link")
end
function fns.fn390()
    if not Toggles.Fly.Value then
        local xL = qI()
        if xL then
            xL.PlatformStand = false
        end
    end
end
function fns.worker5()
    while not Library.Unloaded do
        local zi = qN("AutoTrain") and not qN("AutoDrain")
        if zi then
            pcall(p_)
        end
        task.wait(pX("TrainDelay", 0.08))
    end
end
function fns.fn426()
    qs(Toggles.AntiGameplayPause.Value)
end
function fns.fn429(an)
    local r7 = qn[tostring(an)] or 0
    return r7
end
function fns.onRscripts()
    pn(pZ, "Copied Rscripts profile to clipboard")
end
function fns.fn443()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    qo = tick()
end
function fns.onCopyLitecoinAddress()
    pn(pQ, "Copied Litecoin address")
end
function fns.worker()
    local xz_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local xy = math.floor(os.clock() - px)
        if xy < 60 then
            xz_1 = xy .. "s"
        elseif xy < 3600 then
            xz_1 = string.format("%dm %ds", math.floor((xy) / (60)), xy % 60)
        else
            xz_1 = string.format("%dh %dm", math.floor((xy) / (3600)), math.floor((xy % 3600) / (60)))
        end
        Label:SetText(qB("Session time", xz_1, p0))
    end
end
function fns.onCopyPayPalLink()
    pn(pu, "Copied PayPal link")
end
function fns.fn549(az, aA)
    return az.Id < aA.Id
end
function fns.worker3()
    while not Library.Unloaded do
        task.wait(1)
        if qN("AntiGameplayPause") then
            qs(true)
        end
    end
end
function fns.onCopyEthereumAddress()
    pn(pJ, "Copied Ethereum address")
end
function fns.worker6()
    while not Library.Unloaded do
        if qN("AutoRebirth") then
            pcall(pg)
        end
        task.wait(pX("RebirthDelay", 1))
    end
end
function fns.onUnload()
    Library:Unload()
end
function fns.worker8()
    while not Library.Unloaded do
        if qN("AutoHatch") then
            pcall(pV)
        end
        task.wait(pX("HatchDelay", 1))
    end
end
function fns.onCopyJoinScript_JobID()
    local iS = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, pY)
    pn(iS, "Copied join script to clipboard")
end
function fns.fn702()
    if not Toggles.WalkSpeedEnabled.Value then
        local xN = qI()
        if xN then
            xN.WalkSpeed = 16
        end
    end
end
function fns.onCopyBitcoinAddress()
    pn(pN, "Copied Bitcoin address")
end
function fns.onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local xP_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if xP_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
function fns.worker4()
    while not Library.Unloaded do
        if qN("AutoDrain") then
            pcall(o6)
            task.wait(pX("DrainLoopDelay", 0.15))
        else
            task.wait(0.25)
        end
    end
end
function fns.fn906()
    local yz = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local yA = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if yA then
                local yA_1 = qh(k, v)
                if yA_1 then
                    yz[#yz + 1] = yA_1
                end
            end
        end
    end
    table.sort(yz, function(kZ, k_)
        if kZ.type ~= k_.type then
            return kZ.type < k_.type
        end
        return kZ.idx < k_.idx
    end)
    return { objects = yz }
end
local function onInputBegan()
    qu = tick()
end
local function fn989(kD, kE)
    local ym_1 = (kD == "Toggle" and Toggles or Options)[kE]
    local yl_2 = type(ym_1) == "table" and ym_1.Type == kD
    return yl_2 and ym_1 or nil
end
local function worker9()
    while not Library.Unloaded do
        if qN("AutoSell") then
            pcall(zt_2)
        end
        task.wait(pX("SellLoopDelay", 2))
    end
end
local function onImportConfigFromClipboardTex()
    local yZ_1
    local yX = Options.SaveManager_ImportSource.Value or ""
    local yX_1
    local yY = tostring(yX):match("^%s*(.-)%s*$")
    if yY == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    yX_1, yZ_1 = pcall(HttpService.JSONDecode, HttpService, yY)
    local yY_1 = not yX_1 or type(yZ_1) ~= "table" or type(yZ_1.objects) ~= "table"
    if yY_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local yX_2 = 0
    for i, v in ipairs(yZ_1.objects) do
        if o_(v) then
            yX_2 += 1
        end
    end
    if yX_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local yZ_2 = yX_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(yX_2, yZ_2), 6)
end
local function onExportConfigToClipboard()
    local yU_1
    local yT_1
    yT_1, yU_1 = pcall(HttpService.JSONEncode, HttpService, p2())
    if not yT_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local yT_2 = setclipboard or toclipboard
    local yT_3 = type(yT_2) ~= "function" or not pcall(yT_2, yU_1)
    if yT_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function onRenderStepped(j1)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local xZ_1 = qI()
        if xZ_1 then
            xZ_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local xZ_3 = ql()
        local x_ = qI()
        local x0 = Workspace.CurrentCamera
        local x5 = if x0 then 1 else 0
        local x3 = 1179 * x5 + 2176 * (1 - x5)
        local x4 = 3737 * x5 + 2611 * (1 - x5)
        if not ((x3 * 2614 + x4 * 1499 + x3 * x4) % 16777213 == 13089592) then
            x0 = pU
        end
        pU = x0
        if xZ_3 and x_ and pU then
            x_.PlatformStand = true
            local x__1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                x__1 = x__1 + pU.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                x__1 = x__1 - pU.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                x__1 = x__1 - pU.CFrame.RightVector
            end
            local x8 = if UserInputService:IsKeyDown(Enum.KeyCode.D) then 1 else 0
            if x8 == 1 then
                x__1 = x__1 + pU.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                x__1 = x__1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                x__1 = x__1 - Vector3.new(0, 1, 0)
            end
            xZ_3.Velocity = Vector3.zero
            if x__1.Magnitude > 0 then
                xZ_3.CFrame = xZ_3.CFrame + x__1.Unit * Options.FlySpeed.Value * j1
            end
        end
    end
end
local function worker7()
    while not Library.Unloaded do
        if qN("AutoBuyPump") then
            pcall(qw)
        end
        if qN("AutoBuyUpgrades") then
            pcall(qy)
        end
        if qN("AutoBuyAura") then
            pcall(qT)
        end
        task.wait(pX("ShopDelay", 1))
    end
end
local function onInputChanged(kw)
    local UserInputType = kw.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        qu = tick()
    end
end
o_ = nil
AbbNumber = nil
o3 = nil
o4 = nil
o6 = nil
o7 = nil
onJoinDiscordForKeylessScripts = nil
o9 = nil
zt_2 = nil
connection2 = nil
pe = nil
pg = nil
pj = nil
pk = nil
pm = nil
pn = nil
po = nil
pp = nil
pq = nil
ps = nil
Options = nil
pu = nil
pv = nil
pw = nil
px = nil
py = nil
pz = nil
Toggles = nil
connection = nil
pC = nil
SaveManager = nil
pF = nil
pG = nil
pH = nil
pI = nil
pJ = nil
pK = nil
pL = nil
Library = nil
local o0, o2, o5, pb, pd, pf, ph, AuraHelper, UpgradeHelper, PumpHelper, pD
pN = nil
pO = nil
pP = nil
pQ = nil
pR = nil
pS = nil
pT = nil
pU = nil
pV = nil
pW = nil
pX = nil
pY = nil
pZ = nil
p_ = nil
p0 = nil
p1 = nil
p2 = nil
Label = nil
p4 = nil
p5 = nil
p7 = nil
p8 = nil
LocalPlayer = nil
qd = nil
Workspace = nil
qg = nil
qh = nil
qi = nil
qk = nil
ql = nil
qn = nil
qo = nil
qp = nil
qs = nil
qu = nil
qv = nil
qw = nil
HttpService = nil
qy = nil
local p6, p9, qb, qc, qf, CoreGui, qm, GuiService, qr, qt, qz
qA = nil
qB = nil
qC = nil
VirtualUser = nil
qE = nil
qG = nil
UserInputService = nil
qI = nil
qK = nil
qL = nil
qN = nil
qO = nil
qP = nil
qQ = nil
qR = nil
EquipBest = nil
qT = nil
qU = nil
qV = nil
qX = nil
qY = nil
local qF, qJ, qM, qW
qF = nil
qJ = nil
qM = nil
qW = nil
UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, LocalPlayer, p4, pZ, pH, pD, py, pq, pk, ph, pd, pb, o5, o0, EquipBest, qO, qJ, qF, qz, qr, qk, qf, qb, p9, p6, pR, pO, zt_20, PumpHelper, UpgradeHelper, AuraHelper, pe, AbbNumber, qU, qP, qK = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local zt_65 = game:GetService("Players")
local zt_12 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
LocalPlayer = zt_65.LocalPlayer
local zt_60 = "+1 Drain Water Per Click"
p4 = "https://discord.gg/K7Qxnxkk46"
pZ = "https://discord.gg/K7Qxnxkk46"
local zt_35 = zt_12:WaitForChild("Remote")
local zt_46 = zt_35:WaitForChild("Event")
local zt_69 = zt_35:WaitForChild("Function")
if ((pH or pH) and (pO or pO) or (not pH or not pH) and (not pO or pH) or not pH and not pH and (not pO or not pO) and (pH and not pH and (not pO or pO))) and not ((pH or pH) and (pO or pO) or (not pH or not pH) and (not pO or pH) or not pH and not pH and (not pO or not pO) and (pH and not pH and (not pO or pO))) then
    zt_46 = pH.Level["[C-S]Click"]
else
    pH = zt_46.Level["[C-S]Click"]
end
if ((not CoreGui or not AbbNumber) and (not CoreGui and not CoreGui) or (not CoreGui or not AbbNumber) and (not AbbNumber or not CoreGui)) and ((CoreGui and CoreGui or (not AbbNumber or not CoreGui)) and (not CoreGui and not AbbNumber and (AbbNumber or not AbbNumber))) or not (((not CoreGui or not AbbNumber) and (not CoreGui and not CoreGui) or (not CoreGui or not AbbNumber) and (not AbbNumber or not CoreGui)) and ((CoreGui and CoreGui or (not AbbNumber or not CoreGui)) and (not CoreGui and not AbbNumber and (AbbNumber or not AbbNumber)))) then
    pD = zt_46.Stage["[C-S]StandingWater"]
    py = zt_46.Level["[C-S]GoShow"]
    pq = zt_46.Level["[C-S]ReturnHome"]
else
    zt_46 = py.Stage["[C-S]StandingWater"]
    pq = py.Level["[C-S]GoShow"]
    pD = py.Level["[C-S]ReturnHome"]
end
pk = zt_46.Rebirth["[C - S]TryRebirth"]
ph = zt_46.Pump["[C-S]BuyCashPump"]
pd = zt_46.Pump["[C-S]EquipPump"]
pb = zt_46.Upgrade["[C-S]BuyCashUpgrade"]
o5 = zt_46.Aura["[C-S]BuyCashAura"]
o0 = zt_46.Aura["[C-S]EquipAura"]
EquipBest = zt_46.Pet.EquipBest
qO = zt_69.Stage["[C-S]GetStageState"]
qJ = zt_69.Pump["[C-S]GetPumpData"]
qF = zt_69.Upgrade["[C-S]GetUpgradeData"]
qz = zt_69.Aura["[C-S]GetAuraData"]
qr = zt_69.Fish["[C-S]GetFishData"]
qk = zt_69.Fish["[C-S]GetCarryFishData"]
qf = zt_69.Fish["[C-S]SellFish"]
qb = zt_69.Fish["[C-S]SellAllFish"]
p9 = zt_69.Egg["[C-S]CanOpenEgg"]
p6 = zt_69.Egg["[C-S]OpenEgg"]
pR = zt_69.FishShow["[C-S]BestFishUI"]
pO = zt_69.FishShow["[C-S]ClaimOfflineCash"]
if not pq and qU and (GuiService and py) and (not zt_12 or not Workspace or (pq or zt_12)) and (GuiService and not py or zt_12 and py or not Workspace and Workspace and (pq or not GuiService)) or not (not pq and qU and (GuiService and py) and (not zt_12 or not Workspace or (pq or zt_12)) and (GuiService and not py or zt_12 and py or not Workspace and Workspace and (pq or not GuiService))) then
    zt_20 = zt_12:WaitForChild("Config")
else
    zt_12 = zt_20:WaitForChild("Config")
end
require(zt_20:WaitForChild("StageHelper"))
PumpHelper = require(zt_20:WaitForChild("PumpHelper"))
UpgradeHelper = require(zt_20:WaitForChild("UpgradeHelper"))
AuraHelper = require(zt_20:WaitForChild("AuraHelper"))
pe = require(zt_20:WaitForChild("EggHelper"))
local TrainingAreaHelper = require(zt_20:WaitForChild("TrainingAreaHelper"))
require(zt_20:WaitForChild("AquariumHelper"))
AbbNumber = require(zt_12:WaitForChild("Utils"):WaitForChild("AbbNumber"))
qU = 15
qP = "关卡"
qK = "水面"
local zt_48 = {}
local zt_6 = 1
local zt_28 = qU
while zt_6 <= zt_28 do
    local zt_66 = zt_6
    zt_48[zt_66] = "Stage " .. zt_66
    zt_6 += 1
end
qt, qn, zt_20, qc, zt_53, zt_43, zt_31, p7 = nil, nil, nil, nil, nil, nil, nil, nil
zt_65 = 6
repeat
    zt_9 = (zt_65 * 3 + 1) % 4 + 1
    if zt_9 <= 2 then
        if zt_9 <= 1 then
            zt_69 = (vector.create((zt_65 * 3 + 5) % 11 + 1, (zt_65 * 10 + 9) % 13 + 1, (zt_65 * 2 + 7) % 17 + 1))
            zt_57 = (vector.create((zt_65 * 5 + 5) % 11 + 1, (zt_65 * 2 + 4) % 13 + 1, (zt_65 * 10 + 13) % 17 + 1))
            local BQ = vector.cross(zt_69, zt_57)
            local BR = vector.dot(zt_69, zt_57)
            if vector.dot(BQ, BQ) + BR * BR == vector.dot(zt_69, zt_69) * vector.dot(zt_57, zt_57) + 5 then
                zt_43 = fns.fn429
            else
                p7 = fns.fn429
            end
            zt_65 = (zt_65 + 7) % 16
        else
            zt_69 = (vector.create((zt_65 * 6 + 8) % 11 + 1, (zt_65 * 11 + 6) % 13 + 1, (zt_65 * 14 + 8) % 17 + 1))
            zt_57 = (vector.create((zt_65 * 6 + 6) % 11 + 1, (zt_65 * 5 + 9) % 13 + 1, (zt_65 * 10 + 5) % 17 + 1))
            zt_46 = (vector.create((zt_65 * 1 + 2) % 11 + 1, (zt_65 * 4 + 7) % 13 + 1, (zt_65 * 10 + 11) % 17 + 1))
            if vector.dot(vector.cross(zt_69, zt_57), zt_46) == vector.dot(vector.cross(zt_57, zt_46), zt_69) + 4 then
                p7 = {}
            else
                zt_43 = {}
            end
            zt_65 = (zt_65 + 15) % 16
        end
    elseif zt_9 <= 3 then
        if (zt_65 * 2 + 8) * 10 % 3 == ((zt_65 * 2 + 8) * 10 + 1) % 3 then
            zt_43 = { "1", "10", "3" }
        else
            zt_31 = { "1", "3", "10" }
        end
        zt_65 = (zt_65 + 15) % 16
    else
        if zt_65 * 49100077 + 1 + 5 >= zt_65 * 49100077 + 1 + 5 + 5 then
            qn = { "Backpack", "FishDisplay", "Speed" }
            qt = { Exotic = 7, Secret = 8, Rare = 2, Exclusive = 6, Mythic = 5, Legendary = 4, Epic = 3, Common = 1 }
            qc = { "Rare", "Epic", "Mythic", "Secret", "Common", "Exotic", "Legendary", "Exclusive" }
            zt_53 = { "Normal", "Diamond", "Hole", "Gold" }
            zt_20 = { "Highest Earning", "Highest Rarity", "Random" }
        else
            qt = { "Backpack", "Speed", "FishDisplay" }
            qn = { Common = 1, Rare = 2, Epic = 3, Legendary = 4, Mythic = 5, Exclusive = 6, Exotic = 7, Secret = 8 }
            zt_20 = { "Common", "Rare", "Epic", "Legendary", "Mythic", "Exclusive", "Exotic", "Secret" }
            qc = { "Normal", "Gold", "Diamond", "Hole" }
            zt_53 = { "Highest Earning", "Random", "Highest Rarity" }
        end
        zt_65 = (zt_65 + 7) % 16
    end
until (zt_65 * 9 + 2) % 16 == 4
zt_69, zt_57 = nil, nil
zt_9 = 4
repeat
    zt_65 = (zt_9 * 1 + 0) % 2 + 1
    if zt_65 <= 1 then
        local AO = bit32.rrotate(bit32.bxor(bit32.lrotate(zt_9, 4), string.byte(tostring(zt_69))), 31)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(AO, 1895465581), 3536293984), (bit32.bxor(bit32.band(AO, 2399501714), 3440878505))), 3536293984), 3440878505) ~= AO then
            pe = zt_69.GetAllEggConfig()
        else
            zt_69 = pe.GetAllEggConfig()
        end
        zt_9 = (zt_9 + 3) % 8
    else
        local A_ = bit32.rrotate(bit32.bxor(bit32.lrotate(zt_9, 16), string.byte(tostring(zt_69))), 11)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(A_, 3739663023), 1109337807), (bit32.bxor(bit32.band(A_, 555304272), 1389294332))), 1109337807), 1389294332) ~= A_ then
            zt_69 = {}
        else
            zt_57 = {}
        end
        zt_9 = (zt_9 + 1) % 8
    end
until (zt_9 * 7 + 3) % 8 == 3
for k, v in pairs(zt_69) do
    zt_65 = tonumber(k) or k
    zt_9 = zt_65
    zt_65 = pe.GetCostType(zt_9) or pe.getCostType(zt_9)
    zt_69 = zt_65
    if zt_69 == "Cash" then
        zt_65 = #zt_57 + 1
        zt_69 = (pe.GetEggName(zt_9))
        if not zt_69 then
            zt_46 = v and v.name
            zt_69 = zt_46
        end
        if not zt_69 then
            zt_69 = "Egg " .. tostring(zt_9)
        end
        zt_57[zt_65] = { Id = zt_9, Name = zt_69 }
    end
end
zt_46 = 2
repeat
    zt_65 = (vector.create((zt_46 * 4 + 4) % 11 + 1, (zt_46 * 7 + 5) % 13 + 1, (zt_46 * 6 + 15) % 17 + 1))
    local A8 = vector.floor(zt_65) + vector.ceil(zt_65 * -1)
    if vector.dot(A8, A8) == 1 then
        table.sort(zt_57, fns.fn549)
    else
        table.sort(zt_57, fns.fn549)
    end
    zt_46 = (zt_46 + 5) % 8
until (zt_46 * 1 + 7) % 8 == 6
for i, v in ipairs(zt_57) do
    zt_43[#zt_43 + 1] = v.Name
end
qG = {}
zt_65 = TrainingAreaHelper.GetAllTrainingAreaConfig()
for k, v in pairs(zt_65) do
    zt_65 = tonumber(k) or k
    zt_9 = zt_65
    zt_65 = TrainingAreaHelper.GetRobuxProduct(zt_9)
    zt_69 = zt_65 == nil and type(v) == "table" and v.productKey == nil
    if zt_69 then
        zt_65 = #qG + 1
        zt_69 = TrainingAreaHelper.GetTrainingAreaName(zt_9) or "Area " .. tostring(zt_9)
        zt_57 = tonumber(TrainingAreaHelper.GetMultiplier(zt_9)) or 0
        zt_46 = tonumber(TrainingAreaHelper.GetRebirthRequired(zt_9)) or 0
        qG[zt_65] = { Id = zt_9, Name = zt_69, Multiplier = zt_57, RequiredRebirths = zt_46 }
    end
end
table.sort(qG, fns.fn175)
Library = getgenv().Library
zt_9 = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
pn = function(aU, aV)
    if setclipboard then
        setclipboard(aU)
    elseif toclipboard then
        toclipboard(aU)
    end
    Library:Notify(aV)
end
onJoinDiscordForKeylessScripts = function()
    pn(p4, "Copied Discord invite to clipboard")
end
qQ = function(a0, a1)
    return string.format('<font color="%s">%s</font>', a1, a0)
end
qB = function(a3, a4, a5)
    return string.format("<b>%s</b> %s %s", a3, '<font color="#5a6070">-</font>', qQ(a4, a5))
end
p0 = "#e8a34d"
pF = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
zt_57 = "#6ec1ff"
zt_35 = "#7fd47f"
pN = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
pC = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
pJ = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
pQ = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
pu = ""
po = ""
local zt_15 = "#8b93a3"
qN = function(bq)
    local se = Toggles[bq]
    return se ~= nil and se.Value == true
end
qi = function(bv)
    local sh = Options[bv]
    return sh and sh.Value or nil
end
pX = function(bA, bB)
    local sk = Options[bA]
    local sl = sk and tonumber(sk.Value)
    if sl then
        return sl
    end
    return bB
end
pp = function(bH, bI)
    local sq = Options[bH]
    local sr = sq and sq.Value
    if type(sr) ~= "table" then
        return false
    elseif sr[bI] == true then
        return true
    else
        for k in pairs(sr) do
            if k == bI and sr[k] then
                return true
            end
        end
        return false
    end
end
qI = function()
    local Character = LocalPlayer.Character
    local sy = Character and Character:FindFirstChildOfClass("Humanoid")
    return sy
end
ql = function()
    local Character = LocalPlayer.Character
    local sB = Character and Character:FindFirstChild("HumanoidRootPart")
    return sB
end
p5 = function(bY)
    local Character = LocalPlayer.Character
    if not Character then
        return
    end
    if Character.PrimaryPart then
        Character:PivotTo(bY)
    else
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = bY
        end
    end
end
pI = function(b2, b3)
    local sO
    if typeof(b2) ~= "Vector3" then
        return
    end
    if not Workspace.StreamingEnabled then
        return
    end
    sO = false
    task.spawn(function()
        pcall(function()
            local sM = b3 or 5
            LocalPlayer:RequestStreamAroundAsync(b2, sM)
        end)
        sO = true
    end)
    local sP = os.clock()
    local sQ = b3
    local sX = if sQ then 1 else 0
    local sV = 487 * sX + 3412 * (1 - sX)
    local sW = 3173 * sX + 2403 * (1 - sX)
    if not ((sV * 205 + sW * 1383 + sV * sW) % 16777213 == 6033345) then
        sQ = 5
    end
    local sP_1 = sP + sQ + 0.25
    while true do
        local sQ_1 = not sO and os.clock() < sP_1 and not Library.Unloaded
        if sQ_1 then
            task.wait()
            continue
        end
        break
    end
end
qm = function(ci)
    local sZ_1
    local sY_1
    if type(ci) == "number" then
        return ci
    elseif type(ci) == "string" then
        sY_1, sZ_1 = pcall(AbbNumber.ConvertToNumber, ci)
        local s_ = sY_1 and type(sZ_1) == "number"
        if s_ then
            return sZ_1
        end
        local sY_2 = tonumber((ci:gsub("[%$,]", ""))) or 0
        return sY_2
    else
        return 0
    end
end
pS = function(co, cp, cq)
    local s1 = LocalPlayer:FindFirstChild(co)
    local s2 = s1 and s1:FindFirstChild(cp)
    local s1_1 = s2
    if s2 then
        s2 = s1_1:IsA("ValueBase")
    end
    if s2 then
        return s1_1.Value
    end
    return cq
end
pf = function()
    local s4 = tonumber(pS("Cash", "cash", 0)) or 0
    return s4
end
qV = function()
    local tb = tonumber(pS("Level", "level", 0)) or 0
    return tb
end
qL = function()
    local td = tonumber(pS("Rebirth", "rebirth", 0)) or 0
    return td
end
qA = function()
    local tf = (tonumber(pS("Rebirth", "rebirthNeed", math.huge)))
    local tj = if tf then 1 else 0
    local th = 3865 * tj + 3200 * (1 - tj)
    local ti = 3900 * tj + 2639 * (1 - tj)
    if not ((th * 2539 + ti * 3244 + th * ti) % 16777213 == 3983909) then
        tf = math.huge
    end
    return tf
end
qg = function()
    local tk = qi("DrainStage")
    if type(tk) == "string" then
        local tl = tonumber(tk:match("%d+"))
        if tl then
            return math.clamp(tl, 1, qU)
        end
        return 1
    end
    return 1
end
pT = function()
    for i, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Folder") then
            for i, child in ipairs(child:GetChildren()) do
                if child:FindFirstChild("WorldFish") then
                    return child
                end
            end
        end
    end
end
ps = function(cT)
    local tA = pT()
    if not tA then
        return nil
    end
    return tA:FindFirstChild(qP .. tostring(cT))
end
o7 = function(cY)
    local BasePart
    local tF = ps(cY)
    local tF_6
    if tF then
        local tG_1 = tF:FindFirstChild(qK)
        local tH = tG_1 and tG_1:IsA("BasePart")
        if tH then
            return tG_1.CFrame + Vector3.new(0, 2, 0), tG_1.Position
        end
        local _1 = tF:FindFirstChild("1")
        local tF_1 = _1 and _1:IsA("BasePart")
        if tF_1 then
            local tF_2 = math.clamp(_1.Size.Y * 0.35, 4, 24)
            return CFrame.new(_1.Position + Vector3.new(0, tF_2, 0)), _1.Position
        end
        local FishSpawnPoints = Workspace:FindFirstChild("FishSpawnPoints")
        local tG_3 = FishSpawnPoints and FishSpawnPoints:FindFirstChild("Stage" .. tostring(cY))
        if tF_6 then
            local BasePart2 = tG_3:FindFirstChildWhichIsA("BasePart")
            if BasePart then
                return BasePart2.CFrame + Vector3.new(0, 3, 0), BasePart2.Position
            end
            return nil, nil
        end
        return nil, nil
    end
    local FishSpawnPoints = Workspace:FindFirstChild("FishSpawnPoints")
    local tG_5 = FishSpawnPoints and FishSpawnPoints:FindFirstChild("Stage" .. tostring(cY))
    tF_6 = tG_5
    if tF_6 then
        BasePart = tF_6:FindFirstChildWhichIsA("BasePart")
        if BasePart then
            return BasePart.CFrame + Vector3.new(0, 3, 0), BasePart.Position
        end
        return nil, nil
    end
    return nil, nil
end
pP = function(dc)
    local tN_1
    local tM_1
    tN_1, tM_1 = o7(dc)
    local tO = not tN_1
    if tO ~= false then
        tO = tM_1
    end
    if tO then
        pI(tM_1, 4)
        tN_1 = o7(dc)
    elseif tM_1 then
        local tO_1 = ql()
        if tO_1 and (tO_1.Position - tM_1).Magnitude > 80 then
            pI(tM_1, 4)
            local tM_2 = select(1, o7(dc)) or tN_1
            tN_1 = tM_2
        end
    end
    if not tN_1 then
        return false
    end
    local tM_3 = ql()
    if not tM_3 or (tM_3.Position - tN_1.Position).Magnitude > 8 then
        p5(tN_1)
        task.wait(0.15)
    end
    return true
end
qY = function(dp)
    local tS_1
    local tR_1
    tR_1, tS_1 = pcall(function()
        return qO:InvokeServer()
    end)
    local tT = not tR_1 or type(tS_1) ~= "table"
    if tT then
        return nil
    end
    local tR_2 = tS_1[dp] or tS_1[tostring(dp)]
    return tR_2
end
qd = function(dy)
    if LocalPlayer:GetAttribute("StageCompleted_" .. tostring(dy)) == true then
        return true
    end
    local tV = qY(dy)
    if type(tV) == "table" then
        if tV.completed == true then
            return true
        end
        local tW = tonumber(tV.remaining)
        if tW and tW <= 0 then
            return true
        end
        return false
    end
    return false
end
pK = function()
    pcall(function()
        pH:FireServer()
    end)
end
pv = function(dI)
    pcall(function()
        pD:FireServer(dI)
    end)
end
o9 = function()
    local tY = pT()
    if tY then
        local WorldFish = tY:FindFirstChild("WorldFish")
        if WorldFish then
            return WorldFish
        end
    end
    for i, descendant in ipairs(Workspace:GetDescendants()) do
        local tY_1 = descendant.Name == "WorldFish" and descendant:IsA("Folder")
        if tY_1 then
            return descendant
        end
    end
end
qp = function(dV)
    if not dV then
        return
    end
    if fireproximityprompt then
        pcall(fireproximityprompt, dV)
        return
    end
    pcall(function()
        dV:InputHoldBegin()
    end)
    local ua = dV.HoldDuration or 0
    task.wait(ua)
    pcall(function()
        dV:InputHoldEnd()
    end)
end
p8 = function()
    local ug_1
    local uf_1
    uf_1, ug_1 = pcall(function()
        return qk:InvokeServer()
    end)
    local uh = uf_1 and type(ug_1) == "table"
    if uh then
        return ug_1
    end
    return { Count = 0, Capacity = 0, Items = {} }
end
pG = function()
    local um = p8()
    local un = tonumber(um.Count) or 0
    if un <= 0 then
        return
    end
    pcall(function()
        py:FireServer()
    end)
    task.wait(0.6)
    pcall(function()
        pq:FireServer()
    end)
    task.wait(0.25)
end
zt_2 = nil
o4 = function(ec)
    local up = tonumber(ec:GetAttribute("Price")) or 0
    local up_1 = p7(ec:GetAttribute("Rarity"))
    return up, up_1
end
qE = function(eh)
    local uy_2
    local ux_2
    if not qd(eh) then
        return
    end
    local uu = o9()
    if not uu then
        return
    end
    local uv = "^Fish_" .. tostring(eh) .. "_"
    local uw = {}
    for i, child in ipairs(uu:GetChildren()) do
        if child.Name:match(uv) then
            local ProximityPrompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
            local ux_1 = child:FindFirstChild("FishRoot", true) or child:FindFirstChildWhichIsA("BasePart", true)
            local uy_1 = ProximityPrompt
            if uy_1 then
                uy_1 = ProximityPrompt.Enabled
            end
            if uy_1 then
                uy_1 = ux_1
            end
            if uy_1 then
                uy_1 = child:GetAttribute("Claimed") ~= true
            end
            if uy_1 then
                ux_2, uy_2 = o4(child)
                uw[#uw + 1] = {
                    Fish = child,
                    Prompt = ProximityPrompt,
                    Part = ux_1,
                    Price = ux_2,
                    Rarity = uy_2,
                    Random = math.random()
                }
            end
        end
    end
    local uu_2 = qi("DrainPriority") or "Highest Earning"
    if uu_2 == "Highest Rarity" then
        table.sort(uw, function(eB, eC)
            if eB.Rarity == eC.Rarity then
                return eB.Price > eC.Price
            end
            return eB.Rarity > eC.Rarity
        end)
    elseif uu_2 == "Random" then
        table.sort(uw, function(ez, eA)
            return ez.Random < eA.Random
        end)
    else
        table.sort(uw, function(ex, ey)
            if ex.Price == ey.Price then
                return ex.Rarity > ey.Rarity
            end
            return ex.Price > ey.Price
        end)
    end
    local uu_3 = math.clamp(math.floor(pX("FishPickAmount", 3)), 1, 50)
    local uv_2 = 0
    for i, v in ipairs(uw) do
        local uw_1 = Library.Unloaded or not qN("AutoDrain")
        if uw_1 then
            return
        end
        if uv_2 >= uu_3 then
            break
        end
        local uw_2 = p8()
        local ux_3 = tonumber(uw_2.Count) or 0
        local ux_4 = tonumber(uw_2.Capacity) or 0
        local ux_5 = uu_3 - uv_2
        if ux_4 > 0 then
            ux_5 = math.min(ux_5, ux_4 - ux_3)
        end
        if ux_5 <= 0 then
            pG()
            local uw_4 = qN("AutoSell") and zt_2
            if uw_4 then
                pcall(zt_2)
            end
            break
        end
        p5(v.Part.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.08)
        qp(v.Prompt)
        uv_2 += 1
        task.wait(pX("FishPickDelay", 0.12))
    end
end
pm = function(eV)
    local uR
    local uQ = 1
    while true do
        if not (uQ <= eV) then
            return eV
        end
        uR = uQ
        if not qd(uR) then
            break
        end
        uQ += 1
    end
    return uR
end
o6 = function()
    local uT = qg()
    local uU = pm(uT)
    if not pP(uU) then
        return
    end
    if not qd(uU) then
        local uV = math.clamp(math.floor(pX("DrainClicks", 12)), 1, 60)
        local uZ = 1
        while true do
            if not (uZ <= uV) then
                return
            end
            local uV_1 = Library.Unloaded or not qN("AutoDrain")
            if uV_1 then
                return
            end
            if not pP(uU) then
                break
            end
            pv(uU)
            pK()
            task.wait(pX("DrainClickDelay", 0.05))
            uZ += 1
        end
        return
    end
    if uU ~= uT then
        return
    end
    qE(uT)
    local uT_1 = p8()
    local uU_1 = tonumber(uT_1.Count) or 0
    if uU_1 > 0 then
        pG()
    end
end
pz = function()
    local u4 = qL()
    local u5
    for i, v in ipairs(qG) do
        if v.RequiredRebirths <= u4 then
            if not u5 or v.Multiplier > u5.Multiplier then
                u5 = v
            end
        end
    end
    return u5
end
qX = function(fo)
    local ExerciseArea = Workspace:FindFirstChild("ExerciseArea")
    if not ExerciseArea then
        return nil
    end
    local vf = tostring(fo)
    local vg = -1
    local vh
    for i, child in ipairs(ExerciseArea:GetChildren()) do
        local ve_1 = child.Name == vf and child:IsA("BasePart")
        if ve_1 then
            local ve_2 = child.Size.X * child.Size.Y * child.Size.Z
            if ve_2 > vg then
                vh = child
                vg = ve_2
            end
        end
    end
    return vh
end
p_ = function()
    local vp = pz()
    if not vp then
        return
    end
    local vq = qX(vp.Id)
    if not vq then
        return
    end
    local vp_1 = ql()
    if not vp_1 or (vp_1.Position - vq.Position).Magnitude > 6 then
        p5(vq.CFrame)
        task.wait(0.1)
    end
    pK()
end
pg = function()
    if qV() >= qA() then
        pcall(function()
            pk:FireServer()
        end)
    end
end
qR = function()
    local vu = LocalPlayer:GetAttribute("FishShowPlotId") or 1
    return Workspace:FindFirstChild(tostring(vu))
end
qv = function(fS)
    local vx = qR()
    if not vx then
        return nil
    end
    for i, descendant in ipairs(vx:GetDescendants()) do
        local vx_1 = descendant:IsA("BasePart") and fS(descendant)
        if vx_1 then
            return descendant
        end
    end
end
pW = function()
    return qv(function(f_)
        local vF = f_.Name == "Touch" and f_.Parent and f_.Parent.Name:find("收集") ~= nil
        return vF
    end)
end
pj = function(f6)
    local vP = ql()
    local vQ = not f6
    local vR = not vP
    local vV = if vR then 1 else 0
    local vT = 4034 * vV + 3684 * (1 - vV)
    local vU = 1294 * vV + 1307 * (1 - vV)
    if not ((vT * 3678 + vU * 1364 + vT * vU) % 16777213 == 5044851) then
        vR = vQ
    end
    if vR then
        return
    end
    if firetouchinterest then
        pcall(firetouchinterest, vP, f6, 0)
        task.wait(0.05)
        pcall(firetouchinterest, vP, f6, 1)
    end
end
o3 = function()
    local vW = pW()
    if vW then
        pj(vW)
    end
    pcall(function()
        pO:InvokeServer()
    end)
end
qw = function()
    local vY
    local v__1
    local vZ_1
    vZ_1, v__1 = pcall(function()
        return qJ:InvokeServer()
    end)
    local v0 = not vZ_1 or type(v__1) ~= "table"
    if v0 then
        return
    end
    local v0_1 = v__1.Owned or {}
    local v__2 = pf()
    local v0_2 = -1
    vY = nil
    for k in pairs(PumpHelper.GetAllPumpConfig()) do
        local v1 = tonumber(k) or k
        local v1_1 = not v0_1[v1]
        if v1_1 ~= false then
            v1_1 = not v0_1[tostring(v1)]
        end
        if v1_1 then
            local v1_2 = qm(PumpHelper.GetCashPrice(v1))
            local v3 = qm(PumpHelper.GetMultiplier(v1))
            if v1_2 > 0 and v1_2 <= v__2 and v3 > v0_2 then
                vY = v1
                v0_2 = v3
            end
        end
    end
    if not vY then
        return
    end
    pcall(function()
        ph:FireServer(vY)
    end)
    task.wait(0.2)
    pcall(function()
        pd:FireServer(vY)
    end)
end
qy = function()
    local we_1
    local wd_1
    wd_1, we_1 = pcall(function()
        return qF:InvokeServer()
    end)
    local wf = not wd_1 or type(we_1) ~= "table"
    if wf then
        return
    end
    local wd_2 = pf()
    for i, v in ipairs(qt) do
        local wn = v
        local wf_1 = we_1[wn]
        local wg = type(wf_1) == "table" and wf_1.isMax ~= true
        if wg then
            local wg_1 = tonumber(wf_1.level) or 0
            local wg_2 = qm(UpgradeHelper.GetCashPrice(wn, wg_1))
            if wg_2 > 0 and wg_2 <= wd_2 then
                pcall(function()
                    pb:FireServer(wn)
                end)
                wd_2 -= wg_2
                task.wait(0.1)
            end
        end
    end
end
qT = function()
    local wo
    local wq_1
    local wp_1
    wp_1, wq_1 = pcall(function()
        return qz:InvokeServer()
    end)
    local wr = not wp_1 or type(wq_1) ~= "table"
    if wr then
        return
    end
    local wr_1 = wq_1.Owned or {}
    local wq_2 = pf()
    local wr_2 = -1
    wo = nil
    for k in pairs(AuraHelper.GetAllAuraConfig()) do
        local ws = tonumber(k) or k
        local ws_1 = not wr_1[ws]
        if ws_1 ~= false then
            ws_1 = not wr_1[tostring(ws)]
        end
        if ws_1 then
            local ws_2 = qm(AuraHelper.GetCashPrice(ws))
            local wu = qm(AuraHelper.GetMultiplier(ws))
            if ws_2 > 0 and ws_2 <= wq_2 and wu > wr_2 then
                wo = ws
                wr_2 = wu
            end
        end
    end
    if not wo then
        return
    end
    pcall(function()
        o5:FireServer(wo)
    end)
    task.wait(0.2)
    pcall(function()
        o0:FireServer(wo)
    end)
end
qW = function()
    local wE = qi("HatchEgg")
    if type(wE) ~= "string" then
        return nil
    end
    local wF = pe.GetAllEggConfig()
    for k, v in pairs(wF) do
        local wF_1 = tonumber(k) or k
        local wF_2 = (pe.GetEggName(wF_1))
        if not wF_2 then
            wF_2 = v and v.name
        end
        if wF_2 == wE then
            return wF_1
        end
    end
    return nil
end
pV = function()
    local wS, wT
    local wV_1
    wS = qW()
    if not wS then
        return
    end
    local wU = tonumber(qi("HatchAmount")) or 1
    local wU_1
    wT = wU
    wU_1, wV_1 = pcall(function()
        return p9:InvokeServer(wS, wT)
    end)
    if not wU_1 or wV_1 ~= true then
        return
    end
    pcall(function()
        p6:InvokeServer(wS, wT)
    end)
end
qM = function(hP)
    if type(hP) ~= "table" then
        return false
    end
    local wZ = hP.protected == true and qN("SellKeepProtected")
    if wZ then
        return false
    end
    local wZ_1 = hP.special == true and qN("SellKeepSpecial")
    if wZ_1 then
        return false
    end
    local wZ_2 = hP.mutation or "Normal"
    local w_ = tostring(wZ_2)
    if pp("SellKeepMutations", w_) then
        return false
    end
    local wZ_3 = qi("SellMode") or "Sell All"
    if wZ_3 == "Below Rarity" then
        local wZ_4 = qi("SellBelowRarity") or "Mythic"
        return p7(hP.rarity) < p7(wZ_4)
    end
    return true
end
zt_2 = function()
    local w4 = qi("SellMode") or "Sell All"
    local w4_4
    local w5_2
    local w4_1 = qN("SellKeepProtected")
    local w6 = qN("SellKeepSpecial")
    local w7 = false
    for i, v in ipairs(qc) do
        if pp("SellKeepMutations", v) then
            w7 = true
            break
        end
    end
    if w4 == "Sell All" and not w4_1 and not w6 and not w7 then
        pcall(function()
            qb:InvokeServer()
        end)
        return
    end
    w4_4, w5_2 = pcall(function()
        return qr:InvokeServer()
    end)
    local w6_2 = not w4_4 or type(w5_2) ~= "table" or type(w5_2.Items) ~= "table"
    if w6_2 then
        return
    end
    for k, v in pairs(w5_2.Items) do
        local xp = v
        local w4_5 = Library.Unloaded or not qN("AutoSell")
        if w4_5 then
            return
        end
        local w4_6 = qM(xp) and xp.uid
        if w4_6 then
            pcall(function()
                qf:InvokeServer(xp.uid)
            end)
            task.wait(pX("SellDelay", 0.05))
        end
    end
end
pL = function()
    pcall(function()
        pR:InvokeServer()
    end)
end
pw = function()
    pcall(function()
        EquipBest:FireServer()
    end)
end
local zt_4 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = p4, Copyable = true }, "|", zt_60 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local zt_63 = {
    Info = zt_4:AddTab("Info", "info"),
    Main = zt_4:AddTab("Main", "droplets"),
    Shop = zt_4:AddTab("Shop", "shopping-bag"),
    Fish = zt_4:AddTab("Fish", "fish"),
    Player = zt_4:AddTab("Player", "person-standing"),
    Settings = zt_4:AddTab("Settings", "settings")
}
zt_4 = function(iB)
    local DiscordGroup = iB:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onJoinDiscordForKeylessScripts })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onJoinDiscordForKeylessScripts })
end
for k, v in zt_63 do
    zt_4(v)
end
qC, Label, pY = nil, nil, nil
qC = "Unknown"
pcall(fns.fn285)
local zt_51 = zt_63.Info:AddLeftGroupbox("Account", "circle-user")
zt_51:AddLabel(qB("User", LocalPlayer.Name, zt_35), true)
zt_51:AddLabel('<b>Status</b> <font color="#5a6070">-</font> <font color="#7fd47f">Keyless</font>', true)
zt_51:AddLabel(qB("Executor", qC, zt_35), true)
local GameInfoGroup = zt_63.Info:AddLeftGroupbox("Game Info", "gamepad-2")
GameInfoGroup:AddLabel(qQ(zt_60 .. " [" .. tostring(game.PlaceId) .. "]", zt_57), true)
GameInfoGroup:AddLabel(qB("Place ID", tostring(game.PlaceId), zt_57), true)
Label = GameInfoGroup:AddLabel('<b>Session time</b> <font color="#5a6070">-</font> <font color="#e8a34d">0s</font>', true)
pY = tostring(game.JobId)
local zt_29 = #pY > 18
if zt_29 then
    zt_4 = 5
    repeat
        if zt_4 * 112243475 + 2 + 7 <= zt_4 * 112243475 + 2 + 7 + 4 then
            zt_29 = string.sub(pY, 1, 18) .. "..."
        else
            pY = string.sub(zt_29, 1, 18) .. "..."
        end
        zt_4 = (zt_4 + 4) % 8
    until (zt_4 * 3 + 1) % 8 == 4
end
zt_4 = zt_29 or pY
px, FeaturesGroup, ProgressGroup, zt_51, EggsGroup = nil, nil, nil, nil, nil
local zt_67 = zt_4
GameInfoGroup:AddLabel(qB("Server", zt_67, zt_15), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
px = os.clock()
task.spawn(fns.worker)
local ScriptsGroup = zt_63.Info:AddRightGroupbox("Scripts", "package")
if (ProgressGroup or FeaturesGroup or (ProgressGroup or FeaturesGroup) or (not ProgressGroup or not ProgressGroup) and (not ProgressGroup or not ProgressGroup)) and ((not ProgressGroup or not FeaturesGroup) and (not FeaturesGroup and ProgressGroup) or (not FeaturesGroup or ProgressGroup or not ProgressGroup and ProgressGroup)) and not ((ProgressGroup or FeaturesGroup or (ProgressGroup or FeaturesGroup) or (not ProgressGroup or not ProgressGroup) and (not ProgressGroup or not ProgressGroup)) and ((not ProgressGroup or not FeaturesGroup) and (not FeaturesGroup and ProgressGroup) or (not FeaturesGroup or ProgressGroup or not ProgressGroup and ProgressGroup))) then
    qQ:AddLabel(zt_57("Included in this hub", ScriptsGroup), true)
    qQ:AddLabel(zt_57(zt_15, zt_63), true)
    FeaturesGroup.Info:AddRightGroupbox("Features", "list")
else
    ScriptsGroup:AddLabel('<font color="#8b93a3">Included in this hub</font>', true)
    ScriptsGroup:AddLabel('<font color="#6ec1ff">+1 Drain Water Per Click</font>', true)
    FeaturesGroup = zt_63.Info:AddRightGroupbox("Features", "list")
end
FeaturesGroup:AddLabel('<font color="#6ec1ff">Auto Drain</font>', true)
FeaturesGroup:AddLabel('<font color="#7fd47f">Auto Shop</font>', true)
FeaturesGroup:AddLabel('<font color="#e8a34d">Auto Fish / Aquarium</font>', true)
FeaturesGroup:AddLabel('<font color="#8b93a3">Misc Utilities</font>', true)
local SocialsGroup = zt_63.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = onJoinDiscordForKeylessScripts })
SocialsGroup:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
local TempoHubGroup = zt_63.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = onJoinDiscordForKeylessScripts })
local DonationsGroup = zt_63.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel('<font color="#e8a34d">All donations are optional but appreciated.</font>', true)
DonationsGroup:AddLabel('<font color="#7fd47f">If you donate you get a special role, just PING after you donate.</font>', true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel('<font color="#345d9d">LTC / Litecoin</font>', true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = fns.onCopyLitecoinAddress })
DonationsGroup:AddLabel('<font color="#f7931a">BTC / Bitcoin</font>', true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = fns.onCopyBitcoinAddress })
DonationsGroup:AddLabel('<font color="#627eea">ETH / Ethereum</font>', true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = fns.onCopyEthereumAddress })
DonationsGroup:AddLabel('<font color="#26a17b">USDT</font>', true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = fns.onCopyUSDTAddress })
DonationsGroup:AddLabel('<font color="#14f195">Solana</font>', true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = fns.onCopySolanaAddress })
DonationsGroup:AddLabel('<font color="#0070ba">PayPal</font>', true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = fns.onCopyPayPalLink })
DonationsGroup:AddLabel('<font color="#008cff">Venmo</font>', true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = fns.onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel('<font color="#8b93a3">Don\'t have any of the listed currencies but still wanna donate?</font>', true)
DonationsGroup:AddLabel('<font color="#6ec1ff">DM me and we\'ll work something out.</font>', true)
local FaqGroup = zt_63.Info:AddRightGroupbox("FAQ", "circle-help")
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
zt_29 = zt_63.Main:AddLeftGroupbox("Auto Drain", "droplets")
if (ProgressGroup and zt_67 or (zt_67 or zt_67)) and ((px or zt_67) and (not px or not zt_67)) and not ((ProgressGroup and zt_67 or (zt_67 or zt_67)) and ((px or zt_67) and (not px or not zt_67))) then
    zt_63:AddToggle("AutoDrain", { Text = "Auto Drain", Default = false })
    zt_63:AddDropdown("DrainStage", { Values = ProgressGroup, Text = "Stage", Default = ProgressGroup[1] })
    zt_63:AddDropdown("DrainPriority", { Text = "Fish Priority", Default = "Highest Earning", Values = zt_29 })
    zt_63:AddSlider("FishPickAmount", { Rounding = 0, Text = "Pick Up this Many", Default = 3, Min = 1, Max = 50 })
    zt_63:AddSlider("DrainClicks", { Default = 12, Min = 1, Max = 40, Rounding = 0, Text = "Clicks per pulse" })
    zt_63:AddSlider("DrainClickDelay", { Min = 0.03, Text = "Click delay", Rounding = 2, Suffix = "s", Default = 0.05, Max = 0.5 })
    zt_63:AddSlider("FishPickDelay", { Text = "Fish pick delay", Max = 1, Min = 0.05, Default = 0.12, Rounding = 2, Suffix = "s" })
    zt_63:AddSlider("DrainLoopDelay", { Min = 0.05, Text = "Loop delay", Rounding = 2, Suffix = "s", Default = 0.15, Max = 2 })
    zt_48.Main:AddRightGroupbox("Progress", "rotate-ccw")
else
    zt_29:AddToggle("AutoDrain", { Text = "Auto Drain", Default = false })
    zt_29:AddDropdown("DrainStage", { Text = "Stage", Values = zt_48, Default = zt_48[1] })
    zt_29:AddDropdown("DrainPriority", { Text = "Fish Priority", Values = zt_53, Default = "Highest Earning" })
    zt_29:AddSlider("FishPickAmount", { Text = "Pick Up this Many", Default = 3, Min = 1, Max = 50, Rounding = 0 })
    zt_29:AddSlider("DrainClicks", { Text = "Clicks per pulse", Default = 12, Min = 1, Max = 40, Rounding = 0 })
    zt_29:AddSlider("DrainClickDelay", { Text = "Click delay", Default = 0.05, Min = 0.03, Max = 0.5, Rounding = 2, Suffix = "s" })
    zt_29:AddSlider("FishPickDelay", { Text = "Fish pick delay", Default = 0.12, Min = 0.05, Max = 1, Rounding = 2, Suffix = "s" })
    zt_29:AddSlider("DrainLoopDelay", { Text = "Loop delay", Default = 0.15, Min = 0.05, Max = 2, Rounding = 2, Suffix = "s" })
    ProgressGroup = zt_63.Main:AddRightGroupbox("Progress", "rotate-ccw")
end
if (not ScriptsGroup or EggsGroup) and (not ScriptsGroup or ScriptsGroup) and (not ScriptsGroup and not ScriptsGroup and (not ScriptsGroup and not ScriptsGroup)) or not ((not ScriptsGroup or EggsGroup) and (not ScriptsGroup or ScriptsGroup) and (not ScriptsGroup and not ScriptsGroup and (not ScriptsGroup and not ScriptsGroup))) then
    ProgressGroup:AddToggle("AutoTrain", { Text = "Auto Train", Default = false })
    ProgressGroup:AddSlider("TrainDelay", { Text = "Train delay", Default = 0.08, Min = 0.03, Max = 1, Rounding = 2, Suffix = "s" })
    ProgressGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
    ProgressGroup:AddSlider("RebirthDelay", { Text = "Rebirth delay", Default = 1, Min = 0.5, Max = 30, Rounding = 1, Suffix = "s" })
    zt_51 = zt_63.Shop:AddLeftGroupbox("Shop", "shopping-bag")
else
    zt_51:AddToggle("AutoTrain", { Text = "Auto Train", Default = false })
    zt_51:AddSlider("TrainDelay", { Text = "Train delay", Default = 0.08, Suffix = "s", Max = 1, Min = 0.03, Rounding = 2 })
    zt_51:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
    zt_51:AddSlider("RebirthDelay", { Default = 1, Text = "Rebirth delay", Suffix = "s", Max = 30, Min = 0.5, Rounding = 1 })
    zt_63 = ProgressGroup.Shop:AddLeftGroupbox("Shop", "shopping-bag")
end
zt_51:AddToggle("AutoBuyPump", { Text = "Auto Buy Pump", Default = false })
zt_51:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
zt_51:AddToggle("AutoBuyAura", { Text = "Auto Buy Aura", Default = false })
zt_51:AddSlider("ShopDelay", { Text = "Shop delay", Default = 1, Min = 0.25, Max = 10, Rounding = 2, Suffix = "s" })
EggsGroup = zt_63.Shop:AddRightGroupbox("Eggs", "egg")
EggsGroup:AddToggle("AutoHatch", { Text = "Auto Hatch Eggs", Default = false })
zt_65 = #zt_43 > 0 and zt_43
zt_53 = { "Basic Egg" }
zt_69 = zt_65 or zt_53
zt_65 = zt_43[1]
local zt_45 = if zt_65 then 1 else 0
local zt_68 = 1783 * zt_45 + 1548 * (1 - zt_45)
local zt_56 = 3964 * zt_45 + 2946 * (1 - zt_45)
if not ((zt_68 * 2547 + zt_56 * 2154 + zt_68 * zt_56) % 16777213 == 3370356) then
    zt_65 = "Basic Egg"
end
pU, qu, qo, connection, connection2, qs, p1, o2, qh, p2, o_ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
EggsGroup:AddDropdown("HatchEgg", { Text = "Egg", Values = zt_69, Default = zt_65 })
EggsGroup:AddDropdown("HatchAmount", { Text = "Amount", Values = zt_31, Default = "1" })
EggsGroup:AddSlider("HatchDelay", { Text = "Hatch delay", Default = 1, Min = 0.25, Max = 10, Rounding = 2, Suffix = "s" })
zt_12 = zt_63.Fish:AddLeftGroupbox("Auto Sell", "banknote")
zt_12:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
zt_12:AddDropdown("SellMode", { Text = "Sell Mode", Values = { "Sell All", "Below Rarity" }, Default = "Sell All" })
zt_12:AddDropdown("SellBelowRarity", { Text = "Sell Below Rarity", Values = zt_20, Default = "Mythic" })
zt_12:AddDropdown("SellKeepMutations", { Text = "Keep Mutations", Values = qc, Default = {}, Multi = true })
zt_12:AddToggle("SellKeepProtected", { Text = "Keep Protected", Default = true })
zt_12:AddToggle("SellKeepSpecial", { Text = "Keep Special", Default = true })
zt_12:AddSlider("SellDelay", { Text = "Sell delay", Default = 0.05, Min = 0.01, Max = 1, Rounding = 2, Suffix = "s" })
zt_12:AddSlider("SellLoopDelay", { Text = "Sell loop delay", Default = 2, Min = 0.5, Max = 30, Rounding = 1, Suffix = "s" })
local AquariumGroup = zt_63.Fish:AddRightGroupbox("Aquarium", "container")
AquariumGroup:AddToggle("AutoCollectAquariumCash", { Text = "Auto Collect Aquarium Cash", Default = false })
AquariumGroup:AddToggle("AutoEquipBestAquarium", { Text = "Auto Equip Best Aquarium Fish", Default = false })
AquariumGroup:AddToggle("AutoEquipBestPet", { Text = "Auto Equip Best Pet", Default = false })
AquariumGroup:AddSlider("AquariumDelay", { Text = "Aquarium delay", Default = 3, Min = 0.5, Max = 30, Rounding = 1, Suffix = "s" })
zt_46 = zt_63.Player:AddLeftGroupbox("Movement", "footprints")
zt_46:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
zt_46:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
zt_46:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
zt_46:AddToggle("NoClip", { Text = "NoClip", Default = false })
zt_46:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
zt_57 = zt_63.Player:AddRightGroupbox("Fly", "feather")
zt_57:AddToggle("Fly", { Text = "Fly", Default = false })
zt_57:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
qs = function(jw)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not jw)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not jw
        end
    end)
    if not jw then
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
Toggles.AntiGameplayPause:OnChanged(fns.fn426)
Toggles.Fly:OnChanged(fns.fn390)
Toggles.WalkSpeedEnabled:OnChanged(fns.fn702)
RunService.Stepped:Connect(fns.onStepped)
UserInputService.JumpRequest:Connect(fns.onJumpRequest)
pU = Workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
zt_35 = zt_63.Settings:AddLeftGroupbox("Menu")
zt_35:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
zt_35:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
zt_35:AddButton("Unload", fns.onUnload)
qu = tick()
qo = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local yf = v
        pcall(function()
            yf:Disable()
        end)
    end
end)
p1 = fns.fn443
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
zt_9:SetLibrary(Library)
zt_9:SetFolder("TempoHub")
zt_9:SaveDefault("Monochrome")
zt_9:ApplyToTab(zt_63.Settings)
zt_9:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/plus1-drain-water-per-click")
zt_53 = SaveManager:BuildConfigSection(zt_63.Settings)
o2 = fn989
qh = fns.fn31
p2 = fns.fn906
o_ = function(k1)
    local yQ
    yQ = nil
    local yR = type(k1) ~= "table" or type(k1.idx) ~= "string" or type(k1.type) ~= "string" or SaveManager.Ignore[k1.idx]
    if yR then
        return false
    end
    yQ = o2(k1.type, k1.idx)
    if not yQ then
        return false
    end
    local yR_1 = pcall(function()
        if k1.type == "Input" then
            if type(k1.text) ~= "string" then
                return
            end
            yQ:SetValue(k1.text)
        elseif k1.type == "ColorPicker" then
            yQ:SetValueRGB(Color3.fromHex(k1.value), k1.transparency)
        elseif k1.type == "KeyPicker" then
            yQ:SetValue({ k1.key, k1.mode, k1.modifiers })
            if k1.mode == "Toggle" and k1.toggled ~= nil then
                yQ.Toggled = k1.toggled
                yQ:Update()
            end
        else
            yQ:SetValue(k1.value)
        end
    end)
    return yR_1
end
zt_53:AddDivider()
zt_53:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
zt_53:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
zt_53:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
task.spawn(fns.worker2)
task.spawn(fns.worker3)
task.spawn(fns.worker4)
task.spawn(fns.worker5)
task.spawn(fns.worker6)
task.spawn(worker7)
task.spawn(fns.worker8)
task.spawn(worker9)
task.spawn(fns.worker10)
Library:OnUnload(fns.fn307)
Library:Notify("+1 Drain Water Per Click loaded")
end)(...)

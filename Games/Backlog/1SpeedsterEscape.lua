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
getgenv().TempoHoodSubtitle = "+1 SPEEDSTER ESCAPE"
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
local nR
local ny
local nU
local nB
local nX
local nE
local n_
local nH
local n2
local no
local n5
local nK
local nr
local n8
local nN
local nQ
local nx
local nT
local nA
local Workspace
local nD
local nZ
local nG
local n1
local n4
local nJ
local nq
local n7
local nM
local nt
local nP
local nw
local nz
local nC
local nY
local nF
local nI
local n3
local np
local n6
local nO
local ns
local nv
local function fn1(ev)
    local rJ = tonumber(string.match(tostring(ev), "%d+"))
    if rJ and rJ >= 1 and rJ <= nK then
        nx.WinStage = rJ
    end
end
local function fn28()
    local pD = tonumber(nT:GetAttribute("Level")) or 1
    return pD
end
local function fn90(n)
    local oF = typeof(cloneref) == "function" and typeof(n) == "Instance"
    if oF then
        return cloneref(n)
    end
    return n
end
local function fn91(c5)
    n6(nx.OwnedAuras, c5)
end
local function fn139()
    return { Wins = nA, Treadmills = nD }
end
local function fn176(az)
    local o9_1
    if az == "Aura" then
        o9_1 = nY.Auras
    else
        o9_1 = nY.Trails
    end
    local pa = {}
    local pb = o9_1
    if type(pb) ~= "table" then
        return pa
    end
    for k, v in pb do
        local o9_2 = type(v) == "table" and type(v.Id) == "string" and v.ShopEnabled ~= false
        if o9_2 then
            local insert = table.insert
            local Id = v.Id
            local pc = tonumber(v.WinsCost) or 0
            insert(pa, { Id = Id, WinsCost = pc })
        end
    end
    table.sort(pa, function(aG, aH)
        if aG.WinsCost ~= aH.WinsCost then
            return aG.WinsCost < aH.WinsCost
        end
        return aG.Id < aH.Id
    end)
    return pa
end
local function fn219()
    local OwnedSkins = nx.OwnedSkins
    local qz = nH()
    local qA = n7()
    for k, v in nU.Ordered do
        local Id = v.Id
        local qC = type(Id) == "string" and OwnedSkins[Id] ~= true
        if qC then
            local qC_1 = tonumber(v.RequiredLevel) or 0
            local qC_2 = tonumber(v.RequiredRebirths) or 0
            if qz >= qC_1 and qA >= qC_2 then
                return Id
            end
            return nil
        end
    end
end
local function fn227(bH)
    local p1 = nw(bH)
    if p1 then
        return p1
    end
    local p1_1 = os.clock()
    if p1_1 - nx.LastStream < 0.45 then
        return
    end
    nx.LastStream = p1_1
    local p1_2 = np[bH] or n8[bH]
    nz(p1_2)
    if bH >= 9 then
        local p1_3 = (bH - 9) % #n3 + 1
        nz(n3[p1_3])
    end
    local p1_4 = Workspace:FindFirstChild(nE)
    local p2 = p1_4 and p1_4:FindFirstChild("stage" .. bH)
    local p1_5 = p2
    if p2 then
        p2 = p1_5:IsA("BasePart")
    end
    if p2 then
        n8[bH] = p1_5.Position
        nz(p1_5.Position + Vector3.new(-60, 90, -30))
    end
    return nw(bH)
end
local function fn260(de)
    if type(de) ~= "table" then
        return
    end
    local Owned = de.Owned
    if type(Owned) == "boolean" then
        nx.FlightOwned = Owned
    elseif type(Owned) == "table" then
        local ra = Owned[nv] == true or Owned.Flight == true
        nx.FlightOwned = ra
    end
    if tonumber(de.Wins) then
        nx.ShopWins = tonumber(de.Wins)
    end
end
local function worker3()
    while not nx.Unloaded do
        if nx.Enabled.Trails then
            local rB = nP(nC, nx.OwnedTrails)
            if rB then
                nG:FireServer("Buy", rB.Id)
                task.wait(0.8)
            else
                nG:FireServer("RequestState")
                task.wait(1.2)
            end
        else
            task.wait(0.4)
        end
    end
end
local function fn392(G, H)
    local connection = G:Connect(H)
    table.insert(n5, connection)
    return connection
end
local function fn393(ci)
    local ql_1
    local qk_1
    ql_1, qk_1 = nt(ci)
    if ql_1 then
        if ql_1:IsA("BasePart") then
            nZ[ci.Key] = ql_1.Position
            return ql_1
        end
        return ql_1, qk_1
    end
    local qk_2 = os.clock()
    if qk_2 - nx.LastStream >= 0.45 then
        nx.LastStream = qk_2
        nz(nZ[ci.Key])
    end
    return nt(ci)
end
local function fn411(c8)
    n6(nx.OwnedTrails, c8)
    local q1 = type(c8) == "table" and type(c8.Owned) ~= "table" and type(c8.OwnedTrails) == "table"
    if q1 then
        table.clear(nx.OwnedTrails)
        for k, v in c8.OwnedTrails do
            if v == true then
                nx.OwnedTrails[k] = true
            end
        end
    end
end
local function fn444()
    nx.FlightOwned = nT:GetAttribute("FlightAbilityOwned") == true
end
local function fn465(c0, c1)
    if type(c1) ~= "table" then
        return
    end
    if type(c1.Owned) == "table" then
        table.clear(c0)
        for k, v in c1.Owned do
            if v == true then
                c0[k] = true
            end
        end
    end
    if tonumber(c1.Wins) then
        nx.ShopWins = tonumber(c1.Wins)
    end
end
local function worker5()
    while not nx.Unloaded do
        if nx.Enabled.Rebirth then
            local rw = tonumber(nT:GetAttribute("NextRebirthLevelRequired")) or 5
            if nH() >= rw then
                nR:FireServer("Rebirth")
                task.wait(1.2)
            else
                task.wait(0.5)
            end
        else
            task.wait(0.4)
        end
    end
end
local function fn516(cT, cU)
    local qM = nJ()
    for k, v in cT do
        if cU[v.Id] ~= true and qM >= v.WinsCost then
            return v
        end
    end
end
local function fn517()
    if n2.IsWorld2Place then
        return n2.World2TreadmillProfiles
    end
    return n2.NewWorld1TreadmillProfiles
end
local function fn529(es, et)
    nx.Enabled[es] = et == true
end
local function fn531()
    local pw = tonumber(nT:GetAttribute("Rebirths"))
    if pw then
        return pw
    end
    local leaderstats = nT:FindFirstChild("leaderstats")
    local px = leaderstats and leaderstats:FindFirstChild("Rebirths")
    local pw_2 = px
    if px then
        local py = tonumber(pw_2.Value) or 0
        px = py
    end
    local pw_3 = px
    local pC = if pw_3 then 1 else 0
    local pA = 4009 * pC + 410 * (1 - pC)
    local pB = 3271 * pC + 225 * (1 - pC)
    if not ((pA * 299 + pB * 3954 + pA * pB) % 16777213 == 10468451) then
        pw_3 = 0
    end
    return pw_3
end
local function fn721()
    local Character = nT.Character
    local pl = Character and Character:FindFirstChildOfClass("Humanoid")
    local pm = Character
    if pm then
        pm = Character:FindFirstChild("HumanoidRootPart")
    end
    local pl_1 = Character
    local po = pm
    if pl_1 then
        pl_1 = pl
    end
    if pl_1 then
        pl_1 = po
    end
    if pl_1 then
        pl_1 = pl.Health > 0
    end
    if pl_1 then
        return Character, pl, po
    end
end
local function worker4()
    while not nx.Unloaded do
        if nx.Enabled.Auras then
            local rz = nP(nF, nx.OwnedAuras)
            if rz then
                nO:FireServer("Buy", rz.Id)
                task.wait(0.8)
            else
                nO:FireServer("RequestState")
                task.wait(1.2)
            end
        else
            task.wait(0.4)
        end
    end
end
local function worker7()
    while not nx.Unloaded do
        if nx.Enabled.Win then
            local rq = nN(nx.WinStage)
            if rq then
                n_(rq)
            end
            task.wait(0.2)
        else
            task.wait(0.3)
        end
    end
end
local function fn777(be)
    local pG = typeof(be) ~= "Instance" or not be:IsA("BasePart")
    if pG then
        return
    end
    local pG_1 = tonumber(be:GetAttribute("SafeZoneIndex"))
    local pH = not pG_1 or be:GetAttribute("WinReward") == nil
    if pH then
        return
    end
    local pH_1 = string.find(be.Name, "Skip") or string.find(be.Name, "^X%d")
    if pH_1 then
        return
    end
    nx.PadCache[pG_1] = be
    np[pG_1] = be.Position
end
local function fn790()
    nO:FireServer("RequestState")
    nG:FireServer("RequestState")
    ny:FireServer("RequestState")
    nR:FireServer("Sync")
end
local function worker6()
    local ru_1
    local rt_1
    while not nx.Unloaded do
        if nx.Enabled.Train and not nx.Enabled.Win then
            local rs_1 = nI[nx.Treadmill]
            if no(rs_1) then
                ru_1, rt_1 = nM(rs_1)
                if ru_1 or rt_1 then
                    n_(ru_1, rt_1)
                end
            end
            task.wait(0.2)
        else
            task.wait(0.3)
        end
    end
end
local function fn814()
    if nx.Unloaded then
        return
    end
    nx.Unloaded = true
    for k in nx.Enabled do
        nx.Enabled[k] = false
    end
    for k, v in n5 do
        v:Disconnect()
    end
    table.clear(n5)
    if getgenv()[nQ] == n4 then
        getgenv()[nQ] = nil
    end
end
local function fn820()
    local leaderstats = nT:FindFirstChild("leaderstats")
    local pr = leaderstats and leaderstats:FindFirstChild("Wins")
    if pr then
        local pr_1 = (tonumber(pr.Value))
        local pv = if pr_1 then 1 else 0
        local pt = 2075 * pv + 1769 * (1 - pv)
        local pu = 2990 * pv + 1237 * (1 - pv)
        if not ((pt * 3031 + pu * 4024 + pt * pu) % 16777213 == 7748122) then
            pr_1 = 0
        end
        return pr_1
    end
    return nx.ShopWins
end
local function fn846(dw)
    n1(dw)
end
local function fn865(bm)
    local pJ = nx.PadCache[bm]
    if pJ and pJ.Parent then
        return pJ
    end
    local NewWorld1ManualStagePads_Run = Workspace:FindFirstChild("NewWorld1ManualStagePads_Runtime")
    if NewWorld1ManualStagePads_Run then
        local pK_1 = NewWorld1ManualStagePads_Run:FindFirstChild("Win" .. bm .. "_RuntimePad")
        local pL = pK_1 and pK_1:IsA("BasePart")
        if pL then
            n1(pK_1)
            return pK_1
        end
        for i, child in NewWorld1ManualStagePads_Run:GetChildren() do
            local pJ_2 = tonumber(child:GetAttribute("SafeZoneIndex")) == bm and child:GetAttribute("WinReward") ~= nil
            if pJ_2 then
                n1(child)
                return child
            end
        end
    end
    local WinPads_TO_PLACE = Workspace:FindFirstChild("WinPads_TO_PLACE")
    if WinPads_TO_PLACE then
        for i, child in WinPads_TO_PLACE:GetChildren() do
            local pJ_4 = child:IsA("BasePart") and tonumber(child:GetAttribute("SafeZoneIndex")) == bm
            if pJ_4 then
                n1(child)
                return child
            end
        end
    end
    local pJ_5 = Workspace:FindFirstChild("X" .. bm)
    local pK_2 = pJ_5 and pJ_5:FindFirstChild("Win" .. bm)
    local pJ_6 = pK_2
    if pK_2 then
        pK_2 = pJ_6:IsA("BasePart")
    end
    if pK_2 then
        return pJ_6
    end
end
local function worker()
    while not nx.Unloaded do
        if nx.Enabled.Abilities then
            local rF = nx.FlightOwned or nT:GetAttribute("FlightAbilityOwned") == true
            local rF_1 = nT:GetAttribute("FlightAbilityEquipped") == true or nT:GetAttribute("EquippedAbility") == nv
            if rF then
                if not rF_1 then
                    ny:FireServer("Equip", nv)
                end
                task.wait(1.5)
            elseif nJ() >= nB then
                ny:FireServer("BuyWins", nv)
                task.wait(1.2)
            else
                ny:FireServer("RequestState")
                task.wait(1.5)
            end
        else
            task.wait(0.4)
        end
    end
end
local function fn910()
    local attr = nT:GetAttribute("EquippedSkin")
    local rn = attr ~= ""
    local ro = type(attr) == "string" and rn
    if ro then
        nx.OwnedSkins[attr] = true
    end
end
local function fn918(cr, cs)
    local qp_1
    local qo_1
    local qn_1
    qn_1, qp_1, qo_1 = nq()
    if not qo_1 then
        return false
    end
    local qn_2 = cr
    local qq = cs
    if qn_2 then
        qn_2 = cr:IsA("BasePart")
    end
    if qn_2 then
        qq = cr.Position + Vector3.new(0, 3, 0)
    elseif typeof(cs) == "Vector3" then
        qq = cs + Vector3.new(0, 3, 0)
    end
    if typeof(qq) ~= "Vector3" then
        return false
    end
    qo_1.CFrame = CFrame.new(qq)
    qo_1.AssemblyLinearVelocity = Vector3.zero
    local qn_3 = cr and cr:IsA("BasePart") and typeof(firetouchinterest) == "function"
    if qn_3 then
        pcall(firetouchinterest, cr, qo_1, 1)
        pcall(firetouchinterest, cr, qo_1, 0)
    end
    if qp_1 then
        qp_1:ChangeState(Enum.HumanoidStateType.Running)
    end
    return true
end
local function fn929(V)
    if type(V) ~= "string" then
        return nil
    end
    return (string.gsub(V, "\n", " "))
end
local function fn968(dj)
    if type(dj) ~= "table" then
        return
    end
    if type(dj.OwnedSkins) == "table" then
        table.clear(nx.OwnedSkins)
        for k, v in dj.OwnedSkins do
            if v == true then
                nx.OwnedSkins[k] = true
            end
        end
    end
    local EquippedSkin = dj.EquippedSkin
    local rd = EquippedSkin ~= ""
    local re = type(EquippedSkin) == "string" and rd
    if re then
        nx.OwnedSkins[EquippedSkin] = true
    end
    nx.OwnedSkins[ns] = true
end
local function fn998(cB)
    if not cB then
        return false
    elseif cB.GamePassId then
        return true
    else
        local qv = n7()
        return qv >= (cB.RequiredRebirths or 0)
    end
end
local function fn1017(eA)
    if nI[eA] then
        nx.Treadmill = eA
    end
end
local function worker2()
    while not nx.Unloaded do
        if nx.Enabled.Evolve then
            local rD = nX()
            if rD then
                nr:FireServer(rD)
                task.wait(1.2)
            else
                task.wait(0.8)
            end
        else
            task.wait(0.4)
        end
    end
end
no = nil
np = nil
nq = nil
nr = nil
ns = nil
nt = nil
nv = nil
nw = nil
nx = nil
ny = nil
nz = nil
nA = nil
nB = nil
nC = nil
nD = nil
nE = nil
nF = nil
nG = nil
nH = nil
nI = nil
nJ = nil
nK = nil
nM = nil
nN = nil
nO = nil
nP = nil
nQ = nil
nR = nil
nT = nil
nU = nil
Workspace = nil
nX = nil
nY = nil
nZ = nil
n_ = nil
n1 = nil
n2 = nil
n3 = nil
n4 = nil
n5 = nil
n6 = nil
n7 = nil
n8 = nil
local Players, nu, nL, nS, nV, RunService
local oa_1
Players, RunService, Workspace, nT, nQ, oa_1 = nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NewWorld1ManualStagePads_Run, oc_2
RunService = game:GetService("RunService")
Workspace = game:GetService("Workspace")
nT = Players.LocalPlayer
if not Players and not Players and 9 and (Players and Players and (not Players)) or false or (not Players or not Players and false or (not Players or false) and (not Players and Players)) or not (not Players and not Players and 9 and (Players and Players and (not Players)) or false or (not Players or not Players and false or (not Players or false) and (not Players and Players))) then
    nQ = "TempoSpeedsterEscape"
else
    nT = "TempoSpeedsterEscape"
end
local ob = getgenv()[nQ]
if (not ReplicatedStorage or not RunService or RunService and ReplicatedStorage or (not Players and Workspace or not Workspace and ReplicatedStorage)) and ((oa_1 or not Workspace) and (RunService or oa_1) and (not oa_1 and not oa_1 and (oa_1 or not oa_1))) and ((Players or Workspace or not oa_1 and false) and (RunService and (not oa_1 or Players)) or (RunService or RunService or (not oa_1 or not oa_1)) and (RunService and oa_1 or (not Workspace or oa_1))) or not ((not ReplicatedStorage or not RunService or RunService and ReplicatedStorage or (not Players and Workspace or not Workspace and ReplicatedStorage)) and ((oa_1 or not Workspace) and (RunService or oa_1) and (not oa_1 and not oa_1 and (oa_1 or not oa_1))) and ((Players or Workspace or not oa_1 and false) and (RunService and (not oa_1 or Players)) or (RunService or RunService or (not oa_1 or not oa_1)) and (RunService and oa_1 or (not Workspace or oa_1)))) then
    oa_1 = ob
else
    ob = oa_1
end
if oa_1 then
    oa_1 = ob.Unload
end
if oa_1 then
    ob.Unload()
end
n2, nY, nU, nR, nO, nG, ny, nr, n5 = nil, nil, nil, nil, nil, nil, nil, nil, nil
local oa_2 = fn90(ReplicatedStorage)
local n9 = fn90(oa_2:WaitForChild("Shared"))
local oe = fn90(oa_2:WaitForChild("Remotes"))
n2 = require(fn90(n9:WaitForChild("Config")))
nY = require(fn90(n9:WaitForChild("CosmeticCatalog")))
nU = require(fn90(n9:WaitForChild("SuitCatalog")))
nR = fn90(oe:WaitForChild("RebirthRequest"))
nO = fn90(oe:WaitForChild("AuraShopAction"))
local oj = fn90(oe:WaitForChild("AuraShopUpdate"))
nG = fn90(oe:WaitForChild("TrailShopAction"))
local oi = fn90(oe:WaitForChild("TrailShopUpdate"))
ny = fn90(oe:WaitForChild("AbilityShopAction"))
local oh = fn90(oe:WaitForChild("AbilityShopUpdate"))
nr = fn90(oe:WaitForChild("EquipSkin"))
local og = fn90(oe:WaitForChild("EvolveSkinUpdate"))
n5 = {}
local n9_1 = (tonumber(n2.StageCount))
local ot = if n9_1 then 1 else 0
local op = 3073 * ot + 1907 * (1 - ot)
local oq = 32 * ot + 3040 * (1 - ot)
if not ((op * 634 + oq * 4005 + op * oq) % 16777213 == 2174778) then
    n9_1 = 11
end
nK = n9_1
nE = n2.NewWorld1MapMarkerName or "neworld1"
local n9_3 = tonumber(n2.AbilityFlightWinsCost) or 1000000
nB = n9_3
nv = n2.AbilityFlightUpgradeName or "Flight"
local n9_5 = nU.DefaultSkinId or "FlashSuit"
ns, np, n8, n3, nZ, nV, nL, nI, nD, nA, nS, nu = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
ns = n9_5
np = {
    [1] = Vector3.new(209.36888122559, 37468.44921875, -1316.43359375),
    [2] = Vector3.new(203.36888122559, 37468.44921875, -1016.43359375),
    [3] = Vector3.new(200.36888122559, 37517.63671875, -622.43359375),
    [4] = Vector3.new(200.36888122559, 37520.875, -95.43359375),
    [5] = Vector3.new(206.64579772949, 37513.61328125, 240.45631408691),
    [6] = Vector3.new(223.99417114258, 37524.61328125, 823.2021484375),
    [7] = Vector3.new(242.21527099609, 37525.61328125, 1345.0092773438),
    [8] = Vector3.new(230.0592041015625, 37525.61328125, 1913.7677001953125)
}
n8 = {
    [1] = Vector3.new(272.70516967773, 37387.7109375, -1287.09375),
    [2] = Vector3.new(264.70516967773, 37369.7109375, -984.53784179688),
    [3] = Vector3.new(263.28540039062, 37421.3671875, -589.70153808594),
    [4] = Vector3.new(264.28540039062, 37467.8359375, -67.360473632812),
    [5] = Vector3.new(268.25765991211, 37369.83203125, 267.32162475586),
    [6] = Vector3.new(291.64868164062, 37445.3046875, 851.73754882812),
    [7] = Vector3.new(301.21731567383, 37427.1484375, 1374.7495117188),
    [8] = Vector3.new(289.8954772949219, 37383.6484375, 1943.36865234375)
}
n3 = {
    Vector3.new(54.81146240234375, 37514.17578125, 2073.420654296875),
    Vector3.new(-368.2906188964844, 37963.66796875, 2689.642822265625),
    Vector3.new(-246.79974365234375, 37981.2578125, 4050.12451171875)
}
nZ = {
    Basic = Vector3.new(159.8963165283203, 37469.0859375, -1706.5577392578125),
    Golden = Vector3.new(160.48944091796875, 37468.98828125, -1723.958984375),
    Candy = Vector3.new(160.50045776367188, 37469.08984375, -1741.65576171875),
    Diamond = Vector3.new(162.59500122070312, 37468.9375, -1759.3961181640625),
    Needoh = Vector3.new(163.31332397460938, 37469.30078125, -1777.7335205078125),
    Admin = Vector3.new(166.38206481933594, 37469.1484375, -1796.1339111328125),
    Hacker = Vector3.new(171.7630615234375, 37469.2890625, -1818.59814453125)
}
nV = { "Basic", "Golden", "Candy", "Diamond", "Needoh", "Admin", "Hacker" }
nS = fn929
nL = {}
nI = {}
nD = {}
nA = {}
nu = fn517
local function oa_3()
    table.clear(nL)
    table.clear(nI)
    table.clear(nD)
    local oP = nu()
    local oQ = {}
    if n2.IsWorld2Place then
        for k in oP do
            table.insert(oQ, k)
        end
        table.sort(oQ, function(ao, ap)
            local oM = tonumber(oP[ao].BaseGain) or 0
            local oN = tonumber(oP[ap].BaseGain) or 0
            return oM < oN
        end)
    else
        for k, v in nV do
            if oP[v] then
                table.insert(oQ, v)
            end
        end
    end
    for k, v in oQ do
        local oQ_1 = oP[v]
        local oR = nS(oQ_1.DisplayText) or v
        local oR_1 = tonumber(oQ_1.RequiredRebirths) or 0
        local oT = {
            Key = v,
            Label = oR,
            RequiredRebirths = oR_1,
            GamePassId = tonumber(oQ_1.GamePassId),
            SourceName = oQ_1.SourceName
        }
        nL[oR] = oT
        nI[oR] = oT
        table.insert(nD, oR)
    end
end
oa_3()
local ow = 1
local ou = nK
while ow <= ou do
    local ox = ow
    table.insert(nA, "Stage " .. ox)
    ow += 1
end
nF, nC, nx = nil, nil, nil
nF = fn176("Aura")
nC = fn176("Trail")
nx = {
    Unloaded = false,
    Enabled = {
        Win = false,
        Train = false,
        Rebirth = false,
        Auras = false,
        Trails = false,
        Evolve = false,
        Abilities = false
    },
    WinStage = 1,
    Treadmill = nD[1],
    PadCache = {},
    OwnedAuras = {},
    OwnedTrails = {},
    OwnedSkins = { [ns] = true },
    ShopWins = 0,
    FlightOwned = nT:GetAttribute("FlightAbilityOwned") == true,
    LastStream = 0
}
local attr = nT:GetAttribute("EquippedSkin")
local n9_7 = attr ~= ""
local oa_4 = type(attr) == "string" and n9_7
if oa_4 then
    local n9_8 = 1
    repeat
        if n9_8 * 87244403 + 4 + 4 >= n9_8 * 87244403 + 4 + 4 + 2 then
            attr.OwnedSkins[nx] = true
        else
            nx.OwnedSkins[attr] = true
        end
        n9_8 = (n9_8 + 1) % 4
    until (n9_8 * 3 + 1) % 4 == 3
end
NewWorld1ManualStagePads_Run, nq, nJ, n7, nH, nz, n1, nw, nN, nt, nM, n_, no, nX, nP, n6 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
nq = fn721
nJ = fn820
n7 = fn531
nH = fn28
nz = function(a9)
    if typeof(a9) ~= "Vector3" then
        return
    end
    pcall(function()
        nT:RequestStreamAroundAsync(a9)
    end)
end
n1 = fn777
nw = fn865
nN = fn227
nt = function(bZ)
    local p7
    local p9_6
    if not bZ then
        return
    end
    local VortexTreadmillCollisionFix_ = Workspace:FindFirstChild("VortexTreadmillCollisionFix_V255")
    local p8_6
    if VortexTreadmillCollisionFix_ then
        for i, child in VortexTreadmillCollisionFix_:GetChildren() do
            local attr = child:GetAttribute("SourceTreadmill")
            local p9_1 = type(attr) == "string" and string.find(attr, bZ.Key, 1, true)
            if p9_1 then
                local SmoothDeck = child:FindFirstChild("SmoothDeck")
                local p9_2 = SmoothDeck and SmoothDeck:IsA("BasePart")
                if p9_2 then
                    return SmoothDeck
                end
            end
        end
    end
    if type(bZ.SourceName) == "string" then
        local p8_3 = Workspace:FindFirstChild(bZ.SourceName, true)
        if p8_3 then
            if p8_3:IsA("BasePart") then
                return p8_3
            end
            local SmoothDeck = p8_3:FindFirstChild("SmoothDeck", true)
            if SmoothDeck then
                return SmoothDeck
            end
            return p8_3
        end
    end
    local p8_4 = Workspace:FindFirstChild(nE)
    local p9_4 = p8_4 and p8_4:FindFirstChild(bZ.Key, true)
    if p9_4 then
        local p9_5 = p9_4:FindFirstChild("Treadmil", true) or p9_4
        p7 = p9_5
        if p7:IsA("BasePart") then
            return p7
        end
        p8_6, p9_6 = pcall(function()
            return p7:GetPivot()
        end)
        if p8_6 then
            return p7, p9_6.Position
        end
    end
end
nM = fn393
if (false or nH) and (nH and not nX) and ((nH or nM) and (false or not nH)) or (nX and nH and (nP or nt) or (not nP or nH) and (not nX and nP)) or not ((false or nH) and (nH and not nX) and ((nH or nM) and (false or not nH)) or (nX and nH and (nP or nt) or (not nP or nH) and (not nX and nP))) then
    n_ = fn918
else
    nH = fn918
end
no = fn998
nX = fn219
nP = fn516
n6 = fn465
if (NewWorld1ManualStagePads_Run or not n_) and (NewWorld1ManualStagePads_Run or not nM) and (n_ and n_ and (nq and n_)) and not ((NewWorld1ManualStagePads_Run or not n_) and (NewWorld1ManualStagePads_Run or not nM) and (n_ and n_ and (nq and n_))) then
    NewWorld1ManualStagePads_Run(Workspace.OnClientEvent, fn91)
    NewWorld1ManualStagePads_Run(nT.OnClientEvent, fn411)
    NewWorld1ManualStagePads_Run(og.OnClientEvent, fn260)
    NewWorld1ManualStagePads_Run(oi.OnClientEvent, fn968)
    NewWorld1ManualStagePads_Run(oh:GetAttributeChangedSignal("FlightAbilityOwned"), fn444)
    NewWorld1ManualStagePads_Run(oh:GetAttributeChangedSignal("EquippedSkin"), fn910)
    NewWorld1ManualStagePads_Run(oj.DescendantAdded, fn846)
    oj:FindFirstChild("NewWorld1ManualStagePads_Runtime")
else
    fn392(oj.OnClientEvent, fn91)
    fn392(oi.OnClientEvent, fn411)
    fn392(oh.OnClientEvent, fn260)
    fn392(og.OnClientEvent, fn968)
    fn392(nT:GetAttributeChangedSignal("FlightAbilityOwned"), fn444)
    fn392(nT:GetAttributeChangedSignal("EquippedSkin"), fn910)
    fn392(Workspace.DescendantAdded, fn846)
    NewWorld1ManualStagePads_Run = Workspace:FindFirstChild("NewWorld1ManualStagePads_Runtime")
end
if NewWorld1ManualStagePads_Run then
    for i, child in NewWorld1ManualStagePads_Run:GetChildren() do
        n1(child)
    end
end
n4, oc_2 = nil, nil
pcall(fn790)
if (false and not oc_2 and (oc_2 and not n4) or (not n4 and not oc_2 or false)) and ((n4 or not n4) and (n4 or not n4) or (worker or oc_2 or oc_2 and false)) and not ((false and not oc_2 and (oc_2 and not n4) or (not n4 and not oc_2 or false)) and ((n4 or not n4) and (n4 or not n4) or (worker or oc_2 or oc_2 and false))) then
    task.spawn(worker5)
    task.spawn(worker2)
    task.spawn(worker6)
    task.spawn(worker3)
    task.spawn(worker7)
    task.spawn(n4)
    task.spawn(worker4)
else
    task.spawn(worker7)
    task.spawn(worker6)
    task.spawn(worker5)
    task.spawn(worker4)
    task.spawn(worker3)
    task.spawn(worker2)
    task.spawn(worker)
    n4 = {}
end
n4.State = nx
n4.SetEnabled = fn529
n4.SetWinStage = fn1
n4.SetTreadmill = fn1017
n4.Options = fn139
n4.Unload = fn814
getgenv()[nQ] = n4
local function oc_3()
    local wl
    local Library
    local Unload
    local onDiscord
    local wj
    Library = nil
    Unload = nil
    wj = nil
    wl = nil
    onDiscord = nil
    local Toggles, TeleportService, SaveManager, UserInputService, wo, wp, wq, ThemeManager, Options, HttpService, wv
    wq = "https://tempohub.shop"
    HttpService = game:GetService("HttpService")
    TeleportService = game:GetService("TeleportService")
    wl = "https://discord.gg/K7Qxnxkk46"
    wo = "+1 Speedster Escape"
    UserInputService = game:GetService("UserInputService")
    wv = "https://discord.gg/K7Qxnxkk46"
    Library = getgenv().Library
    ThemeManager = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = Library.Toggles
    Options = Library.Options
    Unload = n4.Unload
    n4.Unload = function()
        if not Library.Unloaded then
            Library:Unload()
        else
            Unload()
        end
    end
    Library:OnUnload(Unload)
    wj = function(e4, e5)
        if setclipboard then
            setclipboard(e4)
        elseif toclipboard then
            toclipboard(e4)
        end
        Library:Notify(e5)
    end
    onDiscord = function()
        wj(wl, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = wl, Copyable = true }, "|", wo },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(true, { Color = Color3.fromRGB(242, 154, 196), Radius = 24, Transparency = 0.3 })
    wp = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gamepad-2"),
        Shop = Window:AddTab("Shop", "shopping-cart"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
    local function ww_1(fd)
        local DiscordGroup = fd:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    for k, v in wp do
        if k ~= "Info" then
            ww_1(v)
        end
    end
    local ww_2 = n4.Options()
    local FarmGroup = wp.Main:AddLeftGroupbox("Farm", "trophy")
    FarmGroup:AddToggle("AutoWin", {
        Text = "Auto Win",
        Default = false,
        Callback = function(fk)
            n4.SetEnabled("Win", fk)
        end
    })
    FarmGroup:AddDropdown("WinStage", {
        Text = "Win Pad",
        Values = ww_2.Wins,
        Default = 1,
        Callback = function(fm)
            n4.SetWinStage(fm)
        end
    })
    FarmGroup:AddToggle("AutoRebirth", {
        Text = "Auto Rebirth",
        Default = false,
        Callback = function(fp)
            n4.SetEnabled("Rebirth", fp)
        end
    })
    local TrainGroup = wp.Main:AddRightGroupbox("Train", "footprints")
    TrainGroup:AddToggle("AutoTrain", {
        Text = "Auto Train Speed",
        Default = false,
        Callback = function(fs)
            n4.SetEnabled("Train", fs)
        end
    })
    TrainGroup:AddDropdown("Treadmill", {
        Text = "Treadmill",
        Values = ww_2.Treadmills,
        Default = 1,
        Callback = function(fu)
            n4.SetTreadmill(fu)
        end
    })
    local CosmeticsGroup = wp.Shop:AddLeftGroupbox("Cosmetics", "sparkles")
    CosmeticsGroup:AddToggle("AutoAuras", {
        Text = "Auto Buy Auras",
        Default = false,
        Callback = function(fx)
            n4.SetEnabled("Auras", fx)
        end
    })
    CosmeticsGroup:AddToggle("AutoTrails", {
        Text = "Auto Buy Trails",
        Default = false,
        Callback = function(fz)
            n4.SetEnabled("Trails", fz)
        end
    })
    local ProgressGroup = wp.Shop:AddRightGroupbox("Progress", "swords")
    ProgressGroup:AddToggle("AutoEvolve", {
        Text = "Auto Evolve",
        Default = false,
        Callback = function(fC)
            n4.SetEnabled("Evolve", fC)
        end
    })
    ProgressGroup:AddToggle("AutoAbilities", {
        Text = "Auto Buy Abilities",
        Default = false,
        Callback = function(fE)
            n4.SetEnabled("Abilities", fE)
        end
    })
    local function ww_5()
        local sY
        local s2
        local s0
        local sZ
        local sV
        local s5
        sV = nil
        sY = nil
        sZ = nil
        s0 = nil
        s2 = nil
        s5 = nil
        local Label2, Label3, s_, Label, s3, s4
        s2 = function(fI, fJ)
            return string.format('<font color="%s">%s</font>', fJ, fI)
        end
        s4 = function(fL, fM, fN)
            return string.format("<b>%s</b> %s %s", fL, s2("-", "#5a6070"), s2(fM, fN))
        end
        s0 = "#7fd47f"
        s5 = "#e05a5a"
        sY = "#e8a34d"
        local s7 = "#8b93a3"
        local function s8()
            local r2 = hookfunction ~= nil
            local r3 = hookmetamethod ~= nil
            local r4 = getrawmetatable ~= nil
            local r5 = setrawmetatable ~= nil
            local r6 = getgc ~= nil
            local r7 = getgenv ~= nil
            local r8 = getreg ~= nil
            local r9 = getconnections ~= nil
            local sa = firesignal ~= nil
            local sb = getcallbackvalue ~= nil
            local sc = setclipboard ~= nil
            local sd = getcustomasset ~= nil
            local se = getnamecallmethod ~= nil
            local sf = isexecutorclosure ~= nil
            local sg = fireproximityprompt ~= nil
            local sh = firetouchinterest ~= nil
            local si = WebSocket ~= nil
            local sj = readfile ~= nil
            local sk = writefile ~= nil
            local sl = request
            local sw = if sl then 1 else 0
            local su = 2850 * sw + 380 * (1 - sw)
            local sv = 3210 * sw + 1109 * (1 - sw)
            if not ((su * 2637 + sv * 1124 + su * sv) % 16777213 == 3494777) then
                sl = http_request
            end
            local sm = sl ~= nil
            local so = (debug and debug.getupvalues) ~= nil
            local sq = (debug and debug.setupvalue) ~= nil
            local sr = 0
            local ss = { r2, r3, r4, r5, r6, r7, r8, r9, sa, sb, sc, sd, se, sf, sg, sh, si, sj, sk, sm, so, sq }
            for i, v in ipairs(ss) do
                if v then
                    sr += 1
                end
            end
            local r2_1 = sr / #ss
            if r2_1 >= 0.9 then
                return s2("Full Support", s0)
            elseif r2_1 >= 0.6 then
                return s2("Half Support", sY)
            else
                return s2("Low Support", s5)
            end
        end
        sV = "Unknown"
        pcall(function()
            local sE_1
            local sD_1
            if identifyexecutor then
                sE_1, sD_1 = identifyexecutor()
                local sF = sE_1 ~= ""
                local sG = type(sE_1) == "string" and sF
                if sG then
                    local sF_1 = type(sD_1) == "string" and sD_1 ~= "" and sE_1 .. " " .. sD_1
                    sV = sF_1 or sE_1
                end
            end
        end)
        local s9 = s8()
        sZ = os.clock()
        s3 = function()
            local sL = math.floor(os.clock() - sZ)
            if sL < 60 then
                return sL .. "s"
            elseif sL < 3600 then
                return string.format("%dm %ds", math.floor((sL) / (60)), sL % 60)
            else
                return string.format("%dh %dm", math.floor((sL) / (3600)), math.floor((sL % 3600) / (60)))
            end
        end
        local UserGroup = wp.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = nT, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(s4("User", nT.DisplayName .. " @" .. nT.Name, s0), true)
        UserGroup:AddLabel(s4("UserId", tostring(nT.UserId), "#6ec1ff"), true)
        UserGroup:AddLabel(s4("Executor", sV .. "  " .. s9, s0), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(s4("Session", s3(), sY), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                wj(nT.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                wj("https://www.roblox.com/users/" .. tostring(nT.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = wp.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddDivider("Server")
        SessionGroup:AddLabel(s4("Game", wo, "#6ec1ff"), true)
        Label2 = SessionGroup:AddLabel(s4("Players", "0/0", s0), true)
        s_ = tostring(game.JobId)
        local s6 = #s_ > 18 and string.sub(s_, 1, 18) .. "..."
        local s9_1 = s6 or s_
        SessionGroup:AddLabel(s4("Job", s9_1, s7), true)
        Label = SessionGroup:AddLabel(s4("Ping", "0 ms", sY), true)
        SessionGroup:AddDivider()
        SessionGroup:AddButton({
            Text = "Rejoin Server",
            Func = function()
                TeleportService:Teleport(game.PlaceId, nT)
            end
        })
        SessionGroup:AddButton({
            Text = "Copy Job ID",
            Func = function()
                wj(s_, "Copied Job ID")
            end
        })
        task.spawn(function()
            local sO_1
            local sN_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(s4("Session", s3(), sY))
                Label2:SetText(s4("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), s0))
                sN_1, sO_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local sN_2 = sN_1 and sO_1 .. " ms"
                local sT = if sN_2 then 1 else 0
                local sR = 1743 * sT + 4073 * (1 - sT)
                local sS = 4038 * sT + 2333 * (1 - sT)
                if not ((sR * 2770 + sS * 1018 + sR * sS) % 16777213 == 15977028) then
                    sN_2 = "n/a"
                end
                Label:SetText(s4("Ping", sN_2, sY))
            end
        end)
        local SocialsGroup = wp.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                if setclipboard then
                    setclipboard(wv)
                elseif toclipboard then
                    toclipboard(wv)
                end
                Library:Notify("Copied Rscripts profile to clipboard")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                wj(wq, "Copied website link")
            end
        })
    end
    ww_5()
    local function ww_6()
        local g2
        local g0
        local g_
        local g1
        g0 = {}
        g_ = {}
        g1 = {}
        g2 = {}
        local g3 = {}
        local function g4()
            for k, v in g_ do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(g_)
        end
        local function g8()
            for k, v in g0 do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(g0)
        end
        local function hc()
            for k, v in g1 do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(g1)
        end
        local function hg()
            for k, v in g2 do
                if k.Parent then
                    k.HoldDuration = v[1]
                    k.MaxActivationDistance = v[2]
                    k.RequiresLineOfSight = v[3]
                end
            end
            table.clear(g2)
        end
        local function hk(hl)
            local tG = if not hl:IsA("ProximityPrompt") then 1 else 0
            if tG == 1 then
                return
            end
            if not g2[hl] then
                g2[hl] = { hl.HoldDuration, hl.MaxActivationDistance, hl.RequiresLineOfSight }
            end
            hl.HoldDuration = 0
            hl.MaxActivationDistance = 50
            hl.RequiresLineOfSight = false
        end
        local MovementGroup = wp.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", {
            Text = "WalkSpeed",
            Default = false,
            Callback = function(hp)
                if not hp then
                    g8()
                end
            end
        })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", {
            Text = "NoClip",
            Default = false,
            Callback = function(hr)
                if not hr then
                    g4()
                end
            end
        })
        MovementGroup:AddToggle("InstantProximityPrompt", {
            Text = "Instant ProximityPrompt",
            Default = false,
            Callback = function(ht)
                if ht then
                    for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                        hk(v)
                    end
                else
                    hg()
                end
            end
        })
        local FlyGroup = wp.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", {
            Text = "Fly",
            Default = false,
            Callback = function(hC)
                if not hC then
                    hc()
                end
            end
        })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        table.insert(g3, Workspace.DescendantAdded:Connect(function(hE)
            if Toggles.InstantProximityPrompt.Value then
                hk(hE)
            end
        end))
        table.insert(g3, RunService.Stepped:Connect(function()
            local Character = nT.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if g_[v] == nil then
                        g_[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(g3, UserInputService.JumpRequest:Connect(function()
            local Character = nT.Character
            local t4 = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and t4 then
                t4:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(g3, RunService.RenderStepped:Connect(function(hX)
            local Character = nT.Character
            local t7 = Character and Character:FindFirstChildOfClass("Humanoid")
            local t8 = Character
            if t8 then
                t8 = Character:FindFirstChild("HumanoidRootPart")
            end
            local t6_1 = t8
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and t7 then
                if g0[t7] == nil then
                    g0[t7] = t7.WalkSpeed
                end
                t7.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and t6_1 and t7 and CurrentCamera then
                if g1[t7] == nil then
                    g1[t7] = t7.PlatformStand
                end
                t7.PlatformStand = true
                local t8_4 = Vector3.zero
                if not UserInputService:GetFocusedTextBox() then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        t8_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        t8_4 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        t8_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        t8_4 += CurrentCamera.CFrame.RightVector
                    end
                    local ue = if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
                    if ue == 1 then
                        t8_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        t8_4 -= Vector3.new(0, 1, 0)
                    end
                end
                t6_1.AssemblyLinearVelocity = Vector3.zero
                if t8_4.Magnitude > 0 then
                    t6_1.CFrame = t6_1.CFrame + t8_4.Unit * Options.FlySpeed.Value * hX
                end
            end
        end))
        Library:OnUnload(function()
            for k, v in g3 do
                v:Disconnect()
            end
            g4()
            g8()
            hc()
            hg()
        end)
    end
    ww_6()
    local function ww_7()
        local iV
        local ij
        local Lighting = game:GetService("Lighting")
        local ii = {}
        ij = {}
        local GuiService = game:GetService("GuiService")
        local CoreGui = game:GetService("CoreGui")
        local VirtualUser = game:GetService("VirtualUser")
        local ik
        local im = 0
        local il = false
        local io = os.clock()
        local MenuGroup = wp.Settings:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        local Label = MenuGroup:AddLabel("AFK triggers: 0")
        local function is()
            local CurrentCamera = Workspace.CurrentCamera
            if not CurrentCamera then
                return
            end
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero, CurrentCamera.CFrame)
            im += 1
            io = os.clock()
            Label:SetText("AFK triggers: " .. im)
        end
        local function onAntiGameplayPause(iB)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not iB)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not iB
                end
            end)
            if iB then
                pcall(function()
                    if sethiddenproperty then
                        sethiddenproperty(nT, "GameplayPaused", false)
                    else
                        nT.GameplayPaused = false
                    end
                end)
            end
        end
        local function iM()
            for k, v in ij do
                local uw = k
                local uy = v
                if uw.Parent then
                    pcall(function()
                        uw.Enabled = uy
                    end)
                end
            end
            table.clear(ij)
            if ik then
                pcall(function()
                    settings().Rendering.QualityLevel = ik.Quality
                end)
                Lighting.GlobalShadows = ik.Shadows
                Lighting.FogEnd = ik.Fog
                ik = nil
            end
        end
        iV = { ParticleEmitter = true, Trail = true, Smoke = true, Fire = true, Sparkles = true, Beam = true }
        local function iW(iX)
            if iV[iX.ClassName] then
                if ij[iX] == nil then
                    ij[iX] = iX.Enabled
                end
                iX.Enabled = false
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true, Callback = onAntiGameplayPause })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(i_)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not i_)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(i4)
                if i4 then
                    if not ik then
                        ik = {
                            Quality = settings().Rendering.QualityLevel,
                            Shadows = Lighting.GlobalShadows,
                            Fog = Lighting.FogEnd
                        }
                    end
                    pcall(function()
                        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                    end)
                    Lighting.GlobalShadows = false
                    Lighting.FogEnd = 9000000000
                    for i, descendant in Workspace:GetDescendants() do
                        pcall(iW, descendant)
                    end
                else
                    iM()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        local ScriptGroup = wp.Settings:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        table.insert(ii, nT.Idled:Connect(function()
            if Toggles.AntiAfk.Value then
                pcall(is)
            end
        end))
        table.insert(ii, Workspace.DescendantAdded:Connect(function(jj)
            if Toggles.FpsBoost.Value then
                iW(jj)
            end
        end))
        local function jm(jn)
            if il or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            il = true
            local uQ_1 = pcall(function()
                if jn then
                    TeleportService:Teleport(game.PlaceId, nT)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, nT)
                end
            end)
            if not uQ_1 then
                il = false
                if not jn then
                    jm(true)
                end
            end
        end
        table.insert(ii, TeleportService.TeleportInitFailed:Connect(function(jA)
            if jA == nT and il then
                il = false
                task.delay(3, function()
                    jm(true)
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local uZ = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            if Library.Unloaded or not uZ then
                return
            end
            table.insert(ii, uZ.ChildAdded:Connect(function(jL)
                if jL.Name == "ErrorPrompt" then
                    jm(false)
                end
            end))
        end)
        task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    onAntiGameplayPause(true)
                end
                local u4 = Toggles.AntiAfk.Value and os.clock() - io >= 60
                if u4 then
                    pcall(is)
                end
                task.wait(1)
            end
        end)
        Library:OnUnload(function()
            for k, v in ii do
                v:Disconnect()
            end
            onAntiGameplayPause(false)
            iM()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    ww_7()
    local function ww_8()
        local wa, wb, wc, wd
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("TempoHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(wp.Settings)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/SpeedsterEscape")
        local we = SaveManager:BuildConfigSection(wp.Settings)
        wa = function(j7, j8)
            local ve = j7 == "Toggle" and Toggles
            local vj = if ve then 1 else 0
            local vh = 1793 * vj + 638 * (1 - vj)
            local vi = 2819 * vj + 318 * (1 - vj)
            if not ((vh * 2106 + vi * 989 + vh * vi) % 16777213 == 11618516) then
                ve = Options
            end
            local ve_1 = ve[j8]
            local vd_2 = type(ve_1) == "table" and ve_1.Type == j7
            return vd_2 and ve_1 or nil
        end
        wc = function(kh, ki)
            local Type = ki.Type
            if Type == "Toggle" then
                return { idx = kh, type = "Toggle", value = ki.Value == true }
            elseif Type == "Slider" then
                return { idx = kh, type = "Slider", value = tostring(ki.Value) }
            elseif Type == "Dropdown" then
                return { idx = kh, type = "Dropdown", multi = ki.Multi == true, value = ki.Value }
            elseif Type == "Input" then
                local vl = ki.Value or ""
                return { idx = kh, type = "Input", text = tostring(vl) }
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
        wb = function()
            local vo = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local vp = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if vp then
                        local vp_1 = wc(k, v)
                        if vp_1 then
                            vo[#vo + 1] = vp_1
                        end
                    end
                end
            end
            table.sort(vo, function(ks, kt)
                if ks.type ~= kt.type then
                    return ks.type < kt.type
                end
                return ks.idx < kt.idx
            end)
            return { objects = vo }
        end
        wd = function(kw)
            local vI
            vI = nil
            local vJ = type(kw) ~= "table" or type(kw.idx) ~= "string" or type(kw.type) ~= "string" or SaveManager.Ignore[kw.idx]
            if vJ then
                return false
            end
            vI = wa(kw.type, kw.idx)
            if not vI then
                return false
            end
            local vJ_1 = pcall(function()
                if kw.type == "Input" then
                    if type(kw.text) ~= "string" then
                        return
                    end
                    vI:SetValue(kw.text)
                elseif kw.type == "ColorPicker" then
                    vI:SetValueRGB(Color3.fromHex(kw.value), kw.transparency)
                elseif kw.type == "KeyPicker" then
                    vI:SetValue({ kw.key, kw.mode, kw.modifiers })
                    if kw.mode == "Toggle" and kw.toggled ~= nil then
                        vI.Toggled = kw.toggled
                        vI:Update()
                    end
                else
                    vI:SetValue(kw.value)
                end
            end)
            return vJ_1
        end
        we:AddDivider()
        we:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        we:AddButton("Export Config to Clipboard", function()
            local vP_1
            local vO_1
            vO_1, vP_1 = pcall(HttpService.JSONEncode, HttpService, wb())
            if not vO_1 then
                Library:Notify("Failed to encode the config")
                return
            end
            local vO_2 = setclipboard
            local vU = if vO_2 then 1 else 0
            local vS = 1524 * vU + 2589 * (1 - vU)
            local vT = 2605 * vU + 1957 * (1 - vU)
            if not ((vS * 1573 + vT * 4076 + vS * vT) % 16777213 == 208039) then
                vO_2 = toclipboard
            end
            local vQ = vO_2
            local vO_3 = type(vQ) ~= "function" or not pcall(vQ, vP_1)
            if vO_3 then
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Config copied to clipboard", 6)
        end)
        we:AddButton("Import Config from Clipboard Text", function()
            local vX_1
            local vV = Options.SaveManager_ImportSource.Value or ""
            local vV_1
            local vW = tostring(vV):match("^%s*(.-)%s*$")
            if vW == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            vV_1, vX_1 = pcall(HttpService.JSONDecode, HttpService, vW)
            local vW_1 = not vV_1 or type(vX_1) ~= "table"
            local v0 = if vW_1 then 1 else 0
            local vZ = 1869 * v0 + 1141 * (1 - v0)
            local v_ = 3130 * v0 + 2951 * (1 - v0)
            if not ((vZ * 2686 + v_ * 2698 + vZ * v_) % 16777213 == 2537631) then
                vW_1 = type(vX_1.objects) ~= "table"
            end
            if vW_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            local vV_2 = 0
            for i, v in ipairs(vX_1.objects) do
                if wd(v) then
                    vV_2 += 1
                end
            end
            if vV_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local vX_2 = vV_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(vV_2, vX_2), 6)
        end)
        ThemeManager:LoadDefault()
        SaveManager:LoadAutoloadConfig()
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    ww_8()
end
oc_3()
end)(...)

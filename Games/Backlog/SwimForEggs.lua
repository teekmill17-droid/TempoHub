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
getgenv().TempoHoodSubtitle = "SWIM FOR EGGS!"
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
local Aq_29
local r6
local LocalPlayer
local rO
local qO
local rv
local sc
local bodyVelocity
local qU
local Window
local si
local Training
local r_
local q_
local rH
local qH
local ro
local r5
local q5
local rN
local qN
local connection3
local sb
local CoreGui
local rT
local qT
local rA
local sh
local Workspace
local rZ
local qZ
local rG
local BaseConfig
local r4
local q4
local rM
local qM
local rt
local sa
local ra
local qS
local rz
local State
local connection4
local rY
local qY
local rF
local qF
local connection2
local r3
local q3
local qL
local rs
local r9
local q9
local rR
local EggCatalog
local HiddenAttribute
local sf
local rf
local rX
local qX
local connection5
local qE
local rl
local r2
local q2
local rK
local TrailConfig
local Ready
local SellConfig
local q8
local bodyGyro
local qQ
local rx
local se
local Attributes
local rW
local qW
local UserInputService
local PlacementConfig
local rk
local r1
local q1
local PlatformStand
local qJ
local rq
local r7
local Remotes
local rP
local qP
local VirtualUser
local PetConfig
local MinGrid
local PlayerAttributes
local qV
local connection
local qC
local rj
local r0
local q0
local qI
local GuiService
function fns.fn6()
    return not si.Unloaded
end
function fns.fn25(bf)
    local tu = os.clock() + math.max(bf, 0)
    while true do
        local tv = q5() and os.clock() < tu
        if tv then
            task.wait(0.05)
            continue
        end
        break
    end
end
function fns.fn43(lm)
    si.setAutoSteal(lm)
end
function fns.fn46(jg)
    if r3[jg] then
        return
    end
    r3[jg] = {
        HoldDuration = jg.HoldDuration,
        MaxActivationDistance = jg.MaxActivationDistance,
        RequiresLineOfSight = jg.RequiresLineOfSight
    }
end
function fns.fn48(fC)
    while true do
        local wk = q5() and State.AutoClaimIndex and sc.ClaimIndex == fC
        if wk then
            pcall(function()
                sa:InvokeServer()
            end)
            q0(3)
            continue
        end
        break
    end
end
function fns.fn70()
    local jN = pcall(function()
        local CurrentCamera = Workspace.CurrentCamera
        VirtualUser:CaptureController()
        if CurrentCamera then
            VirtualUser:ClickButton2(Vector2.new(), CurrentCamera.CFrame)
        else
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
    return jN
end
function fns.fn92(h8)
    local ye = h8 and true or false
    State.WalkSpeedEnabled = ye
    qJ()
end
function fns.fn115(g6)
    local w1_2
    while true do
        local w0 = q5() and State.AutoTreadmill and sc.Treadmill == g6
        local w0_2
        if w0 then
            local w0_1 = (rH())
            if w0_1 then
                local w1_1 = rs() or rt()
                w0_1 = w1_1
            end
            if w0_1 then
                q0(0.4)
            elseif LocalPlayer:GetAttribute(PlayerAttributes.Training) == true then
                w0_2, w1_2 = rO()
                local w0_3 = qF()
                if w1_2 and w0_3 then
                    if (w0_3.Position - w1_2.Position).Magnitude > Training.DismountDistance then
                        q8()
                    end
                end
                q0(0.75)
            else
                q8()
                q0(0.5)
            end
            continue
        end
        break
    end
end
function fns.fn128()
    return getgenv().OuroFlow
end
function fns.fn132(hz)
    local xe = hz and true or false
    State.AutoSteal = xe
    q4("Steal", State.AutoSteal, rZ)
end
function fns.fn138(hX)
    local xH = hX and true or false
    State.AutoBuyPetSlots = xH
    q4("BuySlots", State.AutoBuyPetSlots, qV)
end
function fns.fn162()
    local vB
    local vA = rR()
    if not vA then
        return nil
    end
    local vG = 1
    while true do
        if not (vG <= 48) then
            local vB_1 = BaseConfig.GetCenterPoint(vA)
            local vA_1 = vB_1 and vB_1:IsA("BasePart")
            if vA_1 then
                local vA_2 = BaseConfig.CanPlaceAt(LocalPlayer, vB_1.Position, MinGrid, true)
                if vA_2 then
                    return vB_1.Position
                end
                return nil
            end
            return nil
        end
        vB = BaseConfig.RandomPointInPetArea(vA)
        if typeof(vB) == "Vector3" then
            local vC = BaseConfig.CanPlaceAt(LocalPlayer, vB, MinGrid, true)
            if vC then
                break
            end
            vG += 1
            continue
        end
        vG += 1
    end
    return vB
end
function fns.fn191(lH)
    si.setAutoSell(lH)
end
function fns.fn204()
    local vY = {}
    local attr = LocalPlayer:GetAttribute(TrailConfig.Attributes.Owned)
    if type(attr) == "string" then
        for k in string.gmatch(attr, "[^,]+") do
            vY[k] = true
        end
    end
    return vY
end
function fns.fn208()
    local attr = LocalPlayer:GetAttribute(PlayerAttributes.BaseId)
    local tH = attr ~= ""
    local tI = type(attr) == "string" and tH
    if tI then
        return attr
    elseif type(attr) == "number" then
        return tostring(attr)
    else
        return nil
    end
end
function fns.fn209(gx)
    while true do
        local wQ = q5() and State.AutoSell and sc.Sell == gx
        if wQ then
            local wQ_1 = qN(State.SellKinds)
            local wR = qN(State.SellRarities)
            if wQ_1.Eggs then
                rM("Egg", q1(wR))
            end
            if wQ_1.Pets then
                if r1 then
                    pcall(function()
                        r1:FireServer()
                    end)
                end
                rM("Pet", qW(wR))
            end
            q0(1.25)
            continue
        end
        break
    end
end
function fns.onCharacterAdded()
    task.defer(function()
        if not q5() then
            return
        end
        qJ()
        if State.Fly then
            si.setFly(true)
        end
        if State.NoClip then
            si.setNoClip(true)
        end
    end)
end
function fns.fn244()
    for k, v in pairs(r3) do
        if k.Parent then
            k.HoldDuration = v.HoldDuration
            k.MaxActivationDistance = v.MaxActivationDistance
            k.RequiresLineOfSight = v.RequiresLineOfSight
        end
        r3[k] = nil
    end
end
function fns.fn268(hZ)
    local xQ = hZ and true
    local xU = if xQ then 1 else 0
    local xS = 1499 * xU + 1995 * (1 - xU)
    local xT = 3382 * xU + 688 * (1 - xU)
    if not ((xS * 1159 + xT * 3142 + xS * xT) % 16777213 == 655990) then
        xQ = false
    end
    State.AutoSell = xQ
    q4("Sell", State.AutoSell, qX)
end
function fns.fn270(eD)
    while true do
        local vO = q5() and State.AutoHatch and sc.Hatch == eD
        if vO then
            local vO_1 = qQ()
            if vO_1 then
                for i, child in vO_1:GetChildren() do
                    local vO_2 = q5() and State.AutoHatch and sc.Hatch == eD
                    if not vO_2 then
                        break
                    end
                    local vO_3 = child:IsA("Model") and child:GetAttribute(PlacementConfig.Attributes.Owner) == LocalPlayer.UserId and child:GetAttribute(Ready) == true
                    if vO_3 then
                        qH:FireServer(child.Name)
                        q0(0.2)
                    end
                end
            end
            q0(0.5)
            continue
        end
        break
    end
end
function fns.fn279(lL)
    si.setSellRarities(lL)
end
function fns.fn284(bR)
    local tW = qF()
    local tX = not tW or typeof(bR) ~= "CFrame"
    if tX then
        return false
    end
    tW.CFrame = bR
    return true
end
function fns.fn294(lJ)
    si.setSellKinds(lJ)
end
function fns.fn321()
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    local yT = r7()
    if yT and PlatformStand ~= nil then
        yT.PlatformStand = PlatformStand
        PlatformStand = nil
    end
end
function fns.fn345()
    local wY_1
    local wX_1
    wX_1, wY_1 = rO()
    local wX_2 = qF()
    if not (wY_1 and wX_2) then
        return false
    end
    r0(wY_1.CFrame * CFrame.new(0, 2.5, 0))
    if r2 then
        r2(wX_2, wY_1, 0)
        task.wait(0.05)
        r2(wX_2, wY_1, 1)
    end
    rW:FireServer(true)
    local wX_3 = os.clock() + 1.5
    while true do
        local wY_2 = q5() and os.clock() < wX_3
        if wY_2 then
            if LocalPlayer:GetAttribute(PlayerAttributes.Training) == true then
                return true
            end
            task.wait(0.1)
            continue
        end
        break
    end
    return LocalPlayer:GetAttribute(PlayerAttributes.Training) == true
end
function fns.fn347(cR, cS)
    local uM = rA()
    if not uM then
        return false
    end
    if type(cR) ~= "number" then
        cR = qU()
    end
    if type(cS) ~= "number" then
        cS = rX()
    end
    local uN = CFrame.new(uM)
    local uM_1 = os.clock() + 8
    while true do
        local uO = q5() and os.clock() < uM_1
        if uO then
            r0(uN)
            local uO_1 = qU()
            local uP = rX()
            if uO_1 > cR or uP > cS then
                return true
            end
            task.wait(0.05)
            continue
        end
        break
    end
    local uM_2 = qU() > cR or rX() > cS
    return uM_2
end
function fns.fn353(hH)
    local xs = hH and true or false
    State.AutoPlace = xs
    q4("Place", State.AutoPlace, qL)
end
function fns.fn354(eQ)
    while true do
        local vW = q5() and State.AutoEquipBest and sc.EquipBest == eQ
        if vW then
            qE:FireServer()
            q0(2)
            continue
        end
        break
    end
end
function fns.fn402()
    local uf = qN(State.StealZones)
    local ug = {}
    for k, v in pairs(q9) do
        if uf[k] then
            ug[v] = true
        end
    end
    return ug
end
function fns.fn403()
    local World = Workspace:FindFirstChild("World")
    local tO = World and World:FindFirstChild("Eggs")
    return tO
end
function fns.fn451(lz)
    si.setAutoClaimIndex(lz)
end
function fns.fn455(ib)
    local yk = tonumber(ib) or 32
    State.WalkSpeed = math.clamp(yk, 16, 250)
    if State.WalkSpeedEnabled then
        qJ()
    end
end
function fns.fn457()
    local uG = rR()
    if not uG then
        return nil
    end
    local uH = rj[uG]
    if uH then
        return uH
    end
    local uH_1 = BaseConfig.GetCenterPoint(uG)
    local uG_1 = uH_1 and uH_1:IsA("BasePart")
    if uG_1 then
        return (uH_1.CFrame * CFrame.new(0, 3.5, 28.25)).Position
    end
    return nil
end
function fns.fn478(lO)
    si.setAutoTreadmill(lO)
end
function fns.fn485(je)
    local y7 = (tonumber(je))
    local zb = if y7 then 1 else 0
    local y9 = 3042 * zb + 3897 * (1 - zb)
    local za = 1641 * zb + 561 * (1 - zb)
    if not ((y9 * 3194 + za * 3644 + y9 * za) % 16777213 == 3910661) then
        y7 = 60
    end
    State.FlySpeed = math.clamp(y7, 10, 400)
end
function fns.fn487(aw, ax)
    return aw.Order < ax.Order
end
function fns.fn494(h3)
    local x9 = h3 and true or false
    State.AutoUpgradeTreadmill = x9
    q4("UpgradeTreadmill", State.AutoUpgradeTreadmill, sf)
end
function fns.fn504(hn)
    while true do
        local w4 = q5() and State.AutoUpgradeTreadmill and sc.UpgradeTreadmill == hn
        if w4 then
            local w4_1 = LocalPlayer:GetAttribute(Attributes.NextPrice)
            local w5 = LocalPlayer:GetAttribute(PlayerAttributes.Cash)
            if type(w4_1) ~= "number" then
                w4_1 = 0
            end
            if type(w5) ~= "number" then
                w5 = 0
            end
            if w4_1 > 0 and w5 >= w4_1 then
                rT:FireServer()
                q0(0.85)
            else
                q0(1.5)
            end
            continue
        end
        break
    end
end
function fns.fn507(lQ)
    si.setAutoUpgradeTreadmill(lQ)
end
function fns.fn514()
    local uX_1
    local uW_1
    local uS = q3()
    local uT = qF()
    if not (uS and uT) then
        return nil
    end
    local uU_1 = r9()
    local uV = qN(State.StealRarities)
    uX_1, uW_1 = nil, nil
    for i, child in uS:GetChildren() do
        local uS_1 = child:IsA("Model") and child:GetAttribute(rN) == nil and child:GetAttribute(HiddenAttribute) ~= true
        if uS_1 then
            local uS_2 = rx(child)
            local uY = q2(child.Name)
            if uS_2 and uU_1[uS_2] and uY and uV[uY] then
                local ProximityPrompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
                if ProximityPrompt then
                    local Magnitude = (uT.Position - child:GetPivot().Position).Magnitude
                    if not uX_1 or Magnitude < uW_1 then
                        uX_1 = child
                        uW_1 = Magnitude
                    end
                end
            end
        end
    end
    return uX_1
end
function fns.fn518()
    local Group = rf:AddLeftGroupbox({ Name = "Menu", Icon = "monitor" })
    Group:CreateKeybind({
        Name = "Toggle UI",
        CurrentKeybind = "RightControl",
        Flag = "ToggleUIKey",
        Callback = function() end,
        OnChanged = function(md)
            Window:SetKeybind(md)
        end
    })
    Group:CreateDropdown({
        Name = "Toggle button",
        Options = { "Mobile only", "Mobile & PC" },
        CurrentOption = "Mobile only",
        AllowNone = false,
        Flag = "ToggleButtonPlatform",
        Callback = function(mg)
            local Ak = mg == "Mobile & PC" and "Both"
            local Ao = if Ak then 1 else 0
            local Am = 843 * Ao + 3801 * (1 - Ao)
            local An = 3623 * Ao + 431 * (1 - Ao)
            if not ((Am * 1307 + An * 3884 + Am * An) % 16777213 == 1450509) then
                Ak = "Mobile"
            end
            Window:SetToggleButtonPlatform(Ak)
        end
    })
    Group:CreateToggle({
        Name = "Anti AFK",
        CurrentValue = true,
        Flag = "AntiAfk",
        Callback = function(mi)
            si.setAntiAfk(mi)
        end
    })
    Group:CreateToggle({
        Name = "No Gameplay Paused",
        CurrentValue = true,
        Flag = "NoGameplayPaused",
        Callback = function(ml)
            si.setNoGameplayPaused(ml)
        end
    })
    Group:CreateButton({
        Name = "Unload",
        Icon = "power",
        Callback = function()
            rP:Confirm({
                Title = "Unload?",
                ConfirmText = "Unload",
                Callback = function()
                    Window:Destroy()
                end
            })
        end
    })
    rf:CreateConfigManager({ Name = "Configs", Side = "Left" })
    rf:CreateThemeManager({ Name = "Themes", Side = "Right" })
end
function fns.fn520(ej)
    local vJ, vK, vL, vM
    local vN = 12
    while true do
        local vN_1 = 12916 - vN
        do
            if vN_1 < 12902 then
                if vN_1 < 12895 then
                    if vN_1 < 12888 then
                        if vN_1 < 12885 then
                            if vN_1 < 12884 then
                                if vN_1 < 10956 then
                                    break
                                elseif vN_1 < 12802 then
                                    break
                                elseif vN_1 < 12858 then
                                    break
                                elseif vN_1 < 12883 then
                                    break
                                else
                                    vN = if vL then 2 else 18
                                end
                            else
                                vJ = vK:GetAttribute("Uid")
                                vL = rq()
                                vM = type(vJ) == "string"
                                vN = if vM then 25 else 13
                            end
                        elseif vN_1 < 12886 then
                            if vN_1 == 12885 then
                                vJ:EquipTool(vK)
                                q0(0.15)
                                vN = 32
                            else
                                vN = 12901
                                continue
                            end
                        elseif vN_1 < 12887 then
                            if vN_1 == 12886 then
                                vN = if vL then 31 else 32
                            else
                                vN = 12904
                                continue
                            end
                        else
                            vL = (q5())
                            vN = if vL then 10 else 33
                        end
                    elseif vN_1 < 12891 then
                        if vN_1 < 12890 then
                            if vN_1 < 12889 then
                                vN = 16
                            else
                                vJ = State.AutoPlace
                                vN = 17
                            end
                        else
                            vJ = r7()
                            vL = vJ
                            vN = if vL then 21 else 30
                        end
                    elseif vN_1 < 12893 then
                        if vN_1 < 12892 then
                            vM = vL
                            vN = 13
                        elseif vN_1 == 12892 then
                            vN = if vJ then 5 else 3
                        else
                            vN = 12884
                            continue
                        end
                    elseif vN_1 < 12894 then
                        if vN_1 == 12893 then
                            vJ = (q5())
                            vN = if vJ then 27 else 17
                        else
                            vN = 12904
                            continue
                        end
                    else
                        vN = 29
                    end
                elseif vN_1 < 12899 then
                    if vN_1 < 12898 then
                        if vN_1 < 12896 then
                            if vN_1 == 12895 then
                                vL = vK.Parent ~= qO()
                                vN = 30
                            else
                                vN = 1562
                                continue
                            end
                        elseif vN_1 < 12897 then
                            vN = 9
                        else
                            vN = if vK.Parent == nil then 0 else 11
                        end
                    else
                        vN = if vL then 19 else 14
                    end
                elseif vN_1 < 12900 then
                    vN = if vJ then 4 else 24
                elseif vN_1 < 12901 then
                    vN = 1
                elseif vN_1 == 12901 then
                    vN = 22
                else
                    vN = 12908
                    continue
                end
            elseif vN_1 < 12907 then
                if vN_1 < 12906 then
                    if vN_1 < 12904 then
                        if vN_1 < 12903 then
                            vN = 28
                        else
                            vN = if vM then 8 else 16
                        end
                    elseif vN_1 < 12905 then
                        if vN_1 == 12904 then
                            vN = 7
                        else
                            vN = 12895
                            continue
                        end
                    elseif vN_1 == 12905 then
                        task.wait(0.1)
                        vN = 15
                    else
                        vN = 12895
                        continue
                    end
                elseif vN_1 == 12906 then
                    vL = sc.Place == ej
                    vN = 33
                else
                    vN = 12894
                    continue
                end
            elseif vN_1 < 12915 then
                if vN_1 < 12911 then
                    if vN_1 < 12910 then
                        if vN_1 < 12909 then
                            if vN_1 < 12908 then
                                break
                            end
                            qM:FireServer(vJ, vL)
                            vJ = os.clock() + 2
                            vN = 22
                        else
                            vN = 23
                        end
                    else
                        vN = 7
                    end
                elseif vN_1 < 12913 then
                    if vN_1 < 12912 then
                        vJ = qP()
                        vK = vJ[1]
                        vN = if vK then 26 else 1
                    elseif vN_1 == 12912 then
                        vJ = sc.Place == ej
                        vN = 24
                    else
                        vN = 10834
                        continue
                    end
                elseif vN_1 < 12914 then
                    if vN_1 == 12913 then
                        vN = 20
                    else
                        vN = 12906
                        continue
                    end
                else
                    vL = os.clock() < vJ
                    vN = 18
                end
            elseif vN_1 < 14126 then
                if vN_1 < 12916 then
                    if vN_1 == 12915 then
                        q0(0.35)
                        vN = 6
                    else
                        vN = 11208
                        continue
                    end
                elseif vN_1 == 12916 then
                    vN = 28
                else
                    vN = 12858
                    continue
                end
            else
                break
            end
        end
    end
end
function fns.fn529(hD)
    local xg = type(hD) == "table" and hD
    local xi = xg or {}
    State.StealZones = xi
end
function fns.fn532(lx)
    si.setAutoEquipBest(lx)
end
function fns.fn535()
    local World = Workspace:FindFirstChild("World")
    local tU = World and World:FindFirstChild(PetConfig.WorldFolder)
    return tU
end
function fns.fn559()
    local yb = r7()
    if not yb then
        return
    end
    if State.WalkSpeedEnabled then
        if rY[yb] == nil then
            rY[yb] = yb.WalkSpeed
        end
        yb.WalkSpeed = State.WalkSpeed
    elseif rY[yb] ~= nil then
        yb.WalkSpeed = rY[yb]
        rY[yb] = nil
    end
end
local function fn565()
    local wT = ro()
    if not wT then
        return nil, nil
    end
    local wU = wT:FindFirstChild(Training.MachineName, true)
    if not wU then
        return nil, nil
    end
    local wT_1 = wU:FindFirstChild(Training.HitboxName, true)
    local wV = wT_1 and wT_1:IsA("BasePart")
    if wV then
        return wU, wT_1
    end
    return wU, nil
end
local function fn579(dy)
    if not (dy and sb) then
        return false
    end
    local ProximityPrompt = dy:FindFirstChildWhichIsA("ProximityPrompt", true)
    local va = qF()
    if not (ProximityPrompt and va) then
        return false
    end
    local HoldDuration = ProximityPrompt.HoldDuration
    local MaxActivationDistance = ProximityPrompt.MaxActivationDistance
    ProximityPrompt.HoldDuration = 0
    ProximityPrompt.MaxActivationDistance = math.max(MaxActivationDistance, 30)
    r0(CFrame.new(dy:GetPivot().Position + Vector3.new(0, 3, 0)))
    local vc = os.clock() + 1.25
    local vd = 0
    while true do
        local ve = q5() and os.clock() < vc
        if ve then
            local ve_1 = dy:GetAttribute(rN) == LocalPlayer.UserId or rs()
            if ve_1 then
                ProximityPrompt.HoldDuration = HoldDuration
                ProximityPrompt.MaxActivationDistance = MaxActivationDistance
                return true
            end
            if LocalPlayer:GetAttribute(PlayerAttributes.ZoneType) ~= "Safe" then
                local ve_2 = os.clock()
                if ve_2 - vd >= 0.05 then
                    vd = ve_2
                    pcall(sb, ProximityPrompt)
                end
            end
            task.wait()
            continue
        end
        break
    end
    ProximityPrompt.HoldDuration = HoldDuration
    ProximityPrompt.MaxActivationDistance = MaxActivationDistance
    local u9_2 = dy:GetAttribute(rN) == LocalPlayer.UserId
    local vl = if u9_2 then 1 else 0
    local vj = 1160 * vl + 3454 * (1 - vl)
    local vk = 1067 * vl + 4069 * (1 - vl)
    if not ((vj * 3796 + vk * 23 + vj * vk) % 16777213 == 5665621) then
        u9_2 = rs() ~= nil
    end
    return u9_2
end
local function fn606(e3)
    while true do
        local v4 = q5() and State.AutoBuyTrail and sc.BuyTrail == e3
        if v4 then
            local v4_1 = LocalPlayer:GetAttribute(PlayerAttributes.Cash)
            if type(v4_1) ~= "number" then
                v4_1 = 0
            end
            local v5 = qZ()
            local v6
            for i, v in ipairs(TrailConfig.Trails) do
                local Price = v.Price
                local v8 = type(Price) == "number" and Price > 0 and not v5[v.Id] and v4_1 >= Price
                if v8 then
                    if not v6 or Price < v6.Price then
                        v6 = v
                    end
                end
            end
            if v6 then
                sh:FireServer(v6.Id)
                q0(1)
            else
                q0(1.5)
            end
            continue
        end
        break
    end
end
local function fn613()
    for k in pairs(sc) do
        sc[k] += 1
    end
    State.AutoSteal = false
    State.AutoPlace = false
    State.AutoHatch = false
    State.AutoEquipBest = false
    State.AutoBuyTrail = false
    State.AutoBuyPetSlots = false
    State.AutoClaimIndex = false
    State.AutoSell = false
    State.AutoTreadmill = false
    State.AutoUpgradeTreadmill = false
    State.WalkSpeedEnabled = false
    State.InfJump = false
    State.NoClip = false
    State.Fly = false
    State.InstantPrompt = false
    State.AntiAfk = false
    State.NoGameplayPaused = false
    if LocalPlayer:GetAttribute(PlayerAttributes.Training) == true then
        pcall(function()
            rW:FireServer(false)
        end)
    end
    qT()
    qS()
    rl()
    qJ()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    if connection3 then
        connection3:Disconnect()
        connection3 = nil
    end
    if connection2 then
        connection2:Disconnect()
        connection2 = nil
    end
    if connection4 then
        connection4:Disconnect()
        connection4 = nil
    end
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(true)
    end)
end
local function fn616()
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(false)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = false
        end
    end)
    pcall(function()
        if ra then
            ra(LocalPlayer, "GameplayPaused", false)
        else
            LocalPlayer.GameplayPaused = false
        end
    end)
    pcall(function()
        local RobloxGui = CoreGui:FindFirstChild("RobloxGui")
        local zP = RobloxGui and RobloxGui:FindFirstChild("Notifications")
        if not zP then
            return
        end
        for i, descendant in zP:GetDescendants() do
            local zO_2 = descendant:IsA("TextLabel") and string.find(string.lower(descendant.Text), "gameplay paused", 1, true)
            if zO_2 then
                local Frame = descendant:FindFirstAncestorOfClass("Frame")
                if Frame then
                    Frame.Visible = false
                end
            end
        end
    end)
end
local function fn638(bW)
    local attr = bW:GetAttribute(rF)
    local tZ_2
    if type(attr) == "string" then
        local t_ = string.match(attr, "^(Area%d+)")
        if t_ then
            return t_
        end
        local tZ_1 = EggCatalog.AreaIdFor(bW.Name)
        if type(tZ_2) == "string" then
            return tZ_1
        end
        return nil
    end
    tZ_2 = EggCatalog.AreaIdFor(bW.Name)
    if type(tZ_2) == "string" then
        return tZ_2
    end
    return nil
end
local function fn647(h0)
    local xZ = type(h0) == "table" and h0
    local x0 = xZ or {}
    State.SellRarities = x0
end
local function fn655()
    return LocalPlayer.Character
end
local function fn663()
    local tA = qO()
    local tB = tA and tA:FindFirstChild("HumanoidRootPart")
    return tB
end
local function fn671(lo)
    si.setStealZones(lo)
end
local function fn701(ig)
    local yv = ig and true or false
    State.InfJump = yv
    if connection then
        connection:Disconnect()
        connection = nil
    end
    if not State.InfJump then
        return
    end
    connection = UserInputService.JumpRequest:Connect(function()
        local yp = q5() and State.InfJump
        if not yp then
            return
        end
        local yp_1 = r7()
        if yp_1 then
            yp_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end
local function fn709()
    connection5:Disconnect()
end
local function fn732(h1)
    local x6 = h1 and true or false
    State.AutoTreadmill = x6
    q4("Treadmill", State.AutoTreadmill, r5)
    local x5_1 = not State.AutoTreadmill and LocalPlayer:GetAttribute(PlayerAttributes.Training) == true
    if x5_1 then
        rW:FireServer(false)
    end
end
local function onDestroying()
    task.defer(si.Unload)
end
local function fn776(fn)
    while true do
        local wg = q5() and State.AutoBuyPetSlots and sc.BuySlots == fn
        if wg then
            local wg_1 = LocalPlayer:GetAttribute(PlayerAttributes.BaseUpgradeLevel)
            if type(wg_1) ~= "number" then
                wg_1 = 0
            end
            local wh = BaseConfig.NextTier(wg_1)
            local wg_2 = LocalPlayer:GetAttribute(PlayerAttributes.Cash)
            if type(wg_2) ~= "number" then
                wg_2 = 0
            end
            local wi = wh and type(wh.Cost) == "number" and wh.Cost > 0 and wg_2 >= wh.Cost
            if wi then
                se:FireServer()
                q0(0.75)
            else
                q0(1.5)
            end
            continue
        end
        break
    end
end
local function fn779(hY)
    local xK = hY and true or false
    State.AutoClaimIndex = xK
    q4("ClaimIndex", State.AutoClaimIndex, rK)
end
local function fn797(dK)
    while true do
        local vm = q5() and State.AutoSteal and sc.Steal == dK
        if vm then
            if rs() then
                q_(qU(), rX())
            else
                local vm_1 = rt()
                if vm_1 then
                    local vn = qU()
                    local vo = rX()
                    if rv(vm_1) then
                        q_(vn, vo)
                    else
                        task.wait()
                    end
                else
                    q0(0.15)
                end
            end
            continue
        end
        break
    end
end
local function fn811()
    local Group2 = rk:AddLeftGroupbox({ Name = "Movement", Icon = "move" })
    Group2:CreateToggle({
        Name = "WalkSpeed",
        CurrentValue = false,
        Flag = "WalkSpeedEnabled",
        Callback = function(lV)
            si.setWalkSpeedEnabled(lV)
        end
    })
    Group2:CreateSlider({
        Name = "Speed",
        Range = { 16, 250 },
        Increment = 1,
        CurrentValue = 32,
        Flag = "WalkSpeed",
        Callback = function(lY)
            si.setWalkSpeed(lY)
        end
    })
    Group2:CreateToggle({
        Name = "Infinite Jump",
        CurrentValue = false,
        Flag = "InfJump",
        Callback = function(l_)
            si.setInfJump(l_)
        end
    })
    Group2:CreateToggle({
        Name = "Noclip",
        CurrentValue = false,
        Flag = "NoClip",
        Callback = function(l1)
            si.setNoClip(l1)
        end
    })
    Group2:CreateToggle({
        Name = "Instant ProximityPrompt",
        CurrentValue = false,
        Flag = "InstantPrompt",
        Callback = function(l3)
            si.setInstantPrompt(l3)
        end
    })
    local Group = rk:AddRightGroupbox({ Name = "Flight", Icon = "plane" })
    Group:CreateToggle({
        Name = "Fly",
        CurrentValue = false,
        Flag = "Fly",
        Callback = function(l6)
            si.setFly(l6)
        end
    })
    Group:CreateSlider({
        Name = "Fly Speed",
        Range = { 10, 400 },
        Increment = 1,
        CurrentValue = 60,
        Flag = "FlySpeed",
        Callback = function(l8)
            si.setFlySpeed(l8)
        end
    })
end
local function fn826(hT)
    local xB = hT and true
    local xF = if xB then 1 else 0
    local xD = 2247 * xF + 1163 * (1 - xF)
    local xE = 2785 * xF + 316 * (1 - xF)
    if not ((xD * 3461 + xE * 3343 + xD * xE) % 16777213 == 6567804) then
        xB = false
    end
    State.AutoBuyTrail = xB
    q4("BuyTrail", State.AutoBuyTrail, qI)
end
local function fn835(hL)
    local xv = hL and true or false
    State.AutoHatch = xv
    q4("Hatch", State.AutoHatch, qY)
end
local function fn852(hP)
    local xy = hP and true or false
    State.AutoEquipBest = xy
    q4("EquipBest", State.AutoEquipBest, rz)
end
local function fn864(b2)
    local t1 = b2 == ""
    local t2 = type(b2) ~= "string" or t1
    if t2 then
        return nil
    end
    local t1_1 = EggCatalog.RarityOf(b2)
    local t2_1 = type(t1_1) == "string" and rG[t1_1]
    if t2_1 then
        return t1_1
    end
    return nil
end
local function fn867(lq)
    si.setStealRarities(lq)
end
local function fn878(h_)
    local xV = type(h_) == "table" and h_
    local xX = xV or {}
    State.SellKinds = xX
end
local function fn880()
    local attr = LocalPlayer:GetAttribute(PlayerAttributes.EggCount)
    if type(attr) == "number" then
        return attr
    end
    return 0
end
local function fn888(hF)
    local xn = type(hF) == "table" and hF
    local xp = xn or {}
    State.StealRarities = xp
end
local function fn898(gn, go)
    if #go == 0 then
        return
    end
    local wI = SellConfig.Rules.MaxPerRequest or 256
    local wI_1 = #go
    local wN = 1
    while wI > 0 and wN <= wI_1 or wI <= 0 and wN >= wI_1 do
        local wO = wN
        if not q5() then
            return
        end
        local wI_2 = table.move(go, wO, math.min(wO + wI - 1, #go), 1, {})
        r4:FireServer(gn, wI_2)
        q0(0.35)
        wN += wI
    end
end
local function fn909(f8)
    local wx = {}
    local wy = qC()
    if not wy then
        return wx
    end
    for i, child in wy:GetChildren() do
        local wy_1 = child:IsA("Model") and child:GetAttribute(PetConfig.Attributes.Owner) == LocalPlayer.UserId
        if wy_1 then
            local attr2 = child:GetAttribute(PetConfig.Attributes.Uid)
            local attr = child:GetAttribute(PetConfig.Attributes.EggId)
            local wA = q2(attr)
            local wz_1 = type(attr2) == "string" and wA and f8[wA]
            if wz_1 then
                table.insert(wx, attr2)
            end
        end
    end
    return wx
end
local function fn913()
    local World = Workspace:FindFirstChild("World")
    local tR = World and World:FindFirstChild(PlacementConfig.WorldFolder)
    return tR
end
local function fn970(lv)
    si.setAutoHatch(lv)
end
local function fn979(lE)
    si.setAutoBuyPetSlots(lE)
end
local function fn993()
    for k, v in pairs(r6) do
        if k.Parent then
            k.CanCollide = v
        end
        r6[k] = nil
    end
end
local function fn996()
    local uo = q3()
    if not uo then
        return nil
    end
    for i, child in uo:GetChildren() do
        local uo_1 = child:IsA("Model") and child:GetAttribute(rN) == LocalPlayer.UserId
        if uo_1 then
            return child
        end
    end
    return nil
end
local function fn1016()
    return State.AutoSteal == true
end
local function fn1021()
    local tD = qO()
    local tE = tD and tD:FindFirstChildOfClass("Humanoid")
    return tE
end
local function fn1037(S, T, U)
    local s7 = U or 10
    local s8 = Remotes:WaitForChild(S, s7)
    local s7_1 = s8 and s8:IsA(T)
    if s7_1 then
        return s8
    end
    return nil
end
local function fn1057(lC)
    si.setAutoBuyTrail(lC)
end
local function fn1060()
    local tK = rR()
    local tL = tK and BaseConfig.ResolveBase(tK)
    return tL or nil
end
local function fn1100(lt)
    si.setAutoPlace(lt)
end
local function fn1103(b8)
    local t7 = {}
    if type(b8) == "string" then
        if b8 ~= "" then
            t7[b8] = true
        end
        return t7
    elseif type(b8) ~= "table" then
        return t7
    else
        for i, v in ipairs(b8) do
            if type(v) == "string" then
                t7[v] = true
            end
        end
        return t7
    end
end
local function fn1106(hu, hv, hw)
    sc[hu] += 1
    local w8 = sc[hu]
    if hv then
        task.spawn(hw, w8)
    end
end
qC = nil
PlacementConfig = nil
qE = nil
qF = nil
BaseConfig = nil
qH = nil
qI = nil
qJ = nil
TrailConfig = nil
qL = nil
qM = nil
qN = nil
qO = nil
qP = nil
qQ = nil
EggCatalog = nil
qS = nil
qT = nil
qU = nil
qV = nil
qW = nil
qX = nil
qY = nil
qZ = nil
q_ = nil
q0 = nil
q1 = nil
q2 = nil
q3 = nil
q4 = nil
q5 = nil
LocalPlayer = nil
Remotes = nil
q8 = nil
q9 = nil
ra = nil
CoreGui = nil
MinGrid = nil
Attributes = nil
rf = nil
connection4 = nil
Workspace = nil
Training = nil
rj = nil
rk = nil
rl = nil
connection2 = nil
ro = nil
local rc, rn
GuiService = nil
rq = nil
Ready = nil
rs = nil
rt = nil
connection3 = nil
rv = nil
VirtualUser = nil
rx = nil
HiddenAttribute = nil
rz = nil
rA = nil
Window = nil
connection = nil
UserInputService = nil
connection5 = nil
rF = nil
rG = nil
rH = nil
PlatformStand = nil
rK = nil
rM = nil
rN = nil
rO = nil
rP = nil
bodyGyro = nil
rR = nil
rT = nil
bodyVelocity = nil
PlayerAttributes = nil
rW = nil
rX = nil
rY = nil
rZ = nil
r_ = nil
r0 = nil
r1 = nil
r2 = nil
r3 = nil
r4 = nil
r5 = nil
r6 = nil
r7 = nil
SellConfig = nil
r9 = nil
sa = nil
sb = nil
local rI, RunService, Egg
sc = nil
PetConfig = nil
se = nil
sf = nil
State = nil
sh = nil
si = nil
if not game:IsLoaded() then
    game.Loaded:Wait()
end
r_, RunService, UserInputService, VirtualUser, GuiService, Workspace, CoreGui, LocalPlayer, Aq_29, EggCatalog, TrailConfig, BaseConfig, PlacementConfig, PetConfig, SellConfig, PlayerAttributes, Egg, rN, rF, HiddenAttribute, Ready, Training, Attributes, MinGrid, Remotes, qM, qH, qE, sh, se, sa, r4, r1, rW, rT = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Aq_14 = "v0.7"
local Aq_6 = "Swim For Eggs"
local Aq_26 = "https://discord.gg/K7Qxnxkk46"
local Aq_5 = "https://tempohub.shop"
r_ = ""
local Aq_25 = "TempoSwimForEggs"
local Aq_34 = game:GetService("Players")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
GuiService = game:GetService("GuiService")
Workspace = game:GetService("Workspace")
local Aq_10 = game:GetService("ReplicatedStorage")
CoreGui = game:GetService("CoreGui")
LocalPlayer = Aq_34.LocalPlayer
assert(LocalPlayer, "LocalPlayer missing")
local Aq_31 = Aq_10:WaitForChild("Shared", 15)
assert(Aq_31, "Shared missing")
local Aq_9 = Aq_31:WaitForChild("Config", 15)
assert(Aq_9, "Config missing")
local Aq_18 = require(Aq_9:WaitForChild("GameConfig"))
if (r1 or not r1) and (not r1 and not RunService) and (not RunService and not qE or (not RunService or not RunService)) or not ((r1 or not r1) and (not r1 and not RunService) and (not RunService and not qE or (not RunService or not RunService))) then
    Aq_29 = require(Aq_9:WaitForChild("EggConfig"))
else
    Aq_9 = require(Aq_29:WaitForChild("EggConfig"))
end
EggCatalog = require(Aq_9:WaitForChild("EggCatalog"))
local AreaConfig = require(Aq_9:WaitForChild("AreaConfig"))
local Aq_12 = require(Aq_9:WaitForChild("RarityConfig"))
TrailConfig = require(Aq_9:WaitForChild("TrailConfig"))
BaseConfig = require(Aq_9:WaitForChild("BaseConfig"))
if (false or not qH or (false or not qH)) and (not qH and not qH or "Swim For Eggs") or not ((false or not qH or (false or not qH)) and (not qH and not qH or "Swim For Eggs")) then
    PlacementConfig = require(Aq_9:WaitForChild("PlacementConfig"))
else
    Aq_9 = require(PlacementConfig:WaitForChild("PlacementConfig"))
end
local SpeedConfig = require(Aq_9:WaitForChild("SpeedConfig"))
PetConfig = require(Aq_9:WaitForChild("PetConfig"))
SellConfig = require(Aq_9:WaitForChild("SellConfig"))
local Aq_11 = require(Aq_9:WaitForChild("HatchConfig"))
local Aq_23 = require(Aq_9:WaitForChild("IndexConfig"))
PlayerAttributes = Aq_18.PlayerAttributes
Egg = Aq_18.ItemTypes.Egg
if (not qH and not qH and false or (false or not qH) and (Aq_26 and not qH)) and (false or not qH or "https://discord.gg/K7Qxnxkk46" or (not qH and false or (false or qH))) and not ((not qH and not qH and false or (false or not qH) and (Aq_26 and not qH)) and (false or not qH or "https://discord.gg/K7Qxnxkk46" or (not qH and false or (false or qH)))) then
    rN = Ready.NestKeyAttribute
    rF = Ready.FirstEgg.HiddenAttribute
    Aq_11 = HiddenAttribute.Attributes.Ready
else
    rN = Aq_29.CarriedByAttribute
    rF = Aq_29.NestKeyAttribute
    HiddenAttribute = Aq_29.FirstEgg.HiddenAttribute
    Ready = Aq_11.Attributes.Ready
end
Training = SpeedConfig.Training
Attributes = Training.Attributes
MinGrid = PlacementConfig.Footprint.MinGrid
Remotes = Aq_10:WaitForChild("Remotes", 15)
assert(Remotes, "Remotes missing")
local Aq_21 = fn1037
qM = Aq_21(PlacementConfig.RemoteName, "RemoteEvent")
qH = Aq_21(Aq_11.HatchRemoteName, "RemoteEvent")
qE = Aq_21(PetConfig.Equip.BestRemoteName, "RemoteEvent")
sh = Aq_21(TrailConfig.RemoteName, "RemoteEvent")
se = Aq_21(BaseConfig.Upgrade.RemoteName, "RemoteEvent")
sa = Aq_21(Aq_23.ClaimAllRemoteName, "RemoteFunction")
r4 = Aq_21(SellConfig.RemoteName, "RemoteEvent")
r1 = Aq_21(PetConfig.Equip.PushRemoteName, "RemoteEvent")
rW = Aq_21(Training.RemoteName, "RemoteEvent")
rT = Aq_21(Training.UpgradeRemoteName, "RemoteEvent")
Aq_29 = qM and qH
Aq_18 = Aq_29 and qE
Aq_29 = Aq_18 and sh
Aq_18 = Aq_29 and se
assert(Aq_18, "core remotes missing")
Aq_29 = sa and r4
Aq_18 = Aq_29 and rW
Aq_29 = Aq_18 and rT
rG = nil
assert(Aq_29, "secondary remotes missing")
Aq_9 = table.clone(Aq_12.Order)
rG = {}
for i, v in ipairs(Aq_9) do
    rG[v] = i
end
rj, q9 = nil, nil
rj = {
    ["1"] = Vector3.new(-420.739990234375, 6.980000019073486, -90.29000091552734),
    ["2"] = Vector3.new(-420.2807312011719, 6.977315425872803, 21.493724822998047),
    ["3"] = Vector3.new(-482.9465637207031, 6.977315425872803, -90.242919921875),
    ["4"] = Vector3.new(-483.0702209472656, 6.977315425872803, 21.542438507080078),
    ["5"] = Vector3.new(-545.7360229492188, 6.977315425872803, -90.19419860839844),
    ["6"] = Vector3.new(-545.28076171875, 6.977315425872803, 21.590696334838867)
}
Aq_18 = { "Area1", "Area2", "Area3", "Area4", "Area5", "Area6", "Area7", "Area8" }
Aq_31 = {}
q9 = {}
Aq_21 = {}
for i, v in ipairs(Aq_18) do
    Aq_21[v] = true
end
Aq_29 = {}
for k, v in AreaConfig.Areas do
    if Aq_21[k] then
        Aq_18 = table.insert
        Aq_10 = v.Order or 0
        Aq_34 = v.Banner and v.Banner.DisplayName
        Aq_23 = Aq_34 or k
        Aq_18(Aq_29, { Id = k, Order = Aq_10, Label = Aq_23 })
    end
end
table.sort(Aq_29, fns.fn487)
for i, v in ipairs(Aq_29) do
    table.insert(Aq_31, v.Label)
    q9[v.Label] = v.Id
end
Aq_18 = typeof(fireproximityprompt) == "function" and fireproximityprompt
Aq_29 = Aq_18 or nil
sb, Aq_21 = nil, nil
if ((Aq_21 or 4) and (not sb or 4 or not sb) or (not sb or 4) and (not sb and not sb) and (not sb or false or not sb)) and (Aq_21 and (not Aq_21 or false) or (sb and Aq_21 or sb and sb) or sb and not sb and (not sb or sb) and (sb and sb or Aq_21 and not Aq_21)) and not (((Aq_21 or 4) and (not sb or 4 or not sb) or (not sb or 4) and (not sb and not sb) and (not sb or false or not sb)) and (Aq_21 and (not Aq_21 or false) or (sb and Aq_21 or sb and sb) or sb and not sb and (not sb or sb) and (sb and sb or Aq_21 and not Aq_21))) then
else
    sb = Aq_29
end
Aq_21 = typeof(firetouchinterest) == "function" and firetouchinterest
Aq_29 = Aq_21 or nil
r2, si, State, sc, r6, r3, rY, bodyVelocity, bodyGyro, PlatformStand, connection, connection3, connection2, connection4, Aq_10 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
r2 = Aq_29
Aq_18 = function(aF)
    local tp
    local tn
    local to
    tn = nil
    to = nil
    tp = nil
    local ts_1
    assert(type(getgenv) == "function", "getgenv unavailable")
    to = getgenv()
    local tq = to[aF]
    local tr = type(tq) == "table" and type(tq.Unload) == "function"
    local tr_1
    if tr then
        tr_1, ts_1 = pcall(tq.Unload)
        if not tr_1 then
            warn("Previous cleanup: " .. tostring(ts_1))
        end
    end
    tp = {}
    tn = { State = {}, Unloaded = false }
    tn.Track = function(aN)
        if tn.Unloaded then
            pcall(aN)
        else
            table.insert(tp, aN)
        end
        return aN
    end
    tn.Unload = function()
        local tg_1
        local tf_1
        if tn.Unloaded then
            return
        end
        tn.Unloaded = true
        local tk = #tp
        local tj = -1
        while false and tk <= 1 or true and tk >= 1 do
            local tl = tk
            local te_1 = table.remove(tp, tl)
            tf_1, tg_1 = pcall(te_1)
            if not tf_1 then
                warn("Cleanup: " .. tostring(tg_1))
            end
            tk += tj
        end
        table.clear(tn.State)
        if to[aF] == tn then
            to[aF] = nil
        end
    end
    to[aF] = tn
    return tn
end
si = Aq_18(Aq_25)
State = si.State
State.AutoSteal = false
State.StealZones = table.clone(Aq_31)
State.StealRarities = table.clone(Aq_9)
State.AutoPlace = false
State.AutoHatch = false
State.AutoEquipBest = false
State.AutoBuyTrail = false
State.AutoBuyPetSlots = false
State.AutoClaimIndex = false
State.AutoSell = false
State.SellKinds = { "Eggs", "Pets" }
State.SellRarities = table.clone(Aq_9)
State.AutoTreadmill = false
State.AutoUpgradeTreadmill = false
State.WalkSpeedEnabled = false
State.WalkSpeed = 32
State.InfJump = false
State.NoClip = false
State.Fly = false
State.FlySpeed = 60
State.InstantPrompt = false
State.AntiAfk = true
State.NoGameplayPaused = true
sc = {
    Steal = 0,
    Place = 0,
    Hatch = 0,
    EquipBest = 0,
    BuyTrail = 0,
    BuySlots = 0,
    ClaimIndex = 0,
    Sell = 0,
    Treadmill = 0,
    UpgradeTreadmill = 0,
    WalkSpeed = 0,
    NoClip = 0,
    Fly = 0,
    InstantPrompt = 0,
    AntiAfk = 0,
    NoGameplayPaused = 0
}
r6 = {}
r3 = {}
rY = {}
bodyVelocity = nil
bodyGyro = nil
PlatformStand = nil
connection = nil
connection3 = nil
if ((not r6 or r6) and (r6 and not r6) and (not Aq_18 and r6 and (Aq_18 and not r6)) or (not r6 or not r6 or not r6 and r6 or (not Aq_18 and not r6 or Aq_18 and Aq_18))) and not ((not r6 or r6) and (r6 and not r6) and (not Aq_18 and r6 and (Aq_18 and not r6)) or (not r6 or not r6 or not r6 and r6 or (not Aq_18 and not r6 or Aq_18 and Aq_18))) then
    sc = nil
else
    connection2 = nil
end
connection4 = nil
if (not bodyVelocity or not connection3) and (bodyVelocity or bodyVelocity) and (bodyVelocity and not connection3 or not bodyVelocity and connection3) and ((not connection3 and not connection2 or (connection2 or not bodyVelocity)) and (connection2 or not bodyVelocity or bodyVelocity and not connection3)) and not ((not bodyVelocity or not connection3) and (bodyVelocity or bodyVelocity) and (bodyVelocity and not connection3 or not bodyVelocity and connection3) and ((not connection3 and not connection2 or (connection2 or not bodyVelocity)) and (connection2 or not bodyVelocity or bodyVelocity and not connection3))) then
    sc = typeof(sethiddenproperty) == "function"
else
    Aq_10 = typeof(sethiddenproperty) == "function"
end
if Aq_10 then
    Aq_10 = sethiddenproperty
end
Aq_29 = Aq_10
local sK = if Aq_29 then 1 else 0
local Aq_33 = 2108 * sK + 3872 * (1 - sK)
local Aq_22 = 187 * sK + 1476 * (1 - sK)
if not ((Aq_33 * 4048 + Aq_22 * 1497 + Aq_33 * Aq_22) % 16777213 == 9207319) then
    Aq_29 = nil
end
ra, rP, Aq_10, q5, q0, qO, qF, r7, rR, ro, q3, qQ, qC, r0, rx, q2, qN, r9, rs, qU, rX, rA, q_, rH, rt, rv, rZ, qP, rq, qL, qY, rz, qZ, qI, qV, rK, q1, qW, rM, qX, rO, q8, r5, sf, q4, qJ, qS, qT, rI, rl, rn, rc = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
ra = Aq_29
q5 = fns.fn6
q0 = fns.fn25
qO = fn655
qF = fn663
r7 = fn1021
rR = fns.fn208
ro = fn1060
if (not Aq_10 or qZ) and (qZ and not q5) and (not q5 and Aq_10 and (q5 and not q5)) or ((not r9 or r9) and (Aq_10 or not r9) or (not rX and q5 or (q5 or Aq_10))) or not ((not Aq_10 or qZ) and (qZ and not q5) and (not q5 and Aq_10 and (q5 and not q5)) or ((not r9 or r9) and (Aq_10 or not r9) or (not rX and q5 or (q5 or Aq_10)))) then
    q3 = fns.fn403
    qQ = fn913
else
    qQ = fns.fn403
    q3 = fn913
end
qC = fns.fn535
r0 = fns.fn284
rx = fn638
q2 = fn864
qN = fn1103
r9 = fns.fn402
rs = fn996
qU = function()
    local ct = 0
    local function cu(cv)
        if not cv then
            return
        end
        for i, child in cv:GetChildren() do
            local uw = child:IsA("Tool") and child:GetAttribute("ItemType") == Egg
            if uw then
                ct += 1
            end
        end
    end
    cu(LocalPlayer:FindFirstChildOfClass("Backpack"))
    cu(qO())
    return ct
end
rX = fn880
rA = fns.fn457
q_ = fns.fn347
rH = fn1016
rt = fns.fn514
rv = fn579
rZ = fn797
qP = function()
    local dT = {}
    local function dU(dV)
        if not dV then
            return
        end
        for i, child in dV:GetChildren() do
            local vq = child:IsA("Tool") and child:GetAttribute("ItemType") == Egg
            if vq then
                local attr2 = child:GetAttribute("Uid")
                local attr = child:GetAttribute("Id")
                local vs = type(attr2) == "string" and type(attr) == "string"
                if vs then
                    table.insert(dT, child)
                end
            end
        end
    end
    dU(LocalPlayer:FindFirstChildOfClass("Backpack"))
    dU(qO())
    return dT
end
rq = fns.fn162
qL = fns.fn520
qY = fns.fn270
rz = fns.fn354
qZ = fns.fn204
qI = fn606
qV = fn776
rK = fns.fn48
q1 = function(fL)
    local fM = {}
    local function fN(fO)
        if not fO then
            return
        end
        for i, child in fO:GetChildren() do
            local wm = child:IsA("Tool") and child:GetAttribute("ItemType") == Egg
            if wm then
                local attr2 = child:GetAttribute("Uid")
                local attr = child:GetAttribute("Id")
                local wo = q2(attr)
                local wp = type(attr2) == "string" and wo and fL[wo]
                if wp then
                    local wo_1 = SellConfig.Rules.AllowPaidEggs or not EggCatalog.PaidEggOf(attr)
                    wp = wo_1
                end
                if wp then
                    table.insert(fM, attr2)
                end
            end
        end
    end
    fN(LocalPlayer:FindFirstChildOfClass("Backpack"))
    fN(qO())
    return fM
end
qW = fn909
rM = fn898
qX = fns.fn209
rO = fn565
q8 = fns.fn345
r5 = fns.fn115
sf = fns.fn504
q4 = fn1106
si.setAutoSteal = fns.fn132
si.setStealZones = fns.fn529
si.setStealRarities = fn888
si.setAutoPlace = fns.fn353
si.setAutoHatch = fn835
si.setAutoEquipBest = fn852
si.setAutoBuyTrail = fn826
si.setAutoBuyPetSlots = fns.fn138
si.setAutoClaimIndex = fn779
si.setAutoSell = fns.fn268
si.setSellKinds = fn878
si.setSellRarities = fn647
si.setAutoTreadmill = fn732
si.setAutoUpgradeTreadmill = fns.fn494
qJ = fns.fn559
si.setWalkSpeedEnabled = fns.fn92
si.setWalkSpeed = fns.fn455
si.setInfJump = fn701
qS = fn993
si.setNoClip = function(iw)
    local NoClip
    local yR = iw and true or false
    State.NoClip = yR
    sc.NoClip = sc.NoClip + 1
    NoClip = sc.NoClip
    if not State.NoClip then
        qS()
        return
    end
    task.spawn(function()
        while true do
            local yH = q5() and State.NoClip and sc.NoClip == NoClip
            if yH then
                local yH_1 = qO()
                if yH_1 then
                    for i, descendant in yH_1:GetDescendants() do
                        if descendant:IsA("BasePart") then
                            if r6[descendant] == nil then
                                r6[descendant] = descendant.CanCollide
                            end
                            descendant.CanCollide = false
                        end
                    end
                end
                RunService.Stepped:Wait()
                continue
            end
            break
        end
        qS()
    end)
end
qT = fns.fn321
si.setFly = function(iX)
    local Fly
    local y4 = iX and true or false
    State.Fly = y4
    sc.Fly = sc.Fly + 1
    Fly = sc.Fly
    qT()
    if not State.Fly then
        return
    end
    task.spawn(function()
        while true do
            local yX = q5() and State.Fly and sc.Fly == Fly
            if yX then
                local yX_1 = qF()
                local yY = r7()
                local CurrentCamera = Workspace.CurrentCamera
                if yX_1 and yY and CurrentCamera then
                    if not bodyVelocity or bodyVelocity.Parent ~= yX_1 then
                        qT()
                        PlatformStand = yY.PlatformStand
                        yY.PlatformStand = true
                        bodyVelocity = Instance.new("BodyVelocity")
                        bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
                        bodyVelocity.Velocity = Vector3.zero
                        bodyVelocity.Parent = yX_1
                        bodyGyro = Instance.new("BodyGyro")
                        bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
                        bodyGyro.P = 10000
                        bodyGyro.Parent = yX_1
                    end
                    bodyGyro.CFrame = CurrentCamera.CFrame
                    local yX_2 = Vector3.zero
                    if not UserInputService:GetFocusedTextBox() then
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            yX_2 += CurrentCamera.CFrame.LookVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            yX_2 -= CurrentCamera.CFrame.LookVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                            yX_2 -= CurrentCamera.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                            yX_2 += CurrentCamera.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            yX_2 += Vector3.yAxis
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                            yX_2 -= Vector3.yAxis
                        end
                    end
                    if yX_2.Magnitude > 0 then
                        bodyVelocity.Velocity = yX_2.Unit * State.FlySpeed
                    else
                        bodyVelocity.Velocity = Vector3.zero
                    end
                end
                task.wait()
                continue
            end
            break
        end
        qT()
    end)
end
si.setFlySpeed = fns.fn485
rI = fns.fn46
rl = fns.fn244
si.setInstantPrompt = function(jm)
    local InstantPrompt, zo
    local zq = jm and true or false
    State.InstantPrompt = zq
    sc.InstantPrompt = sc.InstantPrompt + 1
    InstantPrompt = sc.InstantPrompt
    if connection2 then
        connection2:Disconnect()
        connection2 = nil
    end
    if not State.InstantPrompt then
        rl()
        return
    end
    zo = function(jt)
        if jt:IsA("ProximityPrompt") then
            rI(jt)
            jt.HoldDuration = 0
            jt.MaxActivationDistance = 50
            jt.RequiresLineOfSight = false
        end
    end
    for i, descendant in Workspace:GetDescendants() do
        zo(descendant)
    end
    connection2 = Workspace.DescendantAdded:Connect(function(jz)
        local zl = q5() and State.InstantPrompt and sc.InstantPrompt == InstantPrompt
        if zl then
            zo(jz)
        end
    end)
end
rn = fns.fn70
si.setAntiAfk = function(jO)
    local AntiAfk
    local zJ = jO and true or false
    State.AntiAfk = zJ
    sc.AntiAfk = sc.AntiAfk + 1
    AntiAfk = sc.AntiAfk
    if connection3 then
        connection3:Disconnect()
        connection3 = nil
    end
    if not State.AntiAfk then
        return
    end
    connection3 = LocalPlayer.Idled:Connect(function()
        local zA = q5() and State.AntiAfk
        if zA then
            rn()
        end
    end)
    task.spawn(function()
        while true do
            local zC = q5() and State.AntiAfk and sc.AntiAfk == AntiAfk
            if zC then
                q0(60)
                local zC_1 = q5() and State.AntiAfk and sc.AntiAfk == AntiAfk
                if zC_1 then
                    rn()
                end
                continue
            end
            break
        end
    end)
end
rc = fn616
si.setNoGameplayPaused = function(kq)
    local NoGameplayPaused
    local z5 = kq and true or false
    State.NoGameplayPaused = z5
    sc.NoGameplayPaused = sc.NoGameplayPaused + 1
    NoGameplayPaused = sc.NoGameplayPaused
    if connection4 then
        connection4:Disconnect()
        connection4 = nil
    end
    if not State.NoGameplayPaused then
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(true)
        end)
        return
    end
    rc()
    connection4 = CoreGui.DescendantAdded:Connect(function()
        local zX = q5() and State.NoGameplayPaused and sc.NoGameplayPaused == NoGameplayPaused
        if zX then
            rc()
        end
    end)
    task.spawn(function()
        while true do
            local z1 = q5() and State.NoGameplayPaused and sc.NoGameplayPaused == NoGameplayPaused
            if z1 then
                rc()
                q0(1)
                continue
            end
            break
        end
    end)
end
si.Track(fn613)
LocalPlayer.CharacterAdded:Connect(fns.onCharacterAdded)
Aq_18, rP = pcall(fns.fn128)
Aq_10 = not Aq_18
if not Aq_10 then
    Aq_29 = 1
    repeat
        Aq_18 = {
            "icfvjnaedi",
            "bgzilzmndq",
            "ksahycxzk",
            "qlsqyuroindc",
            "rwohvlsb",
            "rpqwfbwbeccp",
            "csqflput",
            "ostixzkn",
            "sfjsoxa",
            "kqoqqhyq",
            "tjutnlqfiarr",
            "jjafnkjspq",
            "gzi",
            "idsblqzecen"
        }
        if Aq_18[(Aq_29 * 56 + 81) % 14 + 1] < Aq_18[(Aq_29 * 56 + 81) % 14 + 1] then
            rP = type(Aq_10) ~= "table"
        else
            Aq_10 = type(rP) ~= "table"
        end
        Aq_29 = (Aq_29 + 1) % 4
    until (Aq_29 * 3 + 0) % 4 == 2
end
if Aq_10 then
    Aq_29 = 3
    repeat
        if (Aq_29 * 3 + 5) * 17 % 4 == ((Aq_29 * 3 + 5) * 17 + 12) % 4 then
            error("failed to load UI library: " .. tostring(rP), 0)
        else
            error("failed to load UI library: " .. tostring(rP), 0)
        end
        Aq_29 = (Aq_29 + 2) % 8
    until (Aq_29 * 3 + 0) % 8 == 7
end
Window, rk, rf, Aq_18 = nil, nil, nil, nil
rP:LoadFont({ Name = "ValleySans" })
rP:SetDefaultTheme("Sakura")
Window = rP:CreateWindow({
    Name = Aq_6,
    LoadingSubtitle = Aq_14,
    ToggleUIKeybind = "RightControl",
    ConfigurationSaving = { Enabled = true, FolderName = "Tempo/SwimForEggs", FileName = "default" },
    ToggleButton = { Platform = "Mobile" },
    Home = {
        Title = "Welcome to Swim For Eggs!",
        Tier = Aq_14,
        Discord = Aq_26,
        Website = Aq_5,
        Stats = { "Players", "Session", "FPS", "Ping" }
    }
})
Aq_11 = Window:CreateTab({ Name = "Main", Icon = "gamepad-2" })
rk = Window:CreateTab({ Name = "Player", Icon = "user" })
rf = Window:CreateTab({ Name = "Settings", Icon = "settings" })
Aq_23 = Aq_11:AddLeftGroupbox({ Name = "Auto Steal", Icon = "egg" })
Aq_23:CreateToggle({ Name = "Auto Steal", CurrentValue = false, Flag = "AutoSteal", Callback = fns.fn43 })
Aq_23:CreateDropdown({
    Name = "Zone Filter",
    Options = Aq_31,
    CurrentOption = Aq_31,
    MultipleOptions = true,
    AllowNone = true,
    Flag = "StealZones",
    Callback = fn671
})
Aq_23:CreateDropdown({
    Name = "Rarity Filter",
    Options = Aq_9,
    CurrentOption = Aq_9,
    MultipleOptions = true,
    AllowNone = true,
    Flag = "StealRarities",
    Callback = fn867
})
Aq_21 = Aq_11:AddRightGroupbox({ Name = "Eggs", Icon = "sparkles" })
Aq_21:CreateToggle({ Name = "Auto Place Eggs", CurrentValue = false, Flag = "AutoPlace", Callback = fn1100 })
Aq_21:CreateToggle({ Name = "Auto Hatch Eggs", CurrentValue = false, Flag = "AutoHatch", Callback = fn970 })
Aq_21:CreateToggle({ Name = "Auto Equip Best", CurrentValue = false, Flag = "AutoEquipBest", Callback = fns.fn532 })
Aq_21:CreateToggle({ Name = "Auto Claim Index", CurrentValue = false, Flag = "AutoClaimIndex", Callback = fns.fn451 })
Aq_12 = Aq_11:AddLeftGroupbox({ Name = "Shop", Icon = "shopping-bag" })
Aq_12:CreateToggle({ Name = "Auto Buy Trail", CurrentValue = false, Flag = "AutoBuyTrail", Callback = fn1057 })
Aq_12:CreateToggle({ Name = "Auto Buy Pet Slots", CurrentValue = false, Flag = "AutoBuyPetSlots", Callback = fn979 })
local Group = Aq_11:AddRightGroupbox({ Name = "Auto Sell", Icon = "badge-dollar-sign" })
Group:CreateToggle({ Name = "Auto Sell", CurrentValue = false, Flag = "AutoSell", Callback = fns.fn191 })
Group:CreateDropdown({
    Name = "Sell Targets",
    Options = { "Eggs", "Pets" },
    CurrentOption = { "Eggs", "Pets" },
    MultipleOptions = true,
    AllowNone = true,
    Flag = "SellKinds",
    Callback = fns.fn294
})
Group:CreateDropdown({
    Name = "Sell Rarities",
    Options = Aq_9,
    CurrentOption = Aq_9,
    MultipleOptions = true,
    AllowNone = true,
    Flag = "SellRarities",
    Callback = fns.fn279
})
Aq_10 = Aq_11:AddLeftGroupbox({ Name = "Treadmill", Icon = "activity" })
if ((not Group and not Aq_18 or not Aq_18 and not Window) and ((not Window or Group) and (not Window and Aq_18)) or (not Group and Group and (Window and Window) or (Group or not Aq_18 or (Window or not Aq_18)))) and not ((not Group and not Aq_18 or not Aq_18 and not Window) and ((not Window or Group) and (not Window and Aq_18)) or (not Group and Group and (Window and Window) or (Group or not Aq_18 or (Window or not Aq_18)))) then
    Aq_18:CreateToggle({
        Callback = fns.fn478,
        CurrentValue = false,
        Name = "Auto Go on Treadmill",
        Flag = "AutoTreadmill"
    })
    Aq_18:CreateToggle({
        Name = "Auto Upgrade Treadmill",
        CurrentValue = false,
        Flag = "AutoUpgradeTreadmill",
        Callback = fns.fn507
    })
else
    Aq_10:CreateToggle({
        Name = "Auto Go on Treadmill",
        CurrentValue = false,
        Flag = "AutoTreadmill",
        Callback = fns.fn478
    })
    Aq_10:CreateToggle({
        Name = "Auto Upgrade Treadmill",
        CurrentValue = false,
        Flag = "AutoUpgradeTreadmill",
        Callback = fns.fn507
    })
    Aq_18 = fn811
end
Aq_34 = fns.fn518
Aq_18()
Aq_34()
Aq_29 = Window.Gui
if typeof(Aq_29) == "Instance" then
    connection5 = nil
    Aq_18 = 15
    repeat
        Aq_9 = (Aq_18 * 1 + 0) % 2 + 1
        if Aq_9 <= 1 then
            if Aq_18 * 46758379 + 12 + 6 >= Aq_18 * 46758379 + 12 + 6 + 1 then
                si.Track(fn709)
            else
                si.Track(fn709)
            end
            Aq_18 = (Aq_18 + 5) % 16
        else
            Aq_9 = {
                "akolenmba",
                "quekmtx",
                "nlco",
                "zndqqj",
                "ldtjwihbrd",
                "pymocooawmje",
                "bmkltzinfd",
                "rtuiilybjb",
                "twnymisxtxo",
                "jeluet",
                "pvgvjous",
                "eimejvtab",
                "bcroflz",
                "vwequqc",
                "mbqqksum",
                "fmdcyu"
            }
            if Aq_9[(Aq_18 * 12 + 75) % 16 + 1] <= Aq_9[(Aq_18 * 12 + 75) % 16 + 1] then
                connection5 = Aq_29.Destroying:Connect(onDestroying)
            else
                Aq_29 = connection5.Destroying:Connect(onDestroying)
            end
            Aq_18 = (Aq_18 + 3) % 16
        end
    until (Aq_18 * 7 + 14) % 16 == 15
end
Aq_9 = 2
repeat
    if (Aq_9 * 3 + 5) * 21 % 4 == ((Aq_9 * 3 + 5) * 21 + 5) % 4 then
        Window.setAntiAfk(true)
        Window.setNoGameplayPaused(true)
        si:LoadAutoload()
    else
        si.setAntiAfk(true)
        si.setNoGameplayPaused(true)
        Window:LoadAutoload()
    end
    Aq_9 = (Aq_9 + 1) % 4
until (Aq_9 * 3 + 3) % 4 == 0
if rP.Flags then
    if rP.Flags.AntiAfk ~= nil then
        Aq_29 = si.setAntiAfk
        Aq_18 = rP.Flags.AntiAfk and true
        Aq_9 = Aq_18 or false
        Aq_29(Aq_9)
    end
    if rP.Flags.NoGameplayPaused ~= nil then
        Aq_29 = si.setNoGameplayPaused
        Aq_18 = rP.Flags.NoGameplayPaused and true
        Aq_9 = Aq_18 or false
        Aq_29(Aq_9)
    end
end
end)(...)

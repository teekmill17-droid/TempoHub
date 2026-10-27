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
getgenv().TempoHoodSubtitle = "SAIL FOR EGGS"
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
local pi
local p_
local o_
local pH
local po
local pN
local pb
local pT
local oT
local ph
local pZ
local oZ
local pn
local Claim
local oM
local pt
local pa
local pg
local pY
local pm
local o3
local ps
local o9
local SaveManager
local oR
local py
local pf
local Upgrade
local oX
local pE
local pl
local Toggles
local pr
local pQ
local oQ
local PenGeometry
local oW
local pD
local Boats
local Library
local pJ
local o7
local pP
local oP
local pw
local pd
local ThemeManager
local oV
local Options
local pj
local State
local o0
local pI
local pp
local PenProgression
local pO
local Request
local pv
local pc
local LocalPlayer
local function fn88(aD, aE)
    return tonumber(aD.id) < tonumber(aE.id)
end
local function fn220()
    return oM.CoreGui
end
local function fn303()
    gethui = pP
end
local function fn482()
    return not oP.Unloaded
end
local function fn666(V)
    return type(V) == "function"
end
local function fn794(S)
    local q5 = typeof(cloneref) == "function" and typeof(S) == "Instance"
    if q5 then
        return cloneref(S)
    end
    return S
end
oM = nil
Request = nil
oP = nil
oQ = nil
oR = nil
oT = nil
oV = nil
oW = nil
oX = nil
oZ = nil
o_ = nil
o0 = nil
Library = nil
o3 = nil
PenProgression = nil
o7 = nil
o9 = nil
pa = nil
pb = nil
pc = nil
pd = nil
PenGeometry = nil
pf = nil
pg = nil
ph = nil
pi = nil
pj = nil
Boats = nil
pl = nil
pm = nil
pn = nil
po = nil
pp = nil
pr = nil
ps = nil
pt = nil
pv = nil
pw = nil
py = nil
local oN, oS, Activate, oY, o2, o4, o5, o8, pu, Data
Options = nil
pD = nil
pE = nil
pH = nil
pI = nil
pJ = nil
Toggles = nil
Claim = nil
pN = nil
pO = nil
pP = nil
pQ = nil
SaveManager = nil
pT = nil
LocalPlayer = nil
ThemeManager = nil
Upgrade = nil
pY = nil
pZ = nil
p_ = nil
State = nil
local pz, pA, pB, Equip, pG, pL, Request2, pW, p1
if not game:IsLoaded() then
    game.Loaded:Wait()
end
oM, LocalPlayer, pP = nil, nil, nil
oM = {}
oM.Players = game:GetService("Players")
oM.ReplicatedStorage = game:GetService("ReplicatedStorage")
oM.RunService = game:GetService("RunService")
oM.UserInputService = game:GetService("UserInputService")
oM.VirtualUser = game:GetService("VirtualUser")
oM.HttpService = game:GetService("HttpService")
oM.TeleportService = game:GetService("TeleportService")
oM.Workspace = game:GetService("Workspace")
oM.Lighting = game:GetService("Lighting")
oM.Stats = game:GetService("Stats")
oM.CoreGui = game:GetService("CoreGui")
LocalPlayer = oM.Players.LocalPlayer
pP = fn220
if getgenv then
    getgenv().gethui = pP
end
pc, o5, oY, oP, State, pa, Activate, Request, Upgrade, Request2, Claim, Equip, Data, Boats, PenGeometry, PenProgression, o_, oR, pA, ps = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pcall(fn303)
local function p5(i)
    local qZ
    local qX
    local qY
    qX = nil
    qY = nil
    qZ = nil
    local q_ = i ~= ""
    local q0 = type(i) == "string" and q_
    assert(q0, "Namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    qX = getgenv()
    assert(type(qX) == "table", "getgenv did not return a table")
    local q__1 = qX[i]
    if q__1 ~= nil then
        local q0_1 = type(q__1) == "table" and type(q__1.Unload) == "function"
        assert(q0_1, "Namespace is occupied")
        q__1.Unload()
        assert(qX[i] == nil, "Previous instance did not release its namespace")
    end
    qY = {}
    qZ = { State = {}, Unloaded = false }
    qZ.Track = function(o)
        assert(type(o) == "function", "Cleanup must be callable")
        if qZ.Unloaded then
            o()
        else
            table.insert(qY, o)
        end
        return o
    end
    qZ.Unload = function()
        local qQ_1
        local qP_1
        if qZ.Unloaded then
            return
        end
        qZ.Unloaded = true
        local qN = {}
        local qU = #qY
        local qT = -1
        while false and qU <= 1 or true and qU >= 1 do
            local qV = qU
            local qO_1 = table.remove(qY, qV)
            qP_1, qQ_1 = pcall(qO_1)
            if not qP_1 then
                table.insert(qN, tostring(qQ_1))
            end
            qU += qT
        end
        table.clear(qZ.State)
        if #qN > 0 then
            error("Cleanup incomplete: " .. table.concat(qN, "; "), 0)
        end
        if qX[i] == qZ then
            qX[i] = nil
        end
    end
    qX[i] = qZ
    return qZ
end
local function qa(D, E)
    local q3 = type(D) == "table" and type(D.Track) == "function"
    assert(q3, "FeatureAPI required")
    local q3_1 = type(E) == "table" and type(E.OnUnload) == "function"
    assert(q3_1, "UI library required")
    assert(type(E.Unload) == "function", "UI unload required")
    D.Track(function()
        if not E.Unloaded then
            E:Unload()
        end
    end)
    E:OnUnload(function()
        D.Unload()
    end)
end
local p4 = "TempoSailForEggs"
local pq = "Sail For Eggs"
local qb = "v0.4"
pc = "https://discord.gg/K7Qxnxkk46"
o5 = "https://discord.gg/K7Qxnxkk46"
oY = "https://tempohub.shop"
oP = p5(p4)
State = oP.State
pA = fn666
ps = fn482
local p3 = fn794(oM.ReplicatedStorage)
local p3_1
pa = fn794(oM.Workspace)
local Events = p3:WaitForChild("Events")
Activate = Events:WaitForChild("Interaction"):WaitForChild("Activate")
Request = Events:WaitForChild("Pen"):WaitForChild("Request")
Upgrade = Events:WaitForChild("Boat"):WaitForChild("Upgrade")
Request2 = Events:WaitForChild("SellPets"):WaitForChild("Request")
Claim = Events:WaitForChild("Index"):WaitForChild("Claim")
Equip = Events:WaitForChild("Inventory"):WaitForChild("Equip")
Data = require(p3.Source.Game.Data)
local p8 = require(p3.Source.Game.Items.Animals)
local Worlds = require(p3.Source.Game.Items.Worlds)
Boats = require(p3.Source.Game.Items.Boats)
PenGeometry = require(p3.Source.Features.Pen.PenGeometry)
PenProgression = require(p3.Source.Features.Pen.PenProgression)
if ((not Data or oY) and (p8 and p8) or Claim and Data and (false or p8) or false or ((p8 or not Claim) and (p8 and false) or 61 or (Claim and false or Data and pq or (Claim or not Data) and (Claim and not Claim)))) and not ((not Data or oY) and (p8 and p8) or Claim and Data and (false or p8) or false or ((p8 or not Claim) and (p8 and false) or 61 or (Claim and false or Data and pq or (Claim or not Data) and (Claim and not Claim)))) then
    p8 = { "Epic", "Arcane", "Rare", "Mythic", "Common", "Uncommon", "Secret", "Etherial", "Legendary" }
else
    o_ = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Arcane", "Etherial" }
end
oR = {}
for i, v in ipairs(o_) do
    oR[v] = i
end
pO = {}
for k, v in p8 do
    local p2_1 = type(v) == "table" and type(v.id) == "string"
    if p2_1 then
        pO[v.id] = v
    end
end
p3_1, pn, ph = nil, nil, nil
local p2_2 = 1
repeat
    if (p2_2 * 1 + 1) % 2 + 1 <= 1 then
        if (pn or not p2_2) and (pn and not p2_2) and (not p2_2 and not pn and (not p2_2 and not pn)) or (p2_2 and not pn or p2_2 and not p2_2 or (not pn and not pn or p2_2 and not p2_2)) or not ((pn or not p2_2) and (pn and not p2_2) and (not p2_2 and not pn and (not p2_2 and not pn)) or (p2_2 and not pn or p2_2 and not p2_2 or (not pn and not pn or p2_2 and not p2_2))) then
            p3_1 = {}
        else
            pn = {}
        end
        p2_2 = (p2_2 + 3) % 16
    else
        local ze = bit32.rrotate(bit32.bxor(bit32.lrotate(p2_2, 31), string.byte(tostring(p3_1))), 28)
        if bit32.bxor(bit32.lrotate(bit32.bxor(ze, 1094043637), 4), 324829012) == bit32.lrotate(ze, 4) then
            pn = {}
            ph = {}
        else
            ph = {}
            pn = {}
        end
        p2_2 = (p2_2 + 15) % 16
    end
until (p2_2 * 7 + 0) % 16 == 5
for k, v in Worlds do
    local p2_3 = type(v) == "table" and v.id ~= nil and type(v.displayName) == "string"
    if p2_3 then
        local p2_4 = tostring(v.id)
        local displayName = v.displayName
        table.insert(p3_1, { id = p2_4, label = displayName })
        table.insert(pn, displayName)
        ph[displayName] = p2_4
    end
end
table.sort(p3_1, fn88)
table.clear(pn)
for i, v in ipairs(p3_1) do
    table.insert(pn, v.label)
end
pw = {}
for i, v in ipairs(Boats) do
    local p2_5 = type(v) == "table" and type(v.id) == "string"
    if p2_5 then
        pw[v.id] = { index = i, def = v }
    end
end
o7 = Vector3.new(-16, 3, 66)
State.AutoSteal = false
State.AutoPlace = false
State.AutoHatch = false
State.AutoEquipBest = false
State.AutoSell = false
State.AutoBuyBoat = false
State.AutoRepair = false
State.AutoUpgradeBoat = false
State.AutoUpgradePen = false
State.AutoClaimIndex = false
State.SelectedZones = {}
State.StealRarities = {}
State.SellRarities = {}
State.SellMode = "Animals"
State.StealBusy = false
State.PlaceBusy = false
State.EquipVersion = 0
State.Workers = {}
State.Status = "Idle"
Library = nil
oT = function(aO, aP)
    if Library and Library.Notify then
        local q7_1 = tostring(aO)
        local q8 = aP or 4
        Library:Notify(q7_1, q8)
    end
end
pD = function(aT)
    local ra = State.Workers[aT]
    if ra then
        pcall(task.cancel, ra)
        State.Workers[aT] = nil
    end
end
pj = function(aX, aY, aZ)
    pD(aX)
    State.Workers[aX] = task.spawn(function()
        local rg_1
        local rf_1
        while ps() do
            rf_1, rg_1 = pcall(aZ)
            if not rf_1 then
                warn("[Tempo]", aX, rg_1)
            end
            task.wait(aY)
            if not ps() then
                break
            end
        end
    end)
end
pg = function(a9, ba)
    local rj_1
    local ri_1
    ri_1, rj_1 = pcall(function()
        return Data.client[a9]()
    end)
    if ri_1 then
        return rj_1
    end
    return ba
end
pE = function()
    local Character = LocalPlayer.Character
    if not Character then
        return nil
    end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid or Humanoid.Health <= 0 then
        return nil
    end
    return Character:FindFirstChild("HumanoidRootPart"), Character, Humanoid
end
pd = function()
    local Plots = pa:FindFirstChild("Plots")
    if not Plots then
        return nil
    end
    for i, child in ipairs(Plots:GetChildren()) do
        local rs_1 = child:IsA("Model") and child:GetAttribute("OwnerUserId") == LocalPlayer.UserId
        if rs_1 then
            return child
        end
    end
    return nil
end
pJ = function(bt)
    local rA
    local rB
    rA = nil
    rB = nil
    rA = pE()
    if not rA then
        return false
    end
    local rC = typeof(bt) == "Vector3" and bt
    rB = rC or nil
    if not rB then
        return false
    end
    pcall(function()
        rA.AssemblyLinearVelocity = Vector3.zero
        rA.AssemblyAngularVelocity = Vector3.zero
        rA.CFrame = CFrame.new(rB + Vector3.new(0, 3, 0))
    end)
    return true
end
o3 = function(bA)
    local rF = pO[bA]
    return rF and rF.rarity or nil
end
pN = function(bF)
    local rI = {}
    if type(bF) ~= "table" then
        return rI
    end
    for k, v in pairs(bF) do
        if v == true then
            rI[tostring(k)] = true
        else
            local rJ = type(k) == "number" and type(v) == "string"
            if rJ then
                rI[v] = true
            end
        end
    end
    return rI
end
pf = function(bL)
    local SelectedZones = State.SelectedZones
    local rS = false
    for k in pairs(SelectedZones) do
        rS = true
        break
    end
    if not rS then
        return true
    end
    return SelectedZones[tostring(bL)] == true
end
pQ = function(bR, bS)
    local rY = false
    for k in pairs(bS) do
        rY = true
        break
    end
    if not rY then
        return true
    end
    return bR ~= nil and bS[bR] == true
end
pi = function(bX)
    if not bX or not bX.Parent then
        return false
    elseif bX:GetAttribute("Action") ~= "Pickup" then
        return false
    else
        local attr2 = bX:GetAttribute("PersonalOwnerUserId")
        if attr2 ~= nil and attr2 ~= LocalPlayer.UserId then
            return false
        end
        local attr = bX:GetAttribute("worldId")
        if not pf(attr) then
            return false
        end
        local r3_3 = o3(bX:GetAttribute("eggId"))
        if not pQ(r3_3, State.StealRarities) then
            return false
        end
        return true
    end
end
pm = function(b8)
    if b8:IsA("Model") then
        return b8:GetPivot().Position
    end
    local sb = if b8:IsA("BasePart") then 1 else 0
    if sb == 1 then
        return b8.Position
    end
    local BasePart = b8:FindFirstChildWhichIsA("BasePart", true)
    return BasePart and BasePart.Position or nil
end
oV = function()
    local sj_1
    local si_1
    local Terrain = pa:FindFirstChild("Terrain")
    local sg = Terrain and Terrain:FindFirstChild("World")
    local sf_1 = sg
    if sg then
        sg = sf_1:FindFirstChild("Main")
    end
    local sf_2 = sg
    if sg then
        sg = sf_2:FindFirstChild("Worlds")
    end
    local sf_3 = sg
    if not sf_3 then
        return nil
    end
    local sg_1 = pE()
    local sg_2 = sg_1 and sg_1.Position or Vector3.zero
    sj_1, si_1 = nil, nil
    for i, child in ipairs(sf_3:GetChildren()) do
        local SpawnedEggs = child:FindFirstChild("SpawnedEggs")
        if SpawnedEggs then
            for i, child in ipairs(SpawnedEggs:GetChildren()) do
                if pi(child) then
                    local sf_5 = pm(child)
                    if sf_5 then
                        local Magnitude = (sf_5 - sg_2).Magnitude
                        if not si_1 or Magnitude < si_1 then
                            sj_1 = child
                            si_1 = Magnitude
                        end
                    end
                end
            end
        end
    end
    return sj_1, si_1
end
pb = function(cx)
    if not cx or not cx.Parent then
        return false
    end
    local sA_1 = pcall(function()
        Activate:FireServer(cx)
    end)
    return sA_1
end
pG = function(cE)
    State.EquipVersion = State.EquipVersion + 1
    local EquipVersion = State.EquipVersion
    local cL = pcall(function()
        Equip:FireServer(EquipVersion, cE)
    end)
    return cL, EquipVersion
end
oN = function(cN, cO)
    local sC = os.clock()
    local sE = sC + (cO or 3)
    while true do
        local sC_1 = ps() and os.clock() < sE
        if sC_1 then
            local Character = LocalPlayer.Character
            local sD_1 = Character and Character:FindFirstChildOfClass("Tool")
            local sF = sD_1
            if sD_1 then
                sD_1 = sF:GetAttribute("uniqueId") == cN
            end
            if sD_1 then
                return sF
            end
            if LocalPlayer:GetAttribute("ServerEquippedItemId") == cN then
                local sD_2 = Character and Character:FindFirstChildOfClass("Tool")
                local sC_3 = sD_2 and sD_2:GetAttribute("uniqueId") == cN
                if sC_3 then
                    return sD_2
                end
            end
            task.wait(0.1)
            continue
        end
        break
    end
    return nil
end
pZ = function()
    local sH = {}
    local sI = pg("ownedEggs", {})
    local sJ = pg("ownedAnimals", {})
    for k, v in pairs(sI) do
        local placement = v.placement
        if type(placement) == "table" then
            local insert = table.insert
            local sL_1 = placement.x or placement.X
            local sM = placement.z or placement.Z
            insert(sH, { x = sL_1, z = sM, radius = 1.35 })
        end
    end
    for k, v in pairs(sJ) do
        local placement = v.placement
        if type(placement) == "table" then
            local insert = table.insert
            local sK_2 = placement.x or placement.X
            local sL_2 = placement.z or placement.Z
            insert(sH, { x = sK_2, z = sL_2, radius = 1.35 })
        end
    end
    return sH
end
pL = function(de)
    local s_ = de:GetAttribute("PenSizeLevel") or 1
    local s__1 = PenGeometry.bounds(de, s_)
    if not s__1 then
        return nil
    end
    local s0_1 = pZ()
    local minX = s__1.minX
    local maxX = s__1.maxX
    local s6 = minX
    while s6 <= maxX do
        local s7 = s6
        local minZ = s__1.minZ
        local maxZ = s__1.maxZ
        local tb = minZ
        while tb <= maxZ do
            local tc = tb
            local s1_2 = Vector3.new(s7, s__1.y, tc)
            if PenGeometry.fits(s__1, s1_2, 1.35, s0_1) then
                return s1_2
            end
            tb += 1.5
        end
        s6 += 1.5
    end
    return Vector3.new((s__1.minX + s__1.maxX) / 2, s__1.y, (s__1.minZ + s__1.maxZ) / 2)
end
p1 = function()
    local tg_1
    local tf_1
    local te = pg("ownedEggs", {})
    tg_1, tf_1 = nil, nil
    for k, v in pairs(te) do
        local te_1 = type(v) == "table" and type(v.uniqueId) == "string" and not v.placement
        if te_1 then
            local te_2 = o3(v.eggId)
            local th = oR[te_2] or 0
            if not tf_1 or th > tf_1 then
                tg_1 = v
                tf_1 = th
            end
        end
    end
    return tg_1
end
pW = function()
    local tq = workspace:GetServerTimeNow()
    local tr = {}
    local ts = pg("ownedEggs", {})
    for k, v in pairs(ts) do
        local ts_1 = type(v) == "table" and v.placement and type(v.uniqueId) == "string"
        if ts_1 then
            local hatchReadyAt = v.hatchReadyAt
            local tt = typeof(hatchReadyAt) == "number" and hatchReadyAt <= tq
            if tt then
                table.insert(tr, v.uniqueId)
            end
        end
    end
    return tr
end
o0 = function()
    local tB = pg("equippedBoatId", "Rowboat")
    local tC = pw[tB]
    if not tC then
        return nil
    end
    return Boats[tC.index + 1]
end
pB = function(dR)
    local tH = {}
    local SellRarities = State.SellRarities
    local tJ = dR == "Both"
    local tK = dR == "Animals"
    local tO = if tK then 1 else 0
    local tM = 3661 * tO + 1637 * (1 - tO)
    local tN = 1179 * tO + 2042 * (1 - tO)
    if not ((tM * 1895 + tN * 3825 + tM * tN) % 16777213 == 15763589) then
        tK = tJ
    end
    if tK then
        for k, v in pairs(pg("ownedAnimals", {})) do
            local tJ_1 = type(v) == "table" and not v.placement and type(v.uniqueId) == "string"
            if tJ_1 then
                local tJ_2 = o3(v.animalId)
                if pQ(tJ_2, SellRarities) then
                    table.insert(tH, v.uniqueId)
                end
            end
        end
    end
    if dR == "Eggs" or dR == "Both" then
        for k, v in pairs(pg("ownedEggs", {})) do
            local tJ_4 = type(v) == "table" and not v.placement and type(v.uniqueId) == "string"
            if tJ_4 then
                local tJ_5 = o3(v.eggId)
                if pQ(tJ_5, SellRarities) then
                    table.insert(tH, v.uniqueId)
                end
            end
        end
    end
    return tH
end
pl = function()
    State.Status = "Banking"
    local t0 = os.clock() + 8
    while true do
        local t1 = ps() and State.AutoSteal and LocalPlayer:GetAttribute("StealingEgg") == true and os.clock() < t0
        if t1 then
            local t1_1 = pE()
            if t1_1 and (t1_1.Position - o7).Magnitude > 6 then
                pJ(o7)
            end
            task.wait(0.2)
            continue
        end
        break
    end
end
pt = function()
    if not State.AutoSteal or State.StealBusy then
        return
    end
    if LocalPlayer:GetAttribute("StealingEgg") == true then
        State.StealBusy = true
        pl()
        State.StealBusy = false
        return
    end
    local t4_1 = oV()
    if not t4_1 then
        State.Status = "No eggs"
        return
    end
    State.StealBusy = true
    State.Status = "Stealing"
    local t5 = pm(t4_1)
    if t5 then
        pJ(t5)
        task.wait(0.15)
    end
    local t5_1 = ps() and State.AutoSteal and t4_1.Parent and pi(t4_1)
    if t5_1 then
        pb(t4_1)
    end
    local t4_2 = os.clock() + 2.5
    while true do
        local t5_2 = ps() and os.clock() < t4_2
        if t5_2 then
            if LocalPlayer:GetAttribute("StealingEgg") == true then
                break
            end
            task.wait(0.1)
            continue
        end
        break
    end
    local t9 = if LocalPlayer:GetAttribute("StealingEgg") == true then 1 else 0
    if t9 == 1 then
        pl()
    end
    State.StealBusy = false
end
o9 = function()
    if not State.AutoPlace or State.PlaceBusy or State.StealBusy then
        return
    end
    if LocalPlayer:GetAttribute("StealingEgg") == true then
        return
    end
    local uc_1 = pd()
    local ua = p1()
    if not uc_1 or not ua then
        return
    end
    local ub = pL(uc_1)
    if not ub then
        return
    end
    State.PlaceBusy = true
    State.Status = "Placing"
    pG(ua.uniqueId)
    local uc_2 = oN(ua.uniqueId, 3)
    local ud_1 = uc_2 and ps() and State.AutoPlace
    if ud_1 then
        pcall(function()
            Request:FireServer("Place", ua.uniqueId, ub, 0)
        end)
        task.wait(0.35)
    end
    State.PlaceBusy = false
end
pI = function()
    if not State.AutoHatch then
        return
    end
    for i, v in ipairs(pW()) do
        local uq = v
        local uj = not ps() or not State.AutoHatch
        if uj then
            break
        end
        pcall(function()
            Request:FireServer("HatchFromPanel", uq)
        end)
        task.wait(0.2)
    end
end
pY = function()
    if not State.AutoEquipBest then
        return
    end
    pcall(function()
        Request:FireServer("EquipBest")
    end)
end
py = function()
    local SellMode, uu
    if not State.AutoSell then
        return
    end
    SellMode = State.SellMode
    if SellMode == "Both" then
        local us = pB("Animals")
        if #us > 0 then
            pcall(function()
                Request2:FireServer("Animals", us)
            end)
            task.wait(0.4)
        end
        local uv = pB("Eggs")
        if #uv > 0 then
            pcall(function()
                Request2:FireServer("Eggs", uv)
            end)
        end
        return
    end
    uu = pB(SellMode)
    if #uu == 0 then
        return
    end
    pcall(function()
        Request2:FireServer(SellMode, uu)
    end)
end
po = function()
    if not State.AutoBuyBoat and not State.AutoUpgradeBoat then
        return
    end
    local uA_1 = o0()
    if not uA_1 then
        return
    end
    local uB = pg("currency", 0)
    local uC = typeof(uB) ~= "number"
    local uH = if uC then 1 else 0
    local uF = 2943 * uH + 3027 * (1 - uH)
    local uG = 152 * uH + 864 * (1 - uH)
    if not ((uF * 2490 + uG * 253 + uF * uG) % 16777213 == 7813862) then
        uC = uB < (uA_1.price or math.huge)
    end
    if uC then
        return
    end
    local uA_2 = pd()
    if not uA_2 then
        return
    end
    local uB_1 = uA_2:FindFirstChild("Assets") and uA_2.Assets:FindFirstChild("BoatUpgradeSign")
    if uB_1 then
        pJ(uB_1:GetPivot().Position)
        task.wait(0.2)
    end
    pcall(function()
        Upgrade:FireServer()
    end)
end
oW = function()
    local uL = pd()
    if not uL then
        return nil
    end
    local RepairZone = uL:FindFirstChild("RepairZone")
    if not RepairZone then
        return nil
    end
    local Center = RepairZone:FindFirstChild("Center", true)
    local uN = Center and Center:IsA("Attachment")
    if uN then
        return Center.WorldPosition
    end
    local Part = RepairZone:FindFirstChild("Part", true)
    local uN_1 = Part and Part:IsA("BasePart")
    if uN_1 then
        return Part.Position
    end
    return RepairZone:GetPivot().Position
end
pr = function()
    if not State.AutoRepair then
        return
    end
    local uP = State.StealBusy or LocalPlayer:GetAttribute("StealingEgg") == true
    if uP then
        return
    end
    local uP_1 = oW()
    if not uP_1 then
        return
    end
    local uQ = pE()
    if not uQ then
        return
    end
    if (Vector3.new(uQ.Position.X, 0, uQ.Position.Z) - Vector3.new(uP_1.X, 0, uP_1.Z)).Magnitude > 3 then
        pJ(uP_1)
    end
    State.Status = "Repairing"
end
pH = function()
    if not State.AutoUpgradePen then
        return
    end
    local uS = pg("penLevel", 1)
    if typeof(uS) ~= "number" then
        uS = 1
    end
    local uT = PenProgression[uS]
    if not uT or uT.price == nil then
        return
    end
    local uS_2 = pg("currency", 0)
    local uU = typeof(uS_2) ~= "number" or uS_2 < uT.price
    if uU then
        return
    end
    pcall(function()
        Request:FireServer("UpgradeFromPanel")
    end)
end
pT = function()
    if not State.AutoClaimIndex then
        return
    end
    pcall(function()
        Claim:FireServer("All")
    end)
end
oP.SetAutoSteal = function(f3)
    local u0 = f3 and true or false
    State.AutoSteal = u0
    if State.AutoSteal then
        pj("steal", 0.35, pt)
    else
        pD("steal")
        State.StealBusy = false
    end
end
oP.SetAutoPlace = function(f8)
    local u3 = f8 and true or false
    State.AutoPlace = u3
    if State.AutoPlace then
        pj("place", 0.5, o9)
    else
        pD("place")
        State.PlaceBusy = false
    end
end
oP.SetAutoHatch = function(gd)
    local u6 = gd and true or false
    State.AutoHatch = u6
    if State.AutoHatch then
        pj("hatch", 0.75, pI)
    else
        pD("hatch")
    end
end
oP.SetAutoEquipBest = function(gi)
    local vc = gi and true or false
    State.AutoEquipBest = vc
    if State.AutoEquipBest then
        pj("equipBest", 2, pY)
    else
        pD("equipBest")
    end
end
oP.SetAutoSell = function(gn)
    local vi = gn and true or false
    State.AutoSell = vi
    if State.AutoSell then
        pj("sell", 2.5, py)
    else
        pD("sell")
    end
end
oP.SetAutoBuyBoat = function(go)
    local vl = go and true or false
    State.AutoBuyBoat = vl
    if State.AutoBuyBoat or State.AutoUpgradeBoat then
        pj("boatBuy", 2, po)
    else
        pD("boatBuy")
    end
end
oP.SetAutoUpgradeBoat = function(gq)
    local vo = gq and true or false
    State.AutoUpgradeBoat = vo
    if State.AutoBuyBoat or State.AutoUpgradeBoat then
        pj("boatBuy", 2, po)
    else
        pD("boatBuy")
    end
end
oP.SetAutoRepair = function(gs)
    local vu = gs and true or false
    State.AutoRepair = vu
    if State.AutoRepair then
        pj("repair", 0.75, pr)
    else
        pD("repair")
    end
end
oP.SetAutoUpgradePen = function(gt)
    local vx = gt and true or false
    State.AutoUpgradePen = vx
    if State.AutoUpgradePen then
        pj("penUpgrade", 2, pH)
    else
        pD("penUpgrade")
    end
end
oP.SetAutoClaimIndex = function(gu)
    local vA = gu and true or false
    State.AutoClaimIndex = vA
    if State.AutoClaimIndex then
        pj("index", 3, pT)
    else
        pD("index")
    end
end
oP.SetSelectedZones = function(gv)
    local vC = pN(gv)
    local vD = {}
    for k in pairs(vC) do
        local vC_1 = ph[k]
        if vC_1 then
            vD[vC_1] = true
        end
    end
    State.SelectedZones = vD
end
oP.SetStealRarities = function(gB)
    State.StealRarities = pN(gB)
end
oP.SetSellRarities = function(gE)
    State.SellRarities = pN(gE)
end
oP.SetSellMode = function(gH)
    if gH == "Eggs" or gH == "Animals" or gH == "Both" then
        State.SellMode = gH
    end
end
oZ = {
    [1] = false,
    [2] = 32,
    [3] = false,
    [4] = false,
    [5] = false,
    [6] = false,
    [7] = 60,
    [8] = {},
    [9] = {}
}
oQ = function(gL)
    local vN = oZ[8][gL]
    if vN then
        vN:Disconnect()
        oZ[8][gL] = nil
    end
end
oP.SetWalkSpeedEnabled = function(gO)
    local vY_1
    local vW = gO and true
    local vW_1
    local vX = vW
    local vX_1
    local v1 = if vX then 1 else 0
    local v_ = 138 * v1 + 1464 * (1 - v1)
    local v0 = 3362 * v1 + 1733 * (1 - v1)
    if not ((v_ * 2982 + v0 * 1387 + v_ * v0) % 16777213 == 5538566) then
        vX = false
    end
    oZ[1] = vX
    oQ("walk")
    if not oZ[1] then
        vX_1, vW_1, vY_1 = pE()
        if vY_1 then
            vY_1.WalkSpeed = 16
        end
        return
    end
    oZ[8].walk = oM.RunService.Heartbeat:Connect(function()
        local vR_1
        local vQ_1
        local vP = not ps() or not oZ[1]
        local vP_1
        if vP then
            return
        end
        vQ_1, vP_1, vR_1 = pE()
        if vR_1 and vR_1.WalkSpeed ~= oZ[2] then
            vR_1.WalkSpeed = oZ[2]
        end
    end)
end
oP.SetWalkSpeedValue = function(g4)
    local v5 = tonumber(g4) or 32
    oZ[2] = v5
end
oP.SetInfJump = function(g6)
    local wf = g6 and true or false
    oZ[3] = wf
    oQ("infJump")
    if not oZ[3] then
        return
    end
    oZ[8].infJump = oM.UserInputService.JumpRequest:Connect(function()
        local v9_1
        local v8_1
        local v7 = not ps() or not oZ[3]
        local v7_1
        if v7 then
            return
        end
        v7_1, v8_1, v9_1 = pE()
        if v9_1 then
            v9_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end
oP.SetNoClip = function(hj)
    local wq = hj and true
    local wu = if wq then 1 else 0
    local ws = 1580 * wu + 404 * (1 - wu)
    local wt = 2882 * wu + 3326 * (1 - wu)
    if not ((ws * 2441 + wt * 3350 + ws * wt) % 16777213 == 1287827) then
        wq = false
    end
    oZ[4] = wq
    oQ("noclip")
    if not oZ[4] then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    descendant.CanCollide = true
                end
            end
        end
        return
    end
    oZ[8].noclip = oM.RunService.Stepped:Connect(function()
        local wh = not ps() or not oZ[4]
        if wh then
            return
        end
        local Character = LocalPlayer.Character
        if not Character then
            return
        end
        for i, descendant in ipairs(Character:GetDescendants()) do
            if descendant:IsA("BasePart") then
                descendant.CanCollide = false
            end
        end
    end)
end
oP.SetInstantProximityPrompt = function(hz)
    local wH
    local wJ = hz and true
    local wN = if wJ then 1 else 0
    local wL = 369 * wN + 2766 * (1 - wN)
    local wM = 3942 * wN + 737 * (1 - wN)
    if not ((wL * 1082 + wM * 2457 + wL * wM) % 16777213 == 11539350) then
        wJ = false
    end
    oZ[5] = wJ
    if not oZ[5] then
        for k, v in pairs(oZ[9]) do
            local wR = k
            local wT = v
            if wR and wR.Parent then
                pcall(function()
                    wR.HoldDuration = wT
                end)
            end
        end
        table.clear(oZ[9])
        oQ("prompt")
        return
    end
    wH = function(hI)
        local wB = hI:IsA("ProximityPrompt") and oZ[9][hI] == nil
        if wB then
            oZ[9][hI] = hI.HoldDuration
            hI.HoldDuration = 0
        end
    end
    for i, descendant in ipairs(pa:GetDescendants()) do
        wH(descendant)
    end
    oQ("prompt")
    oZ[8].prompt = pa.DescendantAdded:Connect(function(hO)
        if oZ[5] then
            wH(hO)
        end
    end)
end
oP.SetFly = function(hR)
    local xa = hR and true or false
    oZ[6] = xa
    oQ("fly")
    local w9_1 = pE()
    if w9_1 then
        local OuroFly = w9_1:FindFirstChild("OuroFly")
        if OuroFly then
            OuroFly:Destroy()
        end
    end
    if not oZ[6] then
        return
    end
    oZ[8].fly = oM.RunService.RenderStepped:Connect(function()
        local w_ = not ps() or not oZ[6]
        if w_ then
            return
        end
        local w__1 = pE()
        if not w__1 then
            return
        end
        local w0 = w__1:FindFirstChild("OuroFly")
        if not w0 then
            w0 = Instance.new("BodyVelocity")
            w0.Name = "OuroFly"
            w0.MaxForce = Vector3.new(100000, 100000, 100000)
            w0.Parent = w__1
        end
        local w__2 = Vector3.zero
        local CurrentCamera = pa.CurrentCamera
        if not CurrentCamera then
            return
        end
        if oM.UserInputService:IsKeyDown(Enum.KeyCode.W) then
            w__2 += CurrentCamera.CFrame.LookVector
        end
        if oM.UserInputService:IsKeyDown(Enum.KeyCode.S) then
            w__2 -= CurrentCamera.CFrame.LookVector
        end
        if oM.UserInputService:IsKeyDown(Enum.KeyCode.A) then
            w__2 -= CurrentCamera.CFrame.RightVector
        end
        if oM.UserInputService:IsKeyDown(Enum.KeyCode.D) then
            w__2 += CurrentCamera.CFrame.RightVector
        end
        if oM.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            w__2 += Vector3.yAxis
        end
        if oM.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            w__2 -= Vector3.yAxis
        end
        if w__2.Magnitude > 0 then
            w0.Velocity = w__2.Unit * oZ[7]
        else
            w0.Velocity = Vector3.zero
        end
    end)
end
oP.SetFlySpeed = function(h9)
    local xc = tonumber(h9) or 60
    oZ[7] = xc
end
oP.Track(function()
    for k in pairs(State.Workers) do
        pD(k)
    end
    oP.SetWalkSpeedEnabled(false)
    oP.SetInfJump(false)
    oP.SetNoClip(false)
    oP.SetInstantProximityPrompt(false)
    oP.SetFly(false)
end)
pu = function(ii, ij)
    local xj = false
    if type(setclipboard) == "function" then
        xj = pcall(setclipboard, ii)
    elseif type(toclipboard) == "function" then
        xj = pcall(toclipboard, ii)
    end
    if xj then
        local xj_1 = ij or "Copied"
        oT(xj_1, 3)
    else
        oT("Clipboard unavailable", 3)
    end
end
oX = function(io)
    return (tostring(io):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
end
p_ = function(iq, ir)
    return string.format('<font color="%s">%s</font>', ir, oX(iq))
end
pz = function(iu, iv, iw)
    return string.format("<b>%s</b> %s %s", iu, '<font color="#5a6070">-</font>', p_(iv, iw))
end
oS = "#e8a34d"
o2 = "#6ec1ff"
o8 = "#7fd47f"
Library = getgenv().Library
ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles, Options = Library.Toggles, Library.Options
qa(oP, Library)
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = pc, Copyable = true }, "|", pq, "|", qb },
    Icon = 132608042600488,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    SidebarCompacted = true,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
pv = {}
pv[1] = Window:AddTab("Info", "info")
pv[2] = Window:AddTab("Main", "gamepad-2")
pv[3] = Window:AddTab("Player", "person-standing")
pv[4] = Window:AddTab("Settings", "settings")
pp = function(iJ)
    local DiscordGroup = iJ:AddLeftGroupbox("Discord", "message-circle")
    DiscordGroup:AddDiscordBox(nil, {
        Banner = 95892854151512,
        Avatar = 132608042600488,
        Title = "Tempo Hub",
        Subtitle = "Dupes, keyless scripts and updates",
        Status = "online",
        Accent = Color3.fromRGB(88, 101, 242),
        Link = pc,
        Buttons = { { Text = "Copy Discord Invite", Icon = "copy", Copy = true } }
    })
    return DiscordGroup
end
local function p2_7()
    local iS
    local iN
    iN = "Unknown"
    pcall(function()
        local xm_1
        local xl_1
        if type(identifyexecutor) == "function" then
            xm_1, xl_1 = identifyexecutor()
            local xn = xm_1 ~= ""
            local xo = type(xm_1) == "string" and xn
            if xo then
                local xn_1 = type(xl_1) == "string" and xl_1 ~= "" and xm_1 .. " " .. xl_1
                iN = xn_1 or xm_1
            end
        end
    end)
    iS = os.clock()
    local function iT()
        local xq = math.floor(os.clock() - iS)
        if xq < 60 then
            return xq .. "s"
        elseif xq < 3600 then
            return string.format("%dm %ds", math.floor((xq) / (60)), xq % 60)
        else
            return string.format("%dh %dm", math.floor((xq) / (3600)), math.floor((xq % 3600) / (60)))
        end
    end
    local UserGroup = pv[1]:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(pz("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, o8), true)
    UserGroup:AddLabel(pz("UserId", tostring(LocalPlayer.UserId), o2), true)
    UserGroup:AddLabel(pz("Executor", iN, o8), true)
    UserGroup:AddDivider()
    local Label5 = UserGroup:AddLabel(pz("Session", iT(), oS), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            pu(LocalPlayer.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            pu("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
        end
    })
    local DiscordGroup = pv[1]:AddRightGroupbox("Discord", "message-circle")
    DiscordGroup:AddDiscordBox(nil, {
        Banner = 95892854151512,
        Avatar = 132608042600488,
        Title = "Tempo Hub",
        Subtitle = "Dupes, keyless scripts and updates",
        Status = "online",
        Accent = Color3.fromRGB(88, 101, 242),
        Link = pc,
        Buttons = { { Text = "Copy Discord Invite", Icon = "copy", Copy = true } }
    })
    local SessionGroup = pv[1]:AddRightGroupbox("Session", "signal")
    local Label4 = SessionGroup:AddLabel('<b>Game</b> <font color="#5a6070">-</font> <font color="#7fd47f">Sail For Eggs</font>', true)
    local Label3 = SessionGroup:AddLabel(pz("Players", tostring(#oM.Players:GetPlayers()), o2), true)
    local Label2 = SessionGroup:AddLabel(pz("Job", string.sub(game.JobId, 1, 8) .. "...", oS), true)
    local Label = SessionGroup:AddLabel('<b>Ping</b> <font color="#5a6070">-</font> <font color="#7fd47f">0 ms</font>', true)
    SessionGroup:AddButton({
        Text = "Rejoin Place",
        Func = function()
            pcall(function()
                oM.TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            pu(game.JobId, "Copied Job ID")
        end
    })
    local SocialsGroup = pv[1]:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({
        Text = "Copy Discord",
        Func = function()
            pu(pc, "Copied Discord")
        end
    })
    SocialsGroup:AddButton({
        Text = "Copy Rscripts",
        Func = function()
            pu(o5, "Copied Rscripts")
        end
    })
    SocialsGroup:AddButton({
        Text = "Copy Website",
        Func = function()
            pu(oY, "Copied Website")
        end
    })
    task.spawn(function()
        local xv = false
        repeat
            local xs
            if ps() then
                Label5:SetText(pz("Session", iT(), oS))
                Label3:SetText(pz("Players", tostring(#oM.Players:GetPlayers()), o2))
                xs = 0
                pcall(function()
                    xs = math.floor(oM.Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                Label:SetText(pz("Ping", tostring(xs) .. " ms", o8))
                Label4:SetText('<b>Game</b> <font color="#5a6070">-</font> <font color="#7fd47f">Sail For Eggs</font>')
                Label2:SetText(pz("Job", string.sub(game.JobId, 1, 8) .. "...", oS))
                task.wait(1)
            else
                xv = true
            end
        until xv
    end)
end
local function p3_2()
    pp(pv[2])
    local StealGroup = pv[2]:AddLeftGroupbox("Steal", "egg")
    StealGroup:AddToggle("AutoStealEgg", { Text = "Auto Steal Egg", Default = false })
    StealGroup:AddDropdown("ZoneFilter", { Text = "Zones", Values = pn, Multi = true, AllowNull = true, Default = pn })
    StealGroup:AddDropdown("StealRarityFilter", { Text = "Steal Rarities", Values = o_, Multi = true, AllowNull = true, Default = o_ })
    local PenGroup = pv[2]:AddLeftGroupbox("Pen", "house")
    PenGroup:AddToggle("AutoPlaceEgg", { Text = "Auto Place Egg", Default = false })
    PenGroup:AddToggle("AutoHatch", { Text = "Auto Hatch", Default = false })
    PenGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
    PenGroup:AddToggle("AutoUpgradePen", { Text = "Auto Upgrade Pen", Default = false })
    local EconomyGroup = pv[2]:AddRightGroupbox("Economy", "coins")
    EconomyGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
    EconomyGroup:AddDropdown("SellMode", { Text = "Sell Mode", Values = { "Animals", "Eggs", "Both" }, Default = "Animals" })
    EconomyGroup:AddDropdown("SellRarityFilter", {
        Text = "Sell Rarities",
        Values = o_,
        Multi = true,
        AllowNull = true,
        Default = { "Common", "Uncommon", "Rare" }
    })
    EconomyGroup:AddToggle("AutoBuyBoat", { Text = "Auto Buy Boat", Default = false })
    EconomyGroup:AddToggle("AutoClaimIndex", { Text = "Auto Claim Index", Default = false })
    local BoatGroup = pv[2]:AddRightGroupbox("Boat", "ship")
    BoatGroup:AddToggle("AutoRepair", { Text = "Auto Repair", Default = false })
    BoatGroup:AddToggle("AutoUpgradeBoat", { Text = "Auto Upgrade Boat", Default = false })
    Toggles.AutoStealEgg:OnChanged(function(jW)
        oP.SetAutoSteal(jW)
    end)
    Options.ZoneFilter:OnChanged(function(j_)
        oP.SetSelectedZones(j_)
    end)
    Options.StealRarityFilter:OnChanged(function(j1)
        oP.SetStealRarities(j1)
    end)
    Toggles.AutoPlaceEgg:OnChanged(function(j3)
        oP.SetAutoPlace(j3)
    end)
    Toggles.AutoHatch:OnChanged(function(j5)
        oP.SetAutoHatch(j5)
    end)
    Toggles.AutoEquipBest:OnChanged(function(j7)
        oP.SetAutoEquipBest(j7)
    end)
    Toggles.AutoUpgradePen:OnChanged(function(j9)
        oP.SetAutoUpgradePen(j9)
    end)
    Toggles.AutoSell:OnChanged(function(kb)
        oP.SetAutoSell(kb)
    end)
    Options.SellMode:OnChanged(function(kd)
        oP.SetSellMode(kd)
    end)
    Options.SellRarityFilter:OnChanged(function(kf)
        oP.SetSellRarities(kf)
    end)
    Toggles.AutoBuyBoat:OnChanged(function(kh)
        oP.SetAutoBuyBoat(kh)
    end)
    Toggles.AutoClaimIndex:OnChanged(function(kj)
        oP.SetAutoClaimIndex(kj)
    end)
    Toggles.AutoRepair:OnChanged(function(kl)
        oP.SetAutoRepair(kl)
    end)
    Toggles.AutoUpgradeBoat:OnChanged(function(kn)
        oP.SetAutoUpgradeBoat(kn)
    end)
    oP.SetSelectedZones(Options.ZoneFilter.Value)
    oP.SetStealRarities(Options.StealRarityFilter.Value)
    oP.SetSellRarities(Options.SellRarityFilter.Value)
    oP.SetSellMode(Options.SellMode.Value)
end
local function p4_3()
    pp(pv[3])
    local MovementGroup = pv[3]:AddLeftGroupbox("Movement", "person-standing")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "Noclip", Default = false })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = pv[3]:AddRightGroupbox("Fly", "plane")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    Toggles.WalkSpeedEnabled:OnChanged(function(kw)
        oP.SetWalkSpeedEnabled(kw)
    end)
    Options.WalkSpeed:OnChanged(function(kA)
        oP.SetWalkSpeedValue(kA)
    end)
    Toggles.InfJump:OnChanged(function(kC)
        oP.SetInfJump(kC)
    end)
    Toggles.NoClip:OnChanged(function(kE)
        oP.SetNoClip(kE)
    end)
    Toggles.InstantProximityPrompt:OnChanged(function(kG)
        oP.SetInstantProximityPrompt(kG)
    end)
    Toggles.Fly:OnChanged(function(kI)
        oP.SetFly(kI)
    end)
    Options.FlySpeed:OnChanged(function(kK)
        oP.SetFlySpeed(kK)
    end)
end
o4 = {
    [1] = true,
    [2] = true,
    [3] = false,
    [4] = false,
    [5] = false,
    [6] = nil,
    [7] = nil,
    [8] = {},
    [9] = {},
    [10] = nil,
    [11] = nil
}
p5 = function()
    local function kO()
        local xw = not pA(oM.VirtualUser.CaptureController) or not pA(oM.VirtualUser.ClickButton2)
        if xw then
            return false
        end
        return pcall(function()
            oM.VirtualUser:CaptureController()
            oM.VirtualUser:ClickButton2(Vector2.new())
        end)
    end
    oP.SetAntiAfk = function(kV)
        local xE = kV and true or false
        o4[1] = xE
        if o4[6] then
            o4[6]:Disconnect()
            o4[6] = nil
        end
        if o4[7] then
            pcall(task.cancel, o4[7])
            o4[7] = nil
        end
        if not o4[1] then
            return
        end
        o4[6] = LocalPlayer.Idled:Connect(function()
            local xy = ps() and o4[1]
            if xy then
                kO()
            end
        end)
        o4[7] = task.spawn(function()
            local xA = os.clock()
            while true do
                local xB = ps() and o4[1]
                if xB then
                    task.wait(1)
                    local xB_1 = not ps() or not o4[1]
                    if xB_1 then
                        break
                    end
                    if os.clock() - xA >= 60 then
                        xA = os.clock()
                        kO()
                    end
                    continue
                end
                break
            end
        end)
    end
    oP.SetNoGameplayPaused = function(ld)
        local xT
        local xV = ld and true or false
        o4[2] = xV
        if o4[11] then
            o4[11]:Disconnect()
            o4[11] = nil
        end
        if not o4[2] then
            return
        end
        xT = function()
            pcall(function()
                local RobloxGui = oM.CoreGui:FindFirstChild("RobloxGui")
                local xH = RobloxGui and RobloxGui:FindFirstChild("Notifications")
                if xH then
                    for i, descendant in ipairs(xH:GetDescendants()) do
                        local xG_2 = descendant:IsA("TextLabel") and string.find(string.lower(descendant.Text), "gameplay paused")
                        if xG_2 then
                            local Frame = descendant:FindFirstAncestorOfClass("Frame")
                            if Frame then
                                Frame.Visible = false
                            end
                        end
                    end
                end
            end)
        end
        xT()
        o4[11] = oM.CoreGui.DescendantAdded:Connect(function()
            if o4[2] then
                xT()
            end
        end)
    end
    oP.SetAutoReconnect = function(ls)
        local x2 = ls and true or false
        o4[3] = x2
        for i, v in ipairs(o4[8]) do
            v:Disconnect()
        end
        table.clear(o4[8])
        if not o4[3] then
            return
        end
        table.insert(o4[8], oM.TeleportService.TeleportInitFailed:Connect(function()
            local x_ = not ps() or not o4[3]
            if x_ then
                return
            end
            task.wait(1)
            local x__1 = ps() and o4[3]
            if x__1 then
                pcall(function()
                    oM.TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end)
            end
        end))
    end
    oP.SetDisable3D = function(lH)
        local yb = lH and true or false
        o4[4] = yb
        pcall(function()
            oM.RunService:Set3dRenderingEnabled(not o4[4])
        end)
    end
    oP.SetFpsBoost = function(lM)
        local yx
        local yz = lM and true or false
        o4[5] = yz
        if o4[10] then
            o4[10]:Disconnect()
            o4[10] = nil
        end
        local function yy_1()
            for k, v in pairs(o4[9]) do
                local yi = k
                if yi and yi.Parent then
                    for k, v in pairs(v) do
                        local yo = k
                        local yq = v
                        pcall(function()
                            yi[yo] = yq
                        end)
                    end
                end
            end
            table.clear(o4[9])
        end
        if not o4[5] then
            yy_1()
            return
        end
        yx = function(lZ)
            if o4[9][lZ] then
                return
            end
            local yr = lZ:IsA("ParticleEmitter") or lZ:IsA("Trail") or lZ:IsA("Beam") or lZ:IsA("Fire")
            local yv = if yr then 1 else 0
            local yt = 2284 * yv + 1382 * (1 - yv)
            local yu = 3960 * yv + 2331 * (1 - yv)
            if not ((yt * 1633 + yu * 3160 + yt * yu) % 16777213 == 8510799) then
                yr = lZ:IsA("Smoke")
            end
            if not yr then
                yr = lZ:IsA("Sparkles")
            end
            if yr then
                o4[9][lZ] = { Enabled = lZ.Enabled }
                lZ.Enabled = false
            end
        end
        for i, descendant in ipairs(pa:GetDescendants()) do
            yx(descendant)
        end
        if o4[9][oM.Lighting] == nil then
            o4[9][oM.Lighting] = { GlobalShadows = oM.Lighting.GlobalShadows }
            oM.Lighting.GlobalShadows = false
        end
        o4[10] = pa.DescendantAdded:Connect(function(l6)
            if o4[5] then
                yx(l6)
            end
        end)
    end
    oP.Track(function()
        oP.SetAntiAfk(false)
        oP.SetNoGameplayPaused(false)
        oP.SetAutoReconnect(false)
        oP.SetDisable3D(false)
        oP.SetFpsBoost(false)
    end)
end
local function p6()
    pp(pv[4])
    local MenuGroup = pv[4]:AddLeftGroupbox("Menu", "settings")
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    MenuGroup:AddToggle("NoGameplayPaused", { Text = "No Gameplay Paused", Default = true })
    MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
    MenuGroup:AddToggle("Disable3DRendering", { Text = "Disable 3D Rendering", Default = false })
    MenuGroup:AddToggle("FPSBoost", { Text = "FPS Boost", Default = false })
    MenuGroup:AddToggle("HideUIOnStart", { Text = "Hide UI On Start", Default = false })
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    local ScriptGroup = pv[4]:AddLeftGroupbox("Script", "scroll-text")
    ScriptGroup:AddButton({
        Text = "Unload Script",
        Func = function()
            Library:Unload()
        end
    })
    Toggles.AntiAfk:OnChanged(function(mj)
        oP.SetAntiAfk(mj)
    end)
    Toggles.NoGameplayPaused:OnChanged(function(mm)
        oP.SetNoGameplayPaused(mm)
    end)
    Toggles.AutoReconnect:OnChanged(function(mo)
        oP.SetAutoReconnect(mo)
    end)
    Toggles.Disable3DRendering:OnChanged(function(mq)
        oP.SetDisable3D(mq)
    end)
    Toggles.FPSBoost:OnChanged(function(ms)
        oP.SetFpsBoost(ms)
    end)
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("MyScriptHub")
    ThemeManager:SaveDefault("Evil Hello Kitty")
    ThemeManager:ApplyToTab(pv[4])
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    SaveManager:SetFolder("TempoHub/SailForEggs")
    SaveManager:BuildConfigSection(pv[4])
    pcall(function()
        ThemeManager:LoadDefault()
    end)
    pcall(function()
        SaveManager:LoadAutoloadConfig()
    end)
    oP.SetAntiAfk(Toggles.AntiAfk.Value)
    oP.SetNoGameplayPaused(Toggles.NoGameplayPaused.Value)
    oP.SetAutoReconnect(Toggles.AutoReconnect.Value)
    oP.SetDisable3D(Toggles.Disable3DRendering.Value)
    oP.SetFpsBoost(Toggles.FPSBoost.Value)
    oP.SetSelectedZones(Options.ZoneFilter.Value)
    oP.SetStealRarities(Options.StealRarityFilter.Value)
    oP.SetSellRarities(Options.SellRarityFilter.Value)
    oP.SetSellMode(Options.SellMode.Value)
    oP.SetAutoSteal(Toggles.AutoStealEgg.Value)
    oP.SetAutoPlace(Toggles.AutoPlaceEgg.Value)
    oP.SetAutoHatch(Toggles.AutoHatch.Value)
    oP.SetAutoEquipBest(Toggles.AutoEquipBest.Value)
    oP.SetAutoUpgradePen(Toggles.AutoUpgradePen.Value)
    oP.SetAutoSell(Toggles.AutoSell.Value)
    oP.SetAutoBuyBoat(Toggles.AutoBuyBoat.Value)
    oP.SetAutoClaimIndex(Toggles.AutoClaimIndex.Value)
    oP.SetAutoRepair(Toggles.AutoRepair.Value)
    oP.SetAutoUpgradeBoat(Toggles.AutoUpgradeBoat.Value)
    if Toggles.HideUIOnStart.Value then
        pcall(function()
            Library:Toggle(false)
        end)
    end
end
p5()
p2_7()
p3_2()
p4_3()
p6()
end)(...)

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
getgenv().TempoHoodSubtitle = "AGE EVOLUTION TYCOON"
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
local ii
local hW
local CurrentCamera
local il
local h1
local hJ
local h4
local is
local h7
local iv
local hM
local connection3
local BuyRebirth
local ia
local id
local hS
local VirtualUser
local hV
local hY
local UserInputService
local h0
local io
local Options
local hL
local h6
local connection
local hO
local HttpService
local ix
local connection4
local hU
local ig
local hX
local ij
local h_
local Library
local connection2
local iq
local LocalPlayer
local hK
local it
local Toggles
local RebirthConfig
local iw
local hQ
local iz
local ib
local SaveManager
local connection5
local function fn3()
    local j7 = hX()
    local j8 = iw()
    local j9 = {}
    for i, v in ipairs(j7) do
        local j7_1 = not v.bought
        if j7_1 ~= false then
            j7_1 = hM(v.dep)
        end
        if j7_1 then
            j7_1 = j8.money >= v.price
        end
        if j7_1 then
            table.insert(j9, v)
        end
    end
    table.sort(j9, function(bM, bN)
        return bM.price < bN.price
    end)
    return j9[1]
end
local function onImportConfigFromClipboardTex()
    local mD_1
    local mB = Options.SaveManager_ImportSource.Value or ""
    local mB_1
    local mC = tostring(mB):match("^%s*(.-)%s*$")
    if mC == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    mB_1, mD_1 = pcall(HttpService.JSONDecode, HttpService, mC)
    local mC_1 = not mB_1 or type(mD_1) ~= "table"
    local mH = if mC_1 then 1 else 0
    local mF = 3820 * mH + 1831 * (1 - mH)
    local mG = 2212 * mH + 2579 * (1 - mH)
    if not ((mF * 3049 + mG * 3408 + mF * mG) % 16777213 == 10858303) then
        mC_1 = type(mD_1.objects) ~= "table"
    end
    if mC_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local mB_2 = 0
    for i, v in ipairs(mD_1.objects) do
        if io(v) then
            mB_2 += 1
        end
    end
    if mB_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local mD_2 = mB_2 == 1 and ""
    local mQ = if mD_2 then 1 else 0
    local mO = 628 * mQ + 318 * (1 - mQ)
    local mP = 2430 * mQ + 746 * (1 - mQ)
    if not ((mO * 3895 + mP * 2338 + mO * mP) % 16777213 == 9653440) then
        mD_2 = "s"
    end
    Library:Notify(("Imported %d setting%s"):format(mB_2, mD_2), 6)
end
local function fn30()
    h_(hY, "Copied Discord invite to clipboard")
end
local function onCopyBitcoinAddress()
    h_(ix, "Copied Bitcoin address")
end
local function fn75(ex, ey)
    local Type = ey.Type
    if Type == "Toggle" then
        return { idx = ex, type = "Toggle", value = ey.Value == true }
    elseif Type == "Slider" then
        return { idx = ex, type = "Slider", value = tostring(ey.Value) }
    elseif Type == "Dropdown" then
        return { idx = ex, type = "Dropdown", multi = ey.Multi == true, value = ey.Value }
    elseif Type == "Input" then
        local l1 = ey.Value or ""
        return { idx = ex, type = "Input", text = tostring(l1) }
    elseif Type == "ColorPicker" then
        return { idx = ex, type = "ColorPicker", value = ey.Value:ToHex(), transparency = ey.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = ex,
            type = "KeyPicker",
            mode = ey.Mode,
            key = ey.Value,
            modifiers = ey.Modifiers,
            toggled = ey.Toggled
        }
    else
        return nil
    end
end
local function autoCollectIncomeLoop()
    while not Library.Unloaded do
        if Toggles.AutoCollectIncome.Value then
            local Character = LocalPlayer.Character
            local kQ = Character and Character:FindFirstChild("HumanoidRootPart")
            if kQ then
                local kQ_1 = h6()
                if kQ_1 then
                    kQ.CFrame = CFrame.new(kQ_1.Position + Vector3.new(0, 3, 0))
                end
            end
        end
        task.wait(Options.CollectInterval.Value)
    end
end
local function onUnload()
    Library:Unload()
end
local function onCopyLitecoinAddress()
    h_(hK, "Copied Litecoin address")
end
local function onRscripts()
    if setclipboard then
        setclipboard(hW)
    elseif toclipboard then
        toclipboard(hW)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function onCopyEthereumAddress()
    h_(iq, "Copied Ethereum address")
end
local function fn185(G)
    local DiscordGroup = G:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = hL })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = hL })
end
local function fn213()
    ib(false)
end
local function onRebirthNow()
    local kG = iw()
    local kH = RebirthConfig and RebirthConfig.Levels and RebirthConfig.Levels[kG.rebirth + 1]
    local kH_1 = it() and kH
    if kH_1 then
        local money = kG.money
        local kK = kH.requiredMoney
        local kO = if kK then 1 else 0
        local kM = 3338 * kO + 297 * (1 - kO)
        local kN = 3848 * kO + 1337 * (1 - kO)
        if not ((kM * 2941 + kN * 3880 + kM * kN) % 16777213 == 4037496) then
            kK = 0
        end
        kH_1 = money >= kK
    end
    if kH_1 then
        pcall(function()
            BuyRebirth:FireServer()
        end)
        Library:Notify("Rebirth triggered")
    else
        Library:Notify("Not ready to rebirth")
    end
end
local function autoRebirthLoop()
    while not Library.Unloaded do
        if Toggles.AutoRebirth.Value then
            local kY = iw()
            local kZ = kY.rebirth + 1
            if kZ <= (RebirthConfig and RebirthConfig.MaxLevel or 1000) then
                local k__2 = RebirthConfig and RebirthConfig.Levels and RebirthConfig.Levels[kZ]
                local kZ_1 = k__2
                if k__2 then
                    k__2 = kY.money >= (kZ_1.requiredMoney or 0)
                end
                if k__2 then
                    k__2 = it()
                end
                if k__2 then
                    pcall(function()
                        BuyRebirth:FireServer()
                    end)
                    task.wait(2)
                end
            end
        end
        task.wait(Options.RebirthInterval.Value)
    end
end
local function fn290(ep, eq)
    local lY_1 = (ep == "Toggle" and Toggles or Options)[eq]
    local lX_2 = type(lY_1) == "table" and lY_1.Type == ep
    return lX_2 and lY_1 or nil
end
local function onInputBegan()
    h4 = tick()
end
local function fn324()
    local Character = LocalPlayer.Character
    local k4 = Character and Character:FindFirstChildOfClass("Humanoid")
    return k4
end
local function onJumpRequest()
    if Library.Unloaded or not Toggles then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local li_2 = hQ()
        if li_2 then
            li_2:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn365()
    if not Toggles.Fly.Value then
        local ls = hQ()
        if ls then
            ls.PlatformStand = false
        end
    end
end
local function onStepped()
    if Library.Unloaded or not Toggles then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local k9_3 = descendant:IsA("BasePart") and descendant.CanCollide
                if k9_3 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn402()
    connection4:Disconnect()
    connection5:Disconnect()
    connection:Disconnect()
    connection2:Disconnect()
    connection3:Disconnect()
end
local function onCopyPayPalLink()
    h_(id, "Copied PayPal link")
end
local function fn522()
    ib(Toggles.AntiGameplayPause.Value)
end
local function onExportConfigToClipboard()
    local my_1
    local mx_1
    mx_1, my_1 = pcall(HttpService.JSONEncode, HttpService, iv())
    if not mx_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local mx_2 = setclipboard or toclipboard
    local mx_3 = type(mx_2) ~= "function" or not pcall(mx_2, my_1)
    if mx_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function fn545()
    if not Toggles.WalkSpeedEnabled.Value then
        local lx = hQ()
        if lx then
            lx.WalkSpeed = 16
        end
    end
end
local function fn555()
    local Character = LocalPlayer.Character
    local k7 = Character and Character:FindFirstChild("HumanoidRootPart")
    return k7
end
local function onCopyUSDTAddress()
    h_(il, "Copied USDT address")
end
local function worker()
    local jB_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local jA = math.floor(os.clock() - hO)
        if jA < 60 then
            jB_1 = jA .. "s"
        elseif jA < 3600 then
            jB_1 = string.format("%dm %ds", math.floor((jA) / (60)), jA % 60)
        else
            jB_1 = string.format("%dh %dm", math.floor((jA) / (3600)), math.floor((jA % 3600) / (60)))
        end
        ii:SetText(iz("Session time", jB_1, h0))
    end
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            ib(true)
        end
    end
end
local function fn619(bA)
    if bA == 0 then
        return true
    end
    return ig("Button" .. bA) == true
end
local function fn646()
    local jr_1
    local jq_1
    if identifyexecutor then
        jr_1, jq_1 = identifyexecutor()
        local js = jr_1 ~= ""
        local jt = type(jr_1) == "string" and js
        if jt then
            local js_1 = type(jq_1) == "string" and jq_1 ~= "" and jr_1 .. " " .. jq_1
            hV = js_1 or jr_1
        end
    end
end
local function onInputChanged(d3)
    local UserInputType = d3.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        h4 = tick()
    end
end
local function fn671(P, Q, R)
    return string.format("<b>%s</b> %s %s", P, hS("-", "#5a6070"), hS(Q, R))
end
local function fn678()
    local ma = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local mb = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if mb then
                local mb_1 = hU(k, v)
                if mb_1 then
                    ma[#ma + 1] = mb_1
                end
            end
        end
    end
    table.sort(ma, function(eK, eL)
        if eK.type ~= eL.type then
            return eK.type < eL.type
        end
        return eK.idx < eL.idx
    end)
    return { objects = ma }
end
local function onCopyVenmoLink()
    h_(h7, "Copied Venmo link")
end
local function fn683(x, y)
    if setclipboard then
        setclipboard(x)
    elseif toclipboard then
        toclipboard(x)
    end
    Library:Notify(y)
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local lT = tick() - h4
            local lU = tick() - h1
            if lT >= 300 and lU >= 60 then
                pcall(hJ)
            else
                if lT < 300 and lU >= 300 then
                    pcall(hJ)
                end
            end
        end
    end
end
local function fn710(M, N)
    return string.format('<font color="%s">%s</font>', N, M)
end
local function fn714()
    local kh = hX()
    for i, v in ipairs(kh) do
        if not v.bought then
            return false
        end
    end
    return #kh > 0
end
local function onCopyJoinScript_JobID()
    local jy = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, ia)
    if setclipboard then
        setclipboard(jy)
    elseif toclipboard then
        toclipboard(jy)
    end
    Library:Notify("Copied join script to clipboard")
end
local function onCopySolanaAddress()
    h_(ij, "Copied Solana address")
end
local function onRenderStepped(dl)
    if Library.Unloaded or not Toggles or not Options then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local ll_3 = hQ()
        if ll_3 then
            ll_3.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local ll_5 = is()
        local lm_1 = hQ()
        if ll_5 and lm_1 then
            lm_1.PlatformStand = true
            local lm_2 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                lm_2 = lm_2 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                lm_2 = lm_2 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                lm_2 = lm_2 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                lm_2 = lm_2 + CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                lm_2 = lm_2 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                lm_2 = lm_2 - Vector3.new(0, 1, 0)
            end
            ll_5.Velocity = Vector3.zero
            if lm_2.Magnitude > 0 then
                ll_5.CFrame = ll_5.CFrame + lm_2.Unit * Options.FlySpeed.Value * dl
            end
        end
    end
end
local function fn733()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    h1 = tick()
end
hJ = nil
hK = nil
hL = nil
hM = nil
RebirthConfig = nil
hO = nil
connection3 = nil
hQ = nil
hS = nil
connection5 = nil
hU = nil
hV = nil
hW = nil
hX = nil
hY = nil
CurrentCamera = nil
h_ = nil
h0 = nil
h1 = nil
connection2 = nil
Options = nil
h4 = nil
LocalPlayer = nil
h6 = nil
h7 = nil
Toggles = nil
HttpService = nil
ia = nil
ib = nil
connection4 = nil
id = nil
SaveManager = nil
ig = nil
VirtualUser = nil
ii = nil
ij = nil
UserInputService = nil
il = nil
Library = nil
io = nil
iq = nil
is = nil
it = nil
connection = nil
iv = nil
iw = nil
ix = nil
local Stat, ip, ir
BuyRebirth = nil
iz = nil
local FaqGroup
local MenuGroup
local iL_1
local iE_1
local i1_1
local iC_1, iC_2
UserInputService, VirtualUser, HttpService, LocalPlayer, hY, hW, Stat, RebirthConfig, BuyRebirth, Library, SaveManager, Toggles, Options, h_, hL = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local iF_1
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
LocalPlayer = Players.LocalPlayer
local iH = "Age Evolution Tycoon"
hY = "https://discord.gg/K7Qxnxkk46"
hW = "https://discord.gg/K7Qxnxkk46"
Stat = require(ReplicatedStorage:WaitForChild("Stat"))
RebirthConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Secondary"):WaitForChild("RebirthConfig"))
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local AccountGroup, iB_3
BuyRebirth = RemoteEvents:WaitForChild("BuyRebirth")
setthreadidentity(8)
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
h_ = fn683
hL = fn30
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = hY, Copyable = true }, "|", iH },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
local iD_1
local iJ = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gavel"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in iJ do
    fn185(v)
end
iF_1, iE_1, h0, iD_1, hV, AccountGroup, iL_1, ii, ia, iC_1, hS, iz = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local iA_1 = 62
repeat
    local iG_1 = (iA_1 * 3 + 3) % 8 + 1
    if iG_1 <= 4 then
        if iG_1 <= 2 then
            if iG_1 <= 1 then
                local iM_1 = {
                    "xmwzvyw",
                    "opiwowdt",
                    "gznoaptmdsx",
                    "ayq",
                    "yyndl",
                    "cszamzxxmfb",
                    "zyzgqpyzsvx",
                    "jrkcrnmnwqz",
                    "qgib",
                    "kkaabuwnmw",
                    "apzi"
                }
                local ns = iA_1
                local iN_1 = iM_1[ns % 11 + 1]
                if iN_1:len() >= iN_1:gsub("(.)", "%1%1", ns % 3 % 2 + 1):len() then
                    iL_1 = "#6ec1ff"
                else
                    iE_1 = "#6ec1ff"
                end
                iA_1 = (iA_1 + 51) % 64
            else
                local iM_2 = { "azz", "apqbpz", "qsjkgc", "rhqtmgsy", "vregyrth", "ltzcfqz", "kkjcfiuqbf", "invj" }
                local np = iA_1
                local iN_2 = iM_2[np % 8 + 1]
                if iN_2:len() <= iN_2:gsub("(.)", "%1%1", np % 3 % 2 + 1):len() then
                    h0 = "#e8a34d"
                else
                    hV = "#e8a34d"
                end
                iA_1 = (iA_1 + 3) % 64
            end
        elseif iG_1 <= 3 then
            local iM_3 = (vector.create((iA_1 * 5 + 4) % 11 + 1, (iA_1 * 1 + 1) % 13 + 1, (iA_1 * 1 + 2) % 17 + 1))
            local iN_3 = (vector.create((iA_1 * 2 + 7) % 11 + 1, (iA_1 * 5 + 10) % 13 + 1, (iA_1 * 10 + 13) % 17 + 1))
            local nx = vector.cross(iM_3, iN_3)
            local ny = vector.dot(iM_3, iN_3)
            if vector.dot(nx, nx) + ny * ny == vector.dot(iM_3, iM_3) * vector.dot(iN_3, iN_3) then
                iD_1 = "#8b93a3"
                hV = "Unknown"
                pcall(fn646)
                AccountGroup = iJ.Info:AddLeftGroupbox("Account", "circle-user")
                AccountGroup:AddLabel(iz("User", LocalPlayer.Name, iF_1), true)
                AccountGroup:AddLabel(iz("Status", "Keyless", iF_1), true)
                AccountGroup:AddLabel(iz("Executor", hV, iF_1), true)
                iL_1 = iJ.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                iL_1:AddLabel(hS(iH .. " [" .. tostring(game.PlaceId) .. "]", iE_1), true)
                iL_1:AddLabel(iz("Place ID", tostring(game.PlaceId), iE_1), true)
                ii = iL_1:AddLabel(iz("Session time", "0s", h0), true)
            else
                iz = "#8b93a3"
                iE_1 = "Unknown"
                pcall(fn646)
                ii = iD_1.Info:AddLeftGroupbox("Account", "circle-user")
                ii:AddLabel(iF_1("User", hS.Name, LocalPlayer), true)
                ii:AddLabel(iF_1("Status", "Keyless", LocalPlayer), true)
                ii:AddLabel(iF_1("Executor", "Unknown", LocalPlayer), true)
                hV = iD_1.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                hV:AddLabel(iL_1(iJ .. " [" .. tostring(game.PlaceId) .. "]", AccountGroup), true)
                hV:AddLabel(iF_1("Place ID", tostring(game.PlaceId), AccountGroup), true)
                h0 = hV:AddLabel(iF_1("Session time", "0s", iH), true)
            end
            iA_1 = (iA_1 + 59) % 64
        else
            local iM_4 = {
                "gmkoq",
                "csavqgz",
                "bdnewaoji",
                "hphnprcdwj",
                "qmclhd",
                "sftbdczhyb",
                "ruwgkqhej",
                "kfdwjnwla",
                "zhhy",
                "vxfxervlau"
            }
            local nT = iA_1
            local iN_4 = iM_4[nT % 10 + 1]
            if iN_4:len() >= iN_4:reverse():rep(nT % 3 + 2):len() then
                iF_1 = tostring(game.JobId)
            else
                ia = tostring(game.JobId)
            end
            iA_1 = (iA_1 + 59) % 64
        end
    elseif iG_1 <= 6 then
        if iG_1 <= 5 then
            if (iA_1 * 3 + 5) * 17 % 4 == ((iA_1 * 3 + 5) * 17 + 9) % 4 then
                ia = #iC_1 > 18
            else
                iC_1 = #ia > 18
            end
            iA_1 = (iA_1 + 27) % 64
        else
            local iM_5 = { "zglp", "skuku", "jlawfdro", "wghsvfgxr", "geg", "dbaf", "vbvzytdhzvh", "jruruoyew", "jutoazvo" }
            local nY = iA_1
            local iN_5 = iM_5[nY % 9 + 1]
            if iN_5:len() <= iN_5:gsub("(.)", "%1%1", nY % 3 % 2 + 1):len() then
                hS = fn710
            else
                iz = fn710
            end
            iA_1 = (iA_1 + 51) % 64
        end
    elseif iG_1 <= 7 then
        if (iA_1 * 2 + 1) * 16 % 3 == ((iA_1 * 2 + 1) * 16 + 3) % 3 then
            iz = fn671
        else
            hV = fn671
        end
        iA_1 = (iA_1 + 43) % 64
    else
        local nz = bit32.rrotate(bit32.bxor(bit32.lrotate(iA_1, 31), string.byte(tostring(iC_1))), 23)
        if bit32.bxor(bit32.lrotate(bit32.bxor(nz, 1578596006), 26), 2574802394) ~= bit32.lrotate(nz, 26) then
            hV = "#7fd47f"
        else
            iF_1 = "#7fd47f"
        end
        iA_1 = (iA_1 + 35) % 64
    end
until (iA_1 * 53 + 7) % 64 == 5
if iC_1 then
    local iA_2 = 7
    repeat
        local iB_2 = {
            "najykh",
            "mndclmn",
            "iczgl",
            "jqbhzqspdlxp",
            "nox",
            "hwehbueqmz",
            "gqmvccw",
            "fvumfapcapqb",
            "flivfcatonu",
            "zsslo",
            "uwsxlxqg",
            "fmqyh"
        }
        if iB_2[(iA_2 * 62 + 55) % 12 + 1] <= iB_2[(iA_2 * 62 + 55) % 12 + 1] then
            iC_1 = string.sub(ia, 1, 18) .. "..."
        else
            ia = string.sub(iC_1, 1, 18) .. "..."
        end
        iA_2 = (iA_2 + 4) % 8
    until (iA_2 * 7 + 4) % 8 == 1
end
local iA_3 = iC_1
local ji = if iA_3 then 1 else 0
local jg = 1869 * ji + 1853 * (1 - ji)
local jh = 1977 * ji + 2932 * (1 - ji)
if not ((jg * 1090 + jh * 3367 + jg * jh) % 16777213 == 12388782) then
    iA_3 = ia
end
hO, hK, ix, iq, il, ij, id, h7, iC_2, iB_3, i1_1, FaqGroup, connection, connection2, CurrentCamera, connection3, MenuGroup, h4, h1, connection4, connection5, ig, iw, hX, hM, ip, it, h6, hQ, is, ib, hJ, ir, hU, iv, io = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local iV = iA_3
iL_1:AddLabel(iz("Server", iV, iD_1), true)
iL_1:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
hO = os.clock()
task.spawn(worker)
local ScriptsGroup = iJ.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(hS("Included in this hub", iD_1), true)
ScriptsGroup:AddLabel(hS(iH, iE_1), true)
local FeaturesGroup = iJ.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(hS("Auto Collect Income", iE_1), true)
FeaturesGroup:AddLabel(hS("Auto Buy Buttons", h0), true)
FeaturesGroup:AddLabel(hS("Auto Rebirth", iF_1), true)
FeaturesGroup:AddLabel(hS("Player Movement", iD_1), true)
local SocialsGroup = iJ.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = hL })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = iJ.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = hL })
hK = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
ix = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
iq = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
il = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
ij = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
id = ""
h7 = ""
local iW = "#345d9d"
local iT = "#f7931a"
local iP = "#627eea"
local iN_6 = "#26a17b"
local iM_6 = "#14f195"
if ((not hU or ij) and (ij and not hU) or "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp" and (not hU or not hU)) and not ((not hU or ij) and (ij and not hU) or "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp" and (not hU or not hU)) then
    iJ = FaqGroup.Info:AddRightGroupbox("Donations", "heart")
    iJ:AddLabel(iD_1("All donations are optional but appreciated.", iC_2), true)
    iJ:AddLabel(iD_1("If you donate you get a special role, just PING after you donate.", iT), true)
    iJ:AddDivider()
    iJ:AddLabel(iD_1("LTC / Litecoin", h0), true)
    iJ:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
    iJ:AddLabel(iD_1("BTC / Bitcoin", iB_3), true)
    iJ:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
    iJ:AddLabel(iD_1("ETH / Ethereum", iM_6), true)
    iJ:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
    iJ:AddLabel(iD_1("USDT", hS), true)
    iJ:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
    iJ:AddLabel(iD_1("Solana", iP), true)
    iJ:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
    iJ:AddLabel(iD_1("PayPal", "#0070ba"), true)
    iJ:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
    iJ:AddLabel(iD_1("Venmo", "#008cff"), true)
    iJ:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
    iJ:AddDivider()
    iJ:AddLabel(iD_1("Don't have any of the listed currencies but still wanna donate?", ig), true)
    iJ:AddLabel(iD_1("DM me and we'll work something out.", i1_1), true)
    local FaqGroup = FaqGroup.Info:AddRightGroupbox("FAQ", "circle-help")
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
else
    local DonationsGroup = iJ.Info:AddRightGroupbox("Donations", "heart")
    DonationsGroup:AddLabel(hS("All donations are optional but appreciated.", h0), true)
    DonationsGroup:AddLabel(hS("If you donate you get a special role, just PING after you donate.", iF_1), true)
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(hS("LTC / Litecoin", iW), true)
    DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
    DonationsGroup:AddLabel(hS("BTC / Bitcoin", iT), true)
    DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
    DonationsGroup:AddLabel(hS("ETH / Ethereum", iP), true)
    DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
    DonationsGroup:AddLabel(hS("USDT", iN_6), true)
    DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
    DonationsGroup:AddLabel(hS("Solana", iM_6), true)
    DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
    DonationsGroup:AddLabel(hS("PayPal", "#0070ba"), true)
    DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
    DonationsGroup:AddLabel(hS("Venmo", "#008cff"), true)
    DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(hS("Don't have any of the listed currencies but still wanna donate?", iD_1), true)
    DonationsGroup:AddLabel(hS("DM me and we'll work something out.", iE_1), true)
    FaqGroup = iJ.Info:AddRightGroupbox("FAQ", "circle-help")
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
    ig = function(a3)
        local jF_1
        local jE_1
        jE_1, jF_1 = pcall(function()
            return Stat.Get(LocalPlayer, a3)
        end)
        if jE_1 and jF_1 then
            return jF_1.Value
        end
        return nil
    end
end
iw = function()
    local Value
    local jM = ig("Money") or 0
    local jM_1 = ig("Rebirth") or 0
    Value = nil
    pcall(function()
        Value = LocalPlayer.TempValues.Plot.Value
    end)
    return { money = jM, rebirth = jM_1, plotNum = Value }
end
hX = function()
    local jQ
    jQ = nil
    local jS_1
    local jR_1
    jQ = iw()
    if not jQ.plotNum then
        return {}
    end
    jR_1, jS_1 = pcall(function()
        return workspace:WaitForChild("Plots"):FindFirstChild(tostring(jQ.plotNum))
    end)
    if not jR_1 or not jS_1 then
        return {}
    end
    local Buttons = jS_1:FindFirstChild("Buttons")
    if not Buttons then
        return {}
    end
    local jS_2 = {}
    for i, child in ipairs(Buttons:GetChildren()) do
        if child:IsA("BasePart") then
            local Price = child:FindFirstChild("Price")
            local UnlockedByButton = child:FindFirstChild("UnlockedByButton")
            local insert = table.insert
            local jV = tonumber(child.Name) or 0
            local jR_4 = Price and Price.Value or 0
            local jT_2 = UnlockedByButton and UnlockedByButton.Value or 0
            insert(jS_2, {
                id = jV,
                part = child,
                price = jR_4,
                dep = jT_2,
                bought = ig("Button" .. child.Name) == true,
                position = child.Position
            })
        end
    end
    return jS_2
end
hM = fn619
ip = fn3
it = fn714
h6 = function()
    local kp
    kp = nil
    local kr_1
    local kq_1
    kp = iw()
    if not kp.plotNum then
        return nil
    end
    kq_1, kr_1 = pcall(function()
        return workspace:WaitForChild("Plots"):FindFirstChild(tostring(kp.plotNum))
    end)
    if not kq_1 or not kr_1 then
        return nil
    end
    local CollectorParts = kr_1:FindFirstChild("CollectorParts")
    if not CollectorParts then
        return nil
    end
    for i, child in ipairs(CollectorParts:GetChildren()) do
        local kq_3 = child:IsA("BasePart") and child.Name == "Collector" and child.Position.Y < 5
        if kq_3 then
            return child
        end
    end
    return nil
end
local IncomeCollectionGroup = iJ.Main:AddLeftGroupbox("Income Collection", "coins")
IncomeCollectionGroup:AddToggle("AutoCollectIncome", { Text = "Auto Collect Income", Default = false })
IncomeCollectionGroup:AddSlider("CollectInterval", { Text = "Collect Interval", Default = 1, Min = 0.1, Max = 5, Rounding = 1, Suffix = "s" })
local ButtonPurchasingGroup = iJ.Main:AddRightGroupbox("Button Purchasing", "shopping-cart")
ButtonPurchasingGroup:AddToggle("AutoBuy", { Text = "Auto Buy Buttons", Default = false })
ButtonPurchasingGroup:AddSlider("BuyInterval", { Text = "Buy Interval", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Suffix = "s" })
ButtonPurchasingGroup:AddButton({
    Text = "Buy Next Button Now",
    Func = function()
        local kD = ip()
        if kD then
            local kE = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local kC = kE
            if kC then
                kC.CFrame = CFrame.new(kD.position + Vector3.new(0, 3, 0))
                task.wait(0.15)
                pcall(function()
                    firetouchinterest(kC, kD.part, 0)
                    task.wait(0.05)
                    firetouchinterest(kC, kD.part, 1)
                end)
                Library:Notify("Bought button " .. kD.id)
            end
        else
            Library:Notify("No buyable buttons")
        end
    end
})
local RebirthGroup = iJ.Main:AddLeftGroupbox("Rebirth", "refresh-cw")
RebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
RebirthGroup:AddSlider("RebirthInterval", { Text = "Rebirth Check Interval", Default = 3, Min = 1, Max = 10, Rounding = 1, Suffix = "s" })
RebirthGroup:AddButton({ Text = "Rebirth Now", DoubleClick = true, Func = onRebirthNow })
task.spawn(autoCollectIncomeLoop)
task.spawn(function()
    local kX = false
    repeat
        if not Library.Unloaded then
            if Toggles.AutoBuy.Value then
                local kS = ip()
                if kS then
                    local kU = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local kT = kU
                    if kT then
                        kT.CFrame = CFrame.new(kS.position + Vector3.new(0, 3, 0))
                        task.wait(0.15)
                        pcall(function()
                            firetouchinterest(kT, kS.part, 0)
                            task.wait(0.05)
                            firetouchinterest(kT, kS.part, 1)
                        end)
                        task.wait(0.3)
                    end
                end
            end
            task.wait(Options.BuyInterval.Value)
        else
            kX = true
        end
    until kX
end)
task.spawn(autoRebirthLoop)
local MovementGroup = iJ.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = iJ.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
hQ = fn324
is = fn555
connection = RunService.Stepped:Connect(onStepped)
connection2 = UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
connection3 = RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn365)
Toggles.WalkSpeedEnabled:OnChanged(fn545)
ib = function(dF)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not dF)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not dF
        end
    end)
    if not dF then
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
if (false and (iw or not connection5) or (false or (false or not FaqGroup))) and (false and connection5 or (false or iw) or FaqGroup and FaqGroup and false) and not ((false and (iw or not connection5) or (false or (false or not FaqGroup))) and (false and connection5 or (false or iw) or FaqGroup and FaqGroup and false)) then
    Library.AntiGameplayPause:OnChanged(fn522)
    task.spawn(antiGameplayPauseLoop)
    MenuGroup:OnUnload(fn213)
    iJ = Toggles.Settings:AddLeftGroupbox("Menu")
else
    Toggles.AntiGameplayPause:OnChanged(fn522)
    task.spawn(antiGameplayPauseLoop)
    Library:OnUnload(fn213)
    MenuGroup = iJ.Settings:AddLeftGroupbox("Menu")
end
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
h4 = tick()
h1 = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local lK = v
        pcall(function()
            lK:Disable()
        end)
    end
end)
hJ = fn733
connection4 = UserInputService.InputBegan:Connect(onInputBegan)
connection5 = UserInputService.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(antiAfkLoop)
MenuGroup:AddButton("Unload", onUnload)
Library:OnUnload(fn402)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Linoria")
ThemeManager:ApplyToTab(iJ.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/AgeEvolutionTycoon")
local i3 = SaveManager:BuildConfigSection(iJ.Settings)
SaveManager:LoadAutoloadConfig()
ir = fn290
hU = fn75
iv = fn678
io = function(eN)
    local mu
    mu = nil
    local mv = type(eN) ~= "table" or type(eN.idx) ~= "string" or type(eN.type) ~= "string" or SaveManager.Ignore[eN.idx]
    if mv then
        return false
    end
    mu = ir(eN.type, eN.idx)
    if not mu then
        return false
    end
    local mv_1 = pcall(function()
        if eN.type == "Input" then
            if type(eN.text) ~= "string" then
                return
            end
            mu:SetValue(eN.text)
        elseif eN.type == "ColorPicker" then
            mu:SetValueRGB(Color3.fromHex(eN.value), eN.transparency)
        elseif eN.type == "KeyPicker" then
            mu:SetValue({ eN.key, eN.mode, eN.modifiers })
            if eN.mode == "Toggle" and eN.toggled ~= nil then
                mu.Toggled = eN.toggled
                mu:Update()
            end
        else
            mu:SetValue(eN.value)
        end
    end)
    return mv_1
end
if (FeaturesGroup or not FeaturesGroup or (not FeaturesGroup or MovementGroup)) and (FeaturesGroup and not MovementGroup or FeaturesGroup and MovementGroup) and not ((FeaturesGroup or not FeaturesGroup or (not FeaturesGroup or MovementGroup)) and (FeaturesGroup and not MovementGroup or FeaturesGroup and MovementGroup)) then
    i3:AddDivider()
    i3:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    i3:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    i3:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
else
    i3:AddDivider()
    i3:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    i3:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    i3:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
end
end)(...)

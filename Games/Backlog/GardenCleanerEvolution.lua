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
getgenv().TempoHoodSubtitle = "GARDEN CLEANER EVOLUTION"
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
local Label6
local iZ
local iG
local MaxHold
local i4
local Leaves
local bodyGyro
local h8
local Label3
local iz
local UserInputService
local iF
local il
local Options
local iL
local bodyVelocity
local h7
local iy
local connection4
local iX
local iE
local iK
local ir
local i8
local h6
local VirtualUser
local connection5
local iD
local Cash
local Label2
local iJ
local Label5
local UpgradeLevels
local connection2
local Toggles
local connection
local iV
local iC
local i0
local SellZones
local i6
local Areas
local iv
local Label
local ia
local Rebirth
local connection3
local HiddenData
local iH
local io
local i5
local iN
local Library
local LeafData
local RebirthEvent
local Label4
local function fn32(at)
    local jW = Options[at]
    local jX = jW and jW.Value
    local jW_1 = {}
    local jY = jX
    local j1 = if jY then 1 else 0
    local j_ = 2470 * j1 + 886 * (1 - j1)
    local j0 = 2316 * j1 + 3152 * (1 - j1)
    if not ((j_ * 2012 + j0 * 192 + j_ * j0) % 16777213 == 11134832) then
        jY = jW_1
    end
    return jY
end
local function fn63(a9, ba, bb)
    local kr = {}
    for k, v in LeafData.leaves do
        if #kr >= a9 then
            break
        elseif not v.pickedUp then
            local ks = v.areaName or "Unknown"
            if bb or ba[ks] then
                LeafData.MarkPickedUp(k)
                table.insert(kr, { AreaName = ks, IsLucky = false })
            end
        end
    end
    return kr
end
local function fn232(an, ao)
    local jT = Options[an]
    local jU = jT and tonumber(jT.Value)
    return jU or ao
end
local function fn236()
    iX(iK, "Copied Discord invite to clipboard")
end
local function fn255(bH)
    local DiscordGroup = bH:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = iC })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = iC })
end
local function fn362()
    local kp_3
    if iZ("Capacity") < 5 then
        return false
    elseif Rebirth.Value >= 1 then
        local BasementCapacityLevel = UpgradeLevels:FindFirstChild("BasementCapacityLevel")
        if not BasementCapacityLevel or BasementCapacityLevel.Value < 4 then
            return false
        end
        HiddenData:FindFirstChild("HasClearedPlotThisRebirth")
        if kp_3 then
            return true
        end
        return iy() >= 0.999
    else
        local HasClearedPlotThisRebirth = HiddenData:FindFirstChild("HasClearedPlotThisRebirth")
        kp_3 = HasClearedPlotThisRebirth and HasClearedPlotThisRebirth.Value == true
        if kp_3 then
            return true
        end
        return iy() >= 0.999
    end
end
local function fn377(aN)
    local j5 = UpgradeLevels:FindFirstChild(aN .. "Level")
    return j5 and j5.Value or 1
end
local function fn390()
    local ka_1
    local j9_1
    local SavedLeafCounts = HiddenData:FindFirstChild("SavedLeafCounts")
    if not SavedLeafCounts then
        return 0
    end
    ka_1, j9_1 = 0, 0
    for i, child in Areas:GetChildren() do
        if child:IsA("Folder") then
            local kb = child:GetAttribute("LeafAmount") or 50
            ka_1 += kb
            local kb_1 = SavedLeafCounts:FindFirstChild(child.Name)
            local kb_2 = kb_1 and kb_1.Value or kb
            j9_1 += kb_2
        end
    end
    return ka_1 > 0 and (ka_1 - j9_1) / ka_1 or 0
end
local function fn394()
    local kS_1
    local kR_1
    local kQ = h8()
    if not kQ then
        return nil
    end
    kS_1, kR_1 = nil, math.huge
    for i, child in SellZones:GetChildren() do
        local kT = child:FindFirstChild("Bin") or child:FindFirstChild("Part")
        local kU = kT
        if kT then
            kT = kU:IsA("BasePart")
        end
        if kT then
            local Magnitude = (kU.Position - kQ.Position).Magnitude
            if Magnitude < kR_1 then
                kR_1 = Magnitude
                kS_1 = kU
            end
        end
    end
    return kS_1
end
local function fn420(P, Q)
    if setclipboard then
        setclipboard(P)
    elseif toclipboard then
        toclipboard(P)
    end
    Library:Notify(Q)
end
local function fn492()
    Library.ScreenGui.Parent = iJ:WaitForChild("PlayerGui")
end
local function fn495()
    local Character = iJ.Character
    local j3 = Character and Character:FindFirstChild("HumanoidRootPart")
    return j3
end
local function fn520(ai)
    local jQ = Toggles[ai]
    return jQ ~= nil and jQ.Value == true
end
local function fn564()
    local k5_1
    local k4_1
    if identifyexecutor then
        k5_1, k4_1 = identifyexecutor()
        local k6 = k5_1 ~= ""
        local k7 = type(k5_1) == "string" and k6
        if k7 then
            local k6_1 = type(k4_1) == "string" and k4_1 ~= "" and k5_1 .. " " .. k4_1
            iF = k6_1 or k5_1
        end
    end
end
local function fn581(Z, aa, ab)
    return string.format("<b>%s</b> %s %s", Z, io("-", "#5a6070"), io(aa, ab))
end
local function fn609(W, X)
    return string.format('<font color="%s">%s</font>', X, W)
end
local function fn684(bj)
    local kF_1
    local kE_1
    local kD = Areas:FindFirstChild(bj)
    if not kD then
        return nil
    end
    kF_1, kE_1 = nil, 0
    for i, descendant in kD:GetDescendants() do
        local kD_1 = descendant:IsA("BasePart") and descendant.Name == "Part"
        if kD_1 then
            local kD_2 = descendant.Size.X * descendant.Size.Z
            if kD_2 > kE_1 then
                kE_1 = kD_2
                kF_1 = descendant
            end
        end
    end
    if not kF_1 then
        return nil
    end
    return kF_1.Position + Vector3.new(0, kF_1.Size.Y / 2 + 4, 0)
end
h6 = nil
h7 = nil
h8 = nil
RebirthEvent = nil
ia = nil
connection = nil
connection4 = nil
Label6 = nil
connection3 = nil
Cash = nil
il = nil
MaxHold = nil
io = nil
Label5 = nil
ir = nil
Leaves = nil
Library = nil
iv = nil
iy = nil
iz = nil
Label4 = nil
iC = nil
iD = nil
iE = nil
iF = nil
iG = nil
iH = nil
SellZones = nil
iJ = nil
iK = nil
iL = nil
iN = nil
Areas = nil
connection2 = nil
VirtualUser = nil
Label3 = nil
Rebirth = nil
iV = nil
local ic, BuyEquipment, ii, UpgradeRequest, LeafPickedUp, is, iw, ix, BasementUpgrades, iM, iR, BasementUpgradeManager
iX = nil
UserInputService = nil
iZ = nil
HiddenData = nil
i0 = nil
Label2 = nil
Options = nil
i4 = nil
i5 = nil
i6 = nil
UpgradeLevels = nil
i8 = nil
bodyVelocity = nil
bodyGyro = nil
LeafData = nil
Label = nil
Toggles = nil
connection5 = nil
local ShopConfig, UpgradeManager
local SaveManager
local jl_1
local jk_1
UserInputService, VirtualUser, iJ = nil, nil, nil
local Players = game:GetService("Players")
local Window, AccountGroup
local ReplicatedStorage = game:GetService("ReplicatedStorage")
UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
if (UserInputService or not VirtualUser) and (iJ and not Players) and (iJ and not Players or Players and ReplicatedStorage) or not ((UserInputService or not VirtualUser) and (iJ and not Players) and (iJ and not Players or Players and ReplicatedStorage)) then
    VirtualUser = game:GetService("VirtualUser")
    iJ = Players.LocalPlayer
else
    iJ = game:GetService("VirtualUser")
end
if getgenv then
    getgenv().gethui = function()
        return iJ:WaitForChild("PlayerGui")
    end
end
LeafPickedUp, UpgradeRequest, BuyEquipment, RebirthEvent, LeafData, UpgradeManager, ShopConfig, BasementUpgradeManager, Areas, SellZones, BasementUpgrades, Leaves, MaxHold, Cash, UpgradeLevels, HiddenData, Rebirth, iK, iG, Library, SaveManager, Toggles, Options, iL, iH, iz, iv, iX, iC, io, h7, ir, i6, ix, h8 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local jj_1
local jf_1 = ReplicatedStorage:WaitForChild("Modules")
LeafPickedUp = Remotes:WaitForChild("LeafPickedUp")
UpgradeRequest = Remotes:WaitForChild("UpgradeRequest")
BuyEquipment = Remotes:WaitForChild("BuyEquipment")
RebirthEvent = Remotes:WaitForChild("RebirthEvent")
LeafData = require(jf_1:WaitForChild("LeafData"))
if (BasementUpgradeManager or not BasementUpgradeManager or (UpgradeManager or not Options) or (not Options and Toggles)) and (not iX and Toggles and (not Toggles or not Toggles) or (Toggles and Toggles or 98)) or not ((BasementUpgradeManager or not BasementUpgradeManager or (UpgradeManager or not Options) or (not Options and Toggles)) and (not iX and Toggles and (not Toggles or not Toggles) or (Toggles and Toggles or 98))) then
    UpgradeManager = require(jf_1:WaitForChild("UpgradeManager"))
else
    jf_1 = require(UpgradeManager:WaitForChild("UpgradeManager"))
end
ShopConfig = require(jf_1:WaitForChild("ShopConfig"))
BasementUpgradeManager = require(jf_1:WaitForChild("BasementUpgradeManager"))
Areas = workspace:WaitForChild("Areas")
SellZones = workspace:WaitForChild("SellZones")
BasementUpgrades = workspace:WaitForChild("BasementUpgrades")
local PlayerData = iJ:WaitForChild("PlayerData")
Leaves = PlayerData:WaitForChild("Leaves")
MaxHold = PlayerData:WaitForChild("MaxHold")
Cash = PlayerData:WaitForChild("Cash")
local hasRake = PlayerData:WaitForChild("hasRake")
local jm = PlayerData:WaitForChild("hasLeafblower")
UpgradeLevels = PlayerData:WaitForChild("UpgradeLevels")
HiddenData = iJ:WaitForChild("HiddenData")
Rebirth = iJ:WaitForChild("leaderstats"):WaitForChild("Rebirth")
local jo = "Garden Cleaner Evolution"
if ((iC and not Leaves or Cash and Cash) and (BasementUpgrades and not iX and (not BasementUpgrades or not iC)) or (iX and iX or iX and not Cash or (iC and not iX or BasementUpgrades and UpgradeLevels))) and not ((iC and not Leaves or Cash and Cash) and (BasementUpgrades and not iX and (not BasementUpgrades or not iC)) or (iX and iX or iX and not Cash or (iC and not iX or BasementUpgrades and UpgradeLevels))) then
    iG = "https://discord.gg/K7Qxnxkk46"
    iK = "https://discord.gg/K7Qxnxkk46"
else
    iK = "https://discord.gg/K7Qxnxkk46"
    iG = "https://discord.gg/K7Qxnxkk46"
end
Library = getgenv().Library
pcall(fn492)
local ThemeManager = getgenv().ThemeManager
if (Areas or Areas) and (not Areas or not Areas) and (i6 and not Areas or (not Areas or not i6)) or (not i6 and not Areas and (not Areas or not Areas) or i6 and not i6 and (not i6 or not Areas)) or not ((Areas or Areas) and (not Areas or not Areas) and (i6 and not Areas or (not Areas or not i6)) or (not i6 and not Areas and (not Areas or not Areas) or i6 and not i6 and (not i6 or not Areas))) then
    SaveManager = getgenv().SaveManager
else
    local _ = getgenv().SaveManager
end
Toggles = Library.Toggles
Options = Library.Options
iX = fn420
iC = fn236
io = fn609
h7 = fn581
iL = "#7fd47f"
iH = "#6ec1ff"
iz = "#e8a34d"
iv = "#8b93a3"
ir = fn520
i6 = fn232
ix = fn32
h8 = fn495
local jp = {}
for i, child in Areas:GetChildren() do
    local jf_2 = child:IsA("Folder") or child:IsA("Model")
    if jf_2 then
        table.insert(jp, child.Name)
    end
end
iw, is, il, ii, ia, h6 = nil, nil, nil, nil, nil, nil
table.sort(jp)
iw = {
    "Capacity",
    "Yield",
    "Cooldown",
    "RakeSpeed",
    "RakeArea",
    "RakeRange",
    "BlowerRange",
    "BlowerRadius",
    "BlowerCooldown"
}
if not ii and not il and (not il and not il) and (ia or not ia or not ia and not iw) or not (not ii and not il and (not il and not il) and (ia or not ia or not ia and not iw)) then
    is = {
        RakeSpeed = hasRake,
        RakeArea = hasRake,
        RakeRange = hasRake,
        BlowerRange = jm,
        BlowerRadius = jm,
        BlowerCooldown = jm
    }
else
    jm = {
        RakeSpeed = is,
        BlowerCooldown = hasRake,
        BlowerRange = hasRake,
        RakeArea = is,
        RakeRange = is,
        BlowerRadius = hasRake
    }
end
il = { "BasementCapacity", "BasementCashMultiplier", "BasementLuckyChance" }
ii = {
    BasementCapacity = "CapacityUpgradeButton",
    BasementCashMultiplier = "CashMultiplierUpgradeButton",
    BasementLuckyChance = "LuckyUpgradeButton"
}
ia = { Rake = hasRake, Blower = jm }
h6 = {}
for k in ShopConfig.Equipment do
    if ia[k] then
        table.insert(h6, k)
    end
end
Window, jj_1, iZ, iy, iD, iR, i5, ic = nil, nil, nil, nil, nil, nil, nil, nil
table.sort(h6)
iZ = fn377
iy = fn390
iD = fn362
iR = fn63
i5 = fn684
ic = fn394
if jj_1 and iy and (jj_1 and false) or not iy and ic and false or not (jj_1 and iy and (jj_1 and false) or not iy and ic and false) then
    Window = Library:CreateWindow({
        Title = "Tempo Hub",
        Footer = iK .. " | Garden Cleaner Evolution",
        Icon = 18657887261,
        NotifySide = "Right",
        ShowCustomCursor = false
    })
else
    jo = iK:CreateWindow({
        NotifySide = "Right",
        Icon = 18657887261,
        Title = "Tempo Hub",
        ShowCustomCursor = false,
        Footer = Library .. " | " .. Window
    })
end
local jj_2 = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "leaf"),
    Shop = Window:AddTab("Shop", "shopping-bag"),
    Player = Window:AddTab("Player", "user"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in jj_2 do
    fn255(v)
end
iF, AccountGroup, jl_1, Label, i4, jk_1 = nil, nil, nil, nil, nil, nil
local jg_1 = 22
repeat
    local jh_2 = (jg_1 * 5 + 5) % 6 + 1
    if jh_2 <= 3 then
        if jh_2 <= 2 then
            if jh_2 <= 1 then
                if ((not jg_1 or i4 or jk_1 and not jk_1 or (not AccountGroup or not Label or (not i4 or jk_1))) and ((not iF or Label) and (i4 and not AccountGroup) or (not jk_1 and not jg_1 or jg_1 and not AccountGroup)) or ((not i4 or i4) and (not iF and i4) or (not jk_1 or not jk_1 or (not AccountGroup or not iF))) and (not AccountGroup and not AccountGroup and (Label and Label) or not iF and Label and (not AccountGroup and jg_1))) and not ((not jg_1 or i4 or jk_1 and not jk_1 or (not AccountGroup or not Label or (not i4 or jk_1))) and ((not iF or Label) and (i4 and not AccountGroup) or (not jk_1 and not jg_1 or jg_1 and not AccountGroup)) or ((not i4 or i4) and (not iF and i4) or (not jk_1 or not jk_1 or (not AccountGroup or not iF))) and (not AccountGroup and not AccountGroup and (Label and Label) or not iF and Label and (not AccountGroup and jg_1))) then
                    i4 = #jk_1 > 18
                else
                    jk_1 = #i4 > 18
                end
                jg_1 = (jg_1 + 35) % 48
            else
                local jm_1 = (vector.create((jg_1 * 4 + 4) % 11 + 1, (jg_1 * 11 + 2) % 13 + 1, (jg_1 * 2 + 4) % 17 + 1))
                local jn_1 = (vector.create((jg_1 * 3 + 4) % 11 + 1, (jg_1 * 10 + 5) % 13 + 1, (jg_1 * 15 + 5) % 17 + 1))
                local js = (vector.create((jg_1 * 1 + 6) % 11 + 1, (jg_1 * 6 + 3) % 13 + 1, (jg_1 * 4 + 3) % 17 + 1))
                local jt = (vector.create((jg_1 * 3 + 3) % 11 + 1, (jg_1 * 5 + 6) % 13 + 1, (jg_1 * 2 + 10) % 17 + 1))
                if vector.dot(vector.cross(jm_1, jn_1), (vector.cross(js, jt))) == vector.dot(jm_1, js) * vector.dot(jn_1, jt) - vector.dot(jm_1, jt) * vector.dot(jn_1, js) + 1 then
                    jl_1 = "Unknown"
                else
                    iF = "Unknown"
                end
                jg_1 = (jg_1 + 11) % 48
            end
        else
            local n7 = bit32.rrotate(bit32.bxor(bit32.lrotate(jg_1, 3), string.byte(tostring(AccountGroup))), 6)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(n7, 4132987353), 2212400296), (bit32.bxor(bit32.band(n7, 161979942), 2751228016))), 2212400296), 2751228016) ~= n7 then
                pcall(fn564)
                jj_2 = AccountGroup.Info:AddLeftGroupbox("Account", "circle-user")
            else
                pcall(fn564)
                AccountGroup = jj_2.Info:AddLeftGroupbox("Account", "circle-user")
            end
            jg_1 = (jg_1 + 41) % 48
        end
    elseif jh_2 <= 5 then
        if jh_2 <= 4 then
            local jh_3 = (vector.create((jg_1 * 3 + 8) % 11 + 1, (jg_1 * 4 + 10) % 13 + 1, (jg_1 * 3 + 5) % 17 + 1))
            local jm_2 = (vector.create((jg_1 * 7 + 3) % 11 + 1, (jg_1 * 5 + 7) % 13 + 1, (jg_1 * 1 + 2) % 17 + 1))
            local oe = vector.dot(jh_3, jm_2)
            if oe * oe >= vector.dot(jh_3, jh_3) * vector.dot(jm_2, jm_2) + 1 then
                iL:AddLabel(AccountGroup("User", jl_1.Name, h7), true)
                iL:AddLabel(AccountGroup("Status", "Keyless", h7), true)
                iL:AddLabel(AccountGroup("Executor", jj_2, h7), true)
                iF = iJ.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            else
                AccountGroup:AddLabel(h7("User", iJ.Name, iL), true)
                AccountGroup:AddLabel(h7("Status", "Keyless", iL), true)
                AccountGroup:AddLabel(h7("Executor", iF, iL), true)
                jl_1 = jj_2.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            end
            jg_1 = (jg_1 + 41) % 48
        else
            if jg_1 * 94689239 + 10 + 7 <= jg_1 * 94689239 + 10 + 7 + 3 then
                jl_1:AddLabel(io(jo .. " [" .. tostring(game.PlaceId) .. "]", iH), true)
                jl_1:AddLabel(h7("Place ID", tostring(game.PlaceId), iH), true)
                Label = jl_1:AddLabel(h7("Session time", "0s", iz), true)
            else
                iH:AddLabel(jl_1(h7 .. " [" .. tostring(game.PlaceId) .. "]", Label), true)
                iH:AddLabel(iz("Place ID", tostring(game.PlaceId), Label), true)
                io = iH:AddLabel(iz("Session time", "0s", jo), true)
            end
            jg_1 = (jg_1 + 29) % 48
        end
    else
        if jg_1 * 106782385 + 12 + 3 >= jg_1 * 106782385 + 12 + 3 + 4 then
            jl_1 = tostring(game.JobId)
        else
            i4 = tostring(game.JobId)
        end
        jg_1 = (jg_1 + 47) % 48
    end
until (jg_1 * 17 + 14) % 48 == 16
if jk_1 then
    local jf_5 = 3
    repeat
        local jg_2 = {
            "mumqbifx",
            "swiqnbog",
            "gagyt",
            "eac",
            "eaqyot",
            "ssevkaxiyjm",
            "dnazcunxceh",
            "fpmpsm",
            "kiyu",
            "pjddi",
            "vxckdirewpe",
            "ozcvxjdsvusd",
            "jzo"
        }
        if jg_2[(jf_5 * 70 + 92) % 13 + 1] <= jg_2[(jf_5 * 70 + 92) % 13 + 1] then
            jk_1 = string.sub(i4, 1, 18) .. "..."
        else
            i4 = string.sub(jk_1, 1, 18) .. "..."
        end
        jf_5 = (jf_5 + 2) % 8
    until (jf_5 * 3 + 0) % 8 == 7
end
local jf_6 = jk_1 or i4
jl_1:AddLabel(h7("Server", jf_6, iv), true)
jl_1:AddButton({
    Text = "Copy join script (Job ID)",
    Func = function()
        iX(string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, i4), "Copied join script to clipboard")
    end
})
local TempoHubGroup = jj_2.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = iC })
local ScriptsGroup = jj_2.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(io("Included in this hub", iv), true)
ScriptsGroup:AddLabel(io(jo, iH), true)
local FeaturesGroup = jj_2.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(io("Auto Collect Leaves", iH), true)
FeaturesGroup:AddLabel(io("Auto Sell", iz), true)
FeaturesGroup:AddLabel(io("Auto Upgrades", iL), true)
FeaturesGroup:AddLabel(io("Auto Basement Upgrades", iL), true)
FeaturesGroup:AddLabel(io("Auto Buy Equipment", iv), true)
FeaturesGroup:AddLabel(io("Auto Rebirth", iv), true)
local SocialsGroup = jj_2.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = iC })
SocialsGroup:AddButton({
    Text = "Rscripts",
    Func = function()
        iX(iG, "Copied Rscripts profile to clipboard")
    end
})
local FaqGroup = jj_2.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutoCollectLeavesGroup = jj_2.Main:AddLeftGroupbox("Auto Collect Leaves", "leaf")
AutoCollectLeavesGroup:AddToggle("AutoCollect", { Text = "Auto Collect Leaves", Default = false })
AutoCollectLeavesGroup:AddToggle("CollectAnyArea", { Text = "Any Area", Default = true })
AutoCollectLeavesGroup:AddDropdown("CollectAreas", { Text = "Areas", Values = jp, Default = {}, Multi = true })
AutoCollectLeavesGroup:AddSlider("CollectAmount", { Text = "Leaves Per Batch", Default = 250, Min = 1, Max = 1000, Rounding = 0 })
AutoCollectLeavesGroup:AddSlider("CollectDelay", { Text = "Loop Delay", Default = 0, Min = 0, Max = 5, Rounding = 2 })
Label2 = AutoCollectLeavesGroup:AddLabel(h7("Leaves", "0 / 0", iL), true)
local AutoSellGroup = jj_2.Main:AddRightGroupbox("Auto Sell", "trash-2")
AutoSellGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
AutoSellGroup:AddSlider("SellAt", { Text = "Sell At % Of Capacity", Default = 100, Min = 10, Max = 100, Rounding = 0 })
AutoSellGroup:AddToggle("SellReturn", { Text = "Return After Selling", Default = true })
AutoSellGroup:AddSlider("SellDelay", { Text = "Loop Delay", Default = 0.5, Min = 0.5, Max = 15, Rounding = 1 })
Label3 = AutoSellGroup:AddLabel(h7("Cash", "0", iz), true)
local AutoUpgradesGroup = jj_2.Shop:AddLeftGroupbox("Auto Upgrades", "arrow-up-circle")
AutoUpgradesGroup:AddToggle("AutoUpgrade", { Text = "Auto Upgrades", Default = false })
AutoUpgradesGroup:AddToggle("UpgradeAny", { Text = "Any Upgrade", Default = true })
AutoUpgradesGroup:AddDropdown("Upgrades", { Text = "Upgrades", Values = iw, Default = {}, Multi = true })
AutoUpgradesGroup:AddInput("UpgradeCashReserve", { Text = "Keep Cash Reserve", Default = "0", Numeric = true, Finished = true })
AutoUpgradesGroup:AddSlider("UpgradeDelay", { Text = "Loop Delay", Default = 3, Min = 0.5, Max = 60, Rounding = 1 })
local AutoBasementUpgradesGroup = jj_2.Shop:AddLeftGroupbox("Auto Basement Upgrades", "arrow-up-from-line")
AutoBasementUpgradesGroup:AddToggle("AutoBasementUpgrade", { Text = "Auto Basement Upgrades", Default = false })
AutoBasementUpgradesGroup:AddToggle("BasementUpgradeAny", { Text = "Any Upgrade", Default = true })
AutoBasementUpgradesGroup:AddDropdown("BasementUpgradeList", { Text = "Upgrades", Values = il, Default = {}, Multi = true })
AutoBasementUpgradesGroup:AddInput("BasementCashReserve", { Text = "Keep Cash Reserve", Default = "0", Numeric = true, Finished = true })
AutoBasementUpgradesGroup:AddSlider("BasementDelay", { Text = "Loop Delay", Default = 3, Min = 0.5, Max = 60, Rounding = 1 })
Label4 = AutoBasementUpgradesGroup:AddLabel(h7("Levels", "0 / 0 / 0", iL), true)
local AutoBuyEquipmentGroup = jj_2.Shop:AddRightGroupbox("Auto Buy Equipment", "shovel")
AutoBuyEquipmentGroup:AddToggle("AutoBuyEquipment", { Text = "Auto Buy Equipment", Default = false })
AutoBuyEquipmentGroup:AddToggle("BuyAnyEquipment", { Text = "Any Equipment", Default = true })
AutoBuyEquipmentGroup:AddDropdown("BuyEquipmentList", { Text = "Equipment", Values = h6, Default = {}, Multi = true })
AutoBuyEquipmentGroup:AddInput("EquipmentCashReserve", { Text = "Keep Cash Reserve", Default = "0", Numeric = true, Finished = true })
AutoBuyEquipmentGroup:AddSlider("EquipmentDelay", { Text = "Loop Delay", Default = 5, Min = 1, Max = 60, Rounding = 1 })
Label5 = AutoBuyEquipmentGroup:AddLabel(h7("Owned", "None", iv), true)
local AutoRebirthGroup = jj_2.Shop:AddRightGroupbox("Auto Rebirth", "rotate-ccw")
AutoRebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
AutoRebirthGroup:AddSlider("RebirthDelay", { Text = "Loop Delay", Default = 10, Min = 1, Max = 120, Rounding = 1 })
Label6 = AutoRebirthGroup:AddLabel(h7("Rebirth", "0", iH), true)
local MovementGroup = jj_2.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "Walk Speed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "Walk Speed", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfiniteJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("Noclip", { Text = "Noclip", Default = false })
local FlyGroup = jj_2.Player:AddRightGroupbox("Fly", "plane")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 80, Min = 16, Max = 400, Rounding = 0 })
local TeleportGroup = jj_2.Player:AddLeftGroupbox("Teleport", "map-pin")
TeleportGroup:AddDropdown("TeleportArea", { Text = "Area", Values = jp, Default = jp[1] })
TeleportGroup:AddButton({
    Text = "Teleport",
    Func = function()
        local TeleportArea = Options.TeleportArea
        local la = TeleportArea and TeleportArea.Value
        local k9_1 = la
        if la then
            la = i5(k9_1)
        end
        local k9_2 = la
        local la_1 = h8()
        local lb = not la_1
        local lc = not k9_2
        local lg = if lc then 1 else 0
        local le = 1945 * lg + 1504 * (1 - lg)
        local lf = 609 * lg + 4086 * (1 - lg)
        if not ((le * 3924 + lf * 2329 + le * lf) % 16777213 == 10235046) then
            lc = lb
        end
        if lc then
            Library:Notify("Could not find that area")
            return
        end
        la_1.CFrame = CFrame.new(k9_2)
    end
})
local MenuGroup = jj_2.Settings:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
i8 = tick()
i0 = tick()
pcall(function()
    for i, v in ipairs(getconnections(iJ.Idled)) do
        local ln = v
        pcall(function()
            ln:Disable()
        end)
    end
end)
iE = function()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    i0 = tick()
end
connection = UserInputService.InputBegan:Connect(function()
    i8 = tick()
end)
connection2 = UserInputService.InputChanged:Connect(function(cD)
    local UserInputType = cD.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        i8 = tick()
    end
end)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)
Library.ToggleKeybind = Options.MenuKeybind
Library:OnUnload(function()
    connection:Disconnect()
    connection2:Disconnect()
    select("#", "Garden Cleaner Evolution unloaded")
end)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Mint")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/GardenCleanerEvolution")
SaveManager:BuildConfigSection(jj_2.Settings)
ThemeManager:ApplyToTab(jj_2.Settings)
ThemeManager:LoadDefault()
SaveManager:LoadAutoloadConfig()
task.spawn(function()
    while not Library.Unloaded do
        task.wait(2)
        if ir("AntiAfk") then
            local lt = tick() - i8
            local lu = tick() - i0
            if lt >= 300 and lu >= 60 then
                pcall(iE)
            else
                if lt < 300 and lu >= 300 then
                    pcall(iE)
                end
            end
        end
    end
end)
iN = os.clock()
task.spawn(function()
    local lB_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local lA = math.floor(os.clock() - iN)
        if lA < 60 then
            lB_1 = lA .. "s"
        elseif lA < 3600 then
            lB_1 = string.format("%dm %ds", math.floor((lA) / (60)), lA % 60)
        else
            lB_1 = string.format("%dh %dm", math.floor((lA) / (3600)), math.floor((lA % 3600) / (60)))
        end
        Label:SetText(h7("Session time", lB_1, iz))
        Label2:SetText(h7("Leaves", string.format("%d / %d", Leaves.Value, MaxHold.Value), iL))
        Label3:SetText(h7("Cash", string.format("%d", math.floor(Cash.Value)), iz))
        local lA_1 = {}
        for k, v in h6 do
            if ia[v].Value then
                table.insert(lA_1, v)
            end
        end
        local lB_2 = #lA_1 > 0 and table.concat(lA_1, ", ")
        local lC = lB_2 or "None"
        local lA_2 = #lA_1 > 0 and iL or iv
        Label5:SetText(h7("Owned", lC, lA_2))
        local lA_3 = {}
        for k, v in il do
            local lB_4 = UpgradeLevels:FindFirstChild(v .. "Level")
            local insert = table.insert
            local lB_5 = lB_4 and lB_4.Value or 0
            insert(lA_3, tostring(lB_5))
        end
        Label4:SetText(h7("Levels", table.concat(lA_3, " / "), iL))
        local format = string.format
        local Value = Rebirth.Value
        local lC_2 = iD() and "ready"
        local lD_2 = lC_2 or "locked"
        local lC_3 = format("%d (%s)", Value, lD_2)
        local lA_5 = iD() and iL
        local lB_7 = lA_5 or iH
        Label6:SetText(h7("Rebirth", lC_3, lB_7))
    end
end)
bodyVelocity, bodyGyro = nil, nil
iV = function()
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
end
connection3 = UserInputService.JumpRequest:Connect(function()
    local l_ = if not ir("InfiniteJump") then 1 else 0
    if l_ == 1 then
        return
    end
    local Character = iJ.Character
    local lW = Character and Character:FindFirstChildOfClass("Humanoid")
    if lW then
        lW:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
connection4 = nil
connection5 = nil
connection4 = RunService.Stepped:Connect(function()
    if Library.Unloaded then
        connection4:Disconnect()
        return
    end
    if not ir("Noclip") then
        return
    end
    local Character = iJ.Character
    if not Character then
        return
    end
    for i, descendant in Character:GetDescendants() do
        local l0_1 = descendant:IsA("BasePart") and descendant.CanCollide
        if l0_1 then
            descendant.CanCollide = false
        end
    end
end)
connection5 = RunService.RenderStepped:Connect(function()
    if Library.Unloaded then
        iV()
        connection3:Disconnect()
        connection5:Disconnect()
        return
    end
    local Character = iJ.Character
    local mc = Character and Character:FindFirstChildOfClass("Humanoid")
    local md = Character
    if md then
        md = Character:FindFirstChild("HumanoidRootPart")
    end
    local mb_1 = mc
    local mc_1 = md
    if mb_1 then
        mb_1 = ir("WalkSpeedEnabled")
    end
    if mb_1 then
        local mb_2 = i6("WalkSpeed", 32)
        if mc.WalkSpeed ~= mb_2 then
            mc.WalkSpeed = mb_2
        end
    end
    local mb_3 = not mc_1
    local md_1 = not ir("Fly") or mb_3
    if md_1 or not mc then
        iV()
        return
    end
    if not bodyVelocity then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 9000000000
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = mc_1
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 9000000000
        bodyGyro.P = 90000
        bodyGyro.Parent = mc_1
    end
    local CurrentCamera = workspace.CurrentCamera
    local mc_2 = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        mc_2 += CurrentCamera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        mc_2 -= CurrentCamera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        mc_2 -= CurrentCamera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        mc_2 += CurrentCamera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        mc_2 += Vector3.yAxis
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        mc_2 -= Vector3.yAxis
    end
    bodyGyro.CFrame = CurrentCamera.CFrame
    local mb_6 = mc_2.Magnitude > 0 and mc_2.Unit * i6("FlySpeed", 80)
    local mc_3 = mb_6
    local mm = if mc_3 then 1 else 0
    local mk = 1967 * mm + 3043 * (1 - mm)
    local ml = 2263 * mm + 2329 * (1 - mm)
    if not ((mk * 3821 + ml * 2662 + mk * ml) % 16777213 == 1214121) then
        mc_3 = Vector3.zero
    end
    bodyVelocity.Velocity = mc_3
end)
iM = false
task.spawn(function()
    while not Library.Unloaded do
        local mo = not iM
        local mp = ir("AutoCollect") and mo
        if mp then
            local mo_1 = MaxHold.Value - Leaves.Value
            if mo_1 > 0 then
                local mp_1 = iR(mo_1, ix("CollectAreas"), ir("CollectAnyArea"))
                local mo_2 = math.max(1, i6("CollectAmount", 250))
                local mq = #mp_1
                for i = 1, mq, mo_2 do
                    local mn
                    mn = table.move(mp_1, i, math.min(i + mo_2 - 1, #mp_1), 1, {})
                    pcall(function()
                        LeafPickedUp:FireServer(mn)
                    end)
                end
            end
        end
        task.wait(i6("CollectDelay", 0))
    end
end)
task.spawn(function()
    local mC = false
    repeat
        if not Library.Unloaded then
            local mx = not iM
            local my = ir("AutoSell") and mx
            if my then
                local mx_1 = math.max(1, math.floor(MaxHold.Value * i6("SellAt", 100) / 100))
                local my_1 = h8()
                local mw = ic()
                local mz = my_1 and mw and Leaves.Value >= mx_1
                local mz_1
                if mz then
                    iM = true
                    local CFrame2 = my_1.CFrame
                    my_1.CFrame = CFrame.new(mw.Position + Vector3.new(0, 3, 4))
                    task.wait(0.4)
                    pcall(function()
                        fireproximityprompt(mw.ProximityPrompt)
                    end)
                    local my_2 = os.clock() + 5
                    repeat
                        task.wait(0.1)
                        mz_1 = Leaves.Value <= 0 or os.clock() > my_2 or Library.Unloaded
                    until mz_1
                    local mF = if ir("SellReturn") then 1 else 0
                    if mF == 1 then
                        local my_3 = h8()
                        if my_3 then
                            my_3.CFrame = CFrame2
                        end
                    end
                    iM = false
                end
            end
            task.wait(i6("SellDelay", 1))
        else
            mC = true
        end
    until mC
end)
task.spawn(function()
    while not Library.Unloaded do
        if ir("AutoUpgrade") then
            local mG = ix("Upgrades")
            local mH = ir("UpgradeAny")
            local mI = i6("UpgradeCashReserve", 0)
            for k, v in iw do
                local mR = v
                if not not (mH or mG[mR]) then
                    local mJ_1 = is[mR]
                    if not (mJ_1 and not mJ_1.Value) then
                        local mJ_2 = iZ(mR)
                        if not (mJ_2 >= UpgradeManager.MAX_LEVEL) then
                            local mK_1 = UpgradeManager.GetModifiedCost(iJ, mR, mJ_2)
                            if mK_1 > 0 and Cash.Value - mK_1 >= mI then
                                pcall(function()
                                    UpgradeRequest:FireServer(mR)
                                end)
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end
        end
        task.wait(i6("UpgradeDelay", 3))
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if ir("AutoBasementUpgrade") then
            local mU = ix("BasementUpgradeList")
            local mV = ir("BasementUpgradeAny")
            local mW = i6("BasementCashReserve", 0)
            for k, v in il do
                if not not (mV or mU[v]) then
                    local mT = BasementUpgrades:FindFirstChild(ii[v])
                    local mX_1 = UpgradeLevels:FindFirstChild(v .. "Level")
                    local mS = h8()
                    if not not (mT and mX_1 and mS) then
                        local mY_1 = BasementUpgradeManager.GetCost(iJ, v, mX_1.Value)
                        if mY_1 and mY_1 > 0 and Cash.Value - mY_1 >= mW then
                            pcall(function()
                                firetouchinterest(mS, mT, 0)
                                task.wait(0.1)
                                firetouchinterest(mS, mT, 1)
                            end)
                            task.wait(0.3)
                        end
                    end
                end
            end
        end
        task.wait(i6("BasementDelay", 3))
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if ir("AutoBuyEquipment") then
            local m6 = ix("BuyEquipmentList")
            local m7 = ir("BuyAnyEquipment")
            local m8 = i6("EquipmentCashReserve", 0)
            for k, v in h6 do
                local nh = v
                if not not (m7 or m6[nh]) then
                    if not ia[nh].Value then
                        local m9_1 = ShopConfig.GetModifiedCost(iJ, nh)
                        if m9_1 > 0 and Cash.Value - m9_1 >= m8 then
                            pcall(function()
                                BuyEquipment:FireServer(nh)
                            end)
                            task.wait(0.3)
                        end
                    end
                end
            end
        end
        task.wait(i6("EquipmentDelay", 5))
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        local ni = ir("AutoRebirth") and iD()
        if ni then
            pcall(function()
                RebirthEvent:FireServer()
            end)
            task.wait(3)
        end
        task.wait(i6("RebirthDelay", 10))
    end
end)
Library:Notify("Garden Cleaner Evolution loaded")
end)(...)

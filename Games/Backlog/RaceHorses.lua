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
getgenv().TempoHoodSubtitle = "RACE HORSES"
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
local uu
local tQ
local ux
local ue
local uA
local tW
local uD
local tD
local tZ
local uk
local tG
local t1
local un
local tJ
local t4
local uw
local ua
local ud
local uz
local uC
local tY
local LocalPlayer
local t0
local um
local tI
local t3
local t6
local us
local tO
local uv
local uc
local tU
local uf
local tE
local tH
local uo
local t2
local CoreGui
local State
local t8
local function fn55()
    local wp = 0
    for k in pairs(t1()) do
        wp += 1
    end
    return wp
end
local function fn75(V)
    local vu = typeof(cloneref) == "function" and typeof(V) == "Instance"
    if vu then
        return cloneref(V)
    end
    return V
end
local function fn110()
    return not uf.Unloaded
end
local function fn229(az)
    local vO_2
    local vN = os.clock() + 8
    local vN_2
    while true do
        local vO_1 = State.MoveBusy and tJ() and os.clock() < vN
        if vO_1 then
            task.wait(0.1)
            continue
        end
        break
    end
    local vN_1 = State.MoveBusy or not tJ()
    if vN_1 then
        return false
    end
    State.MoveBusy = true
    vN_2, vO_2 = pcall(az)
    State.MoveBusy = false
    if not vN_2 then
        warn("[Tempo] movement error: " .. tostring(vO_2))
        return false
    end
    return vO_2
end
local function fn246(gm)
    local Az = t1()
    local AA = type(gm) == "table" and next(gm) ~= nil
    local AA_3
    local AA_1 = AA and gm or Az
    local AB_1 = {}
    local AC_2
    for k in pairs(AA_1) do
        local AA_2 = Az[k]
        local AC_1 = type(AA_2) == "table"
        if AC_1 then
            local AD_1 = tonumber(AA_2.CanRaceAt) or 0
            AC_1 = AD_1 <= os.time()
        end
        if AC_1 then
            table.insert(AB_1, k)
        end
    end
    if #AB_1 == 0 then
        return nil
    elseif tD.priority == "Random Horse" then
        return AB_1[math.random(1, #AB_1)]
    else
        AC_2, AA_3 = nil, nil
        for i, v in ipairs(AB_1) do
            local AB_2 = tonumber(Az[v].Multiplier) or 0
            local AD_2 = not AA_3
            if not AD_2 then
                AD_2 = AB_2 > AA_3
            end
            if AD_2 then
                AC_2, AA_3 = v, AB_2
            end
        end
        return AC_2
    end
end
local function fn297(a_)
    if not table.find(tG.missing, a_) then
        table.insert(tG.missing, a_)
    end
end
local function fn311()
    local zA = t2(um)
    local zB = type(zA) == "table" and zA
    return zB or {}
end
local function fn345()
    gethui = ux
end
local function fn347()
    local Character = LocalPlayer.Character
    local vF = Character and Character:FindFirstChild("HumanoidRootPart")
    return vF or nil
end
local function fn351(ai)
    local format = string.format
    local floor = math.floor
    local vB = tonumber(ai) or 0
    local vC = format("%d", floor(vB))
    local vz_1 = vC:reverse():gsub("(%d%d%d)", "%1,")
    local vA_1 = vz_1:reverse()
    return (vA_1:gsub("^,", ""))
end
local function fn357()
    local Modules = uA:FindFirstChild("Modules")
    if not Modules then
        uD("Modules")
        return
    end
    local Core = Modules:FindFirstChild("Core")
    local Shop = Modules:FindFirstChild("Shop")
    local v0_1 = Core and t6(Core:FindFirstChild("MailService"))
    local v3 = v0_1 or nil
    tG.Mail = v3
    local v0_2 = Core and t6(Core:FindFirstChild("DataCache"))
    local v1_1 = v0_2 or nil
    tG.Data = v1_1
    local v0_3 = Shop and Shop:FindFirstChild("Categories")
    local v1_2 = v0_3 or nil
    local v0_4 = v1_2
    if v1_2 then
        v1_2 = t6(v0_4:FindFirstChild("Eggs"))
    end
    local v0_5 = v1_2 or nil
    tG.EggShop = v0_5
    local v0_6 = not tG.Mail or not tW(tG.Mail.Call) or not tW(tG.Mail.FireServer)
    if v0_6 then
        uD("MailService")
    end
    local v0_7 = not tG.Data or not tW(tG.Data.Get)
    if v0_7 then
        uD("DataCache")
    end
    local v0_8 = not tG.EggShop or not tW(tG.EggShop.GetItems)
    if v0_8 then
        uD("Egg shop")
    end
    tG.ready = #tG.missing == 0
end
local function fn377()
    local yc = us("StableUpgrade")
    if yc and yc.Success and yc.Value == true then
        State.UpgradeStatus = "Upgraded, stable holds " .. tostring(uu())
        return
    end
    State.UpgradeStatus = "Requirements not met"
end
local function fn401()
    local zr = {}
    for k, v in pairs(t1()) do
        local zs = type(v) == "table" and type(v.Name) == "string" and not table.find(zr, v.Name)
        if zs then
            table.insert(zr, v.Name)
        end
    end
    table.sort(zr)
    return zr
end
local function fn410(aU)
    local vX_1
    local vW_1
    if not aU then
        return nil
    end
    vW_1, vX_1 = pcall(require, aU)
    local vY = vW_1 and type(vX_1) == "table"
    if vY then
        return vX_1
    end
    return nil
end
local function fn423(c2)
    c2.stopped = true
    local xC = c2.generation or 0
    c2.generation = xC + 1
end
local function fn487()
    local wn = tE({ "Inventory", "Horses" }, nil)
    if type(wn) ~= "table" then
        return {}
    end
    return wn
end
local function fn557()
    local wv = tonumber(tE({ "Stable", "MaxHorses" }, 0)) or 0
    return wv
end
local function fn598()
    local wx = tonumber(tE("Cash", 0)) or 0
    return wx
end
local function fn623()
    local Ae = tO(uz.rarities)
    if not next(Ae) then
        State.SellStatus = "No rarity selected"
        return
    end
    local Af = t1()
    local Ag = 0
    local Ah = {}
    for k, v in pairs(Af) do
        Ag += 1
        local Af_1 = type(v) == "table" and Ae[tostring(v.Rarity)]
        if Af_1 then
            local Ai = tonumber(v.Level) or 0
            Af_1 = Ai <= uz.maxLevel
        end
        if Af_1 then
            table.insert(Ah, { uid = k, horse = v })
        end
    end
    local Ae_1 = math.max(1, uz.keep)
    if Ag <= Ae_1 then
        State.SellStatus = "Keeping " .. Ag .. " horse(s)"
        return
    end
    if #Ah == 0 then
        State.SellStatus = "Nothing matches filters"
        return
    end
    table.sort(Ah, function(gd, ge)
        local z8 = (tonumber(gd.horse.Multiplier))
        local Ad = if z8 then 1 else 0
        local Ab = 428 * Ad + 1932 * (1 - Ad)
        local Ac = 2680 * Ad + 3471 * (1 - Ad)
        if not ((Ab * 2585 + Ac * 128 + Ab * Ac) % 16777213 == 2596460) then
            z8 = 0
        end
        local z9 = tonumber(ge.horse.Multiplier) or 0
        return z8 < z9
    end)
    local Af_2 = 0
    for i, v in ipairs(Ah) do
        local Ah_1 = not tJ() or uz.stopped or Ag - Af_2 <= Ae_1
        if Ah_1 then
            break
        elseif t0("SellHorse", v.uid) then
            Af_2 += 1
            task.wait(0.6)
        end
    end
    local Af_3 = Af_2 > 0 and "Sold " .. Af_2 .. " horse(s)" or "Sell rejected"
    State.SellStatus = Af_3
end
local function fn685(hx)
    if hx then
        tD.stopped = false
        ue()
        if t3.signup then
            State.RaceStatus = "Waiting for next race"
        end
    else
        tD.stopped = true
        uC()
        State.RaceStatus = "Idle"
    end
end
local function fn693(cL)
    local xl = {}
    if type(cL) ~= "table" then
        return xl
    end
    for k, v in pairs(cL) do
        if v == true then
            xl[k] = true
        elseif type(v) == "string" then
            xl[v] = true
        end
    end
    return xl
end
local function fn843()
    for i, v in ipairs({ uc, t8, t4, tZ, tU, tQ, tI, uz }) do
        un(v)
    end
    tD.stopped = true
    uC()
end
local function fn873(Y)
    return type(Y) == "function"
end
local function fn898()
    local zj = {}
    for i, v in ipairs(ua("Horse")) do
        if v:GetAttribute("HorseOwner") == LocalPlayer.UserId then
            table.insert(zj, v)
        end
    end
    return zj
end
local function fn939()
    local yD = 0
    for i, v in ipairs(ua("HatchEgg")) do
        if v:GetAttribute("Owner") == LocalPlayer.UserId then
            yD += 1
        end
    end
    return yD
end
local function fn943()
    return CoreGui
end
local function fn991()
    local wU = us("GetBaseBounds")
    local wV = not wU or not wU.Success
    local wZ = if wV then 1 else 0
    local wX = 2514 * wZ + 2452 * (1 - wZ)
    local wY = 454 * wZ + 4050 * (1 - wZ)
    if not ((wX * 3282 + wY * 1596 + wX * wY) % 16777213 == 10116888) then
        wV = type(wU.Value) ~= "table"
    end
    if wV then
        return nil
    end
    local Base = wU.Value.Base
    local wU_1 = typeof(Base) == "Instance" and Base:IsA("BasePart")
    if wU_1 then
        return Base
    end
    return nil
end
local function fn1075()
    if t3.signup then
        return
    end
    local Be = not tG.Mail or not tW(tG.Mail.Bind)
    if Be then
        State.RaceStatus = "Race binding unavailable"
        return
    end
    local Be_1 = pcall(function()
        t3.signup = tG.Mail:Bind("InquireSignup", function()
            local A_ = not tJ() or tD.stopped
            if A_ then
                return
            end
            State.RaceStatus = "Signing up"
            t0("RequestSignup")
        end)
        t3.select = tG.Mail:Bind("HorseSelect", function(gY)
            local A1 = not tJ() or tD.stopped
            if A1 then
                return
            end
            local A1_1 = tY(gY)
            if not A1_1 then
                State.RaceStatus = "All horses on cooldown"
                return
            end
            local A2 = us("RequestEnterHorse", A1_1)
            if A2 and A2.Success and A2.Value == true then
                local A2_1 = t1()[A1_1]
                local A2_2 = A2_1 and A2_1.Name or A1_1
                State.RaceStatus = "Entered " .. tostring(A2_2)
            else
                State.RaceStatus = "Entry rejected"
            end
        end)
    end)
    if not Be_1 then
        uC()
        State.RaceStatus = "Race binding failed"
    end
end
local function fn1093(b9, ca)
    local wN = typeof(b9) ~= "Instance"
    local wN_3
    local wT = if wN then 1 else 0
    local wR = 4055 * wT + 2523 * (1 - wT)
    local wS = 966 * wT + 1062 * (1 - wT)
    if not ((wR * 2358 + wS * 2710 + wR * wS) % 16777213 == 16096680) then
        wN = not b9:IsDescendantOf(uv)
    end
    if wN then
        return false
    end
    local wN_1 = ud(b9)
    if not wN_1 then
        return false
    end
    local wO = tH()
    if not wO then
        return false
    elseif (wO.Position - wN_1).Magnitude > 35 then
        local wO_1 = wN_1 + Vector3.new(0, 0, 6)
        local wP = ca or 5
        local wT_1 = if not uo(wO_1, wP) then 1 else 0
        if wT_1 == 1 then
            return false
        end
        task.wait(0.35)
        local wN_2 = not tJ() or not b9:IsDescendantOf(uv)
        if wN_3 then
            return false
        end
        return t0("Interact", b9)
    else
        wN_3 = not tJ() or not b9:IsDescendantOf(uv)
        if wN_3 then
            return false
        end
        return t0("Interact", b9)
    end
end
local function fn1100()
    local yj_1
    local yi_1
    if not tG.EggShop then
        return {}
    end
    yi_1, yj_1 = pcall(function()
        return tG.EggShop:GetItems()
    end)
    local yk = not yi_1 or type(yj_1) ~= "table"
    if yk then
        return {}
    end
    return yj_1
end
local function fn1128()
    local yp = tO(tZ.rarities)
    if not next(yp) then
        State.BuyStatus = "No rarity selected"
        return
    end
    local yq = uw()
    if #yq == 0 then
        State.BuyStatus = "Egg shop unavailable"
        return
    end
    local yr = 0
    for i, v in ipairs(yq) do
        local yq_1 = not tJ() or tZ.stopped
        if yq_1 then
            break
        else
            local yq_2 = tonumber(v.Price)
            local ys = v.Rarity and yp[v.Rarity] and not v.OffSale and yq_2 and yq_2 <= uk()
            if ys then
                local yq_3 = us("PurchaseItem", "Eggs", i)
                if yq_3 and yq_3.Success then
                    yr += 1
                end
                task.wait(0.3)
            end
        end
    end
    local yq_4 = yr > 0 and "Bought " .. yr .. " egg(s)" or "Out of stock or cash"
    State.BuyStatus = yq_4
end
local function fn1129(cB)
    local Character = LocalPlayer.Character
    local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    for i, v in ipairs({ Character, Backpack }) do
        if v then
            for i, child in ipairs(v:GetChildren()) do
                local w6_1 = child:IsA("Tool") and cB(child)
                if w6_1 then
                    return child
                end
            end
        end
    end
    return nil
end
tD = nil
tE = nil
LocalPlayer = nil
tG = nil
tH = nil
tI = nil
tJ = nil
tO = nil
tQ = nil
tU = nil
tW = nil
tY = nil
tZ = nil
t0 = nil
t1 = nil
t2 = nil
t3 = nil
t4 = nil
CoreGui = nil
t6 = nil
t8 = nil
ua = nil
uc = nil
ud = nil
ue = nil
uf = nil
uk = nil
um = nil
un = nil
uo = nil
local Players, tK, Workspace, tM, tN, tP, tR, Lighting, tT, tV, CollectionService, TeleportService, t7, GuiService, ub, ug, uh, ui, uj, ul
State = nil
us = nil
uu = nil
uv = nil
uw = nil
ux = nil
uz = nil
uA = nil
uC = nil
uD = nil
local up, uq, ut, uy, uB
local uV_1
local uU_1
if not game:IsLoaded() then
    game.Loaded:Wait()
end
Players, ut, up, uj, ug, GuiService, CoreGui, TeleportService, CollectionService, Lighting, Workspace, LocalPlayer, ux = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
if ((CoreGui or ux) and (not CoreGui or not CoreGui) or ux and up and (not ux and ux)) and (not CoreGui and uj and (not up or LocalPlayer) and (not uj or not up or (not CoreGui or not uj))) and (((not LocalPlayer or not up) and (not ux or ux) or (not LocalPlayer or not up) and (not ux and not uj)) and (not CoreGui and not ux and (not ux or CoreGui) or (not uj and not LocalPlayer or (ux or not LocalPlayer)))) or not (((CoreGui or ux) and (not CoreGui or not CoreGui) or ux and up and (not ux and ux)) and (not CoreGui and uj and (not up or LocalPlayer) and (not uj or not up or (not CoreGui or not uj))) and (((not LocalPlayer or not up) and (not ux or ux) or (not LocalPlayer or not up) and (not ux and not uj)) and (not CoreGui and not ux and (not ux or CoreGui) or (not uj and not LocalPlayer or (ux or not LocalPlayer))))) then
    ut = game:GetService("RunService")
    up = game:GetService("UserInputService")
    uj = game:GetService("VirtualUser")
    ug = game:GetService("HttpService")
else
    up = game:GetService("RunService")
    ut = game:GetService("UserInputService")
    ug = game:GetService("VirtualUser")
    uj = game:GetService("HttpService")
end
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
TeleportService = game:GetService("TeleportService")
CollectionService = game:GetService("CollectionService")
Lighting = game:GetService("Lighting")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local uG = "TempoRaceHorses"
ux = fn943
if getgenv then
    getgenv().gethui = ux
end
uf, uA, uv, State, ul, uh, ub, tG, uc, t8, t4, tZ, tU, tQ, tI, tD, uz, t3, tM, tW, tJ, t7, tH, uo, tK, t2, t6, uD, t0, us, tE, t1, tP, uu, uk, ua, ud, tR, tN, ui, uB, tO, uq, un, uw, uy, tT, um, tV, tY, uC, ue = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pcall(fn345)
local function uP(u)
    local vg
    local vh
    local vf
    vf = nil
    vg = nil
    vh = nil
    local vi = u ~= ""
    local vj = type(u) == "string" and vi
    assert(vj, "Namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    vg = getgenv()
    assert(type(vg) == "table", "getgenv did not return a table")
    local vi_1 = vg[u]
    if vi_1 ~= nil then
        local vj_1 = type(vi_1) == "table" and type(vi_1.Unload) == "function"
        assert(vj_1, "Namespace is occupied")
        vi_1.Unload()
        assert(vg[u] == nil, "Previous instance did not release its namespace")
    end
    vh = {}
    vf = { State = {}, Unloaded = false }
    vf.Track = function(A)
        assert(type(A) == "function", "Cleanup must be callable")
        if vf.Unloaded then
            A()
        else
            table.insert(vh, A)
        end
        return A
    end
    vf.Unload = function()
        local u8_1
        local u7_1
        if vf.Unloaded then
            return
        end
        vf.Unloaded = true
        local u5 = {}
        local vc = #vh
        local vb = -1
        while false and vc <= 1 or true and vc >= 1 do
            local vd = vc
            local u6_1 = table.remove(vh, vd)
            u7_1, u8_1 = pcall(u6_1)
            if not u7_1 then
                table.insert(u5, tostring(u8_1))
            end
            vc += vb
        end
        table.clear(vf.State)
        if #u5 > 0 then
            error("Cleanup incomplete: " .. table.concat(u5, "; "), 0)
        end
        if vg[u] == vf then
            vg[u] = nil
        end
    end
    vg[u] = vf
    return vf
end
tM = function(N, O)
    local vp = type(N) == "table" and type(N.Track) == "function"
    assert(vp, "FeatureAPI required")
    local vp_1 = type(O) == "table" and type(O.OnUnload) == "function"
    assert(vp_1, "UI library required")
    assert(type(O.Unload) == "function", "UI unload required")
    N.Track(function()
        if not O.Unloaded then
            O:Unload()
        end
    end)
    O:OnUnload(function()
        N.Unload()
    end)
end
uf = uP(uG)
tW = fn873
tJ = fn110
uA = fn75(ReplicatedStorage)
uv = fn75(Workspace)
State = uf.State
State.CollectStatus = "Idle"
State.AppleStatus = "Idle"
State.UpgradeStatus = "Idle"
State.BuyStatus = "Idle"
State.PlaceStatus = "Idle"
State.HatchStatus = "Idle"
State.FeedStatus = "Idle"
State.RaceStatus = "Idle"
State.SellStatus = "Idle"
State.MoveBusy = false
ul = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic" }
uh = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Exotic" }
ub = { "Apple", "Carrot", "Beetroot", "Melon", "Pumpkin", "Golden Apple", "Taco" }
t7 = fn351
tH = fn347
uo = function(ar, as)
    local vL
    vL = nil
    if typeof(ar) ~= "Vector3" then
        return false
    end
    vL = tH()
    if not vL then
        return false
    end
    return (pcall(function()
        local vJ = as or 5
        vL.CFrame = CFrame.new(ar + Vector3.new(0, vJ, 0))
        vL.AssemblyLinearVelocity = Vector3.zero
    end))
end
tK = fn229
t2 = function(aI, ...)
    local vQ
    local vS
    local vR
    vQ = nil
    vR = nil
    vS = nil
    vS = table.pack(...)
    vQ = false
    vR = nil
    task.spawn(function()
        vR = table.pack(pcall(aI, table.unpack(vS, 1, vS.n)))
        vQ = true
    end)
    local vT = os.clock() + 15
    while true do
        local vU = not vQ and os.clock() < vT
        if vU then
            task.wait()
            continue
        end
        break
    end
    if not vQ or not vR[1] then
        return nil
    end
    return table.unpack(vR, 2, vR.n)
end
t6 = fn410
tG = { ready = false, missing = {} }
if (not tU or uu) and (not tU and not t6) or tP and t6 and (t6 or tU) or not ((not tU or uu) and (not tU and not t6) or tP and t6 and (t6 or tU)) then
    uD = fn297
    t2(fn357)
    t0 = function(bj, ...)
        local v8
        if not tG.Mail then
            return false
        end
        v8 = table.pack(...)
        return (pcall(function()
            tG.Mail:FireServer(bj, table.unpack(v8, 1, v8.n))
        end))
    end
    us = function(bq, ...)
        local wa
        local wc_2
        local wb_2
        if not tG.Mail then
            return nil
        end
        wa = table.pack(...)
        wb_2, wc_2 = pcall(function()
            return tG.Mail:Call(bq, table.unpack(wa, 1, wa.n))
        end)
        local wd = not wb_2
        local wh = if wd then 1 else 0
        local wf = 1440 * wh + 1051 * (1 - wh)
        local wg = 2393 * wh + 312 * (1 - wh)
        if not ((wf * 3533 + wg * 3153 + wf * wg) % 16777213 == 16078569) then
            wd = type(wc_2) ~= "table"
        end
        if wd then
            return nil
        end
        return wc_2
    end
else
    t0 = fn357
    uD(t0)
    us = function(bj, ...)
        local v8
        if not tG.Mail then
            return false
        end
        v8 = table.pack(...)
        return (pcall(function()
            tG.Mail:FireServer(bj, table.unpack(v8, 1, v8.n))
        end))
    end
    t2 = function(bq, ...)
        local wa
        local wc_1
        local wb_1
        if not tG.Mail then
            return nil
        end
        wa = table.pack(...)
        wb_1, wc_1 = pcall(function()
            return tG.Mail:Call(bq, table.unpack(wa, 1, wa.n))
        end)
        local wd = not wb_1
        local wh = if wd then 1 else 0
        local wf = 1440 * wh + 1051 * (1 - wh)
        local wg = 2393 * wh + 312 * (1 - wh)
        if not ((wf * 3533 + wg * 3153 + wf * wg) % 16777213 == 16078569) then
            wd = type(wc_1) ~= "table"
        end
        if wd then
            return nil
        end
        return wc_1
    end
end
tE = function(bA, bB)
    local wj_1
    local wi_1
    if not tG.Data then
        return bB
    end
    wi_1, wj_1 = pcall(function()
        return tG.Data:Get(bA, true)
    end)
    if not wi_1 or wj_1 == nil then
        return bB
    end
    return wj_1
end
t1 = fn487
tP = fn55
uu = fn557
uk = fn598
ua = function(bT)
    local bU = {}
    pcall(function()
        for i, v in ipairs(CollectionService:GetTagged("Interaction")) do
            local wz = v:IsDescendantOf(uv) and v:GetAttribute("InteractType") == bT
            if wz then
                table.insert(bU, v)
            end
        end
    end)
    return bU
end
ud = function(b4)
    local wI_1
    local wH_1
    if typeof(b4) ~= "Instance" then
        return nil
    end
    local wM = if b4:IsA("BasePart") then 1 else 0
    if wM == 1 then
        return b4.Position
    elseif b4:IsA("Model") then
        wH_1, wI_1 = pcall(function()
            return b4:GetPivot()
        end)
        if wH_1 then
            return wI_1.Position
        end
        return nil
    else
        return nil
    end
end
tR = fn1093
tN = fn991
ui = function(cs)
    local w0 = typeof(cs) ~= "Instance" or not cs:IsA("Tool")
    if w0 then
        return false
    end
    local Character = LocalPlayer.Character
    local w1 = Character and Character:FindFirstChildOfClass("Humanoid")
    local w_ = w1
    if not w_ then
        return false
    elseif cs.Parent == Character then
        return true
    else
        pcall(function()
            w_:EquipTool(cs)
        end)
        task.wait(0.25)
        return cs.Parent == Character
    end
end
uB = fn1129
tO = fn693
uq = function(cQ, cR)
    local generation
    local xA = cQ.generation or 0
    cQ.generation = xA + 1
    cQ.stopped = false
    generation = cQ.generation
    task.spawn(function()
        local xx_1
        while true do
            local xw = tJ() and not cQ.stopped and cQ.generation == generation
            local xw_1
            if xw then
                xw_1, xx_1 = pcall(cR)
                if not xw_1 then
                    warn("[Tempo] loop error: " .. tostring(xx_1))
                end
                local xw_2 = not tJ() or cQ.stopped or cQ.generation ~= generation
                if xw_2 then
                    break
                end
                task.wait(cQ.interval)
                continue
            end
            break
        end
    end)
end
un = fn423
uc = { interval = 5 }
t8 = { interval = 1.2 }
t4 = { interval = 10 }
tZ = { interval = 4, rarities = { "Common" } }
tU = { interval = 2.5, rarities = { "Common" }, maxEggs = 3 }
tQ = { interval = 2, needRoom = true }
tI = { interval = 1.5, fruits = { "Apple" }, keep = 0, horses = {} }
tD = { interval = 5, priority = "Best Horse" }
uz = { interval = 8, rarities = {}, maxLevel = 5, keep = 1 }
local function uR()
    local xN, xO
    xO = {}
    for i, v in ipairs(ua("StableSign")) do
        if v:GetAttribute("InteractOwner") == LocalPlayer.UserId then
            table.insert(xO, v)
        end
    end
    if #xO == 0 then
        State.CollectStatus = "No owned stable sign"
        return
    end
    xN = 0
    tK(function()
        for i, v in ipairs(xO) do
            local xE = not tJ() or uc.stopped
            if xE then
                break
            else
                local xE_1 = tonumber(v:GetAttribute("StoredCash")) or 0
                local xE_2 = xE_1 > 0 and tR(v)
                if xE_2 then
                    xN += xE_1
                    task.wait(0.35)
                end
            end
        end
    end)
    local xP = xN > 0 and "Collected $" .. t7(xN)
    local xQ = xP or "Waiting for cash"
    State.CollectStatus = xQ
end
local function uT()
    local x0
    local x2_1
    local x1 = tH()
    if not x1 then
        State.AppleStatus = "No character"
        return
    end
    x0, x2_1 = nil, nil
    for i, v in ipairs(ua("Tree")) do
        local x3_1 = tonumber(v:GetAttribute("Fruit")) or 0
        if x3_1 > 0 then
            local x3_2 = ud(v)
            if x3_2 then
                local Magnitude = (x3_2 - x1.Position).Magnitude
                if not x2_1 or Magnitude < x2_1 then
                    x0, x2_1 = v, Magnitude
                end
            end
        end
    end
    if not x0 then
        State.AppleStatus = "No ripe trees"
        return
    end
    local x1_1 = x0:GetAttribute("FruitType") or "Fruit"
    local x2_2 = tostring(x1_1)
    local x1_2 = tK(function()
        return tR(x0)
    end)
    local x1_3 = x1_2 and "Picked " .. x2_2 or "Pick failed"
    State.AppleStatus = x1_3
end
uw = fn1100
uy = fn939
local function uK()
    local yY
    yY = nil
    local yX, yZ
    yY = tO(tU.rarities)
    if not next(yY) then
        State.PlaceStatus = "No rarity selected"
        return
    end
    if uy() >= math.max(1, tU.maxEggs) then
        State.PlaceStatus = "Placed limit reached"
        return
    end
    yZ = uB(function(es)
        local yL = es.Name == "Egg" and yY[tostring(es:GetAttribute("Name"))] == true
        return yL
    end)
    if not yZ then
        State.PlaceStatus = "No matching egg held"
        return
    end
    yX = tN()
    if not yX then
        State.PlaceStatus = "Base bounds unavailable"
        return
    end
    local y_ = tostring(yZ:GetAttribute("Name"))
    local y0 = tK(function()
        if not ui(yZ) then
            return false
        end
        local yN = yX.Size * 0.5
        local yO = math.max(0, yN.X - 4)
        local yP = math.max(0, yN.Z - 4)
        local yU = 1
        while yU <= 6 do
            local yN_1 = not tJ() or tU.stopped
            if yN_1 then
                return false
            end
            local yN_2 = yX.CFrame * CFrame.new((math.random() * 2 - 1) * yO, 0, (math.random() * 2 - 1) * yP)
            local yQ = CFrame.new(yN_2.X, yX.Position.Y + yX.Size.Y + 1.5, yN_2.Z)
            local yN_3 = us("RequestPlace", yQ)
            if yN_3 and yN_3.Success then
                return true
            end
            task.wait(0.25)
            yU += 1
        end
        return false
    end)
    local y__1 = y0 and "Placed " .. y_ .. " egg" or "Placement rejected"
    State.PlaceStatus = y__1
end
local function uO()
    local y6
    if tQ.needRoom then
        local y7_1 = uu()
        local y8_1 = y7_1 > 0 and tP() >= y7_1
        if y8_1 then
            State.HatchStatus = "Stable full (" .. tP() .. "/" .. y7_1 .. ")"
            return
        end
    end
    y6 = nil
    for i, v in ipairs(ua("HatchEgg")) do
        local y7_2 = v:GetAttribute("Owner") == LocalPlayer.UserId and v:GetAttribute("Ready") == true
        if y7_2 then
            y6 = v
            break
        end
    end
    if not y6 then
        State.HatchStatus = "No ready egg"
        return
    end
    local y7_3 = tK(function()
        return tR(y6)
    end)
    local y7_4 = y7_3 and "Hatched an egg" or "Hatch failed"
    State.HatchStatus = y7_4
end
tT = fn898
um = fn401
tV = fn311
local function uS()
    local zS
    local zP
    zP = nil
    zS = nil
    local zQ, zR
    zP = tO(tI.fruits)
    if not next(zP) then
        State.FeedStatus = "No fruit selected"
        return
    end
    zR = tT()
    local zT = tO(tI.horses)
    if next(zT) then
        local zU_1 = {}
        for i, v in ipairs(zR) do
            if zT[v.Name] then
                table.insert(zU_1, v)
            end
        end
        zR = zU_1
        if #zR == 0 then
            State.FeedStatus = "Chosen horse not spawned"
            return
        end
    end
    if #zR == 0 then
        State.FeedStatus = "No owned horse spawned"
        return
    end
    zS = math.max(0, tI.keep)
    zQ = uB(function(fF)
        if not zP[fF.Name] then
            return false
        end
        local zE = tonumber(fF:GetAttribute("Quantity"))
        return zE == nil or zE > zS
    end)
    if not zQ then
        State.FeedStatus = "No spare fruit"
        return
    end
    local Name = zQ.Name
    local zU_2 = tK(function()
        if not ui(zQ) then
            return false
        end
        for i, v in ipairs(zR) do
            local zH = not tJ() or tI.stopped
            if zH then
                break
            elseif tR(v) then
                return true
            end
        end
        return false
    end)
    local zT_2 = zU_2 and "Fed " .. Name
    local zZ = if zT_2 then 1 else 0
    local zX = 3124 * zZ + 3947 * (1 - zZ)
    local zY = 1731 * zZ + 3385 * (1 - zZ)
    if not ((zX * 705 + zY * 1178 + zX * zY) % 16777213 == 9649182) then
        zT_2 = "Feed failed"
    end
    State.FeedStatus = zT_2
end
t3 = { signup = nil, select = nil }
tY = fn246
uC = function()
    for k, v in pairs(t3) do
        local AZ = v
        if AZ then
            pcall(function()
                AZ:Disconnect()
            end)
            t3[k] = nil
        end
    end
end
ue = fn1075
local function uH(hi, hj, hk, hl)
    hi.SetEnabled = function(hm)
        if hm then
            uq(hi, hj)
        else
            un(hi)
            State[hl] = hk
        end
    end
end
uH(uc, uR, "Idle", "CollectStatus")
uH(t8, uT, "Idle", "AppleStatus")
uH(t4, fn377, "Idle", "UpgradeStatus")
uH(tZ, fn1128, "Idle", "BuyStatus")
uH(tU, uK, "Idle", "PlaceStatus")
uH(tQ, uO, "Idle", "HatchStatus")
uH(tI, uS, "Idle", "FeedStatus")
uH(uz, fn623, "Idle", "SellStatus")
tD.SetEnabled = fn685
uf.Track(fn843)
local function uN()
    local FP
    local FL
    local FN
    local FO
    FL = nil
    FN = nil
    FO = nil
    FP = nil
    local FM, SaveManager, FR, FS, FT, FU, ThemeManager, Options, onDiscord, FY, FZ, F_, F0, Library, Toggles
    local F3 = "v0.2"
    FP = "https://discord.gg/K7Qxnxkk46"
    FU = "https://tempohub.shop"
    F0 = "https://discord.gg/K7Qxnxkk46"
    F_ = "Race Horses"
    Library = getgenv().Library
    ThemeManager = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = Library.Toggles
    Options = Library.Options
    tM(uf, Library)
    local F4 = #tG.missing > 0 and "missing: " .. table.concat(tG.missing, ", ")
    local F5 = F4 or "bindings ready"
    local F4_1 = {}
    if tW(getgenv) then
        table.insert(F4_1, "getgenv")
    end
    local F5_1 = tW(setclipboard) or tW(toclipboard)
    if F5_1 then
        table.insert(F4_1, "clipboard")
    end
    local F5_2 = #F4_1 > 0 and table.concat(F4_1, "+")
    FT = (F5_2 or "basic") .. " | " .. F5
    FO = function(ic, id)
        local Bs = tW(setclipboard) and setclipboard
        local Bt = Bs
        if not Bt then
            local Bs_1 = tW(toclipboard) and toclipboard
            Bt = Bs_1 or nil
        end
        local Bs_2 = Bt
        if not Bs_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local Bt_1 = pcall(Bs_2, ic)
        if Bt_1 then
            Library:Notify(id)
        else
            Library:Notify("Failed to copy")
        end
    end
    onDiscord = function()
        FO(FP, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = FP, Copyable = true }, "|", F_, "|", F3 },
        Icon = 132608042600488,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(false)
    FR = {
        [1] = Window:AddTab("Info", "info"),
        [2] = Window:AddTab("Main", "gamepad-2"),
        [3] = Window:AddTab("Player", "person-standing"),
        [4] = Window:AddTab("Settings", "settings")
    }
    FM = FR[2]:AddSubTab("Stable", "warehouse")
    FY = FR[2]:AddSubTab("Eggs", "egg")
    FS = FR[2]:AddSubTab("Horses", "rabbit")
    FN = function(iv)
        iv:AddDiscordBox(nil, {
            Banner = 95892854151512,
            Avatar = 132608042600488,
            Title = "Tempo Hub",
            Subtitle = "Dupes, keyless scripts and updates",
            Status = "online",
            Accent = Color3.fromRGB(88, 101, 242),
            Link = FP,
            Buttons = { { Text = "Copy Discord Invite", Icon = "copy", Copy = true } }
        })
        return iv
    end
    local function F3_1(iy)
        return FN(iy:AddLeftGroupbox("Discord", "message-circle"))
    end
    F3_1(FM)
    F3_1(FY)
    F3_1(FS)
    F3_1(FR[3])
    F3_1(FR[4])
    local function F3_2()
        local BR
        local BP
        local BW
        local BS
        local BZ
        BP = nil
        BR = nil
        BS = nil
        BW = nil
        BZ = nil
        local BO, Label, Label3, BU, BV, Label2, BY, B_
        BZ = function(iC)
            return (tostring(iC):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
        end
        BW = function(iE, iF)
            return string.format('<font color="%s">%s</font>', iF, BZ(iE))
        end
        BO = function(iI, iJ, iK)
            return string.format("<b>%s</b> %s %s", iI, BW("-", "#5a6070"), BW(iJ, iK))
        end
        BS = "Unknown"
        BY = "#7fd47f"
        local B1 = "#8b93a3"
        BV = "#e8a34d"
        pcall(function()
            local Bx_1
            local Bw_1
            if type(identifyexecutor) == "function" then
                Bx_1, Bw_1 = identifyexecutor()
                local By = Bx_1 ~= ""
                local Bz = type(Bx_1) == "string" and By
                if Bz then
                    local By_1 = type(Bw_1) == "string" and Bw_1 ~= "" and Bx_1 .. " " .. Bw_1
                    BS = By_1 or Bx_1
                end
            end
        end)
        BP = os.clock()
        BU = function()
            local BH = math.floor(os.clock() - BP)
            if BH < 60 then
                return BH .. "s"
            elseif BH < 3600 then
                return string.format("%dm %ds", math.floor((BH) / (60)), BH % 60)
            else
                return string.format("%dh %dm", math.floor((BH) / (3600)), math.floor((BH % 3600) / (60)))
            end
        end
        local UserGroup = FR[1]:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(BO("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, BY), true)
        UserGroup:AddLabel(BO("UserId", tostring(LocalPlayer.UserId), "#6ec1ff"), true)
        UserGroup:AddLabel(BO("Executor", BS .. "  " .. FT, BY), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(BO("Session", BU(), BV), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                FO(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                FO("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        FN(FR[1]:AddRightGroupbox("Discord", "message-circle"))
        local SessionGroup = FR[1]:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(BO("Game", F_, "#6ec1ff"), true)
        Label2 = SessionGroup:AddLabel(BO("Players", "0/0", BY), true)
        B_ = tostring(game.JobId)
        local B0 = #B_ > 18 and string.sub(B_, 1, 18) .. "..."
        local B0_1 = B0 or B_
        SessionGroup:AddLabel(BO("Job", B0_1, B1), true)
        Label = SessionGroup:AddLabel(BO("Ping", "0 ms", BV), true)
        SessionGroup:AddDivider()
        SessionGroup:AddButton({
            Text = "Rejoin Place",
            Func = function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        })
        SessionGroup:AddButton({
            Text = "Copy Job ID",
            Func = function()
                FO(B_, "Copied Job ID")
            end
        })
        BR = task.spawn(function()
            local BK_1
            local BJ_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(BO("Session", BU(), BV))
                Label2:SetText(BO("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), BY))
                BJ_1, BK_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local BJ_2 = BJ_1 and BK_1 .. " ms" or "n/a"
                Label:SetText(BO("Ping", BJ_2, BV))
            end
        end)
        uf.Track(function()
            if coroutine.status(BR) ~= "dead" then
                task.cancel(BR)
            end
        end)
        local SocialsGroup = FR[1]:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                FO(F0, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                FO(FU, "Copied website link")
            end
        })
    end
    F3_2()
    FL = {}
    FZ = function(jP, jQ)
        table.insert(FL, { label = jP, key = jQ })
    end
    local function F3_3()
        local lu
        local StableGroup = FM:AddRightGroupbox("Stable", "coins")
        FZ(StableGroup:AddLabel(State.CollectStatus, true), "CollectStatus")
        StableGroup:AddToggle("AutoCollect", {
            Text = "Auto Collect",
            Default = false,
            Callback = function(jY)
                uc.SetEnabled(jY)
            end
        })
        StableGroup:AddDivider()
        FZ(StableGroup:AddLabel(State.UpgradeStatus, true), "UpgradeStatus")
        StableGroup:AddToggle("AutoUpgradeStable", {
            Text = "Auto Upgrade Stable",
            Default = false,
            Callback = function(j1)
                t4.SetEnabled(j1)
            end
        })
        local OrchardGroup = FM:AddRightGroupbox("Orchard", "apple")
        FZ(OrchardGroup:AddLabel(State.AppleStatus, true), "AppleStatus")
        OrchardGroup:AddToggle("AutoApples", {
            Text = "Auto Pick Apples",
            Default = false,
            Callback = function(j6)
                t8.SetEnabled(j6)
            end
        })
        local EggShopGroup = FY:AddRightGroupbox("Egg Shop", "shopping-cart")
        FZ(EggShopGroup:AddLabel(State.BuyStatus, true), "BuyStatus")
        EggShopGroup:AddToggle("AutoBuyEggs", {
            Text = "Auto Buy Eggs",
            Default = false,
            Callback = function(kc)
                tZ.SetEnabled(kc)
            end
        })
        EggShopGroup:AddDropdown("BuyEggRarities", {
            Text = "Egg rarities to buy",
            Values = ul,
            Default = { "Common" },
            Multi = true,
            Callback = function(ki)
                tZ.rarities = ki
            end
        })
        local PlacementGroup = FY:AddLeftGroupbox("Placement", "map-pin")
        FZ(PlacementGroup:AddLabel(State.PlaceStatus, true), "PlaceStatus")
        PlacementGroup:AddToggle("AutoPlaceEggs", {
            Text = "Auto Place Eggs",
            Default = false,
            Callback = function(kl)
                tU.SetEnabled(kl)
            end
        })
        PlacementGroup:AddDropdown("PlaceEggRarities", {
            Text = "Egg rarities to place",
            Values = ul,
            Default = { "Common" },
            Multi = true,
            Callback = function(kp)
                tU.rarities = kp
            end
        })
        PlacementGroup:AddSlider("MaxPlacedEggs", {
            Text = "Max eggs placed at once",
            Default = 3,
            Min = 1,
            Max = 10,
            Rounding = 0,
            Callback = function(kr)
                tU.maxEggs = kr
            end
        })
        local HatchingGroup = FY:AddLeftGroupbox("Hatching", "sparkles")
        FZ(HatchingGroup:AddLabel(State.HatchStatus, true), "HatchStatus")
        HatchingGroup:AddToggle("AutoHatchEggs", {
            Text = "Auto Hatch Eggs",
            Default = false,
            Callback = function(kv)
                tQ.SetEnabled(kv)
            end
        })
        HatchingGroup:AddToggle("HatchOnlyWithRoom", {
            Text = "Only hatch when the stable has room",
            Default = true,
            Callback = function(kz)
                tQ.needRoom = kz
            end
        })
        local FeedingGroup = FS:AddRightGroupbox("Feeding", "carrot")
        FZ(FeedingGroup:AddLabel(State.FeedStatus, true), "FeedStatus")
        FeedingGroup:AddToggle("AutoFeedHorses", {
            Text = "Auto Feed Horses",
            Default = false,
            Callback = function(kD)
                tI.SetEnabled(kD)
            end
        })
        FeedingGroup:AddDropdown("FeedFruits", {
            Text = "Fruit to feed",
            Values = ub,
            Default = { "Apple" },
            Multi = true,
            Callback = function(kJ)
                tI.fruits = kJ
            end
        })
        local FeedHorsesDropdown = FeedingGroup:AddDropdown("FeedHorses", {
            Text = "Horses to feed (empty feeds all)",
            Values = tV(),
            Default = {},
            Multi = true,
            AllowNull = true,
            Callback = function(kN)
                tI.horses = kN
            end
        })
        FeedingGroup:AddSlider("FeedKeep", {
            Text = "Keep this many of each fruit",
            Default = 0,
            Min = 0,
            Max = 20,
            Rounding = 0,
            Callback = function(kQ)
                tI.keep = kQ
            end
        })
        local RacingGroup = FS:AddRightGroupbox("Racing", "flag")
        FZ(RacingGroup:AddLabel(State.RaceStatus, true), "RaceStatus")
        RacingGroup:AddToggle("AutoRace", {
            Text = "Auto Race",
            Default = false,
            Callback = function(kT)
                tD.SetEnabled(kT)
            end
        })
        RacingGroup:AddDropdown("RacePriority", {
            Text = "Race priority",
            Values = { "Best Horse", "Random Horse" },
            Default = "Best Horse",
            Multi = false,
            Callback = function(kX)
                tD.priority = kX
            end
        })
        local SellingGroup = FS:AddLeftGroupbox("Selling", "hand-coins")
        FZ(SellingGroup:AddLabel(State.SellStatus, true), "SellStatus")
        SellingGroup:AddToggle("AutoSellHorses", {
            Text = "Auto Sell",
            Default = false,
            Callback = function(k_)
                uz.SetEnabled(k_)
            end
        })
        SellingGroup:AddDropdown("SellRarities", {
            Text = "Horse rarities to sell",
            Values = uh,
            Default = {},
            Multi = true,
            Callback = function(k5)
                uz.rarities = k5
            end
        })
        SellingGroup:AddSlider("SellMaxLevel", {
            Text = "Only sell up to level",
            Default = 5,
            Min = 1,
            Max = 100,
            Rounding = 0,
            Callback = function(k7)
                uz.maxLevel = k7
            end
        })
        SellingGroup:AddSlider("SellKeep", {
            Text = "Always keep this many horses",
            Default = 1,
            Min = 1,
            Max = 20,
            Rounding = 0,
            Callback = function(k9)
                uz.keep = k9
            end
        })
        local ld = table.concat(um(), "\x00")
        lu = task.spawn(function()
            local B9 = false
            repeat
                task.wait(0.5)
                if Library.Unloaded then
                    B9 = true
                else
                    for i, v in ipairs(FL) do
                        local Cf = v
                        pcall(function()
                            Cf.label:SetText(tostring(State[Cf.key]))
                        end)
                    end
                    local B5 = tV()
                    local B6 = table.concat(B5, "\x00")
                    if B6 ~= ld then
                        ld = B6
                        pcall(function()
                            FeedHorsesDropdown:SetValues(B5)
                        end)
                    end
                end
            until B9
        end)
        uf.Track(function()
            if coroutine.status(lu) ~= "dead" then
                task.cancel(lu)
            end
        end)
    end
    F3_3()
    local function F3_4()
        local lD
        local lE
        local lC
        local lF
        local MovementGroup = FR[3]:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = FR[3]:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        lD = {}
        lF = {}
        local lB = {}
        lE = {}
        lC = {}
        local function lG()
            for k, v in lC do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(lC)
        end
        local function lK()
            for k, v in lD do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(lD)
        end
        local function lO()
            for k, v in lE do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(lE)
        end
        local function lS(lT)
            if not lT:IsA("ProximityPrompt") then
                return
            end
            if lF[lT] == nil then
                lF[lT] = {
                    HoldDuration = lT.HoldDuration,
                    MaxActivationDistance = lT.MaxActivationDistance,
                    RequiresLineOfSight = lT.RequiresLineOfSight
                }
            end
            lT.HoldDuration = 0
            lT.MaxActivationDistance = 50
            lT.RequiresLineOfSight = false
        end
        local function lV()
            for k, v in lF do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(lF)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                lO()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                lK()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                lG()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                    pcall(lS, v)
                end
            else
                lV()
            end
        end)
        table.insert(lB, Workspace.DescendantAdded:Connect(function(md)
            if Toggles.InstantProximityPrompt.Value then
                lS(md)
            end
        end))
        table.insert(lB, ut.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if lC[v] == nil then
                        lC[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(lB, up.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local Da = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and Da then
                Da:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(lB, ut.RenderStepped:Connect(function(mz)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local Dg = Character and Character:FindFirstChildOfClass("Humanoid")
            local Dh = Character
            if Dh then
                Dh = Character:FindFirstChild("HumanoidRootPart")
            end
            local Df_1 = Dh
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and Dg then
                if lD[Dg] == nil then
                    lD[Dg] = Dg.WalkSpeed
                end
                Dg.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and Df_1 and Dg and CurrentCamera then
                if lE[Dg] == nil then
                    lE[Dg] = Dg.PlatformStand
                end
                Dg.PlatformStand = true
                local Dh_4 = Vector3.zero
                if not up:GetFocusedTextBox() then
                    if up:IsKeyDown(Enum.KeyCode.W) then
                        Dh_4 += CurrentCamera.CFrame.LookVector
                    end
                    if up:IsKeyDown(Enum.KeyCode.S) then
                        Dh_4 -= CurrentCamera.CFrame.LookVector
                    end
                    if up:IsKeyDown(Enum.KeyCode.A) then
                        Dh_4 -= CurrentCamera.CFrame.RightVector
                    end
                    local Dn = if up:IsKeyDown(Enum.KeyCode.D) then 1 else 0
                    if Dn == 1 then
                        Dh_4 += CurrentCamera.CFrame.RightVector
                    end
                    if up:IsKeyDown(Enum.KeyCode.Space) then
                        Dh_4 += Vector3.new(0, 1, 0)
                    end
                    local Dn_1 = if up:IsKeyDown(Enum.KeyCode.LeftControl) then 1 else 0
                    if Dn_1 == 1 then
                        Dh_4 -= Vector3.new(0, 1, 0)
                    end
                end
                Df_1.AssemblyLinearVelocity = Vector3.zero
                if Dh_4.Magnitude > 0 then
                    Df_1.CFrame = Df_1.CFrame + Dh_4.Unit * Options.FlySpeed.Value * mz
                end
            end
        end))
        uf.Track(function()
            for k, v in lB do
                v:Disconnect()
            end
            lG()
            lK()
            lO()
            lV()
        end)
    end
    F3_4()
    local function F3_5()
        local Eu, Ev, Ew, Ex, Label, Ez, EA, EB, EC, ED, EE, EF, EG, EH
        Ez = {}
        EH = {}
        EE = nil
        EF = 0
        Ev = false
        EB = 0
        Ew = os.clock()
        local MenuGroup = FR[4]:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        EC = function()
            local CurrentCamera
            CurrentCamera = Workspace.CurrentCamera
            local Dw = not CurrentCamera or not tW(uj.CaptureController) or not tW(uj.ClickButton2)
            if Dw then
                return false
            end
            local Dw_1 = pcall(function()
                uj:CaptureController()
                uj:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            end)
            if not Dw_1 then
                return false
            end
            EF += 1
            Ew = os.clock()
            pcall(function()
                Label:SetText("AFK triggers: " .. EF)
            end)
            return true
        end
        Ex = function(ni)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not ni)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not ni
                end
            end)
            if not ni then
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
        Eu = function(ny)
            if ny.ClassName == "ParticleEmitter" or ny.ClassName == "Trail" or ny.ClassName == "Smoke" or ny.ClassName == "Fire" or ny.ClassName == "Sparkles" or ny.ClassName == "Explosion" or ny.ClassName == "Beam" then
                if Ez[ny] == nil then
                    Ez[ny] = ny.Enabled
                end
                pcall(function()
                    ny.Enabled = false
                end)
            end
        end
        EG = function()
            for k, v in Ez do
                local DL = k
                local DN = v
                if DL.Parent then
                    pcall(function()
                        DL.Enabled = DN
                    end)
                end
            end
            table.clear(Ez)
            if EE then
                pcall(function()
                    settings().Rendering.QualityLevel = EE.Quality
                end)
                Lighting.GlobalShadows = EE.Shadows
                Lighting.FogEnd = EE.Fog
                EE = nil
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(nN)
                pcall(function()
                    ut:Set3dRenderingEnabled(not nN)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(nS)
                if nS then
                    if not EE then
                        EE = {
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
                    for k, v in Workspace:QueryDescendants("ParticleEmitter,Trail,Smoke,Fire,Sparkles,Beam") do
                        pcall(Eu, v)
                    end
                else
                    EG()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        Ex(true)
        local ScriptGroup = FR[4]:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiGameplayPause:OnChanged(function()
            Ex(Toggles.AntiGameplayPause.Value)
        end)
        if Toggles.AntiGameplayPause.Value then
            Ex(true)
        end
        table.insert(EH, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                EC()
            end
        end))
        table.insert(EH, Workspace.DescendantAdded:Connect(function(oa)
            if Toggles.FpsBoost.Value then
                Eu(oa)
            end
        end))
        ED = function(oe)
            local D0 = Ev
            local D5 = if D0 then 1 else 0
            local D3 = 2646 * D5 + 3854 * (1 - D5)
            local D4 = 3163 * D5 + 898 * (1 - D5)
            if not ((D3 * 2640 + D4 * 841 + D3 * D4) % 16777213 == 1237608) then
                D0 = Library.Unloaded
            end
            if not D0 then
                D0 = not Toggles.AutoReconnect.Value
            end
            if D0 then
                return
            end
            Ev = true
            local D_ = EB
            local D0_1 = pcall(function()
                if oe then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not D0_1 then
                Ev = false
                if not oe and D_ == EB then
                    task.delay(1.5, function()
                        if D_ == EB then
                            ED(true)
                        end
                    end)
                end
            end
        end
        table.insert(EH, TeleportService.TeleportInitFailed:Connect(function(oz)
            local D7
            if oz == LocalPlayer and Ev then
                Ev = false
                D7 = EB
                task.delay(3, function()
                    if D7 == EB then
                        ED(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local Ei = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            if Library.Unloaded or not Ei then
                return
            end
            table.insert(EH, Ei.ChildAdded:Connect(function(oO)
                if oO.Name == "ErrorPrompt" then
                    ED(false)
                end
            end))
        end)
        EA = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    Ex(true)
                end
                local El = Toggles.AntiAfk.Value and os.clock() - Ew >= 60
                if El then
                    EC()
                end
                task.wait(1)
            end
        end)
        uf.Track(function()
            EB += 1
            for k, v in EH do
                v:Disconnect()
            end
            pcall(task.cancel, EA)
            Ex(false)
            EG()
            pcall(function()
                ut:Set3dRenderingEnabled(true)
            end)
        end)
    end
    F3_5()
    local function F3_6()
        local Fu
        Fu = nil
        local Fv, Fw
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("TempoHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(FR[4])
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/RaceHorses")
        local Fx = SaveManager:BuildConfigSection(FR[4])
        Fu = function(pe, pf)
            local EL_1 = (pe == "Toggle" and Toggles or Options)[pf]
            local EK_2 = type(EL_1) == "table" and EL_1.Type == pe
            return EK_2 and EL_1 or nil
        end
        Fw = function(po, pp)
            local Type = pp.Type
            if Type == "Toggle" then
                return { idx = po, type = "Toggle", value = pp.Value == true }
            elseif Type == "Slider" then
                return { idx = po, type = "Slider", value = tostring(pp.Value) }
            elseif Type == "Dropdown" then
                return { idx = po, type = "Dropdown", multi = pp.Multi == true, value = pp.Value }
            elseif Type == "Input" then
                local ES_1 = pp.Value or ""
                return { idx = po, type = "Input", text = tostring(ES_1) }
            elseif Type == "ColorPicker" then
                return { idx = po, type = "ColorPicker", value = pp.Value:ToHex(), transparency = pp.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = po,
                    type = "KeyPicker",
                    key = pp.Value,
                    mode = pp.Mode,
                    syncToggleState = pp.SyncToggleState or nil
                }
            else
                return nil
            end
        end
        Fv = function(ps)
            local EV = type(ps) ~= "table" or type(ps.idx) ~= "string" or type(ps.type) ~= "string"
            if EV then
                return false
            end
            local EV_1 = Fu(ps.type, ps.idx)
            if not EV_1 then
                return false
            end
            local EW = ps.type == "Toggle" and type(ps.value) == "boolean"
            if EW then
                EV_1:SetValue(ps.value)
                return true
            elseif ps.type == "Slider" then
                local EW_1 = tonumber(ps.value)
                if EW_1 then
                    EV_1:SetValue(EW_1)
                    return true
                end
                return false
            elseif ps.type == "Dropdown" then
                EV_1:SetValue(ps.value)
                return true
            else
                local EW_2 = ps.type == "Input" and type(ps.text) == "string"
                if EW_2 then
                    EV_1:SetValue(ps.text)
                    return true
                end
                local EW_3 = ps.type == "ColorPicker" and type(ps.value) == "string"
                if EW_3 then
                    EV_1:SetValueRGB(Color3.fromHex(ps.value))
                    if type(ps.transparency) == "number" then
                        EV_1:SetTransparency(ps.transparency)
                    end
                    return true
                end
                local EW_4 = ps.type == "KeyPicker" and type(ps.key) == "string"
                if EW_4 then
                    local key = ps.key
                    local EX = ps.mode or "Toggle"
                    EV_1:SetValue({ key, EX })
                    return true
                end
                return false
            end
        end
        Fx:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Default = "", Finished = true, AllowEmpty = true })
        Fx:AddButton({
            Text = "Export Config to Clipboard",
            Func = function()
                local E3_2
                local E2_4
                local E1 = {}
                for k, v in Toggles do
                    if k ~= "MenuKeybind" then
                        local E2_1 = Fw(k, v)
                        if E2_1 then
                            table.insert(E1, E2_1)
                        end
                    end
                end
                for k, v in Options do
                    if k ~= "MenuKeybind" and k ~= "SaveManager_ImportSource" then
                        local E2_3 = Fw(k, v)
                        if E2_3 then
                            table.insert(E1, E2_3)
                        end
                    end
                end
                table.sort(E1, function(pH, pI)
                    return pH.idx < pI.idx
                end)
                E2_4, E3_2 = pcall(ug.JSONEncode, ug, { objects = E1 })
                if not E2_4 then
                    Library:Notify("Failed to encode config")
                    return
                end
                FO(E3_2, "Copied config to clipboard")
            end
        })
        Fx:AddButton({
            Text = "Import Config from Clipboard Text",
            Func = function()
                local Fi = Options.SaveManager_ImportSource and Options.SaveManager_ImportSource.Value or ""
                local Fi_2
                local Fi_1 = Fi == ""
                local Fj = type(Fi) ~= "string" or Fi_1
                local Fj_1
                if Fj then
                    Library:Notify("Paste a config first")
                    return
                end
                if #Fi > 262144 then
                    Library:Notify("That config is too large")
                    return
                end
                Fi_2, Fj_1 = pcall(ug.JSONDecode, ug, Fi)
                local Fh_2 = not Fi_2 or type(Fj_1) ~= "table" or type(Fj_1.objects) ~= "table"
                if Fh_2 then
                    Library:Notify("That is not a valid exported config")
                    return
                end
                if #Fj_1.objects > 2048 then
                    Library:Notify("That config has too many records")
                    return
                end
                local Fh_3 = 0
                for i, v in ipairs(Fj_1.objects) do
                    if Fv(v) then
                        Fh_3 += 1
                    end
                end
                if Fh_3 == 0 then
                    Library:Notify("No settings in that config matched this script")
                    return
                end
                Options.SaveManager_ImportSource:SetValue("")
                local Fj_2 = Fh_3 == 1 and "" or "s"
                Library:Notify(("Imported %d setting%s"):format(Fh_3, Fj_2), 6)
            end
        })
        ThemeManager:LoadDefault()
        SaveManager:LoadAutoloadConfig()
        local Fx_1 = {
            {
                "BuyEggRarities",
                function(p2)
                    tZ.rarities = p2
                end
            },
            {
                "PlaceEggRarities",
                function(p5)
                    tU.rarities = p5
                end
            },
            {
                "MaxPlacedEggs",
                function(p8)
                    tU.maxEggs = p8
                end
            },
            {
                "FeedFruits",
                function(qa)
                    tI.fruits = qa
                end
            },
            {
                "FeedHorses",
                function(qd)
                    tI.horses = qd
                end
            },
            {
                "FeedKeep",
                function(qf)
                    tI.keep = qf
                end
            },
            {
                "RacePriority",
                function(qh)
                    tD.priority = qh
                end
            },
            {
                "SellRarities",
                function(qk)
                    uz.rarities = qk
                end
            },
            {
                "SellMaxLevel",
                function(qn)
                    uz.maxLevel = qn
                end
            },
            {
                "SellKeep",
                function(qp)
                    uz.keep = qp
                end
            }
        }
        for i, v in ipairs(Fx_1) do
            local Fx_2 = Options[v[1]]
            if Fx_2 then
                v[2](Fx_2.Value)
            end
        end
        if Toggles.HatchOnlyWithRoom then
            tQ.needRoom = Toggles.HatchOnlyWithRoom.Value
        end
        local Fx_3 = {
            { "AutoCollect", uc },
            { "AutoUpgradeStable", t4 },
            { "AutoApples", t8 },
            { "AutoBuyEggs", tZ },
            { "AutoPlaceEggs", tU },
            { "AutoHatchEggs", tQ },
            { "AutoFeedHorses", tI },
            { "AutoRace", tD },
            { "AutoSellHorses", uz }
        }
        for i, v in ipairs(Fx_3) do
            local Fx_4 = Toggles[v[1]]
            if Fx_4 then
                v[2].SetEnabled(Fx_4.Value)
            end
        end
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    F3_6()
end
uU_1, uV_1 = pcall(uN)
if not uU_1 then
    local uE_1 = 3
    repeat
        local uF_1 = { "amfvkv", "qgbeuuak", "hgcz", "mjfumqkmlm", "lsgotdds", "nyswpk", "nmljnfxrd" }
        local HQ = uE_1
        local uG_1 = uF_1[HQ % 7 + 1]
        if uG_1:len() >= uG_1:reverse():rep(HQ % 3 + 2):len() then
            pcall(uV_1.Unload)
            error(uf, 0)
        else
            pcall(uf.Unload)
            error(uV_1, 0)
        end
        uE_1 = (uE_1 + 1) % 4
    until (uE_1 * 3 + 1) % 4 == 1
end
end)(...)

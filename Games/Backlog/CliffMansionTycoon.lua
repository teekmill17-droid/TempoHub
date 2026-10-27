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
getgenv().TempoHoodSubtitle = "CLIFF MANSION TYCOON"
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
local HttpService
local hJ
local hq
local g4
local VirtualUser
local connection3
local SaveManager
local connection5
local hd
local UserInputService
local hg
local hC
local connection
local hj
local hF
local gY
local hm
local hI
local g0
local hp
local g3
local hs
local g6
local hv
local g9
local hc
local connection4
local hf
local hB
local gX
local hi
local hE
local g_
local ReplicatedStorage
local connection2
local Utils
local ho
local hK
local g5
local Toggles
local g8
local hu
local hb
local hx
local CurrentCamera
local hA
local LocalPlayer
local gW
local hD
local Options
local Library
local gZ
local g1
local function onRenderStepped(cE)
    if Library.Unloaded or not Toggles or not Options then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local ka_3 = g8()
        if ka_3 then
            ka_3.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local ka_5 = hK()
        local kb_1 = g8()
        if ka_5 and kb_1 then
            kb_1.PlatformStand = true
            local kb_2 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                kb_2 = kb_2 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                kb_2 = kb_2 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                kb_2 = kb_2 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                kb_2 = kb_2 + CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                kb_2 = kb_2 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                kb_2 = kb_2 - Vector3.new(0, 1, 0)
            end
            ka_5.Velocity = Vector3.zero
            if kb_2.Magnitude > 0 then
                ka_5.CFrame = ka_5.CFrame + kb_2.Unit * Options.FlySpeed.Value * cE
            end
        end
    end
end
local function onInputBegan()
    hp = tick()
end
local function fn41()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    hj = tick()
end
local function onCopyLitecoinAddress()
    hf(g_, "Copied Litecoin address")
end
local function onRscripts()
    if setclipboard then
        setclipboard(g5)
    elseif toclipboard then
        toclipboard(g5)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function fn140(dH, dI)
    local kR_1 = (dH == "Toggle" and Toggles or Options)[dI]
    local kQ_2 = type(kR_1) == "table" and kR_1.Type == dH
    return kQ_2 and kR_1 or nil
end
local function fn144()
    if not hs then
        return false
    end
    local jw = if gZ() < 1 then 1 else 0
    if jw == 1 then
        return false
    end
    local jl = hm() or 0
    local jl_1 = gZ()
    hs:FireServer("CollectMoney")
    task.wait(0.4)
    local jn = hm() or 0
    local jn_1 = gZ()
    if jn > jl or jn_1 < jl_1 then
        hE = 0
        return true
    end
    hE = hE + 1
    if hE >= 2 then
        local jl_2 = ho()
        local jm_1 = hD(jl_2)
        if jm_1 and jm_1.CanTouch then
            hb(jm_1)
            task.wait(0.4)
            hs:FireServer("CollectMoney")
        end
        hE = 0
    end
    return false
end
local function fn146(br)
    if not br then
        return nil
    end
    local i6 = br:FindFirstChild("Base") and br.Base:FindFirstChild("Production")
    if i6 then
        local TouchArea = i6:FindFirstChild("TouchArea")
        local i7_1 = TouchArea and TouchArea:IsA("BasePart")
        if i7_1 then
            return TouchArea
        end
        return nil
    end
    return nil
end
local function onInputChanged(dj)
    local UserInputType = dj.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        hp = tick()
    end
end
local function onCopyPayPalLink()
    hf(hv, "Copied PayPal link")
end
local function onCopySolanaAddress()
    hf(hC, "Copied Solana address")
end
local function worker()
    local iD_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local iC = math.floor(os.clock() - g4)
        if iC < 60 then
            iD_1 = iC .. "s"
        elseif iC < 3600 then
            iD_1 = string.format("%dm %ds", math.floor((iC) / (60)), iC % 60)
        else
            iD_1 = string.format("%dh %dm", math.floor((iC) / (3600)), math.floor((iC % 3600) / (60)))
        end
        hA:SetText(gY("Session time", iD_1, hg))
    end
end
local function fn213()
    local iH_1
    local iG_1
    if not hs then
        return nil
    end
    iG_1, iH_1 = pcall(function()
        return hs:InvokeFunction("GetValue", "Coins")
    end)
    local iI = iG_1 and type(iH_1) == "table"
    if iI then
        return iH_1.Main or 0
    end
    return nil
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            hx(true)
        end
    end
end
local function fn225(L, M)
    return string.format('<font color="%s">%s</font>', M, L)
end
local function onUnload()
    Library:Unload()
end
local function onImportConfigFromClipboardTex()
    local lz_1
    local lx = Options.SaveManager_ImportSource.Value
    local lx_1
    local lD = if lx then 1 else 0
    local lB = 2633 * lD + 229 * (1 - lD)
    local lC = 3584 * lD + 3499 * (1 - lD)
    if not ((lB * 87 + lC * 3620 + lB * lC) % 16777213 == 5862610) then
        lx = ""
    end
    local ly = tostring(lx):match("^%s*(.-)%s*$")
    if ly == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    lx_1, lz_1 = pcall(HttpService.JSONDecode, HttpService, ly)
    local ly_1 = not lx_1 or type(lz_1) ~= "table" or type(lz_1.objects) ~= "table"
    if ly_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local lx_2 = 0
    for i, v in ipairs(lz_1.objects) do
        if hI(v) then
            lx_2 += 1
        end
    end
    if lx_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local lz_2 = lx_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(lx_2, lz_2), 6)
end
local function onCopyUSDTAddress()
    hf(hF, "Copied USDT address")
end
local function onCopyBitcoinAddress()
    hf(gW, "Copied Bitcoin address")
end
local function onCopyJoinScript_JobID()
    local iA = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, hu)
    if setclipboard then
        setclipboard(iA)
    elseif toclipboard then
        toclipboard(iA)
    end
    Library:Notify("Copied join script to clipboard")
end
local function fn311()
    connection4:Disconnect()
    connection5:Disconnect()
    connection:Disconnect()
    connection2:Disconnect()
    connection3:Disconnect()
end
local function onCopyVenmoLink()
    hf(hq, "Copied Venmo link")
end
local function onJumpRequest()
    if Library.Unloaded or not Toggles then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local j4_2 = g8()
        if j4_2 then
            j4_2:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn428()
    local Character = LocalPlayer.Character
    local jL = Character and Character:FindFirstChildOfClass("Humanoid")
    return jL
end
local function fn439()
    hf(hc, "Copied Discord invite to clipboard")
end
local function fn473()
    hx(false)
end
local function fn480(bm)
    if not bm then
        return nil
    end
    for i, descendant in bm:GetDescendants() do
        local iW = descendant:IsA("Folder") and descendant.Name == "Buttons" and #descendant:GetChildren() > 0
        if iW then
            return descendant
        end
    end
    return nil
end
local function fn484()
    for i, child in workspace:GetChildren() do
        local iO = child:IsA("Model") and child.Name:match("^Mansion_1_" .. LocalPlayer.Name .. "$")
        if iO then
            return child
        end
    end
    return nil
end
local function fn515(O, P, Q)
    return string.format("<b>%s</b> %s %s", O, g6("-", "#5a6070"), g6(P, Q))
end
local function fn530()
    hx(Toggles.AntiGameplayPause.Value)
end
local function fn534()
    local jx = ho()
    local jy = g3(jx)
    if not jy then
        return false
    end
    local jx_1 = false
    for i, child in jy:GetChildren() do
        if Library.Unloaded then
            break
        elseif not (child:GetAttribute("ActorClass") ~= "GeneratorPointActor") then
            local Button = child:FindFirstChild("Button")
            local jz = not Button or not Button:IsA("BasePart") or not Button.CanTouch
            if not jz then
                local jz_1 = Utils and Utils:GetActorIface(child)
                if jz_1 then
                    jz_1:FireServer("GeneratorResponse", LocalPlayer)
                    jx_1 = true
                else
                    hb(Button)
                    task.wait(0.3)
                    jx_1 = true
                end
                task.wait(0.35)
            end
        end
    end
    return jx_1
end
local function fn541()
    local iL_1
    local iK_1
    if not hs then
        return 0
    end
    iK_1, iL_1 = pcall(function()
        return hs:InvokeFunction("GetValue", "ProducedMoney")
    end)
    local iM = iK_1 and type(iL_1) == "number"
    if iM then
        return iL_1
    end
    return 0
end
local function fn547()
    local k3 = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local k4 = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if k4 then
                local k4_1 = hd(k, v)
                if k4_1 then
                    k3[#k3 + 1] = k4_1
                end
            end
        end
    end
    table.sort(k3, function(d1, d2)
        if d1.type ~= d2.type then
            return d1.type < d2.type
        end
        return d1.idx < d2.idx
    end)
    return { objects = k3 }
end
local function fn561(dP, dQ)
    local Type = dQ.Type
    if Type == "Toggle" then
        return { idx = dP, type = "Toggle", value = dQ.Value == true }
    elseif Type == "Slider" then
        return { idx = dP, type = "Slider", value = tostring(dQ.Value) }
    elseif Type == "Dropdown" then
        return { idx = dP, type = "Dropdown", multi = dQ.Multi == true, value = dQ.Value }
    elseif Type == "Input" then
        local kY = dQ.Value or ""
        return { idx = dP, type = "Input", text = tostring(kY) }
    elseif Type == "ColorPicker" then
        return { idx = dP, type = "ColorPicker", value = dQ.Value:ToHex(), transparency = dQ.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = dP,
            type = "KeyPicker",
            mode = dQ.Mode,
            key = dQ.Value,
            modifiers = dQ.Modifiers,
            toggled = dQ.Toggled
        }
    else
        return nil
    end
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local kM = tick() - hp
            local kN = tick() - hj
            if kM >= 300 and kN >= 60 then
                pcall(g0)
            else
                if kM < 300 and kN >= 300 then
                    pcall(g0)
                end
            end
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
                local jT_3 = descendant:IsA("BasePart") and descendant.CanCollide
                if jT_3 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn629(w, x)
    if setclipboard then
        setclipboard(w)
    elseif toclipboard then
        toclipboard(w)
    end
    Library:Notify(x)
end
local function onCopyEthereumAddress()
    hf(hJ, "Copied Ethereum address")
end
local function fn648(bx)
    local Character = LocalPlayer.Character
    if not Character then
        return false
    end
    local Humanoid = Character:FindFirstChild("Humanoid")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not HumanoidRootPart then
        return false
    end
    Humanoid.PlatformStand = true
    HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    Character:PivotTo(bx.CFrame * CFrame.new(0, 1.4, 0))
    task.wait(0.25)
    HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    Humanoid.PlatformStand = false
    return true
end
local function fn650()
    if not Toggles.WalkSpeedEnabled.Value then
        local kp = g8()
        if kp then
            kp.WalkSpeed = 16
        end
    end
end
local function fn665()
    Utils = require(ReplicatedStorage.Scripts.Core.Utils.Utils)
end
local function fn685()
    local it_1
    local is_1
    if identifyexecutor then
        it_1, is_1 = identifyexecutor()
        local iu = it_1 ~= ""
        local iv = type(it_1) == "string" and iu
        if iv then
            local iu_1 = type(is_1) == "string" and is_1 ~= "" and it_1 .. " " .. is_1
            g9 = iu_1 or it_1
        end
    end
end
local function fn733()
    if not Toggles.Fly.Value then
        local kk = g8()
        if kk then
            kk.PlatformStand = false
        end
    end
end
local function autoBuyLoop()
    while not Library.Unloaded do
        if Toggles.AutoBuy.Value then
            pcall(hi)
        end
        task.wait(Options.BuyInterval.Value)
    end
end
local function onExportConfigToClipboard()
    local lu_1
    local lt_1
    lt_1, lu_1 = pcall(HttpService.JSONEncode, HttpService, gX())
    if not lt_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local lt_2 = setclipboard or toclipboard
    local lt_3 = type(lt_2) ~= "function" or not pcall(lt_2, lu_1)
    if lt_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function fn813(F)
    local DiscordGroup = F:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = g1 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = g1 })
end
local function autoCollectLoop()
    while not Library.Unloaded do
        if Toggles.AutoCollect.Value then
            pcall(hB)
        end
        task.wait(Options.CollectInterval.Value)
    end
end
local function fn822()
    local Character = LocalPlayer.Character
    local jR = Character and Character:FindFirstChild("HumanoidRootPart")
    return jR
end
connection = nil
gW = nil
gX = nil
gY = nil
gZ = nil
g_ = nil
g0 = nil
g1 = nil
Utils = nil
g3 = nil
g4 = nil
g5 = nil
g6 = nil
connection3 = nil
g8 = nil
g9 = nil
connection5 = nil
hb = nil
hc = nil
hd = nil
CurrentCamera = nil
hf = nil
hg = nil
LocalPlayer = nil
hi = nil
hj = nil
Options = nil
connection2 = nil
hm = nil
HttpService = nil
ho = nil
hp = nil
hq = nil
Toggles = nil
hs = nil
VirtualUser = nil
hu = nil
hv = nil
SaveManager = nil
hx = nil
connection4 = nil
UserInputService = nil
hA = nil
hB = nil
hC = nil
hD = nil
hE = nil
hF = nil
Library = nil
ReplicatedStorage = nil
hI = nil
hJ = nil
hK = nil
local hL
local GameInfoGroup
local hW_1
local hU_1
local hV_1
local hP_1
local hN_1, hN_4
local hQ_1
ReplicatedStorage, UserInputService, VirtualUser, HttpService, LocalPlayer, hc, g5, Utils, Library, SaveManager, Toggles, Options, hU_1, hf, g1, hQ_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
LocalPlayer = Players.LocalPlayer
local hR = "Cliff Mansion Tycoon"
hc = "https://discord.gg/K7Qxnxkk46"
g5 = "https://discord.gg/K7Qxnxkk46"
pcall(fn665)
setthreadidentity(8)
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
hf = fn629
g1 = fn439
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = hc, Copyable = true }, "|", hR },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
local hO_2
if (hQ_1 and not LocalPlayer or (Options or LocalPlayer)) and (ThemeManager and ThemeManager or (ThemeManager or Options)) and (hQ_1 or LocalPlayer or g1 and hQ_1 or hf and not ThemeManager and (not hf and not hf)) and (((not g1 or hf) and (not hQ_1 or hf) or (not ThemeManager or Options or (Options or not hQ_1))) and ((not ThemeManager or hf) and (not LocalPlayer or not g1) or (Options or not hQ_1) and (not hQ_1 or not hQ_1))) and not ((hQ_1 and not LocalPlayer or (Options or LocalPlayer)) and (ThemeManager and ThemeManager or (ThemeManager or Options)) and (hQ_1 or LocalPlayer or g1 and hQ_1 or hf and not ThemeManager and (not hf and not hf)) and (((not g1 or hf) and (not hQ_1 or hf) or (not ThemeManager or Options or (Options or not hQ_1))) and ((not ThemeManager or hf) and (not LocalPlayer or not g1) or (Options or not hQ_1) and (not hQ_1 or not hQ_1)))) then
    local hO_1 = {
        Player = hU_1:AddTab("Player", "person-standing"),
        Settings = hU_1:AddTab("Settings", "settings"),
        Main = hU_1:AddTab("Main", "gavel"),
        Info = hU_1:AddTab("Info", "info")
    }
else
    hU_1 = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gavel"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
end
for k, v in hU_1 do
    fn813(v)
end
hW_1, hV_1, hg, hP_1, g9, hN_1, GameInfoGroup, hA, hu, hO_2, g6, gY = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local hM_1 = 58
repeat
    local hQ_3 = (hM_1 * 1 + 0) % 8 + 1
    if hQ_3 <= 4 then
        if hQ_3 <= 2 then
            if hQ_3 <= 1 then
                local hY_1 = (vector.create((hM_1 * 1 + 2) % 11 + 1, (hM_1 * 1 + 2) % 13 + 1, (hM_1 * 13 + 4) % 17 + 1))
                local hZ_1 = (vector.create((hM_1 * 2 + 5) % 11 + 1, (hM_1 * 11 + 3) % 13 + 1, (hM_1 * 7 + 4) % 17 + 1))
                local mi = vector.dot(hY_1, hZ_1)
                if mi * mi >= vector.dot(hY_1, hY_1) * vector.dot(hZ_1, hZ_1) + 1 then
                    hP_1 = tostring(game.JobId)
                else
                    hu = tostring(game.JobId)
                end
                hM_1 = (hM_1 + 1) % 64
            else
                local mx = bit32.rrotate(bit32.bxor(bit32.lrotate(hM_1, 6), string.byte(tostring(hA))), 8)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(mx, 1055223997), 3479992763), (bit32.bxor(bit32.band(mx, 3239743298), 250330579))), 3479992763), 250330579) == mx then
                    hO_2 = #hu > 18
                else
                    hu = #hO_2 > 18
                end
                hM_1 = (hM_1 + 17) % 64
            end
        elseif hQ_3 <= 3 then
            local hY_2 = (vector.create((hM_1 * 7 + 9) % 11 + 1, (hM_1 * 4 + 7) % 13 + 1, (hM_1 * 5 + 15) % 17 + 1))
            local mj = vector.floor(hY_2) + vector.ceil(hY_2 * -1)
            if vector.dot(mj, mj) == 3 then
                gY = fn225
            else
                g6 = fn225
            end
            hM_1 = (hM_1 + 9) % 64
        else
            local hY_3 = (vector.create((hM_1 * 5 + 2) % 11 + 1, (hM_1 * 4 + 12) % 13 + 1, (hM_1 * 5 + 1) % 17 + 1))
            local hZ_2 = (vector.create((hM_1 * 2 + 7) % 11 + 1, (hM_1 * 7 + 9) % 13 + 1, (hM_1 * 5 + 7) % 17 + 1))
            local mB = vector.cross(hY_3, hZ_2)
            local mC = vector.dot(hY_3, hZ_2)
            if vector.dot(mB, mB) + mC * mC == vector.dot(hY_3, hY_3) * vector.dot(hZ_2, hZ_2) + 5 then
                hA = fn515
            else
                gY = fn515
            end
            hM_1 = (hM_1 + 41) % 64
        end
    elseif hQ_3 <= 6 then
        if hQ_3 <= 5 then
            if hM_1 * 27443243 + 9 + 3 >= hM_1 * 27443243 + 9 + 3 + 1 then
                hO_2 = "#7fd47f"
            else
                hW_1 = "#7fd47f"
            end
            hM_1 = (hM_1 + 25) % 64
        else
            if (hN_1 or not hN_1 or not hN_1 and hM_1) and ((hN_1 or hN_1) and (hM_1 and hN_1)) or (hM_1 or not hM_1) and (hM_1 or not hN_1) and (not hM_1 or hN_1 or not hM_1 and hM_1) or ((hN_1 or false) and (not hN_1 or false) or (hW_1 or hN_1) and (hW_1 and not hN_1)) and (false or (hW_1 or not hM_1) and (hW_1 and hM_1)) or not ((hN_1 or not hN_1 or not hN_1 and hM_1) and ((hN_1 or hN_1) and (hM_1 and hN_1)) or (hM_1 or not hM_1) and (hM_1 or not hN_1) and (not hM_1 or hN_1 or not hM_1 and hM_1) or ((hN_1 or false) and (not hN_1 or false) or (hW_1 or hN_1) and (hW_1 and not hN_1)) and (false or (hW_1 or not hM_1) and (hW_1 and hM_1))) then
                hV_1 = "#6ec1ff"
            else
                gY = "#6ec1ff"
            end
            hM_1 = (hM_1 + 25) % 64
        end
    elseif hQ_3 <= 7 then
        local hQ_4 = (vector.create((hM_1 * 6 + 8) % 11 + 1, (hM_1 * 4 + 6) % 13 + 1, (hM_1 * 11 + 6) % 17 + 1))
        local hY_4 = (vector.create((hM_1 * 2 + 4) % 11 + 1, (hM_1 * 8 + 4) % 13 + 1, (hM_1 * 13 + 7) % 17 + 1))
        local mc = vector.dot(hQ_4, hY_4)
        if mc * mc <= vector.dot(hQ_4, hQ_4) * vector.dot(hY_4, hY_4) then
            hg = "#e8a34d"
        else
            hA = "#e8a34d"
        end
        hM_1 = (hM_1 + 57) % 64
    else
        local hQ_5 = {
            "qqb",
            "kldtcosbh",
            "mtsqphcbcacg",
            "cynrwlbsz",
            "hmixjmcpdlip",
            "pxsjgx",
            "xngcdaf",
            "sajqdjoidbr",
            "toxy",
            "cvsuktuoqc",
            "lfdug",
            "rkeqpse",
            "oniol",
            "zuocnnhpqv",
            "qktqdujpbus",
            "gwqiqbcgqq"
        }
        if hQ_5[(hM_1 * 85 + 111) % 16 + 1] <= hQ_5[(hM_1 * 85 + 111) % 16 + 1] then
            hP_1 = "#8b93a3"
            g9 = "Unknown"
            pcall(fn685)
            hN_1 = hU_1.Info:AddLeftGroupbox("Account", "circle-user")
            hN_1:AddLabel(gY("User", LocalPlayer.Name, hW_1), true)
            hN_1:AddLabel(gY("Status", "Keyless", hW_1), true)
            hN_1:AddLabel(gY("Executor", g9, hW_1), true)
            GameInfoGroup = hU_1.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            GameInfoGroup:AddLabel(g6(hR .. " [" .. tostring(game.PlaceId) .. "]", hV_1), true)
            GameInfoGroup:AddLabel(gY("Place ID", tostring(game.PlaceId), hV_1), true)
            hA = GameInfoGroup:AddLabel(gY("Session time", "0s", hg), true)
        else
            hA = "#8b93a3"
            hN_1 = "Unknown"
            pcall(fn685)
            hU_1 = hP_1.Info:AddLeftGroupbox("Account", "circle-user")
            hU_1:AddLabel(hR("User", gY.Name, GameInfoGroup), true)
            hU_1:AddLabel(hR("Status", "Keyless", GameInfoGroup), true)
            hU_1:AddLabel(hR("Executor", "Unknown", GameInfoGroup), true)
            hV_1 = hP_1.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            hV_1:AddLabel(LocalPlayer(hW_1 .. " [" .. tostring(game.PlaceId) .. "]", g6), true)
            hV_1:AddLabel(hR("Place ID", tostring(game.PlaceId), g6), true)
            hg = hV_1:AddLabel(hR("Session time", "0s", g9), true)
        end
        hM_1 = (hM_1 + 41) % 64
    end
until (hM_1 * 47 + 39) % 64 == 53
if hO_2 then
    local hM_2 = 3
    repeat
        local hN_2 = (vector.create((hM_2 * 3 + 5) % 11 + 1, (hM_2 * 4 + 9) % 13 + 1, (hM_2 * 2 + 10) % 17 + 1))
        local hQ_6 = (vector.create((hM_2 * 6 + 7) % 11 + 1, (hM_2 * 7 + 1) % 13 + 1, (hM_2 * 10 + 1) % 17 + 1))
        local mz = vector.dot(hN_2, hQ_6)
        if mz * mz >= vector.dot(hN_2, hN_2) * vector.dot(hQ_6, hQ_6) + 1 then
            hu = string.sub(hO_2, 1, 18) .. "..."
        else
            hO_2 = string.sub(hu, 1, 18) .. "..."
        end
        hM_2 = (hM_2 + 4) % 8
    until (hM_2 * 3 + 7) % 8 == 4
end
local hM_3 = hO_2 or hu
g4, g_, gW, hJ, hF, hC, hv, hq = nil, nil, nil, nil, nil, nil, nil, nil
GameInfoGroup:AddLabel(gY("Server", hM_3, hP_1), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
g4 = os.clock()
task.spawn(worker)
local ScriptsGroup = hU_1.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(g6("Included in this hub", hP_1), true)
ScriptsGroup:AddLabel(g6(hR, hV_1), true)
local FeaturesGroup = hU_1.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(g6("Auto Collect Income", hV_1), true)
FeaturesGroup:AddLabel(g6("Auto Buy All Buttons", hg), true)
FeaturesGroup:AddLabel(g6("Player Movement", hP_1), true)
local SocialsGroup = hU_1.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = g1 })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = hU_1.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = g1 })
g_ = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
gW = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
hJ = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
hF = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
hC = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
hv = ""
hq = ""
local h6 = "#345d9d"
local h3 = "#f7931a"
local h1 = "#627eea"
local h0 = "#26a17b"
local h_ = "#14f195"
local hY_5 = "#0070ba"
local hO_3 = "#008cff"
local DonationsGroup = hU_1.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(g6("All donations are optional but appreciated.", hg), true)
DonationsGroup:AddLabel(g6("If you donate you get a special role, just PING after you donate.", hW_1), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(g6("LTC / Litecoin", h6), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(g6("BTC / Bitcoin", h3), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(g6("ETH / Ethereum", h1), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(g6("USDT", h0), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(g6("Solana", h_), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(g6("PayPal", hY_5), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(g6("Venmo", hO_3), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(g6("Don't have any of the listed currencies but still wanna donate?", hP_1), true)
DonationsGroup:AddLabel(g6("DM me and we'll work something out.", hV_1), true)
local FaqGroup = hU_1.Info:AddRightGroupbox("FAQ", "circle-help")
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
local h9 = Utils and Utils:GetActorIface(LocalPlayer)
hs, hE, hN_4, connection, connection2, CurrentCamera, connection3, hp, hj, connection4, connection5, hm, gZ, ho, g3, hD, hb, hB, hi, g8, hK, hx, g0, hL, hd, gX, hI = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
hs = h9
hm = fn213
gZ = fn541
if (not gX or gX or g3 and g3) and (not gX or not hN_4 or gX and gX) and (not hN_4 and not g3 and (g3 and g3) or not g3 and not g3 and (not hN_4 or not g3)) and ((not hN_4 or hN_4) and (hN_4 or not g3) or (not hN_4 and gX or not hN_4 and not g3) or (not gX or gX) and (not gX and gX) and ((not gX or not hN_4) and (gX or hN_4))) or not ((not gX or gX or g3 and g3) and (not gX or not hN_4 or gX and gX) and (not hN_4 and not g3 and (g3 and g3) or not g3 and not g3 and (not hN_4 or not g3)) and ((not hN_4 or hN_4) and (hN_4 or not g3) or (not hN_4 and gX or not hN_4 and not g3) or (not gX or gX) and (not gX and gX) and ((not gX or not hN_4) and (gX or hN_4)))) then
    ho = fn484
    g3 = fn480
else
    g3 = fn484
    ho = fn480
end
hD = fn146
hb = fn648
hE = 0
hB = fn144
hi = fn534
local MailboxGroup = hU_1.Main:AddLeftGroupbox("Mailbox", "banknote")
MailboxGroup:AddToggle("AutoCollect", { Text = "Auto Collect Income", Default = false })
MailboxGroup:AddSlider("CollectInterval", { Text = "Collect Interval", Default = 2, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
local PurchasesGroup = hU_1.Main:AddRightGroupbox("Purchases", "shopping-cart")
PurchasesGroup:AddToggle("AutoBuy", { Text = "Auto Buy All Buttons", Default = false })
PurchasesGroup:AddSlider("BuyInterval", { Text = "Buy Interval", Default = 1.5, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
task.spawn(autoCollectLoop)
task.spawn(autoBuyLoop)
local MovementGroup = hU_1.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = hU_1.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
g8 = fn428
hK = fn822
connection = RunService.Stepped:Connect(onStepped)
connection2 = UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
connection3 = RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn733)
Toggles.WalkSpeedEnabled:OnChanged(fn650)
hx = function(cV)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not cV)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not cV
        end
    end)
    if not cV then
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
Toggles.AntiGameplayPause:OnChanged(fn530)
task.spawn(antiGameplayPauseLoop)
Library:OnUnload(fn473)
local MenuGroup = hU_1.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
hp = tick()
hj = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local kD = v
        pcall(function()
            kD:Disable()
        end)
    end
end)
g0 = fn41
connection4 = UserInputService.InputBegan:Connect(onInputBegan)
connection5 = UserInputService.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(antiAfkLoop)
MenuGroup:AddButton("Unload", onUnload)
Library:OnUnload(fn311)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Linoria")
ThemeManager:ApplyToTab(hU_1.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/CliffMansionTycoon")
local hM_4 = SaveManager:BuildConfigSection(hU_1.Settings)
SaveManager:LoadAutoloadConfig()
hL = fn140
hd = fn561
gX = fn547
hI = function(d4)
    local ln
    ln = nil
    local lo = type(d4) ~= "table" or type(d4.idx) ~= "string"
    local ls = if lo then 1 else 0
    local lq = 2977 * ls + 2623 * (1 - ls)
    local lr = 255 * ls + 2089 * (1 - ls)
    if not ((lq * 3625 + lr * 3644 + lq * lr) % 16777213 == 12479980) then
        lo = type(d4.type) ~= "string"
    end
    if not lo then
        lo = SaveManager.Ignore[d4.idx]
    end
    if lo then
        return false
    end
    ln = hL(d4.type, d4.idx)
    if not ln then
        return false
    end
    local lo_1 = pcall(function()
        if d4.type == "Input" then
            if type(d4.text) ~= "string" then
                return
            end
            ln:SetValue(d4.text)
        elseif d4.type == "ColorPicker" then
            ln:SetValueRGB(Color3.fromHex(d4.value), d4.transparency)
        elseif d4.type == "KeyPicker" then
            ln:SetValue({ d4.key, d4.mode, d4.modifiers })
            if d4.mode == "Toggle" and d4.toggled ~= nil then
                ln.Toggled = d4.toggled
                ln:Update()
            end
        else
            ln:SetValue(d4.value)
        end
    end)
    return lo_1
end
hM_4:AddDivider()
hM_4:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
hM_4:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
hM_4:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
end)(...)

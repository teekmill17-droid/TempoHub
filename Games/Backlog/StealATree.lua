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
getgenv().TempoHoodSubtitle = "STEAL A TREE!"
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
local pH
local qo
local po
local p5
local Workspace
local TrailDictionary
local pu
local pT
local pA
local qh
local RebirthDictionary
local pZ
local pG
local qn
local pn
local pM
local qt
local pt
local qa
local pS
local qg
local pF
local PlaytimeRewardDictionary
local pm
local p3
local qs
local qy
local py
local Library
local pX
local pE
local JuicerUpgradeDictionary
local Toggles
local pK
local qr
local pr
local px
local qe
local Options
local pk
local p1
local pJ
local PetEggDictionary
local pq
local p7
local pP
local pw
local qd
local pV
local pC
local qj
local p0
local LocalPlayer
local pp
local pO
local qv
local pv
local Plots
local function fn11(bW)
    local CollectSaplingPrompt = bW:FindFirstChild("CollectSaplingPrompt", true)
    local r7 = CollectSaplingPrompt and CollectSaplingPrompt:IsA("ProximityPrompt")
    if r7 then
        return CollectSaplingPrompt
    end
    return nil
end
local function fn45(ci, cj)
    if Toggles.StealUseFilters and Toggles.StealUseFilters.Value ~= true then
        return true
    elseif not pi(ci) then
        return true
    else
        return ci.Value[cj] == true
    end
end
local function fn53(aB)
    pk[#pk + 1] = aB
    return aB
end
local function fn67()
    local Character = LocalPlayer.Character
    local rA = Character and Character:FindFirstChild("HumanoidRootPart")
    return rA
end
local function fn73(aV)
    local DiscordGroup = aV:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = py })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = py })
end
local function fn109()
    pZ(pr, pr + Vector3.new(0, 0, -1))
    task.wait(0.35)
    return true
end
local function onOnClientEvent(ga)
    if type(ga) == "table" then
        qn.quest = ga
    end
end
local function onOnClientEvent3(ge, gf, gg)
    local vJ = tonumber(ge) or 1
    qn.dailyDay = math.clamp(math.floor(vJ), 1, 7)
    qn.dailyCanClaim = gg == true
end
local function fn226()
    if pq("CarriedSaplingTemplate") then
        pn()
        qv(2.5)
        if Toggles.AutoPlaceTrees.Value then
            pA()
        end
        return
    end
    local uA = Toggles.AutoClaimTree.Value and pM()
    if uA then
        return
    end
    if Toggles.AutoStealTree.Value then
        local uA_1 = qy()
        if uA_1 then
            qn.lastPickupAt = os.clock()
            if qr(uA_1) then
                pn()
                qv(2.5)
                if Toggles.AutoPlaceTrees.Value then
                    pA()
                end
            end
            return
        end
    end
    if Toggles.AutoPlaceTrees.Value then
        pA()
    end
end
local function onOnClientEvent4(gi, gj)
    local vL = type(gi) == "table" and gi
    local vM = {}
    local vN = vL
    local vR = if vN then 1 else 0
    local vP = 1586 * vR + 1006 * (1 - vR)
    local vQ = 793 * vR + 1141 * (1 - vR)
    if not ((vP * 2885 + vQ * 2988 + vP * vQ) % 16777213 == 8202792) then
        vN = vM
    end
    qn.trailsOwned = vN
    local vL_1 = type(gj) == "string" and gj
    local vM_1 = vL_1
    local vU = if vM_1 then 1 else 0
    local vS = 766 * vU + 2173 * (1 - vU)
    local vT = 3452 * vU + 3967 * (1 - vU)
    if not ((vS * 3013 + vT * 495 + vS * vT) % 16777213 == 6660930) then
        vM_1 = ""
    end
    qn.trailEquipped = vM_1
end
local function fn261()
    local rM = pq("AssignedTycoon")
    if not rM then
        return nil
    end
    return Plots:FindFirstChild(rM)
end
local function fn279(bL)
    local rY = bL + Vector3.new(5, 3, 0)
    if not pZ(rY, bL) then
        return false
    end
    task.wait(0.4)
    local rZ = qg()
    if not rZ then
        return false
    end
    if (rZ.Position - bL).Magnitude > 12 then
        pZ(rY, bL)
        task.wait(0.25)
        rZ = qg()
    end
    return rZ ~= nil and (rZ.Position - bL).Magnitude <= 12
end
local function fn284(cb)
    local sn = cb and cb.Value
    if type(sn) ~= "table" then
        return false
    end
    for k, v in sn do
        if v == true then
            return true
        end
    end
    return false
end
local function fn307(bl)
    local attr = LocalPlayer:GetAttribute(bl)
    local rJ = attr ~= ""
    local rK = type(attr) == "string" and rJ
    if rK then
        return attr
    end
    return nil
end
local function fn377()
    local sy = qt()
    local sz = {}
    if not sy then
        return sz
    end
    local PlantedTreeRuntime = sy:FindFirstChild("PlantedTreeRuntime", true)
    if not PlantedTreeRuntime then
        return sz
    end
    for i, descendant in PlantedTreeRuntime:GetDescendants() do
        local attr = descendant:GetAttribute("PlantZone")
        local sA_1 = attr ~= ""
        local sB = type(attr) == "string" and sA_1
        if sB then
            sz[attr] = true
        end
    end
    return sz
end
local function fn394()
    if not Toggles.AutoClaimRewards.Value then
        return
    end
    if os.clock() - qn.lastRewardAt < 1.2 then
        return
    end
    qn.lastRewardAt = os.clock()
    pK:Fire("GetState")
    pF:Fire("GetState")
    local playtime = qn.playtime
    if type(playtime) == "table" then
        local u5 = tonumber(playtime.AccumulatedSeconds) or 0
        local max = math.max
        local u7 = Workspace:GetServerTimeNow()
        local u8 = (tonumber(playtime.SnapshotAt))
        local vd = if u8 then 1 else 0
        local vb = 2019 * vd + 3556 * (1 - vd)
        local vc = 3092 * vd + 2443 * (1 - vd)
        if not ((vb * 3757 + vc * 2179 + vb * vc) % 16777213 == 3788386) then
            u8 = 0
        end
        local u6_1 = u5 + max(0, u7 - u8)
        local Claimed = playtime.Claimed
        for k, v in po do
            local u4_1 = PlaytimeRewardDictionary.Get(v)
            local u7_1 = type(Claimed) == "table" and Claimed[v] == true
            local u8_1 = u4_1
            if u8_1 then
                u8_1 = not u7_1
            end
            if u8_1 then
                u8_1 = u6_1 >= (u4_1.RequiredSeconds or math.huge)
            end
            if u8_1 then
                pK:Fire("Claim", v)
            end
        end
    end
    local u4_2 = LocalPlayer:GetAttribute("CanClaimDaily") == true or qn.dailyCanClaim
    if u4_2 then
        local u4_3 = math.clamp(math.floor(pH("DailyRewardDay", qn.dailyDay)), 1, 7)
        pF:Fire("Claim", u4_3)
    end
end
local function fn411(ei, ej)
    local attr = ei:GetAttribute("LocalSaplingId")
    if type(attr) ~= "string" then
        return false
    end
    local uj = tonumber(string.match(attr, "^(%d+)")) or Workspace:GetAttribute("SaplingPopulationGeneration")
    local uj_1 = tonumber(string.match(attr, ":(%d+)$")) or 1
    p5:Fire({
        Id = attr,
        Generation = uj,
        AreaNumber = ei:GetAttribute("AreaNumber"),
        Index = uj_1,
        Position = ej.Position
    })
    return true
end
local function fn485(bS)
    local Handle = bS:FindFirstChild("Handle", true)
    local r4 = Handle and Handle:IsA("BasePart")
    if r4 then
        return Handle
    elseif bS:IsA("BasePart") then
        return bS
    else
        return bS:FindFirstChildWhichIsA("BasePart", true)
    end
end
local function fn493(eL)
    local ux = os.clock() + eL
    while true do
        local uy = os.clock() < ux and not Library.Unloaded
        if uy then
            if not pq("CarriedSaplingTemplate") then
                return true
            end
            task.wait(0.08)
            continue
        end
        break
    end
    return not pq("CarriedSaplingTemplate")
end
local function fn610()
    if os.clock() - qn.lastPlantAt < 0.35 then
        return false
    end
    local to = not p7() and not pq("CarriedSaplingTemplate")
    if to then
        return false
    end
    local to_1 = pu()
    local tp = to_1[1]
    if not tp then
        return false
    elseif not pm(tp.Part.Position) then
        return false
    else
        qn.lastPlantAt = os.clock()
        p1:Fire(tp.Name, tp.Part.Position, tp.Part)
        return true
    end
end
local function fn731()
    local tE_1
    local tD_1
    if os.clock() - qn.lastClaimTreeAt < 0.35 then
        return false
    elseif pq("CarriedSaplingTemplate") then
        return false
    else
        tE_1, tD_1 = qs()
        if not (tE_1 and tD_1) then
            return false
        end
        local tJ = if not pm(tD_1.Position) then 1 else 0
        if tJ == 1 then
            return false
        end
        qn.lastClaimTreeAt = os.clock()
        local tM = 1
        while tM <= 8 do
            if Library.Unloaded or not Toggles.AutoClaimTree.Value then
                return false
            end
            if not tE_1.Parent then
                return true
            end
            pJ(tE_1)
            local tD_3 = os.clock() + 0.28
            while os.clock() < tD_3 do
                if not tE_1.Parent then
                    return true
                end
                task.wait(0.05)
            end
            tM += 1
        end
        return not tE_1.Parent
    end
end
local function onOnClientEvent2(gc)
    if type(gc) == "table" then
        qn.playtime = gc
    end
end
local function autoStealTreeLoop()
    while not Library.Unloaded do
        if Toggles.AutoStealTree.Value or Toggles.AutoPlaceTrees.Value or Toggles.AutoClaimTree.Value then
            pcall(qa)
        end
        task.wait(0.12)
    end
end
local function worker()
    while not Library.Unloaded do
        pcall(pw)
        pcall(qo)
        pcall(pX)
        pcall(pp)
        pcall(pt)
        pcall(p3)
        task.wait(0.35)
    end
end
local function fn828()
    local tu = qt()
    if not tu then
        return nil
    end
    local PlantedTreeRuntime = tu:FindFirstChild("PlantedTreeRuntime", true)
    local tu_1 = PlantedTreeRuntime and PlantedTreeRuntime:FindFirstChild("_ClaimableTrees")
    if not tu_1 then
        return nil
    end
    for i, descendant in tu_1:GetDescendants() do
        local tu_2 = descendant:IsA("ProximityPrompt") and descendant.Name == "ClaimTreePrompt" and descendant.Enabled
        if tu_2 then
            local Parent = descendant.Parent
            local tv_2 = Parent and Parent:IsA("BasePart")
            if tv_2 then
                return descendant, Parent
            end
        end
    end
    return nil
end
local function fn855()
    local rO = qt()
    local rP = rO and rO:FindFirstChild("GrowLocation", true)
    return rP or nil
end
local function fn863(aO, aP)
    if setclipboard then
        setclipboard(aO)
    elseif toclipboard then
        toclipboard(aO)
    end
    Library:Notify(aP)
end
local function fn873()
    local Character = LocalPlayer.Character
    local rD = Character and Character:FindFirstChildOfClass("Humanoid")
    return rD
end
local function fn926()
    if not Toggles.AutoPetShop.Value then
        return
    end
    local vq = if os.clock() - qn.lastEggAt < 1.5 then 1 else 0
    if vq == 1 then
        return
    end
    local vl = qe[Options.PetEgg.Value]
    local vk_1 = vl and PetEggDictionary.Get(vl)
    if not vk_1 then
        return
    end
    local vk_2 = tonumber(vk_1.TicketPrice) or 0
    if pH("Tickets", 0) < vk_2 then
        return
    end
    qn.lastEggAt = os.clock()
    pE:Fire("Buy", vl)
end
local function fn1003()
    if not Toggles.AutoBuyTrails.Value then
        return
    end
    if os.clock() - qn.lastTrailAt < 1.4 then
        return
    end
    qn.lastTrailAt = os.clock()
    pC:Fire("GetState")
    local vr = pH("Coins", 0)
    local vs = -1
    local vt
    for k, v in TrailDictionary.Order do
        local vu_1 = TrailDictionary.Get(v)
        local vv = vu_1
        if vv then
            local BuyTrails = Options.BuyTrails
            local vx_1 = vu_1.DisplayName or v
            vv = qd(BuyTrails, vx_1)
        end
        if vv then
            local vv_1 = qn.trailsOwned[v] == true
            local vw_2 = not vv_1
            if vw_2 ~= false then
                local vx_2 = tonumber(vu_1.CashPrice) or math.huge
                vw_2 = vr >= vx_2
            end
            if vw_2 then
                pC:Fire("BuyCash", v)
                return
            end
            if vv_1 then
                local vv_2 = tonumber(vu_1.SpeedMultiplier) or 0
                if vv_2 > vs then
                    vs = vv_2
                    vt = v
                end
            end
        end
    end
    if vt and qn.trailEquipped ~= vt then
        pC:Fire("Equip", vt)
    end
end
local function fn1037(bc, bd)
    local attr = LocalPlayer:GetAttribute(bc)
    if type(attr) == "number" then
        return attr
    end
    local PlrValues = LocalPlayer:FindFirstChild("PlrValues")
    local rG = PlrValues and PlrValues:FindFirstChild(bc)
    local rF_2 = rG
    if rG then
        rG = type(rF_2.Value) == "number"
    end
    if rG then
        return rF_2.Value
    end
    return bd or 0
end
local function fn1042(er)
    local un = qj(er)
    if not un then
        return false
    end
    local uo = p0(er)
    local up = uo and uo.Parent
    local uq = up
    if up then
        up = uq:IsA("BasePart")
    end
    if up then
        up = uq.Position
    end
    local uq_1 = up or un.Position
    if not pm(uq_1) then
        return false
    end
    local uu = 1
    while uu <= 10 do
        if Library.Unloaded or not Toggles.AutoStealTree.Value then
            return false
        end
        if pq("CarriedSaplingTemplate") then
            return true
        end
        if not er.Parent then
            return pq("CarriedSaplingTemplate") ~= nil
        end
        if er:GetAttribute("LocalOnlySapling") == true then
            px(er, un)
        end
        pJ(uo)
        local up_3 = os.clock() + 0.28
        while os.clock() < up_3 do
            if pq("CarriedSaplingTemplate") then
                return true
            end
            task.wait(0.05)
        end
        uu += 1
    end
    return pq("CarriedSaplingTemplate") ~= nil
end
local function fn1048()
    if not Toggles.AutoUpgradeJuice.Value then
        return
    end
    if os.clock() - qn.lastJuiceAt < 0.8 then
        return
    end
    local uF = pH("JuicerIncomeUpgradeLevel", 0)
    if uF >= (JuicerUpgradeDictionary.MaxLevel or 20) then
        return
    end
    local uG_1 = JuicerUpgradeDictionary.GetCost(uF)
    if pH("Coins", 0) < uG_1 then
        return
    end
    qn.lastJuiceAt = os.clock()
    pV:Fire("BuyIncome")
end
local function fn1065()
    local Character = LocalPlayer.Character
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    local function s3(c_)
        local sY = not c_ or not c_:IsA("Tool")
        if sY then
            return false
        end
        local attr = c_:GetAttribute("ItemCategory")
        return attr == "Sapling" or attr == "UprootedTree"
    end
    if Character then
        for i, child in Character:GetChildren() do
            if s3(child) then
                return child
            end
        end
    end
    if Backpack then
        for i, child in Backpack:GetChildren() do
            if s3(child) then
                return child
            end
        end
    end
    return nil
end
local function fn1085()
    if not Toggles.AutoRebirth.Value then
        return
    end
    if os.clock() - qn.lastRebirthAt < 3 then
        return
    end
    local uM = pH("RebirthRequirement", RebirthDictionary.GetRequirement(pH("Rebirths", 0)))
    if pH("Coins", 0) < uM then
        return
    end
    qn.lastRebirthAt = os.clock()
    pS:Fire()
end
local function fn1086()
    if not Toggles.AutoClaimQuests.Value then
        return
    end
    if os.clock() - qn.lastQuestAt < 1.2 then
        return
    end
    qn.lastQuestAt = os.clock()
    pO:Fire("GetState")
    local quest = qn.quest
    if type(quest) ~= "table" then
        return
    end
    local Completed = quest.Completed
    local Claimed = quest.Claimed
    if type(Completed) ~= "table" then
        return
    end
    for k, v in pv do
        local uO_1 = Completed[v] == true
        if uO_1 then
            local uR = type(Claimed) ~= "table"
            local u3 = if uR then 1 else 0
            local u1 = 3460 * u3 + 3411 * (1 - u3)
            local u2 = 1664 * u3 + 1037 * (1 - u3)
            if not ((u1 * 1301 + u2 * 3166 + u1 * u2) % 16777213 == 15527124) then
                uR = Claimed[v] ~= true
            end
            uO_1 = uR
        end
        if uO_1 then
            pO:Fire("Claim", v)
        end
    end
end
local function fn1090()
    local sJ = qh()
    local sK = {}
    if not sJ then
        return sK
    end
    local sL = pP()
    for i, child in sJ:GetChildren() do
        local sJ_1 = string.match(child.Name, "^PlantZone") and not sL[child.Name]
        if sJ_1 then
            local sJ_2 = child
            if child:IsA("Model") then
                local sM_1 = child:FindFirstChild(child.Name) or child:FindFirstChildWhichIsA("BasePart", true)
                sJ_2 = sM_1
            end
            local sM_2 = sJ_2 and sJ_2:IsA("BasePart")
            if sM_2 then
                sK[#sK + 1] = { Name = child.Name, Part = sJ_2, Root = child }
            end
        end
    end
    return sK
end
local function fn1134()
    pG(pT, "Copied Discord invite to clipboard")
end
RebirthDictionary = nil
pi = nil
pk = nil
JuicerUpgradeDictionary = nil
pm = nil
pn = nil
po = nil
pp = nil
pq = nil
pr = nil
pt = nil
pu = nil
pv = nil
pw = nil
px = nil
py = nil
pA = nil
local pB
pC = nil
pE = nil
pF = nil
pG = nil
pH = nil
LocalPlayer = nil
pJ = nil
pK = nil
pM = nil
Workspace = nil
pO = nil
pP = nil
pS = nil
pT = nil
pV = nil
Options = nil
pX = nil
pZ = nil
p0 = nil
p1 = nil
Toggles = nil
local pg, pj, ps, pz, pD, pL, pQ, pR, pU, pY, p_
p3 = nil
p5 = nil
p7 = nil
qa = nil
Plots = nil
qd = nil
qe = nil
Library = nil
qg = nil
qh = nil
qj = nil
PlaytimeRewardDictionary = nil
qn = nil
qo = nil
PetEggDictionary = nil
qr = nil
qs = nil
qt = nil
TrailDictionary = nil
qv = nil
qy = nil
local p4, SaveManager, HttpService, ThemeManager, VirtualUser, UserInputService, SkriptF, RunService, Players, qw, qx, qB, qD, qF, qK, qL, qM, qN, qO
local qC_4, qC_5
p4 = nil
SaveManager = nil
HttpService = nil
ThemeManager = nil
VirtualUser = nil
UserInputService = nil
SkriptF = nil
RunService = nil
Players = nil
qw = nil
qx = nil
local zK_4 = 132958491990446
pg = "Steal a Tree"
if game.PlaceId ~= zK_4 then
    error("Tempo: this script is only for Steal a Tree")
end
Players, qB, RunService, UserInputService, VirtualUser, HttpService, p4, p_, pU, pR, Workspace, LocalPlayer = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if (not qB and not UserInputService and (qB and UserInputService) or (UserInputService and qB or not qB and not UserInputService)) and ((not UserInputService or UserInputService) and (UserInputService or not qB) or (not UserInputService and qB or UserInputService and qB)) or (not UserInputService or UserInputService) and (qB and UserInputService) and (not qB and qB or (not UserInputService or UserInputService)) and (not UserInputService and not UserInputService and (not UserInputService and qB) or UserInputService and qB and (not UserInputService or qB)) or not ((not qB and not UserInputService and (qB and UserInputService) or (UserInputService and qB or not qB and not UserInputService)) and ((not UserInputService or UserInputService) and (UserInputService or not qB) or (not UserInputService and qB or UserInputService and qB)) or (not UserInputService or UserInputService) and (qB and UserInputService) and (not qB and qB or (not UserInputService or UserInputService)) and (not UserInputService and not UserInputService and (not UserInputService and qB) or UserInputService and qB and (not UserInputService or qB))) then
    Players = game:GetService("Players")
else
    game:GetService("Players")
end
qB = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
if (not LocalPlayer or not LocalPlayer or (p_ or false)) and (LocalPlayer or (LocalPlayer or not p_)) and not ((not LocalPlayer or not LocalPlayer or (p_ or false)) and (LocalPlayer or (LocalPlayer or not p_))) then
    pR = game:GetService("CoreGui")
    p4 = game:GetService("GuiService")
    p_ = game:GetService("TeleportService")
    pU = game:GetService("Lighting")
else
    p4 = game:GetService("CoreGui")
    p_ = game:GetService("GuiService")
    pU = game:GetService("TeleportService")
    pR = game:GetService("Lighting")
end
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local zK_9 = getgenv and getgenv()
pD = zK_9 or nil
if pD then
    pB, zK_9 = nil, nil
    local zK_4_2 = 5
    repeat
        if (zK_4_2 * 1 + 1) % 2 + 1 <= 1 then
            local qC_2 = (vector.create((zK_4_2 * 2 + 5) % 11 + 1, (zK_4_2 * 8 + 1) % 13 + 1, (zK_4_2 * 3 + 13) % 17 + 1))
            qD = (vector.create((zK_4_2 * 4 + 6) % 11 + 1, (zK_4_2 * 2 + 5) % 13 + 1, (zK_4_2 * 3 + 12) % 17 + 1))
            local qE_1 = (vector.create((zK_4_2 * 2 + 4) % 11 + 1, (zK_4_2 * 7 + 5) % 13 + 1, (zK_4_2 * 8 + 10) % 17 + 1))
            qF = (vector.create((zK_4_2 * 7 + 2) % 11 + 1, (zK_4_2 * 5 + 12) % 13 + 1, (zK_4_2 * 9 + 2) % 17 + 1))
            if vector.dot(vector.cross(qC_2, qD), (vector.cross(qE_1, qF))) == vector.dot(qC_2, qE_1) * vector.dot(qD, qF) - vector.dot(qC_2, qF) * vector.dot(qD, qE_1) then
                pB = pD.__TempoStealATreeLib
            else
                pD = pB.__TempoStealATreeLib
            end
            zK_4_2 = (zK_4_2 + 7) % 16
        else
            local qC_3 = {
                "tjcgaxmriev",
                "yhsjutvi",
                "lnwvk",
                "zxrxjwgo",
                "qvptestzuv",
                "alnmxiazi",
                "yysqvklsh",
                "syicq",
                "ziiqux",
                "zbrn",
                "jisxamqjgzzk",
                "kqmhnw",
                "zjikh",
                "hebdqedmxtvh",
                "zeu",
                "nvz"
            }
            if qC_3[(zK_4_2 * 1 + 37) % 16 + 1] < qC_3[(zK_4_2 * 1 + 37) % 16 + 1] then
                pB = zK_9
            else
                zK_9 = pB
            end
            zK_4_2 = (zK_4_2 + 9) % 16
        end
    until (zK_4_2 * 11 + 11) % 16 == 2
    if zK_9 then
        zK_9 = pB.Unload
    end
    if zK_9 then
        pcall(function()
            pB:Unload()
        end)
    end
end
if setthreadidentity then
    setthreadidentity(8)
end
JuicerUpgradeDictionary, RebirthDictionary, TrailDictionary, PetEggDictionary, PlaytimeRewardDictionary, SkriptF, Plots, p5, p1, pV, pS, pO, pK, pF, pE, pC, pz = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
qD = qB:WaitForChild("Modules")
zK_9 = qD:WaitForChild("Dictionaries")
local zK_4_3 = require(qD:WaitForChild("REConnection"))
local AreaDictionary = require(zK_9:WaitForChild("AreaDictionary"))
qF = require(zK_9:WaitForChild("ItemDictionary"))
JuicerUpgradeDictionary = require(zK_9:WaitForChild("JuicerUpgradeDictionary"))
RebirthDictionary = require(zK_9:WaitForChild("RebirthDictionary"))
TrailDictionary = require(zK_9:WaitForChild("TrailDictionary"))
PetEggDictionary = require(zK_9:WaitForChild("PetEggDictionary"))
local qG = require(zK_9:WaitForChild("QuestDictionary"))
PlaytimeRewardDictionary = require(zK_9:WaitForChild("PlaytimeRewardDictionary"))
SkriptF = Workspace:WaitForChild("SkriptF")
Plots = SkriptF:WaitForChild("Plots")
local Remotes = qD:WaitForChild("REConnection"):WaitForChild("Remotes")
p5 = zK_4_3.RemoteEvent("LocalSaplingPickupRequest")
p1 = zK_4_3.RemoteEvent("RequestPlantSapling")
pV = zK_4_3.RemoteEvent("JuicerUpgradeRequest")
pS = zK_4_3.RemoteEvent("RequestRebirth")
pO = zK_4_3.RemoteEvent("QuestRequest")
pK = zK_4_3.RemoteEvent("PlaytimeRewardRequest")
pF = zK_4_3.RemoteEvent("DailyRewardRequest")
pE = zK_4_3.RemoteEvent("PetEggRequest")
pC = zK_4_3.RemoteEvent("TrailShopRequest")
pz = {
    Common = 1,
    Rare = 2,
    Epic = 3,
    Legendary = 4,
    Mythic = 5,
    Secret = 6,
    Divine = 7,
    Prismatic = 8,
    Cosmic = 9,
    Supreme = 10
}
local qI = {}
local qH = {}
for k, v in AreaDictionary.AreaOrder do
    qI[#qI + 1] = v
    qH[v] = true
end
qC_4, qB, zK_9, pj = nil, nil, nil, nil
if (qC_4 or not qB) and (not pj and 0) and (not zK_9 or zK_9) or not ((qC_4 or not qB) and (not pj and 0) and (not zK_9 or zK_9)) then
    qC_5 = {}
    qB = {}
else
    qB = {}
    qC_5 = {}
end
zK_9 = {}
pj = {}
local zK_4_4 = qF.GetAll()
for k, v in zK_4_4 do
    if v.Category == "Sapling" then
        qD = v.DisplayName or k
        qC_5[#qC_5 + 1] = qD
        qB[qD] = true
        zK_9[qD] = k
        local zK_4_6 = v.Rarity or "Common"
        pj[k] = zK_4_6
    end
end
table.sort(qC_5)
qD, qe, zK_9 = nil, nil, nil
local zK_4_7 = 15
repeat
    if (zK_4_7 * 1 + 1) % 2 + 1 <= 1 then
        local Bf = bit32.rrotate(bit32.bxor(bit32.lrotate(zK_4_7, 12), string.byte(tostring(qD))), 8)
        if bit32.bxor(bit32.lrotate(bit32.bxor(Bf, 664144503), 22), 2647254402) ~= bit32.lrotate(Bf, 22) then
            zK_9 = {}
        else
            qD = {}
        end
        zK_4_7 = (zK_4_7 + 7) % 16
    else
        if zK_4_7 * 123751689 + 1 + 7 <= zK_4_7 * 123751689 + 1 + 7 + 1 then
            qe = {}
            zK_9 = nil
        else
            zK_9 = {}
            qe = nil
        end
        zK_4_7 = (zK_4_7 + 5) % 16
    end
until (zK_4_7 * 7 + 5) % 16 == 2
for k, v in PetEggDictionary.Order do
    local zK_4_8 = PetEggDictionary.Get(v)
    if zK_4_8 then
        local qE_4 = zK_4_8.DisplayName or v
        qD[#qD + 1] = qE_4
        qe[qE_4] = v
        if not zK_9 then
            zK_9 = qE_4
        end
    end
end
qL, qK, qF = nil, nil, nil
local qE_5 = 4
repeat
    local zK_4_10 = (vector.create((qE_5 * 6 + 8) % 11 + 1, (qE_5 * 11 + 6) % 13 + 1, (qE_5 * 10 + 14) % 17 + 1))
    qM = (vector.create((qE_5 * 4 + 9) % 11 + 1, (qE_5 * 6 + 10) % 13 + 1, (qE_5 * 9 + 3) % 17 + 1))
    qN = (vector.create((qE_5 * 2 + 4) % 11 + 1, (qE_5 * 9 + 1) % 13 + 1, (qE_5 * 3 + 16) % 17 + 1))
    qO = (vector.create((qE_5 * 5 + 3) % 11 + 1, (qE_5 * 3 + 12) % 13 + 1, (qE_5 * 2 + 7) % 17 + 1))
    if vector.dot(vector.cross(zK_4_10, qM), (vector.cross(qN, qO))) == vector.dot(zK_4_10, qN) * vector.dot(qM, qO) - vector.dot(zK_4_10, qO) * vector.dot(qM, qN) + 4 then
        qF = {}
        qL = {}
        qK = {}
    else
        qL = {}
        qK = {}
        qF = {}
    end
    qE_5 = (qE_5 + 0) % 8
until (qE_5 * 7 + 2) % 8 == 6
for k, v in TrailDictionary.Order do
    local zK_4_11 = TrailDictionary.Get(v)
    if zK_4_11 then
        local qE_6 = zK_4_11.DisplayName or v
        qL[#qL + 1] = qE_6
        qK[qE_6] = true
        qF[qE_6] = v
    end
end
pv = {}
for k, v in qG.Quests do
    local zK_4_13 = type(v) == "table" and type(v.Id) == "string"
    if zK_4_13 then
        pv[#pv + 1] = v.Id
    end
end
po = {}
for k in PlaytimeRewardDictionary.Rewards do
    po[#po + 1] = k
end
pk, qn, Library, qw = nil, nil, nil, nil
table.sort(po)
pk = {}
qw = fn53
if (pk or Library) and (qw or qw or (not Library or false)) and not ((pk or Library) and (qw or qw or (not Library or false))) then
    qw = {
        dailyCanClaim = false,
        lastPickupAt = 0,
        playtime = nil,
        dailyDay = 1,
        lastRebirthAt = 0,
        lastJuiceAt = 0,
        lastRewardAt = 0,
        quest = nil,
        lastEggAt = 0,
        lastPlantAt = 0,
        trailEquipped = "",
        lastTrailAt = 0,
        lastClaimTreeAt = 0,
        trailsOwned = {},
        lastQuestAt = 0
    }
else
    qn = {
        quest = nil,
        playtime = nil,
        dailyDay = 1,
        dailyCanClaim = false,
        trailsOwned = {},
        trailEquipped = "",
        lastPickupAt = 0,
        lastPlantAt = 0,
        lastClaimTreeAt = 0,
        lastJuiceAt = 0,
        lastRebirthAt = 0,
        lastQuestAt = 0,
        lastRewardAt = 0,
        lastEggAt = 0,
        lastTrailAt = 0
    }
end
Library = getgenv().Library
if pD then
    pD.__TempoStealATreeLib = Library
end
ThemeManager, SaveManager, Toggles, Options, pT, pQ, pL, qx, pG, py = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
pT = "https://discord.gg/K7Qxnxkk46"
pQ = "https://discord.gg/K7Qxnxkk46"
pL = "https://tempohub.shop"
pG = fn863
py = fn1134
qG = fn73
local zK_4_14 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = pT, Copyable = true }, "|", pg },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    SidebarCompacted = true,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
zK_4_14:SetGlow(true, { Color = Color3.fromRGB(242, 154, 196), Radius = 24, Transparency = 0.3 })
qx = {
    Info = zK_4_14:AddTab("Info", "info"),
    Main = zK_4_14:AddTab("Main", "gamepad-2"),
    Player = zK_4_14:AddTab("Player", "person-standing"),
    Settings = zK_4_14:AddTab("Settings", "settings")
}
qN = qx.Main:AddSubTab("Farm", "sprout")
qM = qx.Main:AddSubTab("Shop", "store")
for k, v in qx do
    if k ~= "Info" and k ~= "Main" then
        qG(v)
    end
end
pr, qg, pY, pH, pq, qt, qh, pZ, pm, qj, p0, pJ, pi, qd, pP, pu, ps, p7, pA, qs, pM, qy, px, qr, pn, qv, qa, pw, qo, pX, pp, pt, p3, qF = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if (p0 or p0 or (not p0 or pn) or (not pn or false or qy and not p0)) and (pn and qy or qy and qy or (not pn and p0 or (not p0 or p0))) and (p0 and p0 and (false or not p0) and ((pn or qy) and (p0 or pn)) or (qy and pn and (not pn or false) or (not pn or not p0) and (not pn or false))) and not ((p0 or p0 or (not p0 or pn) or (not pn or false or qy and not p0)) and (pn and qy or qy and qy or (not pn and p0 or (not p0 or p0))) and (p0 and p0 and (false or not p0) and ((pn or qy) and (p0 or pn)) or (qy and pn and (not pn or false) or (not pn or not p0) and (not pn or false)))) then
    qM(pq)
    qM(qN)
    pH = fn67
    qg = fn1037
    pY = fn307
else
    qG(qN)
    qG(qM)
    qg = fn67
    pY = fn873
    pH = fn1037
    pq = fn307
end
qt = fn261
qh = fn855
pZ = function(bx, by)
    local Character
    local rS
    Character = nil
    rS = nil
    Character = LocalPlayer.Character
    local rT = Character and Character:FindFirstChild("HumanoidRootPart")
    if not (Character and rT) then
        return false
    end
    local rT_2 = by and bx
    local rV = rT_2 or bx + Vector3.new(0, 4, 0)
    local rT_3 = by
    if rT_3 then
        rT_3 = CFrame.new(rV, by)
    end
    local rV_1 = rT_3 or CFrame.new(rV)
    rS = rV_1
    pcall(function()
        Character:PivotTo(rS)
    end)
    rT.CFrame = rS
    rT.AssemblyLinearVelocity = Vector3.zero
    rT.AssemblyAngularVelocity = Vector3.zero
    return true
end
pm = fn279
qj = fn485
p0 = fn11
pJ = function(b_)
    local sb_1
    local sa_1
    local r9 = not b_
    local sg = if r9 then 1 else 0
    local se = 3247 * sg + 3457 * (1 - sg)
    local sf = 1778 * sg + 2155 * (1 - sg)
    if not ((se * 3612 + sf * 3919 + se * sf) % 16777213 == 7692099) then
        r9 = not b_.Parent
    end
    if r9 then
        return false
    end
    b_.Enabled = true
    b_.HoldDuration = 0
    b_.MaxActivationDistance = 80
    b_.RequiresLineOfSight = false
    if setproximitypromptduration then
        pcall(setproximitypromptduration, b_, 0)
    end
    local r9_1 = false
    if getconnections then
        sa_1, sb_1 = pcall(getconnections, b_.Triggered)
        local sc = sa_1 and type(sb_1) == "table"
        if sc then
            for k, v in sb_1 do
                local sm = v
                if pcall(function()
                    sm:Fire(LocalPlayer)
                end) then
                    r9_1 = true
                end
            end
        end
    end
    if fireproximityprompt then
        if pcall(fireproximityprompt, b_) then
            r9_1 = true
        end
        if pcall(fireproximityprompt, b_, 0) then
            r9_1 = true
        end
    end
    return r9_1
end
pi = fn284
qd = fn45
pP = fn377
pu = fn1090
ps = fn1065
p7 = function()
    local tn = if pq("CarriedSaplingTemplate") then 1 else 0
    if tn == 1 then
        return true
    end
    local ti = ps()
    local th = pY()
    if not (ti and th) then
        return false
    elseif ti.Parent == LocalPlayer.Character then
        return true
    else
        pcall(function()
            th:EquipTool(ti)
        end)
        return true
    end
end
pA = fn610
qs = fn828
pM = fn731
qy = function()
    local tY, tZ, t_
    local t0 = qg()
    local t1 = t0 and t0.Position
    tZ = nil
    t_ = t1
    tY = -math.huge
    local function t0_1(dX)
        local tP = not dX or dX.Name == "_CarriedSaplingVisual" or string.sub(dX.Name, 1, 1) == "_"
        if tP then
            return
        end
        if dX:GetAttribute("LocalClaimPending") == true then
            return
        end
        local attr3 = dX:GetAttribute("SourceArea")
        local attr2 = dX:GetAttribute("SaplingDisplayName")
        local tR = type(attr3) == "string" and not qd(Options.StealZones, attr3)
        if tR then
            return
        end
        local tP_2 = type(attr2) == "string" and not qd(Options.StealTrees, attr2)
        if tP_2 then
            return
        end
        local tP_3 = qj(dX)
        if not tP_3 then
            return
        end
        local attr = dX:GetAttribute("SaplingItemId")
        local tR_1 = tonumber(dX:GetAttribute("AreaNumber")) or 0
        local tR_3 = pz[pj[attr] or "Common"] or 0
        local tQ_3 = t_
        if tQ_3 then
            tQ_3 = (tP_3.Position - t_).Magnitude
        end
        local tP_4 = tQ_3 or 0
        local tP_5 = string.find(dX.Name, "Dropped_", 1, true) and 5000
        local tR_5 = (tP_5 or 0) + tR_3 * 100 + tR_1 - tP_4 * 0.01
        if tR_5 > tY then
            tY = tR_5
            tZ = dX
        end
    end
    local LocalAreaSaplings = SkriptF:FindFirstChild("_LocalAreaSaplings")
    if LocalAreaSaplings then
        for i, child in LocalAreaSaplings:GetChildren() do
            t0_1(child)
        end
    end
    local SpawnedSaplings = SkriptF:FindFirstChild("SpawnedSaplings")
    if SpawnedSaplings then
        for i, child in SpawnedSaplings:GetChildren() do
            t0_1(child)
        end
    end
    return tZ
end
px = fn411
qr = fn1042
pr = Vector3.new(-297, 18, -44)
pn = fn109
qv = fn493
qa = fn226
pw = fn1048
qo = fn1085
pX = fn1086
pp = fn394
pt = fn926
if not qF and qF and (pn or qh) or (pn and not ps or (not ps or not qh)) or (pi or not qF or p0 and not p0) and (not pn or ps or pn and not pn) or not (not qF and qF and (pn or qh) or (pn and not ps or (not ps or not qh)) or (pi or not qF or p0 and not p0) and (not pn or ps or pn and not pn)) then
    p3 = fn1003
else
    pn = fn1003
end
qw(Remotes:WaitForChild("QuestState").OnClientEvent:Connect(onOnClientEvent))
qw(Remotes:WaitForChild("PlaytimeRewardState").OnClientEvent:Connect(onOnClientEvent2))
qw(Remotes:WaitForChild("DailyRewardState").OnClientEvent:Connect(onOnClientEvent3))
qw(Remotes:WaitForChild("TrailShopState").OnClientEvent:Connect(onOnClientEvent4))
qF = function()
    local wI
    local wT
    local wY
    local wU
    local wL
    local wQ
    wI = nil
    wL = nil
    wQ = nil
    wT = nil
    wU = nil
    wY = nil
    local Label2, wJ, wK, wM, wN, Label3, wP, wR, Label, wV, wW, wX, wZ
    wY = function(gn, go)
        return string.format('<font color="%s">%s</font>', go, gn)
    end
    wZ = function(gq, gr, gs)
        return string.format("<b>%s</b> %s %s", gq, wY("-", "#5a6070"), wY(gr, gs))
    end
    local w_ = "#8b93a3"
    wI = "#e05a5a"
    wT = "#e8a34d"
    local w0 = "#6ec1ff"
    wL = "#7fd47f"
    local function w1()
        local vV = hookfunction ~= nil
        local vW = hookmetamethod ~= nil
        local vX = getrawmetatable ~= nil
        local vY = setrawmetatable ~= nil
        local vZ = getgc ~= nil
        local v_ = getgenv ~= nil
        local v0 = getreg ~= nil
        local v1 = getconnections ~= nil
        local v2 = firesignal ~= nil
        local v3 = getcallbackvalue ~= nil
        local v4 = setclipboard ~= nil
        local v5 = getcustomasset ~= nil
        local v6 = getnamecallmethod ~= nil
        local v7 = isexecutorclosure ~= nil
        local v8 = fireproximityprompt ~= nil
        local v9 = firetouchinterest ~= nil
        local wa = WebSocket ~= nil
        local wb = readfile ~= nil
        local wc = writefile ~= nil
        local we = (request or http_request) ~= nil
        local wg = (debug and debug.getupvalues) ~= nil
        local wi = (debug and debug.setupvalue) ~= nil
        local wj = 0
        local wk = { vV, vW, vX, vY, vZ, v_, v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, wa, wb, wc, we, wg, wi }
        for i, v in ipairs(wk) do
            if v then
                wj += 1
            end
        end
        local vV_1 = wj / #wk
        if vV_1 >= 0.9 then
            return wY("Full Support", wL)
        elseif vV_1 >= 0.6 then
            return wY("Half Support", wT)
        else
            return wY("Low Support", wI)
        end
    end
    wQ = "Unknown"
    pcall(function()
        local wt_1
        local ws_1
        if identifyexecutor then
            wt_1, ws_1 = identifyexecutor()
            local wu = wt_1 ~= ""
            local wv = type(wt_1) == "string" and wu
            if wv then
                local wu_1 = type(ws_1) == "string" and ws_1 ~= "" and wt_1 .. " " .. ws_1
                wQ = wu_1 or wt_1
            end
        end
    end)
    local w2 = w1()
    wU = os.clock()
    wM = function()
        local wx = math.floor(os.clock() - wU)
        if wx < 60 then
            return wx .. "s"
        elseif wx < 3600 then
            return string.format("%dm %ds", math.floor((wx) / (60)), wx % 60)
        else
            return string.format("%dh %dm", math.floor((wx) / (3600)), math.floor((wx % 3600) / (60)))
        end
    end
    local UserGroup = qx.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(wZ("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, wL), true)
    UserGroup:AddLabel(wZ("UserId", tostring(LocalPlayer.UserId), "#6ec1ff"), true)
    UserGroup:AddLabel(wZ("Executor", wQ .. "  " .. w2, wL), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(wZ("Session", wM(), wT), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            pG(LocalPlayer.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            pG("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = qx.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(wZ("Game", pg, "#6ec1ff"), true)
    Label2 = SessionGroup:AddLabel(wZ("Players", "0/0", wL), true)
    wR = tostring(game.JobId)
    local w2_1 = #wR > 18 and string.sub(wR, 1, 18) .. "..."
    local w2_2 = w2_1 or wR
    SessionGroup:AddLabel(wZ("Job", w2_2, w_), true)
    Label = SessionGroup:AddLabel(wZ("Ping", "0 ms", wT), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            pU:Teleport(game.PlaceId, LocalPlayer)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            pG(wR, "Copied Job ID")
        end
    })
    task.spawn(function()
        local wA_1
        local wz_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(wZ("Session", wM(), wT))
            Label2:SetText(wZ("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), wL))
            wz_1, wA_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local wz_2 = wz_1 and wA_1 .. " ms" or "n/a"
            Label:SetText(wZ("Ping", wz_2, wT))
        end
    end)
    local SocialsGroup = qx.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = py })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            if setclipboard then
                setclipboard(pQ)
            elseif toclipboard then
                toclipboard(pQ)
            end
            Library:Notify("Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            pG(pL, "Copied website link")
        end
    })
    wV = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
    wJ = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
    wK = ""
    wX = ""
    wN = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
    wW = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
    wP = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
    local DonationsGroup = qx.Info:AddRightGroupbox("Donations", "heart")
    DonationsGroup:AddLabel(wY("All donations are optional but appreciated.", wT), true)
    DonationsGroup:AddLabel(wY("If you donate you get a special role, just PING after you donate.", wL), true)
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(wY("LTC / Litecoin", "#345d9d"), true)
    DonationsGroup:AddButton({
        Text = "Copy Litecoin Address",
        Func = function()
            pG(wV, "Copied Litecoin address")
        end
    })
    DonationsGroup:AddLabel(wY("BTC / Bitcoin", "#f7931a"), true)
    DonationsGroup:AddButton({
        Text = "Copy Bitcoin Address",
        Func = function()
            pG(wN, "Copied Bitcoin address")
        end
    })
    DonationsGroup:AddLabel(wY("ETH / Ethereum", "#627eea"), true)
    DonationsGroup:AddButton({
        Text = "Copy Ethereum Address",
        Func = function()
            pG(wJ, "Copied Ethereum address")
        end
    })
    DonationsGroup:AddLabel(wY("USDT", "#26a17b"), true)
    DonationsGroup:AddButton({
        Text = "Copy USDT Address",
        Func = function()
            pG(wW, "Copied USDT address")
        end
    })
    DonationsGroup:AddLabel(wY("Solana", "#14f195"), true)
    DonationsGroup:AddButton({
        Text = "Copy Solana Address",
        Func = function()
            pG(wP, "Copied Solana address")
        end
    })
    DonationsGroup:AddLabel(wY("PayPal", "#0070ba"), true)
    DonationsGroup:AddButton({
        Text = "Copy PayPal Link",
        Func = function()
            pG(wK, "Copied PayPal link")
        end
    })
    DonationsGroup:AddLabel(wY("Venmo", "#008cff"), true)
    DonationsGroup:AddButton({
        Text = "Copy Venmo Link",
        Func = function()
            pG(wX, "Copied Venmo link")
        end
    })
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(wY("Don't have any of the listed currencies but still wanna donate?", w_), true)
    DonationsGroup:AddLabel(wY("DM me and we'll work something out.", w0), true)
    local w__1 = qx.Info:AddRightGroupbox("FAQ", "circle-help")
    w__1:AddLabel("Where do I get a good config?", true)
    w__1:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
    w__1:AddLabel("How do I import / export configs?", true)
    w__1:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
    w__1:AddLabel("How do I report bugs?", true)
    w__1:AddLabel("Join the Discord and post it in the bugs channel.", true)
    w__1:AddLabel("How do I make suggestions?", true)
    w__1:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
    w__1:AddLabel("How do I get help or updates?", true)
    w__1:AddLabel("Join the Discord, updates and support are posted there first.", true)
end
qF()
local zK_4_16 = qN:AddLeftGroupbox("Steal", "trees")
zK_4_16:AddToggle("AutoStealTree", { Text = "Auto Steal Tree", Default = false })
zK_4_16:AddToggle("StealUseFilters", { Text = "Use Filters", Default = false })
zK_4_16:AddDropdown("StealZones", {
    Text = "Zones",
    Values = qI,
    Default = qH,
    Multi = true,
    Searchable = true,
    Expandable = true,
    SelectAllButtons = true
})
zK_4_16:AddDropdown("StealTrees", {
    Text = "Trees",
    Values = qC_5,
    Default = qB,
    Multi = true,
    Searchable = true,
    Expandable = true,
    SelectAllButtons = true
})
local ClaimsGroup = qN:AddLeftGroupbox("Claims", "gift")
ClaimsGroup:AddToggle("AutoClaimQuests", { Text = "Auto Claim Quests", Default = false })
ClaimsGroup:AddToggle("AutoClaimRewards", { Text = "Auto Claim Rewards", Default = false })
local FarmGroup = qN:AddRightGroupbox("Farm", "sprout")
FarmGroup:AddToggle("AutoPlaceTrees", { Text = "Auto Place Trees", Default = false })
FarmGroup:AddToggle("AutoClaimTree", { Text = "Auto Claim Tree", Default = false })
FarmGroup:AddToggle("AutoUpgradeJuice", { Text = "Auto Upgrade Juice Income", Default = false })
FarmGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
local PetsGroup = qM:AddLeftGroupbox("Pets", "paw-print")
PetsGroup:AddToggle("AutoPetShop", { Text = "Auto Pet Shop", Default = false })
PetsGroup:AddDropdown("PetEgg", { Text = "Egg", Values = qD, Default = zK_9, Searchable = true })
local TrailsGroup = qM:AddRightGroupbox("Trails", "wind")
TrailsGroup:AddToggle("AutoBuyTrails", { Text = "Auto Buy Trails", Default = false })
TrailsGroup:AddDropdown("BuyTrails", {
    Text = "Trails",
    Values = qL,
    Default = qK,
    Multi = true,
    Searchable = true,
    Expandable = true,
    SelectAllButtons = true
})
local function qR()
    local MovementGroup = qx.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = qx.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local function ig(ih)
        local xd = if not ih:IsA("ProximityPrompt") then 1 else 0
        if xd == 1 then
            return
        end
        ih.HoldDuration = 0
        ih.MaxActivationDistance = 50
        ih.RequiresLineOfSight = false
    end
    local connection
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in Workspace:GetDescendants() do
                pcall(ig, descendant)
            end
            connection = Workspace.DescendantAdded:Connect(function(is)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(ig, is)
                end
            end)
            qw(connection)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    qw(RunService.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = LocalPlayer.Character
            if Character then
                for i, descendant in Character:GetDescendants() do
                    local xp_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if xp_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end))
    qw(UserInputService.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local xA_1 = pY()
            if xA_1 then
                xA_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end))
    local CurrentCamera = Workspace.CurrentCamera
    qw(RunService.RenderStepped:Connect(function(iQ)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local xF_1 = pY()
            if xF_1 then
                xF_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local xF_3 = qg()
            local xG = pY()
            if xF_3 and xG then
                xG.PlatformStand = true
                local xG_1 = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    xG_1 += CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    xG_1 -= CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    xG_1 -= CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    xG_1 += CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    xG_1 += Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    xG_1 -= Vector3.new(0, 1, 0)
                end
                xF_3.AssemblyLinearVelocity = Vector3.zero
                if xG_1.Magnitude > 0 then
                    xF_3.CFrame = xF_3.CFrame + xG_1.Unit * Options.FlySpeed.Value * iQ
                end
            end
        end
    end))
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local xJ = pY()
            if xJ then
                xJ.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local xO = pY()
            if xO then
                xO.WalkSpeed = 16
            end
        end
    end)
end
qR()
qO = function()
    local MenuGroup = qx.Settings:AddLeftGroupbox("Menu", "logs")
    local je = 0
    local jf = tick()
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = MenuGroup:AddLabel("AFK triggers: 0")
    local function jh()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then
            return
        end
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        je += 1
        jf = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. je)
        end)
    end
    qw(LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(jh)
        end
    end))
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local xW = Toggles.AntiAfk.Value and tick() - jf >= 60
            if xW then
                pcall(jh)
            end
        end
    end)
    MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
    MenuGroup:AddToggle("Disable3D", { Text = "Disable 3D Rendering", Default = false })
    MenuGroup:AddToggle("FpsBoost", { Text = "FPS Boost", Default = false })
    MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
    local function jD(jE)
        pcall(function()
            p_:SetGameplayPausedNotificationEnabled(not jE)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = p4:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not jE
            end
        end)
        if not jE then
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
    Toggles.AntiGameplayPause:OnChanged(function()
        jD(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                jD(true)
            end
        end
    end)
    local jV = false
    local function jW()
        local JobId, PlaceId
        if jV then
            return
        end
        jV = true
        PlaceId, JobId = game.PlaceId, game.JobId
        local x4 = pcall(function()
            pU:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
        end)
        if not x4 then
            pcall(function()
                pU:Teleport(PlaceId, LocalPlayer)
            end)
        end
    end
    task.spawn(function()
        local RobloxPromptGui = p4:WaitForChild("RobloxPromptGui", 30)
        local yc = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
        if not yc then
            return
        end
        qw(yc.ChildAdded:Connect(function(ke)
            if Library.Unloaded then
                return
            end
            if Toggles.AutoReconnect.Value and ke.Name == "ErrorPrompt" then
                jW()
            end
        end))
    end)
    qw(pU.TeleportInitFailed:Connect(function()
        if Toggles.AutoReconnect.Value then
            jV = false
            jW()
        end
    end))
    Toggles.Disable3D:OnChanged(function()
        pcall(function()
            RunService:Set3dRenderingEnabled(not Toggles.Disable3D.Value)
        end)
    end)
    local kv = {
        ParticleEmitter = true,
        Trail = true,
        Smoke = true,
        Fire = true,
        Sparkles = true,
        Explosion = true,
        Beam = true
    }
    local function kw(kx)
        if kv[kx.ClassName] then
            pcall(function()
                kx.Enabled = false
            end)
        end
    end
    local connection
    Toggles.FpsBoost:OnChanged(function()
        if Toggles.FpsBoost.Value then
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            end)
            pcall(function()
                pR.GlobalShadows = false
            end)
            pcall(function()
                pR.FogEnd = 9000000000
            end)
            for i, descendant in Workspace:GetDescendants() do
                pcall(kw, descendant)
            end
            connection = Workspace.DescendantAdded:Connect(function(kM)
                if Toggles.FpsBoost.Value then
                    pcall(kw, kM)
                end
            end)
            qw(connection)
        else
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            end)
            pcall(function()
                pR.GlobalShadows = true
            end)
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end)
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    local ScriptGroup = qx.Settings:AddLeftGroupbox("Script", "terminal")
    ScriptGroup:AddButton({
        Text = "Unload Script",
        Func = function()
            Library:Unload()
        end
    })
end
qO()
local function qE_8()
    local zr, zs, zt, zu
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("TempoHub/StealATree")
    ThemeManager:SaveDefault("Evil Hello Kitty")
    ThemeManager:ApplyToTab(qx.Settings)
    ThemeManager:LoadDefault()
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    SaveManager:SetFolder("TempoHub/StealATree")
    local zv = SaveManager:BuildConfigSection(qx.Settings)
    zu = function(k_, k0)
        local yv_1 = (k_ == "Toggle" and Toggles or Options)[k0]
        local yu_2 = type(yv_1) == "table" and yv_1.Type == k_
        local yu_3 = yu_2 and yv_1
        local yA = if yu_3 then 1 else 0
        local yy = 3796 * yA + 410 * (1 - yA)
        local yz = 1125 * yA + 1608 * (1 - yA)
        if not ((yy * 2772 + yz * 341 + yy * yz) % 16777213 == 15176637) then
            yu_3 = nil
        end
        return yu_3
    end
    zs = function(k9, la)
        local Type = la.Type
        if Type == "Toggle" then
            return { idx = k9, type = "Toggle", value = la.Value == true }
        elseif Type == "Slider" then
            return { idx = k9, type = "Slider", value = tostring(la.Value) }
        elseif Type == "Dropdown" then
            return { idx = k9, type = "Dropdown", multi = la.Multi == true, value = la.Value }
        elseif Type == "Input" then
            local yC = la.Value or ""
            return { idx = k9, type = "Input", text = tostring(yC) }
        elseif Type == "ColorPicker" then
            return { idx = k9, type = "ColorPicker", value = la.Value:ToHex(), transparency = la.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = k9,
                type = "KeyPicker",
                mode = la.Mode,
                key = la.Value,
                modifiers = la.Modifiers,
                toggled = la.Toggled
            }
        else
            return nil
        end
    end
    zr = function()
        local yL = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local yM = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if yM then
                    local yM_1 = zs(k, v)
                    if yM_1 then
                        yL[#yL + 1] = yM_1
                    end
                end
            end
        end
        table.sort(yL, function(ll, lm)
            if ll.type ~= lm.type then
                return ll.type < lm.type
            end
            return ll.idx < lm.idx
        end)
        return { objects = yL }
    end
    zt = function(lo)
        local y4
        y4 = nil
        local y5 = type(lo) ~= "table" or type(lo.idx) ~= "string" or type(lo.type) ~= "string" or SaveManager.Ignore[lo.idx]
        if y5 then
            return false
        end
        y4 = zu(lo.type, lo.idx)
        if not y4 then
            return false
        end
        local y5_1 = pcall(function()
            if lo.type == "Input" then
                if type(lo.text) ~= "string" then
                    return
                end
                y4:SetValue(lo.text)
            elseif lo.type == "ColorPicker" then
                y4:SetValueRGB(Color3.fromHex(lo.value), lo.transparency)
            elseif lo.type == "KeyPicker" then
                y4:SetValue({ lo.key, lo.mode, lo.modifiers })
                if lo.mode == "Toggle" and lo.toggled ~= nil then
                    y4.Toggled = lo.toggled
                    y4:Update()
                end
            else
                y4:SetValue(lo.value)
            end
        end)
        return y5_1
    end
    zv:AddDivider()
    zv:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    zv:AddButton("Export Config to Clipboard", function()
        local zb_1
        local za_1
        za_1, zb_1 = pcall(HttpService.JSONEncode, HttpService, zr())
        if not za_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local za_2 = setclipboard or toclipboard
        local za_3 = type(za_2) ~= "function" or not pcall(za_2, zb_1)
        if za_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    zv:AddButton("Import Config from Clipboard Text", function()
        local zg_1
        local ze = Options.SaveManager_ImportSource.Value or ""
        local ze_1
        local zf = tostring(ze):match("^%s*(.-)%s*$")
        if zf == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        ze_1, zg_1 = pcall(HttpService.JSONDecode, HttpService, zf)
        local zf_1 = not ze_1 or type(zg_1) ~= "table" or type(zg_1.objects) ~= "table"
        if zf_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local ze_2 = 0
        for i, v in ipairs(zg_1.objects) do
            if zt(v) then
                ze_2 += 1
            end
        end
        if ze_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local zg_2 = ze_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(ze_2, zg_2), 6)
    end)
    SaveManager:LoadAutoloadConfig()
    if Toggles.HideUiOnStart.Value then
        Library:Toggle(false)
    end
end
qE_8()
Library:OnUnload(function()
    for k, v in pk do
        local zD = v
        pcall(function()
            zD:Disconnect()
        end)
    end
    table.clear(pk)
    pcall(function()
        RunService:Set3dRenderingEnabled(true)
    end)
    if pD then
        pD.__TempoStealATreeLib = nil
    end
end)
pO:Fire("GetState")
pK:Fire("GetState")
pF:Fire("GetState")
pC:Fire("GetState")
pV:Fire("GetState")
pE:Fire("GetState")
task.spawn(autoStealTreeLoop)
task.spawn(worker)
end)(...)

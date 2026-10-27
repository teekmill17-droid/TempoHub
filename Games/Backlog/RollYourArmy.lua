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
getgenv().TempoHoodSubtitle = "ROLL YOUR ARMY!"
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
local vM_1, UserInputService, vM_17
local nc
local mU
local LocalPlayer
local ni
local Enemies
local nH
local onReplaceNow
local no
local Toggles
local connection
local nu
local mT
local mZ
local nG
local mG
local nn
local m4
local nM
local mM
local nt
local na
local mS
local nz
local ng
local mY
local nF
local mF
local nm
local m3
local nL
local mL
local m9
local ny
local Troops2
local mX
local VirtualUser
local Label
local onCollectNow
local nK
local onSellSelectedNow
local nr
local m8
local nQ
local mQ
local nx
local ne
local mW
local Workspace
local mD
local nk
local Options
local mJ
local nq
local Rebirths
local nP
local mP
local nw
local nd
local onUpgradeNow
local nj
local m0
local onBuySkillsNow
local Library
local np
local Skills
local connection2
local mO
local nv
function fns.fn4()
    return nM() < mP()
end
function fns.onRscripts()
    nF(nr, "Copied Rscripts profile to clipboard")
end
function fns.fn23(bz)
    local PlacedTroops = LocalPlayer:FindFirstChild("PlacedTroops")
    if not PlacedTroops then
        return 0
    end
    local pV = 0
    for i, child in ipairs(PlacedTroops:GetChildren()) do
        if child.Value == bz then
            pV += 1
        end
    end
    return pV
end
function fns.fn27()
    local Visuals = Workspace:FindFirstChild("Visuals")
    if not Visuals then
        return
    end
    local RolledTroopModel = Visuals:FindFirstChild("RolledTroopModel")
    if RolledTroopModel then
        RolledTroopModel:Destroy()
    end
end
function fns.onOnClientEvent()
    mW()
    local qy = mL("AutoRoll") and not Library.Unloaded
    if qy then
        local qy_1 = mL("RollRequireRoom") and not mM()
        if not qy_1 then
            task.defer(nc)
        end
    end
end
function fns.onInputChanged(jj)
    local UserInputType = jj.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        np = tick()
    end
end
function fns.worker11()
    while not Library.Unloaded do
        if mL("AutoPlace") then
            nH()
        end
        task.wait(nK("PlaceDelay", 0.35))
    end
end
function fns.fn107()
    local Troops = LocalPlayer:FindFirstChild("Troops")
    local pS = Troops and #Troops:GetChildren()
    return pS or 0
end
function fns.fn117(il)
    local DiscordGroup = il:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = nx })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = nx })
end
local function worker13()
    while not Library.Unloaded do
        if mL("AutoRoll") then
            m3()
        end
        task.wait(nK("RollDelay", 0.5))
    end
end
local function fn143(dC, dD, dE)
    local Ground = dC:FindFirstChild("Ground")
    if not Ground then
        return nil
    end
    local rv = mS()
    if dE then
        for i, v in ipairs(dE) do
            table.insert(rv, v)
        end
    end
    local rw = nP(dC)
    local rx = math.floor(Ground.Size.X * 0.5) - 2
    local ru_1 = math.max(math.floor(dD), 1)
    local ry = nK("PlaceMaxPathDistance", 0)
    local rz = {}
    local rL = -rx
    while ru_1 > 0 and rL <= rx or ru_1 <= 0 and rL >= rx do
        local rM = rL
        local rQ_1 = -rx
        while ru_1 > 0 and rQ_1 <= rx or ru_1 <= 0 and rQ_1 >= rx do
            local rR = rQ_1
            local rA_2 = not nd(dC, rM, rR) and mD(rM, rR, dD, rv)
            if rA_2 then
                local rA_3 = nq(rM, rR, rw)
                if ry <= 0 or rA_3 <= ry * ry then
                    table.insert(rz, { pos = Vector3.new(rM, 0, rR), dist = rA_3 })
                end
            end
            rQ_1 += ru_1
        end
        rL += ru_1
    end
    if #rz == 0 and ry > 0 then
        local rQ_2 = -rx
        while ru_1 > 0 and rQ_2 <= rx or ru_1 <= 0 and rQ_2 >= rx do
            local rT = rQ_2
            local rX = -rx
            while ru_1 > 0 and rX <= rx or ru_1 <= 0 and rX >= rx do
                local rY = rX
                local ry_3 = not nd(dC, rT, rY) and mD(rT, rY, dD, rv)
                if ry_3 then
                    table.insert(rz, { pos = Vector3.new(rT, 0, rY), dist = nq(rT, rY, rw) })
                end
                rX += ru_1
            end
            rQ_2 += ru_1
        end
    end
    table.sort(rz, function(d2, d3)
        return d2.dist < d3.dist
    end)
    local ru_2 = rz[1]
    return ru_2 and ru_2.pos or nil
end
local function fn176()
    local qt = mL("RollRequireRoom") and not mM()
    if qt then
        return
    end
    local qt_1 = ng()
    local qu = qt_1 and mL("AutoBuyRoll") and mF(qt_1)
    if qu then
        return
    end
    nc()
end
local function worker10()
    while not Library.Unloaded do
        if mL("AutoReplace") then
            onReplaceNow()
        end
        task.wait(nK("ReplaceDelay", 0.5))
    end
end
local function fn246()
    local u1_1
    local u0_1
    if identifyexecutor then
        u1_1, u0_1 = identifyexecutor()
        local u2 = u1_1 ~= ""
        local u3 = type(u1_1) == "string" and u2
        if u3 then
            local u2_1 = type(u0_1) == "string" and u0_1 ~= "" and u1_1 .. " " .. u0_1
            mU = u2_1 or u1_1
        end
    end
end
local function fn247()
    return LocalPlayer:GetAttribute("RolledTroop")
end
local function fn249(cc)
    local qm = nu(cc)
    if not qm then
        return false
    elseif not m9(nt("BuyRollRarities"), qm.Rarity) then
        return false
    elseif not mX(nt("BuyRollTroops"), cc) then
        return false
    else
        local qn = (tonumber(qm.Price))
        local qs = if qn then 1 else 0
        local qq = 3363 * qs + 176 * (1 - qs)
        local qr = 2253 * qs + 1095 * (1 - qs)
        if not ((qq * 2963 + qr * 267 + qq * qr) % 16777213 == 1365746) then
            qn = 0
        end
        local qm_1 = qn
        local qn_1 = nK("BuyRollMaxPrice", 0)
        if qn_1 > 0 and qm_1 > qn_1 then
            return false
        end
        local qn_2 = nK("BuyRollMoneyBuffer", 0)
        if mO() - qm_1 < qn_2 then
            return false
        end
        return true
    end
end
local function fn267()
    local PlacedTroops = LocalPlayer:FindFirstChild("PlacedTroops")
    local pM = PlacedTroops and #PlacedTroops:GetChildren()
    local pL_1 = pM
    local pQ = if pL_1 then 1 else 0
    local pO = 154 * pQ + 2258 * (1 - pQ)
    local pP = 779 * pQ + 2394 * (1 - pQ)
    if not ((pO * 583 + pP * 915 + pO * pP) % 16777213 == 922533) then
        pL_1 = 0
    end
    return pL_1
end
local function fn270(go)
    local tB = nu(go)
    if not tB then
        return false
    elseif not m9(nt("UpgradeRarities"), tB.Rarity) then
        return false
    elseif not mX(nt("UpgradeTroops"), go) then
        return false
    else
        return true
    end
end
local function fn273(fh)
    local sL = nu(fh)
    if not sL then
        return false
    elseif not m9(nt("ReplaceWithRarities"), sL.Rarity) then
        return false
    elseif not mX(nt("ReplaceWithTroops"), fh) then
        return false
    elseif nn(fh) >= mY(fh) then
        return false
    else
        return true
    end
end
local function worker2()
    while not Library.Unloaded do
        if mL("KillAura") then
            ne()
        end
        local vC = nK("KillAuraDelay", 0)
        if vC <= 0 then
            vC = nG()
        end
        task.wait(vC)
    end
end
local function fn284(cO, cP, cQ)
    local Ground = cO:FindFirstChild("Ground")
    if not Ground then
        return true
    end
    for i, descendant in ipairs(cO:GetDescendants()) do
        local qE = (descendant:IsA("BasePart"))
        if qE then
            qE = descendant.Name == "Path" or descendant.Name == "AnchorPart"
        end
        if qE then
            local Position = Ground.CFrame:ToObjectSpace(descendant.CFrame).Position
            local qF_2 = descendant.Size.X * 0.5 + 0.75
            local qG = descendant.Size.Z * 0.5 + 0.75
            local qH = math.abs(cP - Position.X) <= qF_2 and math.abs(cQ - Position.Z) <= qG
            if qH then
                return true
            end
        end
    end
    return false
end
local function fn297(aK)
    local pk = Options[aK]
    return pk and pk.Value or {}
end
local function fn314(an, ao)
    return string.format('<font color="%s">%s</font>', ao, an)
end
local function worker4()
    while not Library.Unloaded do
        if mL("AutoSellSelectedBrainrots") then
            onSellSelectedNow()
        end
        task.wait(nK("SellSelectedDelay", 3))
    end
end
local function fn374(a8)
    return Troops2[a8]
end
local function onUnload()
    Library:Unload()
end
local function fn417(K, L)
    if K.order == L.order then
        return K.price < L.price
    end
    return K.order < L.order
end
local function fn423(gS, gT)
    local tR = type(gT) ~= "table"
    local tX = if tR then 1 else 0
    local tV = 3151 * tX + 2852 * (1 - tX)
    local tW = 232 * tX + 834 * (1 - tX)
    if not ((tV * 2525 + tW * 1182 + tV * tW) % 16777213 == 8961531) then
        tR = gT.IsBack
    end
    if tR then
        return false
    end
    local tR_1 = tonumber(gT.Price)
    if not tR_1 or tR_1 <= 0 then
        return false
    end
    local tR_2 = LocalPlayer.SkillTree:FindFirstChild(gS)
    if tR_2 and tR_2.Value == true then
        return false
    end
    local ConnectedTo = gT.ConnectedTo
    local tS_2 = ConnectedTo ~= ""
    local tT = type(ConnectedTo) == "string" and tS_2
    if tT then
        local tS_3 = LocalPlayer.SkillTree:FindFirstChild(ConnectedTo)
        if not (tS_3 and tS_3.Value == true) then
            return false
        end
        return true
    end
    return true
end
local function fn425(y, A)
    return y.order < A.order
end
local function worker8()
    while not Library.Unloaded do
        if mL("AutoBuySkills") then
            onBuySkillsNow()
        end
        task.wait(nK("SkillDelay", 0.35))
    end
end
local function worker6()
    while not Library.Unloaded do
        if mL("AutoCollectMoney") then
            onCollectNow()
        end
        task.wait(nK("CollectDelay", 2))
    end
end
local function fn463(ep)
    local sb = nu(ep)
    if not sb then
        return false
    elseif not m9(nt("PlaceRarities"), sb.Rarity) then
        return false
    else
        local sf = if not mX(nt("PlaceTroops"), ep) then 1 else 0
        if sf == 1 then
            return false
        elseif nn(ep) >= mY(ep) then
            return false
        else
            return true
        end
    end
end
local function fn469(V, W)
    if V.order == W.order then
        return V.mps < W.mps
    end
    return V.order < W.order
end
local function fn477()
    local Currencies = LocalPlayer:FindFirstChild("Currencies")
    local pw = Currencies and Currencies:FindFirstChild("Money")
    local pv_1 = pw
    if pw then
        pw = tonumber(pv_1.Value)
    end
    return pw or 0
end
local function fn482()
    local Misc = LocalPlayer:FindFirstChild("Misc")
    local pJ = Misc and Misc:FindFirstChild("MaxTroops")
    local pI_1 = pJ
    if pJ then
        pJ = tonumber(pI_1.Value)
    end
    return pJ or 6
end
local function fn485()
    local uF = 0.45
    for k, v in pairs(Skills) do
        local uG = type(v) == "table" and v.SkillType == "PlayerFirerate"
        if uG then
            local uG_1 = LocalPlayer.SkillTree:FindFirstChild(k)
            if uG_1 and uG_1.Value == true then
                local uG_2 = tonumber(v.SkillAmount) or 0
                uF *= 1 - uG_2 / 100
            end
        end
    end
    return math.max(uF, 0.05)
end
local function worker3()
    while not Library.Unloaded do
        if mL("AutoSellAllBrainrots") then
            nv()
        end
        task.wait(nK("SellAllDelay", 5))
    end
end
local function onInputBegan()
    np = tick()
end
local function fn504()
    nF(nw, "Copied Discord invite to clipboard")
end
local function fn526()
    pcall(function()
        ni.SellAllBrainrots:FireServer()
    end)
end
local function worker12()
    while not Library.Unloaded do
        if mL("AutoBuyRoll") then
            mG()
        end
        task.wait(nK("BuyRollDelay", 0.25))
    end
end
local function fn549(aP, aQ)
    local pr = not aP or not next(aP)
    if pr then
        return true
    end
    return aP[aQ] == true
end
local function fn550(az)
    local pe = Toggles[az]
    return pe ~= nil and pe.Value == true
end
local function fn553()
    local uj = Rebirths[nL() + 1]
    if type(uj) ~= "number" then
        return
    end
    local uk = nK("RebirthMoneyBuffer", 0)
    if mO() - uj < uk then
        return
    end
    if mO() < uj then
        return
    end
    pcall(function()
        ni.Rebirth:FireServer()
    end)
end
local function fn579(c9, da, db)
    local qZ = math.huge
    for i, v in ipairs(db) do
        local q_ = math.max(math.abs(c9 - v.x) - v.halfX, 0)
        local q0 = math.max(math.abs(da - v.z) - v.halfZ, 0)
        local q1 = q_ * q_ + q0 * q0
        if q1 < qZ then
            qZ = q1
        end
    end
    return qZ
end
local function fn582(aq, ar, as)
    return string.format("<b>%s</b> %s %s", aq, nk("-", "#5a6070"), nk(ar, as))
end
local function worker9()
    while not Library.Unloaded do
        if mL("AutoUpgrade") then
            onUpgradeNow()
        end
        task.wait(nK("UpgradeDelay", 0.35))
    end
end
local function fn594()
    pcall(function()
        ni.RollTroop:FireServer(true)
    end)
end
local function worker()
    local u9_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local u8 = math.floor(os.clock() - nz)
        if u8 < 60 then
            u9_1 = u8 .. "s"
        elseif u8 < 3600 then
            u9_1 = string.format("%dm %ds", math.floor((u8) / (60)), u8 % 60)
        else
            u9_1 = string.format("%dh %dm", math.floor((u8) / (3600)), math.floor((u8 % 3600) / (60)))
        end
        Label:SetText(m8("Session time", u9_1, mQ))
    end
end
local function worker14()
    while not Library.Unloaded do
        task.wait(2)
        if mL("AntiAfk") then
            local vn = tick() - np
            local vo = tick() - nj
            if vn >= 300 and vo >= 60 then
                pcall(m4)
            else
                if vn < 300 and vo >= 300 then
                    pcall(m4)
                end
            end
        end
    end
end
local function fn605(ag, ah)
    if setclipboard then
        setclipboard(ag)
    elseif toclipboard then
        toclipboard(ag)
    end
    Library:Notify(ah)
end
local function fn618()
    local Currencies = LocalPlayer:FindFirstChild("Currencies")
    local pz = Currencies and Currencies:FindFirstChild("Rebirth")
    local py_1 = pz
    if pz then
        pz = tonumber(py_1.Value)
    end
    return pz or 0
end
local function fn628()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    nj = tick()
end
local function fn632()
    connection:Disconnect()
    connection2:Disconnect()
end
local function fn635()
    local qw = ng()
    if not qw then
        return
    end
    if not mF(qw) then
        return
    end
    pcall(function()
        ni.BuyRolledTroop:FireServer()
    end)
end
local function fn640()
    local NotSaving = LocalPlayer:FindFirstChild("NotSaving")
    local pC = NotSaving and NotSaving:FindFirstChild("PlayerPlot")
    if not pC then
        return nil
    end
    local Plots = Workspace:FindFirstChild("Plots")
    local pD = Plots and Plots:FindFirstChild(pC.Value)
    return pD
end
local function fn664(bG)
    local p2 = nu(bG)
    if not p2 or p2.MaxPlaced == nil then
        return math.huge
    end
    local p3_1 = tonumber(p2.MaxPlaced) or 0
    local p4 = p3_1
    local MaxPlacedSkillIncrease = p2.MaxPlacedSkillIncrease
    if MaxPlacedSkillIncrease then
        for k, v in pairs(Skills) do
            local p2_1 = type(v) == "table" and v.SkillType == MaxPlacedSkillIncrease
            if p2_1 then
                local p2_2 = LocalPlayer.SkillTree:FindFirstChild(k)
                if p2_2 and p2_2.Value == true then
                    local p2_3 = tonumber(v.SkillAmount) or 0
                    p4 += p2_3
                end
            end
        end
    end
    return p4
end
local function worker7()
    while not Library.Unloaded do
        if mL("AutoRebirth") then
            mJ()
        end
        task.wait(nK("RebirthDelay", 2))
    end
end
local function fn686(dq, dr, ds, dt)
    local rk = ds * ds
    for i, v in ipairs(dt) do
        local rl = dq - v.x
        local rm = dr - v.z
        if rl * rl + rm * rm < rk then
            return false
        end
    end
    return true
end
local function fn693()
    pcall(function()
        ni.EquipBestBrainrots:FireServer()
    end)
end
local function fn704(aE, aF)
    local ph = Options[aE]
    local pi = ph and tonumber(ph.Value)
    return pi or aF
end
local function fn761(c1)
    local Ground = c1:FindFirstChild("Ground")
    local qQ = {}
    if not Ground then
        return qQ
    end
    for i, descendant in ipairs(c1:GetDescendants()) do
        local qR = descendant:IsA("BasePart") and descendant.Name == "Path"
        if qR then
            local Position = Ground.CFrame:ToObjectSpace(descendant.CFrame).Position
            table.insert(qQ, { x = Position.X, z = Position.Z, halfX = descendant.Size.X * 0.5, halfZ = descendant.Size.Z * 0.5 })
        end
    end
    return qQ
end
local function fn813()
    local uv = 10
    for k, v in pairs(Skills) do
        local uw = type(v) == "table" and v.SkillType == "PlayerRange"
        if uw then
            local uw_1 = LocalPlayer.SkillTree:FindFirstChild(k)
            if uw_1 and uw_1.Value == true then
                local uw_2 = tonumber(v.SkillAmount) or 0
                uv += uw_2
            end
        end
    end
    return uv
end
local function fn817(fa)
    local sG = nu(fa)
    if not sG then
        return false
    end
    local sK = if not m9(nt("ReplaceFromRarities"), sG.Rarity) then 1 else 0
    if sK == 1 then
        return false
    elseif not mX(nt("ReplaceFromTroops"), fa) then
        return false
    else
        return true
    end
end
local function onCopyJoinScript_JobID()
    local iD = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, nQ)
    nF(iD, "Copied join script to clipboard")
end
local function fn828()
    local q9 = {}
    local PlacedTroops = LocalPlayer:FindFirstChild("PlacedTroops")
    if not PlacedTroops then
        return q9
    end
    for i, child in ipairs(PlacedTroops:GetChildren()) do
        local insert = table.insert
        local rb = tonumber(child:GetAttribute("XPosition")) or 0
        local rc = tonumber(child:GetAttribute("ZPosition")) or 0
        insert(q9, { x = rb, z = rc })
    end
    return q9
end
local function fn841(fW)
    local tf = nt("SellBrainrotTypes")
    local tg = nt("SellBrainrotRarities")
    local th = tf and next(tf) ~= nil
    local ti = tg
    if ti then
        ti = next(tg) ~= nil
    end
    local th_1 = ti
    local ti_1 = not th_1
    local tk = not th
    if tk ~= false then
        tk = ti_1
    end
    if tk then
        return false
    end
    local ti_2 = Enemies[fW]
    local tk_1 = ti_2 and ti_2.Rarity
    local ti_3 = th
    if ti_3 then
        ti_3 = tf[fW] ~= true
    end
    if ti_3 then
        return false
    end
    local tf_1 = th_1
    if tf_1 then
        tf_1 = not tk_1 or tg[tk_1] ~= true
    end
    if tf_1 then
        return false
    end
    return true
end
local function fn843(aT, aU)
    local pt = not aT or not next(aT)
    if pt then
        return true
    end
    return aT[aU] == true
end
local function worker5()
    while not Library.Unloaded do
        if mL("AutoEquipBest") then
            ny()
        end
        task.wait(nK("EquipBestDelay", 5))
    end
end
local function fn877()
    if not mM() then
        return
    end
    local sh = na()
    if not sh then
        return
    end
    local Troops = LocalPlayer:FindFirstChild("Troops")
    if not Troops then
        return
    end
    local sj = nK("PlaceSpacing", 3)
    local sk = {}
    for i, child in ipairs(Troops:GetChildren()) do
        local si_1 = m0[child.Name]
        local sl_1 = si_1 and tick() < si_1
        local si_2 = not sl_1
        if si_2 ~= false then
            si_2 = no(child.Value)
        end
        if si_2 then
            local si_3 = nu(child.Value)
            local sl_2 = si_3 and si_3.MaxPlaced ~= nil
            local insert = table.insert
            local Value = child.Value
            local si_5 = sl_2 and 1 or 0
            insert(sk, { troop = child, name = Value, priority = si_5, score = mZ(child.Value, 1) })
        end
    end
    table.sort(sk, function(e_, e0)
        if e_.priority == e0.priority then
            return e_.score > e0.score
        end
        return e_.priority < e0.priority
    end)
    for i, v in ipairs(sk) do
        if not mM() then
            break
        elseif not not no(v.name) then
            local si_6 = false
            local sk_1 = {}
            local sD = 1
            while sD <= 12 do
                local sl_4 = nm(sh, sj, sk_1)
                if not sl_4 then
                    break
                elseif mT(v.troop, sl_4) then
                    si_6 = true
                    task.wait(nK("PlaceDelay", 0.35))
                    break
                else
                    table.insert(sk_1, { x = sl_4.X, z = sl_4.Z })
                    sD += 1
                end
            end
            if not si_6 then
                m0[v.troop.Name] = tick() + 5
            end
        end
    end
end
mD = nil
Label = nil
mF = nil
mG = nil
onReplaceNow = nil
Library = nil
mJ = nil
onSellSelectedNow = nil
mL = nil
mM = nil
connection = nil
mO = nil
mP = nil
mQ = nil
mS = nil
mT = nil
mU = nil
onUpgradeNow = nil
mW = nil
mX = nil
mY = nil
mZ = nil
Enemies = nil
m0 = nil
m3 = nil
m4 = nil
Skills = nil
Rebirths = nil
m8 = nil
m9 = nil
na = nil
nc = nil
nd = nil
ne = nil
Troops2 = nil
ng = nil
ni = nil
nj = nil
nk = nil
onCollectNow = nil
nm = nil
nn = nil
no = nil
np = nil
local mR, m1, m2, m5, Rarities, nh
nq = nil
nr = nil
nt = nil
nu = nil
nv = nil
nw = nil
nx = nil
ny = nil
nz = nil
LocalPlayer = nil
Workspace = nil
VirtualUser = nil
nF = nil
nG = nil
nH = nil
onBuySkillsNow = nil
Options = nil
nK = nil
nL = nil
nM = nil
Toggles = nil
connection2 = nil
nP = nil
nQ = nil
local ns, nA, n3
ns = nil
nA = nil
local nC
vM_1, UserInputService, VirtualUser, Workspace, LocalPlayer, nw, nr, ni, Troops2, Rarities, Rebirths, Skills, m1, Enemies = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if (LocalPlayer or not UserInputService or not UserInputService and UserInputService) and (UserInputService and not UserInputService or UserInputService and not Workspace) and (not Workspace or not UserInputService or LocalPlayer and UserInputService or (not Workspace and not Workspace or (not LocalPlayer or UserInputService))) or ((UserInputService or not Workspace) and (not UserInputService or Workspace) or (not Workspace and not Workspace or (LocalPlayer or UserInputService))) and (LocalPlayer and not UserInputService and (not LocalPlayer and not LocalPlayer) or (UserInputService or not UserInputService or (not Workspace or not Workspace))) or not ((LocalPlayer or not UserInputService or not UserInputService and UserInputService) and (UserInputService and not UserInputService or UserInputService and not Workspace) and (not Workspace or not UserInputService or LocalPlayer and UserInputService or (not Workspace and not Workspace or (not LocalPlayer or UserInputService))) or ((UserInputService or not Workspace) and (not UserInputService or Workspace) or (not Workspace and not Workspace or (LocalPlayer or UserInputService))) and (LocalPlayer and not UserInputService and (not LocalPlayer and not LocalPlayer) or (UserInputService or not UserInputService or (not Workspace or not Workspace)))) then
    vM_1 = game:GetService("Players")
else
    m1 = game:GetService("Players")
end
local vM_4 = game:GetService("ReplicatedStorage")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
Workspace = game:GetService("Workspace")
LocalPlayer = vM_1.LocalPlayer
local vM_22 = "Roll Your Army"
nw = "https://discord.gg/K7Qxnxkk46"
nr = "https://discord.gg/K7Qxnxkk46"
local vM_12 = vM_4:WaitForChild("Modules")
ni = vM_4:WaitForChild("Remotes")
Troops2 = require(vM_12:WaitForChild("Troops"))
Rarities = require(vM_12:WaitForChild("Rarities"))
Rebirths = require(vM_12:WaitForChild("Rebirths"))
Skills = require(vM_12:WaitForChild("SkillTree"):WaitForChild("Skills"))
m1 = require(vM_12:WaitForChild("Util"))
Enemies = require(vM_12:WaitForChild("Enemies"))
local vM_13 = {}
local vM_15 = {}
for k, v in pairs(Rarities) do
    if type(v) == "table" then
        vM_1 = table.insert
        vM_12 = v.LayoutOrder or 999
        vM_1(vM_15, { name = k, order = vM_12 })
    end
end
local vM_20 = 3
repeat
    vM_1 = {
        "vzxaxa",
        "csjsbexw",
        "xplbnfygexi",
        "rzfghwnpdba",
        "isnqmmltajt",
        "dydbkj",
        "iwzeizo",
        "bvkgqdfugslx",
        "jneouqx",
        "xozi",
        "lhme",
        "pnxqewkf",
        "gsqyydpq",
        "qqqzduv"
    }
    if vM_1[(vM_20 * 63 + 21) % 14 + 1] <= vM_1[(vM_20 * 63 + 21) % 14 + 1] then
        table.sort(vM_15, fn425)
    else
        table.sort(vM_15, fn425)
    end
    vM_20 = (vM_20 + 5) % 8
until (vM_20 * 5 + 5) % 8 == 5
for i, v in ipairs(vM_15) do
    table.insert(vM_13, v.name)
end
vM_1 = {}
vM_12 = {}
for k, v in pairs(Troops2) do
    vM_20 = type(v) == "table" and v.Rarity
    if vM_20 then
        vM_20 = 999
        vM_4 = Rarities[v.Rarity]
        if type(vM_4) == "table" then
            vM_15 = vM_4.LayoutOrder or 999
            vM_20 = vM_15
        end
        vM_4 = table.insert
        vM_15 = tonumber(v.Price) or 0
        vM_4(vM_12, { name = k, order = vM_20, price = vM_15 })
    end
end
local vM_24 = 2
repeat
    if vM_24 * 132642495 + 4 + 2 <= vM_24 * 132642495 + 4 + 2 + 2 then
        table.sort(vM_12, fn417)
    else
        table.sort(vM_12, fn417)
    end
    vM_24 = (vM_24 + 2) % 4
until (vM_24 * 3 + 2) % 4 == 2
for i, v in ipairs(vM_12) do
    table.insert(vM_1, v.name)
end
vM_12 = {}
vM_20 = {}
for k, v in pairs(Enemies) do
    vM_4 = type(v) == "table" and v.Rarity
    if vM_4 then
        vM_4 = 999
        vM_15 = Rarities[v.Rarity]
        if type(vM_15) == "table" then
            vM_24 = vM_15.LayoutOrder or 999
            vM_4 = vM_24
        end
        vM_15 = table.insert
        vM_24 = tonumber(v.MoneyPerSecond) or 0
        vM_15(vM_20, { name = k, order = vM_4, mps = vM_24 })
    end
end
table.sort(vM_20, fn469)
for i, v in ipairs(vM_20) do
    table.insert(vM_12, v.name)
end
Library, Toggles, Options, mQ, m0, vM_15, nF, nx, nk, m8, mL, nK, nt, m9, mX, mO, nL, nu, ng, na, mP, nM, nn, mY, nC, mW, mM, mF, nc, m3, mG, nd, nP, nq, mS, mD, nm, mZ, no, mT, nH, ns, m5, onReplaceNow, nA, onSellSelectedNow, nv, nh, onUpgradeNow, m2, onBuySkillsNow, mJ, ny, onCollectNow, mR, nG, ne, vM_17 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
nF = fn605
nx = fn504
nk = fn314
m8 = fn582
local n5 = "#7fd47f"
local n4 = "#6ec1ff"
if ((ThemeManager or nh or ThemeManager and SaveManager or (ThemeManager and nh or ThemeManager and not nH)) and ((SaveManager or SaveManager) and (nh or not SaveManager) and (not nh or SaveManager or (not nH or SaveManager))) or (ThemeManager or nH or not ThemeManager and ThemeManager or (not SaveManager or SaveManager) and (nH and not ThemeManager)) and (SaveManager and SaveManager or (not nH or not nh) or nH and nH and (not nH and nH))) and not ((ThemeManager or nh or ThemeManager and SaveManager or (ThemeManager and nh or ThemeManager and not nH)) and ((SaveManager or SaveManager) and (nh or not SaveManager) and (not nh or SaveManager or (not nH or SaveManager))) or (ThemeManager or nH or not ThemeManager and ThemeManager or (not SaveManager or SaveManager) and (nH and not ThemeManager)) and (SaveManager and SaveManager or (not nH or not nh) or nH and nH and (not nH and nH))) then
    n3 = "#e8a34d"
    mQ = "#8b93a3"
    nK = fn550
    mL = fn704
else
    mQ = "#e8a34d"
    n3 = "#8b93a3"
    mL = fn550
    nK = fn704
end
nt = fn297
m9 = fn549
mX = fn843
mO = fn477
nL = fn618
nu = fn374
ng = fn247
na = fn640
mP = fn482
nM = fn267
nn = fns.fn23
mY = fn664
nC = function(bU, bV)
    local qe_1
    local qd_1
    qd_1, qe_1 = pcall(function()
        return m1:GetTroopUpgradePrice(LocalPlayer, bU, bV)
    end)
    if qd_1 then
        local qd_2 = tonumber(qe_1) or 0
        return qd_2
    end
    return 0
end
m0 = {}
mW = fns.fn27
mM = fns.fn4
mF = fn249
nc = fn594
m3 = fn176
mG = fn635
if (((not mD or not nG) and (mD or n3) or not nG and nG and (not nG and not n3)) and (not n3 or not mD or (not mD or not mD) or (not nG and mD or not mD and mD)) or ((not mD or n3) and (nG or not nG) or (nG or nG) and (mD and not n3)) and ((mD or not mD or (not mD or nG)) and ((n3 or nG) and (not n3 or not n3)))) and not (((not mD or not nG) and (mD or n3) or not nG and nG and (not nG and not n3)) and (not n3 or not mD or (not mD or not mD) or (not nG and mD or not mD and mD)) or ((not mD or n3) and (nG or not nG) or (nG or nG) and (mD and not n3)) and ((mD or not mD or (not mD or nG)) and ((n3 or nG) and (not n3 or not n3)))) then
    nq.BuyRolledTroop.OnClientEvent:Connect(fns.onOnClientEvent)
    nP = fn284
    nd = fn761
    ni = fn579
else
    ni.BuyRolledTroop.OnClientEvent:Connect(fns.onOnClientEvent)
    nd = fn284
    nP = fn761
    nq = fn579
end
if not nd and not vM_15 or Library and mX or (not nd or not onUpgradeNow) and (nd or not Library) or not (not nd and not vM_15 or Library and mX or (not nd or not onUpgradeNow) and (nd or not Library)) then
    mS = fn828
else
    vM_17 = fn828
end
mD = fn686
if (mW or mW) and (fns.fn107 or not mY) or (not mY or mX or mW and fns.fn107) or (not mX and nL and (mW and false) or mY and nL and (not mX and not mX)) or not ((mW or mW) and (fns.fn107 or not mY) or (not mY or mX or mW and fns.fn107) or (not mX and nL and (mW and false) or mY and nL and (not mX and not mX))) then
    nm = fn143
    mZ = function(d7, d8, d9)
        local r5
        local r6 = nu(d7)
        if not r6 then
            return -math.huge
        end
        local r7 = 0
        local r8 = Rarities[r6.Rarity]
        if type(r8) == "table" then
            local r9_3 = tonumber(r8.LayoutOrder) or 0
            r7 = r9_3
        end
        r5 = 0
        pcall(function()
            local r_ = d8
            local r4 = if r_ then 1 else 0
            local r2 = 3311 * r4 + 3764 * (1 - r4)
            local r3 = 479 * r4 + 2292 * (1 - r4)
            if not ((r2 * 1027 + r3 * 67 + r2 * r3) % 16777213 == 5018459) then
                r_ = 1
            end
            local r0 = tonumber(m1:GetDPS(LocalPlayer, d7, r_, d9)) or 0
            r5 = r0
        end)
        local r8_2 = r7 * 1000000000000 + r5 * 1000
        local r9_4 = tonumber(r6.Price) or 0
        return r8_2 + r9_4
    end
    no = fn463
    mT = function(ey, ez)
        local eA = false
        pcall(function()
            eA = ni.PlaceTroop:InvokeServer({ UUID = ey.Name, Rotation = 0, Position = ez }) == true
        end)
        return eA
    end
else
    mT = fn143
    nm = function(d7, d8, d9)
        local r5
        local r6 = nu(d7)
        if not r6 then
            return -math.huge
        end
        local r7 = 0
        local r8 = Rarities[r6.Rarity]
        if type(r8) == "table" then
            local r9_1 = tonumber(r8.LayoutOrder) or 0
            r7 = r9_1
        end
        r5 = 0
        pcall(function()
            local r_ = d8
            local r4 = if r_ then 1 else 0
            local r2 = 3311 * r4 + 3764 * (1 - r4)
            local r3 = 479 * r4 + 2292 * (1 - r4)
            if not ((r2 * 1027 + r3 * 67 + r2 * r3) % 16777213 == 5018459) then
                r_ = 1
            end
            local r0 = tonumber(m1:GetDPS(LocalPlayer, d7, r_, d9)) or 0
            r5 = r0
        end)
        local r8_1 = r7 * 1000000000000 + r5 * 1000
        local r9_2 = tonumber(r6.Price) or 0
        return r8_1 + r9_2
    end
    mZ = fn463
    no = function(ey, ez)
        local eA = false
        pcall(function()
            eA = ni.PlaceTroop:InvokeServer({ UUID = ey.Name, Rotation = 0, Position = ez }) == true
        end)
        return eA
    end
end
nH = fn877
ns = fn817
m5 = fn273
onReplaceNow = function()
    local sN, sO
    local sP = na()
    if not sP then
        return
    end
    local Troops = LocalPlayer:FindFirstChild("Troops")
    local PlacedTroops = LocalPlayer:FindFirstChild("PlacedTroops")
    if not Troops or not PlacedTroops then
        return
    end
    local sS_1 = nil
    for i, child in ipairs(Troops:GetChildren()) do
        if m5(child.Value) then
            local sQ_1 = mZ(child.Value, 1)
            if not sS_1 or sQ_1 > sS_1.score then
                sS_1 = { troop = child, name = child.Value, score = sQ_1 }
            end
        end
    end
    if not sS_1 then
        return
    end
    sN = nil
    for i, child in ipairs(PlacedTroops:GetChildren()) do
        if ns(child.Value) then
            local Value2 = child.Value
            local sR_1 = child:GetAttribute("Level") or 1
            local sT_2 = mZ(Value2, sR_1, child:GetAttribute("Enchant"))
            local sQ_3 = not sN
            local s9 = if sQ_3 then 1 else 0
            local s7 = 3414 * s9 + 1279 * (1 - s9)
            local s8 = 845 * s9 + 1450 * (1 - s9)
            if not ((s7 * 3827 + s8 * 1208 + s7 * s8) % 16777213 == 193755) then
                sQ_3 = sT_2 < sN.score
            end
            if sQ_3 then
                local Value = child.Value
                local sR_2 = tonumber(child:GetAttribute("XPosition")) or 0
                local sU = tonumber(child:GetAttribute("ZPosition")) or 0
                sN = { troop = child, name = Value, score = sT_2, x = sR_2, z = sU }
            end
        end
    end
    if not sN then
        return
    end
    if sS_1.score <= sN.score then
        return
    end
    sO = false
    pcall(function()
        sO = ni.PickupTroop:InvokeServer(sN.troop.Name) == true
    end)
    if not sO then
        return
    end
    task.wait(0.15)
    local sQ_5 = Vector3.new(sN.x, 0, sN.z)
    if mT(sS_1.troop, sQ_5) then
        task.wait(nK("ReplaceDelay", 0.5))
        return
    end
    local sQ_6 = { { x = sN.x, z = sN.z } }
    local sR_3 = nK("PlaceSpacing", 3)
    local tc = 1
    while tc <= 10 do
        local sT_3 = nm(sP, sR_3, sQ_6)
        if not sT_3 then
            break
        end
        if mT(sS_1.troop, sT_3) then
            task.wait(nK("ReplaceDelay", 0.5))
            return
        end
        table.insert(sQ_6, { x = sT_3.X, z = sT_3.Z })
        tc += 1
    end
end
nA = fn841
onSellSelectedNow = function()
    local tp
    local Brainrots = LocalPlayer:FindFirstChild("Brainrots")
    if not Brainrots then
        return
    end
    tp = {}
    for i, child in ipairs(Brainrots:GetChildren()) do
        if nA(child.Value) then
            table.insert(tp, child.Name)
        end
    end
    if #tp == 0 then
        return
    end
    pcall(function()
        ni.SellSpecific:FireServer(tp)
    end)
end
nv = fn526
if (not m9 and not nK or (not nK or vM_17) or (nK or vM_17 or (nK or not nK)) or (not nu and not vM_17 or nK and not nu or (nK or m9 or (m9 or vM_17)))) and ((nu and not vM_17 or m9 and not nK) and (not m9 and not vM_17 or not nK and nK) or not nK and not vM_17 and (not vM_17 and m9) and (not nK and nK and (not nK and nu))) or not ((not m9 and not nK or (not nK or vM_17) or (nK or vM_17 or (nK or not nK)) or (not nu and not vM_17 or nK and not nu or (nK or m9 or (m9 or vM_17)))) and ((nu and not vM_17 or m9 and not nK) and (not m9 and not vM_17 or not nK and nK) or not nK and not vM_17 and (not vM_17 and m9) and (not nK and nK and (not nK and nu)))) then
    nh = fn270
    onUpgradeNow = function()
        local PlacedTroops = LocalPlayer:FindFirstChild("PlacedTroops")
        if not PlacedTroops then
            return
        end
        local tG = nK("UpgradeMoneyBuffer", 0)
        local tH = nK("UpgradeMaxPrice", 0)
        local tE = mL("UpgradeUseMax")
        for i, child in ipairs(PlacedTroops:GetChildren()) do
            local tQ = child
            local Value = tQ.Value
            if nh(Value) then
                local tI = tonumber(tQ:GetAttribute("Level")) or 1
                local tI_2 = nC(Value, tI)
                local tF_4 = tI_2 > 0 and mO() - tI_2 >= tG
                if tF_4 then
                    tF_4 = tH <= 0 or tI_2 <= tH
                end
                if tF_4 then
                    pcall(function()
                        if tE then
                            ni.UpgradeMaxTroop:FireServer(tQ.Name)
                        else
                            ni.UpgradeTroop:FireServer(tQ.Name)
                        end
                    end)
                    task.wait(nK("UpgradeDelay", 0.35))
                end
            end
        end
    end
    m2 = fn423
else
    m2 = fn270
    nh = function()
        local PlacedTroops = LocalPlayer:FindFirstChild("PlacedTroops")
        if not PlacedTroops then
            return
        end
        local tG = nK("UpgradeMoneyBuffer", 0)
        local tH = nK("UpgradeMaxPrice", 0)
        local tE = mL("UpgradeUseMax")
        for i, child in ipairs(PlacedTroops:GetChildren()) do
            local tQ = child
            local Value = tQ.Value
            if nh(Value) then
                local tI = tonumber(tQ:GetAttribute("Level")) or 1
                local tI_1 = nC(Value, tI)
                local tF_2 = tI_1 > 0 and mO() - tI_1 >= tG
                if tF_2 then
                    tF_2 = tH <= 0 or tI_1 <= tH
                end
                if tF_2 then
                    pcall(function()
                        if tE then
                            ni.UpgradeMaxTroop:FireServer(tQ.Name)
                        else
                            ni.UpgradeTroop:FireServer(tQ.Name)
                        end
                    end)
                    task.wait(nK("UpgradeDelay", 0.35))
                end
            end
        end
    end
    onUpgradeNow = fn423
end
onBuySkillsNow = function()
    local t0 = nK("SkillMoneyBuffer", 0)
    local t1 = nK("SkillMaxPrice", 0)
    local t2 = {}
    for k, v in pairs(Skills) do
        if m2(k, v) then
            local t3 = tonumber(v.Price) or 0
            local t3_1 = mO() - t3 >= t0 and (t1 <= 0 or t3 <= t1)
            if t3_1 then
                table.insert(t2, { name = k, price = t3 })
            end
        end
    end
    table.sort(t2, function(he, hf)
        return he.price < hf.price
    end)
    for i, v in ipairs(t2) do
        local ui = v
        if mO() - ui.price < t0 then
            break
        end
        pcall(function()
            ni.BuySkill:FireServer(ui.name)
        end)
        task.wait(nK("SkillDelay", 0.35))
    end
end
mJ = fn553
ny = fn693
onCollectNow = function()
    local BrainrotSlots = LocalPlayer:FindFirstChild("BrainrotSlots")
    if not BrainrotSlots then
        return
    end
    for i, child in ipairs(BrainrotSlots:GetChildren()) do
        local uu = child
        local um_1 = uu.Value == true
        if um_1 then
            local un = tonumber(uu:GetAttribute("GeneratedMoney")) or 0
            um_1 = un > 0
        end
        if um_1 then
            pcall(function()
                ni.ClaimBrainrotSlotMoney:FireServer(uu.Name)
            end)
        end
    end
end
mR = fn813
nG = fn485
ne = function()
    local Character = LocalPlayer.Character
    local uR = Character and Character:FindFirstChild("HumanoidRootPart")
    if not uR then
        return
    end
    local Visuals = Workspace:FindFirstChild("Visuals")
    local uS = Visuals and Visuals:FindFirstChild("PlayerEnemies")
    if not uS then
        return
    end
    local uS_1 = nK("KillAuraRange", 0)
    if uS_1 <= 0 then
        uS_1 = mR()
    end
    local uT = Vector3.new(uR.Position.X, 0, uR.Position.Z)
    local uQ_2 = uS_1
    local uP
    for i, child in ipairs(uS:GetChildren()) do
        local PrimaryPart = child.PrimaryPart
        if PrimaryPart then
            local Magnitude = (uT - Vector3.new(PrimaryPart.Position.X, 0, PrimaryPart.Position.Z)).Magnitude
            if Magnitude < uQ_2 then
                uQ_2 = Magnitude
                uP = child
            end
        end
    end
    if uP then
        pcall(function()
            ni.PlayerDamageBrainrot:FireServer(uP.Name)
        end)
    end
end
vM_24 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = nw, Copyable = true }, "|", vM_22 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local n6 = {}
n6.Info = vM_24:AddTab("Info", "info")
vM_15 = vM_24:AddTab("Main", "gamepad-2")
n6.Settings = vM_24:AddTab("Settings", "settings")
vM_15:SetSubTabAlignment("Center")
n6.Roll = vM_15:AddSubTab("Roll", "dices")
n6.Units = vM_15:AddSubTab("Units", "swords")
n6.Skills = vM_15:AddSubTab("Skills", "network")
vM_17 = fns.fn117
for k, v in n6 do
    vM_17(v)
end
mU, Label, nQ = nil, nil, nil
mU = "Unknown"
pcall(fn246)
vM_20 = n6.Info:AddLeftGroupbox("Account", "circle-user")
vM_20:AddLabel(m8("User", LocalPlayer.Name, n5), true)
vM_20:AddLabel(m8("Status", "Keyless", n5), true)
vM_20:AddLabel(m8("Executor", mU, n5), true)
vM_24 = n6.Info:AddLeftGroupbox("Game Info", "gamepad-2")
vM_24:AddLabel(nk(vM_22 .. " [" .. tostring(game.PlaceId) .. "]", n4), true)
vM_24:AddLabel(m8("Place ID", tostring(game.PlaceId), n4), true)
Label = vM_24:AddLabel(m8("Session time", "0s", mQ), true)
nQ = tostring(game.JobId)
vM_15 = #nQ > 18
if vM_15 then
    vM_20 = 1
    repeat
        local wQ = bit32.rrotate(bit32.bxor(bit32.lrotate(vM_20, 6), string.byte(tostring(vM_20))), 6)
        if bit32.bxor(bit32.lrotate(bit32.bxor(wQ, 2955543423), 22), 3756788352) == bit32.lrotate(wQ, 22) then
            vM_15 = string.sub(nQ, 1, 18) .. "..."
        else
            nQ = string.sub(vM_15, 1, 18) .. "..."
        end
        vM_20 = (vM_20 + 1) % 4
    until (vM_20 * 3 + 0) % 4 == 2
end
vM_20 = vM_15 or nQ
nz, vM_15, np, nj, connection, connection2, m4 = nil, nil, nil, nil, nil, nil, nil
local oj = vM_20
vM_24:AddLabel(m8("Server", oj, n3), true)
vM_24:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
nz = os.clock()
task.spawn(worker)
local ScriptsGroup = n6.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(nk("Included in this hub", n3), true)
ScriptsGroup:AddLabel(nk(vM_22, n4), true)
local FeaturesGroup = n6.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(nk("Auto Roll / Buy Roll", n4), true)
FeaturesGroup:AddLabel(nk("Auto Place / Replace / Upgrade", n5), true)
FeaturesGroup:AddLabel(nk("Auto Skill Tree / Rebirth", mQ), true)
FeaturesGroup:AddLabel(nk("Auto Equip / Collect / Sell", n4), true)
FeaturesGroup:AddLabel(nk("Kill Aura", mQ), true)
FeaturesGroup:AddLabel(nk("Misc Utilities", n3), true)
local SocialsGroup = n6.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = nx })
SocialsGroup:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
local TempoHubGroup = n6.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = nx })
local FaqGroup = n6.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutoRollGroup = n6.Roll:AddLeftGroupbox("Auto Roll", "dices")
AutoRollGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
AutoRollGroup:AddSlider("RollDelay", { Text = "Roll delay", Default = 0.5, Min = 0.1, Max = 10, Rounding = 2, Suffix = "s" })
AutoRollGroup:AddToggle("RollRequireRoom", { Text = "Require place room", Default = false })
AutoRollGroup:AddButton({ Text = "Roll Now", Func = m3 })
local AutoBuyRollGroup = n6.Roll:AddRightGroupbox("Auto Buy Roll", "shopping-bag")
AutoBuyRollGroup:AddToggle("AutoBuyRoll", { Text = "Auto Buy Roll", Default = false })
AutoBuyRollGroup:AddSlider("BuyRollDelay", { Text = "Buy delay", Default = 0.25, Min = 0.05, Max = 5, Rounding = 2, Suffix = "s" })
AutoBuyRollGroup:AddSlider("BuyRollMaxPrice", { Text = "Max price", Default = 0, Min = 0, Max = 1000000000000, Rounding = 0, Suffix = "$" })
AutoBuyRollGroup:AddSlider("BuyRollMoneyBuffer", { Text = "Keep money", Default = 0, Min = 0, Max = 1000000000000, Rounding = 0, Suffix = "$" })
AutoBuyRollGroup:AddDropdown("BuyRollRarities", { Text = "Rarities", Values = vM_13, Multi = true, AllowNull = true, Default = {} })
AutoBuyRollGroup:AddDropdown("BuyRollTroops", {
    Text = "Troops",
    Values = vM_1,
    Multi = true,
    AllowNull = true,
    Default = {},
    Expandable = true,
    ExpandColumns = 2
})
AutoBuyRollGroup:AddButton({ Text = "Buy Roll Now", Func = mG })
vM_17 = n6.Units:AddLeftGroupbox("Auto Place", "map-pin")
if not oj and m4 or m4 and not m4 or (oj or not m4) and (not m4 or not m4) or (not oj or not m4) and (not oj and not oj) and (m4 and not m4 or m4 and m4) or not (not oj and m4 or m4 and not m4 or (oj or not m4) and (not m4 or not m4) or (not oj or not m4) and (not oj and not oj) and (m4 and not m4 or m4 and m4)) then
    vM_17:AddToggle("AutoPlace", { Text = "Auto Place Units", Default = false })
    vM_17:AddSlider("PlaceDelay", { Text = "Place delay", Default = 0.35, Min = 0.1, Max = 10, Rounding = 2, Suffix = "s" })
    vM_17:AddSlider("PlaceSpacing", { Text = "Spacing", Default = 3, Min = 1, Max = 10, Rounding = 0 })
    vM_17:AddSlider("PlaceMaxPathDistance", { Text = "Max path distance", Default = 6, Min = 0, Max = 30, Rounding = 0 })
    vM_17:AddDropdown("PlaceRarities", { Text = "Rarities", Values = vM_13, Multi = true, AllowNull = true, Default = {} })
    vM_17:AddDropdown("PlaceTroops", {
        Text = "Troops",
        Values = vM_1,
        Multi = true,
        AllowNull = true,
        Default = {},
        Expandable = true,
        ExpandColumns = 2
    })
    vM_17:AddButton({ Text = "Place Now", Func = nH })
    vM_15 = n6.Units:AddLeftGroupbox("Auto Replace", "replace")
else
    vM_13:AddToggle("AutoPlace", { Text = "Auto Place Units", Default = false })
    vM_13:AddSlider("PlaceDelay", { Suffix = "s", Min = 0.1, Max = 10, Default = 0.35, Rounding = 2, Text = "Place delay" })
    vM_13:AddSlider("PlaceSpacing", { Default = 3, Text = "Spacing", Max = 10, Rounding = 0, Min = 1 })
    vM_13:AddSlider("PlaceMaxPathDistance", { Text = "Max path distance", Min = 0, Default = 6, Rounding = 0, Max = 30 })
    vM_13:AddDropdown("PlaceRarities", { Text = "Rarities", Multi = true, AllowNull = true, Default = {}, Values = vM_15 })
    vM_13:AddDropdown("PlaceTroops", {
        Multi = true,
        Default = {},
        AllowNull = true,
        ExpandColumns = 2,
        Values = n6,
        Expandable = true,
        Text = "Troops"
    })
    vM_13:AddButton({ Text = "Place Now", Func = vM_17 })
    vM_1 = nH.Units:AddLeftGroupbox("Auto Replace", "replace")
end
vM_15:AddToggle("AutoReplace", { Text = "Auto Replace Units", Default = false })
vM_15:AddSlider("ReplaceDelay", { Text = "Replace delay", Default = 0.5, Min = 0.1, Max = 10, Rounding = 2, Suffix = "s" })
vM_15:AddDropdown("ReplaceFromRarities", { Text = "Replace from rarities", Values = vM_13, Multi = true, AllowNull = true, Default = {} })
vM_15:AddDropdown("ReplaceFromTroops", {
    Text = "Replace from troops",
    Values = vM_1,
    Multi = true,
    AllowNull = true,
    Default = {},
    Expandable = true,
    ExpandColumns = 2
})
vM_15:AddDropdown("ReplaceWithRarities", { Text = "Replace with rarities", Values = vM_13, Multi = true, AllowNull = true, Default = {} })
vM_15:AddDropdown("ReplaceWithTroops", {
    Text = "Replace with troops",
    Values = vM_1,
    Multi = true,
    AllowNull = true,
    Default = {},
    Expandable = true,
    ExpandColumns = 2
})
vM_15:AddButton({ Text = "Replace Now", Func = onReplaceNow })
vM_4 = n6.Units:AddRightGroupbox("Auto Upgrade", "arrow-up")
vM_4:AddToggle("AutoUpgrade", { Text = "Auto Upgrade Units", Default = false })
vM_4:AddToggle("UpgradeUseMax", { Text = "Upgrade max affordable", Default = true })
vM_4:AddSlider("UpgradeDelay", { Text = "Upgrade delay", Default = 0.35, Min = 0.1, Max = 30, Rounding = 2, Suffix = "s" })
vM_4:AddSlider("UpgradeMaxPrice", { Text = "Max price", Default = 0, Min = 0, Max = 1000000000000, Rounding = 0, Suffix = "$" })
vM_4:AddSlider("UpgradeMoneyBuffer", { Text = "Keep money", Default = 0, Min = 0, Max = 1000000000000, Rounding = 0, Suffix = "$" })
vM_4:AddDropdown("UpgradeRarities", { Text = "Rarities", Values = vM_13, Multi = true, AllowNull = true, Default = {} })
vM_4:AddDropdown("UpgradeTroops", {
    Text = "Troops",
    Values = vM_1,
    Multi = true,
    AllowNull = true,
    Default = {},
    Expandable = true,
    ExpandColumns = 2
})
vM_4:AddButton({ Text = "Upgrade Now", Func = onUpgradeNow })
local Collect_EquipGroup = n6.Units:AddLeftGroupbox("Collect / Equip", "hand-coins")
Collect_EquipGroup:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
Collect_EquipGroup:AddSlider("CollectDelay", { Text = "Collect delay", Default = 2, Min = 0.5, Max = 60, Rounding = 1, Suffix = "s" })
Collect_EquipGroup:AddButton({ Text = "Collect Now", Func = onCollectNow })
Collect_EquipGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
Collect_EquipGroup:AddSlider("EquipBestDelay", { Text = "Equip best delay", Default = 5, Min = 1, Max = 120, Rounding = 1, Suffix = "s" })
Collect_EquipGroup:AddButton({ Text = "Equip Best Now", Func = ny })
local SellSelectedGroup = n6.Units:AddRightGroupbox("Sell Selected", "badge-dollar-sign")
SellSelectedGroup:AddToggle("AutoSellSelectedBrainrots", { Text = "Auto Sell Selected", Default = false })
SellSelectedGroup:AddSlider("SellSelectedDelay", { Text = "Sell delay", Default = 3, Min = 0.5, Max = 120, Rounding = 1, Suffix = "s" })
SellSelectedGroup:AddDropdown("SellBrainrotRarities", { Text = "Rarities", Values = vM_13, Multi = true, AllowNull = true, Default = {} })
SellSelectedGroup:AddDropdown("SellBrainrotTypes", {
    Text = "Brainrots",
    Values = vM_12,
    Multi = true,
    AllowNull = true,
    Default = {},
    Expandable = true,
    ExpandColumns = 2
})
SellSelectedGroup:AddButton({ Text = "Sell Selected Now", Func = onSellSelectedNow })
local SellAllGroup = n6.Units:AddRightGroupbox("Sell All", "trash-2")
SellAllGroup:AddToggle("AutoSellAllBrainrots", { Text = "Auto Sell All", Default = false })
SellAllGroup:AddSlider("SellAllDelay", { Text = "Sell delay", Default = 5, Min = 0.5, Max = 120, Rounding = 1, Suffix = "s" })
SellAllGroup:AddButton({ Text = "Sell All Now", Func = nv })
local CombatGroup = n6.Units:AddRightGroupbox("Combat", "crosshair")
CombatGroup:AddToggle("KillAura", { Text = "Kill Aura", Default = false })
CombatGroup:AddSlider("KillAuraRange", { Text = "Range", Default = 0, Min = 0, Max = 100, Rounding = 0 })
CombatGroup:AddSlider("KillAuraDelay", { Text = "Delay", Default = 0, Min = 0, Max = 2, Rounding = 2, Suffix = "s" })
local SkillTreeGroup = n6.Skills:AddLeftGroupbox("Skill Tree", "network")
SkillTreeGroup:AddToggle("AutoBuySkills", { Text = "Auto Buy Affordable Skills", Default = false })
SkillTreeGroup:AddSlider("SkillDelay", { Text = "Skill delay", Default = 0.35, Min = 0.1, Max = 30, Rounding = 2, Suffix = "s" })
SkillTreeGroup:AddSlider("SkillMaxPrice", { Text = "Max price", Default = 0, Min = 0, Max = 1000000000000, Rounding = 0, Suffix = "$" })
SkillTreeGroup:AddSlider("SkillMoneyBuffer", { Text = "Keep money", Default = 0, Min = 0, Max = 1000000000000, Rounding = 0, Suffix = "$" })
SkillTreeGroup:AddButton({ Text = "Buy Skills Now", Func = onBuySkillsNow })
local RebirthGroup = n6.Skills:AddRightGroupbox("Rebirth", "refresh-cw")
RebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
RebirthGroup:AddSlider("RebirthDelay", { Text = "Rebirth delay", Default = 2, Min = 0.5, Max = 60, Rounding = 1, Suffix = "s" })
RebirthGroup:AddSlider("RebirthMoneyBuffer", { Text = "Keep money", Default = 0, Min = 0, Max = 1000000000000, Rounding = 0, Suffix = "$" })
RebirthGroup:AddButton({ Text = "Rebirth Now", Func = mJ })
local MenuGroup = n6.Settings:AddLeftGroupbox("Menu", "menu")
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton({ Text = "Unload", Func = onUnload })
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(n6.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/roll-your-army")
SaveManager:BuildConfigSection(n6.Settings)
SaveManager:LoadAutoloadConfig()
np = tick()
nj = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local vh = v
        pcall(function()
            vh:Disable()
        end)
    end
end)
m4 = fn628
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(fns.onInputChanged)
if Collect_EquipGroup and SkillTreeGroup and (SkillTreeGroup and not connection2) or (not connection2 and Collect_EquipGroup or connection2 and connection2) or not (Collect_EquipGroup and SkillTreeGroup and (SkillTreeGroup and not connection2) or (not connection2 and Collect_EquipGroup or connection2 and connection2)) then
    Library:OnUnload(fn632)
    task.spawn(worker14)
    task.spawn(worker13)
    task.spawn(worker12)
    task.spawn(fns.worker11)
    task.spawn(worker10)
    task.spawn(worker9)
    task.spawn(worker8)
    task.spawn(worker7)
    task.spawn(worker6)
    task.spawn(worker5)
    task.spawn(worker4)
    task.spawn(worker3)
    task.spawn(worker2)
else
    Library:OnUnload(fn632)
    task.spawn(worker14)
    task.spawn(worker13)
    task.spawn(worker12)
    task.spawn(fns.worker11)
    task.spawn(worker10)
    task.spawn(worker9)
    task.spawn(worker8)
    task.spawn(worker7)
    task.spawn(worker6)
    task.spawn(worker5)
    task.spawn(worker4)
    task.spawn(worker3)
    task.spawn(worker2)
end
end)(...)

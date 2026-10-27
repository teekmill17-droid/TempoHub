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
getgenv().TempoHoodSubtitle = "DRILL FOR ANIME"
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
local ReplaceGroup, xf_9, xf_21, SaveManager, xf_25, xf_28, xf_33, xf_37
local oA
local of
local Label
local nX
local oG
local connection
local ol
local o4
local n2
local nK
local ot
local pa
local n8
local oS
local nQ
local oz
local nx
local oe
local oY
local Options
local oF
local ok
local o3
local RequestSpeedBuyMax
local nJ
local oq
local o9
local n7
local oR
local oy
local nw
local od
local VirtualUser
local RequestPowerBuyMax
local nC
local oj
local o2
local n0
local nI
local op
local o8
local oQ
local nO
local ox
local nv
local oc
local oW
local nU
local oD
local nB
local oi
local connection2
local Toggles
local oJ
local nH
local oo
local oP
local nN
local ow
local RequestRebirth
local ob
local RequestCarryUpgrade
local nT
local oC
local nA
local oh
local nG
local on
local o6
local n4
local RequestPowerUpgrade
local nM
local ov
local oa
local oU
local nS
local oB
local DrillConfigurations
local RequestJumpUpgrade
local nY
local RequestCarryBuyMax
local nF
local om
local RequestSpeedUpgrade
local n3
local oN
local ou
local RebirthConfigurations
local Workspace
local nR
function fns.fn9()
    local Character = oN.Character
    local qY = Character and Character:FindFirstChild("HumanoidRootPart")
    return qY
end
function fns.fn39(bP, bQ, bR)
    local rd = ok.GetItemData(bP)
    if not rd then
        return 0
    end
    local GetIncomeAtLevel = ok.GetIncomeAtLevel
    local rf = rd.Income or 0
    local rd_1 = bQ or 1
    return GetIncomeAtLevel(rf, rd_1, nH(bR))
end
function fns.fn45(bc, bd)
    local qL = oR(bc)
    local qP = if not ox(qL) then 1 else 0
    if qP == 1 then
        return true
    end
    return qL[bd] == true
end
function fns.fn61()
    local tc = nx()
    if not tc then
        return false
    end
    return n4(tc)
end
function fns.fn64(aZ, a_)
    local qy = Options[aZ]
    if qy == nil then
        return a_
    end
    return qy.Value
end
function fns.fn77()
    if oF() then
        pcall(function()
            RequestRebirth:FireServer()
        end)
    end
end
function fns.fn79(b6)
    local rv = {}
    if not b6 then
        return rv
    end
    for i, child in ipairs(b6:GetChildren()) do
        if child.Name:match("^Floor%d+$") then
            local Slots = child:FindFirstChild("Slots")
            if Slots then
                for i, child in ipairs(Slots:GetChildren()) do
                    local rw_1 = child:IsA("Model") and child:GetAttribute("IsUnlocked")
                    if rw_1 then
                        table.insert(rv, child)
                    end
                end
            end
        end
    end
    return rv
end
function fns.fn82(bE)
    local q2 = oB()
    if not q2 then
        return false
    end
    q2.CFrame = CFrame.new(bE + Vector3.new(0, 3, 0))
    return true
end
function fns.fn83(c3)
    local attr = c3:GetAttribute("PlacedItem")
    if not attr then
        return 0
    end
    local sv = c3:GetAttribute("ItemLevel") or 1
    local sw = c3:GetAttribute("PlacedMutation") or "Normal"
    return o3(attr, sv, sw)
end
function fns.fn91()
    local ts = if not nI() then 1 else 0
    if ts == 1 then
        nC = 0
        nG = 0
        return false
    end
    if nC == 0 then
        nC = tick()
    end
    local to = tick()
    if to < nG then
        return true
    end
    local ts_1 = if n0() then 1 else 0
    if ts_1 == 1 then
        oj()
        task.wait(0.15)
    end
    oC()
    nG = tick() + math.max(nX("BaseReturnDelay", 1.25), 0.5)
    return true
end
function fns.fn96(T, U)
    local qh = tonumber(string.match(T, "%d+")) or 0
    local qi = (tonumber(string.match(U, "%d+")))
    local qm = if qi then 1 else 0
    local qk = 14 * qm + 2610 * (1 - qm)
    local ql = 874 * qm + 218 * (1 - qm)
    if not ((qk * 4076 + ql * 3964 + qk * ql) % 16777213 == 3533836) then
        qi = 0
    end
    return qh < qi
end
function fns.fn131(cf)
    return "Drill_" .. string.gsub(cf, " ", "_")
end
function fns.fn137(Z, aa)
    return Z.Order < aa.Order
end
function fns.onInputChanged(jE)
    local UserInputType = jE.UserInputType
    local wS = UserInputType == Enum.UserInputType.MouseMovement
    local wW = if wS then 1 else 0
    local wU = 3967 * wW + 3121 * (1 - wW)
    local wV = 3156 * wW + 441 * (1 - wW)
    if not ((wU * 1454 + wV * 2378 + wU * wV) % 16777213 == 9015625) then
        wS = UserInputType == Enum.UserInputType.Gamepad1
    end
    if wS then
        ou = tick()
    end
end
function fns.fn141()
    local rL = oN:GetAttribute("EquippedDrill") or "Default"
    return rL
end
function fns.fn154(aF, aG, aH)
    return string.format("<b>%s</b> %s %s", aF, o6("-", "#5a6070"), o6(aG, aH))
end
function fns.fn184(av, aw)
    if setclipboard then
        setclipboard(av)
    elseif toclipboard then
        toclipboard(av)
    end
    oa:Notify(aw)
end
function fns.fn196(f2)
    local uL = oi()
    if not uL or not f2 then
        return false
    elseif f2.Parent == oN.Character then
        return true
    else
        uL:EquipTool(f2)
        return true
    end
end
function fns.fn203()
    local Character = oN.Character
    if not Character then
        return 0
    end
    local rY = 0
    for i, child in ipairs(Character:GetChildren()) do
        if child.Name == "CarriedLoot" then
            rY = rY + 1
        end
    end
    return rY
end
function fns.onCopyJoinScript_JobID()
    local i_ = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, oU)
    nR(i_, "Copied join script to clipboard")
end
function fns.fn257()
    local sN = oe()
    if #sN == 0 then
        return nil
    end
    local sO = nw("DigMode", "Highest")
    if sO == "Specific" then
        local sP_1 = nw("DigZone", "DrillZone1")
        for i, v in ipairs(sN) do
            if v.Name == sP_1 then
                return v
            end
        end
        return nil
    elseif sO == "Best For Drill" then
        local sO_1 = oh()
        local sP_2 = -1
        local sQ
        for i, v in ipairs(sN) do
            local sR_1 = oA[v.Name] or 0
            local sR_2 = sR_1 / math.max(sO_1, 1)
            local sT = sR_2 <= nX("DigMaxSeconds", 120) and sR_1 > sP_2
            if sT then
                sQ = v
                sP_2 = sR_1
            end
        end
        return sQ or sN[1]
    else
        return sN[1]
    end
end
function fns.fn290(a3)
    local qA = Options[a3]
    return qA and qA.Value or {}
end
function fns.fn296(iJ)
    local DiscordGroup = iJ:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = nA })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = nA })
end
function fns.fn319()
    connection:Disconnect()
    connection2:Disconnect()
end
function fns.fn341()
    local q7 = oN:GetAttribute("Cash") or 0
    return q7
end
function fns.fn350()
    local rU = oN:GetAttribute("CarryLevel") or 1
    local rU_1 = ob.Carry[rU]
    return rU_1 and rU_1.Capacity or 1
end
function fns.fn358()
    select("#", "Unloaded!")
end
function fns.fn367(cP, cQ, cR, cS)
    local attr = cP:GetAttribute("OriginalName")
    local sh = (cP:GetAttribute("Mutation"))
    local sm = if sh then 1 else 0
    local sk = 2455 * sm + 1177 * (1 - sm)
    local sl = 572 * sm + 2449 * (1 - sm)
    if not ((sk * 2391 + sl * 1947 + sk * sl) % 16777213 == 8387849) then
        sh = "Normal"
    end
    local si = sh
    local sh_1 = oz(attr)
    if not pa(cR, sh_1) then
        return false
    end
    local sm_1 = if not of(cQ, sh_1) then 1 else 0
    if sm_1 == 1 then
        return false
    elseif not nT(cS, si) then
        return false
    else
        return true
    end
end
function fns.worker7()
    while not oa.Unloaded do
        if od("AutoRebirth") then
            pcall(n7)
        end
        if od("AutoBuyDrills") then
            pcall(nS)
        end
        if od("AutoEquipBestDrill") then
            pcall(n8)
        end
        if od("AutoBuyUpgrades") then
            pcall(oG)
        end
        task.wait(nX("ShopDelay", 0.5))
    end
end
function fns.onRscripts()
    nR(oy, "Copied Rscripts profile to clipboard")
end
function fns.onInputBegan()
    ou = tick()
end
function fns.worker2()
    while not oa.Unloaded do
        task.wait(2)
        if od("AntiAfk") then
            local w_ = tick() - ou
            local w0 = tick() - on
            if w_ >= 300 and w0 >= 60 then
                pcall(n2)
            else
                if w_ < 300 and w0 >= 300 then
                    pcall(n2)
                end
            end
        end
    end
end
function fns.fn423()
    local SpawnedItems = Workspace:FindFirstChild("SpawnedItems")
    if not SpawnedItems then
        return nil
    end
    local tO = oB()
    local tP
    local tQ
    local tR = nX("FightMaxDistance", 0)
    for i, child in ipairs(SpawnedItems:GetChildren()) do
        local tN_1 = child:IsA("Model") and ol(child)
        if tN_1 then
            local tN_2 = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)
            if tN_2 then
                local tS_1 = tO and (tN_2.Position - tO.Position).Magnitude or 0
                if tR <= 0 or tS_1 <= tR then
                    local tS_3 = child:GetAttribute("ItemName") or child.Name
                    local tT = child:GetAttribute("Mutation") or "Normal"
                    local tU = o3(tS_3, 1, tT)
                    local tS_4 = nw("FightPriority", "Best Income")
                    local tT_1 = tU
                    if tS_4 == "Nearest" and tO then
                        tT_1 = -tS_1
                    elseif tS_4 == "Weakest" then
                        tT_1 = -tU
                    end
                    if tP == nil or tT_1 > tP then
                        tQ = child
                        tP = tT_1
                    end
                end
            end
        end
    end
    return tQ
end
function fns.fn444(c0)
    local attr = c0:GetAttribute("OriginalName")
    local so = c0:GetAttribute("ItemLevel") or 1
    local sp = (c0:GetAttribute("Mutation"))
    local st = if sp then 1 else 0
    local sr = 1572 * st + 2947 * (1 - st)
    local ss = 3348 * st + 3004 * (1 - st)
    if not ((sr * 3758 + ss * 159 + sr * ss) % 16777213 == 11702964) then
        sp = "Normal"
    end
    return o3(attr, so, sp)
end
function fns.fn446()
    if nI() then
        o4()
        return
    end
    local uy = oe()
    if #uy == 0 then
        local uy_1 = ow()
        if uy_1 then
            n4(uy_1.Position)
        end
        return
    end
    local uy_2 = nB()
    if not uy_2 then
        return
    end
    local uz = oB()
    if not uz then
        return
    end
    if (uz.Position - uy_2.Position).Magnitude > 8 then
        n4(uy_2.Position)
    end
end
function fns.worker()
    local wG_1
    while true do
        task.wait(1)
        if oa.Unloaded then
            break
        end
        local wF = math.floor(os.clock() - ov)
        if wF < 60 then
            wG_1 = wF .. "s"
        elseif wF < 3600 then
            wG_1 = string.format("%dm %ds", math.floor((wF) / (60)), wF % 60)
        else
            wG_1 = string.format("%dh %dm", math.floor((wF) / (3600)), math.floor((wF % 3600) / (60)))
        end
        Label:SetText(oQ("Session time", wG_1, oo))
    end
end
function fns.fn454()
    nR(oD, "Copied Discord invite to clipboard")
end
function fns.fn476(bK)
    local rb = ok.Mutations[bK or "Normal"]
    return rb and rb.Multiplier or 1
end
function fns.fn487()
    local wr = nO()
    local ws = od("BuyUpgradeMax")
    if o2("Power") then
        local wt_1 = oN:GetAttribute("PowerLevel") or 1
        local wt_2 = ob.Power[wt_1 + 1]
        if wt_2 then
            if ws then
                pcall(function()
                    RequestPowerBuyMax:FireServer()
                end)
            else
                if wr >= (wt_2.MoneyCost or 0) then
                    pcall(function()
                        RequestPowerUpgrade:FireServer()
                    end)
                end
            end
        end
    end
    if o2("Speed") then
        local wt_3 = oN:GetAttribute("SpeedLevel") or 1
        local wt_4 = ob.Speed[wt_3 + 1]
        if wt_4 then
            if ws then
                pcall(function()
                    RequestSpeedBuyMax:FireServer()
                end)
            else
                if wr >= (wt_4.MoneyCost or 0) then
                    pcall(function()
                        RequestSpeedUpgrade:FireServer()
                    end)
                end
            end
        end
    end
    if o2("Jump") then
        local wt_5 = oN:GetAttribute("JumpLevel") or 1
        local wt_6 = ob.Jump[wt_5 + 1]
        local wu_6 = wt_6
        if wu_6 then
            local wv = wt_6.MoneyCost
            local wz = if wv then 1 else 0
            local wx = 1482 * wz + 3608 * (1 - wz)
            local wy = 3663 * wz + 2473 * (1 - wz)
            if not ((wx * 931 + wy * 759 + wx * wy) % 16777213 == 9588525) then
                wv = 0
            end
            wu_6 = wr >= wv
        end
        if wu_6 then
            pcall(function()
                RequestJumpUpgrade:FireServer()
            end)
        end
    end
    if o2("Carry") then
        local wt_7 = oN:GetAttribute("CarryLevel") or 1
        local wt_8 = ob.Carry[wt_7 + 1]
        if wt_8 then
            if ws then
                pcall(function()
                    RequestCarryBuyMax:FireServer()
                end)
            else
                if wr >= (wt_8.MoneyCost or 0) then
                    pcall(function()
                        RequestCarryUpgrade:FireServer()
                    end)
                end
            end
        end
    end
end
local function fn501(ah, ai)
    local qn = oq[ah.Rarity] or 0
    local qn_1 = oq[ai.Rarity] or 0
    if qn ~= qn_1 then
        return qn < qn_1
    elseif ah.Income ~= ai.Income then
        return ah.Income < ai.Income
    else
        return ah.Name < ai.Name
    end
end
local function worker3()
    while not oa.Unloaded do
        if nI() then
            pcall(o4)
            local w3 = nC > 0 and tick() - nC >= 10
            if w3 then
                pcall(oS)
                nC = tick()
            end
        end
        task.wait(0.25)
    end
end
local function onOnClientEvent(en)
    if en == "start" then
        nY = true
        nJ = tick()
        nN = o9()
    end
end
local function fn536()
    local Character = oN.Character
    local q0 = Character and Character:FindFirstChildOfClass("Humanoid")
    return q0
end
local function fn585()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    on = tick()
end
local function worker6()
    while not oa.Unloaded do
        if od("AutoCollect") then
            pcall(om)
        end
        if od("AutoPlace") then
            pcall(oS)
        end
        if od("AutoReplace") then
            pcall(oY)
        end
        if od("AutoUpgradeItems") then
            pcall(nv)
        end
        task.wait(nX("PlaceDelay", 0.35))
    end
end
local function fn603()
    local te = ow()
    local tf = not te or not te:IsA("BasePart")
    if tf then
        return false
    end
    return n4((te.CFrame * CFrame.new(te.Size.X / 2 + 35, 0, 0)).Position)
end
local function fn635()
    local Plots = Workspace:FindFirstChild("Plots")
    if not Plots then
        return nil
    end
    for i, child in ipairs(Plots:GetChildren()) do
        local rn_1 = child:IsA("Model") and child:GetAttribute("Owner") == oN.UserId
        if rn_1 then
            return child
        end
    end
    return nil
end
local function worker4()
    while not oa.Unloaded do
        if od("AutoDig") then
            pcall(n3)
        end
        task.wait(nX("DigDelay", 0.35))
    end
end
local function worker5()
    while not oa.Unloaded do
        if od("AutoFight") then
            pcall(oW)
        else
            local w6 = nY and od("AutoCombatMulti")
            if w6 then
                pcall(o8)
            end
        end
        task.wait(nX("FightDelay", 0.4))
    end
end
local function fn682()
    if not od("AutoReturnBase") then
        return false
    end
    local tm = o9()
    if tm <= 0 then
        return false
    end
    return tm >= nQ()
end
local function fn685()
    local wB_1
    local wA_1
    if identifyexecutor then
        wB_1, wA_1 = identifyexecutor()
        local wC = wB_1 ~= ""
        local wD = type(wB_1) == "string" and wC
        if wD then
            local wC_1 = type(wA_1) == "string" and wA_1 ~= "" and wB_1 .. " " .. wA_1
            nK = wC_1 or wB_1
        end
    end
end
local function fn724(aC, aD)
    return string.format('<font color="%s">%s</font>', aD, aC)
end
local function fn729(bo, bp)
    local qT = nw(bo, "Common")
    return (oq[bp] or 0) >= (oq[qT] or 1)
end
local function fn731()
    nY = false
    nU = nil
    nJ = 0
end
local function fn734(h5)
    local wp = oR("BuyUpgrades")
    if ox(wp) then
        return wp[h5] == true
    end
    return true
end
local function fn740(bW)
    local rk = ok.GetItemData(bW)
    return rk and rk.Rarity or "Common"
end
local function fn746(cn)
    local Drills = DrillConfigurations.Drills
    local rO = cn
    local rT = if rO then 1 else 0
    local rR = 1045 * rT + 291 * (1 - rT)
    local rS = 3628 * rT + 1471 * (1 - rT)
    if not ((rR * 504 + rS * 1090 + rR * rS) % 16777213 == 8272460) then
        rO = ot()
    end
    local rP = Drills[rO]
    return rP and rP.Damage or 1
end
local function fn758()
    local th = oB()
    local ti = nx()
    if not th or not ti then
        return false
    end
    return (th.Position - ti).Magnitude <= 28
end
local function fn815(ch)
    if ch == "Default" then
        return true
    end
    return oN:GetAttribute(oP(ch)) == true
end
local function fn848()
    local s9 = ow()
    local ta = s9 and s9:IsA("BasePart")
    if ta then
        return s9.Position
    end
    local Map = Workspace:FindFirstChild("Map")
    local ta_1 = Map and Map:FindFirstChild("TutorialBack")
    local s9_2 = ta_1
    if ta_1 then
        ta_1 = s9_2:IsA("BasePart")
    end
    if ta_1 then
        return s9_2.Position
    end
    return nil
end
local function fn853(a8)
    for k, v in pairs(a8) do
        if v then
            return true
        end
    end
    return false
end
local function fn857()
    local Map = Workspace:FindFirstChild("Map")
    local sz = Map and Map:FindFirstChild("Claim")
    return sz
end
local function fn872(fg)
    for i, v in ipairs(oJ()) do
        if v:GetAttribute("OriginalName") == fg then
            return true
        end
    end
    local t5 = oc()
    if not t5 then
        return false
    end
    for i, v in ipairs(nM(t5)) do
        if v:GetAttribute("PlacedItem") == fg then
            return true
        end
    end
    return false
end
local function fn875(aT, aU)
    local qv = Options[aT]
    local qw = qv and tonumber(qv.Value)
    return qw or aU
end
local function fn880()
    local DrillZones = Workspace:FindFirstChild("DrillZones")
    local sF = {}
    if not DrillZones then
        return sF
    end
    for i, child in ipairs(DrillZones:GetChildren()) do
        local sE_1 = child:IsA("BasePart") and oA[child.Name]
        if sE_1 then
            table.insert(sF, child)
        end
    end
    table.sort(sF, function(di, dj)
        local sB = tonumber(string.match(di.Name, "%d+")) or 0
        local sC = tonumber(string.match(dj.Name, "%d+")) or 0
        return sB > sC
    end)
    return sF
end
local function fn886()
    local um = (oN:GetAttribute("RebirthLevel"))
    local ur = if um then 1 else 0
    local up = 2225 * ur + 4026 * (1 - ur)
    local uq = 3513 * ur + 584 * (1 - ur)
    if not ((up * 139 + uq * 2808 + up * uq) % 16777213 == 1212991) then
        um = 0
    end
    local um_1 = RebirthConfigurations.Rebirths[um + 1]
    if not um_1 then
        return false
    end
    for i, v in ipairs(um_1.Requirements) do
        if v.Type == "Cash" then
            local um_2 = nO()
            if um_2 < (v.Amount or 0) then
                return false
            end
        elseif v.Type == "Item" then
            if not nF(v.Name) then
                return false
            end
        elseif v.Type == "Power" then
            local um_3 = (oN:GetAttribute("PowerLevel"))
            local ur_1 = if um_3 then 1 else 0
            local up_1 = 3494 * ur_1 + 441 * (1 - ur_1)
            local uq_1 = 1475 * ur_1 + 2088 * (1 - ur_1)
            if not ((up_1 * 2701 + uq_1 * 815 + up_1 * uq_1) % 16777213 == 15793069) then
                um_3 = 1
            end
            if um_3 < (v.PowerLevel or 0) then
                return false
            end
        end
    end
    return true
end
local function onOnClientEvent2()
    op()
    if nI() then
        nC = tick()
        nG = tick() + math.max(nX("BaseReturnDelay", 1.25), 0.5)
        oC()
    end
end
local function onUnload()
    oa:Unload()
end
local function fn916(bi, bj)
    local qQ = oR(bi)
    if not ox(qQ) then
        return true
    end
    return qQ[bj or "Normal"] == true
end
local function fn920(eK)
    local tF = eK:GetAttribute("ItemName") or eK.Name
    local tF_1 = eK:GetAttribute("Rarity") or oz(tF)
    local tF_2 = (eK:GetAttribute("Mutation"))
    local tM = if tF_2 then 1 else 0
    local tK = 3583 * tM + 4008 * (1 - tM)
    local tL = 602 * tM + 603 * (1 - tM)
    if not ((tK * 73 + tL * 3328 + tK * tL) % 16777213 == 4421981) then
        tF_2 = "Normal"
    end
    local tI = tF_2
    if not of("FightCharacters", tF) then
        return false
    elseif not pa("FightMinRarity", tF_1) then
        return false
    elseif not of("FightRarities", tF_1) then
        return false
    elseif not nT("FightMutations", tI) then
        return false
    else
        return true
    end
end
local function fn924(aO)
    local qs = Toggles[aO]
    return qs ~= nil and qs.Value == true
end
RequestRebirth = nil
nv = nil
nw = nil
nx = nil
nA = nil
nB = nil
nC = nil
connection = nil
nF = nil
nG = nil
nH = nil
nI = nil
nJ = nil
nK = nil
nM = nil
nN = nil
nO = nil
nQ = nil
nR = nil
nS = nil
nT = nil
nU = nil
Options = nil
nX = nil
nY = nil
Toggles = nil
n0 = nil
n2 = nil
n3 = nil
n4 = nil
n7 = nil
n8 = nil
RebirthConfigurations = nil
oa = nil
ob = nil
oc = nil
od = nil
oe = nil
of = nil
DrillConfigurations = nil
local ny, CombatMultiplier, nD, StartCombat, CollectCash, EquipDrill, PurchaseDrill, PickupFromSlot, PlaceItem, n6
oh = nil
oi = nil
oj = nil
ok = nil
ol = nil
om = nil
on = nil
oo = nil
op = nil
oq = nil
ot = nil
ou = nil
ov = nil
ow = nil
ox = nil
oy = nil
oz = nil
oA = nil
oB = nil
oC = nil
oD = nil
RequestPowerBuyMax = nil
oF = nil
oG = nil
RequestCarryBuyMax = nil
oJ = nil
RequestSpeedBuyMax = nil
oN = nil
RequestPowerUpgrade = nil
oP = nil
oQ = nil
oR = nil
oS = nil
Workspace = nil
oU = nil
RequestCarryUpgrade = nil
oW = nil
VirtualUser = nil
oY = nil
Label = nil
RequestJumpUpgrade = nil
connection2 = nil
o2 = nil
o3 = nil
o4 = nil
RequestSpeedUpgrade = nil
local oI, PlayerGui, oM, o0
o6 = nil
o8 = nil
o9 = nil
pa = nil
local RequestItemUpgrade
RequestItemUpgrade = nil
VirtualUser, Workspace, oN, PlayerGui, oD, oy, ok, DrillConfigurations, ob, RebirthConfigurations, PlaceItem, PickupFromSlot, PurchaseDrill, EquipDrill, CollectCash, StartCombat, CombatMultiplier, RequestRebirth, RequestItemUpgrade, RequestSpeedUpgrade, RequestJumpUpgrade, RequestCarryUpgrade, RequestPowerUpgrade, RequestSpeedBuyMax, RequestCarryBuyMax, RequestPowerBuyMax, oA, xf_33, oq = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local xf_41 = game:GetService("Players")
local xf_30 = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
Workspace = game:GetService("Workspace")
oN = xf_41.LocalPlayer
PlayerGui = oN:WaitForChild("PlayerGui")
local xf_18 = "Drill for Anime"
oD = "https://discord.gg/K7Qxnxkk46"
oy = "https://discord.gg/K7Qxnxkk46"
local xf_44 = xf_30:WaitForChild("Modules")
local xf_13 = xf_30:WaitForChild("Events")
if (not RequestPowerUpgrade or xf_33) and ((not PurchaseDrill) and (RequestPowerUpgrade or RequestPowerUpgrade)) and not ((not RequestPowerUpgrade or xf_33) and ((not PurchaseDrill) and (RequestPowerUpgrade or RequestPowerUpgrade))) then
    xf_44 = require(DrillConfigurations:WaitForChild("ItemConfigurations"))
    ob = require(DrillConfigurations:WaitForChild("DrillConfigurations"))
    ok = require(DrillConfigurations:WaitForChild("UpgradeConfigurations"))
else
    ok = require(xf_44:WaitForChild("ItemConfigurations"))
    DrillConfigurations = require(xf_44:WaitForChild("DrillConfigurations"))
    ob = require(xf_44:WaitForChild("UpgradeConfigurations"))
end
RebirthConfigurations = require(xf_44:WaitForChild("RebirthConfigurations"))
PlaceItem = xf_30:WaitForChild("PlaceItem")
PickupFromSlot = xf_30:WaitForChild("PickupFromSlot")
PurchaseDrill = xf_30:WaitForChild("PurchaseDrill")
EquipDrill = xf_30:WaitForChild("EquipDrill")
CollectCash = xf_30:WaitForChild("CollectCash")
StartCombat = xf_13:WaitForChild("StartCombat")
local xf_2 = xf_13:WaitForChild("CombatUpdate")
local xf_15 = xf_13:WaitForChild("CombatEnded")
CombatMultiplier = xf_13:WaitForChild("CombatMultiplier")
RequestRebirth = xf_13:WaitForChild("RequestRebirth")
RequestItemUpgrade = xf_13:WaitForChild("RequestItemUpgrade")
RequestSpeedUpgrade = xf_13:WaitForChild("RequestSpeedUpgrade")
RequestJumpUpgrade = xf_13:WaitForChild("RequestJumpUpgrade")
RequestCarryUpgrade = xf_13:WaitForChild("RequestCarryUpgrade")
RequestPowerUpgrade = xf_13:WaitForChild("RequestPowerUpgrade")
RequestSpeedBuyMax = xf_13:WaitForChild("RequestSpeedBuyMax")
RequestCarryBuyMax = xf_13:WaitForChild("RequestCarryBuyMax")
RequestPowerBuyMax = xf_13:WaitForChild("RequestPowerBuyMax")
oA = {
    DrillZone1 = 20,
    DrillZone2 = 75,
    DrillZone3 = 350,
    DrillZone4 = 500,
    DrillZone5 = 750,
    DrillZone6 = 1250,
    DrillZone7 = 2000,
    DrillZone8 = 3500,
    DrillZone9 = 8000,
    DrillZone10 = 20000,
    DrillZone11 = 35000,
    DrillZone12 = 50000,
    DrillZone13 = 65000,
    DrillZone14 = 100000,
    DrillZone15 = 150000,
    DrillZone16 = 250000,
    DrillZone17 = 375000,
    DrillZone18 = 500000,
    DrillZone19 = 650000,
    DrillZone20 = 800000,
    DrillZone21 = 1000000,
    DrillZone22 = 1250000,
    DrillZone23 = 1500000,
    DrillZone24 = 1750000,
    DrillZone25 = 2000000,
    DrillZone26 = 2500000,
    DrillZone27 = 3000000,
    DrillZone28 = 3750000,
    DrillZone29 = 4500000,
    DrillZone30 = 5500000,
    DrillZone31 = 6500000,
    DrillZone32 = 8000000,
    DrillZone33 = 10000000
}
if not RequestPowerUpgrade and xf_13 and (not DrillConfigurations or not xf_13) and (not RequestCarryBuyMax and DrillConfigurations and "https://discord.gg/K7Qxnxkk46") and ((not RequestCarryBuyMax or not RequestPowerUpgrade or xf_13 and not RequestPowerUpgrade) and (RequestCarryBuyMax and xf_13 and (not RequestCarryBuyMax or not xf_13))) or xf_33 and not DrillConfigurations and (xf_33 or oy) and (DrillConfigurations or not RequestCarryBuyMax or "https://discord.gg/K7Qxnxkk46") and (not xf_33 and not xf_33 and (RequestCarryBuyMax or oy) or (xf_13 or false or RequestPowerUpgrade and xf_33)) or not (not RequestPowerUpgrade and xf_13 and (not DrillConfigurations or not xf_13) and (not RequestCarryBuyMax and DrillConfigurations and "https://discord.gg/K7Qxnxkk46") and ((not RequestCarryBuyMax or not RequestPowerUpgrade or xf_13 and not RequestPowerUpgrade) and (RequestCarryBuyMax and xf_13 and (not RequestCarryBuyMax or not xf_13))) or xf_33 and not DrillConfigurations and (xf_33 or oy) and (DrillConfigurations or not RequestCarryBuyMax or "https://discord.gg/K7Qxnxkk46") and (not xf_33 and not xf_33 and (RequestCarryBuyMax or oy) or (xf_13 or false or RequestPowerUpgrade and xf_33))) then
    xf_33 = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Limited", "Secret", "Godly" }
else
    ok = { "Common", "Rare", "Legendary", "Mythical", "Epic", "Limited", "Secret", "Godly", "Uncommon" }
end
oq = {}
for i, v in ipairs(xf_33) do
    oq[v] = i
end
xf_44, xf_13, xf_28 = nil, nil, nil
if (not xf_28 and xf_13 or xf_28 and 15 or (xf_13 or not xf_13) and (not xf_44 and xf_13)) and ((xf_28 or not xf_13) and (xf_28 and false) or (xf_44 or xf_44) and false) and not ((not xf_28 and xf_13 or xf_28 and 15 or (xf_13 or not xf_13) and (not xf_44 and xf_13)) and ((xf_28 or not xf_13) and (xf_28 and false) or (xf_44 or xf_44) and false)) then
else
    xf_44 = { "Normal", "Golden", "Diamond", "Magma", "Void" }
end
xf_13 = { "Power", "Speed", "Jump", "Carry" }
xf_28 = {}
for k in pairs(oA) do
    table.insert(xf_28, k)
end
xf_30 = nil
xf_41 = 2
repeat
    local yb = bit32.rrotate(bit32.bxor(bit32.lrotate(xf_41, 17), string.byte(tostring(xf_30))), 25)
    if bit32.bxor(bit32.lrotate(bit32.bxor(yb, 864188082), 26), 3368946138) ~= bit32.lrotate(yb, 26) then
        table.sort(xf_30, fns.fn96)
        xf_28 = {}
    else
        table.sort(xf_28, fns.fn96)
        xf_30 = {}
    end
    xf_41 = (xf_41 + 0) % 4
until (xf_41 * 3 + 2) % 4 == 0
local xf_35 = {}
for k, v in pairs(DrillConfigurations.Drills) do
    xf_41 = table.insert
    xf_21 = v.LayoutOrder or 0
    xf_41(xf_35, { Name = k, Order = xf_21 })
end
local xf_7 = 3
repeat
    xf_41 = (vector.create((xf_7 * 1 + 6) % 11 + 1, (xf_7 * 1 + 7) % 13 + 1, (xf_7 * 11 + 7) % 17 + 1))
    xf_21 = (vector.create((xf_7 * 2 + 8) % 11 + 1, (xf_7 * 8 + 3) % 13 + 1, (xf_7 * 11 + 4) % 17 + 1))
    local yl = vector.cross(xf_41, xf_21)
    local ym = vector.dot(xf_41, xf_21)
    if vector.dot(yl, yl) + ym * ym == vector.dot(xf_41, xf_41) * vector.dot(xf_21, xf_21) + 4 then
        table.sort(xf_35, fns.fn137)
    else
        table.sort(xf_35, fns.fn137)
    end
    xf_7 = (xf_7 + 0) % 4
until (xf_7 * 3 + 1) % 4 == 2
for i, v in ipairs(xf_35) do
    table.insert(xf_30, v.Name)
end
xf_41 = {}
xf_35 = {}
for k, v in pairs(ok.Items) do
    xf_21 = table.insert
    xf_7 = v.Income or 0
    xf_37 = v.Rarity or "Common"
    xf_21(xf_35, { Name = k, Income = xf_7, Rarity = xf_37 })
end
table.sort(xf_35, fn501)
for i, v in ipairs(xf_35) do
    table.insert(xf_41, v.Name)
end
oa, SaveManager, Toggles, Options, oo, nY, nU, nN, nJ, nG, nC, nR, nA, o6, oQ, od, nX, nw, oR, ox, of, nT, pa, oB, oi, n4, nO, nH, o3, oz, oc, nM, oP, oI, ot, oh, nQ, o9, oJ, n6, o0, oM, ow, oe, nB, nx, oC, oj, n0, nI, o4, op, o8, ol, nD, nF, oF, n3, oW, ny, oS, oY, om, nv, n7, nS, n8, o2, oG = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
oa = getgenv().Library
if not n7 and nI and (nI or nX) and ((not nI or nX) and (nX or o6)) or not (not n7 and nI and (nI or nX) and ((not nI or nX) and (nX or o6))) then
    xf_9 = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = oa.Toggles
else
    local _ = getgenv().SaveManager
    oa = getgenv().SaveManager
    xf_9 = Toggles.Toggles
end
Options = oa.Options
nR = fns.fn184
nA = fns.fn454
o6 = fn724
oQ = fns.fn154
local xf_40 = "#7fd47f"
local xf_10 = "#6ec1ff"
oo = "#e8a34d"
local xf_24 = "#8b93a3"
od = fn924
nX = fn875
nw = fns.fn64
oR = fns.fn290
ox = fn853
of = fns.fn45
nT = fn916
pa = fn729
oB = fns.fn9
oi = fn536
n4 = fns.fn82
nO = fns.fn341
nH = fns.fn476
o3 = fns.fn39
oz = fn740
oc = fn635
nM = fns.fn79
oP = fns.fn131
oI = fn815
if not o2 and oW or (not o2 or false) or (not nO and not of or of and o2) or not (not o2 and oW or (not o2 or false) or (not nO and not of or of and o2)) then
    ot = fns.fn141
    oh = fn746
else
    oh = fns.fn141
    ot = fn746
end
nQ = fns.fn350
o9 = fns.fn203
oJ = function()
    local cG
    cG = {}
    local function cH(cI)
        if not cI then
            return
        end
        for i, child in ipairs(cI:GetChildren()) do
            local r8 = child:IsA("Tool") and child:GetAttribute("OriginalName")
            if r8 then
                table.insert(cG, child)
            end
        end
    end
    cH(oN:FindFirstChildOfClass("Backpack"))
    cH(oN.Character)
    return cG
end
n6 = fns.fn367
o0 = fns.fn444
oM = fns.fn83
ow = fn857
oe = fn880
nB = fns.fn257
nY = false
nU = nil
nN = 0
nJ = 0
nG = 0
nC = 0
nx = fn848
oC = fns.fn61
oj = fn603
if (false or not o0) and (not o0 and o0) or (false or not o0 or not o0 and o0) or not ((false or not o0) and (not o0 and o0) or (false or not o0 or not o0 and o0)) then
    n0 = fn758
    nI = fn682
    o4 = fns.fn91
else
    o4 = fn758
    n0 = fn682
    nI = fns.fn91
end
op = fn731
xf_2.OnClientEvent:Connect(onOnClientEvent)
xf_15.OnClientEvent:Connect(onOnClientEvent2)
o8 = function()
    local MainGui = PlayerGui:FindFirstChild("MainGui")
    if not MainGui then
        return
    end
    local tw = { { Name = "X4Power", Mult = 4 }, { Name = "X3Power", Mult = 3 }, { Name = "X2Power", Mult = 2 } }
    for i, v in ipairs(tw) do
        local tE = v
        local tw_1 = MainGui:FindFirstChild(tE.Name)
        if tw_1 and tw_1.Visible then
            pcall(function()
                CombatMultiplier:FireServer(tE.Mult)
            end)
            return
        end
    end
end
ol = fn920
nD = fns.fn423
nF = fn872
oF = fn886
n3 = fns.fn446
oW = function()
    local uE
    local uF = nY and nJ > 0 and tick() - nJ > 45
    if uF then
        op()
    end
    if nI() then
        o4()
        return
    end
    if nY then
        if od("AutoCombatMulti") then
            o8()
        end
        return
    end
    if o9() >= nQ() then
        if od("AutoReturnBase") then
            o4()
        end
        return
    end
    uE = nD()
    if not uE then
        return
    end
    local uF_1 = uE.PrimaryPart
    local uK = if uF_1 then 1 else 0
    local uI = 2197 * uK + 2527 * (1 - uK)
    local uJ = 144 * uK + 3197 * (1 - uK)
    if not ((uI * 2120 + uJ * 49 + uI * uJ) % 16777213 == 4981064) then
        uF_1 = uE:FindFirstChildWhichIsA("BasePart", true)
    end
    local uG = uF_1
    if uG then
        n4(uG.Position)
    end
    nU = uE
    nN = o9()
    nJ = tick()
    pcall(function()
        StartCombat:FireServer(uE)
    end)
end
ny = fns.fn196
oS = function()
    local uQ = oc()
    if not uQ then
        return
    end
    local uR = {}
    for i, v in ipairs(nM(uQ)) do
        if not v:GetAttribute("PlacedItem") then
            table.insert(uR, v)
        end
    end
    if #uR == 0 then
        return
    end
    local uQ_1 = {}
    for i, v in ipairs(oJ()) do
        if n6(v, "PlaceRarities", "PlaceMinRarity", "PlaceMutations") then
            table.insert(uQ_1, v)
        end
    end
    table.sort(uQ_1, function(gi, gj)
        return o0(gi) > o0(gj)
    end)
    for i, v in ipairs(uQ_1) do
        local uP = uR[i]
        if not uP then
            break
        end
        ny(v)
        task.wait(0.1)
        pcall(function()
            PlaceItem:FireServer(uP)
        end)
        task.wait(nX("PlaceDelay", 0.35))
    end
end
oY = function()
    local u8 = oc()
    if not u8 then
        return
    end
    local u9 = {}
    for i, v in ipairs(oJ()) do
        if n6(v, "ReplaceRarities", "ReplaceMinRarity", "ReplaceMutations") then
            table.insert(u9, v)
        end
    end
    table.sort(u9, function(gC, gD)
        return o0(gC) > o0(gD)
    end)
    if #u9 == 0 then
        return
    end
    local va = {}
    for i, v in ipairs(nM(u8)) do
        local vs = v
        local attr = vs:GetAttribute("PlacedItem")
        if attr then
            local u8_2 = oM(vs)
            local vb = u8_2
            local vc
            for i, v in ipairs(u9) do
                if not va[v] then
                    local vd = o0(v)
                    local ve = nX("ReplaceMinGain", 1)
                    if vd >= u8_2 + ve and vd > vb then
                        vc = v
                        vb = vd
                    end
                end
            end
            if vc then
                va[vc] = true
                pcall(function()
                    PickupFromSlot:FireServer(vs)
                end)
                task.wait(0.2)
                ny(vc)
                task.wait(0.1)
                pcall(function()
                    PlaceItem:FireServer(vs)
                end)
                task.wait(nX("ReplaceDelay", 0.4))
            end
        end
    end
end
om = function()
    local vz = oc()
    if not vz then
        return
    end
    local vA = nX("CollectMinCash", 1)
    for i, v in ipairs(nM(vz)) do
        local vI = v
        local vz_1 = vI:GetAttribute("PendingCash") or 0
        local vz_2 = vI:GetAttribute("PlacedItem") and vz_1 >= vA
        if vz_2 then
            pcall(function()
                CollectCash:FireServer(vI)
            end)
            task.wait(0.05)
        end
    end
end
nv = function()
    local vJ = oc()
    if not vJ then
        return
    end
    local vK = ok.Upgrades.MaxLevel or 50
    for i, v in ipairs(nM(vJ)) do
        local vT = v
        local attr = vT:GetAttribute("PlacedItem")
        if attr then
            local vK_1 = vT:GetAttribute("ItemLevel") or 1
            if vK_1 < vK then
                local vK_2 = ok.GetItemData(attr)
                if vK_2 then
                    local vJ_2 = ok.GetUpgradeCost(vK_2.Income, vK_1)
                    if nO() >= vJ_2 then
                        pcall(function()
                            RequestItemUpgrade:FireServer(vT)
                        end)
                        task.wait(0.05)
                    end
                end
            end
        end
    end
end
n7 = fns.fn77
nS = function()
    local vV = oR("BuyDrills")
    local vW = ox(vV)
    local vX = nO()
    local vY = {}
    for k, v in pairs(DrillConfigurations.Drills) do
        local vZ = k ~= "Default" and not oI(k)
        if vZ then
            if not vW or vV[k] then
                local insert = table.insert
                local v_ = v.CashCost or 0
                local v0 = v.LayoutOrder or 0
                insert(vY, { Name = k, Cost = v_, Order = v0 })
            end
        end
    end
    table.sort(vY, function(hM, hN)
        return hM.Order < hN.Order
    end)
    for i, v in ipairs(vY) do
        local wd = v
        if vX >= wd.Cost then
            pcall(function()
                PurchaseDrill:FireServer(wd.Name)
            end)
            task.wait(0.2)
            vX = nO()
        end
    end
end
n8 = function()
    local wf = -1
    local we = "Default"
    for k, v in pairs(DrillConfigurations.Drills) do
        local wg = oI(k) and (v.Damage or 0) > wf
        if wg then
            we = k
            wf = v.Damage or 0
        end
    end
    if ot() ~= we then
        pcall(function()
            EquipDrill:FireServer(we)
        end)
    end
end
o2 = fn734
oG = fns.fn487
xf_7 = oa:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = oD, Copyable = true }, "|", xf_18 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local xf_38 = {
    Info = xf_7:AddTab("Info", "info"),
    Main = xf_7:AddTab("Main", "gamepad-2"),
    Settings = xf_7:AddTab("Settings", "settings")
}
xf_38.Dig = xf_38.Main:AddSubTab("Dig", "pickaxe")
xf_38.Fight = xf_38.Main:AddSubTab("Fight", "swords")
xf_38.Place = xf_38.Main:AddSubTab("Place", "hammer")
xf_38.Shop = xf_38.Main:AddSubTab("Shop", "shopping-cart")
xf_37 = fns.fn296
for k, v in xf_38 do
    if v ~= xf_38.Main then
        xf_37(v)
    end
end
nK, xf_2, xf_21, Label, oU, xf_35 = nil, nil, nil, nil, nil, nil
xf_15 = 23
repeat
    xf_7 = (xf_15 * 2 + 1) % 3 + 1
    if xf_7 <= 2 then
        if xf_7 <= 1 then
            if xf_15 * 129523813 + 9 + 7 <= xf_15 * 129523813 + 9 + 7 + 1 then
                oU = tostring(game.JobId)
            else
                nK = tostring(game.JobId)
            end
            xf_15 = (xf_15 + 14) % 24
        else
            xf_7 = {
                "ynxdadxp",
                "rcmknz",
                "eohy",
                "thtwstosvl",
                "erkirnmexgf",
                "payuy",
                "bnqfzyjz",
                "ilnttbklld",
                "alqf",
                "gyzrvez"
            }
            local xP = xf_15
            xf_37 = xf_7[xP % 10 + 1]
            if xf_37:len() <= xf_37:gsub("(.)", "%1%1", xP % 3 % 2 + 1):len() then
                xf_35 = #oU > 18
            else
                oU = #xf_35 > 18
            end
            xf_15 = (xf_15 + 23) % 24
        end
    else
        xf_7 = (vector.create((xf_15 * 1 + 5) % 11 + 1, (xf_15 * 1 + 5) % 13 + 1, (xf_15 * 9 + 5) % 17 + 1))
        xf_37 = (vector.create((xf_15 * 7 + 6) % 11 + 1, (xf_15 * 9 + 9) % 13 + 1, (xf_15 * 10 + 11) % 17 + 1))
        xf_25 = (vector.create((xf_15 * 3 + 7) % 11 + 1, (xf_15 * 3 + 4) % 13 + 1, (xf_15 * 7 + 16) % 17 + 1))
        if vector.dot(vector.cross(xf_7, xf_37), xf_25) == vector.dot(vector.cross(xf_37, xf_25), xf_7) then
            nK = "Unknown"
            pcall(fn685)
            xf_2 = xf_38.Info:AddLeftGroupbox("Account", "circle-user")
            xf_2:AddLabel(oQ("User", oN.Name, xf_40), true)
            xf_2:AddLabel(oQ("Status", "Keyless", xf_40), true)
            xf_2:AddLabel(oQ("Executor", nK, xf_40), true)
            xf_21 = xf_38.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            xf_21:AddLabel(o6(xf_18 .. " [" .. tostring(game.PlaceId) .. "]", xf_10), true)
            xf_21:AddLabel(oQ("Place ID", tostring(game.PlaceId), xf_10), true)
            Label = xf_21:AddLabel(oQ("Session time", "0s", oo), true)
        else
            oN = "Unknown"
            pcall(fn685)
            nK = (nil):AddLeftGroupbox("Account", "circle-user")
            nK:AddLabel(xf_2("User", xf_38.Name, xf_18), true)
            nK:AddLabel(xf_2("Status", "Keyless", xf_18), true)
            nK:AddLabel(xf_2("Executor", oN, xf_18), true)
            xf_10 = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
            xf_10:AddLabel(Label(xf_21 .. " [" .. tostring(game.PlaceId) .. "]", xf_40), true)
            xf_10:AddLabel(xf_2("Place ID", tostring(game.PlaceId), xf_40), true)
            o6 = xf_10:AddLabel(xf_2("Session time", "0s", oQ), true)
        end
        xf_15 = (xf_15 + 20) % 24
    end
until (xf_15 * 17 + 5) % 24 == 21
if xf_35 then
    xf_15 = 3
    repeat
        if xf_15 * 7248303 + 8 + 6 <= xf_15 * 7248303 + 8 + 6 + 1 then
            xf_35 = string.sub(oU, 1, 18) .. "..."
        else
            oU = string.sub(xf_35, 1, 18) .. "..."
        end
        xf_15 = (xf_15 + 1) % 8
    until (xf_15 * 3 + 2) % 8 == 6
end
xf_15 = xf_35 or oU
ov, ReplaceGroup, ou, on, connection, connection2, n2 = nil, nil, nil, nil, nil, nil, nil
local xf_1 = xf_15
xf_21:AddLabel(oQ("Server", xf_1, xf_24), true)
xf_21:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
ov = os.clock()
task.spawn(fns.worker)
local ScriptsGroup = xf_38.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(o6("Included in this hub", xf_24), true)
ScriptsGroup:AddLabel(o6(xf_18, xf_10), true)
xf_25 = xf_38.Info:AddRightGroupbox("Features", "list")
xf_25:AddLabel(o6("Auto Dig", xf_10), true)
xf_25:AddLabel(o6("Auto Fight", oo), true)
xf_25:AddLabel(o6("Auto Place", oo), true)
xf_25:AddLabel(o6("Auto Shop", xf_40), true)
xf_25:AddLabel(o6("Misc Utilities", xf_24), true)
xf_37 = xf_38.Info:AddRightGroupbox("Socials", "link")
xf_37:AddButton({ Text = "Discord", Func = nA })
xf_37:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
xf_7 = xf_38.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
xf_7:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
xf_7:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
xf_7:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
xf_7:AddButton({ Text = "Copy Discord Invite", Func = nA })
xf_35 = xf_38.Info:AddRightGroupbox("FAQ", "circle-help")
xf_35:AddLabel("Where do I get a good config?", true)
xf_35:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
xf_35:AddLabel("How do I import / export configs?", true)
xf_35:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
xf_35:AddLabel("How do I report bugs?", true)
xf_35:AddLabel("Join the Discord and post it in the bugs channel.", true)
xf_35:AddLabel("How do I make suggestions?", true)
xf_35:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
xf_35:AddLabel("How do I get help or updates?", true)
xf_35:AddLabel("Join the Discord, updates and support are posted there first.", true)
xf_2 = xf_38.Dig:AddLeftGroupbox("Dig", "pickaxe")
xf_2:AddToggle("AutoDig", { Text = "Auto Dig", Default = false })
xf_2:AddDropdown("DigMode", { Text = "Dig mode", Values = { "Highest", "Best For Drill", "Specific" }, Default = "Highest" })
xf_2:AddDropdown("DigZone", { Text = "Zone", Values = xf_28, Default = "DrillZone1" })
xf_2:AddSlider("DigMaxSeconds", { Text = "Max dig time", Default = 120, Min = 5, Max = 600, Rounding = 0, Suffix = "s" })
xf_2:AddSlider("DigDelay", { Text = "Dig delay", Default = 0.35, Min = 0.1, Max = 3, Rounding = 2, Suffix = "s" })
local FightGroup = xf_38.Fight:AddLeftGroupbox("Fight", "swords")
FightGroup:AddToggle("AutoFight", { Text = "Auto Fight", Default = false })
FightGroup:AddToggle("AutoCombatMulti", { Text = "Auto Multipliers", Default = true })
FightGroup:AddToggle("AutoReturnBase", { Text = "Register Held When Full", Default = true })
FightGroup:AddSlider("BaseReturnDelay", { Text = "Register delay", Default = 1.25, Min = 0.25, Max = 5, Rounding = 2, Suffix = "s" })
FightGroup:AddDropdown("FightPriority", { Text = "Priority", Values = { "Best Income", "Nearest", "Weakest" }, Default = "Best Income" })
FightGroup:AddDropdown("FightMinRarity", { Text = "Min rarity", Values = xf_33, Default = "Common" })
FightGroup:AddDropdown("FightRarities", { Text = "Rarities", Values = xf_33, Multi = true, AllowNull = true, Default = {} })
local FiltersGroup = xf_38.Fight:AddRightGroupbox("Filters", "filter")
FiltersGroup:AddDropdown("FightCharacters", {
    Text = "Characters",
    Values = xf_41,
    Multi = true,
    AllowNull = true,
    Searchable = true,
    Default = {}
})
FiltersGroup:AddDropdown("FightMutations", { Text = "Mutations", Values = xf_44, Multi = true, AllowNull = true, Default = {} })
FiltersGroup:AddSlider("FightMaxDistance", { Text = "Max distance", Default = 0, Min = 0, Max = 2000, Rounding = 0 })
FiltersGroup:AddSlider("FightDelay", { Text = "Fight delay", Default = 0.4, Min = 0.1, Max = 3, Rounding = 2, Suffix = "s" })
local PlaceGroup = xf_38.Place:AddLeftGroupbox("Place", "hammer")
if (on and on or (not on or PlaceGroup) or (on or PlaceGroup) and (PlaceGroup and not PlaceGroup)) and (not on and not on and (not PlaceGroup and on) or (PlaceGroup or PlaceGroup or (PlaceGroup or on))) and not ((on and on or (not on or PlaceGroup) or (on or PlaceGroup) and (PlaceGroup and not PlaceGroup)) and (not on and not on and (not PlaceGroup and on) or (PlaceGroup or PlaceGroup or (PlaceGroup or on)))) then
    ReplaceGroup:AddToggle("AutoPlace", { Text = "Auto Place", Default = false })
    ReplaceGroup:AddDropdown("PlaceMinRarity", { Default = "Common", Values = xf_44, Text = "Min rarity" })
    ReplaceGroup:AddDropdown("PlaceRarities", { Default = {}, Values = xf_44, Multi = true, AllowNull = true, Text = "Rarities" })
    ReplaceGroup:AddDropdown("PlaceMutations", { Values = xf_33, AllowNull = true, Text = "Mutations", Multi = true, Default = {} })
    ReplaceGroup:AddSlider("PlaceDelay", { Text = "Place delay", Suffix = "s", Default = 0.35, Rounding = 2, Min = 0.1, Max = 3 })
    xf_38 = PlaceGroup.Place:AddRightGroupbox("Replace", "replace")
else
    PlaceGroup:AddToggle("AutoPlace", { Text = "Auto Place", Default = false })
    PlaceGroup:AddDropdown("PlaceMinRarity", { Text = "Min rarity", Values = xf_33, Default = "Common" })
    PlaceGroup:AddDropdown("PlaceRarities", { Text = "Rarities", Values = xf_33, Multi = true, AllowNull = true, Default = {} })
    PlaceGroup:AddDropdown("PlaceMutations", { Text = "Mutations", Values = xf_44, Multi = true, AllowNull = true, Default = {} })
    PlaceGroup:AddSlider("PlaceDelay", { Text = "Place delay", Default = 0.35, Min = 0.1, Max = 3, Rounding = 2, Suffix = "s" })
    ReplaceGroup = xf_38.Place:AddRightGroupbox("Replace", "replace")
end
ReplaceGroup:AddToggle("AutoReplace", { Text = "Auto Replace Better", Default = false })
ReplaceGroup:AddDropdown("ReplaceMinRarity", { Text = "Min rarity", Values = xf_33, Default = "Common" })
ReplaceGroup:AddDropdown("ReplaceRarities", { Text = "Rarities", Values = xf_33, Multi = true, AllowNull = true, Default = {} })
ReplaceGroup:AddDropdown("ReplaceMutations", { Text = "Mutations", Values = xf_44, Multi = true, AllowNull = true, Default = {} })
ReplaceGroup:AddSlider("ReplaceMinGain", { Text = "Min income gain", Default = 1, Min = 1, Max = 100000000, Rounding = 0 })
ReplaceGroup:AddSlider("ReplaceDelay", { Text = "Replace delay", Default = 0.4, Min = 0.1, Max = 3, Rounding = 2, Suffix = "s" })
local CollectGroup = xf_38.Place:AddLeftGroupbox("Collect", "coins")
CollectGroup:AddToggle("AutoCollect", { Text = "Auto Collect", Default = false })
CollectGroup:AddSlider("CollectMinCash", { Text = "Min pending cash", Default = 1, Min = 1, Max = 1000000000, Rounding = 0 })
CollectGroup:AddToggle("AutoUpgradeItems", { Text = "Auto Upgrade Characters", Default = false })
local RebirthGroup = xf_38.Shop:AddLeftGroupbox("Rebirth", "refresh-cw")
RebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
local DrillsGroup = xf_38.Shop:AddLeftGroupbox("Drills", "pickaxe")
DrillsGroup:AddToggle("AutoBuyDrills", { Text = "Auto Buy Drills", Default = false })
DrillsGroup:AddToggle("AutoEquipBestDrill", { Text = "Auto Equip Best", Default = true })
DrillsGroup:AddDropdown("BuyDrills", { Text = "Drills", Values = xf_30, Multi = true, AllowNull = true, Default = {} })
local UpgradesGroup = xf_38.Shop:AddRightGroupbox("Upgrades", "arrow-big-up")
UpgradesGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
UpgradesGroup:AddToggle("BuyUpgradeMax", { Text = "Buy Max", Default = false })
UpgradesGroup:AddDropdown("BuyUpgrades", {
    Text = "Upgrades",
    Values = xf_13,
    Multi = true,
    AllowNull = true,
    Default = { Power = true, Speed = true, Jump = true, Carry = true }
})
UpgradesGroup:AddSlider("ShopDelay", { Text = "Shop delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 2, Suffix = "s" })
local MenuGroup = xf_38.Settings:AddLeftGroupbox("Menu", "settings")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
oa.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
oa:OnUnload(fns.fn358)
xf_9:SetLibrary(oa)
xf_9:SetFolder("TempoHub")
xf_9:SaveDefault("Monochrome")
xf_9:ApplyToTab(xf_38.Settings)
xf_9:LoadDefault()
SaveManager:SetLibrary(oa)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/DrillForAnime")
SaveManager:BuildConfigSection(xf_38.Settings)
SaveManager:LoadAutoloadConfig()
ou = tick()
on = tick()
pcall(function()
    for i, v in ipairs(getconnections(oN.Idled)) do
        local wO = v
        pcall(function()
            wO:Disable()
        end)
    end
end)
n2 = fn585
connection = UserInputService.InputBegan:Connect(fns.onInputBegan)
connection2 = UserInputService.InputChanged:Connect(fns.onInputChanged)
oa:OnUnload(fns.fn319)
task.spawn(fns.worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(worker6)
task.spawn(fns.worker7)
oa:Notify("Drill for Anime loaded")
end)(...)

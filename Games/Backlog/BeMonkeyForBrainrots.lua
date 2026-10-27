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
getgenv().TempoHoodSubtitle = "BE MONKEY FOR BRAINROTS!"
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
local lW
local kW
local lD
local TailConfig
local Label
local HttpService
local lq
local k7
local lP
local kP
local lw
local ld
local lV
local kV
local PlayerGui
local lj
local AuraRemote
local lI
local StrengthSystemFunction
local Toggles
local connection2
local lv
local lc
local lU
local kU
local lB
local li
local CurrentCamera
local k_
local lH
local lo
local connection
local VirtualUser
local ChargeGameplayConfig
local lb
local SaveManager
local lA
local ChargeGameplayRemote
local lZ
local kZ
local LocalPlayer
local ln
local k4
local lM
local StrengthConfig
local la
local UserInputService
local kS
local lz
local lg
local lY
local kY
local lF
local lm
local k3
local Options
local ls
local StrengthSystemRemote
local lR
local kR
local ly
local lf
local lX
local TailSystemRemote
local lE
local ll
local k2
local lK
local lr
local k8
local lQ
local Library
local lx
local le
function fns.onCopyUSDTAddress()
    lA(k7, "Copied USDT address")
end
function fns.worker8()
    while not Library.Unloaded do
        task.wait(0.6)
        if lP("AutoBuyWeights") then
            lM()
            local cash = kW.cash
            local rebirths = kW.rebirths
            local pB = false
            for k, v in StrengthConfig.Weights do
                local pC_1 = not v.PaidOnly
                if pC_1 ~= false then
                    pC_1 = not kS(v.Id)
                end
                if pC_1 then
                    local pD = rebirths >= (v.RequiredRebirth or 0)
                    if pD then
                        pD = cash >= (v.Cost or 0)
                    end
                    if pD then
                        lz(StrengthSystemRemote, "BuyOrEquip", v.Id)
                        pB = true
                        break
                    end
                end
            end
            if not pB then
                local pz_1 = -1
                local Id = nil
                for k, v in StrengthConfig.Weights do
                    local pB_1 = not v.PaidOnly
                    if pB_1 ~= false then
                        pB_1 = kS(v.Id)
                    end
                    if pB_1 then
                        local pB_2 = tonumber(v.Gain) or 0
                        if pB_2 > pz_1 then
                            pz_1 = pB_2
                            Id = v.Id
                        end
                    end
                end
                local pB_3 = Id and tostring(kW.equippedWeight) ~= Id
                if pB_3 then
                    lz(StrengthSystemRemote, "BuyOrEquip", Id)
                end
            end
        end
    end
end
function fns.onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local qf_1 = la()
        if qf_1 then
            for i, descendant in qf_1:GetDescendants() do
                local qf_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if qf_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
function fns.worker2()
    while not Library.Unloaded do
        if lP("AutoSkip") then
            lm()
        end
        if lP("AutoCharge") then
            pcall(lR)
        else
            task.wait(0.15)
        end
    end
end
function fns.worker6()
    while not Library.Unloaded do
        task.wait(0.7)
        if lP("AutoRebirth") then
            lM()
            local rebirths = kW.rebirths
            local o5 = tonumber(StrengthConfig.MaxRebirths) or 15
            if rebirths < o5 then
                local o5_1 = StrengthConfig.GetRebirthRequirement(rebirths)
                local o4_1 = type(o5_1) == "number" and kW.strength >= o5_1
                if o4_1 then
                    lz(StrengthSystemRemote, "Rebirth")
                end
            end
        end
    end
end
local function onCopyLitecoinAddress()
    lA(li, "Copied Litecoin address")
end
local function worker()
    local ot_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local oq = math.floor(os.clock() - lU)
        if oq < 60 then
            ot_1 = oq .. "s"
        elseif oq < 3600 then
            ot_1 = string.format("%dm %ds", math.floor((oq) / (60)), oq % 60)
        else
            ot_1 = string.format("%dh %dm", math.floor((oq) / (3600)), math.floor((oq % 3600) / (60)))
        end
        Label:SetText(lK("Session time", ot_1, lv))
    end
end
local function onOnClientEvent(bE, bF)
    local n6 = bE ~= "Sync"
    local oa = if n6 then 1 else 0
    local n8 = 119 * oa + 1703 * (1 - oa)
    local n9 = 3044 * oa + 1595 * (1 - oa)
    if not ((n8 * 1823 + n9 * 2041 + n8 * n9) % 16777213 == 6791977) then
        n6 = type(bF) ~= "table"
    end
    if n6 then
        return
    end
    if type(bF.Owned) == "table" then
        lj = bF.Owned
        lj.Brown = true
    end
    if bF.Equipped then
        lf = tostring(bF.Equipped)
    end
end
local function fn83()
    connection:Disconnect()
    connection2:Disconnect()
    k_(false)
    select("#", "Unloaded!")
end
local function fn88(bl)
    local ownedWeights = kW.ownedWeights
    if type(ownedWeights) == "table" then
        if ownedWeights[bl] == true then
            return true
        end
        for k, v in ownedWeights do
            if v == bl or v == true and k == bl then
                return true
            end
        end
        local nM_2 = kW.equippedWeight or ""
        return tostring(nM_2) == bl
    end
    local nM_3 = kW.equippedWeight or ""
    return tostring(nM_3) == bl
end
local function fn89(af)
    local mS = Toggles[af]
    return mS ~= nil and mS.Value == true
end
local function fn107(bO, bP)
    return string.format('<font color="%s">%s</font>', bP, bO)
end
local function onInputBegan()
    ly = tick()
end
local function fn124()
    local m4 = ChargeGameplayConfig.ChargeZoneName
    local m8 = if m4 then 1 else 0
    local m6 = 1345 * m8 + 3006 * (1 - m8)
    local m7 = 2600 * m8 + 4052 * (1 - m8)
    if not ((m6 * 2478 + m7 * 294 + m6 * m7) % 16777213 == 7594310) then
        m4 = "ChargeZone"
    end
    return workspace:FindFirstChild(m4)
end
local function onCopyEthereumAddress()
    lA(lb, "Copied Ethereum address")
end
local function onRenderStepped(fy)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local qp_1 = k2()
        if qp_1 then
            qp_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local qp_3 = kP()
        local qq = k2()
        if qp_3 and qq then
            qq.PlatformStand = true
            local qq_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                qq_1 = qq_1 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                qq_1 = qq_1 - CurrentCamera.CFrame.LookVector
            end
            local qv = if UserInputService:IsKeyDown(Enum.KeyCode.A) then 1 else 0
            if qv == 1 then
                qq_1 = qq_1 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                qq_1 = qq_1 + CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                qq_1 = qq_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                qq_1 = qq_1 - Vector3.new(0, 1, 0)
            end
            qp_3.Velocity = Vector3.zero
            if qq_1.Magnitude > 0 then
                qp_3.CFrame = qp_3.CFrame + qq_1.Unit * Options.FlySpeed.Value * fy
            end
        end
    end
end
local function onCopyVenmoLink()
    lA(kV, "Copied Venmo link")
end
local function onCopySolanaAddress()
    lA(k3, "Copied Solana address")
end
local function fn184(K, L)
    if setclipboard then
        setclipboard(K)
    elseif toclipboard then
        toclipboard(K)
    end
    Library:Notify(L)
end
local function onExportConfigToClipboard()
    local rF_1
    local rE_1
    rE_1, rF_1 = pcall(HttpService.JSONEncode, HttpService, lX())
    if not rE_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local rE_2 = setclipboard or toclipboard
    local rE_3 = type(rE_2) ~= "function" or not pcall(rE_2, rF_1)
    if rE_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function fn257()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    lx = tick()
end
local function fn258()
    local ne = lI()
    local nf = kP()
    local ng = ne and ne:IsA("BasePart")
    if not (ng and nf) then
        return
    end
    local ng_1 = 3
    local nh_1 = k2()
    if nh_1 then
        ng_1 = math.max(nh_1.HipHeight + 1.5, 3)
    end
    nf.CFrame = CFrame.new(ne.Position + Vector3.new(0, ne.Size.Y * 0.5 + ng_1, 0))
    nf.AssemblyLinearVelocity = Vector3.zero
    nf.AssemblyAngularVelocity = Vector3.zero
end
local function fn281()
    local rk = {}
    for k, v in { Toggles, Options } do
        for k, v in v do
            local rl = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if rl then
                local rl_1 = kU(k, v)
                if rl_1 then
                    rk[#rk + 1] = rl_1
                end
            end
        end
    end
    table.sort(rk, function(gV, gW)
        if gV.type ~= gW.type then
            return gV.type < gW.type
        end
        return gV.idx < gW.idx
    end)
    return { objects = rk }
end
local function fn298(az, aA)
    local attr = LocalPlayer:GetAttribute(az)
    local m1 = attr ~= ""
    local m2 = typeof(attr) == "string" and m1
    if m2 then
        return attr
    end
    return aA
end
local function fn326(dX)
    local o7 = dX and dX:IsA("Tool")
    if not o7 then
        return false
    elseif dX:GetAttribute("IsTrainingWeight") == true then
        return true
    elseif dX:GetAttribute("WeightId") ~= nil then
        return true
    else
        return dX.Name == lg()
    end
end
local function fn384()
    local mP = la()
    local mQ = mP and mP:FindFirstChild("HumanoidRootPart")
    return mQ
end
local function onRscripts()
    lA(lE, "Copied Rscripts profile to clipboard")
end
local function worker10()
    while not Library.Unloaded do
        task.wait(0.6)
        if lP("AutoBuyTails") then
            local p1 = k4("Coins")
            local p2 = false
            local p3 = true
            local p4 = "Brown"
            for k, v in TailConfig.Order do
                local p5 = TailConfig.Tails[v]
                if lj[v] == true then
                    p3 = true
                    p4 = v
                else
                    if p3 and p5 and p1 >= (p5.Price or 0) then
                        lz(TailSystemRemote, "BuyTail", { tailId = v })
                        p2 = true
                        break
                    end
                    p3 = false
                end
            end
            local p1_1 = p4 ~= lf
            local p3_1 = not p2
            if p3_1 ~= false then
                p3_1 = p1_1
            end
            if p3_1 then
                lz(TailSystemRemote, "EquipTail", { tailId = p4 })
            end
        end
    end
end
local function onCopyJoinScript_JobID()
    local oj = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, kY)
    if setclipboard then
        setclipboard(oj)
    elseif toclipboard then
        toclipboard(oj)
    end
    Library:Notify("Copied join script to clipboard")
end
local function fn425()
    local m9 = lI()
    local na = kP()
    local nb = m9 and m9:IsA("BasePart")
    if not (nb and na) then
        return false
    end
    local nb_1 = tonumber(ChargeGameplayConfig.ChargeZoneJumpExtraY) or 80
    local nb_2 = m9.CFrame:PointToObjectSpace(na.Position)
    local na_1 = m9.Size * 0.5
    local m9_1 = math.abs(nb_2.X) <= na_1.X and math.abs(nb_2.Z) <= na_1.Z and nb_2.Y >= -na_1.Y and nb_2.Y <= na_1.Y + nb_1
    return m9_1
end
local function fn428()
    local nZ = ls(StrengthSystemFunction, "GetState")
    if type(nZ) == "table" then
        local n_ = type(nZ.ownedWeights) == "table" and nZ.ownedWeights
        local n1 = n_ or {}
        kW.ownedWeights = n1
        local n__1 = (tonumber(nZ.strength))
        local n5 = if n__1 then 1 else 0
        local n3 = 1753 * n5 + 3928 * (1 - n5)
        local n4 = 2603 * n5 + 1214 * (1 - n5)
        if not ((n3 * 4079 + n4 * 1988 + n3 * n4) % 16777213 == 111097) then
            n__1 = kW.strength
        end
        kW.strength = n__1
        local n__2 = tonumber(nZ.cash) or kW.cash
        kW.cash = n__2
        local n__3 = tonumber(nZ.rebirths) or kW.rebirths
        kW.rebirths = n__3
        local n__4 = nZ.equippedWeight or kW.equippedWeight
        kW.equippedWeight = tostring(n__4)
    end
    kW.cash = k4("Cash")
    kW.strength = k4("Strength")
    kW.rebirths = k4("Rebirths")
    kW.equippedWeight = kR("EquippedWeight", kW.equippedWeight)
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local q_ = tick() - ly
            local q0 = tick() - lx
            if q_ >= 300 and q0 >= 60 then
                pcall(ln)
            else
                if q_ < 300 and q0 >= 300 then
                    pcall(ln)
                end
            end
        end
    end
end
local function fn517()
    if not Toggles.Fly.Value then
        local qw = k2()
        if qw then
            qw.PlatformStand = false
        end
    end
end
local function fn537()
    local oA = if LocalPlayer:GetAttribute("HasInstantCharge") == true then 1 else 0
    if oA == 1 then
        return 0.12
    end
    local ow = tonumber(ChargeGameplayConfig.ChargeSeconds) or 3
    return math.max(0.15, ow)
end
local function worker7()
    while not Library.Unloaded do
        local pv = tonumber(StrengthConfig.TrainInterval) or 1
        task.wait(math.max(0.25, pv * 0.5))
        if lP("AutoUseWeights") then
            pcall(lD)
        end
    end
end
local function fn545()
    k_(Toggles.AntiGameplayPause.Value)
end
local function onCopyPayPalLink()
    lA(kZ, "Copied PayPal link")
end
local function onUnload()
    Library:Unload()
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            k_(true)
        end
    end
end
local function fn611()
    local mM = la()
    local mN = mM and mM:FindFirstChildOfClass("Humanoid")
    return mN
end
local function fn612()
    local Charge = PlayerGui:FindFirstChild("Charge")
    local nH = Charge and Charge:FindFirstChild("Skip")
    local nG_1 = nH
    if nH then
        nH = nG_1:IsA("GuiButton")
    end
    if nH then
        nH = nG_1.Visible
    end
    if nH then
        lF(nG_1)
    end
end
local function fn629()
    return LocalPlayer.Character
end
local function fn639()
    local oG = if lV() then 1 else 0
    if oG == 1 then
        task.wait(0.15)
        return
    end
    if not lB() then
        lc()
        task.wait(0.12)
        if not lB() then
            return
        end
    end
    lz(ChargeGameplayRemote, "BeginCharge")
    local oB = os.clock() + lZ()
    while true do
        local oC_1 = os.clock() < oB and lP("AutoCharge") and not Library.Unloaded
        if oC_1 then
            if not lB() then
                lc()
            end
            if lP("AutoSkip") then
                lm()
            end
            task.wait(0.05)
            continue
        end
        break
    end
    local oB_1 = not lP("AutoCharge") or Library.Unloaded
    if oB_1 then
        return
    end
    lz(ChargeGameplayRemote, "Launch", { percent = 100 })
    local oB_2 = os.clock() + 45
    while true do
        local oC_2 = lV() and os.clock() < oB_2 and lP("AutoCharge") and not Library.Unloaded
        if oC_2 then
            if lP("AutoSkip") then
                lm()
            end
            task.wait(0.15)
            continue
        end
        break
    end
    task.wait(0.35)
end
local function fn650()
    return kR("EquippedWeight", "Banana")
end
local function fn653(gI, gJ)
    local Type = gJ.Type
    if Type == "Toggle" then
        return { idx = gI, type = "Toggle", value = gJ.Value == true }
    elseif Type == "Slider" then
        return { idx = gI, type = "Slider", value = tostring(gJ.Value) }
    elseif Type == "Dropdown" then
        return { idx = gI, type = "Dropdown", multi = gJ.Multi == true, value = gJ.Value }
    elseif Type == "Input" then
        local rb = gJ.Value or ""
        return { idx = gI, type = "Input", text = tostring(rb) }
    elseif Type == "ColorPicker" then
        return { idx = gI, type = "ColorPicker", value = gJ.Value:ToHex(), transparency = gJ.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = gI,
            type = "KeyPicker",
            mode = gJ.Mode,
            key = gJ.Value,
            modifiers = gJ.Modifiers,
            toggled = gJ.Toggled
        }
    else
        return nil
    end
end
local function worker5()
    while not Library.Unloaded do
        task.wait(0.8)
        if lP("AutoUpgradeBase") then
            local oY = lQ()
            if oY then
                local oZ = workspace:FindFirstChild("Base") and workspace.Base:FindFirstChild(oY)
                local o_ = oZ
                if oZ then
                    oZ = tonumber(o_:GetAttribute("BaseUpgradeLevel"))
                end
                local o__1 = oZ or 0
                local o__2 = lo.GetPriceUpgrade(o__1)
                local oZ_2 = type(o__2) == "number" and k4("Cash") >= o__2
                if oZ_2 then
                    lz(ld, "UpgradeBase", { baseName = oY })
                end
            end
        end
    end
end
local function onOnClientEvent2(er, es)
    local px = Library.Unloaded or not lP("Auto2x")
    if px then
        return
    end
    local px_1 = er ~= "StartQTE" or type(es) ~= "table"
    if px_1 then
        return
    end
    local id = es.id
    if id == nil then
        return
    end
    lz(StrengthSystemRemote, "QTEResult", { success = true, id = tostring(id) })
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local qn_1 = k2()
        if qn_1 then
            qn_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn693()
    Library.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
local function fn695()
    if not Toggles.WalkSpeedEnabled.Value then
        local qB = k2()
        if qB then
            qB.WalkSpeed = 16
        end
    end
end
local function fn699()
    local oc_1
    local ob_1
    if identifyexecutor then
        oc_1, ob_1 = identifyexecutor()
        local od = oc_1 ~= ""
        local oe = type(oc_1) == "string" and od
        if oe then
            local od_1 = type(ob_1) == "string" and ob_1 ~= "" and oc_1 .. " " .. ob_1
            lr = od_1 or oc_1
        end
    end
end
local function worker3()
    while not Library.Unloaded do
        task.wait(1.3)
        if lP("AutoEquipBest") then
            lz(ld, "PlaceBestBrainrots")
        end
    end
end
local function fn731()
    local oJ = kP()
    if not oJ or not firetouchinterest then
        return
    end
    local oK_1 = lQ()
    if not oK_1 then
        return
    end
    local Base = workspace:FindFirstChild("Base")
    local oM = Base and Base:FindFirstChild(oK_1)
    local oL_1 = oM and oM:FindFirstChild("Podiums")
    if not oL_1 then
        return
    end
    for k, v in oL_1:QueryDescendants("#CashClaim") do
        local oK_4 = v:IsA("BasePart") and v:FindFirstChild("TouchInterest")
        if oK_4 then
            pcall(firetouchinterest, oJ, v, 0)
            pcall(firetouchinterest, oJ, v, 1)
        end
    end
end
local function fn766()
    return kR("AssignedBaseName", nil)
end
local function onCopyBitcoinAddress()
    lA(le, "Copied Bitcoin address")
end
local function fn804(bR, bS, bT)
    return string.format("<b>%s</b> %s %s", bR, lW("-", "#5a6070"), lW(bS, bT))
end
local function fn810()
    lA(lH, "Copied Discord invite to clipboard")
end
local function worker9()
    while not Library.Unloaded do
        task.wait(0.8)
        if lP("AutoEquipBestAura") then
            local pR = k4("Rebirths")
            local attr = LocalPlayer:GetAttribute("OwnsVoidAura")
            local pT = "Normal"
            local pU = attr == true
            for k, v in lq.Order do
                if lq.IsUnlocked(v, pR, pU) then
                    pT = v
                end
            end
            if kR("EquippedAura", "Normal") ~= pT then
                lz(AuraRemote, "Equip", pT)
            end
        end
    end
end
local function onImportConfigFromClipboardTex()
    local rK_1
    local rI = Options.SaveManager_ImportSource.Value or ""
    local rI_1
    local rJ = tostring(rI):match("^%s*(.-)%s*$")
    if rJ == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    rI_1, rK_1 = pcall(HttpService.JSONDecode, HttpService, rJ)
    local rJ_1 = not rI_1 or type(rK_1) ~= "table"
    local rO = if rJ_1 then 1 else 0
    local rM = 2816 * rO + 3881 * (1 - rO)
    local rN = 1130 * rO + 1512 * (1 - rO)
    if not ((rM * 1921 + rN * 687 + rM * rN) % 16777213 == 9367926) then
        rJ_1 = type(rK_1.objects) ~= "table"
    end
    if rJ_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local rI_2 = 0
    for k, v in rK_1.objects do
        if ll(v) then
            rI_2 += 1
        end
    end
    if rI_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local rK_2 = rI_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(rI_2, rK_2), 6)
end
local function worker4()
    while not Library.Unloaded do
        task.wait(0.5)
        local oX = if lP("AutoCollectMoney") then 1 else 0
        if oX == 1 then
            pcall(lY)
        end
    end
end
local function fn897()
    local nm = LocalPlayer:GetAttribute("ChargeGameplayActive") == true or PlayerGui:GetAttribute("ChargeGameplaySequenceActive") == true
    return nm
end
local function onInputChanged(gg)
    local UserInputType = gg.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        ly = tick()
    end
end
local function fn918(R)
    local DiscordGroup = R:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = lw })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = lw })
end
local function fn919(aw)
    local mZ = tonumber(LocalPlayer:GetAttribute(aw)) or 0
    return mZ
end
local function fn953()
    local o9 = la()
    if o9 then
        for i, child in o9:GetChildren() do
            if k8(child) then
                return child
            end
        end
    end
    for i, child in LocalPlayer.Backpack:GetChildren() do
        if k8(child) then
            return child
        end
    end
    return nil
end
local function fn957(gA, gB)
    local q4_1 = (gA == "Toggle" and Toggles or Options)[gB]
    local q3_2 = type(q4_1) == "table" and q4_1.Type == gA
    return q3_2 and q4_1 or nil
end
connection2 = nil
kP = nil
Library = nil
kR = nil
kS = nil
kU = nil
kV = nil
kW = nil
TailSystemRemote = nil
kY = nil
kZ = nil
k_ = nil
AuraRemote = nil
Label = nil
k2 = nil
k3 = nil
k4 = nil
connection = nil
StrengthSystemFunction = nil
k7 = nil
k8 = nil
StrengthSystemRemote = nil
la = nil
lb = nil
lc = nil
ld = nil
le = nil
lf = nil
lg = nil
ChargeGameplayRemote = nil
li = nil
lj = nil
TailConfig = nil
ll = nil
lm = nil
ln = nil
lo = nil
lq = nil
lr = nil
ls = nil
StrengthConfig = nil
ChargeGameplayConfig = nil
lv = nil
lw = nil
lx = nil
ly = nil
lz = nil
lA = nil
local kT, lp
lB = nil
PlayerGui = nil
lD = nil
lE = nil
lF = nil
LocalPlayer = nil
lH = nil
lI = nil
HttpService = nil
lK = nil
Options = nil
lM = nil
VirtualUser = nil
Toggles = nil
lP = nil
lQ = nil
lR = nil
UserInputService = nil
SaveManager = nil
lU = nil
lV = nil
lW = nil
lX = nil
lY = nil
lZ = nil
CurrentCamera = nil
local l4, mb, mc, md, me, mf
local DonationsGroup
UserInputService, VirtualUser, HttpService, LocalPlayer, PlayerGui = nil, nil, nil, nil, nil
local rY_2 = game:GetService("Players")
local rY_1 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
LocalPlayer = rY_2.LocalPlayer
PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
if setthreadidentity then
    setthreadidentity(8)
end
ChargeGameplayConfig, StrengthConfig, lq, lo, TailConfig, ChargeGameplayRemote, ld, StrengthSystemRemote, StrengthSystemFunction, AuraRemote, TailSystemRemote, Library, SaveManager, Toggles, Options, lH, lE, kW, lj, lf, lA, lw, la, k2, kP, lP, lz, ls, k4, kR, lQ, lI, lB, lc, lV, lF, lm, kS, lM = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local l9 = "Be Monkey For Brainrots"
local l6 = rY_1:WaitForChild("Modules")
local l5 = rY_1:WaitForChild("Events")
ChargeGameplayConfig = require(l6:WaitForChild("ChargeGameplayConfig"))
StrengthConfig = require(l6:WaitForChild("StrengthConfig"))
if ((lq or not lq) and (not lq and not lq) or not lq and lq and (lq or not k4)) and not ((lq or not lq) and (not lq and not lq) or not lq and lq and (lq or not k4)) then
    require(TailConfig:WaitForChild("AuraConfig"))
    lq = require(TailConfig:WaitForChild("BaseUpgradeConfig"))
    l5 = require(TailConfig:WaitForChild("TailModules"):WaitForChild("TailConfig"))
    ld = ChargeGameplayRemote:WaitForChild("ChargeGameplayRemote")
    lo = ChargeGameplayRemote:WaitForChild("BaseSystemRemote")
else
    lq = require(l6:WaitForChild("AuraConfig"))
    lo = require(l6:WaitForChild("BaseUpgradeConfig"))
    TailConfig = require(l6:WaitForChild("TailModules"):WaitForChild("TailConfig"))
    ChargeGameplayRemote = l5:WaitForChild("ChargeGameplayRemote")
    ld = l5:WaitForChild("BaseSystemRemote")
end
StrengthSystemRemote = l5:WaitForChild("StrengthSystemRemote")
StrengthSystemFunction = l5:WaitForChild("StrengthSystemFunction")
AuraRemote = l5:WaitForChild("AuraRemote")
TailSystemRemote = l5:WaitForChild("TailSystemRemote")
Library = getgenv().Library
pcall(fn693)
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
lH = "https://discord.gg/K7Qxnxkk46"
lE = "https://discord.gg/K7Qxnxkk46"
lA = fn184
lw = fn810
local l7 = fn918
la = fn629
k2 = fn611
kP = fn384
lP = fn89
lz = function(ak, ...)
    local al
    al = { ... }
    pcall(function()
        ak:FireServer(table.unpack(al))
    end)
end
ls = function(ap, ...)
    local mV
    mV = nil
    local mX_1
    local mW_1
    mV = { ... }
    mW_1, mX_1 = pcall(function()
        return ap:InvokeServer(table.unpack(mV))
    end)
    if not mW_1 then
        return nil
    end
    return mX_1
end
k4 = fn919
kR = fn298
lQ = fn766
lI = fn124
lB = fn425
lc = fn258
lV = fn897
lF = function(a4)
    local np = a4 and a4:IsA("GuiButton")
    if not np then
        return
    end
    pcall(function()
        a4:Activate()
    end)
    if firesignal then
        pcall(firesignal, a4.Activated)
        pcall(firesignal, a4.MouseButton1Click)
        return
    end
    if not getconnections then
        return
    end
    for k, v in { a4.Activated, a4.MouseButton1Click } do
        for k, v in getconnections(v) do
            local nF = v
            pcall(function()
                if nF.Fire then
                    nF:Fire()
                elseif nF.Function then
                    nF.Function()
                end
            end)
        end
    end
end
lm = fn612
kW = { ownedWeights = {}, strength = 0, cash = 0, rebirths = 0, equippedWeight = "" }
kS = fn88
lM = fn428
lj = { Brown = true }
lf = "Brown"
TailSystemRemote.OnClientEvent:Connect(onOnClientEvent)
lz(TailSystemRemote, "RequestSync")
rY_2 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = lH, Copyable = true }, "|", l9 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
local l8 = {
    Info = rY_2:AddTab("Info", "info"),
    Main = rY_2:AddTab("Main", "zap"),
    Player = rY_2:AddTab("Player", "person-standing"),
    Settings = rY_2:AddTab("Settings", "settings")
}
for k, v in { l8.Main, l8.Player, l8.Settings } do
    l7(v)
end
mb, l6, lv, l5, lr, rY_2, l4, Label, kY, rY_1, lW, lK = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local rY_5 = 0
repeat
    l7 = (rY_5 * 5 + 6) % 9 + 1
    if l7 <= 5 then
        if l7 <= 3 then
            if l7 <= 2 then
                if l7 <= 1 then
                    mc = (vector.create((rY_5 * 3 + 6) % 11 + 1, (rY_5 * 8 + 12) % 13 + 1, (rY_5 * 2 + 8) % 17 + 1))
                    md = (vector.create((rY_5 * 6 + 1) % 11 + 1, (rY_5 * 9 + 11) % 13 + 1, (rY_5 * 10 + 8) % 17 + 1))
                    me = (vector.create((rY_5 * 4 + 7) % 5 + 1, (rY_5 * 2 + 2) % 7 + 1, (rY_5 * 4 + 2) % 9 + 1))
                    if math.abs((vector.angle(mc, md, me))) - math.abs((vector.angle(md, mc, me))) == 0 then
                        l6 = "#6ec1ff"
                    else
                        rY_1 = "#6ec1ff"
                    end
                    rY_5 = (rY_5 + 11) % 72
                else
                    if (rY_5 * 3 + 9) * 17 % 4 == ((rY_5 * 3 + 9) * 17 + 8) % 4 then
                        lv = "#e8a34d"
                    else
                        l5 = "#e8a34d"
                    end
                    rY_5 = (rY_5 + 56) % 72
                end
            else
                local s3 = bit32.rrotate(bit32.bxor(bit32.lrotate(rY_5, 24), string.byte(tostring(lr))), 22)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(s3, 2409626981), 2203875018), (bit32.bxor(bit32.band(s3, 1885340314), 2206639211))), 2203875018), 2206639211) == s3 then
                    l5 = "#8b93a3"
                else
                    lv = "#8b93a3"
                end
                rY_5 = (rY_5 + 2) % 72
            end
        elseif l7 <= 4 then
            mc = (vector.create((rY_5 * 5 + 1) % 11 + 1, (rY_5 * 8 + 5) % 13 + 1, (rY_5 * 8 + 14) % 17 + 1))
            md = (vector.create((rY_5 * 3 + 4) % 11 + 1, (rY_5 * 2 + 6) % 13 + 1, (rY_5 * 1 + 7) % 17 + 1))
            me = (vector.create((rY_5 * 7 + 1) % 11 + 1, (rY_5 * 7 + 10) % 13 + 1, (rY_5 * 9 + 17) % 17 + 1))
            mf = (vector.create((rY_5 * 5 + 4) % 5 + 1, (rY_5 * 4 + 5) % 7 + 1, (rY_5 * 3 + 3) % 9 + 1))
            if vector.dot(vector.cross(mc, (vector.cross(md, me))), mf) == vector.dot(md * vector.dot(mc, me) - me * vector.dot(mc, md), mf) + 2 then
                l4 = "Unknown"
                pcall(fn699)
                lv = Label.Info:AddLeftGroupbox("Account", "circle-user")
                lv:AddLabel(lr("User", lW.Name, l9), true)
                lv:AddLabel(lr("Status", "Keyless", l9), true)
                lv:AddLabel(lr("Executor", "Unknown", l9), true)
                l6 = Label.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                l6:AddLabel(LocalPlayer(rY_2 .. " [" .. tostring(game.PlaceId) .. "]", lK), true)
                l6:AddLabel(lr("Place ID", tostring(game.PlaceId), lK), true)
                l8 = l6:AddLabel(lr("Session time", "0s", mb), true)
            else
                lr = "Unknown"
                pcall(fn699)
                rY_2 = l8.Info:AddLeftGroupbox("Account", "circle-user")
                rY_2:AddLabel(lK("User", LocalPlayer.Name, mb), true)
                rY_2:AddLabel(lK("Status", "Keyless", mb), true)
                rY_2:AddLabel(lK("Executor", lr, mb), true)
                l4 = l8.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                l4:AddLabel(lW(l9 .. " [" .. tostring(game.PlaceId) .. "]", l6), true)
                l4:AddLabel(lK("Place ID", tostring(game.PlaceId), l6), true)
                Label = l4:AddLabel(lK("Session time", "0s", lv), true)
            end
            rY_5 = (rY_5 + 38) % 72
        else
            mc = (vector.create((rY_5 * 4 + 4) % 11 + 1, (rY_5 * 6 + 5) % 13 + 1, (rY_5 * 7 + 5) % 17 + 1))
            md = (vector.create((rY_5 * 3 + 6) % 11 + 1, (rY_5 * 2 + 2) % 13 + 1, (rY_5 * 4 + 4) % 17 + 1))
            local s4 = vector.dot(mc, md)
            if s4 * s4 >= vector.dot(mc, mc) * vector.dot(md, md) + 1 then
                l4 = tostring(game.JobId)
            else
                kY = tostring(game.JobId)
            end
            rY_5 = (rY_5 + 65) % 72
        end
    elseif l7 <= 7 then
        if l7 <= 6 then
            mc = {
                "vwlyuqu",
                "rbkwcmlx",
                "uupzybcw",
                "xelngknz",
                "nguhogn",
                "kcxhep",
                "plpddabm",
                "oseudgidatt",
                "oirfdaz",
                "gudeqre"
            }
            local sy = rY_5
            md = mc[sy % 10 + 1]
            if md:len() >= md:gsub("(.)", "%1%1", sy % 3 % 2 + 1):len() then
                kY = #rY_1 > 18
            else
                rY_1 = #kY > 18
            end
            rY_5 = (rY_5 + 20) % 72
        else
            if (rY_5 * 2 + 1) * 4 % 3 == ((rY_5 * 2 + 1) * 4 + 3) % 3 then
                lW = fn107
            else
                kY = fn107
            end
            rY_5 = (rY_5 + 2) % 72
        end
    elseif l7 <= 8 then
        l7 = (vector.create((rY_5 * 7 + 3) % 11 + 1, (rY_5 * 5 + 3) % 13 + 1, (rY_5 * 7 + 6) % 17 + 1))
        mc = (vector.create((rY_5 * 1 + 4) % 11 + 1, (rY_5 * 7 + 4) % 13 + 1, (rY_5 * 12 + 9) % 17 + 1))
        md = (vector.create((rY_5 * 6 + 5) % 11 + 1, (rY_5 * 3 + 7) % 13 + 1, (rY_5 * 2 + 15) % 17 + 1))
        me = (vector.create((rY_5 * 7 + 8) % 11 + 1, (rY_5 * 6 + 10) % 13 + 1, (rY_5 * 15 + 16) % 17 + 1))
        if vector.dot(vector.cross(l7, mc), (vector.cross(md, me))) == vector.dot(l7, md) * vector.dot(mc, me) - vector.dot(l7, me) * vector.dot(mc, md) then
            lK = fn804
        else
            l6 = fn804
        end
        rY_5 = (rY_5 + 65) % 72
    else
        local sN = bit32.rrotate(bit32.bxor(bit32.lrotate(rY_5, 29), string.byte(tostring(Label))), 8)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(sN, 3961785519), 2215273464), (bit32.bxor(bit32.band(sN, 333181776), 3415671650))), 2215273464), 3415671650) == sN then
            mb = "#7fd47f"
        else
            kY = "#7fd47f"
        end
        rY_5 = (rY_5 + 20) % 72
    end
until (rY_5 * 35 + 25) % 72 == 70
if rY_1 then
    rY_2 = 3
    repeat
        rY_5 = (vector.create((rY_2 * 2 + 8) % 11 + 1, (rY_2 * 1 + 13) % 13 + 1, (rY_2 * 1 + 9) % 17 + 1))
        l7 = (vector.create((rY_2 * 3 + 3) % 11 + 1, (rY_2 * 5 + 4) % 13 + 1, (rY_2 * 11 + 7) % 17 + 1))
        mc = (vector.create((rY_2 * 5 + 4) % 11 + 1, (rY_2 * 5 + 8) % 13 + 1, (rY_2 * 5 + 17) % 17 + 1))
        if vector.dot(vector.cross(rY_5, l7), mc) == vector.dot(vector.cross(l7, mc), rY_5) then
            rY_1 = string.sub(kY, 1, 18) .. "..."
        else
            kY = string.sub(rY_1, 1, 18) .. "..."
        end
        rY_2 = (rY_2 + 3) % 4
    until (rY_2 * 3 + 2) % 4 == 0
end
rY_2 = rY_1 or kY
lU, li, le, lb, k7, k3, kZ, kV, DonationsGroup, CurrentCamera, ly, lx, connection, connection2, lZ, lR, lY, lg, k8, kT, lD, k_, ln, lp, kU, lX, ll = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
l7 = rY_2
l4:AddLabel(lK("Server", l7, l5), true)
l4:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
lU = os.clock()
task.spawn(worker)
local ScriptsGroup = l8.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(lW("Included in this hub", l5), true)
ScriptsGroup:AddLabel(lW(l9, l6), true)
local FeaturesGroup = l8.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(lW("Auto Charge", l6), true)
FeaturesGroup:AddLabel(lW("Auto Train", lv), true)
FeaturesGroup:AddLabel(lW("Auto Base", mb), true)
FeaturesGroup:AddLabel(lW("Auto Shop", l5), true)
local SocialsGroup = l8.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = lw })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = l8.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = lw })
li = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
le = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
lb = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
k7 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
k3 = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
kZ = ""
kV = ""
mc = "#345d9d"
rY_5 = "#f7931a"
local mv = "#627eea"
local mu = "#26a17b"
local mt = "#14f195"
local ms = "#0070ba"
local mr = "#008cff"
if ((not kU or not lZ) and (not lZ or false) or (false or not lZ or (not kU or false))) and ((mt or not kU or "#14f195") and (not lZ and not lZ and (lZ or false))) and not (((not kU or not lZ) and (not lZ or false) or (false or not lZ or (not kU or false))) and ((mt or not kU or "#14f195") and (not lZ and not lZ and (lZ or false)))) then
    l8 = DonationsGroup.Info:AddRightGroupbox("Donations", "heart")
else
    DonationsGroup = l8.Info:AddRightGroupbox("Donations", "heart")
end
DonationsGroup:AddLabel(lW("All donations are optional but appreciated.", lv), true)
DonationsGroup:AddLabel(lW("If you donate you get a special role, just PING after you donate.", mb), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(lW("LTC / Litecoin", mc), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(lW("BTC / Bitcoin", rY_5), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(lW("ETH / Ethereum", mv), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(lW("USDT", mu), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = fns.onCopyUSDTAddress })
DonationsGroup:AddLabel(lW("Solana", mt), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(lW("PayPal", ms), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(lW("Venmo", mr), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(lW("Don't have any of the listed currencies but still wanna donate?", l5), true)
DonationsGroup:AddLabel(lW("DM me and we'll work something out.", l6), true)
local FaqGroup = l8.Info:AddRightGroupbox("FAQ", "circle-help")
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
local ChargeGroup = l8.Main:AddLeftGroupbox("Charge", "zap")
ChargeGroup:AddToggle("AutoCharge", { Text = "Auto Charge", Default = false })
ChargeGroup:AddToggle("AutoSkip", { Text = "Auto Skip", Default = false })
mf = l8.Main:AddLeftGroupbox("Strength", "dumbbell")
mf:AddToggle("AutoUseWeights", { Text = "Auto Use Weights", Default = false })
mf:AddToggle("Auto2x", { Text = "Auto 2x", Default = false })
mf:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
mf:AddToggle("AutoBuyWeights", { Text = "Auto Buy Weights", Default = false })
md = l8.Main:AddRightGroupbox("Base", "house")
md:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
md:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
md:AddToggle("AutoUpgradeBase", { Text = "Auto Upgrade Base", Default = false })
rY_1 = l8.Main:AddRightGroupbox("Cosmetics", "sparkles")
rY_1:AddToggle("AutoEquipBestAura", { Text = "Auto Equip Best Owned Aura", Default = false })
rY_1:AddToggle("AutoBuyTails", { Text = "Auto Buy Tails", Default = false })
lZ = fn537
lR = fn639
task.spawn(fns.worker2)
task.spawn(worker3)
lY = fn731
task.spawn(worker4)
task.spawn(worker5)
task.spawn(fns.worker6)
lg = fn650
k8 = fn326
kT = fn953
lD = function()
    if lV() then
        return
    end
    local pp = lg()
    local po = kT()
    if not po then
        lz(StrengthSystemRemote, "EquipTrainingTool", { weightId = pp })
        return
    end
    local pq = la()
    local pn = k2()
    if pq and pn and po.Parent ~= pq then
        pcall(function()
            pn:EquipTool(po)
        end)
    end
    local pq_1 = po:GetAttribute("WeightId") or pp
    lz(StrengthSystemRemote, "Train", { weightId = tostring(pq_1) })
end
task.spawn(worker7)
StrengthSystemRemote.OnClientEvent:Connect(onOnClientEvent2)
task.spawn(fns.worker8)
task.spawn(worker9)
task.spawn(worker10)
local MovementGroup = l8.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = l8.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
RunService.Stepped:Connect(fns.onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn517)
Toggles.WalkSpeedEnabled:OnChanged(fn695)
k_ = function(fT)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not fT)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not fT
        end
    end)
    if not fT then
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
Toggles.AntiGameplayPause:OnChanged(fn545)
task.spawn(antiGameplayPauseLoop)
local MenuGroup = l8.Settings:AddLeftGroupbox("Menu", "menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
ly = tick()
lx = tick()
pcall(function()
    for k, v in getconnections(LocalPlayer.Idled) do
        local qU = v
        pcall(function()
            qU:Disable()
        end)
    end
end)
ln = fn257
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
task.spawn(antiAfkLoop)
Library:OnUnload(fn83)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Linoria")
ThemeManager:ApplyToTab(l8.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/BeMonkeyForBrainrots")
local mj = SaveManager:BuildConfigSection(l8.Settings)
lp = fn957
kU = fn653
lX = fn281
ll = function(gY)
    local rB
    rB = nil
    local rC = type(gY) ~= "table" or type(gY.idx) ~= "string" or type(gY.type) ~= "string" or SaveManager.Ignore[gY.idx]
    if rC then
        return false
    end
    rB = lp(gY.type, gY.idx)
    if not rB then
        return false
    end
    local rC_1 = pcall(function()
        if gY.type == "Input" then
            if type(gY.text) ~= "string" then
                return
            end
            rB:SetValue(gY.text)
        elseif gY.type == "ColorPicker" then
            rB:SetValueRGB(Color3.fromHex(gY.value), gY.transparency)
        elseif gY.type == "KeyPicker" then
            rB:SetValue({ gY.key, gY.mode, gY.modifiers })
            if gY.mode == "Toggle" and gY.toggled ~= nil then
                rB.Toggled = gY.toggled
                rB:Update()
            end
        else
            rB:SetValue(gY.value)
        end
    end)
    return rC_1
end
mj:AddDivider()
mj:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
mj:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
mj:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
end)(...)

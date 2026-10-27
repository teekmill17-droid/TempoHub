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
getgenv().TempoHoodSubtitle = "+1 LONG ARM TOY ESCAPE!"
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
local ms
local Toggles
local my
local mU
local mB
local mX
local mi
local m_
local mH
local m2
local l2
local mK
local l5
local mN
local l8
local mQ
local mx
local mT
local mA
local mW
local mh
local mZ
local mn
local mJ
local l4
local mM
local ma
local mw
local mS
local md
local mg
local mC
local mj
local mp
local function fn95()
    if not my("AutoRebirth") then
        return
    end
    if tick() - mJ < 2 then
        return
    end
    local pM = mA()
    if not l4.IsRebirthAvailable(pM) then
        return
    end
    if mN() < l4.RebirthLevel(pM) then
        return
    end
    mJ = tick()
    pcall(function()
        mB:FireServer()
    end)
end
local function fn155(aw)
    if aw then
        m2[#m2 + 1] = aw
    end
    return aw
end
local function fn156(bM)
    local oK = not bM or not bM.Parent or not bM:IsA("BasePart")
    if oK then
        return false
    end
    local oK_1 = mS()
    if oK_1 and (oK_1.Position - bM.Position).Magnitude > 60 then
        mZ(bM.Position, 2)
    end
    local oK_2 = m_(bM)
    if not oK_2 then
        return false
    end
    return mn(oK_2)
end
local function fn248()
    local Character = mM.Character
    local n8 = Character and Character:FindFirstChild("HumanoidRootPart")
    return n8
end
local function fn272(c5)
    return mM:GetAttribute(mW.UnlockedAttribute(c5)) == true
end
local function fn282()
    local Character = mM.Character
    if mX then
        if mX.ArmController and mX.Character == Character and Character and Character.Parent then
            return mX
        end
        if filtergc then
            mX = filtergc("table", { Keys = { "RequestedWhileInside", "ArmController" } }, true)
        end
        return mX
    end
    if filtergc then
        mX = filtergc("table", { Keys = { "RequestedWhileInside", "ArmController" } }, true)
    end
    return mX
end
local function fn295(bC)
    local oE = l8()
    local oF = mS()
    if not bC or not oE or not oF then
        return nil
    end
    local oG_2 = bC.Parent and bC.Parent:FindFirstChild("Like")
    local oH_1 = oG_2 or bC
    local oG_4 = oH_1.Position.Y + oH_1.Size.Y * 0.5 + oE.HipHeight + oF.Size.Y * 0.5 + 0.2
    return CFrame.new(bC.Position.X, oG_4, bC.Position.Z)
end
local function fn325()
    return ms("Rebirths")
end
local function fn364(aG)
    if mg.Unloaded then
        return false
    end
    local nW = Toggles[aG]
    return nW ~= nil and nW.Value == true
end
local function fn388(cF)
    l5()
    local pe
    local pf
    for k, v in mQ:GetTagged("WinBox") do
        local pg_1 = v:IsA("BasePart") and v:IsDescendantOf(mU) and v:GetAttribute("StageNumber") == cF
        if pg_1 then
            if v:GetAttribute("IsDouble") == true then
                pf = v
            else
                pe = v
            end
        end
    end
    if mw and pf then
        return pf
    end
    return pe or pf
end
local function fn436(a6)
    local Character = mM.Character
    local oi = Character and Character:FindFirstChild("HumanoidRootPart")
    local oj = not Character or not oi
    local op = if oj then 1 else 0
    local on = 1226 * op + 741 * (1 - op)
    local oo = 707 * op + 45 * (1 - op)
    if not ((on * 1709 + oo * 3560 + on * oo) % 16777213 == 5478936) then
        oj = typeof(a6) ~= "CFrame"
    end
    if oj then
        return false
    end
    Character:PivotTo(a6)
    oi.AssemblyLinearVelocity = Vector3.zero
    oi.AssemblyAngularVelocity = Vector3.zero
    return true
end
local function fn459()
    ma(mx, "Copied Discord invite to clipboard")
end
local function fn460(az, aA)
    if setclipboard then
        setclipboard(az)
    elseif toclipboard then
        toclipboard(az)
    end
    mg:Notify(aA)
end
local function fn493(cQ)
    for k, v in mQ:GetTagged("StretchPad") do
        local po_1 = v:IsA("BasePart") and v:IsDescendantOf(mU) and v:GetAttribute("PadId") == cQ
        if po_1 then
            return v
        end
    end
    local Generated = mU:FindFirstChild("Generated")
    local pp = Generated and Generated:FindFirstChild("Progression")
    local po_3 = pp
    if pp then
        pp = po_3:FindFirstChild("HomeBase")
    end
    local po_4 = pp
    if pp then
        pp = po_4:FindFirstChild("StretchPads")
    end
    local po_5 = pp
    if pp then
        pp = po_5:FindFirstChild(cQ)
    end
    local po_6 = pp
    if pp then
        pp = po_6:FindFirstChild("Pad")
    end
    local po_7 = pp
    if pp then
        pp = po_7:IsA("BasePart")
    end
    if pp then
        return po_7
    end
    return nil
end
local function fn571()
    local o9_1
    local o8_1
    if mi <= 0 then
        mw = false
        return
    end
    if tick() - mp < 20 then
        return
    end
    mp = tick()
    o8_1, o9_1 = pcall(function()
        return mj:UserOwnsGamePassAsync(mM.UserId, mi)
    end)
    if o8_1 then
        mw = o9_1 == true
    end
end
local function fn595()
    return ms("Level")
end
local function fn621()
    return ms("Wins")
end
local function fn643(aU)
    local leaderstats = mM:FindFirstChild("leaderstats")
    local ob = leaderstats and leaderstats:FindFirstChild(aU)
    local oa_1 = ob
    if ob then
        local oc = tonumber(oa_1.Value) or 0
        ob = oc
    end
    local oa_2 = ob
    local og = if oa_2 then 1 else 0
    local oe = 23 * og + 2750 * (1 - og)
    local of = 2251 * og + 1389 * (1 - og)
    if not ((oe * 3368 + of * 3873 + oe * of) % 16777213 == 8847360) then
        oa_2 = 0
    end
    return oa_2
end
local function fn649()
    local WinPlate = l2.WinPlate
    local pc = WinPlate and WinPlate.Value
    if type(pc) == "string" then
        local pc_1 = tonumber(pc:match("%d+"))
        if pc_1 then
            return pc_1
        end
        return 1
    end
    return 1
end
local function fn661(ee)
    local DiscordGroup = ee:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = mT })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = mT })
end
local function worker()
    while not mg.Unloaded do
        pcall(mh)
        pcall(mH)
        pcall(md)
        task.wait(0.15)
    end
end
local function fn823()
    local Character = mM.Character
    local n2 = Character and Character:FindFirstChildOfClass("Humanoid")
    return n2
end
l2 = nil
l4 = nil
l5 = nil
Toggles = nil
l8 = nil
ma = nil
md = nil
mg = nil
mh = nil
mi = nil
mj = nil
local mm
mn = nil
mp = nil
ms = nil
mw = nil
mx = nil
my = nil
mA = nil
mB = nil
mC = nil
mH = nil
mJ = nil
mK = nil
mM = nil
mN = nil
local l1, l3, l7, l9, SaveManager, mc, me, mf, mk, ml, mo, mq, mr, StretchPadEvent, mu, mv, mz, mD, mE, mF, mG, WinCollectRequestEvent, mL, ZoneVolume
mQ = nil
mS = nil
mT = nil
mU = nil
mW = nil
mX = nil
mZ = nil
m_ = nil
m2 = nil
local mP, mV, mY, m0, m1
local m8_1
local PlayerGui, StageConfig
local ContentReleaseConfig
local m6_1
local nn = if not game:IsLoaded() then 1 else 0
if nn == 1 then
    game.Loaded:Wait()
end
local function m3(c)
    return c
end
local m3_4
local m4 = cloneref or m3
local m4_1, m4_2
m6_1, mQ, mK, mD, mv, mq, mj, me, m8_1, l9, l3, l1, m0, mU, mM, PlayerGui = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local m5 = 43
local m5_3
repeat
    local m3_1 = (m5 * 9 + 4) % 10 + 1
    if m3_1 <= 5 then
        if m3_1 <= 3 then
            if m3_1 <= 2 then
                if m3_1 <= 1 then
                    local m9_1 = {
                        "bvujz",
                        "xwxvnku",
                        "cdwomnndlwc",
                        "ojwklnvh",
                        "fksh",
                        "yenq",
                        "eaozkeod",
                        "mbipxyd",
                        "hbeqrnmqmz"
                    }
                    local tc = m5
                    local na_1 = m9_1[tc % 9 + 1]
                    if na_1:len() >= na_1:gsub("(.)", "%1%1", tc % 3 % 2 + 1):len() then
                        mM = PlayerGui:WaitForChild("PlayerGui")
                    else
                        PlayerGui = mM:WaitForChild("PlayerGui")
                    end
                    m5 = (m5 + 69) % 80
                else
                    local m9_2 = {
                        "gkcedoebb",
                        "uhlzms",
                        "qff",
                        "mtvvtviqcu",
                        "jiiafgli",
                        "tvglmcpuwvxo",
                        "ycyhsazjtmw",
                        "fbtm",
                        "sfsa",
                        "psj",
                        "hvmhobx",
                        "ropt",
                        "qrxki"
                    }
                    if m9_2[(m5 * 6 + 5) % 13 + 1] <= m9_2[(m5 * 6 + 5) % 13 + 1] then
                        m6_1 = m4
                    else
                        m4 = m6_1
                    end
                    m5 = (m5 + 79) % 80
                end
            else
                local uA = bit32.rrotate(bit32.bxor(bit32.lrotate(m5, 5), string.byte(tostring(mD))), 16)
                if bit32.bxor(bit32.lrotate(bit32.bxor(uA, 1978080995), 30), 3715745720) ~= bit32.lrotate(uA, 30) then
                    m6_1 = mQ(game:GetService("CollectionService"))
                else
                    mQ = m6_1(game:GetService("CollectionService"))
                end
                m5 = (m5 + 9) % 80
            end
        elseif m3_1 <= 4 then
            local un = bit32.rrotate(bit32.bxor(bit32.lrotate(m5, 8), string.byte(tostring(mD))), 6)
            if bit32.bxor(bit32.lrotate(bit32.bxor(un, 2366053235), 18), 1842230300) == bit32.lrotate(un, 18) then
                mK = m6_1(game:GetService("CoreGui"))
            else
                m6_1 = mK(game:GetService("CoreGui"))
            end
            m5 = (m5 + 49) % 80
        else
            local tO = bit32.rrotate(bit32.bxor(bit32.lrotate(m5, 10), string.byte(tostring(mD))), 7)
            if bit32.bxor(bit32.lrotate(bit32.bxor(tO, 1330382918), 0), 1330382918) ~= bit32.lrotate(tO, 0) then
                mj = mD(game:GetService("GuiService"))
                mq = mD(game:GetService("HttpService"))
                mv = mD(game:GetService("Lighting"))
                m6_1 = mD(game:GetService("MarketplaceService"))
            else
                mD = m6_1(game:GetService("GuiService"))
                mv = m6_1(game:GetService("HttpService"))
                mq = m6_1(game:GetService("Lighting"))
                mj = m6_1(game:GetService("MarketplaceService"))
            end
            m5 = (m5 + 9) % 80
        end
    elseif m3_1 <= 8 then
        if m3_1 <= 7 then
            if m3_1 <= 6 then
                local m9_3 = (vector.create((m5 * 1 + 8) % 11 + 1, (m5 * 1 + 13) % 13 + 1, (m5 * 8 + 13) % 17 + 1))
                local na_2 = (vector.create((m5 * 1 + 7) % 11 + 1, (m5 * 9 + 1) % 13 + 1, (m5 * 4 + 12) % 17 + 1))
                local um = vector.dot(m9_3, na_2)
                if um * um <= vector.dot(m9_3, m9_3) * vector.dot(na_2, na_2) then
                    me = m6_1(game:GetService("Players"))
                else
                    m6_1 = me(game:GetService("Players"))
                end
                m5 = (m5 + 39) % 80
            else
                local ub = bit32.rrotate(bit32.bxor(bit32.lrotate(m5, 3), string.byte(tostring(m8_1))), 21)
                if bit32.bxor(bit32.lrotate(bit32.bxor(ub, 881713635), 28), 860413470) ~= bit32.lrotate(ub, 28) then
                    m6_1 = l9(game:GetService("ReplicatedStorage"))
                    l3 = l9(game:GetService("RunService"))
                    m8_1 = l9(game:GetService("TeleportService"))
                else
                    m8_1 = m6_1(game:GetService("ReplicatedStorage"))
                    l9 = m6_1(game:GetService("RunService"))
                    l3 = m6_1(game:GetService("TeleportService"))
                end
                m5 = (m5 + 9) % 80
            end
        else
            local uB = bit32.rrotate(bit32.bxor(bit32.lrotate(m5, 1), string.byte(tostring(l9))), 18)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(uB, 66891473), 234034058), (bit32.bxor(bit32.band(uB, 4228075822), 1503052201))), 234034058), 1503052201) == uB then
                l1 = m6_1(game:GetService("UserInputService"))
                m0 = m6_1(game:GetService("VirtualUser"))
            else
                m0 = l1(game:GetService("UserInputService"))
                m6_1 = l1(game:GetService("VirtualUser"))
            end
            m5 = (m5 + 59) % 80
        end
    elseif m3_1 <= 9 then
        local td = bit32.rrotate(bit32.bxor(bit32.lrotate(m5, 8), string.byte(tostring(mU))), 17)
        if bit32.bxor(bit32.lrotate(bit32.bxor(td, 2875628067), 2), 2912577678) ~= bit32.lrotate(td, 2) then
            m6_1 = mU(game:GetService("Workspace"))
        else
            mU = m6_1(game:GetService("Workspace"))
        end
        m5 = (m5 + 29) % 80
    else
        local m3_2 = (vector.create((m5 * 7 + 2) % 11 + 1, (m5 * 11 + 7) % 13 + 1, (m5 * 6 + 17) % 17 + 1))
        local m9_4 = (vector.create((m5 * 3 + 4) % 11 + 1, (m5 * 7 + 4) % 13 + 1, (m5 * 2 + 11) % 17 + 1))
        local na_3 = (vector.create((m5 * 7 + 3) % 11 + 1, (m5 * 8 + 4) % 13 + 1, (m5 * 13 + 5) % 17 + 1))
        local nb_1 = (vector.create((m5 * 5 + 6) % 11 + 1, (m5 * 4 + 10) % 13 + 1, (m5 * 12 + 3) % 17 + 1))
        if vector.dot(vector.cross(m3_2, m9_4), (vector.cross(na_3, nb_1))) == vector.dot(m3_2, na_3) * vector.dot(m9_4, nb_1) - vector.dot(m3_2, nb_1) * vector.dot(m9_4, na_3) then
            mM = me.LocalPlayer
        else
            me = mM.LocalPlayer
        end
        m5 = (m5 + 59) % 80
    end
until (m5 * 53 + 16) % 80 == 25
if setthreadidentity then
    setthreadidentity(8)
end
mC = function()
    return mK
end
if getgenv then
    mm, m4_1 = nil, nil
    local m3_3 = 4
    repeat
        if (m3_3 * 1 + 0) % 2 + 1 <= 1 then
            local m5_2 = (vector.create((m3_3 * 5 + 1) % 11 + 1, (m3_3 * 7 + 13) % 13 + 1, (m3_3 * 12 + 2) % 17 + 1))
            local m6_2 = (vector.create((m3_3 * 4 + 8) % 11 + 1, (m3_3 * 6 + 1) % 13 + 1, (m3_3 * 6 + 16) % 17 + 1))
            local m9_5 = (vector.create((m3_3 * 1 + 6) % 5 + 1, (m3_3 * 1 + 1) % 7 + 1, (m3_3 * 3 + 4) % 9 + 1))
            if math.abs((vector.angle(m5_2, m6_2, m9_5))) - math.abs((vector.angle(m6_2, m5_2, m9_5))) == 1 then
                getgenv().gethui = mm
                mC = getgenv().__TempoLongArmToyEscapeLib
            else
                getgenv().gethui = mC
                mm = getgenv().__TempoLongArmToyEscapeLib
            end
            m3_3 = (m3_3 + 3) % 8
        else
            if (m3_3 * 3 + 6) * 13 % 4 == ((m3_3 * 3 + 6) * 13 + 8) % 4 then
                m4_1 = mm
            else
                mm = m4_1
            end
            m3_3 = (m3_3 + 1) % 8
        end
    until (m3_3 * 5 + 7) % 8 == 7
    if m4_1 then
        m4_1 = mm.Unload
    end
    if m4_1 then
        pcall(function()
            mm:Unload()
        end)
    end
end
pcall(function()
    gethui = mC
end)
for k, v in { mK, PlayerGui } do
    for k, v2 in { "Obsidian", "ObsidianLoading" } do
        local mR = v:FindFirstChild(v2)
        while mR do
            pcall(function()
                mR:Destroy()
            end)
            mR = v:FindFirstChild(v2)
        end
    end
end
mG, mx, mr, ml, m5_3, m4_2, m3_4, l4, ContentReleaseConfig, StageConfig, mW, ZoneVolume, WinCollectRequestEvent, mB, StretchPadEvent = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local m6_3 = 48
repeat
    local na_4 = (m6_3 * 4 + 7) % 9 + 1
    if na_4 <= 5 then
        if na_4 <= 3 then
            if na_4 <= 2 then
                if na_4 <= 1 then
                    local tA = bit32.rrotate(bit32.bxor(bit32.lrotate(m6_3, 12), string.byte(tostring(StretchPadEvent))), 15)
                    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(tA, 3781946303), 2818920001), (bit32.bxor(bit32.band(tA, 513020992), 1752490552))), 2818920001), 1752490552) ~= tA then
                        m3_4 = require(StretchPadEvent:WaitForChild("RebirthRequestEvent"))
                        mB = require(StretchPadEvent:WaitForChild("StretchPadEvent"))
                    else
                        mB = require(m3_4:WaitForChild("RebirthRequestEvent"))
                        StretchPadEvent = require(m3_4:WaitForChild("StretchPadEvent"))
                    end
                    m6_3 = (m6_3 + 52) % 72
                else
                    if (m6_3 * 3 + 1) * 9 % 4 == ((m6_3 * 3 + 1) * 9 + 14) % 4 then
                        mr = "+1 Long Arm Toy Escape!"
                        mG = "https://discord.gg/K7Qxnxkk46"
                        mx = "https://discord.gg/K7Qxnxkk46"
                    else
                        mG = "+1 Long Arm Toy Escape!"
                        mx = "https://discord.gg/K7Qxnxkk46"
                        mr = "https://discord.gg/K7Qxnxkk46"
                    end
                    m6_3 = (m6_3 + 16) % 72
                end
            else
                if (m6_3 * 2 + 1) * 4 % 3 == ((m6_3 * 2 + 1) * 4 + 4) % 3 then
                    mG = "https://tempohub.shop"
                else
                    ml = "https://tempohub.shop"
                end
                m6_3 = (m6_3 + 16) % 72
            end
        elseif na_4 <= 4 then
            if m6_3 * 52542141 + 6 + 3 <= m6_3 * 52542141 + 6 + 3 + 3 then
                m5_3 = m8_1:WaitForChild("Shared")
            else
                m8_1 = m5_3:WaitForChild("Shared")
            end
            m6_3 = (m6_3 + 25) % 72
        else
            local nb_2 = {
                "iin",
                "phlgpilxvo",
                "qvhkhbqj",
                "gunudshib",
                "ihwx",
                "twhk",
                "pvrkx",
                "mcclaiibxhj",
                "wzgy",
                "jil",
                "gevwhptuz"
            }
            if nb_2[(m6_3 * 30 + 72) % 11 + 1] < nb_2[(m6_3 * 30 + 72) % 11 + 1] then
                m5_3 = m4_2:WaitForChild("Config")
            else
                m4_2 = m5_3:WaitForChild("Config")
            end
            m6_3 = (m6_3 + 61) % 72
        end
    elseif na_4 <= 7 then
        if na_4 <= 6 then
            local nb_3 = { "egkjiw", "vewchlznd", "mqtlquszgua", "npleyakbwdw", "vhhnrexmq", "kbdpwlyrbz", "zjhesyzczd" }
            local tb = m6_3
            local nc_1 = nb_3[tb % 7 + 1]
            if nc_1:len() >= nc_1:reverse():rep(tb % 3 + 2):len() then
                m5_3 = m3_4:WaitForChild("Events")
            else
                m3_4 = m5_3:WaitForChild("Events")
            end
            m6_3 = (m6_3 + 34) % 72
        else
            if (m6_3 * 2 + 7) * 10 % 3 == ((m6_3 * 2 + 7) * 10 + 7) % 3 then
                m4_2 = require(ContentReleaseConfig:WaitForChild("ArmProgressionConfig"))
                l4 = require(ContentReleaseConfig:WaitForChild("ContentReleaseConfig"))
            else
                l4 = require(m4_2:WaitForChild("ArmProgressionConfig"))
                ContentReleaseConfig = require(m4_2:WaitForChild("ContentReleaseConfig"))
            end
            m6_3 = (m6_3 + 34) % 72
        end
    elseif na_4 <= 8 then
        local na_5 = { "exjuypqf", "fuyd", "jausprgvo", "xwqo", "ordnfrfac", "sgohsmrul", "matqpd" }
        local uz = m6_3
        local nb_4 = na_5[uz % 7 + 1]
        if nb_4:len() >= nb_4:gsub("(.)", "%1%1", uz % 3 % 2 + 1):len() then
            m4_2 = require(StageConfig:WaitForChild("StageConfig"))
        else
            StageConfig = require(m4_2:WaitForChild("StageConfig"))
        end
        m6_3 = (m6_3 + 70) % 72
    else
        local na_6 = {
            "dodereq",
            "zeskdm",
            "vskhdmbwvm",
            "icemixmwkh",
            "ouj",
            "soucgei",
            "ptureoz",
            "dufmnfk",
            "qhsombw"
        }
        local ti = m6_3
        local nb_5 = na_6[ti % 9 + 1]
        if nb_5:len() >= nb_5:gsub("(.)", "%1%1", ti % 3 % 2 + 1):len() then
            m5_3 = require(WinCollectRequestEvent:WaitForChild("StretchPadConfig"))
            mW = require(ZoneVolume:WaitForChild("ZoneVolume"))
            m3_4 = require(m4_2:WaitForChild("WinCollectRequestEvent"))
        else
            mW = require(m4_2:WaitForChild("StretchPadConfig"))
            ZoneVolume = require(m5_3:WaitForChild("ZoneVolume"))
            WinCollectRequestEvent = require(m3_4:WaitForChild("WinCollectRequestEvent"))
        end
        m6_3 = (m6_3 + 70) % 72
    end
until (m6_3 * 43 + 60) % 72 == 18
local m3_5 = tonumber(StageConfig.TouchCooldown) or 1
mo = m3_5
local m3_6 = tonumber(StageConfig.DoubleWinsGamepassId) or 0
local m4_3 = {}
mi = m3_6
local m3_7 = {}
for k, v in mQ:GetTagged("WinBox") do
    local attr = v:GetAttribute("StageNumber")
    local m6_4 = type(attr) == "number" and not m3_7[attr]
    if m6_4 then
        m3_7[attr] = true
        m4_3[#m4_3 + 1] = attr
    end
end
table.sort(m4_3)
if #m4_3 == 0 then
    local attr = mU:GetAttribute(ContentReleaseConfig.ReleasedStageCountAttribute)
    local m5_5 = type(attr) == "number" and attr
    local m5_6 = m5_5 or ContentReleaseConfig.BaseReleasedStageCount or 11
    local nG = 1
    while nG <= m5_6 do
        local nH = nG
        m4_3[nH] = nH
        nG += 1
    end
end
for k, v in m4_3 do
    m4_3[k] = "Stage " .. v
end
mg, SaveManager = nil, nil
mg = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
if getgenv then
    getgenv().__TempoLongArmToyEscapeLib = mg
end
Toggles, l2, m2, mX, mP, mJ, mF, mw, mp, mE, mk, ma, mT, my, l8, mS, ms, m1, mN, mA, mn, mZ, mu, m_, l7, mf, mV, l5, mc, mL, mY, mz, md, mh, mH = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Toggles = mg.Toggles
if ((m1 or not l5 or (m1 or not mf)) and (mf or mN or (not l7 or mL)) and ((mL and not m1 or (m1 or l7)) and (not mf and mN and (not l5 and l7))) or (mf or mf or (mN or not m1) or (not l7 or not mL) and (m1 and m1)) and ((not m1 or l7 or (not mN or mL)) and (not l5 and not l5 or (l5 or l5)))) and not ((m1 or not l5 or (m1 or not mf)) and (mf or mN or (not l7 or mL)) and ((mL and not m1 or (m1 or l7)) and (not mf and mN and (not l5 and l7))) or (mf or mf or (mN or not m1) or (not l7 or not mL) and (m1 and m1)) and ((not m1 or l7 or (not mN or mL)) and (not l5 and not l5 or (l5 or l5)))) then
    mg = m2.Options
    mP = {}
    l2 = 0
else
    l2 = mg.Options
    m2 = {}
    mP = 0
end
mJ = 0
mF = 0
mw = false
mp = 0
mk = fn155
ma = fn460
mT = fn459
my = fn364
l8 = fn823
mS = fn248
ms = fn643
m1 = fn621
if ((not my and not mz and (l2 or not l8) or not mz and not m_ and (my and not mz)) and ((mz or 138 or (my or not mz)) and (my and not l8 and (my or mz))) or ((not l8 or l2) and (not l8 or not l8) and ((m_ or 138) and l2) or not mz and false and (l8 or not m_) and (not my and m_ or (not my or l2)))) and not ((not my and not mz and (l2 or not l8) or not mz and not m_ and (my and not mz)) and ((mz or 138 or (my or not mz)) and (my and not l8 and (my or mz))) or ((not l8 or l2) and (not l8 or not l8) and ((m_ or 138) and l2) or not mz and false and (l8 or not m_) and (not my and m_ or (not my or l2)))) then
    mE = fn595
else
    mN = fn595
end
mA = fn325
mn = fn436
mZ = function(bd, be)
    local ou
    local ov = typeof(bd) ~= "Vector3"
    local oA = if ov then 1 else 0
    local oy = 3043 * oA + 397 * (1 - oA)
    local oz = 787 * oA + 255 * (1 - oA)
    if not ((oy * 3711 + oz * 3669 + oy * oz) % 16777213 == 16574917) then
        ov = not mU.StreamingEnabled
    end
    if ov then
        return
    end
    ou = false
    task.spawn(function()
        pcall(function()
            local oq = be or 5
            mM:RequestStreamAroundAsync(bd, oq)
        end)
        ou = true
    end)
    local ov_1 = os.clock()
    local ov_2 = ov_1 + (be or 5) + 0.25
    while true do
        local ow_1 = not ou and os.clock() < ov_2 and not mg.Unloaded
        if ow_1 then
            task.wait()
            continue
        end
        break
    end
end
mu = function(bu)
    local oB = mS()
    local oC = not oB or not bu or not bu.Parent or not bu:IsA("BasePart")
    if oC then
        return false
    elseif firetouchinterest then
        local oC_1 = pcall(function()
            firetouchinterest(oB, bu, 0)
            firetouchinterest(oB, bu, 1)
        end)
        return oC_1
    else
        return false
    end
end
m_ = fn295
l7 = fn156
mf = fn282
mV = function()
    local o_ = l8()
    if o_ then
        o_.PlatformStand = false
        o_.Sit = false
        pcall(function()
            o_:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end
    local o1 = mf()
    local oY = o1 and o1.ArmController
    if oY then
        pcall(function()
            oY.LeftArm:SetLatchedContact(nil)
            oY.RightArm:SetLatchedContact(nil)
        end)
        pcall(function()
            oY:ForceUnlatch()
        end)
        pcall(function()
            oY.GroundArmWalker:Clear(false)
        end)
        local CharacterControllerManager = oY.CharacterControllerManager
        if CharacterControllerManager then
            pcall(function()
                CharacterControllerManager:SetActiveController("Ground")
            end)
        end
    end
    local Character = mM.Character
    local o3 = Character and Character:FindFirstChild("CharacterControllerManager")
    local o0 = o3
    local o2_2 = o0 and o0:FindFirstChild("GroundController")
    local oZ = o2_2
    if o0 and oZ then
        pcall(function()
            o0.ActiveController = oZ
        end)
    end
    local o2_4 = o1 and type(o1.RequestedWhileInside) == "table"
    if o2_4 then
        table.clear(o1.RequestedWhileInside)
    end
    return oY
end
l5 = fn571
mc = fn649
if (mN and not mS or (not mN or mS) or (mN and false or mS and mu)) and ((mN or not mN or (mu or mu)) and (false or mN and false)) and not ((mN and not mS or (not mN or mS) or (mN and false or mS and mu)) and ((mN or not mN or (mu or mu)) and (false or mN and false))) then
    l2 = fn388
else
    mL = fn388
end
mY = fn493
mz = fn272
md = function()
    local pA, pB
    if not my("AutoFarmWins") then
        return
    end
    if tick() - mP < mo then
        return
    end
    pB = mL(mc())
    if not pB then
        return
    end
    local pC = pB.Parent and pB.Parent:FindFirstChild("Hitbox")
    mV()
    l7(pB)
    mV()
    task.wait(0.12)
    local pC_1 = mV()
    local pE = mS()
    if not pE then
        return
    end
    pA = pE.Position
    local pE_1 = pC and pC:IsA("BasePart") and not ZoneVolume.containsPoint(pC, pA)
    if pE_1 then
        pA = pC.Position
    end
    mP = tick()
    pcall(function()
        WinCollectRequestEvent:FireServer(pB, pA)
    end)
    mu(pB)
    local pE_2 = pC and pC:IsA("BasePart")
    if pE_2 then
        mu(pC)
    end
    local pD_1 = pC_1 and pC_1.CanCollectWinBox and not pC_1:CanCollectWinBox()
    if pD_1 then
        mV()
    end
end
mh = fn95
mH = function()
    if not my("AutoBuyLong") then
        return
    end
    if tick() - mF < 1.2 then
        return
    end
    local pQ = m1()
    local pP
    local pR = -1
    local pO
    for k, v in mW.Pads do
        if mz(v.Id) then
            local pS_1 = tonumber(v.SpeedPerTick) or 0
            if pS_1 > pR then
                pR = pS_1
                pP = v
            end
        else
            local pS_2 = not pO
            if pS_2 then
                local pT_2 = tonumber(v.WinsRequired) or math.huge
                pS_2 = pQ >= pT_2
            end
            if pS_2 then
                pO = v
            end
        end
    end
    if pO then
        mF = tick()
        local pQ_1 = mY(pO.Id)
        if pQ_1 then
            l7(pQ_1)
            mu(pQ_1)
        end
        pcall(function()
            StretchPadEvent:FireServer("Purchase", pO.Id)
        end)
        pcall(function()
            StretchPadEvent:FireServer("Unlock", pO.Id)
        end)
        pcall(function()
            StretchPadEvent:FireServer("Equip", pO.Id)
        end)
        return
    end
    local attr = mM:GetAttribute(mW.EquippedAttribute)
    if pP and pP.Id ~= attr then
        mF = tick()
        local pQ_3 = mY(pP.Id)
        if pQ_3 then
            l7(pQ_3)
            mu(pQ_3)
        end
        pcall(function()
            StretchPadEvent:FireServer("Equip", pP.Id)
        end)
    end
end
local Window = mg:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = mx, Copyable = true }, "|", mG },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    SidebarCompacted = true,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
Window:SetGlow(true, { Color = Color3.fromRGB(242, 154, 196), Radius = 24, Transparency = 0.3 })
mE = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gamepad-2"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in mE do
    if k ~= "Info" then
        fn661(v)
    end
end
local FarmGroup = mE.Main:AddLeftGroupbox("Farm", "trophy")
FarmGroup:AddToggle("AutoFarmWins", { Text = "Auto Farm Wins", Default = false })
local m3_10 = m4_3[1]
local nn_1 = if m3_10 then 1 else 0
local nl = 2994 * nn_1 + 1308 * (1 - nn_1)
local nm = 3735 * nn_1 + 2984 * (1 - nn_1)
if not ((nl * 1759 + nm * 796 + nl * nm) % 16777213 == 2644883) then
    m3_10 = "Stage 1"
end
local m7_4 = nil
FarmGroup:AddDropdown("WinPlate", { Text = "Win Plate", Values = m4_3, Default = m3_10 })
local AutomationGroup = mE.Main:AddRightGroupbox("Automation", "sparkles")
AutomationGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
AutomationGroup:AddToggle("AutoBuyLong", { Text = "Auto Buy Long", Default = false })
task.spawn(worker)
local function nd()
    local qK
    local qV
    local qR
    local qL
    local qU
    local qQ
    qK = nil
    qL = nil
    qQ = nil
    qR = nil
    qU = nil
    qV = nil
    local qM, qN, Label2, Label3, qS, Label
    qL = function(et, eu)
        return string.format('<font color="%s">%s</font>', eu, et)
    end
    qN = function(ew, ex, ey)
        return string.format("<b>%s</b> %s %s", ew, qL("-", "#5a6070"), qL(ex, ey))
    end
    qK = "#7fd47f"
    local qW = "#8b93a3"
    qU = "#e8a34d"
    qQ = "#e05a5a"
    local function qY()
        local p1 = hookfunction ~= nil
        local p2 = hookmetamethod ~= nil
        local p3 = getrawmetatable ~= nil
        local p4 = setrawmetatable ~= nil
        local p5 = getgc ~= nil
        local p6 = getgenv ~= nil
        local p7 = getreg ~= nil
        local p8 = getconnections ~= nil
        local p9 = firesignal ~= nil
        local qa = getcallbackvalue ~= nil
        local qb = setclipboard ~= nil
        local qc = getcustomasset ~= nil
        local qd = getnamecallmethod ~= nil
        local qe = isexecutorclosure ~= nil
        local qf = fireproximityprompt ~= nil
        local qg = firetouchinterest ~= nil
        local qh = WebSocket ~= nil
        local qi = readfile ~= nil
        local qj = writefile ~= nil
        local ql = (request or http_request) ~= nil
        local qn = (debug and debug.getupvalues) ~= nil
        local qp = (debug and debug.setupvalue) ~= nil
        local qq = 0
        local qr = { p1, p2, p3, p4, p5, p6, p7, p8, p9, qa, qb, qc, qd, qe, qf, qg, qh, qi, qj, ql, qn, qp }
        for i, v in ipairs(qr) do
            if v then
                qq += 1
            end
        end
        local p1_1 = qq / #qr
        if p1_1 >= 0.9 then
            return qL("Full Support", qK)
        elseif p1_1 >= 0.6 then
            return qL("Half Support", qU)
        else
            return qL("Low Support", qQ)
        end
    end
    qR = "Unknown"
    pcall(function()
        local qA_1
        local qz_1
        if identifyexecutor then
            qA_1, qz_1 = identifyexecutor()
            local qB = qA_1 ~= ""
            local qC = type(qA_1) == "string" and qB
            if qC then
                local qB_1 = type(qz_1) == "string" and qz_1 ~= "" and qA_1 .. " " .. qz_1
                qR = qB_1 or qA_1
            end
        end
    end)
    local qZ = qY()
    qV = os.clock()
    qM = function()
        local qE = math.floor(os.clock() - qV)
        if qE < 60 then
            return qE .. "s"
        elseif qE < 3600 then
            return string.format("%dm %ds", math.floor((qE) / (60)), qE % 60)
        else
            return string.format("%dh %dm", math.floor((qE) / (3600)), math.floor((qE % 3600) / (60)))
        end
    end
    local UserGroup = mE.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = mM, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(qN("User", mM.DisplayName .. " @" .. mM.Name, qK), true)
    UserGroup:AddLabel(qN("UserId", tostring(mM.UserId), "#6ec1ff"), true)
    UserGroup:AddLabel(qN("Executor", qR .. "  " .. qZ, qK), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(qN("Session", qM(), qU), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            ma(mM.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            ma("https://www.roblox.com/users/" .. tostring(mM.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = mE.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(qN("Game", mG, "#6ec1ff"), true)
    Label2 = SessionGroup:AddLabel(qN("Players", "0/0", qK), true)
    qS = tostring(game.JobId)
    local qX = #qS > 18 and string.sub(qS, 1, 18) .. "..."
    local qZ_1 = qX or qS
    SessionGroup:AddLabel(qN("Job", qZ_1, qW), true)
    Label = SessionGroup:AddLabel(qN("Ping", "0 ms", qU), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            l3:Teleport(game.PlaceId, mM)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            ma(qS, "Copied Job ID")
        end
    })
    task.spawn(function()
        local qH_1
        local qG_1
        while true do
            task.wait(1)
            if mg.Unloaded then
                break
            end
            Label3:SetText(qN("Session", qM(), qU))
            Label2:SetText(qN("Players", #me:GetPlayers() .. "/" .. tostring(me.MaxPlayers), qK))
            qG_1, qH_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local qG_2 = qG_1 and qH_1 .. " ms" or "n/a"
            Label:SetText(qN("Ping", qG_2, qU))
        end
    end)
    local SocialsGroup = mE.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = mT })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            ma(mr, "Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            ma(ml, "Copied website link")
        end
    })
end
local function nc_2()
    local connection
    local MovementGroup = mE.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = mE.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    mk(l9.Stepped:Connect(function()
        if mg.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = mM.Character
            if Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    local q0_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if q0_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end))
    mk(l1.JumpRequest:Connect(function()
        if mg.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local q8_1 = l8()
            if q8_1 then
                q8_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end))
    local CurrentCamera = mU.CurrentCamera
    mk(l9.RenderStepped:Connect(function(f7)
        if mg.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local rd_1 = l8()
            if rd_1 then
                rd_1.WalkSpeed = l2.WalkSpeed.Value
            end
        end
        local rd_2 = Toggles.Fly and Toggles.Fly.Value and not my("AutoFarmWins")
        if rd_2 then
            local rd_3 = mS()
            local re = l8()
            if rd_3 and re then
                re.PlatformStand = true
                local re_1 = Vector3.zero
                if l1:IsKeyDown(Enum.KeyCode.W) then
                    re_1 += CurrentCamera.CFrame.LookVector
                end
                if l1:IsKeyDown(Enum.KeyCode.S) then
                    re_1 -= CurrentCamera.CFrame.LookVector
                end
                local rj = if l1:IsKeyDown(Enum.KeyCode.A) then 1 else 0
                if rj == 1 then
                    re_1 -= CurrentCamera.CFrame.RightVector
                end
                if l1:IsKeyDown(Enum.KeyCode.D) then
                    re_1 += CurrentCamera.CFrame.RightVector
                end
                if l1:IsKeyDown(Enum.KeyCode.Space) then
                    re_1 += Vector3.new(0, 1, 0)
                end
                if l1:IsKeyDown(Enum.KeyCode.LeftControl) then
                    re_1 -= Vector3.new(0, 1, 0)
                end
                rd_3.AssemblyLinearVelocity = Vector3.zero
                if re_1.Magnitude > 0 then
                    rd_3.CFrame = rd_3.CFrame + re_1.Unit * l2.FlySpeed.Value * f7
                end
            end
        end
    end))
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local rk = l8()
            if rk then
                rk.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local rm = l8()
            if rm then
                rm.WalkSpeed = 16
            end
        end
    end)
    local function gv(gw)
        if not gw:IsA("ProximityPrompt") then
            return
        end
        gw.HoldDuration = 0
        gw.MaxActivationDistance = 50
        gw.RequiresLineOfSight = false
    end
    connection = nil
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in ipairs(mU:GetDescendants()) do
                pcall(gv, descendant)
            end
            connection = mU.DescendantAdded:Connect(function(gE)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(gv, gE)
                end
            end)
            mk(connection)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    mg:OnUnload(function()
        if connection then
            connection:Disconnect()
        end
    end)
end
local function nb_6()
    local MenuGroup = mE.Settings:AddLeftGroupbox("Menu", "logs")
    local gM = 0
    local gN = tick()
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = MenuGroup:AddLabel("AFK triggers: 0")
    local function gP()
        local CurrentCamera = mU.CurrentCamera
        if not CurrentCamera then
            return
        end
        m0:CaptureController()
        m0:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        gM += 1
        gN = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. gM)
        end)
    end
    local connection2 = mM.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(gP)
        end
    end)
    mk(connection2)
    task.spawn(function()
        while not mg.Unloaded do
            task.wait(2)
            local rE = Toggles.AntiAfk.Value and tick() - gN >= 60
            if rE then
                pcall(gP)
            end
        end
    end)
    MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
    MenuGroup:AddToggle("Disable3D", { Text = "Disable 3D Rendering", Default = false })
    MenuGroup:AddToggle("FpsBoost", { Text = "FPS Boost", Default = false })
    MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    mg.ToggleKeybind = l2.MenuKeybind
    local function hc(hd)
        pcall(function()
            mD:SetGameplayPausedNotificationEnabled(not hd)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = mK:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not hd
            end
        end)
        if not hd then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(mM, "GameplayPaused", false)
            else
                mM.GameplayPaused = false
            end
        end)
    end
    Toggles.AntiGameplayPause:OnChanged(function()
        hc(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not mg.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                hc(true)
            end
        end
    end)
    local hu = false
    local function hv()
        local PlaceId, JobId
        if hu then
            return
        end
        hu = true
        PlaceId, JobId = game.PlaceId, game.JobId
        local rN = pcall(function()
            l3:TeleportToPlaceInstance(PlaceId, JobId, mM)
        end)
        if not rN then
            pcall(function()
                l3:Teleport(PlaceId, mM)
            end)
        end
    end
    task.spawn(function()
        local RobloxPromptGui = mK:WaitForChild("RobloxPromptGui", 30)
        local rS = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
        if not rS then
            return
        end
        mk(rS.ChildAdded:Connect(function(hO)
            if mg.Unloaded then
                return
            end
            if Toggles.AutoReconnect.Value and hO.Name == "ErrorPrompt" then
                hv()
            end
        end))
    end)
    mk(l3.TeleportInitFailed:Connect(function()
        if Toggles.AutoReconnect.Value then
            hu = false
            hv()
        end
    end))
    Toggles.Disable3D:OnChanged(function()
        pcall(function()
            l9:Set3dRenderingEnabled(not Toggles.Disable3D.Value)
        end)
    end)
    local h3 = {
        ParticleEmitter = true,
        Trail = true,
        Smoke = true,
        Fire = true,
        Sparkles = true,
        Explosion = true,
        Beam = true
    }
    local function h4(h5)
        if h3[h5.ClassName] then
            pcall(function()
                h5.Enabled = false
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
                mq.GlobalShadows = false
            end)
            pcall(function()
                mq.FogEnd = 9000000000
            end)
            for i, descendant in ipairs(mU:GetDescendants()) do
                pcall(h4, descendant)
            end
            connection = mU.DescendantAdded:Connect(function(il)
                if Toggles.FpsBoost.Value then
                    pcall(h4, il)
                end
            end)
            mk(connection)
        else
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            end)
            pcall(function()
                mq.GlobalShadows = true
            end)
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end)
    local ScriptGroup = mE.Settings:AddLeftGroupbox("Script", "terminal")
    ScriptGroup:AddButton({
        Text = "Unload Script",
        Func = function()
            mg:Unload()
        end
    })
    mg:OnUnload(function()
        if connection2 then
            connection2:Disconnect()
        end
        hc(false)
        pcall(function()
            l9:Set3dRenderingEnabled(true)
        end)
        if connection then
            connection:Disconnect()
        end
        for k, v in m2 do
            local sa = v
            pcall(function()
                sa:Disconnect()
            end)
        end
        table.clear(m2)
        local r3 = l8()
        if r3 then
            r3.PlatformStand = false
            r3.WalkSpeed = 16
        end
        if getgenv then
            getgenv().__TempoLongArmToyEscapeLib = nil
        end
    end)
end
if (nc_2 or not nb_6 or (nb_6 or not nc_2) or (not nc_2 and not nc_2 or not nb_6 and not nc_2)) and (nb_6 and not nb_6 and (not nb_6 or not nb_6) or (nc_2 or nb_6) and (not nc_2 or nc_2)) and ((not nb_6 and not nb_6 and (nb_6 or not nc_2) or (nc_2 or nc_2 or not nb_6 and not nb_6)) and (nb_6 and not nb_6 or not nc_2 and nb_6 or (nc_2 or nb_6) and (not nc_2 or nb_6))) or not ((nc_2 or not nb_6 or (nb_6 or not nc_2) or (not nc_2 and not nc_2 or not nb_6 and not nc_2)) and (nb_6 and not nb_6 and (not nb_6 or not nb_6) or (nc_2 or nb_6) and (not nc_2 or nc_2)) and ((not nb_6 and not nb_6 and (nb_6 or not nc_2) or (nc_2 or nc_2 or not nb_6 and not nb_6)) and (nb_6 and not nb_6 or not nc_2 and nb_6 or (nc_2 or nb_6) and (not nc_2 or nb_6)))) then
    m7_4 = function(iG)
        local function iH(iI, iJ)
            local sc_1 = (iI == "Toggle" and Toggles or l2)[iJ]
            local sb_2 = type(sc_1) == "table" and sc_1.Type == iI
            return sb_2 and sc_1 or nil
        end
        local function iR(iS, iT)
            local Type = iT.Type
            if Type == "Toggle" then
                return { idx = iS, type = "Toggle", value = iT.Value == true }
            elseif Type == "Slider" then
                return { idx = iS, type = "Slider", value = tostring(iT.Value) }
            elseif Type == "Dropdown" then
                return { idx = iS, type = "Dropdown", multi = iT.Multi == true, value = iT.Value }
            elseif Type == "Input" then
                local sg = iT.Value or ""
                return { idx = iS, type = "Input", text = tostring(sg) }
            elseif Type == "ColorPicker" then
                return { idx = iS, type = "ColorPicker", value = iT.Value:ToHex(), transparency = iT.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = iS,
                    type = "KeyPicker",
                    mode = iT.Mode,
                    key = iT.Value,
                    modifiers = iT.Modifiers,
                    toggled = iT.Toggled
                }
            else
                return nil
            end
        end
        local function iV()
            local sm = {}
            for i, v in ipairs({ Toggles, l2 }) do
                for k, v in pairs(v) do
                    local sn = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if sn then
                        local sn_1 = iR(k, v)
                        if sn_1 then
                            sm[#sm + 1] = sn_1
                        end
                    end
                end
            end
            table.sort(sm, function(i4, i5)
                if i4.type ~= i5.type then
                    return i4.type < i5.type
                end
                return i4.idx < i5.idx
            end)
            return { objects = sm }
        end
        local function i6(i7)
            local sD
            sD = nil
            local sE = type(i7) ~= "table" or type(i7.idx) ~= "string"
            local sI = if sE then 1 else 0
            local sG = 3601 * sI + 2359 * (1 - sI)
            local sH = 897 * sI + 1866 * (1 - sI)
            if not ((sG * 3654 + sH * 3752 + sG * sH) % 16777213 == 2976482) then
                sE = type(i7.type) ~= "string"
            end
            if not sE then
                sE = SaveManager.Ignore[i7.idx]
            end
            if sE then
                return false
            end
            sD = iH(i7.type, i7.idx)
            if not sD then
                return false
            end
            local sE_1 = pcall(function()
                if i7.type == "Input" then
                    if type(i7.text) ~= "string" then
                        return
                    end
                    sD:SetValue(i7.text)
                elseif i7.type == "ColorPicker" then
                    sD:SetValueRGB(Color3.fromHex(i7.value), i7.transparency)
                elseif i7.type == "KeyPicker" then
                    sD:SetValue({ i7.key, i7.mode, i7.modifiers })
                    if i7.mode == "Toggle" and i7.toggled ~= nil then
                        sD.Toggled = i7.toggled
                        sD:Update()
                    end
                else
                    sD:SetValue(i7.value)
                end
            end)
            return sE_1
        end
        iG:AddDivider()
        iG:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        iG:AddButton("Export Config to Clipboard", function()
            local sK_1
            local sJ_1
            sJ_1, sK_1 = pcall(mv.JSONEncode, mv, iV())
            if not sJ_1 then
                mg:Notify("Failed to encode the config")
                return
            end
            local sJ_2 = setclipboard or toclipboard
            local sJ_3 = type(sJ_2) ~= "function" or not pcall(sJ_2, sK_1)
            if sJ_3 then
                mg:Notify("Your executor does not support copying to the clipboard")
                return
            end
            mg:Notify("Config copied to clipboard", 6)
        end)
        iG:AddButton("Import Config from Clipboard Text", function()
            local sS_1
            local sQ = l2.SaveManager_ImportSource.Value or ""
            local sQ_1
            local sR = tostring(sQ):match("^%s*(.-)%s*$")
            if sR == "" then
                mg:Notify("Paste an exported config into the box first")
                return
            end
            sQ_1, sS_1 = pcall(mv.JSONDecode, mv, sR)
            local sR_1 = not sQ_1 or type(sS_1) ~= "table" or type(sS_1.objects) ~= "table"
            if sR_1 then
                mg:Notify("That is not a valid exported config")
                return
            end
            local sQ_2 = 0
            for i, v in ipairs(sS_1.objects) do
                if i6(v) then
                    sQ_2 += 1
                end
            end
            if sQ_2 == 0 then
                mg:Notify("No settings in that config matched this script")
                return
            end
            l2.SaveManager_ImportSource:SetValue("")
            local sS_2 = sQ_2 == 1 and "" or "s"
            mg:Notify(("Imported %d setting%s"):format(sQ_2, sS_2), 6)
        end)
    end
end
nd()
nc_2()
nb_6()
ThemeManager:SetLibrary(mg)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(mE.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(mg)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/LongArmToyEscape")
local m8_2 = SaveManager:BuildConfigSection(mE.Settings)
m7_4(m8_2)
SaveManager:LoadAutoloadConfig()
if Toggles.HideUiOnStart and Toggles.HideUiOnStart.Value then
    mg:Toggle(false)
end
end)(...)

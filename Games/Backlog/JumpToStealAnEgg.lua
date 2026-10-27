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
getgenv().TempoHoodSubtitle = "JUMP TO STEAL AN EGG"
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
local LocalPlayer
local ut
local tt
local ua
local tS
local tz
local ug
local tg
local tY
local tF
local um
local tm
local tL
local us
local ts
local t9
local ty
local tf
local tX
local tE
local ul
local tl
local t2
local tK
local tr
local t8
local tQ
local tx
local ue
local Players
local tD
local uk
local tk
local t1
local tJ
local uq
local tq
local t7
local tw
local ud
local tV
local tC
local tj
local t0
local tI
local up
local tp
local Workspace
local tv
local uc
local tU
local tB
local ui
local ti
local t_
local tH
local uo
local to
local State
local tN
local tu
local tT
local uh
local th
local CoreGui
local tG
local un
local tn
local t4
local function fn78(hK)
    local Bq = {}
    if type(hK) == "table" then
        for k, v in pairs(hK) do
            if type(k) == "string" then
                Bq[k] = v == true
            elseif type(v) == "string" then
                Bq[v] = true
            end
        end
    elseif type(hK) == "string" then
        Bq[hK] = true
    end
    return Bq
end
local function fn104()
    local wB = {}
    local wC = { LocalPlayer:FindFirstChildOfClass("Backpack"), tw() }
    for i, v in ipairs(wC) do
        if v then
            for i, child in ipairs(v:GetChildren()) do
                local wC_1 = child:IsA("Tool") and child:GetAttribute("ItemType") == "AssetEgg"
                if wC_1 then
                    local attr = child:GetAttribute("UID")
                    local wD = type(attr) == "string" and #attr > 0
                    if wD then
                        table.insert(wB, { Tool = child, Uid = attr })
                    end
                end
            end
        end
    end
    return wB
end
local function fn105(dz, dA)
    local xy = os.clock() + 120
    while true do
        local xz = tk() and os.clock() < xy
        if not xz then
            return false
        end
        local xz_1 = dA and not tf()
        if xz_1 then
            break
        end
        local xz_2 = tr()
        if not xz_2 then
            return false
        end
        local xA = dz - xz_2.Position
        if xA.Magnitude <= tY then
            xz_2.CFrame = CFrame.new(dz)
            xz_2.AssemblyLinearVelocity = Vector3.zero
            return true
        end
        xz_2.CFrame = CFrame.new(xz_2.Position + xA.Unit * tY)
        xz_2.AssemblyLinearVelocity = Vector3.zero
        task.wait(tU)
    end
    return false
end
local function fn106(hQ)
    State.StealBiomes = tF(hQ)
end
local function fn136(ij)
    State.AutoIndexRewards = ij == true
end
local function fn141()
    return State.Status
end
local function fn145()
    while tk() do
        if State.AutoSteal then
            if tf() then
                tT("Returning the stolen egg")
                tn()
            else
                local xN = State.StopWhenPenFull and tt()
                if xN then
                    tT("Pen is full, stealing paused")
                    task.wait(2)
                else
                    tT("Looking for an egg to steal")
                    if tV() then
                        tT("Returning the stolen egg")
                        tn()
                    else
                        task.wait(1)
                    end
                end
            end
        end
        task.wait(0.2)
    end
end
local function fn150()
    while tk() do
        if State.AutoSell and tu then
            local Ad_1 = to()
            for i, v in ipairs(Ad_1) do
                local Ae = not tk() or not State.AutoSell
                if Ae then
                    break
                end
                local Ae_1 = tq(tu, { Uid = v })
                if uo(Ae_1) then
                    tT("Sold an animal")
                end
                task.wait(0.2)
            end
            if #Ad_1 > 0 then
                ua()
            end
        end
        task.wait(2)
    end
end
local function fn202(h0)
    State.AutoEquipBest = h0 == true
end
local function fn216(hO)
    State.AutoSteal = hO == true
end
local function fn219()
    while tk() do
        if State.AutoEquipBest and tv then
            tq(tv, {})
        end
        task.wait(5)
    end
end
local function onOnClientEvent(bC)
    local v0 = type(bC) == "table" and type(bC.Data) == "table"
    if v0 then
        t2 = bC.Data
    end
end
local function fn233()
    return LocalPlayer:GetAttribute("CarryingEgg") == true
end
local function fn253(Z)
    return type(Z) == "function"
end
local function fn261(ig)
    State.SellRarities = tF(ig)
end
local function fn263(h8)
    local By = tonumber(h8)
    if By then
        State.JumpAmount = math.floor(By)
    end
end
local function fn266(fi, fj)
    local yS = {}
    local yT = fj.Size.X * 0.5 - 4
    local yU = fj.Size.Z * 0.5 - 4
    local yV = 5
    local yW = -yT
    while yW <= yT do
        local yX = -yU
        while yX <= yU do
            table.insert(yS, tE(fi, fj, yW, yX))
            yX += yV
        end
        yW += yV
    end
    return yS
end
local function fn282(a8)
    if State.Status == a8 then
        return
    end
    State.Status = a8
    for i, v in ipairs(tX) do
        pcall(v, a8)
    end
end
local function fn286(h4)
    State.AutoRebirth = h4 == true
end
local function fn303()
    while tk() do
        if State.AutoHatch and tz and tx then
            local zA_1 = tL()
            for i, v in ipairs(zA_1) do
                local zB_1 = not tk() or not State.AutoHatch
                if zB_1 then
                    break
                else
                    local zB_2 = tq(tz, { Uid = v })
                    local zC = type(zB_2) == "table" and zB_2.Success == true and type(zB_2.HatchToken) == "string"
                    if zC then
                        local zC_1 = zB_2.Species or "an egg"
                        tT("Hatching " .. tostring(zC_1))
                        local zM = 1
                        while zM <= 3 do
                            if not tk() then
                                break
                            end
                            local zC_2 = tq(tx, { Token = zB_2.HatchToken })
                            if uo(zC_2) then
                                break
                            end
                            task.wait(0.5)
                            zM += 1
                        end
                    end
                    task.wait(0.4)
                end
            end
            if #zA_1 > 0 then
                ua()
            end
        end
        task.wait(2)
    end
end
local function fn314(be)
    table.insert(tX, be)
end
local function fn343()
    local AY = {}
    for i, v in ipairs(tK) do
        table.insert(AY, v)
    end
    return AY
end
local function fn359(at, au)
    local vA_1
    local vy = uq(at, au, 20)
    local vz = not vy or not vy:IsA("ModuleScript")
    local vz_1
    if vz then
        return nil
    end
    vz_1, vA_1 = pcall(require, vy)
    return vz_1 and vA_1 or nil
end
local function fn391(io)
    State.AutoGroupReward = io == true
end
local function fn394()
    local yb = tw()
    if not yb then
        return false
    end
    for i, child in ipairs(yb:GetChildren()) do
        local yc_1 = child:IsA("Tool") and child:GetAttribute("IsBat") == true
        if yc_1 then
            return true
        end
    end
    local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local Humanoid = yb:FindFirstChildOfClass("Humanoid")
    if not Backpack or not Humanoid then
        return false
    end
    for i, child in ipairs(Backpack:GetChildren()) do
        local yb_2 = child:IsA("Tool") and child:GetAttribute("IsBat") == true
        if yb_2 then
            Humanoid:EquipTool(child)
            return true
        end
    end
    return false
end
local function fn403()
    return CoreGui
end
local function fn475()
    while tk() do
        if State.AutoRebirth and tj and uh and t2 then
            local AD_2 = type(t2.Rebirths) == "number" and t2.Rebirths
            local AE_1 = AD_2 or 0
            local AE_2 = type(t2.Jump) == "number" and t2.Jump
            local AF = AE_2 or 0
            local AF_1 = uh.GetNextStage(AE_1)
            if AF_1 and AF >= AF_1.RequiredJump then
                local AD_5 = tq(tj)
                if uo(AD_5) then
                    tT("Rebirthed")
                    ua()
                end
            end
        end
        task.wait(3)
    end
end
local function fn480()
    local xF = tN()
    if not xF then
        tT("No egg available in the selected biomes")
        return false
    end
    local xG = xF.Root.Position + Vector3.new(0, 5, 0)
    if not ty(xG) then
        tT("Waiting for character")
        return false
    end
    local xH = os.clock() + 2.5
    while true do
        local xI = tk() and os.clock() < xH
        if xI then
            ty(xG)
            task.wait(0.2)
            continue
        end
        break
    end
    local xM = if not tk() then 1 else 0
    if xM == 1 then
        return false
    end
    local xG_1 = false
    local xM_1 = if ts(fireproximityprompt) then 1 else 0
    if xM_1 == 1 then
        xG_1 = pcall(fireproximityprompt, xF.Prompt)
    end
    if not xG_1 then
        tT("fireproximityprompt is unavailable")
        return false
    end
    local xF_1 = os.clock() + 3
    while true do
        local xG_2 = tk() and not tf() and os.clock() < xF_1
        if xG_2 then
            task.wait(0.1)
            continue
        end
        break
    end
    local xF_2 = tk() and tf()
    return xF_2
end
local function fn486(e7, e8, e9, fa)
    local yN = e8.Size.X * 0.5
    local yO = e8.Size.Z * 0.5
    local yQ = t4 and t4.Placement.PointInsetStuds or 0.05
    local yP_2 = math.min(yQ, yN, yO)
    local yQ_1 = CFrame.new(math.clamp(e9, -yN + yP_2, yN - yP_2), e8.Size.Y * 0.5, math.clamp(fa, -yO + yP_2, yO - yP_2))
    return e7.CFrame:ToObjectSpace(e8.CFrame * yQ_1)
end
local function fn493()
    local v2 = tw()
    local v3 = v2 and v2:FindFirstChild("HumanoidRootPart")
    return v3
end
local function fn503()
    local BQ = select(1, uc())
    if not BQ then
        return false, "Base plot unavailable"
    elseif not up(BQ.Position + Vector3.new(0, 6, 0), 0.6) then
        return false, "Character is unavailable"
    else
        return true
    end
end
local function fn529()
    local w_ = {}
    for k, v in pairs(State.StealBiomes) do
        if v == true then
            table.insert(w_, k)
        end
    end
    if #w_ > 0 then
        table.sort(w_)
        return w_
    end
    local w__1 = LocalPlayer:GetAttribute("HighestReachedBiomeOrder")
    local w0 = type(w__1) == "number" and w__1
    local w__2 = w0 or 1
    local w0_1 = {}
    for i, v in ipairs(tK) do
        if i <= w__2 then
            table.insert(w0_1, v)
        end
    end
    if #w0_1 == 0 and tK[1] then
        table.insert(w0_1, tK[1])
    end
    return w0_1
end
local function fn537(hZ)
    State.AutoHatch = hZ == true
end
local function fn559(cQ)
    local Map = Workspace:FindFirstChild("Map")
    local wS = Map and Map:FindFirstChild("BiomeNests")
    if not wS then
        return nil
    end
    for i, child in ipairs(wS:GetChildren()) do
        if child.Name:sub(4) == cQ then
            return child
        end
    end
    return nil
end
local function fn574(gA)
    local An_1
    local Am = not ti or not t2 or type(t2.Cash) ~= "string" or type(gA) ~= "string"
    local Am_1
    if Am then
        return false
    end
    Am_1, An_1 = pcall(ti.Compare, t2.Cash, gA)
    return Am_1 and An_1 >= 0
end
local function fn591(iq)
    local BD = type(iq) == "string" and iq
    local BE = BD
    local BI = if BE then 1 else 0
    local BG = 3589 * BI + 3023 * (1 - BI)
    local BH = 2805 * BI + 2326 * (1 - BI)
    if not ((BG * 2745 + BH * 491 + BG * BH) % 16777213 == 4518992) then
        BE = nil
    end
    State.TeleportBiome = BE
end
local function fn593(aK, aL)
    local vF = tG and tG:FindFirstChild(aK)
    local vG = vF
    if vF then
        vF = vG:IsA(aL)
    end
    if vF then
        return vG
    end
    return nil
end
local function fn599()
    local yA_1
    local yw = t1 and t1.SwingCooldownSeconds
    local yG = if yw then 1 else 0
    local yE = 1052 * yG + 2136 * (1 - yG)
    local yF = 290 * yG + 2940 * (1 - yG)
    if not ((yE * 695 + yF * 1112 + yE * yF) % 16777213 == 1358700) then
        yw = 0.8
    end
    local yv_1 = t1
    local yx = yw
    if yv_1 then
        yv_1 = t1.MaximumHitDistanceStuds
    end
    local yw_1 = yv_1 or 17
    local yv_2 = 0
    while tk() do
        local yw_2 = State.BatDefense and t9 and not uk()
        if yw_2 then
            local yw_3 = tr()
            local yz = yw_3 and ug()
            local yz_1
            if yz then
                yA_1, yz_1 = nil, math.huge
                for i, v in ipairs(t_()) do
                    local Magnitude = (v - yw_3.Position).Magnitude
                    if Magnitude <= yw_1 and Magnitude < yz_1 then
                        yA_1, yz_1 = v, Magnitude
                    end
                end
                local yB_2 = yA_1 and os.clock() - yv_2 >= yx
                if yB_2 then
                    yv_2 = os.clock()
                    local yz_2 = Vector3.new(yA_1.X, yw_3.Position.Y, yA_1.Z)
                    if (yz_2 - yw_3.Position).Magnitude > 0.1 then
                        yw_3.CFrame = CFrame.lookAt(yw_3.Position, yz_2)
                    end
                    pcall(function()
                        t9:FireServer()
                    end)
                end
            end
        end
        task.wait(0.15)
    end
end
local function fn606()
    local vW = tq(tI)
    local vX = type(vW) == "table" and type(vW.Data) == "table"
    if vX then
        t2 = vW.Data
    end
    return t2
end
local function fn687()
    local wz = tS()
    if not wz then
        return false
    end
    return tD() >= wz
end
local function fn732()
    local zR = not t2
    local zS = {}
    local z0 = if zR then 1 else 0
    local zZ = 2 * z0 + 1147 * (1 - z0)
    local z_ = 1817 * z0 + 1091 * (1 - z0)
    if not ((zZ * 1564 + z_ * 3272 + zZ * z_) % 16777213 == 5951986) then
        zR = type(t2.Inventory) ~= "table"
    end
    if not zR then
        zR = type(t2.Inventory.Animals) ~= "table"
    end
    if zR then
        return zS
    end
    local zR_1 = type(t2.Placements) == "table" and t2.Placements.Animals
    local zT = zR_1 or nil
    local SellRarities = State.SellRarities
    local zU = false
    for k, v in pairs(SellRarities) do
        if v == true then
            zU = true
            break
        end
    end
    for i, v in ipairs(t2.Inventory.Animals) do
        local zV = type(v) == "table" and type(v.Uid) == "string" and v.PlacementId == nil
        if zV then
            local zV_1 = type(zT) == "table" and zT[v.Uid] ~= nil
            local zV_2 = type(v.Rarity) == "string" and v.Rarity
            local zX = zV_2 or "Common"
            local zV_3 = not zV_1
            if zV_3 then
                zV_3 = not zU or SellRarities[zX] == true
            end
            if zV_3 then
                table.insert(zS, v.Uid)
            end
        end
    end
    return zS
end
local function fn750(cd, ce, cf)
    local wh = os.clock() + ce
    while true do
        local wi = tk() and os.clock() < wh
        if not wi then
            return tk()
        end
        if not ty(cd, cf) then
            break
        end
        task.wait(0.1)
    end
    return false
end
local function fn755()
    return LocalPlayer:GetAttribute("InSafeZone") == true
end
local function fn758()
    local xP = {}
    local EggGameWorld = Workspace:FindFirstChild("EggGameWorld")
    local xR = EggGameWorld and EggGameWorld:FindFirstChild("Guardians")
    if xR then
        for i, child in ipairs(xR:GetChildren()) do
            if child:IsA("BasePart") then
                table.insert(xP, child.Position)
            end
        end
    end
    local EggGameClientVisuals = Workspace:FindFirstChild("EggGameClientVisuals")
    local xR_1 = EggGameClientVisuals and EggGameClientVisuals:FindFirstChild("Guardians")
    if xR_1 then
        for i, child in ipairs(xR_1:GetChildren()) do
            local xQ_4 = child:IsA("Model") and child.PrimaryPart
            local xR_2 = xQ_4 or nil
            if xR_2 then
                table.insert(xP, xR_2.Position)
            end
        end
    end
    for i, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local xQ_6 = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if xQ_6 then
                table.insert(xP, xQ_6.Position)
            end
        end
    end
    return xP
end
local function fn759()
    local attr = LocalPlayer:GetAttribute("PlotId")
    if type(attr) ~= "number" then
        return nil, nil
    end
    local Plots = Workspace:FindFirstChild("Plots")
    local v7 = Plots and Plots:FindFirstChild(tostring(attr))
    local v6_1 = v7 and v7:FindFirstChild("ToUpdate")
    local v5_2 = v6_1
    if v6_1 then
        v6_1 = v5_2:FindFirstChild("CenterPoint")
    end
    local v7_1 = v5_2
    local v8 = v6_1
    if v7_1 then
        v7_1 = v5_2:FindFirstChild("PetArea")
    end
    local v5_3 = v8
    local v6_2 = v7_1
    if v5_3 then
        v5_3 = v8:IsA("BasePart")
    end
    if v5_3 then
        v5_3 = v6_2
    end
    if v5_3 then
        v5_3 = v6_2:IsA("BasePart")
    end
    if v5_3 then
        return v8, v6_2
    end
    return nil, nil
end
local function fn764()
    if not t2 or not ul then
        return nil
    end
    local wk_1 = type(t2.EnclosureLevel) == "number" and t2.EnclosureLevel
    local wl_1 = wk_1 or 0
    local wl_2 = ul.GetEffectiveLevel(wl_1)
    return wl_2 and wl_2.AnimalCapacity or nil
end
local function fn811(hT)
    State.StopWhenPenFull = hT == true
end
local function fn830()
    local TeleportBiome = State.TeleportBiome
    if not TeleportBiome then
        return false, "Pick a biome first"
    end
    local BK = tH(TeleportBiome)
    if not BK then
        return false, "That biome is not loaded"
    end
    local BJ_1 = (BK:FindFirstChild("Nest01"))
    local BP = if BJ_1 then 1 else 0
    local BN = 3340 * BP + 3584 * (1 - BP)
    local BO = 358 * BP + 2059 * (1 - BP)
    if not ((BN * 3483 + BO * 2171 + BN * BO) % 16777213 == 13606158) then
        BJ_1 = BK:GetChildren()[1]
    end
    local BK_1 = BJ_1
    if BJ_1 then
        local BL = BK_1:FindFirstChild("Root") or BK_1:FindFirstChildWhichIsA("BasePart")
        BJ_1 = BL
    end
    local BK_2 = BJ_1
    if not BK_2 then
        return false, "That biome has no anchor point"
    end
    local BP_1 = if not up(BK_2.Position + Vector3.new(0, 6, 0), 0.6) then 1 else 0
    if BP_1 == 1 then
        return false, "Character is unavailable"
    end
    return true
end
local function fn835()
    gethui = tJ
end
local function fn852()
    local wt = not t2 or type(t2.Placements) ~= "table" or type(t2.Placements.Animals) ~= "table"
    if wt then
        return 0
    end
    local wt_1 = 0
    for k in pairs(t2.Placements.Animals) do
        wt_1 += 1
    end
    return wt_1
end
local function fn893()
    local zi = not t2
    local zj = {}
    if not zi then
        zi = type(t2.Inventory) ~= "table"
    end
    local zq = if zi then 1 else 0
    local zo = 1879 * zq + 274 * (1 - zq)
    local zp = 2266 * zq + 157 * (1 - zq)
    if not ((zo * 375 + zp * 643 + zo * zp) % 16777213 == 6419477) then
        zi = type(t2.Inventory.Eggs) ~= "table"
    end
    if zi then
        return zj
    end
    local zi_1 = Workspace:GetServerTimeNow()
    for i, v in ipairs(t2.Inventory.Eggs) do
        local zk = type(v) == "table" and type(v.Uid) == "string" and type(v.PlacementId) == "string"
        if zk then
            local zk_1 = v.Ready == true
            local zl = not zk_1
            if zl ~= false then
                zl = type(v.GrowthStartedAt) == "number"
            end
            if zl then
                zl = type(v.GrowthDuration) == "number"
            end
            if zl then
                zl = v.GrowthDuration > 0
            end
            if zl then
                local zl_1 = type(v.GrowthCreditSeconds) == "number" and v.GrowthCreditSeconds
                zk_1 = zi_1 - v.GrowthStartedAt + (zl_1 or 0) >= v.GrowthDuration
            end
            if zk_1 then
                table.insert(zj, v.Uid)
            end
        end
    end
    return zj
end
local function fn903(h6)
    State.AutoJump = h6 == true
end
local function fn904()
    if coroutine.status(t7) ~= "dead" then
        pcall(task.cancel, t7)
    end
end
local function fn912(b5, b6)
    local wd = tr()
    if not wd then
        return false
    end
    local we = b6 and CFrame.lookAt(b5, b6)
    local wf = we or CFrame.new(b5)
    wd.CFrame = wf
    wd.AssemblyLinearVelocity = Vector3.zero
    return true
end
local function fn914()
    return not tB.Unloaded
end
local function fn937(id)
    State.AutoSell = id == true
end
local function worker()
    while tk() do
        task.wait(6)
        if tk() then
            ua()
        end
    end
end
local function fn961(h2)
    State.AutoTrail = h2 == true
end
local function fn971()
    local Bh = us
    local Bi = {}
    if Bh then
        Bh = type(us.Jump) == "table"
    end
    if Bh then
        for i, v in ipairs(us.Jump.Upgrades) do
            table.insert(Bi, tostring(v.Amount))
        end
    end
    if #Bi == 0 then
        Bi = { "1", "5", "10" }
    end
    return Bi
end
local function fn993()
    local xC = select(1, uc())
    if not xC then
        tT("Base plot unavailable")
        return false
    end
    local xD = xC.Position + Vector3.new(0, 6, 0)
    tQ(xD, true)
    local xC_1 = os.clock() + 4
    while true do
        local xD_1 = tk() and tf() and os.clock() < xC_1
        if xD_1 then
            task.wait(0.1)
            continue
        end
        break
    end
    local xC_2 = tk() and not tf()
    return xC_2
end
local function fn1042(hV)
    State.BatDefense = hV == true
end
local function fn1047(hX)
    State.AutoPlaceEggs = hX == true
end
local function fn1051()
    local xh_1
    local xf = tr()
    local xf_2
    local xf_1 = xf and xf.Position or Vector3.zero
    xh_1, xf_2 = nil, math.huge
    for i, v in ipairs(tl()) do
        local xi = tH(v)
        if xi then
            for i, child in ipairs(xi:GetChildren()) do
                local Egg = child:FindFirstChild("Egg")
                local xj = Egg and Egg:FindFirstChild("EggRoot")
                local xi_2 = xj
                if xj then
                    xj = xi_2:FindFirstChild("CarryPrompt")
                end
                local xk = xj
                if xj then
                    xj = xk:IsA("ProximityPrompt")
                end
                if xj then
                    xj = xk.Enabled
                end
                if xj then
                    local Magnitude = (xi_2.Position - xf_1).Magnitude
                    if Magnitude < xf_2 then
                        xh_1, xf_2 = { Root = xi_2, Prompt = xk }, Magnitude
                    end
                end
            end
        end
    end
    return xh_1
end
local function fn1060()
    local y__1
    while tk() do
        local yZ = State.AutoPlaceEggs and tC
        local yZ_1
        if yZ then
            yZ_1, y__1 = uc()
            local y0 = tg()
            if yZ_1 and y__1 and #y0 > 0 then
                local y1_1 = State.StopWhenPenFull and tt()
                if y1_1 then
                    tT("Pen is full, placement paused")
                else
                    local y1_2 = um(yZ_1, y__1)
                    for i, v in ipairs(y0) do
                        local yZ_2 = not tk() or not State.AutoPlaceEggs
                        if yZ_2 then
                            break
                        end
                        local yZ_3 = false
                        for i, v2 in ipairs(y1_2) do
                            if not tk() then
                                break
                            end
                            local y__2 = tq(tC, { Uid = v.Uid, LocalCFrame = v2 })
                            if uo(y__2) then
                                yZ_3 = true
                                tT("Placed an egg on the pen")
                                break
                            end
                            task.wait(0.1)
                        end
                        if not yZ_3 then
                            tT("No free spot on the pen")
                        end
                        task.wait(0.3)
                    end
                    ua()
                end
            end
        end
        task.wait(1.5)
    end
end
local function fn1093()
    while tk() do
        if State.AutoEnclosure and tm and ul and t2 then
            local AA_2 = type(t2.EnclosureLevel) == "number" and t2.EnclosureLevel
            local AB_1 = AA_2 or 0
            local AB_2 = ul.GetNextLevel(AB_1)
            local AA_4 = AB_2 and t0(AB_2.UpgradeCost)
            if AA_4 then
                local AA_5 = tq(tm)
                if uo(AA_5) then
                    tT("Enclosure upgraded to level " .. tostring(AA_5.Level))
                    ua()
                end
            end
        end
        task.wait(2)
    end
end
local function fn1105(bq)
    local vU = type(bq) == "table" and bq.Success == true
    return vU
end
local function fn1170()
    while tk() do
        if State.AutoIndexRewards and ut then
            local AW_1 = tq(ut)
            if uo(AW_1) then
                tT("Claimed index rewards")
            end
        end
        if State.AutoOfflineCash and th then
            local AW_3 = tq(th)
            if uo(AW_3) then
                tT("Claimed offline cash")
            end
        end
        if State.AutoGroupReward and un then
            tq(un)
        end
        task.wait(10)
    end
end
local function fn1192(il)
    State.AutoOfflineCash = il == true
end
local function fn1227()
    while true do
        local Az = if tk() then 1 else 0
        if Az == 1 then
            if State.AutoJump and tp and us then
                local At_1 = t2 and type(t2.Jump) == "number" and t2.Jump
                local Au_1 = At_1 or nil
                if Au_1 then
                    local JumpAmount = State.JumpAmount
                    local Av = us.GetJumpUpgradePrice(Au_1, JumpAmount)
                    local At_3 = Av and t0(Av)
                    if At_3 then
                        local At_4 = tq(tp, JumpAmount)
                        if uo(At_4) then
                            tT("Jump upgraded to " .. tostring(At_4.Jump))
                            ua()
                        end
                    end
                end
            end
            task.wait(1)
            continue
        end
        break
    end
end
local function fn1243()
    local vP = {}
    if not ts(fireproximityprompt) then
        table.insert(vP, "fireproximityprompt")
    end
    if not tG then
        table.insert(vP, "EggGameRemotes")
    end
    if not ti then
        table.insert(vP, "BigNumber")
    end
    return vP
end
local function fn1247()
    local AK_1
    while tk() do
        if State.AutoTrail and ui and ue and ud and t2 then
            local AH_2 = type(t2.Trails) == "table" and type(t2.Trails.Owned) == "table" and t2.Trails.Owned
            local AJ = AH_2 or {}
            local AJ_2
            local AI_3 = type(t2.Trails) == "table" and t2.Trails.Equipped
            local AJ_1 = AI_3 or nil
            AJ_2, AK_1 = nil, nil
            for i, v in ipairs(ud.Trails) do
                if AJ[v.Name] == true then
                    if not AK_1 or v.SpeedBonus > AK_1.SpeedBonus then
                        AK_1 = v
                    end
                else
                    local AL_2 = v.Acquisition == "Purchase" and t0(v.CashPrice)
                    if AL_2 then
                        if not AJ_2 or v.SpeedBonus > AJ_2.SpeedBonus then
                            AJ_2 = v
                        end
                    end
                end
            end
            if AJ_2 then
                local AH_4 = tq(ui, AJ_2.Name)
                if uo(AH_4) then
                    tT("Bought the " .. AJ_2.Name .. " trail")
                    ua()
                end
            else
                if AK_1 and AJ_1 ~= AK_1.Name then
                    local AH_6 = tq(ue, AK_1.Name)
                    if uo(AH_6) then
                        tT("Equipped the " .. AK_1.Name .. " trail")
                        ua()
                    end
                end
            end
        end
        task.wait(3)
    end
end
local function fn1278()
    return LocalPlayer.Character
end
local function fn1286(W)
    local vn = typeof(cloneref) == "function" and typeof(W) == "Instance"
    if vn then
        return cloneref(W)
    end
    return W
end
local function fn1291(ib)
    State.AutoEnclosure = ib == true
end
local function fn1317()
    local A5 = t8
    local A6 = {}
    if A5 then
        A5 = type(t8.Names) == "table"
    end
    if A5 then
        for i, v in ipairs(t8.Names) do
            table.insert(A6, v)
        end
    end
    if #A6 == 0 then
        A6 = {
            "Common",
            "Rare",
            "Epic",
            "Legendary",
            "Mythic",
            "Secret",
            "Celestial",
            "Divine",
            "Transcendent",
            "Eternal"
        }
    end
    return A6
end
Players = nil
tf = nil
tg = nil
th = nil
ti = nil
tj = nil
tk = nil
tl = nil
tm = nil
tn = nil
to = nil
tp = nil
tq = nil
tr = nil
ts = nil
tt = nil
tu = nil
tv = nil
tw = nil
tx = nil
ty = nil
tz = nil
tB = nil
tC = nil
tD = nil
tE = nil
tF = nil
tG = nil
tH = nil
tI = nil
tJ = nil
tK = nil
tL = nil
LocalPlayer = nil
tN = nil
Workspace = nil
tQ = nil
tS = nil
tT = nil
tU = nil
tV = nil
tX = nil
tY = nil
CoreGui = nil
t_ = nil
t0 = nil
local tP, Lighting, tW
t1 = nil
t2 = nil
t4 = nil
State = nil
t7 = nil
t8 = nil
t9 = nil
ua = nil
uc = nil
ud = nil
ue = nil
ug = nil
uh = nil
ui = nil
uk = nil
ul = nil
um = nil
un = nil
uo = nil
up = nil
uq = nil
us = nil
ut = nil
local GuiService, HttpService, VirtualUser, UserInputService, RunService, uv
if not game:IsLoaded() then
    game.Loaded:Wait()
end
Players, RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, tW, Lighting, Workspace, LocalPlayer, tJ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local uw = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
tW = game:GetService("TeleportService")
Lighting = game:GetService("Lighting")
if (not uw or not tJ) and (tJ and not tJ) or (RunService and RunService or not uw and RunService) or not ((not uw or not tJ) and (tJ and not tJ) or (RunService and RunService or not uw and RunService)) then
    Workspace = game:GetService("Workspace")
else
    tW = game:GetService("Workspace")
end
LocalPlayer = Players.LocalPlayer
if (not Lighting and CoreGui or (CoreGui or UserInputService) or (not UserInputService and Lighting or (RunService or not UserInputService)) or (RunService or not CoreGui) and (RunService or not Lighting) and ((UserInputService or UserInputService) and (UserInputService or not UserInputService))) and ((not UserInputService or Lighting or (not UserInputService or CoreGui)) and (Lighting and Lighting and (CoreGui and RunService)) and ((not CoreGui and not RunService or (UserInputService or not CoreGui)) and ((not RunService or CoreGui) and (Lighting and CoreGui)))) or not ((not Lighting and CoreGui or (CoreGui or UserInputService) or (not UserInputService and Lighting or (RunService or not UserInputService)) or (RunService or not CoreGui) and (RunService or not Lighting) and ((UserInputService or UserInputService) and (UserInputService or not UserInputService))) and ((not UserInputService or Lighting or (not UserInputService or CoreGui)) and (Lighting and Lighting and (CoreGui and RunService)) and ((not CoreGui and not RunService or (UserInputService or not CoreGui)) and ((not RunService or CoreGui) and (Lighting and CoreGui))))) then
    uv = "TempoJumpToStealAnEgg"
    tJ = fn403
else
    tJ = "TempoJumpToStealAnEgg"
    uv = fn403
end
if getgenv then
    getgenv().gethui = tJ
end
tB, tG, ti, us, ul, uh, ud, t8, t4, t1, tI, tC, tz, tx, tv, tu, tp, tm, tj, th, ut, un, ui, ue, t9, State, t2, tX, tP, ts, tk, uq, tT, tq, uo, ua = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pcall(fn835)
local function uy(t)
    local ve
    local vg
    local vf
    ve = nil
    vf = nil
    vg = nil
    local vh = t ~= ""
    local vi = type(t) == "string" and vh
    assert(vi, "A namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    ve = getgenv()
    assert(type(ve) == "table", "getgenv did not return a table")
    local vh_1 = ve[t]
    if vh_1 ~= nil then
        local vi_1 = type(vh_1) == "table" and type(vh_1.Unload) == "function"
        assert(vi_1, "Namespace is occupied")
        vh_1.Unload()
        assert(ve[t] == nil, "Previous instance did not release its namespace")
    end
    vf = {}
    vg = { State = {}, Unloaded = false }
    vg.Track = function(B)
        assert(type(B) == "function", "Cleanup must be callable")
        if vg.Unloaded then
            B()
        else
            table.insert(vf, B)
        end
        return B
    end
    vg.Unload = function()
        local u7_1
        local u6_1
        if vg.Unloaded then
            return
        end
        vg.Unloaded = true
        local u4 = {}
        local vb = #vf
        local va = -1
        while false and vb <= 1 or true and vb >= 1 do
            local vc = vb
            local u5_1 = table.remove(vf, vc)
            u6_1, u7_1 = pcall(u5_1)
            if not u6_1 then
                table.insert(u4, tostring(u7_1))
            end
            vb += va
        end
        table.clear(vg.State)
        if #u4 > 0 then
            error("Cleanup incomplete: " .. table.concat(u4, "; "), 0)
        end
        if ve[t] == vg then
            ve[t] = nil
        end
    end
    ve[t] = vg
    return vg
end
tP = function(O, P)
    local vl = type(O) == "table" and type(O.Track) == "function"
    assert(vl, "FeatureAPI required")
    local vl_1 = type(P) == "table" and type(P.OnUnload) == "function"
    assert(vl_1, "UI library required")
    assert(type(P.Unload) == "function", "UI unload required")
    O.Track(function()
        if not P.Unloaded then
            P:Unload()
        end
    end)
    P:OnUnload(function()
        O.Unload()
    end)
end
tB = uy(uv)
local ux = fn1286
ts = fn253
tk = fn914
local uu = ux(uw)
uq = function(ae, af, ag)
    local vv_1
    if not ae then
        return nil
    end
    local vu = ae:FindFirstChild(af)
    local vu_1
    if vu then
        return vu
    end
    vu_1, vv_1 = pcall(function()
        local vs = ag or 15
        return ae:WaitForChild(af, vs)
    end)
    return vu_1 and vv_1 or nil
end
local uD = uq(uu, "Shared", 30)
local uC = uq(uD, "EggGame", 30)
local uB = uq(uC, "Configs", 30)
local uA = uq(uC, "Utils", 30)
tG = uq(uu, "EggGameRemotes", 30)
local uz = fn359
ti = uz(uA, "BigNumber")
local uI = uz(uB, "BiomeConfig")
us = uz(uB, "EconomyConfig")
ul = uz(uB, "EnclosureConfig")
uh = uz(uB, "RebirthConfig")
ud = uz(uB, "TrailConfig")
t8 = uz(uB, "RarityConfig")
t4 = uz(uB, "AnimalInventoryConfig")
t1 = uz(uB, "BatCombatConfig")
tI = fn593("RequestPlayerData", "RemoteFunction")
local uG = fn593("PlayerDataSnapshot", "RemoteEvent")
tC = fn593("RequestPlaceEgg", "RemoteFunction")
tz = fn593("RequestHatchEgg", "RemoteFunction")
tx = fn593("RequestCompleteHatchEgg", "RemoteFunction")
tv = fn593("RequestEquipBestAnimals", "RemoteFunction")
tu = fn593("RequestSellAnimal", "RemoteFunction")
tp = fn593("RequestJumpUpgrade", "RemoteFunction")
tm = fn593("RequestEnclosureUpgrade", "RemoteFunction")
tj = fn593("RequestRebirth", "RemoteFunction")
th = fn593("RequestClaimOfflineIncome", "RemoteFunction")
ut = fn593("RequestClaimIndexRewards", "RemoteFunction")
un = fn593("RequestClaimGroupReward", "RemoteFunction")
ui = fn593("RequestPurchaseTrail", "RemoteFunction")
ue = fn593("RequestEquipTrail", "RemoteFunction")
t9 = fn593("RequestBatSwing", "RemoteEvent")
State = tB.State
State.Status = "Idle"
State.AutoSteal = false
State.StealBiomes = {}
State.StopWhenPenFull = true
State.BatDefense = false
State.AutoPlaceEggs = false
State.AutoHatch = false
State.AutoEquipBest = false
State.AutoTrail = false
State.AutoRebirth = false
State.AutoJump = false
State.JumpAmount = 10
State.AutoEnclosure = false
State.AutoSell = false
State.SellRarities = {}
State.AutoIndexRewards = false
State.AutoOfflineCash = false
State.AutoGroupReward = false
State.TeleportBiome = nil
t2 = nil
tX = {}
tT = fn282
tB.GetStatus = fn141
tB.OnStatus = fn314
tB.Support = fn1243
tq = function(bl, ...)
    local vS_1
    local vR_1
    if not bl then
        return nil
    end
    vR_1, vS_1 = pcall(function(...)
        return bl:InvokeServer(...)
    end, ...)
    if vR_1 then
        return vS_1
    end
    return nil
end
uo = fn1105
ua = fn606
local uH = uG
if uH then
    uu = 2
    repeat
        uv = {
            "mkeyaypg",
            "ofgafi",
            "avyqlfgsmov",
            "halwsxb",
            "bvxijfp",
            "enf",
            "qpfgcxy",
            "givbsmr",
            "antupxqkoex",
            "zpygzoo"
        }
        local Hn = uu
        uw = uv[Hn % 10 + 1]
        if uw:len() <= uw:reverse():rep(Hn % 3 + 2):len() then
            uH = uG.OnClientEvent:Connect(onOnClientEvent)
        else
            uG = uH.OnClientEvent:Connect(onOnClientEvent)
        end
        uu = (uu + 5) % 8
    until (uu * 7 + 0) % 8 == 1
end
local tA = uH
if tA then
    tB.Track(function()
        tA:Disconnect()
    end)
end
tK, tw, tr, tf, uk, uc, ty, up, tS, tD, tt, tg = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
tw = fn1278
tr = fn493
tf = fn233
uk = fn755
uc = fn759
ty = fn912
up = fn750
tS = fn764
tD = fn852
tt = fn687
tg = fn104
tK = {}
if uI then
    for i, v in ipairs(uI.Biomes) do
        table.insert(tK, v.Name)
    end
end
tY, tU, tH, tl, tN, tQ, tn, tV, t_, ug, tE, um, tL, to, ux, t0, tF = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
tH = fn559
tl = fn529
tN = fn1051
tY = 4
tU = 0.07
tQ = fn105
tn = fn993
tV = fn480
uv = fn145
t_ = fn758
ug = fn394
uA = fn599
tE = fn486
um = fn266
uD = fn1060
if (tU or not tV or not tV and not tL) and ((false or not tV) and (tU and ux)) and not ((tU or not tV or not tV and not tL) and ((false or not tV) and (tU and ux))) then
    uv = fn893
else
    tL = fn893
end
uu = fn303
uy = fn219
to = fn732
ux = fn150
t0 = fn574
uB = fn1227
uw = fn475
uC = fn1247
uz = fn1170
tB.BiomeValues = fn343
tB.RarityValues = fn1317
tB.JumpAmountValues = fn971
tF = fn78
tB.SetAutoSteal = fn216
tB.SetStealBiomes = fn106
tB.SetStopWhenPenFull = fn811
tB.SetBatDefense = fn1042
tB.SetAutoPlaceEggs = fn1047
tB.SetAutoHatch = fn537
tB.SetAutoEquipBest = fn202
tB.SetAutoTrail = fn961
tB.SetAutoRebirth = fn286
tB.SetAutoJump = fn903
tB.SetJumpAmount = fn263
tB.SetAutoEnclosure = fn1291
tB.SetAutoSell = fn937
tB.SetSellRarities = fn261
tB.SetAutoIndexRewards = fn136
tB.SetAutoOfflineCash = fn1192
tB.SetAutoGroupReward = fn391
tB.SetTeleportBiome = fn591
tB.TeleportToBiome = fn830
tB.TeleportToBase = fn503
uG = { uv, uA, uD, uu, uy, ux, uB, fn1093, uw, uC, uz }
ua()
for i, v in ipairs(uG) do
    local ur
    ur = task.spawn(v)
    tB.Track(function()
        if coroutine.status(ur) ~= "dead" then
            pcall(task.cancel, ur)
        end
    end)
end
t7 = nil
t7 = task.spawn(worker)
tB.Track(fn904)
uv = function()
    local iR = "v0.2"
    local iT = "https://discord.gg/K7Qxnxkk46"
    local iS = "https://discord.gg/K7Qxnxkk46"
    local iU = "https://tempohub.shop"
    local iQ = "Jump To Steal An Egg"
    local Library = getgenv().Library
    local ThemeManager = getgenv().ThemeManager
    local SaveManager = getgenv().SaveManager
    local Toggles = Library.Toggles
    local Options = Library.Options
    tP(tB, Library)
    local function i2(i3, i4)
        local BV = ts(setclipboard) and setclipboard
        local BW = BV
        if not BW then
            local BV_1 = ts(toclipboard) and toclipboard
            BW = BV_1 or nil
        end
        local BV_2 = BW
        if not BV_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local BW_1 = pcall(BV_2, i3)
        if BW_1 then
            Library:Notify(i4)
        else
            Library:Notify("Failed to copy")
        end
    end
    local function onDiscord()
        i2(iS, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = iS, Copyable = true }, "|", iQ, "|", iR },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(false)
    local jh = {
        [1] = Window:AddTab("Info", "info"),
        [2] = Window:AddTab("Main", "gamepad-2"),
        [3] = Window:AddTab("Player", "person-standing"),
        [4] = Window:AddTab("Settings", "settings")
    }
    local ji = {
        [1] = jh[2]:AddSubTab("Farm", "egg"),
        [2] = jh[2]:AddSubTab("Economy", "coins"),
        [3] = jh[2]:AddSubTab("Rewards", "gift")
    }
    local function jj(jk)
        local DiscordGroup = jk:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    jj(ji[1])
    jj(ji[2])
    jj(ji[3])
    jj(jh[3])
    jj(jh[4])
    local function jn()
        local AutoStealGroup = ji[1]:AddRightGroupbox("Auto Steal", "egg")
        local Label = AutoStealGroup:AddLabel(tB.GetStatus(), true)
        tB.OnStatus(function(js)
            if not Library.Unloaded then
                pcall(function()
                    Label:SetText(js)
                end)
            end
        end)
        AutoStealGroup:AddDivider()
        AutoStealGroup:AddToggle("AutoSteal", { Text = "Auto Steal Eggs", Default = false, Callback = tB.SetAutoSteal })
        AutoStealGroup:AddDropdown("StealBiomes", {
            Text = "Target Biomes",
            Values = tB.BiomeValues(),
            Default = nil,
            Multi = true,
            AllowNull = true,
            Callback = tB.SetStealBiomes
        })
        AutoStealGroup:AddToggle("StopWhenPenFull", { Text = "Stop Steal When Pen Full", Default = true, Callback = tB.SetStopWhenPenFull })
        AutoStealGroup:AddToggle("BatDefense", { Text = "Auto Bat Defense", Default = false, Callback = tB.SetBatDefense })
        local Base_FarmGroup = ji[1]:AddLeftGroupbox("Base & Farm", "house")
        Base_FarmGroup:AddToggle("AutoPlaceEggs", { Text = "Auto Place Eggs on Pen", Default = false, Callback = tB.SetAutoPlaceEggs })
        Base_FarmGroup:AddToggle("AutoHatch", { Text = "Auto Hatch Growing Eggs", Default = false, Callback = tB.SetAutoHatch })
        Base_FarmGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best Pets", Default = false, Callback = tB.SetAutoEquipBest })
        Base_FarmGroup:AddToggle("AutoTrail", { Text = "Auto Buy & Equip Best Trail", Default = false, Callback = tB.SetAutoTrail })
        Base_FarmGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false, Callback = tB.SetAutoRebirth })
        local UpgradesGroup = ji[2]:AddRightGroupbox("Upgrades", "trending-up")
        UpgradesGroup:AddToggle("AutoJump", { Text = "Auto Upgrade Jump Level", Default = false, Callback = tB.SetAutoJump })
        UpgradesGroup:AddDropdown("JumpAmount", {
            Text = "Jump Amount",
            Values = tB.JumpAmountValues(),
            Default = 3,
            Multi = false,
            AllowNull = false,
            Callback = tB.SetJumpAmount
        })
        UpgradesGroup:AddToggle("AutoEnclosure", { Text = "Auto Upgrade Enclosure / Plot", Default = false, Callback = tB.SetAutoEnclosure })
        local AutoSellGroup = ji[2]:AddLeftGroupbox("Auto Sell", "coins")
        AutoSellGroup:AddToggle("AutoSell", { Text = "Auto Sell Animals", Default = false, Callback = tB.SetAutoSell })
        AutoSellGroup:AddDropdown("SellRarities", {
            Text = "Sell Rarities",
            Values = tB.RarityValues(),
            Default = nil,
            Multi = true,
            AllowNull = true,
            Callback = tB.SetSellRarities
        })
        local RewardsGroup = ji[3]:AddRightGroupbox("Rewards", "gift")
        RewardsGroup:AddToggle("AutoIndexRewards", { Text = "Auto Claim Index Rewards", Default = false, Callback = tB.SetAutoIndexRewards })
        RewardsGroup:AddToggle("AutoOfflineCash", { Text = "Auto Claim Offline Cash", Default = false, Callback = tB.SetAutoOfflineCash })
        RewardsGroup:AddToggle("AutoGroupReward", { Text = "Auto Claim Group Reward", Default = false, Callback = tB.SetAutoGroupReward })
        local TeleportsGroup = ji[3]:AddLeftGroupbox("Teleports", "map-pin")
        local function jD(jE)
            local B3_1
            local B2_1
            B2_1, B3_1 = jE()
            if not B2_1 then
                local B2_2 = B3_1 or "Teleport failed"
                Library:Notify(tostring(B2_2))
            end
        end
        TeleportsGroup:AddDropdown("TeleportBiome", {
            Text = "Biome",
            Values = tB.BiomeValues(),
            Default = nil,
            Multi = false,
            AllowNull = true,
            Callback = tB.SetTeleportBiome
        })
        TeleportsGroup:AddButton({
            Text = "Teleport to Biome",
            Func = function()
                jD(tB.TeleportToBiome)
            end
        })
        TeleportsGroup:AddDivider()
        TeleportsGroup:AddButton({
            Text = "Teleport to Base",
            Func = function()
                jD(tB.TeleportToBase)
            end
        })
    end
    jn()
    local function jM()
        local Co
        local Cv
        local Cl
        local Cs
        Cl = nil
        Co = nil
        Cs = nil
        Cv = nil
        local Ck, Cm, Label, Cp, Cq, Cr, Ct, Label2, Label3
        Cs = function(jO)
            return (tostring(jO):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
        end
        Cl = function(jQ, jR)
            return string.format('<font color="%s">%s</font>', jR, Cs(jQ))
        end
        Ct = function(jU, jV, jW)
            return string.format("<b>%s</b> %s %s", jU, Cl("-", "#5a6070"), Cl(jV, jW))
        end
        local Cx = "#6ec1ff"
        local Cy = "#8b93a3"
        Cm = "#e8a34d"
        Cr = "#7fd47f"
        local Cz = tB.Support()
        local CA = #Cz == 0 and "ready"
        local CB = CA or "limited: " .. table.concat(Cz, ", ")
        Cq = "Unknown"
        pcall(function()
            local B6_1
            local B5_1
            if ts(identifyexecutor) then
                B6_1, B5_1 = identifyexecutor()
                local B7 = B6_1 ~= ""
                local B8 = type(B6_1) == "string" and B7
                if B8 then
                    local B7_1 = type(B5_1) == "string" and B5_1 ~= "" and B6_1 .. " " .. B5_1
                    Cq = B7_1 or B6_1
                end
            end
        end)
        Cv = os.clock()
        Cp = function()
            local Ca = math.floor(os.clock() - Cv)
            if Ca < 60 then
                return Ca .. "s"
            elseif Ca < 3600 then
                return string.format("%dm %ds", math.floor((Ca) / (60)), Ca % 60)
            else
                return string.format("%dh %dm", math.floor((Ca) / (3600)), math.floor((Ca % 3600) / (60)))
            end
        end
        local UserGroup = jh[1]:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(Ct("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, Cr), true)
        UserGroup:AddLabel(Ct("UserId", tostring(LocalPlayer.UserId), Cx), true)
        UserGroup:AddLabel(Ct("Executor", Cq .. "  " .. CB, Cr), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(Ct("Session", Cp(), Cm), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                i2(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                i2("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = jh[1]:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(Ct("Game", iQ, Cx), true)
        Label2 = SessionGroup:AddLabel(Ct("Players", "0/0", Cr), true)
        Ck = tostring(game.JobId)
        local Cx_1 = #Ck > 18 and string.sub(Ck, 1, 18) .. "..."
        local CA_2 = Cx_1 or Ck
        SessionGroup:AddLabel(Ct("Job", CA_2, Cy), true)
        Label = SessionGroup:AddLabel(Ct("Ping", "0 ms", Cm), true)
        SessionGroup:AddDivider()
        SessionGroup:AddButton({
            Text = "Rejoin Place",
            Func = function()
                tW:Teleport(game.PlaceId, LocalPlayer)
            end
        })
        SessionGroup:AddButton({
            Text = "Copy Job ID",
            Func = function()
                i2(Ck, "Copied Job ID")
            end
        })
        Co = task.spawn(function()
            local Cg_1
            local Cf_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(Ct("Session", Cp(), Cm))
                Label2:SetText(Ct("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), Cr))
                Cf_1, Cg_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local Cf_2 = Cf_1 and Cg_1 .. " ms" or "n/a"
                Label:SetText(Ct("Ping", Cf_2, Cm))
            end
        end)
        tB.Track(function()
            if coroutine.status(Co) ~= "dead" then
                pcall(task.cancel, Co)
            end
        end)
        local SocialsGroup = jh[1]:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                i2(iT, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                i2(iU, "Copied website link")
            end
        })
    end
    jM()
    local function k2()
        local k8
        local la
        local k9
        local k7
        local MovementGroup = jh[3]:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = jh[3]:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        la = {}
        local k6 = {}
        k7 = {}
        k9 = {}
        k8 = {}
        local function lb()
            for k, v in k7 do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(k7)
        end
        local function lf()
            for k, v in k8 do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(k8)
        end
        local function lj()
            for k, v in k9 do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(k9)
        end
        local function ln(lo)
            if not lo:IsA("ProximityPrompt") then
                return
            end
            if la[lo] == nil then
                la[lo] = {
                    HoldDuration = lo.HoldDuration,
                    MaxActivationDistance = lo.MaxActivationDistance,
                    RequiresLineOfSight = lo.RequiresLineOfSight
                }
            end
            lo.HoldDuration = 0
            lo.MaxActivationDistance = 50
            lo.RequiresLineOfSight = false
        end
        local function lq()
            for k, v in la do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(la)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                lj()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                lf()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                lb()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                    pcall(ln, v)
                end
            else
                lq()
            end
        end)
        table.insert(k6, Workspace.DescendantAdded:Connect(function(lJ)
            if Toggles.InstantProximityPrompt.Value then
                ln(lJ)
            end
        end))
        table.insert(k6, RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if k7[v] == nil then
                        k7[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(k6, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local Dw = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and Dw then
                Dw:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(k6, RunService.RenderStepped:Connect(function(l4)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local DF = Character and Character:FindFirstChildOfClass("Humanoid")
            local DG = Character
            if DG then
                DG = Character:FindFirstChild("HumanoidRootPart")
            end
            local DE_1 = DG
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and DF then
                if k8[DF] == nil then
                    k8[DF] = DF.WalkSpeed
                end
                DF.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and DE_1 and DF and CurrentCamera then
                if k9[DF] == nil then
                    k9[DF] = DF.PlatformStand
                end
                DF.PlatformStand = true
                local DG_4 = Vector3.zero
                if not UserInputService:GetFocusedTextBox() then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        DG_4 += CurrentCamera.CFrame.LookVector
                    end
                    local DM = if UserInputService:IsKeyDown(Enum.KeyCode.S) then 1 else 0
                    if DM == 1 then
                        DG_4 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        DG_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        DG_4 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        DG_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        DG_4 -= Vector3.new(0, 1, 0)
                    end
                end
                DE_1.AssemblyLinearVelocity = Vector3.zero
                if DG_4.Magnitude > 0 then
                    DE_1.CFrame = DE_1.CFrame + DG_4.Unit * Options.FlySpeed.Value * l4
                end
            end
        end))
        tB.Track(function()
            for k, v in k6 do
                v:Disconnect()
            end
            lb()
            lf()
            lj()
            lq()
        end)
    end
    k2()
    local function mk()
        local EZ, E_, E0, E1, Label, E3, E4, E5, E6, E7, E8, E9, Fa, Fb
        E4 = {}
        Fb = {}
        E8 = nil
        E5 = 0
        E_ = false
        E9 = 0
        E0 = os.clock()
        local MenuGroup = jh[4]:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        E6 = function()
            local CurrentCamera
            CurrentCamera = Workspace.CurrentCamera
            local DV = not CurrentCamera
            local DZ = if DV then 1 else 0
            local DX = 2128 * DZ + 441 * (1 - DZ)
            local DY = 1334 * DZ + 3823 * (1 - DZ)
            if not ((DX * 3071 + DY * 176 + DX * DY) % 16777213 == 9608624) then
                DV = not ts(VirtualUser.CaptureController)
            end
            local DZ_1 = if DV then 1 else 0
            local DX_1 = 1472 * DZ_1 + 2964 * (1 - DZ_1)
            local DY_1 = 3526 * DZ_1 + 603 * (1 - DZ_1)
            if not ((DX_1 * 3718 + DY_1 * 3329 + DX_1 * DY_1) % 16777213 == 5624009) then
                DV = not ts(VirtualUser.ClickButton2)
            end
            if DV then
                return false
            end
            local DV_1 = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            end)
            if not DV_1 then
                return false
            end
            E9 += 1
            E0 = os.clock()
            pcall(function()
                Label:SetText("AFK triggers: " .. E9)
            end)
            return true
        end
        E1 = function(mO)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not mO)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not mO
                end
            end)
            if not mO then
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
        EZ = function(m3)
            if m3.ClassName == "ParticleEmitter" or m3.ClassName == "Trail" or m3.ClassName == "Smoke" or m3.ClassName == "Fire" or m3.ClassName == "Sparkles" or m3.ClassName == "Explosion" or m3.ClassName == "Beam" then
                if E4[m3] == nil then
                    E4[m3] = m3.Enabled
                end
                pcall(function()
                    m3.Enabled = false
                end)
            end
        end
        Fa = function()
            for k, v in E4 do
                local Ec = k
                local Ee = v
                if Ec.Parent then
                    pcall(function()
                        Ec.Enabled = Ee
                    end)
                end
            end
            table.clear(E4)
            if E8 then
                pcall(function()
                    settings().Rendering.QualityLevel = E8.Quality
                end)
                Lighting.GlobalShadows = E8.Shadows
                Lighting.FogEnd = E8.Fog
                E8 = nil
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(ni)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not ni)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(nn)
                if nn then
                    if not E8 then
                        E8 = {
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
                        pcall(EZ, v)
                    end
                else
                    Fa()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        E1(true)
        local ScriptGroup = jh[4]:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiGameplayPause:OnChanged(function()
            E1(Toggles.AntiGameplayPause.Value)
        end)
        if Toggles.AntiGameplayPause.Value then
            E1(true)
        end
        table.insert(Fb, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                E6()
            end
        end))
        table.insert(Fb, Workspace.DescendantAdded:Connect(function(nG)
            if Toggles.FpsBoost.Value then
                EZ(nG)
            end
        end))
        E7 = function(nK)
            if E_ or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            E_ = true
            local Eu = E5
            local Ev_1 = pcall(function()
                if nK then
                    tW:Teleport(game.PlaceId, LocalPlayer)
                else
                    tW:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not Ev_1 then
                E_ = false
                if not nK and Eu == E5 then
                    task.delay(1.5, function()
                        if Eu == E5 then
                            E7(true)
                        end
                    end)
                end
            end
        end
        table.insert(Fb, tW.TeleportInitFailed:Connect(function(n1)
            local Ez
            if n1 == LocalPlayer and E_ then
                E_ = false
                Ez = E5
                task.delay(3, function()
                    if Ez == E5 then
                        E7(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local EH = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            if Library.Unloaded or not EH then
                return
            end
            table.insert(Fb, EH.ChildAdded:Connect(function(og)
                if og.Name == "ErrorPrompt" then
                    E7(false)
                end
            end))
        end)
        E3 = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    E1(true)
                end
                local EN = Toggles.AntiAfk.Value and os.clock() - E0 >= 60
                if EN then
                    E6()
                end
                task.wait(1)
            end
        end)
        tB.Track(function()
            E5 += 1
            for k, v in Fb do
                v:Disconnect()
            end
            pcall(task.cancel, E3)
            E1(false)
            Fa()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    mk()
    local function oD()
        local F3, F4, F5, F6
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("MyScriptHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(jh[4])
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/JumpToStealAnEgg")
        local F7 = SaveManager:BuildConfigSection(jh[4])
        F4 = function(oK, oL)
            local Ff_1 = (oK == "Toggle" and Toggles or Options)[oL]
            local Fe_2 = type(Ff_1) == "table" and Ff_1.Type == oK
            return Fe_2 and Ff_1 or nil
        end
        F6 = function(oU, oV)
            local Type = oV.Type
            if Type == "Toggle" then
                return { idx = oU, type = "Toggle", value = oV.Value == true }
            elseif Type == "Slider" then
                return { idx = oU, type = "Slider", value = tostring(oV.Value) }
            elseif Type == "Dropdown" then
                return { idx = oU, type = "Dropdown", multi = oV.Multi == true, value = oV.Value }
            elseif Type == "Input" then
                local Fj = oV.Value or ""
                return { idx = oU, type = "Input", text = tostring(Fj) }
            elseif Type == "ColorPicker" then
                return { idx = oU, type = "ColorPicker", value = oV.Value:ToHex(), transparency = oV.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = oU,
                    type = "KeyPicker",
                    mode = oV.Mode,
                    key = oV.Value,
                    modifiers = oV.Modifiers,
                    toggled = oV.Toggled
                }
            else
                return nil
            end
        end
        F5 = function()
            local Fm = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local Fn = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if Fn then
                        local Fn_1 = F6(k, v)
                        if Fn_1 then
                            Fm[#Fm + 1] = Fn_1
                        end
                    end
                end
            end
            table.sort(Fm, function(o4, o5)
                if o4.type ~= o5.type then
                    return o4.type < o5.type
                end
                return o4.idx < o5.idx
            end)
            return { objects = Fm }
        end
        F3 = function(o7)
            local FG
            FG = nil
            local FH = type(o7) ~= "table" or type(o7.idx) ~= "string" or type(o7.type) ~= "string" or SaveManager.Ignore[o7.idx]
            if FH then
                return false
            end
            FG = F4(o7.type, o7.idx)
            if not FG then
                return false
            end
            local FH_1 = pcall(function()
                if o7.type == "Input" then
                    if type(o7.text) ~= "string" then
                        return
                    end
                    FG:SetValue(o7.text)
                elseif o7.type == "ColorPicker" then
                    FG:SetValueRGB(Color3.fromHex(o7.value), o7.transparency)
                elseif o7.type == "KeyPicker" then
                    FG:SetValue({ o7.key, o7.mode, o7.modifiers })
                    if o7.mode == "Toggle" and o7.toggled ~= nil then
                        FG.Toggled = o7.toggled
                        FG:Update()
                    end
                else
                    FG:SetValue(o7.value)
                end
            end)
            return FH_1
        end
        F7:AddDivider()
        F7:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", AllowEmpty = true })
        F7:AddButton("Export Config to Clipboard", function()
            local FK_1
            local FJ_1
            FJ_1, FK_1 = pcall(HttpService.JSONEncode, HttpService, F5())
            if FJ_1 then
                local FJ_2 = ts(setclipboard) and setclipboard
                local FL = FJ_2
                if not FL then
                    local FJ_3 = ts(toclipboard) and toclipboard
                    local FM = FJ_3
                    local FQ = if FM then 1 else 0
                    local FO = 2455 * FQ + 3960 * (1 - FQ)
                    local FP = 3046 * FQ + 906 * (1 - FQ)
                    if not ((FO * 406 + FP * 1631 + FO * FP) % 16777213 == 13442686) then
                        FM = nil
                    end
                    FL = FM
                end
                local FJ_4 = FL
                local FL_1 = type(FJ_4) == "function" and pcall(FJ_4, FK_1)
                if FL_1 then
                    Library:Notify("Config copied to clipboard", 6)
                    return
                end
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Failed to encode the config")
        end)
        F7:AddButton("Import Config from Clipboard Text", function()
            local FT_1
            local FR = Options.SaveManager_ImportSource.Value or ""
            local FR_1
            local FS = tostring(FR):match("^%s*(.-)%s*$")
            if FS == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            if #FS > 262144 then
                Library:Notify("That config is too large")
                return
            end
            FR_1, FT_1 = pcall(HttpService.JSONDecode, HttpService, FS)
            local FS_1 = not FR_1 or type(FT_1) ~= "table" or type(FT_1.objects) ~= "table"
            if FS_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            if #FT_1.objects > 2048 then
                Library:Notify("That config has too many records")
                return
            end
            local FR_2 = 0
            for i, v in ipairs(FT_1.objects) do
                if F3(v) then
                    FR_2 += 1
                end
            end
            if FR_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local FT_2 = FR_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(FR_2, FT_2), 6)
        end)
        ThemeManager:LoadDefault()
        SaveManager:LoadAutoloadConfig()
        if Options.StealBiomes then
            tB.SetStealBiomes(Options.StealBiomes.Value)
        end
        if Options.JumpAmount then
            tB.SetJumpAmount(Options.JumpAmount.Value)
        end
        if Options.SellRarities then
            tB.SetSellRarities(Options.SellRarities.Value)
        end
        if Options.TeleportBiome then
            tB.SetTeleportBiome(Options.TeleportBiome.Value)
        end
        if Toggles.StopWhenPenFull then
            tB.SetStopWhenPenFull(Toggles.StopWhenPenFull.Value)
        end
        if Toggles.AutoPlaceEggs then
            tB.SetAutoPlaceEggs(Toggles.AutoPlaceEggs.Value)
        end
        if Toggles.AutoHatch then
            tB.SetAutoHatch(Toggles.AutoHatch.Value)
        end
        if Toggles.AutoEquipBest then
            tB.SetAutoEquipBest(Toggles.AutoEquipBest.Value)
        end
        if Toggles.AutoTrail then
            tB.SetAutoTrail(Toggles.AutoTrail.Value)
        end
        if Toggles.AutoJump then
            tB.SetAutoJump(Toggles.AutoJump.Value)
        end
        if Toggles.AutoEnclosure then
            tB.SetAutoEnclosure(Toggles.AutoEnclosure.Value)
        end
        if Toggles.AutoSell then
            tB.SetAutoSell(Toggles.AutoSell.Value)
        end
        if Toggles.AutoIndexRewards then
            tB.SetAutoIndexRewards(Toggles.AutoIndexRewards.Value)
        end
        if Toggles.AutoOfflineCash then
            tB.SetAutoOfflineCash(Toggles.AutoOfflineCash.Value)
        end
        if Toggles.AutoGroupReward then
            tB.SetAutoGroupReward(Toggles.AutoGroupReward.Value)
        end
        if Toggles.AutoRebirth then
            tB.SetAutoRebirth(Toggles.AutoRebirth.Value)
        end
        if Toggles.BatDefense then
            tB.SetBatDefense(Toggles.BatDefense.Value)
        end
        if Toggles.AutoSteal then
            tB.SetAutoSteal(Toggles.AutoSteal.Value)
        end
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    oD()
end
uv()
end)(...)

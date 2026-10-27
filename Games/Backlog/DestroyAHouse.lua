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
getgenv().TempoHoodSubtitle = "DESTROY A HOUSE"
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
local Qn_1, Qn_3, Qn_4, Qn_5, Qn_6, Qn_7, Qn_9, Qn_12, Qn_14, Qn_15, Qn_34
Qn_1 = nil
Qn_34 = nil
Qn_3 = nil
Qn_4 = nil
Qn_5 = nil
Qn_6 = nil
Qn_7 = nil
Qn_9 = nil
Qn_12 = nil
Qn_14 = nil
Qn_15 = nil
local zB
local Ai
local A_
local z_
local AH
local worker3
local zH
local Ao
local A5
local z5
local CollectionService
local Bu
local Au
local Bb
local Ab
local AT
local zA
local Ah
local AZ
local zZ
local AG
local zG
local An
local A4
local z4
local worker2
local Bt
local zM
local At
local worker4
local Aa
local CoreGui
local zS
local Az
local zz
local Ag
local AY
local zY
local AF
local State
local Bm
local AL
local Bs
local As
local A9
local zL
local z9
local AR
local By
local zR
local Ay
local zy
local Af
local zX
local Bl
local zE
local Al
local A2
local z2
local AK
local Br
local zK
local Ar
local z8
local AQ
local Bx
local zQ
local Ax
local zx
local Ae
local AW
local Be
local AD
local Bk
local zD
local A1
local z1
local Ak
local worker
local zJ
local A7
local z7
local AP
local Bw
local LocalPlayer
local Bd
local Ad
local AV
local zw
local zV
local zC
local Aj
local A0
local Bj
local z0
local AI
local zI
local Ap
function fns.fn3()
    local Iq
    for i, v in ipairs(Bj()) do
        local Ir = not Iq or Ay(Ak(v.Name)) > Ay(Ak(Iq.Name))
        if Ir then
            Iq = v
        end
    end
    return Iq
end
function fns.fn8(g0)
    local G5 = g0 and g0:FindFirstChild("HumanoidRootPart")
    local G6 = G5
    if G5 then
        G5 = G6:FindFirstChild("BuyPrompt")
    end
    local G7 = G6
    local G8 = G5
    if G7 then
        G7 = G8
    end
    if G7 then
        G7 = G8:IsA("ProximityPrompt")
    end
    if not G7 then
        return nil
    end
    local Workers = zx.Workers
    local G7_1 = Workers and Workers.Definitions
    local G5_2 = G7_1
    if G7_1 then
        G7_1 = G5_2[g0.Name]
    end
    local G5_3 = G7_1
    local G7_2 = type(G5_3) == "table" and tonumber(G5_3.Price)
    local G9 = G7_2 or nil
    local G9_1 = tonumber((tostring(G8.ActionText):gsub("[^%d]", "")))
    local Name = g0.Name
    local Hb = type(G5_3) == "table" and type(G5_3.Rarity) == "string"
    local G5_4 = Hb and G5_3.Rarity or "Common"
    local Hb_1 = G9_1 or G9
    local min = math.min
    local Hd = G9_1 or math.huge
    local G9_2 = G9 or math.huge
    return {
        model = g0,
        root = G6,
        prompt = G8,
        name = Name,
        rarity = G5_4,
        price = Hb_1,
        minPrice = min(Hd, G9_2)
    }
end
function fns.fn9(aR, aS, aT)
    if not aR then
        return nil
    end
    local CM = aR:FindFirstChild(aS)
    if CM then
        return CM
    end
    local CM_1 = aT or 10
    return aR:WaitForChild(aS, CM_1)
end
function fns.fn21(ix)
    if #Af == 0 then
        return true
    end
    for i, v in ipairs(Af) do
        if v == ix then
            return true
        end
    end
    return false
end
function fns.fn34()
    local KC = {}
    for i, v in ipairs(zH) do
        KC[#KC + 1] = v
    end
    return KC
end
function fns.fn86()
    return CoreGui
end
function fns.fn114(e1)
    local Upgrades = zx.Upgrades
    local Fs = Upgrades and Upgrades.Definitions
    local Fr_1 = Fs
    if Fs then
        Fs = Fr_1[e1]
    end
    local Fr_2 = Fs
    local Fs_1 = type(Fr_2) == "table" and Fr_2
    return Fs_1 or nil
end
function fns.fn128(f6)
    local Gi = {}
    if type(f6) == "table" then
        for i, v in ipairs(zS) do
            if f6[v.label] then
                Gi[#Gi + 1] = v.label
            end
        end
        if #Gi == 0 then
            for i, v in ipairs(f6) do
                local Gj_1 = type(v) == "string" and zM[v]
                if Gj_1 then
                    Gi[#Gi + 1] = v
                end
            end
        end
    else
        local Gj_2 = type(f6) == "string" and zM[f6]
        if Gj_2 then
            Gi[1] = f6
        end
    end
    A_ = Gi
end
function fns.fn158(aq)
    return string.format('<font color="%s">%s</font>', AF(aq), AP(aq))
end
function fns.fn198(nm)
    local LW = type(nm) == "number" and nm >= 0
    if LW then
        Qn_5 = math.floor(nm)
    end
end
function fns.fn203(kP)
    zD = kP == true
    if not zD then
        State.PlaceStatus = "Idle"
        return
    end
    local J0 = zw and coroutine.status(zw) ~= "dead"
    if J0 then
        return
    end
    zw = task.spawn(worker)
end
function fns.fn224(bo, ...)
    local C_ = Ae(bo)
    if not C_ then
        return false
    end
    local C0 = pcall(C_.Fire, C_, ...)
    return C0
end
function fns.fn227(cO)
    local Gears = zx.Gears
    local Ed = not Gears or type(cO) ~= "string"
    if Ed then
        return nil
    end
    for k, v in pairs(Gears) do
        local Ec_1 = type(v) == "table" and v.Model == cO
        if Ec_1 then
            return v
        end
    end
    return nil
end
function fns.fn287()
    while true do
        local Lu = zE() and zY
        if Lu then
            if #zV == 0 then
                State.GearStatus = "No gear types selected"
                task.wait(1.5)
            else
                local Lu_1 = A7()
                local Lv
                for i, v in ipairs(AH()) do
                    local Lw = Bw(v.style) and not Lu_1[v.model]
                    if Lw then
                        Lv = v
                        break
                    end
                end
                if not Lv then
                    State.GearStatus = "Owns every selected gear"
                    if zI then
                        A1()
                    end
                    task.wait(3)
                elseif AG() - Lv.cost < Qn_5 then
                    State.GearStatus = string.format("Saving for %s (%d)", Lv.model, Lv.cost)
                    task.wait(2)
                elseif Bx("BuyGear", Lv.model) then
                    task.wait(1)
                    if A7()[Lv.model] then
                        State.Gears = State.Gears + 1
                        State.GearStatus = "Bought " .. Lv.model
                        if zI then
                            A1()
                        end
                    else
                        State.GearStatus = "Cannot afford " .. Lv.model
                        task.wait(1.5)
                    end
                else
                    State.GearStatus = "Cannot reach the gear remote"
                    task.wait(1.5)
                end
            end
            continue
        end
        break
    end
    if zE() then
        State.GearStatus = "Idle"
    end
end
function fns.fn299()
    local Ks = 0
    for i, v in ipairs(zR()) do
        local Kt_1 = v.stored > 0 and Bx("WorkerCollect", v.key)
        if Kt_1 then
            Ks += 1
            State.Collected = State.Collected + 1
            task.wait(0.3)
        end
    end
    local Kt_2 = Ks > 0 and string.format("Collected from %d helpers", Ks)
    local Ku = Kt_2 or "Nothing stored yet"
    State.CollectStatus = Ku
    return Ks
end
function fns.fn302()
    local KK = {}
    local attr = LocalPlayer:GetAttribute("OwnedGears")
    if type(attr) == "string" then
        for k in attr:gmatch("[^,]+") do
            KK[k:match("^%s*(.-)%s*$")] = true
        end
    end
    return KK
end
function fns.fn308()
    local JQ_1
    local JP_1
    Br = true
    JQ_1, JP_1 = At()
    Br = false
    if JQ_1 then
        State.Helpers = State.Helpers + 1
    end
    State.BuyStatus = JP_1
    return JQ_1
end
function fns.fn324(eD)
    local Fd = eD == true
    local Fe = LocalPlayer:GetAttribute("AutoSell") == true
    if Fe == Fd then
        return true
    end
    return Bx("AutoSellToggle")
end
function fns.fn333()
    local GP = AT()
    local GQ = GP and GP:FindFirstChild("RNG")
    local GP_1 = GQ
    if GQ then
        GQ = GP_1:FindFirstChild("Lever")
    end
    local GP_2 = GQ
    if GQ then
        GQ = GP_2:FindFirstChild("Cylinder.001")
    end
    local GP_3 = GQ
    if GQ then
        GQ = GP_3:FindFirstChild("ProximityPrompt")
    end
    local GR = GQ
    if GQ then
        GQ = GR:IsA("ProximityPrompt")
    end
    if GQ then
        return GR, GP_3
    end
    return nil, GP_3
end
function fns.fn348()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local Fp = leaderstats and leaderstats:FindFirstChild("Coins")
    local Fo_1 = Fp
    if Fp then
        Fp = Fo_1:IsA("ValueBase")
    end
    if Fp then
        Fp = type(Fo_1.Value) == "number"
    end
    if Fp then
        return Fo_1.Value
    end
    return 0
end
function fns.fn351()
    return LocalPlayer:GetAttribute("OwnsAutoSell") == true
end
function fns.fn356(d4)
    zK = d4 == true
    if not zK then
        Ad = false
        State.BombStatus = "Idle"
        return
    end
    local EU = zB and coroutine.status(zB) ~= "dead"
    if EU then
        return
    end
    zB = task.spawn(Qn_34)
end
function fns.fn358(hJ)
    local HJ = hJ and hJ:IsA("ProximityPrompt")
    if not HJ then
        return false
    elseif not zQ(fireproximityprompt) then
        Bu("fireproximityprompt")
        return false
    else
        return (pcall(fireproximityprompt, hJ))
    end
end
function fns.fn360(kk)
    z0 = kk == true
    if not z0 then
        zJ = false
    end
end
function fns.fn371()
    local C9 = AR()
    local Da = Az() ~= nil and C9 ~= nil and C9.Health > 0
    return Da
end
function fns.fn372()
    local Gears = zx.Gears
    local KV = {}
    if not Gears then
        return KV
    end
    for k, v in pairs(Gears) do
        local KU_1 = type(v) == "table" and tonumber(v.Cost)
        local KW = KU_1 or nil
        local KW_1 = type(v) == "table" and type(v.Model) == "string" and KW and KW > 0
        if KW_1 then
            KV[#KV + 1] = { model = v.Model, style = tostring(v.Style), cost = KW }
        end
    end
    table.sort(KV, function(mn, mo)
        return mn.cost < mo.cost
    end)
    return KV
end
function fns.fn387()
    local El = A2()
    local Em = El and El:FindFirstChildOfClass("Tool")
    return Em or nil
end
function fns.fn419(j1)
    Aj = j1 == true
    if not Aj then
        State.BuyStatus = "Idle"
        return
    end
    local Jr = zZ and coroutine.status(zZ) ~= "dead"
    if Jr then
        return
    end
    zZ = task.spawn(worker2)
end
function fns.fn435()
    local D0_1
    local D__1
    local DY = z1()
    if #DY == 0 then
        return nil
    end
    local DZ = Az()
    if not DZ then
        return DY[1]
    end
    D0_1, D__1 = nil, nil
    local Position = DZ.Position
    for i, v in ipairs(DY) do
        local Magnitude = (v.Position - Position).Magnitude
        if not D__1 or Magnitude < D__1 then
            D0_1, D__1 = v, Magnitude
        end
    end
    return D0_1
end
function fns.fn460(ki)
    z4 = ki == true
end
function fns.fn473()
    local GH = {}
    for i, v in ipairs(Qn_4) do
        GH[#GH + 1] = v
    end
    return GH
end
function fns.fn479(kf)
    local JM = type(kf) == "number" and kf >= 0
    if JM then
        Aa = math.floor(kf)
    end
end
function fns.fn497()
    local C5 = A2()
    local C6 = C5 and C5:FindFirstChild("HumanoidRootPart")
    local C5_1 = C6
    if C6 then
        C6 = C5_1:IsA("BasePart")
    end
    return C6 and C5_1 or nil
end
function fns.fn505(lO)
    Ar = lO == true
    if not Ar then
        State.CollectStatus = "Idle"
        return
    end
    local Kq = Ag and coroutine.status(Ag) ~= "dead"
    if Kq then
        return
    end
    Ag = task.spawn(Ab)
end
function fns.fn508(dz)
    z8 = dz == true
    if not z8 then
        State.HammerStatus = "Idle"
        return
    end
    local EH = z_ and coroutine.status(z_) ~= "dead"
    if EH then
        return
    end
    z_ = task.spawn(zX)
end
function fns.fn517()
    gethui = Ao
end
function fns.fn544(dC)
    local EJ = type(dC) == "number" and dC > 0
    if EJ then
        z2 = math.clamp(dC, 0.1, 2)
    end
end
function fns.fn556(lU)
    An = lU == true
end
function fns.fn563()
    return LocalPlayer.Character
end
function fns.fn573(j7)
    local Jw = {}
    if type(j7) == "table" then
        for i, v in ipairs(Qn_4) do
            if j7[v] then
                Jw[#Jw + 1] = v
            end
        end
        if #Jw == 0 then
            for i, v in ipairs(j7) do
                if type(v) == "string" then
                    Jw[#Jw + 1] = v
                end
            end
        end
    else
        local Jx = j7 ~= ""
        local Jy = type(j7) == "string" and Jx
        if Jy then
            Jw[1] = j7
        end
    end
    Af = Jw
end
function fns.fn577(gu)
    local Workers = zx.Workers
    local GF = Workers and Workers.Definitions
    local GE_1 = GF
    if GF then
        GF = GE_1[gu]
    end
    local GE_2 = GF
    local GF_1 = type(GE_2) == "table" and type(GE_2.Rarity) == "string"
    if GF_1 then
        return GE_2.Rarity
    end
    return "Common"
end
function fns.fn586(aj)
    return (tostring(aj):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
end
function fns.fn627(ne)
    local LG = {}
    if type(ne) == "table" then
        for i, v in ipairs(zH) do
            if ne[v] then
                LG[#LG + 1] = v
            end
        end
        if #LG == 0 then
            for i, v in ipairs(ne) do
                if type(v) == "string" then
                    LG[#LG + 1] = v
                end
            end
        end
    else
        local LH = ne ~= ""
        local LI = type(ne) == "string" and LH
        if LI then
            LG[1] = ne
        end
    end
    zV = LG
end
function fns.fn637()
    local Ld = A7()
    local Le = {}
    for i, v in ipairs(AH()) do
        local Lf = Ld[v.model] and Bw(v.style)
        if Lf then
            local Lf_1 = Le[v.style]
            if not Lf_1 or v.cost > Lf_1.cost then
                Le[v.style] = v
            end
        end
    end
    for k, v in pairs(Le) do
        local Ld_1 = zy[k]
        local Le_1 = Ld_1 and LocalPlayer:GetAttribute(Ld_1) ~= v.model
        if Le_1 then
            Bx("EquipGear", v.model)
            task.wait(0.5)
        end
    end
end
function fns.fn640()
    z8 = false
    zK = false
    AD = false
    A5 = false
    zC = false
    Aj = false
    zD = false
    Qn_15 = false
    Ar = false
    zY = false
    Bd = false
    Ad = false
    Br = false
end
function fns.fn645()
    while true do
        local Ez = zE() and z8
        if Ez then
            local Ez_1 = Bd
            local EG = if Ez_1 then 1 else 0
            local EE = 3103 * EG + 2756 * (1 - EG)
            local EF = 1904 * EG + 855 * (1 - EG)
            if not ((EE * 2271 + EF * 1202 + EE * EF) % 16777213 == 15243633) then
                Ez_1 = Ad
            end
            if Ez_1 then
                State.HammerStatus = "Waiting for the character"
                task.wait(0.25)
            elseif not z9() then
                State.HammerStatus = "Waiting for the character"
                task.wait(0.5)
            else
                local Ez_2 = Bm()
                if not Ez_2 then
                    State.HammerStatus = "Waiting for the house"
                    task.wait(0.75)
                else
                    local attr = LocalPlayer:GetAttribute("LoadoutMelee")
                    local EB = attr ~= ""
                    local EC = type(attr) == "string" and EB
                    if EC then
                        Bt(attr)
                    end
                    if Bk(Ez_2.Position) > 12 then
                        if A9(15) then
                            Au(Ez_2.Position, Vector3.new(0, 4, 7))
                            Qn_14()
                        end
                        local EA_1 = Bm() or Ez_2
                        Ez_2 = EA_1
                    end
                    local EA_2 = Ez_2.Parent and Bk(Ez_2.Position) <= 14
                    if EA_2 then
                        if Bx("GearHit", Ez_2.Position) then
                            State.Hits = State.Hits + 1
                            State.HammerStatus = "Smashing the house"
                        else
                            State.HammerStatus = "Cannot reach the hit remote"
                        end
                    else
                        State.HammerStatus = "Moving to the house"
                    end
                    task.wait(z2)
                end
            end
            continue
        end
        break
    end
    if zE() then
        State.HammerStatus = "Idle"
    end
end
function fns.fn656()
    local FK = AT()
    local FL = FK and FK:FindFirstChild("Floors")
    local FK_1 = {}
    if not FL then
        return FK_1
    end
    for i, descendant in ipairs(FL:GetDescendants()) do
        local attr = descendant:GetAttribute("BuyKey")
        if type(attr) == "string" then
            FK_1[#FK_1 + 1] = { key = attr, model = descendant }
        end
    end
    return FK_1
end
function fns.fn684(ff, fg)
    local FF_1
    local Upgrades = zx.Upgrades
    local FE = not Upgrades or not zQ(Upgrades.priceFor)
    local FE_1
    if FE then
        return nil
    end
    FE_1, FF_1 = A0(Upgrades.priceFor, ff, fg)
    local FD_1 = FE_1 and type(FF_1) == "number"
    return FD_1 and FF_1 or nil
end
function fns.fn690()
    local attr = LocalPlayer:GetAttribute("BackpackCapacity")
    if LocalPlayer:GetAttribute("BackpackInfinite") == true then
        return math.huge
    end
    local EX = type(attr) == "number" and attr > 0
    if EX then
        return attr
    end
    return 0
end
function fns.fn739()
    local C2 = A2()
    local C3 = C2 and C2:FindFirstChildOfClass("Humanoid")
    return C3 or nil
end
function fns.fn755()
    local DM = Al()
    local DN = {}
    if not DM then
        return DN
    end
    for i, descendant in ipairs(DM:GetDescendants()) do
        local DM_1 = descendant:IsA("BasePart") and descendant.Anchored and not CollectionService:HasTag(descendant, "DebrisChunk")
        if DM_1 then
            DN[#DN + 1] = descendant
        end
    end
    return DN
end
function fns.fn793(Y)
    return type(Y) == "function"
end
function fns.fn807(gh)
    local Gx = type(gh) == "number" and gh >= 0
    if Gx then
        AW = math.floor(gh)
    end
end
function fns.fn818(aW, aX)
    local CP_1
    local CO_1
    if not aW then
        Bu(aX)
        return nil
    end
    CO_1, CP_1 = A0(require, aW)
    local CQ = not CO_1 or type(CP_1) ~= "table"
    if CQ then
        Bu(aX)
        return nil
    end
    return CP_1
end
function fns.fn828(np)
    zI = np == true
end
function fns.fn838()
    local H8 = {}
    local H9 = A2()
    if H9 then
        for i, child in ipairs(H9:GetChildren()) do
            local H9_1 = child:IsA("Tool") and child:GetAttribute("Worker")
            if H9_1 then
                H8[#H8 + 1] = child
            end
        end
    end
    local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if Backpack then
        for i, child in ipairs(Backpack:GetChildren()) do
            local H9_3 = child:IsA("Tool") and child:GetAttribute("Worker")
            if H9_3 then
                H8[#H8 + 1] = child
            end
        end
    end
    return H8
end
function fns.fn869()
    local DC = AY and AY.Parent and AY:GetAttribute("OwnerUserId") == LocalPlayer.UserId
    if DC then
        return AY
    end
    AY = nil
    local Plots = Bl:FindFirstChild("Plots")
    if not Plots then
        return nil
    end
    for i, child in ipairs(Plots:GetChildren()) do
        if child:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            AY = child
            return child
        end
    end
    return nil
end
function fns.fn871()
    return zx.missing
end
local function fn876()
    return math.max(By - os.clock(), 0)
end
local function fn929(ey)
    if type(ey) == "number" then
        Ax = math.clamp(ey, 1, 100)
    end
end
local function fn942(cd)
    local Dx = Az()
    if not Dx then
        return math.huge
    end
    return (Dx.Position - cd).Magnitude
end
local function fn959(e9)
    local FA = e9 and e9.Stat
    if type(FA) ~= "string" then
        return nil
    end
    local attr = LocalPlayer:GetAttribute("Upg" .. FA)
    local FB_1 = type(attr) == "number" and attr
    return FB_1 or nil
end
local function fn989()
    while true do
        local F_ = zE() and A5
        if F_ then
            local F__1 = false
            if #A_ == 0 then
                State.UpgradeStatus = "No upgrades selected"
            else
                local F0_1 = nil
                for i, v in ipairs(A_) do
                    local F1_1 = not A5
                    local F2 = not zE() or F1_1
                    if F2 then
                        break
                    else
                        local F1_2 = zM[v]
                        local F2_1 = F1_2 and Ah(F1_2)
                        local F3 = F2_1
                        if F2_1 then
                            F2_1 = zG(F3)
                        end
                        local F4 = F2_1
                        if F3 and F4 then
                            local F2_3 = tonumber(F3.MaxLevel)
                            if not (F2_3 and F4 >= F2_3) then
                                local F2_4 = Qn_1(F3, F4)
                                if F2_4 then
                                    if AG() - F2_4 >= AW then
                                        if Bx("BuyUpgrade", F1_2) then
                                            State.Upgrades = State.Upgrades + 1
                                            State.UpgradeStatus = "Bought " .. v
                                            F__1 = true
                                            task.wait(0.35)
                                        end
                                    elseif not F0_1 then
                                        F0_1 = string.format("Saving for %s (%d)", v, F2_4)
                                    end
                                end
                            end
                        end
                    end
                end
                local F1_3 = AQ and zz()
                if F1_3 then
                    F__1 = true
                end
                if not F__1 then
                    local F1_4 = F0_1 or "Nothing to upgrade"
                    State.UpgradeStatus = F1_4
                end
            end
            local wait = task.wait
            local F__2 = F__1 and 0.2 or 1.5
            wait(F__2)
            continue
        end
        break
    end
    if zE() then
        State.UpgradeStatus = "Idle"
    end
end
local function fn993(gr)
    local Gz = AK[gr]
    local GD = if Gz then 1 else 0
    local GB = 28 * GD + 2111 * (1 - GD)
    local GC = 3653 * GD + 1623 * (1 - GD)
    if not ((GB * 578 + GC * 1796 + GB * GC) % 16777213 == 6679256) then
        Gz = 0
    end
    return Gz
end
local function fn1000(ij)
    zC = ij == true
    if not zC then
        State.RollStatus = "Idle"
        return
    end
    local HX = Qn_6 and coroutine.status(Qn_6) ~= "dead"
    if HX then
        return
    end
    Qn_6 = task.spawn(worker3)
end
local function fn1022(bR)
    local Dj = os.clock()
    local Dl = Dj + (bR or 20)
    while true do
        local Dj_1 = Bd and zE() and os.clock() < Dl
        if Dj_1 then
            task.wait(0.1)
            continue
        end
        break
    end
    local Dj_2 = Bd or not zE()
    if Dj_2 then
        return false
    end
    Bd = true
    return true
end
local function fn1023()
    local GZ = AT()
    local G_ = GZ and GZ:FindFirstChild("RNG")
    local GZ_1 = G_
    if G_ then
        G_ = GZ_1:FindFirstChild("WorkerSlots")
    end
    local GZ_2 = G_
    if G_ then
        G_ = GZ_2:GetChildren()
    end
    return G_ or {}
end
local function fn1043(at, au)
    return string.format('<font color="%s">%s</font>  <font color="%s">%s</font>', A4, AP(at), Bb, AP(au))
end
local function fn1048()
    local Hs = AT()
    local Ht = Hs and Hs:FindFirstChild("Floors")
    if not Ht then
        return nil
    end
    local Ht_1 = z7()
    for i, child in ipairs(Ht:GetChildren()) do
        local Hs_2 = tonumber(tostring(child.Name):match("^Floor%s*(%d+)$"))
        local Hu = Hs_2 and child:FindFirstChild("Platforms")
        if Hu then
            for i, child in ipairs(Hu:GetChildren()) do
                local Hu_1 = tonumber(child.Name)
                local Hv_1 = Hu_1 and child:GetAttribute("BuyKey") == nil
                if Hv_1 then
                    local Hv_2 = string.format("%d:%d", Hs_2, Hu_1)
                    if not Ht_1[Hv_2] then
                        return Hv_2, child
                    end
                end
            end
        end
    end
    return nil
end
local function fn1050(bK)
    local Dc = os.clock()
    local Dd = bK
    local Di = if Dd then 1 else 0
    local Dg = 144 * Di + 2792 * (1 - Di)
    local Dh = 3793 * Di + 2057 * (1 - Di)
    if not ((Dg * 2053 + Dh * 1964 + Dg * Dh) % 16777213 == 8291276) then
        Dd = 10
    end
    local De = Dc + Dd
    while true do
        local Dc_1 = zE() and os.clock() < De
        if Dc_1 then
            if z9() then
                return true
            end
            task.wait(0.15)
            continue
        end
        break
    end
    return z9()
end
local function fn1067()
    local Hi = AT()
    local Hj = Hi and Hi:FindFirstChild("PlacedWorkers")
    local Hi_1 = {}
    if not Hj then
        return Hi_1
    end
    for i, child in ipairs(Hj:GetChildren()) do
        local attr = child:GetAttribute("PlatformKey")
        if type(attr) == "string" then
            Hi_1[attr] = true
        end
    end
    return Hi_1
end
local function fn1081(lp)
    Qn_15 = lp == true
    if not Qn_15 then
        State.ReplaceStatus = "Idle"
        return
    end
    local Kd = Be and coroutine.status(Be) ~= "dead"
    if Kd then
        return
    end
    Be = task.spawn(worker4)
end
local function fn1137(aB)
    for i, v in ipairs(zx.missing) do
        if v == aB then
            return
        end
    end
    table.insert(zx.missing, aB)
end
local function fn1148(es)
    AD = es == true
    if not AD then
        State.SellStatus = "Idle"
        return
    end
    local E3 = Qn_7 and coroutine.status(Qn_7) ~= "dead"
    if E3 then
        return
    end
    Qn_7 = task.spawn(z5)
end
local function fn1187(al)
    local Cr = tostring(al):match("^%a+") or ""
    if Cr == "Cannot" or Cr == "Failed" or Cr == "Missing" then
        return AV
    end
    local Ct_1 = Cr == "Idle" or Cr == "No"
    local Cr_4 = Cr == "Nothing"
    local Cu_1 = Ct_1
    local Cy = if Cu_1 then 1 else 0
    local Cw = 2594 * Cy + 994 * (1 - Cy)
    local Cx = 2189 * Cy + 2374 * (1 - Cy)
    if not ((Cw * 3097 + Cx * 2331 + Cw * Cx) % 16777213 == 2037230) then
        Cu_1 = Cr_4
    end
    if Cu_1 or Cr == "Waiting" then
        return AZ
    end
    return Bb
end
local function fn1213()
    local ClientBuildings = Bl:FindFirstChild("ClientBuildings")
    if not ClientBuildings then
        return nil
    end
    return ClientBuildings:FindFirstChild(tostring(LocalPlayer.UserId))
end
local function fn1236(m8)
    zY = m8 == true
    if not zY then
        State.GearStatus = "Idle"
        return
    end
    local LE = zA and coroutine.status(zA) ~= "dead"
    if LE then
        return
    end
    zA = task.spawn(zL)
end
local function fn1255()
    while true do
        local Kf = zE() and Ar
        if Kf then
            local Kf_1 = Ap()
            local attr = LocalPlayer:GetAttribute("Scraps")
            local Kh = type(attr) == "number" and attr
            if Kf_1 ~= math.huge and (Kh or 0) >= Kf_1 then
                State.CollectStatus = "Backpack is full"
                task.wait(1.5)
            else
                local Kf_2 = 0
                for i, v in ipairs(zR()) do
                    local Kg_2 = not Ar
                    local Kh_2 = not zE() or Kg_2
                    if Kh_2 then
                        break
                    end
                    local Kg_3 = v.instance:GetAttribute("StorageFull") == true
                    if v.stored > 0 and (not An or Kg_3) then
                        if Bx("WorkerCollect", v.key) then
                            Kf_2 += 1
                            State.Collected = State.Collected + 1
                            task.wait(0.35)
                        end
                    end
                end
                if Kf_2 > 0 then
                    State.CollectStatus = string.format("Collected from %d helpers", Kf_2)
                else
                    State.CollectStatus = "Nothing stored yet"
                end
                task.wait(2)
            end
            continue
        end
        break
    end
    if zE() then
        State.CollectStatus = "Idle"
    end
end
local function fn1261(gk)
    AQ = gk == true
end
local function fn1266()
    Bd = false
end
local function fn1267()
    return not Qn_3.Unloaded
end
local function fn1289(mv)
    if #zV == 0 then
        return false
    end
    for i, v in ipairs(zV) do
        if v == mv then
            return true
        end
    end
    return false
end
local function fn1359()
    local IO
    for i, v in ipairs(zR()) do
        local IP = not IO or Ay(v.rarity) < Ay(IO.rarity)
        if IP then
            IO = v
        end
    end
    return IO
end
local function fn1361(bf)
    local Network = zx.Network
    local CY = Network and Network[bf]
    local CY_1 = type(CY) ~= "table" or not zQ(CY.Fire)
    if CY_1 then
        Bu("Network." .. bf)
        return nil
    end
    return CY
end
local function fn1364()
    local FX = AT()
    if not FX then
        return false
    end
    local attr = FX:GetAttribute("NextPlatformPrice")
    if type(attr) ~= "number" then
        return false
    end
    local FX_1 = Ai()
    if #FX_1 == 0 then
        return false
    elseif AG() - attr < AW then
        State.UpgradeStatus = string.format("Saving for a platform (%d)", attr)
        return false
    elseif Bx("BuyPlatform", FX_1[1].key) then
        State.Upgrades = State.Upgrades + 1
        State.UpgradeStatus = "Built a platform"
        task.wait(0.6)
        return true
    else
        return false
    end
end
local function fn1365()
    if Bx("SellScraps") then
        State.Sells = State.Sells + 1
        return true
    end
    return false
end
local function fn1366()
    local Fg = {}
    for i, v in ipairs(zS) do
        Fg[#Fg + 1] = v.label
    end
    return Fg
end
local function fn1376(f3)
    A5 = f3 == true
    if not A5 then
        State.UpgradeStatus = "Idle"
        return
    end
    local Gd = AL and coroutine.status(AL) ~= "dead"
    if Gd then
        return
    end
    AL = task.spawn(AI)
end
local function fn1378()
    local CS = Qn_9(Bs, "Shared", 20)
    local CT = CS and Qn_9(CS, "Data", 20)
    local CU = CS and CS:FindFirstChild("Network")
    zx.Network = Qn_12(CU, "Shared.Network")
    local CS_1 = CT and CT:FindFirstChild("Gears")
    zx.Gears = Qn_12(CS_1, "Data.Gears")
    local CS_2 = CT and CT:FindFirstChild("Workers")
    zx.Workers = Qn_12(CS_2, "Data.Workers")
    local CS_3 = CT and CT:FindFirstChild("Upgrades")
    zx.Upgrades = Qn_12(CS_3, "Data.Upgrades")
end
local function fn1399()
    while true do
        local EO = zE() and zK
        if EO then
            local EO_1 = Bd or not z9()
            if EO_1 then
                State.BombStatus = "Waiting for the character"
                task.wait(0.4)
            else
                local attr2 = LocalPlayer:GetAttribute("LoadoutBomb")
                local EP = attr2 == ""
                local EQ = type(attr2) ~= "string" or EP
                if EQ then
                    State.BombStatus = "No bomb in the loadout"
                    task.wait(1)
                else
                    local EP_1 = By - os.clock()
                    if EP_1 > 0 then
                        State.BombStatus = string.format("Bomb ready in %ds", math.ceil(EP_1))
                        task.wait(math.min(EP_1, 1))
                    else
                        local EP_2 = Bm()
                        if not EP_2 then
                            State.BombStatus = "Waiting for the house"
                            task.wait(0.75)
                        else
                            local EQ_1 = Bk(EP_2.Position) > 12 and A9(15)
                            if EQ_1 then
                                Au(EP_2.Position, Vector3.new(0, 4, 7))
                                Qn_14()
                                local EQ_2 = Bm() or EP_2
                                EP_2 = EQ_2
                            end
                            local attr = LocalPlayer:GetAttribute("LoadoutMelee")
                            Ad = true
                            if not Bt(attr2) then
                                State.BombStatus = "Cannot equip " .. attr2
                                Ad = false
                                task.wait(1)
                            else
                                local ER = Bx("GearHit", EP_2.Position)
                                local EP_3 = As(attr2)
                                local ES = EP_3 and tonumber(EP_3.Cooldown)
                                local EP_4 = ES or 15
                                if ER then
                                    State.Bombs = State.Bombs + 1
                                    State.BombStatus = "Threw " .. attr2
                                    By = os.clock() + EP_4
                                else
                                    State.BombStatus = "Cannot reach the hit remote"
                                    By = os.clock() + 2
                                end
                                task.wait(0.6)
                                local EO_3 = attr ~= ""
                                local EP_5 = type(attr) == "string" and EO_3
                                if EP_5 then
                                    Bt(attr)
                                end
                                Ad = false
                            end
                        end
                    end
                end
            end
            continue
        end
        break
    end
    if zE() then
        State.BombStatus = "Idle"
    end
end
local function fn1418()
    local Iz = AT()
    local IA = Iz and Iz:FindFirstChild("PlacedWorkers")
    local Iz_1 = {}
    if not IA then
        return Iz_1
    end
    for i, child in ipairs(IA:GetChildren()) do
        local attr = child:GetAttribute("PlatformKey")
        if type(attr) == "string" then
            local IB_1 = #Iz_1 + 1
            local IC = child:GetAttribute("Worker") or child.Name
            local ID = tostring(IC)
            local IE = child:GetAttribute("Rarity") or "Common"
            local IF = tostring(IE)
            local IG = tonumber(child:GetAttribute("StoredScraps")) or 0
            Iz_1[IB_1] = { instance = child, key = attr, name = ID, rarity = IF, stored = IG }
        end
    end
    return Iz_1
end
local function fn1426()
    while true do
        local EZ = zE() and AD
        if EZ then
            local attr = LocalPlayer:GetAttribute("Scraps")
            local E_ = type(attr) ~= "number" or attr <= 0
            if E_ then
                State.SellStatus = "Nothing to sell"
            else
                local E__1 = Ap()
                local E0 = E__1 == math.huge and 1
                local E1 = E0 or math.max(math.floor(E__1 * Ax / 100), 1)
                if attr >= E1 then
                    if Bx("SellScraps") then
                        State.Sells = State.Sells + 1
                        State.SellStatus = string.format("Sold %d scraps", attr)
                        task.wait(0.6)
                    else
                        State.SellStatus = "Cannot reach the sell remote"
                    end
                else
                    State.SellStatus = string.format("Holding %d / %d scraps", attr, E1)
                end
            end
            task.wait(1)
            continue
        end
        break
    end
    if zE() then
        State.SellStatus = "Idle"
    end
end
local function fn1434(V)
    local Cp = typeof(cloneref) == "function" and typeof(V) == "Instance"
    if Cp then
        return cloneref(V)
    end
    return V
end
zw = nil
zx = nil
zy = nil
zz = nil
zA = nil
zB = nil
zC = nil
zD = nil
zE = nil
State = nil
zG = nil
zH = nil
zI = nil
zJ = nil
zK = nil
zL = nil
zM = nil
Qn_5 = nil
zQ = nil
zR = nil
zS = nil
Qn_12 = nil
zV = nil
zX = nil
zY = nil
zZ = nil
z_ = nil
z0 = nil
z1 = nil
z2 = nil
z4 = nil
z5 = nil
Qn_3 = nil
z7 = nil
z8 = nil
z9 = nil
Aa = nil
Ab = nil
Qn_9 = nil
Ad = nil
Ae = nil
Af = nil
Ag = nil
Ah = nil
local Players, zN, zP, zT, zW, z3
Ai = nil
Aj = nil
Ak = nil
Al = nil
An = nil
Ao = nil
Ap = nil
Ar = nil
As = nil
At = nil
Au = nil
Qn_7 = nil
LocalPlayer = nil
Ax = nil
Ay = nil
Az = nil
Qn_14 = nil
AD = nil
AF = nil
AG = nil
AH = nil
AI = nil
AK = nil
AL = nil
worker2 = nil
CollectionService = nil
Qn_4 = nil
AP = nil
AQ = nil
AR = nil
CoreGui = nil
AT = nil
AV = nil
AW = nil
AY = nil
AZ = nil
A_ = nil
A0 = nil
A1 = nil
A2 = nil
A4 = nil
local Am, Aq, Workspace, AC, Lighting, TeleportService, AU, GuiService, HttpService
A5 = nil
Qn_1 = nil
A7 = nil
A9 = nil
worker4 = nil
Bb = nil
Bd = nil
Be = nil
Qn_15 = nil
Bj = nil
Bk = nil
Bl = nil
Bm = nil
worker3 = nil
Qn_34 = nil
worker = nil
Br = nil
Bs = nil
Bt = nil
Bu = nil
Qn_6 = nil
Bw = nil
Bx = nil
By = nil
local VirtualUser, UserInputService, Bf, Bg, RunService, Bn
VirtualUser = nil
UserInputService = nil
Bf = nil
Bg = nil
RunService = nil
Bn = nil
if not game:IsLoaded() then
    game.Loaded:Wait()
end
Players, RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, CollectionService, TeleportService, Lighting, Workspace, LocalPlayer, Ao = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
CollectionService = game:GetService("CollectionService")
TeleportService = game:GetService("TeleportService")
Lighting = game:GetService("Lighting")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local Qn_21 = "TempoDestroyAHouse"
Ao = fns.fn86
if getgenv then
    getgenv().gethui = Ao
end
Qn_3, Bs, Bl, Bf, AC, zQ, zE = nil, nil, nil, nil, nil, nil, nil
pcall(fns.fn517)
local function Qn_31(u)
    local Ch
    local Ci
    local Cg
    Cg = nil
    Ch = nil
    Ci = nil
    local Cj = u ~= ""
    local Ck = type(u) == "string" and Cj
    assert(Ck, "A namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    Ch = getgenv()
    assert(type(Ch) == "table", "getgenv did not return a table")
    local Cj_1 = Ch[u]
    if Cj_1 ~= nil then
        local Ck_1 = type(Cj_1) == "table" and type(Cj_1.Unload) == "function"
        assert(Ck_1, "Namespace is occupied")
        Cj_1.Unload()
        assert(Ch[u] == nil, "Previous instance did not release its namespace")
    end
    Ci = {}
    Cg = { State = {}, Unloaded = false }
    Cg.Track = function(A)
        assert(type(A) == "function", "Cleanup must be callable")
        if Cg.Unloaded then
            A()
        else
            table.insert(Ci, A)
        end
        return A
    end
    Cg.Unload = function()
        local B3_1
        local B2_1
        if Cg.Unloaded then
            return
        end
        Cg.Unloaded = true
        local B0 = {}
        local Ca = #Ci
        local B9 = -1
        while false and Ca <= 1 or true and Ca >= 1 do
            local Cb = Ca
            local B1_1 = table.remove(Ci, Cb)
            B2_1, B3_1 = pcall(B1_1)
            if not B2_1 then
                table.insert(B0, tostring(B3_1))
            end
            Ca += B9
        end
        table.clear(Cg.State)
        if #B0 > 0 then
            error("Cleanup incomplete: " .. table.concat(B0, "; "), 0)
        end
        if Ch[u] == Cg then
            Ch[u] = nil
        end
    end
    Ch[u] = Cg
    return Cg
end
AC = function(N, O)
    local Cn = type(N) == "table" and type(N.Track) == "function"
    assert(Cn, "FeatureAPI required")
    local Cn_1 = type(O) == "table" and type(O.OnUnload) == "function"
    assert(Cn_1, "UI library required")
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
Qn_3 = Qn_31(Qn_21)
local Qn_29 = fn1434
zQ = fns.fn793
zE = fn1267
Bs = Qn_29(ReplicatedStorage)
Bl = Qn_29(Workspace)
Bf = {}
Bb, A4, AZ, AV, AP, AF = nil, nil, nil, nil, nil, nil
Bb = "#ffb3d9"
A4 = "#6a7080"
AZ = "#7c8290"
AV = "#e0788c"
AP = fns.fn586
AF = fn1187
Bf.status = fns.fn158
Bf.field = fn1043
State, zx, Bd, AY, Ad, z8, z2, z_, zK, zB, By, AD, Ax, Qn_7, zS, zM, Bu, A0, Qn_9, Qn_12, Ae, Bx, A2, AR, Az, z9, zP, A9, Qn_14, Au, Bk, AT, Al, z1, Bm, As, zT, Bt, zX, Qn_34, Ap, z5 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
State = Qn_3.State
State.HammerStatus = "Idle"
State.BombStatus = "Idle"
State.SellStatus = "Idle"
State.UpgradeStatus = "Idle"
State.RollStatus = "Idle"
State.BuyStatus = "Idle"
State.PlaceStatus = "Idle"
State.ReplaceStatus = "Idle"
State.CollectStatus = "Idle"
State.GearStatus = "Idle"
State.Hits = 0
State.Bombs = 0
State.Sells = 0
State.Upgrades = 0
State.Rolls = 0
State.Helpers = 0
State.Replacements = 0
State.Collected = 0
State.Gears = 0
zx = { missing = {} }
Bu = fn1137
A0 = function(aG, ...)
    local CG
    local CH
    CG = nil
    CH = nil
    local CK_1
    local CJ_1
    if not zQ(aG) then
        return false, "not callable"
    end
    CG = table.pack(...)
    CH = nil
    local CI = coroutine.create(function()
        CH = table.pack(pcall(aG, table.unpack(CG, 1, CG.n)))
    end)
    CJ_1, CK_1 = coroutine.resume(CI)
    if not CJ_1 then
        return false, CK_1
    end
    local CJ_2 = not CH
    local CK_2 = coroutine.status(CI) ~= "dead" or CJ_2
    if CK_2 then
        return false, "call did not finish"
    end
    return table.unpack(CH, 1, CH.n)
end
Qn_9 = fns.fn9
Qn_12 = fns.fn818
Qn_21 = fn1378
Qn_21()
Ae = fn1361
Bx = fns.fn224
A2 = fns.fn563
AR = fns.fn739
Az = fns.fn497
z9 = fns.fn371
zP = fn1050
Bd = false
A9 = fn1022
Qn_14 = fn1266
Au = function(b_, b0)
    local Do
    local Dn
    Dn = nil
    Do = nil
    if not zP(8) then
        return false
    end
    Do = Az()
    if not Do then
        return false
    end
    local Dp = b0 or Vector3.new(0, 4, 5)
    Dn = b_ + Dp
    local Dp_1 = pcall(function()
        Do.CFrame = CFrame.new(Dn, b_)
    end)
    if not Dp_1 then
        return false
    end
    task.wait(0.55)
    local Dp_2 = zE() and Az() ~= nil
    return Dp_2
end
Bk = fn942
AT = fns.fn869
Al = fn1213
z1 = fns.fn755
Bm = fns.fn435
As = fns.fn227
zT = fns.fn387
Bt = function(c_)
    local Er
    local Es
    Er = nil
    Es = nil
    local Et = c_ == ""
    local Eu = type(c_) ~= "string" or Et
    if Eu then
        return false
    end
    local Et_1 = zT()
    if Et_1 and Et_1.Name == c_ then
        return true
    end
    Es = AR()
    local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local Eu_2 = Backpack and Backpack:FindFirstChild(c_)
    Er = Eu_2
    if not Es or not Er then
        return false
    end
    local Et_4 = pcall(function()
        Es:EquipTool(Er)
    end)
    if not Et_4 then
        return false
    end
    task.wait(0.2)
    local Et_5 = zT()
    return Et_5 ~= nil and Et_5.Name == c_
end
Ad = false
z8 = false
z2 = 0.3
zX = fns.fn645
Qn_3.SetAutoHammer = fns.fn508
Qn_3.SetHammerInterval = fns.fn544
zK = false
By = 0
Qn_34 = fn1399
Qn_3.SetAutoBomb = fns.fn356
Qn_3.BombCooldownRemaining = fn876
AD = false
Ax = 90
Ap = fns.fn690
z5 = fn1426
Qn_3.SetAutoSell = fn1148
Qn_3.SetSellPercent = fn929
Qn_3.SellNow = fn1365
Qn_3.OwnsGameAutoSell = fns.fn351
Qn_3.SetGameAutoSell = fns.fn324
zS = {
    { label = "Player Strength", key = "PlayerStrength" },
    { label = "Helper Strength", key = "HelperStrength" },
    { label = "Luck", key = "Luck" },
    { label = "Rolls", key = "Rolls" },
    { label = "Sell Boost", key = "Sell" },
    { label = "Backpack Storage", key = "Storage" },
    { label = "Platforms", key = "Platforms" },
    { label = "Expand Base", key = "ExpandBase" },
    { label = "House Level", key = "House" }
}
zM = {}
for i, v in ipairs(zS) do
    zM[v.label] = v.key
end
A5, A_, AW, AQ, AL, Qn_4, AK, AG, Ah, zG, Qn_1, Ai, zz, AI = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Qn_3.UpgradeLabels = fn1366
A5 = false
A_ = {}
AW = 0
AQ = true
AG = fns.fn348
Ah = fns.fn114
zG = fn959
Qn_1 = fns.fn684
Ai = fns.fn656
zz = fn1364
AI = fn989
Qn_3.SetAutoUpgrade = fn1376
Qn_3.SetUpgradeSelection = fns.fn128
Qn_3.SetUpgradeReserve = fns.fn807
Qn_3.SetBuildPlatforms = fn1261
Qn_4 = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Godly", "Secret" }
AK = {}
for i, v in ipairs(Qn_4) do
    AK[v] = i
end
zJ, zC, Qn_6, Aj, Af, Aa, z4, z0, zZ, Br, zD, zw, Qn_15, Be, Ar, An, Ag, zH, zy, zY, zV, Qn_5, zI, zA, Ay, Ak, Bg, Am, zN, z7, Bn, z3, worker3, zW, Bj, Aq, zR, AU, At, worker2, worker, worker4, Ab, A7, AH, Bw, A1, zL = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Ay = fn993
Ak = fns.fn577
Qn_3.RarityNames = fns.fn473
Bg = fns.fn333
Am = fn1023
zN = fns.fn8
z7 = fn1067
Bn = fn1048
z3 = fns.fn358
zJ = false
zC = false
worker3 = function()
    local HP_1
    local Name
    local HM_1
    Name, HM_1 = nil, os.clock()
    local HW = false
    repeat
        local HO = zE() and zC
        local HO_1
        if HO then
            HP_1, HO_1 = Bg()
            if not HP_1 or not HO_1 then
                State.RollStatus = "Waiting for the roll lever"
                task.wait(1)
            elseif not z9() then
                State.RollStatus = "Waiting for the character"
                task.wait(0.5)
            else
                local HQ_1 = Am()
                local HR_1 = HQ_1[1]
                if HR_1 then
                    if HR_1.Name ~= Name then
                        Name, HM_1 = HR_1.Name, os.clock()
                    end
                else
                    Name = nil
                end
                local HQ_2 = HR_1 ~= nil
                if HQ_2 then
                    local HS_1 = zJ or os.clock() - HM_1 > 12
                    HQ_2 = HS_1
                end
                if HR_1 and not HQ_2 then
                    State.RollStatus = "Waiting on " .. HR_1.Name
                    task.wait(0.75)
                elseif A9(20) then
                    local HQ_4 = Az() and Az().CFrame
                    local HR_2 = true
                    local HL = HQ_4
                    if Bk(HO_1.Position) > 9 then
                        HR_2 = Au(HO_1.Position, Vector3.new(0, 4, 5))
                    end
                    local HO_2 = HR_2 and z3(HP_1)
                    if HO_2 then
                        State.Rolls = State.Rolls + 1
                        State.RollStatus = "Rolling a helper"
                        Name, HM_1 = nil, os.clock()
                        zJ = false
                    else
                        State.RollStatus = "Cannot pull the lever"
                    end
                    task.wait(0.35)
                    local HO_3 = HL and not zK and not z8 and Az()
                    if HO_3 then
                        pcall(function()
                            Az().CFrame = HL
                        end)
                    end
                    Qn_14()
                    task.wait(1.6)
                else
                    task.wait(0.5)
                end
            end
        else
            HW = true
        end
    until HW
    if zE() then
        State.RollStatus = "Idle"
    end
end
Qn_3.SetAutoRoll = fn1000
Aj = false
Af = {}
Aa = 0
z4 = true
z0 = false
zW = fns.fn21
Br = false
Bj = fns.fn838
Aq = fns.fn3
zR = fn1418
AU = fn1359
At = function(jd)
    local IX
    local IY
    local IY_2
    if type(jd) == "string" then
        for i, v in ipairs(Bj()) do
            if v.Name == jd then
                IY = v
                break
            end
        end
    end
    local IZ = IY or Aq()
    local IZ_1
    if not IZ then
        return false, "Nothing to place"
    end
    IZ_1, IX = Bn()
    local I_ = not IX
    local I__1
    if not IZ_1 or I_ then
        return false, "No free platform"
    elseif not Bt(IZ.Name) then
        return false, "Cannot hold " .. IZ.Name
    else
        IY_2, I__1 = pcall(function()
            return IX:GetPivot().Position
        end)
        local I0_1 = IY_2 and Bk(I__1) > 10
        if I0_1 then
            Au(I__1, Vector3.new(0, 5, 4))
        end
        if not Bx("PlaceWorker", IZ_1) then
            return false, "Cannot reach the place remote"
        end
        task.wait(0.8)
        return z7()[IZ_1] == true, "Placed on " .. IZ_1
    end
end
worker2 = function()
    local Jh = false
    repeat
        local Jc = zE() and Aj
        if Jc then
            local Jq_1 = if not z9() then 1 else 0
            if Jq_1 == 1 then
                State.BuyStatus = "Waiting for the character"
                task.wait(0.5)
            else
                local Jc_1 = nil
                for i, v in ipairs(Am()) do
                    Jc_1 = zN(v)
                    if Jc_1 then
                        break
                    end
                end
                if not Jc_1 then
                    State.BuyStatus = "Waiting for a rolled helper"
                    task.wait(0.75)
                elseif not zW(Jc_1.rarity) then
                    State.BuyStatus = string.format("Skipping %s (%s)", Jc_1.name, Jc_1.rarity)
                    task.wait(1)
                else
                    local Jd = Aa > 0 and Jc_1.price and Jc_1.price > Aa
                    local Jd_5
                    if Jd then
                        State.BuyStatus = string.format("Skipping %s (too costly)", Jc_1.name)
                        task.wait(1)
                    else
                        local Jd_1 = Jc_1.minPrice and Jc_1.minPrice < math.huge and AG() < Jc_1.minPrice
                        if Jd_1 then
                            if z0 then
                                zJ = true
                                State.BuyStatus = string.format("Skipping %s (cannot afford)", Jc_1.name)
                            else
                                State.BuyStatus = string.format("Saving for %s (%d)", Jc_1.name, Jc_1.minPrice)
                            end
                            task.wait(1.5)
                        else
                            local Jd_2 = z4 and not Bn()
                            if Jd_2 then
                                State.BuyStatus = "No free platform"
                                task.wait(2)
                            elseif A9(25) then
                                local Jd_3 = Az() and Az().CFrame
                                local Je = true
                                local Je_1
                                local Jb = Jd_3
                                if Bk(Jc_1.root.Position) > 10 then
                                    Je = Au(Jc_1.root.Position, Vector3.new(0, 4, 5))
                                end
                                local Jd_4 = Je and z3(Jc_1.prompt)
                                if Jd_4 then
                                    task.wait(0.9)
                                    if Jc_1.model.Parent == nil then
                                        State.BuyStatus = "Bought " .. Jc_1.name
                                        if z4 then
                                            Br = true
                                            Jd_5, Je_1 = At(Jc_1.name)
                                            Br = false
                                            if Jd_5 then
                                                State.Helpers = State.Helpers + 1
                                                State.BuyStatus = Jc_1.name .. " " .. string.lower(Je_1)
                                            else
                                                State.BuyStatus = Je_1
                                            end
                                        else
                                            State.Helpers = State.Helpers + 1
                                        end
                                    else
                                        if z0 then
                                            zJ = true
                                        end
                                        State.BuyStatus = "Cannot afford " .. Jc_1.name
                                        task.wait(1.5)
                                    end
                                else
                                    State.BuyStatus = "Cannot use the buy prompt"
                                end
                                local Jc_2 = Jb and not zK and not z8 and Az()
                                if Jc_2 then
                                    pcall(function()
                                        Az().CFrame = Jb
                                    end)
                                end
                                Qn_14()
                                task.wait(1)
                            else
                                task.wait(0.5)
                            end
                        end
                    end
                end
            end
        else
            Jh = true
        end
    until Jh
    local Jq_2 = if zE() then 1 else 0
    if Jq_2 == 1 then
        State.BuyStatus = "Idle"
    end
end
Qn_3.SetAutoBuyHelper = fns.fn419
Qn_3.SetBuyRarities = fns.fn573
Qn_3.SetBuyMaxPrice = fns.fn479
Qn_3.SetBuyAutoPlace = fns.fn460
Qn_3.SetBuySkipUnaffordable = fns.fn360
Qn_3.PlacePendingHelper = fns.fn308
zD = false
worker = function()
    local JU_1
    local JX = false
    repeat
        local JT = zE() and zD
        local JT_3
        if JT then
            local JT_1 = Br or not z9()
            if JT_1 then
                task.wait(0.4)
            elseif #Bj() == 0 then
                State.PlaceStatus = "No helper to place"
                task.wait(1)
            elseif not Bn() then
                State.PlaceStatus = "No free platform"
                task.wait(2)
            else
                local J_ = if A9(20) then 1 else 0
                if J_ == 1 then
                    local JT_2 = Az() and Az().CFrame
                    local JS = JT_2
                    Br = true
                    JT_3, JU_1 = At()
                    Br = false
                    if JT_3 then
                        State.Helpers = State.Helpers + 1
                    end
                    State.PlaceStatus = JU_1
                    local JT_4 = JS and Az()
                    if JT_4 then
                        pcall(function()
                            Az().CFrame = JS
                        end)
                    end
                    Qn_14()
                    task.wait(0.8)
                else
                    task.wait(0.5)
                end
            end
        else
            JX = true
        end
    until JX
    if zE() then
        State.PlaceStatus = "Idle"
    end
end
Qn_3.SetAutoPlaceHelpers = fns.fn203
Qn_15 = false
worker4 = function()
    local J9 = false
    repeat
        local J3 = zE() and Qn_15
        if J3 then
            local J3_1 = Br or not z9()
            if J3_1 then
                task.wait(0.4)
            else
                local J3_2 = Aq()
                if not J3_2 then
                    State.ReplaceStatus = "No better helper held"
                    task.wait(1.5)
                elseif Bn() then
                    State.ReplaceStatus = "Free platform is open"
                    task.wait(1.5)
                else
                    local J4 = AU()
                    local J5 = Ay(Ak(J3_2.Name))
                    local J5_3
                    local J6 = not J4 or J5 <= Ay(J4.rarity)
                    local J6_1
                    if J6 then
                        State.ReplaceStatus = "Nothing worse to swap out"
                        task.wait(2)
                    elseif A9(20) then
                        local J5_1 = Az() and Az().CFrame
                        local J2 = J5_1
                        Br = true
                        local key = J4.key
                        if J4.stored > 0 then
                            Bx("WorkerCollect", key)
                            task.wait(0.4)
                        end
                        if Bx("WorkerRemove", key) then
                            task.wait(0.8)
                            J5_3, J6_1 = At(J3_2.Name)
                            if J5_3 then
                                State.Replacements = State.Replacements + 1
                                State.ReplaceStatus = string.format("Swapped %s for %s", J4.name, J3_2.Name)
                            else
                                State.ReplaceStatus = J6_1
                            end
                        else
                            State.ReplaceStatus = "Cannot reach the remove remote"
                        end
                        Br = false
                        local J3_3 = J2 and Az()
                        if J3_3 then
                            pcall(function()
                                Az().CFrame = J2
                            end)
                        end
                        Qn_14()
                        task.wait(1)
                    else
                        task.wait(0.5)
                    end
                end
            end
        else
            J9 = true
        end
    until J9
    local Kc = if zE() then 1 else 0
    if Kc == 1 then
        State.ReplaceStatus = "Idle"
    end
end
Qn_3.SetAutoReplaceHelpers = fn1081
Ar = false
An = false
Ab = fn1255
Qn_3.SetAutoCollectHelpers = fns.fn505
Qn_3.SetCollectFullOnly = fns.fn556
Qn_3.CollectNow = fns.fn299
zH = { "Melee", "Bomb", "Backpack" }
zy = { Melee = "LoadoutMelee", Bomb = "LoadoutBomb", Backpack = "LoadoutBackpack" }
Qn_3.GearStyles = fns.fn34
A7 = fns.fn302
AH = fns.fn372
zY = false
zV = { "Melee", "Bomb" }
Qn_5 = 0
zI = true
Bw = fn1289
A1 = fns.fn637
zL = fns.fn287
Qn_3.SetAutoBuyGear = fn1236
Qn_3.SetGearStyles = fns.fn627
Qn_3.SetGearReserve = fns.fn198
Qn_3.SetGearEquipBest = fns.fn828
Qn_3.MissingBindings = fns.fn871
Qn_3.Track(fns.fn640)
Qn_29 = function()
    local nI
    local nG = "Destroy a House"
    local nH = "v0.3"
    nI = "https://discord.gg/K7Qxnxkk46"
    local nK = "https://tempohub.shop"
    local nJ = "https://discord.gg/K7Qxnxkk46"
    local Library = getgenv().Library
    local ThemeManager = getgenv().ThemeManager
    local SaveManager = getgenv().SaveManager
    local Toggles = Library.Toggles
    local Options = Library.Options
    AC(Qn_3, Library)
    local function nR(nS, nT)
        local LY = zQ(setclipboard) and setclipboard
        local LZ = LY
        local L3 = if LZ then 1 else 0
        local L1 = 2460 * L3 + 289 * (1 - L3)
        local L2 = 3061 * L3 + 2088 * (1 - L3)
        if not ((L1 * 3500 + L2 * 693 + L1 * L2) % 16777213 == 1484120) then
            local LY_1 = zQ(toclipboard) and toclipboard
            LZ = LY_1 or nil
        end
        local LY_2 = LZ
        if not LY_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local LZ_1 = pcall(LY_2, nS)
        if LZ_1 then
            Library:Notify(nT)
        else
            Library:Notify("Failed to copy")
        end
    end
    local function onDiscord()
        nR(nI, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = nI, Copyable = true }, "|", nG, "|", nH },
        Icon = 132608042600488,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(false)
    local n3 = {
        [1] = Window:AddTab("Info", "info"),
        [2] = Window:AddTab("Main", "gamepad-2"),
        [3] = Window:AddTab("Helpers", "users"),
        [4] = Window:AddTab("Upgrades", "trending-up"),
        [5] = Window:AddTab("Player", "person-standing"),
        [6] = Window:AddTab("Settings", "settings")
    }
    local function n4(n5)
        n5:AddDiscordBox(nil, {
            Banner = 95892854151512,
            Avatar = 132608042600488,
            Title = "Tempo Hub",
            Subtitle = "Dupes, keyless scripts and updates",
            Status = "online",
            Accent = Color3.fromRGB(88, 101, 242),
            Link = nI,
            Buttons = { { Text = "Copy Discord Invite", Icon = "copy", Copy = true } }
        })
        return n5
    end
    local function n7(n8)
        return n4(n8:AddLeftGroupbox("Discord", "message-circle"))
    end
    n7(n3[2])
    n7(n3[3])
    n7(n3[4])
    n7(n3[5])
    n7(n3[6])
    local oa = {}
    local function ob()
        local DestructionGroup = n3[2]:AddLeftGroupbox("Destruction", "hammer")
        oa[1] = DestructionGroup:AddLabel(Bf.status(State.HammerStatus), true)
        DestructionGroup:AddToggle("AutoHammer", {
            Text = "Auto Hammer House",
            Default = false,
            Callback = function(oj)
                Qn_3.SetAutoHammer(oj)
            end
        })
        DestructionGroup:AddSlider("HammerInterval", {
            Text = "Swing Delay",
            Default = 0.3,
            Min = 0.1,
            Max = 2,
            Rounding = 2,
            Suffix = "s",
            Callback = function(on)
                Qn_3.SetHammerInterval(on)
            end
        })
        DestructionGroup:AddDivider()
        oa[2] = DestructionGroup:AddLabel(Bf.status(State.BombStatus), true)
        DestructionGroup:AddToggle("AutoBomb", {
            Text = "Auto Throw Bomb",
            Tooltip = "Throws the bomb from your loadout whenever its cooldown is up",
            Default = false,
            Callback = function(op)
                Qn_3.SetAutoBomb(op)
            end
        })
        local SellingGroup = n3[2]:AddRightGroupbox("Selling", "coins")
        oa[3] = SellingGroup:AddLabel(Bf.status(State.SellStatus), true)
        SellingGroup:AddToggle("AutoSell", {
            Text = "Auto Sell",
            Default = false,
            Callback = function(ou)
                Qn_3.SetAutoSell(ou)
            end
        })
        SellingGroup:AddSlider("SellPercent", {
            Text = "Sell At Backpack",
            Default = 90,
            Min = 1,
            Max = 100,
            Rounding = 0,
            Suffix = "%",
            Callback = function(ow)
                Qn_3.SetSellPercent(ow)
            end
        })
        SellingGroup:AddToggle("GameAutoSell", {
            Text = "Game Auto Sell Pad",
            Tooltip = "Toggles the in game auto sell you own on your plot",
            Default = false,
            Callback = function(oy)
                local L4 = oy and not Qn_3.OwnsGameAutoSell()
                if L4 then
                    Library:Notify("You do not own the auto sell pad")
                    return
                end
                Qn_3.SetGameAutoSell(oy)
            end
        })
        SellingGroup:AddDivider()
        SellingGroup:AddButton({
            Text = "Sell Scraps Now",
            Func = function()
                if not Qn_3.SellNow() then
                    Library:Notify("Could not reach the sell remote")
                end
            end
        })
        local GearShopGroup = n3[2]:AddLeftGroupbox("Gear Shop", "swords")
        oa[4] = GearShopGroup:AddLabel(Bf.status(State.GearStatus), true)
        GearShopGroup:AddToggle("AutoBuyGear", {
            Text = "Auto Buy Gear",
            Tooltip = "Buys the cheapest gear you do not own yet, working upward",
            Default = false,
            Callback = function(oG)
                Qn_3.SetAutoBuyGear(oG)
            end
        })
        GearShopGroup:AddDropdown("GearStyles", {
            Text = "Gear Types",
            Values = Qn_3.GearStyles(),
            Default = { "Melee", "Bomb" },
            Multi = true,
            AllowNull = true,
            Callback = function(oI)
                Qn_3.SetGearStyles(oI)
            end
        })
        GearShopGroup:AddToggle("GearEquipBest", {
            Text = "Equip Best Owned",
            Default = true,
            Callback = function(oK)
                Qn_3.SetGearEquipBest(oK)
            end
        })
        GearShopGroup:AddSlider("GearReserve", {
            Text = "Keep Coins",
            Default = 0,
            Min = 0,
            Max = 5000000,
            Rounding = 0,
            Callback = function(oM)
                Qn_3.SetGearReserve(oM)
            end
        })
        local SessionGroup = n3[2]:AddRightGroupbox("Session", "activity")
        oa[5] = SessionGroup:AddLabel(Bf.field("Hits", State.Hits), true)
        oa[6] = SessionGroup:AddLabel(Bf.field("Bombs", State.Bombs), true)
        oa[7] = SessionGroup:AddLabel(Bf.field("Sells", State.Sells), true)
        oa[8] = SessionGroup:AddLabel(Bf.field("Scraps", 0), true)
        oa[9] = SessionGroup:AddLabel(Bf.field("Coins", 0), true)
    end
    local function oP()
        local RollingGroup = n3[3]:AddLeftGroupbox("Rolling", "dices")
        oa[10] = RollingGroup:AddLabel(Bf.status(State.RollStatus), true)
        RollingGroup:AddToggle("AutoRoll", {
            Text = "Auto Roll Helper",
            Tooltip = "Pulls the RNG lever on your plot and waits while a helper is on offer",
            Default = false,
            Callback = function(oV)
                Qn_3.SetAutoRoll(oV)
            end
        })
        local BuyingGroup = n3[3]:AddRightGroupbox("Buying", "shopping-cart")
        oa[11] = BuyingGroup:AddLabel(Bf.status(State.BuyStatus), true)
        BuyingGroup:AddToggle("AutoBuyHelper", {
            Text = "Auto Buy Helper",
            Default = false,
            Callback = function(oZ)
                Qn_3.SetAutoBuyHelper(oZ)
            end
        })
        BuyingGroup:AddDropdown("BuyRarities", {
            Text = "Buy Rarities",
            Values = Qn_3.RarityNames(),
            Default = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Godly", "Secret" },
            Multi = true,
            AllowNull = true,
            Callback = function(o0)
                Qn_3.SetBuyRarities(o0)
            end
        })
        BuyingGroup:AddSlider("BuyMaxPrice", {
            Text = "Max Price",
            Default = 0,
            Min = 0,
            Max = 5000000,
            Rounding = 0,
            Callback = function(o2)
                Qn_3.SetBuyMaxPrice(o2)
            end
        })
        BuyingGroup:AddToggle("BuyAutoPlace", {
            Text = "Place On A Free Platform",
            Default = true,
            Callback = function(o4)
                Qn_3.SetBuyAutoPlace(o4)
            end
        })
        BuyingGroup:AddToggle("BuySkipUnaffordable", {
            Text = "Skip If Unaffordable",
            Tooltip = "Rolls again instead of waiting when you cannot pay for the helper on the pad",
            Default = false,
            Callback = function(o6)
                Qn_3.SetBuySkipUnaffordable(o6)
            end
        })
        BuyingGroup:AddDivider()
        BuyingGroup:AddButton({
            Text = "Place Held Helper",
            Func = function()
                if not Qn_3.PlacePendingHelper() then
                    Library:Notify(State.BuyStatus)
                end
            end
        })
        oa[12] = BuyingGroup:AddLabel(Bf.field("Helpers", State.Helpers), true)
        local ManagingGroup = n3[3]:AddLeftGroupbox("Managing", "hard-hat")
        oa[13] = ManagingGroup:AddLabel(Bf.status(State.PlaceStatus), true)
        ManagingGroup:AddToggle("AutoPlaceHelpers", {
            Text = "Auto Place Helpers",
            Tooltip = "Puts any helper sitting in your backpack onto a free platform",
            Default = false,
            Callback = function(pd)
                Qn_3.SetAutoPlaceHelpers(pd)
            end
        })
        ManagingGroup:AddDivider()
        oa[14] = ManagingGroup:AddLabel(Bf.status(State.ReplaceStatus), true)
        ManagingGroup:AddToggle("AutoReplaceHelpers", {
            Text = "Auto Replace Helpers with Better",
            Tooltip = "When the platforms are full, swaps out your lowest rarity helper for a higher one",
            Default = false,
            Callback = function(pf)
                Qn_3.SetAutoReplaceHelpers(pf)
            end
        })
        oa[15] = ManagingGroup:AddLabel(Bf.field("Swaps", State.Replacements), true)
        local CollectingGroup = n3[3]:AddRightGroupbox("Collecting", "package-open")
        oa[16] = CollectingGroup:AddLabel(Bf.status(State.CollectStatus), true)
        CollectingGroup:AddToggle("AutoCollectHelpers", {
            Text = "Auto Collect from Helpers",
            Default = false,
            Callback = function(pi)
                Qn_3.SetAutoCollectHelpers(pi)
            end
        })
        CollectingGroup:AddToggle("CollectFullOnly", {
            Text = "Only When Storage Is Full",
            Default = false,
            Callback = function(pk)
                Qn_3.SetCollectFullOnly(pk)
            end
        })
        CollectingGroup:AddDivider()
        CollectingGroup:AddButton({
            Text = "Collect From All Helpers",
            Func = function()
                if Qn_3.CollectNow() == 0 then
                    Library:Notify("No helper has scraps stored yet")
                end
            end
        })
        oa[17] = CollectingGroup:AddLabel(Bf.field("Collections", State.Collected), true)
    end
    local function po()
        local BaseUpgradesGroup = n3[4]:AddRightGroupbox("Base Upgrades", "trending-up")
        oa[18] = BaseUpgradesGroup:AddLabel(Bf.status(State.UpgradeStatus), true)
        BaseUpgradesGroup:AddToggle("AutoUpgrade", {
            Text = "Auto Upgrades",
            Default = false,
            Callback = function(pu)
                Qn_3.SetAutoUpgrade(pu)
            end
        })
        BaseUpgradesGroup:AddDropdown("UpgradeSelection", {
            Text = "Upgrades To Buy",
            Values = Qn_3.UpgradeLabels(),
            Default = { "Player Strength", "Luck", "Platforms" },
            Multi = true,
            AllowNull = true,
            Callback = function(px)
                Qn_3.SetUpgradeSelection(px)
            end
        })
        BaseUpgradesGroup:AddToggle("BuildPlatforms", {
            Text = "Also Build Unlocked Platforms",
            Default = true,
            Callback = function(pz)
                Qn_3.SetBuildPlatforms(pz)
            end
        })
        BaseUpgradesGroup:AddSlider("UpgradeReserve", {
            Text = "Keep Coins",
            Default = 0,
            Min = 0,
            Max = 5000000,
            Rounding = 0,
            Callback = function(pB)
                Qn_3.SetUpgradeReserve(pB)
            end
        })
        oa[19] = BaseUpgradesGroup:AddLabel(Bf.field("Purchases", State.Upgrades), true)
    end
    local function pD()
        local pY
        pY = task.spawn(function()
            while not Library.Unloaded do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                pcall(function()
                    oa[1]:SetText(Bf.status(State.HammerStatus))
                    oa[2]:SetText(Bf.status(State.BombStatus))
                    oa[3]:SetText(Bf.status(State.SellStatus))
                    oa[10]:SetText(Bf.status(State.RollStatus))
                    oa[11]:SetText(Bf.status(State.BuyStatus))
                    oa[18]:SetText(Bf.status(State.UpgradeStatus))
                    oa[4]:SetText(Bf.status(State.GearStatus))
                    oa[13]:SetText(Bf.status(State.PlaceStatus))
                    oa[14]:SetText(Bf.status(State.ReplaceStatus))
                    oa[16]:SetText(Bf.status(State.CollectStatus))
                    oa[15]:SetText(Bf.field("Swaps", State.Replacements))
                    oa[17]:SetText(Bf.field("Collections", State.Collected))
                    oa[5]:SetText(Bf.field("Hits", State.Hits))
                    oa[6]:SetText(Bf.field("Bombs", State.Bombs))
                    oa[7]:SetText(Bf.field("Sells", State.Sells))
                    oa[12]:SetText(Bf.field("Helpers", State.Helpers))
                    oa[19]:SetText(Bf.field("Purchases", State.Upgrades))
                    local attr = LocalPlayer:GetAttribute("Scraps")
                    local Md = oa[8]
                    local field2 = Bf.field
                    local Mf = type(attr) == "number" and attr
                    local Mc_1 = Mf or 0
                    Md:SetText(field2("Scraps", Mc_1))
                    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                    local Md_1 = leaderstats and leaderstats:FindFirstChild("Coins")
                    local Md_2 = oa[9]
                    local field = Bf.field
                    local Mc_4 = Md_1 and Md_1.Value or 0
                    Md_2:SetText(field("Coins", Mc_4))
                end)
            end
        end)
        Qn_3.Track(function()
            local Ml = if coroutine.status(pY) ~= "dead" then 1 else 0
            if Ml == 1 then
                pcall(task.cancel, pY)
            end
        end)
    end
    ob()
    oP()
    po()
    local function p0()
        local Mv
        local MA
        Mv = nil
        MA = nil
        local Mt, Label, Mw, Mx, Label3, Label2, MB, MC
        local MJ_1
        local MH_1
        local MI_2
        local MG_1
        MB = Color3.fromRGB(120, 230, 150)
        local MD = Color3.fromRGB(120, 180, 255)
        MC = Color3.fromRGB(255, 190, 120)
        local ME = Color3.fromRGB(180, 180, 180)
        Mx = function(p6, p7, p8)
            return string.format('%s: <font color="#%s">%s</font>', p6, p8:ToHex(), tostring(p7))
        end
        local MF = "Unknown"
        if zQ(identifyexecutor) then
            MG_1, MH_1 = pcall(identifyexecutor)
            local MI_1 = MG_1 and type(MH_1) == "string"
            if MI_1 then
                MF = MH_1
            end
        end
        local MG_2 = 0
        local MH_2 = { "getgenv", "fireproximityprompt", "setclipboard", "cloneref" }
        for i, v in ipairs(MH_2) do
            local MU = v
            MI_2, MJ_1 = pcall(function()
                return getgenv()[MU]
            end)
            local MK = MI_2 and zQ(MJ_1)
            if MK then
                MG_2 += 1
            end
        end
        local MI_3 = string.format("(%d/%d used globals available)", MG_2, #MH_2)
        MA = os.clock()
        Mw = function()
            local Mm = math.floor(os.clock() - MA)
            if Mm < 60 then
                return Mm .. "s"
            elseif Mm < 3600 then
                return string.format("%dm %ds", math.floor((Mm) / (60)), Mm % 60)
            else
                return string.format("%dh %dm", math.floor((Mm) / (3600)), math.floor((Mm % 3600) / (60)))
            end
        end
        local UserGroup = n3[1]:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(Mx("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, MB), true)
        UserGroup:AddLabel(Mx("UserId", tostring(LocalPlayer.UserId), MD), true)
        UserGroup:AddLabel(Mx("Executor", MF .. "  " .. MI_3, MB), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(Mx("Session", Mw(), MC), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                nR(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                nR("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        n4(n3[1]:AddRightGroupbox("Discord", "message-circle"))
        local SessionGroup = n3[1]:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(Mx("Game", nG, MD), true)
        Label2 = SessionGroup:AddLabel(Mx("Players", "0/0", MB), true)
        Mt = tostring(game.JobId)
        local MD_1 = #Mt > 18 and string.sub(Mt, 1, 18) .. "..."
        local MG_4 = MD_1
        local MO = if MG_4 then 1 else 0
        local MM = 3957 * MO + 2141 * (1 - MO)
        local MN = 3161 * MO + 1679 * (1 - MO)
        if not ((MM * 2040 + MN * 2243 + MM * MN) % 16777213 == 10893267) then
            MG_4 = Mt
        end
        local MD_2 = MG_4
        SessionGroup:AddLabel(Mx("Job", MD_2, ME), true)
        Label = SessionGroup:AddLabel(Mx("Ping", "0 ms", MC), true)
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
                nR(Mt, "Copied Job ID")
            end
        })
        Mv = task.spawn(function()
            local Mp_1
            local Mo_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(Mx("Session", Mw(), MC))
                Label2:SetText(Mx("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), MB))
                Mo_1, Mp_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local Mo_2 = Mo_1 and Mp_1 .. " ms" or "n/a"
                Label:SetText(Mx("Ping", Mo_2, MC))
            end
        end)
        Qn_3.Track(function()
            if coroutine.status(Mv) ~= "dead" then
                pcall(task.cancel, Mv)
            end
        end)
        local SocialsGroup = n3[1]:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                nR(nJ, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                nR(nK, "Copied website link")
            end
        })
    end
    p0()
    local function rd()
        local ri
        local rj
        local rh
        local rk
        local MovementGroup = n3[5]:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("Fly", { Text = "Fly", Default = false }):AddKeyPicker("FlyKey", { Default = "H", SyncToggleState = true, Mode = "Toggle", Text = "Fly" })
        MovementGroup:AddToggle("NoClip", { Text = "Noclip", Default = false }):AddKeyPicker("NoClipKey", { Default = "N", SyncToggleState = true, Mode = "Toggle", Text = "Noclip" })
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "Speed", Default = false }):AddKeyPicker("SpeedKey", { Default = "K", SyncToggleState = true, Mode = "Toggle", Text = "Speed" })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false }):AddKeyPicker("InfJumpKey", { Default = "J", SyncToggleState = true, Mode = "Toggle", Text = "Infinite Jump" })
        MovementGroup:AddDivider()
        MovementGroup:AddSlider("WalkSpeed", { Text = "Speed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        rk = {}
        local rg = {}
        rh = {}
        rj = {}
        ri = {}
        local function rl()
            for k, v in rh do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(rh)
        end
        local function rp()
            for k, v in ri do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(ri)
        end
        local function rt()
            for k, v in rj do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(rj)
        end
        local function rx(ry)
            if not ry:IsA("ProximityPrompt") then
                return
            end
            if rk[ry] == nil then
                rk[ry] = {
                    HoldDuration = ry.HoldDuration,
                    MaxActivationDistance = ry.MaxActivationDistance,
                    RequiresLineOfSight = ry.RequiresLineOfSight
                }
            end
            ry.HoldDuration = 0
            ry.MaxActivationDistance = 50
            ry.RequiresLineOfSight = false
        end
        local function rA()
            for k, v in rk do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(rk)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                rt()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                rp()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                rl()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for i, descendant in ipairs(Workspace:GetDescendants()) do
                    if descendant:IsA("ProximityPrompt") then
                        pcall(rx, descendant)
                    end
                end
            else
                rA()
            end
        end)
        table.insert(rg, Workspace.DescendantAdded:Connect(function(rT)
            local NA = Toggles.InstantProximityPrompt.Value and rT:IsA("ProximityPrompt")
            if NA then
                rx(rT)
            end
        end))
        table.insert(rg, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded or not Toggles.InfJump.Value then
                return
            end
            local NC_1 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if NC_1 then
                NC_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(rg, RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        if rh[descendant] == nil then
                            rh[descendant] = descendant.CanCollide
                        end
                        descendant.CanCollide = false
                    end
                end
            end
        end))
        table.insert(rg, RunService.RenderStepped:Connect(function(sf)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local NS = Character and Character:FindFirstChildOfClass("Humanoid")
            local NT = Character
            if NT then
                NT = Character:FindFirstChild("HumanoidRootPart")
            end
            local NR_1 = NT
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and NS then
                if ri[NS] == nil then
                    ri[NS] = NS.WalkSpeed
                end
                NS.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and NR_1 and NS and CurrentCamera then
                if rj[NS] == nil then
                    rj[NS] = NS.PlatformStand
                end
                NS.PlatformStand = true
                local NT_4 = Vector3.zero
                if not UserInputService:GetFocusedTextBox() then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        NT_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        NT_4 -= CurrentCamera.CFrame.LookVector
                    end
                    local NZ = if UserInputService:IsKeyDown(Enum.KeyCode.A) then 1 else 0
                    if NZ == 1 then
                        NT_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        NT_4 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        NT_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        NT_4 -= Vector3.new(0, 1, 0)
                    end
                end
                NR_1.AssemblyLinearVelocity = Vector3.zero
                if NT_4.Magnitude > 0 then
                    NR_1.CFrame = NR_1.CFrame + NT_4.Unit * Options.FlySpeed.Value * sf
                end
            end
        end))
        Qn_3.Track(function()
            for k, v in rg do
                v:Disconnect()
            end
            rl()
            rp()
            rt()
            rA()
        end)
    end
    rd()
    pD()
    local function sB()
        local O2, O3, O4, O5, O6, O7, O8, O9, Pa, Label, Pc, Pd, Pe, Pf
        Pc = {}
        O6 = {}
        O3 = nil
        O4 = 0
        O8 = false
        Pe = 0
        O9 = os.clock()
        local MenuGroup = n3[6]:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        Pf = function()
            local CurrentCamera
            CurrentCamera = Workspace.CurrentCamera
            local N7 = not CurrentCamera or not zQ(VirtualUser.CaptureController) or not zQ(VirtualUser.ClickButton2)
            if N7 then
                return false
            end
            local N7_1 = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            end)
            if not N7_1 then
                return false
            end
            O4 += 1
            O9 = os.clock()
            pcall(function()
                Label:SetText("AFK triggers: " .. O4)
            end)
            return true
        end
        Pa = function(s4)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not s4)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not s4
                end
            end)
            if not s4 then
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
        O7 = function(tk)
            local Od = tk.ClassName == "ParticleEmitter" or tk.ClassName == "Trail" or tk.ClassName == "Smoke"
            local Oh = if Od then 1 else 0
            local Of = 452 * Oh + 272 * (1 - Oh)
            local Og = 1345 * Oh + 349 * (1 - Oh)
            if not ((Of * 1451 + Og * 3232 + Of * Og) % 16777213 == 5610832) then
                Od = tk.ClassName == "Fire"
            end
            if not Od then
                Od = tk.ClassName == "Sparkles"
            end
            local Oh_1 = if Od then 1 else 0
            local Of_1 = 1045 * Oh_1 + 3533 * (1 - Oh_1)
            local Og_1 = 3146 * Oh_1 + 988 * (1 - Oh_1)
            if not ((Of_1 * 3096 + Og_1 * 650 + Of_1 * Og_1) % 16777213 == 8567790) then
                Od = tk.ClassName == "Beam"
            end
            if Od then
                if Pc[tk] == nil then
                    Pc[tk] = tk.Enabled
                end
                pcall(function()
                    tk.Enabled = false
                end)
            end
        end
        O5 = function()
            for k, v in Pc do
                local Om = k
                local Oo = v
                if Om.Parent then
                    pcall(function()
                        Om.Enabled = Oo
                    end)
                end
            end
            table.clear(Pc)
            if O3 then
                pcall(function()
                    settings().Rendering.QualityLevel = O3.Quality
                end)
                Lighting.GlobalShadows = O3.Shadows
                Lighting.FogEnd = O3.Fog
                O3 = nil
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(tz)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not tz)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(tE)
                if tE then
                    if not O3 then
                        O3 = {
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
                    for i, descendant in ipairs(Workspace:GetDescendants()) do
                        pcall(O7, descendant)
                    end
                else
                    O5()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        Pa(true)
        local ScriptGroup = n3[6]:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiGameplayPause:OnChanged(function()
            Pa(Toggles.AntiGameplayPause.Value)
        end)
        if Toggles.AntiGameplayPause.Value then
            Pa(true)
        end
        table.insert(O6, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                Pf()
            end
        end))
        table.insert(O6, Workspace.DescendantAdded:Connect(function(tX)
            if Toggles.FpsBoost.Value then
                O7(tX)
            end
        end))
        O2 = function(t0)
            if O8 or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            O8 = true
            local OB = Pe
            local OC_1 = pcall(function()
                if t0 then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not OC_1 then
                O8 = false
                if not t0 and OB == Pe then
                    task.delay(1.5, function()
                        if OB == Pe then
                            O2(true)
                        end
                    end)
                end
            end
        end
        table.insert(O6, TeleportService.TeleportInitFailed:Connect(function(ui)
            local OJ
            if ui == LocalPlayer and O8 then
                O8 = false
                OJ = Pe
                task.delay(3, function()
                    if OJ == Pe then
                        O2(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local OO = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            local OO_1 = not OO
            local OP = Library.Unloaded
            local OT = if OP then 1 else 0
            local OR = 1946 * OT + 2640 * (1 - OT)
            local OS = 632 * OT + 3754 * (1 - OT)
            if not ((OR * 7 + OS * 2746 + OR * OS) % 16777213 == 2978966) then
                OP = OO_1
            end
            if OP then
                return
            end
            table.insert(O6, OO.ChildAdded:Connect(function(ux)
                if ux.Name == "ErrorPrompt" then
                    O2(false)
                end
            end))
        end)
        Pd = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    Pa(true)
                end
                local OU = Toggles.AntiAfk.Value and os.clock() - O9 >= 60
                if OU then
                    Pf()
                end
                task.wait(1)
            end
        end)
        Qn_3.Track(function()
            Pe += 1
            for k, v in O6 do
                v:Disconnect()
            end
            pcall(task.cancel, Pd)
            Pa(false)
            O5()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    sB()
    local function uR()
        local P9, Qa, Qb, Qc
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("MyScriptHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(n3[6])
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/DestroyAHouse")
        local Qd = SaveManager:BuildConfigSection(n3[6])
        Qc = function(uY, uZ)
            local Pj_1 = (uY == "Toggle" and Toggles or Options)[uZ]
            local Pi_2 = type(Pj_1) == "table" and Pj_1.Type == uY
            return Pi_2 and Pj_1 or nil
        end
        Qa = function(u7, u8)
            local Type = u8.Type
            if Type == "Toggle" then
                return { idx = u7, type = "Toggle", value = u8.Value == true }
            elseif Type == "Slider" then
                return { idx = u7, type = "Slider", value = tostring(u8.Value) }
            elseif Type == "Dropdown" then
                return { idx = u7, type = "Dropdown", multi = u8.Multi == true, value = u8.Value }
            elseif Type == "Input" then
                local Pq = u8.Value or ""
                return { idx = u7, type = "Input", text = tostring(Pq) }
            elseif Type == "ColorPicker" then
                return { idx = u7, type = "ColorPicker", value = u8.Value:ToHex(), transparency = u8.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = u7,
                    type = "KeyPicker",
                    mode = u8.Mode,
                    key = u8.Value,
                    modifiers = u8.Modifiers,
                    toggled = u8.Toggled
                }
            else
                return nil
            end
        end
        P9 = function()
            local Pw = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local Px = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if Px then
                        local Px_1 = Qa(k, v)
                        if Px_1 then
                            Pw[#Pw + 1] = Px_1
                        end
                    end
                end
            end
            table.sort(Pw, function(vi, vj)
                if vi.type ~= vj.type then
                    return vi.type < vj.type
                end
                return vi.idx < vj.idx
            end)
            return { objects = Pw }
        end
        Qb = function(vl)
            local PQ
            PQ = nil
            local PR = type(vl) ~= "table" or type(vl.idx) ~= "string" or type(vl.type) ~= "string" or SaveManager.Ignore[vl.idx]
            if PR then
                return false
            end
            PQ = Qc(vl.type, vl.idx)
            if not PQ then
                return false
            end
            local PR_1 = pcall(function()
                if vl.type == "Input" then
                    if type(vl.text) ~= "string" then
                        return
                    end
                    PQ:SetValue(vl.text)
                elseif vl.type == "ColorPicker" then
                    PQ:SetValueRGB(Color3.fromHex(vl.value), vl.transparency)
                elseif vl.type == "KeyPicker" then
                    PQ:SetValue({ vl.key, vl.mode, vl.modifiers })
                    if vl.mode == "Toggle" and vl.toggled ~= nil then
                        PQ.Toggled = vl.toggled
                        PQ:Update()
                    end
                else
                    PQ:SetValue(vl.value)
                end
            end)
            return PR_1
        end
        Qd:AddDivider()
        Qd:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        Qd:AddButton("Export Config to Clipboard", function()
            local PU_1
            local PT_1
            PT_1, PU_1 = pcall(HttpService.JSONEncode, HttpService, P9())
            if PT_1 then
                local PT_2 = zQ(setclipboard) and setclipboard
                local PV = PT_2
                if not PV then
                    local PT_3 = zQ(toclipboard) and toclipboard
                    PV = PT_3 or nil
                end
                local PT_4 = PV
                local PV_1 = type(PT_4) == "function" and pcall(PT_4, PU_1)
                if PV_1 then
                    Library:Notify("Config copied to clipboard", 6)
                    return
                end
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Failed to encode the config")
        end)
        Qd:AddButton("Import Config from Clipboard Text", function()
            local P__1
            local PY = Options.SaveManager_ImportSource.Value or ""
            local PY_1
            local PZ = tostring(PY):match("^%s*(.-)%s*$")
            if PZ == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            if #PZ > 262144 then
                Library:Notify("That config is too large")
                return
            end
            PY_1, P__1 = pcall(HttpService.JSONDecode, HttpService, PZ)
            local PZ_1 = not PY_1 or type(P__1) ~= "table" or type(P__1.objects) ~= "table"
            if PZ_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            if #P__1.objects > 2048 then
                Library:Notify("That config has too many records")
                return
            end
            local PY_2 = 0
            for i, v in ipairs(P__1.objects) do
                if Qb(v) then
                    PY_2 += 1
                end
            end
            if PY_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local P__2 = PY_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(PY_2, P__2), 6)
        end)
        ThemeManager:LoadDefault()
        SaveManager:LoadAutoloadConfig()
        local function Qd_1(vU, vV)
            if Options[vU] then
                vV(Options[vU].Value)
            end
        end
        local function Qe(vY, vZ)
            if Toggles[vY] then
                vZ(Toggles[vY].Value)
            end
        end
        Qd_1("HammerInterval", Qn_3.SetHammerInterval)
        Qd_1("SellPercent", Qn_3.SetSellPercent)
        Qd_1("UpgradeSelection", Qn_3.SetUpgradeSelection)
        Qd_1("UpgradeReserve", Qn_3.SetUpgradeReserve)
        Qd_1("BuyRarities", Qn_3.SetBuyRarities)
        Qd_1("BuyMaxPrice", Qn_3.SetBuyMaxPrice)
        Qd_1("GearStyles", Qn_3.SetGearStyles)
        Qd_1("GearReserve", Qn_3.SetGearReserve)
        Qe("GearEquipBest", Qn_3.SetGearEquipBest)
        Qe("CollectFullOnly", Qn_3.SetCollectFullOnly)
        Qe("BuildPlatforms", Qn_3.SetBuildPlatforms)
        Qe("BuyAutoPlace", Qn_3.SetBuyAutoPlace)
        Qe("BuySkipUnaffordable", Qn_3.SetBuySkipUnaffordable)
        Qe("AutoHammer", Qn_3.SetAutoHammer)
        Qe("AutoBomb", Qn_3.SetAutoBomb)
        Qe("AutoSell", Qn_3.SetAutoSell)
        Qe("AutoUpgrade", Qn_3.SetAutoUpgrade)
        Qe("AutoRoll", Qn_3.SetAutoRoll)
        Qe("AutoBuyHelper", Qn_3.SetAutoBuyHelper)
        Qe("AutoBuyGear", Qn_3.SetAutoBuyGear)
        Qe("AutoPlaceHelpers", Qn_3.SetAutoPlaceHelpers)
        Qe("AutoReplaceHelpers", Qn_3.SetAutoReplaceHelpers)
        Qe("AutoCollectHelpers", Qn_3.SetAutoCollectHelpers)
        local Qd_2 = Qn_3.MissingBindings()
        if #Qd_2 > 0 then
            Library:Notify("Missing game bindings: " .. table.concat(Qd_2, ", "), 8)
        end
        if Toggles.HideUiOnStart and Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    uR()
end
Qn_29()
end)(...)

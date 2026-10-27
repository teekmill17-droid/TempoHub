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
getgenv().TempoHoodSubtitle = "BUILD A GUN ARMY"
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
local hW
local Toggles
local ii
local il
local hZ
local iI
local h1
local ip
local h4
local h7
local iv
local hM
local ia
local hP
local connection
local id
local hS
local iB
local iE
local hY
local iH
local ik
local h0
local io
local ir
local h3
local hL
local iu
local h6
local hO
local h9
local ix
local hR
local iA
local hU
local iD
local ig
local hX
local ij
local iG
local h_
local im
local iJ
local h2
local iq
local h5
local it
local connection2
local iw
local hN
local ib
local hQ
local iz
local hT
local WeaponConfigModule
local ie
local function onCopyEthereumAddress()
    iv(hP, "Copied Ethereum address")
end
local function fn41(M, N)
    return string.format('<font color="%s">%s</font>', N, M)
end
local function fn52()
    local CurrentCamera = h7.CurrentCamera
    if not CurrentCamera then
        return
    end
    iq:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    iq:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    ir = tick()
end
local function antiGameplayPauseLoop()
    while not hW.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            io(true)
        end
    end
end
local function onJumpRequest()
    if hW.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local k5_1 = h1()
        if k5_1 then
            k5_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn135(F, G)
    if setclipboard then
        setclipboard(F)
    elseif toclipboard then
        toclipboard(F)
    end
    hW:Notify(G)
end
local function fn144()
    local Character = h2.Character
    local jF = Character and Character:FindFirstChildOfClass("Humanoid")
    return jF
end
local function onCopyVenmoLink()
    iv(ix, "Copied Venmo link")
end
local function fn150()
    if not Toggles.Fly.Value then
        local kU = h1()
        if kU then
            kU.PlatformStand = false
        end
    end
end
local function fn159(eh, ei)
    local Type = ei.Type
    if Type == "Toggle" then
        return { idx = eh, type = "Toggle", value = ei.Value == true }
    elseif Type == "Slider" then
        return { idx = eh, type = "Slider", value = tostring(ei.Value) }
    elseif Type == "Dropdown" then
        return { idx = eh, type = "Dropdown", multi = ei.Multi == true, value = ei.Value }
    elseif Type == "Input" then
        local lC = ei.Value
        local lG = if lC then 1 else 0
        local lE = 631 * lG + 1892 * (1 - lG)
        local lF = 271 * lG + 294 * (1 - lG)
        if not ((lE * 601 + lF * 2232 + lE * lF) % 16777213 == 1155104) then
            lC = ""
        end
        return { idx = eh, type = "Input", text = tostring(lC) }
    elseif Type == "ColorPicker" then
        return { idx = eh, type = "ColorPicker", value = ei.Value:ToHex(), transparency = ei.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = eh,
            type = "KeyPicker",
            mode = ei.Mode,
            key = ei.Value,
            modifiers = ei.Modifiers,
            toggled = ei.Toggled
        }
    else
        return nil
    end
end
local function fn170(aU)
    local jT = aU and aU:FindFirstChild("RolledWeapon")
    if not jT then
        return nil
    end
    local attr = jT:GetAttribute("unitName")
    local jV = tonumber(jT:GetAttribute("unitTier"))
    local jW = tonumber(jT:GetAttribute("Cost"))
    local jU_1 = not jV
    local jX = type(attr) ~= "string" or jU_1
    if jX or not jW then
        return nil
    end
    local jU_3 = WeaponConfigModule.WeaponStats[attr]
    local jX_2 = jU_3 and jU_3.Rarity or 1
    local jU_5 = iI.getRarityName(jX_2)
    return { unitName = attr, unitTier = jV, cost = jW, rarityName = jU_5, tierName = h4[jV] or "Normal" }
end
local function onCopyJoinScript_JobID()
    local kK = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, iz)
    if setclipboard then
        setclipboard(kK)
    elseif toclipboard then
        toclipboard(kK)
    end
    hW:Notify("Copied join script to clipboard")
end
local function fn222()
    local lI = {}
    for i, v in ipairs({ Toggles, iA }) do
        for k, v in pairs(v) do
            local lJ = type(v) == "table" and type(v.Type) == "string" and not hL.Ignore[k]
            if lJ then
                local lJ_1 = ii(k, v)
                if lJ_1 then
                    lI[#lI + 1] = lJ_1
                end
            end
        end
    end
    table.sort(lI, function(ev, ew)
        if ev.type ~= ew.type then
            return ev.type < ew.type
        end
        return ev.idx < ew.idx
    end)
    return { objects = lI }
end
local function fn225()
    iv(hS, "Copied Discord invite to clipboard")
end
local function fn230()
    return iI.findPlayersPlot(h2)
end
local function fn250()
    local Character = h2.Character
    local jI = Character and Character:FindFirstChild("HumanoidRootPart")
    return jI
end
local function fn258(aI)
    local Character = h2.Character
    if not Character then
        return false
    end
    Character:PivotTo(aI)
    return true
end
local function worker2()
    while not hW.Unloaded do
        if hT("AutoCollectCoin") then
            pcall(h3)
        end
        if hT("AutoPlaceWeapon") then
            pcall(h5)
        end
        local mo = hT("AutoOpenMysteryBox") or hT("AutoBuyMysteryBox")
        if mo then
            pcall(hU)
        end
        task.wait(0.2)
    end
end
local function fn280(as)
    local jA = iA[as]
    return jA and jA.Value or {}
end
local function fn295(aO, aP)
    local jN = iH()
    if not (jN and aO) then
        return false
    end
    if (jN.Position - aO.Position).Magnitude > aP then
        h9(CFrame.new(aO.Position + Vector3.new(0, 3, 0)))
        task.wait(0.05)
    end
    return true
end
local function worker3()
    while not hW.Unloaded do
        task.wait(2)
        if hT("AntiAfk") then
            local mr = tick() - it
            local ms = tick() - ir
            if mr >= 300 and ms >= 60 then
                pcall(h0)
            else
                if mr < 300 and ms >= 300 then
                    pcall(h0)
                end
            end
        end
    end
end
local function fn309(am)
    if hW.Unloaded then
        return false
    end
    local ju = Toggles[am]
    return ju and ju.Value == true
end
local function onRenderStepped(dz)
    if hW.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local k7_1 = h1()
        if k7_1 then
            k7_1.WalkSpeed = iA.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local k7_3 = iH()
        local k8 = h1()
        hR = h7.CurrentCamera or hR
        if k7_3 and k8 and hR then
            k8.PlatformStand = true
            local k8_1 = Vector3.zero
            if iu:IsKeyDown(Enum.KeyCode.W) then
                k8_1 = k8_1 + hR.CFrame.LookVector
            end
            local lh = if iu:IsKeyDown(Enum.KeyCode.S) then 1 else 0
            if lh == 1 then
                k8_1 = k8_1 - hR.CFrame.LookVector
            end
            if iu:IsKeyDown(Enum.KeyCode.A) then
                k8_1 = k8_1 - hR.CFrame.RightVector
            end
            if iu:IsKeyDown(Enum.KeyCode.D) then
                k8_1 = k8_1 + hR.CFrame.RightVector
            end
            if iu:IsKeyDown(Enum.KeyCode.Space) then
                k8_1 = k8_1 + Vector3.new(0, 1, 0)
            end
            if iu:IsKeyDown(Enum.KeyCode.LeftControl) then
                k8_1 = k8_1 - Vector3.new(0, 1, 0)
            end
            k7_3.Velocity = Vector3.zero
            if k8_1.Magnitude > 0 then
                k7_3.CFrame = k7_3.CFrame + k8_1.Unit * iA.FlySpeed.Value * dz
            end
        end
    end
end
local function fn319()
    connection:Disconnect()
    connection2:Disconnect()
    io(false)
    local mv = h1()
    if mv then
        mv.PlatformStand = false
        mv.WalkSpeed = 16
    end
end
local function fn321(ca)
    local DiscordGroup = ca:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = ie })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = ie })
end
local function fn334()
    if not Toggles.WalkSpeedEnabled.Value then
        local kW = h1()
        if kW then
            kW.WalkSpeed = 16
        end
    end
end
local function fn351()
    local kv = il()
    local kw = kv and kv:FindFirstChild("WeaponBox")
    if not kw then
        return
    end
    local ProxPromptPart = kw:FindFirstChild("ProxPromptPart")
    local ky = ProxPromptPart and ProxPromptPart:FindFirstChild("WeaponBoxPrompt")
    local Zone = kw:FindFirstChild("Zone")
    local kw_2 = Zone or ProxPromptPart
    local ky_2 = id(kw)
    if ky_2 then
        local kx_1 = ia(kv, ky_2.unitName)
        local kv_1 = hT("SkipOwnedMysteryBox") and kx_1
        if kv_1 then
            iE(kw_2, 8)
            pcall(function()
                ij:FireServer()
            end)
            return
        elseif hT("AutoBuyMysteryBox") then
            if not iw(ky_2) then
                iE(kw_2, 8)
                pcall(function()
                    ij:FireServer()
                end)
                return
            end
            local kv_2 = tonumber(h2:GetAttribute("currency")) or 0
            if kv_2 >= ky_2.cost then
                iE(kw_2, 8)
                pcall(function()
                    im:FireServer()
                end)
            end
            return
        else
            return
        end
    end
    local kE = if not hT("AutoOpenMysteryBox") then 1 else 0
    if kE == 1 then
        return
    end
    if type(h2:GetAttribute("PendingWeapon")) == "string" then
        return
    end
    if not ky or not ky.Enabled or ky.ActionText ~= "Open" then
        return
    end
    iE(kw_2, 8)
    hO(ky)
end
local function fn411(P, Q, R)
    return string.format("<b>%s</b> %s %s", P, hZ("-", "#5a6070"), hZ(Q, R))
end
local function onStepped()
    if hW.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = h2.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local kY_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if kY_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function worker()
    local kN_1
    while true do
        task.wait(1)
        if hW.Unloaded then
            break
        end
        local kM = math.floor(os.clock() - h6)
        if kM < 60 then
            kN_1 = kM .. "s"
        elseif kM < 3600 then
            kN_1 = string.format("%dm %ds", math.floor((kM) / (60)), kM % 60)
        else
            kN_1 = string.format("%dh %dm", math.floor((kM) / (3600)), math.floor((kM % 3600) / (60)))
        end
        iD:SetText(iJ("Session time", kN_1, ib))
    end
end
local function onExportConfigToClipboard()
    local l8_1
    local l7_1
    l7_1, l8_1 = pcall(ik.JSONEncode, ik, hY())
    if not l7_1 then
        hW:Notify("Failed to encode the config")
        return
    end
    local l7_2 = setclipboard or toclipboard
    local l7_3 = type(l7_2) ~= "function" or not pcall(l7_2, l8_1)
    if l7_3 then
        hW:Notify("Your executor does not support copying to the clipboard")
        return
    end
    hW:Notify("Config copied to clipboard", 6)
end
local function fn453()
    local kG_1
    local kF_1
    if identifyexecutor then
        kG_1, kF_1 = identifyexecutor()
        local kH = kG_1 ~= ""
        local kI = type(kG_1) == "string" and kH
        if kI then
            local kH_1 = type(kF_1) == "string" and kF_1 ~= "" and kG_1 .. " " .. kF_1
            ig = kH_1 or kG_1
        end
    end
end
local function onInputBegan()
    it = tick()
end
local function fn503()
    local attr = h2:GetAttribute("PendingWeapon")
    local kn = attr == ""
    local ko = type(attr) ~= "string" or kn
    if ko then
        return
    end
    local kn_1 = il()
    local ko_1 = kn_1 and kn_1:FindFirstChild("Units")
    local kn_2 = ko_1
    if ko_1 then
        ko_1 = kn_2:FindFirstChild(attr)
    end
    local km_1 = ko_1
    if not km_1 then
        return
    end
    local WeaponBasePart = km_1:FindFirstChild("WeaponBasePart")
    local ko_2 = WeaponBasePart and WeaponBasePart:FindFirstChild("WeaponProxPrompt")
    if not ko_2 then
        return
    end
    local ko_3 = km_1:FindFirstChild("MainPart") or WeaponBasePart
    iE(ko_3, 12)
    hO(ko_2)
end
local function fn507(be)
    local j8 = ip("MysteryBoxRarities")
    local j9 = ip("MysteryBoxTiers")
    return j8[be.rarityName] == true and j9[be.tierName] == true
end
local function onRscripts()
    if setclipboard then
        setclipboard(hN)
    elseif toclipboard then
        toclipboard(hN)
    end
    hW:Notify("Copied Rscripts profile to clipboard")
end
local function onImportConfigFromClipboardTex()
    local md_1
    local mb = iA.SaveManager_ImportSource.Value or ""
    local mb_1
    local mc = tostring(mb):match("^%s*(.-)%s*$")
    if mc == "" then
        hW:Notify("Paste an exported config into the box first")
        return
    end
    mb_1, md_1 = pcall(ik.JSONDecode, ik, mc)
    local mc_1 = not mb_1 or type(md_1) ~= "table"
    local mh = if mc_1 then 1 else 0
    local mf = 1413 * mh + 1730 * (1 - mh)
    local mg = 1505 * mh + 2610 * (1 - mh)
    if not ((mf * 3661 + mg * 2054 + mf * mg) % 16777213 == 10390828) then
        mc_1 = type(md_1.objects) ~= "table"
    end
    if mc_1 then
        hW:Notify("That is not a valid exported config")
        return
    end
    local mb_2 = 0
    for i, v in ipairs(md_1.objects) do
        if hQ(v) then
            mb_2 += 1
        end
    end
    if mb_2 == 0 then
        hW:Notify("No settings in that config matched this script")
        return
    end
    iA.SaveManager_ImportSource:SetValue("")
    local md_2 = mb_2 == 1 and "" or "s"
    hW:Notify(("Imported %d setting%s"):format(mb_2, md_2), 6)
end
local function fn606(aM)
    if not aM then
        return
    end
    if fireproximityprompt then
        pcall(fireproximityprompt, aM)
    end
end
local function fn609(a6, a7)
    local j2 = a6 and a6:FindFirstChild("Units")
    local j3 = j2
    if j2 then
        j2 = j3:FindFirstChild(a7)
    end
    local j3_1 = j2
    local j2_1 = j3_1 ~= nil and j3_1:GetAttribute("Placed") == true
    return j2_1
end
local function onCopyUSDTAddress()
    iv(hM, "Copied USDT address")
end
local function onCopyLitecoinAddress()
    iv(h_, "Copied Litecoin address")
end
local function fn661()
    io(Toggles.AntiGameplayPause.Value)
end
local function fn666(d9, ea)
    local lv_1 = (d9 == "Toggle" and Toggles or iA)[ea]
    local lu_2 = type(lv_1) == "table" and lv_1.Type == d9
    return lu_2 and lv_1 or nil
end
local function onCopySolanaAddress()
    iv(iG, "Copied Solana address")
end
local function onInputChanged(d1)
    local UserInputType = d1.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        it = tick()
    end
end
local function onUnload()
    hW:Unload()
end
local function onCopyBitcoinAddress()
    iv(hX, "Copied Bitcoin address")
end
local function onCopyPayPalLink()
    iv(iB, "Copied PayPal link")
end
hL = nil
hM = nil
hN = nil
hO = nil
hP = nil
hQ = nil
hR = nil
hS = nil
hT = nil
hU = nil
hW = nil
hX = nil
hY = nil
hZ = nil
h_ = nil
h0 = nil
h1 = nil
h2 = nil
h3 = nil
h4 = nil
h5 = nil
h6 = nil
h7 = nil
connection2 = nil
h9 = nil
ia = nil
ib = nil
id = nil
ie = nil
ig = nil
ii = nil
ij = nil
ik = nil
il = nil
im = nil
io = nil
ip = nil
iq = nil
ir = nil
it = nil
iu = nil
iv = nil
iw = nil
ix = nil
connection = nil
iz = nil
local hV, ic, ih, is
iA = nil
iB = nil
WeaponConfigModule = nil
iD = nil
iE = nil
Toggles = nil
iG = nil
iH = nil
iI = nil
iJ = nil
local iK, iL, iN, iP, iQ, iR, iS, iT, iU, iV, iW, iX, iY, iZ, i_, i0, i1, i2, i3, i4, RunService, i6, i9, ja, FarmGroup
local iM_1, iM_2
iK, iQ, RunService, iu, iq, ik, ih, ic, h7, h2, iU, hS, hN, iI, WeaponConfigModule, iP, is, im, ij, iN, iZ, h4, iM_1, hW, iT, hL, Toggles, iA, i2, i0, ib, iX, h_, hX, hP, hM, iG, iB, ix, i4, i3, i1, i_, iY, iW, iV, iL, iS, iv, ie, hZ, iJ, hT, ip, h1, iH, il, h9, hO, iE, id, ia, iw, h3, h5, hU, iR = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local iO = 209
repeat
    i6 = (iO * 1 + 16) % 31 + 1
    if i6 <= 16 then
        if i6 <= 8 then
            if i6 <= 4 then
                if i6 <= 2 then
                    if i6 <= 1 then
                        local i7_1 = { "owhdcgadqa", "yraia", "vdypsy", "ywkiaxqy", "stg", "srfoaauwdt", "azbvje" }
                        local m3 = iO
                        local i8_1 = i7_1[m3 % 7 + 1]
                        if i8_1:len() >= i8_1:gsub("(.)", "%1%1", m3 % 3 % 2 + 1):len() then
                            ip = "#0070ba"
                            iW = "#008cff"
                            h1 = fn309
                            hT = fn280
                            iV = fn144
                        else
                            iW = "#0070ba"
                            iV = "#008cff"
                            hT = fn309
                            ip = fn280
                            h1 = fn144
                        end
                        iO = (iO + 94) % 248
                    else
                        local i7_2 = (vector.create((iO * 5 + 3) % 11 + 1, (iO * 4 + 3) % 13 + 1, (iO * 9 + 13) % 17 + 1))
                        local i8_2 = (vector.create((iO * 3 + 3) % 11 + 1, (iO * 3 + 12) % 13 + 1, (iO * 7 + 6) % 17 + 1))
                        i9 = (vector.create((iO * 5 + 3) % 5 + 1, (iO * 3 + 1) % 7 + 1, (iO * 4 + 7) % 9 + 1))
                        if math.abs((vector.angle(i7_2, i8_2, i9))) - math.abs((vector.angle(i8_2, i7_2, i9))) == 0 then
                            iH = fn250
                        else
                            iA = fn250
                        end
                        iO = (iO + 125) % 248
                    end
                elseif i6 <= 3 then
                    local ng = bit32.rrotate(bit32.bxor(bit32.lrotate(iO, 13), string.byte(tostring(iW))), 27)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(ng, 1533117179), 0), 1533117179) ~= bit32.lrotate(ng, 0) then
                        hO = fn230
                        il = fn258
                        iE = fn606
                        h9 = fn295
                    else
                        il = fn230
                        h9 = fn258
                        hO = fn606
                        iE = fn295
                    end
                    iO = (iO + 1) % 248
                else
                    local i7_3 = (vector.create((iO * 5 + 5) % 11 + 1, (iO * 10 + 12) % 13 + 1, (iO * 4 + 12) % 17 + 1))
                    local i8_3 = (vector.create((iO * 1 + 7) % 11 + 1, (iO * 9 + 5) % 13 + 1, (iO * 2 + 7) % 17 + 1))
                    local m0 = vector.dot(i7_3, i8_3)
                    if m0 * m0 <= vector.dot(i7_3, i7_3) * vector.dot(i8_3, i8_3) then
                        id = fn170
                    else
                        iM_1 = fn170
                    end
                    iO = (iO + 218) % 248
                end
            elseif i6 <= 6 then
                if i6 <= 5 then
                    if (iO * 1 + 9) * 13 % 4 == ((iO * 1 + 9) * 13 + 4) % 4 then
                        ia = fn609
                        iw = fn507
                        h3 = function()
                            local kd = il()
                            if not kd then
                                return
                            end
                            local LootSpawned = kd:FindFirstChild("LootSpawned")
                            if not LootSpawned then
                                return
                            end
                            local kc = {}
                            for i, child in LootSpawned:GetChildren() do
                                kc[#kc + 1] = child.Name
                                if #kc >= 40 then
                                    pcall(function()
                                        is:FireServer(kc)
                                    end)
                                    kc = {}
                                end
                            end
                            if #kc > 0 then
                                pcall(function()
                                    is:FireServer(kc)
                                end)
                            end
                        end
                        h5 = fn503
                        hU = fn351
                    else
                        hU = fn609
                        ia = fn507
                        h5 = function()
                            local kd = il()
                            if not kd then
                                return
                            end
                            local LootSpawned = kd:FindFirstChild("LootSpawned")
                            if not LootSpawned then
                                return
                            end
                            local kc = {}
                            for i, child in LootSpawned:GetChildren() do
                                kc[#kc + 1] = child.Name
                                if #kc >= 40 then
                                    pcall(function()
                                        is:FireServer(kc)
                                    end)
                                    kc = {}
                                end
                            end
                            if #kc > 0 then
                                pcall(function()
                                    is:FireServer(kc)
                                end)
                            end
                        end
                        h3 = fn503
                        iw = fn351
                    end
                    iO = (iO + 94) % 248
                else
                    local nc = bit32.rrotate(bit32.bxor(bit32.lrotate(iO, 27), string.byte(tostring(RunService))), 28)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(nc, 1140943942), 2), 268808473) ~= bit32.lrotate(nc, 2) then
                        iU = hS:CreateWindow({
                            Footer = { { Text = iL, Copyable = true }, "|", hW },
                            NotifySide = "Right",
                            ShowCustomCursor = false,
                            CornerRadius = 10,
                            Icon = 12645376577,
                            Title = "Tempo Hub"
                        })
                    else
                        iL = hW:CreateWindow({
                            Title = "Tempo Hub",
                            Footer = { { Text = hS, Copyable = true }, "|", iU },
                            Icon = 12645376577,
                            NotifySide = "Right",
                            ShowCustomCursor = false,
                            CornerRadius = 10
                        })
                    end
                    iO = (iO + 125) % 248
                end
            elseif i6 <= 7 then
                if iO * 2531357 + 13 + 5 >= iO * 2531357 + 13 + 5 + 1 then
                    iL = {
                        Player = iS:AddTab("Player", "person-standing"),
                        Settings = iS:AddTab("Settings", "settings"),
                        Main = iS:AddTab("Main", "gamepad-2"),
                        Info = iS:AddTab("Info", "info")
                    }
                else
                    iS = {
                        Info = iL:AddTab("Info", "info"),
                        Main = iL:AddTab("Main", "gamepad-2"),
                        Player = iL:AddTab("Player", "person-standing"),
                        Settings = iL:AddTab("Settings", "settings")
                    }
                end
                iO = (iO + 94) % 248
            else
                local i7_4 = {
                    "ihzfsllov",
                    "mdjnqeij",
                    "euufxebnnegh",
                    "hwbznp",
                    "rnvhcq",
                    "rhacmycd",
                    "rfz",
                    "zfxx",
                    "pnfcq",
                    "ncwu"
                }
                if i7_4[(iO * 86 + 42) % 10 + 1] <= i7_4[(iO * 86 + 42) % 10 + 1] then
                    iR = fn321
                else
                    h3 = fn321
                end
                iO = (iO + 187) % 248
            end
        elseif i6 <= 12 then
            if i6 <= 10 then
                if i6 <= 9 then
                    local i7_5 = { "aem", "yeszlrv", "scawgjj", "ioikdfb", "ziewwazgt", "mfwpt", "bkswmfovkfx", "dijsffn" }
                    if i7_5[(iO * 25 + 9) % 8 + 1] <= i7_5[(iO * 25 + 9) % 8 + 1] then
                        iK = game:GetService("Players")
                    else
                        iB = game:GetService("Players")
                    end
                    iO = (iO + 187) % 248
                else
                    if (not ih or ih) and (not ih or ih) and (not iP and not iP and (iP or ih)) and not ((not ih or ih) and (not ih or ih) and (not iP and not iP and (iP or ih))) then
                        i3 = game:GetService("ReplicatedStorage")
                    else
                        iQ = game:GetService("ReplicatedStorage")
                    end
                    iO = (iO + 218) % 248
                end
            elseif i6 <= 11 then
                local i7_6 = {
                    "ebboqarrf",
                    "xojyogu",
                    "dajttrfcac",
                    "eppfdwnhh",
                    "gldwqtsfqp",
                    "cnngv",
                    "tfmvgiwq",
                    "itqifrc",
                    "eax",
                    "kvelrvbx",
                    "vigoh"
                }
                local ni = iO
                local i8_4 = i7_6[ni % 11 + 1]
                if i8_4:len() >= i8_4:reverse():rep(ni % 3 + 2):len() then
                    ik = game:GetService("RunService")
                else
                    RunService = game:GetService("RunService")
                end
                iO = (iO + 63) % 248
            else
                local i7_7 = {
                    "lpdzhnnpe",
                    "vmtwhmbrxwl",
                    "zswq",
                    "smv",
                    "ohmhf",
                    "rlnbept",
                    "hydgqmifjys",
                    "uqunvgyxz",
                    "kfbewtjvxw",
                    "ghhcbewrymy"
                }
                if i7_7[(iO * 41 + 107) % 10 + 1] < i7_7[(iO * 41 + 107) % 10 + 1] then
                    ik = game:GetService("UserInputService")
                    iu = game:GetService("VirtualUser")
                    iq = game:GetService("HttpService")
                else
                    iu = game:GetService("UserInputService")
                    iq = game:GetService("VirtualUser")
                    ik = game:GetService("HttpService")
                end
                iO = (iO + 94) % 248
            end
        elseif i6 <= 14 then
            if i6 <= 13 then
                local i7_8 = {
                    "cjjifzk",
                    "febnj",
                    "udla",
                    "azy",
                    "oejqkdkg",
                    "klluzvaxb",
                    "jfaz",
                    "vmk",
                    "lbboykg",
                    "zxtwm",
                    "uvu",
                    "rkdl",
                    "gdmewt"
                }
                if i7_8[(iO * 69 + 50) % 13 + 1] < i7_8[(iO * 69 + 50) % 13 + 1] then
                    ic = game:GetService("GuiService")
                    ih = game:GetService("CoreGui")
                else
                    ih = game:GetService("GuiService")
                    ic = game:GetService("CoreGui")
                end
                iO = (iO + 63) % 248
            else
                if (iO * 3 + 3) * 9 % 4 == ((iO * 3 + 3) * 9 + 3) % 4 then
                    iW = game:GetService("Workspace")
                else
                    h7 = game:GetService("Workspace")
                end
                iO = (iO + 1) % 248
            end
        elseif i6 <= 15 then
            if (not i0 or not ij or not iu and not i0) and (ij and not i0 or (iu or iu)) or not ((not i0 or not ij or not iu and not i0) and (ij and not i0 or (iu or iu))) then
                h2 = iK.LocalPlayer
            else
                iK = h2.LocalPlayer
            end
            iO = (iO + 125) % 248
        else
            local i7_9 = (vector.create((iO * 4 + 3) % 11 + 1, (iO * 8 + 5) % 13 + 1, (iO * 5 + 16) % 17 + 1))
            local i8_5 = (vector.create((iO * 5 + 2) % 11 + 1, (iO * 9 + 3) % 13 + 1, (iO * 12 + 12) % 17 + 1))
            i9 = (vector.create((iO * 5 + 1) % 11 + 1, (iO * 2 + 1) % 13 + 1, (iO * 3 + 2) % 17 + 1))
            if vector.dot(vector.cross(i7_9, i8_5), i9) == vector.dot(vector.cross(i8_5, i9), i7_9) then
                iU = "Build a Gun Army"
            else
                iL = "Build a Gun Army"
            end
            iO = (iO + 218) % 248
        end
    elseif i6 <= 24 then
        if i6 <= 20 then
            if i6 <= 18 then
                if i6 <= 17 then
                    local i7_10 = {
                        "zrrnvmpfkb",
                        "oprqx",
                        "vpkyjp",
                        "odnnayxt",
                        "ywtr",
                        "iffdonebrv",
                        "ewib",
                        "udziabvzb",
                        "ovk",
                        "kgbohwikd",
                        "mcbfenrqxfk"
                    }
                    local m2 = iO
                    local i8_6 = i7_10[m2 % 11 + 1]
                    if i8_6:len() >= i8_6:reverse():rep(m2 % 3 + 2):len() then
                        h2 = "https://discord.gg/K7Qxnxkk46"
                    else
                        hS = "https://discord.gg/K7Qxnxkk46"
                    end
                    iO = (iO + 218) % 248
                else
                    local i7_11 = {
                        "lcnvjeziwsv",
                        "wblmtqq",
                        "bpcwo",
                        "wkhgbdgfx",
                        "ximqjkpodznl",
                        "fbyefbrjt",
                        "oeaqrbehxa",
                        "yxrwuv",
                        "zsxwzky"
                    }
                    if i7_11[(iO * 50 + 96) % 9 + 1] <= i7_11[(iO * 50 + 96) % 9 + 1] then
                        hN = "https://discord.gg/K7Qxnxkk46"
                        iI = require(iQ:WaitForChild("HelperModule"))
                    else
                        iI = "https://discord.gg/K7Qxnxkk46"
                        iQ = require(hN:WaitForChild("HelperModule"))
                    end
                    iO = (iO + 218) % 248
                end
            elseif i6 <= 19 then
                if (not ic or ic) and (not h3 and not h3) and (not ic and not ic or (not ic or not h3)) and not ((not ic or ic) and (not h3 and not h3) and (not ic and not ic or (not ic or not h3))) then
                    iQ = require(WeaponConfigModule:WaitForChild("WeaponConfigModule"))
                else
                    WeaponConfigModule = require(iQ:WaitForChild("WeaponConfigModule"))
                end
                iO = (iO + 1) % 248
            else
                if (not iw and iw and (not iw and iN) or (iw and not iN or iN and iw) or (iw and iw or not iN and iw or (iw and iw or not iw and iN))) and (not iN and iN and (iw or iw) or iN and not iw and (not iN and not iN) or (iw and not iw or (not iw or iN)) and (not iw or iN or not iw and iN)) or not ((not iw and iw and (not iw and iN) or (iw and not iN or iN and iw) or (iw and iw or not iN and iw or (iw and iw or not iw and iN))) and (not iN and iN and (iw or iw) or iN and not iw and (not iN and not iN) or (iw and not iw or (not iw or iN)) and (not iw or iN or not iw and iN))) then
                    iP = iQ:WaitForChild("RemoteEvents")
                    is = iP:WaitForChild("CurrencyPickup")
                    im = iP:WaitForChild("WeaponBoxBuy")
                    ij = iP:WaitForChild("WeaponBoxDiscard")
                else
                    im = iP:WaitForChild("RemoteEvents")
                    ij = im:WaitForChild("CurrencyPickup")
                    is = im:WaitForChild("WeaponBoxBuy")
                    iQ = im:WaitForChild("WeaponBoxDiscard")
                end
                iO = (iO + 63) % 248
            end
        elseif i6 <= 22 then
            if i6 <= 21 then
                if (iu and not iB or (iB or not iu)) and ((iL or not i3) and (i3 or not iL)) and ((iu or not iu or not iB and i3) and ((iu or i3) and (iB or i3))) and ((iL and iB or not iB and not iB) and (not i3 and i3 or (not iL or iB)) and ((i3 or not iL) and (not i3 or not iu) or iu and not iB and (not iL or not i3))) or not ((iu and not iB or (iB or not iu)) and ((iL or not i3) and (i3 or not iL)) and ((iu or not iu or not iB and i3) and ((iu or i3) and (iB or i3))) and ((iL and iB or not iB and not iB) and (not i3 and i3 or (not iL or iB)) and ((i3 or not iL) and (not i3 or not iu) or iu and not iB and (not iL or not i3)))) then
                    iN = h7:WaitForChild("Plots")
                    iZ = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret" }
                    h4 = { "Normal", "Shiny", "Electric", "Cosmic" }
                else
                    h7 = h4:WaitForChild("Plots")
                    iN = { "Secret", "Epic", "Common", "Mythic", "Rare", "Uncommon", "Legendary" }
                    iZ = { "Cosmic", "Shiny", "Normal", "Electric" }
                end
                iO = (iO + 187) % 248
            else
                if ((iY or iY) and (RunService and iY) or (not iZ and iZ or not iZ and not iY) or (not iY and not iZ or RunService and not iZ or (not iY and iZ or iZ and not RunService))) and ((not iZ or not iY or (iY or not RunService) or iY and RunService and (not iZ or not iZ)) and (not iZ and RunService and (RunService and iY) or (iZ or iY or (iY or not RunService)))) and not (((iY or iY) and (RunService and iY) or (not iZ and iZ or not iZ and not iY) or (not iY and not iZ or RunService and not iZ or (not iY and iZ or iZ and not RunService))) and ((not iZ or not iY or (iY or not RunService) or iY and RunService and (not iZ or not iZ)) and (not iZ and RunService and (RunService and iY) or (iZ or iY or (iY or not RunService))))) then
                    iq = ""
                else
                    iM_1 = ""
                end
                iO = (iO + 32) % 248
            end
        elseif i6 <= 23 then
            if ((not iO or not iO) and (not ij and not iO) and ((not ij or ij) and (ij and ij)) or (not iO and iG or (not iO or iG)) and (ij and iO or (not ij or not ij))) and (ij and iO or (iG or not iG) or (not ij or not iO) and (ij and not iG) or iG and ij and (iO or iO) and (iO or iG or (not iO or ij))) or not (((not iO or not iO) and (not ij and not iO) and ((not ij or ij) and (ij and ij)) or (not iO and iG or (not iO or iG)) and (ij and iO or (not ij or not ij))) and (ij and iO or (iG or not iG) or (not ij or not iO) and (ij and not iG) or iG and ij and (iO or iO) and (iO or iG or (not iO or ij)))) then
                hW = getgenv().Library
            else
                iM_1 = getgenv().Library
            end
            iO = (iO + 32) % 248
        else
            local m4 = bit32.rrotate(bit32.bxor(bit32.lrotate(iO, 27), string.byte(tostring(hT))), 10)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(m4, 323441313), 4042662955), (bit32.bxor(bit32.band(m4, 3971525982), 2126238833))), 4042662955), 2126238833) == m4 then
                iT = getgenv().ThemeManager
                hL = getgenv().SaveManager
                Toggles = hW.Toggles
                iA = hW.Options
                iv = fn135
            else
                iM_1 = getgenv().ThemeManager
                iT = getgenv().SaveManager
                hL = Toggles.Toggles
                iv = Toggles.Options
                hW = fn135
            end
            iO = (iO + 94) % 248
        end
    elseif i6 <= 28 then
        if i6 <= 26 then
            if i6 <= 25 then
                local i7_12 = (vector.create((iO * 5 + 2) % 11 + 1, (iO * 8 + 6) % 13 + 1, (iO * 9 + 5) % 17 + 1))
                local i8_7 = (vector.create((iO * 6 + 9) % 11 + 1, (iO * 6 + 6) % 13 + 1, (iO * 2 + 10) % 17 + 1))
                local m6 = vector.cross(i7_12, i8_7)
                local m7 = vector.dot(i7_12, i8_7)
                if vector.dot(m6, m6) + m7 * m7 == vector.dot(i7_12, i7_12) * vector.dot(i8_7, i8_7) then
                    ie = fn225
                    hZ = fn41
                else
                    hZ = fn225
                    ie = fn41
                end
                iO = (iO + 63) % 248
            else
                if (not h4 and h4 or (not h4 or h5)) and ((not h4 or hM) and (not hU or hU)) or (hM and hM or (not hU or not h4) or (not hM and not h5 or hM and h5)) or not ((not h4 and h4 or (not h4 or h5)) and ((not h4 or hM) and (not hU or hU)) or (hM and hM or (not hU or not h4) or (not hM and not h5 or hM and h5))) then
                    iJ = fn411
                    i2 = "#7fd47f"
                    i0 = "#6ec1ff"
                    ib = "#e8a34d"
                    iX = "#8b93a3"
                else
                    i2 = fn411
                    i0 = "#7fd47f"
                    iX = "#6ec1ff"
                    iJ = "#e8a34d"
                    ib = "#8b93a3"
                end
                iO = (iO + 32) % 248
            end
        elseif i6 <= 27 then
            local mY = bit32.rrotate(bit32.bxor(bit32.lrotate(iO, 30), string.byte(tostring(i1))), 24)
            if bit32.bxor(bit32.lrotate(bit32.bxor(mY, 1611756429), 8), 292785504) ~= bit32.lrotate(mY, 8) then
                hX = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
                h_ = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
            else
                h_ = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
                hX = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
            end
            iO = (iO + 187) % 248
        else
            local i7_13 = (vector.create((iO * 5 + 6) % 11 + 1, (iO * 2 + 7) % 13 + 1, (iO * 15 + 8) % 17 + 1))
            local i8_8 = (vector.create((iO * 2 + 7) % 11 + 1, (iO * 11 + 3) % 13 + 1, (iO * 2 + 3) % 17 + 1))
            i9 = (vector.create((iO * 7 + 5) % 11 + 1, (iO * 2 + 9) % 13 + 1, (iO * 14 + 7) % 17 + 1))
            ja = (vector.create((iO * 3 + 7) % 5 + 1, (iO * 5 + 1) % 7 + 1, (iO * 3 + 4) % 9 + 1))
            if vector.dot(vector.cross(i7_13, (vector.cross(i8_8, i9))), ja) == vector.dot(i8_8 * vector.dot(i7_13, i9) - i9 * vector.dot(i7_13, i8_8), ja) then
                hP = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                hM = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                iG = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
                iB = ""
            else
                iB = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                iG = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                hP = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
                hM = ""
            end
            iO = (iO + 63) % 248
        end
    elseif i6 <= 30 then
        if i6 <= 29 then
            local mQ = bit32.rrotate(bit32.bxor(bit32.lrotate(iO, 11), string.byte(tostring(RunService))), 25)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(mQ, 2311900853), 3500280754), (bit32.bxor(bit32.band(mQ, 1983066442), 2814150224))), 3500280754), 2814150224) == mQ then
                ix = ""
            else
                iN = ""
            end
            iO = (iO + 63) % 248
        else
            i6 = (vector.create((iO * 1 + 3) % 11 + 1, (iO * 8 + 8) % 13 + 1, (iO * 6 + 16) % 17 + 1))
            local i7_14 = (vector.create((iO * 6 + 2) % 11 + 1, (iO * 11 + 5) % 13 + 1, (iO * 15 + 1) % 17 + 1))
            local i8_9 = (vector.create((iO * 5 + 9) % 11 + 1, (iO * 11 + 3) % 13 + 1, (iO * 6 + 9) % 17 + 1))
            i9 = (vector.create((iO * 6 + 8) % 11 + 1, (iO * 11 + 7) % 13 + 1, (iO * 6 + 9) % 17 + 1))
            if vector.dot(vector.cross(i6, i7_14), (vector.cross(i8_9, i9))) == vector.dot(i6, i8_9) * vector.dot(i7_14, i9) - vector.dot(i6, i9) * vector.dot(i7_14, i8_9) then
                i4 = "#345d9d"
                i3 = "#f7931a"
                i1 = "#627eea"
            else
                i1 = "#345d9d"
                i4 = "#f7931a"
                i3 = "#627eea"
            end
            iO = (iO + 1) % 248
        end
    else
        if (not h4 or id or (i2 or iP)) and ((not iP or id) and (not iP or not h4)) or not ((not h4 or id or (i2 or iP)) and ((not iP or id) and (not iP or not h4))) then
            i_ = "#26a17b"
            iY = "#14f195"
        else
            iY = "#26a17b"
            i_ = "#14f195"
        end
        iO = (iO + 156) % 248
    end
until (iO * 165 + 120) % 248 == 102
for k, v in iS do
    iR(v)
end
ig, iK, iN, iD, iz, iM_2 = nil, nil, nil, nil, nil, nil
iL = 7
repeat
    iO = (iL * 2 + 2) % 3 + 1
    if iO <= 2 then
        if iO <= 1 then
            local m_ = bit32.rrotate(bit32.bxor(bit32.lrotate(iL, 18), string.byte(tostring(iM_2))), 2)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(m_, 169729729), 2696082079), (bit32.bxor(bit32.band(m_, 4125237566), 43467359))), 2696082079), 43467359) ~= m_ then
                iz = #iM_2 > 18
            else
                iM_2 = #iz > 18
            end
            iL = (iL + 8) % 12
        else
            local m9 = bit32.rrotate(bit32.bxor(bit32.lrotate(iL, 20), string.byte(tostring(iM_2))), 29)
            if bit32.bxor(bit32.lrotate(bit32.bxor(m9, 4049075671), 28), 2132115421) ~= bit32.lrotate(m9, 28) then
                iS = "Unknown"
                pcall(fn453)
                hZ = iN.Info:AddLeftGroupbox("Account", "circle-user")
                hZ:AddLabel(iD("User", ig.Name, iK), true)
                hZ:AddLabel(iD("Status", "Keyless", iK), true)
                hZ:AddLabel(iD("Executor", "Unknown", iK), true)
                iJ = iN.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                iJ:AddLabel(iU(h2 .. " [" .. tostring(game.PlaceId) .. "]", ib), true)
                iJ:AddLabel(iD("Place ID", tostring(game.PlaceId), ib), true)
                i2 = iJ:AddLabel(iD("Session time", "0s", i0), true)
            else
                ig = "Unknown"
                pcall(fn453)
                iK = iS.Info:AddLeftGroupbox("Account", "circle-user")
                iK:AddLabel(iJ("User", h2.Name, i2), true)
                iK:AddLabel(iJ("Status", "Keyless", i2), true)
                iK:AddLabel(iJ("Executor", ig, i2), true)
                iN = iS.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                iN:AddLabel(hZ(iU .. " [" .. tostring(game.PlaceId) .. "]", i0), true)
                iN:AddLabel(iJ("Place ID", tostring(game.PlaceId), i0), true)
                iD = iN:AddLabel(iJ("Session time", "0s", ib), true)
            end
            iL = (iL + 11) % 12
        end
    else
        iO = (vector.create((iL * 6 + 3) % 11 + 1, (iL * 5 + 3) % 13 + 1, (iL * 5 + 6) % 17 + 1))
        local mW = vector.floor(iO) + vector.ceil(iO * -1)
        if vector.dot(mW, mW) == 0 then
            iz = tostring(game.JobId)
        else
            iD = tostring(game.JobId)
        end
        iL = (iL + 11) % 12
    end
until (iL * 11 + 10) % 12 == 9
if iM_2 then
    iK = 0
    repeat
        iL = {
            "lvyi",
            "saxkmpkc",
            "xwc",
            "miuhsyduxwk",
            "uxxpatucwa",
            "wun",
            "hkydwbxbdy",
            "iobc",
            "sauwji",
            "ijgpt",
            "gkjtnyrpryn",
            "zrmzzso"
        }
        local mZ = iK
        iO = iL[mZ % 12 + 1]
        if iO:len() >= iO:gsub("(.)", "%1%1", mZ % 3 % 2 + 1):len() then
            iz = string.sub(iM_2, 1, 18) .. "..."
        else
            iM_2 = string.sub(iz, 1, 18) .. "..."
        end
        iK = (iK + 1) % 4
    until (iK * 1 + 2) % 4 == 3
end
iK = iM_2 or iz
h6, iL, FarmGroup, hR, it, ir, connection, connection2, io, h0, hV, ii, hY, hQ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
i6 = iK
iN:AddLabel(iJ("Server", i6, iX), true)
iN:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
h6 = os.clock()
task.spawn(worker)
local ScriptsGroup = iS.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(hZ("Included in this hub", iX), true)
ScriptsGroup:AddLabel(hZ(iU, i0), true)
iR = iS.Info:AddRightGroupbox("Features", "list")
iR:AddLabel(hZ("Auto Mystery Box", i0), true)
iR:AddLabel(hZ("Auto Collect", ib), true)
iR:AddLabel(hZ("Auto Place", i2), true)
iR:AddLabel(hZ("Misc Utilities", iX), true)
iQ = iS.Info:AddRightGroupbox("Socials", "link")
iQ:AddButton({ Text = "Discord", Func = ie })
iQ:AddButton({ Text = "Rscripts", Func = onRscripts })
iP = iS.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
iP:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
iP:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
iP:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
iP:AddButton({ Text = "Copy Discord Invite", Func = ie })
local DonationsGroup = iS.Info:AddRightGroupbox("Donations", "heart")
if h0 and not i6 and (not i6 and iQ) and (not ii or FarmGroup or (not ii or not i6)) and not (h0 and not i6 and (not i6 and iQ) and (not ii or FarmGroup or (not ii or not i6))) then
    i2:AddLabel(i_("All donations are optional but appreciated.", i0), true)
    i2:AddLabel(i_("If you donate you get a special role, just PING after you donate.", iY), true)
    i2:AddDivider()
    i2:AddLabel(i_("LTC / Litecoin", hZ), true)
    i2:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
    i2:AddLabel(i_("BTC / Bitcoin", iW), true)
    i2:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
    i2:AddLabel(i_("ETH / Ethereum", iX), true)
    i2:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
    i2:AddLabel(i_("USDT", i3), true)
    i2:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
    i2:AddLabel(i_("Solana", iS), true)
    i2:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
    i2:AddLabel(i_("PayPal", iL), true)
    i2:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
    i2:AddLabel(i_("Venmo", DonationsGroup), true)
    i2:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
    i2:AddDivider()
    i2:AddLabel(i_("Don't have any of the listed currencies but still wanna donate?", ib), true)
    i2:AddLabel(i_("DM me and we'll work something out.", i4), true)
    iV.Info:AddRightGroupbox("FAQ", "circle-help")
else
    DonationsGroup:AddLabel(hZ("All donations are optional but appreciated.", ib), true)
    DonationsGroup:AddLabel(hZ("If you donate you get a special role, just PING after you donate.", i2), true)
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(hZ("LTC / Litecoin", i4), true)
    DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
    DonationsGroup:AddLabel(hZ("BTC / Bitcoin", i3), true)
    DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
    DonationsGroup:AddLabel(hZ("ETH / Ethereum", i1), true)
    DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
    DonationsGroup:AddLabel(hZ("USDT", i_), true)
    DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
    DonationsGroup:AddLabel(hZ("Solana", iY), true)
    DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
    DonationsGroup:AddLabel(hZ("PayPal", iW), true)
    DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
    DonationsGroup:AddLabel(hZ("Venmo", iV), true)
    DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(hZ("Don't have any of the listed currencies but still wanna donate?", iX), true)
    DonationsGroup:AddLabel(hZ("DM me and we'll work something out.", i0), true)
    iL = iS.Info:AddRightGroupbox("FAQ", "circle-help")
end
iL:AddLabel("Where do I get a good config?", true)
iL:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
iL:AddLabel("How do I import / export configs?", true)
iL:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
iL:AddLabel("How do I report bugs?", true)
iL:AddLabel("Join the Discord and post it in the bugs channel.", true)
iL:AddLabel("How do I make suggestions?", true)
iL:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
iL:AddLabel("How do I get help or updates?", true)
iL:AddLabel("Join the Discord, updates and support are posted there first.", true)
local MysteryBoxGroup = iS.Main:AddLeftGroupbox("Mystery Box", "package")
MysteryBoxGroup:AddToggle("AutoOpenMysteryBox", { Text = "Auto Open Mystery Box", Default = false })
MysteryBoxGroup:AddToggle("AutoBuyMysteryBox", { Text = "Auto Buy", Default = false })
MysteryBoxGroup:AddDropdown("MysteryBoxRarities", { Text = "Rarities", Values = iZ, Default = iZ, Multi = true, AllowNull = true })
MysteryBoxGroup:AddDropdown("MysteryBoxTiers", { Text = "Tiers", Values = h4, Default = h4, Multi = true, AllowNull = true })
MysteryBoxGroup:AddToggle("SkipOwnedMysteryBox", { Text = "Skip if Already Owned", Default = true })
FarmGroup = iS.Main:AddRightGroupbox("Farm", "coins")
FarmGroup:AddToggle("AutoCollectCoin", { Text = "Auto Collect Coin", Default = false })
FarmGroup:AddToggle("AutoPlaceWeapon", { Text = "Auto Place Weapon", Default = false })
ja = iS.Player:AddLeftGroupbox("Movement", "footprints")
ja:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
ja:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
ja:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
ja:AddToggle("NoClip", { Text = "NoClip", Default = false })
ja:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = iS.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
io = function(c1)
    pcall(function()
        ih:SetGameplayPausedNotificationEnabled(not c1)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = ic:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not c1
        end
    end)
    if not c1 then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(h2, "GameplayPaused", false)
        else
            h2.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fn661)
Toggles.Fly:OnChanged(fn150)
Toggles.WalkSpeedEnabled:OnChanged(fn334)
RunService.Stepped:Connect(onStepped)
iu.JumpRequest:Connect(onJumpRequest)
hR = h7.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
local MenuGroup = iS.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
hW.ToggleKeybind = iA.MenuKeybind
it = tick()
ir = tick()
pcall(function()
    for i, v in ipairs(getconnections(h2.Idled)) do
        local lo = v
        pcall(function()
            lo:Disable()
        end)
    end
end)
h0 = fn52
connection = iu.InputBegan:Connect(onInputBegan)
connection2 = iu.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton({ Text = "Unload", Func = onUnload })
iT:SetLibrary(hW)
iT:SetFolder("TempoHub")
iT:SaveDefault("Monochrome")
hL:SetLibrary(hW)
hL:IgnoreThemeSettings()
hL:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
hL:SetFolder("TempoHub/build-a-gun-army")
iO = hL:BuildConfigSection(iS.Settings)
hV = fn666
ii = fn159
hY = fn222
hQ = function(ey)
    local l1
    l1 = nil
    local l2 = type(ey) ~= "table" or type(ey.idx) ~= "string" or type(ey.type) ~= "string" or hL.Ignore[ey.idx]
    if l2 then
        return false
    end
    l1 = hV(ey.type, ey.idx)
    if not l1 then
        return false
    end
    local l2_1 = pcall(function()
        if ey.type == "Input" then
            if type(ey.text) ~= "string" then
                return
            end
            l1:SetValue(ey.text)
        elseif ey.type == "ColorPicker" then
            l1:SetValueRGB(Color3.fromHex(ey.value), ey.transparency)
        elseif ey.type == "KeyPicker" then
            l1:SetValue({ ey.key, ey.mode, ey.modifiers })
            if ey.mode == "Toggle" and ey.toggled ~= nil then
                l1.Toggled = ey.toggled
                l1:Update()
            end
        else
            l1:SetValue(ey.value)
        end
    end)
    return l2_1
end
iO:AddDivider()
iO:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
iO:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
iO:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
iT:ApplyToTab(iS.Settings)
iT:LoadDefault()
hL:LoadAutoloadConfig()
task.spawn(worker2)
task.spawn(antiGameplayPauseLoop)
task.spawn(worker3)
hW:OnUnload(fn319)
hW:Notify(iU .. " loaded")
end)(...)

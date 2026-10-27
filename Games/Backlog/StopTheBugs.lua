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
getgenv().TempoHoodSubtitle = "STOP THE BUGS"
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
local GetBlockInventory
local kS
local PurchaseWeaponCrate
local VirtualUser
local kf
local kY
local kF
local ReplicatedStorage
local SetAutoWave
local k3
local kL
local kr
local k9
local Label
local kR
local ky
local lf
local GetWeaponShopStocks
local kX
local kE
local ll
local kk
local k2
local ItemConfigurations
local kq
local Options
local kQ
local kx
local le
local kD
local lk
local kj
local k1
local kJ
local ToggleWaveState
local k7
local kP
local kw
local Workspace
local kc
local kV
local PurchaseBlockItem
local Library
local k0
local kI
local lp
local ko
local k6
local PlacementMath
local PlaceItemEvent
local Toggles
local kb
local kU
local kB
local li
local GetBlockShopStocks
local k_
local kH
local lo
local connection
local k5
local kN
local kt
local ka
local kA
local lh
local connection2
local kZ
local kG
local ln
local EquipLastWeaponRequest
local k4
local kM
local function fn15(ae)
    local mc = Toggles[ae]
    return mc ~= nil and mc.Value == true
end
local function fn31(cO, cP, cQ)
    local oA_1
    local Base = cO:FindFirstChild("Base")
    local ov = lf(cP)
    local ow = Base and Base:IsA("BasePart")
    if not (ow and ov) then
        return nil
    end
    local clone = ov:Clone()
    local ov_1 = PlacementMath.GetPlacementBox(clone)
    if not ov_1 then
        clone:Destroy()
        return nil
    end
    local ox_1 = PlacementMath.GetStaticCellState(cO, Base)
    local oy = cQ
    local oy_1
    local oI = if oy then 1 else 0
    local oG = 2770 * oI + 2475 * (1 - oI)
    local oH = 1072 * oI + 1439 * (1 - oI)
    if not ((oG * 2863 + oH * 1786 + oG * oH) % 16777213 == 12814542) then
        oy = 0
    end
    local oz = oy
    oA_1, oy_1 = PlacementMath.GetFootprintCells(ov_1.Size, oz)
    local ov_2 = {}
    local oB = ox_1.cellsX - oA_1
    local oL = 0
    while oL <= oB do
        local oM = oL
        local oB_1 = ox_1.cellsZ - oy_1
        local oQ = 0
        while oQ <= oB_1 do
            local oR = oQ
            if PlacementMath.IsStaticAreaValid(cO, Base, oM, oR, oA_1, oy_1, false) then
                local oB_2 = not k7(cO, oM, oR, oA_1, oy_1) and kw(ox_1, oM, oR, oA_1, oy_1)
                if oB_2 then
                    table.insert(ov_2, { x = oM, z = oR })
                end
            end
            oQ += 1
        end
        oL += 1
    end
    if #ov_2 == 0 then
        clone:Destroy()
        return nil
    end
    local ox_2 = ov_2[math.random(1, #ov_2)]
    local ov_3 = PlacementMath.GetPlacementFromSavedGrid(Base, clone, ox_2.x, ox_2.z, oz)
    clone:Destroy()
    if not ov_3 then
        return nil
    end
    return ov_3.pivot
end
local function fn44()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local mS = leaderstats and leaderstats:FindFirstChild("Cash")
    local mR_1 = mS
    if mS then
        mS = tonumber(mR_1.Value)
    end
    return mS or 0
end
local function fn78(bv, bw, bx, by, bz, bA)
    local ne = bw + by - 1
    local nf = bx + bz - 1
    for i, child in ipairs(bv:GetChildren()) do
        local ng = child:IsA("Model") and child:GetAttribute("IsPlacedItem")
        if ng then
            local ng_1 = bA and child:GetAttribute("UniqueId") == bA
            if not ng_1 then
                local attr4 = child:GetAttribute("GridX")
                local attr3 = child:GetAttribute("GridZ")
                local attr2 = child:GetAttribute("GridW")
                local attr = child:GetAttribute("GridD")
                if attr4 and attr3 and attr2 and attr then
                    if bw <= attr4 + attr2 - 1 and attr4 <= ne and bx <= attr3 + attr - 1 and attr3 <= nf then
                        return true
                    end
                end
            end
        end
    end
    return false
end
local function fn80()
    local pU = os.clock()
    if pU - kJ < 0.5 then
        return
    end
    if not lo("AutoBuyCrates") then
        return
    end
    local pV = Options.AutoBuyCrateList and Options.AutoBuyCrateList.Value
    local pW = k9(pV)
    local pV_1 = li()
    for i, v in ipairs(ll) do
        if pW[v] then
            local pX = tonumber(kR[v]) or 0
            local pX_1 = lh[v]
            if pX > 0 and pX_1 and pV_1 >= pX_1 then
                PurchaseWeaponCrate:FireServer(v)
                kJ = pU
                return
            end
        end
    end
end
local function fn98(dg)
    if not dg or not dg.Parent then
        return false
    end
    local o9 = if dg:GetAttribute("IsDead") then 1 else 0
    if o9 == 1 then
        return false
    end
    local Humanoid = dg:FindFirstChildOfClass("Humanoid")
    if Humanoid and Humanoid.Health <= 0 then
        return false
    end
    local attr = dg:GetAttribute("Health")
    local o5_1 = typeof(attr) == "number" and attr <= 0
    if o5_1 then
        return false
    end
    return true
end
local function fn204(bh)
    local mZ = tonumber(kM[bh]) or 0
    return mZ
end
local function fn236(aj)
    local mf = {}
    if type(aj) ~= "table" then
        return mf
    end
    for k, v in pairs(aj) do
        if v then
            mf[k] = true
        end
    end
    return mf
end
local function worker3()
    while not Library.Unloaded do
        task.wait(0.05)
        if lo("KillAura") then
            pcall(kB)
        end
    end
end
local function fn278(V, W, X)
    return string.format("<b>%s</b> %s %s", V, kD("-", "#5a6070"), kD(W, X))
end
local function fn306(b2, b3, b4, b5, b6)
    local nM = b3 + b5 - 1
    local nS = b3
    while nS <= nM do
        local nT = nS
        local nM_1 = b4 + b6 - 1
        local nX = b4
        while nX <= nM_1 do
            local nY = nX
            for i, v in ipairs({ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }) do
                local nM_2 = nT + v[1]
                local nN = nY + v[2]
                if nM_2 >= 0 and nN >= 0 and nM_2 < b2.cellsX and nN < b2.cellsZ then
                    if b2.path[nM_2][nN] then
                        return true
                    end
                end
            end
            nX += 1
        end
        nS += 1
    end
    return false
end
local function fn315(dn)
    local pa = {}
    local ClientEntities = Workspace:FindFirstChild("ClientEntities")
    local pc = ClientEntities and ClientEntities:FindFirstChild("Enemies")
    if not pc then
        return pa
    end
    local pc_1 = kc()
    local pd = pc_1 and pc_1:FindFirstChild("Base")
    local pd_1 = kk()
    if not pd_1 then
        return pa
    end
    local pf = Options.KillAuraPlotRange and Options.KillAuraPlotRange.Value or 120
    for i, child in ipairs(pc:GetChildren()) do
        local pb_2 = child:IsA("Model") and kb(child)
        if pb_2 then
            local pb_3 = kj(child)
            if pb_3 then
                local pf_1 = pd
                local pg = true
                if pf_1 then
                    pf_1 = pd:IsA("BasePart")
                end
                if pf_1 then
                    pg = (pb_3.Position - pd.Position).Magnitude <= pf
                end
                local Magnitude = (pb_3.Position - pd_1.Position).Magnitude
                if pg and Magnitude <= dn then
                    table.insert(pa, { enemy = child, part = pb_3, dist = Magnitude })
                end
            end
        end
    end
    table.sort(pa, function(dM, dN)
        return dM.dist < dN.dist
    end)
    return pa
end
local function onInputChanged(gB)
    local UserInputType = gB.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        k5 = tick()
    end
end
local function worker()
    local ra_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local q9 = math.floor(os.clock() - k3)
        if q9 < 60 then
            ra_1 = q9 .. "s"
        elseif q9 < 3600 then
            ra_1 = string.format("%dm %ds", math.floor((q9) / (60)), q9 % 60)
        else
            ra_1 = string.format("%dh %dm", math.floor((q9) / (3600)), math.floor((q9 % 3600) / (60)))
        end
        Label:SetText(kt("Session time", ra_1, kf))
    end
end
local function fn363(aI, aJ)
    local mz = lh[aI]
    local mE = if mz then 1 else 0
    local mC = 3586 * mE + 282 * (1 - mE)
    local mD = 47 * mE + 3403 * (1 - mE)
    if not ((mC * 3019 + mD * 2471 + mC * mD) % 16777213 == 11110813) then
        mz = 0
    end
    return mz < (lh[aJ] or 0)
end
local function fn388(S, T)
    return string.format('<font color="%s">%s</font>', T, S)
end
local function fn403(a8)
    if not a8 then
        return nil
    end
    return a8
end
local function fn431()
    if not lo("AutoWave") then
        return
    end
    SetAutoWave:FireServer(true)
end
local function fn454()
    local pM = os.clock()
    if pM - kN < 0.35 then
        return
    end
    local pN = false
    local pT = if lo("AutoBuyTurrets") then 1 else 0
    if pT == 1 then
        local pO_1 = Options.AutoBuyTurretList and Options.AutoBuyTurretList.Value
        local pP_1 = (le(kQ, kI, k9(pO_1)))
        local pT_1 = if pP_1 then 1 else 0
        local pR = 3364 * pT_1 + 3914 * (1 - pT_1)
        local pS = 1633 * pT_1 + 3122 * (1 - pT_1)
        if not ((pR * 2149 + pS * 2407 + pR * pS) % 16777213 == 16653279) then
            pP_1 = pN
        end
        pN = pP_1
    end
    if lo("AutoBuyBlocks") then
        local pO_2 = Options.AutoBuyBlockList and Options.AutoBuyBlockList.Value
        local pP_2 = le(kL, kx, k9(pO_2)) or pN
        pN = pP_2
    end
    if pN then
        kN = pM
        task.defer(kS)
    end
end
local function fn455(ax, ay)
    local mq = kI[ax] or 0
    local mr = kI[ay]
    local mv = if mr then 1 else 0
    local mt = 1387 * mv + 1324 * (1 - mv)
    local mu = 1735 * mv + 2941 * (1 - mv)
    if not ((mt * 1267 + mu * 2928 + mt * mu) % 16777213 == 9243854) then
        mr = 0
    end
    return mq < mr
end
local function fn469()
    local result = GetBlockInventory:InvokeServer()
    if type(result) == "table" then
        kM = result
    end
end
local function worker2()
    while not Library.Unloaded do
        task.wait(2)
        if lo("AntiAfk") then
            local rp = tick() - k5
            local rq = tick() - k0
            if rp >= 300 and rq >= 60 then
                pcall(kH)
            else
                if rp < 300 and rq >= 300 then
                    pcall(kH)
                end
            end
        end
    end
end
local function fn481()
    local p9 = os.clock()
    if p9 - kV < (Options.PlaceTurretDelay and Options.PlaceTurretDelay.Value or 0.65) then
        return
    end
    if not lo("AutoPlaceTurrets") then
        return
    end
    local qa_2 = kc()
    if not qa_2 then
        return
    end
    kS()
    local qb_1 = Options.PlaceTurretList and Options.PlaceTurretList.Value
    local qc = k9(qb_1)
    local floor = math.floor
    local qe = Options.PlaceTurretRotation and Options.PlaceTurretRotation.Value or 0
    local qb_3 = floor(qe / 90 + 0.5) % 4
    for i, v in ipairs(kQ) do
        local qd_1 = qc[v] and kr(v) > 0
        if qd_1 then
            local qd_2 = ky(qa_2, v, qb_3)
            if qd_2 then
                PlaceItemEvent:FireServer(v, qd_2, qa_2)
                kV = p9
                task.defer(kS)
                return
            end
        end
    end
end
local function fn505()
    local Character = LocalPlayer.Character
    local m1 = Character and Character:FindFirstChild("HumanoidRootPart")
    return m1
end
local function fn509(ck, cl, cm, cn, co)
    local Base = ck:FindFirstChild("Base")
    local oc = lf(cl)
    local od = Base and Base:IsA("BasePart")
    if not (od and oc) then
        return nil
    end
    local clone = oc:Clone()
    local GetPlacementFromSavedGrid = PlacementMath.GetPlacementFromSavedGrid
    local oe_1 = co or 0
    local of = GetPlacementFromSavedGrid(Base, clone, cm, cn, oe_1)
    clone:Destroy()
    return of and of.pivot or nil
end
local function worker4()
    while not Library.Unloaded do
        task.wait(0.2)
        pcall(kq)
        pcall(k_)
        pcall(lk)
        pcall(ka)
        pcall(lp)
    end
end
local function onOnClientEvent(aW)
    if type(aW) == "table" then
        kU = aW
    end
end
local function fn545()
    local ps = os.clock()
    if ps - kY < (Options.KillAuraDelay and Options.KillAuraDelay.Value or 0.35) then
        return
    end
    local pu_1 = Options.KillAuraRange and Options.KillAuraRange.Value or 25
    local pu_2 = k6(pu_1)
    if #pu_2 == 0 then
        return
    end
    local pt_4 = kF()
    local pv = kk()
    if not (pt_4 and pv) then
        return
    end
    local pw_1 = pu_2[1]
    pv.AssemblyLinearVelocity = Vector3.zero
    pv.AssemblyAngularVelocity = Vector3.zero
    pv.CFrame = CFrame.new(pw_1.part.Position + Vector3.new(0, 2.5, 0))
    pt_4:Activate()
    kY = ps
end
local function fn577()
    local mW_1
    local mV_1
    mV_1, mW_1 = pcall(function()
        return GetBlockInventory:InvokeServer()
    end)
    local mX = mV_1 and type(mW_1) == "table"
    if mX then
        kM = mW_1
    end
    return kM
end
local function fn578()
    local Character = LocalPlayer.Character
    if not Character then
        return nil
    end
    local Tool2 = Character:FindFirstChildOfClass("Tool")
    if Tool2 then
        return Tool2
    end
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    if not Backpack then
        return nil
    end
    local Tool = Backpack:FindFirstChildOfClass("Tool")
    if Tool then
        Tool.Parent = Character
        return Tool
    end
    pcall(function()
        EquipLastWeaponRequest:FireServer()
    end)
    task.wait(0.15)
    return Character:FindFirstChildOfClass("Tool")
end
local function fn587(cf)
    local Turrets = ReplicatedStorage:FindFirstChild("Turrets")
    local n6 = Turrets and Turrets:FindFirstChild(cf)
    return n6
end
local function onOnClientEvent2(aY)
    if type(aY) == "table" then
        kR = aY
    end
end
local function fn623()
    connection:Disconnect()
    connection2:Disconnect()
end
local function onOnClientEvent3(a_)
    if type(a_) == "table" then
        kM = a_
    end
end
local function onRscripts()
    if setclipboard then
        setclipboard(kZ)
    elseif toclipboard then
        toclipboard(kZ)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function fn667(d9, ea, eb)
    local pB = li()
    for i, v in ipairs(d9) do
        if eb[v] then
            local pC = tonumber(kU[v]) or 0
            local pC_1 = kX(ea[v])
            if pC > 0 and pC_1 and pB >= pC_1 then
                PurchaseBlockItem:FireServer(v)
                return true
            end
        end
    end
    return false
end
local function fn676()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    k0 = tick()
end
local function fn683()
    k4(k2, "Copied Discord invite to clipboard")
end
local function fn700(dd)
    local o2 = dd.PrimaryPart or dd:FindFirstChild("HumanoidRootPart") or dd:FindFirstChildWhichIsA("BasePart")
    return o2
end
local function fn705(bT)
    local nC = {}
    for i, child in ipairs(bT:GetChildren()) do
        local nD = child:IsA("Model") and child:GetAttribute("IsPlacedItem")
        if nD then
            local attr = child:GetAttribute("Name")
            local nE = attr and ItemConfigurations[attr]
            local nD_2 = nE
            if nE then
                nE = nD_2.Type == "Turrets"
            end
            if nE then
                table.insert(nC, child)
            end
        end
    end
    return nC
end
local function fn709(aA, aB)
    return (kx[aA] or 0) < (kx[aB] or 0)
end
local function fn712()
    local result = GetWeaponShopStocks:InvokeServer()
    if type(result) == "table" then
        kR = result
    end
end
local function fn720(cy, cz, cA, cB, cC, cD)
    local on_1
    local Base = cy:FindFirstChild("Base")
    local oi = lf(cz)
    local oj = Base and Base:IsA("BasePart")
    local ol = oj and oi
    local ol_2
    if not ol then
        return false
    end
    local clone = oi:Clone()
    local oi_1 = PlacementMath.GetPlacementBox(clone)
    if not oi_1 then
        clone:Destroy()
        return false
    end
    local ol_1 = cC or 0
    on_1, ol_2 = PlacementMath.GetFootprintCells(oi_1.Size, ol_1)
    clone:Destroy()
    if not PlacementMath.IsStaticAreaValid(cy, Base, cA, cB, on_1, ol_2, false) then
        return false
    elseif k7(cy, cA, cB, on_1, ol_2, cD) then
        return false
    else
        return true
    end
end
local function onUnload()
    Library:Unload()
end
local function fn738(bN, bO)
    if bO == "Damage" then
        return kE[bN] or 0
    elseif bO == "DPS" then
        local nt_2 = kE[bN] or 0
        local nv = kA[bN]
        local nB_1 = if nv then 1 else 0
        local ny_1 = 244 * nB_1 + 3137 * (1 - nB_1)
        local nA_1 = 3004 * nB_1 + 1039 * (1 - nB_1)
        if not ((ny_1 * 973 + nA_1 * 1728 + ny_1 * nA_1) % 16777213 == 6161300) then
            nv = 1
        end
        return nt_2 / math.max(nv, 0.01)
    else
        local nt_3 = kI[bN]
        local nB_2 = if nt_3 then 1 else 0
        local ny_2 = 1289 * nB_2 + 3867 * (1 - nB_2)
        local nA_2 = 2691 * nB_2 + 2468 * (1 - nB_2)
        if not ((ny_2 * 2085 + nA_2 * 1811 + ny_2 * nA_2) % 16777213 == 11029665) then
            nt_3 = 0
        end
        return nt_3
    end
end
local function onInputBegan()
    k5 = tick()
end
local function fn751()
    local qY_1
    local qX_1
    if identifyexecutor then
        qY_1, qX_1 = identifyexecutor()
        local qZ = qY_1 ~= ""
        local q_ = type(qY_1) == "string" and qZ
        if q_ then
            local qZ_1 = type(qX_1) == "string" and qX_1 ~= "" and qY_1 .. " " .. qX_1
            local qX_2 = qZ_1
            local q3 = if qX_2 then 1 else 0
            local q1 = 626 * q3 + 3018 * (1 - q3)
            local q2 = 2871 * q3 + 2018 * (1 - q3)
            if not ((q1 * 1363 + q2 * 707 + q1 * q2) % 16777213 == 4680281) then
                qX_2 = qY_1
            end
            ko = qX_2
        end
    end
end
local function fn756(fD)
    local DiscordGroup = fD:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = kP })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = kP })
end
local function worker5()
    while not Library.Unloaded do
        task.wait(2)
        if lo("AutoWave") then
            pcall(k1)
        end
    end
end
local function onCopyJoinScript_JobID()
    local q4 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, ln)
    if setclipboard then
        setclipboard(q4)
    elseif toclipboard then
        toclipboard(q4)
    end
    Library:Notify("Copied join script to clipboard")
end
local function fn847()
    local qU = os.clock()
    if qU - kG < 1 then
        return
    end
    if not lo("AutoStartFight") then
        return
    end
    if LocalPlayer:GetAttribute("IsFighting") then
        return
    end
    EquipLastWeaponRequest:FireServer()
    ToggleWaveState:FireServer()
    kG = qU
end
local function fn850(L, M)
    if setclipboard then
        setclipboard(L)
    elseif toclipboard then
        toclipboard(L)
    end
    Library:Notify(M)
end
local function fn854()
    local Plots = Workspace:FindFirstChild("Plots")
    if not Plots then
        return nil
    end
    for i, child in ipairs(Plots:GetChildren()) do
        local m6_1 = child:IsA("Model") and child:GetAttribute("OwnerId") == LocalPlayer.UserId
        if m6_1 then
            return child
        end
    end
    return nil
end
local function fn865()
    local result = GetBlockShopStocks:InvokeServer()
    if type(result) == "table" then
        kU = result
    end
end
Label = nil
GetBlockInventory = nil
ka = nil
kb = nil
kc = nil
GetWeaponShopStocks = nil
kf = nil
connection2 = nil
GetBlockShopStocks = nil
kj = nil
kk = nil
SetAutoWave = nil
EquipLastWeaponRequest = nil
connection = nil
ko = nil
ToggleWaveState = nil
kq = nil
kr = nil
kt = nil
PlaceItemEvent = nil
kw = nil
kx = nil
ky = nil
PurchaseWeaponCrate = nil
kA = nil
kB = nil
PurchaseBlockItem = nil
kD = nil
kE = nil
kF = nil
kG = nil
kH = nil
kI = nil
kJ = nil
ItemConfigurations = nil
kL = nil
kM = nil
kN = nil
PlacementMath = nil
kP = nil
kQ = nil
kR = nil
kS = nil
kU = nil
kV = nil
local kd, ki, RemoveItemEvent, kT, kW
kX = nil
kY = nil
kZ = nil
k_ = nil
k0 = nil
k1 = nil
k2 = nil
k3 = nil
k4 = nil
k5 = nil
k6 = nil
k7 = nil
Options = nil
k9 = nil
LocalPlayer = nil
Toggles = nil
Workspace = nil
le = nil
lf = nil
VirtualUser = nil
lh = nil
li = nil
Library = nil
lk = nil
ll = nil
ReplicatedStorage = nil
ln = nil
lo = nil
lp = nil
local lb
local ls_1
ReplicatedStorage, VirtualUser, Workspace, LocalPlayer, k2, kZ, PlacementMath, ItemConfigurations, PurchaseBlockItem, PurchaseWeaponCrate, PlaceItemEvent, RemoveItemEvent, ToggleWaveState, EquipLastWeaponRequest, SetAutoWave, GetBlockShopStocks, GetWeaponShopStocks, GetBlockInventory, Library, Toggles, Options, kf, kQ, kL, kI, kE, kA, kx, k4, kP, kD, kt, lo, k9 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local Window
ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local lC = "Stop The Bugs"
k2 = "https://discord.gg/K7Qxnxkk46"
kZ = "https://discord.gg/K7Qxnxkk46"
local lx = ReplicatedStorage:WaitForChild("Events")
local Functions = ReplicatedStorage:WaitForChild("Functions")
PlacementMath = require(ReplicatedStorage.Modules.PlacementMath)
ItemConfigurations = require(ReplicatedStorage.Modules.ItemConfigurations).ItemConfigurations
local lu = require(ReplicatedStorage.Modules.WeaponConfigurations)
PurchaseBlockItem = lx:WaitForChild("PurchaseBlockItem")
PurchaseWeaponCrate = lx:WaitForChild("PurchaseWeaponCrate")
PlaceItemEvent = lx:WaitForChild("PlaceItemEvent")
RemoveItemEvent = lx:WaitForChild("RemoveItemEvent")
ToggleWaveState = lx:WaitForChild("ToggleWaveState")
EquipLastWeaponRequest = lx:WaitForChild("EquipLastWeaponRequest")
SetAutoWave = lx:WaitForChild("SetAutoWave")
local lw = lx:WaitForChild("UpdateBlockStocks")
local lv = lx:WaitForChild("UpdateWeaponStocks")
GetBlockShopStocks = Functions:WaitForChild("GetBlockShopStocks")
GetWeaponShopStocks = Functions:WaitForChild("GetWeaponShopStocks")
GetBlockInventory = Functions:WaitForChild("GetBlockInventory")
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
k4 = fn850
kP = fn683
kD = fn388
kt = fn278
local lA = "#7fd47f"
local lz = "#6ec1ff"
kf = "#e8a34d"
local ly = "#8b93a3"
lo = fn15
k9 = fn236
kQ = {}
kL = {}
kI = {}
kE = {}
kA = {}
kx = {}
local lB = { "Price", "Damage", "DPS" }
for k, v in pairs(ItemConfigurations) do
    local lq_1 = type(v) == "table" and v.Price
    if lq_1 then
        if v.Type == "Turrets" then
            table.insert(kQ, k)
            kI[k] = v.Price
            local lq_2 = v.Damage or 0
            kE[k] = lq_2
            local lq_3 = v.FireRate or 1
            kA[k] = lq_3
        elseif v.Type == "Blocks" then
            table.insert(kL, k)
            kx[k] = v.Price
        end
    end
end
ll, lh = nil, nil
table.sort(kQ, fn455)
table.sort(kL, fn709)
ll = {}
lh = {}
local lr_1 = lu.Crates or {}
for k, v in pairs(lr_1) do
    local lq_5 = type(v) == "table" and v.Price
    if lq_5 then
        table.insert(ll, k)
        lh[k] = v.Price
    end
end
kU, kR, kM, kY, kV, kT, kN, kJ, kG, Window, li, kX, kS, kr, kk, kc, k7, kd, lb, kw, lf, kW, ki, ky, kF, kj, kb, k6, kB, le, kq, k_, lk, ka, lp, k1, ls_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
table.sort(ll, fn363)
kU = {}
kR = {}
kM = {}
pcall(fn865)
pcall(fn712)
pcall(fn469)
lw.OnClientEvent:Connect(onOnClientEvent)
lv.OnClientEvent:Connect(onOnClientEvent2)
lx.BlockInventoryUpdated.OnClientEvent:Connect(onOnClientEvent3)
li = fn44
kX = fn403
kS = fn577
kr = fn204
kk = fn505
kc = fn854
k7 = fn78
kd = fn738
lb = fn705
kw = fn306
lf = fn587
kW = fn509
ki = fn720
ky = fn31
kF = fn578
kj = fn700
kb = fn98
k6 = fn315
kY = 0
kV = 0
kT = 0
kN = 0
kJ = 0
kG = 0
kB = fn545
le = fn667
kq = fn454
k_ = fn80
lk = fn481
ka = function()
    local qp
    local qq = os.clock()
    if qq - kT < (Options.ReplaceTurretDelay and Options.ReplaceTurretDelay.Value or 0.75) then
        return
    end
    if not lo("AutoReplaceTurrets") then
        return
    end
    local qq_1 = kc()
    if not qq_1 then
        return
    end
    kS()
    local qr_2 = Options.ReplaceTargetList and Options.ReplaceTargetList.Value
    local qs_1 = k9(qr_2)
    local qr_3 = Options.ReplaceWithList and Options.ReplaceWithList.Value
    local qt = k9(qr_3)
    local qu = Options.ReplaceCompareMode and Options.ReplaceCompareMode.Value or "Price"
    local qr_5 = {}
    qp = qu
    for i, v in ipairs(kQ) do
        local qu_1 = qt[v] and kr(v) > 0
        if qu_1 then
            table.insert(qr_5, v)
        end
    end
    if #qr_5 == 0 then
        return
    end
    table.sort(qr_5, function(eZ, e_)
        return kd(eZ, qp) > kd(e_, qp)
    end)
    local qt_1 = lb(qq_1)
    table.sort(qt_1, function(e5, e6)
        return kd(e5:GetAttribute("Name"), qp) < kd(e6:GetAttribute("Name"), qp)
    end)
    for i, v in ipairs(qt_1) do
        local attr4 = v:GetAttribute("Name")
        local attr3 = v:GetAttribute("UniqueId")
        local attr2 = v:GetAttribute("GridX")
        local attr = v:GetAttribute("GridZ")
        local qx = v:GetAttribute("RotationTurns") or 0
        local qx_1 = qs_1[attr4] and type(attr3) == "string"
        if qx_1 and attr2 ~= nil and attr ~= nil then
            local qx_3 = kd(attr4, qp)
            for i, v in ipairs(qr_5) do
                local qz_2 = v ~= attr4 and kr(v) > 0 and kd(v, qp) > qx_3
                if qz_2 then
                    if ki(qq_1, v, attr2, attr, qx, attr3) then
                        local qz_3 = kW(qq_1, v, attr2, attr, qx)
                        if qz_3 then
                            RemoveItemEvent:FireServer(attr3)
                            task.wait(0.45)
                            PlaceItemEvent:FireServer(v, qz_3, qq_1)
                            kT = os.clock()
                            task.defer(kS)
                            return
                        end
                    end
                end
            end
        end
    end
end
lp = fn847
k1 = fn431
if (not ls_1 or not ls_1) and (not lb and 22) and (Window and kX or not Window and kX) or not ((not ls_1 or not ls_1) and (not lb and 22) and (Window and kX or not Window and kX)) then
    Window = Library:CreateWindow({
        Title = "Tempo Hub",
        Footer = { { Text = k2, Copyable = true }, "|", lC },
        Icon = 12645376577,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 10
    })
else
    lC = k2:CreateWindow({
        NotifySide = "Right",
        Footer = { { Text = Library, Copyable = true }, "|", Window },
        Title = "Tempo Hub",
        CornerRadius = 10,
        ShowCustomCursor = false,
        Icon = 12645376577
    })
end
local lt = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "bug"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in lt do
    if v ~= lt.Info then
        fn756(v)
    end
end
ko, Label, ln = nil, nil, nil
do
    ko = "Unknown"
    pcall(fn751)
    local AccountGroup = lt.Info:AddLeftGroupbox("Account", "circle-user")
    AccountGroup:AddLabel(kt("User", LocalPlayer.Name, lA), true)
    AccountGroup:AddLabel(kt("Status", "Keyless", lA), true)
    AccountGroup:AddLabel(kt("Executor", ko, lA), true)
    lv = lt.Info:AddLeftGroupbox("Game Info", "gamepad-2")
    lv:AddLabel(kD(lC .. " [" .. tostring(game.PlaceId) .. "]", lz), true)
    lv:AddLabel(kt("Place ID", tostring(game.PlaceId), lz), true)
    Label = lv:AddLabel(kt("Session time", "0s", kf), true)
end
ln = tostring(game.JobId)
lu = #ln > 18
if lu then
    local lq_8 = 2
    repeat
        if (lq_8 * 3 + 1) * 21 % 4 == ((lq_8 * 3 + 1) * 21 + 10) % 4 then
            ln = string.sub(lu, 1, 18) .. "..."
        else
            lu = string.sub(ln, 1, 18) .. "..."
        end
        lq_8 = (lq_8 + 5) % 8
    until (lq_8 * 1 + 4) % 8 == 3
end
local lq_9 = lu or ln
k3, k5, k0, connection, connection2, kH = nil, nil, nil, nil, nil, nil
lv:AddLabel(kt("Server", lq_9, ly), true)
lv:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
k3 = os.clock()
task.spawn(worker)
local ScriptsGroup = lt.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(kD("Included in this hub", ly), true)
ScriptsGroup:AddLabel(kD(lC, lz), true)
local FeaturesGroup = lt.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(kD("Auto Buy", lz), true)
FeaturesGroup:AddLabel(kD("Combat", kf), true)
FeaturesGroup:AddLabel(kD("Placement", lA), true)
FeaturesGroup:AddLabel(kD("Auto Replace", lz), true)
FeaturesGroup:AddLabel(kD("Waves", ly), true)
local SocialsGroup = lt.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = kP })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = lt.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = kP })
lx = lt.Info:AddRightGroupbox("FAQ", "circle-help")
lx:AddLabel("Where do I get a good config?", true)
lx:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
lx:AddLabel("How do I import / export configs?", true)
lx:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
lx:AddLabel("How do I report bugs?", true)
lx:AddLabel("Join the Discord and post it in the bugs channel.", true)
lx:AddLabel("How do I make suggestions?", true)
lx:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
lx:AddLabel("How do I get help or updates?", true)
lx:AddLabel("Join the Discord, updates and support are posted there first.", true)
lw = lt.Main:AddLeftGroupbox("Shop", "shopping-cart")
lw:AddToggle("AutoBuyTurrets", { Text = "Auto Buy Turrets", Default = false })
lw:AddDropdown("AutoBuyTurretList", { Text = "Turrets", Values = kQ, Default = { "BasicTurret" }, Multi = true, AllowNull = true })
lw:AddToggle("AutoBuyBlocks", { Text = "Auto Buy Blocks", Default = false })
lw:AddDropdown("AutoBuyBlockList", { Text = "Blocks", Values = kL, Default = { "WoodBlock" }, Multi = true, AllowNull = true })
lw:AddToggle("AutoBuyCrates", { Text = "Auto Buy Crates", Default = false })
lw:AddDropdown("AutoBuyCrateList", { Text = "Crates", Values = ll, Default = { "Bronze Crate" }, Multi = true, AllowNull = true })
lu = lt.Main:AddLeftGroupbox("Combat", "swords")
lu:AddToggle("KillAura", { Text = "Kill Aura", Default = false })
lu:AddSlider("KillAuraRange", { Text = "Kill Aura Range", Default = 30, Min = 5, Max = 100, Rounding = 0 })
lu:AddSlider("KillAuraPlotRange", { Text = "Plot Range", Default = 120, Min = 40, Max = 300, Rounding = 0 })
lu:AddSlider("KillAuraDelay", { Text = "Kill Aura Delay", Default = 0.35, Min = 0.1, Max = 1.5, Rounding = 2 })
local PlacementGroup = lt.Main:AddRightGroupbox("Placement", "map-pin")
PlacementGroup:AddToggle("AutoPlaceTurrets", { Text = "Auto Place Turrets Near Path", Default = false })
PlacementGroup:AddDropdown("PlaceTurretList", { Text = "Place Turrets", Values = kQ, Default = { "BasicTurret" }, Multi = true, AllowNull = true })
PlacementGroup:AddSlider("PlaceTurretDelay", { Text = "Place Delay", Default = 0.65, Min = 0.35, Max = 3, Rounding = 2 })
PlacementGroup:AddSlider("PlaceTurretRotation", { Text = "Rotation", Default = 0, Min = 0, Max = 270, Rounding = 0 })
PlacementGroup:AddToggle("AutoReplaceTurrets", { Text = "Auto Replace Turrets", Default = false })
PlacementGroup:AddDropdown("ReplaceTargetList", { Text = "Replace Targets", Values = kQ, Default = kQ, Multi = true, AllowNull = true })
PlacementGroup:AddDropdown("ReplaceWithList", { Text = "Replace With", Values = kQ, Default = kQ, Multi = true, AllowNull = true })
PlacementGroup:AddDropdown("ReplaceCompareMode", { Text = "Compare By", Values = lB, Default = "Price" })
PlacementGroup:AddSlider("ReplaceTurretDelay", { Text = "Replace Delay", Default = 0.75, Min = 0.4, Max = 3, Rounding = 2 })
local WavesGroup = lt.Main:AddRightGroupbox("Waves", "play")
WavesGroup:AddToggle("AutoStartFight", { Text = "Auto Start Fight", Default = false })
WavesGroup:AddToggle("AutoWave", {
    Text = "Auto Wave",
    Default = false,
    Callback = function(gf)
        pcall(function()
            SetAutoWave:FireServer(gf == true)
        end)
    end
})
local MenuGroup = lt.Settings:AddLeftGroupbox("Menu", "menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton({ Text = "Unload", Func = onUnload })
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(lt.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/stop-the-bugs")
SaveManager:BuildConfigSection(lt.Settings)
SaveManager:LoadAutoloadConfig()
k5 = tick()
k0 = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local rj = v
        pcall(function()
            rj:Disable()
        end)
    end
end)
kH = fn676
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
Library:OnUnload(fn623)
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
end)(...)

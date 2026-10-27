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
getgenv().TempoHoodSubtitle = "SNOWCONE STAND"
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
local connection
local PlotSystem
local jb
local UserId
local je
local iA
local Data
local iD
local iZ
local iG
local VirtualUser
local iJ
local CollectionService
local iM
local iw
local iz
local iY
local iF
local Library
local Options
local i9
local Zones
local iR
local Toggles
local iy
local iU
local iB
local LocalPlayer
local iE
local i_
local iH
local function autoHarvestPlantsLoop()
    while not Library.Unloaded do
        if Toggles.AutoHarvestPlants.Value then
            iY()
        end
        task.wait(0.5)
    end
end
local function fn119(bl)
    for i, v in ipairs(Zones) do
        if v.name == bl then
            return v.max
        end
    end
    return 0.65
end
local function fn121(ee, ef)
    local oy = tonumber(ef:GetAttribute("RipeAt"))
    if oy then
        return oy <= os.time()
    end
    local oy_1 = (tonumber(ee:GetAttribute("YieldReady")))
    local oC = if oy_1 then 1 else 0
    local oA = 168 * oC + 1069 * (1 - oC)
    local oB = 2950 * oC + 3044 * (1 - oC)
    if not ((oA * 602 + oB * 3367 + oA * oB) % 16777213 == 10529386) then
        oy_1 = 0
    end
    return oy_1 >= 1
end
local function fn132(fy)
    fy:AddLeftGroupbox("Discord"):AddButton({ Text = "Join Discord For Dupe", Func = iU })
end
local function autoBuyFlavorsLoop()
    while not Library.Unloaded do
        if Toggles.AutoBuyFlavors.Value then
            iz()
        end
        task.wait(0.5)
    end
end
local function onHarvestPlants(fU)
    local qd = {}
    for k, v in fU do
        if v then
            qd[k] = true
        end
    end
    i_ = qd
end
local function fn219()
    if setclipboard then
        setclipboard(iZ)
    elseif toclipboard then
        toclipboard(iZ)
    end
    Library:Notify("Copied Discord invite to clipboard")
end
local function fn223()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    select("#", "Snowcone Stand unloaded")
end
local function fn229()
end
local function fn305()
    local Character = LocalPlayer.Character
    if Character then
        for i, child in ipairs(Character:GetChildren()) do
            local m3_1 = child:IsA("Tool") and CollectionService:HasTag(child, iG)
            if m3_1 then
                return child
            end
        end
    end
    return nil
end
local function autoBuyPlantsLoop()
    while not Library.Unloaded do
        if Toggles.AutoBuyPlants.Value then
            iH()
        end
        task.wait(0.5)
    end
end
local function fn354()
    local kJ_1
    local kI_1
    local kH = {}
    kI_1, kJ_1 = pcall(function()
        return Data:Get("ShopStock")
    end)
    local kK = kI_1 and type(kJ_1) == "table" and type(kJ_1.Plants) == "table"
    if kK then
        for i, v in ipairs(kJ_1.Plants) do
            if v.name then
                local name = v.name
                local kJ_2 = (tonumber(v.remaining))
                local kU = if kJ_2 then 1 else 0
                local kS = 3851 * kU + 1541 * (1 - kU)
                local kT = 1270 * kU + 2278 * (1 - kU)
                if not ((kS * 2384 + kT * 988 + kS * kT) % 16777213 == 15326314) then
                    kJ_2 = tonumber(v.stock)
                end
                local kK_1 = kJ_2 or 0
                kH[name] = { remaining = kK_1, cash = tonumber(v.cash) }
            end
        end
    end
    return kH
end
local function autoBlendLoop()
    while not Library.Unloaded do
        if Toggles.AutoBlend.Value then
            i9()
        end
        local qr = Options.BlendDelay.Value or 0.2
        task.wait(qr)
    end
end
local function fn412()
    local kc_1
    local kb_1
    kb_1, kc_1 = pcall(function()
        return Data:Get("ShopStock")
    end)
    local kd = kb_1 and type(kc_1) == "table"
    if kd then
        if type(kc_1.Flavors) == "table" then
            table.clear(iJ)
            table.clear(iF)
            for i, v in ipairs(kc_1.Flavors) do
                if v.name then
                    iJ[#iJ + 1] = v.name
                    local name = v.name
                    local kd_1 = v.tier
                    local ko = if kd_1 then 1 else 0
                    local km = 2475 * ko + 272 * (1 - ko)
                    local kn = 723 * ko + 3951 * (1 - ko)
                    if not ((km * 1156 + kn * 1399 + km * kn) % 16777213 == 5662002) then
                        kd_1 = v.rarity
                    end
                    local ke = kd_1 or "Common"
                    iF[name] = ke
                end
            end
        end
        if type(kc_1.Plants) == "table" then
            table.clear(iA)
            table.clear(iw)
            for i, v in ipairs(kc_1.Plants) do
                if v.name then
                    iA[#iA + 1] = v.name
                    local name = v.name
                    local kd_2 = v.tier or v.rarity or "Common"
                    iw[name] = kd_2
                end
            end
        end
    end
end
local function autoBuyLandLoop()
    while not Library.Unloaded do
        if Toggles.AutoBuyLand.Value then
            iR()
        end
        task.wait(0.5)
    end
end
local function autoClaimQuestsLoop()
    while not Library.Unloaded do
        if Toggles.AutoClaimQuests.Value then
            je()
        end
        task.wait(1)
    end
end
local function onUnload()
    Library:Unload()
end
local function onAntiAfk(f2)
    if f2 then
        if not connection then
            connection = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    elseif connection then
        connection:Disconnect()
        connection = nil
    end
end
local function fn546(bq, br)
    if bq:GetAttribute("Blending") ~= true then
        return false
    end
    local lS = (bq:GetAttribute("BlendStart"))
    local lY = if lS then 1 else 0
    local lW = 3220 * lY + 3566 * (1 - lY)
    local lX = 676 * lY + 1154 * (1 - lY)
    if not ((lW * 3345 + lX * 152 + lW * lX) % 16777213 == 13050372) then
        lS = 0
    end
    local lT = lS
    local lS_1 = (bq:GetAttribute("BlendDuration"))
    local l0 = if lS_1 then 1 else 0
    local lZ = 2153 * l0 + 1775 * (1 - l0)
    local l_ = 119 * l0 + 3846 * (1 - l0)
    if not ((lZ * 430 + l_ * 1108 + lZ * l_) % 16777213 == 1313849) then
        lS_1 = 1
    end
    local lU = lS_1
    local lS_2 = (workspace:GetServerTimeNow() - lT) / math.max(lU, 0.01)
    if br == "Any" then
        return lS_2 > 0.16
    end
    local lT_1 = PlotSystem.GetBlendZone(math.clamp(lS_2, 0, 1))
    if lT_1.name == br then
        return true
    end
    return lS_2 >= jb(br)
end
local function fn577()
    local ky_1
    local kx_1
    local kw = {}
    kx_1, ky_1 = pcall(function()
        return Data:Get("ShopStock")
    end)
    local kz = kx_1 and type(ky_1) == "table" and type(ky_1.Flavors) == "table"
    if kz then
        for i, v in ipairs(ky_1.Flavors) do
            if v.name then
                local name = v.name
                local ky_2 = tonumber(v.remaining) or tonumber(v.stock)
                local kz_1 = ky_2 or 0
                kw[name] = { remaining = kz_1, cash = tonumber(v.cash), gem = tonumber(v.gem) }
            end
        end
    end
    return kw
end
local function fn701()
    local on = {}
    for i, v in ipairs(CollectionService:GetTagged(PlotSystem.PlacedItemTag)) do
        local oo = v:IsDescendantOf(workspace) and v:GetAttribute("OwnerUserId") == UserId and PlotSystem.IsPlant(v)
        if oo then
            on[#on + 1] = v
        end
    end
    return on
end
local function fn723()
    local ls = {}
    for i, v in ipairs(CollectionService:GetTagged(iy)) do
        local lt = v:IsDescendantOf(workspace) and v:GetAttribute("OwnerUserId") == UserId
        if lt then
            local lt_1 = {}
            for i, descendant in ipairs(v:GetDescendants()) do
                local lu = descendant:IsA("BasePart") and descendant.Name == "PlacePart"
                if lu then
                    lt_1[#lt_1 + 1] = descendant
                end
            end
            if #lt_1 > 0 then
                ls[#ls + 1] = { model = v, slots = lt_1 }
            end
        end
    end
    return ls
end
local function onBuyPlants(fO)
    local p5 = {}
    for k, v in fO do
        if v then
            p5[k] = true
        end
    end
    iM = p5
end
local function fn732()
    for i, v in ipairs(CollectionService:GetTagged("OwnedPlot")) do
        local o_ = v:IsDescendantOf(workspace) and v:GetAttribute("OwnerUserId") == UserId
        if o_ then
            return v
        end
    end
    return nil
end
local function fn734()
    Library.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
local function onBuyFlavors(fI)
    local pY = {}
    for k, v in fI do
        if v then
            pY[k] = true
        end
    end
    iE = pY
end
local function fn744(eP)
    local pa = eP
    while true do
        local pi = if pa and pa ~= workspace then 1 else 0
        local pg = 3866 * pi + 3456 * (1 - pi)
        local ph = 2922 * pi + 2200 * (1 - pi)
        if not ((pg * 731 + ph * 1760 + pg * ph) % 16777213 == 2488005) then
            return nil
        end
        local pf = if CollectionService:HasTag(pa, "ExpansionTile") then 1 else 0
        if pf == 1 then
            break
        end
        pa = pa.Parent
    end
    return pa
end
local function fn760()
    local k4 = {}
    for i, v in ipairs(CollectionService:GetTagged(iB)) do
        local k5 = v:IsDescendantOf(workspace) and v:GetAttribute("OwnerUserId") == UserId
        if k5 then
            local k5_1 = {}
            local k6 = {}
            for i, descendant in ipairs(v:GetDescendants()) do
                local k7 = descendant:IsA("BasePart") and descendant.Name == "BlenderPart"
                if k7 then
                    local k7_1 = descendant.Parent and descendant.Parent.Parent
                    local k8 = k7_1
                    if k7_1 then
                        k7_1 = not k6[k8]
                    end
                    if k7_1 then
                        k6[k8] = true
                        k5_1[#k5_1 + 1] = k8
                    end
                end
            end
            if #k5_1 > 0 then
                k4[#k4 + 1] = { model = v, jars = k5_1 }
            end
        end
    end
    return k4
end
local function autoServeLoop()
    while not Library.Unloaded do
        if Toggles.AutoServe.Value then
            iD()
        end
        task.wait(0.3)
    end
end
Zones = nil
iw = nil
iy = nil
iz = nil
iA = nil
iB = nil
iD = nil
iE = nil
iF = nil
iG = nil
iH = nil
Library = nil
iJ = nil
iM = nil
PlotSystem = nil
iR = nil
UserId = nil
iU = nil
Data = nil
LocalPlayer = nil
iY = nil
iZ = nil
i_ = nil
VirtualUser = nil
CollectionService = nil
connection = nil
Options = nil
i9 = nil
jb = nil
Toggles = nil
je = nil
local is, it, iu, ix, iC, iK, iL, iN, PlotGrid, iP, iS, iV, Network, i2, i3, i7, i8, ja, jd
local AutoPlaceConeGroup
local AutoHarvestPlantsGroup
local jg_1
local js_1
local jp_1
local jh_1
local jf_1, AutoClaimQuestsGroup
jf_1, jh_1, CollectionService, VirtualUser, LocalPlayer, UserId = nil, nil, nil, nil, nil, nil
if (not UserId or LocalPlayer) and false and (CollectionService or VirtualUser and not UserId) or not ((not UserId or LocalPlayer) and false and (CollectionService or VirtualUser and not UserId)) then
    jf_1 = game:GetService("Players")
else
    jh_1 = game:GetService("Players")
end
if not jf_1 and jh_1 and 3 or jh_1 and VirtualUser and (VirtualUser and 3) or not (not jf_1 and jh_1 and 3 or jh_1 and VirtualUser and (VirtualUser and 3)) then
    jh_1 = game:GetService("ReplicatedStorage")
else
    jf_1 = game:GetService("ReplicatedStorage")
end
CollectionService = game:GetService("CollectionService")
VirtualUser = game:GetService("VirtualUser")
LocalPlayer = jf_1.LocalPlayer
UserId = LocalPlayer.UserId
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
Library, Toggles, Options, Network, Data, PlotSystem, PlotGrid, iL, iG, iB, iy, Zones, it, ja = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
pcall(fn734)
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
local Modules = jh_1:WaitForChild("Modules")
Network = require(Modules.Shared.Network.Network)
Data = require(Modules.Client.Network.ReplicaHandler.Data)
PlotSystem = require(Modules.Shared.Config.PlotSystem)
PlotGrid = require(Modules.Shared.Data.PlotGrid)
iL = "FlavorTool"
iG = "SnowConeTool"
iB = "ProductionBlender"
iy = "ServingTable"
Zones = PlotSystem.Production.Zones
it = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Exotic", "Cosmic" }
ja = {}
for i, v in ipairs(it) do
    ja[v] = i
end
iZ, iJ, iF, iA, iw, iu, jg_1, iU = nil, nil, nil, nil, nil, nil, nil, nil
local jf_2 = 4
repeat
    local jh_2 = (jf_2 * 3 + 1) % 4 + 1
    if jh_2 <= 2 then
        if jh_2 <= 1 then
            local ji_1 = {
                "mgisf",
                "rfvvzllonuwt",
                "ywsbue",
                "wyk",
                "rdyvymmvyr",
                "jrbjy",
                "mziejkfxu",
                "gch",
                "kdvdlnd",
                "xgiudshini",
                "aqktmzthhpfw",
                "sdln",
                "ldemjkrbrlrg",
                "imghpmh"
            }
            if ji_1[(jf_2 * 29 + 46) % 14 + 1] < ji_1[(jf_2 * 29 + 46) % 14 + 1] then
                jg_1 = {}
                iu = {}
            else
                iu = {}
                jg_1 = {}
            end
            jf_2 = (jf_2 + 3) % 16
        else
            if jf_2 * 100040245 + 10 + 1 >= jf_2 * 100040245 + 10 + 1 + 1 then
                iU = "https://discord.gg/K7Qxnxkk46"
                iZ = fn219
            else
                iZ = "https://discord.gg/K7Qxnxkk46"
                iU = fn219
            end
            jf_2 = (jf_2 + 11) % 16
        end
    elseif jh_2 <= 3 then
        if (jf_2 * 2 + 2) * 4 % 3 == ((jf_2 * 2 + 2) * 4 + 8) % 3 then
            iF = {}
        else
            iJ = {}
        end
        jf_2 = (jf_2 + 11) % 16
    else
        local jh_3 = {
            "slmwcmp",
            "sbabyq",
            "aotlaifqza",
            "hjlk",
            "jcujdemei",
            "svixtntw",
            "mgbmj",
            "iigsfw",
            "wgvtlrfpjeyg",
            "gubojw",
            "xwfyfgy",
            "irnatwiupez",
            "uzkzcj",
            "znvgf",
            "dtexltyzwk"
        }
        if jh_3[(jf_2 * 54 + 44) % 15 + 1] <= jh_3[(jf_2 * 54 + 44) % 15 + 1] then
            iF = {}
            iA = {}
            iw = {}
        else
            iw = {}
            iF = {}
            iA = {}
        end
        jf_2 = (jf_2 + 7) % 16
    end
until (jf_2 * 5 + 15) % 16 == 3
for k, v in pairs(PlotSystem.Placeables) do
    local jf_3 = type(v) == "table" and v.behavior == "Plant"
    if jf_3 then
        local jf_4 = v.display
        local jB = if jf_4 then 1 else 0
        local jz = 1849 * jB + 864 * (1 - jB)
        local jA = 3027 * jB + 103 * (1 - jB)
        if not ((jz * 3993 + jA * 928 + jz * jA) % 16777213 == 15789036) then
            jf_4 = k
        end
        iu[k] = jf_4
        local jf_5 = #jg_1 + 1
        local jh_4 = v.display or k
        jg_1[jf_5] = jh_4
    end
end
table.sort(jg_1)
iE, iM, i_, iK, iS, i2, ix, i7, jb, iP, i3, i9, iC, i8, iD, iz, iH, iV, is, iY, iN, jd, iR, je = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
fn412()
iK = fn577
iS = fn354
i2 = function(aM)
    local k1_1
    local k0_1
    k0_1, k1_1 = pcall(function()
        local kW = aM == "gem" and "Gems"
        local k_ = if kW then 1 else 0
        local kY = 177 * k_ + 3465 * (1 - k_)
        local kZ = 1351 * k_ + 2096 * (1 - k_)
        if not ((kY * 1940 + kZ * 2103 + kY * kZ) % 16777213 == 3423660) then
            kW = "Cash"
        end
        return Data:Get(kW)
    end)
    local k2 = k0_1 and tonumber(k1_1)
    return k2 or 0
end
ix = fn760
i7 = fn723
jb = fn119
iP = fn546
i3 = function(bz, bA)
    local mc
    local Character = LocalPlayer.Character
    local me = Character and Character:FindFirstChildOfClass("Humanoid")
    if not me then
        return nil
    end
    for i, child in ipairs(Character:GetChildren()) do
        local me_1 = child:IsA("Tool") and CollectionService:HasTag(child, bz)
        if me_1 then
            local me_2 = bA == nil
            local mk = if me_2 then 1 else 0
            local mi = 1097 * mk + 3757 * (1 - mk)
            local mj = 1438 * mk + 1302 * (1 - mk)
            if not ((mi * 2244 + mj * 1371 + mi * mj) % 16777213 == 6010652) then
                me_2 = bA == "Any"
            end
            if not me_2 then
                me_2 = child.Name == bA
            end
            if me_2 then
                return child
            end
        end
    end
    mc = {}
    local function me_3(bM)
        if bM then
            for i, child in ipairs(bM:GetChildren()) do
                local l4 = child:IsA("Tool") and CollectionService:HasTag(child, bz)
                if l4 then
                    mc[#mc + 1] = child
                end
            end
        end
    end
    me_3(LocalPlayer:FindFirstChildOfClass("Backpack"))
    me_3(Character)
    local mg
    if bA and bA ~= "Any" then
        for i, v in ipairs(mc) do
            if v.Name == bA then
                mg = v
                break
            end
        end
    else
        mg = mc[1]
    end
    if not mg then
        return nil
    end
    me:EquipTool(mg)
    return mg
end
i9 = function()
    for i, v in ipairs(ix()) do
        local mE = v
        for i, v in ipairs(mE.jars) do
            local mK = v
            local mx = Library.Unloaded or not Toggles.AutoBlend.Value
            local mx_1
            if mx then
                return
            end
            if mK:GetAttribute("Blending") ~= true then
                if Toggles.AutoStartBlend.Value then
                    if Toggles.AutoEquipFlavor.Value then
                        mx_1 = i3(iL, Options.FlavorToUse.Value)
                    else
                        mx_1 = i3(iL, "Any")
                    end
                    if mx_1 then
                        pcall(function()
                            Network:FireServer("BlenderInteract", mE.model, mK)
                        end)
                        task.wait(0.1)
                    end
                end
            elseif Toggles.AutoCollectCone.Value then
                if iP(mK, Options.CollectQuality.Value) then
                    pcall(function()
                        Network:FireServer("CollectBlender", mE.model, mK)
                    end)
                    task.wait(0.1)
                end
            end
        end
    end
end
iC = function()
    local cf, cg
    local function ch(ci)
        if ci then
            for i, child in ipairs(ci:GetChildren()) do
                local mO = child:IsA("Tool") and CollectionService:HasTag(child, iG)
                if mO then
                    local mO_1 = tonumber(child:GetAttribute("Value")) or 0
                    local mP = not cg
                    local m_ = if mP then 1 else 0
                    local mY = 3794 * m_ + 726 * (1 - m_)
                    local mZ = 1944 * m_ + 3182 * (1 - m_)
                    if not ((mY * 3521 + mZ * 328 + mY * mZ) % 16777213 == 4594629) then
                        mP = mO_1 > cg
                    end
                    if mP then
                        cf = child
                        cg = mO_1
                    end
                end
            end
        end
    end
    ch(LocalPlayer.Character)
    ch(LocalPlayer:FindFirstChildOfClass("Backpack"))
    return cf
end
i8 = fn305
iD = function()
    local Value = Options.ServeMode.Value
    for i, v in ipairs(i7()) do
        local nn = v
        for i, v in ipairs(nn.slots) do
            local nt = v
            local nc = Library.Unloaded or not Toggles.AutoServe.Value
            local nc_1
            if nc then
                return
            end
            if not nt:FindFirstChild("Cone") then
                if Value == "Fill All Slots (Highest Value)" then
                    nc_1 = iC()
                    local Character = LocalPlayer.Character
                    local ne = Character and Character:FindFirstChildOfClass("Humanoid")
                    if nc_1 and ne and nc_1.Parent ~= Character then
                        ne:EquipTool(nc_1)
                    end
                elseif Toggles.AutoEquipCone.Value then
                    nc_1 = i3(iG, "Any")
                else
                    nc_1 = i8()
                end
                if not nc_1 then
                    return
                end
                pcall(function()
                    Network:FireServer("ServeCone", nn.model, nt)
                end)
                local wait = task.wait
                local nd_2 = Options.ServeDelay.Value or 0.2
                wait(nd_2)
                if Value == "One Per Table" then
                    break
                end
            end
        end
    end
end
iE = {}
iz = function()
    local ny = iK()
    local nx = Options.BuyCurrency.Value == "Gem" and "gem" or "cash"
    local nz_1 = ja[Options.BuyMaxTier.Value] or #it
    local nz_2 = next(iE) ~= nil
    local Value = Toggles.BuyOnlyInStock.Value
    local floor = math.floor
    local nC_3
    local nD = Options.BuyPerFlavor.Value or 1
    local nE = floor(nD)
    local nC_1 = Options.BuyDelay.Value or 0.6
    for i, v in ipairs(iJ) do
        local nN = v
        local nC_2 = Library.Unloaded
        local nQ = if nC_2 then 1 else 0
        local nO = 2124 * nQ + 2477 * (1 - nQ)
        local nP = 1962 * nQ + 401 * (1 - nQ)
        if not ((nO * 1399 + nP * 608 + nO * nP) % 16777213 == 8331660) then
            nC_2 = not Toggles.AutoBuyFlavors.Value
        end
        if nC_2 then
            return
        end
        if nz_2 then
            nC_3 = iE[nN] == true
        else
            local nF_1 = iF[nN]
            local nQ_1 = if nF_1 then 1 else 0
            local nO_1 = 4076 * nQ_1 + 1271 * (1 - nQ_1)
            local nP_1 = 1261 * nQ_1 + 986 * (1 - nQ_1)
            if not ((nO_1 * 2195 + nP_1 * 580 + nO_1 * nP_1) % 16777213 == 14818036) then
                nF_1 = "Common"
            end
            nC_3 = (ja[nF_1] or 99) <= nz_1
        end
        local nF_2 = ny[nN]
        local nG_2 = nC_3 and nF_2
        if nG_2 then
            local nC_4 = not Value
            local nQ_2 = if nC_4 then 1 else 0
            local nO_2 = 2655 * nQ_2 + 2131 * (1 - nQ_2)
            local nP_2 = 1335 * nQ_2 + 3127 * (1 - nQ_2)
            if not ((nO_2 * 4044 + nP_2 * 2378 + nO_2 * nP_2) % 16777213 == 678662) then
                nC_4 = nF_2.remaining > 0
            end
            nG_2 = nC_4
        end
        if nG_2 then
            local nC_5 = nF_2[nx]
            local nF_3 = nC_5 and i2(nx) >= nC_5
            if nF_3 then
                local nW = 1
                while nW <= nE do
                    if Library.Unloaded or not Toggles.AutoBuyFlavors.Value then
                        return
                    end
                    if i2(nx) < nC_5 then
                        break
                    end
                    pcall(function()
                        Network:FireServer("BuyShopItem", "Flavors", nN, nx)
                    end)
                    task.wait(nC_1)
                    nW += 1
                end
            end
        end
    end
end
iM = {}
iH = function()
    local nZ = iS()
    local n_ = ja[Options.BuyPlantsMaxTier.Value] or #it
    local n__1 = next(iM) ~= nil
    local Value = Toggles.BuyPlantsOnlyInStock.Value
    local floor = math.floor
    local n2_3
    local n3 = Options.BuyPlantsPerPlant.Value or 1
    local n4 = floor(n3)
    local n2_1 = Options.BuyPlantsDelay.Value or 0.6
    for i, v in ipairs(iA) do
        local od = v
        if Library.Unloaded or not Toggles.AutoBuyPlants.Value then
            return
        end
        if n__1 then
            n2_3 = iM[od] == true
        else
            n2_3 = (ja[iw[od] or "Common"] or 99) <= n_
        end
        local n5_2 = nZ[od]
        local n6_2 = n2_3 and n5_2
        if n6_2 then
            n6_2 = not Value or n5_2.remaining > 0
        end
        if n6_2 then
            local cash = n5_2.cash
            local n5_3 = cash and i2("cash") >= cash
            if n5_3 then
                local og = 1
                while og <= n4 do
                    if Library.Unloaded or not Toggles.AutoBuyPlants.Value then
                        return
                    end
                    local om = if i2("cash") < cash then 1 else 0
                    if om == 1 then
                        break
                    end
                    pcall(function()
                        Network:FireServer("BuyPlant", od)
                    end)
                    task.wait(n2_1)
                    og += 1
                end
            end
        end
    end
end
i_ = {}
iV = fn701
is = fn121
iY = function()
    local oE = next(i_) ~= nil
    local Value = Toggles.HarvestOnlyRipe.Value
    local oG = Options.HarvestDelay.Value or 0.15
    for i, v in ipairs(iV()) do
        if Library.Unloaded or not Toggles.AutoHarvestPlants.Value then
            return
        end
        local oG_2 = v:GetAttribute("PlaceableId") or v.Name
        local oI = iu[oG_2]
        if not oE or oI and i_[oI] == true then
            local Fruits = v:FindFirstChild("_Fruits")
            if Fruits then
                for i, child in ipairs(Fruits:GetChildren()) do
                    if Library.Unloaded or not Toggles.AutoHarvestPlants.Value then
                        return
                    end
                    if child:IsA("BasePart") then
                        local FruitHarvest = child:FindFirstChild("FruitHarvest")
                        local oG_6 = FruitHarvest and FruitHarvest:IsA("ProximityPrompt")
                        if oG_6 then
                            local oI_1 = not Value or is(v, child)
                            oG_6 = oI_1
                        end
                        if oG_6 then
                            pcall(function()
                                fireproximityprompt(FruitHarvest)
                            end)
                            task.wait(oG)
                        end
                    end
                end
            end
        end
    end
end
iN = fn732
jd = fn744
iR = function()
    local pn = iN()
    if not pn then
        return
    end
    local po = {}
    local pp = Data:Get({ "Plot", "Cells" }) or po
    local pp_1 = PlotSystem.GetNextPrice(PlotGrid.CountUnlocked(pp))
    local po_2 = tonumber(Data:Get("Cash")) or 0
    local po_3 = tonumber(Options.LandReserve.Value) or 0
    local pr = not pp_1
    if not pr then
        pr = po_2 - pp_1 < po_3
    end
    if pr then
        return
    end
    for i, descendant in ipairs(pn:GetDescendants()) do
        local pn_1 = descendant:IsA("ProximityPrompt") and descendant.Enabled and descendant.ActionText == "Buy Land"
        if pn_1 then
            local pm = jd(descendant)
            if pm then
                pcall(function()
                    Network:FireServer("BuyExpansion", pm.Name)
                end)
                return
            end
        end
    end
end
je = function()
    local pA = Data:Get("Quests")
    if type(pA) ~= "table" then
        return
    end
    local pB = {}
    local pC = pA.active
    local pH = if pC then 1 else 0
    local pF = 2577 * pH + 824 * (1 - pH)
    local pG = 2248 * pH + 3387 * (1 - pH)
    if not ((pF * 238 + pG * 625 + pF * pG) % 16777213 == 7811422) then
        pC = pB
    end
    for i, v in ipairs(pC) do
        local pN = v
        if Library.Unloaded or not Toggles.AutoClaimQuests.Value then
            return
        end
        if pN.complete == true and pN.claimed ~= true then
            pcall(function()
                Network:FireServer("QuestClaim", pN.id)
            end)
            task.wait(0.2)
        end
    end
    if Toggles.ClaimTierRewards.Value then
        local pB_3 = pA.tiersUnlocked or 0
        local pA_1 = pA.tierClaimed or {}
        for i = 1, 4 do
            local pR = i
            if Library.Unloaded or not Toggles.AutoClaimQuests.Value then
                return
            end
            local pB_6 = pR <= pB_3 and pA_1[tostring(pR)] ~= true
            if pB_6 then
                pcall(function()
                    Network:FireServer("QuestClaimTier", pR)
                end)
                task.wait(0.2)
            end
        end
    end
end
Library.SetNotifySide = fn229
local Window = Library:CreateWindow({
    Title = "Snowcone Stand",
    Footer = "Tempo Hub",
    Size = UDim2.fromOffset(900, 640),
    ShowCustomCursor = false
})
Library.ShowCustomCursor = false
local jm = { Main = Window:AddTab("Main", "cup-soda"), Settings = Window:AddTab("Settings", "settings") }
for k, v in jm do
    fn132(v)
end
local AutoBlendGroup = jm.Main:AddLeftGroupbox("Auto Blend", "blend")
AutoBlendGroup:AddToggle("AutoBlend", { Text = "Auto Blend", Default = false })
AutoBlendGroup:AddToggle("AutoStartBlend", { Text = "Auto Start Blends", Default = true })
AutoBlendGroup:AddToggle("AutoCollectCone", { Text = "Auto Collect Cones", Default = true })
AutoBlendGroup:AddToggle("AutoEquipFlavor", { Text = "Auto Equip Flavor Tool", Default = true })
AutoBlendGroup:AddDropdown("CollectQuality", {
    Text = "Collect At",
    Values = { "Perfect", "Chunky", "Melted", "Any" },
    Default = "Perfect",
    Multi = false
})
local jh_6 = { "Any" }
for i, v in ipairs(iJ) do
    jh_6[#jh_6 + 1] = v
end
AutoPlaceConeGroup, jp_1, AutoHarvestPlantsGroup, AutoClaimQuestsGroup, js_1, connection = nil, nil, nil, nil, nil, nil
if jp_1 or not AutoClaimQuestsGroup or not AutoClaimQuestsGroup and jp_1 or AutoHarvestPlantsGroup and not AutoPlaceConeGroup and (jp_1 and not AutoHarvestPlantsGroup) or not (jp_1 or not AutoClaimQuestsGroup or not AutoClaimQuestsGroup and jp_1 or AutoHarvestPlantsGroup and not AutoPlaceConeGroup and (jp_1 and not AutoHarvestPlantsGroup)) then
    AutoBlendGroup:AddDropdown("FlavorToUse", { Text = "Flavor To Blend", Values = jh_6, Default = "Any", Multi = false })
    AutoBlendGroup:AddSlider("BlendDelay", { Text = "Loop Delay", Default = 0.2, Min = 0.1, Max = 2, Rounding = 2 })
    AutoPlaceConeGroup = jm.Main:AddLeftGroupbox("Auto Place Cone", "ice-cream-cone")
else
    AutoPlaceConeGroup:AddDropdown("FlavorToUse", { Values = AutoBlendGroup, Default = "Any", Text = "Flavor To Blend", Multi = false })
    AutoPlaceConeGroup:AddSlider("BlendDelay", { Default = 0.2, Rounding = 2, Max = 2, Min = 0.1, Text = "Loop Delay" })
    jm = jh_6.Main:AddLeftGroupbox("Auto Place Cone", "ice-cream-cone")
end
AutoPlaceConeGroup:AddToggle("AutoServe", { Text = "Auto Place Cone", Default = false })
AutoPlaceConeGroup:AddToggle("AutoEquipCone", { Text = "Auto Equip Cone", Default = true })
AutoPlaceConeGroup:AddDropdown("ServeMode", {
    Text = "Fill Mode",
    Values = { "Fill All Slots", "Fill All Slots (Highest Value)", "One Per Table" },
    Default = "Fill All Slots (Highest Value)",
    Multi = false
})
AutoPlaceConeGroup:AddSlider("ServeDelay", { Text = "Serve Delay", Default = 0.2, Min = 0.05, Max = 2, Rounding = 2 })
local AutoBuyFlavorsGroup = jm.Main:AddRightGroupbox("Auto Buy Flavors", "shopping-cart")
AutoBuyFlavorsGroup:AddToggle("AutoBuyFlavors", { Text = "Auto Buy Flavors", Default = false })
AutoBuyFlavorsGroup:AddToggle("BuyOnlyInStock", { Text = "Only Buy If In Stock", Default = true })
AutoBuyFlavorsGroup:AddDropdown("BuyCurrency", { Text = "Currency", Values = { "Cash", "Gem" }, Default = "Cash", Multi = false })
AutoBuyFlavorsGroup:AddDropdown("BuyMaxTier", { Text = "Max Tier", Values = it, Default = "Uncommon", Multi = false })
AutoBuyFlavorsGroup:AddDropdown("BuyFlavors", {
    Text = "Specific Flavors (empty = by tier)",
    Values = iJ,
    Default = {},
    Multi = true,
    Callback = onBuyFlavors
})
AutoBuyFlavorsGroup:AddSlider("BuyPerFlavor", { Text = "Buys Per Flavor", Default = 1, Min = 1, Max = 20, Rounding = 0 })
AutoBuyFlavorsGroup:AddSlider("BuyDelay", { Text = "Buy Delay", Default = 0.6, Min = 0.1, Max = 3, Rounding = 2 })
local AutoBuyPlantsGroup = jm.Main:AddRightGroupbox("Auto Buy Plants", "sprout")
if (js_1 and AutoPlaceConeGroup or (not AutoHarvestPlantsGroup or not AutoPlaceConeGroup)) and ((AutoBuyPlantsGroup or AutoPlaceConeGroup) and (not AutoBuyPlantsGroup or AutoPlaceConeGroup)) or (AutoPlaceConeGroup and not connection or connection and js_1) and (not AutoBuyPlantsGroup and not AutoHarvestPlantsGroup or not AutoBuyFlavorsGroup and AutoBuyFlavorsGroup) or not ((js_1 and AutoPlaceConeGroup or (not AutoHarvestPlantsGroup or not AutoPlaceConeGroup)) and ((AutoBuyPlantsGroup or AutoPlaceConeGroup) and (not AutoBuyPlantsGroup or AutoPlaceConeGroup)) or (AutoPlaceConeGroup and not connection or connection and js_1) and (not AutoBuyPlantsGroup and not AutoHarvestPlantsGroup or not AutoBuyFlavorsGroup and AutoBuyFlavorsGroup)) then
    AutoBuyPlantsGroup:AddToggle("AutoBuyPlants", { Text = "Auto Buy Plants", Default = false })
    AutoBuyPlantsGroup:AddToggle("BuyPlantsOnlyInStock", { Text = "Only Buy If In Stock", Default = true })
    AutoBuyPlantsGroup:AddDropdown("BuyPlantsMaxTier", { Text = "Max Tier", Values = it, Default = "Common", Multi = false })
    AutoBuyPlantsGroup:AddDropdown("BuyPlants", {
        Text = "Specific Plants (empty = by tier)",
        Values = iA,
        Default = {},
        Multi = true,
        Callback = onBuyPlants
    })
    AutoBuyPlantsGroup:AddSlider("BuyPlantsPerPlant", { Text = "Buys Per Plant", Default = 1, Min = 1, Max = 10, Rounding = 0 })
    AutoBuyPlantsGroup:AddSlider("BuyPlantsDelay", { Text = "Buy Delay", Default = 0.6, Min = 0.1, Max = 3, Rounding = 2 })
    AutoHarvestPlantsGroup = jm.Main:AddLeftGroupbox("Auto Harvest Plants", "sprout")
else
    AutoHarvestPlantsGroup:AddToggle("AutoBuyPlants", { Text = "Auto Buy Plants", Default = false })
    AutoHarvestPlantsGroup:AddToggle("BuyPlantsOnlyInStock", { Text = "Only Buy If In Stock", Default = true })
    AutoHarvestPlantsGroup:AddDropdown("BuyPlantsMaxTier", { Default = "Common", Text = "Max Tier", Values = AutoBuyPlantsGroup, Multi = false })
    AutoHarvestPlantsGroup:AddDropdown("BuyPlants", {
        Text = "Specific Plants (empty = by tier)",
        Callback = onBuyPlants,
        Values = it,
        Default = {},
        Multi = true
    })
    AutoHarvestPlantsGroup:AddSlider("BuyPlantsPerPlant", { Text = "Buys Per Plant", Default = 1, Min = 1, Max = 10, Rounding = 0 })
    AutoHarvestPlantsGroup:AddSlider("BuyPlantsDelay", { Min = 0.1, Default = 0.6, Text = "Buy Delay", Max = 3, Rounding = 2 })
    jm = iA.Main:AddLeftGroupbox("Auto Harvest Plants", "sprout")
end
AutoHarvestPlantsGroup:AddToggle("AutoHarvestPlants", { Text = "Auto Harvest Plants", Default = false })
AutoHarvestPlantsGroup:AddToggle("HarvestOnlyRipe", { Text = "Only Harvest Ripe", Default = true })
AutoHarvestPlantsGroup:AddDropdown("HarvestPlants", {
    Text = "Specific Plants (empty = all)",
    Values = jg_1,
    Default = {},
    Multi = true,
    Callback = onHarvestPlants
})
AutoHarvestPlantsGroup:AddSlider("HarvestDelay", { Text = "Harvest Delay", Default = 0.15, Min = 0.05, Max = 2, Rounding = 2 })
local AutoBuyLandGroup = jm.Main:AddRightGroupbox("Auto Buy Land", "map")
if (AutoPlaceConeGroup or not js_1 or (not AutoHarvestPlantsGroup or 22)) and (AutoPlaceConeGroup and 22 or not AutoHarvestPlantsGroup and not AutoHarvestPlantsGroup) and ((not AutoHarvestPlantsGroup and 22 or (not AutoPlaceConeGroup or false)) and ((not js_1 or AutoHarvestPlantsGroup) and (not AutoPlaceConeGroup or AutoHarvestPlantsGroup))) and ((js_1 or js_1) and false and ((not js_1 or not js_1) and (js_1 and js_1)) or (AutoHarvestPlantsGroup and AutoPlaceConeGroup and (js_1 and not AutoPlaceConeGroup) or (js_1 or AutoPlaceConeGroup or not AutoPlaceConeGroup))) and not ((AutoPlaceConeGroup or not js_1 or (not AutoHarvestPlantsGroup or 22)) and (AutoPlaceConeGroup and 22 or not AutoHarvestPlantsGroup and not AutoHarvestPlantsGroup) and ((not AutoHarvestPlantsGroup and 22 or (not AutoPlaceConeGroup or false)) and ((not js_1 or AutoHarvestPlantsGroup) and (not AutoPlaceConeGroup or AutoHarvestPlantsGroup))) and ((js_1 or js_1) and false and ((not js_1 or not js_1) and (js_1 and js_1)) or (AutoHarvestPlantsGroup and AutoPlaceConeGroup and (js_1 and not AutoPlaceConeGroup) or (js_1 or AutoPlaceConeGroup or not AutoPlaceConeGroup)))) then
    AutoClaimQuestsGroup:AddToggle("AutoBuyLand", { Text = "Auto Buy Land", Default = false })
    AutoClaimQuestsGroup:AddInput("LandReserve", { Finished = true, Default = "0", Text = "Keep Cash Reserve", Numeric = true })
    jm = AutoBuyLandGroup.Main:AddRightGroupbox("Auto Claim Quests", "scroll-text")
else
    AutoBuyLandGroup:AddToggle("AutoBuyLand", { Text = "Auto Buy Land", Default = false })
    AutoBuyLandGroup:AddInput("LandReserve", { Text = "Keep Cash Reserve", Default = "0", Numeric = true, Finished = true })
    AutoClaimQuestsGroup = jm.Main:AddRightGroupbox("Auto Claim Quests", "scroll-text")
end
AutoClaimQuestsGroup:AddToggle("AutoClaimQuests", { Text = "Auto Claim Quests", Default = false })
AutoClaimQuestsGroup:AddToggle("ClaimTierRewards", { Text = "Also Claim Tier Rewards", Default = true })
local MenuGroup = jm.Settings:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddLabel("UI Keybind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "UI Keybind" })
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true, Callback = onAntiAfk })
MenuGroup:AddButton("Unload", onUnload)
Library.ToggleKeybind = Options.MenuKeybind
Library:OnUnload(fn223)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Mint")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/SnowconeStand")
SaveManager:BuildConfigSection(jm.Settings)
ThemeManager:ApplyToTab(jm.Settings)
ThemeManager:LoadDefault()
SaveManager:LoadAutoloadConfig()
task.spawn(autoBlendLoop)
task.spawn(autoServeLoop)
task.spawn(autoBuyFlavorsLoop)
task.spawn(autoBuyPlantsLoop)
task.spawn(autoHarvestPlantsLoop)
task.spawn(autoBuyLandLoop)
task.spawn(autoClaimQuestsLoop)
Library:Notify("Snowcone Stand loaded")
end)(...)

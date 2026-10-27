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
getgenv().TempoHoodSubtitle = "BUILD A GOLEM!"
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
local nJ
local Options
local nM
local nq
local ct
local nP
local remotes
local nS
local nd
local nz
local od
local nF
local Crafters
local nm
local n3
local m3
local nL
local n6
local Toggles
local ns
local n9
local part_registry
local Inventory
local Selling
local nc
local ny
local nU
local Library
local nX
local n2
local nH
local no
local Local
local nK
local LocalPlayer
local n8
local m8
local nu
local gear_shop
local nA
local nD
local function fn86()
    if n9 and n9.world and n9.replicator then
        return n9
    end
    for k, v in getgc(true) do
        local pD_1 = type(v) == "table" and rawget(v, "world") and rawget(v, "replicator") and rawget(v, "scheduler")
        if pD_1 then
            n9 = v
            return n9
        end
    end
    return nil
end
local function fn95(dd, de, df)
    local qS = {}
    if de then
        for k, v in de do
            if v.golem == df then
                qS[k] = true
            elseif v.golem ~= nil then
                return false, qS
            end
        end
    end
    if dd then
        for k in dd do
            qS[k] = true
        end
    end
    return nK(qS), qS
end
local function fn139()
    local Character = LocalPlayer.Character
    local pM = Character and Character:FindFirstChildOfClass("Humanoid")
    return pM
end
local function fn148()
    nu(false)
    nq()
    if nc then
        nc:Disconnect()
    end
    n9 = nil
    local uO = nL()
    if uO then
        uO.PlatformStand = false
        uO.WalkSpeed = 16
    end
end
local function fn165(bl)
    local DiscordGroup = bl:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = n2 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = n2 })
end
local function fn173(eB, eC)
    local rF = Selling.held_sale(eB.world, eC)
    if rF ~= nil and not rF.last_golem then
        remotes.requests.sell:fire()
        return
    end
    if rF == nil then
        local rF_1 = Selling.held_tool(eB.world, eC)
        if rF_1 ~= nil then
            remotes.requests.sell:fire()
        end
    end
end
local function fn190(a7, a8)
    return string.format('<font color="%s">%s</font>', a8, a7)
end
local function fn230()
    local q3 = no("BuildGolemList")
    local q4 = {}
    for k in q3 do
        local q3_1 = nP[k]
        if q3_1 then
            q4[q3_1] = true
        end
    end
    return q4
end
local function fn254(aQ, aR)
    return aQ.label < aR.label
end
local function fn292(bT, bU)
    for k, v in bT:archetypes() do
        local entities = v.entities
        local qk = #entities
        local qj = -1
        while false and qk <= 1 or true and qk >= 1 do
            local ql = qk
            bU(entities[ql], v, ql)
            qk += qj
        end
    end
end
local function autoRollLoop()
    while not Library.Unloaded do
        local s7 = n6()
        if s7 then
            local s8 = Local.player(s7)
            local s9 = Local.plot(s7)
            if s8 and s9 then
                if Toggles.AutoRoll.Value then
                    pcall(ns, s7, s9)
                end
                if Toggles.AutoBuyRollResult.Value then
                    pcall(n3, s7, s9, s8)
                end
                if Toggles.AutoPickupBox.Value then
                    pcall(nm, s7, s9)
                end
                if Toggles.AutoSellBoxes.Value then
                    pcall(nX, s7, s8)
                end
                if Toggles.AutoBuyGears.Value then
                    pcall(nA)
                end
                if Toggles.AutoBuildGolem.Value then
                    pcall(n8, s7, s9)
                end
                if Toggles.AutoBuyPlots.Value then
                    pcall(nd, s7, s9, s8)
                end
                if Toggles.AutoPlaceGolem.Value then
                    pcall(nM, s7)
                end
                if Toggles.AutoUpgradeStation.Value then
                    pcall(m8, s7, s9)
                end
            end
        end
        task.wait(0.35)
    end
end
local function fn333()
    od(nD, "Copied Discord invite to clipboard")
end
local function fn375(bP)
    local p6 = no("BuyRarities")
    if next(p6) == nil then
        return true
    end
    return p6[bP] == true
end
local function fn404(fX)
    local sn = Local.player(fX)
    if not sn then
        return
    end
    local so = Crafters.held_tools(fX)
    if not so or not so.has_golem then
        local sp_1 = nz(fX, sn)
        if sp_1 == nil then
            return
        end
        Inventory.equip(fX, sp_1)
        task.wait(0.08)
        so = Crafters.held_tools(fX)
    end
    if not so or not so.has_golem then
        return
    end
    if nJ and nJ.place then
        nJ.place(fX)
    else
        remotes.requests.place:fire()
    end
end
local function fn422(a0, a1)
    if setclipboard then
        setclipboard(a0)
    elseif toclipboard then
        toclipboard(a0)
    end
    Library:Notify(a1)
end
local function fn469(U, V)
    return U.rank < V.rank
end
local function fn600(c8)
    if not c8 then
        return false
    end
    for k, v in nU do
        if not c8[v] then
            return false
        end
    end
    return true
end
local function fn607(ba, bb, bc)
    return string.format("<b>%s</b> %s %s", ba, nS("-", "#5a6070"), nS(bb, bc))
end
local function fn635(b_, b0)
    return b_.replicator:get_server_entity(b0)
end
local function fn675(b7)
    local qu_1
    local qt_1
    qt_1, qu_1 = pcall(part_registry.get, b7)
    if qt_1 then
        return qu_1
    end
    return nil
end
local function fn676()
    local rP_1
    local rO_1
    local rL = no("GearList")
    local rM = tonumber(Options.GearQuantity.Value) or 1
    for k in rL do
        local rL_1 = m3[k]
        if rL_1 then
            local rM_1 = 1
            if gear_shop.remaining_gear_stock then
                rO_1, rP_1 = pcall(gear_shop.remaining_gear_stock, rL_1)
                local rQ = rO_1 and type(rP_1) == "number"
                if rQ then
                    rM_1 = rP_1
                end
            end
            if rM_1 > 0 then
                remotes.requests.buy_gear:fire(rL_1, rM)
            end
        end
    end
end
local function fn761(b2, b3)
    local qn = b2.world:get(b3, ct.money)
    local qo = qn
    local qs = if qo then 1 else 0
    local qq = 1958 * qs + 1339 * (1 - qs)
    local qr = 3159 * qs + 3027 * (1 - qs)
    if not ((qq * 2590 + qr * 1393 + qq * qr) % 16777213 == 15657029) then
        qo = 0
    end
    return qo
end
local function fn783(dv, dw, dx)
    local golem
    if dw then
        for k, v in dw do
            if v.golem then
                if not dx[v.golem] then
                    return nil
                end
                golem = v.golem
                break
            end
        end
    end
    if golem then
        local rb = ny(dv[golem], dw, golem)
        if rb then
            return golem
        end
        return nil
    end
    for k in dx do
        local ra_1 = ny(dv[k], dw, k)
        if ra_1 then
            return k
        end
    end
    return nil
end
local function fn788(bG)
    local pX = Options[bG]
    local pY = pX and pX.Value
    local pX_1 = {}
    if type(pY) ~= "table" then
        return pX_1
    end
    for k, v in pY do
        if v then
            pX_1[k] = true
        end
    end
    return pX_1
end
local function fn800()
    local Character = LocalPlayer.Character
    local pS = Character and Character:FindFirstChild("HumanoidRootPart")
    return pS
end
local function fn875(cc)
    if type(cc) == "table" then
        return cc.part_id
    elseif type(cc) == "string" then
        return cc
    else
        return nil
    end
end
m3 = nil
Options = nil
Toggles = nil
m8 = nil
part_registry = nil
nc = nil
nd = nil
gear_shop = nil
Library = nil
nm = nil
no = nil
nq = nil
ns = nil
ct = nil
nu = nil
remotes = nil
ny = nil
nz = nil
nA = nil
nD = nil
nF = nil
nH = nil
nJ = nil
nK = nil
nL = nil
nM = nil
LocalPlayer = nil
Selling = nil
local is_full_set, m2, part_price, m7, SaveManager, nb, ng, plot_upgrades, ni, island_price, nk, slots, nn, pair, nr, nv, nx, nB, nC, nE, nG, nI
nP = nil
Inventory = nil
nS = nil
nU = nil
nX = nil
Crafters = nil
n2 = nil
n3 = nil
Local = nil
n6 = nil
n8 = nil
n9 = nil
od = nil
local Workspace, nT, nV, Plots, nY, nZ, n_, n1, n4, UserInputService, RunService, ob, oc
local oq_1
local on_1
local oh_1
RunService, UserInputService, n4, nZ, nV, nT, Workspace, LocalPlayer, oh_1, nG, nD, nC, remotes, ct, pair, slots, island_price, plot_upgrades, gear_shop, part_registry, part_price, is_full_set, on_1, Local, Crafters, Plots, Inventory, Selling = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local oe_4
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local oj_3
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
if (false and is_full_set or (nC or slots)) and (is_full_set and false or not pair and slots) and (pair or nC or false or (pair or is_full_set) and (pair or not is_full_set)) and not ((false and is_full_set or (nC or slots)) and (is_full_set and false or not pair and slots) and (pair or nC or false or (pair or is_full_set) and (pair or not is_full_set))) then
    nT = game:GetService("VirtualUser")
    nV = game:GetService("HttpService")
    nZ = game:GetService("GuiService")
    n4 = game:GetService("CoreGui")
else
    n4 = game:GetService("VirtualUser")
    nZ = game:GetService("HttpService")
    nV = game:GetService("GuiService")
    nT = game:GetService("CoreGui")
end
Workspace = game:GetService("Workspace")
if (not Workspace and oh_1 and (not Plots and not Workspace) or (not oh_1 and not Workspace or (part_registry or oh_1)) or part_registry and not part_registry and (not Workspace or false) and (oh_1 and not on_1 or not Plots and Workspace)) and not (not Workspace and oh_1 and (not Plots and not Workspace) or (not oh_1 and not Workspace or (part_registry or oh_1)) or part_registry and not part_registry and (not Workspace or false) and (oh_1 and not on_1 or not Plots and Workspace)) then
else
    LocalPlayer = Players.LocalPlayer
end
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
nG = "Build A Golem"
nD = "https://discord.gg/K7Qxnxkk46"
nC = "https://discord.gg/K7Qxnxkk46"
local TS = ReplicatedStorage:WaitForChild("TS")
local og_3, og_4
remotes = require(TS:WaitForChild("remotes")).remotes
ct = require(TS:WaitForChild("components")).ct
pair = require(ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("jecs"):WaitForChild("src"):WaitForChild("jecs")).pair
slots = require(TS:WaitForChild("constants"):WaitForChild("slots")).slots
island_price = require(TS:WaitForChild("constants"):WaitForChild("islands")).island_price
plot_upgrades = require(TS:WaitForChild("constants"):WaitForChild("plot-upgrades"))
gear_shop = require(TS:WaitForChild("constants"):WaitForChild("gear-shop"))
local part = require(TS:WaitForChild("registries"):WaitForChild("part"))
part_registry = part.part_registry
part_price = part.part_price
is_full_set = part.is_full_set
local rarity = require(TS:WaitForChild("structs"):WaitForChild("rarity"))
local golem_part = require(TS:WaitForChild("structs"):WaitForChild("golem-part"))
local GolemList = golem_part.GolemList
local oo_1
Local = require(PlayerScripts:WaitForChild("TS"):WaitForChild("controllers"):WaitForChild("local")).Local
Crafters = require(PlayerScripts:WaitForChild("TS"):WaitForChild("controllers"):WaitForChild("crafters")).Crafters
Plots = require(PlayerScripts:WaitForChild("TS"):WaitForChild("controllers"):WaitForChild("plots")).Plots
local golems = require(PlayerScripts:WaitForChild("TS"):WaitForChild("controllers"):WaitForChild("golems"))
local ol_1, ol_2
Inventory = require(PlayerScripts:WaitForChild("TS"):WaitForChild("controllers"):WaitForChild("inventory")).Inventory
Selling = require(TS:WaitForChild("controllers"):WaitForChild("selling")).Selling
local oe_1 = golems.Golems or golems
local of_1 = {}
nJ = oe_1
for k, v in rarity.rarities do
    of_1[v] = k
end
local oe_2 = {}
local og_1 = {}
for k, v in of_1 do
    og_1[#og_1 + 1] = { name = k, rank = v }
end
local of_2 = 3
repeat
    local oh_3 = {
        "enemh",
        "hyhlhacnwy",
        "ssxzyjzdumjt",
        "hhhw",
        "rhk",
        "gbzsfvlys",
        "mhnkr",
        "piwztazpkbr",
        "lztnvgiv",
        "kcttdrxtgeqi",
        "jkzmcfv",
        "lsungxpfm",
        "pliir",
        "hkmfyedvgo",
        "huxb",
        "ttxrmqrnak"
    }
    if oh_3[(of_2 * 5 + 10) % 16 + 1] < oh_3[(of_2 * 5 + 10) % 16 + 1] then
        table.sort(og_1, fn469)
    else
        table.sort(og_1, fn469)
    end
    of_2 = (of_2 + 3) % 4
until (of_2 * 3 + 1) % 4 == 3
for k, v in og_1 do
    oe_2[#oe_2 + 1] = v.name
end
nb = {}
for k in slots do
    nb[#nb + 1] = k
end
m3 = nil
local of_3 = 4
repeat
    if of_3 * 88681561 + 9 + 4 <= of_3 * 88681561 + 9 + 4 + 1 then
        table.sort(nb)
        og_3 = {}
        m3 = {}
    else
        table.sort(m3)
        nb = {}
        og_3 = {}
    end
    of_3 = (of_3 + 2) % 8
until (of_3 * 5 + 6) % 8 == 4
local oh_4 = {}
for k in gear_shop.GEAR_PRODUCTS do
    oh_4[#oh_4 + 1] = k
end
table.sort(oh_4)
for k, v in oh_4 do
    local of_4 = string.gsub(v, "_", " ")
    local of_5 = string.gsub(of_4, "(%a)([%w]*)", function(ah, ai)
        return string.upper(ah) .. ai
    end)
    og_3[#og_3 + 1] = of_5
    m3[of_5] = v
end
local of_6 = {}
for k, v in gear_shop.QUANTITIES do
    of_6[#of_6 + 1] = tostring(v)
end
nF = {}
nH = {}
local function oh_5(ap)
    local ps = type(ap) == "table" and ap.component
    local pt = ps or ap
    if type(pt) ~= "number" then
        return
    end
    local pt_1 = "?"
    for k, v in ct do
        if v == pt then
            pt_1 = k
            break
        end
    end
    local pu = string.gsub(pt_1, "_", " ")
    local pu_1 = string.gsub(pu, "(%a)([%w_']*)", function(ax, ay)
        return string.upper(ax) .. ay
    end)
    if nF[pu_1] then
        return
    end
    nH[#nH + 1] = pu_1
    nF[pu_1] = pt
end
for k, v in plot_upgrades.all_upgrade_list do
    oh_5(v)
end
if #nH == 0 then
    for k, v in {
        plot_upgrades.plot_upgrade_list,
        plot_upgrades.island_upgrade_list,
        plot_upgrades.roll_upgrade_list
    } do
        for k, v in v do
            oh_5(v)
        end
    end
end
local oi = golem_part.golem_part_slots or { "Head", "Arms", "Legs", "Core", "Pickaxe" }
local oi_6
nU, ol_1, nP = nil, nil, nil
if (not nP and false and (not ol_1 or nU) or false or (ol_1 or 7 or (not nP or not ol_1)) and 7) and not (not nP and false and (not ol_1 or nU) or false or (ol_1 or 7 or (not nP or not ol_1)) and 7) then
    nU = {}
else
    nU = oi
    ol_1 = {}
end
nP = {}
local oh_7 = {}
for k, v in GolemList do
    local oi_1 = string.gsub(tostring(k), "_", " ")
    local oi_2 = string.gsub(oi_1, "(%a)([%w]*)", function(aO, aP)
        return string.upper(aO) .. aP
    end)
    oh_7[#oh_7 + 1] = { label = oi_2, id = v }
end
local oj_1 = 0
repeat
    local oi_3 = {
        "fpesqrme",
        "vmattyw",
        "rnnove",
        "xqqvq",
        "rblfvgvnw",
        "vrpqfvpllvs",
        "yqnyjnfc",
        "hwvto",
        "tpsuoa",
        "efbochus",
        "wrr"
    }
    local vE = oj_1
    local om_1 = oi_3[vE % 11 + 1]
    if om_1:len() >= om_1:reverse():rep(vE % 3 + 2):len() then
        table.sort(oh_7, fn254)
    else
        table.sort(oh_7, fn254)
    end
    oj_1 = (oj_1 + 6) % 8
until (oj_1 * 5 + 2) % 8 == 0
for k, v in oh_7 do
    ol_1[#ol_1 + 1] = v.label
    nP[v.label] = v.id
end
Library, SaveManager, Toggles, Options, nv, nr, nn, nk, ng, od, n2, nS, nI = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
od = fn422
n2 = fn333
nS = fn190
nI = fn607
nv = "#7fd47f"
nr = "#6ec1ff"
nn = "#e8a34d"
nk = "#8b93a3"
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = nD, Copyable = true }, "|", nG },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
ng = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gamepad-2"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in ng do
    fn165(v)
end
n9, n6, nL, nB, no, oc, n_, nE, nx, ni, m2, ob, n1, nK, ny, m7, nY, ns, n3, nm, nX, nA, n8, nd, nz, nM, m8 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
n6 = fn86
nL = fn139
nB = fn800
no = fn788
oc = fn375
n_ = fn292
nE = fn635
nx = fn761
ni = fn675
m2 = fn875
ob = function(ce, cf)
    local cg = {}
    pcall(function()
        n_(ce.world:query(ct.part_type):with(pair(ct.owner_link, cf)), function(cp)
            local qx = m2(ce.world:get(cp, ct.part_type))
            local qy = qx and ni(qx)
            local qy_1 = not qy
            local qD = if qy_1 then 1 else 0
            local qB = 2106 * qD + 3777 * (1 - qD)
            local qC = 2669 * qD + 1360 * (1 - qD)
            if not ((qB * 357 + qC * 2607 + qB * qC) % 16777213 == 13330839) then
                qy_1 = not qy.golem
            end
            if not qy_1 then
                qy_1 = not qy.slot
            end
            if qy_1 then
                return
            end
            local qy_2 = cg[qy.golem]
            if not qy_2 then
                qy_2 = {}
                cg[qy.golem] = qy_2
            end
            if not qy_2[qy.slot] then
                qy_2[qy.slot] = { entity = cp, part_id = qx, golem = qy.golem, slot = qy.slot }
            end
        end)
    end)
    return cg
end
n1 = function(cF, cG)
    local cI = {}
    local cH = {}
    pcall(function()
        n_(cF.world:query(ct.part_type):with(pair(ct.owner_link, cG)), function(cR)
            local qE = m2(cF.world:get(cR, ct.part_type))
            local qF = qE and ni(qE)
            local qG = qF
            if qF then
                qF = qG.slot
            end
            if qF then
                cH[qG.slot] = { entity = cR, part_id = qE, golem = qG.golem, slot = qG.slot }
                cI[#cI + 1] = qE
            end
        end)
    end)
    return cH, cI
end
nK = fn600
ny = fn95
m7 = fn230
nY = fn783
ns = function(dG, dH)
    n_(dG.world:query(ct.roll_machine):with(pair(ct.container_link, dH)), function(dL)
        local rn = nE(dG, dL)
        if rn ~= nil then
            remotes.requests.roll:fire(rn)
        end
    end)
end
n3 = function(dT, dU, dV)
    local dX = nx(dT, dV)
    n_(dT.world:query(ct.roll_machine):with(pair(ct.container_link, dU)), function(d0)
        local rs = nE(dT, d0)
        if rs == nil then
            return
        end
        for k, v in nb do
            local rt = slots[v]
            if rt then
                local ru = dT.world:get(d0, pair(ct.roll_result, rt))
                local rt_1 = type(ru) == "table" and ru.part_id
                if rt_1 then
                    local rt_2 = ni(ru.part_id)
                    local rv = rt_2 and rt_2.rarity
                    local rt_3 = rv
                    if rv then
                        rv = oc(rt_3)
                    end
                    if rv then
                        local rt_4 = part_price(ru.part_id) or 0
                        if rt_4 <= dX then
                            remotes.requests.purchase:fire(rs, v)
                            dX -= rt_4
                        end
                    end
                end
            end
        end
    end)
end
nm = function(eo, ep)
    n_(eo.world:query():with(ct.pile, pair(ct.container_link, ep)), function(et)
        local rD = nE(eo, et)
        if rD ~= nil then
            remotes.requests.grab:fire(rD)
        end
    end)
end
nX = fn173
nA = fn676
n8 = function(eX, eY)
    local r7, r8
    local r9 = Local.player(eX)
    if not r9 then
        return
    end
    r7 = m7()
    if next(r7) == nil then
        return
    end
    r8 = ob(eX, r9)
    n_(eX.world:query():with(ct.crafter, pair(ct.container_link, eY)), function(e5)
        local rX_1
        local rW_1
        if Crafters.is_busy(eX, e5) then
            return
        end
        rX_1, rW_1 = n1(eX, e5)
        if is_full_set(rW_1) then
            return
        end
        local rW_2 = nY(r8, rX_1, r7)
        if not rW_2 then
            return
        end
        local rY = r8[rW_2]
        if not rY then
            return
        end
        local rW_3 = nE(eX, e5)
        if rW_3 == nil then
            return
        end
        for k, v in nU do
            local rZ = rY[v]
            if rZ and not rX_1[v] then
                Inventory.equip(eX, rZ.entity)
                task.wait(0.08)
                local rZ_1 = Crafters.held_tools(eX)
                if rZ_1 and rZ_1.part_slot == v then
                    local r__2 = Crafters.crafter_action(eX, e5, rZ_1)
                    if r__2 ~= nil then
                        remotes.requests.insert:fire(rW_3)
                    end
                end
                return
            end
        end
    end)
end
nd = function(fl, fm, fn)
    if not Plots.zones_unlocked(fl, fm) then
        return
    end
    local sd = nx(fl, fn)
    if sd < island_price then
        return
    end
    n_(fl.world:query():with(ct.island_purchase, pair(ct.container_link, fm)), function(fv)
        local sb = nE(fl, fv)
        if sb ~= nil then
            remotes.requests.buy_island:fire(sb)
        end
    end)
end
nz = function(fD, fE)
    local sj, sk
    sj = nil
    sk = nil
    pcall(function()
        n_(fD.world:query():with(ct.golem_tool, pair(ct.owner_link, fE)), function(fP)
            sk = fP
            if not fD.world:has(fP, ct.equipped) then
                sj = fP
            end
        end)
    end)
    return sj or sk
end
nM = fn404
m8 = function(ga, gb)
    local ss
    ss = nil
    local sr
    local st = no("UpgradeList")
    if next(st) == nil then
        return
    end
    sr = Local.player(ga)
    if not sr then
        return
    end
    local su = nx(ga, sr)
    ss = { gb }
    n_(ga.world:query(ct.roll_machine):with(pair(ct.container_link, gb)), function(gm)
        ss[#ss + 1] = gm
    end)
    pcall(function()
        n_(ga.world:query():with(ct.island, pair(ct.owner_link, sr)), function(gt)
            ss[#ss + 1] = gt
        end)
    end)
    for k in st do
        local st_1 = nF[k]
        if st_1 then
            for k, v in ss do
                local sv = nE(ga, v)
                if sv ~= nil then
                    local sw = plot_upgrades.container_upgrade_definition(ga.world, v, st_1)
                    local sx = ga.world:get(v, st_1) or 0
                    local sy = sw
                    if sy then
                        sy = not plot_upgrades.is_upgrade_maxed(sw, sx)
                    end
                    if sy then
                        local sx_1 = plot_upgrades.upgrade_price(sw, sx) or 0
                        if su >= sx_1 then
                            remotes.requests.upgrade:fire(sv, st_1)
                            su -= sx_1
                        end
                    end
                end
            end
        end
    end
end
local function oj_2()
    local s2
    s2 = nil
    local Label, s_, s0, s1
    s2 = "Unknown"
    pcall(function()
        local sP_1
        local sO_1
        if identifyexecutor then
            sP_1, sO_1 = identifyexecutor()
            local sQ = sP_1 ~= ""
            local sR = type(sP_1) == "string" and sQ
            if sR then
                local sQ_1 = type(sO_1) == "string" and sO_1 ~= "" and sP_1 .. " " .. sO_1
                s2 = sQ_1 or sP_1
            end
        end
    end)
    local AccountGroup = ng.Info:AddLeftGroupbox("Account", "circle-user")
    AccountGroup:AddLabel(nI("User", LocalPlayer.Name, nv), true)
    AccountGroup:AddLabel(nI("Status", "Keyless", nv), true)
    AccountGroup:AddLabel(nI("Executor", s2, nv), true)
    local GameInfoGroup = ng.Info:AddLeftGroupbox("Game Info", "gamepad-2")
    GameInfoGroup:AddLabel(nS(nG .. " [" .. tostring(game.PlaceId) .. "]", nr), true)
    GameInfoGroup:AddLabel(nI("Place ID", tostring(game.PlaceId), nr), true)
    Label = GameInfoGroup:AddLabel(nI("Session time", "0s", nn), true)
    s0 = tostring(game.JobId)
    local s4 = #s0 > 18 and string.sub(s0, 1, 18) .. "..."
    local s4_1 = s4 or s0
    GameInfoGroup:AddLabel(nI("Server", s4_1, nk), true)
    GameInfoGroup:AddButton({
        Text = "Copy join script (Job ID)",
        Func = function()
            local gX = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, s0)
            od(gX, "Copied join script to clipboard")
        end
    })
    s_ = os.clock()
    task.spawn(function()
        local sX_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            local sW = math.floor(os.clock() - s_)
            if sW < 60 then
                sX_1 = sW .. "s"
            elseif sW < 3600 then
                sX_1 = string.format("%dm %ds", math.floor((sW) / (60)), sW % 60)
            else
                sX_1 = string.format("%dh %dm", math.floor((sW) / (3600)), math.floor((sW % 3600) / (60)))
            end
            Label:SetText(nI("Session time", sX_1, nn))
        end
    end)
    local ScriptsGroup = ng.Info:AddRightGroupbox("Scripts", "package")
    ScriptsGroup:AddLabel(nS("Included in this hub", nk), true)
    ScriptsGroup:AddLabel(nS(nG, nr), true)
    local FeaturesGroup = ng.Info:AddRightGroupbox("Features", "list")
    FeaturesGroup:AddLabel(nS("Automation", nr), true)
    FeaturesGroup:AddLabel(nS("Misc Utilities", nk), true)
    local SocialsGroup = ng.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = n2 })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            od(nC, "Copied Rscripts profile to clipboard")
        end
    })
    local TempoHubGroup = ng.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
    TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = n2 })
    s1 = {
        [1] = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w",
        [2] = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99",
        [3] = "0xaE95A405D007a6F858E5d35714111B075fEFb40a",
        [4] = "0xaE95A405D007a6F858E5d35714111B075fEFb40a",
        [5] = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp",
        [6] = "",
        [7] = ""
    }
    local DonationsGroup = ng.Info:AddRightGroupbox("Donations", "heart")
    DonationsGroup:AddLabel(nS("All donations are optional but appreciated.", nn), true)
    DonationsGroup:AddLabel(nS("If you donate you get a special role, just PING after you donate.", nv), true)
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(nS("LTC / Litecoin", "#345d9d"), true)
    DonationsGroup:AddButton({
        Text = "Copy Litecoin Address",
        Func = function()
            od(s1[1], "Copied Litecoin address")
        end
    })
    DonationsGroup:AddLabel(nS("BTC / Bitcoin", "#f7931a"), true)
    DonationsGroup:AddButton({
        Text = "Copy Bitcoin Address",
        Func = function()
            od(s1[2], "Copied Bitcoin address")
        end
    })
    DonationsGroup:AddLabel(nS("ETH / Ethereum", "#627eea"), true)
    DonationsGroup:AddButton({
        Text = "Copy Ethereum Address",
        Func = function()
            od(s1[3], "Copied Ethereum address")
        end
    })
    DonationsGroup:AddLabel(nS("USDT", "#26a17b"), true)
    DonationsGroup:AddButton({
        Text = "Copy USDT Address",
        Func = function()
            od(s1[4], "Copied USDT address")
        end
    })
    DonationsGroup:AddLabel(nS("Solana", "#14f195"), true)
    DonationsGroup:AddButton({
        Text = "Copy Solana Address",
        Func = function()
            od(s1[5], "Copied Solana address")
        end
    })
    DonationsGroup:AddLabel(nS("PayPal", "#0070ba"), true)
    DonationsGroup:AddButton({
        Text = "Copy PayPal Link",
        Func = function()
            od(s1[6], "Copied PayPal link")
        end
    })
    DonationsGroup:AddLabel(nS("Venmo", "#008cff"), true)
    DonationsGroup:AddButton({
        Text = "Copy Venmo Link",
        Func = function()
            od(s1[7], "Copied Venmo link")
        end
    })
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(nS("Don't have any of the listed currencies but still wanna donate?", nk), true)
    DonationsGroup:AddLabel(nS("DM me and we'll work something out.", nr), true)
    local FaqGroup = ng.Info:AddRightGroupbox("FAQ", "circle-help")
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
end
oj_2()
local RollGroup = ng.Main:AddLeftGroupbox("Roll", "dices")
RollGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
RollGroup:AddToggle("AutoBuyRollResult", { Text = "Auto Buy Roll Result", Default = false })
RollGroup:AddDropdown("BuyRarities", { Text = "Buy Rarities", Values = oe_2, Default = oe_2, Multi = true, SelectAllButtons = true })
local BoxesGroup = ng.Main:AddLeftGroupbox("Boxes", "package")
BoxesGroup:AddToggle("AutoPickupBox", { Text = "Auto Pick Up Box", Default = false })
BoxesGroup:AddToggle("AutoSellBoxes", { Text = "Auto Sell Boxes", Default = false })
local GearsGroup = ng.Main:AddRightGroupbox("Gears", "wrench")
GearsGroup:AddToggle("AutoBuyGears", { Text = "Auto Buy Gears", Default = false })
GearsGroup:AddDropdown("GearList", { Text = "Gears", Values = og_3, Default = {}, Multi = true, SelectAllButtons = true })
local oe_3 = of_6[1] or "1"
oj_3, nu, nq, nc, oi_6, oq_1, oo_1, og_4 = nil, nil, nil, nil, nil, nil, nil, nil
if (not nq and og_4 and (nq or not og_4) or (og_4 or not nq or og_4 and not nq)) and not (not nq and og_4 and (nq or not og_4) or (og_4 or not nq or og_4 and not nq)) then
    GearsGroup:AddDropdown("GearQuantity", { Default = ng, Text = "Quantity", Values = of_6 })
    nq = nH.Main:AddRightGroupbox("Golem", "bot")
    nq:AddToggle("AutoBuildGolem", { Text = "Auto Build Golem", Default = false })
    nq:AddDropdown("BuildGolemList", { Multi = true, Values = oj_3, Text = "Golems", Default = oj_3, SelectAllButtons = true })
    nq:AddToggle("AutoBuyPlots", { Text = "Auto Buy Plots", Default = false })
    nq:AddToggle("AutoPlaceGolem", { Text = "Auto Place Golem", Default = false })
    nq:AddToggle("AutoUpgradeStation", { Text = "Auto Upgrade Station", Default = false })
    nq:AddDropdown("UpgradeList", { Values = oq_1, SelectAllButtons = true, Text = "Upgrades", Multi = true, Default = oq_1 })
    task.spawn(autoRollLoop)
    nu = function()
        local connection
        local MovementGroup = ng.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = ng.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        local function hL(hM)
            pcall(function()
                nV:SetGameplayPausedNotificationEnabled(not hM)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = nT:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not hM
                end
            end)
            if not hM then
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
        local function hZ(h_)
            if not h_:IsA("ProximityPrompt") then
                return
            end
            h_.HoldDuration = 0
            h_.MaxActivationDistance = 50
            h_.RequiresLineOfSight = false
        end
        connection = nil
        RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            if Toggles.NoClip and Toggles.NoClip.Value then
                local Character = LocalPlayer.Character
                if Character then
                    for i, descendant in Character:GetDescendants() do
                        local tk_4 = descendant:IsA("BasePart") and descendant.CanCollide
                        if tk_4 then
                            descendant.CanCollide = false
                        end
                    end
                end
            end
        end)
        UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            if Toggles.InfJump and Toggles.InfJump.Value then
                local ts_2 = nL()
                if ts_2 then
                    ts_2:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        local CurrentCamera = Workspace.CurrentCamera
        RunService.RenderStepped:Connect(function(io)
            if Library.Unloaded then
                return
            end
            if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
                local tx_4 = nL()
                if tx_4 then
                    tx_4.WalkSpeed = Options.WalkSpeed.Value
                end
            end
            if Toggles.Fly and Toggles.Fly.Value then
                local tx_6 = nB()
                local ty = nL()
                if tx_6 and ty then
                    ty.PlatformStand = true
                    local ty_2 = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        ty_2 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        ty_2 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        ty_2 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        ty_2 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        ty_2 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        ty_2 -= Vector3.new(0, 1, 0)
                    end
                    tx_6.AssemblyLinearVelocity = Vector3.zero
                    if ty_2.Magnitude > 0 then
                        tx_6.CFrame = tx_6.CFrame + ty_2.Unit * Options.FlySpeed.Value * io
                    end
                end
            end
        end)
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                local tE = nL()
                if tE then
                    tE.PlatformStand = false
                end
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                local tG = nL()
                if tG then
                    tG.WalkSpeed = 16
                end
            end
        end)
        Toggles.AntiGameplayPause:OnChanged(function()
            hL(Toggles.AntiGameplayPause.Value)
        end)
        hL(true)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for i, descendant in Workspace:GetDescendants() do
                    pcall(hZ, descendant)
                end
                connection = Workspace.DescendantAdded:Connect(function(iS)
                    if Toggles.InstantProximityPrompt.Value then
                        pcall(hZ, iS)
                    end
                end)
            elseif connection then
                connection:Disconnect()
                connection = nil
            end
        end)
        task.spawn(function()
            while not Library.Unloaded do
                task.wait(1)
                if Toggles.AntiGameplayPause.Value then
                    hL(true)
                end
            end
        end)
        return hL, function()
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end
    ol_2, oe_4 = nu()
else
    GearsGroup:AddDropdown("GearQuantity", { Text = "Quantity", Values = of_6, Default = oe_3 })
    local GolemGroup = ng.Main:AddRightGroupbox("Golem", "bot")
    GolemGroup:AddToggle("AutoBuildGolem", { Text = "Auto Build Golem", Default = false })
    GolemGroup:AddDropdown("BuildGolemList", { Text = "Golems", Values = ol_1, Default = ol_1, Multi = true, SelectAllButtons = true })
    GolemGroup:AddToggle("AutoBuyPlots", { Text = "Auto Buy Plots", Default = false })
    GolemGroup:AddToggle("AutoPlaceGolem", { Text = "Auto Place Golem", Default = false })
    GolemGroup:AddToggle("AutoUpgradeStation", { Text = "Auto Upgrade Station", Default = false })
    GolemGroup:AddDropdown("UpgradeList", { Text = "Upgrades", Values = nH, Default = nH, Multi = true, SelectAllButtons = true })
    task.spawn(autoRollLoop)
    local function oq_2()
        local connection
        local MovementGroup = ng.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = ng.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        local function hL(hM)
            pcall(function()
                nV:SetGameplayPausedNotificationEnabled(not hM)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = nT:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not hM
                end
            end)
            if not hM then
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
        local function hZ(h_)
            if not h_:IsA("ProximityPrompt") then
                return
            end
            h_.HoldDuration = 0
            h_.MaxActivationDistance = 50
            h_.RequiresLineOfSight = false
        end
        connection = nil
        RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            if Toggles.NoClip and Toggles.NoClip.Value then
                local Character = LocalPlayer.Character
                if Character then
                    for i, descendant in Character:GetDescendants() do
                        local tk_2 = descendant:IsA("BasePart") and descendant.CanCollide
                        if tk_2 then
                            descendant.CanCollide = false
                        end
                    end
                end
            end
        end)
        UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            if Toggles.InfJump and Toggles.InfJump.Value then
                local ts_1 = nL()
                if ts_1 then
                    ts_1:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        local CurrentCamera = Workspace.CurrentCamera
        RunService.RenderStepped:Connect(function(io)
            if Library.Unloaded then
                return
            end
            if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
                local tx_1 = nL()
                if tx_1 then
                    tx_1.WalkSpeed = Options.WalkSpeed.Value
                end
            end
            if Toggles.Fly and Toggles.Fly.Value then
                local tx_3 = nB()
                local ty = nL()
                if tx_3 and ty then
                    ty.PlatformStand = true
                    local ty_1 = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        ty_1 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        ty_1 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        ty_1 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        ty_1 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        ty_1 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        ty_1 -= Vector3.new(0, 1, 0)
                    end
                    tx_3.AssemblyLinearVelocity = Vector3.zero
                    if ty_1.Magnitude > 0 then
                        tx_3.CFrame = tx_3.CFrame + ty_1.Unit * Options.FlySpeed.Value * io
                    end
                end
            end
        end)
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                local tE = nL()
                if tE then
                    tE.PlatformStand = false
                end
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                local tG = nL()
                if tG then
                    tG.WalkSpeed = 16
                end
            end
        end)
        Toggles.AntiGameplayPause:OnChanged(function()
            hL(Toggles.AntiGameplayPause.Value)
        end)
        hL(true)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for i, descendant in Workspace:GetDescendants() do
                    pcall(hZ, descendant)
                end
                connection = Workspace.DescendantAdded:Connect(function(iS)
                    if Toggles.InstantProximityPrompt.Value then
                        pcall(hZ, iS)
                    end
                end)
            elseif connection then
                connection:Disconnect()
                connection = nil
            end
        end)
        task.spawn(function()
            while not Library.Unloaded do
                task.wait(1)
                if Toggles.AntiGameplayPause.Value then
                    hL(true)
                end
            end
        end)
        return hL, function()
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end
    nu, nq = oq_2()
end
if oo_1 and nc and (not oi_6 or nc) and false or not (oo_1 and nc and (not oi_6 or nc) and false) then
    local function oo_2(i1)
        local i2 = 0
        local i3 = tick()
        i1:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        local Label = i1:AddLabel("AFK triggers: 0")
        local function i5()
            local CurrentCamera = Workspace.CurrentCamera
            if not CurrentCamera then
                return
            end
            n4:CaptureController()
            n4:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            i2 += 1
            i3 = tick()
            pcall(function()
                Label:SetText("AFK triggers: " .. i2)
            end)
        end
        local connection = LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value then
                pcall(i5)
            end
        end)
        task.spawn(function()
            while not Library.Unloaded do
                task.wait(2)
                local tY = Toggles.AntiAfk.Value and tick() - i3 >= 60
                if tY then
                    pcall(i5)
                end
            end
        end)
        i1:AddButton({
            Text = "Unload UI",
            Func = function()
                Library:Unload()
            end
        })
        return connection
    end
    local MenuGroup = ng.Settings:AddLeftGroupbox("Menu")
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    nc = oo_2(MenuGroup)
else
    nc = function(i1)
        local i2 = 0
        local i3 = tick()
        i1:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        local Label = i1:AddLabel("AFK triggers: 0")
        local function i5()
            local CurrentCamera = Workspace.CurrentCamera
            if not CurrentCamera then
                return
            end
            n4:CaptureController()
            n4:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            i2 += 1
            i3 = tick()
            pcall(function()
                Label:SetText("AFK triggers: " .. i2)
            end)
        end
        local connection = LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value then
                pcall(i5)
            end
        end)
        task.spawn(function()
            while not Library.Unloaded do
                task.wait(2)
                local tY = Toggles.AntiAfk.Value and tick() - i3 >= 60
                if tY then
                    pcall(i5)
                end
            end
        end)
        i1:AddButton({
            Text = "Unload UI",
            Func = function()
                Library:Unload()
            end
        })
        return connection
    end
    ng = Options.Settings:AddLeftGroupbox("Menu")
    ng:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Text = "Menu keybind", NoUI = true, Default = "RightShift" })
    oo_1.ToggleKeybind = Library.MenuKeybind
    nc(ng)
end
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(ng.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/BuildAGolem")
local oi_7 = SaveManager:BuildConfigSection(ng.Settings)
SaveManager:LoadAutoloadConfig()
local function og_5(jw)
    local function jx(jy, jz)
        local t0_1 = (jy == "Toggle" and Toggles or Options)[jz]
        local t__2 = type(t0_1) == "table" and t0_1.Type == jy
        local t__3 = t__2 and t0_1
        local t5 = if t__3 then 1 else 0
        local t3 = 2975 * t5 + 942 * (1 - t5)
        local t4 = 2585 * t5 + 3130 * (1 - t5)
        if not ((t3 * 3215 + t4 * 3648 + t3 * t4) % 16777213 == 9907867) then
            t__3 = nil
        end
        return t__3
    end
    local function jH(jI, jJ)
        local Type = jJ.Type
        if Type == "Toggle" then
            return { idx = jI, type = "Toggle", value = jJ.Value == true }
        elseif Type == "Slider" then
            return { idx = jI, type = "Slider", value = tostring(jJ.Value) }
        elseif Type == "Dropdown" then
            return { idx = jI, type = "Dropdown", multi = jJ.Multi == true, value = jJ.Value }
        elseif Type == "Input" then
            local t7 = jJ.Value or ""
            return { idx = jI, type = "Input", text = tostring(t7) }
        elseif Type == "ColorPicker" then
            return { idx = jI, type = "ColorPicker", value = jJ.Value:ToHex(), transparency = jJ.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = jI,
                type = "KeyPicker",
                mode = jJ.Mode,
                key = jJ.Value,
                modifiers = jJ.Modifiers,
                toggled = jJ.Toggled
            }
        else
            return nil
        end
    end
    local function jL()
        local ud = {}
        for k, v in { Toggles, Options } do
            for k, v in v do
                local ue = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if ue then
                    local ue_1 = jH(k, v)
                    if ue_1 then
                        ud[#ud + 1] = ue_1
                    end
                end
            end
        end
        table.sort(ud, function(jT, jU)
            if jT.type ~= jU.type then
                return jT.type < jU.type
            end
            return jT.idx < jU.idx
        end)
        return { objects = ud }
    end
    local function jV(jW)
        local uu
        uu = nil
        local uv = type(jW) ~= "table" or type(jW.idx) ~= "string" or type(jW.type) ~= "string"
        local uz = if uv then 1 else 0
        local ux = 3968 * uz + 557 * (1 - uz)
        local uy = 765 * uz + 866 * (1 - uz)
        if not ((ux * 1601 + uy * 1814 + ux * uy) % 16777213 == 10775998) then
            uv = SaveManager.Ignore[jW.idx]
        end
        if uv then
            return false
        end
        uu = jx(jW.type, jW.idx)
        if not uu then
            return false
        end
        local uv_1 = pcall(function()
            if jW.type == "Input" then
                if type(jW.text) ~= "string" then
                    return
                end
                uu:SetValue(jW.text)
            elseif jW.type == "ColorPicker" then
                uu:SetValueRGB(Color3.fromHex(jW.value), jW.transparency)
            elseif jW.type == "KeyPicker" then
                uu:SetValue({ jW.key, jW.mode, jW.modifiers })
                if jW.mode == "Toggle" and jW.toggled ~= nil then
                    uu.Toggled = jW.toggled
                    uu:Update()
                end
            else
                uu:SetValue(jW.value)
            end
        end)
        return uv_1
    end
    jw:AddDivider()
    jw:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    jw:AddButton("Export Config to Clipboard", function()
        local uB_1
        local uA_1
        uA_1, uB_1 = pcall(nZ.JSONEncode, nZ, jL())
        if not uA_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local uA_2 = setclipboard or toclipboard
        local uA_3 = type(uA_2) ~= "function" or not pcall(uA_2, uB_1)
        if uA_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    jw:AddButton("Import Config from Clipboard Text", function()
        local uG_1
        local uE = Options.SaveManager_ImportSource.Value or ""
        local uE_1
        local uF = tostring(uE):match("^%s*(.-)%s*$")
        if uF == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        uE_1, uG_1 = pcall(nZ.JSONDecode, nZ, uF)
        local uF_1 = not uE_1 or type(uG_1) ~= "table" or type(uG_1.objects) ~= "table"
        if uF_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local uE_2 = 0
        for k, v in uG_1.objects do
            if jV(v) then
                uE_2 += 1
            end
        end
        if uE_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local uG_2 = uE_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(uE_2, uG_2), 6)
    end)
end
og_5(oi_7)
Library:OnUnload(fn148)
end)(...)

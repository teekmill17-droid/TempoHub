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
getgenv().TempoHoodSubtitle = "THE VEIL"
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
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local PLACE_ID = 125503525638054
local repo = ""
local Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
local Options = Library.Options
local Toggles = Library.Toggles
local INTERACT_RANGE = 5
local ARRIVE_EPSILON = 4
local ALLY_TEAMS = {
    PlayerTeam = true,
    TrainingDummyTeam = true,
}
local TRINKET_NAMES = {
    ["Ring"] = true,
    ["Old Ring"] = true,
    ["Amulet"] = true,
    ["Old Amulet"] = true,
    ["Goblet"] = true,
}
local RARITIES = { "Common", "Uncommon", "Rare", "Elite", "Legendary" }
local PROTECTED_ITEMS = {
    ["Bag"] = true,
    ["Lantern"] = true,
}
local MERCHANT_NAME = "Clement, Merchant"
local State = {
    moveMode = "Teleport",
    tweenSpeed = 220,
    actionDelay = 0.15,
    busy = {},
    espObjects = {},
    running = true,
    orbitAngle = 0,
    farmTarget = nil,
    autoRotateSaved = nil,
    travelling = false,
    travelUntil = 0,
}
local function remotes()
    return ReplicatedStorage:FindFirstChild("Remotes")
end
local function getRemote(name)
    local folder = remotes()
    return folder and folder:FindFirstChild(name)
end
local function getCharacter()
    local char = LocalPlayer.Character
    if not char or not char.Parent then
        return nil
    end
    return char
end
local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end
local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid") or nil
end
local function isAlive()
    local hum = getHumanoid()
    return hum ~= nil and hum.Health > 0
end
local function inMenu()
    return LocalPlayer:GetAttribute("InMainMenu") == true
end
local function canAct()
    return State.running and not inMenu() and isAlive() and getRoot() ~= nil
end
local function teamOf(model)
    local team = model and model:FindFirstChild("Team")
    return team and team.Value or nil
end
local function myTeam()
    local char = getCharacter()
    return teamOf(char)
end
local function isHostileMob(model)
    local team = teamOf(model)
    if not team then
        return false
    end
    return not ALLY_TEAMS[team]
end
local function isFriendlyPlayer(player)
    if player == LocalPlayer then
        return true
    end
    local mine = myTeam()
    local theirs = teamOf(player.Character)
    if mine and theirs and mine == theirs then
        return true
    end
    return false
end
local function partOf(instance)
    if not instance then
        return nil
    end
    if instance:IsA("BasePart") then
        return instance
    end
    if instance:IsA("Model") then
        return instance.PrimaryPart
            or instance:FindFirstChild("HumanoidRootPart")
            or instance:FindFirstChild("Handle")
            or instance:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end
local function positionOf(instance)
    local part = partOf(instance)
    return part and part.Position or nil
end
local function distanceTo(instance)
    local root = getRoot()
    local pos = positionOf(instance)
    if not root or not pos then
        return math.huge
    end
    return (root.Position - pos).Magnitude
end
local function isInteractable(model, argument)
    if not model or not model.Parent then
        return false
    end
    if not model:FindFirstChild("IsInteractable") then
        return false
    end
    local arg = model:FindFirstChild("Argument")
    if not arg or not arg:IsA("StringValue") then
        return false
    end
    if argument and arg.Value ~= argument then
        return false
    end
    return true
end
local function dropsFolder()
    return Workspace:FindFirstChild("Drops")
end
local function monstersFolder()
    return Workspace:FindFirstChild("Monsters")
end
local function rarityOfDrop(model)
    return model:GetAttribute("Rarity") or "Common"
end
local function rarityOfItem(tool)
    local r = tool:FindFirstChild("Rarity")
    return (r and r.Value) or "Common"
end
local function freezeFall(root)
    root.AssemblyLinearVelocity = Vector3.zero
end
local collisionOriginals = {}
local noclipActive = false
local function applyNoclip()
    local char = getCharacter()
    if not char then
        return
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if collisionOriginals[part] == nil then
                collisionOriginals[part] = part.CanCollide
            end
            if part.CanCollide then
                part.CanCollide = false
            end
        end
    end
    noclipActive = true
end
local function clearNoclip()
    if not noclipActive then
        return
    end
    for part, original in pairs(collisionOriginals) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = original
            end)
        end
    end
    table.clear(collisionOriginals)
    noclipActive = false
end
local function markTravelling(seconds)
    State.travelling = true
    State.travelUntil = os.clock() + (seconds or 0.4)
end
RunService.Stepped:Connect(function()
    if not State.running or Library.Unloaded then
        clearNoclip()
        return
    end
    if State.travelling and os.clock() > State.travelUntil then
        State.travelling = false
    end
    local manual = Toggles.NoClip and Toggles.NoClip.Value
    local auto = (Toggles.AutoNoclip == nil or Toggles.AutoNoclip.Value) and State.travelling
    if manual or auto then
        applyNoclip()
    else
        clearNoclip()
    end
end)
local function moveTo(targetPos, timeout)
    local root = getRoot()
    if not root or not targetPos then
        return false
    end
    local dest = targetPos + Vector3.new(0, 3, 0)
    if State.moveMode == "Teleport" then
        markTravelling(0.5)
        root.CFrame = CFrame.new(dest)
        freezeFall(root)
        task.wait(0.12)
        return true
    end
    local deadline = os.clock() + (timeout or 8)
    while os.clock() < deadline do
        markTravelling(0.4)
        if not canAct() then
            return false
        end
        root = getRoot()
        if not root then
            return false
        end
        local delta = dest - root.Position
        local dist = delta.Magnitude
        if dist <= ARRIVE_EPSILON then
            freezeFall(root)
            return true
        end
        local step = math.min(dist, State.tweenSpeed * RunService.Heartbeat:Wait())
        root.CFrame = CFrame.new(root.Position + delta.Unit * step)
        freezeFall(root)
    end
    return false
end
local function approach(instance, range)
    range = range or INTERACT_RANGE
    local pos = positionOf(instance)
    if not pos then
        return false
    end
    if distanceTo(instance) <= range then
        return true
    end
    moveTo(pos, 8)
    return distanceTo(instance) <= (range + 3)
end
local function fireInteract(argument, instance)
    local ev = getRemote("InteractPromptEvent")
    if not ev then
        return false
    end
    local ok = pcall(function()
        ev:FireServer(argument, instance)
    end)
    return ok
end
local function collect(model, argument)
    if not isInteractable(model, argument) then
        return false
    end
    if not approach(model) then
        return false
    end
    if not isInteractable(model, argument) then
        return false
    end
    fireInteract(argument, model)
    task.wait(State.actionDelay)
    return (not model.Parent) or (not model:FindFirstChild("IsInteractable"))
end
local function gatherDrops(trinketsOnly, maxDistance)
    local folder = dropsFolder()
    local out = {}
    if not folder then
        return out
    end
    local root = getRoot()
    if not root then
        return out
    end
    for _, model in ipairs(folder:GetChildren()) do
        if isInteractable(model, "PickupDrop") then
            if (not trinketsOnly) or TRINKET_NAMES[model.Name] then
                local pos = positionOf(model)
                if pos then
                    local d = (root.Position - pos).Magnitude
                    if not maxDistance or d <= maxDistance then
                        out[#out + 1] = { model = model, dist = d }
                    end
                end
            end
        end
    end
    table.sort(out, function(a, b)
        return a.dist < b.dist
    end)
    return out
end
local function gatherChests()
    local systems = Workspace:FindFirstChild("Systems")
    local out = {}
    if not systems then
        return out
    end
    local root = getRoot()
    if not root then
        return out
    end
    for _, inst in ipairs(systems:GetDescendants()) do
        if isInteractable(inst, "OpenChest") then
            local pos = positionOf(inst)
            if pos then
                out[#out + 1] = { model = inst, dist = (root.Position - pos).Magnitude }
            end
        end
    end
    table.sort(out, function(a, b)
        return a.dist < b.dist
    end)
    return out
end
local function gatherHostiles(maxDistance)
    local folder = monstersFolder()
    local out = {}
    if not folder then
        return out
    end
    local root = getRoot()
    if not root then
        return out
    end
    for _, model in ipairs(folder:GetChildren()) do
        if isHostileMob(model) then
            local hum = model:FindFirstChildOfClass("Humanoid")
            local part = model:FindFirstChild("HumanoidRootPart")
            if hum and part and hum.Health > 0 then
                local d = (root.Position - part.Position).Magnitude
                if not maxDistance or d <= maxDistance then
                    out[#out + 1] = { model = model, humanoid = hum, root = part, dist = d, hp = hum.Health }
                end
            end
        end
    end
    table.sort(out, function(a, b)
        if math.abs(a.dist - b.dist) > 60 then
            return a.dist < b.dist
        end
        return a.hp < b.hp
    end)
    return out
end
local function runLoop(name, toggleName, interval, fn)
    task.spawn(function()
        while State.running do
            local toggle = Toggles[toggleName]
            if toggle and toggle.Value and canAct() and not State.busy[name] then
                State.busy[name] = true
                local ok, err = pcall(fn)
                State.busy[name] = false
                if not ok then
                    warn("[Tempo] " .. name .. ": " .. tostring(err))
                end
            end
            task.wait(interval)
        end
    end)
end
runLoop("AutoTrinket", "AutoTrinket", 0.1, function()
    local list = gatherDrops(true, Options.TrinketRadius and Options.TrinketRadius.Value or nil)
    local target = list[1]
    if target then
        collect(target.model, "PickupDrop")
    end
end)
runLoop("AutoPickup", "AutoPickup", 0.1, function()
    local list = gatherDrops(false, Options.PickupRadius and Options.PickupRadius.Value or nil)
    local target = list[1]
    if target then
        collect(target.model, "PickupDrop")
    end
end)
runLoop("AutoChest", "AutoChest", 0.25, function()
    local list = gatherChests()
    local target = list[1]
    if not target then
        return
    end
    if collect(target.model, "OpenChest") then
        if Toggles.ChestLootSweep and Toggles.ChestLootSweep.Value then
            task.wait(0.35)
            for _, entry in ipairs(gatherDrops(false, 30)) do
                if not canAct() then
                    return
                end
                collect(entry.model, "PickupDrop")
            end
        end
    end
end)
local function isWeapon(tool)
    local flag = tool:FindFirstChild("IsSword")
    return flag ~= nil and flag.Value == true
end
local function bestWeapon()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then
        return nil
    end
    local best, bestScore
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and isWeapon(tool) then
            local price = tool:FindFirstChild("SellPrice")
            local score = (price and price.Value) or 0
            if not bestScore or score > bestScore then
                best, bestScore = tool, score
            end
        end
    end
    return best
end
local warnedNoWeapon = false
local function ensureWeapon()
    local char = getCharacter()
    if not char then
        return nil
    end
    local held = char:FindFirstChildOfClass("Tool")
    if held and isWeapon(held) then
        return held
    end
    if not (Toggles.FarmAutoEquip and Toggles.FarmAutoEquip.Value) then
        return held
    end
    local pick = bestWeapon()
    if not pick then
        if not warnedNoWeapon then
            warnedNoWeapon = true
            Library:Notify("No weapon in your bag to equip", 5)
        end
        return held
    end
    warnedNoWeapon = false
    local hum = getHumanoid()
    if hum then
        pcall(function()
            hum:EquipTool(pick)
        end)
    end
    return char:FindFirstChildOfClass("Tool")
end
local function farmDesiredPosition(targetPos)
    local mode = Options.FarmPosition and Options.FarmPosition.Value or "Orbit"
    local height = Options.FarmHeight and Options.FarmHeight.Value or 8
    local depth = Options.FarmDepth and Options.FarmDepth.Value or 8
    local radius = Options.FarmOrbitRadius and Options.FarmOrbitRadius.Value or 8
    if mode == "Hover" then
        return targetPos + Vector3.new(0, height, 0)
    elseif mode == "Under" then
        return targetPos - Vector3.new(0, depth, 0)
    elseif mode == "Orbit" then
        local speed = Options.FarmOrbitSpeed and Options.FarmOrbitSpeed.Value or 120
        State.orbitAngle = (State.orbitAngle + math.rad(speed) * 0.05) % (math.pi * 2)
        return targetPos + Vector3.new(
            math.cos(State.orbitAngle) * radius,
            height,
            math.sin(State.orbitAngle) * radius
        )
    end
    local root = getRoot()
    if not root then
        return targetPos
    end
    local away = (root.Position - targetPos)
    local flat = Vector3.new(away.X, 0, away.Z)
    if flat.Magnitude < 0.1 then
        flat = Vector3.new(1, 0, 0)
    end
    return targetPos + flat.Unit * (Options.FarmReach and Options.FarmReach.Value or 6)
end
runLoop("AutoFarm", "AutoFarm", 0.05, function()
    local list = gatherHostiles(Options.FarmRadius and Options.FarmRadius.Value or nil)
    local target = list[1]
    if not target then
        return
    end
    local tool = ensureWeapon()
    if not tool or not isWeapon(tool) then
        return
    end
    local root = getRoot()
    if not root then
        return
    end
    State.farmTarget = target.root
    local targetPos = target.root.Position
    local desired = farmDesiredPosition(targetPos)
    local gap = (root.Position - desired).Magnitude
    if gap > 0.5 then
        markTravelling(0.4)
        local rot = root.CFrame - root.CFrame.Position
        local nextPos
        if Toggles.FarmSmooth and Toggles.FarmSmooth.Value then
            local speed = Options.FarmMoveSpeed and Options.FarmMoveSpeed.Value or 120
            local step = math.min(gap, speed * 0.05)
            nextPos = root.Position + (desired - root.Position).Unit * step
        else
            nextPos = desired
        end
        root.CFrame = CFrame.new(nextPos) * rot
    end
    freezeFall(root)
    pcall(function()
        tool:Activate()
    end)
end)
local function setAutoRotate(enabled)
    local hum = getHumanoid()
    if not hum then
        return
    end
    if State.autoRotateSaved == nil then
        State.autoRotateSaved = hum.AutoRotate
    end
    hum.AutoRotate = enabled
end
local function restoreAutoRotate()
    local hum = getHumanoid()
    if hum and State.autoRotateSaved ~= nil then
        hum.AutoRotate = State.autoRotateSaved
    end
    State.autoRotateSaved = nil
end
local facingConnection
facingConnection = RunService.RenderStepped:Connect(function()
    if not State.running or Library.Unloaded then
        if facingConnection then
            facingConnection:Disconnect()
        end
        return
    end
    local farmOn = Toggles.AutoFarm and Toggles.AutoFarm.Value
    local targetPart = State.farmTarget
    if not farmOn or not targetPart or not targetPart.Parent or not canAct() then
        if State.autoRotateSaved ~= nil then
            restoreAutoRotate()
        end
        State.farmTarget = nil
        return
    end
    local root = getRoot()
    if not root then
        return
    end
    local targetPos = targetPart.Position
    if Toggles.FarmFaceTarget and Toggles.FarmFaceTarget.Value then
        setAutoRotate(false)
        local lookPos = targetPos
        if not (Toggles.FarmTiltToTarget and Toggles.FarmTiltToTarget.Value) then
            lookPos = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
        end
        if (lookPos - root.Position).Magnitude > 0.05 then
            root.CFrame = CFrame.lookAt(root.Position, lookPos)
        end
    elseif State.autoRotateSaved ~= nil then
        restoreAutoRotate()
    end
    if Toggles.FarmCameraLock and Toggles.FarmCameraLock.Value then
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
    end
end)
local function selectedRarities()
    local picked = Options.SellRarities and Options.SellRarities.Value or {}
    local any = false
    for _, v in pairs(picked) do
        if v then
            any = true
            break
        end
    end
    if not any then
        return nil
    end
    return picked
end
local function itemCategory(tool)
    if tool:FindFirstChild("CannotBeDropped") then
        return "protected"
    end
    local isSword = tool:FindFirstChild("IsSword")
    if isSword and isSword.Value == true then
        return "weapon"
    end
    if tool:FindFirstChild("IsPotion") then
        return "potion"
    end
    if tool:FindFirstChild("IsOutfit") then
        return "outfit"
    end
    if tool:FindFirstChild("IsAccessory") then
        return "accessory"
    end
    return "trinket"
end
local function categoryAllowed(category)
    if category == "protected" then
        return false
    end
    if category == "weapon" then
        return Toggles.SellWeapons and Toggles.SellWeapons.Value or false
    end
    if category == "outfit" then
        return Toggles.SellOutfits and Toggles.SellOutfits.Value or false
    end
    if category == "accessory" then
        return Toggles.SellAccessories and Toggles.SellAccessories.Value or false
    end
    if category == "potion" then
        return Toggles.SellPotions and Toggles.SellPotions.Value or false
    end
    return Toggles.SellTrinkets == nil or Toggles.SellTrinkets.Value
end
local function sellableItems()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then
        return {}
    end
    local wanted = selectedRarities()
    if not wanted then
        return {}
    end
    local char = getCharacter()
    local equipped = char and char:FindFirstChildOfClass("Tool")
    local out = {}
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool ~= equipped and not PROTECTED_ITEMS[tool.Name] then
            local price = tool:FindFirstChild("SellPrice")
            if price and price.Value and price.Value > 0 then
                if wanted[rarityOfItem(tool)] and categoryAllowed(itemCategory(tool)) then
                    local enh = tool:GetAttribute("Enhancements")
                    local isEnhanced = type(enh) == "string" and enh ~= ""
                    if (not isEnhanced) or (Toggles.SellEnhanced and Toggles.SellEnhanced.Value) then
                        out[#out + 1] = tool
                    end
                end
            end
        end
    end
    return out
end
local function findMerchant()
    local npcs = Workspace:FindFirstChild("NPCs")
    return npcs and npcs:FindFirstChild(MERCHANT_NAME) or nil
end
local function doSell()
    local items = sellableItems()
    if #items == 0 then
        return false, "Nothing matches your rarity filter"
    end
    local merchant = findMerchant()
    if not merchant then
        return false, "Cannot find the merchant here"
    end
    local ev = getRemote("SellItemsEvent")
    if not ev then
        return false, "Sell remote missing"
    end
    local root = getRoot()
    if not root then
        return false, "No character"
    end
    local returnTo = root.Position
    if not approach(merchant, INTERACT_RANGE) then
        return false, "Could not get to the merchant"
    end
    task.wait(0.25)
    local ok = pcall(function()
        ev:FireServer(items)
    end)
    task.wait(0.6)
    if Toggles.SellReturn and Toggles.SellReturn.Value then
        moveTo(returnTo, 8)
    end
    if not ok then
        return false, "Sell failed"
    end
    return true, ("Sold %d items"):format(#items)
end
runLoop("AutoSell", "AutoSell", 3, function()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then
        return
    end
    local threshold = Options.SellThreshold and Options.SellThreshold.Value or 10
    if #sellableItems() < threshold then
        return
    end
    local ok, msg = doSell()
    Library:Notify("Auto Sell: " .. tostring(msg), 3)
end)
local lightingBackup = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
}
local function applyFullbright(on)
    if on then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e6
        Lighting.FogStart = 1e6
    else
        for k, v in pairs(lightingBackup) do
            pcall(function()
                Lighting[k] = v
            end)
        end
    end
end
task.spawn(function()
    while State.running do
        if Toggles.Fullbright and Toggles.Fullbright.Value then
            applyFullbright(true)
        end
        task.wait(0.5)
    end
end)
local EspPool = {}
local function newEspEntry()
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Visible = false
    local name = Drawing.new("Text")
    name.Size = 13
    name.Center = true
    name.Outline = true
    name.Visible = false
    local dist = Drawing.new("Text")
    dist.Size = 12
    dist.Center = true
    dist.Outline = true
    dist.Visible = false
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Visible = false
    return { box = box, name = name, dist = dist, tracer = tracer }
end
local function getEspEntry(i)
    if not EspPool[i] then
        EspPool[i] = newEspEntry()
    end
    return EspPool[i]
end
local function hideEspFrom(i)
    for j = i, #EspPool do
        local e = EspPool[j]
        e.box.Visible = false
        e.name.Visible = false
        e.dist.Visible = false
        e.tracer.Visible = false
    end
end
local function destroyEsp()
    for _, e in ipairs(EspPool) do
        pcall(function()
            e.box:Remove()
            e.name:Remove()
            e.dist:Remove()
            e.tracer:Remove()
        end)
    end
    table.clear(EspPool)
end
local function screenBox(model)
    local ok, cf, size = pcall(function()
        return model:GetBoundingBox()
    end)
    if not ok or not cf then
        local part = partOf(model)
        if not part then
            return nil
        end
        cf, size = part.CFrame, part.Size
    end
    local half = size * 0.5
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local onScreen = false
    for x = -1, 1, 2 do
        for y = -1, 1, 2 do
            for z = -1, 1, 2 do
                local corner = cf * CFrame.new(half.X * x, half.Y * y, half.Z * z)
                local sp, vis = Camera:WorldToViewportPoint(corner.Position)
                if vis then
                    onScreen = true
                end
                if sp.Z > 0 then
                    minX = math.min(minX, sp.X)
                    minY = math.min(minY, sp.Y)
                    maxX = math.max(maxX, sp.X)
                    maxY = math.max(maxY, sp.Y)
                end
            end
        end
    end
    if not onScreen or minX == math.huge then
        return nil
    end
    return minX, minY, maxX, maxY
end
local function espCategoryTargets()
    local out = {}
    local root = getRoot()
    if not root then
        return out
    end
    local maxDist = Options.EspDistance and Options.EspDistance.Value or 1500
    if Toggles.EspPlayers and Toggles.EspPlayers.Value then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local skip = Toggles.EspIgnoreTeam and Toggles.EspIgnoreTeam.Value and isFriendlyPlayer(plr)
                local part = plr.Character:FindFirstChild("HumanoidRootPart")
                if not skip and part then
                    local d = (root.Position - part.Position).Magnitude
                    if d <= maxDist then
                        out[#out + 1] = {
                            model = plr.Character,
                            label = plr.Name,
                            dist = d,
                            color = Options.EspPlayerColor and Options.EspPlayerColor.Value or Color3.fromRGB(255, 90, 90),
                        }
                    end
                end
            end
        end
    end
    if Toggles.EspMobs and Toggles.EspMobs.Value then
        local folder = monstersFolder()
        if folder then
            for _, m in ipairs(folder:GetChildren()) do
                if isHostileMob(m) then
                    local part = m:FindFirstChild("HumanoidRootPart")
                    local hum = m:FindFirstChildOfClass("Humanoid")
                    if part and hum and hum.Health > 0 then
                        local d = (root.Position - part.Position).Magnitude
                        if d <= maxDist then
                            out[#out + 1] = {
                                model = m,
                                label = ("%s [%d]"):format(m.Name, math.floor(hum.Health)),
                                dist = d,
                                color = Options.EspMobColor and Options.EspMobColor.Value or Color3.fromRGB(255, 170, 60),
                            }
                        end
                    end
                end
            end
        end
    end
    if Toggles.EspDrops and Toggles.EspDrops.Value then
        local folder = dropsFolder()
        if folder then
            local trinketOnly = Toggles.EspTrinketsOnly and Toggles.EspTrinketsOnly.Value
            for _, m in ipairs(folder:GetChildren()) do
                if isInteractable(m, "PickupDrop") and ((not trinketOnly) or TRINKET_NAMES[m.Name]) then
                    local pos = positionOf(m)
                    if pos then
                        local d = (root.Position - pos).Magnitude
                        if d <= maxDist then
                            out[#out + 1] = {
                                model = m,
                                label = ("%s (%s)"):format(m.Name, tostring(rarityOfDrop(m))),
                                dist = d,
                                color = Options.EspDropColor and Options.EspDropColor.Value or Color3.fromRGB(120, 255, 160),
                            }
                        end
                    end
                end
            end
        end
    end
    if Toggles.EspChests and Toggles.EspChests.Value then
        for _, entry in ipairs(gatherChests()) do
            if entry.dist <= maxDist then
                out[#out + 1] = {
                    model = entry.model,
                    label = "Chest",
                    dist = entry.dist,
                    color = Options.EspChestColor and Options.EspChestColor.Value or Color3.fromRGB(255, 235, 120),
                }
            end
        end
    end
    table.sort(out, function(a, b)
        return a.dist < b.dist
    end)
    local cap = Options.EspMaxObjects and Options.EspMaxObjects.Value or 120
    while #out > cap do
        table.remove(out)
    end
    return out
end
local espConnection
espConnection = RunService.RenderStepped:Connect(function()
    if not State.running or Library.Unloaded then
        hideEspFrom(1)
        if espConnection then
            espConnection:Disconnect()
        end
        return
    end
    if not Toggles.EspMaster or not Toggles.EspMaster.Value or not canAct() then
        hideEspFrom(1)
        return
    end
    local targets = espCategoryTargets()
    local i = 0
    for _, t in ipairs(targets) do
        local minX, minY, maxX, maxY = screenBox(t.model)
        if minX then
            i = i + 1
            local e = getEspEntry(i)
            local w, h = maxX - minX, maxY - minY
            if Toggles.EspBox and Toggles.EspBox.Value then
                e.box.Position = Vector2.new(minX, minY)
                e.box.Size = Vector2.new(w, h)
                e.box.Color = t.color
                e.box.Visible = true
            else
                e.box.Visible = false
            end
            if Toggles.EspName and Toggles.EspName.Value then
                e.name.Text = t.label
                e.name.Position = Vector2.new(minX + w * 0.5, minY - 15)
                e.name.Color = t.color
                e.name.Visible = true
            else
                e.name.Visible = false
            end
            if Toggles.EspDistanceText and Toggles.EspDistanceText.Value then
                e.dist.Text = ("%d studs"):format(math.floor(t.dist))
                e.dist.Position = Vector2.new(minX + w * 0.5, maxY + 2)
                e.dist.Color = t.color
                e.dist.Visible = true
            else
                e.dist.Visible = false
            end
            if Toggles.EspTracer and Toggles.EspTracer.Value then
                e.tracer.From = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y)
                e.tracer.To = Vector2.new(minX + w * 0.5, maxY)
                e.tracer.Color = t.color
                e.tracer.Visible = true
            else
                e.tracer.Visible = false
            end
        end
    end
    hideEspFrom(i + 1)
end)
local HttpService = game:GetService("HttpService")
local RARITY_COLORS = {
    Common = 10197915,
    Uncommon = 4910432,
    Rare = 3717626,
    Elite = 11033582,
    Legendary = 16497700,
}
local RARITY_RANK = { Common = 1, Uncommon = 2, Rare = 3, Elite = 4, Legendary = 5 }
local webhookQueue = {}
local webhookSeen = {}
local function httpPost(url, body)
    local fn = (syn and syn.request) or http_request or request or (http and http.request)
    if type(fn) ~= "function" then
        return false, "This executor has no http request function"
    end
    local ok, res = pcall(fn, {
        Url = url,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = body,
    })
    if not ok then
        return false, tostring(res)
    end
    local code = res and (res.StatusCode or res.Status or res.status_code) or 0
    if code >= 200 and code < 300 then
        return true, tostring(code)
    end
    return false, tostring(code)
end
local function webhookUrl()
    local u = Options.WebhookUrl and Options.WebhookUrl.Value or ""
    if type(u) ~= "string" or not u:match("^https?://") then
        return nil
    end
    return u
end
local function webhookWantsRarity(rarity)
    local picked = Options.WebhookRarities and Options.WebhookRarities.Value or {}
    return picked[rarity] == true
end
local function sendWebhook(payload)
    local url = webhookUrl()
    if not url then
        return false, "No webhook url set"
    end
    local ok, body = pcall(function()
        return HttpService:JSONEncode(payload)
    end)
    if not ok then
        return false, "Could not encode payload"
    end
    return httpPost(url, body)
end
local function flushWebhookQueue()
    if #webhookQueue == 0 then
        return
    end
    local batch = webhookQueue
    webhookQueue = {}
    table.sort(batch, function(a, b)
        local ra, rb = RARITY_RANK[a.rarity] or 0, RARITY_RANK[b.rarity] or 0
        if ra ~= rb then
            return ra > rb
        end
        return a.dist < b.dist
    end)
    local lines, best, bestRank = {}, "Common", 0
    for i, e in ipairs(batch) do
        if i <= 20 then
            lines[#lines + 1] = ("`%s`  %s  %d studs"):format(e.rarity, e.name, math.floor(e.dist))
        end
        local rank = RARITY_RANK[e.rarity] or 0
        if rank > bestRank then
            bestRank, best = rank, e.rarity
        end
    end
    if #batch > 20 then
        lines[#lines + 1] = ("and %d more"):format(#batch - 20)
    end
    sendWebhook({
        username = "Tempo",
        embeds = { {
            title = (#batch == 1) and "Drop spotted" or ("%d drops spotted"):format(#batch),
            description = table.concat(lines, "\n"),
            color = RARITY_COLORS[best] or RARITY_COLORS.Common,
            footer = { text = "Tempo | The Veil" },
        } },
    })
end
local function watchDropsForWebhook()
    local folder = dropsFolder()
    if not folder then
        return
    end
    folder.ChildAdded:Connect(function(model)
        if not (Toggles.DropWebhook and Toggles.DropWebhook.Value) then
            return
        end
        if webhookSeen[model] then
            return
        end
        webhookSeen[model] = true
        task.delay(0.35, function()
            if not model.Parent then
                return
            end
            local rarity = model:GetAttribute("Rarity") or "Common"
            if not webhookWantsRarity(rarity) then
                return
            end
            local root = getRoot()
            local pos = positionOf(model)
            local dist = (root and pos) and (root.Position - pos).Magnitude or 0
            local limit = Options.WebhookRadius and Options.WebhookRadius.Value or 0
            if limit > 0 and dist > limit then
                return
            end
            webhookQueue[#webhookQueue + 1] = { name = model.Name, rarity = rarity, dist = dist }
        end)
    end)
end
task.spawn(function()
    watchDropsForWebhook()
    while State.running do
        task.wait(Options.WebhookInterval and Options.WebhookInterval.Value or 4)
        if Toggles.DropWebhook and Toggles.DropWebhook.Value then
            pcall(flushWebhookQueue)
        else
            webhookQueue = {}
        end
    end
end)
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local GAME_NAME = "The Veil"
local DISCORD_INVITE = "https://discord.gg/K7Qxnxkk46"
local RSCRIPTS_LINK = "https://discord.gg/K7Qxnxkk46"
local WEBSITE_LINK = "https://tempohub.shop"
local function copyText(text, message)
    if setclipboard then
        setclipboard(text)
    elseif toclipboard then
        toclipboard(text)
    end
    Library:Notify(message)
end
local function copyDiscord()
    copyText(DISCORD_INVITE, "Copied Discord invite to clipboard")
end
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = {
        { Text = DISCORD_INVITE, Copyable = true },
        "|",
        GAME_NAME,
    },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    SidebarCompacted = true,
    TabSwipeFrom = "bottom",
    Animations = {
        TabSwitch = true,
    },
})
Window:SetGlow(true, {
    Color = Color3.fromRGB(242, 154, 196),
    Radius = 24,
    Transparency = 0.3,
})
local Tabs = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "swords"),
    Items = Window:AddTab("Items", "package"),
    Visuals = Window:AddTab("Visuals", "eye"),
    Misc = Window:AddTab("Misc", "settings-2"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings"),
}
local function AddDiscordButton(Tab)
    local DiscordGroup = Tab:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({
        Text = "Join Discord to Make Money",
        Func = copyDiscord,
    })
    DiscordGroup:AddButton({
        Text = "Join Discord for Keyless Scripts",
        Func = copyDiscord,
    })
end
for name, Tab in Tabs do
    if name ~= "Info" then
        AddDiscordButton(Tab)
    end
end
local function colored(text, color)
    return string.format('<font color="%s">%s</font>', color, text)
end
local function field(key, value, color)
    return string.format("<b>%s</b> %s %s", key, colored("-", "#5a6070"), colored(value, color))
end
local GREEN = "#7fd47f"
local BLUE = "#6ec1ff"
local ORANGE = "#e8a34d"
local GREY = "#8b93a3"
local RED = "#e05a5a"
local function detectSupport()
    local flags = {
        hookfunction ~= nil,
        hookmetamethod ~= nil,
        getrawmetatable ~= nil,
        setrawmetatable ~= nil,
        getgc ~= nil,
        getgenv ~= nil,
        getreg ~= nil,
        getconnections ~= nil,
        firesignal ~= nil,
        getcallbackvalue ~= nil,
        setclipboard ~= nil,
        getcustomasset ~= nil,
        getnamecallmethod ~= nil,
        isexecutorclosure ~= nil,
        fireproximityprompt ~= nil,
        firetouchinterest ~= nil,
        WebSocket ~= nil,
        readfile ~= nil,
        writefile ~= nil,
        (request or http_request) ~= nil,
        (debug and debug.getupvalues) ~= nil,
        (debug and debug.setupvalue) ~= nil,
    }
    local available = 0
    for _, ok in ipairs(flags) do
        if ok then available += 1 end
    end
    local ratio = available / #flags
    if ratio >= 0.9 then
        return colored("Full Support", GREEN)
    elseif ratio >= 0.6 then
        return colored("Half Support", ORANGE)
    else
        return colored("Low Support", RED)
    end
end
local function setupInfoTab()
    local executorName = "Unknown"
    pcall(function()
        if identifyexecutor then
            local name, version = identifyexecutor()
            if type(name) == "string" and name ~= "" then
                executorName = type(version) == "string" and version ~= "" and (name .. " " .. version) or name
            end
        end
    end)
    local supportText = detectSupport()
    local sessionStart = os.clock()
    local function sessionElapsed()
        local elapsed = math.floor(os.clock() - sessionStart)
        if elapsed < 60 then return elapsed .. "s"
        elseif elapsed < 3600 then return string.format("%dm %ds", math.floor((elapsed) / (60)), elapsed % 60)
        else return string.format("%dh %dm", math.floor((elapsed) / (3600)), math.floor(((elapsed % 3600)) / (60))) end
    end
    local UserGroup = Tabs.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", {
        Player = LocalPlayer,
        Title = "User",
        HeaderIcon = "user",
        Collapsible = false,
    })
    UserGroup:AddLabel(field("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, GREEN), true)
    UserGroup:AddLabel(field("UserId", tostring(LocalPlayer.UserId), BLUE), true)
    UserGroup:AddLabel(field("Executor", executorName .. "  " .. supportText, GREEN), true)
    UserGroup:AddDivider()
    local SessionLabel = UserGroup:AddLabel(field("Session", sessionElapsed(), ORANGE), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({ Text = "Copy Username", Func = function() copyText(LocalPlayer.Name, "Copied username") end })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            copyText("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
        end,
    })
    local SessionGroup = Tabs.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(field("Game", GAME_NAME, BLUE), true)
    local PlayersLabel = SessionGroup:AddLabel(field("Players", "0/0", GREEN), true)
    local jobId = tostring(game.JobId)
    local shortJobId = #jobId > 18 and (string.sub(jobId, 1, 18) .. "...") or jobId
    SessionGroup:AddLabel(field("Job", shortJobId, GREY), true)
    local PingLabel = SessionGroup:AddLabel(field("Ping", "0 ms", ORANGE), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({ Text = "Rejoin Server", Func = function() TeleportService:Teleport(PLACE_ID, LocalPlayer) end })
    SessionGroup:AddButton({ Text = "Copy Job ID", Func = function() copyText(jobId, "Copied Job ID") end })
    task.spawn(function()
        while true do
            task.wait(1)
            if Library.Unloaded then break end
            SessionLabel:SetText(field("Session", sessionElapsed(), ORANGE))
            PlayersLabel:SetText(field("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), GREEN))
            local ok, ping = pcall(function()
                return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            PingLabel:SetText(field("Ping", ok and (ping .. " ms") or "n/a", ORANGE))
        end
    end)
    local SocialsGroup = Tabs.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = copyDiscord })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function() copyText(RSCRIPTS_LINK, "Copied Rscripts profile to clipboard") end,
    })
    SocialsGroup:AddButton({ Text = "Website", Func = function() copyText(WEBSITE_LINK, "Copied website link") end })
end
setupInfoTab()
local FarmBox = Tabs.Main:AddLeftGroupbox("Auto Farm", "swords")
FarmBox:AddToggle("AutoFarm", { Text = "Auto Farm NPCs", Default = false })
FarmBox:AddToggle("FarmAutoEquip", { Text = "Auto Equip Weapon", Default = true })
FarmBox:AddToggle("FarmFaceTarget", { Text = "Look At Target", Default = true })
FarmBox:AddToggle("FarmTiltToTarget", { Text = "Tilt Body Vertically", Default = false })
FarmBox:AddToggle("FarmCameraLock", { Text = "Camera Follows Target", Default = false })
FarmBox:AddSlider("FarmRadius", {
    Text = "Search Radius",
    Default = 2000,
    Min = 100,
    Max = 5000,
    Rounding = 0,
    Suffix = " studs",
})
local PosBox = Tabs.Main:AddRightGroupbox("Farm Positioning", "move")
PosBox:AddDropdown("FarmPosition", {
    Text = "Position Mode",
    Values = { "Orbit", "Hover", "Under", "Direct" },
    Default = 1,
    Multi = false,
})
PosBox:AddDivider("Orbit")
PosBox:AddSlider("FarmOrbitRadius", {
    Text = "Orbit Radius",
    Default = 5,
    Min = 2,
    Max = 40,
    Rounding = 0,
    Suffix = " studs",
})
PosBox:AddSlider("FarmOrbitSpeed", {
    Text = "Orbit Speed",
    Default = 120,
    Min = 10,
    Max = 720,
    Rounding = 0,
    Suffix = " deg/s",
})
PosBox:AddDivider("Offsets")
PosBox:AddSlider("FarmHeight", {
    Text = "Hover Height",
    Default = 4,
    Min = 0,
    Max = 60,
    Rounding = 0,
    Suffix = " studs",
})
PosBox:AddSlider("FarmDepth", {
    Text = "Under Depth",
    Default = 8,
    Min = 0,
    Max = 60,
    Rounding = 0,
    Suffix = " studs",
})
PosBox:AddSlider("FarmReach", {
    Text = "Direct Reach",
    Default = 6,
    Min = 2,
    Max = 30,
    Rounding = 0,
    Suffix = " studs",
})
PosBox:AddDivider("Repositioning")
PosBox:AddToggle("FarmSmooth", { Text = "Smooth Repositioning", Default = true })
PosBox:AddSlider("FarmMoveSpeed", {
    Text = "Reposition Speed",
    Default = 120,
    Min = 20,
    Max = 800,
    Rounding = 0,
    Suffix = " studs/s",
})
local ChestBox = Tabs.Main:AddLeftGroupbox("Chests", "box")
ChestBox:AddToggle("AutoChest", { Text = "Auto Open Chests", Default = false })
ChestBox:AddToggle("ChestLootSweep", { Text = "Grab Chest Loot", Default = true })
local PickupBox = Tabs.Items:AddLeftGroupbox("Pickup", "hand")
PickupBox:AddToggle("AutoTrinket", { Text = "Auto Trinket Teleport", Default = false })
PickupBox:AddSlider("TrinketRadius", {
    Text = "Trinket Radius",
    Default = 3000,
    Min = 100,
    Max = 6000,
    Rounding = 0,
    Suffix = " studs",
})
PickupBox:AddDivider("Pickup All")
PickupBox:AddToggle("AutoPickup", { Text = "Auto Pickup All", Default = false })
PickupBox:AddSlider("PickupRadius", {
    Text = "Pickup Radius",
    Default = 3000,
    Min = 100,
    Max = 6000,
    Rounding = 0,
    Suffix = " studs",
})
local SellBox = Tabs.Items:AddLeftGroupbox("Auto Sell", "coins")
SellBox:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
SellBox:AddDropdown("SellRarities", {
    Text = "Rarities To Sell",
    Values = RARITIES,
    Default = { "Common" },
    Multi = true,
})
SellBox:AddDivider("Categories")
SellBox:AddToggle("SellTrinkets", { Text = "Trinkets And Junk", Default = true })
SellBox:AddToggle("SellWeapons", { Text = "Weapons", Default = false })
SellBox:AddToggle("SellOutfits", { Text = "Outfits And Armor", Default = false })
SellBox:AddToggle("SellAccessories", { Text = "Accessories", Default = false })
SellBox:AddToggle("SellPotions", { Text = "Potions", Default = false })
SellBox:AddToggle("SellEnhanced", { Text = "Also Sell Enhanced", Default = false })
SellBox:AddDivider("Behaviour")
SellBox:AddSlider("SellThreshold", {
    Text = "Sell When N Items Match",
    Default = 10,
    Min = 1,
    Max = 60,
    Rounding = 0,
})
SellBox:AddToggle("SellReturn", { Text = "Return After Selling", Default = true })
SellBox:AddButton({
    Text = "Sell Now",
    Func = function()
        task.spawn(function()
            local ok, msg = doSell()
            Library:Notify("Sell: " .. tostring(msg), 4)
        end)
    end,
})
local HookBox = Tabs.Items:AddRightGroupbox("Drop Webhook", "bell")
HookBox:AddToggle("DropWebhook", { Text = "Drop Webhook", Default = false })
HookBox:AddInput("WebhookUrl", {
    Text = "Webhook URL",
    Default = "",
    Placeholder = "https://discord.com/api/webhooks/...",
    Numeric = false,
    Finished = true,
})
HookBox:AddDropdown("WebhookRarities", {
    Text = "Rarities To Post",
    Values = RARITIES,
    Default = { "Rare", "Elite", "Legendary" },
    Multi = true,
})
HookBox:AddSlider("WebhookRadius", {
    Text = "Only Within",
    Default = 0,
    Min = 0,
    Max = 5000,
    Rounding = 0,
    Suffix = " studs",
})
HookBox:AddSlider("WebhookInterval", {
    Text = "Batch Every",
    Default = 4,
    Min = 1,
    Max = 30,
    Rounding = 0,
    Suffix = "s",
})
HookBox:AddButton({
    Text = "Send Test Webhook",
    Func = function()
        task.spawn(function()
            local ok, info = sendWebhook({
                username = "Tempo",
                embeds = { {
                    title = "Test",
                    description = "Webhook is working",
                    color = RARITY_COLORS.Legendary,
                    footer = { text = "Tempo | The Veil" },
                } },
            })
            Library:Notify(ok and "Webhook sent" or ("Webhook failed: " .. tostring(info)), 4)
        end)
    end,
})
local EspBox = Tabs.Visuals:AddLeftGroupbox("ESP", "eye")
EspBox:AddToggle("EspMaster", { Text = "Enable ESP", Default = false })
EspBox:AddDivider("Drawings")
EspBox:AddToggle("EspBox", { Text = "Boxes", Default = true })
EspBox:AddToggle("EspName", { Text = "Names", Default = true })
EspBox:AddToggle("EspDistanceText", { Text = "Distance", Default = true })
EspBox:AddToggle("EspTracer", { Text = "Tracers", Default = false })
EspBox:AddDivider("Limits")
EspBox:AddSlider("EspDistance", {
    Text = "Max Distance",
    Default = 1500,
    Min = 100,
    Max = 6000,
    Rounding = 0,
    Suffix = " studs",
})
EspBox:AddSlider("EspMaxObjects", {
    Text = "Max Drawn",
    Default = 120,
    Min = 10,
    Max = 400,
    Rounding = 0,
})
local EspCatBox = Tabs.Visuals:AddRightGroupbox("ESP Targets", "list")
EspCatBox:AddToggle("EspPlayers", { Text = "Players", Default = false })
    :AddColorPicker("EspPlayerColor", { Default = Color3.fromRGB(255, 90, 90), Title = "Player color" })
EspCatBox:AddToggle("EspIgnoreTeam", { Text = "Hide Party Members", Default = true })
EspCatBox:AddToggle("EspMobs", { Text = "Mobs", Default = false })
    :AddColorPicker("EspMobColor", { Default = Color3.fromRGB(255, 170, 60), Title = "Mob color" })
EspCatBox:AddToggle("EspDrops", { Text = "Items And Accessories", Default = false })
    :AddColorPicker("EspDropColor", { Default = Color3.fromRGB(120, 255, 160), Title = "Item color" })
EspCatBox:AddToggle("EspTrinketsOnly", { Text = "Only Trinkets", Default = false })
EspCatBox:AddToggle("EspChests", { Text = "Chests", Default = false })
    :AddColorPicker("EspChestColor", { Default = Color3.fromRGB(255, 235, 120), Title = "Chest color" })
local LightBox = Tabs.Visuals:AddLeftGroupbox("World", "sun")
LightBox:AddToggle("Fullbright", {
    Text = "Fullbright",
    Default = true,
    Callback = function(v)
        applyFullbright(v)
    end,
})
local MoveBox = Tabs.Misc:AddLeftGroupbox("Movement", "move")
MoveBox:AddDropdown("MoveMode", {
    Text = "Travel Mode",
    Values = { "Teleport", "Tween" },
    Default = 1,
    Multi = false,
    Callback = function(v)
        State.moveMode = v
    end,
})
MoveBox:AddSlider("TweenSpeed", {
    Text = "Tween Speed",
    Default = 220,
    Min = 40,
    Max = 800,
    Rounding = 0,
    Suffix = " studs/s",
    Callback = function(v)
        State.tweenSpeed = v
    end,
})
MoveBox:AddSlider("ActionDelay", {
    Text = "Action Delay",
    Default = 0.15,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
    Suffix = "s",
    Callback = function(v)
        State.actionDelay = v
    end,
})
MoveBox:AddToggle("AutoNoclip", { Text = "Auto Noclip", Default = true })
local ServerBox = Tabs.Misc:AddRightGroupbox("Server", "server")
ServerBox:AddButton({
    Text = "Rejoin",
    Func = function()
        TeleportService:Teleport(PLACE_ID, LocalPlayer)
    end,
})
ServerBox:AddButton({
    Text = "Server Hop",
    Func = function()
        local ok, err = pcall(function()
            TeleportService:Teleport(PLACE_ID, LocalPlayer)
        end)
        if not ok then
            Library:Notify("Hop failed: " .. tostring(err), 4)
        end
    end,
})
local instantPromptConnection
local function setupPlayerTab()
    local MovementGroup = Tabs.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", {
        Text = "WalkSpeed Amount",
        Default = 32, Min = 16, Max = 250, Rounding = 0,
    })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = Tabs.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", {
        Text = "Fly Speed",
        Default = 60, Min = 10, Max = 400, Rounding = 0,
    })
    UserInputService.JumpRequest:Connect(function()
        if Library.Unloaded then return end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local humanoid = getHumanoid()
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    RunService.RenderStepped:Connect(function(dt)
        if Library.Unloaded then return end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local humanoid = getHumanoid()
            if humanoid then humanoid.WalkSpeed = Options.WalkSpeed.Value end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local root = getRoot()
            local humanoid = getHumanoid()
            if root and humanoid then
                humanoid.PlatformStand = true
                local direction = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.new(0, 1, 0) end
                root.AssemblyLinearVelocity = Vector3.zero
                if direction.Magnitude > 0 then
                    root.CFrame = root.CFrame + direction.Unit * Options.FlySpeed.Value * dt
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local humanoid = getHumanoid()
            if humanoid then humanoid.PlatformStand = false end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local humanoid = getHumanoid()
            if humanoid then humanoid.WalkSpeed = 16 end
        end
    end)
    local function applyInstantPrompt(prompt)
        if not prompt:IsA("ProximityPrompt") then return end
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 50
        prompt.RequiresLineOfSight = false
    end
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                pcall(applyInstantPrompt, prompt)
            end
            instantPromptConnection = Workspace.DescendantAdded:Connect(function(descendant)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(applyInstantPrompt, descendant)
                end
            end)
        elseif instantPromptConnection then
            instantPromptConnection:Disconnect()
            instantPromptConnection = nil
        end
    end)
end
setupPlayerTab()
local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu", "logs")
local antiAfkIdledConnection
local fpsBoostConnection
local function applyAntiGameplayPause(enabled)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not enabled)
    end)
    pcall(function()
        local notification = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if notification then notification.Enabled = not enabled end
    end)
    if not enabled then return end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(LocalPlayer, "GameplayPaused", false)
        else
            LocalPlayer.GameplayPaused = false
        end
    end)
end
local function setupMenuGroup()
    local antiAfkTriggerCount = 0
    local antiAfkLastPulse = tick()
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local antiAfkStat = MenuGroup:AddLabel("AFK triggers: 0")
    local function antiAfkTap()
        local camera = Workspace.CurrentCamera
        if not camera then return end
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0), camera.CFrame)
        antiAfkTriggerCount = antiAfkTriggerCount + 1
        antiAfkLastPulse = tick()
        pcall(function() antiAfkStat:SetText("AFK triggers: " .. antiAfkTriggerCount) end)
    end
    antiAfkIdledConnection = LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(antiAfkTap)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            if Toggles.AntiAfk.Value and tick() - antiAfkLastPulse >= 60 then
                pcall(antiAfkTap)
            end
        end
    end)
    MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
    MenuGroup:AddToggle("Disable3D", { Text = "Disable 3D Rendering", Default = false })
    MenuGroup:AddToggle("FpsBoost", { Text = "FPS Boost", Default = false })
    MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
    Toggles.AntiGameplayPause:OnChanged(function()
        applyAntiGameplayPause(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                applyAntiGameplayPause(true)
            end
        end
    end)
    local reconnecting = false
    local function rejoin()
        if reconnecting then return end
        reconnecting = true
        local placeId, jobId = game.PlaceId, game.JobId
        local ok = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
        end)
        if not ok then
            pcall(function() TeleportService:Teleport(placeId, LocalPlayer) end)
        end
    end
    task.spawn(function()
        local overlay = CoreGui:WaitForChild("RobloxPromptGui", 30)
        overlay = overlay and overlay:WaitForChild("promptOverlay", 30)
        if not overlay then return end
        overlay.ChildAdded:Connect(function(child)
            if Library.Unloaded then return end
            if Toggles.AutoReconnect.Value and child.Name == "ErrorPrompt" then
                rejoin()
            end
        end)
    end)
    TeleportService.TeleportInitFailed:Connect(function()
        if Toggles.AutoReconnect.Value then
            reconnecting = false
            rejoin()
        end
    end)
    Toggles.Disable3D:OnChanged(function()
        pcall(function()
            RunService:Set3dRenderingEnabled(not Toggles.Disable3D.Value)
        end)
    end)
    local strippedClasses = {
        ParticleEmitter = true, Trail = true, Smoke = true, Fire = true,
        Sparkles = true, Explosion = true, Beam = true,
    }
    local function stripEffect(instance)
        if strippedClasses[instance.ClassName] then
            pcall(function() instance.Enabled = false end)
        end
    end
    Toggles.FpsBoost:OnChanged(function()
        if Toggles.FpsBoost.Value then
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
            pcall(function() Lighting.GlobalShadows = false end)
            pcall(function() Lighting.FogEnd = 9e9 end)
            for _, instance in ipairs(Workspace:GetDescendants()) do
                pcall(stripEffect, instance)
            end
            fpsBoostConnection = Workspace.DescendantAdded:Connect(function(instance)
                if Toggles.FpsBoost.Value then
                    pcall(stripEffect, instance)
                end
            end)
        else
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
            pcall(function() Lighting.GlobalShadows = true end)
            if fpsBoostConnection then
                fpsBoostConnection:Disconnect()
                fpsBoostConnection = nil
            end
        end
    end)
    Library.ToggleKeybind = Options.MenuKeybind
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
        Default = "RightShift",
        NoUI = true,
        Text = "Menu keybind",
    })
end
setupMenuGroup()
local ScriptGroup = Tabs.Settings:AddLeftGroupbox("Script", "terminal")
ScriptGroup:AddButton({
    Text = "Unload Script",
    Func = function()
        Library:Unload()
    end,
})
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(Tabs.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/TheVeil")
local ConfigurationBox = SaveManager:BuildConfigSection(Tabs.Settings)
local function setupConfigTransfer()
    local function configElement(objectType, index)
        local holder = objectType == "Toggle" and Toggles or Options
        local element = holder[index]
        return type(element) == "table" and element.Type == objectType and element or nil
    end
    local function encodeConfigObject(index, element)
        local elementType = element.Type
        if elementType == "Toggle" then
            return { idx = index, type = "Toggle", value = element.Value == true }
        elseif elementType == "Slider" then
            return { idx = index, type = "Slider", value = tostring(element.Value) }
        elseif elementType == "Dropdown" then
            return { idx = index, type = "Dropdown", multi = element.Multi == true, value = element.Value }
        elseif elementType == "Input" then
            return { idx = index, type = "Input", text = tostring(element.Value or "") }
        elseif elementType == "ColorPicker" then
            return {
                idx = index,
                type = "ColorPicker",
                value = element.Value:ToHex(),
                transparency = element.Transparency,
            }
        elseif elementType == "KeyPicker" then
            return {
                idx = index,
                type = "KeyPicker",
                mode = element.Mode,
                key = element.Value,
                modifiers = element.Modifiers,
                toggled = element.Toggled,
            }
        end
        return nil
    end
    local function buildConfigPayload()
        local objects = {}
        for _, holder in ipairs({ Toggles, Options }) do
            for index, element in pairs(holder) do
                if type(element) == "table"
                    and type(element.Type) == "string"
                    and not SaveManager.Ignore[index]
                then
                    local encoded = encodeConfigObject(index, element)
                    if encoded then
                        objects[#objects + 1] = encoded
                    end
                end
            end
        end
        table.sort(objects, function(a, b)
            if a.type ~= b.type then return a.type < b.type end
            return a.idx < b.idx
        end)
        return { objects = objects }
    end
    local function applyConfigObject(object)
        if type(object) ~= "table"
            or type(object.idx) ~= "string"
            or type(object.type) ~= "string"
            or SaveManager.Ignore[object.idx]
        then
            return false
        end
        local element = configElement(object.type, object.idx)
        if not element then return false end
        local applied = pcall(function()
            if object.type == "Input" then
                if type(object.text) ~= "string" then return end
                element:SetValue(object.text)
            elseif object.type == "ColorPicker" then
                element:SetValueRGB(Color3.fromHex(object.value), object.transparency)
            elseif object.type == "KeyPicker" then
                element:SetValue({ object.key, object.mode, object.modifiers })
                if object.mode == "Toggle" and object.toggled ~= nil then
                    element.Toggled = object.toggled
                    element:Update()
                end
            else
                element:SetValue(object.value)
            end
        end)
        return applied
    end
    ConfigurationBox:AddDivider()
    ConfigurationBox:AddInput("SaveManager_ImportSource", {
        Text = "Paste exported config here",
        Finished = true,
        AllowEmpty = true,
    })
    ConfigurationBox:AddButton("Export Config to Clipboard", function()
        local encodeSuccess, encoded = pcall(HttpService.JSONEncode, HttpService, buildConfigPayload())
        if not encodeSuccess then
            Library:Notify("Failed to encode the config")
            return
        end
        local writeClipboard = setclipboard or toclipboard
        if type(writeClipboard) ~= "function" or not pcall(writeClipboard, encoded) then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    ConfigurationBox:AddButton("Import Config from Clipboard Text", function()
        local source = tostring(Options.SaveManager_ImportSource.Value or ""):match("^%s*(.-)%s*$")
        if source == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        local decodeSuccess, decoded = pcall(HttpService.JSONDecode, HttpService, source)
        if not decodeSuccess or type(decoded) ~= "table" or type(decoded.objects) ~= "table" then
            Library:Notify("That is not a valid exported config")
            return
        end
        local applied = 0
        for _, object in ipairs(decoded.objects) do
            if applyConfigObject(object) then applied += 1 end
        end
        if applied == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        Library:Notify(("Imported %d setting%s"):format(applied, applied == 1 and "" or "s"), 6)
    end)
end
setupConfigTransfer()
SaveManager:LoadAutoloadConfig()
Library:OnUnload(function()
    State.running = false
    destroyEsp()
    applyFullbright(false)
    clearNoclip()
    applyAntiGameplayPause(false)
    pcall(function() RunService:Set3dRenderingEnabled(true) end)
    if antiAfkIdledConnection then antiAfkIdledConnection:Disconnect() end
    if fpsBoostConnection then fpsBoostConnection:Disconnect() end
    if instantPromptConnection then instantPromptConnection:Disconnect() end
    local hum = getHumanoid()
    if hum and State.autoRotateSaved ~= nil then
        hum.AutoRotate = State.autoRotateSaved
    elseif hum then
        hum.AutoRotate = true
    end
    Library.Unloaded = true
end)
if Toggles.HideUiOnStart.Value then
    Library:Toggle(false)
end
Library:Notify("Tempo Hub loaded", 5)
end)(...)

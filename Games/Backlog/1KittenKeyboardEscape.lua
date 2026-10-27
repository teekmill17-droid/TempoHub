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
getgenv().TempoHoodSubtitle = "+1 KITTEN KEYBOARD ESCAPE"
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
local tb_4, tb_13, tb_18, tb_20, ThemeManager, tb_25, tb_27
local Toggles
local TrailConfigurations
local lR
local my
local mf
local mX
local lX
local mE
local lE
local ml
local AuraAction
local mK
local lK
local Library
local TrailAction
local mQ
local lQ
local me
local mW
local mD
local lD
local mk
local l1
local mJ
local lJ
local connection2
local l7
local AuraConfigurations
local lP
local mw
local SaveManager
local mV
local ItemShopRequest
local mC
local lC
local mj
local l0
local mI
local lI
local connection
local connection3
local mO
local lO
local LocalPlayer
local RequestWin
local mU
local lU
local lB
local mi
local l_
local mH
local Worlds
local mo
local l5
local mN
local Request
local mu
local mb
local mT
local lT
local mA
local Shoes
local mh
local mZ
local lZ
local HttpService
local lG
local mn
local l4
local VirtualUser
local lM
local mt
local ma
local mS
local lS
local Rebirth
local mg
local mY
local lY
local mF
local Items
local mm
local l3
local Name
local lL
local ms
function fns.fn16()
    mX = nil
    connection:Disconnect()
    connection2:Disconnect()
    connection3:Disconnect()
    lY(false)
    local s5 = lX()
    if s5 then
        s5.PlatformStand = false
        s5.WalkSpeed = 16
    end
end
function fns.onCopyVenmoLink()
    l_(l0, "Copied Venmo link")
end
function fns.fn27()
    local pT = mm()
    local pU = Worlds.GetCurrent()
    local pV_1 = pU and pU.Id or 1
    local pU_2 = Shoes.GetNextUnlockableShoeName(pT.OwnedShoes, pV_1)
    if not pU_2 then
        return
    end
    local pV_2 = Shoes.GetWinsCost(pU_2)
    local pW = typeof(pV_2) ~= "number" or (pT.Wins or 0) < pV_2
    if pW then
        return
    end
    lL:FireServer(pU_2)
end
function fns.fn34()
    local Character = LocalPlayer.Character
    local n7 = Character and Character:FindFirstChildOfClass("Humanoid")
    return n7
end
function fns.onImportConfigFromClipboardTex()
    local sH_1
    local sF = l4.SaveManager_ImportSource.Value or ""
    local sF_1
    local sG = tostring(sF):match("^%s*(.-)%s*$")
    if sG == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    sF_1, sH_1 = pcall(HttpService.JSONDecode, HttpService, sG)
    local sG_1 = not sF_1 or type(sH_1) ~= "table"
    local sL = if sG_1 then 1 else 0
    local sJ = 1268 * sL + 2753 * (1 - sL)
    local sK = 184 * sL + 1178 * (1 - sL)
    if not ((sJ * 1109 + sK * 3902 + sJ * sK) % 16777213 == 2357492) then
        sG_1 = type(sH_1.objects) ~= "table"
    end
    if sG_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local sF_2 = 0
    for i, v in ipairs(sH_1.objects) do
        if lS(v) then
            sF_2 += 1
        end
    end
    if sF_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    l4.SaveManager_ImportSource:SetValue("")
    local sH_2 = sF_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(sF_2, sH_2), 6)
end
function fns.fn141(aB)
    if Library.Unloaded then
        return false
    end
    local nY = Toggles[aB]
    return nY ~= nil and nY.Value == true
end
function fns.fn144(gM, gN)
    local rZ_1 = (gM == "Toggle" and Toggles or l4)[gN]
    local rY_2 = type(rZ_1) == "table" and rZ_1.Type == gM
    return rY_2 and rZ_1 or nil
end
function fns.fn150()
    return mw.Data
end
function fns.fn153(dE, dF)
    local p4 = mm()[dF]
    local p5 = p4 ~= ""
    local p6 = typeof(p4) == "string" and p5
    if p6 then
        return p4
    end
    local p4_1 = LocalPlayer:FindFirstChild(dE)
    local p5_1 = p4_1 and p4_1:FindFirstChild("Equipped")
    local p4_2 = p5_1
    if p5_1 then
        p5_1 = p4_2:IsA("StringValue")
    end
    if p5_1 then
        return p4_2.Value
    end
    return ""
end
function fns.worker4()
    while not Library.Unloaded do
        local sZ = if lC("AutoBestWorld") then 1 else 0
        if sZ == 1 then
            pcall(mu)
        end
        if lC("AutoRebirth") then
            pcall(mg)
        end
        task.wait(2)
    end
end
function fns.fn158()
    local pM = mm()
    local pN = pM.Rebirths or 0
    local pN_1 = pM.Level or 1
    local pS = if pN_1 < Rebirth.GetRequiredLevel(pN) then 1 else 0
    if pS == 1 then
        return
    end
    Request:InvokeServer()
end
function fns.fn167(d1, d2, d3, d4, d5, d6)
    local ID
    local qm_1
    ID, qm_1 = nil, -1
    for i, v in ipairs(d4) do
        if mA(d1, d2, v.ID) then
            local qo_1 = v[d6] or 0
            if qo_1 > qm_1 then
                ID, qm_1 = v.ID, qo_1
            end
        end
    end
    local qo_2 = ID and l1(d1, d3) ~= ID
    if qo_2 then
        d5:FireServer("Equip", ID)
    end
end
function fns.fn175(bi, bj)
    local og = mf()
    if not og then
        return
    end
    mU = bj == true
    mX = bi
    og.AssemblyLinearVelocity = Vector3.zero
    og.AssemblyAngularVelocity = Vector3.zero
    og.CFrame = bi
end
function fns.fn187(cc)
    if cc:GetAttribute("PersonalTreadmill") == true then
        return false
    elseif cc.Name == "Basic" then
        return true
    else
        local o0 = lJ[cc.Name]
        if o0 then
            local OwnedTreadmills = mm().OwnedTreadmills
            local o2 = typeof(OwnedTreadmills) == "table" and OwnedTreadmills[o0] == true
            return o2
        end
        local o0_1 = l3(cc)
        if typeof(o0_1) ~= "number" then
            return false
        end
        local o1_2 = mm().Rebirths or 0
        return o1_2 >= o0_1
    end
end
function fns.onCopySolanaAddress()
    l_(ma, "Copied Solana address")
end
function fns.onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local rC_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if rC_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
function fns.onUnload()
    Library:Unload()
end
function fns.onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local rK_1 = lX()
        if rK_1 then
            rK_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn312()
    local OwnedItems = mm().OwnedItems
    local ItemTiers = mm().ItemTiers
    if typeof(OwnedItems) ~= "table" then
        return
    end
    for i, v in ipairs(Items.GetAll(OwnedItems)) do
        local max = math.max
        local floor = math.floor
        local qX = tonumber(OwnedItems[v.Id]) or 0
        local qY = max(0, floor(qX))
        local qV_1 = typeof(ItemTiers) == "table" and ItemTiers[v.Id]
        local qW_1 = qV_1 or nil
        local qW_2 = Items.MaxStarTier - 1
        local ra = 0
        while ra <= qW_2 do
            local rb = ra
            if lO(qY, qW_1, rb) >= Items.MergeCost then
                lZ:FireServer("Merge", v.Id, rb)
                return
            end
            ra += 1
        end
    end
end
local function worker()
    local rj_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local ri = math.floor(os.clock() - ml)
        if ri < 60 then
            rj_1 = ri .. "s"
        elseif ri < 3600 then
            rj_1 = string.format("%dm %ds", math.floor((ri) / (60)), ri % 60)
        else
            rj_1 = string.format("%dh %dm", math.floor((ri) / (3600)), math.floor((ri % 3600) / (60)))
        end
        mK:SetText(mT("Session time", rj_1, mt))
    end
end
local function fn325()
    local Character = LocalPlayer.Character
    local n4 = Character and Character:FindFirstChild("HumanoidRootPart")
    return n4
end
local function worker5()
    while not Library.Unloaded do
        if lC("AutoWin") then
            Name = nil
            pcall(lR)
        elseif lC("AutoBestTreadmill") then
            pcall(mJ)
        else
            Name = nil
            mX = nil
        end
        local sT = lC("AutoWin") and mD("WinDelay", 0.55)
        local sU = sT or 0.5
        task.wait(sU)
    end
end
local function fn340()
    local qz_1
    local qy_1
    local qx_1
    qx_1, qy_1, qz_1 = pcall(function()
        return ItemShopRequest:InvokeServer("GetStock")
    end)
    local qA = not qx_1 or qy_1 ~= true or typeof(qz_1) ~= "table"
    if qA then
        return
    end
    local qx_2 = mm().Wins or 0
    local qy_2 = qx_2
    local qA_1 = qz_1.Items or {}
    for k, v in pairs(qA_1) do
        local qx_4 = v.Count or 0
        local qx_5 = Items.GetWinPrice(v.ItemId)
        local qA_2 = qx_4 > 0 and typeof(qx_5) == "number" and qy_2 >= qx_5
        if qA_2 then
            ItemShopRequest:InvokeServer("BuyWins", v.Slot, v.ItemId)
            task.wait(0.2)
            local qx_6 = mm().Wins or 0
            qy_2 = qx_6
        end
    end
end
local function fn346(bD, bE, bF, bG)
    local oq = os.clock()
    local ou = oq + (bG or 2.5)
    lU(CFrame.new(bF.X, bF.Y + 80, bF.Z), false)
    mi(bF)
    while os.clock() < ou do
        if Library.Unloaded then
            return nil
        end
        for i, v in ipairs(bE) do
            local oq_1 = bD:FindFirstChild(v)
            local ot_1 = oq_1 and oq_1:IsA("BasePart")
            if ot_1 then
                return oq_1
            end
        end
        lU(CFrame.new(bF.X, bF.Y + 80, bF.Z), false)
        if os.clock() - mQ >= 0.2 then
            mi(bF)
        end
        task.wait(0.05)
    end
    for i, v in ipairs(bE) do
        local oq_2 = bD:FindFirstChild(v)
        local ot_2 = oq_2 and oq_2:IsA("BasePart")
        if ot_2 then
            return oq_2
        end
    end
    return nil
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local s1 = tick() - lE
            local s2 = tick() - mY
            if s1 >= 300 and s2 >= 60 then
                pcall(mE)
            else
                if s1 < 300 and s2 >= 300 then
                    pcall(mE)
                end
            end
        end
    end
end
local function fn372()
    l_(mn, "Copied Discord invite to clipboard")
end
local function fn398()
    Library.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
local function fn399()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    mY = tick()
end
local function worker2()
    while not Library.Unloaded do
        if lC("AutoBuyItems") then
            pcall(mH)
        end
        if lC("AutoEquipBestItems") then
            pcall(function()
                lZ:FireServer("EquipBest")
            end)
        end
        if lC("AutoFuseItems") then
            pcall(mS)
        end
        task.wait(3)
    end
end
local function fn413()
    lY(Toggles.AntiGameplayPause.Value)
end
local function fn451(ab, ac)
    return string.format('<font color="%s">%s</font>', ac, ab)
end
local function onCopyPayPalLink()
    l_(l5, "Copied PayPal link")
end
local function fn458()
    local o9_1
    local o8_1
    local o7 = Worlds.GetTreadmills()
    if not o7 then
        return nil
    end
    o9_1, o8_1 = nil, -1
    for i, child in ipairs(o7:GetChildren()) do
        local attr = child:GetAttribute("SpeedMultiplier")
        local pa = typeof(attr) == "number" and attr > o8_1 and lB(child)
        if pa then
            o9_1, o8_1 = child, attr
        end
    end
    return o9_1
end
local function fn466()
    local pK = lT()
    if not pK then
        return
    end
    if os.clock() - mN < 5 then
        return
    end
    mN = os.clock()
    lQ:FireServer(pK.Id)
end
local function onInputChanged(fR)
    local UserInputType = fR.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        lE = tick()
    end
end
local function onCopyEthereumAddress()
    l_(mh, "Copied Ethereum address")
end
local function fn538()
    local pv = mm().Level
    local pD = if pv then 1 else 0
    local pB = 436 * pD + 3611 * (1 - pD)
    local pC = 860 * pD + 2521 * (1 - pD)
    if not ((pB * 3270 + pC * 1631 + pB * pC) % 16777213 == 3203340) then
        pv = 1
    end
    local pw = pv
    local pv_1 = Worlds.GetCurrent()
    local px = pv_1 and pv_1.Id
    local pv_2 = nil
    for k, v in pairs(Worlds.GetDefinitions()) do
        local px_1 = typeof(v.RequiredLevel) == "number" and pw >= v.RequiredLevel
        if px_1 then
            if Worlds.GetTeleportPlaceId(v.Id) then
                if not pv_2 or v.RequiredLevel > pv_2.RequiredLevel or v.RequiredLevel == pv_2.RequiredLevel and v.Id > pv_2.Id then
                    pv_2 = v
                end
            end
        end
    end
    if not pv_2 or pv_2.Id == px then
        return nil
    end
    return pv_2
end
local function fn551(et, eu, ev)
    if ev > 0 then
        if typeof(eu) == "table" then
            local max = math.max
            local floor = math.floor
            local qK_1 = tonumber(eu[tostring(ev)]) or 0
            return max(0, floor(qK_1))
        end
        return 0
    end
    local qI_2 = 0
    if typeof(eu) == "table" then
        for k, v in pairs(eu) do
            local max = math.max
            local floor = math.floor
            local qL = tonumber(v) or 0
            qI_2 += max(0, floor(qL))
        end
    end
    return math.max(0, et - qI_2)
end
local function onInputBegan()
    lE = tick()
end
local function onRscripts()
    l_(mj, "Copied Rscripts profile to clipboard")
end
local function onCopyLitecoinAddress()
    l_(mo, "Copied Litecoin address")
end
local function onCopyUSDTAddress()
    l_(me, "Copied USDT address")
end
local function fn693(dO, dP, dQ, dR)
    local ID
    local qb = mm().Wins or 0
    local WinCost
    ID, WinCost = nil, nil
    for i, v in ipairs(dQ) do
        local qe = not mA(dO, dP, v.ID) and typeof(v.WinCost) == "number" and qb >= v.WinCost
        if qe then
            if WinCost == nil or v.WinCost < WinCost then
                ID, WinCost = v.ID, v.WinCost
            end
        end
    end
    if ID then
        dR:FireServer("BuyWins", ID)
    end
end
local function onRenderStepped(gq)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local rM_1 = lX()
        if rM_1 then
            rM_1.WalkSpeed = l4.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local rM_3 = mf()
        local rN = lX()
        lK = workspace.CurrentCamera or lK
        if rM_3 and rN and lK then
            rN.PlatformStand = true
            local rN_1 = Vector3.zero
            if mO:IsKeyDown(Enum.KeyCode.W) then
                rN_1 = rN_1 + lK.CFrame.LookVector
            end
            if mO:IsKeyDown(Enum.KeyCode.S) then
                rN_1 = rN_1 - lK.CFrame.LookVector
            end
            if mO:IsKeyDown(Enum.KeyCode.A) then
                rN_1 = rN_1 - lK.CFrame.RightVector
            end
            if mO:IsKeyDown(Enum.KeyCode.D) then
                rN_1 = rN_1 + lK.CFrame.RightVector
            end
            if mO:IsKeyDown(Enum.KeyCode.Space) then
                rN_1 = rN_1 + Vector3.new(0, 1, 0)
            end
            local rT = if mO:IsKeyDown(Enum.KeyCode.LeftControl) then 1 else 0
            if rT == 1 then
                rN_1 = rN_1 - Vector3.new(0, 1, 0)
            end
            rM_3.AssemblyLinearVelocity = Vector3.zero
            if rN_1.Magnitude > 0 then
                rM_3.CFrame = rM_3.CFrame + rN_1.Unit * l4.FlySpeed.Value * gq
            end
        end
    end
end
local function fn726()
    local r8 = {}
    for i, v in ipairs({ Toggles, l4 }) do
        for k, v in pairs(v) do
            local r9 = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if r9 then
                local r9_1 = mW(k, v)
                if r9_1 then
                    r8[#r8 + 1] = r9_1
                end
            end
        end
    end
    table.sort(r8, function(g8, g9)
        if g8.type ~= g9.type then
            return g8.type < g9.type
        end
        return g8.idx < g9.idx
    end)
    return { objects = r8 }
end
local function fn757()
    local po_1
    local pn_1
    local pm = ms()
    if not pm then
        return
    end
    if Name == pm.Name then
        return
    end
    pn_1, po_1 = mF(pm)
    if not pn_1 then
        return
    end
    if not po_1 then
        po_1 = mb(pm, { "Part", "Touch" }, pn_1, 2)
        if po_1 then
            pn_1 = po_1.Position
        end
    end
    if not lC("AutoBestTreadmill") then
        return
    end
    local pp = mf()
    if not pp then
        return
    end
    local pq = mZ(pn_1, po_1)
    pp.AssemblyLinearVelocity = Vector3.zero
    pp.AssemblyAngularVelocity = Vector3.zero
    pp.CFrame = pq
    mX = nil
    Name = pm.Name
end
local function onExportConfigToClipboard()
    local sz_1
    local sy_1
    sy_1, sz_1 = pcall(HttpService.JSONEncode, HttpService, mI())
    if not sy_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local sy_2 = setclipboard or toclipboard
    local sy_3 = type(sy_2) ~= "function" or not pcall(sy_2, sz_1)
    if sy_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function onCharacterAdded()
    Name = nil
end
local function onCopyBitcoinAddress()
    l_(mk, "Copied Bitcoin address")
end
local function fn776(U, V)
    if setclipboard then
        setclipboard(U)
    elseif toclipboard then
        toclipboard(U)
    end
    Library:Notify(V)
end
local function worker3()
    while not Library.Unloaded do
        if lC("AutoBuyTrails") then
            pcall(mV, "Trails", "OwnedTrails", TrailConfigurations.Trails, TrailAction)
        end
        if lC("AutoBuySkins") then
            pcall(mV, "Auras", "OwnedAuras", AuraConfigurations.Auras, AuraAction)
        end
        if lC("AutoBuyShoes") then
            pcall(lP)
        end
        if lC("AutoEquipBestTrail") then
            pcall(l7, "Trails", "OwnedTrails", "EquippedTrail", TrailConfigurations.Trails, TrailAction, "SpeedBoost")
        end
        if lC("AutoEquipBestSkin") then
            pcall(l7, "Auras", "OwnedAuras", "EquippedAura", AuraConfigurations.Auras, AuraAction, "WinBoost")
        end
        task.wait(1)
    end
end
local function fn798()
    if not Toggles.WalkSpeedEnabled.Value then
        local rW = lX()
        if rW then
            rW.WalkSpeed = 16
        end
    end
end
local function onCopyJoinScript_JobID()
    local e2 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, mC)
    l_(e2, "Copied join script to clipboard")
end
local function fn856()
    local pk_1
    local pj_1
    local pi = my()
    if not pi then
        return
    end
    pj_1, pk_1 = mF(pi)
    if not pj_1 then
        return
    end
    if not pk_1 then
        pk_1 = mb(pi, { "Touch", "Part" }, pj_1, 2.5)
        if pk_1 then
            pj_1 = pk_1.Position
        end
    end
    if not lC("AutoWin") then
        return
    end
    lU(mZ(pj_1, pk_1), false)
    RequestWin:FireServer(pi.Name)
end
local function fn877(b3)
    local oT = lD[b3.Name]
    if oT ~= nil then
        return oT
    end
    local GUI = b3:FindFirstChild("GUI")
    local oU = GUI and GUI:FindFirstChild("RebirthText", true)
    local oV = oU
    if oU then
        oU = oV:IsA("TextLabel")
    end
    if oU then
        local oU_1 = tonumber(oV.Text:match("(%d+)%s*Rebirth"))
        local Name = b3.Name
        local oW = oU_1
        local o_ = if oW then 1 else 0
        local oY = 1471 * o_ + 2168 * (1 - o_)
        local oZ = 204 * o_ + 314 * (1 - o_)
        if not ((oY * 2935 + oZ * 2826 + oY * oZ) % 16777213 == 5193973) then
            oW = false
        end
        lD[Name] = oW
    elseif GUI then
        lD[b3.Name] = 0
    end
    return lD[b3.Name]
end
local function fn878(aH, aI)
    local n0 = l4[aH]
    if n0 == nil or n0.Value == nil then
        return aI
    end
    return n0.Value
end
local function fn881()
    if not Toggles.Fly.Value then
        local rU = lX()
        if rU then
            rU.PlatformStand = false
        end
    end
end
local function fn882()
    local oK_1
    local oJ_1
    local oI = Worlds.GetGiveWins()
    if not oI then
        return nil
    end
    oK_1, oJ_1 = nil, -1
    for i, child in ipairs(oI:GetChildren()) do
        local attr = child:GetAttribute("WinAmount")
        local oL = typeof(attr) == "number" and child:GetAttribute("DoubleWinsProduct") ~= true
        if oL then
            if attr > oJ_1 then
                oK_1, oJ_1 = child, attr
            end
        end
    end
    return oK_1
end
local function onHeartbeat()
    if not mX then
        return
    end
    local n9 = mf()
    if not n9 then
        return
    end
    if mU and (n9.Position - mX.Position).Magnitude < 8 then
        return
    end
    n9.AssemblyLinearVelocity = Vector3.zero
    n9.AssemblyAngularVelocity = Vector3.zero
    n9.CFrame = mX
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            lY(true)
        end
    end
end
local function fn898(gU, gV)
    local Type = gV.Type
    if Type == "Toggle" then
        return { idx = gU, type = "Toggle", value = gV.Value == true }
    elseif Type == "Slider" then
        return { idx = gU, type = "Slider", value = tostring(gV.Value) }
    elseif Type == "Dropdown" then
        return { idx = gU, type = "Dropdown", multi = gV.Multi == true, value = gV.Value }
    elseif Type == "Input" then
        local r2 = gV.Value or ""
        return { idx = gU, type = "Input", text = tostring(r2) }
    elseif Type == "ColorPicker" then
        return { idx = gU, type = "ColorPicker", value = gV.Value:ToHex(), transparency = gV.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = gU,
            type = "KeyPicker",
            mode = gV.Mode,
            key = gV.Value,
            modifiers = gV.Modifiers,
            toggled = gV.Toggled
        }
    else
        return nil
    end
end
local function fn902(dw, dx, dy)
    local pZ = mm()[dx]
    local p_ = typeof(pZ) == "table" and pZ[dy] == true
    if p_ then
        return true
    end
    local pZ_1 = LocalPlayer:FindFirstChild(dw)
    local p__1 = pZ_1 ~= nil and pZ_1:FindFirstChild(dy) ~= nil
    return p__1
end
local function fn920(ae, af, ag)
    return string.format("<b>%s</b> %s %s", ae, lG("-", "#5a6070"), lG(af, ag))
end
local function fn923(eM)
    local DiscordGroup = eM:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = lM })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = lM })
end
local function fn924(bp, bq)
    local oi = bp.Y + 3.5
    local oj = bq and bq:IsA("BasePart")
    if oj then
        oi = bq.Position.Y + bq.Size.Y / 2 + 3.5
    end
    return CFrame.new(bp.X, oi, bp.Z)
end
local function fn942()
    local re_1
    local rd_1
    if identifyexecutor then
        re_1, rd_1 = identifyexecutor()
        local rf = re_1 ~= ""
        local rg = type(re_1) == "string" and rf
        if rg then
            local rf_1 = type(rd_1) == "string" and rd_1 ~= "" and re_1 .. " " .. rd_1
            lI = rf_1 or re_1
        end
    end
end
Shoes = nil
lB = nil
lC = nil
lD = nil
lE = nil
Items = nil
lG = nil
Worlds = nil
lI = nil
lJ = nil
lK = nil
lL = nil
lM = nil
Request = nil
lO = nil
lP = nil
lQ = nil
lR = nil
lS = nil
lT = nil
lU = nil
ItemShopRequest = nil
lX = nil
lY = nil
lZ = nil
l_ = nil
l0 = nil
l1 = nil
AuraAction = nil
l3 = nil
l4 = nil
l5 = nil
connection3 = nil
l7 = nil
TrailAction = nil
Toggles = nil
ma = nil
mb = nil
RequestWin = nil
SaveManager = nil
me = nil
mf = nil
mg = nil
mh = nil
mi = nil
mj = nil
mk = nil
ml = nil
mm = nil
local lW
mn = nil
mo = nil
connection = nil
connection2 = nil
Library = nil
ms = nil
mt = nil
mu = nil
LocalPlayer = nil
mw = nil
my = nil
Rebirth = nil
mA = nil
mC = nil
mD = nil
mE = nil
mF = nil
HttpService = nil
mH = nil
mI = nil
mJ = nil
mK = nil
Name = nil
VirtualUser = nil
mN = nil
mO = nil
AuraConfigurations = nil
mQ = nil
TrailConfigurations = nil
mS = nil
mT = nil
mU = nil
mV = nil
mW = nil
mX = nil
mY = nil
mZ = nil
local CoreGui
local GuiService
local WorldsGroup
tb_4, mO, VirtualUser, HttpService, GuiService, CoreGui, LocalPlayer = nil, nil, nil, nil, nil, nil, nil
if (GuiService and not GuiService or (VirtualUser or not GuiService) or (not VirtualUser or not GuiService) and (VirtualUser or VirtualUser)) and (GuiService or VirtualUser or not VirtualUser and VirtualUser or (not VirtualUser or VirtualUser or not VirtualUser and GuiService)) and (VirtualUser and VirtualUser and (GuiService and GuiService) or (GuiService or GuiService or not VirtualUser and GuiService) or (VirtualUser or GuiService or (VirtualUser or not GuiService)) and ((GuiService or not GuiService) and (not GuiService and VirtualUser))) or not ((GuiService and not GuiService or (VirtualUser or not GuiService) or (not VirtualUser or not GuiService) and (VirtualUser or VirtualUser)) and (GuiService or VirtualUser or not VirtualUser and VirtualUser or (not VirtualUser or VirtualUser or not VirtualUser and GuiService)) and (VirtualUser and VirtualUser and (GuiService and GuiService) or (GuiService or GuiService or not VirtualUser and GuiService) or (VirtualUser or GuiService or (VirtualUser or not GuiService)) and ((GuiService or not GuiService) and (not GuiService and VirtualUser)))) then
    tb_4 = game:GetService("Players")
else
    game:GetService("Players")
end
local tb_15 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
mO = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
LocalPlayer = tb_4.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
mn, mj, RequestWin, TrailAction, AuraAction, lZ, ItemShopRequest, lQ, Request, lL, tb_4, Worlds, Items, Shoes, tb_18, TrailConfigurations, AuraConfigurations, Rebirth, mw, tb_25, Library, ThemeManager, SaveManager, Toggles, l4, mt, mo, mk, mh, me, ma, l5, l0, tb_20, lJ, l_, lM, lG, mT, lC, mD, mm, mf, lX = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if ((tb_18 or not SaveManager) and (Shoes and not tb_18) or (tb_18 or not lQ or not Shoes and not Shoes)) and (lQ or not Shoes or (not tb_18 or SaveManager) or (SaveManager or not Shoes or not tb_18 and tb_18)) or not (((tb_18 or not SaveManager) and (Shoes and not tb_18) or (tb_18 or not lQ or not Shoes and not Shoes)) and (lQ or not Shoes or (not tb_18 or SaveManager) or (SaveManager or not Shoes or not tb_18 and tb_18))) then
    tb_13 = "+1 Kitten Keyboard Escape"
    mn = "https://discord.gg/K7Qxnxkk46"
    mj = "https://discord.gg/K7Qxnxkk46"
else
    mj = "+1 Kitten Keyboard Escape"
    tb_13 = "https://discord.gg/K7Qxnxkk46"
    mn = "https://discord.gg/K7Qxnxkk46"
end
local tb_23 = tb_15:WaitForChild("Events")
RequestWin = tb_23:WaitForChild("WinButtons"):WaitForChild("RequestWin")
TrailAction = tb_23:WaitForChild("TrailAction")
AuraAction = tb_23:WaitForChild("AuraAction")
if (mf or mf or (not mT or not TrailAction) or (not mT or not lJ or (not mT or TrailAction)) or ((not TrailAction or mf) and (not mT or mT) or (mf and TrailAction or mT and TrailAction))) and ((mo and TrailAction or false and not TrailAction or (lJ and TrailAction or (mo or lJ))) and ((not TrailAction or not mT or (not mf or false)) and (not mT and mo or mo and not lJ))) and not ((mf or mf or (not mT or not TrailAction) or (not mT or not lJ or (not mT or TrailAction)) or ((not TrailAction or mf) and (not mT or mT) or (mf and TrailAction or mT and TrailAction))) and ((mo and TrailAction or false and not TrailAction or (lJ and TrailAction or (mo or lJ))) and ((not TrailAction or not mT or (not mf or false)) and (not mT and mo or mo and not lJ)))) then
    tb_23 = ItemShopRequest:WaitForChild("ItemAction")
    lZ = ItemShopRequest:WaitForChild("ItemShopRequest")
else
    lZ = tb_23:WaitForChild("ItemAction")
    ItemShopRequest = tb_23:WaitForChild("ItemShopRequest")
end
if ((not lC and not Rebirth and (not lC and not Worlds) or (not lC or tb_25) and (not tb_4 or tb_25)) and (not tb_25 or not ThemeManager or (lC or not ThemeManager) or not Worlds and not tb_25 and (Worlds or not ThemeManager)) or not ThemeManager and not Rebirth and (Worlds or not tb_4) and (tb_25 and Rebirth or not ThemeManager and not Worlds) and ((tb_25 or not Worlds) and (not tb_25 or Rebirth) or (ThemeManager or not Worlds or (lC or Worlds)))) and not ((not lC and not Rebirth and (not lC and not Worlds) or (not lC or tb_25) and (not tb_4 or tb_25)) and (not tb_25 or not ThemeManager or (lC or not ThemeManager) or not Worlds and not tb_25 and (Worlds or not ThemeManager)) or not ThemeManager and not Rebirth and (Worlds or not tb_4) and (tb_25 and Rebirth or not ThemeManager and not Worlds) and ((tb_25 or not Worlds) and (not tb_25 or Rebirth) or (ThemeManager or not Worlds or (lC or Worlds)))) then
    lL = Request:WaitForChild("WorldTravelRequest")
    lQ = Request:WaitForChild("Rebirth"):WaitForChild("Request")
    Request:WaitForChild("Shoe"):WaitForChild("Unlock")
else
    lQ = tb_23:WaitForChild("WorldTravelRequest")
    Request = tb_23:WaitForChild("Rebirth"):WaitForChild("Request")
    lL = tb_23:WaitForChild("Shoe"):WaitForChild("Unlock")
end
tb_4 = tb_15:WaitForChild("Config")
Worlds = require(tb_4:WaitForChild("Worlds"))
Items = require(tb_4:WaitForChild("Items"))
Shoes = require(tb_4:WaitForChild("Shoes"))
tb_18 = tb_15:WaitForChild("Modules")
TrailConfigurations = require(tb_18:WaitForChild("TrailConfigurations"))
AuraConfigurations = require(tb_18:WaitForChild("AuraConfigurations"))
local tb_9 = require(tb_18:WaitForChild("ProductConfigurations"))
local tb_7 = tb_15:WaitForChild("Utility")
local tb_17 = require(tb_7:WaitForChild("PlayerData"))
Rebirth = require(tb_7:WaitForChild("Rebirth"))
mw = tb_17.GetLocalPlayerReplicaWait()
Library = getgenv().Library
pcall(fn398)
ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
l4 = Library.Options
l_ = fn776
lM = fn372
lG = fn451
mT = fn920
local tb_14 = "#7fd47f"
local tb_22 = "#6ec1ff"
mt = "#e8a34d"
local tb_3 = "#8b93a3"
mo = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
mk = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
mh = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
if (Worlds and false or false or (lG or Worlds or (tb_20 or Worlds))) and not (Worlds and false or false or (lG or Worlds or (tb_20 or Worlds))) then
    l5 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
    me = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
    ma = ""
else
    me = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
    ma = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
    l5 = ""
end
l0 = ""
local tb_2 = "#345d9d"
local tb_12 = "#f7931a"
tb_20 = "#627eea"
local tb_1 = "#26a17b"
local tb_10 = "#14f195"
local tb_19 = "#0070ba"
local tb_28 = "#008cff"
lC = fns.fn141
mD = fn878
mm = fns.fn150
mf = fn325
lX = fns.fn34
lJ = {}
for k, v in pairs(tb_9.TreadmillProducts) do
    if typeof(v.ModelName) == "string" then
        lJ[v.ModelName] = k
    end
end
lD, mX, mU, mQ, mN, Name, connection, tb_25, mi, lU, mZ, mF, mb, my, l3, lB, ms, lR, mJ, lT, mu, mg, lP, mA, l1, mV, l7, mH, lO, mS = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
lD = {}
mX = nil
mU = false
mQ = 0
mN = 0
Name = nil
connection = RunService.Heartbeat:Connect(onHeartbeat)
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
mi = function(bc)
    if typeof(bc) ~= "Vector3" then
        return
    end
    mQ = os.clock()
    pcall(function()
        LocalPlayer:RequestStreamAroundAsync(bc)
    end)
end
if mU and false and (mU and not mU) and (mU and 19 or mU and not mU) or (mU and not mU) and 19 or (not mU and false and false or mU and 19 and 19 or (not mU and mU and (mU and 19) or 19)) or not (mU and false and (mU and not mU) and (mU and 19 or mU and not mU) or (mU and not mU) and 19 or (not mU and false and false or mU and 19 and 19 or (not mU and mU and (mU and 19) or 19))) then
    lU = fns.fn175
else
    my = fns.fn175
end
mZ = fn924
mF = function(bu)
    local Touch = bu:FindFirstChild("Touch")
    local om_2
    local on = Touch and Touch:IsA("BasePart")
    local on_2
    if on then
        return Touch.Position, Touch
    end
    local Part = bu:FindFirstChild("Part")
    local on_1 = Part and Part:IsA("BasePart")
    if on_1 then
        return Part.Position, Part
    end
    om_2, on_2 = pcall(function()
        return bu:GetPivot().Position
    end)
    if om_2 and on_2 then
        return on_2, nil
    end
    return nil, nil
end
mb = fn346
my = fn882
l3 = fn877
lB = fns.fn187
ms = fn458
lR = fn856
mJ = fn757
lT = fn538
mu = fn466
if (connection or not Name or (not l7 or l7)) and (not tb_25 and not tb_25 or (Name or not tb_25)) and not ((connection or not Name or (not l7 or l7)) and (not tb_25 and not tb_25 or (Name or not tb_25))) then
    lT = fns.fn158
else
    mg = fns.fn158
end
lP = fns.fn27
mA = fn902
l1 = fns.fn153
mV = fn693
l7 = fns.fn167
mH = fn340
lO = fn551
if (lO and not mF or (not lO or lO)) and (my and my and (mF or not mF)) and (not lO and my and (not lO or lO) and (not lO and mF or (not my or mF))) or not ((lO and not mF or (not lO or lO)) and (my and my and (mF or not mF)) and (not lO and my and (not lO or lO) and (not lO and mF or (not my or mF)))) then
    mS = fn312
else
    mF = fn312
end
tb_23 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = mn, Copyable = true }, "|", tb_13 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
Library.ShowCustomCursor = false
tb_25 = {
    Info = tb_23:AddTab("Info", "info"),
    Main = tb_23:AddTab("Main", "gamepad-2"),
    Shop = tb_23:AddTab("Shop", "shopping-cart"),
    Player = tb_23:AddTab("Player", "person-standing"),
    Settings = tb_23:AddTab("Settings", "settings")
}
tb_15 = fn923
for k, v in tb_25 do
    tb_15(v)
end
lI, tb_23, tb_7, mK, mC, tb_17 = nil, nil, nil, nil, nil, nil
tb_4 = 8
repeat
    tb_15 = (tb_4 * 1 + 1) % 3 + 1
    if tb_15 <= 2 then
        if tb_15 <= 1 then
            local tR = bit32.rrotate(bit32.bxor(bit32.lrotate(tb_4, 9), string.byte(tostring(tb_17))), 15)
            if bit32.bxor(bit32.lrotate(bit32.bxor(tR, 2651077598), 16), 1004445188) ~= bit32.lrotate(tR, 16) then
                mt = "Unknown"
                pcall(fn942)
                mT = tb_13.Info:AddLeftGroupbox("Account", "circle-user")
                mT:AddLabel(tb_22("User", tb_23.Name, LocalPlayer), true)
                mT:AddLabel(tb_22("Status", "Keyless", LocalPlayer), true)
                mT:AddLabel(tb_22("Executor", mt, LocalPlayer), true)
                lG = tb_13.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                lG:AddLabel(tb_7(lI .. " [" .. tostring(game.PlaceId) .. "]", tb_25), true)
                lG:AddLabel(tb_22("Place ID", tostring(game.PlaceId), tb_25), true)
                tb_14 = lG:AddLabel(tb_22("Session time", "0s", mK), true)
            else
                lI = "Unknown"
                pcall(fn942)
                tb_23 = tb_25.Info:AddLeftGroupbox("Account", "circle-user")
                tb_23:AddLabel(mT("User", LocalPlayer.Name, tb_14), true)
                tb_23:AddLabel(mT("Status", "Keyless", tb_14), true)
                tb_23:AddLabel(mT("Executor", lI, tb_14), true)
                tb_7 = tb_25.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                tb_7:AddLabel(lG(tb_13 .. " [" .. tostring(game.PlaceId) .. "]", tb_22), true)
                tb_7:AddLabel(mT("Place ID", tostring(game.PlaceId), tb_22), true)
                mK = tb_7:AddLabel(mT("Session time", "0s", mt), true)
            end
            tb_4 = (tb_4 + 13) % 24
        else
            tb_15 = {
                "rpejkcss",
                "vdjppa",
                "xdjhpwyik",
                "waaibkcuz",
                "wbfz",
                "rylhlxb",
                "lrsfnoucfq",
                "kdovpb",
                "svuqvwxlfy"
            }
            local tN = tb_4
            tb_27 = tb_15[tN % 9 + 1]
            if tb_27:len() >= tb_27:gsub("(.)", "%1%1", tN % 3 % 2 + 1):len() then
                mK = tostring(game.JobId)
            else
                mC = tostring(game.JobId)
            end
            tb_4 = (tb_4 + 7) % 24
        end
    else
        if (tb_4 * 3 + 6) * 5 % 4 == ((tb_4 * 3 + 6) * 5 + 14) % 4 then
            mC = #tb_17 > 18
        else
            tb_17 = #mC > 18
        end
        tb_4 = (tb_4 + 4) % 24
    end
until (tb_4 * 23 + 7) % 24 == 23
if tb_17 then
    tb_4 = 4
    repeat
        tb_23 = (vector.create((tb_4 * 1 + 1) % 11 + 1, (tb_4 * 8 + 5) % 13 + 1, (tb_4 * 5 + 11) % 17 + 1))
        tb_15 = (vector.create((tb_4 * 7 + 1) % 11 + 1, (tb_4 * 8 + 10) % 13 + 1, (tb_4 * 1 + 12) % 17 + 1))
        tb_27 = (vector.create((tb_4 * 3 + 7) % 11 + 1, (tb_4 * 3 + 12) % 13 + 1, (tb_4 * 7 + 6) % 17 + 1))
        if vector.dot(vector.cross(tb_23, tb_15), tb_27) == vector.dot(vector.cross(tb_15, tb_27), tb_23) then
            tb_17 = string.sub(mC, 1, 18) .. "..."
        else
            mC = string.sub(tb_17, 1, 18) .. "..."
        end
        tb_4 = (tb_4 + 3) % 8
    until (tb_4 * 5 + 0) % 8 == 3
end
tb_4 = tb_17 or mC
ml, tb_27, WorldsGroup, lE, mY, connection2, connection3, lK, mE, lY, lW, mW, mI, lS = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local nu = tb_4
tb_7:AddLabel(mT("Server", nu, tb_3), true)
tb_7:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
ml = os.clock()
task.spawn(worker)
local ScriptsGroup = tb_25.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(lG("Included in this hub", tb_3), true)
ScriptsGroup:AddLabel(lG(tb_13, tb_22), true)
tb_9 = tb_25.Info:AddRightGroupbox("Features", "list")
if WorldsGroup and not ScriptsGroup and (WorldsGroup or not WorldsGroup) and (mE and false or (ScriptsGroup or not ScriptsGroup)) and not (WorldsGroup and not ScriptsGroup and (WorldsGroup or not WorldsGroup) and (mE and false or (ScriptsGroup or not ScriptsGroup))) then
    tb_27:AddLabel(tb_22("Auto Farm", lG), true)
    tb_27:AddLabel(tb_22("Auto Treadmill", tb_3), true)
    tb_27:AddLabel(tb_22("Auto Rebirth", tb_9), true)
    tb_27:AddLabel(tb_22("Auto Buy", tb_9), true)
    tb_27:AddLabel(tb_22("Auto Equip", lG), true)
    tb_27:AddLabel(tb_22("Auto Fuse", tb_3), true)
    tb_27:AddLabel(tb_22("World Teleport", tb_25), true)
    mt = tb_14.Info:AddRightGroupbox("Socials", "link")
else
    tb_9:AddLabel(lG("Auto Farm", tb_22), true)
    tb_9:AddLabel(lG("Auto Treadmill", mt), true)
    tb_9:AddLabel(lG("Auto Rebirth", tb_14), true)
    tb_9:AddLabel(lG("Auto Buy", tb_14), true)
    tb_9:AddLabel(lG("Auto Equip", tb_22), true)
    tb_9:AddLabel(lG("Auto Fuse", mt), true)
    tb_9:AddLabel(lG("World Teleport", tb_3), true)
    tb_27 = tb_25.Info:AddRightGroupbox("Socials", "link")
end
tb_27:AddButton({ Text = "Discord", Func = lM })
tb_27:AddButton({ Text = "Rscripts", Func = onRscripts })
tb_23 = tb_25.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
tb_23:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
tb_23:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
tb_23:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
tb_23:AddButton({ Text = "Copy Discord Invite", Func = lM })
local DonationsGroup = tb_25.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(lG("All donations are optional but appreciated.", mt), true)
DonationsGroup:AddLabel(lG("If you donate you get a special role, just PING after you donate.", tb_14), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(lG("LTC / Litecoin", tb_2), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(lG("BTC / Bitcoin", tb_12), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(lG("ETH / Ethereum", tb_20), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(lG("USDT", tb_1), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(lG("Solana", tb_10), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = fns.onCopySolanaAddress })
DonationsGroup:AddLabel(lG("PayPal", tb_19), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(lG("Venmo", tb_28), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = fns.onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(lG("Don't have any of the listed currencies but still wanna donate?", tb_3), true)
DonationsGroup:AddLabel(lG("DM me and we'll work something out.", tb_22), true)
local FaqGroup = tb_25.Info:AddRightGroupbox("FAQ", "circle-help")
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
local FarmGroup = tb_25.Main:AddLeftGroupbox("Farm", "trophy")
FarmGroup:AddToggle("AutoWin", { Text = "Auto Win", Default = false })
FarmGroup:AddSlider("WinDelay", { Text = "Win Delay", Default = 0.55, Min = 0.3, Max = 3, Rounding = 2 })
FarmGroup:AddToggle("AutoBestTreadmill", { Text = "Auto Best Treadmill", Default = false })
FarmGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
WorldsGroup = tb_25.Main:AddRightGroupbox("Worlds", "globe")
WorldsGroup:AddToggle("AutoBestWorld", { Text = "Teleport to Best World", Default = false })
local BuyGroup = tb_25.Shop:AddLeftGroupbox("Buy", "shopping-bag")
BuyGroup:AddToggle("AutoBuyTrails", { Text = "Auto Buy Trails", Default = false })
BuyGroup:AddToggle("AutoBuySkins", { Text = "Auto Buy Skins", Default = false })
BuyGroup:AddToggle("AutoBuyItems", { Text = "Auto Buy Items", Default = false })
BuyGroup:AddToggle("AutoBuyShoes", { Text = "Auto Buy Best Shoe", Default = false })
local EquipGroup = tb_25.Shop:AddRightGroupbox("Equip", "sparkles")
EquipGroup:AddToggle("AutoEquipBestTrail", { Text = "Auto Equip Best Trail", Default = false })
EquipGroup:AddToggle("AutoEquipBestSkin", { Text = "Auto Equip Best Skin", Default = false })
EquipGroup:AddToggle("AutoEquipBestItems", { Text = "Auto Equip Best Items", Default = false })
local FuseGroup = tb_25.Shop:AddLeftGroupbox("Fuse", "combine")
FuseGroup:AddToggle("AutoFuseItems", { Text = "Auto Fuse Items", Default = false })
tb_18 = tb_25.Player:AddLeftGroupbox("Movement", "footprints")
tb_18:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
tb_18:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
tb_18:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
tb_18:AddToggle("NoClip", { Text = "NoClip", Default = false })
tb_18:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
tb_17 = tb_25.Player:AddRightGroupbox("Fly", "feather")
tb_17:AddToggle("Fly", { Text = "Fly", Default = false })
tb_17:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
tb_15 = tb_25.Settings:AddLeftGroupbox("Menu", "wrench")
tb_15:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
lE = tick()
mY = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local rr = v
        pcall(function()
            rr:Disable()
        end)
    end
end)
mE = fn399
connection2 = mO.InputBegan:Connect(onInputBegan)
connection3 = mO.InputChanged:Connect(onInputChanged)
if tb_18 and not FuseGroup and (connection2 or not connection2) or (not connection2 or not lK or not tb_18 and lK) or ((not connection2 or lK) and (lK and not connection2) or (not FuseGroup and nu or (not tb_18 or not nu))) or not (tb_18 and not FuseGroup and (connection2 or not connection2) or (not connection2 or not lK or not tb_18 and lK) or ((not connection2 or lK) and (lK and not connection2) or (not FuseGroup and nu or (not tb_18 or not nu)))) then
    tb_15:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    tb_15:AddButton("Unload", fns.onUnload)
    Library.ToggleKeybind = l4.MenuKeybind
    lY = function(fY)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not fY)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not fY
            end
        end)
        if not fY then
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
    Toggles.AntiGameplayPause:OnChanged(fn413)
    task.spawn(antiGameplayPauseLoop)
    RunService.Stepped:Connect(fns.onStepped)
    mO.JumpRequest:Connect(fns.onJumpRequest)
    lK = workspace.CurrentCamera
else
    lK:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    lK:AddButton("Unload", fns.onUnload)
    tb_15.ToggleKeybind = Toggles.MenuKeybind
    l4 = function(fY)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not fY)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not fY
            end
        end)
        if not fY then
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
    Library.AntiGameplayPause:OnChanged(fn413)
    task.spawn(antiGameplayPauseLoop)
    lY.Stepped:Connect(fns.onStepped)
    RunService.JumpRequest:Connect(fns.onJumpRequest)
    mO = workspace.CurrentCamera
end
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn881)
Toggles.WalkSpeedEnabled:OnChanged(fn798)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/Plus1KittenKeyboardEscape")
local nr = SaveManager:BuildConfigSection(tb_25.Settings)
lW = fns.fn144
mW = fn898
mI = fn726
lS = function(hb)
    local ss
    ss = nil
    local st = type(hb) ~= "table" or type(hb.idx) ~= "string" or type(hb.type) ~= "string" or SaveManager.Ignore[hb.idx]
    if st then
        return false
    end
    ss = lW(hb.type, hb.idx)
    if not ss then
        return false
    end
    local st_1 = pcall(function()
        if hb.type == "Input" then
            if type(hb.text) ~= "string" then
                return
            end
            ss:SetValue(hb.text)
        elseif hb.type == "ColorPicker" then
            ss:SetValueRGB(Color3.fromHex(hb.value), hb.transparency)
        elseif hb.type == "KeyPicker" then
            ss:SetValue({ hb.key, hb.mode, hb.modifiers })
            if hb.mode == "Toggle" and hb.toggled ~= nil then
                ss.Toggled = hb.toggled
                ss:Update()
            end
        else
            ss:SetValue(hb.value)
        end
    end)
    return st_1
end
do
    nr:AddDivider()
    nr:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    nr:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    nr:AddButton("Import Config from Clipboard Text", fns.onImportConfigFromClipboardTex)
    ThemeManager:ApplyToTab(tb_25.Settings)
    ThemeManager:LoadDefault()
    SaveManager:LoadAutoloadConfig()
    task.spawn(worker5)
    task.spawn(fns.worker4)
    task.spawn(worker3)
    task.spawn(worker2)
    task.spawn(antiAfkLoop)
    Library:OnUnload(fns.fn16)
    Library:Notify(tb_13 .. " loaded")
end
end)(...)

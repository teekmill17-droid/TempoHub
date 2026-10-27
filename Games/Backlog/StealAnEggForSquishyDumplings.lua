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
getgenv().TempoHoodSubtitle = "STEAL AN EGG FOR SQUISHY DUM"
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
local yJ
local yq
local y7
local x7
local yP
local xP
local zd
local yd
local yV
local xV
local yC
local zj
local yj
local x0
local yI
local yp
local y6
local x6
local yO
local yv
local zc
local yU
local xU
local yB
local yi
local y_
local yo
local y5
local xN
local yu
local zb
local yb
local yT
local xT
local yA
local zh
local yh
local yZ
local xZ
local yG
local y4
local x4
local yM
local yt
local za
local ya
local yS
local xS
local yz
local zg
local State
local yY
local yF
local CoreGui
local x3
local yL
local y9
local yR
local xR
local yy
local zf
local yf
local yE
local y2
local yK
local yr
local x8
local yQ
local LocalPlayer
local yx
local ze
local ye
local yW
local xW
local x1
function fns.fn35()
    for k, v in pairs(yJ) do
        if v.Gui then
            v.Gui:Destroy()
        end
        if v.Highlight then
            v.Highlight:Destroy()
        end
        yJ[k] = nil
    end
    if yQ then
        yQ:Destroy()
        yQ = nil
    end
end
function fns.fn39()
    local Hb = yT()
    local targets = zc.targets
    local Hd = next(targets) ~= nil
    local He
    for i, v in ipairs(yW()) do
        local Hf = not xW() or zc.stopped
        if Hf then
            break
        else
            local Hf_1 = not Hd or targets[v.Name]
            local Hr = if Hf_1 then 1 else 0
            local Hp = 2977 * Hr + 3703 * (1 - Hr)
            local Hq = 2832 * Hr + 110 * (1 - Hr)
            if not ((Hp * 1636 + Hq * 210 + Hp * Hq) % 16777213 == 13895956) then
                Hf_1 = targets[v.ID]
            end
            local Hg = Hf_1
            if Hf_1 then
                Hf_1 = not x1(v.ID)
            end
            if Hf_1 then
                Hf_1 = v.Price > 0
            end
            if Hf_1 then
                Hf_1 = Hb >= v.Price
            end
            if Hf_1 then
                if zd("TrailAction", "BuyMoney", v.ID) then
                    task.wait(0.5)
                    if x1(v.ID) then
                        x4("Bought " .. v.Name)
                        y6("Bought " .. v.Name)
                    end
                    Hb = yT()
                end
            end
            local Hf_2 = x1(v.ID)
            if Hf_2 and (not Hd or Hg) then
                if not He or v.SpeedBoost > He.SpeedBoost then
                    He = v
                end
            end
        end
    end
    local Hb_1 = zc.equip and He and yZ() ~= He.ID
    if Hb_1 then
        if zd("TrailAction", "Equip", He.ID) then
            y6("Equipped " .. He.Name)
        end
    end
end
function fns.fn42(hw, hx)
    local F6 = {}
    for k in pairs(yf(hw)) do
        local F7_1 = hx and hx[k] or k
        F6[F7_1] = true
    end
    yd.zones = F6
end
function fns.fn47(V)
    local z9 = typeof(cloneref) == "function" and typeof(V) == "Instance"
    if z9 then
        return cloneref(V)
    end
    return V
end
function fns.fn92(im)
    local GH = tonumber(im) or 2
    x3.interval = math.max(GH, 0.5)
end
function fns.fn120()
    if y7 then
        return y7
    end
    local B6 = {}
    local Eggs = zf:FindFirstChild("Eggs")
    if not Eggs then
        return B6
    end
    for i, child in ipairs(Eggs:GetChildren()) do
        local B7_1 = x0(yo(child))
        if B7_1 then
            local B8 = B6[B7_1]
            if not B8 then
                B8 = {}
                B6[B7_1] = B8
            end
            table.insert(B8, child.Name)
        end
    end
    y7 = B6
    return B6
end
function fns.fn127(ih)
    if ih then
        yu(x3, yR)
    else
        yp(x3)
    end
end
function fns.fn155()
    return CoreGui
end
function fns.fn235(ei)
    local DV_1
    local DU_1
    local DS = ze()
    local DS_1 = DS and DS.Position or Vector3.zero
    DV_1, DU_1 = nil, nil
    for i, v in ipairs(ei) do
        local Magnitude = (v.Position - DS_1).Magnitude
        if not DU_1 or Magnitude < DU_1 then
            DV_1, DU_1 = v, Magnitude
        end
    end
    return DV_1, DU_1 or 0
end
function fns.fn277()
    local Fb = yv("TrailConfigurations")
    local Fc = not Fb
    local Fd = {}
    if not Fc then
        Fc = type(Fb.Trails) ~= "table"
    end
    if Fc then
        return Fd
    end
    for i, v in ipairs(Fb.Trails) do
        local Fb_1 = type(v) == "table" and type(v.ID) == "string"
        if Fb_1 then
            local insert = table.insert
            local ID = v.ID
            local Fe = type(v.Name) == "string" and v.Name
            local Ff = Fe or v.ID
            local Fe_1 = tonumber(v.Price) or 0
            local Fg = tonumber(v.SpeedBoost) or 0
            insert(Fd, { ID = ID, Name = Ff, Price = Fe_1, SpeedBoost = Fg })
        end
    end
    table.sort(Fd, function(gf, gg)
        return gf.Price < gg.Price
    end)
    return Fd
end
function fns.worker()
    while xW() do
        pcall(xV, true)
        task.wait(15)
    end
end
function fns.fn323(cg)
    if not cg then
        return nil
    elseif cg:IsA("BasePart") then
        return cg
    else
        for i, descendant in ipairs(cg:GetDescendants()) do
            if descendant:IsA("BasePart") then
                return descendant
            end
        end
        return nil
    end
end
function fns.fn337()
    local EP = yv("TreadmillConfigurations")
    local EQ = not EP
    local ER = {}
    local EV = if EQ then 1 else 0
    local ET = 1742 * EV + 1648 * (1 - EV)
    local EU = 3866 * EV + 3324 * (1 - EV)
    if not ((ET * 3125 + EU * 945 + ET * EU) % 16777213 == 15831692) then
        EQ = type(EP.Treadmills) ~= "table"
    end
    if EQ then
        return ER
    end
    for k, v in pairs(EP.Treadmills) do
        local EP_1 = type(v) == "table" and tonumber(v.Price)
        if EP_1 then
            table.insert(ER, { Name = k, Price = tonumber(v.Price) })
        end
    end
    table.sort(ER, function(fU, fV)
        return fU.Price < fV.Price
    end)
    return ER
end
function fns.fn391(kr)
    if kr then
        yu(yS, yU)
    else
        yp(yS)
    end
end
function fns.fn397(aG, aH)
    local Events = zf:FindFirstChild("Events")
    local Ao = Events and Events:FindFirstChild(aG)
    local An_1 = Ao
    if Ao then
        Ao = An_1:IsA(aH)
    end
    if Ao then
        return An_1
    end
    return nil
end
function fns.fn420(dP, dQ)
    local Dz_1
    local Eggs = y9:FindFirstChild("Eggs")
    local Du = {}
    if not Eggs then
        return Du
    end
    local Dv = dP and next(dP) ~= nil
    local Dw = dQ
    if Dw then
        Dw = next(dQ) ~= nil
    end
    local Dv_1 = Dw
    for i, child in ipairs(Eggs:GetChildren()) do
        local Dt_1 = (child:IsA("Folder"))
        if Dt_1 then
            Dt_1 = not Dv or dP[child.Name]
        end
        if Dt_1 then
            for i, child2 in ipairs(child:GetChildren()) do
                local Dt_2 = child2:IsA("Model") and child2.Name == "SpawnedEgg"
                local Dw_2 = Dt_2 and child2
                local Dt_3 = Dw_2 or child2:FindFirstChild("SpawnedEgg")
                local Dw_3 = Dt_3
                if Dt_3 then
                    Dt_3 = xT(Dw_3)
                end
                local Dy = Dt_3 or nil
                local Dy_1
                local Dt_4 = Dy
                if Dy then
                    Dy = Dt_4.Enabled
                end
                if Dy then
                    Dy_1, Dz_1 = x6(Dw_3, child.Name)
                    if not Dv_1 or Dz_1 and dQ[Dz_1] then
                        local DA_1 = yF(Dw_3)
                        if DA_1 then
                            table.insert(Du, { Model = Dw_3, Prompt = Dt_4, Position = DA_1, Zone = child.Name, Name = Dy_1, Rarity = Dz_1 })
                        end
                    end
                end
            end
        end
    end
    return Du
end
local function fn434(iT)
    local G_ = tonumber(iT) or 12
    xR.interval = math.max(G_, 5)
end
local function fn436()
    local By_1
    local Bx_1
    Bx_1, By_1 = {}, {}
    local Eggs = y9:FindFirstChild("Eggs")
    local BA = {}
    if Eggs then
        for i, child in ipairs(Eggs:GetChildren()) do
            local Bz_1 = child:IsA("Folder") and child.Name:match("^Zone%d+$")
            if Bz_1 then
                table.insert(BA, child.Name)
            end
        end
    end
    if #BA == 0 then
        local Bz_2 = yv("ZoneConfigurations")
        if type(Bz_2) == "table" then
            for k in pairs(Bz_2) do
                local Bz_3 = type(k) == "string" and k:match("^Zone%d+$")
                if Bz_3 then
                    table.insert(BA, k)
                end
            end
        end
    end
    table.sort(BA, function(b9, ca)
        local Bu = tonumber(b9:match("%d+")) or 0
        local Bv = tonumber(ca:match("%d+")) or 0
        return Bu < Bv
    end)
    for i, v in ipairs(BA) do
        local Bz_4 = v:gsub("Zone", "Zone ") .. " - " .. yx(v)
        table.insert(Bx_1, Bz_4)
        By_1[Bz_4] = v
    end
    return Bx_1, By_1
end
local function fn441()
    local Character = LocalPlayer.Character
    local C6 = Character and Character:GetAttribute("CarriedEgg_Name")
    local C6_1 = type(C6) == "string" and C6
    local C5_2 = C6_1
    local Da = if C5_2 then 1 else 0
    local C8 = 197 * Da + 1855 * (1 - Da)
    local C9 = 1675 * Da + 2312 * (1 - Da)
    if not ((C8 * 3023 + C9 * 1001 + C8 * C9) % 16777213 == 2602181) then
        C5_2 = nil
    end
    return C5_2
end
local function fn449()
    local Ia = yv("PlotConfigurations")
    local Ia_2
    local Ib = xV(true)
    if Ib <= 0 then
        return
    end
    local Ic = Ia and Ia.MaxSlots
    local Ic_3
    local Id = tonumber(Ic) or 0
    if Id > 0 and Ib >= Id then
        y6("Pet slots are maxed out")
        return
    end
    local Ic_2 = nil
    local Id_2 = Ia and type(Ia.Upgrades) == "table"
    if Id_2 then
        Ic_2 = tonumber(Ia.Upgrades[Ib + 1])
    end
    local Ia_1 = Ic_2 and yT() < Ic_2
    if Ia_1 then
        return
    end
    Ia_2, Ic_3 = yj("RequestPlotUpgrade")
    local Id_3 = Ia_2 and type(Ic_3) == "table" and Ic_3.Success
    if Id_3 then
        xV(true)
        x4("Unlocked pet slot " .. tostring(Ib + 1))
        y6("Unlocked pet slot " .. tostring(Ib + 1))
    end
end
local function fn497(al, am)
    if not xW() then
        return
    end
    local Notifications = State.Notifications
    local Ad = tostring(al)
    local Ae = am or 5
    table.insert(Notifications, { text = Ad, time = Ae })
    if #State.Notifications > 12 then
        table.remove(State.Notifications, 1)
    end
end
local function fn506(Y)
    return type(Y) == "function"
end
local function fn509(j9)
    local HQ = tonumber(j9) or 30
    y2.interval = math.max(HQ, 1)
end
local function fn528()
    local GJ = yq()
    local GK = 0
    for i, v in ipairs(GJ) do
        local GJ_1 = not xW() or xZ.stopped
        if GJ_1 then
            break
        end
        local GJ_2 = v.Parent and v:GetAttribute("HatchReady") == true
        if GJ_2 then
            if zd("RequestHatch", v) then
                GK += 1
                task.wait(0.35)
            end
        end
    end
    if GK > 0 then
        local GL = GK == 1 and "" or "s"
        y6("Hatched " .. GK .. " egg" .. GL)
    end
end
local function fn558()
    local eB, eC = yq()
    return #eB + #eC
end
local function fn565(cA)
    local Cg = yv("EggConfigurations")
    local Ch = Cg and type(Cg.ZoneProbabilities) == "table" and Cg.ZoneProbabilities[cA]
    local Cg_1 = Ch or nil
    local Ch_1 = {}
    if type(Cg_1) == "table" then
        for k in pairs(Cg_1) do
            table.insert(Ch_1, k)
        end
    end
    table.sort(Ch_1)
    return Ch_1
end
local function fn571(eu)
    local D3 = tonumber(State.CapacityStamp)
    local D3_1
    local D4 = not eu
    local D4_1
    if D4 ~= false then
        D4 = (State.PlotCapacity or 0) > 0
    end
    if D4 then
        D4 = D3
    end
    if D4 then
        D4 = os.clock() - D3 < 20
    end
    if D4 then
        return State.PlotCapacity
    end
    D3_1, D4_1 = yj("GetPlotCapacity")
    local D5_2 = D3_1 and tonumber(D4_1)
    if D5_2 then
        State.PlotCapacity = tonumber(D4_1)
        State.CapacityStamp = os.clock()
    end
    return State.PlotCapacity or 0
end
local function fn580()
    return y9:FindFirstChild("Plot_" .. LocalPlayer.Name)
end
local function fn591(gq)
    local Fx = yh()
    local Fy = Fx ~= nil and Fx:FindFirstChild(gq) ~= nil
    return Fy
end
local function fn602(au)
    local Al_1
    local Aj = yG[au]
    if Aj ~= nil then
        if Aj == false then
            return nil
        end
        return Aj
    end
    local Modules = zf:FindFirstChild("Modules")
    local Ak = Modules and Modules:FindFirstChild(au)
    local Ak_2
    local Ak_1 = not Ak or not Ak:IsA("ModuleScript")
    if Ak_1 then
        yG[au] = false
        return nil
    end
    Ak_2, Al_1 = pcall(require, Ak)
    local Aj_3 = not Ak_2 or type(Al_1) ~= "table"
    if Aj_3 then
        yG[au] = false
        return nil
    end
    yG[au] = Al_1
    return Al_1
end
local function fn604(eY)
    local Es_3
    local Er_1, Er_3
    local Eq_1
    local Ep
    if x8(getthreadidentity) then
        Eq_1, Er_1 = pcall(getthreadidentity)
        Ep = Eq_1 and Er_1 or nil
    end
    local Eq_3 = x8(setthreadidentity) and setthreadidentity
    local Er_2 = Eq_3
    if not Er_2 then
        local Eq_4 = x8(setidentity) and setidentity
        Er_2 = Eq_4 or nil
    end
    local Eq_5 = Er_2
    if Eq_5 then
        pcall(Eq_5, 2)
    end
    Er_3, Es_3 = pcall(eY)
    if Eq_5 and Ep then
        pcall(Eq_5, Ep)
    end
    if not Er_3 then
        warn("[Tempo] activation error: " .. tostring(Es_3))
        return false
    end
    return Es_3
end
local function fn617(ck)
    if not ck then
        return nil
    end
    local SurfaceAppearance = ck:FindFirstChildOfClass("SurfaceAppearance")
    local B1 = ck.MeshId or ""
    local B2 = tostring(B1)
    local B3 = ck.Size.Y
    local B4 = SurfaceAppearance and tostring(SurfaceAppearance.ColorMap)
    local B__1 = B4 or "none"
    return string.format("%s|%.2f|%s", B2, B3, B__1)
end
local function fn635()
    return not yE.Unloaded
end
local function fn656()
    gethui = zb
end
local function fn693()
    local Fp_1
    local Fo_1
    Fo_1, Fp_1 = {}, {}
    for i, v in ipairs(yW()) do
        table.insert(Fo_1, v.Name)
        Fp_1[v.Name] = v.ID
    end
    return Fo_1, Fp_1
end
local function fn694(kb)
    local HT = kb == "Inventory" and "Inventory" or "Equipped"
    y2.mode = HT
end
local function fn727()
    local Character = LocalPlayer.Character
    local C3 = Character ~= nil and Character:GetAttribute("CarryingEgg") == true
    return C3
end
local function fn757()
    if yQ and yQ.Parent then
        return yQ
    end
    local folder = Instance.new("Folder")
    folder.Name = "TempoEggEsp"
    folder.Parent = yB()
    yQ = folder
    return folder
end
local function fn759()
    local I2 = if coroutine.status(ya) ~= "dead" then 1 else 0
    if I2 == 1 then
        pcall(task.cancel, ya)
    end
end
local function fn771(kd)
    local HX = tonumber(kd) or 1
    y2.minimum = math.max(math.floor(HX), 1)
end
local function fn773(cI, cJ)
    local Cr = x0(yo(cI))
    local Cs = Cr and yY()[Cr]
    local Cr_1 = Cs or nil
    local Cs_1 = {}
    if Cr_1 then
        local Cr_2 = {}
        for i, v in ipairs(za(cJ)) do
            Cr_2[v] = true
        end
        for i, v in ipairs(Cr_1) do
            local Ct_1 = next(Cr_2) == nil or Cr_2[v]
            if Ct_1 then
                table.insert(Cs_1, v)
            end
        end
    end
    if #Cs_1 == 0 then
        Cs_1 = za(cJ)
    end
    table.sort(Cs_1)
    if #Cs_1 == 0 then
        return "Egg", nil
    end
    local Cr_3 = yV(Cs_1[1])
    local Ct_2 = #Cs_1
    local CN = 2
    while CN <= Ct_2 do
        local CO = CN
        local Ct_3 = yV(Cs_1[CO])
        if Ct_3 and (not Cr_3 or (yP[Ct_3] or 0) > (yP[Cr_3] or 0)) then
            Cr_3 = Ct_3
        end
        CN += 1
    end
    return table.concat(Cs_1, " / "), Cr_3
end
local function fn798(lD)
    if lD then
        yu(yC, ye)
    else
        yp(yC)
        xU()
    end
end
local function fn837(j4)
    if j4 then
        yu(y2, xN)
    else
        yp(y2)
    end
end
local function fn846()
    local E2_1
    local E1_1
    E1_1, E2_1 = yj("GetEquippedTreadmill")
    local E3 = E1_1 and type(E2_1) == "string"
    local E3_1 = E3 and E2_1 or nil
    local E1_3 = yi()
    local E3_2 = E3_1 == nil
    for i, v in ipairs(E1_3) do
        if E3_2 then
            return v
        end
        if v.Name == E3_1 then
            E3_2 = true
        end
    end
    return nil
end
local function fn851(hu)
    local F4 = tonumber(hu) or 0.6
    yd.interval = math.max(F4, 0.1)
end
local function fn877()
    local In_1
    local Im_1
    local Is = if x8(gethui) then 1 else 0
    if Is == 1 then
        Im_1, In_1 = pcall(gethui)
        local Io = Im_1 and typeof(In_1) == "Instance"
        if Io then
            return In_1
        end
        return CoreGui
    end
    return CoreGui
end
local function fn885()
    local Character = LocalPlayer.Character
    local CT = Character and Character:FindFirstChild("HumanoidRootPart")
    return CT or nil
end
local function fn904(hp)
    if hp then
        yu(yd, y4)
    else
        yp(yd)
    end
end
local function fn906()
    if zd("EquipBestPets") then
        y6("Equipped your best pets")
    end
end
local function fn955(kP)
    if kP then
        yu(yK, yA)
    else
        yp(yK)
    end
end
local function fn959(iJ)
    local GV = tonumber(iJ) or 3
    xZ.interval = math.max(GV, 0.5)
end
local function fn966(iO)
    if iO then
        yu(xR, y_)
    else
        yp(xR)
    end
end
local function fn973(i7)
    if i7 then
        yu(zg, zj)
    else
        yp(zg)
    end
end
local function fn977()
    return LocalPlayer:FindFirstChild("Trails")
end
local function fn987(bi)
    local AR_1
    local AQ_1
    local AP = xP(bi)
    AR_1, AQ_1 = {}, {}
    if not AP then
        return AR_1, AQ_1
    end
    for i, child in ipairs(AP:GetChildren()) do
        if child:IsA("Model") then
            if child:GetAttribute("IsEgg") == true then
                table.insert(AR_1, child)
            elseif child:GetAttribute("ItemUUID") then
                table.insert(AQ_1, child)
            end
        end
    end
    return AR_1, AQ_1
end
local function fn995()
    local IC = yO()
    local ID = yM(nil, yC.rarities)
    local IE = {}
    for i, v in ipairs(ID) do
        IE[v.Model] = true
        local ID_1 = yJ[v.Model]
        local IF = yo(v.Model)
        if not not IF then
            if not ID_1 or not ID_1.Gui or not ID_1.Gui.Parent then
                local billboardGui = Instance.new("BillboardGui")
                billboardGui.Name = "EggTag"
                billboardGui.AlwaysOnTop = true
                billboardGui.LightInfluence = 0
                billboardGui.Size = UDim2.fromOffset(220, 44)
                billboardGui.StudsOffset = Vector3.new(0, 3.5, 0)
                billboardGui.MaxDistance = 1000
                billboardGui.Adornee = IF
                billboardGui.Parent = IC
                local textLabel = Instance.new("TextLabel")
                textLabel.Name = "Text"
                textLabel.BackgroundTransparency = 1
                textLabel.Size = UDim2.fromScale(1, 1)
                textLabel.Font = Enum.Font.BuilderSansBold
                textLabel.TextScaled = true
                textLabel.TextStrokeTransparency = 0.2
                textLabel.TextColor3 = Color3.new(1, 1, 1)
                textLabel.Parent = billboardGui
                local highlight = Instance.new("Highlight")
                highlight.Name = "EggGlow"
                highlight.FillTransparency = 0.65
                highlight.OutlineTransparency = 0
                highlight.Adornee = v.Model
                highlight.Parent = IC
                ID_1 = { Gui = billboardGui, Label = textLabel, Highlight = highlight }
                yJ[v.Model] = ID_1
            end
            local IF_2 = v.Rarity and yr[v.Rarity]
            local IG_2 = IF_2 or Color3.fromRGB(255, 255, 255)
            local IG_3 = ze()
            local IH_2 = IG_3 and math.floor((v.Position - IG_3.Position).Magnitude)
            local IG_4 = IH_2 or 0
            local Label = ID_1.Label
            local Name = v.Name
            local IK = v.Rarity or "Unknown"
            Label.Text = string.format("%s\n%s  |  %d studs", Name, IK, IG_4)
            ID_1.Label.TextColor3 = IG_2
            ID_1.Highlight.FillColor = IG_2
            ID_1.Highlight.OutlineColor = IG_2
        end
    end
    for k, v in pairs(yJ) do
        if not IE[k] or not k.Parent then
            if v.Gui then
                v.Gui:Destroy()
            end
            if v.Highlight then
                v.Highlight:Destroy()
            end
            yJ[k] = nil
        end
    end
end
local function fn997(ip)
    xS.rarities = yf(ip)
end
local function fn1021()
    local G2_1
    local G1_1, G1_3
    G1_1, G2_1 = yj("GetDailyRewardState")
    local G3 = not G1_1
    local G3_2
    local G9 = if G3 then 1 else 0
    local G7 = 3789 * G9 + 1760 * (1 - G9)
    local G8 = 2859 * G9 + 1972 * (1 - G9)
    if not ((G7 * 1888 + G8 * 759 + G7 * G8) % 16777213 == 3379151) then
        G3 = type(G2_1) ~= "table"
    end
    if G3 then
        return
    end
    if G2_1.CanClaim ~= true then
        local G1_2 = tonumber(G2_1.SecondsUntilClaim)
        if G1_2 and G1_2 > 0 then
            y6(string.format("Daily reward in %dh %dm", math.floor((G1_2) / (3600)), math.floor((G1_2 % 3600) / (60))))
        end
        return
    end
    G1_3, G3_2 = yj("ClaimDailyReward")
    if G1_3 and G3_2 ~= false then
        local G1_4 = tonumber(G2_1.CurrentDay)
        local G1_5 = G1_4 and "Claimed daily reward day " .. G1_4 or "Claimed the daily reward"
        x4(G1_5)
        y6("Claimed the daily reward")
    end
end
local function fn1041(dv)
    local Dc_2
    local Db = os.clock() + 8
    local Db_2
    while true do
        local Dc_1 = State.MoveBusy and xW() and os.clock() < Db
        if Dc_1 then
            task.wait(0.1)
            continue
        end
        break
    end
    local Db_1 = State.MoveBusy or not xW()
    if Db_1 then
        return false
    end
    State.MoveBusy = true
    Db_2, Dc_2 = pcall(dv)
    State.MoveBusy = false
    if not Db_2 then
        warn("[Tempo] movement error: " .. tostring(Dc_2))
        return false
    end
    return Dc_2
end
local function fn1047(jx)
    if jx then
        yu(zc, yy)
    else
        yp(zc)
    end
end
local function fn1076(hE)
    yd.rarities = yf(hE)
end
local function fn1091(gY)
    gY.stopped = true
    local FM = gY.generation or 0
    gY.generation = FM + 1
end
local function fn1095(jC)
    zc.targets = yf(jC)
end
local function fn1102(fl)
    if next(xS.rarities) == nil then
        return true
    end
    local Ez = yV(fl)
    return Ez ~= nil and xS.rarities[Ez] == true
end
local function fn1145(aq)
    State.Status = tostring(aq)
end
local function fn1149(bb)
    local AG = bb
    local AL = if AG then 1 else 0
    local AJ = 3834 * AL + 1269 * (1 - AL)
    local AK = 1368 * AL + 2434 * (1 - AL)
    if not ((AJ * 538 + AK * 2325 + AJ * AK) % 16777213 == 10488204) then
        AG = x7()
    end
    bb = AG
    if AG then
        AG = bb:FindFirstChild("EggHatch")
    end
    local AH = AG
    if AG then
        AG = AH:IsA("BasePart")
    end
    if AG then
        return AH
    end
    return nil
end
local function fn1205(g_)
    local FO = {}
    if type(g_) == "table" then
        for k, v in pairs(g_) do
            local FP = v == true and type(k) == "string"
            if FP then
                FO[k] = true
            elseif type(v) == "string" then
                FO[v] = true
            end
        end
    end
    return FO
end
local function fn1223(iE)
    if iE then
        yu(xZ, yb)
    else
        yp(xZ)
    end
end
local function fn1227(dK)
    if not dK then
        return nil
    end
    for i, descendant in ipairs(dK:GetDescendants()) do
        local Dl = descendant:IsA("ProximityPrompt") and descendant:HasTag("EggLootPrompt")
        if Dl then
            return descendant
        end
    end
    return nil
end
local function fn1230()
    local FA = yh()
    local FB = FA and FA:FindFirstChild("Equipped")
    local FA_1 = FB
    if FB then
        FB = FA_1:IsA("StringValue")
    end
    if FB then
        return FA_1.Value
    end
    return nil
end
local function fn1252(c4)
    local CQ = not c4 or not c4:IsA("ProximityPrompt") or not c4.Enabled
    if CQ then
        return false
    elseif not x8(fireproximityprompt) then
        return false
    else
        return (pcall(fireproximityprompt, c4))
    end
end
local function fn1283(br)
    local A4_1
    local A3_1
    local AZ = br == ""
    local A_ = type(br) ~= "string" or AZ
    if A_ then
        return nil
    end
    local AZ_1 = y5[br]
    if AZ_1 ~= nil then
        return AZ_1 ~= false and AZ_1 or nil
    end
    local AZ_3 = yv("AnimalConfigurations")
    local A__2 = AZ_3 and type(AZ_3.Animals) == "table" and AZ_3.Animals
    local AZ_4 = A__2 or nil
    local A__3 = AZ_4
    if AZ_4 then
        AZ_4 = A__3[br]
    end
    local A0 = AZ_4
    local AZ_5 = type(A0) == "table" and type(A0.Rarity) == "string"
    if AZ_5 then
        y5[br] = A0.Rarity
        return A0.Rarity
    end
    local AZ_6 = yv("EggConfigurations")
    local A0_1 = AZ_6 and type(AZ_6.EggDrops) == "table" and AZ_6.EggDrops[br]
    local AZ_7 = A0_1 or nil
    local AZ_8 = not A__3
    local A1 = type(AZ_7) ~= "table"
    local Bb = if A1 then 1 else 0
    local A9 = 3539 * Bb + 1536 * (1 - Bb)
    local Ba = 424 * Bb + 1120 * (1 - Bb)
    if not ((A9 * 2521 + Ba * 1869 + A9 * Ba) % 16777213 == 11214811) then
        A1 = AZ_8
    end
    if A1 then
        y5[br] = false
        return nil
    end
    local AZ_9 = {}
    for k, v in pairs(AZ_7) do
        local A0_3 = A__3[k]
        local A1_1 = type(A0_3) == "table" and A0_3.Rarity
        local A0_4 = A1_1 or nil
        if type(A0_4) == "string" then
            local A0_5 = AZ_9[A0_4] or 0
            local A2 = tonumber(v) or 0
            AZ_9[A0_4] = A0_5 + A2
        end
    end
    A4_1, A3_1 = nil, nil
    for k, v in pairs(AZ_9) do
        local AZ_10 = not A3_1 or v > A3_1
        if not AZ_10 then
            local A__4 = v == A3_1
            if A__4 then
                A__4 = (yP[k] or 0) > (yP[A4_1] or 0)
            end
            AZ_10 = A__4
        end
        if AZ_10 then
            A4_1, A3_1 = k, v
        end
    end
    local AZ_11 = A4_1
    local Bb_1 = if AZ_11 then 1 else 0
    local A9_1 = 934 * Bb_1 + 223 * (1 - Bb_1)
    local Ba_1 = 4091 * Bb_1 + 2437 * (1 - Bb_1)
    if not ((A9_1 * 3881 + Ba_1 * 600 + A9_1 * Ba_1) % 16777213 == 9900448) then
        AZ_11 = false
    end
    y5[br] = AZ_11
    return A4_1
end
local function fn1316()
    local SellNPC = y9:FindFirstChild("SellNPC")
    local EN = SellNPC and SellNPC:FindFirstChild("ProxPart")
    local EM_1 = EN
    if EN then
        EN = EM_1:IsA("BasePart")
    end
    if EN then
        return EM_1
    end
    return nil
end
local function fn1356()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local AB = leaderstats and leaderstats:FindFirstChild("Money")
    local AA_1 = AB
    if AB then
        AB = tonumber(AA_1.Value)
    end
    return AB or 0
end
local function fn1361(lJ)
    yC.rarities = yf(lJ)
end
local function fn1366()
    local H0_1
    local H__1
    local HZ = yz()
    if not HZ then
        y6("Treadmill is fully upgraded")
        return
    end
    if yT() < HZ.Price then
        return
    end
    H__1, H0_1 = yj("RequestTreadmillUpgrade")
    local H1 = H__1 and type(H0_1) == "table" and H0_1.Success
    if H1 then
        x4("Upgraded to " .. HZ.Name)
        y6("Upgraded to " .. HZ.Name)
    end
end
local function fn1373(jF)
    zc.equip = jF == true
end
local function fn1385(kf)
    y2.teleport = kf == true
end
local function fn1392(bS)
    local Bo = yv("ZoneConfigurations")
    local Bp = Bo and Bo[bS]
    local Bp_1 = type(Bp) == "table" and type(Bp.DisplayName) == "string"
    if Bp_1 then
        return Bp.DisplayName
    end
    return bS
end
local function fn1397()
    if not zh() then
        return false
    end
    local EF = yL()
    local EG = EF and not yt(EF)
    if EG then
        y6("Dropping " .. EF)
        zd("DropEgg")
        task.wait(0.4)
        return not zh()
    end
    local EG_1 = xP()
    if not EG_1 then
        y6("Your plot is not loaded")
        return false
    end
    local EH = EF or "the egg"
    y6("Delivering " .. EH)
    local EF_1 = EG_1.Position + Vector3.new(0, EG_1.Size.Y * 0.5 + 3, 0)
    if not yI(EF_1, 0) then
        return false
    end
    local EG_2 = os.clock() + 4
    while true do
        local EH_1 = xW() and zh() and os.clock() < EG_2
        if EH_1 then
            yI(EF_1, 0)
            task.wait(0.25)
            continue
        end
        break
    end
    if zh() then
        zd("DropEgg")
        task.wait(0.5)
    end
    return not zh()
end
local function fn1448()
    yp(yd)
    yp(x3)
    yp(xZ)
    yp(xR)
    yp(zg)
    yp(zc)
    yp(y2)
    yp(yS)
    yp(yK)
    yp(yC)
    xU()
end
xN = nil
xP = nil
LocalPlayer = nil
xR = nil
xS = nil
xT = nil
xU = nil
xV = nil
xW = nil
xZ = nil
x0 = nil
x1 = nil
x3 = nil
x4 = nil
x6 = nil
x7 = nil
x8 = nil
ya = nil
yb = nil
yd = nil
ye = nil
yf = nil
State = nil
yh = nil
yi = nil
yj = nil
CoreGui = nil
yo = nil
yp = nil
yq = nil
yr = nil
yt = nil
yu = nil
yv = nil
yx = nil
yy = nil
local Players, xO, Workspace, xY, x_, Lighting, x5, x9, TeleportService, yk, yl, yn, ys, GuiService
yz = nil
yA = nil
yB = nil
yC = nil
yE = nil
yF = nil
yG = nil
yI = nil
yJ = nil
yK = nil
yL = nil
yM = nil
yO = nil
yP = nil
yQ = nil
yR = nil
yS = nil
yT = nil
yU = nil
yV = nil
yW = nil
yY = nil
yZ = nil
y_ = nil
y2 = nil
y4 = nil
y5 = nil
y6 = nil
y7 = nil
y9 = nil
za = nil
zb = nil
zc = nil
zd = nil
ze = nil
zf = nil
zg = nil
zh = nil
zj = nil
local yD, HttpService, VirtualUser, UserInputService, y0, y1, y3, RunService, zi, zk
yD = nil
HttpService = nil
VirtualUser = nil
UserInputService = nil
y0 = nil
y1 = nil
y3 = nil
RunService = nil
zi = nil
zk = nil
local zx = if not game:IsLoaded() then 1 else 0
if zx == 1 then
    game.Loaded:Wait()
end
Players, RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, TeleportService, Lighting, Workspace, LocalPlayer, zb = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
game:GetService("CollectionService")
TeleportService = game:GetService("TeleportService")
Lighting = game:GetService("Lighting")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local NV_4 = "TempoSquishyDumplings"
zb = fns.fn155
if getgenv then
    getgenv().gethui = zb
end
yE, zf, y9, y0, yP, x_, x8, xW = nil, nil, nil, nil, nil, nil, nil, nil
pcall(fn656)
local function zp(u)
    local zW
    local zX
    local zV
    zV = nil
    zW = nil
    zX = nil
    local zY = u ~= ""
    local zZ = type(u) == "string" and zY
    assert(zZ, "A namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    zW = getgenv()
    assert(type(zW) == "table", "getgenv did not return a table")
    local zY_1 = zW[u]
    if zY_1 ~= nil then
        local zZ_1 = type(zY_1) == "table" and type(zY_1.Unload) == "function"
        assert(zZ_1, "Namespace is occupied")
        zY_1.Unload()
        assert(zW[u] == nil, "Previous instance did not release its namespace")
    end
    zX = {}
    zV = { State = {}, Unloaded = false }
    zV.Track = function(A)
        assert(type(A) == "function", "Cleanup must be callable")
        if zV.Unloaded then
            A()
        else
            table.insert(zX, A)
        end
        return A
    end
    zV.Unload = function()
        local zO_1
        local zN_1
        if zV.Unloaded then
            return
        end
        zV.Unloaded = true
        local zL = {}
        local zS = #zX
        local zR = -1
        while false and zS <= 1 or true and zS >= 1 do
            local zT = zS
            local zM_1 = table.remove(zX, zT)
            zN_1, zO_1 = pcall(zM_1)
            if not zN_1 then
                table.insert(zL, tostring(zO_1))
            end
            zS += zR
        end
        table.clear(zV.State)
        if #zL > 0 then
            error("Cleanup incomplete: " .. table.concat(zL, "; "), 0)
        end
        if zW[u] == zV then
            zW[u] = nil
        end
    end
    zW[u] = zV
    return zV
end
x_ = function(N, O)
    local z4 = type(N) == "table" and type(N.Track) == "function"
    assert(z4, "FeatureAPI required")
    local z4_1 = type(O) == "table" and type(O.OnUnload) == "function"
    assert(z4_1, "UI library required")
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
yE = zp(NV_4)
x8 = fn506
xW = fn635
zf = fns.fn47(ReplicatedStorage)
y9 = fns.fn47(Workspace)
if ((y9 or x_ or not y9) and ((false or not y9) and (y9 and false))) or not ((y9 or x_ or not y9) and ((false or not y9) and (y9 and false))) then
    y0 = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Limited" }
end
if ((not zf or not zf) and (zf and not zf) or (not zf or zf or (xW or xW))) and (not zf and not zf and (not zf and not xW) and ((not zf or not zf) and (not zf or zf))) and not (((not zf or not zf) and (zf and not zf) or (not zf or zf or (xW or xW))) and (not zf and not zf and (not zf and not xW) and ((not zf or not zf) and (not zf or zf)))) then
    xW = {}
else
    yP = {}
end
for i, v in ipairs(y0) do
    yP[v] = i
end
yr, yl, State, yG, y5, y7, xS, yd, x3, xZ, xR, zg, zc, y2, yS, yK, yC, yQ, yJ, x4, y6, yv, yD, zd, yj, yT, x7, xP, yq, yV, yx, zk, yo, x0, yY, za, x6, x5, ze, yI, zh, yL, x9, yF, xT, yM, xY, xV, yk, zi, ys, yn, yt, xO, y3, yi, yz, yW, y1, yh, x1, yZ, yu, yp, yf, y4, yR, yb, y_, zj, yy, xN, yU, yA, yB, xU, yO, ye = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
yr = {
    Common = Color3.fromRGB(200, 200, 200),
    Uncommon = Color3.fromRGB(85, 255, 142),
    Rare = Color3.fromRGB(0, 170, 255),
    Epic = Color3.fromRGB(214, 102, 255),
    Legendary = Color3.fromRGB(255, 170, 0),
    Mythical = Color3.fromRGB(255, 85, 127),
    Secret = Color3.fromRGB(255, 255, 255),
    Limited = Color3.fromRGB(0, 255, 128)
}
yl = { "Inventory", "Equipped" }
State = yE.State
State.Notifications = {}
State.Status = "Idle"
State.PlotCapacity = 0
State.MoveBusy = false
x4 = fn497
y6 = fn1145
yG = {}
yv = fn602
yD = fns.fn397
zd = function(aO, ...)
    local Ar
    local Aq
    Aq = nil
    Ar = nil
    Aq = yD(aO, "RemoteEvent")
    if not Aq then
        return false
    end
    Ar = table.pack(...)
    return (pcall(function()
        Aq:FireServer(table.unpack(Ar, 1, Ar.n))
    end))
end
yj = function(aV, ...)
    local At
    local Au
    At = nil
    Au = nil
    At = yD(aV, "RemoteFunction")
    if not At then
        return false, "remote unavailable"
    end
    Au = table.pack(...)
    local Av = table.pack(pcall(function()
        return At:InvokeServer(table.unpack(Au, 1, Au.n))
    end))
    if not Av[1] then
        return false, "remote rejected"
    end
    return true, table.unpack(Av, 2, Av.n)
end
yT = fn1356
x7 = fn580
xP = fn1149
yq = fn987
y5 = {}
yV = fn1283
yx = fn1392
zk = fn436
yo = fns.fn323
x0 = fn617
yY = fns.fn120
za = fn565
x6 = fn773
x5 = fn1252
ze = fn885
yI = function(dc, dd)
    local CW
    local CV
    CV = nil
    CW = nil
    if typeof(dc) ~= "Vector3" then
        return false
    end
    CV = ze()
    if not CV then
        return false
    end
    local CY = dd
    local C1 = if CY then 1 else 0
    local C_ = 3283 * C1 + 2617 * (1 - C1)
    local C0 = 549 * C1 + 3393 * (1 - C1)
    if not ((C_ * 11 + C0 * 1191 + C_ * C0) % 16777213 == 2492339) then
        CY = 4
    end
    CW = dc + Vector3.new(0, CY, 0)
    return (pcall(function()
        CV.CFrame = CFrame.new(CW)
        CV.AssemblyLinearVelocity = Vector3.zero
    end))
end
zh = fn727
yL = fn441
x9 = fn1041
yF = function(dE)
    local Df_1
    local De_1
    if not dE then
        return nil
    elseif dE:IsA("BasePart") then
        return dE.Position
    else
        De_1, Df_1 = pcall(function()
            return dE:GetPivot()
        end)
        local Dg = De_1 and typeof(Df_1) == "CFrame"
        if Dg then
            return Df_1.Position
        end
        return nil
    end
end
xT = fn1227
yM = fns.fn420
xY = fns.fn235
xV = fn571
yk = fn558
xS = { rarities = {} }
zi = function()
    local Ej, Ek
    local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local Em = yv("EggConfigurations")
    local En = Em and type(Em.EggSettings) == "table" and Em.EggSettings
    local Em_1 = En or nil
    Ek = {}
    Ej = Em_1
    local function Em_2(eN)
        if not eN then
            return
        end
        for i, child in ipairs(eN:GetChildren()) do
            local D7 = child:IsA("Tool") and child:GetAttribute("OriginalName")
            local D8 = D7 or nil
            local D8_1 = type(D8) == "string" and Ej and Ej[D8]
            if D8_1 then
                table.insert(Ek, { Tool = child, Name = D8, Rarity = yV(D8) })
            end
        end
    end
    Em_2(Backpack)
    Em_2(LocalPlayer.Character)
    return Ek
end
ys = fn604
yn = function(fa)
    local Character = LocalPlayer.Character
    local Ex = Character and Character:FindFirstChildOfClass("Humanoid")
    local Ev = Ex
    if not Ev or not fa or not fa.Parent then
        return false
    elseif fa.Parent ~= Character then
        local Ex_2 = pcall(function()
            Ev:EquipTool(fa)
        end)
        if not Ex_2 then
            return false
        end
        task.wait(0.35)
        if fa.Parent ~= Character then
            return false
        end
        return ys(function()
            fa:Activate()
            return true
        end)
    elseif fa.Parent ~= Character then
        return false
    else
        return ys(function()
            fa:Activate()
            return true
        end)
    end
end
yt = fn1102
xO = fn1397
y3 = fn1316
yi = fns.fn337
yz = fn846
yW = fns.fn277
y1 = fn693
yh = fn977
x1 = fn591
yZ = fn1230
yd = { interval = 0.6, zones = {}, rarities = {} }
x3 = { interval = 2 }
if (not xY or yR or (not yJ or yR) or (not xY and not yJ or not yJ and not yJ) or (yJ and xY and (yR and yJ) or not xY and xY and (not yJ and false))) and not (not xY or yR or (not yJ or yR) or (not xY and not yJ or not yJ and not yJ) or (yJ and xY and (yR and yJ) or not xY and xY and (not yJ and false))) then
    yK = { interval = 3 }
else
    xZ = { interval = 3 }
end
xR = { interval = 12 }
zg = { interval = 60 }
zc = { interval = 10, targets = {}, lookup = {}, equip = true }
y2 = { interval = 30, mode = "Equipped", minimum = 1, teleport = true }
yS = { interval = 10 }
yK = { interval = 10 }
yC = { interval = 1, rarities = {} }
yu = function(gL, gM)
    local generation
    local FK = gL.generation or 0
    gL.generation = FK + 1
    gL.stopped = false
    generation = gL.generation
    task.spawn(function()
        local FE_1
        while true do
            local FD = xW() and not gL.stopped and gL.generation == generation
            local FD_1
            if FD then
                FD_1, FE_1 = pcall(gM)
                if not FD_1 then
                    warn("[Tempo] loop error: " .. tostring(FE_1))
                end
                local FD_2 = not xW()
                local FI = if FD_2 then 1 else 0
                local FG = 1393 * FI + 1361 * (1 - FI)
                local FH = 2438 * FI + 669 * (1 - FI)
                if not ((FG * 1572 + FH * 748 + FG * FH) % 16777213 == 7409554) then
                    FD_2 = gL.stopped
                end
                if not FD_2 then
                    FD_2 = gL.generation ~= generation
                end
                if FD_2 then
                    break
                end
                task.wait(gL.interval)
                continue
            end
            break
        end
    end)
end
yp = fn1091
yf = fn1205
y4 = function()
    local F_
    if zh() then
        x9(xO)
        return
    end
    local F0 = yM(yd.zones, yd.rarities)
    if #F0 == 0 then
        y6("No egg matches the filters right now")
        return
    end
    F_ = xY(F0)
    if not F_ then
        return
    end
    y6("Stealing " .. F_.Name)
    x9(function()
        if not F_.Model.Parent then
            return false
        elseif not yI(F_.Position, 4) then
            return false
        else
            task.wait(0.35)
            if not F_.Model.Parent then
                return false
            end
            x5(F_.Prompt)
            local FX = os.clock() + 1.5
            while true do
                local FY = xW() and not zh() and os.clock() < FX
                if FY then
                    task.wait(0.05)
                    continue
                end
                break
            end
            if zh() then
                xO()
            end
            return true
        end
    end)
end
yd.SetEnabled = fn904
yd.SetDelay = fn851
yd.SetZones = fns.fn42
yd.SetRarities = fn1076
yR = function()
    local Gr, Gs, Gt, Gu, Gv
    if zh() then
        x9(xO)
        return
    end
    Gs = xP()
    if not Gs then
        y6("Your plot is not loaded")
        return
    end
    Gu = zi()
    if #Gu == 0 then
        return
    end
    local Gw = xV(true)
    local Gx = Gw > 0 and Gw - yk()
    Gv = Gx or #Gu
    if Gv <= 0 then
        y6("Your plot is full")
        return
    end
    local Gw_2 = next(xS.rarities)
    Gr = 0
    Gt = Gw_2 ~= nil
    x9(function()
        local Ge = Gs.Position + Vector3.new(0, Gs.Size.Y * 0.5 + 3, 0)
        if not yI(Ge, 0) then
            return false
        end
        task.wait(0.5)
        for i, v in ipairs(Gu) do
            local Ge_1 = not xW() or x3.stopped or Gv <= 0
            if Ge_1 then
                break
            end
            local Ge_2 = v.Tool.Parent
            if Ge_2 then
                Ge_2 = not Gt or v.Rarity and xS.rarities[v.Rarity]
            end
            if Ge_2 then
                y6("Placing " .. v.Name)
                if yn(v.Tool) then
                    local Ge_3 = os.clock() + 2
                    while true do
                        local Gf_2 = xW() and v.Tool.Parent and os.clock() < Ge_3
                        if Gf_2 then
                            task.wait(0.1)
                            continue
                        end
                        break
                    end
                    if not v.Tool.Parent then
                        Gr += 1
                        Gv -= 1
                    end
                end
            end
        end
        return true
    end)
    if Gr > 0 then
        xV(true)
        local Gx_1 = Gr == 1 and ""
        local GE = if Gx_1 then 1 else 0
        local GC = 2491 * GE + 621 * (1 - GE)
        local GD = 2892 * GE + 4041 * (1 - GE)
        if not ((GC * 3621 + GD * 3345 + GC * GD) % 16777213 == 9120410) then
            Gx_1 = "s"
        end
        y6("Placed " .. Gr .. " egg" .. Gx_1 .. " on your plot")
    end
end
x3.SetEnabled = fns.fn127
x3.SetDelay = fns.fn92
x3.SetRarities = fn997
yb = fn528
xZ.SetEnabled = fn1223
xZ.SetDelay = fn959
y_ = fn906
xR.SetEnabled = fn966
xR.SetDelay = fn434
zj = fn1021
zg.SetEnabled = fn973
yy = fns.fn39
zc.SetEnabled = fn1047
zc.SetTargets = fn1095
zc.SetEquip = fn1373
xN = function()
    local Hw
    local Hz_2
    local Hx = y2.mode == "Inventory" and "Inventory"
    local Hx_1
    local Hy = Hx or "Equipped"
    local Hy_4
    Hw = Hy
    if Hw == "Inventory" then
        Hx_1 = 0
        local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        local Hz_1 = Backpack and Backpack:GetChildren()
        local HA = Hz_1 or {}
        for i, v in ipairs(HA) do
            local Hy_3 = v:IsA("Tool") and v:GetAttribute("IsTemporary") ~= true
            if Hy_3 then
                Hx_1 += 1
            end
        end
    else
        Hy_4, Hz_2 = yq()
        Hx_1 = #Hz_2
    end
    if Hx_1 < y2.minimum then
        return
    end
    local Hx_2 = x9(function()
        if y2.teleport then
            local Ht = y3()
            local Ht_1 = Ht and Ht.Position or nil
            local Hu_1 = Ht_1
            if Ht_1 then
                Ht_1 = not yI(Hu_1, 4)
            end
            if Ht_1 then
                return false
            end
            task.wait(0.35)
            return zd("RequestSell", Hw)
        end
        return zd("RequestSell", Hw)
    end)
    if Hx_2 then
        y6("Sold your " .. string.lower(Hw))
    end
end
y2.SetEnabled = fn837
y2.SetDelay = fn509
y2.SetMode = fn694
y2.SetMinimum = fn771
y2.SetTeleport = fn1385
yU = fn1366
yS.SetEnabled = fns.fn391
yA = fn449
yK.SetEnabled = fn955
yJ = {}
yB = fn877
xU = fns.fn35
yO = fn757
if yn and not xV or false or false or (false and xV or (yn or xV)) and (yn and xV and false) or (xV or xV) and (not xV and xV) and (false and (yR or yn)) and ((yR or false or xV and false) and ((false or yn) and (yR or false))) or not (yn and not xV or false or false or (false and xV or (yn or xV)) and (yn and xV and false) or (xV or xV) and (not xV and xV) and (false and (yR or yn)) and ((yR or false or xV and false) and ((false or yn) and (yR or false)))) then
    ye = fn995
else
    yf = fn995
end
yC.SetEnabled = fn798
yC.SetRarities = fn1361
yE.Track(fn1448)
ya = nil
ya = task.spawn(fns.worker)
if ((ya or ya and ya) and ((not ya or 2) and (ya or ya)) or ((not ya) and (not ya and false) or ya)) and not ((ya or ya and ya) and ((not ya or 2) and (ya or ya)) or ((not ya) and (not ya and false) or ya)) then
    yE.Track(fn759)
else
    yE.Track(fn759)
end
local function NV_5()
    local NA
    local onDiscord
    local NC
    onDiscord = nil
    NA = nil
    NC = nil
    local Np, Nr, Ns, Library, Nu, Toggles, Nw, Nx, Ny, ThemeManager, Options, SaveManager
    Nx = "https://tempohub.shop"
    Ns = "https://discord.gg/K7Qxnxkk46"
    Np = "Steal an Egg for Squishy Dumplings"
    NC = "https://discord.gg/K7Qxnxkk46"
    Library = getgenv().Library
    ThemeManager = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = Library.Toggles
    Options = Library.Options
    x_(yE, Library)
    Nr, Ny = zk()
    Nu = y1()
    NA = function(ml, mm)
        local I3 = x8(setclipboard) and setclipboard
        local I4 = I3
        if not I4 then
            local I3_1 = x8(toclipboard) and toclipboard
            I4 = I3_1 or nil
        end
        local I3_2 = I4
        if not I3_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local I4_1 = pcall(I3_2, ml)
        if I4_1 then
            Library:Notify(mm)
        else
            Library:Notify("Failed to copy")
        end
    end
    onDiscord = function()
        NA(NC, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = NC, Copyable = true }, "|", Np, "|", "v0.1" },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(false)
    Nw = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gamepad-2"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
    local function NE_1(mz)
        local DiscordGroup = mz:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    for k, v in Nw do
        if k ~= "Info" then
            NE_1(v)
        end
    end
    local function NF()
        local oh
        local EggsGroup = Nw.Main:AddLeftGroupbox("Eggs", "egg")
        local Label = EggsGroup:AddLabel(State.Status, true)
        EggsGroup:AddDivider()
        EggsGroup:AddToggle("AutoSteal", {
            Text = "Auto Steal",
            Default = false,
            Tooltip = "Teleports to the nearest matching nest egg, steals it, and runs it back to your plot.",
            Callback = function(mK)
                yd.SetEnabled(mK)
            end
        })
        EggsGroup:AddDropdown("StealZones", {
            Text = "Zones",
            Values = Nr,
            Default = {},
            Multi = true,
            AllowNull = true,
            Tooltip = "Leave everything unticked to steal from every zone.",
            Callback = function(mP)
                yd.SetZones(mP, Ny)
            end
        })
        EggsGroup:AddDropdown("StealRarities", {
            Text = "Rarities",
            Values = y0,
            Default = {},
            Multi = true,
            AllowNull = true,
            Tooltip = "Egg rarity is read from the animals that egg can hatch. Leave everything unticked to accept any rarity.",
            Callback = function(mV)
                yd.SetRarities(mV)
            end
        })
        EggsGroup:AddSlider("StealDelay", {
            Text = "Steal Delay",
            Default = 0.6,
            Min = 0.1,
            Max = 10,
            Rounding = 1,
            Suffix = "s",
            Callback = function(mX)
                yd.SetDelay(mX)
            end
        })
        EggsGroup:AddDivider("Plot")
        EggsGroup:AddToggle("AutoPlace", {
            Text = "Auto Place Eggs",
            Default = false,
            Tooltip = "Places the eggs in your backpack onto your plot, and carries home an egg you are already holding.",
            Callback = function(mZ)
                x3.SetEnabled(mZ)
            end
        })
        EggsGroup:AddDropdown("PlaceRarities", {
            Text = "Place Rarities",
            Values = y0,
            Default = {},
            Multi = true,
            AllowNull = true,
            Tooltip = "Only places and carries these rarities. Anything else is dropped on the spot. Leave everything unticked to keep every egg.",
            Callback = function(m2)
                x3.SetRarities(m2)
            end
        })
        EggsGroup:AddSlider("PlaceDelay", {
            Text = "Place Delay",
            Default = 2,
            Min = 0.5,
            Max = 30,
            Rounding = 1,
            Suffix = "s",
            Callback = function(m4)
                x3.SetDelay(m4)
            end
        })
        EggsGroup:AddToggle("AutoHatch", {
            Text = "Auto Hatch Eggs",
            Default = false,
            Tooltip = "Hatches every egg on your plot as soon as its timer is finished.",
            Callback = function(m6)
                xZ.SetEnabled(m6)
            end
        })
        EggsGroup:AddSlider("HatchDelay", {
            Text = "Hatch Check Delay",
            Default = 3,
            Min = 0.5,
            Max = 30,
            Rounding = 1,
            Suffix = "s",
            Callback = function(na)
                xZ.SetDelay(na)
            end
        })
        EggsGroup:AddToggle("AutoEquipBest", {
            Text = "Auto Equip Best",
            Default = false,
            Tooltip = "Uses the game's Equip Best button to put your strongest pets on the treadmill.",
            Callback = function(nc)
                xR.SetEnabled(nc)
            end
        })
        EggsGroup:AddSlider("EquipBestDelay", {
            Text = "Equip Best Delay",
            Default = 12,
            Min = 5,
            Max = 120,
            Rounding = 0,
            Suffix = "s",
            Callback = function(ng)
                xR.SetDelay(ng)
            end
        })
        local VisualsGroup = Nw.Main:AddLeftGroupbox("Visuals", "eye")
        VisualsGroup:AddToggle("EggEsp", {
            Text = "Egg ESP",
            Default = false,
            Tooltip = "Labels every nest egg in the world with its egg type, rarity and distance.",
            Callback = function(nj)
                yC.SetEnabled(nj)
            end
        })
        VisualsGroup:AddDropdown("EspRarities", {
            Text = "ESP Rarities",
            Values = y0,
            Default = {},
            Multi = true,
            AllowNull = true,
            Tooltip = "Leave everything unticked to show every egg.",
            Callback = function(nn)
                yC.SetRarities(nn)
            end
        })
        local MoneyGroup = Nw.Main:AddRightGroupbox("Money", "dollar-sign")
        MoneyGroup:AddToggle("AutoSell", {
            Text = "Auto Sell",
            Default = false,
            Tooltip = "Sells through the sell NPC on a timer.",
            Callback = function(nq)
                y2.SetEnabled(nq)
            end
        })
        MoneyGroup:AddDropdown("SellMode", {
            Text = "Sell Mode",
            Values = yl,
            Default = "Equipped",
            Multi = false,
            Tooltip = "Equipped sells the hatched pets standing on your plot. Inventory sells the eggs and pets in your backpack.",
            Callback = function(nw)
                y2.SetMode(nw)
            end
        })
        MoneyGroup:AddSlider("SellMinimum", {
            Text = "Minimum Items",
            Default = 1,
            Min = 1,
            Max = 30,
            Rounding = 0,
            Tooltip = "Waits until you hold at least this many of the selected items before selling.",
            Callback = function(ny)
                y2.SetMinimum(ny)
            end
        })
        MoneyGroup:AddSlider("SellDelay", {
            Text = "Sell Delay",
            Default = 30,
            Min = 1,
            Max = 300,
            Rounding = 0,
            Suffix = "s",
            Callback = function(nA)
                y2.SetDelay(nA)
            end
        })
        MoneyGroup:AddToggle("SellTeleport", {
            Text = "Travel To Seller",
            Default = true,
            Tooltip = "Teleports you to the sell NPC before selling.",
            Callback = function(nC)
                y2.SetTeleport(nC)
            end
        })
        local UpgradesGroup = Nw.Main:AddRightGroupbox("Upgrades", "trending-up")
        UpgradesGroup:AddToggle("AutoDaily", {
            Text = "Auto Claim Daily",
            Default = false,
            Tooltip = "Claims the daily reward whenever it is available.",
            Callback = function(nF)
                zg.SetEnabled(nF)
            end
        })
        UpgradesGroup:AddToggle("AutoTreadmill", {
            Text = "Auto Upgrade Treadmill",
            Default = false,
            Tooltip = "Buys the next treadmill as soon as you can afford it.",
            Callback = function(nJ)
                yS.SetEnabled(nJ)
            end
        })
        UpgradesGroup:AddToggle("AutoSlots", {
            Text = "Auto Buy Pet Slots",
            Default = false,
            Tooltip = "Buys the next plot slot as soon as you can afford it.",
            Callback = function(nN)
                yK.SetEnabled(nN)
            end
        })
        UpgradesGroup:AddDivider("Trails")
        UpgradesGroup:AddToggle("AutoTrails", {
            Text = "Auto Buy Trails",
            Default = false,
            Tooltip = "Buys unowned trails with cash, cheapest first.",
            Callback = function(nR)
                zc.SetEnabled(nR)
            end
        })
        UpgradesGroup:AddDropdown("TrailTargets", {
            Text = "Trails",
            Values = Nu,
            Default = {},
            Multi = true,
            AllowNull = true,
            Tooltip = "Leave everything unticked to buy every trail you can afford.",
            Callback = function(nW)
                zc.SetTargets(nW)
            end
        })
        UpgradesGroup:AddToggle("TrailEquip", {
            Text = "Equip Fastest Trail",
            Default = true,
            Tooltip = "Equips the fastest trail you own after buying.",
            Callback = function(nY)
                zc.SetEquip(nY)
            end
        })
        oh = task.spawn(function()
            while not Library.Unloaded do
                pcall(function()
                    local Jb_1
                    local Ja_1
                    Ja_1, Jb_1 = yq()
                    local Jc = State.PlotCapacity or 0
                    local Jc_1 = string.format("Plot %d/%d  |  Eggs %d  |  Pets %d", #Ja_1 + #Jb_1, Jc, #Ja_1, #Jb_1)
                    Label:SetText(Jc_1 .. "  |  " .. tostring(State.Status))
                end)
                local Jj = false
                repeat
                    local Jf
                    if State.Notifications and #State.Notifications > 0 then
                        Jf = table.remove(State.Notifications, 1)
                        pcall(function()
                            Library:Notify(Jf.text, Jf.time)
                        end)
                    else
                        Jj = true
                    end
                until Jj
                task.wait(0.3)
            end
        end)
        yE.Track(function()
            local Jn = if coroutine.status(oh) ~= "dead" then 1 else 0
            if Jn == 1 then
                pcall(task.cancel, oh)
            end
        end)
    end
    NF()
    local function NE_2()
        local JJ
        local JE
        local JC
        local JH
        JC = nil
        JE = nil
        JH = nil
        JJ = nil
        local Label3, Label2, JD, JF, Label, JI, JK, JL, JM
        JE = function(on)
            return (tostring(on):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
        end
        JJ = function(op, oq)
            return string.format('<font color="%s">%s</font>', oq, JE(op))
        end
        JD = function(ov, ow, ox)
            return string.format("<b>%s</b> %s %s", ov, JJ("-", "#5a6070"), JJ(ow, ox))
        end
        local JN = "#6ec1ff"
        local JO = "#8b93a3"
        JL = "#7fd47f"
        JK = "#e8a34d"
        local JP = {}
        if not x8(fireproximityprompt) then
            table.insert(JP, "stealing")
        end
        if not yD("RequestHatch", "RemoteEvent") then
            table.insert(JP, "hatching")
        end
        if not yD("DropEgg", "RemoteEvent") then
            table.insert(JP, "placing")
        end
        local JV = if not yD("ClaimDailyReward", "RemoteFunction") then 1 else 0
        if JV == 1 then
            table.insert(JP, "daily rewards")
        end
        local JY = if not yD("TrailAction", "RemoteEvent") then 1 else 0
        if JY == 1 then
            table.insert(JP, "trails")
        end
        local JQ = not yD("RequestTreadmillUpgrade", "RemoteFunction")
        local JY_1 = if JQ then 1 else 0
        local JW = 437 * JY_1 + 2265 * (1 - JY_1)
        local JX = 1163 * JY_1 + 2739 * (1 - JY_1)
        if not ((JW * 1061 + JX * 2582 + JW * JX) % 16777213 == 3974754) then
            JQ = not yD("RequestPlotUpgrade", "RemoteFunction")
        end
        if JQ then
            table.insert(JP, "upgrades")
        end
        local JY_2 = if not yD("RequestSell", "RemoteEvent") then 1 else 0
        if JY_2 == 1 then
            table.insert(JP, "selling")
        end
        local JQ_1 = #JP == 0 and "ready"
        local JR = JQ_1 or "limited: " .. table.concat(JP, ", ")
        JM = "Unknown"
        pcall(function()
            local Jp_1
            local Jo_1
            if x8(identifyexecutor) then
                Jp_1, Jo_1 = identifyexecutor()
                local Jq = Jp_1 ~= ""
                local Jr = type(Jp_1) == "string" and Jq
                if Jr then
                    local Jq_1 = type(Jo_1) == "string" and Jo_1 ~= "" and Jp_1 .. " " .. Jo_1
                    JM = Jq_1 or Jp_1
                end
            end
        end)
        JC = os.clock()
        JI = function()
            local Jt = math.floor(os.clock() - JC)
            if Jt < 60 then
                return Jt .. "s"
            elseif Jt < 3600 then
                return string.format("%dm %ds", math.floor((Jt) / (60)), Jt % 60)
            else
                return string.format("%dh %dm", math.floor((Jt) / (3600)), math.floor((Jt % 3600) / (60)))
            end
        end
        local UserGroup = Nw.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(JD("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, JL), true)
        UserGroup:AddLabel(JD("UserId", tostring(LocalPlayer.UserId), JN), true)
        UserGroup:AddLabel(JD("Executor", JM .. "  " .. JR, JL), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(JD("Session", JI(), JK), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                NA(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                NA("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = Nw.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(JD("Game", Np, JN), true)
        Label2 = SessionGroup:AddLabel(JD("Players", "0/0", JL), true)
        JF = tostring(game.JobId)
        local JN_1 = #JF > 18 and string.sub(JF, 1, 18) .. "..."
        local JQ_3 = JN_1 or JF
        SessionGroup:AddLabel(JD("Job", JQ_3, JO), true)
        Label = SessionGroup:AddLabel(JD("Ping", "0 ms", JK), true)
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
                NA(JF, "Copied Job ID")
            end
        })
        JH = task.spawn(function()
            local Jw_1
            local Jv_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(JD("Session", JI(), JK))
                Label2:SetText(JD("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), JL))
                Jv_1, Jw_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local Jv_2 = Jv_1 and Jw_1 .. " ms" or "n/a"
                Label:SetText(JD("Ping", Jv_2, JK))
            end
        end)
        yE.Track(function()
            if coroutine.status(JH) ~= "dead" then
                task.cancel(JH)
            end
        end)
        local SocialsGroup = Nw.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                NA(Ns, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                NA(Nx, "Copied website link")
            end
        })
    end
    NE_2()
    local function NE_3()
        local pN
        local pL
        local pO
        local pM
        local MovementGroup = Nw.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = Nw.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        local pK = {}
        pN = {}
        pM = {}
        pL = {}
        pO = {}
        local function pP()
            for k, v in pL do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(pL)
        end
        local function pT()
            for k, v in pM do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(pM)
        end
        local function pX()
            for k, v in pN do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(pN)
        end
        local function p0(p1)
            local Km = if not p1:IsA("ProximityPrompt") then 1 else 0
            if Km == 1 then
                return
            end
            if pO[p1] == nil then
                pO[p1] = {
                    HoldDuration = p1.HoldDuration,
                    MaxActivationDistance = p1.MaxActivationDistance,
                    RequiresLineOfSight = p1.RequiresLineOfSight
                }
            end
            p1.HoldDuration = 0
            p1.MaxActivationDistance = 50
            p1.RequiresLineOfSight = false
        end
        local function p3()
            for k, v in pO do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(pO)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                pX()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                pT()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                pP()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                    pcall(p0, v)
                end
            else
                p3()
            end
        end)
        table.insert(pK, Workspace.DescendantAdded:Connect(function(qm)
            if Toggles.InstantProximityPrompt.Value then
                p0(qm)
            end
        end))
        table.insert(pK, RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if pL[v] == nil then
                        pL[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(pK, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local KV = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and KV then
                KV:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(pK, RunService.RenderStepped:Connect(function(qI)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local K0 = Character and Character:FindFirstChildOfClass("Humanoid")
            local K1 = Character
            if K1 then
                K1 = Character:FindFirstChild("HumanoidRootPart")
            end
            local K__1 = K1
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and K0 then
                if pM[K0] == nil then
                    pM[K0] = K0.WalkSpeed
                end
                K0.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and K__1 and K0 and CurrentCamera then
                if pN[K0] == nil then
                    pN[K0] = K0.PlatformStand
                end
                K0.PlatformStand = true
                local K1_4 = Vector3.zero
                if not UserInputService:GetFocusedTextBox() then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        K1_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        K1_4 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        K1_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        K1_4 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        K1_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        K1_4 -= Vector3.new(0, 1, 0)
                    end
                end
                K__1.AssemblyLinearVelocity = Vector3.zero
                if K1_4.Magnitude > 0 then
                    K__1.CFrame = K__1.CFrame + K1_4.Unit * Options.FlySpeed.Value * qI
                end
            end
        end))
        yE.Track(function()
            for k, v in pK do
                v:Disconnect()
            end
            pP()
            pT()
            pX()
            p3()
        end)
    end
    NE_3()
    local function NE_4()
        local L5, L6, L7, L8, L9, Ma, Mb, Mc, Md, Me, Mf, Mg, Label, Mi
        Mi = {}
        Mc = {}
        L9 = nil
        L6 = 0
        Ma = 0
        Me = false
        Mf = os.clock()
        local MenuGroup = Nw.Settings:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        L7 = function()
            local CurrentCamera
            CurrentCamera = Workspace.CurrentCamera
            local Lg = not CurrentCamera or not x8(VirtualUser.CaptureController) or not x8(VirtualUser.ClickButton2)
            if Lg then
                return false
            end
            local Lg_1 = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            end)
            if not Lg_1 then
                return false
            end
            Ma += 1
            Mf = os.clock()
            pcall(function()
                Label:SetText("AFK triggers: " .. Ma)
            end)
            return true
        end
        Mg = function(rr)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not rr)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not rr
                end
            end)
            if not rr then
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
        Md = function(rH)
            if rH.ClassName == "ParticleEmitter" or rH.ClassName == "Trail" or rH.ClassName == "Smoke" or rH.ClassName == "Fire" or rH.ClassName == "Sparkles" or rH.ClassName == "Explosion" or rH.ClassName == "Beam" then
                if Mi[rH] == nil then
                    Mi[rH] = rH.Enabled
                end
                pcall(function()
                    rH.Enabled = false
                end)
            end
        end
        Mb = function()
            for k, v in Mi do
                local Lv = k
                local Lx = v
                if Lv.Parent then
                    pcall(function()
                        Lv.Enabled = Lx
                    end)
                end
            end
            table.clear(Mi)
            if L9 then
                pcall(function()
                    settings().Rendering.QualityLevel = L9.Quality
                end)
                Lighting.GlobalShadows = L9.Shadows
                Lighting.FogEnd = L9.Fog
                L9 = nil
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(rW)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not rW)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(r0)
                if r0 then
                    if not L9 then
                        L9 = {
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
                        pcall(Md, v)
                    end
                else
                    Mb()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        Mg(true)
        local ScriptGroup = Nw.Settings:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiGameplayPause:OnChanged(function()
            Mg(Toggles.AntiGameplayPause.Value)
        end)
        if Toggles.AntiGameplayPause.Value then
            Mg(true)
        end
        table.insert(Mc, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                L7()
            end
        end))
        table.insert(Mc, Workspace.DescendantAdded:Connect(function(sj)
            if Toggles.FpsBoost.Value then
                Md(sj)
            end
        end))
        L8 = function(sn)
            if Me or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            Me = true
            local LK = L6
            local LL_1 = pcall(function()
                if sn then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not LL_1 then
                Me = false
                if not sn and LK == L6 then
                    task.delay(1.5, function()
                        if LK == L6 then
                            L8(true)
                        end
                    end)
                end
            end
        end
        table.insert(Mc, TeleportService.TeleportInitFailed:Connect(function(sF)
            local LP
            if sF == LocalPlayer and Me then
                Me = false
                LP = L6
                task.delay(3, function()
                    if LP == L6 then
                        L8(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local LU = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            if Library.Unloaded or not LU then
                return
            end
            table.insert(Mc, LU.ChildAdded:Connect(function(sU)
                if sU.Name == "ErrorPrompt" then
                    L8(false)
                end
            end))
        end)
        L5 = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    Mg(true)
                end
                local LX = Toggles.AntiAfk.Value and os.clock() - Mf >= 60
                if LX then
                    L7()
                end
                task.wait(1)
            end
        end)
        yE.Track(function()
            L6 += 1
            for k, v in Mc do
                v:Disconnect()
            end
            pcall(task.cancel, L5)
            Mg(false)
            Mb()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    NE_4()
    local function NE_5()
        local Nd, Ne, Nf, Ng
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("TempoHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(Nw.Settings)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/SquishyDumplings")
        local Nh = SaveManager:BuildConfigSection(Nw.Settings)
        Ng = function(tk, tl)
            local Mm_1 = (tk == "Toggle" and Toggles or Options)[tl]
            local Ml_2 = type(Mm_1) == "table" and Mm_1.Type == tk
            return Ml_2 and Mm_1 or nil
        end
        Ne = function(tu, tv)
            local Type = tv.Type
            if Type == "Toggle" then
                return { idx = tu, type = "Toggle", value = tv.Value == true }
            elseif Type == "Slider" then
                return { idx = tu, type = "Slider", value = tostring(tv.Value) }
            elseif Type == "Dropdown" then
                return { idx = tu, type = "Dropdown", multi = tv.Multi == true, value = tv.Value }
            elseif Type == "Input" then
                local Mq = tv.Value or ""
                return { idx = tu, type = "Input", text = tostring(Mq) }
            elseif Type == "ColorPicker" then
                return { idx = tu, type = "ColorPicker", value = tv.Value:ToHex(), transparency = tv.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = tu,
                    type = "KeyPicker",
                    mode = tv.Mode,
                    key = tv.Value,
                    modifiers = tv.Modifiers,
                    toggled = tv.Toggled
                }
            else
                return nil
            end
        end
        Nd = function()
            local Mw = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local Mx = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if Mx then
                        local Mx_1 = Ne(k, v)
                        if Mx_1 then
                            Mw[#Mw + 1] = Mx_1
                        end
                    end
                end
            end
            table.sort(Mw, function(tF, tG)
                if tF.type ~= tG.type then
                    return tF.type < tG.type
                end
                return tF.idx < tG.idx
            end)
            return { objects = Mw }
        end
        Nf = function(tI)
            local MN
            MN = nil
            local MO = type(tI) ~= "table" or type(tI.idx) ~= "string" or type(tI.type) ~= "string" or SaveManager.Ignore[tI.idx]
            if MO then
                return false
            end
            MN = Ng(tI.type, tI.idx)
            if not MN then
                return false
            end
            local MO_1 = pcall(function()
                if tI.type == "Input" then
                    if type(tI.text) ~= "string" then
                        return
                    end
                    MN:SetValue(tI.text)
                elseif tI.type == "ColorPicker" then
                    MN:SetValueRGB(Color3.fromHex(tI.value), tI.transparency)
                elseif tI.type == "KeyPicker" then
                    MN:SetValue({ tI.key, tI.mode, tI.modifiers })
                    if tI.mode == "Toggle" and tI.toggled ~= nil then
                        MN.Toggled = tI.toggled
                        MN:Update()
                    end
                else
                    MN:SetValue(tI.value)
                end
            end)
            return MO_1
        end
        Nh:AddDivider()
        Nh:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        Nh:AddButton("Export Config to Clipboard", function()
            local MR_1
            local MQ_1
            MQ_1, MR_1 = pcall(HttpService.JSONEncode, HttpService, Nd())
            if MQ_1 then
                local MQ_2 = x8(setclipboard) and setclipboard
                local MS = MQ_2
                local M_ = if MS then 1 else 0
                local MY = 349 * M_ + 4071 * (1 - M_)
                local MZ = 179 * M_ + 1055 * (1 - M_)
                if not ((MY * 3474 + MZ * 949 + MY * MZ) % 16777213 == 1444768) then
                    local MQ_3 = x8(toclipboard) and toclipboard
                    MS = MQ_3 or nil
                end
                local MQ_4 = MS
                local MS_1 = type(MQ_4) == "function" and pcall(MQ_4, MR_1)
                if MS_1 then
                    Library:Notify("Config copied to clipboard", 6)
                    return
                end
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Failed to encode the config")
        end)
        Nh:AddButton("Import Config from Clipboard Text", function()
            local M2_1
            local M0 = Options.SaveManager_ImportSource.Value or ""
            local M0_1
            local M1 = tostring(M0):match("^%s*(.-)%s*$")
            if M1 == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            if #M1 > 262144 then
                Library:Notify("That config is too large")
                return
            end
            M0_1, M2_1 = pcall(HttpService.JSONDecode, HttpService, M1)
            local M1_1 = not M0_1 or type(M2_1) ~= "table" or type(M2_1.objects) ~= "table"
            if M1_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            if #M2_1.objects > 2048 then
                Library:Notify("That config has too many records")
                return
            end
            local M0_2 = 0
            for i, v in ipairs(M2_1.objects) do
                if Nf(v) then
                    M0_2 += 1
                end
            end
            if M0_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local M2_2 = M0_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(M0_2, M2_2), 6)
        end)
        ThemeManager:LoadDefault()
        SaveManager:LoadAutoloadConfig()
        if Options.StealDelay then
            yd.SetDelay(Options.StealDelay.Value)
        end
        if Options.StealZones then
            yd.SetZones(Options.StealZones.Value, Ny)
        end
        if Options.StealRarities then
            yd.SetRarities(Options.StealRarities.Value)
        end
        if Options.PlaceRarities then
            x3.SetRarities(Options.PlaceRarities.Value)
        end
        if Options.PlaceDelay then
            x3.SetDelay(Options.PlaceDelay.Value)
        end
        if Options.HatchDelay then
            xZ.SetDelay(Options.HatchDelay.Value)
        end
        if Options.EquipBestDelay then
            xR.SetDelay(Options.EquipBestDelay.Value)
        end
        if Options.EspRarities then
            yC.SetRarities(Options.EspRarities.Value)
        end
        if Options.SellMode then
            y2.SetMode(Options.SellMode.Value)
        end
        if Options.SellMinimum then
            y2.SetMinimum(Options.SellMinimum.Value)
        end
        if Options.SellDelay then
            y2.SetDelay(Options.SellDelay.Value)
        end
        if Toggles.SellTeleport then
            y2.SetTeleport(Toggles.SellTeleport.Value)
        end
        if Options.TrailTargets then
            zc.SetTargets(Options.TrailTargets.Value)
        end
        if Toggles.TrailEquip then
            zc.SetEquip(Toggles.TrailEquip.Value)
        end
        if Toggles.AutoSteal then
            yd.SetEnabled(Toggles.AutoSteal.Value)
        end
        if Toggles.AutoPlace then
            x3.SetEnabled(Toggles.AutoPlace.Value)
        end
        if Toggles.AutoHatch then
            xZ.SetEnabled(Toggles.AutoHatch.Value)
        end
        if Toggles.AutoEquipBest then
            xR.SetEnabled(Toggles.AutoEquipBest.Value)
        end
        if Toggles.EggEsp then
            yC.SetEnabled(Toggles.EggEsp.Value)
        end
        if Toggles.AutoSell then
            y2.SetEnabled(Toggles.AutoSell.Value)
        end
        if Toggles.AutoDaily then
            zg.SetEnabled(Toggles.AutoDaily.Value)
        end
        if Toggles.AutoTrails then
            zc.SetEnabled(Toggles.AutoTrails.Value)
        end
        if Toggles.AutoTreadmill then
            yS.SetEnabled(Toggles.AutoTreadmill.Value)
        end
        if Toggles.AutoSlots then
            yK.SetEnabled(Toggles.AutoSlots.Value)
        end
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    NE_5()
end
NV_5()
end)(...)

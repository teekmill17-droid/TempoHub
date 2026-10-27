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
getgenv().TempoHoodSubtitle = "KAWAII ANIME RNG"
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
local q8_1, GameInfoGroup, q8_9
local lM
local kM
local BuyDice
local Toggles
local FoodCart
local lz
local kz
local lg
local kY
local lF
local lm
local Options
local Merchant2
local kL
local ls
local k9
local ly
local SkillTree2
local Index
local EquipBest
local Wheel2
local kE
local ll
local VirtualUser
local BuyPotion
local lQ
local Wheel
local lx
local kx
local le
local kW
local Rolling
local Library
local Rebirth
local lJ
local kJ
local lq
local k7
local lP
local lw
local Eggs
local ld
local Merchant
local lC
local kC
local OfflineEarnings
local k0
local lp
local k6
local RebirthHandler
local kO
local lv
local kv
local kU
local lB
local kB
local li
local k_
local FoodCart2
local kH
local connection
local k5
local lN
local kN
local lu
local lb
local kT
local lA
local kA
local lh
local kZ
local LocalPlayer
local kG
local SkillTree
local connection2
local function fn37()
    kY(lA, "Copied Discord invite to clipboard")
end
local function fn97()
    local _NodeData = SkillTree2._NodeData
    if type(_NodeData) ~= "table" then
        return {}
    end
    local oE = {}
    for k, v in pairs(_NodeData) do
        if lx(k, v) then
            local oD_1 = SkillTree2.Prices and SkillTree2.Prices[k]
            local oF = oD_1
            if oD_1 then
                oD_1 = oF[1]
            end
            local oG = oF
            local oH = oD_1
            if oG then
                oG = tonumber(oF[2])
            end
            local oD_2 = oG or 0
            local insert = table.insert
            local oI_1 = oH == nil or oH == "N/A" or oD_2 <= 0 or k == lh or k == ld
            insert(oE, { id = k, currency = oH, cost = oD_2, free = oI_1 })
        end
    end
    table.sort(oE, function(dy, dz)
        if dy.free ~= dz.free then
            return dy.free
        elseif dy.cost == dz.cost then
            return dy.id < dz.id
        else
            return dy.cost < dz.cost
        end
    end)
    return oE
end
local function worker12()
    while not Library.Unloaded do
        if lq("AutoEquipBest") then
            pcall(lN)
        end
        task.wait(k5("EquipBestDelay", 3))
    end
end
local function worker6()
    while not Library.Unloaded do
        if lq("AutoRebirth") then
            pcall(kU)
        end
        task.wait(k5("RebirthDelay", 2))
    end
end
local function fn111(a2)
    local m9 = kT(a2)
    if not m9 then
        return false
    end
    local Character = LocalPlayer.Character
    local nb = Character and Character:FindFirstChild("HumanoidRootPart")
    if not nb then
        return false
    end
    if (nb.Position - m9).Magnitude > 12 then
        lm(m9)
        task.wait(0.35)
    end
    return true
end
local function fn112()
    if not lJ("Shop") then
        return
    end
    BuyDice:FireServer("RequestShop")
    task.wait(0.25)
    BuyDice:FireServer("BuyBestAvailable")
end
local function onUnload()
    Library:Unload()
end
local function fn136()
    local n0 = LocalPlayer:GetAttribute("OfflineEarningsVisible") == true
    local n7 = if n0 then 1 else 0
    local n5 = 3954 * n7 + 1326 * (1 - n7)
    local n6 = 512 * n7 + 3315 * (1 - n7)
    if not ((n5 * 3693 + n6 * 3776 + n5 * n6) % 16777213 == 1782669) then
        n0 = LocalPlayer:GetAttribute("OfflineEarningsPending") == true
    end
    if n0 then
        pcall(function()
            OfflineEarnings:FireServer("Claim")
        end)
    end
    local n0_1 = k9()
    if not n0_1 then
        return
    end
    local Character = LocalPlayer.Character
    local n2 = Character and Character:FindFirstChild("HumanoidRootPart")
    if not n2 then
        return
    end
    for i, descendant in n0_1:GetDescendants() do
        local n0_2 = descendant.Name == "Collector" and descendant:IsA("BasePart") and descendant.CanTouch
        if n0_2 then
            local n0_3 = descendant:FindFirstChild("FrameTag") and descendant.FrameTag:FindFirstChild("Frame") and descendant.FrameTag.Frame:FindFirstChild("Amount")
            local n2_1 = n0_3
            if n0_3 then
                local n3 = tonumber(n2_1:GetAttribute("money")) or 0
                n0_3 = n3
            end
            if (n0_3 or 0) > 0 then
                if firetouchinterest then
                    pcall(firetouchinterest, descendant, n2, 0)
                    pcall(firetouchinterest, descendant, n2, 1)
                else
                    n2.CFrame = descendant.CFrame + Vector3.new(0, 3, 0)
                end
                task.wait(0.05)
            end
        end
    end
end
local function worker13()
    while not Library.Unloaded do
        if lq("AutoEquipSort") then
            pcall(ll)
        end
        task.wait(k5("EquipSortDelay", 3))
    end
end
local function worker9()
    while not Library.Unloaded do
        if lq("AutoBuyMerchant") then
            pcall(kx)
        end
        if lq("AutoBuyFoodCart") then
            pcall(lu)
        end
        task.wait(k5("MerchantDelay", 10))
    end
end
local function worker4()
    while not Library.Unloaded do
        if lq("AutoCollectMoney") then
            pcall(kM)
        end
        task.wait(k5("CollectDelay", 0.75))
    end
end
local function fn211(bk)
    local nk = li(bk)
    if not nk then
        return false
    end
    local Character = LocalPlayer.Character
    local nm = Character and Character:FindFirstChild("HumanoidRootPart")
    if not nm then
        return false
    end
    if (nm.Position - nk.Position).Magnitude > 10 then
        lm(nk.Position)
        task.wait(0.35)
    end
    return true
end
local function fn246(ar, as)
    local mF = Options[ar]
    local mG = mF and tonumber(mF.Value)
    return mG or as
end
local function fn294(bb)
    local ng = lz[bb]
    if not ng then
        return nil
    end
    local nh = Eggs.InteractionByIndex and Eggs.InteractionByIndex[ng]
    if type(nh) ~= "table" then
        return nil
    end
    local Proximity = nh.Proximity
    local ni = typeof(Proximity) == "Instance" and Proximity:IsA("BasePart")
    if ni then
        return Proximity, nh
    end
    return nil, nh
end
local function onCopyJoinScript_JobID()
    local f4 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, kW)
    kY(f4, "Copied join script to clipboard")
end
local function worker3()
    while not Library.Unloaded do
        if lq("AutoRoll") then
            pcall(kz, true)
        end
        task.wait(1)
    end
end
local function fn325()
    local result2 = Wheel:InvokeServer("GetState")
    if type(result2) ~= "table" then
        return
    end
    local pD = tonumber(result2.NextFreeAt) or 0
    local pE = tonumber(result2.ServerTime) or 0
    if pD - pE > 0 then
        return
    end
    if not lg() then
        return
    end
    Wheel:InvokeServer("ClaimFree")
    task.wait(0.35)
    local result = Wheel:InvokeServer("Spin")
    local pD_1 = type(result) == "table" and result.Success
    if pD_1 then
        task.wait(0.35)
        Wheel:InvokeServer("FinishSpin")
    end
end
local function fn328(T, U)
    if setclipboard then
        setclipboard(T)
    elseif toclipboard then
        toclipboard(T)
    end
    Library:Notify(U)
end
local function onInputBegan()
    kv = tick()
end
local function fn359(cT, cU)
    local og = os.clock()
    local oi = og + (cU or 1.5)
    while true do
        if not (os.clock() < oi) then
            return kZ(cT)
        end
        if kZ(cT) then
            break
        end
        task.wait(0.05)
    end
    return true
end
local function worker2()
    while not Library.Unloaded do
        task.wait(2)
        if lq("AntiAfk") then
            local qN = tick() - kv
            local qO = tick() - lQ
            if qN >= 300 and qO >= 60 then
                pcall(lB)
            else
                if qN < 300 and qO >= 300 then
                    pcall(lB)
                end
            end
        end
    end
end
local function onRemoveHatchAnimation(gs)
    kC(gs)
end
local function worker11()
    while not Library.Unloaded do
        if lq("AutoClaimIndex") then
            pcall(lw)
        end
        task.wait(k5("IndexDelay", 5))
    end
end
local function fn394()
    FoodCart:FireServer("Request")
    task.wait(0.3)
    for k in FoodCart2.Catalog do
        local pp = tonumber(FoodCart2.Stock[k]) or 0
        if pp > 0 then
            FoodCart:FireServer("BuyAll", k)
            task.wait(0.1)
        end
    end
end
local function fn398()
    if not lJ("PotionShop") then
        return
    end
    BuyPotion:FireServer("RequestShop")
    task.wait(0.25)
    BuyPotion:FireServer("BuyBestAvailable")
end
local function onInputChanged(gJ)
    local UserInputType = gJ.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        kv = tick()
    end
end
local function fn449()
    local pL_1
    local pK_1
    local pJ = Eggs.MaxOpenAmount
    if type(Eggs.GetMaxOpenAmount) == "function" then
        pK_1, pL_1 = pcall(function()
            return Eggs:GetMaxOpenAmount()
        end)
        local pM_1 = pK_1 and type(pL_1) == "number"
        if pM_1 then
            pJ = pL_1
        end
    end
    local max = math.max
    local floor = math.floor
    local pM_2 = tonumber(pJ) or 1
    return max(1, floor(pM_2))
end
local function fn452()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    lQ = tick()
end
local function fn458()
    local qr_1
    local qq_1
    if identifyexecutor then
        qr_1, qq_1 = identifyexecutor()
        local qs = qr_1 ~= ""
        local qt = type(qr_1) == "string" and qs
        if qt then
            local qs_1 = type(qq_1) == "string" and qq_1 ~= "" and qr_1 .. " " .. qq_1
            ls = qs_1 or qr_1
        end
    end
end
local function fn463()
    EquipBest:FireServer()
end
local function worker8()
    while not Library.Unloaded do
        if lq("AutoHatchEggs") then
            pcall(lp)
            local qZ = lM - os.clock()
            if qZ > 0 then
                task.wait(qZ)
            else
                task.wait(0.05)
            end
        else
            task.wait(0.25)
        end
    end
end
local function fn489(dB)
    if kZ(dB) then
        return true
    end
    SkillTree:FireServer("Purchase", dB)
    if kO(dB, 1.5) then
        return true
    end
    k6[dB] = true
    return false
end
local function fn492()
    local nB_1
    local nA_1
    if Rolling.Hiding then
        return
    end
    local nz = true
    if type(Rolling.CanAutoHideDice) == "function" then
        nA_1, nB_1 = pcall(function()
            return Rolling:CanAutoHideDice()
        end)
        nz = nA_1 and nB_1 == true
    end
    if not nz then
        return
    end
    if type(Rolling.HideCall) == "function" then
        pcall(function()
            Rolling:HideCall()
        end)
    elseif type(Rolling.HideButton) == "function" then
        pcall(function()
            Rolling:HideButton()
        end)
    end
end
local function fn520(aM)
    local Character = LocalPlayer.Character
    local mY = Character and Character:FindFirstChild("HumanoidRootPart")
    local mX_1 = mY
    if mY then
        mY = typeof(aM) == "Vector3"
    end
    if not mY then
        return false
    end
    mX_1.CFrame = CFrame.new(aM + Vector3.new(0, 4, 0))
    return true
end
local function fn546()
    pcall(function()
        Index:FireServer("ClaimAll")
    end)
end
local function fn547()
    local o8 = kH("SelectedDice", "Bronze")
    if not lJ("Shop") then
        return
    end
    BuyDice:FireServer("RequestShop")
    task.wait(0.25)
    BuyDice:FireServer("BuyAll", o8)
end
local function fn555(aT)
    local m_ = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("MapShop")
    local m0 = m_
    if m_ then
        m_ = m0:FindFirstChild(aT)
    end
    local m0_1 = m_
    if not m0_1 then
        return nil
    end
    local m__1 = m0_1:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not m__1 then
        return nil
    end
    local Parent = m__1.Parent
    local m__2 = Parent and Parent:IsA("BasePart")
    if m__2 then
        return Parent.Position
    end
    local m__3 = m0_1:FindFirstChildWhichIsA("Model", true)
    if m__3 then
        return m__3:GetPivot().Position
    end
    return nil
end
local function fn573(aa, ab)
    return string.format('<font color="%s">%s</font>', ab, aa)
end
local function fn603()
    pcall(function()
        RebirthHandler:RequestAvailability()
    end)
    task.wait(0.35)
    pcall(function()
        RebirthHandler:UpdateRebirthButton()
    end)
    if RebirthHandler.IsMax then
        return
    end
    local qn = RebirthHandler.Alert and RebirthHandler.Alert.Visible
    local qo = qn or lF()
    if qo then
        Rebirth:FireServer()
    end
end
local function onAutoRoll(gm)
    kz(gm)
end
local function fn642()
    local pb = lC("MerchantCategories")
    Merchant:FireServer("Request")
    task.wait(0.3)
    if not Merchant2.IsActive then
        return
    end
    for k, v in Merchant2.Catalog do
        local pc = Merchant2.Stock[k]
        local pd = pb[k] and type(v) == "table" and type(pc) == "table"
        if pd then
            for k2 in v do
                local pd_1 = tonumber(pc[k2]) or 0
                if pd_1 > 0 then
                    Merchant:FireServer("BuyAll", k, k2)
                    task.wait(0.1)
                end
            end
        end
    end
end
local function worker()
    local qz_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local qy = math.floor(os.clock() - kB)
        if qy < 60 then
            qz_1 = qy .. "s"
        elseif qy < 3600 then
            qz_1 = string.format("%dm %ds", math.floor((qy) / (60)), qy % 60)
        else
            qz_1 = string.format("%dh %dm", math.floor((qy) / (3600)), math.floor((qy % 3600) / (60)))
        end
        k_:SetText(lP("Session time", qz_1, lv))
    end
end
local function fn698()
    pcall(function()
        SkillTree:FireServer("RequestSync")
    end)
    task.wait(0.3)
    local oS = 0
    local oZ = 1
    while oZ <= 60 do
        local oT = kE()
        if #oT == 0 then
            break
        end
        local oU = false
        for i, v in ipairs(oT) do
            local oT_1 = SkillTree2._NodeData and SkillTree2._NodeData[v.id]
            local oV = oT_1
            if oT_1 then
                oT_1 = lx(v.id, oV)
            end
            if oT_1 then
                if k7(v.id) then
                    oS = oS + 1
                    oU = true
                end
                if oS >= 60 then
                    break
                end
            end
        end
        if not oU or oS >= 60 then
            break
        end
        task.wait(0.1)
        oZ += 1
    end
end
local function fn706(aG)
    local mN = Options[aG]
    local mO = mN and mN.Value
    local mO_1 = type(mO) == "table" and mO
    local mN_2 = {}
    local mP = mO_1
    local mW = if mP then 1 else 0
    local mU = 399 * mW + 2571 * (1 - mW)
    local mV = 4076 * mW + 232 * (1 - mW)
    if not ((mU * 3573 + mV * 3191 + mU * mV) % 16777213 == 16058467) then
        mP = mN_2
    end
    return mP
end
local function fn707(fO)
    local DiscordGroup = fO:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = kN })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = kN })
end
local function fn712()
    local WheelAnchor = Wheel2.WheelAnchor
    local pw = typeof(WheelAnchor) == "Instance" and WheelAnchor:IsA("BasePart")
    if not pw then
        return true
    end
    local Character = LocalPlayer.Character
    local px = Character and Character:FindFirstChild("HumanoidRootPart")
    if not px then
        return false
    end
    if (px.Position - WheelAnchor.Position).Magnitude > 15 then
        lm(WheelAnchor.Position)
        task.wait(0.35)
    end
    return true
end
local function worker5()
    while not Library.Unloaded do
        if lq("AutoBuyUpgrades") then
            pcall(kJ)
        end
        task.wait(k5("UpgradeDelay", 1))
    end
end
local function fn775()
    local om_1
    local ol_1
    ol_1, om_1 = pcall(function()
        return LocalPlayer:IsInGroupAsync(lb)
    end)
    return ol_1 and om_1 == true
end
local function fn802(cP)
    return SkillTree2.Owned and SkillTree2.Owned[cP] == true
end
local function fn831(am)
    local mC = Toggles[am]
    return mC ~= nil and mC.Value == true
end
local function fn851()
    local nP = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Plots")
    if not nP then
        return nil
    end
    for i, child in nP:GetChildren() do
        if child:GetAttribute("owner") == LocalPlayer.UserId then
            return child
        end
    end
    return nil
end
local function onRscripts()
    kY(ly, "Copied Rscripts profile to clipboard")
end
local function fn917()
    connection:Disconnect()
    connection2:Disconnect()
    kz(false)
    kC(false)
end
local function worker7()
    while not Library.Unloaded do
        if lq("AutoBuyDice") then
            pcall(le)
        end
        if lq("AutoBuySelectedDice") then
            pcall(k0)
        end
        if lq("AutoBuyPotions") then
            pcall(kL)
        end
        task.wait(k5("ShopDelay", 1))
    end
end
local function worker10()
    while not Library.Unloaded do
        if lq("AutoSpinWheel") then
            pcall(kG)
        end
        task.wait(30)
    end
end
local function fn938(ad, ae, af)
    return string.format("<b>%s</b> %s %s", ad, kA("-", "#5a6070"), kA(ae, af))
end
local function fn950(ax, ay)
    local mI = Options[ax]
    local mJ = mI and mI.Value
    local mJ_1 = mJ ~= ""
    local mL = type(mJ) == "string" and mJ_1
    if mL then
        return mJ
    elseif type(mJ) == "number" then
        local Values = mI.Values
        local mI_1 = type(Values) == "table" and type(Values[mJ]) == "string"
        if mI_1 then
            return Values[mJ]
        end
        return ay
    else
        return ay
    end
end
kv = nil
Eggs = nil
kx = nil
SkillTree2 = nil
kz = nil
kA = nil
kB = nil
kC = nil
Rolling = nil
kE = nil
kG = nil
kH = nil
kJ = nil
kL = nil
kM = nil
kN = nil
kO = nil
Wheel = nil
FoodCart = nil
kT = nil
kU = nil
Merchant = nil
kW = nil
EquipBest = nil
kY = nil
kZ = nil
k_ = nil
k0 = nil
Rebirth = nil
Options = nil
connection2 = nil
k5 = nil
k6 = nil
k7 = nil
k9 = nil
Toggles = nil
lb = nil
ld = nil
le = nil
Index = nil
lg = nil
lh = nil
local kF, kI, IsHugePetCutsceneSkipped, ShowPetRevealResultsWithHugeCutscene, ShowPetRevealResults, k2, Settings, EggInfo
li = nil
OfflineEarnings = nil
Library = nil
ll = nil
lm = nil
SkillTree = nil
connection = nil
lp = nil
lq = nil
BuyPotion = nil
ls = nil
BuyDice = nil
lu = nil
lv = nil
lw = nil
lx = nil
ly = nil
lz = nil
lA = nil
lB = nil
lC = nil
Wheel2 = nil
lF = nil
LocalPlayer = nil
FoodCart2 = nil
lJ = nil
VirtualUser = nil
Merchant2 = nil
lM = nil
lN = nil
RebirthHandler = nil
lP = nil
lQ = nil
local lI, Pets, lS
lI = nil
Pets = nil
lS = nil
local FaqGroup
VirtualUser, LocalPlayer, lA, ly, BuyDice, BuyPotion, SkillTree, OfflineEarnings, Index, EggInfo, Settings, Rebirth, EquipBest, Merchant, FoodCart, Wheel, Rolling, SkillTree2, Eggs, Pets, RebirthHandler, Merchant2, FoodCart2, Wheel2, lz, Library, Toggles, Options, lv, ShowPetRevealResults, ShowPetRevealResultsWithHugeCutscene, IsHugePetCutsceneSkipped, kF, lh, ld, lb, k6, lM, kY, kN, kA, lP, lq, k5, kH, lC, lm, kT, lJ, li, kI, kC, k2, kz, k9, kM, kZ, kO, lS, lx, kE, k7, kJ, le, k0, kL, kx, lu, lg, kG, lI, lp, lw, ll, lN, lF, kU = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local q8_2 = game:GetService("Players")
local q8_3 = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
LocalPlayer = q8_2.LocalPlayer
local mb = "Kawaii Anime RNG"
lA = "https://discord.gg/K7Qxnxkk46"
ly = "https://discord.gg/K7Qxnxkk46"
local q8_6 = q8_3:WaitForChild("Remotes")
BuyDice = q8_6:WaitForChild("BuyDice")
BuyPotion = q8_6:WaitForChild("BuyPotion")
SkillTree = q8_6:WaitForChild("SkillTree")
OfflineEarnings = q8_6:WaitForChild("OfflineEarnings")
Index = q8_6:WaitForChild("Index")
EggInfo = q8_6:WaitForChild("EggInfo")
Settings = q8_6:WaitForChild("Settings")
Rebirth = q8_6:WaitForChild("Rebirth")
EquipBest = q8_6:WaitForChild("EquipBest")
Merchant = q8_6:WaitForChild("Merchant")
FoodCart = q8_6:WaitForChild("FoodCart")
Wheel = q8_6:WaitForChild("Wheel")
local q8_8 = q8_3:WaitForChild("Modules"):WaitForChild("Services")
local q8_10 = q8_8:WaitForChild("UserInterface")
Rolling = require(q8_10:WaitForChild("Rolling"))
SkillTree2 = require(q8_10:WaitForChild("SkillTree"))
Eggs = require(q8_10:WaitForChild("Eggs"))
Pets = require(q8_10:WaitForChild("Pets"))
RebirthHandler = require(q8_10:WaitForChild("RebirthHandler"))
Merchant2 = require(q8_10:WaitForChild("Merchant"))
FoodCart2 = require(q8_10:WaitForChild("FoodCart"))
Wheel2 = require(q8_10:WaitForChild("Wheel"))
local ma = { "Basic", "Forest", "Jungle", "Beach", "Monster", "Desert", "Galaxy", "Candy", "Lava", "Frozen" }
lz = {
    Basic = 1,
    Forest = 2,
    Jungle = 3,
    Beach = 4,
    Monster = 5,
    Desert = 6,
    Galaxy = 7,
    Candy = 8,
    Lava = 9,
    Frozen = 10
}
local l7 = {
    "Bronze",
    "Iron",
    "Silver",
    "Gold",
    "Sapphire",
    "Emerald",
    "Ruby",
    "Obsidian",
    "Crystal",
    "Nebula",
    "Void",
    "Celestial",
    "Abyssal",
    "Infernal",
    "Ethereal",
    "Quantum",
    "Eldritch",
    "Galactic",
    "Sovereign",
    "Arcane",
    "Paradox",
    "Oblivion",
    "Singularity",
    "Omnipotent",
    "Transcendent",
    "Seraphic",
    "Valentine"
}
local l6 = { "Dices", "Potions", "Foods", "Exclusives" }
local l4 = { "Luck", "Cash", "Rarity", "Size", "Mutations", "Favorites" }
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
kY = fn328
kN = fn37
kA = fn573
lP = fn938
local l9 = "#7fd47f"
local l8 = "#6ec1ff"
lv = "#e8a34d"
local l5 = "#8b93a3"
lq = fn831
k5 = fn246
kH = fn950
lC = fn706
if (BuyDice and not q8_6 or Merchant2 and not q8_6) and (Merchant2 and Merchant2 or not BuyDice and not BuyDice) and not ((BuyDice and not q8_6 or Merchant2 and not q8_6) and (Merchant2 and Merchant2 or not BuyDice and not BuyDice)) then
    k0 = fn520
else
    lm = fn520
end
kT = fn555
lJ = fn111
li = fn294
kI = fn211
ShowPetRevealResults = Eggs.ShowPetRevealResults
ShowPetRevealResultsWithHugeCutscene = Eggs.ShowPetRevealResultsWithHugeCutscene
IsHugePetCutsceneSkipped = Eggs.IsHugePetCutsceneSkipped
kF = false
kC = function(bL)
    if bL then
        if kF then
            return
        end
        kF = true
        Eggs.ShowPetRevealResults = function(bP, bQ)
            local nu = typeof(bQ) ~= "table" or #bQ == 0
            if nu then
                return 0.05
            end
            pcall(function()
                bP:ClearPetRevealResults()
            end)
            pcall(function()
                bP:SetOpeningUiSelected(false)
            end)
            return 0.05
        end
        Eggs.ShowPetRevealResultsWithHugeCutscene = function(bU, bV, bW)
            local nw = bU:ShowPetRevealResults(bV)
            if type(bW) == "function" then
                task.defer(bW)
            end
            return nw
        end
        Eggs.IsHugePetCutsceneSkipped = function()
            return true
        end
        pcall(function()
            Settings:FireServer("Skip-Cutscene", "HolyRollAnimation", true)
        end)
    else
        if not kF then
            return
        end
        kF = false
        Eggs.ShowPetRevealResults = ShowPetRevealResults
        Eggs.ShowPetRevealResultsWithHugeCutscene = ShowPetRevealResultsWithHugeCutscene
        Eggs.IsHugePetCutsceneSkipped = IsHugePetCutsceneSkipped
    end
end
k2 = fn492
kz = function(b8)
    if b8 then
        if not Rolling.AutoRolling then
            local nJ_1 = Rolling.AutoRoll
            if not nJ_1 then
                local nK_1 = Rolling.MainFrame and Rolling.MainFrame:FindFirstChild("AutoRoll")
                nJ_1 = nK_1
            end
            local nI = nJ_1
            if nI then
                pcall(function()
                    Rolling:AutoRollCall(nI)
                end)
            end
        end
        if Rolling.AutoRolling and not Rolling.Playing then
            pcall(function()
                Rolling:Start()
            end)
        end
        if Rolling.AutoRolling then
            k2()
        end
    else
        local nJ_3 = Rolling.AutoRolling
        if not nJ_3 then
            local nK_2 = Rolling.IsAutoUseDiceRunning and Rolling:IsAutoUseDiceRunning()
            nJ_3 = nK_2
        end
        if nJ_3 then
            if Rolling.StopAutoRoll then
                pcall(function()
                    Rolling:StopAutoRoll()
                end)
            else
                Rolling.AutoRolling = false
            end
        end
    end
end
k9 = fn851
kM = fn136
lh = "Mutations/Player/Group"
ld = "Mutations/Player/Like"
lb = 326703534
k6 = {}
kZ = fn802
kO = fn359
lS = fn775
lx = function(c4, c5)
    local ot_1
    if k6[c4] then
        return false
    end
    local oq = type(c4) ~= "string" or c4 == "__Back__" or type(c5) ~= "table"
    local oq_1
    if oq then
        return false
    elseif c5.Info ~= "Unlock" then
        return false
    elseif kZ(c4) then
        return false
    elseif type(SkillTree2._IsPurchasableNode) ~= "function" then
        return false
    else
        oq_1, ot_1 = pcall(function()
            return SkillTree2:_IsPurchasableNode(c4, c5)
        end)
        if not (oq_1 and ot_1) then
            return false
        end
        local oq_2 = c4 == lh and not lS()
        if oq_2 then
            k6[c4] = true
            return false
        end
        return true
    end
end
kE = fn97
k7 = fn489
kJ = fn698
le = fn112
k0 = fn547
kL = fn398
kx = fn642
lu = fn394
lg = fn712
kG = fn325
lM = 0
lI = fn449
lp = function()
    local pO, pP, result
    local pR = os.clock()
    if pR < lM then
        return
    end
    if Eggs.EggBuyInFlight then
        return
    end
    pO = kH("HatchEgg", "Basic")
    pP = math.max(1, math.floor(k5("HatchAmount", 1)))
    pP = math.min(pP, lI())
    if not kI(pO) then
        lM = os.clock() + 0.35
        return
    end
    result = nil
    local pR_1 = pcall(function()
        result = EggInfo:InvokeServer("Buy", pO, pP)
    end)
    local pS = not pR_1 or type(result) ~= "table"
    if pS then
        lM = os.clock() + 0.75
        return
    end
    if type(result.MaxOpenAmount) == "number" then
        Eggs.MaxOpenAmount = result.MaxOpenAmount
    end
    if result.Success == true then
        lM = os.clock() + math.max(k5("HatchDelay", 1.25), 0.75)
        if kF then
            pcall(function()
                Eggs:SetOpeningUiSelected(false)
            end)
            pcall(function()
                Eggs:ClearOpeningPreview(true)
            end)
        end
        return
    end
    local Reason = result.Reason
    if Reason == "Cooldown" then
        local pS_1 = tonumber(result.RetryAfter) or 1.25
        lM = os.clock() + math.max(pS_1, 0.75)
    elseif Reason == "OutOfRange" then
        lM = os.clock() + 0.35
    else
        lM = os.clock() + math.max(k5("HatchDelay", 1.25), 0.75)
    end
end
lw = fn546
ll = function()
    local result, p3
    p3 = kH("EquipSortMode", "Luck")
    if Pets then
        Pets.SortMode = p3
        Pets.Requesting = false
    end
    result = nil
    local p4 = pcall(function()
        result = EggInfo:InvokeServer("EquipSort", p3)
    end)
    local p5 = p4 and type(result) == "table" and result.Success and Pets and type(Pets.ApplyStateUpdate) == "function"
    if p5 then
        pcall(function()
            local p0 = result.State or result
            Pets:ApplyStateUpdate(p0)
        end)
    else
        local p5_1 = p4 and type(result) == "table" and result.Success and Pets and type(Pets.SetState) == "function"
        if p5_1 then
            pcall(function()
                Pets:SetState(result.State)
            end)
        end
    end
end
lN = fn463
lF = function()
    local qa, Items, qc
    if RebirthHandler.IsMax then
        return false
    end
    local Cash = RebirthHandler.Cash
    if type(Cash) ~= "number" then
        return false
    end
    local CashFrame = RebirthHandler.CashFrame
    local qf = CashFrame and CashFrame:GetAttribute("Cash")
    if (qf or 0) < Cash then
        return false
    end
    Items = RebirthHandler.Items
    local qd_1 = type(Items) ~= "table" or type(Items.One) ~= "table" or type(Items.Two) ~= "table"
    if qd_1 then
        return false
    end
    qc = false
    qa = false
    pcall(function()
        qa = RebirthHandler:IsNameInInventory(Items.One[1], 1)
        qc = RebirthHandler:IsNameInInventory(Items.Two[1], 2)
    end)
    return qa and qc
end
kU = fn603
local q8_4 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = lA, Copyable = true }, "|", mb },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local mc = {
    Info = q8_4:AddTab("Info", "info"),
    Main = q8_4:AddTab("Main", "gamepad-2"),
    Settings = q8_4:AddTab("Settings", "settings")
}
mc.Farm = mc.Main:AddSubTab("Farm", "sprout")
mc.Shop = mc.Main:AddSubTab("Shop", "shopping-cart")
mc.Pets = mc.Main:AddSubTab("Pets", "paw-print")
local l1 = fn707
for k, v in mc do
    if v ~= mc.Main then
        l1(v)
    end
end
ls, q8_2, GameInfoGroup, k_, kW, q8_8 = nil, nil, nil, nil, nil, nil
q8_10 = 7
repeat
    q8_1 = (q8_10 * 1 + 0) % 3 + 1
    if q8_1 <= 2 then
        if q8_1 <= 1 then
            q8_1 = {
                "fbxubqan",
                "cfnwvva",
                "ptdnlpnd",
                "glzttwrmen",
                "ujy",
                "kbqcrufvu",
                "vkbmjvoq",
                "giwd",
                "cmsgtseba",
                "ptp",
                "aaka"
            }
            local su = q8_10
            q8_9 = q8_1[su % 11 + 1]
            if q8_9:len() <= q8_9:reverse():rep(su % 3 + 2):len() then
                q8_8 = #kW > 18
            else
                kW = #q8_8 > 18
            end
            q8_10 = (q8_10 + 1) % 24
        else
            if (not q8_8 or not q8_8 or (q8_8 or q8_8) or (not q8_8 or q8_2) and (q8_8 and q8_2)) and ((not q8_2 or not q8_8) and (not q8_2 or q8_2) and (q8_2 and not q8_8 and (not q8_8 or q8_8))) and not ((not q8_8 or not q8_8 or (q8_8 or q8_8) or (not q8_8 or q8_2) and (q8_8 and q8_2)) and ((not q8_2 or not q8_8) and (not q8_2 or q8_2) and (q8_2 and not q8_8 and (not q8_8 or q8_8)))) then
                k_ = "Unknown"
                pcall(fn458)
                kA = (nil):AddLeftGroupbox("Account", "circle-user")
                kA:AddLabel(GameInfoGroup("User", mc.Name, q8_2), true)
                kA:AddLabel(GameInfoGroup("Status", "Keyless", q8_2), true)
                kA:AddLabel(GameInfoGroup("Executor", k_, q8_2), true)
                l8 = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
                l8:AddLabel(ls(l9 .. " [" .. tostring(game.PlaceId) .. "]", LocalPlayer), true)
                l8:AddLabel(GameInfoGroup("Place ID", tostring(game.PlaceId), LocalPlayer), true)
                mb = l8:AddLabel(GameInfoGroup("Session time", "0s", lP), true)
            else
                ls = "Unknown"
                pcall(fn458)
                q8_2 = mc.Info:AddLeftGroupbox("Account", "circle-user")
                q8_2:AddLabel(lP("User", LocalPlayer.Name, l9), true)
                q8_2:AddLabel(lP("Status", "Keyless", l9), true)
                q8_2:AddLabel(lP("Executor", ls, l9), true)
                GameInfoGroup = mc.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                GameInfoGroup:AddLabel(kA(mb .. " [" .. tostring(game.PlaceId) .. "]", l8), true)
                GameInfoGroup:AddLabel(lP("Place ID", tostring(game.PlaceId), l8), true)
                k_ = GameInfoGroup:AddLabel(lP("Session time", "0s", lv), true)
            end
            q8_10 = (q8_10 + 16) % 24
        end
    else
        q8_1 = (vector.create((q8_10 * 5 + 8) % 11 + 1, (q8_10 * 8 + 10) % 13 + 1, (q8_10 * 4 + 16) % 17 + 1))
        q8_9 = (vector.create((q8_10 * 7 + 2) % 11 + 1, (q8_10 * 4 + 3) % 13 + 1, (q8_10 * 2 + 6) % 17 + 1))
        q8_6 = (vector.create((q8_10 * 5 + 9) % 11 + 1, (q8_10 * 2 + 13) % 13 + 1, (q8_10 * 12 + 5) % 17 + 1))
        q8_4 = (vector.create((q8_10 * 2 + 5) % 5 + 1, (q8_10 * 4 + 6) % 7 + 1, (q8_10 * 4 + 4) % 9 + 1))
        if vector.dot(vector.cross(q8_1, (vector.cross(q8_9, q8_6))), q8_4) == vector.dot(q8_9 * vector.dot(q8_1, q8_6) - q8_6 * vector.dot(q8_1, q8_9), q8_4) then
            kW = tostring(game.JobId)
        else
            k_ = tostring(game.JobId)
        end
        q8_10 = (q8_10 + 7) % 24
    end
until (q8_10 * 17 + 13) % 24 == 12
if q8_8 then
    q8_2 = 4
    repeat
        q8_10 = {
            "pher",
            "mwm",
            "pelypv",
            "emzyiivceolg",
            "uttpc",
            "ztciilyqbfb",
            "zjoqyacu",
            "ynawd",
            "tpd",
            "fsgsahyoeit",
            "bqmd",
            "jdsouwykaukm"
        }
        if q8_10[(q8_2 * 34 + 36) % 12 + 1] < q8_10[(q8_2 * 34 + 36) % 12 + 1] then
            kW = string.sub(q8_8, 1, 18) .. "..."
        else
            q8_8 = string.sub(kW, 1, 18) .. "..."
        end
        q8_2 = (q8_2 + 1) % 8
    until (q8_2 * 7 + 7) % 8 == 2
end
q8_2 = q8_8 or kW
kB, FaqGroup, q8_6, kv, lQ, connection, connection2, lB = nil, nil, nil, nil, nil, nil, nil, nil
q8_1 = q8_2
GameInfoGroup:AddLabel(lP("Server", q8_1, l5), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
kB = os.clock()
task.spawn(worker)
local ScriptsGroup = mc.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(kA("Included in this hub", l5), true)
ScriptsGroup:AddLabel(kA(mb, l8), true)
local FeaturesGroup = mc.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(kA("Auto Farm", l8), true)
FeaturesGroup:AddLabel(kA("Auto Shop", l9), true)
FeaturesGroup:AddLabel(kA("Pet Utilities", lv), true)
FeaturesGroup:AddLabel(kA("Misc Utilities", l5), true)
local SocialsGroup = mc.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = kN })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = mc.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
if (not ScriptsGroup and q8_1 and (not q8_6 or not q8_6) or (q8_1 and connection or (q8_1 or q8_1))) and ((not connection or not q8_1 or (not connection or ScriptsGroup)) and (not q8_1 or ScriptsGroup or (connection or not q8_6))) or ((not q8_6 or q8_6) and (q8_1 and not q8_6) or (q8_6 and not q8_6 or (q8_1 or not q8_6))) and ((q8_1 or not connection) and (not connection and q8_6) or (not ScriptsGroup or ScriptsGroup) and (connection or q8_6)) or not ((not ScriptsGroup and q8_1 and (not q8_6 or not q8_6) or (q8_1 and connection or (q8_1 or q8_1))) and ((not connection or not q8_1 or (not connection or ScriptsGroup)) and (not q8_1 or ScriptsGroup or (connection or not q8_6))) or ((not q8_6 or q8_6) and (q8_1 and not q8_6) or (q8_6 and not q8_6 or (q8_1 or not q8_6))) and ((q8_1 or not connection) and (not connection and q8_6) or (not ScriptsGroup or ScriptsGroup) and (connection or q8_6))) then
    TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = kN })
    FaqGroup = mc.Info:AddRightGroupbox("FAQ", "circle-help")
else
    mc:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    mc:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    mc:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    mc:AddButton({ Text = "Copy Discord Invite", Func = TempoHubGroup })
    kN = FaqGroup.Info:AddRightGroupbox("FAQ", "circle-help")
end
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
l1 = mc.Farm:AddLeftGroupbox("Farm", "dices")
l1:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false, Callback = onAutoRoll })
l1:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
l1:AddSlider("CollectDelay", { Text = "Collect delay", Default = 0.75, Min = 0.2, Max = 10, Rounding = 2, Suffix = "s" })
l1:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Affordable Upgrades", Default = false })
l1:AddSlider("UpgradeDelay", { Text = "Upgrade delay", Default = 1, Min = 0.3, Max = 15, Rounding = 1, Suffix = "s" })
l1:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
l1:AddSlider("RebirthDelay", { Text = "Rebirth delay", Default = 2, Min = 0.5, Max = 30, Rounding = 1, Suffix = "s" })
q8_3 = mc.Farm:AddRightGroupbox("Wheel", "disc-3")
q8_3:AddToggle("AutoSpinWheel", { Text = "Auto Spin Free Wheel", Default = false })
q8_4 = mc.Shop:AddLeftGroupbox("Shop", "store")
q8_4:AddToggle("AutoBuyDice", { Text = "Auto Buy Dice", Default = false })
q8_4:AddToggle("AutoBuySelectedDice", { Text = "Auto Buy Selected Dice", Default = false })
q8_4:AddDropdown("SelectedDice", { Text = "Dice", Values = l7, Default = "Bronze" })
q8_4:AddToggle("AutoBuyPotions", { Text = "Auto Buy Potions", Default = false })
q8_4:AddSlider("ShopDelay", { Text = "Shop delay", Default = 1, Min = 0.3, Max = 15, Rounding = 1, Suffix = "s" })
q8_6 = mc.Shop:AddRightGroupbox("Merchant", "user-round")
q8_6:AddToggle("AutoBuyMerchant", { Text = "Auto Buy Merchant", Default = false })
q8_6:AddDropdown("MerchantCategories", { Text = "Merchant categories", Values = l6, Default = { "Potions", "Foods" }, Multi = true })
q8_6:AddToggle("AutoBuyFoodCart", { Text = "Auto Buy Food Cart", Default = false })
q8_6:AddSlider("MerchantDelay", { Text = "Merchant delay", Default = 10, Min = 2, Max = 60, Rounding = 0, Suffix = "s" })
q8_9 = mc.Pets:AddLeftGroupbox("Eggs", "egg")
q8_9:AddToggle("AutoHatchEggs", { Text = "Auto Hatch Eggs", Default = false })
q8_9:AddDropdown("HatchEgg", { Text = "Egg", Values = ma, Default = "Basic" })
q8_9:AddSlider("HatchAmount", { Text = "Hatch amount", Default = 1, Min = 1, Max = 3, Rounding = 0 })
q8_9:AddSlider("HatchDelay", { Text = "Hatch delay", Default = 1.25, Min = 0.75, Max = 10, Rounding = 2, Suffix = "s" })
q8_9:AddToggle("RemoveHatchAnimation", { Text = "Remove Hatch Animation", Default = false, Callback = onRemoveHatchAnimation })
q8_8 = mc.Pets:AddRightGroupbox("Pets", "paw-print")
q8_8:AddToggle("AutoClaimIndex", { Text = "Auto Claim Index", Default = false })
q8_8:AddSlider("IndexDelay", { Text = "Index delay", Default = 5, Min = 1, Max = 60, Rounding = 0, Suffix = "s" })
q8_8:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
q8_8:AddSlider("EquipBestDelay", { Text = "Equip best delay", Default = 3, Min = 1, Max = 60, Rounding = 0, Suffix = "s" })
q8_8:AddToggle("AutoEquipSort", { Text = "Auto Equip Sort Pets", Default = false })
q8_8:AddDropdown("EquipSortMode", { Text = "Sort mode", Values = l4, Default = "Luck" })
q8_8:AddSlider("EquipSortDelay", { Text = "Equip sort delay", Default = 3, Min = 1, Max = 60, Rounding = 0, Suffix = "s" })
q8_10 = mc.Settings:AddLeftGroupbox("Menu", "menu")
Library.ToggleKeybind = Options.MenuKeybind
q8_10:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
q8_10:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
q8_10:AddButton({ Text = "Unload", Func = onUnload })
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(mc.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/kawaii-anime-rng")
SaveManager:BuildConfigSection(mc.Settings)
SaveManager:LoadAutoloadConfig()
kv = tick()
lQ = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local qH = v
        pcall(function()
            qH:Disable()
        end)
    end
end)
lB = fn452
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
if ((q8_6 or not connection2) and (connection2 or not q8_6) and (lB or false or connection2 and not connection2) or (lB and not lB or not q8_8 and 28 or (not lB and lB or q8_6 and 28)) or ((q8_6 or q8_6) and (q8_6 or false) or (q8_6 and q8_6 or not connection2 and not connection2) or not connection2 and not connection2 and connection2 and (connection2 and not connection2 and (q8_8 and connection2)))) and not ((q8_6 or not connection2) and (connection2 or not q8_6) and (lB or false or connection2 and not connection2) or (lB and not lB or not q8_8 and 28 or (not lB and lB or q8_6 and 28)) or ((q8_6 or q8_6) and (q8_6 or false) or (q8_6 and q8_6 or not connection2 and not connection2) or not connection2 and not connection2 and connection2 and (connection2 and not connection2 and (q8_8 and connection2)))) then
    Library:OnUnload(fn917)
else
    Library:OnUnload(fn917)
end
if lq("RemoveHatchAnimation") then
    kC(true)
end
if lq("AutoRoll") then
    kz(true)
end
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(worker6)
task.spawn(worker7)
task.spawn(worker8)
task.spawn(worker9)
task.spawn(worker10)
task.spawn(worker11)
task.spawn(worker12)
task.spawn(worker13)
Library:Notify("Kawaii Anime RNG loaded")
end)(...)

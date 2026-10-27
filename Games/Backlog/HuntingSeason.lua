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
getgenv().TempoHoodSubtitle = "HUNTING SEASON"
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
local xP
local wP
local xw
local ww
local xd
local xV
local wV
local xC
local wC
local x0
local w0
local wI
local xp
local w6
local Workspace
local wO
local xv
local wv
local xU
local wU
local xB
local wB
local xi
local x_
local w_
local LocalPlayer
local wH
local x5
local xT
local wT
local wA
local wZ
local xG
local wG
local xn
local x4
local w4
local xM
local wM
local ya
local wt
local xa
local xS
local wS
local wz
local wY
local wF
local RunService
local wL
local xs
local xR
local xy
local wy
local xf
local xX
local wX
local xE
local wE
local xl
local w2
local xK
local wK
local w8
local xQ
local wx
local xe
local xW
local wW
local xD
local wD
local xJ
local wJ
local x7
local w7
function fns.fn49()
    if wF.AmmoStore ~= "Nearest" then
        return wF.AmmoStore
    end
    local EZ = xM()
    if not EZ then
        return "Sage Armory"
    end
    local E_ = math.huge
    local E0 = "Sage Armory"
    for k, v in xw do
        if v ~= "Nearest" then
            local E1 = xU(wy(v))
            if E1 then
                local Magnitude = (E1 - EZ.Position).Magnitude
                if Magnitude < E_ then
                    E_ = Magnitude
                    E0 = v
                end
            end
        end
    end
    return E0
end
function fns.fn68()
    if x_ then
        return
    end
    x_ = true
    RunService:BindToRenderStep(x5, Enum.RenderPriority.Camera.Value + 1, function()
        local BT = wF.Unloaded
        local BY = if BT then 1 else 0
        local BW = 1182 * BY + 893 * (1 - BY)
        local BX = 1326 * BY + 3890 * (1 - BY)
        if not ((BW * 1968 + BX * 3453 + BW * BX) % 16777213 == 8472186) then
            BT = not wF.AutoShoot
        end
        if BT then
            return
        end
        local AimPosition = wF.AimPosition
        if typeof(AimPosition) ~= "Vector3" then
            return
        end
        local CurrentCamera = Workspace.CurrentCamera
        if CurrentCamera then
            CurrentCamera.CFrame = CFrame.lookAt(CurrentCamera.CFrame.Position, AimPosition)
        end
    end)
end
function fns.fn91(dz, dA, dB, dC)
    local A5 = RaycastParams.new()
    A5.FilterType = Enum.RaycastFilterType.Exclude
    local A6 = {}
    if dC then
        A6[1] = dC
    end
    local CurrentCamera = Workspace.CurrentCamera
    if CurrentCamera then
        A6[#A6 + 1] = CurrentCamera
    end
    A5.FilterDescendantsInstances = A6
    local A6_1 = dA - dz
    if A6_1.Magnitude <= 0 then
        return true
    end
    local A7_1 = Workspace:Raycast(dz, A6_1, A5)
    if not A7_1 then
        return true
    end
    return A7_1.Instance:IsDescendantOf(dB)
end
function fns.fn102()
    return Workspace:FindFirstChild("Animals")
end
function fns.fn109()
    local zD_1
    local zC_1
    if xX then
        return xX
    end
    zC_1, zD_1 = pcall(function()
        return require(wK.Common.AnimalStats)
    end)
    local zE = zC_1 and type(zD_1) == "table"
    if zE then
        xX = zD_1
        return zD_1
    end
end
function fns.fn115()
    local B4_1
    local B3_1
    if typeof(gethui) == "function" then
        B3_1, B4_1 = pcall(gethui)
        local B5 = B3_1 and typeof(B4_1) == "Instance"
        if B5 then
            return B4_1
        end
        return LocalPlayer:WaitForChild("PlayerGui")
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end
local function fn128(i_)
    if type(i_) ~= "table" then
        return
    end
    if not wF.AutoHarvest and not wF.AutoPreserve then
        return
    end
    wG[#wG + 1] = { data = i_, range = wM }
    wM = nil
    wz()
end
local function fn136(u, v)
    local yG_1
    local yF_1
    if u == v then
        return true
    elseif typeof(compareinstances) == "function" then
        yF_1, yG_1 = pcall(compareinstances, u, v)
        if yF_1 then
            return yG_1 == true
        end
        return false
    else
        return false
    end
end
local function fn144()
    local D2_1
    local D1_1
    D1_1, D2_1 = pcall(function()
        require(wK.Common.UI.Router).Go("Gameplay")
    end)
    if not D1_1 then
        xJ("HarvestContinue", D2_1)
    end
end
local function fn150()
    local z4 = xy()
    local z5 = z4 and z4.CurrentItem
    local z5_1 = type(z5) == "table" and z5.ClassName == "Rifle" and type(z5.Fire) == "function"
    if z5_1 then
        return z5
    end
end
local function fn225(lz, lA)
    wF[lz] = lA
end
local function fn253(m)
    local yt = getfenv(0)
    for k in string.gmatch(m, "[^.]+") do
        if type(yt) ~= "table" then
            return false
        end
        yt = yt[k]
    end
    local yu = typeof(yt) == "function"
    local yC = if yu then 1 else 0
    local yA = 2738 * yC + 987 * (1 - yC)
    local yB = 3332 * yC + 2816 * (1 - yC)
    if not ((yA * 1412 + yB * 2494 + yA * yB) % 16777213 == 4521867) then
        yu = typeof(yt) == "table"
    end
    return yu
end
local function fn279()
    return Workspace:FindFirstChild("DeadAnimals")
end
local function fn283(gS)
    local Parent = gS.Parent
    local Di = Parent and Parent:IsA("BasePart")
    if Di then
        return Parent.Position
    end
    local Di_1 = Parent and Parent:IsA("Bone")
    if Di_1 then
        return Parent.WorldPosition
    end
    local Model = gS:FindFirstAncestorOfClass("Model")
    local Di_2 = Model and wS(Model)
    local Dh_2 = Di_2
    if Di_2 then
        Di_2 = Dh_2.Position
    end
    return Di_2
end
local function fn293()
    if typeof(filtergc) ~= "function" then
        return
    end
    local FO = filtergc("table", { Keys = { "Marker", "Waypoint", "WorldPosition", "MapPosition" } }, true)
    local FP = wA(FO)
    if FP then
        return FP
    end
    if type(FO) == "table" then
        for k, v in FO do
            local FP_1 = wA(v)
            if FP_1 then
                return FP_1
            end
        end
    end
end
local function fn341(gs)
    local attr = gs:GetAttribute("AnimalId")
    local C3 = attr ~= ""
    local C4 = type(attr) == "string" and C3
    if C4 then
        return attr
    end
    local Model = gs:FindFirstAncestorOfClass("Model")
    local C3_1 = Model and Model:GetAttribute("Id")
    local C3_2 = C3_1 ~= ""
    local C4_1 = type(C3_1) == "string" and C3_2
    if C4_1 then
        return C3_1
    end
end
local function fn345(b7)
    local Aa = typeof(b7) ~= "Instance" or not b7:IsA("Model")
    if Aa then
        return
    end
    local Aa_1 = b7:FindFirstChild("RootPart") or b7.PrimaryPart
    return Aa_1
end
local function fn381(ag, ah)
    local yT = os.clock()
    local yU = xS[ag]
    if yU and yT - yU < xa then
        return
    end
    xS[ag] = yT
    warn((("[TempoHuntingSeason] %*: %*"):format(ag, ah)))
end
local function fn414(cg)
    local Ac = typeof(cg) ~= "Instance" or not cg:IsA("Model") or not cg.Parent
    if Ac then
        return false
    end
    local attr = cg:GetAttribute("Owner")
    if attr ~= nil and attr ~= LocalPlayer.UserId then
        return false
    end
    for i, descendant in cg:GetDescendants() do
        local Ac_2 = descendant:IsA("MeshPart") and descendant.Transparency < 1 and descendant.LocalTransparencyModifier < 1
        if Ac_2 then
            return true
        end
    end
    return false
end
local function fn472()
    local yL = {}
    for k, v in xE do
        yL[v] = true
    end
    return yL
end
local function onChildAdded(lx)
    if lx.Name == "DeadAnimals" then
        xK(lx)
    end
end
local function fn523()
    if not wF.MarkerTeleport or w_ or wV or wJ then
        return
    end
    local FX_2 = xM()
    if not FX_2 then
        return
    end
    local FY_1 = xP()
    if typeof(FY_1) ~= "Vector3" then
        wE = nil
        return
    end
    if wE and (FY_1 - wE).Magnitude < 6 then
        return
    end
    wE = FY_1
    FX_2.CFrame = CFrame.new(FY_1 + Vector3.new(0, 4, 0))
end
local function fn528(lH)
    if typeof(lH) == "Color3" then
        wF.EspColor = lH
    end
end
local function fn555(kB)
    if type(kB) ~= "table" then
        return
    end
    local FI = typeof(kB.WorldPosition) == "Vector3"
    if FI then
        local FJ = kB.Marker
        local FN = if FJ then 1 else 0
        local FL = 3916 * FN + 3745 * (1 - FN)
        local FM = 1112 * FN + 3232 * (1 - FN)
        if not ((FL * 973 + FM * 353 + FL * FM) % 16777213 == 8557396) then
            FJ = kB.Waypoint
        end
        FI = FJ
    end
    if FI then
        return kB.WorldPosition
    end
end
local function worker()
    while not wF.Unloaded do
        xp("AutoShoot", function()
            if wF.AutoShoot then
                xT()
                local F0 = xf()
                local F1 = wT()
                if F0 and F1 then
                    wI(F1)
                    local F2_1 = wx(F1)
                    wF.AimPosition = F2_1
                    wY(F0, F1, F2_1)
                else
                    wI(nil)
                    wF.AimPosition = nil
                end
            else
                wI(nil)
                xi()
            end
        end)
        task.wait(wF.ShootDelay)
    end
end
local function fn585(fJ, fK, fL)
    local Cr = fJ:GetAttribute("DisplayName") or fJ.Name
    local Cr_1 = { Cr }
    if fL then
        Cr_1[#Cr_1 + 1] = "Dead"
    end
    if wF.EspShowSex then
        local attr = fJ:GetAttribute("Sex")
        local Ct_1 = attr ~= ""
        local Cu = type(attr) == "string" and Ct_1
        if Cu then
            Cr_1[#Cr_1 + 1] = attr
        end
    end
    local Cs_2 = table.concat(Cr_1, " | ")
    local Cr_2 = ""
    if wF.EspShowDistance then
        Cr_2 = string.format("%dm", math.floor(fK + 0.5))
    end
    local attr = fJ:GetAttribute("Weight")
    if type(attr) == "number" then
        if Cr_2 ~= "" then
            Cr_2 ..= "  "
        end
        Cr_2 ..= string.format("%.1fkg", attr)
    end
    return Cs_2, Cr_2
end
local function worker2()
    while not wF.Unloaded do
        xp("AnimalEsp", wB.UpdateEsp)
        xp("AutoHarvest", wC)
        xp("AutoBuyAmmo", w8)
        xp("MarkerTeleport", xv)
        task.wait(xe)
    end
end
local function fn626(gy)
    local C9 = typeof(gy) ~= "Instance" or not gy:IsA("ProximityPrompt")
    if C9 then
        return false
    end
    local C9_1 = x4()
    local Da = not C9_1 or not gy:IsDescendantOf(C9_1)
    if Da then
        return false
    end
    local attr2 = gy:GetAttribute("Owner")
    if attr2 ~= nil and attr2 ~= LocalPlayer.UserId then
        return false
    end
    local C9_3 = xD(gy)
    if not C9_3 then
        return false
    end
    local Model = gy:FindFirstAncestorOfClass("Model")
    if Model then
        local attr = Model:GetAttribute("Owner")
        if attr ~= nil and attr ~= LocalPlayer.UserId then
            return false
        end
        if Model:GetAttribute("ClientSide") == true then
            wD(C9_3)
        end
        return w4[C9_3] ~= nil
    end
    return w4[C9_3] ~= nil
end
local function fn633(cy)
    if typeof(cy) ~= "Instance" then
        return
    end
    local Au = cy:IsA("Attachment") or cy:IsA("Bone")
    if Au then
        return cy.WorldPosition
    end
    if cy:IsA("BasePart") then
        return cy.Position
    end
end
local function fn662(lC, lD)
    local Gj = wt(lD)
    if lC == "Shoot" then
        wF.ShootSpecies = Gj
    elseif lC == "Esp" then
        wF.EspSpecies = Gj
    elseif lC == "Harvest" then
        wF.HarvestSpecies = Gj
    elseif lC == "Preserve" then
        wF.PreserveSpecies = Gj
    end
end
local function fn676()
    if x7 and x7.Parent then
        return x7
    end
    local folder = Instance.new("Folder")
    folder.Name = "TempoHSEsp"
    folder.Parent = wO()
    x7 = folder
    return folder
end
local function fn724(ac)
    ww[#ww + 1] = ac
    return ac
end
local function fn748(ao, ap)
    local y0_1
    local y__1
    y0_1, y__1 = pcall(ap)
    if not y0_1 then
        xJ(ao, y__1)
    end
    return y0_1
end
local function fn790()
    local AX_1
    local AW_1
    if w7 then
        return w7
    end
    AW_1, AX_1 = pcall(function()
        return require(wK.ReservesCommon.Client.Controllers.ProjectileController)
    end)
    local AY = AW_1 and type(AX_1) == "table" and type(AX_1.Fire) == "function"
    if AY then
        w7 = AX_1
        return AX_1
    end
end
local function fn805()
    for k, v in x0 do
        if v.gui then
            v.gui:Destroy()
        end
        if v.highlight then
            v.highlight:Destroy()
        end
    end
    table.clear(x0)
    if x7 then
        x7:Destroy()
        x7 = nil
    end
end
local function fn863(gO)
    local Model = gO:FindFirstAncestorOfClass("Model")
    if not Model then
        return
    end
    local Df = Model:GetAttribute("DisplayName") or Model.Name
    return Df
end
local function fn888()
    if not x_ then
        return
    end
    x_ = false
    pcall(function()
        RunService:UnbindFromRenderStep(x5)
    end)
    wF.AimPosition = nil
end
local function fn889()
    local BC_1
    local BB_1
    local BA_1
    BC_1, BA_1, BB_1 = xM()
    local CurrentCamera = Workspace.CurrentCamera
    if not BC_1 or not CurrentCamera then
        return
    end
    local BD_1 = wv()
    if not BD_1 then
        return
    end
    local Position = CurrentCamera.CFrame.Position
    local LookVector = CurrentCamera.CFrame.LookVector
    local ShootDistance = wF.ShootDistance
    local BG = wF.ShootFov * 0.5
    local BH
    local BI = math.huge
    for i, child in BD_1:GetChildren() do
        if xR(child) then
            local BD_2 = xn(child)
            if BD_2 then
                local attr2 = child:GetAttribute("DisplayName")
                local attr = child:GetAttribute("Sex")
                if w2(wF.ShootSpecies, attr2) then
                    if wF.ShootSex == "Any" or attr == wF.ShootSex then
                        local Magnitude = (BD_2.Position - BC_1.Position).Magnitude
                        if Magnitude <= ShootDistance then
                            local BK_1 = xd(LookVector, Position, BD_2.Position)
                            if BK_1 <= BG then
                                local BL = not wF.WallCheck or xC(Position, BD_2.Position, child, BB_1)
                                if BL then
                                    local BD_3 = BK_1 * 8 + Magnitude
                                    if BD_3 < BI then
                                        BI = BD_3
                                        BH = child
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return BH
end
local function fn921()
    local Viewmodel = wF.Viewmodel
    local z2 = type(Viewmodel) == "table" and Viewmodel.CurrentItem
    if z2 then
        return Viewmodel
    end
    if typeof(filtergc) == "function" then
        local z1_1 = filtergc("table", { Keys = { "CurrentItem", "Springs" } }, true)
        local z2_1 = type(z1_1) == "table" and z1_1.CurrentItem
        if z2_1 then
            wF.Viewmodel = z1_1
            return z1_1
        end
    end
end
local function fn923(jA)
    local Fa = jA.Data and jA.Data.Loadout
    local Fa_1 = jA.Data and jA.Data.Inventory
    local Fa_2 = type(Fa) ~= "table" or type(Fa_1) ~= "table"
    if Fa_2 then
        return
    end
    local Fa_3 = Fa[1]
    if type(Fa_3) ~= "string" then
        return
    end
    local Weapons = Fa_1.Weapons
    if type(Weapons) ~= "table" then
        return
    end
    for k, v in Weapons do
        local Fb_2 = type(v) == "table" and v.Item == Fa_3 and type(v.Ammunition) == "string"
        if Fb_2 then
            return v.Ammunition
        end
    end
end
local function fn925(lk)
    local F6 = typeof(lk) ~= "Instance" or not lk:IsA("Model")
    if F6 then
        return
    end
    local attr = lk:GetAttribute("Id")
    local F7 = type(attr) == "string" and attr ~= "" and lk:GetAttribute("ClientSide") == true
    if F7 then
        wD(attr)
    end
end
local function fn976(az)
    local y2 = az ~= ""
    local y3 = type(az) == "string" and y2
    if y3 then
        w4[az] = os.clock()
    end
end
local function fn1000(cp)
    local ProjectileBounds = cp:FindFirstChild("_ProjectileBounds")
    local Am = ProjectileBounds and ProjectileBounds:IsA("BasePart")
    if Am then
        return ProjectileBounds
    end
    for i, descendant in cp:GetDescendants() do
        local Al_1 = descendant:IsA("MeshPart") and descendant.Transparency < 1
        if Al_1 then
            return descendant
        end
    end
    return wS(cp)
end
local function fn1010()
    local Character = LocalPlayer.Character
    if not Character then
        return
    end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if HumanoidRootPart and Humanoid and Humanoid.Health > 0 then
        return HumanoidRootPart, Humanoid, Character
    end
end
local function fn1033(aC)
    if typeof(aC) == "Instance" then
        wD(aC:GetAttribute("Id"))
    end
end
local function fn1038(bN)
    if type(bN) ~= "table" then
        return w6()
    end
    local zS = false
    local zT = {}
    for k, v in bN do
        local zU = v == true and type(k) == "string"
        if zU then
            zT[k] = true
            zS = true
        else
            local zU_1 = type(k) == "number" and type(v) == "string"
            if zU_1 then
                zT[v] = true
                zS = true
            end
        end
    end
    if not zS then
        return {}
    end
    return zT
end
local function fn1042()
    local AL_1
    local AK_1
    if xl then
        return xl
    end
    AK_1, AL_1 = pcall(function()
        return require(wK.ReservesCommon.Client.Controllers.ReplicationController)
    end)
    local AM = AK_1 and type(AL_1) == "table"
    if AM then
        xl = AL_1
        return AL_1
    end
end
local function fn1097(i6)
    local Stores = Workspace:FindFirstChild("Stores")
    if not Stores then
        return
    end
    return Stores:FindFirstChild(i6)
end
local function fn1143(r)
    local yD = typeof(cloneref) == "function" and typeof(r) == "Instance"
    if yD then
        return cloneref(r)
    end
    return r
end
local function fn1144(eu, ev, ew)
    local By = ew - ev
    if By.Magnitude <= 0 then
        return 0
    end
    return math.deg(math.acos((math.clamp(eu:Dot(By.Unit), -1, 1))))
end
local function fn1145()
    local zH_1
    local zG_1
    if xs then
        return xs
    end
    zG_1, zH_1 = pcall(function()
        return require(wK.Common.GameConfig)
    end)
    local zI = zG_1 and type(zH_1) == "table"
    if zI then
        xs = zH_1
        return zH_1
    end
end
local function fn1146()
    local zz_1
    local zy_1
    if wX then
        return wX
    end
    zy_1, zz_1 = pcall(function()
        return require(wK.ReservesCommon.Ammunition)
    end)
    local zA = zy_1 and type(zz_1) == "table"
    if zA then
        wX = zz_1
        return zz_1
    end
end
local function fn1204(cB)
    local Aw
    local Ax = math.huge
    for i, descendant in cB:GetDescendants() do
        local Ay = wU[descendant.Name]
        if Ay and Ay < Ax then
            local Az_1 = wL(descendant)
            if Az_1 then
                Aw = Az_1
                Ax = Ay
            end
        end
    end
    if Aw then
        return Aw
    end
    local Aw_1 = xn(cB)
    return Aw_1 and Aw_1.Position
end
local function fn1205()
    if wF.Unloaded then
        return
    end
    wF.Unloaded = true
    wB.Unloaded = true
    wF.AutoShoot = false
    wF.AnimalEsp = false
    wF.CorpseEsp = false
    wF.AutoHarvest = false
    wF.AutoPreserve = false
    wF.MarkerTeleport = false
    w_ = false
    wV = false
    wJ = false
    wZ = false
    table.clear(wG)
    wE = nil
    wF.AutoBuyAmmo = false
    wI(nil)
    xi()
    xB()
    if wP then
        local Gm = w0 and typeof(hookmetamethod) == "function"
        if Gm then
            pcall(function()
                hookmetamethod(game, "__namecall", w0)
            end)
        else
            local Gm_1 = wW and typeof(hookfunction) == "function"
            if Gm_1 then
                pcall(function()
                    hookfunction(xQ.FireServer, wW)
                end)
            end
        end
        wP = false
    end
    for k, v in ww do
        v:Disconnect()
    end
    table.clear(ww)
    local Gz = if getgenv()[xG] == wB then 1 else 0
    if Gz == 1 then
        getgenv()[xG] = nil
    end
end
local function fn1228(bH, bI)
    if type(bH) ~= "table" then
        return true
    end
    local zK = false
    for k, v in bH do
        if v then
            zK = true
            break
        end
    end
    if not zK then
        return false
    end
    return bH[bI] == true
end
local function fn1243(dq)
    local Model = dq.Model
    local A0 = Model and Model.PrimaryPart
    local A__1 = A0
    if A0 then
        A0 = A__1:FindFirstChild("BarrelAttachment")
    end
    local A__2 = A0
    local A0_1 = typeof(A__2) == "Instance" and A__2:IsA("Attachment")
    if A0_1 then
        return A__2
    end
end
local function fn1269(lr)
    if not lr or xV == lr then
        return
    end
    xV = lr
    ya(lr.ChildAdded:Connect(wH))
    for i, child in lr:GetChildren() do
        wH(child)
    end
end
local function fn1315(fw, fx, fy)
    local Cn_1
    local Cm = xW()
    if typeof(fy) == "Color3" then
        Cn_1 = fy
    else
        Cn_1 = wF.EspColor
    end
    fy = Cn_1
    local highlight = Instance.new("Highlight")
    highlight.Name = "Esp"
    highlight.Adornee = fw
    highlight.FillColor = fy
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0.1
    highlight.Parent = Cm
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "Esp"
    billboardGui.AlwaysOnTop = true
    billboardGui.Size = UDim2.fromOffset(180, 42)
    billboardGui.StudsOffset = Vector3.new(0, 3.4, 0)
    billboardGui.Adornee = fx
    billboardGui.Parent = Cm
    local textLabel2 = Instance.new("TextLabel")
    textLabel2.Name = "Name"
    textLabel2.BackgroundTransparency = 1
    textLabel2.Size = UDim2.fromScale(1, 0.58)
    textLabel2.Font = Enum.Font.BuilderSans
    textLabel2.TextColor3 = fy
    textLabel2.TextStrokeTransparency = 0.4
    textLabel2.TextScaled = true
    textLabel2.Parent = billboardGui
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Info"
    textLabel.BackgroundTransparency = 1
    textLabel.Position = UDim2.fromScale(0, 0.58)
    textLabel.Size = UDim2.fromScale(1, 0.42)
    textLabel.Font = Enum.Font.BuilderSans
    textLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    textLabel.TextStrokeTransparency = 0.4
    textLabel.TextScaled = true
    textLabel.Parent = billboardGui
    x0[fw] = { gui = billboardGui, highlight = highlight, root = fx, title = textLabel2, info = textLabel }
end
wt = nil
wv = nil
ww = nil
wx = nil
wy = nil
wz = nil
wA = nil
wB = nil
wC = nil
wD = nil
wE = nil
wF = nil
wG = nil
wH = nil
wI = nil
wJ = nil
wK = nil
wL = nil
wM = nil
wO = nil
wP = nil
wS = nil
wT = nil
wU = nil
wV = nil
wW = nil
wX = nil
wY = nil
wZ = nil
w_ = nil
w0 = nil
w2 = nil
w4 = nil
w6 = nil
w7 = nil
w8 = nil
xa = nil
xd = nil
xe = nil
local Players, wu, wN, wQ, wR, w3, w5, w9, xb, xc
xf = nil
xi = nil
xl = nil
xn = nil
xp = nil
xs = nil
xv = nil
xw = nil
xy = nil
xB = nil
xC = nil
xD = nil
xE = nil
xG = nil
LocalPlayer = nil
xJ = nil
xK = nil
xM = nil
Workspace = nil
xP = nil
xQ = nil
xR = nil
xS = nil
xT = nil
xU = nil
xV = nil
xW = nil
xX = nil
x_ = nil
x0 = nil
local xg, xh, xj, xk, xm, xo, xq, xr, xt, xu, xx, xz, xA, xF, xI, xL, xN, CollectionService, xZ, x1
RunService = nil
x4 = nil
x5 = nil
x7 = nil
ya = nil
local x2, x6, x9, yb, yj
x2 = nil
x6 = nil
local x8
x9 = nil
yb = nil
Players, RunService, CollectionService, Workspace, LocalPlayer, xG = nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local yf = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
CollectionService = game:GetService("CollectionService")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
xG = "TempoHuntingSeason"
local Li_2 = getgenv()[xG]
local Li_3 = Li_2 and Li_2.Unload
if Li_3 then
    Li_2.Unload()
end
wK, wu, x9, xZ, xQ, yj, xx, w9 = nil, nil, nil, nil, nil, nil, nil, nil
xx = fn253
w9 = fn136
wK = fn1143(yf)
Li_3 = fn1143(wK:WaitForChild("Remotes"))
local Li_1 = fn1143(wK:WaitForChild("ReservesCommon"):WaitForChild("Remotes"))
wu = fn1143(Li_1:WaitForChild("HarvestAnimal"))
x9 = fn1143(Li_1:WaitForChild("PreserveHarvest"))
local yk = fn1143(Li_1:WaitForChild("DisplayHarvest"))
xZ = fn1143(Li_3:WaitForChild("PurchaseAmmunition"))
if yj and (yj or not yj) and (x9 or not xx) and (not yj and yj or not xx or not yj and yj and 14) or not (yj and (yj or not yj) and (x9 or not xx) and (not yj and yj or not xx or not yj and yj and 14)) then
    xQ = fn1143(Li_3:WaitForChild("ProjectileHitAnimal"))
else
    Li_3 = xQ(fn1143:WaitForChild("ProjectileHitAnimal"))
end
local yi = Li_3:FindFirstChild("Birds")
yj = yi
if yj then
    Li_1 = 6
    repeat
        local ML = bit32.rrotate(bit32.bxor(bit32.lrotate(Li_1, 8), string.byte(tostring(Li_1))), 28)
        if bit32.bxor(bit32.lrotate(bit32.bxor(ML, 1462207331), 24), 1666656131) ~= bit32.lrotate(ML, 24) then
            yi = yj(fn1143:FindFirstChild("PreserveBirdHarvest"))
        else
            yj = fn1143(yi:FindFirstChild("PreserveBirdHarvest"))
        end
        Li_1 = (Li_1 + 6) % 8
    until (Li_1 * 3 + 0) % 8 == 4
end
xF, xE, xz, xw, xt, xr, xo, xk, xg, xe, xa, wF, wB, ww, xS, w4, w0, wW, wP, wJ, wX, xX, xs, wU, xl, wN, w7, x5, x_, x7, x0, w3, w_, wV, wM, wG, wZ, xc, wE, xV, w6, ya, xJ, xp, wD, x6, xM, xu, wQ, xN, xq, w2, wt, xy, xf, wS, wv, x4, xR, xn, wL, wx, xh, wI, w5, yb, xC, wY, xd, wT, xT, xi, wO, xW, xB, xm, x8, xD, xj, xI, xA, wC, x1, wR, x2, wz, wy, xU, xb, xL, w8, wA, xP, xv, wH, xK = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
xF = yj
xE = {
    "Blue wildebeest",
    "Canada goose",
    "Coyote",
    "Gray wolf",
    "Grizzly bear",
    "Leopard",
    "Lion",
    "Moose",
    "Plains zebra",
    "Red fox",
    "Ruffed grouse",
    "Spotted hyena",
    "Tiger",
    "White-tailed deer",
    "Wild boar"
}
xz = { Bronze = 0, Silver = 1, Gold = 2, Diamond = 3, Ruby = 4, Mythical = 5 }
xw = { "Nearest", "Sage Armory", "Smolov's Guns and Ammo" }
xt = { "Zone", "TeleportPart", "StorePart" }
xr = 0.15
xo = 0.35
xk = 0.25
xg = 0.2
xe = 0.2
xa = 4
w6 = fn472
wF = {
    Unloaded = false,
    AutoShoot = false,
    ShootDistance = 400,
    ShootFov = 180,
    ShootDelay = 0.35,
    ShootSex = "Any",
    WallCheck = true,
    ShootSpecies = w6(),
    AnimalEsp = false,
    CorpseEsp = false,
    EspDistance = 800,
    EspShowDistance = true,
    EspShowSex = true,
    EspColor = Color3.fromRGB(255, 170, 70),
    CorpseEspColor = Color3.fromRGB(220, 70, 70),
    EspSpecies = w6(),
    AutoHarvest = false,
    HarvestDistance = 400,
    HarvestSpecies = w6(),
    AutoPreserve = false,
    PreserveDistance = 400,
    MinRarity = "Bronze",
    PreserveSpecies = w6(),
    AutoBuyAmmo = false,
    AmmoThreshold = 10,
    AmmoBuyAmount = "Max",
    AmmoStore = "Nearest",
    MarkerTeleport = false,
    AimPosition = nil,
    Replica = nil,
    Viewmodel = nil
}
wB = { State = wF, Unloaded = false }
if (not wT or not w6 or xz and not xP) and ((xP or wT) and (not wT and not xz)) and not ((not wT or not w6 or xz and not xP) and ((xP or wT) and (not wT and not xz))) then
    xw = {}
else
    ww = {}
end
ya = fn724
xS = {}
xJ = fn381
xp = fn748
w4 = {}
wP = false
wJ = false
wD = fn976
x6 = fn1033
local function yg()
    local za_1
    if wP then
        return
    end
    local function y8(...)
        wD(select(3, ...))
    end
    local y9 = typeof(hookmetamethod) == "function" and typeof(getnamecallmethod) == "function"
    local y9_2
    if y9 then
        if typeof(newcclosure) == "function" then
            za_1 = newcclosure
        else
            za_1 = function(aT)
                return aT
            end
        end
        local y9_1 = za_1
        w0 = hookmetamethod(game, "__namecall", y9_1(function(aW, ...)
            local y6 = getnamecallmethod() == "FireServer" and w9(aW, xQ)
            if y6 then
                y8(...)
            end
            return w0(aW, ...)
        end))
        wP = true
    elseif typeof(hookfunction) == "function" then
        if typeof(newcclosure) == "function" then
            y9_2 = newcclosure
        else
            y9_2 = function(aK)
                return aK
            end
        end
        local za_2 = y9_2
        wW = hookfunction(xQ.FireServer, za_2(function(aO, ...)
            y8(...)
            return wW(aO, ...)
        end))
        wP = true
    end
end
yg()
xM = fn1010
xu = function()
    local zq
    zq = nil
    local zr_1, zr_2
    if wF.Replica then
        return wF.Replica
    end
    zr_1, zq = pcall(function()
        return require(wK.Common.Client.Controllers.ReplicaController)
    end)
    local zs = not zr_1 or type(zq) ~= "table"
    local zs_1
    if zs then
        return nil
    end
    zr_2, zs_1 = pcall(function()
        return zq:WaitForReplica("PlayerData")
    end)
    if zr_2 and zs_1 then
        wF.Replica = zs_1
        return zs_1
    end
end
wQ = fn1146
xN = fns.fn109
xq = fn1145
w2 = fn1228
wt = fn1038
xy = fn921
xf = fn150
wS = fn345
wv = fns.fn102
x4 = fn279
xR = fn414
xn = fn1000
wU = { Heart = 1, ["Left lung"] = 2, ["Right lung"] = 3, Lungs = 4 }
wL = fn633
wx = fn1204
xh = fn1042
wI = function(cY)
    local AR_1, AR_2, AR_3
    if wN == cY then
        return
    end
    local AO = xh()
    local AQ = wN and AO
    local AQ_1, AQ_3, AQ_5
    if AQ then
        AQ_1, AR_1 = pcall(function()
            AO:SetAnimalCollisionPersistent(wN, false)
        end)
        if not AQ_1 then
            xJ("PersistCollision", AR_1)
        end
    end
    wN = cY
    if cY and AO then
        AQ_3, AR_2 = pcall(function()
            AO:SetAnimalCollisionPersistent(cY, true)
        end)
        if not AQ_3 then
            xJ("PersistCollision", AR_2)
        end
        local ProjectileBounds = cY:FindFirstChild("_ProjectileBounds")
        local AQ_4 = ProjectileBounds and ProjectileBounds:IsA("BasePart") and type(AO.HydrateAnimalFromBounds) == "function"
        if AQ_4 then
            AQ_5, AR_3 = pcall(function()
                AO:HydrateAnimalFromBounds(ProjectileBounds)
            end)
            if not AQ_5 then
                xJ("HydrateAnimal", AR_3)
            end
        end
    end
end
w5 = fn790
yb = fn1243
xC = fns.fn91
wY = function(dL, dM, dN)
    local Bg
    local Be
    local WorldPosition
    local Bf
    local Bd
    WorldPosition = nil
    Bd = nil
    Be = nil
    Bf = nil
    Bg = nil
    local Bw_2
    local Bv_2
    local Bi_1, Bi_7, Bi_9, Bi_13, Bi_15
    if typeof(dN) ~= "Vector3" then
        return false
    end
    local Bh = dL.BulletsInMagazine or 0
    local Bh_1, Bh_10, Bh_12, Bh_15, Bh_18, Bh_20
    if Bh < 1 then
        if type(dL.Reload) == "function" then
            Bh_1, Bi_1 = pcall(function()
                dL:Reload()
            end)
            if not Bh_1 then
                xJ("Reload", Bi_1)
            end
        end
        return false
    end
    Bf = w5()
    local Bh_2 = yb(dL)
    local Bi_2 = wQ()
    local Bj = Bi_2 and Bi_2[dL.Ammunition]
    local Bi_3 = Bf and Bh_2 and type(Bj) == "table"
    if not Bi_3 then
        return false
    end
    WorldPosition = Bh_2.WorldPosition
    if wF.WallCheck and dM then
        local Character = LocalPlayer.Character
        if not xC(WorldPosition, dN, dM, Character) then
            return false
        end
        Be = (dL.MuzzleVelocity or 800) / 0.28
        local Magnitude = (dN - WorldPosition).Magnitude
        if Bh_15 then
            return false
        end
        local Bh_8 = Magnitude / Be
        local Bi_5 = Vector3.new(dN.X, dN.Y + 17.5178585 * Bh_8 * Bh_8, dN.Z)
        Bd = Bi_5 - WorldPosition
        if Bd.Magnitude < 1 then
            return false
        end
        local Bh_9 = {}
        if type(dL.Attachments) == "table" then
            for k, v in dL.Attachments do
                local Bi_6 = type(v) == "table" and type(v.Name) == "string"
                if Bi_6 then
                    Bh_9[k] = v.Name
                elseif typeof(v) == "Instance" then
                    Bh_9[k] = v.Name
                end
            end
        end
        Bg = {
            MaxHits = 4,
            FireProjectileHit = true,
            BulletProperties = {
                Mass = Bj.Mass,
                DragCoefficient = Bj.DragCoefficient,
                Diameter = Bj.Diameter,
                Type = Bj.Type,
                Name = dL.Ammunition,
                Tracer = Bj.Tracer == true,
                CreateImpactEffect = true
            },
            Attachments = Bh_9,
            CrossSectionalArea = math.pi * (Bj.Diameter / 2) ^ 2 * 1e-06,
            WeaponModel = dL._modelReference
        }
        Bh_10, Bi_7 = pcall(function()
            Bf:Fire(WorldPosition, Bd.Unit, Be, Bg)
        end)
        if not Bh_18 then
            xJ("ProjectileFire", Bi_7)
            return false
        end
        local max = math.max
        local Bi_8 = dL.BulletsInMagazine
        if not ((Bv_2 * 2099 + Bw_2 * 2815 + Bv_2 * Bw_2) % 16777213 == 3969851) then
            Bi_8 = 1
        end
        dL.BulletsInMagazine = max(Bi_8 - 1, 0)
        if type(dL._updateGui) == "function" then
            Bh_12, Bi_9 = pcall(function()
                dL:_updateGui()
            end)
            if not Bh_20 then
                xJ("RifleGui", Bi_9)
            end
        end
        x6(dM)
        return true
    end
    Be = (dL.MuzzleVelocity or 800) / 0.28
    local Magnitude = (dN - WorldPosition).Magnitude
    Bh_15 = Magnitude < 1 or Be <= 0
    if Bh_15 then
        return false
    end
    local Bh_16 = Magnitude / Be
    local Bi_11 = Vector3.new(dN.X, dN.Y + 17.5178585 * Bh_16 * Bh_16, dN.Z)
    Bd = Bi_11 - WorldPosition
    if Bd.Magnitude < 1 then
        return false
    end
    local Bh_17 = {}
    if type(dL.Attachments) == "table" then
        for k, v in dL.Attachments do
            local Bi_12 = type(v) == "table" and type(v.Name) == "string"
            if Bi_12 then
                Bh_17[k] = v.Name
            elseif typeof(v) == "Instance" then
                Bh_17[k] = v.Name
            end
        end
    end
    Bg = {
        MaxHits = 4,
        FireProjectileHit = true,
        BulletProperties = {
            Mass = Bj.Mass,
            DragCoefficient = Bj.DragCoefficient,
            Diameter = Bj.Diameter,
            Type = Bj.Type,
            Name = dL.Ammunition,
            Tracer = Bj.Tracer == true,
            CreateImpactEffect = true
        },
        Attachments = Bh_17,
        CrossSectionalArea = math.pi * (Bj.Diameter / 2) ^ 2 * 1e-06,
        WeaponModel = dL._modelReference
    }
    Bh_18, Bi_13 = pcall(function()
        Bf:Fire(WorldPosition, Bd.Unit, Be, Bg)
    end)
    if not Bh_18 then
        xJ("ProjectileFire", Bi_13)
        return false
    end
    local max = math.max
    local Bi_14 = dL.BulletsInMagazine
    local Bx_2 = if Bi_14 then 1 else 0
    Bv_2 = 759 * Bx_2 + 2191 * (1 - Bx_2)
    Bw_2 = 665 * Bx_2 + 3848 * (1 - Bx_2)
    if not ((Bv_2 * 2099 + Bw_2 * 2815 + Bv_2 * Bw_2) % 16777213 == 3969851) then
        Bi_14 = 1
    end
    dL.BulletsInMagazine = max(Bi_14 - 1, 0)
    if type(dL._updateGui) == "function" then
        Bh_20, Bi_15 = pcall(function()
            dL:_updateGui()
        end)
        if not Bh_20 then
            xJ("RifleGui", Bi_15)
        end
    end
    x6(dM)
    return true
end
xd = fn1144
wT = fn889
x5 = "TempoHSAim"
x_ = false
xT = fns.fn68
xi = fn888
wO = fns.fn115
x0 = {}
xW = fn676
xB = fn805
xm = fn1315
x8 = fn585
if ((not ww or xc) and (ww or not ww) and (wv or not wv or ww and not ww) or (xc or not wv or (not xF or not xc) or (not xK and not xc or xK and not xF))) and ((not xF and not wv or (not ww or wv) or not xF and not ww and (not xc and wv)) and (not xK and not ww and (not xc and not xF) and (xF or xF or not ww and not xK))) or not (((not ww or xc) and (ww or not ww) and (wv or not wv or ww and not ww) or (xc or not wv or (not xF or not xc) or (not xK and not xc or xK and not xF))) and ((not xF and not wv or (not ww or wv) or not xF and not ww and (not xc and wv)) and (not xK and not ww and (not xc and not xF) and (xF or xF or not ww and not xK)))) then
    wB.UpdateEsp = function()
        local CH, CI
        if not wF.AnimalEsp and not wF.CorpseEsp then
            xB()
            return
        end
        CH = xM()
        if not CH then
            xB()
            return
        end
        CI = {}
        local function CJ_2(f0, f1, f2, f3)
            local CC_2
            local CB_2
            local attr = f0:GetAttribute("DisplayName")
            local CA = f1 and w2(wF.EspSpecies, attr)
            if not CA then
                return
            end
            local Magnitude = (f1.Position - CH.Position).Magnitude
            if Magnitude > wF.EspDistance then
                return
            end
            CI[f0] = true
            local CA_2 = x0[f0]
            if not CA_2 then
                xm(f0, f1, f2)
                CA_2 = x0[f0]
            end
            if CA_2 then
                CA_2.highlight.FillColor = f2
                CA_2.title.TextColor3 = f2
                CB_2, CC_2 = x8(f0, Magnitude, f3)
                CA_2.title.Text = CB_2
                CA_2.info.Text = CC_2
            end
        end
        if wF.AnimalEsp then
            local CK_5 = wv()
            if CK_5 then
                local EspColor = wF.EspColor
                for i, child in CK_5:GetChildren() do
                    if xR(child) then
                        local CK_6 = xn(child) or wS(child)
                        CJ_2(child, CK_6, EspColor, false)
                    end
                end
            end
        end
        if wF.CorpseEsp then
            local CK_7 = x4()
            if CK_7 then
                local CorpseEspColor = wF.CorpseEspColor
                for i, child in CK_7:GetChildren() do
                    if child:IsA("Model") then
                        local CK_8 = wS(child) or xn(child)
                        CJ_2(child, CK_8, CorpseEspColor, true)
                    end
                end
            end
        end
        for k, v in x0 do
            if not CI[k] then
                if v.gui then
                    v.gui:Destroy()
                end
                if v.highlight then
                    v.highlight:Destroy()
                end
                x0[k] = nil
            end
        end
    end
    xD = fn341
else
    xD.UpdateEsp = function()
        local CH, CI
        if not wF.AnimalEsp and not wF.CorpseEsp then
            xB()
            return
        end
        CH = xM()
        if not CH then
            xB()
            return
        end
        CI = {}
        local function CJ_1(f0, f1, f2, f3)
            local CC_1
            local CB_1
            local attr = f0:GetAttribute("DisplayName")
            local CA = f1 and w2(wF.EspSpecies, attr)
            if not CA then
                return
            end
            local Magnitude = (f1.Position - CH.Position).Magnitude
            if Magnitude > wF.EspDistance then
                return
            end
            CI[f0] = true
            local CA_1 = x0[f0]
            if not CA_1 then
                xm(f0, f1, f2)
                CA_1 = x0[f0]
            end
            if CA_1 then
                CA_1.highlight.FillColor = f2
                CA_1.title.TextColor3 = f2
                CB_1, CC_1 = x8(f0, Magnitude, f3)
                CA_1.title.Text = CB_1
                CA_1.info.Text = CC_1
            end
        end
        if wF.AnimalEsp then
            local CK_1 = wv()
            if CK_1 then
                local EspColor = wF.EspColor
                for i, child in CK_1:GetChildren() do
                    if xR(child) then
                        local CK_2 = xn(child) or wS(child)
                        CJ_1(child, CK_2, EspColor, false)
                    end
                end
            end
        end
        if wF.CorpseEsp then
            local CK_3 = x4()
            if CK_3 then
                local CorpseEspColor = wF.CorpseEspColor
                for i, child in CK_3:GetChildren() do
                    if child:IsA("Model") then
                        local CK_4 = wS(child) or xn(child)
                        CJ_1(child, CK_4, CorpseEspColor, true)
                    end
                end
            end
        end
        for k, v in x0 do
            if not CI[k] then
                if v.gui then
                    v.gui:Destroy()
                end
                if v.highlight then
                    v.highlight:Destroy()
                end
                x0[k] = nil
            end
        end
    end
    wB = fn341
end
xj = fn626
xI = fn863
xA = fn283
w3 = {}
w_ = false
wV = false
wG = {}
wC = function()
    local DC = not wF.AutoHarvest or w_ or wV
    local DC_3
    local DB_1 = DC
    local DI = if DB_1 then 1 else 0
    local DG = 1768 * DI + 3227 * (1 - DI)
    local DH = 2932 * DI + 3581 * (1 - DI)
    if not ((DG * 1419 + DH * 3662 + DG * DH) % 16777213 == 1652339) then
        DB_1 = wJ
    end
    if DB_1 then
        return
    end
    local Dy = xM()
    if not Dy then
        return
    end
    local DB_2 = os.clock()
    for k, v in CollectionService:GetTagged("HarvestAnimalPrompt") do
        if xj(v) then
            local Dz = xD(v)
            local DC_1 = w3[Dz]
            if Dz and (not DC_1 or DB_2 - DC_1 >= 1) then
                local DC_2 = xI(v)
                if w2(wF.HarvestSpecies, DC_2) then
                    local DA = xA(v)
                    if DA then
                        DC_3 = (DA - Dy.Position).Magnitude
                    else
                        DC_3 = 0
                    end
                    local Dx = DC_3
                    if Dx <= wF.HarvestDistance then
                        w3[Dz] = DB_2
                        wM = Dx
                        w_ = true
                        task.spawn(function()
                            local Dv_1
                            local Du_1
                            Du_1, Dv_1 = pcall(function()
                                local CFrame2 = Dy.CFrame
                                local Do = DA
                                local Dp = false
                                if Do then
                                    Do = Dy.Parent
                                end
                                if Do then
                                    Do = Dx > 8
                                end
                                if Do then
                                    Dy.CFrame = CFrame.new(DA + Vector3.new(0, 4, 0))
                                    Dp = true
                                    task.wait(xr)
                                end
                                if not wF.Unloaded then
                                    wu:FireServer(Dz)
                                end
                                if Dp then
                                    task.wait(xr)
                                    if Dy.Parent then
                                        Dy.CFrame = CFrame2
                                    end
                                end
                                task.wait(xe)
                            end)
                            if not Du_1 then
                                xJ("AutoHarvest", Dv_1)
                            end
                            w_ = false
                        end)
                        return
                    end
                end
            end
        end
    end
end
x1 = function(hQ)
    local DQ
    local DP
    local DR
    DP = nil
    DQ = nil
    DR = nil
    DP = xN()
    DR = xq()
    local DS = not DP
    local DS_1, DS_2
    local DY = if DS then 1 else 0
    local DW = 4059 * DY + 3857 * (1 - DY)
    local DX = 3548 * DY + 973 * (1 - DY)
    if not ((DW * 2440 + DX * 1800 + DW * DX) % 16777213 == 13914479) then
        DS = not DR
    end
    if not DS then
        DS = type(hQ) ~= "table"
    end
    if DS then
        return 0
    end
    DS_1, DQ = pcall(function()
        return DP.GetFinalScore(hQ)
    end)
    local DT = not DS_1 or type(DQ) ~= "number"
    local DT_1
    if DT then
        return 0
    end
    DS_2, DT_1 = pcall(function()
        return DR.GetRarity(DQ)
    end)
    local DU = not DS_2
    local D0 = if DU then 1 else 0
    local DZ = 392 * D0 + 2250 * (1 - D0)
    local D_ = 2255 * D0 + 810 * (1 - D0)
    if not ((DZ * 3046 + D_ * 2355 + DZ * D_) % 16777213 == 7388517) then
        DU = type(DT_1) ~= "string"
    end
    if DU then
        return 0
    end
    return xz[DT_1] or 0
end
wZ = false
wR = fn144
x2 = function(ie, ig)
    if type(ie) ~= "table" then
        return
    end
    local Species = ie.Species
    local D5_5, D5_6
    if not w2(wF.PreserveSpecies, Species) then
        return
    end
    local D5_1 = xz[wF.MinRarity] or 0
    local D6_2, D6_3
    if x1(ie) < D5_1 then
        return
    end
    local D5_2 = type(ig) == "number" and ig > wF.PreserveDistance
    if D5_2 then
        return
    end
    local Id = ie.Id
    local D5_3 = Id == ""
    local D6_1 = type(Id) ~= "string" or D5_3
    if D6_1 then
        return
    end
    if ie.IsBird == true and xF then
        D5_5, D6_2 = pcall(function()
            xF:InvokeServer(Id)
        end)
        if not D5_5 then
            xJ("PreserveBird", D6_2)
        end
    else
        D5_6, D6_3 = pcall(function()
            x9:InvokeServer(Id)
        end)
        if not D5_6 then
            xJ("PreserveHarvest", D6_3)
        end
    end
end
wz = function()
    local range, En, data, AutoPreserve
    if wZ or wF.Unloaded then
        return
    end
    local Eq_1 = table.remove(wG, 1)
    if not Eq_1 then
        wV = false
        return
    end
    data = Eq_1.data
    range = Eq_1.range
    AutoPreserve = wF.AutoPreserve
    local Eq_2 = wF.AutoHarvest
    local Ev = if Eq_2 then 1 else 0
    local Et = 3930 * Ev + 3989 * (1 - Ev)
    local Eu = 1998 * Ev + 723 * (1 - Ev)
    if not ((Et * 3822 + Eu * 86 + Et * Eu) % 16777213 == 6267215) then
        Eq_2 = wF.AutoPreserve
    end
    En = Eq_2
    if not AutoPreserve and not En then
        wz()
        return
    end
    wV = true
    wZ = true
    task.spawn(function()
        local Eh_1
        local Eg_1
        Eg_1, Eh_1 = pcall(function()
            if AutoPreserve then
                task.wait(xo)
                if not wF.Unloaded then
                    x2(data, range)
                end
                task.wait(xk)
            else
                task.wait(xo)
            end
            if not wF.Unloaded and En then
                wR()
            end
            task.wait(xg)
        end)
        if not Eg_1 then
            xJ("HarvestUi", Eh_1)
        end
        wZ = false
        wz()
    end)
end
yf = fn128
wy = fn1097
xU = function(ja)
    local EE_2
    local ED_2
    if not ja then
        return
    end
    for k, v in xt do
        local ED_1 = ja:FindFirstChild(v)
        local EE_1 = ED_1 and ED_1:IsA("BasePart")
        if EE_1 then
            return ED_1.Position
        end
    end
    for i, child in ja:GetChildren() do
        local EV = child
        local EY = if EV:IsA("Model") then 1 else 0
        if EY == 1 then
            ED_2, EE_2 = pcall(function()
                return EV:GetBoundingBox()
            end)
            local EF = ED_2 and typeof(EE_2) == "CFrame"
            if EF then
                return EE_2.Position
            end
            if EV.PrimaryPart then
                return EV.PrimaryPart.Position
            end
        end
    end
end
xb = fns.fn49
xL = fn923
xc = 0
w8 = function()
    local Fu, Fv, Fw, Fx, Fy
    local Fz = not wF.AutoBuyAmmo
    local FH = if Fz then 1 else 0
    local FF = 1156 * FH + 2900 * (1 - FH)
    local FG = 3733 * FH + 1797 * (1 - FH)
    if not ((FF * 3611 + FG * 1900 + FF * FG) % 16777213 == 15582364) then
        Fz = wJ
    end
    if Fz or w_ or wV then
        return
    end
    if os.clock() - xc < 2 then
        return
    end
    Fw = xM()
    if not Fw then
        return
    end
    local Fz_2 = xu()
    local FA_1 = not Fz_2 or type(Fz_2.Data) ~= "table"
    if FA_1 then
        return
    end
    Fu = xL(Fz_2)
    if type(Fu) ~= "string" then
        return
    end
    local FA_3 = Fz_2.Data.Ammunition and Fz_2.Data.Ammunition[Fu] or 0
    if type(FA_3) ~= "number" then
        FA_3 = 0
    end
    if FA_3 > wF.AmmoThreshold then
        return
    end
    local FB_1 = wQ()
    local FB_2 = FB_1 and FB_1[Fu]
    if type(FB_2) ~= "table" then
        return
    end
    local FC_1 = FB_2.MaxAmmo or 0
    local FC_2 = math.max(FC_1 - FA_3, 0)
    if FC_2 <= 0 then
        return
    end
    Fx = FC_2
    if wF.AmmoBuyAmount == "10" then
        Fx = math.min(FC_2, 10)
    end
    local FB_3 = FB_2.Price or 0
    local FA_5 = Fz_2.Data.Money or 0
    if FB_3 > 0 and FA_5 < FB_3 * Fx then
        Fx = math.floor(FA_5 / FB_3)
    end
    if Fx <= 0 then
        return
    end
    Fv = xb()
    Fy = xU(wy(Fv))
    xc = os.clock()
    wJ = true
    task.spawn(function()
        local Fp_1
        local Fo_1
        Fo_1, Fp_1 = pcall(function()
            local CFrame2 = Fw.CFrame
            local Fl = Fy
            local Fm = false
            if Fl then
                Fl = Fw.Parent
            end
            if Fl then
                Fl = (Fy - Fw.Position).Magnitude > 12
            end
            if Fl then
                Fw.CFrame = CFrame.new(Fy + Vector3.new(0, 4, 0))
                Fm = true
                task.wait(xr)
            end
            if not wF.Unloaded then
                xZ:InvokeServer(Fu, Fx, Fv)
            end
            if Fm then
                task.wait(xr)
                if Fw.Parent then
                    Fw.CFrame = CFrame2
                end
            end
        end)
        if not Fo_1 then
            xJ("AutoBuyAmmo", Fp_1)
        end
        wJ = false
    end)
end
wA = fn555
xP = fn293
xv = fn523
task.spawn(worker)
task.spawn(worker2)
ya(yk.OnClientEvent:Connect(yf))
wH = fn925
xK = fn1269
xK(x4())
ya(Workspace.ChildAdded:Connect(onChildAdded))
wB.SetFlag = fn225
wB.SetSpecies = fn662
wB.SetEspColor = fn528
wB.Unload = fn1205
getgenv()[xG] = wB
Li_3 = function()
    local onDiscord
    local KV
    local Unload
    local Library
    local K_
    Library = nil
    Unload = nil
    KV = nil
    onDiscord = nil
    K_ = nil
    local KO, UserInputService, Toggles, KS, KU, ThemeManager, TeleportService, Options, SaveManager, HttpService, K2
    K2 = "https://discord.gg/K7Qxnxkk46"
    HttpService = game:GetService("HttpService")
    UserInputService = game:GetService("UserInputService")
    KU = "https://tempohub.shop"
    KS = "Hunting Season"
    TeleportService = game:GetService("TeleportService")
    K_ = "https://discord.gg/K7Qxnxkk46"
    Library = getgenv().Library
    ThemeManager = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = Library.Toggles
    Options = Library.Options
    Unload = wB.Unload
    wB.Unload = function()
        if not Library.Unloaded then
            Library:Unload()
        else
            Unload()
        end
    end
    Library:OnUnload(Unload)
    KV = function(mp, mq)
        if xx("setclipboard") then
            setclipboard(mp)
        elseif xx("toclipboard") then
            toclipboard(mp)
        end
        Library:Notify(mq)
    end
    onDiscord = function()
        KV(K_, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "[Belta]Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = K_, Copyable = true }, "|", KS },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(true, { Color = Color3.fromRGB(242, 154, 196), Radius = 24, Transparency = 0.3 })
    KO = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gamepad-2"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
    local function K3_1(mA)
        local DiscordGroup = mA:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    for k, v in KO do
        if k ~= "Info" then
            K3_1(v)
        end
    end
    local function K4()
        local AutoShootGroup = KO.Main:AddLeftGroupbox("Auto Shoot", "crosshair")
        AutoShootGroup:AddToggle("AutoShoot", {
            Text = "Auto Shoot Animals",
            Default = false,
            Callback = function(mI)
                wB.SetFlag("AutoShoot", mI)
            end
        })
        AutoShootGroup:AddSlider("ShootDistance", {
            Text = "Max Distance",
            Default = 400,
            Min = 50,
            Max = 2000,
            Rounding = 0,
            Callback = function(mL)
                wB.SetFlag("ShootDistance", mL)
            end
        })
        AutoShootGroup:AddSlider("ShootFov", {
            Text = "FOV",
            Default = 180,
            Min = 10,
            Max = 360,
            Rounding = 0,
            Callback = function(mN)
                wB.SetFlag("ShootFov", mN)
            end
        })
        AutoShootGroup:AddSlider("ShootDelay", {
            Text = "Shot Delay",
            Default = 0.35,
            Min = 0.05,
            Max = 2,
            Rounding = 2,
            Callback = function(mP)
                wB.SetFlag("ShootDelay", mP)
            end
        })
        AutoShootGroup:AddDivider("Filters")
        AutoShootGroup:AddDropdown("ShootSex", {
            Text = "Sex",
            Values = { "Any", "Male", "Female" },
            Default = 1,
            Callback = function(mR)
                wB.SetFlag("ShootSex", mR)
            end
        })
        AutoShootGroup:AddToggle("WallCheck", {
            Text = "Wall Check",
            Default = true,
            Callback = function(mT)
                wB.SetFlag("WallCheck", mT)
            end
        })
        AutoShootGroup:AddDropdown("ShootSpecies", {
            Text = "Animals",
            Values = xE,
            Default = xE,
            Multi = true,
            Expandable = true,
            ExpandColumns = 2,
            Callback = function(mX)
                wB.SetSpecies("Shoot", mX)
            end
        })
        local AutoHarvestGroup = KO.Main:AddLeftGroupbox("Auto Harvest", "leaf")
        AutoHarvestGroup:AddToggle("AutoHarvest", {
            Text = "Auto Harvest",
            Default = false,
            Callback = function(m_)
                wB.SetFlag("AutoHarvest", m_)
            end
        })
        AutoHarvestGroup:AddSlider("HarvestDistance", {
            Text = "Max Distance",
            Default = 400,
            Min = 10,
            Max = 2000,
            Rounding = 0,
            Callback = function(m1)
                wB.SetFlag("HarvestDistance", m1)
            end
        })
        AutoHarvestGroup:AddDropdown("HarvestSpecies", {
            Text = "Animals",
            Values = xE,
            Default = xE,
            Multi = true,
            Expandable = true,
            ExpandColumns = 2,
            Callback = function(m3)
                wB.SetSpecies("Harvest", m3)
            end
        })
        local MarkerTeleportGroup = KO.Main:AddLeftGroupbox("Marker Teleport", "map-pin")
        MarkerTeleportGroup:AddToggle("MarkerTeleport", {
            Text = "Marker Teleport",
            Default = false,
            Callback = function(m6)
                wB.SetFlag("MarkerTeleport", m6)
                wE = nil
            end
        })
        local AnimalEspGroup = KO.Main:AddRightGroupbox("Animal ESP", "eye")
        AnimalEspGroup:AddToggle("AnimalEsp", {
            Text = "Animal ESP",
            Default = false,
            Callback = function(nc)
                wB.SetFlag("AnimalEsp", nc)
                wB.UpdateEsp()
            end
        })
        AnimalEspGroup:AddToggle("CorpseEsp", {
            Text = "Dead Corpse ESP",
            Default = false,
            Callback = function(ne)
                wB.SetFlag("CorpseEsp", ne)
                wB.UpdateEsp()
            end
        })
        AnimalEspGroup:AddSlider("EspDistance", {
            Text = "Max Distance",
            Default = 800,
            Min = 100,
            Max = 3000,
            Rounding = 0,
            Callback = function(ng)
                wB.SetFlag("EspDistance", ng)
            end
        })
        AnimalEspGroup:AddToggle("EspShowDistance", {
            Text = "Show Distance",
            Default = true,
            Callback = function(ni)
                wB.SetFlag("EspShowDistance", ni)
            end
        })
        AnimalEspGroup:AddToggle("EspShowSex", {
            Text = "Show Sex",
            Default = true,
            Callback = function(nk)
                wB.SetFlag("EspShowSex", nk)
            end
        })
        AnimalEspGroup:AddLabel("Color"):AddColorPicker("EspColor", {
            Default = Color3.fromRGB(255, 170, 70),
            Callback = function(nm)
                wB.SetEspColor(nm)
            end
        })
        AnimalEspGroup:AddLabel("Corpse Color"):AddColorPicker("CorpseEspColor", {
            Default = Color3.fromRGB(220, 70, 70),
            Callback = function(no)
                if typeof(no) == "Color3" then
                    wB.SetFlag("CorpseEspColor", no)
                end
            end
        })
        AnimalEspGroup:AddDropdown("EspSpecies", {
            Text = "Animals",
            Values = xE,
            Default = xE,
            Multi = true,
            Expandable = true,
            ExpandColumns = 2,
            Callback = function(nq)
                wB.SetSpecies("Esp", nq)
            end
        })
        local AutoPreserveGroup = KO.Main:AddRightGroupbox("Auto Preserve", "trophy")
        AutoPreserveGroup:AddToggle("AutoPreserve", {
            Text = "Auto Preserve",
            Default = false,
            Callback = function(nt)
                wB.SetFlag("AutoPreserve", nt)
            end
        })
        AutoPreserveGroup:AddSlider("PreserveDistance", {
            Text = "Max Distance",
            Default = 400,
            Min = 10,
            Max = 2000,
            Rounding = 0,
            Callback = function(nv)
                wB.SetFlag("PreserveDistance", nv)
            end
        })
        AutoPreserveGroup:AddDropdown("MinRarity", {
            Text = "Min Rarity",
            Values = { "Bronze", "Silver", "Gold", "Diamond", "Ruby", "Mythical" },
            Default = 1,
            Callback = function(nx)
                wB.SetFlag("MinRarity", nx)
            end
        })
        AutoPreserveGroup:AddDropdown("PreserveSpecies", {
            Text = "Animals",
            Values = xE,
            Default = xE,
            Multi = true,
            Expandable = true,
            ExpandColumns = 2,
            Callback = function(nz)
                wB.SetSpecies("Preserve", nz)
            end
        })
        local AutoBuyAmmoGroup = KO.Main:AddRightGroupbox("Auto Buy Ammo", "box")
        AutoBuyAmmoGroup:AddToggle("AutoBuyAmmo", {
            Text = "Auto Buy Ammo",
            Default = false,
            Callback = function(nC)
                wB.SetFlag("AutoBuyAmmo", nC)
            end
        })
        AutoBuyAmmoGroup:AddSlider("AmmoThreshold", {
            Text = "Buy Below",
            Default = 10,
            Min = 0,
            Max = 200,
            Rounding = 0,
            Callback = function(nE)
                wB.SetFlag("AmmoThreshold", nE)
            end
        })
        AutoBuyAmmoGroup:AddDropdown("AmmoBuyAmount", {
            Text = "Amount",
            Values = { "10", "Max" },
            Default = 2,
            Callback = function(nG)
                wB.SetFlag("AmmoBuyAmount", nG)
            end
        })
        AutoBuyAmmoGroup:AddDropdown("AmmoStore", {
            Text = "Store",
            Values = xw,
            Default = 1,
            Callback = function(nK)
                wB.SetFlag("AmmoStore", nK)
            end
        })
    end
    K4()
    local function K3_2()
        local Hx
        local HG
        local Hy
        local HF
        local HD
        local Hz
        Hx = nil
        Hy = nil
        Hz = nil
        HD = nil
        HF = nil
        HG = nil
        local Label3, Label2, HA, HB, Label, HE
        HF = "#e05a5a"
        local HH = "#8b93a3"
        Hy = "#e8a34d"
        HD = "#7fd47f"
        Hz = function(nT, nU)
            return string.format('<font color="%s">%s</font>', nU, nT)
        end
        HB = function(nW, nX, nY)
            return string.format("<b>%s</b> %s %s", nW, Hz("-", "#5a6070"), Hz(nX, nY))
        end
        local function HJ()
            local GD = hookfunction ~= nil
            local GE = hookmetamethod ~= nil
            local GF = getrawmetatable ~= nil
            local GG = setrawmetatable ~= nil
            local GH = getgc ~= nil
            local GI = getgenv ~= nil
            local GJ = getreg ~= nil
            local GK = getconnections ~= nil
            local GL = firesignal ~= nil
            local GM = getcallbackvalue ~= nil
            local GN = setclipboard ~= nil
            local GO = getcustomasset ~= nil
            local GP = getnamecallmethod ~= nil
            local GQ = isexecutorclosure ~= nil
            local GR = fireproximityprompt ~= nil
            local GS = firetouchinterest ~= nil
            local GT = WebSocket ~= nil
            local GU = readfile ~= nil
            local GV = writefile ~= nil
            local GW = request
            local G6 = if GW then 1 else 0
            local G4 = 3687 * G6 + 38 * (1 - G6)
            local G5 = 740 * G6 + 3813 * (1 - G6)
            if not ((G4 * 204 + G5 * 639 + G4 * G5) % 16777213 == 3953388) then
                GW = http_request
            end
            local GX = GW ~= nil
            local GZ = (debug and debug.getupvalues) ~= nil
            local G0 = (debug and debug.setupvalue) ~= nil
            local G1 = 0
            local G2 = { GD, GE, GF, GG, GH, GI, GJ, GK, GL, GM, GN, GO, GP, GQ, GR, GS, GT, GU, GV, GX, GZ, G0 }
            for i, v in ipairs(G2) do
                if v then
                    G1 += 1
                end
            end
            local GD_1 = G1 / #G2
            if GD_1 >= 0.9 then
                return Hz("Full Support", HD)
            elseif GD_1 >= 0.6 then
                return Hz("Half Support", Hy)
            else
                return Hz("Low Support", HF)
            end
        end
        HG = "Unknown"
        pcall(function()
            local Hh_1
            local Hg_1
            if identifyexecutor then
                Hh_1, Hg_1 = identifyexecutor()
                local Hi = Hh_1 ~= ""
                local Hj = type(Hh_1) == "string" and Hi
                if Hj then
                    local Hi_1 = type(Hg_1) == "string" and Hg_1 ~= "" and Hh_1 .. " " .. Hg_1
                    HG = Hi_1 or Hh_1
                end
            end
        end)
        local HK = HJ()
        Hx = os.clock()
        HE = function()
            local Ho = math.floor(os.clock() - Hx)
            if Ho < 60 then
                return Ho .. "s"
            elseif Ho < 3600 then
                return string.format("%dm %ds", math.floor((Ho) / (60)), Ho % 60)
            else
                return string.format("%dh %dm", math.floor((Ho) / (3600)), math.floor((Ho % 3600) / (60)))
            end
        end
        local UserGroup = KO.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(HB("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, HD), true)
        UserGroup:AddLabel(HB("UserId", tostring(LocalPlayer.UserId), "#6ec1ff"), true)
        UserGroup:AddLabel(HB("Executor", HG .. "  " .. HK, HD), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(HB("Session", HE(), Hy), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                KV(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                KV("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = KO.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddDivider("Server")
        SessionGroup:AddLabel(HB("Game", KS, "#6ec1ff"), true)
        Label2 = SessionGroup:AddLabel(HB("Players", "0/0", HD), true)
        HA = tostring(game.JobId)
        local HI = #HA > 18 and string.sub(HA, 1, 18) .. "..."
        local HK_1 = HI or HA
        SessionGroup:AddLabel(HB("Job", HK_1, HH), true)
        Label = SessionGroup:AddLabel(HB("Ping", "0 ms", Hy), true)
        SessionGroup:AddDivider()
        SessionGroup:AddButton({
            Text = "Rejoin Server",
            Func = function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        })
        SessionGroup:AddButton({
            Text = "Copy Job ID",
            Func = function()
                KV(HA, "Copied Job ID")
            end
        })
        task.spawn(function()
            local Hr_1
            local Hq_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(HB("Session", HE(), Hy))
                Label2:SetText(HB("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), HD))
                Hq_1, Hr_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local Hq_2 = Hq_1 and Hr_1 .. " ms" or "n/a"
                Label:SetText(HB("Ping", Hq_2, Hy))
            end
        end)
        local SocialsGroup = KO.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                if setclipboard then
                    setclipboard(K2)
                elseif toclipboard then
                    toclipboard(K2)
                end
                Library:Notify("Copied Rscripts profile to clipboard")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                KV(KU, "Copied website link")
            end
        })
    end
    K3_2()
    local function K3_3()
        local pe
        local pf
        local pd
        local pc
        local MovementGroup = KO.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = KO.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        pc = {}
        pe = {}
        pf = {}
        local pb = {}
        pd = {}
        local function pg()
            for k, v in pc do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(pc)
        end
        local function pk()
            for k, v in pd do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(pd)
        end
        local function po()
            for k, v in pe do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(pe)
        end
        local function ps(pt)
            if not pt:IsA("ProximityPrompt") then
                return
            end
            if pf[pt] == nil then
                pf[pt] = {
                    HoldDuration = pt.HoldDuration,
                    MaxActivationDistance = pt.MaxActivationDistance,
                    RequiresLineOfSight = pt.RequiresLineOfSight
                }
            end
            pt.HoldDuration = 0
            pt.MaxActivationDistance = 50
            pt.RequiresLineOfSight = false
        end
        local function pv()
            for k, v in pf do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(pf)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                po()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                pk()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                pg()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                    pcall(ps, v)
                end
            else
                pv()
            end
        end)
        table.insert(pb, Workspace.DescendantAdded:Connect(function(pO)
            if Toggles.InstantProximityPrompt.Value then
                ps(pO)
            end
        end))
        table.insert(pb, RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if pc[v] == nil then
                        pc[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(pb, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local IC = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and IC then
                IC:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(pb, RunService.RenderStepped:Connect(function(p8)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local IF = Character and Character:FindFirstChildOfClass("Humanoid")
            local IG = Character
            if IG then
                IG = Character:FindFirstChild("HumanoidRootPart")
            end
            local IE_1 = IG
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and IF then
                if pd[IF] == nil then
                    pd[IF] = IF.WalkSpeed
                end
                IF.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and IE_1 and IF and CurrentCamera then
                if pe[IF] == nil then
                    pe[IF] = IF.PlatformStand
                end
                IF.PlatformStand = true
                local IG_4 = Vector3.zero
                if not UserInputService:GetFocusedTextBox() then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        IG_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        IG_4 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        IG_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        IG_4 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        IG_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        IG_4 -= Vector3.new(0, 1, 0)
                    end
                end
                IE_1.AssemblyLinearVelocity = Vector3.zero
                if IG_4.Magnitude > 0 then
                    IE_1.CFrame = IE_1.CFrame + IG_4.Unit * Options.FlySpeed.Value * p8
                end
            end
        end))
        Library:OnUnload(function()
            for k, v in pb do
                v:Disconnect()
            end
            pg()
            pk()
            po()
            pv()
        end)
    end
    K3_3()
    local function K3_4()
        local q4
        local qu
        local Lighting = game:GetService("Lighting")
        local VirtualUser = game:GetService("VirtualUser")
        local GuiService = game:GetService("GuiService")
        local qt = {}
        local CoreGui = game:GetService("CoreGui")
        qu = {}
        local qv
        local qx = 0
        local qw = false
        local qy = os.clock()
        local MenuGroup = KO.Settings:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        local Label = MenuGroup:AddLabel("AFK triggers: 0")
        local function qC()
            local CurrentCamera = Workspace.CurrentCamera
            if not CurrentCamera then
                return
            end
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero, CurrentCamera.CFrame)
            qx += 1
            qy = os.clock()
            Label:SetText("AFK triggers: " .. qx)
        end
        local function onAntiGameplayPause(qL)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not qL)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not qL
                end
            end)
            if qL then
                pcall(function()
                    if sethiddenproperty then
                        sethiddenproperty(LocalPlayer, "GameplayPaused", false)
                    else
                        LocalPlayer.GameplayPaused = false
                    end
                end)
            end
        end
        local function qW()
            for k, v in qu do
                local I3 = k
                local I5 = v
                if I3.Parent then
                    pcall(function()
                        I3.Enabled = I5
                    end)
                end
            end
            table.clear(qu)
            if qv then
                pcall(function()
                    settings().Rendering.QualityLevel = qv.Quality
                end)
                Lighting.GlobalShadows = qv.Shadows
                Lighting.FogEnd = qv.Fog
                qv = nil
            end
        end
        q4 = { ParticleEmitter = true, Trail = true, Smoke = true, Fire = true, Sparkles = true, Beam = true }
        local function q5(q6)
            if q4[q6.ClassName] then
                if qu[q6] == nil then
                    qu[q6] = q6.Enabled
                end
                q6.Enabled = false
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true, Callback = onAntiGameplayPause })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(q9)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not q9)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(re)
                if re then
                    if not qv then
                        qv = {
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
                    for i, descendant in Workspace:GetDescendants() do
                        pcall(q5, descendant)
                    end
                else
                    qW()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        local ScriptGroup = KO.Settings:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        table.insert(qt, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value then
                pcall(qC)
            end
        end))
        table.insert(qt, Workspace.DescendantAdded:Connect(function(rt)
            if Toggles.FpsBoost.Value then
                q5(rt)
            end
        end))
        local function rw(rx)
            if qw or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            qw = true
            local Jh_1 = pcall(function()
                if rx then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not Jh_1 then
                qw = false
                if not rx then
                    rw(true)
                end
            end
        end
        table.insert(qt, TeleportService.TeleportInitFailed:Connect(function(rK)
            if rK == LocalPlayer and qw then
                qw = false
                task.delay(3, function()
                    rw(true)
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local Jq = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            if Library.Unloaded or not Jq then
                return
            end
            table.insert(qt, Jq.ChildAdded:Connect(function(rV)
                if rV.Name == "ErrorPrompt" then
                    rw(false)
                end
            end))
        end)
        task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    onAntiGameplayPause(true)
                end
                local Jt = Toggles.AntiAfk.Value and os.clock() - qy >= 60
                if Jt then
                    pcall(qC)
                end
                task.wait(1)
            end
        end)
        Library:OnUnload(function()
            for k, v in qt do
                v:Disconnect()
            end
            onAntiGameplayPause(false)
            qW()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    K3_4()
    local function K3_5()
        local KF, KG, KH, KI
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("TempoHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(KO.Settings)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/HuntingSeason")
        local KJ = SaveManager:BuildConfigSection(KO.Settings)
        KI = function(sh, si)
            local JD = sh == "Toggle" and Toggles
            local JI = if JD then 1 else 0
            local JG = 612 * JI + 1074 * (1 - JI)
            local JH = 554 * JI + 2675 * (1 - JI)
            if not ((JG * 3526 + JH * 327 + JG * JH) % 16777213 == 2678118) then
                JD = Options
            end
            local JD_1 = JD[si]
            local JC_2 = type(JD_1) == "table" and JD_1.Type == sh
            return JC_2 and JD_1 or nil
        end
        KG = function(sr, ss)
            local Type = ss.Type
            if Type == "Toggle" then
                return { idx = sr, type = "Toggle", value = ss.Value == true }
            elseif Type == "Slider" then
                return { idx = sr, type = "Slider", value = tostring(ss.Value) }
            elseif Type == "Dropdown" then
                return { idx = sr, type = "Dropdown", multi = ss.Multi == true, value = ss.Value }
            elseif Type == "Input" then
                local JK = ss.Value or ""
                return { idx = sr, type = "Input", text = tostring(JK) }
            elseif Type == "ColorPicker" then
                return { idx = sr, type = "ColorPicker", value = ss.Value:ToHex(), transparency = ss.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = sr,
                    type = "KeyPicker",
                    mode = ss.Mode,
                    key = ss.Value,
                    modifiers = ss.Modifiers,
                    toggled = ss.Toggled
                }
            else
                return nil
            end
        end
        KF = function()
            local JT = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local JU = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if JU then
                        local JU_1 = KG(k, v)
                        if JU_1 then
                            JT[#JT + 1] = JU_1
                        end
                    end
                end
            end
            table.sort(JT, function(sC, sD)
                if sC.type ~= sD.type then
                    return sC.type < sD.type
                end
                return sC.idx < sD.idx
            end)
            return { objects = JT }
        end
        KH = function(sF)
            local Kc
            Kc = nil
            local Kd = type(sF) ~= "table"
            local Kh = if Kd then 1 else 0
            local Kf = 3149 * Kh + 364 * (1 - Kh)
            local Kg = 1284 * Kh + 2222 * (1 - Kh)
            if not ((Kf * 270 + Kg * 3603 + Kf * Kg) % 16777213 == 9519798) then
                Kd = type(sF.idx) ~= "string"
            end
            if not Kd then
                Kd = type(sF.type) ~= "string"
            end
            if not Kd then
                Kd = SaveManager.Ignore[sF.idx]
            end
            if Kd then
                return false
            end
            Kc = KI(sF.type, sF.idx)
            if not Kc then
                return false
            end
            local Kd_1 = pcall(function()
                if sF.type == "Input" then
                    if type(sF.text) ~= "string" then
                        return
                    end
                    Kc:SetValue(sF.text)
                elseif sF.type == "ColorPicker" then
                    Kc:SetValueRGB(Color3.fromHex(sF.value), sF.transparency)
                elseif sF.type == "KeyPicker" then
                    Kc:SetValue({ sF.key, sF.mode, sF.modifiers })
                    if sF.mode == "Toggle" and sF.toggled ~= nil then
                        Kc.Toggled = sF.toggled
                        Kc:Update()
                    end
                else
                    Kc:SetValue(sF.value)
                end
            end)
            return Kd_1
        end
        KJ:AddDivider()
        KJ:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        KJ:AddButton("Export Config to Clipboard", function()
            local Kj_1
            local Ki_1
            Ki_1, Kj_1 = pcall(HttpService.JSONEncode, HttpService, KF())
            if not Ki_1 then
                Library:Notify("Failed to encode the config")
                return
            end
            local Ki_2 = setclipboard or toclipboard
            local Ki_3 = type(Ki_2) ~= "function" or not pcall(Ki_2, Kj_1)
            if Ki_3 then
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Config copied to clipboard", 6)
        end)
        KJ:AddButton("Import Config from Clipboard Text", function()
            local Ko_1
            local Km = Options.SaveManager_ImportSource.Value
            local Km_1
            local Ks = if Km then 1 else 0
            local Kq = 1131 * Ks + 2986 * (1 - Ks)
            local Kr = 3660 * Ks + 1664 * (1 - Ks)
            if not ((Kq * 3766 + Kr * 4017 + Kq * Kr) % 16777213 == 6323813) then
                Km = ""
            end
            local Kn = tostring(Km):match("^%s*(.-)%s*$")
            if Kn == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            Km_1, Ko_1 = pcall(HttpService.JSONDecode, HttpService, Kn)
            local Kn_1 = not Km_1 or type(Ko_1) ~= "table" or type(Ko_1.objects) ~= "table"
            if Kn_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            local Km_2 = 0
            for i, v in ipairs(Ko_1.objects) do
                if KH(v) then
                    Km_2 += 1
                end
            end
            if Km_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local Ko_2 = Km_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(Km_2, Ko_2), 6)
        end)
        SaveManager:LoadAutoloadConfig()
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    K3_5()
end
Li_3()
end)(...)

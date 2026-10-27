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
getgenv().TempoHoodSubtitle = "+1 FOLLOWERS PER CLICK"
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
local kq
local kQ
local jP
local ClickRemote
local kW
local jV
local kD
local kj
local Options
local j6
local LocalPlayer
local kc
local Library
local kC
local TitleRoll
local j_
local kI
local ko
local j5
local connection
local kv
local kb
local kB
local kh
local k_
local jZ
local kN
local RebirthRemote
local VirtualUser
local jS
local kA
local kg
local kZ
local ChangePet
local kG
local Label
local j3
local Toggles
local ks
local j9
local kS
local connection2
local kY
local WorldManager
local kF
local kl
local j2
local kL
local j8
local kR
local ky
local ke
local jW
local kE
local j1
local kK
local function fn21(aE)
    local l7 = Toggles[aE]
    return l7 ~= nil and l7.Value == true
end
local function worker11()
    while not Library.Unloaded do
        if kW("AutoFollowers") then
            pcall(kA)
        end
        task.wait(kF("FollowersDelay", 0.05))
    end
end
local function fn49()
    local nWins = LocalPlayer:FindFirstChild("nWins")
    return nWins and nWins.Value or 0
end
local function fn52(aZ)
    local Character = LocalPlayer.Character
    if not Character then
        return
    end
    if Character.PrimaryPart then
        Character:PivotTo(aZ)
    else
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = aZ
        end
    end
end
local function worker12()
    while not Library.Unloaded do
        if kW("AutoClick") then
            j5()
        end
        task.wait(kF("ClickDelay", 0.05))
    end
end
local function fn70()
    kE(kL, "Copied Discord invite to clipboard")
end
local function fn71(d_)
    if Toggles.AutoBuyAura and Toggles.AutoBuyAura.Value then
        Toggles.AutoBuyAura:SetValue(false)
    end
    if d_ then
        Library:Notify(d_)
    end
end
local function fn85()
    local mJ = jW()
    if mJ then
        jV(mJ)
    end
end
local function fn92()
    local nw = LocalPlayer:GetAttribute("World") or 1
    local nw_1 = WorldManager:GetMap(nw)
    if not nw_1 then
        return nil
    end
    local Platform = nw_1:FindFirstChild("Platform")
    if not Platform then
        return nil
    end
    local nw_2 = math.clamp(j1(), 1, 20)
    local ny = Platform:FindFirstChild("Platform" .. nw_2)
    if not ny then
        return nil
    end
    local ProximityPrompt = ny:FindFirstChildWhichIsA("ProximityPrompt", true)
    local nx_2 = ny:FindFirstChild("Proximity")
    local nz = nx_2 and not nx_2:IsA("BasePart")
    if nz then
        nx_2 = nx_2:FindFirstChildWhichIsA("BasePart")
    end
    if not nx_2 then
        nx_2 = ny:FindFirstChildWhichIsA("BasePart", true)
    end
    return ny, ProximityPrompt, nx_2
end
local function fn134()
    return (kB() + 1) * 20
end
local function fn155()
    local np = (LocalPlayer:GetAttribute("World"))
    local nv = if np then 1 else 0
    local nt = 526 * nv + 2217 * (1 - nv)
    local nu = 1729 * nv + 1306 * (1 - nv)
    if not ((nt * 2821 + nu * 1538 + nt * nu) % 16777213 == 5052502) then
        np = 1
    end
    local nq = np
    local np_1 = LocalPlayer:GetAttribute("Stage") or 1
    return math.min(21, np_1 - (nq - 1) * 20)
end
local function fn159(ak, al)
    if setclipboard then
        setclipboard(ak)
    elseif toclipboard then
        toclipboard(ak)
    end
    Library:Notify(al)
end
local function fn164(ab, ac)
    local l3 = tonumber(ab:match("%d+")) or 0
    local l4 = tonumber(ac:match("%d+")) or 0
    return l3 < l4
end
local function fn183(aJ, aK)
    local ma = Options[aJ]
    local mb = ma and tonumber(ma.Value)
    local ma_1 = mb
    local mf = if ma_1 then 1 else 0
    local md = 2457 * mf + 820 * (1 - mf)
    local me = 2799 * mf + 555 * (1 - mf)
    if not ((md * 262 + me * 1395 + md * me) % 16777213 == 11425482) then
        ma_1 = aK
    end
    return ma_1
end
local function fn209()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local mu = leaderstats and leaderstats:FindFirstChild("Level")
    local mt_1 = mu
    if mu then
        mu = mt_1.Value
    end
    return mu or 0
end
local function fn212()
    local mX = LocalPlayer:GetAttribute("InBattle") or kW("AutoCompleteMinigame")
    if mX then
        return
    end
    local mX_1 = ke()
    if not mX_1 then
        kN()
        return
    end
    local mY = LocalPlayer:GetAttribute("Stage") or 1
    local mY_1 = kg()
    jV(mX_1.CFrame + Vector3.new(0, 3, 0))
    local mX_2 = os.clock() + math.max(kF("WinDelay", 0.5), 0.35)
    while true do
        if os.clock() < mX_2 then
            local m_ = Library.Unloaded or not kW("AutoWin")
            if m_ then
                break
            end
            local m__1 = LocalPlayer:GetAttribute("Stage") or 1
            local m__2 = m__1 ~= mY or kg() > mY_1
            if m__2 then
                kN()
                task.wait(0.15)
                return
            end
            task.wait(0.05)
            continue
        end
        kN()
        task.wait(0.15)
        return
    end
    return
end
local function worker2()
    while not Library.Unloaded do
        if kW("AutoEquipBestPet") then
            pcall(j2)
        end
        task.wait(kF("EquipBestDelay", 5))
    end
end
local function fn247()
    local ni = LocalPlayer:GetAttribute("InBattle") or kW("AutoCompleteMinigame")
    if ni then
        return
    end
    local ni_1 = kb()
    if not ni_1 then
        return
    end
    local nj = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local nj_1 = not nj
    local no = if nj_1 then 1 else 0
    local nm = 158 * no + 3685 * (1 - no)
    local nn = 2477 * no + 1535 * (1 - no)
    if not ((nm * 856 + nn * 2475 + nm * nn) % 16777213 == 6657189) then
        nj_1 = (nj.Position - ni_1.Position).Magnitude > 6
    end
    if nj_1 then
        jV(ni_1.CFrame + Vector3.new(0, 3, 0))
    end
    j5()
end
local function fn255()
    local ol = j9("AuraPack")
    local om = type(ol) == "string" and ol:match("%d+")
    local ol_1 = om or nil
    local om_1 = tonumber(ol_1)
    local ol_2 = om_1 or LocalPlayer:GetAttribute("CurrentPack")
    return ol_2 or 1
end
local function worker8()
    while not Library.Unloaded do
        if kW("AutoBuyAura") then
            pcall(kQ)
        end
        task.wait(kF("AuraDelay", 1))
    end
end
local function fn279()
    local m2 = LocalPlayer:GetAttribute("World") or 1
    local m2_1 = WorldManager:GetWorld(m2)
    if not m2_1 then
        return nil
    end
    local TrainingZones = m2_1:FindFirstChild("TrainingZones")
    if not TrainingZones then
        return nil
    end
    local m2_2 = kB()
    local m4 = -1
    local m5
    for i, child in ipairs(TrainingZones:GetChildren()) do
        if child:IsA("Model") then
            local m3_2 = (tonumber(child:GetAttribute("Rebirth")))
            local nh = if m3_2 then 1 else 0
            local nf = 3333 * nh + 4024 * (1 - nh)
            local ng = 1834 * nh + 394 * (1 - nh)
            if not ((nf * 1507 + ng * 3883 + nf * ng) % 16777213 == 1479762) then
                m3_2 = 0
            end
            local m6 = m3_2
            local m3_3 = tonumber(child:GetAttribute("Multiplier")) or 0
            if m6 <= m2_2 and m6 < 1000000 and m3_3 > m4 then
                local TouchPart = child:FindFirstChild("TouchPart", true)
                local m6_1 = TouchPart and TouchPart:IsA("BasePart")
                if m6_1 then
                    m5 = TouchPart
                    m4 = m3_3
                end
            end
        end
    end
    return m5
end
local function worker3()
    while not Library.Unloaded do
        if kW("AutoClaimDaily") then
            pcall(kZ)
        end
        task.wait(kF("DailyDelay", 5))
    end
end
local function fn292()
    local pv_1
    local pu_1
    if identifyexecutor then
        pv_1, pu_1 = identifyexecutor()
        local pw = pv_1 ~= ""
        local px = type(pv_1) == "string" and pw
        if px then
            local pw_1 = type(pu_1) == "string" and pu_1 ~= "" and pv_1 .. " " .. pu_1
            kG = pw_1 or pv_1
        end
    end
end
local function worker13()
    while not Library.Unloaded do
        if kW("AutoWin") then
            pcall(kY)
        else
            task.wait(0.25)
        end
    end
end
local function fn299(aP)
    local mg = Options[aP]
    return mg and mg.Value or {}
end
local function onInputBegan()
    j6 = tick()
end
local function worker9()
    while not Library.Unloaded do
        if kW("AutoBuyClickUpgrader") then
            pcall(kl)
        end
        task.wait(kF("ClickUpgraderDelay", 1))
    end
end
local function fn322(c1)
    local ProximityPrompt = c1:FindFirstChildWhichIsA("ProximityPrompt", true)
    return ProximityPrompt
end
local function fn335(cC, cD)
    local nE = os.clock()
    local nG = nE + (cD or 10)
    while os.clock() < nG do
        local nE_1 = Library.Unloaded or not kW("AutoCompleteMinigame")
        if nE_1 then
            return false
        end
        if cC() then
            return true
        end
        task.wait(0.05)
    end
    return cC()
end
local function onOnClientEvent(dX)
    if type(dX) == "string" then
        j_ = dX
    end
end
local function worker5()
    while not Library.Unloaded do
        if kW("AutoRebirth") then
            pcall(kR)
        end
        task.wait(kF("RebirthDelay", 1))
    end
end
local function fn441()
    local mL = j9("WinPlate")
    if type(mL) == "string" then
        local mM_1 = tonumber(mL:match("%d+"))
        if mM_1 then
            return math.clamp(mM_1, 1, 21)
        end
        local mL_1 = LocalPlayer:GetAttribute("World") or 1
        local mL_2 = LocalPlayer:GetAttribute("Stage") or 1
        return math.min(21, mL_2 - (mL_1 - 1) * 20)
    end
    local mL_3 = LocalPlayer:GetAttribute("World") or 1
    local mL_4 = LocalPlayer:GetAttribute("Stage") or 1
    return math.min(21, mL_4 - (mL_3 - 1) * 20)
end
local function fn447()
    local nRebirth = LocalPlayer:FindFirstChild("nRebirth")
    return nRebirth and nRebirth.Value or 0
end
local function fn457()
    local oo = j9("StopAura")
    local op = oo == ""
    local oq = type(oo) ~= "string" or op
    if oq or oo == "None" then
        return nil
    end
    return oo
end
local function fn472()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    j3 = tick()
end
local function fn480(ar, as)
    return string.format('<font color="%s">%s</font>', as, ar)
end
local function worker14()
    while not Library.Unloaded do
        task.wait(2)
        if kW("AntiAfk") then
            local pR = tick() - j6
            local pS = tick() - j3
            if pR >= 300 and pS >= 60 then
                pcall(jP)
            else
                if pR < 300 and pS >= 300 then
                    pcall(jP)
                end
            end
        end
    end
end
local function onCopyJoinScript_JobID()
    local fU = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, kh)
    kE(fU, "Copied join script to clipboard")
end
local function fn541()
    if kg() < 10 then
        return
    end
    pcall(function()
        TitleRoll:FireServer("Normal")
    end)
end
local function fn558(au, av, aw)
    return string.format("<b>%s</b> %s %s", au, kj("-", "#5a6070"), kj(av, aw))
end
local function fn606()
    local mD = LocalPlayer:GetAttribute("World") or 1
    local mD_1 = WorldManager:GetWorld(mD)
    local mE_1 = mD_1 and mD_1:FindFirstChild("SpawnLocation")
    if mE_1 then
        return mE_1.CFrame + Vector3.new(0, 8, 0)
    end
    return nil
end
local function worker6()
    while not Library.Unloaded do
        if kW("AutoHatchEggs") then
            pcall(ks)
        end
        task.wait(kF("HatchDelay", 1))
    end
end
local function fn656()
    if kS() < kq() then
        return
    end
    pcall(function()
        RebirthRemote:FireServer()
    end)
end
local function onAuraPack()
    ky()
end
local function fn659()
    local ov = k_()
    local ow = { "None" }
    local ox = ko[ov]
    local oC = if ox then 1 else 0
    local oA = 1549 * oC + 3725 * (1 - oC)
    local oB = 1274 * oC + 3240 * (1 - oC)
    if not ((oA * 930 + oB * 385 + oA * oB) % 16777213 == 3904486) then
        ox = ow
    end
    local ov_1 = ox
    local StopAura = Options.StopAura
    if not StopAura then
        return
    end
    StopAura:SetValues(ov_1)
    local Value = StopAura.Value
    local oy = false
    for i, v in ipairs(ov_1) do
        if v == Value then
            oy = true
            break
        end
    end
    if not oy then
        StopAura:SetValue("None")
    end
end
local function fn661()
    pcall(function()
        ChangePet:InvokeServer(nil, "EquipBest")
    end)
end
local function onRscripts()
    kE(kI, "Copied Rscripts profile to clipboard")
end
local function fn686()
    if LocalPlayer:GetAttribute("InBattle") then
        return
    end
    pcall(function()
        ClickRemote:FireServer()
    end)
end
local function fn687(fD)
    local DiscordGroup = fD:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = kv })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = kv })
end
local function fn714()
    connection:Disconnect()
    connection2:Disconnect()
end
local function worker10()
    while not Library.Unloaded do
        if kW("AutoCompleteMinigame") then
            pcall(j8)
            task.wait(kF("MinigameDelay", 0.5))
        else
            task.wait(0.25)
        end
    end
end
local function worker()
    local pD_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local pC = math.floor(os.clock() - jZ)
        if pC < 60 then
            pD_1 = pC .. "s"
        elseif pC < 3600 then
            pD_1 = string.format("%dm %ds", math.floor((pC) / (60)), pC % 60)
        else
            pD_1 = string.format("%dh %dm", math.floor((pC) / (3600)), math.floor((pC % 3600) / (60)))
        end
        Label:SetText(kc("Session time", pD_1, jS))
    end
end
local function onInputChanged(gu)
    local UserInputType = gu.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        j6 = tick()
    end
end
local function worker4()
    while not Library.Unloaded do
        if kW("AutoRollTitle") then
            pcall(kD)
        end
        task.wait(kF("TitleDelay", 1))
    end
end
local function fn777(aU)
    local mk = Options[aU]
    return mk and mk.Value or nil
end
local function fn778()
    local mP = LocalPlayer:GetAttribute("World") or 1
    local mP_1 = kC()
    local attr = LocalPlayer:GetAttribute("HasX2Win")
    local mS = WorldManager:GetMap(mP)
    if not mS then
        return nil
    end
    local mR_1 = attr and "Win2" or "Win"
    local mQ_2 = mS:FindFirstChild(mR_1)
    if not mQ_2 then
        return nil
    end
    local mR_2 = mQ_2:FindFirstChild("Lane" .. mP_1)
    if not mR_2 then
        return nil
    end
    return mR_2:FindFirstChild("WinPart")
end
local function worker7()
    while not Library.Unloaded do
        if kW("AutoBuyUpgrades") then
            pcall(kK)
        end
        task.wait(kF("UpgradeDelay", 2))
    end
end
local function onUnload()
    Library:Unload()
end
jP = nil
jS = nil
jV = nil
jW = nil
WorldManager = nil
ChangePet = nil
jZ = nil
j_ = nil
j1 = nil
j2 = nil
j3 = nil
j5 = nil
j6 = nil
j8 = nil
j9 = nil
kb = nil
kc = nil
ke = nil
kg = nil
kh = nil
TitleRoll = nil
kj = nil
kl = nil
Label = nil
ko = nil
kq = nil
ks = nil
RebirthRemote = nil
kv = nil
ClickRemote = nil
ky = nil
connection2 = nil
kA = nil
kB = nil
kC = nil
local Upgrades, jR, jT, PhoneConfig, HatchPet, GetPlayerData, BattleTap, RollVisualFinished, kd, Roll, kk, ClaimDailyReward, kp, BuyUpgrade, kw
kD = nil
kE = nil
kF = nil
kG = nil
kI = nil
Options = nil
kK = nil
kL = nil
Toggles = nil
kN = nil
connection = nil
LocalPlayer = nil
kQ = nil
kR = nil
kS = nil
VirtualUser = nil
Library = nil
kW = nil
kY = nil
kZ = nil
k_ = nil
local kH, Chances, li
kH = nil
Chances = nil
local Eggs
VirtualUser, LocalPlayer, kL, kI, ClickRemote, RebirthRemote, BuyUpgrade, ClaimDailyReward, TitleRoll, Roll, RollVisualFinished, BattleTap, GetPlayerData, HatchPet, ChangePet, WorldManager, PhoneConfig, Upgrades, Eggs, Chances = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local p8_3 = game:GetService("Players")
local p8_21 = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
LocalPlayer = p8_3.LocalPlayer
local k8 = "+1 Followers Per Click"
kL = "https://discord.gg/K7Qxnxkk46"
kI = "https://discord.gg/K7Qxnxkk46"
local Remotes = p8_21:WaitForChild("Remotes")
local p8_5_3
local p8_19 = Remotes:WaitForChild("Events")
local p8_11 = Remotes:WaitForChild("Functions")
ClickRemote = p8_19:WaitForChild("ClickRemote")
RebirthRemote = p8_19:WaitForChild("RebirthRemote")
BuyUpgrade = p8_19:WaitForChild("BuyUpgrade")
ClaimDailyReward = p8_19:WaitForChild("ClaimDailyReward")
TitleRoll = p8_19:WaitForChild("TitleRoll")
Roll = p8_19:WaitForChild("Roll")
local p8_15 = p8_19:WaitForChild("RollVisual")
RollVisualFinished = p8_19:WaitForChild("RollVisualFinished")
BattleTap = p8_19:WaitForChild("BattleTap")
GetPlayerData = p8_11:WaitForChild("GetPlayerData")
HatchPet = Remotes:WaitForChild("HatchPet")
ChangePet = Remotes:WaitForChild("ChangePet")
WorldManager = require(p8_21.Modules.WorldManager)
PhoneConfig = require(p8_21.PhoneConfig)
Upgrades = require(p8_21.Configuration.Upgrades)
local p8_7 = require(p8_21.Configuration.Upgrades.ListUpgrade)
if (not ClickRemote or p8_3) and (not HatchPet and p8_3) and (Chances or Eggs or (ClickRemote or HatchPet)) or (not p8_3 and not Eggs or (not HatchPet or Chances)) and (not ClickRemote or ClickRemote or (not Chances or false)) or not ((not ClickRemote or p8_3) and (not HatchPet and p8_3) and (Chances or Eggs or (ClickRemote or HatchPet)) or (not p8_3 and not Eggs or (not HatchPet or Chances)) and (not ClickRemote or ClickRemote or (not Chances or false))) then
    Eggs = require(p8_21.Configuration.Eggs)
else
    p8_21 = require(Eggs.Configuration.Eggs)
end
Chances = require(p8_21.Configuration.AuraMultipliers.Chances)
local k9 = {}
for i, v in ipairs(p8_7) do
    k9[#k9 + 1] = v.Name
end
p8_3 = {}
for k, v in pairs(Eggs) do
    p8_11 = type(v) == "table" and v.Currency == "Wins"
    if p8_11 then
        p8_3[#p8_3 + 1] = k
    end
end
table.sort(p8_3)
p8_19 = { "Current" }
local lI = 1
while lI <= 21 do
    local lJ = lI
    p8_19[#p8_19 + 1] = "Lane" .. lJ
    lI += 1
end
ko = {}
p8_11 = {}
local p8_13 = Chances.Packs or {}
for k, v in pairs(p8_13) do
    local p8_5_2 = tonumber(k)
    if p8_5_2 then
        p8_11[#p8_11 + 1] = "Pack " .. p8_5_2
        local p8_13_1 = { "None" }
        p8_21 = Chances.AuraMultipliers and Chances.AuraMultipliers[p8_5_2]
        p8_7 = p8_21
        if type(p8_7) == "table" then
            p8_21 = {}
            for k in pairs(p8_7) do
                p8_21[#p8_21 + 1] = k
            end
            table.sort(p8_21)
            for i, v in ipairs(p8_21) do
                p8_13_1[#p8_13_1 + 1] = v
            end
        end
        ko[p8_5_2] = p8_13_1
    end
end
Library, Toggles, Options, jS, j_, p8_21, li, kE, kv, kj, kc, kW, kF, kp, j9, jV, kS, kB, kq, kg, j5, jW, kN, kC, ke, kY, kb, kA, j1, jR, kw, j8, kk, kd, kl, k_, kH, ky, jT, kQ, kR, kD, ks, kK, kZ, j2 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
table.sort(p8_11, fn164)
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local lj = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
kE = fn159
kv = fn70
kj = fn480
kc = fn558
local lf = "#7fd47f"
local le = "#6ec1ff"
jS = "#e8a34d"
local lh = "#8b93a3"
local lg = "#ff6b6b"
kW = fn21
kF = fn183
kp = fn299
j9 = fn777
jV = fn52
kS = fn209
kB = fn447
kq = fn134
kg = fn49
j5 = fn686
jW = fn606
kN = fn85
kC = fn441
ke = fn778
kY = fn212
kb = fn279
kA = fn247
j1 = fn155
jR = fn92
kw = fn335
j8 = function()
    local nI
    local nK_1
    local nJ_2
    local nP = if LocalPlayer:GetAttribute("InBattle") then 1 else 0
    if nP == 1 then
        while true do
            local nJ_1 = kW("AutoCompleteMinigame") and not Library.Unloaded and LocalPlayer:GetAttribute("InBattle")
            if nJ_1 then
                pcall(function()
                    BattleTap:FireServer()
                end)
                task.wait(0.05)
                continue
            end
            break
        end
        task.wait(0.35)
        return
    end
    nJ_2, nI, nK_1 = jR()
    if not nK_1 then
        return
    end
    local nJ_3 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not nJ_3 or (nJ_3.Position - nK_1.Position).Magnitude > 8 then
        jV(nK_1.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.15)
    end
    if nI and fireproximityprompt then
        pcall(function()
            fireproximityprompt(nI)
        end)
    end
    if not kw(function()
        return LocalPlayer:GetAttribute("InBattle") == true
    end, 8) then
        return
    end
    while true do
        local nJ_6 = kW("AutoCompleteMinigame") and not Library.Unloaded and LocalPlayer:GetAttribute("InBattle")
        if nJ_6 then
            pcall(function()
                BattleTap:FireServer()
            end)
            task.wait(0.05)
            continue
        end
        break
    end
    task.wait(0.5)
end
kk = fn322
kd = function()
    local nY_1
    local nU = LocalPlayer:GetAttribute("World") or 1
    local nV_2
    local nU_1 = WorldManager:GetWorld(nU)
    if not nU_1 then
        return nil
    end
    local FollowersBoosts = nU_1:FindFirstChild("FollowersBoosts")
    if not FollowersBoosts then
        return nil
    end
    local nU_2 = kg()
    local nW = LocalPlayer:GetAttribute("BaseFollowers") or 1
    local nX
    for i, v in ipairs({ FollowersBoosts:FindFirstChild("FirstFloor"), FollowersBoosts:FindFirstChild("SecondFloor") }) do
        if v then
            for i, child in ipairs(v:GetChildren()) do
                if child:IsA("Model") then
                    local nT = tonumber(child.Name)
                    if nT then
                        nV_2, nY_1 = pcall(function()
                            return PhoneConfig:get("Phone" .. nT)
                        end)
                        if nV_2 and nY_1 and nY_1.winsRequired <= nU_2 and nY_1.followersPerClick > nW then
                            nW = nY_1.followersPerClick
                            nX = child
                        end
                    end
                end
            end
        end
    end
    return nX
end
kl = function()
    local od = kd()
    if not od then
        return
    end
    local BoostPart = od:FindFirstChild("BoostPart")
    local of = BoostPart or od:FindFirstChildWhichIsA("BasePart", true)
    if of then
        jV(of.CFrame + Vector3.new(0, 3, 0))
    end
    task.wait(0.15)
    local oc = kk(od)
    if oc and fireproximityprompt then
        pcall(function()
            fireproximityprompt(oc)
        end)
    end
end
k_ = fn255
kH = fn457
ky = fn659
j_ = nil
p8_15.OnClientEvent:Connect(onOnClientEvent)
jT = fn71
kQ = function()
    local oM
    oM = k_()
    local oN = Chances.Packs and Chances.Packs[oM]
    if not oN then
        return
    end
    local oN_1 = kH()
    local attr = LocalPlayer:GetAttribute("AuraName")
    local oQ = j_ == oN_1
    local oQ_3
    if oN_1 and (attr == oN_1 or oQ) then
        jT("Stopped aura roll on " .. oN_1)
        return
    end
    local oP_2 = kg()
    if oP_2 < (oN.price or math.huge) then
        return
    end
    j_ = nil
    pcall(function()
        Roll:FireServer("Normal", oM)
    end)
    local oO_1 = os.clock() + 3
    while true do
        if os.clock() < oO_1 then
            local oP_3 = Library.Unloaded or not kW("AutoBuyAura")
            if oP_3 then
                break
            elseif j_ then
                pcall(function()
                    RollVisualFinished:FireServer()
                end)
                local oO_2 = j_ or LocalPlayer:GetAttribute("AuraName")
                if oQ_3 then
                    jT("Stopped aura roll on " .. oN_1)
                end
                return
            else
                task.wait(0.05)
                continue
            end
        else
            pcall(function()
                RollVisualFinished:FireServer()
            end)
            local oO_4 = j_ or LocalPlayer:GetAttribute("AuraName")
            oQ_3 = oN_1 and oO_4 == oN_1
            if oQ_3 then
                jT("Stopped aura roll on " .. oN_1)
            end
            return
        end
    end
    return
end
if ((kB or ke) and (not ke or false) and (not ky and not kB or (not kB or not ky)) or (lh and kB or false) and (lh and ky and (false or not ky))) and not ((kB or ke) and (not ke or false) and (not ky and not kB or (not kB or not ky)) or (lh and kB or false) and (lh and ky and (false or not ky))) then
    kZ = fn656
    kK = fn541
    kR = function()
        local oY, oZ
        oY = j9("EggChoice")
        if not oY or oY == "" then
            return
        end
        local o__5 = Eggs[oY]
        if not o__5 or o__5.Currency ~= "Wins" then
            return
        end
        local o0_6 = kg()
        if o0_6 < (o__5.Cost or math.huge) then
            return
        end
        local o__6 = LocalPlayer:GetAttribute("World") or 1
        local o__7 = WorldManager:GetEggFolder(o__6)
        if not o__7 then
            return
        end
        local o0_8 = o__7:FindFirstChild(oY)
        if not o0_8 then
            return
        end
        local o__8 = tonumber(j9("HatchAmount")) or 1
        oZ = o__8
        if oZ ~= 3 then
            oZ = 1
        end
        jV(CFrame.new(o0_8.Position + Vector3.new(0, 3, 0)))
        task.wait(0.1)
        pcall(function()
            HatchPet:FireServer(oY, oZ, {})
        end)
    end
    ks = function()
        local o4_3
        local o5_5
        local o3 = {}
        o4_3, o5_5 = pcall(function()
            return GetPlayerData:InvokeServer()
        end)
        local o6 = o4_3 and type(o5_5) == "table" and type(o5_5.Upgrades) == "table"
        if o6 then
            o3 = o5_5.Upgrades
        end
        local o4_4 = kg()
        for k, v in pairs(kp("UpgradeKinds")) do
            local pb = k
            if v then
                local o5_6 = o3[pb] or 0
                local o5_7 = Upgrades:GetMaxLevel(pb)
                if o5_6 < o5_7 then
                    local o5_8 = Upgrades:GetPrice(pb, o5_6)
                    if o4_4 >= o5_8 then
                        pcall(function()
                            BuyUpgrade:FireServer(pb, "Win")
                        end)
                        task.wait(0.1)
                    end
                end
            end
        end
    end
    kD = function()
        local pi_2
        local ph_4
        local pg = {}
        ph_4, pi_2 = pcall(function()
            return GetPlayerData:InvokeServer()
        end)
        local pj = ph_4 and type(pi_2) == "table" and type(pi_2.DailyClaimableRewards) == "table"
        if pj then
            pg = pi_2.DailyClaimableRewards
        end
        local ph_5 = false
        for k, v in pairs(pg) do
            local pf = tonumber(v)
            if pf then
                pcall(function()
                    ClaimDailyReward:FireServer(pf)
                end)
                ph_5 = true
                task.wait(0.15)
            end
        end
        if not ph_5 then
            local pg_4 = tonumber(LocalPlayer:GetAttribute("DailyRewardDay")) or 1
            local pe = pg_4
            local pg_5 = tonumber(LocalPlayer:GetAttribute("LastDailyRewardClaimTime")) or 0
            local pg_6 = pg_5 == 0 or os.time() - pg_5 >= 86400
            if pg_6 then
                pcall(function()
                    ClaimDailyReward:FireServer(pe)
                end)
            end
        end
    end
else
    kR = fn656
    kD = fn541
    ks = function()
        local oY, oZ
        oY = j9("EggChoice")
        if not oY or oY == "" then
            return
        end
        local o__1 = Eggs[oY]
        if not o__1 or o__1.Currency ~= "Wins" then
            return
        end
        local o0_2 = kg()
        if o0_2 < (o__1.Cost or math.huge) then
            return
        end
        local o__2 = LocalPlayer:GetAttribute("World") or 1
        local o__3 = WorldManager:GetEggFolder(o__2)
        if not o__3 then
            return
        end
        local o0_4 = o__3:FindFirstChild(oY)
        if not o0_4 then
            return
        end
        local o__4 = tonumber(j9("HatchAmount")) or 1
        oZ = o__4
        if oZ ~= 3 then
            oZ = 1
        end
        jV(CFrame.new(o0_4.Position + Vector3.new(0, 3, 0)))
        task.wait(0.1)
        pcall(function()
            HatchPet:FireServer(oY, oZ, {})
        end)
    end
    kK = function()
        local o4_1
        local o5_1
        local o3 = {}
        o4_1, o5_1 = pcall(function()
            return GetPlayerData:InvokeServer()
        end)
        local o6 = o4_1 and type(o5_1) == "table" and type(o5_1.Upgrades) == "table"
        if o6 then
            o3 = o5_1.Upgrades
        end
        local o4_2 = kg()
        for k, v in pairs(kp("UpgradeKinds")) do
            local pb = k
            if v then
                local o5_2 = o3[pb] or 0
                local o5_3 = Upgrades:GetMaxLevel(pb)
                if o5_2 < o5_3 then
                    local o5_4 = Upgrades:GetPrice(pb, o5_2)
                    if o4_2 >= o5_4 then
                        pcall(function()
                            BuyUpgrade:FireServer(pb, "Win")
                        end)
                        task.wait(0.1)
                    end
                end
            end
        end
    end
    kZ = function()
        local pi_1
        local ph_1
        local pg = {}
        ph_1, pi_1 = pcall(function()
            return GetPlayerData:InvokeServer()
        end)
        local pj = ph_1 and type(pi_1) == "table" and type(pi_1.DailyClaimableRewards) == "table"
        if pj then
            pg = pi_1.DailyClaimableRewards
        end
        local ph_2 = false
        for k, v in pairs(pg) do
            local pf = tonumber(v)
            if pf then
                pcall(function()
                    ClaimDailyReward:FireServer(pf)
                end)
                ph_2 = true
                task.wait(0.15)
            end
        end
        if not ph_2 then
            local pg_1 = tonumber(LocalPlayer:GetAttribute("DailyRewardDay")) or 1
            local pe = pg_1
            local pg_2 = tonumber(LocalPlayer:GetAttribute("LastDailyRewardClaimTime")) or 0
            local pg_3 = pg_2 == 0 or os.time() - pg_2 >= 86400
            if pg_3 then
                pcall(function()
                    ClaimDailyReward:FireServer(pe)
                end)
            end
        end
    end
end
j2 = fn661
if (not kH or not kD or not kH and kH) and (not kD or not kD or not kH and kD) and (kD or not kD or (kH or kH) or (kD and not kH or kD and not kD)) and ((kD and not kD or (kD or not kH)) and (kH or kH or kH and not kH) or (kD and not kD or (kD or kH)) and (kH or not kH or (not kD or not kH))) or not ((not kH or not kD or not kH and kH) and (not kD or not kD or not kH and kD) and (kD or not kD or (kH or kH) or (kD and not kH or kD and not kD)) and ((kD and not kD or (kD or not kH)) and (kH or kH or kH and not kH) or (kD and not kD or (kD or kH)) and (kH or not kH or (not kD or not kH)))) then
    p8_21 = Library:CreateWindow({
        Title = "Tempo Hub",
        Footer = { { Text = kL, Copyable = true }, "|", k8 },
        Icon = 12645376577,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 10
    })
else
    k8 = p8_21:CreateWindow({
        Footer = { kL, "|", { Text = Library, Copyable = true } },
        ShowCustomCursor = false,
        Icon = 12645376577,
        Title = "Tempo Hub",
        CornerRadius = 10,
        NotifySide = "Right"
    })
end
if (not kF or false or (kj or false)) and (not kj and kF or not kj and kF) and (not kj and not kj or kF and kj or kj and false and (not kj and kF)) or not ((not kF or false or (kj or false)) and (not kj and kF or not kj and kF) and (not kj and not kj or kF and kj or kj and false and (not kj and kF))) then
    li = {}
else
    lj = {}
end
li.Info = p8_21:AddTab("Info", "info")
local lc = p8_21:AddTab("Main", "gamepad-2")
li.Settings = p8_21:AddTab("Settings", "settings")
lc:SetSubTabAlignment("Center")
li.Farm = lc:AddSubTab("Farm", "sprout")
li.Shop = lc:AddSubTab("Shop", "shopping-cart")
li.Progress = lc:AddSubTab("Progress", "trending-up")
local ld = fn687
for k, v in li do
    ld(v)
end
kG, p8_5_3, p8_7, Label, kh, p8_21 = nil, nil, nil, nil, nil, nil
local p8_13_2 = 0
repeat
    p8_15 = (p8_13_2 * 1 + 1) % 3 + 1
    if p8_15 <= 2 then
        if p8_15 <= 1 then
            if p8_13_2 * 73305693 + 3 + 2 <= p8_13_2 * 73305693 + 3 + 2 + 3 then
                p8_21 = #kh > 18
            else
                kh = #p8_21 > 18
            end
            p8_13_2 = (p8_13_2 + 10) % 12
        else
            p8_15 = {
                "jdwjnpuk",
                "wtp",
                "kbxrhviyaivl",
                "asnexqdxzwf",
                "ctu",
                "dxieoscni",
                "brh",
                "yvjpl",
                "jaxiimv",
                "pil",
                "qdapvfjqlt",
                "orxuselov",
                "mfxbkfy"
            }
            if p8_15[(p8_13_2 * 18 + 21) % 13 + 1] < p8_15[(p8_13_2 * 18 + 21) % 13 + 1] then
                kc = "Unknown"
                pcall(fn292)
                kG = LocalPlayer.Info:AddLeftGroupbox("Account", "circle-user")
                kG:AddLabel(k8("User", Label.Name, kj), true)
                kG:AddLabel(k8("Status", "Keyless", kj), true)
                kG:AddLabel(k8("Executor", kc, kj), true)
                le = LocalPlayer.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                le:AddLabel(lf(p8_5_3 .. " [" .. tostring(game.PlaceId) .. "]", p8_7), true)
                le:AddLabel(k8("Place ID", tostring(game.PlaceId), p8_7), true)
                jS = le:AddLabel(k8("Session time", "0s", li), true)
            else
                kG = "Unknown"
                pcall(fn292)
                p8_5_3 = li.Info:AddLeftGroupbox("Account", "circle-user")
                p8_5_3:AddLabel(kc("User", LocalPlayer.Name, lf), true)
                p8_5_3:AddLabel(kc("Status", "Keyless", lf), true)
                p8_5_3:AddLabel(kc("Executor", kG, lf), true)
                p8_7 = li.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                p8_7:AddLabel(kj(k8 .. " [" .. tostring(game.PlaceId) .. "]", le), true)
                p8_7:AddLabel(kc("Place ID", tostring(game.PlaceId), le), true)
                Label = p8_7:AddLabel(kc("Session time", "0s", jS), true)
            end
            p8_13_2 = (p8_13_2 + 10) % 12
        end
    else
        p8_15 = {
            "crrbdrudb",
            "rcvhlrk",
            "ljmas",
            "dwklxlru",
            "prtgxpdorpf",
            "ashtiulsykof",
            "byknazdo",
            "nsvqrsbwdnn",
            "bbemdudlufum",
            "rfprcllysmp",
            "lugckyycax",
            "jwzjtaimilq",
            "lyukc",
            "xomeiucl",
            "batis"
        }
        if p8_15[(p8_13_2 * 83 + 76) % 15 + 1] <= p8_15[(p8_13_2 * 83 + 76) % 15 + 1] then
            kh = tostring(game.JobId)
        else
            kG = tostring(game.JobId)
        end
        p8_13_2 = (p8_13_2 + 10) % 12
    end
until (p8_13_2 * 5 + 5) % 12 == 11
if p8_21 then
    local p8_5_4 = 0
    repeat
        local p8_13_3 = {
            "ivg",
            "emil",
            "mmfdhlgu",
            "tsryigrcijsi",
            "cdpimttwmjdw",
            "rlxnyoh",
            "gftc",
            "ufbotvyimet",
            "iwfyaavqjz",
            "zlysfkd"
        }
        if p8_13_3[(p8_5_4 * 21 + 82) % 10 + 1] <= p8_13_3[(p8_5_4 * 21 + 82) % 10 + 1] then
            p8_21 = string.sub(kh, 1, 18) .. "..."
        else
            kh = string.sub(p8_21, 1, 18) .. "..."
        end
        p8_5_4 = (p8_5_4 + 6) % 8
    until (p8_5_4 * 7 + 0) % 8 == 2
end
local p8_5_5 = p8_21 or kh
jZ = nil
p8_7:AddLabel(kc("Server", p8_5_5, lh), true)
p8_7:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
jZ = os.clock()
task.spawn(worker)
local ScriptsGroup = li.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(kj("Included in this hub", lh), true)
ScriptsGroup:AddLabel(kj(k8, le), true)
local FeaturesGroup = li.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(kj("Auto Farm", le), true)
FeaturesGroup:AddLabel(kj("Auto Shop", lf), true)
FeaturesGroup:AddLabel(kj("Auto Progress", jS), true)
FeaturesGroup:AddLabel(kj("Misc Utilities", lh), true)
ld = li.Info:AddRightGroupbox("Socials", "link")
ld:AddButton({ Text = "Discord", Func = kv })
ld:AddButton({ Text = "Rscripts", Func = onRscripts })
lc = li.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
lc:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
lc:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
lc:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
lc:AddButton({ Text = "Copy Discord Invite", Func = kv })
local FaqGroup = li.Info:AddRightGroupbox("FAQ", "circle-help")
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
p8_21 = li.Farm:AddLeftGroupbox("Farm", "mouse-pointer-click")
p8_21:AddToggle("AutoWin", { Text = "Auto Win", Default = false })
p8_21:AddLabel(kj("Auto Win is laggy and can drop FPS.", lg), true)
p8_21:AddDropdown("WinPlate", { Text = "Win plate", Values = p8_19, Default = "Current" })
p8_21:AddSlider("WinDelay", { Text = "Win delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 2, Suffix = "s" })
p8_21:AddToggle("AutoClick", { Text = "Auto Click", Default = false })
p8_21:AddSlider("ClickDelay", { Text = "Click delay", Default = 0.05, Min = 0.05, Max = 1, Rounding = 2, Suffix = "s" })
p8_21:AddToggle("AutoFollowers", { Text = "Auto Followers based on Rebirth", Default = false })
p8_21:AddSlider("FollowersDelay", { Text = "Followers delay", Default = 0.05, Min = 0.05, Max = 1, Rounding = 2, Suffix = "s" })
p8_21:AddToggle("AutoCompleteMinigame", { Text = "Auto Complete Follower Minigame", Default = false })
p8_21:AddSlider("MinigameDelay", { Text = "Minigame delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 2, Suffix = "s" })
local ShopGroup = li.Shop:AddLeftGroupbox("Shop", "shopping-bag")
ShopGroup:AddToggle("AutoBuyClickUpgrader", { Text = "Auto Buy Click Upgrader", Default = false })
ShopGroup:AddSlider("ClickUpgraderDelay", { Text = "Click upgrader delay", Default = 1, Min = 0.25, Max = 10, Rounding = 2, Suffix = "s" })
ShopGroup:AddToggle("AutoBuyAura", { Text = "Auto Buy Aura", Default = false })
p8_19 = p8_11[1] or "Pack 1"
local p8_5_6 = 4
repeat
    local qZ = bit32.rrotate(bit32.bxor(bit32.lrotate(p8_5_6, 19), string.byte(tostring(p8_5_6))), 19)
    if bit32.bxor(bit32.lrotate(bit32.bxor(qZ, 3157782175), 30), 4010671015) ~= bit32.lrotate(qZ, 30) then
        ShopGroup:AddDropdown("AuraPack", { Text = "Aura pack", Values = p8_11, Default = p8_19, Callback = onAuraPack })
    else
        ShopGroup:AddDropdown("AuraPack", { Text = "Aura pack", Values = p8_11, Default = p8_19, Callback = onAuraPack })
    end
    p8_5_6 = (p8_5_6 + 2) % 8
until (p8_5_6 * 5 + 1) % 8 == 7
p8_11 = { "None" }
p8_19 = ko[1] or p8_11
ShopGroup:AddDropdown("StopAura", { Text = "Stop on aura", Values = p8_19, Default = "None" })
ShopGroup:AddSlider("AuraDelay", { Text = "Aura delay", Default = 1, Min = 0.25, Max = 10, Rounding = 2, Suffix = "s" })
ky()
ShopGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
ShopGroup:AddDropdown("UpgradeKinds", { Text = "Upgrades", Values = k9, Multi = true, AllowNull = true, Default = k9 })
ShopGroup:AddSlider("UpgradeDelay", { Text = "Upgrade delay", Default = 2, Min = 0.5, Max = 30, Rounding = 1, Suffix = "s" })
local p8_13_5 = li.Shop:AddRightGroupbox("Eggs", "egg")
p8_13_5:AddToggle("AutoHatchEggs", { Text = "Auto Hatch Eggs", Default = false })
p8_11 = p8_3[1] or "Basic"
j6, j3, connection, connection2, jP = nil, nil, nil, nil, nil
p8_13_5:AddDropdown("EggChoice", { Text = "Egg", Values = p8_3, Default = p8_11 })
p8_13_5:AddDropdown("HatchAmount", { Text = "Hatch amount", Values = { "1", "3" }, Default = "1" })
p8_13_5:AddSlider("HatchDelay", { Text = "Hatch delay", Default = 1, Min = 0.5, Max = 10, Rounding = 1, Suffix = "s" })
p8_7 = li.Progress:AddLeftGroupbox("Progress", "rotate-ccw")
p8_7:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
p8_7:AddSlider("RebirthDelay", { Text = "Rebirth delay", Default = 1, Min = 0.5, Max = 30, Rounding = 1, Suffix = "s" })
p8_7:AddToggle("AutoRollTitle", { Text = "Auto Roll Title", Default = false })
p8_7:AddSlider("TitleDelay", { Text = "Title delay", Default = 1, Min = 0.5, Max = 10, Rounding = 1, Suffix = "s" })
p8_21 = li.Progress:AddRightGroupbox("Rewards", "gift")
p8_21:AddToggle("AutoClaimDaily", { Text = "Auto Claim Daily Rewards", Default = false })
p8_21:AddSlider("DailyDelay", { Text = "Daily delay", Default = 5, Min = 1, Max = 60, Rounding = 1, Suffix = "s" })
p8_21:AddToggle("AutoEquipBestPet", { Text = "Auto Equip Best Pet", Default = false })
p8_21:AddSlider("EquipBestDelay", { Text = "Equip best delay", Default = 5, Min = 1, Max = 60, Rounding = 1, Suffix = "s" })
local p8_5_7 = li.Settings:AddLeftGroupbox("Menu", "menu")
Library.ToggleKeybind = Options.MenuKeybind
p8_5_7:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
p8_5_7:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
p8_5_7:AddButton({ Text = "Unload", Func = onUnload })
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(li.Settings)
ThemeManager:LoadDefault()
lj:SetLibrary(Library)
lj:IgnoreThemeSettings()
lj:SetIgnoreIndexes({ "MenuKeybind" })
lj:SetFolder("TempoHub/plus1-followers-per-click")
lj:BuildConfigSection(li.Settings)
lj:LoadAutoloadConfig()
j6 = tick()
j3 = tick()
if (not connection and not p8_21 or (p8_21 or p8_5_7)) and (not connection or not p8_21 or jP and not p8_5_7) and not ((not connection and not p8_21 or (p8_21 or p8_5_7)) and (not connection or not p8_21 or jP and not p8_5_7)) then
    pcall(function()
        for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
            local pL = v
            pcall(function()
                pL:Disable()
            end)
        end
    end)
else
    pcall(function()
        for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
            local pL = v
            pcall(function()
                pL:Disable()
            end)
        end
    end)
    jP = fn472
end
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
do
    Library:OnUnload(fn714)
    task.spawn(worker14)
    task.spawn(worker13)
    task.spawn(worker12)
    task.spawn(worker11)
    task.spawn(worker10)
    task.spawn(worker9)
    task.spawn(worker8)
    task.spawn(worker7)
    task.spawn(worker6)
    task.spawn(worker5)
    task.spawn(worker4)
    task.spawn(worker3)
    task.spawn(worker2)
    Library:Notify("+1 Followers Per Click loaded")
end
end)(...)

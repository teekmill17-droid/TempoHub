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
getgenv().TempoHoodSubtitle = "+1 TALL TO ESCAPE"
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
local tW
local uD
local tD
local uk
local t1
local uJ
local tJ
local uq
local uP
local tP
local tw
local ud
local tV
local tC
local uj
local uI
local tI
local t6
local uO
local uv
local LocalPlayer
local uc
local uB
local tB
local ui
local t_
local uH
local tH
local uo
local t5
local uN
local tN
local uu
local tu
local ub
local uA
local tA
local uh
local tZ
local uG
local tG
local un
local uM
local tM
local ut
local tt
local ua
local tS
local uz
local tz
local ug
local CoreGui
local uF
local um
local t3
local uL
local tL
local us
local tR
local uy
local ty
local uf
local tX
local uE
local ul
local t2
local uK
local tK
local t8
local tQ
local ux
local tx
local function fn10()
    local An = tu()
    if not An then
        if ty.eating then
            uk(false)
            ty.eating = false
        end
        tX("No unlocked train zone")
        return
    end
    local Ao = uy(An)
    if not Ao then
        return
    end
    tz(Ao.Position + Vector3.new(0, 3, 0))
    if not ty.eating then
        local As = if uk(true) then 1 else 0
        if As == 1 then
            ty.eating = true
        end
    end
    tX("Training zone " .. tostring(An))
end
local function fn13(hA)
    local Ce = hA and true or false
    tR.enabled = Ce
    if tR.enabled then
        tt(tR, tL)
    else
        uE(tR)
    end
end
local function fn33(fk)
    local z0 = fk and true or false
    us.enabled = z0
    if us.enabled then
        tt(us, t_)
    else
        uE(us)
    end
end
local function fn45()
    local wz = tonumber(uf("wins")) or 0
    return wz
end
local function fn55()
    local wB = tonumber(uf("rebirths")) or 0
    return wB
end
local function fn71()
    return pcall(function()
        t8.spinWheelRequest.fire()
    end)
end
local function fn73()
    local zv = {}
    local zw = t6()
    local selected = us.selected
    local zy = false
    local zz = false
    for k in pairs(selected) do
        zz = true
        if k == ux or us.lookup[k] == 0 then
            zy = true
        end
    end
    if not zz or zy then
        local zy_1 = ul()
        if zy_1 then
            table.insert(zv, zy_1)
        end
        return zv
    end
    for k in pairs(selected) do
        local zx_1 = us.lookup[k]
        local zy_2 = um()[zx_1]
        local zz_1 = zx_1 and zx_1 > 0 and zy_2
        if zz_1 then
            local zA_3 = tonumber(zy_2.requiredLevel) or math.huge
            zz_1 = zw >= zA_3
        end
        if zz_1 then
            table.insert(zv, zx_1)
        end
    end
    table.sort(zv)
    return zv
end
local function fn115(fV)
    local AA = tonumber(fV) or 0.25
    ty.delay = math.max(0.05, AA)
end
local function fn121(gd)
    local AM = gd and true or false
    tQ.enabled = AM
    if tQ.enabled then
        tt(tQ, tJ)
    else
        uE(tQ)
    end
end
local function fn129(as, at)
    local Notifications = uv.Notifications
    local vC = tostring(as)
    local vD = at or 4
    table.insert(Notifications, { text = vC, time = vD })
end
local function fn145(g6)
    local BC = g6 and true or false
    uD.equipBest = BC
end
local function fn155(c9)
    if type(c9) ~= "table" then
        return false
    elseif c9.gamePassId then
        return tG(c9.gamePassId)
    else
        local xA = tonumber(c9.rebirthsRequired) or 0
        return uA() >= xA
    end
end
local function fn159()
    local yH = {}
    local yI = {}
    for k, v in pairs(uN()) do
        local yK = type(v) == "table" and v.order
        local yL = tonumber(yK) or 999
        local yK_1 = type(v) == "table" and v.cost
        local yM = tonumber(yK_1) or 0
        table.insert(yH, { Name = k, Order = yL, Cost = yM })
    end
    table.sort(yH, function(em, en)
        if em.Order == en.Order then
            return em.Cost < en.Cost
        end
        return em.Order < en.Order
    end)
    for i, v in ipairs(yH) do
        table.insert(yI, v.Name)
    end
    return yI, yH
end
local function fn186(g1)
    local Bw = g1 and true or false
    uD.enabled = Bw
    if uD.enabled then
        tt(uD, uu)
    else
        uE(uD)
    end
end
local function fn190()
    return not ud.Unloaded
end
local function fn213(bm)
    local wl = uf("ownedZonePasses")
    if type(wl) ~= "table" then
        return false
    end
    local wm = tostring(bm)
    if wl[wm] == true or wl[bm] == true then
        return true
    end
    for k, v in pairs(wl) do
        if tostring(v) == wm then
            return true
        end
    end
    return false
end
local function fn214()
    local AJ_1
    local AI_1
    local AH = uA()
    AI_1, AJ_1 = pcall(tP.requiredLevel, AH)
    local AH_1 = not AI_1 or type(AJ_1) ~= "number"
    if AH_1 then
        tX("Rebirth requirement unavailable")
        return
    end
    local AH_2 = t6()
    if AH_2 < AJ_1 then
        tX(string.format("Rebirth at level %d (now %d)", AJ_1, AH_2))
        return
    end
    if uK() then
        uo("Rebirth requested")
        tX("Rebirthed")
    end
end
local function fn271()
    local zl = t6()
    local zm
    for i, v in ipairs(um()) do
        local zn = tonumber(v.requiredLevel) or math.huge
        if zl >= zn then
            zm = i
        end
    end
    return zm
end
local function fn301()
    local xG = { ["Best Unlocked"] = 0 }
    local xH = { "Best Unlocked" }
    for i, v in ipairs(uj()) do
        local xI = v.power or "?"
        local xJ = tostring(xI)
        local xI_1 = ""
        if v.gamePassId then
            local xK_1 = tG(v.gamePassId) and ""
            xI_1 = xK_1 or " [Pass]"
        else
            local xK_2 = tonumber(v.rebirthsRequired) or 0
            if uA() < xK_2 then
                xI_1 = string.format(" [R%d]", xK_2)
            end
        end
        local xK_3 = string.format("Zone %d (x%s)%s", i, xJ, xI_1)
        table.insert(xH, xK_3)
        xG[xK_3] = i
    end
    return xH, xG
end
local function fn318(fX, fY)
    if type(fY) == "table" then
        ty.lookup = fY
    end
    local AC = type(fX) == "string" and ty.lookup[fX] ~= nil
    if AC then
        ty.zone = ty.lookup[fX]
    elseif type(fX) == "number" then
        ty.zone = fX
    else
        ty.zone = 0
    end
end
local function fn333(Y)
    return type(Y) == "function"
end
local function fn338(eB)
    local zf = tC()
    local zg = not zf
    local zk = if zg then 1 else 0
    local zi = 480 * zk + 2059 * (1 - zk)
    local zj = 3057 * zk + 3734 * (1 - zk)
    if not ((zi * 2188 + zj * 276 + zi * zj) % 16777213 == 3361332) then
        zg = typeof(eB) ~= "Vector3"
    end
    if zg then
        return false
    end
    zf.CFrame = CFrame.new(eB)
    zf.AssemblyLinearVelocity = Vector3.zero
    return true
end
local function fn339(cy)
    local w0 = tW()
    local w1 = w0 and w0:FindFirstChild("stages")
    if not w1 then
        return nil
    end
    for i, child in ipairs(w1:GetChildren()) do
        local w0_2 = tonumber(string.match(child.Name, "^Stage%s+(%d+)"))
        if w0_2 == cy then
            return child
        end
    end
    return nil
end
local function fn361(hB)
    local Ck = tonumber(hB) or 5
    tR.delay = math.max(1, Ck)
end
local function fn362()
    return pcall(function()
        t8.petBulkRequest.fire(1)
    end)
end
local function fn364(ht)
    local BT = type(ht) == "string" and ht
    local BU = BT or nil
    uB.egg = BU
end
local function fn375()
    local xT = {}
    if type(uL.data) ~= "table" then
        return xT
    end
    for k, v in pairs(uL.data) do
        local xV = v.displayName or k
        local xW = tostring(xV)
        local xX = tonumber(v.winPrice) or math.huge
        local xY = tonumber(v.heightMultiplier) or 1
        table.insert(xT, { Name = k, Display = xW, Price = xX, Height = xY })
    end
    table.sort(xT, function(dF, dG)
        return dF.Price < dG.Price
    end)
    return xT
end
local function fn398()
    uE(us)
    uE(ty)
    uE(tQ)
    uE(un)
    uE(uD)
    uE(uB)
    uE(tR)
    if ty.eating then
        uk(false)
        ty.eating = false
    end
end
local function fn399(hq)
    local BO = hq and true or false
    uB.enabled = BO
    if uB.enabled then
        tt(uB, ut)
    else
        uE(uB)
    end
end
local function fn410()
    gethui = uH
end
local function fn418(gF)
    local A8 = tonumber(gF) or 1
    un.delay = math.max(0.2, A8)
end
local function fn435(cq)
    cq.enabled = false
    local wV = cq.generation or 0
    cq.generation = wV + 1
    if cq.task then
        pcall(task.cancel, cq.task)
        cq.task = nil
    end
end
local function fn446(V)
    local vy = typeof(cloneref) == "function" and typeof(V) == "Instance"
    if vy then
        return cloneref(V)
    end
    return V
end
local function fn493()
    return uz:FindFirstChild("world " .. tostring(uc()))
end
local function fn496()
    local vM_1
    local vL_1
    if not tB() then
        return nil
    end
    vL_1, vM_1 = pcall(function()
        return t1:query(tZ.player)
    end)
    if not vL_1 or not vM_1 then
        return nil
    end
    for k, v in vM_1:iter() do
        local vL_2 = v == LocalPlayer
        local vM_2 = typeof(v) == "Instance" and vL_2
        if vM_2 then
            return k
        end
        if v == LocalPlayer.Name then
            return k
        end
    end
    return nil
end
local function fn499(aw)
    uv.Status = tostring(aw)
end
local function fn544()
    return pcall(function()
        t8.rebirthRequest.fire()
    end)
end
local function fn598()
    local yd = {}
    local ye = tW()
    local yf = ye and ye:FindFirstChild("upgrades")
    if yf then
        for i, child in ipairs(yf:GetChildren()) do
            local ye_2 = uP[child.Name]
            if type(ye_2) == "table" then
                local insert = table.insert
                local Name = child.Name
                local yh = tonumber(ye_2.cost) or 0
                local yi = tonumber(ye_2.power) or 0
                insert(yd, { Name = Name, Cost = yh, Power = yi })
            end
        end
    end
    if #yd == 0 then
        for k, v in pairs(uP) do
            local ye_3 = type(v) == "table" and v.cost ~= nil
            if ye_3 then
                local insert = table.insert
                local yf_2 = (tonumber(v.cost))
                local yy = if yf_2 then 1 else 0
                local yw = 2358 * yy + 976 * (1 - yy)
                local yx = 1356 * yy + 1942 * (1 - yy)
                if not ((yw * 3562 + yx * 600 + yw * yx) % 16777213 == 12410244) then
                    yf_2 = 0
                end
                local yg_2 = tonumber(v.power) or 0
                insert(yd, { Name = k, Cost = yf_2, Power = yg_2 })
            end
        end
    end
    table.sort(yd, function(dZ, d_)
        return dZ.Cost < d_.Cost
    end)
    return yd
end
local function fn614(hw)
    local B5 = hw and true or false
    uB.equipBest = B5
end
local function fn618(gi)
    local AS = tonumber(gi) or 2
    tQ.delay = math.max(0.5, AS)
end
local function fn641(g3)
    uD.selected = ub(g3)
end
local function fn722()
    local Character = LocalPlayer.Character
    local vJ = Character and Character:FindFirstChildOfClass("Humanoid")
    return vJ
end
local function fn728(g2)
    local Bz = tonumber(g2) or 1
    uD.delay = math.max(0.2, Bz)
end
local function fn743(fl)
    local z6 = tonumber(fl) or 1.6
    us.delay = math.max(0.2, z6)
end
local function fn759(ev)
    local y5 = {}
    if type(ev) == "table" then
        for k, v in pairs(ev) do
            local y6_1 = v == true and type(k) == "string"
            if y6_1 then
                y5[k] = true
            elseif type(v) == "string" then
                y5[v] = true
            end
        end
    else
        local y6_2 = ev ~= ""
        local y7 = type(ev) == "string" and y6_2
        if y7 then
            y5[ev] = true
        end
    end
    return y5
end
local function fn762(bg)
    local wd = uf("ownedTrails")
    if type(wd) ~= "table" then
        return false
    elseif wd[bg] == true then
        return true
    else
        for k, v in pairs(wd) do
            if v == bg then
                return true
            end
        end
        return false
    end
end
local function fn777(hs)
    local BR = tonumber(hs) or 1.2
    uB.delay = math.max(0.3, BR)
end
local function fn821()
    local v2 = tonumber(uf("currentWorldId")) or 1
    local v3 = v2
    if v3 < 1 then
        v3 = 1
    end
    return v3
end
local function fn832()
    if ui() <= 0 then
        tX("No spins left")
        return
    end
    if tD() then
        uo("Spin requested")
        tX("Spinning")
        local B7 = (tonumber(uF.spinDuration))
        local Cc = if B7 then 1 else 0
        local Ca = 2637 * Cc + 140 * (1 - Cc)
        local Cb = 2045 * Cc + 4092 * (1 - Cc)
        if not ((Ca * 2434 + Cb * 94 + Ca * Cb) % 16777213 == 12003353) then
            B7 = 4.5
        end
        local B8 = B7
        task.wait(B8 + 0.3)
    end
end
local function fn833(gA)
    local A5 = gA and true or false
    un.enabled = A5
    if un.enabled then
        tt(un, ua)
    else
        uE(un)
    end
end
local function fn852(hu)
    local BZ = tonumber(hu) or 1
    local B__1 = BZ == 3 and 3 or 1
    uB.amount = B__1
end
local function fn857(er)
    local y_ = uN()[er]
    if type(y_) == "table" then
        local y0 = (tonumber(y_.cost))
        local y4 = if y0 then 1 else 0
        local y2 = 3371 * y4 + 3529 * (1 - y4)
        local y3 = 719 * y4 + 3584 * (1 - y4)
        if not ((y2 * 3696 + y3 * 345 + y2 * y3) % 16777213 == 15131020) then
            y0 = 0
        end
        return y0
    end
    return 0
end
local function fn870()
    return CoreGui
end
local function fn872()
    local Ba = uM()
    local selected = uD.selected
    local Bc = false
    for k in pairs(selected) do
        Bc = true
        break
    end
    local Bd
    for i, v in ipairs(tM()) do
        local Be = (not Bc or selected[v.Display] or selected[v.Name]) and not ug(v.Name) and v.Price <= Ba
        if Be then
            if not Bd or v.Price > Bd.Price then
                Bd = v
            end
        end
    end
    if Bd then
        if tx(Bd.Name) then
            uo("Bought " .. Bd.Display)
            tX("Bought " .. Bd.Display)
        end
        return
    end
    if uD.equipBest then
        local Ba_1 = nil
        for i, v in ipairs(tM()) do
            if ug(v.Name) then
                Ba_1 = v
            end
        end
        local Bb_1 = uf("equippedTrail") or ""
        local Bc_1 = tostring(Bb_1)
        if Ba_1 and Ba_1.Name ~= Bc_1 then
            tx(Ba_1.Name)
            tX("Equipped " .. Ba_1.Display)
            return
        end
    end
    tX("No affordable auras")
end
local function fn881()
    local BE = uB.egg
    local BF = BE == ""
    local BG = type(BE) ~= "string"
    local BM = if BG then 1 else 0
    local BK = 882 * BM + 965 * (1 - BM)
    local BL = 2995 * BM + 3631 * (1 - BM)
    if not ((BK * 3632 + BL * 1648 + BK * BL) % 16777213 == 10780774) then
        BG = BF
    end
    if BG then
        local BF_1 = uG()
        BE = BF_1[1]
        uB.egg = BE
    end
    local BF_2 = BE == ""
    local BG_1 = type(BE) ~= "string" or BF_2
    if BG_1 then
        tX("No eggs available")
        return
    end
    local max = math.max
    local floor = math.floor
    local BH = tonumber(uB.amount) or 1
    local BI = max(1, floor(BH))
    if BI ~= 1 and BI ~= 3 then
        BI = 1
    end
    local BF_5 = BI == 3 and uf("tripleHatchOwned") ~= true
    if BF_5 then
        BI = 1
    end
    local BF_6 = uI(BE) * BI
    local BG_4 = uM()
    if BG_4 < BF_6 then
        tX(string.format("%s needs %s wins", BE, tostring(BF_6)))
        return
    end
    if uq(BE, BI) then
        tX(string.format("Hatching %dx %s", BI, BE))
        if uB.equipBest then
            task.wait(0.4)
            local BE_1 = tB() and uB.enabled
            if BE_1 then
                tS()
            end
        end
    end
end
local function fn930()
    local Character = LocalPlayer.Character
    local vG = Character and Character:FindFirstChild("HumanoidRootPart")
    return vG
end
local function fn948()
    local wD = tonumber(uf("spins")) or 0
    return wD
end
local function fn958()
    local zM = uO()
    if #zM == 0 then
        tX("No claimable stages for your level")
        return
    end
    local zN = tonumber(tH.claimCooldown) or 1.5
    for i, v in ipairs(zM) do
        local zM_1 = not tB()
        local zZ = if zM_1 then 1 else 0
        local zX = 3000 * zZ + 2216 * (1 - zZ)
        local zY = 2107 * zZ + 1113 * (1 - zZ)
        if not ((zX * 1663 + zY * 2629 + zX * zY) % 16777213 == 72090) then
            zM_1 = not us.enabled
        end
        if zM_1 then
            return
        end
        local zM_2 = t3(v)
        if zM_2 then
            local zN_1 = zM_2.Position + Vector3.new(0, 3, 0)
            local zM_3 = os.clock() + math.max(zN, us.delay)
            while true do
                local zP = tB() and us.enabled and os.clock() < zM_3
                if zP then
                    tz(zN_1)
                    task.wait(0.05)
                    continue
                end
                break
            end
            tX("Claiming stage " .. tostring(v))
        end
        local zM_4 = not tB() or not us.enabled
        if zM_4 then
            return
        end
        task.wait(0.05)
    end
end
local function fn960()
    local AU = uM()
    local AV
    for i, v in ipairs(tI()) do
        local AW = not tA(v.Name) and v.Cost <= AU
        if AW then
            if not AV or v.Cost > AV.Cost or v.Cost == AV.Cost and v.Power > AV.Power then
                AV = v
            end
        end
    end
    if not AV then
        tX("No affordable food upgrades")
        return
    end
    if t2(AV.Name) then
        uo("Bought " .. AV.Name)
        tX("Bought " .. AV.Name)
    end
end
local function fn977()
    local xx_1
    local xw_1
    xw_1, xx_1 = pcall(tw.forWorld, uc())
    local xy = xw_1 and type(xx_1) == "table"
    if xy then
        return xx_1
    end
    return {}
end
local function fn981()
    local wx_1
    local wv = tonumber(uf("steps")) or 0
    local wv_1
    wv_1, wx_1 = pcall(tV.levelFromSteps, wv)
    local ww_1 = wv_1 and type(wx_1) == "number"
    if ww_1 then
        return wx_1
    end
    return 0
end
local function fn1020()
    local xj = { [ux] = 0 }
    local xk = { ux }
    for i, v in ipairs(um()) do
        local xl = tN(i)
        local xm = xl and string.match(xl.Name, "^Stage%s+%d+%s*%((.+)%)")
        local xl_1 = xm or tostring(i)
        local format = string.format
        local xn = v.requiredLevel or "?"
        local xo = format("%d - %s (Lv %s)", i, xl_1, tostring(xn))
        table.insert(xk, xo)
        xj[xo] = i
    end
    return xk, xj
end
local function fn1066()
    local yB_1, yB_2, yB_3
    local worldEggs = uh:FindFirstChild("worldEggs")
    local yz_6
    local yA = worldEggs and worldEggs:FindFirstChild("world" .. tostring(uc()))
    local yA_1, yA_2, yA_3
    if yA then
        yA_1, yB_1 = pcall(require, t5(yA))
        local yz_2 = yA_1 and type(yB_1) == "table"
        if yz_2 then
            return yB_1
        end
        local eggs = uh:FindFirstChild("eggs")
        if eggs then
            yA_2, yB_2 = pcall(require, t5(eggs))
            if yz_6 then
                return yB_2
            end
            return {}
        end
        return {}
    end
    local eggs = uh:FindFirstChild("eggs")
    if eggs then
        yA_3, yB_3 = pcall(require, t5(eggs))
        yz_6 = yA_3 and type(yB_3) == "table"
        if yz_6 then
            return yB_3
        end
        return {}
    end
    return {}
end
local function fn1072()
    local x5 = {}
    for i, v in ipairs(tM()) do
        table.insert(x5, v.Display)
    end
    return x5
end
local function fn1086()
    local zone = ty.zone
    local Aa = uj()
    if zone and zone > 0 then
        local Ab_1 = Aa[zone]
        local Ac = Ab_1 and tK(Ab_1) and uy(zone)
        if Ac then
            return zone
        end
        return nil
    end
    local z9_1 = nil
    for i, v in ipairs(Aa) do
        local Aa_1 = tK(v) and uy(i)
        if Aa_1 then
            z9_1 = i
        end
    end
    return z9_1
end
local function fn1102()
    local wY_1
    local wX_1
    wX_1, wY_1 = pcall(tH.forWorld, uc())
    local wZ = wX_1 and type(wY_1) == "table"
    if wZ then
        return wY_1
    end
    return {}
end
local function fn1105(fP)
    local Au = fP and true
    local Ay = if Au then 1 else 0
    local Aw = 2646 * Ay + 2199 * (1 - Ay)
    local Ax = 2221 * Ay + 435 * (1 - Ay)
    if not ((Aw * 807 + Ax * 2556 + Aw * Ax) % 16777213 == 13688964) then
        Au = false
    end
    ty.enabled = Au
    if ty.enabled then
        tt(ty, uJ)
    else
        uE(ty)
        if ty.eating then
            uk(false)
            ty.eating = false
        end
    end
end
local function fn1111(de)
    local xD = tW()
    local xE = xD and xD:FindFirstChild("zones")
    if not xE then
        return nil
    end
    local xE_1 = xE:FindFirstChild(tostring(de))
    local xD_2 = xE_1 and xE_1:IsA("BasePart")
    if xD_2 then
        return xE_1
    end
    return nil
end
local function fn1125(ba)
    local v5 = uf("foods")
    if type(v5) ~= "table" then
        return false
    end
    for k, v in pairs(v5) do
        if v == ba then
            return true
        end
    end
    return false
end
local function fn1128(cH)
    local w9 = tN(cH)
    if not w9 then
        return nil
    end
    local Normal_Win = w9:FindFirstChild("Normal Win")
    local xb = Normal_Win and Normal_Win:FindFirstChild("Win", true)
    local xa_1 = xb
    if xb then
        xb = xa_1:IsA("BasePart")
    end
    if xb then
        return xa_1
    end
    local Win = w9:FindFirstChild("Win", true)
    local w9_1 = Win and Win:IsA("BasePart")
    if w9_1 then
        return Win
    end
    return nil
end
local function fn1132(fm, fo)
    us.selected = ub(fm)
    if type(fo) == "table" then
        us.lookup = fo
    end
end
tt = nil
tu = nil
LocalPlayer = nil
tw = nil
tx = nil
ty = nil
tz = nil
tA = nil
tB = nil
tC = nil
tD = nil
tG = nil
tH = nil
tI = nil
tJ = nil
tK = nil
tL = nil
tM = nil
tN = nil
tP = nil
tQ = nil
tR = nil
tS = nil
tV = nil
tW = nil
tX = nil
CoreGui = nil
tZ = nil
t_ = nil
t1 = nil
t2 = nil
t3 = nil
t5 = nil
t6 = nil
t8 = nil
ua = nil
ub = nil
uc = nil
ud = nil
local Players, tE, tF, Lighting, tT, TeleportService, GuiService, t4, HttpService, t9, VirtualUser
uf = nil
ug = nil
uh = nil
ui = nil
uj = nil
uk = nil
ul = nil
um = nil
un = nil
uo = nil
uq = nil
us = nil
ut = nil
uu = nil
uv = nil
ux = nil
uy = nil
uz = nil
uA = nil
uB = nil
uD = nil
uE = nil
uF = nil
uG = nil
uH = nil
uI = nil
uJ = nil
uK = nil
uL = nil
uM = nil
uN = nil
uO = nil
uP = nil
local UserInputService, ur, RunService, uC
local uX_1
if not game:IsLoaded() then
    game.Loaded:Wait()
end
Players, RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, TeleportService, Lighting, LocalPlayer, uH = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
TeleportService = game:GetService("TeleportService")
Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local uU = "TempoTallEscape"
uH = fn870
if getgenv then
    getgenv().gethui = uH
end
ud, uz, uX_1, uh, t8, t1, tZ, tV, tP, tH, tw, uP, uL, uF, uv, ux, us, ty, tQ, un, uD, uB, tR, tE, t5, tT, tB, uo, tX, tC, uC, t4, uf, uc, tW, tA, ug, tG, t6, uM, uA, ui, t2, tx, uq, tD, uK, uk, tS, tt, uE, um, tN, t3, ur, uj, tK, uy, tF, tM, t9, tI, uN, uG, uI, ub, tz, ul, uO, t_, tu, uJ, tJ, ua, uu, ut, tL = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pcall(fn410)
local function uW(u)
    local vn
    local vo
    local vm
    vm = nil
    vn = nil
    vo = nil
    local vp = u ~= ""
    local vq = type(u) == "string" and vp
    assert(vq, "Atypical is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    vn = getgenv()
    assert(type(vn) == "table", "getgenv did not return a table")
    local vp_1 = vn[u]
    if vp_1 ~= nil then
        local vq_1 = type(vp_1) == "table" and type(vp_1.Unload) == "function"
        assert(vq_1, "Namespace is occupied")
        vp_1.Unload()
        assert(vn[u] == nil, "Previous instance did not release its namespace")
    end
    vo = {}
    vm = { State = {}, Unloaded = false }
    vm.Track = function(A)
        assert(type(A) == "function", "Cleanup must be callable")
        if vm.Unloaded then
            A()
        else
            table.insert(vo, A)
        end
        return A
    end
    vm.Unload = function()
        local vc_1
        local vb_1
        if vm.Unloaded then
            return
        end
        vm.Unloaded = true
        local u9 = {}
        local vj = #vo
        local vi = -1
        while false and vj <= 1 or true and vj >= 1 do
            local vk = vj
            local va_1 = table.remove(vo, vk)
            vb_1, vc_1 = pcall(va_1)
            if not vb_1 then
                table.insert(u9, tostring(vc_1))
            end
            vj += vi
        end
        table.clear(vm.State)
        if #u9 > 0 then
            error("Cleanup incomplete: " .. table.concat(u9, "; "), 0)
        end
        if vn[u] == vm then
            vn[u] = nil
        end
    end
    vn[u] = vm
    return vm
end
tE = function(N, O)
    local vw = type(N) == "table" and type(N.Track) == "function"
    assert(vw, "FeatureAPI required")
    local vw_1 = type(O) == "table" and type(O.OnUnload) == "function"
    assert(vw_1, "UI library required")
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
if (not uI and not tZ and (not tZ or not uI) and (not tZ and uI and (uI and uI)) and ((tZ or tZ) and (not uI or tZ) or (not uI or not uI) and (not tZ and tZ)) or ((not uI or tZ) and (tZ or uI) and (uI and tZ or (tZ or not uI)) or (uI and not tZ and (not uI and tZ) or (not uI or tZ) and (tZ or not uI)))) and not (not uI and not tZ and (not tZ or not uI) and (not tZ and uI and (uI and uI)) and ((tZ or tZ) and (not uI or tZ) or (not uI or not uI) and (not tZ and tZ)) or ((not uI or tZ) and (tZ or uI) and (uI and tZ or (tZ or not uI)) or (uI and not tZ and (not uI and tZ) or (not uI or tZ) and (tZ or not uI)))) then
    ud(uW)
else
    ud = uW(uU)
end
t5 = fn446
tT = fn333
tB = fn190
local uZ = t5(ReplicatedStorage)
local uY = t5(ReplicatedFirst)
uz = t5(Workspace)
if (not t8 and uA and (uA and t8) or uA and t8 and (t8 or not t8)) and not (not t8 and uA and (uA and t8) or uA and t8 and (t8 or not t8)) then
    uX_1(t5:WaitForChild("shared", 30))
else
    uX_1 = t5(uZ:WaitForChild("shared", 30))
end
assert(uX_1, "shared folder missing")
uh = t5(uX_1:WaitForChild("modules", 30))
assert(uh, "shared.modules missing")
t8 = require(t5(uY:WaitForChild("network", 30)))
t1 = require(t5(uX_1:WaitForChild("world", 30)))
tZ = require(t5(uX_1:WaitForChild("shared_components", 30)))
tV = require(t5(uh:WaitForChild("levels", 30)))
tP = require(t5(uh:WaitForChild("rebirths", 30)))
tH = require(t5(uh:WaitForChild("stages", 30)))
tw = require(t5(uh:WaitForChild("zones", 30)))
uP = require(t5(uh:WaitForChild("foods", 30)))
uL = require(t5(uh:WaitForChild("trails", 30)))
uF = require(t5(uh:WaitForChild("spinWheel", 30)))
uv = { Status = "Ready", Notifications = {} }
uo = fn129
tX = fn499
tC = fn930
uC = fn722
t4 = fn496
uf = function(aS)
    local vZ
    local v0_1
    vZ = t4()
    local v_ = not vZ or tZ[aS] == nil
    local v__1
    if v_ then
        return nil
    end
    v__1, v0_1 = pcall(function()
        return t1:get(vZ, tZ[aS])
    end)
    if v__1 then
        return v0_1
    end
    return nil
end
uc = fn821
if (ub and not ua or (not ua or not ub) or (not ub or not ub or (not ua or not ub))) and ((not ub and not ua or ua and not ua) and (ub or not ua or ub and not ub)) or not ((ub and not ua or (not ua or not ub) or (not ub or not ub or (not ua or not ub))) and ((not ub and not ua or ua and not ua) and (ub or not ua or ub and not ub))) then
    tW = fn493
    tA = fn1125
    ug = fn762
else
    ug = fn493
    tW = fn1125
    tA = fn762
end
tG = fn213
t6 = fn981
uM = fn45
uA = fn55
ui = fn948
t2 = function(bH)
    return pcall(function()
        t8.upgradeRequest.fire(bH)
    end)
end
tx = function(bM)
    return pcall(function()
        t8.trailRequest.fire(bM)
    end)
end
uq = function(bR, bS)
    return pcall(function()
        t8.eggRequest.fire({ EggName = bR, Count = bS })
    end)
end
tD = fn71
uK = fn544
uk = function(b3)
    return pcall(function()
        local fire = t8.setEatingEffect.fire
        local wH = b3 and true
        local wL = if wH then 1 else 0
        local wJ = 1749 * wL + 943 * (1 - wL)
        local wK = 3906 * wL + 1011 * (1 - wL)
        if not ((wJ * 595 + wK * 3909 + wJ * wK) % 16777213 == 6363590) then
            wH = false
        end
        fire(wH)
    end)
end
tS = fn362
tt = function(cb, cc)
    local generation
    local wQ = cb.generation
    local wU = if wQ then 1 else 0
    local wS = 1599 * wU + 2556 * (1 - wU)
    local wT = 2171 * wU + 3730 * (1 - wU)
    if not ((wS * 2116 + wT * 3875 + wS * wT) % 16777213 == 15267538) then
        wQ = 0
    end
    cb.generation = wQ + 1
    generation = cb.generation
    if cb.task then
        pcall(task.cancel, cb.task)
        cb.task = nil
    end
    cb.task = task.spawn(function()
        local wN_1
        while true do
            local wM = tB() and cb.enabled and cb.generation == generation
            local wM_1
            if wM then
                wM_1, wN_1 = pcall(cc)
                if not wM_1 then
                    tX(tostring(wN_1))
                end
                local wM_2 = not tB() or not cb.enabled or cb.generation ~= generation
                if wM_2 then
                    break
                end
                local wait = task.wait
                local wN_2 = cb.delay or 1
                wait(wN_2)
                continue
            end
            break
        end
    end)
end
uE = fn435
um = fn1102
tN = fn339
t3 = fn1128
ux = "Auto (Best for Level)"
ur = fn1020
uj = fn977
tK = fn155
uy = fn1111
tF = fn301
tM = fn375
t9 = fn1072
tI = fn598
uN = fn1066
uG = fn159
uI = fn857
ub = fn759
tz = fn338
us = { enabled = false, delay = 1.6, selected = {}, lookup = {}, generation = 0 }
ul = fn271
uO = fn73
t_ = fn958
us.SetEnabled = fn33
us.SetDelay = fn743
us.SetPads = fn1132
ty = { enabled = false, delay = 0.25, zone = 0, lookup = {}, generation = 0, eating = false }
tu = fn1086
uJ = fn10
if uF and uF and (uF or t6) and (t6 or not uF) and (not t6 and false and (not uE or not uF) or (not t6 or uE or (not uF or 310))) or not (uF and uF and (uF or t6) and (t6 or not uF) and (not t6 and false and (not uE or not uF) or (not t6 or uE or (not uF or 310)))) then
    ty.SetEnabled = fn1105
    ty.SetDelay = fn115
    ty.SetZone = fn318
    tQ = { enabled = false, delay = 2, generation = 0 }
else
    tQ.SetEnabled = fn1105
    tQ.SetDelay = fn115
    tQ.SetZone = fn318
    ty = { generation = 0, enabled = false, delay = 2 }
end
tJ = fn214
tQ.SetEnabled = fn121
tQ.SetDelay = fn618
un = { enabled = false, delay = 1, generation = 0 }
ua = fn960
un.SetEnabled = fn833
un.SetDelay = fn418
uD = { enabled = false, delay = 1, selected = {}, equipBest = true, generation = 0 }
uu = fn872
uD.SetEnabled = fn186
uD.SetDelay = fn728
uD.SetTargets = fn641
uD.SetEquip = fn145
uB = { enabled = false, delay = 1.2, egg = nil, amount = 1, equipBest = true, generation = 0 }
if (not tQ or ug or tQ and tQ) and (not ug and not tQ and (not ug and not tQ)) and (not ug or not ug or (ug or ug) or (not ug or ug) and (ug and tQ)) and not ((not tQ or ug or tQ and tQ) and (not ug and not tQ and (not ug and not tQ)) and (not ug or not ug or (ug or ug) or (not ug or ug) and (ug and tQ))) then
    t_ = fn881
else
    ut = fn881
end
uB.SetEnabled = fn399
uB.SetDelay = fn777
uB.SetEgg = fn364
uB.SetAmount = fn852
uB.SetEquip = fn614
tR = { enabled = false, delay = 5, generation = 0 }
tL = fn832
tR.SetEnabled = fn13
tR.SetDelay = fn361
ud.Track(fn398)
local function uV()
    local G0
    local Hb
    local onDiscord
    G0 = nil
    onDiscord = nil
    Hb = nil
    local SaveManager, GW, GX, GY, GZ, G_, Library, G2, Toggles, G4, G5, G6, G8, ThemeManager, Options
    G6 = "https://tempohub.shop"
    GX = "+1 Tall to Escape"
    Hb = "https://discord.gg/K7Qxnxkk46"
    G_ = "https://discord.gg/K7Qxnxkk46"
    Library = getgenv().Library
    ThemeManager = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = Library.Toggles
    Options = Library.Options
    tE(ud, Library)
    GZ, G5 = ur()
    G2, G8 = tF()
    G4 = t9()
    GY = uG()
    us.lookup = G5
    ty.lookup = G8
    G0 = function(h6, h7)
        local Cn = tT(setclipboard) and setclipboard
        local Co = Cn
        if not Co then
            local Cn_1 = tT(toclipboard) and toclipboard
            Co = Cn_1 or nil
        end
        local Cn_2 = Co
        if not Cn_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local Co_1 = pcall(Cn_2, h6)
        if Co_1 then
            Library:Notify(h7)
        else
            Library:Notify("Failed to copy")
        end
    end
    onDiscord = function()
        G0(Hb, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = Hb, Copyable = true }, "|", GX, "|", "v0.2" },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(false)
    GW = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gamepad-2"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
    local function Hc_1(im)
        local DiscordGroup = im:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    for k, v in GW do
        if k ~= "Info" then
            Hc_1(v)
        end
    end
    local function Hd()
        local CJ
        CJ = nil
        local Label
        local WinsGroup = GW.Main:AddLeftGroupbox("Wins", "trophy")
        Label = WinsGroup:AddLabel(uv.Status, true)
        WinsGroup:AddDivider()
        WinsGroup:AddToggle("AutoWin", {
            Text = "Auto Win",
            Default = false,
            Callback = function(iy)
                us.SetEnabled(iy)
            end
        })
        WinsGroup:AddDropdown("WinStages", {
            Text = "Stages",
            Values = GZ,
            Default = { ux },
            Multi = true,
            AllowNull = true,
            Callback = function(iE)
                us.SetPads(iE, G5)
            end
        })
        WinsGroup:AddSlider("WinDelay", {
            Text = "Claim Hold",
            Default = 1.6,
            Min = 0.5,
            Max = 5,
            Rounding = 1,
            Suffix = "s",
            Callback = function(iI)
                us.SetDelay(iI)
            end
        })
        local TrainGroup = GW.Main:AddLeftGroupbox("Train", "dumbbell")
        TrainGroup:AddToggle("AutoTrain", {
            Text = "Auto Train",
            Default = false,
            Callback = function(iL)
                ty.SetEnabled(iL)
            end
        })
        local CM = G2[1] or "Best Unlocked"
        TrainGroup:AddDropdown("TrainZone", {
            Text = "Zone",
            Values = G2,
            Default = CM,
            Multi = false,
            AllowNull = false,
            Callback = function(iP)
                ty.SetZone(iP, G8)
            end
        })
        TrainGroup:AddSlider("TrainDelay", {
            Text = "Train Delay",
            Default = 0.25,
            Min = 0.05,
            Max = 2,
            Rounding = 2,
            Suffix = "s",
            Callback = function(iT)
                ty.SetDelay(iT)
            end
        })
        local ProgressGroup = GW.Main:AddRightGroupbox("Progress", "trending-up")
        ProgressGroup:AddToggle("AutoRebirth", {
            Text = "Auto Rebirth",
            Default = false,
            Callback = function(iW)
                tQ.SetEnabled(iW)
            end
        })
        ProgressGroup:AddSlider("RebirthDelay", {
            Text = "Rebirth Check Delay",
            Default = 2,
            Min = 0.5,
            Max = 30,
            Rounding = 1,
            Suffix = "s",
            Callback = function(i_)
                tQ.SetDelay(i_)
            end
        })
        ProgressGroup:AddToggle("AutoSpin", {
            Text = "Auto Spin Wheel",
            Default = false,
            Callback = function(i1)
                tR.SetEnabled(i1)
            end
        })
        ProgressGroup:AddSlider("SpinDelay", {
            Text = "Spin Delay",
            Default = 5,
            Min = 1,
            Max = 30,
            Rounding = 0,
            Suffix = "s",
            Callback = function(i5)
                tR.SetDelay(i5)
            end
        })
        local ShopGroup = GW.Main:AddRightGroupbox("Shop", "shopping-cart")
        ShopGroup:AddToggle("AutoUpgrades", {
            Text = "Auto Buy Best Affordable Upgrades",
            Default = false,
            Callback = function(i8)
                un.SetEnabled(i8)
            end
        })
        ShopGroup:AddSlider("UpgradeDelay", {
            Text = "Upgrade Delay",
            Default = 1,
            Min = 0.2,
            Max = 10,
            Rounding = 1,
            Suffix = "s",
            Callback = function(jc)
                un.SetDelay(jc)
            end
        })
        ShopGroup:AddDivider("Auras")
        ShopGroup:AddToggle("AutoAura", {
            Text = "Auto Buy Aura",
            Default = false,
            Callback = function(je)
                uD.SetEnabled(je)
            end
        })
        ShopGroup:AddDropdown("AuraTargets", {
            Text = "Auras",
            Values = G4,
            Default = {},
            Multi = true,
            AllowNull = true,
            Callback = function(jj)
                uD.SetTargets(jj)
            end
        })
        ShopGroup:AddToggle("AuraEquipBest", {
            Text = "Equip Best Aura",
            Default = true,
            Callback = function(jl)
                uD.SetEquip(jl)
            end
        })
        ShopGroup:AddDivider("Pets")
        ShopGroup:AddToggle("AutoPets", {
            Text = "Auto Buy Pets",
            Default = false,
            Callback = function(jn)
                uB.SetEnabled(jn)
            end
        })
        local CM_1 = GY[1] or ""
        ShopGroup:AddDropdown("PetEgg", {
            Text = "Egg",
            Values = GY,
            Default = CM_1,
            Multi = false,
            AllowNull = true,
            Callback = function(js)
                uB.SetEgg(js)
            end
        })
        ShopGroup:AddDropdown("PetAmount", {
            Text = "Amount",
            Values = { "1", "3" },
            Default = "1",
            Multi = false,
            AllowNull = false,
            Callback = function(ju)
                uB.SetAmount(ju)
            end
        })
        ShopGroup:AddToggle("PetEquipBest", {
            Text = "Equip Best Pets",
            Default = true,
            Callback = function(jw)
                uB.SetEquip(jw)
            end
        })
        CJ = task.spawn(function()
            while not Library.Unloaded do
                pcall(function()
                    local Ct_1
                    local Cs_1
                    local Cr = "?"
                    Cs_1, Ct_1 = pcall(tP.requiredLevel, uA())
                    local Cu = Cs_1 and type(Ct_1) == "number"
                    if Cu then
                        Cr = tostring(Ct_1)
                    end
                    local format = string.format
                    local Ct_2 = tostring(uM())
                    local Cu_1 = t6()
                    local Cv = uA()
                    local Cw = ui()
                    local Cx = uf("food") or "?"
                    local Cy = format("Wins %s  |  Level %d/%s  |  Rebirths %d  |  Spins %d  |  Food %s", Ct_2, Cu_1, Cr, Cv, Cw, tostring(Cx))
                    Label:SetText(Cy .. "  |  " .. tostring(uv.Status))
                end)
                local CH = false
                repeat
                    local CD
                    if uv.Notifications and #uv.Notifications > 0 then
                        CD = table.remove(uv.Notifications, 1)
                        pcall(function()
                            Library:Notify(CD.text, CD.time)
                        end)
                    else
                        CH = true
                    end
                until CH
                task.wait(0.3)
            end
        end)
        ud.Track(function()
            if coroutine.status(CJ) ~= "dead" then
                pcall(task.cancel, CJ)
            end
        end)
    end
    Hd()
    local function Hc_2()
        local Dc
        local C6
        local C2
        local C9
        C2 = nil
        C6 = nil
        C9 = nil
        Dc = nil
        local C3, Label2, Label3, C7, C8, Da, Label, Dd, De
        C9 = function(j4)
            return (tostring(j4):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
        end
        C2 = function(j6, j7)
            return string.format('<font color="%s">%s</font>', j7, C9(j6))
        end
        Da = function(ka, kb, kc)
            return string.format("<b>%s</b> %s %s", ka, C2("-", "#5a6070"), C2(kb, kc))
        end
        local Df = "#6ec1ff"
        local Dg = {}
        C7 = "#7fd47f"
        C3 = "#e8a34d"
        local Dh = "#8b93a3"
        local Di = type(t8) ~= "table" or type(t8.upgradeRequest) ~= "table"
        if Di then
            table.insert(Dg, "network")
        end
        if not tW() then
            table.insert(Dg, "world folder")
        end
        local Di_1 = #Dg == 0 and "ready"
        local Dj = Di_1 or "limited: " .. table.concat(Dg, ", ")
        De = "Unknown"
        pcall(function()
            local CP_1
            local CO_1
            if tT(identifyexecutor) then
                CP_1, CO_1 = identifyexecutor()
                local CQ = CP_1 ~= ""
                local CR = type(CP_1) == "string" and CQ
                if CR then
                    local CQ_1 = type(CO_1) == "string" and CO_1 ~= "" and CP_1 .. " " .. CO_1
                    De = CQ_1 or CP_1
                end
            end
        end)
        C6 = os.clock()
        Dd = function()
            local CW = math.floor(os.clock() - C6)
            if CW < 60 then
                return CW .. "s"
            elseif CW < 3600 then
                return string.format("%dm %ds", math.floor((CW) / (60)), CW % 60)
            else
                return string.format("%dh %dm", math.floor((CW) / (3600)), math.floor((CW % 3600) / (60)))
            end
        end
        local UserGroup = GW.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(Da("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, C7), true)
        UserGroup:AddLabel(Da("UserId", tostring(LocalPlayer.UserId), Df), true)
        UserGroup:AddLabel(Da("Executor", De .. "  " .. Dj, C7), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(Da("Session", Dd(), C3), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                G0(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                G0("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = GW.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(Da("Game", GX, Df), true)
        Label2 = SessionGroup:AddLabel(Da("Players", "0/0", C7), true)
        C8 = tostring(game.JobId)
        local Df_1 = #C8 > 18 and string.sub(C8, 1, 18) .. "..."
        local Di_3 = Df_1 or C8
        SessionGroup:AddLabel(Da("Job", Di_3, Dh), true)
        Label = SessionGroup:AddLabel(Da("Ping", "0 ms", C3), true)
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
                G0(C8, "Copied Job ID")
            end
        })
        Dc = task.spawn(function()
            local CZ_1
            local CY_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(Da("Session", Dd(), C3))
                Label2:SetText(Da("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), C7))
                CY_1, CZ_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local CY_2 = CY_1 and CZ_1 .. " ms" or "n/a"
                Label:SetText(Da("Ping", CY_2, C3))
            end
        end)
        ud.Track(function()
            if coroutine.status(Dc) ~= "dead" then
                task.cancel(Dc)
            end
        end)
        local SocialsGroup = GW.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                G0(G_, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                G0(G6, "Copied website link")
            end
        })
    end
    Hc_2()
    local function Hc_3()
        local lw
        local lu
        local lv
        local lt
        local MovementGroup = GW.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = GW.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        lt = {}
        lw = {}
        lu = {}
        lv = {}
        local ls = {}
        local function lx()
            for k, v in lt do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(lt)
        end
        local function lB()
            for k, v in lu do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(lu)
        end
        local function lF()
            for k, v in lv do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(lv)
        end
        local function lJ(lK)
            if not lK:IsA("ProximityPrompt") then
                return
            end
            if lw[lK] == nil then
                lw[lK] = {
                    HoldDuration = lK.HoldDuration,
                    MaxActivationDistance = lK.MaxActivationDistance,
                    RequiresLineOfSight = lK.RequiresLineOfSight
                }
            end
            lK.HoldDuration = 0
            lK.MaxActivationDistance = 50
            lK.RequiresLineOfSight = false
        end
        local function lM()
            for k, v in lw do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(lw)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                lF()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                lB()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                lx()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for k, v in uz:QueryDescendants("ProximityPrompt") do
                    pcall(lJ, v)
                end
            else
                lM()
            end
        end)
        table.insert(ls, uz.DescendantAdded:Connect(function(l4)
            if Toggles.InstantProximityPrompt.Value then
                lJ(l4)
            end
        end))
        table.insert(ls, RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if lt[v] == nil then
                        lt[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(ls, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Ea = uC()
            if Toggles.InfJump.Value and Ea then
                Ea:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(ls, RunService.RenderStepped:Connect(function(mq)
            if Library.Unloaded then
                return
            end
            local Eg = uC()
            local Eh = tC()
            local CurrentCamera = uz.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and Eg then
                if lu[Eg] == nil then
                    lu[Eg] = Eg.WalkSpeed
                end
                Eg.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and Eh and Eg and CurrentCamera then
                if lv[Eg] == nil then
                    lv[Eg] = Eg.PlatformStand
                end
                Eg.PlatformStand = true
                local Eg_1 = Vector3.zero
                if not UserInputService:GetFocusedTextBox() then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        Eg_1 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        Eg_1 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        Eg_1 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        Eg_1 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        Eg_1 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        Eg_1 -= Vector3.new(0, 1, 0)
                    end
                end
                Eh.AssemblyLinearVelocity = Vector3.zero
                if Eg_1.Magnitude > 0 then
                    Eh.CFrame = Eh.CFrame + Eg_1.Unit * Options.FlySpeed.Value * mq
                end
            end
        end))
        ud.Track(function()
            for k, v in ls do
                v:Disconnect()
            end
            lx()
            lB()
            lF()
            lM()
        end)
    end
    Hc_3()
    local function Hc_4()
        local Fy, Fz, Label, FB, FC, FD, FE, FF, FG, FH, FI, FJ, FK, FL
        FB = {}
        FJ = {}
        FG = nil
        FL = false
        FH = 0
        FD = 0
        Fy = os.clock()
        local MenuGroup = GW.Settings:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        FE = function()
            local CurrentCamera
            CurrentCamera = uz.CurrentCamera
            local Ex = not CurrentCamera or not tT(VirtualUser.CaptureController) or not tT(VirtualUser.ClickButton2)
            if Ex then
                return false
            end
            local Ex_1 = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            end)
            if not Ex_1 then
                return false
            end
            FH += 1
            Fy = os.clock()
            pcall(function()
                Label:SetText("AFK triggers: " .. FH)
            end)
            return true
        end
        Fz = function(m6)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not m6)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not m6
                end
            end)
            if not m6 then
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
        FK = function(nm)
            local ED = nm.ClassName == "ParticleEmitter" or nm.ClassName == "Trail"
            local EH = if ED then 1 else 0
            local EF = 3 * EH + 1364 * (1 - EH)
            local EG = 1800 * EH + 89 * (1 - EH)
            if not ((EF * 502 + EG * 52 + EF * EG) % 16777213 == 100506) then
                ED = nm.ClassName == "Smoke"
            end
            local EH_1 = if ED then 1 else 0
            local EF_1 = 2012 * EH_1 + 646 * (1 - EH_1)
            local EG_1 = 2848 * EH_1 + 3006 * (1 - EH_1)
            if not ((EF_1 * 3618 + EG_1 * 686 + EF_1 * EG_1) % 16777213 == 14963320) then
                ED = nm.ClassName == "Fire"
            end
            if not ED then
                ED = nm.ClassName == "Sparkles"
            end
            if not ED then
                ED = nm.ClassName == "Explosion"
            end
            local EH_2 = if ED then 1 else 0
            local EF_2 = 3004 * EH_2 + 2738 * (1 - EH_2)
            local EG_2 = 1933 * EH_2 + 3730 * (1 - EH_2)
            if not ((EF_2 * 2384 + EG_2 * 911 + EF_2 * EG_2) % 16777213 == 14729231) then
                ED = nm.ClassName == "Beam"
            end
            if ED then
                if FB[nm] == nil then
                    FB[nm] = nm.Enabled
                end
                pcall(function()
                    nm.Enabled = false
                end)
            end
        end
        FI = function()
            for k, v in FB do
                local EM = k
                local EO = v
                if EM.Parent then
                    pcall(function()
                        EM.Enabled = EO
                    end)
                end
            end
            table.clear(FB)
            if FG then
                pcall(function()
                    settings().Rendering.QualityLevel = FG.Quality
                end)
                Lighting.GlobalShadows = FG.Shadows
                Lighting.FogEnd = FG.Fog
                FG = nil
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(nB)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not nB)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(nG)
                if nG then
                    if not FG then
                        FG = {
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
                    for k, v in uz:QueryDescendants("ParticleEmitter,Trail,Smoke,Fire,Sparkles,Beam") do
                        pcall(FK, v)
                    end
                else
                    FI()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        Fz(true)
        local ScriptGroup = GW.Settings:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiGameplayPause:OnChanged(function()
            Fz(Toggles.AntiGameplayPause.Value)
        end)
        if Toggles.AntiGameplayPause.Value then
            Fz(true)
        end
        table.insert(FJ, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                FE()
            end
        end))
        table.insert(FJ, uz.DescendantAdded:Connect(function(nZ)
            if Toggles.FpsBoost.Value then
                FK(nZ)
            end
        end))
        FF = function(n2)
            if FL or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            FL = true
            local E3 = FD
            local E4_1 = pcall(function()
                if n2 then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not E4_1 then
                FL = false
                if not n2 and E3 == FD then
                    task.delay(1.5, function()
                        if E3 == FD then
                            FF(true)
                        end
                    end)
                end
            end
        end
        table.insert(FJ, TeleportService.TeleportInitFailed:Connect(function(ol)
            local Fb
            if ol == LocalPlayer and FL then
                FL = false
                Fb = FD
                task.delay(3, function()
                    if Fb == FD then
                        FF(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local Fg = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            local Fg_1 = not Fg
            local Fh = Library.Unloaded
            local Fl = if Fh then 1 else 0
            local Fj = 826 * Fl + 1855 * (1 - Fl)
            local Fk = 2693 * Fl + 343 * (1 - Fl)
            if not ((Fj * 101 + Fk * 3967 + Fj * Fk) % 16777213 == 12990975) then
                Fh = Fg_1
            end
            if Fh then
                return
            end
            table.insert(FJ, Fg.ChildAdded:Connect(function(oC)
                if oC.Name == "ErrorPrompt" then
                    FF(false)
                end
            end))
        end)
        FC = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    Fz(true)
                end
                local Fm = Toggles.AntiAfk.Value and os.clock() - Fy >= 60
                if Fm then
                    FE()
                end
                task.wait(1)
            end
        end)
        ud.Track(function()
            FD += 1
            for k, v in FJ do
                v:Disconnect()
            end
            pcall(task.cancel, FC)
            Fz(false)
            FI()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    Hc_4()
    local function Hc_5()
        local GG, GH, GI, GJ
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("TempoHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(GW.Settings)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/TallEscape")
        local GK = SaveManager:BuildConfigSection(GW.Settings)
        GI = function(o2, o3)
            local FP_1 = (o2 == "Toggle" and Toggles or Options)[o3]
            local FO_2 = type(FP_1) == "table" and FP_1.Type == o2
            return FO_2 and FP_1 or nil
        end
        GG = function(pc, pd)
            local Type = pd.Type
            if Type == "Toggle" then
                return { idx = pc, type = "Toggle", value = pd.Value == true }
            elseif Type == "Slider" then
                return { idx = pc, type = "Slider", value = tostring(pd.Value) }
            elseif Type == "Dropdown" then
                return { idx = pc, type = "Dropdown", multi = pd.Multi == true, value = pd.Value }
            elseif Type == "Input" then
                local FT = pd.Value or ""
                return { idx = pc, type = "Input", text = tostring(FT) }
            elseif Type == "ColorPicker" then
                return { idx = pc, type = "ColorPicker", value = pd.Value:ToHex(), transparency = pd.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = pc,
                    type = "KeyPicker",
                    mode = pd.Mode,
                    key = pd.Value,
                    modifiers = pd.Modifiers,
                    toggled = pd.Toggled
                }
            else
                return nil
            end
        end
        GJ = function()
            local F1 = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local F2 = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if F2 then
                        local F2_1 = GG(k, v)
                        if F2_1 then
                            F1[#F1 + 1] = F2_1
                        end
                    end
                end
            end
            table.sort(F1, function(pn, po)
                if pn.type ~= po.type then
                    return pn.type < po.type
                end
                return pn.idx < po.idx
            end)
            return { objects = F1 }
        end
        GH = function(pq)
            local Gi
            Gi = nil
            local Gj = type(pq) ~= "table" or type(pq.idx) ~= "string" or type(pq.type) ~= "string" or SaveManager.Ignore[pq.idx]
            if Gj then
                return false
            end
            Gi = GI(pq.type, pq.idx)
            if not Gi then
                return false
            end
            local Gj_1 = pcall(function()
                if pq.type == "Input" then
                    if type(pq.text) ~= "string" then
                        return
                    end
                    Gi:SetValue(pq.text)
                elseif pq.type == "ColorPicker" then
                    Gi:SetValueRGB(Color3.fromHex(pq.value), pq.transparency)
                elseif pq.type == "KeyPicker" then
                    Gi:SetValue({ pq.key, pq.mode, pq.modifiers })
                    if pq.mode == "Toggle" and pq.toggled ~= nil then
                        Gi.Toggled = pq.toggled
                        Gi:Update()
                    end
                else
                    Gi:SetValue(pq.value)
                end
            end)
            return Gj_1
        end
        GK:AddDivider()
        GK:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        GK:AddButton("Export Config to Clipboard", function()
            local Gm_1
            local Gl_1
            Gl_1, Gm_1 = pcall(HttpService.JSONEncode, HttpService, GJ())
            if Gl_1 then
                local Gl_2 = tT(setclipboard) and setclipboard
                local Gn = Gl_2
                if not Gn then
                    local Gl_3 = tT(toclipboard) and toclipboard
                    local Go = Gl_3
                    local Gs = if Go then 1 else 0
                    local Gq = 1582 * Gs + 1103 * (1 - Gs)
                    local Gr = 3030 * Gs + 609 * (1 - Gs)
                    if not ((Gq * 460 + Gr * 2353 + Gq * Gr) % 16777213 == 12650770) then
                        Go = nil
                    end
                    Gn = Go
                end
                local Gl_4 = Gn
                local Gn_1 = type(Gl_4) == "function" and pcall(Gl_4, Gm_1)
                if Gn_1 then
                    Library:Notify("Config copied to clipboard", 6)
                    return
                end
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Failed to encode the config")
        end)
        GK:AddButton("Import Config from Clipboard Text", function()
            local Gv_1
            local Gt = Options.SaveManager_ImportSource.Value or ""
            local Gt_1
            local Gu = tostring(Gt):match("^%s*(.-)%s*$")
            if Gu == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            if #Gu > 262144 then
                Library:Notify("That config is too large")
                return
            end
            Gt_1, Gv_1 = pcall(HttpService.JSONDecode, HttpService, Gu)
            local Gu_1 = not Gt_1
            local Gz = if Gu_1 then 1 else 0
            local Gx = 1597 * Gz + 1532 * (1 - Gz)
            local Gy = 442 * Gz + 1813 * (1 - Gz)
            if not ((Gx * 3716 + Gy * 3465 + Gx * Gy) % 16777213 == 8171856) then
                Gu_1 = type(Gv_1) ~= "table"
            end
            if not Gu_1 then
                Gu_1 = type(Gv_1.objects) ~= "table"
            end
            if Gu_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            if #Gv_1.objects > 2048 then
                Library:Notify("That config has too many records")
                return
            end
            local Gt_2 = 0
            for i, v in ipairs(Gv_1.objects) do
                if GH(v) then
                    Gt_2 += 1
                end
            end
            if Gt_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local Gv_2 = Gt_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(Gt_2, Gv_2), 6)
        end)
        ThemeManager:LoadDefault()
        SaveManager:LoadAutoloadConfig()
        if Options.WinDelay then
            us.SetDelay(Options.WinDelay.Value)
        end
        if Options.WinStages then
            us.SetPads(Options.WinStages.Value, G5)
        end
        if Options.TrainDelay then
            ty.SetDelay(Options.TrainDelay.Value)
        end
        if Options.TrainZone then
            ty.SetZone(Options.TrainZone.Value, G8)
        end
        if Options.RebirthDelay then
            tQ.SetDelay(Options.RebirthDelay.Value)
        end
        if Options.SpinDelay then
            tR.SetDelay(Options.SpinDelay.Value)
        end
        if Options.UpgradeDelay then
            un.SetDelay(Options.UpgradeDelay.Value)
        end
        if Options.AuraTargets then
            uD.SetTargets(Options.AuraTargets.Value)
        end
        if Toggles.AuraEquipBest then
            uD.SetEquip(Toggles.AuraEquipBest.Value)
        end
        if Options.PetEgg then
            uB.SetEgg(Options.PetEgg.Value)
        end
        if Options.PetAmount then
            uB.SetAmount(Options.PetAmount.Value)
        end
        if Toggles.PetEquipBest then
            uB.SetEquip(Toggles.PetEquipBest.Value)
        end
        if Toggles.AutoWin then
            us.SetEnabled(Toggles.AutoWin.Value)
        end
        if Toggles.AutoTrain then
            ty.SetEnabled(Toggles.AutoTrain.Value)
        end
        if Toggles.AutoRebirth then
            tQ.SetEnabled(Toggles.AutoRebirth.Value)
        end
        if Toggles.AutoSpin then
            tR.SetEnabled(Toggles.AutoSpin.Value)
        end
        if Toggles.AutoUpgrades then
            un.SetEnabled(Toggles.AutoUpgrades.Value)
        end
        if Toggles.AutoAura then
            uD.SetEnabled(Toggles.AutoAura.Value)
        end
        if Toggles.AutoPets then
            uB.SetEnabled(Toggles.AutoPets.Value)
        end
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    Hc_5()
end
uV()
end)(...)

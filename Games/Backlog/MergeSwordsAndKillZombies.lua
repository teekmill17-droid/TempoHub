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
getgenv().TempoHoodSubtitle = "MERGE SWORDS AND KILL ZOMBIE"
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
local iy
local ic
local iX
local iE
local i2
local iK
local h5
local Rebirth
local CombatConfig
local ib
local iW
local ij
local i1
local Swords
local iP
local iw
local ia
local iV
local Label
local ii
local i0
local iI
local connection
local i6
local CurrentCamera2
local iv
local h9
local Upgrades
local Options
local Net
local iH
local Toggles
local connection2
local iN
local iu
local h8
local iT
local iA
local ig
local iZ
local HttpService
local im
local i4
local VirtualUser
local it
local h7
local SetNotifySide
local Workspace
local ie
local iY
local iF
local il
local i3
local iL
local is
local h6
local UserInputService
local function onStepped()
    if ib.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = it.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local mm_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if mm_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn49(F, G)
    ib.NotifySide = G
    pcall(SetNotifySide, F, G)
end
local function fn51(ff, fg)
    local na_1 = (ff == "Toggle" and Toggles or Options)[fg]
    local m9_2 = type(na_1) == "table" and na_1.Type == ff
    local m9_3 = m9_2 and na_1
    local ni = if m9_3 then 1 else 0
    local ng = 3657 * ni + 3830 * (1 - ni)
    local nh = 2790 * ni + 2874 * (1 - ni)
    if not ((ng * 1379 + nh * 112 + ng * nh) % 16777213 == 15558513) then
        m9_3 = nil
    end
    return m9_3
end
local function fn57()
    local kQ = {}
    for i, v in ipairs(iL()) do
        local attr = v:GetAttribute("SwordId")
        if type(attr) == "string" then
            local kS = kQ[attr]
            if not kS then
                kS = {}
                kQ[attr] = kS
            end
            kS[#kS + 1] = v
        end
    end
    return kQ
end
local function onRscripts()
    ic(h8, "Copied Rscripts profile to clipboard")
end
local function fn118(bN)
    local k6_1
    local k5_1
    local k4_1
    k6_1, k5_1, k4_1 = nil, nil, nil
    for k, v in pairs(bN) do
        local k7 = #v >= 2 and iv(k)
        if k7 then
            local k7_1 = Swords.Get(k)
            local k7_2 = k7_1 and k7_1.Tier or 0
            local k8_1 = not k4_1
            if not k8_1 then
                k8_1 = k7_2 < k4_1
            end
            if k8_1 then
                k6_1, k5_1, k4_1 = v[1], v[2], k7_2
            end
        end
    end
    return k6_1, k5_1
end
local function fn120()
    if not Toggles.WalkSpeedEnabled.Value then
        local mk = ii()
        if mk then
            mk.WalkSpeed = 16
        end
    end
end
local function fn137(af)
    local jO = Toggles[af]
    return jO ~= nil and jO.Value == true
end
local function fn155()
    local nq = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local nr = type(v) == "table" and type(v.Type) == "string" and not iW.Ignore[k]
            if nr then
                local nr_1 = iZ(k, v)
                if nr_1 then
                    nq[#nq + 1] = nr_1
                end
            end
        end
    end
    table.sort(nq, function(fA, fB)
        if fA.type ~= fB.type then
            return fA.type < fB.type
        end
        return fA.idx < fB.idx
    end)
    return { objects = nq }
end
local function fn156()
    i1(Toggles.AntiGameplayPause.Value)
end
local function fn181()
    ib.ScreenGui.Parent = it:WaitForChild("PlayerGui")
end
local function onInputChanged(dJ)
    local UserInputType = dJ.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        im = tick()
    end
end
local function fn219(cI)
    if not cI then
        return
    end
    local GetReach = CombatConfig.GetReach
    local lM = it:GetAttribute("AttackRange") or 1
    local lN = GetReach(lM)
    local pivot = cI:GetPivot()
    iN(pivot * CFrame.new(0, 3, math.max(2, lN * 0.35)))
end
local function fn221(cR)
    local DiscordGroup = cR:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = i0 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = i0 })
end
local function onCopyJoinScript_JobID()
    local c7 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, iw)
    ic(c7, "Copied join script to clipboard")
end
local function fn243(aD)
    local j3 = Upgrades.Get(aD)
    if not j3 then
        return 1
    elseif j3.MaxFromSwords then
        return #Swords.Order
    else
        return j3.MaxLevel or 1
    end
end
local function antiAfkLoop()
    while not ib.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local m1 = tick() - im
            local m2 = tick() - ie
            if m1 >= 300 and m2 >= 60 then
                pcall(iX)
            else
                if m1 < 300 and m2 >= 300 then
                    pcall(iX)
                end
            end
        end
    end
end
local function onInputBegan()
    im = tick()
end
local function fn318()
    local ky = if iy() then 1 else 0
    if ky == 1 then
        pcall(function()
            Net.DoRebirth.send()
        end)
    end
end
local function worker()
    local lY_1
    while true do
        task.wait(1)
        if ib.Unloaded then
            break
        end
        local lX = math.floor(os.clock() - h5)
        if lX < 60 then
            lY_1 = lX .. "s"
        elseif lX < 3600 then
            lY_1 = string.format("%dm %ds", math.floor((lX) / (60)), lX % 60)
        else
            lY_1 = string.format("%dh %dm", math.floor((lX) / (3600)), math.floor((lX % 3600) / (60)))
        end
        Label:SetText(is("Session time", lY_1, iY))
    end
end
local function fn337()
    ic(ia, "Copied Discord invite to clipboard")
end
local function fn345()
    local kq = it:GetAttribute("RebirthLevel") or 0
    if Rebirth.MAX_LEVEL <= kq then
        return false
    end
    local kq_1 = it:GetAttribute("MaxTierReached") or 1
    local kq_2 = Rebirth.GateTier(kq + 1)
    local kr_1 = type(kq_2) == "number" and kq_2 <= kq_1
    return kr_1
end
local function onHeartbeat()
    if ib.Unloaded then
        return
    end
    local mQ = if not iP("AntiKnockback") then 1 else 0
    if mQ == 1 then
        return
    end
    local mJ = i6()
    local mK = ii()
    if not mJ then
        return
    end
    if mK and mK.PlatformStand and not (Toggles.Fly and Toggles.Fly.Value) then
        mK.PlatformStand = false
    end
    local AssemblyLinearVelocity = mJ.AssemblyLinearVelocity
    local mL_1 = Vector3.new(AssemblyLinearVelocity.X, 0, AssemblyLinearVelocity.Z)
    if mL_1.Magnitude > 45 then
        mJ.AssemblyLinearVelocity = Vector3.new(0, AssemblyLinearVelocity.Y, 0)
    end
    mJ.AssemblyAngularVelocity = Vector3.zero
end
local function worker3()
    while not ib.Unloaded do
        local mV = iP("AutoFarmZombies") and not iP("AutoMerge")
        if mV then
            local mV_1 = iF()
            if mV_1 then
                ij(mV_1)
                task.wait(0.2)
            else
                task.wait(0.4)
            end
        else
            task.wait(0.35)
        end
    end
end
local function fn392(fn, fo)
    local Type = fo.Type
    if Type == "Toggle" then
        return { idx = fn, type = "Toggle", value = fo.Value == true }
    elseif Type == "Slider" then
        return { idx = fn, type = "Slider", value = tostring(fo.Value) }
    elseif Type == "Dropdown" then
        return { idx = fn, type = "Dropdown", multi = fo.Multi == true, value = fo.Value }
    elseif Type == "Input" then
        local nk = fo.Value or ""
        return { idx = fn, type = "Input", text = tostring(nk) }
    elseif Type == "ColorPicker" then
        return { idx = fn, type = "ColorPicker", value = fo.Value:ToHex(), transparency = fo.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = fn,
            type = "KeyPicker",
            mode = fo.Mode,
            key = fo.Value,
            modifiers = fo.Modifiers,
            toggled = fo.Toggled
        }
    else
        return nil
    end
end
local function onRenderStepped(eh)
    if ib.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local mC_1 = ii()
        if mC_1 then
            mC_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local mC_3 = i6()
        local mD = ii()
        if mC_3 and mD then
            mD.PlatformStand = true
            local mD_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                mD_1 = mD_1 + CurrentCamera2.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                mD_1 = mD_1 - CurrentCamera2.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                mD_1 = mD_1 - CurrentCamera2.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                mD_1 = mD_1 + CurrentCamera2.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                mD_1 = mD_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                mD_1 = mD_1 - Vector3.new(0, 1, 0)
            end
            mC_3.AssemblyLinearVelocity = Vector3.zero
            if mD_1.Magnitude > 0 then
                mC_3.CFrame = mC_3.CFrame + mD_1.Unit * Options.FlySpeed.Value * eh
            end
        end
    end
    local mC_4 = iP("KillAura") and not iP("AutoMerge") and os.clock() - iH >= 0.12
    if mC_4 then
        iH = os.clock()
        local mC_5 = iF(Options.KillAuraRange.Value)
        if mC_5 then
            ij(mC_5)
        end
    end
end
local function worker5()
    while not ib.Unloaded do
        task.wait(30)
        if iP("AutoClaimDaily") then
            h7()
        end
    end
end
local function fn414()
    local kH = {}
    local SwordsRuntime = Workspace:FindFirstChild("SwordsRuntime")
    if not SwordsRuntime then
        return kH
    end
    for i, child in ipairs(SwordsRuntime:GetChildren()) do
        local kI_1 = child.Name == "SwordPickup" and child:GetAttribute("OwnerUserId") == it.UserId and child:GetAttribute("FieldDeployed") ~= true
        if kI_1 then
            kH[#kH + 1] = child
        end
    end
    return kH
end
local function fn432()
    local Character = it.Character
    local jV = Character and Character:FindFirstChild("HumanoidRootPart")
    return jV
end
local function fn433(W, X, Y)
    return string.format("<b>%s</b> %s %s", W, iK("-", "#5a6070"), iK(X, Y))
end
local function antiGameplayPauseLoop()
    while not ib.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            i1(true)
        end
    end
end
local function fn448()
    local lm = if it:GetAttribute("HeldSwordId") == nil then 1 else 0
    if lm == 1 then
        return false
    end
    pcall(function()
        Net.DropSword.send()
    end)
    local lh = os.clock() + 1
    while true do
        local li = it:GetAttribute("HeldSwordId") ~= nil and os.clock() < lh
        if li then
            task.wait(0.05)
            continue
        end
        break
    end
    return it:GetAttribute("HeldSwordId") == nil
end
local function fn463(ax)
    if type(ax) == "table" then
        ig = ax
    end
end
local function fn467()
    i1(false)
    if connection then
        connection:Disconnect()
    end
    if connection2 then
        connection2:Disconnect()
    end
    select("#", "Unloaded!")
end
local function onExportConfigToClipboard()
    local nO_1
    local nN_1
    nN_1, nO_1 = pcall(HttpService.JSONEncode, HttpService, iE())
    if not nN_1 then
        ib:Notify("Failed to encode the config")
        return
    end
    local nN_2 = setclipboard or toclipboard
    local nN_3 = type(nN_2) ~= "function" or not pcall(nN_2, nO_1)
    if nN_3 then
        ib:Notify("Your executor does not support copying to the clipboard")
        return
    end
    ib:Notify("Config copied to clipboard", 6)
end
local function fn494(aI)
    local j9 = Upgrades.Get(aI)
    if not j9 then
        return false
    end
    local j9_1 = it:GetAttribute(aI) or 1
    local j9_2 = iT(aI)
    if j9_1 >= j9_2 then
        return false
    elseif aI == "SpawnType" then
        local Cap = Rebirth.Cap
        local kb = it:GetAttribute("RebirthLevel") or 0
        local kc = Cap(kb)
        if j9_1 >= kc then
            return false
        end
        local kg_1 = if it:GetAttribute("FreeUpgradeUsed") == true then 1 else 0
        if kg_1 == 1 then
            local j9_4 = Upgrades.Cost(aI, j9_1)
            local ka_1 = it:GetAttribute("Cash") or 0
            return ka_1 >= j9_4
        end
        return true
    else
        local kg_2 = if it:GetAttribute("FreeUpgradeUsed") == true then 1 else 0
        if kg_2 == 1 then
            local j9_5 = Upgrades.Cost(aI, j9_1)
            local ka_2 = it:GetAttribute("Cash") or 0
            return ka_2 >= j9_5
        end
        return true
    end
end
local function onJumpRequest()
    if ib.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local mx_1 = ii()
        if mx_1 then
            mx_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn533(cn)
    local lv = cn and cn:IsA("Model") and cn:GetAttribute("ZombieId") ~= nil
    if not lv then
        return false
    end
    local Humanoid = cn:FindFirstChildOfClass("Humanoid")
    if Humanoid and Humanoid.Health <= 0 then
        return false
    end
    return true
end
local function onImportConfigFromClipboardTex()
    local nT_1
    local nR = Options.SaveManager_ImportSource.Value or ""
    local nR_1
    local nS = tostring(nR):match("^%s*(.-)%s*$")
    if nS == "" then
        ib:Notify("Paste an exported config into the box first")
        return
    end
    nR_1, nT_1 = pcall(HttpService.JSONDecode, HttpService, nS)
    local nS_1 = not nR_1
    local nX = if nS_1 then 1 else 0
    local nV = 3037 * nX + 3840 * (1 - nX)
    local nW = 3567 * nX + 296 * (1 - nX)
    if not ((nV * 2227 + nW * 3780 + nV * nW) % 16777213 == 14302425) then
        nS_1 = type(nT_1) ~= "table"
    end
    if not nS_1 then
        nS_1 = type(nT_1.objects) ~= "table"
    end
    if nS_1 then
        ib:Notify("That is not a valid exported config")
        return
    end
    local nR_2 = 0
    for i, v in ipairs(nT_1.objects) do
        if iu(v) then
            nR_2 += 1
        end
    end
    if nR_2 == 0 then
        ib:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local nT_2 = nR_2 == 1 and "" or "s"
    ib:Notify(("Imported %d setting%s"):format(nR_2, nT_2), 6)
end
local function fn586(as)
    local Character = it.Character
    if not Character then
        return
    end
    if Character.PrimaryPart then
        Character:PivotTo(as)
    else
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = as
        end
    end
end
local function fn596(cs)
    local lA_1
    local lz_1
    local ly = i6()
    if not ly then
        return nil
    end
    lA_1, lz_1 = nil, nil
    for i, child in ipairs(Workspace:GetChildren()) do
        if i4(child) then
            local Position = child:GetPivot().Position
            local Magnitude = (Position - ly.Position).Magnitude
            local lD = not cs or Magnitude <= cs
            if lD then
                lD = not lz_1 or Magnitude < lz_1
            end
            if lD then
                lA_1, lz_1 = child, Magnitude
            end
        end
    end
    return lA_1, lz_1
end
local function fn610()
    return it:WaitForChild("PlayerGui")
end
local function fn620()
    local lQ_1
    local lP_1
    if identifyexecutor then
        lQ_1, lP_1 = identifyexecutor()
        local lR = lQ_1 ~= ""
        local lS = type(lQ_1) == "string" and lR
        if lS then
            local lR_1 = type(lP_1) == "string" and lP_1 ~= "" and lQ_1 .. " " .. lP_1
            h9 = lR_1 or lQ_1
        end
    end
end
local function fn628()
    if not Toggles.Fly.Value then
        local mi = ii()
        if mi then
            mi.PlatformStand = false
        end
    end
end
local function fn637(bG)
    local k_ = Swords.Next(bG)
    if not k_ then
        return false
    end
    local Cap = Rebirth.Cap
    local k1 = it:GetAttribute("RebirthLevel") or 0
    local k2 = Cap(k1)
    return k_.Tier <= k2
end
local function fn646(M, N)
    if setclipboard then
        setclipboard(M)
    elseif toclipboard then
        toclipboard(M)
    end
    ib:Notify(N)
end
local function worker2()
    while not ib.Unloaded do
        if iP("AutoMerge") then
            local mR = il()
            local mR_1 = mR and 0.2 or 0.45
            task.wait(mR_1)
        else
            task.wait(0.35)
        end
    end
end
local function fn663()
    pcall(function()
        Net.DailyRewardSync.send()
    end)
end
local function fn685(T, U)
    return string.format('<font color="%s">%s</font>', U, T)
end
local function fn699()
    local lp_2, lp_3, lp_4
    local ln = h6()
    local attr = it:GetAttribute("HeldSwordId")
    local lo_1, lo_2, lo_4
    if type(attr) == "string" then
        local lp_1 = ln[attr]
        local lq = lp_1 and #lp_1 >= 1 and iv(attr)
        if lq then
            iN(lp_1[1]:GetPivot() * CFrame.new(0, 3, 0))
            task.wait(0.35)
            return true
        end
        lo_1, lp_2 = i2(ln)
        if not lo_1 then
            return false
        elseif not iV() then
            return false
        else
            task.wait(0.15)
            local ln_1 = h6()
            lo_2, lp_3 = i2(ln_1)
            if not lo_2 then
                return false
            end
            iN(lo_2:GetPivot() * CFrame.new(0, 3, 0))
            task.wait(0.35)
            if lp_3 and lp_3.Parent then
                iN(lp_3:GetPivot() * CFrame.new(0, 3, 0))
                task.wait(0.4)
            end
            return true
        end
    else
        lo_4, lp_4 = i2(ln)
        if not lo_4 then
            return false
        end
        iN(lo_4:GetPivot() * CFrame.new(0, 3, 0))
        task.wait(0.35)
        if lp_4 and lp_4.Parent then
            iN(lp_4:GetPivot() * CFrame.new(0, 3, 0))
            task.wait(0.4)
        end
        return true
    end
end
local function onUnload()
    ib:Unload()
end
local function worker4()
    while not ib.Unloaded do
        local m_ = if iP("AutoBuyUpgrades") then 1 else 0
        if m_ == 1 then
            iA()
        end
        if iP("AutoRebirth") then
            i3()
        end
        if iP("AutoClaimDaily") then
            iI()
        end
        task.wait(1)
    end
end
local function fn778()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    ie = tick()
end
local function fn804()
    local Character = it.Character
    local jS = Character and Character:FindFirstChildOfClass("Humanoid")
    return jS
end
h5 = nil
h6 = nil
h7 = nil
h8 = nil
h9 = nil
ia = nil
ib = nil
ic = nil
ie = nil
ig = nil
Options = nil
ii = nil
ij = nil
il = nil
im = nil
Toggles = nil
connection = nil
is = nil
it = nil
iu = nil
iv = nil
iw = nil
CombatConfig = nil
iy = nil
Workspace = nil
iA = nil
Label = nil
iE = nil
iF = nil
HttpService = nil
iH = nil
iI = nil
Swords = nil
iK = nil
iL = nil
VirtualUser = nil
iN = nil
CurrentCamera2 = nil
iP = nil
Rebirth = nil
UserInputService = nil
SetNotifySide = nil
iT = nil
Upgrades = nil
iV = nil
local ik, iq, ir, iB, DailyRewardsConfig
iW = nil
iX = nil
iY = nil
iZ = nil
Net = nil
i0 = nil
i1 = nil
i2 = nil
i3 = nil
i4 = nil
connection2 = nil
i6 = nil
local ji_1
local jh_1
local jd_1
local jq_1
local je_1
local AccountGroup
local jj_3
UserInputService, VirtualUser, HttpService, Workspace, it = nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local i7_1
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FeaturesGroup
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
Workspace = game:GetService("Workspace")
it = Players.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return it:WaitForChild("PlayerGui")
    end
end
ia, h8, Net, Upgrades, Rebirth, Swords, DailyRewardsConfig, CombatConfig, ir, ik, ib, iW = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
gethui = fn610
local jc = "Merge Swords And Kill Zombies!"
ia = "https://discord.gg/K7Qxnxkk46"
h8 = "https://discord.gg/K7Qxnxkk46"
local Shared = ReplicatedStorage:WaitForChild("Shared")
local jb_1
Net = require(Shared:WaitForChild("Net"))
Upgrades = require(Shared.Config.Upgrades)
Rebirth = require(Shared.Config.Rebirth)
Swords = require(Shared.Config.Swords)
DailyRewardsConfig = require(Shared.Config.DailyRewardsConfig)
CombatConfig = require(Shared:WaitForChild("CombatConfig"))
ir = { "SpawnType", "CashMultiplier", "AttackRange" }
if ir and DailyRewardsConfig or h8 and not CombatConfig or 23 or ((not DailyRewardsConfig or h8) and (h8 and not ir) or h8 and ir and (not ir and not CombatConfig)) or not (ir and DailyRewardsConfig or h8 and not CombatConfig or 23 or ((not DailyRewardsConfig or h8) and (h8 and not ir) or h8 and ir and (not ir and not CombatConfig))) then
    ik = { SpawnType = "Spawn Type", CashMultiplier = "Cash Multiplier", AttackRange = "Sword Range" }
    ib = getgenv().Library
    pcall(fn181)
    jd_1 = getgenv().ThemeManager
    iW = getgenv().SaveManager
else
    iW = { AttackRange = "Sword Range", CashMultiplier = "Cash Multiplier", SpawnType = "Spawn Type" }
    jd_1 = ""
    local _ = getgenv().Library
    pcall(fn181)
    ik = getgenv().ThemeManager
    ib = getgenv().SaveManager
end
SetNotifySide = nil
if (SetNotifySide or (SetNotifySide or 10)) and false and ((SetNotifySide or not SetNotifySide) and 10 or (not SetNotifySide and SetNotifySide or false)) or ((SetNotifySide or SetNotifySide) and false or (not SetNotifySide and SetNotifySide)) or not ((SetNotifySide or (SetNotifySide or 10)) and false and ((SetNotifySide or not SetNotifySide) and 10 or (not SetNotifySide and SetNotifySide or false)) or ((SetNotifySide or SetNotifySide) and false or (not SetNotifySide and SetNotifySide))) then
    SetNotifySide = ib.SetNotifySide
else
    ib = SetNotifySide.SetNotifySide
end
ib.SetNotifySide = fn49
Toggles, Options, iY, ig, i7_1, ic, i0, iK, is, iP, ii, i6, iN, h7, iT, iq, iA, iy, i3, iI, iL, h6, iv, i2, iV, il, i4, iF, ij = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Toggles = ib.Toggles
Options = ib.Options
ic = fn646
i0 = fn337
iK = fn685
is = fn433
if ((i7_1 and iy or (not iy or i7_1) or (not iy or not is) and (not iy and i7_1)) and ((not iy or not is or i6 and is) and (i7_1 and not iy and (not i6 or not i7_1))) or (is or iy or (i6 or not i7_1) or not i7_1 and i7_1 and (not is and iy)) and ((not i6 and not i6 or iy and i6) and (i6 or not i7_1 or i7_1 and i7_1))) and not ((i7_1 and iy or (not iy or i7_1) or (not iy or not is) and (not iy and i7_1)) and ((not iy or not is or i6 and is) and (i7_1 and not iy and (not i6 or not i7_1))) or (is or iy or (i6 or not i7_1) or not i7_1 and i7_1 and (not is and iy)) and ((not i6 and not i6 or iy and i6) and (i6 or not i7_1 or i7_1 and i7_1))) then
    jh_1 = "#7fd47f"
    iY = "#6ec1ff"
    jb_1 = "#e8a34d"
else
    jb_1 = "#7fd47f"
    jh_1 = "#6ec1ff"
    iY = "#e8a34d"
end
local jg = "#8b93a3"
iP = fn137
ii = fn804
i6 = fn432
iN = fn586
ig = nil
Net.DailyRewardState.listen(fn463)
h7 = fn663
h7()
iT = fn243
iq = fn494
iA = function()
    local kh = Options.AutoBuyUpgradesList and Options.AutoBuyUpgradesList.Value
    if type(kh) ~= "table" then
        return
    end
    for i, v in ipairs(ir) do
        local kp = v
        local kh_1 = kh[ik[kp]] == true and iq(kp)
        if kh_1 then
            pcall(function()
                Net.BuyUpgrade.send(kp)
            end)
            task.wait(0.15)
        end
    end
end
iy = fn345
i3 = fn318
iI = function()
    if not ig then
        h7()
        return
    end
    local kA = tonumber(ig.nextIn) or -1
    local kA_1 = tonumber(ig.claimedCount) or 0
    local kz = kA_1 + 1
    local kA_2 = kA == 0 and DailyRewardsConfig.isReal(kz)
    if kA_2 then
        pcall(function()
            Net.DailyRewardClaim.send({ tier = kz })
        end)
        task.wait(0.35)
        h7()
    end
end
iL = fn414
h6 = fn57
iv = fn637
i2 = fn118
iV = fn448
il = fn699
i4 = fn533
iF = fn596
ij = fn219
local Window = ib:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = ia, Copyable = true }, "|", jc },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local jf = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "swords"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in jf do
    fn221(v)
end
h9, AccountGroup, ji_1, Label, iw, je_1 = nil, nil, nil, nil, nil, nil
local i7_3 = 3
repeat
    local i9_2 = (i7_3 * 1 + 2) % 3 + 1
    if i9_2 <= 2 then
        if i9_2 <= 1 then
            local i9_3 = (vector.create((i7_3 * 7 + 3) % 11 + 1, (i7_3 * 1 + 5) % 13 + 1, (i7_3 * 1 + 3) % 17 + 1))
            local oW = vector.floor(i9_3) + vector.ceil(i9_3 * -1)
            if vector.dot(oW, oW) == 3 then
                ji_1 = tostring(game.JobId)
            else
                iw = tostring(game.JobId)
            end
            i7_3 = (i7_3 + 10) % 12
        else
            local i9_4 = (vector.create((i7_3 * 7 + 9) % 11 + 1, (i7_3 * 7 + 4) % 13 + 1, (i7_3 * 12 + 7) % 17 + 1))
            local jj_1 = (vector.create((i7_3 * 3 + 9) % 11 + 1, (i7_3 * 1 + 2) % 13 + 1, (i7_3 * 3 + 3) % 17 + 1))
            local oN = vector.cross(i9_4, jj_1)
            local oO = vector.dot(i9_4, jj_1)
            if vector.dot(oN, oN) + oO * oO == vector.dot(i9_4, i9_4) * vector.dot(jj_1, jj_1) then
                je_1 = #iw > 18
            else
                iw = #je_1 > 18
            end
            i7_3 = (i7_3 + 1) % 12
        end
    else
        local i9_5 = { "qbylmrxgak", "khfuku", "meajwum", "cyaiesuic", "mudseoha", "wzu", "qodxyhmj", "kmvq" }
        local o3 = i7_3
        local jj_2 = i9_5[o3 % 8 + 1]
        if jj_2:len() >= jj_2:gsub("(.)", "%1%1", o3 % 3 % 2 + 1):len() then
            is = "Unknown"
            pcall(fn620)
            jf = iY.Info:AddLeftGroupbox("Account", "circle-user")
            jf:AddLabel(ji_1("User", nil, iK), true)
            jf:AddLabel(ji_1("Status", "Keyless", iK), true)
            jf:AddLabel(ji_1("Executor", is, iK), true)
            jh_1 = iY.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            jh_1:AddLabel(Label(AccountGroup .. " [" .. tostring(game.PlaceId) .. "]", h9), true)
            jh_1:AddLabel(ji_1("Place ID", tostring(game.PlaceId), h9), true)
            it = jh_1:AddLabel(ji_1("Session time", "0s", jb_1), true)
        else
            h9 = "Unknown"
            pcall(fn620)
            AccountGroup = jf.Info:AddLeftGroupbox("Account", "circle-user")
            AccountGroup:AddLabel(is("User", it.Name, jb_1), true)
            AccountGroup:AddLabel(is("Status", "Keyless", jb_1), true)
            AccountGroup:AddLabel(is("Executor", h9, jb_1), true)
            ji_1 = jf.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            ji_1:AddLabel(iK(jc .. " [" .. tostring(game.PlaceId) .. "]", jh_1), true)
            ji_1:AddLabel(is("Place ID", tostring(game.PlaceId), jh_1), true)
            Label = ji_1:AddLabel(is("Session time", "0s", iY), true)
        end
        i7_3 = (i7_3 + 10) % 12
    end
until (i7_3 * 11 + 11) % 12 == 11
if je_1 then
    local i7_4 = 6
    repeat
        if not i7_4 or not i7_4 or not i7_4 and not i7_4 or (not i7_4 or not i7_4) and (i7_4 and i7_4) or not (not i7_4 or not i7_4 or not i7_4 and not i7_4 or (not i7_4 or not i7_4) and (i7_4 and i7_4)) then
            je_1 = string.sub(iw, 1, 18) .. "..."
        else
            iw = string.sub(je_1, 1, 18) .. "..."
        end
        i7_4 = (i7_4 + 5) % 8
    until (i7_4 * 7 + 1) % 8 == 6
end
local i7_5 = je_1 or iw
h5, FeaturesGroup, jq_1, jj_3, im, ie, connection, connection2, CurrentCamera2, iH, iX, i1, iB, iZ, iE, iu = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
ji_1:AddLabel(is("Server", i7_5, jg), true)
ji_1:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
h5 = os.clock()
task.spawn(worker)
local ScriptsGroup = jf.Info:AddRightGroupbox("Scripts", "package")
if ((CurrentCamera2 or iH) and (not jj_3 or jq_1) or (not jq_1 and not CurrentCamera2 or (not jq_1 or CurrentCamera2))) and ((iH and iH or (jq_1 or not iH)) and (jq_1 or not CurrentCamera2 or (not iH or CurrentCamera2))) or CurrentCamera2 and jj_3 and (not jj_3 and jq_1) and ((not CurrentCamera2 or not CurrentCamera2) and (not iH and iH)) and ((not iH or not CurrentCamera2) and (not iH or not CurrentCamera2) or (jj_3 or iH) and (not iH or iH)) or not (((CurrentCamera2 or iH) and (not jj_3 or jq_1) or (not jq_1 and not CurrentCamera2 or (not jq_1 or CurrentCamera2))) and ((iH and iH or (jq_1 or not iH)) and (jq_1 or not CurrentCamera2 or (not iH or CurrentCamera2))) or CurrentCamera2 and jj_3 and (not jj_3 and jq_1) and ((not CurrentCamera2 or not CurrentCamera2) and (not iH and iH)) and ((not iH or not CurrentCamera2) and (not iH or not CurrentCamera2) or (jj_3 or iH) and (not iH or iH))) then
    ScriptsGroup:AddLabel(iK("Included in this hub", jg), true)
    ScriptsGroup:AddLabel(iK(jc, jh_1), true)
    FeaturesGroup = jf.Info:AddRightGroupbox("Features", "list")
else
    jh_1:AddLabel(FeaturesGroup("Included in this hub", jc), true)
    jh_1:AddLabel(FeaturesGroup(ScriptsGroup, jf), true)
    jg = iK.Info:AddRightGroupbox("Features", "list")
end
FeaturesGroup:AddLabel(iK("Auto Merge", jh_1), true)
FeaturesGroup:AddLabel(iK("Auto Buy Upgrades", jh_1), true)
FeaturesGroup:AddLabel(iK("Auto Rebirth", iY), true)
FeaturesGroup:AddLabel(iK("Auto Farm Zombies", iY), true)
FeaturesGroup:AddLabel(iK("Kill Aura", iY), true)
FeaturesGroup:AddLabel(iK("Anti-Knockback", jg), true)
FeaturesGroup:AddLabel(iK("Auto Claim Daily Rewards", jg), true)
FeaturesGroup:AddLabel(iK("Player Movement", jg), true)
local SocialsGroup = jf.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = i0 })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = jf.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = i0 })
local FaqGroup = jf.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutomationGroup = jf.Main:AddLeftGroupbox("Automation", "bot")
AutomationGroup:AddToggle("AutoMerge", { Text = "Auto Merge", Default = false })
AutomationGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
AutomationGroup:AddDropdown("AutoBuyUpgradesList", {
    Text = "Upgrades",
    Values = { "Spawn Type", "Cash Multiplier", "Sword Range" },
    Default = { "Spawn Type", "Cash Multiplier", "Sword Range" },
    Multi = true,
    AllowNull = true
})
AutomationGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
AutomationGroup:AddToggle("AutoClaimDaily", { Text = "Auto Claim Daily Rewards", Default = false })
local CombatGroup = jf.Main:AddRightGroupbox("Combat", "skull")
CombatGroup:AddToggle("AutoFarmZombies", { Text = "Auto Farm Zombies", Default = false })
CombatGroup:AddToggle("KillAura", { Text = "Kill Aura", Default = false })
CombatGroup:AddSlider("KillAuraRange", { Text = "Kill Aura Range", Default = 200, Min = 20, Max = 2000, Rounding = 0 })
CombatGroup:AddToggle("AntiKnockback", { Text = "Anti-Knockback", Default = true })
local MovementGroup = jf.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = jf.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
local MenuGroup = jf.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
ib.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
im = tick()
ie = tick()
pcall(function()
    for i, v in ipairs(getconnections(it.Idled)) do
        local l5 = v
        pcall(function()
            l5:Disable()
        end)
    end
end)
iX = fn778
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
i1 = function(dP)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not dP)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not dP
        end
    end)
    if not dP then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(it, "GameplayPaused", false)
        else
            it.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fn156)
Toggles.Fly:OnChanged(fn628)
Toggles.WalkSpeedEnabled:OnChanged(fn120)
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera2 = Workspace.CurrentCamera
iH = 0
RunService.RenderStepped:Connect(onRenderStepped)
RunService.Heartbeat:Connect(onHeartbeat)
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(antiAfkLoop)
task.spawn(antiGameplayPauseLoop)
jd_1:SetLibrary(ib)
jd_1:SetFolder("TempoHub")
jd_1:SaveDefault("Monochrome")
jd_1:ApplyToTab(jf.Settings)
jd_1:LoadDefault()
iW:SetLibrary(ib)
iW:IgnoreThemeSettings()
iW:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
iW:SetFolder("TempoHub/MergeSwordsAndKillZombies")
local jl = iW:BuildConfigSection(jf.Settings)
iB = fn51
iZ = fn392
iE = fn155
iu = function(fD)
    local nK
    nK = nil
    local nL = type(fD) ~= "table" or type(fD.idx) ~= "string" or type(fD.type) ~= "string" or iW.Ignore[fD.idx]
    if nL then
        return false
    end
    nK = iB(fD.type, fD.idx)
    if not nK then
        return false
    end
    local nL_1 = pcall(function()
        if fD.type == "Input" then
            if type(fD.text) ~= "string" then
                return
            end
            nK:SetValue(fD.text)
        elseif fD.type == "ColorPicker" then
            nK:SetValueRGB(Color3.fromHex(fD.value), fD.transparency)
        elseif fD.type == "KeyPicker" then
            nK:SetValue({ fD.key, fD.mode, fD.modifiers })
            if fD.mode == "Toggle" and fD.toggled ~= nil then
                nK.Toggled = fD.toggled
                nK:Update()
            end
        else
            nK:SetValue(fD.value)
        end
    end)
    return nL_1
end
if (not TempoHubGroup and not iX and (not h5 and false) or iX and not jl and (TempoHubGroup and TempoHubGroup)) and (i1 or i1 or (jl or i1) or (jl and not h5 or not iX and not TempoHubGroup)) and not ((not TempoHubGroup and not iX and (not h5 and false) or iX and not jl and (TempoHubGroup and TempoHubGroup)) and (i1 or i1 or (jl or i1) or (jl and not h5 or not iX and not TempoHubGroup))) then
    ib:AddDivider()
    ib:AddInput("SaveManager_ImportSource", { Finished = true, AllowEmpty = true, Text = "Paste exported config here" })
    ib:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    ib:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
    jl:LoadAutoloadConfig()
    iW:OnUnload(fn467)
else
    jl:AddDivider()
    jl:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    jl:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    jl:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
    iW:LoadAutoloadConfig()
    ib:OnUnload(fn467)
end
end)(...)

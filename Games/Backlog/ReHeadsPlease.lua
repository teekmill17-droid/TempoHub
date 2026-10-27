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
getgenv().TempoHoodSubtitle = "RE HEADS PLEASE!"
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
local kA
local Data
local jV
local kg
local onBuyTicketsOnce
local kj
local onSpinOnce
local SaveManager
local kp
local kM
local ItemInventory
local Toggles
local CurrentCamera2
local j9
local onCraftOnce
local kw
local kz
local kc
local Workspace
local onCoinGachaOnce
local onAccessoryGachaOnce
local ki
local HttpService
local connection2
local kl
local VirtualUser
local j2
local kL
local ko
local Label
local kr
local j8
local onCoinShopOnce
local kb
local ky
local onRuinedUpgradeOnce
local kB
local jW
local kE
local kh
local kk
local kH
local SetNotifySide
local onUpgradeOnce
local Options
local onSellOnce
local kq
local j4
local UserInputService
local CoinInventory
local kQ
local kt
local connection
local kx
local function antiAfkLoop()
    while not j9.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local pk = tick() - kE
            local pl = tick() - kA
            if pk >= 300 and pl >= 60 then
                pcall(ko)
            else
                if pk < 300 and pl >= 300 then
                    pcall(ko)
                end
            end
        end
    end
end
local function fn10()
    j9.ScreenGui.Parent = kz:WaitForChild("PlayerGui")
end
local function onJumpRequest()
    if j9.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local oV_1 = kL()
        if oV_1 then
            oV_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn65()
    pcall(function()
        kg.Enchant:FireServer(1, {})
    end)
end
local function onRscripts()
    kH(kr, "Copied Rscripts profile to clipboard")
end
local function fn92(gh, gi)
    local pq_1 = (gh == "Toggle" and Toggles or Options)[gi]
    local pp_2 = type(pq_1) == "table" and pq_1.Type == gh
    return pp_2 and pq_1 or nil
end
local function fn99()
    kg.AccessoryGacha:FireServer("GetPity")
end
local function fn133()
    local pD = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local pE = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if pE then
                local pE_1 = kj(k, v)
                if pE_1 then
                    pD[#pD + 1] = pE_1
                end
            end
        end
    end
    table.sort(pD, function(gC, gD)
        if gC.type ~= gD.type then
            return gC.type < gD.type
        end
        return gC.idx < gD.idx
    end)
    return { objects = pD }
end
local function onRenderStepped(fz)
    if j9.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local o__1 = kL()
        if o__1 then
            o__1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local o__3 = ky()
        local o0 = kL()
        if o__3 and o0 then
            o0.PlatformStand = true
            local o0_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                o0_1 = o0_1 + CurrentCamera2.CFrame.LookVector
            end
            local o5 = if UserInputService:IsKeyDown(Enum.KeyCode.S) then 1 else 0
            if o5 == 1 then
                o0_1 = o0_1 - CurrentCamera2.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                o0_1 = o0_1 - CurrentCamera2.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                o0_1 = o0_1 + CurrentCamera2.CFrame.RightVector
            end
            local o5_1 = if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
            if o5_1 == 1 then
                o0_1 = o0_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                o0_1 = o0_1 - Vector3.new(0, 1, 0)
            end
            o__3.AssemblyLinearVelocity = Vector3.zero
            if o0_1.Magnitude > 0 then
                o__3.CFrame = o__3.CFrame + o0_1.Unit * Options.FlySpeed.Value * fz
            end
        end
    end
end
local function fn140()
    if Toggles.AutoCoinGacha.Value then
        kb("CoinGacha", "Auto-ON")
    else
        kb("CoinGacha", "Auto-OFF")
    end
end
local function enchantDelayLoop()
    while not j9.Unloaded do
        if jW("AutoEnchant") then
            kl()
            task.wait(Options.EnchantDelay.Value)
        else
            task.wait(0.35)
        end
    end
end
local function onTeleportToAccessoryShop()
    kq(kk["Accessory Shop"])
end
local function worker()
    local n1_1
    while true do
        task.wait(1)
        if j9.Unloaded then
            break
        end
        local n0 = math.floor(os.clock() - kM)
        if n0 < 60 then
            n1_1 = n0 .. "s"
        elseif n0 < 3600 then
            n1_1 = string.format("%dm %ds", math.floor((n0) / (60)), n0 % 60)
        else
            n1_1 = string.format("%dh %dm", math.floor((n0) / (3600)), math.floor((n0 % 3600) / (60)))
        end
        Label:SetText(kh("Session time", n1_1, j4))
    end
end
local function fn196()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    kA = tick()
end
local function onUnload()
    j9:Unload()
end
local function fn213()
    if not Toggles.WalkSpeedEnabled.Value then
        local oI = kL()
        if oI then
            oI.WalkSpeed = 16
        end
    end
end
local function fn224()
    kg.CoinGacha:FireServer("GetPity")
end
local function fn236()
    local Character = kz.Character
    local l0 = Character and Character:FindFirstChild("HumanoidRootPart")
    return l0
end
local function fn248(ag, ah)
    if setclipboard then
        setclipboard(ag)
    elseif toclipboard then
        toclipboard(ag)
    end
    j9:Notify(ah)
end
local function upgradeDelayLoop()
    while not j9.Unloaded do
        if jW("AutoUpgrade") then
            onUpgradeOnce()
            task.wait(Options.UpgradeDelay.Value)
        else
            task.wait(0.35)
        end
    end
end
local function fn255(aM)
    local Character = kz.Character
    if not Character then
        return
    end
    local l3 = CFrame.new(aM)
    if Character.PrimaryPart then
        Character:PivotTo(l3)
    else
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = l3
        end
    end
end
local function onStepped()
    if j9.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = kz.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local oK_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if oK_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function onInputChanged(eU)
    local UserInputType = eU.UserInputType
    local oj = UserInputType == Enum.UserInputType.MouseMovement
    local on = if oj then 1 else 0
    local ol = 2333 * on + 897 * (1 - on)
    local om = 3706 * on + 3702 * (1 - on)
    if not ((ol * 3795 + om * 1225 + ol * om) % 16777213 == 5262470) then
        oj = UserInputType == Enum.UserInputType.Gamepad1
    end
    if oj then
        kE = tick()
    end
end
local function craftDelayLoop()
    while not j9.Unloaded do
        if jW("AutoCraft") then
            onCraftOnce()
            task.wait(Options.CraftDelay.Value)
        else
            task.wait(0.35)
        end
    end
end
local function onRefreshCoinList()
    Options.EquipCoinName:SetValues(kQ())
    j9:Notify("Coin list refreshed")
end
local function fn308(aq, ar, as)
    return string.format("<b>%s</b> %s %s", aq, kp("-", "#5a6070"), kp(ar, as))
end
local function fn329()
    kb("Enchant", "Auto-OFF")
    kb("CoinGacha", "Auto-OFF")
    kb("AccessoryGacha", "Auto-OFF")
    jV(false)
    if connection then
        connection:Disconnect()
    end
    if connection2 then
        connection2:Disconnect()
    end
    select("#", "Unloaded!")
end
local function coinGachaDelayLoop()
    while not j9.Unloaded do
        if jW("AutoCoinGacha") then
            onCoinGachaOnce()
            task.wait(Options.CoinGachaDelay.Value)
        else
            task.wait(0.35)
        end
    end
end
local function fn342(an, ao)
    return string.format('<font color="%s">%s</font>', ao, an)
end
local function sellDelayLoop()
    while not j9.Unloaded do
        if jW("AutoSell") then
            onSellOnce()
            task.wait(Options.SellDelay.Value)
        else
            task.wait(0.35)
        end
    end
end
local function fn486()
    kH(kt, "Copied Discord invite to clipboard")
end
local function fn496()
    kx(Toggles.SkipCutscenes.Value)
end
local function fn502(dy)
    local DiscordGroup = dy:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = kw })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = kw })
end
local function onInputBegan()
    kE = tick()
end
local function fn519()
    if not Toggles.Fly.Value then
        local oG = kL()
        if oG then
            oG.PlatformStand = false
        end
    end
end
local function fn583()
    Data:FireServer("Init")
end
local function fn584()
    kg.RuinedStation:FireServer("GetLevel")
end
local function fn596()
    local Character = kz.Character
    local lY = Character and Character:FindFirstChildOfClass("Humanoid")
    return lY
end
local function ruinedUpgradeDelayLoop()
    while not j9.Unloaded do
        if jW("AutoRuinedUpgrade") then
            onRuinedUpgradeOnce()
            task.wait(Options.RuinedUpgradeDelay.Value)
        else
            task.wait(0.35)
        end
    end
end
local function onTeleportToUpgrade()
    kq(kk.Upgrade)
end
local function onTeleportToCoinShop()
    kq(kk["Coin Shop"])
end
local function onSpawnSkateboard()
    pcall(function()
        kg.Skateboard:FireServer("Spawn")
    end)
end
local function coinShopDelayLoop()
    while not j9.Unloaded do
        if jW("AutoCoinShop") then
            onCoinShopOnce()
            task.wait(Options.CoinShopDelay.Value)
        else
            task.wait(0.35)
        end
    end
end
local function fn670(az)
    local lR = Toggles[az]
    return lR ~= nil and lR.Value == true
end
local function fn672()
    local mt = kz:GetAttribute("ActionDisabled") and kz:GetAttribute("ActionDisabled") > 0
    if mt then
        return
    end
    if kz:GetAttribute("Flipping") then
        return
    end
    pcall(function()
        kg.Clicked:FireServer(true)
    end)
end
local function fn681(Z, aa)
    j9.NotifySide = aa
    pcall(SetNotifySide, Z, aa)
end
local function onTeleportToEnchant()
    kq(kk.Enchant)
end
local function onImportConfigFromClipboardTex()
    local qb_1
    local p9 = Options.SaveManager_ImportSource.Value or ""
    local p9_1
    local qa = tostring(p9):match("^%s*(.-)%s*$")
    if qa == "" then
        j9:Notify("Paste an exported config into the box first")
        return
    end
    p9_1, qb_1 = pcall(HttpService.JSONDecode, HttpService, qa)
    local qa_1 = not p9_1 or type(qb_1) ~= "table" or type(qb_1.objects) ~= "table"
    if qa_1 then
        j9:Notify("That is not a valid exported config")
        return
    end
    local p9_2 = 0
    for i, v in ipairs(qb_1.objects) do
        if kB(v) then
            p9_2 += 1
        end
    end
    if p9_2 == 0 then
        j9:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local qb_2 = p9_2 == 1 and "" or "s"
    j9:Notify(("Imported %d setting%s"):format(p9_2, qb_2), 6)
end
local function fn719(aX)
    local l6 = ItemInventory:FindFirstChild(aX)
    return l6 and l6.Value or 0
end
local function spinDelayLoop()
    while not j9.Unloaded do
        if jW("AutoSpin") then
            onSpinOnce()
            task.wait(Options.SpinDelay.Value)
        else
            task.wait(0.35)
        end
    end
end
local function flipDelayLoop()
    while not j9.Unloaded do
        if jW("AutoFlip") then
            kc()
            task.wait(Options.FlipDelay.Value)
        else
            task.wait(0.2)
        end
    end
end
local function fn784()
    local nX_1
    local nW_1
    if identifyexecutor then
        nX_1, nW_1 = identifyexecutor()
        local nY = nX_1 ~= ""
        local nZ = type(nX_1) == "string" and nY
        if nZ then
            local nY_1 = type(nW_1) == "string" and nW_1 ~= "" and nX_1 .. " " .. nW_1
            ki = nY_1 or nX_1
        end
    end
end
local function fn810()
    local l9 = {}
    for i, child in CoinInventory:GetChildren() do
        local ma = child:IsA("NumberValue") and child.Value > 0
        if ma then
            l9[#l9 + 1] = child.Name
        end
    end
    table.sort(l9)
    return l9
end
local function fn815()
    if Toggles.AutoAccessoryGacha.Value then
        kb("AccessoryGacha", "Auto-ON")
    else
        kb("AccessoryGacha", "Auto-OFF")
    end
end
local function onTeleportToSpinningWheel()
    kq(kk["Spinning Wheel"])
end
local function antiGameplayPauseLoop()
    while not j9.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            jV(true)
        end
    end
end
local function onCopyJoinScript_JobID()
    local dP = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, j2)
    kH(dP, "Copied join script to clipboard")
end
local function accessoryGachaDelayLoop()
    while not j9.Unloaded do
        if jW("AutoAccessoryGacha") then
            onAccessoryGachaOnce()
            task.wait(Options.AccessoryGachaDelay.Value)
        else
            task.wait(0.35)
        end
    end
end
local function onExportConfigToClipboard()
    local p6_1
    local p5_1
    p5_1, p6_1 = pcall(HttpService.JSONEncode, HttpService, j8())
    if not p5_1 then
        j9:Notify("Failed to encode the config")
        return
    end
    local p5_2 = setclipboard or toclipboard
    local p5_3 = type(p5_2) ~= "function" or not pcall(p5_2, p6_1)
    if p5_3 then
        j9:Notify("Your executor does not support copying to the clipboard")
        return
    end
    j9:Notify("Config copied to clipboard", 6)
end
local function onTeleport()
    local n4 = kk[Options.TeleportTarget.Value]
    if n4 then
        kq(n4)
    end
end
local function fn935(gp, gq)
    local Type = gq.Type
    if Type == "Toggle" then
        return { idx = gp, type = "Toggle", value = gq.Value == true }
    elseif Type == "Slider" then
        return { idx = gp, type = "Slider", value = tostring(gq.Value) }
    elseif Type == "Dropdown" then
        return { idx = gp, type = "Dropdown", multi = gq.Multi == true, value = gq.Value }
    elseif Type == "Input" then
        local pu = gq.Value
        local py = if pu then 1 else 0
        local pw = 191 * py + 2652 * (1 - py)
        local px = 2928 * py + 1466 * (1 - py)
        if not ((pw * 2940 + px * 3796 + pw * px) % 16777213 == 12235476) then
            pu = ""
        end
        return { idx = gp, type = "Input", text = tostring(pu) }
    elseif Type == "ColorPicker" then
        return { idx = gp, type = "ColorPicker", value = gq.Value:ToHex(), transparency = gq.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = gp,
            type = "KeyPicker",
            mode = gq.Mode,
            key = gq.Value,
            modifiers = gq.Modifiers,
            toggled = gq.Toggled
        }
    else
        return nil
    end
end
local function fn947()
    jV(Toggles.AntiGameplayPause.Value)
end
local function ticketBuyDelayLoop()
    while not j9.Unloaded do
        if jW("AutoBuyTickets") then
            onBuyTicketsOnce()
            task.wait(Options.TicketBuyDelay.Value)
        else
            task.wait(0.35)
        end
    end
end
local function fn999()
    if Toggles.AutoEnchant.Value then
        kb("Enchant", "Auto-ON")
    else
        kb("Enchant", "Auto-OFF")
    end
end
jV = nil
jW = nil
onAccessoryGachaOnce = nil
SetNotifySide = nil
connection2 = nil
onUpgradeOnce = nil
j2 = nil
SaveManager = nil
j4 = nil
Label = nil
ItemInventory = nil
CoinInventory = nil
j8 = nil
j9 = nil
connection = nil
kb = nil
kc = nil
Data = nil
onRuinedUpgradeOnce = nil
onCoinGachaOnce = nil
kg = nil
kh = nil
ki = nil
kj = nil
kk = nil
kl = nil
onSpinOnce = nil
onSellOnce = nil
ko = nil
kp = nil
kq = nil
kr = nil
CurrentCamera2 = nil
kt = nil
kw = nil
kx = nil
ky = nil
kz = nil
kA = nil
kB = nil
Workspace = nil
kE = nil
HttpService = nil
onBuyTicketsOnce = nil
kH = nil
local jU, jY, j0, kv, kD
VirtualUser = nil
Options = nil
kL = nil
kM = nil
UserInputService = nil
Toggles = nil
kQ = nil
onCoinShopOnce = nil
onCraftOnce = nil
local kJ, kO, k3, lc, le, lf
local onRedeemCode
UserInputService, VirtualUser, HttpService, Workspace, kz, kt, kr, kg, Data, CoinInventory, ItemInventory, jY, k3, jU = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local kT_4
local kZ = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
Workspace = game:GetService("Workspace")
kz = Players.LocalPlayer
local k2 = "RE:Heads, Please!"
kt = "https://discord.gg/K7Qxnxkk46"
kr = "https://discord.gg/K7Qxnxkk46"
local kY = require(kZ:WaitForChild("SharedPackage"))
local kW = kY.ControllerPackage.ReplicationController
local kV = kY.FunctionPackage
local k0 = kV.RuinedStationFunctions
kg = {
    Clicked = kW:GetRemoteEvent("Clicked"),
    Upgrade = kW:GetRemoteEvent("Upgrade"),
    Enchant = kW:GetRemoteEvent("Enchant"),
    CoinGacha = kW:GetRemoteEvent("CoinGacha"),
    AccessoryGacha = kW:GetRemoteEvent("AccessoryGacha"),
    BuyAccessoryTicket = kW:GetRemoteEvent("BuyAccessoryTicket"),
    SpinningWheel = kW:GetRemoteEvent("SpinningWheel"),
    RuinedStation = kW:GetRemoteEvent("RuinedStation"),
    CoinShop = kW:GetRemoteEvent("CoinShop"),
    EquipCoin = kW:GetRemoteEvent("EquipCoin"),
    UseItem = kW:GetRemoteEvent("UseItem"),
    Skateboard = kW:GetRemoteEvent("Skateboard"),
    Code = kW:GetRemoteEvent("Code")
}
Data = kz:WaitForChild("PlayerGui"):WaitForChild("mainInterface"):WaitForChild("Handlers"):WaitForChild("TriggerFrameHandler"):WaitForChild("Data")
local kU = kz:WaitForChild("DataFolder")
CoinInventory = kU:WaitForChild("CoinInventory")
ItemInventory = kU:WaitForChild("ItemInventory")
local EquippedCoin = kU:WaitForChild("EquippedCoin")
local k1 = { "Money Earn", "Flip Speed", "Critical Multiply", "Critical Chance", "Head Chance" }
jY = {
    ["Money Earn"] = 1,
    ["Flip Speed"] = 2,
    ["Critical Multiply"] = 3,
    ["Critical Chance"] = 4,
    ["Head Chance"] = 5
}
if (k3 and jY or not UserInputService and not jY or not Workspace and jY and (k3 or not EquippedCoin)) and not (k3 and jY or not UserInputService and not jY or not Workspace and jY and (k3 or not EquippedCoin)) then
    jU = { "x3", "x5", "x1" }
    k3 = {}
else
    k3 = { "x1", "x3", "x5" }
    jU = {}
end
local kT_1 = k0.GetSaleableItems()
for k in pairs(kT_1) do
    jU[#jU + 1] = k
end
table.sort(jU)
kJ = {}
kO = {}
local kT_2 = k0.GetRecipes()
for i, v in ipairs(kT_2) do
    local kT_3 = tostring(v[2])
    kO[#kO + 1] = kT_3
    kJ[kT_3] = i
end
kv, kV = nil, nil
kv = k0.GetUpgrades()
if (not kv or kV or not kv and not kv) and ((not kv or not kV) and (not kv or not kv)) or not ((not kv or kV or not kv and not kv) and ((not kv or not kV) and (not kv or not kv))) then
    kV = {}
else
    kv = {}
end
for i, child in CoinInventory:GetChildren() do
    kV[#kV + 1] = child.Name
end
table.sort(kV)
kk = nil
kW = { "WealthSoda", "FlipSpeedSoda", "LuckSoda", "EnchantBook", "Soda", "Icecream", "WatermelonSlice" }
do
    kk = {
        Upgrade = Vector3.new(638, 48, -51),
        Enchant = Vector3.new(725, 48, -176),
        ["Spinning Wheel"] = Vector3.new(574, 50, -133),
        ["Accessory Shop"] = Vector3.new(756, 48, -20),
        ["Coin Shop"] = Vector3.new(587, 49, -157),
        Quest = Vector3.new(654, 24, -60),
        Npc = Vector3.new(624, 49, -25),
        ["Coin Fountain"] = Vector3.new(671, 57, -94),
        ["Train Station"] = Vector3.new(4620, 23, -735)
    }
end
kU = {}
for k in pairs(kk) do
    kU[#kU + 1] = k
end
j9, kY, SaveManager = nil, nil, nil
local kX_1 = 2
repeat
    kZ = {
        "jjputqgmkul",
        "nftuuc",
        "csgatanttcf",
        "dxrxksl",
        "cxsmql",
        "verxtwmgkpd",
        "apiwqv",
        "rbokpp",
        "nbz",
        "kcmr",
        "kmpjf"
    }
    if kZ[(kX_1 * 54 + 34) % 11 + 1] <= kZ[(kX_1 * 54 + 34) % 11 + 1] then
        table.sort(kU)
        j9 = getgenv().Library
        pcall(fn10)
        kY = getgenv().ThemeManager
        SaveManager = getgenv().SaveManager
    else
        table.sort(SaveManager)
        kY = ""
        local _ = getgenv().Library
        pcall(fn10)
        j9 = getgenv().ThemeManager
        kU = getgenv().SaveManager
    end
    kX_1 = (kX_1 + 5) % 8
until (kX_1 * 3 + 3) % 8 == 0
SetNotifySide = nil
SetNotifySide = j9.SetNotifySide
j9.SetNotifySide = fn681
Toggles, Options, j4, kH, kw, kp, kh, jW, kL, ky, kq, kb, j0, kQ, kx, kc, onUpgradeOnce, kl, onCoinGachaOnce, onAccessoryGachaOnce, onBuyTicketsOnce, onSpinOnce, onCoinShopOnce, onSellOnce, onCraftOnce, onRuinedUpgradeOnce, onRedeemCode = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Toggles = j9.Toggles
Options = j9.Options
kH = fn248
kw = fn486
kp = fn342
kh = fn308
k0 = "#7fd47f"
local k7 = "#6ec1ff"
j4 = "#e8a34d"
local k6 = "#8b93a3"
jW = fn670
kL = fn596
ky = fn236
kq = fn255
kb = function(...)
    local aS = table.pack(...)
    pcall(function()
        Data:FireServer(table.unpack(aS, 1, aS.n))
    end)
end
j0 = fn719
kQ = fn810
kx = function(a7)
    pcall(function()
        local Workers = kz:WaitForChild("PlayerScripts"):WaitForChild("ClientScripts"):WaitForChild("Workers")
        local UpgradeWorker = Workers:FindFirstChild("UpgradeWorker")
        local SpinningWheelWorker = Workers:FindFirstChild("SpinningWheelWorker")
        if UpgradeWorker then
            UpgradeWorker:SetAttribute("Skipped", a7)
        end
        if SpinningWheelWorker then
            SpinningWheelWorker:SetAttribute("Skipped", a7)
        end
    end)
    if a7 then
        kb("Enchant", "Cutscene-OFF")
        kb("CoinGacha", "Cutscene-OFF")
        kb("AccessoryGacha", "Cutscene-OFF")
    else
        kb("Enchant", "Cutscene-ON")
        kb("CoinGacha", "Cutscene-ON")
        kb("AccessoryGacha", "Cutscene-ON")
    end
end
kc = fn672
onUpgradeOnce = function()
    local mB
    mB = jY[Options.UpgradeType and Options.UpgradeType.Value] or 1
    pcall(function()
        local Workers = kz.PlayerScripts.ClientScripts.Workers
        local UpgradeWorker = Workers:FindFirstChild("UpgradeWorker")
        if UpgradeWorker then
            UpgradeWorker:SetAttribute("SelectingUpgrade", mB)
            UpgradeWorker:SetAttribute("Skipped", jW("SkipCutscenes"))
        end
    end)
    pcall(function()
        kg.Upgrade:FireServer(mB)
    end)
end
kl = fn65
onCoinGachaOnce = function()
    local mF
    mF = Options.CoinGachaAmount and Options.CoinGachaAmount.Value or "x1"
    pcall(function()
        kg.CoinGacha:FireServer("Gacha", mF, true)
    end)
end
onAccessoryGachaOnce = function()
    local mJ
    mJ = Options.AccessoryGachaAmount and Options.AccessoryGachaAmount.Value or "x1"
    pcall(function()
        kg.AccessoryGacha:FireServer("Gacha", mJ, true)
    end)
end
onBuyTicketsOnce = function()
    local mN
    local mP = Options.TicketBuyAmount and Options.TicketBuyAmount.Value
    local mT = if mP then 1 else 0
    local mR = 1925 * mT + 1050 * (1 - mT)
    local mS = 1894 * mT + 126 * (1 - mT)
    if not ((mR * 3664 + mS * 309 + mR * mS) % 16777213 == 11284396) then
        mP = 1
    end
    mN = mP
    pcall(function()
        kg.BuyAccessoryTicket:FireServer(mN)
    end)
end
onSpinOnce = function()
    local mX
    mX = Options.SpinAmount and Options.SpinAmount.Value or 1
    if mX <= 0 then
        return
    end
    if j0("Coin") < mX then
        return
    end
    pcall(function()
        local Workers = kz.PlayerScripts.ClientScripts.Workers
        local SpinningWheelWorker = Workers:FindFirstChild("SpinningWheelWorker")
        if SpinningWheelWorker then
            SpinningWheelWorker:SetAttribute("Amount", mX)
            SpinningWheelWorker:SetAttribute("Skipped", jW("SkipCutscenes"))
        end
    end)
    pcall(function()
        kg.SpinningWheel:FireServer(mX)
    end)
end
onCoinShopOnce = function()
    local m0, m1
    m1 = Options.CoinShopAmount and Options.CoinShopAmount.Value or 1
    m0 = Options.CoinShopMode and Options.CoinShopMode.Value or "Buy"
    if m1 <= 0 then
        return
    end
    pcall(function()
        kg.CoinShop:FireServer(m1, m0)
    end)
end
onSellOnce = function()
    local m6 = Options.SellItemsList and Options.SellItemsList.Value
    if type(m6) ~= "table" then
        return
    end
    local m8 = Options.SellAmount and Options.SellAmount.Value
    local nc = if m8 then 1 else 0
    local na = 1564 * nc + 2419 * (1 - nc)
    local nb = 1052 * nc + 29 * (1 - nc)
    if not ((na * 710 + nb * 3845 + na * nb) % 16777213 == 6800708) then
        m8 = "x1"
    end
    local m5 = m8
    for i, v in ipairs(jU) do
        local ni = v
        local m6_2 = m6[ni] == true and j0(ni) > 0
        if m6_2 then
            pcall(function()
                kg.RuinedStation:FireServer("Sell", { ItemID = ni, SellAmount = m5 })
            end)
            task.wait(0.1)
        end
    end
end
onCraftOnce = function()
    local nl = Options.CraftRecipesList and Options.CraftRecipesList.Value
    if type(nl) ~= "table" then
        return
    end
    local nj = Options.CraftAmount and Options.CraftAmount.Value or "x1"
    for i, v in ipairs(kO) do
        if nl[v] == true then
            local nk = kJ[v]
            if nk then
                pcall(function()
                    kg.RuinedStation:FireServer("Craft", { RecipeIndex = nk, CraftAmount = nj })
                end)
                task.wait(0.15)
            end
        end
    end
end
onRuinedUpgradeOnce = function()
    local nv = Options.RuinedUpgradesList and Options.RuinedUpgradesList.Value
    if type(nv) ~= "table" then
        return
    end
    for i, v in ipairs(kv) do
        local nD = v
        if nv[nD] == true then
            pcall(function()
                kg.RuinedStation:FireServer("Upgrade", { UpgradeID = nD })
            end)
            task.wait(0.15)
        end
    end
end
local function onEquipCoin()
    local nE
    nE = Options.EquipCoinName and Options.EquipCoinName.Value
    local nF_1 = nE == ""
    local nG = type(nE) ~= "string" or nF_1
    if nG then
        return
    end
    pcall(function()
        kg.EquipCoin:FireServer(nE)
    end)
end
local function onUseItem()
    local nL, nM
    nM = Options.UseItemName and Options.UseItemName.Value
    nL = Options.UseItemAmount and Options.UseItemAmount.Value or 1
    local nN_2 = nM == ""
    local nO_1 = type(nM) ~= "string"
    local nS = if nO_1 then 1 else 0
    local nQ = 3326 * nS + 2889 * (1 - nS)
    local nR = 1595 * nS + 1356 * (1 - nS)
    if not ((nQ * 724 + nR * 3437 + nQ * nR) % 16777213 == 13195009) then
        nO_1 = nN_2
    end
    if nO_1 then
        return
    end
    if j0(nM) < nL then
        return
    end
    pcall(function()
        kg.UseItem:FireServer(nM, nL)
    end)
end
if (not j0 and false or (kc or not j0) or (not kc and not kL or (kh or onRuinedUpgradeOnce)) or (not j0 or not j0) and (kL and not j0) and (not kL and not kc and (onRuinedUpgradeOnce or not j0))) and not (not j0 and false or (kc or not j0) or (not kc and not kL or (kh or onRuinedUpgradeOnce)) or (not j0 or not j0) and (kL and not j0) and (not kL and not kc and (onRuinedUpgradeOnce or not j0))) then
    k0 = function()
        local nT
        nT = Options.RedeemCodeInput and Options.RedeemCodeInput.Value
        if type(nT) ~= "string" then
            return
        end
        nT = nT:match("^%s*(.-)%s*$")
        if nT == "" then
            j9:Notify("Paste a code first")
            return
        end
        pcall(function()
            kg.Code:FireServer(nT)
        end)
        j9:Notify("Redeemed code")
    end
else
    onRedeemCode = function()
        local nT
        nT = Options.RedeemCodeInput and Options.RedeemCodeInput.Value
        if type(nT) ~= "string" then
            return
        end
        nT = nT:match("^%s*(.-)%s*$")
        if nT == "" then
            j9:Notify("Paste a code first")
            return
        end
        pcall(function()
            kg.Code:FireServer(nT)
        end)
        j9:Notify("Redeemed code")
    end
end
pcall(fn583)
pcall(fn224)
pcall(fn99)
pcall(fn584)
local Window = j9:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = kt, Copyable = true }, "|", k2 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local la = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "coins"),
    Gacha = Window:AddTab("Gacha", "gift"),
    Station = Window:AddTab("Station", "map-pin"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
local k_ = fn502
for k, v in la do
    k_(v)
end
ki, kT_4, lc, Label, j2, kZ = nil, nil, nil, nil, nil, nil
local kX_3 = 16
repeat
    k_ = (kX_3 * 1 + 1) % 3 + 1
    if k_ <= 2 then
        if k_ <= 1 then
            if kX_3 * 90902027 + 13 + 5 <= kX_3 * 90902027 + 13 + 5 + 1 then
                j2 = tostring(game.JobId)
            else
                kT_4 = tostring(game.JobId)
            end
            kX_3 = (kX_3 + 19) % 24
        else
            local qY = bit32.rrotate(bit32.bxor(bit32.lrotate(kX_3, 28), string.byte(tostring(j2))), 17)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(qY, 2739765711), 3861212057), (bit32.bxor(bit32.band(qY, 1555201584), 2905755557))), 3861212057), 2905755557) == qY then
                kZ = #j2 > 18
            else
                j2 = #kZ > 18
            end
            kX_3 = (kX_3 + 10) % 24
        end
    else
        if (kX_3 * 2 + 5) * 7 % 3 == ((kX_3 * 2 + 5) * 7 + 6) % 3 then
            ki = "Unknown"
            pcall(fn784)
            kT_4 = la.Info:AddLeftGroupbox("Account", "circle-user")
            kT_4:AddLabel(kh("User", kz.Name, k0), true)
            kT_4:AddLabel(kh("Status", "Keyless", k0), true)
            kT_4:AddLabel(kh("Executor", ki, k0), true)
            lc = la.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            lc:AddLabel(kp(k2 .. " [" .. tostring(game.PlaceId) .. "]", k7), true)
            lc:AddLabel(kh("Place ID", tostring(game.PlaceId), k7), true)
            Label = lc:AddLabel(kh("Session time", "0s", j4), true)
        else
            kp = "Unknown"
            pcall(fn784)
            kz = (nil):AddLeftGroupbox("Account", "circle-user")
            kz:AddLabel(k2("User", k0.Name, kT_4), true)
            kz:AddLabel(k2("Status", "Keyless", kT_4), true)
            kz:AddLabel(k2("Executor", kp, kT_4), true)
            ki = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
            ki:AddLabel(Label(j4 .. " [" .. tostring(game.PlaceId) .. "]", lc), true)
            ki:AddLabel(k2("Place ID", tostring(game.PlaceId), lc), true)
            kh = ki:AddLabel(k2("Session time", "0s", la), true)
        end
        kX_3 = (kX_3 + 13) % 24
    end
until (kX_3 * 17 + 5) % 24 == 7
if kZ then
    local kT_5 = 1
    repeat
        local kX_4 = {
            "rzfjfbo",
            "rtuovjtti",
            "nzewwjkjyvl",
            "ljvgc",
            "kcbky",
            "rbphf",
            "fnfzuxlemyi",
            "osadfhco",
            "tfrh",
            "hslrspzzye"
        }
        local rC = kT_5
        k_ = kX_4[rC % 10 + 1]
        if k_:len() <= k_:gsub("(.)", "%1%1", rC % 3 % 2 + 1):len() then
            kZ = string.sub(j2, 1, 18) .. "..."
        else
            j2 = string.sub(kZ, 1, 18) .. "..."
        end
        kT_5 = (kT_5 + 3) % 4
    until (kT_5 * 3 + 2) % 4 == 2
end
local kT_6 = kZ or j2
kM, lf, le = nil, nil, nil
lc:AddLabel(kh("Server", kT_6, k6), true)
lc:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
kM = os.clock()
task.spawn(worker)
local lh = la.Info:AddRightGroupbox("Scripts", "package")
lh:AddLabel(kp("Included in this hub", k6), true)
lh:AddLabel(kp(k2, k7), true)
local lg = la.Info:AddRightGroupbox("Features", "list")
if kM and lf or (not lf or kM) or (le and not le or (not le or kM)) or not (kM and lf or (not lf or kM) or (le and not le or (not le or kM))) then
    lg:AddLabel(kp("Auto Flip", k7), true)
    lg:AddLabel(kp("Auto Upgrade", k7), true)
    lg:AddLabel(kp("Auto Enchant", k7), true)
    lg:AddLabel(kp("Auto Gacha", j4), true)
    lg:AddLabel(kp("Spin / Shop / Sell", j4), true)
    lg:AddLabel(kp("Teleports", k6), true)
    lg:AddLabel(kp("Player Movement", k6), true)
    lf = la.Info:AddRightGroupbox("Socials", "link")
else
    k6:AddLabel(j4("Auto Flip", la), true)
    k6:AddLabel(j4("Auto Upgrade", la), true)
    k6:AddLabel(j4("Auto Enchant", la), true)
    k6:AddLabel(j4("Auto Gacha", k7), true)
    k6:AddLabel(j4("Spin / Shop / Sell", k7), true)
    k6:AddLabel(j4("Teleports", lf), true)
    k6:AddLabel(j4("Player Movement", lf), true)
    kp.Info:AddRightGroupbox("Socials", "link")
end
lf:AddButton({ Text = "Discord", Func = kw })
lf:AddButton({ Text = "Rscripts", Func = onRscripts })
le = la.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
le:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
le:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
le:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
le:AddButton({ Text = "Copy Discord Invite", Func = kw })
local ld = la.Info:AddRightGroupbox("FAQ", "circle-help")
ld:AddLabel("Where do I get a good config?", true)
ld:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
ld:AddLabel("How do I import / export configs?", true)
ld:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
ld:AddLabel("How do I report bugs?", true)
ld:AddLabel("Join the Discord and post it in the bugs channel.", true)
ld:AddLabel("How do I make suggestions?", true)
ld:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
ld:AddLabel("How do I get help or updates?", true)
ld:AddLabel("Join the Discord, updates and support are posted there first.", true)
k0 = la.Main:AddLeftGroupbox("Flip", "coins")
k0:AddToggle("AutoFlip", { Text = "Auto Flip", Default = false })
k0:AddSlider("FlipDelay", { Text = "Flip Delay", Default = 0.05, Min = 0, Max = 1, Rounding = 2 })
k0:AddButton({ Text = "Flip Once", Func = kc })
k_ = la.Main:AddLeftGroupbox("Upgrade", "arrow-up")
k_:AddToggle("AutoUpgrade", { Text = "Auto Upgrade", Default = false })
k_:AddDropdown("UpgradeType", { Text = "Upgrade Type", Values = k1, Default = 1 })
k_:AddSlider("UpgradeDelay", { Text = "Upgrade Delay", Default = 0.75, Min = 0.2, Max = 5, Rounding = 2 })
k_:AddButton({ Text = "Upgrade Once", Func = onUpgradeOnce })
k_:AddButton({ Text = "Teleport to Upgrade", Func = onTeleportToUpgrade })
kZ = la.Main:AddRightGroupbox("Enchant", "sparkles")
kZ:AddToggle("AutoEnchant", { Text = "Auto Enchant", Default = false })
kZ:AddSlider("EnchantDelay", { Text = "Enchant Delay", Default = 1.5, Min = 0.3, Max = 5, Rounding = 2 })
kZ:AddToggle("SkipCutscenes", { Text = "Skip Cutscenes", Default = true })
kZ:AddButton({ Text = "Enchant Once", Func = kl })
kZ:AddButton({ Text = "Teleport to Enchant", Func = onTeleportToEnchant })
local CoinGroup = la.Main:AddRightGroupbox("Coin", "circle-dollar-sign")
local kT_7 = #kV > 0 and kV
kV = { "Penny" }
local kX_6 = kT_7
local lI = if kX_6 then 1 else 0
local lG = 3890 * lI + 1079 * (1 - lI)
local lH = 1345 * lI + 2436 * (1 - lI)
if not ((lG * 3261 + lH * 754 + lG * lH) % 16777213 == 2154257) then
    kX_6 = kV
end
kE, kA, connection, connection2, CurrentCamera2, ko, jV, kD, kj, j8, kB = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
CoinGroup:AddDropdown("EquipCoinName", { Text = "Coin", Values = kX_6, Default = EquippedCoin.Value })
CoinGroup:AddButton({ Text = "Equip Coin", Func = onEquipCoin })
CoinGroup:AddButton({ Text = "Refresh Coin List", Func = onRefreshCoinList })
lf = la.Gacha:AddLeftGroupbox("Coin Gacha", "dices")
lf:AddToggle("AutoCoinGacha", { Text = "Auto Coin Gacha", Default = false })
lf:AddDropdown("CoinGachaAmount", { Text = "Amount", Values = k3, Default = 1 })
lf:AddSlider("CoinGachaDelay", { Text = "Gacha Delay", Default = 3, Min = 0.5, Max = 10, Rounding = 1 })
lf:AddButton({ Text = "Coin Gacha Once", Func = onCoinGachaOnce })
ld = la.Gacha:AddRightGroupbox("Accessory Gacha", "shirt")
ld:AddToggle("AutoAccessoryGacha", { Text = "Auto Accessory Gacha", Default = false })
ld:AddDropdown("AccessoryGachaAmount", { Text = "Amount", Values = k3, Default = 1 })
ld:AddSlider("AccessoryGachaDelay", { Text = "Gacha Delay", Default = 3, Min = 0.5, Max = 10, Rounding = 1 })
ld:AddButton({ Text = "Accessory Gacha Once", Func = onAccessoryGachaOnce })
ld:AddButton({ Text = "Teleport to Accessory Shop", Func = onTeleportToAccessoryShop })
lc = la.Gacha:AddLeftGroupbox("Tickets", "ticket")
lc:AddToggle("AutoBuyTickets", { Text = "Auto Buy Tickets", Default = false })
lc:AddSlider("TicketBuyAmount", { Text = "Ticket Amount", Default = 1, Min = 1, Max = 100, Rounding = 0 })
lc:AddSlider("TicketBuyDelay", { Text = "Buy Delay", Default = 1, Min = 0.2, Max = 10, Rounding = 1 })
lc:AddButton({ Text = "Buy Tickets Once", Func = onBuyTicketsOnce })
k7 = la.Station:AddLeftGroupbox("Spinning Wheel", "refresh-cw")
k7:AddToggle("AutoSpin", { Text = "Auto Spin", Default = false })
k7:AddSlider("SpinAmount", { Text = "Spin Amount", Default = 1, Min = 1, Max = 100, Rounding = 0 })
k7:AddSlider("SpinDelay", { Text = "Spin Delay", Default = 2, Min = 0.5, Max = 10, Rounding = 1 })
k7:AddButton({ Text = "Spin Once", Func = onSpinOnce })
k7:AddButton({ Text = "Teleport to Spinning Wheel", Func = onTeleportToSpinningWheel })
k6 = la.Station:AddLeftGroupbox("Coin Shop", "store")
k6:AddToggle("AutoCoinShop", { Text = "Auto Coin Shop", Default = false })
k6:AddDropdown("CoinShopMode", { Text = "Mode", Values = { "Buy", "Sell" }, Default = 1 })
k6:AddSlider("CoinShopAmount", { Text = "Amount", Default = 1, Min = 1, Max = 1000, Rounding = 0 })
k6:AddSlider("CoinShopDelay", { Text = "Shop Delay", Default = 1, Min = 0.2, Max = 10, Rounding = 1 })
k6:AddButton({ Text = "Coin Shop Once", Func = onCoinShopOnce })
k6:AddButton({ Text = "Teleport to Coin Shop", Func = onTeleportToCoinShop })
k2 = la.Station:AddRightGroupbox("Ruined Sell", "banknote")
k2:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
k2:AddDropdown("SellItemsList", { Text = "Items", Values = jU, Default = jU, Multi = true, AllowNull = true })
k2:AddDropdown("SellAmount", { Text = "Sell Amount", Values = { "x1", "x10", "x100" }, Default = 1 })
k2:AddSlider("SellDelay", { Text = "Sell Delay", Default = 2, Min = 0.5, Max = 15, Rounding = 1 })
k2:AddButton({ Text = "Sell Once", Func = onSellOnce })
k1 = la.Station:AddRightGroupbox("Ruined Craft", "hammer")
k1:AddToggle("AutoCraft", { Text = "Auto Craft", Default = false })
k1:AddDropdown("CraftRecipesList", { Text = "Recipes", Values = kO, Default = {}, Multi = true, AllowNull = true })
k1:AddDropdown("CraftAmount", { Text = "Craft Amount", Values = { "x1", "x10", "x100" }, Default = 1 })
k1:AddSlider("CraftDelay", { Text = "Craft Delay", Default = 2, Min = 0.5, Max = 15, Rounding = 1 })
k1:AddButton({ Text = "Craft Once", Func = onCraftOnce })
k0 = la.Station:AddRightGroupbox("Ruined Upgrades", "trending-up")
k0:AddToggle("AutoRuinedUpgrade", { Text = "Auto Ruined Upgrade", Default = false })
k0:AddDropdown("RuinedUpgradesList", { Text = "Upgrades", Values = kv, Default = kv, Multi = true, AllowNull = true })
k0:AddSlider("RuinedUpgradeDelay", { Text = "Upgrade Delay", Default = 2, Min = 0.5, Max = 15, Rounding = 1 })
k0:AddButton({ Text = "Ruined Upgrade Once", Func = onRuinedUpgradeOnce })
k_ = la.Station:AddLeftGroupbox("Misc", "wrench")
k_:AddDropdown("UseItemName", { Text = "Item", Values = kW, Default = 1 })
k_:AddSlider("UseItemAmount", { Text = "Use Amount", Default = 1, Min = 1, Max = 50, Rounding = 0 })
k_:AddButton({ Text = "Use Item", Func = onUseItem })
k_:AddButton({ Text = "Spawn Skateboard", Func = onSpawnSkateboard })
k_:AddInput("RedeemCodeInput", { Text = "Code", Default = "", Finished = true, AllowEmpty = true })
k_:AddButton({ Text = "Redeem Code", Func = onRedeemCode })
kZ = la.Station:AddRightGroupbox("Teleports", "map")
kZ:AddDropdown("TeleportTarget", { Text = "Location", Values = kU, Default = 1 })
kZ:AddButton({ Text = "Teleport", Func = onTeleport })
local MovementGroup = la.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
lh = la.Player:AddRightGroupbox("Fly", "feather")
lh:AddToggle("Fly", { Text = "Fly", Default = false })
lh:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
lg = la.Settings:AddLeftGroupbox("Menu")
lg:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
j9.ToggleKeybind = Options.MenuKeybind
lg:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
lg:AddButton("Unload", onUnload)
kE = tick()
kA = tick()
pcall(function()
    for i, v in ipairs(getconnections(kz.Idled)) do
        local oc = v
        pcall(function()
            oc:Disable()
        end)
    end
end)
ko = fn196
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
jV = function(e_)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not e_)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not e_
        end
    end)
    if not e_ then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(kz, "GameplayPaused", false)
        else
            kz.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fn947)
Toggles.SkipCutscenes:OnChanged(fn496)
Toggles.AutoEnchant:OnChanged(fn999)
Toggles.AutoCoinGacha:OnChanged(fn140)
Toggles.AutoAccessoryGacha:OnChanged(fn815)
kx(true)
Toggles.Fly:OnChanged(fn519)
Toggles.WalkSpeedEnabled:OnChanged(fn213)
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera2 = Workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
task.spawn(flipDelayLoop)
task.spawn(upgradeDelayLoop)
task.spawn(enchantDelayLoop)
task.spawn(coinGachaDelayLoop)
task.spawn(accessoryGachaDelayLoop)
task.spawn(ticketBuyDelayLoop)
task.spawn(spinDelayLoop)
task.spawn(coinShopDelayLoop)
task.spawn(sellDelayLoop)
task.spawn(craftDelayLoop)
task.spawn(ruinedUpgradeDelayLoop)
task.spawn(antiAfkLoop)
task.spawn(antiGameplayPauseLoop)
kY:SetLibrary(j9)
kY:SetFolder("TempoHub")
kY:SaveDefault("Monochrome")
kY:ApplyToTab(la.Settings)
kY:LoadDefault()
SaveManager:SetLibrary(j9)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/REHeadsPlease")
le = SaveManager:BuildConfigSection(la.Settings)
kD = fn92
kj = fn935
j8 = fn133
kB = function(gF)
    local p_
    p_ = nil
    local p0 = type(gF) ~= "table"
    local p4 = if p0 then 1 else 0
    local p2 = 3409 * p4 + 1260 * (1 - p4)
    local p3 = 1031 * p4 + 2317 * (1 - p4)
    if not ((p2 * 3434 + p3 * 123 + p2 * p3) % 16777213 == 15347998) then
        p0 = type(gF.idx) ~= "string"
    end
    if not p0 then
        p0 = type(gF.type) ~= "string"
    end
    if not p0 then
        p0 = SaveManager.Ignore[gF.idx]
    end
    if p0 then
        return false
    end
    p_ = kD(gF.type, gF.idx)
    if not p_ then
        return false
    end
    local p0_1 = pcall(function()
        if gF.type == "Input" then
            if type(gF.text) ~= "string" then
                return
            end
            p_:SetValue(gF.text)
        elseif gF.type == "ColorPicker" then
            p_:SetValueRGB(Color3.fromHex(gF.value), gF.transparency)
        elseif gF.type == "KeyPicker" then
            p_:SetValue({ gF.key, gF.mode, gF.modifiers })
            if gF.mode == "Toggle" and gF.toggled ~= nil then
                p_.Toggled = gF.toggled
                p_:Update()
            end
        else
            p_:SetValue(gF.value)
        end
    end)
    return p0_1
end
le:AddDivider()
le:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
le:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
le:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
j9:OnUnload(fn329)
end)(...)

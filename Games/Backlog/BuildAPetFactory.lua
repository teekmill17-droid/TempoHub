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
getgenv().TempoHoodSubtitle = "BUILD A PET FACTORY"
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
local hb
local hT
local RebirthMath
local hh
local hG
local hn
local g4
local hM
local Toggles
local ha
local Workspace
local hz
local hg
local connection
local PlacementUtil
local hm
local Library
local hs
local g9
local hR
local hy
local hf
local hE
local hl
local Rebirth
local hK
local hr
local g8
local hx
local PurchaseBuilding
local hW
local hD
local Options
local Players
local hJ
local hq
local CollectCash
local ItemConfig
local Label
local hd
local RequestClearPlot
local connection2
local hj
local RebirthConfig
local g6
local hO
local hv
local hc
local hU
local hB
local hi
local hH
local ho
local g5
local VirtualUser
local hu
local function onInputBegan()
    hR = tick()
end
local function fn7()
    hi = true
    connection:Disconnect()
    connection2:Disconnect()
end
local function fn13()
    return hr.Replica
end
local function fn15(ba)
    local jQ = ItemConfig[ba]
    if not jQ then
        return math.huge
    elseif jQ.RequiredRebirths then
        return jQ.RequiredRebirths
    else
        if jQ.Rarity and RebirthConfig.Rarity[jQ.Rarity] then
            return RebirthConfig.Rarity[jQ.Rarity]
        end
        return 0
    end
end
local function fn25()
    local jY_1
    local jX_1
    if identifyexecutor then
        jY_1, jX_1 = identifyexecutor()
        local jZ = jY_1 ~= ""
        local j_ = type(jY_1) == "string" and jZ
        if j_ then
            local jZ_1 = type(jX_1) == "string" and jX_1 ~= "" and jY_1 .. " " .. jX_1
            hf = jZ_1 or jY_1
        end
    end
end
local function fn48(by, bz)
    if setclipboard then
        setclipboard(by)
    elseif toclipboard then
        toclipboard(by)
    end
    Library:Notify(bz)
end
local function fn65(bO, bP, bQ)
    return string.format("<b>%s</b> %s %s", bO, g9("-", "#5a6070"), g9(bP, bQ))
end
local function onRefreshPlayers()
    Options.StealTarget:SetValues(hc())
end
local function fn86(a2)
    local jK = hb()
    if not jK then
        return 0
    end
    return jK.BuildingStock[a2] or 0
end
local function worker()
    local j5_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local j4 = math.floor(os.clock() - g6)
        if j4 < 60 then
            j5_1 = j4 .. "s"
        elseif j4 < 3600 then
            j5_1 = string.format("%dm %ds", math.floor((j4) / (60)), j4 % 60)
        else
            j5_1 = string.format("%dh %dm", math.floor((j4) / (3600)), math.floor((j4 % 3600) / (60)))
        end
        hG:SetText(hW("Session time", j5_1, hn))
    end
end
local function onUnload()
    Library:Unload()
end
local function fn107(bg)
    if hs(bg) > 0 then
        return true
    end
    local jT = ItemConfig[bg]
    if not jT or jT.Cost == nil then
        return false
    end
    local jT_1 = hb()
    local jT_2 = jT_1 and jT_1.Rebirths or 0
    return jT_2 >= g5(bg)
end
local function autoBuyLoop()
    while not Library.Unloaded do
        local j8 = Options.BuyInterval and Options.BuyInterval.Value or 1
        if Toggles.AutoBuy.Value then
            local j8_1 = hb()
            if j8_1 then
                local Value3 = Toggles.BuyDecorations.Value
                local Value2 = Toggles.BuyAffordableOnly.Value
                local Value = Options.BuyFilter.Value
                local kc = false
                for k in pairs(Value) do
                    kc = true
                    break
                end
                for k, v in pairs(j8_1.BuildingStock) do
                    if Library.Unloaded or not Toggles.AutoBuy.Value then
                        break
                    end
                    if v and v > 0 and ItemConfig[k] then
                        local j8_4 = kc
                        local kd = false
                        if j8_4 then
                            j8_4 = not Value[k]
                        end
                        if j8_4 then
                            kd = true
                        end
                        local j8_5 = not kd
                        if j8_5 ~= false then
                            j8_5 = not Value3
                        end
                        if j8_5 then
                            j8_5 = hz(k)
                        end
                        if j8_5 then
                            kd = true
                        end
                        local j8_6 = not kd
                        if j8_6 ~= false then
                            j8_6 = Value2
                        end
                        if j8_6 then
                            local j8_7 = g8(k)
                            local ke = j8_7
                            if ke then
                                local kf = hb().Cash or 0
                                ke = j8_7 > kf
                            end
                            if ke then
                                kd = true
                            end
                        end
                        if not kd then
                            PurchaseBuilding:FireServer(k)
                            task.wait(0.15)
                        end
                    end
                end
            end
        end
        task.wait(j8)
    end
end
local function onScanSelectedBase()
    local lr = ha()
    if lr then
        hg(lr)
        Library:Notify(string.format("Scanned %d buildings", #lr.Entries))
    end
end
local function fn124()
    local kT = {}
    for i, player in ipairs(Players:GetPlayers()) do
        if player ~= hD then
            table.insert(kT, player.Name)
        end
    end
    table.sort(kT)
    return kT
end
local function onCopyJoinScript_JobID()
    local b7 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, hB)
    hd(b7, "Copied join script to clipboard")
end
local function fn133()
    local Character = hD.Character
    local ks = Character and Character:FindFirstChild("HumanoidRootPart")
    return ks or nil
end
local function fn155()
    hd(hu, "Copied Discord invite to clipboard")
end
local function fn183()
    local kv = hT(hD)
    if not kv then
        return
    end
    local Placements = kv:FindFirstChild("Placements")
    if not Placements then
        return
    end
    local kv_1 = Toggles.CollectTeleport and Toggles.CollectTeleport.Value
    for i, child in Placements:GetChildren() do
        if Library.Unloaded or not Toggles.AutoCollect.Value then
            break
        end
        local ProximityPrompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
        if ProximityPrompt and ProximityPrompt.Enabled then
            local ActionText = ProximityPrompt.ActionText
            if ActionText == "Collect" or ActionText == "Claim" then
                if kv_1 then
                    local kw_3 = hH()
                    if kw_3 then
                        local Parent = ProximityPrompt.Parent
                        local kz_1 = Parent and Parent:IsA("BasePart") and Parent.CFrame
                        local ky_2 = kz_1
                        local kJ = if ky_2 then 1 else 0
                        local kH = 1954 * kJ + 554 * (1 - kJ)
                        local kI = 1927 * kJ + 2595 * (1 - kJ)
                        if not ((kH * 1721 + kI * 647 + kH * kI) % 16777213 == 8374961) then
                            ky_2 = child:GetPivot()
                        end
                        local kz_2 = ky_2
                        kw_3.CFrame = kz_2 + Vector3.new(0, 4, 0)
                        task.wait(0.08)
                    end
                end
                pcall(fireproximityprompt, ProximityPrompt)
            end
        end
    end
end
local function autoCollectLoop()
    while not Library.Unloaded do
        local kK_1 = Options.SellInterval and Options.SellInterval.Value or 1
        if Toggles.AutoCollect.Value then
            hl()
        end
        if Toggles.AutoSell.Value then
            CollectCash:FireServer()
        end
        task.wait(kK_1)
    end
end
local function fn186(a6)
    local jN = hb()
    if not jN then
        return 0
    end
    return jN.Inventory[a6] or 0
end
local function fn208()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    hO = tick()
end
local function fn235(ao)
    return hq[hK(ao)]
end
local function fn246(as)
    local at = as % 360
    return math.floor(at / 90 + 0.5) * 90 % 360
end
local function fn278(dq)
    local k7_1
    local k6_1
    local k4_1
    local k3_1
    if not dq then
        Label:SetText("Scan a player to see their base materials.")
        return
    end
    local k0 = {}
    for k in pairs(dq.Materials) do
        table.insert(k0, k)
    end
    table.sort(k0)
    local k1 = {}
    k3_1, k4_1 = 0, 0
    for i, v in ipairs(k0) do
        local k5 = dq.Materials[v]
        k3_1 = k3_1 + k5
        if hE(v) then
            k4_1 = k4_1 + 1
            k6_1 = g9("[OWNED]", hy)
            k7_1 = hv
        else
            local k8 = g5(v)
            local k9_1 = ItemConfig[v] and ItemConfig[v].Cost == nil and "gem/limited"
            if not k9_1 then
                k9_1 = "needs " .. k8 .. " rebirth" .. (k8 == 1 and "" or "s")
            end
            local k8_1 = k9_1
            k6_1 = g9("[LOCKED " .. k8_1 .. "]", "#ff6b6b")
            k7_1 = hh
        end
        table.insert(k1, k6_1 .. " " .. g9(v, k7_1) .. " " .. g9("x" .. k5, hn))
    end
    table.insert(k1, 1, g9(string.format("Total buildings: %d  (%d/%d types owned)", k3_1, k4_1, #k0), hn))
    if dq.Unknown > 0 then
        table.insert(k1, g9("Unidentified: " .. dq.Unknown, hh))
    end
    Label:SetText(table.concat(k1, "\n"))
end
local function onClearMyBase()
    RequestClearPlot:FireServer()
    Library:Notify("Requested plot clear")
end
local function onInputChanged(eE)
    local UserInputType = eE.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        hR = tick()
    end
end
local function onStop()
    hi = true
end
local function fn302(F)
    local Plots = Workspace:FindFirstChild("Plots")
    if not Plots then
        return nil, nil
    end
    local attr = F:GetAttribute("PlotName")
    local iN = attr and Plots:FindFirstChild(attr)
    local iM_1 = iN
    if not iM_1 then
        local iN_1 = "_" .. F.Name
        for i, child in Plots:GetChildren() do
            local Placements = child:FindFirstChild("Placements")
            if Placements then
                for i, child2 in Placements:GetChildren() do
                    if string.sub(child2.Name, -#iN_1) == iN_1 then
                        iM_1 = child
                        break
                    end
                end
            end
            if iM_1 then
                break
            end
        end
    end
    if not iM_1 then
        return nil, nil
    end
    return iM_1, iM_1:FindFirstChild("Platform")
end
local function fn364(dS)
    local lt_3
    if hs(dS) > 0 then
        return true
    elseif not Toggles.StealBuyMissing.Value then
        return false
    elseif hJ(dS) <= 0 then
        return false
    elseif Toggles.StealAffordableOnly.Value then
        local lt_1 = g8(dS)
        local lu = hb()
        if lt_1 and lu and lt_1 > (lu.Cash or 0) then
            return false
        end
        PurchaseBuilding:FireServer(dS)
        local lt_2 = os.clock() + 1
        while true do
            if not (os.clock() < lt_3) then
                return hs(dS) > 0
            end
            if hs(dS) > 0 then
                break
            end
            task.wait(0.05)
        end
        return true
    else
        PurchaseBuilding:FireServer(dS)
        lt_3 = os.clock() + 1
        while true do
            if not (os.clock() < lt_3) then
                return hs(dS) > 0
            end
            if hs(dS) > 0 then
                break
            end
            task.wait(0.05)
        end
        return true
    end
end
local function fn369(bF)
    local DiscordGroup = bF:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = hU })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = hU })
end
local function fn380(bL, bM)
    return string.format('<font color="%s">%s</font>', bM, bL)
end
local function fn381()
    local Value = Options.StealTarget.Value
    local ln_1
    local lp = not Value or Value == ""
    local lp_1
    if lp then
        Library:Notify("Select a player first")
        return nil
    end
    local lo_1 = Players:FindFirstChild(Value)
    if not lo_1 then
        Library:Notify("That player left the game")
        return nil
    end
    lp_1, ln_1 = hx(lo_1)
    if not lp_1 then
        local lo_2 = ln_1 or "Failed to read that base"
        Library:Notify(lo_2)
        return nil
    end
    return lp_1
end
local function autoRebirthLoop()
    while not Library.Unloaded do
        local kO = Options.RebirthInterval and Options.RebirthInterval.Value or 3
        if Toggles.AutoRebirth.Value then
            local kO_1 = hb()
            if kO_1 then
                local kP = kO_1.Rebirths or 0
                local kQ = RebirthMath:GetCost(kP)
                if kQ and (kO_1.Cash or 0) >= kQ then
                    Rebirth:FireServer()
                end
            end
        end
        task.wait(kO)
    end
end
local function fn488(aU)
    local jE = ItemConfig[aU]
    return jE and jE.Type == "Decoration"
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local l5 = tick() - hR
            local l6 = tick() - hO
            if l5 >= 300 and l6 >= 60 then
                pcall(ho)
            else
                if l5 < 300 and l6 >= 300 then
                    pcall(ho)
                end
            end
        end
    end
end
local function fn509(av)
    local jw_1
    local jp_1
    local jo_1, jo_2
    jo_1, jp_1 = hT(av)
    local jq = not jp_1
    local jq_3
    local jr = not jo_1 or jq
    local jr_1
    if jr then
        return nil, "Could not find that player's plot"
    end
    local Placements = jo_1:FindFirstChild("Placements")
    if not Placements then
        return nil, "That plot has no placements"
    end
    jo_2, jr_1 = jp_1.CFrame:ToOrientation()
    local jo_3 = {}
    local js = {}
    local jt = 0
    for i, child in Placements:GetChildren() do
        if not string.find(child.Name, "_Tutorial") then
            local attr = child:GetAttribute("BaseGrid")
            if attr then
                local ju = g4(child)
                if ju then
                    local jv = PlacementUtil.GridToNormalizedGrid(attr, jp_1)
                    jq_3, jw_1 = child:GetPivot():ToOrientation()
                    js[#js + 1] = { ModelName = ju, NormalizedGrid = jv, Rotation = hM(math.deg(jw_1 - jr_1)) }
                    local jq_4 = jo_3[ju] or 0
                    jo_3[ju] = jq_4 + 1
                else
                    jt = jt + 1
                end
            end
        end
    end
    return { Entries = js, Materials = jo_3, Unknown = jt }
end
local function fn510(aY)
    local jH = ItemConfig[aY]
    return jH and jH.Cost or nil
end
local function fn516()
    local iI = hj()
    return iI and iI.Data or nil
end
local function onRscripts()
    hd(hm, "Copied Rscripts profile to clipboard")
end
Players = nil
Rebirth = nil
g4 = nil
g5 = nil
g6 = nil
CollectCash = nil
g8 = nil
g9 = nil
ha = nil
hb = nil
hc = nil
hd = nil
PurchaseBuilding = nil
hf = nil
hg = nil
hh = nil
hi = nil
hj = nil
Options = nil
hl = nil
hm = nil
hn = nil
ho = nil
hq = nil
hr = nil
hs = nil
Toggles = nil
hu = nil
hv = nil
Label = nil
hx = nil
hy = nil
hz = nil
RebirthMath = nil
hB = nil
connection2 = nil
hD = nil
hE = nil
PlacementUtil = nil
hG = nil
hH = nil
RebirthConfig = nil
hJ = nil
hK = nil
Library = nil
hM = nil
VirtualUser = nil
hO = nil
local g3, hp
ItemConfig = nil
hR = nil
Workspace = nil
hT = nil
hU = nil
RequestClearPlot = nil
hW = nil
connection = nil
local hQ, PlacePlacement
local h8_1
local ii_1
local ib_1
local h7_1
local h2_1
local h__1, h__3
local Events
Players, h__1, Workspace, VirtualUser, hD, h2_1, hu, hm, Events, PurchaseBuilding, CollectCash, Rebirth, PlacePlacement, RequestClearPlot, ItemConfig, RebirthConfig, PlacementUtil, RebirthMath, hr, hQ, hq, hj, hb, hT, hK = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
if (not hQ and PurchaseBuilding or not hT and false or (hQ or 34) and (h2_1 or not hT)) and (not hQ and false and hT or (not PurchaseBuilding and false or (hu or not hT))) and ((hu or hQ or hu and hT or (hQ and not PurchaseBuilding or (hT or false))) and ((h2_1 or not hT) and (false or hQ) and ("Build a Pet Factory" and (not PurchaseBuilding or h2_1)))) or not ((not hQ and PurchaseBuilding or not hT and false or (hQ or 34) and (h2_1 or not hT)) and (not hQ and false and hT or (not PurchaseBuilding and false or (hu or not hT))) and ((hu or hQ or hu and hT or (hQ and not PurchaseBuilding or (hT or false))) and ((h2_1 or not hT) and (false or hQ) and ("Build a Pet Factory" and (not PurchaseBuilding or h2_1))))) then
    h__1 = game:GetService("ReplicatedStorage")
else
    game:GetService("ReplicatedStorage")
end
Workspace = game:GetService("Workspace")
VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
hD = Players.LocalPlayer
local h2_2 = "Build a Pet Factory"
hu = "https://discord.gg/K7Qxnxkk46"
hm = "https://discord.gg/K7Qxnxkk46"
if ((CollectCash and not Players or (Players or PlacePlacement)) and (not hQ and not hQ or not Players and not Players) or (CollectCash or PlacePlacement or (CollectCash or PlacePlacement)) and ((not PlacePlacement or not PlacePlacement) and (hQ and not hQ))) and not ((CollectCash and not Players or (Players or PlacePlacement)) and (not hQ and not hQ or not Players and not Players) or (CollectCash or PlacePlacement or (CollectCash or PlacePlacement)) and ((not PlacePlacement or not PlacePlacement) and (hQ and not hQ))) then
    h__1 = Events:WaitForChild("Events")
else
    Events = h__1:WaitForChild("Events")
end
PurchaseBuilding = Events:WaitForChild("PurchaseBuilding")
CollectCash = Events:WaitForChild("CollectCash")
Rebirth = Events:WaitForChild("Rebirth")
PlacePlacement = Events:WaitForChild("PlacePlacement")
RequestClearPlot = Events:WaitForChild("RequestClearPlot")
ItemConfig = require(h__1.Configs.ItemConfig)
RebirthConfig = require(h__1.Configs.RebirthConfig)
PlacementUtil = require(h__1.Utilities.PlacementUtil)
RebirthMath = require(h__1.Utilities.RebirthMath)
local Placements = h__1.Assets.Placements
if (PurchaseBuilding or not hQ or not PurchaseBuilding and not hQ or (not hQ or PurchaseBuilding) and (hQ or not hQ)) and ((PurchaseBuilding or PurchaseBuilding) and (PurchaseBuilding and not PurchaseBuilding) or (PurchaseBuilding and PurchaseBuilding or (not hQ or PurchaseBuilding))) or not ((PurchaseBuilding or not hQ or not PurchaseBuilding and not hQ or (not hQ or PurchaseBuilding) and (hQ or not hQ)) and ((PurchaseBuilding or PurchaseBuilding) and (PurchaseBuilding and not PurchaseBuilding) or (PurchaseBuilding and PurchaseBuilding or (not hQ or PurchaseBuilding)))) then
    hr = require(hD.PlayerScripts.Client.Data)
    hj = fn13
else
    hD = require(hj.PlayerScripts.Client.Data)
    hr = fn13
end
hb = fn516
hT = fn302
hQ = { ArrowAttachments = true, TargetAttachment = true, SelectionBox = true }
hK = function(T)
    local i7
    i7 = {}
    for i, descendant in ipairs(T:GetDescendants()) do
        if hQ[descendant.Name] then
            i7[descendant] = true
        end
    end
    local function i8(Z)
        local i3 = Z
        while true do
            if not (i3 and i3 ~= T) then
                return hQ[Z.Name] == true
            end
            if i7[i3] then
                break
            end
            i3 = i3.Parent
        end
        return true
    end
    local i9 = {}
    for i, descendant in ipairs(T:GetDescendants()) do
        local ja = not i8(descendant) and descendant:IsA("BasePart")
        if ja then
            local Color = descendant.Color
            i9[#i9 + 1] = string.format("%d_%d_%d_%d_%.1f_%.1f_%.1f", math.floor(Color.R * 255), math.floor(Color.G * 255), math.floor(Color.B * 255), descendant.Material.Value, descendant.Size.X, descendant.Size.Y, descendant.Size.Z)
        end
    end
    table.sort(i9)
    return table.concat(i9, "|")
end
hq = {}
for i, child in ipairs(Placements:GetChildren()) do
    local hZ_2 = hK(child)
    if hq[hZ_2] == nil then
        hq[hZ_2] = child.Name
    end
end
g4, hM, hx = nil, nil, nil
g4 = fn235
hM = fn246
hx = fn509
local h0 = {}
for k, v in pairs(ItemConfig) do
    local hZ_3 = type(v) == "table" and v.Type
    if hZ_3 then
        table.insert(h0, k)
    end
end
Library, Toggles, Options, hz, g8, hJ, hs, g5, hE, hd, hU = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
table.sort(h0)
hz = fn488
g8 = fn510
hJ = fn86
hs = fn186
g5 = fn15
hE = fn107
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
local h__2 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = "https://discord.gg/K7Qxnxkk46 | Build a Pet Factory",
    Icon = 18657887261,
    NotifySide = "Right",
    ShowCustomCursor = false
})
Toggles = Library.Toggles
Options = Library.Options
local h4 = {
    Info = h__2:AddTab("Info", "info"),
    Main = h__2:AddTab("Main", "gavel"),
    Steal = h__2:AddTab("Steal Bases", "copy"),
    Settings = h__2:AddTab("Settings", "settings")
}
hd = fn48
hU = fn155
for k, v in h4 do
    fn369(v)
end
hy, hv, hn, hh, hf, h__3, h8_1, hG, hB, h7_1, g9, hW = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local hZ_4 = 47
repeat
    local h1_2 = (hZ_4 * 7 + 6) % 9 + 1
    if h1_2 <= 5 then
        if h1_2 <= 3 then
            if h1_2 <= 2 then
                if h1_2 <= 1 then
                    local h9_1 = (vector.create((hZ_4 * 3 + 2) % 11 + 1, (hZ_4 * 5 + 2) % 13 + 1, (hZ_4 * 13 + 12) % 17 + 1))
                    local ia_1 = (vector.create((hZ_4 * 6 + 9) % 11 + 1, (hZ_4 * 1 + 5) % 13 + 1, (hZ_4 * 13 + 16) % 17 + 1))
                    local m4 = vector.dot(h9_1, ia_1)
                    if m4 * m4 <= vector.dot(h9_1, h9_1) * vector.dot(ia_1, ia_1) then
                        hB = tostring(game.JobId)
                    else
                        hf = tostring(game.JobId)
                    end
                    hZ_4 = (hZ_4 + 49) % 72
                else
                    local h9_2 = (vector.create((hZ_4 * 1 + 5) % 11 + 1, (hZ_4 * 8 + 3) % 13 + 1, (hZ_4 * 2 + 1) % 17 + 1))
                    local m7 = vector.floor(h9_2) + vector.ceil(h9_2 * -1)
                    if vector.dot(m7, m7) == 2 then
                        hB = #h7_1 > 18
                    else
                        h7_1 = #hB > 18
                    end
                    hZ_4 = (hZ_4 + 58) % 72
                end
            else
                local mE = bit32.rrotate(bit32.bxor(bit32.lrotate(hZ_4, 18), string.byte(tostring(hG))), 21)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(mE, 968830125), 1663593696), (bit32.bxor(bit32.band(mE, 3326137170), 2720946472))), 1663593696), 2720946472) ~= mE then
                    h7_1 = fn380
                else
                    g9 = fn380
                end
                hZ_4 = (hZ_4 + 31) % 72
            end
        elseif h1_2 <= 4 then
            if (hZ_4 * 1 + 6) * 5 % 4 == ((hZ_4 * 1 + 6) * 5 + 15) % 4 then
                h8_1 = fn65
            else
                hW = fn65
            end
            hZ_4 = (hZ_4 + 58) % 72
        else
            if hZ_4 * 17630329 + 3 + 3 >= hZ_4 * 17630329 + 3 + 3 + 4 then
                hB = "#7fd47f"
            else
                hy = "#7fd47f"
            end
            hZ_4 = (hZ_4 + 13) % 72
        end
    elseif h1_2 <= 7 then
        if h1_2 <= 6 then
            if (hZ_4 * 3 + 8) * 9 % 4 == ((hZ_4 * 3 + 8) * 9 + 6) % 4 then
                g9 = "#6ec1ff"
            else
                hv = "#6ec1ff"
            end
            hZ_4 = (hZ_4 + 58) % 72
        else
            if hn and h7_1 and (hn or hn) and (h8_1 or h7_1 or not hn and not h8_1) or not (hn and h7_1 and (hn or hn) and (h8_1 or h7_1 or not hn and not h8_1)) then
                hn = "#e8a34d"
            else
                hf = "#e8a34d"
            end
            hZ_4 = (hZ_4 + 31) % 72
        end
    elseif h1_2 <= 8 then
        local h1_3 = { "qlzmeli", "fnzm", "wvcifzsr", "gft", "eawycajjkhg", "jjrpv", "btuqnklwrxg", "ebur" }
        local mY = hZ_4
        local h9_3 = h1_3[mY % 8 + 1]
        if h9_3:len() <= h9_3:reverse():rep(mY % 3 + 2):len() then
            hh = "#8b93a3"
        else
            hG = "#8b93a3"
        end
        hZ_4 = (hZ_4 + 58) % 72
    else
        local h1_4 = { "upv", "lvjtcnj", "eugw", "iitfwcjtub", "qcnfnc", "smfhn", "cfgwiapwvjn" }
        local m5 = hZ_4
        local h9_4 = h1_4[m5 % 7 + 1]
        if h9_4:len() <= h9_4:gsub("(.)", "%1%1", m5 % 3 % 2 + 1):len() then
            hf = "Unknown"
            pcall(fn25)
            h__3 = h4.Info:AddLeftGroupbox("Account", "circle-user")
            h__3:AddLabel(hW("User", hD.Name, hy), true)
            h__3:AddLabel(hW("Status", "Keyless", hy), true)
            h__3:AddLabel(hW("Executor", hf, hy), true)
            h8_1 = h4.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            h8_1:AddLabel(g9(h2_2 .. " [" .. tostring(game.PlaceId) .. "]", hv), true)
            h8_1:AddLabel(hW("Place ID", tostring(game.PlaceId), hv), true)
            hG = h8_1:AddLabel(hW("Session time", "0s", hn), true)
        else
            hD = "Unknown"
            pcall(fn25)
            hy = hW.Info:AddLeftGroupbox("Account", "circle-user")
            hy:AddLabel(h__3("User", nil, h8_1), true)
            hy:AddLabel(h__3("Status", "Keyless", h8_1), true)
            hy:AddLabel(h__3("Executor", hD, h8_1), true)
            hv = hW.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            hv:AddLabel(hG(g9 .. " [" .. tostring(game.PlaceId) .. "]", hf), true)
            hv:AddLabel(h__3("Place ID", tostring(game.PlaceId), hf), true)
            hn = hv:AddLabel(h__3("Session time", "0s", h4), true)
        end
        hZ_4 = (hZ_4 + 22) % 72
    end
until (hZ_4 * 5 + 68) % 72 == 33
if h7_1 then
    local hZ_5 = 2
    repeat
        if hZ_5 and hZ_5 or not hZ_5 and hZ_5 or not hZ_5 and hZ_5 and (not hZ_5 or not hZ_5) or not (hZ_5 and hZ_5 or not hZ_5 and hZ_5 or not hZ_5 and hZ_5 and (not hZ_5 or not hZ_5)) then
            h7_1 = string.sub(hB, 1, 18) .. "..."
        else
            hB = string.sub(h7_1, 1, 18) .. "..."
        end
        hZ_5 = (hZ_5 + 7) % 8
    until (hZ_5 * 5 + 3) % 8 == 0
end
local hZ_6 = h7_1 or hB
ib_1, g6, ii_1, Label, hp, hi, hR, hO, connection, connection2, hH, hl, hc, hg, ha, g3, ho = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if ((g6 and not g6 or (ii_1 or not ii_1)) and (not g6 or g6 or (g6 or not ii_1)) or (ii_1 and not g6 or (g6 or g6) or (g6 or g6) and (not ii_1 or not g6))) and (ii_1 and ii_1 and (g6 and g6) and ((not ii_1 or g6) and (not g6 and not g6)) or (g6 and g6 and (not ii_1 and not ii_1) or (not g6 or ii_1) and (not g6 or not g6))) and not (((g6 and not g6 or (ii_1 or not ii_1)) and (not g6 or g6 or (g6 or not ii_1)) or (ii_1 and not g6 or (g6 or g6) or (g6 or g6) and (not ii_1 or not g6))) and (ii_1 and ii_1 and (g6 and g6) and ((not ii_1 or g6) and (not g6 and not g6)) or (g6 and g6 and (not ii_1 and not ii_1) or (not g6 or ii_1) and (not g6 or not g6)))) then
    local hZ_7 = hW
    hh:AddLabel(ib_1("Server", hZ_7, g6), true)
    hh:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
    os.clock()
else
    h8_1:AddLabel(hW("Server", hZ_6, hh), true)
    h8_1:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
    g6 = os.clock()
end
task.spawn(worker)
local ScriptsGroup = h4.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(g9("Included in this hub", hh), true)
ScriptsGroup:AddLabel(g9(h2_2, hv), true)
local FeaturesGroup = h4.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(g9("Auto Buy Shop", hv), true)
FeaturesGroup:AddLabel(g9("Auto Collect Money", hy), true)
FeaturesGroup:AddLabel(g9("Auto Press to Sell", hn), true)
FeaturesGroup:AddLabel(g9("Auto Rebirth", hv), true)
FeaturesGroup:AddLabel(g9("Steal Bases", hh), true)
local SocialsGroup = h4.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = hU })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local h__4 = h4.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
h__4:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
h__4:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
h__4:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
h__4:AddButton({ Text = "Copy Discord Invite", Func = hU })
local FaqGroup = h4.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutoBuyShopGroup = h4.Main:AddLeftGroupbox("Auto Buy Shop", "shopping-cart")
AutoBuyShopGroup:AddToggle("AutoBuy", { Text = "Auto Buy Shop", Default = false })
AutoBuyShopGroup:AddToggle("BuyDecorations", { Text = "Include Decorations", Default = false })
AutoBuyShopGroup:AddToggle("BuyAffordableOnly", { Text = "Only Buy Affordable", Default = true })
AutoBuyShopGroup:AddDropdown("BuyFilter", {
    Values = h0,
    Default = {},
    Multi = true,
    AllowNull = true,
    Searchable = true,
    Text = "Buildings (empty = all in stock)"
})
AutoBuyShopGroup:AddSlider("BuyInterval", { Text = "Buy Interval (s)", Default = 1, Min = 0.2, Max = 5, Rounding = 1, Suffix = "s" })
local MoneyGroup = h4.Main:AddLeftGroupbox("Money", "banknote")
MoneyGroup:AddToggle("AutoCollect", { Text = "Auto Collect Money", Default = false })
MoneyGroup:AddToggle("CollectTeleport", { Text = "Teleport To Collector", Default = true })
MoneyGroup:AddToggle("AutoSell", { Text = "Auto Press to Sell", Default = false })
MoneyGroup:AddSlider("SellInterval", { Text = "Collect / Sell Interval (s)", Default = 1, Min = 1, Max = 10, Rounding = 1, Suffix = "s" })
local RebirthGroup = h4.Main:AddRightGroupbox("Rebirth", "rotate-ccw")
RebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
RebirthGroup:AddSlider("RebirthInterval", { Text = "Rebirth Interval (s)", Default = 3, Min = 1, Max = 30, Rounding = 1, Suffix = "s" })
task.spawn(autoBuyLoop)
hH = fn133
hl = fn183
task.spawn(autoCollectLoop)
task.spawn(autoRebirthLoop)
local TargetGroup = h4.Steal:AddLeftGroupbox("Target", "user-round")
hc = fn124
TargetGroup:AddDropdown("StealTarget", { Values = hc(), Default = nil, AllowNull = true, Searchable = true, Text = "Player" })
TargetGroup:AddButton({ Text = "Refresh Players", Func = onRefreshPlayers })
TargetGroup:AddToggle("StealClearFirst", { Text = "Clear My Base First", Default = true })
TargetGroup:AddToggle("StealBuyMissing", { Text = "Buy Missing Buildings", Default = true })
TargetGroup:AddToggle("StealAffordableOnly", { Text = "Only Buy Affordable", Default = true })
TargetGroup:AddSlider("StealDelay", { Text = "Place Delay (s)", Default = 0.15, Min = 0.05, Max = 1, Rounding = 2, Suffix = "s" })
local MaterialsGroup = h4.Steal:AddRightGroupbox("Materials", "boxes")
Label = MaterialsGroup:AddLabel("Scan a player to see their base materials.", true)
hp = false
hi = false
hg = fn278
ha = fn381
local ActionsGroup = h4.Steal:AddLeftGroupbox("Actions", "wand-sparkles")
ActionsGroup:AddButton({ Text = "Scan Selected Base", Func = onScanSelectedBase })
g3 = fn364
local function onCopyBase1_1()
    local lK, lL
    local lM_1
    if hp then
        Library:Notify("Already copying a base")
        return
    end
    lL = ha()
    if not lL then
        return
    end
    lM_1, lK = hT(hD)
    if not lK then
        Library:Notify("Could not find your own plot")
        return
    end
    hp = true
    hi = false
    hg(lL)
    task.spawn(function()
        local lz_1
        local ly_1
        if Toggles.StealClearFirst.Value then
            RequestClearPlot:FireServer()
            task.wait(1)
        end
        lz_1, ly_1 = 0, 0
        local Value = Options.StealDelay.Value
        for i, v in ipairs(lL.Entries) do
            if hi or Library.Unloaded then
                break
            end
            if g3(v.ModelName) then
                local lB_1 = PlacementUtil.NormalizedGridToGrid(v.NormalizedGrid, lK)
                local lC = PlacementUtil.GridToWorld(lB_1)
                PlacePlacement:FireServer(v.ModelName, lC, v.Rotation)
                lz_1 = lz_1 + 1
            else
                ly_1 = ly_1 + 1
            end
            task.wait(Value)
        end
        hp = false
        if hi then
            Library:Notify(string.format("Stopped. Placed %d, missing %d", lz_1, ly_1))
        else
            Library:Notify(string.format("Done. Placed %d, missing %d", lz_1, ly_1))
        end
    end)
end
ActionsGroup:AddButton({ Text = "Copy Base 1:1", Func = onCopyBase1_1 })
ActionsGroup:AddButton({ Text = "Stop", Func = onStop })
ActionsGroup:AddButton({ Text = "Clear My Base", Func = onClearMyBase })
local MenuGroup = h4.Settings:AddLeftGroupbox("Menu", "menu")
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
hR = tick()
hO = tick()
pcall(function()
    for i, v in ipairs(getconnections(hD.Idled)) do
        local lX = v
        pcall(function()
            lX:Disable()
        end)
    end
end)
ho = fn208
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
task.spawn(antiAfkLoop)
Library:OnUnload(fn7)
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
SaveManager:SetFolder("TempoHub/BuildAPetFactory")
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SaveDefault("Mint")
ThemeManager:ApplyToTab(h4.Settings)
ThemeManager:LoadDefault()
SaveManager:BuildConfigSection(h4.Settings)
SaveManager:LoadAutoloadConfig()
Library:Notify("Build a Pet Factory loaded")
end)(...)

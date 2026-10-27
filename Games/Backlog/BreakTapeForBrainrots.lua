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
getgenv().TempoHoodSubtitle = "BREAK TAPE FOR BRAINROTS"
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
local iv
local jc
local iU
local iB
local ih
local i_
local iH
local io
local i5
local iN
local Label
local jb
local iT
local iA
local ig
local iZ
local iG
local PurchasePower
local i4
local connection2
local it
local Workspace
local iz
local BuyTool
local iY
local iF
local il
local i3
local iL
local is
local EquipTool
local iR
local iy
local id
local RequestRebirth
local iE
local ik
local i2
local iK
local ir
local Options
local iQ
local ix
local je
local connection
local iW
local iD
local ij
local RequestFloorPurchase
local iJ
local iq
local i7
local iP
local iw
local jd
local Toggles
local iV
local iC
local PurchaseSpeed
local i0
local iI
local ip
local RequestSlotUpgrade
local iO
local function fn2(by, bz)
    local k6_1
    local k5_1
    k5_1, k6_1 = by, 0
    local la = 1
    while la <= bz do
        k6_1 = k6_1 + 1.75 ^ math.max(0, k5_1 - 20) * 200
        k5_1 = k5_1 + 1
        la += 1
    end
    return math.floor(k6_1)
end
local function fn6(aX, aY)
    if not iC(aX) then
        return true
    end
    return ij(aX)[tostring(aY)] == true
end
local function onInputBegan()
    jb = tick()
end
local function fn54()
    iG(iz, "Copied Discord invite to clipboard")
end
local function fn77()
    local mp = jc()
    if not mp then
        return false
    end
    local mq = false
    for i, child in ipairs(mp:GetChildren()) do
        if not not child.Name:match("^Floor%d+$") then
            local Slots = child:FindFirstChild("Slots")
            if not not Slots then
                for i, child in ipairs(Slots:GetChildren()) do
                    local mp_2 = tonumber(child:GetAttribute("StoredCash")) or 0
                    if not (mp_2 <= 0) then
                        local CollectButton = child:FindFirstChild("CollectButton")
                        local mr_1 = CollectButton and CollectButton:FindFirstChild("Touch")
                        if mr_1 then
                            iP(mr_1)
                            task.wait(0.08)
                            mq = true
                        end
                    end
                end
            end
        end
    end
    return mq
end
local function fn84()
    local leaderstats = iL:FindFirstChild("leaderstats")
    local kF = leaderstats and leaderstats:FindFirstChild("Money")
    local kE_1 = kF
    if kF then
        kF = kE_1.Value
    end
    return kF or 0
end
local function fn118(ad, ae)
    return ad.num < ae.num
end
local function worker3()
    while not ip.Unloaded do
        if id("AutoRebirth") then
            pcall(iE)
            task.wait(0.05)
        else
            task.wait(0.2)
        end
    end
end
local function fn157()
    return Workspace:FindFirstChild("Plot_" .. iL.Name)
end
local function fn178()
    local nW_1
    local nV_1
    if identifyexecutor then
        nW_1, nV_1 = identifyexecutor()
        local nX = nW_1 ~= ""
        local nY = type(nW_1) == "string" and nX
        if nY then
            local nX_1 = type(nV_1) == "string" and nV_1 ~= "" and nW_1 .. " " .. nV_1
            i3 = nX_1 or nW_1
        end
    end
end
local function onRscripts()
    iG(iw, "Copied Rscripts profile to clipboard")
end
local function fn206()
    local Bases = Workspace:FindFirstChild("Bases")
    if not Bases then
        return {}
    end
    local lO = i7()
    local lP = lO and lO.Position
    local lO_1 = {}
    for i, child in ipairs(Bases:GetChildren()) do
        local lN_1 = child:IsA("Model") and ir("CollectAreas", child.Name)
        if not not lN_1 then
            local Slots = child:FindFirstChild("Slots")
            if not not Slots then
                for i, child2 in ipairs(Slots:GetChildren()) do
                    local Spawn = child2:FindFirstChild("Spawn")
                    local lP_1 = Spawn and Spawn:FindFirstChild("SpawnedItem")
                    if not not lP_1 then
                        local lP_2 = ix(lP_1, "Steal") or ix(child2, "Steal")
                        local lS = lP_2
                        if lP_2 then
                            lP_2 = lS.Enabled
                        end
                        if not not lP_2 then
                            local lP_3 = lP_1:GetAttribute("Rarity") or ""
                            local lT = tostring(lP_3)
                            local lP_4 = lP_1:GetAttribute("Mutation") or "Normal"
                            local lU = tostring(lP_4)
                            if not not ir("CollectRarities", lT) then
                                if not not ir("CollectMutations", lU) then
                                    local lP_5 = lS.Parent
                                    local lV = lP_5 and lP_5:IsA("BasePart")
                                    if not lV then
                                        local lV_1 = Spawn:IsA("BasePart") and Spawn
                                        lP_5 = lV_1 or lP_1
                                    end
                                    local lN_5 = lP_5:IsA("BasePart") and lP_5.Position
                                    local lV_2 = lN_5 or lP_1:GetPivot().Position
                                    local lN_6 = lP
                                    if lN_6 then
                                        lN_6 = (lV_2 - lP).Magnitude
                                    end
                                    local lV_3 = lN_6 or 0
                                    local insert = table.insert
                                    local Name2 = child.Name
                                    local Name = child2.Name
                                    local lY = iT[lT] or 0
                                    insert(lO_1, {
                                        base = Name2,
                                        slot = Name,
                                        rarity = lT,
                                        mutation = lU,
                                        rank = lY,
                                        dist = lV_3,
                                        prompt = lS,
                                        part = lP_5,
                                        item = lP_1
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    table.sort(lO_1, function(cK, cL)
        if cK.rank ~= cL.rank then
            return cK.rank > cL.rank
        end
        return cK.dist < cL.dist
    end)
    return lO_1
end
local function fn217()
    if not it() then
        return false
    elseif not i4() then
        return false
    else
        local me = os.clock() + 2
        while os.clock() < me do
            if not it() then
                return true
            end
            task.wait(0.05)
        end
        return true
    end
end
local function fn239(aB)
    if ip.Unloaded then
        return false
    end
    local ki = Toggles[aB]
    return ki ~= nil and ki.Value == true
end
local function onCopyJoinScript_JobID()
    local e0 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, ik)
    iG(e0, "Copied join script to clipboard")
end
local function fn256(bE)
    return bE * 15 + 20
end
local function fn257(aH, aI)
    local kl = Options[aH]
    if kl == nil then
        return aI
    end
    return kl.Value
end
local function worker()
    local n6_1
    while true do
        task.wait(1)
        if ip.Unloaded then
            break
        end
        local n5 = math.floor(os.clock() - iW)
        if n5 < 60 then
            n6_1 = n5 .. "s"
        elseif n5 < 3600 then
            n6_1 = string.format("%dm %ds", math.floor((n5) / (60)), n5 % 60)
        else
            n6_1 = string.format("%dh %dm", math.floor((n5) / (3600)), math.floor((n5 % 3600) / (60)))
        end
        Label:SetText(iZ("Session time", n6_1, il))
    end
end
local function fn264()
    local nn = iN()
    local no = iI()
    for i, v in ipairs(iV) do
        local np = iY(nn, v)
        if no >= np then
            PurchasePower:FireServer(v)
            return true
        end
    end
    return false
end
local function fn267(bs, bt)
    local kZ_1
    local kY_1
    kY_1, kZ_1 = bs, 0
    local k2 = 1
    while k2 <= bt do
        kZ_1 = kZ_1 + 1.125 ^ math.max(0, kY_1 - 1) * 50
        kY_1 = kY_1 + 1
        k2 += 1
    end
    return math.floor(kZ_1)
end
local function fn276(as, at, au)
    return string.format("<b>%s</b> %s %s", as, jd("-", "#5a6070"), jd(at, au))
end
local function fn327(S, T)
    local kd = tonumber(S:match("%d+")) or 0
    local ke = tonumber(T:match("%d+")) or 0
    return kd < ke
end
local function fn335()
    local kN = iL:GetAttribute("Power") or 1
    return kN
end
local function fn343()
    local leaderstats = iL:FindFirstChild("leaderstats")
    local kI = leaderstats and leaderstats:FindFirstChild("Rebirths")
    local kH_1 = kI
    if kI then
        kI = kH_1.Value
    end
    return kI or 0
end
local function fn357(aM)
    local kn = iH(aM, {})
    if typeof(kn) ~= "table" then
        return {}
    end
    local ko = {}
    for k, v in pairs(kn) do
        if v == true then
            ko[k] = true
        else
            local kn_1 = typeof(k) == "number" and typeof(v) == "string"
            if kn_1 then
                ko[v] = true
            end
        end
    end
    return ko
end
local function fn368()
    local kQ = (iL:GetAttribute("WalkSpeed"))
    local kU = if kQ then 1 else 0
    local kS = 3050 * kU + 1891 * (1 - kU)
    local kT = 318 * kU + 4084 * (1 - kU)
    if not ((kS * 1903 + kT * 2601 + kS * kT) % 16777213 == 7601168) then
        kQ = 20
    end
    return math.min(kQ, 100)
end
local function fn427(ap, aq)
    return string.format('<font color="%s">%s</font>', aq, ap)
end
local function fn457()
    local nN = it() and id("AutoBackToBase")
    local nN_8, nN_9, nN_10, nN_11, nN_12, nN_13, nN_14
    if nN then
        local nR = if je() then 1 else 0
        if nR == 1 then
            return true
        end
        local nN_1 = id("AutoCollectBrainrot") and iR()
        if nN_8 then
            return true
        end
        local nN_2 = id("AutoCollectMoney") and iQ()
        if nN_9 then
            return true
        end
        local nN_3 = id("AutoUpgradeBrainrots") and iD()
        if nN_10 then
            return true
        end
        local nN_4 = id("AutoBuyFloors") and iv()
        if nN_11 then
            return true
        end
        local nN_5 = id("AutoBuyTools") and iF()
        if nN_12 then
            return true
        end
        local nN_6 = id("AutoBuyPower") and is()
        if nN_13 then
            return true
        end
        local nN_7 = id("AutoBuySpeed") and iy()
        if nN_14 then
            return true
        end
        return false
    end
    nN_8 = id("AutoCollectBrainrot") and iR()
    if nN_8 then
        return true
    end
    nN_9 = id("AutoCollectMoney") and iQ()
    if nN_9 then
        return true
    end
    nN_10 = id("AutoUpgradeBrainrots") and iD()
    if nN_10 then
        return true
    end
    nN_11 = id("AutoBuyFloors") and iv()
    if nN_11 then
        return true
    end
    nN_12 = id("AutoBuyTools") and iF()
    if nN_12 then
        return true
    end
    nN_13 = id("AutoBuyPower") and is()
    if nN_13 then
        return true
    end
    nN_14 = id("AutoBuySpeed") and iy()
    if nN_14 then
        return true
    end
    return false
end
local function fn476(aU)
    return next(ij(aU)) ~= nil
end
local function fn496()
    local ml = if it() then 1 else 0
    if ml == 1 then
        if id("AutoBackToBase") then
            return je()
        end
        return false
    end
    local mg = iU()
    local mh = mg[1]
    if not mh then
        return false
    end
    local mg_1 = i7()
    if mg_1 then
        mg_1.AssemblyLinearVelocity = Vector3.zero
        mg_1.AssemblyAngularVelocity = Vector3.zero
    end
    iP(mh.part)
    task.wait(0.25)
    i2(mh.prompt)
    local mg_2 = os.clock() + 1.25
    while os.clock() < mg_2 do
        if it() then
            break
        end
        task.wait(0.05)
    end
    local mg_3 = id("AutoBackToBase") and it()
    if mg_3 then
        return je()
    end
    return it()
end
local function fn522(bW, bX)
    if not bW then
        return nil
    end
    for i, descendant in ipairs(bW:GetDescendants()) do
        local lp = descendant:IsA("ProximityPrompt") and descendant.Enabled
        if lp then
            if not bX or descendant.ActionText == bX then
                return descendant
            end
        end
    end
    return nil
end
local function onInputChanged(fB)
    local UserInputType = fB.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        jb = tick()
    end
end
local function worker2()
    while not ip.Unloaded do
        task.wait(2)
        if id("AntiAfk") then
            local ol = tick() - jb
            local om = tick() - i5
            if ol >= 300 and om >= 60 then
                pcall(iB)
            else
                if ol < 300 and om >= 300 then
                    pcall(iB)
                end
            end
        end
    end
end
local function fn557()
    local m7 = iI()
    local m8 = false
    for i, v in ipairs(iK) do
        if not (iL:GetAttribute(v.name) == true) then
            if v.cost > 0 and m7 >= v.cost then
                BuyTool:FireServer(v.name)
                m8 = true
                task.wait(0.15)
                m7 = iI()
            end
        end
    end
    local m9_2 = nil
    for i, v in ipairs(iK) do
        if iL:GetAttribute(v.name) == true then
            if not m9_2 or v.damage > m9_2.damage then
                m9_2 = v
            end
        end
    end
    local m7_2 = m9_2 and iL:GetAttribute("EquippedTool") ~= m9_2.name
    if m7_2 then
        EquipTool:FireServer(m9_2.name)
        m8 = true
    end
    return m8
end
local function fn566()
    local nx = iA()
    if nx >= 100 then
        return false
    end
    local ny = iI()
    for i, v in ipairs(iO) do
        if not (nx + v > 100) then
            local nz = iq(nx, v)
            if ny >= nz then
                PurchaseSpeed:FireServer(v)
                return true
            end
        end
    end
    return false
end
local function fn570(eK)
    local DiscordGroup = eK:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = io })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = io })
end
local function onUnload()
    ip:Unload()
end
local function fn595(du)
    if du == "Floor1" then
        return true
    end
    return iL:GetAttribute(du .. "_Unlocked") == true
end
local function fn607(ai, aj)
    if setclipboard then
        setclipboard(ai)
    elseif toclipboard then
        toclipboard(ai)
    end
    ip:Notify(aj)
end
local function fn622()
    local Character = iL.Character
    local kC = Character and Character:FindFirstChild("HumanoidRootPart")
    return kC
end
local function fn625()
    local ll = jc()
    if not ll then
        return false
    end
    local lm = ll:FindFirstChild("Teleport") or ll:FindFirstChild("Spawn") or ll
    return iP(lm)
end
local function fn649()
    local nH = iN()
    local nI = i0(ig())
    if nH < nI then
        return false
    end
    RequestRebirth:FireServer()
    return true
end
local function fn651(Y, Z)
    if Y.order ~= Z.order then
        return Y.order < Z.order
    end
    return Y.cost < Z.cost
end
local function onReturnToBase()
    task.spawn(i4)
end
local function fn661()
    local mF = jc()
    if not mF then
        return false
    end
    local mG = false
    for i, child in ipairs(mF:GetChildren()) do
        if not not child.Name:match("^Floor%d+$") then
            local mF_1 = child.Name ~= "Floor1" and iL:GetAttribute(child.Name .. "_Unlocked") ~= true
            if not mF_1 then
                local Slots = child:FindFirstChild("Slots")
                local mQ = if not Slots then 1 else 0
                local mO = 3899 * mQ + 2124 * (1 - mQ)
                local mP = 1198 * mQ + 2586 * (1 - mQ)
                if not ((mO * 1940 + mP * 1443 + mO * mP) % 16777213 == 13963776) then
                    for i, child2 in ipairs(Slots:GetChildren()) do
                        if child2:GetAttribute("HasItem") == true then
                            RequestSlotUpgrade:FireServer(child.Name, child2.Name)
                            mG = true
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
    end
    return mG
end
local function fn681()
    connection:Disconnect()
    connection2:Disconnect()
end
local function fn699()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    i_:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    i_:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    i5 = tick()
end
local function fn702()
    local mY = iI()
    local mZ = false
    for i, v in ipairs(ih) do
        if not iJ(v.name) then
            local m_ = v.previous and not iJ(v.previous)
            if not m_ then
                if mY >= v.price then
                    RequestFloorPurchase:FireServer(v.name)
                    mZ = true
                    task.wait(0.2)
                    mY = iI()
                end
            end
        end
    end
    return mZ
end
local function fn711()
    local Character = iL.Character
    local kW = Character ~= nil and Character:GetAttribute("Carrying") == true
    return kW
end
Toggles = nil
connection = nil
id = nil
BuyTool = nil
ig = nil
ih = nil
PurchaseSpeed = nil
ij = nil
ik = nil
il = nil
PurchasePower = nil
io = nil
ip = nil
iq = nil
ir = nil
is = nil
it = nil
Label = nil
iv = nil
iw = nil
ix = nil
iy = nil
iz = nil
iA = nil
iB = nil
iC = nil
iD = nil
iE = nil
iF = nil
iG = nil
iH = nil
iI = nil
iJ = nil
iK = nil
iL = nil
connection2 = nil
iN = nil
iO = nil
iP = nil
iQ = nil
iR = nil
Workspace = nil
iT = nil
iU = nil
iV = nil
iW = nil
RequestRebirth = nil
iY = nil
iZ = nil
i_ = nil
i0 = nil
RequestFloorPurchase = nil
i2 = nil
i3 = nil
i4 = nil
i5 = nil
RequestSlotUpgrade = nil
i7 = nil
Options = nil
EquipTool = nil
jb = nil
jc = nil
jd = nil
je = nil
local ja, jk, js, jt, jw
local jr_1
local jq_1
local ji_1
i_, Workspace, iL, iz, iw, PurchasePower, PurchaseSpeed, BuyTool, EquipTool, RequestSlotUpgrade, RequestFloorPurchase, RequestRebirth, ji_1, ip, jq_1, Toggles, Options, iT = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local jf = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local jj_4
if ((Options or not RequestSlotUpgrade) and (PurchaseSpeed or not RequestSlotUpgrade) or (iw or iw or (not PurchaseSpeed or Options))) and not ((Options or not RequestSlotUpgrade) and (PurchaseSpeed or not RequestSlotUpgrade) or (iw or iw or (not PurchaseSpeed or Options))) then
    iL = game:GetService("UserInputService")
    jt = game:GetService("VirtualUser")
    jr_1 = game:GetService("Workspace")
    i_ = "Break Tape For Brainrots"
else
    jt = game:GetService("UserInputService")
    i_ = game:GetService("VirtualUser")
    Workspace = game:GetService("Workspace")
    iL = jf.LocalPlayer
    jr_1 = "Break Tape For Brainrots"
end
if (Toggles or not RequestFloorPurchase) and (jq_1 or not Toggles) and (Toggles and jq_1 and (not jq_1 or not RequestFloorPurchase)) or not ((Toggles or not RequestFloorPurchase) and (jq_1 or not Toggles) and (Toggles and jq_1 and (not jq_1 or not RequestFloorPurchase))) then
    iz = "https://discord.gg/K7Qxnxkk46"
    iw = "https://discord.gg/K7Qxnxkk46"
else
    iw = "https://discord.gg/K7Qxnxkk46"
    iz = "https://discord.gg/K7Qxnxkk46"
end
local jh = ReplicatedStorage:WaitForChild("Events")
PurchasePower = jh:WaitForChild("PurchasePower")
PurchaseSpeed = jh:WaitForChild("PurchaseSpeed")
BuyTool = jh:WaitForChild("BuyTool")
EquipTool = jh:WaitForChild("EquipTool")
RequestSlotUpgrade = jh:WaitForChild("RequestSlotUpgrade")
RequestFloorPurchase = jh:WaitForChild("RequestFloorPurchase")
RequestRebirth = jh:WaitForChild("RequestRebirth")
local RarityConfigurations = require(ReplicatedStorage.Modules.RarityConfigurations)
local jm = require(ReplicatedStorage.Modules.MutationConfigurations)
local jn = require(ReplicatedStorage.Modules.ToolsConfiguration)
local jo = require(ReplicatedStorage.Modules.FloorConfigurations)
if ((Toggles or not iz) and (iw or not Toggles) or (Toggles or not i_ or not i_ and iw) or (not Toggles and not jm and (not iw or iw) or (jm or not jm) and (not jm and not i_))) and ((Toggles and i_ or (i_ or not iz)) and (iw and not jm or (iw or Toggles)) and ((not i_ and i_ or not i_ and not jm) and (iw and not Toggles and (iw or not Toggles)))) or not (((Toggles or not iz) and (iw or not Toggles) or (Toggles or not i_ or not i_ and iw) or (not Toggles and not jm and (not iw or iw) or (jm or not jm) and (not jm and not i_))) and ((Toggles and i_ or (i_ or not iz)) and (iw and not jm or (iw or Toggles)) and ((not i_ and i_ or not i_ and not jm) and (iw and not Toggles and (iw or not Toggles))))) then
    ji_1 = ""
else
    iT = ""
end
ip = getgenv().Library
local jq_2 = getgenv().ThemeManager
local jp = getgenv().SaveManager
Toggles = ip.Toggles
Options = ip.Options
if (jq_2 or jq_2 or (not jm or jq_2) or Options and jm and (not jt and jq_2)) and (not Options and not jt and (not jq_2 and Options) or jt and Options and (jt or not jq_2)) and ((Options and jq_2 or jm and not jt or not jq_2 and not jt and (jm and Options)) and ((jq_2 or jt) and (Options and jt) or (not Options or jm or (Options or jm)))) and not ((jq_2 or jq_2 or (not jm or jq_2) or Options and jm and (not jt and jq_2)) and (not Options and not jt and (not jq_2 and Options) or jt and Options and (jt or not jq_2)) and ((Options and jq_2 or jm and not jt or not jq_2 and not jt and (jm and Options)) and ((jq_2 or jt) and (Options and jt) or (not Options or jm or (Options or jm))))) then
    js = {
        "Godly",
        "Mythical",
        "Uncommon",
        "Rare",
        "OG",
        "Secret",
        "Celestial",
        "Exclusive",
        "Epic",
        "Ancient",
        "Limited",
        "Legendary",
        "Common"
    }
    iT = {}
    jk = {}
else
    jk = {
        "Common",
        "Uncommon",
        "Rare",
        "Epic",
        "Legendary",
        "Mythical",
        "Secret",
        "Godly",
        "OG",
        "Celestial",
        "Ancient",
        "Limited",
        "Exclusive"
    }
    js = {}
    iT = {}
end
local ju = {}
for i, v in ipairs(jk) do
    if RarityConfigurations[v] then
        table.insert(js, v)
        iT[v] = i
        ju[v] = true
    end
end
for k in pairs(RarityConfigurations) do
    if not ju[k] then
        table.insert(js, k)
        iT[k] = #js
    end
end
jf = {}
for k in pairs(jm) do
    table.insert(jf, k)
end
jh = nil
local jg = 3
local AccountGroup
repeat
    local ji_2 = {
        "anetobeuluf",
        "wsnz",
        "sknkjogdurv",
        "xjp",
        "cnqss",
        "ficmz",
        "ugd",
        "vrjzccoq",
        "cgsjqurhrji",
        "rfpehij",
        "ofnkclvtjl",
        "muyqpf"
    }
    local pa = jg
    local jj_1 = ji_2[pa % 12 + 1]
    if jj_1:len() <= jj_1:gsub("(.)", "%1%1", pa % 3 % 2 + 1):len() then
        table.sort(jf)
        jh = {}
    else
        table.sort(jh)
        jf = {}
    end
    jg = (jg + 3) % 4
until (jg * 3 + 2) % 4 == 0
local Bases = Workspace:WaitForChild("Bases")
for i, child in ipairs(Bases:GetChildren()) do
    local jg_2 = child:IsA("Model") and child.Name:match("^Base%d+$")
    if jg_2 then
        table.insert(jh, child.Name)
    end
end
local jg_3 = 6
repeat
    local pe = bit32.rrotate(bit32.bxor(bit32.lrotate(jg_3, 23), string.byte(tostring(jg_3))), 12)
    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(pe, 3541993379), 1836820765), (bit32.bxor(bit32.band(pe, 752973916), 2092322750))), 1836820765), 2092322750) ~= pe then
        table.sort(jh, fn327)
    else
        table.sort(jh, fn327)
    end
    jg_3 = (jg_3 + 3) % 8
until (jg_3 * 3 + 5) % 8 == 0
iK = {}
for k, v in pairs(jn) do
    local insert = table.insert
    local ji_3 = tonumber(v.Cost) or 0
    local jj_2 = tonumber(v.DamageMultiplier) or 1
    jk = tonumber(v.FunnelOrder) or math.huge
    insert(iK, { name = k, cost = ji_3, damage = jj_2, order = jk })
end
ih = nil
local jl_1 = 2
repeat
    local jg_5 = {
        "pzjnqmwcrfb",
        "ouyljsitqc",
        "mxjyu",
        "qedd",
        "snovlyybnagr",
        "okjyb",
        "xsrhoesvr",
        "oibugaqa",
        "covumqywlyqj"
    }
    if jg_5[(jl_1 * 3 + 102) % 9 + 1] < jg_5[(jl_1 * 3 + 102) % 9 + 1] then
        table.sort(ih, fn651)
        iK = {}
    else
        table.sort(iK, fn651)
        ih = {}
    end
    jl_1 = (jl_1 + 0) % 8
until (jl_1 * 3 + 4) % 8 == 2
for k, v in pairs(jo.Floors) do
    local insert = table.insert
    local ji_4 = tonumber(v.Price) or 0
    local Previous = v.Previous
    jk = tonumber(k:match("%d+")) or 0
    insert(ih, { name = k, price = ji_4, previous = Previous, num = jk })
end
iV, iO, il, iG, io, jd, iZ, id, iH, ij, iC, ir, i7, iI, ig, iN, iA, it, jc, iY, iq, i0, iP, i4, ix, i2, iU, je, iR, iQ, iD, iJ, iv, iF, is, iy, iE, ja = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if (((iq or not iq) and 47) or ((iq or false) and false) and ((not iq or iq) and (iq or not iq) and 47)) and not (((iq or not iq) and 47) or ((iq or false) and false) and ((not iq or iq) and (iq or not iq) and 47)) then
    table.sort(jd, fn118)
    iG = { 1, 5, 10 }
    io = { 10, 1, 5 }
    ih = fn607
    iV = fn54
    iO = fn427
else
    table.sort(ih, fn118)
    iV = { 10, 5, 1 }
    iO = { 10, 5, 1 }
    iG = fn607
    io = fn54
    jd = fn427
end
iZ = fn276
ju = "#7fd47f"
jo = "#6ec1ff"
il = "#e8a34d"
jn = "#8b93a3"
id = fn239
iH = fn257
ij = fn357
iC = fn476
ir = fn6
i7 = fn622
iI = fn84
ig = fn343
iN = fn335
iA = fn368
it = fn711
jc = fn157
iY = fn267
iq = fn2
i0 = fn256
iP = function(bG)
    local le
    local ld
    ld = nil
    le = nil
    le = i7()
    if not (le and bG) then
        return false
    end
    ld = nil
    if typeof(bG) == "Vector3" then
        ld = bG
    elseif typeof(bG) == "CFrame" then
        ld = bG.Position
    elseif bG:IsA("Attachment") then
        ld = bG.WorldPosition
    elseif bG:IsA("BasePart") then
        ld = bG.Position
    elseif bG:IsA("Model") then
        ld = bG:GetPivot().Position
    else
        local Parent = bG.Parent
        local lg = Parent and Parent:IsA("BasePart")
        if lg then
            ld = Parent.Position
        else
            local lg_1 = Parent and Parent:IsA("Model")
            if lg_1 then
                ld = Parent:GetPivot().Position
            end
        end
    end
    if not ld then
        return false
    end
    pcall(function()
        le.AssemblyLinearVelocity = Vector3.zero
        le.AssemblyAngularVelocity = Vector3.zero
        le.CFrame = CFrame.new(ld + Vector3.new(0, 3, 0))
    end)
    return true
end
i4 = fn625
ix = fn522
i2 = function(b2)
    local lA_1, lA_2
    if not b2 then
        return false
    end
    local ly = tonumber(b2.HoldDuration) or 0
    local ly_3, ly_4
    local lz = ly
    if lz < 0.05 then
        lz = 0.05
    end
    if fireproximityprompt then
        local ly_1 = pcall(fireproximityprompt, b2, lz)
        if ly_1 then
            return true
        end
        local ly_2 = pcall(fireproximityprompt, b2)
        if ly_2 then
            return true
        elseif getconnections then
            ly_3, lA_1 = pcall(getconnections, b2.Triggered)
            local lB_1 = ly_3 and type(lA_1) == "table"
            if lB_1 then
                for i, v in ipairs(lA_1) do
                    local lI = v
                    pcall(function()
                        if lI.Fire then
                            lI:Fire(iL)
                        elseif type(lI.Function) == "function" then
                            lI.Function(iL)
                        end
                    end)
                end
                return true
            end
            pcall(function()
                b2:InputHoldBegin()
            end)
            task.wait(lz)
            pcall(function()
                b2:InputHoldEnd()
            end)
            return true
        else
            pcall(function()
                b2:InputHoldBegin()
            end)
            task.wait(lz)
            pcall(function()
                b2:InputHoldEnd()
            end)
            return true
        end
    elseif getconnections then
        ly_4, lA_2 = pcall(getconnections, b2.Triggered)
        local lB_2 = ly_4 and type(lA_2) == "table"
        if lB_2 then
            for i, v in ipairs(lA_2) do
                local lI = v
                pcall(function()
                    if lI.Fire then
                        lI:Fire(iL)
                    elseif type(lI.Function) == "function" then
                        lI.Function(iL)
                    end
                end)
            end
            return true
        end
        pcall(function()
            b2:InputHoldBegin()
        end)
        task.wait(lz)
        pcall(function()
            b2:InputHoldEnd()
        end)
        return true
    else
        pcall(function()
            b2:InputHoldBegin()
        end)
        task.wait(lz)
        pcall(function()
            b2:InputHoldEnd()
        end)
        return true
    end
end
iU = fn206
je = fn217
iR = fn496
iQ = fn77
iD = fn661
if (iY or iY) and (iC or it) or (iC and iC or not iC and it) or not ((iY or iY) and (iC or it) or (iC and iC or not iC and it)) then
    iJ = fn595
    iv = fn702
    iF = fn557
    is = fn264
    iy = fn566
else
    iy = fn595
    iJ = fn702
    iv = fn557
    iF = fn264
    is = fn566
end
iE = fn649
ja = fn457
local Window = ip:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = iz, Copyable = true }, "|", jr_1 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local jv = {
    Info = Window:AddTab("Info", "info"),
    Collect = Window:AddTab("Collect", "hand-grab"),
    Auto = Window:AddTab("Auto", "bot"),
    Settings = Window:AddTab("Settings", "settings")
}
jm = fn570
for k, v in jv do
    jm(v)
end
i3, AccountGroup, jk, Label, ik, jj_4 = nil, nil, nil, nil, nil, nil
local ji_5 = 10
repeat
    local jl_3 = (ji_5 * 2 + 1) % 3 + 1
    if jl_3 <= 2 then
        if jl_3 <= 1 then
            local jl_4 = (vector.create((ji_5 * 3 + 2) % 11 + 1, (ji_5 * 5 + 8) % 13 + 1, (ji_5 * 2 + 13) % 17 + 1))
            jm = (vector.create((ji_5 * 5 + 6) % 11 + 1, (ji_5 * 11 + 3) % 13 + 1, (ji_5 * 6 + 3) % 17 + 1))
            jw = (vector.create((ji_5 * 2 + 6) % 5 + 1, (ji_5 * 1 + 4) % 7 + 1, (ji_5 * 3 + 3) % 9 + 1))
            if math.abs((vector.angle(jl_4, jm, jw))) - math.abs((vector.angle(jm, jl_4, jw))) == 2 then
                jk = "Unknown"
                pcall(fn178)
                ju = (nil):AddLeftGroupbox("Account", "circle-user")
                ju:AddLabel(AccountGroup("User", i3.Name, iZ), true)
                ju:AddLabel(AccountGroup("Status", "Keyless", iZ), true)
                ju:AddLabel(AccountGroup("Executor", "Unknown", iZ), true)
                iL = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
                iL:AddLabel(Label(jo .. " [" .. tostring(game.PlaceId) .. "]", jr_1), true)
                iL:AddLabel(AccountGroup("Place ID", tostring(game.PlaceId), jr_1), true)
                jv = iL:AddLabel(AccountGroup("Session time", "0s", jd), true)
            else
                i3 = "Unknown"
                pcall(fn178)
                AccountGroup = jv.Info:AddLeftGroupbox("Account", "circle-user")
                AccountGroup:AddLabel(iZ("User", iL.Name, ju), true)
                AccountGroup:AddLabel(iZ("Status", "Keyless", ju), true)
                AccountGroup:AddLabel(iZ("Executor", i3, ju), true)
                jk = jv.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                jk:AddLabel(jd(jr_1 .. " [" .. tostring(game.PlaceId) .. "]", jo), true)
                jk:AddLabel(iZ("Place ID", tostring(game.PlaceId), jo), true)
                Label = jk:AddLabel(iZ("Session time", "0s", il), true)
            end
            ji_5 = (ji_5 + 14) % 24
        else
            local jl_5 = {
                "wesygsuw",
                "euqlzj",
                "detgnpc",
                "inzqxau",
                "uzgmqrre",
                "crchqvn",
                "osnapkqs",
                "jrul",
                "byriwknza",
                "aaxegt",
                "vekdd",
                "ocwr",
                "yqbghbeucmi",
                "eomtxwwtl",
                "hzewgguana",
                "emolmtgogdmh"
            }
            if jl_5[(ji_5 * 23 + 32) % 16 + 1] <= jl_5[(ji_5 * 23 + 32) % 16 + 1] then
                ik = tostring(game.JobId)
            else
                i3 = tostring(game.JobId)
            end
            ji_5 = (ji_5 + 14) % 24
        end
    else
        local jl_6 = {
            "mvhgmo",
            "snls",
            "kfflywjlkty",
            "mgyx",
            "yspiptg",
            "ckw",
            "prp",
            "spwndy",
            "swfvwz",
            "immjnde",
            "fjkpaeb",
            "ily"
        }
        local o7 = ji_5
        jm = jl_6[o7 % 12 + 1]
        if jm:len() >= jm:gsub("(.)", "%1%1", o7 % 3 % 2 + 1):len() then
            ik = #jj_4 > 18
        else
            jj_4 = #ik > 18
        end
        ji_5 = (ji_5 + 8) % 24
    end
until (ji_5 * 23 + 5) % 24 == 7
if jj_4 then
    local jg_8 = 5
    repeat
        local ji_6 = (vector.create((jg_8 * 3 + 1) % 11 + 1, (jg_8 * 8 + 7) % 13 + 1, (jg_8 * 1 + 4) % 17 + 1))
        local jl_7 = (vector.create((jg_8 * 2 + 1) % 11 + 1, (jg_8 * 7 + 2) % 13 + 1, (jg_8 * 4 + 7) % 17 + 1))
        local pz = vector.dot(ji_6, jl_7)
        if pz * pz >= vector.dot(ji_6, ji_6) * vector.dot(jl_7, jl_7) + 1 then
            ik = string.sub(jj_4, 1, 18) .. "..."
        else
            jj_4 = string.sub(ik, 1, 18) .. "..."
        end
        jg_8 = (jg_8 + 1) % 8
    until (jg_8 * 5 + 1) % 8 == 7
end
local jg_9 = jj_4 or ik
iW, jb, i5, connection, connection2, iB = nil, nil, nil, nil, nil, nil
jk:AddLabel(iZ("Server", jg_9, jn), true)
jk:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
iW = os.clock()
task.spawn(worker)
local ScriptsGroup = jv.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(jd("Included in this hub", jn), true)
ScriptsGroup:AddLabel(jd(jr_1, jo), true)
local FeaturesGroup = jv.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(jd("Brainrot Collect", jo), true)
FeaturesGroup:AddLabel(jd("Base Return", il), true)
FeaturesGroup:AddLabel(jd("Shop Automation", ju), true)
FeaturesGroup:AddLabel(jd("Base Automation", jn), true)
local SocialsGroup = jv.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = io })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = jv.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = io })
local FaqGroup = jv.Info:AddRightGroupbox("FAQ", "circle-help")
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
local CollectGroup = jv.Collect:AddLeftGroupbox("Collect", "hand-grab")
CollectGroup:AddToggle("AutoCollectBrainrot", { Text = "Auto Collect Brainrot", Default = false })
CollectGroup:AddToggle("AutoBackToBase", { Text = "Auto Go Back to Base", Default = true })
CollectGroup:AddDropdown("CollectAreas", { Text = "Areas", Values = jh, Multi = true, AllowNull = true, Searchable = true, Default = {} })
CollectGroup:AddSlider("ActionDelay", { Text = "Action delay", Default = 0.35, Min = 0.1, Max = 5, Rounding = 2, Suffix = "s" })
CollectGroup:AddButton({ Text = "Return to Base", Func = onReturnToBase })
local FiltersGroup = jv.Collect:AddRightGroupbox("Filters", "filter")
FiltersGroup:AddDropdown("CollectRarities", { Text = "Rarities", Values = js, Multi = true, AllowNull = true, Searchable = true, Default = {} })
FiltersGroup:AddDropdown("CollectMutations", { Text = "Mutations", Values = jf, Multi = true, AllowNull = true, Searchable = true, Default = {} })
local BaseGroup = jv.Auto:AddLeftGroupbox("Base", "house")
BaseGroup:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
BaseGroup:AddToggle("AutoUpgradeBrainrots", { Text = "Auto Upgrade Brainrots", Default = false })
BaseGroup:AddToggle("AutoBuyFloors", { Text = "Auto Buy Floors", Default = false })
jw = jv.Auto:AddRightGroupbox("Shop", "shopping-cart")
jw:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
jw:AddToggle("AutoBuyPower", { Text = "Auto Buy Power Upgrades", Default = false })
jw:AddToggle("AutoBuySpeed", { Text = "Auto Buy Speed Upgrades", Default = false })
jw:AddToggle("AutoBuyTools", { Text = "Auto Buy Tools", Default = false })
jm = jv.Settings:AddLeftGroupbox("Menu", "menu")
jm:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
ip.ToggleKeybind = Options.MenuKeybind
jm:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
jm:AddButton({ Text = "Unload", Func = onUnload })
jq_2:SetLibrary(ip)
jq_2:SetFolder("TempoHub")
jq_2:SaveDefault("Monochrome")
jq_2:ApplyToTab(jv.Settings)
jq_2:LoadDefault()
jp:SetLibrary(ip)
jp:IgnoreThemeSettings()
jp:SetIgnoreIndexes({ "MenuKeybind" })
jp:SetFolder("TempoHub/break-tape-for-brainrots")
jp:BuildConfigSection(jv.Settings)
jp:LoadAutoloadConfig()
jb = tick()
i5 = tick()
pcall(function()
    for i, v in ipairs(getconnections(iL.Idled)) do
        local oe = v
        pcall(function()
            oe:Disable()
        end)
    end
end)
iB = fn699
connection = jt.InputBegan:Connect(onInputBegan)
connection2 = jt.InputChanged:Connect(onInputChanged)
ip:OnUnload(fn681)
task.spawn(worker2)
task.spawn(function()
    local ox = false
    repeat
        local oq
        if not ip.Unloaded then
            oq = false
            pcall(function()
                oq = ja() == true
            end)
            if oq then
                local ou = tonumber(iH("ActionDelay", 0.35)) or 0.35
                task.wait(ou)
            else
                task.wait(0.2)
            end
        else
            ox = true
        end
    until ox
end)
task.spawn(worker3)
ip:Notify(jr_1 .. " loaded")
end)(...)

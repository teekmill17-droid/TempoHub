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
getgenv().TempoHoodSubtitle = "THROW AN ANIME COIN!"
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
local iu
local jb
local iT
local iA
local SellAll
local Stacks
local im
local i4
local LocalPlayer
local it
local Label
local HttpService
local ClientState
local VirtualUser
local iF
local il
local connection
local iL
local is
local i9
local iR
local Library
local iX
local iE
local Options
local SellItem
local iK
local SaveManager
local i8
local ItemDB
local ix
local je
local Constants
local connection2
local ij
local UserInputService
local CoinDB
local iq
local BuyCoin
local iP
local iw
local Toggles
local iV
local CurrentCamera
local ThrowCoin
local i0
local iI
local ip
local i6
local iO
local BuyUpgrade
local EquipBest
local iB
local i_
local iH
local io
local i5
local CollectPad
local function fn1(cl)
    for i, child in cl:GetChildren() do
        local Collect = child:FindFirstChild("Collect")
        if Collect then
            local Hitbox = Collect:FindFirstChild("Hitbox")
            if Hitbox then
                return Hitbox
            end
        end
    end
    return nil
end
local function onCopyUSDTAddress()
    iE(je, "Copied USDT address")
end
local function onRenderStepped(dN)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local mx_1 = iB()
        if mx_1 then
            mx_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local mx_3 = ij()
        local my = iB()
        if mx_3 and my then
            my.PlatformStand = true
            local my_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                my_1 = my_1 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                my_1 = my_1 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                my_1 = my_1 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                my_1 = my_1 + CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                my_1 = my_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                my_1 = my_1 - Vector3.new(0, 1, 0)
            end
            mx_3.Velocity = Vector3.zero
            if my_1.Magnitude > 0 then
                mx_3.CFrame = mx_3.CFrame + my_1.Unit * Options.FlySpeed.Value * dN
            end
        end
    end
end
local function fn33()
    local kI_1
    local kH_1
    if identifyexecutor then
        kI_1, kH_1 = identifyexecutor()
        local kJ = kI_1 ~= ""
        local kK = type(kI_1) == "string" and kJ
        if kK then
            local kJ_1 = type(kH_1) == "string" and kH_1 ~= "" and kI_1 .. " " .. kH_1
            iH = kJ_1 or kI_1
        end
    end
end
local function fn47()
    local ls = il()
    if not ls then
        return
    end
    local lt = ls.valueLevel or 0
    local lt_1 = iK(Constants.VALUE_UPGRADE, lt)
    if i6() >= lt_1 then
        iI(BuyUpgrade, "value")
    end
end
local function fn54()
    iI(EquipBest)
end
local function onCopyEthereumAddress()
    iE(io, "Copied Ethereum address")
end
local function onCopyPayPalLink()
    iE(i8, "Copied PayPal link")
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local mZ = tick() - iX
            local m_ = tick() - iR
            if mZ >= 300 and m_ >= 60 then
                pcall(iu)
            else
                if mZ < 300 and m_ >= 300 then
                    pcall(iu)
                end
            end
        end
    end
end
local function fn118()
    local k0 = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Bases")
    if not k0 then
        return nil
    end
    for i, child in k0:GetChildren() do
        if child:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return child
        end
    end
    return nil
end
local function onCopyVenmoLink()
    iE(i0, "Copied Venmo link")
end
local function fn127()
    ClientState = require(LocalPlayer:WaitForChild("PlayerScripts").Client.ClientState)
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local mh_1 = iL()
        if mh_1 then
            for i, descendant in ipairs(mh_1:GetDescendants()) do
                local mh_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if mh_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn145(aM, aN)
    return string.format('<font color="%s">%s</font>', aN, aM)
end
local function onCopyJoinScript_JobID()
    local kS = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, i5)
    if setclipboard then
        setclipboard(kS)
    elseif toclipboard then
        toclipboard(kS)
    end
    Library:Notify("Copied join script to clipboard")
end
local function onCopySolanaAddress()
    iE(jb, "Copied Solana address")
end
local function onRscripts()
    if setclipboard then
        setclipboard(i4)
    elseif toclipboard then
        toclipboard(i4)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function fn230()
    local nd = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local ne = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if ne then
                local ne_1 = iO(k, v)
                if ne_1 then
                    nd[#nd + 1] = ne_1
                end
            end
        end
    end
    table.sort(nd, function(e9, fa)
        if e9.type ~= fa.type then
            return e9.type < fa.type
        end
        return e9.idx < fa.idx
    end)
    return { objects = nd }
end
local function onInputChanged(ev)
    local UserInputType = ev.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        iX = tick()
    end
end
local function fn288(eP, eQ)
    local m3 = eP == "Toggle" and Toggles
    local m8 = if m3 then 1 else 0
    local m6 = 2217 * m8 + 3917 * (1 - m8)
    local m7 = 1152 * m8 + 2530 * (1 - m8)
    if not ((m6 * 1041 + m7 * 294 + m6 * m7) % 16777213 == 5200569) then
        m3 = Options
    end
    local m3_1 = m3[eQ]
    local m2_2 = type(m3_1) == "table" and m3_1.Type == eP
    return m2_2 and m3_1 or nil
end
local function fn296(au)
    local DiscordGroup = au:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = ip })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = ip })
end
local function onUnload()
    Library:Unload()
end
local function fn332()
    i_(Toggles.AntiGameplayPause.Value)
end
local function fn357()
    local ll = ij()
    if not ll then
        return
    end
    local lm = iP()
    if not lm then
        return
    end
    local ln = im(lm)
    if not ln then
        return
    end
    local CFrame = ll.CFrame
    ll.CFrame = ln.CFrame + Vector3.new(0, 3, 0)
    task.wait(0.15)
    iI(CollectPad)
    task.wait(0.1)
    ll.CFrame = CFrame
end
local function fn372()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    iR = tick()
end
local function fn377()
    local kE = iL()
    local kF = kE and kE:FindFirstChild("HumanoidRootPart")
    return kF
end
local function onExportConfigToClipboard()
    local nB_1
    local nA_1
    nA_1, nB_1 = pcall(HttpService.JSONEncode, HttpService, ix())
    if not nA_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local nA_2 = setclipboard or toclipboard
    local nA_3 = type(nA_2) ~= "function" or not pcall(nA_2, nB_1)
    if nA_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function fn392()
    iE(i9, "Copied Discord invite to clipboard")
end
local function fn397()
    local lp = il()
    if not lp then
        return
    end
    local lq = lp.luckLevel or 0
    local lq_1 = iK(Constants.LUCK_UPGRADE, lq)
    if i6() >= lq_1 then
        iI(BuyUpgrade, "luck")
    end
end
local function onImportConfigFromClipboardTex()
    local nG_1
    local nE = Options.SaveManager_ImportSource.Value
    local nE_1
    local nK = if nE then 1 else 0
    local nI = 4024 * nK + 1810 * (1 - nK)
    local nJ = 459 * nK + 3676 * (1 - nK)
    if not ((nI * 3143 + nJ * 3452 + nI * nJ) % 16777213 == 16078916) then
        nE = ""
    end
    local nF = tostring(nE):match("^%s*(.-)%s*$")
    if nF == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    nE_1, nG_1 = pcall(HttpService.JSONDecode, HttpService, nF)
    local nF_1 = not nE_1
    local nQ = if nF_1 then 1 else 0
    local nO = 689 * nQ + 3416 * (1 - nQ)
    local nP = 619 * nQ + 2532 * (1 - nQ)
    if not ((nO * 875 + nP * 2915 + nO * nP) % 16777213 == 2833751) then
        nF_1 = type(nG_1) ~= "table"
    end
    if not nF_1 then
        nF_1 = type(nG_1.objects) ~= "table"
    end
    if nF_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local nE_2 = 0
    for i, v in ipairs(nG_1.objects) do
        if iq(v) then
            nE_2 += 1
        end
    end
    if nE_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local nG_2 = nE_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(nE_2, nG_2), 6)
end
local function fn472()
    iI(ThrowCoin, 1)
end
local function onCopyBitcoinAddress()
    iE(is, "Copied Bitcoin address")
end
local function fn554()
    local lv = il()
    if not lv then
        return
    end
    local lw = i6()
    local lx = -1
    local ly
    local lA = CoinDB.List or {}
    for k, v in lA do
        if v.price <= lw and not v.robuxOnly then
            if not lv.ownedCoins or not lv.ownedCoins[v.id] then
                if (v.luck or 0) > lx then
                    lx = v.luck or 0
                    ly = v
                end
            end
        end
    end
    if ly then
        iI(BuyCoin, ly.id)
    end
end
local function onInputBegan()
    iX = tick()
end
local function fn578()
    connection:Disconnect()
    connection2:Disconnect()
    i_(false)
    select("#", "Unloaded!")
end
local function fn580()
    local kB = iL()
    local kC = kB and kB:FindFirstChildOfClass("Humanoid")
    return kC
end
local function worker()
    local kV_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local kU = math.floor(os.clock() - iA)
        if kU < 60 then
            kV_1 = kU .. "s"
        elseif kU < 3600 then
            kV_1 = string.format("%dm %ds", math.floor((kU) / (60)), kU % 60)
        else
            kV_1 = string.format("%dh %dm", math.floor((kU) / (3600)), math.floor((kU % 3600) / (60)))
        end
        Label:SetText(it("Session time", kV_1, iT))
    end
end
local function fn626()
    iI(ThrowCoin, 1)
end
local function fn652()
    return LocalPlayer.Character
end
local function fn660()
    if not Toggles.WalkSpeedEnabled.Value then
        local mG = iB()
        if mG then
            mG.WalkSpeed = 16
        end
    end
end
local function fn712(Z, aa)
    if Z.tiers then
        local ki_1 = 0
        local kj_1 = 0
        for k, v in Z.tiers do
            local kk_1 = v.levelMax - ki_1
            if aa < v.levelMax then
                local km = kk_1 - (aa - ki_1)
                local kx = 1
                while kx <= km do
                    local ky = kx
                    local floor = math.floor
                    local baseCost = Z.baseCost
                    local km_1 = v.growth or 1
                    kj_1 = kj_1 + floor(baseCost * km_1 ^ (ki_1 + ky))
                    kx += 1
                end
                return kj_1
            end
            ki_1 = v.levelMax
        end
        return math.huge
    end
    local floor = math.floor
    local baseCost = Z.baseCost
    local kk_3 = Z.growth or 1
    return floor(baseCost * kk_3 ^ aa)
end
local function fn722()
    if not Toggles.Fly.Value then
        local mE = iB()
        if mE then
            mE.PlatformStand = false
        end
    end
end
local function fn739()
    local kf = il()
    local kg = kf and tonumber(kf.money)
    return kg or 0
end
local function fn747()
    if ClientState and ClientState.Data then
        return ClientState.Data
    end
    return nil
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            i_(true)
        end
    end
end
local function fn768(eX, eY)
    local Type = eY.Type
    if Type == "Toggle" then
        return { idx = eX, type = "Toggle", value = eY.Value == true }
    elseif Type == "Slider" then
        return { idx = eX, type = "Slider", value = tostring(eY.Value) }
    elseif Type == "Dropdown" then
        return { idx = eX, type = "Dropdown", multi = eY.Multi == true, value = eY.Value }
    elseif Type == "Input" then
        local na = eY.Value or ""
        return { idx = eX, type = "Input", text = tostring(na) }
    elseif Type == "ColorPicker" then
        return { idx = eX, type = "ColorPicker", value = eY.Value:ToHex(), transparency = eY.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = eX,
            type = "KeyPicker",
            mode = eY.Mode,
            key = eY.Value,
            modifiers = eY.Modifiers,
            toggled = eY.Toggled
        }
    else
        return nil
    end
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local ms_1 = iB()
        if ms_1 then
            ms_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn787()
    local lR_1
    local lI = il()
    if not lI or not lI.stacks then
        return
    end
    local lJ_1 = {}
    for k, v in pairs(Options.AutoSellRarity.Value) do
        if v then
            local lK_1 = iV[k]
            if lK_1 then
                lJ_1[lK_1] = true
            end
        end
    end
    local Value2 = Options.AutoSellMinValue.Value
    local Value = Toggles.AutoSellMutated.Value
    local lM = next(lJ_1) ~= nil
    local lN = Value2 > 0
    local lP = lM or lN or Value
    local lP_1
    local lO_1 = {}
    for k, v in lI.stacks do
        lR_1, lP_1 = Stacks.Parse(k)
        if lR_1 then
            local lS = ItemDB.ById[lR_1]
            if lS then
                local lT = false
                if not lP then
                    lT = true
                else
                    if lM and lJ_1[lS.rarity] then
                        lT = true
                    end
                    if lN and (lS.income or 0) >= Value2 then
                        lT = true
                    end
                    if Value and lP_1 > 0 then
                        lT = true
                    end
                end
                if lT then
                    table.insert(lO_1, { key = k, id = lR_1, mut = lP_1, count = v })
                end
            end
        end
    end
    if #lO_1 == 0 then
        return
    end
    local lJ_2 = 0
    for k in lI.stacks do
        lJ_2 = lJ_2 + 1
    end
    if #lO_1 >= lJ_2 then
        iI(SellAll)
    else
        for k, v in lO_1 do
            iI(SellItem, v.id, v.mut, v.count)
            task.wait(0.1)
        end
    end
end
local function fn804(an, ao)
    if setclipboard then
        setclipboard(an)
    elseif toclipboard then
        toclipboard(an)
    end
    Library:Notify(ao)
end
local function fn828(aP, aQ, aR)
    return string.format("<b>%s</b> %s %s", aP, iF("-", "#5a6070"), iF(aQ, aR))
end
local function onCopyLitecoinAddress()
    iE(iw, "Copied Litecoin address")
end
ThrowCoin = nil
ij = nil
Options = nil
il = nil
im = nil
io = nil
ip = nil
iq = nil
SaveManager = nil
is = nil
it = nil
iu = nil
iw = nil
ix = nil
Library = nil
ClientState = nil
iA = nil
iB = nil
CurrentCamera = nil
connection2 = nil
iE = nil
iF = nil
Stacks = nil
iH = nil
iI = nil
CoinDB = nil
iK = nil
iL = nil
LocalPlayer = nil
CollectPad = nil
iO = nil
iP = nil
ItemDB = nil
iR = nil
HttpService = nil
iT = nil
EquipBest = nil
iV = nil
Constants = nil
iX = nil
VirtualUser = nil
SellAll = nil
i_ = nil
i0 = nil
UserInputService = nil
SellItem = nil
connection = nil
i4 = nil
i5 = nil
local iv
i6 = nil
BuyCoin = nil
i8 = nil
i9 = nil
Label = nil
jb = nil
BuyUpgrade = nil
Toggles = nil
je = nil
local StatUpgradesGroup
local jx_1
local jD_1
local jy_1
local jw_1
local jr_1
UserInputService, VirtualUser, HttpService, LocalPlayer, Library, SaveManager, Options, Toggles, i9, i4 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
LocalPlayer = Players.LocalPlayer
local jk = "Throw an Anime Coin!"
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Options = Library.Options
Toggles = Library.Toggles
if (not UserInputService or UserInputService or not i9 and not i9) and (not i9 and i4 or not i9 and i9) or ((not i4 or i4) and (not i9 and UserInputService) or (not UserInputService or not UserInputService) and (not UserInputService and i4)) or (not i9 or not i4) and (i4 or not i9) and (i4 and UserInputService or (not UserInputService or not i4)) and (i4 or i9 or UserInputService and i4 or (i9 or i4 or not UserInputService and not i4)) or not ((not UserInputService or UserInputService or not i9 and not i9) and (not i9 and i4 or not i9 and i9) or ((not i4 or i4) and (not i9 and UserInputService) or (not UserInputService or not UserInputService) and (not UserInputService and i4)) or (not i9 or not i4) and (i4 or not i9) and (i4 and UserInputService or (not UserInputService or not i4)) and (i4 or i9 or UserInputService and i4 or (i9 or i4 or not UserInputService and not i4))) then
    i9 = "https://discord.gg/K7Qxnxkk46"
    i4 = "https://discord.gg/K7Qxnxkk46"
else
    i4 = "https://discord.gg/K7Qxnxkk46"
    i9 = "https://discord.gg/K7Qxnxkk46"
end
if setthreadidentity then
    setthreadidentity(8)
end
Constants, ItemDB, CoinDB, Stacks, ClientState, ThrowCoin, BuyUpgrade, BuyCoin, SellItem, SellAll, EquipBest, CollectPad, iV, iI, il, i6, iK = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Modules = ReplicatedStorage:WaitForChild("Modules")
Constants = require(Modules.Constants)
ItemDB = require(Modules.ItemDB)
CoinDB = require(Modules.CoinDB)
Stacks = require(Modules.Stacks)
pcall(fn127)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
ThrowCoin = Remotes:WaitForChild("ThrowCoin")
BuyUpgrade = Remotes:WaitForChild("BuyUpgrade")
BuyCoin = Remotes:WaitForChild("BuyCoin")
SellItem = Remotes:WaitForChild("SellItem")
SellAll = Remotes:WaitForChild("SellAll")
EquipBest = Remotes:WaitForChild("EquipBest")
CollectPad = Remotes:WaitForChild("CollectPad")
iI = function(N, ...)
    local O
    O = { ... }
    pcall(function()
        N:FireServer(unpack(O))
    end)
end
il = fn747
i6 = fn739
iK = fn712
local jm = {
    [1] = "Common",
    [2] = "Uncommon",
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary",
    [6] = "Mythic",
    [7] = "Secret",
    [8] = "Secret",
    [9] = "Secret",
    [10] = "Secret"
}
if (Remotes or BuyUpgrade or (Remotes or Remotes)) and (ClientState and ClientState or not ClientState and not Remotes) or (not BuyUpgrade or not ClientState or (not ClientState or BuyUpgrade)) and (Remotes and ClientState or Remotes and not ClientState) or not ((Remotes or BuyUpgrade or (Remotes or Remotes)) and (ClientState and ClientState or not ClientState and not Remotes) or (not BuyUpgrade or not ClientState or (not ClientState or BuyUpgrade)) and (Remotes and ClientState or Remotes and not ClientState)) then
    iV = {}
else
    il = {}
end
for k, v in jm do
    iV[v] = k
end
iE, ip, iL, iB, ij = nil, nil, nil, nil, nil
iE = fn804
ip = fn392
iL = fn652
iB = fn580
ij = fn377
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = i9, Copyable = true }, "|", jk },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
local ji_1 = {
    Info = Window:AddTab("Info", "info"),
    Farming = Window:AddTab("Farming", "tractor"),
    Inventory = Window:AddTab("Inventory", "package"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
ji_1.Throwing = ji_1.Farming:AddSubTab("Throwing", "crosshair")
ji_1.Collection = ji_1.Farming:AddSubTab("Collection", "archive")
ji_1.Upgrades = ji_1.Inventory:AddSubTab("Upgrades", "arrow-up")
ji_1.Shop = ji_1.Inventory:AddSubTab("Shop", "shopping-cart")
for i, v in ipairs({ ji_1.Throwing, ji_1.Collection, ji_1.Upgrades, ji_1.Shop, ji_1.Player, ji_1.Settings }) do
    fn296(v)
end
iT, iH, Label, i5, iF, it = nil, nil, nil, nil, nil, nil
iF = fn145
it = fn828
local jp = "#7fd47f"
local jo = "#6ec1ff"
iT = "#e8a34d"
local jn = "#8b93a3"
iH = "Unknown"
pcall(fn33)
local AccountGroup = ji_1.Info:AddLeftGroupbox("Account", "circle-user")
AccountGroup:AddLabel(it("User", LocalPlayer.Name, jp), true)
AccountGroup:AddLabel(it("Status", "Keyless", jp), true)
AccountGroup:AddLabel(it("Executor", iH, jp), true)
local GameInfoGroup = ji_1.Info:AddLeftGroupbox("Game Info", "gamepad-2")
GameInfoGroup:AddLabel(iF(jk .. " [" .. tostring(game.PlaceId) .. "]", jo), true)
GameInfoGroup:AddLabel(it("Place ID", tostring(game.PlaceId), jo), true)
Label = GameInfoGroup:AddLabel(it("Session time", "0s", iT), true)
i5 = tostring(game.JobId)
local jm_1 = #i5 > 18
if jm_1 then
    local jf_3 = 2
    repeat
        if (jf_3 * 2 + 5) * 13 % 3 == ((jf_3 * 2 + 5) * 13 + 7) % 3 then
            i5 = string.sub(jm_1, 1, 18) .. "..."
        else
            jm_1 = string.sub(i5, 1, 18) .. "..."
        end
        jf_3 = (jf_3 + 1) % 4
    until (jf_3 * 3 + 0) % 4 == 1
end
local jf_4 = jm_1 or i5
iA, iw, is, io, je, jb, i8, i0, jx_1, StatUpgradesGroup, jD_1, jy_1, jw_1, CurrentCamera, iX, iR, connection, connection2, jr_1, iP, im, i_, iu, iv, iO, ix, iq = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
GameInfoGroup:AddLabel(it("Server", jf_4, jn), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
iA = os.clock()
task.spawn(worker)
local ScriptsGroup = ji_1.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(iF("Included in this hub", jn), true)
ScriptsGroup:AddLabel(iF(jk, jo), true)
local FeaturesGroup = ji_1.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(iF("Auto Throw", jo), true)
FeaturesGroup:AddLabel(iF("Auto Collect Income", jp), true)
FeaturesGroup:AddLabel(iF("Auto Upgrades & Shop", iT), true)
FeaturesGroup:AddLabel(iF("Auto Sell", jn), true)
local SocialsGroup = ji_1.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = ip })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = ji_1.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = ip })
iw = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
is = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
io = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
je = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
if (jy_1 or iP) and (jy_1 and not FeaturesGroup) and (jy_1 or not iP or (FeaturesGroup or not FeaturesGroup)) and ((not FeaturesGroup or FeaturesGroup) and (not FeaturesGroup and not jy_1) or (not FeaturesGroup and not jy_1 or (iP or not jy_1))) and not ((jy_1 or iP) and (jy_1 and not FeaturesGroup) and (jy_1 or not iP or (FeaturesGroup or not FeaturesGroup)) and ((not FeaturesGroup or FeaturesGroup) and (not FeaturesGroup and not jy_1) or (not FeaturesGroup and not jy_1 or (iP or not jy_1)))) then
else
    jb = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
end
i8 = ""
i0 = ""
local jF = "#345d9d"
local jB = "#f7931a"
if (false and (false or not jD_1) or (not jr_1 or not jD_1 or not jr_1 and jB)) and ((jD_1 or not jr_1) and (not jr_1 and jB) and "0xaE95A405D007a6F858E5d35714111B075fEFb40a") and not ((false and (false or not jD_1) or (not jr_1 or not jD_1 or not jr_1 and jB)) and ((jD_1 or not jr_1) and (not jr_1 and jB) and "0xaE95A405D007a6F858E5d35714111B075fEFb40a")) then
    io = "#627eea"
else
    jx_1 = "#627eea"
end
local ju = "#26a17b"
local jt = "#14f195"
local jm_2 = "#0070ba"
local jh_2 = "#008cff"
local DonationsGroup = ji_1.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(iF("All donations are optional but appreciated.", iT), true)
DonationsGroup:AddLabel(iF("If you donate you get a special role, just PING after you donate.", jp), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(iF("LTC / Litecoin", jF), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(iF("BTC / Bitcoin", jB), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(iF("ETH / Ethereum", jx_1), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(iF("USDT", ju), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(iF("Solana", jt), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(iF("PayPal", jm_2), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(iF("Venmo", jh_2), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(iF("Don't have any of the listed currencies but still wanna donate?", jn), true)
DonationsGroup:AddLabel(iF("DM me and we'll work something out.", jo), true)
local FaqGroup = ji_1.Info:AddRightGroupbox("FAQ", "circle-help")
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
local ThrowingGroup = ji_1.Throwing:AddLeftGroupbox("Throwing", "target")
ThrowingGroup:AddToggle("AutoThrow", { Text = "Auto Throw", Default = false })
ThrowingGroup:AddSlider("AutoThrowInterval", { Text = "Throw Interval", Default = 2, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
ThrowingGroup:AddToggle("PerfectThrow", { Text = "Perfect Throw", Default = false })
local IncomeGroup = ji_1.Collection:AddLeftGroupbox("Income", "coins")
if (ThrowingGroup and not DonationsGroup or (not jw_1 or jr_1)) and ((jw_1 or SocialsGroup) and (jw_1 and not ThrowingGroup)) and not ((ThrowingGroup and not DonationsGroup or (not jw_1 or jr_1)) and ((jw_1 or SocialsGroup) and (jw_1 and not ThrowingGroup))) then
    StatUpgradesGroup:AddToggle("AutoCollectIncome", { Text = "Auto Collect Income", Default = false })
    StatUpgradesGroup:AddSlider("AutoCollectIncomeInterval", { Suffix = "s", Rounding = 1, Min = 0.1, Max = 300, Text = "Collect Interval", Default = 10 })
    ji_1 = IncomeGroup.Upgrades:AddLeftGroupbox("Stat Upgrades", "bar-chart-2")
else
    IncomeGroup:AddToggle("AutoCollectIncome", { Text = "Auto Collect Income", Default = false })
    IncomeGroup:AddSlider("AutoCollectIncomeInterval", { Text = "Collect Interval", Default = 10, Min = 0.1, Max = 300, Rounding = 1, Suffix = "s" })
    StatUpgradesGroup = ji_1.Upgrades:AddLeftGroupbox("Stat Upgrades", "bar-chart-2")
end
StatUpgradesGroup:AddToggle("AutoUpgradeLuck", { Text = "Auto Upgrade Luck", Default = false })
StatUpgradesGroup:AddSlider("AutoUpgradeLuckInterval", { Text = "Upgrade Luck Interval", Default = 3, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
StatUpgradesGroup:AddToggle("AutoUpgradeValue", { Text = "Auto Upgrade Value", Default = false })
StatUpgradesGroup:AddSlider("AutoUpgradeValueInterval", { Text = "Upgrade Value Interval", Default = 3, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
local PurchasingGroup = ji_1.Shop:AddLeftGroupbox("Purchasing", "credit-card")
PurchasingGroup:AddToggle("AutoBuyBestCoin", { Text = "Auto Buy Best Coin", Default = false })
PurchasingGroup:AddSlider("AutoBuyBestCoinInterval", { Text = "Buy Interval", Default = 5, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
PurchasingGroup:AddToggle("AutoPlaceBestAnime", { Text = "Auto Place Best Anime", Default = false })
PurchasingGroup:AddSlider("AutoPlaceBestAnimeInterval", { Text = "Place Interval", Default = 3, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
local SellingGroup = ji_1.Shop:AddRightGroupbox("Selling", "tag")
SellingGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
SellingGroup:AddDropdown("AutoSellRarity", {
    Text = "Auto Sell By Rarity",
    Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret" },
    Default = {},
    Multi = true,
    SelectAllButtons = true
})
SellingGroup:AddSlider("AutoSellMinValue", { Text = "Min Income Threshold", Default = 0, Min = 0, Max = 10000, Rounding = 0 })
SellingGroup:AddToggle("AutoSellMutated", { Text = "Auto Sell Mutated Items", Default = false })
SellingGroup:AddSlider("AutoSellInterval", { Text = "Sell Interval", Default = 2, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
local function jv(bY, bZ, b_)
    Toggles[bY]:OnChanged(function()
        if not Toggles[bY].Value then
            return
        end
        task.spawn(function()
            while Toggles[bY].Value and not Library.Unloaded do
                pcall(b_)
                task.wait(math.max(Options[bZ].Value, 0.1))
            end
        end)
    end)
end
jv("AutoThrow", "AutoThrowInterval", fn472)
jv("PerfectThrow", "AutoThrowInterval", fn626)
iP = fn118
im = fn1
jv("AutoCollectIncome", "AutoCollectIncomeInterval", fn357)
jv("AutoUpgradeLuck", "AutoUpgradeLuckInterval", fn397)
jv("AutoUpgradeValue", "AutoUpgradeValueInterval", fn47)
jv("AutoBuyBestCoin", "AutoBuyBestCoinInterval", fn554)
jv("AutoPlaceBestAnime", "AutoPlaceBestAnimeInterval", fn54)
jv("AutoSell", "AutoSellInterval", fn787)
local MovementGroup = ji_1.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = ji_1.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn722)
Toggles.WalkSpeedEnabled:OnChanged(fn660)
i_ = function(d7)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not d7)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not d7
        end
    end)
    if not d7 then
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
Toggles.AntiGameplayPause:OnChanged(fn332)
task.spawn(antiGameplayPauseLoop)
local MenuGroup = ji_1.Settings:AddLeftGroupbox("Menu", "menu")
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
iX = tick()
iR = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local mT = v
        pcall(function()
            mT:Disable()
        end)
    end
end)
iu = fn372
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
task.spawn(antiAfkLoop)
Library:OnUnload(fn578)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Linoria")
ThemeManager:ApplyToTab(ji_1.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/ThrowAnAnimeCoin")
local jr_2 = SaveManager:BuildConfigSection(ji_1.Settings)
iv = fn288
iO = fn768
if (not FaqGroup or false) and (false or iP) and (jB and not FaqGroup or (false or iP)) and not ((not FaqGroup or false) and (false or iP) and (jB and not FaqGroup or (false or iP))) then
else
    ix = fn230
end
iq = function(fc)
    local nx
    nx = nil
    local ny = type(fc) ~= "table" or type(fc.idx) ~= "string" or type(fc.type) ~= "string" or SaveManager.Ignore[fc.idx]
    if ny then
        return false
    end
    nx = iv(fc.type, fc.idx)
    if not nx then
        return false
    end
    local ny_1 = pcall(function()
        if fc.type == "Input" then
            if type(fc.text) ~= "string" then
                return
            end
            nx:SetValue(fc.text)
        elseif fc.type == "ColorPicker" then
            nx:SetValueRGB(Color3.fromHex(fc.value), fc.transparency)
        elseif fc.type == "KeyPicker" then
            nx:SetValue({ fc.key, fc.mode, fc.modifiers })
            if fc.mode == "Toggle" and fc.toggled ~= nil then
                nx.Toggled = fc.toggled
                nx:Update()
            end
        else
            nx:SetValue(fc.value)
        end
    end)
    return ny_1
end
jr_2:AddDivider()
jr_2:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
jr_2:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
jr_2:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
end)(...)

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
getgenv().TempoHoodSubtitle = "BUILD A CART"
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
local s0_4, s0_6, s0_11, s0_17, GameInfoGroup, s0_25, s0_27, s0_29, s0_35, s0_39, s0_41
local k1
local Label
local l8
local k7
local Toggles
local lx
local me
local ld
local lW
local lD
local mk
local lj
local lJ
local mq
local connection2
local k6
local lP
local lw
local md
local lc
local lV
local lC
local mj
local li
local lI
local mp
local lo
local l6
local connection6
local lO
local mv
local lu
local mc
local lb
local lU
local lB
local mi
local lh
local l_
local lH
local RarityTiers
local lN
local mu
local lt
local HttpService
local DataUtil
local lT
local lA
local connection4
local Workspace
local lG
local mn
local connection5
local l4
local k3
local lM
local mt
local ls
local ma
local k9
local PlayerGui
local lz
local mg
local lf
local lY
local connection3
local ll
local l3
local k2
local lL
local MutationUtil
local l9
local k8
local lR
local ly
local VirtualUser
local connection
local lX
local lE
local UserInputService
function fns.fn8()
    return lW:GetAttribute("Launched") == true
end
function fns.fn15(ax, ay, az)
    return string.format("<b>%s</b> %s %s", ax, lj("-", "#5a6070"), lj(ay, az))
end
function fns.onCopyJoinScript_JobID()
    local eN = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, lC)
    lL(eN, "Copied join script to clipboard")
end
function fns.fn34(a8, a9)
    local nY = lI[a8]
    if nY == nil or nY.Value == nil then
        return a9
    end
    return nY.Value
end
function fns.fn57()
    local n7_1
    local n6_1
    n6_1, n7_1 = pcall(function()
        return DataUtil:GetPlayerData(lW)
    end)
    if n6_1 then
        return n7_1
    end
    return nil
end
function fns.onExportConfigToClipboard()
    local st_1
    local ss_1
    ss_1, st_1 = pcall(HttpService.JSONEncode, HttpService, lD())
    if not ss_1 then
        l9:Notify("Failed to encode the config")
        return
    end
    local ss_2 = setclipboard or toclipboard
    local ss_3 = type(ss_2) ~= "function"
    local sB = if ss_3 then 1 else 0
    local sz = 1096 * sB + 3779 * (1 - sB)
    local sA = 2743 * sB + 2523 * (1 - sB)
    if not ((sz * 3894 + sA * 2606 + sz * sA) % 16777213 == 14422410) then
        ss_3 = not pcall(ss_2, st_1)
    end
    if ss_3 then
        l9:Notify("Your executor does not support copying to the clipboard")
        return
    end
    l9:Notify("Config copied to clipboard", 6)
end
function fns.onInputChanged(gP)
    local UserInputType = gP.UserInputType
    local rH = UserInputType == Enum.UserInputType.MouseMovement
    local rL = if rH then 1 else 0
    local rJ = 2083 * rL + 1245 * (1 - rL)
    local rK = 1722 * rL + 1492 * (1 - rL)
    if not ((rJ * 656 + rK * 2702 + rJ * rK) % 16777213 == 9606218) then
        rH = UserInputType == Enum.UserInputType.Gamepad1
    end
    if rH then
        l8 = tick()
    end
end
function fns.fn76(ai, aj)
    return ai[1] < aj[1]
end
function fns.onCopyPayPalLink()
    lL(lR, "Copied PayPal link")
end
function fns.fn101()
    local rX = {}
    for i, v in ipairs({ Toggles, lI }) do
        for k, v in pairs(v) do
            local rY = type(v) == "table" and type(v.Type) == "string" and not lT.Ignore[k]
            if rY then
                local rY_1 = lX(k, v)
                if rY_1 then
                    rX[#rX + 1] = rY_1
                end
            end
        end
    end
    table.sort(rX, function(hi, hj)
        if hi.type ~= hj.type then
            return hi.type < hj.type
        end
        return hi.idx < hj.idx
    end)
    return { objects = rX }
end
function fns.fn122()
    local pz = {}
    local pA = mv()
    local pB = pA and pA.Gears and type(pA.Gears.Owned) == "table"
    if not pB then
        return pz
    end
    local pB_1 = lM()
    for k, v in pA.Gears.Owned do
        local pA_1 = type(k) == "string" and type(v) == "number" and v > 0 and not pB_1[k]
        if pA_1 then
            local pA_2 = lh(k)
            local pC = pA_2
            if pC then
                local pD = pA_2:GetAttribute("Fuel") or pA_2:GetAttribute("Speed")
                pC = pD
            end
            if pC then
                local pC_1 = tonumber(pA_2:GetAttribute("Price")) or 0
                local pC_2 = pC_1 > 0 and not k7(mn(k))
                if pC_2 then
                    local pN = 1
                    while pN <= v do
                        pz[#pz + 1] = k
                        pN += 1
                    end
                end
            end
        end
    end
    return pz
end
function fns.fn126()
    local n9 = mv()
    local oa = n9 and type(n9.Currency) == "table"
    if oa then
        local oa_1 = tonumber(n9.Currency.Currency1) or 0
        return oa_1
    end
    return 0
end
function fns.fn128()
    l9.ScreenGui.Parent = PlayerGui
end
function fns.fn171()
    local oi = lO()
    if not oi then
        return nil
    end
    local AllCartsModel = oi:FindFirstChild("AllCartsModel")
    if AllCartsModel and AllCartsModel.Name == "OldCart" then
        return nil
    end
    return AllCartsModel
end
function fns.onRenderStepped(gl)
    if l9.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local rp_1 = lo()
        if rp_1 then
            rp_1.WalkSpeed = lI.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local rp_3 = k9()
        local rq = lo()
        lz = Workspace.CurrentCamera or lz
        if rp_3 and rq and lz then
            rq.PlatformStand = true
            local rq_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                rq_1 = rq_1 + lz.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                rq_1 = rq_1 - lz.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                rq_1 = rq_1 - lz.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                rq_1 = rq_1 + lz.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                rq_1 = rq_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                rq_1 = rq_1 - Vector3.new(0, 1, 0)
            end
            rp_3.Velocity = Vector3.zero
            if rq_1.Magnitude > 0 then
                rp_3.CFrame = rp_3.CFrame + rq_1.Unit * lI.FlySpeed.Value * gl
            end
        end
    end
end
function fns.fn194(cD)
    local pb = lh(cD)
    if not pb then
        return nil
    end
    local pc = pb:GetAttribute("Rarity") or pb:GetAttribute("Tier")
    local pb_1 = tonumber(pc)
    if not pb_1 then
        return nil
    end
    local pc_1 = RarityTiers.Tiers[pb_1]
    local pb_2 = type(pc_1) == "table" and pc_1.Name
    return pb_2 or nil
end
function fns.fn199(cW)
    if type(cW) ~= "string" then
        return false
    end
    local px = mu("KeepRarities")
    return px[cW] == true
end
function fns.fn205()
    me(Toggles.AntiGameplayPause.Value)
end
function fns.fn211(ew)
    local DiscordGroup = ew:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = lu })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = lu })
end
function fns.fn235()
    lP()
    connection:Disconnect()
    connection2:Disconnect()
    connection3:Disconnect()
    connection4:Disconnect()
    connection5:Disconnect()
    connection6:Disconnect()
    me(false)
    local sX = lo()
    if sX then
        sX.PlatformStand = false
        sX.WalkSpeed = 16
    end
end
function fns.onJumpRequest()
    if l9.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local rk_1 = lo()
        if rk_1 then
            rk_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
function fns.fn244()
    local n0 = lw()
    local n1 = n0 and n0:FindFirstChildOfClass("Humanoid")
    return n1
end
function fns.fn265()
    local og_1
    local of_1
    of_1, og_1 = pcall(function()
        return k6:GetPlayerPlot(lW)
    end)
    if of_1 then
        return og_1
    end
    return nil
end
function fns.fn282(g4, g5)
    local Type = g5.Type
    if Type == "Toggle" then
        return { idx = g4, type = "Toggle", value = g5.Value == true }
    elseif Type == "Slider" then
        return { idx = g4, type = "Slider", value = tostring(g5.Value) }
    elseif Type == "Dropdown" then
        return { idx = g4, type = "Dropdown", multi = g5.Multi == true, value = g5.Value }
    elseif Type == "Input" then
        local rR = g5.Value or ""
        return { idx = g4, type = "Input", text = tostring(rR) }
    elseif Type == "ColorPicker" then
        return { idx = g4, type = "ColorPicker", value = g5.Value:ToHex(), transparency = g5.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = g4,
            type = "KeyPicker",
            mode = g5.Mode,
            key = g5.Value,
            modifiers = g5.Modifiers,
            toggled = g5.Toggled
        }
    else
        return nil
    end
end
local function onUnload()
    l9:Unload()
end
local function fn287()
    l9.ScreenGui.Parent = PlayerGui
end
local function worker4()
    while not l9.Unloaded do
        if ld("AutoBuyShop") then
            pcall(lE)
        end
        if ld("AutoBuyUpgrades") then
            pcall(mq)
        end
        if ld("AutoSpin") then
            pcall(mg)
        end
        if ld("AutoRebirth") then
            pcall(lG)
        end
        task.wait(0.6)
    end
end
local function fn310(gX, gY)
    local rN_1 = (gX == "Toggle" and Toggles or lI)[gY]
    local rM_2 = type(rN_1) == "table" and rN_1.Type == gX
    return rM_2 and rN_1 or nil
end
local function fn321()
    lL(lA, "Copied Discord invite to clipboard")
end
local function onCopySolanaAddress()
    lL(lU, "Copied Solana address")
end
local function fn381()
    local pX = mt()
    for k, v in pX do
        local pX_1 = l9.Unloaded or not ld("AutoSell")
        if pX_1 then
            return
        end
        k2:FireServer(v)
        task.wait(0.2)
    end
end
local function fn398(bN, ...)
    local oq = ll and ll.RemoteEvent
    if not oq then
        return
    end
    oq:FireServer(bN, ...)
end
local function fn400()
    local qy_1
    local qx_1
    local qw = false
    qx_1, qy_1 = pcall(function()
        return lc:CanWheelSpin(lW)
    end)
    if qx_1 then
        qw = qy_1 == true
    end
    if qw then
        lc.RemoteEvent:FireServer("WheelSpin")
    end
end
local function onImportConfigFromClipboardTex()
    local sH_1
    local sF = lI.SaveManager_ImportSource.Value or ""
    local sF_1
    local sG = tostring(sF):match("^%s*(.-)%s*$")
    if sG == "" then
        l9:Notify("Paste an exported config into the box first")
        return
    end
    sF_1, sH_1 = pcall(HttpService.JSONDecode, HttpService, sG)
    local sG_1 = not sF_1 or type(sH_1) ~= "table"
    local sL = if sG_1 then 1 else 0
    local sJ = 3410 * sL + 992 * (1 - sL)
    local sK = 2553 * sL + 1149 * (1 - sL)
    if not ((sJ * 4091 + sK * 236 + sJ * sK) % 16777213 == 6481335) then
        sG_1 = type(sH_1.objects) ~= "table"
    end
    if sG_1 then
        l9:Notify("That is not a valid exported config")
        return
    end
    local sF_2 = 0
    for i, v in ipairs(sH_1.objects) do
        if mp(v) then
            sF_2 += 1
        end
    end
    if sF_2 == 0 then
        l9:Notify("No settings in that config matched this script")
        return
    end
    lI.SaveManager_ImportSource:SetValue("")
    local sH_2 = sF_2 == 1 and "" or "s"
    l9:Notify(("Imported %d setting%s"):format(sF_2, sH_2), 6)
end
local function fn429()
    if not Toggles.WalkSpeedEnabled.Value then
        local ra = lo()
        if ra then
            ra.WalkSpeed = 16
        end
    end
end
local function onRscripts()
    lL(ly, "Copied Rscripts profile to clipboard")
end
local function fn450(cu)
    local o5_1
    if type(cu) ~= "string" then
        return nil
    end
    local o3 = MutationUtil
    local o3_1
    local o4 = cu
    if o3 then
        o3 = type(MutationUtil.GetBaseId) == "function"
    end
    if o3 then
        o3_1, o5_1 = pcall(MutationUtil.GetBaseId, MutationUtil, cu)
        local o6 = o3_1 and type(o5_1) == "string"
        if o6 then
            o4 = o5_1
        end
    end
    return mi:FindFirstChild(o4, true)
end
local function onStepped()
    if l9.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = lW.Character
        if Character then
            for i, descendant in Character:GetDescendants() do
                local rc_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if rc_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function onInputBegan()
    l8 = tick()
end
local function fn467(bU)
    if not bU then
        mc = nil
        l6 = nil
        return
    end
    if l6 ~= bU then
        l6 = bU
        local ov = tonumber(bU:GetAttribute("Speed")) or 50
        mc = ov
    end
end
local function onCopyBitcoinAddress()
    lL(l4, "Copied Bitcoin address")
end
local function worker3()
    while not l9.Unloaded do
        if lb() then
            pcall(mk)
        end
        task.wait(0.4)
    end
end
local function fn489()
    if not Toggles.Fly.Value then
        local q5 = lo()
        if q5 then
            q5.PlatformStand = false
        end
    end
end
local function onCopyVenmoLink()
    lL(lN, "Copied Venmo link")
end
local function fn526()
    local oW = (k3())
    local o_ = if oW then 1 else 0
    local oY = 1270 * o_ + 458 * (1 - o_)
    local oZ = 259 * o_ + 985 * (1 - o_)
    if not ((oY * 1342 + oZ * 3906 + oY * oZ) % 16777213 == 3044924) then
        oW = lW:GetAttribute("Reviving")
    end
    local o2 = if oW then 1 else 0
    local o0 = 2384 * o2 + 1316 * (1 - o2)
    local o1 = 3486 * o2 + 658 * (1 - o2)
    if not ((o0 * 111 + o1 * 543 + o0 * o1) % 16777213 == 10468146) then
        oW = lW:GetAttribute("Dying")
    end
    if oW then
        return
    end
    if os.clock() - lJ < 2 then
        return
    end
    lJ = os.clock()
    k1("Launch")
end
local function fn543(an, ao)
    if setclipboard then
        setclipboard(an)
    elseif toclipboard then
        toclipboard(an)
    end
    l9:Notify(ao)
end
local function fn555()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    l3 = tick()
end
local function fn568()
    local pe = {}
    local pf = mv()
    local pg = pf and pf.Carts and type(pf.Carts.Equipped) == "table"
    if not pg then
        return pe
    end
    for k, v in pf.Carts.Equipped do
        local pf_1 = type(v) == "table" and type(v.Gears) == "table"
        if pf_1 then
            for k, v in v.Gears do
                if type(v) == "string" then
                    pe[v] = true
                end
            end
        end
    end
    return pe
end
local function fn596()
    gethui = function()
        return PlayerGui
    end
end
local function fn601()
    if Toggles.AutoDrive.Value then
        if not k3() then
            lB()
        end
    else
        lP()
    end
end
local function onCopyEthereumAddress()
    lL(l_, "Copied Ethereum address")
end
local function fn655()
    local qI_1
    local qH_1
    if identifyexecutor then
        qI_1, qH_1 = identifyexecutor()
        local qJ = qI_1 ~= ""
        local qK = type(qI_1) == "string" and qJ
        if qK then
            local qJ_1 = type(qH_1) == "string" and qH_1 ~= "" and qI_1 .. " " .. qH_1
            md = qJ_1 or qI_1
        end
    end
end
local function antiAfkLoop()
    while not l9.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local sT = tick() - l8
            local sU = tick() - l3
            if sT >= 300 and sU >= 60 then
                pcall(lH)
            else
                if sT < 300 and sU >= 300 then
                    pcall(lH)
                end
            end
        end
    end
end
local function onHeartbeat()
    if l9.Unloaded then
        return
    end
    local qV = ld("AutoDrive") and k3()
    if qV then
        pcall(ls)
    end
end
local function fn692()
    return lW.Character
end
local function fn725()
    if not ld("AutoSell") then
        return false
    end
    local pT = mt()
    local pU = lV("AutoSellMode", lx)
    if pU == lt then
        local pU_1 = #pT
        local pV = tonumber(lV("AutoSellCount", 10)) or 10
        return pU_1 >= pV
    end
    return #pT > 0
end
local function fn726(a_)
    local nK = lI[a_]
    local nL = nK and nK.Value
    local nK_1 = {}
    if type(nL) ~= "table" then
        local nL_1 = nL ~= ""
        local nN = type(nL) == "string" and nL_1
        if nN then
            nK_1[nL] = true
        end
        return nK_1
    end
    for k, v in nL do
        local nL_2 = v == true
        local nM_1 = type(k) == "string" and nL_2
        if nM_1 then
            nK_1[k] = true
        elseif type(v) == "string" then
            nK_1[v] = true
        end
    end
    return nK_1
end
local function onCopyUSDTAddress()
    lL(lY, "Copied USDT address")
end
local function fn803(au, av)
    return string.format('<font color="%s">%s</font>', av, au)
end
local function fn856()
    local n3 = lw()
    local n4 = n3 and n3:FindFirstChild("HumanoidRootPart")
    return n4
end
local function fn867()
    local qC_1
    local qB_1
    local qA = false
    qB_1, qC_1 = pcall(function()
        return lf:CanRebirth(lW)
    end)
    if qB_1 then
        qA = qC_1 == true
    end
    if qA then
        lf.RemoteEvent:FireServer("Rebirth")
    end
end
local function worker2()
    while not l9.Unloaded do
        local qQ = ld("AutoDrive") and k3()
        if qQ then
            pcall(ls)
        end
        task.wait(0.15)
    end
end
local function onCopyLitecoinAddress()
    lL(ma, "Copied Litecoin address")
end
local function antiGameplayPauseLoop()
    while not l9.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            me(true)
        end
    end
end
local function fn970()
    if l6 and mc then
        pcall(function()
            l6:SetAttribute("Speed", mc)
        end)
    end
    mc = nil
    l6 = nil
end
local function worker()
    local qN_1
    while true do
        task.wait(1)
        if l9.Unloaded then
            break
        end
        local qM = math.floor(os.clock() - li)
        if qM < 60 then
            qN_1 = qM .. "s"
        elseif qM < 3600 then
            qN_1 = string.format("%dm %ds", math.floor((qM) / (60)), qM % 60)
        else
            qN_1 = string.format("%dh %dm", math.floor((qM) / (3600)), math.floor((qM % 3600) / (60)))
        end
        Label:SetText(k8("Session time", qN_1, mj))
    end
end
local function fn990(aU)
    if l9.Unloaded then
        return false
    end
    local nE = Toggles[aU]
    return nE ~= nil and nE.Value == true
end
k1 = nil
k2 = nil
k3 = nil
RarityTiers = nil
connection6 = nil
k6 = nil
k7 = nil
k8 = nil
k9 = nil
DataUtil = nil
lb = nil
lc = nil
ld = nil
connection = nil
lf = nil
lh = nil
li = nil
lj = nil
ll = nil
connection5 = nil
lo = nil
MutationUtil = nil
ls = nil
lt = nil
lu = nil
lw = nil
lx = nil
ly = nil
lz = nil
lA = nil
lB = nil
lC = nil
lD = nil
lE = nil
connection3 = nil
lG = nil
lH = nil
lI = nil
lJ = nil
Label = nil
lL = nil
lM = nil
lN = nil
lO = nil
lP = nil
local lg, lk, ln, GearUtil, lq
Toggles = nil
lR = nil
PlayerGui = nil
lT = nil
lU = nil
lV = nil
lW = nil
lX = nil
lY = nil
Workspace = nil
l_ = nil
l3 = nil
l4 = nil
l6 = nil
connection2 = nil
l8 = nil
l9 = nil
ma = nil
HttpService = nil
mc = nil
md = nil
me = nil
VirtualUser = nil
mg = nil
connection4 = nil
mi = nil
mj = nil
mk = nil
UserInputService = nil
mn = nil
mp = nil
mq = nil
mt = nil
mu = nil
mv = nil
local l0, CoreGui, l2, GuiService, GetPlayerUpgrades, mo, mr, ms
l0 = nil
CoreGui = nil
l2 = nil
GuiService = nil
GetPlayerUpgrades = nil
mo = nil
mr = nil
ms = nil
UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, lW, PlayerGui = nil, nil, nil, nil, nil, nil, nil, nil
local s0_20 = game:GetService("Players")
local s0_36 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
lW = s0_20.LocalPlayer
PlayerGui = lW:WaitForChild("PlayerGui")
if getgenv then
    getgenv().gethui = function()
        return PlayerGui
    end
end
s0_25, s0_6, MutationUtil, GearUtil, ll, lf, lc, DataUtil, k6, RarityTiers, k2, mr, mo, GetPlayerUpgrades, mi, s0_39, l9 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local s0_8 = 15
repeat
    s0_11 = (s0_8 * 7 + 6) % 9 + 1
    if s0_11 <= 5 then
        if s0_11 <= 3 then
            if s0_11 <= 2 then
                if s0_11 <= 1 then
                    if not ll and false and (MutationUtil or k2) or (not k2 or GetPlayerUpgrades) and (not MutationUtil or mr) or (MutationUtil and false or k2 and MutationUtil or (not k2 and not mr or not mr and s0_25)) or (s0_25 and GetPlayerUpgrades and (not ll and mr) or (false or k2) and (not GetPlayerUpgrades or ll)) and (MutationUtil or mr or not k2 and MutationUtil or (not mr or GetPlayerUpgrades) and (not GetPlayerUpgrades and s0_25)) or not (not ll and false and (MutationUtil or k2) or (not k2 or GetPlayerUpgrades) and (not MutationUtil or mr) or (MutationUtil and false or k2 and MutationUtil or (not k2 and not mr or not mr and s0_25)) or (s0_25 and GetPlayerUpgrades and (not ll and mr) or (false or k2) and (not GetPlayerUpgrades or ll)) and (MutationUtil or mr or not k2 and MutationUtil or (not mr or GetPlayerUpgrades) and (not GetPlayerUpgrades and s0_25))) then
                        s0_20 = s0_36:WaitForChild("Remotes")
                        k2 = s0_20:WaitForChild("SellItemEvent")
                        mr = s0_20:WaitForChild("BuyUpgrade")
                        mo = s0_20:WaitForChild("GetUpgradeStats")
                        GetPlayerUpgrades = s0_20:WaitForChild("GetPlayerUpgrades")
                    else
                        mo = GetPlayerUpgrades:WaitForChild("Remotes")
                        mo:WaitForChild("SellItemEvent")
                        k2 = mo:WaitForChild("BuyUpgrade")
                        s0_36 = mo:WaitForChild("GetUpgradeStats")
                        mr = mo:WaitForChild("GetPlayerUpgrades")
                    end
                    s0_8 = (s0_8 + 31) % 36
                else
                    if s0_8 * 82728897 + 2 + 5 >= s0_8 * 82728897 + 2 + 5 + 4 then
                        s0_36 = s0_39:WaitForChild("Assets"):WaitForChild("Gears")
                        l9 = ""
                        mi = getgenv().Library
                    else
                        mi = s0_36:WaitForChild("Assets"):WaitForChild("Gears")
                        s0_39 = ""
                        l9 = getgenv().Library
                    end
                    s0_8 = (s0_8 + 22) % 36
                end
            else
                s0_41 = {
                    "dmqblcrv",
                    "aoiqnx",
                    "bzrubmea",
                    "malpqxlax",
                    "gtevz",
                    "dgzivwf",
                    "efwcwoxc",
                    "ukvdvy",
                    "lpwdxgzwbrh",
                    "qagwzhyvuhc",
                    "hhcikk"
                }
                local t2 = s0_8
                s0_27 = s0_41[t2 % 11 + 1]
                if s0_27:len() <= s0_27:reverse():rep(t2 % 3 + 2):len() then
                    pcall(fns.fn128)
                else
                    pcall(fns.fn128)
                end
                s0_8 = (s0_8 + 31) % 36
            end
        elseif s0_11 <= 4 then
            local tu = bit32.rrotate(bit32.bxor(bit32.lrotate(s0_8, 9), string.byte(tostring(ll))), 11)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(tu, 581827057), 1537715370), (bit32.bxor(bit32.band(tu, 3713140238), 3653187548))), 1537715370), 3653187548) == tu then
                pcall(fn596)
                s0_25 = "Build A Cart"
            else
                pcall(fn596)
                ll = "Build A Cart"
            end
            s0_8 = (s0_8 + 4) % 36
        else
            local tJ = bit32.rrotate(bit32.bxor(bit32.lrotate(s0_8, 20), string.byte(tostring(mr))), 14)
            if bit32.bxor(bit32.lrotate(bit32.bxor(tJ, 3978683819), 18), 2528097431) == bit32.lrotate(tJ, 18) then
                s0_6 = require(s0_36:WaitForChild("Framework"))
            else
                s0_36 = require(s0_6:WaitForChild("Framework"))
            end
            s0_8 = (s0_8 + 22) % 36
        end
    elseif s0_11 <= 7 then
        if s0_11 <= 6 then
            s0_41 = (vector.create((s0_8 * 4 + 5) % 11 + 1, (s0_8 * 10 + 10) % 13 + 1, (s0_8 * 6 + 15) % 17 + 1))
            local tB = vector.floor(s0_41) + vector.ceil(s0_41 * -1)
            if vector.dot(tB, tB) == 3 then
                s0_6 = MutationUtil.Modules.MutationUtil
            else
                MutationUtil = s0_6.Modules.MutationUtil
            end
            s0_8 = (s0_8 + 4) % 36
        else
            s0_41 = {
                "jwsscmhjvgzm",
                "fgs",
                "vfnahwldqcty",
                "upnfetbresa",
                "uiniktxynq",
                "ntjndmf",
                "qvcdto",
                "bjymfv",
                "emabthimo",
                "alqeimr",
                "cpurkstkg",
                "ufjqc",
                "nsznk",
                "bocn",
                "ocop",
                "wwtk"
            }
            if s0_41[(s0_8 * 75 + 2) % 16 + 1] <= s0_41[(s0_8 * 75 + 2) % 16 + 1] then
                GearUtil = s0_6.Modules.GearUtil
                ll = s0_6.Modules.LaunchUtil
                lf = s0_6.Modules.RebirthUtil
            else
                s0_6 = GearUtil.Modules.GearUtil
                lf = GearUtil.Modules.LaunchUtil
                ll = GearUtil.Modules.RebirthUtil
            end
            s0_8 = (s0_8 + 31) % 36
        end
    elseif s0_11 <= 8 then
        s0_11 = (vector.create((s0_8 * 3 + 5) % 11 + 1, (s0_8 * 6 + 6) % 13 + 1, (s0_8 * 9 + 4) % 17 + 1))
        s0_41 = (vector.create((s0_8 * 2 + 7) % 11 + 1, (s0_8 * 10 + 11) % 13 + 1, (s0_8 * 4 + 1) % 17 + 1))
        local tx = vector.cross(s0_11, s0_41)
        local ty = vector.dot(s0_11, s0_41)
        if vector.dot(tx, tx) + ty * ty == vector.dot(s0_11, s0_11) * vector.dot(s0_41, s0_41) + 5 then
            s0_6 = DataUtil.Modules.SpinsUtil
            lc = DataUtil.Modules.DataUtil
        else
            lc = s0_6.Modules.SpinsUtil
            DataUtil = s0_6.Modules.DataUtil
        end
        s0_8 = (s0_8 + 31) % 36
    else
        if s0_8 * 118912725 + 11 + 4 >= s0_8 * 118912725 + 11 + 4 + 6 then
            s0_6 = RarityTiers.Modules.PlotsUtil
            k6 = RarityTiers.Modules.RarityTiers
        else
            k6 = s0_6.Modules.PlotsUtil
            RarityTiers = s0_6.Modules.RarityTiers
        end
        s0_8 = (s0_8 + 22) % 36
    end
until (s0_8 * 11 + 28) % 36 == 31
if setthreadidentity then
    setthreadidentity(8)
end
s0_6, lT, Toggles, lI, lA, ly, lx, lt, lq, ln, lg = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
s0_20 = 8
repeat
    s0_36 = (s0_20 * 2 + 1) % 3 + 1
    if s0_36 <= 2 then
        if s0_36 <= 1 then
            if s0_20 * 4987803 + 11 + 3 >= s0_20 * 4987803 + 11 + 3 + 1 then
                ly = "https://discord.gg/K7Qxnxkk46"
                lA = "https://discord.gg/K7Qxnxkk46"
                lt = "Always"
                lx = "Count"
            else
                lA = "https://discord.gg/K7Qxnxkk46"
                ly = "https://discord.gg/K7Qxnxkk46"
                lx = "Always"
                lt = "Count"
            end
            s0_20 = (s0_20 + 17) % 24
        else
            s0_36 = (vector.create((s0_20 * 7 + 7) % 11 + 1, (s0_20 * 5 + 10) % 13 + 1, (s0_20 * 3 + 10) % 17 + 1))
            s0_8 = (vector.create((s0_20 * 3 + 2) % 11 + 1, (s0_20 * 2 + 9) % 13 + 1, (s0_20 * 3 + 4) % 17 + 1))
            s0_11 = (vector.create((s0_20 * 5 + 4) % 11 + 1, (s0_20 * 7 + 1) % 13 + 1, (s0_20 * 8 + 4) % 17 + 1))
            if vector.dot(vector.cross(s0_36, s0_8), s0_11) == vector.dot(vector.cross(s0_8, s0_11), s0_36) then
                lq = { "Distance Per Currency", "Currency Multiplier", "Currency" }
                ln = {
                    ["Distance Per Currency"] = "DPC",
                    ["Currency Multiplier"] = "CurrencyMulti",
                    Currency = "CurrencyBuff"
                }
                lg = {}
            else
                lg = { "Currency", "Currency Multiplier", "Distance Per Currency" }
                lq = {
                    ["Distance Per Currency"] = "DPC",
                    ["Currency Multiplier"] = "CurrencyMulti",
                    Currency = "CurrencyBuff"
                }
                ln = {}
            end
            s0_20 = (s0_20 + 23) % 24
        end
    else
        if (s0_20 * 2 + 5) * 7 % 3 == ((s0_20 * 2 + 5) * 7 + 5) % 3 then
            lI = getgenv().ThemeManager
            l9 = getgenv().SaveManager
            s0_39 = Toggles.Toggles
            s0_6 = Toggles.Options
        else
            s0_6 = getgenv().ThemeManager
            lT = getgenv().SaveManager
            Toggles = l9.Toggles
            lI = l9.Options
        end
        s0_20 = (s0_20 + 20) % 24
    end
until (s0_20 * 13 + 12) % 24 == 8
s0_36 = {}
for i, child in mi:GetChildren() do
    for i, child in child:GetChildren() do
        s0_20 = not s0_36[child.Name]
        if s0_20 ~= false then
            s0_20 = typeof(child:GetAttribute("Price")) == "number"
        end
        if s0_20 then
            s0_36[child.Name] = true
            lg[#lg + 1] = child.Name
        end
    end
end
table.sort(lg)
s0_20 = {}
s0_36 = RarityTiers.Tiers
if type(s0_36) == "table" then
    s0_8 = {}
    for k, v in s0_36 do
        s0_36 = tonumber(k)
        s0_39 = s0_36 and type(v) == "table" and type(v.Name) == "string"
        if s0_39 then
            s0_8[#s0_8 + 1] = { s0_36, v.Name }
        end
    end
    s0_39 = 3
    repeat
        s0_36 = {
            "ozsfwckqaf",
            "lshuiyqad",
            "jgmkj",
            "sqtg",
            "thfwjesme",
            "gyyldgyjnqy",
            "uwxhcp",
            "rsuvyes",
            "tkdqjtmf"
        }
        if s0_36[(s0_39 * 36 + 77) % 9 + 1] <= s0_36[(s0_39 * 36 + 77) % 9 + 1] then
            table.sort(s0_8, fns.fn76)
        else
            table.sort(s0_8, fns.fn76)
        end
        s0_39 = (s0_39 + 2) % 8
    until (s0_39 * 3 + 5) % 8 == 4
    for k, v in s0_8 do
        s0_20[#s0_20 + 1] = v[2]
    end
end
if #s0_20 == 0 then
    s0_36 = 2
    repeat
        s0_8 = {
            "nfvltei",
            "nclssikkipk",
            "rsii",
            "hcuwxzkuggmy",
            "xynrs",
            "hkobrnkisq",
            "uqu",
            "zocgbkpteyq",
            "chreqekwk"
        }
        if s0_8[(s0_36 * 90 + 41) % 9 + 1] < s0_8[(s0_36 * 90 + 41) % 9 + 1] then
            s0_20 = {
                "Divine",
                "Common",
                "Rare",
                "Mythic",
                "Transcendent",
                "Infinite",
                "Legendary",
                "Pinnacle",
                "Secret",
                "Eternal",
                "Epic",
                "Heavenly"
            }
        else
            s0_20 = {
                "Common",
                "Rare",
                "Epic",
                "Legendary",
                "Mythic",
                "Divine",
                "Secret",
                "Heavenly",
                "Pinnacle",
                "Transcendent",
                "Eternal",
                "Infinite"
            }
        end
        s0_36 = (s0_36 + 0) % 8
    until (s0_36 * 3 + 1) % 8 == 7
end
mj, ma, l4, l_, lY, lU, lR, lN, s0_29, s0_27, mc, l6, lJ, lL, lu, lj, k8, ld, mu, lV, lw, lo, k9, mv, l0, lO, lk, k3, k1, l2, lP, ls, lB, lh, mn, lM, k7, mt, lb, mk, lE, mq, mg, lG = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
lL = fn543
lu = fn321
lj = fn803
k8 = fns.fn15
local s0_33 = "#7fd47f"
local s0_3 = "#6ec1ff"
mj = "#e8a34d"
if (mg or false) and (mv or not mv) and ((not mv or mg) and (not lP and not s0_27)) and ((not mv or lP) and (s0_27 and not lP) or not mg and not s0_27 and (not lP or not s0_27)) or (s0_29 and not s0_27 or (mv or s0_29)) and ((not lP or s0_29) and (s0_29 or not lP)) and (not mg and not lP and (not mv and not lP) and (not mg and not mv and (not lP or s0_27))) or not ((mg or false) and (mv or not mv) and ((not mv or mg) and (not lP and not s0_27)) and ((not mv or lP) and (s0_27 and not lP) or not mg and not s0_27 and (not lP or not s0_27)) or (s0_29 and not s0_27 or (mv or s0_29)) and ((not lP or s0_29) and (s0_29 or not lP)) and (not mg and not lP and (not mv and not lP) and (not mg and not mv and (not lP or s0_27)))) then
    s0_17 = "#8b93a3"
    ma = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
    l4 = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
else
    l4 = "#8b93a3"
    s0_17 = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
    ma = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
end
l_ = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
lY = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
lU = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
lR = ""
lN = ""
local s0_32 = "#345d9d"
local s0_1 = "#f7931a"
local s0_16 = "#627eea"
s0_29 = "#26a17b"
local s0_44 = "#14f195"
local s0_13 = "#0070ba"
s0_27 = "#008cff"
if (not mn or false) and (mn and not mv) and (not mv or s0_27 or (not mg or not mn)) or not ((not mn or false) and (mn and not mv) and (not mv or s0_27 or (not mg or not mn))) then
    ld = fn990
    mu = fn726
    lV = fns.fn34
    lw = fn692
else
    lw = fn990
    lV = fn726
    ld = fns.fn34
    mu = fn692
end
lo = fns.fn244
k9 = fn856
mv = fns.fn57
l0 = fns.fn126
lO = fns.fn265
lk = fns.fn171
k3 = fns.fn8
k1 = fn398
mc = nil
l6 = nil
l2 = fn467
lP = fn970
ls = function()
    local oz
    oz = nil
    oz = lk()
    local oB = oz and k3()
    if not oB then
        return
    end
    l2(oz)
    local oB_1 = tonumber(lV("DriveSpeed", 4)) or 4
    local oC_1
    local max = math.max
    local oD = mc or 50
    local oD_1
    local oE = max(oD * oB_1, 20)
    oz:SetAttribute("Speed", oE)
    local VehicleSeat = oz:FindFirstChildWhichIsA("VehicleSeat", true)
    if VehicleSeat then
        VehicleSeat.Throttle = 1
        pcall(function()
            VehicleSeat.ThrottleFloat = 1
        end)
    end
    local oB_3 = {}
    oC_1, oD_1 = pcall(function()
        return oz:QueryDescendants("LinearVelocity")
    end)
    local oF = oC_1 and type(oD_1) == "table"
    if oF then
        oB_3 = oD_1
    else
        for i, descendant in oz:GetDescendants() do
            if descendant:IsA("LinearVelocity") then
                oB_3[#oB_3 + 1] = descendant
            end
        end
    end
    for k, v in oB_3 do
        v.VectorVelocity = Vector3.new(0, 0, -oE * 1.25)
    end
end
if (false or not lM) and (lM or false) or mq and mq and (not lM and not lM) or not ((false or not lM) and (lM or false) or mq and mq and (not lM and not lM)) then
    lJ = 0
    lB = fn526
    lh = fn450
    mn = fns.fn194
else
    lh = 0
    lJ = fn526
    mn = fn450
    lB = fns.fn194
end
lM = fn568
k7 = fns.fn199
mt = fns.fn122
lb = fn725
if ((lV or k8) and (not s0_17 or l4) and (not k8 and not k8 or (l4 or false)) or (not k8 or lV) and (s0_17 or false) and (k8 or s0_13 or (not lV or k8))) and not ((lV or k8) and (not s0_17 or l4) and (not k8 and not k8 or (l4 or false)) or (not k8 or lV) and (s0_17 or false) and (k8 or s0_13 or (not lV or k8))) then
    s0_32 = fn381
else
    mk = fn381
end
lE = function()
    local p7_1
    local p6_1
    local p4 = mu("AutoBuyShopItems")
    if next(p4) == nil then
        return
    end
    for k, v in lg do
        local qe = v
        if p4[qe] then
            local p5 = false
            p6_1, p7_1 = pcall(function()
                return GearUtil:CanBuyGear(lW, qe)
            end)
            if p6_1 then
                p5 = p7_1 == true
            end
            if p5 then
                GearUtil.RemoteEvent:FireServer("BuyGear", qe)
                task.wait(0.2)
            end
        end
    end
end
mq = function()
    local ql_1
    local qk_1
    local qj_1, qj_4
    local qh = mu("AutoBuyUpgrade")
    local qi
    qj_1, qk_1 = pcall(function()
        return GetPlayerUpgrades:InvokeServer()
    end)
    if qj_1 then
        qi = qk_1
    end
    if type(qi) ~= "table" then
        return
    end
    for k, v in lq do
        local qf, qg
        if qh[v] then
            qf = ln[v]
            local qj_2 = qi[qf]
            local qk_2 = type(qj_2) == "table" and #qj_2
            qg = qk_2 or 0
            local qk_3 = nil
            qj_4, ql_1 = pcall(function()
                return mo:InvokeServer(qf, qg)
            end)
            if qj_4 then
                qk_3 = ql_1
            end
            local qj_5 = type(qk_3) == "table" and type(qk_3.Cost) == "number" and l0() >= qk_3.Cost
            if qj_5 then
                pcall(function()
                    mr:InvokeServer(qf)
                end)
                task.wait(0.25)
            end
        end
    end
end
mg = fn400
lG = fn867
s0_8 = l9:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = lA, Copyable = true }, "|", s0_25 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
pcall(fn287)
s0_41 = {
    Info = s0_8:AddTab("Info", "info"),
    Main = s0_8:AddTab("Main", "gauge"),
    Player = s0_8:AddTab("Player", "person-standing"),
    Settings = s0_8:AddTab("Settings", "settings")
}
s0_11 = fns.fn211
for k, v in s0_41 do
    s0_11(v)
end
md, GameInfoGroup, Label, lC, s0_39 = nil, nil, nil, nil, nil
s0_8 = 4
repeat
    s0_11 = (s0_8 * 2 + 2) % 3 + 1
    if s0_11 <= 2 then
        if s0_11 <= 1 then
            if s0_8 * 67132555 + 9 + 3 >= s0_8 * 67132555 + 9 + 3 + 1 then
                lC = #s0_39 > 18
            else
                s0_39 = #lC > 18
            end
            s0_8 = (s0_8 + 2) % 24
        else
            s0_11 = (vector.create((s0_8 * 6 + 3) % 11 + 1, (s0_8 * 9 + 2) % 13 + 1, (s0_8 * 4 + 5) % 17 + 1))
            s0_4 = (vector.create((s0_8 * 2 + 4) % 11 + 1, (s0_8 * 11 + 13) % 13 + 1, (s0_8 * 2 + 15) % 17 + 1))
            s0_35 = (vector.create((s0_8 * 6 + 7) % 11 + 1, (s0_8 * 9 + 3) % 13 + 1, (s0_8 * 9 + 3) % 17 + 1))
            if vector.dot(vector.cross(s0_11, s0_4), s0_35) == vector.dot(vector.cross(s0_4, s0_35), s0_11) + 3 then
                s0_41 = "Unknown"
                pcall(fn655)
                s0_3 = GameInfoGroup.Info:AddLeftGroupbox("Account", "circle-user")
                s0_3:AddLabel(mj("User", Label.Name, lj), true)
                s0_3:AddLabel(mj("Status", "Keyless", lj), true)
                s0_3:AddLabel(mj("Executor", "Unknown", lj), true)
                s0_36 = GameInfoGroup.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                s0_36:AddLabel(k8(s0_33 .. " [" .. tostring(game.PlaceId) .. "]", s0_25), true)
                s0_36:AddLabel(mj("Place ID", tostring(game.PlaceId), s0_25), true)
                lW = s0_36:AddLabel(mj("Session time", "0s", md), true)
            else
                md = "Unknown"
                pcall(fn655)
                s0_36 = s0_41.Info:AddLeftGroupbox("Account", "circle-user")
                s0_36:AddLabel(k8("User", lW.Name, s0_33), true)
                s0_36:AddLabel(k8("Status", "Keyless", s0_33), true)
                s0_36:AddLabel(k8("Executor", md, s0_33), true)
                GameInfoGroup = s0_41.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                GameInfoGroup:AddLabel(lj(s0_25 .. " [" .. tostring(game.PlaceId) .. "]", s0_3), true)
                GameInfoGroup:AddLabel(k8("Place ID", tostring(game.PlaceId), s0_3), true)
                Label = GameInfoGroup:AddLabel(k8("Session time", "0s", mj), true)
            end
            s0_8 = (s0_8 + 5) % 24
        end
    else
        s0_11 = {
            "urhrqzsn",
            "szzlhic",
            "ctztzcf",
            "uyiwkcvge",
            "xqluiug",
            "ers",
            "xuuztra",
            "wily",
            "rgigxvgw",
            "brzla",
            "moh",
            "ptdrohwas"
        }
        local t6 = s0_8
        s0_4 = s0_11[t6 % 12 + 1]
        if s0_4:len() <= s0_4:gsub("(.)", "%1%1", t6 % 3 % 2 + 1):len() then
            lC = tostring(game.JobId)
        else
            md = tostring(game.JobId)
        end
        s0_8 = (s0_8 + 14) % 24
    end
until (s0_8 * 11 + 5) % 24 == 16
if s0_39 then
    s0_36 = 0
    repeat
        s0_8 = {
            "lpynsoqtwq",
            "qabjusjww",
            "digaqal",
            "enkykrn",
            "qxziwilekt",
            "fxlrr",
            "dcgfw",
            "icugwfgn",
            "idvkqshsvi",
            "jssparyaofh",
            "qjwnvmlg"
        }
        local tq = s0_36
        s0_11 = s0_8[tq % 11 + 1]
        if s0_11:len() >= s0_11:reverse():rep(tq % 3 + 2):len() then
            lC = string.sub(s0_39, 1, 18) .. "..."
        else
            s0_39 = string.sub(lC, 1, 18) .. "..."
        end
        s0_36 = (s0_36 + 3) % 8
    until (s0_36 * 3 + 6) % 8 == 7
end
s0_36 = s0_39 or lC
li, s0_11, connection, connection2, connection3, lz, connection4, l8, l3, connection5, connection6, s0_8, me, lH, ms, lX, lD, mp = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
s0_35 = s0_36
GameInfoGroup:AddLabel(k8("Server", s0_35, s0_17), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
li = os.clock()
task.spawn(worker)
local ScriptsGroup = s0_41.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(lj("Included in this hub", s0_17), true)
ScriptsGroup:AddLabel(lj(s0_25, s0_3), true)
local FeaturesGroup = s0_41.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(lj("Auto Farm", s0_3), true)
FeaturesGroup:AddLabel(lj("Auto Sell", mj), true)
FeaturesGroup:AddLabel(lj("Auto Buy", s0_17), true)
local SocialsGroup = s0_41.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = lu })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = s0_41.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = lu })
local DonationsGroup = s0_41.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(lj("All donations are optional but appreciated.", mj), true)
DonationsGroup:AddLabel(lj("If you donate you get a special role, just PING after you donate.", s0_33), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(lj("LTC / Litecoin", s0_32), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(lj("BTC / Bitcoin", s0_1), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(lj("ETH / Ethereum", s0_16), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(lj("USDT", s0_29), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(lj("Solana", s0_44), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(lj("PayPal", s0_13), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = fns.onCopyPayPalLink })
DonationsGroup:AddLabel(lj("Venmo", s0_27), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(lj("Don't have any of the listed currencies but still wanna donate?", s0_17), true)
DonationsGroup:AddLabel(lj("DM me and we'll work something out.", s0_3), true)
s0_4 = s0_41.Info:AddRightGroupbox("FAQ", "circle-help")
if ((not lz or lz) and (s0_8 and not s0_8) or not lz and not lz and (lz and s0_8) or (not lz and not lz and (not lz or s0_8) or (not s0_8 or s0_8) and (s0_8 and not lz))) and not ((not lz or lz) and (s0_8 and not s0_8) or not lz and not lz and (lz and s0_8) or (not lz and not lz and (not lz or s0_8) or (not s0_8 or s0_8) and (s0_8 and not lz))) then
    s0_11:AddLabel("Where do I get a good config?", true)
    s0_11:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
    s0_11:AddLabel("How do I import / export configs?", true)
    s0_11:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
    s0_11:AddLabel("How do I report bugs?", true)
    s0_11:AddLabel("Join the Discord and post it in the bugs channel.", true)
    s0_11:AddLabel("How do I make suggestions?", true)
    s0_11:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
    s0_11:AddLabel("How do I get help or updates?", true)
    s0_11:AddLabel("Join the Discord, updates and support are posted there first.", true)
    s0_41 = s0_4.Main:AddLeftGroupbox("Drive", "gauge")
else
    s0_4:AddLabel("Where do I get a good config?", true)
    s0_4:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
    s0_4:AddLabel("How do I import / export configs?", true)
    s0_4:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
    s0_4:AddLabel("How do I report bugs?", true)
    s0_4:AddLabel("Join the Discord and post it in the bugs channel.", true)
    s0_4:AddLabel("How do I make suggestions?", true)
    s0_4:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
    s0_4:AddLabel("How do I get help or updates?", true)
    s0_4:AddLabel("Join the Discord, updates and support are posted there first.", true)
    s0_11 = s0_41.Main:AddLeftGroupbox("Drive", "gauge")
end
s0_11:AddToggle("AutoDrive", { Text = "Auto Drive", Default = false })
s0_11:AddSlider("DriveSpeed", { Text = "Drive Speed", Default = 4, Min = 1, Max = 100, Rounding = 1 })
s0_39 = s0_41.Main:AddLeftGroupbox("Sell", "circle-dollar-sign")
s0_39:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
s0_39:AddDropdown("AutoSellMode", { Text = "When", Values = { lx, lt }, Default = lx })
s0_39:AddSlider("AutoSellCount", { Text = "Item Count", Default = 10, Min = 1, Max = 200, Rounding = 0 })
s0_39:AddDropdown("KeepRarities", {
    Text = "Keep Rarities",
    Values = s0_20,
    Default = {},
    Multi = true,
    Expandable = true,
    ExpandColumns = 2
})
local ShopGroup = s0_41.Main:AddRightGroupbox("Shop", "shopping-bag")
ShopGroup:AddToggle("AutoBuyShop", { Text = "Auto Buy Shop", Default = false })
ShopGroup:AddDropdown("AutoBuyShopItems", { Text = "Items", Values = lg, Default = {}, Multi = true, Expandable = true, ExpandColumns = 2 })
local UpgradesGroup = s0_41.Main:AddRightGroupbox("Upgrades", "trending-up")
UpgradesGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Cart Upgrades", Default = false })
UpgradesGroup:AddDropdown("AutoBuyUpgrade", {
    Text = "Upgrade",
    Values = lq,
    Default = { "Distance Per Currency", "Currency Multiplier", "Currency" },
    Multi = true,
    Expandable = true,
    ExpandColumns = 1
})
local MiscGroup = s0_41.Main:AddRightGroupbox("Misc", "sparkles")
MiscGroup:AddToggle("AutoSpin", { Text = "Auto Spin Wheel", Default = false })
MiscGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
local MovementGroup = s0_41.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = s0_41.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
Toggles.AutoDrive:OnChanged(fn601)
task.spawn(worker2)
connection = RunService.Heartbeat:Connect(onHeartbeat)
task.spawn(worker3)
task.spawn(worker4)
me = function(fO)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not fO)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not fO
        end
    end)
    if not fO then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(lW, "GameplayPaused", false)
        else
            lW.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fns.fn205)
Toggles.Fly:OnChanged(fn489)
Toggles.WalkSpeedEnabled:OnChanged(fn429)
connection2 = RunService.Stepped:Connect(onStepped)
connection3 = UserInputService.JumpRequest:Connect(fns.onJumpRequest)
lz = Workspace.CurrentCamera
connection4 = RunService.RenderStepped:Connect(fns.onRenderStepped)
local MenuGroup = s0_41.Settings:AddLeftGroupbox("Menu", "menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
l9.ToggleKeybind = lI.MenuKeybind
l8 = tick()
l3 = tick()
pcall(function()
    for k, v in getconnections(lW.Idled) do
        local rD = v
        pcall(function()
            rD:Disable()
        end)
    end
end)
lH = fn555
connection5 = UserInputService.InputBegan:Connect(onInputBegan)
connection6 = UserInputService.InputChanged:Connect(fns.onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
s0_6:SetLibrary(l9)
s0_6:SetFolder("TempoHub")
s0_6:SaveDefault("Evil Hello Kitty")
s0_6:ApplyToTab(s0_41.Settings)
s0_6:LoadDefault()
lT:SetLibrary(l9)
lT:IgnoreThemeSettings()
lT:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
lT:SetFolder("TempoHub/BuildACart")
s0_8 = lT:BuildConfigSection(s0_41.Settings)
ms = fn310
lX = fns.fn282
lD = fns.fn101
mp = function(hl)
    local sj
    sj = nil
    local sk = type(hl) ~= "table" or type(hl.idx) ~= "string" or type(hl.type) ~= "string"
    local so = if sk then 1 else 0
    local sm = 2588 * so + 3008 * (1 - so)
    local sn = 3592 * so + 14 * (1 - so)
    if not ((sm * 1 + sn * 1816 + sm * sn) % 16777213 == 15821756) then
        sk = lT.Ignore[hl.idx]
    end
    if sk then
        return false
    end
    sj = ms(hl.type, hl.idx)
    if not sj then
        return false
    end
    local sk_1 = pcall(function()
        if hl.type == "Input" then
            if type(hl.text) ~= "string" then
                return
            end
            sj:SetValue(hl.text)
        elseif hl.type == "ColorPicker" then
            sj:SetValueRGB(Color3.fromHex(hl.value), hl.transparency)
        elseif hl.type == "KeyPicker" then
            sj:SetValue({ hl.key, hl.mode, hl.modifiers })
            if hl.mode == "Toggle" and hl.toggled ~= nil then
                sj.Toggled = hl.toggled
                sj:Update()
            end
        else
            sj:SetValue(hl.value)
        end
    end)
    return sk_1
end
s0_8:AddDivider()
s0_8:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
s0_8:AddButton("Export Config to Clipboard", fns.onExportConfigToClipboard)
s0_8:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
lT:LoadAutoloadConfig()
task.spawn(antiGameplayPauseLoop)
task.spawn(antiAfkLoop)
l9:OnUnload(fns.fn235)
l9:Notify("Build A Cart loaded")
end)(...)

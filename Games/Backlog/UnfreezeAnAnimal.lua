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
getgenv().TempoHoodSubtitle = "UNFREEZE AN ANIMAL"
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
if not game:IsLoaded() then
	game.Loaded:Wait()
end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local NAMESPACE = "TempoUnfreezeAnAnimal"
local function hubGetHui()
	return CoreGui
end
if getgenv then
	getgenv().gethui = hubGetHui
end
pcall(function()
	gethui = hubGetHui
end)
local function createFeatureAPI(namespace)
	assert(type(namespace) == "string" and namespace ~= "", "A namespace is required")
	assert(type(getgenv) == "function", "getgenv is unavailable")
	local env = getgenv()
	assert(type(env) == "table", "getgenv did not return a table")
	local previous = env[namespace]
	if previous ~= nil then
		assert(type(previous) == "table" and type(previous.Unload) == "function", "Namespace is occupied")
		previous.Unload()
		assert(env[namespace] == nil, "Previous instance did not release its namespace")
	end
	local API = { State = {}, Unloaded = false }
	local cleanup = {}
	function API.Track(dispose)
		assert(type(dispose) == "function", "Cleanup must be callable")
		if API.Unloaded then
			dispose()
		else
			table.insert(cleanup, dispose)
		end
		return dispose
	end
	function API.Unload()
		if API.Unloaded then
			return
		end
		API.Unloaded = true
		local failures = {}
		for index = #cleanup, 1, -1 do
			local dispose = table.remove(cleanup, index)
			local ok, err = pcall(dispose)
			if not ok then
				table.insert(failures, tostring(err))
			end
		end
		table.clear(API.State)
		if #failures > 0 then
			error("Cleanup incomplete: " .. table.concat(failures, "; "), 0)
		end
		if env[namespace] == API then
			env[namespace] = nil
		end
	end
	env[namespace] = API
	return API
end
local function attachUI(API, Library)
	assert(type(API) == "table" and type(API.Track) == "function", "FeatureAPI required")
	assert(type(Library) == "table" and type(Library.OnUnload) == "function", "UI library required")
	assert(type(Library.Unload) == "function", "UI unload required")
	API.Track(function()
		if not Library.Unloaded then
			Library:Unload()
		end
	end)
	Library:OnUnload(function()
		API.Unload()
	end)
end
local API = createFeatureAPI(NAMESPACE)
local function cref(instance)
	if typeof(cloneref) == "function" and typeof(instance) == "Instance" then
		return cloneref(instance)
	end
	return instance
end
local function callable(fn)
	return type(fn) == "function"
end
local function alive()
	return not API.Unloaded
end
local RS = cref(ReplicatedStorage)
local WS = cref(Workspace)
local ANIMAL_TAG = "FrozenAnimal"
local SPHERE_NAME = "IceSphere"
local PUSH_STAND_GAP = 2.2
local PUSH_SEND_INTERVAL = 0.08
local CONTACT_DISTANCE = 4
local CLOSE_DISTANCE = 15
local TARGET_TIMEOUT = 45
local TARGET_COOLDOWN = 25
local STALL_WINDOW = 8
local STALL_DISTANCE = 4
local CAPACITY_INTERVAL = 5
local REPLACE_INTERVAL = 4
local INDEX_INTERVAL = 12
local POWER_INTERVAL = 2
local REBIRTH_INTERVAL = 6
local POWER_CALL_GAP = 0.4
local POWER_ATTEMPTS = 10
local POWER_MAX_PAUSE = 30
local DATA_TTL = 1.5
local State = API.State
State.AutoPush = false
State.AutoCapacity = false
State.AutoReplace = false
State.AutoIndex = false
State.AutoPower = false
State.AutoRebirth = false
State.PushRarities = {}
State.PushAnimals = {}
State.PushVariants = {}
State.PushRarityCount = 0
State.PushAnimalCount = 0
State.PushVariantCount = 0
State.PushEggs = false
State.OnlyPushable = true
State.Priority = "Nearest"
State.PowerTier = "Best Affordable"
State.PowerReserve = 0
State.Status = "Idle"
State.Delivered = 0
State.Placed = 0
State.Claimed = 0
State.Rebirths = 0
State.PowerBought = 0
local function setStatus(text)
	State.Status = text
end
local function abbreviate(value)
	value = tonumber(value) or 0
	local units = { "", "K", "M", "B", "T", "Qa", "Qi" }
	local index = 1
	while math.abs(value) >= 1000 and index < #units do
		value /= 1000
		index += 1
	end
	if index == 1 then
		return string.format("%d", value)
	end
	return string.format("%.2f%s", value, units[index])
end
local function requireModule(getter)
	local ok, result = pcall(getter)
	if ok and type(result) == "table" then
		return result
	end
	return nil
end
local function waitChild(parent, name, timeout)
	if not parent then
		return nil
	end
	local ok, child = pcall(function()
		return parent:WaitForChild(name, timeout or 20)
	end)
	return ok and child or nil
end
local Packages = waitChild(RS, "Packages")
local PackageIndex = waitChild(Packages, "_Index")
local function knitServices()
	if not PackageIndex then
		return nil
	end
	for _, child in ipairs(PackageIndex:GetChildren()) do
		if string.find(child.Name, "sleitnick_knit", 1, true) then
			local knit = child:FindFirstChild("knit")
			local services = knit and knit:FindFirstChild("Services")
			if services then
				return services
			end
		end
	end
	return nil
end
local Services = knitServices()
local function remoteAt(serviceName, folderName, remoteName)
	if not Services then
		return nil
	end
	local service = Services:FindFirstChild(serviceName)
	local folder = service and service:FindFirstChild(folderName)
	local remote = folder and folder:FindFirstChild(remoteName)
	return remote
end
local PushIntent = remoteAt("PushService", "RE", "Intent")
local PushStop = remoteAt("PushService", "RE", "Stop")
local GetMyBase = remoteAt("BaseService", "RF", "GetMyBase")
local BuySlot = remoteAt("BaseService", "RE", "BuySlot")
local GetPanel = remoteAt("PetService", "RF", "GetPanel")
local PickUpPet = remoteAt("PetService", "RF", "PickUp")
local PlacePet = remoteAt("PetService", "RF", "Place")
local GetIndex = remoteAt("DiscoveryService", "RF", "GetIndex")
local ClaimIndexQuest = remoteAt("DiscoveryService", "RF", "ClaimIndexQuest")
local BuyPower = remoteAt("PowerShopService", "RF", "Buy")
local GetRebirthInfo = remoteAt("RebirthService", "RF", "GetInfo")
local DoRebirth = remoteAt("RebirthService", "RF", "DoRebirth")
local GetData = remoteAt("DataService", "RF", "GetData")
local Shared = waitChild(RS, "Shared")
local BaseConfig = requireModule(function()
	return require(waitChild(Shared, "BaseConfig"))
end)
local PushConfig = requireModule(function()
	return require(waitChild(Shared, "PushConfig"))
end)
if PushConfig then
	ANIMAL_TAG = type(PushConfig.AnimalTag) == "string" and PushConfig.AnimalTag or ANIMAL_TAG
	SPHERE_NAME = type(PushConfig.SphereName) == "string" and PushConfig.SphereName or SPHERE_NAME
end
local function hasPush()
	return PushIntent ~= nil
end
local function hasCapacity()
	return BuySlot ~= nil and GetMyBase ~= nil
end
local function hasReplace()
	return GetPanel ~= nil and PickUpPet ~= nil and PlacePet ~= nil
end
local function hasIndex()
	return GetIndex ~= nil and ClaimIndexQuest ~= nil and BaseConfig ~= nil and type(BaseConfig.IndexQuests) == "table"
end
local function hasPower()
	return BuyPower ~= nil
end
local function hasRebirth()
	return DoRebirth ~= nil and GetRebirthInfo ~= nil
end
function API.Support()
	local missing = {}
	if not hasPush() then
		table.insert(missing, "auto push")
	end
	if not hasCapacity() then
		table.insert(missing, "capacity")
	end
	if not hasReplace() then
		table.insert(missing, "replace")
	end
	if not hasIndex() then
		table.insert(missing, "index quests")
	end
	if not hasPower() then
		table.insert(missing, "power")
	end
	if not hasRebirth() then
		table.insert(missing, "rebirth")
	end
	return missing
end
local rarityValues = {}
local rarityRank = {}
local animalValues = {}
local variantValues = {}
local powerTierValues = { "Best Affordable" }
local function buildCatalog()
	if BaseConfig and type(BaseConfig.RarityOrder) == "table" then
		for order, rarity in ipairs(BaseConfig.RarityOrder) do
			table.insert(rarityValues, rarity)
			rarityRank[rarity] = order
		end
	end
	if BaseConfig and type(BaseConfig.Animals) == "table" then
		for name in pairs(BaseConfig.Animals) do
			table.insert(animalValues, name)
		end
		table.sort(animalValues)
	end
	if BaseConfig and type(BaseConfig.Variants) == "table" then
		for _, variant in ipairs(BaseConfig.Variants) do
			if type(variant) == "string" then
				table.insert(variantValues, variant)
			end
		end
	end
	if #variantValues == 0 then
		table.insert(variantValues, "Normal")
	end
	if BaseConfig and type(BaseConfig.PowerShop) == "table" and type(BaseConfig.PowerShop.Offers) == "table" then
		for index = 1, #BaseConfig.PowerShop.Offers do
			table.insert(powerTierValues, "Tier " .. index)
		end
	end
end
buildCatalog()
function API.RarityValues()
	return rarityValues
end
function API.AnimalValues()
	return animalValues
end
function API.VariantValues()
	return variantValues
end
function API.PowerTierValues()
	return powerTierValues
end
local function selectionSet(values)
	local set = {}
	local count = 0
	if type(values) == "table" then
		for key, value in pairs(values) do
			local entry = type(value) == "string" and value or (type(key) == "string" and key or nil)
			local enabled = type(value) == "string" or value == true
			if entry and enabled then
				set[entry] = true
				count += 1
			end
		end
	elseif type(values) == "string" and values ~= "" then
		set[values] = true
		count = 1
	end
	return set, count
end
local function animalInfo(name)
	if BaseConfig and type(BaseConfig.Animals) == "table" then
		return BaseConfig.Animals[name]
	end
	return nil
end
local function playerStrength()
	return LocalPlayer:GetAttribute("BaseStrength")
		or LocalPlayer:GetAttribute("Strength")
		or LocalPlayer:GetAttribute("PermanentStrength")
		or 0
end
local dataCache = nil
local dataCacheAt = 0
local function playerData(force)
	if not GetData then
		return nil
	end
	local now = os.clock()
	if not force and dataCache and now - dataCacheAt < DATA_TTL then
		return dataCache
	end
	local ok, data = pcall(function()
		return GetData:InvokeServer()
	end)
	if ok and type(data) == "table" then
		dataCache = data
		dataCacheAt = now
	end
	return dataCache
end
local function currentMoney()
	local data = playerData()
	if type(data) ~= "table" then
		return 0
	end
	local key = BaseConfig and type(BaseConfig.MoneyKey) == "string" and BaseConfig.MoneyKey or "Money"
	return tonumber(data[key]) or 0
end
local function currentRebirths()
	local data = playerData()
	if type(data) ~= "table" then
		return tonumber(LocalPlayer:GetAttribute("Rebirths")) or 0
	end
	return tonumber(data.Rebirths) or tonumber(LocalPlayer:GetAttribute("Rebirths")) or 0
end
function API.GetStatus()
	return string.format(
		"%s  |  delivered %d  |  placed %d  |  power %s",
		tostring(State.Status),
		State.Delivered or 0,
		State.Placed or 0,
		abbreviate(playerStrength())
	)
end
local function character()
	local model = LocalPlayer.Character
	if not model or not model.Parent then
		return nil
	end
	local root = model:FindFirstChild("HumanoidRootPart")
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then
		return nil
	end
	return model, root, humanoid
end
local baseModel = nil
local function ownBase()
	if baseModel and baseModel.Parent then
		return baseModel
	end
	if not GetMyBase then
		return nil
	end
	local ok, info = pcall(function()
		return GetMyBase:InvokeServer()
	end)
	if not ok or type(info) ~= "table" or not info.index then
		return nil
	end
	local bases = WS:FindFirstChild("Bases")
	baseModel = bases and bases:FindFirstChild("Base" .. tostring(info.index)) or nil
	return baseModel
end
local function campfirePosition()
	local base = ownBase()
	if not base then
		return nil
	end
	local platform = base:FindFirstChild("CampfirePlatform")
	if platform and platform:IsA("BasePart") then
		return platform.Position
	end
	local campfire = base:FindFirstChild("Campfire")
	if campfire then
		local ok, pivot = pcall(function()
			return campfire:GetPivot().Position
		end)
		if ok then
			return pivot
		end
	end
	return nil
end
local function sphereOf(model)
	local sphere = model:FindFirstChild(SPHERE_NAME, true)
	if sphere and sphere:IsA("BasePart") then
		return sphere
	end
	return nil
end
local function horizontal(vector)
	return Vector3.new(vector.X, 0, vector.Z)
end
local blacklist = {}
local function blacklisted(model)
	local until_ = blacklist[model]
	return until_ ~= nil and os.clock() < until_
end
local function blacklistModel(model, seconds)
	blacklist[model] = os.clock() + (seconds or TARGET_COOLDOWN)
end
local function variantOf(model)
	local variant = model:GetAttribute("Variant")
	if type(variant) == "string" and variant ~= "" then
		return variant
	end
	return "Normal"
end
local function matchesFilters(model)
	local info = animalInfo(model.Name)
	if not info then
		return State.PushEggs
	end
	if State.PushVariantCount > 0 and not State.PushVariants[variantOf(model)] then
		return false
	end
	if State.PushRarityCount == 0 and State.PushAnimalCount == 0 then
		return true
	end
	if State.PushAnimalCount > 0 and State.PushAnimals[model.Name] then
		return true
	end
	if State.PushRarityCount > 0 and info.rarity and State.PushRarities[info.rarity] then
		return true
	end
	return false
end
local function selectTarget(root, fire)
	local best, bestScore, bestSphere
	local strength = playerStrength()
	for _, model in ipairs(CollectionService:GetTagged(ANIMAL_TAG)) do
		if model.Parent and not blacklisted(model) then
			local owner = model:GetAttribute("OwnerUserId")
			if owner == nil or owner == LocalPlayer.UserId then
				local sphere = sphereOf(model)
				if sphere then
					local required = tonumber(model:GetAttribute("RequiredStrength"))
					local pushable = not State.OnlyPushable or required == nil or required <= strength
					if pushable and matchesFilters(model) then
						local score
						if State.Priority == "Closest To Campfire" then
							score = (sphere.Position - fire).Magnitude
						elseif State.Priority == "Highest Rarity" then
							local info = animalInfo(model.Name)
							local rank = info and rarityRank[info.rarity] or 0
							score = -(rank * 100000) + (sphere.Position - root.Position).Magnitude
						else
							score = (sphere.Position - root.Position).Magnitude
						end
						if not bestScore or score < bestScore then
							bestScore = score
							best = model
							bestSphere = sphere
						end
					end
				end
			end
		end
	end
	return best, bestSphere
end
local function stopPush()
	if PushStop then
		pcall(function()
			PushStop:FireServer()
		end)
	end
end
local function pushTarget(model, sphere, fire)
	local started = os.clock()
	local lastDistance = (horizontal(sphere.Position - fire)).Magnitude
	local lastProgress = started
	local sending = false
	while alive() and State.AutoPush do
		if not model.Parent or not sphere.Parent then
			if sending then
				stopPush()
			end
			State.Delivered += 1
			return true
		end
		if os.clock() - started > TARGET_TIMEOUT then
			blacklistModel(model, TARGET_COOLDOWN)
			if sending then
				stopPush()
			end
			return false
		end
		local _, root = character()
		if not root then
			sending = false
			task.wait(0.2)
		else
			local spherePosition = sphere.Position
			local flat = horizontal(fire - spherePosition)
			local distance = flat.Magnitude
			if distance > CLOSE_DISTANCE then
				if lastDistance - distance > STALL_DISTANCE then
					lastDistance = distance
					lastProgress = os.clock()
				elseif os.clock() - lastProgress > STALL_WINDOW then
					blacklistModel(model, TARGET_COOLDOWN)
					if sending then
						stopPush()
					end
					return false
				end
			else
				lastProgress = os.clock()
			end
			if distance <= CONTACT_DISTANCE then
				if sending then
					sending = false
					stopPush()
				end
				setStatus("Melting " .. model.Name)
				task.wait(0.25)
			else
				local direction = flat.Unit
				local stand = spherePosition
					- direction * (sphere.Size.X * 0.5 + PUSH_STAND_GAP)
					+ Vector3.new(0, 0.6, 0)
				root.CFrame = CFrame.new(stand, spherePosition)
				pcall(function()
					PushIntent:FireServer(model, direction)
				end)
				sending = true
				setStatus(string.format("Pushing %s (%d studs left)", model.Name, math.floor(distance)))
				task.wait(PUSH_SEND_INTERVAL)
			end
		end
	end
	if sending then
		stopPush()
	end
	return false
end
local function pushPass()
	if not hasPush() then
		setStatus("Push remote unavailable")
		return
	end
	local fire = campfirePosition()
	if not fire then
		setStatus("Waiting for your base")
		task.wait(1)
		return
	end
	local _, root = character()
	if not root then
		setStatus("Waiting for character")
		task.wait(0.5)
		return
	end
	local model, sphere = selectTarget(root, fire)
	if not model or not sphere then
		setStatus("No animal matches the filters")
		task.wait(1)
		return
	end
	pushTarget(model, sphere, fire)
end
local function capacityPass()
	if not hasCapacity() then
		return
	end
	local base = ownBase()
	local signs = base and base:FindFirstChild("Signs")
	if not signs then
		return
	end
	local money = currentMoney()
	for _, sign in ipairs(signs:GetChildren()) do
		if not alive() or not State.AutoCapacity then
			return
		end
		local button = sign:FindFirstChild("BuyButton", true)
		local price = button and tonumber(button:GetAttribute("Price"))
		if price and price <= money then
			pcall(function()
				BuySlot:FireServer(sign)
			end)
			task.wait(0.6)
			playerData(true)
			return
		end
	end
end
local function fetchPanel()
	if not GetPanel then
		return nil
	end
	local ok, panel = pcall(function()
		return GetPanel:InvokeServer()
	end)
	if ok and type(panel) == "table" then
		return panel
	end
	return nil
end
local function bestInventoryEntry(panel)
	local best
	if type(panel.inventory) ~= "table" then
		return nil
	end
	for _, entry in ipairs(panel.inventory) do
		if type(entry) == "table" and entry.isEgg ~= true and entry.index then
			local income = tonumber(entry.income) or 0
			if not best or income > (tonumber(best.income) or 0) then
				best = entry
			end
		end
	end
	return best
end
local function worstPlacedEntry(panel)
	local worst
	if type(panel.pets) ~= "table" then
		return nil
	end
	for _, entry in ipairs(panel.pets) do
		if type(entry) == "table" and entry.id then
			local income = tonumber(entry.income) or 0
			if not worst or income < (tonumber(worst.income) or 0) then
				worst = entry
			end
		end
	end
	return worst
end
local function replacePass()
	if not hasReplace() then
		return
	end
	local panel = fetchPanel()
	if not panel then
		return
	end
	local used = tonumber(panel.used) or 0
	local capacity = tonumber(panel.capacity) or 0
	local best = bestInventoryEntry(panel)
	if not best then
		return
	end
	if used < capacity then
		local ok = pcall(function()
			return PlacePet:InvokeServer(best.index)
		end)
		if ok then
			State.Placed += 1
			setStatus("Placed " .. tostring(best.animalType))
		end
		return
	end
	local worst = worstPlacedEntry(panel)
	if not worst then
		return
	end
	if (tonumber(best.income) or 0) <= (tonumber(worst.income) or 0) then
		return
	end
	local removed = pcall(function()
		return PickUpPet:InvokeServer(worst.id)
	end)
	if not removed then
		return
	end
	task.wait(0.4)
	local refreshed = fetchPanel()
	if not refreshed then
		return
	end
	local replacement = bestInventoryEntry(refreshed)
	if not replacement then
		return
	end
	local placed = pcall(function()
		return PlacePet:InvokeServer(replacement.index)
	end)
	if placed then
		State.Placed += 1
		setStatus(string.format("Replaced %s with %s", tostring(worst.animalType), tostring(replacement.animalType)))
	end
end
local function discoveredSet(index, variant)
	local set = {}
	local source = type(index.discovered) == "table" and index.discovered[variant] or nil
	if type(source) ~= "table" then
		return set
	end
	for key, value in pairs(source) do
		if type(value) == "string" then
			set[value] = true
		elseif value == true and type(key) == "string" then
			set[key] = true
		end
	end
	return set
end
local function questComplete(index, quest)
	local set = discoveredSet(index, quest.variant)
	for _, need in ipairs(quest.needs or {}) do
		local count = 0
		for name in pairs(set) do
			local info = animalInfo(name)
			if info and info.rarity == need.rarity then
				count += 1
			end
		end
		if count < (tonumber(need.count) or 0) then
			return false
		end
	end
	return true
end
local function indexPass()
	if not hasIndex() then
		return
	end
	local ok, index = pcall(function()
		return GetIndex:InvokeServer()
	end)
	if not ok or type(index) ~= "table" then
		return
	end
	local claimed = {}
	if type(index.claimed) == "table" then
		for key, value in pairs(index.claimed) do
			if type(value) == "string" then
				claimed[value] = true
			elseif value == true and type(key) == "string" then
				claimed[key] = true
			end
		end
	end
	for _, quest in ipairs(BaseConfig.IndexQuests) do
		if not alive() or not State.AutoIndex then
			return
		end
		if quest.id and not claimed[quest.id] and questComplete(index, quest) then
			local claimedOk, result = pcall(function()
				return ClaimIndexQuest:InvokeServer(quest.id)
			end)
			if claimedOk and result ~= nil and result ~= false and result ~= "early" and result ~= "invalid" then
				State.Claimed += 1
				setStatus("Claimed index quest " .. tostring(quest.id))
				playerData(true)
				task.wait(0.4)
			end
		end
	end
end
local offerLookupBroken = false
local learnedPrice = {}
local unaffordableAt = {}
local powerPausedUntil = 0
local function offerPrice(index, strength, rebirths)
	if learnedPrice[index] then
		return learnedPrice[index]
	end
	if offerLookupBroken or not BaseConfig or type(BaseConfig.PowerShop) ~= "table" or not callable(BaseConfig.PowerShop.offerFor) then
		return nil
	end
	local ok, offer = pcall(BaseConfig.PowerShop.offerFor, index, strength, rebirths)
	if not ok then
		offerLookupBroken = true
		return nil
	end
	if type(offer) ~= "table" then
		return nil
	end
	return tonumber(offer.money)
end
local function buyTier(index)
	local before = currentMoney()
	local ok, result = pcall(function()
		return BuyPower:InvokeServer(index)
	end)
	if not ok then
		return nil
	end
	if result == "ok" then
		local after = playerData(true)
		local key = BaseConfig and type(BaseConfig.MoneyKey) == "string" and BaseConfig.MoneyKey or "Money"
		local spent = before - (type(after) == "table" and tonumber(after[key]) or before)
		if spent > 0 then
			learnedPrice[index] = spent
		end
		unaffordableAt[index] = nil
		State.PowerBought += 1
		setStatus("Bought power tier " .. index)
	end
	return result
end
local function powerPass()
	if not BuyPower or os.clock() < powerPausedUntil then
		return
	end
	local count = BaseConfig and type(BaseConfig.PowerShop) == "table" and type(BaseConfig.PowerShop.Offers) == "table" and #BaseConfig.PowerShop.Offers or 0
	if count == 0 then
		count = 7
	end
	local reserve = math.max(0, State.PowerReserve or 0)
	local strength = playerStrength()
	local rebirths = currentRebirths()
	local order = {}
	if State.PowerTier == "Best Affordable" then
		for index = count, 1, -1 do
			table.insert(order, index)
		end
	else
		local index = tonumber(string.match(tostring(State.PowerTier), "%d+"))
		if not index then
			return
		end
		table.insert(order, index)
	end
	local attempts = 0
	for _, index in ipairs(order) do
		local money = currentMoney() - reserve
		if money <= 0 then
			return
		end
		local price = offerPrice(index, strength, rebirths)
		local knownTooDear = price ~= nil and price > money
		local seenTooDear = unaffordableAt[index] ~= nil and money <= unaffordableAt[index]
		if not knownTooDear and not seenTooDear then
			local retries = 0
			while alive() and State.AutoPower and attempts < POWER_ATTEMPTS do
				attempts += 1
				local result = buyTier(index)
				if result == "ok" then
					retries = 0
					task.wait(POWER_CALL_GAP)
				elseif result == "bad" and retries < 2 then
					retries += 1
					task.wait(POWER_CALL_GAP)
				elseif result == "max" then
					powerPausedUntil = os.clock() + POWER_MAX_PAUSE
					return
				else
					if result == "poor" then
						unaffordableAt[index] = currentMoney() - reserve
					end
					task.wait(POWER_CALL_GAP)
					break
				end
			end
			if attempts >= POWER_ATTEMPTS then
				return
			end
		end
	end
end
local function rebirthPass()
	if not hasRebirth() then
		return
	end
	local ok, info = pcall(function()
		return GetRebirthInfo:InvokeServer()
	end)
	if not ok or type(info) ~= "table" or type(info.next) ~= "table" then
		return
	end
	if info.next.canRebirth ~= true then
		return
	end
	local done, result = pcall(function()
		return DoRebirth:InvokeServer()
	end)
	if done and result ~= nil and result ~= false then
		State.Rebirths += 1
		setStatus("Rebirthed")
		playerData(true)
		task.wait(1)
	end
end
local loops = {}
local function stopLoop(name)
	local thread = loops[name]
	if not thread then
		return
	end
	loops[name] = nil
	if coroutine.status(thread) ~= "dead" then
		pcall(task.cancel, thread)
	end
end
local function startLoop(name, interval, body)
	stopLoop(name)
	local thread
	thread = task.spawn(function()
		while alive() and loops[name] == thread do
			local ok, err = pcall(body)
			if not ok then
				warn("[Tempo] " .. name .. ": " .. tostring(err))
				task.wait(1)
			end
			task.wait(interval)
		end
	end)
	loops[name] = thread
end
API.Track(function()
	for name in pairs(loops) do
		stopLoop(name)
	end
	stopPush()
end)
function API.SetAutoPush(value)
	State.AutoPush = value == true
	if State.AutoPush then
		startLoop("Push", 0.2, pushPass)
	else
		stopLoop("Push")
		stopPush()
		setStatus("Idle")
	end
end
function API.SetAutoCapacity(value)
	State.AutoCapacity = value == true
	if State.AutoCapacity then
		startLoop("Capacity", CAPACITY_INTERVAL, capacityPass)
	else
		stopLoop("Capacity")
	end
end
function API.SetAutoReplace(value)
	State.AutoReplace = value == true
	if State.AutoReplace then
		startLoop("Replace", REPLACE_INTERVAL, replacePass)
	else
		stopLoop("Replace")
	end
end
function API.SetAutoIndex(value)
	State.AutoIndex = value == true
	if State.AutoIndex then
		startLoop("Index", INDEX_INTERVAL, indexPass)
	else
		stopLoop("Index")
	end
end
function API.SetAutoPower(value)
	State.AutoPower = value == true
	if State.AutoPower then
		startLoop("Power", POWER_INTERVAL, powerPass)
	else
		stopLoop("Power")
	end
end
function API.SetAutoRebirth(value)
	State.AutoRebirth = value == true
	if State.AutoRebirth then
		startLoop("Rebirth", REBIRTH_INTERVAL, rebirthPass)
	else
		stopLoop("Rebirth")
	end
end
function API.SetPushRarities(values)
	State.PushRarities, State.PushRarityCount = selectionSet(values)
end
function API.SetPushAnimals(values)
	State.PushAnimals, State.PushAnimalCount = selectionSet(values)
end
function API.SetPushVariants(values)
	State.PushVariants, State.PushVariantCount = selectionSet(values)
end
function API.SetPushEggs(value)
	State.PushEggs = value == true
end
function API.SetOnlyPushable(value)
	State.OnlyPushable = value == true
end
function API.SetPriority(value)
	State.Priority = type(value) == "string" and value or "Nearest"
end
function API.SetPowerTier(value)
	State.PowerTier = type(value) == "string" and value or "Best Affordable"
end
function API.SetPowerReserve(value)
	State.PowerReserve = math.max(0, tonumber(value) or 0)
end
function API.PlaceBestNow()
	if not hasReplace() then
		return false, "Pet remotes are unavailable"
	end
	replacePass()
	return true, "Checked your base for a better animal"
end
function API.ClaimIndexNow()
	if not hasIndex() then
		return false, "Index remotes are unavailable"
	end
	local before = State.Claimed
	indexPass()
	local gained = State.Claimed - before
	return true, gained > 0 and ("Claimed " .. gained .. " quest(s)") or "No index quest is ready"
end
function API.RebirthNow()
	if not hasRebirth() then
		return false, "Rebirth remotes are unavailable"
	end
	local before = State.Rebirths
	rebirthPass()
	return true, State.Rebirths > before and "Rebirthed" or "Rebirth requirements are not met"
end
local function setupInterface()
	local GAME_NAME = "Unfreeze an Animal"
	local SCRIPT_VERSION = "v0.1"
	local DISCORD_INVITE = "https://discord.gg/K7Qxnxkk46"
	local RSCRIPTS_LINK = "https://discord.gg/K7Qxnxkk46"
	local WEBSITE_LINK = "https://tempohub.shop"
	local repo = ""
	local Library = getgenv().Library
	local ThemeManager = getgenv().ThemeManager
	local SaveManager = getgenv().SaveManager
	local Toggles = Library.Toggles
	local Options = Library.Options
	attachUI(API, Library)
	local function copyText(text, message)
		local writer = callable(setclipboard) and setclipboard or (callable(toclipboard) and toclipboard or nil)
		if not writer then
			Library:Notify("Clipboard is unavailable")
			return
		end
		local ok = pcall(writer, text)
		if ok then
			Library:Notify(message)
		else
			Library:Notify("Failed to copy")
		end
	end
	local function copyDiscord()
		copyText(DISCORD_INVITE, "Copied Discord invite to clipboard")
	end
	local Window = Library:CreateWindow({
		Title = "Tempo",
		Font = Enum.Font.BuilderSans,
		Footer = {
			{ Text = DISCORD_INVITE, Copyable = true },
			"|",
			GAME_NAME,
			"|",
			SCRIPT_VERSION,
		},
		Icon = 78539693571783,
		NotifySide = "Right",
		ShowCustomCursor = false,
		CornerRadius = 0,
		SidebarCompacted = true,
		TabSwipeFrom = "bottom",
		Animations = { TabSwitch = true },
	})
	Window:SetGlow(false)
	local Tabs = {
		Info = Window:AddTab("Info", "info"),
		Main = Window:AddTab("Main", "gamepad-2"),
		Player = Window:AddTab("Player", "person-standing"),
		Settings = Window:AddTab("Settings", "settings"),
	}
	local function AddDiscordButton(Tab)
		local DiscordGroup = Tab:AddLeftGroupbox("Discord")
		DiscordGroup:AddButton({
			Text = "Join Discord to Make Money",
			Func = copyDiscord,
		})
		DiscordGroup:AddButton({
			Text = "Join Discord for Keyless Scripts",
			Func = copyDiscord,
		})
	end
	for name, Tab in Tabs do
		if name ~= "Info" then
			AddDiscordButton(Tab)
		end
	end
	local function setupMainTab()
		local PushGroup = Tabs.Main:AddRightGroupbox("Push", "snowflake")
		local StatusLabel = PushGroup:AddLabel(API.GetStatus(), true)
		PushGroup:AddDivider()
		PushGroup:AddToggle("AutoPush", {
			Text = "Auto Push Animals",
			Default = false,
			Tooltip = "Walks the nearest matching frozen animal into your campfire, one at a time.",
			Callback = function(value)
				API.SetAutoPush(value)
			end,
		})
		PushGroup:AddDropdown("PushRarities", {
			Text = "Rarity Filter",
			Values = API.RarityValues(),
			Default = {},
			Multi = true,
			AllowNull = true,
			Expandable = true,
			Tooltip = "Push animals of these rarities. Leave this and the animal filter empty to push everything.",
			Callback = function(value)
				API.SetPushRarities(value)
			end,
		})
		PushGroup:AddDropdown("PushAnimals", {
			Text = "Specific Animal Filter",
			Values = API.AnimalValues(),
			Default = {},
			Multi = true,
			AllowNull = true,
			Searchable = true,
			Expandable = true,
			Tooltip = "Push these exact animals. An animal is taken when it matches either filter.",
			Callback = function(value)
				API.SetPushAnimals(value)
			end,
		})
		PushGroup:AddDropdown("PushVariants", {
			Text = "Variant Filter",
			Values = API.VariantValues(),
			Default = {},
			Multi = true,
			AllowNull = true,
			Expandable = true,
			Tooltip = "Only push these variants. Leave empty to accept every variant.",
			Callback = function(value)
				API.SetPushVariants(value)
			end,
		})
		PushGroup:AddDropdown("PushPriority", {
			Text = "Target Priority",
			Values = { "Nearest", "Closest To Campfire", "Highest Rarity" },
			Default = "Nearest",
			Multi = false,
			AllowNull = false,
			Tooltip = "Pick the closest animal, the one already near your campfire, or the rarest one.",
			Callback = function(value)
				API.SetPriority(value)
			end,
		})
		PushGroup:AddToggle("OnlyPushable", {
			Text = "Skip Animals Above My Power",
			Default = true,
			Tooltip = "Ignores animals whose RequiredStrength is higher than your current power.",
			Callback = function(value)
				API.SetOnlyPushable(value)
			end,
		})
		PushGroup:AddToggle("PushEggs", {
			Text = "Push Ice Eggs",
			Default = false,
			Tooltip = "Also pushes the frozen eggs that spawn around the map.",
			Callback = function(value)
				API.SetPushEggs(value)
			end,
		})
		local BaseGroup = Tabs.Main:AddLeftGroupbox("Base", "house")
		BaseGroup:AddToggle("AutoCapacity", {
			Text = "Auto Upgrade Capacity",
			Default = false,
			Tooltip = "Buys the next base slot sign as soon as you can afford it.",
			Callback = function(value)
				API.SetAutoCapacity(value)
			end,
		})
		BaseGroup:AddToggle("AutoReplace", {
			Text = "Auto Replace Animal With Better",
			Default = false,
			Tooltip = "Places stored animals in free slots, and swaps out your lowest income animal when the base is full.",
			Callback = function(value)
				API.SetAutoReplace(value)
			end,
		})
		BaseGroup:AddDivider()
		BaseGroup:AddButton({
			Text = "Place Best Animal Now",
			Func = function()
				local _, message = API.PlaceBestNow()
				Library:Notify(message)
			end,
		})
		local ProgressGroup = Tabs.Main:AddLeftGroupbox("Progression", "trending-up")
		ProgressGroup:AddToggle("AutoPower", {
			Text = "Auto Buy Power",
			Default = false,
			Tooltip = "Buys power from the power shop with cash.",
			Callback = function(value)
				API.SetAutoPower(value)
			end,
		})
		ProgressGroup:AddDropdown("PowerTier", {
			Text = "Power Tier",
			Values = API.PowerTierValues(),
			Default = "Best Affordable",
			Multi = false,
			AllowNull = false,
			Tooltip = "Buy the largest tier you can afford, or lock buying to one tier.",
			Callback = function(value)
				API.SetPowerTier(value)
			end,
		})
		ProgressGroup:AddSlider("PowerReserve", {
			Text = "Keep Cash",
			Default = 0,
			Min = 0,
			Max = 100000000,
			Rounding = 0,
			Tooltip = "Cash kept back from power purchases, so slot upgrades stay affordable. Applied from the first purchase of a tier, once its price is known.",
			Callback = function(value)
				API.SetPowerReserve(value)
			end,
		})
		ProgressGroup:AddDivider()
		ProgressGroup:AddToggle("AutoRebirth", {
			Text = "Auto Rebirth",
			Default = false,
			Tooltip = "Rebirths as soon as the power and rarity requirements are met.",
			Callback = function(value)
				API.SetAutoRebirth(value)
			end,
		})
		ProgressGroup:AddButton({
			Text = "Rebirth Now",
			Func = function()
				local _, message = API.RebirthNow()
				Library:Notify(message)
			end,
		})
		local IndexGroup = Tabs.Main:AddRightGroupbox("Index", "book-open")
		IndexGroup:AddToggle("AutoIndex", {
			Text = "Auto Claim Index Quests",
			Default = false,
			Tooltip = "Claims every discovery quest whose rarity targets are already met.",
			Callback = function(value)
				API.SetAutoIndex(value)
			end,
		})
		IndexGroup:AddButton({
			Text = "Claim Index Quests Now",
			Func = function()
				local _, message = API.ClaimIndexNow()
				Library:Notify(message)
			end,
		})
		local statusTask = task.spawn(function()
			while not Library.Unloaded do
				pcall(function()
					StatusLabel:SetText(API.GetStatus())
				end)
				task.wait(0.25)
			end
		end)
		API.Track(function()
			if coroutine.status(statusTask) ~= "dead" then
				pcall(task.cancel, statusTask)
			end
		end)
	end
	setupMainTab()
	local function setupInfoTab()
		local function escapeText(text)
			return (tostring(text):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
		end
		local function colored(text, color)
			return string.format('<font color="%s">%s</font>', color, escapeText(text))
		end
		local function field(key, value, color)
			return string.format("<b>%s</b> %s %s", key, colored("-", "#5a6070"), colored(value, color))
		end
		local GREEN = "#7fd47f"
		local BLUE = "#6ec1ff"
		local ORANGE = "#e8a34d"
		local GREY = "#8b93a3"
		local missing = API.Support()
		local supportText = #missing == 0 and "ready" or ("limited: " .. table.concat(missing, ", "))
		local executorName = "Unknown"
		pcall(function()
			if callable(identifyexecutor) then
				local name, version = identifyexecutor()
				if type(name) == "string" and name ~= "" then
					executorName = type(version) == "string" and version ~= "" and (name .. " " .. version) or name
				end
			end
		end)
		local sessionStart = os.clock()
		local function sessionElapsed()
			local elapsed = math.floor(os.clock() - sessionStart)
			if elapsed < 60 then
				return elapsed .. "s"
			elseif elapsed < 3600 then
				return string.format("%dm %ds", math.floor((elapsed) / (60)), elapsed % 60)
			end
			return string.format("%dh %dm", math.floor((elapsed) / (3600)), math.floor(((elapsed % 3600)) / (60)))
		end
		local UserGroup = Tabs.Info:AddLeftGroupbox("User", "circle-user")
		UserGroup:AddPlayerInfo("InfoUserCard", {
			Player = LocalPlayer,
			Title = "User",
			HeaderIcon = "user",
			Collapsible = false,
		})
		UserGroup:AddLabel(field("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, GREEN), true)
		UserGroup:AddLabel(field("UserId", tostring(LocalPlayer.UserId), BLUE), true)
		UserGroup:AddLabel(field("Executor", executorName .. "  " .. supportText, GREEN), true)
		UserGroup:AddDivider()
		local SessionLabel = UserGroup:AddLabel(field("Session", sessionElapsed(), ORANGE), true)
		UserGroup:AddDivider()
		UserGroup:AddButton({
			Text = "Copy Username",
			Func = function()
				copyText(LocalPlayer.Name, "Copied username")
			end,
		})
		UserGroup:AddButton({
			Text = "Copy Profile Link",
			Func = function()
				copyText("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
			end,
		})
		local SessionGroup = Tabs.Info:AddRightGroupbox("Session", "signal")
		SessionGroup:AddLabel(field("Game", GAME_NAME, BLUE), true)
		local PlayersLabel = SessionGroup:AddLabel(field("Players", "0/0", GREEN), true)
		local jobId = tostring(game.JobId)
		local shortJobId = #jobId > 18 and (string.sub(jobId, 1, 18) .. "...") or jobId
		SessionGroup:AddLabel(field("Job", shortJobId, GREY), true)
		local PingLabel = SessionGroup:AddLabel(field("Ping", "0 ms", ORANGE), true)
		SessionGroup:AddDivider()
		SessionGroup:AddButton({
			Text = "Rejoin Place",
			Func = function()
				TeleportService:Teleport(game.PlaceId, LocalPlayer)
			end,
		})
		SessionGroup:AddButton({
			Text = "Copy Job ID",
			Func = function()
				copyText(jobId, "Copied Job ID")
			end,
		})
		local statsTask = task.spawn(function()
			while true do
				task.wait(1)
				if Library.Unloaded then
					break
				end
				SessionLabel:SetText(field("Session", sessionElapsed(), ORANGE))
				PlayersLabel:SetText(field("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), GREEN))
				local ok, ping = pcall(function()
					return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
				end)
				PingLabel:SetText(field("Ping", ok and (ping .. " ms") or "n/a", ORANGE))
			end
		end)
		API.Track(function()
			if coroutine.status(statsTask) ~= "dead" then
				pcall(task.cancel, statsTask)
			end
		end)
		local SocialsGroup = Tabs.Info:AddRightGroupbox("Socials", "link")
		SocialsGroup:AddButton({ Text = "Discord", Func = copyDiscord })
		SocialsGroup:AddButton({
			Text = "Rscripts",
			Func = function()
				copyText(RSCRIPTS_LINK, "Copied Rscripts profile")
			end,
		})
		SocialsGroup:AddButton({
			Text = "Website",
			Func = function()
				copyText(WEBSITE_LINK, "Copied website link")
			end,
		})
	end
	setupInfoTab()
	local function setupPlayerTab()
		local MovementGroup = Tabs.Player:AddLeftGroupbox("Movement", "footprints")
		MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
		MovementGroup:AddSlider("WalkSpeed", {
			Text = "WalkSpeed Amount",
			Default = 32,
			Min = 16,
			Max = 250,
			Rounding = 0,
		})
		MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
		MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
		MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
		local FlyGroup = Tabs.Player:AddRightGroupbox("Fly", "feather")
		FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
		FlyGroup:AddSlider("FlySpeed", {
			Text = "Fly Speed",
			Default = 60,
			Min = 10,
			Max = 400,
			Rounding = 0,
		})
		local connections = {}
		local collisions = {}
		local speeds = {}
		local platforms = {}
		local promptDefaults = {}
		local function restoreCollisions()
			for part, value in collisions do
				if part.Parent then
					part.CanCollide = value
				end
			end
			table.clear(collisions)
		end
		local function restoreSpeeds()
			for humanoid, value in speeds do
				if humanoid.Parent then
					humanoid.WalkSpeed = value
				end
			end
			table.clear(speeds)
		end
		local function restoreFlight()
			for humanoid, value in platforms do
				if humanoid.Parent then
					humanoid.PlatformStand = value
				end
			end
			table.clear(platforms)
		end
		local function applyPrompt(prompt)
			if not prompt:IsA("ProximityPrompt") then
				return
			end
			if promptDefaults[prompt] == nil then
				promptDefaults[prompt] = {
					HoldDuration = prompt.HoldDuration,
					MaxActivationDistance = prompt.MaxActivationDistance,
					RequiresLineOfSight = prompt.RequiresLineOfSight,
				}
			end
			prompt.HoldDuration = 0
			prompt.MaxActivationDistance = 50
			prompt.RequiresLineOfSight = false
		end
		local function restorePrompts()
			for prompt, values in promptDefaults do
				if prompt.Parent then
					prompt.HoldDuration = values.HoldDuration
					prompt.MaxActivationDistance = values.MaxActivationDistance
					prompt.RequiresLineOfSight = values.RequiresLineOfSight
				end
			end
			table.clear(promptDefaults)
		end
		Toggles.Fly:OnChanged(function()
			if not Toggles.Fly.Value then
				restoreFlight()
			end
		end)
		Toggles.WalkSpeedEnabled:OnChanged(function()
			if not Toggles.WalkSpeedEnabled.Value then
				restoreSpeeds()
			end
		end)
		Toggles.NoClip:OnChanged(function()
			if not Toggles.NoClip.Value then
				restoreCollisions()
			end
		end)
		Toggles.InstantProximityPrompt:OnChanged(function()
			if Toggles.InstantProximityPrompt.Value then
				for _, prompt in Workspace:QueryDescendants("ProximityPrompt") do
					pcall(applyPrompt, prompt)
				end
			else
				restorePrompts()
			end
		end)
		table.insert(connections, Workspace.DescendantAdded:Connect(function(instance)
			if Toggles.InstantProximityPrompt.Value then
				applyPrompt(instance)
			end
		end))
		table.insert(connections, RunService.Stepped:Connect(function()
			if Library.Unloaded then
				return
			end
			local characterModel = LocalPlayer.Character
			if Toggles.NoClip.Value and characterModel then
				for _, part in characterModel:QueryDescendants("BasePart") do
					if collisions[part] == nil then
						collisions[part] = part.CanCollide
					end
					part.CanCollide = false
				end
			end
		end))
		table.insert(connections, UserInputService.JumpRequest:Connect(function()
			if Library.Unloaded then
				return
			end
			local characterModel = LocalPlayer.Character
			local humanoid = characterModel and characterModel:FindFirstChildOfClass("Humanoid")
			if Toggles.InfJump.Value and humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end))
		table.insert(connections, RunService.RenderStepped:Connect(function(dt)
			if Library.Unloaded then
				return
			end
			local characterModel = LocalPlayer.Character
			local humanoid = characterModel and characterModel:FindFirstChildOfClass("Humanoid")
			local root = characterModel and characterModel:FindFirstChild("HumanoidRootPart")
			local camera = Workspace.CurrentCamera
			if Toggles.WalkSpeedEnabled.Value and humanoid then
				if speeds[humanoid] == nil then
					speeds[humanoid] = humanoid.WalkSpeed
				end
				humanoid.WalkSpeed = Options.WalkSpeed.Value
			end
			if Toggles.Fly.Value and root and humanoid and camera then
				if platforms[humanoid] == nil then
					platforms[humanoid] = humanoid.PlatformStand
				end
				humanoid.PlatformStand = true
				local direction = Vector3.zero
				if not UserInputService:GetFocusedTextBox() then
					if UserInputService:IsKeyDown(Enum.KeyCode.W) then
						direction += camera.CFrame.LookVector
					end
					if UserInputService:IsKeyDown(Enum.KeyCode.S) then
						direction -= camera.CFrame.LookVector
					end
					if UserInputService:IsKeyDown(Enum.KeyCode.A) then
						direction -= camera.CFrame.RightVector
					end
					if UserInputService:IsKeyDown(Enum.KeyCode.D) then
						direction += camera.CFrame.RightVector
					end
					if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
						direction += Vector3.new(0, 1, 0)
					end
					if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
						direction -= Vector3.new(0, 1, 0)
					end
				end
				root.AssemblyLinearVelocity = Vector3.zero
				if direction.Magnitude > 0 then
					root.CFrame += direction.Unit * Options.FlySpeed.Value * dt
				end
			end
		end))
		API.Track(function()
			for _, connection in connections do
				connection:Disconnect()
			end
			restoreCollisions()
			restoreSpeeds()
			restoreFlight()
			restorePrompts()
		end)
	end
	setupPlayerTab()
	local function setupSettings()
		local connections = {}
		local effects = {}
		local renderDefaults
		local reconnecting = false
		local reconnectToken = 0
		local triggers = 0
		local lastPulse = os.clock()
		local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu", "logs")
		MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
		local AfkLabel = MenuGroup:AddLabel("AFK triggers: 0")
		local function pulse()
			local camera = Workspace.CurrentCamera
			if not camera or not callable(VirtualUser.CaptureController) or not callable(VirtualUser.ClickButton2) then
				return false
			end
			local ok = pcall(function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new(0, 0), camera.CFrame)
			end)
			if not ok then
				return false
			end
			triggers += 1
			lastPulse = os.clock()
			pcall(function()
				AfkLabel:SetText("AFK triggers: " .. triggers)
			end)
			return true
		end
		local function applyPause(enabled)
			pcall(function()
				GuiService:SetGameplayPausedNotificationEnabled(not enabled)
			end)
			pcall(function()
				local notification = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
				if notification then
					notification.Enabled = not enabled
				end
			end)
			if not enabled then
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
		local function stripEffect(instance)
			if instance.ClassName == "ParticleEmitter" or instance.ClassName == "Trail" or instance.ClassName == "Smoke" or instance.ClassName == "Fire" or instance.ClassName == "Sparkles" or instance.ClassName == "Explosion" or instance.ClassName == "Beam" then
				if effects[instance] == nil then
					effects[instance] = instance.Enabled
				end
				pcall(function()
					instance.Enabled = false
				end)
			end
		end
		local function restoreEffects()
			for instance, value in effects do
				if instance.Parent then
					pcall(function()
						instance.Enabled = value
					end)
				end
			end
			table.clear(effects)
			if renderDefaults then
				pcall(function()
					settings().Rendering.QualityLevel = renderDefaults.Quality
				end)
				Lighting.GlobalShadows = renderDefaults.Shadows
				Lighting.FogEnd = renderDefaults.Fog
				renderDefaults = nil
			end
		end
		MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
		MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
		MenuGroup:AddToggle("Disable3D", {
			Text = "Disable 3D Rendering",
			Default = false,
			Callback = function(value)
				pcall(function()
					RunService:Set3dRenderingEnabled(not value)
				end)
			end,
		})
		MenuGroup:AddToggle("FpsBoost", {
			Text = "FPS Boost",
			Default = false,
			Callback = function(value)
				if value then
					if not renderDefaults then
						renderDefaults = {
							Quality = settings().Rendering.QualityLevel,
							Shadows = Lighting.GlobalShadows,
							Fog = Lighting.FogEnd,
						}
					end
					pcall(function()
						settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
					end)
					Lighting.GlobalShadows = false
					Lighting.FogEnd = 9e9
					for _, instance in Workspace:QueryDescendants("ParticleEmitter,Trail,Smoke,Fire,Sparkles,Beam") do
						pcall(stripEffect, instance)
					end
				else
					restoreEffects()
				end
			end,
		})
		MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
		MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
			Default = "RightShift",
			NoUI = true,
			Text = "Menu keybind",
		})
		Library.ToggleKeybind = Options.MenuKeybind
		applyPause(true)
		local ScriptGroup = Tabs.Settings:AddLeftGroupbox("Script", "terminal")
		ScriptGroup:AddButton({
			Text = "Unload Script",
			Func = function()
				Library:Unload()
			end,
		})
		Toggles.AntiGameplayPause:OnChanged(function()
			applyPause(Toggles.AntiGameplayPause.Value)
		end)
		if Toggles.AntiGameplayPause.Value then
			applyPause(true)
		end
		table.insert(connections, LocalPlayer.Idled:Connect(function()
			if Toggles.AntiAfk.Value and not Library.Unloaded then
				pulse()
			end
		end))
		table.insert(connections, Workspace.DescendantAdded:Connect(function(instance)
			if Toggles.FpsBoost.Value then
				stripEffect(instance)
			end
		end))
		local function rejoin(fresh)
			if reconnecting or Library.Unloaded or not Toggles.AutoReconnect.Value then
				return
			end
			reconnecting = true
			local token = reconnectToken
			local ok = pcall(function()
				if fresh then
					TeleportService:Teleport(game.PlaceId, LocalPlayer)
				else
					TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
				end
			end)
			if not ok then
				reconnecting = false
				if not fresh and token == reconnectToken then
					task.delay(1.5, function()
						if token == reconnectToken then
							rejoin(true)
						end
					end)
				end
			end
		end
		table.insert(connections, TeleportService.TeleportInitFailed:Connect(function(player)
			if player == LocalPlayer and reconnecting then
				reconnecting = false
				local token = reconnectToken
				task.delay(3, function()
					if token == reconnectToken then
						rejoin(true)
					end
				end)
			end
		end))
		task.spawn(function()
			local promptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
			local overlay = promptGui and promptGui:WaitForChild("promptOverlay", 30)
			if Library.Unloaded or not overlay then
				return
			end
			table.insert(connections, overlay.ChildAdded:Connect(function(child)
				if child.Name == "ErrorPrompt" then
					rejoin(false)
				end
			end))
		end)
		local menuTask = task.spawn(function()
			while not Library.Unloaded do
				if Toggles.AntiGameplayPause.Value then
					applyPause(true)
				end
				if Toggles.AntiAfk.Value and os.clock() - lastPulse >= 60 then
					pulse()
				end
				task.wait(1)
			end
		end)
		API.Track(function()
			reconnectToken += 1
			for _, connection in connections do
				connection:Disconnect()
			end
			pcall(task.cancel, menuTask)
			applyPause(false)
			restoreEffects()
			pcall(function()
				RunService:Set3dRenderingEnabled(true)
			end)
		end)
	end
	setupSettings()
	local function setupConfigExport()
		ThemeManager:SetLibrary(Library)
		ThemeManager:SetFolder("MyScriptHub")
		ThemeManager:SaveDefault("Evil Hello Kitty")
		ThemeManager:ApplyToTab(Tabs.Settings)
		SaveManager:SetLibrary(Library)
		SaveManager:IgnoreThemeSettings()
		SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
		SaveManager:SetFolder("TempoHub/UnfreezeAnAnimal")
		local ConfigurationBox = SaveManager:BuildConfigSection(Tabs.Settings)
		local function configElement(objectType, index)
			local holder = objectType == "Toggle" and Toggles or Options
			local element = holder[index]
			return type(element) == "table" and element.Type == objectType and element or nil
		end
		local function encodeConfigObject(index, element)
			local elementType = element.Type
			if elementType == "Toggle" then
				return { idx = index, type = "Toggle", value = element.Value == true }
			elseif elementType == "Slider" then
				return { idx = index, type = "Slider", value = tostring(element.Value) }
			elseif elementType == "Dropdown" then
				return { idx = index, type = "Dropdown", multi = element.Multi == true, value = element.Value }
			elseif elementType == "Input" then
				return { idx = index, type = "Input", text = tostring(element.Value or "") }
			elseif elementType == "ColorPicker" then
				return {
					idx = index,
					type = "ColorPicker",
					value = element.Value:ToHex(),
					transparency = element.Transparency,
				}
			elseif elementType == "KeyPicker" then
				return {
					idx = index,
					type = "KeyPicker",
					mode = element.Mode,
					key = element.Value,
					modifiers = element.Modifiers,
					toggled = element.Toggled,
				}
			end
			return nil
		end
		local function buildConfigPayload()
			local objects = {}
			for _, holder in ipairs({ Toggles, Options }) do
				for index, element in pairs(holder) do
					if type(element) == "table" and type(element.Type) == "string" and not SaveManager.Ignore[index] then
						local encoded = encodeConfigObject(index, element)
						if encoded then
							objects[#objects + 1] = encoded
						end
					end
				end
			end
			table.sort(objects, function(a, b)
				if a.type ~= b.type then
					return a.type < b.type
				end
				return a.idx < b.idx
			end)
			return { objects = objects }
		end
		local function applyConfigObject(object)
			if type(object) ~= "table" or type(object.idx) ~= "string" or type(object.type) ~= "string" or SaveManager.Ignore[object.idx] then
				return false
			end
			local element = configElement(object.type, object.idx)
			if not element then
				return false
			end
			local applied = pcall(function()
				if object.type == "Input" then
					if type(object.text) ~= "string" then
						return
					end
					element:SetValue(object.text)
				elseif object.type == "ColorPicker" then
					element:SetValueRGB(Color3.fromHex(object.value), object.transparency)
				elseif object.type == "KeyPicker" then
					element:SetValue({ object.key, object.mode, object.modifiers })
					if object.mode == "Toggle" and object.toggled ~= nil then
						element.Toggled = object.toggled
						element:Update()
					end
				else
					element:SetValue(object.value)
				end
			end)
			return applied
		end
		ConfigurationBox:AddDivider()
		ConfigurationBox:AddInput("SaveManager_ImportSource", {
			Text = "Paste exported config here",
			Finished = true,
			AllowEmpty = true,
		})
		ConfigurationBox:AddButton("Export Config to Clipboard", function()
			local encodeSuccess, encoded = pcall(HttpService.JSONEncode, HttpService, buildConfigPayload())
			if encodeSuccess then
				local writeClipboard = callable(setclipboard) and setclipboard or (callable(toclipboard) and toclipboard or nil)
				if type(writeClipboard) == "function" and pcall(writeClipboard, encoded) then
					Library:Notify("Config copied to clipboard", 6)
					return
				end
				Library:Notify("Your executor does not support copying to the clipboard")
				return
			end
			Library:Notify("Failed to encode the config")
		end)
		ConfigurationBox:AddButton("Import Config from Clipboard Text", function()
			local source = tostring(Options.SaveManager_ImportSource.Value or ""):match("^%s*(.-)%s*$")
			if source == "" then
				Library:Notify("Paste an exported config into the box first")
				return
			end
			if #source > 262144 then
				Library:Notify("That config is too large")
				return
			end
			local decodeSuccess, decoded = pcall(HttpService.JSONDecode, HttpService, source)
			if not decodeSuccess or type(decoded) ~= "table" or type(decoded.objects) ~= "table" then
				Library:Notify("That is not a valid exported config")
				return
			end
			if #decoded.objects > 2048 then
				Library:Notify("That config has too many records")
				return
			end
			local applied = 0
			for _, object in ipairs(decoded.objects) do
				if applyConfigObject(object) then
					applied += 1
				end
			end
			if applied == 0 then
				Library:Notify("No settings in that config matched this script")
				return
			end
			Options.SaveManager_ImportSource:SetValue("")
			Library:Notify(("Imported %d setting%s"):format(applied, applied == 1 and "" or "s"), 6)
		end)
		ThemeManager:LoadDefault()
		SaveManager:LoadAutoloadConfig()
		if Options.PushRarities then
			API.SetPushRarities(Options.PushRarities.Value)
		end
		if Options.PushAnimals then
			API.SetPushAnimals(Options.PushAnimals.Value)
		end
		if Options.PushVariants then
			API.SetPushVariants(Options.PushVariants.Value)
		end
		if Options.PushPriority then
			API.SetPriority(Options.PushPriority.Value)
		end
		if Options.PowerTier then
			API.SetPowerTier(Options.PowerTier.Value)
		end
		if Options.PowerReserve then
			API.SetPowerReserve(Options.PowerReserve.Value)
		end
		if Toggles.OnlyPushable then
			API.SetOnlyPushable(Toggles.OnlyPushable.Value)
		end
		if Toggles.PushEggs then
			API.SetPushEggs(Toggles.PushEggs.Value)
		end
		if Toggles.AutoCapacity then
			API.SetAutoCapacity(Toggles.AutoCapacity.Value)
		end
		if Toggles.AutoReplace then
			API.SetAutoReplace(Toggles.AutoReplace.Value)
		end
		if Toggles.AutoIndex then
			API.SetAutoIndex(Toggles.AutoIndex.Value)
		end
		if Toggles.AutoPower then
			API.SetAutoPower(Toggles.AutoPower.Value)
		end
		if Toggles.AutoRebirth then
			API.SetAutoRebirth(Toggles.AutoRebirth.Value)
		end
		if Toggles.AutoPush then
			API.SetAutoPush(Toggles.AutoPush.Value)
		end
		if Toggles.HideUiOnStart.Value then
			Library:Toggle(false)
		end
	end
	setupConfigExport()
end
setupInterface()
end)(...)

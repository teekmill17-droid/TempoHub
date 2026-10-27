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
getgenv().TempoHoodSubtitle = "CLEAN THE WORLD!"
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
local jg
local jC
local jj
local i0
local jI
local jm
local i3
local i6
local js
local jO
local jv
local jc
local jf
local jB
local iX
local Library
local Workspace
local i_
local jH
local jo
local jK
local Options
local jN
local i5
local Toggles
local jb
local LocalPlayer
local iW
local jh
local jG
local jk
local i1
local jJ
local jn
local i4
local jq
local jM
local i7
local ja
local jw
local function autoCleanLoop()
    while not Library.Unloaded do
        if Toggles.AutoClean.Value then
            pcall(jB)
        end
        task.wait(0.12)
    end
end
local function fn125()
    local lq = jv("PollutionList")
    for k, v in jw do
        local lr = lq[v] and iX(v)
        if lr then
            local lr_1 = js[v]
            local ls = jh(lr_1)
            local lr_2 = type(ls) == "table" and ls.success == true
            if lr_2 then
                return
            end
        end
    end
end
local function fn155()
    local l_ = jv("BuildList")
    for k, v in i7 do
        local l0 = l_[v] and ja(v)
        if l0 then
            local l0_1 = jh(i1[v])
            local l1 = type(l0_1) == "table" and l0_1.success == true
            if l1 then
                return
            end
        end
    end
end
local function fn187()
    local mu = jh("GetSkillUpgrades")
    if type(mu) ~= "table" then
        return
    end
    local costs = mu.costs
    local currencies = mu.currencies
    local mx = mu.purchased
    local my = type(costs) ~= "table" or type(currencies) ~= "table"
    if my then
        return
    end
    if type(mx) ~= "table" then
        mx = {}
    end
    local my_1 = tonumber(mu.gum) or jC()
    local my_2 = jN()
    for k, v in my_2 do
        local id = v.id
        if currencies[id] == "Gum" then
            local mz = tonumber(costs[id]) or 0
            local mz_1 = jn(mx, id)
            if mz_1 < v.cap and my_1 >= mz then
                local mz_2 = true
                if v.requiredId then
                    mz_2 = jn(mx, v.requiredId) > 0
                end
                if mz_2 then
                    local mz_3 = jh("PurchaseSkillUpgrade", id)
                    local my_4 = type(mz_3) == "table" and mz_3.success == true
                    if my_4 then
                        return
                    end
                end
            end
        end
    end
end
local function fn196()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local kk = leaderstats and leaderstats:FindFirstChild("Gum")
    local kj_1 = kk
    if kk then
        kk = tonumber(kj_1.Value)
    end
    return kk or 0
end
local function fn312(aF)
    local kr = Options[aF]
    local ks = kr and kr.Value
    local kr_1 = {}
    if type(ks) ~= "table" then
        return kr_1
    end
    for k, v in ks do
        if v then
            kr_1[k] = true
        end
    end
    return kr_1
end
local function fn334()
    local la = if not jK() then 1 else 0
    if la == 1 then
        return
    end
    local DropArea = Workspace:FindFirstChild("DropArea")
    if not DropArea then
        return
    end
    for i, child in DropArea:GetChildren() do
        if i4(child) then
            local k6_1 = jq(child)
            if k6_1 == nil then
                jH:FireServer()
            else
                jH:FireServer(k6_1)
            end
            if child.Parent then
                child:Destroy()
            end
            return
        end
    end
end
local function fn352(ae)
    local DiscordGroup = ae:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = i5 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = i5 })
end
local function fn370()
    local PrivateStats = LocalPlayer:FindFirstChild("PrivateStats")
    local ke = PrivateStats and PrivateStats:FindFirstChild("Money")
    local kd_1 = ke
    if ke then
        ke = tonumber(kd_1.Value)
    end
    return ke or 0
end
local function fn392(bW)
    local lV = jh(iW[bW])
    if type(lV) ~= "table" then
        return false
    elseif lV.unlocked == false then
        return false
    else
        local lW = tonumber(lV.count) or 0
        local lW_1 = tonumber(lV.maxCount)
        if lW_1 and lW >= lW_1 then
            return false
        end
        local lW_2 = tonumber(lV.cost) or 0
        return jf() >= lW_2
    end
end
local function fn406(T, U, V)
    return string.format("<b>%s</b> %s %s", T, jI("-", "#5a6070"), jI(U, V))
end
local function fn429(ch, ci)
    local l9 = ch and ch[ci]
    if l9 == true then
        return 1
    end
    local l9_1 = tonumber(l9)
    if l9_1 then
        return math.max(0, math.floor(l9_1))
    end
    return 0
end
local function fn460()
    for i, child in Workspace:GetChildren() do
        local kF = child.Name == "Trash Can" or string.find(child.Name, "Trash Can", 1, true) == 1
        if kF then
            return true
        end
    end
    return false
end
local function fn475(bb)
    local lh = jo[bb]
    local li = jh(lh)
    local lh_1 = jf()
    if bb == "People" then
        local lj_1 = (tonumber(li))
        local lp = if lj_1 then 1 else 0
        local ln = 1503 * lp + 783 * (1 - lp)
        local lo = 1614 * lp + 411 * (1 - lp)
        if not ((ln * 1326 + lo * 1685 + ln * lo) % 16777213 == 7138410) then
            lj_1 = 0
        end
        return lj_1 < 25 and lh_1 > 0
    elseif type(li) ~= "table" then
        return false
    elseif bb == "Gum" then
        if li.unlocked == true then
            return false
        end
        local lj_3 = tonumber(li.cost) or 0
        return lh_1 >= lj_3
    elseif li.unlocked == false then
        return false
    else
        local lj_4 = tonumber(li.count) or 0
        local lj_5 = tonumber(li.maxCount)
        if lj_5 and lj_4 >= lj_5 then
            return false
        end
        local lj_6 = tonumber(li.cost) or 0
        return lh_1 >= lj_6
    end
end
local function fn497()
    jO(false)
    if i_ then
        i_:Disconnect()
    end
    if jM then
        jM:Disconnect()
    end
    local o7 = i0()
    if o7 then
        o7.PlatformStand = false
        o7.WalkSpeed = 16
    end
end
local function fn562(aT)
    local kN = aT:GetAttribute("ThundergumBoosted") == true
    local Name = aT.Name
    if Name == "Poop" then
        local kP_1 = aT:GetAttribute("GlowingPoop") == true
        if aT:GetAttribute("BluePoop") == true then
            if kP_1 then
                return kN and "ThundergumNeonBluePoop" or "NeonBluePoop"
            end
            return kN and "ThundergumBluePoop" or "BluePoop"
        elseif aT:GetAttribute("GoldPoop") == true then
            if kP_1 then
                return kN and "ThundergumNeonGoldPoop" or "NeonGoldPoop"
            end
            return kN and "ThundergumGoldPoop" or "GoldPoop"
        elseif kP_1 then
            return kN and "ThundergumNeonPoop" or "NeonPoop"
        else
            return kN and "ThundergumPoop" or "Poop"
        end
    elseif Name == "Banana" then
        if aT:GetAttribute("DiamondBanana") == true then
            return kN and "ThundergumDiamondBanana" or "DiamondBanana"
        elseif aT:GetAttribute("GoldenBanana") == true then
            return kN and "ThundergumGoldenBanana" or "GoldenBanana"
        else
            return kN and "ThundergumBanana" or "Banana"
        end
    elseif Name == "Egg" then
        if aT:GetAttribute("DiamondEgg") == true then
            return kN and "ThundergumDiamondEgg" or "DiamondEgg"
        elseif aT:GetAttribute("GoldenEgg") == true then
            return kN and "ThundergumGoldenEgg" or "GoldenEgg"
        else
            return kN and "ThundergumEgg" or "Egg"
        end
    elseif aT:GetAttribute("GoldenPaper") == true then
        return kN and "ThundergumGoldenPaper" or "GoldenPaper"
    elseif kN then
        return "Thundergum"
    else
        return nil
    end
end
local function fn580(bB)
    local lA = jh(jc[bB])
    if type(lA) ~= "table" then
        return false
    elseif lA.unlocked == false then
        return false
    else
        local lB = tonumber(lA.level) or 0
        local lB_1 = tonumber(lA.maxLevel) or 10
        if lB >= lB_1 then
            return false
        end
        local lB_2 = tonumber(lA.cost) or 0
        return jf() >= lB_2
    end
end
local function fn609(aY)
    local kZ = not aY:IsA("BasePart") or not aY.Parent
    if kZ then
        return false
    end
    local Name = aY.Name
    if Name == "Paper" then
        return true
    end
    if Name == "Poop" or Name == "Banana" or Name == "Egg" then
        return aY:GetAttribute("TrashReady") == true
    end
    return false
end
local function fn661()
    jm(i3, "Copied Discord invite to clipboard")
end
local function fn678(J, K)
    if setclipboard then
        setclipboard(J)
    elseif toclipboard then
        toclipboard(J)
    end
    Library:Notify(K)
end
local function autoBuyPollutionLoop()
    while not Library.Unloaded do
        task.wait(0.35)
        if Toggles.AutoBuyPollution.Value then
            pcall(jJ)
        end
        if Toggles.AutoBuyUpgrades.Value then
            pcall(i6)
        end
        if Toggles.AutoBuyBuild.Value then
            pcall(jk)
        end
        if Toggles.AutoBuySkillNodes.Value then
            pcall(jb)
        end
    end
end
local function fn748()
    local mf = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Skill")
    local mg = mf
    if mf then
        mf = mg:FindFirstChild("Frame")
    end
    local mg_1 = mf
    if mf then
        mf = mg_1:FindFirstChild("Upgrade")
    end
    local mg_2 = mf
    if not mg_2 then
        return {}
    end
    local mf_1 = {}
    for i, child in mg_2:GetChildren() do
        if child:IsA("GuiButton") then
            local mg_3 = child:GetAttribute("UpgradeName")
            local mh = mg_3 == ""
            local mi = type(mg_3) ~= "string" or mh
            if mi then
                mg_3 = child.Name
            end
            local Cap = child:FindFirstChild("Cap")
            local mi_1 = Cap
            local mj = 1
            if mi_1 then
                local mk_1 = Cap:IsA("NumberValue") or Cap:IsA("IntValue")
                mi_1 = mk_1
            end
            if mi_1 then
                mj = math.max(1, math.floor(Cap.Value))
            end
            local mh_2 = nil
            local Required = child:FindFirstChild("Required")
            local mk_2 = Required and Required:IsA("ObjectValue") and Required.Value
            if mk_2 then
                local Value = Required.Value
                local mi_3 = Value:GetAttribute("UpgradeName")
                local ml = mi_3 == ""
                local mm = type(mi_3) ~= "string" or ml
                if mm then
                    mi_3 = Value.Name
                end
                mh_2 = mi_3
            end
            mf_1[#mf_1 + 1] = { id = mg_3, cap = mj, requiredId = mh_2 }
        end
    end
    return mf_1
end
local function fn801()
    local lI = jv("UpgradeList")
    for k, v in jj do
        local lJ = lI[v] and jG(v)
        if lJ then
            local lJ_1 = jh(jg[v])
            local lK = type(lJ_1) == "table" and lJ_1.success == true
            if lK then
                return
            end
        end
    end
end
local function fn806(Q, R)
    return string.format('<font color="%s">%s</font>', R, Q)
end
iW = nil
iX = nil
i_ = nil
i0 = nil
i1 = nil
i3 = nil
i4 = nil
i5 = nil
i6 = nil
i7 = nil
ja = nil
jb = nil
jc = nil
LocalPlayer = nil
jf = nil
jg = nil
jh = nil
Workspace = nil
jj = nil
jk = nil
jm = nil
jn = nil
jo = nil
jq = nil
Options = nil
js = nil
Toggles = nil
jv = nil
jw = nil
jB = nil
jC = nil
Library = nil
jG = nil
jH = nil
jI = nil
local iY, iZ, i2, i8, i9, jd, CoreGui, GuiService, HttpService, jx, VirtualUser, SaveManager, jA, RunService, jF
jJ = nil
jK = nil
jM = nil
jN = nil
jO = nil
local jL
local jY_1
local jR_1
RunService, jA, VirtualUser, HttpService, GuiService, CoreGui, Workspace, LocalPlayer, i9, i3, iZ, jL, jH, jR_1, jw, js, jo, jj, jg, jc, i7, i1, iW, Library, SaveManager, Toggles, Options, jd, i8, i2, iY, jF, jm, i5, jI, jx = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
jA = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
i9 = "Clean the WORLD!"
i3 = "https://discord.gg/K7Qxnxkk46"
if ((jx or not jx) and (jx or jL) and (false and not jx and (not jF or i2)) or (jI or not jx or jx and i2) and (jL and not jx and "#e8a34d") or (("#e8a34d" or jL and i2) and (jI or jL or not jF and jL) or (jx or jL or jF and jF) and (not jF and jI and (not jI or jF)))) and not ((jx or not jx) and (jx or jL) and (false and not jx and (not jF or i2)) or (jI or not jx or jx and i2) and (jL and not jx and "#e8a34d") or (("#e8a34d" or jL and i2) and (jI or jL or not jF and jL) or (jx or jL or jF and jF) and (not jF and jI and (not jI or jF)))) then
    jL = "https://discord.gg/K7Qxnxkk46"
    local Remotes = jR_1:WaitForChild("Remotes")
    Remotes:WaitForChild("CollectPaper")
    jH = Remotes:WaitForChild("PurchaseSkillUpgrade")
    iZ = Remotes:WaitForChild("GetSkillUpgrades")
else
    iZ = "https://discord.gg/K7Qxnxkk46"
    jL = ReplicatedStorage:WaitForChild("Remotes")
    jH = jL:WaitForChild("CollectPaper")
    jL:WaitForChild("PurchaseSkillUpgrade")
    jL:WaitForChild("GetSkillUpgrades")
end
jw = { "People", "Gum", "Horse", "Unicorn", "Gorilla", "DINOSAUR" }
js = {
    People = "PurchaseNPC",
    Gum = "PurchaseGum",
    Horse = "PurchaseHorse",
    Unicorn = "PurchaseUnicorn",
    Gorilla = "PurchaseGorilla",
    DINOSAUR = "PurchaseDinosaur"
}
jo = {
    People = "GetNPCCount",
    Gum = "GetGum",
    Horse = "GetHorseCount",
    Unicorn = "GetUnicornCount",
    Gorilla = "GetGorillaCount",
    DINOSAUR = "GetDinosaurCount"
}
jj = { "Paper", "Poop", "Banana", "Egg" }
jg = {
    Paper = "PurchasePaperUpgrade",
    Poop = "PurchasePoopUpgrade",
    Banana = "PurchaseBananaUpgrade",
    Egg = "PurchaseEggUpgrade"
}
jc = {
    Paper = "GetPaperUpgrade",
    Poop = "GetPoopUpgrade",
    Banana = "GetBananaUpgrade",
    Egg = "GetEggUpgrade"
}
i7 = { "Rat", "Thundergum", "Seagull", "Seaweed" }
i1 = {
    Rat = "PurchaseRat",
    Thundergum = "PurchaseThundergum",
    Seagull = "PurchaseSeagull",
    Seaweed = "PurchaseSeaweed"
}
iW = {
    Rat = "GetRatCount",
    Thundergum = "GetThundergumCount",
    Seagull = "GetSeagullCount",
    Seaweed = "GetSeaweed"
}
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
jm = fn678
i5 = fn661
jI = fn806
jx = fn406
jd = "#7fd47f"
i8 = "#6ec1ff"
i2 = "#e8a34d"
if (not js or false) and (not jF and Toggles) and false or not ((not js or false) and (not jF and Toggles) and false) then
    iY = "#8b93a3"
else
    jA = "#8b93a3"
end
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = i3, Copyable = true }, "|", i9 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
jF = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "sparkles"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in jF do
    fn352(v)
end
i0, jO, i_, jM, jf, jC, jh, jv, jK, jq, i4, jB, iX, jJ, jG, i6, ja, jk, jn, jN, jb, jY_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
jf = fn370
jC = fn196
jh = function(aw, ...)
    local km
    local kn
    km = nil
    kn = nil
    local kp_1
    local ko_1
    kn = jL:FindFirstChild(aw)
    if not kn then
        return nil
    end
    km = { ... }
    ko_1, kp_1 = pcall(function()
        return kn:InvokeServer(table.unpack(km))
    end)
    if ko_1 then
        return kp_1
    end
    return nil
end
jv = fn312
jK = fn460
jq = fn562
i4 = fn609
jB = fn334
iX = fn475
jJ = fn125
jG = fn580
if ((not jC or not jq) and (iX or not jq) and ((jY_1 or iX) and (not jq and false)) or (not jq and iX or (jY_1 or jq) or jC and jC and (jY_1 or jY_1))) and not ((not jC or not jq) and (iX or not jq) and ((jY_1 or iX) and (not jq and false)) or (not jq and iX or (jY_1 or jq) or jC and jC and (jY_1 or jY_1))) then
    jk = fn801
    jn = fn392
    ja = fn155
    i6 = fn429
else
    i6 = fn801
    ja = fn392
    jk = fn155
    jn = fn429
end
jN = fn748
jb = fn187
local function jQ()
    local mZ
    mZ = nil
    local mX, mY, Label
    mZ = "Unknown"
    pcall(function()
        local mN_1
        local mM_1
        if identifyexecutor then
            mN_1, mM_1 = identifyexecutor()
            local mO = mN_1 ~= ""
            local mP = type(mN_1) == "string" and mO
            if mP then
                local mO_1 = type(mM_1) == "string" and mM_1 ~= "" and mN_1 .. " " .. mM_1
                mZ = mO_1 or mN_1
            end
        end
    end)
    local AccountGroup = jF.Info:AddLeftGroupbox("Account", "circle-user")
    AccountGroup:AddLabel(jx("User", LocalPlayer.Name, jd), true)
    AccountGroup:AddLabel(jx("Status", "Keyless", jd), true)
    AccountGroup:AddLabel(jx("Executor", mZ, jd), true)
    local GameInfoGroup = jF.Info:AddLeftGroupbox("Game Info", "gamepad-2")
    GameInfoGroup:AddLabel(jI(i9 .. " [" .. tostring(game.PlaceId) .. "]", i8), true)
    GameInfoGroup:AddLabel(jx("Place ID", tostring(game.PlaceId), i8), true)
    Label = GameInfoGroup:AddLabel(jx("Session time", "0s", i2), true)
    mY = tostring(game.JobId)
    local m2 = #mY > 18 and string.sub(mY, 1, 18) .. "..."
    local m2_1 = m2 or mY
    GameInfoGroup:AddLabel(jx("Server", m2_1, iY), true)
    GameInfoGroup:AddButton({
        Text = "Copy join script (Job ID)",
        Func = function()
            local db = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, mY)
            jm(db, "Copied join script to clipboard")
        end
    })
    mX = os.clock()
    task.spawn(function()
        local mV_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            local mU = math.floor(os.clock() - mX)
            if mU < 60 then
                mV_1 = mU .. "s"
            elseif mU < 3600 then
                mV_1 = string.format("%dm %ds", math.floor((mU) / (60)), mU % 60)
            else
                mV_1 = string.format("%dh %dm", math.floor((mU) / (3600)), math.floor((mU % 3600) / (60)))
            end
            Label:SetText(jx("Session time", mV_1, i2))
        end
    end)
    local ScriptsGroup = jF.Info:AddRightGroupbox("Scripts", "package")
    ScriptsGroup:AddLabel(jI("Included in this hub", iY), true)
    ScriptsGroup:AddLabel(jI(i9, i8), true)
    local FeaturesGroup = jF.Info:AddRightGroupbox("Features", "list")
    FeaturesGroup:AddLabel(jI("Automation", i8), true)
    FeaturesGroup:AddLabel(jI("Misc Utilities", iY), true)
    local SocialsGroup = jF.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = i5 })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            jm(iZ, "Copied Rscripts profile to clipboard")
        end
    })
    local TempoHubGroup = jF.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
    TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = i5 })
    local m1_6 = {
        LTC = {
            address = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w",
            color = "#345d9d",
            label = "LTC / Litecoin",
            button = "Copy Litecoin Address",
            message = "Copied Litecoin address"
        },
        BTC = {
            address = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99",
            color = "#f7931a",
            label = "BTC / Bitcoin",
            button = "Copy Bitcoin Address",
            message = "Copied Bitcoin address"
        },
        ETH = {
            address = "0xaE95A405D007a6F858E5d35714111B075fEFb40a",
            color = "#627eea",
            label = "ETH / Ethereum",
            button = "Copy Ethereum Address",
            message = "Copied Ethereum address"
        },
        USDT = {
            address = "0xaE95A405D007a6F858E5d35714111B075fEFb40a",
            color = "#26a17b",
            label = "USDT",
            button = "Copy USDT Address",
            message = "Copied USDT address"
        },
        SOL = {
            address = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp",
            color = "#14f195",
            label = "Solana",
            button = "Copy Solana Address",
            message = "Copied Solana address"
        },
        PAYPAL = {
            address = "",
            color = "#0070ba",
            label = "PayPal",
            button = "Copy PayPal Link",
            message = "Copied PayPal link"
        },
        VENMO = {
            address = "",
            color = "#008cff",
            label = "Venmo",
            button = "Copy Venmo Link",
            message = "Copied Venmo link"
        }
    }
    local DonationsGroup = jF.Info:AddRightGroupbox("Donations", "heart")
    DonationsGroup:AddLabel(jI("All donations are optional but appreciated.", i2), true)
    DonationsGroup:AddLabel(jI("If you donate you get a special role, just PING after you donate.", jd), true)
    DonationsGroup:AddDivider()
    for k, v in { "LTC", "BTC", "ETH", "USDT", "SOL", "PAYPAL", "VENMO" } do
        local m_
        m_ = m1_6[v]
        DonationsGroup:AddLabel(jI(m_.label, m_.color), true)
        DonationsGroup:AddButton({
            Text = m_.button,
            Func = function()
                jm(m_.address, m_.message)
            end
        })
    end
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(jI("Don't have any of the listed currencies but still wanna donate?", iY), true)
    DonationsGroup:AddLabel(jI("DM me and we'll work something out.", i8), true)
    local FaqGroup = jF.Info:AddRightGroupbox("FAQ", "circle-help")
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
end
jQ()
local AutomationGroup = jF.Main:AddLeftGroupbox("Automation", "bot")
AutomationGroup:AddToggle("AutoClean", { Text = "Auto Clean", Default = false })
AutomationGroup:AddToggle("AutoBuyPollution", { Text = "Auto Buy Pollution", Default = false })
AutomationGroup:AddDropdown("PollutionList", { Text = "Pollution", Values = jw, Default = jw, Multi = true, SelectAllButtons = true })
AutomationGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
AutomationGroup:AddDropdown("UpgradeList", { Text = "Upgrades", Values = jj, Default = jj, Multi = true, SelectAllButtons = true })
AutomationGroup:AddToggle("AutoBuyBuild", { Text = "Auto Buy Build", Default = false })
AutomationGroup:AddDropdown("BuildList", { Text = "Build", Values = i7, Default = i7, Multi = true, SelectAllButtons = true })
AutomationGroup:AddToggle("AutoBuySkillNodes", { Text = "Auto Buy Affordable Skill Tree Nodes", Default = false })
task.spawn(autoCleanLoop)
task.spawn(autoBuyPollutionLoop)
local function jT_1()
    local MovementGroup = jF.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    local FlyGroup = jF.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local function dT()
        local Character = LocalPlayer.Character
        local ne = Character and Character:FindFirstChildOfClass("Humanoid")
        return ne
    end
    local function dY()
        local Character = LocalPlayer.Character
        local nh = Character and Character:FindFirstChild("HumanoidRootPart")
        return nh
    end
    local function d1(d2)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not d2)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not d2
            end
        end)
        if not d2 then
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
    RunService.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = LocalPlayer.Character
            if Character then
                for i, descendant in Character:GetDescendants() do
                    local nq_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if nq_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    jA.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local ny_1 = dT()
            if ny_1 then
                ny_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    local CurrentCamera = Workspace.CurrentCamera
    RunService.RenderStepped:Connect(function(ex)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local nA_1 = dT()
            if nA_1 then
                nA_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local nA_3 = dY()
            local nB = dT()
            if nA_3 and nB then
                nB.PlatformStand = true
                local nB_1 = Vector3.zero
                if jA:IsKeyDown(Enum.KeyCode.W) then
                    nB_1 += CurrentCamera.CFrame.LookVector
                end
                if jA:IsKeyDown(Enum.KeyCode.S) then
                    nB_1 -= CurrentCamera.CFrame.LookVector
                end
                if jA:IsKeyDown(Enum.KeyCode.A) then
                    nB_1 -= CurrentCamera.CFrame.RightVector
                end
                if jA:IsKeyDown(Enum.KeyCode.D) then
                    nB_1 += CurrentCamera.CFrame.RightVector
                end
                if jA:IsKeyDown(Enum.KeyCode.Space) then
                    nB_1 += Vector3.new(0, 1, 0)
                end
                if jA:IsKeyDown(Enum.KeyCode.LeftControl) then
                    nB_1 -= Vector3.new(0, 1, 0)
                end
                nA_3.AssemblyLinearVelocity = Vector3.zero
                if nB_1.Magnitude > 0 then
                    nA_3.CFrame = nA_3.CFrame + nB_1.Unit * Options.FlySpeed.Value * ex
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local nH = dT()
            if nH then
                nH.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local nM = dT()
            if nM then
                nM.WalkSpeed = 16
            end
        end
    end)
    Toggles.AntiGameplayPause:OnChanged(function()
        d1(Toggles.AntiGameplayPause.Value)
    end)
    d1(true)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                d1(true)
            end
        end
    end)
    return dT, d1
end
i0, jO = jT_1()
local function jY_2(e_)
    local e0
    e0 = tick()
    local e1 = tick()
    pcall(function()
        for k, v in getconnections(LocalPlayer.Idled) do
            local nY = v
            pcall(function()
                nY:Disable()
            end)
        end
    end)
    local function e7()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then
            return
        end
        VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
        task.wait(0.1)
        VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
        e1 = tick()
    end
    local connection2 = jA.InputBegan:Connect(function()
        e0 = tick()
    end)
    local connection = jA.InputChanged:Connect(function(fh)
        local UserInputType = fh.UserInputType
        if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
            e0 = tick()
        end
    end)
    e_:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            if Toggles.AntiAfk.Value then
                local n3 = tick() - e0
                local n4 = tick() - e1
                if n3 >= 300 and n4 >= 60 then
                    pcall(e7)
                else
                    if n3 < 300 and n4 >= 300 then
                        pcall(e7)
                    end
                end
            end
        end
    end)
    return connection2, connection
end
local MenuGroup = jF.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
i_, jM = jY_2(MenuGroup)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(jF.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/CleanTheWorld")
local jV_1 = SaveManager:BuildConfigSection(jF.Settings)
SaveManager:LoadAutoloadConfig()
local function jU(fC)
    local function fD(fE, fF)
        local n8_1 = (fE == "Toggle" and Toggles or Options)[fF]
        local n7_2 = type(n8_1) == "table" and n8_1.Type == fE
        return n7_2 and n8_1 or nil
    end
    local function fN(fO, fP)
        local Type = fP.Type
        if Type == "Toggle" then
            return { idx = fO, type = "Toggle", value = fP.Value == true }
        elseif Type == "Slider" then
            return { idx = fO, type = "Slider", value = tostring(fP.Value) }
        elseif Type == "Dropdown" then
            return { idx = fO, type = "Dropdown", multi = fP.Multi == true, value = fP.Value }
        elseif Type == "Input" then
            local oc = fP.Value
            local og = if oc then 1 else 0
            local oe = 155 * og + 1141 * (1 - og)
            local of = 880 * og + 246 * (1 - og)
            if not ((oe * 2944 + of * 1680 + oe * of) % 16777213 == 2071120) then
                oc = ""
            end
            return { idx = fO, type = "Input", text = tostring(oc) }
        elseif Type == "ColorPicker" then
            return { idx = fO, type = "ColorPicker", value = fP.Value:ToHex(), transparency = fP.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = fO,
                type = "KeyPicker",
                mode = fP.Mode,
                key = fP.Value,
                modifiers = fP.Modifiers,
                toggled = fP.Toggled
            }
        else
            return nil
        end
    end
    local function fR()
        local oi = {}
        for k, v in { Toggles, Options } do
            for k, v in v do
                local oj = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if oj then
                    local oj_1 = fN(k, v)
                    if oj_1 then
                        oi[#oi + 1] = oj_1
                    end
                end
            end
        end
        table.sort(oi, function(f0, f1)
            if f0.type ~= f1.type then
                return f0.type < f1.type
            end
            return f0.idx < f1.idx
        end)
        return { objects = oi }
    end
    local function f2(f3)
        local oI
        oI = nil
        local oJ = type(f3) ~= "table" or type(f3.idx) ~= "string" or type(f3.type) ~= "string" or SaveManager.Ignore[f3.idx]
        if oJ then
            return false
        end
        oI = fD(f3.type, f3.idx)
        if not oI then
            return false
        end
        local oJ_1 = pcall(function()
            if f3.type == "Input" then
                if type(f3.text) ~= "string" then
                    return
                end
                oI:SetValue(f3.text)
            elseif f3.type == "ColorPicker" then
                oI:SetValueRGB(Color3.fromHex(f3.value), f3.transparency)
            elseif f3.type == "KeyPicker" then
                oI:SetValue({ f3.key, f3.mode, f3.modifiers })
                if f3.mode == "Toggle" and f3.toggled ~= nil then
                    oI.Toggled = f3.toggled
                    oI:Update()
                end
            else
                oI:SetValue(f3.value)
            end
        end)
        return oJ_1
    end
    fC:AddDivider()
    fC:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    fC:AddButton("Export Config to Clipboard", function()
        local oP_1
        local oO_1
        oO_1, oP_1 = pcall(HttpService.JSONEncode, HttpService, fR())
        if not oO_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local oO_2 = setclipboard or toclipboard
        local oO_3 = type(oO_2) ~= "function"
        local oU = if oO_3 then 1 else 0
        local oS = 1373 * oU + 2284 * (1 - oU)
        local oT = 3083 * oU + 447 * (1 - oU)
        if not ((oS * 1757 + oT * 2894 + oS * oT) % 16777213 == 15567522) then
            oO_3 = not pcall(oO_2, oP_1)
        end
        if oO_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    fC:AddButton("Import Config from Clipboard Text", function()
        local oX_1
        local oV = Options.SaveManager_ImportSource.Value or ""
        local oV_1
        local oW = tostring(oV):match("^%s*(.-)%s*$")
        if oW == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        oV_1, oX_1 = pcall(HttpService.JSONDecode, HttpService, oW)
        local oW_1 = not oV_1 or type(oX_1) ~= "table" or type(oX_1.objects) ~= "table"
        if oW_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local oV_2 = 0
        for k, v in oX_1.objects do
            if f2(v) then
                oV_2 += 1
            end
        end
        if oV_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local oX_2 = oV_2 == 1 and ""
        local o6 = if oX_2 then 1 else 0
        local o4 = 2207 * o6 + 478 * (1 - o6)
        local o5 = 1726 * o6 + 145 * (1 - o6)
        if not ((o4 * 482 + o5 * 404 + o4 * o5) % 16777213 == 5570360) then
            oX_2 = "s"
        end
        Library:Notify(("Imported %d setting%s"):format(oV_2, oX_2), 6)
    end)
end
jU(jV_1)
Library:OnUnload(fn497)
end)(...)

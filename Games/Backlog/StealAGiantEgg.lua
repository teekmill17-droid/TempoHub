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
	local keyless = false
	pcall(function()
		local c = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/control.json?t=" .. tostring(os.time())))
		keyless = c.keyRequired == false
	end)
	if not keyless then
		local key = g.__TempoKey or g.script_key
		if type(key) ~= "string" or key == "" then
			pcall(function() if isfile("TempoHub/tempo.key") then key = readfile("TempoHub/tempo.key") end end)
		end
		key = type(key) == "string" and key:gsub("%s+", "") or ""
		local ok, why = false, "no key"
		for try = 1, (key ~= "" and 2 or 0) do
			local src
			pcall(function() src = game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/Key.lua?t=" .. tostring(os.time())) end)
			local fn = src and loadstring(src)
			if not fn then
				why = "couldn't check your key, try again in a minute"
			else
				local ran, a, b = pcall(fn, { verify = key })
				if not ran then why = "key check failed, try again in a minute" beacon("check crashed: " .. tostring(a))
				else ok, why = a == true, b end
			end
			if ok or not (type(why) == "string" and (why:find("reach") or why:find("try again"))) then break end
			task.wait(3)
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
getgenv().TempoHoodSubtitle = "STEAL A GIANT EGG"
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
local uh
local uZ
local uG
local un
local u4
local ut
local va
local uS
local uz
local ug
local State
local um
local u3
local uL
local us
local u9
local t9
local uy
local uf
local uX
local u2
local ur
local u8
local t8
local uQ
local ux
local ue
local uW
local uD
local uJ
local uq
local u7
local t7
local uP
local uw
local vd
local LocalPlayer
local uV
local uC
local u0
local uI
local u6
local t6
local uO
local uv
local vc
local uc
local uB
local ui
local uH
local uo
local CollectionService
local uN
local vb
local ub
local uT
local CoreGui
local function fn48(cT)
    local xZ = os.clock()
    local x0 = xZ + (cT or 20)
    while true do
        local xZ_1 = uh() and uW() and os.clock() < x0
        if xZ_1 then
            task.wait(0.15)
            continue
        end
        break
    end
    return not uW()
end
local function fn52()
    local zK_1
    local zG = uf("PlotConfigurations")
    local zG_4
    local zH = uX()
    if not zH then
        return
    end
    local zI = zG and tonumber(zG.MaxSlots)
    local zI_2
    local zJ = zI
    local zJ_2
    if zI then
        zI = zH >= zJ
    end
    if zI then
        return
    end
    local zI_1 = nil
    local zJ_1 = zG and ut(zG.GetUpgradePrice)
    if zJ_1 then
        zJ_2, zK_1 = pcall(zG.GetUpgradePrice, zH + 1)
        local zL = zJ_2 and tonumber(zK_1)
        local zJ_3 = zL
        local zP_1 = if zJ_3 then 1 else 0
        local zN_1 = 3880 * zP_1 + 75 * (1 - zP_1)
        local zO_1 = 32 * zP_1 + 2717 * (1 - zP_1)
        if not ((zN_1 * 2416 + zO_1 * 1327 + zN_1 * zO_1) % 16777213 == 9540704) then
            zJ_3 = nil
        end
        zI_1 = zJ_3
    end
    local zJ_4 = not zI_1
    if zJ_4 ~= false then
        zJ_4 = zG
    end
    if zJ_4 then
        zJ_4 = type(zG.Upgrades) == "table"
    end
    if zJ_4 then
        local zJ_5 = zG.Upgrades[zH + 1]
        local zP_2 = if zJ_5 then 1 else 0
        local zN_2 = 3974 * zP_2 + 1124 * (1 - zP_2)
        local zO_2 = 3094 * zP_2 + 3116 * (1 - zP_2)
        if not ((zN_2 * 1781 + zO_2 * 3175 + zN_2 * zO_2) % 16777213 == 12419487) then
            zJ_5 = zG.Upgrades[tostring(zH + 1)]
        end
        local zG_1 = zJ_5
        if zJ_5 then
            zJ_5 = tonumber(zG_1.Price)
        end
        zI_1 = zJ_5 or nil
    end
    local zG_3 = zI_1 and uy() < zI_1
    if zG_3 then
        return
    end
    zG_4, zI_2 = t6("RequestPlotUpgrade")
    local zJ_6 = zG_4 and type(zI_2) == "table" and zI_2.Success
    if zJ_6 then
        uB("Unlocked pet slot " .. tostring(zH + 1))
    end
end
local function fn53(h3)
    local BO = tonumber(h3) or 30
    uw.interval = math.max(5, BO)
end
local function fn80(eY)
    if eY then
        us(vc, vc.Step)
    else
        uo(vc)
    end
end
local function fn85(jg)
    if jg then
        if not uD.lookup then
            task.spawn(function()
                local jh, ji = vb()
                uD.lookup = jh
                uD.colors = ji
            end)
        end
        us(uD, uD.Step)
    else
        uo(uD)
        u8()
    end
end
local function fn105(ez)
    local y5_1
    local y4_1
    local yZ = tonumber(ez:GetAttribute("HatchTimeOverride"))
    local y_ = uf("EggSizeSystem")
    local y__3
    local y0 = uf("EggConfigurations")
    local y0_5
    local y1 = uf("GlobalEvents")
    if not yZ then
        local attr = ez:GetAttribute("OriginalName")
        local y3 = y0 and type(y0.EggSettings) == "table" and y0.EggSettings[attr]
        local y2_1 = y3 and tonumber(y3.HatchTime)
        local y0_2 = y2_1
        local y9 = if y0_2 then 1 else 0
        local y7 = 1312 * y9 + 932 * (1 - y9)
        local y8 = 3527 * y9 + 1299 * (1 - y9)
        if not ((y7 * 2887 + y8 * 3045 + y7 * y8) % 16777213 == 2377670) then
            y0_2 = 5
        end
        local y2_2 = y_
        local y3_1 = y0_2
        if y2_2 then
            y2_2 = ut(y_.GetHatchTime)
        end
        if y2_2 then
            local GetHatchTime = y_.GetHatchTime
            local y2_3 = ez:GetAttribute("EggSize") or "Normal"
            y4_1, y5_1 = pcall(GetHatchTime, y3_1, y2_3)
            local y__1 = y4_1 and tonumber(y5_1)
            yZ = y__1 or y3_1
        else
            yZ = y3_1
        end
    end
    local y__2 = y1 and ut(y1.GetHatchMultiplier)
    if y__2 then
        y__3, y0_5 = pcall(y1.GetHatchMultiplier)
        if y__3 then
            local y0_6 = tonumber(y0_5)
            if y0_6 and y0_6 > 0 then
                yZ = yZ / y0_6
            end
        end
    end
    return yZ
end
local function fn170()
    local wC = u9()
    local wD = wC and wC:FindFirstChild("EggHatch")
    local wC_1 = wD
    if wD then
        wD = wC_1:IsA("BasePart")
    end
    if wD then
        return wC_1
    end
    return nil
end
local function fn172()
    uH("EquipBestPets")
end
local function fn190(gn)
    if gn then
        us(uN, uN.Step)
    else
        uo(uN)
    end
end
local function fn208()
    local yi_1
    local yh_1
    local yn = if uW() then 1 else 0
    if yn == 1 then
        if ub.returnHome then
            ug()
        end
        ue(12)
        return
    end
    yh_1, yi_1 = ur()
    if not yi_1 then
        uB("Waiting for character")
        return
    end
    local yh_2 = uO()
    if #yh_2 == 0 then
        uB("No egg matches the filters")
        return
    end
    local yi_2 = yh_2[1]
    if not u6(yi_2.Anchor.Position, 4) then
        uB("Could not reach the egg")
        return
    end
    task.wait(0.55)
    if not yi_2.Anchor.Parent then
        return
    end
    if not uq(yi_2.Prompt) then
        uB("Prompt firing is unavailable")
        return
    end
    local yh_3 = os.clock() + 3
    while true do
        local yj = uh() and not uW() and os.clock() < yh_3
        if yj then
            task.wait(0.1)
            continue
        end
        break
    end
    if not uW() then
        uB("Missed " .. tostring(yi_2.Name))
        return
    end
    uB("Stealing " .. tostring(yi_2.Name))
    if ub.returnHome then
        task.wait(0.15)
        ug()
    end
    ue(12)
end
local function fn236()
    local za = 0
    for i, v in ipairs(um()) do
        if v:GetAttribute("IsEgg") == true then
            local zb_1 = tonumber(v:GetAttribute("HatchStartTime"))
            local zc_1 = zb_1 and va:GetServerTimeNow() - zb_1 >= uS(v)
            if zc_1 then
                if uH("RequestHatch", v) then
                    za += 1
                    task.wait(0.35)
                end
            end
        end
    end
    if za > 0 then
        local zc_2 = za == 1 and "" or "s"
        uB(("Hatched %d egg%s"):format(za, zc_2))
    end
end
local function fn242()
    uo(ub)
    uo(t9)
    uo(vc)
    uo(u4)
    uo(u0)
    uo(uV)
    uo(uN)
    uo(uG)
    uo(uw)
    uo(uD)
end
local function fn258(dE)
    ub.zones = dE
end
local function fn265(cd)
    local Parent = cd.Parent
    local xz = Parent and Parent:IsA("BasePart")
    if xz then
        return Parent
    end
    local xz_1 = Parent and Parent:IsA("Model")
    if xz_1 then
        local xz_2 = Parent.PrimaryPart or Parent:FindFirstChildWhichIsA("BasePart", true)
        return xz_2
    end
    return nil
end
local function fn280(ai)
    State.Status = tostring(ai)
end
local function fn303(h_)
    uw.keep = h_
end
local function fn319()
    local wI = uT()
    if not wI then
        return {}
    end
    local wJ = {}
    for i, child in ipairs(wI:GetChildren()) do
        if child:IsA("Model") then
            table.insert(wJ, child)
        end
    end
    return wJ
end
local function fn333()
    local BR_1
    local BQ_1
    if ut(gethui) then
        BQ_1, BR_1 = pcall(gethui)
        local BS = BQ_1 and typeof(BR_1) == "Instance"
        if BS then
            return BR_1
        end
        return CoreGui
    end
    return CoreGui
end
local function fn388()
    for k, v in pairs(uD.entries) do
        if v.Gui then
            v.Gui:Destroy()
        end
        if v.Highlight then
            v.Highlight:Destroy()
        end
        uD.entries[k] = nil
    end
    if uD.Folder then
        uD.Folder:Destroy()
        uD.Folder = nil
    end
end
local function fn407()
    local AX_1
    local AW_1
    local AV_1
    local AU_1
    local AT = u2()
    if #AT == 0 then
        return
    end
    AU_1, AV_1 = uZ(uG.trails)
    AW_1, AX_1 = uI()
    for i, v in ipairs(AT) do
        local AY_1 = not AW_1[v.ID]
        if AY_1 ~= false then
            AY_1 = AV_1 == 0 or AU_1[v.Name] or AU_1[v.ID]
        end
        if AY_1 then
            if uy() >= v.Price then
                uH("TrailAction", "BuyMoney", v.ID)
                uB("Bought " .. v.Name)
                task.wait(0.6)
                AW_1, AX_1 = uI()
            end
        end
    end
    local AY_2 = nil
    for i, v in ipairs(AT) do
        local AT_1 = AW_1[v.ID]
        if AT_1 then
            AT_1 = not AY_2 or v.SpeedBoost > AY_2.SpeedBoost
        end
        if AT_1 then
            AY_2 = v
        end
    end
    if AY_2 and AX_1 and AX_1.Value ~= AY_2.ID then
        uH("TrailAction", "Equip", AY_2.ID)
    end
end
local function fn426()
    local BU = uf("AnimalConfigurations")
    local BV = uf("RarityConfigurations")
    local BW = {}
    local BX = {}
    local BY = BU and type(BU.Animals) == "table"
    if BY then
        for k, v in pairs(BU.Animals) do
            local BU_1 = v.Rarity or "None"
            BX[k] = BU_1
            local BU_2 = k .. " Egg"
            local BY_1 = v.Rarity or "None"
            BX[BU_2] = BY_1
        end
    end
    if type(BV) == "table" then
        for k, v in pairs(BV) do
            if type(v) == "table" then
                local GradientColor = v.GradientColor
                local BV_1 = typeof(GradientColor) == "ColorSequence" and #GradientColor.Keypoints > 0
                if BV_1 then
                    BW[k] = GradientColor.Keypoints[1].Value
                elseif typeof(v.TextColor) == "Color3" then
                    BW[k] = v.TextColor
                end
            end
        end
    end
    return BX, BW
end
local function fn475()
    local wS_1
    local wR_1
    wR_1, wS_1 = t6("GetPlotCapacity")
    if wR_1 then
        local wR_2 = tonumber(wS_1)
        if wR_2 then
            return wR_2
        elseif type(wS_1) == "table" then
            local wR_3 = tonumber(wS_1.Capacity) or tonumber(wS_1.Slots)
            if wR_3 then
                return wR_3
            end
            return nil
        else
            return nil
        end
    else
        return nil
    end
end
local function fn498(h5)
    uw.teleport = h5 == true
end
local function fn508(eu)
    t9.rarities = eu
end
local function fn522(by)
    local wU = by or ""
    return (tostring(wU):gsub(" Egg$", ""))
end
local function fn524(dI)
    ub.returnHome = dI == true
end
local function fn552(hf)
    uG.trails = hf
end
local function fn579(bI)
    local w1 = uf("AnimalConfigurations")
    local w2 = w1 and type(w1.Animals) == "table" and w1.Animals[ui(bI)]
    local w1_1 = w2
    if w2 then
        w2 = tonumber(w1_1.Income)
    end
    local w1_2 = w2
    local w6 = if w1_2 then 1 else 0
    local w4 = 1347 * w6 + 1373 * (1 - w6)
    local w5 = 3206 * w6 + 255 * (1 - w6)
    if not ((w4 * 1726 + w5 * 2183 + w4 * w5) % 16777213 == 13642102) then
        w1_2 = 0
    end
    return w1_2
end
local function fn587(eq)
    if eq then
        us(t9, t9.Step)
    else
        uo(t9)
    end
end
local function fn602()
    local stats = LocalPlayer:FindFirstChild("stats")
    local wx = stats and stats:FindFirstChild("Money")
    local ww_1 = wx
    if wx then
        wx = tonumber(ww_1.Value)
    end
    local ww_2 = wx
    local wB = if ww_2 then 1 else 0
    local wz = 952 * wB + 2889 * (1 - wB)
    local wA = 2066 * wB + 3539 * (1 - wB)
    if not ((wz * 1760 + wA * 2656 + wz * wA) % 16777213 == 9129648) then
        ww_2 = 0
    end
    return ww_2
end
local function fn603()
    local xF = {}
    for i, v in ipairs(CollectionService:GetTagged("EggLootPrompt")) do
        local xG = u3(v)
        local Model = v:FindFirstAncestorOfClass("Model")
        if xG and Model then
            local insert = table.insert
            local xJ = Model:GetAttribute("EggName") or Model:GetAttribute("OriginalName") or Model.Name
            insert(xF, { Prompt = v, Anchor = xG, Name = xJ, Zone = uv(v), Source = "Wild Eggs" })
        end
    end
    return xF
end
local function fn611(bQ)
    local w7 = 0
    local w8 = {}
    if type(bQ) == "table" then
        for k, v in pairs(bQ) do
            if v == true then
                w8[k] = true
                w7 += 1
            elseif type(v) == "string" then
                w8[v] = true
                w7 += 1
            end
        end
    end
    return w8, w7
end
local function fn613()
    local zp_1, zp_3
    local zo_1, zo_2
    zo_1, zp_1 = t6("GetIndexData")
    local zq = not zo_1 or type(zp_1) ~= "table"
    local zq_1
    if zq then
        return
    end
    zo_2, zq_1 = t6("IndexRewardAction", "GetClaims")
    local zr = not zo_2 or type(zq_1) ~= "table"
    if zr then
        zq_1 = {}
    end
    local zo_3 = uf("AnimalConfigurations")
    local zr_1 = zo_3 and type(zo_3.Animals) == "table" and zo_3.Animals
    local zs = zr_1 or {}
    local zs_1
    local zo_5 = 0
    for k, v in pairs(zp_1) do
        if v == true and zq_1[k] ~= true and zs[k] then
            zp_3, zs_1 = t6("IndexRewardAction", "Claim", k)
            local zt = zp_3 and type(zs_1) == "table" and zs_1.Success
            if zt then
                zo_5 += 1
                task.wait(0.3)
            end
        end
    end
    if zo_5 > 0 then
        local zq_2 = zo_5 == 1 and "" or "s"
        uB(("Claimed %d index reward%s"):format(zo_5, zq_2))
    end
end
local function fn623()
    local x8_1
    local x6_1
    local x5_1
    local x4_1
    local x3_1
    local x7_1
    local x2 = u7()
    x4_1, x3_1 = uZ(ub.zones)
    x6_1, x5_1 = uZ(ub.rarities)
    x7_1, x8_1 = ur()
    if not x8_1 then
        return {}
    end
    local x7_2 = {}
    for i, v in ipairs(x2) do
        local x2_1 = v.Anchor ~= nil and v.Anchor.Parent ~= nil
        local x9 = x2_1
        if x2_1 then
            x2_1 = x3_1 > 0
        end
        if x2_1 then
            x2_1 = v.Zone ~= nil
        end
        if x2_1 then
            x2_1 = not x4_1[v.Zone]
        end
        if x2_1 then
            x9 = false
        end
        local x2_2 = x9 and x5_1 > 0 and not x6_1[t8(v.Name)]
        if x2_2 then
            x9 = false
        end
        if x9 then
            v.Distance = (v.Anchor.Position - x8_1.Position).Magnitude
            table.insert(x7_2, v)
        end
    end
    table.sort(x7_2, function(dg, dh)
        return dg.Distance < dh.Distance
    end)
    return x7_2
end
local function fn692()
    local Ay = {}
    for i, v in ipairs(u2()) do
        table.insert(Ay, v.Name)
    end
    return Ay
end
local function fn721(am)
    local v__1
    local vY = un[am]
    if vY ~= nil then
        if vY == false then
            return nil
        end
        return vY
    end
    local Modules = t7:FindFirstChild("Modules")
    local vZ = Modules and Modules:FindFirstChild(am)
    local vZ_2
    local vZ_1 = not vZ or not vZ:IsA("ModuleScript")
    if vZ_1 then
        un[am] = false
        return nil
    end
    vZ_2, v__1 = pcall(require, vZ)
    local vY_3 = not vZ_2 or type(v__1) ~= "table"
    if vY_3 then
        un[am] = false
        return nil
    end
    un[am] = v__1
    return v__1
end
local function fn777(ay, az)
    local Events = t7:FindFirstChild("Events")
    local v8 = Events and Events:FindFirstChild(ay)
    local v7_1 = v8
    if v8 then
        v8 = v7_1:IsA(az)
    end
    if v8 then
        return v7_1
    end
    return nil
end
local function fn778()
    return va:FindFirstChild("Plot_" .. LocalPlayer.Name)
end
local function fn779()
    return not uP.Unloaded
end
local function fn790(U)
    local vW = typeof(cloneref) == "function" and typeof(U) == "Instance"
    if vW then
        return cloneref(U)
    end
    return U
end
local function fn792(fq)
    if fq then
        us(u0, u0.Step)
    else
        uo(u0)
    end
end
local function fn821()
    local Al = uf("TrailConfigurations")
    local Am = Al
    local An = {}
    if Am then
        Am = type(Al.Trails) == "table"
    end
    if Am then
        for k, v in pairs(Al.Trails) do
            local Al_1 = type(v) == "table" and v.ID
            if Al_1 then
                local insert = table.insert
                local ID = v.ID
                local Ao = v.Name or v.ID
                local Ap = tonumber(v.Price) or 0
                local Aq = tonumber(v.SpeedBoost) or 0
                insert(An, { ID = ID, Name = Ao, Price = Ap, SpeedBoost = Aq })
            end
        end
    end
    table.sort(An, function(gA, gB)
        return gA.Price < gB.Price
    end)
    return An
end
local function fn831()
    local zR = uf("TreadmillConfigurations")
    local zS = zR
    local zT = {}
    if zS then
        zS = type(zR.Treadmills) == "table"
    end
    if zS then
        for k, v in pairs(zR.Treadmills) do
            local insert = table.insert
            local zS_1 = tonumber(v.Price) or 0
            insert(zT, { Name = k, Price = zS_1 })
        end
    end
    table.sort(zT, function(f1, f2)
        return f1.Price < f2.Price
    end)
    return zT
end
local function fn867(jl)
    uD.rarities = jl
end
local function fn868()
    local Folder = uD.Folder
    if Folder and Folder.Parent then
        return Folder
    end
    local folder = Instance.new("Folder")
    folder.Name = "TempoStealAGiantEggEsp"
    folder.Parent = uz()
    uD.Folder = folder
    return folder
end
local function fn923()
    local xw = uT()
    if not xw then
        return false
    end
    return u6(xw.Position, 6)
end
local function fn925(hb)
    if hb then
        us(uG, uG.Step)
    else
        uo(uG)
    end
end
local function fn985()
    local Character = LocalPlayer.Character
    if not Character or not Character.Parent then
        return nil, nil, nil
    end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not HumanoidRootPart or not Humanoid or Humanoid.Health <= 0 then
        return nil, nil, nil
    end
    return Character, HumanoidRootPart, Humanoid
end
local function fn995(iD, iE)
    local iG = uJ()
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "EggEsp"
    billboardGui.AlwaysOnTop = true
    billboardGui.LightInfluence = 0
    billboardGui.Size = UDim2.fromOffset(220, 46)
    billboardGui.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
    billboardGui.MaxDistance = math.huge
    billboardGui.Adornee = iE
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.BackgroundTransparency = 1
    textLabel.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold)
    textLabel.TextScaled = true
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Text = ""
    local uIStroke = Instance.new("UIStroke")
    uIStroke.Thickness = 2
    uIStroke.Color = Color3.new(0, 0, 0)
    uIStroke.Parent = textLabel
    textLabel.Parent = billboardGui
    local highlight = Instance.new("Highlight")
    highlight.Name = "EggHighlight"
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    highlight.Adornee = iD
    highlight.Parent = iG
    billboardGui.Parent = iG
    return { Gui = billboardGui, Label = textLabel, Highlight = highlight, Anchor = iE }
end
local function fn1004()
    local Trails = LocalPlayer:FindFirstChild("Trails")
    local AH = {}
    local AI
    if Trails then
        for i, child in ipairs(Trails:GetChildren()) do
            if child.Name == "Equipped" then
                AI = child
            else
                AH[child.Name] = true
            end
        end
    end
    return AH, AI
end
local function fn1016(X)
    return type(X) == "function"
end
local function fn1017()
    local Bk_1
    local Bj_1
    Bk_1, Bj_1 = uZ(uw.keep)
    if Bj_1 == 0 then
        return nil
    end
    for i, v in ipairs(uQ()) do
        local attr = v:GetAttribute("OriginalName")
        local Bl = t8(attr)
        if Bk_1[Bl] then
            return attr, Bl
        end
    end
    return nil
end
local function fn1048()
    local Ct_1
    local Cr_1
    local Cs_1
    local Co = {}
    local Cp = uD.lookup
    local CG = if Cp then 1 else 0
    local CE = 3658 * CG + 3699 * (1 - CG)
    local CF = 943 * CG + 1254 * (1 - CG)
    if not ((CE * 4010 + CF * 3194 + CE * CF) % 16777213 == 4352803) then
        Cp = Co
    end
    local Co_1 = Cp
    local Cq = uD.colors or {}
    local Cq_1
    Cr_1, Cq_1 = uZ(uD.rarities)
    Cs_1, Ct_1 = ur()
    local Eggs = va:FindFirstChild("Eggs")
    local Cu = {}
    if Eggs and Ct_1 then
        for i, child in ipairs(Eggs:GetChildren()) do
            for i, child in ipairs(child:GetChildren()) do
                local SpawnedEgg = child:FindFirstChild("SpawnedEgg")
                local Cv_1 = SpawnedEgg
                if Cv_1 then
                    local Cw_1 = SpawnedEgg.PrimaryPart or SpawnedEgg:FindFirstChildWhichIsA("BasePart", true)
                    Cv_1 = Cw_1
                end
                local Cw_2 = Cv_1
                if SpawnedEgg and Cw_2 then
                    local Cv_3 = SpawnedEgg:GetAttribute("EggName") or SpawnedEgg.Name
                    local Cv_4 = Co_1[Cv_3] or "None"
                    if Cq_1 == 0 or Cr_1[Cv_4] then
                        Cu[SpawnedEgg] = true
                        local Cv_6 = uD.entries[SpawnedEgg]
                        if not Cv_6 or not Cv_6.Gui.Parent then
                            Cv_6 = uc(SpawnedEgg, Cw_2)
                            uD.entries[SpawnedEgg] = Cv_6
                        end
                        local Cz_1 = Cq[Cv_4] or Color3.new(1, 1, 1)
                        local Magnitude = (Cw_2.Position - Ct_1.Position).Magnitude
                        Cv_6.Label.TextColor3 = Cz_1
                        Cv_6.Highlight.FillColor = Cz_1
                        Cv_6.Highlight.OutlineColor = Cz_1
                        local Label = Cv_6.Label
                        local CA_1 = tostring(Cv_3)
                        local CB = tostring(Cv_4)
                        local CC = SpawnedEgg:GetAttribute("EggSize") or "Normal"
                        Label.Text = ("%s\n%s | %s | %d studs"):format(CA_1, CB, tostring(CC), math.floor(Magnitude))
                    end
                end
            end
        end
    end
    for k, v in pairs(uD.entries) do
        if not Cu[k] then
            v.Gui:Destroy()
            v.Highlight:Destroy()
            uD.entries[k] = nil
        end
    end
end
local function fn1072()
    local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not Backpack then
        return {}
    end
    local yw = {}
    for i, child in ipairs(Backpack:GetChildren()) do
        local yv_1 = child:IsA("Tool") and child:GetAttribute("OriginalName")
        if yv_1 then
            table.insert(yw, child)
        end
    end
    table.sort(yw, function(dT, dU)
        return ux(dT:GetAttribute("OriginalName")) > ux(dU:GetAttribute("OriginalName"))
    end)
    return yw
end
local function fn1086()
    local z1_1, z1_3
    local z0_1, z0_6
    z0_1, z1_1 = t6("GetEquippedTreadmill")
    if not z0_1 then
        return
    end
    local z0_2 = type(z1_1) == "table" and z1_1.Name
    local z2 = z0_2 or z1_1
    local z1_2 = uC()
    local Price = nil
    for i, v in ipairs(z1_2) do
        if v.Name == z2 then
            Price = v.Price
        end
    end
    local z3
    for i, v in ipairs(z1_2) do
        if Price == nil or v.Price > Price then
            z3 = v
            break
        end
    end
    local z0_5 = not z3 or uy() < z3.Price
    if z0_5 then
        return
    end
    z0_6, z1_3 = t6("RequestTreadmillUpgrade")
    local z2_2 = z0_6 and type(z1_3) == "table" and z1_3.Success
    if z2_2 then
        uB("Upgraded to " .. tostring(z3.Name))
    end
end
local function fn1125(cR)
    cR.stopped = true
    local xX = cR.generation or 0
    cR.generation = xX + 1
end
local function fn1152(fR)
    if fR then
        us(uV, uV.Step)
    else
        uo(uV)
    end
end
local function fn1158(fk)
    if fk then
        us(u4, u4.Step)
    else
        uo(u4)
    end
end
local function fn1165(dA)
    if dA then
        us(ub, ub.Step)
    else
        uo(ub)
    end
end
local function fn1209(h1)
    local BL = tonumber(h1) or 1
    uw.minimum = math.max(1, math.floor(BL))
end
local function fn1230(bA)
    local wW = uf("AnimalConfigurations")
    local wX = wW and type(wW.Animals) == "table" and wW.Animals[ui(bA)]
    local wW_1 = wX
    if wX then
        wX = wW_1.Rarity
    end
    local wW_2 = wX
    local w0 = if wW_2 then 1 else 0
    local wZ = 853 * w0 + 3385 * (1 - w0)
    local w_ = 2470 * w0 + 2679 * (1 - w0)
    if not ((wZ * 1989 + w_ * 1768 + wZ * w_) % 16777213 == 8170487) then
        wW_2 = "None"
    end
    return wW_2
end
local function fn1246(ew)
    local yX = tonumber(ew) or 1
    t9.interval = math.max(0.3, yX)
end
local function fn1255()
    return CoreGui
end
local function fn1283(cj)
    local Eggs = va:FindFirstChild("Eggs")
    if not Eggs then
        return nil
    end
    local xC = cj
    while true do
        if not (xC and xC.Parent) then
            return nil
        end
        if xC.Parent == Eggs then
            break
        end
        xC = xC.Parent
    end
    return xC.Name
end
local function fn1292(dG)
    ub.rarities = dG
end
local function fn1295()
    gethui = vd
end
local function fn1308(hT)
    if hT then
        us(uw, uw.Step)
    else
        uo(uw)
    end
end
local function fn1325()
    local Character = LocalPlayer.Character
    local wu = Character ~= nil and Character:GetAttribute("CarryingEgg") == true
    return wu
end
local function fn1338(hX)
    if table.find(uL, hX) then
        uw.mode = hX
    end
end
local function fn1363(dK)
    local yt = tonumber(dK) or 0.4
    ub.interval = math.max(0.1, yt)
end
t6 = nil
t7 = nil
t8 = nil
t9 = nil
ub = nil
uc = nil
LocalPlayer = nil
ue = nil
uf = nil
ug = nil
uh = nil
ui = nil
um = nil
un = nil
uo = nil
uq = nil
ur = nil
us = nil
ut = nil
uv = nil
uw = nil
ux = nil
uy = nil
uz = nil
CoreGui = nil
uB = nil
uC = nil
uD = nil
State = nil
uG = nil
uH = nil
uI = nil
uJ = nil
uL = nil
uN = nil
uO = nil
uP = nil
uQ = nil
uS = nil
local Players, uj, Workspace, ul, Lighting, TeleportService, GuiService, HttpService, uM, uR
uT = nil
uV = nil
uW = nil
uX = nil
uZ = nil
u0 = nil
u2 = nil
u3 = nil
u4 = nil
CollectionService = nil
u6 = nil
u7 = nil
u8 = nil
u9 = nil
va = nil
vb = nil
vc = nil
vd = nil
local uU, UserInputService, u_, RunService, ve
if not game:IsLoaded() then
    game.Loaded:Wait()
end
Players, RunService, UserInputService, uR, HttpService, GuiService, CoreGui, TeleportService, Lighting, Workspace, LocalPlayer, vd = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
if not uR and not LocalPlayer and (LocalPlayer and not ReplicatedStorage) or (not vd or ReplicatedStorage) and (not ReplicatedStorage or uR) or not (not uR and not LocalPlayer and (LocalPlayer and not ReplicatedStorage) or (not vd or ReplicatedStorage) and (not ReplicatedStorage or uR)) then
    RunService = game:GetService("RunService")
else
    uR = game:GetService("RunService")
end
UserInputService = game:GetService("UserInputService")
uR = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
TeleportService = game:GetService("TeleportService")
Lighting = game:GetService("Lighting")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local ua = "TempoStealAGiantEgg"
vd = fn1255
if getgenv then
    getgenv().gethui = vd
end
uP, t7, va, CollectionService, u_, uU, uL, State, un, ub, t9, vc, u4, u0, uV, uN, uG, uD, uw, ul, ut, uh, uB, uf, uj, uH, t6, ur, uW, uy, u9, uT, um, uX, ui, t8, ux, uZ, uq, u6, ug, u3, uv, u7, us, uo, ue, uO, uQ, uS, uC, u2, ve, uI, uM, uz, vb, u8, uJ, uc = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pcall(fn1295)
local function vi(t)
    local vH
    local vJ
    local vI
    vH = nil
    vI = nil
    vJ = nil
    local vK = t ~= ""
    local vL = type(t) == "string" and vK
    assert(vL, "A namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    vH = getgenv()
    assert(type(vH) == "table", "getgenv did not return a table")
    local vK_1 = vH[t]
    if vK_1 ~= nil then
        local vL_1 = type(vK_1) == "table" and type(vK_1.Unload) == "function"
        assert(vL_1, "Namespace is occupied")
        vK_1.Unload()
        assert(vH[t] == nil, "Previous instance did not release its namespace")
    end
    vI = {}
    vJ = { State = {}, Unloaded = false }
    vJ.Track = function(z)
        assert(type(z) == "function", "Cleanup must be callable")
        if vJ.Unloaded then
            z()
        else
            table.insert(vI, z)
        end
        return z
    end
    vJ.Unload = function()
        local vx_1
        local vw_1
        if vJ.Unloaded then
            return
        end
        vJ.Unloaded = true
        local vu = {}
        local vB = #vI
        local vA = -1
        while false and vB <= 1 or true and vB >= 1 do
            local vC = vB
            local vv_1 = table.remove(vI, vC)
            vw_1, vx_1 = pcall(vv_1)
            if not vw_1 then
                table.insert(vu, tostring(vx_1))
            end
            vB += vA
        end
        table.clear(vJ.State)
        if #vu > 0 then
            error("Cleanup incomplete: " .. table.concat(vu, "; "), 0)
        end
        if vH[t] == vJ then
            vH[t] = nil
        end
    end
    vH[t] = vJ
    return vJ
end
ul = function(M, N)
    local vR = type(M) == "table" and type(M.Track) == "function"
    assert(vR, "FeatureAPI required")
    local vR_1 = type(N) == "table" and type(N.OnUnload) == "function"
    assert(vR_1, "UI library required")
    assert(type(N.Unload) == "function", "UI unload required")
    M.Track(function()
        if not N.Unloaded then
            N:Unload()
        end
    end)
    N:OnUnload(function()
        M.Unload()
    end)
end
uP = vi(ua)
ut = fn1016
uh = fn779
t7 = fn790(ReplicatedStorage)
va = fn790(Workspace)
CollectionService = game:GetService("CollectionService")
u_ = { "Zone1", "Zone2", "Zone3", "Zone4", "Zone5", "Zone6", "Zone7", "Zone8", "Zone9" }
uU = {
    "Common",
    "Uncommon",
    "Rare",
    "Epic",
    "Legendary",
    "Mythical",
    "Secret",
    "Divine",
    "Cosmic",
    "Eternal",
    "Hacker"
}
uL = { "Inventory", "Equipped", "Both" }
State = uP.State
State.Status = "Idle"
uB = fn280
un = {}
uf = fn721
uj = fn777
uH = function(aG, ...)
    local wb
    local wa
    wa = nil
    wb = nil
    wb = uj(aG, "RemoteEvent")
    if not wb then
        return false
    end
    wa = table.pack(...)
    return (pcall(function()
        wb:FireServer(table.unpack(wa, 1, wa.n))
    end))
end
t6 = function(aN, ...)
    local wd
    local we
    wd = nil
    we = nil
    local wg_1
    local wf_1
    we = uj(aN, "RemoteFunction")
    if not we then
        return false
    end
    wd = table.pack(...)
    wf_1, wg_1 = pcall(function()
        return we:InvokeServer(table.unpack(wd, 1, wd.n))
    end)
    if not wf_1 then
        return false
    end
    return true, wg_1
end
ur = fn985
uW = fn1325
uy = fn602
u9 = fn778
uT = fn170
um = fn319
uX = fn475
ui = fn522
t8 = fn1230
ux = fn579
uZ = fn611
uq = function(bW)
    local xg = not bW or not bW:IsA("ProximityPrompt")
    if xg then
        return false
    elseif not ut(fireproximityprompt) then
        return false
    else
        if not bW.Enabled then
            pcall(function()
                bW.Enabled = true
            end)
        end
        return (pcall(fireproximityprompt, bW))
    end
end
u6 = function(b0, b1)
    local xp
    xp = nil
    local xq_1
    xq_1, xp = ur()
    if not xp or not b0 then
        return false
    end
    return (pcall(function()
        local xn = b1 or 5
        xp.CFrame = CFrame.new(b0 + Vector3.new(0, xn, 0))
    end))
end
ug = fn923
u3 = fn265
uv = fn1283
u7 = fn603
ub = { interval = 0.4, zones = {}, rarities = {}, returnHome = true }
t9 = { interval = 1, rarities = {} }
vc = { interval = 2 }
u4 = { interval = 15 }
u0 = { interval = 10 }
uV = { interval = 6 }
uN = { interval = 6 }
uG = { interval = 8, trails = {} }
uD = { interval = 0.25, rarities = {}, entries = {}, lookup = nil, colors = nil }
uw = { interval = 30, mode = "Inventory", keep = {}, minimum = 1, teleport = true }
us = function(cJ, cK)
    local generation
    local xV = cJ.generation or 0
    cJ.generation = xV + 1
    cJ.stopped = false
    generation = cJ.generation
    task.spawn(function()
        local xS_1
        while true do
            local xR = uh() and not cJ.stopped and cJ.generation == generation
            local xR_1
            if xR then
                xR_1, xS_1 = pcall(cK)
                if not xR_1 then
                    warn("[Tempo] loop error: " .. tostring(xS_1))
                end
                local xR_2 = not uh() or cJ.stopped or cJ.generation ~= generation
                if xR_2 then
                    break
                end
                task.wait(cJ.interval)
                continue
            end
            break
        end
    end)
end
uo = fn1125
if ((uV or uQ) and (not uU or not uV) or (not uU or uc) and (uV and not uV)) and (uU and not uV or (uU or uQ) or (uQ and uV or uU and uU)) or not (((uV or uQ) and (not uU or not uV) or (not uU or uc) and (uV and not uV)) and (uU and not uV or (uU or uQ) or (uQ and uV or uU and uU))) then
    ue = fn48
    uO = fn623
    ub.Step = fn208
    ub.SetEnabled = fn1165
    ub.SetZones = fn258
    ub.SetRarities = fn1292
    ub.SetReturnHome = fn524
    ub.SetDelay = fn1363
    uQ = fn1072
    t9.Step = function()
        local yE
        local yH_4
        local yI_6, yI_8
        if uW() then
            return
        end
        local yG = uQ()
        yI_6, yH_4 = uZ(t9.rarities)
        if yH_4 > 0 then
            local yH_5 = {}
            for i, v in ipairs(yG) do
                local yU_3 = if yI_6[t8(v:GetAttribute("OriginalName"))] then 1 else 0
                if yU_3 == 1 then
                    table.insert(yH_5, v)
                end
            end
            yG = yH_5
        end
        if #yG == 0 then
            uB("Nothing to place")
            return
        end
        local yH_6 = uT()
        if not yH_6 then
            uB("Plot is not loaded")
            return
        end
        local yI_7 = uX()
        local yJ = yI_7 and #um() >= yI_7
        local yJ_3
        if yJ then
            uB("Plot is full")
            return
        end
        yI_8, yJ_3, yE = ur()
        if not yJ_3 or not yE then
            return
        end
        if (yJ_3.Position - yH_6.Position).Magnitude > 25 then
            if not u6(yH_6.Position, 6) then
                return
            end
            task.wait(0.8)
        end
        local yF = yG[1]
        if yF.Parent ~= LocalPlayer.Character then
            pcall(function()
                yE:EquipTool(yF)
            end)
            task.wait(0.4)
        end
        local yG_2 = #um()
        local yI_10 = yH_6.Size * 0.35
        local yJ_4 = yH_6.Position + Vector3.new((math.random() - 0.5) * 2 * yI_10.X, yH_6.Size.Y / 2, (math.random() - 0.5) * 2 * yI_10.Z)
        uH("PlaceItemAtCursor", yJ_4)
        task.wait(0.8)
        local yU_4 = if #um() > yG_2 then 1 else 0
        if yU_4 == 1 then
            uB("Placed " .. tostring(yF:GetAttribute("OriginalName")))
        else
            uB("Placement was rejected")
        end
    end
    t9.SetEnabled = fn587
    t9.SetRarities = fn508
    t9.SetDelay = fn1246
    uS = fn105
else
    uQ = fn48
    ub = fn623
    uS.Step = fn208
    uS.SetEnabled = fn1165
    uS.SetZones = fn258
    uS.SetRarities = fn1292
    uS.SetReturnHome = fn524
    uS.SetDelay = fn1363
    ue = fn1072
    uO.Step = function()
        local yE
        local yH_1
        local yI_1, yI_3
        if uW() then
            return
        end
        local yG = uQ()
        yI_1, yH_1 = uZ(t9.rarities)
        if yH_1 > 0 then
            local yH_2 = {}
            for i, v in ipairs(yG) do
                local yU_1 = if yI_1[t8(v:GetAttribute("OriginalName"))] then 1 else 0
                if yU_1 == 1 then
                    table.insert(yH_2, v)
                end
            end
            yG = yH_2
        end
        if #yG == 0 then
            uB("Nothing to place")
            return
        end
        local yH_3 = uT()
        if not yH_3 then
            uB("Plot is not loaded")
            return
        end
        local yI_2 = uX()
        local yJ = yI_2 and #um() >= yI_2
        local yJ_1
        if yJ then
            uB("Plot is full")
            return
        end
        yI_3, yJ_1, yE = ur()
        if not yJ_1 or not yE then
            return
        end
        if (yJ_1.Position - yH_3.Position).Magnitude > 25 then
            if not u6(yH_3.Position, 6) then
                return
            end
            task.wait(0.8)
        end
        local yF = yG[1]
        if yF.Parent ~= LocalPlayer.Character then
            pcall(function()
                yE:EquipTool(yF)
            end)
            task.wait(0.4)
        end
        local yG_1 = #um()
        local yI_5 = yH_3.Size * 0.35
        local yJ_2 = yH_3.Position + Vector3.new((math.random() - 0.5) * 2 * yI_5.X, yH_3.Size.Y / 2, (math.random() - 0.5) * 2 * yI_5.Z)
        uH("PlaceItemAtCursor", yJ_2)
        task.wait(0.8)
        local yU_2 = if #um() > yG_1 then 1 else 0
        if yU_2 == 1 then
            uB("Placed " .. tostring(yF:GetAttribute("OriginalName")))
        else
            uB("Placement was rejected")
        end
    end
    uO.SetEnabled = fn587
    uO.SetRarities = fn508
    uO.SetDelay = fn1246
    t9 = fn105
end
vc.Step = fn236
vc.SetEnabled = fn80
u4.Step = fn613
u4.SetEnabled = fn1158
u0.Step = fn172
u0.SetEnabled = fn792
uV.Step = fn52
uV.SetEnabled = fn1152
uC = fn831
uN.Step = fn1086
uN.SetEnabled = fn190
u2 = fn821
ve = fn692
uI = fn1004
uG.Step = fn407
uG.SetEnabled = fn925
uG.SetTrails = fn552
uM = fn1017
uw.Step = function()
    local Bu
    if uW() then
        return
    end
    local mode = uw.mode
    local Bv_2, Bv_4, Bv_8
    local Bw = mode == "Both"
    local Bx = mode == "Inventory"
    local BD = if Bx then 1 else 0
    local BB = 3146 * BD + 2496 * (1 - BD)
    local BC = 1558 * BD + 1600 * (1 - BD)
    if not ((BB * 1682 + BC * 3270 + BB * BC) % 16777213 == 15287700) then
        Bx = Bw
    end
    local Bw_1 = Bx
    local By = mode == "Equipped" or mode == "Both"
    local By_1, By_3
    local Bv_1 = Bw_1
    if Bv_1 then
        Bv_1 = #uQ() < math.max(1, uw.minimum)
    end
    if Bv_1 then
        Bw_1 = false
    end
    if Bw_1 then
        Bv_2, By_1 = uM()
        if Bv_2 then
            uB(("Keeping %s (%s), inventory sell skipped"):format(tostring(Bv_2), tostring(By_1)))
            Bw_1 = false
        end
    end
    local Bv_3 = not By
    local By_2 = not Bw_1
    if By_2 ~= false then
        By_2 = Bv_3
    end
    if By_2 then
        return
    end
    local CFrame
    Bv_4, By_3 = ur()
    if uw.teleport and By_3 then
        local SellNPC = va:FindFirstChild("SellNPC")
        local Bz = SellNPC and SellNPC:FindFirstChild("ProxPart")
        local Bv_7 = Bz
        if Bz then
            Bz = Bv_7:IsA("BasePart")
        end
        if Bz then
            CFrame = By_3.CFrame
            if u6(Bv_7.Position, 4) then
                task.wait(0.6)
            else
                CFrame = nil
            end
        end
    end
    if Bw_1 then
        uH("RequestSell", "Inventory")
        task.wait(0.5)
    end
    if By then
        uH("RequestSell", "Equipped")
        task.wait(0.5)
    end
    uB("Sold pets")
    if CFrame then
        Bv_8, Bu = ur()
        local Bv_9 = Bu and not uW()
        if Bv_9 then
            pcall(function()
                Bu.CFrame = CFrame
            end)
        end
    end
end
uw.SetEnabled = fn1308
uw.SetMode = fn1338
uw.SetKeep = fn303
uw.SetMinimum = fn1209
uw.SetInterval = fn53
uw.SetTeleport = fn498
uz = fn333
vb = fn426
u8 = fn388
uJ = fn868
uc = fn995
uD.Step = fn1048
uD.SetEnabled = fn85
uD.SetRarities = fn867
uP.Track(u8)
uP.Track(fn242)
local function vj()
    local onDiscord
    local Hv
    local Hu
    onDiscord = nil
    Hu = nil
    Hv = nil
    local Hl, Hm, Library, Toggles, Hq, ThemeManager, Hs, Options, SaveManager
    Hl = "Steal a Giant Egg"
    Hu = "https://discord.gg/K7Qxnxkk46"
    Hq = "https://tempohub.shop"
    Hm = "https://discord.gg/K7Qxnxkk46"
    Library = getgenv().Library
    ThemeManager = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = Library.Toggles
    Options = Library.Options
    ul(uP, Library)
    Hv = function(jL, jM)
        local CY = ut(setclipboard) and setclipboard
        local CZ = CY
        local C3 = if CZ then 1 else 0
        local C1 = 1557 * C3 + 2822 * (1 - C3)
        local C2 = 1215 * C3 + 858 * (1 - C3)
        if not ((C1 * 3560 + C2 * 953 + C1 * C2) % 16777213 == 8592570) then
            local CY_1 = ut(toclipboard) and toclipboard
            CZ = CY_1 or nil
        end
        local CY_2 = CZ
        if not CY_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local CZ_1 = pcall(CY_2, jL)
        if CZ_1 then
            Library:Notify(jM)
        else
            Library:Notify("Failed to copy")
        end
    end
    onDiscord = function()
        Hv(Hu, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = Hu, Copyable = true }, "|", Hl, "|", "v0.2" },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(false)
    Hs = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gamepad-2"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
    local function Hx_1(jZ)
        local DiscordGroup = jZ:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    for k, v in Hs do
        if k ~= "Info" then
            Hx_1(v)
        end
    end
    local function Hy()
        local lx
        local StealingGroup = Hs.Main:AddLeftGroupbox("Stealing", "hand-coins")
        StealingGroup:AddToggle("AutoSteal", {
            Text = "Auto Steal",
            Default = false,
            Callback = function(j6)
                ub.SetEnabled(j6)
            end
        })
        StealingGroup:AddDropdown("StealZones", {
            Text = "Zones",
            Values = u_,
            Default = {},
            Multi = true,
            AllowNull = true,
            Callback = function(kc)
                ub.SetZones(kc)
            end
        })
        StealingGroup:AddDropdown("StealRarities", {
            Text = "Rarities",
            Values = uU,
            Default = {},
            Multi = true,
            AllowNull = true,
            Callback = function(kg)
                ub.SetRarities(kg)
            end
        })
        StealingGroup:AddSlider("StealDelay", {
            Text = "Steal Delay",
            Default = 0.4,
            Min = 0.1,
            Max = 5,
            Rounding = 1,
            Suffix = "s",
            Callback = function(ki)
                ub.SetDelay(ki)
            end
        })
        StealingGroup:AddToggle("ReturnHome", {
            Text = "Teleport Home To Bank Egg",
            Default = true,
            Callback = function(kk)
                ub.SetReturnHome(kk)
            end
        })
        local EggsGroup = Hs.Main:AddLeftGroupbox("Eggs", "egg")
        EggsGroup:AddToggle("AutoPlaceEggs", {
            Text = "Auto Place Eggs",
            Default = false,
            Callback = function(kn)
                t9.SetEnabled(kn)
            end
        })
        EggsGroup:AddDropdown("PlaceRarities", {
            Text = "Place Rarities",
            Values = uU,
            Default = {},
            Multi = true,
            AllowNull = true,
            Callback = function(kr)
                t9.SetRarities(kr)
            end
        })
        EggsGroup:AddSlider("PlaceDelay", {
            Text = "Place Delay",
            Default = 1,
            Min = 0.3,
            Max = 5,
            Rounding = 1,
            Suffix = "s",
            Callback = function(kt)
                t9.SetDelay(kt)
            end
        })
        EggsGroup:AddToggle("AutoHatchEggs", {
            Text = "Auto Hatch Eggs",
            Default = false,
            Callback = function(kw)
                vc.SetEnabled(kw)
            end
        })
        local VisualsGroup = Hs.Main:AddLeftGroupbox("Visuals", "eye")
        VisualsGroup:AddToggle("EggEsp", {
            Text = "Egg ESP",
            Default = false,
            Callback = function(kB)
                uD.SetEnabled(kB)
            end
        })
        VisualsGroup:AddDropdown("EspRarities", {
            Text = "ESP Rarities",
            Values = uU,
            Default = {},
            Multi = true,
            AllowNull = true,
            Callback = function(kF)
                uD.SetRarities(kF)
            end
        })
        local ProgressionGroup = Hs.Main:AddRightGroupbox("Progression", "trending-up")
        ProgressionGroup:AddToggle("AutoClaimIndex", {
            Text = "Auto Claim Index",
            Default = false,
            Callback = function(kI)
                u4.SetEnabled(kI)
            end
        })
        ProgressionGroup:AddToggle("AutoEquipBest", {
            Text = "Auto Equip Best",
            Default = false,
            Callback = function(kM)
                u0.SetEnabled(kM)
            end
        })
        ProgressionGroup:AddToggle("AutoBuySlots", {
            Text = "Auto Buy Pet Slots",
            Default = false,
            Callback = function(kQ)
                uV.SetEnabled(kQ)
            end
        })
        ProgressionGroup:AddToggle("AutoTreadmill", {
            Text = "Auto Upgrade Treadmill",
            Default = false,
            Callback = function(kU)
                uN.SetEnabled(kU)
            end
        })
        ProgressionGroup:AddToggle("AutoBuyTrails", {
            Text = "Auto Buy Trails",
            Default = false,
            Callback = function(kY)
                uG.SetEnabled(kY)
            end
        })
        ProgressionGroup:AddDropdown("TrailTargets", {
            Text = "Trails",
            Values = ve(),
            Default = {},
            Multi = true,
            AllowNull = true,
            Callback = function(k3)
                uG.SetTrails(k3)
            end
        })
        local SellingGroup = Hs.Main:AddRightGroupbox("Selling", "banknote")
        SellingGroup:AddToggle("AutoSell", {
            Text = "Auto Sell",
            Default = false,
            Callback = function(k6)
                uw.SetEnabled(k6)
            end
        })
        SellingGroup:AddDropdown("SellMode", {
            Text = "Sell Mode",
            Values = uL,
            Default = 1,
            Multi = false,
            Callback = function(lc)
                uw.SetMode(lc)
            end
        })
        SellingGroup:AddDropdown("SellKeepRarities", {
            Text = "Never Sell Rarities",
            Values = uU,
            Default = {},
            Multi = true,
            AllowNull = true,
            Callback = function(le)
                uw.SetKeep(le)
            end
        })
        SellingGroup:AddSlider("SellMinimum", {
            Text = "Minimum Inventory Eggs",
            Default = 1,
            Min = 1,
            Max = 50,
            Rounding = 0,
            Callback = function(lg)
                uw.SetMinimum(lg)
            end
        })
        SellingGroup:AddSlider("SellInterval", {
            Text = "Sell Interval",
            Default = 30,
            Min = 5,
            Max = 300,
            Rounding = 0,
            Suffix = "s",
            Callback = function(li)
                uw.SetInterval(li)
            end
        })
        SellingGroup:AddToggle("SellTeleport", {
            Text = "Teleport To Seller",
            Default = true,
            Callback = function(lk)
                uw.SetTeleport(lk)
            end
        })
        local StatusGroup = Hs.Main:AddRightGroupbox("Status", "activity")
        local Label = StatusGroup:AddLabel("Idle", true)
        lx = task.spawn(function()
            while uh() do
                pcall(function()
                    Label:SetText(tostring(State.Status))
                end)
                task.wait(0.5)
            end
        end)
        uP.Track(function()
            pcall(task.cancel, lx)
        end)
    end
    Hy()
    local function Hx_2()
        local Dr
        local Dn
        local Dv
        local Dk
        Dk = nil
        Dn = nil
        Dr = nil
        Dv = nil
        local Dl, Dm, Do, Dp, Label3, Label2, Dt, Du, Label
        Dn = function(lC)
            return (tostring(lC):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
        end
        Dv = function(lE, lF)
            return string.format('<font color="%s">%s</font>', lF, Dn(lE))
        end
        Do = function(lI, lJ, lK)
            return string.format("<b>%s</b> %s %s", lI, Dv("-", "#5a6070"), Dv(lJ, lK))
        end
        local Dx = "#6ec1ff"
        Dm = "#7fd47f"
        Dt = "#e8a34d"
        local Dy = {}
        local Dz = "#8b93a3"
        if not ut(fireproximityprompt) then
            table.insert(Dy, "stealing")
        end
        local DF = if not uj("PlaceItemAtCursor", "RemoteEvent") then 1 else 0
        if DF == 1 then
            table.insert(Dy, "egg placement")
        end
        if not uj("RequestHatch", "RemoteEvent") then
            table.insert(Dy, "hatching")
        end
        if not uj("IndexRewardAction", "RemoteFunction") then
            table.insert(Dy, "index rewards")
        end
        local DF_1 = if not uT() then 1 else 0
        if DF_1 == 1 then
            table.insert(Dy, "plot lookup")
        end
        local DA = #Dy == 0 and "ready"
        local DB = DA or "limited: " .. table.concat(Dy, ", ")
        Dp = "Unknown"
        pcall(function()
            local C6_1
            local C5_1
            local Dc = if ut(identifyexecutor) then 1 else 0
            if Dc == 1 then
                C6_1, C5_1 = identifyexecutor()
                local C7 = C6_1 ~= ""
                local C8 = type(C6_1) == "string" and C7
                if C8 then
                    local C7_1 = type(C5_1) == "string" and C5_1 ~= "" and C6_1 .. " " .. C5_1
                    Dp = C7_1 or C6_1
                end
            end
        end)
        Dr = os.clock()
        Dl = function()
            local Dd = math.floor(os.clock() - Dr)
            if Dd < 60 then
                return Dd .. "s"
            elseif Dd < 3600 then
                return string.format("%dm %ds", math.floor((Dd) / (60)), Dd % 60)
            else
                return string.format("%dh %dm", math.floor((Dd) / (3600)), math.floor((Dd % 3600) / (60)))
            end
        end
        local UserGroup = Hs.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(Do("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, Dm), true)
        UserGroup:AddLabel(Do("UserId", tostring(LocalPlayer.UserId), Dx), true)
        UserGroup:AddLabel(Do("Executor", Dp .. "  " .. DB, Dm), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(Do("Session", Dl(), Dt), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                Hv(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                Hv("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = Hs.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(Do("Game", Hl, Dx), true)
        Label2 = SessionGroup:AddLabel(Do("Players", "0/0", Dm), true)
        Du = tostring(game.JobId)
        local Dx_1 = #Du > 18 and string.sub(Du, 1, 18) .. "..."
        local DA_2 = Dx_1 or Du
        SessionGroup:AddLabel(Do("Job", DA_2, Dz), true)
        Label = SessionGroup:AddLabel(Do("Ping", "0 ms", Dt), true)
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
                Hv(Du, "Copied Job ID")
            end
        })
        Dk = task.spawn(function()
            local Dg_1
            local Df_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(Do("Session", Dl(), Dt))
                Label2:SetText(Do("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), Dm))
                Df_1, Dg_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local Df_2 = Df_1 and Dg_1 .. " ms" or "n/a"
                Label:SetText(Do("Ping", Df_2, Dt))
            end
        end)
        uP.Track(function()
            if coroutine.status(Dk) ~= "dead" then
                task.cancel(Dk)
            end
        end)
        local SocialsGroup = Hs.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                Hv(Hm, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                Hv(Hq, "Copied website link")
            end
        })
    end
    Hx_2()
    local function Hx_3()
        local m0
        local mZ
        local m1
        local m_
        local MovementGroup = Hs.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = Hs.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        local mY = {}
        mZ = {}
        m1 = {}
        m0 = {}
        m_ = {}
        local function m2()
            for k, v in mZ do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(mZ)
        end
        local function m6()
            for k, v in m_ do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(m_)
        end
        local function na()
            for k, v in m0 do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(m0)
        end
        local function ne(nf)
            if not nf:IsA("ProximityPrompt") then
                return
            end
            if m1[nf] == nil then
                m1[nf] = {
                    HoldDuration = nf.HoldDuration,
                    MaxActivationDistance = nf.MaxActivationDistance,
                    RequiresLineOfSight = nf.RequiresLineOfSight
                }
            end
            nf.HoldDuration = 0
            nf.MaxActivationDistance = 50
            nf.RequiresLineOfSight = false
        end
        local function nh()
            for k, v in m1 do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(m1)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                na()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                m6()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                m2()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                    pcall(ne, v)
                end
            else
                nh()
            end
        end)
        table.insert(mY, Workspace.DescendantAdded:Connect(function(nA)
            if Toggles.InstantProximityPrompt.Value then
                ne(nA)
            end
        end))
        table.insert(mY, RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if mZ[v] == nil then
                        mZ[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(mY, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local Et = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and Et then
                Et:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(mY, RunService.RenderStepped:Connect(function(nW)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local Ez = Character and Character:FindFirstChildOfClass("Humanoid")
            local EA = Character
            if EA then
                EA = Character:FindFirstChild("HumanoidRootPart")
            end
            local Ey_1 = EA
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and Ez then
                if m_[Ez] == nil then
                    m_[Ez] = Ez.WalkSpeed
                end
                Ez.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and Ey_1 and Ez and CurrentCamera then
                if m0[Ez] == nil then
                    m0[Ez] = Ez.PlatformStand
                end
                Ez.PlatformStand = true
                local EA_4 = Vector3.zero
                local EM = if not UserInputService:GetFocusedTextBox() then 1 else 0
                if EM == 1 then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        EA_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        EA_4 -= CurrentCamera.CFrame.LookVector
                    end
                    local EJ = if UserInputService:IsKeyDown(Enum.KeyCode.A) then 1 else 0
                    if EJ == 1 then
                        EA_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        EA_4 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        EA_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        EA_4 -= Vector3.new(0, 1, 0)
                    end
                end
                Ey_1.AssemblyLinearVelocity = Vector3.zero
                if EA_4.Magnitude > 0 then
                    Ey_1.CFrame = Ey_1.CFrame + EA_4.Unit * Options.FlySpeed.Value * nW
                end
            end
        end))
        uP.Track(function()
            for k, v in mY do
                v:Disconnect()
            end
            m2()
            m6()
            na()
            nh()
        end)
    end
    Hx_3()
    local function Hx_4()
        local F1, F2, F3, F4, F5, Label, F7, F8, F9, Ga, Gb, Gc, Gd, Ge
        F7 = {}
        F1 = {}
        Gc = nil
        F3 = false
        Gd = 0
        F9 = 0
        F4 = os.clock()
        local MenuGroup = Hs.Settings:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        Ga = function()
            local CurrentCamera
            CurrentCamera = Workspace.CurrentCamera
            local EV = not CurrentCamera or not ut(uR.CaptureController)
            local EZ = if EV then 1 else 0
            local EX = 3057 * EZ + 3719 * (1 - EZ)
            local EY = 1548 * EZ + 2455 * (1 - EZ)
            if not ((EX * 2926 + EY * 1532 + EX * EY) % 16777213 == 16048554) then
                EV = not ut(uR.ClickButton2)
            end
            if EV then
                return false
            end
            local EV_1 = pcall(function()
                uR:CaptureController()
                uR:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            end)
            if not EV_1 then
                return false
            end
            Gd += 1
            F4 = os.clock()
            pcall(function()
                Label:SetText("AFK triggers: " .. Gd)
            end)
            return true
        end
        F5 = function(oI)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not oI)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not oI
                end
            end)
            if not oI then
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
        F2 = function(oY)
            local E6 = oY.ClassName == "ParticleEmitter" or oY.ClassName == "Trail" or oY.ClassName == "Smoke" or oY.ClassName == "Fire"
            local Fa = if E6 then 1 else 0
            local E8 = 1726 * Fa + 3899 * (1 - Fa)
            local E9 = 2282 * Fa + 1790 * (1 - Fa)
            if not ((E8 * 1550 + E9 * 616 + E8 * E9) % 16777213 == 8019744) then
                E6 = oY.ClassName == "Sparkles"
            end
            if not E6 then
                E6 = oY.ClassName == "Explosion"
            end
            if not E6 then
                E6 = oY.ClassName == "Beam"
            end
            if E6 then
                if F7[oY] == nil then
                    F7[oY] = oY.Enabled
                end
                pcall(function()
                    oY.Enabled = false
                end)
            end
        end
        Ge = function()
            for k, v in F7 do
                local Ff = k
                local Fh = v
                if Ff.Parent then
                    pcall(function()
                        Ff.Enabled = Fh
                    end)
                end
            end
            table.clear(F7)
            if Gc then
                pcall(function()
                    settings().Rendering.QualityLevel = Gc.Quality
                end)
                Lighting.GlobalShadows = Gc.Shadows
                Lighting.FogEnd = Gc.Fog
                Gc = nil
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(pc)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not pc)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(ph)
                if ph then
                    if not Gc then
                        Gc = {
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
                    for k, v in Workspace:QueryDescendants("ParticleEmitter,Trail,Smoke,Fire,Sparkles,Beam") do
                        pcall(F2, v)
                    end
                else
                    Ge()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        F5(true)
        local ScriptGroup = Hs.Settings:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiGameplayPause:OnChanged(function()
            F5(Toggles.AntiGameplayPause.Value)
        end)
        if Toggles.AntiGameplayPause.Value then
            F5(true)
        end
        table.insert(F1, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                Ga()
            end
        end))
        table.insert(F1, Workspace.DescendantAdded:Connect(function(pA)
            if Toggles.FpsBoost.Value then
                F2(pA)
            end
        end))
        Gb = function(pE)
            if F3 or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            F3 = true
            local Fx = F9
            local Fy_1 = pcall(function()
                if pE then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not Fy_1 then
                F3 = false
                if not pE and Fx == F9 then
                    task.delay(1.5, function()
                        if Fx == F9 then
                            Gb(true)
                        end
                    end)
                end
            end
        end
        table.insert(F1, TeleportService.TeleportInitFailed:Connect(function(pW)
            local FI
            if pW == LocalPlayer and F3 then
                F3 = false
                FI = F9
                task.delay(3, function()
                    if FI == F9 then
                        Gb(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local FN = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            local FN_1 = not FN
            local FO = Library.Unloaded
            local FS = if FO then 1 else 0
            local FQ = 1439 * FS + 1125 * (1 - FS)
            local FR = 1095 * FS + 1341 * (1 - FS)
            if not ((FQ * 2264 + FR * 701 + FQ * FR) % 16777213 == 5601196) then
                FO = FN_1
            end
            if FO then
                return
            end
            table.insert(F1, FN.ChildAdded:Connect(function(qa)
                if qa.Name == "ErrorPrompt" then
                    Gb(false)
                end
            end))
        end)
        F8 = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    F5(true)
                end
                local FT = Toggles.AntiAfk.Value and os.clock() - F4 >= 60
                if FT then
                    Ga()
                end
                task.wait(1)
            end
        end)
        uP.Track(function()
            F9 += 1
            for k, v in F1 do
                v:Disconnect()
            end
            pcall(task.cancel, F8)
            F5(false)
            Ge()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    Hx_4()
    local function Hx_5()
        local G9, Ha, Hb, Hc
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("TempoHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(Hs.Settings)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/StealAGiantEgg")
        local Hd = SaveManager:BuildConfigSection(Hs.Settings)
        Hc = function(qB, qC)
            local Gi_1 = (qB == "Toggle" and Toggles or Options)[qC]
            local Gh_2 = type(Gi_1) == "table" and Gi_1.Type == qB
            return Gh_2 and Gi_1 or nil
        end
        Ha = function(qL, qM)
            local Type = qM.Type
            if Type == "Toggle" then
                return { idx = qL, type = "Toggle", value = qM.Value == true }
            elseif Type == "Slider" then
                return { idx = qL, type = "Slider", value = tostring(qM.Value) }
            elseif Type == "Dropdown" then
                return { idx = qL, type = "Dropdown", multi = qM.Multi == true, value = qM.Value }
            elseif Type == "Input" then
                local Gp = qM.Value
                local Gt = if Gp then 1 else 0
                local Gr = 2197 * Gt + 2047 * (1 - Gt)
                local Gs = 2181 * Gt + 37 * (1 - Gt)
                if not ((Gr * 1525 + Gs * 1520 + Gr * Gs) % 16777213 == 11457202) then
                    Gp = ""
                end
                return { idx = qL, type = "Input", text = tostring(Gp) }
            elseif Type == "ColorPicker" then
                return { idx = qL, type = "ColorPicker", value = qM.Value:ToHex(), transparency = qM.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = qL,
                    type = "KeyPicker",
                    mode = qM.Mode,
                    key = qM.Value,
                    modifiers = qM.Modifiers,
                    toggled = qM.Toggled
                }
            else
                return nil
            end
        end
        G9 = function()
            local Gv = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local Gw = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if Gw then
                        local Gw_1 = Ha(k, v)
                        if Gw_1 then
                            Gv[#Gv + 1] = Gw_1
                        end
                    end
                end
            end
            table.sort(Gv, function(qW, qX)
                if qW.type ~= qX.type then
                    return qW.type < qX.type
                end
                return qW.idx < qX.idx
            end)
            return { objects = Gv }
        end
        Hb = function(qZ)
            local GP
            GP = nil
            local GQ = type(qZ) ~= "table" or type(qZ.idx) ~= "string" or type(qZ.type) ~= "string" or SaveManager.Ignore[qZ.idx]
            if GQ then
                return false
            end
            GP = Hc(qZ.type, qZ.idx)
            if not GP then
                return false
            end
            local GQ_1 = pcall(function()
                if qZ.type == "Input" then
                    if type(qZ.text) ~= "string" then
                        return
                    end
                    GP:SetValue(qZ.text)
                elseif qZ.type == "ColorPicker" then
                    GP:SetValueRGB(Color3.fromHex(qZ.value), qZ.transparency)
                elseif qZ.type == "KeyPicker" then
                    GP:SetValue({ qZ.key, qZ.mode, qZ.modifiers })
                    if qZ.mode == "Toggle" and qZ.toggled ~= nil then
                        GP.Toggled = qZ.toggled
                        GP:Update()
                    end
                else
                    GP:SetValue(qZ.value)
                end
            end)
            return GQ_1
        end
        Hd:AddDivider()
        Hd:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        Hd:AddButton("Export Config to Clipboard", function()
            local GT_1
            local GS_1
            GS_1, GT_1 = pcall(HttpService.JSONEncode, HttpService, G9())
            if GS_1 then
                local GS_2 = ut(setclipboard) and setclipboard
                local GU = GS_2
                if not GU then
                    local GS_3 = ut(toclipboard) and toclipboard
                    GU = GS_3 or nil
                end
                local GS_4 = GU
                local GU_1 = type(GS_4) == "function" and pcall(GS_4, GT_1)
                if GU_1 then
                    Library:Notify("Config copied to clipboard", 6)
                    return
                end
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Failed to encode the config")
        end)
        Hd:AddButton("Import Config from Clipboard Text", function()
            local GZ_1
            local GX = Options.SaveManager_ImportSource.Value or ""
            local GX_1
            local GY = tostring(GX):match("^%s*(.-)%s*$")
            if GY == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            if #GY > 262144 then
                Library:Notify("That config is too large")
                return
            end
            GX_1, GZ_1 = pcall(HttpService.JSONDecode, HttpService, GY)
            local GY_1 = not GX_1 or type(GZ_1) ~= "table" or type(GZ_1.objects) ~= "table"
            if GY_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            if #GZ_1.objects > 2048 then
                Library:Notify("That config has too many records")
                return
            end
            local GX_2 = 0
            for i, v in ipairs(GZ_1.objects) do
                if Hb(v) then
                    GX_2 += 1
                end
            end
            if GX_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local GZ_2 = GX_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(GX_2, GZ_2), 6)
        end)
        ThemeManager:LoadDefault()
        SaveManager:LoadAutoloadConfig()
        if Options.StealZones then
            ub.SetZones(Options.StealZones.Value)
        end
        if Options.StealRarities then
            ub.SetRarities(Options.StealRarities.Value)
        end
        if Options.StealDelay then
            ub.SetDelay(Options.StealDelay.Value)
        end
        if Toggles.ReturnHome then
            ub.SetReturnHome(Toggles.ReturnHome.Value)
        end
        if Options.PlaceRarities then
            t9.SetRarities(Options.PlaceRarities.Value)
        end
        if Options.PlaceDelay then
            t9.SetDelay(Options.PlaceDelay.Value)
        end
        if Options.TrailTargets then
            uG.SetTrails(Options.TrailTargets.Value)
        end
        if Options.SellMode then
            uw.SetMode(Options.SellMode.Value)
        end
        if Options.SellKeepRarities then
            uw.SetKeep(Options.SellKeepRarities.Value)
        end
        if Options.SellMinimum then
            uw.SetMinimum(Options.SellMinimum.Value)
        end
        if Options.SellInterval then
            uw.SetInterval(Options.SellInterval.Value)
        end
        if Toggles.SellTeleport then
            uw.SetTeleport(Toggles.SellTeleport.Value)
        end
        if Options.EspRarities then
            uD.SetRarities(Options.EspRarities.Value)
        end
        if Toggles.EggEsp then
            uD.SetEnabled(Toggles.EggEsp.Value)
        end
        if Toggles.AutoSteal then
            ub.SetEnabled(Toggles.AutoSteal.Value)
        end
        if Toggles.AutoPlaceEggs then
            t9.SetEnabled(Toggles.AutoPlaceEggs.Value)
        end
        if Toggles.AutoHatchEggs then
            vc.SetEnabled(Toggles.AutoHatchEggs.Value)
        end
        if Toggles.AutoClaimIndex then
            u4.SetEnabled(Toggles.AutoClaimIndex.Value)
        end
        if Toggles.AutoEquipBest then
            u0.SetEnabled(Toggles.AutoEquipBest.Value)
        end
        if Toggles.AutoBuySlots then
            uV.SetEnabled(Toggles.AutoBuySlots.Value)
        end
        if Toggles.AutoTreadmill then
            uN.SetEnabled(Toggles.AutoTreadmill.Value)
        end
        if Toggles.AutoBuyTrails then
            uG.SetEnabled(Toggles.AutoBuyTrails.Value)
        end
        if Toggles.AutoSell then
            uw.SetEnabled(Toggles.AutoSell.Value)
        end
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    Hx_5()
end
vj()
end)(...)

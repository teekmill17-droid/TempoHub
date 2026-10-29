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
getgenv().TempoHoodSubtitle = "STEAL A LUCKY EGG"
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
local x7_3_1, x7_3_5
local oo
local oP
local pd
local oV
local oC
local pj
local o0
local nX
local om
local o6
local n2
local ov
local pc
local n8
local oU
local Options
local pi
local o_
local oH
local ol
local n1
local Toggles
local n7
local oA
local ph
local od
local nV
local oG
local ClaimIndexRewards
local Library
local n0
local oM
local ot
local pa
local n6
local pg
local nU
local Rebirth
local o3
local n_
local oL
local oq
local o9
local n5
local oR
local pf
local ob
local Bases
local nT
local oE
local oK
local op
local o8
local n4
local oQ
local ox
local oa
local oW
local oD
local o1
local nY
local oJ
local function fn39()
    if tonumber(n0:GetAttribute("Holding")) == 1 then
        return true
    end
    local Holding = n7:FindFirstChild("Holding")
    local qU = Holding and Holding:FindFirstChild(n0.Name)
    local qU_1 = qU ~= nil and #qU:GetChildren() > 0
    return qU_1
end
local function fn58(aR)
    if Library.Unloaded then
        return false
    end
    local qg = Toggles[aR]
    return qg ~= nil and qg.Value == true
end
local function fn72()
    for i, child in Bases:GetChildren() do
        local rp = if child:GetAttribute("OwnerId") == n0.UserId then 1 else 0
        if rp == 1 then
            return child
        end
    end
end
local function fn119()
    local uT_1
    local uS_1
    if n6 then
        return
    end
    n6 = true
    uS_1, uT_1 = pcall(function()
        local uH = ov("SellMode", "Sell All")
        if uH == "Sell All" then
            oQ:FireServer(1)
            task.wait(0.4)
            return
        end
        local uH_1 = o0()
        local uI = uH_1 and uH_1:FindFirstChild("Slots")
        if not uI then
            return
        end
        for i, child in uI:GetChildren() do
            local uH_3 = Library.Unloaded or not pd("AutoSell")
            if uH_3 then
                break
            elseif pg(child) then
                local SpawnPart = child:FindFirstChild("SpawnPart")
                local uI_1 = SpawnPart and SpawnPart:FindFirstChild("SellPrompt")
                local uJ = SpawnPart
                if uJ then
                    uJ = uI_1
                end
                if uJ then
                    uJ = uI_1.Enabled
                end
                if uJ then
                    n2(SpawnPart.CFrame + Vector3.new(0, 3, 0))
                    task.wait(0.12)
                    oJ(uI_1)
                    task.wait(0.35)
                end
            end
        end
    end)
    n6 = false
    if not uS_1 then
        warn("[Tempo] Auto Sell:", uT_1)
    end
end
local function fn184()
    local Character = n0.Character
    local qy = Character and Character:FindFirstChildOfClass("Humanoid")
    return qy
end
local function fn200(aC, aD)
    if setclipboard then
        setclipboard(aC)
    elseif toclipboard then
        toclipboard(aC)
    end
    Library:Notify(aD)
end
local function fn201(aa, ab)
    return aa.order < ab.order
end
local function fn217()
    return oC
end
local function fn251(bO)
    local qY = n5()
    if not qY then
        return false
    end
    local qZ = o8()
    qY.AssemblyLinearVelocity = Vector3.zero
    qY.AssemblyAngularVelocity = Vector3.zero
    if qZ then
        qZ:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    qY.Anchored = true
    qY.CFrame = bO
    task.wait()
    qY.AssemblyLinearVelocity = Vector3.zero
    qY.AssemblyAngularVelocity = Vector3.zero
    qY.Anchored = false
    return true
end
local function fn272()
    local qK_1
    local qJ_1
    qJ_1, qK_1 = pcall(function()
        return nT.ScreenGui.Left.CashFrame.CashLabel.Text
    end)
    if qJ_1 then
        return oG(qK_1)
    end
    return 0
end
local function fn299()
    n_(om, "Copied Discord invite to clipboard")
end
local function worker3()
    while not Library.Unloaded do
        if pd("AutoSteal") then
            pcall(oV)
            task.wait(0.2)
        else
            task.wait(0.35)
        end
    end
end
local function fn339(hd)
    local DiscordGroup = hd:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = o1 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = o1 })
end
local function fn347()
    local qP = tonumber(n0:GetAttribute("Speed")) or 0
    return qP
end
local function fn352()
    local t0_1
    local t__1
    if ot then
        return
    end
    ot = true
    t__1, t0_1 = pcall(function()
        n4()
        if ob() then
            o_()
            return
        end
        local tL = #ph() > 0 and #oa(o0()) == 0 and pd("AutoPlace")
        if tL then
            return
        end
        local tL_1 = pa()
        if not tL_1 then
            return
        end
        local tM = oU(tL_1)
        if not tM then
            return
        end
        n2(tM)
        task.wait(0.2)
        n4()
        if not tL_1.prompt or not tL_1.prompt.Parent then
            return
        end
        local tU = 1
        while tU <= 4 do
            if ob() then
                break
            end
            local tN_1 = n5()
            if tN_1 then
                n2(tM)
            end
            oJ(tL_1.prompt)
            task.wait(0.25)
            tU += 1
        end
        local tL_2 = os.clock() + 2.5
        while true do
            local tM_1 = os.clock() < tL_2 and not ob()
            if tM_1 then
                task.wait(0.1)
                n4()
                continue
            end
            break
        end
        local tZ = if ob() then 1 else 0
        if tZ == 1 then
            o_()
        end
        n4()
    end)
    ot = false
    if not t__1 then
        warn("[Tempo] Auto Steal:", t0_1)
    end
end
local function worker()
    while not Library.Unloaded do
        if pd("AutoSell") then
            pcall(oH)
        end
        if pd("AutoRebirth") then
            pcall(nY)
        end
        if pd("AutoBuyTreadmills") then
            pcall(oo)
        end
        if pd("AutoClaimIndex") then
            pcall(n1)
        end
        if pd("AutoUnlockBasement") then
            pcall(pc)
        end
        task.wait(1.1)
    end
end
local function fn409(bU)
    local q3 = bU.prompt and bU.prompt.Parent
    local q4 = q3
    if q3 then
        q3 = q4:IsA("BasePart")
    end
    if not q3 then
        local q3_1 = bU.model
        if q3_1 then
            local q5_1 = bU.model.PrimaryPart or bU.model:FindFirstChildWhichIsA("BasePart", true)
            q3_1 = q5_1
        end
        q4 = q3_1
    end
    local q3_2 = q4 and q4:IsA("BasePart")
    if not q3_2 then
        local q3_3 = bU.folder and bU.folder:FindFirstChildWhichIsA("BasePart", true)
        q4 = q3_3
    end
    if not q4 then
        return nil
    end
    local q3_4 = q4.Position + Vector3.new(0, 8, 0)
    local q5_2 = RaycastParams.new()
    q5_2.FilterType = Enum.RaycastFilterType.Exclude
    local q6 = { n0.Character, bU.folder, bU.model }
    q5_2.FilterDescendantsInstances = q6
    local q6_1 = n7:Raycast(q3_4, Vector3.new(0, -40, 0), q5_2)
    local q3_5 = q6_1 and q6_1.Position.Y + 3.5
    local q5_3 = q3_5 or math.max(q4.Position.Y + 3.5, 4)
    return CFrame.new(q4.Position.X, q5_3, q4.Position.Z)
end
local function fn455()
    if n0:GetAttribute("BasementOwned") == true then
        return
    end
    local vm = n0:GetAttribute("CanAffordBasement") ~= true and nX() < 1000000
    if vm then
        return
    end
    local vm_1 = o0()
    local vn = vm_1 and vm_1:FindFirstChild("BasementDoor")
    local vm_2 = vn
    if vn then
        vn = vm_2:FindFirstChild("Door", true)
    end
    if vn then
        vn = vm_2.Door:FindFirstChild("DoorPrompt")
    end
    local vm_3 = vn
    if not vm_3 then
        return
    end
    local Parent = vm_3.Parent
    local vo = Parent and Parent:IsA("BasePart")
    if vo then
        n2(Parent.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.15)
    end
    oJ(vm_3)
end
local function fn464(cn)
    for i, child in cn:GetChildren() do
        local rq = child:IsA("Model") and child:GetAttribute("EggName")
        if rq then
            return child
        end
    end
end
local function fn465()
    pcall(function()
        ClaimIndexRewards:FireServer()
    end)
end
local function fn482(a1)
    local ql = ov(a1, {})
    if typeof(ql) ~= "table" then
        return {}
    end
    local qm = {}
    for k, v in ql do
        if v == true then
            qm[k] = true
        else
            local ql_1 = typeof(k) == "number" and typeof(v) == "string"
            if ql_1 then
                qm[v] = true
            end
        end
    end
    return qm
end
local function fn497()
    local uV = oq()
    local uV_1 = pi[uV + 1]
    if not uV_1 then
        return
    end
    local uW_1 = tonumber(uV_1.SpeedXP) or 0
    if oM() < uW_1 then
        return
    end
    pcall(function()
        Rebirth:FireServer()
    end)
end
local function fn523(dB)
    local sF = dB
    local sG = {}
    if sF then
        sF = dB:FindFirstChild("Slots")
    end
    local sH = sF
    if not sH then
        return sG
    end
    for i, child in sH:GetChildren() do
        local sF_1 = child:GetAttribute("Occupied") ~= true and child:GetAttribute("SlotState") == "Empty"
        if sF_1 then
            sG[#sG + 1] = child
        end
    end
    table.sort(sG, function(dI, dJ)
        return dI.Name < dJ.Name
    end)
    return sG
end
local function fn524(cs)
    local ry = n8[cs]
    return ry and ry.Rarity
end
local function fn542()
    local sp = n5()
    if not sp then
        return false
    end
    local su = 1
    while true do
        if not (su <= 4) then
            return not ob()
        end
        if not ob() then
            break
        end
        n2(oW)
        task.wait(0.05)
        local sp_1 = n5()
        if not sp_1 then
            return false
        end
        local sq = od:Create(sp_1, TweenInfo.new(0.35, Enum.EasingStyle.Linear), { CFrame = oR })
        sq:Play()
        sq.Completed:Wait()
        task.wait(0.25)
        su += 1
    end
    return true
end
local function fn636(aM, aN, aO)
    return string.format("<b>%s</b> %s %s", aM, oK("-", "#5a6070"), oK(aN, aO))
end
local function fn647(aj, ak)
    return aj.order < ak.order
end
local function fn652()
    local sd = {}
    for k, v in oP() do
        if oD(v) then
            sd[#sd + 1] = v
        end
    end
    if #sd == 0 then
        return nil
    end
    local se = ov("StealPriority", "Highest Rarity")
    if se == "Nearest" then
        table.sort(sd, function(dd, de)
            return dd.distance < de.distance
        end)
    elseif se == "Zone Order" then
        table.sort(sd, function(db, dc)
            if db.zoneOrder ~= dc.zoneOrder then
                return db.zoneOrder > dc.zoneOrder
            elseif db.rank ~= dc.rank then
                return db.rank > dc.rank
            else
                return db.distance < dc.distance
            end
        end)
    else
        table.sort(sd, function(c9, da)
            if c9.rank ~= da.rank then
                return c9.rank > da.rank
            end
            return c9.distance < da.distance
        end)
    end
    return sd[1]
end
local function fn656()
    local re = n5()
    if not re then
        return
    end
    if re.Position.Y > -10 then
        return
    end
    n2(oW)
end
local function fn728()
    local qR = tonumber(n0:GetAttribute("Rebirths")) or 0
    return qR
end
local function fn732(er)
    local tK = if er:GetAttribute("SlotState") ~= "Character" then 1 else 0
    if tK == 1 then
        return false
    end
    local attr2 = er:GetAttribute("Rarity")
    local attr = er:GetAttribute("CharName")
    local tE = nU("SellRarity")
    local tF = nU("SellCharacters")
    local tG = op("SellRarity") and not tE[attr2]
    if tG then
        return false
    end
    local tE_1 = op("SellCharacters") and not tF[attr]
    if tE_1 then
        return false
    end
    local tD_1 = ov("SellMinRarityRank", 0)
    local tE_2 = oL[attr2] or 0
    if tE_2 < tD_1 then
        return false
    end
    local tD_2 = ov("SellMaxRarityRank", 0)
    if tD_2 > 0 and tE_2 > tD_2 then
        return false
    end
    return true
end
local function fn752(dQ)
    for i, descendant in dQ:GetDescendants() do
        local sZ = descendant:IsA("TextLabel") and descendant.Name == "Timer"
        if sZ then
            local sZ_1 = ox(descendant.Text)
            if sZ_1 ~= nil then
                return sZ_1, descendant.Text
            end
        end
    end
    return nil
end
local function fn824(dX)
    local attr = dX:GetAttribute("SlotState")
    if attr == "EggReady" then
        return true
    elseif attr ~= "EggGrowing" then
        return false
    else
        local s6_1 = nil
        local s7 = false
        for i, descendant in dX:GetDescendants() do
            local ti_1 = if descendant:GetAttribute("EggReady") == true then 1 else 0
            if ti_1 == 1 then
                s7 = true
            end
            local s8_1 = descendant:IsA("ProximityPrompt") and descendant.Name == "HatchPrompt"
            if s8_1 then
                s6_1 = descendant
            end
        end
        if s7 then
            return true
        elseif s6_1 then
            local ActionText = s6_1.ActionText
            local s6_2 = ActionText == "Hatch?!"
            local s8_2 = ActionText == "Hatch"
            local ti_2 = if s8_2 then 1 else 0
            local tg = 1576 * ti_2 + 1591 * (1 - ti_2)
            local th = 2864 * ti_2 + 3145 * (1 - ti_2)
            if not ((tg * 165 + th * 480 + tg * th) % 16777213 == 6148424) then
                s8_2 = s6_2
            end
            if s8_2 then
                return true
            elseif string.find(string.lower(ActionText), "skip", 1, true) then
                return false
            else
                local s6_3 = nV(dX)
                return s6_3 ~= nil and s6_3 <= 0
            end
        else
            local s6_4 = nV(dX)
            return s6_4 ~= nil and s6_4 <= 0
        end
    end
end
local function fn852()
    local Character = n0.Character
    local qv = Character and Character:FindFirstChild("HumanoidRootPart")
    return qv
end
local function worker2()
    while not Library.Unloaded do
        if pd("AutoPlace") then
            pcall(o6)
        end
        if pd("AutoHatch") then
            pcall(oE)
        end
        task.wait(0.3)
    end
end
local function fn901(aJ, aK)
    return string.format('<font color="%s">%s</font>', aK, aJ)
end
local function fn917(bk)
    local qB_1
    if type(bk) == "number" then
        return bk
    end
    local qA = bk or ""
    local qA_1
    bk = tostring(qA):gsub("%$", ""):gsub(",", ""):gsub("%s", "")
    qB_1, qA_1 = string.match(bk, "^([%d%.]+)([%a]*)$")
    local qB_2 = tonumber(qB_1)
    if not qB_2 then
        return 0
    end
    local qC = {
        K = 1000,
        M = 1000000,
        B = 1000000000,
        T = 1000000000000,
        QA = 1000000000000000,
        QI = 1e+18,
        SX = 1e+21,
        SP = 1e+24,
        OC = 1e+27,
        NO = 1e+30,
        DC = 1e+33
    }
    local upper = string.upper
    local qE = qA_1 or ""
    local qA_2 = upper(qE)
    local qD_1 = qC[qA_2]
    local qI = if qD_1 then 1 else 0
    local qG = 2872 * qI + 2578 * (1 - qI)
    local qH = 2046 * qI + 223 * (1 - qI)
    if not ((qG * 3533 + qH * 1325 + qG * qH) % 16777213 == 1956625) then
        qD_1 = 1
    end
    return qB_2 * qD_1
end
local function fn918(d8)
    local tj = d8
    local tk = {}
    if tj then
        tj = d8:FindFirstChild("Slots")
    end
    local tl = tj
    if not tl then
        return tk
    end
    for i, child in tl:GetChildren() do
        if oA(child) then
            local tj_1 = nil
            for i, descendant in child:GetDescendants() do
                local tl_1 = descendant:IsA("ProximityPrompt") and descendant.Name == "HatchPrompt" and descendant.Enabled
                if tl_1 then
                    local tl_2 = string.lower(descendant.ActionText)
                    local tm_1 = tl_2 == "hatch" or tl_2 == "hatch?!" or not string.find(tl_2, "skip", 1, true)
                    if tm_1 then
                        tj_1 = descendant
                        break
                    end
                end
            end
            local tl_3 = child:FindFirstChild("SpawnPart") and child.SpawnPart:FindFirstChild("PickPrompt")
            local tm_2 = tl_3
            if tm_2 then
                local tl_4 = string.lower(tm_2.ActionText)
                if tl_4 ~= "hatch" and tl_4 ~= "hatch?!" then
                    tm_2 = nil
                end
            end
            if tj_1 or tm_2 then
                local tl_6 = #tk + 1
                local tn_2 = nV(child) or 0
                tk[tl_6] = { slot = child, hatch = tj_1, pick = tm_2, timer = tn_2 }
            end
        end
    end
    table.sort(tk, function(eo, ep)
        return eo.timer < ep.timer
    end)
    return tk
end
local function fn932(aX, aY)
    local qj = Options[aX]
    if qj == nil then
        return aY
    end
    return qj.Value
end
local function fn936()
    local rB = {}
    local rC = n5()
    local rD = rC and rC.Position
    for i, child in o3:GetChildren() do
        for i, child2 in child:GetChildren() do
            if child2.Name == "EggFolder" then
                local rD_1 = ol(child2)
                local ProximityPrompt = child2:FindFirstChildWhichIsA("ProximityPrompt", true)
                if rD_1 and ProximityPrompt and ProximityPrompt.Enabled and ProximityPrompt.ActionText == "Steal" then
                    local rF_1 = rD_1:GetAttribute("EggName") or rD_1.Name
                    local rF_2 = pj(rF_1)
                    local BasePart = child2:FindFirstChildWhichIsA("BasePart", true)
                    local rI = BasePart and BasePart.Position
                    local rI_1 = #rB + 1
                    local Name = child.Name
                    local rK = rD_1:GetAttribute("Mutation") or "Normal"
                    local rL = oL[rF_2] or 0
                    local rM = o9[child.Name] or 0
                    local rN_1 = rD and rI and (rI - rD).Magnitude or math.huge
                    rB[rI_1] = {
                        folder = child2,
                        model = rD_1,
                        prompt = ProximityPrompt,
                        zone = Name,
                        eggName = rF_1,
                        rarity = rF_2,
                        mutation = rK,
                        rank = rL,
                        zoneOrder = rM,
                        distance = rN_1,
                        position = rI
                    }
                end
            end
        end
    end
    return rB
end
local function fn959(cX)
    local r1 = nU("StealRarity")
    local r2 = nU("StealZone")
    local r3 = op("StealRarity") and not r1[cX.rarity]
    if r3 then
        return false
    end
    local r1_1 = op("StealZone") and not r2[cX.zone]
    if r1_1 then
        return false
    end
    return true
end
local function fn971(dL)
    local sS = dL or ""
    local sS_5
    dL = tostring(sS):lower():gsub("%s", "")
    local sS_1 = dL == "ready"
    local sT = dL == ""
    local sT_2
    local sY = if sT then 1 else 0
    local sW = 1486 * sY + 276 * (1 - sY)
    local sX = 3656 * sY + 2630 * (1 - sY)
    if not ((sW * 203 + sX * 1207 + sW * sX) % 16777213 == 10147266) then
        sT = sS_1
    end
    if sT or dL == "0s" or dL == "0" then
        return 0
    end
    local sS_4 = dL:find("%$") or dL:find("/")
    if sS_4 then
        return nil
    end
    sS_5, sT_2 = string.match(dL, "^(%d+)m(%d+)s$")
    if sS_5 then
        return tonumber(sS_5) * 60 + tonumber(sT_2)
    end
    local sS_6 = string.match(dL, "^(%d+)m$")
    if sS_6 then
        return tonumber(sS_6) * 60
    end
    local sT_3 = string.match(dL, "^(%d+)s$")
    if sT_3 then
        return tonumber(sT_3)
    end
    return nil
end
local function fn981(a9)
    return next(nU(a9)) ~= nil
end
nT = nil
nU = nil
nV = nil
nX = nil
nY = nil
n_ = nil
n0 = nil
n1 = nil
n2 = nil
n4 = nil
n5 = nil
n6 = nil
n7 = nil
n8 = nil
oa = nil
ob = nil
od = nil
ClaimIndexRewards = nil
ol = nil
om = nil
oo = nil
op = nil
oq = nil
ot = nil
ov = nil
ox = nil
oA = nil
Options = nil
oC = nil
oD = nil
oE = nil
Rebirth = nil
oG = nil
oH = nil
local nR, nS, nW, nZ, n3, n9, oc, oe, of, og, oh, oi, ou, ow, oy, oz
oJ = nil
oK = nil
oL = nil
oM = nil
Toggles = nil
oP = nil
oQ = nil
oR = nil
oU = nil
oV = nil
oW = nil
Bases = nil
o_ = nil
o0 = nil
o1 = nil
local o2
o3 = nil
Library = nil
o6 = nil
o8 = nil
o9 = nil
pa = nil
pc = nil
pd = nil
pf = nil
pg = nil
ph = nil
pi = nil
pj = nil
local oI, oZ, o5, pb, po, pp, pq, pr, pt
local pm_2, pm_3
oI = nil
local oO
local SaveManager
local oT
local ThemeManager
oZ = nil
o5 = nil
local o7
pb = nil
local pe
nR, x7_3_1, o5, oZ, oT, oO, oC, ou, oi, od, n7, n0, nT, pf = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local x7_14 = 0
repeat
    local pm_1 = (x7_14 * 4 + 4) % 5 + 1
    if pm_1 <= 3 then
        if pm_1 <= 2 then
            if pm_1 <= 1 then
                if x7_14 * 51559409 + 11 + 7 >= x7_14 * 51559409 + 11 + 7 + 1 then
                    oT = game:GetService("ReplicatedStorage")
                    x7_3_1 = game:GetService("RunService")
                    o5 = game:GetService("UserInputService")
                    oZ = game:GetService("VirtualUser")
                else
                    x7_3_1 = game:GetService("ReplicatedStorage")
                    o5 = game:GetService("RunService")
                    oZ = game:GetService("UserInputService")
                    oT = game:GetService("VirtualUser")
                end
                x7_14 = (x7_14 + 9) % 40
            else
                local yY = bit32.rrotate(bit32.bxor(bit32.lrotate(x7_14, 26), string.byte(tostring(oO))), 17)
                if bit32.bxor(bit32.lrotate(bit32.bxor(yY, 2808248932), 26), 2459797993) == bit32.lrotate(yY, 26) then
                    oO = game:GetService("HttpService")
                    oC = game:GetService("CoreGui")
                    ou = game:GetService("GuiService")
                else
                    ou = game:GetService("HttpService")
                    oO = game:GetService("CoreGui")
                    oC = game:GetService("GuiService")
                end
                x7_14 = (x7_14 + 24) % 40
            end
        else
            local pn_1 = (vector.create((x7_14 * 6 + 8) % 11 + 1, (x7_14 * 9 + 11) % 13 + 1, (x7_14 * 12 + 9) % 17 + 1))
            po = (vector.create((x7_14 * 7 + 5) % 11 + 1, (x7_14 * 5 + 7) % 13 + 1, (x7_14 * 15 + 17) % 17 + 1))
            pp = (vector.create((x7_14 * 2 + 4) % 11 + 1, (x7_14 * 7 + 7) % 13 + 1, (x7_14 * 10 + 13) % 17 + 1))
            pq = (vector.create((x7_14 * 5 + 3) % 5 + 1, (x7_14 * 1 + 3) % 7 + 1, (x7_14 * 4 + 5) % 9 + 1))
            if vector.dot(vector.cross(pn_1, (vector.cross(po, pp))), pq) == vector.dot(po * vector.dot(pn_1, pp) - pp * vector.dot(pn_1, po), pq) + 3 then
                nR = game:GetService("TeleportService")
                nT = game:GetService("TweenService")
                oi = game:GetService("Workspace")
                od = n7.LocalPlayer
                n0 = od:WaitForChild("PlayerGui")
            else
                oi = game:GetService("TeleportService")
                od = game:GetService("TweenService")
                n7 = game:GetService("Workspace")
                n0 = nR.LocalPlayer
                nT = n0:WaitForChild("PlayerGui")
            end
            x7_14 = (x7_14 + 34) % 40
        end
    elseif pm_1 <= 4 then
        if x7_14 * 70683539 + 10 + 7 <= x7_14 * 70683539 + 10 + 7 + 1 then
            pf = fn217
        else
            nR = fn217
        end
        x7_14 = (x7_14 + 24) % 40
    else
        local zf = bit32.rrotate(bit32.bxor(bit32.lrotate(x7_14, 4), string.byte(tostring(oO))), 4)
        if bit32.bxor(bit32.lrotate(bit32.bxor(zf, 1701942789), 4), 1461280854) ~= bit32.lrotate(zf, 4) then
            nT = game:GetService("Players")
        else
            nR = game:GetService("Players")
        end
        x7_14 = (x7_14 + 9) % 40
    end
until (x7_14 * 11 + 8) % 40 == 28
if getgenv then
    o2, pm_2 = nil, nil
    x7_14 = 2
    repeat
        if (x7_14 * 1 + 0) % 2 + 1 <= 1 then
            local yC = bit32.rrotate(bit32.bxor(bit32.lrotate(x7_14, 9), string.byte(tostring(o2))), 11)
            if bit32.bxor(bit32.lrotate(bit32.bxor(yC, 4047591297), 16), 1468133697) ~= bit32.lrotate(yC, 16) then
                getgenv().gethui = o2
                pf = getgenv().__TempoStealALuckyEggLib
            else
                getgenv().gethui = pf
                o2 = getgenv().__TempoStealALuckyEggLib
            end
            x7_14 = (x7_14 + 13) % 16
        else
            local yG = bit32.rrotate(bit32.bxor(bit32.lrotate(x7_14, 21), string.byte(tostring(pm_2))), 26)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(yG, 3377692779), 3705170219), (bit32.bxor(bit32.band(yG, 917274516), 1012096761))), 3705170219), 1012096761) == yG then
                pm_2 = o2
            else
                o2 = pm_2
            end
            x7_14 = (x7_14 + 15) % 16
        end
    until (x7_14 * 15 + 15) % 16 == 1
    if pm_2 then
        pm_2 = o2.Unload
    end
    if pm_2 then
        pcall(function()
            o2:Unload()
        end)
    end
end
pcall(function()
    gethui = pf
end)
if setthreadidentity then
    setthreadidentity(8)
end
oz, om, og, n9, n3, nZ, nS, pe, o7, po, oQ, Rebirth, ow, ClaimIndexRewards, pm_3, n8, pp, pq, pi, pb, o3, Bases, pr, oL = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
x7_14 = 16
repeat
    local ps_1 = (x7_14 * 5 + 2) % 13 + 1
    if ps_1 <= 7 then
        if ps_1 <= 4 then
            if ps_1 <= 2 then
                if ps_1 <= 1 then
                    if x7_14 * 63634943 + 3 + 4 <= x7_14 * 63634943 + 3 + 4 + 4 then
                        n8 = require(pm_3:WaitForChild("CharactersModule"))
                        pp = require(pm_3:WaitForChild("RaritiesModule"))
                        pq = require(pm_3:WaitForChild("BiomesModule"))
                        pi = require(pm_3:WaitForChild("RebirthModule"))
                        pb = require(pm_3:WaitForChild("TreadmillModule"))
                    else
                        pm_3 = require(pq:WaitForChild("CharactersModule"))
                        pi = require(pq:WaitForChild("RaritiesModule"))
                        n8 = require(pq:WaitForChild("BiomesModule"))
                        pb = require(pq:WaitForChild("RebirthModule"))
                        pp = require(pq:WaitForChild("TreadmillModule"))
                    end
                    x7_14 = (x7_14 + 21) % 52
                else
                    if x7_14 * 26148889 + 11 + 1 <= x7_14 * 26148889 + 11 + 1 + 1 then
                        o3 = n7:WaitForChild("Eggs")
                        Bases = n7:WaitForChild("Bases")
                    else
                        n7 = Bases:WaitForChild("Eggs")
                        o3 = Bases:WaitForChild("Bases")
                    end
                    x7_14 = (x7_14 + 34) % 52
                end
            elseif ps_1 <= 3 then
                local y4 = bit32.rrotate(bit32.bxor(bit32.lrotate(x7_14, 29), string.byte(tostring(pq))), 1)
                if bit32.bxor(bit32.lrotate(bit32.bxor(y4, 2119981450), 16), 1502248540) == bit32.lrotate(y4, 16) then
                    pr = {}
                else
                    og = {}
                end
                x7_14 = (x7_14 + 8) % 52
            else
                pt = { "gexeyfrlo", "mshowyxrk", "twslrudn", "dvedt", "uzoapq", "csy", "opedz", "lomah" }
                if pt[(x7_14 * 9 + 88) % 8 + 1] <= pt[(x7_14 * 9 + 88) % 8 + 1] then
                    oL = {}
                else
                    og = {}
                end
                x7_14 = (x7_14 + 47) % 52
            end
        elseif ps_1 <= 6 then
            if ps_1 <= 5 then
                local y0 = bit32.rrotate(bit32.bxor(bit32.lrotate(x7_14, 3), string.byte(tostring(nZ))), 31)
                if bit32.bxor(bit32.lrotate(bit32.bxor(y0, 4234905838), 30), 3206210107) == bit32.lrotate(y0, 30) then
                    oz = "Steal A Lucky Egg"
                    om = "https://discord.gg/K7Qxnxkk46"
                    og = "https://discord.gg/K7Qxnxkk46"
                else
                    og = "Steal A Lucky Egg"
                    oz = "https://discord.gg/K7Qxnxkk46"
                    om = "https://discord.gg/K7Qxnxkk46"
                end
                x7_14 = (x7_14 + 47) % 52
            else
                if x7_14 * 132815157 + 6 + 5 <= x7_14 * 132815157 + 6 + 5 + 5 then
                    n9 = "https://tempohub.shop"
                end
                x7_14 = (x7_14 + 8) % 52
            end
        else
            pt = (vector.create((x7_14 * 2 + 8) % 11 + 1, (x7_14 * 7 + 7) % 13 + 1, (x7_14 * 14 + 5) % 17 + 1))
            local pu = (vector.create((x7_14 * 5 + 3) % 11 + 1, (x7_14 * 3 + 13) % 13 + 1, (x7_14 * 2 + 2) % 17 + 1))
            local pv_1 = (vector.create((x7_14 * 1 + 6) % 5 + 1, (x7_14 * 3 + 6) % 7 + 1, (x7_14 * 4 + 3) % 9 + 1))
            if math.abs((vector.angle(pt, pu, pv_1))) - math.abs((vector.angle(pu, pt, pv_1))) == 4 then
                nZ = "#7fd47f"
                n3 = "#6ec1ff"
            else
                n3 = "#7fd47f"
                nZ = "#6ec1ff"
            end
            x7_14 = (x7_14 + 8) % 52
        end
    elseif ps_1 <= 10 then
        if ps_1 <= 9 then
            if ps_1 <= 8 then
                if (x7_14 * 2 + 2) * 10 % 3 == ((x7_14 * 2 + 2) * 10 + 6) % 3 then
                    nS = "#e8a34d"
                    pe = "#8b93a3"
                else
                    pe = "#e8a34d"
                    nS = "#8b93a3"
                end
                x7_14 = (x7_14 + 8) % 52
            else
                if (x7_14 * 3 + 2) * 9 % 4 == ((x7_14 * 3 + 2) * 9 + 8) % 4 then
                    o7 = "#e05a5a"
                else
                    og = "#e05a5a"
                end
                x7_14 = (x7_14 + 34) % 52
            end
        else
            if x7_14 * 1353759 + 6 + 4 >= x7_14 * 1353759 + 6 + 4 + 2 then
                x7_3_1 = po:WaitForChild("Remotes")
            else
                po = x7_3_1:WaitForChild("Remotes")
            end
            x7_14 = (x7_14 + 8) % 52
        end
    elseif ps_1 <= 12 then
        if ps_1 <= 11 then
            local ps_2 = (vector.create((x7_14 * 7 + 3) % 11 + 1, (x7_14 * 9 + 7) % 13 + 1, (x7_14 * 6 + 13) % 17 + 1))
            local y1 = vector.floor(ps_2) + vector.ceil(ps_2 * -1)
            if vector.dot(y1, y1) == 0 then
                po:WaitForChild("EggSlotInteract")
                oQ = po:WaitForChild("Sell")
                Rebirth = po:WaitForChild("Rebirth")
            else
                oQ = Rebirth:WaitForChild("EggSlotInteract")
                po = Rebirth:WaitForChild("Sell")
                Rebirth:WaitForChild("Rebirth")
            end
            x7_14 = (x7_14 + 47) % 52
        else
            if not pp and o3 and (pp or o3) and (o3 and not pp and (not o3 or o3)) or not (not pp and o3 and (pp or o3) and (o3 and not pp and (not o3 or o3))) then
                ow = po:WaitForChild("BuyTreadmill")
                ClaimIndexRewards = po:WaitForChild("ClaimIndexRewards")
            else
                po = ClaimIndexRewards:WaitForChild("BuyTreadmill")
                ow = ClaimIndexRewards:WaitForChild("ClaimIndexRewards")
            end
            x7_14 = (x7_14 + 21) % 52
        end
    else
        if x7_14 * 56272475 + 10 + 1 <= x7_14 * 56272475 + 10 + 1 + 1 then
            pm_3 = x7_3_1:WaitForChild("ClientModules")
        else
            x7_3_1 = pm_3:WaitForChild("ClientModules")
        end
        x7_14 = (x7_14 + 34) % 52
    end
until (x7_14 * 9 + 9) % 52 == 10
local ps_3 = {}
for k, v in pp do
    x7_14 = #ps_3 + 1
    local x7_3_2 = tonumber(v.Order) or 0
    ps_3[x7_14] = { name = k, order = x7_3_2 }
end
local pm_4 = 0
repeat
    if (pm_4 * 2 + 8) * 7 % 3 == ((pm_4 * 2 + 8) * 7 + 3) % 3 then
        table.sort(ps_3, fn201)
    else
        table.sort(ps_3, fn201)
    end
    pm_4 = (pm_4 + 2) % 8
until (pm_4 * 7 + 6) % 8 == 4
for k, v in ps_3 do
    pr[#pr + 1] = v.name
    oL[v.name] = v.order
end
o9 = {}
x7_14 = {}
local x7_3_3 = {}
for k, v in pq do
    local pm_5 = #x7_3_3 + 1
    local pn_3 = tonumber(v.Order) or 0
    x7_3_3[pm_5] = { name = k, order = pn_3 }
end
table.sort(x7_3_3, fn647)
for k, v in x7_3_3 do
    x7_14[#x7_14 + 1] = v.name
    o9[v.name] = v.order
end
nW = nil
local pn_4 = { "Highest Rarity", "Nearest", "Zone Order" }
local pm_6 = { "Sell All", "Sell Filtered Slots" }
nW = {}
local p1 = 1
while p1 <= 20 do
    local p2 = p1
    if pb[p2] then
        nW[#nW + 1] = p2
    end
    p1 += 1
end
Library, ThemeManager, SaveManager = nil, nil, nil
Library = getgenv().Library
ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
if getgenv then
    getgenv().__TempoStealALuckyEggLib = Library
end
Toggles, Options, ot, oh, oc, n6, oW, oR, n_, o1, oK, of, pd, ov, nU, op, n5, o8, oG, nX, oM, oq, ob, oJ, n2, oU, n4, o0, ol, pj, oP, oD, pa, o_, ph, oa, ox, nV, oA, oI, pg, oV, o6, oE, oH, nY, oe, oo, n1, pc = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Toggles = Library.Toggles
Options = Library.Options
ot = false
oh = false
oc = false
n6 = false
n_ = fn200
o1 = fn299
oK = fn901
of = fn636
pd = fn58
ov = fn932
nU = fn482
op = fn981
n5 = fn852
o8 = fn184
oG = fn917
nX = fn272
oM = fn347
oq = fn728
ob = fn39
oW = CFrame.new(144, 4, -30)
oR = CFrame.new(156, 4, -30)
oJ = function(bJ)
    local qW = not bJ or not bJ:IsA("ProximityPrompt")
    if qW then
        return false
    elseif not fireproximityprompt then
        return false
    else
        pcall(function()
            bJ.HoldDuration = 0
            bJ.MaxActivationDistance = math.max(bJ.MaxActivationDistance, 20)
            bJ.RequiresLineOfSight = false
        end)
        local qW_1 = pcall(fireproximityprompt, bJ) or pcall(fireproximityprompt, bJ, 1)
        return qW_1 == true
    end
end
n2 = fn251
oU = fn409
n4 = fn656
o0 = fn72
if (not o_ and not oM or not oM and false or false) and (not oM and (not oM and not oM) and 116) and ((not o_ and 116 and o_) or 116) and not ((not o_ and not oM or not oM and false or false) and (not oM and (not oM and not oM) and 116) and ((not o_ and 116 and o_) or 116)) then
    oP = fn464
    ol = fn524
    pj = fn936
else
    ol = fn464
    pj = fn524
    oP = fn936
end
oD = fn959
pa = fn652
o_ = fn542
ph = function()
    local dr
    dr = {}
    local function ds(du)
        if not du then
            return
        end
        for i, child in du:GetChildren() do
            local sx = child:IsA("Tool") and child:GetAttribute("IsEgg")
            if sx then
                dr[#dr + 1] = child
            end
        end
    end
    ds(n0.Backpack)
    ds(n0.Character)
    return dr
end
oa = fn523
ox = fn971
nV = fn752
oA = fn824
oI = fn918
pg = fn732
oV = fn352
o6 = function()
    local ue, uf
    local uh_1
    local ug = oh or ob()
    local ug_3
    if ug then
        return
    end
    local ug_1 = o0()
    ue = oa(ug_1)
    uf = ph()
    if #ue == 0 or #uf == 0 then
        return
    end
    oh = true
    ug_3, uh_1 = pcall(function()
        local t2 = uf[1]
        local t3 = ue[1]
        local SpawnPart = t3:FindFirstChild("SpawnPart")
        local t5 = SpawnPart and SpawnPart:FindFirstChild("PickPrompt")
        local t5_1 = o8()
        local t8 = not t5_1 or not SpawnPart
        local t7_1 = not t5
        local t9 = t8
        local ud = if t9 then 1 else 0
        local ub = 2605 * ud + 2102 * (1 - ud)
        local uc = 1493 * ud + 1062 * (1 - ud)
        if not ((ub * 2716 + uc * 1676 + ub * uc) % 16777213 == 13466713) then
            t9 = t7_1
        end
        if t9 then
            return
        end
        if t2.Parent ~= n0.Character then
            t5_1:EquipTool(t2)
            task.wait(0.2)
        end
        oJ(t5)
        task.wait(0.35)
        if t3:GetAttribute("Occupied") == true then
            return
        end
        n2(SpawnPart.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.15)
        oJ(t5)
        task.wait(0.35)
    end)
    oh = false
    if not ug_3 then
        warn("[Tempo] Auto Place:", uh_1)
    end
end
oE = function()
    local uD
    local uF_1
    local uE_1
    if oc then
        return
    end
    uD = oI(o0())
    if #uD == 0 then
        return
    end
    oc = true
    uE_1, uF_1 = pcall(function()
        for k, v in uD do
            local um = Library.Unloaded or not pd("AutoHatch")
            if um then
                break
            elseif not not oA(v.slot) then
                local um_1 = v.hatch
                local un = not um_1 or not um_1.Parent or string.find(string.lower(um_1.ActionText), "skip", 1, true)
                if un then
                    um_1 = nil
                    for i, descendant in v.slot:GetDescendants() do
                        local un_1 = descendant:IsA("ProximityPrompt") and descendant.Name == "HatchPrompt" and descendant.Enabled
                        if un_1 then
                            local un_2 = string.lower(descendant.ActionText)
                            if un_2 == "hatch" or un_2 == "hatch?!" then
                                um_1 = descendant
                                break
                            end
                        end
                    end
                end
                if not not um_1 then
                    oJ(um_1)
                    task.wait(0.2)
                end
            end
        end
    end)
    oc = false
    if not uE_1 then
        warn("[Tempo] Auto Hatch:", uF_1)
    end
end
oH = fn119
nY = fn497
oe = function()
    local u5
    u5 = nil
    u5 = {}
    local function u6(gt)
        if not gt then
            return
        end
        for i, child in gt:GetChildren() do
            local uY = child:IsA("Tool") and child:GetAttribute("Treadmill")
            if uY then
                local uY_1 = tonumber(child:GetAttribute("TreadmillIndex"))
                if uY_1 then
                    u5[uY_1] = true
                end
            end
        end
    end
    u6(n0.Backpack)
    u6(n0.Character)
    u6 = tonumber(n0:GetAttribute("TreadmillIndex"))
    if u6 then
        u5[u6] = true
    end
    return u5
end
oo = function()
    local u8 = oe()
    local u9 = nX()
    for k, v in nW do
        local vi = v
        if not u8[vi] then
            local va = pb[vi]
            local vb = va and tonumber(va.Cost)
            local vb_1 = vb or 0
            if vb_1 > 0 and u9 >= vb_1 * 0.98 then
                pcall(function()
                    ow:FireServer(vi, "Cash")
                end)
                task.wait(0.35)
            end
            break
        end
    end
end
n1 = fn465
pc = fn455
po = {}
for k, v in n8 do
    if not v.IsEgg then
        po[#po + 1] = k
    end
end
table.sort(po)
oy = nil
local x7_3_4 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = om, Copyable = true }, "|", oz },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
oy = {
    Info = x7_3_4:AddTab("Info", "info"),
    Main = x7_3_4:AddTab("Main", "egg"),
    Player = x7_3_4:AddTab("Player", "person-standing"),
    Settings = x7_3_4:AddTab("Settings", "settings")
}
pq = fn339
for k, v in oy do
    if k ~= "Info" then
        pq(v)
    end
end
pp = nil
local StealGroup = oy.Main:AddLeftGroupbox("Steal", "hand")
StealGroup:AddToggle("AutoSteal", { Text = "Auto Steal", Default = false })
StealGroup:AddDropdown("StealRarity", { Text = "Rarity", Values = pr, Default = {}, Multi = true, AllowEmpty = true })
StealGroup:AddDropdown("StealZone", { Text = "Zone", Values = x7_14, Default = {}, Multi = true, AllowEmpty = true })
StealGroup:AddDropdown("StealPriority", { Text = "Priority", Values = pn_4, Default = 1 })
local FarmGroup = oy.Main:AddLeftGroupbox("Farm", "shovel")
FarmGroup:AddToggle("AutoPlace", { Text = "Auto Place", Default = false })
FarmGroup:AddToggle("AutoHatch", { Text = "Auto Hatch", Default = false })
FarmGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
FarmGroup:AddToggle("AutoBuyTreadmills", { Text = "Auto Buy Treadmills", Default = false })
FarmGroup:AddToggle("AutoClaimIndex", { Text = "Auto Claim Index", Default = false })
FarmGroup:AddToggle("AutoUnlockBasement", { Text = "Auto Unlock Basement", Default = false })
local SellGroup = oy.Main:AddRightGroupbox("Sell", "tags")
if (FarmGroup or not FarmGroup) and (FarmGroup or FarmGroup) or (FarmGroup and pp or (true or StealGroup)) or (not StealGroup and FarmGroup or StealGroup and not FarmGroup) and (true and not StealGroup or pp and not StealGroup) or (not StealGroup or FarmGroup or not FarmGroup and StealGroup) and (FarmGroup or not StealGroup or (pp or not StealGroup)) and (FarmGroup or FarmGroup or (FarmGroup or StealGroup) or pp and FarmGroup and true) or not ((FarmGroup or not FarmGroup) and (FarmGroup or FarmGroup) or (FarmGroup and pp or (true or StealGroup)) or (not StealGroup and FarmGroup or StealGroup and not FarmGroup) and (true and not StealGroup or pp and not StealGroup) or (not StealGroup or FarmGroup or not FarmGroup and StealGroup) and (FarmGroup or not StealGroup or (pp or not StealGroup)) and (FarmGroup or FarmGroup or (FarmGroup or StealGroup) or pp and FarmGroup and true)) then
    SellGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
    SellGroup:AddDropdown("SellMode", { Text = "Mode", Values = pm_6, Default = 1 })
    SellGroup:AddDivider("Filters")
    SellGroup:AddDropdown("SellRarity", {
        Text = "Rarity",
        Values = pr,
        Default = { Common = true, Uncommon = true },
        Multi = true,
        AllowEmpty = true
    })
    SellGroup:AddDropdown("SellCharacters", {
        Text = "Characters",
        Values = po,
        Default = {},
        Multi = true,
        AllowEmpty = true,
        Searchable = true
    })
    SellGroup:AddSlider("SellMinRarityRank", { Text = "Min Rank", Default = 0, Min = 0, Max = 11, Rounding = 0 })
    SellGroup:AddSlider("SellMaxRarityRank", { Text = "Max Rank (0 = none)", Default = 0, Min = 0, Max = 11, Rounding = 0 })
    pp = function()
        local wh
        local wi
        wh = nil
        wi = nil
        local Label, Label2, Label3, wm, wn
        local function wo()
            local vw = hookfunction ~= nil
            local vx = hookmetamethod ~= nil
            local vy = getrawmetatable ~= nil
            local vz = setrawmetatable ~= nil
            local vA = getgc ~= nil
            local vB = getgenv ~= nil
            local vC = getreg ~= nil
            local vD = getconnections ~= nil
            local vE = firesignal ~= nil
            local vF = getcallbackvalue ~= nil
            local vG = setclipboard ~= nil
            local vH = getcustomasset ~= nil
            local vI = getnamecallmethod ~= nil
            local vJ = isexecutorclosure ~= nil
            local vK = fireproximityprompt ~= nil
            local vL = firetouchinterest ~= nil
            local vM = WebSocket ~= nil
            local vN = readfile ~= nil
            local vO = writefile ~= nil
            local vQ = (request or http_request) ~= nil
            local vS = (debug and debug.getupvalues) ~= nil
            local vU = (debug and debug.setupvalue) ~= nil
            local vV = 0
            local vW = { vw, vx, vy, vz, vA, vB, vC, vD, vE, vF, vG, vH, vI, vJ, vK, vL, vM, vN, vO, vQ, vS, vU }
            for i, v in ipairs(vW) do
                if v then
                    vV += 1
                end
            end
            local vw_1 = vV / #vW
            if vw_1 >= 0.9 then
                return oK("Full Support", n3)
            elseif vw_1 >= 0.6 then
                return oK("Half Support", nS)
            else
                return oK("Low Support", o7)
            end
        end
        wh = "Unknown"
        pcall(function()
            local v4_1
            local v3_1
            if identifyexecutor then
                v4_1, v3_1 = identifyexecutor()
                local v5 = v4_1 ~= ""
                local v6 = type(v4_1) == "string" and v5
                if v6 then
                    local v5_1 = type(v3_1) == "string" and v3_1 ~= "" and v4_1 .. " " .. v3_1
                    wh = v5_1 or v4_1
                end
            end
        end)
        local wp = wo()
        wi = os.clock()
        wm = function()
            local wb = math.floor(os.clock() - wi)
            if wb < 60 then
                return wb .. "s"
            elseif wb < 3600 then
                return string.format("%dm %ds", math.floor((wb) / (60)), wb % 60)
            else
                return string.format("%dh %dm", math.floor((wb) / (3600)), math.floor((wb % 3600) / (60)))
            end
        end
        local UserGroup = oy.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = n0, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(of("User", n0.DisplayName .. " @" .. n0.Name, n3), true)
        UserGroup:AddLabel(of("UserId", tostring(n0.UserId), nZ), true)
        UserGroup:AddLabel(of("Executor", wh .. "  " .. wp, n3), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(of("Session", wm(), nS), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                n_(n0.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                n_("https://www.roblox.com/users/" .. tostring(n0.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = oy.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddDivider("Server")
        SessionGroup:AddLabel(of("Game", oz, nZ), true)
        Label2 = SessionGroup:AddLabel(of("Players", "0/0", n3), true)
        wn = tostring(game.JobId)
        local wp_1 = #wn > 18 and string.sub(wn, 1, 18) .. "..."
        local wp_2 = wp_1 or wn
        SessionGroup:AddLabel(of("Job", wp_2, pe), true)
        Label = SessionGroup:AddLabel(of("Ping", "0 ms", nS), true)
        SessionGroup:AddDivider()
        SessionGroup:AddButton({
            Text = "Rejoin Server",
            Func = function()
                oi:Teleport(game.PlaceId, n0)
            end
        })
        SessionGroup:AddButton({
            Text = "Copy Job ID",
            Func = function()
                n_(wn, "Copied Job ID")
            end
        })
        task.spawn(function()
            local we_1
            local wd_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(of("Session", wm(), nS))
                Label2:SetText(of("Players", #nR:GetPlayers() .. "/" .. tostring(nR.MaxPlayers), n3))
                wd_1, we_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local wd_2 = wd_1 and we_1 .. " ms" or "n/a"
                Label:SetText(of("Ping", wd_2, nS))
            end
        end)
        local SocialsGroup = oy.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = o1 })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                n_(og, "Copied Rscripts profile to clipboard")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                n_(n9, "Copied website link")
            end
        })
    end
else
    pm_6:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
    pm_6:AddDropdown("SellMode", { Text = "Mode", Values = po, Default = 1 })
    pm_6:AddDivider("Filters")
    pm_6:AddDropdown("SellRarity", {
        Values = pp,
        Multi = true,
        AllowEmpty = true,
        Text = "Rarity",
        Default = { Common = true, Uncommon = true }
    })
    pm_6:AddDropdown("SellCharacters", {
        AllowEmpty = true,
        Text = "Characters",
        Values = pr,
        Searchable = true,
        Multi = true,
        Default = {}
    })
    pm_6:AddSlider("SellMinRarityRank", { Min = 0, Rounding = 0, Default = 0, Text = "Min Rank", Max = 11 })
    pm_6:AddSlider("SellMaxRarityRank", { Text = "Max Rank (0 = none)", Default = 0, Max = 11, Min = 0, Rounding = 0 })
end
pt = function()
    local MovementGroup = oy.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = oy.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local connection
    local function iD(iE)
        pcall(function()
            ou:SetGameplayPausedNotificationEnabled(not iE)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = oC:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not iE
            end
        end)
        if not iE then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(n0, "GameplayPaused", false)
            else
                n0.GameplayPaused = false
            end
        end)
    end
    local function iR(iS)
        if not iS:IsA("ProximityPrompt") then
            return
        end
        iS.HoldDuration = 0
        iS.MaxActivationDistance = 50
        iS.RequiresLineOfSight = false
    end
    o5.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        local wH = if pd("NoClip") then 1 else 0
        if wH == 1 then
            local Character = n0.Character
            if Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    local wx_1 = descendant:IsA("BasePart") and descendant.CanCollide
                    if wx_1 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    oZ.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if pd("InfJump") then
            local wI = o8()
            if wI then
                wI:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    o5.RenderStepped:Connect(function(i8)
        if Library.Unloaded then
            return
        end
        if pd("WalkSpeedEnabled") then
            local wK_1 = o8()
            local WalkSpeed = Options.WalkSpeed
            if wK_1 and WalkSpeed then
                wK_1.WalkSpeed = WalkSpeed.Value
            end
        end
        if pd("Fly") then
            local wK_2 = n5()
            local wL_2 = o8()
            local FlySpeed = Options.FlySpeed
            local CurrentCamera = n7.CurrentCamera
            if wK_2 and wL_2 and FlySpeed and CurrentCamera then
                wL_2.PlatformStand = true
                local wL_3 = Vector3.zero
                if oZ:IsKeyDown(Enum.KeyCode.W) then
                    wL_3 += CurrentCamera.CFrame.LookVector
                end
                if oZ:IsKeyDown(Enum.KeyCode.S) then
                    wL_3 -= CurrentCamera.CFrame.LookVector
                end
                if oZ:IsKeyDown(Enum.KeyCode.A) then
                    wL_3 -= CurrentCamera.CFrame.RightVector
                end
                if oZ:IsKeyDown(Enum.KeyCode.D) then
                    wL_3 += CurrentCamera.CFrame.RightVector
                end
                if oZ:IsKeyDown(Enum.KeyCode.Space) then
                    wL_3 += Vector3.new(0, 1, 0)
                end
                if oZ:IsKeyDown(Enum.KeyCode.LeftControl) then
                    wL_3 -= Vector3.new(0, 1, 0)
                end
                wK_2.AssemblyLinearVelocity = Vector3.zero
                if wL_3.Magnitude > 0 then
                    wK_2.CFrame = wK_2.CFrame + wL_3.Unit * FlySpeed.Value * i8
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local wU = o8()
            if wU then
                wU.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local wW = o8()
            if wW then
                wW.WalkSpeed = 16
            end
        end
    end)
    Toggles.AntiGameplayPause:OnChanged(function()
        iD(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                iD(true)
            end
        end
    end)
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in ipairs(n7:GetDescendants()) do
                pcall(iR, descendant)
            end
            connection = n7.DescendantAdded:Connect(function(jI)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(iR, jI)
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    Library:OnUnload(function()
        iD(false)
        if connection then
            connection:Disconnect()
        end
    end)
end
do
    pp()
    pt()
    task.spawn(worker3)
    task.spawn(worker2)
    task.spawn(worker)
    x7_3_5 = function()
        local connection
        local MenuGroup = oy.Settings:AddLeftGroupbox("Menu")
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        local j5 = 0
        local j6 = tick()
        local Label
        local function j8()
            local CurrentCamera = n7.CurrentCamera
            if not CurrentCamera then
                return
            end
            oT:CaptureController()
            oT:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            j5 += 1
            j6 = tick()
            if Label then
                pcall(function()
                    Label:SetText("AFK triggers: " .. j5)
                end)
            end
        end
        connection = n0.Idled:Connect(function()
            if pd("AntiAfk") then
                pcall(j8)
            end
        end)
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        MenuGroup:AddButton({
            Text = "Unload UI",
            Func = function()
                Library:Unload()
            end
        })
        task.spawn(function()
            while not Library.Unloaded do
                task.wait(2)
                local xd = pd("AntiAfk") and tick() - j6 >= 60
                if xd then
                    pcall(j8)
                end
            end
        end)
        Library:OnUnload(function()
            if connection then
                connection:Disconnect()
            end
            if getgenv then
                getgenv().__TempoStealALuckyEggLib = nil
            end
        end)
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("TempoHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(oy.Settings)
        ThemeManager:LoadDefault()
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/StealALuckyEgg")
        local kw = SaveManager:BuildConfigSection(oy.Settings)
        local function kx(ky, kz)
            local xh_1 = (ky == "Toggle" and Toggles or Options)[kz]
            local xg_2 = type(xh_1) == "table" and xh_1.Type == ky
            return xg_2 and xh_1 or nil
        end
        local function kG(kH, kI)
            local Type = kI.Type
            if Type == "Toggle" then
                return { idx = kH, type = "Toggle", value = kI.Value == true }
            elseif Type == "Slider" then
                return { idx = kH, type = "Slider", value = tostring(kI.Value) }
            elseif Type == "Dropdown" then
                return { idx = kH, type = "Dropdown", multi = kI.Multi == true, value = kI.Value }
            elseif Type == "Input" then
                local xl = kI.Value or ""
                return { idx = kH, type = "Input", text = tostring(xl) }
            elseif Type == "ColorPicker" then
                return { idx = kH, type = "ColorPicker", value = kI.Value:ToHex(), transparency = kI.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = kH,
                    type = "KeyPicker",
                    mode = kI.Mode,
                    key = kI.Value,
                    modifiers = kI.Modifiers,
                    toggled = kI.Toggled
                }
            else
                return nil
            end
        end
        local function kK()
            local xr = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local xs = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if xs then
                        local xs_1 = kG(k, v)
                        if xs_1 then
                            xr[#xr + 1] = xs_1
                        end
                    end
                end
            end
            table.sort(xr, function(kU, kV)
                if kU.type ~= kV.type then
                    return kU.type < kV.type
                end
                return kU.idx < kV.idx
            end)
            return { objects = xr }
        end
        local function kW(kX)
            local xL
            xL = nil
            local xM = type(kX) ~= "table" or type(kX.idx) ~= "string" or type(kX.type) ~= "string" or SaveManager.Ignore[kX.idx]
            if xM then
                return false
            end
            xL = kx(kX.type, kX.idx)
            if not xL then
                return false
            end
            local xM_1 = pcall(function()
                if kX.type == "Input" then
                    if type(kX.text) ~= "string" then
                        return
                    end
                    xL:SetValue(kX.text)
                elseif kX.type == "ColorPicker" then
                    xL:SetValueRGB(Color3.fromHex(kX.value), kX.transparency)
                elseif kX.type == "KeyPicker" then
                    xL:SetValue({ kX.key, kX.mode, kX.modifiers })
                    if kX.mode == "Toggle" and kX.toggled ~= nil then
                        xL.Toggled = kX.toggled
                        xL:Update()
                    end
                else
                    xL:SetValue(kX.value)
                end
            end)
            return xM_1
        end
        kw:AddDivider()
        kw:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        kw:AddButton({
            Text = "Export Config to Clipboard",
            Func = function()
                local xP_1
                local xO_1
                xO_1, xP_1 = pcall(oO.JSONEncode, oO, kK())
                if not xO_1 then
                    Library:Notify("Failed to encode the config")
                    return
                end
                local xO_2 = setclipboard or toclipboard
                local xO_3 = type(xO_2) ~= "function" or not pcall(xO_2, xP_1)
                if xO_3 then
                    Library:Notify("Your executor does not support copying to the clipboard")
                    return
                end
                Library:Notify("Config copied to clipboard", 6)
            end
        })
        kw:AddButton({
            Text = "Import Config from Clipboard Text",
            Func = function()
                local xU_1
                local xS = Options.SaveManager_ImportSource.Value or ""
                local xS_1
                local xT = tostring(xS):match("^%s*(.-)%s*$")
                if xT == "" then
                    Library:Notify("Paste an exported config into the box first")
                    return
                end
                xS_1, xU_1 = pcall(oO.JSONDecode, oO, xT)
                local xT_1 = not xS_1 or type(xU_1) ~= "table" or type(xU_1.objects) ~= "table"
                if xT_1 then
                    Library:Notify("That is not a valid exported config")
                    return
                end
                local xS_2 = 0
                for i, v in ipairs(xU_1.objects) do
                    if kW(v) then
                        xS_2 += 1
                    end
                end
                if xS_2 == 0 then
                    Library:Notify("No settings in that config matched this script")
                    return
                end
                Options.SaveManager_ImportSource:SetValue("")
                local xU_2 = xS_2 == 1 and "" or "s"
                Library:Notify(("Imported %d setting%s"):format(xS_2, xU_2), 6)
            end
        })
        SaveManager:LoadAutoloadConfig()
    end
end
x7_3_5()
end)(...)

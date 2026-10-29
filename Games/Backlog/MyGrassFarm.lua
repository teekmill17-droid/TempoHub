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
getgenv().TempoHoodSubtitle = "MY GRASS FARM"
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
local ow
local Toggles
local n9
local oz
local oV
local pd
local oY
local FloorConfig
local o0
local oF
local oI
local o3
local om
local oL
local PlotLocator
local WorkerConfig
local pf
local ob
local oB
local oe
local ExpansionConfig
local oE
local UpgradeConfig
local oH
local ol
local oK
local o5
local op
local Options
local o8
local ou
local RarityConfig
local n4
local ox
local pe
local oT
local EconomyConfig
local oW
local ph
local og
local oG
local DataController
local MutationConfig
local oM
local oP
local n6
local function fn28()
    local Character = oe.Character
    local q6 = Character and Character:FindFirstChildOfClass("Humanoid")
    return q6
end
local function fn38(co)
    local rs = co == ""
    local rt = type(co) ~= "string" or rs
    if rt then
        return 0
    end
    local rs_1 = WorkerConfig.Workers[co]
    local rt_1 = rs_1 and tonumber(rs_1.mult)
    return rt_1 or 0
end
local function fn60(bo, bp)
    local qF = Options[bo]
    local qG = qF and qF.Value
    local qG_1 = qG ~= ""
    local qH = type(qG) == "string" and qG_1
    if qH then
        return qG
    end
    return bp
end
local function fn97()
    local s4_1
    local s3 = os.clock() - oK.workerStockAt < 2 and type(oK.workerStock) == "table"
    local s3_1
    if s3 then
        return oK.workerStock
    end
    s3_1, s4_1 = pcall(function()
        return oB.GetWorkerStock:InvokeServer()
    end)
    local s5 = s3_1 and type(s4_1) == "table"
    if s5 then
        oK.workerStock = s4_1
        oK.workerStockAt = os.clock()
        return s4_1
    end
    return oK.workerStock
end
local function fn170(dW)
    local sl_1
    local sk_1
    if os.clock() - oK.lastUpgradeAt < 0.35 then
        return false
    end
    local sh = o0("UpgradeList")
    if not pe(sh) then
        return false
    end
    local si = tonumber(dW.Money) or 0
    sl_1, sk_1 = nil, nil
    for k, v in ox do
        if sh[v.label] then
            local si_1 = oV(v, dW)
            local sm = type(si_1) == "number" and si_1 <= si
            if sm then
                if sk_1 == nil or si_1 < sk_1 then
                    sl_1 = v
                    sk_1 = si_1
                end
            end
        end
    end
    if not sl_1 then
        return false
    elseif oF(sl_1) then
        oK.lastUpgradeAt = os.clock()
        return true
    else
        return false
    end
end
local function fn214(gR)
    local DiscordGroup = gR:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = oI })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = oI })
end
local function fn219(ch)
    local rj = ch and ch:FindFirstChild("Lever")
    if not rj then
        return nil, nil
    end
    for i, descendant in rj:GetDescendants() do
        local rj_1 = descendant:IsA("ProximityPrompt") and descendant.Name == "RollPrompt"
        if rj_1 then
            return descendant, descendant.Parent
        end
    end
    return nil, rj:FindFirstChildWhichIsA("BasePart", true)
end
local function fn221(bv)
    local qJ = Options[bv]
    local qK = qJ and qJ.Value
    if typeof(qK) ~= "table" then
        return {}
    end
    local qK_1 = {}
    for k, v in qK do
        if v == true then
            qK_1[k] = true
        else
            local qJ_2 = typeof(k) == "number" and typeof(v) == "string"
            if qJ_2 then
                qK_1[v] = true
            end
        end
    end
    return qK_1
end
local function fn327()
    local Character = oe.Character
    local q3 = Character and Character:FindFirstChild("HumanoidRootPart")
    return q3
end
local function fn350(fB)
    for k, v in RarityConfig.Order do
        if v == fB then
            return k
        end
    end
    return 0
end
local function fn361(b1)
    if not b1 then
        return false
    elseif fireproximityprompt then
        pcall(fireproximityprompt, b1)
        return true
    else
        return false
    end
end
local function fn365(ec, ed)
    local su = tonumber(ec.Carrying) or 0
    local su_2
    local sv_2
    if su > 0 then
        return false
    end
    local su_1 = tonumber(ec.Pile) or 0
    if su_1 < 1 then
        return false
    elseif os.clock() - oK.lastHayAt < 0.4 then
        return false
    else
        sv_2, su_2 = oP(ed, "HayHolder")
        pf(su_2)
        pcall(function()
            oB.CarryGrass:FireServer()
        end)
        n9(sv_2)
        oK.lastHayAt = os.clock()
        return true
    end
end
local function fn378(cx, cy)
    if cx.kind == "upgrade" then
        local rC_1 = cy.Upgrades and cy.Upgrades[cx.id] or 0
        if UpgradeConfig.IsMaxed(cx.id, rC_1) then
            return nil
        end
        return UpgradeConfig.Cost(cx.id, rC_1), rC_1
    elseif cx.kind == "processor" then
        local rC_2 = cy.Upgrades and cy.Upgrades.ProcessorShop or 0
        if rC_2 >= EconomyConfig.ProcessorShop.MaxLevel then
            return nil
        end
        return EconomyConfig.ProcessorShopCost(rC_2), rC_2
    elseif cx.kind == "stand" then
        local rB_5 = ph(cy.Stands)
        local TotalStands = FloorConfig.TotalStands
        local rD = cy.FloorsUnlocked or 1
        local rE = TotalStands(rD)
        if rB_5 >= rE then
            return nil
        end
        return WorkerConfig.StandCost(rB_5), rB_5
    else
        return nil
    end
end
local function fn433(eJ)
    local sX = if os.clock() - oK.lastExpandAt < 1 then 1 else 0
    if sX == 1 then
        return false
    end
    local s_ = if ExpansionConfig.IsExpanded(eJ) then 1 else 0
    if s_ == 1 then
        return false
    end
    local sR = tonumber(eJ.Money) or 0
    local sR_2
    local sS_1
    local sR_1 = tonumber(ExpansionConfig.Cost) or 0
    if sR < sR_1 then
        return false
    end
    sR_2, sS_1 = pcall(function()
        return oB.BuyExpansion:InvokeServer()
    end)
    oK.lastExpandAt = os.clock()
    local sT_1 = sR_2 and type(sS_1) == "table" and sS_1.ok == true
    return sT_1
end
local function fn456(en, eo)
    local sx = tonumber(en.Carrying) or 0
    local sx_1
    local sy_1
    if sx <= 0 then
        return false
    end
    local sC = if os.clock() - oK.lastDepositAt < 0.4 then 1 else 0
    if sC == 1 then
        return false
    end
    sy_1, sx_1 = oP(eo, "GrassProcessor")
    pf(sx_1)
    pcall(function()
        oB.DepositGrass:FireServer()
    end)
    n9(sy_1)
    oK.lastDepositAt = os.clock()
    return true
end
local function fn516(eG, eH)
    if type(eG.Tools) ~= "table" then
        return nil
    end
    local sP = eG.Tools[eH] or eG.Tools[tonumber(eH)] or eG.Tools[tostring(eH)]
    return sP
end
local function fn529()
    o3(oH, "Copied Discord invite to clipboard")
end
local function fn569(df, dg)
    local rW_1
    local rV = oK.spinning and os.clock() - oK.lastRollAt > 8
    local rV_3
    if rV then
        oK.spinning = false
    end
    if oK.spinning then
        return false
    end
    local rV_1 = o8("RollDelay", 3)
    if os.clock() - oK.lastRollAt < rV_1 then
        return false
    end
    local rV_2 = ol("AutoBuyScythe") and type(oK.offers) == "table"
    if rV_2 then
        return false
    end
    rW_1, rV_3 = pd(dg)
    pf(rV_3)
    pcall(function()
        oB.PullLever:FireServer()
    end)
    n9(rW_1)
    oK.spinning = true
    oK.lastRollAt = os.clock()
    return true
end
local function fn573(b8, b9)
    local rg = b8 and b8:FindFirstChild(b9)
    local rh = rg
    if rg then
        rg = rh:FindFirstChild("StationAnchor")
    end
    local rh_1 = rg
    if rg then
        rg = rh_1:FindFirstChild("StationPrompt")
    end
    return rg, rh_1
end
local function onOnClientEvent(gG)
    if gG == oe then
        oK.spinning = true
        oK.offers = nil
    end
end
local function fn612(cM)
    if cM.kind == "upgrade" then
        oB.BuyUpgrade:FireServer(cM.id)
        return true
    elseif cM.kind == "processor" then
        oB.BuyProcessorUpgrade:InvokeServer()
        return true
    elseif cM.kind == "stand" then
        oB.BuyStand:FireServer()
        return true
    else
        return false
    end
end
local function fn625(gv, gw)
    if os.clock() - oK.lastRewardAt < 0.45 then
        return false
    end
    local ue = tonumber(gv.PadMoney) or 0
    if ue > 0.05 then
        oY(gw)
        oK.lastRewardAt = os.clock()
        return true
    end
    local PendingOffline = gv.PendingOffline
    local uf_1 = type(PendingOffline) == "table"
    if uf_1 then
        local ug = tonumber(PendingOffline.Grass) or 0
        local uh = ug > 0
        if not uh then
            local ug_1 = tonumber(PendingOffline.Seconds) or 0
            uh = ug_1 > 0
        end
        uf_1 = uh
    end
    if uf_1 then
        pcall(function()
            oB.ClaimOfflineEarnings:FireServer()
        end)
        oK.lastRewardAt = os.clock()
        return true
    end
    return false
end
local function fn633(cP, cQ)
    local rH = cP and type(cQ) == "string"
    if not rH then
        return "Normal"
    end
    local Display = cP:FindFirstChild("Display")
    local rI = Display and Display:FindFirstChild(cQ)
    if not rI then
        return "Normal"
    end
    local attr = rI:GetAttribute("Mutation")
    local rJ = type(attr) == "string" and MutationConfig.Mutations[attr]
    if rJ then
        return attr
    end
    local MutationVFX = rI:FindFirstChild("MutationVFX")
    if MutationVFX then
        for i, descendant in MutationVFX:GetDescendants() do
            if MutationConfig.Mutations[descendant.Name] then
                return descendant.Name
            end
        end
    end
    return "Normal"
end
local function fn638()
    local q__1
    local qZ_1
    qZ_1, q__1 = pcall(function()
        return DataController.GetAll()
    end)
    local q0 = qZ_1 and type(q__1) == "table"
    if q0 then
        return q__1
    end
    return nil
end
local function fn642(fF, fG)
    local tB = ow.lookupTool(fF, fG.ToolId)
    local tC = ow.toolRate(tB)
    local tB_1 = fF.Workers
    if tB_1 then
        local tD_1 = fF.Workers[fG.WorkerId]
        local tH = if tD_1 then 1 else 0
        local tF = 861 * tH + 347 * (1 - tH)
        local tG = 28 * tH + 3683 * (1 - tH)
        if not ((tF * 378 + tG * 57 + tF * tG) % 16777213 == 351162) then
            tD_1 = fF.Workers[tonumber(fG.WorkerId)]
        end
        local tH_1 = if tD_1 then 1 else 0
        local tF_1 = 777 * tH_1 + 3368 * (1 - tH_1)
        local tG_1 = 2233 * tH_1 + 2975 * (1 - tH_1)
        if not ((tF_1 * 613 + tG_1 * 51 + tF_1 * tG_1) % 16777213 == 2325225) then
            tD_1 = fF.Workers[tostring(fG.WorkerId)]
        end
        tB_1 = tD_1
    end
    local tD_2 = tB_1
    local tB_2 = type(tD_2) == "table" and oz(tD_2.Type)
    local tB_3 = tB_2 or 1
    if tB_3 <= 0 then
        tB_3 = 1
    end
    return tC * tB_3
end
local function fn661(c1, c2, c3, c4)
    local rR = RarityConfig.DisplayName(c1)
    local rS = MutationConfig.DisplayName(c2)
    local rT = not pe(c3) or c3[rR] == true
    local rT_1 = not pe(c4) or c4[rS] == true
    return rT and rT_1
end
local function worker()
    while om and not om.Unloaded do
        og()
        task.wait(1)
    end
end
local function fn726()
    return oL
end
local function fn752(a0, a1, a2)
    return string.format("<b>%s</b> %s %s", a0, oE("-", "#5a6070"), oE(a1, a2))
end
local function fn787(b3)
    local rd = ob()
    if not (rd and b3) then
        return false
    elseif b3:IsA("Model") then
        local pivot = b3:GetPivot()
        rd.CFrame = pivot + Vector3.new(0, 4, 0)
        return true
    elseif b3:IsA("BasePart") then
        local CFrame = b3.CFrame
        rd.CFrame = CFrame + Vector3.new(0, 4, 0)
        return true
    else
        return false
    end
end
local function fn789()
    local q9_1
    local q8_1
    q8_1, q9_1 = pcall(function()
        return PlotLocator.LocalPlot()
    end)
    if q8_1 and q9_1 then
        return q9_1
    end
    return nil
end
local function fn790(bh, bi)
    local qz = Options[bh]
    local qz_1 = qz and qz.Value
    if type(qz_1) == "number" then
        return qz_1
    end
    return bi
end
local function fn796(e_)
    local s7 = 0
    if type(e_.Workers) ~= "table" then
        return s7
    end
    for k in e_.Workers do
        s7 += 1
    end
    return s7
end
local function onOnClientEvent2(gJ, gK)
    if gJ == oe then
        oK.spinning = false
        local un = type(gK) == "table" and gK
        local uo = un or nil
        oK.offers = uo
        oK.lastRollAt = os.clock()
    end
end
local function fn825(ct)
    local rv = 0
    if type(ct) ~= "table" then
        return rv
    end
    for k in ct do
        rv += 1
    end
    return rv
end
local function worker2()
    while not om.Unloaded do
        local wd = oT()
        local we = oM()
        local wf = false
        if wd and we then
            local wg_1 = ol("AutoPickupHay") and ou(wd, we)
            if wg_1 then
                wf = true
            end
            local wg_2 = ol("AutoDepositHay") and op(wd, we)
            if wg_2 then
                wf = true
            end
            local wg_3 = ol("AutoBuyScythe") and o5(wd, we)
            if wg_3 then
                wf = true
            end
            local wg_4 = ol("AutoRoll") and n6(wd, we)
            if wg_4 then
                wf = true
            end
            local wg_5 = ol("AutoBuyUpgrades") and oW(wd)
            if wg_5 then
                wf = true
            end
            local wg_6 = ol("AutoExpand") and ow.expand(wd)
            if wg_6 then
                wf = true
            end
            local wg_7 = ol("AutoBuyWorkers") and ow.buyWorkers(wd)
            if wg_7 then
                wf = true
            end
            local wg_8 = ol("AutoEquipBest") and ow.equipBest()
            if wg_8 then
                wf = true
            end
            local wg_9 = ol("AutoUpgradePlaced") and ow.upgradePlaced(wd)
            if wg_9 then
                wf = true
            end
            local wg_10 = ol("AutoCollectMoney") and oG(wd, we)
            if wg_10 then
                wf = true
            end
        end
        local wait = task.wait
        local wf_1 = wf and 0.25 or 0.55
        wait(wf_1)
    end
end
local function fn847(bc)
    local qw = Toggles[bc]
    return qw ~= nil and qw.Value == true
end
local function onOnClientEvent3()
    oK.lastBuyAt = os.clock()
end
local function fn860()
    local ts = o8("EquipDelay", 5)
    if os.clock() - oK.lastEquipAt < ts then
        return false
    end
    pcall(function()
        oB.EquipBest:InvokeServer()
    end)
    oK.lastEquipAt = os.clock()
    return true
end
local function fn874(a5, a6)
    if setclipboard then
        setclipboard(a5)
    elseif toclipboard then
        toclipboard(a5)
    end
    om:Notify(a6)
end
local function fn882(aY, aZ)
    return string.format('<font color="%s">%s</font>', aZ, aY)
end
local function fn898(bF)
    for k, v in bF do
        if v == true then
            return true
        end
    end
    return false
end
n4 = nil
WorkerConfig = nil
n6 = nil
n9 = nil
EconomyConfig = nil
ob = nil
oe = nil
og = nil
UpgradeConfig = nil
ol = nil
om = nil
op = nil
PlotLocator = nil
ou = nil
ow = nil
ox = nil
oz = nil
oB = nil
oE = nil
oF = nil
oG = nil
oH = nil
oI = nil
DataController = nil
oK = nil
oL = nil
oM = nil
Options = nil
oP = nil
Toggles = nil
oT = nil
local n2, n3, n7, n8, oc, od, of, oi, oj, oo, ot, ov, TeleportService, oA, oC, oD, oO, Roller, HttpService
oV = nil
oW = nil
oY = nil
ExpansionConfig = nil
o0 = nil
o3 = nil
MutationConfig = nil
o5 = nil
o8 = nil
local pa
RarityConfig = nil
pd = nil
pe = nil
pf = nil
FloorConfig = nil
ph = nil
local ToolConfig, oX, oZ, UserInputService, o2, o6, o7, o9, pc, pv
local pj_1
local po_3
local pm_7
local pk_3
n2, pj_1, o6, UserInputService, oX, HttpService, oL, oD, TeleportService, oo, oe, n8, n4 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local pi = 10
repeat
    local pk_1 = (pi * 5 + 6) % 8 + 1
    if pk_1 <= 4 then
        if pk_1 <= 2 then
            if pk_1 <= 1 then
                local pl_1 = (vector.create((pi * 6 + 2) % 11 + 1, (pi * 2 + 2) % 13 + 1, (pi * 12 + 17) % 17 + 1))
                local pm_1 = (vector.create((pi * 6 + 3) % 11 + 1, (pi * 6 + 3) % 13 + 1, (pi * 1 + 14) % 17 + 1))
                local pn_1 = (vector.create((pi * 2 + 2) % 5 + 1, (pi * 3 + 4) % 7 + 1, (pi * 3 + 2) % 9 + 1))
                if math.abs((vector.angle(pl_1, pm_1, pn_1))) - math.abs((vector.angle(pm_1, pl_1, pn_1))) == 4 then
                    n8 = game:GetService("Players")
                else
                    n2 = game:GetService("Players")
                end
                pi = (pi + 21) % 32
            else
                if (pi * 2 + 6) * 4 % 3 == ((pi * 2 + 6) * 4 + 7) % 3 then
                    o6 = game:GetService("ReplicatedStorage")
                    pj_1 = game:GetService("RunService")
                else
                    pj_1 = game:GetService("ReplicatedStorage")
                    o6 = game:GetService("RunService")
                end
                pi = (pi + 21) % 32
            end
        elseif pk_1 <= 3 then
            local pl_2 = (vector.create((pi * 5 + 7) % 11 + 1, (pi * 4 + 1) % 13 + 1, (pi * 8 + 12) % 17 + 1))
            local pm_2 = (vector.create((pi * 3 + 5) % 11 + 1, (pi * 9 + 12) % 13 + 1, (pi * 1 + 16) % 17 + 1))
            local pn_2 = (vector.create((pi * 4 + 7) % 11 + 1, (pi * 7 + 7) % 13 + 1, (pi * 1 + 15) % 17 + 1))
            local po_1 = (vector.create((pi * 6 + 7) % 11 + 1, (pi * 6 + 7) % 13 + 1, (pi * 7 + 12) % 17 + 1))
            if vector.dot(vector.cross(pl_2, pm_2), (vector.cross(pn_2, po_1))) == vector.dot(pl_2, pn_2) * vector.dot(pm_2, po_1) - vector.dot(pl_2, po_1) * vector.dot(pm_2, pn_2) then
                UserInputService = game:GetService("UserInputService")
            else
                n8 = game:GetService("UserInputService")
            end
            pi = (pi + 21) % 32
        else
            local pl_3 = {
                "cmmdmx",
                "ogjv",
                "ponskwvn",
                "skxrzjexljq",
                "mgvwqcgvwurf",
                "wlkqygzttty",
                "fndun",
                "hnjrcuiqaq",
                "omwhxvsztrlu",
                "cygedpxdz"
            }
            if pl_3[(pi * 20 + 33) % 10 + 1] <= pl_3[(pi * 20 + 33) % 10 + 1] then
                oX = game:GetService("VirtualUser")
            else
                oD = game:GetService("VirtualUser")
            end
            pi = (pi + 21) % 32
        end
    elseif pk_1 <= 6 then
        if pk_1 <= 5 then
            if pi * 92381525 + 13 + 2 <= pi * 92381525 + 13 + 2 + 1 then
                HttpService = game:GetService("HttpService")
            else
                n4 = game:GetService("HttpService")
            end
            pi = (pi + 29) % 32
        else
            local pl_4 = { "npfqgveth", "xrkiu", "squivvr", "azxaep", "fcezmnjr", "rklhbpd", "wjq", "tcqtkzapi" }
            local xJ = pi
            local pm_3 = pl_4[xJ % 8 + 1]
            if pm_3:len() >= pm_3:gsub("(.)", "%1%1", xJ % 3 % 2 + 1):len() then
                oD = game:GetService("CoreGui")
                oL = game:GetService("GuiService")
            else
                oL = game:GetService("CoreGui")
                oD = game:GetService("GuiService")
            end
            pi = (pi + 21) % 32
        end
    elseif pk_1 <= 7 then
        local pk_2 = (vector.create((pi * 5 + 7) % 11 + 1, (pi * 6 + 7) % 13 + 1, (pi * 13 + 12) % 17 + 1))
        local pl_5 = (vector.create((pi * 3 + 2) % 11 + 1, (pi * 7 + 11) % 13 + 1, (pi * 9 + 15) % 17 + 1))
        local yc = vector.dot(pk_2, pl_5)
        if yc * yc <= vector.dot(pk_2, pk_2) * vector.dot(pl_5, pl_5) then
            TeleportService = game:GetService("TeleportService")
            oo = game:GetService("Workspace")
            oe = n2.LocalPlayer
            n8 = oe:WaitForChild("PlayerGui")
        else
            oe = game:GetService("TeleportService")
            n8 = game:GetService("Workspace")
            n2 = TeleportService.LocalPlayer
            oo = n2:WaitForChild("PlayerGui")
        end
        pi = (pi + 21) % 32
    else
        if pi * 120947663 + 2 + 1 <= pi * 120947663 + 2 + 1 + 6 then
            n4 = fn726
        else
            oX = fn726
        end
        pi = (pi + 5) % 32
    end
until (pi * 3 + 9) % 32 == 7
if getgenv then
    pa, pk_3 = nil, nil
    pi = 15
    repeat
        if (pi * 1 + 0) % 2 + 1 <= 1 then
            local pl_7 = {
                "wprmc",
                "hrdlw",
                "oszmbi",
                "jltchfp",
                "iviuufn",
                "ygtz",
                "fjcmaamakzf",
                "ehnrcbi",
                "bsxzqrlje",
                "wvjbildn",
                "tdirbhjxvb",
                "ncnusauskbu"
            }
            local yC = pi
            local pm_4 = pl_7[yC % 12 + 1]
            if pm_4:len() >= pm_4:gsub("(.)", "%1%1", yC % 3 % 2 + 1):len() then
                pa = pk_3
            else
                pk_3 = pa
            end
            pi = (pi + 7) % 16
        else
            local xZ = bit32.rrotate(bit32.bxor(bit32.lrotate(pi, 27), string.byte(tostring(pk_3))), 23)
            if bit32.bxor(bit32.lrotate(bit32.bxor(xZ, 162610649), 28), 2426082269) == bit32.lrotate(xZ, 28) then
                getgenv().gethui = n4
                pa = getgenv().__TempoMyGrassFarmLib
            else
                getgenv().gethui = pa
                n4 = getgenv().__TempoMyGrassFarmLib
            end
            pi = (pi + 1) % 16
        end
    until (pi * 9 + 7) % 16 == 6
    if pk_3 then
        pk_3 = pa.Unload
    end
    if pk_3 then
        pcall(function()
            pa:Unload()
        end)
    end
end
pcall(function()
    gethui = n4
end)
if setthreadidentity then
    setthreadidentity(8)
end
oO, oH, oA, ov, oj, oc, n7, n3, pc, PlotLocator, UpgradeConfig, EconomyConfig, WorkerConfig, FloorConfig, RarityConfig, MutationConfig, ExpansionConfig, ToolConfig, Roller, DataController, oB, ox = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if (not WorkerConfig and not WorkerConfig or (ToolConfig or ToolConfig) or (not ToolConfig or not ToolConfig) and (WorkerConfig and not WorkerConfig)) and not (not WorkerConfig and not WorkerConfig or (ToolConfig or ToolConfig) or (not ToolConfig or not ToolConfig) and (WorkerConfig and not WorkerConfig)) then
    oA = "My Grass Farm"
    oO = "https://discord.gg/K7Qxnxkk46"
    oH = "https://discord.gg/K7Qxnxkk46"
else
    oO = "My Grass Farm"
    oH = "https://discord.gg/K7Qxnxkk46"
    oA = "https://discord.gg/K7Qxnxkk46"
end
if (not Roller or not UpgradeConfig) and (Roller and DataController) and (not UpgradeConfig and not UpgradeConfig or (not Roller or not DataController)) and not ((not Roller or not UpgradeConfig) and (Roller and DataController) and (not UpgradeConfig and not UpgradeConfig or (not Roller or not DataController))) then
    ox = "https://tempohub.shop"
else
    ov = "https://tempohub.shop"
end
oj = "#7fd47f"
oc = "#6ec1ff"
n7 = "#e8a34d"
n3 = "#8b93a3"
pc = "#e05a5a"
local Modules = pj_1:WaitForChild("Modules")
local Configs = Modules:WaitForChild("Configs")
local Remotes = pj_1:WaitForChild("Remotes")
PlotLocator = require(Modules:WaitForChild("PlotLocator"))
UpgradeConfig = require(Configs:WaitForChild("UpgradeConfig"))
EconomyConfig = require(Configs:WaitForChild("EconomyConfig"))
WorkerConfig = require(Configs:WaitForChild("WorkerConfig"))
FloorConfig = require(Configs:WaitForChild("FloorConfig"))
RarityConfig = require(Configs:WaitForChild("RarityConfig"))
MutationConfig = require(Configs:WaitForChild("MutationConfig"))
ExpansionConfig = require(Configs:WaitForChild("ExpansionConfig"))
ToolConfig = require(Configs:WaitForChild("ToolConfig"))
Roller = require(Modules:WaitForChild("Roller"))
DataController = require(oe:WaitForChild("PlayerScripts"):WaitForChild("Controllers"):WaitForChild("DataController"))
oB = {
    PullLever = Remotes:WaitForChild("PullLever"),
    BuyTool = Remotes:WaitForChild("BuyTool"),
    BuyUpgrade = Remotes:WaitForChild("BuyUpgrade"),
    BuyStand = Remotes:WaitForChild("BuyStand"),
    BuyProcessorUpgrade = Remotes:WaitForChild("BuyProcessorUpgrade"),
    CarryGrass = Remotes:WaitForChild("CarryGrass"),
    DepositGrass = Remotes:WaitForChild("DepositGrass"),
    CollectMoney = Remotes:WaitForChild("CollectMoney"),
    UpgradeTool = Remotes:WaitForChild("UpgradeTool"),
    EquipBest = Remotes:WaitForChild("EquipBest"),
    BuyExpansion = Remotes:WaitForChild("BuyExpansion"),
    BuyWorker = Remotes:WaitForChild("BuyWorker"),
    GetWorkerStock = Remotes:WaitForChild("GetWorkerStock"),
    ClaimOfflineEarnings = Remotes:WaitForChild("ClaimOfflineEarnings"),
    ShuffleBegan = Remotes:WaitForChild("ShuffleBegan"),
    ShuffleRevealed = Remotes:WaitForChild("ShuffleRevealed"),
    ToolBought = Remotes:WaitForChild("ToolBought")
}
if (RarityConfig and pc or (not MutationConfig or RarityConfig)) and (RarityConfig or not MutationConfig or (MutationConfig or pc)) or not ((RarityConfig and pc or (not MutationConfig or RarityConfig)) and (RarityConfig or not MutationConfig or (MutationConfig or pc))) then
    ox = {
        { id = "CutSpeed", label = "Cut Speed", kind = "upgrade" },
        { id = "Rolls", label = "Extra Rolls", kind = "upgrade" },
        { id = "PureLuck", label = "Pure Luck", kind = "upgrade" },
        { id = "MutationLuck", label = "Mutation Luck", kind = "upgrade" },
        { id = "SiloRate", label = "Processor Speed", kind = "upgrade" },
        { id = "ProcessorShop", label = "Processor Shop", kind = "processor" },
        { id = "BuyStand", label = "Worker Stand", kind = "stand" }
    }
end
local pt = {}
local pr = {}
local ps = {}
for k, v in ox do
    pt[#pt + 1] = v.label
    pr[v.label] = v
    ps[v.label] = true
end
pi = {}
for k, v in RarityConfig.RollOrder do
    pi[#pi + 1] = RarityConfig.DisplayName(v)
end
for k, v in RarityConfig.SpecialOrder do
    pi[#pi + 1] = RarityConfig.DisplayName(v)
end
local pj_2 = {}
for k, v in RarityConfig.Order do
    pj_2[RarityConfig.DisplayName(v)] = v
end
local pk_5 = {}
local pj_3 = {}
for k, v in MutationConfig.Order do
    local pl_9 = MutationConfig.DisplayName(v)
    pj_3[#pj_3 + 1] = pl_9
    pk_5[pl_9] = v
end
local pl_10 = {}
for k, v in WorkerConfig.Order do
    local pk_6 = v ~= "Noob" and not WorkerConfig.IsVaulted(v) and not WorkerConfig.RobuxOnly(v)
    if pk_6 then
        pl_10[#pl_10 + 1] = WorkerConfig.DisplayName(v)
    end
end
oK, oC, om = nil, nil, nil
local pk_7 = 5
repeat
    local xV = bit32.rrotate(bit32.bxor(bit32.lrotate(pk_7, 21), string.byte(tostring(oK))), 23)
    if bit32.bxor(bit32.lrotate(bit32.bxor(xV, 1148885515), 8), 2056915780) == bit32.lrotate(xV, 8) then
        oK = {
            spinning = false,
            offers = nil,
            lastRollAt = 0,
            lastBuyAt = 0,
            lastUpgradeAt = 0,
            lastHayAt = 0,
            lastDepositAt = 0,
            lastEquipAt = 0,
            lastUpgradeToolAt = 0,
            lastExpandAt = 0,
            lastBuyWorkerAt = 0,
            lastRewardAt = 0,
            workerStock = nil,
            workerStockAt = 0
        }
        oC = {}
        pm_7 = ""
        om = getgenv().Library
    else
        om = {
            workerStockAt = 0,
            lastBuyWorkerAt = 0,
            workerStock = nil,
            lastUpgradeToolAt = 0,
            lastHayAt = 0,
            lastBuyAt = 0,
            spinning = false,
            lastRollAt = 0,
            lastEquipAt = 0,
            offers = nil,
            lastDepositAt = 0,
            lastRewardAt = 0,
            lastUpgradeAt = 0,
            lastExpandAt = 0
        }
        pm_7 = {}
        oK = ""
        oC = getgenv().Library
    end
    pk_7 = (pk_7 + 3) % 8
until (pk_7 * 5 + 5) % 8 == 5
if getgenv then
    getgenv().__TempoMyGrassFarmLib = om
end
o2, oZ, Toggles, Options, ow, o9, og, oE, of, o3, oI, ol, o8, ot, o0, pe, oT, ob, o7, oM, n9, pf, oP, pd, oz, ph, oV, oF, oi, od, n6, o5, oW, ou, op, oY, oG = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if (not ob or not pf) and (o0 and not pf) and ((og or false) and (not ob and o0)) and ((false or o0 or false and o0) and (pf and not pf or (not o0 or o0))) and (pf and not ob and (pf or not pf) and (pf and not o0 and (o0 and not ob)) or (og and not ob and (not ob and pf) or (o0 or pf) and (o0 or not pf))) or not ((not ob or not pf) and (o0 and not pf) and ((og or false) and (not ob and o0)) and ((false or o0 or false and o0) and (pf and not pf or (not o0 or o0))) and (pf and not ob and (pf or not pf) and (pf and not o0 and (o0 and not ob)) or (og and not ob and (not ob and pf) or (o0 or pf) and (o0 or not pf)))) then
    og = function()
        local function qj(aD)
            local qh = not aD or not aD:IsA("ScreenGui")
            if qh then
                return
            end
            aD.ResetOnSpawn = false
            aD.IgnoreGuiInset = true
            aD.DisplayOrder = math.max(aD.DisplayOrder, 1000)
            pcall(function()
                aD.ClipToDeviceSafeArea = false
            end)
            pcall(function()
                aD.ScreenInsets = Enum.ScreenInsets.None
            end)
            if aD.Parent ~= oL then
                aD.Parent = oL
            end
        end
        qj(om.ScreenGui)
        if om.ActiveLoading and om.ActiveLoading.ScreenGui then
            qj(om.ActiveLoading.ScreenGui)
        end
        for i, v in ipairs({ "Obsidian", "ObsidianLoading" }) do
            local qk_2 = oL:FindFirstChild(v) or n8:FindFirstChild(v)
            if qk_2 then
                qj(qk_2)
            end
        end
    end
    og()
    task.spawn(worker)
    o2 = getgenv().ThemeManager
else
    o2 = function()
        local function qj(aD)
            local qh = not aD or not aD:IsA("ScreenGui")
            if qh then
                return
            end
            aD.ResetOnSpawn = false
            aD.IgnoreGuiInset = true
            aD.DisplayOrder = math.max(aD.DisplayOrder, 1000)
            pcall(function()
                aD.ClipToDeviceSafeArea = false
            end)
            pcall(function()
                aD.ScreenInsets = Enum.ScreenInsets.None
            end)
            if aD.Parent ~= oL then
                aD.Parent = oL
            end
        end
        qj(om.ScreenGui)
        if om.ActiveLoading and om.ActiveLoading.ScreenGui then
            qj(om.ActiveLoading.ScreenGui)
        end
        for i, v in ipairs({ "Obsidian", "ObsidianLoading" }) do
            local qk_1 = oL:FindFirstChild(v) or n8:FindFirstChild(v)
            if qk_1 then
                qj(qk_1)
            end
        end
    end
    o2()
    task.spawn(worker)
    pm_7 = getgenv().ThemeManager
end
oZ = getgenv().SaveManager
Toggles = om.Toggles
Options = om.Options
oE = fn882
of = fn752
o3 = fn874
oI = fn529
ol = fn847
o8 = fn790
ot = fn60
o0 = fn221
pe = fn898
oT = fn638
ob = fn327
o7 = fn28
oM = fn789
n9 = fn361
pf = fn787
oP = fn573
pd = fn219
oz = fn38
ph = fn825
oV = fn378
oF = fn612
oi = fn633
od = fn661
n6 = fn569
o5 = function(dx, dy)
    local offers = oK.offers
    if type(offers) ~= "table" then
        return false
    end
    local sa = if os.clock() - oK.lastBuyAt < 0.2 then 1 else 0
    if sa == 1 then
        return false
    end
    local rZ = o0("BuyRarities")
    local r_ = o0("BuyMutations")
    local r0 = ol("SkipUnaffordable")
    local r1 = PlotLocator.OrderedToolHolders(dy)
    local r2 = tonumber(dx.Money) or 0
    local r3 = false
    local r4 = 0
    local r5 = r2
    for k, v in offers do
        local se = k
        if type(v) == "string" then
            local rY_1 = r1[se]
            local r2_1 = oi(rY_1, v)
            if od(v, r2_1, rZ, r_) then
                local rY_2 = Roller.ToolCost(v, r2_1)
                local r2_2 = type(rY_2) == "number" and rY_2 <= r5
                if r2_2 then
                    pcall(function()
                        oB.BuyTool:FireServer(se)
                    end)
                    r5 -= rY_2
                    r4 += 1
                    oK.lastBuyAt = os.clock()
                else
                    local r2_3 = not r0
                    local r6 = type(rY_2) == "number" and r2_3
                    if r6 then
                        r3 = true
                    end
                end
            end
        end
    end
    if r3 and r4 == 0 then
        return false
    end
    oK.offers = nil
    return r4 > 0
end
oW = fn170
ou = fn365
op = fn456
ow = {}
ow.toolRate = function(ez)
    local sJ_1
    local sI_1
    if type(ez) ~= "table" then
        return 0
    end
    sI_1, sJ_1 = pcall(function()
        local ToolCutRate = Roller.ToolCutRate
        local Rarity = ez.Rarity
        local sF = ez.Mutation or "Normal"
        local sG = ez.Level or 1
        return ToolCutRate(Rarity, sF, sG)
    end)
    local sK = sI_1 and type(sJ_1) == "number"
    if sK then
        return sJ_1
    end
    return 0
end
ow.lookupTool = fn516
ow.expand = fn433
ow.workerStock = fn97
ow.ownedWorkerCount = fn796
ow.buyWorkers = function(e2)
    local td
    if os.clock() - oK.lastBuyWorkerAt < 0.6 then
        return false
    end
    local te = tonumber(WorkerConfig.MaxOwnedWorkers) or 320
    local te_2
    local tf_2
    if ow.ownedWorkerCount(e2) >= te then
        return false
    end
    local te_1 = o0("WorkerList")
    local tf_1 = pe(te_1)
    local tg = ow.workerStock()
    if type(tg) ~= "table" then
        return false
    end
    local th = tonumber(e2.Money) or 0
    td = nil
    local th_1 = tg.items or tg
    for k, v in th_1 do
        local tg_2 = type(v) == "table" and type(v.type) == "string"
        if tg_2 then
            local tg_3 = tonumber(v.remaining) or tonumber(v.qty)
            local th_2 = tg_3 or 0
            local th_3 = tonumber(v.price)
            if type(th_3) ~= "number" then
                th_3 = WorkerConfig.Price(v.type)
            end
            local tj = WorkerConfig.DisplayName(v.type)
            local tk = not tf_1 or te_1[tj] == true
            local tk_1 = th_2 > 0 and tk and not WorkerConfig.RobuxOnly(v.type) and type(th_3) == "number" and th_3 > 0 and th_3 <= th
            if tk_1 then
                if not td or th_3 < td.price then
                    td = { typeName = v.type, price = th_3 }
                end
            end
        end
    end
    if not td then
        return false
    end
    te_2, tf_2 = pcall(function()
        return oB.BuyWorker:InvokeServer(td.typeName)
    end)
    oK.lastBuyWorkerAt = os.clock()
    oK.workerStockAt = 0
    local tg_6 = te_2 and type(tf_2) == "table" and tf_2.ok == true
    return tg_6
end
ow.equipBest = fn860
ow.rarityRank = fn350
ow.standEarnings = fn642
ow.upgradePlaced = function(fR)
    local tI
    if os.clock() - oK.lastUpgradeToolAt < 0.35 then
        return false
    end
    local Stands = fR.Stands
    if type(Stands) ~= "table" then
        return false
    end
    local tK = tonumber(fR.Money) or 0
    local tL = {}
    for k, v in Stands do
        if type(v) == "table" then
            local tJ_1 = v.WorkerId or ""
            local tK_1 = tostring(tJ_1)
            local ToolId = v.ToolId
            local tN = tK_1 ~= "" and ToolId ~= nil and tostring(ToolId) ~= ""
            if tN then
                local tK_2 = ow.lookupTool(fR, ToolId)
                if type(tK_2) == "table" then
                    local tN_1 = tonumber(tK_2.Level) or 1
                    if tN_1 < ToolConfig.MaxLevel then
                        local tN_2 = ToolConfig.UpgradeCost(tK_2.Rarity, tK_2.Mutation, tN_1)
                        local tO_1 = type(tN_2) == "number" and tN_2 <= tK
                        if tO_1 then
                            tL[#tL + 1] = { toolId = ToolId, earnings = ow.standEarnings(fR, v), rarity = ow.rarityRank(tK_2.Rarity) }
                        end
                    end
                end
            end
        end
    end
    if #tL == 0 then
        return false
    end
    local tJ_3 = ot("UpgradePriority", "Random")
    tI = tL[1]
    if tJ_3 == "Highest Earnings" then
        for k, v in tL do
            if v.earnings > tI.earnings then
                tI = v
            end
        end
    elseif tJ_3 == "Rarest" then
        for k, v in tL do
            if v.rarity > tI.rarity then
                tI = v
            else
                if v.rarity == tI.rarity and v.earnings > tI.earnings then
                    tI = v
                end
            end
        end
    else
        tI = tL[math.random(1, #tL)]
    end
    pcall(function()
        oB.UpgradeTool:FireServer(tI.toolId)
    end)
    oK.lastUpgradeToolAt = os.clock()
    return true
end
oY = function(gg)
    local t7 = gg and gg:FindFirstChild("Collectionpad")
    local t8 = t7
    if t7 then
        local t9 = t8:FindFirstChild("Touch") or t8:FindFirstChild("CollectionPart")
        t7 = t9
    end
    local t6 = t7
    local t5 = ob()
    if t6 then
        pf(t6)
    end
    pcall(function()
        oB.CollectMoney:FireServer()
    end)
    if firetouchinterest and t5 and t6 then
        pcall(function()
            firetouchinterest(t5, t6, 0)
            task.wait()
            firetouchinterest(t5, t6, 1)
        end)
    end
end
oG = fn625
oC[#oC + 1] = oB.ShuffleBegan.OnClientEvent:Connect(onOnClientEvent)
oC[#oC + 1] = oB.ShuffleRevealed.OnClientEvent:Connect(onOnClientEvent2)
oC[#oC + 1] = oB.ToolBought.OnClientEvent:Connect(onOnClientEvent3)
local Window = om:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = oH, Copyable = true }, "|", oO },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
o9 = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gavel"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in o9 do
    if k ~= "Info" then
        fn214(v)
    end
end
local FarmGroup = o9.Main:AddLeftGroupbox("Farm", "sprout")
FarmGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
FarmGroup:AddSlider("RollDelay", { Text = "Roll Delay", Default = 3, Min = 0.5, Max = 15, Rounding = 1 })
FarmGroup:AddToggle("AutoBuyScythe", { Text = "Auto Buy Scythe", Default = false })
FarmGroup:AddToggle("SkipUnaffordable", { Text = "Skip if Unaffordable", Default = true })
FarmGroup:AddDropdown("BuyRarities", { Text = "Rarities", Values = pi, Default = {}, Multi = true, Expandable = true, ExpandColumns = 2 })
FarmGroup:AddDropdown("BuyMutations", {
    Text = "Mutations",
    Values = pj_3,
    Default = {},
    Multi = true,
    Expandable = true,
    ExpandColumns = 2
})
FarmGroup:AddDivider("Hay")
FarmGroup:AddToggle("AutoPickupHay", { Text = "Auto Pickup Hay", Default = false })
FarmGroup:AddToggle("AutoDepositHay", { Text = "Auto Deposit Hay", Default = false })
local ShopGroup = o9.Main:AddLeftGroupbox("Shop", "store")
ShopGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
ShopGroup:AddDropdown("UpgradeList", { Text = "Upgrades", Values = pt, Default = ps, Multi = true, Expandable = true, ExpandColumns = 2 })
ShopGroup:AddToggle("AutoExpand", { Text = "Auto Expand Base", Default = false })
ShopGroup:AddToggle("AutoBuyWorkers", { Text = "Auto Buy Workers", Default = false })
ShopGroup:AddDropdown("WorkerList", {
    Text = "Workers",
    Values = pl_10,
    Default = {},
    Multi = true,
    Expandable = true,
    ExpandColumns = 2
})
local WorkersGroup = o9.Main:AddRightGroupbox("Workers", "users")
WorkersGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
WorkersGroup:AddSlider("EquipDelay", { Text = "Equip Delay", Default = 5, Min = 5, Max = 30, Rounding = 1 })
WorkersGroup:AddToggle("AutoUpgradePlaced", { Text = "Auto Upgrade Placed Workers", Default = false })
WorkersGroup:AddDropdown("UpgradePriority", {
    Text = "Priority",
    Values = { "Random", "Highest Earnings", "Rarest" },
    Default = "Highest Earnings",
    Multi = false
})
local ClaimsGroup = o9.Main:AddRightGroupbox("Claims", "gift")
ClaimsGroup:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
pv, po_3, pr = nil, nil, nil
if (pv and pr or po_3 or 10 or (false and not po_3 and (not pr and pr) or (false or (not pr or not po_3))) or ((false or not po_3) and (not pr and false) or (not po_3 or pv) and (po_3 and pv)) and ((pr and false or false) and (false and (po_3 and false)))) and not (pv and pr or po_3 or 10 or (false and not po_3 and (not pr and pr) or (false or (not pr or not po_3))) or ((false or not po_3) and (not pr and false) or (not po_3 or pv) and (po_3 and pv)) and ((pr and false or false) and (false and (po_3 and false)))) then
else
    pv = function()
        local ve
        local vf
        ve = nil
        vf = nil
        local Label, Label2, Label3, vj, vk
        local function vl()
            local uq = hookfunction ~= nil
            local ur = hookmetamethod ~= nil
            local us = getrawmetatable ~= nil
            local ut = setrawmetatable ~= nil
            local uu = getgc ~= nil
            local uv = getgenv ~= nil
            local uw = getreg ~= nil
            local ux = getconnections ~= nil
            local uy = firesignal ~= nil
            local uz = getcallbackvalue ~= nil
            local uA = setclipboard ~= nil
            local uB = getcustomasset ~= nil
            local uC = getnamecallmethod ~= nil
            local uD = isexecutorclosure ~= nil
            local uE = fireproximityprompt ~= nil
            local uF = firetouchinterest ~= nil
            local uG = WebSocket ~= nil
            local uH = readfile ~= nil
            local uI = writefile ~= nil
            local uK = (request or http_request) ~= nil
            local uM = (debug and debug.getupvalues) ~= nil
            local uO = (debug and debug.setupvalue) ~= nil
            local uP = 0
            local uQ = { uq, ur, us, ut, uu, uv, uw, ux, uy, uz, uA, uB, uC, uD, uE, uF, uG, uH, uI, uK, uM, uO }
            for i, v in ipairs(uQ) do
                if v then
                    uP += 1
                end
            end
            local uq_1 = uP / #uQ
            if uq_1 >= 0.9 then
                return oE("Full Support", oj)
            elseif uq_1 >= 0.6 then
                return oE("Half Support", n7)
            else
                return oE("Low Support", pc)
            end
        end
        ve = "Unknown"
        pcall(function()
            local u1_1
            local u0_1
            if identifyexecutor then
                u1_1, u0_1 = identifyexecutor()
                local u2 = u1_1 ~= ""
                local u3 = type(u1_1) == "string" and u2
                if u3 then
                    local u2_1 = type(u0_1) == "string" and u0_1 ~= "" and u1_1 .. " " .. u0_1
                    local u0_2 = u2_1
                    local u7 = if u0_2 then 1 else 0
                    local u5 = 2288 * u7 + 1457 * (1 - u7)
                    local u6 = 3125 * u7 + 2016 * (1 - u7)
                    if not ((u5 * 3881 + u6 * 1924 + u5 * u6) % 16777213 == 5265015) then
                        u0_2 = u1_1
                    end
                    ve = u0_2
                end
            end
        end)
        local vm = vl()
        vf = os.clock()
        vj = function()
            local u8 = math.floor(os.clock() - vf)
            if u8 < 60 then
                return u8 .. "s"
            elseif u8 < 3600 then
                return string.format("%dm %ds", math.floor((u8) / (60)), u8 % 60)
            else
                return string.format("%dh %dm", math.floor((u8) / (3600)), math.floor((u8 % 3600) / (60)))
            end
        end
        local UserGroup = o9.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = oe, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(of("User", oe.DisplayName .. " @" .. oe.Name, oj), true)
        UserGroup:AddLabel(of("UserId", tostring(oe.UserId), oc), true)
        UserGroup:AddLabel(of("Executor", ve .. "  " .. vm, oj), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(of("Session", vj(), n7), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                o3(oe.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                o3("https://www.roblox.com/users/" .. tostring(oe.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = o9.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddDivider("Server")
        SessionGroup:AddLabel(of("Game", oO, oc), true)
        Label2 = SessionGroup:AddLabel(of("Players", "0/0", oj), true)
        vk = tostring(game.JobId)
        local vm_1 = #vk > 18 and string.sub(vk, 1, 18) .. "..."
        local vm_2 = vm_1 or vk
        SessionGroup:AddLabel(of("Job", vm_2, n3), true)
        Label = SessionGroup:AddLabel(of("Ping", "0 ms", n7), true)
        SessionGroup:AddDivider()
        SessionGroup:AddButton({
            Text = "Rejoin Server",
            Func = function()
                TeleportService:Teleport(game.PlaceId, oe)
            end
        })
        SessionGroup:AddButton({
            Text = "Copy Job ID",
            Func = function()
                o3(vk, "Copied Job ID")
            end
        })
        task.spawn(function()
            local vb_1
            local va_1
            while true do
                task.wait(1)
                if om.Unloaded then
                    break
                end
                Label3:SetText(of("Session", vj(), n7))
                Label2:SetText(of("Players", #n2:GetPlayers() .. "/" .. tostring(n2.MaxPlayers), oj))
                va_1, vb_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local va_2 = va_1 and vb_1 .. " ms" or "n/a"
                Label:SetText(of("Ping", va_2, n7))
            end
        end)
        local SocialsGroup = o9.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = oI })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                o3(oA, "Copied Rscripts profile to clipboard")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                o3(ov, "Copied website link")
            end
        })
    end
end
local function po_4()
    local MovementGroup = o9.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = o9.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local CurrentCamera = oo.CurrentCamera
    local connection
    local function ij(ik)
        pcall(function()
            oD:SetGameplayPausedNotificationEnabled(not ik)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = oL:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not ik
            end
        end)
        if not ik then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(oe, "GameplayPaused", false)
            else
                oe.GameplayPaused = false
            end
        end)
    end
    local function iy(iz)
        local vw = if not iz:IsA("ProximityPrompt") then 1 else 0
        if vw == 1 then
            return
        end
        iz.HoldDuration = 0
        iz.MaxActivationDistance = 50
        iz.RequiresLineOfSight = false
    end
    o6.Stepped:Connect(function()
        if om.Unloaded then
            return
        end
        if ol("NoClip") then
            local Character = oe.Character
            if Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    local vx_1 = descendant:IsA("BasePart") and descendant.CanCollide
                    if vx_1 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    UserInputService.JumpRequest:Connect(function()
        if om.Unloaded then
            return
        end
        local vJ = if ol("InfJump") then 1 else 0
        if vJ == 1 then
            local vF = o7()
            if vF then
                vF:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    o6.RenderStepped:Connect(function(iQ)
        if om.Unloaded then
            return
        end
        if ol("WalkSpeedEnabled") then
            local vK_1 = o7()
            if vK_1 then
                vK_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        local vQ = if ol("Fly") then 1 else 0
        if vQ == 1 then
            local vK_2 = ob()
            local vL = o7()
            if vK_2 and vL then
                vL.PlatformStand = true
                local vL_1 = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    vL_1 += CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    vL_1 -= CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    vL_1 -= CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    vL_1 += CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    vL_1 += Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    vL_1 -= Vector3.new(0, 1, 0)
                end
                vK_2.Velocity = Vector3.zero
                if vL_1.Magnitude > 0 then
                    vK_2.CFrame = vK_2.CFrame + vL_1.Unit * Options.FlySpeed.Value * iQ
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local vR = o7()
            if vR then
                vR.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local vW = o7()
            if vW then
                vW.WalkSpeed = 16
            end
        end
    end)
    Toggles.AntiGameplayPause:OnChanged(function()
        ij(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not om.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                ij(true)
            end
        end
    end)
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in ipairs(oo:GetDescendants()) do
                pcall(iy, descendant)
            end
            connection = oo.DescendantAdded:Connect(function(jl)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(iy, jl)
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    om:OnUnload(function()
        ij(false)
        if connection then
            connection:Disconnect()
        end
    end)
end
pv()
po_4()
task.spawn(worker2)
pr = function()
    local MenuGroup = o9.Settings:AddLeftGroupbox("Menu")
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    om.ToggleKeybind = Options.MenuKeybind
    local jP = 0
    local jQ = tick()
    local Label
    local function jS()
        local CurrentCamera = oo.CurrentCamera
        if not CurrentCamera then
            return
        end
        oX:CaptureController()
        oX:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        jP += 1
        jQ = tick()
        if Label then
            pcall(function()
                Label:SetText("AFK triggers: " .. jP)
            end)
        end
    end
    local connection = oe.Idled:Connect(function()
        if ol("AntiAfk") then
            pcall(jS)
        end
    end)
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    Label = MenuGroup:AddLabel("AFK triggers: 0")
    MenuGroup:AddButton({
        Text = "Unload UI",
        Func = function()
            om:Unload()
        end
    })
    task.spawn(function()
        while not om.Unloaded do
            task.wait(2)
            local wo = ol("AntiAfk") and tick() - jQ >= 60
            if wo then
                pcall(jS)
            end
        end
    end)
    om:OnUnload(function()
        if connection then
            connection:Disconnect()
        end
        for k, v in oC do
            local ww = v
            pcall(function()
                ww:Disconnect()
            end)
        end
        table.clear(oC)
        if getgenv then
            getgenv().__TempoMyGrassFarmLib = nil
        end
    end)
    o2:SetLibrary(om)
    o2:SetFolder("TempoHub")
    o2:SaveDefault("Evil Hello Kitty")
    o2:ApplyToTab(o9.Settings)
    o2:LoadDefault()
    oZ:SetLibrary(om)
    oZ:IgnoreThemeSettings()
    oZ:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    oZ:SetFolder("TempoHub/MyGrassFarm")
    local kj = oZ:BuildConfigSection(o9.Settings)
    local function kk(kl, km)
        local wy = kl == "Toggle" and Toggles
        local wD = if wy then 1 else 0
        local wB = 128 * wD + 1366 * (1 - wD)
        local wC = 3950 * wD + 2015 * (1 - wD)
        if not ((wB * 1967 + wC * 374 + wB * wC) % 16777213 == 2234676) then
            wy = Options
        end
        local wy_1 = wy[km]
        local wx_2 = type(wy_1) == "table" and wy_1.Type == kl
        return wx_2 and wy_1 or nil
    end
    local function kt(kv, kw)
        local Type = kw.Type
        if Type == "Toggle" then
            return { idx = kv, type = "Toggle", value = kw.Value == true }
        elseif Type == "Slider" then
            return { idx = kv, type = "Slider", value = tostring(kw.Value) }
        elseif Type == "Dropdown" then
            return { idx = kv, type = "Dropdown", multi = kw.Multi == true, value = kw.Value }
        elseif Type == "Input" then
            local wF = kw.Value or ""
            return { idx = kv, type = "Input", text = tostring(wF) }
        elseif Type == "ColorPicker" then
            return { idx = kv, type = "ColorPicker", value = kw.Value:ToHex(), transparency = kw.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = kv,
                type = "KeyPicker",
                mode = kw.Mode,
                key = kw.Value,
                modifiers = kw.Modifiers,
                toggled = kw.Toggled
            }
        else
            return nil
        end
    end
    local function ky()
        local wI = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local wJ = type(v) == "table" and type(v.Type) == "string" and not oZ.Ignore[k]
                if wJ then
                    local wJ_1 = kt(k, v)
                    if wJ_1 then
                        wI[#wI + 1] = wJ_1
                    end
                end
            end
        end
        table.sort(wI, function(kI, kJ)
            if kI.type ~= kJ.type then
                return kI.type < kJ.type
            end
            return kI.idx < kJ.idx
        end)
        return { objects = wI }
    end
    local function kK(kL)
        local w4
        w4 = nil
        local w5 = type(kL) ~= "table" or type(kL.idx) ~= "string" or type(kL.type) ~= "string" or oZ.Ignore[kL.idx]
        if w5 then
            return false
        end
        w4 = kk(kL.type, kL.idx)
        if not w4 then
            return false
        end
        local w5_1 = pcall(function()
            if kL.type == "Input" then
                if type(kL.text) ~= "string" then
                    return
                end
                w4:SetValue(kL.text)
            elseif kL.type == "ColorPicker" then
                w4:SetValueRGB(Color3.fromHex(kL.value), kL.transparency)
            elseif kL.type == "KeyPicker" then
                w4:SetValue({ kL.key, kL.mode, kL.modifiers })
                if kL.mode == "Toggle" and kL.toggled ~= nil then
                    w4.Toggled = kL.toggled
                    w4:Update()
                end
            else
                w4:SetValue(kL.value)
            end
        end)
        return w5_1
    end
    kj:AddDivider()
    kj:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    kj:AddButton({
        Text = "Export Config to Clipboard",
        Func = function()
            local w8_1
            local w7_1
            w7_1, w8_1 = pcall(HttpService.JSONEncode, HttpService, ky())
            if not w7_1 then
                om:Notify("Failed to encode the config")
                return
            end
            local w7_2 = setclipboard or toclipboard
            local w7_3 = type(w7_2) ~= "function" or not pcall(w7_2, w8_1)
            if w7_3 then
                om:Notify("Your executor does not support copying to the clipboard")
                return
            end
            om:Notify("Config copied to clipboard", 6)
        end
    })
    kj:AddButton({
        Text = "Import Config from Clipboard Text",
        Func = function()
            local xd_1
            local xb = Options.SaveManager_ImportSource.Value or ""
            local xb_1
            local xc = tostring(xb):match("^%s*(.-)%s*$")
            if xc == "" then
                om:Notify("Paste an exported config into the box first")
                return
            end
            xb_1, xd_1 = pcall(HttpService.JSONDecode, HttpService, xc)
            local xc_1 = not xb_1 or type(xd_1) ~= "table" or type(xd_1.objects) ~= "table"
            if xc_1 then
                om:Notify("That is not a valid exported config")
                return
            end
            local xb_2 = 0
            for i, v in ipairs(xd_1.objects) do
                if kK(v) then
                    xb_2 += 1
                end
            end
            if xb_2 == 0 then
                om:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local xd_2 = xb_2 == 1 and "" or "s"
            om:Notify(("Imported %d setting%s"):format(xb_2, xd_2), 6)
        end
    })
    oZ:LoadAutoloadConfig()
end
pr()
end)(...)

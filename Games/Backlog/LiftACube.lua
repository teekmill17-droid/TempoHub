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
getgenv().TempoHoodSubtitle = "LIFT A CUBE"
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
local o2
local oH
local om
local oK
local op
local n8
local ox
local LocalPlayer
local oA
local oW
local oe
local oZ
local o1
local oG
local ol
local oJ
local oo
local oM
local ot
local oP
local n7
local State
local ow
local oV
local od
local oC
local oY
local oF
local o0
local oj
local oL
local oq
local oO
local ov
local n9
local oy
local oc
local oX
local of
local oE
local function fn23()
    local rJ = ox()
    if not rJ then
        return
    end
    local rK = oX()
    local rL = rK and rK.Arms
    local rK_1 = rL
    if rL then
        rL = type(rK_1.owned) == "table"
    end
    if rL then
        rL = rK_1.owned
    end
    local rN = rL or {}
    local rM_1 = n7()
    local rW = 1
    while rW <= 10 do
        local rX = rW
        local rN_1 = od[rX]
        local rO = type(rN_1) == "table" and rN[rX] ~= true
        if rO then
            local rO_1 = tonumber(rN_1.Price) or 0
            if rM_1 >= rO_1 then
                local rN_3 = rJ:FindFirstChild(tostring(rX))
                local rO_2 = rN_3 and rN_3:FindFirstChild("Main")
                local rO_3 = typeof(rO_2) == "Instance" and rO_2:IsA("BasePart")
                if rO_3 then
                    oV(rO_2.Position + Vector3.new(0, 3, 0))
                    task.wait(0.08)
                    local rO_4 = not of() or not State.Enabled.BuySpeed
                    if rO_4 then
                        return
                    end
                    oj(rO_2)
                    local rN_5 = os.clock() + 1.4
                    while true do
                        local rO_5 = of() and State.Enabled.BuySpeed and os.clock() < rN_5
                        if rO_5 then
                            local rO_6 = n7() < rM_1
                            if not rO_6 then
                                local rP = rK_1 and rK_1.owned
                                if rP then
                                    rP = rK_1.owned[rX] == true
                                end
                                rO_6 = rP
                            end
                            if rO_6 then
                                break
                            end
                            task.wait(0.1)
                            continue
                        end
                        break
                    end
                    return
                end
            end
        end
        rW += 1
    end
    task.wait(0.45)
end
local function fn91(a4, a5)
    local qn = a5 and a5:FindFirstChild("CubeName", true)
    local qo = qn
    if qn then
        qn = type(qo.Text) == "string"
    end
    if qn then
        qn = qo.Text
    end
    local qo_1 = qn or nil
    if qo_1 and qo_1 ~= "" then
        return qo_1
    end
    local qn_2 = oM[a4] or ("Cube %*"):format(a4)
    return qn_2
end
local function fn99(V)
    local pU = typeof(cloneref) == "function" and typeof(V) == "Instance"
    if pU then
        return cloneref(V)
    end
    return V
end
local function worker()
    while of() do
        if State.Enabled.Bonus then
            oP()
        else
            task.wait(0.2)
        end
    end
end
local function fn180()
    gethui = o0
end
local function worker5()
    while of() do
        if State.Enabled.Lift then
            oe()
        else
            task.wait(0.2)
        end
    end
end
local function worker2()
    while of() do
        if State.Enabled.Train then
            ov()
        else
            task.wait(0.2)
        end
    end
end
local function fn225()
    local rZ = oX()
    local r_ = rZ and rZ.Roll
    local rZ_1 = r_
    if r_ then
        r_ = oq(rZ_1.Play)
    end
    if r_ then
        r_ = oq(rZ_1.Buy)
    end
    if r_ then
        r_ = oq(rZ_1.Next)
    end
    if not r_ then
        local r__1 = oc()
        local r0_1 = r__1 and r__1:FindFirstChildWhichIsA("ProximityPrompt")
        if State.Enabled.Roll then
            if r__1 then
                oV(r__1.Position + Vector3.new(0, 3, 0))
            end
            oo(r0_1)
        end
        task.wait(0.35)
        return
    end
    if rZ_1.rolling or rZ_1.buying then
        task.wait(0.12)
        return
    end
    if rZ_1.pending then
        if State.Enabled.BuyRoll then
            local r__3 = n8[rZ_1.pending]
            local r0_2 = r__3 and tonumber(r__3.Price)
            local r__4 = r0_2 or math.huge
            if n7() >= r__4 then
                pcall(rZ_1.Buy, rZ_1)
            else
                pcall(rZ_1.Next, rZ_1)
            end
            task.wait(0.2)
            return
        elseif State.Enabled.Roll then
            pcall(rZ_1.Next, rZ_1)
            task.wait(0.2)
            return
        else
            task.wait(0.25)
            return
        end
    end
    if State.Enabled.Roll then
        local r__5 = oc()
        if r__5 then
            oV(r__5.Position + Vector3.new(0, 3, 0))
            task.wait(0.08)
        end
        local r__6 = not of() or not State.Enabled.Roll
        if r__6 then
            return
        end
        pcall(rZ_1.Play, rZ_1)
        task.wait(0.2)
        return
    end
    task.wait(0.25)
end
local function fn302()
    State.Enabled.Lift = false
    State.Enabled.BuySpeed = false
    State.Enabled.Roll = false
    State.Enabled.BuyRoll = false
    State.Enabled.Train = false
    State.Enabled.Bonus = false
    State.LiftBusy = false
end
local function fn312()
    local qk = n9()
    local ql = qk and qk:FindFirstChild("Points")
    local qk_1 = ql
    if ql then
        ql = qk_1:FindFirstChild("Roll")
    end
    return ql
end
local function fn319()
    return not oG.Unloaded
end
local function fn320()
    for k, v in oJ do
        pcall(task.cancel, v)
    end
end
local function fn348(Y)
    return type(Y) == "function"
end
local function fn370()
    return ow
end
local function fn382()
    local World = oy:FindFirstChild("World")
    local p9 = World and World:FindFirstChild("Shared")
    return p9
end
local function fn388()
    oZ()
    return { Cubes = oC }
end
local function worker3()
    while of() do
        if State.Enabled.Roll or State.Enabled.BuyRoll then
            op()
        else
            task.wait(0.2)
        end
    end
end
local function fn430()
    local qe = n9()
    local qf = qe and qe:FindFirstChild("Arms")
    return qf
end
local function fn469()
    local qE = type(ot) == "table" and type(ot.controllers) == "table"
    if qE then
        return ot.controllers
    end
    if not oE then
        return nil
    end
    local qE_1 = os.clock()
    if qE_1 - om < 0.35 then
        return nil
    end
    om = qE_1
    local qE_2 = oE("table", { Keys = { "data_replica", "controllers" } }, true)
    local qF = type(qE_2) == "table" and type(qE_2.controllers) == "table"
    if qF then
        ot = qE_2
        return qE_2.controllers
    end
end
local function fn543(ev, ew)
    State.Enabled[ev] = ew == true
    if ev == "Lift" and not State.Enabled.Lift then
        State.LiftBusy = false
    end
end
local function fn545()
    local qZ_1
    local qY_1
    qY_1, qZ_1 = oL()
    local q_ = qY_1 and qY_1:FindFirstChild("Train")
    local qY_2 = q_
    if q_ then
        q_ = qY_2:IsA("Tool")
    end
    if q_ then
        q_ = qY_2:GetAttribute("TrainTool") == true
    end
    if q_ then
        return qY_2, qZ_1
    end
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    local q__1 = Backpack and Backpack:FindFirstChild("Train")
    local qY_4 = q__1
    if q__1 then
        q__1 = qY_4:IsA("Tool")
    end
    if q__1 then
        q__1 = qY_4:GetAttribute("TrainTool") == true
    end
    if q__1 then
        return qY_4, qZ_1
    end
end
local function fn615()
    local q6_1
    local q4 = oX()
    local q5 = q4 and q4.Cubes
    local q5_1
    local q4_1 = q5
    if q5 then
        q5 = oq(q4_1.IsLifting)
    end
    if q5 then
        q5_1, q6_1 = pcall(q4_1.IsLifting, q4_1)
        if q5_1 then
            return q6_1 == true or q4_1.active ~= nil
        end
        return State.LiftBusy == true
    end
    return State.LiftBusy == true
end
local function fn698()
    local p0 = tonumber(LocalPlayer:GetAttribute("Strength")) or 0
    return p0
end
local function fn713()
    local pW = (tonumber(LocalPlayer:GetAttribute("Cash")))
    local p_ = if pW then 1 else 0
    local pY = 3149 * p_ + 2339 * (1 - p_)
    local pZ = 3750 * p_ + 2055 * (1 - p_)
    if not ((pY * 2022 + pZ * 1078 + pY * pZ) % 16777213 == 5441315) then
        pW = 0
    end
    return pW
end
local function fn719()
    local Character = LocalPlayer.Character
    local p3 = Character and Character:FindFirstChildOfClass("Humanoid")
    local p4 = Character
    if p4 then
        p4 = Character:FindFirstChild("HumanoidRootPart")
    end
    local p3_1 = Character
    local p6 = p4
    if p3_1 then
        p3_1 = p3
    end
    if p3_1 then
        p3_1 = p6
    end
    if p3_1 then
        p3_1 = p3.Health > 0
    end
    if p3_1 then
        return Character, p3, p6
    end
end
local function fn742()
    local sb = oX()
    local sb_2
    local sc = sb and sb.Pops
    local sb_1 = sc
    if sc then
        sc = type(sb_1.live) == "table"
    end
    if sc then
        sc = oq(sb_1._Claim)
    end
    if not sc then
        task.wait(0.3)
        return
    end
    local sc_1 = false
    for k, v in sb_1.live do
        local sd_1 = type(v) == "table" and v.Rare ~= true
        if sd_1 then
            pcall(sb_1._Claim, sb_1, k)
            sc_1 = true
        end
    end
    local wait = task.wait
    if sc_1 then
        sb_2 = 0.12
    else
        sb_2 = 0.3
    end
    wait(sb_2)
end
local function fn792(cn)
    local MinimumTime = oY.MinimumTime
    local rc = oW()
    local rd = tonumber(cn) or 0
    local re = MinimumTime(rc, rd)
    local rb_1 = type(re) ~= "number" or re ~= re or re >= 100000000
    if rb_1 then
        re = 0.5
    end
    return math.max(re * 1.25, re + 0.12)
end
local function fn809()
    local qb = n9()
    local qc = qb and qb:FindFirstChild("Cubes")
    return qc
end
local function fn818(ct, cu)
    local max = math.max
    local rh = (tonumber(o2.MaxRate))
    local rr = if rh then 1 else 0
    local rp = 3240 * rr + 1573 * (1 - rr)
    local rq = 1261 * rr + 2935 * (1 - rr)
    if not ((rp * 1996 + rq * 3151 + rp * rq) % 16777213 == 14526091) then
        rh = 20
    end
    local rg_1 = 1 / max(1, rh)
    local rh_1 = o1(cu)
    local ri = os.clock()
    local min = math.min
    local rk = tonumber(o2.Timeout) or 60
    local rj_1 = ri + min(rk, math.max(8, rh_1 + 4))
    while true do
        local ri_1 = of() and State.Enabled.Lift and os.clock() < rj_1
        if ri_1 then
            local active = ct.active
            if type(active) ~= "table" then
                break
            end
            local rk_1 = tonumber(active.Elapsed) or 0
            local rk_2 = tonumber(active.Gain) or 0
            local rk_3 = tonumber(active.Progress) or 0
            local rk_4 = rk_3 + rk_2
            if rk_1 < rh_1 then
                rk_4 = math.min(rk_4, 0.999)
            end
            active.Progress = rk_4
            task.wait(rg_1)
            local ri_3 = not of() or not State.Enabled.Lift
            if ri_3 then
                break
            end
            continue
        end
        break
    end
end
local function fn825(bB)
    local qN_1
    local qM_1
    local qL_1
    qL_1, qM_1, qN_1 = oL()
    local qL_2 = not qN_1 or typeof(bB) ~= "Vector3"
    if qL_2 then
        return
    end
    ol(bB)
    qN_1.CFrame = CFrame.new(bB)
    qN_1.AssemblyLinearVelocity = Vector3.zero
end
local function fn864(ez)
    local sq = oA[ez]
    if type(sq) == "number" then
        State.CubeLabel = ez
        State.CubeIndex = sq
    end
end
local function worker4()
    while of() do
        if State.Enabled.BuySpeed then
            oK()
        else
            task.wait(0.2)
        end
    end
end
local function fn946()
    table.clear(oC)
    table.clear(oA)
    local qr = oO()
    for k, v in oH do
        local qs = qr and qr:FindFirstChild(tostring(v))
        local qs_1 = (("%* %*"):format(v, (oF(v, qs))))
        table.insert(oC, qs_1)
        oA[qs_1] = v
    end
    if not oA[State.CubeLabel] then
        State.CubeLabel = oC[1]
        local qr_1 = oH[1] or 1
        State.CubeIndex = qr_1
    end
end
n7 = nil
n8 = nil
n9 = nil
LocalPlayer = nil
oc = nil
od = nil
oe = nil
of = nil
oj = nil
ol = nil
om = nil
oo = nil
op = nil
oq = nil
ot = nil
ov = nil
ow = nil
ox = nil
oy = nil
oA = nil
oC = nil
oE = nil
oF = nil
oG = nil
oH = nil
oJ = nil
oK = nil
oL = nil
oM = nil
oO = nil
oP = nil
State = nil
oV = nil
oW = nil
local Players, oa, Workspace, oh, oi, Lighting, ou, oz, oB, HttpService, VirtualUser, UserInputService, oQ, oR, RunService, oU
oX = nil
oY = nil
oZ = nil
o0 = nil
o1 = nil
o2 = nil
local o_
local o7_1
if not game:IsLoaded() then
    game.Loaded:Wait()
end
Players, RunService, UserInputService, VirtualUser, HttpService, oB, ow, ou, Lighting, Workspace, LocalPlayer, o0 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
if (not Lighting and not o0 and (Lighting and Players) or (not o0 or Players) and (not LocalPlayer or not Lighting) and ((not Lighting or not o0) and (Players and Players))) and (not Players and not LocalPlayer or false or (o0 and Players or (not VirtualUser or Players)) or ((o0 or false) and (not LocalPlayer and VirtualUser) or (VirtualUser and o0 or LocalPlayer and LocalPlayer))) and not ((not Lighting and not o0 and (Lighting and Players) or (not o0 or Players) and (not LocalPlayer or not Lighting) and ((not Lighting or not o0) and (Players and Players))) and (not Players and not LocalPlayer or false or (o0 and Players or (not VirtualUser or Players)) or ((o0 or false) and (not LocalPlayer and VirtualUser) or (VirtualUser and o0 or LocalPlayer and LocalPlayer)))) then
    ou = game:GetService("GuiService")
    oB = game:GetService("CoreGui")
    ow = game:GetService("TeleportService")
else
    oB = game:GetService("GuiService")
    ow = game:GetService("CoreGui")
    ou = game:GetService("TeleportService")
end
Lighting = game:GetService("Lighting")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local o4 = "TempoLiftACube"
o0 = fn370
if getgenv then
    getgenv().gethui = o0
end
oG, o7_1, oh, oq = nil, nil, nil, nil
pcall(fn180)
local function o3(u)
    local pK
    local pI
    local pJ
    pI = nil
    pJ = nil
    pK = nil
    local pL = u ~= ""
    local pM = type(u) == "string" and pL
    assert(pM, "A namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    pI = getgenv()
    assert(type(pI) == "table", "getgenv did not return a table")
    local pL_1 = pI[u]
    if pL_1 ~= nil then
        local pM_1 = type(pL_1) == "table" and type(pL_1.Unload) == "function"
        assert(pM_1, "Namespace is occupied")
        pL_1.Unload()
        assert(pI[u] == nil, "Previous instance did not release its namespace")
    end
    pJ = {}
    pK = { State = {}, Unloaded = false }
    pK.Track = function(A)
        assert(type(A) == "function", "Cleanup must be callable")
        if pK.Unloaded then
            A()
        else
            table.insert(pJ, A)
        end
        return A
    end
    pK.Unload = function()
        local pB_1
        local pA_1
        if pK.Unloaded then
            return
        end
        pK.Unloaded = true
        local py = {}
        local pF = #pJ
        local pE = -1
        while false and pF <= 1 or true and pF >= 1 do
            local pG = pF
            local pz_1 = table.remove(pJ, pG)
            pA_1, pB_1 = pcall(pz_1)
            if not pA_1 then
                table.insert(py, tostring(pB_1))
            end
            pF += pE
        end
        table.clear(pK.State)
        if #py > 0 then
            error("Cleanup incomplete: " .. table.concat(py, "; "), 0)
        end
        if pI[u] == pK then
            pI[u] = nil
        end
    end
    pI[u] = pK
    return pK
end
oh = function(N, O)
    local pS = type(N) == "table" and type(N.Track) == "function"
    assert(pS, "FeatureAPI required")
    local pS_1 = type(O) == "table" and type(O.OnUnload) == "function"
    assert(pS_1, "UI library required")
    assert(type(O.Unload) == "function", "UI unload required")
    N.Track(function()
        if not O.Unloaded then
            O:Unload()
        end
    end)
    O:OnUnload(function()
        N.Unload()
    end)
end
oG = o3(o4)
if (oh and o7_1 or (oG or false) or false and (oh or not o3)) and ((o3 or oh) and (not o3 or not o7_1) and (not oG or oh or false and not o3)) and not ((oh and o7_1 or (oG or false) or false and (oh or not o3)) and ((o3 or oh) and (not o3 or not o7_1) and (not oG or oh or false and not o3))) then
else
    oq = fn348
end
local o7_2 = oq(firetouchinterest) and firetouchinterest
local o3_1 = o7_2
local pl = if o3_1 then 1 else 0
local pj = 2701 * pl + 258 * (1 - pl)
local pk = 3536 * pl + 952 * (1 - pl)
if not ((pj * 3524 + pk * 2072 + pj * pk) % 16777213 == 9618439) then
    o3_1 = nil
end
oa = nil
oa = o3_1
local o6 = oq(fireproximityprompt) and fireproximityprompt
local o3_2 = o6
local po = if o3_2 then 1 else 0
local pm = 3088 * po + 910 * (1 - po)
local pn = 2160 * po + 551 * (1 - po)
if not ((pm * 1721 + pn * 958 + pm * pn) % 16777213 == 14053808) then
    o3_2 = nil
end
o_ = nil
o_ = o3_2
local o6_1 = oq(mouse1click) and mouse1click
local o3_3 = o6_1 or nil
oQ = nil
oQ = o3_3
local o6_2 = oq(filtergc) and filtergc
local o3_4 = o6_2 or nil
oE, oy, oi, od, n8, o2, oY, State, oM, oH, oC, oA = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
oE = o3_4
local o9 = fn99(ReplicatedStorage)
oy = fn99(Workspace)
local o7_3 = fn99(o9:WaitForChild("Schematics"))
local o6_3 = fn99(o9:WaitForChild("Modules"))
oi = require(fn99(o7_3:WaitForChild("Cubes")))
od = require(fn99(o7_3:WaitForChild("Arms")))
n8 = require(fn99(o7_3:WaitForChild("Materials")))
o2 = require(fn99(o7_3:WaitForChild("Lifting")))
oY = require(fn99(o6_3:WaitForChild("Lifting")))
State = oG.State
State.Enabled = { Lift = false, BuySpeed = false, Roll = false, BuyRoll = false, Train = false, Bonus = false }
State.CubeIndex = 1
State.LiftBusy = false
oM = {
    [1] = "Wood Cube",
    [2] = "Stone Cube",
    [3] = "Cooper Cube",
    [4] = "Ice Cube",
    [5] = "Crystal Cube",
    [6] = "Golden Cube",
    [7] = "Magma Cube",
    [8] = "Plasma Cube",
    [9] = "Void Cube",
    [10] = "Singularity Cube"
}
oH = {}
oC = {}
oA = {}
local pr = 1
while pr <= 10 do
    local ps = pr
    if oi[ps] then
        table.insert(oH, ps)
    end
    pr += 1
end
ot, om, oJ, of, n7, oW, oL, n9, oO, ox, oc, oF, oZ, oX, ol, oV, oj, oo, oR, oU, o1, oz, oe, oK, op, ov, oP = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
table.sort(oH)
om = 0
of = fn319
n7 = fn713
oW = fn698
oL = fn719
n9 = fn382
oO = fn809
ox = fn430
oc = fn312
oF = fn91
oZ = fn946
oZ()
oX = fn469
ol = function(bw)
    if typeof(bw) ~= "Vector3" then
        return
    end
    pcall(function()
        LocalPlayer:RequestStreamAroundAsync(bw, 8)
    end)
end
oV = fn825
oj = function(bJ)
    local qP
    local qR_1
    local qQ_1
    qQ_1, qR_1, qP = oL()
    local qQ_2 = not oa or not qP
    local qV = if qQ_2 then 1 else 0
    local qT = 1126 * qV + 2986 * (1 - qV)
    local qU = 2802 * qV + 2595 * (1 - qV)
    if not ((qT * 2530 + qU * 2381 + qT * qU) % 16777213 == 12675394) then
        qQ_2 = typeof(bJ) ~= "Instance"
    end
    if qQ_2 then
        return false
    end
    local qQ_3 = pcall(function()
        oa(bJ, qP, 0)
        oa(bJ, qP, 1)
        oa(bJ, qP, 0)
    end)
    return qQ_3
end
oo = function(bV)
    local qW = not o_ or typeof(bV) ~= "Instance"
    if qW then
        return false
    end
    return pcall(function()
        bV.Enabled = true
        o_(bV)
    end)
end
oR = fn545
oU = fn615
o1 = fn792
oz = fn818
oe = function()
    local rt
    local CubeIndex = State.CubeIndex
    local rw = oi[CubeIndex]
    if type(rw) ~= "table" then
        return
    end
    local GainPerClick2 = oY.GainPerClick
    local ry = oW()
    local ry_3
    local rz = (tonumber(rw.Mass))
    local rF = if rz then 1 else 0
    local rD = 3368 * rF + 1893 * (1 - rF)
    local rE = 3501 * rF + 3537 * (1 - rF)
    if not ((rD * 2701 + rE * 2257 + rD * rE) % 16777213 == 12012880) then
        rz = 0
    end
    if GainPerClick2(ry, rz) <= 0 then
        task.wait(0.6)
        return
    end
    local rx_1 = oO()
    local ry_1 = rx_1 and rx_1:FindFirstChild(tostring(CubeIndex))
    local ry_2 = typeof(ry_1) ~= "Instance" or not ry_1:IsA("BasePart")
    if ry_2 then
        task.wait(0.35)
        return
    end
    ry_3, rt = oL()
    if not ry_3 then
        task.wait(0.2)
        return
    end
    State.LiftBusy = true
    if rt then
        pcall(function()
            rt:UnequipTools()
        end)
    end
    oV(ry_1.Position + Vector3.new(4, 3, 0))
    task.wait(0.12)
    local rz_1 = not of() or not State.Enabled.Lift
    if rz_1 then
        State.LiftBusy = false
        return
    end
    local ry_4 = oL()
    if not ry_4 then
        State.LiftBusy = false
        return
    end
    local ry_5 = oX()
    local ru = ry_5 and ry_5.Cubes
    local ry_6 = n7()
    local rz_3 = ru and oq(ru.Start)
    if rz_3 then
        pcall(function()
            if oq(ru.SetPrompts) then
                ru:SetPrompts(true)
            end
        end)
        pcall(ru.Start, ru, CubeIndex, ry_1)
        task.wait(0.08)
        local rv_1 = not of() or not State.Enabled.Lift
        if rv_1 then
            State.LiftBusy = false
            return
        end
        if ru.active then
            local rv_2 = tonumber(rw.Mass) or 0
            oz(ru, rv_2)
        end
    else
        local ProximityPrompt = ry_1:FindFirstChildWhichIsA("ProximityPrompt")
        oo(ProximityPrompt)
        local rv_4 = o1(rw.Mass)
        local GainPerClick = oY.GainPerClick
        local rz_4 = oW()
        local rA = tonumber(rw.Mass) or 0
        local rw_1 = GainPerClick(rz_4, rA)
        local max2 = math.max
        local ceil = math.ceil
        local rA_1 = tonumber(o2.Start) or 0.125
        local rB = max2(1, ceil((1 - rA_1) / math.max(rw_1, 1e-06)))
        local max = math.max
        local rz_6 = tonumber(o2.MaxRate) or 20
        local rx_5 = max(1 / max2(1, rz_6), rv_4 / rB)
        local rw_3 = os.clock()
        local rz_7 = 0
        while true do
            local rA_2 = of() and State.Enabled.Lift and rz_7 < rB + 8
            if rA_2 then
                local rA_3 = os.clock() - rw_3 >= rv_4 and rz_7 >= rB
                if rA_3 then
                    break
                end
                if oQ then
                    pcall(oQ)
                end
                rz_7 += 1
                task.wait(rx_5)
                continue
            end
            break
        end
    end
    local rv_5 = os.clock()
    while true do
        local rw_4 = of() and os.clock() - rv_5 < 2
        if rw_4 then
            local rw_5 = oX()
            local rx_6 = rw_5 and rw_5.Cubes
            local rw_6 = rx_6
            if rx_6 then
                rx_6 = rw_6.active or rw_6.celebration or rw_6.opening
            end
            local rx_7 = not rx_6
            if rx_7 ~= false then
                local rw_8 = n7() > ry_6 or os.clock() - rv_5 >= 1.1
                rx_7 = rw_8
            end
            if rx_7 then
                break
            end
            task.wait(0.05)
            continue
        end
        break
    end
    State.LiftBusy = false
end
oK = fn23
op = fn225
ov = function()
    local r6
    local r7
    if oU() then
        task.wait(0.15)
        return
    end
    r7, r6 = oR()
    if not r7 or not r6 then
        task.wait(0.35)
        return
    end
    if r7.Parent ~= LocalPlayer.Character then
        pcall(function()
            r6:EquipTool(r7)
        end)
    end
    task.wait(0.4)
end
oP = fn742
do
    oG.SetEnabled = fn543
    oG.SetCube = fn864
    oG.Options = fn388
    oG.Track(fn302)
    oJ = {
        task.spawn(worker5),
        task.spawn(worker4),
        task.spawn(worker3),
        task.spawn(worker2),
        task.spawn(worker)
    }
end
oG.Track(fn320)
local function o4_1()
    local wF
    local onDiscord
    local wQ
    wF = nil
    onDiscord = nil
    wQ = nil
    local SaveManager, wH, wI, Library, Toggles, wM, wN, ThemeManager, Options
    wQ = "https://discord.gg/K7Qxnxkk46"
    wH = "Lift a Cube"
    wM = "https://tempohub.shop"
    wI = "https://discord.gg/K7Qxnxkk46"
    Library = getgenv().Library
    ThemeManager = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = Library.Toggles
    Options = Library.Options
    oh(oG, Library)
    wF = function(fe, ff)
        local sF = oq(setclipboard) and setclipboard
        local sG = sF
        if not sG then
            local sF_1 = oq(toclipboard) and toclipboard
            sG = sF_1 or nil
        end
        local sF_2 = sG
        if not sF_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local sG_1 = pcall(sF_2, fe)
        if sG_1 then
            Library:Notify(ff)
        else
            Library:Notify("Failed to copy")
        end
    end
    onDiscord = function()
        wF(wQ, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = wQ, Copyable = true }, "|", wH, "|", "v0.2" },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(true, { Color = Color3.fromRGB(242, 154, 196), Radius = 24, Transparency = 0.3 })
    wN = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gamepad-2"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
    local function wR_1(fv)
        local DiscordGroup = fv:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    for k, v in wN do
        if k ~= "Info" then
            wR_1(v)
        end
    end
    local wR_2 = oG.Options()
    local CubesGroup = wN.Main:AddLeftGroupbox("Cubes", "box")
    CubesGroup:AddToggle("AutoLift", {
        Text = "Auto Lift Cube",
        Default = false,
        Callback = function(fC)
            oG.SetEnabled("Lift", fC)
        end
    })
    CubesGroup:AddDropdown("LiftCube", {
        Text = "Cube",
        Values = wR_2.Cubes,
        Default = 1,
        Callback = function(fE)
            oG.SetCube(fE)
        end
    })
    local RollGroup = wN.Main:AddLeftGroupbox("Roll", "dices")
    RollGroup:AddToggle("AutoRoll", {
        Text = "Auto Roll",
        Default = false,
        Callback = function(fH)
            oG.SetEnabled("Roll", fH)
        end
    })
    RollGroup:AddToggle("AutoBuyRoll", {
        Text = "Auto Buy Roll",
        Default = false,
        Callback = function(fJ)
            oG.SetEnabled("BuyRoll", fJ)
        end
    })
    local TrainGroup = wN.Main:AddRightGroupbox("Train", "dumbbell")
    TrainGroup:AddToggle("AutoTrain", {
        Text = "Auto Train",
        Default = false,
        Callback = function(fM)
            oG.SetEnabled("Train", fM)
        end
    })
    TrainGroup:AddToggle("AutoBonusTrain", {
        Text = "Auto Get Bonus Train",
        Default = false,
        Callback = function(fO)
            oG.SetEnabled("Bonus", fO)
        end
    })
    TrainGroup:AddToggle("AutoBuyTrainSpeed", {
        Text = "Auto Buy Train Speed",
        Default = false,
        Callback = function(fQ)
            oG.SetEnabled("BuySpeed", fQ)
        end
    })
    local function wR_5()
        local tc
        local s9
        local s5
        local s3
        s3 = nil
        s5 = nil
        s9 = nil
        tc = nil
        local s0, s1, s2, s4, Label2, s7, Label3, ta, Label
        s5 = function(fU)
            return (tostring(fU):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
        end
        s3 = function(fW, fX)
            return string.format('<font color="%s">%s</font>', fX, s5(fW))
        end
        s7 = function(f_, f0, f1)
            return string.format("<b>%s</b> %s %s", f_, s3("-", "#5a6070"), s3(f0, f1))
        end
        local td = {}
        local te = "#8b93a3"
        s2 = "#e8a34d"
        s4 = "#7fd47f"
        local tf = "#6ec1ff"
        if not oa then
            table.insert(td, "firetouchinterest")
        end
        if not o_ then
            table.insert(td, "fireproximityprompt")
        end
        if not oE then
            table.insert(td, "filtergc")
        end
        local tg = #td == 0 and "ready"
        local th = tg or "limited: " .. table.concat(td, ", ")
        s1 = "Unknown"
        pcall(function()
            local sN_1
            local sM_1
            if oq(identifyexecutor) then
                sN_1, sM_1 = identifyexecutor()
                local sO = sN_1 ~= ""
                local sP = type(sN_1) == "string" and sO
                if sP then
                    local sO_1 = type(sM_1) == "string" and sM_1 ~= "" and sN_1 .. " " .. sM_1
                    s1 = sO_1 or sN_1
                end
            end
        end)
        s9 = os.clock()
        s0 = function()
            local sU = math.floor(os.clock() - s9)
            if sU < 60 then
                return sU .. "s"
            elseif sU < 3600 then
                return string.format("%dm %ds", math.floor((sU) / (60)), sU % 60)
            else
                return string.format("%dh %dm", math.floor((sU) / (3600)), math.floor((sU % 3600) / (60)))
            end
        end
        local UserGroup = wN.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(s7("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, s4), true)
        UserGroup:AddLabel(s7("UserId", tostring(LocalPlayer.UserId), tf), true)
        UserGroup:AddLabel(s7("Executor", s1 .. "  " .. th, s4), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(s7("Session", s0(), s2), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                wF(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                wF("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = wN.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(s7("Game", wH, tf), true)
        Label2 = SessionGroup:AddLabel(s7("Players", "0/0", s4), true)
        ta = tostring(game.JobId)
        local tf_1 = #ta > 18 and string.sub(ta, 1, 18) .. "..."
        local tg_2 = tf_1 or ta
        SessionGroup:AddLabel(s7("Job", tg_2, te), true)
        Label = SessionGroup:AddLabel(s7("Ping", "0 ms", s2), true)
        SessionGroup:AddDivider()
        SessionGroup:AddButton({
            Text = "Rejoin Place",
            Func = function()
                ou:Teleport(game.PlaceId, LocalPlayer)
            end
        })
        SessionGroup:AddButton({
            Text = "Copy Job ID",
            Func = function()
                wF(ta, "Copied Job ID")
            end
        })
        tc = task.spawn(function()
            local sX_1
            local sW_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(s7("Session", s0(), s2))
                Label2:SetText(s7("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), s4))
                sW_1, sX_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local sW_2 = sW_1 and sX_1 .. " ms" or "n/a"
                Label:SetText(s7("Ping", sW_2, s2))
            end
        end)
        oG.Track(function()
            if coroutine.status(tc) ~= "dead" then
                task.cancel(tc)
            end
        end)
        local SocialsGroup = wN.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                wF(wI, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                wF(wM, "Copied website link")
            end
        })
    end
    wR_5()
    local function wR_6()
        local hl
        local hj
        local hk
        local hi
        local MovementGroup = wN.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = wN.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        local hh = {}
        hk = {}
        hi = {}
        hj = {}
        hl = {}
        local function hm()
            for k, v in hi do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(hi)
        end
        local function hq()
            for k, v in hj do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(hj)
        end
        local function hu()
            for k, v in hk do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(hk)
        end
        local function hy(hz)
            if not hz:IsA("ProximityPrompt") then
                return
            end
            if hl[hz] == nil then
                hl[hz] = {
                    HoldDuration = hz.HoldDuration,
                    MaxActivationDistance = hz.MaxActivationDistance,
                    RequiresLineOfSight = hz.RequiresLineOfSight
                }
            end
            hz.HoldDuration = 0
            hz.MaxActivationDistance = 50
            hz.RequiresLineOfSight = false
        end
        local function hB()
            for k, v in hl do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(hl)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                hu()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                hq()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                hm()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                    pcall(hy, v)
                end
            else
                hB()
            end
        end)
        table.insert(hh, Workspace.DescendantAdded:Connect(function(hU)
            if Toggles.InstantProximityPrompt.Value then
                hy(hU)
            end
        end))
        table.insert(hh, RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if hi[v] == nil then
                        hi[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(hh, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local uc = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and uc then
                uc:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(hh, RunService.RenderStepped:Connect(function(ih)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local ul = Character and Character:FindFirstChildOfClass("Humanoid")
            local um = Character
            if um then
                um = Character:FindFirstChild("HumanoidRootPart")
            end
            local uk_1 = um
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and ul then
                if hj[ul] == nil then
                    hj[ul] = ul.WalkSpeed
                end
                ul.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and uk_1 and ul and CurrentCamera then
                if hk[ul] == nil then
                    hk[ul] = ul.PlatformStand
                end
                ul.PlatformStand = true
                local um_4 = Vector3.zero
                local uy = if not UserInputService:GetFocusedTextBox() then 1 else 0
                if uy == 1 then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        um_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        um_4 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        um_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        um_4 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        um_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        um_4 -= Vector3.new(0, 1, 0)
                    end
                end
                uk_1.AssemblyLinearVelocity = Vector3.zero
                if um_4.Magnitude > 0 then
                    uk_1.CFrame = uk_1.CFrame + um_4.Unit * Options.FlySpeed.Value * ih
                end
            end
        end))
        oG.Track(function()
            for k, v in hh do
                v:Disconnect()
            end
            hm()
            hq()
            hu()
            hB()
        end)
    end
    wR_6()
    local function wR_7()
        local jp
        local iA
        iA = {}
        local iz = {}
        local iB
        local iC = false
        local iE = 0
        local iD = 0
        local iF = os.clock()
        local MenuGroup = wN.Settings:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        local Label = MenuGroup:AddLabel("AFK triggers: 0")
        local function iJ()
            local CurrentCamera
            CurrentCamera = Workspace.CurrentCamera
            if not CurrentCamera then
                return
            end
            local uH = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.zero, CurrentCamera.CFrame)
            end)
            if not uH then
                return
            end
            iE += 1
            iF = os.clock()
            Label:SetText("AFK triggers: " .. iE)
        end
        local function onAntiGameplayPause(iX)
            pcall(function()
                oB:SetGameplayPausedNotificationEnabled(not iX)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = ow:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not iX
                end
            end)
            if iX then
                pcall(function()
                    if oq(sethiddenproperty) then
                        sethiddenproperty(LocalPlayer, "GameplayPaused", false)
                    else
                        LocalPlayer.GameplayPaused = false
                    end
                end)
            end
        end
        local function je()
            for k, v in iA do
                local uX = k
                local uZ = v
                if uX.Parent then
                    pcall(function()
                        uX.Enabled = uZ
                    end)
                end
            end
            table.clear(iA)
            if iB then
                pcall(function()
                    settings().Rendering.QualityLevel = iB.Quality
                end)
                Lighting.GlobalShadows = iB.Shadows
                Lighting.FogEnd = iB.Fog
                iB = nil
            end
        end
        jp = { ParticleEmitter = true, Trail = true, Smoke = true, Fire = true, Sparkles = true, Beam = true }
        local function jq(jr)
            if jp[jr.ClassName] then
                if iA[jr] == nil then
                    iA[jr] = jr.Enabled
                end
                jr.Enabled = false
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true, Callback = onAntiGameplayPause })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(ju)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not ju)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(jz)
                if jz then
                    if not iB then
                        iB = {
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
                        pcall(jq, v)
                    end
                else
                    je()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        onAntiGameplayPause(true)
        local ScriptGroup = wN.Settings:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        table.insert(iz, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                iJ()
            end
        end))
        table.insert(iz, Workspace.DescendantAdded:Connect(function(jQ)
            if Toggles.FpsBoost.Value then
                jq(jQ)
            end
        end))
        local function jT(jU)
            if iC or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            iC = true
            local vf = iD
            local vg_1 = pcall(function()
                if jU then
                    ou:Teleport(game.PlaceId, LocalPlayer)
                else
                    ou:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not vg_1 then
                iC = false
                if not jU and vf == iD then
                    task.delay(1.5, function()
                        if vf == iD then
                            jT(true)
                        end
                    end)
                end
            end
        end
        table.insert(iz, ou.TeleportInitFailed:Connect(function(kb)
            local vn
            if kb == LocalPlayer and iC then
                iC = false
                vn = iD
                task.delay(3, function()
                    if vn == iD then
                        jT(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = ow:WaitForChild("RobloxPromptGui", 30)
            local vs = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            if Library.Unloaded or not vs then
                return
            end
            table.insert(iz, vs.ChildAdded:Connect(function(kq)
                if kq.Name == "ErrorPrompt" then
                    jT(false)
                end
            end))
        end)
        local kA = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    onAntiGameplayPause(true)
                end
                local vy = Toggles.AntiAfk.Value and os.clock() - iF >= 60
                if vy then
                    iJ()
                end
                task.wait(1)
            end
        end)
        oG.Track(function()
            iD += 1
            for k, v in iz do
                v:Disconnect()
            end
            pcall(task.cancel, kA)
            onAntiGameplayPause(false)
            je()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    wR_7()
    local function wR_8()
        local wz, wA, wB, wC
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("TempoHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(wN.Settings)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/LiftACube")
        local wD = SaveManager:BuildConfigSection(wN.Settings)
        wC = function(kS, kT)
            local vI_1 = (kS == "Toggle" and Toggles or Options)[kT]
            local vH_2 = type(vI_1) == "table" and vI_1.Type == kS
            return vH_2 and vI_1 or nil
        end
        wA = function(k1, k2)
            local Type = k2.Type
            if Type == "Toggle" then
                return { idx = k1, type = "Toggle", value = k2.Value == true }
            elseif Type == "Slider" then
                return { idx = k1, type = "Slider", value = tostring(k2.Value) }
            elseif Type == "Dropdown" then
                return { idx = k1, type = "Dropdown", multi = k2.Multi == true, value = k2.Value }
            elseif Type == "Input" then
                local vP = k2.Value
                local vT = if vP then 1 else 0
                local vR = 3262 * vT + 2340 * (1 - vT)
                local vS = 1039 * vT + 688 * (1 - vT)
                if not ((vR * 604 + vS * 3070 + vR * vS) % 16777213 == 8549196) then
                    vP = ""
                end
                return { idx = k1, type = "Input", text = tostring(vP) }
            elseif Type == "ColorPicker" then
                return { idx = k1, type = "ColorPicker", value = k2.Value:ToHex(), transparency = k2.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = k1,
                    type = "KeyPicker",
                    mode = k2.Mode,
                    key = k2.Value,
                    modifiers = k2.Modifiers,
                    toggled = k2.Toggled
                }
            else
                return nil
            end
        end
        wz = function()
            local vV = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local vW = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if vW then
                        local vW_1 = wA(k, v)
                        if vW_1 then
                            vV[#vV + 1] = vW_1
                        end
                    end
                end
            end
            table.sort(vV, function(lc, ld)
                if lc.type ~= ld.type then
                    return lc.type < ld.type
                end
                return lc.idx < ld.idx
            end)
            return { objects = vV }
        end
        wB = function(lf)
            local we
            we = nil
            local wf = type(lf) ~= "table" or type(lf.idx) ~= "string" or type(lf.type) ~= "string" or SaveManager.Ignore[lf.idx]
            if wf then
                return false
            end
            we = wC(lf.type, lf.idx)
            if not we then
                return false
            end
            local wf_1 = pcall(function()
                if lf.type == "Input" then
                    if type(lf.text) ~= "string" then
                        return
                    end
                    we:SetValue(lf.text)
                elseif lf.type == "ColorPicker" then
                    we:SetValueRGB(Color3.fromHex(lf.value), lf.transparency)
                elseif lf.type == "KeyPicker" then
                    we:SetValue({ lf.key, lf.mode, lf.modifiers })
                    if lf.mode == "Toggle" and lf.toggled ~= nil then
                        we.Toggled = lf.toggled
                        we:Update()
                    end
                else
                    we:SetValue(lf.value)
                end
            end)
            return wf_1
        end
        wD:AddDivider()
        wD:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        wD:AddButton("Export Config to Clipboard", function()
            local wl_1
            local wk_1
            wk_1, wl_1 = pcall(HttpService.JSONEncode, HttpService, wz())
            if not wk_1 then
                Library:Notify("Failed to encode the config")
                return
            end
            local wk_2 = oq(setclipboard) and setclipboard
            local wm = wk_2
            if not wm then
                local wk_3 = oq(toclipboard) and toclipboard
                wm = wk_3 or nil
            end
            local wk_4 = wm
            local wm_1 = type(wk_4) ~= "function" or not pcall(wk_4, wl_1)
            if wm_1 then
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Config copied to clipboard", 6)
        end)
        wD:AddButton("Import Config from Clipboard Text", function()
            local wr_1
            local wp = Options.SaveManager_ImportSource.Value or ""
            local wp_1
            local wq = tostring(wp):match("^%s*(.-)%s*$")
            if wq == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            if #wq > 262144 then
                Library:Notify("That config is too large")
                return
            end
            wp_1, wr_1 = pcall(HttpService.JSONDecode, HttpService, wq)
            local wq_1 = not wp_1 or type(wr_1) ~= "table" or type(wr_1.objects) ~= "table"
            if wq_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            if #wr_1.objects > 2048 then
                Library:Notify("That config has too many records")
                return
            end
            local wp_2 = 0
            for i, v in ipairs(wr_1.objects) do
                if wB(v) then
                    wp_2 += 1
                end
            end
            if wp_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local wr_2 = wp_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(wp_2, wr_2), 6)
        end)
        SaveManager:LoadAutoloadConfig()
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    wR_8()
end
o4_1()
end)(...)

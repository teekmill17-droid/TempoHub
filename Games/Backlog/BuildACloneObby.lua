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
getgenv().TempoHoodSubtitle = "BUILD A CLONE OBBY"
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
local PlayerGui
local rf
local qf
local RebirthConfig
local qs
local qi
local qE
local q_
local q2
local qH
local qo
local qN
local p8
local rb
local qu
local qx
local qT
local qe
local qW
local qA
local qb
local re
local rh
local qk
local q1
local qn
local qq
local ObbyConfig
local qM
local Network
local qa
local Library
local qw
local qz
local qC
local qY
local qg
local qF
local q0
local qj
local Options
local q6
local p6
local Toggles
local q9
local p9
local qR
local rc
local qv
local function fn9()
    return qk.Character
end
local function worker5()
    while not Library.Unloaded do
        task.wait(1.5)
        if q9("AutoRebirth") then
            pcall(qz)
        end
    end
end
local function worker3()
    while not Library.Unloaded do
        task.wait(1.25)
        if q9("AutoPlace") then
            pcall(rh)
        end
    end
end
local function fn35(aI, aJ)
    return string.format('<font color="%s">%s</font>', aJ, aI)
end
local function worker2()
    while not Library.Unloaded do
        task.wait(1.5)
        if q9("AutoReplaceBetter") then
            pcall(q6)
        end
    end
end
local function fn42(ag, ah)
    if ag.mult == ah.mult then
        return ag.label < ah.label
    end
    return ag.mult < ah.mult
end
local function fn87()
    if not getgc then
        return
    end
    for k, v in getgc(true) do
        if type(v) == "table" then
            local tp = rawget(v, "RebirthCount")
            local tq = rawget(v, "Wallet")
            local tr = type(tp) == "number" and type(tq) == "number" and rawget(v, "UnlockedObbies") ~= nil
            if tr then
                qE.rebirthCount = tp
                local tp_1 = tq == qE.wallet or math.abs(tq - qE.wallet) < 1
                if tp_1 then
                    local tp_2 = rawget(v, "UnlockedObbies")
                    if type(tp_2) == "table" then
                        for k, v in tp_2 do
                            if v then
                                qE.unlocked[k] = true
                            end
                        end
                    end
                end
                break
            end
        end
    end
end
local function fn147()
    local um = tonumber(qk:GetAttribute("Wallet")) or qE.wallet
    qE.wallet = um
end
local function onOnClientEvent2(b5)
    if type(b5) == "table" then
        qE.shopRotation = b5
    end
end
local function worker7()
    local yw_1
    while not Library.Unloaded do
        local yv = not qE.busy and q9("AutoCompleteObby")
        local yv_1
        if yv then
            qE.busy = true
            yv_1, yw_1 = pcall(function()
                qa(qo())
            end)
            qE.busy = false
            if not yv_1 then
                warn("[Tempo] Auto Complete failed:", yw_1)
            end
        else
            task.wait(0.05)
        end
    end
end
local function fn195(gM)
    if fireproximityprompt then
        fireproximityprompt(gM)
        return
    end
    gM:InputHoldBegin()
    task.wait(math.max(gM.HoldDuration, 0) + 0.05)
    gM:InputHoldEnd()
end
local function fn218()
    if not getgc then
        return
    end
    for k, v in getgc(true) do
        local sW = type(v) == "table" and rawget(v, "StarterObby") == true
        if sW then
            local sW_1 = 0
            local sX = true
            for k, v in v do
                local sY_1 = type(k) ~= "string" or type(v) ~= "boolean"
                if sY_1 then
                    sX = false
                    break
                end
                sW_1 += 1
            end
            if sX and sW_1 >= 1 and sW_1 <= 20 then
                for k, v in v do
                    if v then
                        qE.unlocked[k] = true
                    end
                end
                break
            end
        end
    end
end
local function worker6()
    while not Library.Unloaded do
        task.wait(0.4)
        if q9("AutoCollectMoney") then
            pcall(qx)
        end
    end
end
local function onOnClientEvent3(b7)
    local tV = type(b7) ~= "table" or type(qE.shopRotation) ~= "table"
    if tV then
        return
    end
    local items = qE.shopRotation.items
    if type(items) ~= "table" then
        return
    end
    for k, v in items do
        if v.slot == b7.slot then
            v.remaining = b7.remaining
            break
        end
    end
end
local function fn300(fB)
    local wT = type(fB) == "table" and type(fB.characterId) == "string" and fB.characterId ~= ""
    return wT
end
local function fn314(a1)
    local so = Options[a1]
    local sp = so and so.Value
    local so_1 = {}
    if type(sp) ~= "table" then
        local sp_1 = sp ~= ""
        local sr = type(sp) == "string" and sp_1
        if sr then
            so_1[sp] = true
        end
        return so_1
    end
    for k, v in sp do
        local sp_2 = v == true
        local sq_1 = type(k) == "string" and sp_2
        if sq_1 then
            so_1[k] = true
        elseif type(v) == "string" then
            so_1[v] = true
        end
    end
    return so_1
end
local function onOnClientEvent(bZ)
    local tI = type(bZ) == "table"
    if tI then
        local tJ_1 = bZ.unlocked
        local tN = if tJ_1 then 1 else 0
        local tL = 3289 * tN + 190 * (1 - tN)
        local tM = 350 * tN + 2311 * (1 - tN)
        if not ((tL * 2046 + tM * 523 + tL * tM) % 16777213 == 8063494) then
            tJ_1 = bZ
        end
        tI = tJ_1
    end
    local tJ_2 = tI or nil
    if type(tJ_2) ~= "table" then
        return
    end
    local tJ_3 = {}
    for k, v in tJ_2 do
        if v then
            tJ_3[k] = true
        end
    end
    qE.unlocked = tJ_3
end
local function fn344()
    p8(qN, "Copied Discord invite to clipboard")
end
local function onOnClientEvent6(cj, ck)
    local ub = cj == "Wallet" and type(ck) == "number"
    if ub then
        qE.wallet = ck
    else
        local ub_1 = cj == "RebirthCount" and type(ck) == "number"
        if ub_1 then
            qE.rebirthCount = ck
        else
            local ub_2 = cj == "UnlockedObbies" and type(ck) == "table"
            if ub_2 then
                local ub_3 = {}
                for k, v in ck do
                    if v then
                        ub_3[k] = true
                    end
                end
                qE.unlocked = ub_3
            end
        end
    end
end
local function fn363()
    local uy = {}
    for k, v in qv do
        if qE.unlocked[v] then
            uy[#uy + 1] = v
        end
    end
    if #uy == 0 then
        uy[1] = "StarterObby"
    end
    return uy
end
local function fn366()
    local xx_1
    for k, v in q0() do
        local xq = Library.Unloaded or not q9("AutoReplaceBetter")
        if xq then
            return
        end
        local xq_1 = qR(v)
        if not (type(xq_1) ~= "table") then
            local xr = tonumber(xq_1.cap) or 0
            local clone2 = table.clone
            local xu = xq_1.available or {}
            local xu_3
            local xt_1 = clone2(xu)
            local xK = 1
            while xK <= xr do
                local xL = xK
                local xr_2 = Library.Unloaded or not q9("AutoReplaceBetter")
                if xr_2 then
                    return
                end
                local xr_3 = qY(xq_1, xL)
                if not not rb(xr_3) then
                    local characterId2 = xr_3.characterId
                    local xu_1 = xr_3.mutation or "Normal"
                    local xv = xr_3.level or 1
                    local xv_1
                    local xw = qw(characterId2, xu_1, xv)
                    local xs_2 = nil
                    for k, v in xt_1 do
                        local xu_2 = type(v) == "number" and v > 0
                        if xu_2 then
                            xv_1, xx_1, xu_3 = qj(k)
                            local xy = qw(xv_1, xx_1, xu_3)
                            if xy > xw and (not xs_2 or xy > xs_2.power) then
                                xs_2 = { key = k, charId = xv_1, mutation = xx_1, level = xu_3, power = xy }
                            end
                        end
                    end
                    if xs_2 then
                        local UnequipRequest = Network.UnequipRequest
                        local characterId = xr_3.characterId
                        local mutation = xr_3.mutation
                        local xx_2 = xr_3.level or 1
                        UnequipRequest:FireServer({ obbyId = v, charId = characterId, mutation = mutation, level = xx_2, slotIndex = xL })
                        task.wait(0.12)
                        Network.EquipRequest:FireServer({ obbyId = v, charId = xs_2.charId, mutation = xs_2.mutation, level = xs_2.level })
                        local key = xs_2.key
                        local xu_5 = xt_1[xs_2.key] or 1
                        xt_1[key] = xu_5 - 1
                        task.wait(0.12)
                        local xr_5 = qR(v) or xq_1
                        xq_1 = xr_5
                        local clone = table.clone
                        local xs_3 = xq_1.available or xt_1
                        xt_1 = clone(xs_3)
                    end
                end
                xK += 1
            end
        end
    end
end
local function fn415(h4)
    local DiscordGroup = h4:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = q1 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = q1 })
end
local function fn438(S, T)
    local r1 = S.UnlockCost or 0
    local r2 = T.UnlockCost
    local r6 = if r2 then 1 else 0
    local r4 = 3565 * r6 + 1888 * (1 - r6)
    local r5 = 2547 * r6 + 3509 * (1 - r6)
    if not ((r4 * 217 + r5 * 2091 + r4 * r5) % 16777213 == 15179437) then
        r2 = 0
    end
    if r1 == r2 then
        return (S.DisplayName or S.Id) < (T.DisplayName or T.Id)
    end
    return (S.UnlockCost or 0) < (T.UnlockCost or 0)
end
local function fn476()
    local vB = RebirthConfig.RequirementFor(qE.rebirthCount)
    if type(vB) ~= "number" then
        return
    end
    local vC = tonumber(qk:GetAttribute("Wallet")) or qE.wallet
    if vC < vB then
        return
    end
    Network.RebirthRequest:FireServer()
end
local function fn521(aW, aX)
    local si = Options[aW]
    if si == nil or si.Value == nil then
        return aX
    end
    return si.Value
end
local function fn567(aB, aC)
    if setclipboard then
        setclipboard(aB)
    elseif toclipboard then
        toclipboard(aB)
    end
    Library:Notify(aC)
end
local function fn576()
    if not getgc then
        return
    end
    for k, v in getgc(true) do
        local th = type(v) == "table" and type(rawget(v, "items")) == "table"
        if th then
            local th_1 = rawget(v, "rotationId") ~= nil or rawget(v, "nextRestockClock") ~= nil
            if th_1 then
                qE.shopRotation = v
                break
            end
        end
    end
end
local function fn584()
    Library.ScreenGui.Parent = PlayerGui
end
local function fn602(gH)
    local xU_1
    local xT_1
    if type(gH) ~= "string" then
        return nil
    end
    xT_1, xU_1 = gH:match("%$([%d%,%.]+)([KMBTkmbt]?)")
    if not xT_1 then
        return nil
    end
    local xT_2 = xT_1:gsub(",", "")
    local xV = tonumber(xT_2)
    if not xV then
        return nil
    end
    if xU_1 ~= "" then
        local xT_3 = qu[xU_1] or 1
        xV *= xT_3
    end
    return xV
end
local function fn605()
    return PlayerGui
end
local function worker4()
    while not Library.Unloaded do
        task.wait(2)
        if q9("AutoBuyCharacters") then
            pcall(q2)
        end
    end
end
local function worker()
    while not Library.Unloaded do
        task.wait(1.25)
        if q9("AutoUnlockSlots") then
            pcall(qT)
        end
    end
end
local function fn655()
    local PlayerPlots = qs:FindFirstChild("PlayerPlots")
    if not PlayerPlots then
        return nil
    end
    local up = PlayerPlots:FindFirstChild("Plot_" .. tostring(qk.UserId))
    local uq = up and up:IsA("Model") and up:GetAttribute("OwnerUserId") == qk.UserId
    if uq then
        return up
    end
    for i, child in PlayerPlots:GetChildren() do
        local uo_1 = child:IsA("Model") and child:GetAttribute("OwnerUserId") == qk.UserId
        if uo_1 then
            return child
        end
    end
    return nil
end
local function fn717()
    local PlayerPlots = qs:FindFirstChild("PlayerPlots")
    if not PlayerPlots then
        return
    end
    for i, child in PlayerPlots:GetChildren() do
        local sI_1 = child:IsA("Model") and child:GetAttribute("OwnerUserId") == qk.UserId
        if sI_1 then
            local Obbies = child:FindFirstChild("Obbies")
            if Obbies then
                for i, child in Obbies:GetChildren() do
                    qE.unlocked[child.Name] = true
                end
            end
            break
        end
    end
end
local function onOnClientEvent4(cd)
    local t4 = type(cd) == "table" and type(cd.rebirthCount) == "number"
    if t4 then
        qE.rebirthCount = cd.rebirthCount
    elseif type(cd) == "number" then
        qE.rebirthCount = cd
    end
end
local function onOnClientEvent5(cg)
    local t6 = type(cg) == "table" and cg.ok and type(cg.rebirthCount) == "number"
    if t6 then
        qE.rebirthCount = cg.rebirthCount
    end
end
local function fn794()
    local w0 = qC("PlaceLogic", qf)
    for k, v in q0() do
        local w1 = Library.Unloaded or not q9("AutoPlace")
        if w1 then
            return
        end
        local w1_1 = qR(v)
        if not (type(w1_1) ~= "table") then
            local w2 = tonumber(w1_1.cap) or 0
            local w3 = 0
            local xh = 1
            while xh <= w2 do
                local xi = xh
                if not rb(qY(w1_1, xi)) then
                    w3 += 1
                end
                xh += 1
            end
            if not (w3 <= 0) then
                local w2_1 = qW(w1_1.available, nil)
                if w0 == p9 then
                    table.sort(w2_1, function(f4, f5)
                        return f4.charId < f5.charId
                    end)
                end
                for k, v2 in w2_1 do
                    local w1_2 = w3 <= 0 or Library.Unloaded or not q9("AutoPlace")
                    if w1_2 then
                        break
                    end
                    local w1_3 = v2.count
                    while true do
                        if w1_3 > 0 and w3 > 0 then
                            Network.EquipRequest:FireServer({ obbyId = v, charId = v2.charId, mutation = v2.mutation, level = v2.level })
                            w1_3 -= 1
                            w3 -= 1
                            task.wait(0.12)
                            continue
                        end
                        break
                    end
                end
            end
        end
    end
end
local function fn795()
    local sF = qi()
    local sG = sF and sF:FindFirstChild("HumanoidRootPart")
    return sG
end
local function fn809(aQ)
    if Library.Unloaded then
        return false
    end
    local sc = Toggles[aQ]
    return sc ~= nil and sc.Value == true
end
local function fn842()
    local yE = hookfunction ~= nil
    local yF = hookmetamethod ~= nil
    local yG = getrawmetatable ~= nil
    local yH = setrawmetatable ~= nil
    local yI = getgc ~= nil
    local yJ = getgenv ~= nil
    local yK = getreg ~= nil
    local yL = getconnections ~= nil
    local yM = firesignal ~= nil
    local yN = getcallbackvalue ~= nil
    local yO = setclipboard ~= nil
    local yP = getcustomasset ~= nil
    local yQ = getnamecallmethod ~= nil
    local yR = isexecutorclosure ~= nil
    local yS = fireproximityprompt ~= nil
    local yT = firetouchinterest ~= nil
    local yU = WebSocket ~= nil
    local yV = readfile ~= nil
    local yW = writefile ~= nil
    local yY = (request or http_request) ~= nil
    local y_ = (debug and debug.getupvalues) ~= nil
    local y1 = (debug and debug.setupvalue) ~= nil
    local y2 = 0
    local y3 = { yE, yF, yG, yH, yI, yJ, yK, yL, yM, yN, yO, yP, yQ, yR, yS, yT, yU, yV, yW, yY, y_, y1 }
    for i, v in ipairs(y3) do
        if v then
            y2 += 1
        end
    end
    local yE_1 = y2 / #y3
    if yE_1 >= 0.9 then
        return qM("Full Support", qq)
    elseif yE_1 >= 0.6 then
        return qM("Half Support", qb)
    else
        return qM("Low Support", re)
    end
end
local function fn870()
    local vr = qH()
    local vs = q_()
    if not (vr and vs and firetouchinterest) then
        return
    end
    for i, descendant in vr:GetDescendants() do
        local vr_1 = Library.Unloaded or not q9("AutoCollectMoney")
        if vr_1 then
            break
        end
        local vr_2 = descendant.Name == "CollectTouch" and descendant:IsA("BasePart")
        if vr_2 then
            local vs_1 = q_()
            if not vs_1 then
                break
            end
            pcall(firetouchinterest, vs_1, descendant, 0)
            pcall(firetouchinterest, vs_1, descendant, 1)
        end
    end
end
local function fn909(aL, aM, aN)
    return string.format("<b>%s</b> %s %s", aL, qM("-", "#5a6070"), qM(aM, aN))
end
local function fn916(ay)
    qA[#qA + 1] = ay
    return ay
end
local function fn923()
    local uI_1
    local uG = q0()
    local uH = qC("ObbyMode", qg)
    local uH_1
    if uH == qn then
        return uG[math.random(1, #uG)]
    elseif uH == qg then
        uI_1, uH_1 = uG[1], -1
        for k, v in uG do
            local uG_1 = ObbyConfig[v]
            local uJ = uG_1
            if uJ then
                uJ = uG_1.CashReward or uG_1.CashPerLap or 0
            end
            local uG_3 = uJ or 0
            if uG_3 > uH_1 then
                uH_1 = uG_3
                uI_1 = v
            end
        end
        return uI_1
    else
        local uG_4 = rc("ObbyPriority")
        for k in uG_4 do
            local uG_5 = qe[k]
            if uG_5 and qE.unlocked[uG_5] then
                return uG_5
            end
        end
        for k, v in qv do
            if qE.unlocked[v] then
                return v
            end
        end
        return "StarterObby"
    end
end
local function fn924()
    local sC = qi()
    local sD = sC and sC:FindFirstChildOfClass("Humanoid")
    return sD
end
local function fn925()
    local vK = qE.shopRotation
    local vL = type(vK) ~= "table" or type(vK.items) ~= "table"
    if vL then
        qF()
        vK = qE.shopRotation
    end
    local vL_1 = type(vK) ~= "table"
    local vS = if vL_1 then 1 else 0
    local vQ = 1641 * vS + 2738 * (1 - vS)
    local vR = 862 * vS + 796 * (1 - vS)
    if not ((vQ * 4018 + vR * 1272 + vQ * vR) % 16777213 == 9104544) then
        vL_1 = type(vK.items) ~= "table"
    end
    if vL_1 then
        return
    end
    local vL_2 = rc("BuyCharacters")
    if next(vL_2) == nil then
        return
    end
    local vM = {}
    for k in vL_2 do
        local vL_3 = p6[k]
        if vL_3 then
            vM[vL_3] = true
        end
    end
    local vL_4 = tonumber(qk:GetAttribute("Wallet")) or qE.wallet
    local vN = {}
    for k, v in vK.items do
        local vK_1 = vM[v.charId] and v.locked ~= true
        if vK_1 then
            vK_1 = (v.remaining or 0) > 0
        end
        if vK_1 then
            vK_1 = type(v.cashPrice) == "number"
        end
        if vK_1 then
            vK_1 = v.cashPrice <= vL_4
        end
        if vK_1 then
            vN[#vN + 1] = v
        end
    end
    table.sort(vN, function(em, en)
        local vF = rf[em.charId] or 0
        local vF_1 = rf[en.charId] or 0
        if vF == vF_1 then
            return (em.cashPrice or 0) > (en.cashPrice or 0)
        end
        return vF > vF_1
    end)
    for k, v in vN do
        local vK_2 = Library.Unloaded or not q9("AutoBuyCharacters")
        if vK_2 then
            break
        end
        Network.ShopBuyRequest:FireServer(v.slot)
        task.wait(0.35)
        local vK_3 = (tonumber(qk:GetAttribute("Wallet")))
    end
end
local function fn939(fE, fF)
    local wV = fE and fE.slots
    if type(wV) ~= "table" then
        return nil
    end
    local wV_1 = wV[fF]
    local w_ = if wV_1 then 1 else 0
    local wY = 3339 * w_ + 497 * (1 - w_)
    local wZ = 1326 * w_ + 1044 * (1 - w_)
    if not ((wY * 3924 + wZ * 2383 + wY * wZ) % 16777213 == 3912395) then
        wV_1 = wV[tostring(fF)]
    end
    return wV_1
end
p6 = nil
p8 = nil
p9 = nil
qa = nil
qb = nil
PlayerGui = nil
qe = nil
qf = nil
qg = nil
qi = nil
qj = nil
qk = nil
qn = nil
qo = nil
qq = nil
qs = nil
qu = nil
qv = nil
qw = nil
qx = nil
qz = nil
qA = nil
qC = nil
qE = nil
qF = nil
qH = nil
Options = nil
qM = nil
qN = nil
Toggles = nil
qR = nil
local p4, p5, p7, qd, qh, ql, qm, qp, qr, qt, qy, qB, UpgradeConfig, qG, qJ, qK, TrainingConfig, qP, qQ
qT = nil
qW = nil
RebirthConfig = nil
qY = nil
q_ = nil
q0 = nil
q1 = nil
q2 = nil
q6 = nil
ObbyConfig = nil
q9 = nil
Network = nil
rb = nil
rc = nil
Library = nil
re = nil
rf = nil
local rg
rh = nil
local qS, SaveManager, qV, qZ, q3, q4, q5, q8
local rm_3
local rk_2, rk_6, Window
local rj_1
p4, rj_1, q8, q5, qZ, qV, qP, qJ, qB, qs, qk, PlayerGui = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local ri = 33
repeat
    local rk_1 = (ri * 2 + 0) % 5 + 1
    if rk_1 <= 3 then
        if rk_1 <= 2 then
            if rk_1 <= 1 then
                local rl_1 = { "udzzqdg", "punffui", "etkkgt", "cna", "euwjusntk", "waqxttj", "adipvwuyoms" }
                local Dw = ri
                local rm_1 = rl_1[Dw % 7 + 1]
                if rm_1:len() >= rm_1:reverse():rep(Dw % 3 + 2):len() then
                    qk = PlayerGui:WaitForChild("PlayerGui")
                else
                    PlayerGui = qk:WaitForChild("PlayerGui")
                end
                ri = (ri + 3) % 40
            else
                local rl_2 = { "cfejdclut", "bszuzl", "huvjkj", "njhlb", "qixjvxkfomw", "gwbgmq", "qssteprxh", "uqul", "tmqcg" }
                local DT = ri
                local rm_2 = rl_2[DT % 9 + 1]
                if rm_2:len() >= rm_2:reverse():rep(DT % 3 + 2):len() then
                    q8 = game:GetService("Players")
                else
                    p4 = game:GetService("Players")
                end
                ri = (ri + 33) % 40
            end
        else
            if (ri * 3 + 9) * 17 % 4 == ((ri * 3 + 9) * 17 + 12) % 4 then
                rj_1 = game:GetService("ReplicatedStorage")
                q8 = game:GetService("RunService")
                q5 = game:GetService("UserInputService")
                qZ = game:GetService("VirtualUser")
                qV = game:GetService("HttpService")
            else
                q5 = game:GetService("ReplicatedStorage")
                rj_1 = game:GetService("RunService")
                qV = game:GetService("UserInputService")
                q8 = game:GetService("VirtualUser")
                qZ = game:GetService("HttpService")
            end
            ri = (ri + 8) % 40
        end
    elseif rk_1 <= 4 then
        local DJ = bit32.rrotate(bit32.bxor(bit32.lrotate(ri, 27), string.byte(tostring(rj_1))), 20)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(DJ, 3117840207), 2990716455), (bit32.bxor(bit32.band(DJ, 1177127088), 378676556))), 2990716455), 378676556) == DJ then
            qP = game:GetService("GuiService")
            qJ = game:GetService("TeleportService")
            qB = game:GetService("CoreGui")
            qs = game:GetService("Workspace")
        else
            qs = game:GetService("GuiService")
            qP = game:GetService("TeleportService")
            qJ = game:GetService("CoreGui")
            qB = game:GetService("Workspace")
        end
        ri = (ri + 13) % 40
    else
        local Dv = bit32.rrotate(bit32.bxor(bit32.lrotate(ri, 31), string.byte(tostring(qs))), 5)
        if bit32.bxor(bit32.lrotate(bit32.bxor(Dv, 2697303253), 30), 1748067637) ~= bit32.lrotate(Dv, 30) then
            p4 = qk.LocalPlayer
        else
            qk = p4.LocalPlayer
        end
        ri = (ri + 33) % 40
    end
until (ri * 17 + 8) % 40 == 19
if getgenv then
    rg, rk_2 = nil, nil
    local ri_1 = 3
    repeat
        if (ri_1 * 1 + 1) % 2 + 1 <= 1 then
            if ri_1 * 89602703 + 3 + 4 <= ri_1 * 89602703 + 3 + 4 + 3 then
                getgenv().gethui = fn605
                rg = getgenv().__TempoBuildACloneObbyLib
            else
                getgenv().gethui = fn605
                rk_2 = getgenv().__TempoBuildACloneObbyLib
            end
            ri_1 = (ri_1 + 5) % 8
        else
            if ri_1 * 95565563 + 11 + 7 <= ri_1 * 95565563 + 11 + 7 + 3 then
                rk_2 = rg
            else
                rg = rk_2
            end
            ri_1 = (ri_1 + 5) % 8
        end
    until (ri_1 * 5 + 2) % 8 == 3
    if rk_2 then
        rk_2 = rg.Unload
    end
    if rk_2 then
        pcall(function()
            rg:Unload()
        end)
    end
end
pcall(function()
    gethui = function()
        return PlayerGui
    end
end)
if setthreadidentity then
    setthreadidentity(8)
end
qS, qN, qG, qy, qq, qh, qb, p5, re, Network, ObbyConfig, RebirthConfig, qQ, TrainingConfig, UpgradeConfig, qv, rm_3, qe = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
qS = "Build A Clone Obby"
qN = "https://discord.gg/K7Qxnxkk46"
qG = "https://discord.gg/K7Qxnxkk46"
qy = "https://tempohub.shop"
qq = "#7fd47f"
qh = "#6ec1ff"
qb = "#e8a34d"
p5 = "#8b93a3"
re = "#e05a5a"
Network = require(rj_1:WaitForChild("Shared"):WaitForChild("Network"))
ObbyConfig = require(rj_1:WaitForChild("Configs"):WaitForChild("ObbyConfig"))
local CharacterConfig = require(rj_1:WaitForChild("Configs"):WaitForChild("CharacterConfig"))
RebirthConfig = require(rj_1:WaitForChild("Configs"):WaitForChild("RebirthConfig"))
if ((not rm_3 or RebirthConfig) and (not rm_3 and p5) or (UpgradeConfig or RebirthConfig or false)) and (("#8b93a3" or (p5 or not rm_3)) and (false or rm_3 or (UpgradeConfig or UpgradeConfig))) or not (((not rm_3 or RebirthConfig) and (not rm_3 and p5) or (UpgradeConfig or RebirthConfig or false)) and (("#8b93a3" or (p5 or not rm_3)) and (false or rm_3 or (UpgradeConfig or UpgradeConfig)))) then
    qQ = require(rj_1:WaitForChild("Configs"):WaitForChild("MutationConfig"))
    TrainingConfig = require(rj_1:WaitForChild("Configs"):WaitForChild("TrainingConfig"))
else
    rj_1 = require(TrainingConfig:WaitForChild("Configs"):WaitForChild("MutationConfig"))
    qQ = require(TrainingConfig:WaitForChild("Configs"):WaitForChild("TrainingConfig"))
end
UpgradeConfig = require(rj_1:WaitForChild("Configs"):WaitForChild("UpgradeConfig"))
qv = {}
local rm_4 = {}
qe = {}
local rk_3 = {}
local rn = {}
for k, v in ObbyConfig do
    rn[#rn + 1] = v
end
local ri_2 = 2
repeat
    if (ri_2 * 3 + 4) * 9 % 4 == ((ri_2 * 3 + 4) * 9 + 3) % 4 then
        table.sort(rn, fn438)
    else
        table.sort(rn, fn438)
    end
    ri_2 = (ri_2 + 1) % 4
until (ri_2 * 1 + 0) % 4 == 3
for k, v in rn do
    local ri_3 = v.DisplayName or v.Id
    qv[#qv + 1] = v.Id
    rm_4[#rm_4 + 1] = ri_3
    qe[ri_3] = v.Id
    rk_3[v.Id] = ri_3
end
rn, p6, rf = nil, nil, nil
local ri_4 = 7
repeat
    if (ri_4 * 1 + 1) % 2 + 1 <= 1 then
        local rj_4 = { "krgvghz", "eayizwuoir", "cohdp", "hvp", "ixavohvgel", "xqtx", "hjnmvoggqq", "cfvexjkb" }
        if rj_4[(ri_4 * 8 + 79) % 8 + 1] <= rj_4[(ri_4 * 8 + 79) % 8 + 1] then
            rn = {}
            p6 = {}
        else
            p6 = {}
            rn = {}
        end
        ri_4 = (ri_4 + 3) % 8
    else
        local rj_5 = (vector.create((ri_4 * 2 + 2) % 11 + 1, (ri_4 * 3 + 12) % 13 + 1, (ri_4 * 9 + 8) % 17 + 1))
        local rk_4 = (vector.create((ri_4 * 5 + 4) % 11 + 1, (ri_4 * 4 + 9) % 13 + 1, (ri_4 * 11 + 14) % 17 + 1))
        local CZ = vector.cross(rj_5, rk_4)
        local C_ = vector.dot(rj_5, rk_4)
        if vector.dot(CZ, CZ) + C_ * C_ == vector.dot(rj_5, rj_5) * vector.dot(rk_4, rk_4) + 3 then
            rn = {}
        else
            rf = {}
        end
        ri_4 = (ri_4 + 5) % 8
    end
until (ri_4 * 7 + 3) % 8 == 4
local rj_6 = {}
for k, v in CharacterConfig do
    local ri_5 = #rj_6 + 1
    local rk_5 = v.DisplayName or k
    local rl_5 = v.Multiplier or 0
    rj_6[ri_5] = { id = k, label = rk_5, mult = rl_5 }
end
table.sort(rj_6, fn42)
for k, v in rj_6 do
    rn[#rn + 1] = v.label
    p6[v.label] = v.id
    rf[v.id] = v.mult
end
qn, qg, Library = nil, nil, nil
qn = "Random"
qg = "Best Unlocked"
local rl_6 = { "Priority", qn, qg }
Library = getgenv().Library
pcall(fn584)
if getgenv then
    getgenv().__TempoBuildACloneObbyLib = Library
end
SaveManager, Toggles, Options, qA, qt, p8, q1, qM, qp, q9, qC, rc, qi, p7, q_ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
qA = {}
qt = fn916
p8 = fn567
q1 = fn344
qM = fn35
qp = fn909
q9 = fn809
qC = fn521
rc = fn314
qi = fn9
p7 = fn924
q_ = fn795
local ro = {}
local ri_6 = tonumber(qk:GetAttribute("Wallet")) or 0
qE, qf, p9, qu, rk_6, qm, qF, qH, q0, qo, qa, qx, qz, q2, qj, qw, qR, qW, rb, qY, rh, q6, ql, q3, qT = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
qE = { unlocked = ro, shopRotation = nil, rebirthCount = 0, wallet = ri_6, busy = false }
local rp = fn717
local saveManager_ImportSourceLoop = fn218
qF = fn576
local noClipLoop = fn87
rp()
task.defer(saveManager_ImportSourceLoop)
task.defer(qF)
task.defer(noClipLoop)
qt(Network.ObbyUnlockSync.OnClientEvent:Connect(onOnClientEvent))
qt(Network.ShopRotation.OnClientEvent:Connect(onOnClientEvent2))
qt(Network.ShopSlotUpdate.OnClientEvent:Connect(onOnClientEvent3))
qt(Network.RebirthState.OnClientEvent:Connect(onOnClientEvent4))
qt(Network.RebirthResult.OnClientEvent:Connect(onOnClientEvent5))
qt(Network.DataChanged.OnClientEvent:Connect(onOnClientEvent6))
qt(qk:GetAttributeChangedSignal("Wallet"):Connect(fn147))
qH = fn655
q0 = fn363
qo = fn923
qa = function(dd)
    local vb
    local u8
    local va
    u8 = nil
    va = nil
    vb = nil
    local u9
    local vc = qH()
    if not vc then
        return false
    end
    local Obbies = vc:FindFirstChild("Obbies")
    local vc_1 = Obbies and Obbies:FindFirstChild(dd)
    if not vc_1 then
        return false
    end
    local Start = vc_1:FindFirstChild("Start")
    local End = vc_1:FindFirstChild("End")
    u9 = q_()
    local vd_2 = p7()
    if not (Start and End and u9 and vd_2) then
        return false
    end
    pcall(function()
        Network.RunLeaveRequest:FireServer()
    end)
    vd_2.PlatformStand = false
    vb = false
    va = false
    u8 = false
    local connection3 = Network.RunStarted.OnClientEvent:Connect(function()
        u8 = true
    end)
    local connection2 = Network.RunFinished.OnClientEvent:Connect(function()
        va = true
    end)
    local connection = Network.RunReset.OnClientEvent:Connect(function()
        vb = true
    end)
    local function vh(dA)
        u9 = q_()
        if not u9 or not dA then
            return
        end
        u9.CFrame = dA.CFrame * CFrame.new(0, 3.2, 0)
        u9.AssemblyLinearVelocity = Vector3.zero
        if firetouchinterest then
            pcall(firetouchinterest, u9, dA, 0)
            pcall(firetouchinterest, u9, dA, 1)
        end
    end
    vh(Start)
    local vi = os.clock()
    while true do
        local vj = not u8 and not va and not vb and os.clock() - vi < 2 and not Library.Unloaded and q9("AutoCompleteObby")
        if vj then
            vh(Start)
            task.wait()
            continue
        end
        break
    end
    local vc_3 = Library.Unloaded or not q9("AutoCompleteObby")
    if vc_3 then
        connection3:Disconnect()
        connection2:Disconnect()
        connection:Disconnect()
        return false
    end
    vh(End)
    local vc_4 = os.clock()
    while true do
        local vi_1 = not va and os.clock() - vc_4 < 0.75 and not Library.Unloaded and q9("AutoCompleteObby")
        if vi_1 then
            vh(End)
            task.wait()
            continue
        end
        break
    end
    connection3:Disconnect()
    connection2:Disconnect()
    connection:Disconnect()
    return va == true
end
qx = fn870
if (qa or not rk_6) and (false and not qm) or qR and not qR and (not qm or qm) or (not qm or qm) and (not qm and qR) and (rk_6 or not qR or false) or not ((qa or not rk_6) and (false and not qm) or qR and not qR and (not qm or qm) or (not qm or qm) and (not qm and qR) and (rk_6 or not qR or false)) then
    qz = fn476
else
    qR = fn476
end
q2 = fn925
qj = function(ex)
    local v9, wa
    local wc_1
    local wb_1
    v9, wc_1, wb_1 = string.match(ex, "^([^|]+)|(.+)|(%d+)$")
    if wc_1 then
        wa = v9
        pcall(function()
            wa = qQ.Normalize(v9)
        end)
        local wd = wa
        local wi = if wd then 1 else 0
        local wg = 4000 * wi + 897 * (1 - wi)
        local wh = 2233 * wi + 3864 * (1 - wi)
        if not ((wg * 2776 + wh * 334 + wg * wh) % 16777213 == 4004609) then
            wd = v9
        end
        local we = tonumber(wb_1) or 1
        return wc_1, wd, we
    end
    local wb_2 = string.match(ex, "^Gold|(.+)$")
    if wb_2 then
        return wb_2, "Gold", 1
    end
    return ex, "Normal", 1
end
qw = function(eI, eJ, eK)
    local wo, wp, wq
    wq = eI
    pcall(function()
        wq = TrainingConfig.BaseId(eI)
    end)
    local ws = rf[wq] or rf[eI]
    local ww = if ws then 1 else 0
    local wu = 1607 * ww + 1334 * (1 - ww)
    local wv = 1595 * ww + 2649 * (1 - ww)
    if not ((wu * 702 + wv * 3259 + wu * wv) % 16777213 == 8889384) then
        ws = 0
    end
    wo = 1
    local wr_1 = ws
    pcall(function()
        local wj = qQ.GetMultiplier(eJ) or 1
        wo = wj
    end)
    wp = 1
    pcall(function()
        local CharacterLevelMultiplier = UpgradeConfig.CharacterLevelMultiplier
        local wm = eK or 1
        local wl_1 = CharacterLevelMultiplier(wm) or 1
        wp = wl_1
    end)
    return wr_1 * wo * wp
end
qR = function(e3)
    local wz
    wz = nil
    wz = nil
    local connection = Network.EquipState.OnClientEvent:Connect(function(e6)
        local wx = type(e6) == "table" and e6.obbyId == e3
        if wx then
            wz = e6
        end
    end)
    Network.EquipStateRequest:FireServer(e3)
    local wB = os.clock() + 2
    while true do
        local wC = not wz and os.clock() < wB and not Library.Unloaded
        if wC then
            task.wait()
            continue
        end
        break
    end
    connection:Disconnect()
    return wz
end
qW = function(ff, fg)
    local wK_1
    local wH = {}
    if type(ff) ~= "table" then
        return wH
    end
    local wI = type(fg) == "table" and next(fg) ~= nil
    local wI_2
    for k, v in ff do
        local wG, wF
        local wI_1 = type(v) == "number" and v > 0
        if wI_1 then
            wG, wK_1, wI_2 = qj(k)
            wF = wG
            pcall(function()
                wF = TrainingConfig.BaseId(wG)
            end)
            if not wI or fg[wF] or fg[wG] then
                wH[#wH + 1] = { key = k, charId = wG, mutation = wK_1, level = wI_2, count = v, power = qw(wG, wK_1, wI_2) }
            end
        end
    end
    table.sort(wH, function(fy, fz)
        if fy.power == fz.power then
            return fy.charId < fz.charId
        end
        return fy.power > fz.power
    end)
    return wH
end
rb = fn300
qY = fn939
qf = "Place Best"
p9 = "Place Anything"
rh = fn794
q6 = fn366
qu = {
    K = 1000,
    k = 1000,
    M = 1000000,
    m = 1000000,
    B = 1000000000,
    b = 1000000000,
    T = 1000000000000,
    t = 1000000000000
}
ql = fn602
if qY and p9 and (qR and qR) and (qR or p9 or (qY or not rh)) or not (qY and p9 and (qR and qR) and (qR or p9 or (qY or not rh))) then
    q3 = fn195
    qT = function()
        local x8, x9, ya
        if qE.busy then
            return
        end
        local x4 = qH()
        local x3 = q_()
        if not (x4 and x3) then
            return
        end
        local x5_4 = tonumber(qk:GetAttribute("Wallet")) or qE.wallet
        local x6 = {}
        local x7 = x5_4
        for k, v in q0() do
            local Obbies = x4:FindFirstChild("Obbies")
            x8 = Obbies and Obbies:FindFirstChild(v)
            local x5_6 = x8
            if x8 then
                x8 = x5_6:FindFirstChild("CharacterSlots")
            end
            x5_4 = x8
            if not not x5_4 then
                for i, child in x5_4:GetChildren() do
                    x5_4 = tonumber(child.Name:match("^Slot(%d+)$"))
                    if not not x5_4 then
                        x8 = child:GetAttribute("Unlocked") == true or child:GetAttribute("PaidSlot") == true
                        if not x8 then
                            x8 = child:FindFirstChild("BuySlotPrompt", true)
                            x9 = x8 and x8:IsA("ProximityPrompt") and x8.Enabled
                            if not not x9 then
                                x9 = ql(x8.ActionText) or 0
                                ya = x9
                                if not (ya > x7) then
                                    x6[#x6 + 1] = { obbyId = v, index = x5_4, prompt = x8, part = x8.Parent, price = ya }
                                end
                            end
                        end
                    end
                end
            end
        end
        table.sort(x6, function(hb, hc)
            if hb.obbyId == hc.obbyId then
                return hb.index < hc.index
            end
            return hb.obbyId < hc.obbyId
        end)
        local yj = false
        for k, v in x6 do
            local x2
            local yi = 30
            while true do
                if yi < 23 then
                    if yi < 11 then
                        if yi < 5 then
                            if yi < 2 then
                                if yi < 1 then
                                    break
                                end
                                yi = 0
                            elseif yi < 3 then
                                yi = if ya then 12 else 44
                            elseif yi < 4 then
                                yi = 36
                            else
                                x5_4 = x4.Enabled
                                yi = 39
                            end
                        elseif yi < 8 then
                            if yi < 6 then
                                x4 = qE.busy
                                yi = 9
                            elseif yi < 7 then
                                yi = 32
                            else
                                yi = if not x8 then 1 else 41
                            end
                        elseif yi < 9 then
                            x3.CFrame = x8
                            x3.AssemblyLinearVelocity = Vector3.zero
                            yi = 13
                        elseif yi < 10 then
                            yi = if x4 then 40 else 46
                        else
                            x6 = x5_4:GetAttribute("Unlocked") == true
                            yi = 34
                        end
                    elseif yi < 17 then
                        if yi < 14 then
                            if yi < 12 then
                                yi = if v.price > x4 then 15 else 21
                            elseif yi < 13 then
                                yi = 32
                            else
                                qE.busy = false
                                task.wait(0.2)
                                yi = 0
                            end
                        elseif yi < 15 then
                            ya = x5_4:GetAttribute("Unlocked") ~= true
                            yi = 37
                        elseif yi < 16 then
                            yi = 0
                        else
                            task.wait()
                            yi = 18
                        end
                    elseif yi < 20 then
                        if yi < 18 then
                            x4 = not q9("AutoUnlockSlots")
                            yi = 27
                        elseif yi < 19 then
                            yi = 3
                        else
                            ya = not q9("AutoUnlockSlots")
                            yi = 2
                        end
                    elseif yi < 21 then
                        yi = if ya then 42 else 16
                    elseif yi < 22 then
                        x4 = v.prompt
                        x5_4 = x4
                        yi = if x5_4 then 24 else 23
                    else
                        x5_4 = x4:FindFirstAncestorWhichIsA("Model")
                        x6 = not x5_4
                        yi = if x6 then 34 else 10
                    end
                elseif yi < 35 then
                    if yi < 29 then
                        if yi < 26 then
                            if yi < 24 then
                                yi = if x5_4 then 4 else 39
                            elseif yi < 25 then
                                x5_4 = x4.Parent
                                yi = 23
                            else
                                x8 = x6:IsA("BasePart")
                                yi = 7
                            end
                        elseif yi < 27 then
                            ya = Library.Unloaded
                            yi = if ya then 2 else 19
                        elseif yi < 28 then
                            yi = if x4 then 9 else 5
                        else
                            x4 = qE.wallet
                            yi = 11
                        end
                    elseif yi < 32 then
                        if yi < 30 then
                            x6 = v.part
                            x8 = x6
                            yi = if x8 then 25 else 7
                        elseif yi < 31 then
                            x4 = Library.Unloaded
                            yi = if x4 then 27 else 17
                        else
                            qE.busy = false
                            return
                        end
                    elseif yi < 33 then
                        x3 = q_()
                        yi = if x3 then 8 else 13
                    elseif yi < 34 then
                        yi = 0
                    else
                        local yu = if x6 then 1 else 0
                        local ys = 2469 * yu + 3089 * (1 - yu)
                        local yt = 2264 * yu + 3981 * (1 - yu)
                        yi = if (ys * 896 + yt * 528 + ys * yt) % 16777213 == 8997432 then 43 else 29
                    end
                elseif yi < 41 then
                    if yi < 38 then
                        if yi < 36 then
                            x8 = x3.CFrame
                            x2 = x6.CFrame * CFrame.new(0, 3, 0)
                            x6 = function()
                                x3 = q_()
                                if not x3 then
                                    return
                                end
                                x3.CFrame = x2
                                x3.AssemblyLinearVelocity = Vector3.zero
                            end
                            x6()
                            task.wait(0.1)
                            q3(x4)
                            x9 = os.clock()
                            yi = 3
                        elseif yi < 37 then
                            ya = os.clock() - x9 < 1.25
                            yi = if ya then 14 else 37
                        else
                            yi = if ya then 26 else 6
                        end
                    elseif yi < 39 then
                        ya = os.clock() - x9 < 0.45
                        yi = 20
                    elseif yi < 40 then
                        yi = if not x5_4 then 33 else 22
                    else
                        return
                    end
                elseif yi < 44 then
                    if yi < 42 then
                        qE.busy = true
                        x3 = q_()
                        yi = if not x3 then 31 else 35
                    elseif yi < 43 then
                        q3(x4)
                        yi = 16
                    else
                        yi = 0
                    end
                elseif yi < 45 then
                    x6()
                    ya = os.clock() - x9 > 0.35
                    yi = if ya then 38 else 20
                elseif yi < 46 then
                    yj = true
                    yi = 0
                else
                    x4 = (tonumber(qk:GetAttribute("Wallet")))
                    yi = if x4 then 11 else 28
                end
            end
            if yj then
                break
            end
        end
    end
else
    qT = fn195
    q3 = function()
        local x8, x9, ya
        if qE.busy then
            return
        end
        local x4 = qH()
        local x3 = q_()
        if not (x4 and x3) then
            return
        end
        local x5_1 = tonumber(qk:GetAttribute("Wallet")) or qE.wallet
        local x6 = {}
        local x7 = x5_1
        for k, v in q0() do
            local Obbies = x4:FindFirstChild("Obbies")
            x8 = Obbies and Obbies:FindFirstChild(v)
            local x5_3 = x8
            if x8 then
                x8 = x5_3:FindFirstChild("CharacterSlots")
            end
            x5_1 = x8
            if not not x5_1 then
                for i, child in x5_1:GetChildren() do
                    x5_1 = tonumber(child.Name:match("^Slot(%d+)$"))
                    if not not x5_1 then
                        x8 = child:GetAttribute("Unlocked") == true or child:GetAttribute("PaidSlot") == true
                        if not x8 then
                            x8 = child:FindFirstChild("BuySlotPrompt", true)
                            x9 = x8 and x8:IsA("ProximityPrompt") and x8.Enabled
                            if not not x9 then
                                x9 = ql(x8.ActionText) or 0
                                ya = x9
                                if not (ya > x7) then
                                    x6[#x6 + 1] = { obbyId = v, index = x5_1, prompt = x8, part = x8.Parent, price = ya }
                                end
                            end
                        end
                    end
                end
            end
        end
        table.sort(x6, function(hb, hc)
            if hb.obbyId == hc.obbyId then
                return hb.index < hc.index
            end
            return hb.obbyId < hc.obbyId
        end)
        local yj = false
        for k, v in x6 do
            local x2
            local yi = 30
            while true do
                if yi < 23 then
                    if yi < 11 then
                        if yi < 5 then
                            if yi < 2 then
                                if yi < 1 then
                                    break
                                end
                                yi = 0
                            elseif yi < 3 then
                                yi = if ya then 12 else 44
                            elseif yi < 4 then
                                yi = 36
                            else
                                x5_1 = x4.Enabled
                                yi = 39
                            end
                        elseif yi < 8 then
                            if yi < 6 then
                                x4 = qE.busy
                                yi = 9
                            elseif yi < 7 then
                                yi = 32
                            else
                                yi = if not x8 then 1 else 41
                            end
                        elseif yi < 9 then
                            x3.CFrame = x8
                            x3.AssemblyLinearVelocity = Vector3.zero
                            yi = 13
                        elseif yi < 10 then
                            yi = if x4 then 40 else 46
                        else
                            x6 = x5_1:GetAttribute("Unlocked") == true
                            yi = 34
                        end
                    elseif yi < 17 then
                        if yi < 14 then
                            if yi < 12 then
                                yi = if v.price > x4 then 15 else 21
                            elseif yi < 13 then
                                yi = 32
                            else
                                qE.busy = false
                                task.wait(0.2)
                                yi = 0
                            end
                        elseif yi < 15 then
                            ya = x5_1:GetAttribute("Unlocked") ~= true
                            yi = 37
                        elseif yi < 16 then
                            yi = 0
                        else
                            task.wait()
                            yi = 18
                        end
                    elseif yi < 20 then
                        if yi < 18 then
                            x4 = not q9("AutoUnlockSlots")
                            yi = 27
                        elseif yi < 19 then
                            yi = 3
                        else
                            ya = not q9("AutoUnlockSlots")
                            yi = 2
                        end
                    elseif yi < 21 then
                        yi = if ya then 42 else 16
                    elseif yi < 22 then
                        x4 = v.prompt
                        x5_1 = x4
                        yi = if x5_1 then 24 else 23
                    else
                        x5_1 = x4:FindFirstAncestorWhichIsA("Model")
                        x6 = not x5_1
                        yi = if x6 then 34 else 10
                    end
                elseif yi < 35 then
                    if yi < 29 then
                        if yi < 26 then
                            if yi < 24 then
                                yi = if x5_1 then 4 else 39
                            elseif yi < 25 then
                                x5_1 = x4.Parent
                                yi = 23
                            else
                                x8 = x6:IsA("BasePart")
                                yi = 7
                            end
                        elseif yi < 27 then
                            ya = Library.Unloaded
                            yi = if ya then 2 else 19
                        elseif yi < 28 then
                            yi = if x4 then 9 else 5
                        else
                            x4 = qE.wallet
                            yi = 11
                        end
                    elseif yi < 32 then
                        if yi < 30 then
                            x6 = v.part
                            x8 = x6
                            yi = if x8 then 25 else 7
                        elseif yi < 31 then
                            x4 = Library.Unloaded
                            yi = if x4 then 27 else 17
                        else
                            qE.busy = false
                            return
                        end
                    elseif yi < 33 then
                        x3 = q_()
                        yi = if x3 then 8 else 13
                    elseif yi < 34 then
                        yi = 0
                    else
                        local yu = if x6 then 1 else 0
                        local ys = 2469 * yu + 3089 * (1 - yu)
                        local yt = 2264 * yu + 3981 * (1 - yu)
                        yi = if (ys * 896 + yt * 528 + ys * yt) % 16777213 == 8997432 then 43 else 29
                    end
                elseif yi < 41 then
                    if yi < 38 then
                        if yi < 36 then
                            x8 = x3.CFrame
                            x2 = x6.CFrame * CFrame.new(0, 3, 0)
                            x6 = function()
                                x3 = q_()
                                if not x3 then
                                    return
                                end
                                x3.CFrame = x2
                                x3.AssemblyLinearVelocity = Vector3.zero
                            end
                            x6()
                            task.wait(0.1)
                            q3(x4)
                            x9 = os.clock()
                            yi = 3
                        elseif yi < 37 then
                            ya = os.clock() - x9 < 1.25
                            yi = if ya then 14 else 37
                        else
                            yi = if ya then 26 else 6
                        end
                    elseif yi < 39 then
                        ya = os.clock() - x9 < 0.45
                        yi = 20
                    elseif yi < 40 then
                        yi = if not x5_1 then 33 else 22
                    else
                        return
                    end
                elseif yi < 44 then
                    if yi < 42 then
                        qE.busy = true
                        x3 = q_()
                        yi = if not x3 then 31 else 35
                    elseif yi < 43 then
                        q3(x4)
                        yi = 16
                    else
                        yi = 0
                    end
                elseif yi < 45 then
                    x6()
                    ya = os.clock() - x9 > 0.35
                    yi = if ya then 38 else 20
                elseif yi < 46 then
                    yj = true
                    yi = 0
                else
                    x4 = (tonumber(qk:GetAttribute("Wallet")))
                    yi = if x4 then 11 else 28
                end
            end
            if yj then
                break
            end
        end
    end
end
do
    task.spawn(worker7)
    task.spawn(worker6)
    task.spawn(worker5)
    task.spawn(worker4)
    task.spawn(worker3)
    task.spawn(worker2)
    task.spawn(worker)
    Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = qN, Copyable = true }, "|", qS },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
end
qm = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gamepad-2"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in qm do
    if k ~= "Info" then
        fn415(v)
    end
end
qr, qd, q4, qK = nil, nil, nil, nil
local ObbyGroup = qm.Main:AddLeftGroupbox("Obby", "flag")
ObbyGroup:AddToggle("AutoCompleteObby", { Text = "Auto Complete Obby", Default = false })
ObbyGroup:AddDropdown("ObbyMode", { Text = "Obby Mode", Values = rl_6, Default = qg })
ObbyGroup:AddDropdown("ObbyPriority", {
    Text = "Obby Priority",
    Values = rm_4,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Default = {}
})
local EconomyGroup = qm.Main:AddRightGroupbox("Economy", "coins")
EconomyGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
EconomyGroup:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
EconomyGroup:AddDivider("Characters")
EconomyGroup:AddToggle("AutoBuyCharacters", { Text = "Auto Buy Characters", Default = false })
EconomyGroup:AddDropdown("BuyCharacters", {
    Text = "Characters",
    Values = rn,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Default = {}
})
rp = qm.Main:AddLeftGroupbox("Pads", "layout-grid")
rp:AddToggle("AutoPlace", { Text = "Auto Place", Default = false })
rp:AddDropdown("PlaceLogic", { Text = "Place Logic", Values = { qf, p9 }, Default = qf })
rp:AddToggle("AutoReplaceBetter", { Text = "Auto Replace Better", Default = false })
rp:AddToggle("AutoUnlockSlots", { Text = "Auto Unlock Slots", Default = false })
qK = fn842
ro = function()
    local zr
    local zn
    zn = nil
    zr = nil
    local Label2, Label3, zp, zq, Label
    zr = "Unknown"
    pcall(function()
        local zc_1
        local zb_1
        if identifyexecutor then
            zc_1, zb_1 = identifyexecutor()
            local zd = zc_1 ~= ""
            local ze = type(zc_1) == "string" and zd
            if ze then
                local zd_1 = type(zb_1) == "string" and zb_1 ~= "" and zc_1 .. " " .. zb_1
                zr = zd_1 or zc_1
            end
        end
    end)
    local zt = qK()
    zn = os.clock()
    zq = function()
        local zg = math.floor(os.clock() - zn)
        if zg < 60 then
            return zg .. "s"
        elseif zg < 3600 then
            return string.format("%dm %ds", math.floor((zg) / (60)), zg % 60)
        else
            return string.format("%dh %dm", math.floor((zg) / (3600)), math.floor((zg % 3600) / (60)))
        end
    end
    local UserGroup = qm.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = qk, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(qp("User", qk.DisplayName .. " @" .. qk.Name, qq), true)
    UserGroup:AddLabel(qp("UserId", tostring(qk.UserId), qh), true)
    UserGroup:AddLabel(qp("Executor", zr .. "  " .. zt, qq), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(qp("Session", zq(), qb), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            p8(qk.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            p8("https://www.roblox.com/users/" .. tostring(qk.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = qm.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(qp("Game", qS, qh), true)
    Label2 = SessionGroup:AddLabel(qp("Players", "0/0", qq), true)
    zp = tostring(game.JobId)
    local zu_1 = #zp > 18 and string.sub(zp, 1, 18) .. "..."
    local zu_2 = zu_1 or zp
    SessionGroup:AddLabel(qp("Job", zu_2, p5), true)
    Label = SessionGroup:AddLabel(qp("Ping", "0 ms", qb), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            qJ:Teleport(game.PlaceId, qk)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            p8(zp, "Copied Job ID")
        end
    })
    task.spawn(function()
        local zj_1
        local zi_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(qp("Session", zq(), qb))
            Label2:SetText(qp("Players", #p4:GetPlayers() .. "/" .. tostring(p4.MaxPlayers), qq))
            zi_1, zj_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local zi_2 = zi_1 and zj_1 .. " ms" or "n/a"
            Label:SetText(qp("Ping", zi_2, qb))
        end
    end)
    local SocialsGroup = qm.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = q1 })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            p8(qG, "Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            p8(qy, "Copied website link")
        end
    })
end
ro()
noClipLoop = function()
    local MovementGroup = qm.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = qm.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local PerformanceGroup = qm.Player:AddRightGroupbox("Performance", "gauge")
    PerformanceGroup:AddToggle("BoostFPS", { Text = "Boost FPS", Default = false })
    local connection2
    local Lighting = game:GetService("Lighting")
    local jw = setmetatable({}, { __mode = "k" })
    local function jx(jy, jz, jA)
        local zz_1
        local zy_1
        local zx = jw[jy]
        if not zx then
            zx = {}
            jw[jy] = zx
        end
        if zx[jz] == nil then
            zy_1, zz_1 = pcall(function()
                return jy[jz]
            end)
            if not zy_1 then
                return
            end
            zx[jz] = zz_1
        end
        pcall(function()
            jy[jz] = jA
        end)
    end
    local function onDescendantAdded(jL)
        if jL:IsA("BasePart") then
            jx(jL, "CastShadow", false)
            jx(jL, "Reflectance", 0)
        else
            local zB = jL:IsA("Decal") or jL:IsA("Texture")
            if zB then
                jx(jL, "Transparency", 1)
            else
                local zB_1 = jL:IsA("ParticleEmitter") or jL:IsA("Trail") or jL:IsA("Beam")
                local zF = if zB_1 then 1 else 0
                local zD = 646 * zF + 3921 * (1 - zF)
                local zE = 590 * zF + 3164 * (1 - zF)
                if not ((zD * 2094 + zE * 982 + zD * zE) % 16777213 == 2313244) then
                    zB_1 = jL:IsA("Smoke")
                end
                if not zB_1 then
                    zB_1 = jL:IsA("Fire")
                end
                if not zB_1 then
                    zB_1 = jL:IsA("Sparkles")
                end
                if not zB_1 then
                    zB_1 = jL:IsA("PostEffect")
                end
                if zB_1 then
                    jx(jL, "Enabled", false)
                elseif jL:IsA("Atmosphere") then
                    jx(jL, "Density", 0)
                elseif jL:IsA("MeshPart") then
                    jx(jL, "TextureID", "")
                end
            end
        end
    end
    local function jP()
        if connection2 then
            connection2:Disconnect()
            connection2 = nil
        end
        for k, v in jw do
            local zK = k
            for k, v in v do
                local zQ = k
                local zS = v
                pcall(function()
                    zK[zQ] = zS
                end)
            end
        end
        table.clear(jw)
    end
    local function jZ(j_)
        jP()
        if not j_ then
            return
        end
        pcall(function()
            jx(settings().Rendering, "QualityLevel", Enum.QualityLevel.Level01)
        end)
        pcall(function()
            jx(UserSettings():GetService("UserGameSettings"), "SavedQualityLevel", Enum.SavedQualitySetting.QualityLevel1)
        end)
        jx(Lighting, "GlobalShadows", false)
        jx(Lighting, "EnvironmentDiffuseScale", 0)
        jx(Lighting, "EnvironmentSpecularScale", 0)
        local Terrain = qs.Terrain
        if Terrain then
            jx(Terrain, "Decoration", false)
            jx(Terrain, "WaterWaveSize", 0)
            jx(Terrain, "WaterWaveSpeed", 0)
            jx(Terrain, "WaterReflectance", 0)
        end
        for i, descendant in qs:GetDescendants() do
            onDescendantAdded(descendant)
        end
        for i, descendant in Lighting:GetDescendants() do
            onDescendantAdded(descendant)
        end
        connection2 = qs.DescendantAdded:Connect(onDescendantAdded)
        qt(connection2)
    end
    local function kg(kh)
        pcall(function()
            qP:SetGameplayPausedNotificationEnabled(not kh)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = qB:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not kh
            end
        end)
        if not kh then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(qk, "GameplayPaused", false)
            else
                qk.GameplayPaused = false
            end
        end)
    end
    local function kv(kw)
        if not kw:IsA("ProximityPrompt") then
            return
        end
        kw.HoldDuration = 0
        kw.MaxActivationDistance = 50
        kw.RequiresLineOfSight = false
    end
    local connection
    qt(q8.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = qk.Character
            if Character then
                for i, descendant in Character:GetDescendants() do
                    local Ab_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if Ab_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end))
    qt(q5.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local Aj_1 = p7()
            if Aj_1 then
                Aj_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end))
    local CurrentCamera = qs.CurrentCamera
    qt(q8.RenderStepped:Connect(function(kR)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local Ao_1 = p7()
            if Ao_1 then
                Ao_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local Ao_3 = q_()
            local Ap = p7()
            if Ao_3 and Ap then
                Ap.PlatformStand = true
                local Ap_1 = Vector3.zero
                if q5:IsKeyDown(Enum.KeyCode.W) then
                    Ap_1 += CurrentCamera.CFrame.LookVector
                end
                if q5:IsKeyDown(Enum.KeyCode.S) then
                    Ap_1 -= CurrentCamera.CFrame.LookVector
                end
                if q5:IsKeyDown(Enum.KeyCode.A) then
                    Ap_1 -= CurrentCamera.CFrame.RightVector
                end
                if q5:IsKeyDown(Enum.KeyCode.D) then
                    Ap_1 += CurrentCamera.CFrame.RightVector
                end
                if q5:IsKeyDown(Enum.KeyCode.Space) then
                    Ap_1 += Vector3.new(0, 1, 0)
                end
                if q5:IsKeyDown(Enum.KeyCode.LeftControl) then
                    Ap_1 -= Vector3.new(0, 1, 0)
                end
                Ao_3.AssemblyLinearVelocity = Vector3.zero
                if Ap_1.Magnitude > 0 then
                    Ao_3.CFrame = Ao_3.CFrame + Ap_1.Unit * Options.FlySpeed.Value * kR
                end
            end
        end
    end))
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local Av = p7()
            if Av then
                Av.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local AA = p7()
            if AA then
                AA.WalkSpeed = 16
            end
        end
    end)
    Toggles.AntiGameplayPause:OnChanged(function()
        kg(Toggles.AntiGameplayPause.Value)
    end)
    kg(true)
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in qs:GetDescendants() do
                pcall(kv, descendant)
            end
            connection = qs.DescendantAdded:Connect(function(lk)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(kv, lk)
                end
            end)
            qt(connection)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    Toggles.BoostFPS:OnChanged(function()
        jZ(Toggles.BoostFPS.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                kg(true)
            end
        end
    end)
    return kg, function()
        jP()
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
end
qr, qd = noClipLoop()
local function ri_7(ly)
    local lz = 0
    local lA = tick()
    ly:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = ly:AddLabel("AFK triggers: 0")
    local function lC()
        local CurrentCamera = qs.CurrentCamera
        if not CurrentCamera then
            return
        end
        qZ:CaptureController()
        qZ:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        lz += 1
        lA = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. lz)
        end)
    end
    local connection = qk.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(lC)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local AS = Toggles.AntiAfk.Value and tick() - lA >= 60
            if AS then
                pcall(lC)
            end
        end
    end)
    ly:AddButton({
        Text = "Unload UI",
        Func = function()
            Library:Unload()
        end
    })
    return connection
end
local MenuGroup = qm.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
q4 = ri_7(MenuGroup)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(qm.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/BuildACloneObby")
local rv = SaveManager:BuildConfigSection(qm.Settings)
SaveManager:LoadAutoloadConfig()
saveManager_ImportSourceLoop = function(l2)
    local function l3(l4, l5)
        local AV_1 = (l4 == "Toggle" and Toggles or Options)[l5]
        local AU_2 = type(AV_1) == "table" and AV_1.Type == l4
        return AU_2 and AV_1 or nil
    end
    local function mf(mg, mh)
        local Type = mh.Type
        if Type == "Toggle" then
            return { idx = mg, type = "Toggle", value = mh.Value == true }
        elseif Type == "Slider" then
            return { idx = mg, type = "Slider", value = tostring(mh.Value) }
        elseif Type == "Dropdown" then
            return { idx = mg, type = "Dropdown", multi = mh.Multi == true, value = mh.Value }
        elseif Type == "Input" then
            local AZ = mh.Value or ""
            return { idx = mg, type = "Input", text = tostring(AZ) }
        elseif Type == "ColorPicker" then
            return { idx = mg, type = "ColorPicker", value = mh.Value:ToHex(), transparency = mh.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = mg,
                type = "KeyPicker",
                mode = mh.Mode,
                key = mh.Value,
                modifiers = mh.Modifiers,
                toggled = mh.Toggled
            }
        else
            return nil
        end
    end
    local function mj()
        local A4 = {}
        for k, v in { Toggles, Options } do
            for k, v in v do
                local A5 = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if A5 then
                    local A5_1 = mf(k, v)
                    if A5_1 then
                        A4[#A4 + 1] = A5_1
                    end
                end
            end
        end
        table.sort(A4, function(mr, ms)
            if mr.type ~= ms.type then
                return mr.type < ms.type
            end
            return mr.idx < ms.idx
        end)
        return { objects = A4 }
    end
    local function mt(mu)
        local Bo
        Bo = nil
        local Bp = type(mu) ~= "table"
        local Bt = if Bp then 1 else 0
        local Br = 457 * Bt + 3016 * (1 - Bt)
        local Bs = 853 * Bt + 3441 * (1 - Bt)
        if not ((Br * 261 + Bs * 1449 + Br * Bs) % 16777213 == 1745095) then
            Bp = type(mu.idx) ~= "string"
        end
        if not Bp then
            Bp = type(mu.type) ~= "string"
        end
        if not Bp then
            Bp = SaveManager.Ignore[mu.idx]
        end
        if Bp then
            return false
        end
        Bo = l3(mu.type, mu.idx)
        if not Bo then
            return false
        end
        local Bp_1 = pcall(function()
            if mu.type == "Input" then
                if type(mu.text) ~= "string" then
                    return
                end
                Bo:SetValue(mu.text)
            elseif mu.type == "ColorPicker" then
                Bo:SetValueRGB(Color3.fromHex(mu.value), mu.transparency)
            elseif mu.type == "KeyPicker" then
                Bo:SetValue({ mu.key, mu.mode, mu.modifiers })
                if mu.mode == "Toggle" and mu.toggled ~= nil then
                    Bo.Toggled = mu.toggled
                    Bo:Update()
                end
            else
                Bo:SetValue(mu.value)
            end
        end)
        return Bp_1
    end
    l2:AddDivider()
    l2:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    l2:AddButton("Export Config to Clipboard", function()
        local Bv_1
        local Bu_1
        Bu_1, Bv_1 = pcall(qV.JSONEncode, qV, mj())
        if not Bu_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local Bu_2 = setclipboard or toclipboard
        local Bu_3 = type(Bu_2) ~= "function" or not pcall(Bu_2, Bv_1)
        if Bu_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    l2:AddButton("Import Config from Clipboard Text", function()
        local BD_1
        local BB = Options.SaveManager_ImportSource.Value or ""
        local BB_1
        local BC = tostring(BB):match("^%s*(.-)%s*$")
        if BC == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        BB_1, BD_1 = pcall(qV.JSONDecode, qV, BC)
        local BC_1 = not BB_1 or type(BD_1) ~= "table"
        local BH = if BC_1 then 1 else 0
        local BF = 1944 * BH + 865 * (1 - BH)
        local BG = 2058 * BH + 2734 * (1 - BH)
        if not ((BF * 3013 + BG * 1878 + BF * BG) % 16777213 == 13722948) then
            BC_1 = type(BD_1.objects) ~= "table"
        end
        if BC_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local BB_2 = 0
        for k, v in BD_1.objects do
            if mt(v) then
                BB_2 += 1
            end
        end
        if BB_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local BD_2 = BB_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(BB_2, BD_2), 6)
    end)
end
saveManager_ImportSourceLoop(rv)
Library:OnUnload(function()
    qr(false)
    qd()
    if q4 then
        q4:Disconnect()
    end
    for k, v in qA do
        local BV = v
        pcall(function()
            BV:Disconnect()
        end)
    end
    table.clear(qA)
    local BO = p7()
    if BO then
        BO.PlatformStand = false
        BO.WalkSpeed = 16
    end
    local BO_1 = getgenv and getgenv().__TempoBuildACloneObbyLib == Library
    if BO_1 then
        getgenv().__TempoBuildACloneObbyLib = nil
    end
end)
end)(...)

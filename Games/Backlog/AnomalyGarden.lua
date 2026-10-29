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
getgenv().TempoHoodSubtitle = "ANOMALY GARDEN"
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
local sy
local sB
local sX
local si
local ti
local s_
local sf
local sH
local sl
local so
local sr
local sN
local s8
local tb
local sQ
local sx
local HttpService
local te
local sA
local th
local sW
local sD
local sZ
local sk
local sG
local s1
local Workspace
local s4
local CoreGui
local sq
local sM
local se
local sh
local sP
local st
local sw
local td
local sd
local sz
local tg
local sg
local sV
local tj
local LocalPlayer
local s0
local sm
local s3
local sI
local sL
local s6
local ss
local sR
local tc
local sU
local tf
local function fn92()
    return sq(si(function(cS)
        return cS:GetAttribute("IsScythe") == true
    end))
end
local function fn136()
    local yO = {}
    if sZ.hearts then
        table.insert(yO, sN("Hearts"))
    end
    if sZ.scythes then
        table.insert(yO, sN("Scythes"))
    end
    if sZ.backpacks then
        table.insert(yO, sN("Backpacks"))
    end
    local yP = #yO > 0 and table.concat(yO, " | ")
    local yO_1 = yP or "Idle"
    tg.GearStatus = yO_1
end
local function fn172()
    local Character = LocalPlayer.Character
    if not Character then
        return nil
    end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if Humanoid and Humanoid.Health <= 0 then
        return nil
    end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local ux_1 = HumanoidRootPart and HumanoidRootPart:IsA("BasePart")
    if ux_1 then
        return HumanoidRootPart
    end
    return nil
end
local function fn298()
    local yU_1
    if not sx.GetResearchState or not sx.PurchaseResearch then
        tg.ResearchStatus = "Research remotes are unavailable"
        return
    end
    local yS_1 = sM(sx.GetResearchState, 6)
    local yT = type(yS_1) ~= "table" or type(yS_1.Categories) ~= "table"
    local yT_1
    if yT then
        tg.ResearchStatus = "Research Lab is not built yet"
        return
    end
    yU_1, yT_1 = {}, {}
    for i, v in ipairs(yS_1.Categories) do
        local yV_1 = type(v.Upgrades) == "table" and v.Upgrades
        local yX_1 = yV_1 or {}
        for i, v in ipairs(yX_1) do
            local yV_2 = v.DisplayName or v.Id
            local yW_2 = tostring(yV_2)
            if not yT_1[yW_2] then
                yT_1[yW_2] = true
                table.insert(yU_1, yW_2)
            end
        end
    end
    local yT_2 = sz(sG.refresh) and #yU_1 > 0
    if yT_2 then
        pcall(sG.refresh, yU_1)
    end
    local picks = sU.picks
    local yU_2 = next(picks)
    local yV_3 = 0
    local yW_3 = yU_2 ~= nil
    for i, v in ipairs(yS_1.Categories) do
        local yS_2 = type(v.Upgrades) == "table" and v.Upgrades
        local yX_2 = yS_2 or {}
        for i, v2 in ipairs(yX_2) do
            if not sm() then
                return
            end
            local yS_3 = v2.DisplayName or v2.Id
            local yU_4 = tostring(yS_3)
            if (not yW_3 or picks[yU_4] == true) and v2.Unlocked == true and v2.Maxed ~= true then
                local yS_5 = sM(sx.PurchaseResearch, 6, v.Id, v2.Id)
                local yU_6 = type(yS_5) == "table" and yS_5.Success == true
                if yU_6 then
                    yV_3 += 1
                    td(0.2)
                end
            end
        end
    end
    local yT_4 = yV_3 > 0 and "Bought " .. yV_3 .. " upgrades"
    local y0 = if yT_4 then 1 else 0
    local yZ = 13 * y0 + 1311 * (1 - y0)
    local y_ = 1045 * y0 + 49 * (1 - y0)
    if not ((yZ * 428 + y_ * 1156 + yZ * y_) % 16777213 == 1227169) then
        yT_4 = "Nothing affordable"
    end
    tg.ResearchStatus = yT_4
end
local function fn317()
    sL(tb)
    sL(s4)
    sL(sZ)
    sL(sU)
end
local function fn327(eZ, e_)
    tb[eZ] = e_ == true
    if sA() then
        if not tb.running then
            tb.running = true
            sQ(tb, ti)
        end
    else
        tb.running = false
        sL(tb)
        if tb.restore and tb.origin then
            sD(tb.origin)
        end
        tb.origin = nil
        tg.FieldStatus = "Idle"
    end
end
local function fn331()
    if not sz(fireproximityprompt) then
        tg.FieldStatus = "fireproximityprompt is unavailable"
        return false
    end
    local xn = s0("GrabBoxesButton")
    local xo = s0("SacrificeButton")
    local xp = sd(xn)
    local xq = sd(xo)
    if not xp or not xq then
        tg.FieldStatus = "Box buttons not found"
        return false
    end
    local xr_1 = sr(xn)
    local xn_1 = sr(xo)
    if not xr_1 or not xn_1 then
        return false
    end
    tg.FieldStatus = "Sacrificing boxes"
    sw(xr_1, s1)
    td(0.5)
    pcall(fireproximityprompt, xp)
    td(0.8)
    sw(xn_1, s1)
    td(0.6)
    pcall(fireproximityprompt, xq)
    td(0.8)
    return true
end
local function fn348()
    local u2_1
    local u1_1
    u1_1, u2_1 = sk()
    if not u1_1 then
        return nil
    end
    local attr = u1_1:GetAttribute("FarmContentName")
    local u4 = type(attr) == "string" and u1_1:FindFirstChild(attr)
    local u3_1 = u4 or nil
    local u8 = if u3_1 then 1 else 0
    local u6 = 1578 * u8 + 1692 * (1 - u8)
    local u7 = 1061 * u8 + 2497 * (1 - u8)
    if not ((u6 * 3234 + u7 * 3941 + u6 * u7) % 16777213 == 10958911) then
        u3_1 = u1_1
    end
    return u3_1, u2_1
end
local function fn359()
    local v6 = tonumber(LocalPlayer:GetAttribute("BackpackCapacity")) or 30
    return math.max(v6, 1)
end
local function fn367(cX)
    if not cX then
        return nil
    end
    for i, descendant in ipairs(cX:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            return descendant
        end
    end
    return nil
end
local function fn376(dJ, dK)
    return sD(CFrame.new(dJ + dK, dJ))
end
local function fn379(U)
    local uf = typeof(cloneref) == "function" and typeof(U) == "Instance"
    if uf then
        return cloneref(U)
    end
    return U
end
local function fn395()
    local va_1
    local u9_1
    u9_1, va_1 = sk()
    if not va_1 then
        return nil
    end
    local FarmV2Spawned = Workspace:FindFirstChild("FarmV2Spawned")
    local vb = FarmV2Spawned and FarmV2Spawned:FindFirstChild(va_1)
    return vb or nil
end
local function fn443()
    if not sx.GetSeedShopState or not sx.BuySeed then
        tg.SeedStatus = "Seed shop remotes are unavailable"
        return
    end
    local x5_1 = sM(sx.GetSeedShopState, 6)
    local x6 = type(x5_1) ~= "table"
    local yf = if x6 then 1 else 0
    local yd = 2587 * yf + 3525 * (1 - yf)
    local ye = 2291 * yf + 178 * (1 - yf)
    if not ((yd * 2917 + ye * 791 + yd * ye) % 16777213 == 15285277) then
        x6 = type(x5_1.Stock) ~= "table"
    end
    if x6 then
        tg.SeedStatus = "Seed shop is unavailable"
        return
    end
    local x6_1 = x5_1.Stock
    local crops = s4.crops
    local x7 = next(crops)
    local x8 = 0
    local x9 = x7 ~= nil
    for i, v in ipairs(tc) do
        if not x9 or crops[v] then
            while true do
                local x7_2 = (sm())
                if x7_2 then
                    local ya_1 = tonumber(x6_1[v]) or 0
                    x7_2 = ya_1 > 0
                end
                if x7_2 then
                    local x7_3 = sM(sx.BuySeed, 6, v)
                    local ya_2 = type(x7_3) ~= "table" or x7_3.Success ~= true
                    if ya_2 then
                        local yb = x8 > 0 and "Bought " .. x8 .. " seed packs" or "Cannot afford the stocked seeds"
                        tg.SeedStatus = yb
                        return
                    end
                    x8 += 1
                    local ya_4 = type(x7_3.State) == "table" and type(x7_3.State.Stock) == "table"
                    if ya_4 then
                        x6_1 = x7_3.State.Stock
                    else
                        local x7_4 = tonumber(x6_1[v]) or 1
                        x6_1[v] = x7_4 - 1
                    end
                    td(0.2)
                    continue
                end
                break
            end
        end
    end
    local x6_2 = x8 > 0 and "Bought " .. x8 .. " seed packs" or "Nothing in stock"
    tg.SeedStatus = x6_2
end
local function fn468(gF)
    if gF then
        sQ(sU, sy)
    else
        sL(sU)
        tg.ResearchStatus = "Idle"
    end
end
local function fn484(b6)
    local vK_1
    local vJ_1
    local vF = s6()
    local vG = tf()
    local vI = not vF or not vG
    local vI_1
    if vI then
        return nil
    end
    local Position = vG.Position
    vK_1, vJ_1, vI_1 = nil, nil, nil
    for i, child in ipairs(vF:GetChildren()) do
        local vF_1 = child:IsA("Model") and b6(child)
        if vF_1 then
            local vF_2 = sr(child)
            if vF_2 then
                local Magnitude = (vF_2 - Position).Magnitude
                if not vI_1 or Magnitude < vI_1 then
                    vK_1, vJ_1, vI_1 = child, vF_2, Magnitude
                end
            end
        end
    end
    return vK_1, vJ_1
end
local function fn511(cy)
    local Character = LocalPlayer.Character
    if Character then
        for i, child in ipairs(Character:GetChildren()) do
            local v8_1 = child:IsA("Tool") and cy(child)
            if v8_1 then
                return child
            end
        end
    end
    local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if Backpack then
        for i, child in ipairs(Backpack:GetChildren()) do
            local v8_3 = child:IsA("Tool") and cy(child)
            if v8_3 then
                return child
            end
        end
    end
    return nil
end
local function fn568(gy)
    if gy then
        sQ(s4, sI)
    else
        sL(s4)
        tg.SeedStatus = "Idle"
    end
end
local function fn604()
    gethui = th
end
local function fn655(b3)
    local vA = b3:GetAttribute("FarmV2CropReady") == true and b3:GetAttribute("FarmV2Dead") ~= true
    return vA
end
local function fn662()
    local wU = tb.plant
    local wY = if wU then 1 else 0
    local wW = 2414 * wY + 4050 * (1 - wY)
    local wX = 2552 * wY + 485 * (1 - wY)
    if not ((wW * 2058 + wX * 1634 + wW * wX) % 16777213 == 15298508) then
        wU = tb.harvest
    end
    if not wU then
        wU = tb.kill
    end
    local w0 = if wU then 1 else 0
    local wZ = 178 * w0 + 1196 * (1 - w0)
    local w_ = 2251 * w0 + 1684 * (1 - w0)
    if not ((wZ * 2162 + w_ * 3300 + wZ * w_) % 16777213 == 8213814) then
        wU = tb.deposit
    end
    local w3 = if wU then 1 else 0
    local w1 = 4001 * w3 + 1116 * (1 - w3)
    local w2 = 3486 * w3 + 1260 * (1 - w3)
    if not ((w1 * 2870 + w2 * 1187 + w1 * w2) % 16777213 == 12791025) then
        wU = tb.sacrifice
    end
    return wU
end
local function fn664(du)
    du.stopped = true
    local wS = du.generation or 0
    du.generation = wS + 1
end
local function fn694()
    local attr = LocalPlayer:GetAttribute("CarryItemsJson")
    local vU = attr == ""
    local vU_1
    local vV = type(attr) ~= "string" or vU
    local vV_1
    if vV then
        return 0
    end
    vU_1, vV_1 = pcall(HttpService.JSONDecode, HttpService, attr)
    local vT_1 = not vU_1 or type(vV_1) ~= "table"
    if vT_1 then
        return 0
    end
    local vT_2 = 0
    for i, v in ipairs(vV_1) do
        if type(v) == "table" then
            local vU_2 = tonumber(v.Count) or 0
            vT_2 += vU_2
        end
    end
    return vT_2
end
local function fn710(a0)
    local uG = os.clock() + a0
    while true do
        local uH = sm() and os.clock() < uG
        if uH then
            task.wait(0.05)
            continue
        end
        break
    end
    return sm()
end
local function fn722(X)
    return type(X) == "function"
end
local function fn724()
    return sZ.hearts or sZ.scythes or sZ.backpacks
end
local function fn731(c0)
    local wC = sB()
    if not wC then
        return nil
    end
    local Buttons = wC:FindFirstChild("Buttons")
    local wE = Buttons and Buttons:FindFirstChild(c0)
    local wD_1 = wE or wC:FindFirstChild(c0, true)
    return wD_1
end
local function fn748()
    return not sW.Unloaded
end
local function fn791()
    local vg = sB()
    if not vg then
        return {}
    end
    local vh = vg:FindFirstChild("FarmPlots") or vg
    local vg_1 = {}
    for i, descendant in ipairs(vh:GetDescendants()) do
        local vh_1 = descendant:IsA("Model") and descendant:GetAttribute("FarmV2Unlocked") == true and descendant:GetAttribute("FarmV2CropPatch") ~= true and typeof(descendant:GetAttribute("TileX")) == "number"
        if vh_1 then
            table.insert(vg_1, descendant)
        end
    end
    return vg_1
end
local function fn801()
    return si(function(cV)
        return type(cV:GetAttribute("SeedCropType")) == "string"
    end)
end
local function fn871()
    local xS_1
    if not sA() then
        tg.FieldStatus = "Idle"
        return
    end
    if not sX.ready then
        tg.FieldStatus = "Farm remotes are unavailable"
        return
    end
    local xP = tf()
    if not xP then
        tg.FieldStatus = "Waiting for character"
        return
    end
    if not sB() then
        tg.FieldStatus = "Waiting for your plot"
        return
    end
    if tb.origin == nil then
        tb.origin = xP.CFrame
    end
    local xP_1 = sf()
    local xQ = st()
    local xQ_1
    local xR = tb.deposit and xP_1 >= xQ
    local xR_1, xR_3
    if xR then
        tj()
        return
    end
    if tb.kill then
        xR_1, xS_1 = sH(so)
        if xR_1 and xS_1 then
            local xT_1 = xR_1:GetAttribute("DisplayName") or xR_1.Name
            tg.FieldStatus = "Attacking " .. tostring(xT_1)
            sw(xS_1, te)
            sh()
            return
        end
    end
    if tb.harvest and xP_1 < xQ then
        xQ_1, xR_3 = sH(sV)
        if xQ_1 and xR_3 then
            local xS_3 = (xQ_1:GetAttribute("DisplayName"))
            local x_ = if xS_3 then 1 else 0
            local xY = 214 * x_ + 3742 * (1 - x_)
            local xZ = 3268 * x_ + 2949 * (1 - x_)
            if not ((xY * 3606 + xZ * 3170 + xY * xZ) % 16777213 == 11830596) then
                xS_3 = xQ_1.Name
            end
            tg.FieldStatus = "Harvesting " .. tostring(xS_3)
            sw(xR_3, te)
            sh()
            return
        end
    end
    if tb.deposit and xP_1 > 0 then
        tj()
        return
    end
    local xP_2 = tb.sacrifice and sl() > 0
    if xP_2 then
        ss()
        return
    end
    local xP_3 = tb.plant and se()
    if xP_3 then
        return
    end
    if not tb.plant then
        tg.FieldStatus = "Waiting for work"
    end
    if tb.restore and tb.origin then
        sD(tb.origin)
        tb.origin = nil
    end
end
local function fn909()
    local xa = sB()
    local xb = xa and xa:FindFirstChild("Crates")
    local xb_1 = tf()
    local xc = not xb_1
    local xc_1
    local xd = not xb or xc
    local xd_1
    if xd then
        tg.FieldStatus = "No crates found"
        return false
    end
    xd_1, xc_1 = nil, nil
    for i, child in ipairs(xb:GetChildren()) do
        local xa_2 = sr(child)
        if xa_2 then
            local Magnitude = (xa_2 - xb_1.Position).Magnitude
            if not xc_1 or Magnitude < xc_1 then
                xd_1, xc_1 = xa_2, Magnitude
            end
        end
    end
    if not xd_1 then
        tg.FieldStatus = "No crates found"
        return false
    end
    tg.FieldStatus = "Depositing crops"
    sw(xd_1, s8)
    local xa_3 = os.clock() + 5
    while true do
        local xb_2 = sm() and os.clock() < xa_3
        if xb_2 then
            if sf() <= 0 then
                break
            end
            task.wait(0.15)
            continue
        end
        break
    end
    return true
end
local function fn942()
    return CoreGui
end
local function fn979()
    local wG = sd(s0("GrabBoxesButton"))
    if not wG then
        return 0
    end
    local wH = tonumber(string.match(tostring(wG.ObjectText), "(%d+)")) or 0
    return wH
end
local function fn1025()
    local attr = LocalPlayer:GetAttribute("FarmPlotName")
    local uT = attr == ""
    local uU = type(attr) ~= "string" or uT
    if uU then
        return nil
    end
    local Bases = Workspace:FindFirstChild("Bases")
    if Bases then
        local uU_1 = Bases:FindFirstChild(attr)
        local uT_2 = uU_1 and uU_1:GetAttribute("OwnerUserId") == LocalPlayer.UserId
        if uT_2 then
            return uU_1, attr
        end
        for i, descendant in ipairs(Workspace:GetDescendants()) do
            local uT_3 = descendant.Name == attr and descendant:GetAttribute("OwnerUserId") == LocalPlayer.UserId
            if uT_3 then
                return descendant, attr
            end
        end
        return nil
    end
    for i, descendant in ipairs(Workspace:GetDescendants()) do
        local uT_4 = descendant.Name == attr and descendant:GetAttribute("OwnerUserId") == LocalPlayer.UserId
        if uT_4 then
            return descendant, attr
        end
    end
    return nil
end
local function fn1029(fv)
    local ym = sg[fv]
    if not ym or not ym.GetStateRemote or not ym.PurchaseRemote then
        return fv .. " unavailable"
    end
    local yn_1 = sM(ym.GetStateRemote, 6)
    local yo = type(yn_1) ~= "table"
    local yw = if yo then 1 else 0
    local yu = 645 * yw + 2467 * (1 - yw)
    local yv = 1371 * yw + 723 * (1 - yw)
    if not ((yu * 1934 + yv * 492 + yu * yv) % 16777213 == 2806257) then
        yo = type(yn_1.Owned) ~= "table"
    end
    if yo then
        return fv .. " unavailable"
    end
    local yo_1 = yn_1.Owned
    local yp = yn_1.Equipped
    local yq
    for i, v in ipairs(ym.Order) do
        if yo_1[v] == true then
            yq = v
        end
    end
    for i, v in ipairs(ym.Order) do
        if not sm() then
            break
        elseif yo_1[v] ~= true then
            local yn_2 = sM(ym.PurchaseRemote, 6, v)
            local yr_1 = type(yn_2) == "table" and yn_2.Success == true
            if yr_1 then
                local yr_2 = type(yn_2.Owned) == "table" and yn_2.Owned
                yo_1 = yr_2 or yo_1
                yo_1[v] = true
                yp = yn_2.Equipped or yp
                yq = v
                td(0.25)
            else
                break
            end
        end
    end
    if sZ.equip and ym.ToggleEquipRemote and yq and yp ~= yq then
        sM(ym.ToggleEquipRemote, 6, yq)
    end
    local ym_1 = yq or "none"
    return fv .. ": " .. tostring(ym_1)
end
local function fn1057(bX)
    local attr = bX:GetAttribute("FarmV2ObjectType")
    local vu = attr == ""
    local vv = type(attr) ~= "string" or vu
    if vv then
        return false
    end
    local vu_1 = s_[attr] or attr == "WorldLoot" or string.match(attr, "SeedPatch$")
    if vu_1 then
        return false
    end
    local vz = if bX:GetAttribute("FarmV2Dead") == true then 1 else 0
    if vz == 1 then
        return false
    end
    local vt_1 = tonumber(bX:GetAttribute("Health"))
    return vt_1 ~= nil and vt_1 > 0
end
local function fn1101(fT, fU)
    sZ[fT] = fU == true
    if s3() then
        if not sZ.running then
            sZ.running = true
            sQ(sZ, sP)
        end
    else
        sZ.running = false
        sL(sZ)
        tg.GearStatus = "Idle"
    end
end
local function fn1109(at)
    for i, v in ipairs(sX.missing) do
        if v == at then
            return
        end
    end
    table.insert(sX.missing, at)
end
local function fn1156(ay, az, aA)
    if not ay then
        return nil
    end
    local ur = ay:FindFirstChild(az)
    local us = ur and ur:IsA(aA)
    if us then
        return ur
    end
    sR(az)
    return nil
end
sd = nil
se = nil
sf = nil
sg = nil
sh = nil
si = nil
LocalPlayer = nil
sk = nil
sl = nil
sm = nil
Workspace = nil
so = nil
sq = nil
sr = nil
ss = nil
st = nil
sw = nil
sx = nil
sy = nil
sz = nil
sA = nil
sB = nil
sD = nil
sG = nil
sH = nil
sI = nil
CoreGui = nil
sL = nil
sM = nil
sN = nil
sP = nil
sQ = nil
sR = nil
HttpService = nil
sU = nil
sV = nil
sW = nil
sX = nil
sZ = nil
local Players, sp, Lighting, sv, TeleportService, sE, sF, sK, GuiService, sS, VirtualUser
s_ = nil
s0 = nil
s1 = nil
s3 = nil
s4 = nil
s6 = nil
s8 = nil
tb = nil
tc = nil
td = nil
te = nil
tf = nil
tg = nil
th = nil
ti = nil
tj = nil
local UserInputService, s5, s7, RunService, ta, tp
local to_1
local AnomalyRanchRemotes
local tn_1, tn_3
local tq_4
if not game:IsLoaded() then
    game.Loaded:Wait()
end
Players, RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, TeleportService, Lighting, Workspace, LocalPlayer, th = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local tm = game:GetService("ReplicatedStorage")
local SeedShopRemotes
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
TeleportService = game:GetService("TeleportService")
Lighting = game:GetService("Lighting")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local tl = "TempoAnomalyGarden"
th = fn942
if getgenv then
    getgenv().gethui = th
end
sW, tp, tg, tc, s5, s_, to_1, sp, tn_1, sz, sm = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local tk = 61
repeat
    local tq_1 = (tk * 3 + 2) % 8 + 1
    if tq_1 <= 4 then
        if tq_1 <= 2 then
            if tq_1 <= 1 then
                local GB = bit32.rrotate(bit32.bxor(bit32.lrotate(tk, 14), string.byte(tostring(tn_1))), 3)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(GB, 3457111079), 1884935190), (bit32.bxor(bit32.band(GB, 837856216), 274125825))), 1884935190), 274125825) == GB then
                    s_ = {}
                else
                    sp = {}
                end
                tk = (tk + 11) % 64
            else
                local tr_1 = (vector.create((tk * 1 + 8) % 11 + 1, (tk * 5 + 3) % 13 + 1, (tk * 10 + 7) % 17 + 1))
                local ts_1 = (vector.create((tk * 3 + 1) % 11 + 1, (tk * 5 + 6) % 13 + 1, (tk * 10 + 1) % 17 + 1))
                local Go = vector.cross(tr_1, ts_1)
                local Gp = vector.dot(tr_1, ts_1)
                if vector.dot(Go, Go) + Gp * Gp == vector.dot(tr_1, tr_1) * vector.dot(ts_1, ts_1) then
                    pcall(fn604)
                    to_1 = function(t)
                        local t8
                        local t6
                        local t7
                        t6 = nil
                        t7 = nil
                        t8 = nil
                        local t9 = t ~= ""
                        local ua = type(t) == "string" and t9
                        assert(ua, "A namespace is required")
                        assert(type(getgenv) == "function", "getgenv is unavailable")
                        t6 = getgenv()
                        assert(type(t6) == "table", "getgenv did not return a table")
                        local t9_2 = t6[t]
                        if t9_2 ~= nil then
                            local ua_2 = type(t9_2) == "table" and type(t9_2.Unload) == "function"
                            assert(ua_2, "Namespace is occupied")
                            t9_2.Unload()
                            assert(t6[t] == nil, "Previous instance did not release its namespace")
                        end
                        t7 = {}
                        t8 = { State = {}, Unloaded = false }
                        t8.Track = function(z)
                            assert(type(z) == "function", "Cleanup must be callable")
                            if t8.Unloaded then
                                z()
                            else
                                table.insert(t7, z)
                            end
                            return z
                        end
                        t8.Unload = function()
                            local tX_2
                            local tW_2
                            if t8.Unloaded then
                                return
                            end
                            t8.Unloaded = true
                            local tU = {}
                            local t3 = #t7
                            local t2 = -1
                            while false and t3 <= 1 or true and t3 >= 1 do
                                local t4 = t3
                                local tV_2 = table.remove(t7, t4)
                                tW_2, tX_2 = pcall(tV_2)
                                if not tW_2 then
                                    table.insert(tU, tostring(tX_2))
                                end
                                t3 += t2
                            end
                            table.clear(t8.State)
                            if #tU > 0 then
                                error("Cleanup incomplete: " .. table.concat(tU, "; "), 0)
                            end
                            if t6[t] == t8 then
                                t6[t] = nil
                            end
                        end
                        t6[t] = t8
                        return t8
                    end
                else
                    pcall(fn604)
                    s5 = function(t)
                        local t8
                        local t6
                        local t7
                        t6 = nil
                        t7 = nil
                        t8 = nil
                        local t9 = t ~= ""
                        local ua = type(t) == "string" and t9
                        assert(ua, "A namespace is required")
                        assert(type(getgenv) == "function", "getgenv is unavailable")
                        t6 = getgenv()
                        assert(type(t6) == "table", "getgenv did not return a table")
                        local t9_1 = t6[t]
                        if t9_1 ~= nil then
                            local ua_1 = type(t9_1) == "table" and type(t9_1.Unload) == "function"
                            assert(ua_1, "Namespace is occupied")
                            t9_1.Unload()
                            assert(t6[t] == nil, "Previous instance did not release its namespace")
                        end
                        t7 = {}
                        t8 = { State = {}, Unloaded = false }
                        t8.Track = function(z)
                            assert(type(z) == "function", "Cleanup must be callable")
                            if t8.Unloaded then
                                z()
                            else
                                table.insert(t7, z)
                            end
                            return z
                        end
                        t8.Unload = function()
                            local tX_1
                            local tW_1
                            if t8.Unloaded then
                                return
                            end
                            t8.Unloaded = true
                            local tU = {}
                            local t3 = #t7
                            local t2 = -1
                            while false and t3 <= 1 or true and t3 >= 1 do
                                local t4 = t3
                                local tV_1 = table.remove(t7, t4)
                                tW_1, tX_1 = pcall(tV_1)
                                if not tW_1 then
                                    table.insert(tU, tostring(tX_1))
                                end
                                t3 += t2
                            end
                            table.clear(t8.State)
                            if #tU > 0 then
                                error("Cleanup incomplete: " .. table.concat(tU, "; "), 0)
                            end
                            if t6[t] == t8 then
                                t6[t] = nil
                            end
                        end
                        t6[t] = t8
                        return t8
                    end
                end
                tk = (tk + 11) % 64
            end
        elseif tq_1 <= 3 then
            local tr_2 = (vector.create((tk * 4 + 4) % 11 + 1, (tk * 7 + 9) % 13 + 1, (tk * 4 + 12) % 17 + 1))
            local ts_2 = (vector.create((tk * 1 + 2) % 11 + 1, (tk * 6 + 11) % 13 + 1, (tk * 5 + 8) % 17 + 1))
            local tt_1 = (vector.create((tk * 3 + 5) % 11 + 1, (tk * 6 + 1) % 13 + 1, (tk * 3 + 16) % 17 + 1))
            local tu_1 = (vector.create((tk * 3 + 6) % 5 + 1, (tk * 3 + 1) % 7 + 1, (tk * 2 + 5) % 9 + 1))
            if vector.dot(vector.cross(tr_2, (vector.cross(ts_2, tt_1))), tu_1) == vector.dot(ts_2 * vector.dot(tr_2, tt_1) - tt_1 * vector.dot(tr_2, ts_2), tu_1) + 3 then
                tc = function(M, N)
                    local ud = type(M) == "table" and type(M.Track) == "function"
                    assert(ud, "FeatureAPI required")
                    local ud_2 = type(N) == "table" and type(N.OnUnload) == "function"
                    assert(ud_2, "UI library required")
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
            else
                sp = function(M, N)
                    local ud = type(M) == "table" and type(M.Track) == "function"
                    assert(ud, "FeatureAPI required")
                    local ud_1 = type(N) == "table" and type(N.OnUnload) == "function"
                    assert(ud_1, "UI library required")
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
            end
            tk = (tk + 27) % 64
        else
            local tr_3 = (vector.create((tk * 1 + 7) % 11 + 1, (tk * 6 + 8) % 13 + 1, (tk * 13 + 3) % 17 + 1))
            local ts_3 = (vector.create((tk * 4 + 2) % 11 + 1, (tk * 1 + 6) % 13 + 1, (tk * 10 + 10) % 17 + 1))
            local tt_2 = (vector.create((tk * 2 + 3) % 11 + 1, (tk * 11 + 10) % 13 + 1, (tk * 10 + 6) % 17 + 1))
            local tu_2 = (vector.create((tk * 7 + 7) % 11 + 1, (tk * 7 + 8) % 13 + 1, (tk * 11 + 2) % 17 + 1))
            if vector.dot(vector.cross(tr_3, ts_3), (vector.cross(tt_2, tu_2))) == vector.dot(tr_3, tt_2) * vector.dot(ts_3, tu_2) - vector.dot(tr_3, tu_2) * vector.dot(ts_3, tt_2) then
                sW = to_1(tl)
            else
                tl = sW(to_1)
            end
            tk = (tk + 11) % 64
        end
    elseif tq_1 <= 6 then
        if tq_1 <= 5 then
            if tk * 74399659 + 9 + 5 >= tk * 74399659 + 9 + 5 + 3 then
                sz = fn379
                tn_1 = fn722
                tp = fn748
                tm = sz(sm)
            else
                tn_1 = fn379
                sz = fn722
                sm = fn748
                tp = tn_1(tm)
            end
            tk = (tk + 43) % 64
        else
            if (s_ or tp) and (not s5 or not s_) and (sp or tp or not sp and s5) or (s_ and s_ or (s5 or s5)) and ((not tp or s5) and (not tp and s_)) or not ((s_ or tp) and (not s5 or not s_) and (sp or tp or not sp and s5) or (s_ and s_ or (s5 or s5)) and ((not tp or s5) and (not tp and s_))) then
                tg = sW.State
            else
                sW = tg.State
            end
            tk = (tk + 59) % 64
        end
    elseif tq_1 <= 7 then
        local tq_2 = {
            "putvq",
            "gapez",
            "wfzsexkus",
            "mtyxazbflzgj",
            "qlsj",
            "sojwul",
            "gsefnkofz",
            "vob",
            "dhlt",
            "nnckebrkv",
            "qotyliq",
            "qbbmeadqwi",
            "ytvhxe",
            "hnzn"
        }
        if tq_2[(tk * 86 + 69) % 14 + 1] <= tq_2[(tk * 86 + 69) % 14 + 1] then
            tg.FieldStatus = "Idle"
            tg.SeedStatus = "Idle"
            tg.GearStatus = "Idle"
            tg.ResearchStatus = "Idle"
            tc = { "Carrot", "BlueBerry", "Tomato", "Pumpkin", "Mushroom", "Grape", "Watermelon", "Pepper", "Lemon" }
        else
            tc.FieldStatus = "Idle"
            tc.SeedStatus = "Idle"
            tc.GearStatus = "Idle"
            tc.ResearchStatus = "Idle"
            tg = { "Grape", "Pepper", "Watermelon", "Mushroom", "Carrot", "Pumpkin", "BlueBerry", "Lemon", "Tomato" }
        end
        tk = (tk + 11) % 64
    else
        local tq_3 = {
            "ciekh",
            "eonguulhgs",
            "yncadwhujdm",
            "wnld",
            "infptf",
            "pfrxcbvqpl",
            "wjsnmceemhjb",
            "rgdfpzmjico",
            "vbudibqi",
            "gajqymuiw",
            "agbcydid",
            "iogpvvkm",
            "iupprlzo",
            "nfdiamvf"
        }
        if tq_3[(tk * 19 + 35) % 14 + 1] < tq_3[(tk * 19 + 35) % 14 + 1] then
            sp = {
                Pumpkin = "Pumpkin",
                Mushroom = "Mushroom",
                Watermelon = "Watermelon",
                Grape = "Grape",
                Lemon = "Lemon",
                Carrot = "Carrot",
                Pepper = "Pepper",
                BlueBerry = "Blueberry",
                Tomato = "Tomato"
            }
        else
            s5 = {
                Carrot = "Carrot",
                BlueBerry = "Blueberry",
                Tomato = "Tomato",
                Pumpkin = "Pumpkin",
                Mushroom = "Mushroom",
                Grape = "Grape",
                Watermelon = "Watermelon",
                Pepper = "Pepper",
                Lemon = "Lemon"
            }
        end
        tk = (tk + 59) % 64
    end
until (tk * 7 + 32) % 64 == 35
for i, v in ipairs(tc) do
    s_[v] = true
end
sF = {}
sK = {}
for i, v in ipairs(tc) do
    local tk_1 = s5[v]
    sK[tk_1] = v
    table.insert(sF, tk_1)
end
sg, te, s8, s1, sX, tq_4, sR = nil, nil, nil, nil, nil, nil, nil
sg = {
    Hearts = {
        Order = { "NormalHeart", "MossHeart", "IronHeart", "ReaperHeart", "RiftHeart" },
        GetState = "GetHeartShopState",
        Purchase = "PurchaseHeart",
        ToggleEquip = "ToggleHeartEquip"
    },
    Scythes = {
        Order = {
            "RustyScythe",
            "IronScythe",
            "TemperedScythe",
            "HarvesterScythe",
            "FuseScythe",
            "ChaosScythe",
            "ProspectorScythe",
            "AnomalyScythe"
        },
        GetState = "GetScytheShopState",
        Purchase = "PurchaseScythe",
        ToggleEquip = "ToggleScytheEquip"
    },
    Backpacks = {
        Order = { "WornBackpack", "FieldBackpack", "GathererBackpack", "MerchantBackpack", "RiftBackpack" },
        GetState = "GetBackpackShopState",
        Purchase = "PurchaseBackpack",
        ToggleEquip = "ToggleBackpackEquip"
    }
}
local tn_2 = { "Hearts", "Scythes", "Backpacks" }
if (sR or not tq_4 or not sR and sR) and ((not te or tq_4) and (not tq_4 and not sX)) and ((sX and te or (not sX or tq_4)) and (not te and te or (tq_4 or not sX))) and (not s8 and tq_4 or (s8 or not te) or te and sX and (sX or not s8) or (sX and not s8 or not s8 and s8 or (not tq_4 or sR) and (not te and not tq_4))) or not ((sR or not tq_4 or not sR and sR) and ((not te or tq_4) and (not tq_4 and not sX)) and ((sX and te or (not sX or tq_4)) and (not te and te or (tq_4 or not sX))) and (not s8 and tq_4 or (s8 or not te) or te and sX and (sX or not s8) or (sX and not s8 or not s8 and s8 or (not tq_4 or sR) and (not te and not tq_4)))) then
    te = Vector3.new(0, 4, 5)
    s8 = Vector3.new(0, 4, 5)
else
    s8 = Vector3.new(0, 4, 5)
    te = Vector3.new(0, 4, 5)
end
s1 = Vector3.new(0, 4, 3)
sX = { ready = false, missing = {} }
sR = fn1109
local tq_5 = tp:FindFirstChild("DimensionalGardenGame")
local tm_1 = tq_5 and tq_5:FindFirstChild("DimensionalGardenRemotes")
local tk_2 = tm_1 or nil
AnomalyRanchRemotes, SeedShopRemotes = nil, nil
local tl_1 = 19
repeat
    local ts_4 = (tl_1 * 2 + 0) % 3 + 1
    if ts_4 <= 2 then
        if ts_4 <= 1 then
            local ts_5 = (vector.create((tl_1 * 6 + 1) % 11 + 1, (tl_1 * 1 + 8) % 13 + 1, (tl_1 * 11 + 1) % 17 + 1))
            local tt_3 = (vector.create((tl_1 * 3 + 9) % 11 + 1, (tl_1 * 3 + 3) % 13 + 1, (tl_1 * 6 + 6) % 17 + 1))
            local ES = vector.dot(ts_5, tt_3)
            if ES * ES <= vector.dot(ts_5, ts_5) * vector.dot(tt_3, tt_3) then
                AnomalyRanchRemotes = tp:FindFirstChild("AnomalyRanchRemotes")
            else
                tp = AnomalyRanchRemotes:FindFirstChild("AnomalyRanchRemotes")
            end
            tl_1 = (tl_1 + 23) % 24
        else
            local ts_6 = (vector.create((tl_1 * 4 + 7) % 11 + 1, (tl_1 * 1 + 3) % 13 + 1, (tl_1 * 10 + 16) % 17 + 1))
            local tt_4 = (vector.create((tl_1 * 7 + 7) % 11 + 1, (tl_1 * 11 + 11) % 13 + 1, (tl_1 * 5 + 5) % 17 + 1))
            local tu_3 = (vector.create((tl_1 * 1 + 5) % 11 + 1, (tl_1 * 1 + 10) % 13 + 1, (tl_1 * 3 + 3) % 17 + 1))
            local tv_1 = (vector.create((tl_1 * 3 + 4) % 11 + 1, (tl_1 * 9 + 2) % 13 + 1, (tl_1 * 3 + 9) % 17 + 1))
            if vector.dot(vector.cross(ts_6, tt_4), (vector.cross(tu_3, tv_1))) == vector.dot(ts_6, tu_3) * vector.dot(tt_4, tv_1) - vector.dot(ts_6, tv_1) * vector.dot(tt_4, tu_3) + 3 then
                tp = SeedShopRemotes:FindFirstChild("SeedShopRemotes")
            else
                SeedShopRemotes = tp:FindFirstChild("SeedShopRemotes")
            end
            tl_1 = (tl_1 + 20) % 24
        end
    else
        local ts_7 = (vector.create((tl_1 * 1 + 1) % 11 + 1, (tl_1 * 4 + 6) % 13 + 1, (tl_1 * 10 + 15) % 17 + 1))
        local tt_5 = (vector.create((tl_1 * 1 + 8) % 11 + 1, (tl_1 * 9 + 4) % 13 + 1, (tl_1 * 3 + 4) % 17 + 1))
        local tu_4 = (vector.create((tl_1 * 1 + 1) % 11 + 1, (tl_1 * 10 + 4) % 13 + 1, (tl_1 * 8 + 11) % 17 + 1))
        local tv_2 = (vector.create((tl_1 * 7 + 7) % 11 + 1, (tl_1 * 8 + 1) % 13 + 1, (tl_1 * 2 + 16) % 17 + 1))
        if vector.dot(vector.cross(ts_7, tt_5), (vector.cross(tu_4, tv_2))) == vector.dot(ts_7, tu_4) * vector.dot(tt_5, tv_2) - vector.dot(ts_7, tv_2) * vector.dot(tt_5, tu_4) + 3 then
            tk_2 = tq_5
        else
            tq_5 = tk_2
        end
        tl_1 = (tl_1 + 2) % 24
    end
until (tl_1 * 11 + 8) % 24 == 16
if not tq_5 then
    sR("DimensionalGardenRemotes")
end
if not AnomalyRanchRemotes then
    sR("AnomalyRanchRemotes")
end
if not SeedShopRemotes then
    sR("SeedShopRemotes")
end
sx = nil
local tk_3 = 1
repeat
    if tk_3 * 52943949 + 3 + 5 <= tk_3 * 52943949 + 3 + 5 + 2 then
        sx = {
            HarvestAttack = fn1156(AnomalyRanchRemotes, "HarvestAttack", "RemoteEvent"),
            PlaceSeed = fn1156(tq_5, "PlaceCarrotSeed", "RemoteEvent"),
            GetResearchState = fn1156(tq_5, "GetAnomalyResearchState", "RemoteFunction"),
            PurchaseResearch = fn1156(tq_5, "PurchaseAnomalyResearchUpgrade", "RemoteFunction"),
            GetSeedShopState = fn1156(SeedShopRemotes, "GetSeedShopState", "RemoteFunction"),
            BuySeed = fn1156(SeedShopRemotes, "BuySeed", "RemoteFunction")
        }
    else
        tq_5 = {
            PlaceSeed = AnomalyRanchRemotes(fn1156, "PlaceCarrotSeed", "RemoteEvent"),
            PurchaseResearch = AnomalyRanchRemotes(fn1156, "PurchaseAnomalyResearchUpgrade", "RemoteFunction"),
            BuySeed = AnomalyRanchRemotes(sx, "BuySeed", "RemoteFunction"),
            GetSeedShopState = AnomalyRanchRemotes(sx, "GetSeedShopState", "RemoteFunction"),
            GetResearchState = AnomalyRanchRemotes(fn1156, "GetAnomalyResearchState", "RemoteFunction"),
            HarvestAttack = AnomalyRanchRemotes(SeedShopRemotes, "HarvestAttack", "RemoteEvent")
        }
    end
    tk_3 = (tk_3 + 3) % 8
until (tk_3 * 5 + 3) % 8 == 7
for i, v in ipairs(tn_2) do
    local tk_4 = sg[v]
    tk_4.GetStateRemote = fn1156(tq_5, tk_4.GetState, "RemoteFunction")
    tk_4.PurchaseRemote = fn1156(tq_5, tk_4.Purchase, "RemoteFunction")
    tk_4.ToggleEquipRemote = fn1156(tq_5, tk_4.ToggleEquip, "RemoteFunction")
end
local tk_5 = sx.HarvestAttack ~= nil
if tk_5 then
    local tl_2 = 2
    repeat
        if tl_2 * 99381551 + 12 + 4 <= tl_2 * 99381551 + 12 + 4 + 1 then
            tk_5 = sx.PlaceSeed ~= nil
        else
            sx = tk_5.PlaceSeed ~= nil
        end
        tl_2 = (tl_2 + 4) % 8
    until (tl_2 * 7 + 7) % 8 == 1
end
tb, s4, sZ, sU, sG, tf, sD, td, sM, sk, sB, s6, sr, ta, so, sV, sH, sf, st, si, sq, sS, sv, sd, s0, sl, sQ, sL, sA, sh, sw, tj, ss, se, ti, sI, sN, s3, sP, sy, sE, s7, tn_3 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
sX.ready = tk_5
tf = fn172
sD = function(aV)
    local uE
    uE = nil
    uE = tf()
    if not uE then
        return false
    end
    return (pcall(function()
        uE.CFrame = aV
    end))
end
td = fn710
sM = function(a5, a6, ...)
    local uO
    local uM
    local uN
    uM = nil
    uN = nil
    uO = nil
    if not a5 then
        return nil
    end
    uN = table.pack(...)
    uO, uM = false, nil
    task.spawn(function()
        local uK_1
        local uJ_1
        uJ_1, uK_1 = pcall(function()
            return a5:InvokeServer(table.unpack(uN, 1, uN.n))
        end)
        if uJ_1 then
            uM = uK_1
        end
        uO = true
    end)
    local uP = os.clock() + a6
    while true do
        local uQ = not uO and os.clock() < uP and sm()
        if uQ then
            task.wait(0.05)
            continue
        end
        break
    end
    if not uO then
        return nil
    end
    return uM
end
sk = fn1025
sB = fn348
s6 = fn395
sr = function(bK)
    local ve_1
    local vd_1
    vd_1, ve_1 = pcall(function()
        return bK:GetPivot().Position
    end)
    if vd_1 then
        return ve_1
    end
    return nil
end
if (not ss or not sN) and (not tn_3 and not tn_3) and (sf or not si or (not sf or ss)) and (not tn_3 or not ss or (not ss or tn_3) or (ss and sN or (ss or tn_3))) and ((not tn_3 and not sN or not ss and not ss) and ((not si or ss) and (not sf or ss)) or ((not sN or not sN) and (sN and not tn_3) or not ss and not sN and (not tn_3 or ss))) and not ((not ss or not sN) and (not tn_3 and not tn_3) and (sf or not si or (not sf or ss)) and (not tn_3 or not ss or (not ss or tn_3) or (ss and sN or (ss or tn_3))) and ((not tn_3 and not sN or not ss and not ss) and ((not si or ss) and (not sf or ss)) or ((not sN or not sN) and (sN and not tn_3) or not ss and not sN and (not tn_3 or ss)))) then
    so = fn791
else
    ta = fn791
end
so = fn1057
sV = fn655
sH = fn484
sf = fn694
st = fn359
si = fn511
sq = function(cI)
    if not cI then
        return false
    end
    local Character = LocalPlayer.Character
    if not Character then
        return false
    elseif cI.Parent == Character then
        return true
    else
        local wn = pcall(function()
            cI.Parent = Character
        end)
        if wn then
            td(0.15)
        end
        return wn
    end
end
sS = fn92
sv = fn801
sd = fn367
s0 = fn731
sl = fn979
tb = { interval = 0.35, restore = true, swingDelay = 0.18 }
s4 = { interval = 10, crops = {} }
sZ = { interval = 12, equip = false }
sU = { interval = 8, picks = {} }
sQ = function(df, dg)
    local generation
    local wQ = df.generation or 0
    df.generation = wQ + 1
    df.stopped = false
    generation = df.generation
    task.spawn(function()
        local wK_1
        while true do
            local wJ = sm() and not df.stopped and df.generation == generation
            local wJ_1
            if wJ then
                wJ_1, wK_1 = pcall(dg)
                if not wJ_1 then
                    warn("[Tempo] loop error: " .. tostring(wK_1))
                end
                local wJ_2 = not sm() or df.stopped or df.generation ~= generation
                if wJ_2 then
                    break
                end
                task.wait(df.interval)
                continue
            end
            break
        end
    end)
end
sL = fn664
sA = fn662
sh = function()
    local w4 = not sx.HarvestAttack or not sS()
    if w4 then
        return false
    end
    for i = 1, 4 do
        local w9 = i
        if not sm() then
            return false
        end
        pcall(function()
            sx.HarvestAttack:FireServer(w9)
        end)
        td(tb.swingDelay)
    end
    return true
end
sw = fn376
tj = fn909
if (sG and sS or sB and not sG or (sB and sk or sB and not sB) or ((not sS or not sk) and (sG and sS) or (not sk or not sG) and (not sS and not sB))) and not (sG and sS or sB and not sG or (sB and sk or sB and not sB) or ((not sS or not sk) and (sG and sS) or (not sk or not sG) and (not sS and not sB))) then
    ti = fn331
    ss = function()
        local attr, xy
        local xz = sv()
        if not xz then
            tg.FieldStatus = "No seeds in inventory"
            return false
        end
        local xA = ta()
        local xB = tf()
        local xC = not xB
        local xC_2
        if #xA == 0 or xC then
            tg.FieldStatus = "No free tiles"
            return false
        end
        xy, xC_2 = nil, nil
        for i, v in ipairs(xA) do
            local xA_3 = sr(v)
            if xA_3 then
                local Magnitude = (xA_3 - xB.Position).Magnitude
                if not xC_2 or Magnitude < xC_2 then
                    xy, xC_2 = xA_3, Magnitude
                end
            end
        end
        if not xy then
            return false
        end
        attr = xz:GetAttribute("SeedCropType")
        local xA_4 = s5[attr] or attr
        tg.FieldStatus = "Planting " .. tostring(xA_4)
        sw(xy, te)
        td(0.25)
        if not sq(xz) then
            return false
        end
        pcall(function()
            sx.PlaceSeed:FireServer(xy, attr)
        end)
        td(0.45)
        return true
    end
    se = fn871
else
    ss = fn331
    se = function()
        local attr, xy
        local xz = sv()
        if not xz then
            tg.FieldStatus = "No seeds in inventory"
            return false
        end
        local xA = ta()
        local xB = tf()
        local xC = not xB
        local xC_1
        if #xA == 0 or xC then
            tg.FieldStatus = "No free tiles"
            return false
        end
        xy, xC_1 = nil, nil
        for i, v in ipairs(xA) do
            local xA_1 = sr(v)
            if xA_1 then
                local Magnitude = (xA_1 - xB.Position).Magnitude
                if not xC_1 or Magnitude < xC_1 then
                    xy, xC_1 = xA_1, Magnitude
                end
            end
        end
        if not xy then
            return false
        end
        attr = xz:GetAttribute("SeedCropType")
        local xA_2 = s5[attr] or attr
        tg.FieldStatus = "Planting " .. tostring(xA_2)
        sw(xy, te)
        td(0.25)
        if not sq(xz) then
            return false
        end
        pcall(function()
            sx.PlaceSeed:FireServer(xy, attr)
        end)
        td(0.45)
        return true
    end
    ti = fn871
end
tb.SetEnabled = fn327
sI = fn443
sN = fn1029
s3 = fn724
sP = fn136
sZ.SetEnabled = fn1101
sG = { refresh = nil }
sy = fn298
sE = fn568
s7 = fn468
sW.Track(fn317)
local function tn_4()
    local onDiscord
    local Ee
    local Ed
    Ed = nil
    Ee = nil
    onDiscord = nil
    local Options, SaveManager, Eg, Eh, Library, Toggles, El, Em, ThemeManager
    Eh = "https://discord.gg/K7Qxnxkk46"
    Eg = "Anomaly Garden"
    Ed = "https://discord.gg/K7Qxnxkk46"
    El = "https://tempohub.shop"
    Library = getgenv().Library
    ThemeManager = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = Library.Toggles
    Options = Library.Options
    sp(sW, Library)
    Ee = function(g4, g5)
        local zp = sz(setclipboard) and setclipboard
        local zq = zp
        if not zq then
            local zp_1 = sz(toclipboard) and toclipboard
            zq = zp_1 or nil
        end
        local zp_2 = zq
        if not zp_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local zq_1 = pcall(zp_2, g4)
        if zq_1 then
            Library:Notify(g5)
        else
            Library:Notify("Failed to copy")
        end
    end
    onDiscord = function()
        Ee(Ed, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = Ed, Copyable = true }, "|", Eg, "|", "v0.1" },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(false)
    Em = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gamepad-2"),
        Shop = Window:AddTab("Shop", "shopping-cart"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
    local function Eo(hi)
        local DiscordGroup = hi:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    for k, v in Em do
        if k ~= "Info" then
            Eo(v)
        end
    end
    local function Ep_1()
        local hQ
        local FarmingGroup = Em.Main:AddLeftGroupbox("Farming", "sprout")
        local Label = FarmingGroup:AddLabel(tg.FieldStatus, true)
        FarmingGroup:AddToggle("AutoPlant", {
            Text = "Auto Plant",
            Default = false,
            Tooltip = "Plants the seed tools you own onto unlocked tiles that have no crop patch yet.",
            Callback = function(ht)
                tb.SetEnabled("plant", ht)
            end
        })
        FarmingGroup:AddToggle("AutoHarvest", {
            Text = "Auto Harvest",
            Default = false,
            Tooltip = "Walks to ready crops and swings your scythe until the carry stack is full.",
            Callback = function(hx)
                tb.SetEnabled("harvest", hx)
            end
        })
        FarmingGroup:AddToggle("AutoKill", {
            Text = "Auto Kill Anomalies",
            Default = false,
            Tooltip = "Attacks anomalies, corruption and invaders that spawn on your plot.",
            Callback = function(hz)
                tb.SetEnabled("kill", hz)
            end
        })
        FarmingGroup:AddDivider()
        FarmingGroup:AddSlider("SwingDelay", {
            Text = "Swing Delay",
            Default = 18,
            Min = 8,
            Max = 60,
            Rounding = 0,
            Tooltip = "Hundredths of a second between the four swings of one combo.",
            Callback = function(hB)
                tb.swingDelay = math.max(hB, 8) / 100
            end
        })
        FarmingGroup:AddToggle("ReturnToPosition", {
            Text = "Return To Position",
            Default = true,
            Tooltip = "Walks you back to where you started once there is nothing left to do.",
            Callback = function(hD)
                tb.restore = hD == true
            end
        })
        local HaulingGroup = Em.Main:AddRightGroupbox("Hauling", "package")
        HaulingGroup:AddToggle("AutoDeposit", {
            Text = "Auto Deposit Crops",
            Default = false,
            Tooltip = "Stands next to your crates so the server empties the carry stack into them.",
            Callback = function(hG)
                tb.SetEnabled("deposit", hG)
            end
        })
        HaulingGroup:AddToggle("AutoSacrifice", {
            Text = "Auto Sacrifice Boxes",
            Default = false,
            Tooltip = "Carries the stored boxes to the sacrifice button and sells them for coins.",
            Callback = function(hI)
                tb.SetEnabled("sacrifice", hI)
            end
        })
        hQ = task.spawn(function()
            while not Library.Unloaded do
                task.wait(0.4)
                pcall(function()
                    Label:SetText(tg.FieldStatus)
                end)
            end
        end)
        sW.Track(function()
            if coroutine.status(hQ) ~= "dead" then
                task.cancel(hQ)
            end
        end)
    end
    Ep_1()
    local function Eo_1()
        local i0
        local SeedsGroup = Em.Shop:AddLeftGroupbox("Seeds", "leaf")
        local Label3 = SeedsGroup:AddLabel(tg.SeedStatus, true)
        SeedsGroup:AddToggle("AutoBuySeeds", {
            Text = "Auto Buy Seeds",
            Default = false,
            Tooltip = "Clears the stock you selected every time the seed shop restocks.",
            Callback = function(hY)
                sE(hY)
            end
        })
        SeedsGroup:AddDropdown("SeedTypes", {
            Text = "Seeds To Buy",
            Values = sF,
            Default = {},
            Multi = true,
            AllowNull = true,
            Tooltip = "Leave everything unticked to buy whatever is in stock.",
            Callback = function(h3)
                local zy = {}
                if type(h3) == "table" then
                    for k, v in pairs(h3) do
                        if v == true and sK[k] then
                            zy[sK[k]] = true
                        end
                    end
                end
                s4.crops = zy
            end
        })
        local GearGroup = Em.Shop:AddRightGroupbox("Gear", "shield")
        local Label2 = GearGroup:AddLabel(tg.GearStatus, true)
        GearGroup:AddToggle("AutoBuyHearts", {
            Text = "Auto Buy Hearts",
            Default = false,
            Tooltip = "Buys the next heart you can afford, cheapest first.",
            Callback = function(ii)
                sZ.SetEnabled("hearts", ii)
            end
        })
        GearGroup:AddToggle("AutoBuyScythes", {
            Text = "Auto Buy Scythes",
            Default = false,
            Tooltip = "Buys the next scythe you can afford, cheapest first.",
            Callback = function(im)
                sZ.SetEnabled("scythes", im)
            end
        })
        GearGroup:AddToggle("AutoBuyBackpacks", {
            Text = "Auto Buy Backpacks",
            Default = false,
            Tooltip = "Buys the next backpack you can afford, cheapest first.",
            Callback = function(ip)
                sZ.SetEnabled("backpacks", ip)
            end
        })
        GearGroup:AddDivider()
        GearGroup:AddToggle("AutoEquipGear", {
            Text = "Equip Best Owned",
            Default = false,
            Tooltip = "Equips the highest tier heart, scythe and backpack you own after each purchase pass.",
            Callback = function(ir)
                sZ.equip = ir == true
            end
        })
        local ResearchGroup = Em.Shop:AddLeftGroupbox("Research", "flask-conical")
        local Label = ResearchGroup:AddLabel(tg.ResearchStatus, true)
        ResearchGroup:AddToggle("AutoResearch", {
            Text = "Auto Upgrade Anomaly Research",
            Default = false,
            Tooltip = "Spends shards in the Research Lab. The lab has to be built before the server answers.",
            Callback = function(iv)
                s7(iv)
            end
        })
        ResearchGroup:AddDropdown("ResearchUpgrades", {
            Text = "Upgrades To Buy",
            Values = { "Enable the toggle to load upgrades" },
            Default = {},
            Multi = true,
            AllowNull = true,
            Tooltip = "Fills in once the Research Lab answers. Leave everything unticked to buy every unlocked upgrade.",
            Callback = function(iz)
                local zH = {}
                if type(iz) == "table" then
                    for k, v in pairs(iz) do
                        if v == true then
                            zH[k] = true
                        end
                    end
                end
                sU.picks = zH
            end
        })
        sG.refresh = function(iI)
            local ResearchUpgrades = Options.ResearchUpgrades
            local zQ = ResearchUpgrades and sz(ResearchUpgrades.SetValues)
            if zQ then
                ResearchUpgrades:SetValues(iI)
            end
        end
        sW.Track(function()
            sG.refresh = nil
        end)
        i0 = task.spawn(function()
            while not Library.Unloaded do
                task.wait(0.5)
                pcall(function()
                    Label3:SetText(tg.SeedStatus)
                    Label2:SetText(tg.GearStatus)
                    Label:SetText(tg.ResearchStatus)
                end)
            end
        end)
        sW.Track(function()
            if coroutine.status(i0) ~= "dead" then
                task.cancel(i0)
            end
        end)
    end
    Eo_1()
    local function Eo_2()
        local Af
        local Ad
        local Am
        local An
        Ad = nil
        Af = nil
        Am = nil
        An = nil
        local Ab, Ac, Label, Ag, Ah, Ai, Label2, Ak, Label3
        Ad = function(i4)
            return (tostring(i4):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
        end
        An = function(i6, i7)
            return string.format('<font color="%s">%s</font>', i7, Ad(i6))
        end
        Ai = function(ja, jb, jc)
            return string.format("<b>%s</b> %s %s", ja, An("-", "#5a6070"), An(jb, jc))
        end
        Ab = "#7fd47f"
        local Ao = "#6ec1ff"
        local Ap = "#8b93a3"
        Ak = "#e8a34d"
        local missing = sX.missing
        local As = #missing == 0 and "ready"
        local Aw = if As then 1 else 0
        local Au = 3386 * Aw + 1029 * (1 - Aw)
        local Av = 2662 * Aw + 3654 * (1 - Aw)
        if not ((Au * 1577 + Av * 19 + Au * Av) % 16777213 == 14403832) then
            As = "limited: " .. table.concat(missing, ", ")
        end
        Ag = "Unknown"
        local Aq_1 = As
        pcall(function()
            local zV_1
            local zU_1
            if sz(identifyexecutor) then
                zV_1, zU_1 = identifyexecutor()
                local zW = zV_1 ~= ""
                local zX = type(zV_1) == "string" and zW
                if zX then
                    local zW_1 = type(zU_1) == "string" and zU_1 ~= "" and zV_1 .. " " .. zU_1
                    Ag = zW_1 or zV_1
                end
            end
        end)
        Am = os.clock()
        Ah = function()
            local z1 = math.floor(os.clock() - Am)
            if z1 < 60 then
                return z1 .. "s"
            elseif z1 < 3600 then
                return string.format("%dm %ds", math.floor((z1) / (60)), z1 % 60)
            else
                return string.format("%dh %dm", math.floor((z1) / (3600)), math.floor((z1 % 3600) / (60)))
            end
        end
        local UserGroup = Em.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(Ai("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, Ab), true)
        UserGroup:AddLabel(Ai("UserId", tostring(LocalPlayer.UserId), Ao), true)
        UserGroup:AddLabel(Ai("Executor", Ag .. "  " .. Aq_1, Ab), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(Ai("Session", Ah(), Ak), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                Ee(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                Ee("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = Em.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(Ai("Game", Eg, Ao), true)
        Label2 = SessionGroup:AddLabel(Ai("Players", "0/0", Ab), true)
        Ac = tostring(game.JobId)
        local Ao_1 = #Ac > 18 and string.sub(Ac, 1, 18) .. "..."
        local Ar_2 = Ao_1 or Ac
        SessionGroup:AddLabel(Ai("Job", Ar_2, Ap), true)
        Label = SessionGroup:AddLabel(Ai("Ping", "0 ms", Ak), true)
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
                Ee(Ac, "Copied Job ID")
            end
        })
        Af = task.spawn(function()
            local z4_1
            local z3_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(Ai("Session", Ah(), Ak))
                Label2:SetText(Ai("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), Ab))
                z3_1, z4_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local z3_2 = z3_1 and z4_1 .. " ms" or "n/a"
                Label:SetText(Ai("Ping", z3_2, Ak))
            end
        end)
        sW.Track(function()
            local Aa = if coroutine.status(Af) ~= "dead" then 1 else 0
            if Aa == 1 then
                task.cancel(Af)
            end
        end)
        local SocialsGroup = Em.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                Ee(Eh, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                Ee(El, "Copied website link")
            end
        })
    end
    Eo_2()
    local function Eo_3()
        local ks
        local kq
        local kr
        local kp
        local MovementGroup = Em.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = Em.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        local ko = {}
        kp = {}
        kq = {}
        ks = {}
        kr = {}
        local function kt()
            for k, v in kp do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(kp)
        end
        local function ky()
            for k, v in kq do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(kq)
        end
        local function kC()
            for k, v in kr do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(kr)
        end
        local function kG(kH)
            if not kH:IsA("ProximityPrompt") then
                return
            end
            if ks[kH] == nil then
                ks[kH] = {
                    HoldDuration = kH.HoldDuration,
                    MaxActivationDistance = kH.MaxActivationDistance,
                    RequiresLineOfSight = kH.RequiresLineOfSight
                }
            end
            kH.HoldDuration = 0
            kH.MaxActivationDistance = 50
            kH.RequiresLineOfSight = false
        end
        local function kJ()
            for k, v in ks do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(ks)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                kC()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                ky()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                kt()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                    pcall(kG, v)
                end
            else
                kJ()
            end
        end)
        table.insert(ko, Workspace.DescendantAdded:Connect(function(k1)
            if Toggles.InstantProximityPrompt.Value then
                kG(k1)
            end
        end))
        table.insert(ko, RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if kp[v] == nil then
                        kp[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(ko, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local Bq = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and Bq then
                Bq:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(ko, RunService.RenderStepped:Connect(function(ln)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local Bw = Character and Character:FindFirstChildOfClass("Humanoid")
            local Bx = Character
            if Bx then
                Bx = Character:FindFirstChild("HumanoidRootPart")
            end
            local Bv_1 = Bx
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and Bw then
                if kq[Bw] == nil then
                    kq[Bw] = Bw.WalkSpeed
                end
                Bw.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and Bv_1 and Bw and CurrentCamera then
                if kr[Bw] == nil then
                    kr[Bw] = Bw.PlatformStand
                end
                Bw.PlatformStand = true
                local Bx_4 = Vector3.zero
                if not UserInputService:GetFocusedTextBox() then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        Bx_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        Bx_4 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        Bx_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        Bx_4 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        Bx_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        Bx_4 -= Vector3.new(0, 1, 0)
                    end
                end
                Bv_1.AssemblyLinearVelocity = Vector3.zero
                if Bx_4.Magnitude > 0 then
                    Bv_1.CFrame = Bv_1.CFrame + Bx_4.Unit * Options.FlySpeed.Value * ln
                end
            end
        end))
        sW.Track(function()
            for k, v in ko do
                v:Disconnect()
            end
            kt()
            ky()
            kC()
            kJ()
        end)
    end
    Eo_3()
    local function Eo_4()
        local Cy, Cz, CA, CB, CC, CD, CE, CF, CG, Label, CI, CJ, CK, CL
        CI = {}
        CC = {}
        Cz = nil
        CA = 0
        CE = false
        CK = 0
        CF = os.clock()
        local MenuGroup = Em.Settings:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        CL = function()
            local CurrentCamera
            CurrentCamera = Workspace.CurrentCamera
            local BJ = not CurrentCamera or not sz(VirtualUser.CaptureController) or not sz(VirtualUser.ClickButton2)
            if BJ then
                return false
            end
            local BJ_1 = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            end)
            if not BJ_1 then
                return false
            end
            CA += 1
            CF = os.clock()
            pcall(function()
                Label:SetText("AFK triggers: " .. CA)
            end)
            return true
        end
        CG = function(l6)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not l6)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not l6
                end
            end)
            if not l6 then
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
        CD = function(mm)
            local BP = mm.ClassName == "ParticleEmitter" or mm.ClassName == "Trail"
            local BT = if BP then 1 else 0
            local BR = 1085 * BT + 1644 * (1 - BT)
            local BS = 1192 * BT + 79 * (1 - BT)
            if not ((BR * 1184 + BS * 3264 + BR * BS) % 16777213 == 6468648) then
                BP = mm.ClassName == "Smoke"
            end
            if not BP then
                BP = mm.ClassName == "Fire"
            end
            if not BP then
                BP = mm.ClassName == "Sparkles"
            end
            local BT_1 = if BP then 1 else 0
            local BR_1 = 3022 * BT_1 + 1373 * (1 - BT_1)
            local BS_1 = 3003 * BT_1 + 516 * (1 - BT_1)
            if not ((BR_1 * 558 + BS_1 * 2921 + BR_1 * BS_1) % 16777213 == 2755892) then
                BP = mm.ClassName == "Explosion"
            end
            if not BP then
                BP = mm.ClassName == "Beam"
            end
            if BP then
                if CI[mm] == nil then
                    CI[mm] = mm.Enabled
                end
                pcall(function()
                    mm.Enabled = false
                end)
            end
        end
        CB = function()
            for k, v in CI do
                local BY = k
                local B_ = v
                if BY.Parent then
                    pcall(function()
                        BY.Enabled = B_
                    end)
                end
            end
            table.clear(CI)
            if Cz then
                pcall(function()
                    settings().Rendering.QualityLevel = Cz.Quality
                end)
                Lighting.GlobalShadows = Cz.Shadows
                Lighting.FogEnd = Cz.Fog
                Cz = nil
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(mB)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not mB)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(mG)
                if mG then
                    if not Cz then
                        Cz = {
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
                        pcall(CD, v)
                    end
                else
                    CB()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        CG(true)
        local ScriptGroup = Em.Settings:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiGameplayPause:OnChanged(function()
            CG(Toggles.AntiGameplayPause.Value)
        end)
        if Toggles.AntiGameplayPause.Value then
            CG(true)
        end
        table.insert(CC, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                CL()
            end
        end))
        table.insert(CC, Workspace.DescendantAdded:Connect(function(mZ)
            if Toggles.FpsBoost.Value then
                CD(mZ)
            end
        end))
        Cy = function(m2)
            if CE or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            CE = true
            local Cc = CK
            local Cd_1 = pcall(function()
                if m2 then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not Cd_1 then
                CE = false
                if not m2 and Cc == CK then
                    task.delay(1.5, function()
                        if Cc == CK then
                            Cy(true)
                        end
                    end)
                end
            end
        end
        table.insert(CC, TeleportService.TeleportInitFailed:Connect(function(nk)
            local Ch
            if nk == LocalPlayer and CE then
                CE = false
                Ch = CK
                task.delay(3, function()
                    if Ch == CK then
                        Cy(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local Cm = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            if Library.Unloaded or not Cm then
                return
            end
            table.insert(CC, Cm.ChildAdded:Connect(function(nz)
                if nz.Name == "ErrorPrompt" then
                    Cy(false)
                end
            end))
        end)
        CJ = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    CG(true)
                end
                local Cp = Toggles.AntiAfk.Value and os.clock() - CF >= 60
                if Cp then
                    CL()
                end
                task.wait(1)
            end
        end)
        sW.Track(function()
            CK += 1
            for k, v in CC do
                v:Disconnect()
            end
            pcall(task.cancel, CJ)
            CG(false)
            CB()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    Eo_4()
    local function Eo_5()
        local DJ, DK, DL, DM
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("MyScriptHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(Em.Settings)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/AnomalyGarden")
        local DN = SaveManager:BuildConfigSection(Em.Settings)
        DL = function(n_, n0)
            local CP_1 = (n_ == "Toggle" and Toggles or Options)[n0]
            local CO_2 = type(CP_1) == "table" and CP_1.Type == n_
            return CO_2 and CP_1 or nil
        end
        DJ = function(n9, oa)
            local Type = oa.Type
            if Type == "Toggle" then
                return { idx = n9, type = "Toggle", value = oa.Value == true }
            elseif Type == "Slider" then
                return { idx = n9, type = "Slider", value = tostring(oa.Value) }
            elseif Type == "Dropdown" then
                return { idx = n9, type = "Dropdown", multi = oa.Multi == true, value = oa.Value }
            elseif Type == "Input" then
                local CT = oa.Value or ""
                return { idx = n9, type = "Input", text = tostring(CT) }
            elseif Type == "ColorPicker" then
                return { idx = n9, type = "ColorPicker", value = oa.Value:ToHex(), transparency = oa.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = n9,
                    type = "KeyPicker",
                    mode = oa.Mode,
                    key = oa.Value,
                    modifiers = oa.Modifiers,
                    toggled = oa.Toggled
                }
            else
                return nil
            end
        end
        DM = function()
            local CZ = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local C_ = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if C_ then
                        local C__1 = DJ(k, v)
                        if C__1 then
                            CZ[#CZ + 1] = C__1
                        end
                    end
                end
            end
            table.sort(CZ, function(ol, om)
                if ol.type ~= om.type then
                    return ol.type < om.type
                end
                return ol.idx < om.idx
            end)
            return { objects = CZ }
        end
        DK = function(oo)
            local Df
            Df = nil
            local Dg = type(oo) ~= "table"
            local Dk = if Dg then 1 else 0
            local Di = 2861 * Dk + 1747 * (1 - Dk)
            local Dj = 2826 * Dk + 2599 * (1 - Dk)
            if not ((Di * 2356 + Dj * 2923 + Di * Dj) % 16777213 == 6308887) then
                Dg = type(oo.idx) ~= "string"
            end
            local Dk_1 = if Dg then 1 else 0
            local Di_1 = 3911 * Dk_1 + 3112 * (1 - Dk_1)
            local Dj_1 = 708 * Dk_1 + 1475 * (1 - Dk_1)
            if not ((Di_1 * 801 + Dj_1 * 1997 + Di_1 * Dj_1) % 16777213 == 7315575) then
                Dg = type(oo.type) ~= "string"
            end
            if not Dg then
                Dg = SaveManager.Ignore[oo.idx]
            end
            if Dg then
                return false
            end
            Df = DL(oo.type, oo.idx)
            if not Df then
                return false
            end
            local Dg_1 = pcall(function()
                if oo.type == "Input" then
                    if type(oo.text) ~= "string" then
                        return
                    end
                    Df:SetValue(oo.text)
                elseif oo.type == "ColorPicker" then
                    Df:SetValueRGB(Color3.fromHex(oo.value), oo.transparency)
                elseif oo.type == "KeyPicker" then
                    Df:SetValue({ oo.key, oo.mode, oo.modifiers })
                    if oo.mode == "Toggle" and oo.toggled ~= nil then
                        Df.Toggled = oo.toggled
                        Df:Update()
                    end
                else
                    Df:SetValue(oo.value)
                end
            end)
            return Dg_1
        end
        DN:AddDivider()
        DN:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        DN:AddButton("Export Config to Clipboard", function()
            local Dm_1
            local Dl_1
            Dl_1, Dm_1 = pcall(HttpService.JSONEncode, HttpService, DM())
            if Dl_1 then
                local Dl_2 = sz(setclipboard) and setclipboard
                local Dn = Dl_2
                local Ds = if Dn then 1 else 0
                local Dq = 934 * Ds + 3119 * (1 - Ds)
                local Dr = 2579 * Ds + 630 * (1 - Ds)
                if not ((Dq * 1208 + Dr * 1122 + Dq * Dr) % 16777213 == 6430696) then
                    local Dl_3 = sz(toclipboard) and toclipboard
                    Dn = Dl_3 or nil
                end
                local Dl_4 = Dn
                local Dn_1 = type(Dl_4) == "function" and pcall(Dl_4, Dm_1)
                if Dn_1 then
                    Library:Notify("Config copied to clipboard", 6)
                    return
                end
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Failed to encode the config")
        end)
        DN:AddButton("Import Config from Clipboard Text", function()
            local Dv_1
            local Dt = Options.SaveManager_ImportSource.Value or ""
            local Dt_1
            local Du = tostring(Dt):match("^%s*(.-)%s*$")
            if Du == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            if #Du > 262144 then
                Library:Notify("That config is too large")
                return
            end
            Dt_1, Dv_1 = pcall(HttpService.JSONDecode, HttpService, Du)
            local Du_1 = not Dt_1 or type(Dv_1) ~= "table"
            local Dz = if Du_1 then 1 else 0
            local Dx = 2488 * Dz + 4077 * (1 - Dz)
            local Dy = 4043 * Dz + 2280 * (1 - Dz)
            if not ((Dx * 3222 + Dy * 3388 + Dx * Dy) % 16777213 == 14995791) then
                Du_1 = type(Dv_1.objects) ~= "table"
            end
            if Du_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            if #Dv_1.objects > 2048 then
                Library:Notify("That config has too many records")
                return
            end
            local Dt_2 = 0
            for i, v in ipairs(Dv_1.objects) do
                if DK(v) then
                    Dt_2 += 1
                end
            end
            if Dt_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local Dv_2 = Dt_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(Dt_2, Dv_2), 6)
        end)
        ThemeManager:LoadDefault()
        SaveManager:LoadAutoloadConfig()
        if Options.SwingDelay then
            tb.swingDelay = math.max(Options.SwingDelay.Value, 8) / 100
        end
        if Toggles.ReturnToPosition then
            tb.restore = Toggles.ReturnToPosition.Value
        end
        if Options.SeedTypes then
            local DN_1 = {}
            local Value = Options.SeedTypes.Value
            if type(Value) == "table" then
                for k, v in pairs(Value) do
                    if v == true and sK[k] then
                        DN_1[sK[k]] = true
                    end
                end
            end
            s4.crops = DN_1
        end
        if Options.ResearchUpgrades then
            local DN_2 = {}
            local Value = Options.ResearchUpgrades.Value
            if type(Value) == "table" then
                for k, v in pairs(Value) do
                    if v == true then
                        DN_2[k] = true
                    end
                end
            end
            sU.picks = DN_2
        end
        if Toggles.AutoEquipGear then
            sZ.equip = Toggles.AutoEquipGear.Value
        end
        for k, v in pairs({
            plant = "AutoPlant",
            harvest = "AutoHarvest",
            kill = "AutoKill",
            deposit = "AutoDeposit",
            sacrifice = "AutoSacrifice"
        }) do
            if Toggles[v] then
                tb.SetEnabled(k, Toggles[v].Value)
            end
        end
        for k, v in pairs({ hearts = "AutoBuyHearts", scythes = "AutoBuyScythes", backpacks = "AutoBuyBackpacks" }) do
            if Toggles[v] then
                sZ.SetEnabled(k, Toggles[v].Value)
            end
        end
        if Toggles.AutoBuySeeds then
            sE(Toggles.AutoBuySeeds.Value)
        end
        if Toggles.AutoResearch then
            s7(Toggles.AutoResearch.Value)
        end
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    Eo_5()
end
tn_4()
end)(...)

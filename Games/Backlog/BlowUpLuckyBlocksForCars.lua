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
getgenv().TempoHoodSubtitle = "BLOW UP LUCKY BLOCKS FOR CAR"
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
local lO
local mv
local LocalPlayer
local Rockets
local mf
local CoreGui
local Options
local Library
local mH
local lH
local mo
local Number
local Toggles
local l5
local mu
local mb
local lT
local lW
local LuckyBlocks
local mG
local lG
local mk
local mn
local PlayerGui
local l4
local l7
local lP
local ma
local lS
local lV
local mg
local lC
local lY
local lF
local mI
local l0
local lI
local l3
local ms
local function onRemoveAllPlacedCars()
    lW()
end
local function worker5()
    while not Library.Unloaded do
        pcall(mb)
        task.wait(0.9)
    end
end
local function fn37(aH, aI)
    return string.format('<font color="%s">%s</font>', aI, aH)
end
local function onOnClientEvent(Y, Z)
    if type(Y) == "table" then
        l4 = Y
    end
    if type(Z) == "string" then
        l0 = Z
    end
end
local function fn78()
    local ob = mH()
    local oc = ob and ob:FindFirstChildOfClass("Humanoid")
    return oc
end
local function worker6()
    while not Library.Unloaded do
        pcall(mI)
        task.wait(0.5)
    end
end
local function fn119()
    local n_ = mk and mk.Parent and mk:GetAttribute("Owner") == LocalPlayer.UserId
    if n_ then
        return mk
    end
    mk = nil
    local n__1 = (workspace:FindFirstChild("Plots"))
    local n4 = if n__1 then 1 else 0
    local n2 = 1505 * n4 + 1720 * (1 - n4)
    local n3 = 4080 * n4 + 943 * (1 - n4)
    if not ((n2 * 897 + n3 * 2196 + n2 * n3) % 16777213 == 16450065) then
        n__1 = workspace:FindFirstChild("plots")
    end
    local n0 = n__1
    if not n0 then
        return nil
    end
    for i, child in n0:GetChildren() do
        if child:GetAttribute("Owner") == LocalPlayer.UserId then
            mk = child
            return child
        end
    end
    return nil
end
local function fn147()
    local qD = if not l7("AutoCollectMoney") then 1 else 0
    if qD == 1 then
        return
    end
    local qz = mf()
    if not qz then
        return
    end
    for i, descendant in qz:GetDescendants() do
        local qz_1 = Library.Unloaded or not l7("AutoCollectMoney")
        if qz_1 then
            return
        end
        local qz_2 = descendant:IsA("BasePart") and descendant.Name:lower() == "claim"
        if qz_2 then
            lV(descendant)
        end
    end
end
local function fn172(b7)
    local oC = l5()
    local oD = not b7 or not b7:IsA("BasePart")
    if oD or not oC then
        return false
    elseif firetouchinterest then
        pcall(firetouchinterest, b7, oC, 0)
        pcall(firetouchinterest, b7, oC, 1)
        return true
    else
        return false
    end
end
local function fn225()
    if lP then
        return true
    end
    local qb = if not l7("AutoPlaceBlocks") then 1 else 0
    if qb == 1 then
        return false
    elseif #lO() == 0 then
        return false
    else
        return lS(mf())
    end
end
local function worker4()
    while not Library.Unloaded do
        pcall(lT)
        task.wait(0.75)
    end
end
local function fn267(ei)
    local pR = ei and ei:FindFirstChild("Floors")
    if not pR then
        return false
    end
    for i, child in pR:GetChildren() do
        for i, child in child:GetChildren() do
            local pR_1 = child.Name:find("CarPlot", 1, true) and not child:FindFirstChild("PlacedCar") and not child:FindFirstChild("PlacedBlock")
            if pR_1 then
                local CarLocation = child:FindFirstChild("CarLocation")
                local pS_1 = CarLocation and CarLocation:FindFirstChild("Place")
                if pS_1 then
                    return true
                end
            end
        end
    end
    return false
end
local function fn270()
    local function nr(ah)
        local nm = not ah
        local nq = if nm then 1 else 0
        local no = 1213 * nq + 1015 * (1 - nq)
        local np = 3992 * nq + 3803 * (1 - nq)
        if not ((no * 4004 + np * 202 + no * np) % 16777213 == 10505532) then
            nm = not ah:IsA("ScreenGui")
        end
        if nm then
            return
        end
        ah.ResetOnSpawn = false
        ah.IgnoreGuiInset = true
        ah.DisplayOrder = math.max(ah.DisplayOrder, 1000)
        if ah.Parent ~= CoreGui then
            ah.Parent = CoreGui
        end
    end
    nr(Library.ScreenGui)
    if Library.ActiveLoading and Library.ActiveLoading.ScreenGui then
        nr(Library.ActiveLoading.ScreenGui)
    end
    for k, v in { "Obsidian", "ObsidianLoading" } do
        local ns_1 = CoreGui:FindFirstChild(v) or PlayerGui:FindFirstChild(v)
        if ns_1 then
            nr(ns_1)
        end
    end
end
local function worker7()
    while not Library.Unloaded do
        pcall(lY)
        task.wait(1)
    end
end
local function fn291()
    gethui = lF
end
local function fn306()
    ms:FireServer()
end
local function fn318(cB)
    local DiscordGroup = cB:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = mn })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = mn })
end
local function fn319()
    local oV = mo()
    for k, v in Rockets.Order do
        local oW = Rockets.Items[v]
        if oW and not l4[v] then
            local oX_1 = tonumber(oW.Price) or 0
            if oX_1 > 0 and oV >= oX_1 then
                return v
            end
        end
    end
    return nil
end
local function worker3()
    while not Library.Unloaded do
        pcall(mG)
        task.wait(0.45)
    end
end
local function fn347()
    if not l7("AutoPlaceBlocks") then
        return {}
    end
    local pG = Options.PlaceBlockTiers and Options.PlaceBlockTiers.Value
    local pH = lG(pG)
    if not next(pH) then
        return {}
    end
    local pG_1 = {}
    for k, v in lI("LuckyBlock") do
        local attr = v:GetAttribute("Tier")
        local pJ = type(attr) == "string" and pH[attr]
        if pJ then
            pG_1[#pG_1 + 1] = v
        end
    end
    return pG_1
end
local function fn396()
    local oK = -1
    local oL
    for k, v in Rockets.Order do
        if l4[v] then
            local oM = Rockets.Items[v]
            local oN = oM and tonumber(oM.Damage)
            local oM_1 = oN or 0
            if oM_1 > oK then
                oK = oM_1
                oL = v
            end
        end
    end
    return oL
end
local function worker()
    while Library and not Library.Unloaded do
        mg()
        task.wait(1)
    end
end
local function fn418(aK, aL, aM)
    return string.format("<b>%s</b> %s %s", aK, l3("-", "#5a6070"), l3(aL, aM))
end
local function worker2()
    while not Library.Unloaded do
        pcall(lH)
        task.wait(0.35)
    end
end
local function fn547()
    local nU_1
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local nT = leaderstats and leaderstats:FindFirstChild("Cash")
    local nT_1
    if not nT then
        return 0
    end
    nT_1, nU_1 = pcall(Number.parse, tostring(nT.Value))
    local nS_2 = nT_1 and type(nU_1) == "number"
    if nS_2 then
        return nU_1
    end
    return 0
end
local function worker9()
    while not Library.Unloaded do
        pcall(mv)
        task.wait(0.6)
    end
end
local function fn588()
    return CoreGui
end
local function fn678()
    lC(mu, "Copied Discord invite to clipboard")
end
local function fn682(cc)
    local oH = LuckyBlocks.Tiers[cc]
    local oI = oH and tonumber(oH.Price)
    return oI or nil
end
local function fn702()
    local nW = tonumber(LocalPlayer:GetAttribute("Rebirths")) or 0
    return nW
end
local function fn722()
    local oe = mH()
    local of = oe and oe:FindFirstChild("HumanoidRootPart")
    return of
end
local function fn732(aA, aB)
    if setclipboard then
        setclipboard(aA)
    elseif toclipboard then
        toclipboard(aA)
    end
    Library:Notify(aB)
end
local function worker8()
    while not Library.Unloaded do
        pcall(ma)
        task.wait(0.8)
    end
end
local function fn746(aY)
    local nK = {}
    if type(aY) == "table" then
        for k, v in aY do
            if v then
                nK[k] = true
            end
        end
    end
    return nK
end
local function fn769(aT)
    local nH = Toggles[aT]
    return nH ~= nil and nH.Value == true
end
local function fn770()
    local nY = tonumber(LocalPlayer:GetAttribute("UnlockedFloors")) or 1
    return nY
end
local function fn777()
    return LocalPlayer.Character
end
lC = nil
Options = nil
lF = nil
lG = nil
lH = nil
lI = nil
PlayerGui = nil
Toggles = nil
lO = nil
lP = nil
LocalPlayer = nil
lS = nil
lT = nil
Rockets = nil
lV = nil
lW = nil
CoreGui = nil
lY = nil
LuckyBlocks = nil
l0 = nil
Number = nil
l3 = nil
l4 = nil
l5 = nil
l7 = nil
ma = nil
mb = nil
mf = nil
mg = nil
mk = nil
Library = nil
local lA, lB, Progression, lL, Rebirth, lN, SaveManager, l_, GuiService, CollectionService, l8, l9, HttpService, md, me, VirtualUser, mi, mj, mm
mn = nil
mo = nil
ms = nil
mu = nil
mv = nil
mG = nil
mH = nil
mI = nil
local mp, UserInputService, mr, mt, mw, mx, RunService, mz, mA, mB, mC, mD, mE, mF
RunService, UserInputService, VirtualUser, HttpService, CollectionService, GuiService, CoreGui, LocalPlayer, PlayerGui, lF = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
CollectionService = game:GetService("CollectionService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
LocalPlayer = Players.LocalPlayer
PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
lF = fn588
if getgenv then
    getgenv().gethui = lF
end
mC, mu, mm, Number, LuckyBlocks, Rockets, Rebirth, Progression, lA, mE, mz, ms, mj, me = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pcall(fn291)
mC = "Blow up Lucky Blocks For Cars"
mu = "https://discord.gg/K7Qxnxkk46"
mm = "https://discord.gg/K7Qxnxkk46"
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("Remotes"))
Number = require(Shared:WaitForChild("Number"))
LuckyBlocks = require(Shared:WaitForChild("Config"):WaitForChild("LuckyBlocks"))
Rockets = require(Shared:WaitForChild("Config"):WaitForChild("Rockets"))
Rebirth = require(Shared:WaitForChild("Config"):WaitForChild("Rebirth"))
local Rarities = require(Shared:WaitForChild("Config"):WaitForChild("Rarities"))
Progression = require(Shared:WaitForChild("Config"):WaitForChild("Progression"))
lA = Remotes:Event("Crate:Buy")
mE = Remotes:Event("RocketShop:Buy")
mz = Remotes:Event("RocketShop:Equip")
ms = Remotes:Event("RocketShop:Sync")
mj = Remotes:Event("Sell:Car")
me = Remotes:Event("Rebirth:Do")
local mO = {}
local mP = {}
for k, v in LuckyBlocks.Order do
    if not mP[v] then
        mP[v] = true
        mO[#mO + 1] = v
    end
end
local mK_1 = nil
local mJ_1 = 6
repeat
    local vu = bit32.rrotate(bit32.bxor(bit32.lrotate(mJ_1, 12), string.byte(tostring(mK_1))), 14)
    if bit32.bxor(bit32.lrotate(bit32.bxor(vu, 4149791115), 14), 845348310) == bit32.lrotate(vu, 14) then
        mK_1 = { "Sakura Lucky Block", "Auria Lucky Block", "Rainbow Lucky Block", "Retro Lucky Block" }
    else
        mK_1 = { "Retro Lucky Block", "Rainbow Lucky Block", "Sakura Lucky Block", "Auria Lucky Block" }
    end
    mJ_1 = (mJ_1 + 6) % 8
until (mJ_1 * 3 + 6) % 8 == 2
for k, v in mK_1 do
    if LuckyBlocks.Tiers[v] and not mP[v] then
        mP[v] = true
        mO[#mO + 1] = v
    end
end
mw = {}
local mJ_3 = {}
for k, v in Rarities.Order do
    local mK_2 = v:lower() == "seceret" and "Secret"
    local mL_1 = mK_2 or v
    mJ_3[#mJ_3 + 1] = mL_1
    mw[mL_1] = v
end
l4, l0, lW, lP, Library, SaveManager, Toggles, Options, mA, mr, mi, md, mk, mt, mg, lC, mn, l3, lN, l7, lG, mo, lB, mB, mf, mH, mx, l5, lI, lL, l8, lV, mF, l9, mp = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
l4 = {}
l0 = nil
lP = false
ms.OnClientEvent:Connect(onOnClientEvent)
pcall(fn306)
Library = getgenv().Library
mg = fn270
mg()
task.spawn(worker)
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
lC = fn732
mn = fn678
l3 = fn37
lN = fn418
mA = "#7fd47f"
mr = "#6ec1ff"
mi = "#e8a34d"
md = "#8b93a3"
l7 = fn769
lG = fn746
mo = fn547
lB = fn702
mB = fn770
mk = nil
mf = fn119
mH = fn777
mx = fn78
l5 = fn722
lI = function(by)
    local bz
    bz = {}
    local function bA(bB)
        if not bB then
            return
        end
        for i, child in bB:GetChildren() do
            local oh = child:IsA("Tool") and child:GetAttribute("ItemType") == by
            if oh then
                bz[#bz + 1] = child
            end
        end
    end
    bA(LocalPlayer:FindFirstChild("Backpack"))
    bA(mH())
    return bz
end
lL = function(bK)
    local ot
    ot = nil
    ot = mx()
    if not ot or not bK or not bK.Parent then
        return false
    end
    local ou_1 = mH()
    if bK.Parent == ou_1 then
        return true
    end
    pcall(function()
        ot:EquipTool(bK)
    end)
    return bK.Parent == ou_1
end
l8 = function(bT)
    local RequiresLineOfSight
    local HoldDuration
    local Enabled
    local MaxActivationDistance
    local oA = not bT or not bT:IsA("ProximityPrompt")
    if oA then
        return false
    elseif not fireproximityprompt then
        return false
    else
        HoldDuration = bT.HoldDuration
        MaxActivationDistance = bT.MaxActivationDistance
        RequiresLineOfSight = bT.RequiresLineOfSight
        Enabled = bT.Enabled
        pcall(function()
            bT.HoldDuration = 0
            bT.MaxActivationDistance = math.max(MaxActivationDistance, 100)
            bT.RequiresLineOfSight = false
            bT.Enabled = true
        end)
        local oA_1 = pcall(fireproximityprompt, bT)
        pcall(function()
            bT.HoldDuration = HoldDuration
            bT.MaxActivationDistance = MaxActivationDistance
            bT.RequiresLineOfSight = RequiresLineOfSight
            bT.Enabled = Enabled
        end)
        return oA_1
    end
end
lV = fn172
mF = fn682
l9 = fn396
mp = fn319
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = mu, Copyable = true }, "|", mC },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
mt = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "rocket"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in mt do
    fn318(v)
end
mD, lH, lO, lS, l_, mG, lT, mb, mI, lY, ma, mv = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local function mL_2()
    local pl
    pl = nil
    local pi, pj, pk, Label
    pl = "Unknown"
    pcall(function()
        local o8_1
        local o7_1
        if identifyexecutor then
            o8_1, o7_1 = identifyexecutor()
            local o9 = o8_1 ~= ""
            local pa = type(o8_1) == "string" and o9
            if pa then
                local o9_1 = type(o7_1) == "string" and o7_1 ~= "" and o8_1 .. " " .. o7_1
                pl = o9_1 or o8_1
            end
        end
    end)
    local AccountGroup = mt.Info:AddLeftGroupbox("Account", "circle-user")
    AccountGroup:AddLabel(lN("User", LocalPlayer.Name, mA), true)
    AccountGroup:AddLabel(lN("Status", "Keyless", mA), true)
    AccountGroup:AddLabel(lN("Executor", pl, mA), true)
    local GameInfoGroup = mt.Info:AddLeftGroupbox("Game Info", "gamepad-2")
    GameInfoGroup:AddLabel(l3(mC .. " [" .. tostring(game.PlaceId) .. "]", mr), true)
    GameInfoGroup:AddLabel(lN("Place ID", tostring(game.PlaceId), mr), true)
    Label = GameInfoGroup:AddLabel(lN("Session time", "0s", mi), true)
    pj = tostring(game.JobId)
    local po = #pj > 18 and string.sub(pj, 1, 18) .. "..."
    local po_1 = po or pj
    GameInfoGroup:AddLabel(lN("Server", po_1, md), true)
    GameInfoGroup:AddButton({
        Text = "Copy join script (Job ID)",
        Func = function()
            local c0 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, pj)
            lC(c0, "Copied join script to clipboard")
        end
    })
    pi = os.clock()
    task.spawn(function()
        local pg_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            local pf = math.floor(os.clock() - pi)
            if pf < 60 then
                pg_1 = pf .. "s"
            elseif pf < 3600 then
                pg_1 = string.format("%dm %ds", math.floor((pf) / (60)), pf % 60)
            else
                pg_1 = string.format("%dh %dm", math.floor((pf) / (3600)), math.floor((pf % 3600) / (60)))
            end
            Label:SetText(lN("Session time", pg_1, mi))
        end
    end)
    local ScriptsGroup = mt.Info:AddRightGroupbox("Scripts", "package")
    ScriptsGroup:AddLabel(l3("Included in this hub", md), true)
    ScriptsGroup:AddLabel(l3(mC, mr), true)
    local FeaturesGroup = mt.Info:AddRightGroupbox("Features", "list")
    FeaturesGroup:AddLabel(l3("Automation", mr), true)
    FeaturesGroup:AddLabel(l3("Shop", mi), true)
    FeaturesGroup:AddLabel(l3("Player", md), true)
    local SocialsGroup = mt.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = mn })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            lC(mm, "Copied Rscripts profile to clipboard")
        end
    })
    local TempoHubGroup = mt.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
    TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = mn })
    pk = {
        [1] = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w",
        [2] = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99",
        [3] = "0xaE95A405D007a6F858E5d35714111B075fEFb40a",
        [4] = "0xaE95A405D007a6F858E5d35714111B075fEFb40a",
        [5] = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp",
        [6] = "",
        [7] = ""
    }
    local DonationsGroup = mt.Info:AddRightGroupbox("Donations", "heart")
    DonationsGroup:AddLabel(l3("All donations are optional but appreciated.", mi), true)
    DonationsGroup:AddLabel(l3("If you donate you get a special role, just PING after you donate.", mA), true)
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(l3("LTC / Litecoin", "#345d9d"), true)
    DonationsGroup:AddButton({
        Text = "Copy Litecoin Address",
        Func = function()
            lC(pk[1], "Copied Litecoin address")
        end
    })
    DonationsGroup:AddLabel(l3("BTC / Bitcoin", "#f7931a"), true)
    DonationsGroup:AddButton({
        Text = "Copy Bitcoin Address",
        Func = function()
            lC(pk[2], "Copied Bitcoin address")
        end
    })
    DonationsGroup:AddLabel(l3("ETH / Ethereum", "#627eea"), true)
    DonationsGroup:AddButton({
        Text = "Copy Ethereum Address",
        Func = function()
            lC(pk[3], "Copied Ethereum address")
        end
    })
    DonationsGroup:AddLabel(l3("USDT", "#26a17b"), true)
    DonationsGroup:AddButton({
        Text = "Copy USDT Address",
        Func = function()
            lC(pk[4], "Copied USDT address")
        end
    })
    DonationsGroup:AddLabel(l3("Solana", "#14f195"), true)
    DonationsGroup:AddButton({
        Text = "Copy Solana Address",
        Func = function()
            lC(pk[5], "Copied Solana address")
        end
    })
    DonationsGroup:AddLabel(l3("PayPal", "#0070ba"), true)
    DonationsGroup:AddButton({
        Text = "Copy PayPal Link",
        Func = function()
            lC(pk[6], "Copied PayPal link")
        end
    })
    DonationsGroup:AddLabel(l3("Venmo", "#008cff"), true)
    DonationsGroup:AddButton({
        Text = "Copy Venmo Link",
        Func = function()
            lC(pk[7], "Copied Venmo link")
        end
    })
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(l3("Don't have any of the listed currencies but still wanna donate?", md), true)
    DonationsGroup:AddLabel(l3("DM me and we'll work something out.", mr), true)
    local FaqGroup = mt.Info:AddRightGroupbox("FAQ", "circle-help")
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
mL_2()
local LuckyBlocksGroup = mt.Main:AddLeftGroupbox("Lucky Blocks", "box")
LuckyBlocksGroup:AddToggle("AutoBuyBlocks", { Text = "Auto Buy Lucky Blocks", Default = false })
LuckyBlocksGroup:AddDropdown("BuyBlockTiers", {
    Text = "Blocks To Buy",
    Values = mO,
    Default = { ["Common Lucky Block"] = true },
    Multi = true,
    AllowNull = true,
    Searchable = true
})
LuckyBlocksGroup:AddToggle("AutoPlaceBlocks", { Text = "Auto Place Lucky Blocks", Default = false })
LuckyBlocksGroup:AddDropdown("PlaceBlockTiers", {
    Text = "Blocks To Place",
    Values = mO,
    Default = { ["Common Lucky Block"] = true },
    Multi = true,
    AllowNull = true,
    Searchable = true
})
local LaunchersGroup = mt.Main:AddLeftGroupbox("Launchers", "rocket")
LaunchersGroup:AddToggle("AutoEquipLauncher", { Text = "Auto Equip Launcher", Default = false })
LaunchersGroup:AddToggle("AutoBuyLaunchers", { Text = "Auto Buy Launchers", Default = false })
local MoneyGroup = mt.Main:AddRightGroupbox("Money", "coins")
MoneyGroup:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
MoneyGroup:AddToggle("AutoBuyFloor", { Text = "Auto Buy Floor", Default = false })
MoneyGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
MoneyGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
MoneyGroup:AddDropdown("SellRarities", {
    Text = "Rarities To Sell",
    Values = mJ_3,
    Default = { Common = true, Uncommon = true, Rare = true },
    Multi = true,
    AllowNull = true,
    Searchable = true
})
MoneyGroup:AddButton({ Text = "Remove All Placed Cars", Func = onRemoveAllPlacedCars })
lH = function()
    if not l7("AutoBuyBlocks") then
        return
    end
    local pr = mf()
    if not pr then
        return
    end
    local ps = Options.BuyBlockTiers and Options.BuyBlockTiers.Value
    local pt = lG(ps)
    if not next(pt) then
        return
    end
    local ps_1 = mo()
    for k, v in CollectionService:GetTagged("ConveyorCrate") do
        local pF = v
        local pu = Library.Unloaded or not l7("AutoBuyBlocks")
        if pu then
            return
        end
        local pu_1 = pF.Parent and pF:IsDescendantOf(pr)
        if pu_1 then
            local attr = pF:GetAttribute("Tier")
            local pv = type(attr) == "string" and pt[attr]
            if pv then
                local pv_1 = mF(attr)
                if pv_1 and ps_1 >= pv_1 then
                    pcall(function()
                        lA:FireServer(pF)
                    end)
                    ps_1 -= pv_1
                    task.wait(0.15)
                end
            end
        end
    end
end
lO = fn347
lS = fn267
if ((not mD or false) and (not mD and false) or false and mD and (false or not mD)) and (not mD and not mD and false or (false or (mD or mD))) or not (((not mD or false) and (not mD and false) or false and mD and (false or not mD)) and (not mD and not mD and false or (false or (mD or mD)))) then
    l_ = fn225
    mG = function()
        local qt, qu
        if not l7("AutoPlaceBlocks") then
            return
        end
        qu = mf()
        if not qu then
            return
        end
        qt = lO()
        if #qt == 0 then
            return
        end
        if not lS(qu) then
            return
        end
        lP = true
        pcall(function()
            local qc = qt[1]
            lL(qc)
            task.wait(0.2)
            local Floors = qu:FindFirstChild("Floors")
            if not Floors then
                return
            end
            for i, child in Floors:GetChildren() do
                local qc_6 = Library.Unloaded or not l7("AutoPlaceBlocks")
                if qc_6 then
                    return
                end
                for i, child in child:GetChildren() do
                    if child.Name:find("CarPlot", 1, true) then
                        local qc_7 = child:FindFirstChild("PlacedCar") or child:FindFirstChild("PlacedBlock")
                        if not qc_7 then
                            local CarLocation = child:FindFirstChild("CarLocation")
                            local qd = CarLocation and CarLocation:FindFirstChild("Place")
                            if qd then
                                local qd_2 = l5()
                                local qf = qd_2 and CarLocation:IsA("BasePart")
                                if qf then
                                    qd_2.CFrame = CarLocation.CFrame + Vector3.new(0, 3, 0)
                                    task.wait(0.05)
                                end
                                if l8(qd) then
                                    task.wait(0.35)
                                    qt = lO()
                                    if #qt == 0 then
                                        return
                                    end
                                    lL(qt[1])
                                    task.wait(0.15)
                                end
                            end
                        end
                    end
                end
            end
        end)
        lP = false
    end
else
    mG = fn225
    l_ = function()
        local qt, qu
        if not l7("AutoPlaceBlocks") then
            return
        end
        qu = mf()
        if not qu then
            return
        end
        qt = lO()
        if #qt == 0 then
            return
        end
        if not lS(qu) then
            return
        end
        lP = true
        pcall(function()
            local qc = qt[1]
            lL(qc)
            task.wait(0.2)
            local Floors = qu:FindFirstChild("Floors")
            if not Floors then
                return
            end
            for i, child in Floors:GetChildren() do
                local qc_2 = Library.Unloaded or not l7("AutoPlaceBlocks")
                if qc_2 then
                    return
                end
                for i, child in child:GetChildren() do
                    if child.Name:find("CarPlot", 1, true) then
                        local qc_3 = child:FindFirstChild("PlacedCar") or child:FindFirstChild("PlacedBlock")
                        if not qc_3 then
                            local CarLocation = child:FindFirstChild("CarLocation")
                            local qd = CarLocation and CarLocation:FindFirstChild("Place")
                            if qd then
                                local qd_1 = l5()
                                local qf = qd_1 and CarLocation:IsA("BasePart")
                                if qf then
                                    qd_1.CFrame = CarLocation.CFrame + Vector3.new(0, 3, 0)
                                    task.wait(0.05)
                                end
                                if l8(qd) then
                                    task.wait(0.35)
                                    qt = lO()
                                    if #qt == 0 then
                                        return
                                    end
                                    lL(qt[1])
                                    task.wait(0.15)
                                end
                            end
                        end
                    end
                end
            end
        end)
        lP = false
    end
end
lT = fn147
mb = function()
    local qK, qL
    if not l7("AutoBuyFloor") then
        return
    end
    local qM = mf()
    if not qM then
        return
    end
    qL = mB()
    local qN = tonumber(Progression.MaxFloor) or 5
    if qL >= qN then
        return
    end
    qK = nil
    pcall(function()
        qK = Progression.floorCost(qL)
    end)
    local qN_1 = type(qK) ~= "number" or mo() < qK
    if qN_1 then
        return
    end
    local Floors = qM:FindFirstChild("Floors")
    local qM_1 = Floors and Floors:FindFirstChild("floor" .. tostring(qL))
    local qN_3 = qM_1
    if qM_1 then
        qM_1 = qN_3:FindFirstChild("NextFloor")
    end
    local qN_4 = qM_1
    if qM_1 then
        qM_1 = qN_4:FindFirstChild("BuyNext")
    end
    local qN_5 = qM_1
    if qM_1 then
        qM_1 = qN_5:IsA("BasePart")
    end
    if qM_1 then
        local qM_2 = l5()
        if qM_2 then
            qM_2.CFrame = qN_5.CFrame + Vector3.new(0, 4, 0)
            task.wait(0.05)
        end
        lV(qN_5)
    end
end
lW = function()
    local q2
    q2 = nil
    q2 = mf()
    if not q2 then
        Library:Notify("Plot not found")
        return
    end
    local q3 = mx()
    if q3 then
        pcall(function()
            q3:UnequipTools()
        end)
        task.wait(0.2)
    end
    local function q4()
        local qT = 0
        for i, descendant in q2:GetDescendants() do
            if descendant.Name == "PlacedCar" then
                local Parent = descendant.Parent
                local qV = Parent and Parent.Name:find("CarPlot", 1, true)
                if qV then
                    qT += 1
                end
            end
        end
        return qT
    end
    local q5 = q4()
    local q6 = 0
    local re = 1
    while re <= 8 do
        if Library.Unloaded then
            break
        end
        local q7_1 = {}
        for i, descendant in q2:GetDescendants() do
            if descendant.Name == "PlacedCar" then
                local Parent = descendant.Parent
                local q9 = Parent and Parent.Name:find("CarPlot", 1, true)
                if q9 then
                    local CarLocation = Parent:FindFirstChild("CarLocation")
                    local q8_2 = CarLocation and CarLocation:FindFirstChild("Remove")
                    if CarLocation and q8_2 then
                        q7_1[#q7_1 + 1] = { car = descendant, location = CarLocation, prompt = q8_2 }
                    end
                end
            end
        end
        if #q7_1 == 0 then
            break
        end
        for k, v in q7_1 do
            if Library.Unloaded then
                break
            elseif not not v.car.Parent then
                local q7_2 = l5()
                local q8_4 = q7_2 and v.location:IsA("BasePart")
                if q8_4 then
                    q7_2.CFrame = v.location.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.08)
                end
                l8(v.prompt)
                task.wait(0.35)
                if not v.car.Parent then
                    q6 += 1
                end
            end
        end
        task.wait(0.15)
        if q4() == 0 then
            break
        end
        re += 1
    end
    local q7_3 = q4()
    if q7_3 == 0 then
        q4 = q5 > 0 and "Removed " .. q5 .. " car(s)"
        local q8_5 = q4 or "No placed cars to remove"
        Library:Notify(q8_5)
    else
        Library:Notify(("Removed %d, %d remaining"):format(math.max(q6, q5 - q7_3), q7_3))
    end
end
mI = function()
    if not l7("AutoSell") then
        return
    end
    local rt = Options.SellRarities and Options.SellRarities.Value
    local ru = lG(rt)
    if not next(ru) then
        return
    end
    local rt_1 = {}
    for k in ru do
        local ru_1 = mw[k] or k
        rt_1[ru_1] = true
        rt_1[k] = true
    end
    for k, v in lI("Car") do
        local rG = v
        local ru_2 = Library.Unloaded or not l7("AutoSell")
        if ru_2 then
            return
        end
        local attr = rG:GetAttribute("Rarity")
        local rv_2 = type(attr) == "string" and rt_1[attr]
        if rv_2 then
            pcall(function()
                mj:FireServer(rG)
            end)
            task.wait(0.1)
        end
    end
end
lY = function()
    local rH
    if not l7("AutoRebirth") then
        return
    end
    rH = nil
    pcall(function()
        rH = Rebirth.cost(lB())
    end)
    if type(rH) ~= "number" then
        return
    end
    if mo() >= rH then
        pcall(function()
            me:FireServer()
        end)
    end
end
ma = function()
    local rJ
    if not l7("AutoBuyLaunchers") then
        return
    end
    rJ = mp()
    if not rJ then
        return
    end
    pcall(function()
        mE:FireServer(rJ)
    end)
    pcall(function()
        ms:FireServer()
    end)
end
mv = function()
    if not l7("AutoEquipLauncher") then
        return
    end
    if l_() then
        return
    end
    local rL = l9()
    if not rL then
        return
    end
    if l0 ~= rL then
        pcall(function()
            mz:FireServer(rL)
        end)
        l0 = rL
    end
    local rM = lI("Rocket")
    for k, v in rM do
        local rN = v:GetAttribute("RocketKey") == rL or v.Name:lower():find(rL:lower(), 1, true)
        if rN then
            lL(v)
            return
        end
    end
    if #rM > 0 then
        lL(rM[1])
    end
end
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(worker6)
task.spawn(worker7)
task.spawn(worker8)
task.spawn(worker9)
local function mN_1()
    local connection
    local MovementGroup = mt.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = mt.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    RunService.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = LocalPlayer.Character
            if Character then
                for i, descendant in Character:GetDescendants() do
                    local r8_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if r8_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    UserInputService.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local sj_1 = mx()
            if sj_1 then
                sj_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    local CurrentCamera = workspace.CurrentCamera
    RunService.RenderStepped:Connect(function(hu)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local sl_1 = mx()
            if sl_1 then
                sl_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local sl_3 = l5()
            local sm = mx()
            if sl_3 and sm then
                sm.PlatformStand = true
                local sm_1 = Vector3.zero
                local sr = if UserInputService:IsKeyDown(Enum.KeyCode.W) then 1 else 0
                if sr == 1 then
                    sm_1 += CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    sm_1 -= CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    sm_1 -= CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    sm_1 += CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    sm_1 += Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    sm_1 -= Vector3.new(0, 1, 0)
                end
                sl_3.AssemblyLinearVelocity = Vector3.zero
                if sm_1.Magnitude > 0 then
                    sl_3.CFrame = sl_3.CFrame + sm_1.Unit * Options.FlySpeed.Value * hu
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local ss = mx()
            if ss then
                ss.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local sx = mx()
            if sx then
                sx.WalkSpeed = 16
            end
        end
    end)
    local function hQ(hR)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not hR)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not hR
            end
        end)
        if not hR then
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
    Toggles.AntiGameplayPause:OnChanged(function()
        hQ(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                hQ(true)
            end
        end
    end)
    Library:OnUnload(function()
        hQ(false)
    end)
    local function h8(h9)
        local sN = if not h9:IsA("ProximityPrompt") then 1 else 0
        if sN == 1 then
            return
        end
        h9.HoldDuration = 0
        h9.MaxActivationDistance = 50
        h9.RequiresLineOfSight = false
    end
    connection = nil
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in workspace:GetDescendants() do
                pcall(h8, descendant)
            end
            connection = workspace.DescendantAdded:Connect(function(ih)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(h8, ih)
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    Library:OnUnload(function()
        if connection then
            connection:Disconnect()
        end
    end)
end
mN_1()
local function mK_4()
    local connection
    local MenuGroup = mt.Settings:AddLeftGroupbox("Menu")
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    local ir = 0
    local is = tick()
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = MenuGroup:AddLabel("AFK triggers: 0")
    local function iu()
        if not workspace.CurrentCamera then
            return
        end
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        ir += 1
        is = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. ir)
        end)
    end
    connection = LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(iu)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local s5 = Toggles.AntiAfk.Value and tick() - is >= 60
            if s5 then
                pcall(iu)
            end
        end
    end)
    MenuGroup:AddButton({
        Text = "Unload UI",
        Func = function()
            Library:Unload()
        end
    })
    Library:OnUnload(function()
        if connection then
            connection:Disconnect()
        end
    end)
end
mK_4()
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("MyScriptHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(mt.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/BlowUpLuckyBlocksForCars")
mD = SaveManager:BuildConfigSection(mt.Settings)
SaveManager:LoadAutoloadConfig()
local function mU()
    local function iR(iS, iT)
        local s9_1 = (iS == "Toggle" and Toggles or Options)[iT]
        local s8_2 = type(s9_1) == "table" and s9_1.Type == iS
        return s8_2 and s9_1 or nil
    end
    local function i0(i1, i2)
        local Type = i2.Type
        if Type == "Toggle" then
            return { idx = i1, type = "Toggle", value = i2.Value == true }
        elseif Type == "Slider" then
            return { idx = i1, type = "Slider", value = tostring(i2.Value) }
        elseif Type == "Dropdown" then
            return { idx = i1, type = "Dropdown", multi = i2.Multi == true, value = i2.Value }
        elseif Type == "Input" then
            local td = i2.Value or ""
            return { idx = i1, type = "Input", text = tostring(td) }
        elseif Type == "ColorPicker" then
            return { idx = i1, type = "ColorPicker", value = i2.Value:ToHex(), transparency = i2.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = i1,
                type = "KeyPicker",
                mode = i2.Mode,
                key = i2.Value,
                modifiers = i2.Modifiers,
                toggled = i2.Toggled
            }
        else
            return nil
        end
    end
    local function i4()
        local tj = {}
        for k, v in { Toggles, Options } do
            for k, v in v do
                local tk = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if tk then
                    local tk_1 = i0(k, v)
                    if tk_1 then
                        tj[#tj + 1] = tk_1
                    end
                end
            end
        end
        table.sort(tj, function(je, jf)
            if je.type ~= jf.type then
                return je.type < jf.type
            end
            return je.idx < jf.idx
        end)
        return { objects = tj }
    end
    local function jg(jh)
        local tA
        tA = nil
        local tB = type(jh) ~= "table" or type(jh.idx) ~= "string"
        local tF = if tB then 1 else 0
        local tD = 670 * tF + 3440 * (1 - tF)
        local tE = 2369 * tF + 1115 * (1 - tF)
        if not ((tD * 752 + tE * 3807 + tD * tE) % 16777213 == 11109853) then
            tB = type(jh.type) ~= "string"
        end
        if not tB then
            tB = SaveManager.Ignore[jh.idx]
        end
        if tB then
            return false
        end
        tA = iR(jh.type, jh.idx)
        if not tA then
            return false
        end
        local tB_1 = pcall(function()
            if jh.type == "Input" then
                if type(jh.text) ~= "string" then
                    return
                end
                tA:SetValue(jh.text)
            elseif jh.type == "ColorPicker" then
                tA:SetValueRGB(Color3.fromHex(jh.value), jh.transparency)
            elseif jh.type == "KeyPicker" then
                tA:SetValue({ jh.key, jh.mode, jh.modifiers })
                if jh.mode == "Toggle" and jh.toggled ~= nil then
                    tA.Toggled = jh.toggled
                    tA:Update()
                end
            else
                tA:SetValue(jh.value)
            end
        end)
        return tB_1
    end
    mD:AddDivider()
    mD:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    mD:AddButton("Export Config to Clipboard", function()
        local tH_1
        local tG_1
        tG_1, tH_1 = pcall(HttpService.JSONEncode, HttpService, i4())
        if not tG_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local tG_2 = setclipboard or toclipboard
        local tG_3 = type(tG_2) ~= "function" or not pcall(tG_2, tH_1)
        if tG_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    mD:AddButton("Import Config from Clipboard Text", function()
        local tP_1
        local tN = Options.SaveManager_ImportSource.Value
        local tN_1
        local tT = if tN then 1 else 0
        local tR = 848 * tT + 2937 * (1 - tT)
        local tS = 3338 * tT + 2838 * (1 - tT)
        if not ((tR * 2524 + tS * 1866 + tR * tS) % 16777213 == 11199684) then
            tN = ""
        end
        local tO = tostring(tN):match("^%s*(.-)%s*$")
        if tO == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        tN_1, tP_1 = pcall(HttpService.JSONDecode, HttpService, tO)
        local tO_1 = not tN_1 or type(tP_1) ~= "table" or type(tP_1.objects) ~= "table"
        if tO_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local tN_2 = 0
        for k, v in tP_1.objects do
            if jg(v) then
                tN_2 += 1
            end
        end
        if tN_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local tP_2 = tN_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(tN_2, tP_2), 6)
    end)
end
mU()
end)(...)

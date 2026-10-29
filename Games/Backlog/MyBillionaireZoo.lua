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
getgenv().TempoHoodSubtitle = "MY BILLIONAIRE ZOO"
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
local sW_1, sW_3, GameInfoGroup, sW_14, sW_15, sW_20
local lY
local lF
local lm
local l3
local Data
local PlacePet
local ls
local HttpService
local k9
local lR
local DoRebirth
local UserInputService
local lf
local lX
local lE
local CurrentCamera
local PetConfig
local Options
local lK
local lr
local SaveManager
local k8
local BuyPet
local lx
local me
local PetTiers
local lW
local lD
local mk
local lk
local l1
local lJ
local BuyPerk
local l7
local k7
local lP
local lw
local VirtualUser
local ld
local lV
local CollectPetMoney
local Library
local lj
local l0
local lI
local lp
local l6
local k6
local lO
local lv
local mc
local lc
local lU
local mi
local connection
local l_
local PickupPet
local lo
local l5
local k5
local Label
local lu
local mb
local PetCages
local RollPet
local lA
local mh
local RebirthConfig
local lZ
local lG
local ln
local Toggles
local connection2
local lM
local MaxRebirth
local ma
local la
local lS
local lz
local mg
local lg
function fns.fn21(a1)
    local nV = PetConfig[a1]
    return nV and nV.Rarity or "Common"
end
function fns.fn33(er, es, et)
    return string.format("<b>%s</b> %s %s", er, lo("-", "#5a6070"), lo(es, et))
end
function fns.fn51()
    local op = lw(Options.RebirthUpgrades)
    if not lk(op) then
        return
    end
    local oq = l1("RebirthPoints")
    for k, v in lu do
        if op[v] then
            local ot = ls[v]
            if ot then
                local ou = l1(ot.Id .. "Level")
                local ov = (tonumber(ot.MaxLevel))
                local oG = if ov then 1 else 0
                local oE = 1032 * oG + 3129 * (1 - oG)
                local oF = 1506 * oG + 2840 * (1 - oG)
                if not ((oE * 2200 + oF * 2649 + oE * oF) % 16777213 == 7813986) then
                    ov = 0
                end
                if ou < ov then
                    local ov_1 = RebirthConfig.GetPerkCost(ot, ou)
                    local ou_1 = type(ov_1) == "number" and ov_1 <= oq
                    if ou_1 then
                        if k5(BuyPerk, ot.Id) then
                            oq -= ov_1
                        end
                    end
                end
            end
        end
    end
end
function fns.onExportConfigToClipboard()
    local sA_1
    local sz_1
    sz_1, sA_1 = pcall(HttpService.JSONEncode, HttpService, mk())
    if not sz_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local sz_2 = setclipboard or toclipboard
    local sz_3 = type(sz_2) ~= "function" or not pcall(sz_2, sA_1)
    if sz_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
function fns.fn71(ae, af)
    if setclipboard then
        setclipboard(ae)
    elseif toclipboard then
        toclipboard(ae)
    end
    Library:Notify(af)
end
function fns.fn72()
    if not Toggles.Fly.Value then
        local rx = lO()
        if rx then
            rx.PlatformStand = false
        end
    end
end
function fns.fn79(cC, cD, cE)
    local pa_1
    local o9_1
    for i, child in workspace:GetChildren() do
        local o8 = child:IsA("Model") and string.sub(child.Name, 1, 10) == "PlacedPet_"
        if o8 then
            local Floor = child:FindFirstChild("Floor")
            if Floor then
                o9_1, pa_1 = k7(Floor)
                local pb = math.abs(Floor.Position.X - cC.X) < (cD + o9_1) / 2 - 1 and math.abs(Floor.Position.Z - cC.Z) < (cE + pa_1) / 2 - 1 and math.abs(Floor.Position.Y - cC.Y) < 5
                if pb then
                    return true
                end
            end
        end
    end
    return false
end
function fns.onInputBegan()
    lZ = tick()
end
function fns.fn104()
    if _G.IsButtonRolling then
        return
    end
    local od = k5(RollPet)
    if type(od) ~= "table" then
        return
    end
    _G.LastRollResults = od
    if lj("AutoBuyRoll") then
        me(od)
    end
end
function fns.fn107()
    ld(Toggles.AntiGameplayPause.Value)
end
local function onPickUpAllPlacedPets()
    local qn = tostring(l7.UserId)
    local qo = "PlacedPet_" .. qn .. "_"
    local qn_1 = {}
    for i, child in workspace:GetChildren() do
        local qp = child:IsA("Model") and string.sub(child.Name, 1, #qo) == qo
        if qp then
            local attr = child:GetAttribute("PlacedIndex")
            if attr then
                qn_1[#qn_1 + 1] = attr
            end
        end
    end
    for k, v in qn_1 do
        if Library.Unloaded then
            return
        end
        k5(PickupPet, v)
        task.wait(0.1)
    end
end
local function fn133()
    local attr = l7:GetAttribute("PlotIndex")
    if not attr then
        return {}
    end
    local oP = k6:FindFirstChild("Plot" .. attr)
    if not oP then
        return {}
    end
    local Floors = oP:FindFirstChild("Floors")
    if not Floors then
        return {}
    end
    local oP_1 = lM()
    local oQ = {}
    for i, child in Floors:GetChildren() do
        if child:IsA("Folder") then
            local oO_2 = tonumber(child.Name:match("^Floor(%d+)$"))
            if oO_2 and oP_1[oO_2] then
                local Placement = child:FindFirstChild("Placement")
                local oR_1 = Placement and Placement:IsA("BasePart")
                if oR_1 then
                    oQ[#oQ + 1] = Placement
                end
            end
        end
    end
    return oQ
end
local function fn184(eo, ep)
    return string.format('<font color="%s">%s</font>', ep, eo)
end
local function onImportConfigFromClipboardTex()
    local sF_1
    local sD = Options.SaveManager_ImportSource.Value or ""
    local sD_1
    local sE = tostring(sD):match("^%s*(.-)%s*$")
    if sE == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    sD_1, sF_1 = pcall(HttpService.JSONDecode, HttpService, sE)
    local sE_1 = not sD_1 or type(sF_1) ~= "table" or type(sF_1.objects) ~= "table"
    if sE_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local sD_2 = 0
    for k, v in sF_1.objects do
        if lx(v) then
            sD_2 += 1
        end
    end
    if sD_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local sF_2 = sD_2 == 1 and ""
    local sP = if sF_2 then 1 else 0
    local sN = 3123 * sP + 3161 * (1 - sP)
    local sO = 1808 * sP + 275 * (1 - sP)
    if not ((sN * 127 + sO * 2477 + sN * sO) % 16777213 == 10521421) then
        sF_2 = "s"
    end
    Library:Notify(("Imported %d setting%s"):format(sD_2, sF_2), 6)
end
local function fn213(hg, hh)
    local Type = hh.Type
    if Type == "Toggle" then
        return { idx = hg, type = "Toggle", value = hh.Value == true }
    elseif Type == "Slider" then
        return { idx = hg, type = "Slider", value = tostring(hh.Value) }
    elseif Type == "Dropdown" then
        return { idx = hg, type = "Dropdown", multi = hh.Multi == true, value = hh.Value }
    elseif Type == "Input" then
        local r3 = hh.Value or ""
        return { idx = hg, type = "Input", text = tostring(r3) }
    elseif Type == "ColorPicker" then
        return { idx = hg, type = "ColorPicker", value = hh.Value:ToHex(), transparency = hh.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = hg,
            type = "KeyPicker",
            mode = hh.Mode,
            key = hh.Value,
            modifiers = hh.Modifiers,
            toggled = hh.Toggled
        }
    else
        return nil
    end
end
local function fn224()
    Library.ScreenGui.Parent = l7:WaitForChild("PlayerGui")
end
local function fn232(g8, g9)
    local r__1 = (g8 == "Toggle" and Toggles or Options)[g9]
    local rZ_2 = type(r__1) == "table" and r__1.Type == g8
    return rZ_2 and r__1 or nil
end
local function fn253()
    local qG = tostring(l7.UserId)
    local qH = "PlacedPet_" .. qG .. "_"
    for i, child in workspace:GetChildren() do
        local qG_1 = child:IsA("Model") and string.sub(child.Name, 1, #qH) == qH
        if qG_1 then
            local attr = child:GetAttribute("PlacedIndex")
            local qI = tonumber(child:GetAttribute("AccumulatedMoney")) or 0
            if attr and qI > 0 then
                k5(CollectPetMoney, attr)
            end
        end
    end
end
local function onRscripts()
    k8(lV, "Copied Rscripts profile to clipboard")
end
local function fn265(cP, cQ)
    for k, v in lr() do
        local Size = v.Size
        local CFrame = v.CFrame
        local pl = 5
        local pm = -Size.X / 2 + cP / 2
        local pn = Size.X / 2 - cP / 2
        local po = -Size.Z / 2 + cQ / 2
        local pp = Size.Z / 2 - cQ / 2
        local pz = pm
        local py = 5
        while true and pz <= pn or false and pz >= pn do
            local pA = pz
            local pE = po
            while true and pE <= pp or false and pE >= pp do
                local pF = pE
                local pm_1 = CFrame:PointToWorldSpace(Vector3.new(pA, Size.Y / 2, pF))
                if not mb(pm_1, cP, cQ) then
                    return pm_1
                end
                pE += pl
            end
            pz += py
        end
    end
    return nil
end
local function onCopyJoinScript_JobID()
    local qX = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, lJ)
    if setclipboard then
        setclipboard(qX)
    elseif toclipboard then
        toclipboard(qX)
    end
    Library:Notify("Copied join script to clipboard")
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local q7_1 = lW()
        if q7_1 then
            for i, descendant in q7_1:GetDescendants() do
                local q7_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if q7_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn322()
    k8(l_, "Copied Discord invite to clipboard")
end
local function fn335()
    local nt = lW()
    local nu = nt and nt:FindFirstChild("HumanoidRootPart")
    return nu
end
local function onCopyUSDTAddress()
    k8(lR, "Copied USDT address")
end
local function onInputChanged(gP)
    local UserInputType = gP.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        lZ = tick()
    end
end
local function worker2()
    while not Library.Unloaded do
        task.wait(1)
        if lj("AutoCollectMoney") then
            pcall(mi)
        end
    end
end
local function fn381(az)
    local nw = Toggles[az]
    return nw ~= nil and nw.Value == true
end
local function fn382()
    local r9 = {}
    for k, v in { Toggles, Options } do
        for k, v in v do
            local sa = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if sa then
                local sa_1 = lc(k, v)
                if sa_1 then
                    r9[#r9 + 1] = sa_1
                end
            end
        end
    end
    table.sort(r9, function(ht, hu)
        if ht.type ~= hu.type then
            return ht.type < hu.type
        end
        return ht.idx < hu.idx
    end)
    return { objects = r9 }
end
local function onCopyLitecoinAddress()
    k8(l3, "Copied Litecoin address")
end
local function onCopyEthereumAddress()
    k8(lX, "Copied Ethereum address")
end
local function fn411()
    if not Toggles.WalkSpeedEnabled.Value then
        local rz = lO()
        if rz then
            rz.WalkSpeed = 16
        end
    end
end
local function fn433(al)
    local DiscordGroup = al:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = mh })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = mh })
end
local function onUnload()
    Library:Unload()
end
local function fn450()
    local qT_1
    local qS_1
    if identifyexecutor then
        qT_1, qS_1 = identifyexecutor()
        local qU = qT_1 ~= ""
        local qV = type(qT_1) == "string" and qU
        if qV then
            local qU_1 = type(qS_1) == "string" and qS_1 ~= "" and qT_1 .. " " .. qS_1
            ma = qU_1 or qT_1
        end
    end
end
local function fn502()
    local qb_1
    local qg = if not l6() then 1 else 0
    if qg == 1 then
        return
    end
    local p8_1 = (Options.PlaceMode and Options.PlaceMode.Value or lI) == lD
    local p7_2 = lw(Options.PlaceRarities)
    local p9 = p8_1 and not lk(p7_2)
    if p9 then
        return
    end
    local p9_1 = l5()
    for k, v in lY() do
        if not l6() then
            return
        end
        local qa = not p8_1 or p7_2[k9(v.Name)]
        local qa_1
        if qa then
            qb_1, qa_1 = lE(v.Name)
            local qc = lp(qb_1, qa_1)
            if not qc then
                return
            end
            local qa_2 = PetTiers.Normalize(v:GetAttribute("Tier")) or "Normal"
            k5(PlacePet, v.Name, qc.X, qc.Y, qc.Z, p9_1, qa_2)
            task.wait(0.25)
        end
    end
end
local function fn511(aU)
    local nL = aU and aU.Value
    if typeof(nL) ~= "table" then
        return {}
    end
    return nL
end
local function fn516(cm)
    local o4 = PetConfig[cm]
    local o5_1 = o4 and o4.CageSize or "Large"
    local o4_2 = PetCages:FindFirstChild(o5_1)
    local o5_2 = o4_2 and o4_2:FindFirstChild("Floor")
    if o5_2 then
        return o5_2.Size.X, o5_2.Size.Z
    end
    return 10, 10
end
local function worker()
    local q__1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local qZ = math.floor(os.clock() - lm)
        if qZ < 60 then
            q__1 = qZ .. "s"
        elseif qZ < 3600 then
            q__1 = string.format("%dm %ds", math.floor((qZ) / (60)), qZ % 60)
        else
            q__1 = string.format("%dh %dm", math.floor((qZ) / (3600)), math.floor((qZ % 3600) / (60)))
        end
        Label:SetText(lf("Session time", q__1, mg))
    end
end
local function fn545(a6)
    if type(a6) ~= "table" then
        return
    end
    local nY = lw(Options.BuyRarities)
    if not lk(nY) then
        return
    end
    local nZ = lG()
    local n_ = lj("AutoSkipRoll")
    for k, v in a6 do
        if Library.Unloaded then
            return
        end
        if type(v) == "string" then
            local n0 = PetConfig[v]
            local n1 = n0
            if n1 then
                n1 = nY[n0.Rarity or "Common"]
            end
            if n1 then
                local n1_1 = tonumber(n0.Price) or 0
                local n0_1 = n_
                if n0_1 then
                    n0_1 = n1_1 > nZ
                end
                if not n0_1 then
                    if k5(BuyPet, k) then
                        nZ -= n1_1
                    end
                    task.wait(0.2)
                end
            end
        end
    end
end
local function onCopyPayPalLink()
    k8(lK, "Copied PayPal link")
end
local function fn556(aN)
    local nF = Data:FindFirstChild(aN)
    local nG = nF and tonumber(nF.Value)
    local nF_1 = nG
    local nK = if nF_1 then 1 else 0
    local nI = 3294 * nK + 2262 * (1 - nK)
    local nJ = 2588 * nK + 3675 * (1 - nK)
    if not ((nI * 1529 + nJ * 1243 + nI * nJ) % 16777213 == 1069) then
        nF_1 = 0
    end
    return nF_1
end
local function fn577(aY)
    for k, v in aY do
        if v then
            return true
        end
    end
    return false
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local ri_1 = lO()
        if ri_1 then
            ri_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn617()
    local nn = lW()
    local no = nn and nn:FindFirstChildOfClass("Humanoid")
    return no
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local rV = tick() - lZ
            local rW = tick() - lU
            if rV >= 300 and rW >= 60 then
                pcall(lz)
            else
                if rV < 300 and rW >= 300 then
                    pcall(lz)
                end
            end
        end
    end
end
local function fn713(cw)
    local RightVector = cw.CFrame.RightVector
    local cy = -cw.CFrame.LookVector
    local cz = math.abs(cw.Size.X * RightVector.X) + math.abs(cw.Size.Z * cy.X)
    local cA = math.abs(cw.Size.X * RightVector.Z) + math.abs(cw.Size.Z * cy.Z)
    return math.max(5, math.round(cz / 5) * 5), math.max(5, math.round(cA / 5) * 5)
end
local function worker4()
    while not Library.Unloaded do
        task.wait(1)
        if lj("AutoRebirth") then
            pcall(mc)
        end
        if lj("AutoBuyRebirthUpgrades") then
            pcall(ln)
        end
    end
end
local function fn753()
    return l1("Cash")
end
local function onCopySolanaAddress()
    k8(lP, "Copied Solana address")
end
local function worker3()
    while not Library.Unloaded do
        task.wait(1.5)
        if lj("AutoPlacePets") then
            pcall(lS)
        end
    end
end
local function fn796()
    local attr = l7:GetAttribute("PlotIndex")
    local o_ = attr and k6:FindFirstChild("Plot" .. attr)
    local oZ_1 = o_
    if o_ then
        o_ = oZ_1:GetAttribute("Rotated")
    end
    if o_ then
        return 90
    end
    return -90
end
local function onRenderStepped(f6)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local rn_1 = lO()
        if rn_1 then
            rn_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local rn_3 = lv()
        local ro = lO()
        if rn_3 and ro then
            ro.PlatformStand = true
            local ro_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                ro_1 = ro_1 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                ro_1 = ro_1 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                ro_1 = ro_1 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                ro_1 = ro_1 + CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                ro_1 = ro_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                ro_1 = ro_1 - Vector3.new(0, 1, 0)
            end
            rn_3.Velocity = Vector3.zero
            if ro_1.Magnitude > 0 then
                rn_3.CFrame = rn_3.CFrame + ro_1.Unit * Options.FlySpeed.Value * f6
            end
        end
    end
end
local function fn830()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    lU = tick()
end
local function rollDelayLoop()
    while not Library.Unloaded do
        local q1_1 = Options.RollDelay and Options.RollDelay.Value or 0.5
        if lj("AutoRoll") then
            pcall(la)
        elseif lj("AutoBuyRoll") then
            pcall(me, _G.LastRollResults)
        end
        task.wait(q1_1)
    end
end
local function fn834()
    connection:Disconnect()
    connection2:Disconnect()
    ld(false)
    select("#", "Unloaded!")
end
local function fn835()
    local of = Options.RebirthAmount and Options.RebirthAmount.Value
    if of == lA then
        k5(MaxRebirth)
        return
    end
    local of_1 = lg[of]
    if not of_1 then
        return
    end
    local og_1 = RebirthConfig.REBIRTH_OPTIONS[of_1]
    if not og_1 then
        return
    end
    local oh = l1("RebirthButtonsLevel")
    if oh < (og_1.UnlockLevel or 0) then
        return
    end
    k5(DoRebirth, of_1)
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            ld(true)
        end
    end
end
local function onCopyVenmoLink()
    k8(lF, "Copied Venmo link")
end
local function fn899()
    local attr = l7:GetAttribute("FloorsOwned")
    if not attr then
        return { [1] = true }
    end
    local oI = {}
    for k in tostring(attr):gmatch("%d+") do
        oI[tonumber(k)] = true
    end
    return oI
end
local function fn928()
    local p5 = lj("AutoPlacePets") and not Library.Unloaded
    return p5
end
local function onCopyBitcoinAddress()
    k8(l0, "Copied Bitcoin address")
end
local function fn979()
    return l7.Character
end
Data = nil
connection2 = nil
k5 = nil
k6 = nil
k7 = nil
k8 = nil
k9 = nil
la = nil
PetCages = nil
lc = nil
ld = nil
PetTiers = nil
lf = nil
lg = nil
RebirthConfig = nil
connection = nil
lj = nil
lk = nil
PetConfig = nil
lm = nil
ln = nil
lo = nil
lp = nil
BuyPerk = nil
lr = nil
ls = nil
MaxRebirth = nil
lu = nil
lv = nil
lw = nil
lx = nil
DoRebirth = nil
lz = nil
lA = nil
CollectPetMoney = nil
lD = nil
lE = nil
lF = nil
lG = nil
PickupPet = nil
lI = nil
lJ = nil
lK = nil
PlacePet = nil
lM = nil
Label = nil
lO = nil
lP = nil
BuyPet = nil
local lB
lR = nil
lS = nil
RollPet = nil
lU = nil
lV = nil
lW = nil
lX = nil
lY = nil
lZ = nil
l_ = nil
l0 = nil
l1 = nil
Options = nil
l3 = nil
Toggles = nil
l5 = nil
l6 = nil
l7 = nil
SaveManager = nil
HttpService = nil
ma = nil
mb = nil
mc = nil
VirtualUser = nil
me = nil
UserInputService = nil
mg = nil
mh = nil
mi = nil
Library = nil
mk = nil
CurrentCamera = nil
local mD
local mE, mG, mN, BuyingGroup, RollingGroup, FlyGroup
sW_3, UserInputService, VirtualUser, HttpService, l7 = nil, nil, nil, nil, nil
if ((VirtualUser or not VirtualUser) and (not UserInputService or VirtualUser) or (UserInputService and UserInputService or (not l7 or VirtualUser)) or (not HttpService and VirtualUser or (not l7 or l7)) and (not UserInputService or not HttpService or HttpService and not UserInputService)) and ((not HttpService and sW_3 or UserInputService and sW_3) and (sW_3 or not UserInputService or (sW_3 or UserInputService)) or (UserInputService and UserInputService or (UserInputService or not l7)) and (not sW_3 or sW_3 or not VirtualUser and not UserInputService)) or not (((VirtualUser or not VirtualUser) and (not UserInputService or VirtualUser) or (UserInputService and UserInputService or (not l7 or VirtualUser)) or (not HttpService and VirtualUser or (not l7 or l7)) and (not UserInputService or not HttpService or HttpService and not UserInputService)) and ((not HttpService and sW_3 or UserInputService and sW_3) and (sW_3 or not UserInputService or (sW_3 or UserInputService)) or (UserInputService and UserInputService or (UserInputService or not l7)) and (not sW_3 or sW_3 or not VirtualUser and not UserInputService))) then
    sW_3 = game:GetService("Players")
else
    game:GetService("Players")
end
local sW_19 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
l7 = sW_3.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return l7:WaitForChild("PlayerGui")
    end
end
if setthreadidentity then
    setthreadidentity(8)
end
RollPet, BuyPet, PlacePet, PickupPet, CollectPetMoney, DoRebirth, MaxRebirth, BuyPerk, sW_14, PetConfig, RebirthConfig, PetTiers, PetCages, k6, Data, Library, SaveManager, Toggles, Options, l_, lV, sW_1, lI, lD, lA, lu, ls = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local sW_10 = "My Billionaire Zoo"
local sW_21 = sW_19:WaitForChild("Remotes")
RollPet = sW_21:WaitForChild("RollPet")
BuyPet = sW_21:WaitForChild("BuyPet")
PlacePet = sW_21:WaitForChild("PlacePet")
PickupPet = sW_21:WaitForChild("PickupPet")
CollectPetMoney = sW_21:WaitForChild("CollectPetMoney")
DoRebirth = sW_21:WaitForChild("DoRebirth")
MaxRebirth = sW_21:WaitForChild("MaxRebirth")
if ((not BuyPerk and not Data or PickupPet and not sW_1) and ((not Data or 67) and 67) or not BuyPerk and BuyPerk and (sW_1 or PetCages) and false) and (PickupPet or not BuyPerk or (PetCages or PetCages) or (not Data and not PetCages or 67) or (PetCages or not BuyPerk or 67 or (PetCages and 67 or 67))) and not (((not BuyPerk and not Data or PickupPet and not sW_1) and ((not Data or 67) and 67) or not BuyPerk and BuyPerk and (sW_1 or PetCages) and false) and (PickupPet or not BuyPerk or (PetCages or PetCages) or (not Data and not PetCages or 67) or (PetCages or not BuyPerk or 67 or (PetCages and 67 or 67)))) then
    BuyPerk:WaitForChild("BuyPerk")
else
    BuyPerk = sW_21:WaitForChild("BuyPerk")
end
if false or not BuyPerk and not sW_1 or (BuyPerk or not sW_1) and "My Billionaire Zoo" or not (false or not BuyPerk and not sW_1 or (BuyPerk or not sW_1) and "My Billionaire Zoo") then
    sW_14 = sW_19:WaitForChild("Configs")
else
    sW_19 = sW_14:WaitForChild("Configs")
end
PetConfig = require(sW_14:WaitForChild("PetConfig"))
RebirthConfig = require(sW_14:WaitForChild("RebirthConfig"))
PetTiers = require(sW_14:WaitForChild("PetTiers"))
sW_3 = sW_19:WaitForChild("Assets")
PetCages = sW_3:WaitForChild("PetCages")
if 28 and (not BuyPet and false) and (BuyPet and false or 28) and (false or (false or BuyPet) or (not BuyPet and false or (BuyPet or not sW_14))) or (not sW_14 and 28 and false or false) and (not sW_14 and not sW_14 and (not sW_14 or BuyPet) and (not sW_14 or false)) or not (28 and (not BuyPet and false) and (BuyPet and false or 28) and (false or (false or BuyPet) or (not BuyPet and false or (BuyPet or not sW_14))) or (not sW_14 and 28 and false or false) and (not sW_14 and not sW_14 and (not sW_14 or BuyPet) and (not sW_14 or false))) then
    k6 = workspace:WaitForChild("Map"):WaitForChild("Plots")
    Data = l7:WaitForChild("Data")
else
    l7 = workspace:WaitForChild("Map"):WaitForChild("Plots")
    k6 = Data:WaitForChild("Data")
end
Library = getgenv().Library
pcall(fn224)
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
l_ = "https://discord.gg/K7Qxnxkk46"
lV = "https://discord.gg/K7Qxnxkk46"
sW_1 = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Divine", "Secret", "Exclusive" }
local sW_16 = { "Legendary", "Mythical", "Divine", "Secret", "Exclusive" }
lI = "Best"
lD = "Selected Rarities"
lA = "Max"
lu = {}
ls = {}
for k, v in RebirthConfig.PERKS do
    lu[#lu + 1] = v.Name
    ls[v.Name] = v
end
lg = nil
local sW_11 = { lA }
lg = {}
for k, v in RebirthConfig.REBIRTH_OPTIONS do
    sW_11[#sW_11 + 1] = v.Label
    lg[v.Label] = k
end
k8, mh, lW, lO, lv, lj, k5, l1, lG, lw, lk, k9, me, la, mc, ln, lM, lr, l5, lE, k7, mb, lp, lY, l6, lS, mi = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
k8 = fns.fn71
mh = fn322
sW_14 = fn433
lW = fn979
lO = fn617
lv = fn335
lj = fn381
k5 = function(aE, ...)
    local nz
    nz = nil
    local nD_1
    local nC_1
    local nB_1
    local nA_1
    nz = { ... }
    nA_1, nB_1, nC_1, nD_1 = pcall(function()
        return aE:InvokeServer(table.unpack(nz))
    end)
    if not nA_1 then
        return nil
    end
    return nB_1, nC_1, nD_1
end
l1 = fn556
lG = fn753
lw = fn511
lk = fn577
k9 = fns.fn21
me = fn545
la = fns.fn104
mc = fn835
ln = fns.fn51
lM = fn899
lr = fn133
l5 = fn796
lE = fn516
k7 = fn713
mb = fns.fn79
lp = fn265
lY = function()
    local pQ
    pQ = {}
    local function pR(c7)
        local pH = c7:IsA("Tool") and PetConfig[c7.Name]
        if pH then
            pQ[#pQ + 1] = c7
        end
    end
    for i, child in l7.Backpack:GetChildren() do
        pR(child)
    end
    local pS = lW()
    if pS then
        for i, child in pS:GetChildren() do
            pR(child)
        end
    end
    table.sort(pQ, function(dj, dk)
        local pJ = PetConfig[dj.Name]
        local pK = PetConfig[dk.Name]
        return (pJ and pJ.MoneyPerSecond or 0) > (pK and pK.MoneyPerSecond or 0)
    end)
    return pQ
end
l6 = fn928
lS = fn502
if (not k8 or lY) and (lE and false) or not k8 and k8 and (k8 or lO) or not ((not k8 or lY) and (lE and false) or not k8 and k8 and (k8 or lO)) then
    mi = fn253
else
    lO = fn253
end
sW_19 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = l_, Copyable = true }, "|", sW_10 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
sW_21 = {
    Info = sW_19:AddTab("Info", "info"),
    Main = sW_19:AddTab("Main", "paw-print"),
    Player = sW_19:AddTab("Player", "person-standing"),
    Settings = sW_19:AddTab("Settings", "settings")
}
sW_21.Roll = sW_21.Main:AddSubTab("Roll", "dices")
sW_21.Zoo = sW_21.Main:AddSubTab("Zoo", "paw-print")
sW_21.Rebirth = sW_21.Main:AddSubTab("Rebirth", "rotate-cw")
for k, v in { sW_21.Roll, sW_21.Zoo, sW_21.Rebirth, sW_21.Player, sW_21.Settings } do
    sW_14(v)
end
sW_15, mg, sW_20, ma, GameInfoGroup, Label, lJ, lo, lf = nil, nil, nil, nil, nil, nil, nil, nil, nil
lo = fn184
if (not sW_15 or sW_15) and (lf or lJ) and (not lJ and not lJ or (not sW_15 or lf)) or (sW_15 or sW_15 or (not sW_15 or lJ)) and (lJ and not lf or sW_15 and not lf) or not ((not sW_15 or sW_15) and (lf or lJ) and (not lJ and not lJ or (not sW_15 or lf)) or (sW_15 or sW_15 or (not sW_15 or lJ)) and (lJ and not lf or sW_15 and not lf)) then
    lf = fns.fn33
else
    lo = fns.fn33
end
sW_15 = "#7fd47f"
local sW_7 = "#6ec1ff"
if (lJ and false and (lo and lo) or (not lo and false or (lo or lJ))) and ((not lJ or lJ) and (lJ and lo) and (false or not lo or false and lo)) and (((lo or lJ) and (lo and sW_7) or (lJ or not lo or not lo and not lo)) and (sW_7 or lJ or "#6ec1ff" or (lJ or false or (not lJ or lJ)))) or not ((lJ and false and (lo and lo) or (not lo and false or (lo or lJ))) and ((not lJ or lJ) and (lJ and lo) and (false or not lo or false and lo)) and (((lo or lJ) and (lo and sW_7) or (lJ or not lo or not lo and not lo)) and (sW_7 or lJ or "#6ec1ff" or (lJ or false or (not lJ or lJ))))) then
    mg = "#e8a34d"
else
    sW_20 = "#e8a34d"
end
if ((lJ or false) and (lJ and not ma) or (not ma or not lJ or (lJ or not lJ)) and 29 or ((not lJ or not ma) and (not lJ or lJ) or (lJ and not ma or false)) and ((ma or lJ) and (not ma or ma))) and not ((lJ or false) and (lJ and not ma) or (not ma or not lJ or (lJ or not lJ)) and 29 or ((not lJ or not ma) and (not lJ or lJ) or (lJ and not ma or false)) and ((ma or lJ) and (not ma or ma))) then
    sW_15 = "#8b93a3"
    lo = "Unknown"
    pcall(fn450)
    sW_10 = ma.Info:AddLeftGroupbox("Account", "circle-user")
    sW_10:AddLabel(sW_21("User", sW_20.Name, l7), true)
    sW_10:AddLabel(sW_21("Status", "Keyless", l7), true)
    sW_10:AddLabel(sW_21("Executor", lo, l7), true)
    sW_7 = ma.Info:AddLeftGroupbox("Game Info", "gamepad-2")
    sW_7:AddLabel(GameInfoGroup(mg .. " [" .. tostring(game.PlaceId) .. "]", lf), true)
    sW_7:AddLabel(sW_21("Place ID", tostring(game.PlaceId), lf), true)
    sW_7:AddLabel(sW_21("Session time", "0s", Label), true)
else
    sW_20 = "#8b93a3"
    ma = "Unknown"
    pcall(fn450)
    sW_3 = sW_21.Info:AddLeftGroupbox("Account", "circle-user")
    sW_3:AddLabel(lf("User", l7.Name, sW_15), true)
    sW_3:AddLabel(lf("Status", "Keyless", sW_15), true)
    sW_3:AddLabel(lf("Executor", ma, sW_15), true)
    GameInfoGroup = sW_21.Info:AddLeftGroupbox("Game Info", "gamepad-2")
    GameInfoGroup:AddLabel(lo(sW_10 .. " [" .. tostring(game.PlaceId) .. "]", sW_7), true)
    GameInfoGroup:AddLabel(lf("Place ID", tostring(game.PlaceId), sW_7), true)
    Label = GameInfoGroup:AddLabel(lf("Session time", "0s", mg), true)
end
lJ = tostring(game.JobId)
local sW_4 = #lJ > 18
if sW_4 then
    sW_3 = 2
    repeat
        if (sW_3 * 2 + 7) * 4 % 3 == ((sW_3 * 2 + 7) * 4 + 3) % 3 then
            sW_4 = string.sub(lJ, 1, 18) .. "..."
        else
            lJ = string.sub(sW_4, 1, 18) .. "..."
        end
        sW_3 = (sW_3 + 6) % 8
    until (sW_3 * 1 + 2) % 8 == 2
end
sW_3 = sW_4 or lJ
lm, l3, l0, lX, lR, lP, lK, lF, mG, mE, mD, RollingGroup, BuyingGroup, CurrentCamera, lZ, lU, connection, connection2, mN, ld, lz, lB, lc, mk, lx = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local mK = sW_3
GameInfoGroup:AddLabel(lf("Server", mK, sW_20), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
lm = os.clock()
task.spawn(worker)
local ScriptsGroup = sW_21.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(lo("Included in this hub", sW_20), true)
ScriptsGroup:AddLabel(lo(sW_10, sW_7), true)
local FeaturesGroup = sW_21.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(lo("Auto Roll", sW_7), true)
FeaturesGroup:AddLabel(lo("Auto Rebirth", mg), true)
FeaturesGroup:AddLabel(lo("Auto Place", sW_15), true)
FeaturesGroup:AddLabel(lo("Auto Collect", sW_20), true)
local SocialsGroup = sW_21.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = mh })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = sW_21.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = mh })
l3 = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
l0 = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
lX = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
lR = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
if ((not RollingGroup or false) and (false or CurrentCamera) and false and (RollingGroup or not BuyingGroup or (BuyingGroup or not CurrentCamera) or (false or not CurrentCamera and false)) or ((not BuyingGroup or not CurrentCamera) and (mD and not CurrentCamera) and (CurrentCamera and false or (not CurrentCamera or RollingGroup)) or (RollingGroup or false) and (RollingGroup or false) and ((not RollingGroup or RollingGroup) and (mD or not CurrentCamera)))) and not ((not RollingGroup or false) and (false or CurrentCamera) and false and (RollingGroup or not BuyingGroup or (BuyingGroup or not CurrentCamera) or (false or not CurrentCamera and false)) or ((not BuyingGroup or not CurrentCamera) and (mD and not CurrentCamera) and (CurrentCamera and false or (not CurrentCamera or RollingGroup)) or (RollingGroup or false) and (RollingGroup or false) and ((not RollingGroup or RollingGroup) and (mD or not CurrentCamera)))) then
    lF = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
    lP = ""
    lK = ""
else
    lP = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
    lK = ""
    lF = ""
end
local mL = "#345d9d"
local mI = "#f7931a"
if not TempoHubGroup and not lc and (l3 or not TempoHubGroup) and ((TempoHubGroup or l3) and (not TempoHubGroup or RollingGroup)) or (l3 or not lP) and (lc and not lP) and (not lc or lP or false and TempoHubGroup) or (not RollingGroup and mE and "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w" or (lP and false or (not TempoHubGroup or RollingGroup)) or ((lc or not lc) and (RollingGroup or l3) or (not TempoHubGroup or RollingGroup) and (not TempoHubGroup or false))) or not (not TempoHubGroup and not lc and (l3 or not TempoHubGroup) and ((TempoHubGroup or l3) and (not TempoHubGroup or RollingGroup)) or (l3 or not lP) and (lc and not lP) and (not lc or lP or false and TempoHubGroup) or (not RollingGroup and mE and "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w" or (lP and false or (not TempoHubGroup or RollingGroup)) or ((lc or not lc) and (RollingGroup or l3) or (not TempoHubGroup or RollingGroup) and (not TempoHubGroup or false)))) then
    mG = "#627eea"
else
    lF = "#627eea"
end
mE = "#26a17b"
mD = "#14f195"
local sW_22 = "#0070ba"
sW_14 = "#008cff"
sW_19 = sW_21.Info:AddRightGroupbox("Donations", "heart")
sW_19:AddLabel(lo("All donations are optional but appreciated.", mg), true)
sW_19:AddLabel(lo("If you donate you get a special role, just PING after you donate.", sW_15), true)
sW_19:AddDivider()
sW_19:AddLabel(lo("LTC / Litecoin", mL), true)
sW_19:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
sW_19:AddLabel(lo("BTC / Bitcoin", mI), true)
sW_19:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
sW_19:AddLabel(lo("ETH / Ethereum", mG), true)
sW_19:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
sW_19:AddLabel(lo("USDT", mE), true)
sW_19:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
sW_19:AddLabel(lo("Solana", mD), true)
sW_19:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
sW_19:AddLabel(lo("PayPal", sW_22), true)
sW_19:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
sW_19:AddLabel(lo("Venmo", sW_14), true)
sW_19:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
sW_19:AddDivider()
sW_19:AddLabel(lo("Don't have any of the listed currencies but still wanna donate?", sW_20), true)
sW_19:AddLabel(lo("DM me and we'll work something out.", sW_7), true)
local FaqGroup = sW_21.Info:AddRightGroupbox("FAQ", "circle-help")
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
RollingGroup = sW_21.Roll:AddLeftGroupbox("Rolling", "dices")
RollingGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
RollingGroup:AddSlider("RollDelay", { Text = "Roll Delay", Default = 0.5, Min = 0.2, Max = 5, Rounding = 1 })
BuyingGroup = sW_21.Roll:AddRightGroupbox("Buying", "shopping-cart")
BuyingGroup:AddToggle("AutoBuyRoll", { Text = "Auto Buy Roll", Default = false })
BuyingGroup:AddDropdown("BuyRarities", {
    Text = "Rarities",
    Values = sW_1,
    Default = sW_16,
    Multi = true,
    SelectAllButtons = true,
    Expandable = true
})
BuyingGroup:AddToggle("AutoSkipRoll", { Text = "Auto Skip if Can't Afford", Default = true })
local ZooGroup = sW_21.Zoo:AddLeftGroupbox("Zoo", "paw-print")
ZooGroup:AddToggle("AutoPlacePets", { Text = "Auto Place Pets", Default = false })
ZooGroup:AddDropdown("PlaceMode", { Text = "Place Mode", Values = { lI, lD }, Default = lI })
ZooGroup:AddDropdown("PlaceRarities", {
    Text = "Rarities",
    Values = sW_1,
    Default = sW_1,
    Multi = true,
    SelectAllButtons = true,
    Expandable = true
})
ZooGroup:AddButton({ Text = "Pick Up All Placed Pets", Func = onPickUpAllPlacedPets })
local CollectingGroup = sW_21.Zoo:AddRightGroupbox("Collecting", "coins")
do
    CollectingGroup:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
    local RebirthGroup = sW_21.Rebirth:AddLeftGroupbox("Rebirth", "rotate-cw")
    RebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
    RebirthGroup:AddDropdown("RebirthAmount", { Text = "Rebirth Amount", Values = sW_11, Default = "+1 Rebirths" })
    local UpgradesGroup = sW_21.Rebirth:AddRightGroupbox("Upgrades", "sparkles")
    UpgradesGroup:AddToggle("AutoBuyRebirthUpgrades", { Text = "Auto Buy Rebirth Upgrades", Default = false })
    UpgradesGroup:AddDropdown("RebirthUpgrades", { Text = "Upgrades", Values = lu, Default = lu, Multi = true, SelectAllButtons = true })
    task.spawn(rollDelayLoop)
    task.spawn(worker4)
    task.spawn(worker3)
    task.spawn(worker2)
    local MovementGroup = sW_21.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    FlyGroup = sW_21.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    RunService.Stepped:Connect(onStepped)
    UserInputService.JumpRequest:Connect(onJumpRequest)
    CurrentCamera = workspace.CurrentCamera
end
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fns.fn72)
Toggles.WalkSpeedEnabled:OnChanged(fn411)
ld = function(gr)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not gr)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not gr
        end
    end)
    if not gr then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(l7, "GameplayPaused", false)
        else
            l7.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fns.fn107)
task.spawn(antiGameplayPauseLoop)
local mT = sW_21.Settings:AddLeftGroupbox("Menu", "menu")
if (false and FlyGroup or mN and not mN or (mN or lm) and (not lm and not FlyGroup)) and (ScriptsGroup or lR or (FlyGroup or not mN) or (ScriptsGroup or false or not FlyGroup and not lm)) or not ((false and FlyGroup or mN and not mN or (mN or lm) and (not lm and not FlyGroup)) and (ScriptsGroup or lR or (FlyGroup or not mN) or (ScriptsGroup or false or not FlyGroup and not lm))) then
    mT:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    lZ = tick()
    lU = tick()
    pcall(function()
        for k, v in getconnections(l7.Idled) do
            local rM = v
            pcall(function()
                rM:Disable()
            end)
        end
    end)
    lz = fn830
else
    lZ:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { NoUI = true, Text = "Menu keybind", Default = "RightShift" })
    Options.ToggleKeybind = Library.MenuKeybind
    lU = tick()
    lz = tick()
    pcall(function()
        for k, v in getconnections(l7.Idled) do
            local rM = v
            pcall(function()
                rM:Disable()
            end)
        end
    end)
    mT = fn830
end
connection = UserInputService.InputBegan:Connect(fns.onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
mT:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
mT:AddButton("Unload", onUnload)
task.spawn(antiAfkLoop)
Library:OnUnload(fn834)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Linoria")
ThemeManager:ApplyToTab(sW_21.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/MyBillionaireZoo")
mN = SaveManager:BuildConfigSection(sW_21.Settings)
lB = fn232
lc = fn213
mk = fn382
lx = function(hw)
    local st
    st = nil
    local su = type(hw) ~= "table" or type(hw.idx) ~= "string" or type(hw.type) ~= "string"
    local sy = if su then 1 else 0
    local sw = 370 * sy + 2057 * (1 - sy)
    local sx = 3010 * sy + 214 * (1 - sy)
    if not ((sw * 350 + sx * 1711 + sw * sx) % 16777213 == 6393310) then
        su = SaveManager.Ignore[hw.idx]
    end
    if su then
        return false
    end
    st = lB(hw.type, hw.idx)
    if not st then
        return false
    end
    local su_1 = pcall(function()
        if hw.type == "Input" then
            if type(hw.text) ~= "string" then
                return
            end
            st:SetValue(hw.text)
        elseif hw.type == "ColorPicker" then
            st:SetValueRGB(Color3.fromHex(hw.value), hw.transparency)
        elseif hw.type == "KeyPicker" then
            st:SetValue({ hw.key, hw.mode, hw.modifiers })
            if hw.mode == "Toggle" and hw.toggled ~= nil then
                st.Toggled = hw.toggled
                st:Update()
            end
        else
            st:SetValue(hw.value)
        end
    end)
    return su_1
end
mN:AddDivider()
mN:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
mN:AddButton("Export Config to Clipboard", fns.onExportConfigToClipboard)
mN:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
end)(...)

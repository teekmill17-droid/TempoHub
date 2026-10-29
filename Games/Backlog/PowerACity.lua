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
getgenv().TempoHoodSubtitle = "POWER A CITY"
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
local wA_6, wA_9, wA_22
local mL
local BuildCity
local Config
local GetUnlockedCityZones
local BuyItem
local ny
local nf
local nX
local mX
local PickupBuilding
local m2
local HttpService
local GetShopState
local Workspace
local n8
local m8
local VirtualUser
local mQ
local connection2
local ne
local Library
local mW
local nD
local nk
local GetMyPlotFolder
local m1
local nJ
local mJ
local PlaceBuilding
local BuyExpansion
local m7
local nP
local mP
local nw
local nd
local nV
local mV
local nC
local n0
local m0
local CurrentCamera2
local mI
local np
local n6
local m6
local nO
local GetGenerators
local nv
local nc
local GetUnlockedZones
local mU
local Options
local BaseShopEvent
local n_
local m_
local nH
local mH
local LocalPlayer
local BuildingData
local SaveManager
local mN
local nu
local nb
local UserInputService
local mT
local UpgradeCity
local nh
local connection
local mZ
local Toggles
local PurchaseUpgrade
local nn
local n4
local m4
local nM
local mM
local nt
local na
local nS
local mS
local ng
local nY
local mY
local UnlockCityZone
local nm
local n3
local m3
local UnlockZone
function fns.fn2()
    n6(Toggles.AntiGameplayPause.Value)
end
function fns.fn8(aq, ar)
    if setclipboard then
        setclipboard(aq)
    elseif toclipboard then
        toclipboard(aq)
    end
    Library:Notify(ar)
end
function fns.fn12()
    local pX_1
    local pW_1
    pW_1, pX_1 = pcall(function()
        return GetUnlockedZones:InvokeServer()
    end)
    local pY = pW_1
    local pW_2 = { StartingZone = true }
    if pY then
        pY = type(pX_1) == "table"
    end
    if pY then
        for k, v in pairs(pX_1) do
            if v then
                pW_2[tostring(k)] = true
            end
        end
    end
    return pW_2
end
function fns.fn32(i0, i1)
    local Type = i1.Type
    if Type == "Toggle" then
        return { idx = i0, type = "Toggle", value = i1.Value == true }
    elseif Type == "Slider" then
        return { idx = i0, type = "Slider", value = tostring(i1.Value) }
    elseif Type == "Dropdown" then
        return { idx = i0, type = "Dropdown", multi = i1.Multi == true, value = i1.Value }
    elseif Type == "Input" then
        local vC = i1.Value or ""
        return { idx = i0, type = "Input", text = tostring(vC) }
    elseif Type == "ColorPicker" then
        return { idx = i0, type = "ColorPicker", value = i1.Value:ToHex(), transparency = i1.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = i0,
            type = "KeyPicker",
            mode = i1.Mode,
            key = i1.Value,
            modifiers = i1.Modifiers,
            toggled = i1.Toggled
        }
    else
        return nil
    end
end
function fns.fn35()
    local rC = n_("TokenShopItems")
    local rD = {}
    for k, v in pairs(rC) do
        if v then
            rD[k] = true
        end
    end
    return rD
end
function fns.onExportConfigToClipboard()
    local v5_1
    local v4_1
    v4_1, v5_1 = pcall(HttpService.JSONEncode, HttpService, nb())
    if not v4_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local v4_2 = setclipboard
    local wa = if v4_2 then 1 else 0
    local v8 = 649 * wa + 4003 * (1 - wa)
    local v9 = 2521 * wa + 2927 * (1 - wa)
    if not ((v8 * 2972 + v9 * 2514 + v8 * v9) % 16777213 == 9902751) then
        v4_2 = toclipboard
    end
    local v6 = v4_2
    local v4_3 = type(v6) ~= "function" or not pcall(v6, v5_1)
    if v4_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
function fns.fn57()
    local py_1
    local pw_1
    pw_1, py_1 = pcall(function()
        return GetMyPlotFolder:InvokeServer()
    end)
    local pA = pw_1 and typeof(py_1) == "Instance"
    if pA then
        return py_1
    end
    return nil
end
function fns.onInputBegan()
    m3 = tick()
end
function fns.fn65()
    local pk = ny()
    local pl = pk and pk:FindFirstChildOfClass("Humanoid")
    return pl
end
function fns.fn81()
    if not Toggles.Fly.Value then
        local vk = nm()
        if vk then
            vk.PlatformStand = false
        end
    end
end
function fns.onCopyPayPalLink()
    nu(nC, "Copied PayPal link")
end
function fns.fn111()
    nu(nh, "Copied Discord invite to clipboard")
end
function fns.onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local uY_1 = ny()
        if uY_1 then
            for i, descendant in ipairs(uY_1:GetDescendants()) do
                local uY_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if uY_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
function fns.worker()
    local uD_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local uC = math.floor(os.clock() - mP)
        if uC < 60 then
            uD_1 = uC .. "s"
        elseif uC < 3600 then
            uD_1 = string.format("%dm %ds", math.floor((uC) / (60)), uC % 60)
        else
            uD_1 = string.format("%dh %dm", math.floor((uC) / (3600)), math.floor((uC % 3600) / (60)))
        end
        m2:SetText(mX("Session time", uD_1, mH))
    end
end
function fns.fn127(iT, iU)
    local vy_1 = (iT == "Toggle" and Toggles or Options)[iU]
    local vx_2 = type(vy_1) == "table" and vy_1.Type == iT
    return vx_2 and vy_1 or nil
end
function fns.fn130()
    return GetGenerators:InvokeServer()
end
function fns.onCopyJoinScript_JobID()
    local gJ = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, m_)
    nu(gJ, "Copied join script to clipboard")
end
function fns.fn140(ch, ci)
    local qj_3
    if ci == "StartingZone" then
        local StartingZone = ch:FindFirstChild("StartingZone")
        local qj_1 = StartingZone and StartingZone:FindFirstChild("Ground")
        local qi_2 = qj_1
        if qj_1 then
            qj_1 = qi_2:IsA("BasePart")
        end
        if qj_1 then
            return qi_2
        end
        local Unlockables = ch:FindFirstChild("Unlockables")
        local qj_2 = Unlockables and Unlockables:FindFirstChild(tostring(ci))
        local qi_4 = qj_2
        if qj_3 then
            qj_2 = qi_4:FindFirstChild("Ground")
        end
        local qi_5 = qj_2
        if qj_3 then
            qi_5:IsA("BasePart")
        end
        if qj_3 then
            return qi_5
        end
        return nil
    end
    local Unlockables = ch:FindFirstChild("Unlockables")
    qj_3 = Unlockables and Unlockables:FindFirstChild(tostring(ci))
    local qi_7 = qj_3
    if qj_3 then
        qj_3 = qi_7:FindFirstChild("Ground")
    end
    local qi_8 = qj_3
    if qj_3 then
        qj_3 = qi_8:IsA("BasePart")
    end
    if qj_3 then
        return qi_8
    end
    return nil
end
local function fn158(bb)
    local pg = Options[bb]
    return pg and pg.Value or {}
end
local function onCopyVenmoLink()
    nu(nw, "Copied Venmo link")
end
local function fn207()
    local PlayerData = LocalPlayer:FindFirstChild("PlayerData")
    local ur = PlayerData and PlayerData:FindFirstChild("LastDailyReward")
    local uq_1 = ur
    if ur then
        ur = uq_1.Value
    end
    local uq_2 = ur
    local uw = if uq_2 then 1 else 0
    local uu = 2567 * uw + 79 * (1 - uw)
    local uv = 1417 * uw + 38 * (1 - uw)
    if not ((uu * 1639 + uv * 414 + uu * uv) % 16777213 == 8431390) then
        uq_2 = 0
    end
    local ur_1 = uq_2
    local uq_3 = Config.DailyRewardSeconds or 86400
    local uq_4 = ur_1 > 0 and os.time() - ur_1 < uq_3
    if uq_4 then
        return
    end
    pcall(function()
        BaseShopEvent:FireServer("ClaimDailyReward")
    end)
end
local function fn217(cu)
    local qp = mJ()
    local qq = {}
    local qr = {}
    for k in pairs(qp) do
        if m0(cu, k) then
            local qp_1 = tonumber(k)
            if qp_1 then
                table.insert(qq, qp_1)
            else
                table.insert(qr, k)
            end
        end
    end
    table.sort(qr, function(cC, cD)
        if cC == "StartingZone" then
            return true
        elseif cD == "StartingZone" then
            return false
        else
            return cC < cD
        end
    end)
    table.sort(qq)
    for i, v in ipairs(qq) do
        table.insert(qr, tostring(v))
    end
    return qr
end
local function fn228()
    local pq = ny()
    local pr = pq and pq:FindFirstChild("HumanoidRootPart")
    return pr
end
local function fn240(db, dc, dd, de, df)
    local q0_1
    for i, v in ipairs(db) do
        local attr4 = v:GetAttribute("LocalX")
        local attr3 = v:GetAttribute("LocalZ")
        local attr2 = v:GetAttribute("BuildingId")
        local qY_1
        local attr = v:GetAttribute("Rot")
        local q_ = attr2 or ""
        q0_1, qY_1 = mZ(q_, attr)
        if nO(dc, dd, de, df, attr4, attr3, q0_1, qY_1) then
            return true
        end
    end
    return false
end
local function onPickupPower()
    task.spawn(mN)
end
local function fn265(a_)
    local o9 = Toggles[a_]
    return o9 ~= nil and o9.Value == true
end
local function fn270()
    local sR = mY()
    if not sR then
        return
    end
    local CityZones = sR:FindFirstChild("CityZones")
    if not CityZones then
        return
    end
    local sR_1 = nt()
    for i, child in ipairs(CityZones:GetChildren()) do
        local Name = child.Name
        if Name ~= "River" then
            local sT = false
            for i, child in ipairs(child:GetChildren()) do
                local sU_1 = (child:IsA("Model"))
                if sU_1 then
                    local sV = child:GetAttribute("PlacedCity") or child:GetAttribute("CityTier")
                    sU_1 = sV
                end
                if sU_1 then
                    sT = true
                    break
                end
            end
            if sT then
                mM(UpgradeCity, Name)
                task.wait(0.2)
            else
                if sR_1[Name] or Name == "StartingZone" then
                    mM(BuildCity, Name)
                    task.wait(0.2)
                end
            end
        end
    end
end
local function fn309(aA, aB)
    return string.format('<font color="%s">%s</font>', aB, aA)
end
local function onRenderStepped(h5)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local vd_1 = nm()
        if vd_1 then
            vd_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local vd_3 = nc()
        local ve = nm()
        if vd_3 and ve then
            ve.PlatformStand = true
            local ve_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                ve_1 = ve_1 + CurrentCamera2.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                ve_1 = ve_1 - CurrentCamera2.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                ve_1 = ve_1 - CurrentCamera2.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                ve_1 = ve_1 + CurrentCamera2.CFrame.RightVector
            end
            local vj = if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
            if vj == 1 then
                ve_1 = ve_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                ve_1 = ve_1 - Vector3.new(0, 1, 0)
            end
            vd_3.AssemblyLinearVelocity = Vector3.zero
            if ve_1.Magnitude > 0 then
                vd_3.CFrame = vd_3.CFrame + ve_1.Unit * Options.FlySpeed.Value * h5
            end
        end
    end
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            n6(true)
        end
    end
end
local function fn361(cR)
    return math.floor(cR * 2 + 0.5) / 2
end
local function fn365()
    mM(BuyExpansion)
end
local function fn377()
    local sL = mU()
    if next(sL) == nil then
        return
    end
    for k in pairs(sL) do
        mM(PurchaseUpgrade, k)
        task.wait(0.15)
    end
end
local function onCopyLitecoinAddress()
    nu(n4, "Copied Litecoin address")
end
local function fn413(ds, du, dv)
    local rj_1
    local ri_1
    local q8 = m0(ds, du)
    if not q8 then
        return nil
    end
    local q9 = mW(ds, du)
    local rc = q8.Size.X * 0.5
    local rd = q8.Size.Z * 0.5
    local re = { 0, 1, 2, 3 }
    local rf = 2.5
    local rg = nX(-rc + 2.5)
    while rg <= rc - rf + 0.01 do
        local rh = nX(-rd + rf)
        while rh <= rd - rf + 0.01 do
            for i, v in ipairs(re) do
                rj_1, ri_1 = mZ(dv, v)
                local rk = m7(q8, rg, rh, rj_1, ri_1) and not mL(q9, rg, rh, rj_1, ri_1)
                if rk then
                    return rg, rh, v
                end
            end
            rh += rf
        end
        rg += rf
    end
    return nil
end
local function fn416(d9)
    local rW = mT("MinPlaceRarity", "Common")
    local rX = mT("MaxPlaceRarity", "Galactic")
    local rZ = nD[d9 or ""] or 0
    return rZ >= (nD[rW] or 1) and rZ <= (nD[rX] or #nJ)
end
local function fn424(bL)
    local pJ_1
    local pH = BuildingData[bL]
    local pI = pH and pH.Footprint
    local pI_1
    if typeof(pI) == "Vector2" then
        return math.max(1, math.floor(pI.X + 0.5)), math.max(1, math.floor(pI.Y + 0.5))
    elseif type(pI) == "string" then
        pI_1, pJ_1 = string.match(pI, "([%d%.]+)%s*,%s*([%d%.]+)")
        local max = math.max
        local pL = (tonumber(pI_1))
        local pQ = if pL then 1 else 0
        local pO = 3434 * pQ + 431 * (1 - pQ)
        local pP = 800 * pQ + 1913 * (1 - pQ)
        if not ((pO * 2404 + pP * 3174 + pO * pP) % 16777213 == 13541736) then
            pL = 5
        end
        local pI_2 = max(1, math.floor(pL))
        local pM = tonumber(pJ_1) or 5
        return pI_2, max(1, math.floor(pM))
    else
        return 5, 5
    end
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local u8_1 = nm()
        if u8_1 then
            u8_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function onCopyUSDTAddress()
    nu(nP, "Copied USDT address")
end
local function onUnload()
    Library:Unload()
end
local function fn482(hf)
    local DiscordGroup = hf:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = ng })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = ng })
end
local function fn507()
    local tb = mY()
    if not tb then
        return
    end
    local tc = mJ()
    local Unlockables = tb:FindFirstChild("Unlockables")
    if Unlockables then
        local te = {}
        for i, child in ipairs(Unlockables:GetChildren()) do
            local td_1 = tonumber(child.Name)
            if td_1 then
                table.insert(te, td_1)
            end
        end
        table.sort(te)
        for i, v in ipairs(te) do
            if not tc[tostring(v)] then
                mM(UnlockZone, v)
                task.wait(0.2)
            end
        end
    end
    local td_2 = nt()
    local CityZones = tb:FindFirstChild("CityZones")
    if CityZones then
        local tb_1 = {}
        for i, child in ipairs(CityZones:GetChildren()) do
            local tc_2 = tonumber(child.Name)
            if tc_2 then
                table.insert(tb_1, tc_2)
            end
        end
        table.sort(tb_1)
        for i, v in ipairs(tb_1) do
            if not td_2[tostring(v)] then
                mM(UnlockCityZone, v)
                task.wait(0.2)
            end
        end
    end
end
local function fn564(a4, a5)
    local pc = Options[a4]
    local pd = pc and pc.Value
    local pd_1 = pd ~= ""
    local pe = type(pd) == "string" and pd_1
    if pe then
        return pd
    end
    return a5
end
local function fn568()
    return LocalPlayer.Character
end
local function fn612()
    if not Toggles.WalkSpeedEnabled.Value then
        local vm = nm()
        if vm then
            vm.WalkSpeed = 16
        end
    end
end
local function fn622()
    local rs = n_("PowerShopItems")
    local rt = {}
    for k, v in pairs(rs) do
        if v then
            local rs_1 = na[k] or k
            rt[rs_1] = true
        end
    end
    return rt
end
local function fn627(cT, cU, cV, cW, cX, cY, cZ, c_)
    local qQ = math.abs(cT - cX) < (cV + cZ) * 0.5 - 0.01 and math.abs(cU - cY) < (cW + c_) * 0.5 - 0.01
    return qQ
end
local function fn643()
    pcall(function()
        connection:Disconnect()
    end)
    pcall(function()
        connection2:Disconnect()
    end)
    n6(false)
    local wo = nm()
    if wo then
        wo.PlatformStand = false
        wo.WalkSpeed = 16
    end
end
local function fn648(cH, cI)
    local Buildings = cH:FindFirstChild("Buildings")
    local qE = Buildings and Buildings:FindFirstChild(tostring(cI))
    local qD_1 = {}
    if qE then
        for i, child in ipairs(qE:GetChildren()) do
            local qE_1 = child:IsA("Model") and child:GetAttribute("LocalX") ~= nil and child:GetAttribute("LocalZ") ~= nil
            if qE_1 then
                table.insert(qD_1, child)
            end
        end
    end
    return qD_1
end
local function onInputChanged(hE)
    local UserInputType = hE.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        m3 = tick()
    end
end
local function fn723()
    local sE_1
    local sD_1
    local sC = ne()
    if next(sC) == nil then
        return
    end
    sD_1, sE_1 = pcall(function()
        return GetShopState:InvokeServer()
    end)
    local sF = sD_1 and type(sE_1) == "table"
    local sF_1 = sF and sE_1 or {}
    for k in pairs(sC) do
        local sC_1 = sF_1[k]
        if sC_1 == nil or sC_1 > 0 then
            mM(BuyItem, k)
            task.wait(0.15)
        end
    end
end
local function fn735()
    local p9_1
    local p8_1
    p8_1, p9_1 = pcall(function()
        return GetUnlockedCityZones:InvokeServer()
    end)
    local qa = p8_1
    local p8_2 = {}
    if qa then
        qa = type(p9_1) == "table"
    end
    if qa then
        for k, v in pairs(p9_1) do
            if v then
                p8_2[tostring(k)] = true
            end
        end
    end
    return p8_2
end
local function onImportConfigFromClipboardTex()
    local wd_1
    local wb = Options.SaveManager_ImportSource.Value or ""
    local wb_1
    local wc = tostring(wb):match("^%s*(.-)%s*$")
    if wc == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    wb_1, wd_1 = pcall(HttpService.JSONDecode, HttpService, wc)
    local wc_1 = not wb_1 or type(wd_1) ~= "table" or type(wd_1.objects) ~= "table"
    if wc_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local wb_2 = 0
    for i, v in ipairs(wd_1.objects) do
        if nV(v) then
            wb_2 += 1
        end
    end
    if wb_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local wd_2 = wb_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(wb_2, wd_2), 6)
end
local function fn744()
    local rL = n_("PlacePowerItems")
    local rM = false
    local rN = {}
    for k, v in pairs(rL) do
        if v then
            rM = true
            local rL_1 = na[k] or k
            rN[rL_1] = true
        end
    end
    return rN, rM
end
local function fn786(aD, aE, aF)
    return string.format("<b>%s</b> %s %s", aD, m6("-", "#5a6070"), m6(aE, aF))
end
local function onCopyEthereumAddress()
    nu(nS, "Copied Ethereum address")
end
local function fn806()
    local vF = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local vG = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if vG then
                local vG_1 = nk(k, v)
                if vG_1 then
                    vF[#vF + 1] = vG_1
                end
            end
        end
    end
    table.sort(vF, function(jb, jc)
        if jb.type ~= jc.type then
            return jb.type < jc.type
        end
        return jb.idx < jc.idx
    end)
    return { objects = vF }
end
local function onCopySolanaAddress()
    nu(nH, "Copied Solana address")
end
local function onRscripts()
    nu(nf, "Copied Rscripts profile to clipboard")
end
local function fn824()
    local tZ = mY()
    if not tZ then
        return
    end
    local Buildings = tZ:FindFirstChild("Buildings")
    if not Buildings then
        return
    end
    local tZ_1 = {}
    for i, child in ipairs(Buildings:GetChildren()) do
        for i, child2 in ipairs(child:GetChildren()) do
            if child2:IsA("Model") then
                local t__1 = child2:GetAttribute("BuildingId")
                local attr2 = child2:GetAttribute("LocalX")
                local attr = child2:GetAttribute("LocalZ")
                local t2 = child2:GetAttribute("ZoneName") or child.Name
                local t3 = t__1
                if t3 then
                    t3 = BuildingData[t__1]
                end
                local t2_1 = t3
                local t3_1 = type(t__1) == "string" and t2_1 and t2_1.Type == "Generator"
                if t3_1 and attr2 ~= nil and attr ~= nil then
                    table.insert(tZ_1, { zoneName = t2, buildingId = t__1, x = attr2, z = attr })
                end
            end
        end
    end
    for i, v in ipairs(tZ_1) do
        mM(PickupBuilding, v.zoneName, v.buildingId, v.x, v.z)
        task.wait(0.08)
    end
end
local function worker2()
    while not Library.Unloaded do
        task.wait(0.75)
        if m4("AutoBuyPowerShop") then
            pcall(nd)
        end
        if m4("AutoBuyTokenShop") then
            pcall(n3)
        end
        if m4("AutoBuyZones") then
            pcall(n8)
        end
        if m4("AutoExpandPlot") then
            pcall(mI)
        end
        if m4("AutoUpgradeNeighbourhood") then
            pcall(nv)
        end
        if m4("AutoPlacePower") then
            pcall(n0)
        end
        if m4("AutoClaimDailyRewards") then
            pcall(mV)
        end
    end
end
local function fn868()
    local tJ_1
    local tI_1
    local tH_1
    local tD = mY()
    if not tD then
        return
    end
    local tE = nM(tD)
    local tF = mQ()
    if #tF == 0 or #tE == 0 then
        return
    end
    local tO = false
    for i, v in ipairs(tF) do
        local tN = 10
        while true do
            if tN < 5 then
                if tN < 2 then
                    if tN < 1 then
                        tN = 2
                    else
                        tN = 8
                    end
                elseif tN < 3 then
                    tN = if tF > 0 then 7 else 4
                elseif tN < 4 then
                    break
                else
                    tN = 8
                end
            elseif tN < 8 then
                if tN < 6 then
                    tN = 0
                elseif tN < 7 then
                    tO = true
                    tN = 3
                else
                    local tG_1 = false
                    for i, v2 in ipairs(tE) do
                        tI_1, tJ_1, tH_1 = m8(tD, v2, v.id)
                        if tI_1 ~= nil and tJ_1 ~= nil then
                            local id = v.id
                            local tL_1 = tH_1 or 0
                            local tH_2 = mM(PlaceBuilding, v2, id, tI_1, tJ_1, tL_1)
                            if tH_2 == true then
                                tG_1 = true
                                tF -= 1
                                task.wait(0.15)
                                break
                            end
                        end
                    end
                    tN = if not tG_1 then 1 else 9
                end
            elseif tN < 9 then
                tN = 3
            elseif tN < 10 then
                tN = 5
            else
                tF = v.amount
                tN = 0
            end
        end
        if tO then
            break
        end
    end
end
local function fn913(c2, c3, c4, c5, c6)
    local qS = c2.Size.X * 0.5
    local qT = c2.Size.Z * 0.5
    local qU = math.abs(c3) + c5 * 0.5 <= qS + 0.01 and math.abs(c4) + c6 * 0.5 <= qT + 0.01
    return qU
end
local function fn926()
    local uy_1
    local ux_1
    if identifyexecutor then
        uy_1, ux_1 = identifyexecutor()
        local uz = uy_1 ~= ""
        local uA = type(uy_1) == "string" and uz
        if uA then
            local uz_1 = type(ux_1) == "string" and ux_1 ~= "" and uy_1 .. " " .. ux_1
            np = uz_1 or uy_1
        end
    end
end
local function fn939()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    m1 = tick()
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local uU = tick() - m3
            local uV = tick() - m1
            if uU >= 300 and uV >= 60 then
                pcall(mS)
            else
                if uU < 300 and uV >= 300 then
                    pcall(mS)
                end
            end
        end
    end
end
local function onCopyBitcoinAddress()
    nu(nY, "Copied Bitcoin address")
end
local function fn986(bT, bU)
    local pS_1
    local pR_1
    pR_1, pS_1 = nn(bT)
    local pT = tonumber(bU) or 0
    if pT % 2 == 1 then
        return pS_1, pR_1
    end
    return pR_1, pS_1
end
PurchaseUpgrade = nil
mH = nil
mI = nil
mJ = nil
GetShopState = nil
mL = nil
mM = nil
mN = nil
GetGenerators = nil
mP = nil
mQ = nil
BuyItem = nil
mS = nil
mT = nil
mU = nil
mV = nil
mW = nil
mX = nil
mY = nil
mZ = nil
m_ = nil
m0 = nil
m1 = nil
m2 = nil
m3 = nil
m4 = nil
BuildingData = nil
m6 = nil
m7 = nil
m8 = nil
Config = nil
na = nil
nb = nil
nc = nil
nd = nil
ne = nil
nf = nil
ng = nil
nh = nil
BaseShopEvent = nil
nk = nil
PickupBuilding = nil
nm = nil
nn = nil
LocalPlayer = nil
np = nil
PlaceBuilding = nil
Workspace = nil
BuildCity = nil
local nj
nt = nil
nu = nil
nv = nil
nw = nil
connection2 = nil
ny = nil
UpgradeCity = nil
Options = nil
nC = nil
nD = nil
UnlockCityZone = nil
Toggles = nil
nH = nil
CurrentCamera2 = nil
nJ = nil
HttpService = nil
UnlockZone = nil
nM = nil
SaveManager = nil
nO = nil
nP = nil
VirtualUser = nil
GetUnlockedCityZones = nil
nS = nil
UserInputService = nil
GetUnlockedZones = nil
nV = nil
Library = nil
nX = nil
nY = nil
connection = nil
n_ = nil
n0 = nil
GetMyPlotFolder = nil
n3 = nil
n4 = nil
n6 = nil
BuyExpansion = nil
n8 = nil
local CoreGui, GuiService, n2
CoreGui = nil
GuiService = nil
n2 = nil
local n5
local ou, ov, ow, oy, oA, oB
UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, LocalPlayer, nh, nf, Config, BuildingData, BuyItem, GetGenerators, GetShopState, PurchaseUpgrade, BuyExpansion, GetMyPlotFolder, GetUnlockedZones, GetUnlockedCityZones, UnlockZone, UnlockCityZone, UpgradeCity, BuildCity, PlaceBuilding, PickupBuilding, BaseShopEvent, na = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local wA_2 = game:GetService("Players")
local wA_10 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
LocalPlayer = wA_2.LocalPlayer
local wA_3 = "Power a City"
nh = "https://discord.gg/K7Qxnxkk46"
nf = "https://discord.gg/K7Qxnxkk46"
local wA_1 = wA_10:WaitForChild("Shared"):WaitForChild("Modules")
Config = require(wA_1:WaitForChild("Config"))
BuildingData = require(wA_1:WaitForChild("BuildingData"))
local wA_17 = wA_10:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services")
local wA_8 = wA_17:WaitForChild("ShopService"):WaitForChild("RF")
local wA_24 = wA_17:WaitForChild("UpgradeService"):WaitForChild("RF")
local wA_14 = wA_17:WaitForChild("PlotService"):WaitForChild("RF")
local wA_4 = wA_17:WaitForChild("CityService"):WaitForChild("RF")
local wA_11 = wA_17:WaitForChild("BuildService"):WaitForChild("RF")
BuyItem = wA_8:WaitForChild("BuyItem")
GetGenerators = wA_8:WaitForChild("GetGenerators")
GetShopState = wA_8:WaitForChild("GetShopState")
PurchaseUpgrade = wA_24:WaitForChild("PurchaseUpgrade")
BuyExpansion = wA_14:WaitForChild("BuyExpansion")
GetMyPlotFolder = wA_14:WaitForChild("GetMyPlotFolder")
GetUnlockedZones = wA_14:WaitForChild("GetUnlockedZones")
GetUnlockedCityZones = wA_14:WaitForChild("GetUnlockedCityZones")
UnlockZone = wA_14:WaitForChild("UnlockZone")
UnlockCityZone = wA_14:WaitForChild("UnlockCityZone")
UpgradeCity = wA_4:WaitForChild("UpgradeCity")
BuildCity = wA_4:WaitForChild("BuildCity")
PlaceBuilding = wA_11:WaitForChild("PlaceBuilding")
PickupBuilding = wA_11:WaitForChild("PickupBuilding")
BaseShopEvent = wA_10:WaitForChild("Assets"):WaitForChild("Events"):WaitForChild("BaseShopEvent")
local wA_16 = {}
local wA_19 = {}
na = {}
wA_6, wA_9 = pcall(fns.fn130)
local wA_26 = wA_6
if wA_26 then
    wA_2 = 6
    repeat
        local xo = bit32.rrotate(bit32.bxor(bit32.lrotate(wA_2, 5), string.byte(tostring(wA_2))), 18)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(xo, 1033730673), 2878727588), (bit32.bxor(bit32.band(xo, 3261236622), 977035286))), 2878727588), 977035286) == xo then
            wA_26 = type(wA_9) == "table"
        else
            wA_9 = type(wA_26) == "table"
        end
        wA_2 = (wA_2 + 7) % 8
    until (wA_2 * 5 + 6) % 8 == 7
end
if wA_26 then
    for i, v in ipairs(wA_9) do
        wA_2 = v.id
        wA_11 = v.shopName or wA_2
        wA_22 = wA_11
        if type(wA_2) == "string" then
            table.insert(wA_16, wA_22)
            table.insert(wA_19, wA_2)
            na[wA_22] = wA_2
            na[wA_2] = wA_2
        end
    end
end
wA_2 = {}
wA_11 = Config.PLAYTIME_UPGRADE_IDS
if type(wA_11) == "table" then
    for i, v in ipairs(wA_11) do
        table.insert(wA_2, v)
    end
end
Library, SaveManager, Toggles, Options, mH, n4, nY, nS, nP, nH, nC, nw, nJ, nD, nu, ng, m6, mX, m4, mT, n_, ny, nm, nc, mY, mM = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
wA_26 = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
nu = fns.fn8
ng = fns.fn111
m6 = fn309
mX = fn786
wA_14 = "#7fd47f"
wA_4 = "#6ec1ff"
mH = "#e8a34d"
local wA_18 = "#8b93a3"
n4 = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
nY = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
nS = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
nP = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
nH = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
nC = ""
nw = ""
wA_6 = "#345d9d"
wA_19 = "#f7931a"
wA_10 = "#627eea"
wA_1 = "#26a17b"
wA_17 = "#14f195"
wA_8 = "#0070ba"
wA_24 = "#008cff"
if false or (not Toggles or false) or (not Toggles or not Toggles) and (mY and not mY) or not Toggles and mY and (mY or not Toggles) and (false and Toggles and (false and Toggles)) or not (false or (not Toggles or false) or (not Toggles or not Toggles) and (mY and not mY) or not Toggles and mY and (mY or not Toggles) and (false and Toggles and (false and Toggles))) then
    m4 = fn265
else
    nm = fn265
end
mT = fn564
n_ = fn158
ny = fn568
nm = fns.fn65
nc = fn228
mY = fns.fn57
mM = function(bA, ...)
    local pF_1
    local pE_1
    local pD_1
    local pC_1
    pC_1, pF_1, pD_1, pE_1 = pcall(function(...)
        return bA:InvokeServer(...)
    end, ...)
    if not pC_1 then
        return false, tostring(pF_1)
    end
    return pF_1, pD_1, pE_1
end
nJ = { "Common", "Uncommon", "Rare", "Legendary", "Mythic", "Royal", "Galactic" }
nD = {}
for i, v in ipairs(nJ) do
    nD[v] = i
end
wA_9, ow, np, wA_22, ov, m2, m_, ou, nn, mZ, mJ, nt, m0, nM, mW, nX, nO, m7, mL, m8, ne, mU, n5, nj, mQ, nd, n3, nv, n8, mI, n0, mN, mV = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
wA_11 = 34
repeat
    oy = (wA_11 * 13 + 10) % 14 + 1
    if oy <= 7 then
        if oy <= 4 then
            if oy <= 2 then
                if oy <= 1 then
                    oA = {
                        "hhnjptmnyac",
                        "wqlaklbumf",
                        "oulb",
                        "etfdnkflrw",
                        "azcxn",
                        "bzp",
                        "uslsfg",
                        "jxnkamppf",
                        "slegfp",
                        "qpnoxnastf"
                    }
                    local xg = wA_11
                    oB = oA[xg % 10 + 1]
                    if oB:len() <= oB:gsub("(.)", "%1%1", xg % 3 % 2 + 1):len() then
                        ow = {
                            Info = wA_9:AddTab("Info", "info"),
                            Main = wA_9:AddTab("Main", "zap"),
                            Player = wA_9:AddTab("Player", "person-standing"),
                            Settings = wA_9:AddTab("Settings", "settings")
                        }
                    else
                        wA_9 = {
                            Main = ow:AddTab("Main", "zap"),
                            Info = ow:AddTab("Info", "info"),
                            Settings = ow:AddTab("Settings", "settings"),
                            Player = ow:AddTab("Player", "person-standing")
                        }
                    end
                    wA_11 = (wA_11 + 27) % 56
                else
                    oA = (vector.create((wA_11 * 7 + 4) % 11 + 1, (wA_11 * 2 + 1) % 13 + 1, (wA_11 * 14 + 6) % 17 + 1))
                    oB = (vector.create((wA_11 * 7 + 6) % 11 + 1, (wA_11 * 9 + 9) % 13 + 1, (wA_11 * 6 + 4) % 17 + 1))
                    local xN = vector.cross(oA, oB)
                    local xO = vector.dot(oA, oB)
                    if vector.dot(xN, xN) + xO * xO == vector.dot(oA, oA) * vector.dot(oB, oB) + 3 then
                        ov = "Unknown"
                        pcall(fn926)
                        m2 = (nil):AddLeftGroupbox("Account", "circle-user")
                        m2:AddLabel(wA_22("User", mX.Name, LocalPlayer), true)
                        m2:AddLabel(wA_22("Status", "Keyless", LocalPlayer), true)
                        m2:AddLabel(wA_22("Executor", "Unknown", LocalPlayer), true)
                        np = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
                        np:AddLabel(wA_3(m6 .. " [" .. tostring(game.PlaceId) .. "]", mH), true)
                        np:AddLabel(wA_22("Place ID", tostring(game.PlaceId), mH), true)
                        ow = np:AddLabel(wA_22("Session time", "0s", wA_14), true)
                    else
                        np = "Unknown"
                        pcall(fn926)
                        wA_22 = ow.Info:AddLeftGroupbox("Account", "circle-user")
                        wA_22:AddLabel(mX("User", LocalPlayer.Name, wA_14), true)
                        wA_22:AddLabel(mX("Status", "Keyless", wA_14), true)
                        wA_22:AddLabel(mX("Executor", np, wA_14), true)
                        ov = ow.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                        ov:AddLabel(m6(wA_3 .. " [" .. tostring(game.PlaceId) .. "]", wA_4), true)
                        ov:AddLabel(mX("Place ID", tostring(game.PlaceId), wA_4), true)
                        m2 = ov:AddLabel(mX("Session time", "0s", mH), true)
                    end
                    wA_11 = (wA_11 + 13) % 56
                end
            elseif oy <= 3 then
                oA = {
                    "zjqhv",
                    "lhfgm",
                    "yzxcdt",
                    "yurafcra",
                    "qgi",
                    "bhxq",
                    "hpdimqhvwblu",
                    "tuygnoupa",
                    "vqfspndonz",
                    "wcyw",
                    "mffme",
                    "rqzzvfuxnvbf",
                    "djhehregadpo",
                    "qnadyrggn"
                }
                if oA[(wA_11 * 7 + 18) % 14 + 1] < oA[(wA_11 * 7 + 18) % 14 + 1] then
                    np = tostring(game.JobId)
                else
                    m_ = tostring(game.JobId)
                end
                wA_11 = (wA_11 + 55) % 56
            else
                oA = {
                    "mqvhtc",
                    "aixqgvkts",
                    "mveuhtwmhul",
                    "tsdvkochh",
                    "xvqf",
                    "zxeoniozmp",
                    "tubrslzgw",
                    "wbyxlqwak",
                    "yjeewydl",
                    "zyilkxxgjj",
                    "xiafvxckvn",
                    "dfzpgerfs",
                    "vfzsmsm",
                    "eladtnj"
                }
                if oA[(wA_11 * 62 + 74) % 14 + 1] < oA[(wA_11 * 62 + 74) % 14 + 1] then
                    m_ = #ou > 18
                else
                    ou = #m_ > 18
                end
                wA_11 = (wA_11 + 41) % 56
            end
        elseif oy <= 6 then
            if oy <= 5 then
                if (mN and not nj or (not ov or not ov)) and (ov or nj or mN and nd) or (not m_ and nj or (ov or m_)) and (not ov and ov and (not nj and mN)) or not ((mN and not nj or (not ov or not ov)) and (ov or nj or mN and nd) or (not m_ and nj or (ov or m_)) and (not ov and ov and (not nj and mN))) then
                    nn = fn424
                    mZ = fn986
                else
                    mZ = fn424
                    nn = fn986
                end
                wA_11 = (wA_11 + 41) % 56
            else
                oA = {
                    "anniba",
                    "mmivxur",
                    "fyg",
                    "whrxcxetokn",
                    "slgb",
                    "pkqmn",
                    "haxbafrmwa",
                    "qqvad",
                    "ebsa",
                    "bhzxrh",
                    "stkhqecdl"
                }
                local xn = wA_11
                oB = oA[xn % 11 + 1]
                if oB:len() <= oB:gsub("(.)", "%1%1", xn % 3 % 2 + 1):len() then
                    mJ = fns.fn12
                    nt = fn735
                    m0 = fns.fn140
                    nM = fn217
                    mW = fn648
                else
                    nM = fns.fn12
                    mW = fn735
                    nt = fns.fn140
                    m0 = fn217
                    mJ = fn648
                end
                wA_11 = (wA_11 + 13) % 56
            end
        else
            local xu = bit32.rrotate(bit32.bxor(bit32.lrotate(wA_11, 29), string.byte(tostring(n8))), 24)
            if bit32.bxor(bit32.lrotate(bit32.bxor(xu, 234062847), 14), 3774858108) ~= bit32.lrotate(xu, 14) then
                nO = fn361
                nX = fn627
            else
                nX = fn361
                nO = fn627
            end
            wA_11 = (wA_11 + 13) % 56
        end
    elseif oy <= 11 then
        if oy <= 9 then
            if oy <= 8 then
                local xH = bit32.rrotate(bit32.bxor(bit32.lrotate(wA_11, 17), string.byte(tostring(ne))), 7)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(xH, 622198827), 2905152247), (bit32.bxor(bit32.band(xH, 3672768468), 3637817665))), 2905152247), 3637817665) == xH then
                    m7 = fn913
                    mL = fn240
                    m8 = fn413
                    ne = fn622
                else
                    ne = fn913
                    m7 = fn240
                    mL = fn413
                    m8 = fn622
                end
                wA_11 = (wA_11 + 13) % 56
            else
                oA = {
                    "mrnusc",
                    "nieibsjcmk",
                    "xhkf",
                    "qkzpluq",
                    "fsciob",
                    "elwykooktn",
                    "ubgcnskl",
                    "fmgqmsalqm",
                    "ophwcbiu",
                    "aaiqsuwpg",
                    "mpa",
                    "ooxadbjn",
                    "kcotfsxmp",
                    "qzggxdg",
                    "rllawervk"
                }
                if oA[(wA_11 * 35 + 61) % 15 + 1] <= oA[(wA_11 * 35 + 61) % 15 + 1] then
                    mU = fns.fn35
                    n5 = fn744
                else
                    n5 = fns.fn35
                    mU = fn744
                end
                wA_11 = (wA_11 + 41) % 56
            end
        elseif oy <= 10 then
            if (wA_11 * 2 + 6) * 10 % 3 == ((wA_11 * 2 + 6) * 10 + 3) % 3 then
                nj = fn416
            else
                wA_22 = fn416
            end
            wA_11 = (wA_11 + 27) % 56
        else
            local xr = bit32.rrotate(bit32.bxor(bit32.lrotate(wA_11, 19), string.byte(tostring(nj))), 15)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(xr, 1422052065), 2732369249), (bit32.bxor(bit32.band(xr, 2872915230), 921600388))), 2732369249), 921600388) == xr then
                mQ = function()
                    local sl, sm, sn, so, sp
                    sl = {}
                    so = {}
                    sp, sn = n5()
                    local function sq(eq)
                        if not eq then
                            return
                        end
                        for i, child in ipairs(eq:GetChildren()) do
                            local r0 = child:IsA("Tool") and not sl[child]
                            if r0 then
                                local attr = child:GetAttribute("BuildingId")
                                local r1 = attr and BuildingData[attr]
                                local r1_4 = type(attr) == "string" and r1 and r1.Type == "Generator"
                                if r1_4 then
                                    local r1_5 = (nj(r1.Rarity))
                                    if r1_5 then
                                        r1_5 = not sn or sp[attr]
                                    end
                                    if r1_5 then
                                        sl[child] = true
                                        local r1_6 = tonumber(child:GetAttribute("Amount")) or 1
                                        table.insert(so, { tool = child, id = attr, amount = math.max(1, r1_6), rarity = r1.Rarity })
                                    end
                                end
                            end
                        end
                    end
                    sq(LocalPlayer:FindFirstChild("Backpack"))
                    sq(ny())
                    sq = mT("PlacePriority", "Best")
                    if sq == "Random" then
                        local sw = #so
                        local sv = -1
                        while false and sw <= 2 or true and sw >= 2 do
                            local sx = sw
                            local sr_2 = math.random(sx)
                            so[sx], so[sr_2] = so[sr_2], so[sx]
                            sw += sv
                        end
                    else
                        sm = sq ~= "Worst"
                        table.sort(so, function(eE, eF)
                            local si = nD[eE.rarity or ""] or 0
                            local si_4 = nD[eF.rarity or ""] or 0
                            if si ~= si_4 then
                                if sm then
                                    return si > si_4
                                end
                                return si < si_4
                            end
                            return eE.id < eF.id
                        end)
                    end
                    return so
                end
                nd = fn723
                n3 = fn377
                nv = fn270
                n8 = fn507
            else
                nd = function()
                    local sl, sm, sn, so, sp
                    sl = {}
                    so = {}
                    sp, sn = n5()
                    local function sq(eq)
                        if not eq then
                            return
                        end
                        for i, child in ipairs(eq:GetChildren()) do
                            local r0 = child:IsA("Tool") and not sl[child]
                            if r0 then
                                local attr = child:GetAttribute("BuildingId")
                                local r1 = attr and BuildingData[attr]
                                local r1_1 = type(attr) == "string" and r1 and r1.Type == "Generator"
                                if r1_1 then
                                    local r1_2 = (nj(r1.Rarity))
                                    if r1_2 then
                                        r1_2 = not sn or sp[attr]
                                    end
                                    if r1_2 then
                                        sl[child] = true
                                        local r1_3 = tonumber(child:GetAttribute("Amount")) or 1
                                        table.insert(so, { tool = child, id = attr, amount = math.max(1, r1_3), rarity = r1.Rarity })
                                    end
                                end
                            end
                        end
                    end
                    sq(LocalPlayer:FindFirstChild("Backpack"))
                    sq(ny())
                    sq = mT("PlacePriority", "Best")
                    if sq == "Random" then
                        local sw = #so
                        local sv = -1
                        while false and sw <= 2 or true and sw >= 2 do
                            local sx = sw
                            local sr_1 = math.random(sx)
                            so[sx], so[sr_1] = so[sr_1], so[sx]
                            sw += sv
                        end
                    else
                        sm = sq ~= "Worst"
                        table.sort(so, function(eE, eF)
                            local si = nD[eE.rarity or ""] or 0
                            local si_2 = nD[eF.rarity or ""] or 0
                            if si ~= si_2 then
                                if sm then
                                    return si > si_2
                                end
                                return si < si_2
                            end
                            return eE.id < eF.id
                        end)
                    end
                    return so
                end
                mQ = fn723
                n8 = fn377
                n3 = fn270
                nv = fn507
            end
            wA_11 = (wA_11 + 41) % 56
        end
    elseif oy <= 13 then
        if oy <= 12 then
            if wA_11 * 125256863 + 6 + 6 >= wA_11 * 125256863 + 6 + 6 + 1 then
                mN = fn365
                mI = fn868
                n0 = fn824
            else
                mI = fn365
                n0 = fn868
                mN = fn824
            end
            wA_11 = (wA_11 + 55) % 56
        else
            oy = {
                "fvkwpj",
                "lxnbqbkhdai",
                "nfbmbhsbbu",
                "bxlr",
                "ytak",
                "hvfxahjjub",
                "fpwvqpc",
                "lpyt",
                "jwzmkf",
                "xwg",
                "yuvxem",
                "uqlodtqjnu"
            }
            local xQ = wA_11
            oA = oy[xQ % 12 + 1]
            if oA:len() >= oA:gsub("(.)", "%1%1", xQ % 3 % 2 + 1):len() then
                ne = fn207
            else
                mV = fn207
            end
            wA_11 = (wA_11 + 41) % 56
        end
    else
        if wA_11 * 132681483 + 10 + 1 <= wA_11 * 132681483 + 10 + 1 + 2 then
            wA_9 = Library:CreateWindow({
                Title = "Tempo Hub",
                Footer = { { Text = nh, Copyable = true }, "|", wA_3 },
                Icon = 12645376577,
                NotifySide = "Right",
                ShowCustomCursor = false,
                CornerRadius = 10
            })
        else
            wA_3 = nh:CreateWindow({
                CornerRadius = 10,
                ShowCustomCursor = false,
                Icon = 12645376577,
                Title = "Tempo Hub",
                NotifySide = "Right",
                Footer = { { Text = Library, Copyable = true }, wA_9, "|" }
            })
        end
        wA_11 = (wA_11 + 27) % 56
    end
until (wA_11 * 9 + 1) % 56 == 27
if ou then
    wA_11 = 0
    repeat
        local xz = bit32.rrotate(bit32.bxor(bit32.lrotate(wA_11, 18), string.byte(tostring(wA_11))), 10)
        if bit32.bxor(bit32.lrotate(bit32.bxor(xz, 2971889335), 24), 3081839470) ~= bit32.lrotate(xz, 24) then
            m_ = string.sub(ou, 1, 18) .. "..."
        else
            ou = string.sub(m_, 1, 18) .. "..."
        end
        wA_11 = (wA_11 + 3) % 8
    until (wA_11 * 5 + 0) % 8 == 7
end
wA_11 = ou or m_
mP = nil
wA_22 = wA_11
ov:AddLabel(mX("Server", wA_22, wA_18), true)
ov:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
mP = os.clock()
task.spawn(fns.worker)
local ScriptsGroup = ow.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(m6("Included in this hub", wA_18), true)
ScriptsGroup:AddLabel(m6(wA_3, wA_4), true)
oB = ow.Info:AddRightGroupbox("Features", "list")
oB:AddLabel(m6("Auto Buy", mH), true)
oB:AddLabel(m6("Auto Upgrade", wA_4), true)
oB:AddLabel(m6("Auto Place", wA_14), true)
oB:AddLabel(m6("Auto Claim", wA_4), true)
oB:AddLabel(m6("Player Utilities", wA_18), true)
oA = ow.Info:AddRightGroupbox("Socials", "link")
oA:AddButton({ Text = "Discord", Func = ng })
oA:AddButton({ Text = "Rscripts", Func = onRscripts })
oy = ow.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
oy:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
oy:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
oy:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
oy:AddButton({ Text = "Copy Discord Invite", Func = ng })
ou = ow.Info:AddRightGroupbox("Donations", "heart")
ou:AddLabel(m6("All donations are optional but appreciated.", mH), true)
ou:AddLabel(m6("If you donate you get a special role, just PING after you donate.", wA_14), true)
ou:AddDivider()
ou:AddLabel(m6("LTC / Litecoin", wA_6), true)
ou:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
ou:AddLabel(m6("BTC / Bitcoin", wA_19), true)
ou:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
ou:AddLabel(m6("ETH / Ethereum", wA_10), true)
ou:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
ou:AddLabel(m6("USDT", wA_1), true)
ou:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
ou:AddLabel(m6("Solana", wA_17), true)
ou:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
ou:AddLabel(m6("PayPal", wA_8), true)
ou:AddButton({ Text = "Copy PayPal Link", Func = fns.onCopyPayPalLink })
ou:AddLabel(m6("Venmo", wA_24), true)
ou:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
ou:AddDivider()
ou:AddLabel(m6("Don't have any of the listed currencies but still wanna donate?", wA_18), true)
ou:AddLabel(m6("DM me and we'll work something out.", wA_4), true)
local FaqGroup = ow.Info:AddRightGroupbox("FAQ", "circle-help")
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
for k, v in pairs(ow) do
    if v ~= ow.Info then
        fn482(v)
    end
end
m3, m1, connection, connection2, CurrentCamera2, mS, n6, n2, nk, nb, nV = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
wA_8 = ow.Main:AddLeftGroupbox("Automation", "bot")
wA_8:AddToggle("AutoBuyPowerShop", { Text = "Auto Buy Power Shop", Default = false })
wA_8:AddDropdown("PowerShopItems", {
    Text = "Power Shop Items",
    Values = wA_16,
    Default = {},
    Multi = true,
    AllowNull = true,
    Searchable = true
})
wA_8:AddToggle("AutoUpgradeNeighbourhood", { Text = "Auto Upgrade Neighbourhood", Default = false })
wA_8:AddToggle("AutoBuyZones", { Text = "Auto Buy Zones", Default = false })
wA_8:AddToggle("AutoExpandPlot", { Text = "Auto Expand Plot", Default = false })
wA_8:AddToggle("AutoBuyTokenShop", { Text = "Auto Buy Token Shop", Default = false })
wA_8:AddDropdown("TokenShopItems", { Text = "Token Shop Items", Values = wA_2, Default = {}, Multi = true, AllowNull = true })
wA_24 = ow.Main:AddRightGroupbox("Place & Rewards", "plug")
wA_24:AddToggle("AutoPlacePower", { Text = "Auto Place Power", Default = false })
wA_24:AddDropdown("PlacePriority", { Text = "Place Priority", Values = { "Best", "Random", "Worst" }, Default = "Best" })
wA_24:AddDropdown("MinPlaceRarity", { Text = "Min Place Rarity", Values = nJ, Default = "Common" })
wA_24:AddDropdown("MaxPlaceRarity", { Text = "Max Place Rarity", Values = nJ, Default = "Galactic" })
wA_24:AddDropdown("PlacePowerItems", {
    Text = "Place Power Items",
    Values = wA_16,
    Default = {},
    Multi = true,
    AllowNull = true,
    Searchable = true
})
wA_24:AddButton({ Text = "Pickup Power", Func = onPickupPower })
wA_24:AddToggle("AutoClaimDailyRewards", { Text = "Auto Claim Daily Rewards", Default = false })
wA_14 = ow.Player:AddLeftGroupbox("Movement", "footprints")
wA_14:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
wA_14:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
wA_14:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
wA_14:AddToggle("NoClip", { Text = "NoClip", Default = false })
wA_14:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
wA_4 = ow.Player:AddRightGroupbox("Fly", "feather")
wA_4:AddToggle("Fly", { Text = "Fly", Default = false })
wA_4:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
wA_22 = ow.Settings:AddLeftGroupbox("Menu")
wA_22:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
wA_22:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
wA_22:AddButton({ Text = "Unload", Func = onUnload })
m3 = tick()
m1 = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local uO = v
        pcall(function()
            uO:Disable()
        end)
    end
end)
mS = fn939
connection = UserInputService.InputBegan:Connect(fns.onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
task.spawn(antiAfkLoop)
RunService.Stepped:Connect(fns.onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera2 = Workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fns.fn81)
Toggles.WalkSpeedEnabled:OnChanged(fn612)
n6 = function(it)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not it)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not it
        end
    end)
    if not it then
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
do
    Toggles.AntiGameplayPause:OnChanged(fns.fn2)
    task.spawn(antiGameplayPauseLoop)
    task.spawn(worker2)
    wA_26:SetLibrary(Library)
    wA_26:SetFolder("TempoHub")
    wA_26:SaveDefault("Monochrome")
    wA_26:ApplyToTab(ow.Settings)
    wA_26:LoadDefault()
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    SaveManager:SetFolder("TempoHub/PowerACity")
    wA_17 = SaveManager:BuildConfigSection(ow.Settings)
end
n2 = fns.fn127
nk = fns.fn32
nb = fn806
nV = function(je)
    local vZ
    vZ = nil
    local v_ = type(je) ~= "table" or type(je.idx) ~= "string" or type(je.type) ~= "string" or SaveManager.Ignore[je.idx]
    if v_ then
        return false
    end
    vZ = n2(je.type, je.idx)
    if not vZ then
        return false
    end
    local v__1 = pcall(function()
        if je.type == "Input" then
            if type(je.text) ~= "string" then
                return
            end
            vZ:SetValue(je.text)
        elseif je.type == "ColorPicker" then
            vZ:SetValueRGB(Color3.fromHex(je.value), je.transparency)
        elseif je.type == "KeyPicker" then
            vZ:SetValue({ je.key, je.mode, je.modifiers })
            if je.mode == "Toggle" and je.toggled ~= nil then
                vZ.Toggled = je.toggled
                vZ:Update()
            end
        else
            vZ:SetValue(je.value)
        end
    end)
    return v__1
end
wA_17:AddDivider()
wA_17:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
wA_17:AddButton("Export Config to Clipboard", fns.onExportConfigToClipboard)
wA_17:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
Library:OnUnload(fn643)
end)(...)

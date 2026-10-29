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
getgenv().TempoHoodSubtitle = "CLIMB WATERSLIDE AND SLIDE"
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
local Options
local ik
local SaveManager
local Toggles
local ir
local i8
local EggRoll
local CurrentCamera
local je
local AnimShop
local HttpService
local i1
local iJ
local iq
local i7
local iP
local iw
local jd
local iV
local Raft
local VirtualUser
local ip
local i6
local iO
local iv
local jc
local iU
local connection2
local i_
local iH
local io
local Trail
local UserInputService
local iu
local jb
local iT
local iA
local iZ
local iG
local im
local i4
local iM
local LocalPlayer
local Library
local iS
local iz
local connection
local iF
local il
local i3
local WorldHelper
local is
local i9
local iR
local iy
local iX
local function fn42(aB, aC, aD)
    return string.format("<b>%s</b> %s %s", aB, is("-", "#5a6070"), is(aC, aD))
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local mh_1 = jc()
        if mh_1 then
            mh_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function autoEquipPetsLoop()
    while not Library.Unloaded do
        task.wait(2)
        local lr = io()
        if lr then
            if Toggles.AutoEquipPets.Value then
                i3("Pet", "EquipBest")
            end
            if Toggles.AutoEquipTrail.Value then
                ir(lr)
            end
            if Toggles.AutoEquipRaft.Value then
                iJ(lr)
            end
            if Toggles.AutoEquipDance.Value then
                i1(lr)
            end
        end
    end
end
local function fn73()
    local nk = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local nl = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if nl then
                local nl_1 = i_(k, v)
                if nl_1 then
                    nk[#nk + 1] = nl_1
                end
            end
        end
    end
    table.sort(nk, function(fg, fh)
        if fg.type ~= fh.type then
            return fg.type < fh.type
        end
        return fg.idx < fh.idx
    end)
    return { objects = nk }
end
local function onRscripts()
    if setclipboard then
        setclipboard(je)
    elseif toclipboard then
        toclipboard(je)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function onCopySolanaAddress()
    iu(iZ, "Copied Solana address")
end
local function onCopyLitecoinAddress()
    iu(ik, "Copied Litecoin address")
end
local function fn143()
    iP(Toggles.AutoFarm.Value)
end
local function fn146(ay, az)
    return string.format('<font color="%s">%s</font>', az, ay)
end
local function fn190(e1, e2)
    local Type = e2.Type
    if Type == "Toggle" then
        return { idx = e1, type = "Toggle", value = e2.Value == true }
    elseif Type == "Slider" then
        return { idx = e1, type = "Slider", value = tostring(e2.Value) }
    elseif Type == "Dropdown" then
        return { idx = e1, type = "Dropdown", multi = e2.Multi == true, value = e2.Value }
    elseif Type == "Input" then
        local ne = e2.Value or ""
        return { idx = e1, type = "Input", text = tostring(ne) }
    elseif Type == "ColorPicker" then
        return { idx = e1, type = "ColorPicker", value = e2.Value:ToHex(), transparency = e2.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = e1,
            type = "KeyPicker",
            mode = e2.Mode,
            key = e2.Value,
            modifiers = e2.Modifiers,
            toggled = e2.Toggled
        }
    else
        return nil
    end
end
local function fn199()
    local kw_1
    local kv_1
    if identifyexecutor then
        kw_1, kv_1 = identifyexecutor()
        local kx = kw_1 ~= ""
        local ky = type(kw_1) == "string" and kx
        if ky then
            local kx_1 = type(kv_1) == "string" and kv_1 ~= "" and kw_1 .. " " .. kv_1
            iv = kx_1 or kw_1
        end
    end
end
local function fn201(ci)
    local raftData = ci.raftData
    if not raftData then
        return
    end
    local le = im(Raft.GetTable(), raftData.ownedRaftIds, function(cm)
        local la = tonumber(cm.Speed) or 0
        local lb = tonumber(cm.Stamina) or 0
        return la + lb
    end)
    if le and le ~= raftData.equipRaftId then
        i3("Raft", "EquipRaft", le)
    end
end
local function onRenderStepped(dV)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local mm_1 = jc()
        if mm_1 then
            mm_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local mm_3 = iV()
        local mn = jc()
        if mm_3 and mn then
            mn.PlatformStand = true
            local mn_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                mn_1 = mn_1 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                mn_1 = mn_1 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                mn_1 = mn_1 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                mn_1 = mn_1 + CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                mn_1 = mn_1 + Vector3.new(0, 1, 0)
            end
            local mv = if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then 1 else 0
            if mv == 1 then
                mn_1 = mn_1 - Vector3.new(0, 1, 0)
            end
            mm_3.Velocity = Vector3.zero
            if mn_1.Magnitude > 0 then
                mm_3.CFrame = mm_3.CFrame + mn_1.Unit * Options.FlySpeed.Value * dV
            end
        end
    end
end
local function onUnload()
    Library:Unload()
end
local function fn228(bZ, b_, b0)
    local Id
    local kT_1
    Id, kT_1 = nil, nil
    for k, v in pairs(bZ) do
        if i8(b_, v.Id) then
            local kV = b0(v)
            if not kT_1 or kV > kT_1 then
                kT_1 = kV
                Id = v.Id
            end
        end
    end
    return Id
end
local function fn231()
    if not Toggles.Fly.Value then
        local mw = jc()
        if mw then
            mw.PlatformStand = false
        end
    end
end
local function fn233()
    iP(false)
    iT(false)
    connection:Disconnect()
    connection2:Disconnect()
    select("#", "Unloaded!")
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local m2 = tick() - iR
            local m3 = tick() - iM
            if m2 >= 300 and m3 >= 60 then
                pcall(ip)
            else
                if m2 < 300 and m3 >= 300 then
                    pcall(ip)
                end
            end
        end
    end
end
local function onCopyBitcoinAddress()
    iu(jb, "Copied Bitcoin address")
end
local function onCopyPayPalLink()
    iu(iU, "Copied PayPal link")
end
local function fn291(F, ...)
    local j9 = iG()
    if not (j9 and j9.RE) then
        return
    end
    local ka_1 = j9.RE:Get(F)
    if ka_1 then
        ka_1:FireServer(...)
    end
end
local function fn326()
    local j6 = iG()
    if j6 and j6.PlayerData and j6.PlayerData.Get then
        return j6.PlayerData.Get()
    end
    return nil
end
local function fn332(cJ, cK, cL, cM)
    local lt = io()
    if not lt then
        return
    end
    for k, v in pairs(cJ) do
        local lu = not i8(cK, v.Id) and iw(v.WorldId, lt)
        if lu then
            local LastId = v.LastId
            local lv = LastId == nil or i8(cK, LastId)
            if lv then
                iz(cL, cM, v.Id)
            end
        end
    end
end
local function fn358(as)
    local DiscordGroup = as:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = i9 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = i9 })
end
local function fn371(ad, ae)
    local kr = type(ad) == "table" and table.find(ad, ae) ~= nil
    return kr
end
local function fn394()
    if not Toggles.WalkSpeedEnabled.Value then
        local mB = jc()
        if mB then
            mB.WalkSpeed = 16
        end
    end
end
local function fn407()
    local j3_1
    local j2_1
    j2_1, j3_1 = pcall(getrenv)
    local j4 = j2_1 and type(j3_1) == "table"
    if j4 then
        return j3_1.shared
    end
    return shared
end
local function autoBuyEggsLoop()
    while not Library.Unloaded do
        task.wait(1.5)
        if Toggles.AutoBuyEggs.Value then
            local lG = io()
            if lG then
                local lH = tonumber(lG.cash) or 0
                local lJ
                for k, v in pairs(EggRoll.GetTable()) do
                    local lH_1 = iw(v.WorldId, lG) and i6(v.Price) <= lH
                    if lH_1 then
                        local lH_2 = not lJ
                        if not lH_2 then
                            local lK = tonumber(v.Id) or 0
                            local lL = tonumber(lJ.Id) or 0
                            lH_2 = lK > lL
                        end
                        if lH_2 then
                            lJ = v
                        end
                    end
                end
                if lJ then
                    i3("Pet", "RollEggOnce", lJ.Id, 1, false)
                end
            end
        end
    end
end
local function onInputBegan()
    iR = tick()
end
local function fn431(Y, Z)
    local ko = tonumber(Y) or 1
    if ko <= 1 then
        return true
    end
    local ko_1 = Z and Z.unlockWorlds
    if type(ko_1) ~= "table" then
        return false
    end
    return table.find(ko_1, Y) ~= nil
end
local function autoBuyWorldsLoop()
    while not Library.Unloaded do
        task.wait(3)
        if Toggles.AutoBuyWorlds.Value then
            local lT = io()
            if lT then
                local lU = tonumber(lT.token) or 0
                local lW = WorldHelper.UnlockCostByWorld or {}
                local lW_1 = #WorldHelper.World
                local l0 = 2
                while l0 <= lW_1 do
                    local l1 = l0
                    if not iw(l1, lT) then
                        local lW_2 = tonumber(lW[l1])
                        if lW_2 and lU >= lW_2 then
                            i3("World", "RequestTeleportWorld", l1)
                            break
                        end
                        l0 += 1
                        continue
                    end
                    l0 += 1
                end
            end
        end
    end
end
local function onCopyJoinScript_JobID()
    local kD = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, iS)
    if setclipboard then
        setclipboard(kD)
    elseif toclipboard then
        toclipboard(kD)
    end
    Library:Notify("Copied join script to clipboard")
end
local function onCopyUSDTAddress()
    iu(i4, "Copied USDT address")
end
local function onInputChanged(eD)
    local UserInputType = eD.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        iR = tick()
    end
end
local function fn500()
    local Character = LocalPlayer.Character
    local l4 = Character and Character:FindFirstChildOfClass("Humanoid")
    return l4
end
local function fn502()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    iM = tick()
end
local function fn573()
    local Character = LocalPlayer.Character
    local l7 = Character and Character:FindFirstChild("HumanoidRootPart")
    return l7
end
local function fn611()
    iT(Toggles.AntiGameplayPause.Value)
end
local function fn620(eU, eV)
    local m7_1 = (eU == "Toggle" and Toggles or Options)[eV]
    local m6_2 = type(m7_1) == "table" and m7_1.Type == eU
    return m6_2 and m7_1 or nil
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            iT(true)
        end
    end
end
local function fn646(b9)
    local trailData = b9.trailData
    if not trailData then
        return
    end
    local k7 = im(Trail.GetTable(), trailData.owned, function(cd)
        local k3 = tonumber(cd.Speed) or 0
        local k4 = tonumber(cd.Stamina) or 0
        return k3 + k4
    end)
    if k7 and k7 ~= trailData.current then
        i3("Trail", "EquipTrail", k7)
    end
end
local function fn649(cr)
    local danceData = cr.danceData
    if not danceData then
        return
    end
    local ll = im(AnimShop.GetTable(), danceData.ownedAnimIds, function(cv)
        local lh = tonumber(cv.Speed) or 0
        local li = tonumber(cv.Luck) or 0
        return lh + li
    end)
    if ll and ll ~= danceData.equipAnimId then
        i3("Anim", "EquipAnim", ll)
    end
end
local function fn663(L, ...)
    local kc = iG()
    if not (kc and kc.RE) then
        return nil
    end
    local kd_1 = kc.RE:Get(L, true)
    if kd_1 then
        return kd_1:InvokeServer(...)
    end
    return nil
end
local function worker()
    local kG_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local kF = math.floor(os.clock() - iq)
        if kF < 60 then
            kG_1 = kF .. "s"
        elseif kF < 3600 then
            kG_1 = string.format("%dm %ds", math.floor((kF) / (60)), kF % 60)
        else
            kG_1 = string.format("%dh %dm", math.floor((kF) / (3600)), math.floor((kF % 3600) / (60)))
        end
        iX:SetText(jd("Session time", kG_1, iF))
    end
end
local function fn742(R)
    local kg_1
    local kh_1
    if type(R) == "number" then
        return R
    end
    local kf = tostring(R):gsub("%s", "")
    kh_1, kg_1 = kf:match("^([%d%.]+)([kmbtKMBT]?)$")
    local ki = tonumber(kh_1) or tonumber(kf)
    local kh_2 = ki or 0
    local kf_2 = { k = 1000, m = 1000000, b = 1000000000, t = 1000000000000 }
    if kg_1 and kg_1 ~= "" then
        local ki_2 = kf_2[kg_1:lower()] or 1
        kh_2 = kh_2 * ki_2
    end
    return kh_2
end
local function autoSpinLoop()
    while not Library.Unloaded do
        task.wait(1.5)
        if Toggles.AutoSpin.Value then
            local kQ = io()
            local kR = kQ and kQ.spinData
            if kR then
                local kR_1 = tonumber(kR.opSpinCount) or 0
                if kR_1 > 0 then
                    i3("Spin", "PlayerOpSpin")
                else
                    local kR_2 = tonumber(kR.spinCount) or 0
                    if kR_2 > 0 then
                        i3("Spin", "PlayerSpin")
                    end
                end
            end
        end
    end
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local l9_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if l9_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function onCopyEthereumAddress()
    iu(i7, "Copied Ethereum address")
end
local function onImportConfigFromClipboardTex()
    local nQ_1
    local nO = Options.SaveManager_ImportSource.Value or ""
    local nO_1
    local nP = tostring(nO):match("^%s*(.-)%s*$")
    if nP == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    nO_1, nQ_1 = pcall(HttpService.JSONDecode, HttpService, nP)
    local nP_1 = not nO_1 or type(nQ_1) ~= "table" or type(nQ_1.objects) ~= "table"
    if nP_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local nO_2 = 0
    for i, v in ipairs(nQ_1.objects) do
        if iy(v) then
            nO_2 += 1
        end
    end
    if nO_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local nQ_2 = nO_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(nO_2, nQ_2), 6)
end
local function onExportConfigToClipboard()
    local nL_1
    local nK_1
    nK_1, nL_1 = pcall(HttpService.JSONEncode, HttpService, iH())
    if not nK_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local nK_2 = setclipboard or toclipboard
    local nK_3 = type(nK_2) ~= "function" or not pcall(nK_2, nL_1)
    if nK_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function autoFarmLoop()
    while not Library.Unloaded do
        task.wait(3)
        if Toggles.AutoFarm.Value then
            iP(true)
        end
    end
end
local function autoBuyTrailLoop()
    while not Library.Unloaded do
        task.wait(2)
        local lD = io()
        if lD then
            if Toggles.AutoBuyTrail.Value and lD.trailData then
                iA(Trail.GetTable(), lD.trailData.owned, "TrailF", "BuyTrail")
            end
            if Toggles.AutoBuyRaft.Value and lD.raftData then
                iA(Raft.GetTable(), lD.raftData.ownedRaftIds, "RaftF", "BuyRaft")
            end
            if Toggles.AutoBuyDance.Value and lD.danceData then
                iA(AnimShop.GetTable(), lD.danceData.ownedAnimIds, "AnimF", "BuyAnim")
            end
        end
    end
end
local function onCopyVenmoLink()
    iu(iO, "Copied Venmo link")
end
local function fn844(al, am)
    if setclipboard then
        setclipboard(al)
    elseif toclipboard then
        toclipboard(al)
    end
    Library:Notify(am)
end
local function fn871(bG)
    local kM = iG()
    if kM and kM.Ctrl and kM.Ctrl.AutoSlide and kM.Ctrl.AutoSlide.SetEnabled then
        kM.Ctrl.AutoSlide.SetEnabled(bG)
    end
end
local function fn878()
    iu(il, "Copied Discord invite to clipboard")
end
ik = nil
il = nil
im = nil
io = nil
ip = nil
iq = nil
ir = nil
is = nil
LocalPlayer = nil
iu = nil
iv = nil
iw = nil
CurrentCamera = nil
iy = nil
iz = nil
iA = nil
connection2 = nil
HttpService = nil
Options = nil
iF = nil
iG = nil
iH = nil
VirtualUser = nil
iJ = nil
Toggles = nil
WorldHelper = nil
iM = nil
UserInputService = nil
iO = nil
iP = nil
EggRoll = nil
iR = nil
iS = nil
iT = nil
iU = nil
iV = nil
AnimShop = nil
iX = nil
connection = nil
iZ = nil
i_ = nil
Raft = nil
i1 = nil
SaveManager = nil
i3 = nil
i4 = nil
Trail = nil
i6 = nil
i7 = nil
local iC
i8 = nil
i9 = nil
Library = nil
jb = nil
jc = nil
jd = nil
je = nil
local ScriptsGroup, FarmGroup, MenuGroup
local jD_1
local jC_1
local jq_1
local jr_7
Library, SaveManager, UserInputService, VirtualUser, HttpService, LocalPlayer, il, je, Trail, Raft, AnimShop, EggRoll, WorldHelper, Toggles, Options, iG, io, i3, iz, i6, iw, i8, iu, i9 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
local jj = game:GetService("Players")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
local jh = game:GetService("ReplicatedStorage")
LocalPlayer = jj.LocalPlayer
local jm = "Climb Waterslide and Slide"
il = "https://discord.gg/K7Qxnxkk46"
je = "https://discord.gg/K7Qxnxkk46"
local jk = jh:WaitForChild("ConfigData")
Trail = require(jk.Trail)
Raft = require(jk.Raft)
AnimShop = require(jk.AnimShop)
EggRoll = require(jk.EggRoll)
WorldHelper = require(jk.WorldHelper)
iG = fn407
io = fn326
i3 = fn291
iz = fn663
i6 = fn742
iw = fn431
i8 = fn371
local ji = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = il, Copyable = true }, "|", jm },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
Toggles = Library.Toggles
Options = Library.Options
local jn = {
    Info = ji:AddTab("Info", "info"),
    Main = ji:AddTab("Main", "gamepad-2"),
    Shop = ji:AddTab("Shop", "shopping-cart"),
    Player = ji:AddTab("Player", "person-standing"),
    Settings = ji:AddTab("Settings", "settings")
}
iu = fn844
i9 = fn878
local jl_2
for k, v in pairs(jn) do
    if v ~= jn.Info then
        fn358(v)
    end
end
jk, jj, iF, ji, iv, jq_1, iX, iS, jh, is, jd = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local jf = 4
repeat
    local jl_1 = (jf * 4 + 1) % 9 + 1
    if jl_1 <= 5 then
        if jl_1 <= 3 then
            if jl_1 <= 2 then
                if jl_1 <= 1 then
                    local jr_1 = {
                        "yatwe",
                        "skgtxmhc",
                        "vpav",
                        "genmga",
                        "kibgwtsoju",
                        "gdn",
                        "usk",
                        "fnnrpos",
                        "iwqdgoqivqj",
                        "gifczifw"
                    }
                    local oR = jf
                    local js_1 = jr_1[oR % 10 + 1]
                    if js_1:len() >= js_1:gsub("(.)", "%1%1", oR % 3 % 2 + 1):len() then
                        jk = fn42
                    else
                        jd = fn42
                    end
                    jf = (jf + 34) % 36
                else
                    local jr_2 = (vector.create((jf * 2 + 9) % 11 + 1, (jf * 2 + 12) % 13 + 1, (jf * 14 + 3) % 17 + 1))
                    local js_2 = (vector.create((jf * 1 + 6) % 11 + 1, (jf * 10 + 4) % 13 + 1, (jf * 6 + 5) % 17 + 1))
                    local jt_1 = (vector.create((jf * 2 + 6) % 11 + 1, (jf * 4 + 9) % 13 + 1, (jf * 4 + 12) % 17 + 1))
                    local ju_1 = (vector.create((jf * 5 + 6) % 5 + 1, (jf * 1 + 2) % 7 + 1, (jf * 4 + 6) % 9 + 1))
                    if vector.dot(vector.cross(jr_2, (vector.cross(js_2, jt_1))), ju_1) == vector.dot(js_2 * vector.dot(jr_2, jt_1) - jt_1 * vector.dot(jr_2, js_2), ju_1) + 5 then
                    else
                        jk = "#7fd47f"
                    end
                    jf = (jf + 25) % 36
                end
            else
                local jr_3 = { "kdcmkx", "gpcddq", "epvlnalfir", "grwmdiw", "qpufhdoxi", "hpyidenv", "mpne", "awpj" }
                if jr_3[(jf * 15 + 18) % 8 + 1] <= jr_3[(jf * 15 + 18) % 8 + 1] then
                    jj = "#6ec1ff"
                else
                    jq_1 = "#6ec1ff"
                end
                jf = (jf + 16) % 36
            end
        elseif jl_1 <= 4 then
            local jr_4 = {
                "bbxrnhrdyny",
                "tqoac",
                "hilzh",
                "pwoi",
                "zajcdp",
                "xhd",
                "bczfpuy",
                "nopvzzmxp",
                "mhymeyf",
                "benjkkrub",
                "oldhnjfhdgbr",
                "zgmrhy",
                "zhb",
                "iyqqx",
                "kdvmz"
            }
            if jr_4[(jf * 45 + 29) % 15 + 1] <= jr_4[(jf * 45 + 29) % 15 + 1] then
                iF = "#e8a34d"
            else
                iX = "#e8a34d"
            end
            jf = (jf + 7) % 36
        else
            local jr_5 = {
                "wuljicl",
                "vakghkbv",
                "jashz",
                "uxkgg",
                "lyrioe",
                "phopqjbqvuhm",
                "ioylyvx",
                "zjzamgs",
                "rhjfbxplfk",
                "bws",
                "nziinj",
                "mdyf",
                "hulqn",
                "tiybodititpt",
                "rnij",
                "tiskkwxnv"
            }
            if jr_5[(jf * 81 + 24) % 16 + 1] <= jr_5[(jf * 81 + 24) % 16 + 1] then
                ji = "#8b93a3"
            else
                jk = "#8b93a3"
            end
            jf = (jf + 25) % 36
        end
    elseif jl_1 <= 7 then
        if jl_1 <= 6 then
            local jr_6 = { "fvv", "djso", "wlcsfbwks", "bqvtqzh", "vyoybkytsv", "rbch", "tsdmmvvwe", "esmcjodysth" }
            if jr_6[(jf * 72 + 69) % 8 + 1] < jr_6[(jf * 72 + 69) % 8 + 1] then
                pcall(fn199)
                jn = jd.Info:AddLeftGroupbox("Account", "circle-user")
                jn:AddLabel(LocalPlayer("User", nil, iX), true)
                jn:AddLabel(LocalPlayer("Status", "Keyless", iX), true)
                jn:AddLabel(LocalPlayer("Executor", "Unknown", iX), true)
                jk = jd.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                jk:AddLabel(iv(is .. " [" .. tostring(game.PlaceId) .. "]", jq_1), true)
                jk:AddLabel(LocalPlayer("Place ID", tostring(game.PlaceId), jq_1), true)
                iF = jk:AddLabel(LocalPlayer("Session time", "0s", jj), true)
            else
                iv = "Unknown"
                pcall(fn199)
                local AccountGroup = jn.Info:AddLeftGroupbox("Account", "circle-user")
                AccountGroup:AddLabel(jd("User", LocalPlayer.Name, jk), true)
                AccountGroup:AddLabel(jd("Status", "Keyless", jk), true)
                AccountGroup:AddLabel(jd("Executor", iv, jk), true)
                jq_1 = jn.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                jq_1:AddLabel(is(jm .. " [" .. tostring(game.PlaceId) .. "]", jj), true)
                jq_1:AddLabel(jd("Place ID", tostring(game.PlaceId), jj), true)
                iX = jq_1:AddLabel(jd("Session time", "0s", iF), true)
            end
            jf = (jf + 7) % 36
        else
            if (jf * 3 + 7) * 17 % 4 == ((jf * 3 + 7) * 17 + 4) % 4 then
                iS = tostring(game.JobId)
            end
            jf = (jf + 25) % 36
        end
    elseif jl_1 <= 8 then
        if jf * 131092273 + 5 + 2 <= jf * 131092273 + 5 + 2 + 5 then
            jh = #iS > 18
        else
            iS = #jh > 18
        end
        jf = (jf + 34) % 36
    else
        if jf * 35648567 + 5 + 2 >= jf * 35648567 + 5 + 2 + 3 then
            jq_1 = fn146
        else
            is = fn146
        end
        jf = (jf + 34) % 36
    end
until (jf * 17 + 6) % 36 == 29
if jh then
    jf = 1
    repeat
        local jg_2 = { "tcb", "hgyqlo", "bsffdvdsjh", "lcnj", "eshjvl", "okppaeuk", "gepyjuwajnol", "pcaa", "nckzz" }
        if jg_2[(jf * 54 + 53) % 9 + 1] < jg_2[(jf * 54 + 53) % 9 + 1] then
            iS = string.sub(jh, 1, 18) .. "..."
        else
            jh = string.sub(iS, 1, 18) .. "..."
        end
        jf = (jf + 5) % 8
    until (jf * 7 + 0) % 8 == 2
end
jf = jh or iS
jC_1, iq, ScriptsGroup, jl_2, ik, jb, i7, i4, iZ, iU, iO, jD_1, FarmGroup, jr_7, CurrentCamera, MenuGroup, iR, iM, connection, connection2, iP, im, ir, iJ, i1, iA, jc, iV, iT, ip, iC, i_, iH, iy = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if (not jl_2 and false and (not ScriptsGroup and not connection) and ((not FarmGroup or ScriptsGroup) and (not FarmGroup and connection)) or (not iq and not ScriptsGroup or not jl_2 and FarmGroup or (not iq or iq) and (iq and not connection))) and ((iT or ScriptsGroup) and (not ScriptsGroup and jl_2) and ((connection or not iq) and (ScriptsGroup or ScriptsGroup)) or (jl_2 and jl_2 and (FarmGroup or iT) or (not jl_2 or not iq or (not jl_2 or not FarmGroup)))) or not ((not jl_2 and false and (not ScriptsGroup and not connection) and ((not FarmGroup or ScriptsGroup) and (not FarmGroup and connection)) or (not iq and not ScriptsGroup or not jl_2 and FarmGroup or (not iq or iq) and (iq and not connection))) and ((iT or ScriptsGroup) and (not ScriptsGroup and jl_2) and ((connection or not iq) and (ScriptsGroup or ScriptsGroup)) or (jl_2 and jl_2 and (FarmGroup or iT) or (not jl_2 or not iq or (not jl_2 or not FarmGroup))))) then
    local jC_2 = jf
    jq_1:AddLabel(jd("Server", jC_2, ji), true)
    jq_1:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
    iq = os.clock()
else
    jd:AddLabel(iq("Server", jC_1, jf), true)
    jd:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
    ji = os.clock()
end
task.spawn(worker)
ScriptsGroup = jn.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(is("Included in this hub", ji), true)
ScriptsGroup:AddLabel(is(jm, jj), true)
local FeaturesGroup = jn.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(is("Auto Climb / Slide / Wins", jj), true)
FeaturesGroup:AddLabel(is("Auto Buy Best Gear", iF), true)
FeaturesGroup:AddLabel(is("Auto Equip Best", jk), true)
FeaturesGroup:AddLabel(is("Auto Spin & Buy Worlds", ji), true)
local SocialsGroup = jn.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = i9 })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = jn.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = i9 })
ik = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
jb = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
i7 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
i4 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
iZ = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
iU = ""
iO = ""
if not jr_7 and MenuGroup and (MenuGroup and not iP) and (not FeaturesGroup or false or (not jr_7 or iU)) and not (not jr_7 and MenuGroup and (MenuGroup and not iP) and (not FeaturesGroup or false or (not jr_7 or iU))) then
else
    jD_1 = "#345d9d"
end
local jy = "#f7931a"
local jw = "#627eea"
local jv = "#26a17b"
local ju_2 = "#14f195"
jh = "#0070ba"
local DonationsGroup = jn.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(is("All donations are optional but appreciated.", iF), true)
DonationsGroup:AddLabel(is("If you donate you get a special role, just PING after you donate.", jk), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(is("LTC / Litecoin", jD_1), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(is("BTC / Bitcoin", jy), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(is("ETH / Ethereum", jw), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(is("USDT", jv), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(is("Solana", ju_2), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(is("PayPal", jh), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(is("Venmo", "#008cff"), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(is("Don't have any of the listed currencies but still wanna donate?", ji), true)
DonationsGroup:AddLabel(is("DM me and we'll work something out.", jj), true)
local FaqGroup = jn.Info:AddRightGroupbox("FAQ", "circle-help")
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
FarmGroup = jn.Main:AddLeftGroupbox("Farm", "gauge")
FarmGroup:AddToggle("AutoFarm", { Text = "Auto Climb + Slide + Win", Default = false })
iP = fn871
Toggles.AutoFarm:OnChanged(fn143)
task.spawn(autoFarmLoop)
local SpinGroup = jn.Main:AddRightGroupbox("Spin", "dices")
SpinGroup:AddToggle("AutoSpin", { Text = "Auto Spin Wheel", Default = false })
task.spawn(autoSpinLoop)
local AutoEquipBestGroup = jn.Main:AddLeftGroupbox("Auto Equip Best", "shirt")
AutoEquipBestGroup:AddToggle("AutoEquipPets", { Text = "Auto Equip Best Pets", Default = false })
AutoEquipBestGroup:AddToggle("AutoEquipTrail", { Text = "Auto Equip Best Trail", Default = false })
AutoEquipBestGroup:AddToggle("AutoEquipRaft", { Text = "Auto Equip Best Raft", Default = false })
AutoEquipBestGroup:AddToggle("AutoEquipDance", { Text = "Auto Equip Best Dance", Default = false })
im = fn228
ir = fn646
if (connection or false) and (connection and connection) and (connection or 134 or (not connection)) or not ((connection or false) and (connection and connection) and (connection or 134 or (not connection))) then
    iJ = fn201
else
    i_ = fn201
end
i1 = fn649
task.spawn(autoEquipPetsLoop)
local AutoBuyBestGroup = jn.Shop:AddLeftGroupbox("Auto Buy Best", "badge-dollar-sign")
AutoBuyBestGroup:AddToggle("AutoBuyTrail", { Text = "Auto Buy Best Trails", Default = false })
AutoBuyBestGroup:AddToggle("AutoBuyRaft", { Text = "Auto Buy Best Rafts", Default = false })
AutoBuyBestGroup:AddToggle("AutoBuyDance", { Text = "Auto Buy Best Dances", Default = false })
AutoBuyBestGroup:AddToggle("AutoBuyEggs", { Text = "Auto Buy Best Eggs", Default = false })
iA = fn332
task.spawn(autoBuyTrailLoop)
task.spawn(autoBuyEggsLoop)
local WorldsGroup = jn.Shop:AddRightGroupbox("Worlds", "globe")
WorldsGroup:AddToggle("AutoBuyWorlds", { Text = "Auto Buy Worlds", Default = false })
task.spawn(autoBuyWorldsLoop)
jn.Player = jn.Player
local MovementGroup = jn.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = jn.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
jc = fn500
iV = fn573
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn231)
Toggles.WalkSpeedEnabled:OnChanged(fn394)
iT = function(ef)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not ef)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not ef
        end
    end)
    if not ef then
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
Toggles.AntiGameplayPause:OnChanged(fn611)
task.spawn(antiGameplayPauseLoop)
MenuGroup = jn.Settings:AddLeftGroupbox("Menu", "menu")
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
iR = tick()
iM = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local mU = v
        pcall(function()
            mU:Disable()
        end)
    end
end)
ip = fn502
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
task.spawn(antiAfkLoop)
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Linoria")
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/ClimbWaterslideAndSlide")
ThemeManager:ApplyToTab(jn.Settings)
local jB = SaveManager:BuildConfigSection(jn.Settings)
iC = fn620
i_ = fn190
iH = fn73
iy = function(fj)
    local nE
    nE = nil
    local nF = type(fj) ~= "table" or type(fj.idx) ~= "string"
    local nJ = if nF then 1 else 0
    local nH = 2021 * nJ + 61 * (1 - nJ)
    local nI = 861 * nJ + 2477 * (1 - nJ)
    if not ((nH * 4077 + nI * 2798 + nH * nI) % 16777213 == 12388776) then
        nF = type(fj.type) ~= "string"
    end
    if not nF then
        nF = SaveManager.Ignore[fj.idx]
    end
    if nF then
        return false
    end
    nE = iC(fj.type, fj.idx)
    if not nE then
        return false
    end
    local nF_1 = pcall(function()
        if fj.type == "Input" then
            if type(fj.text) ~= "string" then
                return
            end
            nE:SetValue(fj.text)
        elseif fj.type == "ColorPicker" then
            nE:SetValueRGB(Color3.fromHex(fj.value), fj.transparency)
        elseif fj.type == "KeyPicker" then
            nE:SetValue({ fj.key, fj.mode, fj.modifiers })
            if fj.mode == "Toggle" and fj.toggled ~= nil then
                nE.Toggled = fj.toggled
                nE:Update()
            end
        else
            nE:SetValue(fj.value)
        end
    end)
    return nF_1
end
jB:AddDivider()
jB:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
jB:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
jB:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
ThemeManager:LoadDefault()
Library:OnUnload(fn233)
end)(...)

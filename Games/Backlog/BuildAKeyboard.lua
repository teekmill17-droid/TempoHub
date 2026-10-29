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
getgenv().TempoHoodSubtitle = "BUILD A KEYBOARD"
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
local fI
local fm
local WorkerConfiguration
local fL
local UpgradesConfiguration
local fO
local fv
local fR
local Options
local fU
local NetworkShared
local fE
local connection
local fo
local fN
local fr
local fu
local fx
local fT
local fA
local fG
local RebirthConfiguration
local fJ
local fM
local ft
local fP
local fw
local Library
local Toggles
local fF
local function fn62()
    local gA = fx(NetworkShared.RequestItemShopState)
    local gB = gA and gA.Success and type(gA.Items) == "table"
    if gB then
        fM = gA
    end
    return fM
end
local function fn76()
    local gZ = fT()
    if not gZ then
        return nil
    end
    local Utils = gZ:FindFirstChild("Utils")
    local gZ_1 = Utils and Utils:FindFirstChild("Roll")
    local g__1 = gZ_1
    if gZ_1 then
        gZ_1 = g__1:FindFirstChild("RollKeycapsMain")
    end
    local g__2 = gZ_1
    if gZ_1 then
        gZ_1 = g__2:FindFirstChild("RollkeyBase")
    end
    local g__3 = gZ_1
    if gZ_1 then
        gZ_1 = g__3:FindFirstChild("Rollkey")
    end
    return gZ_1
end
local function fn86(b3)
    b3:AddLeftGroupbox("Discord"):AddButton({ Text = "Join Discord For Dupe", Func = fv })
end
local function fn107()
    return fO() - fU(Options.MoneyReserve)
end
local function worker()
    while not Library.Unloaded do
        fP()
        task.wait(1)
    end
end
local function fn133()
    if setclipboard then
        setclipboard(fw)
    elseif toclipboard then
        toclipboard(fw)
    end
    Library:Notify("Copied Discord invite to clipboard")
end
local function fn156()
    local gW = fT()
    if not gW then
        return nil
    end
    local Utils = gW:FindFirstChild("Utils")
    local gW_1 = Utils and Utils:FindFirstChild("Keyboard")
    local gX_1 = gW_1
    if gW_1 then
        gW_1 = gX_1:FindFirstChild("Keyboard")
    end
    local gX_2 = gW_1
    if gW_1 then
        gW_1 = gX_2:FindFirstChild("Utils")
    end
    local gX_3 = gW_1
    if gW_1 then
        gW_1 = gX_3:FindFirstChild("Keycap")
    end
    return gW_1
end
local function fn160()
    Library.ScreenGui.Parent = fI:WaitForChild("PlayerGui")
end
local function fn165()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    select("#", "Build a Keyboard unloaded")
end
local function fn169()
    local Slots = workspace:FindFirstChild("Slots")
    if not Slots then
        return nil
    end
    for i, child in ipairs(Slots:GetChildren()) do
        if tostring(child:GetAttribute("OwnerUserId")) == tostring(fI.UserId) then
            return child:FindFirstChild("BasePlayer")
        end
    end
    return nil
end
local function fn185(bc)
    local hp = UpgradesConfiguration.GetUpgrade(bc)
    if not hp then
        return false
    end
    local hq = fo(bc)
    if hq >= hp.MaxLevel then
        return false
    end
    local GetRequiredRebirthForNextLevel = UpgradesConfiguration.GetRequiredRebirthForNextLevel
    local hr = (tonumber(fR.Rebirth))
    local hx = if hr then 1 else 0
    local hv = 3719 * hx + 1921 * (1 - hx)
    local hw = 3562 * hx + 2725 * (1 - hx)
    if not ((hv * 2756 + hw * 2344 + hv * hw) % 16777213 == 15068757) then
        hr = 0
    end
    if GetRequiredRebirthForNextLevel(bc, hq, hr) then
        return false
    end
    local hp_2 = UpgradesConfiguration.GetPrice(bc, hq)
    if hp_2 > fE() then
        return false
    end
    local hr_1 = fx(NetworkShared.RequestUpgradePurchase, { upgradeId = bc })
    if hr_1 and hr_1.ok then
        local hs_1 = fO()
        local ht = tonumber(hr_1.price) or hp_2
        fR.Money = hs_1 - ht
        local Upgrades = fR.Upgrades
        local hs_2 = (tonumber(hr_1.level))
        local hA = if hs_2 then 1 else 0
        local hy = 2818 * hA + 2118 * (1 - hA)
        local hz = 2738 * hA + 1264 * (1 - hA)
        if not ((hy * 2523 + hz * 3370 + hy * hz) % 16777213 == 7275345) then
            hs_2 = hq + 1
        end
        Upgrades[bc] = hs_2
        return true
    end
    return false
end
local function autoUpgradeWorkersLoop()
    while not Library.Unloaded do
        if fR then
            for i, v in ipairs(fm) do
                if Toggles[v.Toggle].Value then
                    while fN(v.Id) do
                        task.wait(0.1)
                    end
                end
            end
            if Toggles.AutoUpgradeWorkers.Value then
                fF()
            end
        end
        task.wait(fU(Options.UpgradeDelay))
    end
end
local function autoBuySoundsLoop()
    while not Library.Unloaded do
        if Toggles.AutoBuySounds.Value or Toggles.AutoBuySkins.Value then
            fA()
            if Toggles.AutoBuySounds.Value then
                fu("Sound")
            end
            if Toggles.AutoBuySkins.Value then
                fu("Keyboard")
            end
        end
        task.wait(fU(Options.ShopDelay))
    end
end
local function onUnload()
    Library:Unload()
end
local function fn253()
    if not fR then
        return {}
    end
    local Keyboard = fR.Keyboard
    local g5 = Keyboard and Keyboard.Discovered
    if type(g5) ~= "table" then
        return {}
    end
    local g5_1 = {}
    for k, v in pairs(g5) do
        if v then
            local g4_2 = tonumber(k)
            if g4_2 then
                g5_1[#g5_1 + 1] = g4_2
            end
        end
    end
    table.sort(g5_1)
    return g5_1
end
local function fn257(a8)
    local hn = not fR or type(fR.Upgrades) ~= "table"
    if hn then
        return 0
    end
    local hn_1 = tonumber(fR.Upgrades[a8]) or 0
    return hn_1
end
local function fn259()
    local hZ = not fR or type(fR.Roll) ~= "table"
    if hZ then
        return
    end
    local PendingResults = fR.Roll.PendingResults
    local h_ = type(PendingResults) == "table" and PendingResults.Rolls
    if type(h_) ~= "table" then
        return
    end
    local h__1 = fU(Options.MaxRollPrice)
    for k, v in pairs(h_) do
        local hZ_3 = type(v) == "table" and v.Results
        if type(hZ_3) == "table" then
            for k2, v2 in pairs(hZ_3) do
                local hZ_4 = tonumber(v2.Price) or 0
                local hZ_5 = not v2.Claimed
                if hZ_5 ~= false then
                    hZ_5 = fG[v2.Rarity]
                end
                if hZ_5 then
                    hZ_5 = h__1 <= 0 or hZ_4 <= h__1
                end
                if hZ_5 then
                    hZ_5 = hZ_4 <= fE()
                end
                if hZ_5 then
                    local RequestClaimRollSkin = NetworkShared.RequestClaimRollSkin
                    local h1_2 = v.RollId or k
                    local h2 = fx(RequestClaimRollSkin, { rollId = h1_2, slot = tonumber(k2) })
                    if h2 and h2.ok then
                        fR.Money = fO() - hZ_4
                    end
                end
            end
        end
    end
end
local function fn273()
    local gF = fR and tonumber(fR.Money)
    return gF or 0
end
local function autoRebirthLoop()
    while not Library.Unloaded do
        if Toggles.AutoRebirth.Value and fR then
            local iU_1 = tonumber(fR.Rebirth) or 0
            if iU_1 < RebirthConfiguration.MaxRebirth then
                if fO() >= RebirthConfiguration.GetCostForRebirth(iU_1) then
                    local iU_2 = fx(NetworkShared.RequestRebirth)
                    if iU_2 and iU_2.ok then
                        fP()
                    end
                end
            end
        end
        task.wait(fU(Options.RebirthDelay))
    end
end
local function fn326()
    local hB = not fR or type(fR.Workers) ~= "table"
    if hB then
        return
    end
    local hB_1 = tonumber(fR.Workers.Count) or 0
    local Upgrades = fR.Workers.Upgrades
    local hD = hB_1 <= 0
    local hJ = if hD then 1 else 0
    local hH = 1623 * hJ + 1825 * (1 - hJ)
    local hI = 1506 * hJ + 2367 * (1 - hJ)
    if not ((hH * 1273 + hI * 2307 + hH * hI) % 16777213 == 7984659) then
        hD = type(Upgrades) ~= "table"
    end
    if hD then
        return
    end
    local hM = 1
    while hM <= hB_1 do
        local hN = hM
        local hC_1 = WorkerConfiguration.GetEfficiencyLevel(Upgrades, hN)
        if hC_1 < WorkerConfiguration.EfficiencyUpgrade.MaxLevel then
            local hD_1 = WorkerConfiguration.GetEfficiencyPrice(hC_1)
            if hD_1 <= fE() then
                local hE = fx(NetworkShared.RequestWorkerUpgradePurchase, { workerIndex = hN })
                if not (hE and hE.ok) then
                    return
                end
                fR.Money = fO() - hD_1
                local hD_2 = tonumber(hE.level) or hC_1 + 1
                Upgrades[hN] = hD_2
            end
        end
        hM += 1
    end
end
local function autoEquipBestLoop()
    while not Library.Unloaded do
        if Toggles.AutoEquipBest.Value then
            fx(NetworkShared.RequestEquipBest)
        end
        task.wait(fU(Options.EquipDelay))
    end
end
local function fn355()
    local Character = fI.Character
    local gJ = Character and Character:FindFirstChild("HumanoidRootPart")
    return gJ
end
local function onBuyRarities(b9)
    fG = {}
    for k, v in pairs(b9) do
        if v then
            fG[k] = true
        end
    end
end
local function fn381(aa)
    local gD = tonumber(aa.Value) or 0
    return gD
end
local function fn405(aW)
    if aW:IsA("BasePart") then
        return aW.Position
    end
    local hg = if aW:IsA("Model") then 1 else 0
    if hg == 1 then
        return aW:GetPivot().Position
    end
    return nil
end
local function fn406(a4)
    while fJ do
        if Library.Unloaded then
            return
        end
        task.wait()
    end
    fJ = true
    pcall(a4)
    fJ = false
end
local function onAntiAfk(ck)
    if ck then
        if not connection then
            connection = fI.Idled:Connect(function()
                fL:CaptureController()
                fL:ClickButton2(Vector2.new())
            end)
        end
    elseif connection then
        connection:Disconnect()
        connection = nil
    end
end
local function fn410()
    local gy = fx(NetworkShared.GetPlayerData)
    if gy then
        fR = gy
    end
    return fR
end
local function fn417(aY)
    local hh = ft()
    local hi = aY and fr(aY)
    if not hh or not hi then
        return false
    end
    hh.CFrame = CFrame.new(hi + Vector3.new(0, 3.2, 0))
    return true
end
local function fn488(bD)
    if not fM then
        return
    end
    for k, v in pairs(fM.Items) do
        local hP = v.Category == bD and not v.Owned and not v.StockDisabled
        if hP then
            local hQ_1 = tonumber(v.Stock) or 0
            hP = hQ_1 > 0
        end
        if hP then
            local hQ_2 = tonumber(v.Price) or 0
            hP = hQ_2 > 0
        end
        if hP then
            local hQ_3 = tonumber(v.Price) or 0
            hP = hQ_3 <= fE()
        end
        if hP then
            local hP_1 = fx(NetworkShared.RequestItemShopPurchase, { ItemId = v.Id, Currency = "Money" })
            if hP_1 and hP_1.Success then
                local hQ_5 = fO()
                local hR = tonumber(v.Price) or 0
                fR.Money = hQ_5 - hR
            end
            local hQ_6 = hP_1 and type(hP_1.State) == "table" and hP_1.State.Success
            if hQ_6 then
                fM = hP_1.State
            end
        end
    end
end
fm = nil
RebirthConfiguration = nil
fo = nil
WorkerConfiguration = nil
fr = nil
UpgradesConfiguration = nil
ft = nil
fu = nil
fv = nil
fw = nil
fx = nil
Options = nil
fA = nil
NetworkShared = nil
Toggles = nil
fE = nil
fF = nil
fG = nil
connection = nil
fI = nil
fJ = nil
fL = nil
fM = nil
fN = nil
fO = nil
fP = nil
fR = nil
Library = nil
fT = nil
fU = nil
local fq, fz, fD, fK, fQ, fV
local ItemShopGroup
local fZ_2
fL, fI = nil, nil
local fX = 3
repeat
    local f__1 = {
        "igjujqqzjxfy",
        "ijuob",
        "twbymhnhig",
        "heiuquxypq",
        "nmvqkrypm",
        "hwzyzq",
        "ezsiattv",
        "usbn",
        "cmflvf",
        "aolagqvja",
        "zeapxj"
    }
    if f__1[(fX * 52 + 40) % 11 + 1] <= f__1[(fX * 52 + 40) % 11 + 1] then
        local Players = game:GetService("Players")
        fZ_2 = game:GetService("ReplicatedStorage")
        game:GetService("ReplicatedFirst")
        fL = game:GetService("VirtualUser")
        fI = Players.LocalPlayer
    else
        fZ_2 = game:GetService("Players")
        fL = game:GetService("ReplicatedStorage")
        fI = game:GetService("ReplicatedFirst")
        game:GetService("VirtualUser")
    end
    fX = (fX + 1) % 4
until (fX * 3 + 0) % 4 == 0
if getgenv then
    getgenv().gethui = function()
        return fI:WaitForChild("PlayerGui")
    end
end
NetworkShared, UpgradesConfiguration, WorkerConfiguration, RebirthConfiguration, Library, Toggles, Options, fw, fm, fR, fM, fJ, fG, fv = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Shared = fZ_2:WaitForChild("Shared")
NetworkShared = require(Shared:WaitForChild("Remotes"):WaitForChild("NetworkShared"))
local Configurations = fZ_2:WaitForChild("Configurations")
local Gameplay = Configurations:WaitForChild("Gameplay")
UpgradesConfiguration = require(Gameplay:WaitForChild("UpgradesConfiguration"))
WorkerConfiguration = require(Gameplay:WaitForChild("WorkerConfiguration"))
RebirthConfiguration = require(Gameplay:WaitForChild("RebirthConfiguration"))
Library = getgenv().Library
pcall(fn160)
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
fw = "https://discord.gg/K7Qxnxkk46"
fv = fn133
fm = {
    { Toggle = "AutoSpawnRate", Id = "SpawnRate" },
    { Toggle = "AutoMoneyMultiplier", Id = "MoneyMultiplier" },
    { Toggle = "AutoKeycapLuck", Id = "UpgradeKeycapLuck" },
    { Toggle = "AutoRollLuck", Id = "LuckMultiplier" },
    { Toggle = "AutoKeycapRolls", Id = "KeycapRolls" },
    { Toggle = "AutoRollSpeed", Id = "RollSpeed" },
    { Toggle = "AutoBuyKeycap", Id = "+1Keycap" },
    { Toggle = "AutoBuyWorker", Id = "+1Worker" }
}
local RarityOrder = require(Gameplay:WaitForChild("KeycapSkinsConfiguration")).RarityOrder
fR = nil
fM = nil
fJ = false
fG = {}
for i, v in ipairs(RarityOrder) do
    fG[v] = true
end
fx, fP, fA, fU, fO, fE, ft, fT, fD, fK, fQ, fr, fV, fz, fo, fN, fF, fu, fq = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
fx = function(I, J)
    local gw_1
    local gv_1
    gv_1, gw_1 = pcall(function()
        return I:Invoke(J):expect()
    end)
    if not gv_1 then
        return nil
    end
    return gw_1
end
fP = fn410
fA = fn62
fU = fn381
fO = fn273
fE = fn107
ft = fn355
fT = fn169
fD = fn156
fK = fn76
fQ = fn253
fr = fn405
fV = fn417
fz = fn406
fo = fn257
fN = fn185
fF = fn326
fu = fn488
fq = fn259
local Window = Library:CreateWindow({
    Title = "Build a Keyboard",
    Footer = "Tempo Hub",
    Size = UDim2.fromOffset(900, 640),
    ShowCustomCursor = false
})
Library.ShowCustomCursor = false
local fZ_3 = {
    Main = Window:AddTab("Main", "keyboard"),
    Upgrades = Window:AddTab("Upgrades", "trending-up"),
    Shop = Window:AddTab("Shop", "shopping-bag"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in pairs(fZ_3) do
    fn86(v)
end
ItemShopGroup, connection = nil, nil
local KeycapsGroup = fZ_3.Main:AddLeftGroupbox("Keycaps", "square-mouse-pointer")
KeycapsGroup:AddToggle("AutoCollect", { Text = "Auto Collect Keycaps", Default = false })
KeycapsGroup:AddSlider("CollectDwell", { Text = "Press Dwell", Default = 0.16, Min = 0.1, Max = 1, Rounding = 2 })
KeycapsGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best Keycap", Default = false })
KeycapsGroup:AddSlider("EquipDelay", { Text = "Equip Delay", Default = 5, Min = 1, Max = 60, Rounding = 1 })
local f__2 = fZ_3.Main:AddRightGroupbox("Rolls", "dices")
f__2:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
f__2:AddSlider("RollSettle", { Text = "Roll Settle", Default = 0.2, Min = 0.1, Max = 1, Rounding = 2 })
f__2:AddToggle("AutoClaimRolls", { Text = "Auto Buy Rolls", Default = false })
f__2:AddDropdown("BuyRarities", {
    Text = "Buy Rarities",
    Values = RarityOrder,
    Default = RarityOrder,
    Multi = true,
    Callback = onBuyRarities
})
f__2:AddInput("MaxRollPrice", { Text = "Max Buy Price", Default = "0", Numeric = true, Finished = true })
f__2:AddSlider("RollDelay", { Text = "Loop Delay", Default = 0.5, Min = 0.2, Max = 10, Rounding = 1 })
local RebirthGroup = fZ_3.Main:AddRightGroupbox("Rebirth", "rotate-ccw")
RebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
RebirthGroup:AddSlider("RebirthDelay", { Text = "Loop Delay", Default = 5, Min = 1, Max = 60, Rounding = 1 })
local AutoUpgradeGroup = fZ_3.Upgrades:AddLeftGroupbox("Auto Upgrade", "arrow-big-up-dash")
AutoUpgradeGroup:AddToggle("AutoSpawnRate", { Text = "Auto Upgrade Spawn Cooldown", Default = false })
AutoUpgradeGroup:AddToggle("AutoMoneyMultiplier", { Text = "Auto Upgrade Money Multiplier", Default = false })
AutoUpgradeGroup:AddToggle("AutoKeycapLuck", { Text = "Auto Upgrade Keycap Luck", Default = false })
AutoUpgradeGroup:AddToggle("AutoRollLuck", { Text = "Auto Upgrade Roll Luck", Default = false })
AutoUpgradeGroup:AddToggle("AutoKeycapRolls", { Text = "Auto Upgrade Keycap Rolls", Default = false })
AutoUpgradeGroup:AddToggle("AutoRollSpeed", { Text = "Auto Upgrade Roll Speed", Default = false })
local AutoExpandGroup = fZ_3.Upgrades:AddRightGroupbox("Auto Expand", "plus")
AutoExpandGroup:AddToggle("AutoBuyKeycap", { Text = "Auto Buy Keycaps", Default = false })
AutoExpandGroup:AddToggle("AutoBuyWorker", { Text = "Auto Buy +1 Worker", Default = false })
AutoExpandGroup:AddToggle("AutoUpgradeWorkers", { Text = "Auto Upgrade All Workers", Default = false })
local SpendingGroup = fZ_3.Upgrades:AddRightGroupbox("Spending", "wallet")
if ((AutoExpandGroup or ItemShopGroup) and (not ItemShopGroup and ItemShopGroup) or (not AutoExpandGroup or not ItemShopGroup) and (not ItemShopGroup and not ItemShopGroup)) and not ((AutoExpandGroup or ItemShopGroup) and (not ItemShopGroup and ItemShopGroup) or (not AutoExpandGroup or not ItemShopGroup) and (not ItemShopGroup and not ItemShopGroup)) then
    ItemShopGroup:AddInput("MoneyReserve", { Numeric = true, Text = "Keep Money Reserve", Finished = true, Default = "0" })
    ItemShopGroup:AddSlider("UpgradeDelay", { Default = 1, Max = 10, Text = "Loop Delay", Rounding = 1, Min = 0.2 })
    fZ_3 = SpendingGroup.Shop:AddLeftGroupbox("Item Shop", "store")
else
    SpendingGroup:AddInput("MoneyReserve", { Text = "Keep Money Reserve", Default = "0", Numeric = true, Finished = true })
    SpendingGroup:AddSlider("UpgradeDelay", { Text = "Loop Delay", Default = 1, Min = 0.2, Max = 10, Rounding = 1 })
    ItemShopGroup = fZ_3.Shop:AddLeftGroupbox("Item Shop", "store")
end
ItemShopGroup:AddToggle("AutoBuySounds", { Text = "Auto Buy Sounds", Default = false })
ItemShopGroup:AddToggle("AutoBuySkins", { Text = "Auto Buy Keyboard Skins", Default = false })
ItemShopGroup:AddSlider("ShopDelay", { Text = "Loop Delay", Default = 5, Min = 1, Max = 60, Rounding = 1 })
local MenuGroup = fZ_3.Settings:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddLabel("UI Keybind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "UI Keybind" })
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true, Callback = onAntiAfk })
MenuGroup:AddButton("Unload", onUnload)
Library.ToggleKeybind = Options.MenuKeybind
Library:OnUnload(fn165)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Mint")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/BuildAKeyboard")
SaveManager:BuildConfigSection(fZ_3.Settings)
ThemeManager:ApplyToTab(fZ_3.Settings)
ThemeManager:LoadDefault()
SaveManager:LoadAutoloadConfig()
fP()
fA()
task.spawn(worker)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoCollect.Value then
            local ix = fD()
            if ix then
                for i, v in ipairs(fQ()) do
                    if Library.Unloaded or not Toggles.AutoCollect.Value then
                        break
                    else
                        local iw = ix:FindFirstChild(tostring(v))
                        if iw then
                            fz(function()
                                fV(iw)
                                task.wait(fU(Options.CollectDwell))
                            end)
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
task.spawn(function()
    local iS = false
    repeat
        if not Library.Unloaded then
            if Toggles.AutoRoll.Value then
                local iO = fR and fR.Roll and tonumber(fR.Roll.NextRollAt)
                local iO_1 = iO or 0
                if workspace:GetServerTimeNow() >= iO_1 then
                    local iN = fK()
                    if iN then
                        fz(function()
                            if fV(iN) then
                                task.wait(fU(Options.RollSettle))
                                fV(iN)
                                local iG = fx(NetworkShared.RequestRoll)
                                if iG and iG.ok and fR then
                                    local Roll = fR.Roll
                                    local iI_1 = tonumber(iG.nextRollAt) or 0
                                    Roll.NextRollAt = iI_1
                                end
                            end
                        end)
                    end
                end
            end
            if Toggles.AutoClaimRolls.Value then
                fq()
            end
            task.wait(fU(Options.RollDelay))
        else
            iS = true
        end
    until iS
end)
task.spawn(autoEquipBestLoop)
task.spawn(autoRebirthLoop)
task.spawn(autoUpgradeWorkersLoop)
task.spawn(autoBuySoundsLoop)
end)(...)

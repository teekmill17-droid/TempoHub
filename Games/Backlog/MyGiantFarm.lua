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
getgenv().TempoHoodSubtitle = "MY GIANT FARM"
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
local n7
local nq
local nP
local oa
local nS
local nz
local nC
local nj
local n0
local nF
local oo
local nI
local ot
local nL
local n6
local np
local ns
local nO
local ow
local nR
local oc
local nv
local nU
local Workspace
local nf
local nX
local nc
local ni
local nE
local Library
local n_
local nl
local oq
local no
local oi
local nr
local n2
local SetSetting
local ob
local nx
local Options
local oe
local ne
local oh
local nh
local Toggles
local ol
local nG
local op
local nn
local n4
local ou
local nM
local function fn5(cv)
    local attr = cv:GetAttribute("Rarity")
    local qV = ot(cv)
    if oe("SellPetRarities") then
        local qW = nG("SellPetRarities")
        local qX = type(attr) ~= "string"
        local q0 = if qX then 1 else 0
        local qZ = 924 * q0 + 2040 * (1 - q0)
        local q_ = 3978 * q0 + 2491 * (1 - q0)
        if not ((qZ * 554 + q_ * 2440 + qZ * q_) % 16777213 == 13893888) then
            qX = not qW[attr]
        end
        if qX then
            return false
        end
        local q3 = if oe("SellPetMutations") then 1 else 0
        if q3 == 1 then
            local qU_1 = nG("SellPetMutations")
            if not qU_1[qV] then
                return false
            end
            return true
        end
        return true
    end
    return false
end
local function fn14(cC)
    local q4 = not cC or not cC:IsA("Model")
    if q4 then
        return false
    end
    return cC:GetAttribute("IsEgg") == true
end
local function worker()
    local vH = 0
    local vI = 0
    local vJ = 0
    local vK = 0
    while not Library.Unloaded do
        local vL = n_()
        if vL then
            if nz("AutoSkipNaming") then
                pcall(no)
            end
            local vM = nz("DisableNamingPrompts") and nq:GetAttribute("SettingPromptNaming") ~= false
            if vM then
                pcall(function()
                    nq:SetAttribute("SettingPromptNaming", false)
                    SetSetting:FireServer("PromptNaming", false)
                end)
            end
            if nz("AutoCollectMoney") then
                pcall(nL, vL)
            end
            if nz("AutoIncubateEggs") then
                pcall(nh, vL)
            end
            if nz("AutoBuyIncubators") then
                pcall(nU, vL)
            end
            if nz("AutoUpgradeBase") then
                pcall(n7, vL)
            end
            local vM_1 = os.clock()
            local vN = nz("AutoBuyEgg") and vM_1 - vK >= 1.25
            if vN then
                if nX() then
                    vK = vM_1
                else
                    vK = vM_1 - 0.6
                end
            end
            local vN_1 = (nz("AutoRoll"))
            if vN_1 then
                local vO_1 = vM_1 - vJ
                local vP_1 = tonumber(oh("RollDelay", 1.5)) or 1.5
                vN_1 = vO_1 >= vP_1
            end
            if vN_1 then
                if nE(vL) then
                    vJ = vM_1
                end
            end
            local vN_2 = (nz("AutoSellPets"))
            if vN_2 then
                local vO_2 = vM_1 - vI
                local vP_2 = tonumber(oh("SellDelay", 1)) or 1
                vN_2 = vO_2 >= vP_2
            end
            if vN_2 then
                if nf(vL) then
                    vI = vM_1
                end
            end
            local vL_1 = nz("SyncGameAutoSell") and vM_1 - vH >= 5
            if vL_1 then
                pcall(nr)
                vH = vM_1
            end
        end
        task.wait(0.35)
    end
end
local function fn23(cd)
    local attr = cd:GetAttribute("Mutation")
    local qF = attr == ""
    local qG = type(attr) ~= "string" or qF
    if qG then
        return "None"
    end
    return attr
end
local function fn32(bf)
    local pU = nR()
    if not (pU and bf) then
        return false
    elseif typeof(bf) == "CFrame" then
        pU.CFrame = bf + Vector3.new(0, 3, 0)
        return true
    elseif typeof(bf) == "Vector3" then
        local pV_2 = CFrame.new(bf)
        pU.CFrame = pV_2 + Vector3.new(0, 3, 0)
        return true
    elseif bf:IsA("Model") then
        local pivot = bf:GetPivot()
        pU.CFrame = pivot + Vector3.new(0, 3, 0)
        return true
    elseif bf:IsA("BasePart") then
        local CFrame = bf.CFrame
        pU.CFrame = CFrame + Vector3.new(0, 3, 0)
        return true
    else
        return false
    end
end
local function fn63(al)
    if Library.Unloaded then
        return false
    end
    local o3 = Toggles[al]
    return o3 ~= nil and o3.Value == true
end
local function fn98()
    local s8 = {}
    for k, v in n2(true) do
        local s9 = v.model.Parent and not nx(v.model) and n4(v.model)
        if s9 then
            s8[#s8 + 1] = v
        end
    end
    if #s8 == 0 then
        return false
    end
    table.sort(s8, function(e6, e7)
        local s4 = tonumber(e6.model:GetAttribute("Price")) or 0
        local s4_1 = tonumber(e7.model:GetAttribute("Price")) or 0
        if s4 ~= s4_1 then
            return s4 < s4_1
        elseif e6.mine ~= e7.mine then
            return e6.mine == true
        else
            return false
        end
    end)
    return oo(s8[1], true)
end
local function fn105()
    local Character = nq.Character
    local rS = Character and Character:FindFirstChildOfClass("Tool")
    local rR_1 = rS
    if rS then
        rS = rR_1:GetAttribute("AnimalId")
    end
    if rS then
        rS = rR_1:GetAttribute("UID")
    end
    if rS then
        return rR_1
    end
    return nil
end
local function fn107(d5)
    local sr = d5 and d5:FindFirstChild("Runtime")
    local ss = sr
    if sr then
        sr = ss:FindFirstChild("ButtonTemplate")
    end
    return sr
end
local function fn124(gf)
    local DiscordGroup = gf:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = np })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = np })
end
local function fn150(fn)
    local tn = nI(fn)
    if not tn then
        return false
    end
    local to = ow(fn)
    if to > oq() then
        return false
    end
    return n0(tn)
end
local function fn204(aE)
    return next(nG(aE)) ~= nil
end
local function fn235(bF)
    local qg = nn(bF)
    local qh = qg and qg:FindFirstChild("OtherImportant")
    local qg_1 = qh
    if qh then
        qh = qg_1:FindFirstChild("CashPart")
    end
    local qg_2 = qh
    if not qg_2 then
        return nil
    end
    local qh_1 = qg_2:FindFirstChild("CilinderTouch") or qg_2:FindFirstChildWhichIsA("BasePart", true)
    return qh_1
end
local function fn250(bt)
    if not bt then
        return false
    end
    op(bt)
    if fireproximityprompt then
        pcall(fireproximityprompt, bt)
        return true
    end
    return false
end
local function fn265(cL, cM)
    local q8 = (cL:GetAttribute("UID"))
    local re = if q8 then 1 else 0
    local rc = 1202 * re + 3801 * (1 - re)
    local rd = 3162 * re + 3268 * (1 - re)
    if not ((rc * 2220 + rd * 2315 + rc * rd) % 16777213 == 13789194) then
        q8 = cL:GetFullName()
    end
    local q9 = q8
    local q8_1 = os.clock()
    local ra = cM or 8
    oi[q9] = q8_1 + ra
end
local function fn286(eK, eL)
    local s1_1
    local s0 = not eK or not eK.model or not eK.model.Parent
    local s0_1
    if s0 then
        return false
    end
    s0_1, s1_1 = ns(eK.model)
    if not s0_1 then
        return false
    end
    local s0_2 = s1_1 or eK.prompt
    if not s0_2 or not s0_2.Parent then
        return false
    end
    if not eL then
        local BasePart = eK.model:FindFirstChildWhichIsA("BasePart", true)
        if BasePart then
            oc(BasePart)
            task.wait(0.12)
        end
    end
    op(s0_2)
    local Parent = eK.model.Parent
    local s2 = n0(s0_2)
    task.wait(0.2)
    if eK.model.Parent == Parent then
        oa(eK.model, 10)
        return false
    end
    return s2
end
local function fn292(dU)
    local sh = {}
    local si = nn(dU)
    local sj = si and si:FindFirstChild("WaitingZones")
    if not sj then
        return sh
    end
    for i, child in sj:GetChildren() do
        local si_2 = child.Name:match("^incubator%d+$") and child:GetAttribute("HatchBusy") ~= true
        if si_2 then
            local si_3 = nC(child, "Incubate Egg")
            if si_3 then
                sh[#sh + 1] = { zone = child, prompt = si_3, part = child:FindFirstChild("ProxPart") }
            end
        end
    end
    return sh
end
local function fn302(bk, bl)
    if not bk then
        return nil
    end
    for i, descendant in bk:GetDescendants() do
        if descendant:IsA("ProximityPrompt") then
            if not bl or descendant.ActionText == bl then
                return descendant
            end
        end
    end
    return nil
end
local function fn320(cF)
    if not nM(cF) then
        return false
    elseif cF:GetAttribute("DisplayGround") == nil then
        return false
    else
        local q6 = nC(cF, "Buy")
        if not q6 then
            return false
        end
        return true, q6
    end
end
local function fn338(bO)
    local qj = nn(bO)
    local qk = qj and qj:FindFirstChild("OtherImportant")
    local qj_1 = qk
    if qk then
        qk = qj_1:FindFirstChild("ExpandSign")
    end
    return qk
end
local function fn344(ea)
    if not ea then
        return math.huge
    end
    for i, descendant in ea:GetDescendants() do
        if descendant:IsA("TextLabel") then
            local su = descendant.Text or ""
            local su_1 = su:find("%$") or su:upper():find("[KMB]")
            if su_1 then
                local su_2 = ne(su)
                if su_2 > 0 then
                    return su_2
                end
            end
        end
    end
    return math.huge
end
local function fn347()
    return nP
end
local function fn375(bV)
    local qm = nc(bV)
    local qn = nC(qm, "Upgrade Base") or nC(qm, "Expand")
    return qn
end
local function fn376(ei)
    local sD = ei
    local sE = {}
    if sD then
        sD = ei:FindFirstChild("Runtime")
    end
    local sF = sD
    if not sF then
        return sE
    end
    for i, child in sF:GetChildren() do
        local sD_1 = child:IsA("Model") and child:GetAttribute("UID") and child:GetAttribute("IsEgg") ~= true
        if sD_1 then
            local sD_2 = not child.Name:find("Egg", 1, true) and child.Name ~= "ButtonTemplate" and child.Name ~= "ghostcubator"
            if sD_2 then
                sE[#sE + 1] = child
            end
        end
    end
    return sE
end
local function fn431(fv)
    local tt = ni(fv)
    if #tt == 0 then
        return false
    end
    local tu = tonumber(nq:GetAttribute("PetCount")) or 0
    local tu_1 = tonumber(nq:GetAttribute("PetCapacity")) or 0
    if tu_1 > 0 and tu >= tu_1 then
        return false
    end
    local tu_3 = ol()
    if not tu_3 then
        return false
    end
    local tu_4 = tt[1]
    if tu_4.part then
        oc(tu_4.part)
        task.wait(0.15)
    end
    return n0(tu_4.prompt)
end
local function fn446(fc)
    local th = nl(fc)
    if not th then
        return false
    end
    local ti = ob(th)
    if ti > oq() then
        return false
    end
    local ti_1 = th:FindFirstChild("Cilinder") or th:FindFirstChildWhichIsA("BasePart", true)
    if not ti_1 then
        return false
    end
    local ti_2 = nR()
    if not ti_2 then
        return false
    end
    ti_2.CFrame = CFrame.new(ti_1.Position)
    task.wait(0.35)
    return true
end
local function fn455(ad, ae)
    return string.format('<font color="%s">%s</font>', ae, ad)
end
local function fn484()
    nO(nS, "Copied Discord invite to clipboard")
end
local function fn507(ag, ah, ai)
    return string.format("<b>%s</b> %s %s", ag, ou("-", "#5a6070"), ou(ah, ai))
end
local function fn523(ch)
    local qL = ch:GetAttribute("Rarity") or ch:GetAttribute("RevealRarity")
    local qL_12, qL_13
    local qM_4
    local qL_1 = ot(ch)
    local qN = tonumber(ch:GetAttribute("Price")) or 0
    local qT = if oe("BuyEggRarities") then 1 else 0
    if qT == 1 then
        local qN_1 = nG("BuyEggRarities")
        local qP = type(qL) ~= "string"
        local qT_1 = if qP then 1 else 0
        local qR_1 = 3971 * qT_1 + 2506 * (1 - qT_1)
        local qS_1 = 3826 * qT_1 + 545 * (1 - qT_1)
        if not ((qR_1 * 3803 + qS_1 * 421 + qR_1 * qS_1) % 16777213 == 15128292) then
            qP = not qN_1[qL]
        end
        if qP then
            return false
        elseif oe("BuyEggMutations") then
            nG("BuyEggMutations")
            if not qM_4[qL_1] then
                return false
            end
            local qL_2 = (tonumber(oh("BuyEggMaxPrice", 0)))
            if qL_12 then
                return false
            end
            local qL_4 = nz("BuyEggSkipUnaffordable") and qN > oq()
            if qL_13 then
                return false
            end
            return true
        else
            local qL_5 = (tonumber(oh("BuyEggMaxPrice", 0)))
            if qL_12 then
                return false
            end
            local qL_7 = nz("BuyEggSkipUnaffordable") and qN > oq()
            if qL_13 then
                return false
            end
            return true
        end
    elseif oe("BuyEggMutations") then
        qM_4 = nG("BuyEggMutations")
        if not qM_4[qL_1] then
            return false
        end
        local qL_8 = (tonumber(oh("BuyEggMaxPrice", 0)))
        if qL_12 then
            return false
        end
        local qL_10 = nz("BuyEggSkipUnaffordable") and qN > oq()
        if qL_13 then
            return false
        end
        return true
    else
        local qL_11 = (tonumber(oh("BuyEggMaxPrice", 0)))
        local qT_5 = if qL_11 then 1 else 0
        local qR_5 = 1751 * qT_5 + 2177 * (1 - qT_5)
        local qS_5 = 1597 * qT_5 + 631 * (1 - qT_5)
        if not ((qR_5 * 1278 + qS_5 * 969 + qR_5 * qS_5) % 16777213 == 6581618) then
            qL_11 = 0
        end
        local qM_6 = qL_11
        qL_12 = qM_6 > 0 and qN > qM_6
        if qL_12 then
            return false
        end
        qL_13 = nz("BuyEggSkipUnaffordable") and qN > oq()
        if qL_13 then
            return false
        end
        return true
    end
end
local function fn546(cX, cY)
    local ri = cX
    local ri_4
    local rj = {}
    if ri then
        ri = cX:FindFirstChild("Runtime")
    end
    local rk = ri
    local rk_1
    if not rk then
        return rj
    end
    local attr = cX:GetAttribute("OwnerUserId")
    local rl = attr == nq.UserId
    if cY and not rl then
        return rj
    end
    local ri_3 = not cY
    if ri_3 ~= false then
        ri_3 = rl
    end
    if ri_3 then
        return rj
    end
    for i, child in rk:GetChildren() do
        ri_4, rk_1 = ns(child)
        if ri_4 then
            rj[#rj + 1] = { model = child, prompt = rk_1 }
        end
    end
    return rj
end
local function fn570()
    local Character = nq.Character
    local pn = Character and Character:FindFirstChildOfClass("Humanoid")
    return pn
end
local function fn581(a_)
    local py_1
    local pz_1
    if type(a_) == "number" then
        return a_
    elseif type(a_) ~= "string" then
        return 0
    else
        local px = a_:gsub("[%$,%s]", ""):upper()
        pz_1, py_1 = px:match("^([%d%.]+)([KMB]?)$")
        local pz_2 = tonumber(pz_1)
        if not pz_2 then
            return 0
        elseif py_1 == "K" then
            return pz_2 * 1000
        elseif py_1 == "M" then
            return pz_2 * 1000000
        elseif py_1 == "B" then
            return pz_2 * 1000000000
        else
            return pz_2
        end
    end
end
local function fn633(ar, as)
    local o6 = Options[ar]
    if o6 == nil then
        return as
    end
    return o6.Value
end
local function fn655(da)
    local rx = {}
    local Map = Workspace:FindFirstChild("Map")
    if not Map then
        return rx
    end
    for i, child in Map:GetChildren() do
        local ry_1 = child:GetAttribute("OwnerUserId") == nq.UserId
        local rz = not ry_1
        local rz_2
        local rA = da or rz
        local rA_1
        if rA then
            local Runtime = child:FindFirstChild("Runtime")
            if Runtime then
                for i, child in Runtime:GetChildren() do
                    rz_2, rA_1 = ns(child)
                    if rz_2 then
                        rx[#rx + 1] = { model = child, prompt = rA_1, mine = ry_1 }
                    end
                end
            end
        end
    end
    return rx
end
local function fn705(er)
    local sN = nz("StopRollIfIncubatorsBusy") and #ni(er) == 0
    if sN then
        return false
    end
    local sN_1 = nF(er)
    local sO = not sN_1
    local sT = if sO then 1 else 0
    local sR = 210 * sT + 3462 * (1 - sT)
    local sS = 46 * sT + 3261 * (1 - sT)
    if not ((sR * 335 + sS * 666 + sR * sS) % 16777213 == 110646) then
        sO = not sN_1.Enabled
    end
    if sO then
        return false
    end
    local Parent = sN_1.Parent
    local sP = Parent and Parent:IsA("BasePart")
    if sP then
        oc(Parent)
        task.wait(0.1)
    end
    return n0(sN_1)
end
local function fn707(ba)
    if not ba then
        return nil
    end
    for i, child in ba:GetChildren() do
        local pM = child:IsA("Model") and child.Name:match("^BaseLevel%d+$")
        if pM then
            return child
        end
    end
    return nil
end
local function fn714()
    local Map = Workspace:FindFirstChild("Map")
    if not Map then
        return nil
    end
    for i, child in Map:GetChildren() do
        if child:GetAttribute("OwnerUserId") == nq.UserId then
            return child
        end
    end
    return nil
end
local function fn737(eD)
    local sU = n6(eD)
    local sV = nR()
    if not (sU and sV) then
        return false
    elseif firetouchinterest then
        pcall(firetouchinterest, sV, sU, 0)
        task.wait()
        pcall(firetouchinterest, sV, sU, 1)
        return true
    else
        return oc(sU)
    end
end
local function fn825(cR)
    local rf = cR:GetAttribute("UID") or cR:GetFullName()
    local rf_1 = oi[rf]
    if not rf_1 then
        return false
    elseif os.clock() >= rf_1 then
        oi[rf] = nil
        return false
    else
        return true
    end
end
local function fn844(W, X)
    if setclipboard then
        setclipboard(W)
    elseif toclipboard then
        toclipboard(W)
    end
    Library:Notify(X)
end
local function fn884()
    local rX = nv()
    if rX then
        return rX
    end
    local Character = nq.Character
    local Backpack = nq:FindFirstChild("Backpack")
    if Backpack then
        for i, child in Backpack:GetChildren() do
            local rY_1 = child:IsA("Tool") and child:GetAttribute("AnimalId") and child:GetAttribute("UID")
            if rY_1 then
                return child
            end
        end
    end
    if Character then
        for i, child in Character:GetChildren() do
            local rX_2 = child:IsA("Tool") and child:GetAttribute("AnimalId") and child:GetAttribute("UID")
            if rX_2 then
                return child
            end
        end
    end
    return nil
end
local function fn923(aw)
    local o8 = oh(aw, {})
    if typeof(o8) ~= "table" then
        return {}
    end
    local o9 = {}
    for k, v in o8 do
        if v == true then
            o9[k] = true
        else
            local o8_1 = typeof(k) == "number" and typeof(v) == "string"
            if o8_1 then
                o9[v] = true
            end
        end
    end
    return o9
end
local function fn925(b0)
    local qp = nc(b0)
    if not qp then
        return math.huge
    end
    for i, descendant in qp:GetDescendants() do
        local qq_1 = descendant:IsA("TextLabel") and descendant.Name == "Price"
        if qq_1 then
            local qq_2 = ne(descendant.Text)
            if qq_2 > 0 then
                return qq_2
            end
        end
    end
    for i, descendant in qp:GetDescendants() do
        if descendant:IsA("TextLabel") then
            local qp_1 = descendant.Text or ""
            if qp_1:find("%$") then
                local qp_2 = ne(qp_1)
                if qp_2 > 0 then
                    return qp_2
                end
            end
        end
    end
    return math.huge
end
local function fn943(bw)
    local qd = nn(bw)
    local qe = qd and qd:FindFirstChild("OtherImportant")
    local qd_1 = qe
    if qe then
        qe = qd_1:FindFirstChild("LeverModel")
    end
    local qd_2 = qe
    return nC(qd_2, "Roll"), qd_2
end
local function fn944()
    local Character = nq.Character
    local pk = Character and Character:FindFirstChild("HumanoidRootPart")
    return pk
end
nc = nil
ne = nil
nf = nil
nh = nil
ni = nil
nj = nil
nl = nil
nn = nil
no = nil
np = nil
nq = nil
nr = nil
ns = nil
nv = nil
nx = nil
Workspace = nil
nz = nil
nC = nil
nE = nil
nF = nil
nG = nil
nI = nil
nL = nil
nM = nil
nO = nil
nP = nil
SetSetting = nil
nR = nil
nS = nil
Options = nil
nU = nil
nX = nil
local nb, nd, ng, nk, nm, nt, nu, nw, nA, TeleportService, nD, nH, nJ, SetAutoSell, nN, nV, SellPet, nY
Toggles = nil
n_ = nil
n0 = nil
n2 = nil
n4 = nil
n6 = nil
n7 = nil
oa = nil
ob = nil
oc = nil
oe = nil
oh = nil
oi = nil
ol = nil
Library = nil
oo = nil
op = nil
oq = nil
ot = nil
ou = nil
local ov
ow = nil
local n1, NumberUtil, n5, SaveManager, n9, od, ThemeManager, oj
local oy_1
local oz_3
nb, oy_1, oj, n9, n1, nV, nP, nH, TeleportService, Workspace, nq, nj = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local ox = 13
local ox_4
repeat
    local oz_1 = (ox * 2 + 1) % 5 + 1
    if oz_1 <= 3 then
        if oz_1 <= 2 then
            if oz_1 <= 1 then
                local xm = bit32.rrotate(bit32.bxor(bit32.lrotate(ox, 15), string.byte(tostring(nq))), 10)
                if bit32.bxor(bit32.lrotate(bit32.bxor(xm, 446651432), 28), 2175399362) ~= bit32.lrotate(xm, 28) then
                    oj = game:GetService("TeleportService")
                else
                    TeleportService = game:GetService("TeleportService")
                end
                ox = (ox + 8) % 20
            else
                local oA_1 = {
                    "kslbplmxnrn",
                    "koxuy",
                    "dyjaeprebh",
                    "incwco",
                    "eihzwxngif",
                    "pbrr",
                    "pslipi",
                    "ebjyikjcwc",
                    "rjdyrzzpo",
                    "hbrbszvc",
                    "hud",
                    "osyb",
                    "jefsgow",
                    "puwikkxmjm",
                    "cmuqfsznddh"
                }
                if oA_1[(ox * 16 + 12) % 15 + 1] <= oA_1[(ox * 16 + 12) % 15 + 1] then
                    Workspace = game:GetService("Workspace")
                    nq = nb.LocalPlayer
                    nj = fn347
                else
                    nb = game:GetService("Workspace")
                    nj = Workspace.LocalPlayer
                    nq = fn347
                end
                ox = (ox + 8) % 20
            end
        else
            if ox * 115376437 + 6 + 2 <= ox * 115376437 + 6 + 2 + 3 then
                nb = game:GetService("Players")
            else
                nV = game:GetService("Players")
            end
            ox = (ox + 3) % 20
        end
    elseif oz_1 <= 4 then
        local xj = bit32.rrotate(bit32.bxor(bit32.lrotate(ox, 14), string.byte(tostring(nP))), 23)
        if bit32.bxor(bit32.lrotate(bit32.bxor(xj, 1658559714), 6), 3068606616) ~= bit32.lrotate(xj, 6) then
            n9 = game:GetService("ReplicatedStorage")
            oy_1 = game:GetService("RunService")
            oj = game:GetService("UserInputService")
        else
            oy_1 = game:GetService("ReplicatedStorage")
            oj = game:GetService("RunService")
            n9 = game:GetService("UserInputService")
        end
        ox = (ox + 3) % 20
    else
        local oz_2 = { "uttav", "zydkjlewa", "fedtq", "nmd", "ezbhkylzna", "wgwlvhnb", "xxnwee", "faggfy" }
        if oz_2[(ox * 80 + 83) % 8 + 1] < oz_2[(ox * 80 + 83) % 8 + 1] then
            nH = game:GetService("VirtualUser")
            n1 = game:GetService("HttpService")
            nV = game:GetService("CoreGui")
            nP = game:GetService("GuiService")
        else
            n1 = game:GetService("VirtualUser")
            nV = game:GetService("HttpService")
            nP = game:GetService("CoreGui")
            nH = game:GetService("GuiService")
        end
        ox = (ox + 3) % 20
    end
until (ox * 17 + 6) % 20 == 12
if getgenv then
    ov, oz_3 = nil, nil
    local ox_1 = 1
    repeat
        if (ox_1 * 1 + 1) % 2 + 1 <= 1 then
            local oA_3 = (vector.create((ox_1 * 5 + 2) % 11 + 1, (ox_1 * 9 + 8) % 13 + 1, (ox_1 * 9 + 13) % 17 + 1))
            local oB_1 = (vector.create((ox_1 * 1 + 5) % 11 + 1, (ox_1 * 8 + 10) % 13 + 1, (ox_1 * 5 + 2) % 17 + 1))
            local yh = vector.cross(oA_3, oB_1)
            local yi = vector.dot(oA_3, oB_1)
            if vector.dot(yh, yh) + yi * yi == vector.dot(oA_3, oA_3) * vector.dot(oB_1, oB_1) then
                getgenv().gethui = nj
                ov = getgenv().__TempoMyGiantFarmLib
            else
                getgenv().gethui = ov
                nj = getgenv().__TempoMyGiantFarmLib
            end
            ox_1 = (ox_1 + 5) % 16
        else
            local yl = bit32.rrotate(bit32.bxor(bit32.lrotate(ox_1, 15), string.byte(tostring(ov))), 12)
            if bit32.bxor(bit32.lrotate(bit32.bxor(yl, 3487045306), 30), 3019244974) ~= bit32.lrotate(yl, 30) then
                ov = oz_3
            else
                oz_3 = ov
            end
            ox_1 = (ox_1 + 13) % 16
        end
    until (ox_1 * 5 + 15) % 16 == 14
    if oz_3 then
        oz_3 = ov.Unload
    end
    if oz_3 then
        pcall(function()
            ov:Unload()
        end)
    end
end
pcall(function()
    gethui = nj
end)
if setthreadidentity then
    setthreadidentity(8)
end
nY, nS, nN, nD, nA, nu, nm, ng, nd, NumberUtil, SellPet, SetSetting, SetAutoSell = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
nY = "My Giant Farm"
nS = "https://discord.gg/K7Qxnxkk46"
nN = "https://discord.gg/K7Qxnxkk46"
nD = "https://tempohub.shop"
nA = "#7fd47f"
nu = "#6ec1ff"
nm = "#e8a34d"
ng = "#8b93a3"
nd = "#e05a5a"
local Modules = oy_1:WaitForChild("Modules")
local Remotes = oy_1:WaitForChild("Remotes")
local AnimalConfig = require(Modules:WaitForChild("AnimalConfig"))
NumberUtil = require(Modules:WaitForChild("NumberUtil"))
SellPet = Remotes:WaitForChild("SellPet")
SetSetting = Remotes:WaitForChild("SetSetting")
SetAutoSell = Remotes:WaitForChild("SetAutoSell")
local oC = {}
local RarityOrder = AnimalConfig.RarityOrder
if type(RarityOrder) == "table" then
    local oR = 1
    while oR <= 32 do
        local oy_2 = RarityOrder[oR]
        if type(oy_2) == "string" then
            oC[#oC + 1] = oy_2
        end
        oR += 1
    end
end
if #oC == 0 then
    local ox_3 = 6
    repeat
        local oy_3 = {
            "tgjpzkzes",
            "vhawa",
            "dnbgv",
            "nxermgx",
            "pdxsltsrw",
            "nsam",
            "dfatrkwgu",
            "tiee",
            "azgr",
            "zttom"
        }
        local ys = ox_3
        local oz_5 = oy_3[ys % 10 + 1]
        if oz_5:len() >= oz_5:gsub("(.)", "%1%1", ys % 3 % 2 + 1):len() then
            oC = { "Mythic", "Epic", "Rare", "Common", "Legendary", "Divine", "Secret" }
        else
            oC = { "Common", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Divine" }
        end
        ox_3 = (ox_3 + 1) % 8
    until (ox_3 * 3 + 0) % 8 == 5
end
Library, ThemeManager, SaveManager = nil, nil, nil
local oA_5 = { "None", "Gold", "Ruby", "Diamond", "Rainbow" }
Library = getgenv().Library
ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
if getgenv then
    getgenv().__TempoMyGiantFarmLib = Library
end
Toggles, Options, oi, nJ, nO, np, ou, n5, nz, oh, nG, oe, nR, nt, oq, ne, n_, nn, oc, nC, op, n0, nF, n6, nc, nI, ow, ot, n4, nw, nM, ns, oa, nx, n2, ox_4, nv, od, ol, ni, nl, ob, nk, nE, nL, oo, nX, nU, n7, nh, nf, no, nr = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Toggles = Library.Toggles
Options = Library.Options
nO = fn844
np = fn484
ou = fn455
n5 = fn507
nz = fn63
oh = fn633
nG = fn923
oe = fn204
nR = fn944
nt = fn570
oq = function()
    local pp
    local Data = nq:FindFirstChild("Data")
    local pq_1
    local pr = Data and Data:FindFirstChild("Cash")
    local pr_1
    pp = pr
    if not pp then
        return 0
    end
    pq_1, pr_1 = pcall(function()
        return NumberUtil.ToNumber(pp.Value)
    end)
    local ps = pq_1 and type(pr_1) == "number"
    if ps then
        return pr_1
    end
    local pq_2 = tonumber(pp.Value) or 0
    return pq_2
end
ne = fn581
n_ = fn714
nn = fn707
oc = fn32
nC = fn302
op = function(bq)
    if not bq then
        return false
    end
    pcall(function()
        bq:SetAttribute("LocalPrompt", true)
        bq.Enabled = true
        bq.RequiresLineOfSight = false
        if bq.MaxActivationDistance < 30 then
            bq.MaxActivationDistance = 30
        end
    end)
    return true
end
n0 = fn250
nF = fn943
n6 = fn235
nc = fn338
nI = fn375
ow = fn925
ot = fn23
n4 = fn523
nw = fn5
nM = fn14
ns = fn320
oi = {}
oa = fn265
nx = fn825
if (oq and not nE and (ox_4 or nX) or (oc and oq or (not od or not oc))) and (od and nX and (oc or not od) and (false and od or (not ox_4 or not od))) and (oq and od and (nX or not oc) and (not od and oc or (nE or nE)) and (nX and oc and (nX or ox_4) or (false or nE or (not nE or ox_4)))) or not ((oq and not nE and (ox_4 or nX) or (oc and oq or (not od or not oc))) and (od and nX and (oc or not od) and (false and od or (not ox_4 or not od))) and (oq and od and (nX or not oc) and (not od and oc or (nE or nE)) and (nX and oc and (nX or ox_4) or (false or nE or (not nE or ox_4))))) then
    n2 = fn655
else
    n2 = fn546
end
nv = fn105
od = fn884
ol = function()
    local sb = od()
    if not sb then
        return nil
    elseif sb.Parent == nq.Character then
        return sb
    else
        local sc = nt()
        if sc then
            pcall(function()
                sc:EquipTool(sb)
            end)
            task.wait(0.15)
        end
        return nv()
    end
end
ni = fn292
nl = fn107
ob = fn344
nk = fn376
nE = fn705
nL = fn737
oo = fn286
if ((nk or not oo) and (not nk or not nk) or (oo or not oo) and (oo and nk)) and not ((nk or not oo) and (not nk or not nk) or (oo or not oo) and (oo and nk)) then
    nF = fn98
else
    nX = fn98
end
nU = fn446
n7 = fn150
nh = fn431
nf = function(fI)
    local tz = false
    for k, v in nk(fI) do
        if nw(v) then
            local attr = v:GetAttribute("UID")
            local tA = attr ~= ""
            local tB = type(attr) == "string" and tA
            if tB then
                pcall(function()
                    SellPet:FireServer(attr)
                end)
                tz = true
                task.wait(0.15)
            end
        end
    end
    return tz
end
no = function()
    local PlayerGui = nq:FindFirstChild("PlayerGui")
    local tL = PlayerGui and PlayerGui:FindFirstChild("ScreenGui")
    local tK_1 = tL
    if tL then
        tL = tK_1:FindFirstChild("AnimalName")
    end
    local tK_2 = tL
    if not tK_2 or not tK_2.Visible then
        return false
    end
    local SkipUI = tK_2:FindFirstChild("SkipUI")
    local tK_3 = SkipUI and SkipUI:IsA("GuiButton")
    if tK_3 then
        pcall(function()
            firesignal(SkipUI.Activated)
        end)
        pcall(function()
            firesignal(SkipUI.MouseButton1Click)
        end)
        return true
    end
    return false
end
nr = function()
    local tQ
    if not nz("SyncGameAutoSell") then
        return
    end
    tQ = {}
    for k in nG("SellPetRarities") do
        tQ[k] = true
    end
    for k in nG("SellPetMutations") do
        if k ~= "None" then
            tQ[k] = true
        end
    end
    pcall(function()
        SetAutoSell:FireServer(tQ)
    end)
end
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = nS, Copyable = true }, "|", nY },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
nJ = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gavel"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in nJ do
    if k ~= "Info" then
        fn124(v)
    end
end
local FarmGroup = nJ.Main:AddLeftGroupbox("Farm", "sprout")
FarmGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
FarmGroup:AddToggle("StopRollIfIncubatorsBusy", { Text = "Stop Roll If Incubators Busy", Default = true })
FarmGroup:AddSlider("RollDelay", { Text = "Roll Delay", Default = 1.5, Min = 0.3, Max = 10, Rounding = 1 })
FarmGroup:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
FarmGroup:AddToggle("AutoIncubateEggs", { Text = "Auto Incubate Eggs", Default = false })
FarmGroup:AddToggle("AutoSkipNaming", { Text = "Auto Skip Naming", Default = false })
FarmGroup:AddToggle("DisableNamingPrompts", { Text = "Disable Naming Prompts", Default = false })
local EggsGroup = nJ.Main:AddLeftGroupbox("Eggs", "egg")
EggsGroup:AddToggle("AutoBuyEgg", { Text = "Auto Buy Egg", Default = false })
EggsGroup:AddDropdown("BuyEggRarities", {
    Text = "Buy Rarities",
    Values = oC,
    Default = {},
    Multi = true,
    Expandable = true,
    ExpandColumns = 2
})
EggsGroup:AddDropdown("BuyEggMutations", {
    Text = "Buy Mutations",
    Values = oA_5,
    Default = {},
    Multi = true,
    Expandable = true,
    ExpandColumns = 2
})
EggsGroup:AddInput("BuyEggMaxPrice", { Text = "Max Price (0 = any)", Default = "0", Numeric = true, Finished = true })
EggsGroup:AddToggle("BuyEggSkipUnaffordable", { Text = "Skip Unaffordable", Default = true })
EggsGroup:AddToggle("AutoBuyIncubators", { Text = "Auto Buy Incubators", Default = false })
EggsGroup:AddToggle("AutoUpgradeBase", { Text = "Auto Upgrade Base", Default = false })
local SellGroup = nJ.Main:AddRightGroupbox("Sell", "badge-dollar-sign")
SellGroup:AddToggle("AutoSellPets", { Text = "Auto Sell Pets", Default = false })
SellGroup:AddDropdown("SellPetRarities", {
    Text = "Sell Rarities",
    Values = oC,
    Default = { Common = true },
    Multi = true,
    Expandable = true,
    ExpandColumns = 2
})
SellGroup:AddDropdown("SellPetMutations", {
    Text = "Sell Mutations",
    Values = oA_5,
    Default = {},
    Multi = true,
    Expandable = true,
    ExpandColumns = 2
})
SellGroup:AddToggle("SyncGameAutoSell", { Text = "Sync Game Auto-Sell", Default = false })
SellGroup:AddSlider("SellDelay", { Text = "Sell Delay", Default = 1, Min = 0.3, Max = 10, Rounding = 1 })
local function oF()
    local uT
    local uS
    uS = nil
    uT = nil
    local Label2, Label3, uQ, uR, Label
    local function uV()
        local t_ = hookfunction ~= nil
        local t0 = hookmetamethod ~= nil
        local t1 = getrawmetatable ~= nil
        local t2 = setrawmetatable ~= nil
        local t3 = getgc ~= nil
        local t4 = getgenv ~= nil
        local t5 = getreg ~= nil
        local t6 = getconnections ~= nil
        local t7 = firesignal ~= nil
        local t8 = getcallbackvalue ~= nil
        local t9 = setclipboard ~= nil
        local ua = getcustomasset ~= nil
        local ub = getnamecallmethod ~= nil
        local uc = isexecutorclosure ~= nil
        local ud = fireproximityprompt ~= nil
        local ue = firetouchinterest ~= nil
        local uf = WebSocket ~= nil
        local ug = readfile ~= nil
        local uh = writefile ~= nil
        local uj = (request or http_request) ~= nil
        local ul = (debug and debug.getupvalues) ~= nil
        local un = (debug and debug.setupvalue) ~= nil
        local uo = 0
        local up = { t_, t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, ua, ub, uc, ud, ue, uf, ug, uh, uj, ul, un }
        for i, v in ipairs(up) do
            if v then
                uo += 1
            end
        end
        local t__1 = uo / #up
        if t__1 >= 0.9 then
            return ou("Full Support", nA)
        elseif t__1 >= 0.6 then
            return ou("Half Support", nm)
        else
            return ou("Low Support", nd)
        end
    end
    uS = "Unknown"
    pcall(function()
        local uE_1
        local uD_1
        if identifyexecutor then
            uE_1, uD_1 = identifyexecutor()
            local uF = uE_1 ~= ""
            local uG = type(uE_1) == "string" and uF
            if uG then
                local uF_1 = type(uD_1) == "string" and uD_1 ~= "" and uE_1 .. " " .. uD_1
                uS = uF_1 or uE_1
            end
        end
    end)
    local uW = uV()
    uT = os.clock()
    uQ = function()
        local uI = math.floor(os.clock() - uT)
        if uI < 60 then
            return uI .. "s"
        elseif uI < 3600 then
            return string.format("%dm %ds", math.floor((uI) / (60)), uI % 60)
        else
            return string.format("%dh %dm", math.floor((uI) / (3600)), math.floor((uI % 3600) / (60)))
        end
    end
    local UserGroup = nJ.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = nq, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(n5("User", nq.DisplayName .. " @" .. nq.Name, nA), true)
    UserGroup:AddLabel(n5("UserId", tostring(nq.UserId), nu), true)
    UserGroup:AddLabel(n5("Executor", uS .. "  " .. uW, nA), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(n5("Session", uQ(), nm), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            nO(nq.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            nO("https://www.roblox.com/users/" .. tostring(nq.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = nJ.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(n5("Game", nY, nu), true)
    Label2 = SessionGroup:AddLabel(n5("Players", "0/0", nA), true)
    uR = tostring(game.JobId)
    local uW_1 = #uR > 18 and string.sub(uR, 1, 18) .. "..."
    local uW_2 = uW_1 or uR
    SessionGroup:AddLabel(n5("Job", uW_2, ng), true)
    Label = SessionGroup:AddLabel(n5("Ping", "0 ms", nm), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            TeleportService:Teleport(game.PlaceId, nq)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            nO(uR, "Copied Job ID")
        end
    })
    task.spawn(function()
        local uL_1
        local uK_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(n5("Session", uQ(), nm))
            Label2:SetText(n5("Players", #nb:GetPlayers() .. "/" .. tostring(nb.MaxPlayers), nA))
            uK_1, uL_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local uK_2 = uK_1 and uL_1 .. " ms" or "n/a"
            Label:SetText(n5("Ping", uK_2, nm))
        end
    end)
    local SocialsGroup = nJ.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = np })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            nO(nN, "Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            nO(nD, "Copied website link")
        end
    })
end
local function oG()
    local MovementGroup = nJ.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = nJ.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local function hC(hD)
        pcall(function()
            nH:SetGameplayPausedNotificationEnabled(not hD)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = nP:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not hD
            end
        end)
        if not hD then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(nq, "GameplayPaused", false)
            else
                nq.GameplayPaused = false
            end
        end)
    end
    local function hQ(hR)
        if not hR:IsA("ProximityPrompt") then
            return
        end
        hR.HoldDuration = 0
        hR.MaxActivationDistance = 50
        hR.RequiresLineOfSight = false
    end
    local connection
    oj.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = nq.Character
            if Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    local u3_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if u3_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    n9.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local vb_1 = nt()
            if vb_1 then
                vb_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    local CurrentCamera = Workspace.CurrentCamera
    oj.RenderStepped:Connect(function(ic)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local vg_1 = nt()
            if vg_1 then
                vg_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local vg_3 = nR()
            local vh = nt()
            if vg_3 and vh then
                vh.PlatformStand = true
                local vh_1 = Vector3.zero
                if n9:IsKeyDown(Enum.KeyCode.W) then
                    vh_1 += CurrentCamera.CFrame.LookVector
                end
                if n9:IsKeyDown(Enum.KeyCode.S) then
                    vh_1 -= CurrentCamera.CFrame.LookVector
                end
                if n9:IsKeyDown(Enum.KeyCode.A) then
                    vh_1 -= CurrentCamera.CFrame.RightVector
                end
                local vm = if n9:IsKeyDown(Enum.KeyCode.D) then 1 else 0
                if vm == 1 then
                    vh_1 += CurrentCamera.CFrame.RightVector
                end
                if n9:IsKeyDown(Enum.KeyCode.Space) then
                    vh_1 += Vector3.new(0, 1, 0)
                end
                if n9:IsKeyDown(Enum.KeyCode.LeftControl) then
                    vh_1 -= Vector3.new(0, 1, 0)
                end
                vg_3.AssemblyLinearVelocity = Vector3.zero
                if vh_1.Magnitude > 0 then
                    vg_3.CFrame = vg_3.CFrame + vh_1.Unit * Options.FlySpeed.Value * ic
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local vn = nt()
            if vn then
                vn.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local vs = nt()
            if vs then
                vs.WalkSpeed = 16
            end
        end
    end)
    Toggles.AntiGameplayPause:OnChanged(function()
        hC(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                hC(true)
            end
        end
    end)
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in ipairs(Workspace:GetDescendants()) do
                pcall(hQ, descendant)
            end
            connection = Workspace.DescendantAdded:Connect(function(iL)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(hQ, iL)
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    Library:OnUnload(function()
        hC(false)
        if connection then
            connection:Disconnect()
        end
    end)
end
oF()
oG()
task.spawn(worker)
local function oB_4()
    local connection
    local MenuGroup = nJ.Settings:AddLeftGroupbox("Menu")
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    local jm = 0
    local jn = tick()
    local Label
    local function jp()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then
            return
        end
        n1:CaptureController()
        n1:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        jm += 1
        jn = tick()
        if Label then
            pcall(function()
                Label:SetText("AFK triggers: " .. jm)
            end)
        end
    end
    connection = nq.Idled:Connect(function()
        local vW = if nz("AntiAfk") then 1 else 0
        if vW == 1 then
            pcall(jp)
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
            local vX = nz("AntiAfk") and tick() - jn >= 60
            if vX then
                pcall(jp)
            end
        end
    end)
    Library:OnUnload(function()
        if connection then
            connection:Disconnect()
        end
        if getgenv then
            getgenv().__TempoMyGiantFarmLib = nil
        end
    end)
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("TempoHub")
    ThemeManager:SaveDefault("Evil Hello Kitty")
    ThemeManager:ApplyToTab(nJ.Settings)
    ThemeManager:LoadDefault()
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    SaveManager:SetFolder("TempoHub/MyGiantFarm")
    local jM = SaveManager:BuildConfigSection(nJ.Settings)
    SaveManager:LoadAutoloadConfig()
    local function jN(jO, jP)
        local v3_1 = (jO == "Toggle" and Toggles or Options)[jP]
        local v2_2 = type(v3_1) == "table" and v3_1.Type == jO
        return v2_2 and v3_1 or nil
    end
    local function jW(jX, jY)
        local Type = jY.Type
        if Type == "Toggle" then
            return { idx = jX, type = "Toggle", value = jY.Value == true }
        elseif Type == "Slider" then
            return { idx = jX, type = "Slider", value = tostring(jY.Value) }
        elseif Type == "Dropdown" then
            return { idx = jX, type = "Dropdown", multi = jY.Multi == true, value = jY.Value }
        elseif Type == "Input" then
            local wa = jY.Value or ""
            return { idx = jX, type = "Input", text = tostring(wa) }
        elseif Type == "ColorPicker" then
            return { idx = jX, type = "ColorPicker", value = jY.Value:ToHex(), transparency = jY.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = jX,
                type = "KeyPicker",
                mode = jY.Mode,
                key = jY.Value,
                modifiers = jY.Modifiers,
                toggled = jY.Toggled
            }
        else
            return nil
        end
    end
    local function j_()
        local wg = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local wh = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if wh then
                    local wh_1 = jW(k, v)
                    if wh_1 then
                        wg[#wg + 1] = wh_1
                    end
                end
            end
        end
        table.sort(wg, function(j9, ka)
            if j9.type ~= ka.type then
                return j9.type < ka.type
            end
            return j9.idx < ka.idx
        end)
        return { objects = wg }
    end
    local function kb(kc)
        local wA
        wA = nil
        local wB = type(kc) ~= "table" or type(kc.idx) ~= "string" or type(kc.type) ~= "string" or SaveManager.Ignore[kc.idx]
        if wB then
            return false
        end
        wA = jN(kc.type, kc.idx)
        if not wA then
            return false
        end
        local wB_1 = pcall(function()
            if kc.type == "Input" then
                if type(kc.text) ~= "string" then
                    return
                end
                wA:SetValue(kc.text)
            elseif kc.type == "ColorPicker" then
                wA:SetValueRGB(Color3.fromHex(kc.value), kc.transparency)
            elseif kc.type == "KeyPicker" then
                wA:SetValue({ kc.key, kc.mode, kc.modifiers })
                if kc.mode == "Toggle" and kc.toggled ~= nil then
                    wA.Toggled = kc.toggled
                    wA:Update()
                end
            else
                wA:SetValue(kc.value)
            end
        end)
        return wB_1
    end
    jM:AddDivider()
    jM:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    jM:AddButton({
        Text = "Export Config to Clipboard",
        Func = function()
            local wE_1
            local wD_1
            wD_1, wE_1 = pcall(nV.JSONEncode, nV, j_())
            if not wD_1 then
                Library:Notify("Failed to encode the config")
                return
            end
            local wD_2 = setclipboard or toclipboard
            local wD_3 = type(wD_2) ~= "function" or not pcall(wD_2, wE_1)
            if wD_3 then
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Config copied to clipboard", 6)
        end
    })
    jM:AddButton({
        Text = "Import Config from Clipboard Text",
        Func = function()
            local wJ_1
            local wH = Options.SaveManager_ImportSource.Value or ""
            local wH_1
            local wI = tostring(wH):match("^%s*(.-)%s*$")
            if wI == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            wH_1, wJ_1 = pcall(nV.JSONDecode, nV, wI)
            local wI_1 = not wH_1 or type(wJ_1) ~= "table" or type(wJ_1.objects) ~= "table"
            if wI_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            local wH_2 = 0
            for i, v in ipairs(wJ_1.objects) do
                if kb(v) then
                    wH_2 += 1
                end
            end
            if wH_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local wJ_2 = wH_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(wH_2, wJ_2), 6)
        end
    })
end
oB_4()
end)(...)

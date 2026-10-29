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
getgenv().TempoHoodSubtitle = "GARDEN HORIZONS"
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
local rX_2_1
local Options
local lw
local kS
local lz
local kV
local lg
local lC
local kY
local lj
local lF
local kF
local lI
local Shops
local lp
local k3
local kL
local Library
local k6
local kO
local lv
local kR
local worker2
local lc
local kU
local lB
local lf
local worker
local li
local Label
local k_
local lH
local kE
local k2
local lo
local ll
local k5
local LocalPlayer
local connection
local Position
local lb
local ExpansionUtil
local VirtualUser
local Toggles
local kW
local lk
local connection2
local SellExpansionItems
local ln
local kJ
local SellItems
local kM
local connection3
local function fn9(af)
    local mL = Toggles[af]
    return mL ~= nil and mL.Value == true
end
local function onInputChanged(hC)
    local UserInputType = hC.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        lc = tick()
    end
end
local function onRscripts()
    k5(lC, "Copied Rscripts profile to clipboard")
end
local function fn74()
    local Character = LocalPlayer.Character
    local m4 = Character and Character:FindFirstChildOfClass("Humanoid")
    return m4
end
local function onAutoSellIsle(hk)
    if hk then
        lH(true)
    end
end
local function onSellNow2()
    task.spawn(worker, true)
end
local function fn174()
    kO("Gear", false)
end
local function fn176()
    local rb_1
    local ra_1
    if identifyexecutor then
        rb_1, ra_1 = identifyexecutor()
        local rc = rb_1 ~= ""
        local rd = type(rb_1) == "string" and rc
        if rd then
            local rc_1 = type(ra_1) == "string" and ra_1 ~= "" and rb_1 .. " " .. ra_1
            kM = rc_1 or rb_1
        end
    end
end
local function fn184()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    k6 = tick()
end
local function fn190(aq)
    local mR = Options[aq]
    local mS = mR and mR.Value
    local mR_1 = {}
    if type(mS) == "table" then
        for k, v in pairs(mS) do
            if v then
                table.insert(mR_1, k)
            end
        end
    end
    table.sort(mR_1)
    return mR_1
end
local function fn215()
    kO("Seeds", false)
end
local function onAutoBuySeeds(gX)
    if gX then
        lj("Seeds")
    end
end
local function onAutoSell(g9)
    if g9 then
        lH(false)
    end
end
local function fn291()
    kO("Tools", false)
end
local function onAutoBuyGear(g2)
    if g2 then
        lj("Gear")
    end
end
local function fn324(T, U)
    return string.format('<font color="%s">%s</font>', U, T)
end
local function fn329(a7)
    local nj = {}
    for k, v in pairs(a7.ShopData) do
        if v.Name then
            table.insert(nj, v.Name)
        end
    end
    table.sort(nj)
    return nj
end
local function fn330(M, N)
    if setclipboard then
        setclipboard(M)
    elseif toclipboard then
        toclipboard(M)
    end
    Library:Notify(N)
end
local function onInputBegan()
    lc = tick()
end
local function fn407()
    Library.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
local function fn413()
    lk = false
end
local function worker3()
    local rg_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local rf = math.floor(os.clock() - li)
        if rf < 60 then
            rg_1 = rf .. "s"
        elseif rf < 3600 then
            rg_1 = string.format("%dm %ds", math.floor((rf) / (60)), rf % 60)
        else
            rg_1 = string.format("%dh %dm", math.floor((rf) / (3600)), math.floor((rf % 3600) / (60)))
        end
        Label:SetText(kJ("Session time", rg_1, lz))
    end
end
local function onOnClientEvent()
    local rQ = if lp("AutoBuySeeds") then 1 else 0
    if rQ == 1 then
        lj("Seeds")
    end
    if lp("AutoBuyGear") then
        lj("Gear")
    end
    if lp("AutoBuyTools") then
        lj("Tools")
    end
end
local function fn439()
    while true do
        if not lk then
            if Library.Unloaded then
                return false
            end
            lk = true
            return true
        end
        if Library.Unloaded then
            break
        end
        task.wait(0.1)
    end
    return false
end
local function fn456()
    lg(false)
end
local function fn462()
    lv(false)
end
local function fn486(a1, a2)
    local ne = Shops:FindFirstChild(a1)
    if not ne then
        return nil
    end
    return kF(ne:FindFirstChild(a2))
end
local function onBuyNow2()
    task.spawn(worker2, "Gear")
end
local function onBuySeeds()
    if lp("AutoBuySeeds") then
        lj("Seeds")
    end
end
local function onSaveCurrentPosition()
    local ri = lI()
    if not ri then
        return
    end
    Position = ri.Position
    Library:Notify("Saved plant position")
end
local function onBuyNow()
    task.spawn(worker2, "Seeds")
end
local function onUnload()
    Library:Unload()
end
local function fn529()
    local Character = LocalPlayer.Character
    local m1 = Character and Character:FindFirstChild("HumanoidRootPart")
    return m1
end
local function onBuyTools()
    if lp("AutoBuyTools") then
        lj("Tools")
    end
end
local function onCopyJoinScript_JobID()
    local gz = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, lB)
    k5(gz, "Copied join script to clipboard")
end
local function fn566()
    k5(lF, "Copied Discord invite to clipboard")
end
local function onSellNow()
    task.spawn(worker, false)
end
local function worker4()
    while not Library.Unloaded do
        task.wait(2)
        if lp("AntiAfk") then
            local rH = tick() - lc
            local rI = tick() - k6
            if rH >= 300 and rI >= 60 then
                pcall(kW)
            else
                if rH < 300 and rI >= 300 then
                    pcall(kW)
                end
            end
        end
    end
end
local function fn591()
    connection:Disconnect()
    connection2:Disconnect()
    connection3:Disconnect()
    Library.Unloaded = true
end
local function onBuyGear()
    if lp("AutoBuyGear") then
        lj("Gear")
    end
end
local function fn614(aN, aO)
    local m7 = lI()
    if not m7 then
        return false
    end
    local CFrame = m7.CFrame
    m7.CFrame = aN
    task.wait(lb("TeleportSettle", 0.5))
    local m7_1 = pcall(aO)
    if lp("ReturnAfterAction") then
        local m9 = lI()
        if m9 then
            m9.CFrame = CFrame
        end
    end
    return m7_1
end
local function onAutoBuyTools(hd)
    if hd then
        lj("Tools")
    end
end
local function onBuyNow3()
    task.spawn(worker2, "Tools")
end
local function fn687(ak, al)
    local mO = Options[ak]
    local mP = mO and tonumber(mO.Value)
    return mP or al
end
local function fn710(W, X, Y)
    return string.format("<b>%s</b> %s %s", W, kS("-", "#5a6070"), kS(X, Y))
end
kE = nil
kF = nil
Shops = nil
kJ = nil
connection = nil
kL = nil
kM = nil
kO = nil
ExpansionUtil = nil
kR = nil
kS = nil
kU = nil
kV = nil
kW = nil
worker = nil
kY = nil
k_ = nil
SellExpansionItems = nil
k2 = nil
k3 = nil
SellItems = nil
k5 = nil
k6 = nil
connection3 = nil
Options = nil
lb = nil
lc = nil
Toggles = nil
lf = nil
lg = nil
li = nil
lj = nil
lk = nil
ll = nil
ln = nil
lo = nil
lp = nil
local Plots, kH, ExpansionPlotKeys, kP, kT, kZ, k0, k8, HarvestFruit, PlantSeed, GetShopData, PurchaseShopItem, lq
LocalPlayer = nil
Library = nil
Position = nil
lv = nil
lw = nil
VirtualUser = nil
worker2 = nil
lz = nil
lB = nil
lC = nil
Label = nil
lF = nil
connection2 = nil
lH = nil
lI = nil
local lt, lA, CollectionService, lW, ThemeManager, l2
local l5_1
local l3_1, l3_2
local Seeds
local lP_1
lt = nil
lA = nil
CollectionService = nil
CollectionService, VirtualUser, LocalPlayer = nil, nil, nil
local Players = game:GetService("Players")
local rX_1 = game:GetService("ReplicatedStorage")
CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
LocalPlayer = Players.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
PurchaseShopItem, GetShopData, PlantSeed, HarvestFruit, SellItems, SellExpansionItems, lP_1, rX_2_1, ExpansionUtil, ExpansionPlotKeys, Seeds, Shops, Plots, kE, l5_1, lF, lC, Library, ThemeManager, Toggles, Options, l3_1, lz, lk, lW, k5, kY, kS, kJ, lp, lb, kV, lI, lt, lf, k3, k0, kF, lw = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local l1 = rX_1:WaitForChild("RemoteEvents")
PurchaseShopItem = l1:WaitForChild("PurchaseShopItem")
if (not kV or k3 or not lk and lk or (Options and not k3 or (not Options or k3)) or lP_1 and not k3 and (not k3 and not lP_1) and (not Options and not rX_2_1 or not kV and not k3)) and (Options and not lk and (not lk or lk) or lk and lP_1 and (not lP_1 and not lk) or not rX_2_1 and not Options and (not rX_2_1 or not Options) and ((lP_1 or lP_1) and (not kV or kV))) and not ((not kV or k3 or not lk and lk or (Options and not k3 or (not Options or k3)) or lP_1 and not k3 and (not k3 and not lP_1) and (not Options and not rX_2_1 or not kV and not k3)) and (Options and not lk and (not lk or lk) or lk and lP_1 and (not lP_1 and not lk) or not rX_2_1 and not Options and (not rX_2_1 or not Options) and ((lP_1 or lP_1) and (not kV or kV)))) then
    l1 = GetShopData:WaitForChild("GetShopData")
else
    GetShopData = l1:WaitForChild("GetShopData")
end
PlantSeed = l1:WaitForChild("PlantSeed")
HarvestFruit = l1:WaitForChild("HarvestFruit")
SellItems = l1:WaitForChild("SellItems")
SellExpansionItems = l1:WaitForChild("SellExpansionItems")
local lQ = rX_1:WaitForChild("Shop"):WaitForChild("ShopData")
local SeedShopData = require(lQ:WaitForChild("SeedShopData"))
local lO = require(lQ:WaitForChild("GearShopData"))
local CaptainRogerShopData = require(lQ:WaitForChild("CaptainRogerShopData"))
local rX_2_2 = rX_1:WaitForChild("Expansions")
ExpansionUtil = require(rX_2_2:WaitForChild("ExpansionUtil"))
ExpansionPlotKeys = require(rX_2_2:WaitForChild("ExpansionPlotKeys"))
if Options and not Toggles or false or (Options and l5_1 or l5_1 and not Toggles) or not (Options and not Toggles or false or (Options and l5_1 or l5_1 and not Toggles)) then
    Seeds = rX_1:WaitForChild("Plants"):WaitForChild("Tools"):WaitForChild("Seeds")
else
    Seeds:WaitForChild("Plants"):WaitForChild("Tools"):WaitForChild("Seeds")
end
local rX_6_1 = workspace:WaitForChild("MapPhysical")
Shops = rX_6_1:WaitForChild("Shops")
Plots = workspace:WaitForChild("Plots")
kE = "ForgottenIsle"
local l5_2 = "Garden Horizons"
lF = "https://discord.gg/K7Qxnxkk46"
lC = "https://discord.gg/K7Qxnxkk46"
local lT = ""
Library = getgenv().Library
if (not lp or lp) and (k0 and not lp) and (not k0 and not PlantSeed or (not lp or not k0)) or (not PlantSeed or k0 or lp and not k0) and ((k0 or k0) and (lp or PlantSeed)) or not ((not lp or lp) and (k0 and not lp) and (not k0 and not PlantSeed or (not lp or not k0)) or (not PlantSeed or k0 or lp and not k0) and ((k0 or k0) and (lp or PlantSeed))) then
    pcall(fn407)
    ThemeManager = getgenv().ThemeManager
else
    pcall(fn407)
    lT = getgenv().ThemeManager
end
local l_ = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
k5 = fn330
kY = fn566
kS = fn324
kJ = fn710
local l4 = "#7fd47f"
if l3_1 and false and (false and lp) and (PlantSeed and PlantSeed or "#7fd47f") and not (l3_1 and false and (false and lp) and (PlantSeed and PlantSeed or "#7fd47f")) then
    lz = "#6ec1ff"
    l2 = "#e8a34d"
    lb = "#8b93a3"
    l3_2 = fn9
    lp = fn687
else
    l3_2 = "#6ec1ff"
    lz = "#e8a34d"
    l2 = "#8b93a3"
    lp = fn9
    lb = fn687
end
kV = fn190
lI = fn529
lt = fn74
lk = false
lf = fn439
k3 = fn413
k0 = fn614
kF = function(aX)
    local nc_1
    local nb_1
    if not aX then
        return nil
    end
    nb_1, nc_1 = pcall(function()
        return aX:GetPivot()
    end)
    if not nb_1 then
        return nil
    end
    return nc_1 * CFrame.new(0, 3, 4)
end
lw = fn486
local lS = fn329
local lZ = lS(SeedShopData)
local lY = lS(lO)
local lX = lS(CaptainRogerShopData)
if (ExpansionPlotKeys or not SellItems or (l5_2 or ExpansionPlotKeys)) and (not SellItems and SeedShopData or (not ExpansionPlotKeys or not kS)) and ((not SeedShopData and ExpansionPlotKeys or ExpansionPlotKeys) and (kS and false and (ExpansionPlotKeys or l5_2))) and not ((ExpansionPlotKeys or not SellItems or (l5_2 or ExpansionPlotKeys)) and (not SellItems and SeedShopData or (not ExpansionPlotKeys or not kS)) and ((not SeedShopData and ExpansionPlotKeys or ExpansionPlotKeys) and (kS and false and (ExpansionPlotKeys or l5_2)))) then
    lI = {}
else
    lW = {}
end
local lV = {}
for i, child in Seeds:GetChildren() do
    local rX_6_2 = child:GetAttribute("PlantType")
    if rX_6_2 then
        table.insert(lW, child.Name)
        lV[child.Name] = rX_6_2
    end
end
table.sort(lW)
kH = function(bk)
    local ns_1
    local nr_1
    nr_1, ns_1 = pcall(function()
        return GetShopData:InvokeServer(bk)
    end)
    local nt = nr_1 and type(ns_1) == "table" and type(ns_1.Items) == "table"
    if nt then
        return ns_1.Items
    end
    return nil
end
ln = function(bs, bt, bu, bv, bw)
    local nK, nL
    if #bu == 0 then
        if bw then
            Library:Notify("Nothing selected to buy")
        end
        return
    elseif not bt then
        if bw then
            Library:Notify("Shop not loaded yet")
        end
        return
    else
        local nM = kH(bs)
        if not nM then
            if bw then
                Library:Notify("Could not read shop stock")
            end
            return
        end
        nL = {}
        for k, v in bu do
            local nN_1 = nM[v]
            local nN_2 = nN_1 and nN_1.Amount or 0
            if nN_2 > 0 then
                table.insert(nL, { v, nN_2 })
            end
        end
        if #nL == 0 then
            if bw then
                local nN_3 = {}
                for k, v in pairs(nM) do
                    if (v.Amount or 0) > 0 then
                        table.insert(nN_3, k)
                    end
                end
                table.sort(nN_3)
                Library:Notify("None of your picks are in stock. In stock: " .. table.concat(nN_3, ", "), 6)
            end
            return
        end
        nK = 0
        k0(bt, function()
            for k, v in nL do
                local nE = v
                local nv = bv and nE[2]
                local nv_2
                local nw = nv or 1
                local nw_1
                local nH = 1
                while nH <= nw do
                    if Library.Unloaded then
                        return
                    end
                    nv_2, nw_1 = pcall(function()
                        return PurchaseShopItem:InvokeServer(bs, nE[1])
                    end)
                    local nx = not nv_2 or type(nw_1) ~= "table"
                    if nx then
                        break
                    end
                    nK += 1
                    task.wait(0.05)
                    nH += 1
                end
            end
        end)
        if nK > 0 then
            local nN_4 = nK == 1 and "" or "s"
            Library:Notify("Bought " .. nK .. " item" .. nN_4)
        end
        return nK
    end
end
kR = {
    Seeds = { id = "SeedShop", stand = "Seed Shop", npc = "SeedNPC", pick = "BuySeeds" },
    Gear = { id = "GearShop", stand = "Gear Shop", npc = "GearNPC", pick = "BuyGear" },
    Tools = {
        id = "CaptainRogerShop",
        stand = "ForgottenIsleGear Shop",
        npc = "BlacksmithNPC",
        pick = "BuyTools"
    }
}
kO = function(b3, b4)
    local b6 = kR[b3]
    return ln(b6.id, lw(b6.stand, b6.npc), kV(b6.pick), lp("BuyAllStock"), b4)
end
worker2 = function(cc)
    if not lf() then
        return
    end
    pcall(kO, cc, true)
    k3()
end
lj = function(ch)
    task.spawn(function()
        if not lf() then
            return
        end
        pcall(kO, ch, false)
        k3()
    end)
end
kT = function(cq)
    local oi
    oi = nil
    local oo_1
    local on_1
    local om_1
    local ol_1
    oi = {}
    local function oj(ct, cu)
        if not ct or cu == nil then
            return
        end
        for i, child in ct:GetChildren() do
            local n3_1 = child:IsA("Model") and child:GetAttribute("Owner") == cu
            if n3_1 then
                local PlantableArea = child:FindFirstChild("PlantableArea")
                if PlantableArea then
                    for i, child in PlantableArea:GetChildren() do
                        if child:IsA("BasePart") then
                            table.insert(oi, child)
                        end
                    end
                end
            end
        end
    end
    oj(Plots, LocalPlayer.UserId)
    if cq then
        ol_1, om_1 = pcall(ExpansionUtil.GetPlotContainer, kE)
        on_1, oo_1 = pcall(ExpansionPlotKeys.GetKey, LocalPlayer.UserId, kE)
        if ol_1 and on_1 then
            oj(om_1, oo_1)
        end
    end
    return oi
end
k_ = function(cL, cM)
    local ot = RaycastParams.new()
    ot.FilterType = Enum.RaycastFilterType.Include
    ot.FilterDescendantsInstances = cM
    local ou = workspace:Raycast(cL + Vector3.new(0, 15, 0), Vector3.new(0, -40, 0), ot)
    return ou and ou.Position or nil
end
kL = function(cR)
    local Size = cR.Size
    local oA = (math.random() - 0.5) * Size.X * 0.9
    local oB = (math.random() - 0.5) * Size.Y * 0.9
    local oC = (math.random() - 0.5) * Size.Z * 0.9
    if Size.X <= Size.Y and Size.X <= Size.Z then
        oA = 0
    else
        if Size.Y <= Size.X and Size.Y <= Size.Z then
            oB = 0
        else
            oC = 0
        end
    end
    return k_(cR.CFrame * Vector3.new(oA, oB, oC), { cR })
end
Position = nil
lq = function(c0)
    local oJ = Options.PlantMode and Options.PlantMode.Value or "Random"
    if oJ == "Player Position" then
        local oJ_1 = lI()
        if not oJ_1 then
            return nil
        end
        return k_(oJ_1.Position, c0)
    elseif oJ == "Saved Position" then
        if not Position then
            return nil
        end
        return k_(Position, c0)
    else
        return kL(c0[math.random(1, #c0)])
    end
end
kZ = function(da)
    local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local oM = {}
    if Backpack then
        for i, child in Backpack:GetChildren() do
            local oL_1 = child:IsA("Tool") and child:GetAttribute("Type") == "Seeds"
            if oL_1 then
                table.insert(oM, child)
            end
        end
    end
    local Character = LocalPlayer.Character
    if Character then
        for i, child in Character:GetChildren() do
            local oL_3 = child:IsA("Tool") and child:GetAttribute("Type") == "Seeds"
            if oL_3 then
                table.insert(oM, child)
            end
        end
    end
    if #da == 0 then
        return oM[1]
    end
    for k, v in da do
        for k, v2 in oM do
            local oL_4 = v2:GetAttribute("BaseName") == v or v2.Name == v
            if oL_4 then
                return v2
            end
        end
    end
    return nil
end
local function rX_6_3()
    local pc, attr
    local pe = kT(lp("PlantIsle"))
    if #pe == 0 then
        return
    end
    local pf = kZ(kV("PlantSeeds"))
    if not pf then
        return
    end
    attr = pf:GetAttribute("PlantType")
    if not attr then
        return
    end
    local pg = lt()
    if not pg then
        return
    end
    if pf.Parent ~= LocalPlayer.Character then
        pg:EquipTool(pf)
        task.wait(0.15)
    end
    pc = lq(pe)
    if not pc then
        return
    end
    local pe_1 = lI()
    if not pe_1 then
        return
    end
    local CFrame2 = pe_1.CFrame
    local pg_1 = false
    if (pe_1.Position - pc).Magnitude > 10 then
        pe_1.CFrame = CFrame.new(pc + Vector3.new(0, 4, 0))
        pg_1 = true
        task.wait(lb("TeleportSettle", 0.5))
    end
    pcall(function()
        PlantSeed:InvokeServer(attr, pc)
    end)
    local pe_2 = pg_1 and lp("ReturnAfterAction")
    if pe_2 then
        local pe_3 = lI()
        if pe_3 then
            pe_3.CFrame = CFrame2
        end
    end
end
lo = function(dQ)
    local pl = dQ.Parent
    local pm = pl and pl:IsA("BasePart")
    if pm then
        pl = pl.Parent
    end
    local pm_1 = pl and pl:IsA("Model")
    if pm_1 then
        return pl
    end
    return nil
end
k8 = function(dV)
    local pr = lo(dV)
    if not pr then
        return nil
    elseif pr:GetAttribute("HarvestablePlant") == true then
        local attr = pr:GetAttribute("Uuid")
        if attr then
            return { Uuid = attr }
        end
        return nil
    else
        local Parent = pr.Parent
        local pt = Parent and Parent:IsA("Model")
        if not pt then
            return nil
        end
        local attr = Parent:GetAttribute("Uuid")
        if not attr then
            return nil
        end
        return { Uuid = attr, GrowthAnchorIndex = pr:GetAttribute("GrowthAnchorIndex") }
    end
end
kP = function(d2)
    local pv = lo(d2)
    if not pv then
        return false
    end
    local pw = pv
    local px = pv:GetAttribute("OwnerUserId") == nil and pv.Parent and pv.Parent:IsA("Model")
    if px then
        pw = pv.Parent
    end
    return pw:GetAttribute("OwnerUserId") == LocalPlayer.UserId
end
lH = nil
local function rX_2_3()
    local pD = {}
    for k, v in CollectionService:GetTagged("HarvestPrompt") do
        local pE_1 = v:IsA("ProximityPrompt") and v.Enabled and kP(v)
        if pE_1 then
            table.insert(pD, v)
        end
    end
    if #pD == 0 then
        return
    end
    local pE_2 = lI()
    if not pE_2 then
        return
    end
    local CFrame2 = pE_2.CFrame
    local pE_3 = 0
    local pG = {}
    for k, v in pD do
        if Library.Unloaded or pE_3 >= 8 then
            break
        end
        local pH_1 = not pG[v]
        if pH_1 ~= false then
            pH_1 = v.Parent
        end
        if pH_1 then
            local pH_2 = v.Parent:IsA("BasePart") and v.Parent
            local pI = pH_2
            if not pI then
                local pH_3 = v.Parent:IsA("Model") and v.Parent.PrimaryPart
                pI = pH_3
            end
            local pH_4 = pI
            if pI then
                pI = pH_4.Position
            end
            local pH_5 = pI
            local p_ = if pH_5 then 1 else 0
            local pY = 1345 * p_ + 3737 * (1 - p_)
            local pZ = 2238 * p_ + 4071 * (1 - p_)
            if not ((pY * 3623 + pZ * 196 + pY * pZ) % 16777213 == 8321693) then
                local pI_1 = v.Parent:IsA("Model") and v.Parent:GetPivot().Position
                pH_5 = pI_1
            end
            local pI_2 = pH_5
            if pI_2 then
                local pH_6 = lI()
                if pH_6 then
                    pH_6.CFrame = CFrame.new(pI_2 + Vector3.new(0, 5, 0))
                    task.wait(lb("TeleportSettle", 0.5))
                end
                local pC = {}
                local pH_7 = #pD
                local p2 = k
                while p2 <= pH_7 do
                    local pH_8 = pD[p2]
                    local pJ = not pG[pH_8]
                    if pJ ~= false then
                        pJ = pH_8.Parent
                    end
                    if pJ then
                        local pJ_1 = pH_8.Parent:IsA("BasePart") and pH_8.Parent
                        local pK = pJ_1
                        if not pK then
                            local pJ_2 = pH_8.Parent:IsA("Model") and pH_8.Parent.PrimaryPart
                            pK = pJ_2
                        end
                        local pJ_3 = pK
                        if pK then
                            pK = pJ_3.Position
                        end
                        local pJ_4 = pK
                        if not pJ_4 then
                            local pK_1 = pH_8.Parent:IsA("Model") and pH_8.Parent:GetPivot().Position
                            pJ_4 = pK_1
                        end
                        local pK_2 = pJ_4
                        if pJ_4 then
                            pJ_4 = (pK_2 - pI_2).Magnitude <= 25
                        end
                        if pJ_4 then
                            local pJ_5 = k8(pH_8)
                            if pJ_5 then
                                pG[pH_8] = true
                                table.insert(pC, pJ_5)
                            end
                        end
                    end
                    p2 += 1
                end
                if #pC > 0 then
                    pE_3 += 1
                    pcall(function()
                        HarvestFruit:FireServer(pC)
                    end)
                    task.wait(lb("HarvestDelay", 0.35))
                end
            end
        end
    end
    if lp("ReturnAfterAction") then
        local pD_1 = lI()
        if pD_1 then
            pD_1.CFrame = CFrame2
        end
    end
    if pE_3 > 0 and lH then
        lH(false)
    end
end
lA = function()
    local p8 = 0
    local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if Backpack then
        for i, child in Backpack:GetChildren() do
            if child:GetAttribute("IsHarvested") then
                p8 += 1
            end
        end
    end
    local Character = LocalPlayer.Character
    if Character then
        for i, child in Character:GetChildren() do
            if child:GetAttribute("IsHarvested") then
                p8 += 1
            end
        end
    end
    return p8
end
k2 = function(e6, e7, e8)
    local qr = lA()
    local qv = if qr < lb("SellThreshold", 1) then 1 else 0
    if qv == 1 then
        if e8 then
            Library:Notify("Only " .. qr .. " harvested item(s), below the sell threshold")
        end
        return
    end
    local qr_1 = lw(e6, "Steve")
    if not qr_1 then
        if e8 then
            Library:Notify("Sell stand not loaded yet")
        end
        return
    end
    k0(qr_1, function()
        local qo_1
        local qn_1
        qn_1, qo_1 = pcall(e7)
        local qp = qn_1 and type(qo_1) == "string"
        if qp then
            Library:Notify(qo_1, 5)
        elseif e8 then
            Library:Notify("Sell request failed")
        end
    end)
end
lv = function(fn)
    k2("Sell Stand", function()
        return SellItems:InvokeServer("SellAll")
    end, fn)
end
lg = function(fs)
    k2("ForgottenIsleSell Stand", function()
        return SellExpansionItems:InvokeServer(kE, "SellAll")
    end, fs)
end
worker = function(fz)
    if not lf() then
        return
    end
    local qx = fz and lg or lv
    pcall(qx, true)
    k3()
end
lH = function(fE)
    local qD = fE and "AutoSellIsle" or "AutoSell"
    if not lp(qD) then
        return
    end
    task.spawn(function()
        if not lf() then
            return
        end
        local qA = fE and lg or lv
        pcall(qA, false)
        k3()
    end)
end
ll = function()
    local qG_1
    local qF_1
    qF_1, qG_1 = pcall(ExpansionUtil.GetZoneFolder, kE)
    if not qF_1 or not qG_1 then
        return {}
    end
    local Chests = qG_1:FindFirstChild("Chests")
    if not Chests then
        return {}
    end
    local qG_2 = {}
    for i, child in Chests:GetChildren() do
        if child:IsA("Model") then
            table.insert(qG_2, child)
        end
    end
    return qG_2
end
kU = function()
    local ForgottenIsleSell_Stand = Shops:FindFirstChild("ForgottenIsleSell Stand")
    if not ForgottenIsleSell_Stand then
        return nil
    end
    return ForgottenIsleSell_Stand:GetPivot() * CFrame.new(0, 5, 8)
end
rX_1 = function()
    local qS = lI()
    if not qS then
        return
    end
    local CFrame2 = qS.CFrame
    local qU = ll()
    if #qU == 0 then
        local qV = kU()
        if not qV then
            return
        end
        qS.CFrame = qV
        local q1 = 1
        while q1 <= 16 do
            task.wait(0.5)
            qU = ll()
            if #qU > 0 then
                break
            end
            q1 += 1
        end
    end
    if #qU == 0 then
        if lp("ReturnAfterAction") then
            local qS_1 = lI()
            if qS_1 then
                qS_1.CFrame = CFrame2
            end
        end
        return
    end
    for k, v in qU do
        if Library.Unloaded then
            break
        elseif v.Parent then
            local qS_2 = lI()
            if qS_2 then
                qS_2.CFrame = CFrame.new(v:GetPivot().Position + Vector3.new(0, 4, 0))
                task.wait(lb("TreasureDelay", 1.2))
            end
        end
    end
    if lp("ReturnAfterAction") then
        local qS_3 = lI()
        if qS_3 then
            qS_3.CFrame = CFrame2
        end
    end
end
local rX_5_1 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = "https://discord.gg/K7Qxnxkk46 | Garden Horizons",
    Icon = 18657887261,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 8
})
lO = {
    Info = rX_5_1:AddTab("Info", "info"),
    Farm = rX_5_1:AddTab("Farm", "sprout"),
    Shop = rX_5_1:AddTab("Shop", "shopping-cart"),
    Isle = rX_5_1:AddTab("Forgotten Isle", "ship"),
    Settings = rX_5_1:AddTab("Settings", "settings")
}
local function rX_5_2(gi)
    local DiscordGroup = gi:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = kY })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = kY })
end
for k, v in lO do
    rX_5_2(v)
end
kM, Label, lB = nil, nil, nil
kM = "Unknown"
pcall(fn176)
local AccountGroup = lO.Info:AddLeftGroupbox("Account", "circle-user")
AccountGroup:AddLabel(kJ("User", LocalPlayer.Name, l4), true)
AccountGroup:AddLabel(kJ("Status", "Keyless", l4), true)
AccountGroup:AddLabel(kJ("Executor", kM, l4), true)
lS = lO.Info:AddLeftGroupbox("Game Info", "gamepad-2")
lS:AddLabel(kS(l5_2 .. " [" .. tostring(game.PlaceId) .. "]", l3_2), true)
lS:AddLabel(kJ("Place ID", tostring(game.PlaceId), l3_2), true)
Label = lS:AddLabel(kJ("Session time", "0s", lz), true)
lB = tostring(game.JobId)
local lR = #lB > 18
if lR then
    local rX_5_3 = 3
    repeat
        if (rX_5_3 * 1 + 9) * 9 % 4 == ((rX_5_3 * 1 + 9) * 9 + 8) % 4 then
            lR = string.sub(lB, 1, 18) .. "..."
        else
            lB = string.sub(lR, 1, 18) .. "..."
        end
        rX_5_3 = (rX_5_3 + 0) % 4
    until (rX_5_3 * 3 + 2) % 4 == 3
end
local rX_5_4 = lR or lB
li, lc, k6, connection, connection2, connection3, kW = nil, nil, nil, nil, nil, nil, nil
lS:AddLabel(kJ("Server", rX_5_4, l2), true)
lS:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
li = os.clock()
task.spawn(worker3)
local TempoHubGroup = lO.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = kY })
local ScriptsGroup = lO.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(kS("Included in this hub", l2), true)
ScriptsGroup:AddLabel(kS(l5_2, l3_2), true)
local FeaturesGroup = lO.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(kS("Auto Harvest", l3_2), true)
FeaturesGroup:AddLabel(kS("Auto Plant", l3_2), true)
FeaturesGroup:AddLabel(kS("Auto Buy Seeds and Gear", lz), true)
FeaturesGroup:AddLabel(kS("Auto Sell", lz), true)
FeaturesGroup:AddLabel(kS("Forgotten Isle Tools and Treasure", l4), true)
local SocialsGroup = lO.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = kY })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
lR = lO.Info:AddRightGroupbox("FAQ", "circle-help")
lR:AddLabel("Where do I get a good config?", true)
lR:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
lR:AddLabel("How do I import / export configs?", true)
lR:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
lR:AddLabel("How do I report bugs?", true)
lR:AddLabel("Join the Discord and post it in the bugs channel.", true)
lR:AddLabel("How do I make suggestions?", true)
lR:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
lR:AddLabel("How do I get help or updates?", true)
lR:AddLabel("Join the Discord, updates and support are posted there first.", true)
lQ = lO.Farm:AddLeftGroupbox("Harvest", "scissors")
lQ:AddToggle("AutoHarvest", { Text = "Auto Harvest", Default = false })
lQ:AddSlider("HarvestDelay", { Text = "Harvest delay", Default = 0.35, Min = 0.1, Max = 2, Rounding = 2 })
lQ:AddSlider("HarvestInterval", { Text = "Scan interval", Default = 2, Min = 0.5, Max = 15, Rounding = 1 })
local PlantGroup = lO.Farm:AddRightGroupbox("Plant", "sprout")
PlantGroup:AddToggle("AutoPlant", { Text = "Auto Plant", Default = false })
PlantGroup:AddDropdown("PlantMode", {
    Values = { "Player Position", "Saved Position", "Random" },
    Default = "Random",
    Text = "Plant position"
})
PlantGroup:AddDropdown("PlantSeeds", { Values = lW, Default = {}, Multi = true, Text = "Seeds", Searchable = true })
PlantGroup:AddToggle("PlantIsle", { Text = "Include isle plot", Default = false })
PlantGroup:AddSlider("PlantInterval", { Text = "Plant interval", Default = 1, Min = 0.3, Max = 10, Rounding = 1 })
PlantGroup:AddButton({ Text = "Save current position", Func = onSaveCurrentPosition })
local SeedsGroup = lO.Shop:AddLeftGroupbox("Seeds", "leaf")
SeedsGroup:AddToggle("AutoBuySeeds", { Text = "Auto Buy Seeds", Default = false, Callback = onAutoBuySeeds })
SeedsGroup:AddDropdown("BuySeeds", {
    Values = lZ,
    Default = {},
    Multi = true,
    Text = "Seeds",
    Searchable = true,
    Callback = onBuySeeds
})
SeedsGroup:AddButton({ Text = "Buy now", Func = onBuyNow })
local GearGroup = lO.Shop:AddRightGroupbox("Gear", "wrench")
GearGroup:AddToggle("AutoBuyGear", { Text = "Auto Buy Gear", Default = false, Callback = onAutoBuyGear })
GearGroup:AddDropdown("BuyGear", { Values = lY, Default = {}, Multi = true, Text = "Gear", Searchable = true, Callback = onBuyGear })
GearGroup:AddButton({ Text = "Buy now", Func = onBuyNow2 })
local ShopOptionsGroup = lO.Shop:AddLeftGroupbox("Shop Options", "settings-2")
ShopOptionsGroup:AddToggle("BuyAllStock", { Text = "Buy full stock", Default = true })
ShopOptionsGroup:AddSlider("ShopInterval", { Text = "Restock check", Default = 5, Min = 1, Max = 300, Rounding = 0 })
local SellGroup = lO.Shop:AddRightGroupbox("Sell", "coins")
SellGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false, Callback = onAutoSell })
SellGroup:AddSlider("SellThreshold", { Text = "Sell at items", Default = 1, Min = 1, Max = 200, Rounding = 0 })
SellGroup:AddSlider("SellInterval", { Text = "Sell check", Default = 5, Min = 1, Max = 120, Rounding = 0 })
SellGroup:AddButton({ Text = "Sell now", Func = onSellNow })
lT = lO.Isle:AddLeftGroupbox("Tools", "hammer")
lT:AddToggle("AutoBuyTools", { Text = "Auto Buy Tools", Default = false, Callback = onAutoBuyTools })
lT:AddDropdown("BuyTools", {
    Values = lX,
    Default = {},
    Multi = true,
    Text = "Tools",
    Searchable = true,
    Callback = onBuyTools
})
lT:AddButton({ Text = "Buy now", Func = onBuyNow3 })
local TreasureGroup = lO.Isle:AddRightGroupbox("Treasure", "gem")
TreasureGroup:AddToggle("AutoTreasure", { Text = "Auto Find Treasure", Default = false })
TreasureGroup:AddSlider("TreasureDelay", { Text = "Chest wait", Default = 1.2, Min = 0.5, Max = 5, Rounding = 1 })
TreasureGroup:AddSlider("TreasureInterval", { Text = "Sweep interval", Default = 20, Min = 5, Max = 180, Rounding = 0 })
local IsleSellGroup = lO.Isle:AddLeftGroupbox("Isle Sell", "coins")
IsleSellGroup:AddToggle("AutoSellIsle", { Text = "Auto Sell Isle Produce", Default = false, Callback = onAutoSellIsle })
IsleSellGroup:AddButton({ Text = "Sell now", Func = onSellNow2 })
local MenuGroup = lO.Settings:AddLeftGroupbox("Menu", "menu")
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
local MovementGroup = lO.Settings:AddRightGroupbox("Movement", "move")
MovementGroup:AddToggle("ReturnAfterAction", { Text = "Return after teleport", Default = true })
MovementGroup:AddSlider("TeleportSettle", { Text = "Teleport settle", Default = 0.3, Min = 0.1, Max = 2, Rounding = 2 })
lc = tick()
k6 = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local rB = v
        pcall(function()
            rB:Disable()
        end)
    end
end)
kW = fn184
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
task.spawn(worker4)
local function mb(hR, hS, hT, hU)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(lb(hR, hS))
            local rL = not Library.Unloaded and lp(hT)
            if rL then
                if lf() then
                    pcall(hU)
                    k3()
                end
            end
        end
    end)
end
mb("HarvestInterval", 2, "AutoHarvest", rX_2_3)
mb("PlantInterval", 1, "AutoPlant", rX_6_3)
mb("ShopInterval", 5, "AutoBuySeeds", fn215)
mb("ShopInterval", 5, "AutoBuyGear", fn174)
mb("ShopInterval", 5, "AutoBuyTools", fn291)
connection3 = l1:WaitForChild("ShopRestocked").OnClientEvent:Connect(onOnClientEvent)
mb("SellInterval", 5, "AutoSell", fn462)
mb("SellInterval", 5, "AutoSellIsle", fn456)
mb("TreasureInterval", 20, "AutoTreasure", rX_1)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Mint")
ThemeManager:ApplyToTab(lO.Settings)
ThemeManager:LoadDefault()
l_:SetLibrary(Library)
l_:IgnoreThemeSettings()
l_:SetIgnoreIndexes({ "MenuKeybind" })
l_:SetFolder("TempoHub/garden-horizons")
l_:BuildConfigSection(lO.Settings)
l_:LoadAutoloadConfig()
Library:OnUnload(fn591)
end)(...)

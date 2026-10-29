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
getgenv().TempoHoodSubtitle = "TAP 4 MONEY"
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
local jn
local jv
local jq
local CollectionService
local EternityNum
local jE
local ja
local Options
local jw
local jz
local jN
local PlayerGui
local CurrencyClick
local jQ
local jx
local LocalPlayer
local CoreGui
local je
local jh
local jO
local Toggles
local Library
local jR
local jk
local jy
local function fn1(b9, ca)
    for k, v in CollectionService:GetTagged(b9) do
        if v.Name == ca then
            return v
        end
    end
end
local function fn29(aC, aD)
    if setclipboard then
        setclipboard(aC)
    elseif toclipboard then
        toclipboard(aC)
    end
    Library:Notify(aD)
end
local function fn43()
    local attr = PlayerGui:GetAttribute("CurrentWorld")
    local kZ = attr ~= ""
    local k_ = type(attr) == "string" and kZ
    if k_ then
        return attr
    end
    return "Cash"
end
local function worker3()
    while not Library.Unloaded do
        if je("AutoRebirth") then
            jv()
        end
        local nY = if je("AutoPrestige") then 1 else 0
        if nY == 1 then
            jw()
        end
        if je("AutoBuyPrestigeTree") then
            jE()
        end
        if je("AutoBuyUpgrades") then
            ja()
        end
        task.wait(0.25)
    end
end
local function fn80()
    return CoreGui
end
local function worker()
    while Library and not Library.Unloaded do
        jz()
        task.wait(1)
    end
end
local function fn130(bz)
    local lb_1
    local k9 = bz
    local k9_1
    local lg = if k9 then 1 else 0
    local le = 3768 * lg + 3273 * (1 - lg)
    local lf = 1551 * lg + 169 * (1 - lg)
    if not ((le * 2939 + lf * 769 + le * lf) % 16777213 == 1333826) then
        k9 = ""
    end
    local la = tostring(k9):gsub("%s+", "")
    if la == "" then
        return "10000"
    end
    k9_1, lb_1 = pcall(EternityNum.strtobnum, la)
    if k9_1 and lb_1 ~= nil then
        return lb_1
    end
    return "10000"
end
local function worker2()
    while not Library.Unloaded do
        if je("AutoClick") then
            jh()
        end
        task.wait(0.13)
    end
end
local function fn195(au, av)
    return string.format('<font color="%s">%s</font>', av, au)
end
local function fn227(aT)
    local kO = jQ(aT, {})
    if typeof(kO) ~= "table" then
        return {}
    end
    local kP = {}
    for k, v in kO do
        if v == true then
            kP[k] = true
        else
            local kO_1 = typeof(k) == "number" and typeof(v) == "string"
            if kO_1 then
                kP[v] = true
            end
        end
    end
    return kP
end
local function fn243(A)
    if cloneref then
        return cloneref(A)
    end
    return A
end
local function fn356(cV)
    local DiscordGroup = cV:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = jq })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = jq })
end
local function fn602()
    local k1 = jy()
    if k1 == "Tree" then
        pcall(function()
            CurrencyClick:HandleClick(LocalPlayer, "Tree")
        end)
        return
    end
    if k1 == "Gem" then
        jO(jk, "Gem")
        return
    end
    jO(jk, "Cash")
end
local function fn626(aO, aP)
    local kM = Options[aO]
    if kM == nil then
        return aP
    end
    return kM.Value
end
local function fn658()
    jN(jx, "Copied Discord invite to clipboard")
end
local function fn726(ax, ay, az)
    return string.format("<b>%s</b> %s %s", ax, jn("-", "#5a6070"), jn(ay, az))
end
local function fn768(aJ)
    local kJ = Toggles[aJ]
    return kJ ~= nil and kJ.Value == true
end
PlayerGui = nil
Toggles = nil
LocalPlayer = nil
CollectionService = nil
ja = nil
je = nil
jh = nil
jk = nil
CoreGui = nil
jn = nil
jq = nil
CurrencyClick = nil
jv = nil
jw = nil
jx = nil
jy = nil
jz = nil
jE = nil
Library = nil
local Players, i_, i1, i2, SaveManager, i4, i5, i7, ThemeManager, i9, jb, Workspace, jd, TeleportService, jg, ji, jj, jl, jo, RebirthsList, jr, js, HttpService, VirtualUser, jB, Prestige, jD, jF, UserInputService, jI, UpgradeHandler
EternityNum = nil
jN = nil
jO = nil
jQ = nil
jR = nil
Options = nil
local jK, RunService, jP
local jV_1
Players, RunService, UserInputService, VirtualUser, HttpService, CoreGui, jj, TeleportService, Workspace, CollectionService, LocalPlayer, PlayerGui, jR = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if not LocalPlayer or not TeleportService or CollectionService and RunService or (jj and false) or not (not LocalPlayer or not TeleportService or CollectionService and RunService or (jj and false)) then
    Players = game:GetService("Players")
else
    jj = game:GetService("Players")
end
local ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
CoreGui = game:GetService("CoreGui")
jj = game:GetService("GuiService")
TeleportService = game:GetService("TeleportService")
Workspace = game:GetService("Workspace")
CollectionService = game:GetService("CollectionService")
LocalPlayer = Players.LocalPlayer
PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
jR = fn80
if getgenv then
    getgenv().gethui = jR
end
pcall(function()
    gethui = jR
end)
if setthreadidentity then
    setthreadidentity(8)
end
jF, jx, jr, jl, jV_1 = nil, nil, nil, nil, nil
if (not jr or false or false or jr and jx and (not jV_1 or jV_1)) and not (not jr or false or false or jr and jx and (not jV_1 or jV_1)) then
    jr = "Tap 4 Money"
    jF = "https://discord.gg/K7Qxnxkk46"
    jx = "https://discord.gg/K7Qxnxkk46"
else
    jF = "Tap 4 Money"
    jx = "https://discord.gg/K7Qxnxkk46"
    jr = "https://discord.gg/K7Qxnxkk46"
end
if (jx and 22 and (jF and 22) or jV_1 and false and (jr or false) or (not jV_1 and false or false and jx or (jF and not jF or 22))) and not (jx and 22 and (jF and 22) or jV_1 and false and (jr or false) or (not jV_1 and false or false and jx or (jF and not jF or 22))) then
    jr = "https://tempohub.shop"
else
    jl = "https://tempohub.shop"
end
local jV_2 = getgenv and getgenv()
i9 = jV_2 or _G
if i9.__Tempo_Tap4Money then
    return
end
EternityNum, UpgradeHandler, Prestige, CurrencyClick, RebirthsList, jk, jg, jd, i7, i2 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
i9.__Tempo_Tap4Money = true
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
EternityNum = require(Shared:WaitForChild("Modules"):WaitForChild("EternityNum"))
UpgradeHandler = require(Shared:WaitForChild("Upgrades"):WaitForChild("UpgradeHandler"))
Prestige = require(Shared.Upgrades.UpgradeHandler.Prestige)
CurrencyClick = require(Shared:WaitForChild("Util"):WaitForChild("CurrencyClick"))
RebirthsList = require(Shared.resetLayers.RequirementLists.RebirthsList)
jk = fn243(Remotes:WaitForChild("GainCurrency"))
jg = fn243(Remotes:WaitForChild("GetUpgrade"))
jd = fn243(Remotes:WaitForChild("PerformReset"))
i7 = {
    Cash = { category = "Cash", tag = "MoneyUpgrade", ids = { "M1", "M2", "M3", "M4", "M5", "M6" } },
    Prestige = {
        category = "Prestige",
        tag = "PrestigeUpgrade",
        ids = {
            "PU1",
            "PU2",
            "PU3",
            "PU4",
            "PU5",
            "PU6",
            "PU7",
            "PU8",
            "PU9",
            "PU10",
            "PU11",
            "PU12",
            "PU13",
            "PU14",
            "PU15",
            "PU16",
            "PU17",
            "PU18",
            "PU19"
        }
    },
    Gem = { category = "Gem", tag = "GemUpgrade", ids = { "GU1", "GU2", "GU3", "GU4", "GU5", "GU6" } },
    Tree = { category = "Tree", tag = "TreeUpgrade", ids = { "TU1", "TU2", "TU3", "TU4" } },
    Grass = {
        category = "Grass",
        tag = "GrassUpgrade",
        ids = { "GRU1", "GRU1b", "GRU3", "GRU4", "GRU5", "GRU6" }
    },
    Flower = { category = "Flower", tag = "FlowerUpgrade", ids = { "FU1", "FU2", "FU3", "FU4" } },
    Ascension = {
        category = "Ascension",
        tag = "AscensionUpgrade",
        ids = { "AU1", "AU2", "AU3", "AU4", "AU5", "AU6", "AU7", "AU8", "AU9", "AU10", "AU11" }
    }
}
i2 = { "Cash", "Prestige", "Gem", "Tree", "Grass", "Flower", "Ascension" }
local jY = {}
for k, v in i2 do
    jY[v] = true
end
Library, ThemeManager, SaveManager, Toggles, Options, jP, jK, jI, jB, js, jD, i5, ji, jz, jn, jb, jN, jq, je, jQ, jo, jO, jy, jh, jv, i_, jw, i1, i4, jE, ja = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
jz = function()
    local function kp(U)
        local kk = not U or not U:IsA("ScreenGui")
        if kk then
            return
        end
        U.ResetOnSpawn = false
        U.IgnoreGuiInset = true
        U.DisplayOrder = math.max(U.DisplayOrder, 1000)
        pcall(function()
            U.ClipToDeviceSafeArea = false
        end)
        pcall(function()
            U.ScreenInsets = Enum.ScreenInsets.None
        end)
        if U.Parent ~= CoreGui then
            U.Parent = CoreGui
        end
    end
    kp(Library.ScreenGui)
    if Library.ActiveLoading and Library.ActiveLoading.ScreenGui then
        kp(Library.ActiveLoading.ScreenGui)
    end
    for i, v in ipairs({ "Obsidian", "ObsidianLoading" }) do
        local kq_1 = CoreGui:FindFirstChild(v) or PlayerGui:FindFirstChild(v)
        if kq_1 then
            kp(kq_1)
        end
    end
end
jz()
task.spawn(worker)
ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
jP = "#7fd47f"
jK = "#6ec1ff"
jI = "#e8a34d"
jB = "#8b93a3"
js = "#e05a5a"
jn = fn195
jb = fn726
jN = fn29
jq = fn658
je = fn768
jQ = fn626
jo = fn227
jO = function(a0, ...)
    if a0 then
        pcall(function(...)
            a0:FireServer(...)
        end, ...)
    end
end
jy = fn43
jh = fn602
jD = 0
jv = function()
    local k3, k4
    local k6_1
    local k5_1
    if os.clock() - jD < 0.6 then
        return
    end
    k5_1, k6_1 = pcall(function()
        return EternityNum.bnumtofloat(LocalPlayer.Stats.Rebirth.Value)
    end)
    local k7 = not k5_1 or type(k6_1) ~= "number"
    if k7 then
        return
    end
    if EternityNum.meeq(k6_1, 2.5) then
        return
    end
    k4 = RebirthsList[k6_1 + 1]
    if type(k4) ~= "table" then
        return
    end
    k3 = false
    pcall(function()
        k3 = EternityNum.meeq(LocalPlayer.Stats.Cash.Value, k4.Price)
    end)
    if not k3 then
        return
    end
    jD = os.clock()
    jO(jd, "Rebirth")
end
i5 = 0
if jz and jE and "" and ((Library or jE) and false) or (false or not Library) and (false and Library) and ((Library or false) and false) or not (jz and jE and "" and ((Library or jE) and false) or (false or not Library) and (false and Library) and ((Library or false) and false)) then
    i_ = fn130
    jw = function()
        local lk, ll, Value, ln
        if os.clock() - i5 < 0.6 then
            return
        end
        Value = LocalPlayer.Stats.Cash.Value
        lk = false
        pcall(function()
            lk = EternityNum.meeq(Value, 10000)
        end)
        if not lk then
            return
        end
        ll = i_(jQ("PrestigeThreshold", "10000"))
        ln = false
        pcall(function()
            ln = EternityNum.meeq(Value, ll)
        end)
        if not ln then
            return
        end
        i5 = os.clock()
        jO(jd, "Prestige")
    end
else
    jw = fn130
    i_ = function()
        local lk, ll, Value, ln
        if os.clock() - i5 < 0.6 then
            return
        end
        Value = LocalPlayer.Stats.Cash.Value
        lk = false
        pcall(function()
            lk = EternityNum.meeq(Value, 10000)
        end)
        if not lk then
            return
        end
        ll = i_(jQ("PrestigeThreshold", "10000"))
        ln = false
        pcall(function()
            ln = EternityNum.meeq(Value, ll)
        end)
        if not ln then
            return
        end
        i5 = os.clock()
        jO(jd, "Prestige")
    end
end
i1 = function(bY)
    local lp, UnlockedBy
    local lr = Prestige[bY]
    if type(lr) ~= "table" then
        return false
    end
    UnlockedBy = lr.UnlockedBy
    local lr_1 = UnlockedBy == ""
    local ls = type(UnlockedBy) ~= "string"
    local lw = if ls then 1 else 0
    local lu = 3332 * lw + 1550 * (1 - lw)
    local lv = 671 * lw + 2486 * (1 - lw)
    if not ((lu * 1721 + lv * 1650 + lu * lv) % 16777213 == 9077294) then
        ls = lr_1
    end
    if ls then
        return true
    end
    lp = false
    pcall(function()
        lp = EternityNum.meeq(LocalPlayer.Upgrades[UnlockedBy].Value, 0.5)
    end)
    return lp
end
i4 = fn1
jE = function()
    local Prestige = i7.Prestige
    local lG = {}
    for k, v in Prestige.ids do
        local lE
        local lO = v
        if i1(lO) then
            lE = false
            pcall(function()
                lE = UpgradeHandler.canPurchase(LocalPlayer, lO, "Prestige", true) ~= nil
            end)
            if lE then
                lG[#lG + 1] = lO
            end
        end
    end
    if #lG == 0 then
        return
    end
    local lH = lG[math.random(1, #lG)]
    jO(jg, lH, "Prestige", i4(Prestige.tag, lH), true)
end
ja = function()
    local lR = jo("UpgradeList")
    for k, v in i2 do
        if lR[v] then
            local lQ = i7[v]
            if lQ then
                for k, v in lQ.ids do
                    local lP
                    local l4 = v
                    lP = false
                    pcall(function()
                        lP = UpgradeHandler.canPurchase(LocalPlayer, l4, lQ.category, false) ~= nil
                    end)
                    if lP then
                        local lS = i4(lQ.tag, l4)
                        jO(jg, l4, lQ.category, lS, false)
                    end
                end
            end
        end
    end
end
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = jx, Copyable = true }, "|", jF },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
ji = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gamepad-2"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in ji do
    if k ~= "Info" then
        fn356(v)
    end
end
local AutomationGroup = ji.Main:AddLeftGroupbox("Automation", "bot")
AutomationGroup:AddToggle("AutoClick", { Text = "Auto Click", Default = false })
AutomationGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
AutomationGroup:AddDivider("Prestige")
AutomationGroup:AddToggle("AutoPrestige", { Text = "Auto Prestige", Default = false })
AutomationGroup:AddInput("PrestigeThreshold", { Text = "Prestige Threshold", Default = "10000", Numeric = false, Finished = true })
AutomationGroup:AddToggle("AutoBuyPrestigeTree", { Text = "Auto Buy Prestige Tree", Default = false })
AutomationGroup:AddDivider("Upgrades")
AutomationGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
AutomationGroup:AddDropdown("UpgradeList", { Text = "Upgrades", Values = i2, Default = jY, Multi = true, Expandable = true, ExpandColumns = 2 })
local function jW_2()
    local mU
    local m_
    mU = nil
    m_ = nil
    local Label, Label2, Label3, mY, mZ
    local function m0()
        local l5 = hookfunction ~= nil
        local l6 = hookmetamethod ~= nil
        local l7 = getrawmetatable ~= nil
        local l8 = setrawmetatable ~= nil
        local l9 = getgc ~= nil
        local ma = getgenv ~= nil
        local mb = getreg ~= nil
        local mc = getconnections ~= nil
        local md = firesignal ~= nil
        local me = getcallbackvalue ~= nil
        local mf = setclipboard ~= nil
        local mg = getcustomasset ~= nil
        local mh = getnamecallmethod ~= nil
        local mi = isexecutorclosure ~= nil
        local mj = fireproximityprompt ~= nil
        local mk = firetouchinterest ~= nil
        local ml = WebSocket ~= nil
        local mm = readfile ~= nil
        local mn = writefile ~= nil
        local mp = (request or http_request) ~= nil
        local mr = (debug and debug.getupvalues) ~= nil
        local mt = (debug and debug.setupvalue) ~= nil
        local mu = 0
        local mv = { l5, l6, l7, l8, l9, ma, mb, mc, md, me, mf, mg, mh, mi, mj, mk, ml, mm, mn, mp, mr, mt }
        for i, v in ipairs(mv) do
            if v then
                mu += 1
            end
        end
        local l5_1 = mu / #mv
        if l5_1 >= 0.9 then
            return jn("Full Support", jP)
        elseif l5_1 >= 0.6 then
            return jn("Half Support", jI)
        else
            return jn("Low Support", js)
        end
    end
    m_ = "Unknown"
    pcall(function()
        local mE_1
        local mD_1
        if identifyexecutor then
            mE_1, mD_1 = identifyexecutor()
            local mF = mE_1 ~= ""
            local mG = type(mE_1) == "string" and mF
            if mG then
                local mF_1 = type(mD_1) == "string" and mD_1 ~= "" and mE_1 .. " " .. mD_1
                local mD_2 = mF_1
                local mK = if mD_2 then 1 else 0
                local mI = 4052 * mK + 3874 * (1 - mK)
                local mJ = 2551 * mK + 173 * (1 - mK)
                if not ((mI * 2341 + mJ * 635 + mI * mJ) % 16777213 == 4665056) then
                    mD_2 = mE_1
                end
                m_ = mD_2
            end
        end
    end)
    local m1 = m0()
    mU = os.clock()
    mY = function()
        local mL = math.floor(os.clock() - mU)
        if mL < 60 then
            return mL .. "s"
        elseif mL < 3600 then
            return string.format("%dm %ds", math.floor((mL) / (60)), mL % 60)
        else
            return string.format("%dh %dm", math.floor((mL) / (3600)), math.floor((mL % 3600) / (60)))
        end
    end
    local UserGroup = ji.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(jb("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, jP), true)
    UserGroup:AddLabel(jb("UserId", tostring(LocalPlayer.UserId), jK), true)
    UserGroup:AddLabel(jb("Executor", m_ .. "  " .. m1, jP), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(jb("Session", mY(), jI), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            jN(LocalPlayer.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            jN("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = ji.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(jb("Game", jF, jK), true)
    Label2 = SessionGroup:AddLabel(jb("Players", "0/0", jP), true)
    mZ = tostring(game.JobId)
    local m1_1 = #mZ > 18 and string.sub(mZ, 1, 18) .. "..."
    local m1_2 = m1_1 or mZ
    SessionGroup:AddLabel(jb("Job", m1_2, jB), true)
    Label = SessionGroup:AddLabel(jb("Ping", "0 ms", jI), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            jN(mZ, "Copied Job ID")
        end
    })
    task.spawn(function()
        local mR_1
        local mQ_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(jb("Session", mY(), jI))
            Label2:SetText(jb("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), jP))
            mQ_1, mR_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local mQ_2 = mQ_1 and mR_1 .. " ms" or "n/a"
            Label:SetText(jb("Ping", mQ_2, jI))
        end
    end)
    local SocialsGroup = ji.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = jq })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            jN(jr, "Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            jN(jl, "Copied website link")
        end
    })
end
local function jX_1()
    local function ee()
        local Character = LocalPlayer.Character
        local m5 = Character and Character:FindFirstChildOfClass("Humanoid")
        return m5
    end
    local function ej()
        local Character = LocalPlayer.Character
        local nb = Character and Character:FindFirstChild("HumanoidRootPart")
        return nb
    end
    local MovementGroup = ji.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = ji.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local CurrentCamera = Workspace.CurrentCamera
    local connection
    local function et(eu)
        pcall(function()
            jj:SetGameplayPausedNotificationEnabled(not eu)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not eu
            end
        end)
        if not eu then
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
    local function eG(eH)
        if not eH:IsA("ProximityPrompt") then
            return
        end
        eH.HoldDuration = 0
        eH.MaxActivationDistance = 50
        eH.RequiresLineOfSight = false
    end
    RunService.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if je("NoClip") then
            local Character = LocalPlayer.Character
            if Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    local ni_1 = descendant:IsA("BasePart") and descendant.CanCollide
                    if ni_1 then
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
        if je("InfJump") then
            local nq = ee()
            if nq then
                nq:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    RunService.RenderStepped:Connect(function(eX)
        if Library.Unloaded then
            return
        end
        if je("WalkSpeedEnabled") then
            local ns_1 = ee()
            if ns_1 then
                ns_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if je("Fly") then
            local ns_2 = ej()
            local nt = ee()
            if ns_2 and nt then
                nt.PlatformStand = true
                local nt_1 = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    nt_1 += CurrentCamera.CFrame.LookVector
                end
                local ny = if UserInputService:IsKeyDown(Enum.KeyCode.S) then 1 else 0
                if ny == 1 then
                    nt_1 -= CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    nt_1 -= CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    nt_1 += CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    nt_1 += Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    nt_1 -= Vector3.new(0, 1, 0)
                end
                ns_2.AssemblyLinearVelocity = Vector3.zero
                if nt_1.Magnitude > 0 then
                    ns_2.CFrame = ns_2.CFrame + nt_1.Unit * Options.FlySpeed.Value * eX
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local nz = ee()
            if nz then
                nz.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local nE = ee()
            if nE then
                nE.WalkSpeed = 16
            end
        end
    end)
    Toggles.AntiGameplayPause:OnChanged(function()
        et(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if je("AntiGameplayPause") then
                et(true)
            end
        end
    end)
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in ipairs(Workspace:GetDescendants()) do
                pcall(eG, descendant)
            end
            connection = Workspace.DescendantAdded:Connect(function(fr)
                local nK = if je("InstantProximityPrompt") then 1 else 0
                if nK == 1 then
                    pcall(eG, fr)
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    Library:OnUnload(function()
        et(false)
        if connection then
            connection:Disconnect()
            connection = nil
        end
        local nS = ee()
        if nS then
            nS.PlatformStand = false
            nS.WalkSpeed = 16
        end
    end)
end
jW_2()
jX_1()
task.spawn(worker2)
task.spawn(worker3)
local function jV_3()
    local MenuGroup = ji.Settings:AddLeftGroupbox("Menu")
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    local fN = 0
    local fO = tick()
    local Label
    local function fQ()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then
            return
        end
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        fN += 1
        fO = tick()
        if Label then
            pcall(function()
                Label:SetText("AFK triggers: " .. fN)
            end)
        end
    end
    local connection = LocalPlayer.Idled:Connect(function()
        local n3 = if je("AntiAfk") then 1 else 0
        if n3 == 1 then
            pcall(fQ)
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
            local n4 = je("AntiAfk") and tick() - fO >= 60
            if n4 then
                pcall(fQ)
            end
        end
    end)
    Library:OnUnload(function()
        if connection then
            connection:Disconnect()
        end
        i9.__Tempo_Tap4Money = nil
    end)
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("TempoHub")
    ThemeManager:SaveDefault("Evil Hello Kitty")
    ThemeManager:ApplyToTab(ji.Settings)
    ThemeManager:LoadDefault()
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    SaveManager:SetFolder("TempoHub/Tap4Money")
    local gg = SaveManager:BuildConfigSection(ji.Settings)
    local function gh(gi, gj)
        local n8_1 = (gi == "Toggle" and Toggles or Options)[gj]
        local n7_2 = type(n8_1) == "table" and n8_1.Type == gi
        return n7_2 and n8_1 or nil
    end
    local function gq(gr, gs)
        local Type = gs.Type
        if Type == "Toggle" then
            return { idx = gr, type = "Toggle", value = gs.Value == true }
        elseif Type == "Slider" then
            return { idx = gr, type = "Slider", value = tostring(gs.Value) }
        elseif Type == "Dropdown" then
            return { idx = gr, type = "Dropdown", multi = gs.Multi == true, value = gs.Value }
        elseif Type == "Input" then
            local of = gs.Value or ""
            return { idx = gr, type = "Input", text = tostring(of) }
        elseif Type == "ColorPicker" then
            return { idx = gr, type = "ColorPicker", value = gs.Value:ToHex(), transparency = gs.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = gr,
                type = "KeyPicker",
                mode = gs.Mode,
                key = gs.Value,
                modifiers = gs.Modifiers,
                toggled = gs.Toggled
            }
        else
            return nil
        end
    end
    local function gu()
        local oi = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local oj = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if oj then
                    local oj_1 = gq(k, v)
                    if oj_1 then
                        oi[#oi + 1] = oj_1
                    end
                end
            end
        end
        table.sort(oi, function(gD, gE)
            if gD.type ~= gE.type then
                return gD.type < gE.type
            end
            return gD.idx < gE.idx
        end)
        return { objects = oi }
    end
    local function gF(gG)
        local oG
        oG = nil
        local oH = type(gG) ~= "table" or type(gG.idx) ~= "string" or type(gG.type) ~= "string" or SaveManager.Ignore[gG.idx]
        if oH then
            return false
        end
        oG = gh(gG.type, gG.idx)
        if not oG then
            return false
        end
        local oH_1 = pcall(function()
            if gG.type == "Input" then
                if type(gG.text) ~= "string" then
                    return
                end
                oG:SetValue(gG.text)
            elseif gG.type == "ColorPicker" then
                oG:SetValueRGB(Color3.fromHex(gG.value), gG.transparency)
            elseif gG.type == "KeyPicker" then
                oG:SetValue({ gG.key, gG.mode, gG.modifiers })
                if gG.mode == "Toggle" and gG.toggled ~= nil then
                    oG.Toggled = gG.toggled
                    oG:Update()
                end
            else
                oG:SetValue(gG.value)
            end
        end)
        return oH_1
    end
    gg:AddDivider()
    gg:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    gg:AddButton({
        Text = "Export Config to Clipboard",
        Func = function()
            local oK_1
            local oJ_1
            oJ_1, oK_1 = pcall(HttpService.JSONEncode, HttpService, gu())
            if not oJ_1 then
                Library:Notify("Failed to encode the config")
                return
            end
            local oJ_2 = setclipboard or toclipboard
            local oJ_3 = type(oJ_2) ~= "function" or not pcall(oJ_2, oK_1)
            if oJ_3 then
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Config copied to clipboard", 6)
        end
    })
    gg:AddButton({
        Text = "Import Config from Clipboard Field",
        Func = function()
            local oP_1
            local oN = Options.SaveManager_ImportSource.Value or ""
            local oN_1
            local oO = tostring(oN):match("^%s*(.-)%s*$")
            if oO == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            oN_1, oP_1 = pcall(HttpService.JSONDecode, HttpService, oO)
            local oO_1 = not oN_1 or type(oP_1) ~= "table" or type(oP_1.objects) ~= "table"
            if oO_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            local oN_2 = 0
            for i, v in ipairs(oP_1.objects) do
                if gF(v) then
                    oN_2 += 1
                end
            end
            if oN_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local oP_2 = oN_2 == 1 and ""
            local o1 = if oP_2 then 1 else 0
            local o_ = 927 * o1 + 1854 * (1 - o1)
            local o0 = 1475 * o1 + 210 * (1 - o1)
            if not ((o_ * 754 + o0 * 3705 + o_ * o0) % 16777213 == 7531158) then
                oP_2 = "s"
            end
            Library:Notify(("Imported %d setting%s"):format(oN_2, oP_2), 6)
        end
    })
    SaveManager:LoadAutoloadConfig()
end
jV_3()
end)(...)

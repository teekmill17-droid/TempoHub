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
getgenv().TempoHoodSubtitle = "GREEDY GROWERS"
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
local Ur_31, Ur_34, Ur_38, Ur_40, Ur_43, Ur_49, Ur_52, Ur_57, Ur_60, LimitsGroup, Ur_65, Ur_68, Ur_73, Ur_75, AutoBuyFurnitureGroup, Ur_80, Ur_83, CompostGroup, Ur_88, Ur_91, Ur_96, Ur_100, Ur_105, Ur_109, Ur_113, Ur_117, Ur_119, Ur_122
fns.Ur_2 = nil
fns.Ur_3 = nil
fns.Ur_4 = nil
fns.Ur_6 = nil
fns.Ur_8 = nil
fns.Ur_11 = nil
fns.Ur_12 = nil
fns.Constants = nil
fns.Ur_15 = nil
fns.Ur_17 = nil
fns.Options = nil
fns.Ur_22 = nil
fns.Ur_23 = nil
fns.connection = nil
fns.Ur_27 = nil
fns.Ur_29 = nil
Ur_31 = nil
local De
local Ce
local DD
local CD
local BD
local C1
local B1
local Dq
local Bq
local CP
local BP
local Dd
local Label
local DC
local CC
local C0
local B0
local Workspace
local HttpService
local Bp
local CO
local BO
local Dc
local DB
local CB
local BB
local B_
local Do
local Co
local Bo
local DN
local CN
local Db
local SeedConfig
local VirtualUser
local CA
local BA
local CZ
local BZ
local Dn
local Cn
local Bn
local DM
local CM
local BM
local Da
local LocalPlayer
local Dz
local Cz
local Bz
local CY
local BY
local connection2
local DL
local CL
local BL
local C9
local B9
local Dy
local Cy
local By
local CX
local BX
local Cl
local CK
local C8
local B8
local Dx
local Cx
local Bx
local CW
local BW
local Dk
local Ck
local DJ
local CJ
local B7
local Dw
local UserInputService
local Bw
local CV
local BV
local Dj
local Cj
local DI
local CI
local BI
local C6
local B6
local Dv
local Cv
local Bv
local CU
local BU
local Di
local Ci
local DH
local CH
local BH
local C5
local RebirthConfig
local Cu
local Bu
local CT
local BT
local Dh
local Ch
local DG
local BG
local C4
local B4
local Dt
local Ct
local CS
local BS
local Dg
local Cg
local DF
local CF
local BF
function fns.onExportConfigToClipboard()
    local Sr_1
    local Sq_1
    Sq_1, Sr_1 = pcall(HttpService.JSONEncode, HttpService, Ct())
    if not Sq_1 then
        B_:Notify("Failed to encode the config")
        return
    end
    local Sq_2 = setclipboard or toclipboard
    local Sq_3 = type(Sq_2) ~= "function" or not pcall(Sq_2, Sr_1)
    if Sq_3 then
        B_:Notify("Your executor does not support copying to the clipboard")
        return
    end
    B_:Notify("Config copied to clipboard", 6)
end
function fns.fn9()
    local Character = LocalPlayer.Character
    local FZ = Character and Character:FindFirstChildOfClass("Humanoid")
    return FZ
end
function fns.onCopyVenmoLink()
    CZ(By, "Copied Venmo link")
end
function fns.onJumpRequest()
    if B_.Unloaded then
        return
    end
    if C6.InfJump and C6.InfJump.Value then
        local Rr_1 = DM()
        if Rr_1 then
            Rr_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
function fns.fn41(gQ)
    local gR = Vector3.new((math.random() - 0.5) * gQ.Size.X * 0.8, gQ.Size.Y / 2, (math.random() - 0.5) * gQ.Size.Z * 0.8)
    return gQ.CFrame:PointToWorldSpace(gR)
end
function fns.fn103(cV)
    local Gh = C0()
    local Gh_1
    local Gi = not Gh or not Gh.Inventory
    local Gi_1
    if Gi then
        return
    end
    for i, v in ipairs({ { Gh.Inventory.Hotbar, true }, { Gh.Inventory.Storage, false } }) do
        Gh_1, Gi_1 = v[1], v[2]
        local Gk = Gh_1 or {}
        for k, v in Gk do
            if v and v.empty ~= true then
                if cV(v, k, Gi_1) then
                    return
                end
            end
        end
    end
end
function fns.autoRebirthLoop()
    while not B_.Unloaded do
        if C6.AutoRebirth.Value then
            pcall(fns.Ur_12)
        end
        local S6 = fns.Options.RebirthLoopDelay.Value or 5
        task.wait(S6)
    end
end
function fns.onCopyBitcoinAddress()
    CZ(Da, "Copied Bitcoin address")
end
function fns.fn133()
    local FC = C0()
    if not FC or not FC.Inventory then
        return true
    end
    local FE = FC.Inventory.Hotbar or {}
    for k, v in FE do
        if v and v.empty == true then
            return true
        end
    end
    return #(FC.Inventory.Storage or {}) < fns.Constants.STORAGE_MAX_SIZE
end
function fns.onEggTypes(q0)
    DJ = q0
end
function fns.fn173()
    B_.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
function fns.fn174()
    local Mp_1
    local Mo_2
    local Mm = C0()
    local Mm_1
    local Mn = Mm
    local Mn_1
    if Mn then
        Mn = (Mm.ShredProgress or 0) >= BI
    end
    if Mn then
        return
    end
    Mn_1, Mm_1 = Cv()
    if not Mn_1 then
        return
    end
    Mp_1, Mo_2 = B1()
    if not Mp_1 then
        return
    end
    Dy(Mm_1)
    task.wait(0.12)
    local Mw = if not Bo() then 1 else 0
    if Mw == 1 then
        CK(Mo_2, Mp_1, function(lx)
            return lx:GetAttribute("IsSeed") == true
        end)
    end
    B8(Mn_1)
end
function fns.onTreeBlacklist(qE)
    local Qi = {}
    for k, v in qE do
        if v then
            local Qj = BG[k]
            if Qj then
                Qi[Qj] = true
            end
        end
    end
    Cu.treeBlacklist = Qi
end
function fns.autoCollectIndexLoop()
    while not B_.Unloaded do
        if C6.AutoCollectIndex.Value then
            pcall(Bq)
        end
        local Tl = fns.Options.IndexLoopDelay.Value or 3
        task.wait(Tl)
    end
end
function fns.autoBuyEggsLoop()
    while not B_.Unloaded do
        if C6.AutoBuyEggs.Value then
            pcall(fns.Ur_29)
        end
        local S9 = fns.Options.EggLoopDelay.Value or 1
        task.wait(S9)
    end
end
function fns.onCopyEthereumAddress()
    CZ(BL, "Copied Ethereum address")
end
function fns.autoPlantLoop()
    while not B_.Unloaded do
        if C6.AutoPlant.Value then
            pcall(Dj)
        end
        local SS = fns.Options.PlantLoopDelay.Value or 1
        task.wait(SS)
    end
end
function fns.onFindKinds(qT)
    local QA = {}
    for k, v in qT do
        if v then
            QA[k] = true
        end
    end
    Cu.findKinds = QA
end
function fns.onCopyJoinScript_JobID()
    local po = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, Do)
    CZ(po, "Copied join script to clipboard")
end
function fns.fn252()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    BD = tick()
end
function fns.onCompostRarities(qb)
    local PQ = {}
    for k, v in qb do
        if v then
            local PR = B0[k]
            if PR then
                PQ[PR] = true
            end
        end
    end
    Bp = PQ
end
function fns.autoPickupTreesLoop()
    while not B_.Unloaded do
        if C6.AutoPickupTrees.Value then
            pcall(Cg)
        end
        local SY = fns.Options.PickupLoopDelay.Value or 1
        task.wait(SY)
    end
end
function fns.fn268()
    local JK_1, JK_2
    local JJ_1, JJ_2
    local JD = C1()
    if #JD == 0 then
        return true
    end
    local JE = CP()
    local JF = 1
    while true do
        local JG = not B_.Unloaded
        if JG then
            JG = C6.AutoPlantTrees.Value or C6.AutoOrganiseTrees.Value
        end
        if not JG then
            return false
        end
        local JG_1 = Ce(false)
        if not JG_1 then
            break
        end
        local attr = JG_1:GetAttribute("ItemId")
        if not attr then
            return false
        end
        local JG_2 = JE
        local JI = false
        if JG_2 then
            JG_2 = #JE > 0
        end
        if JG_2 then
            local JG_3 = #JE
            local JO = 1
            while JO <= JG_3 do
                local JG_4 = JE[JF]
                JF = JF % #JE + 1
                JJ_1, JK_1 = fns.Ur_8:PlantTree(attr, JG_4, 0):await()
                if JJ_1 and JK_1 then
                    JI = true
                    break
                end
                task.wait(0.1)
                JO += 1
            end
        else
            local JT = 1
            while JT <= 10 do
                local JG_6 = JD[math.random(#JD)]
                JJ_2, JK_2 = fns.Ur_8:PlantTree(attr, fns.Ur_15(JG_6), 0):await()
                if JJ_2 and JK_2 then
                    JI = true
                    break
                end
                task.wait(0.1)
                JT += 1
            end
        end
        if not JI then
            return false
        end
        if C6.PlantNotify.Value then
            B_:Notify("Planted a grown tree")
        end
        task.wait(0.2)
    end
    return true
end
function fns.fn270()
    local Op = BW()
    if not Op then
        return
    end
    local Oq = Bx()
    local Or = Oq and Oq.CFrame
    for i, child in Op:GetChildren() do
        if B_.Unloaded or not C6.AutoCollectFinds.Value then
            break
        elseif child.Name:sub(1, 9) == "PlotFind_" then
            local Op_2 = child:GetAttribute("FindKind") or "Other"
            local Or_1 = tostring(Op_2)
            local Op_3 = Cu.findKinds[Or_1]
            if Op_3 == nil then
                Op_3 = Cu.findKinds.Other
            end
            if Op_3 then
                local Base = child:FindFirstChild("Base")
                local Or_2 = Base and Base:FindFirstChild("FindPrompt")
                local Ot = Or_2 or child:FindFirstChildWhichIsA("ProximityPrompt", true)
                if Ot then
                    if C6.FindsTeleport.Value then
                        local Ot_1 = Base or child
                        Dy(Ot_1)
                        task.wait(0.1)
                    end
                    B8(Ot)
                    local wait = task.wait
                    local Or_4 = fns.Options.FindsActionDelay.Value or 0.15
                    wait(Or_4)
                end
            end
        end
    end
    if C6.FindsTeleport.Value and Oq and Oq.Parent and Or then
        Oq.CFrame = Or
    end
end
function fns.autoEquipItemLoop()
    while not B_.Unloaded do
        if C6.AutoEquipItem.Value then
            pcall(Cu.autoEquip)
        end
        local Tx = fns.Options.EquipLoopDelay.Value or 1
        task.wait(Tx)
    end
end
function fns.fn311(mG)
    local NA = 0
    if type(mG) ~= "table" then
        return 0
    end
    for k, v in mG do
        if v == true then
            NA += 1
        end
    end
    return NA
end
function fns.autoCollectFindsLoop()
    while not B_.Unloaded do
        if C6.AutoCollectFinds.Value then
            pcall(Cu.collectFinds)
        end
        local Tr = fns.Options.FindsLoopDelay.Value or 1
        task.wait(Tr)
    end
end
function fns.fn322()
    local BigField = Workspace:FindFirstChild("BigField")
    local FN = BigField and BigField:FindFirstChild("PlayerPlots")
    if not FN then
        return nil
    end
    for i, child in FN:GetChildren() do
        if child:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return child
        end
    end
    return nil
end
function fns.fn327()
    if not Cl() then
        return
    end
    local M6 = tonumber(fns.Options.EggReserve.Value) or 0
    for k, v in DJ do
        if v then
            local M6_1 = CT[k]
            local M8 = Bu[k] or 0
            local M8_1
            local M9 = M6_1
            local M9_1
            if M9 then
                M9 = DL() - M8 >= M6
            end
            if M9 then
                M8_1, M9_1 = Dw:BuyEgg(M6_1):await()
                if M8_1 and M9_1 and C6.EggNotify.Value then
                    B_:Notify(("Bought %s"):format(k))
                end
                task.wait(0.25)
                if not Cl() then
                    return
                end
            end
        end
    end
end
function fns.fn329(gd)
    local Ib = not gd or gd.empty == true
    local Ii = if Ib then 1 else 0
    local Ig = 2205 * Ii + 1001 * (1 - Ii)
    local Ih = 3955 * Ii + 3806 * (1 - Ii)
    if not ((Ig * 948 + Ih * 242 + Ig * Ih) % 16777213 == 11768225) then
        Ib = not gd.seedType
    end
    if Ib then
        return false
    end
    local itemType = gd.itemType
    return itemType ~= "Seed" and itemType ~= "Fruit" and itemType ~= "Decor" and itemType ~= "Axe" and itemType ~= "Egg" and itemType ~= "Pet" and itemType ~= "Gear"
end
function fns.fn330()
    if Cl() then
        return
    end
    Dn()
    if Cj() > 0 then
        Dg()
    end
end
function fns.fn342()
    local Hg_1
    local He = tonumber(fns.Options.FurnitureReserve.Value) or 0
    local He_2
    for i, v in ipairs(Bz) do
        if B_.Unloaded or not C6.AutoBuyFurniture.Value then
            return
        end
        if CW() - v.price >= He then
            He_2, Hg_1 = Cy:BuyFurniture(v.type, v.id):await()
            if He_2 and Hg_1 and C6.FurnitureNotify.Value then
                B_:Notify(("Bought %s"):format(v.id))
            end
            local wait = task.wait
            local Hg_2 = fns.Options.FurnitureActionDelay.Value or 0.2
            wait(Hg_2)
        end
    end
end
function fns.onPlantWeathers(qq)
    local P7 = {}
    for k, v in qq do
        if v then
            local P8 = Dc[k]
            if P8 then
                P7[P8] = true
            end
        end
    end
    CS = P7
end
function fns.worker()
    local Pw_1
    while true do
        task.wait(1)
        if B_.Unloaded then
            break
        end
        local Pv = math.floor(os.clock() - Dd)
        if Pv < 60 then
            Pw_1 = Pv .. "s"
        elseif Pv < 3600 then
            Pw_1 = string.format("%dm %ds", math.floor((Pv) / (60)), Pv % 60)
        else
            Pw_1 = string.format("%dh %dm", math.floor((Pv) / (3600)), math.floor((Pv % 3600) / (60)))
        end
        Label:SetText(fns.Ur_6("Session time", Pw_1, Dv))
    end
end
function fns.onFurnitureItems(p3)
    local PH = {}
    for k, v in p3 do
        if v then
            local PI = CA[k]
            if PI then
                PH[#PH + 1] = PI
            end
        end
    end
    Bz = PH
end
function fns.fn387()
    return Dz(function(jq)
        return jq.itemType == "Fruit"
    end)
end
function fns.fn414(hX)
    local JX, JY, JZ
    local JW = {}
    local J1 = false
    for i, descendant in hX:GetDescendants() do
        local J0 = 8
        while true do
            if J0 < 7 then
                if J0 < 3 then
                    if J0 < 1 then
                        JZ = JY
                        J0 = 5
                    elseif J0 < 2 then
                        JW[#JW + 1] = descendant
                        J0 = 12
                    else
                        J0 = 12
                    end
                elseif J0 < 5 then
                    if J0 < 4 then
                        JX = descendant.Parent
                        J0 = 6
                    else
                        J0 = if JX.Name == "FruitSpawns" then 1 else 7
                    end
                elseif J0 < 6 then
                    J0 = if JZ then 4 else 2
                else
                    J0 = 14
                end
            elseif J0 < 11 then
                if J0 < 9 then
                    if J0 < 8 then
                        JX = JX.Parent
                        J0 = 13
                    else
                        J0 = if descendant:IsA("ProximityPrompt") then 3 else 10
                    end
                elseif J0 < 10 then
                    J1 = true
                    J0 = 11
                else
                    J0 = 11
                end
            elseif J0 < 13 then
                if J0 < 12 then
                    break
                end
                J0 = 10
            elseif J0 < 14 then
                J0 = 6
            else
                JY = JX ~= hX
                JZ = JX
                J0 = if JZ then 0 else 5
            end
        end
        if J1 then
            break
        end
    end
    return JW
end
function fns.onUnload()
    B_:Unload()
end
function fns.onRenderStepped(rO)
    if B_.Unloaded then
        return
    end
    if C6.WalkSpeedEnabled and C6.WalkSpeedEnabled.Value then
        local Rt_1 = DM()
        if Rt_1 then
            Rt_1.WalkSpeed = fns.Options.WalkSpeed.Value
        end
    end
    if C6.Fly and C6.Fly.Value then
        local Rt_3 = Bx()
        local Ru = DM()
        BY = Workspace.CurrentCamera or BY
        if Rt_3 and Ru and BY then
            Ru.PlatformStand = true
            local Ru_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                Ru_1 = Ru_1 + BY.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                Ru_1 = Ru_1 - BY.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                Ru_1 = Ru_1 - BY.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                Ru_1 = Ru_1 + BY.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                Ru_1 = Ru_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                Ru_1 = Ru_1 - Vector3.new(0, 1, 0)
            end
            Rt_3.Velocity = Vector3.zero
            if Ru_1.Magnitude > 0 then
                Rt_3.CFrame = Rt_3.CFrame + Ru_1.Unit * fns.Options.FlySpeed.Value * rO
            end
        end
    end
end
function fns.fn425(ay, az)
    if setclipboard then
        setclipboard(ay)
    elseif toclipboard then
        toclipboard(ay)
    end
    B_:Notify(az)
end
function fns.fn458()
    local IA, IB, IC, ID
    local Iy = BW()
    if not Iy then
        return {}
    end
    local Iz = {}
    local IG = false
    for i, descendant in Iy:GetDescendants() do
        local IF = 1
        while true do
            if IF < 9 then
                if IF < 4 then
                    if IF < 2 then
                        if IF < 1 then
                            IF = if ID then 5 else 4
                        else
                            IA = (descendant:IsA("BasePart"))
                            local IN = if IA then 1 else 0
                            local IL = 1743 * IN + 652 * (1 - IN)
                            local IM = 2171 * IN + 2762 * (1 - IN)
                            IF = if (IL * 2349 + IM * 2171 + IL * IM) % 16777213 == 12591601 then 16 else 12
                        end
                    elseif IF < 3 then
                        IG = true
                        IF = 17
                    else
                        IF = if not IA then 13 else 15
                    end
                elseif IF < 6 then
                    if IF < 5 then
                        IF = 3
                    else
                        IF = if IB.Name == "SeedPlot" then 11 else 10
                    end
                elseif IF < 7 then
                    IF = 9
                elseif IF < 8 then
                    IA = false
                    IB = descendant.Parent
                    IF = 6
                else
                    IF = 17
                end
            elseif IF < 14 then
                if IF < 11 then
                    if IF < 10 then
                        IC = IB ~= Iy
                        ID = IB
                        IF = if ID then 14 else 0
                    else
                        IB = IB.Parent
                        IF = 18
                    end
                elseif IF < 12 then
                    IA = true
                    IF = 3
                elseif IF < 13 then
                    IF = if IA then 7 else 8
                else
                    Iz[#Iz + 1] = descendant
                    IF = 15
                end
            elseif IF < 16 then
                if IF < 15 then
                    ID = IC
                    IF = 0
                else
                    IF = 8
                end
            elseif IF < 17 then
                IA = descendant.Name == "Dirt"
                IF = 12
            elseif IF < 18 then
                break
            else
                IF = 6
            end
        end
        if IG then
            break
        end
    end
    return Iz
end
function fns.fn495()
    if not C6.WalkSpeedEnabled.Value then
        local Rb = DM()
        if Rb then
            Rb.WalkSpeed = 16
        end
    end
end
function fns.fn519()
    local J6 = BW()
    if not J6 then
        return
    end
    local J7 = C6.HarvestCollectAll.Value and next(Cu.treeBlacklist) == nil
    if J7 then
        pcall(function()
            fns.Ur_8:CollectAllFruits():await()
        end)
    end
    local J7_1 = Bx()
    local J8 = J7_1 and J7_1.CFrame
    for i, child in J6:GetChildren() do
        local J6_1 = child.Name:match("^PlotTree_") and not Cu.treeBlacklist[child:GetAttribute("SeedType")]
        if J6_1 then
            local J6_2 = DN(child)
            if #J6_2 > 0 then
                if C6.HarvestTeleport.Value and J7_1 then
                    local Base = child:FindFirstChild("Base")
                    if Base then
                        J7_1.CFrame = Base.CFrame + Vector3.new(0, 5, 0)
                        task.wait(0.1)
                    end
                end
                for k, v in J6_2 do
                    if B_.Unloaded or not C6.AutoCollectFruit.Value then
                        break
                    end
                    B8(v)
                    local wait = task.wait
                    local J8_3 = fns.Options.HarvestActionDelay.Value or 0.1
                    wait(J8_3)
                end
            end
        end
    end
    if C6.HarvestTeleport.Value and J7_1 and J8 then
        J7_1.CFrame = J8
    end
end
function fns.onMarketRows(q7)
    local QI = {}
    for k, v in q7 do
        if v then
            local QJ = Ur_31[k]
            if QJ then
                QI[QJ] = true
            end
        end
    end
    CI = QI
end
function fns.fn538(jK, jL, jM)
    local LB_1
    local LA_1
    Bn.ToggleEquip:Fire(jK, jL)
    local Lz = tick() + 1
    while tick() < Lz do
        LA_1, LB_1 = pcall(function()
            return Bn.SelectedItemID:Get()
        end)
        if LA_1 and LB_1 == jM then
            return true
        end
        task.wait(0.03)
    end
    return false
end
function fns.onBuySeeds(pV)
    local Py = {}
    for k, v in pV do
        if v then
            local Pz = BG[k]
            if Pz then
                Py[Pz] = true
            end
        end
    end
    CV = Py
end
function fns.onStepped()
    if B_.Unloaded then
        return
    end
    if C6.NoClip and C6.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local Rg_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if Rg_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
function fns.fn596(aI, aJ, aK)
    return string.format("<b>%s</b> %s %s", aI, DH("-", "#5a6070"), DH(aJ, aK))
end
function fns.fn614()
    local Character = LocalPlayer.Character
    if not Character then
        return nil
    end
    for i, child in Character:GetChildren() do
        local Le_1 = child:IsA("Tool") and child:GetAttribute("IsFruit")
        if Le_1 then
            return child
        end
    end
    return nil
end
function fns.onGearItems(q3)
    CB = q3
end
function fns.fn690()
    local KC_1
    local KB = Co()
    local KB_1
    if KB then
        return KB
    end
    KB_1, KC_1 = Dz(function(iC)
        return iC.itemType == "Axe"
    end)
    if not KB_1 then
        return nil
    end
    return CK(KC_1, KB_1, function(iG)
        return iG:GetAttribute("IsAxe") == true
    end)
end
function fns.fn717()
    local LQ = Dz(function(kp)
        return BV(kp)
    end)
    if not LQ then
        return
    end
    local BigField = Workspace:FindFirstChild("BigField")
    local LR = BigField and BigField:FindFirstChild("SellStand")
    if LR then
        Dy(LR)
        task.wait(0.2)
    end
    CF:SellAll():await()
end
function fns.fn724()
    local CurrentWeather = CC:FindFirstChild("CurrentWeather")
    local H1 = CurrentWeather and BU.Normalize(CurrentWeather.Value)
    return H1
end
function fns.autoHarvestLoop()
    while not B_.Unloaded do
        if C6.AutoHarvest.Value or C6.AutoCollectDead.Value or C6.AutoPlant.Value then
            pcall(fns.Ur_27)
        else
            BM = nil
        end
        task.wait(0.5)
    end
end
function fns.onCopySolanaAddress()
    CZ(BA, "Copied Solana address")
end
function fns.antiGameplayPauseLoop()
    while not B_.Unloaded do
        task.wait(1)
        if C6.AntiGameplayPause.Value then
            DB(true)
        end
    end
end
function fns.onInputChanged(st)
    local UserInputType = st.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        C5 = tick()
    end
end
function fns.autoSellAtMaxLoop()
    while not B_.Unloaded do
        if C6.AutoSellAtMax.Value then
            pcall(Dk)
        end
        if C6.AutoSellFruits.Value then
            pcall(Dg)
        end
        if C6.SellDeadTreesOnly.Value then
            pcall(CU)
        elseif C6.AutoSellAll.Value then
            pcall(Dn)
        end
        local S3 = fns.Options.SellLoopDelay.Value or 2
        task.wait(S3)
    end
end
function fns.fn805(dr, ds, du)
    Bn.ToggleEquip:Fire(dr, ds)
    if du then
        return BS(du, 3)
    end
    task.wait(0.2)
    return true
end
function fns.autoBuyGearLoop()
    while not B_.Unloaded do
        if C6.AutoBuyGear.Value then
            pcall(C9)
        end
        local Tc = fns.Options.GearLoopDelay.Value or 2
        task.wait(Tc)
    end
end
function fns.fn823(cN)
    if not cN then
        return
    end
    pcall(fireproximityprompt, cN)
end
function fns.fn844()
    local H5_1
    local H4_2
    local H3 = BM and not BM.stopped and not BM.crashed
    local H3_6
    if H3 then
        return
    end
    if C6.PlantDuringWeatherOnly.Value then
        local H3_1 = Ck()
        if not H3_1 or not CS[H3_1] then
            return
        end
    end
    local H3_2 = Bo()
    if not H3_2 then
        H5_1, H4_2 = Dx()
        if not H5_1 then
            return
        end
        H3_2 = CK(H4_2, H5_1, function(fZ)
            return fZ:GetAttribute("IsSeed") == true
        end)
    end
    if not H3_2 then
        return
    end
    local attr = H3_2:GetAttribute("SeedType")
    if not attr then
        return
    end
    local H5_2 = fns.Options.PlantFertilizer.Value or "None"
    local H3_4 = C0()
    local H6 = H3_4 and H3_4.Rebirth
    local H6_1
    if (H6 or 0) < 1 then
        H5_2 = "None"
    end
    H3_6, H6_1 = CL:StartRound(attr, H5_2):await()
    if H3_6 and H6_1 then
        C4 = nil
        pcall(fns.Ur_27)
        if C6.PlantNotify.Value then
            B_:Notify(("Planted %s"):format(SeedConfig.SeedDisplayName(attr)))
        end
    end
end
function fns.fn846()
    local KK = BW()
    if not KK then
        return
    end
    if not B4() then
        return
    end
    for i, child in KK:GetChildren() do
        if B_.Unloaded or not C6.AutoPickupTrees.Value then
            return
        end
        local KL_1 = child.Name:match("^PlotTree_") and CX(child)
        if KL_1 then
            if not Cl() then
                return
            end
            local KL_2 = CD(KK, child)
            local Base = child:FindFirstChild("Base")
            local KN = Base or child
            Dy(KN)
            task.wait(0.12)
            if not Co() then
                B4()
            end
            B8(KL_2)
            local wait = task.wait
            local KM_1 = fns.Options.PickupActionDelay.Value or 0.25
            wait(KM_1)
        end
    end
end
function fns.fn850()
    fns.connection:Disconnect()
    connection2:Disconnect()
    DB(false)
    local RR = DM()
    if RR then
        RR.PlatformStand = false
        RR.WalkSpeed = 16
    end
end
function fns.fn865(bd)
    return (tostring(bd):gsub("(%a)([%w]*)", function(be, bf)
        return be:upper() .. bf:lower()
    end))
end
function fns.autoBuySeedsLoop()
    while not B_.Unloaded do
        if C6.AutoBuySeeds.Value then
            pcall(DF)
        end
        local SF = fns.Options.BuyLoopDelay.Value or 0.5
        task.wait(SF)
    end
end
function fns.fn889(dh, di)
    local GC = tick()
    local GE = GC + (di or 3)
    local GC_1 = LocalPlayer.Character
    repeat
        if GC_1 then
            for i, child in GC_1:GetChildren() do
                local GD_1 = child:IsA("Tool") and dh(child)
                if GD_1 then
                    return child
                end
            end
        end
        task.wait(0.1)
        GC_1 = LocalPlayer.Character
    until tick() > GE
    return nil
end
function fns.fn910()
    if not Cl() then
        return
    end
    local Nx = tonumber(fns.Options.WormReserve.Value) or 0
    if CW() - C8 < Nx then
        return
    end
    Dq:BuyCanOfWorms():await()
end
function fns.fn911()
    local Character = LocalPlayer.Character
    if not Character then
        return nil
    end
    for i, child in Character:GetChildren() do
        local HN_1 = child:IsA("Tool") and child:GetAttribute("IsSeed")
        if HN_1 then
            return child
        end
    end
    return nil
end
function fns.onPickupRarities(qM)
    local Qr = {}
    for k, v in qM do
        if v then
            local Qs = B0[k]
            if Qs then
                Qr[Qs] = true
            end
        end
    end
    CO = Qr
end
function fns.fn920(bV, bW)
    Cu.equipNames[#Cu.equipNames + 1] = bV
    Cu.equipInfo[bV] = bW
end
function fns.onStorkPets(rg)
    local QR = {}
    for k, v in rg do
        if v then
            QR[k] = true
        end
    end
    Cu.storkPets = QR
end
function fns.fn957()
    return B6.currentData
end
function fns.fn962()
    local Hz = BW()
    local HA = Hz and Hz:FindFirstChild("SeedPlot")
    local Hz_1 = HA
    if HA then
        local HB = (Hz_1:FindFirstChild("PlotTP"))
        local HF = if HB then 1 else 0
        local HD = 878 * HF + 2539 * (1 - HF)
        local HE = 524 * HF + 3411 * (1 - HF)
        if not ((HD * 1328 + HE * 136 + HD * HE) % 16777213 == 1697320) then
            HB = Hz_1:FindFirstChild("Dirt")
        end
        HA = HB
    end
    local HI = if HA then 1 else 0
    local HG = 3586 * HI + 1453 * (1 - HI)
    local HH = 1597 * HI + 2993 * (1 - HI)
    if not ((HG * 3321 + HH * 1598 + HG * HH) % 16777213 == 3410741) then
        HA = Hz_1
    end
    Dy(HA)
end
function fns.fn970(sO, sP)
    local Type = sP.Type
    if Type == "Toggle" then
        return { idx = sO, type = "Toggle", value = sP.Value == true }
    elseif Type == "Slider" then
        return { idx = sO, type = "Slider", value = tostring(sP.Value) }
    elseif Type == "Dropdown" then
        return { idx = sO, type = "Dropdown", multi = sP.Multi == true, value = sP.Value }
    elseif Type == "Input" then
        local RY = sP.Value or ""
        return { idx = sO, type = "Input", text = tostring(RY) }
    elseif Type == "ColorPicker" then
        return { idx = sO, type = "ColorPicker", value = sP.Value:ToHex(), transparency = sP.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = sO,
            type = "KeyPicker",
            mode = sP.Mode,
            key = sP.Value,
            modifiers = sP.Modifiers,
            toggled = sP.Toggled
        }
    else
        return nil
    end
end
function fns.autoCompostSeedsLoop()
    while not B_.Unloaded do
        if C6.AutoCompostSeeds.Value then
            pcall(Bw)
        end
        local SL = fns.Options.CompostLoopDelay.Value or 0.25
        task.wait(SL)
    end
end
function fns.onInputBegan()
    C5 = tick()
end
function fns.fn992()
    if not Cl() then
        return
    end
    local BigField = Workspace:FindFirstChild("BigField")
    local GT = BigField and BigField:FindFirstChild("ConveyorSeeds")
    if not GT then
        return
    end
    for i, child in GT:GetChildren() do
        local attr3 = child:GetAttribute("SpawnId")
        if attr3 and not Cn[attr3] then
            local attr2 = child:GetAttribute("SeedType")
            local attr = child:GetAttribute("Rarity")
            local GV_1
            local GW = attr2 and attr and fns.Ur_4(attr2, attr, child:GetAttribute("Mutation"))
            local GW_1
            if GW then
                GV_1, GW_1 = fns.Ur_11:RequestPurchase(attr3):await()
                if GV_1 and GW_1 then
                    Cn[attr3] = true
                    if C6.BuyNotify.Value then
                        B_:Notify(("Bought %s"):format(SeedConfig.SeedDisplayName(attr2)))
                    end
                    if not Cl() then
                        return
                    end
                end
                local wait = task.wait
                local GU_2 = fns.Options.BuyActionDelay.Value or 0.2
                wait(GU_2)
            end
        end
    end
    for k in pairs(Cn) do
        local GT_3 = false
        for i, child in GT:GetChildren() do
            if child:GetAttribute("SpawnId") == k then
                GT_3 = true
                break
            end
        end
        if not GT_3 then
            Cn[k] = nil
        end
    end
end
function fns.fn1021()
    local Fz = C0()
    if not Fz or not Fz.Currency then
        return 0
    end
    return Fz.Currency[BZ.CURRENCIES.TICKETS] or 0
end
function fns.onCopyPayPalLink()
    CZ(CY, "Copied PayPal link")
end
function fns.onRscripts()
    CZ(De, "Copied Rscripts profile to clipboard")
end
function fns.onCopyUSDTAddress()
    CZ(fns.Ur_2, "Copied USDT address")
end
function fns.autoFeedPetsLoop()
    while not B_.Unloaded do
        if C6.AutoFeedPets.Value then
            pcall(Db)
        end
        local To = fns.Options.FeedLoopDelay.Value or 2
        task.wait(To)
    end
end
function fns.fn1082(ek)
    local el = math.max(0, Workspace:GetServerTimeNow() - ek)
    return math.max(0, math.floor((math.exp(el * 0.28) - 1) * 100) / 100)
end
function fns.fn1085()
    local Fw = C0()
    if not Fw or not Fw.Currency then
        return 0
    end
    return Fw.Currency[BZ.CURRENCIES.COINS] or 0
end
function fns.onEquipItems(ro)
    local QZ = {}
    for k, v in ro do
        if v then
            QZ[k] = true
        end
    end
    Cu.equipWanted = QZ
end
function fns.onCopyLitecoinAddress()
    CZ(BT, "Copied Litecoin address")
end
function fns.fn1134(dz, dA, dB)
    if C6.BuyMutatedOnly.Value and (dB == nil or dB == "") then
        return false
    end
    local GN_1 = SeedConfig.GetSeed(dz)
    local GO_3 = GN_1 and GN_1.plantCost or 0
    local GN_3 = tonumber(fns.Options.BuyMaxCost.Value) or 0
    if GN_3 > 0 and GO_3 > GN_3 then
        return false
    end
    local GN_5 = tonumber(fns.Options.BuyReserve.Value) or 0
    if CW() - GO_3 < GN_5 then
        return false
    end
    local Value = fns.Options.BuyMode.Value
    if Value == "Buy All" then
        return true
    elseif Value == "Selected Seeds" then
        return CV[dz] == true
    else
        local GN_7 = B0[fns.Options.BuyMinRarity.Value]
        local GO_4 = B7[dA]
        local GP_3 = B7[GN_7]
        if not GO_4 or not GP_3 then
            return false
        end
        return GO_4 >= GP_3
    end
end
function fns.autoBuyFurnitureLoop()
    while not B_.Unloaded do
        if C6.AutoBuyFurniture.Value then
            pcall(Cx)
        end
        local SI = fns.Options.FurnitureLoopDelay.Value or 1
        task.wait(SI)
    end
end
function fns.autoCollectFruitLoop()
    while not B_.Unloaded do
        if C6.AutoCollectFruit.Value then
            pcall(Dt)
        end
        local S0 = fns.Options.HarvestLoopDelay.Value or 1
        task.wait(S0)
    end
end
function fns.fn1206(iI)
    local attr = iI:GetAttribute("SeedType")
    local KF = fns.Ur_22(attr)
    if not KF then
        return false
    end
    return CO[KF] == true
end
function fns.fn1211()
    local Lq = BW()
    if not Lq then
        return nil
    end
    local SellFruits = Lq:FindFirstChild("SellFruits")
    if SellFruits then
        return SellFruits
    end
    for i, descendant in Lq:GetDescendants() do
        local Lq_1 = descendant:IsA("ProximityPrompt") and descendant.ActionText == "Sell"
        if Lq_1 then
            return descendant.Parent
        end
    end
    return nil
end
function fns.onSetTreeSpotToMyPosition()
    local Qg = Bx()
    if not Qg then
        B_:Notify("Could not read your position, spawn in first")
        return
    end
    DD = Qg.Position
    fns.Options.TreePlaceMode:SetValue("Set Spot")
    B_:Notify(("Tree spot set to %.1f, %.1f, %.1f. Placement switched to Set Spot."):format(DD.X, DD.Y, DD.Z), 6)
end
function fns.fn1242()
    local Character = LocalPlayer.Character
    local FW = Character and Character:FindFirstChild("HumanoidRootPart")
    return FW
end
function fns.fn1254()
    local KV = BW()
    if not KV then
        return
    end
    local KW = false
    for i, child in KV:GetChildren() do
        if child.Name:match("^PlotTree_") then
            KW = true
            break
        end
    end
    local KX = KW and B4()
    if KX then
        for i, child in KV:GetChildren() do
            local KW_1 = B_.Unloaded
            local K1 = if KW_1 then 1 else 0
            local K_ = 920 * K1 + 1193 * (1 - K1)
            local K0 = 1529 * K1 + 2723 * (1 - K1)
            if not ((K_ * 1862 + K0 * 2503 + K_ * K0) % 16777213 == 6946807) then
                KW_1 = not C6.AutoOrganiseTrees.Value
            end
            if KW_1 then
                return
            end
            if child.Name:match("^PlotTree_") then
                local KW_2 = CD(KV, child)
                local Base = child:FindFirstChild("Base")
                local KY = Base or child
                Dy(KY)
                task.wait(0.12)
                if not Co() then
                    B4()
                end
                B8(KW_2)
                task.wait(0.2)
            end
        end
        task.wait(0.3)
    end
    local KV_1 = CJ()
    if KV_1 and C6.AutoOrganiseTrees.Value then
        C6.AutoOrganiseTrees:SetValue(false)
        B_:Notify("Auto Organise Trees complete")
    end
end
function fns.fn1287()
    local R0 = {}
    for i, v in ipairs({ C6, fns.Options }) do
        for k, v in pairs(v) do
            local R1 = type(v) == "table" and type(v.Type) == "string" and not BP.Ignore[k]
            if R1 then
                local R1_1 = CH(k, v)
                if R1_1 then
                    R0[#R0 + 1] = R1_1
                end
            end
        end
    end
    table.sort(R0, function(s2, s3)
        if s2.type ~= s3.type then
            return s2.type < s3.type
        end
        return s2.idx < s3.idx
    end)
    return { objects = R0 }
end
function fns.onImportConfigFromClipboardTex()
    local Sw_1
    local Su = fns.Options.SaveManager_ImportSource.Value or ""
    local Su_1
    local Sv = tostring(Su):match("^%s*(.-)%s*$")
    if Sv == "" then
        B_:Notify("Paste an exported config into the box first")
        return
    end
    Su_1, Sw_1 = pcall(HttpService.JSONDecode, HttpService, Sv)
    local Sv_1 = not Su_1 or type(Sw_1) ~= "table" or type(Sw_1.objects) ~= "table"
    if Sv_1 then
        B_:Notify("That is not a valid exported config")
        return
    end
    local Su_2 = 0
    for i, v in ipairs(Sw_1.objects) do
        if BH(v) then
            Su_2 += 1
        end
    end
    if Su_2 == 0 then
        B_:Notify("No settings in that config matched this script")
        return
    end
    fns.Options.SaveManager_ImportSource:SetValue("")
    local Sw_2 = Su_2 == 1 and "" or "s"
    B_:Notify(("Imported %d setting%s"):format(Su_2, Sw_2), 6)
end
function fns.fn1297(n0, n1)
    if n0.itemType ~= n1.itemType then
        return false
    elseif n1.seedType then
        return n0.seedType == n1.seedType
    elseif n1.eggId then
        return (n0.eggId or n0.eggType or n0.egg) == n1.eggId
    elseif n1.petType then
        return (n0.petType or n0.pet) == n1.petType
    else
        return true
    end
end
function fns.fn1303()
    local LU_2
    local LT_5
    if C6.SellTeleport.Value then
        local BigField = Workspace:FindFirstChild("BigField")
        local LU_1 = BigField and BigField:FindFirstChild("SellStand")
        Dy(LU_1)
        task.wait(0.2)
    end
    while true do
        if not B_.Unloaded and C6.SellDeadTreesOnly.Value then
            local LT_4 = Ce(true)
            if not LT_4 then
                return
            end
            LT_5, LU_2 = CF:SellTree():await()
            if not LT_5 or not LU_2 then
                break
            end
            local wait = task.wait
            local LU_3 = fns.Options.SellActionDelay.Value or 0.2
            wait(LU_3)
            continue
        end
        return
    end
    return
end
function fns.fn1315()
    local L1 = C0()
    if not L1 then
        return
    end
    local L2 = L1.Rebirth
    local L7 = if L2 then 1 else 0
    local L5 = 2235 * L7 + 2055 * (1 - L7)
    local L6 = 904 * L7 + 3581 * (1 - L7)
    if not ((L5 * 2523 + L6 * 2599 + L5 * L6) % 16777213 == 10008841) then
        L2 = 0
    end
    local L1_1 = L2
    local L2_1 = tonumber(fns.Options.RebirthMaxLevel.Value) or RebirthConfig.MaxLevel
    if L1_1 >= L2_1 then
        return
    end
    local L2_2 = RebirthConfig.GetNext(L1_1)
    local L3 = not L2_2 or CW() < L2_2.cost
    if L3 then
        return
    end
    DC:DoRebirth():await()
    if C6.RebirthNotify.Value then
        B_:Notify(("Rebirthed to %d"):format(L1_1 + 1))
    end
end
function fns.fn1326()
    DB(C6.AntiGameplayPause.Value)
end
function fns.fn1330(cP)
    local Ge = cP and SeedConfig.GetSeed(cP)
    local Gf = Ge
    if Ge then
        Ge = Gf.rarity
    end
    return Ge
end
function fns.fn1339()
    if not C6.Fly.Value then
        local Q6 = DM()
        if Q6 then
            Q6.PlatformStand = false
        end
    end
end
function fns.fn1340()
    local HJ = BM
    if HJ and HJ.crashed then
        if C6.AutoCollectDead.Value and C4 ~= HJ.roundId then
            Ch()
            task.wait(0.15)
            pcall(function()
                CL:CollectDeadTree()
            end)
            task.wait(0.35)
            pcall(fns.Ur_27)
            if not BM or BM.roundId ~= HJ.roundId or not BM.crashed then
                C4 = HJ.roundId
            end
        end
        return
    end
    if not HJ then
        return
    end
    if HJ.stopped or C4 == HJ.roundId or not C6.AutoHarvest.Value then
        return
    end
    local HK_4 = tonumber(fns.Options.HarvestMultiplier.Value) or 2
    local HK_5 = BB(HJ.startTime)
    if HK_5 < HK_4 then
        return
    end
    C4 = HJ.roundId
    local HJ_1 = CL:StopPlant():await()
    if HJ_1 and C6.HarvestNotify.Value then
        B_:Notify(("Harvested at %.2fx"):format(HK_5))
    end
end
function fns.autoFarmersMarketLoop()
    while not B_.Unloaded do
        if C6.AutoFarmersMarket.Value then
            pcall(Dh)
        elseif C6.AutoClaimMarket.Value then
            pcall(B9)
        end
        local Ti = fns.Options.MarketLoopDelay.Value or 2
        task.wait(Ti)
    end
end
function fns.fn1396()
    local Character = LocalPlayer.Character
    if not Character then
        return nil
    end
    for i, child in Character:GetChildren() do
        local Kt_1 = child:IsA("Tool") and child:GetAttribute("IsAxe")
        if Kt_1 then
            return child
        end
    end
    return nil
end
function fns.onPlantSeeds(qj)
    local PZ = {}
    for k, v in qj do
        if v then
            local P_ = BG[k]
            if P_ then
                PZ[P_] = true
            end
        end
    end
    Bv = PZ
end
function fns.autoBuyWormsLoop()
    while not B_.Unloaded do
        if C6.AutoBuyWorms.Value then
            pcall(fns.Ur_3)
        end
        local Tf = fns.Options.WormLoopDelay.Value or 2
        task.wait(Tf)
    end
end
function fns.fn1446()
    local L8 = BW()
    local L9 = L8 and L8:FindFirstChild("CompostBin")
    if not L9 then
        return nil, nil
    end
    local PromptPart = L9:FindFirstChild("PromptPart")
    local Ma = PromptPart and PromptPart:FindFirstChild("CompostPrompt")
    local Mb = Ma or L9:FindFirstChildWhichIsA("ProximityPrompt", true)
    local Ma_1 = PromptPart
    local Mf = if Ma_1 then 1 else 0
    local Md = 856 * Mf + 3077 * (1 - Mf)
    local Me = 2948 * Mf + 2675 * (1 - Mf)
    if not ((Md * 672 + Me * 1583 + Md * Me) % 16777213 == 7765404) then
        Ma_1 = L9
    end
    return Mb, Ma_1
end
function fns.antiAfkLoop()
    while not B_.Unloaded do
        task.wait(2)
        if C6.AntiAfk.Value then
            local Uh = tick() - C5
            local Ui = tick() - BD
            if Uh >= 300 and Ui >= 60 then
                pcall(CM)
            else
                if Uh < 300 and Ui >= 300 then
                    pcall(CM)
                end
            end
        end
    end
end
function fns.fn1472()
    CZ(BX, "Copied Discord invite to clipboard")
end
function fns.fn1479()
    local Hq_1
    local Hp_1
    Hp_1, Hq_1 = CL:GetActiveRounds():await()
    local Hr = not Hp_1 or type(Hq_1) ~= "table"
    if Hr then
        return
    end
    for k, v in Hq_1 do
        if v.userId == LocalPlayer.UserId then
            BM = v
            return
        end
    end
    BM = nil
end
function fns.fn1486(gp)
    local Character = LocalPlayer.Character
    if not Character then
        return nil
    end
    for i, child in Character:GetChildren() do
        local Il_1 = child:IsA("Tool") and child:GetAttribute("IsTree") and child:GetAttribute("IsDead") == true == gp
        if Il_1 then
            return child
        end
    end
    return nil
end
function fns.fn1498(cI)
    local F3 = Bx()
    if not F3 or not cI then
        return
    end
    if typeof(cI) == "CFrame" then
        F3.CFrame = cI + Vector3.new(0, 5, 0)
    elseif typeof(cI) == "Vector3" then
        F3.CFrame = CFrame.new(cI + Vector3.new(0, 5, 0))
    elseif typeof(cI) == "Instance" then
        if cI:IsA("BasePart") then
            F3.CFrame = cI.CFrame + Vector3.new(0, 5, 0)
        elseif cI:IsA("Model") then
            local pivot = cI:GetPivot()
            F3.CFrame = pivot + Vector3.new(0, 5, 0)
        end
    end
end
function fns.fn1499(iO, iP)
    local KH = iP.Name:gsub("^PlotTree_", "")
    local KI = iO:FindFirstChild("TreeBasePrompt_" .. KH)
    local KH_1 = KI and KI:FindFirstChildWhichIsA("ProximityPrompt")
    return KH_1
end
function fns.fn1535()
    local IO = C1()
    local IQ = {}
    for i, v in ipairs(IO) do
        local IO_1 = v.Size.X * 0.8
        local IR = v.Size.Z * 0.8
        local IS = math.max(1, math.floor(IO_1 / 4))
        local IT = math.max(1, math.floor(IR / 4))
        local IU = IS - 1
        local I5 = 0
        while I5 <= IU do
            local I6 = I5
            local IU_1 = IT - 1
            local Ja = 0
            while Ja <= IU_1 do
                local Jb = Ja
                local IV = IS == 1 and 0 or (I6 / (IS - 1) - 0.5) * IO_1
                local IV_2 = IT == 1 and 0 or (Jb / (IT - 1) - 0.5) * IR
                IQ[#IQ + 1] = v.CFrame:PointToWorldSpace(Vector3.new(IV, v.Size.Y / 2, IV_2))
                Ja += 1
            end
            I5 += 1
        end
    end
    return IQ
end
function fns.fn1540()
    return Dz(function(lf)
        if lf.itemType ~= "Seed" or not lf.seedType then
            return false
        end
        local Mg_1 = fns.Ur_22(lf.seedType)
        return Mg_1 and Bp[Mg_1] == true
    end)
end
function fns.fn1606(o7)
    local DiscordGroup = o7:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = CN })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = CN })
end
function fns.fn1608()
    local Nm_1
    local Ni = C0()
    local Nk = Ni and Ni.OwnedGear or {}
    local Nj_1 = tonumber(fns.Options.GearReserve.Value) or 0
    for k, v in CB do
        if v then
            local Nj_2 = fns.Ur_23[k]
            if Nj_2 then
                local Nl = Nj_2.isTool and Nk[Nj_2.id]
                local Nl_1
                if not Nl then
                    if CW() - Nj_2.price >= Nj_1 then
                        Nl_1, Nm_1 = Ci:BuyGear(Nj_2.id):await()
                        if Nl_1 and Nm_1 and C6.GearNotify.Value then
                            B_:Notify(("Bought %s"):format(k))
                        end
                        task.wait(0.25)
                    end
                end
            end
        end
    end
end
function fns.autoHarvestLoop2()
    while not B_.Unloaded do
        if C6.AutoHarvest.Value or C6.AutoCollectDead.Value then
            pcall(BO)
        end
        task.wait(0.05)
    end
end
function fns.fn1702(aF, aG)
    return string.format('<font color="%s">%s</font>', aG, aF)
end
function fns.fn1728()
    local LL_1
    local LK_1
    local LJ_2
    local LG = Cj()
    local LH = (tonumber(fns.Options.SellMinFruits.Value))
    local LP = if LH then 1 else 0
    local LN = 1106 * LP + 1267 * (1 - LP)
    local LO = 1957 * LP + 895 * (1 - LP)
    if not ((LN * 1675 + LO * 400 + LN * LO) % 16777213 == 4799792) then
        LH = 1
    end
    if LG < LH then
        return
    end
    local LG_1 = Di()
    if C6.SellTeleport.Value and LG_1 then
        Dy(LG_1)
        task.wait(0.2)
    end
    local LG_2 = nil
    local LH_2 = 0
    while true do
        local LI = not B_.Unloaded
        if LI then
            LI = C6.AutoSellFruits.Value or C6.AutoSellAtMax.Value
        end
        if LI then
            local LI_1 = Cj()
            if LI_1 == 0 then
                break
            end
            LK_1, LJ_2, LL_1 = Cz()
            if not LK_1 then
                break
            elseif LL_1 ~= LG_2 then
                if not BF(LJ_2, LK_1, LL_1) then
                    break
                end
                LG_2 = LL_1
                pcall(function()
                    DG:SellFruit()
                end)
                local wait = task.wait
                local LK_2 = fns.Options.SellActionDelay.Value or 0.2
                wait(LK_2)
                if Cj() >= LI_1 then
                    LH_2 += 1
                    if LH_2 >= 3 then
                        break
                    end
                    continue
                end
                LH_2 = 0
                continue
            else
                pcall(function()
                    DG:SellFruit()
                end)
                local wait = task.wait
                local LK_3 = fns.Options.SellActionDelay.Value or 0.2
                wait(LK_3)
                if Cj() >= LI_1 then
                    LH_2 += 1
                    if LH_2 >= 3 then
                        break
                    end
                    continue
                end
                LH_2 = 0
                continue
            end
        else
            break
        end
    end
end
function fns.autoOrganiseTreesLoop()
    while not B_.Unloaded do
        if C6.AutoOrganiseTrees.Value then
            pcall(fns.Ur_17)
        elseif C6.AutoPlantTrees.Value then
            pcall(CJ)
        end
        local SV = fns.Options.PlantLoopDelay.Value or 1
        task.wait(SV)
    end
end
function fns.fn1741()
    local Po_1
    local Pn_1
    if identifyexecutor then
        Po_1, Pn_1 = identifyexecutor()
        local Pp = Po_1 ~= ""
        local Pq = type(Po_1) == "string" and Pp
        if Pq then
            local Pp_1 = type(Pn_1) == "string" and Pn_1 ~= "" and Po_1 .. " " .. Pn_1
            local Pn_2 = Pp_1
            local Pu = if Pn_2 then 1 else 0
            local Ps = 1223 * Pu + 4044 * (1 - Pu)
            local Pt = 1376 * Pu + 3417 * (1 - Pu)
            if not ((Ps * 4095 + Pt * 1652 + Ps * Pt) % 16777213 == 8964185) then
                Pn_2 = Po_1
            end
            DI = Pn_2
        end
    end
end
function fns.autoStorkLoop()
    while not B_.Unloaded do
        if C6.AutoStork.Value then
            pcall(Cu.giveToStork)
        end
        local Tu = fns.Options.StorkLoopDelay.Value or 3
        task.wait(Tu)
    end
end
function fns.fn1755(sG, sH)
    local RU_1 = (sG == "Toggle" and C6 or fns.Options)[sH]
    local RT_2 = type(RU_1) == "table" and RU_1.Type == sG
    return RT_2 and RU_1 or nil
end
Bn = nil
Bo = nil
Bp = nil
Bq = nil
fns.Ur_27 = nil
fns.Ur_8 = nil
Bu = nil
Bv = nil
Bw = nil
Bx = nil
By = nil
Bz = nil
BA = nil
BB = nil
BD = nil
fns.Options = nil
BF = nil
BG = nil
BH = nil
BI = nil
BL = nil
BM = nil
BO = nil
BP = nil
Ur_31 = nil
fns.Ur_12 = nil
BS = nil
BT = nil
BU = nil
BV = nil
BW = nil
BX = nil
BY = nil
BZ = nil
B_ = nil
B0 = nil
B1 = nil
fns.Ur_22 = nil
fns.Ur_3 = nil
B4 = nil
RebirthConfig = nil
B6 = nil
B7 = nil
B8 = nil
B9 = nil
local Bt, IndexInfo, BJ, BK, PetConfig
LocalPlayer = nil
SeedConfig = nil
Label = nil
Ce = nil
Cg = nil
Ch = nil
Ci = nil
Cj = nil
Ck = nil
Cl = nil
Cn = nil
Co = nil
HttpService = nil
fns.connection = nil
fns.Ur_6 = nil
Ct = nil
Cu = nil
Cv = nil
UserInputService = nil
Cx = nil
Cy = nil
Cz = nil
CA = nil
CB = nil
CC = nil
CD = nil
fns.Ur_17 = nil
CF = nil
CH = nil
CI = nil
CJ = nil
CK = nil
CL = nil
CM = nil
CN = nil
CO = nil
CP = nil
fns.Ur_29 = nil
fns.Ur_11 = nil
CS = nil
CT = nil
CU = nil
CV = nil
CW = nil
CX = nil
local Cc, CoreGui, Cm, Cq, CG
CY = nil
CZ = nil
C0 = nil
C1 = nil
fns.Ur_2 = nil
C4 = nil
C5 = nil
C6 = nil
C8 = nil
C9 = nil
Da = nil
Db = nil
Dc = nil
Dd = nil
De = nil
fns.Constants = nil
Dg = nil
Dh = nil
Di = nil
Dj = nil
Dk = nil
connection2 = nil
Dn = nil
Do = nil
Workspace = nil
Dq = nil
fns.Ur_23 = nil
fns.Ur_4 = nil
Dt = nil
Dv = nil
Dw = nil
Dx = nil
Dy = nil
Dz = nil
VirtualUser = nil
DB = nil
DC = nil
DD = nil
fns.Ur_15 = nil
DF = nil
DG = nil
DH = nil
DI = nil
DJ = nil
local C_, C2, C7, Dl, GuiService, DK
DL = nil
DM = nil
DN = nil
CC, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, LocalPlayer = nil, nil, nil, nil, nil, nil, nil, nil
local Ur_47 = game:GetService("Players")
CC = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
LocalPlayer = Ur_47.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
Ur_34, Ur_60, BX, De, BT, Da, BL, fns.Ur_2, BA, CY, By, Ur_88, Ur_43, Ur_96, Ur_52, Ur_105, Ur_73, Ur_113, Ur_80, Ur_122, Dv, fns.Ur_18, fns.Ur_7, SeedConfig, Ur_109, RebirthConfig, Ur_68, BZ, fns.Constants, BU, Ur_100, PetConfig, Ur_75, IndexInfo, Ur_91, Ur_83, fns.Ur_11, fns.Ur_8, CL, Bn, CF, DG, Cy, DC, Cq, Dw, Ci, Dq, Cc, Dl, B6, Ur_38, B_, Ur_57, BP, C6, fns.Options, Ur_117, B7, Ur_65, B0, CZ, CN, DH, fns.Ur_6 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Ur_47 = 65
repeat
    Ur_49 = (Ur_47 * 23 + 8) % 34 + 1
    if Ur_49 <= 17 then
        if Ur_49 <= 9 then
            if Ur_49 <= 5 then
                if Ur_49 <= 3 then
                    if Ur_49 <= 2 then
                        if Ur_49 <= 1 then
                            Ur_40 = (vector.create((Ur_47 * 1 + 4) % 11 + 1, (Ur_47 * 5 + 1) % 13 + 1, (Ur_47 * 1 + 11) % 17 + 1))
                            fns.Ur_30 = (vector.create((Ur_47 * 5 + 3) % 11 + 1, (Ur_47 * 10 + 5) % 13 + 1, (Ur_47 * 2 + 4) % 17 + 1))
                            fns.Ur_10 = (vector.create((Ur_47 * 1 + 3) % 5 + 1, (Ur_47 * 5 + 1) % 7 + 1, (Ur_47 * 3 + 7) % 9 + 1))
                            if math.abs((vector.angle(Ur_40, fns.Ur_30, fns.Ur_10))) - math.abs((vector.angle(fns.Ur_30, Ur_40, fns.Ur_10))) == 2 then
                                CF = fns.fn1472
                            else
                                CN = fns.fn1472
                            end
                            Ur_47 = (Ur_47 + 241) % 272
                        else
                            if (Ur_47 * 3 + 2) * 5 % 4 == ((Ur_47 * 3 + 2) * 5 + 9) % 4 then
                                Ur_83 = fns.fn1702
                            else
                                DH = fns.fn1702
                            end
                            Ur_47 = (Ur_47 + 173) % 272
                        end
                    else
                        Ur_40 = (vector.create((Ur_47 * 7 + 9) % 11 + 1, (Ur_47 * 6 + 9) % 13 + 1, (Ur_47 * 14 + 15) % 17 + 1))
                        fns.Ur_30 = (vector.create((Ur_47 * 2 + 4) % 11 + 1, (Ur_47 * 11 + 2) % 13 + 1, (Ur_47 * 7 + 2) % 17 + 1))
                        fns.Ur_10 = (vector.create((Ur_47 * 6 + 5) % 11 + 1, (Ur_47 * 1 + 12) % 13 + 1, (Ur_47 * 3 + 7) % 17 + 1))
                        Ur_119 = (vector.create((Ur_47 * 2 + 5) % 11 + 1, (Ur_47 * 7 + 7) % 13 + 1, (Ur_47 * 7 + 14) % 17 + 1))
                        if vector.dot(vector.cross(Ur_40, fns.Ur_30), (vector.cross(fns.Ur_10, Ur_119))) == vector.dot(Ur_40, fns.Ur_10) * vector.dot(fns.Ur_30, Ur_119) - vector.dot(Ur_40, Ur_119) * vector.dot(fns.Ur_30, fns.Ur_10) then
                            fns.Ur_6 = fns.fn596
                        else
                            Ur_109 = fns.fn596
                        end
                        Ur_47 = (Ur_47 + 139) % 272
                    end
                elseif Ur_49 <= 4 then
                    Ur_40 = { "dxrjx", "xpmionxt", "hnd", "yeo", "rhpwmgce", "zhault", "esm", "vjlfajanui", "wby" }
                    local XH = Ur_47
                    fns.Ur_30 = Ur_40[XH % 9 + 1]
                    if fns.Ur_30:len() >= fns.Ur_30:reverse():rep(XH % 3 + 2):len() then
                        DC = {
                            "ANCIENT",
                            "MYTHIC",
                            "DIVINE",
                            "TRANSCENDENT",
                            "CELESTIAL",
                            "LEGENDARY",
                            "UNCOMMON",
                            "COMMON",
                            "RARE",
                            "EPIC",
                            "SECRET"
                        }
                    else
                        Ur_117 = {
                            "COMMON",
                            "UNCOMMON",
                            "RARE",
                            "EPIC",
                            "LEGENDARY",
                            "MYTHIC",
                            "CELESTIAL",
                            "SECRET",
                            "DIVINE",
                            "TRANSCENDENT",
                            "ANCIENT"
                        }
                    end
                    Ur_47 = (Ur_47 + 71) % 272
                else
                    local XL = bit32.rrotate(bit32.bxor(bit32.lrotate(Ur_47, 2), string.byte(tostring(fns.Constants))), 17)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(XL, 87196989), 6), 1285640001) == bit32.lrotate(XL, 6) then
                        B7 = {}
                    else
                        fns.Ur_11 = {}
                    end
                    Ur_47 = (Ur_47 + 139) % 272
                end
            elseif Ur_49 <= 7 then
                if Ur_49 <= 6 then
                    local Zu = bit32.rrotate(bit32.bxor(bit32.lrotate(Ur_47, 19), string.byte(tostring(Ur_100))), 7)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(Zu, 805056308), 16), 791949308) == bit32.lrotate(Zu, 16) then
                        Ur_65 = {}
                    else
                        BU = {}
                    end
                    Ur_47 = (Ur_47 + 3) % 272
                else
                    if Ur_47 * 79203929 + 2 + 5 <= Ur_47 * 79203929 + 2 + 5 + 3 then
                        B0 = {}
                    else
                        Cy = {}
                    end
                    Ur_47 = (Ur_47 + 173) % 272
                end
            elseif Ur_49 <= 8 then
                if (Ur_47 * 2 + 7) * 13 % 3 == ((Ur_47 * 2 + 7) * 13 + 8) % 3 then
                    Ur_60 = "Greedy Growers"
                    Ur_34 = "v0.1"
                else
                    Ur_34 = "Greedy Growers"
                    Ur_60 = "v0.1"
                end
                Ur_47 = (Ur_47 + 3) % 272
            else
                local Xe = bit32.rrotate(bit32.bxor(bit32.lrotate(Ur_47, 26), string.byte(tostring(DC))), 7)
                if bit32.bxor(bit32.lrotate(bit32.bxor(Xe, 3303234474), 26), 2870185326) == bit32.lrotate(Xe, 26) then
                    BX = "https://discord.gg/K7Qxnxkk46"
                else
                    Ur_38 = "https://discord.gg/K7Qxnxkk46"
                end
                Ur_47 = (Ur_47 + 71) % 272
            end
        elseif Ur_49 <= 13 then
            if Ur_49 <= 11 then
                if Ur_49 <= 10 then
                    Ur_40 = (vector.create((Ur_47 * 5 + 1) % 11 + 1, (Ur_47 * 6 + 1) % 13 + 1, (Ur_47 * 14 + 17) % 17 + 1))
                    fns.Ur_30 = (vector.create((Ur_47 * 6 + 5) % 11 + 1, (Ur_47 * 11 + 2) % 13 + 1, (Ur_47 * 14 + 11) % 17 + 1))
                    local Xb = vector.cross(Ur_40, fns.Ur_30)
                    local Xc = vector.dot(Ur_40, fns.Ur_30)
                    if vector.dot(Xb, Xb) + Xc * Xc == vector.dot(Ur_40, Ur_40) * vector.dot(fns.Ur_30, fns.Ur_30) then
                        De = "https://discord.gg/K7Qxnxkk46"
                        BT = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
                        Da = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
                    else
                        Da = "https://discord.gg/K7Qxnxkk46"
                        De = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
                        BT = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
                    end
                    Ur_47 = (Ur_47 + 71) % 272
                else
                    Ur_40 = (vector.create((Ur_47 * 7 + 3) % 11 + 1, (Ur_47 * 2 + 9) % 13 + 1, (Ur_47 * 9 + 2) % 17 + 1))
                    fns.Ur_30 = (vector.create((Ur_47 * 3 + 8) % 11 + 1, (Ur_47 * 5 + 6) % 13 + 1, (Ur_47 * 8 + 10) % 17 + 1))
                    fns.Ur_10 = (vector.create((Ur_47 * 5 + 2) % 11 + 1, (Ur_47 * 11 + 11) % 13 + 1, (Ur_47 * 12 + 6) % 17 + 1))
                    Ur_119 = (vector.create((Ur_47 * 4 + 9) % 11 + 1, (Ur_47 * 11 + 10) % 13 + 1, (Ur_47 * 11 + 16) % 17 + 1))
                    if vector.dot(vector.cross(Ur_40, fns.Ur_30), (vector.cross(fns.Ur_10, Ur_119))) == vector.dot(Ur_40, fns.Ur_10) * vector.dot(fns.Ur_30, Ur_119) - vector.dot(Ur_40, Ur_119) * vector.dot(fns.Ur_30, fns.Ur_10) + 3 then
                        BA = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                        CY = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                        fns.Ur_2 = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
                        BL = ""
                    else
                        BL = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                        fns.Ur_2 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                        BA = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
                        CY = ""
                    end
                    Ur_47 = (Ur_47 + 173) % 272
                end
            elseif Ur_49 <= 12 then
                if (Ur_47 * 2 + 1) * 10 % 3 == ((Ur_47 * 2 + 1) * 10 + 3) % 3 then
                    By = ""
                    Ur_88 = "#345d9d"
                    Ur_43 = "#f7931a"
                    Ur_96 = "#627eea"
                    Ur_52 = "#26a17b"
                else
                    Ur_52 = ""
                    Ur_43 = "#345d9d"
                    Ur_88 = "#f7931a"
                    By = "#627eea"
                    Ur_96 = "#26a17b"
                end
                Ur_47 = (Ur_47 + 173) % 272
            else
                Ur_40 = (vector.create((Ur_47 * 2 + 5) % 11 + 1, (Ur_47 * 7 + 5) % 13 + 1, (Ur_47 * 11 + 11) % 17 + 1))
                local XK = vector.floor(Ur_40) + vector.ceil(Ur_40 * -1)
                if vector.dot(XK, XK) == 1 then
                    Ur_80 = "#14f195"
                    Ur_105 = "#0070ba"
                    Ur_73 = "#008cff"
                    Ur_113 = "#7fd47f"
                else
                    Ur_105 = "#14f195"
                    Ur_73 = "#0070ba"
                    Ur_113 = "#008cff"
                    Ur_80 = "#7fd47f"
                end
                Ur_47 = (Ur_47 + 105) % 272
            end
        elseif Ur_49 <= 15 then
            if Ur_49 <= 14 then
                Ur_40 = (vector.create((Ur_47 * 2 + 9) % 11 + 1, (Ur_47 * 7 + 7) % 13 + 1, (Ur_47 * 9 + 2) % 17 + 1))
                fns.Ur_30 = (vector.create((Ur_47 * 2 + 7) % 11 + 1, (Ur_47 * 10 + 9) % 13 + 1, (Ur_47 * 12 + 3) % 17 + 1))
                local Xf = vector.cross(Ur_40, fns.Ur_30)
                local Xg = vector.dot(Ur_40, fns.Ur_30)
                if vector.dot(Xf, Xf) + Xg * Xg == vector.dot(Ur_40, Ur_40) * vector.dot(fns.Ur_30, fns.Ur_30) then
                    Ur_122 = "#6ec1ff"
                    Dv = "#e8a34d"
                else
                    Dv = "#6ec1ff"
                    Ur_122 = "#e8a34d"
                end
                Ur_47 = (Ur_47 + 105) % 272
            else
                Ur_40 = (vector.create((Ur_47 * 3 + 8) % 11 + 1, (Ur_47 * 10 + 3) % 13 + 1, (Ur_47 * 12 + 7) % 17 + 1))
                fns.Ur_30 = (vector.create((Ur_47 * 3 + 7) % 11 + 1, (Ur_47 * 8 + 5) % 13 + 1, (Ur_47 * 8 + 8) % 17 + 1))
                fns.Ur_10 = (vector.create((Ur_47 * 4 + 5) % 11 + 1, (Ur_47 * 5 + 9) % 13 + 1, (Ur_47 * 3 + 9) % 17 + 1))
                Ur_119 = (vector.create((Ur_47 * 2 + 4) % 11 + 1, (Ur_47 * 7 + 10) % 13 + 1, (Ur_47 * 8 + 8) % 17 + 1))
                if vector.dot(vector.cross(Ur_40, fns.Ur_30), (vector.cross(fns.Ur_10, Ur_119))) == vector.dot(Ur_40, fns.Ur_10) * vector.dot(fns.Ur_30, Ur_119) - vector.dot(Ur_40, Ur_119) * vector.dot(fns.Ur_30, fns.Ur_10) + 5 then
                    CY = "#8b93a3"
                else
                    fns.Ur_18 = "#8b93a3"
                end
                Ur_47 = (Ur_47 + 207) % 272
            end
        elseif Ur_49 <= 16 then
            if (Ur_47 * 3 + 1) * 13 % 4 == ((Ur_47 * 3 + 1) * 13 + 11) % 4 then
                CC = require(fns.Ur_7:WaitForChild("Packages"):WaitForChild("Knit"))
            else
                fns.Ur_7 = require(CC:WaitForChild("Packages"):WaitForChild("Knit"))
            end
            Ur_47 = (Ur_47 + 139) % 272
        else
            Ur_40 = (vector.create((Ur_47 * 4 + 1) % 11 + 1, (Ur_47 * 4 + 1) % 13 + 1, (Ur_47 * 7 + 12) % 17 + 1))
            fns.Ur_30 = (vector.create((Ur_47 * 5 + 6) % 11 + 1, (Ur_47 * 1 + 7) % 13 + 1, (Ur_47 * 9 + 14) % 17 + 1))
            fns.Ur_10 = (vector.create((Ur_47 * 1 + 7) % 11 + 1, (Ur_47 * 5 + 11) % 13 + 1, (Ur_47 * 7 + 3) % 17 + 1))
            Ur_119 = (vector.create((Ur_47 * 3 + 1) % 11 + 1, (Ur_47 * 3 + 2) % 13 + 1, (Ur_47 * 7 + 17) % 17 + 1))
            if vector.dot(vector.cross(Ur_40, fns.Ur_30), (vector.cross(fns.Ur_10, Ur_119))) == vector.dot(Ur_40, fns.Ur_10) * vector.dot(fns.Ur_30, Ur_119) - vector.dot(Ur_40, Ur_119) * vector.dot(fns.Ur_30, fns.Ur_10) + 2 then
                CC = require(SeedConfig.Shared.Info.SeedConfig)
            else
                SeedConfig = require(CC.Shared.Info.SeedConfig)
            end
            Ur_47 = (Ur_47 + 71) % 272
        end
    elseif Ur_49 <= 26 then
        if Ur_49 <= 22 then
            if Ur_49 <= 20 then
                if Ur_49 <= 19 then
                    if Ur_49 <= 18 then
                        if Ur_47 * 102657275 + 8 + 3 >= Ur_47 * 102657275 + 8 + 3 + 2 then
                            CC = require(RebirthConfig.Shared.Info.ExpandedRarities)
                            Ur_109 = require(RebirthConfig.Shared.Info.RebirthConfig)
                        else
                            Ur_109 = require(CC.Shared.Info.ExpandedRarities)
                            RebirthConfig = require(CC.Shared.Info.RebirthConfig)
                        end
                        Ur_47 = (Ur_47 + 105) % 272
                    else
                        if Ur_47 * 45976611 + 6 + 5 <= Ur_47 * 45976611 + 6 + 5 + 1 then
                            Ur_68 = require(CC.Shared.Info.FertilizerConfig)
                        else
                            CC = require(Ur_68.Shared.Info.FertilizerConfig)
                        end
                        Ur_47 = (Ur_47 + 105) % 272
                    end
                else
                    local Yu = bit32.rrotate(bit32.bxor(bit32.lrotate(Ur_47, 16), string.byte(tostring(Ur_75))), 18)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(Yu, 561055525), 0), 561055525) == bit32.lrotate(Yu, 0) then
                        BZ = require(CC.Shared.Info.CustomEnum)
                        fns.Constants = require(CC.Shared.Info.Constants)
                    else
                        CC = require(fns.Constants.Shared.Info.CustomEnum)
                        BZ = require(fns.Constants.Shared.Info.Constants)
                    end
                    Ur_47 = (Ur_47 + 71) % 272
                end
            elseif Ur_49 <= 21 then
                Ur_40 = (vector.create((Ur_47 * 6 + 1) % 11 + 1, (Ur_47 * 9 + 8) % 13 + 1, (Ur_47 * 12 + 14) % 17 + 1))
                fns.Ur_30 = (vector.create((Ur_47 * 4 + 3) % 11 + 1, (Ur_47 * 8 + 1) % 13 + 1, (Ur_47 * 10 + 13) % 17 + 1))
                local XW = vector.cross(Ur_40, fns.Ur_30)
                local XX = vector.dot(Ur_40, fns.Ur_30)
                if vector.dot(XW, XW) + XX * XX == vector.dot(Ur_40, Ur_40) * vector.dot(fns.Ur_30, fns.Ur_30) then
                    BU = require(CC.Shared.Info.WeatherConfig)
                else
                    CC = require(BU.Shared.Info.WeatherConfig)
                end
                Ur_47 = (Ur_47 + 37) % 272
            else
                if (Da or not CY or not Ur_38 and not Da) and (not Ur_38 or Ur_38 or Ur_38 and CY) and not ((Da or not CY or not Ur_38 and not Da) and (not Ur_38 or Ur_38 or Ur_38 and CY)) then
                    CC = require(Ur_100.Shared.Info.FurnitureShopConfig)
                else
                    Ur_100 = require(CC.Shared.Info.FurnitureShopConfig)
                end
                Ur_47 = (Ur_47 + 105) % 272
            end
        elseif Ur_49 <= 24 then
            if Ur_49 <= 23 then
                local Xl = bit32.rrotate(bit32.bxor(bit32.lrotate(Ur_47, 3), string.byte(tostring(Ur_73))), 14)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(Xl, 4258944535), 1058918460), (bit32.bxor(bit32.band(Xl, 36022760), 1978199649))), 1058918460), 1978199649) ~= Xl then
                    CC = require(PetConfig.Shared.Info.PetConfig)
                else
                    PetConfig = require(CC.Shared.Info.PetConfig)
                end
                Ur_47 = (Ur_47 + 71) % 272
            else
                if (Ur_47 * 3 + 8) * 21 % 4 == ((Ur_47 * 3 + 8) * 21 + 8) % 4 then
                    Ur_75 = require(CC.Shared.Info.GearConfig)
                else
                    CC = require(Ur_75.Shared.Info.GearConfig)
                end
                Ur_47 = (Ur_47 + 139) % 272
            end
        elseif Ur_49 <= 25 then
            if Ur_47 * 55504927 + 8 + 6 >= Ur_47 * 55504927 + 8 + 6 + 5 then
                CC = require(IndexInfo.Shared.Info.IndexInfo)
            else
                IndexInfo = require(CC.Shared.Info.IndexInfo)
            end
            Ur_47 = (Ur_47 + 207) % 272
        else
            local Xs = bit32.rrotate(bit32.bxor(bit32.lrotate(Ur_47, 22), string.byte(tostring(C6))), 4)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(Xs, 3657121209), 1340874148), (bit32.bxor(bit32.band(Xs, 637846086), 2342511928))), 1340874148), 2342511928) == Xs then
                Ur_91 = require(CC.Shared.Info.FarmersMarketConfig)
            else
                CC = require(Ur_91.Shared.Info.FarmersMarketConfig)
            end
            Ur_47 = (Ur_47 + 139) % 272
        end
    elseif Ur_49 <= 30 then
        if Ur_49 <= 28 then
            if Ur_49 <= 27 then
                Ur_40 = (vector.create((Ur_47 * 4 + 6) % 11 + 1, (Ur_47 * 10 + 4) % 13 + 1, (Ur_47 * 15 + 14) % 17 + 1))
                fns.Ur_30 = (vector.create((Ur_47 * 2 + 3) % 11 + 1, (Ur_47 * 8 + 1) % 13 + 1, (Ur_47 * 3 + 9) % 17 + 1))
                fns.Ur_10 = (vector.create((Ur_47 * 7 + 7) % 11 + 1, (Ur_47 * 11 + 2) % 13 + 1, (Ur_47 * 2 + 17) % 17 + 1))
                Ur_119 = (vector.create((Ur_47 * 2 + 5) % 5 + 1, (Ur_47 * 5 + 7) % 7 + 1, (Ur_47 * 4 + 5) % 9 + 1))
                if vector.dot(vector.cross(Ur_40, (vector.cross(fns.Ur_30, fns.Ur_10))), Ur_119) == vector.dot(fns.Ur_30 * vector.dot(Ur_40, fns.Ur_10) - fns.Ur_10 * vector.dot(Ur_40, fns.Ur_30), Ur_119) then
                    Ur_83 = require(CC.Shared.Utility.AbbreviateNumber)
                    fns.Ur_11 = fns.Ur_7.GetService("SeedConveyorService")
                    fns.Ur_8 = fns.Ur_7.GetService("PlayerPlotService")
                    CL = fns.Ur_7.GetService("PlantRoundService")
                    Bn = fns.Ur_7.GetService("ToolService")
                else
                    fns.Ur_8 = require(Ur_83.Shared.Utility.AbbreviateNumber)
                    CC = CL.GetService("SeedConveyorService")
                    fns.Ur_11 = CL.GetService("PlayerPlotService")
                    Bn = CL.GetService("PlantRoundService")
                    fns.Ur_7 = CL.GetService("ToolService")
                end
                Ur_47 = (Ur_47 + 105) % 272
            else
                Ur_40 = (vector.create((Ur_47 * 7 + 1) % 11 + 1, (Ur_47 * 3 + 8) % 13 + 1, (Ur_47 * 11 + 14) % 17 + 1))
                fns.Ur_30 = (vector.create((Ur_47 * 6 + 2) % 11 + 1, (Ur_47 * 2 + 6) % 13 + 1, (Ur_47 * 3 + 8) % 17 + 1))
                local Xm = vector.dot(Ur_40, fns.Ur_30)
                if Xm * Xm <= vector.dot(Ur_40, Ur_40) * vector.dot(fns.Ur_30, fns.Ur_30) then
                    CF = fns.Ur_7.GetService("SellStandService")
                else
                    fns.Ur_7 = CF.GetService("SellStandService")
                end
                Ur_47 = (Ur_47 + 139) % 272
            end
        elseif Ur_49 <= 29 then
            Ur_40 = (vector.create((Ur_47 * 7 + 2) % 11 + 1, (Ur_47 * 8 + 11) % 13 + 1, (Ur_47 * 12 + 5) % 17 + 1))
            fns.Ur_30 = (vector.create((Ur_47 * 5 + 5) % 11 + 1, (Ur_47 * 3 + 10) % 13 + 1, (Ur_47 * 15 + 7) % 17 + 1))
            local Ys = vector.dot(Ur_40, fns.Ur_30)
            if Ys * Ys >= vector.dot(Ur_40, Ur_40) * vector.dot(fns.Ur_30, fns.Ur_30) + 1 then
                Cq = Cy.GetService("SellFruitsService")
                DG = Cy.GetService("FurnitureShopService")
                Dw = Cy.GetService("RebirthService")
                fns.Ur_7 = Cy.GetService("FarmersMarketService")
                DC = Cy.GetService("PetsService")
            else
                DG = fns.Ur_7.GetService("SellFruitsService")
                Cy = fns.Ur_7.GetService("FurnitureShopService")
                DC = fns.Ur_7.GetService("RebirthService")
                Cq = fns.Ur_7.GetService("FarmersMarketService")
                Dw = fns.Ur_7.GetService("PetsService")
            end
            Ur_47 = (Ur_47 + 241) % 272
        else
            if (not Bn and not Bn or (not Bn or not Bn) or (not Bn or not Ur_52) and (Ur_52 and Bn) or Bn and Ur_52 and (Ur_52 or not Bn) and ((Bn or Bn) and (Bn and Ur_52))) and not (not Bn and not Bn or (not Bn or not Bn) or (not Bn or not Ur_52) and (Ur_52 and Bn) or Bn and Ur_52 and (Ur_52 or not Bn) and ((Bn or Bn) and (Bn and Ur_52))) then
                fns.Ur_7 = Cc.GetService("GearShopService")
                Dl = Cc.GetService("WormShopService")
                Dq = Cc.GetService("IndexService")
                Ci = Cc.GetService("StorkService")
            else
                Ci = fns.Ur_7.GetService("GearShopService")
                Dq = fns.Ur_7.GetService("WormShopService")
                Cc = fns.Ur_7.GetService("IndexService")
                Dl = fns.Ur_7.GetService("StorkService")
            end
            Ur_47 = (Ur_47 + 241) % 272
        end
    elseif Ur_49 <= 32 then
        if Ur_49 <= 31 then
            Ur_40 = {
                "yzijpamgblld",
                "fyzzkeyi",
                "vufwvba",
                "qtaaxmd",
                "mehmhaileod",
                "fgqbl",
                "euzpcf",
                "akxux",
                "pwhvwu",
                "asgxifhyqjx",
                "fkrkstd",
                "epyjjnbhae",
                "eja"
            }
            if Ur_40[(Ur_47 * 11 + 39) % 13 + 1] <= Ur_40[(Ur_47 * 11 + 39) % 13 + 1] then
                B6 = fns.Ur_7.GetController("DataClient")
            else
                fns.Ur_7 = B6.GetController("DataClient")
            end
            Ur_47 = (Ur_47 + 241) % 272
        else
            Ur_40 = (vector.create((Ur_47 * 3 + 4) % 11 + 1, (Ur_47 * 9 + 3) % 13 + 1, (Ur_47 * 7 + 7) % 17 + 1))
            fns.Ur_30 = (vector.create((Ur_47 * 4 + 4) % 11 + 1, (Ur_47 * 11 + 1) % 13 + 1, (Ur_47 * 15 + 6) % 17 + 1))
            fns.Ur_10 = (vector.create((Ur_47 * 4 + 6) % 11 + 1, (Ur_47 * 1 + 1) % 13 + 1, (Ur_47 * 13 + 1) % 17 + 1))
            Ur_119 = (vector.create((Ur_47 * 3 + 1) % 11 + 1, (Ur_47 * 7 + 8) % 13 + 1, (Ur_47 * 5 + 16) % 17 + 1))
            if vector.dot(vector.cross(Ur_40, fns.Ur_30), (vector.cross(fns.Ur_10, Ur_119))) == vector.dot(Ur_40, fns.Ur_10) * vector.dot(fns.Ur_30, Ur_119) - vector.dot(Ur_40, Ur_119) * vector.dot(fns.Ur_30, fns.Ur_10) + 5 then
                Ur_43 = ""
            else
                Ur_38 = ""
            end
            Ur_47 = (Ur_47 + 105) % 272
        end
    elseif Ur_49 <= 33 then
        local XQ = bit32.rrotate(bit32.bxor(bit32.lrotate(Ur_47, 9), string.byte(tostring(Ur_100))), 15)
        if bit32.bxor(bit32.lrotate(bit32.bxor(XQ, 3656950542), 16), 2735659512) ~= bit32.lrotate(XQ, 16) then
            Ur_38 = getgenv().Library
            pcall(fns.fn173)
            B_ = getgenv().ThemeManager
            C6 = getgenv().SaveManager
            Ur_57 = Ur_38.Toggles
            BP = Ur_38.Options
        else
            B_ = getgenv().Library
            pcall(fns.fn173)
            Ur_57 = getgenv().ThemeManager
            BP = getgenv().SaveManager
            C6 = B_.Toggles
            fns.Options = B_.Options
        end
        Ur_47 = (Ur_47 + 3) % 272
    else
        local YW = bit32.rrotate(bit32.bxor(bit32.lrotate(Ur_47, 5), string.byte(tostring(BL))), 8)
        if bit32.bxor(bit32.lrotate(bit32.bxor(YW, 177399234), 20), 1545644334) == bit32.lrotate(YW, 20) then
            CZ = fns.fn425
        else
            DC = fns.fn425
        end
        Ur_47 = (Ur_47 + 105) % 272
    end
until (Ur_47 * 165 + 213) % 272 == 194
for i, v in ipairs(Ur_117) do
    B7[v] = i
    Ur_47 = Ur_109[v] and Ur_109[v].name
    Ur_38 = Ur_47 or v
    Ur_47 = Ur_38
    Ur_65[i] = Ur_47
    B0[Ur_47] = v
end
BG = {}
Ur_47 = {}
for k in pairs(SeedConfig.Seeds) do
    Ur_38 = SeedConfig.GetSeed(k)
    fns.Ur_7 = Ur_38 and Ur_38.plantCost
    Ur_38 = fns.Ur_7 or 0
    fns.Ur_7 = Ur_38
    Ur_38 = fns.Ur_7 > 0 and "$" .. Ur_83(fns.Ur_7)
    fns.Ur_7 = Ur_38 or "Free"
    Ur_38 = fns.Ur_7
    fns.Ur_7 = SeedConfig.SeedDisplayName(k) .. " (" .. Ur_38 .. ")"
    Ur_47[#Ur_47 + 1] = fns.Ur_7
    BG[fns.Ur_7] = k
end
Ur_117, CA = nil, nil
Ur_38 = 1
repeat
    fns.Ur_7 = {
        "jlbsj",
        "tvag",
        "aszkqlizzgh",
        "dyc",
        "qnwgjlxdlk",
        "qhrgemw",
        "oqjmwju",
        "tppeorjckk",
        "nzhkziiyyt",
        "gpm",
        "vpn",
        "woap",
        "qzrxvo",
        "egrgxfuu",
        "yeuljs",
        "jyvri"
    }
    if fns.Ur_7[(Ur_38 * 56 + 106) % 16 + 1] < fns.Ur_7[(Ur_38 * 56 + 106) % 16 + 1] then
        table.sort(CA)
        Ur_47 = {}
        Ur_117 = {}
    else
        table.sort(Ur_47)
        Ur_117 = {}
        CA = {}
    end
    Ur_38 = (Ur_38 + 5) % 8
until (Ur_38 * 7 + 5) % 8 == 7
for i, v in ipairs(Ur_100.Categories) do
    for i, v2 in ipairs(v.items) do
        Ur_38 = tonumber(v2.price) or 0
        fns.Ur_7 = Ur_38
        Ur_38 = fns.Ur_7 > 0 and "$" .. Ur_83(fns.Ur_7)
        Ur_109 = Ur_38 or "Free"
        Ur_38 = Ur_109
        Ur_109 = ("[%s] %s (%s)"):format(v.name, v2.id, Ur_38)
        Ur_117[#Ur_117 + 1] = Ur_109
        CA[Ur_109] = { type = v.type, id = v2.id, price = fns.Ur_7 }
    end
end
Ur_49, Ur_31, Ur_100 = nil, nil, nil
Ur_38 = 5
repeat
    fns.Ur_7 = (Ur_38 * 2 + 2) % 3 + 1
    if fns.Ur_7 <= 2 then
        if fns.Ur_7 <= 1 then
            fns.Ur_7 = (vector.create((Ur_38 * 1 + 6) % 11 + 1, (Ur_38 * 4 + 1) % 13 + 1, (Ur_38 * 12 + 10) % 17 + 1))
            Ur_109 = (vector.create((Ur_38 * 1 + 8) % 11 + 1, (Ur_38 * 9 + 7) % 13 + 1, (Ur_38 * 11 + 16) % 17 + 1))
            Ur_40 = (vector.create((Ur_38 * 4 + 8) % 11 + 1, (Ur_38 * 5 + 6) % 13 + 1, (Ur_38 * 12 + 8) % 17 + 1))
            fns.Ur_30 = (vector.create((Ur_38 * 5 + 6) % 5 + 1, (Ur_38 * 5 + 4) % 7 + 1, (Ur_38 * 4 + 7) % 9 + 1))
            if vector.dot(vector.cross(fns.Ur_7, (vector.cross(Ur_109, Ur_40))), fns.Ur_30) == vector.dot(Ur_109 * vector.dot(fns.Ur_7, Ur_40) - Ur_40 * vector.dot(fns.Ur_7, Ur_109), fns.Ur_30) then
                table.sort(Ur_117)
                Ur_100 = fns.fn865
            else
                table.sort(Ur_100)
                Ur_117 = fns.fn865
            end
            Ur_38 = (Ur_38 + 23) % 24
        else
            fns.Ur_7 = {
                "xbeapfawu",
                "bfszpbxtdz",
                "yuftrvyucp",
                "apbcyipvle",
                "jcleiodse",
                "cxnnxixs",
                "yjhaftv",
                "ybvkc",
                "jbw"
            }
            local Yz = Ur_38
            Ur_109 = fns.Ur_7[Yz % 9 + 1]
            if Ur_109:len() <= Ur_109:reverse():rep(Yz % 3 + 2):len() then
                Ur_49 = {}
            else
                Ur_31 = {}
            end
            Ur_38 = (Ur_38 + 11) % 24
        end
    else
        fns.Ur_7 = {
            "swrsigsrzqt",
            "hbrrx",
            "nsjxz",
            "fwez",
            "qvut",
            "ersll",
            "nwaoghtk",
            "bpzn",
            "ozsatkeky",
            "ouelcsja"
        }
        local YV = Ur_38
        Ur_109 = fns.Ur_7[YV % 10 + 1]
        if Ur_109:len() <= Ur_109:reverse():rep(YV % 3 + 2):len() then
            Ur_31 = {}
        else
            Ur_100 = {}
        end
        Ur_38 = (Ur_38 + 8) % 24
    end
until (Ur_38 * 5 + 11) % 24 == 6
for i, v in ipairs(Ur_91.Rows) do
    Ur_38 = ("%s %s (%d tickets)"):format(Ur_100(v.difficulty), Ur_100(v.kind), v.reward)
    Ur_49[#Ur_49 + 1] = Ur_38
    Ur_31[Ur_38] = i
end
Ur_109, CT, Bu = nil, nil, nil
fns.Ur_7 = 8
repeat
    Ur_38 = (fns.Ur_7 * 1 + 1) % 2 + 1
    if Ur_38 <= 1 then
        Ur_38 = {
            "tpnekjwen",
            "cvjcvfmefw",
            "jywsyr",
            "zsvfiqm",
            "eay",
            "qxt",
            "ohreopxbm",
            "icfswapzstj",
            "pqpmuwlxu",
            "bnzsqnhznpe",
            "uegdvs"
        }
        local Yt = fns.Ur_7
        Ur_100 = Ur_38[Yt % 11 + 1]
        if Ur_100:len() >= Ur_100:gsub("(.)", "%1%1", Yt % 3 % 2 + 1):len() then
            Bu = {}
            CT = {}
        else
            CT = {}
            Bu = {}
        end
        fns.Ur_7 = (fns.Ur_7 + 11) % 16
    else
        local Xa = bit32.rrotate(bit32.bxor(bit32.lrotate(fns.Ur_7, 12), string.byte(tostring(CT))), 20)
        if bit32.bxor(bit32.lrotate(bit32.bxor(Xa, 1640047684), 14), 1225857136) ~= bit32.lrotate(Xa, 14) then
            CT = {}
        else
            Ur_109 = {}
        end
        fns.Ur_7 = (fns.Ur_7 + 7) % 16
    end
until (fns.Ur_7 * 11 + 4) % 16 == 2
for i, v in ipairs(PetConfig.EggOrder) do
    Ur_38 = PetConfig.Eggs[v]
    fns.Ur_7 = Ur_38 and Ur_38.price
    Ur_100 = fns.Ur_7 or 0
    fns.Ur_7 = Ur_38
    Ur_91 = Ur_100
    if fns.Ur_7 then
        fns.Ur_7 = Ur_38.displayName
    end
    Ur_38 = fns.Ur_7 or v
    fns.Ur_7 = ("%s (%d tickets)"):format(Ur_38, Ur_91)
    Ur_109[#Ur_109 + 1] = fns.Ur_7
    CT[fns.Ur_7] = v
    Bu[fns.Ur_7] = Ur_91
end
Ur_40, Ur_100, fns.Ur_23 = nil, nil, nil
Ur_38 = 0
repeat
    local Zt = bit32.rrotate(bit32.bxor(bit32.lrotate(Ur_38, 26), string.byte(tostring(fns.Ur_23))), 15)
    if bit32.bxor(bit32.lrotate(bit32.bxor(Zt, 579944150), 30), 2292469685) == bit32.lrotate(Zt, 30) then
        Ur_40 = {}
        Ur_100 = {}
        fns.Ur_23 = {}
    else
        fns.Ur_23 = {}
        Ur_40 = {}
        Ur_100 = {}
    end
    Ur_38 = (Ur_38 + 2) % 8
until (Ur_38 * 5 + 4) % 8 == 6
for i, v in ipairs(Ur_75.Order) do
    Ur_38 = Ur_75.Get(v) or Ur_75.Items[v]
    fns.Ur_7 = Ur_38
    if Ur_38 then
        Ur_38 = fns.Ur_7.price
    end
    Ur_91 = Ur_38 or 0
    Ur_38 = fns.Ur_7
    fns.Ur_30 = Ur_91
    if Ur_38 then
        Ur_38 = fns.Ur_7.displayName
    end
    fns.Ur_7 = Ur_38 or v
    Ur_38 = ("%s ($%s)"):format(fns.Ur_7, Ur_83(fns.Ur_30))
    Ur_40[#Ur_40 + 1] = Ur_38
    Ur_100[Ur_38] = v
    fns.Ur_23[Ur_38] = { id = v, price = fns.Ur_30, isTool = Ur_75.IsTool(v) }
end
Ur_91 = nil
fns.Ur_7 = 0
repeat
    Ur_38 = {
        "buva",
        "gvicn",
        "mpfkxsgfts",
        "wzobgirxgfw",
        "iqxnizzhva",
        "sugdjylgg",
        "nqybkdv",
        "iimqqfyo",
        "ptkflkbs"
    }
    if Ur_38[(fns.Ur_7 * 70 + 49) % 9 + 1] <= Ur_38[(fns.Ur_7 * 70 + 49) % 9 + 1] then
        Ur_91 = Ur_75.Items[Ur_75.CAN_OF_WORMS]
    else
        Ur_75 = Ur_91.Items[Ur_91.CAN_OF_WORMS]
    end
    fns.Ur_7 = (fns.Ur_7 + 0) % 8
until (fns.Ur_7 * 7 + 1) % 8 == 1
if Ur_91 then
    Ur_38 = 3
    repeat
        if Ur_38 * 12053143 + 11 + 1 <= Ur_38 * 12053143 + 11 + 1 + 1 then
            Ur_91 = Ur_75.Items[Ur_75.CAN_OF_WORMS].price
        else
            Ur_75 = Ur_91.Items[Ur_91.CAN_OF_WORMS].price
        end
        Ur_38 = (Ur_38 + 6) % 8
    until (Ur_38 * 7 + 7) % 8 == 6
end
Ur_38 = Ur_91 or 100
C8, BI, C_, Bz, CV, Bv, CO, Bp, CI, DJ, CB, DD, Cu = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
fns.Ur_7 = 12
repeat
    Ur_100 = (fns.Ur_7 * 1 + 1) % 4 + 1
    if Ur_100 <= 2 then
        if Ur_100 <= 1 then
            Ur_91 = (vector.create((fns.Ur_7 * 1 + 5) % 11 + 1, (fns.Ur_7 * 8 + 7) % 13 + 1, (fns.Ur_7 * 5 + 6) % 17 + 1))
            Ur_83 = (vector.create((fns.Ur_7 * 6 + 2) % 11 + 1, (fns.Ur_7 * 2 + 13) % 13 + 1, (fns.Ur_7 * 12 + 14) % 17 + 1))
            Ur_75 = (vector.create((fns.Ur_7 * 3 + 1) % 5 + 1, (fns.Ur_7 * 1 + 1) % 7 + 1, (fns.Ur_7 * 1 + 1) % 9 + 1))
            if math.abs((vector.angle(Ur_91, Ur_83, Ur_75))) - math.abs((vector.angle(Ur_83, Ur_91, Ur_75))) == 0 then
                CI = {}
                DJ = {}
                CB = {}
                DD = nil
                Cu = {
                    FIND_KINDS = { "Egg", "Worm", "Seed", "Fruit", "Leaf", "Other" },
                    findKinds = { Egg = true, Worm = true, Seed = true },
                    treeBlacklist = {},
                    storkPets = {},
                    equipWanted = {},
                    equipNames = {},
                    equipInfo = {},
                    petTypes = {}
                }
            else
                CB = {}
                DD = {}
                Cu = {}
                CI = nil
                DJ = {
                    FIND_KINDS = { "Other", "Worm", "Leaf", "Egg", "Fruit", "Seed" },
                    treeBlacklist = {},
                    storkPets = {},
                    equipNames = {},
                    petTypes = {},
                    equipInfo = {},
                    equipWanted = {},
                    findKinds = { Worm = true, Seed = true, Egg = true }
                }
            end
            fns.Ur_7 = (fns.Ur_7 + 25) % 32
        else
            Ur_91 = (vector.create((fns.Ur_7 * 7 + 4) % 11 + 1, (fns.Ur_7 * 9 + 8) % 13 + 1, (fns.Ur_7 * 3 + 17) % 17 + 1))
            Ur_83 = (vector.create((fns.Ur_7 * 4 + 6) % 11 + 1, (fns.Ur_7 * 6 + 11) % 13 + 1, (fns.Ur_7 * 5 + 8) % 17 + 1))
            Ur_75 = (vector.create((fns.Ur_7 * 4 + 9) % 11 + 1, (fns.Ur_7 * 10 + 4) % 13 + 1, (fns.Ur_7 * 14 + 11) % 17 + 1))
            if vector.dot(vector.cross(Ur_91, Ur_83), Ur_75) == vector.dot(vector.cross(Ur_83, Ur_75), Ur_91) then
                C8 = Ur_38
                BI = 100
                C_ = {
                    { enum = BZ.INDEXES.SEEDS, dataKey = "Seeds", levelKey = "SeedsLevel", tiers = "seeds" },
                    { enum = BZ.INDEXES.FRUIT, dataKey = "Fruits", levelKey = "FruitsLevel", tiers = "fruits" },
                    {
                        enum = BZ.INDEXES.MUTATIONS,
                        dataKey = "Mutations",
                        levelKey = "MutationsLevel",
                        tiers = "mutations"
                    },
                    { enum = BZ.INDEXES.PETS, dataKey = "Pets", levelKey = "PetsLevel", tiers = "pets" },
                    { enum = BZ.INDEXES.WORMS, dataKey = "Worms", levelKey = "WormsLevel", tiers = "worms" }
                }
                Bz = {}
            else
                BI = C_
                Bz = 100
                BZ = {
                    { dataKey = "Pets", enum = Ur_38.INDEXES.PETS, levelKey = "PetsLevel", tiers = "pets" },
                    { levelKey = "FruitsLevel", enum = Ur_38.INDEXES.FRUIT, tiers = "fruits", dataKey = "Fruits" },
                    { dataKey = "Seeds", enum = Ur_38.INDEXES.SEEDS, tiers = "seeds", levelKey = "SeedsLevel" },
                    {
                        enum = Ur_38.INDEXES.MUTATIONS,
                        levelKey = "MutationsLevel",
                        tiers = "mutations",
                        dataKey = "Mutations"
                    },
                    { dataKey = "Worms", levelKey = "WormsLevel", tiers = "worms", enum = Ur_38.INDEXES.WORMS }
                }
                C8 = {}
            end
            fns.Ur_7 = (fns.Ur_7 + 5) % 32
        end
    elseif Ur_100 <= 3 then
        Ur_100 = {
            "ovvxwsnty",
            "tolyovuxbbg",
            "obdx",
            "lxepcpdwgl",
            "dgtkkkctntq",
            "jghuju",
            "oybmoij",
            "dyutjnxcdq",
            "gdbv",
            "irzxhzaikhen"
        }
        if Ur_100[(fns.Ur_7 * 35 + 70) % 10 + 1] < Ur_100[(fns.Ur_7 * 35 + 70) % 10 + 1] then
            Bv = {}
        else
            CV = {}
        end
        fns.Ur_7 = (fns.Ur_7 + 21) % 32
    else
        if fns.Ur_7 * 115477055 + 2 + 3 <= fns.Ur_7 * 115477055 + 2 + 3 + 4 then
            Bv = {}
            CO = {}
            Bp = {}
        else
            Bp = {}
            Bv = {}
            CO = {}
        end
        fns.Ur_7 = (fns.Ur_7 + 21) % 32
    end
until (fns.Ur_7 * 9 + 23) % 32 == 11
Ur_91 = nil
Ur_100 = 7
repeat
    Ur_38 = (Ur_100 * 1 + 1) % 2 + 1
    if Ur_38 <= 1 then
        if (Ur_100 * 2 + 8) * 16 % 3 == ((Ur_100 * 2 + 8) * 16 + 3) % 3 then
            Ur_91 = fns.fn920
        else
            Ur_91 = fns.fn920
        end
        Ur_100 = (Ur_100 + 11) % 16
    else
        if (Ur_100 * 2 + 4) * 10 % 3 == ((Ur_100 * 2 + 4) * 10 + 3) % 3 then
            Ur_91("Any Seed", { itemType = "Seed" })
            Ur_91("Any Egg", { itemType = "Egg" })
            Ur_91("Any Pet", { itemType = "Pet" })
        else
            Ur_91("Any Seed", { itemType = "Seed" })
            Ur_91("Any Egg", { itemType = "Egg" })
            Ur_91("Any Pet", { itemType = "Pet" })
        end
        Ur_100 = (Ur_100 + 3) % 16
    end
until (Ur_100 * 15 + 11) % 16 == 6
for i, v in ipairs(Ur_47) do
    Ur_91("[Seed] " .. v, { itemType = "Seed", seedType = BG[v] })
end
for i, v in ipairs(Ur_109) do
    Ur_91("[Egg] " .. v, { itemType = "Egg", eggId = CT[v] })
end
for k in pairs(PetConfig.Pets) do
    Cu.petTypes[#Cu.petTypes + 1] = k
end
Ur_38 = 2
repeat
    fns.Ur_7 = {
        "zna",
        "zavbg",
        "lzgsr",
        "hcpacyx",
        "hztr",
        "jpeoez",
        "ykytcq",
        "mqwhiaep",
        "xmnjroq",
        "kniuln",
        "pzrknv",
        "frjib"
    }
    local WX = Ur_38
    Ur_100 = fns.Ur_7[WX % 12 + 1]
    if Ur_100:len() >= Ur_100:reverse():rep(WX % 3 + 2):len() then
        table.sort(Cu.petTypes)
    else
        table.sort(Cu.petTypes)
    end
    Ur_38 = (Ur_38 + 7) % 8
until (Ur_38 * 3 + 4) % 8 == 7
for i, v in ipairs(Cu.petTypes) do
    Ur_91("[Pet] " .. v, { itemType = "Pet", petType = v })
end
for i, v in ipairs(Ur_65) do
    Ur_38 = B0[v]
    if Ur_38 then
        CO[Ur_38] = true
        Bp[Ur_38] = true
    end
end
if Ur_49[1] then
    CI[1] = true
end
if Ur_109[1] then
    Ur_38 = 2
    repeat
        fns.Ur_7 = {
            "mtdcky",
            "insmvxcoel",
            "pewcehwmik",
            "ovfpmikis",
            "tuxdumri",
            "eeklijob",
            "hfxbuytb",
            "okknsdv",
            "vfpirap"
        }
        local Zx = Ur_38
        Ur_100 = fns.Ur_7[Zx % 9 + 1]
        if Ur_100:len() <= Ur_100:reverse():rep(Zx % 3 + 2):len() then
            DJ[Ur_109[1]] = true
        else
            Ur_109[DJ[1]] = true
        end
        Ur_38 = (Ur_38 + 2) % 4
    until (Ur_38 * 1 + 1) % 4 == 1
end
Cn, BM, C4, Ur_100, C0, CW, DL, Cl, BW, Bx, DM, Dy, B8, fns.Ur_22, BK, Dz, BS, CK, fns.Ur_4, DF, Cx, BB, fns.Ur_27, Ch, BO = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
fns.Ur_7 = 20
repeat
    Ur_38 = (fns.Ur_7 * 6 + 1) % 7 + 1
    if Ur_38 <= 4 then
        if Ur_38 <= 2 then
            if Ur_38 <= 1 then
                if fns.Ur_7 * 8254735 + 3 + 4 >= fns.Ur_7 * 8254735 + 3 + 4 + 1 then
                    BM = fns.fn992
                    C4 = fns.fn342
                    Cx = nil
                    BB = nil
                    DF = fns.fn1082
                else
                    DF = fns.fn992
                    Cx = fns.fn342
                    BM = nil
                    C4 = nil
                    BB = fns.fn1082
                end
                fns.Ur_7 = (fns.Ur_7 + 13) % 28
            else
                local YL = bit32.rrotate(bit32.bxor(bit32.lrotate(fns.Ur_7, 25), string.byte(tostring(B8))), 1)
                if bit32.bxor(bit32.lrotate(bit32.bxor(YL, 3405775107), 24), 63635457) == bit32.lrotate(YL, 24) then
                    fns.Ur_27 = fns.fn1479
                    Ch = fns.fn962
                    BO = fns.fn1340
                    Ur_100 = {}
                else
                    Ch = fns.fn1479
                    Ur_100 = fns.fn962
                    fns.Ur_27 = fns.fn1340
                    BO = {}
                end
                fns.Ur_7 = (fns.Ur_7 + 20) % 28
            end
        elseif Ur_38 <= 3 then
            Ur_91 = (vector.create((fns.Ur_7 * 6 + 3) % 11 + 1, (fns.Ur_7 * 10 + 11) % 13 + 1, (fns.Ur_7 * 11 + 8) % 17 + 1))
            Ur_83 = (vector.create((fns.Ur_7 * 7 + 6) % 11 + 1, (fns.Ur_7 * 6 + 5) % 13 + 1, (fns.Ur_7 * 15 + 15) % 17 + 1))
            Ur_75 = (vector.create((fns.Ur_7 * 1 + 3) % 5 + 1, (fns.Ur_7 * 2 + 4) % 7 + 1, (fns.Ur_7 * 2 + 5) % 9 + 1))
            if math.abs((vector.angle(Ur_91, Ur_83, Ur_75))) - math.abs((vector.angle(Ur_83, Ur_91, Ur_75))) == 0 then
                C0 = fns.fn957
                CW = fns.fn1085
                DL = fns.fn1021
            else
                DL = fns.fn957
                C0 = fns.fn1085
                CW = fns.fn1021
            end
            fns.Ur_7 = (fns.Ur_7 + 13) % 28
        else
            if (fns.Ur_7 * 1 + 3) * 5 % 4 == ((fns.Ur_7 * 1 + 3) * 5 + 8) % 4 then
                Cl = fns.fn133
                BW = fns.fn322
            else
                BW = fns.fn133
                Cl = fns.fn322
            end
            fns.Ur_7 = (fns.Ur_7 + 6) % 28
        end
    elseif Ur_38 <= 6 then
        if Ur_38 <= 5 then
            local Yv = bit32.rrotate(bit32.bxor(bit32.lrotate(fns.Ur_7, 19), string.byte(tostring(BB))), 16)
            if bit32.bxor(bit32.lrotate(bit32.bxor(Yv, 3014631300), 8), 2946466995) == bit32.lrotate(Yv, 8) then
                Bx = fns.fn1242
                DM = fns.fn9
                Dy = fns.fn1498
                B8 = fns.fn823
                fns.Ur_22 = fns.fn1330
            else
                DM = fns.fn1242
                fns.Ur_22 = fns.fn9
                Bx = fns.fn1498
                Dy = fns.fn823
                B8 = fns.fn1330
            end
            fns.Ur_7 = (fns.Ur_7 + 27) % 28
        else
            if (fns.Ur_7 * 2 + 7) * 16 % 3 == ((fns.Ur_7 * 2 + 7) * 16 + 0) % 3 then
                BK = fns.fn103
                Dz = function(c6)
                    local c7
                    local c8
                    c7 = nil
                    c8 = nil
                    BK(function(da, db, dc)
                        local GB = if c6(da) then 1 else 0
                        if GB == 1 then
                            c7, c8 = db, dc
                            return true
                        end
                    end)
                    return c7, c8
                end
                BS = fns.fn889
                CK = fns.fn805
            else
                CK = fns.fn103
                BK = function(c6)
                    local c7
                    local c8
                    c7 = nil
                    c8 = nil
                    BK(function(da, db, dc)
                        local GB = if c6(da) then 1 else 0
                        if GB == 1 then
                            c7, c8 = db, dc
                            return true
                        end
                    end)
                    return c7, c8
                end
                Dz = fns.fn889
                BS = fns.fn805
            end
            fns.Ur_7 = (fns.Ur_7 + 6) % 28
        end
    else
        if Dz and not Dy or Dy and Dz or (Dy or Dy) and (Dz or not Dy) or not (Dz and not Dy or Dy and Dz or (Dy or Dy) and (Dz or not Dy)) then
            Cn = {}
            fns.Ur_4 = fns.fn1134
        else
            fns.Ur_4 = {}
            Cn = fns.fn1134
        end
        fns.Ur_7 = (fns.Ur_7 + 27) % 28
    end
until (fns.Ur_7 * 5 + 8) % 28 == 24
for i, v in ipairs(Ur_68.Order) do
    Ur_100[#Ur_100 + 1] = v
end
Dc = {}
Ur_38 = {}
for i, v in ipairs(BU.Order) do
    fns.Ur_7 = BU.Weathers[v]
    Ur_91 = fns.Ur_7 and fns.Ur_7.displayName
    fns.Ur_7 = Ur_91 or v
    Ur_91 = fns.Ur_7
    Ur_38[#Ur_38 + 1] = Ur_91
    Dc[Ur_91] = v
end
CS = {}
for i, v in ipairs(BU.Order) do
    CS[v] = true
end
Bo, Dx, Ck, Dj, BV, BJ, DK, Ce, C1, fns.Ur_15, Cm, CP, CJ, DN, Dt, Co, B4, CX, CD, Cg, fns.Ur_17, Bt, CG, Cj, Di, BF, Cz, Dg, Dn, CU, Dk, fns.Ur_12, Cv, B1, Bw, Dh, B9, fns.Ur_29, C9, fns.Ur_3, C2, Bq, Db = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Bo = fns.fn911
Dx = function()
    local Value = fns.Options.PlantMode.Value
    local fj, fk, fl
    BK(function(fn, fo, fp)
        if fn.itemType == "Seed" and fn.seedType then
            if Value == "Any Seed" or Bv[fn.seedType] == true then
                local HV_2 = SeedConfig.GetSeed(fn.seedType)
                local HV_3 = HV_2 and HV_2.plantCost or 0
                if Value == "Highest Value" then
                    if not fj or HV_3 > fj then
                        fj, fk, fl = HV_3, fo, fp
                    end
                else
                    if not (Value == "Lowest Value") then
                        fk, fl = fo, fp
                        return true
                    end
                    if not fj or HV_3 < fj then
                        fj, fk, fl = HV_3, fo, fp
                    end
                end
            end
        end
    end)
    return fk, fl
end
Ck = fns.fn724
Dj = fns.fn844
BV = fns.fn329
BJ = function(gh)
    return Dz(function(gj)
        local Ij = BV(gj) and gj.isDead == true == gh
        return Ij
    end)
end
DK = fns.fn1486
Ce = function(gw)
    local Iw_1
    local Iv = DK(gw)
    local Iv_1
    if Iv then
        return Iv
    end
    Iv_1, Iw_1 = BJ(gw)
    if not Iv_1 then
        return nil
    end
    return CK(Iw_1, Iv_1, function(gD)
        local It = gD:GetAttribute("IsTree") == true and gD:GetAttribute("IsDead") == true == gw
        return It
    end)
end
C1 = fns.fn458
fns.Ur_15 = fns.fn41
Cm = fns.fn1535
CP = function()
    local Value = fns.Options.TreePlaceMode.Value
    if Value == "Set Spot" then
        if not DD then
            return nil
        end
        local Jl_1 = 3
        local Jm_1 = { DD }
        local Js = 1
        while Js <= 20 do
            local Jt = Js
            local Jn = Jt * 8
            local Jo = Jn - 1
            local Jx = 0
            while Jx <= Jo do
                local Jo_1 = Jx / Jn * math.pi * 2
                Jm_1[#Jm_1 + 1] = DD + Vector3.new(math.cos(Jo_1) * Jl_1 * Jt, 0, math.sin(Jo_1) * Jl_1 * Jt)
                Jx += 1
            end
            Js += 1
        end
        return Jm_1
    end
    if Value == "Left to Right" or Value == "Top to Bottom" then
        local Jl_3 = Cm()
        table.sort(Jl_3, function(hd, he)
            local Je = Value == "Top to Bottom" and hd.Z or hd.X
            local Jf = Value == "Top to Bottom" and he.Z or he.X
            if math.abs(Je - Jf) > 0.1 then
                return Je < Jf
            end
            local Je_3 = Value == "Top to Bottom" and hd.X
            local Jj = if Je_3 then 1 else 0
            local Jh = 464 * Jj + 2927 * (1 - Jj)
            local Ji = 601 * Jj + 2462 * (1 - Jj)
            if not ((Jh * 901 + Ji * 3116 + Jh * Ji) % 16777213 == 2569644) then
                Je_3 = hd.Z
            end
            return Je_3 < (Value == "Top to Bottom" and he.X or he.Z)
        end)
        return Jl_3
    elseif Value == "Grid" then
        return Cm()
    else
        return nil
    end
end
CJ = fns.fn268
DN = fns.fn414
Dt = fns.fn519
Co = fns.fn1396
B4 = fns.fn690
CX = fns.fn1206
CD = fns.fn1499
Cg = fns.fn846
fns.Ur_17 = fns.fn1254
Bt = fns.fn387
CG = fns.fn614
Cj = function()
    local jy
    jy = 0
    BK(function(jA)
        if jA.itemType == "Fruit" then
            jy += 1
        end
    end)
    return jy
end
Di = fns.fn1211
BF = fns.fn538
Cz = function()
    local jT
    local id
    local jU
    jT = nil
    jU = nil
    id = nil
    BK(function(jX, jY, jZ)
        if jX.itemType == "Fruit" then
            jT, jU, id = jY, jZ, jX.id
            return true
        end
    end)
    return jT, jU, id
end
Dg = fns.fn1728
Dn = fns.fn717
CU = fns.fn1303
Dk = fns.fn330
fns.Ur_12 = fns.fn1315
Cv = fns.fn1446
B1 = fns.fn1540
Bw = fns.fn174
Dh = function()
    local My_1
    local Mx_1
    Mx_1, My_1 = Cq:GetOffers():await()
    local Mz = not Mx_1 or type(My_1) ~= "table"
    local MD = if Mz then 1 else 0
    local MB = 457 * MD + 294 * (1 - MD)
    local MC = 1025 * MD + 632 * (1 - MD)
    if not ((MB * 2677 + MC * 391 + MB * MC) % 16777213 == 2092589) then
        Mz = type(My_1.rows) ~= "table"
    end
    if Mz then
        return
    end
    for i, v in ipairs(My_1.rows) do
        local MH = i
        if B_.Unloaded or not C6.AutoFarmersMarket.Value then
            return
        end
        local Mx_3 = CI[MH]
        if Mx_3 then
            Mx_3 = not (My_1.claimed and My_1.claimed[MH])
        end
        if Mx_3 then
            local Mz_2 = v.cells or {}
            for i, v in ipairs(Mz_2) do
                local MN = i
                if v and not v.given then
                    pcall(function()
                        Cq:GiveFruit(MH, MN):await()
                    end)
                    task.wait(0.15)
                end
            end
            if C6.AutoClaimMarket.Value then
                pcall(function()
                    Cq:ClaimRow(MH):await()
                end)
                task.wait(0.15)
            end
        end
    end
end
B9 = function()
    local MR_1
    local MQ_1
    MQ_1, MR_1 = Cq:GetOffers():await()
    local MS = not MQ_1 or type(MR_1) ~= "table" or type(MR_1.rows) ~= "table"
    if MS then
        return
    end
    for i, v in ipairs(MR_1.rows) do
        local MY = i
        if not (MR_1.claimed and MR_1.claimed[MY]) then
            local MQ_3 = true
            local MT = v.cells or {}
            for i, v in ipairs(MT) do
                if not v.given then
                    MQ_3 = false
                    break
                end
            end
            if MQ_3 then
                pcall(function()
                    Cq:ClaimRow(MY):await()
                end)
                task.wait(0.15)
            end
        end
    end
end
fns.Ur_29 = fns.fn327
C9 = fns.fn1608
fns.Ur_3 = fns.fn910
C2 = fns.fn311
Bq = function()
    local NI = C0()
    local NJ = NI and NI.Index
    if not NJ then
        return
    end
    for i, v in ipairs(C_) do
        local NS = v
        local NJ_1 = NJ[NS.levelKey] or 1
        local NJ_2 = IndexInfo.rewardTiers[NS.tiers]
        local NL = NJ_2 and NJ_2[NJ_1]
        if NL then
            local NK_1 = C2(NJ[NS.dataKey])
            if NK_1 >= (NL.goal or 0) then
                pcall(function()
                    Cc.ClaimIndexReward:Fire(NS.enum)
                end)
                task.wait(0.2)
            end
        end
    end
end
Db = function()
    local function Od()
        local NT = BW()
        local NU = {}
        if not NT then
            return NU
        end
        for i, descendant in NT:GetDescendants() do
            local NT_1 = descendant:IsA("Configuration") and descendant.Name:sub(1, 8) == "PlotPet_"
            if NT_1 then
                NU[#NU + 1] = descendant
            end
        end
        return NU
    end
    local function Oe(nb)
        local N1 = (nb:GetAttribute("Hunger"))
        local N8 = if N1 then 1 else 0
        local N6 = 894 * N8 + 3424 * (1 - N8)
        local N7 = 4021 * N8 + 2375 * (1 - N8)
        if not ((N6 * 11 + N7 * 2932 + N6 * N7) % 16777213 == 15394180) then
            N1 = 0
        end
        local N2 = N1
        local N1_1 = nb:GetAttribute("MaxHunger")
        if not N1_1 then
            local attr = nb:GetAttribute("PetType")
            local N4 = attr and PetConfig.GetMaxHunger(attr)
            N1_1 = N4
        end
        if not N1_1 or N1_1 <= 0 then
            return 1
        end
        return N2 / N1_1
    end
    local function Of()
        local Oa_1
        local N9 = CG()
        local N9_1
        if N9 then
            return N9
        end
        N9_1, Oa_1 = Bt()
        if not N9_1 then
            return nil
        end
        return CK(Oa_1, N9_1, function(nt)
            return nt:GetAttribute("IsFruit") == true
        end)
    end
    local Og = tonumber(fns.Options.FeedHungerThreshold.Value) or 100
    local Oh = Og / 100
    for i, v in ipairs(Od()) do
        local Oc
        Od = B_.Unloaded or not C6.AutoFeedPets.Value
        if Od then
            return
        end
        if Oe(v) <= Oh then
            if not Of() then
                return
            end
            Oc = v.Name:sub(9)
            pcall(function()
                fns.Ur_8:FeedPetAll(Oc):await()
            end)
            task.wait(0.2)
        end
    end
end
Cu.collectFinds = fns.fn270
Cu.itemMatches = fns.fn1297
Cu.autoEquip = function()
    local id
    id = nil
    local OQ, OR
    OQ, OR, id = nil, nil, nil
    BK(function(n8, n9, oa)
        for k, v in pairs(Cu.equipWanted) do
            if v then
                local OG = Cu.equipInfo[k]
                local OH = OG and Cu.itemMatches(n8, OG)
                if OH then
                    OQ, OR, id = n9, oa, n8.id
                    return true
                end
            end
        end
    end)
    if not OQ then
        return
    end
    local Character = LocalPlayer.Character
    if Character then
        for i, child in Character:GetChildren() do
            local OS_1 = child:IsA("Tool") and child:GetAttribute("ItemId") == id
            if OS_1 then
                return
            end
        end
    end
    CK(OR, OQ, function(ot)
        return ot:GetAttribute("ItemId") == id
    end)
end
Cu.giveToStork = function()
    local O8 = BW()
    if not O8 then
        return
    end
    local O9
    local O9_4
    for i, descendant in O8:GetDescendants() do
        local O8_1 = descendant:IsA("Configuration") and descendant.Name:sub(1, 8) == "PlotPet_" and descendant:GetAttribute("PetType") == "Stork"
        if O8_1 then
            O9 = descendant
            break
        end
    end
    if not O9 then
        return
    end
    if C6.StorkTeleport.Value then
        local attr = O9:GetAttribute("Anchor")
        if typeof(attr) == "CFrame" then
            Dy(attr)
            task.wait(0.15)
        end
    end
    local O8_3 = O9.Name:sub(9)
    local O9_1 = tonumber(fns.Options.StorkMaxPerCycle.Value) or 5
    local Pa_2
    for i = 1, O9_1 do
        local O4, O6, id, petType
        if B_.Unloaded or not C6.AutoStork.Value then
            return
        end
        O4, O6, id, petType = nil, nil, nil, nil
        BK(function(oP, oQ, oR)
            local O_ = oP.itemType == "Pet" and not oP.favorited and Cu.storkPets[tostring(oP.petType)]
            if O_ then
                O4, O6, id, petType = oQ, oR, oP.id, oP.petType
                return true
            end
        end)
        if not O4 then
            return
        end
        local O9_3 = CK(O6, O4, function(oY)
            return oY:GetAttribute("ItemId") == id
        end)
        if not O9_3 or B_.Unloaded or not C6.AutoStork.Value then
            return
        end
        O9_4, Pa_2 = Dl:GivePet(O8_3):await()
        if not (O9_4 and Pa_2) then
            return
        end
        if C6.StorkNotify.Value then
            B_:Notify(("Gave %s to the stork"):format(tostring(petType)))
        end
        task.wait(0.5)
    end
end
fns.Ur_7 = B_:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = BX, Copyable = true }, "|", Ur_34, "|", Ur_60 },
    Icon = 12645376577,
    NotifySide = "Right",
    Size = UDim2.fromOffset(900, 640),
    ShowCustomCursor = false,
    CornerRadius = 0
})
B_.ShowCustomCursor = false
Ur_75 = {
    Info = fns.Ur_7:AddTab("Info", "info"),
    Seeds = fns.Ur_7:AddTab("Seeds", "sprout"),
    Farm = fns.Ur_7:AddTab("Farm", "trees"),
    Shops = fns.Ur_7:AddTab("Shops", "store"),
    Player = fns.Ur_7:AddTab("Player", "person-standing"),
    Settings = fns.Ur_7:AddTab("Settings", "settings")
}
Ur_83 = fns.fn1606
for k, v in Ur_75 do
    Ur_83(v)
end
DI = nil
DI = "Unknown"
pcall(fns.fn1741)
Label, Do = nil, nil
Ur_83 = Ur_75.Info:AddLeftGroupbox("Account", "circle-user")
Ur_83:AddLabel(fns.Ur_6("User", LocalPlayer.Name, Ur_80), true)
Ur_83:AddLabel(fns.Ur_6("Status", "Keyless", Ur_80), true)
Ur_83:AddLabel(fns.Ur_6("Executor", DI, Ur_80), true)
Ur_60 = Ur_75.Info:AddLeftGroupbox("Game Info", "gamepad-2")
Ur_60:AddLabel(DH(Ur_34 .. " [" .. tostring(game.PlaceId) .. "]", Ur_122), true)
Ur_60:AddLabel(fns.Ur_6("Place ID", tostring(game.PlaceId), Ur_122), true)
Label = Ur_60:AddLabel(fns.Ur_6("Session time", "0s", Dv), true)
Do = tostring(game.JobId)
Ur_68 = #Do > 18
if Ur_68 then
    fns.Ur_7 = 4
    repeat
        local Xv = bit32.rrotate(bit32.bxor(bit32.lrotate(fns.Ur_7, 4), string.byte(tostring(fns.Ur_7))), 28)
        if bit32.bxor(bit32.lrotate(bit32.bxor(Xv, 704769678), 24), 2385117678) == bit32.lrotate(Xv, 24) then
            Ur_68 = string.sub(Do, 1, 18) .. "..."
        else
            Do = string.sub(Ur_68, 1, 18) .. "..."
        end
        fns.Ur_7 = (fns.Ur_7 + 3) % 8
    until (fns.Ur_7 * 7 + 4) % 8 == 5
end
fns.Ur_7 = Ur_68 or Do
Dd, Ur_119 = nil, nil
local Ur_111 = fns.Ur_7
Ur_60:AddLabel(fns.Ur_6("Server", Ur_111, fns.Ur_18), true)
Ur_60:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
Dd = os.clock()
task.spawn(fns.worker)
fns.Ur_10 = Ur_75.Info:AddRightGroupbox("Scripts", "package")
fns.Ur_10:AddLabel(DH("Included in this hub", fns.Ur_18), true)
fns.Ur_10:AddLabel(DH(Ur_34, Ur_122), true)
Ur_91 = Ur_75.Info:AddRightGroupbox("Features", "list")
Ur_91:AddLabel(DH("Auto Farm", Ur_122), true)
Ur_91:AddLabel(DH("Auto Sell", Dv), true)
Ur_91:AddLabel(DH("Shops & Index", Ur_80), true)
Ur_91:AddLabel(DH("Pets & Market", fns.Ur_18), true)
fns.Ur_30 = Ur_75.Info:AddRightGroupbox("Socials", "link")
fns.Ur_30:AddButton({ Text = "Discord", Func = CN })
fns.Ur_30:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
local TempoHubGroup = Ur_75.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = CN })
Ur_68 = Ur_75.Info:AddRightGroupbox("Donations", "heart")
if (not Ur_119 and not fns.Ur_30 and (Ur_111 and not Ur_68) and ((fns.Ur_10 or not Ur_111) and (fns.Ur_10 or not fns.Ur_10)) or (Ur_111 and fns.Ur_30 or (fns.Ur_10 or fns.Ur_30) or (Ur_111 or not fns.Ur_30 or not fns.Ur_30 and not fns.Ur_30))) and (Ur_119 and fns.Ur_30 and (fns.Ur_10 or Ur_68) and (fns.Ur_30 or not Ur_119 or not fns.Ur_10 and Ur_68) and (not fns.Ur_30 or Dd or Ur_119 and fns.Ur_10 or (not Dd or Ur_68 or (fns.Ur_10 or not Ur_111)))) and not ((not Ur_119 and not fns.Ur_30 and (Ur_111 and not Ur_68) and ((fns.Ur_10 or not Ur_111) and (fns.Ur_10 or not fns.Ur_10)) or (Ur_111 and fns.Ur_30 or (fns.Ur_10 or fns.Ur_30) or (Ur_111 or not fns.Ur_30 or not fns.Ur_30 and not fns.Ur_30))) and (Ur_119 and fns.Ur_30 and (fns.Ur_10 or Ur_68) and (fns.Ur_30 or not Ur_119 or not fns.Ur_10 and Ur_68) and (not fns.Ur_30 or Dd or Ur_119 and fns.Ur_10 or (not Dd or Ur_68 or (fns.Ur_10 or not Ur_111))))) then
    Ur_122:AddLabel(Ur_52("All donations are optional but appreciated.", fns.Ur_18), true)
    Ur_122:AddLabel(Ur_52("If you donate you get a special role, just PING after you donate.", Dv), true)
    Ur_122:AddDivider()
    Ur_122:AddLabel(Ur_52("LTC / Litecoin", DH), true)
    Ur_122:AddButton({ Text = "Copy Litecoin Address", Func = fns.onCopyLitecoinAddress })
    Ur_122:AddLabel(Ur_52("BTC / Bitcoin", Ur_68), true)
    Ur_122:AddButton({ Text = "Copy Bitcoin Address", Func = fns.onCopyBitcoinAddress })
    Ur_122:AddLabel(Ur_52("ETH / Ethereum", Ur_113), true)
    Ur_122:AddButton({ Text = "Copy Ethereum Address", Func = fns.onCopyEthereumAddress })
    Ur_122:AddLabel(Ur_52("USDT", Ur_105), true)
    Ur_122:AddButton({ Text = "Copy USDT Address", Func = fns.onCopyUSDTAddress })
    Ur_122:AddLabel(Ur_52("Solana", Ur_73), true)
    Ur_122:AddButton({ Text = "Copy Solana Address", Func = fns.onCopySolanaAddress })
    Ur_122:AddLabel(Ur_52("PayPal", Ur_96), true)
    Ur_122:AddButton({ Text = "Copy PayPal Link", Func = fns.onCopyPayPalLink })
    Ur_122:AddLabel(Ur_52("Venmo", Ur_80), true)
    Ur_122:AddButton({ Text = "Copy Venmo Link", Func = fns.onCopyVenmoLink })
    Ur_122:AddDivider()
    Ur_122:AddLabel(Ur_52("Don't have any of the listed currencies but still wanna donate?", Ur_88), true)
    Ur_122:AddLabel(Ur_52("DM me and we'll work something out.", Ur_119), true)
    Ur_75 = Ur_43.Info:AddRightGroupbox("FAQ", "circle-help")
else
    Ur_68:AddLabel(DH("All donations are optional but appreciated.", Dv), true)
    Ur_68:AddLabel(DH("If you donate you get a special role, just PING after you donate.", Ur_80), true)
    Ur_68:AddDivider()
    Ur_68:AddLabel(DH("LTC / Litecoin", Ur_88), true)
    Ur_68:AddButton({ Text = "Copy Litecoin Address", Func = fns.onCopyLitecoinAddress })
    Ur_68:AddLabel(DH("BTC / Bitcoin", Ur_43), true)
    Ur_68:AddButton({ Text = "Copy Bitcoin Address", Func = fns.onCopyBitcoinAddress })
    Ur_68:AddLabel(DH("ETH / Ethereum", Ur_96), true)
    Ur_68:AddButton({ Text = "Copy Ethereum Address", Func = fns.onCopyEthereumAddress })
    Ur_68:AddLabel(DH("USDT", Ur_52), true)
    Ur_68:AddButton({ Text = "Copy USDT Address", Func = fns.onCopyUSDTAddress })
    Ur_68:AddLabel(DH("Solana", Ur_105), true)
    Ur_68:AddButton({ Text = "Copy Solana Address", Func = fns.onCopySolanaAddress })
    Ur_68:AddLabel(DH("PayPal", Ur_73), true)
    Ur_68:AddButton({ Text = "Copy PayPal Link", Func = fns.onCopyPayPalLink })
    Ur_68:AddLabel(DH("Venmo", Ur_113), true)
    Ur_68:AddButton({ Text = "Copy Venmo Link", Func = fns.onCopyVenmoLink })
    Ur_68:AddDivider()
    Ur_68:AddLabel(DH("Don't have any of the listed currencies but still wanna donate?", fns.Ur_18), true)
    Ur_68:AddLabel(DH("DM me and we'll work something out.", Ur_122), true)
    Ur_119 = Ur_75.Info:AddRightGroupbox("FAQ", "circle-help")
end
if (fns.Ur_10 and Ur_119 or (not Ur_111 or fns.Ur_10) or fns.Ur_10 and Ur_119 and (Ur_111 or not fns.Ur_10)) and ((Ur_111 and not fns.Ur_10 or (Ur_119 or fns.Ur_10)) and (not Ur_119 and not Ur_119 or not fns.Ur_10 and not Ur_119)) and not ((fns.Ur_10 and Ur_119 or (not Ur_111 or fns.Ur_10) or fns.Ur_10 and Ur_119 and (Ur_111 or not fns.Ur_10)) and ((Ur_111 and not fns.Ur_10 or (Ur_119 or fns.Ur_10)) and (not Ur_119 and not Ur_119 or not fns.Ur_10 and not Ur_119))) then
    Ur_119:AddLabel("Where do I get a good config?", true)
    Ur_119:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
    Ur_119:AddLabel("How do I import / export configs?", true)
    Ur_119:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
    Ur_119:AddLabel("How do I report bugs?", true)
    Ur_119:AddLabel("Join the Discord and post it in the bugs channel.", true)
    Ur_119:AddLabel("How do I make suggestions?", true)
    Ur_119:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
    Ur_119:AddLabel("How do I get help or updates?", true)
    Ur_119:AddLabel("Join the Discord, updates and support are posted there first.", true)
else
    Ur_119:AddLabel("Where do I get a good config?", true)
    Ur_119:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
    Ur_119:AddLabel("How do I import / export configs?", true)
    Ur_119:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
    Ur_119:AddLabel("How do I report bugs?", true)
    Ur_119:AddLabel("Join the Discord and post it in the bugs channel.", true)
    Ur_119:AddLabel("How do I make suggestions?", true)
    Ur_119:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
    Ur_119:AddLabel("How do I get help or updates?", true)
    Ur_119:AddLabel("Join the Discord, updates and support are posted there first.", true)
end
LimitsGroup, AutoBuyFurnitureGroup, CompostGroup = nil, nil, nil
local AutoBuySeedsGroup = Ur_75.Seeds:AddLeftGroupbox("Auto Buy Seeds", "shopping-cart")
if CompostGroup and 28 or (AutoBuySeedsGroup and not CompostGroup or (AutoBuyFurnitureGroup or 28)) or not (CompostGroup and 28 or (AutoBuySeedsGroup and not CompostGroup or (AutoBuyFurnitureGroup or 28))) then
    AutoBuySeedsGroup:AddToggle("AutoBuySeeds", { Text = "Auto Buy Seeds", Default = false })
    AutoBuySeedsGroup:AddDropdown("BuyMode", {
        Text = "Buy Mode",
        Values = { "Minimum Rarity", "Selected Seeds", "Buy All" },
        Default = "Minimum Rarity",
        Multi = false
    })
    AutoBuySeedsGroup:AddDropdown("BuyMinRarity", { Text = "Minimum Rarity", Values = Ur_65, Default = Ur_65[1], Multi = false })
    AutoBuySeedsGroup:AddDropdown("BuySeeds", { Text = "Seeds To Buy", Values = Ur_47, Default = {}, Multi = true, Callback = fns.onBuySeeds })
    AutoBuySeedsGroup:AddToggle("BuyMutatedOnly", { Text = "Only Mutated Seeds", Default = false })
    LimitsGroup = Ur_75.Seeds:AddRightGroupbox("Limits", "sliders-horizontal")
else
    LimitsGroup:AddToggle("AutoBuySeeds", { Text = "Auto Buy Seeds", Default = false })
    LimitsGroup:AddDropdown("BuyMode", {
        Multi = false,
        Text = "Buy Mode",
        Default = "Minimum Rarity",
        Values = { "Buy All", "Selected Seeds", "Minimum Rarity" }
    })
    LimitsGroup:AddDropdown("BuyMinRarity", { Default = Ur_75[1], Text = "Minimum Rarity", Multi = false, Values = Ur_75 })
    LimitsGroup:AddDropdown("BuySeeds", {
        Values = AutoBuySeedsGroup,
        Default = {},
        Text = "Seeds To Buy",
        Callback = fns.onBuySeeds,
        Multi = true
    })
    LimitsGroup:AddToggle("BuyMutatedOnly", { Text = "Only Mutated Seeds", Default = false })
    Ur_65 = Ur_47.Seeds:AddRightGroupbox("Limits", "sliders-horizontal")
end
LimitsGroup:AddInput("BuyMaxCost", {
    Text = "Max Cost Per Seed (0 = off)",
    Default = "0",
    Numeric = true,
    Finished = false,
    ClearTextOnFocus = false
})
LimitsGroup:AddInput("BuyReserve", {
    Text = "Keep Coin Reserve",
    Default = "0",
    Numeric = true,
    Finished = false,
    ClearTextOnFocus = false
})
LimitsGroup:AddToggle("BuyNotify", { Text = "Notify On Buy", Default = false })
LimitsGroup:AddSlider("BuyActionDelay", { Text = "Buy Delay", Default = 0.2, Min = 0.1, Max = 2, Rounding = 2 })
LimitsGroup:AddSlider("BuyLoopDelay", { Text = "Loop Delay", Default = 0.5, Min = 0.1, Max = 10, Rounding = 1 })
AutoBuyFurnitureGroup = Ur_75.Seeds:AddLeftGroupbox("Auto Buy Furniture", "sofa")
AutoBuyFurnitureGroup:AddToggle("AutoBuyFurniture", { Text = "Auto Buy Furniture", Default = false })
AutoBuyFurnitureGroup:AddDropdown("FurnitureItems", {
    Text = "Furniture To Buy",
    Values = Ur_117,
    Default = {},
    Multi = true,
    Callback = fns.onFurnitureItems
})
AutoBuyFurnitureGroup:AddInput("FurnitureReserve", {
    Text = "Keep Coin Reserve",
    Default = "0",
    Numeric = true,
    Finished = false,
    ClearTextOnFocus = false
})
AutoBuyFurnitureGroup:AddToggle("FurnitureNotify", { Text = "Notify On Buy", Default = false })
AutoBuyFurnitureGroup:AddSlider("FurnitureActionDelay", { Text = "Buy Delay", Default = 0.2, Min = 0.1, Max = 2, Rounding = 2 })
AutoBuyFurnitureGroup:AddSlider("FurnitureLoopDelay", { Text = "Loop Delay", Default = 1, Min = 0.2, Max = 20, Rounding = 1 })
CompostGroup = Ur_75.Seeds:AddRightGroupbox("Compost", "recycle")
CompostGroup:AddToggle("AutoCompostSeeds", { Text = "Auto Compost Seeds", Default = false })
CompostGroup:AddDropdown("CompostRarities", {
    Text = "Seed Rarity",
    Values = Ur_65,
    Default = Ur_65,
    Multi = true,
    Callback = fns.onCompostRarities
})
CompostGroup:AddSlider("CompostLoopDelay", { Text = "Loop Delay", Default = 0.25, Min = 0.1, Max = 5, Rounding = 2 })
Ur_91, Ur_83, fns.Ur_7, Ur_43 = nil, nil, nil, nil
if ((not Ur_43 or Ur_91) and (not Ur_83 or not Ur_43) or 13 or (not Ur_43 and 13 or not Ur_83 and Ur_91) and (not Ur_91 and not fns.Ur_7 or fns.Ur_7 and 13)) and not ((not Ur_43 or Ur_91) and (not Ur_83 or not Ur_43) or 13 or (not Ur_43 and 13 or not Ur_83 and Ur_91) and (not Ur_91 and not fns.Ur_7 or fns.Ur_7 and 13)) then
    Ur_75 = Ur_91.Farm:AddRightGroupbox("Auto Plant", "sprout")
else
    Ur_91 = Ur_75.Farm:AddRightGroupbox("Auto Plant", "sprout")
end
Ur_91:AddToggle("AutoPlant", { Text = "Auto Plant", Default = false })
Ur_91:AddDropdown("PlantMode", {
    Text = "Seed Choice",
    Values = { "Any Seed", "Selected Seeds", "Highest Value", "Lowest Value" },
    Default = "Any Seed",
    Multi = false
})
Ur_91:AddDropdown("PlantSeeds", { Text = "Seeds To Plant", Values = Ur_47, Default = {}, Multi = true, Callback = fns.onPlantSeeds })
Ur_91:AddDropdown("PlantFertilizer", { Text = "Fertilizer", Values = Ur_100, Default = "None", Multi = false })
Ur_91:AddToggle("PlantDuringWeatherOnly", { Text = "Only Plant During Weather", Default = false })
Ur_91:AddDropdown("PlantWeathers", {
    Text = "Weathers To Plant In",
    Values = Ur_38,
    Default = Ur_38,
    Multi = true,
    Callback = fns.onPlantWeathers
})
Ur_91:AddToggle("AutoPlantTrees", { Text = "Auto Plant Grown Trees", Default = false })
Ur_91:AddToggle("AutoOrganiseTrees", { Text = "Auto Organise Trees", Default = false })
Ur_91:AddDropdown("TreePlaceMode", {
    Text = "Tree Placement",
    Values = { "Random", "Grid", "Left to Right", "Top to Bottom", "Set Spot" },
    Default = "Grid",
    Multi = false
})
Ur_91:AddButton({ Text = "Set Tree Spot To My Position", Func = fns.onSetTreeSpotToMyPosition })
Ur_91:AddToggle("VisualizePlacement", { Text = "Visualize Placement", Default = false })
Ur_91:AddToggle("PlantNotify", { Text = "Notify On Plant", Default = false })
Ur_91:AddSlider("PlantLoopDelay", { Text = "Loop Delay", Default = 1, Min = 0.2, Max = 20, Rounding = 1 })
Ur_52 = Ur_75.Farm:AddLeftGroupbox("Auto Harvest", "apple")
Ur_52:AddToggle("AutoHarvest", { Text = "Auto Harvest", Default = false })
Ur_52:AddInput("HarvestMultiplier", {
    Text = "Harvest At Multiplier",
    Default = "2",
    Numeric = true,
    Finished = false,
    ClearTextOnFocus = false
})
Ur_52:AddToggle("AutoCollectDead", { Text = "Auto Collect Dead Tree", Default = true })
Ur_52:AddToggle("HarvestNotify", { Text = "Notify On Harvest", Default = false })
Ur_83 = Ur_75.Farm:AddLeftGroupbox("Auto Collect Fruit", "grape")
Ur_83:AddToggle("AutoCollectFruit", { Text = "Auto Collect Fruit", Default = false })
Ur_83:AddToggle("HarvestTeleport", { Text = "Teleport To Each Tree", Default = false })
Ur_83:AddDropdown("TreeBlacklist", {
    Text = "Blacklisted Trees",
    Values = Ur_47,
    Default = {},
    Multi = true,
    Callback = fns.onTreeBlacklist
})
Ur_83:AddToggle("HarvestCollectAll", { Text = "Use Collect All (ignored while blacklisting)", Default = false })
Ur_83:AddSlider("HarvestActionDelay", { Text = "Collect Delay", Default = 0.1, Min = 0.05, Max = 2, Rounding = 2 })
Ur_83:AddSlider("HarvestLoopDelay", { Text = "Loop Delay", Default = 1, Min = 0.2, Max = 20, Rounding = 1 })
fns.Ur_7 = Ur_75.Farm:AddLeftGroupbox("Auto Pickup", "axe")
fns.Ur_7:AddToggle("AutoPickupTrees", { Text = "Auto Pickup Trees", Default = false })
fns.Ur_7:AddDropdown("PickupRarities", {
    Text = "Tree Rarity",
    Values = Ur_65,
    Default = Ur_65,
    Multi = true,
    Callback = fns.onPickupRarities
})
fns.Ur_7:AddSlider("PickupActionDelay", { Text = "Pickup Delay", Default = 0.25, Min = 0.1, Max = 2, Rounding = 2 })
fns.Ur_7:AddSlider("PickupLoopDelay", { Text = "Loop Delay", Default = 1, Min = 0.2, Max = 20, Rounding = 1 })
fns.Ur_7:AddDivider()
fns.Ur_7:AddToggle("AutoCollectFinds", { Text = "Auto Collect Plot Finds", Default = false })
fns.Ur_7:AddDropdown("FindKinds", {
    Text = "Find Types",
    Values = Cu.FIND_KINDS,
    Default = { "Egg", "Worm", "Seed" },
    Multi = true,
    Callback = fns.onFindKinds
})
fns.Ur_7:AddToggle("FindsTeleport", { Text = "Teleport To Each Find", Default = true })
fns.Ur_7:AddSlider("FindsActionDelay", { Text = "Collect Delay", Default = 0.15, Min = 0.05, Max = 2, Rounding = 2 })
fns.Ur_7:AddSlider("FindsLoopDelay", { Text = "Finds Loop Delay", Default = 1, Min = 0.2, Max = 20, Rounding = 1 })
Ur_68 = Ur_75.Farm:AddRightGroupbox("Auto Sell", "banknote")
Ur_68:AddToggle("AutoSellFruits", { Text = "Auto Sell Fruits", Default = false })
Ur_68:AddToggle("AutoSellAtMax", { Text = "Auto Sell At Max Inventory", Default = false })
Ur_68:AddToggle("AutoSellAll", { Text = "Auto Sell All", Default = false })
Ur_68:AddToggle("SellDeadTreesOnly", { Text = "Sell Dead Trees Only", Default = false })
Ur_68:AddToggle("SellTeleport", { Text = "Teleport To Sell Stand", Default = false })
Ur_68:AddSlider("SellMinFruits", { Text = "Minimum Fruits", Default = 1, Min = 1, Max = 50, Rounding = 0 })
Ur_68:AddSlider("SellActionDelay", { Text = "Sell Delay", Default = 0.2, Min = 0.1, Max = 2, Rounding = 2 })
Ur_68:AddSlider("SellLoopDelay", { Text = "Loop Delay", Default = 2, Min = 0.5, Max = 30, Rounding = 1 })
Ur_43 = Ur_75.Farm:AddRightGroupbox("Auto Rebirth", "refresh-cw")
Ur_43:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
Ur_43:AddSlider("RebirthMaxLevel", {
    Text = "Max Rebirth Level",
    Default = RebirthConfig.MaxLevel,
    Min = 1,
    Max = RebirthConfig.MaxLevel,
    Rounding = 0
})
Ur_43:AddToggle("RebirthNotify", { Text = "Notify On Rebirth", Default = true })
Ur_43:AddSlider("RebirthLoopDelay", { Text = "Loop Delay", Default = 5, Min = 1, Max = 60, Rounding = 1 })
fns.Ur_18 = Ur_75.Shops:AddLeftGroupbox("Pet Shop", "egg")
fns.Ur_18:AddToggle("AutoBuyEggs", { Text = "Auto Buy Pet Eggs", Default = false })
fns.Ur_18:AddDropdown("EggTypes", { Text = "Eggs", Values = Ur_109, Default = { Ur_109[1] }, Multi = true, Callback = fns.onEggTypes })
fns.Ur_18:AddInput("EggReserve", {
    Text = "Keep Ticket Reserve",
    Default = "0",
    Numeric = true,
    Finished = false,
    ClearTextOnFocus = false
})
fns.Ur_18:AddToggle("EggNotify", { Text = "Notify On Buy", Default = false })
fns.Ur_18:AddSlider("EggLoopDelay", { Text = "Loop Delay", Default = 1, Min = 0.2, Max = 20, Rounding = 1 })
Ur_105 = Ur_75.Shops:AddRightGroupbox("Gear Shop", "wrench")
Ur_105:AddToggle("AutoBuyGear", { Text = "Auto Buy Gear", Default = false })
Ur_105:AddDropdown("GearItems", { Text = "Gear", Values = Ur_40, Default = {}, Multi = true, Callback = fns.onGearItems })
Ur_105:AddInput("GearReserve", {
    Text = "Keep Coin Reserve",
    Default = "0",
    Numeric = true,
    Finished = false,
    ClearTextOnFocus = false
})
Ur_105:AddToggle("GearNotify", { Text = "Notify On Buy", Default = false })
Ur_105:AddSlider("GearLoopDelay", { Text = "Loop Delay", Default = 2, Min = 0.5, Max = 20, Rounding = 1 })
Ur_34 = Ur_75.Shops:AddLeftGroupbox("Worm Shop", "bug")
Ur_34:AddToggle("AutoBuyWorms", { Text = "Auto Buy Worms", Default = false })
Ur_34:AddInput("WormReserve", {
    Text = "Keep Coin Reserve",
    Default = "0",
    Numeric = true,
    Finished = false,
    ClearTextOnFocus = false
})
Ur_34:AddSlider("WormLoopDelay", { Text = "Loop Delay", Default = 2, Min = 0.5, Max = 20, Rounding = 1 })
Ur_113 = Ur_75.Shops:AddRightGroupbox("Farmers Market", "store")
Ur_113:AddToggle("AutoFarmersMarket", { Text = "Auto Give Market Fruits", Default = false })
Ur_113:AddToggle("AutoClaimMarket", { Text = "Auto Claim Market Tickets", Default = false })
Ur_113:AddDropdown("MarketRows", {
    Text = "Ticket Rows",
    Values = Ur_49,
    Default = { Ur_49[1] },
    Multi = true,
    Callback = fns.onMarketRows
})
Ur_113:AddSlider("MarketLoopDelay", { Text = "Loop Delay", Default = 2, Min = 0.5, Max = 30, Rounding = 1 })
Ur_122 = Ur_75.Shops:AddLeftGroupbox("Index", "book-open")
Ur_122:AddToggle("AutoCollectIndex", { Text = "Auto Collect Index", Default = false })
Ur_122:AddSlider("IndexLoopDelay", { Text = "Loop Delay", Default = 3, Min = 1, Max = 30, Rounding = 1 })
Ur_96 = Ur_75.Shops:AddRightGroupbox("Pets", "paw-print")
Ur_96:AddToggle("AutoFeedPets", { Text = "Auto Feed Pets", Default = false })
Ur_96:AddSlider("FeedHungerThreshold", { Text = "Feed Below Fullness %", Default = 50, Min = 0, Max = 100, Rounding = 0 })
Ur_96:AddSlider("FeedLoopDelay", { Text = "Loop Delay", Default = 2, Min = 0.5, Max = 20, Rounding = 1 })
Ur_96:AddDivider()
Ur_96:AddToggle("AutoStork", { Text = "Auto Give To Stork (Rehome)", Default = false })
Ur_96:AddDropdown("StorkPets", {
    Text = "Pets To Rehome",
    Values = Cu.petTypes,
    Default = {},
    Multi = true,
    Callback = fns.onStorkPets
})
Ur_96:AddToggle("StorkTeleport", { Text = "Teleport To Stork", Default = true })
Ur_96:AddSlider("StorkMaxPerCycle", { Text = "Max Per Cycle", Default = 5, Min = 1, Max = 25, Rounding = 0 })
Ur_96:AddToggle("StorkNotify", { Text = "Notify On Rehome", Default = false })
Ur_96:AddSlider("StorkLoopDelay", { Text = "Stork Loop Delay", Default = 3, Min = 1, Max = 60, Rounding = 1 })
Ur_47 = Ur_75.Player:AddLeftGroupbox("Movement", "footprints")
Ur_47:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
Ur_47:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
Ur_47:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
Ur_47:AddToggle("NoClip", { Text = "NoClip", Default = false })
Ur_47:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
Ur_117 = Ur_75.Player:AddLeftGroupbox("Optimization", "gauge")
Ur_117:AddToggle("RemoveOtherTrees", { Text = "Remove Other Players' Trees", Default = false })
Ur_117:AddToggle("RemoveOtherFruit", { Text = "Remove Other Players' Fruit", Default = false })
Ur_38 = Ur_75.Player:AddLeftGroupbox("Inventory", "backpack")
Ur_38:AddToggle("AutoEquipItem", { Text = "Auto Equip Item", Default = false })
Ur_38:AddDropdown("EquipItems", {
    Text = "Items To Equip",
    Values = Cu.equipNames,
    Default = {},
    Multi = true,
    Callback = fns.onEquipItems
})
Ur_38:AddSlider("EquipLoopDelay", { Text = "Loop Delay", Default = 1, Min = 0.2, Max = 20, Rounding = 1 })
Ur_117 = Ur_75.Player:AddRightGroupbox("Fly", "feather")
Ur_117:AddToggle("Fly", { Text = "Fly", Default = false })
Ur_117:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
BY, C5, BD, fns.connection, connection2, DB, CM, C7, CH, Ct, BH = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
C6.Fly:OnChanged(fns.fn1339)
C6.WalkSpeedEnabled:OnChanged(fns.fn495)
RunService.Stepped:Connect(fns.onStepped)
UserInputService.JumpRequest:Connect(fns.onJumpRequest)
BY = Workspace.CurrentCamera
RunService.RenderStepped:Connect(fns.onRenderStepped)
DB = function(r3)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not r3)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not r3
        end
    end)
    if not r3 then
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
C6.AntiGameplayPause:OnChanged(fns.fn1326)
Ur_47 = Ur_75.Settings:AddLeftGroupbox("Menu", "wrench")
Ur_47:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
B_.ToggleKeybind = fns.Options.MenuKeybind
C5 = tick()
BD = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local RI = v
        pcall(function()
            RI:Disable()
        end)
    end
end)
CM = fns.fn252
fns.connection = UserInputService.InputBegan:Connect(fns.onInputBegan)
connection2 = UserInputService.InputChanged:Connect(fns.onInputChanged)
Ur_47:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
Ur_47:AddButton("Unload", fns.onUnload)
B_:OnUnload(fns.fn850)
Ur_57:SetLibrary(B_)
Ur_57:SetFolder("TempoHub")
Ur_57:SaveDefault("Evil Hello Kitty")
BP:SetLibrary(B_)
BP:IgnoreThemeSettings()
BP:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
BP:SetFolder("TempoHub/GreedyGrowers")
Ur_38 = BP:BuildConfigSection(Ur_75.Settings)
C7 = fns.fn1755
CH = fns.fn970
Ct = fns.fn1287
BH = function(s5)
    local Sh
    Sh = nil
    local Si = type(s5) ~= "table" or type(s5.idx) ~= "string"
    local Sm = if Si then 1 else 0
    local Sk = 3428 * Sm + 338 * (1 - Sm)
    local Sl = 2374 * Sm + 3655 * (1 - Sm)
    if not ((Sk * 2340 + Sl * 1519 + Sk * Sl) % 16777213 == 2988485) then
        Si = type(s5.type) ~= "string"
    end
    if not Si then
        Si = BP.Ignore[s5.idx]
    end
    if Si then
        return false
    end
    Sh = C7(s5.type, s5.idx)
    if not Sh then
        return false
    end
    local Si_1 = pcall(function()
        if s5.type == "Input" then
            if type(s5.text) ~= "string" then
                return
            end
            Sh:SetValue(s5.text)
        elseif s5.type == "ColorPicker" then
            Sh:SetValueRGB(Color3.fromHex(s5.value), s5.transparency)
        elseif s5.type == "KeyPicker" then
            Sh:SetValue({ s5.key, s5.mode, s5.modifiers })
            if s5.mode == "Toggle" and s5.toggled ~= nil then
                Sh.Toggled = s5.toggled
                Sh:Update()
            end
        else
            Sh:SetValue(s5.value)
        end
    end)
    return Si_1
end
Ur_38:AddDivider()
Ur_38:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
Ur_38:AddButton("Export Config to Clipboard", fns.onExportConfigToClipboard)
Ur_38:AddButton("Import Config from Clipboard Text", fns.onImportConfigFromClipboardTex)
Ur_57:ApplyToTab(Ur_75.Settings)
Ur_57:LoadDefault()
BP:LoadAutoloadConfig()
task.spawn(fns.autoBuySeedsLoop)
task.spawn(fns.autoBuyFurnitureLoop)
task.spawn(fns.autoCompostSeedsLoop)
task.spawn(fns.autoHarvestLoop)
task.spawn(fns.autoHarvestLoop2)
task.spawn(fns.autoPlantLoop)
task.spawn(fns.autoOrganiseTreesLoop)
task.spawn(fns.autoPickupTreesLoop)
task.spawn(fns.autoCollectFruitLoop)
task.spawn(fns.autoSellAtMaxLoop)
task.spawn(fns.autoRebirthLoop)
task.spawn(fns.autoBuyEggsLoop)
task.spawn(fns.autoBuyGearLoop)
task.spawn(fns.autoBuyWormsLoop)
task.spawn(fns.autoFarmersMarketLoop)
task.spawn(fns.autoCollectIndexLoop)
task.spawn(fns.autoFeedPetsLoop)
task.spawn(fns.autoCollectFindsLoop)
task.spawn(fns.autoStorkLoop)
task.spawn(fns.autoEquipItemLoop)
task.spawn(function()
    local TX
    TX = function(ud)
        for i, descendant in ud:GetDescendants() do
            if descendant:IsA("BasePart") then
                descendant.LocalTransparencyModifier = 1
            else
                local Tz = descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam")
                if Tz then
                    descendant.Enabled = false
                end
            end
        end
    end
    local function TY()
        local BigField = Workspace:FindFirstChild("BigField")
        local TI = BigField and BigField:FindFirstChild("PlayerPlots")
        if not TI then
            return
        end
        local Value2 = C6.RemoveOtherTrees.Value
        local Value = C6.RemoveOtherFruit.Value
        for i, child in TI:GetChildren() do
            if child:GetAttribute("OwnerUserId") ~= LocalPlayer.UserId then
                for i, child in child:GetChildren() do
                    if child.Name:match("^PlotTree_") then
                        if Value2 then
                            TX(child)
                        elseif Value then
                            local FruitSpawns = child:FindFirstChild("FruitSpawns")
                            if FruitSpawns then
                                TX(FruitSpawns)
                            end
                        end
                    end
                end
            end
        end
    end
    while not B_.Unloaded do
        if C6.RemoveOtherTrees.Value or C6.RemoveOtherFruit.Value then
            pcall(TY)
        end
        task.wait(2)
    end
end)
task.spawn(function()
    local folder
    folder = nil
    local Ub
    folder = nil
    Ub = function()
        if folder then
            folder:Destroy()
            folder = nil
        end
    end
    local function Uc(uF)
        Ub()
        folder = Instance.new("Folder")
        folder.Name = "OuroPlacementViz"
        local T1 = math.min(#uF, 150)
        local T7 = 1
        while T7 <= T1 do
            local T8 = T7
            local part = Instance.new("Part")
            part.Shape = Enum.PartType.Ball
            part.Size = Vector3.new(1.5, 1.5, 1.5)
            part.Anchored = true
            part.CanCollide = false
            part.CanQuery = false
            part.CastShadow = false
            part.Material = Enum.Material.Neon
            local T2 = T8 == 1 and Color3.fromRGB(255, 170, 80)
            local T3 = T2 or Color3.fromRGB(110, 200, 255)
            part.Color = T3
            part.Transparency = 0.35
            part.Position = uF[T8]
            part.Parent = folder
            T7 += 1
        end
        folder.Parent = Workspace
    end
    while not B_.Unloaded do
        if C6.VisualizePlacement.Value then
            local Ud = CP()
            if Ud and #Ud > 0 then
                pcall(Uc, Ud)
            else
                Ub()
            end
        else
            Ub()
        end
        task.wait(1)
    end
    Ub()
end)
task.spawn(fns.antiGameplayPauseLoop)
task.spawn(fns.antiAfkLoop)
B_:Notify("Greedy Growers loaded")
end)(...)

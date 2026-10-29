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
getgenv().TempoHoodSubtitle = "+1 DOUBLE JUMP BIKE ESCAPE!"
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
local md
local Label
local RequestAuraAction
local Toggles
local mj
local m0
local mI
local ItemShopRequest
local connection3
local CoinConfig
local nv
local RequestWorldTeleport
local nc
local mc
local mU
local mB
local VirtualUser
local mi
local m_
local mH
local no
local mo
local m5
local mN
local nu
local mu
local nb
local ProgressionConfig
local mA
local nh
local mh
local mZ
local mG
local nn
local mn
local m4
local mM
local nt
local mt
local na
local mS
local mz
local ng
local Progression
local mY
local RequestRebirth
local StageTrackerData
local m3
local mL
local ns
local ms
local m9
local ny
local my
local nf
local mf
local mX
local mE
local nl
local ml
local connection
local mK
local connection2
local mr
local m8
local mQ
local nx
local RequestTrailAction
local ne
local me
local mW
local mD
local nk
local mk
local m1
local WorldContext
local nq
local mq
local m7
local mP
local Library
local mw
local Options
local function fn14(f3)
    if not f3 or not f3.Part or not f3.Part.Parent then
        return false
    end
    local Position = f3.Part.Position
    nv(Position, nl)
    if not f3.Part.Parent then
        return true
    end
    mM(f3)
    nl = Position
    task.wait(0.18)
    local sh_2 = f3.Part.Parent and ng[f3.Id] and os.clock() - ng[f3.Id] < 2
    if sh_2 then
        nv(f3.Part.Position, nl)
        if f3.Part.Parent then
            mM(f3)
            nl = f3.Part.Position
            task.wait(0.2)
        end
    end
    return not f3.Part.Parent
end
local function worker5()
    while not Library.Unloaded do
        local tw = mq("AutoBuyWinsShop") and not mq("AutoWin") and not mq("AutoTrain") and not mq("AutoCollectCoins")
        if tw then
            pcall(mZ)
        end
        task.wait(1)
    end
end
local function onUnload()
    Library:Unload()
end
local function fn120(bf)
    if string.find(bf, "2xWin", 1, true) then
        return string.gsub(bf, "2xWin$", "Win")
    end
    return bf
end
local function fn134()
    local WinClaimTeleport = ProgressionConfig.WinClaimTeleport
    local pN = WinClaimTeleport and WinClaimTeleport.SpawnPath
    local pO = pN
    if pN then
        pN = m1(pO)
    end
    local pO_1 = WinClaimTeleport
    local pP = pN
    if pO_1 then
        pO_1 = tonumber(WinClaimTeleport.Clearance)
    end
    local pM_1 = pO_1 or 4
    if pN then
        pN = pP:IsA("BasePart")
    end
    if pN then
        return CFrame.new(pP.Position + Vector3.new(0, pM_1, 0))
    end
    local LobbyThings = workspace:FindFirstChild("LobbyThings")
    local pN_1 = LobbyThings and LobbyThings:FindFirstChild("SpawnLocation")
    local pM_3 = pN_1
    if pN_1 then
        pN_1 = pM_3:IsA("BasePart")
    end
    if pN_1 then
        return CFrame.new(pM_3.Position + Vector3.new(0, pM_1, 0))
    end
    return nil
end
local function fn143(L, M)
    return string.format('<font color="%s">%s</font>', M, L)
end
local function worker4()
    while not Library.Unloaded do
        if mq("AutoBuyItemShop") then
            pcall(mr)
        end
        task.wait(2)
    end
end
local function worker9()
    local tj = tonumber(mN("Wins", 0)) or 0
    local tk = tj
    local tj_1 = os.clock()
    local tl = 0
    local tm
    while not Library.Unloaded do
        if mq("AutoWin") then
            local tn_1 = tonumber(mN("Wins", 0)) or 0
            if tn_1 ~= tk then
                tk = tn_1
                tj_1 = os.clock()
                tm = nil
            end
            local tn_2 = m8()
            if tn_2 and tn_2.Position.Y >= 2022.7 then
                local tn_4 = tm or os.clock()
                tm = tn_4
            else
                tm = nil
            end
            local tn_5 = os.clock() - tj_1 >= 5
            local to_3 = tm and os.clock() - tm >= 4
            local tp_1 = tn_5
            if tp_1 then
                tp_1 = to_3
            end
            if tp_1 then
                tp_1 = os.clock() - tl >= 3
            end
            if tp_1 then
                tl = os.clock()
                pcall(mw)
                tj_1 = os.clock()
                tm = nil
                task.wait(0.5)
            else
                pcall(mL)
            end
        elseif mq("AutoTrain") then
            tm = nil
            pcall(mQ)
        elseif mt then
            tm = nil
            mt = nil
        else
            tm = nil
        end
        local wait = task.wait
        local to_4 = (mq("AutoWin"))
        if to_4 then
            local max = math.max
            local tq = tonumber(nx("WinDelay", 0.5)) or 0.5
            to_4 = max(tq, 0)
        end
        local tp_3 = to_4 or 0.05
        wait(tp_3)
    end
end
local function onOnClientEvent(fj)
    local rO = typeof(fj) ~= "table" or typeof(fj.CoinId) ~= "string"
    if rO then
        return
    end
    if fj.Action == "Rejected" then
        ng[fj.CoinId] = os.clock()
    elseif fj.Action == "Collected" then
        ng[fj.CoinId] = nil
        nb[fj.CoinId] = os.clock()
    end
end
local function worker()
    local s4_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local s3 = math.floor(os.clock() - mz)
        if s3 < 60 then
            s4_1 = s3 .. "s"
        elseif s3 < 3600 then
            s4_1 = string.format("%dm %ds", math.floor((s3) / (60)), s3 % 60)
        else
            s4_1 = string.format("%dh %dm", math.floor((s3) / (3600)), math.floor((s3 % 3600) / (60)))
        end
        Label:SetText(mU("Session time", s4_1, my))
    end
end
local function fn175()
    local Character = nc.Character
    local oG = Character and Character:FindFirstChildOfClass("Humanoid")
    return oG
end
local function fn184()
    local qz = nh()
    if not qz then
        return
    end
    local qA = m1(qz.Path)
    local qz_1 = not qA or not qA:IsA("BasePart")
    if qz_1 then
        return
    end
    mn = true
    mt = CFrame.new(qA.Position + Vector3.new(0, 3, 0))
    local qz_2 = m_()
    if qz_2 and qz_2.Health > 0 then
        qz_2:Move(Vector3.new(0, 0, -1), false)
    end
end
local function fn192(bY)
    return CFrame.new(bY.X, bY.Y + md, bY.Z)
end
local function fn197(aP, aQ)
    if aP.Amount == aQ.Amount then
        return aP.Name < aQ.Name
    end
    return aP.Amount < aQ.Amount
end
local function fn204(b2)
    return CFrame.new(b2.X, b2.Y + 3.5, b2.Z)
end
local function fn228(X)
    local ot = Toggles[X]
    return ot ~= nil and ot.Value == true
end
local function fn231()
    if WorldContext.GetWorldKey() == "World2" then
        return false
    elseif WorldContext.CanTeleportTo("World2") ~= true then
        return false
    else
        local pF = if os.clock() - ml < 5 then 1 else 0
        if pF == 1 then
            return false
        end
        ml = os.clock()
        RequestWorldTeleport:FireServer("World2")
        return true
    end
end
local function fn245()
    if setclipboard then
        setclipboard(m7)
    elseif toclipboard then
        toclipboard(m7)
    end
    Library:Notify("Copied Discord invite to clipboard")
end
local function fn252(bQ)
    local WinButtons = workspace:FindFirstChild("WinButtons")
    local pH = WinButtons and WinButtons:FindFirstChild(bQ)
    local pG_1 = pH
    if pH then
        pH = pG_1:FindFirstChild("Touch")
    end
    local pG_2 = pH
    if pH then
        pH = pG_2:IsA("BasePart")
    end
    if pH then
        return pG_2
    end
    return nil
end
local function fn264(O, P, Q)
    return string.format("<b>%s</b> %s %s", O, m3("-", "#5a6070"), m3(P, Q))
end
local function fn283()
    local rb = tonumber(mN("Wins", 0)) or 0
    local rb_1 = nk("OwnedBikes")
    local rd = WorldContext.GetConfiguredBikePedestals()
    local re = {}
    for k, v in pairs(rd) do
        if not rb_1[v] then
            local rd_1 = ProgressionConfig.GetBike(v)
            if rd_1 then
                local rf = tonumber(rd_1.CostWins) or 0
                local rf_1 = tonumber(string.match(k, "%d+")) or 0
                re[#re + 1] = { Id = v, Cost = rf, Pedestal = k, Order = rf_1 }
            end
        end
    end
    table.sort(re, function(ep, eq)
        if ep.Cost == eq.Cost then
            return ep.Order < eq.Order
        end
        return ep.Cost < eq.Cost
    end)
    local rb_2 = re[1]
    if not rb_2 or rb < rb_2.Cost then
        return
    end
    local LobbyThings = workspace:FindFirstChild("LobbyThings")
    local rd_4 = LobbyThings and LobbyThings:FindFirstChild("WinsShop")
    local rc_2 = rd_4
    if rd_4 then
        rd_4 = rc_2:FindFirstChild("Pedestals")
    end
    local rc_3 = rd_4
    if rd_4 then
        rd_4 = rc_3:FindFirstChild(rb_2.Pedestal)
    end
    local rb_3 = rd_4
    local rc_4 = rb_3 and rb_3:FindFirstChild("Touch")
    local rc_5 = not rc_4 or not rc_4:IsA("BasePart")
    if rc_5 then
        local rc_6 = WorldContext.CanTeleportTo("World2") == true and WorldContext.GetWorldKey() ~= "World2"
        if rc_6 then
            local rq = if os.clock() - ml >= 5 then 1 else 0
            if rq == 1 then
                ml = os.clock()
                RequestWorldTeleport:FireServer("World2")
            end
        end
        return
    end
    mh(mY(rc_4.Position))
    task.wait(0.05)
    mh(mP(rc_4))
    no(rc_4)
end
local function fn299()
    mt = nil
    connection:Disconnect()
    connection2:Disconnect()
    connection3:Disconnect()
    select("#", "+1 Double Jump Bike Escape unloaded")
end
local function fn310()
    local qe_1
    local qd_1
    local qc = mW[nx("WinPlate", "")]
    if not qc then
        return
    end
    qe_1, qd_1 = mB(qc.Name)
    if not qe_1 then
        mf()
        return
    end
    local qf = qd_1 or nn(qc.Name)
    local qd_2 = qf or mi(qc.Name, qe_1, 2.5)
    if not qd_2 then
        mw()
        return
    end
    mG(qd_2)
end
local function fn333(aq, ar)
    local oI = Progression:FindFirstChild(aq)
    local oJ = oI and oI:IsA("ValueBase")
    if oJ then
        return oI.Value
    end
    return ar
end
local function onInputBegan()
    mH = tick()
end
local function onHeartbeat()
    if not mt then
        return
    end
    local o3 = m8()
    if not o3 then
        return
    end
    if mn and (o3.Position - mt.Position).Magnitude < 8 then
        return
    end
    o3.AssemblyLinearVelocity = Vector3.zero
    o3.AssemblyAngularVelocity = Vector3.zero
    o3.CFrame = mt
end
local function fn401(aw, ax)
    local oL = Progression:FindFirstChild(aw)
    local oM = oL and oL:FindFirstChild(ax)
    local oM_1 = oM ~= nil and oM:IsA("BoolValue") and oM.Value == true
    return oM_1
end
local function fn421()
    local pU = ne()
    if not pU then
        mt = nil
        return
    end
    mh(pU)
    mD(pU.Position)
    task.wait(0.4)
    mt = nil
    local pV = m8()
    if pV then
        pV.AssemblyLinearVelocity = Vector3.zero
        pV.AssemblyAngularVelocity = Vector3.zero
        pV.CFrame = pU
    end
end
local function fn441(ac, ad)
    local ow = Options[ac]
    if ow == nil or ow.Value == nil then
        return ad
    end
    return ow.Value
end
local function worker7()
    while not Library.Unloaded do
        if mq("AutoBuyTrails") then
            pcall(m9)
        end
        if mq("AutoBuyAuras") then
            pcall(mo)
        end
        task.wait(1)
    end
end
local function fn480(bG)
    local pA_1
    local pz_1
    pz_1, pA_1 = m4(bG)
    if pz_1 then
        return pz_1, pA_1
    end
    return mu(bG), nil
end
local function fn509(fE, fF)
    mh(mY(fE))
    mD(fE)
    task.wait(0.08)
    mh(CFrame.new(fE + Vector3.new(0, 4, 0)))
    local r5 = fF and (fE - fF).Magnitude or math.huge
    local max2 = math.max
    local r6 = (tonumber(CoinConfig.MaxCollectionSweepDistance))
    local sc = if r6 then 1 else 0
    local sa = 2074 * sc + 3156 * (1 - sc)
    local sb = 2615 * sc + 3611 * (1 - sc)
    if not ((sa * 1769 + sb * 1165 + sa * sb) % 16777213 == 12138891) then
        r6 = 140
    end
    local r7 = max2(1, r6)
    local r5_2 = 0.35
    if r5 > r7 then
        r5_2 = 0.9
    elseif r5 > r7 * 0.5 then
        r5_2 = 0.6
    end
    local max = math.max
    local r6_1 = (tonumber(CoinConfig.CollectionValidationGraceSeconds))
    local sc_1 = if r6_1 then 1 else 0
    local sa_1 = 1631 * sc_1 + 1307 * (1 - sc_1)
    local sb_1 = 1087 * sc_1 + 529 * (1 - sc_1)
    if not ((sa_1 * 4005 + sb_1 * 740 + sa_1 * sb_1) % 16777213 == 9109432) then
        r6_1 = 0.2
    end
    local r7_1 = max(0.2, r6_1)
    local r6_2 = tonumber(CoinConfig.CollectionValidationWindow) or 0.65
    local r8 = max(0.65, r6_2)
    local r5_3 = math.max(r5_2, r7_1 + r8 * 0.5)
    task.wait(r5_3)
end
local function fn541()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    mE = tick()
end
local function onCopyJoinScript_JobID()
    local s1 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, mS)
    if setclipboard then
        setclipboard(s1)
    elseif toclipboard then
        toclipboard(s1)
    end
    Library:Notify("Copied join script to clipboard")
end
local function fn566()
    local qZ_1
    local qX = tonumber(mN("Wins", 0)) or 0
    local qX_1
    qZ_1, qX_1 = nil, -1
    for i, v in ipairs(ProgressionConfig.GetOrderedAuras()) do
        local q__1 = v.AuraId
        local q0 = tonumber(v.CostWins) or 0
        local q0_1 = v.Aura and tonumber(v.Aura.WinMultiplier)
        local q0_2 = q0_1 or 0
        if ms("OwnedAuras", q__1) then
            if q0_2 > qX_1 then
                qZ_1, qX_1 = q__1, q0_2
            end
        elseif qX >= q0 then
            RequestAuraAction:FireServer(q__1, "BuyWithWins")
            return
        end
    end
    local qX_2 = mN("EquippedAura", "") or ""
    local qY_1 = tostring(qX_2)
    if qZ_1 and qY_1 ~= qZ_1 then
        RequestAuraAction:FireServer(qZ_1, "ToggleEquip")
    end
end
local function fn577(bh)
    return string.find(bh, "2xWin", 1, true) ~= nil
end
local function onInputChanged(hD)
    local UserInputType = hD.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        mH = tick()
    end
end
local function fn590(gM)
    local DiscordGroup = gM:AddLeftGroupbox("Discord", nil, true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = na })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = na })
end
local function fn605()
    local Character = nc.Character
    local oD = Character and Character:FindFirstChild("HumanoidRootPart")
    return oD
end
local function fn610()
    local sm = m8()
    if not sm then
        return
    end
    local Position = sm.Position
    local max = math.max
    local so = tonumber(CoinConfig.CollectionHorizontalRadius) or 10
    local sp = max(0.1, so)
    local so_1 = tonumber(CoinConfig.CollectionVerticalRadius) or 12
    local sq = max(0.1, so_1)
    local floor = math.floor
    local sr = tonumber(CoinConfig.MaxCollectionsPerPlayerPerScan) or 6
    local ss = max(1, floor(sr))
    local sm_2 = 0
    for i, v in ipairs(m0()) do
        if sm_2 >= ss then
            break
        end
        if v.Part and v.Part.Parent then
            local so_4 = v.Part.Position - Position
            if (so_4.X / sp) ^ 2 + (so_4.Y / sq) ^ 2 + (so_4.Z / sp) ^ 2 <= 1 then
                mM(v)
                sm_2 = sm_2 + 1
            end
        end
    end
end
local function fn612(b0)
    return CFrame.new(b0.Position.X, b0.Position.Y + b0.Size.Y / 2 + 3.5, b0.Position.Z)
end
local function fn636(cR)
    mh(mY(cR.Position))
    mD(cR.Position)
    task.wait(0.03)
    mh(mP(cR))
    no(cR)
end
local function fn641(ca)
    local pK = m8()
    if not pK then
        return
    end
    mn = false
    mt = ca
    pK.AssemblyLinearVelocity = Vector3.zero
    pK.AssemblyAngularVelocity = Vector3.zero
    pK.CFrame = ca
end
local function fn666()
    local rT = CoinConfig.RuntimeFolderName or "Collectibles"
    local rU = workspace:FindFirstChild(tostring(rT))
    if not rU then
        return {}
    end
    local rT_1 = {}
    for i, child in rU:GetChildren() do
        if child:IsA("BasePart") then
            local attr2 = child:GetAttribute("CoinId")
            local attr = child:GetAttribute("PersonalOwnerUserId")
            local rW = typeof(attr2) == "string"
            if rW then
                rW = attr == nil or attr == nc.UserId
            end
            if rW then
                local rV_1 = not nb[attr2] or os.clock() - nb[attr2] > 1
                if rV_1 then
                    local rV_2 = #rT_1 + 1
                    local Position = child.Position
                    local rX_2 = tonumber(child:GetAttribute("CourseProgress")) or 0
                    rT_1[rV_2] = { Part = child, Id = attr2, Position = Position, Progress = rX_2 }
                end
            end
        end
    end
    table.sort(rT_1, function(fB, fC)
        return fB.Progress < fC.Progress
    end)
    return rT_1
end
local function fn672()
    pcall(function()
        ItemShopRequest:InvokeServer("EquipBest", {})
    end)
end
local function fn673(aE)
    local oR = {}
    local oS = Progression:FindFirstChild(aE)
    if not oS then
        return oR
    end
    for i, child in oS:GetChildren() do
        if child:IsA("BoolValue") then
            oR[child.Name] = child.Value == true
        end
    end
    return oR
end
local function fn677()
    local sV_1
    local sU_1
    if identifyexecutor then
        sV_1, sU_1 = identifyexecutor()
        local sW = sV_1 ~= ""
        local sX = type(sV_1) == "string" and sW
        if sX then
            local sW_1 = type(sU_1) == "string" and sU_1 ~= "" and sV_1 .. " " .. sU_1
            nf = sW_1 or sV_1
        end
    end
end
local function fn681(bj)
    local pg = mI(bj)
    local max = math.max
    local pi = math.floor
    local pj = tonumber(StageTrackerData:GetAttribute("ExpectedStageCount")) or 20
    local pk = max(1, pi(pj))
    local po = 1
    while true do
        if not (po <= pk) then
            return nil
        end
        local pp = po
        local attr = StageTrackerData:GetAttribute("Stage" .. pp .. "Name")
        pi = tonumber(StageTrackerData:GetAttribute("Stage" .. pp .. "X"))
        if attr == pg and pi then
            break
        end
        po += 1
    end
    local new = Vector3.new
    local pj_2 = mA(bj) and nq
    local pk_1 = pj_2 or nu
    return new(pi, ny, pk_1)
end
local function worker2()
    while not Library.Unloaded do
        task.wait(2)
        if mq("AntiAfk") then
            local tA = tick() - mH
            local tB = tick() - mE
            if tA >= 300 and tB >= 60 then
                pcall(mk)
            else
                if tA < 300 and tB >= 300 then
                    pcall(mk)
                end
            end
        end
    end
end
local function worker3()
    while not Library.Unloaded do
        if mq("AutoEquipBestItems") then
            pcall(mc)
        end
        task.wait(3)
    end
end
local function fn716()
    local qC = tonumber(mN("RebirthBoostPercent", 0)) or 0
    local qC_1 = (tonumber(mN("Level", 1)))
    local qI = if qC_1 then 1 else 0
    local qG = 4085 * qI + 3178 * (1 - qI)
    local qH = 1277 * qI + 763 * (1 - qI)
    if not ((qG * 2368 + qH * 2148 + qG * qH) % 16777213 == 855608) then
        qC_1 = 1
    end
    local qE = qC_1
    local qC_2 = ProgressionConfig.GetRebirthRequirement(qC)
    if qE < qC_2 then
        return
    end
    RequestRebirth:FireServer()
end
local function fn719()
    local qL_1
    local qJ = tonumber(mN("Wins", 0)) or 0
    local qJ_1
    qL_1, qJ_1 = nil, -1
    for i, v in ipairs(ProgressionConfig.GetOrderedTrails()) do
        local TrailId = v.TrailId
        local qN = tonumber(v.CostWins) or 0
        local qN_1 = v.Trail and tonumber(v.Trail.SpeedMultiplier)
        local qN_2 = qN_1 or 0
        if ms("OwnedTrails", TrailId) then
            if qN_2 > qJ_1 then
                qL_1, qJ_1 = TrailId, qN_2
            end
        elseif qJ >= qN then
            RequestTrailAction:FireServer(TrailId, "BuyWithWins")
            return
        end
    end
    local qJ_2 = mN("EquippedTrail", "") or ""
    local qK_1 = tostring(qJ_2)
    if qL_1 and qK_1 ~= qL_1 then
        RequestTrailAction:FireServer(qL_1, "ToggleEquip")
    end
end
local function worker8()
    while not Library.Unloaded do
        if mq("AutoRebirth") then
            pcall(me)
        end
        task.wait(2)
    end
end
local function onRscripts()
    if setclipboard then
        setclipboard(m5)
    elseif toclipboard then
        toclipboard(m5)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function fn750(a9)
    local o6 = workspace
    for i, v in ipairs(a9) do
        local o7 = o6 and o6:FindFirstChild(v)
        o6 = o7
    end
    return o6
end
local function fn780()
    local sA = m0()
    if #sA == 0 then
        local sB_1 = not mq("AutoWin") and not mq("AutoTrain")
        if sB_1 then
            mt = nil
        end
        return
    end
    local sB_2 = m8()
    local sC = 1
    if sB_2 then
        local sD = math.huge
        for i, v in ipairs(sA) do
            local Magnitude = (v.Position - sB_2.Position).Magnitude
            if Magnitude < sD then
                sD = Magnitude
                sC = i
            end
        end
    end
    local sB_3 = #sA - 1
    local sR = 0
    while sR <= sB_3 do
        local sS = sR
        local sB_4 = Library.Unloaded or not mq("AutoCollectCoins")
        if sB_4 then
            break
        end
        local sB_5 = mq("AutoWin") or mq("AutoTrain")
        if sB_5 then
            break
        end
        local sB_6 = sA[(sC - 1 + sS) % #sA + 1]
        pcall(ns, sB_6)
        sR += 1
    end
    local sA_1 = not mq("AutoWin") and not mq("AutoTrain")
    if sA_1 then
        mt = nil
    end
end
local function fn833()
    local qk = (tonumber(mN("Rebirths", 0)))
    local qs = if qk then 1 else 0
    local qq = 3880 * qs + 1072 * (1 - qs)
    local qr = 1891 * qs + 3667 * (1 - qs)
    if not ((qq * 2716 + qr * 3088 + qq * qr) % 16777213 == 6937355) then
        qk = 0
    end
    local ql
    local qm = qk
    for i, v in ipairs(ProgressionConfig.Treadmill.Treadmills) do
        local qk_1 = not v.GamePassId
        if qk_1 ~= false then
            qk_1 = qm >= (v.RequiredRebirths or 0)
        end
        if qk_1 then
            local qk_2 = not ql
            if not qk_2 then
                qk_2 = (v.StepMultiplier or 0) > (ql.StepMultiplier or 0)
            end
            if qk_2 then
                ql = v
            end
        end
    end
    return ql
end
local function worker6()
    while not Library.Unloaded do
        if mq("AutoCollectCoins") then
            local tu = mq("AutoWin") or mq("AutoTrain")
            if tu then
                pcall(mX)
                task.wait(0.2)
            else
                pcall(nt)
                task.wait(1)
            end
        else
            task.wait(0.5)
        end
    end
end
local function fn866(cY, cZ, c_)
    local p7 = mY(cZ)
    local p8 = os.clock()
    local qa = p8 + (c_ or 2.5)
    mh(p7)
    mD(cZ)
    while true do
        if not (os.clock() < qa) then
            mh(mK(cZ))
            mD(cZ)
            task.wait(0.2)
            local p8_1 = nn(cY)
            if p8_1 then
                return p8_1
            end
            mh(p7)
            mD(cZ)
            return nn(cY)
        end
        local p8_2 = Library.Unloaded or not mq("AutoWin")
        if p8_2 then
            break
        end
        local p8_3 = nn(cY)
        if p8_3 then
            return p8_3
        end
        mh(p7)
        if os.clock() - mj >= 0.2 then
            mD(cZ)
        end
        task.wait(0.05)
    end
    return nil
end
mc = nil
md = nil
me = nil
mf = nil
Progression = nil
mh = nil
mi = nil
mj = nil
mk = nil
ml = nil
mn = nil
mo = nil
ItemShopRequest = nil
mq = nil
mr = nil
ms = nil
mt = nil
mu = nil
RequestWorldTeleport = nil
mw = nil
RequestTrailAction = nil
my = nil
mz = nil
mA = nil
mB = nil
RequestAuraAction = nil
mD = nil
mE = nil
RequestRebirth = nil
mG = nil
mH = nil
mI = nil
WorldContext = nil
mK = nil
mL = nil
mM = nil
mN = nil
CoinConfig = nil
mP = nil
mQ = nil
mS = nil
ProgressionConfig = nil
mU = nil
Label = nil
mW = nil
mX = nil
mY = nil
mZ = nil
local mm, ItemShopConfig
m_ = nil
m0 = nil
m1 = nil
connection = nil
m3 = nil
m4 = nil
m5 = nil
connection3 = nil
m7 = nil
m8 = nil
m9 = nil
na = nil
nb = nil
nc = nil
Options = nil
ne = nil
nf = nil
ng = nil
nh = nil
VirtualUser = nil
Toggles = nil
nk = nil
nl = nil
StageTrackerData = nil
nn = nil
no = nil
nq = nil
connection2 = nil
ns = nil
nt = nil
nu = nil
nv = nil
Library = nil
nx = nil
ny = nil
local np, nM
np = nil
VirtualUser, nc, m7, m5, ProgressionConfig, ItemShopConfig, CoinConfig, WorldContext, RequestRebirth, RequestAuraAction, RequestTrailAction, RequestWorldTeleport, ItemShopRequest = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local tI_17 = game:GetService("Players")
local tI_1 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
nc = tI_17.LocalPlayer
local tI_15 = "+1 Double Jump Bike Escape"
m7 = "https://discord.gg/K7Qxnxkk46"
m5 = "https://discord.gg/K7Qxnxkk46"
local tI_4 = tI_1:WaitForChild("GameSystems")
local tI_8 = tI_4:WaitForChild("Remotes")
local tI_6 = tI_4:WaitForChild("Shared")
ProgressionConfig = require(tI_6:WaitForChild("ProgressionConfig"))
ItemShopConfig = require(tI_6:WaitForChild("ItemShopConfig"))
CoinConfig = require(tI_6:WaitForChild("CoinConfig"))
local tI_14 = require(tI_6:WaitForChild("NumberFormatter"))
WorldContext = require(tI_6:WaitForChild("WorldContext"))
RequestRebirth = tI_8:WaitForChild("RequestRebirth")
RequestAuraAction = tI_8:WaitForChild("RequestAuraAction")
RequestTrailAction = tI_8:WaitForChild("RequestTrailAction")
RequestWorldTeleport = tI_8:WaitForChild("RequestWorldTeleport")
ItemShopRequest = tI_8:WaitForChild("ItemShopRequest")
tI_17 = CoinConfig.RequestRemoteName or "CoinRequest"
mm = tI_8:WaitForChild(tI_17)
tI_17 = CoinConfig.StateRemoteName or "CoinState"
Progression, Library, Toggles, Options, my, nM, mW, na, m3, mU, mq, nx, m8, m_, mN, ms, nk = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
tI_1 = tI_8:WaitForChild(tI_17)
Progression = nc:WaitForChild("Progression")
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
na = fn245
m3 = fn143
mU = fn264
local tI_11 = "#7fd47f"
local nL = "#6ec1ff"
my = "#e8a34d"
local nK = "#8b93a3"
mq = fn228
if (not nM and SaveManager and (not m_ or false) or (not nM or mq or mq)) and ((SaveManager or nM or not mq and 19) and (not nM or (not SaveManager))) and not ((not nM and SaveManager and (not m_ or false) or (not nM or mq or mq)) and ((SaveManager or nM or not mq and 19) and (not nM or (not SaveManager)))) then
    m_ = fn441
    nx = fn605
    m8 = fn175
else
    nx = fn441
    m8 = fn605
    m_ = fn175
end
mN = fn333
ms = fn401
nk = fn673
nM = {}
mW = {}
local nP = {}
for k, v in pairs(ProgressionConfig.WinButtons) do
    tI_17 = #nP + 1
    tI_6 = tonumber(v) or 0
    nP[tI_17] = { Name = k, Amount = tI_6, Double = string.find(k, "2xWin", 1, true) ~= nil }
end
local tI_13 = 7
repeat
    if tI_13 * 71182539 + 10 + 3 >= tI_13 * 71182539 + 10 + 3 + 1 then
        table.sort(nP, fn197)
    else
        table.sort(nP, fn197)
    end
    tI_13 = (tI_13 + 7) % 8
until (tI_13 * 3 + 1) % 8 == 3
for i, v in ipairs(nP) do
    tI_17 = string.format
    tI_6 = tI_14.Compact(v.Amount)
    tI_13 = v.Name
    tI_8 = v.Double and " [2x]"
    nP = tI_8 or ""
    tI_8 = tI_17("+%s - %s%s", tI_6, tI_13, nP)
    v.Label = tI_8
    nM[#nM + 1] = tI_8
    mW[tI_8] = v
end
mt, mn, ml, mj, md, ny, nu, nq, StageTrackerData, connection, np, nl, ng, nb, m1, mI, mA, mu, m4, mB, mf, nn, mY, mP, mK, mD, mh, ne, mw, no, mG, mi, mL, nh, mQ, me, m9, mo, mZ, mr, mc, m0, nv, mM, ns, mX, nt = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
mt = nil
mn = false
ml = 0
mj = 0
md = 400
ny = 1902.7
nu = 5.02
nq = -79.92
StageTrackerData = tI_4:WaitForChild("StageTrackerData")
connection = RunService.Heartbeat:Connect(onHeartbeat)
m1 = fn750
mI = fn120
mA = fn577
mu = fn681
m4 = function(bw)
    local pr
    pr = nil
    local WinButtons = workspace:FindFirstChild("WinButtons")
    local ps_2
    local pt = WinButtons and WinButtons:FindFirstChild(bw)
    local pt_2
    pr = pt
    if not pr then
        return nil
    end
    local Touch = pr:FindFirstChild("Touch")
    local pt_1 = Touch and Touch:IsA("BasePart")
    if pt_1 then
        return Touch.Position, Touch
    end
    ps_2, pt_2 = pcall(function()
        return pr:GetPivot().Position
    end)
    if ps_2 and pt_2 then
        return pt_2, nil
    end
    return nil
end
mB = fn480
mf = fn231
nn = fn252
mY = fn192
mP = fn612
mK = fn204
mD = function(b4)
    if typeof(b4) ~= "Vector3" then
        return
    end
    mj = os.clock()
    pcall(function()
        nc:RequestStreamAroundAsync(b4)
    end)
end
mh = fn641
ne = fn134
mw = fn421
no = function(cD)
    local pX = m8()
    if not pX or not cD or not firetouchinterest then
        return
    end
    local pY_1 = nc.Character and nc.Character:FindFirstChild("BikeCollider")
    local pZ = nc.Character and nc.Character:FindFirstChild("LowerTorso")
    local p_ = { pX, pY_1, pZ }
    for i, v in ipairs(p_) do
        local p6 = v
        local pX_1 = p6 and p6:IsA("BasePart")
        if pX_1 then
            pcall(function()
                firetouchinterest(p6, cD, 0)
                firetouchinterest(p6, cD, 1)
            end)
        end
    end
end
mG = fn636
mi = fn866
mL = fn310
nh = fn833
if mL and not np and (not np or np) and (np and not mL or 131) or (not np and mL and (not np or false) or (mL or not np) and (not m9 or m9)) or ((mL or np) and (mL or not m9 and not np) or (mL or not np) and (not m9 and not np) and (not mL or 131 or mL and np)) or not (mL and not np and (not np or np) and (np and not mL or 131) or (not np and mL and (not np or false) or (mL or not np) and (not m9 or m9)) or ((mL or np) and (mL or not m9 and not np) or (mL or not np) and (not m9 and not np) and (not mL or 131 or mL and np))) then
    mQ = fn184
    me = fn716
    m9 = fn719
else
    m9 = fn184
    mQ = fn716
    me = fn719
end
mo = fn566
mZ = fn283
mr = function()
    local rt_1, rt_5
    local rs_1, rs_5
    rs_1, rt_1 = pcall(function()
        return ItemShopRequest:InvokeServer("GetState", {})
    end)
    local ru = not rs_1 or typeof(rt_1) ~= "table" or rt_1.Success ~= true
    if ru then
        return
    end
    local State = rt_1.State
    local rt_2 = typeof(State) ~= "table" or typeof(State.Stock) ~= "table"
    if rt_2 then
        return
    end
    local rt_3 = tonumber(State.Coins) or tonumber(mN("Coins", 0))
    local ru_1 = rt_3 or 0
    local rt_4 = {}
    local rv = ru_1
    for k, v in pairs(State.Stock) do
        local rs_3 = tonumber(v) or 0
        local rs_4 = ItemShopConfig.Items[k]
        if rs_4 and rs_3 > 0 and rs_4.AdminExclusive ~= true then
            local ru_3 = tonumber(rs_4.CoinsCost) or 0
            if rv >= ru_3 then
                local ru_4 = #rt_4 + 1
                local rx = tonumber(rs_4.SpeedPercent) or 0
                rt_4[ru_4] = { ItemId = k, Cost = ru_3, Speed = rx }
            end
        end
    end
    table.sort(rt_4, function(e2, e3)
        if e2.Speed == e3.Speed then
            return e2.Cost < e3.Cost
        end
        return e2.Speed > e3.Speed
    end)
    for i, v in ipairs(rt_4) do
        local rK = v
        if rv < rK.Cost then
            break
        end
        rs_5, rt_5 = pcall(function()
            return ItemShopRequest:InvokeServer("PurchaseCoins", { ItemId = rK.ItemId })
        end)
        local ru_5 = rs_5 and typeof(rt_5) == "table" and rt_5.Success == true
        if ru_5 then
            rv = rv - rK.Cost
            local rs_6 = typeof(rt_5.State) == "table" and rt_5.State.Coins ~= nil
            if rs_6 then
                local rs_7 = (tonumber(rt_5.State.Coins))
                local rN = if rs_7 then 1 else 0
                local rL = 342 * rN + 3782 * (1 - rN)
                local rM = 2503 * rN + 742 * (1 - rN)
                if not ((rL * 1850 + rM * 1824 + rL * rM) % 16777213 == 6054198) then
                    rs_7 = rv
                end
                rv = rs_7
            end
        end
        task.wait(0.2)
    end
end
mc = fn672
np = 0
nl = nil
ng = {}
nb = {}
tI_1.OnClientEvent:Connect(onOnClientEvent)
m0 = fn666
nv = fn509
mM = function(fS)
    local sd = m8()
    if sd and fS.Part and fS.Part.Parent and firetouchinterest then
        pcall(function()
            firetouchinterest(sd, fS.Part, 0)
            firetouchinterest(sd, fS.Part, 1)
        end)
    end
    local max = math.max
    local sf = tonumber(CoinConfig.MaxCollectionRequestsPerSecond) or 30
    local se_2 = 1 / max(1, sf)
    local sf_1 = os.clock() - np
    if sf_1 < se_2 then
        task.wait(se_2 - sf_1)
    end
    mm:FireServer("Collect", fS.Id)
    np = os.clock()
end
ns = fn14
mX = fn610
nt = fn780
tI_6 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = m7, Copyable = true }, "|", tI_15 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10,
    Size = UDim2.fromOffset(900, 640)
})
nP = {
    Info = tI_6:AddTab("Info", "info"),
    Main = tI_6:AddTab("Main", "gamepad-2"),
    Shop = tI_6:AddTab("Shop", "shopping-cart"),
    Settings = tI_6:AddTab("Settings", "settings")
}
tI_13 = fn590
for k, v in nP do
    tI_13(v)
end
nf, tI_6, tI_8, Label, mS, tI_1 = nil, nil, nil, nil, nil, nil
tI_17 = 7
repeat
    tI_13 = (tI_17 * 1 + 0) % 3 + 1
    if tI_13 <= 2 then
        if tI_13 <= 1 then
            if (tI_17 * 1 + 2) * 9 % 4 == ((tI_17 * 1 + 2) * 9 + 4) % 4 then
                tI_1 = #mS > 18
            else
                mS = #tI_1 > 18
            end
            tI_17 = (tI_17 + 1) % 12
        else
            tI_13 = { "omtllmb", "cltfmz", "rphcn", "lfodkhbskn", "vqhgnueok", "ltsch", "hoj" }
            local ux = tI_17
            tI_14 = tI_13[ux % 7 + 1]
            if tI_14:len() >= tI_14:reverse():rep(ux % 3 + 2):len() then
                nP = "Unknown"
                pcall(fn677)
                nc = (nil):AddLeftGroupbox("Account", "circle-user")
                nc:AddLabel(nL("User", mU.Name, tI_6), true)
                nc:AddLabel(nL("Status", "Keyless", tI_6), true)
                nc:AddLabel(nL("Executor", "Unknown", tI_6), true)
                my = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
                my:AddLabel(tI_15(Label .. " [" .. tostring(game.PlaceId) .. "]", tI_8), true)
                my:AddLabel(nL("Place ID", tostring(game.PlaceId), tI_8), true)
                nf = my:AddLabel(nL("Session time", "0s", m3), true)
            else
                nf = "Unknown"
                pcall(fn677)
                tI_6 = nP.Info:AddLeftGroupbox("Account", "circle-user")
                tI_6:AddLabel(mU("User", nc.Name, tI_11), true)
                tI_6:AddLabel(mU("Status", "Keyless", tI_11), true)
                tI_6:AddLabel(mU("Executor", nf, tI_11), true)
                tI_8 = nP.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                tI_8:AddLabel(m3(tI_15 .. " [" .. tostring(game.PlaceId) .. "]", nL), true)
                tI_8:AddLabel(mU("Place ID", tostring(game.PlaceId), nL), true)
                Label = tI_8:AddLabel(mU("Session time", "0s", my), true)
            end
            tI_17 = (tI_17 + 1) % 12
        end
    else
        local ur = bit32.rrotate(bit32.bxor(bit32.lrotate(tI_17, 16), string.byte(tostring(tI_6))), 30)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(ur, 1649720057), 1803931135), (bit32.bxor(bit32.band(ur, 2645247238), 2901674489))), 1803931135), 2901674489) == ur then
            mS = tostring(game.JobId)
        else
            tI_8 = tostring(game.JobId)
        end
        tI_17 = (tI_17 + 4) % 12
    end
until (tI_17 * 1 + 6) % 12 == 7
if tI_1 then
    tI_17 = 2
    repeat
        tI_6 = {
            "xbuwlbqfymz",
            "untjuwb",
            "dxvln",
            "ptem",
            "qabiyfb",
            "drqgpxpqok",
            "izozjimnyf",
            "nmqb",
            "tliu",
            "vyqfpo"
        }
        local uA = tI_17
        tI_13 = tI_6[uA % 10 + 1]
        if tI_13:len() >= tI_13:gsub("(.)", "%1%1", uA % 3 % 2 + 1):len() then
            mS = string.sub(tI_1, 1, 18) .. "..."
        else
            tI_1 = string.sub(mS, 1, 18) .. "..."
        end
        tI_17 = (tI_17 + 3) % 8
    until (tI_17 * 1 + 1) % 8 == 6
end
tI_17 = tI_1 or mS
mz, tI_1, mH, mE, connection2, connection3, mk = nil, nil, nil, nil, nil, nil, nil
tI_13 = tI_17
tI_8:AddLabel(mU("Server", tI_13, nK), true)
tI_8:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
mz = os.clock()
task.spawn(worker)
local ScriptsGroup = nP.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(m3("Included in this hub", nK), true)
ScriptsGroup:AddLabel(m3(tI_15, nL), true)
local FeaturesGroup = nP.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(m3("Auto Farm Wins", nL), true)
FeaturesGroup:AddLabel(m3("Auto Train", nL), true)
FeaturesGroup:AddLabel(m3("Auto Collect Coins", nL), true)
FeaturesGroup:AddLabel(m3("Auto Rebirth", my), true)
FeaturesGroup:AddLabel(m3("Auto Buy Shops", my), true)
FeaturesGroup:AddLabel(m3("Auto Equip Best", nK), true)
local SocialsGroup = nP.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = na })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = nP.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = na })
local FaqGroup = nP.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutoWinGroup = nP.Main:AddLeftGroupbox("Auto Win", "trophy")
AutoWinGroup:AddToggle("AutoWin", { Text = "Auto Farm Win", Default = false })
AutoWinGroup:AddDropdown("WinPlate", { Text = "Win Plate", Values = nM, Default = nM[1], Searchable = true })
AutoWinGroup:AddSlider("WinDelay", { Text = "Win Delay", Default = 0.5, Min = 0, Max = 10, Rounding = 1 })
AutoWinGroup:AddLabel(m3("The game has a built-in cooldown for win plates, so do not think it is bugged. That short delay comes from the game itself.", "#ff6b6b"), true)
local AutoTrainGroup = nP.Main:AddLeftGroupbox("Auto Train", "footprints")
AutoTrainGroup:AddToggle("AutoTrain", { Text = "Auto Train Speed", Default = false })
tI_11 = nP.Main:AddRightGroupbox("Auto Rebirth", "rotate-ccw")
tI_11:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
local tI_10_1 = nP.Main:AddRightGroupbox("Auto Coins", "coins")
tI_10_1:AddToggle("AutoCollectCoins", { Text = "Auto Collect Coins", Default = false })
tI_4 = nP.Shop:AddLeftGroupbox("Wins Shop", "bike")
tI_4:AddToggle("AutoBuyWinsShop", { Text = "Auto Buy Wins Shop", Default = false })
tI_14 = nP.Shop:AddLeftGroupbox("Item Shop", "backpack")
if (tI_4 and not tI_1 and (not mk or not mz) and (not mk and not mk and (not mz or not tI_4)) or (not tI_4 and mz or mk and tI_1 or not mH and mH and (not mH and tI_1))) and (((mz or tI_1) and (not mk or tI_1) or (tI_1 or mz or (tI_1 or mH))) and ((mk and tI_4 or (not tI_1 or tI_4)) and ((mH or not tI_1) and (tI_1 or tI_4)))) and not ((tI_4 and not tI_1 and (not mk or not mz) and (not mk and not mk and (not mz or not tI_4)) or (not tI_4 and mz or mk and tI_1 or not mH and mH and (not mH and tI_1))) and (((mz or tI_1) and (not mk or tI_1) or (tI_1 or mz or (tI_1 or mH))) and ((mk and tI_4 or (not tI_1 or tI_4)) and ((mH or not tI_1) and (tI_1 or tI_4))))) then
    tI_1:AddToggle("AutoBuyItemShop", { Text = "Auto Buy Time Shop", Default = false })
    tI_1:AddToggle("AutoEquipBestItems", { Text = "Auto Equip Best Items", Default = false })
    nP = tI_14.Shop:AddRightGroupbox("Cosmetics", "sparkles")
else
    tI_14:AddToggle("AutoBuyItemShop", { Text = "Auto Buy Time Shop", Default = false })
    tI_14:AddToggle("AutoEquipBestItems", { Text = "Auto Equip Best Items", Default = false })
    tI_1 = nP.Shop:AddRightGroupbox("Cosmetics", "sparkles")
end
tI_1:AddToggle("AutoBuyTrails", { Text = "Auto Buy Trails", Default = false })
tI_1:AddToggle("AutoBuyAuras", { Text = "Auto Buy Auras", Default = false })
tI_6 = nP.Settings:AddLeftGroupbox("Menu")
tI_6:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
mH = tick()
mE = tick()
pcall(function()
    for i, v in ipairs(getconnections(nc.Idled)) do
        local td = v
        pcall(function()
            td:Disable()
        end)
    end
end)
mk = fn541
connection2 = UserInputService.InputBegan:Connect(onInputBegan)
connection3 = UserInputService.InputChanged:Connect(onInputChanged)
do
    tI_6:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    tI_6:AddButton("Unload", onUnload)
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("TempoHub")
    ThemeManager:SaveDefault("Monochrome")
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    SaveManager:SetFolder("TempoHub/DoubleJumpBikeEscape")
    SaveManager:BuildConfigSection(nP.Settings)
    ThemeManager:ApplyToTab(nP.Settings)
    ThemeManager:LoadDefault()
    SaveManager:LoadAutoloadConfig()
    Library:OnUnload(fn299)
    task.spawn(worker9)
    task.spawn(worker8)
    task.spawn(worker7)
    task.spawn(worker6)
    task.spawn(worker5)
    task.spawn(worker4)
    task.spawn(worker3)
    task.spawn(worker2)
end
end)(...)

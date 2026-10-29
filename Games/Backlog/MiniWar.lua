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
getgenv().TempoHoodSubtitle = "MINI WAR"
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
local Ae_2, Ae_3, Ae_4, Ae_12, Ae_13, Ae_15, Ae_16, Ae_18, Ae_19, Ae_21, Ae_31, Ae_33, Ae_35, Ae_37, Ae_41, GeneralsGroup, Ae_43, Ae_45, Ae_47, Ae_49
Ae_2 = nil
Ae_4 = nil
Ae_12 = nil
Ae_15 = nil
Ae_18 = nil
local qJ
local pJ
local pq
local p7
local qP
local q7
local pP
local qw
local onBuyBlackMarketNow2
local qd
local Label9
local rj
local pC
local q0
local p0
local qI
local qp
local Label6
local p6
local pO
local pv
local qc
local LocalPlayer
local CollectionService
local pU
local qB
local pB
local ri
local qi
local q_
local qH
local pH
local qo
local p5
local onBuyBlackMarketNow
local qu
local rb
local qb
local qT
local Label3
local qA
local rh
local pA
local qh
local pZ
local qG
local pG
local qn
local q4
local ConvertCurrency
local qM
local pM
local pt
local Label14
local onBuySelectedNow
local AlienExtractorConfig
local pS
local qz
local pz
local Label13
local qg
local pY
local Label8
local Label12
local Label10
local Label2
local VirtualUser
local p3
local qL
local pL
local qs
local Label7
local p9
local Label11
local Label4
local qy
local py
local qf
local qX
local pX
local pE
local Label5
local q2
local ql
local connection
local pK
local qr
local p8
local Label
local pQ
local ClientData
local re
local px
function fns.fn1(aI)
    local si = pE[aI]
    return si and si.Value or nil
end
function fns.fn7()
    p5.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
function fns.onClearAutoConquerQueue()
    pcall(function()
        qy:Fire({ queue = {} })
    end)
end
function fns.onRscripts()
    pz(qg, "Copied Rscripts profile to clipboard")
end
function fns.fn62()
    if pA.cover and pA.cover.Parent then
        return
    end
    local xI_1 = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TempoBlackScreen"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 100
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
    end
    screenGui.Parent = xI_1
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(1, 1)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    local uIListLayout = Instance.new("UIListLayout")
    uIListLayout.Padding = UDim.new(0, 4)
    uIListLayout.FillDirection = Enum.FillDirection.Vertical
    uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uIListLayout.Parent = frame
    pA.labels = {
        brand = px(frame, 14, Color3.fromRGB(96, 102, 112), 1),
        moneyTitle = px(frame, 18, Color3.fromRGB(196, 199, 206), 2),
        moneyValue = px(frame, 36, Color3.fromRGB(126, 214, 160), 3),
        moneyGain = px(frame, 18, Color3.fromRGB(126, 214, 160), 4),
        gemsTitle = px(frame, 18, Color3.fromRGB(196, 199, 206), 5),
        gemsValue = px(frame, 36, Color3.fromRGB(110, 193, 255), 6),
        gemsGain = px(frame, 18, Color3.fromRGB(110, 193, 255), 7),
        coresTitle = px(frame, 18, Color3.fromRGB(196, 199, 206), 8),
        coresValue = px(frame, 36, Color3.fromRGB(232, 163, 77), 9),
        coresGain = px(frame, 18, Color3.fromRGB(232, 163, 77), 10),
        bpTitle = px(frame, 18, Color3.fromRGB(196, 199, 206), 11),
        bpValue = px(frame, 36, Color3.fromRGB(196, 199, 206), 12),
        bpGain = px(frame, 18, Color3.fromRGB(196, 199, 206), 13)
    }
    pA.labels.brand.Text = "TEMPO HUB"
    pA.labels.moneyTitle.Text = "Money"
    pA.labels.gemsTitle.Text = "Gems"
    pA.labels.coresTitle.Text = "Alien Cores"
    pA.labels.bpTitle.Text = "Pass Points"
    pA.cover = screenGui
end
function fns.fn100()
    local vp = {}
    for k, v in pairs(rb("DeployArmy")) do
        if v then
            local vq = table.find(qH, k)
            if vq then
                table.insert(vp, vq)
            end
        end
    end
    table.sort(vp)
    if #vp == 0 then
        vp[1] = 1
    end
    return vp
end
function fns.onSellAllBuildingsInBackpack()
    pcall(function()
        py:Fire()
    end)
end
function fns.fn165(aN)
    for k, v in pairs(aN) do
        if v then
            return true
        end
    end
    return false
end
function fns.fn166()
    if not pA.labels then
        return
    end
    pU()
    local xM = qp()
    local xN = pY or xM
    pA.labels.moneyValue.Text = q7(xM.money)
    pA.labels.moneyGain.Text = qA(xM.money - xN.money)
    pA.labels.gemsValue.Text = q7(xM.gems)
    pA.labels.gemsGain.Text = qA(xM.gems - xN.gems)
    pA.labels.coresValue.Text = q7(xM.alienCore)
    pA.labels.coresGain.Text = qA(xM.alienCore - xN.alienCore)
    pA.labels.bpValue.Text = q7(xM.bpPoints)
    pA.labels.bpGain.Text = qA(xM.bpPoints - xN.bpPoints)
end
function fns.fn167()
    local Character = LocalPlayer.Character
    local s_ = Character and Character:FindFirstChild("HumanoidRootPart")
    return s_
end
function fns.fn181(hF, hG, hH, hI)
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, -40, 0, hG + 10)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = hG
    textLabel.TextColor3 = hH
    textLabel.Text = ""
    textLabel.LayoutOrder = hI
    textLabel.Parent = hF
    return textLabel
end
function fns.fn187(fJ)
    local ws = Ae_15.generals[fJ]
    local wt = ws and ws.rarity
    local ws_1 = wt
    if wt then
        wt = table.find(Ae_15.rarityOrder, ws_1)
    end
    if not wt then
        wt = 0
    end
    return wt
end
function fns.fn203()
    local s1 = qs()
    local s2 = s1 and s1:FindFirstChild("Plot")
    local s1_1 = s2
    if s2 then
        s2 = s1_1:FindFirstChild("Buildings")
    end
    local s1_2 = s2
    if s2 then
        s2 = s1_2:GetChildren()
    end
    return s2 or {}
end
function fns.fn205(fR)
    local wv = p3()
    local ww = wv and wv.generals
    if not ww then
        return ""
    end
    local equippedSlots = ww.equippedSlots
    local wx = type(equippedSlots) == "table" and equippedSlots[fR]
    if wx then
        return equippedSlots[fR]
    elseif fR == 1 then
        return ww.equipped or ""
    elseif fR == 2 then
        local ww_3 = ww.equipped2
        local wB = if ww_3 then 1 else 0
        local wz = 665 * wB + 3303 * (1 - wB)
        local wA = 3689 * wB + 4057 * (1 - wB)
        if not ((wz * 611 + wA * 3963 + wz * wA) % 16777213 == 701794) then
            ww_3 = ""
        end
        return ww_3
    else
        return ""
    end
end
function fns.onInputBegan()
    qX = tick()
end
function fns.fn211()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    qT = tick()
end
function fns.onInputChanged(hy)
    local UserInputType = hy.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        qX = tick()
    end
end
function fns.onExtractHeldItemNow()
    pcall(function()
        Ae_12:Fire()
    end)
end
function fns.worker4()
    while not p5.Unloaded do
        if Ae_18("AutoWarPassPoints") then
            for k, v in pZ() do
                pJ(v)
            end
        end
        task.wait(1)
    end
end
function fns.worker10()
    while not p5.Unloaded do
        for k, v in Ae_2 do
            local z0_1 = pE[v.option]
            if z0_1 then
                z0_1:SetValues(onBuyBlackMarketNow2(v.shop))
            end
        end
        local BuyBlackMarket = pE.BuyBlackMarket
        if BuyBlackMarket then
            BuyBlackMarket:SetValues(onBuyBlackMarketNow2("BlackMarket"))
        end
        task.wait(30)
    end
end
function fns.fn308(aX)
    if type(aX) == "number" then
        return aX
    end
    local sw = aX == ""
    local sw_2
    local sx = type(aX) ~= "string" or sw
    local sx_1
    if sx then
        return 0
    end
    local sw_1 = tonumber(aX)
    if sw_1 then
        return sw_1
    end
    sw_2, sx_1 = pcall(ConvertCurrency.StringToNumber, aX)
    return sw_2 and sx_1 or 0
end
function fns.fn336()
    pz(ql, "Copied Discord invite to clipboard")
end
function fns.onCopyJoinScript_JobID()
    local em = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, qJ)
    pz(em, "Copied join script to clipboard")
end
function fns.worker3()
    while not p5.Unloaded do
        local yr = Ae_18("BlackScreen")
        if yr ~= pA.active then
            pt(yr)
        elseif yr then
            pt(true)
            p8()
        end
        task.wait(1)
    end
end
function fns.onExtractAllNow()
    pcall(function()
        pL:Fire()
    end)
end
function fns.fn393()
    local w9 = p9(rb("EventTypes"))
    local xa = {}
    for k, v in w9 do
        if table.find(qG, tostring(v.point:GetAttribute("baseType"))) then
            table.insert(xa, v)
        end
    end
    table.sort(xa, function(gS, gT)
        return gS.distance < gT.distance
    end)
    return xa
end
function fns.worker9()
    local zz_1
    while not p5.Unloaded do
        local zv = pP()
        local zw = {}
        local zw_5
        for k, v in pairs(zv) do
            table.insert(zw, string.format("%s x%d", k, v))
        end
        table.sort(zw)
        local zx = #zw > 0 and table.concat(zw, ", ")
        local zx_2, zx_5
        local zw_1 = zx or "No farms on your base yet."
        Label2:SetText(zw_1)
        local zw_2 = ri()
        local zx_1 = zw_2 and zw_2.market and zw_2.market.stock
        if zx_1 then
            zz_1, zx_2 = nil, 0
            for k in pairs(zv) do
                local zv_1 = zx_1[k]
                if zv_1 and zv_1 > zx_2 then
                    zz_1, zx_2 = k, zv_1
                end
            end
            local zv_2 = zz_1 and string.format("%s at %d%%", zz_1, math.floor(zx_2 * 100))
            local zx_3 = zv_2 or "none"
            Label3:SetText(qM("Best price", zx_3, qc))
            Label14:SetText(qM("Weather", tostring(zw_2.weather), p6))
        end
        local zv_3 = {}
        for k, v in pv() do
            local insert = table.insert
            local format = string.format
            local floor = math.floor
            local zB = zx_1 and zx_1[v] or 0
            insert(zv_3, format("%s at %d%%", v, floor(zB * 100)))
        end
        local zw_4 = #zv_3 > 0 and table.concat(zv_3, ", ")
        local zv_4 = zw_4 or "none"
        Label4:SetText(qM("Above threshold", zv_4, qn))
        local zv_5 = p3()
        if zv_5 then
            zw_5, zx_5 = 0, 0
            local zA_3 = zv_5.questData and zv_5.questData.activeQuests or {}
            for k, v in pairs(zA_3) do
                if type(v) == "table" then
                    if v.completed then
                        zw_5 += 1
                    end
                end
            end
            local zA_4 = zv_5.questData and zv_5.questData.claimedTier or {}
            for k in pairs(zA_4) do
                zx_5 += 1
            end
            Label7:SetText(qM("Quests", string.format("%d ready, %d claimed", zw_5, zx_5), qn))
            local zx_6 = zv_5.battlepass and zv_5.battlepass.bpPoints or 0
            Label6:SetText(qM("Pass points", tostring(zx_6), qh))
            local zw_7 = 0
            local zy_3 = zv_5.backpack or {}
            for k, v in pairs(zy_3) do
                local zx_8 = type(v) == "table" and qI(k)
                if zx_8 then
                    local zx_9 = v.amount or 0
                    zw_7 += zx_9
                end
            end
            local format = string.format
            local zy_4 = zv_5.alienCore or 0
            Label5:SetText(qM("Alien cores", format("%d | %d alien items", zy_4, zw_7), qn))
            local zw_8 = qz()
            local zy_5 = #zw_8
            local zz_5 = zv_5.gems or 0
            local zv_6 = q2(1) ~= "" and q2(1)
            local zA_5 = zv_6 or "none"
            Label8:SetText(qM("Generals", format("%d owned | %d gems | %s", zy_5, zz_5, zA_5), p6))
        end
        Label9:SetText(qM("Ready", string.format("%d skills", #qi()), p6))
        local zv_7 = qB()
        local zw_9 = p9(rb("TargetTypes"))
        Label11:SetText(qM("Held bases", tostring(zv_7), qn))
        Label12:SetText(qM("Available", tostring(#zw_9), qh))
        local zv_8 = pO()
        local zv_9 = zv_8 and zv_8.Name or "none"
        Label13:SetText(qM("Next target", zv_9, qc))
        local zv_10 = p0()
        local zw_11 = zv_10[1] and string.format("%d | %s", #zv_10, tostring(zv_10[1].point:GetAttribute("baseType")))
        local zv_11 = zw_11 or "0"
        Label10:SetText(qM("Sites open", zv_11, qc))
        task.wait(2)
    end
end
function fns.fn410()
    local st_1
    local ss_1
    ss_1, st_1 = pcall(function()
        return ClientData.playerProducer:getState().player
    end)
    local su = ss_1 and type(st_1) == "table"
    if su then
        return st_1
    end
    return nil
end
function fns.fn425()
    local sW_1
    local sV_1
    sV_1, sW_1 = pcall(function()
        return ClientData.gameProducer:getState()
    end)
    local sX = sV_1 and type(sW_1) == "table"
    if sX then
        return sW_1
    end
    return nil
end
function fns.worker2()
    local vK_1
    while true do
        task.wait(1)
        if p5.Unloaded then
            break
        end
        local vJ = math.floor(os.clock() - qf)
        if vJ < 60 then
            vK_1 = vJ .. "s"
        elseif vJ < 3600 then
            vK_1 = string.format("%dm %ds", math.floor((vJ) / (60)), vJ % 60)
        else
            vK_1 = string.format("%dh %dm", math.floor((vJ) / (3600)), math.floor((vJ % 3600) / (60)))
        end
        Label:SetText(qM("Session time", vK_1, qc))
    end
end
function fns.fn468(b_)
    local tr = not pC(b_)
    local tv = if tr then 1 else 0
    local tt = 1833 * tv + 3186 * (1 - tv)
    local tu = 803 * tv + 822 * (1 - tv)
    if not ((tt * 2066 + tu * 3936 + tt * tu) % 16777213 == 8419485) then
        tr = rj(b_) <= 0
    end
    if tr then
        return false
    end
    local tv_1 = if Ae_18("AutoCollectAlienOnly") then 1 else 0
    if tv_1 == 1 then
        return qI(b_:GetAttribute("GrownResource"))
    end
    return true
end
function fns.fn505(c6, c7)
    local ux = p3()
    local uy = ux and ux.shopsStock and ux.shopsStock[c6]
    local ux_1 = uy
    if uy then
        uy = type(ux_1.stock) == "table"
    end
    if uy then
        return ux_1.stock[c7] or 0
    end
    return 0
end
function fns.onSellAllNow()
    pcall(function()
        pS:Fire()
    end)
end
function fns.fn534()
    if pY then
        return
    end
    if p3() then
        pY = qp()
    end
end
function fns.fn575()
    local tO = ri()
    return tO and tO.market and tO.market.stock
end
function fns.fn578(bV)
    local tn_1
    local tm_1
    tm_1, tn_1 = pcall(AlienExtractorConfig.isAlienItem, bV)
    return tm_1 and tn_1 == true
end
function fns.fn579(aj, ak, al)
    return string.format("<b>%s</b> %s %s", aj, q0("-", "#5a6070"), q0(ak, al))
end
function fns.fn597()
    return Ae_4(LocalPlayer)
end
function fns.onDeployNow()
    q4(pO())
end
function fns.onUnload()
    p5:Unload()
end
function fns.worker5()
    while not p5.Unloaded do
        task.wait(2)
        if Ae_18("AntiAfk") then
            local yA = tick() - qX
            local yB = tick() - qT
            if yA >= 300 and yB >= 60 then
                pcall(qr)
            else
                if yA < 300 and yB >= 300 then
                    pcall(qr)
                end
            end
        end
    end
end
function fns.fn650()
    local sI = p3()
    if not sI then
        return { money = 0, gems = 0, alienCore = 0, bpPoints = 0 }
    end
    local sJ = pB(sI.money)
    local sK = tonumber(sI.gems) or 0
    local sL = tonumber(sI.alienCore) or 0
    local sM = sI.battlepass and sI.battlepass.bpPoints
    local sN = tonumber(sM) or 0
    return { money = sJ, gems = sK, alienCore = sL, bpPoints = sN }
end
function fns.fn653(bK)
    if pK[bK:GetAttribute("type")] then
        return true
    end
    local s8 = bK.Name == "Vault"
    local tc = if s8 then 1 else 0
    local ta = 3276 * tc + 2467 * (1 - tc)
    local tb = 2702 * tc + 1894 * (1 - tc)
    if not ((ta * 363 + tb * 2490 + ta * tb) % 16777213 == 16768920) then
        s8 = bK.Name == "Vault2"
    end
    return s8
end
function fns.fn664(cI)
    local Character = LocalPlayer.Character
    local uf = Character and Character:FindFirstChild("Humanoid")
    if not uf then
        return
    end
    local uf_1 = LocalPlayer.Backpack:FindFirstChild(cI) or Character:FindFirstChild(cI)
    if not uf_1 then
        return
    end
    uf:EquipTool(uf_1)
    task.wait(0.15)
    pcall(function()
        pQ:Fire()
    end)
    task.wait(0.15)
    uf:UnequipTools()
end
function fns.fn669(dE)
    local vd = qs()
    local ve = vd and vd:GetPivot().Position
    local vd_1 = ve
    if not vd_1 then
        local ve_1 = qP() and qP().Position
        vd_1 = ve_1
    end
    local ve_2 = vd_1
    if not ve_2 then
        return {}
    end
    local vd_2 = {}
    for k, v in p7() do
        if not rh(v) then
            local vf = tostring(v:GetAttribute("baseType"))
            local vg = dE and qo(dE) and not dE[vf]
            if not vg then
                local insert = table.insert
                local Magnitude = (v:GetPivot().Position - ve_2).Magnitude
                local vh = v:GetAttribute("OwnerStrength") or 0
                insert(vd_2, { point = v, distance = Magnitude, strength = vh })
            end
        end
    end
    return vd_2
end
function fns.onDeployOnSiteNow()
    local xu = p0()
    if xu[1] then
        q4(xu[1].point)
    end
end
function fns.fn696(ax, ay)
    local r8 = pE[ax]
    local r9 = r8 and tonumber(r8.Value)
    return r9 or ay
end
function fns.fn701()
    connection:Disconnect()
    pH:Disconnect()
    if pA.active then
        pt(false)
    end
end
function fns.fn702(a8)
    if a8 > 0 then
        return "+" .. q7(a8)
    elseif a8 < 0 then
        return "-" .. q7(math.abs(a8))
    else
        return "+0"
    end
end
function fns.fn728(d4)
    local DiscordGroup = d4:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = re })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = re })
end
function fns.fn752(Z, aa)
    if setclipboard then
        setclipboard(Z)
    elseif toclipboard then
        toclipboard(Z)
    end
    p5:Notify(aa)
end
function fns.worker7()
    while not p5.Unloaded do
        if Ae_18("AutoExtractAlien") then
            pcall(function()
                pL:Fire()
            end)
        end
        task.wait(pG("AlienDelay", 15))
    end
end
function fns.fn791(bO)
    local td = bO:GetAttribute("ResourcesToCollect") or 0
    local te = td
    for k, v in pairs(bO:GetAttributes()) do
        local td_1 = k ~= "ResourcesToCollect" and k ~= "MaxCapacity" and k ~= "NextCropYield" and type(v) == "number"
        if td_1 then
            if qu[k] then
                te += v
            end
        end
    end
    return te
end
function fns.worker()
    while not pY and not p5.Unloaded do
        pU()
        if pY then
            break
        end
        task.wait(0.5)
    end
end
function fns.fn814()
    local uG = CollectionService:GetTagged("CapturePoint")
    local uH = {}
    for k, v in uG do
        uH[v] = true
    end
    for k, v in { "CapturePointKingOfTheHill", "CapturePointToxicKingOfTheHill", "CapturePointAlienKingOfTheHill" } do
        for k, v in CollectionService:GetTagged(v) do
            local uI = v:IsDescendantOf(workspace) and not uH[v]
            if uI then
                uH[v] = true
                table.insert(uG, v)
            end
        end
    end
    return uG
end
function fns.fn825(as)
    local r5 = pM[as]
    return r5 ~= nil and r5.Value == true
end
function fns.fn833()
    local vC_1
    local vB_1
    if identifyexecutor then
        vC_1, vB_1 = identifyexecutor()
        local vD = vC_1 ~= ""
        local vE = type(vC_1) == "string" and vD
        if vE then
            local vD_1 = type(vB_1) == "string" and vB_1 ~= "" and vC_1 .. " " .. vB_1
            pq = vD_1 or vC_1
        end
    end
end
local function fn842(cY)
    local up = p3()
    local uq = up and up.shopsStock and up.shopsStock[cY]
    local up_1 = {}
    local ur = uq
    if uq then
        uq = type(ur.stock) == "table"
    end
    if uq then
        for k in pairs(ur.stock) do
            table.insert(up_1, k)
        end
    end
    table.sort(up_1)
    return up_1
end
local function fn845()
    local t3 = qw()
    if not t3 then
        return {}
    end
    local t4 = 1 + pG("SellThreshold", 10) / 100
    local t5 = {}
    for k, v in qb() do
        if (t3[v] or 0) >= t4 then
            table.insert(t5, v)
        end
    end
    return t5
end
local function fn850(aD)
    local sb = pE[aD]
    local sc = sb and sb.Value
    local sb_1 = {}
    local sd = sc
    local sh = if sd then 1 else 0
    local sf = 4035 * sh + 3479 * (1 - sh)
    local sg = 1789 * sh + 980 * (1 - sh)
    if not ((sf * 816 + sg * 951 + sf * sg) % 16777213 == 12212514) then
        sd = sb_1
    end
    return sd
end
local function fn853(dq)
    local attr2 = dq:GetAttribute("Owner")
    local attr = dq:GetAttribute("CoOwner")
    return attr2 == LocalPlayer.Name or attr == LocalPlayer.Name
end
local function fn862()
    local we = p3()
    local wf = we and we.generals and we.generals.owned
    local we_1 = {}
    if type(wf) == "table" then
        for k, v in pairs(wf) do
            local wf_1 = type(k) == "string" and k
            local wg_1 = wf_1
            if not wg_1 then
                local wf_2 = type(v) == "string" and v
                wg_1 = wf_2 or nil
            end
            local wf_3 = wg_1
            if wg_1 then
                wg_1 = Ae_15.generals[wf_3]
            end
            if wg_1 then
                table.insert(we_1, wf_3)
            end
        end
    end
    return we_1
end
local function fn896()
    local tw = {}
    for k, v in qd() do
        if not not pC(v) then
            local attr = v:GetAttribute("GrownResource")
            local ty = v:GetAttribute("ResourcesToCollect") or 0
            local tz = attr
            if tz then
                tz = ty > 0
            end
            if tz then
                local ty_1 = tw[attr] or 0
                tw[attr] = ty_1 + ty
            end
            for k, v in pairs(v:GetAttributes()) do
                local tx_1 = type(v) == "number" and v > 0 and qu[k]
                if tx_1 then
                    local tx_2 = qu[k]
                    local ty_3 = tx_2.GrownResource and tx_2.GrownResource.ModelName or k
                    local tx_4 = tw[ty_3] or 0
                    tw[ty_3] = tx_4 + v
                end
            end
        end
    end
    return tw
end
local function worker8()
    while not p5.Unloaded do
        if Ae_18("AutoBuy") then
            onBuySelectedNow()
        end
        if Ae_18("AutoBlackMarket") then
            onBuyBlackMarketNow()
        end
        task.wait(pG("BuyDelay", 10))
    end
end
local function fn942()
    pcall(function()
        q_:Fire()
    end)
end
local function fn963()
    local x8 = {}
    for i, child in workspace:GetChildren() do
        if child.Name == "BATTLEPASS_POINT_PICKUP" then
            table.insert(x8, child)
        end
    end
    return x8
end
local function worker6()
    while not p5.Unloaded do
        if Ae_18("AutoSellAll") then
            pcall(function()
                pS:Fire()
            end)
        elseif Ae_18("AutoSellHighPrice") then
            pX()
        end
        task.wait(pG("SellDelay", 10))
    end
end
local function fn990()
    local tR = p3()
    local tS = tR and tR.backpack
    local tR_1 = {}
    if type(tS) == "table" then
        for k, v in pairs(tS) do
            local tS_1 = type(v) == "table" and v.type == "Crop"
            if tS_1 then
                tS_1 = (v.amount or 0) > 0
            end
            if tS_1 then
                table.insert(tR_1, k)
            end
        end
    end
    table.sort(tR_1)
    return tR_1
end
local function fn1004()
    local u5 = 0
    for k, v in p7() do
        if rh(v) then
            u5 += 1
        end
    end
    return u5
end
local function fn1012(a2)
    local sE_1
    local sD_1
    sD_1, sE_1 = pcall(ConvertCurrency.SuffixFormat, a2)
    local sF = sD_1 and type(sE_1) == "string"
    if sF then
        return sE_1
    end
    return tostring(a2)
end
local function fn1016()
    for k, v in pv() do
        qL(v)
    end
end
local function fn1028(ag, ah)
    return string.format('<font color="%s">%s</font>', ah, ag)
end
pq = nil
Label11 = nil
pt = nil
pv = nil
onBuyBlackMarketNow2 = nil
px = nil
py = nil
pz = nil
pA = nil
pB = nil
pC = nil
Ae_12 = nil
pE = nil
Label10 = nil
pG = nil
pH = nil
pJ = nil
pK = nil
pL = nil
pM = nil
onBuyBlackMarketNow = nil
pO = nil
pP = nil
pQ = nil
Label4 = nil
pS = nil
Label3 = nil
pU = nil
Label9 = nil
pX = nil
pY = nil
pZ = nil
p0 = nil
Ae_18 = nil
connection = nil
p3 = nil
ConvertCurrency = nil
p5 = nil
p6 = nil
p7 = nil
p8 = nil
p9 = nil
AlienExtractorConfig = nil
qb = nil
qc = nil
local pr, pu, pI, pW, p_
qd = nil
qf = nil
qg = nil
qh = nil
qi = nil
Ae_15 = nil
ql = nil
Label2 = nil
qn = nil
qo = nil
qp = nil
qr = nil
qs = nil
qu = nil
qw = nil
ClientData = nil
qy = nil
qz = nil
qA = nil
qB = nil
Ae_4 = nil
Label8 = nil
qG = nil
qH = nil
qI = nil
qJ = nil
qL = nil
qM = nil
qP = nil
Label = nil
onBuySelectedNow = nil
qT = nil
LocalPlayer = nil
Ae_2 = nil
qX = nil
q_ = nil
local BattlepassConfig, qj, SkillsConfig, onResearchNow, qv, qC, qE, qK, qN, qO, qR, qV, qY, RunService
q0 = nil
q2 = nil
VirtualUser = nil
q4 = nil
Label6 = nil
q7 = nil
Label7 = nil
Label14 = nil
rb = nil
CollectionService = nil
re = nil
Label13 = nil
rh = nil
ri = nil
rj = nil
Label5 = nil
Label12 = nil
local q1, q8, rd, onUnclaimNow, rk
q1 = nil
local q5
q8 = nil
rd = nil
onUnclaimNow = nil
rk = nil
CollectionService, VirtualUser, RunService, LocalPlayer = nil, nil, nil, nil
local Ae_7 = game:GetService("Players")
local Ae_27 = game:GetService("ReplicatedStorage")
CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
RunService = game:GetService("RunService")
LocalPlayer = Ae_7.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
Ae_13, Ae_4, ClientData, qu, SkillsConfig, Ae_15, BattlepassConfig, AlienExtractorConfig, ConvertCurrency, p_, pW, pS, pQ, pL, Ae_12, py, pu, pr, rk, rd, q8, q5, q_, qV, qR, qK, qE, qy, qv, Ae_33, ql, qg, Ae_43, p5, Ae_16, Ae_31, pM, pE, qn, qh, qc, p6, pY, pK, Ae_19, qG, qH, Ae_41, Ae_47, pz, re, q0, qM, Ae_18, pG, rb, qO, qo, p3, pB, q7, qA, qp, pU, ri, qP, qs, qd, pC, rj, qI, qj, pP, qw, qb, pv, qL, pX, onBuyBlackMarketNow2, qN, p7, rh, qB, p9, qC, Ae_45 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Ae_29 = 33
repeat
    Ae_49 = (Ae_29 * 25 + 12) % 36 + 1
    if Ae_49 <= 18 then
        if Ae_49 <= 9 then
            if Ae_49 <= 5 then
                if Ae_49 <= 3 then
                    if Ae_49 <= 2 then
                        if Ae_49 <= 1 then
                            if (Ae_29 * 3 + 6) * 5 % 4 == ((Ae_29 * 3 + 6) * 5 + 8) % 4 then
                                qI = fns.fn578
                                qj = fns.fn468
                            else
                                qj = fns.fn578
                                qI = fns.fn468
                            end
                            Ae_29 = (Ae_29 + 13) % 144
                        else
                            if (pX or rh) and (pX and not rh) and ((not rh or rh) and (not rh and not pX)) and (pX and not rh and (pX and not rh) or (rh or not pX) and (pX and not pX)) or (rh and not pX or (not pX or not pX) or (not pX or not pX or not rh and rh) or (not rh or rh) and (not pX and not rh) and ((not rh or not rh) and (pX or pX))) or not ((pX or rh) and (pX and not rh) and ((not rh or rh) and (not rh and not pX)) and (pX and not rh and (pX and not rh) or (rh or not pX) and (pX and not pX)) or (rh and not pX or (not pX or not pX) or (not pX or not pX or not rh and rh) or (not rh or rh) and (not pX and not rh) and ((not rh or not rh) and (pX or pX)))) then
                                pP = fn896
                                qw = fns.fn575
                                qb = fn990
                                pv = fn845
                            else
                                pv = fn896
                                pP = fns.fn575
                                qw = fn990
                                qb = fn845
                            end
                            Ae_29 = (Ae_29 + 85) % 144
                        end
                    else
                        Ae_35 = { "xwhlhamm", "hechtr", "aap", "rbbfvdwekxk", "fgrlcekz", "xpbnkvvyn", "ovtophvdbz" }
                        local By = Ae_29
                        Ae_21 = Ae_35[By % 7 + 1]
                        if Ae_21:len() >= Ae_21:gsub("(.)", "%1%1", By % 3 % 2 + 1):len() then
                            pX = fns.fn664
                            onBuyBlackMarketNow2 = { "Decor", "Farm", "Military", "House" }
                            qL = fn842
                        else
                            qL = fns.fn664
                            pX = fn1016
                            onBuyBlackMarketNow2 = fn842
                        end
                        Ae_29 = (Ae_29 + 13) % 144
                    end
                elseif Ae_49 <= 4 then
                    Ae_35 = {
                        "wlcbmmfe",
                        "ujqg",
                        "nfhvxc",
                        "mbkmprjqvc",
                        "jzpgimira",
                        "gffmv",
                        "tdi",
                        "vgdyuupsgxk",
                        "jnqyatlqys",
                        "levrsokovrh"
                    }
                    local Dh = Ae_29
                    Ae_21 = Ae_35[Dh % 10 + 1]
                    if Ae_21:len() >= Ae_21:gsub("(.)", "%1%1", Dh % 3 % 2 + 1):len() then
                        qG = fns.fn505
                        qN = fns.fn814
                        Ae_19 = fn853
                        rh = { "City", "Garnison", "MilitaryBase", "Camp", "Lab", "WaterRig" }
                        p7 = {
                            "RaidBase",
                            "HackerBase",
                            "KingOfTheHill",
                            "AlienKingOfTheHill",
                            "MechBeast",
                            "MeteorBase",
                            "CargoBase",
                            "ToxicKingOfTheHill"
                        }
                    else
                        qN = fns.fn505
                        p7 = fns.fn814
                        rh = fn853
                        Ae_19 = { "City", "Lab", "MilitaryBase", "WaterRig", "Garnison", "Camp" }
                        qG = {
                            "RaidBase",
                            "CargoBase",
                            "MeteorBase",
                            "HackerBase",
                            "MechBeast",
                            "KingOfTheHill",
                            "ToxicKingOfTheHill",
                            "AlienKingOfTheHill"
                        }
                    end
                    Ae_29 = (Ae_29 + 49) % 144
                else
                    if Ae_29 * 33685315 + 9 + 5 <= Ae_29 * 33685315 + 9 + 5 + 6 then
                        qB = fn1004
                        p9 = fns.fn669
                        qH = { "Army 1", "Army 2", "Army 3", "Army 4" }
                    else
                        qH = fn1004
                        qB = fns.fn669
                        p9 = { "Army 4", "Army 1", "Army 2", "Army 3" }
                    end
                    Ae_29 = (Ae_29 + 121) % 144
                end
            elseif Ae_49 <= 7 then
                if Ae_49 <= 6 then
                    local C7 = bit32.rrotate(bit32.bxor(bit32.lrotate(Ae_29, 1), string.byte(tostring(pz))), 1)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(C7, 1577885868), 10), 847425912) ~= bit32.lrotate(C7, 10) then
                        pB = fns.fn100
                    else
                        qC = fns.fn100
                    end
                    Ae_29 = (Ae_29 + 49) % 144
                else
                    local BJ = bit32.rrotate(bit32.bxor(bit32.lrotate(Ae_29, 21), string.byte(tostring(qE))), 1)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(BJ, 1628367496), 10), 1001005444) == bit32.lrotate(BJ, 10) then
                        Ae_41 = p5:CreateWindow({
                            Title = "Tempo Hub",
                            Footer = { { Text = ql, Copyable = true }, "|", Ae_33 },
                            Icon = 18657887261,
                            NotifySide = "Right",
                            ShowCustomCursor = false,
                            CornerRadius = 10
                        })
                    else
                        p5 = Ae_33:CreateWindow({
                            ShowCustomCursor = false,
                            Title = "Tempo Hub",
                            Footer = { ql, "|", { Text = Ae_41, Copyable = true } },
                            CornerRadius = 10,
                            Icon = 18657887261,
                            NotifySide = "Right"
                        })
                    end
                    Ae_29 = (Ae_29 + 85) % 144
                end
            elseif Ae_49 <= 8 then
                if Ae_29 * 63266447 + 8 + 7 >= Ae_29 * 63266447 + 8 + 7 + 6 then
                    Ae_41 = {
                        Conquer = Ae_47:AddTab("Conquer", "swords"),
                        Rewards = Ae_47:AddTab("Rewards", "gift"),
                        Settings = Ae_47:AddTab("Settings", "settings"),
                        Info = Ae_47:AddTab("Info", "info"),
                        Collect = Ae_47:AddTab("Collect", "hand-coins"),
                        Empire = Ae_47:AddTab("Empire", "crown"),
                        Shop = Ae_47:AddTab("Shop", "shopping-cart")
                    }
                else
                    Ae_47 = {
                        Info = Ae_41:AddTab("Info", "info"),
                        Collect = Ae_41:AddTab("Collect", "hand-coins"),
                        Rewards = Ae_41:AddTab("Rewards", "gift"),
                        Shop = Ae_41:AddTab("Shop", "shopping-cart"),
                        Empire = Ae_41:AddTab("Empire", "crown"),
                        Conquer = Ae_41:AddTab("Conquer", "swords"),
                        Settings = Ae_41:AddTab("Settings", "settings")
                    }
                end
                Ae_29 = (Ae_29 + 121) % 144
            else
                Ae_35 = (vector.create((Ae_29 * 4 + 7) % 11 + 1, (Ae_29 * 3 + 7) % 13 + 1, (Ae_29 * 7 + 4) % 17 + 1))
                Ae_21 = (vector.create((Ae_29 * 1 + 9) % 11 + 1, (Ae_29 * 8 + 8) % 13 + 1, (Ae_29 * 14 + 11) % 17 + 1))
                Ae_3 = (vector.create((Ae_29 * 3 + 1) % 11 + 1, (Ae_29 * 6 + 6) % 13 + 1, (Ae_29 * 4 + 8) % 17 + 1))
                Ae_37 = (vector.create((Ae_29 * 3 + 5) % 5 + 1, (Ae_29 * 3 + 3) % 7 + 1, (Ae_29 * 1 + 7) % 9 + 1))
                if vector.dot(vector.cross(Ae_35, (vector.cross(Ae_21, Ae_3))), Ae_37) == vector.dot(Ae_21 * vector.dot(Ae_35, Ae_3) - Ae_3 * vector.dot(Ae_35, Ae_21), Ae_37) then
                    Ae_47.Farming = Ae_47.Collect:AddSubTab("Farming", "hand-coins")
                    Ae_47.Selling = Ae_47.Collect:AddSubTab("Selling", "banknote")
                    Ae_47.Alien = Ae_47.Collect:AddSubTab("Alien", "atom")
                    Ae_47.Bases = Ae_47.Conquer:AddSubTab("Bases", "swords")
                    Ae_47.Events = Ae_47.Conquer:AddSubTab("Events", "siren")
                    Ae_47.Holdings = Ae_47.Conquer:AddSubTab("Holdings", "flag")
                    Ae_45 = fns.fn728
                else
                    Ae_45.Farming = Ae_45.Collect:AddSubTab("Farming", "hand-coins")
                    Ae_45.Selling = Ae_45.Collect:AddSubTab("Selling", "banknote")
                    Ae_45.Alien = Ae_45.Collect:AddSubTab("Alien", "atom")
                    Ae_45.Bases = Ae_45.Conquer:AddSubTab("Bases", "swords")
                    Ae_45.Events = Ae_45.Conquer:AddSubTab("Events", "siren")
                    Ae_45.Holdings = Ae_45.Conquer:AddSubTab("Holdings", "flag")
                    Ae_47 = fns.fn728
                end
                Ae_29 = (Ae_29 + 13) % 144
            end
        elseif Ae_49 <= 14 then
            if Ae_49 <= 12 then
                if Ae_49 <= 11 then
                    if Ae_49 <= 10 then
                        if (Ae_29 * 3 + 3) * 13 % 4 == ((Ae_29 * 3 + 3) * 13 + 4) % 4 then
                            Ae_13 = require(Ae_27.util.GetBridge)
                        else
                            Ae_27 = require(Ae_13.util.GetBridge)
                        end
                        Ae_29 = (Ae_29 + 13) % 144
                    else
                        Ae_35 = (vector.create((Ae_29 * 1 + 7) % 11 + 1, (Ae_29 * 11 + 8) % 13 + 1, (Ae_29 * 12 + 8) % 17 + 1))
                        Ae_21 = (vector.create((Ae_29 * 4 + 7) % 11 + 1, (Ae_29 * 1 + 3) % 13 + 1, (Ae_29 * 7 + 15) % 17 + 1))
                        local CQ = vector.cross(Ae_35, Ae_21)
                        local CR = vector.dot(Ae_35, Ae_21)
                        if vector.dot(CQ, CQ) + CR * CR == vector.dot(Ae_35, Ae_35) * vector.dot(Ae_21, Ae_21) + 2 then
                            Ae_27 = require(ClientData.util.GetPlotModel)
                            Ae_4 = require(ClientData.client.modules.ClientData)
                        else
                            Ae_4 = require(Ae_27.util.GetPlotModel)
                            ClientData = require(Ae_27.client.modules.ClientData)
                        end
                        Ae_29 = (Ae_29 + 121) % 144
                    end
                else
                    Ae_35 = {
                        "nafk",
                        "jaiygk",
                        "bbgkuciptha",
                        "htcp",
                        "eqjqodvqsoow",
                        "fmzu",
                        "hnavr",
                        "iqjegimsjb",
                        "bogucbivf",
                        "aezupgnuexp",
                        "cwbonpckzlg",
                        "wnspqcacexka",
                        "lryapxs"
                    }
                    if Ae_35[(Ae_29 * 80 + 100) % 13 + 1] < Ae_35[(Ae_29 * 80 + 100) % 13 + 1] then
                        Ae_27 = require(SkillsConfig.shared.config.BuildingsConfig)
                        qu = require(SkillsConfig.shared.config.SkillsConfig)
                    else
                        qu = require(Ae_27.shared.config.BuildingsConfig)
                        SkillsConfig = require(Ae_27.shared.config.SkillsConfig)
                    end
                    Ae_29 = (Ae_29 + 85) % 144
                end
            elseif Ae_49 <= 13 then
                if Ae_29 * 89322185 + 8 + 7 <= Ae_29 * 89322185 + 8 + 7 + 4 then
                    Ae_15 = require(Ae_27.shared.config.GeneralsConfig)
                    BattlepassConfig = require(Ae_27.shared.config.BattlepassConfig)
                else
                    Ae_27 = require(BattlepassConfig.shared.config.GeneralsConfig)
                    Ae_15 = require(BattlepassConfig.shared.config.BattlepassConfig)
                end
                Ae_29 = (Ae_29 + 13) % 144
            else
                Ae_35 = {
                    "nyo",
                    "uinfuufk",
                    "navfztm",
                    "hji",
                    "szsdogx",
                    "phqymve",
                    "opfnnq",
                    "vebtvqztns",
                    "ptgmfplc",
                    "vpjixwrvmij"
                }
                if Ae_35[(Ae_29 * 79 + 1) % 10 + 1] < Ae_35[(Ae_29 * 79 + 1) % 10 + 1] then
                    Ae_27 = require(ConvertCurrency.shared.config.AlienExtractorConfig)
                    p_ = require(ConvertCurrency.util.ConvertCurrency)
                    Ae_13 = AlienExtractorConfig("CollectResources")
                    pS = AlienExtractorConfig("collectOfflineMoney")
                    pW = AlienExtractorConfig("SellAll")
                else
                    AlienExtractorConfig = require(Ae_27.shared.config.AlienExtractorConfig)
                    ConvertCurrency = require(Ae_27.util.ConvertCurrency)
                    p_ = Ae_13("CollectResources")
                    pW = Ae_13("collectOfflineMoney")
                    pS = Ae_13("SellAll")
                end
                Ae_29 = (Ae_29 + 85) % 144
            end
        elseif Ae_49 <= 16 then
            if Ae_49 <= 15 then
                if (Ae_29 * 1 + 3) * 5 % 4 == ((Ae_29 * 1 + 3) * 5 + 4) % 4 then
                    pQ = Ae_13("SellSingularItem")
                    pL = Ae_13("ExtractAllAlienCores")
                    Ae_12 = Ae_13("ExtractSingleAlienCore")
                    py = Ae_13("SellAllBuildings")
                else
                    Ae_12 = pL("SellSingularItem")
                    pQ = pL("ExtractAllAlienCores")
                    py = pL("ExtractSingleAlienCore")
                    Ae_13 = pL("SellAllBuildings")
                end
                Ae_29 = (Ae_29 + 49) % 144
            else
                Ae_35 = (vector.create((Ae_29 * 4 + 1) % 11 + 1, (Ae_29 * 10 + 9) % 13 + 1, (Ae_29 * 3 + 3) % 17 + 1))
                Ae_21 = (vector.create((Ae_29 * 6 + 8) % 11 + 1, (Ae_29 * 1 + 2) % 13 + 1, (Ae_29 * 7 + 2) % 17 + 1))
                Ae_3 = (vector.create((Ae_29 * 4 + 7) % 11 + 1, (Ae_29 * 4 + 11) % 13 + 1, (Ae_29 * 8 + 14) % 17 + 1))
                Ae_37 = (vector.create((Ae_29 * 4 + 3) % 5 + 1, (Ae_29 * 4 + 7) % 7 + 1, (Ae_29 * 5 + 6) % 9 + 1))
                if vector.dot(vector.cross(Ae_35, (vector.cross(Ae_21, Ae_3))), Ae_37) == vector.dot(Ae_21 * vector.dot(Ae_35, Ae_3) - Ae_3 * vector.dot(Ae_35, Ae_21), Ae_37) then
                    pu = Ae_13("TryToCompleteQuest")
                    pr = Ae_13("ClaimQuestTier")
                    rk = Ae_13("ClaimBPReward")
                    rd = Ae_13("CollectBPPickup")
                else
                    rk = rd("TryToCompleteQuest")
                    pu = rd("ClaimQuestTier")
                    Ae_13 = rd("ClaimBPReward")
                    pr = rd("CollectBPPickup")
                end
                Ae_29 = (Ae_29 + 121) % 144
            end
        elseif Ae_49 <= 17 then
            Ae_35 = (vector.create((Ae_29 * 6 + 3) % 11 + 1, (Ae_29 * 5 + 9) % 13 + 1, (Ae_29 * 12 + 15) % 17 + 1))
            Ae_21 = (vector.create((Ae_29 * 1 + 6) % 11 + 1, (Ae_29 * 8 + 7) % 13 + 1, (Ae_29 * 7 + 12) % 17 + 1))
            Ae_3 = (vector.create((Ae_29 * 6 + 5) % 11 + 1, (Ae_29 * 2 + 11) % 13 + 1, (Ae_29 * 13 + 17) % 17 + 1))
            if vector.dot(vector.cross(Ae_35, Ae_21), Ae_3) == vector.dot(vector.cross(Ae_21, Ae_3), Ae_35) + 1 then
                Ae_13 = q8("BuyFromShop")
                qV = q8("BuyFromBlackMarketShop")
                q5 = q8("GeneralGemRoll")
                q_ = q8("GeneralEquipSlot")
            else
                q8 = Ae_13("BuyFromShop")
                q5 = Ae_13("BuyFromBlackMarketShop")
                q_ = Ae_13("GeneralGemRoll")
                qV = Ae_13("GeneralEquipSlot")
            end
            Ae_29 = (Ae_29 + 85) % 144
        else
            local Cm = bit32.rrotate(bit32.bxor(bit32.lrotate(Ae_29, 13), string.byte(tostring(pu))), 22)
            if bit32.bxor(bit32.lrotate(bit32.bxor(Cm, 1240413932), 0), 1240413932) == bit32.lrotate(Cm, 0) then
                qR = Ae_13("TryToBuySkill")
            else
                Ae_13 = qR("TryToBuySkill")
            end
            Ae_29 = (Ae_29 + 85) % 144
        end
    elseif Ae_49 <= 27 then
        if Ae_49 <= 23 then
            if Ae_49 <= 21 then
                if Ae_49 <= 20 then
                    if Ae_49 <= 19 then
                        Ae_35 = (vector.create((Ae_29 * 2 + 6) % 11 + 1, (Ae_29 * 5 + 3) % 13 + 1, (Ae_29 * 13 + 1) % 17 + 1))
                        Ae_21 = (vector.create((Ae_29 * 5 + 5) % 11 + 1, (Ae_29 * 2 + 13) % 13 + 1, (Ae_29 * 1 + 1) % 17 + 1))
                        Ae_3 = (vector.create((Ae_29 * 4 + 5) % 5 + 1, (Ae_29 * 3 + 2) % 7 + 1, (Ae_29 * 5 + 2) % 9 + 1))
                        if math.abs((vector.angle(Ae_35, Ae_21, Ae_3))) - math.abs((vector.angle(Ae_21, Ae_35, Ae_3))) == 1 then
                            qE = qv("SendTroopsToPoint")
                            qy = qv("SendRocketsToPoint")
                            Ae_13 = qv("SubmitAutoConquerQueue")
                            qK = qv("UnclaimBase")
                        else
                            qK = Ae_13("SendTroopsToPoint")
                            qE = Ae_13("SendRocketsToPoint")
                            qy = Ae_13("SubmitAutoConquerQueue")
                            qv = Ae_13("UnclaimBase")
                        end
                        Ae_29 = (Ae_29 + 49) % 144
                    else
                        if Ae_29 * 80307145 + 1 + 2 <= Ae_29 * 80307145 + 1 + 2 + 4 then
                            Ae_33 = "Mini War"
                        else
                            qo = "Mini War"
                        end
                        Ae_29 = (Ae_29 + 13) % 144
                    end
                else
                    if (Ae_29 * 2 + 5) * 10 % 3 == ((Ae_29 * 2 + 5) * 10 + 3) % 3 then
                        ql = "https://discord.gg/K7Qxnxkk46"
                    else
                        q8 = "https://discord.gg/K7Qxnxkk46"
                    end
                    Ae_29 = (Ae_29 + 121) % 144
                end
            elseif Ae_49 <= 22 then
                Ae_35 = (vector.create((Ae_29 * 3 + 9) % 11 + 1, (Ae_29 * 11 + 2) % 13 + 1, (Ae_29 * 13 + 16) % 17 + 1))
                Ae_21 = (vector.create((Ae_29 * 7 + 3) % 11 + 1, (Ae_29 * 5 + 11) % 13 + 1, (Ae_29 * 2 + 3) % 17 + 1))
                Ae_3 = (vector.create((Ae_29 * 2 + 5) % 11 + 1, (Ae_29 * 7 + 10) % 13 + 1, (Ae_29 * 14 + 9) % 17 + 1))
                Ae_37 = (vector.create((Ae_29 * 4 + 2) % 11 + 1, (Ae_29 * 2 + 12) % 13 + 1, (Ae_29 * 5 + 6) % 17 + 1))
                if vector.dot(vector.cross(Ae_35, Ae_21), (vector.cross(Ae_3, Ae_37))) == vector.dot(Ae_35, Ae_3) * vector.dot(Ae_21, Ae_37) - vector.dot(Ae_35, Ae_37) * vector.dot(Ae_21, Ae_3) then
                    qg = "https://discord.gg/K7Qxnxkk46"
                else
                    p5 = "https://discord.gg/K7Qxnxkk46"
                end
                Ae_29 = (Ae_29 + 121) % 144
            else
                local BI = bit32.rrotate(bit32.bxor(bit32.lrotate(Ae_29, 18), string.byte(tostring(ConvertCurrency))), 11)
                if bit32.bxor(bit32.lrotate(bit32.bxor(BI, 2936687302), 30), 2881655473) ~= bit32.lrotate(BI, 30) then
                    q8 = ""
                else
                    Ae_43 = ""
                end
                Ae_29 = (Ae_29 + 121) % 144
            end
        elseif Ae_49 <= 25 then
            if Ae_49 <= 24 then
                local CI = bit32.rrotate(bit32.bxor(bit32.lrotate(Ae_29, 4), string.byte(tostring(pu))), 17)
                if bit32.bxor(bit32.lrotate(bit32.bxor(CI, 3771661010), 30), 3090398900) == bit32.lrotate(CI, 30) then
                    p5 = getgenv().Library
                else
                    Ae_43 = getgenv().Library
                end
                Ae_29 = (Ae_29 + 13) % 144
            else
                if (Ae_29 * 2 + 8) * 16 % 3 == ((Ae_29 * 2 + 8) * 16 + 7) % 3 then
                    pcall(fns.fn7)
                    pM = getgenv().ThemeManager
                    p5 = getgenv().SaveManager
                    pE = Ae_31.Toggles
                    Ae_16 = Ae_31.Options
                    Ae_43 = fns.fn752
                else
                    pcall(fns.fn7)
                    Ae_16 = getgenv().ThemeManager
                    Ae_31 = getgenv().SaveManager
                    pM = p5.Toggles
                    pE = p5.Options
                    pz = fns.fn752
                end
                Ae_29 = (Ae_29 + 85) % 144
            end
        elseif Ae_49 <= 26 then
            Ae_35 = (vector.create((Ae_29 * 3 + 6) % 11 + 1, (Ae_29 * 9 + 10) % 13 + 1, (Ae_29 * 4 + 3) % 17 + 1))
            Ae_21 = (vector.create((Ae_29 * 1 + 7) % 11 + 1, (Ae_29 * 4 + 3) % 13 + 1, (Ae_29 * 11 + 8) % 17 + 1))
            Ae_3 = (vector.create((Ae_29 * 4 + 2) % 5 + 1, (Ae_29 * 5 + 1) % 7 + 1, (Ae_29 * 5 + 3) % 9 + 1))
            if math.abs((vector.angle(Ae_35, Ae_21, Ae_3))) - math.abs((vector.angle(Ae_21, Ae_35, Ae_3))) == 2 then
                q0 = fns.fn336
                qM = fn1028
                re = fns.fn579
            else
                re = fns.fn336
                q0 = fn1028
                qM = fns.fn579
            end
            Ae_29 = (Ae_29 + 121) % 144
        else
            Ae_35 = (vector.create((Ae_29 * 2 + 9) % 11 + 1, (Ae_29 * 10 + 6) % 13 + 1, (Ae_29 * 7 + 9) % 17 + 1))
            Ae_21 = (vector.create((Ae_29 * 4 + 5) % 11 + 1, (Ae_29 * 5 + 8) % 13 + 1, (Ae_29 * 12 + 7) % 17 + 1))
            Ae_3 = (vector.create((Ae_29 * 6 + 2) % 11 + 1, (Ae_29 * 10 + 13) % 13 + 1, (Ae_29 * 3 + 15) % 17 + 1))
            Ae_37 = (vector.create((Ae_29 * 1 + 8) % 11 + 1, (Ae_29 * 3 + 10) % 13 + 1, (Ae_29 * 9 + 3) % 17 + 1))
            if vector.dot(vector.cross(Ae_35, Ae_21), (vector.cross(Ae_3, Ae_37))) == vector.dot(Ae_35, Ae_3) * vector.dot(Ae_21, Ae_37) - vector.dot(Ae_35, Ae_37) * vector.dot(Ae_21, Ae_3) + 4 then
                qE = "#7fd47f"
            else
                qn = "#7fd47f"
            end
            Ae_29 = (Ae_29 + 85) % 144
        end
    elseif Ae_49 <= 32 then
        if Ae_49 <= 30 then
            if Ae_49 <= 29 then
                if Ae_49 <= 28 then
                    if (Ae_29 * 2 + 4) * 13 % 3 == ((Ae_29 * 2 + 4) * 13 + 3) % 3 then
                        qh = "#6ec1ff"
                        qc = "#e8a34d"
                        p6 = "#8b93a3"
                        Ae_18 = fns.fn825
                    else
                        qc = "#6ec1ff"
                        qh = "#e8a34d"
                        Ae_18 = "#8b93a3"
                        p6 = fns.fn825
                    end
                    Ae_29 = (Ae_29 + 13) % 144
                else
                    Ae_35 = (vector.create((Ae_29 * 1 + 9) % 11 + 1, (Ae_29 * 4 + 5) % 13 + 1, (Ae_29 * 12 + 10) % 17 + 1))
                    Ae_21 = (vector.create((Ae_29 * 3 + 8) % 11 + 1, (Ae_29 * 8 + 3) % 13 + 1, (Ae_29 * 11 + 9) % 17 + 1))
                    Ae_3 = (vector.create((Ae_29 * 1 + 4) % 5 + 1, (Ae_29 * 4 + 6) % 7 + 1, (Ae_29 * 4 + 1) % 9 + 1))
                    if math.abs((vector.angle(Ae_35, Ae_21, Ae_3))) - math.abs((vector.angle(Ae_21, Ae_35, Ae_3))) == 0 then
                        pG = fns.fn696
                        rb = fn850
                    else
                        rb = fns.fn696
                        pG = fn850
                    end
                    Ae_29 = (Ae_29 + 85) % 144
                end
            else
                if (not qM or not qM) and (Ae_13 and Ae_13) or Ae_31 and not Ae_13 and (Ae_13 or not Ae_31) or not ((not qM or not qM) and (Ae_13 and Ae_13) or Ae_31 and not Ae_13 and (Ae_13 or not Ae_31)) then
                    qO = fns.fn1
                    qo = fns.fn165
                else
                    qo = fns.fn1
                    qO = fns.fn165
                end
                Ae_29 = (Ae_29 + 13) % 144
            end
        elseif Ae_49 <= 31 then
            if (Ae_29 * 3 + 2) * 21 % 4 == ((Ae_29 * 3 + 2) * 21 + 8) % 4 then
                p3 = fns.fn410
            else
                Ae_33 = fns.fn410
            end
            Ae_29 = (Ae_29 + 121) % 144
        else
            if (Ae_45 or not pr or Ae_45 and pr) and ((pr or pr) and (Ae_45 and pr)) or not ((Ae_45 or not pr or Ae_45 and pr) and ((pr or pr) and (Ae_45 and pr))) then
                pB = fns.fn308
            else
                re = fns.fn308
            end
            Ae_29 = (Ae_29 + 85) % 144
        end
    elseif Ae_49 <= 34 then
        if Ae_49 <= 33 then
            Ae_35 = (vector.create((Ae_29 * 5 + 8) % 11 + 1, (Ae_29 * 2 + 5) % 13 + 1, (Ae_29 * 13 + 7) % 17 + 1))
            Ae_21 = (vector.create((Ae_29 * 7 + 4) % 11 + 1, (Ae_29 * 5 + 5) % 13 + 1, (Ae_29 * 9 + 6) % 17 + 1))
            Ae_3 = (vector.create((Ae_29 * 5 + 1) % 5 + 1, (Ae_29 * 3 + 6) % 7 + 1, (Ae_29 * 2 + 6) % 9 + 1))
            if math.abs((vector.angle(Ae_35, Ae_21, Ae_3))) - math.abs((vector.angle(Ae_21, Ae_35, Ae_3))) == 3 then
                qA = fn1012
                qp = fns.fn702
                q7 = fns.fn650
            else
                q7 = fn1012
                qA = fns.fn702
                qp = fns.fn650
            end
            Ae_29 = (Ae_29 + 85) % 144
        else
            Ae_35 = (vector.create((Ae_29 * 4 + 7) % 11 + 1, (Ae_29 * 11 + 12) % 13 + 1, (Ae_29 * 8 + 5) % 17 + 1))
            Ae_21 = (vector.create((Ae_29 * 5 + 9) % 11 + 1, (Ae_29 * 4 + 12) % 13 + 1, (Ae_29 * 12 + 13) % 17 + 1))
            Ae_3 = (vector.create((Ae_29 * 6 + 5) % 11 + 1, (Ae_29 * 6 + 1) % 13 + 1, (Ae_29 * 14 + 4) % 17 + 1))
            if vector.dot(vector.cross(Ae_35, Ae_21), Ae_3) == vector.dot(vector.cross(Ae_21, Ae_3), Ae_35) + 1 then
                p9 = nil
            else
                pY = nil
            end
            Ae_29 = (Ae_29 + 121) % 144
        end
    elseif Ae_49 <= 35 then
        Ae_49 = (vector.create((Ae_29 * 4 + 6) % 11 + 1, (Ae_29 * 2 + 2) % 13 + 1, (Ae_29 * 14 + 14) % 17 + 1))
        Ae_35 = (vector.create((Ae_29 * 1 + 1) % 11 + 1, (Ae_29 * 7 + 13) % 13 + 1, (Ae_29 * 5 + 9) % 17 + 1))
        local BR = vector.dot(Ae_49, Ae_35)
        if BR * BR <= vector.dot(Ae_49, Ae_49) * vector.dot(Ae_35, Ae_35) then
            pU = fns.fn534
            task.spawn(fns.worker)
            ri = fns.fn425
            qP = fns.fn167
        else
            qP = fns.fn534
            task.spawn(fns.worker)
            pU = fns.fn425
            ri = fns.fn167
        end
        Ae_29 = (Ae_29 + 49) % 144
    else
        if (Ae_29 * 2 + 1) * 16 % 3 == ((Ae_29 * 2 + 1) * 16 + 2) % 3 then
            pK = fns.fn597
            pC = fns.fn203
            qs = { Storage = true, Farm = true, GemMine = true, CloneFacility = true }
            rj = fns.fn653
            qd = fns.fn791
        else
            qs = fns.fn597
            qd = fns.fn203
            pK = { Farm = true, GemMine = true, CloneFacility = true, Storage = true }
            pC = fns.fn653
            rj = fns.fn791
        end
        Ae_29 = (Ae_29 + 121) % 144
    end
until (Ae_29 * 77 + 92) % 144 == 77
for k, v in Ae_47 do
    Ae_7 = v ~= Ae_47.Collect and v ~= Ae_47.Conquer
    if Ae_7 then
        Ae_45(v)
    end
end
pq, Ae_41, Ae_43, Label, qJ, Ae_27 = nil, nil, nil, nil, nil, nil
Ae_7 = 8
repeat
    Ae_29 = (Ae_7 * 1 + 1) % 3 + 1
    if Ae_29 <= 2 then
        if Ae_29 <= 1 then
            if Ae_7 * 75989729 + 4 + 7 <= Ae_7 * 75989729 + 4 + 7 + 1 then
                pq = "Unknown"
                pcall(fns.fn833)
                Ae_41 = Ae_47.Info:AddLeftGroupbox("Account", "circle-user")
                Ae_41:AddLabel(qM("User", LocalPlayer.Name, qn), true)
                Ae_41:AddLabel(qM("Status", "Keyless", qn), true)
                Ae_41:AddLabel(qM("Executor", pq, qn), true)
                Ae_43 = Ae_47.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                Ae_43:AddLabel(q0(Ae_33 .. " [" .. tostring(game.PlaceId) .. "]", qh), true)
                Ae_43:AddLabel(qM("Place ID", tostring(game.PlaceId), qh), true)
                Label = Ae_43:AddLabel(qM("Session time", "0s", qc), true)
            else
                qh = "Unknown"
                pcall(fns.fn833)
                qc = qM.Info:AddLeftGroupbox("Account", "circle-user")
                qc:AddLabel(Ae_41("User", Label.Name, LocalPlayer), true)
                qc:AddLabel(Ae_41("Status", "Keyless", LocalPlayer), true)
                qc:AddLabel(Ae_41("Executor", qh, LocalPlayer), true)
                q0 = qM.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                q0:AddLabel(Ae_43(qn .. " [" .. tostring(game.PlaceId) .. "]", pq), true)
                q0:AddLabel(Ae_41("Place ID", tostring(game.PlaceId), pq), true)
                Ae_33 = q0:AddLabel(Ae_41("Session time", "0s", Ae_47), true)
            end
            Ae_7 = (Ae_7 + 7) % 12
        else
            local BS = bit32.rrotate(bit32.bxor(bit32.lrotate(Ae_7, 31), string.byte(tostring(Ae_41))), 22)
            if bit32.bxor(bit32.lrotate(bit32.bxor(BS, 3488891580), 28), 3439281195) ~= bit32.lrotate(BS, 28) then
                pq = tostring(game.JobId)
            else
                qJ = tostring(game.JobId)
            end
            Ae_7 = (Ae_7 + 4) % 12
        end
    else
        Ae_29 = {
            "ebsrdzvjhab",
            "bxbarjvgat",
            "rfiyrapizokt",
            "ldjbeuq",
            "bbtxp",
            "rkqvkcpkg",
            "tqldr",
            "vgagiepjzl",
            "vzdotoqi"
        }
        if Ae_29[(Ae_7 * 62 + 68) % 9 + 1] < Ae_29[(Ae_7 * 62 + 68) % 9 + 1] then
            qJ = #Ae_27 > 18
        else
            Ae_27 = #qJ > 18
        end
        Ae_7 = (Ae_7 + 1) % 12
    end
until (Ae_7 * 7 + 10) % 12 == 6
if Ae_27 then
    Ae_7 = 4
    repeat
        Ae_41 = (vector.create((Ae_7 * 1 + 8) % 11 + 1, (Ae_7 * 10 + 11) % 13 + 1, (Ae_7 * 12 + 17) % 17 + 1))
        Ae_29 = (vector.create((Ae_7 * 4 + 6) % 11 + 1, (Ae_7 * 6 + 9) % 13 + 1, (Ae_7 * 8 + 8) % 17 + 1))
        local Bx = vector.dot(Ae_41, Ae_29)
        if Bx * Bx <= vector.dot(Ae_41, Ae_41) * vector.dot(Ae_29, Ae_29) then
            Ae_27 = string.sub(qJ, 1, 18) .. "..."
        else
            qJ = string.sub(Ae_27, 1, 18) .. "..."
        end
        Ae_7 = (Ae_7 + 5) % 8
    until (Ae_7 * 3 + 7) % 8 == 2
end
Ae_7 = Ae_27
local Ae_22 = if Ae_7 then 1 else 0
local Ae_1 = 4035 * Ae_22 + 919 * (1 - Ae_22)
local Ae_36 = 2613 * Ae_22 + 1293 * (1 - Ae_22)
if not ((Ae_1 * 1125 + Ae_36 * 3074 + Ae_1 * Ae_36) % 16777213 == 6337979) then
    Ae_7 = qJ
end
qf, Label2, Label3, Label4, Label5, Label7, Label6, Ae_2, GeneralsGroup, Label8, Label9, Label10, Ae_13, Ae_27, Label11, Label12, Label13, Label14, qX, qT, connection, pH, pA, onBuySelectedNow, onBuyBlackMarketNow, qY, qz, pI, q2, qi, onResearchNow, pO, q4, p0, onUnclaimNow, qr, px, q1, p8, pt, pZ, pJ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Ae_39 = Ae_7
Ae_43:AddLabel(qM("Server", Ae_39, p6), true)
Ae_43:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
qf = os.clock()
task.spawn(fns.worker2)
Ae_45 = Ae_47.Info:AddRightGroupbox("Scripts", "package")
Ae_45:AddLabel(q0("Included in this hub", p6), true)
Ae_45:AddLabel(q0(Ae_33, qh), true)
Ae_29 = Ae_47.Info:AddRightGroupbox("Features", "list")
Ae_29:AddLabel(q0("Auto Collect", qh), true)
Ae_29:AddLabel(q0("Auto Sell", qc), true)
Ae_29:AddLabel(q0("Auto Rewards", qn), true)
Ae_29:AddLabel(q0("Auto Buy", qh), true)
Ae_29:AddLabel(q0("Generals and Research", qc), true)
Ae_29:AddLabel(q0("Auto Conquer", p6), true)
Ae_29:AddLabel(q0("Alien Event", qn), true)
Ae_41 = Ae_47.Info:AddRightGroupbox("Socials", "link")
Ae_41:AddButton({ Text = "Discord", Func = re })
Ae_41:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
local TempoHubGroup = Ae_47.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = re })
local FaqGroup = Ae_47.Info:AddRightGroupbox("FAQ", "circle-help")
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
local CollectGroup = Ae_47.Farming:AddLeftGroupbox("Collect", "hand-coins")
CollectGroup:AddToggle("AutoCollect", { Text = "Auto Collect", Default = false })
CollectGroup:AddToggle("AutoCollectAlienOnly", { Text = "Collect Alien Mutations Only", Default = false })
CollectGroup:AddSlider("CollectDelay", { Text = "Collect delay", Default = 5, Min = 0.5, Max = 60, Rounding = 1, Suffix = "s" })
CollectGroup:AddButton({
    Text = "Collect Now",
    Func = function()
        for k, v in qd() do
            local vS = v
            if qj(vS) then
                pcall(function()
                    p_:Fire(vS)
                end)
                task.wait(0.05)
            end
        end
    end
})
CollectGroup:AddToggle("AutoOfflineEarnings", { Text = "Auto Claim Offline Earnings", Default = true })
local YourResourcesGroup = Ae_47.Farming:AddRightGroupbox("Your Resources", "boxes")
Label2 = YourResourcesGroup:AddLabel("No farms on your base yet.", true)
Ae_37 = Ae_47.Selling:AddLeftGroupbox("Sell", "banknote")
Ae_37:AddToggle("AutoSellAll", { Text = "Auto Sell ALL", Default = false })
Ae_37:AddButton({ Text = "Sell All Now", Func = fns.onSellAllNow })
Ae_37:AddToggle("AutoSellHighPrice", { Text = "Auto Sell at High Price", Default = false })
Ae_37:AddSlider("SellThreshold", { Text = "Sell when above", Default = 10, Min = 0, Max = 100, Rounding = 0, Suffix = "%" })
Ae_37:AddButton({ Text = "Sell High Price Items Now", Func = pX })
Ae_37:AddSlider("SellDelay", { Text = "Sell delay", Default = 10, Min = 1, Max = 120, Rounding = 1, Suffix = "s" })
Ae_37:AddButton({ Text = "Sell All Buildings In Backpack", Func = fns.onSellAllBuildingsInBackpack })
Label3 = Ae_37:AddLabel(qM("Best price", "none", qc), true)
Label4 = Ae_37:AddLabel(qM("Above threshold", "none", qn), true)
Ae_49 = Ae_47.Alien:AddLeftGroupbox("Alien Event", "atom")
Ae_49:AddToggle("AutoExtractAlien", { Text = "Auto Extract Alien Resources", Default = false })
Ae_49:AddButton({ Text = "Extract All Now", Func = fns.onExtractAllNow })
Ae_49:AddButton({ Text = "Extract Held Item Now", Func = fns.onExtractHeldItemNow })
Ae_49:AddSlider("AlienDelay", { Text = "Extract delay", Default = 15, Min = 2, Max = 120, Rounding = 1, Suffix = "s" })
Label5 = Ae_49:AddLabel(qM("Alien cores", "0", qn), true)
local RewardsGroup = Ae_47.Rewards:AddLeftGroupbox("Rewards", "gift")
if (not Ae_27 and pt and (not Ae_29 and pt) or (Ae_27 or not pZ) and (pt and pZ) or (Ae_29 and not Ae_29 or (not Ae_27 or not Ae_27) or (Ae_27 and pZ or Ae_29 and not Ae_29))) and (((not Ae_27 or not Ae_27) and (pZ and Ae_29) or (not Ae_27 or not pZ) and (Ae_29 or not Ae_29)) and ((not Ae_27 and pt or (pt or Ae_27)) and (not Ae_29 and not Ae_27 and (not Ae_29 or pZ)))) or not ((not Ae_27 and pt and (not Ae_29 and pt) or (Ae_27 or not pZ) and (pt and pZ) or (Ae_29 and not Ae_29 or (not Ae_27 or not Ae_27) or (Ae_27 and pZ or Ae_29 and not Ae_29))) and (((not Ae_27 or not Ae_27) and (pZ and Ae_29) or (not Ae_27 or not pZ) and (Ae_29 or not Ae_29)) and ((not Ae_27 and pt or (pt or Ae_27)) and (not Ae_29 and not Ae_27 and (not Ae_29 or pZ))))) then
    RewardsGroup:AddToggle("AutoQuests", { Text = "Auto Claim Quests", Default = true })
    Label7 = RewardsGroup:AddLabel(qM("Quests", "0 ready, 0 claimed", qn), true)
    RewardsGroup:AddToggle("AutoBattlepass", { Text = "Auto Claim Battlepass", Default = true })
    RewardsGroup:AddToggle("AutoWarPassPoints", { Text = "Auto Collect War Pass Points", Default = true })
    Label6 = RewardsGroup:AddLabel(qM("Pass points", "0", qh), true)
else
    qh:AddToggle("AutoQuests", { Text = "Auto Claim Quests", Default = true })
    qn = qh:AddLabel(Label6("Quests", "0 ready, 0 claimed", RewardsGroup), true)
    qh:AddToggle("AutoBattlepass", { Text = "Auto Claim Battlepass", Default = true })
    qh:AddToggle("AutoWarPassPoints", { Text = "Auto Collect War Pass Points", Default = true })
    qM = qh:AddLabel(Label6("Pass points", "0", Label7), true)
end
RewardsGroup:AddSlider("RewardsDelay", { Text = "Rewards delay", Default = 10, Min = 2, Max = 120, Rounding = 1, Suffix = "s" })
local AutoBuyGroup = Ae_47.Shop:AddLeftGroupbox("Auto Buy", "shopping-cart")
AutoBuyGroup:AddToggle("AutoBuy", { Text = "Auto Buy", Default = false })
AutoBuyGroup:AddDropdown("BuyFarm", {
    Text = "Factory (Farms)",
    Values = onBuyBlackMarketNow2("Farm"),
    Multi = true,
    AllowNull = true,
    Default = {}
})
AutoBuyGroup:AddDropdown("BuyHouse", {
    Text = "Houses",
    Values = onBuyBlackMarketNow2("House"),
    Multi = true,
    AllowNull = true,
    Default = {}
})
AutoBuyGroup:AddDropdown("BuyMilitary", {
    Text = "Military",
    Values = onBuyBlackMarketNow2("Military"),
    Multi = true,
    AllowNull = true,
    Default = {}
})
AutoBuyGroup:AddDropdown("BuyDecor", {
    Text = "Special",
    Values = onBuyBlackMarketNow2("Decor"),
    Multi = true,
    AllowNull = true,
    Default = {}
})
Ae_2 = {
    { shop = "Farm", option = "BuyFarm" },
    { shop = "House", option = "BuyHouse" },
    { shop = "Military", option = "BuyMilitary" },
    { shop = "Decor", option = "BuyDecor" }
}
onBuySelectedNow = function()
    for k, v in Ae_2 do
        local v_ = v
        for k, v in pairs(rb(v_.option)) do
            local v3 = k
            local vT = v and qN(v_.shop, v3) > 0
            if vT then
                pcall(function()
                    q8:Fire({ shop = v_.shop, item = v3 })
                end)
                task.wait(0.2)
            end
        end
    end
end
if (qf and not qf or (not onBuyBlackMarketNow or not p8)) and (Label8 or not qf or qf and qf) and not ((qf and not qf or (not onBuyBlackMarketNow or not p8)) and (Label8 or not qf or qf and qf)) then
    qM:AddButton({ Text = "Buy Selected Now", Func = AutoBuyGroup })
    qM:AddSlider("BuyDelay", { Default = 10, Max = 120, Suffix = "s", Min = 2, Rounding = 1, Text = "Buy delay" })
    onBuyBlackMarketNow = onBuySelectedNow.Shop:AddRightGroupbox("Black Market", "store")
    onBuyBlackMarketNow:AddToggle("AutoBlackMarket", { Text = "Auto Buy Black Market", Default = false })
    onBuyBlackMarketNow:AddDropdown("BuyBlackMarket", {
        Multi = true,
        AllowNull = true,
        Default = {},
        Text = "Items to grab",
        Values = GeneralsGroup("BlackMarket")
    })
    onBuyBlackMarketNow2 = function()
        for k, v in pairs(rb("BuyBlackMarket")) do
            local wb = k
            local v6 = v and qN("BlackMarket", wb) > 0
            if v6 then
                pcall(function()
                    q5:Fire({ shop = "BlackMarket", item = wb })
                end)
                task.wait(0.2)
            end
        end
    end
    onBuyBlackMarketNow:AddButton({ Text = "Buy Black Market Now", Func = onBuyBlackMarketNow2 })
    qY = onBuySelectedNow.Empire:AddLeftGroupbox("Generals", "star")
    qY:AddToggle("AutoRollGenerals", { Text = "Auto Roll Generals", Default = false })
    qY:AddToggle("AutoEquipGenerals", { Text = "Auto Equip Generals", Default = true })
    qY:AddSlider("GemReserve", { Text = "Keep at least", Suffix = " gems", Default = 0, Min = 0, Max = 10000, Rounding = 0 })
    Ae_35 = fn942
    qY:AddButton({ Text = "Roll Now", Func = Ae_35 })
    p6 = qY:AddLabel(Ae_47("Generals", "0 owned", Label8), true)
else
    AutoBuyGroup:AddButton({ Text = "Buy Selected Now", Func = onBuySelectedNow })
    AutoBuyGroup:AddSlider("BuyDelay", { Text = "Buy delay", Default = 10, Min = 2, Max = 120, Rounding = 1, Suffix = "s" })
    Ae_35 = Ae_47.Shop:AddRightGroupbox("Black Market", "store")
    Ae_35:AddToggle("AutoBlackMarket", { Text = "Auto Buy Black Market", Default = false })
    Ae_35:AddDropdown("BuyBlackMarket", {
        Text = "Items to grab",
        Values = onBuyBlackMarketNow2("BlackMarket"),
        Multi = true,
        AllowNull = true,
        Default = {}
    })
    onBuyBlackMarketNow = function()
        for k, v in pairs(rb("BuyBlackMarket")) do
            local wb = k
            local v6 = v and qN("BlackMarket", wb) > 0
            if v6 then
                pcall(function()
                    q5:Fire({ shop = "BlackMarket", item = wb })
                end)
                task.wait(0.2)
            end
        end
    end
    Ae_35:AddButton({ Text = "Buy Black Market Now", Func = onBuyBlackMarketNow })
    GeneralsGroup = Ae_47.Empire:AddLeftGroupbox("Generals", "star")
    GeneralsGroup:AddToggle("AutoRollGenerals", { Text = "Auto Roll Generals", Default = false })
    GeneralsGroup:AddToggle("AutoEquipGenerals", { Text = "Auto Equip Generals", Default = true })
    GeneralsGroup:AddSlider("GemReserve", { Text = "Keep at least", Default = 0, Min = 0, Max = 10000, Rounding = 0, Suffix = " gems" })
    qY = fn942
    GeneralsGroup:AddButton({ Text = "Roll Now", Func = qY })
    Label8 = GeneralsGroup:AddLabel(qM("Generals", "0 owned", p6), true)
end
qz = fn862
pI = fns.fn187
q2 = fns.fn205
local ResearchGroup = Ae_47.Empire:AddRightGroupbox("Research", "flask-conical")
ResearchGroup:AddToggle("AutoResearch", { Text = "Auto Research", Default = false })
ResearchGroup:AddDropdown("ResearchPriority", {
    Text = "Prioritise path",
    Values = { "Smart (cheapest)", "Economy", "Military", "Special" },
    Default = "Smart (cheapest)"
})
qi = function()
    local wL
    local wM = p3()
    local wN = wM and wM.skills
    local wN_1 = {}
    local wO = wN and type(wN.skillsThatCanBeUnlocked) == "table"
    if wO then
        for k, v in pairs(wN.skillsThatCanBeUnlocked) do
            if v and SkillsConfig[k] then
                if not (wN.unlockedSkills and wN.unlockedSkills[k]) then
                    if not (wN.currentlyUnlockingSkills and wN.currentlyUnlockingSkills[k]) then
                        table.insert(wN_1, k)
                    end
                end
            end
        end
    end
    wL = qO("ResearchPriority")
    table.sort(wN_1, function(f9, ga)
        local wD_1
        local wC_1
        wC_1, wD_1 = SkillsConfig[f9], SkillsConfig[ga]
        local wF = wL == wC_1.Type and 1 or 0
        local wF_2 = wL == wD_1.Type and 1 or 0
        if wF ~= wF_2 then
            return wF > wF_2
        end
        local wE_2 = wC_1.Cost
        local wK = if wE_2 then 1 else 0
        local wI = 274 * wK + 2511 * (1 - wK)
        local wJ = 105 * wK + 779 * (1 - wK)
        if not ((wI * 2440 + wJ * 2805 + wI * wJ) % 16777213 == 991855) then
            wE_2 = 0
        end
        return wE_2 < (wD_1.Cost or 0)
    end)
    return wN_1
end
onResearchNow = function()
    local wX = qi()
    local wW = wX[1]
    if wW then
        pcall(function()
            qR:Fire(wW)
        end)
    end
    return wW
end
ResearchGroup:AddButton({ Text = "Research Now", Func = onResearchNow })
Label9 = ResearchGroup:AddLabel(qM("Ready", "0 skills", p6), true)
ResearchGroup:AddSlider("EmpireDelay", { Text = "Empire delay", Default = 10, Min = 2, Max = 120, Rounding = 1, Suffix = "s" })
Ae_21 = Ae_47.Bases:AddLeftGroupbox("Conquer", "swords")
Ae_21:AddDropdown("DeployArmy", { Text = "Armies", Values = qH, Multi = true, AllowNull = true, Default = { "Army 1" } })
Ae_21:AddDropdown("DeployTarget", {
    Text = "Deploy Target",
    Values = { "Nearest to base", "Weakest defender", "Strongest defender" },
    Default = "Nearest to base"
})
Ae_21:AddDropdown("TargetTypes", { Text = "Base types", Values = Ae_19, Multi = true, AllowNull = true, Default = {} })
pO = function()
    local w_
    w_ = nil
    local w0 = p9(rb("TargetTypes"))
    if #w0 == 0 then
        return nil
    end
    w_ = qO("DeployTarget")
    table.sort(w0, function(gu, gv)
        if w_ == "Weakest defender" then
            return gu.strength < gv.strength
        elseif w_ == "Strongest defender" then
            return gu.strength > gv.strength
        else
            return gu.distance < gv.distance
        end
    end)
    return w0[1].point
end
q4 = function(gy)
    if not gy then
        return
    end
    for k, v in qC() do
        local w8 = v
        pcall(function()
            qK:Fire({ armyIndex = w8, capturePoint = gy })
        end)
        task.wait(0.2)
    end
    if Ae_18("IncludeRockets") then
        pcall(function()
            qE:Fire({ capturePoint = gy })
        end)
    end
end
p0 = fns.fn393
onUnclaimNow = function()
    local xi = rb("UnclaimTypes")
    local xn = if not qo(xi) then 1 else 0
    if xn == 1 then
        return
    end
    for k, v in p7() do
        local xt = v
        local xj = rh(xt) and xi[tostring(xt:GetAttribute("baseType"))]
        if xj then
            pcall(function()
                qv:Fire(xt)
            end)
            task.wait(0.2)
        end
    end
end
Ae_21:AddButton({ Text = "Deploy Now", Func = fns.onDeployNow })
Ae_21:AddToggle("AutoConquer", { Text = "Auto Conquer", Default = false })
Ae_21:AddToggle("IncludeRockets", { Text = "Include Rockets", Default = false })
Ae_21:AddSlider("ConquerQueueSize", { Text = "Queue size", Default = 3, Min = 1, Max = 7, Rounding = 0 })
Ae_21:AddSlider("ConquerDelay", { Text = "Conquer delay", Default = 15, Min = 3, Max = 180, Rounding = 1, Suffix = "s" })
Ae_21:AddButton({ Text = "Clear Auto Conquer Queue", Func = fns.onClearAutoConquerQueue })
Ae_3 = Ae_47.Events:AddLeftGroupbox("Raid and Event Sites", "siren")
Ae_3:AddToggle("AutoEventDeploy", { Text = "Auto Deploy on Raid / Event Sites", Default = false })
Ae_3:AddToggle("EventPriority", { Text = "Pause Auto Conquer During Events", Default = true })
Ae_3:AddDropdown("EventTypes", { Text = "Site types", Values = qG, Multi = true, AllowNull = true, Default = qG })
Ae_3:AddButton({ Text = "Deploy on Site Now", Func = fns.onDeployOnSiteNow })
Label10 = Ae_3:AddLabel(qM("Sites open", "0", qc), true)
if ((not Label7 or not Label7 or (not Label2 or false)) and (not Label10 and qi and (Label2 or not Label10)) or (not Label3 and not qf and (not Label7 or Label2) or (not Label2 or false) and (not Label7 or false))) and not ((not Label7 or not Label7 or (not Label2 or false)) and (not Label10 and qi and (Label2 or not Label10)) or (not Label3 and not qf and (not Label7 or Label2) or (not Label2 or false) and (not Label7 or false))) then
    Ae_47 = Ae_13.Holdings:AddLeftGroupbox("Unclaim", "flag-off")
else
    Ae_13 = Ae_47.Holdings:AddLeftGroupbox("Unclaim", "flag-off")
end
Ae_13:AddToggle("AutoUnclaim", { Text = "Auto Unclaim Bases", Default = false })
Ae_13:AddDropdown("UnclaimTypes", {
    Text = "Types to drop",
    Values = Ae_19,
    Multi = true,
    AllowNull = true,
    Default = { "Garnison", "Camp" }
})
Ae_13:AddButton({ Text = "Unclaim Now", Func = onUnclaimNow })
Ae_27 = Ae_47.Holdings:AddRightGroupbox("Domination", "flag")
Label11 = Ae_27:AddLabel(qM("Held bases", "0", qn), true)
Label12 = Ae_27:AddLabel(qM("Available", "0", qh), true)
Label13 = Ae_27:AddLabel(qM("Next target", "none", qc), true)
Label14 = Ae_27:AddLabel(qM("Weather", "None", p6), true)
local MenuGroup = Ae_47.Settings:AddLeftGroupbox("Menu", "menu")
p5.ToggleKeybind = pE.MenuKeybind
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddToggle("BlackScreen", { Text = "Black Screen", Default = false })
MenuGroup:AddButton({ Text = "Unload", Func = fns.onUnload })
Ae_16:SetLibrary(p5)
Ae_16:SetFolder("TempoHub")
Ae_16:SaveDefault("Monochrome")
Ae_16:ApplyToTab(Ae_47.Settings)
Ae_16:LoadDefault()
Ae_31:SetLibrary(p5)
Ae_31:IgnoreThemeSettings()
Ae_31:SetIgnoreIndexes({ "MenuKeybind" })
Ae_31:SetFolder("TempoHub/mini-war")
Ae_31:BuildConfigSection(Ae_47.Settings)
Ae_31:LoadAutoloadConfig()
qX = tick()
qT = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local xC = v
        pcall(function()
            xC:Disable()
        end)
    end
end)
qr = fns.fn211
connection = UserInputService.InputBegan:Connect(fns.onInputBegan)
if ((not p8 or FaqGroup) and (Ae_13 or not Ae_13) or (not FaqGroup and FaqGroup or (Ae_13 or not Ae_13))) and ((not Ae_13 or p8 or Ae_13 and not FaqGroup) and ((not FaqGroup or not p8) and (not Ae_13 and FaqGroup))) and not (((not p8 or FaqGroup) and (Ae_13 or not Ae_13) or (not FaqGroup and FaqGroup or (Ae_13 or not Ae_13))) and ((not Ae_13 or p8 or Ae_13 and not FaqGroup) and ((not FaqGroup or not p8) and (not Ae_13 and FaqGroup)))) then
    pA.InputChanged:Connect(fns.onInputChanged)
    pH = { active = false, hidden = nil, labels = nil, cover = nil }
else
    pH = UserInputService.InputChanged:Connect(fns.onInputChanged)
    pA = { active = false, cover = nil, hidden = nil, labels = nil }
end
px = fns.fn181
q1 = fns.fn62
p8 = fns.fn166
pt = function(h4)
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    pcall(function()
        RunService:Set3dRenderingEnabled(not h4)
    end)
    if h4 then
        local xS = pA.hidden or {}
        pA.hidden = xS
        if PlayerGui then
            for i, child in PlayerGui:GetChildren() do
                local xQ_1 = child:IsA("ScreenGui") and child.Enabled and child ~= p5.ScreenGui and child.Name ~= "TempoBlackScreen"
                if xQ_1 then
                    child.Enabled = false
                    table.insert(pA.hidden, child)
                end
            end
        end
        q1()
        p8()
    else
        local xR_2 = pA.hidden or {}
        for k, v in xR_2 do
            local x4 = v
            pcall(function()
                x4.Enabled = true
            end)
        end
        pA.hidden = nil
        if pA.cover then
            pcall(function()
                pA.cover:Destroy()
            end)
            pA.cover = nil
            pA.labels = nil
        end
    end
    pA.active = h4
end
pZ = fn963
pJ = function(is)
    local yh = qP()
    if not yh or not is.Parent then
        return
    end
    local CFrame2 = yh.CFrame
    local yj = CFrame.new(is:GetPivot().Position)
    local yk = os.clock() + 6
    while true do
        local yl = is.Parent and os.clock() < yk and not p5.Unloaded
        if yl then
            yh.CFrame = yj
            task.wait(0.1)
            continue
        end
        break
    end
    if is.Parent then
        local attr = is:GetAttribute("PickupId")
        if attr then
            pcall(function()
                rd:Fire(attr)
            end)
        end
    end
    yh.CFrame = CFrame2
end
p5:OnUnload(fns.fn701)
task.spawn(fns.worker3)
task.spawn(fns.worker4)
task.spawn(fns.worker5)
task.spawn(function()
    while not p5.Unloaded do
        if Ae_18("AutoCollect") then
            for k, v in qd() do
                local yK = v
                if p5.Unloaded then
                    break
                elseif qj(yK) then
                    pcall(function()
                        p_:Fire(yK)
                    end)
                    task.wait(0.05)
                end
            end
        end
        if Ae_18("AutoOfflineEarnings") then
            pcall(function()
                pW:Fire()
            end)
        end
        task.wait(pG("CollectDelay", 5))
    end
end)
task.spawn(worker6)
task.spawn(function()
    while not p5.Unloaded do
        local yM = p3()
        local yN = yM and Ae_18("AutoQuests")
        if yN then
            local questData = yM.questData
            if questData then
                local yP_1 = questData.activeQuests or {}
                for k, v in pairs(yP_1) do
                    local yW = k
                    local yO_2 = type(v) == "table" and v.completed
                    if yO_2 then
                        pcall(function()
                            pu:Fire(yW)
                        end)
                        task.wait(0.2)
                    end
                end
                local yP_2 = questData.claimedTier or {}
                local yP_3 = questData.tier or 0
                for i = 1, yP_3 do
                    local y1 = i
                    local yN_2 = not yP_2[y1] and not yP_2[tostring(y1)]
                    if yN_2 then
                        pcall(function()
                            pr:Fire(tostring(y1))
                        end)
                        task.wait(0.2)
                    end
                end
            end
        end
        local yN_3 = yM and Ae_18("AutoBattlepass")
        if yN_3 then
            local battlepass = yM.battlepass
            if battlepass then
                local yM_1 = battlepass.bpPoints or 0
                local yP_4 = battlepass.claimedFreeBP or {}
                local yQ = battlepass.claimedPremiumBP or {}
                local TOTAL_STAGES = BattlepassConfig.TOTAL_STAGES
                for i = 1, TOTAL_STAGES do
                    local y3 = i
                    local yQ_2 = BattlepassConfig.GetStagePointRequirement(y3)
                    local yR = type(yQ_2) ~= "number" or yM_1 < yQ_2
                    if yR then
                        break
                    end
                    local yQ_3 = not yP_4[y3] and not yP_4[tostring(y3)]
                    if yQ_3 then
                        pcall(function()
                            rk:Fire({ track = "Free", stage = y3 })
                        end)
                        task.wait(0.2)
                    end
                    local yQ_4 = battlepass.hasPremiumBP and not yQ[y3] and not yQ[tostring(y3)]
                    if yQ_4 then
                        pcall(function()
                            rk:Fire({ track = "Premium", stage = y3 })
                        end)
                        task.wait(0.2)
                    end
                end
            end
        end
        task.wait(pG("RewardsDelay", 10))
    end
end)
task.spawn(fns.worker7)
task.spawn(worker8)
task.spawn(function()
    while not p5.Unloaded do
        local y7 = p3()
        local y8 = y7 and Ae_18("AutoRollGenerals")
        if y8 then
            local y8_1 = y7.gems
            local zc = if y8_1 then 1 else 0
            local za = 1489 * zc + 1738 * (1 - zc)
            local zb = 426 * zc + 3434 * (1 - zc)
            if not ((za * 622 + zb * 2461 + za * zb) % 16777213 == 2608858) then
                y8_1 = 0
            end
            local y7_1 = y8_1
            if y7_1 - Ae_15.gemRollCost >= pG("GemReserve", 0) then
                qY()
            end
        end
        if Ae_18("AutoEquipGenerals") then
            local y7_2 = qz()
            table.sort(y7_2, function(ke, kf)
                return pI(ke) > pI(kf)
            end)
            local y8_2 = Ae_15.MAX_SLOTS or 1
            for i = 1, y8_2 do
                local zg = i
                local y6 = y7_2[zg]
                local y8_3 = y6 and q2(zg) ~= y6
                if y8_3 then
                    pcall(function()
                        qV:Fire({ generalKey = y6, slotIndex = zg })
                    end)
                    task.wait(0.3)
                end
            end
        end
        if Ae_18("AutoResearch") then
            onResearchNow()
        end
        task.wait(pG("EmpireDelay", 10))
    end
end)
task.spawn(function()
    local zp = false
    repeat
        local zj
        if not p5.Unloaded then
            if Ae_18("AutoUnclaim") then
                onUnclaimNow()
            end
            local zk = false
            if Ae_18("AutoEventDeploy") then
                local zl_1 = p0()
                if zl_1[1] then
                    zk = true
                    q4(zl_1[1].point)
                    pcall(function()
                        qy:Fire({ queue = {} })
                    end)
                end
            end
            local zl_2 = (Ae_18("AutoConquer"))
            if zl_2 then
                local zm = zk and Ae_18("EventPriority")
                zl_2 = not zm
            end
            if zl_2 then
                local zk_1 = p9(rb("TargetTypes"))
                zj = qO("DeployTarget")
                table.sort(zk_1, function(kJ, kK)
                    if zj == "Weakest defender" then
                        return kJ.strength < kK.strength
                    elseif zj == "Strongest defender" then
                        return kJ.strength > kK.strength
                    else
                        return kJ.distance < kK.distance
                    end
                end)
                local zi = {}
                local zl_3 = math.min(#zk_1, pG("ConquerQueueSize", 3))
                local zs = 1
                while zs <= zl_3 do
                    local zt = zs
                    table.insert(zi, zk_1[zt].point)
                    zs += 1
                end
                if #zi > 0 then
                    pcall(function()
                        qy:Fire({ queue = zi, deployType = qC()[1] })
                    end)
                    q4(zi[1])
                end
            end
            task.wait(pG("ConquerDelay", 15))
        else
            zp = true
        end
    until zp
end)
task.spawn(fns.worker9)
task.spawn(fns.worker10)
p5:Notify("Mini War loaded")
end)(...)

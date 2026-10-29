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
getgenv().TempoHoodSubtitle = "PRESS A KEYCAP!"
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
local Toggles
local lA
local lg
local kY
local UserInputService
local kF
local LocalPlayer
local k3
local lM
local lt
local k9
local WorkersConfig
local Label
local lf
local kX
local lF
local kE
local ll
local k2
local lL
local kK
local ls
local connection
local kQ
local ly
local le
local kW
local VirtualUser
local PlayerState
local lK
local Library
local Workspace
local k7
local RebirthConfig
local lx
local ld
local GridLayout
local HttpService
local __tempo_gen
local k0
local lJ
local kI
local lq
local kO
local lc
local UpgradesConfig
local lC
local li
local k_
local SetNotifySide
local kH
local lo
local Options
local kN
local lv
local connection2
local lh
local Keycaps
local lH
local kG
local ln
local k4
local lN
local ZonesConfig
local lu
function fns.antiGameplayPauseLoop()
    while not Library.Unloaded and ln.__tempo_gen == __tempo_gen do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            lJ(true)
        end
    end
end
function fns.onAutoRebirth(ew)
    kH.autoRebirth = ew
    if ew then
        kQ("autoRebirth")
    end
end
local function onCopySolanaAddress()
    kW(k3, "Copied Solana address")
end
local function fn79()
    local ne = PlayerState.Money()[ls] or 0
    return ne
end
local function fn118(aL)
    local mC = tonumber(aL) or 0
    aL = mC
    local mC_1 = 0
    local mD = { "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No" }
    while aL >= 1000 and mC_1 < 10 do
        aL = aL / 1000
        mC_1 = mC_1 + 1
    end
    if mC_1 == 0 then
        return string.format("%d", aL)
    end
    return string.format("%.2f%s", aL, mD[mC_1])
end
local function onCopyEthereumAddress()
    kW(lc, "Copied Ethereum address")
end
local function onUpgradeSel(el)
    for k, v in pairs(lx) do
        lH[v] = false
    end
    local oK = type(el) == "table" and el
    local oK_1 = oK or { el }
    for k, v in pairs(oK_1) do
        local oK_2 = type(k) == "number" and v
        local oL_2 = lx[oK_2 or k]
        if oL_2 then
            lH[oL_2] = true
        end
    end
end
local function fn126(cT)
    local DiscordGroup = cT:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = kN })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = kN })
end
local function fn140()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    lK = tick()
end
local function fn150()
    local n3_1
    local n2_1
    if identifyexecutor then
        n3_1, n2_1 = identifyexecutor()
        local n4 = n3_1 ~= ""
        local n5 = type(n3_1) == "string" and n4
        if n5 then
            local n4_1 = type(n2_1) == "string" and n2_1 ~= "" and n3_1 .. " " .. n2_1
            local n2_2 = n4_1
            local n9 = if n2_2 then 1 else 0
            local n7 = 3515 * n9 + 415 * (1 - n9)
            local n8 = 1838 * n9 + 58 * (1 - n9)
            if not ((n7 * 806 + n8 * 1407 + n7 * n8) % 16777213 == 11879726) then
                n2_2 = n3_1
            end
            kE = n2_2
        end
    end
end
local function fn162()
    Library.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
local function fn169()
    if not Toggles.Fly.Value then
        local pa = ld()
        if pa then
            pa.PlatformStand = false
        end
    end
end
local function onInputChanged(fA)
    local UserInputType = fA.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        lN = tick()
    end
end
local function fn180()
    kW(k2, "Copied Discord invite to clipboard")
end
local function fn185()
    if kH.autoBuy or kH.autoUnlock then
        return
    end
    local Unlock = ly.Unlock
    local nr = kF.plotName or PlayerState.PlotOwner()[ls]
    Unlock:fire("RequestRoll", nr)
end
local function onAutoBuy(dR)
    kH.autoBuy = dR
    if dR then
        kQ("autoBuy")
    end
end
local function fn226()
    local nL = PlayerState.Rebirths()[ls] or 0
    local nL_1 = PlayerState.CurrentPresses()[ls] or 0
    local nL_2 = RebirthConfig.Next(nL)
    if nL_2 and nL_1 >= nL_2.Presses then
        ly.Rebirth:fire("Rebirth")
    end
end
local function onCopyLitecoinAddress()
    kW(ll, "Copied Litecoin address")
end
local function onAutoWorkers(dK)
    kH.autoWorkers = dK
    if dK then
        kQ("autoWorkers")
    end
end
local function fn245()
    local nj = PlayerState.Workers()[ls]
    local np = if nj then 1 else 0
    local nn = 4036 * np + 2313 * (1 - np)
    local no = 230 * np + 1666 * (1 - np)
    if not ((nn * 3854 + no * 2499 + nn * no) % 16777213 == 280581) then
        nj = 0
    end
    local nk = nj
    local nj_1 = PlayerState.Rebirths()[ls] or 0
    local nj_2 = math.min(WorkersConfig.BaseMax + RebirthConfig.ExtraWorkersFor(nj_1), #WorkersConfig.Prices)
    if nk >= nj_2 then
        return
    end
    local nj_3 = WorkersConfig.Prices[nk + 1]
    if le() >= nj_3 then
        ly.Workers:fire("BuyWorkers", 1)
    end
end
local function fn246()
    local nt = PlayerState.Zones()[ls]
    if not nt then
        return
    end
    local nu = GridLayout.BuyableZones(nt)[1]
    if not nu then
        return
    end
    local nv = PlayerState.Rebirths()[ls] or 0
    local nv_1 = math.min(ZonesConfig.BaseUnlockable + RebirthConfig.ExtraZonesFor(nv), #ZonesConfig.Prices)
    if #nt >= nv_1 then
        return
    end
    local nv_2 = ZonesConfig.Prices[#nt]
    local nt_1 = nv_2 and le() >= nv_2
    if nt_1 then
        ly.Zones:fire("BuyZone", nu)
    end
end
local function fn271()
    local Character = li.Character
    if not Character then
        return nil
    end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not HumanoidRootPart or Humanoid.Health <= 0 then
        return nil
    end
    return HumanoidRootPart
end
local function onCopyJoinScript_JobID()
    local c7 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, lu)
    kW(c7, "Copied join script to clipboard")
end
local function fn303(am, an, ao)
    return string.format("<b>%s</b> %s %s", am, kI("-", "#5a6070"), kI(an, ao))
end
local function onUnload()
    Library:Unload()
end
local function onCopyPayPalLink()
    kW(k0, "Copied PayPal link")
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local pt_1 = ld()
        if pt_1 then
            pt_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn522()
    local p5 = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local p6 = type(v) == "table" and type(v.Type) == "string" and not kG.Ignore[k]
            if p6 then
                local p6_1 = lF(k, v)
                if p6_1 then
                    p5[#p5 + 1] = p6_1
                end
            end
        end
    end
    table.sort(p5, function(f3, f4)
        if f3.type ~= f4.type then
            return f3.type < f4.type
        end
        return f3.idx < f4.idx
    end)
    return { objects = p5 }
end
local function onCopyVenmoLink()
    kW(kX, "Copied Venmo link")
end
local function onRenderStepped(e7)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local py_1 = ld()
        if py_1 then
            py_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local py_3 = kY()
        local pz = ld()
        lo = Workspace.CurrentCamera or lo
        if py_3 and pz and lo then
            pz.PlatformStand = true
            local pz_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                pz_1 = pz_1 + lo.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                pz_1 = pz_1 - lo.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                pz_1 = pz_1 - lo.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                pz_1 = pz_1 + lo.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                pz_1 = pz_1 + Vector3.new(0, 1, 0)
            end
            local pF = if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then 1 else 0
            if pF == 1 then
                pz_1 = pz_1 - Vector3.new(0, 1, 0)
            end
            py_3.Velocity = Vector3.zero
            if pz_1.Magnitude > 0 then
                py_3.CFrame = py_3.CFrame + pz_1.Unit * Options.FlySpeed.Value * e7
            end
        end
    end
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = li.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local pe_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if pe_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn575()
    lJ(Toggles.AntiGameplayPause.Value)
end
local function onCopyUSDTAddress()
    kW(k7, "Copied USDT address")
end
local function fn619()
    for i, v in ipairs(UpgradesConfig.Order) do
        if lH[v] then
            ly.Upgrades:fire("BuyUpgrade", v)
            task.wait(0.2)
        end
    end
end
local function fn656(aj, ak)
    return string.format('<font color="%s">%s</font>', ak, aj)
end
local function antiAfkLoop()
    while true do
        if not Library.Unloaded and ln.__tempo_gen == __tempo_gen then
            task.wait(2)
            if Toggles.AntiAfk.Value then
                local qU_1 = tick() - lN
                local qV = tick() - lK
                if qU_1 >= 300 and qV >= 60 then
                    pcall(lA)
                else
                    if qU_1 < 300 and qV >= 300 then
                        pcall(lA)
                    end
                end
            end
            continue
        end
        break
    end
end
local function onAutoUpgrade(ei)
    kH.autoUpgrade = ei
    kH.upgradeLoop = ei
    if ei then
        kQ("upgradeLoop")
    end
end
local function fn687()
    kH.autoWalk = false
    kH.autoWorkers = false
    kH.autoRoll = false
    kH.autoBuy = false
    kH.autoUnlock = false
    kH.autoRebirth = false
    kH.autoUpgrade = false
    kH.upgradeLoop = false
    connection:Disconnect()
    connection2:Disconnect()
    lJ(false)
    local q4 = ld()
    if q4 then
        q4.PlatformStand = false
        q4.WalkSpeed = 16
    end
end
local function fn690()
    if not Toggles.WalkSpeedEnabled.Value then
        local pc = ld()
        if pc then
            pc.WalkSpeed = 16
        end
    end
end
local function onRarityThreshold(d9)
    for i, v in ipairs(lf) do
        if v == d9 then
            kF.rarityThreshold = k9[i]
            break
        end
    end
end
local function fn740()
    local om = {}
    for k, v in pairs(Keycaps.Types) do
        if v.OneIn > 0 then
            table.insert(om, { name = k, mpp = v.MoneyPerPress })
        end
    end
    table.sort(om, function(d2, d3)
        return d2.mpp > d3.mpp
    end)
    for i, v in ipairs(om) do
        table.insert(lf, v.name .. " ($" .. lM(v.mpp) .. ")")
        table.insert(k9, v.mpp)
    end
end
local function fn755()
    local m8 = {}
    local m9 = PlayerState.PendingUnlock()[ls]
    local nd = if m9 then 1 else 0
    local nb = 1418 * nd + 903 * (1 - nd)
    local nc = 4056 * nd + 1390 * (1 - nd)
    if not ((nb * 2417 + nc * 957 + nb * nc) % 16777213 == 13060306) then
        m9 = m8
    end
    return m9
end
local function fn762()
    local Character = li.Character
    local mR = Character and Character:FindFirstChildOfClass("Humanoid")
    return mR
end
local function fn764()
    local q2 = ln.__tempo_gen or 0
    ln.__tempo_gen = q2 + 1
    kH.autoWalk = false
    kH.autoWorkers = false
    kH.autoRoll = false
    kH.autoBuy = false
    kH.autoUnlock = false
    kH.autoRebirth = false
    kH.autoUpgrade = false
    kH.upgradeLoop = false
    pcall(function()
        connection:Disconnect()
        connection2:Disconnect()
        lJ(false)
        local q0 = ld()
        if q0 then
            q0.PlatformStand = false
            q0.WalkSpeed = 16
        end
    end)
    pcall(function()
        Library:Unload()
    end)
    ln.__tempo_cleanup = nil
end
local function fn792()
    local Character = li.Character
    local mU = Character and Character:FindFirstChild("HumanoidRootPart")
    return mU
end
local function onImportConfigFromClipboardTex()
    local qE_1
    local qC = Options.SaveManager_ImportSource.Value or ""
    local qC_1
    local qD = tostring(qC):match("^%s*(.-)%s*$")
    if qD == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    qC_1, qE_1 = pcall(HttpService.JSONDecode, HttpService, qD)
    local qD_1 = not qC_1
    local qI = if qD_1 then 1 else 0
    local qG = 2170 * qI + 3451 * (1 - qI)
    local qH = 1617 * qI + 3104 * (1 - qI)
    if not ((qG * 23 + qH * 2560 + qG * qH) % 16777213 == 7698320) then
        qD_1 = type(qE_1) ~= "table"
    end
    if not qD_1 then
        qD_1 = type(qE_1.objects) ~= "table"
    end
    if qD_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local qC_2 = 0
    for i, v in ipairs(qE_1.objects) do
        if kK(v) then
            qC_2 += 1
        end
    end
    if qC_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local qE_2 = qC_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(qC_2, qE_2), 6)
end
local function onAutoRoll(dO)
    kH.autoRoll = dO
    if dO then
        kQ("autoRoll")
    end
end
local function fn814(fI, fJ)
    local pT_1 = (fI == "Toggle" and Toggles or Options)[fJ]
    local pS_2 = type(pT_1) == "table" and pT_1.Type == fI
    return pS_2 and pT_1 or nil
end
local function fn816()
    local mW = PlayerState.PlotOwner()[ls]
    kF.plotName = mW
    kF.keycaps = {}
    if not mW then
        return
    end
    local mX = workspace:FindFirstChild("MAP") and workspace.MAP:FindFirstChild("PLOTS")
    local mY = mX
    if mX then
        mX = mY:FindFirstChild(mW)
    end
    local mW_1 = mX
    if mX then
        mX = mW_1:FindFirstChild("Keycaps")
    end
    local mW_2 = mX
    if not mW_2 then
        return
    end
    for i, child in ipairs(mW_2:GetChildren()) do
        if child:IsA("Model") then
            local BasePart = child:FindFirstChildWhichIsA("BasePart")
            if BasePart then
                table.insert(kF.keycaps, BasePart.Position)
            end
        end
    end
end
local function onCopyBitcoinAddress()
    kW(lh, "Copied Bitcoin address")
end
local function fn823()
    local ny = kF.plotName or PlayerState.PlotOwner()[ls]
    if not ny then
        return
    end
    local ny_1 = lq()
    local nA = false
    for i, v in ipairs(ny_1) do
        if v and v ~= "" then
            local ny_3 = Keycaps.Get(v)
            local nB_1 = ny_3 and ny_3.MoneyPerPress >= kF.rarityThreshold
            if nB_1 then
                local nC = le()
                nB_1 = nC >= (ny_3.Price or 0)
            end
            if nB_1 then
                ly.Unlock:fire("ClaimUnlock", i)
                nA = true
            end
        end
    end
    if not nA then
        ly.Unlock:fire("RequestRoll", ny)
    end
end
local function fn831(fQ, fR)
    local Type = fR.Type
    if Type == "Toggle" then
        return { idx = fQ, type = "Toggle", value = fR.Value == true }
    elseif Type == "Slider" then
        return { idx = fQ, type = "Slider", value = tostring(fR.Value) }
    elseif Type == "Dropdown" then
        return { idx = fQ, type = "Dropdown", multi = fR.Multi == true, value = fR.Value }
    elseif Type == "Input" then
        local p_ = fR.Value or ""
        return { idx = fQ, type = "Input", text = tostring(p_) }
    elseif Type == "ColorPicker" then
        return { idx = fQ, type = "ColorPicker", value = fR.Value:ToHex(), transparency = fR.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = fQ,
            type = "KeyPicker",
            mode = fR.Mode,
            key = fR.Value,
            modifiers = fR.Modifiers,
            toggled = fR.Toggled
        }
    else
        return nil
    end
end
local function onRscripts()
    kW(k_, "Copied Rscripts profile to clipboard")
end
local function onAutoUnlock(dU)
    kH.autoUnlock = dU
    if dU then
        kQ("autoUnlock")
    end
end
local function fn897(N, O)
    Library.NotifySide = O
    pcall(SetNotifySide, N, O)
end
local function fn916(cq)
    if not cq then
        return 1
    end
    local nW = Options[cq .. "Interval"]
    local nX = nW and type(nW.Value) == "number"
    if nX then
        return nW.Value
    end
    return lg[cq] or 1
end
local function onInputBegan()
    lN = tick()
end
local function fn970(ac, ad)
    if setclipboard then
        setclipboard(ac)
    elseif toclipboard then
        toclipboard(ac)
    end
    Library:Notify(ad)
end
local function onAutoWalk(dG)
    kH.autoWalk = dG
    if dG then
        kQ("autoWalk")
    end
end
local function fn1012()
    if #kF.keycaps == 0 then
        kO()
        if #kF.keycaps == 0 then
            return
        end
    end
    local ng = lC()
    if not ng then
        return
    end
    kF.walkIdx = kF.walkIdx % #kF.keycaps + 1
    local nh = kF.keycaps[kF.walkIdx]
    ng.CFrame = CFrame.new(nh + Vector3.new(0, 3, 0))
    ng.AssemblyLinearVelocity = Vector3.zero
    ng.AssemblyAngularVelocity = Vector3.zero
end
local function onExportConfigToClipboard()
    local qw_1
    local qv_1
    qv_1, qw_1 = pcall(HttpService.JSONEncode, HttpService, lv())
    if not qv_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local qv_2 = setclipboard
    local qB = if qv_2 then 1 else 0
    local qz = 523 * qB + 2825 * (1 - qB)
    local qA = 3708 * qB + 3413 * (1 - qB)
    if not ((qz * 3615 + qA * 1311 + qz * qA) % 16777213 == 8691117) then
        qv_2 = toclipboard
    end
    local qx = qv_2
    local qv_3 = type(qx) ~= "function" or not pcall(qx, qw_1)
    if qv_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function worker()
    local ob_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local oa = math.floor(os.clock() - k4)
        if oa < 60 then
            ob_1 = oa .. "s"
        elseif oa < 3600 then
            ob_1 = string.format("%dm %ds", math.floor((oa) / (60)), oa % 60)
        else
            ob_1 = string.format("%dh %dm", math.floor((oa) / (3600)), math.floor((oa % 3600) / (60)))
        end
        Label:SetText(lL("Session time", ob_1, lt))
    end
end
kE = nil
kF = nil
kG = nil
kH = nil
kI = nil
Library = nil
kK = nil
ZonesConfig = nil
kN = nil
kO = nil
RebirthConfig = nil
kQ = nil
WorkersConfig = nil
local kS
connection2 = nil
UpgradesConfig = nil
GridLayout = nil
kW = nil
kX = nil
kY = nil
Keycaps = nil
k_ = nil
k0 = nil
PlayerState = nil
k2 = nil
k3 = nil
k4 = nil
Options = nil
k7 = nil
connection = nil
k9 = nil
Toggles = nil
lc = nil
ld = nil
le = nil
lf = nil
lg = nil
lh = nil
li = nil
__tempo_gen = nil
ll = nil
LocalPlayer = nil
ln = nil
lo = nil
lq = nil
Workspace = nil
local kL, k6, lb, lk
ls = nil
lt = nil
lu = nil
lv = nil
lx = nil
ly = nil
Label = nil
lA = nil
lC = nil
HttpService = nil
VirtualUser = nil
lF = nil
UserInputService = nil
lH = nil
SetNotifySide = nil
lJ = nil
lK = nil
lL = nil
lM = nil
lN = nil
local CoreGui, GuiService, lQ, l0
local mh, GameInfoGroup, MachineGroup, FlyGroup
UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, LocalPlayer, li, PlayerState, Keycaps, GridLayout, UpgradesConfig, WorkersConfig, RebirthConfig, ZonesConfig, Library, kG = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local lO = game:GetService("Players")
local lR = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
LocalPlayer = lO.LocalPlayer
li = LocalPlayer
local lW = "Press a Keycap!"
local lT = require(lR.Packages.Networker).client
local lS = require(lR.Shared.Modules.Atoms.AtomKey)
PlayerState = require(lR.Shared.Modules.Atoms.PlayerState)
Keycaps = require(lR.Shared.Modules.Keycaps.Keycaps)
GridLayout = require(lR.Shared.Modules.Keycaps.GridLayout)
UpgradesConfig = require(lR.Shared.Modules.Config.UpgradesConfig)
WorkersConfig = require(lR.Shared.Modules.Config.WorkersConfig)
RebirthConfig = require(lR.Shared.Modules.Config.RebirthConfig)
ZonesConfig = require(lR.Shared.Modules.Config.ZonesConfig)
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
kG = getgenv().SaveManager
pcall(fn162)
SetNotifySide = nil
SetNotifySide = Library.SetNotifySide
Library.SetNotifySide = fn897
if setthreadidentity then
    setthreadidentity(8)
end
ly, ls, ln = nil, nil, nil
ly = {
    Workers = lT.new("Workers", {}),
    Upgrades = lT.new("Upgrades", {}),
    Rebirth = lT.new("Rebirth", {}),
    Unlock = lT.new("Unlock", {}),
    Zones = lT.new("Zones", {})
}
ls = lS.For(li)
ln = getgenv()
lO = ln.__tempo_gen or 0
__tempo_gen, lQ = nil, nil
local lP = 3
repeat
    lR = (lP * 1 + 1) % 2 + 1
    if lR <= 1 then
        local rW = bit32.rrotate(bit32.bxor(bit32.lrotate(lP, 9), string.byte(tostring(lQ))), 27)
        if bit32.bxor(bit32.lrotate(bit32.bxor(rW, 3840334415), 2), 2476435775) == bit32.lrotate(rW, 2) then
            ln.__tempo_gen = lO + 1
            __tempo_gen = ln.__tempo_gen
        else
            ln.__tempo_gen = __tempo_gen + 1
            ln = lO.__tempo_gen
        end
        lP = (lP + 5) % 8
    else
        lR = {
            "kmoxjkpldhmz",
            "qsol",
            "zuamti",
            "tksnufrjjnjd",
            "epmcbgasnny",
            "ffm",
            "klkamaj",
            "zgpgydrwnmf",
            "lixmyr"
        }
        if lR[(lP * 48 + 61) % 9 + 1] <= lR[(lP * 48 + 61) % 9 + 1] then
            lQ = ln.__tempo_cleanup
        else
            ln = lQ.__tempo_cleanup
        end
        lP = (lP + 7) % 8
    end
until (lP * 7 + 7) % 8 == 0
if type(lQ) == "function" then
    lO = 2
    repeat
        lP = (vector.create((lO * 3 + 9) % 11 + 1, (lO * 10 + 5) % 13 + 1, (lO * 4 + 14) % 17 + 1))
        lR = (vector.create((lO * 1 + 2) % 11 + 1, (lO * 1 + 10) % 13 + 1, (lO * 9 + 9) % 17 + 1))
        lS = (vector.create((lO * 4 + 1) % 5 + 1, (lO * 1 + 5) % 7 + 1, (lO * 5 + 5) % 9 + 1))
        if math.abs((vector.angle(lP, lR, lS))) - math.abs((vector.angle(lR, lP, lS))) == 3 then
            pcall(ln)
            lQ.__tempo_cleanup = nil
        else
            pcall(lQ)
            ln.__tempo_cleanup = nil
        end
        lO = (lO + 5) % 8
    until (lO * 5 + 0) % 8 == 3
end
Toggles, Options, k2, k_, mh, lt, ll, lh, lc, k7, k3, k0, kX, kH, kF, lH, lk, lg, lb, kE, Label, lu, kW, kN, kI, lL, lM, lC, ld, kY, kO, lq, le, lT, k6, kQ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Toggles = Library.Toggles
Options = Library.Options
k2 = "https://discord.gg/K7Qxnxkk46"
k_ = "https://discord.gg/K7Qxnxkk46"
kW = fn970
kN = fn180
kI = fn656
lL = fn303
local mi = "#7fd47f"
if ((le and lT or le and not le) and ((not le or not le) and (lT and lT)) or (le and not lT or not le and le or lT and le and (not le or lT))) and not ((le and lT or le and not le) and ((not le or not le) and (lT and lT)) or (le and not lT or not le and le or lT and le and (not le or lT))) then
else
    mh = "#6ec1ff"
end
lt = "#e8a34d"
local mg = "#8b93a3"
ll = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
lh = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
lc = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
k7 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
k3 = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
k0 = ""
kX = ""
local md = "#345d9d"
local mb = "#f7931a"
local l9 = "#627eea"
local l7 = "#26a17b"
local l6 = "#14f195"
local l5 = "#0070ba"
local l4 = "#008cff"
kH = {
    autoWalk = false,
    autoWorkers = false,
    autoRoll = false,
    autoBuy = false,
    autoUnlock = false,
    autoRebirth = false,
    autoUpgrade = false,
    upgradeLoop = false
}
kF = { plotName = nil, keycaps = {}, walkIdx = 0, rarityThreshold = 0 }
lM = fn118
lC = fn271
ld = fn762
kY = fn792
kO = fn816
lq = fn755
le = fn79
local lY = fn1012
lS = fn245
local l_ = fn185
local lZ = fn246
local l2 = fn823
lT = fn226
lH = {
    PlayerSpeed = false,
    WorkersSpeed = false,
    MoneyMultiplier = false,
    RollSpeed = false,
    LuckMultiplier = false,
    RollAmount = false
}
local l1 = fn619
lk = {
    autoWalk = lY,
    autoWorkers = lS,
    autoRoll = l_,
    autoBuy = l2,
    autoUnlock = lZ,
    autoRebirth = lT,
    upgradeLoop = l1
}
lg = {
    autoWalk = 0.5,
    autoWorkers = 3,
    autoRoll = 2,
    autoBuy = 1.5,
    autoUnlock = 1.5,
    autoRebirth = 6,
    upgradeLoop = 3
}
lb = {}
k6 = fn916
kQ = function(cw)
    if not cw then
        return
    end
    if lb[cw] then
        return
    end
    lb[cw] = task.spawn(function()
        local n__1
        setthreadidentity(8)
        while true do
            local nZ = not Library.Unloaded and ln.__tempo_gen == __tempo_gen
            local nZ_1
            if nZ then
                if kH[cw] then
                    nZ_1, n__1 = pcall(lk[cw])
                    if not nZ_1 then
                        warn("[Tempo] " .. cw .. ": " .. tostring(n__1))
                    end
                end
                local nZ_2 = k6(cw)
                task.wait(nZ_2)
                continue
            end
            break
        end
        lb[cw] = nil
    end)
end
local lX = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = k2, Copyable = true }, "|", lW },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
local mf = {
    Info = lX:AddTab("Info", "info"),
    Farming = lX:AddTab("Farming", "zap"),
    Inventory = lX:AddTab("Inventory", "package"),
    Rebirth = lX:AddTab("Rebirth", "rotate-ccw"),
    Player = lX:AddTab("Player", "person-standing"),
    Settings = lX:AddTab("Settings", "settings")
}
local me = mf.Farming:AddSubTab("Income", "dollar-sign")
local mc = mf.Farming:AddSubTab("Workers", "hard-hat")
local ma = mf.Inventory:AddSubTab("Rolling", "dices")
local l8 = mf.Inventory:AddSubTab("Upgrades", "trending-up")
do
    lR = fn126
    lR(mf.Info)
    lR(mf.Rebirth)
    lR(mf.Player)
    lR(mf.Settings)
    lR(me)
    lR(mc)
    lR(ma)
    lR(l8)
    kE = "Unknown"
    pcall(fn150)
    l0 = mf.Info:AddLeftGroupbox("Account", "circle-user")
    l0:AddLabel(lL("User", LocalPlayer.Name, mi), true)
    l0:AddLabel(lL("Status", "Keyless", mi), true)
    l0:AddLabel(lL("Executor", kE, mi), true)
    GameInfoGroup = mf.Info:AddLeftGroupbox("Game Info", "gamepad-2")
    GameInfoGroup:AddLabel(kI(lW .. " [" .. tostring(game.PlaceId) .. "]", mh), true)
    GameInfoGroup:AddLabel(lL("Place ID", tostring(game.PlaceId), mh), true)
    Label = GameInfoGroup:AddLabel(lL("Session time", "0s", lt), true)
end
lu = tostring(game.JobId)
local l3 = #lu > 18
if l3 then
    lO = 1
    repeat
        if (not lO and lO or not lO and not lO or (not lO and not lO or not lO and lO)) and ((lO or lO) and (lO and lO) or (not lO or lO or lO and lO)) or not ((not lO and lO or not lO and not lO or (not lO and not lO or not lO and lO)) and ((lO or lO) and (lO and lO) or (not lO or lO or lO and lO))) then
            l3 = string.sub(lu, 1, 18) .. "..."
        else
            lu = string.sub(l3, 1, 18) .. "..."
        end
        lO = (lO + 1) % 8
    until (lO * 5 + 1) % 8 == 3
end
lO = l3 or lu
k4, l0, MachineGroup, lf, k9, lx, FlyGroup, lo, lN, lK, connection, connection2, lZ, lJ, lA, kL, lF, lv, kK, kS = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
l1 = lO
GameInfoGroup:AddLabel(lL("Server", l1, mg), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
k4 = os.clock()
task.spawn(worker)
lX = mf.Info:AddRightGroupbox("Scripts", "package")
lX:AddLabel(kI("Included in this hub", mg), true)
lX:AddLabel(kI(lW, mh), true)
lS = mf.Info:AddRightGroupbox("Features", "list")
lS:AddLabel(kI("Auto Income", mh), true)
lS:AddLabel(kI("Auto Rolling and Upgrades", lt), true)
lS:AddLabel(kI("Auto Rebirth", mi), true)
lR = mf.Info:AddRightGroupbox("Socials", "link")
lR:AddButton({ Text = "Discord", Func = kN })
lR:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = mf.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = kN })
local DonationsGroup = mf.Info:AddRightGroupbox("Donations", "heart")
if ((lo or not lo) and (not lZ and not lS) and ((lZ or lS) and (not lZ or not lS)) or (not lS or not lS or (not lo or not lS)) and ((lo or lZ) and (lS or lS))) and ((MachineGroup and lZ or not MachineGroup and lS) and (MachineGroup or not lo or (not lZ or FlyGroup)) and (lo and not MachineGroup or (MachineGroup or not MachineGroup) or (not FlyGroup and not lo or MachineGroup and not lS))) or not (((lo or not lo) and (not lZ and not lS) and ((lZ or lS) and (not lZ or not lS)) or (not lS or not lS or (not lo or not lS)) and ((lo or lZ) and (lS or lS))) and ((MachineGroup and lZ or not MachineGroup and lS) and (MachineGroup or not lo or (not lZ or FlyGroup)) and (lo and not MachineGroup or (MachineGroup or not MachineGroup) or (not FlyGroup and not lo or MachineGroup and not lS)))) then
    DonationsGroup:AddLabel(kI("All donations are optional but appreciated.", lt), true)
    DonationsGroup:AddLabel(kI("If you donate you get a special role, just PING after you donate.", mi), true)
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(kI("LTC / Litecoin", md), true)
    DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
    DonationsGroup:AddLabel(kI("BTC / Bitcoin", mb), true)
    DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
    DonationsGroup:AddLabel(kI("ETH / Ethereum", l9), true)
    DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
    DonationsGroup:AddLabel(kI("USDT", l7), true)
    DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
    DonationsGroup:AddLabel(kI("Solana", l6), true)
    DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
    DonationsGroup:AddLabel(kI("PayPal", l5), true)
    DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
    DonationsGroup:AddLabel(kI("Venmo", l4), true)
    DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(kI("Don't have any of the listed currencies but still wanna donate?", mg), true)
    DonationsGroup:AddLabel(kI("DM me and we'll work something out.", mh), true)
    l0 = mf.Info:AddRightGroupbox("FAQ", "circle-help")
else
    mf:AddLabel(l6("All donations are optional but appreciated.", l7), true)
    mf:AddLabel(l6("If you donate you get a special role, just PING after you donate.", l9), true)
    mf:AddDivider()
    mf:AddLabel(l6("LTC / Litecoin", mi), true)
    mf:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
    mf:AddLabel(l6("BTC / Bitcoin", l5), true)
    mf:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
    mf:AddLabel(l6("ETH / Ethereum", lt), true)
    mf:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
    mf:AddLabel(l6("USDT", kI), true)
    mf:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
    mf:AddLabel(l6("Solana", l0), true)
    mf:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
    mf:AddLabel(l6("PayPal", mh), true)
    mf:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
    mf:AddLabel(l6("Venmo", mg), true)
    mf:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
    mf:AddDivider()
    mf:AddLabel(l6("Don't have any of the listed currencies but still wanna donate?", DonationsGroup), true)
    mf:AddLabel(l6("DM me and we'll work something out.", md), true);
    (nil):AddRightGroupbox("FAQ", "circle-help")
end
l0:AddLabel("Where do I get a good config?", true)
l0:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
l0:AddLabel("How do I import / export configs?", true)
l0:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
l0:AddLabel("How do I report bugs?", true)
l0:AddLabel("Join the Discord and post it in the bugs channel.", true)
l0:AddLabel("How do I make suggestions?", true)
l0:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
l0:AddLabel("How do I get help or updates?", true)
l0:AddLabel("Join the Discord, updates and support are posted there first.", true)
l_ = me:AddLeftGroupbox("Keycap Walking", "footprints")
l_:AddToggle("autoWalk", { Text = "Auto Walk Keycaps", Default = false, Callback = onAutoWalk })
l_:AddSlider("autoWalkInterval", { Text = "Interval", Default = 0.5, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
lT = mc:AddLeftGroupbox("Hiring", "users")
lT:AddToggle("autoWorkers", { Text = "Auto Buy Workers", Default = false, Callback = onAutoWorkers })
lT:AddSlider("autoWorkersInterval", { Text = "Interval", Default = 3, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
MachineGroup = ma:AddLeftGroupbox("Machine", "gauge")
MachineGroup:AddToggle("autoRoll", { Text = "Auto Roll Keycaps", Default = false, Callback = onAutoRoll })
MachineGroup:AddSlider("autoRollInterval", { Text = "Interval", Default = 2, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
MachineGroup:AddToggle("autoBuy", { Text = "Auto Buy Keycaps (rarity)", Default = false, Callback = onAutoBuy })
MachineGroup:AddSlider("autoBuyInterval", { Text = "Interval", Default = 1.5, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
MachineGroup:AddToggle("autoUnlock", { Text = "Auto Unlock Keypads", Default = false, Callback = onAutoUnlock })
MachineGroup:AddSlider("autoUnlockInterval", { Text = "Interval", Default = 1.5, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
lf = { "Any" }
k9 = { 0 }
pcall(fn740)
MachineGroup:AddDropdown("rarityThreshold", { Text = "Minimum rarity", Values = lf, Default = "Any", Callback = onRarityThreshold })
l3 = l8:AddLeftGroupbox("Stat Upgrades", "wrench")
l2 = {
    "Player Speed",
    "Workers Speed",
    "Money Multiplier",
    "Roll Speed",
    "Luck Multiplier",
    "Roll Amount"
}
lx = {
    ["Player Speed"] = "PlayerSpeed",
    ["Workers Speed"] = "WorkersSpeed",
    ["Money Multiplier"] = "MoneyMultiplier",
    ["Roll Speed"] = "RollSpeed",
    ["Luck Multiplier"] = "LuckMultiplier",
    ["Roll Amount"] = "RollAmount"
}
l3:AddToggle("autoUpgrade", { Text = "Auto Upgrade", Default = false, Callback = onAutoUpgrade })
l3:AddDropdown("upgradeSel", { Text = "Select Upgrades", Values = l2, Multi = true, Default = {}, Callback = onUpgradeSel })
l3:AddSlider("upgradeLoopInterval", { Text = "Upgrade interval", Default = 3, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
lY = mf.Rebirth:AddLeftGroupbox("Rebirth", "refresh-cw")
lY:AddToggle("autoRebirth", { Text = "Auto Rebirth", Default = false, Callback = fns.onAutoRebirth })
lY:AddSlider("autoRebirthInterval", { Text = "Interval", Default = 6, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
lP = mf.Player:AddLeftGroupbox("Movement", "footprints")
lP:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
lP:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
lP:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
lP:AddToggle("NoClip", { Text = "NoClip", Default = false })
lP:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
FlyGroup = mf.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
lJ = function(eC)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not eC)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not eC
        end
    end)
    if not eC then
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
Toggles.AntiGameplayPause:OnChanged(fn575)
Toggles.Fly:OnChanged(fn169)
Toggles.WalkSpeedEnabled:OnChanged(fn690)
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
lo = Workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
lQ = mf.Settings:AddLeftGroupbox("Menu")
lQ:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
lN = tick()
lK = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local pM = v
        pcall(function()
            pM:Disable()
        end)
    end
end)
lA = fn140
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
lQ:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
lQ:AddButton({ Text = "Unload", Func = onUnload })
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(mf.Settings)
ThemeManager:LoadDefault()
kG:SetLibrary(Library)
kG:IgnoreThemeSettings()
kG:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
kG:SetFolder("TempoHub/PressAKeycap")
lZ = kG:BuildConfigSection(mf.Settings)
kL = fn814
lF = fn831
lv = fn522
kK = function(f6)
    local qp
    qp = nil
    local qq = type(f6) ~= "table" or type(f6.idx) ~= "string"
    local qu = if qq then 1 else 0
    local qs = 543 * qu + 3891 * (1 - qu)
    local qt = 1605 * qu + 2943 * (1 - qu)
    if not ((qs * 2170 + qt * 3224 + qs * qt) % 16777213 == 7224345) then
        qq = type(f6.type) ~= "string"
    end
    if not qq then
        qq = kG.Ignore[f6.idx]
    end
    if qq then
        return false
    end
    qp = kL(f6.type, f6.idx)
    if not qp then
        return false
    end
    local qq_1 = pcall(function()
        if f6.type == "Input" then
            if type(f6.text) ~= "string" then
                return
            end
            qp:SetValue(f6.text)
        elseif f6.type == "ColorPicker" then
            qp:SetValueRGB(Color3.fromHex(f6.value), f6.transparency)
        elseif f6.type == "KeyPicker" then
            qp:SetValue({ f6.key, f6.mode, f6.modifiers })
            if f6.mode == "Toggle" and f6.toggled ~= nil then
                qp.Toggled = f6.toggled
                qp:Update()
            end
        else
            qp:SetValue(f6.value)
        end
    end)
    return qq_1
end
if (not lv or lT or not lT and l2) and (not l2 and l2 or (not l2 or lT)) and not ((not lv or lT or not lT and l2) and (not l2 and l2 or (not l2 or lT))) then
    kS:AddDivider()
    kS:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", AllowEmpty = true, Finished = true })
    kS:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    kS:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
    lZ:LoadAutoloadConfig()
    task.spawn(fns.antiGameplayPauseLoop)
    task.spawn(antiAfkLoop)
    kG = fn764
else
    lZ:AddDivider()
    lZ:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    lZ:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    lZ:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
    kG:LoadAutoloadConfig()
    task.spawn(fns.antiGameplayPauseLoop)
    task.spawn(antiAfkLoop)
    kS = fn764
end
ln.__tempo_cleanup = kS
Library:OnUnload(fn687)
if STATE then
    STATE.onCleanup(function()
        kS()
    end)
end
kO()
Library:Notify("Press a Keycap! loaded")
end)(...)

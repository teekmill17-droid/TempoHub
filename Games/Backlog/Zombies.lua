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
getgenv().TempoHoodSubtitle = "ZOMBIES"
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
local ScriptsGroup, xF_3, MovementGroup, xF_25, SilentAimGroup, SocialsGroup, GearUpgradesGroup, xF_39, WeaponModsGroup
local pu
local loadoutStore
local pb
local n8
local WeaponController
local pA
local oA
local ph
local connection2
local oZ
local pG
local Options
local pn
local ol
local o4
local pM
local oM
local folder
local Label2
local Client
local connection3
local oS
local connection4
local _canShoot
local pg
local od
local Constants
local UserInputService
local ViewModelController
local pm
local Label4
local Shared
local pL
local connection6
local ps
local PlayReload
local o9
local AmmoBox
local oR
local Blink
local appStore
local pf
local oc
local connection7
local pE
local oE
local pl
local oi
local o2
local pK
local oK
local Workspace
local LightweightNpcsClientModule
local o8
local oQ
local px
local connection
local pe
local MysteryBox
local oW
local weaponUpgrades
local oD
local pk
local Melee
local o1
local pJ
local pq
local Label3
local o7
local pP
local MeleeController
local CollectionService
local ow
local CameraMinZoomDistance
local oa
local oV
local VirtualUser
local DropController
local pj
local o0
local Tags
local oI
local connection5
local on
local o6
local pO
local oO
local pv
local _startShootLoop
local pc
local Label
local oU
local pB
local oB
local CameraMode
local of
local o_
local oH
local po
local om
local Library
local ReplicatedStorage
local Toggles
function fns.fn4(fk)
    local t0_1
    local t__1
    local tZ = pK()
    if not tZ then
        return nil
    end
    t0_1, t__1 = nil, math.huge
    for k, v in CollectionService:GetTagged(fk) do
        local t1 = v:IsA("Model") and v.Parent
        if t1 then
            local Magnitude = (v:GetPivot().Position - tZ.Position).Magnitude
            if Magnitude < t__1 then
                t0_1, t__1 = v, Magnitude
            end
        end
    end
    return t0_1
end
function fns.fn26(hh)
    local u1 = po[hh]
    if not u1 then
        return
    end
    u1.highlight:Destroy()
    u1.billboard:Destroy()
    po[hh] = nil
end
function fns.worker4()
    while not Library.Unloaded do
        task.wait(oI("AreaDelay", 3))
        if not o2("AutoBuyArea") then
            continue
        end
        local Actions = Workspace:FindFirstChild("Actions")
        local wO = Actions and Actions:FindFirstChild("Barriers")
        if not wO then
            continue
        end
        local wO_1 = oI("AreaReserve", 0)
        for i, child in wO:GetChildren() do
            local ProximityPrompt = child:FindFirstChildWhichIsA("ProximityPrompt")
            if ProximityPrompt then
                local wP = child:GetAttribute("Cost") or ow(ProximityPrompt, 0)
                local wP_1 = o8() - wP >= wO_1 and pL(ProximityPrompt)
                if wP_1 then
                    task.wait(0.5)
                end
            end
        end
    end
end
function fns.fn54(b7, b8, b9)
    local sd = b9 - b7
    local Magnitude = sd.Magnitude
    if Magnitude < 1 then
        return false
    end
    local sf = pO(pk, b7, { sd.Unit * (Magnitude + 4) }, 0.5)[1]
    return sf ~= nil and sf.taggedZombie == b8
end
function fns.fn69(eA, eB, eC, eD, eE)
    local tC = oU(eA, eB, eC, eD, eE)
    if not o2("Wallbang") then
        return tC
    end
    local tD = px(eB, eC)
    if tD then
        return { hits = { tD }, hitWall = false, endpoint = tD.position }
    end
    return tC
end
function fns.worker6()
    while not Library.Unloaded do
        task.wait(0.1)
        if not o2("InstantCollect") then
            continue
        end
        local wl = pq()
        local wm = pK()
        if not wl or not wm then
            continue
        end
        local wn_1 = oi("CollectKinds")
        local wo_1 = oI("CollectRange", 40)
        for k, v in wl do
            local wl_1 = false
            for k, v2 in pB do
                if wn_1[k] and v.kind == v2 then
                    wl_1 = true
                    break
                end
            end
            if wl_1 and v.model and v.model.Parent then
                if (v.base - wm.Position).Magnitude <= wo_1 then
                    v.magnetStart = os.clock()
                    v.pos = wm.Position
                    v.model:PivotTo(CFrame.new(wm.Position))
                end
            end
        end
    end
end
function fns.fn81(e6, e7, e8, e9)
    if not o2("InstantReload") then
        return PlayReload(e6, e7, e8, e9)
    end
    e8()
    e9()
end
function fns.onRscripts()
    oD(pf, "Copied Rscripts profile to clipboard")
end
function fns.onInputBegan()
    pj = tick()
end
function fns.fn111(fc, fd, fe, ff)
    if not o2("InstantReload") then
        return on(fc, fd, fe, ff)
    end
    local tW = 1
    while tW <= fd do
        fe()
        tW += 1
    end
    ff()
end
function fns.fn143(aT, aU)
    local match = string.match
    local rg = aT.ObjectText or ""
    local rh = match(rg, "%d+")
    local rf_1 = tonumber(rh) or aU
    return rf_1
end
function fns.worker()
    while not Library.Unloaded do
        task.wait(2)
        if o2("AntiAfk") then
            local xq = tick() - pj
            local xr = tick() - pe
            if xq >= 300 and xr >= 60 then
                pcall(oS)
            else
                if xq < 300 and xr >= 300 then
                    pcall(oS)
                end
            end
        end
    end
end
function fns.fn168()
    local Character = pk.Character
    local q_ = Character and Character:FindFirstChild("HumanoidRootPart")
    return q_
end
function fns.fn185()
    local ud_1
    local uc_1
    if identifyexecutor then
        ud_1, uc_1 = identifyexecutor()
        local ue = ud_1 ~= ""
        local uf = type(ud_1) == "string" and ue
        if uf then
            local ue_1 = type(uc_1) == "string" and uc_1 ~= "" and ud_1 .. " " .. uc_1
            oA = ue_1 or ud_1
        end
    end
end
function fns.fn201()
    if not Toggles.WalkSpeedEnabled.Value then
        local v5 = pu()
        if v5 then
            v5.WalkSpeed = 16
        end
    end
end
function fns.onHeartbeat()
    if Library.Unloaded then
        return
    end
    local uC = math.rad(oI("SilentFov", 60) / 2)
    if o2("SilentAim") then
        if not of(pm, uC) then
            pm = oE(uC)
        end
    else
        pm = nil
    end
    if not o2("KillAura") then
        ps = nil
        oH(nil)
        return
    end
    local uH = if not of(ps, nil) then 1 else 0
    if uH == 1 then
        ps = oE(nil, true)
    end
    if not ps then
        oH(nil)
        return
    end
    if o_ ~= ps.model then
        oH(ps.model)
    end
    local attr = ps.model:GetAttribute("Hp")
    local uD = typeof(attr) == "number" and typeof(oW) == "number" and attr < oW
    if uD then
        oW = attr
        oQ = 0
        oO = nil
    elseif attr ~= oW then
        oW = attr
        oQ = 0
        oO = nil
    end
    local uC_2 = oQ >= pg and oO and os.clock() - oO >= pb
    if uC_2 then
        o1[ps.model] = os.clock() + o6
        ps = oE(nil, true)
        local uD_1 = ps and ps.model or nil
        oH(uD_1)
        if not ps then
            return
        end
    end
    if WeaponController._holstered or not WeaponController._weaponName then
        return
    end
    if WeaponController:_canShoot() then
        WeaponController:_shoot()
        if o_ == ps.model then
            oQ += 1
            local uC_5 = oO or os.clock()
            oO = uC_5
        end
    else
        local uC_6 = o2("AuraAutoReload") and WeaponController._ammo <= 0 and not WeaponController._reloading
        if uC_6 then
            WeaponController:Reload()
        end
    end
end
function fns.fn234(fx)
    local DiscordGroup = fx:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = om })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = om })
end
function fns.fn284()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    pe = tick()
end
function fns.fn360(aa, ab)
    return string.format('<font color="%s">%s</font>', ab, aa)
end
function fns.fn391(dp, dq)
    local sV
    local sW = o2("KillAura") and ps and ps.model.Parent
    if sW then
        sV = ps
    else
        local sW_1 = o2("SilentAim") and pm and pm.model.Parent
        if sW_1 then
            sV = pm
        end
    end
    if sV then
        local sW_2 = o4(sV.model)
        local Position = dq.Position
        if (sW_2 - Position).Magnitude > 1 then
            return CFrame.lookAt(Position, sW_2, dq.UpVector)
        end
        return pA(dp, dq)
    end
    return pA(dp, dq)
end
function fns.fn392(eT)
    local tH_1
    local tG_1
    if not o2("RapidFire") then
        return _canShoot(eT)
    end
    local _lastShotTime = eT._lastShotTime
    local tL = if os.clock() - _lastShotTime < oI("RapidFireDelay", 0.05) then 1 else 0
    if tL == 1 then
        return false
    end
    eT._lastShotTime = -math.huge
    tG_1, tH_1 = pcall(_canShoot, eT)
    eT._lastShotTime = _lastShotTime
    if not tG_1 then
        error(tH_1, 0)
    end
    return tH_1
end
function fns.onInputChanged(gq)
    local UserInputType = gq.UserInputType
    local ux = UserInputType == Enum.UserInputType.MouseMovement
    local uB = if ux then 1 else 0
    local uz = 1141 * uB + 292 * (1 - uB)
    local uA = 2134 * uB + 1445 * (1 - uB)
    if not ((uz * 638 + uA * 3711 + uz * uA) % 16777213 == 11082126) then
        ux = UserInputType == Enum.UserInputType.Gamepad1
    end
    if ux then
        pj = tick()
    end
end
function fns.worker7()
    while not Library.Unloaded do
        task.wait(0.25)
        local wh = ps or pm
        local wi = wh
        if wh then
            wh = wi.model.Name
        end
        local wj = wh or "None"
        local wi_1 = wi and pn or o7
        Label2:SetText(pJ("Target", wj, wi_1))
        local format = string.format
        local wi_2 = WeaponController._ammo or 0
        local wj_1 = WeaponController._reserve or 0
        Label3:SetText(pJ("Ammo", format("%d / %d", wi_2, wj_1), pc))
        Label4:SetText(pJ("Points", tostring(o8()), pn))
    end
end
function fns.worker3()
    while not Library.Unloaded do
        task.wait(0.5)
        if not o2("AutoBuyAmmo") then
            continue
        end
        local wY = WeaponController._reserve or 0
        if wY > oI("AmmoThreshold", 60) then
            continue
        end
        local _weaponName = WeaponController._weaponName
        local wZ = oi("AmmoSources")
        local w_ = oI("AmmoPointsReserve", 0)
        local w0 = false
        if wZ["Wall Weapon"] and _weaponName then
            local Actions = Workspace:FindFirstChild("Actions")
            local w2 = Actions and Actions:FindFirstChild("Wall Weapons")
            if w2 then
                for i, child in w2:GetChildren() do
                    local ProximityPrompt = child:FindFirstChildWhichIsA("ProximityPrompt")
                    local w2_1 = ProximityPrompt and child:GetAttribute("Gun") == _weaponName and string.find(ProximityPrompt.ActionText, "Ammo")
                    if w2_1 then
                        if o8() - ow(ProximityPrompt, 0) >= w_ then
                            w0 = pL(ProximityPrompt, true)
                            if w0 then
                                task.wait(0.5)
                                break
                            end
                        end
                    end
                end
            end
        end
        local w1_4 = (WeaponController._ammo or 0) <= 0
        if w1_4 then
            w1_4 = (WeaponController._reserve or 0) <= 0
        end
        local wY_4 = w1_4
        local w1_5 = not o2("AmmoBoxOnlyEmpty") or wY_4
        local wY_5 = not w0
        if wY_5 then
            wY_5 = wZ["Ammo Box"]
        end
        if wY_5 and w1_5 then
            local wY_6 = od(AmmoBox.ModelTag)
            local wZ_2 = wY_6 and wY_6:GetAttribute("State") == "Idle"
            if wZ_2 then
                local AmmoBoxPrompt = wY_6:FindFirstChild("AmmoBoxPrompt", true)
                local wY_7 = AmmoBoxPrompt and AmmoBoxPrompt:IsA("ProximityPrompt")
                if wY_7 then
                    local xc = if o8() - ow(AmmoBoxPrompt, AmmoBox.DefaultCost) >= w_ then 1 else 0
                    if xc == 1 then
                        pL(AmmoBoxPrompt, true)
                        task.wait(1)
                    end
                end
            end
        end
    end
end
function fns.fn451(ax)
    local qV = Options[ax]
    return qV and qV.Value or {}
end
function fns.fn486(cr)
    o_ = cr
    local sh = cr and cr:GetAttribute("Hp")
    oW = sh or nil
    oQ = 0
    oO = nil
end
function fns.worker8()
    local wf_1
    while not Library.Unloaded do
        task.wait(1)
        local we = math.floor(os.clock() - pP)
        if we < 60 then
            wf_1 = we .. "s"
        elseif we < 3600 then
            wf_1 = string.format("%dm %ds", math.floor((we) / (60)), we % 60)
        else
            wf_1 = string.format("%dh %dm", math.floor((we) / (3600)), math.floor((we % 3600) / (60)))
        end
        Label:SetText(pJ("Session time", wf_1, pc))
    end
end
function fns.fn507(am)
    local qP = Toggles[am]
    return qP ~= nil and qP.Value == true
end
local function fn559(ho)
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = ho
    highlight.Parent = folder
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.fromOffset(200, 40)
    billboardGui.StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.MaxDistance = math.huge
    local va = ho:FindFirstChild("Head") or ho.PrimaryPart or ho:FindFirstChildWhichIsA("BasePart")
    billboardGui.Adornee = va
    billboardGui.Parent = folder
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 13
    textLabel.TextStrokeTransparency = 0.4
    textLabel.RichText = true
    textLabel.Parent = billboardGui
    local vb = { highlight = highlight, billboard = billboardGui, label = textLabel }
    po[ho] = vb
    return vb
end
local function fn577(en, eo, ep, eq, er)
    local tt = oZ(en, eo, ep, eq, er)
    if not o2("Wallbang") then
        return tt
    end
    for k, v in ep do
        local tu = px(eo, v)
        if tu then
            tt[k] = tu
        end
    end
    return tt
end
local function fn590(ee, ef)
    local tq = oa(ee, ef)
    if not tq then
        return nil
    end
    local tr = oM(tq)
    if not tr then
        return nil
    end
    return {
        position = tr.Position,
        normal = -ef.Unit,
        instance = tr,
        hitBlock = false,
        taggedZombie = tq,
        isHead = tr.Name == "Head"
    }
end
local function fn595(T, U)
    if setclipboard then
        setclipboard(T)
    elseif toclipboard then
        toclipboard(T)
    end
    Library:Notify(U)
end
local function fn644(aQ)
    local rd = aQ.Parent
    while rd do
        if rd:IsA("Attachment") then
            return rd.WorldPosition
        end
        if rd:IsA("BasePart") then
            return rd.Position
        end
        if rd:IsA("Model") then
            return rd:GetPivot().Position
        end
        rd = rd.Parent
    end
    return nil
end
local function fn653()
    local s0 = o2("KillAura") and ps and pG(ps.model)
    if s0 then
        return ps.model
    end
    local s0_1 = o2("SilentAim") and pm and pG(pm.model)
    if s0_1 then
        return pm.model
    end
    return nil
end
local function fn667()
    if not Toggles.ThirdPerson.Value then
        pk.CameraMinZoomDistance = CameraMinZoomDistance
        pk.CameraMode = CameraMode
    end
end
local function fn668()
    local Character = pk.Character
    local q2 = Character and Character:FindFirstChildOfClass("Humanoid")
    return q2
end
local function worker5()
    while not Library.Unloaded do
        task.wait(0.3)
        local wM = if not o2("AutoMysteryBox") then 1 else 0
        if wM == 1 then
            continue
        end
        local wD = od(MysteryBox.ModelTag)
        if not wD then
            continue
        end
        local MysteryBoxPrompt = wD:FindFirstChild("MysteryBoxPrompt", true)
        local wF = not MysteryBoxPrompt or not MysteryBoxPrompt:IsA("ProximityPrompt")
        if wF then
            continue
        end
        local attr2 = wD:GetAttribute("State")
        local wG = wD:GetAttribute("UserId") == pk.UserId
        if attr2 == "Grab" and wG then
            local attr = wD:GetAttribute("RollWeapon")
            local wD_1 = oi("BoxWeapons")
            local wH_1 = attr ~= ""
            local wI = typeof(attr) == "string" and wH_1
            if wI then
                local wH_2 = wD_1[attr] == true
                local wD_2 = wH_2 or o2("BoxTakeAny")
                if wD_2 then
                    pL(MysteryBoxPrompt)
                    local wD_3 = wH_2 and o2("BoxStopWhenObtained")
                    if wD_3 then
                        Toggles.AutoMysteryBox:SetValue(false)
                        Library:Notify("Got " .. attr .. ", stopped auto buying")
                    end
                    task.wait(1)
                end
            end
        elseif attr2 == "Idle" then
            local wD_4 = ow(MysteryBoxPrompt, MysteryBox.DefaultCost)
            if o8() - wD_4 >= oI("BoxReserve", 0) then
                pL(MysteryBoxPrompt)
                task.wait(0.75)
            end
        end
    end
end
local function onHeartbeat2()
    local uI = Library.Unloaded or not o2("KnifeKillAura")
    if uI then
        return
    end
    local _weaponName = MeleeController._weaponName
    local uJ = _weaponName and Melee[_weaponName]
    local uI_2 = uJ
    if uJ then
        uJ = uI_2.Stats
    end
    if uJ then
        uJ = uI_2.Stats.Light
    end
    local uI_3 = uJ
    local CurrentCamera = Workspace.CurrentCamera
    local uK = pK()
    if not uI_3 or not CurrentCamera or not uK then
        return
    end
    if os.clock() - MeleeController._lastAttackTime < uI_3.Cooldown then
        return
    end
    local uL_2 = nil
    local uM_1 = math.huge
    local uN_1 = nil
    for k, v in LightweightNpcsClientModule.npcRecords do
        local instance = v.instance
        if pG(instance) then
            local uP = o4(instance)
            local Magnitude = (uP - uK.Position).Magnitude
            if Magnitude <= uI_3.Range and Magnitude < uM_1 then
                if ol(CurrentCamera.CFrame.Position, instance, uP) then
                    uN_1 = instance
                    uL_2 = uP
                    uM_1 = Magnitude
                end
            end
        end
    end
    if not uN_1 then
        return
    end
    local attr = uN_1:GetAttribute("npcId")
    if typeof(attr) ~= "number" then
        return
    end
    MeleeController._lastAttackTime = os.clock()
    Blink.melee.Attack.Fire({
        Timestamp = Workspace:GetServerTimeNow(),
        Origin = CFrame.lookAt(CurrentCamera.CFrame.Position, uL_2, CurrentCamera.CFrame.UpVector),
        Heavy = false,
        Tagged = { ["1"] = attr }
    })
end
local function fn747(b1)
    local sb_2
    local sa_2
    local r9 = if o2("AuraHeadshots") then 1 else 0
    if r9 == 1 then
        local Head = b1:FindFirstChild("Head", true)
        local r5 = Head and Head:IsA("BasePart")
        if r5 then
            return Head
        end
        local r4_2 = b1.PrimaryPart
        if not ((sa_2 * 3069 + sb_2 * 1866 + sa_2 * sb_2) % 16777213 == 6591970) then
            r4_2 = b1:FindFirstChildWhichIsA("BasePart", true)
        end
        return r4_2
    end
    local r4_3 = b1.PrimaryPart
    local sc_2 = if r4_3 then 1 else 0
    sa_2 = 1412 * sc_2 + 3799 * (1 - sc_2)
    sb_2 = 689 * sc_2 + 1658 * (1 - sc_2)
    if not ((sa_2 * 3069 + sb_2 * 1866 + sa_2 * sb_2) % 16777213 == 6591970) then
        r4_3 = b1:FindFirstChildWhichIsA("BasePart", true)
    end
    return r4_3
end
local function fn785()
    if not Toggles.Fly.Value then
        local v3 = pu()
        if v3 then
            v3.PlatformStand = false
        end
    end
end
local function fn809()
    oD(pl, "Copied Discord invite to clipboard")
end
local function onUnload()
    Library:Unload()
end
local function fn833(ar, as)
    local qS = Options[ar]
    local qT = qS and tonumber(qS.Value)
    return qT or as
end
local function onCopyJoinScript_JobID()
    oD(string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, pM), "Copied join script to clipboard")
end
local function fn867()
    pE.AdjustAim = pA
    if oV then
        debug.setupvalue(WeaponController._shoot, oV, oZ)
    end
    if oR then
        debug.setupvalue(WeaponController._shoot, oR, oU)
    end
    WeaponController._canShoot = _canShoot
    WeaponController._startShootLoop = _startShootLoop
    ViewModelController.PlayReload = PlayReload
    ViewModelController.PlayShellReload = on
    pk.CameraMinZoomDistance = CameraMinZoomDistance
    pk.CameraMode = CameraMode
    local v8 = pu()
    if v8 then
        v8.PlatformStand = false
        v8.WalkSpeed = 16
    end
    for k in o9 do
        if k.Parent then
            k.CanCollide = true
        end
    end
    o0()
    folder:Destroy()
    connection5:Disconnect()
    connection6:Disconnect()
    connection7:Disconnect()
    connection3:Disconnect()
    connection4:Disconnect()
    connection:Disconnect()
    connection2:Disconnect()
    select("#", "Zombie[Beta] unloaded")
end
local function fn896()
    Library.ScreenGui.Parent = pk:WaitForChild("PlayerGui")
end
local function onRenderStepped(h7)
    if Library.Unloaded then
        return
    end
    if o2("WalkSpeedEnabled") then
        local vI_1 = pu()
        if vI_1 then
            vI_1.WalkSpeed = oI("WalkSpeed", 32)
        end
    end
    if o2("NoClip") then
        local Character = pk.Character
        if Character then
            for i, descendant in Character:GetDescendants() do
                local vI_3 = descendant:IsA("BasePart") and descendant.CanCollide
                if vI_3 then
                    descendant.CanCollide = false
                    o9[descendant] = true
                end
            end
        end
    elseif next(o9) then
        for k in o9 do
            if k.Parent then
                k.CanCollide = true
            end
        end
        table.clear(o9)
    end
    if o2("Fly") then
        local vI_4 = pK()
        local vJ = pu()
        local CurrentCamera = Workspace.CurrentCamera
        if vI_4 and vJ and CurrentCamera then
            vJ.PlatformStand = true
            local vJ_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                vJ_1 = vJ_1 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                vJ_1 = vJ_1 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                vJ_1 = vJ_1 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                vJ_1 = vJ_1 + CurrentCamera.CFrame.RightVector
            end
            local v2 = if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
            if v2 == 1 then
                vJ_1 = vJ_1 + Vector3.yAxis
            end
            local vQ = if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then 1 else 0
            if vQ == 1 then
                vJ_1 = vJ_1 - Vector3.yAxis
            end
            vI_4.AssemblyLinearVelocity = Vector3.zero
            if vJ_1.Magnitude > 0 then
                vI_4.CFrame = vI_4.CFrame + vJ_1.Unit * oI("FlySpeed", 60) * h7
            end
        end
    end
    if o2("ThirdPerson") then
        local vI_5 = oI("ThirdPersonDistance", 12)
        if pk.CameraMode ~= Enum.CameraMode.Classic then
            pk.CameraMode = Enum.CameraMode.Classic
        end
        if pk.CameraMinZoomDistance ~= vI_5 then
            pk.CameraMinZoomDistance = vI_5
        end
    end
end
local function fn942(bX)
    if o2("AuraHeadshots") then
        local Head = bX:FindFirstChild("Head", true)
        local r2 = Head and Head:IsA("BasePart")
        if r2 then
            return Head.Position
        end
        return bX:GetPivot().Position
    end
    return bX:GetPivot().Position
end
local function worker2()
    while not Library.Unloaded do
        task.wait(oI("GearUpgradeDelay", 0.75))
        if not o2("AutoUpgradeGears") then
            continue
        end
        local xd = appStore.getAccounts()[tostring(pk.UserId)]
        if not xd then
            continue
        end
        local xe = loadoutStore.getLoadout()
        local xg = xd.WeaponLevels or {}
        local xf_1 = oI("GearUpgradeMax", weaponUpgrades.MaxLevel)
        local xg_1 = oI("GearUpgradeReserve", 0)
        local xh = {}
        for k, v in { xe.Slot1, xe.Slot2 } do
            local xe_1 = typeof(v) ~= "string" or v == "" or xh[v]
            if not xe_1 then
                xh[v] = true
                local xe_2 = weaponUpgrades.levelOf(xg, v)
                local xi = xe_2 < xf_1 and weaponUpgrades.costFor(xe_2)
                local xe_3 = xi or nil
                local xi_1 = xe_3
                if xe_3 then
                    xe_3 = o8() - xi_1 >= xg_1
                end
                if xe_3 then
                    Blink.weapon.Upgrade.Fire(v)
                    break
                end
            end
        end
    end
end
local function onJumpRequest()
    local vD = Library.Unloaded or not o2("InfJump")
    if vD then
        return
    end
    local vD_1 = pu()
    if vD_1 then
        vD_1:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end
local function fn977(bQ)
    if not bQ or not bQ.Parent then
        return false
    elseif CollectionService:HasTag(bQ, Tags.Friendly) then
        return false
    else
        local attr = bQ:GetAttribute("Hp")
        local r_ = typeof(attr) ~= "number" or attr > 0
        return r_
    end
end
local function fn985()
    for k in po do
        ph(k)
    end
end
local function fn1079(cy, cz)
    local sk = not cy
    local sk_4
    local st = if sk then 1 else 0
    local sr = 2471 * st + 914 * (1 - st)
    local ss = 2459 * st + 1078 * (1 - st)
    if not ((sr * 1234 + ss * 1730 + sr * ss) % 16777213 == 13379473) then
        sk = not pG(cy.model)
    end
    if sk then
        return false
    end
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return false
    end
    local Position = CurrentCamera.CFrame.Position
    local sm = o4(cy.model)
    local sn = sm - Position
    local Magnitude = sn.Magnitude
    local sp = Magnitude <= 1 or Magnitude > oI("AuraRange", 250)
    if sp then
        return false
    elseif cz then
        local sp_1 = CurrentCamera.CFrame.LookVector:Dot(sn.Unit)
        local sk_2 = math.acos(math.clamp(sp_1, -1, 1))
        if sk_2 > cz then
            return false
        end
        cy.angle = sk_2
        local sk_3 = o2("AuraWallCheck") and not o2("Wallbang") and not ol(Position, cy.model, sm)
        if sk_4 then
            return false
        end
        cy.point = sm
        cy.distance = Magnitude
        return true
    else
        sk_4 = o2("AuraWallCheck") and not o2("Wallbang") and not ol(Position, cy.model, sm)
        if sk_4 then
            return false
        end
        cy.point = sm
        cy.distance = Magnitude
        return true
    end
end
local function onHeartbeat3(hy)
    if Library.Unloaded then
        return
    end
    n8 += hy
    if n8 < 0.1 then
        return
    end
    n8 = 0
    if not o2("ZombieEsp") then
        if next(po) then
            o0()
        end
        return
    end
    local vd = pK()
    if not vd then
        o0()
        return
    end
    local ve = Options.EspColor and Options.EspColor.Value
    local vf = ve or Color3.fromRGB(255, 60, 60)
    local vf_1 = oI("EspRange", 500)
    local vg = {}
    for k, v in LightweightNpcsClientModule.npcRecords do
        local instance = v.instance
        if pG(instance) then
            local Position = instance:GetPivot().Position
            local Magnitude = (Position - vd.Position).Magnitude
            if Magnitude <= vf_1 then
                vg[instance] = true
                local vi_1 = po[instance] or oK(instance)
                vi_1.highlight.Enabled = o2("EspHighlight")
                vi_1.highlight.FillColor = vf
                vi_1.highlight.OutlineColor = vf
                local vi_2 = {}
                if o2("EspName") then
                    table.insert(vi_2, instance.Name)
                end
                if o2("EspHealth") then
                    local attr2 = instance:GetAttribute("Hp")
                    local attr = instance:GetAttribute("MaxHp")
                    if typeof(attr2) == "number" then
                        local insert = table.insert
                        local vo = typeof(attr) == "number" and "/" .. attr
                        local vm_1 = vo or ""
                        insert(vi_2, string.format("%d%s", attr2, vm_1))
                    end
                end
                if o2("EspDistance") then
                    table.insert(vi_2, string.format("%dm", Magnitude))
                end
                vi_1.label.Text = table.concat(vi_2, "  ")
                vi_1.label.TextColor3 = vf
                vi_1.billboard.Enabled = #vi_2 > 0
            end
        end
    end
    for k in po do
        if not vg[k] then
            ph(k)
        end
    end
end
local function fn1098(dK, dL)
    local Magnitude2 = dL.Magnitude
    if Magnitude2 <= 1 then
        return nil
    end
    local s6 = dL / Magnitude2
    local s7 = oB()
    if s7 then
        local s8_1 = o4(s7)
        local s9_1 = (s8_1 - dK):Dot(s6)
        if s9_1 > 0 and s9_1 <= Magnitude2 + 4 then
            return s7
        end
        local s7_1 = math.huge
        local s8_3 = nil
        local s9_2 = math.huge
        for k, v in LightweightNpcsClientModule.npcRecords do
            local instance = v.instance
            if pG(instance) then
                local tb_1 = o4(instance)
                local tc_1 = tb_1 - dK
                local tb_2 = tc_1:Dot(s6)
                if tb_2 > 0 and tb_2 <= Magnitude2 + 4 then
                    local Magnitude = (tc_1 - s6 * tb_2).Magnitude
                    local tc_2 = Magnitude <= 6
                    if tc_2 then
                        local te_1 = Magnitude < s7_1
                        if not te_1 then
                            te_1 = Magnitude == s7_1 and tb_2 < s9_2
                        end
                        tc_2 = te_1
                    end
                    if tc_2 then
                        s8_3 = instance
                        s7_1 = Magnitude
                        s9_2 = tb_2
                    end
                end
            end
        end
        return s8_3
    end
    local s7_2 = math.huge
    local s8_4 = nil
    local s9_3 = math.huge
    for k, v in LightweightNpcsClientModule.npcRecords do
        local instance = v.instance
        if pG(instance) then
            local tb_3 = o4(instance)
            local tc_3 = tb_3 - dK
            local tb_4 = tc_3:Dot(s6)
            if tb_4 > 0 and tb_4 <= Magnitude2 + 4 then
                local Magnitude = (tc_3 - s6 * tb_4).Magnitude
                local tc_4 = Magnitude <= 6
                if tc_4 then
                    local te_2 = Magnitude < s7_2
                    if not te_2 then
                        te_2 = Magnitude == s7_2 and tb_4 < s9_3
                    end
                    tc_4 = te_2
                end
                if tc_4 then
                    s8_4 = instance
                    s7_2 = Magnitude
                    s9_3 = tb_4
                end
            end
        end
    end
    return s8_4
end
local function fn1107()
    local leaderstats = pk:FindFirstChild("leaderstats")
    local q5 = leaderstats and leaderstats:FindFirstChild("Points")
    local q4_1 = q5
    if q5 then
        q5 = q4_1.Value
    end
    local q4_2 = q5
    local rc = if q4_2 then 1 else 0
    local ra = 2092 * rc + 1726 * (1 - rc)
    local rb = 562 * rc + 3226 * (1 - rc)
    if not ((ra * 3957 + rb * 57 + ra * rb) % 16777213 == 9485782) then
        q4_2 = 0
    end
    return q4_2
end
local function fn1112()
    local rA_2
    local ry_1
    local rz_1, rz_2
    if pv then
        return pv
    end
    local rx = {}
    for k, v in {
        Constants:WaitForChild("Drops"),
        Constants:WaitForChild("PlaceIds"),
        Constants:WaitForChild("Sounds"),
        Constants:WaitForChild("WeaponSystem"),
        Shared:WaitForChild("Utils"):WaitForChild("sounds"),
        ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Blink"),
        Client:WaitForChild("LightweightNpcs"):WaitForChild("LightweightNpcsClientModule")
    } do
        ry_1, rz_1 = pcall(require, v)
        local rA_1 = ry_1 and typeof(rz_1) == "table"
        if rA_1 then
            rx[rz_1] = true
        end
    end
    local ry_2 = nil
    local rQ = 1
    while rQ <= 24 do
        local rR = rQ
        rz_2, rA_2 = pcall(debug.getupvalue, DropController.start, rR)
        if not rz_2 then
            break
        end
        local rz_3 = typeof(rA_2) == "table" and not rx[rA_2]
        if rz_3 then
            for k, v in rA_2 do
                local rz_4 = typeof(v) == "table" and v.kind ~= nil and v.model ~= nil
                if rz_4 then
                    pv = rA_2
                    return pv
                end
            end
            if ry_2 == nil then
                ry_2 = rA_2
            else
                ry_2 = false
            end
        end
        rQ += 1
    end
    if ry_2 then
        pv = ry_2
    end
    return pv
end
local function fn1200(ad, ae, af)
    return string.format("<b>%s</b> %s %s", ad, oc("-", "#5a6070"), oc(ae, af))
end
AmmoBox = nil
connection3 = nil
n8 = nil
Label = nil
oa = nil
MysteryBox = nil
oc = nil
od = nil
connection2 = nil
of = nil
Melee = nil
oi = nil
Label4 = nil
ol = nil
om = nil
on = nil
Label3 = nil
LightweightNpcsClientModule = nil
PlayReload = nil
Label2 = nil
loadoutStore = nil
_startShootLoop = nil
ow = nil
connection = nil
appStore = nil
_canShoot = nil
oA = nil
oB = nil
DropController = nil
oD = nil
oE = nil
ViewModelController = nil
Options = nil
oH = nil
oI = nil
oK = nil
connection6 = nil
oM = nil
Toggles = nil
oO = nil
MeleeController = nil
oQ = nil
oR = nil
oS = nil
WeaponController = nil
oU = nil
oV = nil
oW = nil
local og, oJ
connection7 = nil
Constants = nil
oZ = nil
o_ = nil
o0 = nil
o1 = nil
o2 = nil
Shared = nil
o4 = nil
Library = nil
o6 = nil
o7 = nil
o8 = nil
o9 = nil
Client = nil
pb = nil
pc = nil
CameraMinZoomDistance = nil
pe = nil
pf = nil
pg = nil
ph = nil
CameraMode = nil
pj = nil
pk = nil
pl = nil
pm = nil
pn = nil
po = nil
connection5 = nil
pq = nil
Workspace = nil
ps = nil
folder = nil
pu = nil
pv = nil
CollectionService = nil
px = nil
Blink = nil
connection4 = nil
pA = nil
pB = nil
VirtualUser = nil
weaponUpgrades = nil
pE = nil
UserInputService = nil
pG = nil
Tags = nil
pJ = nil
local wallWeaponGate
pK = nil
pL = nil
pM = nil
ReplicatedStorage = nil
pO = nil
pP = nil
ReplicatedStorage, UserInputService, VirtualUser, CollectionService, Workspace, pk = nil, nil, nil, nil, nil, nil
local xF_1 = game:GetService("Players")
ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
CollectionService = game:GetService("CollectionService")
Workspace = game:GetService("Workspace")
pk = xF_1.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return pk:WaitForChild("PlayerGui")
    end
end
Client, Shared, Constants, WeaponController, MeleeController, ViewModelController, DropController, appStore, loadoutStore, LightweightNpcsClientModule, Melee, MysteryBox, AmmoBox, pO, wallWeaponGate, weaponUpgrades, Blink, pl, pf, Library, Toggles, Options, pn, pc, o7, oD, om, oc, pJ, o2, oI, oi, pK, pu, o8, oJ, ow, og, pL = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Client = ReplicatedStorage:WaitForChild("Client")
Shared = ReplicatedStorage:WaitForChild("Shared")
local xF_30 = Client:WaitForChild("Controllers")
Constants = Shared:WaitForChild("Constants")
WeaponController = require(xF_30:WaitForChild("WeaponController"))
MeleeController = require(xF_30:WaitForChild("MeleeController"))
local xF_6 = require(xF_30:WaitForChild("AimAssistController"))
ViewModelController = require(xF_30:WaitForChild("ViewModelController"))
DropController = require(xF_30:WaitForChild("DropController"))
appStore = require(Client:WaitForChild("Stores"):WaitForChild("appStore"))
loadoutStore = require(Client:WaitForChild("Stores"):WaitForChild("loadoutStore"))
LightweightNpcsClientModule = require(Client:WaitForChild("LightweightNpcs"):WaitForChild("LightweightNpcsClientModule"))
local xF_18 = require(Constants:WaitForChild("WeaponSystem"))
Melee = require(Constants:WaitForChild("Melee"))
local xF_32 = require(Constants:WaitForChild("Drops"))
MysteryBox = require(Constants:WaitForChild("MysteryBox"))
AmmoBox = require(Constants:WaitForChild("AmmoBox"))
pO = require(Shared:WaitForChild("Utils"):WaitForChild("castRays"))
local xF_35 = require(Shared:WaitForChild("Utils"):WaitForChild("castPierce"))
wallWeaponGate = require(Shared:WaitForChild("Utils"):WaitForChild("wallWeaponGate"))
weaponUpgrades = require(Shared:WaitForChild("Utils"):WaitForChild("weaponUpgrades"))
Blink = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Blink"))
local xF_22 = "Zombie[Beta]"
pl = "https://discord.gg/K7Qxnxkk46"
pf = "https://discord.gg/K7Qxnxkk46"
Library = getgenv().Library
pcall(fn896)
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
oD = fn595
om = fn809
oc = fns.fn360
pJ = fn1200
pn = "#7fd47f"
local xF_37 = "#6ec1ff"
pc = "#e8a34d"
o7 = "#8b93a3"
o2 = fns.fn507
oI = fn833
oi = fns.fn451
pK = fns.fn168
pu = fn668
o8 = fn1107
oJ = fn644
ow = fns.fn143
og = function(aX)
    local Enabled = aX.Enabled
    aX.Enabled = true
    pcall(function()
        fireproximityprompt(aX)
    end)
    aX.Enabled = Enabled
end
pL = function(a0, a1)
    local rj, rk, rl
    rj = pK()
    if not rj then
        return false
    end
    rl = oJ(a0)
    if not rl then
        return false
    end
    local rm = math.max(a0.MaxActivationDistance - 2, 4)
    if (rj.Position - rl).Magnitude <= rm then
        og(a0)
        return true
    end
    local rm_1 = not a1
    if rm_1 ~= false then
        rm_1 = not o2("TeleportToBuy")
    end
    if rm_1 then
        return false
    end
    local Character = pk.Character
    local CFrame2 = rj.CFrame
    rk = rl + Vector3.new(0, 4, 0)
    local ro = a0.Parent and a0.Parent:IsA("Attachment")
    if ro then
        local ro_1 = wallWeaponGate.outwardNormal(rl)
        if ro_1 then
            rk = rl + ro_1 * 4 + Vector3.new(0, 2, 0)
        end
    end
    local ro_2 = pcall(function()
        rj.CFrame = CFrame.lookAt(rk, rl)
        task.wait(0.3)
        og(a0)
        task.wait(0.25)
    end)
    if rj.Parent and pk.Character == Character then
        rj.CFrame = CFrame2
    end
    return ro_2
end
local xF_10 = {}
for k, v in MysteryBox.Pool do
    table.insert(xF_10, v.Weapon)
end
pB, pv, Tags, ps, pm, pg, pb, o6, o1, o_, oW, oQ, oO, pq, pG, o4, oM, ol, oH, of, oE = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
table.sort(xF_10)
pB = { Gems = xF_32.KindGem, Ammo = xF_32.KindAmmo, Crates = xF_32.KindCrate }
pv = nil
pq = fn1112
Tags = xF_18.Tags
pG = fn977
o4 = fn942
oM = fn747
ol = fns.fn54
ps = nil
pm = nil
pg = 5
pb = 0.75
o6 = 3
o1 = setmetatable({}, { __mode = "k" })
o_ = nil
oW = nil
oQ = 0
oO = nil
oH = fns.fn486
of = fn1079
oE = function(cO, cP)
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return nil
    end
    local Position = CurrentCamera.CFrame.Position
    local LookVector = CurrentCamera.CFrame.LookVector
    local sy_1 = oI("AuraRange", 250)
    local sB = o2("AuraWallCheck") and not o2("Wallbang")
    local sC = {}
    for k, v in LightweightNpcsClientModule.npcRecords do
        local instance = v.instance
        local sF = cP and o1[instance] or nil
        local sE_1 = sF
        if sF then
            sF = sE_1 <= os.clock()
        end
        if sF then
            o1[instance] = nil
            sE_1 = nil
        end
        local sF_1 = not sE_1
        if sF_1 ~= false then
            sF_1 = pG(instance)
        end
        if sF_1 then
            local sE_2 = o4(instance)
            local sF_2 = sE_2 - Position
            local Magnitude = sF_2.Magnitude
            if Magnitude <= sy_1 and Magnitude > 1 then
                local sH_1 = math.acos(math.clamp(LookVector:Dot(sF_2.Unit), -1, 1))
                if not cO or sH_1 <= cO then
                    table.insert(sC, { model = instance, point = sE_2, distance = Magnitude, angle = sH_1 })
                end
            end
        end
    end
    table.sort(sC, function(df, dg)
        if cO then
            return df.angle < dg.angle
        end
        return df.distance < dg.distance
    end)
    for k, v in sC do
        local sy_2 = not sB or ol(Position, v.model, v.point)
        if sy_2 then
            return v
        end
    end
    return nil
end
xF_1 = WeaponController.AimAssistController or xF_6
pE, pA, oZ, oU, oV, oR, oB, oa, px, xF_3, xF_32 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
xF_30 = 2
repeat
    xF_18 = (xF_30 * 3 + 0) % 4 + 1
    if xF_18 <= 2 then
        if xF_18 <= 1 then
            xF_6 = (vector.create((xF_30 * 4 + 3) % 11 + 1, (xF_30 * 8 + 7) % 13 + 1, (xF_30 * 4 + 9) % 17 + 1))
            xF_39 = (vector.create((xF_30 * 5 + 9) % 11 + 1, (xF_30 * 2 + 5) % 13 + 1, (xF_30 * 1 + 6) % 17 + 1))
            xF_25 = (vector.create((xF_30 * 1 + 7) % 5 + 1, (xF_30 * 2 + 6) % 7 + 1, (xF_30 * 5 + 4) % 9 + 1))
            if math.abs((vector.angle(xF_6, xF_39, xF_25))) - math.abs((vector.angle(xF_39, xF_6, xF_25))) == 0 then
                xF_3 = fn577
            else
                oB = fn577
            end
            xF_30 = (xF_30 + 15) % 32
        else
            xF_6 = {
                "nmjpyak",
                "mcga",
                "wapi",
                "qjddyq",
                "rbc",
                "jtctqjup",
                "evi",
                "shturnzziaq",
                "ajpnpccsyyha",
                "fpauptt",
                "opx",
                "jicewsmcgkc"
            }
            if xF_6[(xF_30 * 30 + 32) % 12 + 1] <= xF_6[(xF_30 * 30 + 32) % 12 + 1] then
                xF_32 = fns.fn69
                oV = nil
                oR = nil
            else
                oR = fns.fn69
                xF_32 = nil
                oV = nil
            end
            xF_30 = (xF_30 + 3) % 32
        end
    elseif xF_18 <= 3 then
        xF_18 = (vector.create((xF_30 * 4 + 3) % 11 + 1, (xF_30 * 5 + 1) % 13 + 1, (xF_30 * 4 + 7) % 17 + 1))
        xF_6 = (vector.create((xF_30 * 5 + 9) % 11 + 1, (xF_30 * 4 + 13) % 13 + 1, (xF_30 * 6 + 3) % 17 + 1))
        xF_39 = (vector.create((xF_30 * 6 + 6) % 11 + 1, (xF_30 * 8 + 10) % 13 + 1, (xF_30 * 8 + 12) % 17 + 1))
        xF_25 = (vector.create((xF_30 * 2 + 5) % 5 + 1, (xF_30 * 5 + 6) % 7 + 1, (xF_30 * 4 + 3) % 9 + 1))
        if vector.dot(vector.cross(xF_18, (vector.cross(xF_6, xF_39))), xF_25) == vector.dot(xF_6 * vector.dot(xF_18, xF_39) - xF_39 * vector.dot(xF_18, xF_6), xF_25) then
            pE = xF_1
            pA = pE.AdjustAim
            pE.AdjustAim = fns.fn391
            oB = fn653
            oa = fn1098
            px = fn590
        else
            oa = oB
            px = oa.AdjustAim
            oa.AdjustAim = fns.fn391
            pA = fn653
            pE = fn1098
            xF_1 = fn590
        end
        xF_30 = (xF_30 + 27) % 32
    else
        if (xF_30 * 3 + 6) * 9 % 4 == ((xF_30 * 3 + 6) * 9 + 8) % 4 then
            oZ = pO
            oU = xF_35
        else
            oU = xF_35
            pO = oZ
        end
        xF_30 = (xF_30 + 27) % 32
    end
until (xF_30 * 9 + 26) % 32 == 20
local qC = 1
while qC <= 40 do
    local qD = qC
    xF_1, xF_30 = pcall(debug.getupvalue, WeaponController._shoot, qD)
    if not xF_1 then
        break
    end
    if xF_30 == pO then
        oV = qD
        debug.setupvalue(WeaponController._shoot, qD, xF_3)
    elseif xF_30 == xF_35 then
        oR = qD
        debug.setupvalue(WeaponController._shoot, qD, xF_32)
    end
    qC += 1
end
_canShoot, _startShootLoop, PlayReload, on, xF_6, od, xF_18 = nil, nil, nil, nil, nil, nil, nil
_canShoot = WeaponController._canShoot
_startShootLoop = WeaponController._startShootLoop
PlayReload = ViewModelController.PlayReload
if (xF_18 and not od or (xF_18 or xF_18)) and (not od and xF_18 or (not xF_6 or od)) and not ((xF_18 and not od or (xF_18 or xF_18)) and (not od and xF_18 or (not xF_6 or od))) then
    od = WeaponController.PlayShellReload
    ViewModelController._canShoot = fns.fn392
    ViewModelController._startShootLoop = function(e_)
        if not o2("RapidFire") then
            return _startShootLoop(e_)
        end
        if e_._shootingThread then
            return
        end
        e_._shootingThread = task.spawn(function()
            while e_._activated do
                if e_:_canShoot() then
                    e_:_shoot()
                elseif e_._ammo <= 0 and not e_._reloading then
                    e_:Reload()
                end
                task.wait(math.max(oI("RapidFireDelay", 0.05), 0.01))
            end
            e_._shootingThread = nil
        end)
    end
    WeaponController.PlayReload = fns.fn81
    WeaponController.PlayShellReload = fns.fn111
    on = fns.fn4
else
    on = ViewModelController.PlayShellReload
    WeaponController._canShoot = fns.fn392
    WeaponController._startShootLoop = function(e_)
        if not o2("RapidFire") then
            return _startShootLoop(e_)
        end
        if e_._shootingThread then
            return
        end
        e_._shootingThread = task.spawn(function()
            while e_._activated do
                if e_:_canShoot() then
                    e_:_shoot()
                elseif e_._ammo <= 0 and not e_._reloading then
                    e_:Reload()
                end
                task.wait(math.max(oI("RapidFireDelay", 0.05), 0.01))
            end
            e_._shootingThread = nil
        end)
    end
    ViewModelController.PlayReload = fns.fn81
    ViewModelController.PlayShellReload = fns.fn111
    od = fns.fn4
end
xF_1 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = "https://discord.gg/K7Qxnxkk46 | Zombie[Beta]",
    Icon = 18657887261,
    NotifySide = "Right",
    ShowCustomCursor = false
})
xF_6 = {
    Info = xF_1:AddTab("Info", "info"),
    Combat = xF_1:AddTab("Combat", "crosshair"),
    Loot = xF_1:AddTab("Loot", "gem"),
    Shop = xF_1:AddTab("Shop", "shopping-cart"),
    Player = xF_1:AddTab("Player", "user"),
    Settings = xF_1:AddTab("Settings", "settings")
}
xF_18 = fns.fn234
for k, v in xF_6 do
    xF_18(v)
end
oA, xF_1, xF_32, Label, pP, pM, xF_3 = nil, nil, nil, nil, nil, nil, nil
xF_30 = 7
repeat
    xF_18 = (xF_30 * 2 + 2) % 3 + 1
    if xF_18 <= 2 then
        if xF_18 <= 1 then
            if (xF_30 * 2 + 8) * 16 % 3 == ((xF_30 * 2 + 8) * 16 + 0) % 3 then
                xF_3 = #pM > 18
            else
                pM = #xF_3 > 18
            end
            xF_30 = (xF_30 + 11) % 12
        else
            if (xF_1 or xF_30) and (xF_3 or not xF_1) and (not pM and xF_30 or not xF_3 and not xF_30) or not ((xF_1 or xF_30) and (xF_3 or not xF_1) and (not pM and xF_30 or not xF_3 and not xF_30)) then
                oA = "Unknown"
                pcall(fns.fn185)
                xF_1 = xF_6.Info:AddLeftGroupbox("Account", "circle-user")
                xF_1:AddLabel(pJ("User", pk.Name, pn), true)
                xF_1:AddLabel(pJ("Status", "Keyless", pn), true)
                xF_1:AddLabel(pJ("Executor", oA, pn), true)
                xF_32 = xF_6.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                xF_32:AddLabel(oc(xF_22 .. " [" .. tostring(game.PlaceId) .. "]", xF_37), true)
                xF_32:AddLabel(pJ("Place ID", tostring(game.PlaceId), xF_37), true)
                Label = xF_32:AddLabel(pJ("Session time", "0s", pc), true)
                pP = os.clock()
            else
                pJ = "Unknown"
                pcall(fns.fn185)
                pk = (nil):AddLeftGroupbox("Account", "circle-user")
                pk:AddLabel(xF_1("User", oc.Name, Label), true)
                pk:AddLabel(xF_1("Status", "Keyless", Label), true)
                pk:AddLabel(xF_1("Executor", pJ, Label), true)
                xF_22 = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
                xF_22:AddLabel(oA(xF_32 .. " [" .. tostring(game.PlaceId) .. "]", xF_6), true)
                xF_22:AddLabel(xF_1("Place ID", tostring(game.PlaceId), xF_6), true)
                pP = xF_22:AddLabel(xF_1("Session time", "0s", xF_37), true)
                pc = os.clock()
            end
            xF_30 = (xF_30 + 2) % 12
        end
    else
        xF_18 = {
            "yrjahxjtwnyw",
            "gbfjxsvk",
            "blwvx",
            "epiamzbmhx",
            "mpbyeuuknjk",
            "awxzy",
            "mdrzr",
            "higyqazmne",
            "bvcpcfrpkvdp",
            "bhiptht",
            "mjbzrakv",
            "suvllwbnlel",
            "zpesqoazkun"
        }
        if xF_18[(xF_30 * 30 + 59) % 13 + 1] < xF_18[(xF_30 * 30 + 59) % 13 + 1] then
            xF_32 = tostring(game.JobId)
        else
            pM = tostring(game.JobId)
        end
        xF_30 = (xF_30 + 2) % 12
    end
until (xF_30 * 11 + 10) % 12 == 0
if xF_3 then
    xF_1 = 2
    repeat
        xF_30 = { "xraniud", "jwqhhfoyiqe", "enkukxouf", "jxvhocpwkre", "fccs", "lrkx", "hxzcga" }
        local yt = xF_1
        xF_18 = xF_30[yt % 7 + 1]
        local qz = if xF_18:len() <= xF_18:reverse():rep(yt % 3 + 2):len() then 1 else 0
        if qz == 1 then
            xF_3 = string.sub(pM, 1, 18) .. "..."
        else
            pM = string.sub(xF_3, 1, 18) .. "..."
        end
        xF_1 = (xF_1 + 0) % 4
    until (xF_1 * 3 + 1) % 4 == 3
end
xF_1 = xF_3 or pM
ScriptsGroup, SocialsGroup, SilentAimGroup, WeaponModsGroup, Label2, Label3, Label4, xF_30, GearUpgradesGroup, MovementGroup, pj, pe, connection, connection2, connection3, connection4, folder, po, n8, connection5, CameraMode, CameraMinZoomDistance, o9, connection6, connection7, oS, ph, o0, oK = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local xF_19 = xF_1
xF_32:AddLabel(pJ("Server", xF_19, o7), true)
xF_32:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
local TempoHubGroup = xF_6.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
if (not CameraMinZoomDistance and not connection3 or (connection3 or not SocialsGroup)) and ((SilentAimGroup or not connection3) and (SocialsGroup or GearUpgradesGroup)) and ((connection3 or GearUpgradesGroup or (not SilentAimGroup or not SilentAimGroup)) and (connection3 or SilentAimGroup or (not SilentAimGroup or connection3))) or not ((not CameraMinZoomDistance and not connection3 or (connection3 or not SocialsGroup)) and ((SilentAimGroup or not connection3) and (SocialsGroup or GearUpgradesGroup)) and ((connection3 or GearUpgradesGroup or (not SilentAimGroup or not SilentAimGroup)) and (connection3 or SilentAimGroup or (not SilentAimGroup or connection3)))) then
    TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = om })
    ScriptsGroup = xF_6.Info:AddRightGroupbox("Scripts", "package")
else
    ScriptsGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    ScriptsGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    ScriptsGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    ScriptsGroup:AddButton({ Text = "Copy Discord Invite", Func = TempoHubGroup })
    xF_6 = om.Info:AddRightGroupbox("Scripts", "package")
end
ScriptsGroup:AddLabel(oc("Included in this hub", o7), true)
ScriptsGroup:AddLabel(oc(xF_22, xF_37), true)
local FeaturesGroup = xF_6.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(oc("Kill Aura", xF_37), true)
FeaturesGroup:AddLabel(oc("Silent Aim", xF_37), true)
FeaturesGroup:AddLabel(oc("Zombie ESP", xF_37), true)
FeaturesGroup:AddLabel(oc("Instant Collect Loot", xF_37), true)
FeaturesGroup:AddLabel(oc("Loot Filters", pc), true)
FeaturesGroup:AddLabel(oc("Auto Buy Mystery Box", pc), true)
FeaturesGroup:AddLabel(oc("Auto Buy Area", pn), true)
FeaturesGroup:AddLabel(oc("Auto Buy Ammo", pn), true)
FeaturesGroup:AddLabel(oc("Player Movement", o7), true)
SocialsGroup = xF_6.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = om })
SocialsGroup:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
local FaqGroup = xF_6.Info:AddRightGroupbox("FAQ", "circle-help")
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
local KillAuraGroup = xF_6.Combat:AddLeftGroupbox("Kill Aura", "crosshair")
KillAuraGroup:AddToggle("KillAura", { Text = "Kill Aura", Default = false })
KillAuraGroup:AddToggle("AuraAutoReload", { Text = "Auto Reload", Default = true })
KillAuraGroup:AddToggle("KnifeKillAura", { Text = "Knife Kill Aura", Default = false })
SilentAimGroup = xF_6.Combat:AddLeftGroupbox("Silent Aim", "target")
if (not SilentAimGroup and FaqGroup and (not FaqGroup or FaqGroup) or (SilentAimGroup or not SilentAimGroup) and (SilentAimGroup and FaqGroup)) and (SilentAimGroup and not SilentAimGroup or not SilentAimGroup and not FaqGroup or (not FaqGroup and not FaqGroup or SilentAimGroup and not SilentAimGroup)) or (FaqGroup and SilentAimGroup or FaqGroup and not FaqGroup or not SilentAimGroup and not FaqGroup and (not FaqGroup and SilentAimGroup) or not SilentAimGroup and FaqGroup and (not FaqGroup and SilentAimGroup) and ((FaqGroup or not SilentAimGroup) and (SilentAimGroup or FaqGroup))) or not ((not SilentAimGroup and FaqGroup and (not FaqGroup or FaqGroup) or (SilentAimGroup or not SilentAimGroup) and (SilentAimGroup and FaqGroup)) and (SilentAimGroup and not SilentAimGroup or not SilentAimGroup and not FaqGroup or (not FaqGroup and not FaqGroup or SilentAimGroup and not SilentAimGroup)) or (FaqGroup and SilentAimGroup or FaqGroup and not FaqGroup or not SilentAimGroup and not FaqGroup and (not FaqGroup and SilentAimGroup) or not SilentAimGroup and FaqGroup and (not FaqGroup and SilentAimGroup) and ((FaqGroup or not SilentAimGroup) and (SilentAimGroup or FaqGroup)))) then
    SilentAimGroup:AddToggle("SilentAim", { Text = "Silent Aim", Default = false })
    SilentAimGroup:AddSlider("SilentFov", { Text = "FOV", Default = 60, Min = 5, Max = 360, Rounding = 0, Suffix = " deg" })
    WeaponModsGroup = xF_6.Combat:AddRightGroupbox("Weapon Mods", "zap")
else
    WeaponModsGroup:AddToggle("SilentAim", { Text = "Silent Aim", Default = false })
    WeaponModsGroup:AddSlider("SilentFov", { Suffix = " deg", Text = "FOV", Default = 60, Rounding = 0, Min = 5, Max = 360 })
    xF_6 = SilentAimGroup.Combat:AddRightGroupbox("Weapon Mods", "zap")
end
WeaponModsGroup:AddToggle("InstantReload", { Text = "Instant Reload", Default = false })
WeaponModsGroup:AddToggle("RapidFire", { Text = "Rapid Fire", Default = false })
WeaponModsGroup:AddToggle("Wallbang", { Text = "Wallbang", Default = false })
WeaponModsGroup:AddSlider("RapidFireDelay", { Text = "Shot Delay", Default = 0.05, Min = 0.01, Max = 0.25, Rounding = 2, Suffix = "s" })
local AimSettingsGroup = xF_6.Combat:AddLeftGroupbox("Aim Settings", "settings-2")
AimSettingsGroup:AddSlider("AuraRange", { Text = "Range", Default = 250, Min = 20, Max = 500, Rounding = 0, Suffix = " studs" })
AimSettingsGroup:AddToggle("AuraHeadshots", { Text = "Aim Head", Default = true })
AimSettingsGroup:AddToggle("AuraWallCheck", { Text = "Wall Check", Default = true })
xF_39 = xF_6.Combat:AddRightGroupbox("Zombie ESP", "eye")
xF_39:AddToggle("ZombieEsp", { Text = "Zombie ESP", Default = false }):AddColorPicker("EspColor", { Default = Color3.fromRGB(255, 60, 60), Title = "ESP Color" })
xF_39:AddToggle("EspHighlight", { Text = "Highlight", Default = true })
xF_39:AddToggle("EspName", { Text = "Name", Default = true })
xF_39:AddToggle("EspHealth", { Text = "Health", Default = true })
xF_39:AddToggle("EspDistance", { Text = "Distance", Default = true })
xF_39:AddSlider("EspRange", { Text = "ESP Range", Default = 500, Min = 50, Max = 2000, Rounding = 0, Suffix = " studs" })
xF_35 = xF_6.Combat:AddRightGroupbox("Status", "activity")
Label2 = xF_35:AddLabel(pJ("Target", "None", o7), true)
Label3 = xF_35:AddLabel(pJ("Ammo", "0 / 0", pc), true)
Label4 = xF_35:AddLabel(pJ("Points", "0", pn), true)
xF_18 = xF_6.Loot:AddLeftGroupbox("Instant Collect", "gem")
xF_18:AddToggle("InstantCollect", { Text = "Instant Collect Loot", Default = false })
xF_18:AddDropdown("CollectKinds", { Text = "Collect", Values = { "Gems", "Ammo", "Crates" }, Default = { "Gems" }, Multi = true })
xF_18:AddSlider("CollectRange", { Text = "Max Range", Default = 40, Min = 10, Max = 300, Rounding = 0, Suffix = " studs" })
xF_3 = xF_6.Shop:AddLeftGroupbox("Mystery Box", "box")
if (not KillAuraGroup and ph and (connection7 or ph) or (ph or connection4)) and (not MovementGroup or false or false or (KillAuraGroup and not connection4 or connection4)) and not ((not KillAuraGroup and ph and (connection7 or ph) or (ph or connection4)) and (not MovementGroup or false or false or (KillAuraGroup and not connection4 or connection4))) then
    xF_6:AddToggle("AutoMysteryBox", { Text = "Auto Buy Mystery Box", Default = false })
    xF_6:AddDropdown("BoxWeapons", { Multi = true, Default = {}, Text = "Wanted Weapons", Values = xF_3 })
    xF_6:AddToggle("BoxTakeAny", { Text = "Take Any Weapon", Default = false })
    xF_6:AddToggle("BoxStopWhenObtained", { Text = "Stop After Getting Wanted", Default = true })
    xF_6:AddInput("BoxReserve", { Text = "Points Reserve", Numeric = true, Default = "0", Finished = true })
    xF_30.Shop:AddRightGroupbox("Area", "door-open")
else
    xF_3:AddToggle("AutoMysteryBox", { Text = "Auto Buy Mystery Box", Default = false })
    xF_3:AddDropdown("BoxWeapons", { Text = "Wanted Weapons", Values = xF_10, Default = {}, Multi = true })
    xF_3:AddToggle("BoxTakeAny", { Text = "Take Any Weapon", Default = false })
    xF_3:AddToggle("BoxStopWhenObtained", { Text = "Stop After Getting Wanted", Default = true })
    xF_3:AddInput("BoxReserve", { Text = "Points Reserve", Default = "0", Numeric = true, Finished = true })
    xF_30 = xF_6.Shop:AddRightGroupbox("Area", "door-open")
end
xF_30:AddToggle("AutoBuyArea", { Text = "Auto Buy Area", Default = false })
xF_30:AddInput("AreaReserve", { Text = "Points Reserve", Default = "0", Numeric = true, Finished = true })
xF_30:AddSlider("AreaDelay", { Text = "Delay", Default = 3, Min = 0.5, Max = 15, Rounding = 1, Suffix = "s" })
local AmmoGroup = xF_6.Shop:AddLeftGroupbox("Ammo", "package-plus")
AmmoGroup:AddToggle("AutoBuyAmmo", { Text = "Auto Buy Ammo", Default = false })
AmmoGroup:AddDropdown("AmmoSources", {
    Text = "Sources",
    Values = { "Wall Weapon", "Ammo Box" },
    Default = { "Wall Weapon" },
    Multi = true
})
AmmoGroup:AddToggle("AmmoBoxOnlyEmpty", { Text = "Ammo Box Only When Empty", Default = true })
AmmoGroup:AddSlider("AmmoThreshold", { Text = "Buy Below Reserve", Default = 60, Min = 0, Max = 500, Rounding = 0 })
AmmoGroup:AddInput("AmmoPointsReserve", { Text = "Points Reserve", Default = "0", Numeric = true, Finished = true })
local ReachGroup = xF_6.Shop:AddRightGroupbox("Reach", "move")
ReachGroup:AddToggle("TeleportToBuy", { Text = "Teleport To Buy", Default = false })
GearUpgradesGroup = xF_6.Shop:AddRightGroupbox("Gear Upgrades", "chevrons-up")
GearUpgradesGroup:AddToggle("AutoUpgradeGears", { Text = "Auto Upgrade Gears", Default = false })
GearUpgradesGroup:AddSlider("GearUpgradeMax", { Text = "Maximum Level", Default = 50, Min = 2, Max = 50, Rounding = 0 })
GearUpgradesGroup:AddInput("GearUpgradeReserve", { Text = "Points Reserve", Default = "0", Numeric = true, Finished = true })
GearUpgradesGroup:AddSlider("GearUpgradeDelay", { Text = "Upgrade Delay", Default = 0.75, Min = 0.25, Max = 3, Rounding = 2, Suffix = "s" })
MovementGroup = xF_6.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
local FlyGroup = xF_6.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
local CameraGroup = xF_6.Player:AddLeftGroupbox("Camera", "camera")
CameraGroup:AddToggle("ThirdPerson", { Text = "Force Third Person", Default = false })
CameraGroup:AddSlider("ThirdPersonDistance", { Text = "Camera Distance", Default = 12, Min = 5, Max = 40, Rounding = 0, Suffix = " studs" })
local MenuGroup = xF_6.Settings:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
pj = tick()
pe = tick()
pcall(function()
    for i, v in ipairs(getconnections(pk.Idled)) do
        local ut = v
        pcall(function()
            ut:Disable()
        end)
    end
end)
oS = fns.fn284
connection = UserInputService.InputBegan:Connect(fns.onInputBegan)
connection2 = UserInputService.InputChanged:Connect(fns.onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
Library.ToggleKeybind = Options.MenuKeybind
connection3 = RunService.Heartbeat:Connect(fns.onHeartbeat)
connection4 = RunService.Heartbeat:Connect(onHeartbeat2)
folder = Instance.new("Folder")
folder.Name = "TempoEsp"
folder.Parent = pk:WaitForChild("PlayerGui")
po = {}
ph = fns.fn26
o0 = fn985
oK = fn559
n8 = 0
connection5 = RunService.Heartbeat:Connect(onHeartbeat3)
CameraMode = pk.CameraMode
CameraMinZoomDistance = pk.CameraMinZoomDistance
o9 = {}
connection6 = UserInputService.JumpRequest:Connect(onJumpRequest)
connection7 = RunService.RenderStepped:Connect(onRenderStepped)
do
    Toggles.Fly:OnChanged(fn785)
    Toggles.WalkSpeedEnabled:OnChanged(fns.fn201)
    Toggles.ThirdPerson:OnChanged(fn667)
    Library:OnUnload(fn867)
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("TempoHub")
    ThemeManager:SaveDefault("Mint")
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    SaveManager:SetFolder("TempoHub/ZombiesArena")
    SaveManager:BuildConfigSection(xF_6.Settings)
    ThemeManager:ApplyToTab(xF_6.Settings)
    ThemeManager:LoadDefault()
    SaveManager:LoadAutoloadConfig()
    task.spawn(fns.worker8)
    task.spawn(fns.worker7)
    task.spawn(fns.worker6)
    task.spawn(worker5)
    task.spawn(fns.worker4)
    task.spawn(fns.worker3)
    task.spawn(worker2)
    task.spawn(fns.worker)
    Library:Notify("Zombie[Beta] loaded")
end
end)(...)

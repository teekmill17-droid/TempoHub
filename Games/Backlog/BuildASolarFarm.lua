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
getgenv().TempoHoodSubtitle = "BUILD A SOLAR FARM"
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
local uo
local t5
local tN
local uu
local tu
local ub
local tT
local uA
local LocalPlayer
local tZ
local uG
local tG
local un
local t4
local tM
local ut
local tt
local ua
local tS
local uz
local tz
local ug
local CoreGui
local uF
local tF
local ts
local t9
local tR
local uy
local ty
local uf
local tX
local uE
local tE
local ul
local t2
local tK
local tr
local ux
local tx
local tW
local uD
local tD
local State
local t1
local tJ
local t7
local tP
local uw
local tw
local ud
local tV
local uC
local tC
local uj
local up
local t6
local tO
local tv
local uc
local tU
local uB
local tB
local ui
local function fn22()
    local z6_1
    local z5_1
    local z4_1
    local z2_1
    local z1_1, z1_2
    local z0 = ts()
    if not z0 then
        return
    end
    z2_1, z1_1 = tw()
    if next(z1_1) == nil then
        return
    end
    local z3 = tt()
    z4_1, z5_1 = nil, nil
    for k in pairs(z1_1) do
        z1_2, z6_1 = tK(k, z0, z2_1)
        local z7 = z1_2 and z6_1 <= z3
        if z7 then
            z7 = t4.maxCost <= 0 or z6_1 <= t4.maxCost
        end
        if z7 then
            if not z5_1 or z6_1 < z5_1 then
                z4_1, z5_1 = k, z6_1
            end
        end
    end
    if not z4_1 then
        return
    end
    if tG("ZoneEvent", z4_1) then
        tJ(string.format("Bought plot zone %d for $%d", z4_1, z5_1))
    end
end
local function fn37()
    local xY = type(tx) == "table" and type(tx.Cash) == "number"
    if xY then
        return tx
    end
    tx = nil
    if not tP(getgc) then
        return nil
    elseif os.clock() - uE < 5 then
        return nil
    else
        uE = os.clock()
        local xY_1 = pcall(function()
            for i, v in ipairs(getgc(true)) do
                if type(v) == "table" then
                    local xP = rawget(v, "Data")
                    local xQ = type(xP) == "table" and type(rawget(xP, "Cash")) == "number" and rawget(xP, "DailyRewardDay") ~= nil and rawget(xP, "IsCarryingEnergy") ~= nil
                    if xQ then
                        tx = xP
                        break
                    end
                end
            end
        end)
        if not xY_1 then
            return nil
        end
        return tx
    end
end
local function fn40()
    gethui = uC
end
local function fn48()
    local xJ = up()
    local xK = xJ and xJ.Upgrades[tv]
    local xJ_1 = xK
    if xK then
        xK = xJ_1[uB]
    end
    local xJ_2 = xK
    if xK then
        xK = tonumber(xJ_2.MaxLevel)
    end
    return xK or nil
end
local function fn49(W)
    local vl = typeof(cloneref) == "function" and typeof(W) == "Instance"
    if vl then
        return cloneref(W)
    end
    return W
end
local function fn71(gP)
    local Al = (tonumber(gP)) or 1.5
    tr.interval = math.max(0.3, Al)
end
local function fn80(et)
    local yC = {}
    if type(et) == "table" then
        for k, v in pairs(et) do
            local yD = v == true and type(k) == "string"
            if yD then
                yC[k] = true
            elseif type(v) == "string" then
                yC[v] = true
            end
        end
    end
    return yC
end
local function fn96()
    return not uf.Unloaded
end
local function fn110(dR)
    local yi_1
    local yg = up()
    local yh = not yg or not tP(yg.GetUpgradeCost)
    local yh_1
    if yh then
        return nil
    end
    yh_1, yi_1 = pcall(yg.GetUpgradeCost, tv, uB, dR)
    if not yh_1 then
        return nil
    end
    return tonumber(yi_1)
end
local function fn113(hD)
    if hD then
        tR(t4, tN)
    else
        tO(t4)
    end
end
local function fn118()
    local x5 = ux()
    if x5 then
        local x6_1 = (tonumber(x5.Cash)) or 0
        return x6_1
    end
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local x6_2 = leaderstats and leaderstats:FindFirstChild("Cash")
    local x5_2 = x6_2
    if x6_2 then
        x6_2 = tonumber(x5_2.Value)
    end
    return x6_2 or 0
end
local function fn123()
    tO(tZ)
    tO(t9)
    tO(t4)
    tO(tz)
    tO(tr)
    tO(uy)
    tO(uu)
    tO(un)
    tO(ui)
end
local function fn175()
    local zd = if tT() then 1 else 0
    if zd == 1 then
        return
    end
    if tG("InteractionEvent", "Collect") then
        tJ("Collected energy")
    end
end
local function fn236(hc)
    local Aw = (tonumber(hc)) or 2
    uu.interval = math.max(0.5, Aw)
end
local function fn247(hj)
    local AA = (tonumber(hj)) or 5
    un.interval = math.max(1, AA)
end
local function fn260(hl)
    if hl then
        tR(ui, ul)
    else
        tO(ui)
    end
end
local function fn281(gI)
    local Ah = (tonumber(gI)) or 3
    tz.interval = math.max(0.5, Ah)
end
local function fn283()
    if tG("InteractionEvent", "CollectCash") then
        tJ("Collected cash")
    end
end
local function fn290()
    if not tV() then
        return
    end
    local zR = tC()
    if zR then
        local zS = ut()
        if zS and zR >= zS then
            tJ("Generator is maxed")
            return
        end
        if tZ.maxLevel > 0 and zR >= tZ.maxLevel then
            tJ("Generator at your level cap")
            return
        end
        local zS_2 = tX(zR)
        local zT_1 = zS_2 and zS_2 > tt()
        if zT_1 then
            tJ(string.format("Need $%d for generator level %d", zS_2, zR + 1))
            return
        end
    end
    if tG("UpgradeEvent", tv, uB) then
        tJ("Upgraded generator")
    end
end
local function fn294(hT)
    local AT = (tonumber(hT)) or 0
    tZ.maxLevel = math.max(0, AT)
end
local function fn299()
    local yk = ux()
    if not yk then
        return nil, nil
    end
    local yl = (tonumber(yk.DailyRewardDay)) or 1
    local yl_1 = (tonumber(yk.LastClaimTime)) or 0
    local yl_2 = yl_1 <= 0
    local yq = if yl_2 then 1 else 0
    local yo = 3288 * yq + 3215 * (1 - yq)
    local yp = 2092 * yq + 2201 * (1 - yq)
    if not ((yo * 1801 + yp * 1729 + yo * yp) % 16777213 == 16417252) then
        yl_2 = os.time() - yl_1 >= uo
    end
    if yl_2 then
        return true, yl
    end
    return false, yl
end
local function fn315()
    if ua then
        return ua
    end
    local vC = t6()
    if not vC then
        return nil
    end
    local vD = {}
    for k, v in pairs(vC.Panels) do
        local vC_1 = type(v) == "table" and type(v.Name) == "string"
        if vC_1 then
            local Name = v.Name
            local vE = type(v.Rarity) == "string" and v.Rarity
            local vF = vE or "Common"
            local vE_1 = (tonumber(v.Cost)) or 0
            vD[Name] = { Rarity = vF, Cost = vE_1 }
        end
    end
    ua = vD
    return vD
end
local function fn339(g0)
    if g0 then
        tR(uy, t7)
    else
        tO(uy)
    end
end
local function fn352()
    local wu = t2()
    if #wu == 0 then
        return false
    end
    for i, v in ipairs(wu) do
        if not v.panel then
            return true
        end
    end
    return false
end
local function fn387()
    return tu:FindFirstChild("Remotes")
end
local function fn388(hM)
    if hM then
        tR(tZ, ug)
    else
        tO(tZ)
    end
end
local function fn396(Z)
    return type(Z) == "function"
end
local function fn406(as, at)
    local vs = uG()
    local vt = vs and vs:FindFirstChild(as)
    local vs_1 = vt
    if vt then
        vt = vs_1:IsA(at)
    end
    if vt then
        return vs_1
    end
    return nil
end
local function fn479(hx)
    t9.rarities = tE(hx)
end
local function fn489()
    local Character = LocalPlayer.Character
    local v8 = Character and Character:FindFirstChild("HumanoidRootPart")
    return v8 or nil
end
local function fn492()
    local wE_1
    local wD_4
    if ty ~= nil then
        return ty ~= false and ty or nil
    end
    local Shared = tu:FindFirstChild("Shared")
    local wD_2 = Shared and Shared:FindFirstChild("Configurations")
    local wC_3 = wD_2
    if wD_2 then
        wD_2 = wC_3:FindFirstChild("Zone")
    end
    local wC_4 = wD_2
    local wD_3 = not wC_4 or not wC_4:IsA("ModuleScript")
    if wD_3 then
        ty = false
        return nil
    end
    wD_4, wE_1 = pcall(require, wC_4)
    local wC_5 = not wD_4 or type(wE_1) ~= "table"
    local wI = if wC_5 then 1 else 0
    local wG = 3597 * wI + 255 * (1 - wI)
    local wH = 1118 * wI + 3166 * (1 - wI)
    if not ((wG * 3768 + wH * 1912 + wG * wH) % 16777213 == 2935345) then
        wC_5 = type(wE_1.Zones) ~= "table"
    end
    if wC_5 then
        ty = false
        return nil
    end
    ty = wE_1
    return wE_1
end
local function fn494(gD)
    if gD then
        tR(tz, tS)
    else
        tO(tz)
    end
end
local function fn497()
    local v4 = tV()
    local v5 = v4 and v4:FindFirstChild("SpawnLocation")
    local v4_1 = v5
    if v5 then
        v5 = v4_1:IsA("BasePart")
    end
    if v5 then
        return v4_1.Position
    end
    return nil
end
local function fn524(g5)
    local As = (tonumber(g5)) or 2
    uy.interval = math.max(0.5, As)
end
local function fn538()
    local ya = ux()
    local yb = ya and ya.Upgrades
    local yb_1 = type(yb) == "table" and yb[tv]
    local ya_2 = yb_1
    local yf = if ya_2 then 1 else 0
    local yd = 2087 * yf + 1293 * (1 - yf)
    local ye = 3428 * yf + 471 * (1 - yf)
    if not ((yd * 3148 + ye * 2477 + yd * ye) % 16777213 == 5438055) then
        ya_2 = nil
    end
    local yb_2 = ya_2
    if type(yb_2) ~= "table" then
        return nil
    end
    return tonumber(yb_2[uB])
end
local function fn549()
    return CoreGui
end
local function fn555()
    local Plots = uA:FindFirstChild("Plots")
    if not Plots then
        return nil
    end
    for i, child in ipairs(Plots:GetChildren()) do
        if child:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return child
        end
    end
    return nil
end
local function fn557()
    local zh = if not tT() then 1 else 0
    if zh == 1 then
        return
    end
    if tG("InteractionEvent", "Sell") then
        tJ("Deposited energy")
    end
end
local function fn584(er)
    er.stopped = true
    local yx = er.generation
    local yB = if yx then 1 else 0
    local yz = 1312 * yB + 2151 * (1 - yB)
    local yA = 2427 * yB + 851 * (1 - yB)
    if not ((yz * 2874 + yA * 771 + yz * yA) % 16777213 == 8826129) then
        yx = 0
    end
    er.generation = yx + 1
end
local function fn601()
    local xy_1
    local xx_4
    if uw ~= nil then
        local xx_1 = uw ~= false and uw
        local xC = if xx_1 then 1 else 0
        local xA = 1559 * xC + 2310 * (1 - xC)
        local xB = 2392 * xC + 718 * (1 - xC)
        if not ((xA * 3118 + xB * 1948 + xA * xB) % 16777213 == 13249706) then
            xx_1 = nil
        end
        return xx_1
    end
    local Shared = tu:FindFirstChild("Shared")
    local xx_2 = Shared and Shared:FindFirstChild("Configurations")
    local xw_3 = xx_2
    if xx_2 then
        xx_2 = xw_3:FindFirstChild("Upgrade")
    end
    local xw_4 = xx_2
    local xx_3 = not xw_4
    local xF = if xx_3 then 1 else 0
    local xD = 1998 * xF + 819 * (1 - xF)
    local xE = 1791 * xF + 1088 * (1 - xF)
    if not ((xD * 2836 + xE * 2084 + xD * xE) % 16777213 == 12977190) then
        xx_3 = not xw_4:IsA("ModuleScript")
    end
    if xx_3 then
        uw = false
        return nil
    end
    xx_4, xy_1 = pcall(require, xw_4)
    local xw_5 = not xx_4
    local xI = if xw_5 then 1 else 0
    local xG = 1492 * xI + 1288 * (1 - xI)
    local xH = 2817 * xI + 505 * (1 - xI)
    if not ((xG * 679 + xH * 3244 + xG * xH) % 16777213 == 14354380) then
        xw_5 = type(xy_1) ~= "table"
    end
    if not xw_5 then
        xw_5 = type(xy_1.Upgrades) ~= "table"
    end
    if xw_5 then
        uw = false
        return nil
    end
    uw = xy_1
    return xy_1
end
local function fn604(gK)
    if gK then
        tR(tr, uF)
    else
        tO(tr)
    end
end
local function fn608(gZ)
    local Ao = (tonumber(gZ)) or 0
    tr.maxCost = math.max(0, Ao)
end
local function fn611()
    local vA_1
    local vz_4
    if ud ~= nil then
        return ud ~= false and ud or nil
    end
    local Shared = tu:FindFirstChild("Shared")
    local vz_2 = Shared and Shared:FindFirstChild("Configurations")
    local vy_3 = vz_2
    if vz_2 then
        vz_2 = vy_3:FindFirstChild("Panel")
    end
    local vy_4 = vz_2
    local vz_3 = not vy_4 or not vy_4:IsA("ModuleScript")
    if vz_3 then
        ud = false
        return nil
    end
    vz_4, vA_1 = pcall(require, vy_4)
    local vy_5 = not vz_4 or type(vA_1) ~= "table" or type(vA_1.Panels) ~= "table"
    if vy_5 then
        ud = false
        return nil
    end
    ud = vA_1
    return vA_1
end
local function fn618(hA)
    t9.panels = tE(hA)
end
local function fn641()
    local wi = tV()
    local wj = wi and wi:FindFirstChild("RollSlots")
    if not wj then
        return {}
    end
    local wj_1 = {}
    for i, child in ipairs(wj:GetChildren()) do
        local wi_2 = tonumber(child.Name)
        local RollAnchor = child:FindFirstChild("RollAnchor")
        if wi_2 and RollAnchor then
            local attr = RollAnchor:GetAttribute("PanelName")
            local insert = table.insert
            local wm = type(attr) == "string" and attr
            local wl_2 = wm or nil
            insert(wj_1, { index = wi_2, panel = wl_2 })
        end
    end
    table.sort(wj_1, function(bF, bG)
        return bF.index < bG.index
    end)
    return wj_1
end
local function fn658(g7)
    if g7 then
        tR(uu, tM)
    else
        tO(uu)
    end
end
local function fn676(hI)
    local AJ = (tonumber(hI)) or 5
    t4.interval = math.max(1, AJ)
end
local function fn681()
    local zk_1
    local zj_1
    zj_1, zk_1 = uc()
    if zj_1 == false then
        return
    end
    local zj_2 = zk_1 or 1
    local zo = if tG("ClaimDailyReward", zj_2) then 1 else 0
    if zo == 1 then
        tJ("Claimed daily reward " .. tostring(zj_2))
    end
end
local function fn686(hq)
    if hq then
        tR(t9, tD)
    else
        tO(t9)
    end
end
local function fn694(hK)
    local AM = (tonumber(hK)) or 0
    t4.maxCost = math.max(0, AM)
end
local function fn717(an)
    State.Status = tostring(an)
end
local function fn758()
    local wL_1
    local wJ = tV()
    local wK = wJ and wJ:FindFirstChild("Zones")
    local wK_1
    wL_1, wK_1 = {}, {}
    if not wK then
        return wL_1, wK_1
    end
    for i, child in ipairs(wK:GetChildren()) do
        local wJ_2 = tonumber(child.Name)
        if wJ_2 then
            if child:FindFirstChild("PromptAtt") then
                wK_1[wJ_2] = child
            else
                wL_1[wJ_2] = child
            end
        end
    end
    return wL_1, wK_1
end
local function fn763()
    local x8 = ux()
    if x8 then
        return x8.IsCarryingEnergy == true
    end
    return false
end
local function fn814(ai, aj)
    if not tF() then
        return
    end
    local Notifications = State.Notifications
    local vp = tostring(ai)
    local vq = aj or 5
    table.insert(Notifications, { text = vp, time = vq })
    if #State.Notifications > 12 then
        table.remove(State.Notifications, 1)
    end
end
local function fn906()
    local Ad = uz()
    if not Ad then
        ub("Could not find your plot")
        return
    end
    if tB(Ad, 5) then
        ub("Teleported to your base")
    else
        ub("No character to teleport")
    end
end
local function fn909(hv)
    local AF = (tonumber(hv)) or 2
    t9.interval = math.max(0.5, AF)
end
local function fn910(gR)
    tr.rarities = tE(gR)
end
local function fn1010(gX)
    tr.unblock = gX == true
end
local function fn1025()
    if not tV() then
        tJ("Waiting for your plot")
        return
    end
    local yU = if not t1() then 1 else 0
    if yU == 1 then
        tJ("Roll slots full - buy or clear a panel")
        return
    end
    if tG("RollEvent", "Roll") then
        tJ("Rolled a panel")
    end
end
local function fn1028(gU)
    tr.panels = tE(gU)
end
local function fn1041()
    local vQ = t5()
    local vR = {}
    if not vQ then
        return vR
    end
    for k in pairs(vQ) do
        table.insert(vR, k)
    end
    table.sort(vR)
    return vR
end
local function fn1045(ez)
    local yL = 0
    for k in pairs(ez) do
        yL += 1
    end
    return yL
end
local function fn1065(he)
    if he then
        tR(un, uD)
    else
        tO(un)
    end
end
local function fn1072(b9, ca, cb)
    local wT = ca.Zones[b9]
    if type(wT) ~= "table" then
        return false, 0
    end
    local RequiresAny = wT.RequiresAny
    local wV = type(RequiresAny) == "table" and #RequiresAny > 0
    if wV then
        local wV_1 = false
        for i, v in ipairs(RequiresAny) do
            if cb[tonumber(v)] then
                wV_1 = true
                break
            end
        end
        if not wV_1 then
            return false, 0
        end
        local wU_1 = (tonumber(wT.Cost)) or 0
        return true, wU_1
    end
    local wU_2 = (tonumber(wT.Cost)) or 0
    return true, wU_2
end
local function fn1073()
    local yV = t2()
    if #yV == 0 then
        return
    end
    local yW = t5()
    local yX = uj(tr.rarities)
    local yY = uj(tr.panels)
    local yZ = tt()
    for i, v in ipairs(yV) do
        local yV_1 = not tF() or tr.stopped
        if yV_1 then
            return
        end
        local panel = v.panel
        if panel then
            local y0 = yW and yW[panel] or nil
            local y__1 = y0
            if y0 then
                y0 = y__1.Cost
            end
            local y1 = y0 or 0
            local y0_1 = y__1
            if y0_1 then
                y0_1 = y__1.Rarity
            end
            local y__2 = y0_1 or nil
            local y0_2 = true
            if yY > 0 or yX > 0 then
                y0_2 = false
                if yY > 0 and tr.panels[panel] then
                    y0_2 = true
                end
                if yX > 0 and y__2 and tr.rarities[y__2] then
                    y0_2 = true
                end
            end
            if y0_2 and tr.maxCost > 0 and y1 > tr.maxCost then
                y0_2 = false
            end
            local y__7 = not y0_2
            if y__7 ~= false then
                y__7 = tr.unblock
            end
            if y__7 then
                y0_2 = true
            end
            if y0_2 then
                if y1 > yZ then
                    tJ(string.format("Need $%s for %s", tostring(y1), panel))
                elseif tG("RollEvent", "Buy", v.index) then
                    tJ("Bought " .. panel)
                    yZ -= y1
                    task.wait(0.35)
                end
            else
                tJ("Skipping " .. panel)
            end
        end
    end
end
local function fn1108(hR)
    local AQ = (tonumber(hR)) or 3
    tZ.interval = math.max(0.5, AQ)
end
local function fn1114()
    local zp = tV()
    if not zp then
        return
    end
    local zp_1 = tU()
    if #zp_1 == 0 then
        return
    end
    local zq = t5()
    local zr = t6()
    local zs = uj(t9.rarities)
    local zt = uj(t9.panels)
    local zu = tw()
    for i, v in ipairs(zp_1) do
        local zp_2 = not tF() or t9.stopped
        if zp_2 then
            return
        end
        local zv = zq and zq[v.name] or nil
        local zv_3
        local zp_4 = zv
        if zv then
            zv = zp_4.Rarity
        end
        local zp_5 = zv or nil
        local zv_1 = true
        local zw_1
        if zt > 0 or zs > 0 then
            zv_1 = false
            if zt > 0 and t9.panels[v.name] then
                zv_1 = true
            end
            if zs > 0 and zp_5 and t9.rarities[zp_5] then
                zv_1 = true
            end
        end
        if zv_1 then
            local zp_9 = Vector2.new(4, 4)
            local zv_2 = zr and tP(zr.GetPanelData)
            if zv_2 then
                zv_3, zw_1 = pcall(zr.GetPanelData, v.name)
                local zx_1 = zv_3 and type(zw_1) == "table" and typeof(zw_1.GridSize) == "Vector2"
                if zx_1 then
                    zp_9 = zw_1.GridSize
                end
            end
            local zv_4 = v.quantity
            local zw_2 = false
            for k, v2 in pairs(zu) do
                local zx_2 = zv_4 <= 0 or not tF() or t9.stopped
                if zx_2 then
                    break
                end
                for i, v2 in ipairs(tW(v2, zp_9.X, zp_9.Y)) do
                    if zv_4 <= 0 then
                        break
                    elseif tG("ItemEvent", "Panel", v.uuid, k, v2) then
                        zv_4 -= 1
                        zw_2 = true
                        tJ("Placed " .. v.name)
                        task.wait(0.4)
                    end
                end
            end
            local zp_10 = not zw_2
            if zp_10 ~= false then
                zp_10 = zv_4 > 0
            end
            if zp_10 then
                tJ("No free grid space for " .. v.name)
            end
        end
    end
end
tr = nil
ts = nil
tt = nil
tu = nil
tv = nil
tw = nil
tx = nil
ty = nil
tz = nil
LocalPlayer = nil
tB = nil
tC = nil
tD = nil
tE = nil
tF = nil
tG = nil
tJ = nil
tK = nil
tM = nil
tN = nil
tO = nil
tP = nil
tR = nil
tS = nil
tT = nil
tU = nil
tV = nil
tW = nil
tX = nil
CoreGui = nil
tZ = nil
t1 = nil
t2 = nil
t4 = nil
t5 = nil
t6 = nil
t7 = nil
t9 = nil
ua = nil
ub = nil
uc = nil
local Players, Workspace, tI, Lighting, TeleportService, t_, t0, GuiService, HttpService
ud = nil
uf = nil
ug = nil
ui = nil
uj = nil
State = nil
ul = nil
un = nil
uo = nil
up = nil
ut = nil
uu = nil
uw = nil
ux = nil
uy = nil
uz = nil
uA = nil
uB = nil
uC = nil
uD = nil
uE = nil
uF = nil
uG = nil
local ue, VirtualUser, UserInputService, uq, ur, RunService, uv
local uH_1
if not game:IsLoaded() then
    game.Loaded:Wait()
end
Players, RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, TeleportService, Lighting, Workspace, LocalPlayer, uC = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
TeleportService = game:GetService("TeleportService")
Lighting = game:GetService("Lighting")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local uI = "TempoBuildASolarFarm"
uC = fn549
if getgenv then
    getgenv().gethui = uC
end
uf, tu, uA, uv, uo, State, ud, ua, ty, t_, tv, uB, uw, tx, uE, tz, tr, uy, uu, un, ui, t9, t4, tZ, tI, tP, tF, ub, tJ, uG, ur, tG, t6, t5, uq, tV, uz, t0, tB, t2, t1, ts, tw, tK, tU, tW, up, ut, ux, tt, tT, tC, tX, uc, tR, tO, tE, uj, tS, uF, t7, tM, uD, ul, tD, ug, tN, ue, uH_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pcall(fn40)
local function uM(t)
    local vb
    local u9
    local va
    u9 = nil
    va = nil
    vb = nil
    local vc = t ~= ""
    local vd = type(t) == "string" and vc
    assert(vd, "A namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    u9 = getgenv()
    assert(type(u9) == "table", "getgenv did not return a table")
    local vc_1 = u9[t]
    if vc_1 ~= nil then
        local vd_1 = type(vc_1) == "table" and type(vc_1.Unload) == "function"
        assert(vd_1, "Namespace is occupied")
        vc_1.Unload()
        assert(u9[t] == nil, "Previous instance did not release its namespace")
    end
    va = {}
    vb = { State = {}, Unloaded = false }
    vb.Track = function(B)
        assert(type(B) == "function", "Cleanup must be callable")
        if vb.Unloaded then
            B()
        else
            table.insert(va, B)
        end
        return B
    end
    vb.Unload = function()
        local u2_1
        local u1_1
        if vb.Unloaded then
            return
        end
        vb.Unloaded = true
        local u_ = {}
        local u6 = #va
        local u5 = -1
        while false and u6 <= 1 or true and u6 >= 1 do
            local u7 = u6
            local u0_1 = table.remove(va, u7)
            u1_1, u2_1 = pcall(u0_1)
            if not u1_1 then
                table.insert(u_, tostring(u2_1))
            end
            u6 += u5
        end
        table.clear(vb.State)
        if #u_ > 0 then
            error("Cleanup incomplete: " .. table.concat(u_, "; "), 0)
        end
        if u9[t] == vb then
            u9[t] = nil
        end
    end
    u9[t] = vb
    return vb
end
if (tP and un and (not un and not un) and (not un and uH_1 and (tP and t7)) or not t7 and false and (not tP or un) and (not tP and not t7 or (uH_1 or not t7))) and (un and uH_1 and (not un or un) and (false or not un or (t7 or false)) or (uH_1 and not tP and (false and not un) or (false or tP or (t7 or t7)))) or not ((tP and un and (not un and not un) and (not un and uH_1 and (tP and t7)) or not t7 and false and (not tP or un) and (not tP and not t7 or (uH_1 or not t7))) and (un and uH_1 and (not un or un) and (false or not un or (t7 or false)) or (uH_1 and not tP and (false and not un) or (false or tP or (t7 or t7))))) then
    tI = function(O, P)
        local vg = type(O) == "table" and type(O.Track) == "function"
        assert(vg, "FeatureAPI required")
        local vg_2 = type(P) == "table" and type(P.OnUnload) == "function"
        assert(vg_2, "UI library required")
        assert(type(P.Unload) == "function", "UI unload required")
        O.Track(function()
            if not P.Unloaded then
                P:Unload()
            end
        end)
        P:OnUnload(function()
            O.Unload()
        end)
    end
else
    t0 = function(O, P)
        local vg = type(O) == "table" and type(O.Track) == "function"
        assert(vg, "FeatureAPI required")
        local vg_1 = type(P) == "table" and type(P.OnUnload) == "function"
        assert(vg_1, "UI library required")
        assert(type(P.Unload) == "function", "UI unload required")
        O.Track(function()
            if not P.Unloaded then
                P:Unload()
            end
        end)
        P:OnUnload(function()
            O.Unload()
        end)
    end
end
uf = uM(uI)
tP = fn396
tF = fn96
tu = fn49(ReplicatedStorage)
uA = fn49(Workspace)
uv = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Exclusive" }
uo = 86400
State = uf.State
State.Notifications = {}
State.Status = "Idle"
ub = fn814
tJ = fn717
uG = fn387
ur = fn406
tG = function(aA, ...)
    local vw
    local vv
    vv = nil
    vw = nil
    vw = ur(aA, "RemoteEvent")
    if not vw then
        return false
    end
    vv = table.pack(...)
    return (pcall(function()
        vw.FireServer(vw, table.unpack(vv, 1, vv.n))
    end))
end
ud = nil
t6 = fn611
ua = nil
t5 = fn315
uq = fn1041
tV = fn555
uz = fn497
t0 = fn489
tB = function(bn, bo)
    local we
    local wd
    wd = nil
    we = nil
    if typeof(bn) ~= "Vector3" then
        return false
    end
    we = t0()
    if not we then
        return false
    end
    local wg = bo or 5
    wd = bn + Vector3.new(0, wg, 0)
    return (pcall(function()
        we.CFrame = CFrame.new(wd)
        we.AssemblyLinearVelocity = Vector3.zero
    end))
end
t2 = fn641
t1 = fn352
ty = nil
ts = fn492
tw = fn758
tK = fn1072
t_ = OverlapParams.new()
t_.FilterType = Enum.RaycastFilterType.Include
tU = function()
    local ck
    ck = {}
    local function cl(cm)
        if not cm then
            return
        end
        for i, child in ipairs(cm:GetChildren()) do
            local w2 = (child:IsA("Tool")) and child:GetAttribute("ItemType") == "Panel"
            if w2 then
                local attr2 = child:GetAttribute("UUID")
                local attr = child:GetAttribute("ItemName")
                local w4 = type(attr2) == "string" and type(attr) == "string"
                if w4 then
                    local insert = table.insert
                    local w5 = (tonumber(child:GetAttribute("Quantity"))) or 1
                    insert(ck, { uuid = attr2, name = attr, quantity = w5 })
                end
            end
        end
    end
    cl(LocalPlayer:FindFirstChildOfClass("Backpack"))
    cl(LocalPlayer.Character)
    return ck
end
tW = function(cw, cx, cy)
    local xk_1
    local Base = cw:FindFirstChild("Base")
    local xf = tV()
    local xg = xf and xf:FindFirstChild("PlacedObjects")
    local xf_1 = not Base
    if not xf_1 then
        xf_1 = not Base:IsA("BasePart")
    end
    if xf_1 or not xg then
        return {}
    end
    t_.FilterDescendantsInstances = { xg }
    local xf_2 = math.floor(Base.Size.X / cx)
    local xg_2 = math.floor(Base.Size.Z / cy)
    local xh_1 = Base.Position.Y + Base.Size.Y * 0.5 + 0.1
    local xi_1 = {}
    local xj = xf_2 - 1
    local xj_2
    local xp = 0
    while xp <= xj do
        local xq = xp
        local xf_3 = xg_2 - 1
        for i = 0, xf_3 do
            local xd
            local xf_4 = Base.Position.X - Base.Size.X * 0.5 + cx * (xq + 0.5)
            local xj_1 = Base.Position.Z - Base.Size.Z * 0.5 + cy * (i + 0.5)
            xd = CFrame.new(xf_4, xh_1, xj_1)
            local xf_5 = false
            xj_2, xk_1 = pcall(function()
                return uA:GetPartBoundsInBox(xd, Vector3.new(cx - 0.4, 6, cy - 0.4), t_)
            end)
            local xl = xj_2 and type(xk_1) == "table" and #xk_1 > 0
            if xl then
                xf_5 = true
            end
            if not xf_5 then
                table.insert(xi_1, xd)
            end
        end
        xp += 1
    end
    return xi_1
end
tv = "SellUpgrades"
uB = "EnergyConverted"
uw = nil
up = fn601
ut = fn48
tx = nil
uE = 0
ux = fn37
tt = fn118
tT = fn763
tC = fn538
tX = fn110
uc = fn299
tz = { interval = 3 }
tr = { interval = 1.5, rarities = {}, panels = {}, unblock = false, maxCost = 0 }
uy = { interval = 2 }
uu = { interval = 2 }
un = { interval = 5 }
ui = { interval = 60 }
t9 = { interval = 2, rarities = {}, panels = {} }
t4 = { interval = 5, maxCost = 0 }
tZ = { interval = 3, maxLevel = 0 }
tR = function(eg, eh)
    local generation
    eg.generation = (eg.generation or 0) + 1
    eg.stopped = false
    generation = eg.generation
    task.spawn(function()
        local ys_1
        while true do
            local yr = (tF()) and not eg.stopped and eg.generation == generation
            local yr_1
            if yr then
                yr_1, ys_1 = pcall(eh)
                if not yr_1 then
                    warn("[Tempo] loop error: " .. tostring(ys_1))
                end
                local yr_2 = not tF() or eg.stopped or eg.generation ~= generation
                if yr_2 then
                    break
                end
                task.wait(eg.interval)
                continue
            end
            break
        end
    end)
end
tO = fn584
tE = fn80
uj = fn1045
tS = fn1025
uF = fn1073
t7 = fn175
tM = fn557
uD = fn283
ul = fn681
if (not tO or not uj) and (tP or t5) and (not t5 and not t5 and (not uj or tO)) or not ((not tO or not uj) and (tP or t5) and (not t5 and not t5 and (not uj or tO))) then
    tD = fn1114
    ug = fn290
    tN = fn22
    ue = fn906
else
    ue = fn1114
    tN = fn290
    tD = fn22
    ug = fn906
end
tz.SetEnabled = fn494
tz.SetDelay = fn281
tr.SetEnabled = fn604
tr.SetDelay = fn71
tr.SetRarities = fn910
tr.SetPanels = fn1028
tr.SetUnblock = fn1010
tr.SetMaxCost = fn608
uy.SetEnabled = fn339
uy.SetDelay = fn524
uu.SetEnabled = fn658
uu.SetDelay = fn236
un.SetEnabled = fn1065
un.SetDelay = fn247
ui.SetEnabled = fn260
t9.SetEnabled = fn686
t9.SetDelay = fn909
t9.SetRarities = fn479
t9.SetPanels = fn618
t4.SetEnabled = fn113
t4.SetDelay = fn676
t4.SetMaxCost = fn694
tZ.SetEnabled = fn388
tZ.SetDelay = fn1108
tZ.SetMaxLevel = fn294
uf.Track(fn123)
local function uH_2()
    local AV
    AV = false
    task.spawn(function()
        pcall(t5)
        pcall(ts)
        pcall(up)
        AV = true
    end)
    local AW = os.clock() + 5
    while true do
        local AX = not AV and os.clock() < AW
        if AX then
            task.wait(0.05)
            continue
        end
        break
    end
end
local function uK()
    local Fp
    local onDiscord
    local Fs
    Fp = nil
    Fs = nil
    onDiscord = nil
    local Fo, ThemeManager, Options, SaveManager, Fv, Fw, Fx, Library, Toggles, FA
    Fs = "https://discord.gg/K7Qxnxkk46"
    Fw = "https://discord.gg/K7Qxnxkk46"
    Fo = "https://tempohub.shop"
    Fv = "Build A Solar Farm"
    Library = getgenv().Library
    ThemeManager = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = Library.Toggles
    Options = Library.Options
    tI(uf, Library)
    Fx = uq()
    Fp = function(iB, iC)
        local AZ = (tP(setclipboard)) and setclipboard
        local A_ = AZ
        if not A_ then
            local AZ_1 = (tP(toclipboard)) and toclipboard
            A_ = AZ_1 or nil
        end
        local AZ_2 = A_
        if not AZ_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local A__1 = pcall(AZ_2, iB)
        if A__1 then
            Library:Notify(iC)
        else
            Library:Notify("Failed to copy")
        end
    end
    onDiscord = function()
        Fp(Fs, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = Fs, Copyable = true }, "|", Fv, "|", "v0.3" },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(false)
    FA = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gamepad-2"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
    local function FB_1(iR)
        local DiscordGroup = iR:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    for k, v in FA do
        if k ~= "Info" then
            FB_1(v)
        end
    end
    local function FC()
        local Bm
        Bm = nil
        local Label
        local RollingGroup = FA.Main:AddLeftGroupbox("Rolling", "dices")
        Label = RollingGroup:AddLabel(State.Status, true)
        RollingGroup:AddDivider()
        RollingGroup:AddToggle("AutoRoll", {
            Text = "Auto Roll",
            Default = false,
            Tooltip = "Pulls the roll machine lever whenever a roll slot is empty.",
            Callback = function(i1)
                tz.SetEnabled(i1)
            end
        })
        RollingGroup:AddSlider("RollDelay", {
            Text = "Roll Delay",
            Default = 3,
            Min = 0.5,
            Max = 30,
            Rounding = 1,
            Suffix = "s",
            Callback = function(i5)
                tz.SetDelay(i5)
            end
        })
        RollingGroup:AddDivider("Buying")
        RollingGroup:AddToggle("AutoBuyRoll", {
            Text = "Auto Buy Rolled Panels",
            Default = false,
            Tooltip = "Buys panels sitting in your roll slots. A slot stays blocked until its panel is bought.",
            Callback = function(i7)
                tr.SetEnabled(i7)
            end
        })
        RollingGroup:AddDropdown("BuyRarities", {
            Text = "Buy Rarities",
            Values = uv,
            Default = {},
            Multi = true,
            AllowNull = true,
            Tooltip = "Leave everything unticked to accept any rarity.",
            Callback = function(jd)
                tr.SetRarities(jd)
            end
        })
        RollingGroup:AddDropdown("BuyPanels", {
            Text = "Buy Panels",
            Values = Fx,
            Default = {},
            Multi = true,
            AllowNull = true,
            Tooltip = "Specific panels to always buy. Combines with the rarity list.",
            Callback = function(jg)
                tr.SetPanels(jg)
            end
        })
        RollingGroup:AddSlider("BuyMaxCost", {
            Text = "Max Panel Cost",
            Default = 0,
            Min = 0,
            Max = 1000000,
            Rounding = 0,
            Prefix = "$",
            Tooltip = "Skips panels above this price. 0 removes the limit.",
            Callback = function(ji)
                tr.SetMaxCost(ji)
            end
        })
        RollingGroup:AddToggle("BuyUnblock", {
            Text = "Buy Unwanted To Free Slots",
            Default = false,
            Tooltip = "Buys panels that fail your filter anyway, so the roll machine does not stay blocked.",
            Callback = function(jk)
                tr.SetUnblock(jk)
            end
        })
        RollingGroup:AddSlider("BuyDelay", {
            Text = "Buy Delay",
            Default = 1.5,
            Min = 0.3,
            Max = 30,
            Rounding = 1,
            Suffix = "s",
            Callback = function(jm)
                tr.SetDelay(jm)
            end
        })
        local PlotGroup = FA.Main:AddLeftGroupbox("Plot", "layout-grid")
        PlotGroup:AddToggle("AutoPlacePanels", {
            Text = "Auto Place Panels",
            Default = false,
            Tooltip = "Drops panels from your inventory into free grid cells on the zones you own.",
            Callback = function(jp)
                t9.SetEnabled(jp)
            end
        })
        PlotGroup:AddDropdown("PlaceRarities", {
            Text = "Place Rarities",
            Values = uv,
            Default = {},
            Multi = true,
            AllowNull = true,
            Tooltip = "Leave everything unticked to place any rarity.",
            Callback = function(jt)
                t9.SetRarities(jt)
            end
        })
        PlotGroup:AddDropdown("PlacePanels", {
            Text = "Place Panels",
            Values = Fx,
            Default = {},
            Multi = true,
            AllowNull = true,
            Tooltip = "Specific panels to always place. Combines with the rarity list.",
            Callback = function(jv)
                t9.SetPanels(jv)
            end
        })
        PlotGroup:AddSlider("PlaceDelay", {
            Text = "Place Delay",
            Default = 2,
            Min = 0.5,
            Max = 30,
            Rounding = 1,
            Suffix = "s",
            Callback = function(jx)
                t9.SetDelay(jx)
            end
        })
        PlotGroup:AddDivider("Land")
        PlotGroup:AddToggle("AutoBuyPlot", {
            Text = "Auto Buy Plot",
            Default = false,
            Tooltip = "Unlocks the cheapest plot zone you can afford and reach from the land you already own.",
            Callback = function(jz)
                t4.SetEnabled(jz)
            end
        })
        PlotGroup:AddSlider("ZoneMaxCost", {
            Text = "Max Zone Cost",
            Default = 0,
            Min = 0,
            Max = 1000000000,
            Rounding = 0,
            Prefix = "$",
            Tooltip = "Skips zones above this price. 0 removes the limit.",
            Callback = function(jD)
                t4.SetMaxCost(jD)
            end
        })
        PlotGroup:AddSlider("ZoneDelay", {
            Text = "Buy Zone Delay",
            Default = 5,
            Min = 1,
            Max = 120,
            Rounding = 1,
            Suffix = "s",
            Callback = function(jF)
                t4.SetDelay(jF)
            end
        })
        local EnergyGroup = FA.Main:AddRightGroupbox("Energy", "zap")
        EnergyGroup:AddToggle("AutoCollectEnergy", {
            Text = "Auto Collect Energy",
            Default = false,
            Tooltip = "Picks up the energy your panels have generated.",
            Callback = function(jI)
                uy.SetEnabled(jI)
            end
        })
        EnergyGroup:AddSlider("CollectDelay", {
            Text = "Collect Delay",
            Default = 2,
            Min = 0.5,
            Max = 60,
            Rounding = 1,
            Suffix = "s",
            Callback = function(jM)
                uy.SetDelay(jM)
            end
        })
        EnergyGroup:AddToggle("AutoDepositEnergy", {
            Text = "Auto Deposit Energy",
            Default = false,
            Tooltip = "Drops carried energy into the processing board.",
            Callback = function(jO)
                uu.SetEnabled(jO)
            end
        })
        EnergyGroup:AddSlider("DepositDelay", {
            Text = "Deposit Delay",
            Default = 2,
            Min = 0.5,
            Max = 60,
            Rounding = 1,
            Suffix = "s",
            Callback = function(jS)
                uu.SetDelay(jS)
            end
        })
        EnergyGroup:AddToggle("AutoCollectCash", {
            Text = "Auto Collect Cash",
            Default = false,
            Tooltip = "Takes the cash the processing board has finished converting.",
            Callback = function(jU)
                un.SetEnabled(jU)
            end
        })
        EnergyGroup:AddSlider("CashDelay", {
            Text = "Collect Cash Delay",
            Default = 5,
            Min = 1,
            Max = 120,
            Rounding = 1,
            Suffix = "s",
            Callback = function(jY)
                un.SetDelay(jY)
            end
        })
        EnergyGroup:AddDivider("Generator")
        EnergyGroup:AddToggle("AutoUpgradeGenerator", {
            Text = "Auto Upgrade Generator",
            Default = false,
            Tooltip = "Buys the processing board's energy conversion upgrade whenever you can afford the next level.",
            Callback = function(j_)
                tZ.SetEnabled(j_)
            end
        })
        local Bo = (ut()) or 80
        EnergyGroup:AddSlider("GeneratorMaxLevel", {
            Text = "Stop At Level",
            Default = 0,
            Min = 0,
            Max = Bo,
            Rounding = 0,
            Tooltip = "Stops upgrading once the generator reaches this level. 0 runs to the game's maximum.",
            Callback = function(j5)
                tZ.SetMaxLevel(j5)
            end
        })
        EnergyGroup:AddSlider("GeneratorDelay", {
            Text = "Upgrade Delay",
            Default = 3,
            Min = 0.5,
            Max = 60,
            Rounding = 1,
            Suffix = "s",
            Callback = function(j7)
                tZ.SetDelay(j7)
            end
        })
        local RewardsGroup = FA.Main:AddRightGroupbox("Rewards", "gift")
        RewardsGroup:AddToggle("AutoDaily", {
            Text = "Auto Claim Daily Rewards",
            Default = false,
            Tooltip = "Claims the daily reward as soon as its 24 hour timer is up.",
            Callback = function(ka)
                ui.SetEnabled(ka)
            end
        })
        local TeleportGroup = FA.Main:AddRightGroupbox("Teleport", "map-pin")
        TeleportGroup:AddButton({ Text = "Teleport To Base", Func = ue })
        Bm = task.spawn(function()
            while not Library.Unloaded do
                pcall(function()
                    local A2 = t2()
                    local A3 = 0
                    for i, v in ipairs(A2) do
                        if v.panel then
                            A3 += 1
                        end
                    end
                    local A4 = string.format("Cash $%d  |  Slots %d/%d", tt(), A3, #A2)
                    Label:SetText(A4 .. "  |  " .. tostring(State.Status))
                end)
                local Bg = false
                repeat
                    local Bc
                    if State.Notifications and #State.Notifications > 0 then
                        Bc = table.remove(State.Notifications, 1)
                        pcall(function()
                            Library:Notify(Bc.text, Bc.time)
                        end)
                    else
                        Bg = true
                    end
                until Bg
                task.wait(0.3)
            end
        end)
        uf.Track(function()
            local Bk = if coroutine.status(Bm) ~= "dead" then 1 else 0
            if Bk == 1 then
                pcall(task.cancel, Bm)
            end
        end)
    end
    FC()
    local function FB_2()
        local BH
        local BG
        local BC
        local BN
        BC = nil
        BG = nil
        BH = nil
        BN = nil
        local BD, Label, BF, BI, BJ, BK, Label2, Label3, BO
        BH = function(kK)
            return (tostring(kK):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
        end
        BC = function(kM, kN)
            return string.format('<font color="%s">%s</font>', kN, BH(kM))
        end
        BJ = function(kQ, kR, kS)
            return string.format("<b>%s</b> %s %s", kQ, BC("-", "#5a6070"), BC(kR, kS))
        end
        local BP = "#8b93a3"
        local BQ = {}
        BO = "#e8a34d"
        BF = "#7fd47f"
        local BR = "#6ec1ff"
        if not ur("RollEvent", "RemoteEvent") then
            table.insert(BQ, "rolling")
        end
        if not ur("InteractionEvent", "RemoteEvent") then
            table.insert(BQ, "energy")
        end
        if not ur("ClaimDailyReward", "RemoteEvent") then
            table.insert(BQ, "daily rewards")
        end
        if not ur("ItemEvent", "RemoteEvent") then
            table.insert(BQ, "placing panels")
        end
        local BS = not ur("ZoneEvent", "RemoteEvent") or not ts()
        if BS then
            table.insert(BQ, "buying plot zones")
        end
        if not ur("UpgradeEvent", "RemoteEvent") then
            table.insert(BQ, "generator upgrades")
        end
        if not t5() then
            table.insert(BQ, "panel filters")
        end
        if not tP(getgc) then
            table.insert(BQ, "daily timing and cash checks")
        end
        local BS_1 = #BQ == 0 and "ready"
        local BT = BS_1 or "limited: " .. table.concat(BQ, ", ")
        BK = "Unknown"
        pcall(function()
            local Br_1
            local Bq_1
            if tP(identifyexecutor) then
                Br_1, Bq_1 = identifyexecutor()
                local Bs = Br_1 ~= ""
                local Bt = type(Br_1) == "string" and Bs
                if Bt then
                    local Bs_1 = type(Bq_1) == "string" and Bq_1 ~= "" and Br_1 .. " " .. Bq_1
                    BK = Bs_1 or Br_1
                end
            end
        end)
        BN = os.clock()
        BI = function()
            local Bv = math.floor(os.clock() - BN)
            if Bv < 60 then
                return Bv .. "s"
            elseif Bv < 3600 then
                return string.format("%dm %ds", math.floor((Bv) / (60)), Bv % 60)
            else
                return string.format("%dh %dm", math.floor((Bv) / (3600)), math.floor((Bv % 3600) / (60)))
            end
        end
        local UserGroup = FA.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(BJ("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, BF), true)
        UserGroup:AddLabel(BJ("UserId", tostring(LocalPlayer.UserId), BR), true)
        UserGroup:AddLabel(BJ("Executor", BK .. "  " .. BT, BF), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(BJ("Session", BI(), BO), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                Fp(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                Fp("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = FA.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(BJ("Game", Fv, BR), true)
        Label2 = SessionGroup:AddLabel(BJ("Players", "0/0", BF), true)
        BD = tostring(game.JobId)
        local BR_1 = #BD > 18 and string.sub(BD, 1, 18) .. "..."
        local BS_3 = BR_1
        local BX = if BS_3 then 1 else 0
        local BV = 2772 * BX + 3648 * (1 - BX)
        local BW = 3725 * BX + 2854 * (1 - BX)
        if not ((BV * 2314 + BW * 1420 + BV * BW) % 16777213 == 5252395) then
            BS_3 = BD
        end
        local BR_2 = BS_3
        SessionGroup:AddLabel(BJ("Job", BR_2, BP), true)
        Label = SessionGroup:AddLabel(BJ("Ping", "0 ms", BO), true)
        SessionGroup:AddDivider()
        SessionGroup:AddButton({
            Text = "Rejoin Place",
            Func = function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        })
        SessionGroup:AddButton({
            Text = "Copy Job ID",
            Func = function()
                Fp(BD, "Copied Job ID")
            end
        })
        BG = task.spawn(function()
            local By_1
            local Bx_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(BJ("Session", BI(), BO))
                Label2:SetText(BJ("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), BF))
                Bx_1, By_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local Bx_2 = Bx_1 and By_1 .. " ms" or "n/a"
                Label:SetText(BJ("Ping", Bx_2, BO))
            end
        end)
        uf.Track(function()
            if coroutine.status(BG) ~= "dead" then
                task.cancel(BG)
            end
        end)
        local SocialsGroup = FA.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                Fp(Fw, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                Fp(Fo, "Copied website link")
            end
        })
    end
    FB_2()
    local function FB_3()
        local ma
        local l8
        local l9
        local mb
        local MovementGroup = FA.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = FA.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        mb = {}
        l9 = {}
        l8 = {}
        local l7 = {}
        ma = {}
        local function mc()
            for k, v in l8 do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(l8)
        end
        local function mg()
            for k, v in l9 do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(l9)
        end
        local function mk()
            for k, v in ma do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(ma)
        end
        local function mo(mp)
            if not mp:IsA("ProximityPrompt") then
                return
            end
            if mb[mp] == nil then
                mb[mp] = {
                    HoldDuration = mp.HoldDuration,
                    MaxActivationDistance = mp.MaxActivationDistance,
                    RequiresLineOfSight = mp.RequiresLineOfSight
                }
            end
            mp.HoldDuration = 0
            mp.MaxActivationDistance = 50
            mp.RequiresLineOfSight = false
        end
        local function mr()
            for k, v in mb do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(mb)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                mk()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                mg()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                mc()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                    pcall(mo, v)
                end
            else
                mr()
            end
        end)
        table.insert(l7, Workspace.DescendantAdded:Connect(function(mK)
            if Toggles.InstantProximityPrompt.Value then
                mo(mK)
            end
        end))
        table.insert(l7, RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if l8[v] == nil then
                        l8[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(l7, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local CO = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and CO then
                CO:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(l7, RunService.RenderStepped:Connect(function(m5)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local CR = Character and Character:FindFirstChildOfClass("Humanoid")
            local CS = Character
            if CS then
                CS = Character:FindFirstChild("HumanoidRootPart")
            end
            local CQ_1 = CS
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and CR then
                if l9[CR] == nil then
                    l9[CR] = CR.WalkSpeed
                end
                CR.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and CQ_1 and CR and CurrentCamera then
                if ma[CR] == nil then
                    ma[CR] = CR.PlatformStand
                end
                CR.PlatformStand = true
                local CS_4 = Vector3.zero
                local CY = if not UserInputService:GetFocusedTextBox() then 1 else 0
                if CY == 1 then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        CS_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        CS_4 -= CurrentCamera.CFrame.LookVector
                    end
                    local C0 = if UserInputService:IsKeyDown(Enum.KeyCode.A) then 1 else 0
                    if C0 == 1 then
                        CS_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        CS_4 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        CS_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        CS_4 -= Vector3.new(0, 1, 0)
                    end
                end
                CQ_1.AssemblyLinearVelocity = Vector3.zero
                if CS_4.Magnitude > 0 then
                    CQ_1.CFrame = CQ_1.CFrame + CS_4.Unit * Options.FlySpeed.Value * m5
                end
            end
        end))
        uf.Track(function()
            for k, v in l7 do
                v:Disconnect()
            end
            mc()
            mg()
            mk()
            mr()
        end)
    end
    FB_3()
    local function FB_4()
        local Ea, Eb, Ec, Ed, Ee, Ef, Eg, Eh, Ei, Ej, Label, El, Em, En
        El = {}
        Ef = {}
        Ec = nil
        Eh = false
        Ed = 0
        En = 0
        Ei = os.clock()
        local MenuGroup = FA.Settings:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        Ea = function()
            local CurrentCamera
            CurrentCamera = Workspace.CurrentCamera
            local C9 = not CurrentCamera or not tP(VirtualUser.CaptureController) or not tP(VirtualUser.ClickButton2)
            if C9 then
                return false
            end
            local C9_1 = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            end)
            if not C9_1 then
                return false
            end
            Ed += 1
            Ei = os.clock()
            pcall(function()
                Label:SetText("AFK triggers: " .. Ed)
            end)
            return true
        end
        Ej = function(nP)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not nP)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not nP
                end
            end)
            if not nP then
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
        Eg = function(n4)
            if n4.ClassName == "ParticleEmitter" or n4.ClassName == "Trail" or n4.ClassName == "Smoke" or n4.ClassName == "Fire" or n4.ClassName == "Sparkles" or n4.ClassName == "Explosion" or n4.ClassName == "Beam" then
                if El[n4] == nil then
                    El[n4] = n4.Enabled
                end
                pcall(function()
                    n4.Enabled = false
                end)
            end
        end
        Ee = function()
            for k, v in El do
                local Do = k
                local Dq = v
                if Do.Parent then
                    pcall(function()
                        Do.Enabled = Dq
                    end)
                end
            end
            table.clear(El)
            if Ec then
                pcall(function()
                    settings().Rendering.QualityLevel = Ec.Quality
                end)
                Lighting.GlobalShadows = Ec.Shadows
                Lighting.FogEnd = Ec.Fog
                Ec = nil
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(oj)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not oj)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(op)
                if op then
                    if not Ec then
                        Ec = {
                            Quality = settings().Rendering.QualityLevel,
                            Shadows = Lighting.GlobalShadows,
                            Fog = Lighting.FogEnd
                        }
                    end
                    pcall(function()
                        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                    end)
                    Lighting.GlobalShadows = false
                    Lighting.FogEnd = 9000000000
                    for k, v in Workspace:QueryDescendants("ParticleEmitter,Trail,Smoke,Fire,Sparkles,Beam") do
                        pcall(Eg, v)
                    end
                else
                    Ee()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        Ej(true)
        local ScriptGroup = FA.Settings:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiGameplayPause:OnChanged(function()
            Ej(Toggles.AntiGameplayPause.Value)
        end)
        if Toggles.AntiGameplayPause.Value then
            Ej(true)
        end
        table.insert(Ef, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                Ea()
            end
        end))
        table.insert(Ef, Workspace.DescendantAdded:Connect(function(oK)
            if Toggles.FpsBoost.Value then
                Eg(oK)
            end
        end))
        Eb = function(oO)
            if Eh or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            Eh = true
            local DG = En
            local DH_1 = pcall(function()
                if oO then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not DH_1 then
                Eh = false
                if not oO and DG == En then
                    task.delay(1.5, function()
                        if DG == En then
                            Eb(true)
                        end
                    end)
                end
            end
        end
        table.insert(Ef, TeleportService.TeleportInitFailed:Connect(function(o5)
            local DO
            if o5 == LocalPlayer and Eh then
                Eh = false
                DO = En
                task.delay(3, function()
                    if DO == En then
                        Eb(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local DW = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            if Library.Unloaded or not DW then
                return
            end
            table.insert(Ef, DW.ChildAdded:Connect(function(pk)
                if pk.Name == "ErrorPrompt" then
                    Eb(false)
                end
            end))
        end)
        Em = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    Ej(true)
                end
                local D1 = Toggles.AntiAfk.Value and os.clock() - Ei >= 60
                if D1 then
                    Ea()
                end
                task.wait(1)
            end
        end)
        uf.Track(function()
            En += 1
            for k, v in Ef do
                v:Disconnect()
            end
            pcall(task.cancel, Em)
            Ej(false)
            Ee()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    FB_4()
    local function FB_5()
        local Ff, Fg, Fh, Fi
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("TempoHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(FA.Settings)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/BuildASolarFarm")
        local Fj = SaveManager:BuildConfigSection(FA.Settings)
        Fi = function(pL, pM)
            local Er_1 = (pL == "Toggle" and Toggles or Options)[pM]
            local Eq_2 = type(Er_1) == "table" and Er_1.Type == pL
            return Eq_2 and Er_1 or nil
        end
        Fg = function(pV, pW)
            local Type = pW.Type
            if Type == "Toggle" then
                return { idx = pV, type = "Toggle", value = pW.Value == true }
            elseif Type == "Slider" then
                return { idx = pV, type = "Slider", value = tostring(pW.Value) }
            elseif Type == "Dropdown" then
                return { idx = pV, type = "Dropdown", multi = pW.Multi == true, value = pW.Value }
            elseif Type == "Input" then
                local Ey = pW.Value or ""
                return { idx = pV, type = "Input", text = tostring(Ey) }
            elseif Type == "ColorPicker" then
                return { idx = pV, type = "ColorPicker", value = pW.Value:ToHex(), transparency = pW.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = pV,
                    type = "KeyPicker",
                    mode = pW.Mode,
                    key = pW.Value,
                    modifiers = pW.Modifiers,
                    toggled = pW.Toggled
                }
            else
                return nil
            end
        end
        Ff = function()
            local EB = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local EC = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if EC then
                        local EC_1 = Fg(k, v)
                        if EC_1 then
                            EB[#EB + 1] = EC_1
                        end
                    end
                end
            end
            table.sort(EB, function(p5, p6)
                if p5.type ~= p6.type then
                    return p5.type < p6.type
                end
                return p5.idx < p6.idx
            end)
            return { objects = EB }
        end
        Fh = function(p8)
            local EV
            EV = nil
            local EW = type(p8) ~= "table" or type(p8.idx) ~= "string" or type(p8.type) ~= "string" or SaveManager.Ignore[p8.idx]
            if EW then
                return false
            end
            EV = Fi(p8.type, p8.idx)
            if not EV then
                return false
            end
            local EW_1 = pcall(function()
                if p8.type == "Input" then
                    if type(p8.text) ~= "string" then
                        return
                    end
                    EV:SetValue(p8.text)
                elseif p8.type == "ColorPicker" then
                    EV:SetValueRGB(Color3.fromHex(p8.value), p8.transparency)
                elseif p8.type == "KeyPicker" then
                    EV:SetValue({ p8.key, p8.mode, p8.modifiers })
                    if p8.mode == "Toggle" and p8.toggled ~= nil then
                        EV.Toggled = p8.toggled
                        EV:Update()
                    end
                else
                    EV:SetValue(p8.value)
                end
            end)
            return EW_1
        end
        Fj:AddDivider()
        Fj:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        Fj:AddButton("Export Config to Clipboard", function()
            local EZ_1
            local EY_1
            EY_1, EZ_1 = pcall(HttpService.JSONEncode, HttpService, Ff())
            if EY_1 then
                local EY_2 = (tP(setclipboard)) and setclipboard
                local E_ = EY_2
                if not E_ then
                    local EY_3 = (tP(toclipboard)) and toclipboard
                    E_ = EY_3 or nil
                end
                local EY_4 = E_
                local E__1 = type(EY_4) == "function" and pcall(EY_4, EZ_1)
                if E__1 then
                    Library:Notify("Config copied to clipboard", 6)
                    return
                end
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Failed to encode the config")
        end)
        Fj:AddButton("Import Config from Clipboard Text", function()
            local E7_1
            local E5 = Options.SaveManager_ImportSource.Value or ""
            local E5_1
            local E6 = tostring(E5):match("^%s*(.-)%s*$")
            if E6 == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            if #E6 > 262144 then
                Library:Notify("That config is too large")
                return
            end
            E5_1, E7_1 = pcall(HttpService.JSONDecode, HttpService, E6)
            local E6_1 = not E5_1 or type(E7_1) ~= "table" or type(E7_1.objects) ~= "table"
            if E6_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            if #E7_1.objects > 2048 then
                Library:Notify("That config has too many records")
                return
            end
            local E5_2 = 0
            for i, v in ipairs(E7_1.objects) do
                if Fh(v) then
                    E5_2 += 1
                end
            end
            if E5_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local E7_2 = E5_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(E5_2, E7_2), 6)
        end)
        ThemeManager:LoadDefault()
        SaveManager:LoadAutoloadConfig()
        if Options.RollDelay then
            tz.SetDelay(Options.RollDelay.Value)
        end
        if Options.BuyDelay then
            tr.SetDelay(Options.BuyDelay.Value)
        end
        if Options.BuyRarities then
            tr.SetRarities(Options.BuyRarities.Value)
        end
        if Options.BuyPanels then
            tr.SetPanels(Options.BuyPanels.Value)
        end
        if Options.BuyMaxCost then
            tr.SetMaxCost(Options.BuyMaxCost.Value)
        end
        if Toggles.BuyUnblock then
            tr.SetUnblock(Toggles.BuyUnblock.Value)
        end
        if Options.PlaceDelay then
            t9.SetDelay(Options.PlaceDelay.Value)
        end
        if Options.PlaceRarities then
            t9.SetRarities(Options.PlaceRarities.Value)
        end
        if Options.PlacePanels then
            t9.SetPanels(Options.PlacePanels.Value)
        end
        if Options.ZoneMaxCost then
            t4.SetMaxCost(Options.ZoneMaxCost.Value)
        end
        if Options.ZoneDelay then
            t4.SetDelay(Options.ZoneDelay.Value)
        end
        if Options.CollectDelay then
            uy.SetDelay(Options.CollectDelay.Value)
        end
        if Options.DepositDelay then
            uu.SetDelay(Options.DepositDelay.Value)
        end
        if Options.GeneratorDelay then
            tZ.SetDelay(Options.GeneratorDelay.Value)
        end
        if Options.GeneratorMaxLevel then
            tZ.SetMaxLevel(Options.GeneratorMaxLevel.Value)
        end
        if Options.CashDelay then
            un.SetDelay(Options.CashDelay.Value)
        end
        if Toggles.AutoRoll then
            tz.SetEnabled(Toggles.AutoRoll.Value)
        end
        if Toggles.AutoBuyRoll then
            tr.SetEnabled(Toggles.AutoBuyRoll.Value)
        end
        if Toggles.AutoPlacePanels then
            t9.SetEnabled(Toggles.AutoPlacePanels.Value)
        end
        if Toggles.AutoBuyPlot then
            t4.SetEnabled(Toggles.AutoBuyPlot.Value)
        end
        if Toggles.AutoCollectEnergy then
            uy.SetEnabled(Toggles.AutoCollectEnergy.Value)
        end
        if Toggles.AutoDepositEnergy then
            uu.SetEnabled(Toggles.AutoDepositEnergy.Value)
        end
        if Toggles.AutoCollectCash then
            un.SetEnabled(Toggles.AutoCollectCash.Value)
        end
        if Toggles.AutoUpgradeGenerator then
            tZ.SetEnabled(Toggles.AutoUpgradeGenerator.Value)
        end
        if Toggles.AutoDaily then
            ui.SetEnabled(Toggles.AutoDaily.Value)
        end
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    FB_5()
end
if (tB or false) and (not tM and not tM) and ((tB or tB) and (tB and tw)) or (not tw and false and (not tX or not tw) or tX and false and "SellUpgrades") or not ((tB or false) and (not tM and not tM) and ((tB or tB) and (tB and tw)) or (not tw and false and (not tX or not tw) or tX and false and "SellUpgrades")) then
    uH_2()
    uK()
else
    uK()
    uH_2()
end
end)(...)

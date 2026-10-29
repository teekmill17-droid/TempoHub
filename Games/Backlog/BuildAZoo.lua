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
getgenv().TempoHoodSubtitle = "BUILD A ZOO"
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
local h5
local iQ
local Library
local ib
local iW
local iD
local ResEgg
local i1
local connection
local iq
local iP
local iw
local Options
local iV
local iC
local connection2
local VirtualUser
local Asset
local ip
local h3
local iO
local PetRE
local ResPetFood
local Time
local CharacterRE
local ih
local i_
local iH
local io
local h2
local iN
local iu
local ReplicatedStorage
local iT
local iA
local ig
local iZ
local iG
local Label2
local h1
local iM
local it
local h7
local iS
local Pets2
local Toggles
local iY
local iF
local il
local iL
local is
local h6
local Label
local iy
local Label3
local iX
local Egg
local ik
local iK
local ir
local function fn21()
    local jR_1
    local jQ_1
    if identifyexecutor then
        jR_1, jQ_1 = identifyexecutor()
        local jS = jR_1 ~= ""
        local jT = type(jR_1) == "string" and jS
        if jT then
            local jS_1 = type(jQ_1) == "string" and jQ_1 ~= "" and jR_1 .. " " .. jQ_1
            ir = jS_1 or jR_1
        end
    end
end
local function fn36(R)
    local DiscordGroup = R:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = ih })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = ih })
end
local function autoSellPetsLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AutoSellPets.Value then
            pcall(iL)
        end
        if Toggles.AutoSellEggs.Value then
            pcall(iD)
        end
    end
end
local function fn92()
    iu(iP)
    Library:Notify("Copied Discord invite to clipboard")
end
local function onInputChanged(fI)
    local UserInputType = fI.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        iC = tick()
    end
end
local function fn103()
    local mC = {}
    for i, child in Pets2:GetChildren() do
        local mD = not child:GetAttribute("D") and not child:GetAttribute("BPV")
        if mD then
            table.insert(mC, child)
        end
    end
    return mC
end
local function fn107()
    ik(function()
        local no = i1()
        if not no then
            return
        end
        CharacterRE:FireServer("Focus", no)
        task.wait(0.2)
        for k, v in h2() do
            local np = Asset:GetAttribute(no) or 0
            if np <= 0 then
                return
            end
            PetRE:FireServer("Feed", v.model.Name)
            task.wait(0.15)
        end
    end)
end
local function fn122(a7)
    local j5_1
    local j4_1
    if is then
        return false
    end
    is = true
    j4_1, j5_1 = pcall(a7)
    is = false
    if not j4_1 then
        error(j5_1, 0)
    end
    return true
end
local function fn127()
    ik(function()
        local Value = Options.ReplaceStat.Value
        local mM
        local mN
        for k, v in h2() do
            local mO_1 = it(v.entry, Value)
            if mN == nil or mO_1 < mN then
                mM = v
                mN = mO_1
            end
        end
        local mP_2 = nil
        local mO_2 = nil
        for k, v in ib() do
            local mQ_1 = it(v, Value)
            if mO_2 == nil or mQ_1 > mO_2 then
                mP_2 = v
                mO_2 = mQ_1
            end
        end
        local mL_1 = not mP_2
        local mQ_2 = not mM
        local m6 = if mQ_2 then 1 else 0
        local m4 = 3011 * m6 + 359 * (1 - m6)
        local m5 = 3135 * m6 + 2087 * (1 - m6)
        if not ((m4 * 284 + m5 * 1905 + m4 * m5) % 16777213 == 16266784) then
            mQ_2 = mL_1
        end
        if mQ_2 then
            return
        end
        if mO_2 <= mN * (1 + Options.ReplaceImprovement.Value / 100) then
            return
        end
        local Position = mM.model.Position
        local attr = Time:GetAttribute("s")
        local mO_3 = not attr
        local m9 = if mO_3 then 1 else 0
        local m7 = 2032 * m9 + 2862 * (1 - m9)
        local m8 = 1371 * m9 + 3989 * (1 - m9)
        if not ((m7 * 1798 + m8 * 784 + m7 * m8) % 16777213 == 7514272) then
            mO_3 = Time.Value <= 0
        end
        if mO_3 then
            return
        end
        CharacterRE:FireServer("Del", mM.model.Name, bit32.bxor(iS.UserId, attr, Time.Value))
        local mN_2 = os.clock()
        while true do
            local mO_4 = mM.model.Parent and os.clock() - mN_2 < 3
            if mO_4 then
                task.wait(0.1)
                continue
            end
            break
        end
        if mM.model.Parent then
            return
        end
        CharacterRE:FireServer("Focus", mP_2.Name)
        task.wait(0.2)
        CharacterRE:FireServer("Place", { DST = Position, ID = mP_2.Name })
    end)
end
local function fn129(ds, dt)
    local mp = ds:GetAttributes()
    if dt == "Weight" then
        local mq_1 = tonumber(iX:GetWeight(mp.T, mp.V, mp.Elite)) or 0
        return mq_1
    end
    local mq_2 = tonumber(iX:GetPetProduce(mp, 1)) or 0
    return mq_2
end
local function fn133()
    local attr = iS:GetAttribute("AssignedIslandName")
    if not attr then
        return nil
    end
    local j8 = workspace:FindFirstChild("Art") and workspace.Art:FindFirstChild(attr)
    return j8, attr
end
local function fn143()
    local nA = iY()
    if not nA then
        return 0
    end
    local nB = iQ(nA)
    local nC = h5()
    local nD = 0
    for i, child in nA:GetChildren() do
        local nA_1 = child:IsA("BasePart") and string.match(child.Name, "^Farm_split")
        if nA_1 then
            local Position = child.Position
            local nE = false
            for k, v in nB do
                local nF_1 = math.abs(Position.X - v.position.X) <= v.size.X * 0.5 and math.abs(Position.Z - v.position.Z) <= v.size.Z * 0.5
                if nF_1 then
                    nE = true
                    break
                end
            end
            if not nE then
                for k, v in nC do
                    local nF_2 = math.abs(v.X - Position.X) < 4 and math.abs(v.Z - Position.Z) < 4
                    if nF_2 then
                        nE = true
                        break
                    end
                end
            end
            if not nE then
                nD = nD + 1
            end
        end
    end
    return nD
end
local function fn151(bg)
    for k in bg do
        return true
    end
    return false
end
local function fn152(aa, ab, ac)
    return string.format("<b>%s</b> %s %s", aa, il("-", "#5a6070"), il(ab, ac))
end
local function autoReplacePetsLoop()
    while not Library.Unloaded do
        task.wait(Options.ReplaceDelay.Value)
        if Toggles.AutoReplacePets.Value then
            pcall(iM)
        end
    end
end
local function fn173(a3, a4)
    if a3 == "Any" then
        return true
    elseif a4 == "Any" then
        return false
    else
        return a3 < a4
    end
end
local function fn201(X, Y)
    return string.format('<font color="%s">%s</font>', Y, X)
end
local function worker2()
    while not Library.Unloaded do
        task.wait(2)
        local n1 = Asset:GetAttribute("Coin") or 0
        Label2:SetText(h7("Coins", tostring(n1), iA))
        Label3:SetText(h7("Free tiles", tostring(iZ()), iG))
    end
end
local function autoFeedPetsLoop()
    while not Library.Unloaded do
        task.wait(Options.FeedDelay.Value)
        if Toggles.AutoFeedPets.Value then
            pcall(iV)
        end
    end
end
local function fn281()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    iw = tick()
end
local function fn293(bY)
    local kT = {}
    for k, v in iy(bY) do
        table.insert(kT, { position = v.Position, size = v.Size })
    end
    return kT
end
local function fn295(bP)
    local kJ = {}
    local ENV = bP:FindFirstChild("ENV")
    local kL = ENV and ENV:FindFirstChild("Locks")
    if not kL then
        return kJ
    end
    for i, child in kL:GetChildren() do
        local Farm = child:FindFirstChild("Farm")
        local kL_1 = Farm and Farm:GetAttribute("Unlock") == false
        if kL_1 then
            table.insert(kJ, Farm)
        end
    end
    return kJ
end
local function fn297()
    local k4_1
    local k3_1
    local k0 = iY()
    if not k0 then
        return
    end
    local k1 = Asset:GetAttribute("Coin") or 0
    k4_1, k3_1 = nil, nil
    for k, v in iy(k0) do
        local attr = v:GetAttribute("LockCost")
        if attr and (not k3_1 or attr < k3_1) then
            k4_1 = v
            k3_1 = attr
        end
    end
    if k4_1 and k3_1 <= k1 then
        CharacterRE:FireServer("Unlock", k4_1)
    end
end
local function autoBuyEggLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AutoBuyEgg.Value then
            pcall(h3)
        end
    end
end
local function fn315()
    local ms = {}
    local Pets = workspace:FindFirstChild("Pets")
    if not Pets then
        return ms
    end
    for i, child in Pets:GetChildren() do
        local mt_1 = child:GetAttribute("UserId") == iS.UserId and child:HasTag("IdlePet")
        if mt_1 then
            local mt_2 = Pets2:FindFirstChild(child.Name)
            local mu = mt_2 and not mt_2:GetAttribute("BPV")
            if mu then
                table.insert(ms, { entry = mt_2, model = child })
            end
        end
    end
    return ms
end
local function fn323(bj, bk)
    local kf = ResEgg[bj]
    local Value2
    if not kf then
        return false
    end
    local Value4 = Options.EggRarities.Value
    local kg_4, kg_6
    if iF(Value4) then
        local kh_1 = false
        for k in Value4 do
            if iT[k] == kf.Rarity then
                kh_1 = true
                break
            end
        end
        if not kh_1 then
            return false
        end
        local Value3 = Options.EggTypes.Value
        if iF(Value2) then
            for k in Value3 do
                if iO[k] == bj then
                    break
                end
            end
            if not kg_4 then
                return false
            end
            local Value = Options.EggMutations.Value
            local kg_2 = (iF(Value))
            if kg_6 then
                return false
            end
            return true
        end
        local Value = Options.EggMutations.Value
        local kg_3 = (iF(Value))
        if kg_6 then
            return false
        end
        return true
    end
    Value2 = Options.EggTypes.Value
    if iF(Value2) then
        kg_4 = false
        for k in Value2 do
            if iO[k] == bj then
                kg_4 = true
                break
            end
        end
        if not kg_4 then
            return false
        end
        local Value = Options.EggMutations.Value
        local kg_5 = (iF(Value))
        if kg_6 then
            return false
        end
        return true
    end
    local Value = Options.EggMutations.Value
    kg_6 = (iF(Value))
    if kg_6 then
        kg_6 = not Value[bk or "Base"]
    end
    if kg_6 then
        return false
    end
    return true
end
local function worker()
    local jZ_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local jY = math.floor(os.clock() - ig)
        if jY < 60 then
            jZ_1 = jY .. "s"
        elseif jY < 3600 then
            jZ_1 = string.format("%dm %ds", math.floor((jY) / (60)), jY % 60)
        else
            jZ_1 = string.format("%dh %dm", math.floor((jY) / (3600)), math.floor((jY % 3600) / (60)))
        end
        Label:SetText(h7("Session time", jZ_1, iA))
    end
end
local function onUnload()
    Library:Unload()
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local oo = tick() - iC
            local op = tick() - iw
            if oo >= 300 and op >= 60 then
                pcall(h6)
            else
                if oo < 300 and op >= 300 then
                    pcall(h6)
                end
            end
        end
    end
end
local function fn345()
    local lt = iY()
    if not lt then
        return nil
    end
    local lu = iQ(lt)
    local lv = h5()
    for i, child in lt:GetChildren() do
        local lt_1 = child:IsA("BasePart") and string.match(child.Name, "^Farm_split")
        if lt_1 then
            local Position = child.Position
            local lw = false
            for k, v in lu do
                local lx_1 = math.abs(Position.X - v.position.X) <= v.size.X * 0.5 and math.abs(Position.Z - v.position.Z) <= v.size.Z * 0.5
                if lx_1 then
                    lw = true
                    break
                end
            end
            if not lw then
                for k, v in lv do
                    local lx_2 = math.abs(v.X - Position.X) < 4 and math.abs(v.Z - Position.Z) < 4
                    if lx_2 then
                        lw = true
                        break
                    end
                end
            end
            if not lw then
                return child
            end
        end
    end
    return nil
end
local function fn357(J)
    if setclipboard then
        setclipboard(J)
    elseif toclipboard then
        toclipboard(J)
    end
end
local function fn375()
    ik(function()
        for i, child in Egg:GetChildren() do
            if not child:GetAttribute("D") then
                local lR = ip()
                if not lR then
                    return
                end
                CharacterRE:FireServer("Focus", child.Name)
                task.wait(0.2)
                CharacterRE:FireServer("Place", { DST = lR.Position + Vector3.new(0, lR.Size.Y * 0.5, 0), ID = child.Name })
                task.wait(0.6)
            end
        end
    end)
end
local function fn395()
    PetRE:FireServer("SellAll", "All", "Pet")
end
local function autoHatchEggLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AutoHatchEgg.Value then
            pcall(i_)
        end
    end
end
local function fn409()
    PetRE:FireServer("SellAll", "All", "Egg")
end
local function fn478()
    local Value = Options.FeedFood.Value
    local nb = Value ~= "Any"
    if nb then
        local nc_1 = (Asset:GetAttribute(Value))
        local nh = if nc_1 then 1 else 0
        local nf = 3670 * nh + 2983 * (1 - nh)
        local ng = 3809 * nh + 1307 * (1 - nh)
        if not ((nf * 1436 + ng * 3201 + nf * ng) % 16777213 == 14664546) then
            nc_1 = 0
        end
        nb = nc_1 > 0
    end
    if nb then
        return Value
    end
    local nb_1 = nil
    local na_1 = nil
    for k, v in ResPetFood.__index do
        local nc_2 = Asset:GetAttribute(v) or 0
        if nc_2 > 0 then
            local nc_3 = ResPetFood[v]
            local nd_1 = nc_3 and nc_3.FeedValue or 0
            if na_1 == nil or nd_1 > na_1 then
                nb_1 = v
                na_1 = nd_1
            end
        end
    end
    return nb_1
end
local function onCopyJoinScript_JobID()
    iu(string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, iN))
    Library:Notify("Copied join script to clipboard")
end
local function onRscripts()
    iu(iK)
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function fn510()
    local kz_1
    local ky_1
    ky_1, kz_1 = iY()
    if not kz_1 then
        return
    end
    local Eggs = ReplicatedStorage:FindFirstChild("Eggs")
    local kA = Eggs and Eggs:FindFirstChild(kz_1)
    if not kA then
        return
    end
    local kz_2 = Asset:GetAttribute("Coin") or 0
    local kA_1 = kz_2
    for i, child in kA:GetChildren() do
        local attr2 = child:GetAttribute("T")
        local attr = child:GetAttribute("M")
        local kB = attr2 and iq(attr2, attr)
        if kB then
            local kB_1 = h1:GetPrice({ T = attr2, M = attr })
            if kB_1 and kA_1 >= kB_1 then
                CharacterRE:FireServer("BuyEgg", child.Name, true)
                kA_1 = kA_1 - kB_1
                task.wait(0.15)
            end
        end
    end
end
local function autoBuyTileLoop()
    while not Library.Unloaded do
        task.wait(3)
        if Toggles.AutoBuyTile.Value then
            pcall(io)
        end
    end
end
local function autoPlaceEggLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AutoPlaceEgg.Value then
            pcall(iW)
        end
    end
end
local function onInputBegan()
    iC = tick()
end
local function autoClaimCoinLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AutoClaimCoin.Value then
            pcall(iH)
        end
    end
end
local function fn613()
    connection:Disconnect()
    connection2:Disconnect()
end
h1 = nil
h2 = nil
h3 = nil
h5 = nil
h6 = nil
h7 = nil
ReplicatedStorage = nil
ResPetFood = nil
Options = nil
ib = nil
Label3 = nil
Toggles = nil
ig = nil
ih = nil
connection2 = nil
ResEgg = nil
ik = nil
il = nil
Label2 = nil
io = nil
ip = nil
iq = nil
ir = nil
is = nil
it = nil
iu = nil
PetRE = nil
iw = nil
Library = nil
iy = nil
Pets2 = nil
iA = nil
CharacterRE = nil
iC = nil
iD = nil
Egg = nil
iF = nil
iG = nil
iH = nil
Asset = nil
connection = nil
iK = nil
iL = nil
iM = nil
iN = nil
iO = nil
iP = nil
iQ = nil
Label = nil
local h4
iS = nil
iT = nil
Time = nil
iV = nil
iW = nil
iX = nil
iY = nil
iZ = nil
i_ = nil
VirtualUser = nil
i1 = nil
local jh, ji, jj, jk, jl, jm
local i6_1
local i5_1, SocialsGroup
local Players = game:GetService("Players")
local i3_2, FaqGroup
local i4 = Players.LocalPlayer or Players.PlayerAdded:Wait()
local AccountGroup
iS = i4
local function i2()
    return iS:WaitForChild("PlayerGui")
end
if getgenv then
    getgenv().gethui = i2
end
Library, Toggles, Options, ReplicatedStorage, VirtualUser, iP, iK, CharacterRE, PetRE, ResEgg, ResPetFood, h1, iX, Time, Asset, Egg, Pets2, iu, ih = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
_G.gethui = i2
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
local jb = "Build a Zoo"
iP = "https://discord.gg/K7Qxnxkk46"
iK = "https://discord.gg/K7Qxnxkk46"
local i7 = ReplicatedStorage:WaitForChild("Remote")
CharacterRE = i7:WaitForChild("CharacterRE")
PetRE = i7:WaitForChild("PetRE")
local Config = ReplicatedStorage:WaitForChild("Config")
ResEgg = require(Config:WaitForChild("ResEgg"))
local ResMutate = require(Config:WaitForChild("ResMutate"))
ResPetFood = require(Config:WaitForChild("ResPetFood"))
local Shared = require(ReplicatedStorage:WaitForChild("Shared"))
h1 = Shared("ItemUtil")
iX = Shared("Pet")
Time = ReplicatedStorage:WaitForChild("Time")
local Data = iS:WaitForChild("PlayerGui"):WaitForChild("Data")
local FeaturesGroup
Asset = Data:WaitForChild("Asset")
Egg = Data:WaitForChild("Egg")
Pets2 = Data:WaitForChild("Pets")
iu = fn357
ih = fn92
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = iP, Copyable = true }, "|", jb },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local ScriptsGroup
local jg = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "egg"),
    Settings = Window:AddTab("Settings", "settings")
}
jg.Eggs = jg.Main:AddSubTab("Eggs", "shopping-cart")
jg.Farm = jg.Main:AddSubTab("Farm", "trees")
jg.Pets = jg.Main:AddSubTab("Pets", "paw-print")
local ja_2, MenuGroup
for k, v in jg do
    if v ~= jg.Main then
        fn36(v)
    end
end
i3_2, iG, iA, i6_1, ir, AccountGroup, i7, Label, iN, i5_1, il, h7 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local i2_1 = 40
repeat
    local i8_1 = (i2_1 * 5 + 5) % 8 + 1
    if i8_1 <= 4 then
        if i8_1 <= 2 then
            if i8_1 <= 1 then
                local i9_1 = {
                    "etrk",
                    "lneypptll",
                    "wmtoujchoim",
                    "twvfhkmftwp",
                    "mjxwxdjbk",
                    "kas",
                    "vgu",
                    "rvmrlzsoz",
                    "kcdwnpac",
                    "dssfs"
                }
                local o9 = i2_1
                local ja_1 = i9_1[o9 % 10 + 1]
                if ja_1:len() <= ja_1:gsub("(.)", "%1%1", o9 % 3 % 2 + 1):len() then
                    iG = "#6ec1ff"
                else
                    iA = "#6ec1ff"
                end
                i2_1 = (i2_1 + 13) % 64
            else
                local pG = bit32.rrotate(bit32.bxor(bit32.lrotate(i2_1, 2), string.byte(tostring(i7))), 11)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(pG, 3074170847), 2558512703), (bit32.bxor(bit32.band(pG, 1220796448), 2304529283))), 2558512703), 2304529283) == pG then
                    iA = "#e8a34d"
                else
                    iG = "#e8a34d"
                end
                i2_1 = (i2_1 + 5) % 64
            end
        elseif i8_1 <= 3 then
            if i2_1 * 24528721 + 8 + 7 <= i2_1 * 24528721 + 8 + 7 + 2 then
                i6_1 = "#8b93a3"
                ir = "Unknown"
                pcall(fn21)
                AccountGroup = jg.Info:AddLeftGroupbox("Account", "circle-user")
                AccountGroup:AddLabel(h7("User", iS.Name, i3_2), true)
                AccountGroup:AddLabel(h7("Status", "Keyless", i3_2), true)
                AccountGroup:AddLabel(h7("Executor", ir, i3_2), true)
                i7 = jg.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                i7:AddLabel(il(jb .. " [" .. tostring(game.PlaceId) .. "]", iG), true)
                i7:AddLabel(h7("Place ID", tostring(game.PlaceId), iG), true)
                Label = i7:AddLabel(h7("Session time", "0s", iA), true)
            else
                i3_2 = "#8b93a3"
                il = "Unknown"
                pcall(fn21)
                jg = i7.Info:AddLeftGroupbox("Account", "circle-user")
                jg:AddLabel(jb("User", h7.Name, iG), true)
                jg:AddLabel(jb("Status", "Keyless", iG), true)
                jg:AddLabel(jb("Executor", il, iG), true)
                i6_1 = i7.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                i6_1:AddLabel(iS(AccountGroup .. " [" .. tostring(game.PlaceId) .. "]", ir), true)
                i6_1:AddLabel(jb("Place ID", tostring(game.PlaceId), ir), true)
                iA = i6_1:AddLabel(jb("Session time", "0s", Label), true)
            end
            i2_1 = (i2_1 + 13) % 64
        else
            if i2_1 * 5259291 + 1 + 7 >= i2_1 * 5259291 + 1 + 7 + 6 then
                i3_2 = tostring(game.JobId)
            else
                iN = tostring(game.JobId)
            end
            i2_1 = (i2_1 + 61) % 64
        end
    elseif i8_1 <= 6 then
        if i8_1 <= 5 then
            local i9_2 = { "pkokx", "rclvf", "iqpocpklqmod", "lial", "bfgycvk", "etbwbrkjjs", "dxucilkqd", "msvrcobjf" }
            if i9_2[(i2_1 * 78 + 103) % 8 + 1] <= i9_2[(i2_1 * 78 + 103) % 8 + 1] then
                i5_1 = #iN > 18
            else
                iN = #i5_1 > 18
            end
            i2_1 = (i2_1 + 45) % 64
        else
            local i9_3 = {
                "klyytldby",
                "wmbtjdpmcgg",
                "agh",
                "kraezijqrkfy",
                "skwhrftusq",
                "uuffbn",
                "uknfk",
                "ykqxix",
                "ofmlylnjhgg",
                "kxvrfuaxuay",
                "jokxzbijkc",
                "xrh"
            }
            if i9_3[(i2_1 * 88 + 15) % 12 + 1] <= i9_3[(i2_1 * 88 + 15) % 12 + 1] then
                il = fn201
            else
                i5_1 = fn201
            end
            i2_1 = (i2_1 + 21) % 64
        end
    elseif i8_1 <= 7 then
        local i8_2 = (vector.create((i2_1 * 7 + 6) % 11 + 1, (i2_1 * 1 + 10) % 13 + 1, (i2_1 * 9 + 15) % 17 + 1))
        local i9_4 = (vector.create((i2_1 * 5 + 1) % 11 + 1, (i2_1 * 1 + 13) % 13 + 1, (i2_1 * 6 + 6) % 17 + 1))
        local pv = vector.cross(i8_2, i9_4)
        local pw = vector.dot(i8_2, i9_4)
        if vector.dot(pv, pv) + pw * pw == vector.dot(i8_2, i8_2) * vector.dot(i9_4, i9_4) then
            h7 = fn152
        else
            iA = fn152
        end
        i2_1 = (i2_1 + 53) % 64
    else
        if (i2_1 * 1 + 5) * 5 % 4 == ((i2_1 * 1 + 5) * 5 + 13) % 4 then
            i7 = "#7fd47f"
        else
            i3_2 = "#7fd47f"
        end
        i2_1 = (i2_1 + 29) % 64
    end
until (i2_1 * 19 + 30) % 64 == 38
if i5_1 then
    local i2_2 = 2
    repeat
        if (i2_2 * 2 + 1) * 7 % 3 == ((i2_2 * 2 + 1) * 7 + 0) % 3 then
            i5_1 = string.sub(iN, 1, 18) .. "..."
        else
            iN = string.sub(i5_1, 1, 18) .. "..."
        end
        i2_2 = (i2_2 + 0) % 4
    until (i2_2 * 3 + 2) % 4 == 0
end
local i2_3 = i5_1
local jx = if i2_3 then 1 else 0
local jv = 1445 * jx + 3790 * (1 - jx)
local jw = 2746 * jx + 3274 * (1 - jx)
if not ((jv * 3645 + jw * 3713 + jv * jw) % 16777213 == 2653680) then
    i2_3 = iN
end
ja_2, ig, jh, ScriptsGroup, FeaturesGroup, SocialsGroup, FaqGroup, ji, jk, iT, iO, jj = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local i4_3 = 5
repeat
    jl = (i4_3 * 4 + 4) % 5 + 1
    if jl <= 3 then
        if jl <= 2 then
            if jl <= 1 then
                jm = (vector.create((i4_3 * 3 + 9) % 11 + 1, (i4_3 * 3 + 5) % 13 + 1, (i4_3 * 3 + 17) % 17 + 1))
                local jn = (vector.create((i4_3 * 4 + 1) % 11 + 1, (i4_3 * 8 + 12) % 13 + 1, (i4_3 * 9 + 14) % 17 + 1))
                local pa = vector.dot(jm, jn)
                if pa * pa <= vector.dot(jm, jm) * vector.dot(jn, jn) then
                    task.spawn(worker)
                    jh = jg.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
                else
                    task.spawn(worker)
                    jg = jh.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
                end
                i4_3 = (i4_3 + 14) % 20
            else
                jm = {
                    "wqgqahfnbmbs",
                    "gqzhsxn",
                    "wzyinohheksp",
                    "bxlzoyk",
                    "gtyvpi",
                    "ikprdwuvxvaa",
                    "dlwo",
                    "szkvtsyfklox",
                    "znyokmmsdx",
                    "kyfyeib",
                    "hyqgqhpwvr",
                    "ryprzmzihqy"
                }
                if jm[(i4_3 * 60 + 73) % 12 + 1] <= jm[(i4_3 * 60 + 73) % 12 + 1] then
                    jh:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
                    jh:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
                    jh:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
                    jh:AddButton({ Text = "Copy Discord Invite", Func = ih })
                    ScriptsGroup = jg.Info:AddRightGroupbox("Scripts", "package")
                    ScriptsGroup:AddLabel(il("Included in this hub", i6_1), true)
                    ScriptsGroup:AddLabel(il(jb, iG), true)
                    FeaturesGroup = jg.Info:AddRightGroupbox("Features", "list")
                    FeaturesGroup:AddLabel(il("Auto Buy Eggs", iG), true)
                    FeaturesGroup:AddLabel(il("Auto Place Eggs", iG), true)
                    FeaturesGroup:AddLabel(il("Auto Hatch Eggs", iA), true)
                    FeaturesGroup:AddLabel(il("Auto Claim Coins", iA), true)
                    FeaturesGroup:AddLabel(il("Auto Buy Tiles", iA), true)
                    FeaturesGroup:AddLabel(il("Misc Utilities", i6_1), true)
                    SocialsGroup = jg.Info:AddRightGroupbox("Socials", "link")
                    SocialsGroup:AddButton({ Text = "Discord", Func = ih })
                    SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
                    FaqGroup = jg.Info:AddRightGroupbox("FAQ", "circle-help")
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
                    ji = {
                        [1] = "Basic",
                        [2] = "Rare",
                        [3] = "Legend",
                        [4] = "Hyper",
                        [5] = "Void",
                        [6] = "Ultra",
                        [7] = "Limited",
                        [8] = "Admin"
                    }
                else
                    FaqGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
                    FaqGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
                    FaqGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
                    FaqGroup:AddButton({ Text = "Copy Discord Invite", Func = jg })
                    jh = ScriptsGroup.Info:AddRightGroupbox("Scripts", "package")
                    jh:AddLabel(SocialsGroup("Included in this hub", iA), true)
                    jh:AddLabel(SocialsGroup(iG, jb), true)
                    il = ScriptsGroup.Info:AddRightGroupbox("Features", "list")
                    il:AddLabel(SocialsGroup("Auto Buy Eggs", jb), true)
                    il:AddLabel(SocialsGroup("Auto Place Eggs", jb), true)
                    il:AddLabel(SocialsGroup("Auto Hatch Eggs", FeaturesGroup), true)
                    il:AddLabel(SocialsGroup("Auto Claim Coins", FeaturesGroup), true)
                    il:AddLabel(SocialsGroup("Auto Buy Tiles", FeaturesGroup), true)
                    il:AddLabel(SocialsGroup("Misc Utilities", iA), true)
                    i6_1 = ScriptsGroup.Info:AddRightGroupbox("Socials", "link")
                    i6_1:AddButton({ Text = "Discord", Func = jg })
                    i6_1:AddButton({ Text = "Rscripts", Func = onRscripts })
                    ji = ScriptsGroup.Info:AddRightGroupbox("FAQ", "circle-help")
                    ji:AddLabel("Where do I get a good config?", true)
                    ji:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
                    ji:AddLabel("How do I import / export configs?", true)
                    ji:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
                    ji:AddLabel("How do I report bugs?", true)
                    ji:AddLabel("Join the Discord and post it in the bugs channel.", true)
                    ji:AddLabel("How do I make suggestions?", true)
                    ji:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
                    ji:AddLabel("How do I get help or updates?", true)
                    ji:AddLabel("Join the Discord, updates and support are posted there first.", true)
                    ih = {
                        [1] = "Basic",
                        [6] = "Ultra",
                        [8] = "Admin",
                        [5] = "Void",
                        [7] = "Limited",
                        [4] = "Hyper",
                        [2] = "Rare",
                        [3] = "Legend"
                    }
                end
                i4_3 = (i4_3 + 19) % 20
            end
        else
            if (i4_3 * 1 + 5) * 9 % 4 == ((i4_3 * 1 + 5) * 9 + 12) % 4 then
                jk = {}
            else
                jh = {}
            end
            i4_3 = (i4_3 + 4) % 20
        end
    elseif jl <= 4 then
        if i4_3 * 49423053 + 11 + 6 <= i4_3 * 49423053 + 11 + 6 + 1 then
            iT = {}
            iO = {}
            jj = {}
        else
            jj = {}
            iT = {}
            iO = {}
        end
        i4_3 = (i4_3 + 14) % 20
    else
        if i4_3 * 18029419 + 12 + 1 <= i4_3 * 18029419 + 12 + 1 + 2 then
            ja_2 = i2_3
            i7:AddLabel(h7("Server", ja_2, i6_1), true)
            i7:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
            ig = os.clock()
        else
            i7 = i6_1
            ig:AddLabel(ja_2("Server", i7, i2_3), true)
            ig:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
            h7 = os.clock()
        end
        i4_3 = (i4_3 + 9) % 20
    end
until (i4_3 * 13 + 0) % 20 == 5
jl = {}
for k, v in ResEgg.__index do
    local i2_4 = ResEgg[v]
    if i2_4 then
        local Rarity = i2_4.Rarity
        if not jl[Rarity] then
            jl[Rarity] = true
            local format = string.format
            local i5_3 = ji[Rarity] or "Unknown"
            local i6_2 = format("%d - %s", Rarity, i5_3)
            iT[i6_2] = Rarity
            table.insert(jk, i6_2)
        end
        local i3_5 = i2_4.SearchName or v
        if not iO[i3_5] then
            iO[i3_5] = v
            table.insert(jj, i3_5)
        end
    end
end
table.sort(jk)
table.sort(jj)
local i2_6 = { "Base" }
for k, v in ResMutate.__index do
    table.insert(i2_6, v)
end
local i3_6 = { "Any" }
for k, v in ResPetFood.__index do
    table.insert(i3_6, v)
end
is, h4, Label2, Label3, MenuGroup, iC, iw, connection, connection2, ik, iY, iF, iq, h3, iy, iQ, io, h5, ip, iW, i_, iH, iL, iD, it, h2, ib, iM, i1, iV, iZ, h6 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
table.sort(i3_6, fn173)
is = false
ik = fn122
iY = fn133
iF = fn151
iq = fn323
h3 = fn510
iy = fn295
iQ = fn293
io = fn297
h5 = function()
    local lf_1
    local le_1
    local ld = {}
    for k, v in { workspace:FindFirstChild("Pets"), workspace:FindFirstChild("PlayerBuiltBlocks") } do
        if v then
            for i, child in v:GetChildren() do
                local ls = child
                le_1, lf_1 = pcall(function()
                    return ls:GetPivot().Position
                end)
                if le_1 then
                    table.insert(ld, lf_1)
                end
            end
        end
    end
    return ld
end
ip = fn345
iW = fn375
h4 = {}
i_ = function()
    local PlayerBuiltBlocks = workspace:FindFirstChild("PlayerBuiltBlocks")
    if not PlayerBuiltBlocks then
        return
    end
    local l0 = workspace:GetServerTimeNow()
    for i, child in Egg:GetChildren() do
        local l9 = child
        local attr = l9:GetAttribute("ET")
        local l2 = l9:GetAttribute("D") and attr and l0 >= attr and not h4[l9.Name]
        if l2 then
            local l1_1 = PlayerBuiltBlocks:FindFirstChild(l9.Name)
            local l2_1 = l1_1 and l1_1:FindFirstChild("RF", true)
            local lZ = l2_1
            if lZ then
                h4[l9.Name] = true
                task.spawn(function()
                    pcall(function()
                        lZ:InvokeServer("Hatch")
                    end)
                    h4[l9.Name] = nil
                end)
            end
        end
    end
end
iH = function()
    local Pets = workspace:FindFirstChild("Pets")
    local Character = iS.Character
    local me = Character and Character:FindFirstChild("HumanoidRootPart")
    local md_1 = not Pets
    local mb = me
    local mi = if md_1 then 1 else 0
    local mg = 670 * mi + 2482 * (1 - mi)
    local mh = 2521 * mi + 105 * (1 - mi)
    if not ((mg * 125 + mh * 3213 + mg * mh) % 16777213 == 9872793) then
        md_1 = not mb
    end
    if not md_1 then
        md_1 = not firetouchinterest
    end
    if md_1 then
        return
    end
    for i, child in Pets:GetChildren() do
        if child:GetAttribute("UserId") == iS.UserId then
            local TrgIdle = child:FindFirstChild("TrgIdle")
            if TrgIdle then
                pcall(function()
                    firetouchinterest(mb, TrgIdle, 0)
                    firetouchinterest(mb, TrgIdle, 1)
                end)
            end
        end
    end
end
iL = fn395
iD = fn409
it = fn129
h2 = fn315
ib = fn103
iM = fn127
i1 = fn478
iV = fn107
jb = jg.Eggs:AddLeftGroupbox("Auto Buy", "shopping-cart")
jb:AddToggle("AutoBuyEgg", { Text = "Auto Buy Egg", Default = false })
jb:AddDropdown("EggRarities", { Values = jk, Default = {}, Multi = true, Text = "Rarities" })
jb:AddDropdown("EggMutations", { Values = i2_6, Default = {}, Multi = true, Text = "Mutations" })
local EggTypesGroup = jg.Eggs:AddRightGroupbox("Egg Types", "list")
EggTypesGroup:AddDropdown("EggTypes", { Values = jj, Default = {}, Multi = true, Searchable = true, Text = "Egg Types" })
local AutomationGroup = jg.Farm:AddLeftGroupbox("Automation", "trees")
AutomationGroup:AddToggle("AutoPlaceEgg", { Text = "Auto Place Egg", Default = false })
AutomationGroup:AddToggle("AutoHatchEgg", { Text = "Auto Hatch Egg", Default = false })
AutomationGroup:AddToggle("AutoClaimCoin", { Text = "Auto Claim Coins", Default = false })
AutomationGroup:AddToggle("AutoBuyTile", { Text = "Auto Buy Tiles", Default = false })
i7 = jg.Farm:AddRightGroupbox("Farm", "chart-column")
Label2 = i7:AddLabel(h7("Coins", "0", iA), true)
Label3 = i7:AddLabel(h7("Free tiles", "0", iG), true)
local AutoSellGroup = jg.Pets:AddLeftGroupbox("Auto Sell", "badge-dollar-sign")
AutoSellGroup:AddToggle("AutoSellPets", { Text = "Auto Sell Pets", Default = false })
AutoSellGroup:AddToggle("AutoSellEggs", { Text = "Auto Sell Eggs", Default = false })
local AutoFeedGroup = jg.Pets:AddLeftGroupbox("Auto Feed", "apple")
AutoFeedGroup:AddDropdown("FeedFood", { Values = i3_6, Default = "Any", Searchable = true, Text = "Food" })
AutoFeedGroup:AddSlider("FeedDelay", { Text = "Feed Delay", Default = 5, Min = 1, Max = 30, Rounding = 0 })
AutoFeedGroup:AddToggle("AutoFeedPets", { Text = "Auto Feed Pets", Default = false })
local AutoReplaceGroup = jg.Pets:AddRightGroupbox("Auto Replace", "refresh-cw")
AutoReplaceGroup:AddDropdown("ReplaceStat", { Values = { "Income", "Weight" }, Default = "Income", Text = "Replace By" })
AutoReplaceGroup:AddSlider("ReplaceImprovement", { Text = "Minimum Improvement %", Default = 0, Min = 0, Max = 100, Rounding = 0 })
AutoReplaceGroup:AddSlider("ReplaceDelay", { Text = "Replace Delay", Default = 5, Min = 2, Max = 30, Rounding = 0 })
AutoReplaceGroup:AddToggle("AutoReplacePets", { Text = "Auto Replace Pets", Default = false })
iZ = fn143
if (io and iV or iV and not iV or (iV or iV) and (io or not io)) and ((io or not io or iV and io) and (iV and io or (not io or iV))) and not ((io and iV or iV and not iV or (iV or iV) and (io or not io)) and ((io or not io or iV and io) and (iV and io or (not io or iV)))) then
    task.spawn(worker2)
    task.spawn(autoBuyEggLoop)
    task.spawn(autoPlaceEggLoop)
    task.spawn(autoHatchEggLoop)
    task.spawn(autoClaimCoinLoop)
    task.spawn(autoBuyTileLoop)
    task.spawn(autoSellPetsLoop)
    task.spawn(autoFeedPetsLoop)
    task.spawn(autoReplacePetsLoop)
    jg = MenuGroup.Settings:AddLeftGroupbox("Menu", "sliders-horizontal")
else
    task.spawn(worker2)
    task.spawn(autoBuyEggLoop)
    task.spawn(autoPlaceEggLoop)
    task.spawn(autoHatchEggLoop)
    task.spawn(autoClaimCoinLoop)
    task.spawn(autoBuyTileLoop)
    task.spawn(autoSellPetsLoop)
    task.spawn(autoFeedPetsLoop)
    task.spawn(autoReplacePetsLoop)
    MenuGroup = jg.Settings:AddLeftGroupbox("Menu", "sliders-horizontal")
end
iC = tick()
iw = tick()
pcall(function()
    for i, v in ipairs(getconnections(iS.Idled)) do
        local oh = v
        pcall(function()
            oh:Disable()
        end)
    end
end)
h6 = fn281
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(antiAfkLoop)
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddButton("Unload", onUnload)
Library:OnUnload(fn613)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(jg.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/build-a-zoo")
SaveManager:BuildConfigSection(jg.Settings)
SaveManager:LoadAutoloadConfig()
end)(...)

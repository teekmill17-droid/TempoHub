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
getgenv().TempoHoodSubtitle = "CARS VS TAPE"
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
local h1
local hG
local hn
local hJ
local h4
local hq
local RequestRebirth
local hM
local ht
local hP
local hw
local hS
local hd
local hz
local hV
local hg
local hC
local hY
local hj
local h0
local connection2
local hm
local hI
local Options
local Ranked
local h6
local hO
local h9
local hR
local hy
local connection3
local hf
local hX
local hE
local h_
local hi
local hH
local hl
local ho
local h5
local hK
local hN
local hr
local connection
local hQ
local hu
local Treadmills
local hT
local he
local WinPads2
local hW
local hh
local hZ
local Cars
local hk
local function fn45()
    if not hH:GetAttribute("DataLoaded") then
        return
    end
    local k7 = if not hT() then 1 else 0
    if k7 == 1 then
        return
    end
    pcall(function()
        RequestRebirth:InvokeServer()
    end)
end
local function onRscripts()
    if setclipboard then
        setclipboard(hh)
    elseif toclipboard then
        toclipboard(hh)
    end
    hI:Notify("Copied Rscripts profile to clipboard")
end
local function fn92()
    if not hH:GetAttribute("DataLoaded") then
        return
    end
    local ll = hE()
    if not ll then
        return
    end
    hW(ll)
end
local function fn127()
    local max = math.max
    local floor = math.floor
    local k2 = hH:GetAttribute("Rebirths") or 0
    local k1_1 = max(floor(k2), 0)
    local k0_1 = hH:GetAttribute("Level") or 1
    local k0_2 = hS.GetLevelCap(k1_1)
    return k0_2 <= k0_1
end
local function onInputChanged(eq)
    local UserInputType = eq.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        h5 = tick()
    end
end
local function worker()
    local lL_1
    while true do
        task.wait(1)
        if hI.Unloaded then
            break
        end
        local lK = math.floor(os.clock() - he)
        if lK < 60 then
            lL_1 = lK .. "s"
        elseif lK < 3600 then
            lL_1 = string.format("%dm %ds", math.floor((lK) / (60)), lK % 60)
        else
            lL_1 = string.format("%dh %dm", math.floor((lK) / (3600)), math.floor((lK % 3600) / (60)))
        end
        hP:SetText(hy("Session time", lL_1, h1))
    end
end
local function onInputBegan()
    h5 = tick()
end
local function fn182(M, N)
    if setclipboard then
        setclipboard(M)
    elseif toclipboard then
        toclipboard(M)
    end
    hI:Notify(N)
end
local function fn189(aG)
    local jb = Cars:FindFirstChild(aG)
    if not jb then
        return nil
    end
    local Base = jb:FindFirstChild("Base")
    local jb_1 = Base and Base:FindFirstChild("CarPromptAttachment")
    local jd = jb_1
    if jb_1 then
        jb_1 = jd:FindFirstChild("CarBuyEquipPrompt")
    end
    local jd_1 = jb_1
    if jb_1 then
        jb_1 = jd_1:IsA("ProximityPrompt")
    end
    if jb_1 then
        return jd_1, Base
    end
    return nil
end
local function worker6()
    while not hI.Unloaded do
        task.wait(2)
        if hQ("RemoveGameplayPaused") then
            hR(true)
        end
        if hQ("AntiAfk") then
            local l5 = tick() - h5
            local l6 = tick() - h0
            if l5 >= 300 and l6 >= 60 then
                pcall(hz)
            else
                if l5 < 300 and l6 >= 300 then
                    pcall(hz)
                end
            end
        end
    end
end
local function fn215()
    local CurrentCamera = hO.CurrentCamera
    if not CurrentCamera then
        return
    end
    hV:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    hV:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    h0 = tick()
end
local function worker4()
    while not hI.Unloaded do
        task.wait(0.5)
        if hQ("AutoRebirth") then
            pcall(hm)
        end
    end
end
local function onRemoveGameplayPaused(ea)
    hR(ea)
end
local function fn310()
    hi(hn, "Copied Discord invite to clipboard")
end
local function fn323(aQ)
    local jj_1
    local ji_1
    jj_1, ji_1 = hC(aQ)
    local jk = not ji_1
    local jl = not jj_1
    local jp = if jl then 1 else 0
    local jn = 196 * jp + 1645 * (1 - jp)
    local jo = 596 * jp + 1663 * (1 - jp)
    if not ((jn * 2256 + jo * 1260 + jn * jo) % 16777213 == 1309952) then
        jl = jk
    end
    if jl then
        return false
    elseif not h9(ji_1.CFrame + Vector3.new(0, 3, 4)) then
        return false
    else
        task.wait(0.2)
        if fireproximityprompt then
            fireproximityprompt(jj_1)
            return true
        end
        return false
    end
end
local function onUnload()
    hI:Unload()
end
local function fn338()
    local jq = "Gulf"
    local jr = -math.huge
    for k, v in pairs(hZ.Cars) do
        local PowerBoost = v.PowerBoost
        local jt = typeof(PowerBoost) == "number" and hN(k) and PowerBoost > jr
        if jt then
            jr = PowerBoost
            jq = k
        end
    end
    return jq, jr
end
local function fn354()
    local ki = h6()
    if not hK(ki) then
        ki = 1
    end
    local Name
    local kk = -math.huge
    for i, v in ipairs(hf) do
        local kl_1 = v.World == ki and hH:GetAttribute("OwnsTreadmill_" .. v.Name) == true
        if kl_1 then
            local kl_2 = hr[v.Name] or 1
            if kl_2 > kk then
                kk = kl_2
                Name = v.Name
            end
        end
    end
    if Name then
        return Name
    end
    local max = math.max
    local floor = math.floor
    local kn = hH:GetAttribute("Rebirths") or 0
    local km_3 = max(floor(kn), 0)
    local kn_1 = ({ "Normal", "Candy", "Lava" })[ki] or "Normal"
    local kj_1 = kn_1
    local kk_1 = hr[kn_1] or 1
    for i, v in ipairs(hk) do
        if v.World == ki and v.Requirement <= km_3 then
            local kl_7 = hr[v.Name] or 1
            if kl_7 >= kk_1 then
                kk_1 = kl_7
                kj_1 = v.Name
            end
        end
    end
    return kj_1
end
local function fn359(W, X, Y)
    return string.format("<b>%s</b> %s %s", W, hM("-", "#5a6070"), hM(X, Y))
end
local function fn361(dt)
    local DiscordGroup = dt:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = h4 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = h4 })
end
local function worker3()
    while not hI.Unloaded do
        task.wait(1.5)
        if hQ("AutoBuyBestCar") then
            pcall(hg)
        end
        if hQ("AutoEquipBestCar") then
            pcall(hG)
        end
        if hQ("AutoBuyBestTitle") then
            pcall(hj)
        end
        if hQ("AutoEquipBestTitle") then
            pcall(hY)
        end
    end
end
local function fn388(b7, b8)
    local kG = WinPads2:FindFirstChild(b7)
    local kH = kG and kG:FindFirstChild(b8)
    local kG_1 = kH
    if kH then
        kH = kG_1:FindFirstChild("Collect")
    end
    local kG_2 = kH
    if kH then
        kH = kG_2:IsA("BasePart")
    end
    if kH then
        return kG_2
    end
    return nil
end
local function worker5()
    while not hI.Unloaded do
        task.wait(1.1)
        if hQ("AutoWin") then
            pcall(hX)
        end
    end
end
local function worker2()
    while not hI.Unloaded do
        task.wait(1)
        if hQ("GoBestTreadmill") then
            pcall(ht)
        end
    end
end
local function fn407(bF)
    if bF <= 1 then
        return true
    elseif bF == 2 then
        return hH:GetAttribute("World2Unlocked") == true
    elseif bF == 3 then
        return hH:GetAttribute("World3Unlocked") == true
    else
        return false
    end
end
local function fn428()
    local WinPads = Options.WinPads
    local kT = WinPads and WinPads.Value
    if typeof(kT) ~= "table" then
        return {}
    end
    local kT_1 = {}
    for k, v in pairs(kT) do
        if v then
            table.insert(kT_1, k)
        end
    end
    table.sort(kT_1, function(cp, cq)
        local kM = (tonumber(string.match(cp, "%d+")))
        local kR = if kM then 1 else 0
        local kP = 370 * kR + 2627 * (1 - kR)
        local kQ = 1286 * kR + 1349 * (1 - kR)
        if not ((kP * 2529 + kQ * 3843 + kP * kQ) % 16777213 == 6353648) then
            kM = 0
        end
        local kN = tonumber(string.match(cq, "%d+")) or 0
        return kM < kN
    end)
    return kT_1
end
local function fn458()
    local lk = if not hH:GetAttribute("DataLoaded") then 1 else 0
    if lk == 1 then
        return
    end
    local lg = ho()
    local lk_1 = if hH:GetAttribute("EquippedCar") == lg then 1 else 0
    if lk_1 == 1 then
        return
    end
    hW(lg)
end
local function fn461(ao)
    local i1 = hq()
    if not i1 or not ao then
        return false
    end
    i1.AssemblyLinearVelocity = Vector3.zero
    i1.AssemblyAngularVelocity = Vector3.zero
    i1.CFrame = ao
    return true
end
local function fn462()
    local attr = hH:GetAttribute("CurrentWorld")
    local kc = typeof(attr) == "number" and attr >= 1
    if kc then
        return math.floor(attr)
    end
    return 1
end
local function fn463(az)
    local OwnedTitles = hH:FindFirstChild("OwnedTitles")
    local i9 = OwnedTitles and OwnedTitles:FindFirstChild(az)
    local i9_1 = i9 ~= nil and i9:IsA("BoolValue") and i9.Value == true
    return i9_1
end
local function fn466(as)
    if as == "Gulf" then
        return true
    end
    local OwnedCars = hH:FindFirstChild("OwnedCars")
    local i6 = OwnedCars and OwnedCars:FindFirstChild(as)
    local i6_1 = i6 ~= nil and i6:IsA("BoolValue") and i6.Value == true
    return i6_1
end
local function fn471()
    local Character = hH.Character
    local i_ = Character and Character:FindFirstChild("HumanoidRootPart")
    return i_
end
local function fn476()
    local lB_1
    local lA_1
    if identifyexecutor then
        lB_1, lA_1 = identifyexecutor()
        local lC = lB_1 ~= ""
        local lD = type(lB_1) == "string" and lC
        if lD then
            local lC_1 = type(lA_1) == "string" and lA_1 ~= "" and lB_1 .. " " .. lA_1
            hl = lC_1 or lB_1
        end
    end
end
local function fn486()
    connection:Disconnect()
    connection2:Disconnect()
    connection3:Disconnect()
    hR(false)
end
local function fn505(T, U)
    return string.format('<font color="%s">%s</font>', U, T)
end
local function fn511(b1)
    local kC = Treadmills:FindFirstChild(b1)
    if not kC then
        return nil
    end
    local Hitbox = kC:FindFirstChild("Hitbox")
    local kE = Hitbox and Hitbox:IsA("BasePart")
    if kE then
        return Hitbox
    end
    return kC:FindFirstChildWhichIsA("BasePart", true)
end
local function fn513(D, E)
    local iS = tonumber(string.match(D, "%d+")) or 0
    local iT = tonumber(string.match(E, "%d+")) or 0
    return iS < iT
end
local function fn533()
    local Name
    local jP = -math.huge
    for i, v in ipairs(Ranked) do
        local jQ = hd(v.Name) and v.Multiplier > jP
        if jQ then
            jP = v.Multiplier
            Name = v.Name
        end
    end
    return Name, jP
end
local function fn551()
    local max = math.max
    local floor = math.floor
    local j_ = (hH:GetAttribute("Wins"))
    local j4 = if j_ then 1 else 0
    local j2 = 2658 * j4 + 1708 * (1 - j4)
    local j3 = 807 * j4 + 449 * (1 - j4)
    if not ((j2 * 3745 + j3 * 3545 + j2 * j3) % 16777213 == 14960031) then
        j_ = 0
    end
    local jZ_1 = max(floor(j_), 0)
    local jY_1 = -1
    local j__1 = nil
    for i, v in ipairs(Ranked) do
        local j0 = not hd(v.Name) and v.RequiredWins <= jZ_1 and v.RequiredWins > jY_1
        if j0 then
            jY_1 = v.RequiredWins
            j__1 = v.Name
        end
    end
    return j__1
end
local function fn571(af)
    local iW = hu[af]
    return iW ~= nil and iW.Value == true
end
local function fn573()
    local max = math.max
    local jB_1
    local floor = math.floor
    local jD = hH:GetAttribute("Wins") or 0
    local jD_1
    local jC_1 = max(floor(jD), 0)
    jB_1, jD_1 = ho()
    local jB_2 = jD_1
    local jD_2 = nil
    for k, v in pairs(hZ.Cars) do
        local Price = v.Price
        local PowerBoost = v.PowerBoost
        local jG = typeof(Price) == "number" and typeof(PowerBoost) == "number" and not hN(k) and Price <= jC_1 and PowerBoost > jB_2
        if jG then
            jB_2 = PowerBoost
            jD_2 = k
        end
    end
    return jD_2, jB_2
end
local function onCopyJoinScript_JobID()
    local lI = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, hJ)
    if setclipboard then
        setclipboard(lI)
    elseif toclipboard then
        toclipboard(lI)
    end
    hI:Notify("Copied join script to clipboard")
end
local function fn585()
    return hH:WaitForChild("PlayerGui")
end
local function fn586()
    local lx = hw()
    local ly = h_(lx)
    if not ly then
        return
    end
    h9(ly.CFrame + Vector3.new(0, 3, 0))
end
connection3 = nil
hd = nil
he = nil
hf = nil
hg = nil
hh = nil
hi = nil
hj = nil
hk = nil
hl = nil
hm = nil
hn = nil
ho = nil
Options = nil
hq = nil
hr = nil
ht = nil
hu = nil
hw = nil
Treadmills = nil
hy = nil
hz = nil
WinPads2 = nil
hC = nil
Cars = nil
hE = nil
connection2 = nil
hG = nil
hH = nil
hI = nil
hJ = nil
hK = nil
Ranked = nil
hM = nil
hN = nil
hO = nil
hP = nil
hQ = nil
hR = nil
hS = nil
hT = nil
hV = nil
hW = nil
hX = nil
hY = nil
local RequestWin, hs, hv, hB, hU
hZ = nil
h_ = nil
h0 = nil
h1 = nil
h4 = nil
h5 = nil
h6 = nil
RequestRebirth = nil
connection = nil
h9 = nil
local h2, RequestTitleAction
local il_1
local ik_1
local ij_1
local ii_1
local ih_1
local ip_2
local ib_1
hV, hO, hH = nil, nil, nil
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Window, ic_2
local UserInputService = game:GetService("UserInputService")
if (not UserInputService and not UserInputService or (not UserInputService or not UserInputService)) and (not UserInputService and not hV or (not hV or hV)) and not ((not UserInputService and not UserInputService or (not UserInputService or not UserInputService)) and (not UserInputService and not hV or (not hV or hV))) then
    hH = game:GetService("VirtualUser")
    hV = game:GetService("Workspace")
else
    hV = game:GetService("VirtualUser")
    hO = game:GetService("Workspace")
    hH = Players.LocalPlayer
end
if getgenv then
    getgenv().gethui = function()
        return hH:WaitForChild("PlayerGui")
    end
end
hn, hh, RequestWin, RequestRebirth, RequestTitleAction, hZ, hS, Ranked, Cars, WinPads2, Treadmills, hr, hk, hf = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
gethui = fn585
local ig = "Cars VS Tape"
hn = "https://discord.gg/K7Qxnxkk46"
hh = "https://discord.gg/K7Qxnxkk46"
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
RequestWin = Remotes:WaitForChild("RequestWin")
RequestRebirth = Remotes:WaitForChild("RequestRebirth")
RequestTitleAction = Remotes:WaitForChild("RequestTitleAction")
if (hr or not hr) and (not RequestRebirth or hr) or (RequestRebirth and RequestWin or hr and not hr) or (RequestWin and not hr or (not RequestWin or RequestRebirth)) and ((not RequestWin or false) and (not RequestRebirth and not RequestRebirth)) or not ((hr or not hr) and (not RequestRebirth or hr) or (RequestRebirth and RequestWin or hr and not hr) or (RequestWin and not hr or (not RequestWin or RequestRebirth)) and ((not RequestWin or false) and (not RequestRebirth and not RequestRebirth))) then
    hZ = require(ReplicatedStorage:WaitForChild("Cars"))
    hS = require(ReplicatedStorage:WaitForChild("Rebirths"))
    Ranked = require(ReplicatedStorage:WaitForChild("Ranked"))
    Cars = hO:WaitForChild("Cars")
else
    hO = require(Cars:WaitForChild("Cars"))
    require(Cars:WaitForChild("Rebirths"))
    hZ = require(Cars:WaitForChild("Ranked"))
    hS = Ranked:WaitForChild("Cars")
end
WinPads2 = hO:WaitForChild("WinPads")
Treadmills = hO:WaitForChild("Treadmills")
hr = {
    Normal = 1,
    Gold = 2,
    Green = 4,
    Purple = 6,
    Red = 10,
    Candy = 10,
    CandyApple = 15,
    CandyPurple = 25,
    Cherry = 50,
    Lava = 100,
    LavaApple = 150,
    LavaPurple = 200,
    LavaCherry = 300,
    White = 25,
    Black = 100,
    Snow = 100,
    Coal = 250,
    Light = 500,
    Ash = 1000
}
hk = {
    { Name = "Normal", Requirement = 0, World = 1 },
    { Name = "Gold", Requirement = 2, World = 1 },
    { Name = "Green", Requirement = 4, World = 1 },
    { Name = "Purple", Requirement = 6, World = 1 },
    { Name = "Red", Requirement = 10, World = 1 },
    { Name = "Candy", Requirement = 0, World = 2 },
    { Name = "CandyApple", Requirement = 15, World = 2 },
    { Name = "CandyPurple", Requirement = 25, World = 2 },
    { Name = "Cherry", Requirement = 50, World = 2 },
    { Name = "Lava", Requirement = 0, World = 3 },
    { Name = "LavaApple", Requirement = 150, World = 3 },
    { Name = "LavaPurple", Requirement = 200, World = 3 },
    { Name = "LavaCherry", Requirement = 300, World = 3 }
}
hf = {
    { Name = "White", World = 1 },
    { Name = "Black", World = 1 },
    { Name = "Snow", World = 2 },
    { Name = "Coal", World = 2 },
    { Name = "Light", World = 3 },
    { Name = "Ash", World = 3 }
}
local ie = {}
for i, child in ipairs(WinPads2:GetChildren()) do
    table.insert(ie, child.Name)
end
ib_1, hI, ij_1, ii_1, hu, Options, ih_1, il_1, h1, ik_1, h2, Window, hi, h4, hM, hy, hQ, hq, h9, hN, hd, hC, hW, ho, hE, hv, hU, h6, hK, hw, h_, hs, hB, hT, hm, hX, hG, hg, hY, hj, ht = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local ia_2 = 98
repeat
    local im_1 = (ia_2 * 5 + 6) % 16 + 1
    if im_1 <= 8 then
        if im_1 <= 4 then
            if im_1 <= 2 then
                if im_1 <= 1 then
                    if (ia_2 * 3 + 7) * 9 % 4 == ((ia_2 * 3 + 7) * 9 + 4) % 4 then
                        table.sort(ie, fn513)
                        ib_1 = ""
                    else
                        table.sort(ib_1, fn513)
                        ie = ""
                    end
                    ia_2 = (ia_2 + 45) % 128
                else
                    local io_1 = {
                        "erdyyt",
                        "luutu",
                        "xxr",
                        "gsxhl",
                        "hgdfnmorr",
                        "nrkxeuqkcp",
                        "ebkw",
                        "ohlagy",
                        "txzoethrjz",
                        "thjtmsjgod",
                        "hzejid",
                        "jyvuloiqnpkw",
                        "mhoyaq"
                    }
                    if io_1[(ia_2 * 20 + 95) % 13 + 1] <= io_1[(ia_2 * 20 + 95) % 13 + 1] then
                        hI = getgenv().Library
                    else
                        ib_1 = getgenv().Library
                    end
                    ia_2 = (ia_2 + 77) % 128
                end
            elseif im_1 <= 3 then
                if ia_2 * 57150511 + 1 + 1 <= ia_2 * 57150511 + 1 + 1 + 1 then
                    ij_1 = getgenv().ThemeManager
                    ii_1 = getgenv().SaveManager
                    hu = hI.Toggles
                else
                    ib_1 = getgenv().ThemeManager
                    hu = getgenv().SaveManager
                    hI = ij_1.Toggles
                end
                ia_2 = (ia_2 + 61) % 128
            else
                local io_2 = {
                    "yaerot",
                    "aoglrnyfjl",
                    "xghqkc",
                    "ruf",
                    "zbjxqwgaymp",
                    "klimim",
                    "hakfgkrdk",
                    "bwa",
                    "cyomqwnzw"
                }
                local mP = ia_2
                local ip_1 = io_2[mP % 9 + 1]
                if ip_1:len() >= ip_1:gsub("(.)", "%1%1", mP % 3 % 2 + 1):len() then
                    hI = Options.Options
                else
                    Options = hI.Options
                end
                ia_2 = (ia_2 + 125) % 128
            end
        elseif im_1 <= 6 then
            if im_1 <= 5 then
                if ((not hX or Options) and (not ii_1 and not Options) or (hG and hv or (hv or ia_2)) or (ii_1 and not hG or (ii_1 or hX) or Options and ia_2 and (not Options or not Options))) and not ((not hX or Options) and (not ii_1 and not Options) or (hG and hv or (hv or ia_2)) or (ii_1 and not hG or (ii_1 or hX) or Options and ia_2 and (not Options or not Options))) then
                    hU = fn182
                else
                    hi = fn182
                end
                ia_2 = (ia_2 + 109) % 128
            else
                local io_3 = (vector.create((ia_2 * 5 + 3) % 11 + 1, (ia_2 * 5 + 9) % 13 + 1, (ia_2 * 3 + 1) % 17 + 1))
                local mN = vector.floor(io_3) + vector.ceil(io_3 * -1)
                if vector.dot(mN, mN) == 0 then
                    h4 = fn310
                    hM = fn505
                    hy = fn359
                    ih_1 = "#7fd47f"
                    il_1 = "#6ec1ff"
                else
                    hM = fn310
                    il_1 = fn505
                    h4 = fn359
                    hy = "#7fd47f"
                    ih_1 = "#6ec1ff"
                end
                ia_2 = (ia_2 + 109) % 128
            end
        elseif im_1 <= 7 then
            local io_4 = { "rewsnmxy", "kwwsdbmwed", "cviy", "hukpttsrygul", "tcqrn", "fnna", "eok", "dftnzs", "fypj" }
            if io_4[(ia_2 * 77 + 49) % 9 + 1] <= io_4[(ia_2 * 77 + 49) % 9 + 1] then
                h1 = "#e8a34d"
            else
                h_ = "#e8a34d"
            end
            ia_2 = (ia_2 + 93) % 128
        else
            local io_5 = {
                "jbdwvuswdx",
                "ikxdchnyjwqb",
                "lszfnxxeh",
                "zps",
                "qdtj",
                "omu",
                "raff",
                "uwfdxlkedd",
                "yausrhyucwy"
            }
            if io_5[(ia_2 * 9 + 93) % 9 + 1] <= io_5[(ia_2 * 9 + 93) % 9 + 1] then
                ik_1 = "#8b93a3"
                hQ = fn571
                hq = fn471
                h9 = fn461
                hN = fn466
            else
                hQ = "#8b93a3"
                ik_1 = fn571
                h9 = fn471
                hN = fn461
                hq = fn466
            end
            ia_2 = (ia_2 + 109) % 128
        end
    elseif im_1 <= 12 then
        if im_1 <= 10 then
            if im_1 <= 9 then
                local m_ = bit32.rrotate(bit32.bxor(bit32.lrotate(ia_2, 1), string.byte(tostring(hd))), 3)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(m_, 1495270369), 48247506), (bit32.bxor(bit32.band(m_, 2799696926), 813233561))), 48247506), 813233561) == m_ then
                    hd = fn463
                    hC = fn189
                    hW = fn323
                    ho = fn338
                    hE = fn573
                else
                    hW = fn463
                    hE = fn189
                    hC = fn323
                    hd = fn338
                    ho = fn573
                end
                ia_2 = (ia_2 + 125) % 128
            else
                if (ia_2 * 2 + 8) * 7 % 3 == ((ia_2 * 2 + 8) * 7 + 1) % 3 then
                    h6 = fn533
                    hv = fn551
                    hU = fn462
                else
                    hv = fn533
                    hU = fn551
                    h6 = fn462
                end
                ia_2 = (ia_2 + 29) % 128
            end
        elseif im_1 <= 11 then
            local io_6 = {
                "jze",
                "uqnucoxemk",
                "hrvuedbwz",
                "zzevoi",
                "xvkvdijwjqw",
                "dxixawyn",
                "knpa",
                "gesgspwlt",
                "rqeguxgi",
                "nnezdzh",
                "cmkxwdsunfak",
                "oamh",
                "hfaaey",
                "ujgxbzbdv"
            }
            if io_6[(ia_2 * 80 + 51) % 14 + 1] <= io_6[(ia_2 * 80 + 51) % 14 + 1] then
                hK = fn407
            else
                hs = fn407
            end
            ia_2 = (ia_2 + 29) % 128
        else
            if ia_2 * 119742155 + 6 + 3 >= ia_2 * 119742155 + 6 + 3 + 1 then
                h_ = fn354
                hw = fn511
            else
                hw = fn354
                h_ = fn511
            end
            ia_2 = (ia_2 + 13) % 128
        end
    elseif im_1 <= 14 then
        if im_1 <= 13 then
            local io_7 = (vector.create((ia_2 * 2 + 6) % 11 + 1, (ia_2 * 2 + 2) % 13 + 1, (ia_2 * 2 + 16) % 17 + 1))
            local mM = vector.floor(io_7) + vector.ceil(io_7 * -1)
            if vector.dot(mM, mM) == 0 then
                hs = fn388
            else
                hY = fn388
            end
            ia_2 = (ia_2 + 125) % 128
        else
            if (ia_2 * 2 + 1) * 7 % 3 == ((ia_2 * 2 + 1) * 7 + 2) % 3 then
                hm = fn428
                hB = fn127
                h2 = fn45
                hT = 1
            else
                hB = fn428
                hT = fn127
                hm = fn45
                h2 = 1
            end
            ia_2 = (ia_2 + 13) % 128
        end
    elseif im_1 <= 15 then
        local im_2 = (vector.create((ia_2 * 5 + 8) % 11 + 1, (ia_2 * 1 + 12) % 13 + 1, (ia_2 * 10 + 3) % 17 + 1))
        local mU = vector.floor(im_2) + vector.ceil(im_2 * -1)
        if vector.dot(mU, mU) == 0 then
            hX = function()
                local k8, k9
                if not hH:GetAttribute("DataLoaded") then
                    return
                end
                local la = hB()
                if #la == 0 then
                    return
                end
                if h2 > #la then
                    h2 = 1
                end
                k8 = la[h2]
                h2 += 1
                local la_3 = hQ("UseX10WinPads") and "x10WinCollect"
                k9 = la_3 or "WinCollect"
                local la_4 = hs(k8, k9)
                if not la_4 then
                    return
                end
                if not h9(la_4.CFrame + Vector3.new(0, 3, 0)) then
                    return
                end
                task.wait(0.15)
                pcall(function()
                    RequestWin:InvokeServer(k8, k9)
                end)
            end
            hG = fn458
            hg = fn92
            hY = function()
                local ln
                if not hH:GetAttribute("DataLoaded") then
                    return
                end
                ln = hv()
                if not ln then
                    return
                end
                if hH:GetAttribute("EquippedTitle") == ln then
                    return
                end
                pcall(function()
                    RequestTitleAction:InvokeServer("Equip", ln)
                end)
            end
            hj = function()
                local lp
                local lr_2
                local lq_2
                if not hH:GetAttribute("DataLoaded") then
                    return
                end
                lp = hU()
                if not lp then
                    return
                end
                lq_2, lr_2 = pcall(function()
                    return RequestTitleAction:InvokeServer("BuyWins", lp)
                end)
                if lq_2 and lr_2 then
                    pcall(function()
                        RequestTitleAction:InvokeServer("Equip", lp)
                    end)
                end
            end
        else
            hY = function()
                local k8, k9
                if not hH:GetAttribute("DataLoaded") then
                    return
                end
                local la = hB()
                if #la == 0 then
                    return
                end
                if h2 > #la then
                    h2 = 1
                end
                k8 = la[h2]
                h2 += 1
                local la_1 = hQ("UseX10WinPads") and "x10WinCollect"
                k9 = la_1 or "WinCollect"
                local la_2 = hs(k8, k9)
                if not la_2 then
                    return
                end
                if not h9(la_2.CFrame + Vector3.new(0, 3, 0)) then
                    return
                end
                task.wait(0.15)
                pcall(function()
                    RequestWin:InvokeServer(k8, k9)
                end)
            end
            hX = fn458
            hj = fn92
            hG = function()
                local ln
                if not hH:GetAttribute("DataLoaded") then
                    return
                end
                ln = hv()
                if not ln then
                    return
                end
                if hH:GetAttribute("EquippedTitle") == ln then
                    return
                end
                pcall(function()
                    RequestTitleAction:InvokeServer("Equip", ln)
                end)
            end
            hg = function()
                local lp
                local lr_1
                local lq_1
                if not hH:GetAttribute("DataLoaded") then
                    return
                end
                lp = hU()
                if not lp then
                    return
                end
                lq_1, lr_1 = pcall(function()
                    return RequestTitleAction:InvokeServer("BuyWins", lp)
                end)
                if lq_1 and lr_1 then
                    pcall(function()
                        RequestTitleAction:InvokeServer("Equip", lp)
                    end)
                end
            end
        end
        ia_2 = (ia_2 + 109) % 128
    else
        local m0 = bit32.rrotate(bit32.bxor(bit32.lrotate(ia_2, 3), string.byte(tostring(Options))), 20)
        if bit32.bxor(bit32.lrotate(bit32.bxor(m0, 3839144942), 6), 892140473) == bit32.lrotate(m0, 6) then
            ht = fn586
            Window = hI:CreateWindow({
                Title = "Tempo Hub",
                Footer = { { Text = hn, Copyable = true }, "|", ig },
                Icon = 12645376577,
                NotifySide = "Right",
                ShowCustomCursor = false,
                CornerRadius = 10
            })
        else
            hn = fn586
            ht = Window:CreateWindow({
                Icon = 12645376577,
                Footer = { hI, "|", { Text = ig, Copyable = true } },
                CornerRadius = 10,
                ShowCustomCursor = false,
                Title = "Tempo Hub",
                NotifySide = "Right"
            })
        end
        ia_2 = (ia_2 + 61) % 128
    end
until (ia_2 * 101 + 49) % 128 == 107
if hI.ScreenGui then
    local ia_3 = 3
    repeat
        if ia_3 * 40593313 + 3 + 4 >= ia_3 * 40593313 + 3 + 4 + 1 then
            hH.ScreenGui.Parent = hI:WaitForChild("PlayerGui")
        else
            hI.ScreenGui.Parent = hH:WaitForChild("PlayerGui")
        end
        ia_3 = (ia_3 + 1) % 8
    until (ia_3 * 5 + 3) % 8 == 7
end
local io_8 = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "car"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in io_8 do
    fn361(v)
end
hl, ip_2, hP, hJ, ic_2 = nil, nil, nil, nil, nil
local ia_4 = 19
repeat
    local im_4 = (ia_4 * 2 + 0) % 3 + 1
    if im_4 <= 2 then
        if im_4 <= 1 then
            local im_5 = (vector.create((ia_4 * 5 + 3) % 11 + 1, (ia_4 * 11 + 9) % 13 + 1, (ia_4 * 7 + 4) % 17 + 1))
            local iq_1 = (vector.create((ia_4 * 7 + 5) % 11 + 1, (ia_4 * 1 + 3) % 13 + 1, (ia_4 * 7 + 15) % 17 + 1))
            local m1 = vector.dot(im_5, iq_1)
            if m1 * m1 <= vector.dot(im_5, im_5) * vector.dot(iq_1, iq_1) then
                hJ = tostring(game.JobId)
            else
                ip_2 = tostring(game.JobId)
            end
            ia_4 = (ia_4 + 11) % 24
        else
            local im_6 = (vector.create((ia_4 * 4 + 8) % 11 + 1, (ia_4 * 3 + 1) % 13 + 1, (ia_4 * 11 + 13) % 17 + 1))
            local iq_2 = (vector.create((ia_4 * 4 + 8) % 11 + 1, (ia_4 * 11 + 10) % 13 + 1, (ia_4 * 13 + 13) % 17 + 1))
            local ir_1 = (vector.create((ia_4 * 1 + 4) % 5 + 1, (ia_4 * 4 + 2) % 7 + 1, (ia_4 * 2 + 3) % 9 + 1))
            if math.abs((vector.angle(im_6, iq_2, ir_1))) - math.abs((vector.angle(iq_2, im_6, ir_1))) == 4 then
                hJ = #ic_2 > 18
            else
                ic_2 = #hJ > 18
            end
            ia_4 = (ia_4 + 2) % 24
        end
    else
        local im_7 = (vector.create((ia_4 * 2 + 9) % 11 + 1, (ia_4 * 1 + 12) % 13 + 1, (ia_4 * 6 + 7) % 17 + 1))
        local iq_3 = (vector.create((ia_4 * 7 + 7) % 11 + 1, (ia_4 * 2 + 4) % 13 + 1, (ia_4 * 13 + 11) % 17 + 1))
        local mK = vector.cross(im_7, iq_3)
        local mL = vector.dot(im_7, iq_3)
        if vector.dot(mK, mK) + mL * mL == vector.dot(im_7, im_7) * vector.dot(iq_3, iq_3) + 2 then
            hP = "Unknown"
            pcall(fn476)
            hH = hl.Info:AddLeftGroupbox("Account", "circle-user")
            hH:AddLabel(ip_2("User", ih_1.Name, hM), true)
            hH:AddLabel(ip_2("Status", "Keyless", hM), true)
            hH:AddLabel(ip_2("Executor", hP, hM), true)
            h1 = hl.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            h1:AddLabel(io_8(hy .. " [" .. tostring(game.PlaceId) .. "]", ig), true)
            h1:AddLabel(ip_2("Place ID", tostring(game.PlaceId), ig), true)
            h1:AddLabel(ip_2("Session time", "0s", il_1), true)
        else
            hl = "Unknown"
            pcall(fn476)
            local AccountGroup = io_8.Info:AddLeftGroupbox("Account", "circle-user")
            AccountGroup:AddLabel(hy("User", hH.Name, ih_1), true)
            AccountGroup:AddLabel(hy("Status", "Keyless", ih_1), true)
            AccountGroup:AddLabel(hy("Executor", hl, ih_1), true)
            ip_2 = io_8.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            ip_2:AddLabel(hM(ig .. " [" .. tostring(game.PlaceId) .. "]", il_1), true)
            ip_2:AddLabel(hy("Place ID", tostring(game.PlaceId), il_1), true)
            hP = ip_2:AddLabel(hy("Session time", "0s", h1), true)
        end
        ia_4 = (ia_4 + 14) % 24
    end
until (ia_4 * 1 + 22) % 24 == 20
if ic_2 then
    local ia_5 = 1
    repeat
        local ib_3 = (vector.create((ia_5 * 1 + 3) % 11 + 1, (ia_5 * 7 + 9) % 13 + 1, (ia_5 * 8 + 13) % 17 + 1))
        local im_8 = (vector.create((ia_5 * 7 + 3) % 11 + 1, (ia_5 * 2 + 7) % 13 + 1, (ia_5 * 9 + 17) % 17 + 1))
        local iq_4 = (vector.create((ia_5 * 1 + 5) % 11 + 1, (ia_5 * 2 + 6) % 13 + 1, (ia_5 * 15 + 17) % 17 + 1))
        if vector.dot(vector.cross(ib_3, im_8), iq_4) == vector.dot(vector.cross(im_8, iq_4), ib_3) + 5 then
            hJ = string.sub(ic_2, 1, 18) .. "..."
        else
            ic_2 = string.sub(hJ, 1, 18) .. "..."
        end
        ia_5 = (ia_5 + 2) % 4
    until (ia_5 * 1 + 3) % 4 == 2
end
local ia_6 = ic_2 or hJ
he, h5, h0, connection, connection2, connection3, hR, hz = nil, nil, nil, nil, nil, nil, nil, nil
ip_2:AddLabel(hy("Server", ia_6, ik_1), true)
ip_2:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
he = os.clock()
task.spawn(worker)
local ScriptsGroup = io_8.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(hM("Included in this hub", ik_1), true)
ScriptsGroup:AddLabel(hM(ig, il_1), true)
local FeaturesGroup = io_8.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(hM("Auto Win", il_1), true)
FeaturesGroup:AddLabel(hM("Rebirth", h1), true)
FeaturesGroup:AddLabel(hM("Cars & Titles", ih_1), true)
FeaturesGroup:AddLabel(hM("Treadmills", ik_1), true)
local SocialsGroup = io_8.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = h4 })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = io_8.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = h4 })
local FaqGroup = io_8.Info:AddRightGroupbox("FAQ", "circle-help")
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
local FarmGroup = io_8.Main:AddLeftGroupbox("Farm", "trophy")
FarmGroup:AddToggle("AutoWin", { Text = "Auto Win", Default = false })
FarmGroup:AddDropdown("WinPads", {
    Text = "Win Pads",
    Values = ie,
    Default = { "Section1" },
    Multi = true,
    Expandable = true,
    ExpandColumns = 3
})
FarmGroup:AddToggle("UseX10WinPads", { Text = "x10 Win Pads", Default = false })
FarmGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
FarmGroup:AddToggle("GoBestTreadmill", { Text = "Go Best Treadmill", Default = false })
local GearGroup = io_8.Main:AddRightGroupbox("Gear", "car")
GearGroup:AddToggle("AutoEquipBestCar", { Text = "Auto Equip Best Car", Default = false })
GearGroup:AddToggle("AutoBuyBestCar", { Text = "Auto Buy Best Affordable Car", Default = false })
GearGroup:AddToggle("AutoEquipBestTitle", { Text = "Auto Equip Best Title", Default = false })
GearGroup:AddToggle("AutoBuyBestTitle", { Text = "Auto Buy Best Title", Default = false })
local MenuGroup = io_8.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
hI.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
hR = function(d4)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not d4)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not d4
        end
    end)
    if not d4 then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(hH, "GameplayPaused", false)
        else
            hH.GameplayPaused = false
        end
    end)
end
MenuGroup:AddToggle("RemoveGameplayPaused", { Text = "Auto Remove Gameplay Paused", Default = true, Callback = onRemoveGameplayPaused })
MenuGroup:AddButton({ Text = "Unload", Func = onUnload })
ij_1:SetLibrary(hI)
ij_1:SetFolder("TempoHub")
ij_1:SaveDefault("Monochrome")
ij_1:ApplyToTab(io_8.Settings)
ij_1:LoadDefault()
ii_1:SetLibrary(hI)
ii_1:IgnoreThemeSettings()
ii_1:SetIgnoreIndexes({ "MenuKeybind" })
ii_1:SetFolder("TempoHub/cars-vs-tape")
ii_1:BuildConfigSection(io_8.Settings)
ii_1:LoadAutoloadConfig()
h5 = tick()
h0 = tick()
pcall(function()
    for i, v in ipairs(getconnections(hH.Idled)) do
        local lY = v
        pcall(function()
            lY:Disable()
        end)
    end
end)
hz = fn215
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
connection3 = game:GetService("CoreGui").ChildAdded:Connect(function(ev)
    local l3 = hI.Unloaded or not hQ("RemoveGameplayPaused")
    if l3 then
        return
    end
    if ev.Name == "RobloxNetworkPauseNotification" then
        pcall(function()
            ev.Enabled = false
        end)
    end
end)
do
    hI:OnUnload(fn486)
    hR(hQ("RemoveGameplayPaused"))
    task.spawn(worker6)
    task.spawn(worker5)
    task.spawn(worker4)
    task.spawn(worker3)
    task.spawn(worker2)
end
end)(...)

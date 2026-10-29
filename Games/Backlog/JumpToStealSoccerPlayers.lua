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
getgenv().TempoHoodSubtitle = "JUMP TO STEAL SOCCER PLAYERS"
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
local iU
local iX
local iE
local i_
local ih
local iH
local i2
local ik
local iK
local i5
local connection
local iN
local io
local iu
local ix
local iT
local iW
local iD
local Toggles
local ig
local ij
local Label
local i1
local im
local Options
local Upgrade_Carry_Limit
local iM
local i7
local iq
local it
local autoOGLuckyBlocksLoop
local Buy_Speed_Upgrade
local iz
local iV
local iY
local Rebirth
local Collect_Earnings
local Purchase_Floor
local il
local i3
local iL
local i6
local Upgrade_Slime
local iO
local iv
ig = nil
ih = nil
ij = nil
ik = nil
il = nil
im = nil
io = nil
iq = nil
connection = nil
Upgrade_Slime = nil
it = nil
iu = nil
iv = nil
ix = nil
iz = nil
Rebirth = nil
iD = nil
iE = nil
Collect_Earnings = nil
Label = nil
iH = nil
Upgrade_Carry_Limit = nil
iK = nil
iL = nil
iM = nil
iN = nil
iO = nil
autoOGLuckyBlocksLoop = nil
Buy_Speed_Upgrade = nil
iT = nil
iU = nil
iV = nil
iW = nil
iX = nil
iY = nil
Toggles = nil
i_ = nil
Purchase_Floor = nil
i1 = nil
i2 = nil
i3 = nil
local ii, Open_Lucky_Block, iw, iy, Place_Slime, iB, iI, iQ, iR
Options = nil
i5 = nil
i6 = nil
i7 = nil
local jf_1
local je_1
local ThemeManager
local jc_1, jc_2
local jb_1
local Players, i8_5
local ja_1, ja_3, ja_4
local jm = if not game:IsLoaded() then 1 else 0
if jm == 1 then
    game.Loaded:Wait()
end
Players, jb_1, iV, ja_1 = nil, nil, nil, nil
if (not jb_1 or ja_1) and (jb_1 or jb_1) and (not Players and iV or (not jb_1 or false)) or (iV or not iV) and (ja_1 and jb_1) and (not jb_1 and ja_1 and false) or (jb_1 and iV and (Players or ja_1) or Players and (Players or 2)) and ((Players or false) and (iV or Players) or not ja_1 and ja_1 and (ja_1 and 2)) or not ((not jb_1 or ja_1) and (jb_1 or jb_1) and (not Players and iV or (not jb_1 or false)) or (iV or not iV) and (ja_1 and jb_1) and (not jb_1 and ja_1 and false) or (jb_1 and iV and (Players or ja_1) or Players and (Players or 2)) and ((Players or false) and (iV or Players) or not ja_1 and ja_1 and (ja_1 and 2))) then
    Players = game:GetService("Players")
else
    iV = game:GetService("Players")
end
local ReplicatedStorage = game:GetService("ReplicatedStorage")
iV = Players.LocalPlayer
local ja_2 = getgenv and getgenv()
iv = ja_2 or _G
if type(iv.TempoHubUnload) == "function" then
    pcall(iv.TempoHubUnload)
end
i2, jf_1, ThemeManager, je_1, ja_3, jc_1 = nil, nil, nil, nil, nil, nil
local i8_3 = "https://raw.githubusercontent.com/losthubv1/ffedfdfdf/main/"
i2 = getgenv().Library
if (jc_1 and false or jc_1 and jc_1 or (jc_1 and not jc_1 or (not jc_1 or jc_1)) or ((not jc_1 or not jc_1) and (not jc_1) or (jc_1 or jc_1 or (jc_1 or not jc_1)))) and ((jc_1 or false) and (not jc_1) or jc_1 and not jc_1 and 41 or ((jc_1 and not jc_1) or (not jc_1 or not jc_1 and jc_1))) and not ((jc_1 and false or jc_1 and jc_1 or (jc_1 and not jc_1 or (not jc_1 or jc_1)) or ((not jc_1 or not jc_1) and (not jc_1) or (jc_1 or jc_1 or (jc_1 or not jc_1)))) and ((jc_1 or false) and (not jc_1) or jc_1 and not jc_1 and 41 or ((jc_1 and not jc_1) or (not jc_1 or not jc_1 and jc_1)))) then
    i2 = jf_1:CreateLoading({ WindowHeight = 270, Title = "TempoHub", WindowWidth = 470, TotalSteps = 4 })
else
    jf_1 = i2:CreateLoading({ Title = "TempoHub", TotalSteps = 4, WindowWidth = 470, WindowHeight = 270 })
end
if (i2 or je_1 or not ja_3 and 10) and ((ja_3 or i8_3) and (false or jc_1)) or not ((i2 or je_1 or not ja_3 and 10) and ((ja_3 or i8_3) and (false or jc_1))) then
    jf_1:SetMessage("Starting TempoHub")
    jf_1:SetDescription("Loading interface addons...")
    jf_1:SetCurrentStep(1)
    ThemeManager = getgenv().ThemeManager
else
    ThemeManager:SetMessage("Starting TempoHub")
    ThemeManager:SetDescription("Loading interface addons...")
    ThemeManager:SetCurrentStep(1)
    i8_3 = getgenv().ThemeManager
end
if (i8_3 and not jf_1 and (not jf_1 or jf_1) and (not ThemeManager or not i8_3 or ja_3 and ThemeManager) or (not ThemeManager and i8_3 or (i8_3 or not jf_1)) and (not ja_3 or not ja_3 or (not jf_1 or not jf_1)) or ((i8_3 or jf_1) and (ThemeManager or ThemeManager) or (i8_3 or not i8_3 or (ja_3 or not ja_3))) and (not jf_1 or i8_3 or i8_3 and not i8_3 or not ThemeManager and not jf_1 and (i8_3 and ThemeManager))) and not (i8_3 and not jf_1 and (not jf_1 or jf_1) and (not ThemeManager or not i8_3 or ja_3 and ThemeManager) or (not ThemeManager and i8_3 or (i8_3 or not jf_1)) and (not ja_3 or not ja_3 or (not jf_1 or not jf_1)) or ((i8_3 or jf_1) and (ThemeManager or ThemeManager) or (i8_3 or not i8_3 or (ja_3 or not ja_3))) and (not jf_1 or i8_3 or i8_3 and not i8_3 or not ThemeManager and not jf_1 and (i8_3 and ThemeManager))) then
    local _ = getgenv().SaveManager
else
    je_1 = getgenv().SaveManager
end
jf_1:SetDescription("Finding the game's replicated objects...")
jf_1:SetCurrentStep(2)
ThemeManager:SetLibrary(i2)
ja_4, jc_2 = ThemeManager:SetStartupTheme("Default")
if not ja_4 then
    warn("[TempoHub] Default theme failed to load:", jc_2)
end
Options = i2.Options
Toggles = i2.Toggles
local Remotes = ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Network"):WaitForChild("Remotes")
Collect_Earnings = Remotes:WaitForChild("Collect Earnings")
Place_Slime = Remotes:WaitForChild("Place Slime")
Open_Lucky_Block = Remotes:WaitForChild("Open Lucky Block")
local Send_Notification = Remotes:WaitForChild("Send Notification")
Purchase_Floor = Remotes:WaitForChild("Purchase Floor")
Buy_Speed_Upgrade = Remotes:WaitForChild("Buy Speed Upgrade")
Upgrade_Carry_Limit = Remotes:WaitForChild("Upgrade Carry Limit")
Rebirth = Remotes:WaitForChild("Rebirth")
Upgrade_Slime = Remotes:WaitForChild("Upgrade Slime")
ij = function(C)
    local jp_1
    if type(C) == "number" then
        return C
    end
    local jn = C or ""
    local jn_1
    local jo = tostring(jn):gsub(",", ""):gsub("%$", ""):gsub("%s+", "")
    jn_1, jp_1 = jo:match("([%d%.]+)([%a]*)")
    local jo_1 = tonumber(jn_1)
    if not jo_1 then
        return nil
    end
    local jn_2 = {
        K = 1000,
        M = 1000000,
        B = 1000000000,
        T = 1000000000000,
        QA = 1000000000000000,
        QI = 1e+18,
        SX = 1e+21,
        SP = 1e+24
    }
    local jr = jp_1 or ""
    local jp_2 = jn_2[string.upper(jr)]
    local jv = if jp_2 then 1 else 0
    local jt = 3499 * jv + 2224 * (1 - jv)
    local ju = 1516 * jv + 2024 * (1 - jv)
    if not ((jt * 3147 + ju * 3082 + jt * ju) % 16777213 == 4210936) then
        jp_2 = 1
    end
    return jo_1 * jp_2
end
i3 = function()
    local leaderstats = iV:FindFirstChild("leaderstats")
    local jx = leaderstats and leaderstats:FindFirstChild("Cash")
    local jw_1 = jx
    if jx then
        jx = ij(jw_1.Value)
    end
    return jx or 0
end
i_ = function()
    local Character = iV.Character
    local jD = Character and Character:FindFirstChild("HumanoidRootPart")
    return jD
end
iu = function()
    local Plots = workspace:FindFirstChild("Plots")
    if not Plots then
        return nil
    end
    for i, child in ipairs(Plots:GetChildren()) do
        local owner = child:FindFirstChild("owner")
        local jG = owner and tostring(owner.Value) == iV.Name
        if jG then
            return child
        end
    end
    return nil
end
ik = function()
    local Live = workspace:FindFirstChild("Live")
    local jS = Live and Live:FindFirstChild("PlayerSlimes")
    local jR_1 = jS
    if jS then
        jS = jR_1:FindFirstChild(iV.Name)
    end
    return jS
end
io = function(ae)
    local SlimeBillboard = ae:FindFirstChild("SlimeBillboard")
    local jV = SlimeBillboard and SlimeBillboard:FindFirstChild("Frame")
    local jU_1 = jV
    if jV then
        jV = jU_1:FindFirstChild("DisplayName")
    end
    local jU_2 = jV
    if jV then
        jV = jU_2.Text
    end
    return jV or ae.Name
end
iT = function()
    local j_ = iu()
    local j0 = j_ and j_:FindFirstChild("Base")
    local j1 = j0
    if j0 then
        j0 = j1:FindFirstChild("Teleport", true)
    end
    local j2 = j0
    if j0 then
        j0 = j2:IsA("Attachment")
    end
    if j0 then
        return j2.WorldCFrame
    end
    local j0_1 = j2 and j2:IsA("BasePart")
    if j0_1 then
        return j2.CFrame
    end
    local j0_2 = j1 and j1:IsA("Model")
    if j0_2 then
        return j1:GetPivot()
    end
    local j0_3 = j_ and j_:GetPivot()
    return j0_3 or nil
end
i5 = function(ay)
    local j7 = i_()
    if j7 and ay then
        j7.CFrame = ay + Vector3.new(0, 3, 0)
        j7.AssemblyLinearVelocity = Vector3.zero
        j7.AssemblyAngularVelocity = Vector3.zero
        return true
    end
    return false
end
iz = function(aC)
    if aC:IsA("Model") then
        return aC:GetPivot().Position
    elseif aC:IsA("BasePart") then
        return aC.Position
    else
        local kf = if aC:IsA("Attachment") then 1 else 0
        if kf == 1 then
            return aC.WorldPosition
        end
        local BasePart = aC:FindFirstChildWhichIsA("BasePart", true)
        return BasePart and BasePart.Position or nil
    end
end
iR = function(aG)
    local Live = workspace:FindFirstChild("Live")
    local kh = Live and Live:FindFirstChild("Guardians")
    if not kh then
        return math.huge
    end
    local kh_1 = math.huge
    for i, child in ipairs(kh:GetChildren()) do
        local kg_2 = iz(child)
        if kg_2 then
            kh_1 = math.min(kh_1, (aG - kg_2).Magnitude)
        end
    end
    return kh_1
end
il = function()
    local Character = iV.Character
    local Backpack = iV:FindFirstChildOfClass("Backpack")
    local kr = {}
    local ks = {}
    for i, v in ipairs({ Character, Backpack }) do
        if v then
            for i, child in ipairs(v:GetChildren()) do
                if child:IsA("Tool") then
                    local attr = child:GetAttribute("slimeUID")
                    if attr and not kr[attr] then
                        kr[attr] = true
                        ks[#ks + 1] = { Tool = child, Uid = attr }
                    end
                end
            end
        end
    end
    return ks
end
iq = function(a0)
    local kH = tonumber(a0)
    if not kH then
        return false
    elseif kH <= 10 then
        return true
    else
        local kH_1 = iu()
        local kI = kH_1 and kH_1:FindFirstChild("CollectPads")
        local kH_2 = kI
        if kI then
            kI = kH_2:FindFirstChild(tostring(a0))
        end
        local kH_3 = kI
        if kI then
            kI = kH_3:FindFirstChild("Top")
        end
        local kJ = kI
        if kI then
            kI = kJ:FindFirstChild("PurchaseInfo")
        end
        local kK = kI
        if not kH_3 or not kJ then
            return false
        end
        local kH_4 = kK
        if kH_4 then
            local kI_2 = kK:IsA("BillboardGui") or kK:IsA("SurfaceGui")
            kH_4 = kI_2
        end
        if kH_4 then
            return not kK.Enabled
        end
        return kK == nil
    end
end
iQ = function()
    local kQ = iu()
    local kR = kQ and kQ:FindFirstChild("Stands")
    local kR_1 = ik()
    if not kR then
        return nil
    end
    local kS = {}
    for i, child in ipairs(kR:GetChildren()) do
        local kQ_2 = tonumber(child.Name)
        if kQ_2 then
            kS[#kS + 1] = child
        end
    end
    table.sort(kS, function(bq, br)
        return tonumber(bq.Name) < tonumber(br.Name)
    end)
    for i, v in ipairs(kS) do
        local kQ_3 = kR_1 and kR_1:FindFirstChild(v.Name)
        local kQ_4 = not kQ_3
        if kQ_4 ~= false then
            kQ_4 = iq(v.Name)
        end
        if kQ_4 then
            return v.Name
        end
    end
    return nil
end
iO = {}
iE = function()
    local k5 = {}
    local k6 = {}
    local k7 = ik()
    if k7 then
        for i, child in ipairs(k7:GetChildren()) do
            if child:IsA("Model") then
                local k7_1 = tostring(child.Name)
                local k8 = iu()
                local k9 = k8 and k8:FindFirstChild("Stands")
                local k8_1 = k9
                if k9 then
                    k9 = k8_1:FindFirstChild(k7_1)
                end
                local k8_2 = k9
                if k9 then
                    k9 = k8_2:FindFirstChild("Upgrade")
                end
                if k9 then
                    local k8_4 = string.format("%s | Cell %s", io(child), k7_1)
                    k6[#k6 + 1] = k8_4
                    k5[k8_4] = k7_1
                end
            end
        end
    end
    table.sort(k6)
    if #k6 == 0 then
        k6[1] = "No footballers found"
    end
    return k6, k5
end
i8_5, iO = iE()
jf_1:SetDescription("Building tabs and automation controls...")
jf_1:SetCurrentStep(3)
local Window = i2:CreateWindow({
    Title = "TempoHub",
    Footer = "Jump To Steal Soccer Players",
    Size = UDim2.fromOffset(860, 540),
    Center = true,
    AutoShow = true,
    Resizable = true,
    NotifySide = "Right",
    ShowCustomCursor = true
})
local MainTab = Window:AddTab("Main", "house", "Farm and upgrade automation")
local SettingsTab = Window:AddTab("Settings", "settings", "Interface, themes, and configs")
local FarmGroup = MainTab:AddLeftGroupbox("Farm", "sprout")
local PurchasesGroup = MainTab:AddLeftGroupbox("Purchases", "shopping-cart")
local UpgradesGroup = MainTab:AddRightGroupbox("Upgrades", "trending-up")
FarmGroup:AddToggle("AutoOGLuckyBlocks", {
    Text = "Auto Farm OG Lucky Blocks",
    Default = false,
    Tooltip = "Teleports to an OG Lucky Block, collects it, and returns to your base."
})
FarmGroup:AddToggle("AutoCollect", {
    Text = "Auto Collect Earnings",
    Default = false,
    Tooltip = "Collects earnings from every occupied footballer cell."
})
Label = FarmGroup:AddLabel("FarmStatus", { Text = "Status: Idle", DoesWrap = true })
PurchasesGroup:AddToggle("AutoUpgradeBase", { Text = "Auto Purchase Floor", Default = false })
PurchasesGroup:AddToggle("AutoBuyPads", { Text = "Auto Buy Pads", Default = false })
PurchasesGroup:AddToggle("AutoBuyCarry", { Text = "Auto Buy Extra Carry", Default = false })
UpgradesGroup:AddToggle("AutoUpgradeJump", { Text = "Auto Upgrade Jump", Default = false })
UpgradesGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
UpgradesGroup:AddToggle("AutoUpgradeFootballer", { Text = "Auto Upgrade Footballers", Default = false })
UpgradesGroup:AddDropdown("FootballerTarget", {
    Text = "Footballers",
    Values = i8_5,
    Default = {},
    Multi = true,
    AllowNull = true,
    Searchable = true,
    Tooltip = "Select one or more of your live footballer models."
})
local i8_6 = SettingsTab:AddPage("Interface", "Window and menu controls")
local ja_7 = SettingsTab:AddPage("Themes", "Theme manager")
local jb_4 = SettingsTab:AddPage("Configs", "Saved configurations")
local MenuGroup = i8_6:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddLabel("Menu key"):AddKeyPicker("MenuKeybind", { Default = "RightShift", Mode = "Toggle", NoUI = true, Text = "Menu keybind" })
i2.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddButton({
    Text = "Unload",
    DoubleClick = true,
    Func = function()
        i2:Unload()
    end
})
ThemeManager:SetFolder("TempoHub")
je_1:SetLibrary(i2)
je_1:IgnoreThemeSettings()
je_1:SetIgnoreIndexes({ "MenuKeybind" })
je_1:SetFolder("TempoHub")
je_1:SetSubFolder("soccergame")
ThemeManager:AddThemeOptions(ja_7)
je_1:BuildConfigSection(jb_4)
je_1:LoadAutoloadConfig()
jf_1:SetMessage("TempoHub is ready")
jf_1:SetDescription("Loaded without waiting for private game data.")
jf_1:SetCurrentStep(4)
jf_1:Continue()
i2:Toggle(true)
iB = false
iK = true
it = {}
ih = {}
i1 = nil
iW = 0
iM = function(ca)
    if Toggles.AutoOGLuckyBlocks and not Toggles.AutoOGLuckyBlocks.Value and ca ~= "Idle" then
        return
    end
    if i1 == ca then
        return
    end
    i1 = ca
    Label:SetText("Status: " .. ca)
end
Toggles.AutoOGLuckyBlocks:OnChanged(function(cf)
    local lv = cf and "Starting" or "Idle"
    iM(lv)
end)
local ja_8 = Toggles.AutoOGLuckyBlocks.Value and "Starting" or "Idle"
iM(ja_8)
connection = Send_Notification.OnClientEvent:Connect(function(ch)
    local lA = ch or ""
    local lB = tostring(lA)
    if not string.find(lB, "Captured OG Lucky Block! Return to base.", 1, true) then
        return
    end
    iW = iW + 1
    if Toggles.AutoOGLuckyBlocks.Value then
        iM("Captured; returning to base")
        i5(iT())
    end
end)
ii = function(cq, cr)
    if it[cq] then
        return
    end
    it[cq] = true
    i2:Notify({ Title = "TempoHub", Description = cr, Time = 5 })
end
iw = function()
    for i, v in ipairs(il()) do
        local lE = string.find(string.lower(v.Tool.Name), "og lucky block", 1, true) ~= nil
        if ih[v.Uid] or lE then
            ih[v.Uid] = true
            return v.Uid
        end
    end
    return nil
end
iy = function(cB)
    for i, v in ipairs(il()) do
        if v.Uid == cB then
            return true
        end
    end
    return false
end
iI = function(cG, cH)
    if not cG or not cH then
        return false
    end
    iM("Returning to base")
    i5(iT())
    task.wait(0.08)
    local lZ_1 = nil
    local l5 = 1
    while l5 <= 4 do
        iM("Placing OG block in cell " .. tostring(cG))
        Place_Slime:FireServer(cG, cH)
        local l__1 = os.clock() + 0.12
        while true do
            local l0 = iK and not lZ_1 and os.clock() < l__1
            if l0 then
                local l0_1 = ik()
                local l1 = l0_1 and l0_1:FindFirstChild(tostring(cG))
                lZ_1 = l1
                if not lZ_1 then
                    task.wait()
                end
                continue
            end
            break
        end
        if lZ_1 then
            break
        end
        l5 += 1
    end
    if not lZ_1 then
        iM("Placement failed; retrying")
        return false
    end
    iM("Opening OG block in cell " .. tostring(cG))
    Open_Lucky_Block:FireServer(cG)
    task.delay(0.2, function()
        local lU = ik()
        local lV = lU and lU:FindFirstChild(tostring(cG))
        local lV_1 = iu()
        local lW = lV_1 and lV_1:FindFirstChild("Stands")
        local lV_2 = lW
        if lW then
            lW = lV_2:FindFirstChild(tostring(cG))
        end
        local lV_3 = lV
        local lU_2 = lW
        if lV_3 then
            lV_3 = lU_2
        end
        if lV_3 then
            lV_3 = not lU_2:FindFirstChild("Upgrade")
        end
        if lV_3 then
            iM("Retrying open in cell " .. tostring(cG))
            Open_Lucky_Block:FireServer(cG)
        end
    end)
    task.delay(0.2, function()
        if not iy(cH) then
            ih[cH] = nil
            iM("Ready for next OG block")
        end
    end)
    return true
end
autoOGLuckyBlocksLoop = function()
    local mF_1
    local mE_1
    if iB then
        return
    end
    iB = true
    mE_1, mF_1 = pcall(function()
        local mh
        local mi = iQ()
        local mj = mi and iw()
        local mk = mj or nil
        if mi and mk then
            iI(mi, mk)
            return
        end
        local mi_1 = mi and "Searching for an OG block" or "Base full; collecting to carry"
        iM(mi_1)
        local Live = workspace:FindFirstChild("Live")
        local mj_3 = Live and Live:FindFirstChild("Slimes")
        if not mj_3 then
            iM("Waiting for Workspace.Live.Slimes")
            return
        end
        local mj_4 = nil
        local mk_2 = -1
        for i, child in ipairs(mj_3:GetChildren()) do
            local mi_4 = child:FindFirstChild("RootPart") or child.PrimaryPart
            local ml_1 = mi_4
            if mi_4 then
                mi_4 = ml_1:FindFirstChild("StealPrompt")
            end
            local ml_2 = mi_4
            local mi_5 = child.Name == "OG Lucky Block" and child:GetAttribute("heldBy") == nil and ml_2 and ml_2:IsA("ProximityPrompt") and ml_2.Enabled
            if mi_5 then
                local mi_6 = iR(child:GetPivot().Position)
                if mi_6 > mk_2 then
                    mj_4 = child
                    mk_2 = mi_6
                end
            end
        end
        if not mj_4 then
            iM("Waiting for an OG Lucky Block")
            return
        end
        local mi_7 = iv.fireproximityprompt or fireproximityprompt
        if type(mi_7) ~= "function" then
            ii("missing_prompt", "Your executor does not provide fireproximityprompt.")
            iM("fireproximityprompt is unavailable")
            return
        end
        local mi_8 = mj_4:FindFirstChild("RootPart") or mj_4.PrimaryPart
        local mm = mi_8
        if mi_8 then
            mi_8 = mm:FindFirstChild("StealPrompt")
        end
        local mm_1 = mi_8
        if mk_2 < math.huge then
            iM(string.format("Target %.0f studs from nearest guardian", mk_2))
        else
            iM("Targeting OG Lucky Block")
        end
        if not i5(mj_4:GetPivot()) then
            iM("Character root is unavailable")
            return
        end
        mh = {}
        for i, v in ipairs(il()) do
            mh[v.Uid] = true
        end
        local mi_9 = iW
        task.wait(0.08)
        iM("Collecting OG Lucky Block")
        pcall(mi_7, mm_1, 0)
        local function mj_5()
            local l8
            for i, v in ipairs(il()) do
                if not mh[v.Uid] then
                    ih[v.Uid] = true
                    l8 = l8 or v.Uid
                end
            end
            return l8
        end
        iM("Waiting for capture notification")
        local mk_3 = nil
        local ml_4 = iW > mi_9
        local mm_2 = os.clock() + 0.8
        while true do
            local mn = iK and Toggles.AutoOGLuckyBlocks.Value and not ml_4 and not mk_3 and os.clock() < mm_2
            if mn then
                mk_3 = mj_5()
                ml_4 = iW > mi_9
                if not mk_3 then
                    task.wait()
                end
                continue
            end
            break
        end
        local mi_10 = not mk_3
        local mm_3 = not ml_4
        if mm_3 ~= false then
            mm_3 = mi_10
        end
        if mm_3 then
            iM("Pickup not confirmed; retrying")
            return
        end
        if not i5(iT()) then
            iM("Base teleport unavailable")
            return
        end
        local mi_11 = iQ()
        if not mi_11 then
            iM("Base full; captured block kept in carry")
            task.wait(0.05)
            return
        end
        if not mk_3 then
            iM("At base; syncing captured block")
            local ml_5 = os.clock() + 0.65
            while true do
                local mm_4 = iK and Toggles.AutoOGLuckyBlocks.Value and not mk_3 and os.clock() < ml_5
                if mm_4 then
                    mk_3 = mj_5()
                    if not mk_3 then
                        task.wait()
                    end
                    continue
                end
                break
            end
        end
        if not mk_3 then
            iM("Captured at base; waiting for inventory")
            return
        end
        ih[mk_3] = true
        task.wait(0.05)
        iI(mi_11, mk_3)
    end)
    if not mE_1 then
        warn("[TempoHub] OG Lucky Block farm failed:", mF_1)
        iM("Error: " .. tostring(mF_1))
    end
    iB = false
end
i7 = function()
    local mK = ik()
    local mL = iu()
    local mM = mL and mL:FindFirstChild("Stands")
    if not mK or not mM then
        return
    end
    for i, child in ipairs(mK:GetChildren()) do
        if child:IsA("Model") then
            local mK_1 = tostring(child.Name)
            local mM_2 = mM:FindFirstChild(mK_1)
            local mN_1 = mM_2 and mM_2:FindFirstChild("Upgrade")
            if mN_1 then
                Collect_Earnings:FireServer(mK_1)
            end
        end
    end
end
i6 = function(en)
    local m0 = iu()
    local m1 = m0 and m0:FindFirstChild("Stands")
    local m0_1 = m1
    if m1 then
        m1 = m0_1:FindFirstChild(tostring(en))
    end
    local m0_2 = m1
    if m1 then
        m1 = m0_2:FindFirstChild("Upgrade")
    end
    local m0_3 = m1
    if m1 then
        m1 = m0_3:FindFirstChild("SurfaceGui")
    end
    local m0_4 = m1
    if m1 then
        m1 = m0_4:FindFirstChild("Frame")
    end
    local m0_5 = m1
    if m1 then
        m1 = m0_5:FindFirstChild("Button")
    end
    local m0_6 = m1
    if m1 then
        m1 = m0_6:FindFirstChild("Price")
    end
    local m0_7 = m1
    if m1 then
        m1 = ij(m0_7.Text)
    end
    return m1 or nil
end
iY = function()
    local Value = Options.FootballerTarget.Value
    if type(Value) ~= "table" then
        return
    end
    local m4 = i3()
    for k, v in pairs(Value) do
        local m5 = v and iO[k] or nil
        local m3_2 = m5
        if m5 then
            m5 = i6(m3_2)
        end
        local m6 = m5 or nil
        if m3_2 and m6 and m4 >= m6 then
            Upgrade_Slime:FireServer(m3_2)
            return
        end
    end
end
iD = function(eQ)
    local PlayerGui = iV:FindFirstChild("PlayerGui")
    local ng = PlayerGui and PlayerGui:FindFirstChild("JumpUpgrade")
    local nf_1 = ng
    if ng then
        ng = nf_1:FindFirstChild("Main")
    end
    local nf_2 = ng
    if ng then
        ng = nf_2:FindFirstChild("Container")
    end
    local nf_3 = ng
    if ng then
        ng = nf_3:FindFirstChild(tostring(eQ))
    end
    local nf_4 = ng
    if ng then
        ng = nf_4:FindFirstChild("Cash")
    end
    local nf_5 = ng
    if ng then
        ng = nf_5:FindFirstChild("TextLabel")
    end
    local nf_6 = ng
    if ng then
        ng = ij(nf_6.Text)
    end
    return ng or nil
end
iL = function()
    local ns
    local nl = i3()
    local nr = 3
    local nq = -1
    while true do
        if false and nr <= 1 or true and nr >= 1 then
            ns = nr
            local nm = iD(ns)
            if nm and nl >= nm then
                break
            end
            nr += nq
            continue
        end
        return
    end
    Buy_Speed_Upgrade:FireServer(ns)
    return
end
ix = function()
    local nu = iu()
    local nv = nu and nu:FindFirstChild("MainBase")
    if not nv then
        return
    end
    local nv_1 = {}
    for i, descendant in ipairs(nv:GetDescendants()) do
        local nu_2 = tonumber(descendant.Name:match("^PurchaseFloor(%d+)$"))
        if nu_2 then
            local Pad = descendant:FindFirstChild("Pad")
            local nx = Pad and Pad:FindFirstChild("Top")
            local nw_1 = nx
            if nx then
                nx = nw_1:FindFirstChild("TouchInterest")
            end
            local ny = nw_1
            local nz = nx
            if ny then
                ny = nw_1:FindFirstChild("BillboardGui")
            end
            local nw_2 = ny
            local nx_1 = nw_2 and nw_2:FindFirstChild("Frame")
            local nw_3 = nx_1
            if nx_1 then
                nx_1 = nw_3:FindFirstChild("Price")
            end
            local nw_4 = nx_1
            if nx_1 then
                nx_1 = ij(nw_4.Text)
            end
            local nw_5 = nx_1
            if nz and nw_5 then
                nv_1[#nv_1 + 1] = { Floor = nu_2, Price = nw_5 }
            end
        end
    end
    table.sort(nv_1, function(fx, fy)
        return fx.Floor < fy.Floor
    end)
    local nu_3 = nv_1[1]
    local nv_2 = nu_3 and i3() >= nu_3.Price
    if nv_2 then
        local nv_3 = 1 + (nu_3.Floor - 2) * 10
        Purchase_Floor:InvokeServer(nv_3)
    end
end
iH = function()
    local nK = iu()
    local nL = nK and nK:FindFirstChild("CollectPads")
    if not nL then
        return
    end
    local nL_1 = {}
    for i, child in ipairs(nL:GetChildren()) do
        local nK_2 = tonumber(child.Name)
        local Top = child:FindFirstChild("Top")
        local nN = Top and Top:FindFirstChild("TouchInterest")
        local nO = Top
        if nO then
            nO = Top:FindFirstChild("PurchaseInfo")
        end
        local nM_1 = nO
        local nN_1 = nM_1 and nM_1:FindFirstChild("Frame")
        local nO_1 = nN_1
        if nN_1 then
            nN_1 = nO_1:FindFirstChild("New")
        end
        local nQ = nO_1
        local nR = nN_1
        if nQ then
            nQ = nO_1:FindFirstChild("Price")
        end
        local nN_2 = nQ
        local nO_2 = nN_2 and ij(nN_2.Text)
        local nO_3 = nM_1 ~= nil
        local nQ_1 = nM_1
        if nQ_1 then
            local nS = nM_1:IsA("BillboardGui") or nM_1:IsA("SurfaceGui")
            nQ_1 = nS
        end
        if nQ_1 then
            nO_3 = nM_1.Enabled
        end
        if nK_2 and nK_2 > 10 and nN and nO_3 and nR and nO_2 then
            nL_1[#nL_1 + 1] = { Cell = nK_2, Price = nO_2 }
        end
    end
    table.sort(nL_1, function(f4, f5)
        return f4.Cell < f5.Cell
    end)
    local nK_3 = nL_1[1]
    local nL_2 = nK_3 and i3() >= nK_3.Price
    if nL_2 then
        Purchase_Floor:InvokeServer(nK_3.Cell - 10)
    end
end
im = function()
    local PlayerGui = iV:FindFirstChild("PlayerGui")
    local n3 = PlayerGui and PlayerGui:FindFirstChild("CarryUpgrades")
    local n2_1 = n3
    if n3 then
        n3 = n2_1:FindFirstChild("Main")
    end
    local n2_2 = n3
    if n3 then
        n3 = n2_2:FindFirstChild("Content")
    end
    local n2_3 = n3
    if n3 then
        n3 = n2_3:FindFirstChild("Cash")
    end
    local n2_4 = n3
    if n3 then
        n3 = n2_4:FindFirstChild("TextLabel")
    end
    local n4 = n2_4
    local n5 = n3
    if n4 then
        n4 = n2_4.Visible
    end
    if n4 and n5 then
        return ij(n5.Text)
    end
    return nil
end
iU = function()
    local od = im()
    local oe = od and i3() >= od
    if oe then
        Upgrade_Carry_Limit:FireServer()
    end
end
iX = {
    Lucky = 0,
    Collect = 0,
    Footballer = 0,
    Jump = 0,
    Floor = 0,
    Pad = 0,
    Carry = 0,
    Rebirth = 0,
    Dropdown = 0
}
iN = function(gx, gy, gz, gA)
    local og = os.clock()
    local og_1
    local oh = gz and og - iX[gx] >= gy
    local oh_1
    if oh then
        iX[gx] = og
        og_1, oh_1 = pcall(gA)
        if not og_1 then
            warn(string.format("[TempoHub] %s failed: %s", gx, tostring(oh_1)))
        end
    end
end
task.spawn(function()
    while iK and not i2.Unloaded do
        iN("Lucky", 0.15, Toggles.AutoOGLuckyBlocks.Value, function()
            task.spawn(autoOGLuckyBlocksLoop)
        end)
        iN("Collect", 0.75, Toggles.AutoCollect.Value, i7)
        iN("Footballer", 0.3, Toggles.AutoUpgradeFootballer.Value, iY)
        iN("Jump", 0.4, Toggles.AutoUpgradeJump.Value, iL)
        iN("Floor", 0.8, Toggles.AutoUpgradeBase.Value, ix)
        iN("Pad", 0.65, Toggles.AutoBuyPads.Value, iH)
        iN("Carry", 0.65, Toggles.AutoBuyCarry.Value, iU)
        iN("Rebirth", 1, Toggles.AutoRebirth.Value, function()
            Rebirth:FireServer()
        end)
        iN("Dropdown", 1.5, true, function()
            local ok_1
            local oj_1
            ok_1, oj_1 = iE()
            local ol = table.concat(ok_1, "\x00")
            local om = table.concat(Options.FootballerTarget.Values, "\x00")
            iO = oj_1
            if ol ~= om then
                Options.FootballerTarget:SetValues(ok_1)
            end
        end)
        task.wait(0.1)
    end
end)
ig = nil
ig = function()
    if not i2.Unloaded then
        i2:Unload()
    end
end
iv.TempoHubUnload = ig
i2:OnUnload(function()
    iK = false
    if connection.Connected then
        connection:Disconnect()
    end
    if iv.TempoHubUnload == ig then
        iv.TempoHubUnload = nil
    end
    select("#", "[TempoHub] Unloaded")
end)
end)(...)

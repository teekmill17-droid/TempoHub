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
getgenv().TempoHoodSubtitle = "+1 POWER JUJUTSU KAISEN EVOL"
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
local kN
local kq
local j7
local kQ
local kt
local ka
local kT
local Library
local kA
local kg
local kD
local kZ
local PowerUtils
local kj
local km
local k4
local kM
local kp
local Options
local kP
local ks
local j9
local kw
local MorphConfig
local kV
local kf
local ki
local kF
local k3
local ko
local kL
local k6
local j5
local j8
local kv
local kb
local kU
local Toggles
local kB
local kE
local TrainingZones
local TitleConfig
local kH
local k2
local kK
local k5
local function fn63()
    if not j8("AutoFarmWin") then
        return
    end
    local mm = kE
    if kL("WinFarmMode") == "Random" then
        mm = math.random(1, kE)
    end
    kU.ClaimWins:Fire(mm)
end
local function fn128()
    local Character = ko.Character
    local me = Character and Character:FindFirstChildOfClass("Humanoid")
    return me
end
local function fn143(c_)
    local DiscordGroup = c_:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = kv })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = kv })
end
local function worker()
    while not Library.Unloaded do
        if j8("AutoFarmWin") then
            pcall(kH)
            pcall(kH)
            pcall(kH)
        end
        task.wait()
    end
end
local function fn171()
    if not j8("AutoEquipBestTitle") then
        k4 = nil
        return
    end
    local mR = kT()
    if not mR then
        return
    end
    local mS = kV(mR)
    if not mS or mR.EquippedTitle == mS or k4 == mS then
        return
    end
    kU.ChangeTitleState:Fire(mS, true)
    k4 = mS
end
local function fn189(aA)
    if Library.Unloaded then
        return false
    end
    local lS = Toggles[aA]
    return lS ~= nil and lS.Value == true
end
local function fn190(b7)
    local ne = b7 and b7.UnlockedMorphs
    if type(ne) ~= "table" then
        return nil
    end
    local ne_1 = -1
    local ng
    local nh
    for k, v in MorphConfig.Morphs do
        if ne[k] then
            if v.BestMultiplier then
                ng = k
            else
                local ni = tonumber(v.Multiplier) or 0
                local ni_1 = ni > ne_1
                if not ni_1 then
                    local nk = ni == ne_1 and kP(k) > kP(nh)
                    ni_1 = nk
                end
                if ni_1 then
                    ne_1 = ni
                    nh = k
                end
            end
        end
    end
    return ng or nh
end
local function fn200(ad)
    if ad then
        k6[#k6 + 1] = ad
    end
    return ad
end
local function worker2()
    while not Library.Unloaded do
        if j8("AutoClick") then
            pcall(kt)
        end
        task.wait()
    end
end
local function fn230()
    if not j8("AutoTrain") then
        return
    end
    local nW = kT()
    if not nW then
        return
    end
    local nX = kN(nW)
    if not nX then
        return
    end
    local nW_1 = TrainingZones:FindFirstChild(nX)
    local nX_1 = nW_1 and nW_1:FindFirstChild("Zone")
    local nX_2 = not nX_1 or not nX_1:IsA("BasePart")
    if nX_2 then
        return
    end
    local nX_3 = kp()
    local nY = nX_1.CFrame * CFrame.new(0, 3, 0)
    if not nX_3 or (nX_3.Position - nX_1.Position).Magnitude > 10 then
        k3(nY)
    end
end
local function fn262(aG)
    local lV = Options[aG]
    return lV and lV.Value or nil
end
local function fn282(ag, ah)
    if setclipboard then
        setclipboard(ag)
    elseif toclipboard then
        toclipboard(ag)
    end
    Library:Notify(ah)
end
local function fn311()
    if not j8("AutoBuyMorphs") then
        return
    end
    local ns = kT()
    if not ns then
        return
    end
    local nt = tonumber(ns.Wins) or 0
    local UnlockedMorphs = ns.UnlockedMorphs
    local nv = false
    for k, v in k2 do
        local nw = type(UnlockedMorphs) == "table" and UnlockedMorphs[v.Id]
        if nw and true or false then
            km[v.Id] = true
        else
            if not km[v.Id] and nt >= v.Price then
                km[v.Id] = true
                kU.PurchaseMorph:Fire(v.Id)
                nv = true
                break
            end
        end
    end
    if nv then
        return
    end
    local nt_2 = kF(ns)
    if not nt_2 or kq == nt_2 or ns.EquippedMorph == nt_2 then
        if nt_2 then
            kq = nt_2
        end
        return
    end
    kU.EquipMorph:Fire(nt_2)
    kq = nt_2
end
local function fn328()
    if not j8("AutoClick") then
        return
    end
    kU.TapEvent:Fire()
end
local function fn339(bD)
    local mF = bD
    local mG
    local mH = -1
    if mF then
        mF = bD.Titles
    end
    local mI = mF
    if type(mI) ~= "table" then
        return nil
    end
    for k in mI do
        local mF_1 = TitleConfig[k]
        local mI_1 = mF_1 and tonumber(mF_1.Multiplier)
        local mF_2 = mI_1 or 0
        if mF_2 > mH then
            mH = mF_2
            mG = k
        end
    end
    return mG
end
local function fn388()
    if not j8("AutoBuyAura") then
        ki = nil
        return
    end
    local mW = kT()
    if not mW then
        return
    end
    local mX = tonumber(mW.Wins) or 0
    local mY = mX
    local Auras = mW.Auras
    local mZ = -1
    local Id
    for k, v in kA do
        local m0_1 = type(Auras) == "table" and Auras[v.Id] == true
        local m1 = m0_1
        local m0_2 = not m1
        if m0_2 ~= false then
            m0_2 = mY >= v.Cost
        end
        if m0_2 then
            kU.PurchaseAura:Fire(v.Id)
            mY -= v.Cost
            m1 = true
        end
        if m1 and v.Multiplier > mZ then
            mZ = v.Multiplier
            Id = v.Id
        end
    end
    if Id and mW.EquippedAura ~= Id and ki ~= Id then
        kU.ChangeAura:Fire(Id, true)
        ki = Id
    end
end
local function fn419(b5)
    local nc = tonumber(string.match(tostring(b5), "%d+")) or 0
    return nc
end
local function fn442()
    kQ(j9, "Copied Discord invite to clipboard")
end
local function fn469(cy)
    local nI = tonumber(cy.Rebirths) or 0
    local Gamepasses = cy.Gamepasses
    local nK = -1
    local nL
    for k, v in j5 do
        if type(v) == "table" then
            local nM = false
            if v.Product then
                local nN_1 = type(Gamepasses) == "table" and Gamepasses[v.Product] == true
                nM = nN_1
            elseif type(v.Rebirths) == "number" then
                nM = nI >= v.Rebirths
            end
            local nN_2 = tonumber(v.Multiplier) or 0
            local nO = nM
            if nO then
                nO = nN_2 > nK
            end
            if nO then
                nK = nN_2
                nL = k
            end
        end
    end
    return nL
end
local function fn476()
    if Toggles.AutoBuyMorphs.Value then
        kq = nil
        table.clear(km)
    end
end
local function fn535(a0)
    local Character = ko.Character
    if not Character then
        return
    end
    if Character.PrimaryPart then
        Character:PivotTo(a0)
    else
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = a0
        end
    end
end
local function fn557()
    if not j8("AutoBuyUpgrades") then
        return
    end
    local mu = kT()
    if not mu then
        return
    end
    local mv = kj(kL("UpgradeList"))
    local mw = tonumber(mu.Wins) or 0
    local mx = mw
    local Upgrades = mu.Upgrades
    for k in mv do
        local mu_1 = kK[k]
        local mv_1 = mu_1 and kw.Upgrades[mu_1]
        if mv_1 then
            local mv_2 = Upgrades and Upgrades[mu_1]
            local mz = tonumber(mv_2) or 0
            if mz < (mv_1.Max or 0) then
                local my_1 = kw.Prices[mz + 1]
                local mv_4 = type(my_1) == "number" and mx >= my_1
                if mv_4 then
                    kU.Upgrade:Fire(mu_1)
                    mx -= my_1
                end
            end
        end
    end
end
local function fn563(aq, ar, as)
    return string.format("<b>%s</b> %s %s", aq, kb("-", "#5a6070"), kb(ar, as))
end
local function fn571(T, U)
    if T.Multiplier == U.Multiplier then
        return T.Price < U.Price
    end
    return T.Multiplier > U.Multiplier
end
local function fn572()
    if not j8("AutoRebirth") then
        return
    end
    local mo = kT()
    if not mo then
        return
    end
    local mp = PowerUtils:GetLevelData(mo.Power, mo.Rebirths)
    local mo_1 = not mp
    local mt = if mo_1 then 1 else 0
    local mr = 3696 * mt + 2829 * (1 - mt)
    local ms = 643 * mt + 311 * (1 - mt)
    if not ((mr * 3510 + ms * 45 + mr * ms) % 16777213 == 15378423) then
        mo_1 = not mp.IsMax
    end
    if mo_1 then
        return
    end
    kU.Rebirth:Fire()
end
local function fn575(an, ao)
    return string.format('<font color="%s">%s</font>', ao, an)
end
local function fn606(aL)
    local l0 = {}
    if type(aL) == "table" then
        for k, v in aL do
            if v then
                l0[k] = true
            end
        end
    else
        local l1 = aL ~= ""
        local l2 = type(aL) == "string" and l1
        if l2 then
            l0[aL] = true
        end
    end
    return l0
end
local function worker3()
    local n5_1
    local n4_1
    while not Library.Unloaded do
        n4_1, n5_1 = pcall(function()
            j7()
            kB()
            kZ()
            ka()
            kf()
            kM()
        end)
        if not n4_1 then
            warn("[Tempo] farm loop:", n5_1)
            task.wait(0.5)
        else
            task.wait(0.15)
        end
    end
end
local function fn644()
    return k5 and k5.Data or nil
end
local function fn663()
    local Character = ko.Character
    local mh = Character and Character:FindFirstChild("HumanoidRootPart")
    return mh
end
local function worker4()
    while not Library.Unloaded do
        if j8("AutoRollTitle") then
            local n7 = kT()
            local n8 = n7
            if n8 then
                local n9 = tonumber(n7.Wins) or 0
                n8 = n9 >= 10
            end
            if n8 then
                pcall(function()
                    kU.RequestRoll:Fire()
                end)
            end
        end
        task.wait(0.2)
    end
end
local function fn702()
    local ob = hookfunction ~= nil
    local oc = hookmetamethod ~= nil
    local od = getrawmetatable ~= nil
    local oe = setrawmetatable ~= nil
    local of = getgc ~= nil
    local og = getgenv ~= nil
    local oh = getreg ~= nil
    local oi = getconnections ~= nil
    local oj = firesignal ~= nil
    local ol = getcallbackvalue ~= nil
    local om = setclipboard ~= nil
    local on = getcustomasset ~= nil
    local oo = getnamecallmethod ~= nil
    local op = isexecutorclosure ~= nil
    local oq = fireproximityprompt ~= nil
    local ot = firetouchinterest ~= nil
    local ou = WebSocket ~= nil
    local ov = readfile ~= nil
    local ow = writefile ~= nil
    local oy = (request or http_request) ~= nil
    local oA = (debug and debug.getupvalues) ~= nil
    local oC = (debug and debug.setupvalue) ~= nil
    local oD = 0
    local oE = { ob, oc, od, oe, of, og, oh, oi, oj, ol, om, on, oo, op, oq, ot, ou, ov, ow, oy, oA, oC }
    for i, v in ipairs(oE) do
        if v then
            oD += 1
        end
    end
    local ob_1 = oD / #oE
    if ob_1 >= 0.9 then
        return kb("Full Support", kD)
    elseif ob_1 >= 0.6 then
        return kb("Half Support", ks)
    else
        return kb("Low Support", kg)
    end
end
local function fn709(N, O)
    if N.Cost == O.Cost then
        return N.Multiplier > O.Multiplier
    end
    return N.Cost < O.Cost
end
j5 = nil
Options = nil
j7 = nil
j8 = nil
j9 = nil
ka = nil
kb = nil
MorphConfig = nil
Toggles = nil
kf = nil
kg = nil
ki = nil
kj = nil
TitleConfig = nil
km = nil
ko = nil
kp = nil
kq = nil
ks = nil
kt = nil
kv = nil
kw = nil
Library = nil
kA = nil
kB = nil
kD = nil
kE = nil
kF = nil
PowerUtils = nil
kH = nil
kK = nil
kL = nil
kM = nil
kN = nil
kP = nil
kQ = nil
local j4, kd, kh, SaveManager, kn, kr, ky, CoreGui, kC, kI, kJ, kO, kR, kS
kT = nil
kU = nil
kV = nil
kZ = nil
TrainingZones = nil
k2 = nil
k3 = nil
k4 = nil
k5 = nil
k6 = nil
local kW, kX, RunService, k0, k1, k7, k8
local li_1
local lh_1
local ld_1
local AuraConfig
local lf_1
local le_1
local Packet
local lb_1
local la_1
j4, lf_1, RunService, kS, kR, kO, kI, kC, CoreGui, kr, ko, kh, j9, k7, k1, le_1, ld_1, Packet, lb_1, PowerUtils, la_1, kw, AuraConfig, TitleConfig, MorphConfig, j5, k5, TrainingZones, kU, li_1, lh_1, kK, kE, kA = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local k9 = 108
repeat
    local lj_1 = (k9 * 13 + 6) % 20 + 1
    if lj_1 <= 10 then
        if lj_1 <= 5 then
            if lj_1 <= 3 then
                if lj_1 <= 2 then
                    if lj_1 <= 1 then
                        local sh = bit32.rrotate(bit32.bxor(bit32.lrotate(k9, 26), string.byte(tostring(kC))), 13)
                        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(sh, 2737858933), 1513505207), (bit32.bxor(bit32.band(sh, 1557108362), 1391392662))), 1513505207), 1391392662) == sh then
                            Packet = require(le_1:WaitForChild("Packet"))
                        else
                            le_1 = require(Packet:WaitForChild("Packet"))
                        end
                        k9 = (k9 + 97) % 160
                    else
                        local lk_1 = {
                            "qgpdxvb",
                            "znsfsufw",
                            "oaloggizz",
                            "lhp",
                            "enggsdreri",
                            "wigsimxq",
                            "lkih",
                            "ujhnnqqskhl",
                            "lzjc"
                        }
                        local sd = k9
                        local ll_1 = lk_1[sd % 9 + 1]
                        if ll_1:len() >= ll_1:gsub("(.)", "%1%1", sd % 3 % 2 + 1):len() then
                            lf_1 = require(lb_1:WaitForChild("ReplicaController"))
                        else
                            lb_1 = require(lf_1:WaitForChild("ReplicaController"))
                        end
                        k9 = (k9 + 97) % 160
                    end
                else
                    local lk_2 = {
                        "bmdfmuumv",
                        "cejfpbkyq",
                        "pgbdups",
                        "ettvogvcd",
                        "tcb",
                        "uztppyll",
                        "rjsjraym",
                        "kucrbdvoik",
                        "ssyqsvhrlymz",
                        "jadofwsihcft"
                    }
                    if lk_2[(k9 * 31 + 4) % 10 + 1] <= lk_2[(k9 * 31 + 4) % 10 + 1] then
                        PowerUtils = require(lf_1:WaitForChild("Shared"):WaitForChild("PowerUtils"))
                    else
                        lf_1 = require(PowerUtils:WaitForChild("Shared"):WaitForChild("PowerUtils"))
                    end
                    k9 = (k9 + 37) % 160
                end
            elseif lj_1 <= 4 then
                if ((lf_1 and lf_1 or not kr and kr or (not kr or not kr) and (lf_1 and lf_1)) and (lf_1 and kr and (lf_1 or not lf_1) or (kr or kr) and (not lf_1 or not kr)) or (lf_1 or not kr) and (not kr and kr) and (not kr and kr or not lf_1 and not lf_1) and ((kr and not kr or (lf_1 or lf_1)) and (kr or not kr or (lf_1 or not lf_1)))) and not ((lf_1 and lf_1 or not kr and kr or (not kr or not kr) and (lf_1 and lf_1)) and (lf_1 and kr and (lf_1 or not lf_1) or (kr or kr) and (not lf_1 or not kr)) or (lf_1 or not kr) and (not kr and kr) and (not kr and kr or not lf_1 and not lf_1) and ((kr and not kr or (lf_1 or lf_1)) and (kr or not kr or (lf_1 or not lf_1)))) then
                    ld_1 = require(la_1:WaitForChild("WallConfig"))
                else
                    la_1 = require(ld_1:WaitForChild("WallConfig"))
                end
                k9 = (k9 + 97) % 160
            else
                if ((not k5 or not j4) and (Packet and k5) or (not Packet or k5 or (Packet or k5))) and (not k5 or not k5 or (not Packet or TitleConfig) or (TitleConfig and not Packet or PowerUtils and TitleConfig)) or not (((not k5 or not j4) and (Packet and k5) or (not Packet or k5 or (Packet or k5))) and (not k5 or not k5 or (not Packet or TitleConfig) or (TitleConfig and not Packet or PowerUtils and TitleConfig))) then
                    kw = require(ld_1:WaitForChild("UpgradeConfig"))
                else
                    ld_1 = require(kw:WaitForChild("UpgradeConfig"))
                end
                k9 = (k9 + 57) % 160
            end
        elseif lj_1 <= 8 then
            if lj_1 <= 7 then
                if lj_1 <= 6 then
                    local lk_3 = (vector.create((k9 * 2 + 2) % 11 + 1, (k9 * 10 + 3) % 13 + 1, (k9 * 5 + 15) % 17 + 1))
                    local ll_2 = (vector.create((k9 * 4 + 3) % 11 + 1, (k9 * 8 + 10) % 13 + 1, (k9 * 7 + 2) % 17 + 1))
                    local lm_1 = (vector.create((k9 * 3 + 6) % 11 + 1, (k9 * 6 + 5) % 13 + 1, (k9 * 11 + 9) % 17 + 1))
                    local ln_1 = (vector.create((k9 * 4 + 3) % 5 + 1, (k9 * 3 + 1) % 7 + 1, (k9 * 3 + 6) % 9 + 1))
                    if vector.dot(vector.cross(lk_3, (vector.cross(ll_2, lm_1))), ln_1) == vector.dot(ll_2 * vector.dot(lk_3, lm_1) - lm_1 * vector.dot(lk_3, ll_2), ln_1) then
                        AuraConfig = require(ld_1:WaitForChild("AuraConfig"))
                    else
                        ld_1 = require(AuraConfig:WaitForChild("AuraConfig"))
                    end
                    k9 = (k9 + 117) % 160
                else
                    local sc = bit32.rrotate(bit32.bxor(bit32.lrotate(k9, 19), string.byte(tostring(le_1))), 24)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(sc, 3248324422), 28), 1813633012) ~= bit32.lrotate(sc, 28) then
                        ld_1 = require(TitleConfig:WaitForChild("TitleConfig"))
                    else
                        TitleConfig = require(ld_1:WaitForChild("TitleConfig"))
                    end
                    k9 = (k9 + 157) % 160
                end
            else
                if (not PowerUtils or not PowerUtils) and (PowerUtils or TrainingZones) and (not kO and MorphConfig or (MorphConfig or ko)) or not ((not PowerUtils or not PowerUtils) and (PowerUtils or TrainingZones) and (not kO and MorphConfig or (MorphConfig or ko))) then
                    MorphConfig = require(ld_1:WaitForChild("MorphConfig"))
                else
                    ld_1 = require(MorphConfig:WaitForChild("MorphConfig"))
                end
                k9 = (k9 + 37) % 160
            end
        elseif lj_1 <= 9 then
            local lk_4 = { "hfk", "evw", "driqginlj", "cvvrgm", "jjsay", "vuxug", "kvowv" }
            local se = k9
            local ll_3 = lk_4[se % 7 + 1]
            if ll_3:len() >= ll_3:gsub("(.)", "%1%1", se % 3 % 2 + 1):len() then
                kr = require(kU:WaitForChild("TrainingConfig"))
                lb_1 = Packet:GetReplica()
                k5 = TrainingZones:WaitForChild("TrainingZones")
                li_1 = {
                    PurchaseMorph = ld_1("PurchaseMorph", ld_1.String),
                    ChangeAura = ld_1("ChangeAura", ld_1.String, ld_1.Boolean8),
                    ClaimWins = ld_1("ClaimWins", ld_1.NumberS8),
                    RequestRoll = ld_1("RequestRoll"):Response(ld_1.String, ld_1.NumberS8),
                    EquipMorph = ld_1("EquipMorph", ld_1.String),
                    ChangeTitleState = ld_1("ChangeTitleState", ld_1.String, ld_1.Boolean8),
                    PurchaseAura = ld_1("PurchaseAura", ld_1.String),
                    TapEvent = ld_1("TapEvent"),
                    Rebirth = ld_1("Rebirth"),
                    Upgrade = ld_1("Upgrade", ld_1.String)
                }
                j5 = { "Best", "Random" }
            else
                j5 = require(ld_1:WaitForChild("TrainingConfig"))
                k5 = lb_1:GetReplica()
                TrainingZones = kr:WaitForChild("TrainingZones")
                kU = {
                    ClaimWins = Packet("ClaimWins", Packet.NumberS8),
                    Rebirth = Packet("Rebirth"),
                    Upgrade = Packet("Upgrade", Packet.String),
                    RequestRoll = Packet("RequestRoll"):Response(Packet.String, Packet.NumberS8),
                    ChangeTitleState = Packet("ChangeTitleState", Packet.String, Packet.Boolean8),
                    PurchaseAura = Packet("PurchaseAura", Packet.String),
                    ChangeAura = Packet("ChangeAura", Packet.String, Packet.Boolean8),
                    PurchaseMorph = Packet("PurchaseMorph", Packet.String),
                    EquipMorph = Packet("EquipMorph", Packet.String),
                    TapEvent = Packet("TapEvent")
                }
                li_1 = { "Best", "Random" }
            end
            k9 = (k9 + 97) % 160
        else
            if k9 * 85454845 + 8 + 6 >= k9 * 85454845 + 8 + 6 + 2 then
                kA = { "Speed", "Training Rate", "Luck" }
                lh_1 = { ["Training Rate"] = "TrainingRate", Luck = "Luck", Speed = "Speed" }
                la_1 = #kE.Walls
                kK = {}
            else
                lh_1 = { "Speed", "Training Rate", "Luck" }
                kK = { Speed = "Speed", ["Training Rate"] = "TrainingRate", Luck = "Luck" }
                kE = #la_1.Walls
                kA = {}
            end
            k9 = (k9 + 137) % 160
        end
    elseif lj_1 <= 15 then
        if lj_1 <= 13 then
            if lj_1 <= 12 then
                if lj_1 <= 11 then
                    if k9 * 59937601 + 8 + 3 <= k9 * 59937601 + 8 + 3 + 6 then
                        j4 = game:GetService("Players")
                    else
                        kw = game:GetService("Players")
                    end
                    k9 = (k9 + 77) % 160
                else
                    if (kK and TrainingZones or (not kU or kU)) and ((not kU or not TrainingZones) and (TrainingZones or not TrainingZones)) and (kU and kU or (kK or TrainingZones) or (not kU or not kU or (not TrainingZones or not TrainingZones))) and (TrainingZones and TrainingZones and (not kK or not TrainingZones) and (kK and kU and (not TrainingZones or not kK)) or ((kU or not kU) and (not kU and TrainingZones) or not kU and not TrainingZones and (not kK and kU))) and not ((kK and TrainingZones or (not kU or kU)) and ((not kU or not TrainingZones) and (TrainingZones or not TrainingZones)) and (kU and kU or (kK or TrainingZones) or (not kU or not kU or (not TrainingZones or not TrainingZones))) and (TrainingZones and TrainingZones and (not kK or not TrainingZones) and (kK and kU and (not TrainingZones or not kK)) or ((kU or not kU) and (not kU and TrainingZones) or not kU and not TrainingZones and (not kK and kU)))) then
                        lb_1 = game:GetService("ReplicatedStorage")
                    else
                        lf_1 = game:GetService("ReplicatedStorage")
                    end
                    k9 = (k9 + 97) % 160
                end
            else
                if (kr and not kr or (not j4 or not j4)) and (not j4 and not j4 and (not j4 and not j4)) or not ((kr and not kr or (not j4 or not j4)) and (not j4 and not j4 and (not j4 and not j4))) then
                    RunService = game:GetService("RunService")
                else
                    kE = game:GetService("RunService")
                end
                k9 = (k9 + 137) % 160
            end
        elseif lj_1 <= 14 then
            local lk_5 = {
                "jmdabuuiix",
                "rqvyyiunpnl",
                "uclhraxqev",
                "ggcwhykpt",
                "ftzrh",
                "kgs",
                "exfaa",
                "esotfkuzm",
                "nyayjeiuml",
                "drwxhrrdw",
                "xsjwzmpkg",
                "qlhe"
            }
            local rS = k9
            local ll_4 = lk_5[rS % 12 + 1]
            if ll_4:len() <= ll_4:reverse():rep(rS % 3 + 2):len() then
                kS = game:GetService("UserInputService")
                kR = game:GetService("VirtualUser")
                kO = game:GetService("HttpService")
            else
                kO = game:GetService("UserInputService")
                kS = game:GetService("VirtualUser")
                kR = game:GetService("HttpService")
            end
            k9 = (k9 + 97) % 160
        else
            if (k9 * 2 + 5) * 16 % 3 == ((k9 * 2 + 5) * 16 + 3) % 3 then
                kI = game:GetService("GuiService")
                kC = game:GetService("TeleportService")
            else
                kC = game:GetService("GuiService")
                kI = game:GetService("TeleportService")
            end
            k9 = (k9 + 17) % 160
        end
    elseif lj_1 <= 18 then
        if lj_1 <= 17 then
            if lj_1 <= 16 then
                local lk_6 = (vector.create((k9 * 4 + 6) % 11 + 1, (k9 * 11 + 8) % 13 + 1, (k9 * 10 + 14) % 17 + 1))
                local ll_5 = (vector.create((k9 * 5 + 8) % 11 + 1, (k9 * 7 + 10) % 13 + 1, (k9 * 9 + 9) % 17 + 1))
                local lm_2 = (vector.create((k9 * 4 + 3) % 5 + 1, (k9 * 3 + 6) % 7 + 1, (k9 * 5 + 6) % 9 + 1))
                if math.abs((vector.angle(lk_6, ll_5, lm_2))) - math.abs((vector.angle(ll_5, lk_6, lm_2))) == 4 then
                    li_1 = game:GetService("CoreGui")
                else
                    CoreGui = game:GetService("CoreGui")
                end
                k9 = (k9 + 157) % 160
            else
                if (k9 * 3 + 5) * 13 % 4 == ((k9 * 3 + 5) * 13 + 14) % 4 then
                    j5 = game:GetService("Workspace")
                else
                    kr = game:GetService("Workspace")
                end
                k9 = (k9 + 77) % 160
            end
        else
            local lk_7 = (vector.create((k9 * 7 + 9) % 11 + 1, (k9 * 11 + 6) % 13 + 1, (k9 * 2 + 5) % 17 + 1))
            local ll_6 = (vector.create((k9 * 6 + 7) % 11 + 1, (k9 * 8 + 6) % 13 + 1, (k9 * 7 + 11) % 17 + 1))
            local lm_3 = (vector.create((k9 * 1 + 2) % 11 + 1, (k9 * 8 + 6) % 13 + 1, (k9 * 11 + 7) % 17 + 1))
            local ln_2 = (vector.create((k9 * 4 + 1) % 5 + 1, (k9 * 5 + 6) % 7 + 1, (k9 * 4 + 3) % 9 + 1))
            if vector.dot(vector.cross(lk_7, (vector.cross(ll_6, lm_3))), ln_2) == vector.dot(ll_6 * vector.dot(lk_7, lm_3) - lm_3 * vector.dot(lk_7, ll_6), ln_2) then
                ko = j4.LocalPlayer
                kh = "+1 Power Jujutsu Kaisen Evolution"
                j9 = "https://discord.gg/K7Qxnxkk46"
                k7 = "https://discord.gg/K7Qxnxkk46"
                k1 = "https://tempohub.shop"
            else
                j9 = nil
                k7 = "+1 Power Jujutsu Kaisen Evolution"
                j4 = "https://discord.gg/K7Qxnxkk46"
                kh = "https://discord.gg/K7Qxnxkk46"
                ko = "https://tempohub.shop"
            end
            k9 = (k9 + 97) % 160
        end
    elseif lj_1 <= 19 then
        local lj_2 = { "wgpkkvwdz", "lxtxug", "arepzst", "lyn", "typwvtqf", "ehoaewk", "azciik" }
        local sb = k9
        local lk_8 = lj_2[sb % 7 + 1]
        if lk_8:len() >= lk_8:gsub("(.)", "%1%1", sb % 3 % 2 + 1):len() then
            lf_1 = le_1:WaitForChild("Packages")
        else
            le_1 = lf_1:WaitForChild("Packages")
        end
        k9 = (k9 + 97) % 160
    else
        local rG = bit32.rrotate(bit32.bxor(bit32.lrotate(k9, 21), string.byte(tostring(kr))), 11)
        if bit32.bxor(bit32.lrotate(bit32.bxor(rG, 2574890237), 18), 3556140518) ~= bit32.lrotate(rG, 18) then
            lf_1 = ld_1:WaitForChild("Config")
        else
            ld_1 = lf_1:WaitForChild("Config")
        end
        k9 = (k9 + 157) % 160
    end
until (k9 * 67 + 60) % 160 == 156
for k, v in AuraConfig do
    local k9_1 = type(v) == "table" and type(v.Cost) == "number"
    if k9_1 then
        local k9_2 = #kA + 1
        local Cost = v.Cost
        local lb_2 = tonumber(v.Multiplier) or 0
        kA[k9_2] = { Id = k, Cost = Cost, Multiplier = lb_2 }
    end
end
k2 = nil
local la_3 = 2
repeat
    if (la_3 * 2 + 1) * 16 % 3 == ((la_3 * 2 + 1) * 16 + 3) % 3 then
        table.sort(kA, fn709)
        k2 = {}
    else
        table.sort(k2, fn709)
        kA = {}
    end
    la_3 = (la_3 + 1) % 4
until (la_3 * 3 + 0) % 4 == 1
for k, v in MorphConfig.Morphs do
    local k9_3 = type(v) == "table" and type(v.Price) == "number" and v.Product == nil
    if k9_3 then
        local k9_4 = #k2 + 1
        local Price = v.Price
        local lb_3 = tonumber(v.Multiplier) or 0
        k2[k9_4] = { Id = k, Price = Price, Multiplier = lb_3 }
    end
end
Library, SaveManager, Toggles, Options, k6, kD, ky, ks, kn, kg, k4, ki, kq, km, k8, k0, kQ, kv, kb, kX, j8, kL, kj, kT, kJ, kp, k3, kH, j7, kB, kV, kZ, ka, kP, kF, kf, kN, kM, kt = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
table.sort(k2, fn571)
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
k6 = {}
k0 = fn200
kQ = fn282
kv = fn442
kb = fn575
kX = fn563
kD = "#7fd47f"
ky = "#6ec1ff"
ks = "#e8a34d"
kn = "#8b93a3"
kg = "#e05a5a"
j8 = fn189
kL = fn262
kj = fn606
kT = fn644
kJ = fn128
kp = fn663
k3 = fn535
kH = fn63
j7 = fn572
kB = fn557
kV = fn339
k4 = nil
kZ = fn171
ki = nil
ka = fn388
kP = fn419
kF = fn190
kq = nil
km = {}
kf = fn311
kN = fn469
kM = fn230
kt = fn328
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = j9, Copyable = true }, "|", kh },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
k8 = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gamepad-2"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in k8 do
    if k ~= "Info" then
        fn143(v)
    end
end
kd, kW = nil, nil
local FarmGroup = k8.Main:AddLeftGroupbox("Farm", "swords")
FarmGroup:AddToggle("AutoFarmWin", { Text = "Auto Farm Win", Default = false })
FarmGroup:AddDropdown("WinFarmMode", { Text = "Win Mode", Values = li_1, Default = 1 })
FarmGroup:AddToggle("AutoClick", { Text = "Auto Click", Default = false })
FarmGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
FarmGroup:AddToggle("AutoTrain", { Text = "Auto Train", Default = false })
local ShopGroup = k8.Main:AddRightGroupbox("Shop", "shopping-cart")
ShopGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
ShopGroup:AddDropdown("UpgradeList", { Text = "Upgrades", Values = lh_1, Default = {}, Multi = true })
ShopGroup:AddToggle("AutoRollTitle", { Text = "Auto Roll Title", Default = false })
ShopGroup:AddToggle("AutoEquipBestTitle", { Text = "Auto Equip Best Title", Default = false })
ShopGroup:AddToggle("AutoBuyAura", { Text = "Auto Buy Aura", Default = false })
ShopGroup:AddToggle("AutoBuyMorphs", { Text = "Auto Buy Morphs", Default = false })
Toggles.AutoBuyMorphs:OnChanged(fn476)
task.spawn(worker)
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
kW = fn702
local function lg_2()
    local o7
    local o3
    o3 = nil
    o7 = nil
    local Label3, o5, o6, Label, Label2
    o7 = "Unknown"
    pcall(function()
        local oN_1
        local oM_1
        if identifyexecutor then
            oN_1, oM_1 = identifyexecutor()
            local oO = oN_1 ~= ""
            local oP = type(oN_1) == "string" and oO
            if oP then
                local oO_1 = type(oM_1) == "string" and oM_1 ~= "" and oN_1 .. " " .. oM_1
                o7 = oO_1 or oN_1
            end
        end
    end)
    local pa = kW()
    o3 = os.clock()
    o6 = function()
        local oU = math.floor(os.clock() - o3)
        if oU < 60 then
            return oU .. "s"
        elseif oU < 3600 then
            return string.format("%dm %ds", math.floor((oU) / (60)), oU % 60)
        else
            return string.format("%dh %dm", math.floor((oU) / (3600)), math.floor((oU % 3600) / (60)))
        end
    end
    local UserGroup = k8.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = ko, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(kX("User", ko.DisplayName .. " @" .. ko.Name, kD), true)
    UserGroup:AddLabel(kX("UserId", tostring(ko.UserId), ky), true)
    UserGroup:AddLabel(kX("Executor", o7 .. "  " .. pa, kD), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(kX("Session", o6(), ks), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            kQ(ko.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            kQ("https://www.roblox.com/users/" .. tostring(ko.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = k8.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(kX("Game", kh, ky), true)
    Label2 = SessionGroup:AddLabel(kX("Players", "0/0", kD), true)
    o5 = tostring(game.JobId)
    local pb_1 = #o5 > 18 and string.sub(o5, 1, 18) .. "..."
    local pc = pb_1
    local pg = if pc then 1 else 0
    local pe = 2469 * pg + 4047 * (1 - pg)
    local pf = 2514 * pg + 677 * (1 - pg)
    if not ((pe * 638 + pf * 1518 + pe * pf) % 16777213 == 11598540) then
        pc = o5
    end
    local pb_2 = pc
    SessionGroup:AddLabel(kX("Job", pb_2, kn), true)
    Label = SessionGroup:AddLabel(kX("Ping", "0 ms", ks), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            kC:Teleport(game.PlaceId, ko)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            kQ(o5, "Copied Job ID")
        end
    })
    task.spawn(function()
        local o__1
        local oZ_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(kX("Session", o6(), ks))
            Label2:SetText(kX("Players", #j4:GetPlayers() .. "/" .. tostring(j4.MaxPlayers), kD))
            oZ_1, o__1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local oZ_2 = oZ_1 and o__1 .. " ms" or "n/a"
            Label:SetText(kX("Ping", oZ_2, ks))
        end
    end)
    local SocialsGroup = k8.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = kv })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            if setclipboard then
                setclipboard(k7)
            elseif toclipboard then
                toclipboard(k7)
            end
            Library:Notify("Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            kQ(k1, "Copied website link")
        end
    })
end
lg_2()
local function lj_3()
    local MovementGroup = k8.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = k8.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    k0(RunService.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = ko.Character
            if Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    local ph_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if ph_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end))
    k0(kS.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local pp_1 = kJ()
            if pp_1 then
                pp_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end))
    local CurrentCamera = kr.CurrentCamera
    k0(RunService.RenderStepped:Connect(function(fc)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local pr_1 = kJ()
            if pr_1 then
                pr_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local pr_3 = kp()
            local ps = kJ()
            if pr_3 and ps then
                ps.PlatformStand = true
                local ps_1 = Vector3.zero
                if kS:IsKeyDown(Enum.KeyCode.W) then
                    ps_1 = ps_1 + CurrentCamera.CFrame.LookVector
                end
                if kS:IsKeyDown(Enum.KeyCode.S) then
                    ps_1 = ps_1 - CurrentCamera.CFrame.LookVector
                end
                local px = if kS:IsKeyDown(Enum.KeyCode.A) then 1 else 0
                if px == 1 then
                    ps_1 = ps_1 - CurrentCamera.CFrame.RightVector
                end
                if kS:IsKeyDown(Enum.KeyCode.D) then
                    ps_1 = ps_1 + CurrentCamera.CFrame.RightVector
                end
                if kS:IsKeyDown(Enum.KeyCode.Space) then
                    ps_1 = ps_1 + Vector3.new(0, 1, 0)
                end
                local pA = if kS:IsKeyDown(Enum.KeyCode.LeftControl) then 1 else 0
                if pA == 1 then
                    ps_1 = ps_1 - Vector3.new(0, 1, 0)
                end
                pr_3.Velocity = Vector3.zero
                if ps_1.Magnitude > 0 then
                    pr_3.CFrame = pr_3.CFrame + ps_1.Unit * Options.FlySpeed.Value * fc
                end
            end
        end
    end))
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local pB = kJ()
            if pB then
                pB.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local pD = kJ()
            if pD then
                pD.WalkSpeed = 16
            end
        end
    end)
    local function fy(fz)
        pcall(function()
            kI:SetGameplayPausedNotificationEnabled(not fz)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not fz
            end
        end)
        if not fz then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(ko, "GameplayPaused", false)
            else
                ko.GameplayPaused = false
            end
        end)
    end
    Toggles.AntiGameplayPause:OnChanged(function()
        fy(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                fy(true)
            end
        end
    end)
    local function fQ(fR)
        if not fR:IsA("ProximityPrompt") then
            return
        end
        fR.HoldDuration = 0
        fR.MaxActivationDistance = 50
        fR.RequiresLineOfSight = false
    end
    local connection
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in ipairs(kr:GetDescendants()) do
                pcall(fQ, descendant)
            end
            connection = kr.DescendantAdded:Connect(function(fZ)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(fQ, fZ)
                end
            end)
            k0(connection)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    Library:OnUnload(function()
        fy(false)
        if connection then
            connection:Disconnect()
        end
    end)
end
lj_3()
local function lc_2()
    local MenuGroup = k8.Settings:AddLeftGroupbox("Menu")
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    local f9 = 0
    local ga = tick()
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = MenuGroup:AddLabel("AFK triggers: 0")
    local function gc()
        local CurrentCamera = kr.CurrentCamera
        if not CurrentCamera then
            return
        end
        kR:CaptureController()
        kR:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        f9 = f9 + 1
        ga = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. f9)
        end)
    end
    local connection = ko.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(gc)
        end
    end)
    k0(connection)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local p2 = Toggles.AntiAfk.Value and tick() - ga >= 60
            if p2 then
                pcall(gc)
            end
        end
    end)
    MenuGroup:AddButton({
        Text = "Unload UI",
        Func = function()
            Library:Unload()
        end
    })
end
lc_2()
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("MyScriptHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(k8.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/Plus1PowerJujutsuKaisenEvolution")
kd = SaveManager:BuildConfigSection(k8.Settings)
SaveManager:LoadAutoloadConfig()
local function k9_5()
    local function gB(gC, gD)
        local p5_1 = (gC == "Toggle" and Toggles or Options)[gD]
        local p4_2 = type(p5_1) == "table" and p5_1.Type == gC
        return p4_2 and p5_1 or nil
    end
    local function gL(gM, gN)
        local Type = gN.Type
        if Type == "Toggle" then
            return { idx = gM, type = "Toggle", value = gN.Value == true }
        elseif Type == "Slider" then
            return { idx = gM, type = "Slider", value = tostring(gN.Value) }
        elseif Type == "Dropdown" then
            return { idx = gM, type = "Dropdown", multi = gN.Multi == true, value = gN.Value }
        elseif Type == "Input" then
            local qc = gN.Value or ""
            return { idx = gM, type = "Input", text = tostring(qc) }
        elseif Type == "ColorPicker" then
            return { idx = gM, type = "ColorPicker", value = gN.Value:ToHex(), transparency = gN.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = gM,
                type = "KeyPicker",
                mode = gN.Mode,
                key = gN.Value,
                modifiers = gN.Modifiers,
                toggled = gN.Toggled
            }
        else
            return nil
        end
    end
    local function gP()
        local qf = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local qg = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if qg then
                    local qg_1 = gL(k, v)
                    if qg_1 then
                        qf[#qf + 1] = qg_1
                    end
                end
            end
        end
        table.sort(qf, function(gZ, g_)
            if gZ.type ~= g_.type then
                return gZ.type < g_.type
            end
            return gZ.idx < g_.idx
        end)
        return { objects = qf }
    end
    local function g0(g1)
        local qw
        qw = nil
        local qx = type(g1) ~= "table"
        local qB = if qx then 1 else 0
        local qz = 2031 * qB + 2525 * (1 - qB)
        local qA = 1349 * qB + 1354 * (1 - qB)
        if not ((qz * 3230 + qA * 855 + qz * qA) % 16777213 == 10453344) then
            qx = type(g1.idx) ~= "string"
        end
        if not qx then
            qx = type(g1.type) ~= "string"
        end
        if not qx then
            qx = SaveManager.Ignore[g1.idx]
        end
        if qx then
            return false
        end
        qw = gB(g1.type, g1.idx)
        if not qw then
            return false
        end
        local qx_1 = pcall(function()
            if g1.type == "Input" then
                if type(g1.text) ~= "string" then
                    return
                end
                qw:SetValue(g1.text)
            elseif g1.type == "ColorPicker" then
                qw:SetValueRGB(Color3.fromHex(g1.value), g1.transparency)
            elseif g1.type == "KeyPicker" then
                qw:SetValue({ g1.key, g1.mode, g1.modifiers })
                if g1.mode == "Toggle" and g1.toggled ~= nil then
                    qw.Toggled = g1.toggled
                    qw:Update()
                end
            else
                qw:SetValue(g1.value)
            end
        end)
        return qx_1
    end
    kd:AddDivider()
    kd:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    kd:AddButton("Export Config to Clipboard", function()
        local qD_1
        local qC_1
        qC_1, qD_1 = pcall(kO.JSONEncode, kO, gP())
        if not qC_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local qC_2 = setclipboard or toclipboard
        local qC_3 = type(qC_2) ~= "function" or not pcall(qC_2, qD_1)
        if qC_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    kd:AddButton("Import Config from Clipboard Text", function()
        local qI_1
        local qG = Options.SaveManager_ImportSource.Value or ""
        local qG_1
        local qH = tostring(qG):match("^%s*(.-)%s*$")
        if qH == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        qG_1, qI_1 = pcall(kO.JSONDecode, kO, qH)
        local qH_1 = not qG_1 or type(qI_1) ~= "table" or type(qI_1.objects) ~= "table"
        if qH_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local qG_2 = 0
        for i, v in ipairs(qI_1.objects) do
            if g0(v) then
                qG_2 += 1
            end
        end
        if qG_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local qI_2 = qG_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(qG_2, qI_2), 6)
    end)
end
k9_5()
Library:OnUnload(function()
    for k, v in k6 do
        local qZ = v
        pcall(function()
            qZ:Disconnect()
        end)
    end
    table.clear(k6)
end)
end)(...)

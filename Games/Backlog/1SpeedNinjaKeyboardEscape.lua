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
getgenv().TempoHoodSubtitle = "+1 SPEED NINJA KEYBOARD ESCA"
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
local uy
local vf
local uf
local uX
local uE
local CoreGui
local t2
local uK
local ur
local t8
local uQ
local ux
local ue
local uW
local uD
local vk
local uk
local u1
local LocalPlayer
local vq
local uq
local u7
local t7
local vw
local vd
local ud
local uC
local uj
local u0
local uI
local State
local up
local u6
local t6
local vv
local uv
local vc
local uc
local uU
local uB
local vi
local ui
local u_
local uH
local vo
local uo
local u5
local t5
local uN
local vu
local uu
local vb
local ub
local uT
local uA
local vh
local uh
local uG
local vn
local un
local u4
local t4
local uM
local vt
local ut
local ua
local uS
local uz
local vg
local ug
local uY
local uF
local um
local u3
local t3
local uL
local vs
local us
local u9
local t9
local uR
function fns.fn44()
    local C9 = uh()
    if C9 then
        ui:FireServer(C9)
    end
end
function fns.fn68()
    return CoreGui
end
function fns.fn77()
    return vs:FindFirstChild("WinsClaimContainer")
end
function fns.worker()
    while t5() do
        um()
        u6()
        task.wait(2)
    end
end
function fns.fn91(dE)
    if not dE then
        return
    end
    local Model = dE.Model
    if Model and Model.Parent then
        local yH_1 = uM(Model)
        if yH_1 then
            return Model, yH_1
        end
        ur(Model:GetPivot().Position)
        return
    end
    u6()
    dE = State.TreadByLabel[dE.Label]
    if dE and dE.Model and dE.Model.Parent then
        return dE.Model, uM(dE.Model)
    end
end
function fns.fn101()
    local CR = t8()
    local CT
    for k, v in vi() do
        if CR[v.Speed] and (not CT or v.Speed > CT.Speed) then
            CT = v
        end
    end
    return CT
end
function fns.fn117(dB)
    local yE = tonumber(uT.TreadmillWinsPrices[dB]) or 0
    return yE
end
function fns.fn132(Z)
    return type(Z) == "function"
end
function fns.fn147()
    local y5 = vk({ "Katanas" })
    local y6 = 0
    if type(y5) == "table" then
        for k, v in y5 do
            if v == true then
                y6 += 1
            end
        end
    end
    return y6
end
local function fn151()
    u6()
end
local function fn165()
    local BO_1
    local BN_1
    u6()
    local BM = uv()
    if not BM then
        return false
    end
    BO_1, BN_1 = uE(BM)
    if not BN_1 then
        if BO_1 then
            ur(BO_1:GetPivot().Position)
        end
        return true
    end
    State.OpenGamepass = nil
    local BP = uU(BN_1)
    if BP then
        t4(BP)
    end
    uI(BN_1)
    local Part = BO_1:FindFirstChild("Part")
    local BO_2 = Part and Part:IsA("BasePart")
    if BO_2 then
        uI(Part)
    end
    local BN_3 = os.clock() + 1.2
    while true do
        local BO_3 = t5() and State.Enabled.BuyTreadmills and os.clock() < BN_3
        if not BO_3 then
            return true
        end
        if State.OpenGamepass == BM.Gamepass then
            break
        end
        task.wait(0.1)
    end
    vv:FireServer()
    task.wait(0.6)
    return true
end
local function fn174()
    um()
    return State.WinLabels
end
local function fn209()
    local Ad_1
    local Ac_1
    local Aa = uR()
    local Trails = uW.Trails
    Ad_1, Ac_1 = nil, nil
    for k, v in uQ do
        local Ae = v ~= "None" and vk({ "Trails", v }) ~= true
        if Ae then
            local Ae_1 = tonumber(Trails[v])
            if Ae_1 and Aa >= Ae_1 and (Ac_1 == nil or Ae_1 < Ac_1) then
                Ad_1, Ac_1 = v, Ae_1
            end
        end
    end
    return Ad_1
end
local function fn223(f4)
    local Bm = tonumber(f4)
    if Bm then
        State.WinReturn = math.clamp(Bm, 0, 10)
    end
end
local function fn225()
    local Id
    local zW_1
    local zU = uR()
    local zV = LocalPlayer:GetAttribute("OwnsGamepassVIP") == true
    Id, zW_1 = nil, nil
    for k, v in u_.Outfits do
        local zY = type(v) == "table" and uG.isPurchasable(v) and vk({ "Outfits", v.Id }) ~= true
        if zY then
            if v.RequiresGamepass == nil or zV then
                local zY_2 = v.Unlock and v.Unlock.Cost
                local zZ = tonumber(zY_2) or math.huge
                if zU >= zZ and (zW_1 == nil or zZ < zW_1) then
                    Id, zW_1 = v.Id, zZ
                end
            end
        end
    end
    return Id
end
local function fn231()
    u6()
    return State.TreadLabels
end
local function fn240()
    local Df = u7()
    local Dj = if vk({ "EquippedOutfit" }) ~= Df then 1 else 0
    if Dj == 1 then
        t6:FireServer(Df)
    end
end
local function fn264()
    local BH_1
    u6()
    local BF = State.TreadByLabel[State.Treadmill]
    local BG = not BF or not ud(BF)
    local BG_1
    if BG then
        return false
    end
    BG_1, BH_1 = uE(BF)
    if not BH_1 then
        if BG_1 then
            ur(BG_1:GetPivot().Position)
        end
        return false
    end
    local BF_1 = uU(BH_1)
    if BF_1 then
        t4(BF_1)
    end
    uI(BH_1)
    return true
end
local function fn271(bL)
    local w_ = not bL or not bL:IsA("ProximityPrompt")
    if w_ then
        return false
    elseif uf(fireproximityprompt) then
        return pcall(fireproximityprompt, bL)
    else
        return false
    end
end
local function worker5()
    while t5() do
        if State.Enabled.Rebirth then
            vt()
            task.wait(1.2)
        else
            task.wait(0.4)
        end
    end
end
local function fn294()
    local yJ = vk({ "PurchasedPerSteps" })
    local yK = {}
    if type(yJ) == "table" then
        for k, v in yJ do
            if type(v) == "number" then
                yK[v] = true
            end
        end
    end
    return yK
end
local function fn335()
    u0()
    for k, v in vn do
        pcall(task.cancel, v)
    end
end
local function fn363()
    local wh = tonumber(vk({ "Wins" })) or 0
    return wh
end
local function fn386()
    local zG = {}
    for k, v in u4 do
        if type(v) == "table" then
            table.insert(zG, v)
        end
    end
    table.sort(zG, function(eA, eB)
        return (eA.Order or 0) < (eB.Order or 0)
    end)
    for k, v in zG do
        if u3(v) then
            return v.Id
        end
    end
end
local function fn395()
    gethui = uB
end
local function fn412()
    local AF = uR()
    local AG = t8()
    for k, v in vi() do
        local AH = not AG[v.Speed]
        if AH ~= false then
            AH = AF >= v.Wins
        end
        if AH then
            AH = v.Here
        end
        if AH then
            AH = v.Here:IsA("BasePart")
        end
        if AH then
            return v
        end
    end
end
local function fn413()
    local wl = (tonumber(vk({ "Rebirths" })))
    local wp = if wl then 1 else 0
    local wn = 1130 * wp + 3165 * (1 - wp)
    local wo = 2987 * wp + 3124 * (1 - wp)
    if not ((wn * 726 + wo * 3055 + wn * wo) % 16777213 == 13320975) then
        wl = 0
    end
    return wl
end
local function fn417(hp, hq)
    local B4 = uL.getSpeedMultiplier(hp)
    local B5 = uL.getSpeedMultiplier(hq)
    if B4 ~= B5 then
        return B4 > B5
    end
    local B4_1 = uL.getWinMultiplier(hp)
    local B5_1 = uL.getWinMultiplier(hq)
    if B4_1 ~= B5_1 then
        return B4_1 > B5_1
    end
    return (u4[hp] and u4[hp].Order or 0) > (u4[hq] and u4[hq].Order or 0)
end
local function fn441()
    local BV_1
    local BU_1
    BV_1, BU_1 = uo()
    if not BU_1 then
        return false
    end
    ur(BU_1.Position)
    local BW = uU(BU_1)
    if BW then
        t4(BW)
    end
    uI(BU_1)
    if BV_1 then
        for i, descendant in BV_1:GetDescendants() do
            if descendant:IsA("ProximityPrompt") then
                ue(descendant)
            end
        end
    end
    return true
end
local function fn444()
    local BA_1
    local Bz_1
    local By_1
    um()
    local Bw = State.WinByLabel[State.WinPlate]
    if not Bw then
        return false
    end
    local Bx = ux(Bw)
    if not Bx then
        return false
    end
    u0()
    local Bw_1 = uU(Bx)
    Bz_1, By_1, BA_1 = uc()
    if BA_1 and Bw_1 then
        BA_1.AssemblyLinearVelocity = Vector3.zero
        BA_1.AssemblyAngularVelocity = Vector3.zero
        BA_1.CFrame = Bw_1
    end
    uI(Bx)
    u0()
    local WinReturn = State.WinReturn
    local Bx_1 = os.clock() + WinReturn
    while true do
        local Bw_3 = t5() and State.Enabled.Win and os.clock() < Bx_1
        if Bw_3 then
            task.wait(0.05)
            continue
        end
        break
    end
    return true
end
local function fn456()
    local AP = {}
    for k, v in vo:GetTagged("LuckyBlock") do
        if v:GetAttribute("Collected") ~= true then
            table.insert(AP, v)
        end
    end
    return AP
end
local function fn480()
    local Db = uj()
    if vk({ "EquippedKatana" }) ~= Db then
        ug:FireServer(Db)
    end
end
local function fn501()
    if uH() < uC.GetRequiredLevel(uA() + 1) then
        return
    end
    uk:FireServer()
end
local function fn516()
    local ze = vk({ "PurchasedPerSteps" })
    local zf = 1
    if type(ze) == "table" then
        for k, v in ze do
            local ze_1 = type(v) == "number" and v > zf
            if ze_1 then
                zf = v
            end
        end
    end
    local ze_2 = uA()
    local zg = un()
    local zh = tonumber(vk({ "BestWallChain" })) or 0
    local zi = tonumber(vk({ "PlayStreak" })) or 0
    local zj = uH()
    local zk = tonumber(vk({ "LifetimeDeaths" })) or 0
    return {
        Owned = false,
        Rebirths = ze_2,
        Speed = zg,
        BestWallChain = zh,
        PlayStreak = zi,
        Level = zj,
        Deaths = zk,
        OwnedCount = uF(),
        HasVip = LocalPlayer:GetAttribute("OwnsGamepassVIP") == true,
        Wins = uR(),
        CompletedWorlds = vk({ "CompletedWorlds" }),
        WorldStages = vk({ "WorldFurthestStage" }),
        PerStep = zf
    }
end
local function fn519()
    local Ar = uR()
    local As
    for k, v in State.TreadByLabel do
        local At_1 = v.Gamepass or 0
        local Au = At_1 > 0 and not ud(v)
        if Au then
            local At_2 = uS(v.Gamepass)
            if At_2 > 0 and Ar >= At_2 then
                local Au_2 = not As
                local AE = if Au_2 then 1 else 0
                local AC = 1153 * AE + 752 * (1 - AE)
                local AD = 2248 * AE + 941 * (1 - AE)
                if not ((AC * 2086 + AD * 2864 + AC * AD) % 16777213 == 11435374) then
                    Au_2 = At_2 < As.Price
                end
                if Au_2 then
                    As = { Row = v, Price = At_2 }
                end
            end
        end
    end
    return As and As.Row
end
local function onHeartbeat()
    local wA_1
    local wz_1
    local wy = not vc or not t5()
    local wy_1
    if wy then
        return
    end
    wz_1, wy_1, wA_1 = uc()
    if not wA_1 then
        return
    end
    wA_1.AssemblyLinearVelocity = Vector3.zero
    wA_1.AssemblyAngularVelocity = Vector3.zero
    wA_1.CFrame = vc
end
local function fn550(c0)
    local x1 = vu(c0.Name)
    local x2 = uq(c0)
    if x1 then
        return string.format("Stage %d %s", x1, x2)
    end
    return x2
end
local function worker3()
    while t5() do
        if State.Enabled.Outfits then
            u1()
        end
        if State.Enabled.EquipOutfit then
            uN()
        end
        if State.Enabled.Outfits or State.Enabled.EquipOutfit then
            task.wait(0.8)
        else
            task.wait(0.4)
        end
    end
end
local function fn561()
    local Dd = u9()
    if Dd then
        ub:FireServer(Dd)
    end
end
local function fn650()
    for k, v in uD() do
        local AX_1 = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
        if AX_1 then
            return v, AX_1
        end
    end
    local LuckyBlockSpawns = vs:FindFirstChild("LuckyBlockSpawns")
    if LuckyBlockSpawns then
        for i, child in LuckyBlockSpawns:GetChildren() do
            if child:IsA("BasePart") then
                ur(child.Position)
            end
        end
    end
end
local function fn690(bT)
    local w1 = typeof(bT) ~= "Instance" or not bT:IsA("BasePart")
    if w1 then
        return
    end
    if not vo:HasTag(bT, "WinClaim") then
        return
    end
    local Parent = bT.Parent
    local w2 = Parent and vu(Parent.Name)
    if not w2 then
        return
    end
    State.WinHints[w2] = bT.Position
    local w2_1 = tonumber(bT:GetAttribute("WinsGiveCount"))
    if w2_1 then
        State.WinAmounts[w2] = w2_1
    end
end
local function fn703()
    local Cx = vk({ "Outfits" })
    local Cy = "Default"
    local Cz = (uG.getWinMultiplier("Default"))
    local CH = if Cz then 1 else 0
    local CF = 403 * CH + 2598 * (1 - CH)
    local CG = 2507 * CH + 2435 * (1 - CH)
    if not ((CF * 440 + CG * 3430 + CF * CG) % 16777213 == 9786651) then
        Cz = 1
    end
    local CA = Cz
    if type(Cx) ~= "table" then
        return Cy
    end
    for k, v in Cx do
        local Cx_1 = v == true and type(k) == "string" and u_.Outfits[k]
        if Cx_1 then
            local Cx_2 = uG.getWinMultiplier(k) or 1
            if Cx_2 > CA or Cx_2 == CA and (u_.Outfits[k].Order or 0) > (u_.Outfits[Cy] and u_.Outfits[Cy].Order or 0) then
                Cy = k
                CA = Cx_2
            end
        end
    end
    return Cy
end
local function onOnClientEvent(fP)
    if type(fP) == "table" then
        State.OpenGamepass = fP.Gamepass
    end
end
local function fn754()
    local C2 = t7()
    if not C2 or not C2.Here then
        return false
    end
    local C3_1 = tonumber(vk({ "EquippedPerStep" })) or 1
    if C3_1 == C2.Speed then
        return false
    end
    ur(C2.Here.Position)
    local C3_2 = not t5()
    local C8 = if C3_2 then 1 else 0
    local C6 = 1108 * C8 + 3163 * (1 - C8)
    local C7 = 2545 * C8 + 678 * (1 - C8)
    if not ((C6 * 2042 + C7 * 45 + C6 * C7) % 16777213 == 5196921) then
        C3_2 = not State.Enabled.EquipStep
    end
    if C3_2 then
        return false
    end
    local C3_3 = uU(C2.Here)
    if C3_3 then
        t4(C3_3)
    end
    uI(C2.Here)
    local C3_4 = os.clock() + 1
    while true do
        local C4 = t5() and State.Enabled.EquipStep and os.clock() < C3_4
        if not C4 then
            return true
        end
        local C4_1 = tonumber(vk({ "EquippedPerStep" })) or 1
        if C4_1 == C2.Speed then
            break
        end
        task.wait(0.1)
    end
    return true
end
local function fn761()
    local Upgrader = vs:FindFirstChild("Upgrader")
    local yW = {}
    if not Upgrader then
        return yW
    end
    for i, child in Upgrader:GetChildren() do
        if vo:HasTag(child, "Upgrader") then
            local insert = table.insert
            local yX = tonumber(child:GetAttribute("SpeedPerStep")) or 0
            local yY = tonumber(child:GetAttribute("WinsRequired")) or 0
            insert(yW, { Model = child, Speed = yX, Wins = yY, Here = child:FindFirstChild("Here") })
        end
    end
    table.sort(yW, function(dX, dY)
        return dX.Wins < dY.Wins
    end)
    return yW
end
local function fn798()
    local Dk = t2()
    if Dk then
        t3:FireServer(Dk)
    end
end
local function fn799()
    return not up.Unloaded
end
local function fn808(cT)
    local BillboardGui = cT:FindFirstChildWhichIsA("BillboardGui", true)
    local xZ = BillboardGui and BillboardGui:FindFirstChildWhichIsA("TextLabel", true)
    local xY_1 = xZ
    if xZ then
        xZ = xY_1.Text
    end
    local xY_2 = xZ
    local xZ_1 = xY_2 ~= ""
    local x_ = type(xY_2) == "string" and xZ_1
    if x_ then
        return (string.gsub(xY_2, "%s+", ""))
    end
    local attr = cT:GetAttribute("SpeedPerSec")
    if attr ~= nil then
        return tostring(attr) .. "x"
    end
    return cT.Name
end
local function fn827()
    local wj = tonumber(vk({ "Level" })) or 1
    return wj
end
local function fn836(cN)
    if not cN then
        return
    end
    local HERE = cN:FindFirstChild("HERE")
    local xT = HERE and HERE:IsA("BasePart")
    if xT then
        return HERE
    end
    local Tread = cN:FindFirstChild("Tread")
    local xT_1 = Tread and Tread:IsA("BasePart")
    if xT_1 then
        return Tread
    end
end
local function fn845()
    return uz.getSpeed(uH(), us())
end
local function fn871()
    vc = nil
end
local function fn883()
    local wq = tonumber(vk({ "XP" })) or 0
    return wq
end
local function onDescendantAdded(fR)
    vf(fR)
end
local function worker4()
    while t5() do
        if State.Enabled.Katanas then
            t9()
        end
        if State.Enabled.EquipKatana then
            vq()
        end
        if State.Enabled.Katanas or State.Enabled.EquipKatana then
            task.wait(0.8)
        else
            task.wait(0.4)
        end
    end
end
local function fn909(b2)
    local w7 = State.WinAmounts[b2]
    if w7 then
        return string.format("Stage %d (%s Wins)", b2, tostring(w7))
    end
    return "Stage " .. b2
end
local function fn919(bP)
    return tonumber(string.match(bP, "Stage(%d+)"))
end
local function fn948(bo)
    local wJ_1
    local wI_1
    local wH_1
    wI_1, wH_1, wJ_1 = uc()
    local wH_2 = not wJ_1 or typeof(bo) ~= "CFrame"
    if wH_2 then
        return false
    end
    vc = bo
    wJ_1.AssemblyLinearVelocity = Vector3.zero
    wJ_1.AssemblyAngularVelocity = Vector3.zero
    wJ_1.CFrame = bo
    return true
end
local function fn954(fU)
    local Tokens = State.Tokens
    local Bd = State.Tokens[fU] or 0
    Tokens[fU] = Bd + 1
    return State.Tokens[fU]
end
local function fn961(f7)
    local Br = type(f7) == "string" and State.TreadByLabel[f7]
    if Br then
        State.Treadmill = f7
    end
end
local function fn999(bB)
    local wS_1
    local wR_1
    local wQ_1
    wQ_1, wR_1, wS_1 = uc()
    local wQ_2 = not wS_1
    local wW = if wQ_2 then 1 else 0
    local wU = 3159 * wW + 1669 * (1 - wW)
    local wV = 1050 * wW + 3356 * (1 - wW)
    if not ((wU * 3292 + wV * 3082 + wU * wV) % 16777213 == 175265) then
        wQ_2 = not bB
    end
    if not wQ_2 then
        wQ_2 = not bB.Parent
    end
    local wZ = if wQ_2 then 1 else 0
    local wX = 3390 * wZ + 78 * (1 - wZ)
    local wY = 3772 * wZ + 2799 * (1 - wZ)
    if not ((wX * 2468 + wY * 1180 + wX * wY) % 16777213 == 8827347) then
        wQ_2 = not bB:IsA("BasePart")
    end
    if wQ_2 then
        return false
    elseif uf(firetouchinterest) then
        pcall(firetouchinterest, bB, wS_1, 1)
        pcall(firetouchinterest, bB, wS_1, 0)
        pcall(firetouchinterest, wS_1, bB, 1)
        pcall(firetouchinterest, wS_1, bB, 0)
        return true
    else
        return t4(uU(bB))
    end
end
local function fn1000(by)
    local wL = not by or not by:IsA("BasePart")
    if wL then
        return
    end
    return CFrame.new(by.Position.X, by.Position.Y + by.Size.Y / 2 + 3.5, by.Position.Z)
end
local function fn1008(f1)
    local Bh = type(f1) == "string" and State.WinByLabel[f1]
    if Bh then
        State.WinPlate = f1
    end
end
local function worker6()
    while t5() do
        local Dm = State.Enabled.Lucky and uy()
        if Dm then
            task.wait(0.25)
        else
            local Dm_1 = State.Enabled.Steps and vb()
            if Dm_1 then
                task.wait(0.35)
            else
                local Dm_2 = State.Enabled.BuyTreadmills and uK()
                if Dm_2 then
                    task.wait(0.4)
                else
                    local Dm_3 = State.Enabled.EquipStep and uY()
                    if Dm_3 then
                        task.wait(0.4)
                    elseif State.Enabled.Win then
                        if not vd() then
                            task.wait(0.35)
                        end
                    elseif State.Enabled.Train then
                        ua()
                        task.wait(0.2)
                    else
                        u0()
                        task.wait(0.3)
                    end
                end
            end
        end
    end
end
local function fn1033()
    local Character = LocalPlayer.Character
    local wt = Character and Character:FindFirstChildOfClass("Humanoid")
    local wu = Character
    if wu then
        wu = Character:FindFirstChild("HumanoidRootPart")
    end
    local wt_1 = Character
    local ww = wu
    if wt_1 then
        wt_1 = wt
    end
    if wt_1 then
        wt_1 = ww
    end
    if wt_1 then
        wt_1 = wt.Health > 0
    end
    if wt_1 then
        return Character, wt, ww
    end
end
local function fn1040()
    table.clear(State.TreadByLabel)
    table.clear(State.TreadLabels)
    local x8 = {}
    local x9 = {}
    for k, v in vo:GetTagged("Treadmill") do
        if v:IsA("Model") then
            local ya = vw(v)
            local yb = tonumber(v:GetAttribute("RequiredGamepass")) or 0
            local yb_1 = tonumber(v:GetAttribute("SpeedPerSec")) or 0
            local insert = table.insert
            local ye = vu(v.Name) or 0
            insert(x8, { Model = v, Label = ya, Gamepass = yb, Speed = yb_1, Stage = ye })
        end
    end
    table.sort(x8, function(dh, di)
        if dh.Stage ~= di.Stage then
            return dh.Stage < di.Stage
        elseif dh.Speed ~= di.Speed then
            return dh.Speed < di.Speed
        else
            return dh.Label < di.Label
        end
    end)
    for k, v in x8 do
        if not x9[v.Label] then
            x9[v.Label] = true
            table.insert(State.TreadLabels, v.Label)
            State.TreadByLabel[v.Label] = v
        end
    end
    if State.TreadByLabel[State.Treadmill] == nil then
        local x8_1 = State.TreadLabels[1] or "1x"
        State.Treadmill = x8_1
    end
end
local function fn1060()
    local Cb = vk({ "Katanas" })
    local Cc = "Default"
    if type(Cb) ~= "table" then
        return Cc
    end
    if Cb[Cc] ~= true then
        for k, v in Cb do
            local Cd = v == true and type(k) == "string"
            if Cd then
                Cc = k
                break
            end
        end
    end
    for k, v in Cb do
        local Cb_1 = v == true and type(k) == "string" and u4[k] and u5(k, Cc)
        if Cb_1 then
            Cc = k
        end
    end
    return Cc
end
local function fn1092(at)
    return vg:RemoteEvent(at)
end
local function fn1119(fW, fX)
    State.Enabled[fW] = fX == true
    if not State.Enabled.Win and not State.Enabled.Train and not State.Enabled.BuyTreadmills and not State.Enabled.Steps and not State.Enabled.Lucky and not State.Enabled.EquipStep then
        u0()
    end
    if not fX then
        uX(fW)
    end
end
local function fn1123(W)
    local v9 = typeof(cloneref) == "function" and typeof(W) == "Instance"
    if v9 then
        return cloneref(W)
    end
    return W
end
local function fn1133(dm)
    if not dm then
        return false
    end
    if (dm.Gamepass or 0) <= 0 then
        return true
    elseif uu.isGamepassOwned(LocalPlayer, dm.Gamepass) then
        return true
    else
        local ys_1 = uT.GamepassPlayerAttributes[dm.Gamepass]
        local yt = ys_1 and LocalPlayer:GetAttribute(ys_1) == true
        if yt then
            return true
        end
        local ys_2 = vk({ "PurchasedTreadmills" })
        if type(ys_2) == "table" then
            local yt_1 = ys_2[dm.Gamepass] == true or ys_2[tostring(dm.Gamepass)] == true
            if yt_1 then
                return true
            end
            for k, v in ys_2 do
                local ys_3 = v == dm.Gamepass or v == tostring(dm.Gamepass)
                if ys_3 then
                    return true
                end
            end
            return false
        end
        return false
    end
end
local function worker2()
    while t5() do
        if State.Enabled.Trails then
            ut()
            task.wait(0.8)
        else
            task.wait(0.4)
        end
    end
end
local function fn1183()
    local BR = vh()
    if not BR or not BR.Here then
        return false
    end
    ur(BR.Here.Position)
    local BS_1 = uU(BR.Here)
    if BS_1 then
        t4(BS_1)
    end
    uI(BR.Here)
    return true
end
t2 = nil
t3 = nil
t4 = nil
t5 = nil
t6 = nil
t7 = nil
t8 = nil
t9 = nil
ua = nil
ub = nil
uc = nil
ud = nil
ue = nil
uf = nil
ug = nil
uh = nil
ui = nil
uj = nil
uk = nil
um = nil
un = nil
uo = nil
up = nil
uq = nil
ur = nil
us = nil
ut = nil
uu = nil
uv = nil
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
uH = nil
uI = nil
LocalPlayer = nil
uK = nil
uL = nil
uM = nil
uN = nil
local Players, ul, uw, Workspace
uQ = nil
uR = nil
uS = nil
uT = nil
uU = nil
uW = nil
uX = nil
uY = nil
u_ = nil
u0 = nil
u1 = nil
CoreGui = nil
u3 = nil
u4 = nil
u5 = nil
u6 = nil
u7 = nil
u9 = nil
vb = nil
vc = nil
vd = nil
vf = nil
vg = nil
vh = nil
vi = nil
vk = nil
vn = nil
vo = nil
State = nil
vq = nil
vs = nil
vt = nil
vu = nil
vv = nil
vw = nil
local uP, Lighting, TeleportService, GuiService, va, HttpService, VirtualUser, UserInputService, vm, RunService
local vI
if not game:IsLoaded() then
    game.Loaded:Wait()
end
Players, RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, TeleportService, Lighting, Workspace, LocalPlayer, uB = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
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
local CollectionService = game:GetService("CollectionService")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local vy = "TempoSpeedNinjaKeyboardEscape"
uB = fns.fn68
if getgenv then
    getgenv().gethui = uB
end
up, vI, vs, vo, vg, va, u4, u_, uW, uT, uQ, uL, uG, uC, uz, uu, uk, ui, ug, ub, t6, t3, vv, State, vc, vn, uP, uf, t5, vk, uR, uH, uA, us, un, uc, ur, t4, u0, uU, uI, ue, vu, vm, vf, uw, um, ux, uM, uq, vw, u6, ud, uS, uE, t8, vi, uF, ul, u3, uh, u9, t2, uv, vh, uD, uo, uX, vd, ua, uK, vb, uy, vt, u5, uj, u7, t7, uY, t9, vq, u1, uN, ut = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pcall(fn395)
local function vB(v)
    local v1
    local v2
    local v0
    v0 = nil
    v1 = nil
    v2 = nil
    local v3 = v ~= ""
    local v4 = type(v) == "string" and v3
    assert(v4, "A namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    v1 = getgenv()
    assert(type(v1) == "table", "getgenv did not return a table")
    local v3_1 = v1[v]
    if v3_1 ~= nil then
        local v4_1 = type(v3_1) == "table" and type(v3_1.Unload) == "function"
        assert(v4_1, "Namespace is occupied")
        v3_1.Unload()
        assert(v1[v] == nil, "Previous instance did not release its namespace")
    end
    v2 = {}
    v0 = { State = {}, Unloaded = false }
    v0.Track = function(B)
        assert(type(B) == "function", "Cleanup must be callable")
        if v0.Unloaded then
            B()
        else
            table.insert(v2, B)
        end
        return B
    end
    v0.Unload = function()
        local vU_1
        local vT_1
        if v0.Unloaded then
            return
        end
        v0.Unloaded = true
        local vR = {}
        local vY = #v2
        local vX = -1
        while false and vY <= 1 or true and vY >= 1 do
            local vZ = vY
            local vS_1 = table.remove(v2, vZ)
            vT_1, vU_1 = pcall(vS_1)
            if not vT_1 then
                table.insert(vR, tostring(vU_1))
            end
            vY += vX
        end
        table.clear(v0.State)
        if #vR > 0 then
            error("Cleanup incomplete: " .. table.concat(vR, "; "), 0)
        end
        if v1[v] == v0 then
            v1[v] = nil
        end
    end
    v1[v] = v0
    return v0
end
uP = function(O, P)
    local v7 = type(O) == "table" and type(O.Track) == "function"
    assert(v7, "FeatureAPI required")
    local v7_1 = type(P) == "table" and type(P.OnUnload) == "function"
    assert(v7_1, "UI library required")
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
up = vB(vy)
local vx = fn1123
uf = fns.fn132
t5 = fn799
if not uG and t8 and (not uG and uG) or (uG or not t8 or t8 and uG) or (not t8 or not uG) and (not uG and t8) and ((uG or not t8) and (not t8 or uG)) or ((not t8 or not uG) and (uG or uG) and (not uG or not t8 or not uG and not t8) or t8 and uG and (t8 and not uG) and ((not t8 or not t8) and (not t8 or t8))) or not (not uG and t8 and (not uG and uG) or (uG or not t8 or t8 and uG) or (not t8 or not uG) and (not uG and t8) and ((uG or not t8) and (not t8 or uG)) or ((not t8 or not uG) and (uG or uG) and (not uG or not t8 or not uG and not t8) or t8 and uG and (t8 and not uG) and ((not t8 or not t8) and (not t8 or t8)))) then
    vI = vx(ReplicatedStorage)
else
    vI(vx)
end
vs = vx(Workspace)
vo = vx(CollectionService)
local vG = vx(vI:WaitForChild("Packages"))
vg = require(vx(vG:WaitForChild("Net")))
if ((vB or uM or false and uF or (u4 or uM or ug and not uF)) and ((uF or not u_) and (not ug or not u4) or (not u4 and not u_ or not ug and not uF)) or (not uF and u_ and (not ug or not u_) or (ug and uF or ug and not uM)) and (uF or u_ or (ug or false) or (not u_ or not u_) and (u4 and not ug))) and not ((vB or uM or false and uF or (u4 or uM or ug and not uF)) and ((uF or not u_) and (not ug or not u4) or (not u4 and not u_ or not ug and not uF)) or (not uF and u_ and (not ug or not u_) or (ug and uF or ug and not uM)) and (uF or u_ or (ug or false) or (not u_ or not u_) and (u4 and not ug))) then
    vI = require(va(u4:WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("DataController")))
    u_ = require(va(u4:WaitForChild("Data"):WaitForChild("KatanaData")))
    vx = require(va(u4:WaitForChild("Data"):WaitForChild("OutfitData")))
else
    va = require(vx(vI:WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("DataController")))
    u4 = require(vx(vI:WaitForChild("Data"):WaitForChild("KatanaData")))
    u_ = require(vx(vI:WaitForChild("Data"):WaitForChild("OutfitData")))
end
uW = require(vx(vI:WaitForChild("Data"):WaitForChild("EconomyData")))
uT = require(vx(vI:WaitForChild("Data"):WaitForChild("MonetizationData")))
uQ = require(vx(vI:WaitForChild("Enums"):WaitForChild("TrailEnum")))
uL = require(vx(vI:WaitForChild("Helpers"):WaitForChild("KatanaHelper")))
uG = require(vx(vI:WaitForChild("Helpers"):WaitForChild("OutfitHelper")))
uC = require(vx(vI:WaitForChild("Helpers"):WaitForChild("RebirthHelper")))
uz = require(vx(vI:WaitForChild("Helpers"):WaitForChild("SpeedHelper")))
uu = require(vx(vI:WaitForChild("Utils"):WaitForChild("MonetizationUtils")))
uk = fn1092("Rebirth/Request")
ui = fn1092("Katanas/Buy")
ug = fn1092("Katanas/Equip")
ub = fn1092("Outfits/Buy")
t6 = fn1092("Outfits/Equip")
t3 = fn1092("Trails/BuyViaWins")
vv = fn1092("Treadmill/BuyWithWins")
local vH = fn1092("Treadmill/OpenPurchase")
State = up.State
State.Enabled = {
    Win = false,
    Train = false,
    BuyTreadmills = false,
    Rebirth = false,
    Katanas = false,
    Outfits = false,
    Trails = false,
    Steps = false,
    Lucky = false,
    EquipStep = false,
    EquipKatana = false,
    EquipOutfit = false
}
State.WinPlate = "Stage 1"
State.WinReturn = 1
State.Treadmill = "1x"
State.WinLabels = { "Stage 1" }
State.TreadLabels = { "1x" }
State.WinByLabel = {}
State.TreadByLabel = {}
State.WinHints = {}
State.WinAmounts = {}
State.LastStream = 0
State.OpenGamepass = nil
State.Tokens = {}
vk = function(aF)
    local wf_1
    local we_1
    we_1, wf_1 = pcall(function()
        return va:Get(aF)
    end)
    if we_1 then
        return wf_1
    end
end
uR = fn363
uH = fn827
uA = fn413
us = fn883
un = fn845
uc = fn1033
vc = nil
local function vF(a6)
    up.Track(function()
        a6:Disconnect()
    end)
    return a6
end
vF(RunService.Heartbeat:Connect(onHeartbeat))
ur = function(bh)
    if typeof(bh) ~= "Vector3" then
        return
    end
    local wF = os.clock()
    if wF - State.LastStream < 0.4 then
        return
    end
    State.LastStream = wF
    pcall(function()
        LocalPlayer:RequestStreamAroundAsync(bh)
    end)
end
t4 = fn948
u0 = fn871
uU = fn1000
uI = fn999
ue = fn271
vu = fn919
vm = fns.fn77
vf = fn690
uw = fn909
um = function()
    local xc_1
    local xb_1
    table.clear(State.WinByLabel)
    table.clear(State.WinLabels)
    local w9 = vm()
    local xa = {}
    if w9 then
        for i, child in w9:GetChildren() do
            local xj = child
            local w9_1 = vu(xj.Name)
            if w9_1 then
                xb_1, xc_1 = pcall(function()
                    return xj:GetPivot()
                end)
                if xb_1 then
                    State.WinHints[w9_1] = xc_1.Position
                end
                table.insert(xa, w9_1)
            end
        end
    end
    for k, v in vo:GetTagged("WinClaim") do
        vf(v)
    end
    table.sort(xa)
    if #xa == 0 then
        local xs = 1
        while xs <= 11 do
            local xt = xs
            table.insert(xa, xt)
            xs += 1
        end
    end
    for k, v in xa do
        local w9_2 = uw(v)
        table.insert(State.WinLabels, w9_2)
        State.WinByLabel[w9_2] = v
        State.WinByLabel["Stage " .. v] = v
    end
    if State.WinByLabel[State.WinPlate] == nil then
        local w9_3 = State.WinLabels[1]
        local xB = if w9_3 then 1 else 0
        local xz = 3054 * xB + 2738 * (1 - xB)
        local xA = 3962 * xB + 2094 * (1 - xB)
        if not ((xz * 635 + xA * 2187 + xz * xA) % 16777213 == 5926919) then
            w9_3 = "Stage 1"
        end
        State.WinPlate = w9_3
    end
end
ux = function(cs)
    local xD = vm()
    local xD_2
    local xE = xD and xD:FindFirstChild("Stage" .. cs .. "EndWin")
    local xE_2
    local xC = xE
    if xC then
        for i, child in xC:GetChildren() do
            if vo:HasTag(child, "WinClaim") then
                vf(child)
                return child
            end
        end
    end
    for k, v in vo:GetTagged("WinClaim") do
        local Parent = v.Parent
        local xE_1 = Parent and vu(Parent.Name) == cs
        if xE_1 then
            vf(v)
            return v
        end
    end
    ur(State.WinHints[cs])
    if xC then
        xD_2, xE_2 = pcall(function()
            return xC:GetPivot()
        end)
        if xD_2 then
            ur(xE_2.Position)
        end
    end
end
uM = fn836
uq = fn808
vw = fn550
u6 = fn1040
ud = fn1133
uS = fns.fn117
uE = fns.fn91
t8 = fn294
vi = fn761
uF = fns.fn147
ul = fn516
u3 = function(ei)
    local zs
    local zu_1
    local zt = type(ei) ~= "table"
    local zt_1
    local zz = if zt then 1 else 0
    local zx = 2750 * zz + 3959 * (1 - zz)
    local zy = 2207 * zz + 337 * (1 - zz)
    if not ((zx * 41 + zy * 3871 + zx * zy) % 16777213 == 14725297) then
        zt = type(ei.Id) ~= "string"
    end
    if zt then
        return false
    elseif vk({ "Katanas", ei.Id }) == true then
        return false
    else
        zs = ul()
        zt_1, zu_1 = pcall(function()
            return uL.getProgress(ei, zs)
        end)
        local zv = not zt_1 or type(zu_1) ~= "table"
        if zv then
            return false
        end
        if ei.Unlock and ei.Unlock.Kind == "VipPurchase" then
            local zt_3 = zu_1.Fraction
            local zz_1 = if zt_3 then 1 else 0
            local zx_1 = 2888 * zz_1 + 1885 * (1 - zz_1)
            local zy_1 = 3951 * zz_1 + 863 * (1 - zz_1)
            if not ((zx_1 * 2615 + zy_1 * 3571 + zx_1 * zy_1) % 16777213 == 16294416) then
                zt_3 = 0
            end
            return zt_3 >= 1
        elseif uL.isAutoUnlockable(ei) then
            return (zu_1.Fraction or 0) >= 1
        else
            return false
        end
    end
end
uh = fn386
u9 = fn225
t2 = fn209
uv = fn519
vh = fn412
if not vg and vg and (false or uU) or vB and not uU and (not vg and not uU) or not (not vg and vg and (false or uU) or vB and not uU and (not vg and not uU)) then
    uD = fn456
    uo = fn650
    vF(vH.OnClientEvent:Connect(onOnClientEvent))
    vF(vs.DescendantAdded:Connect(onDescendantAdded))
    um()
    u6()
    uX = fn954
else
    uX = fn456
    uD = fn650
    u6(vs.OnClientEvent:Connect(onOnClientEvent))
    u6(vF.DescendantAdded:Connect(onDescendantAdded))
    uo()
    um()
end
up.SetEnabled = fn1119
up.SetWinPlate = fn1008
up.SetWinReturn = fn223
up.SetTreadmill = fn961
up.WinLabels = fn174
up.TreadLabels = fn231
vd = fn444
ua = fn264
uK = fn165
vb = fn1183
uy = fn441
vt = fn501
u5 = fn417
uj = fn1060
u7 = fn703
t7 = fns.fn101
uY = fn754
t9 = fns.fn44
vq = fn480
u1 = fn561
uN = fn240
ut = fn798
do
    vF(vo:GetInstanceAddedSignal("WinClaim"):Connect(vf))
    vF(vo:GetInstanceAddedSignal("Treadmill"):Connect(fn151))
    vn = {
        task.spawn(worker6),
        task.spawn(worker5),
        task.spawn(worker4),
        task.spawn(worker3),
        task.spawn(worker2),
        task.spawn(fns.worker)
    }
end
up.Track(fn335)
local function vE()
    local HV
    local HI
    local HT
    local onDiscord
    local HP
    HI = nil
    onDiscord = nil
    HP = nil
    HT = nil
    HV = nil
    local ThemeManager, Options, HJ, HK, HL, HM, Library, Toggles, HR, HS, SaveManager, HW, HX, HY
    HM = "https://discord.gg/K7Qxnxkk46"
    HK = "+1 Speed Ninja Keyboard Escape"
    HT = "https://discord.gg/K7Qxnxkk46"
    HY = "https://tempohub.shop"
    Library = getgenv().Library
    ThemeManager = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = Library.Toggles
    Options = Library.Options
    uP(up, Library)
    HI = function(jG, jH)
        local DF = uf(setclipboard) and setclipboard
        local DG = DF
        if not DG then
            local DF_1 = uf(toclipboard) and toclipboard
            DG = DF_1 or nil
        end
        local DF_2 = DG
        if not DF_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local DG_1 = pcall(DF_2, jG)
        if DG_1 then
            Library:Notify(jH)
        else
            Library:Notify("Failed to copy")
        end
    end
    onDiscord = function()
        HI(HT, "Copied Discord invite to clipboard")
    end
    HP = function(jU)
        return (tostring(jU):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
    end
    HV = function(jW, jX)
        return string.format('<font color="%s">%s</font>', jX, HP(jW))
    end
    HR = function(j_, j0, j1)
        return string.format("<b>%s</b> %s %s", j_, HV("-", "#5a6070"), HV(j0, j1))
    end
    HW = "#7fd47f"
    HJ = "#e8a34d"
    HS = "#6ec1ff"
    HX = "#8b93a3"
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = HT, Copyable = true }, "|", HK, "|", "v0.4" },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(false)
    HL = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gamepad-2"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
    local function HZ_1(ka)
        local DiscordGroup = ka:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    for k, v in HL do
        if k ~= "Info" then
            HZ_1(v)
        end
    end
    um()
    u6()
    local FarmGroup = HL.Main:AddLeftGroupbox("Farm", "swords")
    FarmGroup:AddToggle("AutoWin", {
        Text = "Auto Win",
        Default = false,
        Callback = function(ki)
            up.SetEnabled("Win", ki)
        end
    })
    FarmGroup:AddDropdown("WinPlate", {
        Text = "Win Plate",
        Values = State.WinLabels,
        Default = 1,
        Callback = function(kl)
            up.SetWinPlate(kl)
        end
    })
    up.SetWinPlate(Options.WinPlate.Value)
    FarmGroup:AddSlider("WinReturn", {
        Text = "Teleport Back",
        Default = 1,
        Min = 1,
        Max = 10,
        Rounding = 1,
        Callback = function(kn)
            up.SetWinReturn(kn)
        end
    })
    up.SetWinReturn(Options.WinReturn.Value)
    FarmGroup:AddToggle("AutoTreadmill", {
        Text = "Auto Use Treadmill",
        Default = false,
        Callback = function(kp)
            up.SetEnabled("Train", kp)
        end
    })
    FarmGroup:AddDropdown("Treadmill", {
        Text = "Treadmill",
        Values = State.TreadLabels,
        Default = 1,
        Callback = function(kr)
            up.SetTreadmill(kr)
        end
    })
    up.SetTreadmill(Options.Treadmill.Value)
    FarmGroup:AddToggle("AutoRebirth", {
        Text = "Auto Rebirth",
        Default = false,
        Callback = function(kt)
            up.SetEnabled("Rebirth", kt)
        end
    })
    FarmGroup:AddToggle("AutoLuckyBlocks", {
        Text = "Auto Open Lucky Blocks",
        Default = false,
        Callback = function(kw)
            up.SetEnabled("Lucky", kw)
        end
    })
    local ShopGroup = HL.Main:AddRightGroupbox("Shop", "shopping-bag")
    ShopGroup:AddToggle("AutoBuyTreadmills", {
        Text = "Auto Buy Treadmills",
        Default = false,
        Callback = function(kz)
            up.SetEnabled("BuyTreadmills", kz)
        end
    })
    ShopGroup:AddToggle("AutoBuyKatanas", {
        Text = "Auto Buy Katanas",
        Default = false,
        Callback = function(kB)
            up.SetEnabled("Katanas", kB)
        end
    })
    ShopGroup:AddToggle("AutoBuyOutfits", {
        Text = "Auto Buy Outfits",
        Default = false,
        Callback = function(kD)
            up.SetEnabled("Outfits", kD)
        end
    })
    ShopGroup:AddToggle("AutoBuyTrails", {
        Text = "Auto Buy Trails",
        Default = false,
        Callback = function(kF)
            up.SetEnabled("Trails", kF)
        end
    })
    ShopGroup:AddToggle("AutoBuySteps", {
        Text = "Auto Buy Steps",
        Default = false,
        Callback = function(kH)
            up.SetEnabled("Steps", kH)
        end
    })
    ShopGroup:AddToggle("AutoEquipBestStep", {
        Text = "Auto Equip Best Step",
        Default = false,
        Callback = function(kJ)
            up.SetEnabled("EquipStep", kJ)
        end
    })
    ShopGroup:AddToggle("AutoEquipBestKatana", {
        Text = "Auto Equip Best Katana",
        Default = false,
        Callback = function(kL)
            up.SetEnabled("EquipKatana", kL)
        end
    })
    ShopGroup:AddToggle("AutoEquipBestOutfit", {
        Text = "Auto Equip Best Outfit",
        Default = false,
        Callback = function(kN)
            up.SetEnabled("EquipOutfit", kN)
        end
    })
    task.spawn(function()
        while true do
            local DQ = t5() and not Library.Unloaded
            if DQ then
                um()
                u6()
                pcall(function()
                    if Options.WinPlate and Options.WinPlate.SetValues then
                        Options.WinPlate:SetValues(State.WinLabels)
                    end
                end)
                pcall(function()
                    if Options.Treadmill and Options.Treadmill.SetValues then
                        Options.Treadmill:SetValues(State.TreadLabels)
                    end
                end)
                task.wait(2)
                continue
            end
            break
        end
    end)
    local function HZ_4()
        local Eg
        local Ea
        Ea = nil
        Eg = nil
        local Label, Label2, Label3, Ed, Ee, Ef
        local Eh = {}
        if not uf(firetouchinterest) then
            table.insert(Eh, "firetouchinterest")
        end
        if not uf(fireproximityprompt) then
            table.insert(Eh, "fireproximityprompt")
        end
        local Ei = #Eh == 0 and "ready"
        local Ej = Ei or "limited: " .. table.concat(Eh, ", ")
        Ef = "Unknown"
        pcall(function()
            local DW_1
            local DV_1
            local D1 = if uf(identifyexecutor) then 1 else 0
            if D1 == 1 then
                DW_1, DV_1 = identifyexecutor()
                local DX = DW_1 ~= ""
                local DY = type(DW_1) == "string" and DX
                if DY then
                    local DX_1 = type(DV_1) == "string" and DV_1 ~= "" and DW_1 .. " " .. DV_1
                    Ef = DX_1 or DW_1
                end
            end
        end)
        Eg = os.clock()
        Ed = function()
            local D2 = math.floor(os.clock() - Eg)
            if D2 < 60 then
                return D2 .. "s"
            elseif D2 < 3600 then
                return string.format("%dm %ds", math.floor((D2) / (60)), D2 % 60)
            else
                return string.format("%dh %dm", math.floor((D2) / (3600)), math.floor((D2 % 3600) / (60)))
            end
        end
        local UserGroup = HL.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(HR("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, HW), true)
        UserGroup:AddLabel(HR("UserId", tostring(LocalPlayer.UserId), HS), true)
        UserGroup:AddLabel(HR("Executor", Ef .. "  " .. Ej, HW), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(HR("Session", Ed(), HJ), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                HI(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                HI("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = HL.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(HR("Game", HK, HS), true)
        Label2 = SessionGroup:AddLabel(HR("Players", "0/0", HW), true)
        Ee = tostring(game.JobId)
        local Ei_2 = #Ee > 18 and string.sub(Ee, 1, 18) .. "..."
        local Ej_1 = Ei_2 or Ee
        SessionGroup:AddLabel(HR("Job", Ej_1, HX), true)
        Label = SessionGroup:AddLabel(HR("Ping", "0 ms", HJ), true)
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
                HI(Ee, "Copied Job ID")
            end
        })
        Ea = task.spawn(function()
            local D5_1
            local D4_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(HR("Session", Ed(), HJ))
                Label2:SetText(HR("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), HW))
                D4_1, D5_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local D4_2 = D4_1 and D5_1 .. " ms" or "n/a"
                Label:SetText(HR("Ping", D4_2, HJ))
            end
        end)
        up.Track(function()
            if coroutine.status(Ea) ~= "dead" then
                task.cancel(Ea)
            end
        end)
        local SocialsGroup = HL.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                HI(HM, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                HI(HY, "Copied website link")
            end
        })
    end
    HZ_4()
    local function HZ_5()
        local mf
        local md
        local mg
        local me
        local MovementGroup = HL.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = HL.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        md = {}
        mg = {}
        me = {}
        mf = {}
        local mc = {}
        local function mh()
            for k, v in md do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(md)
        end
        local function ml()
            for k, v in me do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(me)
        end
        local function mp()
            for k, v in mf do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(mf)
        end
        local function mt(mu)
            local EJ = if not mu:IsA("ProximityPrompt") then 1 else 0
            if EJ == 1 then
                return
            end
            if mg[mu] == nil then
                mg[mu] = {
                    HoldDuration = mu.HoldDuration,
                    MaxActivationDistance = mu.MaxActivationDistance,
                    RequiresLineOfSight = mu.RequiresLineOfSight
                }
            end
            mu.HoldDuration = 0
            mu.MaxActivationDistance = 50
            mu.RequiresLineOfSight = false
        end
        local function mw()
            for k, v in mg do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(mg)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                mp()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                ml()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                mh()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                    pcall(mt, v)
                end
            else
                mw()
            end
        end)
        table.insert(mc, Workspace.DescendantAdded:Connect(function(mP)
            if Toggles.InstantProximityPrompt.Value then
                mt(mP)
            end
        end))
        table.insert(mc, RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if md[v] == nil then
                        md[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(mc, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local Fe = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and Fe then
                Fe:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(mc, RunService.RenderStepped:Connect(function(na)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local Fk = Character and Character:FindFirstChildOfClass("Humanoid")
            local Fl = Character
            if Fl then
                Fl = Character:FindFirstChild("HumanoidRootPart")
            end
            local Fj_1 = Fl
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and Fk then
                if me[Fk] == nil then
                    me[Fk] = Fk.WalkSpeed
                end
                Fk.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and Fj_1 and Fk and CurrentCamera then
                if mf[Fk] == nil then
                    mf[Fk] = Fk.PlatformStand
                end
                Fk.PlatformStand = true
                local Fl_4 = Vector3.zero
                if not UserInputService:GetFocusedTextBox() then
                    local Fr = if UserInputService:IsKeyDown(Enum.KeyCode.W) then 1 else 0
                    if Fr == 1 then
                        Fl_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        Fl_4 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        Fl_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        Fl_4 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        Fl_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        Fl_4 -= Vector3.new(0, 1, 0)
                    end
                end
                Fj_1.AssemblyLinearVelocity = Vector3.zero
                if Fl_4.Magnitude > 0 then
                    Fj_1.CFrame = Fj_1.CFrame + Fl_4.Unit * Options.FlySpeed.Value * na
                end
            end
        end))
        up.Track(function()
            for k, v in mc do
                v:Disconnect()
            end
            mh()
            ml()
            mp()
            mw()
        end)
    end
    HZ_5()
    local function HZ_6()
        local Gs, Gt, Gu, Gv, Gw, Gx, Gy, Label, GA, GB, GC, GD, GE, GF
        GA = {}
        Gu = {}
        GF = nil
        Gw = false
        Gs = 0
        GC = 0
        Gx = os.clock()
        local MenuGroup = HL.Settings:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        GD = function()
            local CurrentCamera
            CurrentCamera = Workspace.CurrentCamera
            local FA = not CurrentCamera or not uf(VirtualUser.CaptureController) or not uf(VirtualUser.ClickButton2)
            if FA then
                return false
            end
            local FA_1 = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            end)
            if not FA_1 then
                return false
            end
            Gs += 1
            Gx = os.clock()
            pcall(function()
                Label:SetText("AFK triggers: " .. Gs)
            end)
            return true
        end
        Gy = function(nU)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not nU)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not nU
                end
            end)
            if not nU then
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
        Gv = function(n9)
            if n9.ClassName == "ParticleEmitter" or n9.ClassName == "Trail" or n9.ClassName == "Smoke" or n9.ClassName == "Fire" or n9.ClassName == "Sparkles" or n9.ClassName == "Explosion" or n9.ClassName == "Beam" then
                if GA[n9] == nil then
                    GA[n9] = n9.Enabled
                end
                pcall(function()
                    n9.Enabled = false
                end)
            end
        end
        Gt = function()
            for k, v in GA do
                local FM = k
                local FO = v
                if FM.Parent then
                    pcall(function()
                        FM.Enabled = FO
                    end)
                end
            end
            table.clear(GA)
            if GF then
                pcall(function()
                    settings().Rendering.QualityLevel = GF.Quality
                end)
                Lighting.GlobalShadows = GF.Shadows
                Lighting.FogEnd = GF.Fog
                GF = nil
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(op)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not op)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(ow)
                if ow then
                    if not GF then
                        GF = {
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
                        pcall(Gv, v)
                    end
                else
                    Gt()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        Gy(true)
        local ScriptGroup = HL.Settings:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiGameplayPause:OnChanged(function()
            Gy(Toggles.AntiGameplayPause.Value)
        end)
        if Toggles.AntiGameplayPause.Value then
            Gy(true)
        end
        table.insert(Gu, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                GD()
            end
        end))
        table.insert(Gu, Workspace.DescendantAdded:Connect(function(oP)
            if Toggles.FpsBoost.Value then
                Gv(oP)
            end
        end))
        GE = function(oT)
            local F4 = Gw
            local F9 = if F4 then 1 else 0
            local F7 = 463 * F9 + 1402 * (1 - F9)
            local F8 = 1538 * F9 + 2608 * (1 - F9)
            if not ((F7 * 1545 + F8 * 3716 + F7 * F8) % 16777213 == 7142637) then
                F4 = Library.Unloaded
            end
            if not F4 then
                F4 = not Toggles.AutoReconnect.Value
            end
            if F4 then
                return
            end
            Gw = true
            local F3 = GC
            local F4_1 = pcall(function()
                if oT then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not F4_1 then
                Gw = false
                if not oT and F3 == GC then
                    task.delay(1.5, function()
                        if F3 == GC then
                            GE(true)
                        end
                    end)
                end
            end
        end
        table.insert(Gu, TeleportService.TeleportInitFailed:Connect(function(pa)
            local Gb
            if pa == LocalPlayer and Gw then
                Gw = false
                Gb = GC
                task.delay(3, function()
                    if Gb == GC then
                        GE(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local Gg = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            if Library.Unloaded or not Gg then
                return
            end
            table.insert(Gu, Gg.ChildAdded:Connect(function(pp)
                if pp.Name == "ErrorPrompt" then
                    GE(false)
                end
            end))
        end)
        GB = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    Gy(true)
                end
                local Gj = Toggles.AntiAfk.Value and os.clock() - Gx >= 60
                if Gj then
                    GD()
                end
                task.wait(1)
            end
        end)
        up.Track(function()
            GC += 1
            for k, v in Gu do
                v:Disconnect()
            end
            pcall(task.cancel, GB)
            Gy(false)
            Gt()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    HZ_6()
    local function HZ_7()
        local HA, HB, HC, HD
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("MyScriptHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(HL.Settings)
        ThemeManager:LoadDefault()
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/SpeedNinjaKeyboardEscape")
        local HE = SaveManager:BuildConfigSection(HL.Settings)
        HD = function(pQ, pR)
            local GJ_1 = (pQ == "Toggle" and Toggles or Options)[pR]
            local GI_2 = type(GJ_1) == "table" and GJ_1.Type == pQ
            return GI_2 and GJ_1 or nil
        end
        HB = function(p_, p0)
            local Type = p0.Type
            if Type == "Toggle" then
                return { idx = p_, type = "Toggle", value = p0.Value == true }
            elseif Type == "Slider" then
                return { idx = p_, type = "Slider", value = tostring(p0.Value) }
            elseif Type == "Dropdown" then
                return { idx = p_, type = "Dropdown", multi = p0.Multi == true, value = p0.Value }
            elseif Type == "Input" then
                local GN = p0.Value or ""
                return { idx = p_, type = "Input", text = tostring(GN) }
            elseif Type == "ColorPicker" then
                return { idx = p_, type = "ColorPicker", value = p0.Value:ToHex(), transparency = p0.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = p_,
                    type = "KeyPicker",
                    mode = p0.Mode,
                    key = p0.Value,
                    modifiers = p0.Modifiers,
                    toggled = p0.Toggled
                }
            else
                return nil
            end
        end
        HA = function()
            local GT = {}
            for k, v in { Toggles, Options } do
                for k, v in pairs(v) do
                    local GU = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if GU then
                        local GU_1 = HB(k, v)
                        if GU_1 then
                            GT[#GT + 1] = GU_1
                        end
                    end
                end
            end
            table.sort(GT, function(qa, qb)
                if qa.type ~= qb.type then
                    return qa.type < qb.type
                end
                return qa.idx < qb.idx
            end)
            return { objects = GT }
        end
        HC = function(qd)
            local Hc
            Hc = nil
            local Hd = type(qd) ~= "table" or type(qd.idx) ~= "string" or type(qd.type) ~= "string" or SaveManager.Ignore[qd.idx]
            if Hd then
                return false
            end
            Hc = HD(qd.type, qd.idx)
            if not Hc then
                return false
            end
            local Hd_1 = pcall(function()
                if qd.type == "Input" then
                    if type(qd.text) ~= "string" then
                        return
                    end
                    Hc:SetValue(qd.text)
                elseif qd.type == "ColorPicker" then
                    Hc:SetValueRGB(Color3.fromHex(qd.value), qd.transparency)
                elseif qd.type == "KeyPicker" then
                    Hc:SetValue({ qd.key, qd.mode, qd.modifiers })
                    if qd.mode == "Toggle" and qd.toggled ~= nil then
                        Hc.Toggled = qd.toggled
                        Hc:Update()
                    end
                else
                    Hc:SetValue(qd.value)
                end
            end)
            return Hd_1
        end
        HE:AddDivider()
        HE:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        HE:AddButton("Export Config to Clipboard", function()
            local Hg_1
            local Hf_1
            Hf_1, Hg_1 = pcall(HttpService.JSONEncode, HttpService, HA())
            if Hf_1 then
                local Hf_2 = uf(setclipboard) and setclipboard
                local Hh = Hf_2
                local Hm = if Hh then 1 else 0
                local Hk = 1827 * Hm + 4031 * (1 - Hm)
                local Hl = 2558 * Hm + 3400 * (1 - Hm)
                if not ((Hk * 3673 + Hl * 3533 + Hk * Hl) % 16777213 == 3644238) then
                    local Hf_3 = uf(toclipboard) and toclipboard
                    Hh = Hf_3 or nil
                end
                local Hf_4 = Hh
                local Hh_1 = type(Hf_4) == "function" and pcall(Hf_4, Hg_1)
                if Hh_1 then
                    Library:Notify("Config copied to clipboard", 6)
                    return
                end
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Failed to encode the config")
        end)
        HE:AddButton("Import Config from Clipboard Text", function()
            local Hp_1
            local Hn = Options.SaveManager_ImportSource.Value or ""
            local Hn_1
            local Ho = tostring(Hn):match("^%s*(.-)%s*$")
            if Ho == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            if #Ho > 262144 then
                Library:Notify("That config is too large")
                return
            end
            Hn_1, Hp_1 = pcall(HttpService.JSONDecode, HttpService, Ho)
            local Ho_1 = not Hn_1 or type(Hp_1) ~= "table" or type(Hp_1.objects) ~= "table"
            if Ho_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            if #Hp_1.objects > 2048 then
                Library:Notify("That config has too many records")
                return
            end
            local Hn_2 = 0
            for i, v in ipairs(Hp_1.objects) do
                if HC(v) then
                    Hn_2 += 1
                end
            end
            if Hn_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local Hp_2 = Hn_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(Hn_2, Hp_2), 6)
        end)
        SaveManager:LoadAutoloadConfig()
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    HZ_7()
end
vE()
end)(...)

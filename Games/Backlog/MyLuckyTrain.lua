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
getgenv().TempoHoodSubtitle = "MY LUCKY TRAIN"
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
local l4
local TrainConfig
local mt
local mS
local mg
local mY
local lY
local mF
local mm
local Library
local mL
local lL
local ms
local l9
local mR
local lR
local mX
local mE
local Options
local l2
local CartsUpdate
local l8
local mQ
local lQ
local mx
local me
local mW
local lW
local mk
local lJ
local mq
local l7
local mP
local mw
local md
local mV
local mj
local m0
local l0
local mI
local lI
local mp
local l6
local Toggles
local ClaimCash
local mU
local lU
local m_
local l_
local mH
local mo
local PurchaseUpgrade
local mN
local lN
local mu
local mb
local mT
local lT
local mA
local mh
local mZ
local lZ
local function fn25(bf)
    local og = not bf or not bf:IsA("ProximityPrompt") or not bf.Enabled
    if og then
        return false
    elseif fireproximityprompt then
        fireproximityprompt(bf)
        return true
    else
        bf:InputHoldBegin()
        task.wait(math.max(0.05, bf.HoldDuration))
        bf:InputHoldEnd()
        return true
    end
end
local function fn51()
    if not mb("AutoSellCart") then
        return
    end
    local qK = os.clock()
    if qK - mp < 0.35 then
        return
    end
    mP()
    for k, v in md.storage do
        local qL = typeof(v) == "table" and typeof(v.uid) == "string" and mg("CartSellRarities", v.rarity, true)
        if qL then
            mp = qK
            mQ:FireServer(v.uid)
            return
        end
    end
end
local function fn69()
    local Character = l0.Character
    local n2 = Character and Character:FindFirstChildOfClass("Humanoid")
    return n2
end
local function worker()
    mP()
    while not Library.Unloaded do
        task.wait(0.05)
        pcall(m_)
        pcall(lJ)
        pcall(mW)
        pcall(mT)
        pcall(lQ)
        pcall(mE)
        pcall(mH)
        pcall(l2)
        pcall(mI)
        pcall(mh)
        pcall(lU)
    end
end
local function fn85(az, aA)
    return string.format('<font color="%s">%s</font>', aA, az)
end
local function fn92()
    mU(lT, "Copied Discord invite to clipboard")
end
local function fn100()
    if not mb("AutoPullLever") then
        return
    end
    local pk = os.clock()
    local pl = tonumber(lI("PullDelay", 0.35)) or 0.35
    if pk - l7 < pl then
        return
    end
    local pl_1 = ms.rollReadyAt > 0 and os.time() < ms.rollReadyAt
    if pl_1 then
        return
    end
    local pl_2 = lY("TestRollButton")
    if not pl_2 then
        return
    end
    local ProximityPrompt = pl_2:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not ProximityPrompt then
        return
    end
    l7 = pk
    mY(ProximityPrompt)
end
local function fn177()
    if not mb("AutoDeposit") then
        return
    end
    local pS = ms.carriedUnits
    local pY = if pS then 1 else 0
    local pW = 3754 * pY + 2740 * (1 - pY)
    local pX = 447 * pY + 1443 * (1 - pY)
    if not ((pW * 617 + pX * 1581 + pW * pX) % 16777213 == 4700963) then
        pS = 0
    end
    if pS <= 0 then
        return
    end
    local pS_1 = os.clock()
    if pS_1 - lR < 0.35 then
        return
    end
    local pT = lY("DepositPad")
    local pU = me(pT)
    if not pU then
        return
    end
    lR = pS_1
    l6(pU)
end
local function onOnClientEvent3(bO)
    if typeof(bO) ~= "table" then
        return
    end
    local oE = typeof(bO.equipped) == "table" and bO.equipped
    local oG = oE or {}
    md.equipped = oG
    local oE_1 = typeof(bO.storage) == "table" and bO.storage
    local oG_1 = oE_1 or {}
    md.storage = oG_1
    local oE_2 = tonumber(bO.maxSlots) or md.maxSlots
    md.maxSlots = oE_2
    local oE_3 = (tonumber(bO.maxCartLevel))
    local oK = if oE_3 then 1 else 0
    local oI = 3679 * oK + 692 * (1 - oK)
    local oJ = 3529 * oK + 769 * (1 - oK)
    if not ((oI * 117 + oJ * 1946 + oI * oJ) % 16777213 == 3503855) then
        oE_3 = md.maxCartLevel
    end
    md.maxCartLevel = oE_3
end
local function fn202(ba)
    local oa = mA()
    local ob = oa and typeof(ba) == "CFrame"
    if ob then
        oa.CFrame = ba + Vector3.new(0, 3, 0)
    end
end
local function onOnClientEvent(bI)
    if typeof(bI) ~= "table" then
        return
    end
    if bI.cash ~= nil then
        local oA_1 = tonumber(bI.cash) or ms.cash
        ms.cash = oA_1
    end
    if bI.rebirths ~= nil then
        local oA_2 = tonumber(bI.rebirths) or ms.rebirths
        ms.rebirths = oA_2
    end
    if bI.carriedUnits ~= nil then
        local oA_3 = tonumber(bI.carriedUnits) or 0
        ms.carriedUnits = oA_3
    end
    if bI.rollReadyAt ~= nil then
        local oA_4 = tonumber(bI.rollReadyAt) or 0
        ms.rollReadyAt = oA_4
    end
    if bI.rollBuyingPower ~= nil then
        local oA_5 = tonumber(bI.rollBuyingPower) or 0
        ms.rollBuyingPower = oA_5
    end
    if typeof(bI.upgrades) == "table" then
        ms.upgrades = bI.upgrades
    end
end
local function fn259(cr)
    return mg("BuyRarities", cr, false)
end
local function fn292(as, at)
    if setclipboard then
        setclipboard(as)
    elseif toclipboard then
        toclipboard(as)
    end
    Library:Notify(at)
end
local function onOnClientEvent2(bM)
    if typeof(bM) ~= "table" then
        return
    end
    local oC = tonumber(bM.value) or 0
    mm.value = oC
    local oC_1 = tonumber(bM.pending) or 0
    mm.pending = oC_1
    local oC_2 = tonumber(bM.units) or 0
    mm.units = oC_2
    local oC_3 = tonumber(bM.carried) or 0
    mm.carried = oC_3
end
local function fn358()
    local oi = l0:GetAttribute("IslandName") or "Island1"
    local oi_1 = l9:FindFirstChild(oi)
    local oj_1 = oi_1 and oi_1:FindFirstChild("IslandPackage")
    return oj_1
end
local function fn363()
    if not mb("AutoBuyLeverResult") then
        return
    end
    local pr = os.clock()
    if pr - l_ < 0.25 then
        return
    end
    local cash = ms.cash
    local UserId = l0.UserId
    for i, child in l9:GetChildren() do
        local pu = child:IsA("Model") and child:GetAttribute("OwnerUserId") == UserId
        if pu then
            local attr = child:GetAttribute("CartId")
            local pv = typeof(attr) == "string" and mS.byId(attr)
            local pw = pv or nil
            local pv_1 = pw
            if pw then
                pw = pv_1.rarity
            end
            local pv_2 = pw or nil
            if l4(pv_2) then
                local claimCost = mS.claimCost
                local rebirths = ms.rebirths
                local px = ms.rollBuyingPower or cash
                local pv_4 = tonumber(claimCost(attr, rebirths, px)) or 0
                if cash >= pv_4 then
                    local ClaimPrompt = child:FindFirstChild("ClaimPrompt", true)
                    local pv_5 = ClaimPrompt and ClaimPrompt:IsA("ProximityPrompt") and ClaimPrompt.Enabled
                    if pv_5 then
                        local pv_6 = me(child)
                        if pv_6 then
                            l6(pv_6)
                        end
                        l_ = pr
                        mY(ClaimPrompt)
                        return
                    end
                end
            end
        end
    end
end
local function fn381()
    if not mb("AutoBuyUpgrades") then
        return
    end
    local qT = os.clock()
    if qT - mR < 0.35 then
        return
    end
    local qU = mw("UpgradeList")
    if next(qU) == nil then
        return
    end
    mR = qT
    for k, v in qU do
        if v then
            local qT_1 = mo[k]
            if qT_1 then
                local qU_1 = tonumber(ms.upgrades[qT_1]) or 0
                local qU_2 = TrainConfig.upgradeMaxLevel(qT_1)
                local qW = typeof(qU_2) ~= "number" or qU_1 < qU_2
                if qW then
                    local qU_3 = TrainConfig.upgradeCost(qT_1, qU_1)
                    local qV_1 = typeof(qU_3) == "number" and ms.cash >= qU_3
                    if qV_1 then
                        mt()
                        PurchaseUpgrade:FireServer(qT_1, 1)
                        return
                    end
                end
            end
        end
    end
end
local function fn403()
    local pG_1
    local pL = if not mb("AutoCollectOre") then 1 else 0
    if pL == 1 then
        return
    end
    local pF = os.clock()
    local pF_1
    if pF - lW < 0.2 then
        return
    end
    lW = pF
    pF_1, pG_1 = pcall(function()
        return mk:InvokeServer()
    end)
    local pH = not pF_1
    local pL_1 = if pH then 1 else 0
    local pJ = 583 * pL_1 + 679 * (1 - pL_1)
    local pK = 3300 * pL_1 + 1819 * (1 - pL_1)
    if not ((pJ * 3080 + pK * 3246 + pJ * pK) % 16777213 == 14431340) then
        pH = typeof(pG_1) ~= "table"
    end
    if pH then
        return
    end
    local pF_2 = 0
    for k, v in pG_1 do
        local pG_2 = tonumber(v) or v
        mq:FireServer(pG_2)
        pF_2 += 1
        if pF_2 >= 40 then
            break
        end
    end
end
local function fn425(aC, aD, aE)
    return string.format("<b>%s</b> %s %s", aC, l8("-", "#5a6070"), l8(aD, aE))
end
local function fn455()
    local pe = lY("UpgradeBoard")
    local pf = me(pe)
    local pe_1 = pf and not lN(pf, 14)
    if pe_1 then
        l6(pf)
    end
end
local function fn474()
    local q3 = ms.rebirths or 0
    local q3_2
    local REBIRTH_COSTS = mF.REBIRTH_COSTS
    local q5 = typeof(REBIRTH_COSTS) == "table" and REBIRTH_COSTS[q3] ~= nil
    local q5_1
    if q5 then
        return tonumber(REBIRTH_COSTS[q3])
    elseif type(mF.rebirthCost) == "function" then
        q3_2, q5_1 = pcall(mF.rebirthCost, q3)
        if q3_2 then
            return tonumber(q5_1)
        end
        local q3_3 = tonumber(mF.REBIRTH_BASE_COST) or 750000
        local q3_4 = tonumber(mF.REBIRTH_COST_SCALE) or 3.5
        return q3_3 * q3_4 ^ q3
    else
        local q3_5 = tonumber(mF.REBIRTH_BASE_COST) or 750000
        local q3_6 = tonumber(mF.REBIRTH_COST_SCALE) or 3.5
        return q3_5 * q3_6 ^ q3
    end
end
local function fn501(aQ, aR)
    local nR = Options[aQ]
    if nR == nil then
        return aR
    end
    return nR.Value
end
local function fn575()
    if not mb("AutoSell") then
        return
    end
    local pZ = os.clock()
    local p_ = tonumber(lI("SellDelay", 0.5)) or 0.5
    if pZ - lL < p_ then
        return
    end
    local p__1 = mm.value
    local p4 = if p__1 then 1 else 0
    local p2 = 3484 * p4 + 1866 * (1 - p4)
    local p3 = 14 * p4 + 2577 * (1 - p4)
    if not ((p2 * 734 + p3 * 2265 + p2 * p3) % 16777213 == 2637742) then
        p__1 = 0
    end
    local p0_1 = p__1 > 0
    if not p0_1 then
        p0_1 = (mm.pending or 0) > 0
    end
    if not p0_1 then
        local p__3 = mm.units
        local p7 = if p__3 then 1 else 0
        local p5 = 3515 * p7 + 3312 * (1 - p7)
        local p6 = 956 * p7 + 3256 * (1 - p7)
        if not ((p5 * 952 + p6 * 1795 + p5 * p6) % 16777213 == 8422640) then
            p__3 = 0
        end
        p0_1 = p__3 > 0
    end
    local p0_2 = not p0_1
    if p0_2 ~= false then
        p0_2 = (ms.carriedUnits or 0) <= 0
    end
    if p0_2 then
        return
    end
    local p__6 = lY("FurnaceCollectCash")
    local p0_3 = me(p__6)
    if not p0_3 then
        return
    end
    lL = pZ
    l6(p0_3)
    ClaimCash:FireServer()
end
local function fn598()
    if not mb("AutoUpgradeCart") then
        return
    end
    local qz = os.clock()
    if qz - mx < 0.35 then
        return
    end
    mP()
    local qA = tonumber(md.maxCartLevel) or TrainConfig.CART_MAX_LEVEL
    local qB = qA or 10
    for k, v in md.equipped do
        local qB_1 = typeof(v) == "table" and typeof(v.uid) == "string" and mg("CartUpgradeRarities", v.rarity, false)
        if qB_1 then
            local qB_2 = tonumber(v.level) or 1
            if qB_2 < qB then
                local qB_3 = TrainConfig.cartUpgradeCost(v.id, qB_2)
                local qC_1 = typeof(qB_3) == "number" and ms.cash >= qB_3
                if qC_1 then
                    mx = qz
                    mX:FireServer(v.uid)
                    return
                end
            end
        end
    end
end
local function fn607(b_, b0, b1)
    local oN = b0 == ""
    local oO = typeof(b0) ~= "string"
    local oS = if oO then 1 else 0
    local oQ = 3743 * oS + 634 * (1 - oS)
    local oR = 3254 * oS + 1387 * (1 - oS)
    if not ((oQ * 1885 + oR * 879 + oQ * oR) % 16777213 == 5318330) then
        oO = oN
    end
    if oO then
        return false
    end
    local oN_1 = mw(b_)
    if next(oN_1) == nil then
        return b1 ~= true
    end
    return oN_1[b0] == true
end
local function fn677()
    local rh = if not mb("AutoRebirth") then 1 else 0
    if rh == 1 then
        return
    end
    local rb = os.clock()
    if rb - mL < 1 then
        return
    end
    local rc = mV()
    local rd = typeof(rc) == "number" and ms.cash < rc
    if rd then
        return
    end
    mL = rb
    lZ:FireServer()
end
local function fn775(b5)
    local oT = tonumber(b5.boostedOutput) or tonumber(b5.income) or tonumber(b5.baseOutput)
    local oU = oT or 0
    local oU_1 = mN[b5.rarity] or 0
    local oU_2 = typeof(b5.id) == "string" and mS.byId(b5.id)
    local oW = oU_2
    local o_ = if oW then 1 else 0
    local oY = 1614 * o_ + 3832 * (1 - o_)
    local oZ = 370 * o_ + 2839 * (1 - o_)
    if not ((oY * 1399 + oZ * 1887 + oY * oZ) % 16777213 == 3553356) then
        oW = nil
    end
    local oU_3 = oW
    if oW then
        oW = tonumber(oU_3.ladderIndex)
    end
    return oU, oU_1, oW or 0
end
local function fn809(aL)
    local nL = Toggles[aL]
    return nL ~= nil and nL.Value == true
end
local function fn828()
    if not mb("AutoUpgradeSmelt") then
        return
    end
    local p8 = os.clock()
    if p8 - mZ < 0.4 then
        return
    end
    local p9 = tonumber(ms.upgrades.SmeltSpeed) or 0
    local p9_1 = TrainConfig.upgradeMaxLevel("SmeltSpeed")
    local qb = typeof(p9_1) == "number" and p9 >= p9_1
    if qb then
        return
    end
    local p9_2 = TrainConfig.upgradeCost("SmeltSpeed", p9)
    local qa_1 = typeof(p9_2) ~= "number" or ms.cash < p9_2
    if qa_1 then
        return
    end
    mZ = p8
    mt()
    PurchaseUpgrade:FireServer("SmeltSpeed", 1)
end
local function fn842(aV)
    local nT = lI(aV, {})
    if typeof(nT) ~= "table" then
        return {}
    end
    local nU = {}
    for k, v in nT do
        if v == true then
            nU[k] = true
        else
            local nT_1 = typeof(k) == "number" and typeof(v) == "string"
            if nT_1 then
                nU[v] = true
            end
        end
    end
    return nU
end
local function fn862()
    local oL = os.clock()
    if oL - mj < 0.75 then
        return
    end
    mj = oL
    pcall(function()
        CartsUpdate:FireServer()
    end)
end
local function fn897(cu, cv)
    local pa = mA()
    local pb = not pa or typeof(cu) ~= "CFrame"
    if pb then
        return false
    end
    return (pa.Position - cu.Position).Magnitude <= (cv or 12)
end
local function fn912()
    local Character = l0.Character
    local n8 = Character and Character:FindFirstChild("HumanoidRootPart")
    return n8
end
local function fn954(fn)
    local DiscordGroup = fn:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = mu })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = mu })
end
local function fn960(ch, ci)
    local o5_1
    local o4_1
    local o3_1
    local o2_1
    local o1_1
    local o0_1
    if not ch then
        return false
    elseif not ci then
        return true
    else
        o0_1, o1_1, o2_1 = m0(ch)
        o3_1, o4_1, o5_1 = m0(ci)
        if o0_1 ~= o3_1 then
            return o0_1 > o3_1
        elseif o1_1 ~= o4_1 then
            return o1_1 > o4_1
        else
            return o2_1 > o5_1
        end
    end
end
lI = nil
lJ = nil
CartsUpdate = nil
lL = nil
lN = nil
Toggles = nil
lQ = nil
lR = nil
lT = nil
lU = nil
lW = nil
lY = nil
lZ = nil
l_ = nil
l0 = nil
l2 = nil
Library = nil
l4 = nil
PurchaseUpgrade = nil
l6 = nil
l7 = nil
l8 = nil
l9 = nil
mb = nil
ClaimCash = nil
md = nil
me = nil
mg = nil
mh = nil
mj = nil
mk = nil
mm = nil
mo = nil
mp = nil
mq = nil
ms = nil
mt = nil
mu = nil
local lM, lP, lS, SaveManager, lX, l1, Window, CoreGui, mi, ml, mn, mr
mw = nil
mx = nil
mA = nil
mE = nil
mF = nil
mH = nil
mI = nil
mL = nil
TrainConfig = nil
mN = nil
mP = nil
mQ = nil
mR = nil
mS = nil
mT = nil
mU = nil
mV = nil
mW = nil
mX = nil
mY = nil
mZ = nil
m_ = nil
m0 = nil
Options = nil
local mv, my, mz, mB, mC, mD, mG, mJ, SetCartEquipped, mO, m1, m7, m8, na, ne
local m9_1
local m6_1, CartsGroup
local m5_1
local nc_7
local m3_1
m3_1, m5_1, mO, mJ, mB, mv, mn, CoreGui, l9, l0, lX, lT, lM, m6_1, mS, TrainConfig, mF, mz, mq, mk, ClaimCash, PurchaseUpgrade, lZ, m8, m7, CartsUpdate, mX, mQ, SetCartEquipped, na, m9_1, mo = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local m4 = 5
local m4_5
repeat
    local nb_1 = (m4 * 11 + 1) % 14 + 1
    if nb_1 <= 7 then
        if nb_1 <= 4 then
            if nb_1 <= 2 then
                if nb_1 <= 1 then
                    local nc_1 = { "kqemhb", "jqtthnynwna", "zznsgua", "lgccoog", "mwiflgx", "febnjot", "zbeajwzwf", "eeiuo" }
                    if nc_1[(m4 * 6 + 112) % 8 + 1] < nc_1[(m4 * 6 + 112) % 8 + 1] then
                        mB = game:GetService("Players")
                    else
                        m3_1 = game:GetService("Players")
                    end
                    m4 = (m4 + 9) % 56
                else
                    local uN = bit32.rrotate(bit32.bxor(bit32.lrotate(m4, 20), string.byte(tostring(m8))), 25)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(uN, 3356465353), 18), 1663508542) ~= bit32.lrotate(uN, 18) then
                        l9 = game:GetService("ReplicatedStorage")
                    else
                        m5_1 = game:GetService("ReplicatedStorage")
                    end
                    m4 = (m4 + 37) % 56
                end
            elseif nb_1 <= 3 then
                local nc_2 = (vector.create((m4 * 1 + 5) % 11 + 1, (m4 * 5 + 8) % 13 + 1, (m4 * 15 + 2) % 17 + 1))
                local nd_1 = (vector.create((m4 * 6 + 3) % 11 + 1, (m4 * 5 + 2) % 13 + 1, (m4 * 10 + 12) % 17 + 1))
                ne = (vector.create((m4 * 7 + 3) % 11 + 1, (m4 * 4 + 9) % 13 + 1, (m4 * 10 + 16) % 17 + 1))
                local nf = (vector.create((m4 * 1 + 2) % 5 + 1, (m4 * 1 + 3) % 7 + 1, (m4 * 4 + 2) % 9 + 1))
                if vector.dot(vector.cross(nc_2, (vector.cross(nd_1, ne))), nf) == vector.dot(nd_1 * vector.dot(nc_2, ne) - ne * vector.dot(nc_2, nd_1), nf) then
                    mO = game:GetService("RunService")
                    mJ = game:GetService("UserInputService")
                    mB = game:GetService("VirtualUser")
                    mv = game:GetService("HttpService")
                    mn = game:GetService("GuiService")
                else
                    mn = game:GetService("RunService")
                    mO = game:GetService("UserInputService")
                    mJ = game:GetService("VirtualUser")
                    mB = game:GetService("HttpService")
                    mv = game:GetService("GuiService")
                end
                m4 = (m4 + 23) % 56
            else
                if m4 * 96595721 + 7 + 7 <= m4 * 96595721 + 7 + 7 + 1 then
                    CoreGui = game:GetService("CoreGui")
                else
                    mS = game:GetService("CoreGui")
                end
                m4 = (m4 + 9) % 56
            end
        elseif nb_1 <= 6 then
            if nb_1 <= 5 then
                local nc_3 = {
                    "ipnewngkrek",
                    "ahwthmyuqrg",
                    "ckhnlgl",
                    "jcml",
                    "qipc",
                    "ccujrzfkgm",
                    "ypvsptad",
                    "pxiiicv",
                    "fdlsy"
                }
                local ui = m4
                local nd_2 = nc_3[ui % 9 + 1]
                if nd_2:len() <= nd_2:gsub("(.)", "%1%1", ui % 3 % 2 + 1):len() then
                    l9 = game:GetService("Workspace")
                    l0 = m3_1.LocalPlayer
                else
                    l0 = game:GetService("Workspace")
                    m3_1 = l9.LocalPlayer
                end
                m4 = (m4 + 9) % 56
            else
                local nc_4 = (vector.create((m4 * 1 + 1) % 11 + 1, (m4 * 1 + 6) % 13 + 1, (m4 * 14 + 8) % 17 + 1))
                local nd_3 = (vector.create((m4 * 7 + 3) % 11 + 1, (m4 * 2 + 5) % 13 + 1, (m4 * 1 + 4) % 17 + 1))
                local t1 = vector.dot(nc_4, nd_3)
                if t1 * t1 <= vector.dot(nc_4, nc_4) * vector.dot(nd_3, nd_3) then
                    lX = "My Lucky Train"
                    lT = "https://discord.gg/K7Qxnxkk46"
                else
                    lT = "My Lucky Train"
                    lX = "https://discord.gg/K7Qxnxkk46"
                end
                m4 = (m4 + 9) % 56
            end
        else
            local nc_5 = {
                "hekgrcejxk",
                "vyk",
                "huode",
                "eunqemhx",
                "wmbvewxalx",
                "jjjw",
                "esogb",
                "lrndf",
                "xyjqaoqq",
                "vnf",
                "audapnp",
                "tipyzd",
                "vlluuj",
                "ovwysmyl"
            }
            if nc_5[(m4 * 56 + 40) % 14 + 1] < nc_5[(m4 * 56 + 40) % 14 + 1] then
                mF = "https://discord.gg/K7Qxnxkk46"
            else
                lM = "https://discord.gg/K7Qxnxkk46"
            end
            m4 = (m4 + 23) % 56
        end
    elseif nb_1 <= 11 then
        if nb_1 <= 9 then
            if nb_1 <= 8 then
                local ue = bit32.rrotate(bit32.bxor(bit32.lrotate(m4, 6), string.byte(tostring(lZ))), 28)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(ue, 880532351), 4022730903), (bit32.bxor(bit32.band(ue, 3414434944), 1953730334))), 4022730903), 1953730334) ~= ue then
                    m5_1 = m6_1:WaitForChild("TrainRemotes")
                else
                    m6_1 = m5_1:WaitForChild("TrainRemotes")
                end
                m4 = (m4 + 23) % 56
            else
                if m4 * 124985667 + 9 + 4 >= m4 * 124985667 + 9 + 4 + 3 then
                    m5_1 = require(mS:WaitForChild("CartRegistry"))
                else
                    mS = require(m5_1:WaitForChild("CartRegistry"))
                end
                m4 = (m4 + 37) % 56
            end
        elseif nb_1 <= 10 then
            local uh = bit32.rrotate(bit32.bxor(bit32.lrotate(m4, 27), 104), 14)
            if bit32.bxor(bit32.lrotate(bit32.bxor(uh, 182833353), 6), 3111400002) ~= bit32.lrotate(uh, 6) then
                m5_1 = require(TrainConfig:WaitForChild("TrainConfig"))
            else
                TrainConfig = require(m5_1:WaitForChild("TrainConfig"))
            end
            m4 = (m4 + 37) % 56
        else
            if (m4 * 2 + 7) * 10 % 3 == ((m4 * 2 + 7) * 10 + 4) % 3 then
                mz = require(m6_1:WaitForChild("Progression"))
                m5_1 = require(m6_1:WaitForChild("MyIsland"))
                mF = ClaimCash:WaitForChild("ClaimOre")
                mq = ClaimCash:WaitForChild("OreReconcile")
                mk = ClaimCash:WaitForChild("ClaimCash")
            else
                mF = require(m5_1:WaitForChild("Progression"))
                mz = require(m5_1:WaitForChild("MyIsland"))
                mq = m6_1:WaitForChild("ClaimOre")
                mk = m6_1:WaitForChild("OreReconcile")
                ClaimCash = m6_1:WaitForChild("ClaimCash")
            end
            m4 = (m4 + 37) % 56
        end
    elseif nb_1 <= 13 then
        if nb_1 <= 12 then
            local uf = bit32.rrotate(bit32.bxor(bit32.lrotate(m4, 13), string.byte(tostring(m6_1))), 9)
            if bit32.bxor(bit32.lrotate(bit32.bxor(uf, 2174196302), 20), 2766674297) ~= bit32.lrotate(uf, 20) then
                m6_1 = PurchaseUpgrade:WaitForChild("PurchaseUpgrade")
                m8 = PurchaseUpgrade:WaitForChild("DoRebirth")
                lZ = PurchaseUpgrade:WaitForChild("StateUpdate")
            else
                PurchaseUpgrade = m6_1:WaitForChild("PurchaseUpgrade")
                lZ = m6_1:WaitForChild("DoRebirth")
                m8 = m6_1:WaitForChild("StateUpdate")
            end
            m4 = (m4 + 23) % 56
        else
            local uy = bit32.rrotate(bit32.bxor(bit32.lrotate(m4, 2), 104), 11)
            if bit32.bxor(bit32.lrotate(bit32.bxor(uy, 602471137), 28), 306089902) ~= bit32.lrotate(uy, 28) then
                mX = CartsUpdate:WaitForChild("FurnaceUpdate")
                m7 = CartsUpdate:WaitForChild("CartsUpdate")
                m6_1 = CartsUpdate:WaitForChild("UpgradeCart")
            else
                m7 = m6_1:WaitForChild("FurnaceUpdate")
                CartsUpdate = m6_1:WaitForChild("CartsUpdate")
                mX = m6_1:WaitForChild("UpgradeCart")
            end
            m4 = (m4 + 23) % 56
        end
    else
        local nb_2 = {
            "iuakszih",
            "afqrmrfjmf",
            "awe",
            "kqfvyum",
            "fbzds",
            "eoqszyzwct",
            "uerxi",
            "filslmqh",
            "emfcs",
            "sjbaq",
            "uclew"
        }
        local uE = m4
        local nc_6 = nb_2[uE % 11 + 1]
        local nm = if nc_6:len() >= nc_6:reverse():rep(uE % 3 + 2):len() then 1 else 0
        if nm == 1 then
            mS = mo:WaitForChild("SellCart")
            m6_1 = mo:WaitForChild("SetCartEquipped")
            m9_1 = table.clone(SetCartEquipped.RARITY_ORDER)
            table.insert(m9_1, "Exclusive")
            na = {}
            mQ = {}
        else
            mQ = m6_1:WaitForChild("SellCart")
            SetCartEquipped = m6_1:WaitForChild("SetCartEquipped")
            na = table.clone(mS.RARITY_ORDER)
            table.insert(na, "Exclusive")
            m9_1 = {}
            mo = {}
        end
        m4 = (m4 + 37) % 56
    end
until (m4 * 1 + 24) % 56 == 29
for k, v in TrainConfig.UPGRADE_ORDER do
    local m3_2 = TrainConfig.UPGRADES[v]
    local m3_3 = m3_2 and m3_2.DisplayName or v
    table.insert(m9_1, m3_3)
    mo[m3_3] = v
end
for k, v in TrainConfig.UPGRADES do
    local m3_4 = v.DisplayName or k
    if not mo[m3_4] then
        table.insert(m9_1, m3_4)
        mo[m3_4] = k
    end
end
mN = {}
for k, v in mS.RARITY_ORDER do
    mN[v] = k
end
ms, mm = nil, nil
local m3_5 = 1
repeat
    local uF = bit32.rrotate(bit32.bxor(bit32.lrotate(m3_5, 25), string.byte(tostring(mm))), 28)
    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(uF, 2023740021), 2616447341), (bit32.bxor(bit32.band(uF, 2271227274), 1700976449))), 2616447341), 1700976449) ~= uF then
        mm.Exclusive = #mN.RARITY_ORDER + 1
        mS = { carriedUnits = 0, upgrades = {}, rollReadyAt = 0, rollBuyingPower = 0, rebirths = 0, cash = 0 }
        ms = { pending = 0, value = 0, units = 0, carried = 0 }
    else
        mN.Exclusive = #mS.RARITY_ORDER + 1
        ms = { cash = 0, rebirths = 0, carriedUnits = 0, rollReadyAt = 0, upgrades = {}, rollBuyingPower = 0 }
        mm = { value = 0, pending = 0, units = 0, carried = 0 }
    end
    m3_5 = (m3_5 + 3) % 4
until (m3_5 * 3 + 2) % 4 == 2
local m4_4 = {}
local m3_6 = {}
local m5_2 = TrainConfig.CART_MAX_LEVEL or 10
md, l7, l_, lW, lR, lL, mZ, mR, mL, mD, mx, mp, mj, Library, SaveManager, Toggles, Options, mG, my, mr, ml, Window, l1, mU, mu, l8, lS, mb, lI, mw, m1, mA, l6, mY, mC, lY, me, mP, mg, m0, lP, l4, lN, mt, m_, lJ, mW, mT, lQ, mI, mE, mH, l2, mh, mV, lU, nc_7 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
md = { equipped = m4_4, storage = m3_6, maxSlots = 0, maxCartLevel = m5_2 }
l7 = 0
l_ = 0
lW = 0
lR = 0
lL = 0
mZ = 0
if ((not lS or mC) and (mr or l2) or (not lS or l2) and (not mP or false)) and not ((not lS or mC) and (mr or l2) or (not lS or l2) and (not mP or false)) then
    mD = 0
    mR = 0
    mL = 0
else
    mR = 0
    mL = 0
    mD = 0
end
mx = 0
mp = 0
mj = 0
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
mU = fn292
mu = fn92
l8 = fn85
lS = fn425
mG = "#7fd47f"
my = "#6ec1ff"
mr = "#e8a34d"
ml = "#8b93a3"
mb = fn809
lI = fn501
if not lI and false and (l7 or lI) or mE and not mR and (not lI or mE) or not (not lI and false and (l7 or lI) or mE and not mR and (not lI or mE)) then
    mw = fn842
    m1 = fn69
    mA = fn912
else
    mA = fn842
    mw = fn69
    m1 = fn912
end
l6 = fn202
mY = fn25
mC = fn358
lY = function(bq)
    local oo_1
    local om_1
    om_1, oo_1 = pcall(function()
        return mz.find(bq, 5)
    end)
    if om_1 and oo_1 then
        return oo_1
    end
    local om_2 = mC()
    local oo_2 = om_2 and om_2:FindFirstChild(bq, true)
    return oo_2
end
me = function(bB)
    local ox_1
    local ow_1
    if not bB then
        return nil
    elseif bB:IsA("BasePart") then
        return bB.CFrame
    else
        ow_1, ox_1 = pcall(function()
            return bB:GetPivot()
        end)
        local oy = ow_1 and typeof(ox_1) == "CFrame"
        if oy then
            return ox_1
        end
        local BasePart = bB:FindFirstChildWhichIsA("BasePart", true)
        return BasePart and BasePart.CFrame or nil
    end
end
m8.OnClientEvent:Connect(onOnClientEvent)
m7.OnClientEvent:Connect(onOnClientEvent2)
CartsUpdate.OnClientEvent:Connect(onOnClientEvent3)
mP = fn862
mg = fn607
m0 = fn775
lP = fn960
l4 = fn259
if (md and ThemeManager and (md or mt) or (md or ThemeManager) and (md and not md) or (ThemeManager or ThemeManager) and (mt or not mt) and (ThemeManager or not md or mt and mt)) and not (md and ThemeManager and (md or mt) or (md or ThemeManager) and (md and not md) or (ThemeManager or ThemeManager) and (mt or not mt) and (ThemeManager or not md or mt and mt)) then
    mt = fn897
    m_ = fn455
    lN = fn100
else
    lN = fn897
    mt = fn455
    m_ = fn100
end
lJ = fn363
mW = fn403
mT = fn177
lQ = fn575
mI = fn828
mE = function()
    if not mb("AutoReplaceCart") then
        return
    end
    local qe = os.clock()
    if qe - mD < 0.6 then
        return
    end
    mP()
    local equipped = md.equipped
    local storage = md.storage
    local qh = typeof(equipped) ~= "table"
    local qm = if qh then 1 else 0
    local qk = 1044 * qm + 2431 * (1 - qm)
    local ql = 105 * qm + 3887 * (1 - qm)
    if not ((qk * 159 + ql * 2390 + qk * ql) % 16777213 == 526566) then
        qh = typeof(storage) ~= "table"
    end
    if qh then
        return
    end
    local qd
    for k, v in storage do
        local qg_1 = typeof(v) == "table" and typeof(v.uid) == "string" and not v.locked
        if qg_1 then
            if lP(v, qd) then
                qd = v
            end
        end
    end
    if not qd then
        return
    end
    local qg_2 = nil
    local qh_1 = 0
    for k, v in equipped do
        local qf_1 = typeof(v) == "table" and typeof(v.uid) == "string"
        if qf_1 then
            qh_1 += 1
            local qf_2 = qg_2 == nil or lP(qg_2, v)
            if qf_2 then
                qg_2 = v
            end
        end
    end
    local qf_3 = tonumber(md.maxSlots) or 0
    if qh_1 < qf_3 then
        mD = qe
        SetCartEquipped:FireServer(qd.uid, true)
        return
    end
    local qf_4 = qg_2 and lP(qd, qg_2) and qd.uid ~= qg_2.uid
    if qf_4 then
        mD = qe
        SetCartEquipped:FireServer(qg_2.uid, false)
        task.defer(function()
            SetCartEquipped:FireServer(qd.uid, true)
        end)
    end
end
mH = fn598
l2 = fn51
mh = fn381
mV = fn474
lU = fn677
task.spawn(worker)
Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = lT, Copyable = true }, "|", lX },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
l1 = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gamepad-2"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
if ((not mw and mH) or (not mw or 0 or (not mw or not mw))) and (mw or 0 or (not mh or not mh) or mx and 0 and (not mh and mh)) and ((mH or (not mH or mH) and 0) and (not mH or mx or (not mH or not mh) or (mx and mh or mw and false))) and not (((not mw and mH) or (not mw or 0 or (not mw or not mw))) and (mw or 0 or (not mh or not mh) or mx and 0 and (not mh and mh)) and ((mH or (not mH or mH) and 0) and (not mH or mx or (not mH or not mh) or (mx and mh or mw and false)))) then
    mG = fn954
else
    nc_7 = fn954
end
for k, v in l1 do
    nc_7(v)
end
local function m3_7()
    local rA
    rA = nil
    local rx, ry, rz, Label
    rA = "Unknown"
    pcall(function()
        local rk_1
        local rj_1
        if identifyexecutor then
            rk_1, rj_1 = identifyexecutor()
            local rl = rk_1 ~= ""
            local rm = type(rk_1) == "string" and rl
            if rm then
                local rl_1 = type(rj_1) == "string" and rj_1 ~= "" and rk_1 .. " " .. rj_1
                rA = rl_1 or rk_1
            end
        end
    end)
    local AccountGroup = l1.Info:AddLeftGroupbox("Account", "circle-user")
    AccountGroup:AddLabel(lS("User", l0.Name, mG), true)
    AccountGroup:AddLabel(lS("Status", "Keyless", mG), true)
    AccountGroup:AddLabel(lS("Executor", rA, mG), true)
    local GameInfoGroup = l1.Info:AddLeftGroupbox("Game Info", "gamepad-2")
    GameInfoGroup:AddLabel(l8(lX .. " [" .. tostring(game.PlaceId) .. "]", my), true)
    GameInfoGroup:AddLabel(lS("Place ID", tostring(game.PlaceId), my), true)
    Label = GameInfoGroup:AddLabel(lS("Session time", "0s", mr), true)
    ry = tostring(game.JobId)
    local rD = #ry > 18 and string.sub(ry, 1, 18) .. "..."
    local rE = rD
    local rI = if rE then 1 else 0
    local rG = 51 * rI + 2554 * (1 - rI)
    local rH = 3549 * rI + 3692 * (1 - rI)
    if not ((rG * 3603 + rH * 1934 + rG * rH) % 16777213 == 7228518) then
        rE = ry
    end
    local rD_1 = rE
    GameInfoGroup:AddLabel(lS("Server", rD_1, ml), true)
    GameInfoGroup:AddButton({
        Text = "Copy join script (Job ID)",
        Func = function()
            local fN = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, ry)
            mU(fN, "Copied join script to clipboard")
        end
    })
    rx = os.clock()
    task.spawn(function()
        local rv_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            local ru = math.floor(os.clock() - rx)
            if ru < 60 then
                rv_1 = ru .. "s"
            elseif ru < 3600 then
                rv_1 = string.format("%dm %ds", math.floor((ru) / (60)), ru % 60)
            else
                rv_1 = string.format("%dh %dm", math.floor((ru) / (3600)), math.floor((ru % 3600) / (60)))
            end
            Label:SetText(lS("Session time", rv_1, mr))
        end
    end)
    local ScriptsGroup = l1.Info:AddRightGroupbox("Scripts", "package")
    ScriptsGroup:AddLabel(l8("Included in this hub", ml), true)
    ScriptsGroup:AddLabel(l8(lX, my), true)
    local FeaturesGroup = l1.Info:AddRightGroupbox("Features", "list")
    FeaturesGroup:AddLabel(l8("Automation", my), true)
    FeaturesGroup:AddLabel(l8("Misc Utilities", ml), true)
    local SocialsGroup = l1.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = mu })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            mU(lM, "Copied Rscripts profile to clipboard")
        end
    })
    local TempoHubGroup = l1.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
    TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = mu })
    rz = {
        [1] = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w",
        [2] = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99",
        [3] = "0xaE95A405D007a6F858E5d35714111B075fEFb40a",
        [4] = "0xaE95A405D007a6F858E5d35714111B075fEFb40a",
        [5] = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp",
        [6] = "",
        [7] = ""
    }
    local DonationsGroup = l1.Info:AddRightGroupbox("Donations", "heart")
    DonationsGroup:AddLabel(l8("All donations are optional but appreciated.", mr), true)
    DonationsGroup:AddLabel(l8("If you donate you get a special role, just PING after you donate.", mG), true)
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(l8("LTC / Litecoin", "#345d9d"), true)
    DonationsGroup:AddButton({
        Text = "Copy Litecoin Address",
        Func = function()
            mU(rz[1], "Copied Litecoin address")
        end
    })
    DonationsGroup:AddLabel(l8("BTC / Bitcoin", "#f7931a"), true)
    DonationsGroup:AddButton({
        Text = "Copy Bitcoin Address",
        Func = function()
            mU(rz[2], "Copied Bitcoin address")
        end
    })
    DonationsGroup:AddLabel(l8("ETH / Ethereum", "#627eea"), true)
    DonationsGroup:AddButton({
        Text = "Copy Ethereum Address",
        Func = function()
            mU(rz[3], "Copied Ethereum address")
        end
    })
    DonationsGroup:AddLabel(l8("USDT", "#26a17b"), true)
    DonationsGroup:AddButton({
        Text = "Copy USDT Address",
        Func = function()
            mU(rz[4], "Copied USDT address")
        end
    })
    DonationsGroup:AddLabel(l8("Solana", "#14f195"), true)
    DonationsGroup:AddButton({
        Text = "Copy Solana Address",
        Func = function()
            mU(rz[5], "Copied Solana address")
        end
    })
    DonationsGroup:AddLabel(l8("PayPal", "#0070ba"), true)
    DonationsGroup:AddButton({
        Text = "Copy PayPal Link",
        Func = function()
            mU(rz[6], "Copied PayPal link")
        end
    })
    DonationsGroup:AddLabel(l8("Venmo", "#008cff"), true)
    DonationsGroup:AddButton({
        Text = "Copy Venmo Link",
        Func = function()
            mU(rz[7], "Copied Venmo link")
        end
    })
    DonationsGroup:AddDivider()
    DonationsGroup:AddLabel(l8("Don't have any of the listed currencies but still wanna donate?", ml), true)
    DonationsGroup:AddLabel(l8("DM me and we'll work something out.", my), true)
    local FaqGroup = l1.Info:AddRightGroupbox("FAQ", "circle-help")
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
end
m3_7()
CartsGroup, m4_5 = nil, nil
m8 = l1.Main:AddLeftGroupbox("Lever", "dices")
m8:AddToggle("AutoPullLever", { Text = "Auto Pull Lever", Default = false })
m8:AddSlider("PullDelay", { Text = "Pull Delay", Default = 0.35, Min = 0.05, Max = 2, Rounding = 2 })
m8:AddToggle("AutoBuyLeverResult", { Text = "Auto Buy Lever Result", Default = false })
m8:AddDropdown("BuyRarities", { Text = "Buy Rarities", Values = na, Default = {}, Multi = true, AllowNull = true })
Toggles.AutoPullLever:OnChanged(function()
    if not Toggles.AutoPullLever.Value then
        return
    end
    local rJ = Library.Dialogues and Library.Dialogues.PullLeverProximity
    if rJ then
        pcall(function()
            rJ:Dismiss()
        end)
    end
    Window:AddDialog("PullLeverProximity", {
        Title = "Auto Pull Lever",
        Description = "You have to be near it.",
        AutoDismiss = true,
        OutsideClickDismiss = true,
        FooterButtons = { { Id = "ok", Title = "Got it", Variant = "Primary", Order = 1 } }
    })
end)
m7 = l1.Main:AddLeftGroupbox("Ore", "pickaxe")
if ((not m7 or CartsGroup) and (not m4_5 or not CartsGroup) or (m7 or not m4_5) and (not m8) or m8 and m7 and (m4_5 and not m7) and (m7 and not CartsGroup or not m7 and 10) or (m8 and not CartsGroup and (not CartsGroup or not CartsGroup) or m7 and false and (CartsGroup or not m7)) and (not m8 and 10 and (not m4_5 and not CartsGroup) or (m8 or m7))) and not ((not m7 or CartsGroup) and (not m4_5 or not CartsGroup) or (m7 or not m4_5) and (not m8) or m8 and m7 and (m4_5 and not m7) and (m7 and not CartsGroup or not m7 and 10) or (m8 and not CartsGroup and (not CartsGroup or not CartsGroup) or m7 and false and (CartsGroup or not m7)) and (not m8 and 10 and (not m4_5 and not CartsGroup) or (m8 or m7))) then
    CartsGroup:AddToggle("AutoCollectOre", { Text = "Auto Collect Ore", Default = false })
    CartsGroup:AddToggle("AutoDeposit", { Text = "Auto Deposit", Default = false })
    CartsGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
    CartsGroup:AddSlider("SellDelay", { Min = 0.1, Max = 5, Default = 0.5, Rounding = 2, Text = "Sell Delay" })
    l1 = m7.Main:AddRightGroupbox("Carts", "box")
else
    m7:AddToggle("AutoCollectOre", { Text = "Auto Collect Ore", Default = false })
    m7:AddToggle("AutoDeposit", { Text = "Auto Deposit", Default = false })
    m7:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
    m7:AddSlider("SellDelay", { Text = "Sell Delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 2 })
    CartsGroup = l1.Main:AddRightGroupbox("Carts", "box")
end
CartsGroup:AddToggle("AutoReplaceCart", { Text = "Auto Replace Better Cart", Default = false })
CartsGroup:AddToggle("AutoUpgradeCart", { Text = "Auto Upgrade Cart", Default = false })
CartsGroup:AddDropdown("CartUpgradeRarities", { Text = "Upgrade Rarities", Values = na, Default = {}, Multi = true, AllowNull = true })
CartsGroup:AddToggle("AutoSellCart", { Text = "Auto Sell Cart", Default = false })
CartsGroup:AddDropdown("CartSellRarities", { Text = "Sell Rarities", Values = na, Default = {}, Multi = true, AllowNull = true })
local UpgradesGroup = l1.Main:AddRightGroupbox("Upgrades", "arrow-big-up")
if (UpgradesGroup and 4 or (not CartsGroup or not CartsGroup) or (UpgradesGroup or CartsGroup) and (not CartsGroup or not CartsGroup)) and not (UpgradesGroup and 4 or (not CartsGroup or not CartsGroup) or (UpgradesGroup or CartsGroup) and (not CartsGroup or not CartsGroup)) then
    m9_1:AddToggle("AutoUpgradeSmelt", { Text = "Auto Upgrade Smelt Speed", Default = false })
    m9_1:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
    m9_1:AddDropdown("UpgradeList", { Values = UpgradesGroup, AllowNull = true, Multi = true, Default = {}, Text = "Upgrades" })
    m9_1:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
else
    UpgradesGroup:AddToggle("AutoUpgradeSmelt", { Text = "Auto Upgrade Smelt Speed", Default = false })
    UpgradesGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
    UpgradesGroup:AddDropdown("UpgradeList", { Text = "Upgrades", Values = m9_1, Default = {}, Multi = true, AllowNull = true })
    UpgradesGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
end
mi = nil
local function m3_8()
    local MovementGroup = l1.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = l1.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    mO.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = l0.Character
            if Character then
                for i, descendant in Character:GetDescendants() do
                    local rM_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if rM_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    mJ.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local rX_1 = m1()
            if rX_1 then
                rX_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    local CurrentCamera = l9.CurrentCamera
    mO.RenderStepped:Connect(function(gX)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local rZ_1 = m1()
            if rZ_1 then
                rZ_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local rZ_3 = mA()
            local r_ = m1()
            if rZ_3 and r_ then
                r_.PlatformStand = true
                local r__1 = Vector3.zero
                if mJ:IsKeyDown(Enum.KeyCode.W) then
                    r__1 += CurrentCamera.CFrame.LookVector
                end
                if mJ:IsKeyDown(Enum.KeyCode.S) then
                    r__1 -= CurrentCamera.CFrame.LookVector
                end
                local r4 = if mJ:IsKeyDown(Enum.KeyCode.A) then 1 else 0
                if r4 == 1 then
                    r__1 -= CurrentCamera.CFrame.RightVector
                end
                if mJ:IsKeyDown(Enum.KeyCode.D) then
                    r__1 += CurrentCamera.CFrame.RightVector
                end
                local r4_1 = if mJ:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
                if r4_1 == 1 then
                    r__1 += Vector3.new(0, 1, 0)
                end
                if mJ:IsKeyDown(Enum.KeyCode.LeftControl) then
                    r__1 -= Vector3.new(0, 1, 0)
                end
                rZ_3.AssemblyLinearVelocity = Vector3.zero
                if r__1.Magnitude > 0 then
                    rZ_3.CFrame = rZ_3.CFrame + r__1.Unit * Options.FlySpeed.Value * gX
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local r8 = m1()
            if r8 then
                r8.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local sa = m1()
            if sa then
                sa.WalkSpeed = 16
            end
        end
    end)
    local function hi(hj)
        pcall(function()
            mn:SetGameplayPausedNotificationEnabled(not hj)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not hj
            end
        end)
        if not hj then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(l0, "GameplayPaused", false)
            else
                l0.GameplayPaused = false
            end
        end)
    end
    Toggles.AntiGameplayPause:OnChanged(function()
        hi(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                hi(true)
            end
        end
    end)
    local function hA(hB)
        if not hB:IsA("ProximityPrompt") then
            return
        end
        hB.HoldDuration = 0
        hB.MaxActivationDistance = 50
        hB.RequiresLineOfSight = false
    end
    local connection
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in l9:GetDescendants() do
                pcall(hA, descendant)
            end
            connection = l9.DescendantAdded:Connect(function(hJ)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(hA, hJ)
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    Library:OnUnload(function()
        hi(false)
        if connection then
            connection:Disconnect()
        end
    end)
end
m3_8()
ne = function()
    local connection
    local MenuGroup = l1.Settings:AddLeftGroupbox("Menu")
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local hT = 0
    local hU = tick()
    local Label = MenuGroup:AddLabel("AFK triggers: 0")
    local function hW()
        local CurrentCamera = l9.CurrentCamera
        if not CurrentCamera then
            return
        end
        mB:CaptureController()
        mB:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        hT += 1
        hU = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. hT)
        end)
    end
    connection = l0.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(hW)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local sG = Toggles.AntiAfk.Value and tick() - hU >= 60
            if sG then
                pcall(hW)
            end
        end
    end)
    MenuGroup:AddButton({
        Text = "Unload UI",
        Func = function()
            Library:Unload()
        end
    })
    Library:OnUnload(function()
        if connection then
            connection:Disconnect()
        end
    end)
end
ne()
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(l1.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/MyLuckyTrain")
mi = SaveManager:BuildConfigSection(l1.Settings)
local function nb_3()
    local function im(io, ip)
        local sK_1 = (io == "Toggle" and Toggles or Options)[ip]
        local sJ_2 = type(sK_1) == "table" and sK_1.Type == io
        return sJ_2 and sK_1 or nil
    end
    local function ix(iy, iz)
        local Type = iz.Type
        if Type == "Toggle" then
            return { idx = iy, type = "Toggle", value = iz.Value == true }
        elseif Type == "Slider" then
            return { idx = iy, type = "Slider", value = tostring(iz.Value) }
        elseif Type == "Dropdown" then
            return { idx = iy, type = "Dropdown", multi = iz.Multi == true, value = iz.Value }
        elseif Type == "Input" then
            local sO = iz.Value or ""
            return { idx = iy, type = "Input", text = tostring(sO) }
        elseif Type == "ColorPicker" then
            return { idx = iy, type = "ColorPicker", value = iz.Value:ToHex(), transparency = iz.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = iy,
                type = "KeyPicker",
                mode = iz.Mode,
                key = iz.Value,
                modifiers = iz.Modifiers,
                toggled = iz.Toggled
            }
        else
            return nil
        end
    end
    local function iB()
        local sU = {}
        for k, v in { Toggles, Options } do
            for k, v in v do
                local sV = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if sV then
                    local sV_1 = ix(k, v)
                    if sV_1 then
                        sU[#sU + 1] = sV_1
                    end
                end
            end
        end
        table.sort(sU, function(iL, iM)
            if iL.type ~= iM.type then
                return iL.type < iM.type
            end
            return iL.idx < iM.idx
        end)
        return { objects = sU }
    end
    local function iN(iO)
        local td
        td = nil
        local te = type(iO) ~= "table"
        local ti = if te then 1 else 0
        local tg = 151 * ti + 3912 * (1 - ti)
        local th = 1174 * ti + 2330 * (1 - ti)
        if not ((tg * 3986 + th * 2598 + tg * th) % 16777213 == 3829212) then
            te = type(iO.idx) ~= "string"
        end
        local tl = if te then 1 else 0
        local tj = 142 * tl + 2180 * (1 - tl)
        local tk = 3783 * tl + 1982 * (1 - tl)
        if not ((tj * 2348 + tk * 2336 + tj * tk) % 16777213 == 9707690) then
            te = type(iO.type) ~= "string"
        end
        if not te then
            te = SaveManager.Ignore[iO.idx]
        end
        if te then
            return false
        end
        td = im(iO.type, iO.idx)
        if not td then
            return false
        end
        local te_1 = pcall(function()
            if iO.type == "Input" then
                if type(iO.text) ~= "string" then
                    return
                end
                td:SetValue(iO.text)
            elseif iO.type == "ColorPicker" then
                td:SetValueRGB(Color3.fromHex(iO.value), iO.transparency)
            elseif iO.type == "KeyPicker" then
                td:SetValue({ iO.key, iO.mode, iO.modifiers })
                if iO.mode == "Toggle" and iO.toggled ~= nil then
                    td.Toggled = iO.toggled
                    td:Update()
                end
            else
                td:SetValue(iO.value)
            end
        end)
        return te_1
    end
    mi:AddDivider()
    mi:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    mi:AddButton("Export Config to Clipboard", function()
        local tn_1
        local tm_1
        tm_1, tn_1 = pcall(mv.JSONEncode, mv, iB())
        if not tm_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local tm_2 = setclipboard
        local ts = if tm_2 then 1 else 0
        local tq = 692 * ts + 262 * (1 - ts)
        local tr = 2412 * ts + 3245 * (1 - ts)
        if not ((tq * 3784 + tr * 656 + tq * tr) % 16777213 == 5869904) then
            tm_2 = toclipboard
        end
        local to = tm_2
        local tm_3 = type(to) ~= "function" or not pcall(to, tn_1)
        if tm_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    mi:AddButton("Import Config from Clipboard Text", function()
        local tv_1
        local tt = Options.SaveManager_ImportSource.Value
        local tt_1
        local tz = if tt then 1 else 0
        local tx = 335 * tz + 228 * (1 - tz)
        local ty = 2236 * tz + 3021 * (1 - tz)
        if not ((tx * 2853 + ty * 2838 + tx * ty) % 16777213 == 8050583) then
            tt = ""
        end
        local tu = tostring(tt):match("^%s*(.-)%s*$")
        if tu == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        tt_1, tv_1 = pcall(mv.JSONDecode, mv, tu)
        local tu_1 = not tt_1 or type(tv_1) ~= "table" or type(tv_1.objects) ~= "table"
        if tu_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local tt_2 = 0
        for k, v in tv_1.objects do
            if iN(v) then
                tt_2 += 1
            end
        end
        if tt_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local tv_2 = tt_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(tt_2, tv_2), 6)
    end)
end
nb_3()
SaveManager:LoadAutoloadConfig()
end)(...)

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
getgenv().TempoHoodSubtitle = "MY FARMERS GARDEN"
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
local Bp_9_1
local Bp_5_4
local qA
local qW
local qD
local rk
local pZ
local qk
local q1
local qh
local qn
local p4
local qq
local p7
local qP
local qw
local rd
local qS
local rg
local qg
local Library
local pY
local Toggles
local q3
local qp
local PlayerGui
local qs
local p9
local rf
local qf
local qX
local ri
local pX
local qB
local qE
local q_
local q2
local Options
local qo
local qK
local qu
local rb
local qQ
local qb
local function fn15(ck)
    local ti = {}
    if not ck then
        return ti
    end
    for i, child in ck:GetChildren() do
        local tj_1 = child:IsA("Tool") and child:GetAttribute("IsShopDisplay") == true
        if tj_1 then
            local Handle = child:FindFirstChild("Handle")
            local tk_1 = Handle and Handle:FindFirstChildOfClass("ProximityPrompt")
            if tk_1 then
                local tk_2 = #ti + 1
                local Name = child.Name
                local tn_1 = tonumber(child:GetAttribute("FinalPrice")) or tonumber(child:GetAttribute("Price"))
                local to_1 = tn_1 or 0
                ti[tk_2] = { tool = child, name = Name, price = to_1, prompt = tk_1, handle = Handle }
            end
        end
    end
    for i, descendant in ck:GetDescendants() do
        local tj_3 = descendant:IsA("ProximityPrompt") and descendant.ActionText == "Buy"
        if tj_3 then
            local Parent = descendant.Parent
            local tk_3 = Parent and Parent.Parent
            local tl_2 = tk_3
            if tk_3 then
                tk_3 = tl_2:IsA("Tool")
            end
            if tk_3 then
                local tk_4 = false
                for k, v in ti do
                    if v.tool == tl_2 then
                        tk_4 = true
                        break
                    end
                end
                if not tk_4 then
                    local tk_5 = #ti + 1
                    local Name = tl_2.Name
                    local tn_2 = tonumber(tl_2:GetAttribute("FinalPrice")) or tonumber(tl_2:GetAttribute("Price"))
                    local to_2 = tn_2 or 0
                    ti[tk_5] = { tool = tl_2, name = Name, price = to_2, prompt = descendant, handle = Parent }
                end
            end
        end
    end
    return ti
end
local function fn46()
    local leaderstats = qg:FindFirstChild("leaderstats")
    local sD = leaderstats and leaderstats:FindFirstChild("Sunshine")
    local sC_1 = sD
    if sD then
        sD = sC_1.Value
    end
    return ri(sD)
end
local function fn48()
    local Character = qg.Character
    local sw = Character and Character:FindFirstChild("HumanoidRootPart")
    return sw
end
local function fn73(eA)
    local vf = {}
    if not eA then
        return vf
    end
    local vp = 1
    while vp <= 6 do
        local vr = vp
        local vg = eA:FindFirstChild("Plot" .. vr)
        local vh = vg and vg:FindFirstChild("GardenPlot")
        local vi = vh
        if vh then
            vh = vi:IsA("BasePart")
        end
        if vh then
            vh = vi:GetAttribute("Locked") ~= true
        end
        if vh then
            local vh_1 = false
            for i, descendant in vg:GetDescendants() do
                if descendant:GetAttribute("IsPlantedPlant") == true then
                    vh_1 = true
                    break
                end
            end
            vf[#vf + 1] = { model = vg, part = vi, empty = not vh_1 }
        end
        vp += 1
    end
    return vf
end
local function fn115(bq)
    local sA_1
    if type(bq) == "number" then
        return bq
    end
    local sy = bq or "0"
    local sy_1
    local sz = tostring(sy):gsub("[$%,]", ""):gsub("%s", "")
    sA_1, sy_1 = sz:match("^([%d%.]+)([KkMmBbTt]?)$")
    local sA_2 = tonumber(sA_1)
    if not sA_2 then
        return 0
    end
    local sz_1 = ({
        K = 1000,
        k = 1000,
        M = 1000000,
        m = 1000000,
        B = 1000000000,
        b = 1000000000,
        T = 1000000000000,
        t = 1000000000000
    })[sy_1] or 1
    return math.floor(sA_2 * sz_1)
end
local function fn129()
    local tY = qu("BuySeeds")
    local tZ = qu("BuyEggs")
    local t_ = not next(tY)
    if t_ ~= false then
        t_ = not next(tZ)
    end
    if t_ then
        return false
    end
    local t__1 = qD()
    local t0 = qs()
    local t1
    local t2 = math.huge
    if next(tZ) then
        for k, v in q1() do
            if tZ[v.name] and v.price > 0 and v.price <= t__1 then
                local t3_2 = t0
                local t4 = 0
                if t3_2 then
                    t3_2 = v.handle
                end
                if t3_2 then
                    t4 = (t0.Position - v.handle.Position).Magnitude
                end
                if not t1 or t4 < t2 then
                    t1 = v
                    t2 = t4
                end
            end
        end
    end
    local tZ_1 = not t1
    if tZ_1 ~= false then
        tZ_1 = next(tY)
    end
    if tZ_1 then
        local GameShops = qp:FindFirstChild("GameShops")
        if GameShops then
            for i, child in GameShops:GetChildren() do
                if child.Name:match("^Shop%d+") then
                    for k, v in qA(child) do
                        if tY[v.name] and v.prompt and v.prompt.Enabled and v.price > 0 and v.price <= t__1 then
                            local tZ_4 = t0
                            local t3_4 = 0
                            if tZ_4 then
                                tZ_4 = v.handle
                            end
                            if tZ_4 then
                                t3_4 = (t0.Position - v.handle.Position).Magnitude
                            end
                            if not t1 or t3_4 < t2 then
                                t1 = v
                                t2 = t3_4
                            end
                        end
                    end
                end
            end
        end
    end
    if not t1 then
        return false
    end
    return q_(t1)
end
local function fn153(aQ, aR)
    return string.format('<font color="%s">%s</font>', aR, aQ)
end
local function fn202()
    local uU = rd()
    local uV = uU and uU:FindFirstChild("MoneyStorage")
    local uV_1 = not uV or not uV:IsA("BasePart")
    if uV_1 then
        return false
    end
    local uV_2 = nil
    for i, descendant in uV:GetDescendants() do
        local uW_1 = descendant.Name == "AmountLabel" and descendant:IsA("TextLabel")
        if uW_1 then
            uV_2 = descendant
            break
        end
    end
    local uV_3 = uV_2 and uV_2.Text or "$0"
    if ri(uV_3) <= 0 then
        return false
    end
    return qh(uV)
end
local function fn203()
    local wl = qn()
    local wm = not wl or not wl:IsA("BasePart")
    if wm then
        return false
    end
    local wm_1 = qs()
    local wn = qK()
    local wp = not wm_1 or not wn
    local wp_3, wp_6
    if wp then
        return false
    end
    local SellMode = Options.SellMode
    local wp_2 = SellMode and SellMode.Value or "Selected"
    local wq = wp_2 ~= "Inventory" and wp_2 ~= "Selected"
    local wq_1, wq_3
    if wq then
        wp_2 = "Selected"
    end
    local wo_4 = rk()
    if wp_2 == "Inventory" then
        if #wo_4 == 0 then
            return false
        end
        wm_1.CFrame = wl.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.15)
        wp_3, wq_1 = pcall(function()
            return pZ:InvokeServer("SellInventory")
        end)
        local wr_1 = wp_3 and type(wq_1) == "table" and wq_1.success
        if wr_1 then
            task.wait(0.25)
            return true
        end
        return false
    end
    local wp_4 = qu("SellPlants")
    if not next(wp_4) then
        return false
    end
    local wq_2 = {}
    for k, v in wo_4 do
        if wp_4[p7(v)] then
            wq_2[#wq_2 + 1] = v
        end
    end
    if #wq_2 == 0 then
        return false
    end
    local wo_5 = false
    for k, v in wq_2 do
        local wp_5 = Library.Unloaded or not qX("AutoSell")
        if wp_5 then
            break
        elseif v.Parent then
            wn:EquipTool(v)
            task.wait(0.1)
            wm_1.CFrame = wl.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.08)
            wp_6, wq_3 = pcall(function()
                return pZ:InvokeServer("SellThis")
            end)
            local wr_2 = wp_6 and type(wq_3) == "table" and wq_3.success
            if wr_2 then
                wo_5 = true
                task.wait(0.25)
            end
        end
    end
    return wo_5
end
local function fn220(et)
    return et:GetAttribute("JustPlanted") ~= true
end
local function fn245(a4)
    local sg = Toggles[a4]
    return sg ~= nil and sg.Value == true
end
local function worker2()
    while not Library.Unloaded do
        local zQ = false
        local zR = qX("AutoBuySeedsEggs") and qo()
        if zR then
            zQ = true
        end
        local zR_1 = qX("AutoBuyGears") and q2()
        if zR_1 then
            zQ = true
        end
        local zR_2 = qX("AutoBuyFarmer") and p9()
        if zR_2 then
            zQ = true
        end
        local zR_3 = qX("AutoCollectMoney") and qk()
        if zR_3 then
            zQ = true
        end
        local zR_4 = qX("AutoPlant") and pX()
        if zR_4 then
            zQ = true
        end
        local zR_5 = qX("AutoSell") and rb()
        if zR_5 then
            zQ = true
        end
        local zR_6 = qX("AutoWaterPlants") and qW()
        if zR_6 then
            zQ = true
        end
        local zR_7 = qX("AutoShovelPlants") and qb()
        if zR_7 then
            zQ = true
        end
        local zR_8 = qX("AutoMergePlants") and qf()
        if zR_8 then
            zQ = true
        end
        local zR_9 = qX("AutoSpin") and p4()
        if zR_9 then
            zQ = true
        end
        if qX("HideSpinInterface") then
            qP(true)
        end
        local wait = task.wait
        local zQ_1 = zQ and 0.25 or 0.5
        wait(zQ_1)
    end
end
local function fn254(ic)
    local SpinningWheel = PlayerGui:FindFirstChild("SpinningWheel")
    if not SpinningWheel then
        return
    end
    SpinningWheel.Enabled = true
    local WheelFrame = SpinningWheel:FindFirstChild("WheelFrame")
    local DimBackdrop = SpinningWheel:FindFirstChild("DimBackdrop")
    if ic then
        if WheelFrame then
            WheelFrame.Visible = false
        end
        if DimBackdrop then
            DimBackdrop.Visible = false
        end
    else
        if WheelFrame then
            WheelFrame.Visible = true
        end
        if DimBackdrop then
            DimBackdrop.Visible = true
        end
    end
end
local function fn296(a9)
    local sj = Options[a9]
    local sk = sj and sj.Value
    if type(sk) ~= "table" then
        return {}
    end
    local sk_1 = {}
    for k, v in sk do
        if v == true then
            sk_1[k] = true
        end
    end
    return sk_1
end
local function fn330(cR)
    local tV = qs()
    if tV and cR.handle then
        tV.CFrame = cR.handle.CFrame * CFrame.new(0, 2, 4)
        task.wait(0.1)
    end
    if not qS(cR.prompt) then
        return false
    end
    task.wait(0.45)
    return true
end
local function fn349(aY, aZ)
    if setclipboard then
        setclipboard(aY)
    elseif toclipboard then
        toclipboard(aY)
    end
    Library:Notify(aZ)
end
local function fn420(ev)
    local u7 = {}
    if not ev then
        return u7
    end
    for i, descendant in ev:GetDescendants() do
        if descendant:GetAttribute("IsPlantedPlant") == true then
            u7[#u7 + 1] = descendant
        end
    end
    return u7
end
local function fn434(eL)
    local Size = eL.Size
    return eL.CFrame:PointToWorldSpace(Vector3.new(0, Size.Y * 0.5, 0))
end
local function fn436()
    local Character = qg.Character
    local st = Character and Character:FindFirstChildOfClass("Humanoid")
    return st
end
local function fn473(eq)
    local u5 = not eq or not eq:IsA("Tool")
    if u5 then
        return false
    elseif eq:GetAttribute("PlantID") == nil then
        return false
    else
        return eq:GetAttribute("SizeRolled") ~= true
    end
end
local function fn483()
    local sH_1
    local sG_1
    local PLAYERS_GARDEN = qp:FindFirstChild("PLAYERS GARDEN")
    if not PLAYERS_GARDEN then
        return nil
    end
    sG_1, sH_1 = pcall(function()
        return qw:InvokeServer()
    end)
    local sI = sG_1 and type(sH_1) == "string"
    if sI then
        local sG_2 = PLAYERS_GARDEN:FindFirstChild(sH_1)
        if sG_2 then
            return sG_2
        end
        for i, child in PLAYERS_GARDEN:GetChildren() do
            if child:GetAttribute("OwnerUserId") == qg.UserId then
                return child
            end
            local Plot1 = child:FindFirstChild("Plot1")
            local sG_3 = Plot1 and Plot1:FindFirstChild("GardenPlot")
            local sF_2 = sG_3
            if sG_3 then
                sG_3 = sF_2:GetAttribute("OwnerUserId") == qg.UserId
            end
            if sG_3 then
                return child
            end
        end
        return nil
    end
    for i, child in PLAYERS_GARDEN:GetChildren() do
        if child:GetAttribute("OwnerUserId") == qg.UserId then
            return child
        end
        local Plot1 = child:FindFirstChild("Plot1")
        local sG_4 = Plot1 and Plot1:FindFirstChild("GardenPlot")
        local sF_4 = sG_4
        if sG_4 then
            sG_4 = sF_4:GetAttribute("OwnerUserId") == qg.UserId
        end
        if sG_4 then
            return child
        end
    end
    return nil
end
local function fn509(il)
    local DiscordGroup = il:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = rg })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = rg })
end
local function fn557()
    local tI = {}
    for i, child in qp:GetChildren() do
        local tJ = child:IsA("Tool") and child:GetAttribute("IsEgg") == true and child:GetAttribute("PotName") ~= nil
        if tJ then
            local Handle = child:FindFirstChild("Handle")
            local tK = Handle and Handle:FindFirstChildOfClass("ProximityPrompt")
            local tL = tK
            if tK then
                tK = tL.Enabled
            end
            if tK then
                local tK_1 = ri(tL.ObjectText)
                if tK_1 <= 0 then
                    local tM = tonumber(child:GetAttribute("FinalPrice")) or tonumber(child:GetAttribute("Price"))
                    tK_1 = tM or 0
                end
                tI[#tI + 1] = { tool = child, name = child.Name, price = tK_1, prompt = tL, handle = Handle }
            end
        end
    end
    return tI
end
local function fn628(gZ)
    return tostring(gZ) .. " Star"
end
local function fn706(aT, aU, aV)
    return string.format("<b>%s</b> %s %s", aT, rf("-", "#5a6070"), rf(aU, aV))
end
local function fn720()
    local Stalls = qp:FindFirstChild("Stalls")
    local wj = Stalls and Stalls:FindFirstChild("SellPart")
    return wj
end
local function fn754()
    qq(qB, "Copied Discord invite to clipboard")
end
local function fn826()
    return qE
end
local function fn844(gX)
    local xf = tonumber(gX:GetAttribute("MergeCount")) or 0
    return xf
end
local function fn855(G)
    if cloneref then
        return cloneref(G)
    end
    return G
end
local function worker()
    while Library and not Library.Unloaded do
        qQ()
        task.wait(1)
    end
end
local function fn957(en)
    local u3 = en:GetAttribute("PlantName") or en.Name
    return u3
end
Options = nil
pX = nil
pY = nil
pZ = nil
Toggles = nil
p4 = nil
PlayerGui = nil
p7 = nil
p9 = nil
qb = nil
qf = nil
qg = nil
qh = nil
qk = nil
qn = nil
qo = nil
qp = nil
qq = nil
qs = nil
qu = nil
qw = nil
qA = nil
qB = nil
qD = nil
qE = nil
local pT, pV, pW, p_, p1, p2, p3, p5, p8, qa, SaveManager, qd, qe, qi, qj, ThemeManager, qm, qr, qt, qv, qx, qy, qz, qC, qF
qK = nil
qP = nil
qQ = nil
qS = nil
qW = nil
qX = nil
Library = nil
q_ = nil
q1 = nil
q2 = nil
q3 = nil
local q6
rb = nil
rd = nil
rf = nil
rg = nil
ri = nil
rk = nil
local qG, qH, qI, qJ, qL, qO, qR, qT, qU, qV, qZ, q0, q4, q5, q7, q8, q9, ra, rc, re, rh, rj
qG = nil
qH = nil
qI = nil
qJ = nil
qL = nil
local qM
local qN
qO = nil
qR = nil
qT = nil
qU = nil
qV = nil
qZ = nil
q0 = nil
q4 = nil
q5 = nil
q7 = nil
q8 = nil
q9 = nil
ra = nil
rc = nil
re = nil
rh = nil
rj = nil
pT, Bp_9_1, q4, qZ, qR, qI, qE, qy, qv, qp, qg, PlayerGui, pY = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Bp_2 = 15
repeat
    local Bp_5_1 = (Bp_2 * 1 + 3) % 4 + 1
    if Bp_5_1 <= 2 then
        if Bp_5_1 <= 1 then
            if (Bp_2 * 1 + 6) * 5 % 4 == ((Bp_2 * 1 + 6) * 5 + 15) % 4 then
                qp = game:GetService("CoreGui")
                qv = game:GetService("GuiService")
                qE = game:GetService("TeleportService")
                qy = game:GetService("Workspace")
            else
                qE = game:GetService("CoreGui")
                qy = game:GetService("GuiService")
                qv = game:GetService("TeleportService")
                qp = game:GetService("Workspace")
            end
            Bp_2 = (Bp_2 + 13) % 16
        else
            local CD = bit32.rrotate(bit32.bxor(bit32.lrotate(Bp_2, 12), string.byte(tostring(q4))), 29)
            if bit32.bxor(bit32.lrotate(bit32.bxor(CD, 32393915), 10), 3106597895) == bit32.lrotate(CD, 10) then
                qg = pT.LocalPlayer
                PlayerGui = qg:WaitForChild("PlayerGui")
                pY = fn826
            else
                pT = PlayerGui.LocalPlayer
                pY = pT:WaitForChild("PlayerGui")
                qg = fn826
            end
            Bp_2 = (Bp_2 + 13) % 16
        end
    elseif Bp_5_1 <= 3 then
        local Bp_5_2 = {
            "qmpdudzm",
            "fuubkzyrpki",
            "pxxu",
            "tykqb",
            "ullfqhptxm",
            "nsu",
            "evrrx",
            "niyme",
            "fgoug",
            "bpgsqjcl",
            "buq"
        }
        local Cs = Bp_2
        local ro_1 = Bp_5_2[Cs % 11 + 1]
        if ro_1:len() <= ro_1:gsub("(.)", "%1%1", Cs % 3 % 2 + 1):len() then
            pT = game:GetService("Players")
        else
            qR = game:GetService("Players")
        end
        Bp_2 = (Bp_2 + 1) % 16
    else
        local Bp_5_3 = (vector.create((Bp_2 * 4 + 9) % 11 + 1, (Bp_2 * 2 + 8) % 13 + 1, (Bp_2 * 2 + 11) % 17 + 1))
        local C3 = vector.floor(Bp_5_3) + vector.ceil(Bp_5_3 * -1)
        if vector.dot(C3, C3) == 5 then
            qI = game:GetService("ReplicatedStorage")
            Bp_9_1 = game:GetService("RunService")
            qR = game:GetService("UserInputService")
            q4 = game:GetService("VirtualUser")
            qZ = game:GetService("HttpService")
        else
            Bp_9_1 = game:GetService("ReplicatedStorage")
            q4 = game:GetService("RunService")
            qZ = game:GetService("UserInputService")
            qR = game:GetService("VirtualUser")
            qI = game:GetService("HttpService")
        end
        Bp_2 = (Bp_2 + 5) % 16
    end
until (Bp_2 * 9 + 2) % 16 == 9
if getgenv then
    q6, Bp_5_4 = nil, nil
    local Bp_2_1 = 0
    repeat
        if (Bp_2_1 * 1 + 0) % 2 + 1 <= 1 then
            if (Bp_2_1 or not q6 or (Bp_2_1 or Bp_5_4)) and ((q6 or not q6) and (not Bp_5_4 and Bp_2_1)) and ((not Bp_5_4 or not q6 or not Bp_2_1 and Bp_2_1) and (not q6 and not Bp_5_4 and (Bp_2_1 or q6))) or (Bp_2_1 and Bp_5_4 or not Bp_5_4 and not Bp_5_4 or (not Bp_2_1 and not q6 or (not Bp_5_4 or Bp_2_1))) and ((Bp_2_1 or not q6 or (not Bp_2_1 or Bp_5_4)) and (Bp_2_1 and Bp_2_1 and (q6 or not Bp_5_4))) or not ((Bp_2_1 or not q6 or (Bp_2_1 or Bp_5_4)) and ((q6 or not q6) and (not Bp_5_4 and Bp_2_1)) and ((not Bp_5_4 or not q6 or not Bp_2_1 and Bp_2_1) and (not q6 and not Bp_5_4 and (Bp_2_1 or q6))) or (Bp_2_1 and Bp_5_4 or not Bp_5_4 and not Bp_5_4 or (not Bp_2_1 and not q6 or (not Bp_5_4 or Bp_2_1))) and ((Bp_2_1 or not q6 or (not Bp_2_1 or Bp_5_4)) and (Bp_2_1 and Bp_2_1 and (q6 or not Bp_5_4)))) then
                getgenv().gethui = pY
                q6 = getgenv().__TempoMyFarmersGardenLib
            else
                getgenv().gethui = q6
                pY = getgenv().__TempoMyFarmersGardenLib
            end
            Bp_2_1 = (Bp_2_1 + 13) % 16
        else
            local ro_3 = (vector.create((Bp_2_1 * 1 + 4) % 11 + 1, (Bp_2_1 * 5 + 9) % 13 + 1, (Bp_2_1 * 5 + 2) % 17 + 1))
            local rp_1 = (vector.create((Bp_2_1 * 5 + 4) % 11 + 1, (Bp_2_1 * 3 + 7) % 13 + 1, (Bp_2_1 * 15 + 16) % 17 + 1))
            local rq_1 = (vector.create((Bp_2_1 * 2 + 7) % 11 + 1, (Bp_2_1 * 8 + 9) % 13 + 1, (Bp_2_1 * 5 + 12) % 17 + 1))
            local rr_1 = (vector.create((Bp_2_1 * 4 + 6) % 5 + 1, (Bp_2_1 * 1 + 2) % 7 + 1, (Bp_2_1 * 5 + 2) % 9 + 1))
            if vector.dot(vector.cross(ro_3, (vector.cross(rp_1, rq_1))), rr_1) == vector.dot(rp_1 * vector.dot(ro_3, rq_1) - rq_1 * vector.dot(ro_3, rp_1), rr_1) + 5 then
                q6 = Bp_5_4
            else
                Bp_5_4 = q6
            end
            Bp_2_1 = (Bp_2_1 + 11) % 16
        end
    until (Bp_2_1 * 9 + 6) % 16 == 14
    if Bp_5_4 then
        Bp_5_4 = q6.Unload
    end
    if Bp_5_4 then
        pcall(function()
            q6:Unload()
        end)
    end
end
pcall(function()
    gethui = pY
end)
if setthreadidentity then
    setthreadidentity(8)
end
qH, qB, qx, qt, qm, qd, p1, pV, ra, qT, qJ, qF, qz, qw, qr, qi, p8, pZ, rh, q8, q3 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
qH = "My Farmers Garden"
if not qw or qr or (q8 or false) or (false and not q8 or not qw) or not (not qw or qr or (q8 or false) or (false and not q8 or not qw)) then
    qB = "https://discord.gg/K7Qxnxkk46"
    qx = "https://discord.gg/K7Qxnxkk46"
    qt = "https://tempohub.shop"
    qm = "#7fd47f"
    qd = "#6ec1ff"
else
    qd = "https://discord.gg/K7Qxnxkk46"
    qB = "https://discord.gg/K7Qxnxkk46"
    qx = "https://tempohub.shop"
    qt = "#7fd47f"
    qm = "#6ec1ff"
end
if (not qw or false) and (false and (not pZ and qw)) or not ((not qw or false) and (false and (not pZ and qw))) then
    p1 = "#e8a34d"
else
    qt = "#e8a34d"
end
pV = "#8b93a3"
ra = "#e05a5a"
if ((not qF or qH) and (not qm and qF) or (qF or not qm or (qB or qF))) and (false or qF and not qB or (qF or not qB or not qF and not qm)) or not (((not qF or qH) and (not qm and qF) or (qF or not qm or (qB or qF))) and (false or qF and not qB or (qF or not qB or not qF and not qm))) then
    qT = fn855(Bp_9_1:WaitForChild("GearShopBuyRequest"))
else
    Bp_9_1 = qT(fn855:WaitForChild("GearShopBuyRequest"))
end
qJ = fn855(Bp_9_1:WaitForChild("BuyFarmerRequest"))
qF = fn855(Bp_9_1:WaitForChild("GetGearShopStateRequest"))
qz = fn855(Bp_9_1:WaitForChild("GetFarmerShopStockRequest"))
qw = fn855(Bp_9_1:WaitForChild("GetMyGardenRequest"))
if (not qF or pV or (false or qT) or (qT or not qT) and 10) and (pV and not qF or qT and false or (pV or qT) and (qF or false)) and not ((not qF or pV or (false or qT) or (qT or not qT) and 10) and (pV and not qF or qT and false or (pV or qT) and (qF or false))) then
    p8 = Bp_9_1(fn855:WaitForChild("WateringCanUseRequest"))
    qr = Bp_9_1(fn855:WaitForChild("ShovelUprootRequest"))
    qi = Bp_9_1(fn855:WaitForChild("PlantPlacementRequest"))
else
    qr = fn855(Bp_9_1:WaitForChild("WateringCanUseRequest"))
    qi = fn855(Bp_9_1:WaitForChild("ShovelUprootRequest"))
    p8 = fn855(Bp_9_1:WaitForChild("PlantPlacementRequest"))
end
pZ = fn855(Bp_9_1:WaitForChild("SellRequest"))
rh = fn855(Bp_9_1:WaitForChild("FusionMergeConfirm"))
q8 = fn855(Bp_9_1:WaitForChild("SpinRequest"))
q3 = fn855(Bp_9_1:WaitForChild("AutoSpinToggle"))
local SpinWheelConfig = require(Bp_9_1:WaitForChild("Configs"):WaitForChild("SpinWheelConfig"))
local Bp_2_2 = SpinWheelConfig.SPIN_COST or 100000
qO = nil
qO = Bp_2_2
local rq_2 = { "Selected", "Inventory" }
local InventoryItems = Bp_9_1:WaitForChild("InventoryItems")
local rp_2 = {}
local rr_2 = {}
for i, child in InventoryItems:WaitForChild("Plants"):GetChildren() do
    rr_2[#rr_2 + 1] = child.Name
end
local Bp_2_3 = 2
repeat
    local BT = bit32.rrotate(bit32.bxor(bit32.lrotate(Bp_2_3, 16), string.byte(tostring(Bp_2_3))), 1)
    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(BT, 3405390831), 591392235), (bit32.bxor(bit32.band(BT, 889576464), 1505726205))), 591392235), 1505726205) ~= BT then
        table.sort(rp_2)
        rr_2 = rp_2
    else
        table.sort(rr_2)
        rp_2 = rr_2
    end
    Bp_2_3 = (Bp_2_3 + 6) % 8
until (Bp_2_3 * 7 + 7) % 8 == 7
p3, pW, rc, q5, qV, qG = nil, nil, nil, nil, nil, nil
p3 = {
    Bellsora = true,
    ["Vasal Flower"] = true,
    ["Cotton Bloom"] = true,
    ["Coco Bloom"] = true,
    ["White Sta Rosa"] = true,
    ["Red Sta Rosa"] = true
}
pW = table.clone(p3)
rc = table.clone(p3)
q5 = table.clone(p3)
local rs = { "0 Star", "1 Star", "2 Star", "3 Star", "4 Star", "5 Star" }
qV = {
    ["0 Star"] = true,
    ["1 Star"] = true,
    ["2 Star"] = true,
    ["3 Star"] = true,
    ["4 Star"] = true,
    ["5 Star"] = true
}
qG = {}
local Bp_2_4 = {}
for i, child in InventoryItems:WaitForChild("Eggs"):GetChildren() do
    Bp_2_4[#Bp_2_4 + 1] = child.Name
    qG[child.Name] = true
end
table.sort(Bp_2_4)
qa, p_, rj, q9, Library = nil, nil, nil, nil, nil
local rt = {
    "Watering Can",
    "Basic Sprinkler",
    "Improved Sprinkler",
    "Precision Sprinkler",
    "Hydro Sprinkler",
    "Aqua Watering Can",
    "Reclaimer"
}
qa = { ["Watering Can"] = true, ["Basic Sprinkler"] = true }
p_ = { "Common", "Rare", "Epic", "Legendary", "Mythic", "Angelic", "Secret", "Money" }
rj = { Common = true }
q9 = {}
Library = getgenv().Library
if getgenv then
    getgenv().__TempoMyFarmersGardenLib = Library
end
ThemeManager, SaveManager, Toggles, Options, qe, p5, qQ, rf, qU, qq, rg, qX, qu, qK, qs, ri, qD, rd, qS, qh, qM, qA, q1, q_, qo, q2, p9, qk, p7, q7, qN, qC, p2, qj, rk, pX, qn, rb, qb, qW, re, q0, qL, qf, p4, qP = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
qQ = function()
    local function r3(av)
        local rZ = not av or not av:IsA("ScreenGui")
        if rZ then
            return
        end
        av.ResetOnSpawn = false
        av.IgnoreGuiInset = true
        av.DisplayOrder = math.max(av.DisplayOrder, 1000)
        pcall(function()
            av.ClipToDeviceSafeArea = false
        end)
        pcall(function()
            av.ScreenInsets = Enum.ScreenInsets.None
        end)
        if av.Parent ~= qE then
            av.Parent = qE
        end
    end
    r3(Library.ScreenGui)
    if Library.ActiveLoading and Library.ActiveLoading.ScreenGui then
        r3(Library.ActiveLoading.ScreenGui)
    end
    for i, v in ipairs({ "Obsidian", "ObsidianLoading" }) do
        local r4_1 = qE:FindFirstChild(v) or PlayerGui:FindFirstChild(v)
        if r4_1 then
            r3(r4_1)
        end
    end
end
qQ()
task.spawn(worker)
ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
rf = fn153
qU = fn706
qq = fn349
rg = fn754
qX = fn245
qu = fn296
qK = fn436
qs = fn48
ri = fn115
qD = fn46
rd = fn483
qS = function(bT)
    local sQ = not bT or not bT:IsA("ProximityPrompt") or not bT.Enabled
    if sQ then
        return false
    end
    local HoldDuration = bT.HoldDuration
    bT.HoldDuration = 0
    local sR = pcall(function()
        fireproximityprompt(bT)
    end)
    bT.HoldDuration = HoldDuration
    return sR
end
qh = function(bZ)
    local sW = qs()
    local sX = not sW or not bZ or not bZ:IsA("BasePart")
    if sX then
        return false
    end
    sW.CFrame = bZ.CFrame + Vector3.new(0, 3, 0)
    if firetouchinterest then
        pcall(function()
            firetouchinterest(sW, bZ, 0)
            task.wait()
            firetouchinterest(sW, bZ, 1)
        end)
    end
    return true
end
qM = function(b5)
    local s2 = qK()
    if not s2 then
        return nil
    end
    local function s3(b9)
        if type(b5) == "function" then
            return b5(b9)
        end
        return b9.Name == b5
    end
    local Character = qg.Character
    if Character then
        for i, child in Character:GetChildren() do
            local s4_1 = child:IsA("Tool") and s3(child)
            if s4_1 then
                return child
            end
        end
    end
    for i, child in qg.Backpack:GetChildren() do
        local s4_2 = child:IsA("Tool") and s3(child)
        if s4_2 then
            s2:EquipTool(child)
            return child
        end
    end
    return nil
end
qA = fn15
q1 = fn557
q_ = fn330
qo = fn129
q2 = function()
    local ut_1
    local us_1
    local ur = qu("BuyGears")
    if not next(ur) then
        return false
    end
    us_1, ut_1 = pcall(function()
        return qF:InvokeServer()
    end)
    local uu = not us_1 or type(ut_1) ~= "table"
    if uu then
        return false
    end
    local uu_1 = ut_1.stock or {}
    local uv = ut_1.prices or {}
    local uu_3 = qD()
    local uv_1 = false
    for k in ur do
        local uC = k
        local ur_1 = tonumber(uu_1[uC]) or 0
        local ur_2 = tonumber(uv[uC]) or 0
        if ur_1 > 0 and ur_2 > 0 and uu_3 >= ur_2 then
            local ur_4 = pcall(function()
                qT:FireServer(uC)
            end)
            if ur_4 then
                uv_1 = true
                task.wait(0.25)
                uu_3 = qD()
            end
        end
    end
    return uv_1
end
p9 = function()
    local uF_1
    local uE_1
    local uD = qu("BuyFarmers")
    if not next(uD) then
        return false
    end
    uE_1, uF_1 = pcall(function()
        return qz:InvokeServer()
    end)
    local uG = not uE_1
    local uN = if uG then 1 else 0
    local uL = 3393 * uN + 1514 * (1 - uN)
    local uM = 2371 * uN + 709 * (1 - uN)
    if not ((uL * 266 + uM * 3715 + uL * uM) % 16777213 == 978393) then
        uG = type(uF_1) ~= "table"
    end
    if uG then
        return false
    end
    local uE_2 = qD()
    local uG_1 = false
    for k, v in p_ do
        local uT = v
        if uD[uT] then
            local uH = uF_1[uT]
            local uH_2
            if type(uH) == "table" then
                local uI = tonumber(uH.stock) or 0
                local uI_3
                local uI_1 = tonumber(uH.price) or 0
                if uI > 0 and uI_1 > 0 and uE_2 >= uI_1 then
                    uI_3, uH_2 = pcall(function()
                        return qJ:InvokeServer(uT)
                    end)
                    local uJ_1 = uI_3 and type(uH_2) == "table" and uH_2.success
                    if uJ_1 then
                        uG_1 = true
                        task.wait(0.3)
                        uE_2 = qD()
                    elseif uI_3 then
                        task.wait(0.15)
                    end
                end
            end
        end
    end
    return uG_1
end
qk = fn202
p7 = fn957
q7 = fn473
qN = fn220
qC = fn420
p2 = fn73
qj = fn434
rk = function()
    local vA
    vA = nil
    vA = {}
    local function vB(eQ)
        local vy = eQ:IsA("Tool") and eQ:GetAttribute("PlantID")
        if vy then
            vA[#vA + 1] = eQ
        end
    end
    for i, child in qg.Backpack:GetChildren() do
        vB(child)
    end
    local Character = qg.Character
    if Character then
        for i, child in Character:GetChildren() do
            vB(child)
        end
    end
    return vA
end
pX = function()
    local vU = qu("PlantPlants")
    if not next(vU) then
        return false
    end
    local vV = qX("PlantIgnoreIfNotSeed")
    local vW = rd()
    local vX = p2(vW)
    local vW_1 = {}
    for k, v in vX do
        if v.empty then
            vW_1[#vW_1 + 1] = v
        end
    end
    if #vW_1 == 0 then
        return false
    end
    local vX_1 = qK()
    local vY = qs()
    if not vX_1 or not vY then
        return false
    end
    local vZ_1 = 1
    local v__1 = false
    for k, v in rk() do
        local vT
        local v0 = Library.Unloaded or not qX("AutoPlant")
        if v0 then
            break
        elseif vZ_1 > #vW_1 then
            break
        else
            local v0_1 = vU[p7(v)]
            if v0_1 then
                local v1_1 = not vV or q7(v)
                v0_1 = v1_1
            end
            if v0_1 then
                local v0_2 = vW_1[vZ_1]
                vZ_1 += 1
                vX_1:EquipTool(v)
                task.wait(0.1)
                vT = qj(v0_2.part)
                vY.CFrame = CFrame.new(vT + Vector3.new(0, 4, 0))
                task.wait(0.08)
                local v1_2 = pcall(function()
                    p8:FireServer(vT)
                end)
                if v1_2 then
                    v__1 = true
                    v0_2.empty = false
                    task.wait(0.35)
                end
            end
        end
    end
    return v__1
end
if ((not ThemeManager or qS or not Options and not Toggles) and ((false or Toggles) and (rk or Options)) and ((qS and Options or (not ri or not ri)) and (not Options and false or not Options and Options)) or ((not Options or not Options) and (Toggles or not Toggles) and ((not ThemeManager or qS) and (not Options or Options)) or ((false or qS) and (ri and rk) or (not Options or ThemeManager or not ri and false)))) and not ((not ThemeManager or qS or not Options and not Toggles) and ((false or Toggles) and (rk or Options)) and ((qS and Options or (not ri or not ri)) and (not Options and false or not Options and Options)) or ((not Options or not Options) and (Toggles or not Toggles) and ((not ThemeManager or qS) and (not Options or Options)) or ((false or qS) and (ri and rk) or (not Options or ThemeManager or not ri and false)))) then
    rb = fn720
    qn = fn203
    qW = function()
        local wI = qu("ShovelPlants")
        if not next(wI) then
            return false
        end
        local wJ = qX("ShovelIgnoreFullyGrown")
        local wK = rd()
        local wL = qC(wK)
        if #wL == 0 then
            return false
        end
        local wK_3 = {}
        for k, v in wL do
            local wL_3 = wI[p7(v)]
            if wL_3 then
                local wM = wJ and qN(v)
                wL_3 = not wM
            end
            if wL_3 then
                wK_3[#wK_3 + 1] = v
            end
        end
        if #wK_3 == 0 then
            return false
        end
        qM("Shovel")
        local wI_2 = false
        for k, v in wK_3 do
            local w1 = v
            local wJ_5 = Library.Unloaded or not qX("AutoShovelPlants")
            if wJ_5 then
                break
            elseif w1.Parent then
                local wJ_6 = w1:FindFirstChild("Handle") or w1:FindFirstChildWhichIsA("BasePart", true)
                local wJ_7 = qs()
                if wJ_7 and wJ_6 then
                    wJ_7.CFrame = wJ_6.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.05)
                end
                local wJ_8 = pcall(function()
                    qi:FireServer(w1)
                end)
                if wJ_8 then
                    wI_2 = true
                    task.wait(0.2)
                end
            end
        end
        return wI_2
    end
    re = function()
        local w4 = rd()
        local w5 = qC(w4)
        if #w5 == 0 then
            return false
        elseif not qM(function(gG)
            return gG.Name == "Watering Can" or gG.Name == "Aqua Watering Can"
        end) then
            return false
        else
            local w4_2 = false
            for k, v in w5 do
                local xe = v
                local w5_5 = Library.Unloaded or not qX("AutoWaterPlants")
                if w5_5 then
                    break
                else
                    local w5_6 = xe:FindFirstChild("Handle") or xe:FindFirstChildWhichIsA("BasePart", true)
                    local w5_7 = qs()
                    if w5_7 and w5_6 then
                        w5_7.CFrame = w5_6.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.05)
                    end
                    local w5_8 = pcall(function()
                        qr:FireServer(xe)
                    end)
                    if w5_8 then
                        w4_2 = true
                        task.wait(0.15)
                    end
                end
            end
            return w4_2
        end
    end
    qb = fn844
else
    qn = fn720
    rb = fn203
    qb = function()
        local wI = qu("ShovelPlants")
        if not next(wI) then
            return false
        end
        local wJ = qX("ShovelIgnoreFullyGrown")
        local wK = rd()
        local wL = qC(wK)
        if #wL == 0 then
            return false
        end
        local wK_1 = {}
        for k, v in wL do
            local wL_1 = wI[p7(v)]
            if wL_1 then
                local wM = wJ and qN(v)
                wL_1 = not wM
            end
            if wL_1 then
                wK_1[#wK_1 + 1] = v
            end
        end
        if #wK_1 == 0 then
            return false
        end
        qM("Shovel")
        local wI_1 = false
        for k, v in wK_1 do
            local w1 = v
            local wJ_1 = Library.Unloaded or not qX("AutoShovelPlants")
            if wJ_1 then
                break
            elseif w1.Parent then
                local wJ_2 = w1:FindFirstChild("Handle") or w1:FindFirstChildWhichIsA("BasePart", true)
                local wJ_3 = qs()
                if wJ_3 and wJ_2 then
                    wJ_3.CFrame = wJ_2.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.05)
                end
                local wJ_4 = pcall(function()
                    qi:FireServer(w1)
                end)
                if wJ_4 then
                    wI_1 = true
                    task.wait(0.2)
                end
            end
        end
        return wI_1
    end
    qW = function()
        local w4 = rd()
        local w5 = qC(w4)
        if #w5 == 0 then
            return false
        elseif not qM(function(gG)
            return gG.Name == "Watering Can" or gG.Name == "Aqua Watering Can"
        end) then
            return false
        else
            local w4_1 = false
            for k, v in w5 do
                local xe = v
                local w5_1 = Library.Unloaded or not qX("AutoWaterPlants")
                if w5_1 then
                    break
                else
                    local w5_2 = xe:FindFirstChild("Handle") or xe:FindFirstChildWhichIsA("BasePart", true)
                    local w5_3 = qs()
                    if w5_3 and w5_2 then
                        w5_3.CFrame = w5_2.CFrame + Vector3.new(0, 3, 0)
                        task.wait(0.05)
                    end
                    local w5_4 = pcall(function()
                        qr:FireServer(xe)
                    end)
                    if w5_4 then
                        w4_1 = true
                        task.wait(0.15)
                    end
                end
            end
            return w4_1
        end
    end
    re = fn844
end
q0 = fn628
qL = function()
    local xm
    xm = {}
    local function xn(g2)
        if not g2:IsA("Tool") then
            return
        end
        if not g2:GetAttribute("PlantID") then
            return
        end
        if g2:GetAttribute("MergeCount") == nil then
            return
        end
        if g2:GetAttribute("IsEgg") == true then
            return
        end
        local xh = g2:GetAttribute("PlantName") or g2.Name
        local xh_1 = re(g2)
        local xj = xh .. "\x00" .. xh_1
        local xk = xm[xj]
        if not xk then
            xk = { name = xh, stars = xh_1, tools = {} }
            xm[xj] = xk
        end
        xk.tools[#xk.tools + 1] = g2
    end
    for i, child in qg.Backpack:GetChildren() do
        xn(child)
    end
    local Character = qg.Character
    if Character then
        for i, child in Character:GetChildren() do
            xn(child)
        end
    end
    return xm
end
qf = function()
    local xD = qu("MergeStars")
    if not next(xD) then
        return false
    end
    local FusionMachine = qp:FindFirstChild("FusionMachine")
    if not FusionMachine then
        return false
    end
    local Plant1 = FusionMachine:FindFirstChild("Plant1")
    local Plant2 = FusionMachine:FindFirstChild("Plant2")
    local Merge = FusionMachine:FindFirstChild("Merge")
    if not (Plant1 and Plant2 and Merge) then
        return false
    end
    local xE_2 = qL()
    local xI_1 = nil
    local name
    local stars
    for k, v in xE_2 do
        local xE_3 = xD[q0(v.stars)] and #v.tools >= 2
        if xE_3 then
            xI_1 = { v.tools[1], v.tools[2] }
            name = v.name
            stars = v.stars
            break
        end
    end
    if not xI_1 then
        return false
    end
    local xD_1 = qs()
    local xE_4 = qK()
    if not xD_1 or not xE_4 then
        return false
    end
    xE_4:EquipTool(xI_1[1])
    xD_1.CFrame = Plant1.CFrame + Vector3.new(0, 3, 0)
    task.wait(0.1)
    qS(Plant1:FindFirstChildOfClass("ProximityPrompt"))
    task.wait(0.45)
    local xF_1 = xI_1[2]
    if not xF_1.Parent then
        for k, v in qL() do
            if v.name == name and v.stars == stars and #v.tools >= 1 then
                xF_1 = v.tools[1]
                break
            end
        end
    end
    if not xF_1 or not xF_1.Parent then
        return true
    end
    xE_4:EquipTool(xF_1)
    xD_1.CFrame = Plant2.CFrame + Vector3.new(0, 3, 0)
    task.wait(0.1)
    qS(Plant2:FindFirstChildOfClass("ProximityPrompt"))
    task.wait(0.45)
    pcall(function()
        rh:FireServer(true)
    end)
    task.wait(0.1)
    pcall(function()
        rh:FireServer()
    end)
    xD_1.CFrame = Merge.CFrame + Vector3.new(0, 3, 0)
    qS(Merge:FindFirstChildOfClass("ProximityPrompt"))
    local Fusion = PlayerGui:FindFirstChild("Fusion")
    local xE_5 = Fusion and Fusion:FindFirstChild("ProceedButton", true)
    local xD_3 = xE_5
    if xE_5 then
        xE_5 = getconnections
    end
    if xE_5 then
        for k, v in getconnections(xD_3.MouseButton1Click) do
            local x5 = v
            pcall(function()
                if x5.Function then
                    x5.Function()
                end
            end)
        end
    end
    task.wait(0.4)
    return true
end
qe = false
p4 = function()
    local x7
    local x8
    local connection
    if qe then
        return false
    elseif qD() < qO then
        return false
    else
        qe = true
        x7 = false
        x8 = false
        connection = nil
        connection = q8.OnClientEvent:Connect(function(h1)
            x8 = true
            x7 = h1 == "NoFunds"
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end)
        local ya = pcall(function()
            q8:FireServer()
        end)
        if not ya then
            if connection then
                connection:Disconnect()
            end
            qe = false
            return false
        end
        local ya_1 = os.clock() + 12
        while true do
            local yb = not x8 and os.clock() < ya_1 and not Library.Unloaded and qX("AutoSpin")
            if yb then
                task.wait(0.1)
                continue
            end
            break
        end
        if connection then
            connection:Disconnect()
        end
        qe = false
        if not x8 or x7 then
            return false
        end
        task.wait(2.5)
        return true
    end
end
qP = fn254
local Bp_2_5 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = qB, Copyable = true }, "|", qH },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
p5 = {
    Info = Bp_2_5:AddTab("Info", "info"),
    Main = Bp_2_5:AddTab("Main", "sprout"),
    Player = Bp_2_5:AddTab("Player", "person-standing"),
    Settings = Bp_2_5:AddTab("Settings", "settings")
}
for k, v in p5 do
    if k ~= "Info" then
        fn509(v)
    end
end
local ShopGroup = p5.Main:AddLeftGroupbox("Shop", "store")
ShopGroup:AddToggle("AutoBuySeedsEggs", { Text = "Auto Buy Seeds & Eggs", Default = false })
ShopGroup:AddDropdown("BuySeeds", { Text = "Seeds", Values = rp_2, Default = p3, Multi = true, Expandable = true, ExpandColumns = 2 })
ShopGroup:AddDropdown("BuyEggs", { Text = "Eggs", Values = Bp_2_4, Default = qG, Multi = true })
ShopGroup:AddDivider("Gear")
ShopGroup:AddToggle("AutoBuyGears", { Text = "Auto Buy Gears", Default = false })
ShopGroup:AddDropdown("BuyGears", { Text = "Gears", Values = rt, Default = qa, Multi = true })
ShopGroup:AddDivider("Farmers")
ShopGroup:AddToggle("AutoBuyFarmer", { Text = "Auto Buy Farmer", Default = false })
ShopGroup:AddDropdown("BuyFarmers", { Text = "Farmers", Values = p_, Default = rj, Multi = true })
local Bp_9_2 = p5.Main:AddRightGroupbox("Garden", "flower")
Bp_9_2:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
Bp_9_2:AddDivider("Plant")
Bp_9_2:AddToggle("AutoPlant", { Text = "Auto Plant", Default = false })
Bp_9_2:AddToggle("PlantIgnoreIfNotSeed", { Text = "Ignore If Not Seed", Default = true })
Bp_9_2:AddDropdown("PlantPlants", { Text = "Plants", Values = rp_2, Default = pW, Multi = true, Expandable = true, ExpandColumns = 2 })
Bp_9_2:AddDivider("Sell")
Bp_9_2:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
Bp_9_2:AddDropdown("SellMode", { Text = "Mode", Values = rq_2, Default = "Selected" })
Bp_9_2:AddDropdown("SellPlants", { Text = "Plants", Values = rp_2, Default = rc, Multi = true, Expandable = true, ExpandColumns = 2 })
Bp_9_2:AddDivider("Shovel")
Bp_9_2:AddToggle("AutoShovelPlants", { Text = "Auto Shovel Plants", Default = false })
Bp_9_2:AddToggle("ShovelIgnoreFullyGrown", { Text = "Ignore Fully Grown", Default = true })
Bp_9_2:AddDropdown("ShovelPlants", { Text = "Plants", Values = rp_2, Default = q5, Multi = true, Expandable = true, ExpandColumns = 2 })
Bp_9_2:AddDivider("Merge")
Bp_9_2:AddToggle("AutoMergePlants", { Text = "Auto Merge Plants", Default = false })
Bp_9_2:AddDropdown("MergeStars", { Text = "Stars", Values = rs, Default = qV, Multi = true })
Bp_9_2:AddToggle("AutoWaterPlants", { Text = "Auto Water Plants", Default = false })
local Bp_2_6 = p5.Main:AddRightGroupbox("Spin", "rotate-cw")
if Bp_9_2 or Bp_2_6 or Bp_9_2 and 28 or (Bp_9_2 or (ShopGroup or Bp_9_2)) or (not Bp_9_2) and (not Bp_2_6 and false) and ((not Bp_2_6 or Bp_2_6) and ShopGroup) or not (Bp_9_2 or Bp_2_6 or Bp_9_2 and 28 or (Bp_9_2 or (ShopGroup or Bp_9_2)) or (not Bp_9_2) and (not Bp_2_6 and false) and ((not Bp_2_6 or Bp_2_6) and ShopGroup)) then
    Bp_2_6:AddToggle("AutoSpin", { Text = "Auto Spin", Default = false })
    Bp_2_6:AddToggle("HideSpinInterface", { Text = "Hide Spin Interface", Default = false })
else
    Bp_2_6:AddToggle("AutoSpin", { Text = "Auto Spin", Default = false })
    Bp_2_6:AddToggle("HideSpinInterface", { Text = "Hide Spin Interface", Default = false })
end
local function ro_7()
    local y0
    local y_
    y_ = nil
    y0 = nil
    local Label, Label2, Label3, y4, y5
    local function y6()
        local yh = hookfunction ~= nil
        local yi = hookmetamethod ~= nil
        local yj = getrawmetatable ~= nil
        local yk = setrawmetatable ~= nil
        local yl = getgc ~= nil
        local ym = getgenv ~= nil
        local yn = getreg ~= nil
        local yo = getconnections ~= nil
        local yp = firesignal ~= nil
        local yq = getcallbackvalue ~= nil
        local yr = setclipboard ~= nil
        local ys = getcustomasset ~= nil
        local yt = getnamecallmethod ~= nil
        local yu = isexecutorclosure ~= nil
        local yv = fireproximityprompt ~= nil
        local yw = firetouchinterest ~= nil
        local yx = WebSocket ~= nil
        local yy = readfile ~= nil
        local yz = writefile ~= nil
        local yB = (request or http_request) ~= nil
        local yD = (debug and debug.getupvalues) ~= nil
        local yF = (debug and debug.setupvalue) ~= nil
        local yG = 0
        local yH = { yh, yi, yj, yk, yl, ym, yn, yo, yp, yq, yr, ys, yt, yu, yv, yw, yx, yy, yz, yB, yD, yF }
        for i, v in ipairs(yH) do
            if v then
                yG += 1
            end
        end
        local yh_1 = yG / #yH
        if yh_1 >= 0.9 then
            return rf("Full Support", qm)
        elseif yh_1 >= 0.6 then
            return rf("Half Support", p1)
        else
            return rf("Low Support", ra)
        end
    end
    y_ = "Unknown"
    pcall(function()
        local yQ_1
        local yP_1
        if identifyexecutor then
            yQ_1, yP_1 = identifyexecutor()
            local yR = yQ_1 ~= ""
            local yS = type(yQ_1) == "string" and yR
            if yS then
                local yR_1 = type(yP_1) == "string" and yP_1 ~= "" and yQ_1 .. " " .. yP_1
                y_ = yR_1 or yQ_1
            end
        end
    end)
    local y7 = y6()
    y0 = os.clock()
    y4 = function()
        local yU = math.floor(os.clock() - y0)
        if yU < 60 then
            return yU .. "s"
        elseif yU < 3600 then
            return string.format("%dm %ds", math.floor((yU) / (60)), yU % 60)
        else
            return string.format("%dh %dm", math.floor((yU) / (3600)), math.floor((yU % 3600) / (60)))
        end
    end
    local UserGroup = p5.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = qg, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(qU("User", qg.DisplayName .. " @" .. qg.Name, qm), true)
    UserGroup:AddLabel(qU("UserId", tostring(qg.UserId), qd), true)
    UserGroup:AddLabel(qU("Executor", y_ .. "  " .. y7, qm), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(qU("Session", y4(), p1), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            qq(qg.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            qq("https://www.roblox.com/users/" .. tostring(qg.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = p5.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(qU("Game", qH, qd), true)
    Label2 = SessionGroup:AddLabel(qU("Players", "0/0", qm), true)
    y5 = tostring(game.JobId)
    local y7_1 = #y5 > 18 and string.sub(y5, 1, 18) .. "..."
    local y7_2 = y7_1 or y5
    SessionGroup:AddLabel(qU("Job", y7_2, pV), true)
    Label = SessionGroup:AddLabel(qU("Ping", "0 ms", p1), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            qv:Teleport(game.PlaceId, qg)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            qq(y5, "Copied Job ID")
        end
    })
    task.spawn(function()
        local yX_1
        local yW_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(qU("Session", y4(), p1))
            Label2:SetText(qU("Players", #pT:GetPlayers() .. "/" .. tostring(pT.MaxPlayers), qm))
            yW_1, yX_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local yW_2 = yW_1 and yX_1 .. " ms" or "n/a"
            Label:SetText(qU("Ping", yW_2, p1))
        end
    end)
    local SocialsGroup = p5.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = rg })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            qq(qx, "Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            qq(qt, "Copied website link")
        end
    })
end
local function rw()
    local MovementGroup = p5.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = p5.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local CurrentCamera = qp.CurrentCamera
    local connection
    local function jM(jN)
        pcall(function()
            qy:SetGameplayPausedNotificationEnabled(not jN)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = qE:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not jN
            end
        end)
        if not jN then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(qg, "GameplayPaused", false)
            else
                qg.GameplayPaused = false
            end
        end)
    end
    local function j_(j0)
        if not j0:IsA("ProximityPrompt") then
            return
        end
        j0.HoldDuration = 0
        j0.MaxActivationDistance = 50
        j0.RequiresLineOfSight = false
    end
    q4.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if qX("NoClip") then
            local Character = qg.Character
            if Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    local zi_1 = descendant:IsA("BasePart") and descendant.CanCollide
                    if zi_1 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    qZ.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if qX("InfJump") then
            local zq = qK()
            if zq then
                zq:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    q4.RenderStepped:Connect(function(kh)
        if Library.Unloaded then
            return
        end
        if qX("WalkSpeedEnabled") then
            local zv_1 = qK()
            if zv_1 then
                zv_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if qX("Fly") then
            local zv_2 = qs()
            local zw = qK()
            if zv_2 and zw then
                zw.PlatformStand = true
                local zw_1 = Vector3.zero
                if qZ:IsKeyDown(Enum.KeyCode.W) then
                    zw_1 += CurrentCamera.CFrame.LookVector
                end
                if qZ:IsKeyDown(Enum.KeyCode.S) then
                    zw_1 -= CurrentCamera.CFrame.LookVector
                end
                if qZ:IsKeyDown(Enum.KeyCode.A) then
                    zw_1 -= CurrentCamera.CFrame.RightVector
                end
                local zB = if qZ:IsKeyDown(Enum.KeyCode.D) then 1 else 0
                if zB == 1 then
                    zw_1 += CurrentCamera.CFrame.RightVector
                end
                if qZ:IsKeyDown(Enum.KeyCode.Space) then
                    zw_1 += Vector3.new(0, 1, 0)
                end
                if qZ:IsKeyDown(Enum.KeyCode.LeftControl) then
                    zw_1 -= Vector3.new(0, 1, 0)
                end
                zv_2.Velocity = Vector3.zero
                if zw_1.Magnitude > 0 then
                    zv_2.CFrame = zv_2.CFrame + zw_1.Unit * Options.FlySpeed.Value * kh
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local zC = qK()
            if zC then
                zC.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local zE = qK()
            if zE then
                zE.WalkSpeed = 16
            end
        end
    end)
    Toggles.AntiGameplayPause:OnChanged(function()
        jM(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                jM(true)
            end
        end
    end)
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in ipairs(qp:GetDescendants()) do
                pcall(j_, descendant)
            end
            connection = qp.DescendantAdded:Connect(function(kO)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(j_, kO)
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    Library:OnUnload(function()
        jM(false)
        if connection then
            connection:Disconnect()
        end
    end)
end
ro_7()
rw()
if Toggles.AutoSpin then
    Toggles.AutoSpin:OnChanged(function()
        pcall(function()
            q3:FireServer(false)
        end)
    end)
end
if Toggles.HideSpinInterface then
    Toggles.HideSpinInterface:OnChanged(function()
        qP(Toggles.HideSpinInterface.Value == true)
    end)
end
task.spawn(worker2)
local function Bp_2_7()
    local A8, A9, Ba, Bb, Bc, Bd, Be, connection, Label
    local MenuGroup = p5.Settings:AddLeftGroupbox("Menu")
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    A9 = 0
    Bd = tick()
    Label = nil
    Ba = function()
        local CurrentCamera = qp.CurrentCamera
        if not CurrentCamera then
            return
        end
        qR:CaptureController()
        qR:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        A9 += 1
        Bd = tick()
        if Label then
            pcall(function()
                Label:SetText("AFK triggers: " .. A9)
            end)
        end
    end
    connection = qg.Idled:Connect(function()
        if qX("AntiAfk") then
            pcall(Ba)
        end
    end)
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    Label = MenuGroup:AddLabel("AFK triggers: 0")
    MenuGroup:AddButton({
        Text = "Unload UI",
        Func = function()
            Library:Unload()
        end
    })
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local zX = qX("AntiAfk") and tick() - Bd >= 60
            if zX then
                pcall(Ba)
            end
        end
    end)
    Library:OnUnload(function()
        if connection then
            connection:Disconnect()
        end
        pcall(function()
            q3:FireServer(false)
        end)
        qP(false)
        for k, v in q9 do
            local z4 = v
            pcall(function()
                z4:Disconnect()
            end)
        end
        table.clear(q9)
        if getgenv then
            getgenv().__TempoMyFarmersGardenLib = nil
        end
    end)
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("TempoHub")
    ThemeManager:SaveDefault("Evil Hello Kitty")
    ThemeManager:ApplyToTab(p5.Settings)
    ThemeManager:LoadDefault()
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    SaveManager:SetFolder("TempoHub/MyFarmersGarden")
    local Bh_1 = SaveManager:BuildConfigSection(p5.Settings)
    Bc = function(lU, lV)
        local z6_1 = (lU == "Toggle" and Toggles or Options)[lV]
        local z5_2 = type(z6_1) == "table" and z6_1.Type == lU
        return z5_2 and z6_1 or nil
    end
    Be = function(l2, l3)
        local Type = l3.Type
        if Type == "Toggle" then
            return { idx = l2, type = "Toggle", value = l3.Value == true }
        elseif Type == "Slider" then
            return { idx = l2, type = "Slider", value = tostring(l3.Value) }
        elseif Type == "Dropdown" then
            return { idx = l2, type = "Dropdown", multi = l3.Multi == true, value = l3.Value }
        elseif Type == "Input" then
            local Ag = l3.Value or ""
            return { idx = l2, type = "Input", text = tostring(Ag) }
        elseif Type == "ColorPicker" then
            return { idx = l2, type = "ColorPicker", value = l3.Value:ToHex(), transparency = l3.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = l2,
                type = "KeyPicker",
                mode = l3.Mode,
                key = l3.Value,
                modifiers = l3.Modifiers,
                toggled = l3.Toggled
            }
        else
            return nil
        end
    end
    A8 = function()
        local Aj = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local Ak = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if Ak then
                    local Ak_1 = Be(k, v)
                    if Ak_1 then
                        Aj[#Aj + 1] = Ak_1
                    end
                end
            end
        end
        table.sort(Aj, function(mf, mg)
            if mf.type ~= mg.type then
                return mf.type < mg.type
            end
            return mf.idx < mg.idx
        end)
        return { objects = Aj }
    end
    Bb = function(mi)
        local AD
        AD = nil
        local AE = type(mi) ~= "table" or type(mi.idx) ~= "string" or type(mi.type) ~= "string"
        local AI = if AE then 1 else 0
        local AG = 2476 * AI + 3639 * (1 - AI)
        local AH = 1436 * AI + 843 * (1 - AI)
        if not ((AG * 3676 + AH * 2281 + AG * AH) % 16777213 == 15932828) then
            AE = SaveManager.Ignore[mi.idx]
        end
        if AE then
            return false
        end
        AD = Bc(mi.type, mi.idx)
        if not AD then
            return false
        end
        local AE_1 = pcall(function()
            if mi.type == "Input" then
                if type(mi.text) ~= "string" then
                    return
                end
                AD:SetValue(mi.text)
            elseif mi.type == "ColorPicker" then
                AD:SetValueRGB(Color3.fromHex(mi.value), mi.transparency)
            elseif mi.type == "KeyPicker" then
                AD:SetValue({ mi.key, mi.mode, mi.modifiers })
                if mi.mode == "Toggle" and mi.toggled ~= nil then
                    AD.Toggled = mi.toggled
                    AD:Update()
                end
            else
                AD:SetValue(mi.value)
            end
        end)
        return AE_1
    end
    Bh_1:AddDivider()
    Bh_1:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    Bh_1:AddButton({
        Text = "Export Config to Clipboard",
        Func = function()
            local AK_1
            local AJ_1
            AJ_1, AK_1 = pcall(qI.JSONEncode, qI, A8())
            if not AJ_1 then
                Library:Notify("Failed to encode the config")
                return
            end
            local AJ_2 = setclipboard or toclipboard
            local AJ_3 = type(AJ_2) ~= "function"
            local AP = if AJ_3 then 1 else 0
            local AN = 3891 * AP + 240 * (1 - AP)
            local AO = 2909 * AP + 1316 * (1 - AP)
            if not ((AN * 135 + AO * 79 + AN * AO) % 16777213 == 12074015) then
                AJ_3 = not pcall(AJ_2, AK_1)
            end
            if AJ_3 then
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Config copied to clipboard", 6)
        end
    })
    Bh_1:AddButton({
        Text = "Import Config from Clipboard Text",
        Func = function()
            local AS_1
            local AQ = Options.SaveManager_ImportSource.Value or ""
            local AQ_1
            local AR = tostring(AQ):match("^%s*(.-)%s*$")
            if AR == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            AQ_1, AS_1 = pcall(qI.JSONDecode, qI, AR)
            local AR_1 = not AQ_1 or type(AS_1) ~= "table" or type(AS_1.objects) ~= "table"
            if AR_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            local AQ_2 = 0
            for i, v in ipairs(AS_1.objects) do
                if Bb(v) then
                    AQ_2 += 1
                end
            end
            if AQ_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local AS_2 = AQ_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(AQ_2, AS_2), 6)
        end
    })
    SaveManager:LoadAutoloadConfig()
    local function Bh_2(mM)
        local A_ = Options[mM]
        local A__1 = A_ and A_.Value
        if type(A__1) ~= "table" then
            return true
        end
        for k, v in A__1 do
            if v == true then
                return false
            end
        end
        return true
    end
    local Bi = Bh_2("BuySeeds") and Options.BuySeeds
    if Bi then
        Options.BuySeeds:SetValue(p3)
    end
    local Bi_1 = Bh_2("BuyEggs") and Options.BuyEggs
    if Bi_1 then
        Options.BuyEggs:SetValue(qG)
    end
    local Bi_2 = Bh_2("BuyGears") and Options.BuyGears
    if Bi_2 then
        Options.BuyGears:SetValue(qa)
    end
    local Bi_3 = Bh_2("BuyFarmers") and Options.BuyFarmers
    if Bi_3 then
        Options.BuyFarmers:SetValue(rj)
    end
    local Bi_4 = Bh_2("PlantPlants") and Options.PlantPlants
    if Bi_4 then
        Options.PlantPlants:SetValue(pW)
    end
    local Bi_5 = Bh_2("SellPlants") and Options.SellPlants
    if Bi_5 then
        Options.SellPlants:SetValue(rc)
    end
    local Bi_6 = Bh_2("ShovelPlants") and Options.ShovelPlants
    if Bi_6 then
        Options.ShovelPlants:SetValue(q5)
    end
    local Bi_7 = Bh_2("MergeStars") and Options.MergeStars
    if Bi_7 then
        Options.MergeStars:SetValue(qV)
    end
end
Bp_2_7()
end)(...)

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
getgenv().TempoHoodSubtitle = "BACKROOMS SIMULATOR"
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
local E8_3, E8_7, E8_12, E8_16, E8_18, E8_20, E8_24, E8_29, E8_34, E8_40, E8_42
local un
local tn
local tM
local tt
local folder
local tg
local tY
local GetAutoSell
local tm
local t3
local s3
local tL
local us
local sL
local Pets
local Drops
local tE
local tl
local t2
local s8
local tQ
local GetAutoSellDrops
local ue
local tW
local tD
local s1
local tq
local s7
local Doors
local sP
local ud
local td
local sV
local Options
local tj
local s0
local PlayerGui
local Toggles
local Weapons2
local t6
local s6
local uv
local TeleportPoints
local tU
local GetAutoSellWeapon
local Races
local t_
local s_
local tH
local uo
local sH
local AttackEvent
local s5
local tN
local sN
local tb
local tT
local tZ
function fns.fn1()
    local At = sL("UpgradeMode", "All")
    if At == "Pets" or At == "All" then
        t6()
    end
    if At == "Weapons" or At == "All" then
        us()
    end
    if At == "Perks" or At == "All" then
        s_()
    end
end
function fns.fn21(cW)
    local wT = tn()
    local wU = cW and cW:FindFirstChild("HumanoidRootPart")
    local wU_3
    if not wT or not wU then
        return false
    end
    local wU_2 = wT.Position - wU.Position
    if wU_2.Magnitude < 0.1 then
        wU_3 = Vector3.new(0, 0, 4)
    else
        wU_3 = Vector3.new(wU_2.X, 0, wU_2.Z).Unit * 4
    end
    wT.AssemblyLinearVelocity = Vector3.zero
    wT.AssemblyAngularVelocity = Vector3.zero
    wT.CFrame = CFrame.new(wU.Position + wU_3 + Vector3.new(0, 2, 0), wU.Position)
    return true
end
function fns.fn31()
    local yQ = sL("SummonAmount", "1x")
    return yQ == "5x" and 5 or 1
end
function fns.fn80(cw)
    local wq = tQ[cw]
    if not wq then
        return {}
    end
    local wr = {}
    for k, v in wq do
        local wq_1 = Drops:FindFirstChild(v)
        if wq_1 then
            for i, child in wq_1:GetChildren() do
                if child:IsA("Model") then
                    local Humanoid = child:FindFirstChildOfClass("Humanoid")
                    local HumanoidRootPart = child:FindFirstChild("HumanoidRootPart")
                    if Humanoid and HumanoidRootPart and Humanoid.Health > 0 then
                        table.insert(wr, child)
                    end
                end
            end
        end
    end
    return wr
end
function fns.fn83(dR, dS)
    local Name = dS.Name
    local xo = tonumber(dS:GetAttribute("Level")) or 1
    local xo_1 = s0(dR, Name)
    return xo_1 * xo + tq(dR, Name)
end
function fns.fn125()
    local leaderstats = tN:FindFirstChild("leaderstats")
    local vU = leaderstats and leaderstats:FindFirstChild("Coins")
    local vT_1 = vU
    if vU then
        vU = vT_1.Value
    end
    local vT_2 = vU
    local vY = if vT_2 then 1 else 0
    local vW = 863 * vY + 3182 * (1 - vY)
    local vX = 1611 * vY + 2010 * (1 - vY)
    if not ((vW * 3530 + vX * 3850 + vW * vX) % 16777213 == 10639033) then
        vT_2 = 0
    end
    return vT_2
end
function fns.fn188(c8)
    if t2 and t2.Parent then
        local Humanoid = t2:FindFirstChildOfClass("Humanoid")
        local HumanoidRootPart = t2:FindFirstChild("HumanoidRootPart")
        if Humanoid and HumanoidRootPart and Humanoid.Health > 0 then
            local wZ_2 = tQ[c8]
            if wZ_2 then
                for k, v in wZ_2 do
                    if t2.Parent and t2.Parent.Name == v then
                        return t2
                    end
                end
            end
        end
    end
    t2 = select(1, tY(c8))
    return t2
end
function fns.fn194()
    local AO_1
    local AN_1
    local AM_1
    local AL_1
    local AK_1
    local AJ_1
    AJ_1, AK_1 = pcall(function()
        return GetAutoSell:InvokeServer()
    end)
    AL_1, AM_1 = pcall(function()
        return GetAutoSellWeapon:InvokeServer()
    end)
    AN_1, AO_1 = pcall(function()
        return GetAutoSellDrops:InvokeServer()
    end)
    local AP = AJ_1 and typeof(AK_1) == "table" and Options.AutoSellPets
    if AP then
        local AJ_2 = {}
        for k, v in tl do
            AJ_2[v] = AK_1[v] == true
        end
        Options.AutoSellPets:SetValue(AJ_2)
    end
    local AJ_3 = AL_1 and typeof(AM_1) == "table" and Options.AutoSellWeapons
    if AJ_3 then
        local AJ_4 = {}
        for k, v in tl do
            AJ_4[v] = AM_1[v] == true
        end
        Options.AutoSellWeapons:SetValue(AJ_4)
    end
    if AN_1 and Toggles.AutoSellDrops then
        Toggles.AutoSellDrops:SetValue(AO_1 == true)
    end
end
function fns.worker()
    while not sP.Unloaded do
        if tg("AutoSummon") then
            local EggSystem = PlayerGui:FindFirstChild("EggSystem")
            local EG = EggSystem
            if EG then
                local EH = EggSystem:GetAttribute("HatchingCount") or 0
                EG = EH
            end
            if (EG or 0) <= 0 then
                ud()
            end
        end
        task.wait(0.35)
    end
end
function fns.fn221()
    ue(tb, "Copied Discord invite to clipboard")
end
local function worker2()
    while not sP.Unloaded do
        if tg("AutoFarm") then
            local EJ = sL("FarmZone", tU[1])
            local EK = EJ ~= ""
            local EL = type(EJ) == "string" and EK
            if EL then
                tT()
                local EK_1 = tZ(EJ)
                if EK_1 then
                    local EL_1 = tn()
                    local HumanoidRootPart = EK_1:FindFirstChild("HumanoidRootPart")
                    local EN = sN()
                    if EL_1 and HumanoidRootPart then
                        local Magnitude = (HumanoidRootPart.Position - EL_1.Position).Magnitude
                        if Magnitude > math.max(5, EN * 0.5) then
                            s5(EK_1)
                        end
                    end
                else
                    t2 = nil
                    local EK_2 = tn()
                    local EL_2 = TeleportPoints:FindFirstChild(EJ)
                    if EK_2 and EL_2 then
                        local EM_3 = Vector3.new(EK_2.Position.X, 0, EK_2.Position.Z)
                        local EK_3 = Vector3.new(EL_2.Position.X, 0, EL_2.Position.Z)
                        if (EM_3 - EK_3).Magnitude > 60 then
                            tW(EJ)
                        end
                    end
                end
            end
        else
            t2 = nil
        end
        task.wait(0.15)
    end
end
local function fn275(bh)
    if sP.Unloaded then
        return false
    end
    local vw = Toggles[bh]
    return vw ~= nil and vw.Value == true
end
local function fn279()
    return tN.Character
end
local function fn381(i1)
    if s1[i1] then
        return
    end
    local Bj = i1:IsA("BasePart") and i1
    local Bk = Bj
    local Bv = if Bk then 1 else 0
    local Bt = 1575 * Bv + 3204 * (1 - Bv)
    local Bu = 3891 * Bv + 2 * (1 - Bv)
    if not ((Bt * 3813 + Bu * 3361 + Bt * Bu) % 16777213 == 8434238) then
        Bk = i1:FindFirstChildWhichIsA("BasePart", true)
    end
    local Bj_1 = Bk
    if not Bj_1 then
        return
    end
    local Bk_1 = sH(i1)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "EggESP"
    billboardGui.AlwaysOnTop = true
    billboardGui.Size = UDim2.fromOffset(140, 40)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.Adornee = Bj_1
    billboardGui.Parent = folder
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 14
    textLabel.TextStrokeTransparency = 0.4
    local Bn = Bk_1 and Color3.fromRGB(255, 120, 180)
    local Bo = Bn or Color3.fromRGB(120, 220, 255)
    textLabel.TextColor3 = Bo
    local Bo_1 = Bk_1 and "Event Egg\n" .. i1.Name or i1.Name
    textLabel.Text = Bo_1
    textLabel.Parent = billboardGui
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0.1
    local Bn_2 = Bk_1 and Color3.fromRGB(255, 80, 160)
    local Bk_2 = Bn_2 or Color3.fromRGB(80, 180, 255)
    highlight.FillColor = Bk_2
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    local Bk_3 = i1:IsA("Model") and i1
    local Bn_3 = Bk_3 or Bj_1
    highlight.Adornee = Bn_3
    highlight.Parent = folder
    s1[i1] = { Billboard = billboardGui, Highlight = highlight }
end
local function fn400()
    for k, v in s1 do
        if v.Billboard then
            v.Billboard:Destroy()
        end
        if v.Highlight then
            v.Highlight:Destroy()
        end
    end
    table.clear(s1)
end
local function fn416(a2, a3)
    if setclipboard then
        setclipboard(a2)
    elseif toclipboard then
        toclipboard(a2)
    end
    sP:Notify(a3)
end
local function fn430(bn, bo)
    local vz = Options[bn]
    if vz == nil then
        return bo
    end
    return vz.Value
end
local function fn442()
    local leaderstats = tN:FindFirstChild("leaderstats")
    local v_ = leaderstats and leaderstats:FindFirstChild("Level")
    local vZ_1 = v_
    if v_ then
        v_ = vZ_1.Value
    end
    local vZ_2 = v_
    local v3 = if vZ_2 then 1 else 0
    local v1 = 3408 * v3 + 914 * (1 - v3)
    local v2 = 1991 * v3 + 3663 * (1 - v3)
    if not ((v1 * 2310 + v2 * 3152 + v1 * v2) % 16777213 == 4156227) then
        vZ_2 = 0
    end
    return vZ_2
end
local function fn500()
    local Areas = tN:FindFirstChild("Areas")
    local zj = {}
    for i, child in Doors:GetChildren() do
        local zk = tonumber(child.Name)
        local Price = child:FindFirstChild("Price")
        local ProximityPrompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
        local zn = zk and Price
        if zn then
            local zo = not Areas or not Areas:FindFirstChild(child.Name)
            zn = zo
        end
        if zn then
            if not ProximityPrompt or ProximityPrompt.Enabled ~= false then
                table.insert(zj, { Door = child, Index = zk, Price = Price.Value })
            end
        end
    end
    table.sort(zj, function(go, gp)
        return go.Index < gp.Index
    end)
    return zj[1]
end
local function fn518(dl, dm)
    if dl == "Weapon" then
        local w8_1 = Weapons2:FindFirstChild(dm)
        local w9_1 = w8_1 and w8_1:FindFirstChild("Config")
        local w8_2 = w9_1
        if w9_1 then
            w9_1 = w8_2:FindFirstChild("Damage")
        end
        local w8_3 = w9_1
        if w8_3 then
            local w9_2 = tonumber(w8_3.Value) or 0
            return w9_2
        end
        local w8_4 = tm[dm]
        local w9_3 = w8_4
        if w9_3 then
            w9_3 = w8_4.UpgradePrice or 0
        end
        return w9_3 or 0
    end
    local w8_6 = Pets:FindFirstChild(dm)
    local w9_4 = w8_6 and w8_6:FindFirstChild("Config")
    local w8_7 = w9_4
    if w9_4 then
        w9_4 = w8_7:FindFirstChild("Damage")
    end
    local w8_8 = w9_4
    if w8_8 then
        local w9_5 = (tonumber(w8_8.Value))
        local xe_1 = if w9_5 then 1 else 0
        local xc_1 = 2937 * xe_1 + 1549 * (1 - xe_1)
        local xd_1 = 2215 * xe_1 + 1388 * (1 - xe_1)
        if not ((xc_1 * 4029 + xd_1 * 3233 + xc_1 * xd_1) % 16777213 == 8722510) then
            w9_5 = 0
        end
        return w9_5
    end
    local w8_9 = tD[dm]
    local w9_6 = w8_9
    if w9_6 then
        local xa_2 = w8_9.UpgradePrice
        local xe_2 = if xa_2 then 1 else 0
        local xc_2 = 601 * xe_2 + 1237 * (1 - xe_2)
        local xd_2 = 2004 * xe_2 + 2367 * (1 - xe_2)
        if not ((xc_2 * 922 + xd_2 * 1424 + xc_2 * xd_2) % 16777213 == 4612222) then
            xa_2 = 0
        end
        w9_6 = xa_2
    end
    return w9_6 or 0
end
local function worker4()
    while not sP.Unloaded do
        if tg("AutoBuyDoor") then
            un()
        end
        task.wait(1)
    end
end
local function fn527(jF)
    local DiscordGroup = jF:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = t_ })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = t_ })
end
local function fn552()
    local Values = tN:FindFirstChild("Values")
    local xI = Values and Values:FindFirstChild("MaxEquipPets")
    local xJ = Values
    if xJ then
        xJ = Values:FindFirstChild("MaxEquipPetsPerk")
    end
    local xH_1 = xI
    local xI_1 = xJ
    if xH_1 then
        xH_1 = xI.Value
    end
    local xJ_1 = xH_1
    local xO = if xJ_1 then 1 else 0
    local xM = 129 * xO + 3776 * (1 - xO)
    local xN = 2498 * xO + 676 * (1 - xO)
    if not ((xM * 2223 + xN * 2836 + xM * xN) % 16777213 == 7693337) then
        xJ_1 = 2
    end
    return xJ_1 + (xI_1 and xI_1.Value or 0)
end
local function fn564(bc, bd, be)
    return string.format("<b>%s</b> %s %s", bc, tL("-", "#5a6070"), tL(bd, be))
end
local function fn584()
    local vQ = tH()
    local vR = vQ and vQ:FindFirstChild("HumanoidRootPart")
    return vR
end
local function fn651(dI, dJ)
    local xg = dI == "Weapon" and tm[dJ] or tD[dJ]
    if not xg then
        return 0
    end
    local xg_1 = tonumber(xg.Chance) or 100
    local xg_2 = tonumber(xg.SellPrice) or 0
    local xg_3 = tonumber(xg.UpgradePrice) or 0
    return xg_2 * 10 + xg_3 + math.max(0, 100 - xg_1)
end
local function worker7()
    while not sP.Unloaded do
        if tg("AutoClass") then
            s6()
        end
        task.wait(1.5)
    end
end
local function onLoadFromGame()
    s8()
    sP:Notify("Loaded auto sell from game")
end
local function worker9()
    while not sP.Unloaded do
        if tg("AutoEquipBestEntity") then
            tt()
        end
        task.wait(3)
    end
end
local function worker5()
    while not sP.Unloaded do
        if tg("AutoUpgrade") then
            s7()
        end
        task.wait(1.5)
    end
end
local function fn924()
    local wf = tH()
    local wg = wf and wf:FindFirstChildOfClass("Tool")
    local wf_1 = wg
    if wg then
        wg = wf_1:FindFirstChild("Config")
    end
    local wf_2 = wg
    if wg then
        wg = wf_2:FindFirstChild("Range")
    end
    local wf_3 = wg
    if wg then
        wg = tonumber(wf_3.Value)
    end
    return wg or 15
end
local function onApplyAutoSell()
    uv()
    sP:Notify("Auto sell settings applied")
end
local function fn985(iZ)
    local Name = iZ.Name
    return Name ~= "BasicEgg" and Name ~= "BasicEgg2"
end
local function fn1019(aC, aD)
    local vs = Races[aC] and Races[aC].Chance or 999
    local vs_2 = Races[aD] and Races[aD].Chance or 999
    if vs == vs_2 then
        return aC < aD
    end
    return vs < vs_2
end
local function worker11()
    while not sP.Unloaded do
        s3()
        task.wait(0.5)
    end
end
local function fn1027(cK)
    local wJ_1
    local wI_1
    local wH = tn()
    if not wH then
        return nil
    end
    wI_1, wJ_1 = nil, nil
    for k, v in td(cK) do
        local HumanoidRootPart = v:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart then
            local Magnitude = (HumanoidRootPart.Position - wH.Position).Magnitude
            if not wJ_1 or Magnitude < wJ_1 then
                wI_1 = v
                wJ_1 = Magnitude
            end
        end
    end
    return wI_1, wJ_1
end
local function fn1053(bs)
    local vB = sL(bs, {})
    if typeof(vB) ~= "table" then
        return {}
    end
    local vC = {}
    for k, v in pairs(vB) do
        if v == true then
            vC[k] = true
        end
    end
    return vC
end
local function worker3()
    local EQ = false
    while not sP.Unloaded do
        local ER = (tg("AutoAttack"))
        local EW = if ER then 1 else 0
        local EU = 2176 * EW + 2582 * (1 - EW)
        local EV = 1681 * EW + 1205 * (1 - EW)
        if not ((EU * 234 + EV * 3222 + EU * EV) % 16777213 == 9583222) then
            ER = tg("AutoFarm")
        end
        if ER then
            tT()
            if not EQ then
                uo(true)
                EQ = true
            end
            pcall(function()
                AttackEvent:FireServer()
            end)
        elseif EQ then
            uo(false)
            EQ = false
        end
        task.wait(0.15)
    end
end
local function fn1134()
    local yN = sL("SummonPool", "Normal")
    return yN == "Premium" and "RANDOM2" or "RANDOM"
end
local function worker6()
    while not sP.Unloaded do
        if tg("AutoStats") then
            sV()
        end
        task.wait(0.5)
    end
end
local function fn1192(a9, ba)
    return string.format('<font color="%s">%s</font>', ba, a9)
end
local function worker8()
    while not sP.Unloaded do
        if tg("AutoEquipBestWeapon") then
            tM()
        end
        task.wait(3)
    end
end
local function worker10()
    while not sP.Unloaded do
        local E2 = tg("PickupRangeEnabled") or tg("AutoFarm")
        if E2 then
            local E2_1 = sL("PickupRange", 50)
            local E3 = tg("AutoFarm") and not tg("PickupRangeEnabled")
            if E3 then
                E2_1 = math.max(E2_1, 50)
            end
            tj(E2_1)
        end
        task.wait(0.15)
    end
end
local function fn1251()
    return t3
end
local function fn1258()
    local vN = tH()
    local vO = vN and vN:FindFirstChildOfClass("Humanoid")
    return vO
end
sH = nil
sL = nil
sN = nil
sP = nil
sV = nil
s_ = nil
s0 = nil
s1 = nil
s3 = nil
s5 = nil
s6 = nil
s7 = nil
s8 = nil
folder = nil
tb = nil
td = nil
tg = nil
tj = nil
tl = nil
tm = nil
tn = nil
Weapons2 = nil
tq = nil
Pets = nil
local sG, sI, UpgradeSkill, sK, sM, AutoRerollRace, sQ, SwitchRaceSlot, sS, sT, GetRaceData, sW, sX, sY, UnequipPets, s2, EquipWeapon, s9, EquipPet, te, tf, th, ti, GetData, UpgradePerks, UpgradeWeapon
tt = nil
TeleportPoints = nil
local tw
GetAutoSellDrops = nil
Drops = nil
GetAutoSellWeapon = nil
tD = nil
tE = nil
GetAutoSell = nil
tH = nil
PlayerGui = nil
tL = nil
tM = nil
tN = nil
Doors = nil
tQ = nil
tT = nil
tU = nil
tW = nil
tY = nil
tZ = nil
t_ = nil
t2 = nil
t3 = nil
AttackEvent = nil
t6 = nil
ud = nil
ue = nil
local UpgradePet, tz, tA, CurrencyDrops, Weapons, SetAutoSellDrops, Eggs, SetAutoSellWeapon, Workspace, SetAutoSell, tV, GiveCoins, t0, PurchaseDoor, t4, t7, RandomWeapon, t9, ua, Random, Skills, uf
Races = nil
Options = nil
un = nil
uo = nil
Toggles = nil
us = nil
uv = nil
local ug, uh, uk, ul, um, uq, Perks, ut, uu
ug = nil
uh = nil
uk = nil
ul = nil
um = nil
uq = nil
Perks = nil
ut = nil
uu = nil
sG, E8_40, ul, ug, ua, t7, t3, t0, tV, Workspace, tN, PlayerGui, tE = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local E8_9 = 32
repeat
    E8_24 = (E8_9 * 5 + 4) % 6 + 1
    if E8_24 <= 3 then
        if E8_24 <= 2 then
            if E8_24 <= 1 then
                E8_12 = (vector.create((E8_9 * 1 + 3) % 11 + 1, (E8_9 * 8 + 1) % 13 + 1, (E8_9 * 12 + 3) % 17 + 1))
                E8_42 = (vector.create((E8_9 * 3 + 2) % 11 + 1, (E8_9 * 9 + 3) % 13 + 1, (E8_9 * 3 + 8) % 17 + 1))
                local FO = vector.dot(E8_12, E8_42)
                if FO * FO <= vector.dot(E8_12, E8_12) * vector.dot(E8_42, E8_42) then
                    tN = sG.LocalPlayer
                    PlayerGui = tN:WaitForChild("PlayerGui")
                else
                    sG = PlayerGui.LocalPlayer
                    tN = sG:WaitForChild("PlayerGui")
                end
                E8_9 = (E8_9 + 5) % 48
            else
                if (E8_9 * 3 + 3) * 9 % 4 == ((E8_9 * 3 + 3) * 9 + 5) % 4 then
                    t7 = fn1251
                else
                    tE = fn1251
                end
                E8_9 = (E8_9 + 23) % 48
            end
        else
            E8_12 = {
                "lbgomxfev",
                "yhyegbha",
                "qrstej",
                "icln",
                "ysynfinc",
                "wybougge",
                "xofahq",
                "ndfnmoqvb",
                "vtngcxdm",
                "tbrcpipjdj",
                "rbhde",
                "ewotfwwt",
                "fmfkzm",
                "kdibnotq",
                "ciplhw"
            }
            if E8_12[(E8_9 * 7 + 61) % 15 + 1] <= E8_12[(E8_9 * 7 + 61) % 15 + 1] then
                sG = game:GetService("Players")
            else
                tN = game:GetService("Players")
            end
            E8_9 = (E8_9 + 5) % 48
        end
    elseif E8_24 <= 5 then
        if E8_24 <= 4 then
            E8_24 = { "pgzanhapouvd", "bhnraktc", "zhkl", "gtzh", "igzndh", "dmigpdo", "onejz", "dexichvdco", "nvyg" }
            if E8_24[(E8_9 * 75 + 70) % 9 + 1] < E8_24[(E8_9 * 75 + 70) % 9 + 1] then
                t7 = game:GetService("ReplicatedStorage")
                ug = game:GetService("RunService")
                ul = game:GetService("UserInputService")
                E8_40 = game:GetService("VirtualUser")
                ua = game:GetService("HttpService")
            else
                E8_40 = game:GetService("ReplicatedStorage")
                ul = game:GetService("RunService")
                ug = game:GetService("UserInputService")
                ua = game:GetService("VirtualUser")
                t7 = game:GetService("HttpService")
            end
            E8_9 = (E8_9 + 11) % 48
        else
            local GJ = bit32.rrotate(bit32.bxor(bit32.lrotate(E8_9, 16), string.byte(tostring(t3))), 19)
            if bit32.bxor(bit32.lrotate(bit32.bxor(GJ, 1930598791), 18), 1713228874) ~= bit32.lrotate(GJ, 18) then
                tV = game:GetService("CoreGui")
                t3 = game:GetService("GuiService")
                t0 = game:GetService("TeleportService")
            else
                t3 = game:GetService("CoreGui")
                t0 = game:GetService("GuiService")
                tV = game:GetService("TeleportService")
            end
            E8_9 = (E8_9 + 47) % 48
        end
    else
        E8_24 = {
            "nstsxjxqmtew",
            "ecsyk",
            "phzwywwbsmtc",
            "cvmzd",
            "layngihawmdh",
            "mvfx",
            "iuifdvwvyipe",
            "qojkqwqv"
        }
        if E8_24[(E8_9 * 48 + 17) % 8 + 1] <= E8_24[(E8_9 * 48 + 17) % 8 + 1] then
            Workspace = game:GetService("Workspace")
        else
            ul = game:GetService("Workspace")
        end
        E8_9 = (E8_9 + 47) % 48
    end
until (E8_9 * 25 + 6) % 48 == 32
if getgenv then
    tw, E8_24 = nil, nil
    E8_9 = 4
    repeat
        E8_12 = (E8_9 * 1 + 1) % 2 + 1
        if E8_12 <= 1 then
            if E8_9 * 81411465 + 4 + 4 <= E8_9 * 81411465 + 4 + 4 + 4 then
                E8_24 = tw
            else
                tw = E8_24
            end
            E8_9 = (E8_9 + 7) % 8
        else
            if E8_9 * 47152541 + 12 + 6 <= E8_9 * 47152541 + 12 + 6 + 5 then
                getgenv().gethui = tE
                tw = getgenv().__TempoBackroomsLib
            else
                getgenv().gethui = tw
                tE = getgenv().__TempoBackroomsLib
            end
            E8_9 = (E8_9 + 1) % 8
        end
    until (E8_9 * 7 + 3) % 8 == 7
    if E8_24 then
        E8_24 = tw.Unload
    end
    if E8_24 then
        pcall(function()
            tw:Unload()
        end)
    end
end
pcall(function()
    gethui = tE
end)
if setthreadidentity then
    setthreadidentity(8)
end
ti, tb, s2, sY, sT, sQ, sM, sI, uq, Random, RandomWeapon, AttackEvent, PurchaseDoor, GiveCoins, SetAutoSell, SetAutoSellWeapon, SetAutoSellDrops, GetAutoSell, GetAutoSellWeapon, GetAutoSellDrops, UpgradePet, UpgradeWeapon, UpgradePerks, GetData, EquipPet, EquipWeapon, UnequipPets, GetRaceData, SwitchRaceSlot, AutoRerollRace, UpgradeSkill, Perks, Races, Skills, E8_29, E8_16, Doors, Eggs, Weapons, CurrencyDrops, Drops, TeleportPoints, Pets, Weapons2, tl = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
ti = "Backrooms Simulator"
tb = "https://discord.gg/K7Qxnxkk46"
s2 = "https://discord.gg/K7Qxnxkk46"
sY = "https://tempohub.shop"
sT = "#7fd47f"
sQ = "#6ec1ff"
sM = "#e8a34d"
sI = "#8b93a3"
uq = "#e05a5a"
E8_42 = E8_40:WaitForChild("Remotes")
E8_12 = E8_40:WaitForChild("RemotesStats")
Random = E8_42:WaitForChild("Random")
RandomWeapon = E8_42:WaitForChild("RandomWeapon")
AttackEvent = E8_42:WaitForChild("AttackEvent")
PurchaseDoor = E8_42:WaitForChild("PurchaseDoor")
GiveCoins = E8_42:WaitForChild("GiveCoins")
SetAutoSell = E8_42:WaitForChild("SetAutoSell")
if (not GiveCoins and not GetAutoSell or false) and (not GiveCoins and GetAutoSell or (GetAutoSell or GetAutoSell)) or not ((not GiveCoins and not GetAutoSell or false) and (not GiveCoins and GetAutoSell or (GetAutoSell or GetAutoSell))) then
    SetAutoSellWeapon = E8_42:WaitForChild("SetAutoSellWeapon")
else
    E8_42 = SetAutoSellWeapon:WaitForChild("SetAutoSellWeapon")
end
SetAutoSellDrops = E8_42:WaitForChild("SetAutoSellDrops")
GetAutoSell = E8_42:WaitForChild("GetAutoSell")
GetAutoSellWeapon = E8_42:WaitForChild("GetAutoSellWeapon")
GetAutoSellDrops = E8_42:WaitForChild("GetAutoSellDrops")
UpgradePet = E8_42:WaitForChild("UpgradePet")
UpgradeWeapon = E8_42:WaitForChild("UpgradeWeapon")
UpgradePerks = E8_42:WaitForChild("UpgradePerks")
GetData = E8_42:WaitForChild("GetData")
EquipPet = E8_42:WaitForChild("EquipPet")
EquipWeapon = E8_42:WaitForChild("EquipWeapon")
UnequipPets = E8_42:WaitForChild("UnequipPets")
GetRaceData = E8_42:WaitForChild("GetRaceData")
SwitchRaceSlot = E8_42:WaitForChild("SwitchRaceSlot")
AutoRerollRace = E8_42:WaitForChild("AutoRerollRace")
UpgradeSkill = E8_12:WaitForChild("UpgradeSkill")
Perks = require(E8_40:WaitForChild("Perks"))
local TeleportData = require(E8_40.Data:WaitForChild("TeleportData"))
Races = require(E8_40.Data:WaitForChild("Races"))
Skills = require(E8_12.Configuration:WaitForChild("Skills"))
local E8_13 = require(E8_40:WaitForChild("TowerShop"))
local E8_45 = require(E8_40:WaitForChild("TowerShop2"))
if (not GiveCoins or GiveCoins) and (E8_29 or GiveCoins) and (GiveCoins and GiveCoins or (E8_29 or not GiveCoins)) and (GiveCoins or GiveCoins or (GiveCoins or not GiveCoins) or (GiveCoins or E8_29 or GiveCoins and not GiveCoins)) or not ((not GiveCoins or GiveCoins) and (E8_29 or GiveCoins) and (GiveCoins and GiveCoins or (E8_29 or not GiveCoins)) and (GiveCoins or GiveCoins or (GiveCoins or not GiveCoins) or (GiveCoins or E8_29 or GiveCoins and not GiveCoins))) then
    E8_29 = require(E8_40:WaitForChild("WeaponShop"))
    E8_16 = require(E8_40:WaitForChild("WeaponShop2"))
else
    E8_40 = require(E8_16:WaitForChild("WeaponShop"))
    E8_29 = require(E8_16:WaitForChild("WeaponShop2"))
end
E8_24 = Workspace:WaitForChild("Main")
Doors = E8_24:WaitForChild("Doors")
Eggs = E8_24:WaitForChild("Eggs")
Weapons = E8_24:WaitForChild("Weapons")
CurrencyDrops = E8_24:WaitForChild("CurrencyDrops")
Drops = E8_24:WaitForChild("Drops")
TeleportPoints = Workspace:WaitForChild("TeleportPoints")
Pets = E8_40:WaitForChild("Pets")
Weapons2 = E8_40:WaitForChild("Weapons")
tl = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Godly", "Secret" }
if (not AutoRerollRace or E8_24) and (E8_24 and not E8_24) and (not E8_16 or E8_24 or (false or UnequipPets)) or sT and E8_24 and (E8_24 or AutoRerollRace) and ((false or E8_24) and (AutoRerollRace or UnequipPets)) or ((UnequipPets or sT or AutoRerollRace and not E8_24) and (not E8_24 or not E8_24 or (not E8_24 or AutoRerollRace)) or not UnequipPets and UnequipPets and (AutoRerollRace or not AutoRerollRace) and (E8_24 and not E8_24 and (not AutoRerollRace or E8_16))) or not ((not AutoRerollRace or E8_24) and (E8_24 and not E8_24) and (not E8_16 or E8_24 or (false or UnequipPets)) or sT and E8_24 and (E8_24 or AutoRerollRace) and ((false or E8_24) and (AutoRerollRace or UnequipPets)) or ((UnequipPets or sT or AutoRerollRace and not E8_24) and (not E8_24 or not E8_24 or (not E8_24 or AutoRerollRace)) or not UnequipPets and UnequipPets and (AutoRerollRace or not AutoRerollRace) and (E8_24 and not E8_24 and (not AutoRerollRace or E8_16)))) then
    E8_7 = { "Pets", "Weapons" }
    E8_20 = { "Normal", "Premium" }
    E8_34 = { "1x", "5x" }
    E8_3 = { "Pets", "Weapons", "Perks", "All" }
    E8_18 = { "Health", "Sword", "Gun", "Speed", "Critical Chance", "Critical Damage", "All" }
else
    E8_34 = { "Pets", "Weapons" }
    E8_18 = { "Normal", "Premium" }
    E8_7 = { "1x", "5x" }
    E8_20 = { "All", "Perks", "Pets", "Weapons" }
    E8_3 = { "Critical Damage", "Speed", "Health", "Gun", "Critical Chance", "Sword", "All" }
end
local E8_31 = { "1", "2", "3" }
local E8_2 = {}
for k in Races do
    table.insert(E8_2, k)
end
E8_9 = 3
repeat
    E8_40 = {
        "taclwk",
        "kfqmffhaw",
        "nqfhy",
        "sawjlzqlk",
        "mzyrhvwmhr",
        "kzxux",
        "ltgn",
        "nla",
        "apprkzvylu",
        "zyj",
        "efpul",
        "wdsl"
    }
    local Gx = E8_9
    E8_24 = E8_40[Gx % 12 + 1]
    if E8_24:len() <= E8_24:reverse():rep(Gx % 3 + 2):len() then
        table.sort(E8_2, fn1019)
    else
        table.sort(E8_2, fn1019)
    end
    E8_9 = (E8_9 + 7) % 8
until (E8_9 * 1 + 5) % 8 == 7
tQ = {}
tU = {}
for i, v in ipairs(TeleportData) do
    if v.Category == "Area" then
        table.insert(tU, v.Name)
        if v.RequiredDoor then
            tQ[v.Name] = { tostring(v.RequiredDoor) }
        else
            tQ[v.Name] = { "1", "2", "3" }
        end
    end
end
tD = {}
for k, v in E8_13 do
    tD[k] = v
end
for k, v in E8_45 do
    tD[k] = v
end
tm = {}
for k, v in E8_29 do
    tm[k] = v
end
for k, v in E8_16 do
    tm[k] = v
end
sP, sK, uu = nil, nil, nil
E8_40 = 1
repeat
    E8_24 = {
        "uewvpf",
        "ilpwn",
        "bngqx",
        "cdhy",
        "cvc",
        "sszlcgvrg",
        "jzip",
        "junc",
        "vxpoa",
        "vxotxjrta",
        "vwjzdrnab",
        "imrfikgv"
    }
    local GE = E8_40
    E8_12 = E8_24[GE % 12 + 1]
    if E8_12:len() <= E8_12:reverse():rep(GE % 3 + 2):len() then
        sP = getgenv().Library
        sK = getgenv().ThemeManager
        uu = getgenv().SaveManager
    else
        sK = ""
        local _ = getgenv().Library
        uu = getgenv().ThemeManager
        sP = getgenv().SaveManager
    end
    E8_40 = (E8_40 + 0) % 4
until (E8_40 * 3 + 1) % 4 == 0
if getgenv then
    getgenv().__TempoBackroomsLib = sP
end
Toggles, Options, t2, tf, folder, s1, te, ue, t_, tL, tz, tg, sL, t9, tH, tA, tn, sW, um, tW, sN, tT, td, tY, s5, uo, tZ, s0, tq, uk, tM, t4, tt, sV, s6, sS, ut, ud, th, uf, s9, un, tj, t6, us, s_, s7, uv, s8, sX, sH, uh, s3 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Toggles = sP.Toggles
Options = sP.Options
ue = fn416
t_ = fns.fn221
tL = fn1192
tz = fn564
tg = fn275
sL = fn430
t9 = fn1053
tH = fn279
tA = fn1258
tn = fn584
sW = fns.fn125
um = fn442
tW = function(bV)
    local wa = TeleportPoints:FindFirstChild(bV)
    local wb = tn()
    if not wa or not wb then
        return false
    end
    local wc_1 = wa.CFrame + Vector3.new(0, 3, 0)
    wb.AssemblyLinearVelocity = Vector3.zero
    wb.AssemblyAngularVelocity = Vector3.zero
    wb.CFrame = wc_1
    pcall(function()
        local PlayerScripts = tN:FindFirstChild("PlayerScripts")
        local v5 = PlayerScripts and PlayerScripts:FindFirstChild("LightingSystem")
        local v4_1 = v5
        if v5 then
            v5 = v4_1:FindFirstChild("ApplyTeleportLighting")
        end
        local v4_2 = v5
        if v5 then
            v5 = v4_2:IsA("BindableEvent")
        end
        if v5 then
            v4_2:Fire(bV)
        end
    end)
    return true
end
sN = fn924
tT = function()
    local wk = tH()
    if not wk then
        return false
    end
    local wp = if wk:FindFirstChildOfClass("Tool") then 1 else 0
    if wp == 1 then
        return true
    end
    local Backpack = tN:FindFirstChild("Backpack")
    if not Backpack then
        return false
    end
    local Tool = Backpack:FindFirstChildOfClass("Tool")
    if not Tool then
        return false
    end
    local wi = tA()
    if wi then
        pcall(function()
            wi:EquipTool(Tool)
        end)
    end
    return wk:FindFirstChildOfClass("Tool") ~= nil
end
td = fns.fn80
tY = fn1027
s5 = fns.fn21
uo = function(c2)
    pcall(function()
        if c2 then
            tN:SetAttribute("AFKAutoAttackRequest", true)
        else
            tN:SetAttribute("AFKAutoAttackRequest", nil)
        end
    end)
end
t2 = nil
tZ = fns.fn188
s0 = fn518
tq = fn651
uk = fns.fn83
tM = function()
    local xr, xs, attr
    local xv_1, xv_2
    local Weapons = tN:FindFirstChild("Weapons")
    local xu_4
    if not Weapons then
        return false
    end
    xs, xv_1 = nil, nil
    for i, child in Weapons:GetChildren() do
        local attr = child:GetAttribute("ID")
        if attr then
            local xu_2 = uk("Weapon", child)
            if not xv_1 or xu_2 > xv_1 then
                xs = child
                xv_1 = xu_2
            end
        end
    end
    if not xs then
        return false
    end
    local xu_3 = tonumber(xs:GetAttribute("Level")) or 1
    xr = xu_3
    attr = xs:GetAttribute("ID")
    xu_4, xv_2 = pcall(function()
        return EquipWeapon:InvokeServer(xs.Name, xr, attr)
    end)
    if xu_4 and xv_2 then
        tT()
        return true
    end
    return false
end
t4 = fn552
tt = function()
    local Pets = tN:FindFirstChild("Pets")
    if not Pets then
        return false
    end
    local xT = {}
    for i, child in Pets:GetChildren() do
        local attr = child:GetAttribute("ID")
        if attr then
            local insert = table.insert
            local xW_1 = uk("Pet", child)
            local xX = tonumber(child:GetAttribute("Level")) or 1
            insert(xT, { Pet = child, Score = xW_1, Id = attr, Level = xX })
        end
    end
    table.sort(xT, function(eu, ev)
        return eu.Score > ev.Score
    end)
    local xU_2 = t4()
    local xV_2 = {}
    local xW_2 = math.min(xU_2, #xT)
    local x6 = 1
    while x6 <= xW_2 do
        local x7 = x6
        xV_2[xT[x7].Id] = xT[x7]
        x6 += 1
    end
    for i, child in Pets:GetChildren() do
        local xR
        local ye = child
        local attr2 = ye:GetAttribute("ID")
        local attr = ye:GetAttribute("Equipped")
        local xU_3 = attr2
        local xW_3 = attr == true
        if xU_3 then
            xU_3 = xW_3
        end
        if xU_3 then
            xU_3 = not xV_2[attr2]
        end
        if xU_3 then
            local xS_2 = tonumber(ye:GetAttribute("Level")) or 1
            xR = xS_2
            pcall(function()
                UnequipPets:InvokeServer(ye.Name, xR, attr2)
            end)
            task.wait(0.1)
        end
    end
    for k, v in xT do
        local yl = v
        if xV_2[yl.Id] then
            local Pet = yl.Pet
            if Pet:GetAttribute("Equipped") ~= true then
                pcall(function()
                    EquipPet:InvokeServer(Pet.Name, yl.Level, yl.Id)
                end)
                task.wait(0.15)
            end
        end
    end
    return true
end
sV = function()
    local yq_1
    local Stats = tN:FindFirstChild("Stats")
    local Skills2 = tN:FindFirstChild("Skills")
    local yp = Stats and Stats:FindFirstChild("SkillPoints")
    if not yp or not Skills2 or yp.Value <= 0 then
        return
    end
    local yp_2 = sL("AutoStatTarget", "Sword")
    if yp_2 == "All" then
        yq_1 = { "Sword", "Gun", "Health", "Speed", "Critical Chance", "Critical Damage" }
    else
        yq_1 = { yp_2 }
    end
    for k, v in yq_1 do
        local yB = v
        if yp.Value <= 0 then
            return
        end
        local yp_3 = Skills2:FindFirstChild(yB)
        local yq_2 = Skills[yB]
        if yp_3 and yq_2 then
            local yr_2 = (yq_2.Limit or 0) - yp_3.Value
            if yr_2 > 0 then
                local ym = math.min(yp.Value, yr_2, 10)
                if ym > 0 then
                    pcall(function()
                        UpgradeSkill:FireServer(yB, ym)
                    end)
                    task.wait(0.15)
                end
            end
        end
    end
end
tf = false
s6 = function()
    local yC, yD
    local yG_1, yG_3
    if tf then
        return
    end
    local yE = t9("StopAtClass")
    yD = {}
    for k in yE do
        table.insert(yD, k)
    end
    if #yD == 0 then
        return
    end
    local yF = tonumber(sL("ClassSlot", "1")) or 1
    local yF_1, yF_4
    yC = yF
    tf = true
    pcall(function()
        SwitchRaceSlot:InvokeServer(yC)
    end)
    task.wait(0.2)
    yF_1, yG_1 = pcall(function()
        return GetRaceData:InvokeServer()
    end)
    local yH = yF_1 and typeof(yG_1) == "table" and yG_1.Slots and yG_1.Slots[yC]
    if yH then
        local Race = yG_1.Slots[yC].Race
        if Race and yE[Race] then
            tf = false
            return
        end
        if (yG_1.Slots[yC].Spins or 0) <= 0 then
            tf = false
            return
        end
    end
    yF_4, yG_3 = pcall(function()
        return AutoRerollRace:InvokeServer(yC, yD)
    end)
    tf = false
    local yH_2 = yF_4 and typeof(yG_3) == "table" and yG_3.Success and yG_3.NewRace and yE[yG_3.NewRace]
    if yH_2 then
        if Toggles.AutoClass then
            Toggles.AutoClass:SetValue(false)
        end
        sP:Notify("Got class: " .. tostring(yG_3.NewRace))
    end
end
sS = fn1134
ut = fns.fn31
ud = function()
    local yT, yU
    local yV = sL("SummonType", "Pets")
    yU = sS()
    yT = ut()
    if yV == "Weapons" then
        return pcall(function()
            RandomWeapon:InvokeServer(yT, yU, true)
        end)
    end
    return pcall(function()
        Random:InvokeServer(yT, yU, true)
    end)
end
th = function()
    local Areas = tN:FindFirstChild("Areas")
    if not Areas then
        return
    end
    for i, child in Doors:GetChildren() do
        local zh = child
        if Areas:FindFirstChild(zh.Name) then
            pcall(function()
                local ProximityPrompt = zh:FindFirstChildWhichIsA("ProximityPrompt", true)
                if ProximityPrompt then
                    ProximityPrompt.Enabled = false
                end
                for i, descendant in zh:GetDescendants() do
                    if descendant:IsA("BasePart") then
                        descendant.CanCollide = false
                        descendant.Transparency = 1
                    end
                end
                local y9 = if zh:IsA("BasePart") then 1 else 0
                if y9 == 1 then
                    zh.CanCollide = false
                    zh.Transparency = 1
                end
                zh:Destroy()
            end)
        end
    end
end
uf = fn500
s9 = function()
    local MainGui = PlayerGui:FindFirstChild("MainGui")
    local zy = MainGui and MainGui:FindFirstChild("PurchaseArea")
    if not zy or not zy.Visible then
        return false
    end
    local Buy = zy:FindFirstChild("Buy")
    if not Buy then
        return false
    elseif firesignal then
        pcall(firesignal, Buy.Activated)
        return true
    else
        return pcall(function()
            Buy:Activate()
        end)
    end
end
un = function()
    local zE_1
    th()
    local zC = uf()
    if not zC then
        return false
    elseif sW() < zC.Price then
        return false
    else
        local zD = tn()
        local zD_1
        if zD then
            zD.CFrame = zC.Door.CFrame + Vector3.new(0, 3, 5)
            task.wait(0.15)
        end
        local ProximityPrompt = zC.Door:FindFirstChildWhichIsA("ProximityPrompt", true)
        if ProximityPrompt then
            pcall(function()
                if fireproximityprompt then
                    fireproximityprompt(ProximityPrompt)
                else
                    ProximityPrompt:InputHoldBegin()
                    task.wait(0.05)
                    ProximityPrompt:InputHoldEnd()
                end
            end)
            task.wait(0.25)
            s9()
            task.wait(0.1)
        end
        zD_1, zE_1 = pcall(function()
            return PurchaseDoor:InvokeServer(zC.Door)
        end)
        if zD_1 and zE_1 == true then
            pcall(function()
                zC.Door:Destroy()
            end)
            return true
        end
        return false
    end
end
tj = function(gP)
    local zM = tn()
    if not zM then
        return
    end
    for i, child in CurrencyDrops:GetChildren() do
        local zL
        local zN = child:IsA("BasePart") and child:FindFirstChild("CanCollect") and child:FindFirstChild("ID")
        if zN then
            if (child.Position - zM.Position).Magnitude <= gP then
                zL = string.split(child.ID.Value, "|")
                pcall(function()
                    local zJ = #zL == 1 and zL[1] or zL
                    GiveCoins:FireServer(zJ)
                end)
                child:Destroy()
            end
        end
    end
end
t6 = function()
    local Pets = tN:FindFirstChild("Pets")
    if not Pets then
        return
    end
    for i, child in Pets:GetChildren() do
        local z4 = child
        local zX_1 = sP.Unloaded or not tg("AutoUpgrade")
        if zX_1 then
            return
        end
        local attr = z4:GetAttribute("ID")
        local zX_2 = z4:GetAttribute("Level") or 1
        local zV = zX_2
        local zX_3 = tD[z4.Name]
        if attr and zX_3 and zV < 40 and zX_3.UpgradePrice then
            local zY_1 = zX_3.UpgradePrice * zV
            if sW() >= zY_1 then
                pcall(function()
                    UpgradePet:InvokeServer(z4.Name, zV, attr)
                end)
                task.wait(0.15)
            end
        end
    end
end
us = function()
    local Weapons = tN:FindFirstChild("Weapons")
    if not Weapons then
        return
    end
    for i, child in Weapons:GetChildren() do
        local Af = child
        local z7_1 = sP.Unloaded or not tg("AutoUpgrade")
        if z7_1 then
            return
        end
        local attr = Af:GetAttribute("ID")
        local z7_2 = Af:GetAttribute("Level") or 1
        local z6 = z7_2
        local z7_3 = tm[Af.Name]
        if attr and z7_3 and z6 < 40 and z7_3.UpgradePrice then
            local z8_1 = z7_3.UpgradePrice * z6
            if sW() >= z8_1 then
                pcall(function()
                    UpgradeWeapon:InvokeServer(Af.Name, z6, attr)
                end)
                task.wait(0.15)
            end
        end
    end
end
s_ = function()
    local Ah_1
    local Ag_1, Ag_2
    Ag_1, Ah_1 = pcall(function()
        return GetData:InvokeServer()
    end)
    local Ai = not Ag_1 or typeof(Ah_1) ~= "table" or typeof(Ah_1.Perks) ~= "table"
    if Ai then
        return
    end
    local Ai_1 = um()
    local Aj = sW()
    for k, v in Perks.perkList do
        local Aq = k
        local Ak = sP.Unloaded or not tg("AutoUpgrade")
        if Ak then
            return
        end
        local Ak_2 = v[(Ah_1.Perks[Aq] or 0) + 1]
        if Ak_2 and Ai_1 >= Ak_2.Level and Aj >= Ak_2.Price then
            pcall(function()
                UpgradePerks:InvokeServer(Aq)
            end)
            task.wait(0.2)
            Ag_2, Ah_1 = pcall(function()
                return GetData:InvokeServer()
            end)
            local Ak_3 = not Ag_2 or typeof(Ah_1) ~= "table"
            if Ak_3 then
                return
            end
            Aj = sW()
            Ai_1 = um()
        end
    end
end
s7 = fns.fn1
uv = function()
    local AA = t9("AutoSellPets")
    local AB = t9("AutoSellWeapons")
    for k, v in tl do
        local AI = v
        pcall(function()
            SetAutoSell:InvokeServer(AI, AA[AI] == true)
        end)
        pcall(function()
            SetAutoSellWeapon:InvokeServer(AI, AB[AI] == true)
        end)
    end
    pcall(function()
        SetAutoSellDrops:InvokeServer(tg("AutoSellDrops"))
    end)
end
s8 = fns.fn194
folder = Instance.new("Folder")
folder.Name = "TempoEggESP"
folder.Parent = t3
s1 = {}
sX = fn400
sH = fn985
uh = fn381
s3 = function()
    local BF
    if not tg("EspEventEggs") then
        sX()
        return
    end
    BF = {}
    local function BG(jm)
        for i, child in jm:GetChildren() do
            local ProximityPrompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
            if ProximityPrompt and ProximityPrompt.ActionText == "Summon" then
                local Bw_1 = tg("EspAllEggs") or sH(child)
                if Bw_1 then
                    BF[child] = true
                    uh(child)
                end
            end
        end
    end
    BG(Eggs)
    BG(Weapons)
    for k, v in s1 do
        BG = not BF[k] or not k.Parent
        if BG then
            if v.Billboard then
                v.Billboard:Destroy()
            end
            if v.Highlight then
                v.Highlight:Destroy()
            end
            s1[k] = nil
        end
    end
end
E8_9 = sP:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = tb, Copyable = true }, "|", ti },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
te = {
    Info = E8_9:AddTab("Info", "info"),
    Main = E8_9:AddTab("Main", "gamepad-2"),
    Visuals = E8_9:AddTab("Visuals", "eye"),
    Player = E8_9:AddTab("Player", "person-standing"),
    Settings = E8_9:AddTab("Settings", "settings")
}
E8_24 = fn527
for k, v in te do
    if k ~= "Info" then
        E8_24(v)
    end
end
E8_9 = function()
    local CM
    local CN
    CM = nil
    CN = nil
    local Label, Label2, Label3, CR, CS
    local function CT()
        local BO = hookfunction ~= nil
        local BP = hookmetamethod ~= nil
        local BQ = getrawmetatable ~= nil
        local BR = setrawmetatable ~= nil
        local BS = getgc ~= nil
        local BT = getgenv ~= nil
        local BU = getreg ~= nil
        local BV = getconnections ~= nil
        local BW = firesignal ~= nil
        local BX = getcallbackvalue ~= nil
        local BY = setclipboard ~= nil
        local BZ = getcustomasset ~= nil
        local B_ = getnamecallmethod ~= nil
        local B0 = isexecutorclosure ~= nil
        local B1 = fireproximityprompt ~= nil
        local B2 = firetouchinterest ~= nil
        local B3 = WebSocket ~= nil
        local B4 = readfile ~= nil
        local B5 = writefile ~= nil
        local B6 = request
        local Ch = if B6 then 1 else 0
        local Cf = 298 * Ch + 2479 * (1 - Ch)
        local Cg = 3130 * Ch + 3176 * (1 - Ch)
        if not ((Cf * 934 + Cg * 4026 + Cf * Cg) % 16777213 == 13812452) then
            B6 = http_request
        end
        local B7 = B6 ~= nil
        local B9 = (debug and debug.getupvalues) ~= nil
        local Cb = (debug and debug.setupvalue) ~= nil
        local Cc = 0
        local Cd = { BO, BP, BQ, BR, BS, BT, BU, BV, BW, BX, BY, BZ, B_, B0, B1, B2, B3, B4, B5, B7, B9, Cb }
        for i, v in ipairs(Cd) do
            if v then
                Cc += 1
            end
        end
        local BO_1 = Cc / #Cd
        if BO_1 >= 0.9 then
            return tL("Full Support", sT)
        elseif BO_1 >= 0.6 then
            return tL("Half Support", sM)
        else
            return tL("Low Support", uq)
        end
    end
    CM = "Unknown"
    pcall(function()
        local Cs_1
        local Cr_1
        if identifyexecutor then
            Cs_1, Cr_1 = identifyexecutor()
            local Ct = Cs_1 ~= ""
            local Cu = type(Cs_1) == "string" and Ct
            if Cu then
                local Ct_1 = type(Cr_1) == "string" and Cr_1 ~= "" and Cs_1 .. " " .. Cr_1
                CM = Ct_1 or Cs_1
            end
        end
    end)
    local CU = CT()
    CN = os.clock()
    CR = function()
        local Cz = math.floor(os.clock() - CN)
        if Cz < 60 then
            return Cz .. "s"
        elseif Cz < 3600 then
            return string.format("%dm %ds", math.floor((Cz) / (60)), Cz % 60)
        else
            return string.format("%dh %dm", math.floor((Cz) / (3600)), math.floor((Cz % 3600) / (60)))
        end
    end
    local UserGroup = te.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = tN, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(tz("User", tN.DisplayName .. " @" .. tN.Name, sT), true)
    UserGroup:AddLabel(tz("UserId", tostring(tN.UserId), sQ), true)
    UserGroup:AddLabel(tz("Executor", CM .. "  " .. CU, sT), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(tz("Session", CR(), sM), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            ue(tN.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            ue("https://www.roblox.com/users/" .. tostring(tN.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = te.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(tz("Game", ti, sQ), true)
    Label2 = SessionGroup:AddLabel(tz("Players", "0/0", sT), true)
    CS = tostring(game.JobId)
    local CU_1 = #CS > 18 and string.sub(CS, 1, 18) .. "..."
    local CU_2 = CU_1 or CS
    SessionGroup:AddLabel(tz("Job", CU_2, sI), true)
    Label = SessionGroup:AddLabel(tz("Ping", "0 ms", sM), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            tV:Teleport(game.PlaceId, tN)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            ue(CS, "Copied Job ID")
        end
    })
    task.spawn(function()
        local CF_1
        local CE_1
        while true do
            task.wait(1)
            if sP.Unloaded then
                break
            end
            Label3:SetText(tz("Session", CR(), sM))
            Label2:SetText(tz("Players", #sG:GetPlayers() .. "/" .. tostring(sG.MaxPlayers), sT))
            CE_1, CF_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local CE_2 = CE_1 and CF_1 .. " ms" or "n/a"
            Label:SetText(tz("Ping", CE_2, sM))
        end
    end)
    local SocialsGroup = te.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = t_ })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            if setclipboard then
                setclipboard(s2)
            elseif toclipboard then
                toclipboard(s2)
            end
            sP:Notify("Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            ue(sY, "Copied website link")
        end
    })
end
E8_9()
E8_40 = te.Main:AddLeftGroupbox("Summon", "egg")
E8_40:AddToggle("AutoSummon", { Text = "Auto Summon", Default = false })
E8_40:AddDropdown("SummonType", { Text = "Summon Type", Values = E8_7, Default = 1 })
E8_40:AddDropdown("SummonPool", { Text = "Summon Pool", Values = E8_20, Default = 1 })
E8_40:AddDropdown("SummonAmount", { Text = "Summon Amount", Values = E8_34, Default = 1 })
E8_16 = te.Main:AddLeftGroupbox("Farm", "swords")
E8_16:AddToggle("AutoFarm", { Text = "Auto Farm", Default = false })
E8_16:AddDropdown("FarmZone", { Text = "Farm Zone", Values = tU, Default = 1 })
E8_16:AddToggle("AutoAttack", { Text = "Auto Attack", Default = false })
E8_16:AddToggle("AutoBuyDoor", { Text = "Auto Buy Next Door", Default = false })
E8_29 = te.Main:AddLeftGroupbox("Stats", "chart-column")
E8_29:AddToggle("AutoStats", { Text = "Auto Stats", Default = false })
E8_29:AddDropdown("AutoStatTarget", { Text = "Stat", Values = E8_18, Default = 2 })
E8_45 = te.Main:AddLeftGroupbox("Class", "users")
E8_45:AddToggle("AutoClass", { Text = "Auto Class", Default = false })
E8_45:AddDropdown("ClassSlot", { Text = "Slot", Values = E8_31, Default = 1 })
E8_45:AddDropdown("StopAtClass", { Text = "Stop At Class", Values = E8_2, Multi = true, Default = {} })
E8_13 = te.Main:AddRightGroupbox("Equip", "sword")
E8_13:AddToggle("AutoEquipBestWeapon", { Text = "Auto Equip Best Weapon", Default = false })
E8_13:AddToggle("AutoEquipBestEntity", { Text = "Auto Equip Best Entity", Default = false })
E8_42 = te.Main:AddRightGroupbox("Upgrade", "arrow-up")
E8_42:AddToggle("AutoUpgrade", { Text = "Auto Upgrade", Default = false })
E8_42:AddDropdown("UpgradeMode", { Text = "Upgrade Target", Values = E8_3, Default = 4 })
E8_12 = te.Main:AddRightGroupbox("Auto Sell", "badge-dollar-sign")
E8_12:AddDropdown("AutoSellPets", { Text = "Sell Pets", Values = tl, Multi = true, Default = {} })
E8_12:AddDropdown("AutoSellWeapons", { Text = "Sell Weapons", Values = tl, Multi = true, Default = {} })
E8_12:AddToggle("AutoSellDrops", { Text = "Sell Monster Drops", Default = false })
E8_12:AddButton({ Text = "Apply Auto Sell", Func = onApplyAutoSell })
E8_12:AddButton({ Text = "Load From Game", Func = onLoadFromGame })
E8_24 = te.Main:AddLeftGroupbox("Pickup", "magnet")
E8_24:AddToggle("PickupRangeEnabled", { Text = "Pickup Range", Default = false })
E8_24:AddSlider("PickupRange", { Text = "Range", Default = 50, Min = 12, Max = 200, Rounding = 0 })
local EggsGroup = te.Visuals:AddLeftGroupbox("Eggs", "egg")
EggsGroup:AddToggle("EspEventEggs", { Text = "ESP Event Eggs", Default = false })
EggsGroup:AddToggle("EspAllEggs", { Text = "ESP All Eggs", Default = false })
E8_24 = function()
    local MovementGroup = te.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = te.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    ul.Stepped:Connect(function()
        if sP.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local C__1 = tN.Character
            if C__1 then
                for i, descendant in ipairs(C__1:GetDescendants()) do
                    local C__2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if C__2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    ug.JumpRequest:Connect(function()
        if sP.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local Da_1 = tA()
            if Da_1 then
                Da_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    local CurrentCamera = Workspace.CurrentCamera
    ul.RenderStepped:Connect(function(lx)
        if sP.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local Dc_1 = tA()
            if Dc_1 then
                Dc_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local Dc_3 = tn()
            local Dd = tA()
            if Dc_3 and Dd then
                Dd.PlatformStand = true
                local Dd_1 = Vector3.zero
                if ug:IsKeyDown(Enum.KeyCode.W) then
                    Dd_1 += CurrentCamera.CFrame.LookVector
                end
                if ug:IsKeyDown(Enum.KeyCode.S) then
                    Dd_1 -= CurrentCamera.CFrame.LookVector
                end
                if ug:IsKeyDown(Enum.KeyCode.A) then
                    Dd_1 -= CurrentCamera.CFrame.RightVector
                end
                if ug:IsKeyDown(Enum.KeyCode.D) then
                    Dd_1 += CurrentCamera.CFrame.RightVector
                end
                if ug:IsKeyDown(Enum.KeyCode.Space) then
                    Dd_1 += Vector3.new(0, 1, 0)
                end
                local Dl = if ug:IsKeyDown(Enum.KeyCode.LeftControl) then 1 else 0
                if Dl == 1 then
                    Dd_1 -= Vector3.new(0, 1, 0)
                end
                Dc_3.AssemblyLinearVelocity = Vector3.zero
                if Dd_1.Magnitude > 0 then
                    Dc_3.CFrame = Dc_3.CFrame + Dd_1.Unit * Options.FlySpeed.Value * lx
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local Dm = tA()
            if Dm then
                Dm.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local Do = tA()
            if Do then
                Do.WalkSpeed = 16
            end
        end
    end)
    local function lT(lU)
        pcall(function()
            t0:SetGameplayPausedNotificationEnabled(not lU)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = t3:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not lU
            end
        end)
        if not lU then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(tN, "GameplayPaused", false)
            else
                tN.GameplayPaused = false
            end
        end)
    end
    Toggles.AntiGameplayPause:OnChanged(function()
        lT(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not sP.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                lT(true)
            end
        end
    end)
    local function ma(mb)
        if not mb:IsA("ProximityPrompt") then
            return
        end
        mb.HoldDuration = 0
        mb.MaxActivationDistance = 50
        mb.RequiresLineOfSight = false
    end
    local connection
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in ipairs(Workspace:GetDescendants()) do
                pcall(ma, descendant)
            end
            connection = Workspace.DescendantAdded:Connect(function(mj)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(ma, mj)
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    sP:OnUnload(function()
        lT(false)
        if connection then
            connection:Disconnect()
        end
    end)
end
E8_24()
E8_40 = function()
    local MenuGroup = te.Settings:AddLeftGroupbox("Menu")
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    sP.ToggleKeybind = Options.MenuKeybind
    local mt = 0
    local mu = tick()
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = MenuGroup:AddLabel("AFK triggers: 0")
    local function mw()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then
            return
        end
        ua:CaptureController()
        ua:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        mt += 1
        mu = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. mt)
        end)
    end
    local connection = tN.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(mw)
        end
    end)
    task.spawn(function()
        while not sP.Unloaded do
            task.wait(2)
            local DO = Toggles.AntiAfk.Value and tick() - mu >= 60
            if DO then
                pcall(mw)
            end
        end
    end)
    MenuGroup:AddButton({
        Text = "Unload UI",
        Func = function()
            sP:Unload()
        end
    })
    sP:OnUnload(function()
        if connection then
            connection:Disconnect()
        end
        pcall(function()
            tN:SetAttribute("AFKAutoAttackRequest", nil)
        end)
        sX()
        folder:Destroy()
    end)
    sK:SetLibrary(sP)
    sK:SetFolder("TempoHub")
    sK:SaveDefault("Evil Hello Kitty")
    sK:ApplyToTab(te.Settings)
    sK:LoadDefault()
    uu:SetLibrary(sP)
    uu:IgnoreThemeSettings()
    uu:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    uu:SetFolder("TempoHub/BackroomsSimulator")
    local m0 = uu:BuildConfigSection(te.Settings)
    uu:LoadAutoloadConfig()
    local function m1(m2, m3)
        local DS_1 = (m2 == "Toggle" and Toggles or Options)[m3]
        local DR_2 = type(DS_1) == "table" and DS_1.Type == m2
        return DR_2 and DS_1 or nil
    end
    local function m9(na, nb)
        local Type = nb.Type
        if Type == "Toggle" then
            return { idx = na, type = "Toggle", value = nb.Value == true }
        elseif Type == "Slider" then
            return { idx = na, type = "Slider", value = tostring(nb.Value) }
        elseif Type == "Dropdown" then
            return { idx = na, type = "Dropdown", multi = nb.Multi == true, value = nb.Value }
        elseif Type == "Input" then
            local DZ = nb.Value or ""
            return { idx = na, type = "Input", text = tostring(DZ) }
        elseif Type == "ColorPicker" then
            return { idx = na, type = "ColorPicker", value = nb.Value:ToHex(), transparency = nb.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = na,
                type = "KeyPicker",
                mode = nb.Mode,
                key = nb.Value,
                modifiers = nb.Modifiers,
                toggled = nb.Toggled
            }
        else
            return nil
        end
    end
    local function nd()
        local D1 = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local D2 = type(v) == "table" and type(v.Type) == "string" and not uu.Ignore[k]
                if D2 then
                    local D2_1 = m9(k, v)
                    if D2_1 then
                        D1[#D1 + 1] = D2_1
                    end
                end
            end
        end
        table.sort(D1, function(nl, nm)
            if nl.type ~= nm.type then
                return nl.type < nm.type
            end
            return nl.idx < nm.idx
        end)
        return { objects = D1 }
    end
    local function nn(no)
        local El
        El = nil
        local Em = type(no) ~= "table" or type(no.idx) ~= "string" or type(no.type) ~= "string" or uu.Ignore[no.idx]
        if Em then
            return false
        end
        El = m1(no.type, no.idx)
        if not El then
            return false
        end
        local Em_1 = pcall(function()
            if no.type == "Input" then
                if type(no.text) ~= "string" then
                    return
                end
                El:SetValue(no.text)
            elseif no.type == "ColorPicker" then
                El:SetValueRGB(Color3.fromHex(no.value), no.transparency)
            elseif no.type == "KeyPicker" then
                El:SetValue({ no.key, no.mode, no.modifiers })
                if no.mode == "Toggle" and no.toggled ~= nil then
                    El.Toggled = no.toggled
                    El:Update()
                end
            else
                El:SetValue(no.value)
            end
        end)
        return Em_1
    end
    m0:AddDivider()
    m0:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    m0:AddButton("Export Config to Clipboard", function()
        local Ep_1
        local Eo_1
        Eo_1, Ep_1 = pcall(t7.JSONEncode, t7, nd())
        if not Eo_1 then
            sP:Notify("Failed to encode the config")
            return
        end
        local Eo_2 = setclipboard or toclipboard
        local Eo_3 = type(Eo_2) ~= "function" or not pcall(Eo_2, Ep_1)
        if Eo_3 then
            sP:Notify("Your executor does not support copying to the clipboard")
            return
        end
        sP:Notify("Config copied to clipboard", 6)
    end)
    m0:AddButton("Import Config from Clipboard Text", function()
        local Eu_1
        local Es = Options.SaveManager_ImportSource.Value or ""
        local Es_1
        local Et = tostring(Es):match("^%s*(.-)%s*$")
        if Et == "" then
            sP:Notify("Paste an exported config into the box first")
            return
        end
        Es_1, Eu_1 = pcall(t7.JSONDecode, t7, Et)
        local Et_1 = not Es_1 or type(Eu_1) ~= "table"
        local Ey = if Et_1 then 1 else 0
        local Ew = 1667 * Ey + 3965 * (1 - Ey)
        local Ex = 2860 * Ey + 1484 * (1 - Ey)
        if not ((Ew * 3656 + Ex * 1686 + Ew * Ex) % 16777213 == 15684132) then
            Et_1 = type(Eu_1.objects) ~= "table"
        end
        if Et_1 then
            sP:Notify("That is not a valid exported config")
            return
        end
        local Es_2 = 0
        for i, v in ipairs(Eu_1.objects) do
            if nn(v) then
                Es_2 += 1
            end
        end
        if Es_2 == 0 then
            sP:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local Eu_2 = Es_2 == 1 and "" or "s"
        sP:Notify(("Imported %d setting%s"):format(Es_2, Eu_2), 6)
    end)
end
E8_40()
task.spawn(fns.worker)
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(worker6)
task.spawn(worker7)
task.spawn(worker8)
task.spawn(worker9)
task.spawn(worker10)
task.spawn(worker11)
task.defer(s8)
sP:Notify("Backrooms Simulator loaded")
end)(...)

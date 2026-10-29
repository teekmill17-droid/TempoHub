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
getgenv().TempoHoodSubtitle = "FARM RNG"
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
local gg
local gj
local fK
local f5
local fQ
local gb
local gi
local f1
local f4
local f7
local fS
local fY
local f0
local screenGui2
local fO
local _7LData
local gc
local function fn48(bm)
    gg = bm
end
local function fn69(bD)
    if gi and (bD.UserInputType == Enum.UserInputType.MouseMovement or bD.UserInputType == Enum.UserInputType.Touch) then
        local ih_1 = bD.Position - gc
        if ih_1.Magnitude > 4 then
            f4 = true
        end
        fQ.Position = UDim2.new(f7.X.Scale, f7.X.Offset + ih_1.X, f7.Y.Scale, f7.Y.Offset + ih_1.Y)
    end
end
local function fn142(Y)
    local ha_1, ha_2
    local g9_1
    for i, v in ipairs(Y) do
        g9_1, ha_1 = pcall(game.HttpGet, game, v)
        local hb = g9_1 and (function(ef, eg, eh)
            if type(ef) ~= "string" then
                return false
            end
            if #ef ~= eg then
                return false
            end
            local ei = 5381
            local ej = buffer.fromstring(ef)
            local ek = 0
            while ek <= eg - 4 do
                local el = buffer.readu32(ej, ek)
                local ei_3 = bit32.bxor(ei, el)
                ei = bit32.band(ei_3 * 33, 4294967295)
                ek = ek + 4
            end
            while ek < eg do
                local em = buffer.readu8(ej, ek)
                local ei_4 = bit32.bxor(ei, em)
                ei = bit32.band(ei_4 * 33, 4294967295)
                ek = ek + 1
            end
            return ei == eh
        end)(type(ha_1), 6, 2175009567) and #ha_1 > 200
        local hb_1
        if hb then
            local g9_2 = loadstring(ha_1)
            if g9_2 then
                ha_2, hb_1 = pcall(g9_2)
                local g9_3 = ha_2 and (function(ef, eg, eh)
                    if type(ef) ~= "string" then
                        return false
                    end
                    if #ef ~= eg then
                        return false
                    end
                    local ei = 5381
                    local ej = buffer.fromstring(ef)
                    local ek = 0
                    while ek <= eg - 4 do
                        local el = buffer.readu32(ej, ek)
                        local ei_1 = bit32.bxor(ei, el)
                        ei = bit32.band(ei_1 * 33, 4294967295)
                        ek = ek + 4
                    end
                    while ek < eg do
                        local em = buffer.readu8(ej, ek)
                        local ei_2 = bit32.bxor(ei, em)
                        ei = bit32.band(ei_2 * 33, 4294967295)
                        ek = ek + 1
                    end
                    return ei == eh
                end)(type(hb_1), 5, 248602996)
                if g9_3 then
                    return hb_1
                end
            end
        end
    end
    return nil
end
local function worker()
    while true do
        if fO then
            pcall(function()
                f5.Request(f5, "Roll", 1)
            end)
            task.wait(0.05)
        else
            task.wait(0.2)
        end
    end
end
local function fn224()
    if f4 then
        return
    end
    fK = not fK
    pcall(function()
        gb.Minimize(gb, fK)
    end)
end
local function fn241()
    local hE_1
    local hD_1
    local hC_1
    hD_1, hC_1, hE_1 = pcall(function()
        return f1.resolveLocal()
    end)
    if hD_1 and hE_1 then
        local SellShopModel = hE_1:FindFirstChild("SellShopModel")
        if SellShopModel then
            return SellShopModel:FindFirstChild("SellPrompt", true)
        end
        return nil
    end
    return nil
end
local function fn478()
    local hk_1
    local hj_1
    hj_1, hk_1 = pcall(function()
        return _7LData:GetData()
    end)
    local hl = hj_1 and (function(ef, eg, eh)
        if type(ef) ~= "string" then
            return false
        end
        if #ef ~= eg then
            return false
        end
        local ei = 5381
        local ej = buffer.fromstring(ef)
        local ek = 0
        while ek <= eg - 4 do
            local el = buffer.readu32(ej, ek)
            local ei_5 = bit32.bxor(ei, el)
            ei = bit32.band(ei_5 * 33, 4294967295)
            ek = ek + 4
        end
        while ek < eg do
            local em = buffer.readu8(ej, ek)
            local ei_6 = bit32.bxor(ei, em)
            ei = bit32.band(ei_6 * 33, 4294967295)
            ek = ek + 1
        end
        return ei == eh
    end)(type(hk_1), 5, 248602996)
    if hl then
        return hk_1.GameData
    end
    return nil
end
local function fn501(eo, ep)
    if type(eo) ~= "number" then
        return false
    end
    if eo % 1 ~= 0 then
        return false
    end
    local eq_1 = bit32.bxor(eo, 1540483477)
    local eq_2 = bit32.band(eq_1 * 403 + bit32.lshift(eq_1, 24), 4294967295)
    local eq_3 = bit32.bxor(eq_2, bit32.rshift(eq_2, 13))
    return eq_3 == ep
end
local function fn776(bl)
    gj = bl
end
local function fn887(aO)
    aO.AddButton(aO, {
        Title = "Join Discord for Dupes/Keyless Scripts",
        Description = "Copies the invite link to your clipboard.",
        Callback = function()
            if setclipboard then
                setclipboard(f0)
            end
        end
    })
end
local function fn920(bB)
    if bB.UserInputType == Enum.UserInputType.MouseButton1 or bB.UserInputType == Enum.UserInputType.Touch then
        gi, f4 = true, false
        gc = bB.Position
        f7 = fQ.Position
    end
end
local fI
fK = nil
local fL
local fM
fO = nil
fQ = nil
fS = nil
local fT
local uIStroke3
fY = nil
f0 = nil
f1 = nil
screenGui2 = nil
f4 = nil
f5 = nil
f7 = nil
_7LData = nil
local ga
gb = nil
gc = nil
local TweenService
local gf
gg = nil
gi = nil
gj = nil
local fX, fZ, f_, LocalPlayer, f6, gh, gk, gm, go, gq, gr, gs, gt, gu
local gp_1, gp_20
local gl_1, uIStroke2
local gx, gy
local fW = (buffer.fromstring("\x13; t'$5&1t= 19't$=8=:3t!$kt\x00!&:t-;!&t3&=:0t=: ;t57 !58t$&;2= z^^\x178=7?t ;t>;=:t <1t6=331' t &50=:3t7;99!:= -t5&;!:0u+_.ibC,/f+94w*((ac-{02..*)`uu(;-t=3.2/8/)?(954.?4.t957u\x1b9./;6\x17;).?(\x155=-;#u\x1c6/?4.w\x08?4?-?>u7;).?(u\x1b>>54)u\t;,?\x17;4;=?(t6/;/\x159*3=,(49;=x\x1c1+;7*<x;7(1=<x,7x;41(:79*<ysan-,5]*Rup^g{.dXa?8}4c2oI;J\x17243}\x12(/2?2/2.W\x1b/88}\x168$18..}{}\x19(-8}\x0e>/4-).W\x06\x1e14>6})2}\x1e2-$}\x194.>2/9\x00tWU]QDYCXRuYZYD\x05WUyUYpENN2cqztz?4qVxU5B@r/Pc?taEWMJC`MVAGPMKJG.LwHE=Q5JI{u[aJ07$wO5-h$ibX@q@]Q|dILBKH@KQ8!Q?ewv{HF:3;z1G@d0ffX5nS0RN\x05),-h\x07=:'*':';h\x05):#-<8$)+-hnnh\x05\x05_u4G}#u_*pV@WlKUPQv@WSLF@bH5]LJ^Sfyd1Cs5Sf%(&$)&{~ZHRU\\hOBW^3(^,FOXqY.#z9f8l?c3M]l/-J%!NuVDDOrDSWHBDctaueiWVRV$yyrWmDM(2BOILhQ7$9,:#%%Z9Bb4Awt5J-%:yKNlXe6M%PljIT6l%bGIFZG@Is!lTiF)71Yx&,G_*0x.#@;]2sjXl&raFLMPjM@I^AGZ)Xn%IKru8/1?#=5:4Ld;?#{nGGRDU(10$DT2APJNu*TiyKw608L6-M-1r1qjKHO[BZ^cN(DZ9+nM3/_^-$D@S1uCr?z/snvLKV[VKVJqL[!Tp@o]L$]D;+_C1%*NzC6d5dpdpe0e?PPJN=gxNp(p!%jl3po-$I*{z$H;7 5}@__Fu0J.fbcet$JmWT!_$QqzkOpZR&:1#-Ko%C_1Qd79ntcbCybc3feRwGb=*ryzYZK]D00[,Nb@6;C-U=TWybJrC+@*?Q2ActhXZW^oBK^,pRfPSO5%8CBCtTdr1OW#7xM*cLKAcLWVQfMLIADp*}?^qk/T=@TAD3,R#kZI^UOqQCc(A5u#xqbK-A*s/;cPBdhngNxk1zddl'+4-! em25r=O^&*t,;-Z2aJXoi_VVjHUWJNF[?b$+xT}iLfK:=zLY;5DN@}LQ]Lql&!L3cx4p[Tbb))RhGS,qs1pyivBCX\x17gBET_VDR\x17vAV^[VU[R\x17bGPEVSRDl]@LayTQ_VU]VLIInSuu@[#L(h8L[1XguDW@KQ%#_Nb22MXdG_3za}sb45Pvmse[hXI^^U|NRxS3ow&{wmeF{?-JT&-3bJPNZGEzoj2!4mdV7J*gGN;jP[QHF8.#K@a@CDPIQR[$epZ1Rd+Y$KSA$-DACHy]jyDYAH7W{H=RCm0aBlA/=cWd2uiZ/TN}38*7b@%[mqS&p(HLOl8lj^:,!GoCN={J]YL]FTs$2b$bkajZ0-)Y[Z)C}n9}`QL@luX]SZYQZ@t)mq?8jb0eB2(H@q$/=y(U@3vS/8&Q#*;CLq[%a2ahpQh>( =XX[{}TjVED{OPVr[RsxQ06J1myBXNE5ok#KE@IQX,JR3(ZyOVk]ORxPKW^RrZ[VJRaLz^m*7YjQpvkpgqWCER3fOHa4*gnjdo#1+2&RvLMSxkoI_HsTJONnCJ_aLWt=Ivc/2sYXpo|MZ^KZU5STfeoWTos=%LVe#kCdftQQaZRRYP7jIG?]m+Y+-yzrq&2X?4&.EN0vC&W+0J=_6*0:nN7,!&dBQ^C@QBU^SI#;PJ/rqe3o/%T85;5) E3!OW55CMaDBxeT8P=OQQ|ST^|SHINyRSV^m;.Nc;l9:5PoDRS=.DY9Dz/Ht]dSCnv%W71BjxEITHI_QZJP^d*Uw0.d1AAx{g+~WVLohGbL9G6[.p.EZbxMGw26f/dd(lVg;zr8}l-pZfWb,.P2`FPG|[E@AaLEP?Z-i#]j}mAnGSNLnGGRDU-MBH%L/6YBfW^u #2$=wR_#uTtTNI]HV9KJk/~OR^rkFCMDGOD^)RL2^NLgXhBNOgi@CPCH&7]=K.&6e[50aEIOMUI=@??b-lOIj8xBqqZaB@HDQLVMGwQBMPSBQFM@ZoLNFJ_BXCIy_LC^]L_HCNTe_TZ_XQ3/P#vP!,BFJB@B!%.<@Aag+?$btf(G]RE&X=zeBQNqVMWJNFAe-S=Oald)NnH^IrUKNOoBK^PX@R$y;.-6#;'$5]lmXPtI=[6W#_skWZBP1ZZPy?1FZ^?3:#UtxILLAFO|GX8#ljGa^hBpL]ITVi|yYpqem_YE!pBevo^MZQK0Tzk1Ln8}WTYD8@TIKuEGJC(hr%QtACTrIhmYJFNjym_-B-XeT=+d^yeoC^BI^3gzy5No#?wTt]VD#cvC&8;l$wdlHzhtoH[D@[kh4Hr9op{khG_K@RM{_cGm,[N(wuqnZ%$:IUMUX(,lX$3URzfyPQK;):pCl/t[CK8p2sQ@gQFB]WQ_h1fidH=*9*=<*(5JjD#$vdF}J_CFLN[JK|[@]NHJ+ 2{I{a-)_sg#LF%uOHUXUHUI\x1aw[HQ_NsLVLGI@]B7Ho42d@wTV^RGZ@[QvZYZG\x06NSAJO_B]DGE6aP!kzXI~UTQYOXS&3%-hYYEPz][FBLdFMLnrxTIU^If+d:?38qUG]ZSp]FQW@][ZhL^DCJiD_HNYDBCtPBX_VuXCTREX^_`LMMF@WblojJmU`QL@luX]SZYQZ@gVKGkr_ZT]^V]GqSAZT4_.10tma!dJCB_HjXDdC^HYzXBDRzXARZRYCjNZ_7bsnDCUdrgXD^C^XYhiYSl`DHNLeHKLE[KQj^_DFJ_BHxBQN#5= @Q:M1rMnbEFDYCBJQ?yDohJPV@gPQQJK\x14bJQMDH[dKo1qRF[YfsvCv1m?vMCLPgKJPVKHqED_e@WBQTUCuVG[XA@Qg]NQkCXDMAaIHEYA]^OY@=3FU%7rC^RqTGVVCBnJXBELx_RGNbFAFBFUJdJV|MHHEBK`IJXcGUOHAuR_JC_KVTk~{xaUq@]QfJIJW\x16>>)):%:!8>aPCT_E$#^3_D[DC#]XPDMYDFdMMXN_}LQ]jFEF[\x1apXC_VZuX[SiLL|GOODMQEXZdTV[R?6<-/,8< tQQaZRRYP|YYiRZZQXODVjuOoTUi_NNST]I<-:1(8:>uJVLQLJKzL]]@GNZxMN{EHXDpR__QRPXuCRROHAUyO^^CDMY\xcd\xcc\xcc\xcc\xcc\xcc\xdc?hJGGIJH@bSNBe_LS:45676:1|`jF[GL[YMPRmx}eRFBRDC@TIKtadTEGOECAYN]NYXNz@KE@GNbNOODBU>70>;0(lPPTcAPSGZXgrwaPCT_E|M^IBX`QBU^Do^IMXIrCTPETuDW@KQfWDSXB]KNNIX*)8.7 >#<9]HKEL+>=3:8-. )`]@XQOYQL\xd6Lr\x1cvQB]CU]@2$,1rUFY}W[ZqVEZr[z\r2I{+qM@X\xddj\xac\x02\x03`I\x9cy]IL\xda@0\xaa\xd1\xac\xf2`\x1f\x03\xa4\x81oH[D@WB +9~DE!*84?-r;p]VDBI[:1#,'5K@RGAFcYk?%$\xa4\x01\x96\x01\x17\x11|X0[8.5:\x1c3\xaaA/wP\x15"))
local fU = (buffer.fromstring("*6621xmm0#5l%+6*7 71'0!-,6',6l!-/m\x03!67#.\x0f#16'0\r-%5#;m\x04.7',6o\x10','5'&m/#16'0m#&&-,1m\x0b,6'0$#!'\x0f#,#%'0l.7#75%?Ju3:x(cuL};}QMXU-aoK*!PW8\x0f*,+e#*7e\x0105 6e$+!e\x0e <) 66e\x16&7,516ke\x0105 6e2,))e$)2$<6e' e$++*0+& !e$+!e+ 3 7e\"$1 . 51e,+e\n07*'*7*6k2..*)`uu=3.2/8t957u\x1b9./;6\x17;).?(\x155=-;#u\x1c6/?4.w\x08?4?-?>u(?6?;)?)u6;.?).u>5-465;>u\x1c6/?4.t6/;/iSTIDITIUnSD\t`GTKthaf#o+pcNxzKMSj&KvAV%Ha-jORvvyx\x1c&!<1<!< s\x17: 0<!7s0<#:67s'<s0?:#1<2!7ry=Zvi7I{x[YQ]HUOT^nH[TIJ[H_TYCycC4iNkdpNkZi%KwHuM:V^|HIRoX_TOIUzHm.TWvx7VBkq[YM%X*8Fb?1-)LIBHljPWJGJWJVhDWN@QUIDF@2Lhb,Ff)Uzdz^2qiu_6iDwTV^RGZ@[QaGT[FETGP[VL[a85et#x[6p%v+V3EVcUD|YRBQBIt1=d#KFh:.xa+F=DtLIjR(Z}7-l_{r^__TREh?}#8QxAV$wjGH8l*smiC7AY;dMEzz9kJINZC[N_ZkVQe#D+GRdNsY#&Oh_ww#r.Uz,7mxZ@FPyPTCPjeP!HtV+zIauexyA+hHA;xDOZZ#nZ[@j^ZF_pB&g:gWAjJxD0P78:.SH22dnAN*z{_X_[_LS}SOvd=ZH;,[HHK%Ofnjb38,N]q7BxITX`MNI@aV8M.Y_P4Fsqey*9RQOrV$R[z:tQQaTW]ujkNlFf*f9O(hkS5iGA-GcqdHuu2@CRD]7jc6PRGq/L_[8CItR_]5a9L4.lR^QMwQBMPSBQFM@ZRfRFi.ujrtZIA-n^S3Gs=2d[G]@][Zs:EE^Xw7^(.6PO%?XPe(4S5[pLGL^u]0cAZ_351=nuE.x$T3E=6*vvJq6%MUdTV[Rx-eN;;][yk}KP!HD4=B7.lQH,Qdkdjvo^[[VQX6Tb)]Kv8=Ps;%*U}:DY-#4jB\x13h`EPE#L+l1Q#qZC*p@)4=pLkz};sgha3bVEIA9^ZdU7ikBjBg%;Z{o_:uNV)?KwLroCBXITXYM@0j;=^xSaIj1@v*r7#u^FXt;fEGOCVKQJ@pVEJWTEVAJG]P@,u3]9Nw3eXE]TiXd[8c&J9.}n8@F!_G^AJ*.6PKVqLTXWVP]kVVMiXKMdYx9OGGIprdqD)u,rSEBDYO9JsTKn_dN8B{IPa.@&yKb}WR3uHUMD=2$mU6QxzbeB.6A7;iw&^Cc.h[qXYCz0,I.1dqhO2B-G/DNU@G;s4afKg\x1aaiLYLmZE^))cyT4IREY;y8@%iNFjl(iXEInTGX{eqQ6${9oV^BwPTb90KOND@jrjvwk4s@}v=0jNn%KQdA&gl.FhXW5YUBJ_P[pdNq:N;L}we+Vsy=mj%iT3$pR__QRPX:ky_/;p:^i2jQg!;!@bKHOfWDSXB?7*uQR[DtHj1Q*nsxX-jq2yrC^ReIJIT\x15vK.qgUq4nV/e3G-jY@&sDRDUnOrQ@VOhbi^(8E]xq;aSGC^+ 2!ucRE(=T)X@QYPEUx3][zcHKVf@VAz]CFGgJCVO:QwhfcW3oAEcdT65+!ny-v,[Owc5qfKhX/qQOC0Koo^COwZY^Wq6{/]{DxHgZb@.5V9zxITXH4%M$8(YYe8L9)HVqoc@Z$AjIKCOZG]FL|ZIF[XIZMFKQQa65nUWQZlu,CWjq;K{Q.)kgQ0N1pEibM@KLQsLJMWzE0)VphPg.&nGtzlQLT]1qBuMT3}bA2;^ou;Ndq)-[PBEQIvJa_wChD@QYk3wwS2Mzh_KO_IN.IgoO;OEaYkbu4aGO+jBYEL@oBAI]*+hDI(Y3#}_=1:)x8zgGM2}7JHjVKFC(]&SBskhjFEF[.oy&H17RHD1+A?BH!)X{UIs_TU;?R%o:f!i[H[4%62[_ZFCCY[B7kn%+x{le?G8}}T:.&[.RU1z$O!PTl1nH,,+p-72,S56E%Y*V&/QZhp8R%#H&fEGOCVKQJ@pVEJWTEVAJG]\x17'%(!\x10=4!x.KrKgJ&L6K{eevQ[ZG}ZW^IVPM:Xjh2g8xc@BJFSNTOEuS@ORQ@SDOBXwTV^RGZ@[QaGT[FETGP[VL{ARM6TK4.mFVrlC%KN{]3GoFEW$Iy_0NC&B8PduVsgrG`QL@luX]SZYQZ@ELbgvWp^LEGFFD[^07L@65A0WDu6aVJOGjMWFQEB@FpF@WJLMiXEInTGX[LhIuP)DSgU$v_^D4j/7s-_mvt#&t4]0iXEIe|QTZSPXSI:{PL6]~YGBCrYSRSlpd,C3aDfdlVQLALQLPnBQHFWSOB@F#.w3]28PrdFD]$}TKbXwF[W!@n}1R3[f}xsB@NuJVLQLJKm9MTan2g6VcROCtX[XE\x04cwR62be4hGJAF[yF@G]?f($[$mcWDH@?h/FqE[&7w$wPDY[eUWZSL97nOIcMfWJFHPwc;Y]XqGXO^YMPRpYYLZK4WD%Hrx[YQ]HUOT^yUVUH\tbAPLOVWFsLPJWJLMbVWL\x03`OBJN\x03jMGF[nH^IrUKNOh^IMRX^oKYCDMnCXOI^CED`B_HY]YDI`B_]@D.FMo3goPyQuf]IaeYTL(#X)3w]xhR^bDH@aDQDAl67rr.v[FPQFg]NQd]LQXiXEId|QTZSPXSId^MRi2iU_!YpIc^][E;WmJ*x&6G)jEBHjE^_XoDE@H|oHBC^dCNGPOITc^C[R2i}63NTNqWAVmJTQPp]TAmK]JqVHMLlAH]gVSS^YPuXCCXZz@SLhV/}%-f!Ee_^x!iw:)$P5MdBQ^C@QBU^SI#-/*6&5$%/?1r^C_TCcPUXDB{LZL]fGzYH^GCTB^]GT}^RP]h^VKyPM|WVS[x_ADErYP_VTUuYDXSDdWR_CE`DHNL}@@/SO1:(Qw(EZI%aiYH__T}OSz7`MUCYXc^HI^DO]/u6=4v^8fWDSXB{4kx@eTIEr^]^C\x02fD^XNnE_NY<7%!mb/NPlbTE}XSCPCHV@LMMBOLIP~C^FOs{fLR}_Ni_HLSY_T@]_`upUknaMKBEXYHInROIrOYXOlNYD[LYHIvSScXPP[Rh^O}TW_^IgKJJAGP5Y\x00\x00\x00\x00\x00\x00\xf8?WD[DLEX^dIHL%Uw[iKFFHKIA{DXB_BDEa^BXEX^_\xcd\xcc\xcc\xcc\xcc\xcc\xec?1550>3;!sLPJWJLMiVJPMPVW`VGGZ]T@xd~Y_BFH[AW[O^LBsZ[Ar-5pQRUAX@]ITVi|yjFGGLJ]&()3:-;/;9+;2)c__[lN_~DOADCJnOLK_F^qFRVFPW,9-&48vGTCHRsBQFMWdUFQZ@vGTAPFzKXOD^G@F]ZS`QFBWFr^]^C56'1(rORJC_TFGs|PSPMlXKGO\x81E\xb1\x01xITX%3;&MFTI\xb9\tDMlVEZQR@V,\x88s)z@SL~YJUkZGK\xff\xff\xff\x7fO<\x8a\x11bXKT+\xcb%\xb4yEHPz^JO-\xa2\x14\x07;29eJW$/=[PBXSAbdc$)p7<.g]o>7<U^LCHZ92 GL^\xcc\x01(Y\xf0M\x05\x07,\x03w\x12\xe6K\x004\x02%\x16r_"))
local fR = (buffer.fromstring("\t!:n=>/<+n':+#=n>'\"' )n;>qn\x1a;< n7!;<n)<' *n' :!n/-:;/\"n><!(':`DD\r\"'-%n:!n$!' n:&+n,'))+=:n:</*' )n-!##; ':7n/<!; *o;''# i||!2$}4:';&1& 6!0<='6='}0<>|\x120'&2?\x1e2 '6!\x1c<4$2*|\x15?&6='~\x016=6$67|>2 '6!|277<= |\x1a='6!5206\x1e2=246!}?&2&<  $'n{{3= <!6z7;9{\x157 !58\x195' 1&\x1b;3#5-{\x128!1: y\x061:1#10{&1815'1'{85 1' {0;#:8;50{\x128!1: z8!5!)9#:((>/2?attbjokkkcmnhcklo2UNW!N0+[S5lZjr^Gb-G=^$NIa1bkyj0{eem&),&.e1*e&*5<lC.b!V@uR_x@Oi^?Q9m[DtUGI0o@MEAeBHIT~I[M^HYPcbz6_)o&UC*ODZIvz@oP=D=O*ShL^DCJiD_HNYDBCQn+r*nXv6L[Or_PR=()bCnS0=7UdFWpFQUJ@FD#@pkq{w#ssPwFLzn;#ko.sAYJ]mFVTwKJ@HMFPPlV4}m/*BK+8&/-KY{Q*/8J(=T$&TypLtVG`VAEZPVAcjzU-r]sM7^VTaSl:qp1wcg^h?:zlVQLALQLPwLDDOFs!+Q#l66D@t6?s$hL+Xyknvs{JW[cNMJCyF5!ud]cIhdBBf=BXC*3qcli2O:tJrVD^YPdCN[RT[o%1Sak2-eab^gD!Talb904k@uDYUm@CDMMe0h(*+Ive.H,[+jmrZ0zHyZf8$T{WVV][L]}nTtiWN+t8)KtKMTHPg=w=nlusVFc\x01'410{u\x06099{u\x05':3<!{xlbrl,EMgycoW(IuYDSqC_)BH)nD0RX-;O#Gp?J%H$&GMfEM54uWFaW@D[QWJg%JsT:bpi9=^?^z@7m6YfHV]n_BNv[X_V7O{C55D[zp?2zgS!B8cZ_--,r#dTV[RcNGRMfIJC[phwj$5zYi,[mJD($=,SoFG]IH?O8,K4#_sb}mUD0dLHD5ID[}K6KYtHE]Htp4T@xU^Qjt0U--LE1pjrBSRkQ;!NvP[APGRg9W-ViH:=8dt]16?[_-FSgnn]8noS^F0lQ#S@k]IrFiF7T6my!%;_w4%&RJ(?##'$mxx3>$48%3y00x2?\x1c\x01&`'1`!MYOvT@]_`up;)J&eNOq{u}]*GWR]CfuNXZiA{gDFNBWJPKAfJIJW\x16OYhhe7]gI0D)W#SKnSNV_!FN&Ci%ZDOf!MCN+TKDZr3PRUza`CMHmYXC@CMHoCBJEK@xhl2;Ayc;RcyxdUHDS.(i%%]%y!.tO1@sAAb:=W3s&qK{AW_BS#gGIV[?hNiN,^M(,N#XH5n%[GO&}_ECU|UQFUw67RiOZl&B6Q0j:R-msARcY^CNC^C_|^CAC&M?WEuE3O!w+$rQZIdkHY?+8Si9B?24j,CilM^}X+-+aJWL0cUDDY^WC&5X=:=4cJ8@7Kr0HK3UBN1|M^IBX3g5YMJ*wu8x8}NIfLwsoCdi3vBCX\x17rFB^G\x17uRDC\x17g[VYCDD[Q1$0Dn_BNyUVUH\tRBNbsN51q:RGJ=9@mEC.%7{4J0E:5W7$(L&Q*Ok;9e*tsIZVwVURF_Gg;(4E-zn=b^{N5yI#ly-kFzKVZvoBGI@CK@ZtUvR46yL00cg9eJ^CAcJJ_IXquY:dQZILs_gp6CBx4qXYCsPwo,^A=&QJ^xQF]J/?&$E=eKWmAJKWqn:^{)7;G2m2szXKk5V*<4)R.sdxz;P*q2iZ#E^2Q)[iN1pJAOJMD)y9*d+GR_m1sZ}Aa10]0}[HGZYH[LGJPQmiYK2t6x2{&[ggSRIsVATGBCU#^wq=V+M?l3I&2ufAKJWmJGNYF@]x.-N2[uj*(yl>3m3H(07%Q4_#=8=wBUs9Ct)7eTIEbXKT{4;Jq3g_h$i&{MW6@fNUI@LlDEHTL}t0}m7,%nRWj*`PR_VgJCVLiGmi-j2=rpvC^P{XIUVON_jUISNSUTZS1$W=o$]ITVi|y}Ghv;*^mz*qi9eTk!tEVAJP]b{53@^VY[}@;V?2;[LK@[]AjFZ]DtDc8-H+=}l{QEXZepuTUy#[$]J=j}U8FrEmO^\x7fZMXKNO~XOOYFwxx)niZvLMgq)zM^pr)d@3BVrqvGRjIKCOZG]FL|ZIF[XIZMFKQ[PBzEC%t7d)z0t.Jz0:r,dfl:o:;{%0Dt*qlj%-Z-Z3wuDW@KQrOJ:&sYZv5iJDvDhBUFUBCUDO}J.01j2M&G^E|FGt].4Q7YN,,J}5TR^[Iq]^]@Wri3p$G[VXw}[9zabEVIE3_OWoK9Ti&n:Wd;=?6=$_rUL8QIO;X7k&GRkl\x142!$%n`\x13%,,n`\x102/&)4ncYkJuHOR}Z0IgrrF3NBDd@TQW(6g2}XlcXfnIS9:|JB_mDYhCBGOU^VndbHUxWZQVKiVPWM!;pwgwCI{AF[V[F[G\x14vMDUGG]ZS2*32.%'5&tuADa8OOOyCPO6-hY^ieQCeoXAqs`GMLQkLAH_@F[5TchCJYJH_NYNg73lXma|^DBTsDEE^_\x00r]XRZy[AGQvA@@[Z\x05wX]W_e^T_cROCW-[S,-@sAuWFaW@D[QW86,APvW]MRW?e/OkNo!hnQeNGTGERCTRf}&{3,|S_WmucDE)o3.Ncb$2:'1rsYAp[!=Log]ZGJGZG[dGILMZnKK{NM%UBX*})FGnSNV_lGPKYlpaAI~BCIADOYYiq1q!jmVXWK|PQKMPSG.7wF[W{bOJDMNFMWrC^R~gJOAHKCHR\x7flKA@]g@MDSLJW`sT^_Bx_R[LSUHvTEuTBRT_UP_EBi^JN^HOdt{!c6yeoC^BI^C8$gvoXSYXOnIXMMXYzNOTVZORXhRA^vAJ@AVwPATTA@rHzizC/pcHj&L2;0o:-$flI1gjPWJGJWJVmPGoC^BI^~MHEY_1$3)<98*+=7-~SIJV[CuH^_H`QL@w[X[F\x07zixTIU^IiZ_RNH~E_IBoDKHFONx[WUXdXUMQFv[CUONuH^_HKNEQR_Q_AOP=$=(=(%4=<8{ARM]%G-}jZBVKIkBBWAPnLVPFfMWFQEQLNlEEPFWrCTPETHQ(kvTEbTCGXRTq@]QgPQQJKdC]XYoHJLCdCXeSD@_USwF[W`LOLQ\x10J^CAcJJ_IXaWFt]^VW@hXZW^oBK^bRP]TeHAT7<  !5;46dAAqJBBI@\x00\x00\x00\x00\x00\x00\xe0?G_@K@YGCnrhOITP^hKYOzKX^\x9a\x99\x99\x99\x99\x99\xb9?j^MAIcoK@_WGE@VZvQB]/(V?dUHDcYJUqmgKVJAV\x9a\x99\x99\x99\x99\x99\xa9?bEVI\x04vjc\x9a\x99\x99\x99\x99\x99\xd9?|XTRP*Kj]ZQJLP}LIIDCJDO]xxuCxTI^|NRr^__TREiEDDOI^LXEGxmhqW[Z[YM\\HUWh}xrCPETBPSBTM.j[H_TN(2'?&)bS@UDR{J]YL]j[LH]LeTGP[Ab_BZSbKJPduHUMDaEIOMbVEIA`ZIV\x1a\xb6s vJG_FPXE\xb9\xfe\x14\x06~DWH%\xbf\xcfUq^RZ{ARMeYTLj@LMjV[C\xbd\r\x02\r3N\xad\xfew^_E\xcc\xb1R\x01\x9c\x86+\x1ca[HWiS@_xQR@=4?{TI*#(r]@(#1%.<7)066(JTBQZT6=/-;;\x90\x01\xb8\x0b*9^\x14?\xffx;\x10D7@\x041p\xbe\x1e\x08OV"))
local fP = (buffer.fromstring("*6621xmm0#5l%+6*7 71'0!-,6',6l!-/m\x03!67#.\x0f#16'0\r-%5#;m\x04.7',6o\x10','5'&m/#16'0m#&&-,1m\x11#4'\x0f#,#%'0l.7#7UZ_Y;J)zhh30,,(+bww*9/v?1,0-:-+=*;76,=6,v;75w\x19;,-94\x159+,=*\x177?/9!w\x1e4-=6,u\n=6=/=<w59+,=*w\x19<<76+w\x116,=*>9;=\x15969?=*v4-9-0,,(+bww*9/v?1,0-:-+=*;76,=6,v;75w\x19;,-94\x159+,=*\x177?/9!w\x1e4-=6,u\n=6=/=<w59+,=*w\x19<<76+w\x0b9.=\x15969?=*v4-9/?%<..8)49grrdlimmmekhnemji6N!bg&gY31)u9pdy3!C%a13\x15! ;t\x04=7?t\x01$t\x17&5 1'trt\x07188@#CF3{6].#hk]:=aDpEg$,\x0732)f\x16/%-f\x136f\x054'2#5f`f\x15#**oyDq6%-#$/YFPUGW1#kQVKFKVKWlQF\x0bbEVIvjcElu8bpz)3hdoIm.ScxWtS&@`TUN\x01dPTHQ\x01cDRU\x01qM@OURw_ue-dmGA6wN#!2BH;0eTIEeCP_BAPCT_RH$OHpgyJ7lD!YGm,aeIDH9FwLknKK{@HHCJRxGD4^X(0;B,(oHR0s=FZA[j,GrMwds_^^USD.0u2^yIWD{Nh?{_XzUICo:[Bo+W]!@SkTHRORTUnIEQFe}3mv+iPzbBWP6TC(D0Ham[t}}LQ]eHKLElw8P#Oo5!1b]FKo^9tUtH%KeVPdTJjL@A@BV:J7mqw,*%WGd/*Z@f*}@]DW+IWzm#LeRDRCxYdGV@Yf;EVhz@qlkJCBmOU3Mse*9$3sDRDUnOrQ@VO!}_3(uAf(LD/rsc[rPp)5P:G?)!<mp+E?XpjP2f:EJ/9t9zK[GIoPy{1h0ddPQJfIDLHlKA@]g*n*&VPJZ20yT+yE4,*g+bNMNSkMU!Or4;f6e7q]5VMP%pRrm7.Xt,}8oM@@NMOG4^3n}jblS3GTt?7.5a=2EQk}R^nTGXjW=s+F[XrtS^k8)X8(_3ah&ulC_S34DSV;=ikOYJw*pePzDnWr1x?PhA),x&#o}(qYB^W[[Va#u_=Zh+XN(k?W3wb+Vyv^(Ygd^MRo33S*]4-8?v7y4uZ%[/N@&aBT%8NQhKIAMXE_DNiEFEX\x199KSUBPKT)/nF@[5cR5>,b&rEd:9}i768,.J{IYKi;QtuYf(*ZgiVJPMPVW5(jUA8n}N(Sq:T4rk+nlmvl4VgBBrIAAJCwLP)H1qpCfLYp0[rORRefxql@]JhZFUdUR4q0iz$;DpmLA-=:=U-JgH253(/&OVWTyw=M+%uIM_XZkcRY9IHzD5.:<+uWtXbcE4YwcOrh*x}k(i)Jf@D:{AuDYUrH[D4hQp[#2HZ?H2!RNQBPVdQe^tXYYRTCrS_n#&G$F$;)yK&7voX=&&a)eUDSSXqC_(vY7G!3fU.j}8V.,+.,EASpT@EXJ56.1K.bPnI6,(n.C[xs2PZv7m[SN|UHyRSV^X@,AG3[Qv.?OF7R.lW^JWUw^^K]LNk(!^oR-HTmE1LK9h^i&&)?<*<5)8<4/xj$:^$Z-8^3kX{D:iydT9[ax,a.a9cr}z*TywQNS]9%-IpUST\x1auOHUXUHUI0ayUJC\x1a~SIYUH^gz^LVQXlKFSZ4b5=vo5u0h{adPg4jkBCYvC.8BHeaIU+r7xTQ+TQtZ=%yn_BNxONNUT[P+WdrXsZ;FQNFQ&sg@]FU@A[NCnCFHABJA[rYaSihA7%&7!8hROWmhq7%n,SryNO5{]mL%bSNBzWTSZN)l-4feE_!DM)EIy^m{JYNE_X8+H:{wD8;]&K$UuZLsz,%.c!s,eg87*SIf+Ja7?c/UD7{',>fZu6+.0oCgnn@g#3b}iHm;%s`GMLQkLAH_@F[#$2zG&xmnt;fQGQ@{ZgDUCZ3fI?R5Xpo+zzNgVKGjr_ZT]^V]G&3O%,0)Cy^c{WTWJUP,GQ[UYBHwNy?bC]$vvjsBGGJMDl^LE(xzLdD^S/;1`QBWFPL_VdE&b&oAC}!65jVc,'5lB0Io#}VmUMHy5z9%pVOQEXZxQQDRCHF+]=q6/4mQsnoKYCDMnCXOI^CEDvw(jaW9Z4?-Q!Gcs$F4#5O6:R&na/t5y[JATQ[%[aJgWu*Yj$a{6IgVERYCmKdNBh+lHpO)yt#apOUODJCD]%B*U[g]{FCQTL2'$*#42,33x8YjA$2u#6/adXYS[^UCCd:Rf]k9YeDE7t~YGBCrYSRSLDQM8n)Ea:k%.<W}]+3wlU1R:+q/r6YISgSa{=G*kUZ@5+dEXzYjkXN__BELXD%VopfL*),cCGyNRW_rUO^I]ZX^h^XORTUuCR`IJBCT9hdSZ36PYd:{DXB_BDEaWe7TUfd[$#%1:(G;rl&Y1PyS]9[E,B]cGKMOEzi5={)Jbh#6@-7<.PKi:%Gubo}a!(p5[~YD_LYXBWZwZ_QX[SXBjKHO[BZc9$&w5wK)f#iUT^VSXNN-ABug-8w1h_CFNiEDLCMyOI^CEDjo[HDLFY1vBcePyaZYMPRpYYLZK5,F9yPteOCBbmagBj3I@F*&zuPP`UV5]x;7=1__;yjMGF[aFKBUJLQe0jCBXn7TUqYE$BhMQwM^A5]x)Wc]}4,obuDSWBSw+tv.uLlnmoJJzAIIBKw3aWk(fgSRIdSRRIHeIJITqYB^W[DE8=KjCLRlHZ@GNm@[LJ]@FGkO]G@I}ZWBK6y[5uCJCERrGD3QmLF^A^MXOAF^EDK**{hOEDYcDI@WHNS`LOLQDsRv{Dwz^wUDcUBFYSUctI6qbEONSiNCJ]BDY`QL@vA@@[Z}F)gp_ZZr_DSUB_YX<7%p{6^]VWq1dvZ[[PVA#C/D]fo^COxTWTI\x084QCsUCToHVSRr_VCeCP_BAPCT_RHTXDCD{xA?mbytBJWeLQ`KJOG{JYNE_$w;hX)`V^CqXEt_^[SgKJJAGPXa9l-`CRNMTUDrH[DeJGLKVtKMJPcGKMOh_^^EDwSA[\\UaFK^WlHZ@GNz]PEL]Y]LI^OR@CA+/+#0616<-+yHUYz_L]]HIrPJLZsZ^IZ]ITVt]]H^OdJSTc@@CERyHUYnBAB_\x1e@TIKi@@UCRmHHnYXXCB1qYB^W[tYZRbE[^_iNLJEiYH__T}OS90#!/%-&6zNOT\x1bhKRUSGZXfVTYPpDE^t@DXAn_BNv[X_VuEGJCr_VCy[VVX[YQ}B^DYDBC)?7*kgR,`_CYDY_^osiNHUQ_nZ[@|_FAzfl@]AJ]rTCuHUMD333333\xc3?{\x14\xaeG\xe1z\xa4?thbNSODSqNRHUHNOMYDFyliCWJHwbgvWTSG^F2&<2,$+pMPHA-$`LMMF@W~RSSX^IdXUMQFGDGV@Y6zmBNF;#WyPPESBYZXE_^JNUXAAhYJ]VL~[[k^]{JYNE_',>i7RdAAqDGHKZLUo[HDLnR_W_oROW^45<1)#5= yCPOfZWOaPMA \xabs\"f\x16r\x11B\xf2\xfd\xf2iHr\x1fiUX@nIZEpJYF}TWEgBQHi@A[\xf2\xc5f\xcdoFG]\xf3Y\xa9\x02bHDEzKVZrep&-?Q[I38*JAS@KY-&4=6$cYX}Gu^UGaJ[{As3:1,\x01\x1dF<R\xa0n\x13LdG\xff=S\n]$\x0f\x1b\x1fu"))
local fN = (buffer.fromstring("5))-.grr/<*s:4)5(?(.8/>23)83)s>20r\x1c>)(<1\x10<.)8/\x122:*<$r\x1b1(83)p\x0f838*89r0<.)8/r\x1c9923.r\x143)8/;<>8\x10<3<:8/s1(<h-6#Rlt!==9:sff;(>g. =!<+<:,;*&'=,'=g*&$f\x08*=<(%\x04(:=,;\x06&.>(0f\x0f%<,'=d\x1b,',>,-f$(:=,;f\x08--&':f\x00'=,;/(*,\x04('(.,;g%<({;''# i||!2$}4:';&1& 6!0<='6='}0<>|\x120'&2?\x1e2 '6!\x1c<4$2*|\x15?&6='~\x016=6$67|>2 '6!|\x1277<= |\x002%6\x1e2=246!}?&2gSRI\x06vSTENGUC\x06gPGOJGDJC\x06sVATGBCUePm93uKDne5aB[nDOeRG[^TVCRSdCXEVPRi7Mi*T8CQ2qrc.HP3+)mfh2;J^pU:!sx[YQ]HUOT^yUVUH\t&i(v57Y2[T;LM.ExEw2=zzNI}erh{sUCToHVSRr_VCP0H1o)WjvX3Y&@)v7KU;&1U[=MynAT\x195*3?)z.2?z34,3.?z6341z.5z#5/(z963*85;(>tK_B@bKK^HY4gh(&LB5QO*12w}+:eFxa}mzVFYqHH+o^COyNOOTUmGGwc?0pyZUnghe[+!Z}xpo8fl,b,eUDSSXqC_O[.UR%UmMb8*PeC*iHUllKRBY&YSr\n/).`\x04)3#/2$`&/2`\x0450%3o\x0b%9,%33`\x13#2)043fDUrDSWHBDvz_j5{Nitr_NZ%H}hnTGQ}T4srIwzKXOD^Jt4Et6A4?.]$-]KV8)+(@(G@T$DN4imfJKK@FQQ=Cy3gY$0)tx%m{tZFuF+pjE=bUjPJYCQWMBCTFiY/7UaS.umaQIn2ISJOEsMxyzRbFJLN}c]f*qg/gIY9)YYZm$_{IB(i-Ub3xTwDSUHB@M`MHFOLDOU/}mr*$cmYrVD+j6G1s6=/q=zS,xq_KA6W}B5RW[7Ul4}tM&7zR:O@KYM@]m0R]YM4m2obvPKi$L5CgsCviJ2PrlN_TADNIWOLq?:-}/%Km&;gHv$dwk97mwosBQFMW4d7OO9iCg,g3{2K-^-j+xiw{J2,&<7%z1Ijzp[eh}u6]RYs6&j{-#=DbfMGHOfbTE}XSCPCHb#BXZ%v6oSX3[S#NQa{le(Wz@SL#=PwCnQ)]iZWsmuTobLzKpM}p;AM=OFMalvHj%wCG@#+SJTjVQXDjYU^82q7ly_KVTk~{X:k5&+pZn-(1#(aC/b%E;si57t]^L*mFS(4$UA3ytN.^ak-$YaSvNFwoD{ONU\x1ayV[SW\x1asT^_BY{d6jMZ?;HhM*bSRzKXOD^17!1fDeDtQzA#%5#BAWKF&oF?EnLVPFaVWWLM\x12`OJ@HLky8w=xuM+_u8:RpFWWJMDP:r!_d?zs.Jq}8LD;5cx)*{bQFUFQPF3aK(b;Nq{5.8rXM/5SD,_zUYhL^DCJ~YTAH##G!.G^uhA@s*H{&^SGvhYJ]VL7vKgG$4?qxr/rXwZJkrGg.#&(uDW@KQf9(j!z6;B$/}sJzA.3j3YONf.%7?6kgl)9RT$pW2b5thue}$yE{+5*6621xmm&+1!-0&l%%m'*\t\x143u2$u492 [8(+2LQ_EO;AV]:ks(EAoYd&sbp@BOFwZSFSni)vw$y]$CS#I5SH{Ej[H_TNLuOBif%:d[StuQK_syl8f6pJMP]PMPL\x1fwJ]HAQZkGg3NSiW(i,=#?>7+?(27*Rr&2_wn.UV,sBHnS[gVKG`ZIV8d=]5*owuP!t+)Ok0f}|`z][FBLZ1zE-hO6f}kb4JW](kSK@RA1$JbBqT!NUiT-p$M1}hj66ey|YCD|QI_EDGU3pXmLSJ@ACT#qS^^PSQY-*Drz77{RZv5l*Pr{mlCNEB_}BDCY)?Wkm+^n$oNv/9qxBEXUXEXDgEXZXP*,E*TXH)Wj8i^H^OtUhKZLU3l!i5eVlu[8I#kISUCcHGDJCBzsvS/M_]@SospcD_bTCGXRT5ZZB!)fd(*Jxl.{ARMN?5_k@U7-f?tlQhjP_e+rH[DJm7m5mR8YcClna_dI]7VSGZXgrw!6{Pr8syQXH9t3L*YR@).F,W&)Ue2}iz;J6Iw}xxd~Y_BFH6ap$^bNZGAR^c+S92 {Idq?xIU+OAoXC=o[D8+dGEMATISHBrTGHUVGTCHE_hRA^GKGi:kO+EF3ASba8)xsQ@gQFB]WQP6{qT4rg3ZqmBVKIkBBWAPfi3ASKhk3,80rQS[WB_E^TdBQ^C@QBU^SIar(c}}u>14>6})2}>2-$teQPK\x04vAFMVPLY=k[WwM*)]ITVi|y&]z[pV&xW^IYA]oH[DXdtO)D/@ze2]_qN3,xUM[A@{FPQFDkySqdCfIWfOL^0t6TC.}{r$M;N_4%zE_EN@IBBg6j7w;.A9-?oPLVKVPQlXGLfVq?NDp/pKQGLaJEFHA@a_Olh]XmCJKVApLAIAwAPPMJCWxBEXUXEXD\x17uNGVDD^YPtHE])!ci#y!THGC6B$i^BGOhDEMBLxNH_BDE3(;899zeD-7]n1aDGmnHCYH_}(33]V.UMX]yjMGF[aFKBUJLQly#aCY_InYXXCB\x1do@EOGaB@HDQLVMG`LOLQ\x10aPMAaGT[FETGP[VL>)/cP7I.Wuq/5liTq@]QdhaZHg-h,wytzYHTWNO^kTHRORTUCWJHwbg_ze@nDa-[~JKP}JKKPQ|PSPMT_M=0,N._Sg;:Bpz@GZWZGZFaZRRYPaWFt]^VW@HyF^P%fWRR_XQzSPBZ-a. 2ELU$$#[f2}Xq@EEHOFuNQKizbkRXPNKxIZO^H!XkZGKg~SVXQRZQKyHUYulADJC@HCYzKVZvoBGI@CK@ZrHOR_RORN\x1duH_cKPLEIiA@MQI[zKNNCDMhE^^EGyH[N_Ia!A57GalJYVKHYJ]V[AsEMPbKVgLMH@eFTT_bTCGXRT~C^FO@$:dP#VnLVPFaVWWLM\x12q@EEHOFsHFIUi^H^OtUhKZLUkQB]NM{o5&o0|ZIF[XIZMFKQo^MZQKUyM7;~OR^}XKZZONVFSWGNZWXHKoKYCDMy^SFOuCRjODTGT_AdFW`KJOGQFMK_B@bKK^HY`]@XQ.)4Fy5./(?C{/y5DO]&ZEu39wvR^XZs^]ZSPDY[yPPESBsQ@gQFB]WQWFYXSDQQXA*{5.E^CzEeYT[AwPFAq@]QiDG@I9> 5)105%yEDNFCH^^qED_\x10c@Y^333333\xeb?\n\xd7\xa3p=\n\xe7?ffffff\xd6?qS^^PSQY2$55(/&2oH[D\t{gn\x9a\x99\x99\x99\x99\x99\xe1?]KSNB^LN333333\xd3?hM^G5beE~bx_YD@NfYE_B_YX\xf6(\\\x8f\xc2\xf5\xe8?fJKK@FQ-+%3'):~A[AJDM|PMZxJVg]VX]ZS`WCGWAFuODJOHA~I]YI_XINNBEWla@CDPIQ/><4>8:eTCGRCIKRU@I38*z@L*48+>&yH[LG]`QBWFPkVKSZLO^HQp@BOFFETB[uIDLD~RQROqUY_]/$6O|@MUhA@Z\\!\xe9\x08`QL@\x9f\xb3\xeeQ\xbb\xb2\\BdKGOeAUPyHUY\x81f\xe5\x03\xfcAr\x1esTGX~.\x86\x99\x8d\xa4\x85\xf2fWJFgNOU\x82\xf8pB0;)<7%83!yB]ZQCzA^1:(+ 2HCQ5>,jPQ`Z[#4!CJA\x1c\x02qH)2 #+e\x1a\x066\x19T\tW\x18\xdcsJt"))
local fJ = (buffer.fromstring("7++/,epp->(q86+7*=*,:-<01+:1+q<02p\x1e<+*>3\x12>,+:-\x1008(>&p\x193*:1+r\r:1:(:;p2>,+:-p>;;01,p\x0c>):\x12>1>8:-q3*>*^.+[VdnbD<  $'n{{&5#z3= <!6!'1&7;: 1: z7;9{\x157 !58\x195' 1&\x1b;3#5-{\x128!1: y\x061:1#10{95' 1&{\x1500;:'{\x1d: 1&2571\x195:531&z8!5!<  $'n{{&5#z3= <!6!'1&7;: 1: z7;9{\x157 !58\x195' 1&\x1b;3#5-{\x128!1: y\x061:1#10{95' 1&{\x1500;:'{\x075\"1\x195:531&z8!5!rQS[WB_E^TdBQ^C@QBU^SIQAq4rH&!jzHX5Bm;tP[/xjX.3NOt]rQS[WB_E^TdBQ^C@QBU^SIGz*$CtSju1cM:ZzGw{?a:pa,KoAHITCrNCKCuCRROHAUjNn/5nDReB/BoF!/NJ:2C*B{ZscAP`AWGAJ@EJPW4_k;]1xN?k]=rrSI#u6/n5N_T$aPdPQJw@GLWQMJRk9hN08Y]gr6JjJtKY&oG^Zv5^iA.VoC^BI^~MHEY_%FztWJLe33mO]-^:%A=A0Vo;F,ZEmIECAhEFAH}e1^Tbk6-]ydaq2*}gEhFbBr_7J6%!oKYCDMnCXOI^CED6*&&,@u4o}#K!Pu/nhOsei)k_^EzCIA_ZGg5KM}[JgZghIW02h8Z9buMD6r#0O[FDzJHELW^(dw#vuHS@!).,Q.j(b@.!GUK4O!~OJJG@I|GIFZN0R!@klCA+gm}UJHn3l(p.$2vkF[ML[z@SLy@QLE*Uq]KYg%!(lQNIvwpRlDR|M^IBX1_gBIXrU1?y;N8OjX+aL%N==:rS@.&qVEZ{vP=hjLO=lJL*5si7TcI4mL]=)q9dzFTQTTlUnEc.VB7rN8:(e,f0bfpXM)d@@X7qcfW@DQ@!@R05tJ*VIxRiGX5Be%DAH9Y3HVC}MOBKzW^KH!_^ku9_}:ide{ji&GAB$]mP5|MZ^KZhVQ[PHi!A:]Q}_e)1IGQ}SHaJY(myJ][FLNC&6R{j=dG^b%Tl8Hx=W*o-4hF%(w[FQsA]nUu,ZF#4R5mF+@,SIB(xZ&*L@Nwu]FZS_aW_[P]^Vh2kId8yXi58?7UI%e]xo@LD;!#1ChzxFf3QxFIpsjv_CvecR5ZFlxBQNlDT%suq=:x)KKnO^d^)+C1XPxEB:,g]NQOK$w@VZx7]raJTDw1%5_z:@*y1;oFM_c,satb,;UbzJc(QsuCfAAjItJ3548k_^E\nxOHCX^B3l(Gm%rL58NehtO,-_$BwX]]uXCTREX^_I0CDAFe$nz-L!M.=vKt}L_HCY0Up3xPd&9q1WIO*P)i0IclvNM%{]K\\g@^[ZzW^K){s4aSu0zhXZSjza,:fEGOCVKQJ@pVEJWTEVAJG]vo8-$Qv#I{XTV[g[VNRECne-QV{:JUp9CI30^jN;vGPTAPWVEUuXr8qn))PFj[hVhc[kGQMAY=iVYjy{AS?u#xjFLT=4#4d/6[u+<7%)$bzy]R!kI,yik&xVRP$/_^9Me3wTV^RGZ@[QaGT[FETGP[VL&DDJE[[qSBeSD@_USC?IRPAAlp9t}Ys6lNs_{JW[|FUJoOxMTSZOEFJ#a.O)za8KbEVIoApB&qnyG:g6#@KU3YDr^^:)lPMKpM[ZM,Kn^v{h[iP=Zzh.vP1XvUW_SF[AZP`FUZGDUFQZWM:-,l4KfWDSXBk)T+A[qFDC.x30/WtSf#IyVZRV79rT=TFs&Hesf=Gbn)z[e;HCQojK50{5cm$J{*O0=.H^rC}!uSDrORJC%D4pmIF]f44a81s-C0zI^XEOM@m@EKBAIBX.^FR:%nhLCWJHwbgA*5%E_#?dsGMp2BsK2a\x17 40 6151n1Yy;NCh-=qZCxpl395(+588*W:bC9(c-HkE;g19i1{ZY^JSK&P4z*4#!,O:_wt2()0{AFMK:nS-ehgjl{@-4%YQTbdaKGF^(_o9?X1PT4!rw$J}{!!iHKLXAYWyLK.?kaocE0Kg]{wd[G]@][Z]W:B6lT}x:W03UkkIXhMXMUDl*{V_?yS:LvEw+~RSSX^I&,]&D1N-J(wkq4}:eYTLYmeZQAU=lyL{fRsn9*rXNF[^zld[S7KSO;BmNQ=@usPRZVC^D_UeCP_BAPCT_RHdPQJfIDLHlKA@]FuUd#LJnj[[GRx_YD@NfDONDeG4t18wVURF_GjK-?=FvG]5?ryN{yHUYulADJC@HCYH-4Q(D3%. S/!d6XkTkbYrdPsEPF{L@lI^KX]\\sde+=bgo5nVwdCIHUoHEL[DB_![n&DHnbRCTT_vDXc)t4zZ6l?q9ub_BZS8/-Gr#N0}dtT2J4qWAVmJTQPp]TA#w_$-.MDO]3H0opvEx/I80lbnlfkBCYtU7)Xs](x/9LPO1yHUYnBAB_\x1eN:Fjjg9viCWJHwbgdW{jDCL7U!kZ|G]K@MQ#k:4auy%=_9*!3m#GMW?]yWjE6I2(BVKIkBBWAPn+yDx*oInLVPFaVWWLM\x12`OJ@H38*IHp+=;iWBK&T]jO[FD{nkqGDLw#N:*M\x0b16+&+6+7d\t%6/!0vUW_SF[AZPw[X[F\x07gKJJAGPhZ){){;{DnSNV_.F7i/%Ge+h6uVT\\PEXBYStX[XE\x04lZKvXQPMZvQ[ZGZLsWE_XQr_DSUB_YXvBCXuBCCXYtX[XExLMV{LMMVWzVUVKeAUP]$@EF*h)Z;/\x14%6!*0sPT{#j8Ts^FPJKpM[ZM&w)veBHITnIDMZEC^oCBBIOXL=pSm(6uZV^JS0c-_NNXdeYXRZ_TBB;F1yj|]K[JQHLQWV-6aGQF}ZDA@`MDQbT]]bY^A|^UT]cY^CNC^C_\x0cdYNtRDShOQTUuXQDxEX@I*ui0XW.]|YYiRZZQXVz_fJWK@WwDALPV|MZ^KZhVQ[PHq@WSFW/8DH!?dC]XYnELCJHIw[FZQFfUP]AGfJKK@FQFqDcM{XIUVON_iS@_`GTKtSHROKC-(87)7>645lI]@B|LNCJ@2;8)?&;O)_BrkO]G@I}ZWBKeTIEr^]^C\x02${JW[mZ[[@AuWFaW@D[QW<-+)Yhe:]SgSRIvOEMSV97)7798$+5#//-&'% /'tVG`VAEZPVGSNLnGGRDUeZ@ZQ_V48~[[kPXXSZ|LNCJ{V_JyIXOODm_CfWJF~SPW^dTERRYpB^rP]]SPRZ\x00\x00\x00\x00\x00\x00\xd0?gRQdZWG[yFZ@]@FGkIDDJIKCgQ@@]ZSG|C_EXECBuDYUrH[Dw@GLWQMV8<:7.-88rVQVRVEZyMLWkHQV\x9a\x99\x99\x99\x99\x99\xc9?RF[Yfsv`ZQ_Z]TVB_]bwrqVEZ%R04'%/7*+eYTLPGFEQLNqda{D^DOAHqPFAGZL~UD5:?}g[[_hJ[l]JN[Je`TGKC?4&s3D{^^n[X&<004?D_GHOXxCYODrFUYQ+(9/6(+:,5@[Z]J,/>(1~C^FOhRA^d^MRJ^J^kBCYbFRWta\xd1\x0eiTWW:9+=\r:\x992\xdb\x96s*\xcb\x1fr\x10i@CQz@GL(>6+\x1e\xe0O/zSPB:,$9Z\x8f\xb3\xaaAVCnTUmWep_BuONYR@/$6,%.rHz_TFU[Qf/d(!*mB_DIZ&oE\"\xc8\x0bNCUQ-!\rB\x8cI\x0c+\x0e"))
gl_1, go, TweenService, gt, gu, LocalPlayer, f0, fY, gs, _7LData, f5, f1, f_, gk, gb, gr, gm, gq, fX, gh, fZ, gp_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local gn = 24
repeat
    local gv_1 = (gn * 11 + 9) % 14 + 1
    if gv_1 <= 7 then
        if gv_1 <= 4 then
            if gv_1 <= 2 then
                if gv_1 <= 1 then
                    gx = ({
                        "maachiknai",
                        "dzveph",
                        "leblibz",
                        "wfqzcsqu",
                        "ert",
                        "noq",
                        "cmojvfudeo",
                        "ufdnvkj",
                        "dzfgnrfqkn",
                        "otkts",
                        "jmsfzbcfv"
                    })[gn % 11 + 1]
                    local gw_2 = gn % 3 + 2
                    gy = (gx:reverse())
                    local gw_3 = gx:len()
                    local gz_1 = (gy:rep(gw_2))
                    if gw_3 <= gz_1:len() then
                        _7LData = require(go:WaitForChild("7LData"))
                        f5 = _7LData.Net
                        f1 = require(go:WaitForChild("FarmRuntime"))
                    else
                        go = require(_7LData:WaitForChild(_7LData))
                        f1 = go
                        f5 = require(_7LData:WaitForChild(require))
                    end
                    gn = (gn + 9) % 56
                else
                    local gw_4 = {
                        "knkk",
                        "vvyolzleyhld",
                        "ivizoxvqirs",
                        "gdzp",
                        "ywiwwyxdku",
                        "neyyxlbmo",
                        "exjadtivoln",
                        "mvefgg",
                        "hlligjbx",
                        "ozmwbgftucis"
                    }
                    if gw_4[(gn * 86 + 52) % 10 + 1] < gw_4[(gn * 86 + 52) % 10 + 1] then
                        go = require(fX:WaitForChild(fX))
                        f_ = fn478
                    else
                        f_ = require(go:WaitForChild("Economy"))
                        fX = fn478
                    end
                    gn = (gn + 23) % 56
                end
            elseif gv_1 <= 3 then
                local gw_5 = (vector.create((gn * 3 + 4) % 11 + 1, (gn * 7 + 9) % 13 + 1, (gn * 2 + 8) % 17 + 1))
                gx = (vector.create((gn * 1 + 2) % 11 + 1, (gn * 5 + 7) % 13 + 1, (gn * 4 + 4) % 17 + 1))
                gy = (vector.create((gn * 2 + 6) % 5 + 1, (gn * 1 + 1) % 7 + 1, (gn * 5 + 3) % 9 + 1))
                if fn501(math.abs((vector.angle(gw_5, gx, gy))) - math.abs((vector.angle(gx, gw_5, gy))), 544454170) then
                    gk = {}
                    gh = function()
                        local hv, hw, hx
                        local hz_2
                        local hy_2
                        hy_2, hz_2 = f5:Request("GetUpgradeTrees")
                        local hA = not hy_2 or not (function(ef, eg, eh)
                            if type(ef) ~= "string" then
                                return false
                            end
                            if #ef ~= eg then
                                return false
                            end
                            local ei = 5381
                            local ej = buffer.fromstring(ef)
                            local ek = 0
                            while ek <= eg - 4 do
                                local el = buffer.readu32(ej, ek)
                                local ei_17 = bit32.bxor(ei, el)
                                ei = bit32.band(ei_17 * 33, 4294967295)
                                ek = ek + 4
                            end
                            while ek < eg do
                                local em = buffer.readu8(ej, ek)
                                local ei_18 = bit32.bxor(ei, em)
                                ei = bit32.band(ei_18 * 33, 4294967295)
                                ek = ek + 1
                            end
                            return ei == eh
                        end)(type(hz_2), 5, 248602996)
                        if hA then
                            return
                        end
                        hx = {}
                        hw = {}
                        hv = function(az, aA)
                            local hn = not (function(ef, eg, eh)
                                if type(ef) ~= "string" then
                                    return false
                                end
                                if #ef ~= eg then
                                    return false
                                end
                                local ei = 5381
                                local ej = buffer.fromstring(ef)
                                local ek = 0
                                while ek <= eg - 4 do
                                    local el = buffer.readu32(ej, ek)
                                    local ei_15 = bit32.bxor(ei, el)
                                    ei = bit32.band(ei_15 * 33, 4294967295)
                                    ek = ek + 4
                                end
                                while ek < eg do
                                    local em = buffer.readu8(ej, ek)
                                    local ei_16 = bit32.bxor(ei, em)
                                    ei = bit32.band(ei_16 * 33, 4294967295)
                                    ek = ek + 1
                                end
                                return ei == eh
                            end)(type(az), 5, 248602996) or aA > 6
                            if hn then
                                return
                            end
                            local hn_2 = (function(ef, eg, eh)
                                if type(ef) ~= "string" then
                                    return false
                                end
                                if #ef ~= eg then
                                    return false
                                end
                                local ei = 5381
                                local ej = buffer.fromstring(ef)
                                local ek = 0
                                while ek <= eg - 4 do
                                    local el = buffer.readu32(ej, ek)
                                    local ei_13 = bit32.bxor(ei, el)
                                    ei = bit32.band(ei_13 * 33, 4294967295)
                                    ek = ek + 4
                                end
                                while ek < eg do
                                    local em = buffer.readu8(ej, ek)
                                    local ei_14 = bit32.bxor(ei, em)
                                    ei = bit32.band(ei_14 * 33, 4294967295)
                                    ek = ek + 1
                                end
                                return ei == eh
                            end)(type(az.id), 6, 2175009567) and az.costs
                            if hn_2 then
                                if not hw[az.id] then
                                    hw[az.id] = true
                                    hx[#hx + 1] = az.id
                                end
                                return
                            end
                            for k, v in pairs(az) do
                                hv(v, aA + 1)
                            end
                        end
                        hv(hz_2, 0)
                        if #hx > 0 then
                            gk = hx
                        end
                    end
                else
                    gh = {}
                    gk = function()
                        local hv, hw, hx
                        local hz_1
                        local hy_1
                        hy_1, hz_1 = f5:Request("GetUpgradeTrees")
                        local hA = not hy_1 or not (function(ef, eg, eh)
                            if type(ef) ~= "string" then
                                return false
                            end
                            if #ef ~= eg then
                                return false
                            end
                            local ei = 5381
                            local ej = buffer.fromstring(ef)
                            local ek = 0
                            while ek <= eg - 4 do
                                local el = buffer.readu32(ej, ek)
                                local ei_11 = bit32.bxor(ei, el)
                                ei = bit32.band(ei_11 * 33, 4294967295)
                                ek = ek + 4
                            end
                            while ek < eg do
                                local em = buffer.readu8(ej, ek)
                                local ei_12 = bit32.bxor(ei, em)
                                ei = bit32.band(ei_12 * 33, 4294967295)
                                ek = ek + 1
                            end
                            return ei == eh
                        end)(type(hz_1), 5, 248602996)
                        if hA then
                            return
                        end
                        hx = {}
                        hw = {}
                        hv = function(az, aA)
                            local hn = not (function(ef, eg, eh)
                                if type(ef) ~= "string" then
                                    return false
                                end
                                if #ef ~= eg then
                                    return false
                                end
                                local ei = 5381
                                local ej = buffer.fromstring(ef)
                                local ek = 0
                                while ek <= eg - 4 do
                                    local el = buffer.readu32(ej, ek)
                                    local ei_9 = bit32.bxor(ei, el)
                                    ei = bit32.band(ei_9 * 33, 4294967295)
                                    ek = ek + 4
                                end
                                while ek < eg do
                                    local em = buffer.readu8(ej, ek)
                                    local ei_10 = bit32.bxor(ei, em)
                                    ei = bit32.band(ei_10 * 33, 4294967295)
                                    ek = ek + 1
                                end
                                return ei == eh
                            end)(type(az), 5, 248602996) or aA > 6
                            if hn then
                                return
                            end
                            local hn_1 = (function(ef, eg, eh)
                                if type(ef) ~= "string" then
                                    return false
                                end
                                if #ef ~= eg then
                                    return false
                                end
                                local ei = 5381
                                local ej = buffer.fromstring(ef)
                                local ek = 0
                                while ek <= eg - 4 do
                                    local el = buffer.readu32(ej, ek)
                                    local ei_7 = bit32.bxor(ei, el)
                                    ei = bit32.band(ei_7 * 33, 4294967295)
                                    ek = ek + 4
                                end
                                while ek < eg do
                                    local em = buffer.readu8(ej, ek)
                                    local ei_8 = bit32.bxor(ei, em)
                                    ei = bit32.band(ei_8 * 33, 4294967295)
                                    ek = ek + 1
                                end
                                return ei == eh
                            end)(type(az.id), 6, 2175009567) and az.costs
                            if hn_1 then
                                if not hw[az.id] then
                                    hw[az.id] = true
                                    hx[#hx + 1] = az.id
                                end
                                return
                            end
                            for k, v in pairs(az) do
                                hv(v, aA + 1)
                            end
                        end
                        hv(hz_1, 0)
                        if #hx > 0 then
                            gk = hx
                        end
                    end
                end
                gn = (gn + 51) % 56
            else
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gn, 19), string.byte(tostring(f5))), 22), 4272770611), 2622054403), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gn, 19), string.byte(tostring(f5))), 22), 22196684), 729499954))), 2622054403), 729499954) == bit32.rrotate(bit32.bxor(bit32.lrotate(gn, 19), string.byte(tostring(f5))), 22) then
                    fZ = fn241
                else
                    gp_1 = fn241
                end
                gn = (gn + 9) % 56
            end
        elseif gv_1 <= 6 then
            if gv_1 <= 5 then
                gx = ({ "kyprssqnk", "waa", "ujbrpuco", "lulylytelmi", "ntu", "mxlguy", "wtrl", "tnbbfm" })[gn % 8 + 1]
                local gw_7 = gn % 3 + 2
                gy = (gx:reverse())
                local gw_8 = gx:len()
                local gz_2 = (gy:rep(gw_7))
                if gw_8 >= gz_2:len() then
                    fY = gb:CreateWindow(540)
                else
                    gb = gs:CreateWindow({
                        Title = "Farm RNG",
                        SubTitle = "Tempo Hub",
                        Image = fY,
                        TabWidth = 160,
                        Size = UDim2.fromOffset(540, 400),
                        Acrylic = false,
                        Theme = "Dark",
                        MinimizeKey = Enum.KeyCode.RightControl
                    })
                end
                gn = (gn + 51) % 56
            else
                if (gn * 2 + 7) * 16 % 3 == ((gn * 2 + 7) * 16 + 3) % 3 then
                    gr = {
                        Farm = gb:AddTab({ Title = "Farm", Icon = "sprout" }),
                        Crates = gb:AddTab({ Title = "Crates", Icon = "package" }),
                        Settings = gb:AddTab({ Title = "Settings", Icon = "settings" })
                    }
                else
                    gb = { Title = "Farm", Icon = "sprout" }
                end
                gn = (gn + 9) % 56
            end
        else
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gn, 12), string.byte(tostring(fY))), 29), 218238397), 118792749), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gn, 12), string.byte(tostring(fY))), 29), 4076728898), 1626516689))), 118792749), 1626516689) ~= bit32.rrotate(bit32.bxor(bit32.lrotate(gn, 12), string.byte(tostring(fY))), 29) then
                fY = fn887
            else
                gp_1 = fn887
            end
            gn = (gn + 51) % 56
        end
    elseif gv_1 <= 11 then
        if gv_1 <= 9 then
            if gv_1 <= 8 then
                local gw_9 = (vector.create((gn * 1 + 1) % 11 + 1, (gn * 3 + 10) % 13 + 1, (gn * 15 + 4) % 17 + 1))
                if fn501(vector.dot(vector.floor(gw_9) + vector.ceil(gw_9 * -1), vector.floor(gw_9) + vector.ceil(gw_9 * -1)), 544454170) then
                    gl_1 = game:GetService("Players")
                else
                    gs = game:GetService(game)
                end
                gn = (gn + 9) % 56
            else
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gn, 24), string.byte(tostring(gm))), 27), 4068844685), 149496156), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gn, 24), string.byte(tostring(gm))), 27), 226122610), 294272079))), 149496156), 294272079) ~= bit32.rrotate(bit32.bxor(bit32.lrotate(gn, 24), string.byte(tostring(gm))), 27) then
                    gp_1 = game:GetService("ReplicatedStorage")
                else
                    go = game:GetService("ReplicatedStorage")
                end
                gn = (gn + 37) % 56
            end
        elseif gv_1 <= 10 then
            local gw_10 = (vector.create((gn * 7 + 5) % 11 + 1, (gn * 4 + 7) % 13 + 1, (gn * 8 + 11) % 17 + 1))
            gx = (vector.create((gn * 7 + 5) % 11 + 1, (gn * 8 + 1) % 13 + 1, (gn * 5 + 3) % 17 + 1))
            if vector.dot(vector.cross(gw_10, gx), (vector.cross(gw_10, gx))) + vector.dot(gw_10, gx) * vector.dot(gw_10, gx) == vector.dot(gw_10, gw_10) * vector.dot(gx, gx) then
                TweenService = game:GetService("TweenService")
            else
                go = game:GetService(game)
            end
            gn = (gn + 9) % 56
        else
            if gn * 102039225 + 3 + 4 <= gn * 102039225 + 3 + 4 + 3 then
                gt = game:GetService("UserInputService")
                gu = game:GetService("RunService")
                LocalPlayer = gl_1.LocalPlayer
                f0 = "https://discord.gg/K7Qxnxkk46"
            else
                gu = game:GetService(game)
                f0 = game:GetService(game)
                gl_1 = LocalPlayer.LocalPlayer
                gt = LocalPlayer
            end
            gn = (gn + 37) % 56
        end
    elseif gv_1 <= 13 then
        if gv_1 <= 12 then
            local gv_2 = (vector.create((gn * 6 + 7) % 11 + 1, (gn * 6 + 8) % 13 + 1, (gn * 10 + 9) % 17 + 1))
            local gw_11 = (vector.create((gn * 6 + 4) % 11 + 1, (gn * 7 + 7) % 13 + 1, (gn * 15 + 6) % 17 + 1))
            if vector.dot(vector.cross(gv_2, gw_11), (vector.cross(gv_2, gw_11))) + vector.dot(gv_2, gw_11) * vector.dot(gv_2, gw_11) == vector.dot(gv_2, gv_2) * vector.dot(gw_11, gw_11) then
                fY = "rbxassetid://91400086538074"
            else
                gl_1 = "rbxassetid://91400086538074"
            end
            gn = (gn + 23) % 56
        else
            local gv_3 = {
                "lxblrzu",
                "vnwvjacqb",
                "pfjkkdijov",
                "iylhxqehgwt",
                "upliisq",
                "vad",
                "npf",
                "xtijtyyk",
                "cyocwftz",
                "vrvgbudykhj",
                "waydhtfd",
                "oigqek"
            }
            if gv_3[(gn * 70 + 18) % 12 + 1] < gv_3[(gn * 70 + 18) % 12 + 1] then
                gq = function()
                    local textButton, gN, frame3, gP, gQ
                    local screenGui = Instance.new("ScreenGui")
                    screenGui.Name = "TempoLoader"
                    screenGui.ResetOnSpawn = false
                    screenGui.IgnoreGuiInset = true
                    screenGui.DisplayOrder = 2147483647
                    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                    local gS = gethui and gethui()
                    local gT = gS or game:GetService("CoreGui")
                    screenGui.Parent = gT
                    local blurEffect = Instance.new("BlurEffect")
                    blurEffect.Size = 0
                    blurEffect.Parent = game:GetService("Lighting")
                    local frame4 = Instance.new("Frame")
                    frame4.Size = UDim2.fromScale(1, 1)
                    frame4.BackgroundTransparency = 1
                    frame4.Parent = screenGui
                    frame3 = Instance.new("Frame")
                    frame3.AnchorPoint = Vector2.new(0.5, 0.5)
                    frame3.Position = UDim2.fromScale(0.5, 0.5)
                    frame3.Size = UDim2.fromOffset(460, 0)
                    frame3.AutomaticSize = Enum.AutomaticSize.Y
                    frame3.BackgroundTransparency = 1
                    frame3.Parent = frame4
                    local uIListLayout = Instance.new("UIListLayout")
                    uIListLayout.FillDirection = Enum.FillDirection.Vertical
                    uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                    uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    uIListLayout.Padding = UDim.new(0, 8)
                    uIListLayout.Parent = frame3
                    gQ = function(y)
                        local uIStroke = Instance.new("UIStroke")
                        uIStroke.Color = Color3.fromRGB(0, 0, 0)
                        uIStroke.Thickness = 2
                        uIStroke.Transparency = 0.1
                        uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
                        uIStroke.Parent = y
                        return uIStroke
                    end
                    local function gT_9(B, C, D, E, F)
                        local textLabel = Instance.new("TextLabel")
                        textLabel.BackgroundTransparency = 1
                        textLabel.Size = UDim2.fromOffset(460, C + 6)
                        textLabel.Font = D
                        textLabel.Text = B
                        textLabel.TextSize = C
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        textLabel.TextTransparency = E
                        textLabel.LayoutOrder = F
                        gQ(textLabel)
                        textLabel.Parent = frame3
                        return textLabel
                    end
                    gT_9("Made Tempo Marketplace && MM", 26, Enum.Font.GothamBold, 0, 1)
                    textButton = Instance.new("TextButton")
                    textButton.BackgroundTransparency = 1
                    textButton.AutoButtonColor = false
                    textButton.Size = UDim2.fromOffset(460, 24)
                    textButton.Font = Enum.Font.GothamSemibold
                    textButton.RichText = true
                    textButton.Text = "<u>" .. f0 .. "</u>  (click to copy)"
                    textButton.TextSize = 16
                    textButton.TextColor3 = Color3.fromRGB(120, 160, 255)
                    textButton.LayoutOrder = 2
                    gQ(textButton)
                    textButton.Parent = frame3
                    local function gU()
                        textButton.TextColor3 = Color3.fromRGB(170, 200, 255)
                    end
                    local MouseEnter = textButton.MouseEnter
                    MouseEnter.Connect(MouseEnter, gU)
                    local function gU_6()
                        textButton.TextColor3 = Color3.fromRGB(120, 160, 255)
                    end
                    local MouseLeave = textButton.MouseLeave
                    MouseLeave.Connect(MouseLeave, gU_6)
                    local function gU_7()
                        if setclipboard then
                            setclipboard(f0)
                        end
                        textButton.Text = "<u>" .. f0 .. "</u>  (copied!)"
                        task.delay(1.5, function()
                            textButton.Text = "<u>" .. f0 .. "</u>  (click to copy)"
                        end)
                    end
                    local Activated = textButton.Activated
                    Activated.Connect(Activated, gU_7)
                    local gU_8 = gT_9("Join for Dupes and Keyless Scripts. Dupes will always be announced and never gatekept in Tempo.", 13, Enum.Font.GothamMedium, 0.2, 3)
                    gU_8.TextWrapped = true
                    gU_8.Size = UDim2.fromOffset(420, 34)
                    gN = gT_9("Tempo Bypassing", 14, Enum.Font.GothamMedium, 0.05, 4)
                    gN.Size = UDim2.fromOffset(460, 18)
                    local frame2 = Instance.new("Frame")
                    frame2.LayoutOrder = 5
                    frame2.Size = UDim2.fromOffset(300, 6)
                    frame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    frame2.BackgroundTransparency = 0.85
                    frame2.BorderSizePixel = 0
                    frame2.Parent = frame3
                    local uICorner2 = Instance.new("UICorner")
                    uICorner2.CornerRadius = UDim.new(1, 0)
                    uICorner2.Parent = frame2
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.fromScale(0, 1)
                    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    frame.BorderSizePixel = 0
                    frame.Parent = frame2
                    local uICorner = Instance.new("UICorner")
                    uICorner.CornerRadius = UDim.new(1, 0)
                    uICorner.Parent = frame
                    gP = true
                    task.spawn(function()
                        local gK = 0
                        while gP do
                            gK = gK % 3 + 1
                            gN.Text = "Tempo Bypassing" .. string.rep(".", gK)
                            task.wait(0.35)
                        end
                    end)
                    local gV_11 = (TweenService:Create(blurEffect, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = 18 }))
                    gV_11.Play(gV_11)
                    local gV_12 = { 0.35, 0.55, 0.72, 0.9, 1 }
                    for i, v in ipairs(gV_12) do
                        local gV_13 = (TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromScale(v, 1) }))
                        gV_13.Play(gV_13)
                        task.wait(0.55)
                    end
                    gP = false
                    task.wait(0.25)
                    local gV_14 = TweenInfo.new(0.4, Enum.EasingStyle.Quad)
                    for i, descendant in ipairs(frame3:GetDescendants()) do
                        local gW_5 = descendant:IsA("TextLabel") or descendant:IsA("TextButton")
                        if gW_5 then
                            local gW_6 = (TweenService:Create(descendant, gV_14, { TextTransparency = 1 }))
                            gW_6.Play(gW_6)
                        elseif descendant:IsA("UIStroke") then
                            local gW_7 = (TweenService:Create(descendant, gV_14, { Transparency = 1 }))
                            gW_7.Play(gW_7)
                        end
                    end
                    local gW_8 = (TweenService:Create(frame2, gV_14, { BackgroundTransparency = 1 }))
                    gW_8.Play(gW_8)
                    local gT_11 = (TweenService:Create(frame, gV_14, { BackgroundTransparency = 1 }))
                    gT_11.Play(gT_11)
                    local gT_12 = (TweenService:Create(blurEffect, gV_14, { Size = 0 }))
                    gT_12.Play(gT_12)
                    task.wait(0.45)
                    blurEffect.Destroy(blurEffect)
                    screenGui.Destroy(screenGui)
                end
                gq()
                gm = fn142
            else
                gm = function()
                    local textButton, gN, frame3, gP, gQ
                    local screenGui = Instance.new("ScreenGui")
                    screenGui.Name = "TempoLoader"
                    screenGui.ResetOnSpawn = false
                    screenGui.IgnoreGuiInset = true
                    screenGui.DisplayOrder = 2147483647
                    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                    local gS = gethui and gethui()
                    local gT = gS or game:GetService("CoreGui")
                    screenGui.Parent = gT
                    local blurEffect = Instance.new("BlurEffect")
                    blurEffect.Size = 0
                    blurEffect.Parent = game:GetService("Lighting")
                    local frame4 = Instance.new("Frame")
                    frame4.Size = UDim2.fromScale(1, 1)
                    frame4.BackgroundTransparency = 1
                    frame4.Parent = screenGui
                    frame3 = Instance.new("Frame")
                    frame3.AnchorPoint = Vector2.new(0.5, 0.5)
                    frame3.Position = UDim2.fromScale(0.5, 0.5)
                    frame3.Size = UDim2.fromOffset(460, 0)
                    frame3.AutomaticSize = Enum.AutomaticSize.Y
                    frame3.BackgroundTransparency = 1
                    frame3.Parent = frame4
                    local uIListLayout = Instance.new("UIListLayout")
                    uIListLayout.FillDirection = Enum.FillDirection.Vertical
                    uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                    uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    uIListLayout.Padding = UDim.new(0, 8)
                    uIListLayout.Parent = frame3
                    gQ = function(y)
                        local uIStroke = Instance.new("UIStroke")
                        uIStroke.Color = Color3.fromRGB(0, 0, 0)
                        uIStroke.Thickness = 2
                        uIStroke.Transparency = 0.1
                        uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
                        uIStroke.Parent = y
                        return uIStroke
                    end
                    local function gT_3(B, C, D, E, F)
                        local textLabel = Instance.new("TextLabel")
                        textLabel.BackgroundTransparency = 1
                        textLabel.Size = UDim2.fromOffset(460, C + 6)
                        textLabel.Font = D
                        textLabel.Text = B
                        textLabel.TextSize = C
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        textLabel.TextTransparency = E
                        textLabel.LayoutOrder = F
                        gQ(textLabel)
                        textLabel.Parent = frame3
                        return textLabel
                    end
                    gT_3("Made Tempo Marketplace && MM", 26, Enum.Font.GothamBold, 0, 1)
                    textButton = Instance.new("TextButton")
                    textButton.BackgroundTransparency = 1
                    textButton.AutoButtonColor = false
                    textButton.Size = UDim2.fromOffset(460, 24)
                    textButton.Font = Enum.Font.GothamSemibold
                    textButton.RichText = true
                    textButton.Text = "<u>" .. f0 .. "</u>  (click to copy)"
                    textButton.TextSize = 16
                    textButton.TextColor3 = Color3.fromRGB(120, 160, 255)
                    textButton.LayoutOrder = 2
                    gQ(textButton)
                    textButton.Parent = frame3
                    local function gU()
                        textButton.TextColor3 = Color3.fromRGB(170, 200, 255)
                    end
                    local MouseEnter = textButton.MouseEnter
                    MouseEnter.Connect(MouseEnter, gU)
                    local function gU_1()
                        textButton.TextColor3 = Color3.fromRGB(120, 160, 255)
                    end
                    local MouseLeave = textButton.MouseLeave
                    MouseLeave.Connect(MouseLeave, gU_1)
                    local function gU_2()
                        if setclipboard then
                            setclipboard(f0)
                        end
                        textButton.Text = "<u>" .. f0 .. "</u>  (copied!)"
                        task.delay(1.5, function()
                            textButton.Text = "<u>" .. f0 .. "</u>  (click to copy)"
                        end)
                    end
                    local Activated = textButton.Activated
                    Activated.Connect(Activated, gU_2)
                    local gU_3 = gT_3("Join for Dupes and Keyless Scripts. Dupes will always be announced and never gatekept in Tempo.", 13, Enum.Font.GothamMedium, 0.2, 3)
                    gU_3.TextWrapped = true
                    gU_3.Size = UDim2.fromOffset(420, 34)
                    gN = gT_3("Tempo Bypassing", 14, Enum.Font.GothamMedium, 0.05, 4)
                    gN.Size = UDim2.fromOffset(460, 18)
                    local frame2 = Instance.new("Frame")
                    frame2.LayoutOrder = 5
                    frame2.Size = UDim2.fromOffset(300, 6)
                    frame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    frame2.BackgroundTransparency = 0.85
                    frame2.BorderSizePixel = 0
                    frame2.Parent = frame3
                    local uICorner2 = Instance.new("UICorner")
                    uICorner2.CornerRadius = UDim.new(1, 0)
                    uICorner2.Parent = frame2
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.fromScale(0, 1)
                    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    frame.BorderSizePixel = 0
                    frame.Parent = frame2
                    local uICorner = Instance.new("UICorner")
                    uICorner.CornerRadius = UDim.new(1, 0)
                    uICorner.Parent = frame
                    gP = true
                    task.spawn(function()
                        local gK = 0
                        while gP do
                            gK = gK % 3 + 1
                            gN.Text = "Tempo Bypassing" .. string.rep(".", gK)
                            task.wait(0.35)
                        end
                    end)
                    local gV_4 = (TweenService:Create(blurEffect, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = 18 }))
                    gV_4.Play(gV_4)
                    local gV_5 = { 0.35, 0.55, 0.72, 0.9, 1 }
                    for i, v in ipairs(gV_5) do
                        local gV_6 = (TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromScale(v, 1) }))
                        gV_6.Play(gV_6)
                        task.wait(0.55)
                    end
                    gP = false
                    task.wait(0.25)
                    local gV_7 = TweenInfo.new(0.4, Enum.EasingStyle.Quad)
                    for i, descendant in ipairs(frame3:GetDescendants()) do
                        local gW_1 = descendant:IsA("TextLabel") or descendant:IsA("TextButton")
                        if gW_1 then
                            local gW_2 = (TweenService:Create(descendant, gV_7, { TextTransparency = 1 }))
                            gW_2.Play(gW_2)
                        elseif descendant:IsA("UIStroke") then
                            local gW_3 = (TweenService:Create(descendant, gV_7, { Transparency = 1 }))
                            gW_3.Play(gW_3)
                        end
                    end
                    local gW_4 = (TweenService:Create(frame2, gV_7, { BackgroundTransparency = 1 }))
                    gW_4.Play(gW_4)
                    local gT_5 = (TweenService:Create(frame, gV_7, { BackgroundTransparency = 1 }))
                    gT_5.Play(gT_5)
                    local gT_6 = (TweenService:Create(blurEffect, gV_7, { Size = 0 }))
                    gT_6.Play(gT_6)
                    task.wait(0.45)
                    blurEffect.Destroy(blurEffect)
                    screenGui.Destroy(screenGui)
                end
                gm()
                gq = fn142
            end
            gn = (gn + 37) % 56
        end
    else
        if (gn * 2 + 5) * 7 % 3 == ((gn * 2 + 5) * 7 + 4) % 3 then
            go = loadstring(game:HttpGet(loadstring))()
        else
            gs = getgenv().Fluent
        end
        gn = (gn + 23) % 56
    end
until fn501((gn * 9 + 38) % 56, 275914699)
for k, v in pairs(gr) do
    gp_1(v)
end
fO, fL, fI, gj, gg, ga, f6, gn, gm = nil, nil, nil, nil, nil, nil, nil, nil, nil
local gl_2 = 6
repeat
    go = (gl_2 * 5 + 0) % 6 + 1
    if go <= 3 then
        if go <= 2 then
            if go <= 1 then
                if (not gj and fI or (gj or not fL)) and (not f6 or not f6 or not f6 and not gn) or not ((not gj and fI or (gj or not fL)) and (not f6 or not f6 or not f6 and not gn)) then
                    fO = false
                    fL = false
                    fI = false
                else
                    fI = false
                    fO = false
                    fL = false
                end
                gl_2 = (gl_2 + 23) % 24
            else
                if (ga and not fI and (not fL or f6) or not ga and gg and (not gg or not gm)) and ((f6 and not fL or not ga and f6) and (fI or ga or (not fI or ga))) or not ((ga and not fI and (not fL or f6) or not ga and gg and (not gg or not gm)) and ((f6 and not fL or not ga and f6) and (fI or ga or (not fI or ga)))) then
                    gj = false
                    gg = false
                else
                    gg = false
                    gj = false
                end
                gl_2 = (gl_2 + 23) % 24
            end
        else
            if gl_2 * 65365633 + 12 + 3 >= gl_2 * 65365633 + 12 + 3 + 6 then
                fI = false
            else
                ga = false
            end
            gl_2 = (gl_2 + 23) % 24
        end
    elseif go <= 5 then
        if go <= 4 then
            go = (vector.create((gl_2 * 2 + 9) % 11 + 1, (gl_2 * 1 + 9) % 13 + 1, (gl_2 * 9 + 12) % 17 + 1))
            local gp_2 = (vector.create((gl_2 * 5 + 9) % 11 + 1, (gl_2 * 6 + 9) % 13 + 1, (gl_2 * 13 + 9) % 17 + 1))
            local gv_4 = (vector.create((gl_2 * 2 + 1) % 5 + 1, (gl_2 * 3 + 2) % 7 + 1, (gl_2 * 3 + 1) % 9 + 1))
            if math.abs((vector.angle(go, gp_2, gv_4))) - math.abs((vector.angle(gp_2, go, gv_4))) == 4 then
                gm = { "shiny", "big", "base" }
            else
                f6 = { "base", "big", "shiny" }
            end
            gl_2 = (gl_2 + 17) % 24
        else
            go = (vector.create((gl_2 * 3 + 2) % 11 + 1, (gl_2 * 4 + 7) % 13 + 1, (gl_2 * 10 + 4) % 17 + 1))
            local gp_3 = (vector.create((gl_2 * 6 + 2) % 11 + 1, (gl_2 * 2 + 13) % 13 + 1, (gl_2 * 6 + 15) % 17 + 1))
            local gv_5 = (vector.create((gl_2 * 1 + 2) % 11 + 1, (gl_2 * 1 + 4) % 13 + 1, (gl_2 * 10 + 6) % 17 + 1))
            local gw_12 = (vector.create((gl_2 * 3 + 7) % 5 + 1, (gl_2 * 1 + 3) % 7 + 1, (gl_2 * 1 + 3) % 9 + 1))
            if vector.dot(vector.cross(go, (vector.cross(gp_3, gv_5))), gw_12) == vector.dot(gp_3 * vector.dot(go, gv_5) - gv_5 * vector.dot(go, gp_3), gw_12) + 1 then
                task.spawn(worker)
                task.spawn(function()
                    while true do
                        task.wait(1)
                        if fL then
                            if fn501(#gk, 544454170) then
                                pcall(gh)
                            end
                            for i, v in ipairs(gk) do
                                local hO = v
                                if not fL then
                                    break
                                end
                                pcall(function()
                                    f5.Request(f5, "BuyUpgrade", hO)
                                end)
                            end
                        end
                    end
                end)
                task.spawn(task.spawn)
                go = task.spawn
                local function gp_4()
                    while true do
                        local hQ
                        task.wait(2)
                        if gj then
                            local hR = fX()
                            local hR_2
                            if hR then
                                local hS = tonumber(hR.Cash) or 0
                                local hS_4
                                local hS_3 = tonumber(hR.Rebirths) or 0
                                hQ = hS_3
                                hR_2, hS_4 = pcall(function()
                                    return f_.rebirthCost(hQ)
                                end)
                                local hU = hR_2 and (function(ef, eg, eh)
                                    if type(ef) ~= "string" then
                                        return false
                                    end
                                    if #ef ~= eg then
                                        return false
                                    end
                                    local ei = 5381
                                    local ej = buffer.fromstring(ef)
                                    local ek = 0
                                    while ek <= eg - 4 do
                                        local el = buffer.readu32(ej, ek)
                                        local ei_21 = bit32.bxor(ei, el)
                                        ei = bit32.band(ei_21 * 33, 4294967295)
                                        ek = ek + 4
                                    end
                                    while ek < eg do
                                        local em = buffer.readu8(ej, ek)
                                        local ei_22 = bit32.bxor(ei, em)
                                        ei = bit32.band(ei_22 * 33, 4294967295)
                                        ek = ek + 1
                                    end
                                    return ei == eh
                                end)(type(hS_4), 6, 472614556) and hS >= hS_4
                                if hU then
                                    pcall(function()
                                        f5.Request(f5, "Rebirth")
                                    end)
                                end
                            end
                        end
                    end
                end
                go(task)
                local spawn = task.spawn
                spawn(task)
                task.spawn(task[nil])
                gx = gn.Farm
                gx.AddToggle(gx, "Default", go)
                local Farm2 = gn.Farm
                Farm2.AddToggle(Farm2, task, gn)
                gx = gn.Farm
                gx.AddToggle(gx, false, spawn)
                gx = { Callback = fn776, Default = false, Title = "Auto Rebirth" }
                gy = gn.Farm
                gy.AddToggle(gy, gx, "AutoUpgrades")
                go = { Title = "Auto Pick Up Crates & Sell", Callback = fn48, Default = false }
                gx = gn.Crates
                gx.AddToggle(gx, go, gp_4)
                local Farm = gn.Farm
                Farm.AddToggle(Farm, "Auto Rebirth", "Default")
                gq = gr("Default")
            else
                task.spawn(worker)
                task.spawn(function()
                    while true do
                        task.wait(1)
                        if fL then
                            if fn501(#gk, 544454170) then
                                pcall(gh)
                            end
                            for i, v in ipairs(gk) do
                                local hO = v
                                if not fL then
                                    break
                                end
                                pcall(function()
                                    f5.Request(f5, "BuyUpgrade", hO)
                                end)
                            end
                        end
                    end
                end)
                task.spawn(function()
                    while true do
                        task.wait(1)
                        if fI then
                            pcall(function()
                                f5.Request(f5, "PlantBest")
                            end)
                        end
                    end
                end)
                task.spawn(function()
                    while true do
                        local hQ
                        task.wait(2)
                        if gj then
                            local hR = fX()
                            local hR_1
                            if hR then
                                local hS = tonumber(hR.Cash) or 0
                                local hS_2
                                local hS_1 = tonumber(hR.Rebirths) or 0
                                hQ = hS_1
                                hR_1, hS_2 = pcall(function()
                                    return f_.rebirthCost(hQ)
                                end)
                                local hU = hR_1 and (function(ef, eg, eh)
                                    if type(ef) ~= "string" then
                                        return false
                                    end
                                    if #ef ~= eg then
                                        return false
                                    end
                                    local ei = 5381
                                    local ej = buffer.fromstring(ef)
                                    local ek = 0
                                    while ek <= eg - 4 do
                                        local el = buffer.readu32(ej, ek)
                                        local ei_19 = bit32.bxor(ei, el)
                                        ei = bit32.band(ei_19 * 33, 4294967295)
                                        ek = ek + 4
                                    end
                                    while ek < eg do
                                        local em = buffer.readu8(ej, ek)
                                        local ei_20 = bit32.bxor(ei, em)
                                        ei = bit32.band(ei_20 * 33, 4294967295)
                                        ek = ek + 1
                                    end
                                    return ei == eh
                                end)(type(hS_2), 6, 472614556) and hS >= hS_2
                                if hU then
                                    pcall(function()
                                        f5.Request(f5, "Rebirth")
                                    end)
                                end
                            end
                        end
                    end
                end)
                task.spawn(function()
                    while true do
                        if gg then
                            pcall(function()
                                f5.Request(f5, "PickupCrates")
                            end)
                            task.wait(0.3)
                            local hY = fZ()
                            local hZ = hY and hY:IsA("ProximityPrompt") and hY.Parent
                            local Character = LocalPlayer.Character
                            local h0 = Character and Character:FindFirstChild("HumanoidRootPart")
                            local h1 = hZ
                            if h1 then
                                h1 = hZ:IsA("BasePart")
                            end
                            if h1 then
                                h1 = h0
                            end
                            if h1 then
                                local CFrame2 = h0.CFrame
                                h0.CFrame = CFrame.new(hZ.Position + Vector3.new(0, 3, 0))
                                task.wait(0.15)
                                pcall(function()
                                    fireproximityprompt(hY)
                                end)
                                task.wait(0.15)
                                if LocalPlayer.Character == Character and h0.Parent then
                                    h0.CFrame = CFrame2
                                end
                            end
                            task.wait(0.4)
                        else
                            task.wait(0.3)
                        end
                    end
                end)
                task.spawn(function()
                    while true do
                        task.wait(3)
                        if ga then
                            for i, v in ipairs(f6) do
                                local ic = v
                                if not ga then
                                    break
                                end
                                pcall(function()
                                    f5.Request(f5, "ClaimIndexReward", ic)
                                end)
                            end
                        end
                    end
                end)
                local gp_6 = {
                    Title = "Auto Spin",
                    Default = false,
                    Callback = function(bi)
                        fO = bi
                    end
                }
                local Farm5 = gr.Farm
                Farm5.AddToggle(Farm5, "AutoSpin", gp_6)
                local gp_7 = {
                    Title = "Auto Purchase Available Upgrades",
                    Default = false,
                    Callback = function(bj)
                        fL = bj
                    end
                }
                local Farm4 = gr.Farm
                Farm4.AddToggle(Farm4, "AutoUpgrades", gp_7)
                local gp_8 = {
                    Title = "Auto Equip Best Plants",
                    Default = false,
                    Callback = function(bk)
                        fI = bk
                    end
                }
                local Farm3 = gr.Farm
                Farm3.AddToggle(Farm3, "AutoEquip", gp_8)
                local gp_9 = { Title = "Auto Rebirth", Default = false, Callback = fn776 }
                local Farm2 = gr.Farm
                Farm2.AddToggle(Farm2, "AutoRebirth", gp_9)
                local gp_10 = { Title = "Auto Pick Up Crates & Sell", Default = false, Callback = fn48 }
                local Crates = gr.Crates
                Crates.AddToggle(Crates, "AutoPickup", gp_10)
                local gp_11 = {
                    Title = "Auto Claim Index",
                    Default = false,
                    Callback = function(bn)
                        ga = bn
                    end
                }
                local Farm = gr.Farm
                Farm.AddToggle(Farm, "AutoClaimIndex", gp_11)
                gn = getgenv().SaveManager
            end
            gl_2 = (gl_2 + 17) % 24
        end
    else
        go = {
            "apvt",
            "xtiutblgwm",
            "zatlp",
            "gvihctaahq",
            "wdylzcee",
            "gech",
            "ztuvwvzq",
            "fhfzs",
            "eiq",
            "foetvuaey",
            "wrbmsmdl"
        }
        local gp_12 = go[gl_2 % 11 + 1]
        go = gl_2 % 3 + 2
        local gv_13 = (gp_12:reverse())
        local kK = go
        go = gp_12:len()
        local gw_14 = (gv_13:rep(kK))
        if go >= gw_14:len() then
            gq = getgenv().ThemeManager
        else
            gm = getgenv().ThemeManager
        end
        gl_2 = (gl_2 + 5) % 24
    end
until fn501((gl_2 * 5 + 16) % 24, 712218331)
if gn then
    local gl_3 = 2
    repeat
        if ((not gl_3 or not gl_3) and (not gl_3 and gl_3) or gl_3 and not gl_3 and (not gl_3 and gl_3) or (gl_3 and gl_3 or gl_3 and not gl_3 or (not gl_3 or gl_3) and (gl_3 and not gl_3)) or not gl_3 and not gl_3 and (gl_3 or gl_3) and (not gl_3 and gl_3 or (gl_3 or gl_3)) and (gl_3 and not gl_3 and (not gl_3 and gl_3) and (not gl_3 and not gl_3 or gl_3 and not gl_3))) and not ((not gl_3 or not gl_3) and (not gl_3 and gl_3) or gl_3 and not gl_3 and (not gl_3 and gl_3) or (gl_3 and gl_3 or gl_3 and not gl_3 or (not gl_3 or gl_3) and (gl_3 and not gl_3)) or not gl_3 and not gl_3 and (gl_3 or gl_3) and (not gl_3 and gl_3 or (gl_3 or gl_3)) and (gl_3 and not gl_3 and (not gl_3 and gl_3) and (not gl_3 and not gl_3 or gl_3 and not gl_3))) then
            gs.SetLibrary(gs, gr)
            gs.IgnoreThemeSettings(gs)
            gs.SetIgnoreIndexes(gs, {})
            gs.SetFolder(gs, "TempoHub/FarmRNG")
            gs.BuildConfigSection(gs, gs)
        else
            gn.SetLibrary(gn, gs)
            gn.IgnoreThemeSettings(gn)
            gn.SetIgnoreIndexes(gn, {})
            gn.SetFolder(gn, "TempoHub/FarmRNG")
            gn.BuildConfigSection(gn, gr.Settings)
        end
        gl_3 = (gl_3 + 0) % 4
    until fn501((gl_3 * 3 + 2) % 4, 544454170)
end
if gm then
    local gl_4 = 1
    repeat
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gl_4, 29), string.byte(tostring(gl_4))), 25), 848902669), 2863894362), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gl_4, 29), string.byte(tostring(gl_4))), 25), 3446064626), 1374598047))), 2863894362), 1374598047) == bit32.rrotate(bit32.bxor(bit32.lrotate(gl_4, 29), string.byte(tostring(gl_4))), 25) then
            gm.SetLibrary(gm, gs)
            gm.SetFolder(gm, "TempoHub")
            gm.BuildInterfaceSection(gm, gr.Settings)
        else
            gr.SetLibrary(gr, gr)
            gr.SetFolder(gr, gm)
            gr.BuildInterfaceSection(gr, gr)
        end
        gl_4 = (gl_4 + 6) % 8
    until fn501((gl_4 * 3 + 4) % 8, 527583337)
end
gb.SelectTab(gb, 1)
if gn then
    gn.LoadAutoloadConfig(gn)
end
gm = nil
local gl_5 = 13
repeat
    gn = (gl_5 * 1 + 1) % 2 + 1
    if gn <= 1 then
        gn = { "gsqcsza", "jmmaft", "qbxjlvyxo", "swlaxx", "fhb", "igu", "cfmyzwywigx" }
        go = gn[gl_5 % 7 + 1]
        gn = go:len()
        local gp_13 = (go:gsub("(.)", "%1%1", gl_5 % 3 % 2 + 1))
        if gn >= gp_13:len() then
            gm = Instance:new()
        else
            gm = Instance.new("ScreenGui")
        end
        gl_5 = (gl_5 + 11) % 16
    else
        gn = (vector.create((gl_5 * 7 + 9) % 11 + 1, (gl_5 * 4 + 2) % 13 + 1, (gl_5 * 1 + 9) % 17 + 1))
        go = (vector.create((gl_5 * 7 + 8) % 11 + 1, (gl_5 * 10 + 4) % 13 + 1, (gl_5 * 11 + 2) % 17 + 1))
        local gp_14 = (vector.create((gl_5 * 5 + 8) % 11 + 1, (gl_5 * 11 + 12) % 13 + 1, (gl_5 * 2 + 6) % 17 + 1))
        gq = (vector.create((gl_5 * 3 + 6) % 5 + 1, (gl_5 * 1 + 2) % 7 + 1, (gl_5 * 5 + 5) % 9 + 1))
        if vector.dot(vector.cross(gn, (vector.cross(go, gp_14))), gq) == vector.dot(go * vector.dot(gn, gp_14) - gp_14 * vector.dot(gn, go), gq) + 2 then
            gm.Name = "TempoToggle"
            gm.ResetOnSpawn = gm
            gm.ZIndexBehavior = Enum.ZIndexBehavior
        else
            gm.Name = "TempoToggle"
            gm.ResetOnSpawn = false
            gm.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        end
        gl_5 = (gl_5 + 13) % 16
    end
until fn501((gl_5 * 11 + 11) % 16, 578005792)
local gl_6 = gethui and gethui()
gn = gl_6 or game:GetService("CoreGui")
fQ, uIStroke2, gi, gc, f7, f4, fK, screenGui2 = nil, nil, nil, nil, nil, nil, nil, nil
local gp_15 = 30
repeat
    gr = (gp_15 * 3 + 4) % 5 + 1
    if gr <= 3 then
        if gr <= 2 then
            if gr <= 1 then
                if gp_15 * 44653043 + 2 + 7 <= gp_15 * 44653043 + 2 + 7 + 2 then
                    fQ.Size = UDim2.fromOffset(52, 52)
                    fQ.Position = UDim2.fromScale(0.5, 0.04)
                    fQ.AnchorPoint = Vector2.new(0.5, 0)
                    fQ.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                    fQ.BackgroundTransparency = 0.1
                    fQ.Image = fY
                    fQ.ScaleType = Enum.ScaleType.Fit
                    fQ.AutoButtonColor = true
                    fQ.Parent = gm
                    go = Instance.new("UICorner")
                    go.CornerRadius = UDim.new(0, 12)
                    go.Parent = fQ
                    uIStroke2 = Instance.new("UIStroke")
                    uIStroke2.Color = Color3.fromRGB(80, 80, 95)
                    uIStroke2.Thickness = 1
                    uIStroke2.Transparency = 0.3
                    uIStroke2.Parent = fQ
                    gq = Instance.new("UIPadding")
                    gq.PaddingTop = UDim.new(0, 6)
                    gq.PaddingBottom = UDim.new(0, 6)
                    gq.PaddingLeft = UDim.new(0, 6)
                    gq.PaddingRight = UDim.new(0, 6)
                    gq.Parent = fQ
                    gi, gc, f7, f4 = false, nil, nil, false
                else
                    uIStroke2.Size = UDim2.fromOffset(52, UDim2)
                    uIStroke2.Position = UDim2.fromScale(uIStroke2, UDim2.fromScale)
                    uIStroke2.AnchorPoint = Vector2:new(Vector2.new)
                    gs = Color3.fromRGB
                    uIStroke2.BackgroundColor3 = gs(25, 0.5, 0.04)
                    uIStroke2.BackgroundTransparency = uIStroke2
                    uIStroke2.Image = UDim2
                    local Fit = Enum.ScaleType.Fit
                    uIStroke2.ScaleType = uIStroke2
                    uIStroke2.AutoButtonColor = uIStroke2
                    uIStroke2.Parent = 0.5
                    f7 = Instance.new(uIStroke2)
                    gx = UDim.new
                    f7.CornerRadius = gx(Enum, 0.1)
                    f7.Parent = 12
                    fQ = Instance.new(52)
                    gy = Color3.fromRGB
                    fQ.Color = gy(Fit, true, gx)
                    fQ.Thickness = f4
                    fQ.Transparency = uIStroke2
                    fQ.Parent = Color3
                    local new2 = Instance.new
                    gm = new2(uIStroke2)
                    gx = UDim.new
                    gm.PaddingTop = gx(fQ, new2)
                    gm.PaddingBottom = UDim.new(gy, fQ)
                    local new = UDim.new
                    gm.PaddingLeft = new("UICorner", uIStroke2)
                    gm.PaddingRight = UDim.new(f7, new)
                    gm.Parent = gs
                    fY, gc, gi = gx, gm, 0.3
                end
                gp_15 = (gp_15 + 17) % 40
            else
                gs = {
                    "fpuurc",
                    "kgpxmbi",
                    "gcehqrgg",
                    "eqy",
                    "ppn",
                    "xbwovy",
                    "qormh",
                    "ptpxkmjmgvp",
                    "djkqxoy",
                    "sed"
                }
                local gv_17 = gs[gp_15 % 10 + 1]
                gs = gv_17:len()
                local gw_15 = (gv_17:gsub("(.)", "%1%1", gp_15 % 3 % 2 + 1))
                if gs <= gw_15:len() then
                    gs = fn920
                    local InputBegan = fQ.InputBegan
                    InputBegan.Connect(InputBegan, gs)
                    gs = fn69
                    local InputChanged = gt.InputChanged
                    InputChanged.Connect(InputChanged, gs)
                    gs = function(bH)
                        if bH.UserInputType == Enum.UserInputType.MouseButton1 or bH.UserInputType == Enum.UserInputType.Touch then
                            gi = false
                        end
                    end
                    local InputEnded = gt.InputEnded
                    InputEnded.Connect(InputEnded, gs)
                    fK = false
                else
                    gs = fn920
                    local InputBegan = fK.InputBegan
                    InputBegan.Connect(InputBegan, gs)
                    gs = fQ.InputChanged
                    local gw_16 = gs
                    gw_16.Connect(gw_16, fn69)
                    local InputEnded = fQ.InputEnded
                    InputEnded.Connect(InputEnded, gs)
                    gt = InputEnded
                end
                gp_15 = (gp_15 + 32) % 40
            end
        else
            if gp_15 * 28394881 + 12 + 3 <= gp_15 * 28394881 + 12 + 3 + 3 then
                gs = fn224
                local MouseButton1Click = fQ.MouseButton1Click
                MouseButton1Click.Connect(MouseButton1Click, gs)
                screenGui2 = Instance.new("ScreenGui")
            else
                gs = fn224
                local MouseButton1Click = screenGui2.MouseButton1Click
                MouseButton1Click.Connect(MouseButton1Click, gs)
                fQ = Instance.new(Instance.new)
            end
            gp_15 = (gp_15 + 37) % 40
        end
    elseif gr <= 4 then
        gr = (vector.create((gp_15 * 4 + 7) % 11 + 1, (gp_15 * 10 + 3) % 13 + 1, (gp_15 * 6 + 1) % 17 + 1))
        gs = (vector.create((gp_15 * 2 + 3) % 11 + 1, (gp_15 * 10 + 7) % 13 + 1, (gp_15 * 12 + 2) % 17 + 1))
        local gv_26 = (vector.create((gp_15 * 2 + 6) % 11 + 1, (gp_15 * 3 + 5) % 13 + 1, (gp_15 * 13 + 5) % 17 + 1))
        local gw_18 = (vector.create((gp_15 * 5 + 1) % 5 + 1, (gp_15 * 4 + 3) % 7 + 1, (gp_15 * 5 + 4) % 9 + 1))
        if vector.dot(vector.cross(gr, (vector.cross(gs, gv_26))), gw_18) == vector.dot(gs * vector.dot(gr, gv_26) - gv_26 * vector.dot(gr, gs), gw_18) + 2 then
            screenGui2.Name = screenGui2
            screenGui2.ResetOnSpawn = false
            screenGui2.ZIndexBehavior = screenGui2
        else
            screenGui2.Name = "TempoPromo"
            screenGui2.ResetOnSpawn = false
            screenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        end
        gp_15 = (gp_15 + 12) % 40
    else
        gr = (vector.create((gp_15 * 6 + 4) % 11 + 1, (gp_15 * 11 + 12) % 13 + 1, (gp_15 * 7 + 7) % 17 + 1))
        gs = (vector.create((gp_15 * 4 + 7) % 11 + 1, (gp_15 * 11 + 13) % 13 + 1, (gp_15 * 2 + 5) % 17 + 1))
        local gv_27 = (vector.create((gp_15 * 5 + 4) % 5 + 1, (gp_15 * 3 + 3) % 7 + 1, (gp_15 * 5 + 4) % 9 + 1))
        if math.abs((vector.angle(gr, gs, gv_27))) - math.abs((vector.angle(gs, gr, gv_27))) == 1 then
            gm.Parent = fQ
            gn = Instance.new("ImageButton")
        else
            gm.Parent = gn
            fQ = Instance.new("ImageButton")
        end
        gp_15 = (gp_15 + 2) % 40
    end
until fn501((gp_15 * 7 + 29) % 40, 292689510)
local gl_8 = gethui and gethui()
gm = gl_8 or game:GetService("CoreGui")
gn = nil
local gl_9 = 5
repeat
    go = (vector.create((gl_9 * 4 + 8) % 11 + 1, (gl_9 * 7 + 2) % 13 + 1, (gl_9 * 6 + 7) % 17 + 1))
    local gp_16 = (vector.create((gl_9 * 6 + 9) % 11 + 1, (gl_9 * 8 + 11) % 13 + 1, (gl_9 * 12 + 8) % 17 + 1))
    gq = (vector.create((gl_9 * 3 + 6) % 11 + 1, (gl_9 * 4 + 9) % 13 + 1, (gl_9 * 13 + 6) % 17 + 1))
    gr = (vector.create((gl_9 * 6 + 6) % 11 + 1, (gl_9 * 6 + 8) % 13 + 1, (gl_9 * 14 + 10) % 17 + 1))
    if vector.dot(vector.cross(go, gp_16), (vector.cross(gq, gr))) == vector.dot(go, gq) * vector.dot(gp_16, gr) - vector.dot(go, gr) * vector.dot(gp_16, gq) + 4 then
        screenGui2.Parent = gn
        gt = gm
    else
        screenGui2.Parent = gm
        gn = gt.TouchEnabled
    end
    gl_9 = (gl_9 + 7) % 8
until fn501((gl_9 * 5 + 4) % 8, 544454170)
if gn then
    gn = not gt.MouseEnabled
end
fS = gn
local function gl_10(bQ, bR)
    local textButton = Instance.new("TextButton")
    local iq = fS and UDim2.fromOffset(150, 40)
    local ir = iq or UDim2.fromOffset(240, 60)
    textButton.Size = ir
    textButton.Position = bQ
    textButton.AnchorPoint = bR
    textButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    textButton.BackgroundTransparency = 0
    textButton.Text = ""
    textButton.AutoButtonColor = true
    textButton.Parent = screenGui2
    local uICorner = Instance.new("UICorner")
    uICorner.CornerRadius = UDim.new(0, 8)
    uICorner.Parent = textButton
    local uIStroke = Instance.new("UIStroke")
    uIStroke.Color = Color3.fromRGB(80, 80, 95)
    uIStroke.Thickness = 1
    uIStroke.Transparency = 0.3
    uIStroke.Parent = textButton
    local ir_1 = fS and 24 or 36
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Size = UDim2.fromOffset(ir_1, ir_1)
    local new = UDim2.new
    local it = fS and 8 or 12
    imageLabel.Position = new(0, it, 0.5, 0)
    imageLabel.AnchorPoint = Vector2.new(0, 0.5)
    imageLabel.BackgroundTransparency = 1
    imageLabel.Image = fY
    imageLabel.ScaleType = Enum.ScaleType.Fit
    imageLabel.Parent = textButton
    local ir_3 = fS and 40 or 60
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -ir_3, 1, 0)
    textLabel.Position = UDim2.new(0, ir_3, 0, 0)
    textLabel.BackgroundTransparency = 1
    local is_1 = fS and "Join Tempo\n[Copy Discord]" or "Join Tempo\nFree Keyless & Dupe Scripts\n[Click to Copy Discord]"
    textLabel.Text = is_1
    textLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    local is_2 = fS and 10 or 12
    textLabel.TextSize = is_2
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = textButton
    local function iq_10()
        pcall(function()
            setclipboard(f0)
        end)
        if notify then
            notify("Tempo Discord copied to clipboard!")
        end
    end
    local MouseButton1Click = textButton.MouseButton1Click
    MouseButton1Click.Connect(MouseButton1Click, iq_10)
end
if fS then
    gm = 0
    repeat
        if bit32.bxor(bit32.lrotate(bit32.bxor(bit32.rrotate(bit32.bxor(bit32.lrotate(gm, 3), string.byte(tostring(gm))), 6), 1113371323), 28), 3022375723) == bit32.lrotate(bit32.rrotate(bit32.bxor(bit32.lrotate(gm, 3), string.byte(tostring(gm))), 6), 28) then
            gl_10(UDim2.new(0, 12, 0.5, 0), Vector2.new(0, 0.5))
        else
            gl_10(0, Vector2.new(gl_10, 0.5))
        end
        gm = (gm + 0) % 4
    until fn501((gm * 3 + 2) % 4, 578005792)
else
    gn = 1
    repeat
        gm = (vector.create((gn * 5 + 5) % 11 + 1, (gn * 7 + 4) % 13 + 1, (gn * 1 + 14) % 17 + 1))
        if fn501(vector.dot(vector.floor(gm) + vector.ceil(gm * -1), vector.floor(gm) + vector.ceil(gm * -1)), 544454170) then
            gl_10(UDim2.new(0, 20, 0.78, 0), Vector2.new(0, 0.5))
            gl_10(UDim2.new(1, -20, 0.78, 0), Vector2.new(1, 0.5))
        else
            gl_10(UDim2.new, Vector2:new(0.5))
            gl_10(UDim2.new, Vector2.new(1, 0))
        end
        gn = (gn + 2) % 8
    until fn501((gn * 7 + 7) % 8, 477252822)
end
go = nil
gm = 11
repeat
    if (gm * 1 + 0) % 2 + 1 <= 1 then
        local gl_12 = (vector.create((gm * 2 + 8) % 11 + 1, (gm * 7 + 7) % 13 + 1, (gm * 9 + 3) % 17 + 1))
        gn = (vector.create((gm * 4 + 1) % 11 + 1, (gm * 9 + 5) % 13 + 1, (gm * 15 + 15) % 17 + 1))
        local gp_17 = (vector.create((gm * 3 + 5) % 11 + 1, (gm * 11 + 8) % 13 + 1, (gm * 13 + 11) % 17 + 1))
        gq = (vector.create((gm * 5 + 7) % 5 + 1, (gm * 5 + 6) % 7 + 1, (gm * 4 + 6) % 9 + 1))
        if vector.dot(vector.cross(gl_12, (vector.cross(gn, gp_17))), gq) == vector.dot(gn * vector.dot(gl_12, gp_17) - gp_17 * vector.dot(gl_12, gn), gq) + 4 then
            go.Name = go
            go.ResetOnSpawn = go
            go.ZIndexBehavior = Enum
        else
            go.Name = "TempoMarketplace"
            go.ResetOnSpawn = false
            go.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        end
        gm = (gm + 5) % 16
    else
        if (not gm or go) and (not gm and not gm) and (not gm and not gm or (not go or go)) or not ((not gm or go) and (not gm and not gm) and (not gm and not gm or (not go or go))) then
            go = Instance.new("ScreenGui")
        else
            go = Instance.new("ScreenGui")
        end
        gm = (gm + 7) % 16
    end
until fn501((gm * 5 + 8) % 16, 695437356)
local gl_13 = gethui and gethui()
gm = gl_13 or game:GetService("CoreGui")
local f8
local gl_14 = 1
repeat
    if gl_14 * 44853981 + 2 + 1 >= gl_14 * 44853981 + 2 + 1 + 3 then
        go.Parent = f8
        gm = Instance.new("Frame")
    else
        go.Parent = gm
        f8 = Instance.new("Frame")
    end
    gl_14 = (gl_14 + 2) % 4
until fn501((gl_14 * 1 + 2) % 4, 527583337)
local gl_15 = fS
if gl_15 then
    gm = 7
    repeat
        gn = { "ttccpopkrt", "lrk", "prklyp", "rxj", "yjujbkvp", "owhchqok", "levtzpxsc", "rxhwr" }
        local gp_18 = gn[gm % 8 + 1]
        gn = gm % 3 + 2
        gq = (gp_18:reverse())
        local kr = gn
        gn = gp_18:len()
        gr = (gq:rep(kr))
        if gn >= gr:len() then
            gl_15 = UDim2:fromOffset(100)
        else
            gl_15 = UDim2.fromOffset(170, 100)
        end
        gm = (gm + 6) % 8
    until fn501((gm * 7 + 3) % 8, 510804476)
end
gn = gl_15
if not gn then
    local gl_16 = 1
    repeat
        gm = (vector.create((gl_16 * 6 + 5) % 11 + 1, (gl_16 * 7 + 2) % 13 + 1, (gl_16 * 6 + 8) % 17 + 1))
        local gp_19 = (vector.create((gl_16 * 3 + 2) % 11 + 1, (gl_16 * 9 + 8) % 13 + 1, (gl_16 * 6 + 6) % 17 + 1))
        gq = (vector.create((gl_16 * 2 + 6) % 11 + 1, (gl_16 * 3 + 12) % 13 + 1, (gl_16 * 5 + 17) % 17 + 1))
        gr = (vector.create((gl_16 * 3 + 5) % 5 + 1, (gl_16 * 1 + 4) % 7 + 1, (gl_16 * 5 + 7) % 9 + 1))
        if vector.dot(vector.cross(gm, (vector.cross(gp_19, gq))), gr) == vector.dot(gp_19 * vector.dot(gm, gq) - gq * vector.dot(gm, gp_19), gr) then
            gn = UDim2.fromOffset(240, 140)
        else
            gn = UDim2.fromOffset(UDim2.fromOffset, UDim2)
        end
        gl_16 = (gl_16 + 7) % 8
    until fn501((gl_16 * 1 + 0) % 8, 544454170)
end
gs, uIStroke3, fT, gq, gp_20, fM, gm, gf = nil, nil, nil, nil, nil, nil, nil, nil
gr = 14
repeat
    local gl_17 = (gr * 4 + 0) % 5 + 1
    if gl_17 <= 3 then
        if gl_17 <= 2 then
            if gl_17 <= 1 then
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gr, 26), string.byte(tostring(gm))), 17), 1439678245), 793763870), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gr, 26), string.byte(tostring(gm))), 17), 2855289050), 2575707774))), 793763870), 2575707774) == bit32.rrotate(bit32.bxor(bit32.lrotate(gr, 26), string.byte(tostring(gm))), 17) then
                    task.spawn(function()
                        while task.wait(1) do
                            if not gf or not gf.Parent then
                                local iw_1 = gethui and gethui()
                                local ix = iw_1 or game:GetService("CoreGui")
                                for i, child in ipairs(ix:GetChildren()) do
                                    if child:IsA("ScreenGui") then
                                        for i, child in ipairs(child:GetChildren()) do
                                            local iw_3 = child:IsA("Frame") and child.AbsoluteSize.Y > 200
                                            if iw_3 then
                                                for i, descendant in ipairs(child:GetDescendants()) do
                                                    local iw_4 = descendant:IsA("TextLabel") and (function(ef, eg, eh)
                                                        if type(ef) ~= "string" then
                                                            return false
                                                        end
                                                        if #ef ~= eg then
                                                            return false
                                                        end
                                                        local ei = 5381
                                                        local ej = buffer.fromstring(ef)
                                                        local ek = 0
                                                        while ek <= eg - 4 do
                                                            local el = buffer.readu32(ej, ek)
                                                            local ei_23 = bit32.bxor(ei, el)
                                                            ei = bit32.band(ei_23 * 33, 4294967295)
                                                            ek = ek + 4
                                                        end
                                                        while ek < eg do
                                                            local em = buffer.readu8(ej, ek)
                                                            local ei_24 = bit32.bxor(ei, em)
                                                            ei = bit32.band(ei_24 * 33, 4294967295)
                                                            ek = ek + 1
                                                        end
                                                        return ei == eh
                                                    end)(descendant.Text, 13, 1296304569)
                                                    if iw_4 then
                                                        gf = child
                                                        break
                                                    end
                                                end
                                            end
                                            if gf then
                                                break
                                            end
                                        end
                                    end
                                    if gf then
                                        break
                                    end
                                end
                            end
                        end
                    end)
                    gt = function()
                        if gf and gf.Parent then
                            local iR_1 = false
                            if not gf.Visible then
                                iR_1 = true
                            elseif gf.AbsoluteSize.Y < 50 then
                                iR_1 = true
                            elseif gf.AbsolutePosition.Y < -3000 then
                                iR_1 = true
                            end
                            if iR_1 then
                                f8.Visible = false
                            else
                                f8.Visible = true
                                f8.Position = UDim2.fromOffset(gf.AbsolutePosition.X + gf.AbsoluteSize.X + 15, gf.AbsolutePosition.Y)
                            end
                        else
                            f8.Visible = false
                        end
                    end
                    local RenderStepped = gu.RenderStepped
                    RenderStepped.Connect(RenderStepped, gt)
                else
                    task.spawn(task)
                    gt = gu.RenderStepped
                    gt.Connect(gt, gu)
                end
                gr = (gr + 4) % 40
            else
                if (gr * 1 + 7) * 21 % 4 == ((gr * 1 + 7) * 21 + 12) % 4 then
                    f8.Size = gn
                    f8.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                    f8.BackgroundTransparency = 0
                    f8.Visible = false
                    f8.Parent = go
                    gs = Instance.new("UICorner")
                else
                    f8.Size = f8
                    gn.BackgroundColor3 = Color3.fromRGB(25, gn, 30)
                    gn.BackgroundTransparency = 25
                    gn.Visible = Color3
                    gn.Parent = gn
                    go = Instance.new(gn)
                end
                gr = (gr + 29) % 40
            end
        else
            if (gq or not gq or (gr or not gp_20)) and (gq and gs or gr and not gr) or not ((gq or not gq or (gr or not gp_20)) and (gq and gs or gr and not gr)) then
                gs.CornerRadius = UDim.new(0, 8)
                gs.Parent = f8
                uIStroke3 = Instance.new("UIStroke")
            else
                uIStroke3.CornerRadius = UDim.new(uIStroke3, 0)
                uIStroke3.Parent = UDim
                f8 = Instance.new(8)
            end
            gr = (gr + 29) % 40
        end
    elseif gl_17 <= 4 then
        local gl_18 = (vector.create((gr * 7 + 9) % 11 + 1, (gr * 5 + 4) % 13 + 1, (gr * 1 + 12) % 17 + 1))
        gt = (vector.create((gr * 5 + 1) % 11 + 1, (gr * 2 + 3) % 13 + 1, (gr * 3 + 7) % 17 + 1))
        if vector.dot(vector.cross(gl_18, gt), (vector.cross(gl_18, gt))) + vector.dot(gl_18, gt) * vector.dot(gl_18, gt) == vector.dot(gl_18, gl_18) * vector.dot(gt, gt) + 3 then
            fT.Color = Color3.fromRGB(95, 80, Color3.fromRGB)
            fT.Thickness = 80
            fT.Transparency = 0.3
            fT.Parent = fT
            f8 = Instance.new(1)
        else
            uIStroke3.Color = Color3.fromRGB(80, 80, 95)
            uIStroke3.Thickness = 1
            uIStroke3.Transparency = 0.3
            uIStroke3.Parent = f8
            fT = Instance.new("ImageLabel")
        end
        gr = (gr + 9) % 40
    else
        local gl_19 = (vector.create((gr * 4 + 3) % 11 + 1, (gr * 8 + 4) % 13 + 1, (gr * 12 + 10) % 17 + 1))
        gt = (vector.create((gr * 7 + 4) % 11 + 1, (gr * 9 + 1) % 13 + 1, (gr * 14 + 13) % 17 + 1))
        local gv_29 = (vector.create((gr * 5 + 4) % 11 + 1, (gr * 8 + 7) % 13 + 1, (gr * 1 + 10) % 17 + 1))
        if vector.dot(vector.cross(gl_19, gt), gv_29) == vector.dot(vector.cross(gt, gv_29), gl_19) then
            fT.Size = UDim2.fromOffset(40, 40)
            fT.Position = UDim2.new(0, 15, 0, 15)
            fT.BackgroundTransparency = 1
            fT.Image = fY
            fT.ScaleType = Enum.ScaleType.Fit
            fT.Parent = f8
            gq = Instance.new("TextLabel")
            gq.Size = UDim2.new(1, -70, 0, 20)
            gq.Position = UDim2.new(0, 65, 0, 15)
            gq.BackgroundTransparency = 1
            gq.Text = "Tempo Market"
            gq.TextColor3 = Color3.fromRGB(240, 240, 240)
            gq.TextSize = 14
            gq.Font = Enum.Font.GothamBold
            gq.TextXAlignment = Enum.TextXAlignment.Left
            gq.Parent = f8
            gp_20 = Instance.new("TextLabel")
            gp_20.Size = UDim2.new(1, -70, 0, 15)
            gp_20.Position = UDim2.new(0, 65, 0, 35)
            gp_20.BackgroundTransparency = 1
            gp_20.Text = "Trade. Sell. Profit."
            gp_20.TextColor3 = Color3.fromRGB(150, 150, 150)
            gp_20.TextSize = 11
            gp_20.Font = Enum.Font.GothamMedium
            gp_20.TextXAlignment = Enum.TextXAlignment.Left
            gp_20.Parent = f8
            fM = Instance.new("TextLabel")
            fM.Size = UDim2.new(1, -30, 0, 60)
            fM.Position = UDim2.new(0, 15, 0, 65)
            fM.BackgroundTransparency = 1
            fM.Text = "Got spare items piling up? Turn your grind into actual profit.\n\nClick to join the biggest trading community around!"
            fM.TextColor3 = Color3.fromRGB(190, 190, 190)
            fM.TextSize = 11
            fM.Font = Enum.Font.Gotham
            fM.TextXAlignment = Enum.TextXAlignment.Left
            fM.TextYAlignment = Enum.TextYAlignment.Top
            fM.TextWrapped = true
            fM.Parent = f8
            gm = Instance.new("TextButton")
            gm.Size = UDim2.new(1, 0, 1, 0)
            gm.BackgroundTransparency = 1
            gm.Text = ""
            gm.Parent = f8
            local function gl_20()
                local fd = (TweenService:Create(f8, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(30, 30, 35) }))
                fd.Play(fd)
                local fe = (TweenService:Create(uIStroke3, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Color = Color3.fromRGB(100, 100, 115) }))
                fe.Play(fe)
                local ff = (TweenService:Create(fM, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(230, 230, 230) }))
                ff.Play(ff)
            end
            gt = gm.MouseEnter
            gt.Connect(gt, gl_20)
            local function gl_21()
                local fg = (TweenService:Create(f8, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(25, 25, 30) }))
                fg.Play(fg)
                local fh = (TweenService:Create(uIStroke3, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Color = Color3.fromRGB(80, 80, 95) }))
                fh.Play(fh)
                local fi = (TweenService:Create(fM, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(190, 190, 190) }))
                fi.Play(fi)
            end
            gt = gm.MouseLeave
            gt.Connect(gt, gl_21)
            local function gl_22()
                task.spawn(function()
                    local fj = (TweenService:Create(fT, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(34, 34), Position = UDim2.new(0, 18, 0, 18) }))
                    fj.Play(fj)
                    task.wait(0.1)
                    local fk = (TweenService:Create(fT, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(40, 40), Position = UDim2.new(0, 15, 0, 15) }))
                    fk.Play(fk)
                end)
                pcall(function()
                    setclipboard(f0)
                end)
                if notify then
                    notify("Marketplace Discord copied to clipboard!")
                end
            end
            gt = gm.MouseButton1Click
            gt.Connect(gt, gl_22)
            gf = nil
        else
            local fromOffset = UDim2.fromOffset
            gf.Size = fromOffset(40, UDim2)
            gt = UDim2.new
            gf.Position = gt(UDim2, gf, fromOffset, 0)
            gf.BackgroundTransparency = 40
            gf.Image = gf
            local Fit = Enum.ScaleType.Fit
            gf.ScaleType = Enum[nil]
            gf.Parent = 15
            local new3 = Instance.new
            fY = new3(gf)
            gx = UDim2.new
            fY.Size = gx(1, "TextLabel", f8, Fit)
            local new2 = UDim2.new
            fY.Position = new2(0, 0, Enum, UDim2)
            fY.BackgroundTransparency = gt
            fY.Text = "Tempo Market"
            fY.TextColor3 = Color3.fromRGB(70, 1, gf)
            fY.TextSize = gf
            gt = Enum.Font
            fY.Font = 240
            local TextXAlignment = Enum.TextXAlignment
            local Left = TextXAlignment.Left
            fY.TextXAlignment = 15
            fY.Parent = fY
            fM = Instance.new(gx)
            gx = UDim2.new
            fM.Size = gx(TextXAlignment, fY, 15, new3)
            fM.Position = UDim2.new(gt, "TextLabel", gf, fM)
            fM.BackgroundTransparency = 0
            fM.Text = Instance
            fM.TextColor3 = Color3.fromRGB(fM, Color3.fromRGB, 0)
            fM.TextSize = fM
            gt = Enum.Font.GothamMedium
            fM.Font = 240
            fM.TextXAlignment = 150
            fM.Parent = gq
            fT = Instance.new(Enum)
            fT.Size = UDim2.new(fM, 20, 240, -70)
            fT.Position = UDim2.new(fY, 150, gt, UDim2)
            fT.BackgroundTransparency = 65
            fT.Text = Enum
            fT.TextColor3 = Color3.fromRGB(fM, 65, -70)
            fT.TextSize = Enum
            fT.Font = UDim2
            fT.TextXAlignment = gx
            fT.TextYAlignment = fT
            fT.TextWrapped = 70
            fT.Parent = fT
            local new = Instance.new
            gp_20 = new(fT)
            gp_20.Size = UDim2.new(gp_20, new2, Left, Enum)
            gp_20.BackgroundTransparency = 0
            gp_20.Text = "Got spare items piling up? Turn your grind into actual profit.\n\nClick to join the biggest trading community around!"
            gp_20.Parent = new
            local MouseEnter = gp_20.MouseEnter
            MouseEnter.Connect(MouseEnter, true)
            local MouseLeave = gp_20.MouseLeave
            MouseLeave.Connect(MouseLeave, gq)
            local MouseButton1Click = gp_20.MouseButton1Click
            MouseButton1Click.Connect(MouseButton1Click, fM)
            gm = 11
        end
        gr = (gr + 14) % 40
    end
until fn501((gr * 37 + 11) % 40, 1114699906)
end)(...)

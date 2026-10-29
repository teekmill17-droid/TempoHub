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
getgenv().TempoHoodSubtitle = "FARM AN ISLAND"
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
local VirtualUser
local Options
local h1
local Toggles
local connection2
local CollectionService
local ia
local Library
local LocalPlayer
local id
local connection
local iE
local hY
local ik
local Events
local h3
local ir
local iu
local OnoeNum
local ix
local hR
local iA
local peek
local ig
local localPlayerSessionAtom
local h2
local it
local ib
local iz
local ie
local iC
local TweenService
local function onRscripts()
    h2(iu, "Copied Rscripts profile to clipboard")
end
local function fn104(aF, aG, aH)
    return string.format("<b>%s</b> %s %s", aF, ir("-", "#5a6070"), ir(aG, aH))
end
local function fn141(di)
    local Character = LocalPlayer.Character
    local kY = Character and Character:FindFirstChildOfClass("Humanoid")
    if kY then
        kY:EquipTool(di)
    end
end
local function fn213(aQ)
    local DiscordGroup = aQ:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = iC })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = iC })
end
local function fn271()
    local kF = {}
    for k, v in pairs(id().tiles) do
        if v.status == "unlocked" and v.plant then
            table.insert(kF, k)
        end
    end
    table.sort(kF)
    return kF
end
local function fn319(aC, aD)
    return string.format('<font color="%s">%s</font>', aD, aC)
end
local function fn327(av, aw)
    if setclipboard then
        setclipboard(av)
    elseif toclipboard then
        toclipboard(av)
    end
    Library:Notify(aw)
end
local function fn334()
    h2(ix, "Copied Discord invite to clipboard")
end
local function autoUpgradesLoop()
    while not Library.Unloaded do
        task.wait(Options.UpgradeDelay.Value)
        if Toggles.AutoUpgrades.Value then
            if Toggles.UpgradeGrowthSpeed.Value then
                pcall(function()
                    Events.upgrades.upgradeGrowthSpeed()
                end)
            end
            if Toggles.UpgradeHarvestTool.Value then
                pcall(function()
                    Events.upgrades.upgradeHarvestTool()
                end)
            end
            if Toggles.UpgradeSeedLuck.Value then
                pcall(function()
                    Events.upgrades.upgradeSeedLuck()
                end)
            end
            if Toggles.UpgradeMachineSlot.Value then
                pcall(function()
                    Events.upgrades.upgradeSeedsMachineSlot()
                end)
            end
        end
    end
end
local function autoBankLoop()
    while not Library.Unloaded do
        task.wait(Options.BankDelay.Value)
        if Toggles.AutoBank.Value then
            local lR = id()
            local lS = not lR.isConvertingCrops
            if lS ~= false then
                lS = not OnoeNum.new(lR.crops):lessEquals(0)
            end
            if lS then
                pcall(function()
                    Events.bank.convertCrops()
                end)
            end
        end
    end
end
local function autoBuyTilesLoop()
    local CFrame2
    while not Library.Unloaded do
        task.wait(0.3)
        if Toggles.AutoBuyTiles.Value then
            local kp_1 = CollectionService:GetTagged(it)
            local kq_1 = h1()
            if kq_1 and #kp_1 > 0 then
                if not CFrame2 then
                    CFrame2 = kq_1.CFrame
                end
                local kr_1 = kp_1[1]
                local Position = kr_1:GetPivot().Position
                if (kq_1.Position - Position).Magnitude > 12 then
                    kq_1.CFrame = CFrame.new(Position + Vector3.new(0, 5, 0))
                end
            elseif CFrame2 then
                if kq_1 and Toggles.ReturnAfterUnlock.Value then
                    kq_1.CFrame = CFrame2
                end
                CFrame2 = nil
            end
        elseif CFrame2 then
            local kp_4 = h1()
            if kp_4 and Toggles.ReturnAfterUnlock.Value then
                kp_4.CFrame = CFrame2
            end
            CFrame2 = nil
        end
    end
end
local function onCopyJoinScript_JobID()
    local a6 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, ie)
    h2(a6, "Copied join script to clipboard")
end
local function autoMutationLoop()
    while not Library.Unloaded do
        task.wait(Options.MutationClickDelay.Value)
        if Toggles.AutoMutation.Value and firesignal then
            local lI_1 = LocalPlayer.PlayerGui:FindFirstChild(h3)
            if lI_1 then
                for i, descendant in ipairs(lI_1:GetDescendants()) do
                    if descendant:IsA("TextButton") then
                        pcall(firesignal, descendant.Activated)
                    end
                end
            end
        end
    end
end
local function fn485()
    local kO = {}
    for i, v in ipairs(CollectionService:GetTagged(ia)) do
        local attr = v:GetAttribute("uuid")
        if attr then
            table.insert(kO, attr)
        end
    end
    return kO
end
local function fn488()
    connection:Disconnect()
    connection2:Disconnect()
    local mg = h1()
    if mg then
        mg.Anchored = false
    end
end
local function autoBuyChickensLoop()
    while not Library.Unloaded do
        task.wait(Options.BuyChickenDelay.Value)
        if Toggles.AutoBuyChickens.Value then
            local chicken = id().chickenFarm.chicken
            if chicken and (not Toggles.OnlyHugeChickens.Value or chicken.size == "Huge") then
                pcall(function()
                    Events.chickenFarm.buyChicken()
                end)
            end
        end
    end
end
local function fn524()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    iA = tick()
end
local function onInputBegan()
    iE = tick()
end
local function fn587()
    return Toggles.AutoHarvest.Value
end
local function autoSpinLoop()
    while not Library.Unloaded do
        task.wait(Options.SpinDelay.Value)
        if Toggles.AutoSpin.Value then
            pcall(function()
                Events.seedsMachine.drawSeeds(Options.SpinQuality.Value)
            end)
        end
    end
end
local function fn609(aj, ak, al)
    local Magnitude = (aj.Position - ak.Position).Magnitude
    if Magnitude < 4 then
        return true
    end
    local jD = math.clamp(Magnitude / Options.TweenSpeed.Value, 0.05, 8)
    aj.Anchored = true
    local jC_1 = TweenService:Create(aj, TweenInfo.new(jD, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { CFrame = ak })
    jC_1:Play()
    local jE = 0
    while jC_1.PlaybackState == Enum.PlaybackState.Playing do
        jE += task.wait()
        local jF = Library.Unloaded or not al() or jE > jD + 2
        if jF then
            jC_1:Cancel()
            aj.Anchored = false
            return false
        end
    end
    aj.Anchored = false
    return true
end
local function fn611()
    local Character = LocalPlayer.Character
    local jw = Character and Character:FindFirstChild("HumanoidRootPart")
    return jw
end
local function fn625()
    local jJ_1
    local jI_1
    if identifyexecutor then
        jJ_1, jI_1 = identifyexecutor()
        local jK = jJ_1 ~= ""
        local jL = type(jJ_1) == "string" and jK
        if jL then
            local jK_1 = type(jI_1) == "string" and jI_1 ~= "" and jJ_1 .. " " .. jI_1
            hY = jK_1 or jJ_1
        end
    end
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local mc = tick() - iE
            local md = tick() - iA
            if mc >= 300 and md >= 60 then
                pcall(ig)
            else
                if mc < 300 and md >= 300 then
                    pcall(ig)
                end
            end
        end
    end
end
local function fn653()
    return peek(localPlayerSessionAtom)
end
local function onUnload()
    Library:Unload()
end
local function onInputChanged(fk)
    local UserInputType = fk.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        iE = tick()
    end
end
local function worker()
    local jO_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local jN = math.floor(os.clock() - hR)
        if jN < 60 then
            jO_1 = jN .. "s"
        elseif jN < 3600 then
            jO_1 = string.format("%dm %ds", math.floor((jN) / (60)), jN % 60)
        else
            jO_1 = string.format("%dh %dm", math.floor((jN) / (3600)), math.floor((jN % 3600) / (60)))
        end
        ik:SetText(ib("Session time", jO_1, iz))
    end
end
hR = nil
LocalPlayer = nil
connection = nil
TweenService = nil
hY = nil
VirtualUser = nil
h1 = nil
h2 = nil
h3 = nil
CollectionService = nil
OnoeNum = nil
ia = nil
ib = nil
peek = nil
id = nil
ie = nil
ig = nil
localPlayerSessionAtom = nil
ik = nil
Options = nil
Events = nil
Toggles = nil
ir = nil
connection2 = nil
it = nil
iu = nil
ix = nil
Library = nil
iz = nil
iA = nil
iC = nil
iE = nil
local OrderedGadgets, hT, GadgetsData, hX, h_, BackpackUtils, h4, h5, RebirthUtils, ih, ii, im, iq, iv, iw, iB, iD
local SeedMachineGroup
local iF_2
Library, Toggles, Options, CollectionService, VirtualUser, TweenService, LocalPlayer, ix, iu, Events, localPlayerSessionAtom, peek, OnoeNum, RebirthUtils, BackpackUtils, GadgetsData, OrderedGadgets, iv, it, iq, im, ih, ia, h3, hX, hT, iD = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
TweenService = game:GetService("TweenService")
LocalPlayer = Players.LocalPlayer
local iS = "Farm an Island"
ix = "https://discord.gg/K7Qxnxkk46"
iu = "https://discord.gg/K7Qxnxkk46"
local TS = LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("TS")
Events = require(TS:WaitForChild("network")).Events
localPlayerSessionAtom = require(TS.states.localPlayerSessionAtom).localPlayerSessionAtom
peek = require(ReplicatedStorage.rbxts_include.node_modules["@rbxts"].charm).peek
OnoeNum = require(ReplicatedStorage.rbxts_include.node_modules["@rbxts"].serikanum.SerikaNum).OnoeNum
RebirthUtils = require(ReplicatedStorage.TS.utils["Rebirth.utils"]).RebirthUtils
BackpackUtils = require(ReplicatedStorage.TS.utils["Backpack.utils"]).BackpackUtils
local Gadgets_data = require(ReplicatedStorage.TS.data.gadgets["Gadgets.data"])
GadgetsData = Gadgets_data.GadgetsData
OrderedGadgets = Gadgets_data.OrderedGadgets
local iL = tostring(LocalPlayer.UserId)
iv = "HarvestableTile_" .. iL
it = "UnlockableTile_" .. iL
iq = "TileGift_" .. iL
im = "SeedTool_" .. iL
ih = "GadgetTool_" .. iL
ia = "Pet_" .. iL
h3 = "MutationMiniGameScreenPanel"
local iN = { "AMAZING", "GOOD", "OK" }
hX = { "Slot_1", "Slot_2", "Slot_3", "Slot_4", "Slot_5", "Slot_6" }
hT = { Watering_Can = "useWateringCan", Fertilizer = "useFertilizer", Spray = "useSpray" }
iD = { Treat = "useTreat", Toy = "useToy" }
local iR = {}
local iM = {}
local GameInfoGroup
for i, v in ipairs(OrderedGadgets) do
    local displayName = GadgetsData[v].displayName
    table.insert(iR, displayName)
    iM[displayName] = v
end
iz, id, h1, iB, h_, h2, iC, ir, ib = nil, nil, nil, nil, nil, nil, nil, nil, nil
id = fn653
h1 = fn611
iB = function(aa)
    local jz_1
    local jy_1
    if type(aa) ~= "table" then
        return false
    end
    jy_1, jz_1 = pcall(function()
        return OnoeNum.new(aa):lessEquals(OnoeNum.new(id().currency))
    end)
    return jy_1 and jz_1
end
h_ = fn609
h2 = fn327
iC = fn334
ir = fn319
ib = fn104
local iK_1 = "#7fd47f"
local iJ_1 = "#6ec1ff"
iz = "#e8a34d"
local iT = "#8b93a3"
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = ix, Copyable = true }, "|", iS },
    Icon = 12645376577,
    Size = UDim2.fromOffset(980, 620),
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local iH_1
local iL_1 = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "sprout"),
    Settings = Window:AddTab("Settings", "settings")
}
iL_1.Farming = iL_1.Main:AddSubTab("Farming", "wheat")
iL_1.Seeds = iL_1.Main:AddSubTab("Seeds", "dices")
iL_1.Gear = iL_1.Main:AddSubTab("Gear", "wrench")
iL_1.Chickens = iL_1.Main:AddSubTab("Chickens", "egg")
iL_1.Progress = iL_1.Main:AddSubTab("Progress", "trending-up")
for k, v in iL_1 do
    if v ~= iL_1.Main then
        fn213(v)
    end
end
hY, iF_2, GameInfoGroup, ik, ie, iH_1 = nil, nil, nil, nil, nil, nil
local iG_1 = 8
repeat
    local iI_2 = (iG_1 * 2 + 2) % 3 + 1
    if iI_2 <= 2 then
        if iI_2 <= 1 then
            local iI_3 = (vector.create((iG_1 * 7 + 3) % 11 + 1, (iG_1 * 3 + 4) % 13 + 1, (iG_1 * 1 + 10) % 17 + 1))
            local iU_1 = (vector.create((iG_1 * 4 + 4) % 11 + 1, (iG_1 * 8 + 10) % 13 + 1, (iG_1 * 10 + 8) % 17 + 1))
            local mO = vector.cross(iI_3, iU_1)
            local mP = vector.dot(iI_3, iU_1)
            if vector.dot(mO, mO) + mP * mP == vector.dot(iI_3, iI_3) * vector.dot(iU_1, iU_1) then
                hY = "Unknown"
                pcall(fn625)
                iF_2 = iL_1.Info:AddLeftGroupbox("Account", "circle-user")
                iF_2:AddLabel(ib("User", LocalPlayer.Name, iK_1), true)
                iF_2:AddLabel(ib("Status", "Keyless", iK_1), true)
                iF_2:AddLabel(ib("Executor", hY, iK_1), true)
                GameInfoGroup = iL_1.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                GameInfoGroup:AddLabel(ir(iS .. " [" .. tostring(game.PlaceId) .. "]", iJ_1), true)
                GameInfoGroup:AddLabel(ib("Place ID", tostring(game.PlaceId), iJ_1), true)
                ik = GameInfoGroup:AddLabel(ib("Session time", "0s", iz), true)
            else
                ib = "Unknown"
                pcall(fn625)
                iJ_1 = hY.Info:AddLeftGroupbox("Account", "circle-user")
                iJ_1:AddLabel(iK_1("User", nil, LocalPlayer), true)
                iJ_1:AddLabel(iK_1("Status", "Keyless", LocalPlayer), true)
                iJ_1:AddLabel(iK_1("Executor", ib, LocalPlayer), true)
                ik = hY.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                ik:AddLabel(GameInfoGroup(iL_1 .. " [" .. tostring(game.PlaceId) .. "]", iF_2), true)
                ik:AddLabel(iK_1("Place ID", tostring(game.PlaceId), iF_2), true)
                iS = ik:AddLabel(iK_1("Session time", "0s", ir), true)
            end
            iG_1 = (iG_1 + 2) % 24
        else
            local mM = bit32.rrotate(bit32.bxor(bit32.lrotate(iG_1, 31), string.byte(tostring(iF_2))), 3)
            if bit32.bxor(bit32.lrotate(bit32.bxor(mM, 2587666931), 22), 2095484714) ~= bit32.lrotate(mM, 22) then
                iF_2 = tostring(game.JobId)
            else
                ie = tostring(game.JobId)
            end
            iG_1 = (iG_1 + 5) % 24
        end
    else
        if iG_1 * 54290303 + 1 + 7 >= iG_1 * 54290303 + 1 + 7 + 1 then
            ie = #iH_1 > 18
        else
            iH_1 = #ie > 18
        end
        iG_1 = (iG_1 + 20) % 24
    end
until (iG_1 * 17 + 21) % 24 == 16
if iH_1 then
    local iF_3 = 2
    repeat
        local iG_2 = (vector.create((iF_3 * 1 + 5) % 11 + 1, (iF_3 * 3 + 12) % 13 + 1, (iF_3 * 15 + 12) % 17 + 1))
        local iI_4 = (vector.create((iF_3 * 2 + 9) % 11 + 1, (iF_3 * 8 + 11) % 13 + 1, (iF_3 * 15 + 10) % 17 + 1))
        local nO = vector.cross(iG_2, iI_4)
        local nP = vector.dot(iG_2, iI_4)
        if vector.dot(nO, nO) + nP * nP == vector.dot(iG_2, iG_2) * vector.dot(iI_4, iI_4) then
            iH_1 = string.sub(ie, 1, 18) .. "..."
        else
            ie = string.sub(iH_1, 1, 18) .. "..."
        end
        iF_3 = (iF_3 + 5) % 8
    until (iF_3 * 5 + 2) % 8 == 5
end
local iF_4 = iH_1 or ie
hR, SeedMachineGroup, iE, iA, connection, connection2, ii, h5, iw, h4, ig = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
GameInfoGroup:AddLabel(ib("Server", iF_4, iT), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
hR = os.clock()
task.spawn(worker)
local ScriptsGroup = iL_1.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(ir("Included in this hub", iT), true)
ScriptsGroup:AddLabel(ir(iS, iJ_1), true)
local FeaturesGroup = iL_1.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(ir("Auto Harvest", iJ_1), true)
FeaturesGroup:AddLabel(ir("Auto Place Seeds", iJ_1), true)
FeaturesGroup:AddLabel(ir("Auto Buy Tiles", iz), true)
FeaturesGroup:AddLabel(ir("Auto Open Gifts", iz), true)
FeaturesGroup:AddLabel(ir("Auto Spin Seeds", iK_1), true)
FeaturesGroup:AddLabel(ir("Auto Buy Gear", iz), true)
FeaturesGroup:AddLabel(ir("Auto Use Gear", iz), true)
FeaturesGroup:AddLabel(ir("Auto Buy Chickens", iK_1), true)
FeaturesGroup:AddLabel(ir("Auto Place Chickens", iK_1), true)
FeaturesGroup:AddLabel(ir("Auto Mutation Minigame", iJ_1), true)
FeaturesGroup:AddLabel(ir("Auto Upgrades", iK_1), true)
FeaturesGroup:AddLabel(ir("Auto Rebirth", iT), true)
FeaturesGroup:AddLabel(ir("Auto Transfer Bank", iT), true)
local SocialsGroup = iL_1.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = iC })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = iL_1.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = iC })
local FaqGroup = iL_1.Info:AddRightGroupbox("FAQ", "circle-help")
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
local HarvestGroup = iL_1.Farming:AddLeftGroupbox("Harvest", "scissors")
HarvestGroup:AddToggle("AutoHarvest", { Text = "Auto Harvest", Default = false })
HarvestGroup:AddToggle("TweenToCrops", { Text = "Tween between crops", Default = true })
HarvestGroup:AddSlider("TweenSpeed", { Text = "Tween speed", Default = 80, Min = 20, Max = 400, Rounding = 0, Suffix = " studs/s" })
HarvestGroup:AddSlider("HarvestDelay", { Text = "Harvest delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Suffix = "s" })
local PlantingGroup = iL_1.Farming:AddLeftGroupbox("Planting", "sprout")
PlantingGroup:AddToggle("AutoPlaceSeeds", { Text = "Auto Place Seeds", Default = false })
PlantingGroup:AddSlider("PlaceDelay", { Text = "Place delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Suffix = "s" })
local TilesGroup = iL_1.Farming:AddRightGroupbox("Tiles", "hexagon")
TilesGroup:AddToggle("AutoBuyTiles", {
    Text = "Auto Buy Tiles",
    Default = false,
    Tooltip = "Moves your character onto locked tiles so the server drains cash into them"
})
TilesGroup:AddToggle("ReturnAfterUnlock", { Text = "Return to start position", Default = true })
local GiftsGroup = iL_1.Farming:AddRightGroupbox("Gifts", "gift")
GiftsGroup:AddToggle("AutoOpenGifts", { Text = "Auto Open Gifts", Default = false })
local MutationGroup = iL_1.Farming:AddRightGroupbox("Mutation", "wand-sparkles")
if (not ig or not ig or ig and not ig) and (not TempoHubGroup and not ig or ig and TempoHubGroup) or not ((not ig or not ig or ig and not ig) and (not TempoHubGroup and not ig or ig and TempoHubGroup)) then
    MutationGroup:AddToggle("AutoMutation", { Text = "Auto Press Mutation", Default = false })
    MutationGroup:AddSlider("MutationClickDelay", { Text = "Press delay", Default = 0.05, Min = 0.02, Max = 0.5, Rounding = 2, Suffix = "s" })
    SeedMachineGroup = iL_1.Seeds:AddLeftGroupbox("Seed Machine", "dices")
else
    iL_1:AddToggle("AutoMutation", { Text = "Auto Press Mutation", Default = false })
    iL_1:AddSlider("MutationClickDelay", { Max = 0.5, Suffix = "s", Text = "Press delay", Default = 0.05, Rounding = 2, Min = 0.02 })
    SeedMachineGroup.Seeds:AddLeftGroupbox("Seed Machine", "dices")
end
SeedMachineGroup:AddToggle("AutoSpin", { Text = "Auto Spin Seeds", Default = false })
SeedMachineGroup:AddDropdown("SpinQuality", { Text = "Spin quality", Values = iN, Default = 1 })
SeedMachineGroup:AddSlider("SpinDelay", { Text = "Spin delay", Default = 2, Min = 0.5, Max = 10, Rounding = 1, Suffix = "s" })
local SeedBuyingGroup = iL_1.Seeds:AddRightGroupbox("Seed Buying", "shopping-cart")
SeedBuyingGroup:AddToggle("AutoBuySeeds", { Text = "Auto Buy Drawn Seeds", Default = false })
SeedBuyingGroup:AddToggle("OnlyHugeSeeds", { Text = "Only buy Huge seeds", Default = false })
local GearShopGroup = iL_1.Gear:AddLeftGroupbox("Gear Shop", "shopping-cart")
GearShopGroup:AddToggle("AutoBuyGear", { Text = "Auto Buy Gear", Default = false })
GearShopGroup:AddDropdown("GearToBuy", {
    Text = "Gear to buy",
    Values = iR,
    Default = {},
    Multi = true,
    Searchable = true,
    AllowNull = true
})
GearShopGroup:AddSlider("BuyGearDelay", { Text = "Buy delay", Default = 3, Min = 1, Max = 30, Rounding = 0, Suffix = "s" })
local GearUsageGroup = iL_1.Gear:AddRightGroupbox("Gear Usage", "hand")
GearUsageGroup:AddToggle("AutoUseGear", { Text = "Auto Place Gear", Default = false })
GearUsageGroup:AddToggle("UseGearOnChickens", { Text = "Use treats and toys on chickens", Default = true })
GearUsageGroup:AddSlider("UseGearDelay", { Text = "Place delay", Default = 2, Min = 0.5, Max = 30, Rounding = 1, Suffix = "s" })
local ChickenFarmGroup = iL_1.Chickens:AddLeftGroupbox("Chicken Farm", "shopping-basket")
ChickenFarmGroup:AddToggle("AutoBuyChickens", { Text = "Auto Buy Chickens", Default = false })
ChickenFarmGroup:AddToggle("OnlyHugeChickens", { Text = "Only buy Huge chickens", Default = false })
ChickenFarmGroup:AddSlider("BuyChickenDelay", { Text = "Buy delay", Default = 1, Min = 0.5, Max = 10, Rounding = 1, Suffix = "s" })
local ChickenPlacingGroup = iL_1.Chickens:AddRightGroupbox("Chicken Placing", "map-pin")
ChickenPlacingGroup:AddToggle("AutoPlaceChickens", { Text = "Auto Place Chickens", Default = false })
ChickenPlacingGroup:AddToggle("OnlyPlaceHugeChickens", { Text = "Only place Huge chickens", Default = false })
local UpgradesGroup = iL_1.Progress:AddLeftGroupbox("Upgrades", "arrow-big-up")
UpgradesGroup:AddToggle("AutoUpgrades", { Text = "Auto Upgrades", Default = false })
UpgradesGroup:AddToggle("UpgradeGrowthSpeed", { Text = "Growth Speed", Default = true })
UpgradesGroup:AddToggle("UpgradeHarvestTool", { Text = "Harvest Tool", Default = true })
UpgradesGroup:AddToggle("UpgradeSeedLuck", { Text = "Seed Luck", Default = true })
UpgradesGroup:AddToggle("UpgradeMachineSlot", { Text = "Seed Machine Slot", Default = true })
UpgradesGroup:AddSlider("UpgradeDelay", { Text = "Upgrade delay", Default = 3, Min = 1, Max = 30, Rounding = 0, Suffix = "s" })
local BankGroup = iL_1.Progress:AddRightGroupbox("Bank", "banknote")
BankGroup:AddToggle("AutoBank", { Text = "Auto Transfer Bank", Default = false })
BankGroup:AddSlider("BankDelay", { Text = "Transfer delay", Default = 5, Min = 1, Max = 60, Rounding = 0, Suffix = "s" })
local RebirthGroup = iL_1.Progress:AddRightGroupbox("Rebirth", "rotate-ccw")
RebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
local MenuGroup = iL_1.Settings:AddLeftGroupbox("Menu", "menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
Library.ToggleKeybind = Options.MenuKeybind
ii = fn587
if (connection2 and not GiftsGroup and (not connection2 and not GearUsageGroup) and ((not GearUsageGroup or GiftsGroup) and (connection2 and not GearUsageGroup)) or (not GiftsGroup or GearUsageGroup) and (not GiftsGroup and GiftsGroup) and ((not GearUsageGroup or GiftsGroup) and (GearUsageGroup or connection2)) or (GearUsageGroup and GearUsageGroup or not connection2 and connection2 or not GiftsGroup and GiftsGroup and (connection2 or not GearUsageGroup)) and (GiftsGroup and not GiftsGroup or connection2 and not connection2 or (GiftsGroup and connection2 or (not GiftsGroup or GiftsGroup)))) and not (connection2 and not GiftsGroup and (not connection2 and not GearUsageGroup) and ((not GearUsageGroup or GiftsGroup) and (connection2 and not GearUsageGroup)) or (not GiftsGroup or GearUsageGroup) and (not GiftsGroup and GiftsGroup) and ((not GearUsageGroup or GiftsGroup) and (GearUsageGroup or connection2)) or (GearUsageGroup and GearUsageGroup or not connection2 and connection2 or not GiftsGroup and GiftsGroup and (connection2 or not GearUsageGroup)) and (GiftsGroup and not GiftsGroup or connection2 and not connection2 or (GiftsGroup and connection2 or (not GiftsGroup or GiftsGroup)))) then
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(Options.HarvestDelay.Value)
            if Toggles.AutoHarvest.Value then
                for i, v in ipairs(CollectionService:GetTagged(iv)) do
                    if Library.Unloaded or not Toggles.AutoHarvest.Value then
                        break
                    else
                        local attr = v:GetAttribute("hexName")
                        local jR_3 = attr and v:IsDescendantOf(workspace)
                        if jR_3 then
                            local jR_4 = true
                            if Toggles.TweenToCrops.Value then
                                local jS = h1()
                                if jS then
                                    jR_4 = h_(jS, CFrame.new(v:GetPivot().Position + Vector3.new(0, 6, 0)), ii)
                                end
                            end
                            if jR_4 then
                                pcall(function()
                                    Events.seeds.harvestLocalPlayerTile(attr)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(Options.PlaceDelay.Value)
            if Toggles.AutoPlaceSeeds.Value then
                for i, child in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    local j8 = child
                    if Library.Unloaded or not Toggles.AutoPlaceSeeds.Value then
                        break
                    elseif CollectionService:HasTag(j8, im) then
                        local attr = j8:GetAttribute(BackpackUtils.SEED_NAME_ATTRIBUTE)
                        local j_
                        for k, v in pairs(id().tiles) do
                            if v.status == "unlocked" and not v.plant then
                                j_ = k
                                break
                            end
                        end
                        if attr and j_ then
                            pcall(function()
                                Events.seeds.placeSeed(j_, attr, j8:GetAttribute(BackpackUtils.SEED_LEVEL_ATTRIBUTE), j8:GetAttribute(BackpackUtils.SEED_MUTATION_ATTRIBUTE), j8:GetAttribute(BackpackUtils.SEED_SIZE_ATTRIBUTE))
                            end)
                            task.wait(0.3)
                        end
                    end
                end
            end
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AutoOpenGifts.Value then
                for i, v in ipairs(CollectionService:GetTagged(iq)) do
                    if Library.Unloaded or not Toggles.AutoOpenGifts.Value then
                        break
                    else
                        local attr = v:GetAttribute("hexName")
                        if attr then
                            pcall(function()
                                Events.tiles.openGift(attr)
                            end)
                            task.wait(0.3)
                        end
                    end
                end
            end
        end
    end)
    task.spawn(autoBuyTilesLoop)
    task.spawn(autoSpinLoop)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(0.75)
            if Toggles.AutoBuySeeds.Value then
                local seedsMachine = id().seedsMachine
                for i, v in ipairs(hX) do
                    local kE = v
                    if Library.Unloaded or not Toggles.AutoBuySeeds.Value then
                        break
                    else
                        local kw_3 = seedsMachine[kE]
                        local kx = kw_3 and kw_3.unlocked and kw_3.loadedSeed
                        local kx_3 = type(kx) == "table" and iB(kx.price)
                        if kx_3 then
                            if not Toggles.OnlyHugeSeeds.Value or kx.size == "Huge" then
                                pcall(function()
                                    Events.seedsMachine.buySeed(kE)
                                end)
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end
        end
    end)
else
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(Options.HarvestDelay.Value)
            if Toggles.AutoHarvest.Value then
                for i, v in ipairs(CollectionService:GetTagged(iv)) do
                    if Library.Unloaded or not Toggles.AutoHarvest.Value then
                        break
                    else
                        local attr = v:GetAttribute("hexName")
                        local jR_1 = attr and v:IsDescendantOf(workspace)
                        if jR_1 then
                            local jR_2 = true
                            if Toggles.TweenToCrops.Value then
                                local jS = h1()
                                if jS then
                                    jR_2 = h_(jS, CFrame.new(v:GetPivot().Position + Vector3.new(0, 6, 0)), ii)
                                end
                            end
                            if jR_2 then
                                pcall(function()
                                    Events.seeds.harvestLocalPlayerTile(attr)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(Options.PlaceDelay.Value)
            if Toggles.AutoPlaceSeeds.Value then
                for i, child in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    local j8 = child
                    if Library.Unloaded or not Toggles.AutoPlaceSeeds.Value then
                        break
                    elseif CollectionService:HasTag(j8, im) then
                        local attr = j8:GetAttribute(BackpackUtils.SEED_NAME_ATTRIBUTE)
                        local j_
                        for k, v in pairs(id().tiles) do
                            if v.status == "unlocked" and not v.plant then
                                j_ = k
                                break
                            end
                        end
                        if attr and j_ then
                            pcall(function()
                                Events.seeds.placeSeed(j_, attr, j8:GetAttribute(BackpackUtils.SEED_LEVEL_ATTRIBUTE), j8:GetAttribute(BackpackUtils.SEED_MUTATION_ATTRIBUTE), j8:GetAttribute(BackpackUtils.SEED_SIZE_ATTRIBUTE))
                            end)
                            task.wait(0.3)
                        end
                    end
                end
            end
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AutoOpenGifts.Value then
                for i, v in ipairs(CollectionService:GetTagged(iq)) do
                    if Library.Unloaded or not Toggles.AutoOpenGifts.Value then
                        break
                    else
                        local attr = v:GetAttribute("hexName")
                        if attr then
                            pcall(function()
                                Events.tiles.openGift(attr)
                            end)
                            task.wait(0.3)
                        end
                    end
                end
            end
        end
    end)
    task.spawn(autoBuyTilesLoop)
    task.spawn(autoSpinLoop)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(0.75)
            if Toggles.AutoBuySeeds.Value then
                local seedsMachine = id().seedsMachine
                for i, v in ipairs(hX) do
                    local kE = v
                    if Library.Unloaded or not Toggles.AutoBuySeeds.Value then
                        break
                    else
                        local kw_1 = seedsMachine[kE]
                        local kx = kw_1 and kw_1.unlocked and kw_1.loadedSeed
                        local kx_1 = type(kx) == "table" and iB(kx.price)
                        if kx_1 then
                            if not Toggles.OnlyHugeSeeds.Value or kx.size == "Huge" then
                                pcall(function()
                                    Events.seedsMachine.buySeed(kE)
                                end)
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end
        end
    end)
    h5 = fn271
end
do
    iw = fn485
    h4 = fn141
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(Options.BuyGearDelay.Value)
            if Toggles.AutoBuyGear.Value then
                for i, v in ipairs(OrderedGadgets) do
                    local k7 = v
                    if Library.Unloaded or not Toggles.AutoBuyGear.Value then
                        break
                    elseif Options.GearToBuy.Value[GadgetsData[k7].displayName] then
                        local k__1 = id().gadgetShop.stock[k7]
                        local k0 = k__1 and k__1.amountLeft > 0 and iB(GadgetsData[k7].price)
                        if k0 then
                            pcall(function()
                                Events.gadgets.buyGadgetFromShop(k7)
                            end)
                            task.wait(0.3)
                        end
                    end
                end
            end
        end
    end)
    task.spawn(function()
        local k8 = 0
        local li = false
        repeat
            if not Library.Unloaded then
                task.wait(Options.UseGearDelay.Value)
                if Toggles.AutoUseGear.Value then
                    local lc = h5()
                    local k9 = iw()
                    for i, child in ipairs(LocalPlayer.Backpack:GetChildren()) do
                        if Library.Unloaded or not Toggles.AutoUseGear.Value then
                            break
                        else
                            local le_1 = CollectionService:HasTag(child, ih) and child:GetAttribute(BackpackUtils.GADGET_NAME_ATTRIBUTE)
                            local lb = le_1
                            local le_2 = lb and GadgetsData[lb]
                            if le_2 then
                                local la = hT[le_2.properties.type]
                                local ld = iD[le_2.properties.type]
                                if la and #lc > 0 then
                                    k8 = k8 % #lc + 1
                                    h4(child)
                                    pcall(function()
                                        Events.gadgets[la](lc[k8], lb)
                                    end)
                                    task.wait(0.3)
                                else
                                    if ld and Toggles.UseGearOnChickens.Value and #k9 > 0 then
                                        h4(child)
                                        pcall(function()
                                            Events.gadgets[ld](k9[1], lb)
                                        end)
                                        task.wait(0.3)
                                    end
                                end
                            end
                        end
                    end
                end
            else
                li = true
            end
        until li
    end)
    task.spawn(autoBuyChickensLoop)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AutoPlaceChickens.Value then
                for k, v in pairs(id().inventory.pets) do
                    local lz = k
                    if Library.Unloaded or not Toggles.AutoPlaceChickens.Value then
                        break
                    end
                    for k, v in pairs(v) do
                        local lF = k
                        if not Toggles.OnlyPlaceHugeChickens.Value or lF == "Huge" then
                            if v.amount > v.amountEquipped then
                                pcall(function()
                                    Events.pets.equipPet(lz, lF)
                                end)
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end
        end
    end)
    task.spawn(autoMutationLoop)
    task.spawn(autoUpgradesLoop)
    task.spawn(autoBankLoop)
    task.spawn(function()
        local lW_1
        local lV_1
        local l_ = false
        repeat
            local lU
            if not Library.Unloaded then
                task.wait(5)
                if Toggles.AutoRebirth.Value then
                    lU = id()
                    lV_1, lW_1 = pcall(function()
                        return RebirthUtils.canRebirth(lU.rebirths, lU.tiles, lU.index.seeds)
                    end)
                    if lV_1 and lW_1 then
                        pcall(function()
                            Events.rebirth.perform()
                        end)
                    end
                end
            else
                l_ = true
            end
        until l_
    end)
    iE = tick()
end
iA = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local l6 = v
        pcall(function()
            l6:Disable()
        end)
    end
end)
ig = fn524
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
task.spawn(antiAfkLoop)
Library:OnUnload(fn488)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(iL_1.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/farm-an-island")
SaveManager:BuildConfigSection(iL_1.Settings)
SaveManager:LoadAutoloadConfig()
end)(...)

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
getgenv().TempoHoodSubtitle = "ANIME GIRL PAINT BY NUMBERS"
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
local jW
local __tempo_gen
local kh
local SaveManager
local jG
local j1
local kn
local jJ
local j4
local j7
local Workspace
local ka
local jS
local kd
local kg
local jV
local kD
local HttpService
local kG
local jF
local CurrentCamera
local jY
local km
local kp
local j3
local jL
local j6
local ks
local j9
local kw
local Label
local kz
local jU
local connection
local jX
local ki
local kF
local j_
local kl
local connection2
local Options
local j5
local jK
local kv
local kb
local ke
local jT
local kB
local function fn7(bu, bv)
    return string.format('<font color="%s">%s</font>', bv, bu)
end
local function fn10()
    local mb_1
    local ma_1
    if identifyexecutor then
        mb_1, ma_1 = identifyexecutor()
        local mc = mb_1 ~= ""
        local md = type(mb_1) == "string" and mc
        if md then
            local mc_1 = type(ma_1) == "string" and ma_1 ~= "" and mb_1 .. " " .. ma_1
            ke = mc_1 or mb_1
        end
    end
end
local function onCopyJoinScript_JobID()
    local mi = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, jV)
    if setclipboard then
        setclipboard(mi)
    elseif toclipboard then
        toclipboard(mi)
    end
    j4:Notify("Copied join script to clipboard")
end
local function fn55()
    if not workspace.CurrentCamera then
        return
    end
    kn:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    kn:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    kD = tick()
end
local function fn109()
    setthreadidentity(8)
end
local function onCopyVenmoLink()
    j9(jT, "Copied Venmo link")
end
local function onUnload()
    j4:Unload()
end
local function fn190(bx, by, bz)
    return string.format("<b>%s</b> %s %s", bx, jK("-", "#5a6070"), jK(by, bz))
end
local function onCopyEthereumAddress()
    j9(j3, "Copied Ethereum address")
end
local function fn221()
    local nH = {}
    for i, v in ipairs({ kl, Options }) do
        for k, v in pairs(v) do
            local nI = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if nI then
                local nI_1 = kh(k, v)
                if nI_1 then
                    nH[#nH + 1] = nI_1
                end
            end
        end
    end
    table.sort(nH, function(eJ, eK)
        if eJ.type ~= eK.type then
            return eJ.type < eK.type
        end
        return eJ.idx < eK.idx
    end)
    return { objects = nH }
end
local function onRscripts()
    if setclipboard then
        setclipboard(kd)
    elseif toclipboard then
        toclipboard(kd)
    end
    j4:Notify("Copied Rscripts profile to clipboard")
end
local function fn252()
    local lP = jU()
    if not lP then
        return nil
    end
    local Systems = lP:FindFirstChild("Systems")
    if not Systems then
        return nil
    end
    return Systems:FindFirstChild("CanvasBaseParts")
end
local function onCopyBitcoinAddress()
    j9(j5, "Copied Bitcoin address")
end
local function fn300(bp)
    local DiscordGroup = bp:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = j1 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = j1 })
end
local function onImportConfigFromClipboardTex()
    local n9_1
    local n7 = Options.SaveManager_ImportSource.Value
    local n7_1
    local od = if n7 then 1 else 0
    local ob = 2661 * od + 2924 * (1 - od)
    local oc = 2172 * od + 1043 * (1 - od)
    if not ((ob * 3856 + oc * 475 + ob * oc) % 16777213 == 294995) then
        n7 = ""
    end
    local n8 = tostring(n7):match("^%s*(.-)%s*$")
    if n8 == "" then
        j4:Notify("Paste an exported config into the box first")
        return
    end
    n7_1, n9_1 = pcall(HttpService.JSONDecode, HttpService, n8)
    local n8_1 = not n7_1 or type(n9_1) ~= "table" or type(n9_1.objects) ~= "table"
    if n8_1 then
        j4:Notify("That is not a valid exported config")
        return
    end
    local n7_2 = 0
    for i, v in ipairs(n9_1.objects) do
        if kz(v) then
            n7_2 += 1
        end
    end
    if n7_2 == 0 then
        j4:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local n9_2 = n7_2 == 1 and "" or "s"
    j4:Notify(("Imported %d setting%s"):format(n7_2, n9_2), 6)
end
local function fn305()
    SaveManager:LoadAutoloadConfig()
end
local function onCopyPayPalLink()
    j9(jW, "Copied PayPal link")
end
local function fn311(C)
    local lg_1
    local lf_1
    lf_1, lg_1 = pcall(require, C)
    return lf_1 and lg_1 or nil
end
local function fn329(N)
    return N:GetAttributeChangedSignal("SelectedColorNumber")
end
local function fn330()
    if not kl.WalkSpeedEnabled.Value then
        local m0 = jS()
        if m0 then
            m0.WalkSpeed = 16
        end
    end
end
local function fn420()
    local Character = kg.Character
    local mD = Character and Character:FindFirstChildOfClass("Humanoid")
    return mD
end
local function onCopyLitecoinAddress()
    j9(j7, "Copied Litecoin address")
end
local function fn473()
    local Character = kg.Character
    local mG = Character and Character:FindFirstChild("HumanoidRootPart")
    return mG
end
local function onJumpRequest()
    if j4.Unloaded then
        return
    end
    if kl.InfJump and kl.InfJump.Value then
        local mQ_1 = jS()
        if mQ_1 then
            mQ_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn482(bi, bj)
    if setclipboard then
        setclipboard(bi)
    elseif toclipboard then
        toclipboard(bi)
    end
    j4:Notify(bj)
end
local function fn494()
    return not j4.Unloaded and jF.__tempo_gen == __tempo_gen
end
local function fn502()
    if not kl.Fly.Value then
        local mZ = jS()
        if mZ then
            mZ.PlatformStand = false
        end
    end
end
local function fn512(T)
    return T:GetAttribute("PictureBusy") == true
end
local function fn555()
    j4:Notify({ Title = "Tempo", Description = "Loaded for Anime Girl Paint by Numbers", Time = 4 })
end
local function fn563()
    jF.__tempo_gen = __tempo_gen + 1000
    jF.TempoHub_Library = nil
    if connection then
        connection:Disconnect()
    end
    if connection2 then
        connection2:Disconnect()
    end
    ka(false)
    pcall(function()
        Label:SetText("Status: Unloaded")
    end)
end
local function fn589()
    kw = false
end
local function fn601()
    local lL_2
    local lK_2
    local lH_1
    local lG = jL and jL.GetPlot
    local lG_1
    if lG then
        lG_1, lH_1 = pcall(function()
            return jL.GetPlot(kb)
        end)
        if lG_1 and lH_1 then
            return lH_1
        end
        local lG_2 = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("PlotModels") and Workspace.Map.PlotModels:FindFirstChild(kb.Name)
        local lH_2 = lG_2
        if not ((lK_2 * 3960 + lL_2 * 195 + lK_2 * lL_2) % 16777213 == 1824720) then
            lH_2 = nil
        end
        return lH_2
    end
    local lG_3 = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("PlotModels") and Workspace.Map.PlotModels:FindFirstChild(kb.Name)
    local lH_3 = lG_3
    local lM_2 = if lH_3 then 1 else 0
    lK_2 = 140 * lM_2 + 2942 * (1 - lM_2)
    lL_2 = 3792 * lM_2 + 2236 * (1 - lM_2)
    if not ((lK_2 * 3960 + lL_2 * 195 + lK_2 * lL_2) % 16777213 == 1824720) then
        lH_3 = nil
    end
    return lH_3
end
local function fn639(L)
    return L:GetAttribute("LoadedPicture")
end
local function fn649()
    j9(ki, "Copied Discord invite to clipboard")
end
local function antiAfkLoop()
    while not j4.Unloaded do
        task.wait(2)
        if kl.AntiAfk.Value then
            local nm = tick() - kG
            local nn = tick() - kD
            if nm >= 300 and nn >= 60 then
                pcall(ks)
            else
                if nm < 300 and nn >= 300 then
                    pcall(ks)
                end
            end
        end
    end
end
local function fn698(ev, ew)
    local Type = ew.Type
    if Type == "Toggle" then
        return { idx = ev, type = "Toggle", value = ew.Value == true }
    elseif Type == "Slider" then
        return { idx = ev, type = "Slider", value = tostring(ew.Value) }
    elseif Type == "Dropdown" then
        return { idx = ev, type = "Dropdown", multi = ew.Multi == true, value = ew.Value }
    elseif Type == "Input" then
        local nB = ew.Value or ""
        return { idx = ev, type = "Input", text = tostring(nB) }
    elseif Type == "ColorPicker" then
        return { idx = ev, type = "ColorPicker", value = ew.Value:ToHex(), transparency = ew.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = ev,
            type = "KeyPicker",
            mode = ew.Mode,
            key = ew.Value,
            modifiers = ew.Modifiers,
            toggled = ew.Toggled
        }
    else
        return nil
    end
end
local function onStepped()
    if j4.Unloaded then
        return
    end
    if kl.NoClip and kl.NoClip.Value then
        local Character = kg.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local mI_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if mI_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn703()
    ka(kl.AntiGameplayPause.Value)
end
local function onExportConfigToClipboard()
    local n1_1
    local n0_1
    n0_1, n1_1 = pcall(HttpService.JSONEncode, HttpService, j6())
    if not n0_1 then
        j4:Notify("Failed to encode the config")
        return
    end
    local n0_2 = setclipboard or toclipboard
    local n0_3 = type(n0_2) ~= "function" or not pcall(n0_2, n1_1)
    if n0_3 then
        j4:Notify("Your executor does not support copying to the clipboard")
        return
    end
    j4:Notify("Config copied to clipboard", 6)
end
local function fn779(en, eo)
    local nr = en == "Toggle" and kl
    local nw = if nr then 1 else 0
    local nu = 3921 * nw + 2107 * (1 - nw)
    local nv = 82 * nw + 3918 * (1 - nw)
    if not ((nu * 1381 + nv * 1144 + nu * nv) % 16777213 == 5830231) then
        nr = Options
    end
    local nr_1 = nr[eo]
    local nq_2 = type(nr_1) == "table" and nr_1.Type == en
    return nq_2 and nr_1 or nil
end
local function antiGameplayPauseLoop()
    while not j4.Unloaded do
        task.wait(1)
        if kl.AntiGameplayPause.Value then
            ka(true)
        end
    end
end
local function fn804()
    local lN = jU()
    if not lN then
        return nil
    end
    return lN:FindFirstChild("ActivePicture")
end
local function onRenderStepped(dm)
    if j4.Unloaded then
        return
    end
    if kl.WalkSpeedEnabled and kl.WalkSpeedEnabled.Value then
        local mV_1 = jS()
        if mV_1 then
            mV_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if kl.Fly and kl.Fly.Value then
        local mV_3 = jJ()
        local mW = jS()
        if mV_3 and mW then
            mW.PlatformStand = true
            local mW_1 = Vector3.zero
            if kp:IsKeyDown(Enum.KeyCode.W) then
                mW_1 = mW_1 + CurrentCamera.CFrame.LookVector
            end
            if kp:IsKeyDown(Enum.KeyCode.S) then
                mW_1 = mW_1 - CurrentCamera.CFrame.LookVector
            end
            if kp:IsKeyDown(Enum.KeyCode.A) then
                mW_1 = mW_1 - CurrentCamera.CFrame.RightVector
            end
            if kp:IsKeyDown(Enum.KeyCode.D) then
                mW_1 = mW_1 + CurrentCamera.CFrame.RightVector
            end
            if kp:IsKeyDown(Enum.KeyCode.Space) then
                mW_1 = mW_1 + Vector3.new(0, 1, 0)
            end
            if kp:IsKeyDown(Enum.KeyCode.LeftControl) then
                mW_1 = mW_1 - Vector3.new(0, 1, 0)
            end
            mV_3.Velocity = Vector3.zero
            if mW_1.Magnitude > 0 then
                mV_3.CFrame = mV_3.CFrame + mW_1.Unit * Options.FlySpeed.Value * dm
            end
        end
    end
end
local function onCopySolanaAddress()
    j9(jY, "Copied Solana address")
end
local function fn858()
    if kw then
        if os.clock() - kv > 150 then
            kw = false
            kw = true
            kv = os.clock()
            return true
        end
        return false
    end
    kw = true
    kv = os.clock()
    return true
end
local function fn869(O)
    local lk_1 = (kF.StarCashAmounts or { 100, 400, 1600 })[O.Stars] or 100
    local lm = 1 + (O.ColorCount or 0) * (kF.ColorMultiplier or 0.2)
    local floor = math.floor
    local ll_1 = O.PartCount or 0
    local ln = kF.PartMultiplier
    local lr = if ln then 1 else 0
    local lp = 2756 * lr + 3274 * (1 - lr)
    local lq = 2553 * lr + 1210 * (1 - lr)
    if not ((lp * 3875 + lq * 3658 + lp * lq) % 16777213 == 10277229) then
        ln = 0.0002
    end
    return floor(lk_1 * (lm + ll_1 * ln))
end
local function onInputBegan()
    kG = tick()
end
local function onCopyUSDTAddress()
    j9(j_, "Copied USDT address")
end
local function fn931(M)
    return M:GetAttribute("SelectedColorNumber")
end
local function onInputChanged(d6)
    local UserInputType = d6.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        kG = tick()
    end
end
local function worker()
    local ml_1
    while true do
        task.wait(1)
        if j4.Unloaded then
            break
        end
        local mk = math.floor(os.clock() - jG)
        if mk < 60 then
            ml_1 = mk .. "s"
        elseif mk < 3600 then
            ml_1 = string.format("%dm %ds", math.floor((mk) / (60)), mk % 60)
        else
            ml_1 = string.format("%dh %dm", math.floor((mk) / (3600)), math.floor((mk % 3600) / (60)))
        end
        jX:SetText(kB("Session time", ml_1, km))
    end
end
jF = nil
jG = nil
jJ = nil
jK = nil
jL = nil
Label = nil
jS = nil
jT = nil
jU = nil
jV = nil
jW = nil
jX = nil
jY = nil
SaveManager = nil
j_ = nil
CurrentCamera = nil
j1 = nil
connection2 = nil
j3 = nil
j4 = nil
j5 = nil
j6 = nil
j7 = nil
j9 = nil
ka = nil
kb = nil
kd = nil
ke = nil
connection = nil
kg = nil
kh = nil
ki = nil
HttpService = nil
kl = nil
km = nil
kn = nil
Options = nil
kp = nil
local jH, jI, jM, jN, jO, jP, jQ, kc, kk, kq, kr
ks = nil
Workspace = nil
kv = nil
kw = nil
kz = nil
kB = nil
kD = nil
__tempo_gen = nil
kF = nil
kG = nil
local kx, ky, kA, kC, kK, kL, kM, kN, kO, kP, kQ, kR, kS, kT, kU, kV, kX, k3, k4, k5, k6, k7
local kW_4
local kJ_1, kJ_7
jF = nil
pcall(fn109)
jF = getgenv()
local kH = jF.__tempo_gen
local le = if kH then 1 else 0
local lc = 2710 * le + 690 * (1 - le)
local ld = 2767 * le + 2661 * (1 - le)
if not ((lc * 352 + ld * 3245 + lc * ld) % 16777213 == 654192) then
    kH = 0
end
__tempo_gen, kJ_1 = nil, nil
local kI = 10
repeat
    kK = (kI * 1 + 1) % 2 + 1
    if kK <= 1 then
        kK = {
            "rllqw",
            "bpgfofpydq",
            "egf",
            "wlbsfi",
            "fcdvujcpf",
            "kwillfg",
            "nbyetfortod",
            "kssnk",
            "lwhg",
            "hkj"
        }
        local qb = kI
        kL = kK[qb % 10 + 1]
        if kL:len() <= kL:gsub("(.)", "%1%1", qb % 3 % 2 + 1):len() then
            kJ_1 = jF.TempoHub_Library
        else
            jF = kJ_1.TempoHub_Library
        end
        kI = (kI + 3) % 16
    else
        local qU = bit32.rrotate(bit32.bxor(bit32.lrotate(kI, 29), string.byte(tostring(kJ_1))), 22)
        if bit32.bxor(bit32.lrotate(bit32.bxor(qU, 1167314972), 12), 1023525977) ~= bit32.lrotate(qU, 12) then
            jF.__tempo_gen = __tempo_gen + 1
            jF = kH.__tempo_gen
        else
            jF.__tempo_gen = kH + 1
            __tempo_gen = jF.__tempo_gen
        end
        kI = (kI + 11) % 16
    end
until (kI * 7 + 1) % 16 == 9
if kJ_1 then
    local kH_1 = 3
    repeat
        kI = (vector.create((kH_1 * 1 + 1) % 11 + 1, (kH_1 * 8 + 6) % 13 + 1, (kH_1 * 5 + 11) % 17 + 1))
        kK = (vector.create((kH_1 * 2 + 8) % 11 + 1, (kH_1 * 4 + 13) % 13 + 1, (kH_1 * 8 + 5) % 17 + 1))
        local qY = vector.cross(kI, kK)
        local qZ = vector.dot(kI, kK)
        if vector.dot(qY, qY) + qZ * qZ == vector.dot(kI, kI) * vector.dot(kK, kK) then
            kJ_1 = type(jF.TempoHub_Library.Unload) == "function"
        else
            jF = type(kJ_1.TempoHub_Library.Unload) == "function"
        end
        kH_1 = (kH_1 + 0) % 4
    until (kH_1 * 3 + 3) % 4 == 0
end
if kJ_1 then
    pcall(function()
        jF.TempoHub_Library:Unload()
    end)
end
ky, Workspace, kp, kn, HttpService, kg, kb, kI, j4, SaveManager = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
ky = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
Workspace = game:GetService("Workspace")
if (not j4 or not j4 or ky and ky or (not kI or not kn) and (kg and not kg)) and not (not j4 or not j4 or ky and ky or (not kI or not kn) and (kg and not kg)) then
    kn = game:GetService("RunService")
    kM = game:GetService("UserInputService")
    kp = game:GetService("VirtualUser")
else
    kM = game:GetService("RunService")
    kp = game:GetService("UserInputService")
    kn = game:GetService("VirtualUser")
end
HttpService = game:GetService("HttpService")
kg = Players.LocalPlayer
kb = kg
local j8 = "Anime Girl Paint by Numbers"
j4 = getgenv().Library
kL = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
jF.TempoHub_Library = j4
kK = fn311
local kH_2 = {}
kI = kK(ky.Shared.Core.Storage.Game.PicturesLibrary) or kH_2
jP, jN, jL, jH = nil, nil, nil, nil
jP = kI
jN = kK(ky.Shared.Services.PictureService)
jL = kK(ky.Shared.Services.PlotService)
jH = kK(ky.Shared.Utility.Remoting)
local kH_3 = {}
kI = kK(ky.Shared.Constants) or kH_3
kF, kC = nil, nil
local kJ_3 = 2
repeat
    if (kJ_3 * 1 + 0) % 2 + 1 <= 1 then
        local kH_5 = (vector.create((kJ_3 * 6 + 5) % 11 + 1, (kJ_3 * 11 + 11) % 13 + 1, (kJ_3 * 4 + 13) % 17 + 1))
        local qK = vector.floor(kH_5) + vector.ceil(kH_5 * -1)
        if vector.dot(qK, qK) == 4 then
            kI = kF
        else
            kF = kI
        end
        kJ_3 = (kJ_3 + 1) % 8
    else
        if kJ_3 * 11506289 + 10 + 7 <= kJ_3 * 11506289 + 10 + 7 + 4 then
            kC = kK(ky.Client.Data.ClientDataManager)
        else
            ky = kC(kK.Client.Data.ClientDataManager)
        end
        kJ_3 = (kJ_3 + 5) % 8
    end
until (kJ_3 * 1 + 7) % 8 == 7
if not jN then
    local kH_6 = 7
    while true do
        do
            kI = (vector.create((kH_6 * 6 + 4) % 11 + 1, (kH_6 * 8 + 8) % 13 + 1, (kH_6 * 4 + 5) % 17 + 1))
            local kJ_4 = (vector.create((kH_6 * 1 + 5) % 11 + 1, (kH_6 * 3 + 10) % 13 + 1, (kH_6 * 5 + 2) % 17 + 1))
            local pP = vector.cross(kI, kJ_4)
            local pQ = vector.dot(kI, kJ_4)
            if vector.dot(pP, pP) + pQ * pQ == vector.dot(kI, kI) * vector.dot(kJ_4, kJ_4) + 5 then
                jN = {
                    GetLoadedPicture = fn639,
                    GetSelectedColorChangedSignal = fn329,
                    GetSelectedColor = fn931,
                    IsPictureBusy = fn512,
                    GetPriceForPicture = fn869
                }
            else
                jN = {
                    GetLoadedPicture = fn639,
                    GetSelectedColor = fn931,
                    GetSelectedColorChangedSignal = fn329,
                    GetPriceForPicture = fn869,
                    IsPictureBusy = fn512
                }
            end
            kH_6 = (kH_6 + 0) % 8
            if (kH_6 * 5 + 0) % 8 == 3 then
                break
            end
            continue
        end
    end
end
jQ, jO, jM, kw, kv, kN, Options, kl, ki, kd, kU, kT, kS, km, kR, ke, kI, kQ, jX, jV, kO, jI, kr, kk, kV, jU, kx, kq, kc, j9, j1, kP, jK, kB = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local kJ_5 = 55
repeat
    local kH_7 = (kJ_5 * 3 + 10) % 14 + 1
    if kH_7 <= 7 then
        if kH_7 <= 4 then
            if kH_7 <= 2 then
                if kH_7 <= 1 then
                    if kJ_5 * 97872457 + 9 + 3 >= kJ_5 * 97872457 + 9 + 3 + 1 then
                        kP = fn649
                        j1 = fn300
                    else
                        j1 = fn649
                        kP = fn300
                    end
                    kJ_5 = (kJ_5 + 19) % 56
                else
                    if kJ_5 * 92308933 + 13 + 5 <= kJ_5 * 92308933 + 13 + 5 + 6 then
                        kU = {
                            Info = kN:AddTab("Info", "info"),
                            Farming = kN:AddTab("Farming", "paintbrush"),
                            Player = kN:AddTab("Player", "person-standing"),
                            Settings = kN:AddTab("Settings", "settings")
                        }
                    else
                        kN = {
                            Info = kU:AddTab("Info", "info"),
                            Settings = kU:AddTab("Settings", "settings"),
                            Farming = kU:AddTab("Farming", "paintbrush"),
                            Player = kU:AddTab("Player", "person-standing")
                        }
                    end
                    kJ_5 = (kJ_5 + 33) % 56
                end
            elseif kH_7 <= 3 then
                local qq = bit32.rrotate(bit32.bxor(bit32.lrotate(kJ_5, 28), 104), 13)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(qq, 4127271287), 1826980994), (bit32.bxor(bit32.band(qq, 167696008), 3485267358))), 1826980994), 3485267358) ~= qq then
                    kN = fn7
                else
                    jK = fn7
                end
                kJ_5 = (kJ_5 + 47) % 56
            else
                if ((not kv or km) and (not kv or jX) and (kv and km and (not jX or jX)) and (not jI and kl or (not jI or not jX) or (km or not kl or (km or not jX))) or ((false or (jX or not jI)) and (not kl and not kl and (kv and jI)) or (false or jX) and (jX and false) and (jX and kv or (not jX or false)))) and not ((not kv or km) and (not kv or jX) and (kv and km and (not jX or jX)) and (not jI and kl or (not jI or not jX) or (km or not kl or (km or not jX))) or ((false or (jX or not jI)) and (not kl and not kl and (kv and jI)) or (false or jX) and (jX and false) and (jX and kv or (not jX or false)))) then
                    jX = fn190
                else
                    kB = fn190
                end
                kJ_5 = (kJ_5 + 19) % 56
            end
        elseif kH_7 <= 6 then
            if kH_7 <= 5 then
                local qj = bit32.rrotate(bit32.bxor(bit32.lrotate(kJ_5, 6), string.byte(tostring(kd))), 29)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(qj, 3456576803), 2932899728), (bit32.bxor(bit32.band(qj, 838390492), 1028699014))), 2932899728), 1028699014) ~= qj then
                    ke, kT, kB, kU = "#7fd47f", "#e8a34d", "#8b93a3", "#6ec1ff"
                    kR = "Unknown"
                    pcall(fn10)
                    kg = kI.Info:AddLeftGroupbox("Account", "circle-user")
                    kg:AddLabel(kS("User", nil, ke), true)
                    kg:AddLabel(kS("Status", "Keyless", ke), true)
                    kg:AddLabel(kS("Executor", "Unknown", ke), true)
                    jX = kI.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                    jX:AddLabel(j8(jK .. " [" .. tostring(game.PlaceId) .. "]", kU), true)
                    jX:AddLabel(kS("Place ID", tostring(game.PlaceId), kU), true)
                    kQ = jX:AddLabel(kS("Session time", "0s", kT), true)
                else
                    kT, kS, km, kR = "#7fd47f", "#6ec1ff", "#e8a34d", "#8b93a3"
                    ke = "Unknown"
                    pcall(fn10)
                    kI = kU.Info:AddLeftGroupbox("Account", "circle-user")
                    kI:AddLabel(kB("User", kg.Name, kT), true)
                    kI:AddLabel(kB("Status", "Keyless", kT), true)
                    kI:AddLabel(kB("Executor", ke, kT), true)
                    kQ = kU.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                    kQ:AddLabel(jK(j8 .. " [" .. tostring(game.PlaceId) .. "]", kS), true)
                    kQ:AddLabel(kB("Place ID", tostring(game.PlaceId), kS), true)
                    jX = kQ:AddLabel(kB("Session time", "0s", km), true)
                end
                kJ_5 = (kJ_5 + 47) % 56
            else
                local kW_1 = {
                    "kdhoogubxa",
                    "obr",
                    "liodwx",
                    "azfuzxhtqm",
                    "drsvp",
                    "bldn",
                    "kaeooof",
                    "mbbyforjstj",
                    "ytkvfp",
                    "vvfg"
                }
                local q_ = kJ_5
                kX = kW_1[q_ % 10 + 1]
                if kX:len() >= kX:reverse():rep(q_ % 3 + 2):len() then
                    kl = tostring(game.JobId)
                else
                    jV = tostring(game.JobId)
                end
                kJ_5 = (kJ_5 + 19) % 56
            end
        else
            local qd = bit32.rrotate(bit32.bxor(bit32.lrotate(kJ_5, 23), string.byte(tostring(kP))), 17)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(qd, 3206397229), 4185666976), (bit32.bxor(bit32.band(qd, 1088570066), 1119652877))), 4185666976), 1119652877) ~= qd then
                jV = #kO > 18
            else
                kO = #jV > 18
            end
            kJ_5 = (kJ_5 + 47) % 56
        end
    elseif kH_7 <= 11 then
        if kH_7 <= 9 then
            if kH_7 <= 8 then
                local kW_2 = (vector.create((kJ_5 * 6 + 2) % 11 + 1, (kJ_5 * 8 + 4) % 13 + 1, (kJ_5 * 14 + 16) % 17 + 1))
                kX = (vector.create((kJ_5 * 2 + 4) % 11 + 1, (kJ_5 * 2 + 11) % 13 + 1, (kJ_5 * 12 + 6) % 17 + 1))
                local kY = (vector.create((kJ_5 * 1 + 4) % 5 + 1, (kJ_5 * 2 + 4) % 7 + 1, (kJ_5 * 4 + 7) % 9 + 1))
                if math.abs((vector.angle(kW_2, kX, kY))) - math.abs((vector.angle(kX, kW_2, kY))) == 1 then
                    setthreadidentity(8)
                    jQ = function(V)
                        local lt_2
                        local ls = jH and type(jH.RemoteEvent) == "function"
                        local ls_4, Remotes
                        if ls then
                            ls_4, lt_2 = pcall(function()
                                return jH.RemoteEvent(V)
                            end)
                            if ls_4 and lt_2 then
                                return lt_2
                            end
                            local Remotes2 = ky:FindFirstChild("Remotes")
                            if Remotes then
                                return Remotes2:FindFirstChild(V)
                            end
                            return nil
                        end
                        Remotes = ky:FindFirstChild("Remotes")
                        if Remotes then
                            return Remotes:FindFirstChild(V)
                        end
                        return nil
                    end
                    jO = jQ("SelectNumber")
                    jM = jQ("StepNumber")
                    jQ("EquipPlotCanvasPicture")
                else
                    setthreadidentity(8)
                    kK = function(V)
                        local lt_1
                        local ls = jH and type(jH.RemoteEvent) == "function"
                        local ls_1, Remotes
                        if ls then
                            ls_1, lt_1 = pcall(function()
                                return jH.RemoteEvent(V)
                            end)
                            if ls_1 and lt_1 then
                                return lt_1
                            end
                            local Remotes2 = ky:FindFirstChild("Remotes")
                            if Remotes then
                                return Remotes2:FindFirstChild(V)
                            end
                            return nil
                        end
                        Remotes = ky:FindFirstChild("Remotes")
                        if Remotes then
                            return Remotes:FindFirstChild(V)
                        end
                        return nil
                    end
                    jQ = kK("SelectNumber")
                    jO = kK("StepNumber")
                    jM = kK("EquipPlotCanvasPicture")
                end
                kJ_5 = (kJ_5 + 47) % 56
            else
                local kW_3 = {
                    "xvnospcmd",
                    "ghhpk",
                    "ndpfxfq",
                    "xzinbvfewm",
                    "xrgretegl",
                    "vzebao",
                    "kjyppaf",
                    "wjyagffbomk",
                    "ipr",
                    "xijuexs",
                    "adjtuyzz"
                }
                local qi = kJ_5
                kX = kW_3[qi % 11 + 1]
                if kX:len() >= kX:gsub("(.)", "%1%1", qi % 3 % 2 + 1):len() then
                    kw = fn494
                    kr = false
                    jI = 0
                    kv = fn858
                else
                    jI = fn494
                    kw = false
                    kv = 0
                    kr = fn858
                end
                kJ_5 = (kJ_5 + 33) % 56
            end
        elseif kH_7 <= 10 then
            if (kJ_5 * 3 + 8) * 21 % 4 == ((kJ_5 * 3 + 8) * 21 + 5) % 4 then
                kI = fn589
            else
                kk = fn589
            end
            kJ_5 = (kJ_5 + 47) % 56
        else
            local pS = bit32.rrotate(bit32.bxor(bit32.lrotate(kJ_5, 11), 104), 28)
            if bit32.bxor(bit32.lrotate(bit32.bxor(pS, 1603075335), 12), 3486545400) ~= bit32.lrotate(pS, 12) then
                kq = function(au)
                    task.spawn(function()
                        local lD_2
                        local lC_2
                        setthreadidentity(8)
                        while jI() do
                            lC_2, lD_2 = pcall(au)
                            local lE = not lC_2
                            if lE ~= false then
                                lE = jI()
                            end
                            if lE then
                                warn("[TempoHub] loop error: " .. tostring(lD_2))
                                task.wait(1)
                            end
                        end
                    end)
                end
                kc = fn601
                jU = fn804
                kV = fn252
                kx = function()
                    local lY_2
                    local lX_2
                    local lW_2
                    local lT_3, lT_4
                    local lU_4, lU_6
                    if not kC then
                        return nil, nil
                    end
                    lT_3, lU_4 = pcall(function()
                        return kC.GetData()
                    end)
                    local lV = not lT_3 or not lU_4 or not lU_4.Pictures
                    local lV_2
                    if lV then
                        return nil, nil
                    end
                    lW_2, lV_2, lT_4 = nil, nil, -1
                    for k, v in pairs(lU_4.Pictures) do
                        if v and v.Completed then
                            local lS = jP[k]
                            if lS then
                                lX_2, lY_2 = pcall(function()
                                    return jN.GetPriceForPicture(lS)
                                end)
                                local lZ = lX_2 and type(lY_2) == "number"
                                if lZ then
                                    lU_6 = lY_2
                                else
                                    lU_6 = 0
                                end
                                if lU_6 > lT_4 then
                                    lT_4 = lU_6
                                    lW_2 = k
                                    lV_2 = lS
                                end
                            end
                        end
                    end
                    return lW_2, lV_2, lT_4
                end
            else
                kV = function(au)
                    task.spawn(function()
                        local lD_1
                        local lC_1
                        setthreadidentity(8)
                        while jI() do
                            lC_1, lD_1 = pcall(au)
                            local lE = not lC_1
                            if lE ~= false then
                                lE = jI()
                            end
                            if lE then
                                warn("[TempoHub] loop error: " .. tostring(lD_1))
                                task.wait(1)
                            end
                        end
                    end)
                end
                jU = fn601
                kx = fn804
                kq = fn252
                kc = function()
                    local lY_1
                    local lX_1
                    local lW_1
                    local lT_1, lT_2
                    local lU_1, lU_3
                    if not kC then
                        return nil, nil
                    end
                    lT_1, lU_1 = pcall(function()
                        return kC.GetData()
                    end)
                    local lV = not lT_1 or not lU_1 or not lU_1.Pictures
                    local lV_1
                    if lV then
                        return nil, nil
                    end
                    lW_1, lV_1, lT_2 = nil, nil, -1
                    for k, v in pairs(lU_1.Pictures) do
                        if v and v.Completed then
                            local lS = jP[k]
                            if lS then
                                lX_1, lY_1 = pcall(function()
                                    return jN.GetPriceForPicture(lS)
                                end)
                                local lZ = lX_1 and type(lY_1) == "number"
                                if lZ then
                                    lU_3 = lY_1
                                else
                                    lU_3 = 0
                                end
                                if lU_3 > lT_2 then
                                    lT_2 = lU_3
                                    lW_1 = k
                                    lV_1 = lS
                                end
                            end
                        end
                    end
                    return lW_1, lV_1, lT_2
                end
            end
            kJ_5 = (kJ_5 + 33) % 56
        end
    elseif kH_7 <= 13 then
        if kH_7 <= 12 then
            local qg = bit32.rrotate(bit32.bxor(bit32.lrotate(kJ_5, 24), string.byte(tostring(kk))), 1)
            if bit32.bxor(bit32.lrotate(bit32.bxor(qg, 104552771), 28), 811840916) ~= bit32.lrotate(qg, 28) then
                j4 = j8:CreateWindow({
                    Footer = { kN, "|", { Text = "https://discord.gg/K7Qxnxkk46", Copyable = true } },
                    Font = Enum.Font.BuilderSans,
                    CornerRadius = 0,
                    ShowCustomCursor = false,
                    NotifySide = "Right",
                    Title = "Tempo",
                    Icon = 78539693571783
                })
            else
                kN = j4:CreateWindow({
                    Title = "Tempo",
                    Font = Enum.Font.BuilderSans,
                    Footer = { { Text = "https://discord.gg/K7Qxnxkk46", Copyable = true }, "|", j8 },
                    Icon = 78539693571783,
                    NotifySide = "Right",
                    ShowCustomCursor = false,
                    CornerRadius = 0
                })
            end
            kJ_5 = (kJ_5 + 5) % 56
        else
            if kJ_5 * 89118083 + 5 + 1 <= kJ_5 * 89118083 + 5 + 1 + 2 then
                Options = j4.Options
            else
                j4 = Options.Options
            end
            kJ_5 = (kJ_5 + 33) % 56
        end
    else
        if (kB and not jO or (jO or not kB) or (jO or jQ or kP and kP)) and (kq and not kP and (kB or jO) or (kB or kB) and (kq or not kq)) or not ((kB and not jO or (jO or not kB) or (jO or jQ or kP and kP)) and (kq and not kP and (kB or jO) or (kB or kB) and (kq or not kq))) then
            kl = j4.Toggles
            ki = "https://discord.gg/K7Qxnxkk46"
            kd = "https://discord.gg/K7Qxnxkk46"
            j9 = fn482
        else
            j4 = nil
            kl = "https://discord.gg/K7Qxnxkk46"
            j9 = "https://discord.gg/K7Qxnxkk46"
            kd = fn482
        end
        kJ_5 = (kJ_5 + 47) % 56
    end
until (kJ_5 * 19 + 35) % 56 == 44
if kO then
    local kH_8 = 5
    repeat
        kI = {
            "zapwezojom",
            "fpcjxzbadct",
            "bls",
            "jheishaytop",
            "iypzmxyz",
            "bqpvporkpo",
            "fexwwf",
            "biraomjvy",
            "drmkh",
            "dvfwv",
            "gbg"
        }
        local qk = kH_8
        local kJ_6 = kI[qk % 11 + 1]
        if kJ_6:len() >= kJ_6:reverse():rep(qk % 3 + 2):len() then
            jV = string.sub(kO, 1, 18) .. "..."
        else
            kO = string.sub(jV, 1, 18) .. "..."
        end
        kH_8 = (kH_8 + 2) % 8
    until (kH_8 * 7 + 5) % 8 == 6
end
local kH_9 = kO
le = if kH_9 then 1 else 0
lc = 3819 * le + 525 * (1 - le)
ld = 3465 * le + 2962 * (1 - le)
if not ((lc * 1477 + ld * 1610 + lc * ld) % 16777213 == 7674935) then
    kH_9 = jV
end
jG, j7, j5, j3, j_, jY, jW, jT, k5, k6, Label = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
kO = kH_9
kQ:AddLabel(kB("Server", kO, kR), true)
kQ:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
jG = os.clock()
task.spawn(worker)
local ScriptsGroup = kU.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(jK("Included in this hub", kR), true)
ScriptsGroup:AddLabel(jK(j8, kS), true)
local FeaturesGroup = kU.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(jK("Auto Paint", kS), true)
FeaturesGroup:AddLabel(jK("Auto Place Best Picture", km), true)
FeaturesGroup:AddLabel(jK("Player Movement", kR), true)
local SocialsGroup = kU.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = j1 })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = kU.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = j1 })
j7 = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
j5 = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
j3 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
j_ = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
jY = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
jW = ""
jT = ""
kW_4, kN, kK, kJ_7, kI, k4, k3 = "#345d9d", "#f7931a", "#627eea", "#26a17b", "#14f195", "#0070ba", "#008cff"
local DonationsGroup = kU.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(jK("All donations are optional but appreciated.", km), true)
DonationsGroup:AddLabel(jK("If you donate you get a special role, just PING after you donate.", kT), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(jK("LTC / Litecoin", kW_4), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(jK("BTC / Bitcoin", kN), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(jK("ETH / Ethereum", kK), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(jK("USDT", kJ_7), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(jK("Solana", kI), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(jK("PayPal", k4), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(jK("Venmo", k3), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(jK("Don't have any of the listed currencies but still wanna donate?", kR), true)
DonationsGroup:AddLabel(jK("DM me and we'll work something out.", kS), true)
kX = kU.Info:AddRightGroupbox("FAQ", "circle-help")
if (DonationsGroup and not kN or (false or DonationsGroup)) and (DonationsGroup or kN or not kO and kO) or not ((DonationsGroup and not kN or (false or DonationsGroup)) and (DonationsGroup or kN or not kO and kO)) then
    kX:AddLabel("Where do I get a good config?", true)
    kX:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
    kX:AddLabel("How do I import / export configs?", true)
    kX:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
    kX:AddLabel("How do I report bugs?", true)
    kX:AddLabel("Join the Discord and post it in the bugs channel.", true)
    kX:AddLabel("How do I make suggestions?", true)
    kX:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
    kX:AddLabel("How do I get help or updates?", true)
    kX:AddLabel("Join the Discord, updates and support are posted there first.", true)
    kU.Farming:SetSubTabAlignment("Center")
    k5 = kU.Farming:AddSubTab("Painting", "brush")
else
    k5:AddLabel("Where do I get a good config?", true)
    k5:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
    k5:AddLabel("How do I import / export configs?", true)
    k5:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
    k5:AddLabel("How do I report bugs?", true)
    k5:AddLabel("Join the Discord and post it in the bugs channel.", true)
    k5:AddLabel("How do I make suggestions?", true)
    k5:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
    k5:AddLabel("How do I get help or updates?", true)
    k5:AddLabel("Join the Discord, updates and support are posted there first.", true)
    kX.Farming:SetSubTabAlignment("Center")
    kU = kX.Farming:AddSubTab("Painting", "brush")
end
if (false or (not DonationsGroup and not DonationsGroup or (not DonationsGroup or k4)) or (false and not DonationsGroup or (false or DonationsGroup)) and (false and (not DonationsGroup and false))) and not (false or (not DonationsGroup and not DonationsGroup or (not DonationsGroup or k4)) or (false and not DonationsGroup or (false or DonationsGroup)) and (false and (not DonationsGroup and false))) then
    kU = k6.Farming:AddSubTab("Canvas", "image")
else
    k6 = kU.Farming:AddSubTab("Canvas", "image")
end
kP(k5)
kP(k6)
kP(kU.Player)
local k8
local k9 = 0
repeat
    local qP = bit32.rrotate(bit32.bxor(bit32.lrotate(k9, 21), string.byte(tostring(k8))), 13)
    if bit32.bxor(bit32.lrotate(bit32.bxor(qP, 170462651), 22), 1858243139) ~= bit32.lrotate(qP, 22) then
        k7 = Label:AddRightGroupbox("Auto Paint", "paintbrush")
        k7:AddToggle("AutoPaint", { Text = "Auto Paint", Default = false })
        k7:AddSlider("AutoPaintInterval", { Min = 0.1, Text = "Interval", Default = 0.2, Rounding = 1, Suffix = "s", Max = 10 })
        k7:AddToggle("AutoPaintSmartCycle", { Text = "Smart Color Cycle", Default = true })
        k7:AddSlider("AutoPaintBatch", { Text = "Parts Per Tick", Min = 1, Max = 50, Default = 15, Suffix = " parts", Rounding = 0 })
        k5 = Label:AddRightGroupbox("Status", "activity")
        k8 = k5:AddLabel("Status: Idle", true)
    else
        k8 = k5:AddRightGroupbox("Auto Paint", "paintbrush")
        k8:AddToggle("AutoPaint", { Text = "Auto Paint", Default = false })
        k8:AddSlider("AutoPaintInterval", { Text = "Interval", Default = 0.2, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
        k8:AddToggle("AutoPaintSmartCycle", { Text = "Smart Color Cycle", Default = true })
        k8:AddSlider("AutoPaintBatch", { Text = "Parts Per Tick", Default = 15, Min = 1, Max = 50, Rounding = 0, Suffix = " parts" })
        k7 = k5:AddRightGroupbox("Status", "activity")
        Label = k7:AddLabel("Status: Idle", true)
    end
    k9 = (k9 + 0) % 4
until (k9 * 1 + 0) % 4 == 0
local CanvasDisplayGroup = k6:AddRightGroupbox("Canvas Display", "image")
if ((not CanvasDisplayGroup or not CanvasDisplayGroup or false) and (not CanvasDisplayGroup and 10 and 10) or (not CanvasDisplayGroup or not CanvasDisplayGroup) and false) and not ((not CanvasDisplayGroup or not CanvasDisplayGroup or false) and (not CanvasDisplayGroup and 10 and 10) or (not CanvasDisplayGroup or not CanvasDisplayGroup) and false) then
    CanvasDisplayGroup:AddToggle("AutoPlaceBest", { Text = "Auto Place Best Earning Picture on Canvas", Default = false })
    CanvasDisplayGroup:AddSlider("AutoPlaceInterval", { Min = 0.1, Suffix = "s", Text = "Check Interval", Max = 10, Default = 2, Rounding = 1 })
    CanvasDisplayGroup:AddButton({
        Text = "Place Best Now",
        Func = function()
            local mp, mq
            mq = kc()
            if not mq then
                pcall(function()
                    j4:Notify({ Title = "Canvas", Description = "No completed picture to place.", Time = 3 })
                end)
                return
            end
            local mr = kq()
            if not mr then
                pcall(function()
                    j4:Notify({ Title = "Canvas", Description = "No plot/canvas found. Go to your plot.", Time = 3 })
                end)
                return
            end
            mp = 0
            for i = 1, 16 do
                local my = i
                local ms = mr:FindFirstChild("Slot" .. my)
                local mt = ms and ms:GetAttribute("SelectedPicture") == nil
                if mt then
                    local ms_2 = pcall(function()
                        if jM then
                            jM:FireServer(my, mq)
                        end
                    end)
                    if ms_2 then
                        mp += 1
                    end
                    task.wait(0.1)
                end
            end
            pcall(function()
                j4:Notify({ Title = "Canvas", Description = "Placed " .. mq .. " on " .. mp .. " empty slots.", Time = 3 })
            end)
        end
    })
else
    CanvasDisplayGroup:AddToggle("AutoPlaceBest", { Text = "Auto Place Best Earning Picture on Canvas", Default = false })
    CanvasDisplayGroup:AddSlider("AutoPlaceInterval", { Text = "Check Interval", Default = 2, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
    CanvasDisplayGroup:AddButton({
        Text = "Place Best Now",
        Func = function()
            local mp, mq
            mq = kc()
            if not mq then
                pcall(function()
                    j4:Notify({ Title = "Canvas", Description = "No completed picture to place.", Time = 3 })
                end)
                return
            end
            local mr = kq()
            if not mr then
                pcall(function()
                    j4:Notify({ Title = "Canvas", Description = "No plot/canvas found. Go to your plot.", Time = 3 })
                end)
                return
            end
            mp = 0
            for i = 1, 16 do
                local my = i
                local ms = mr:FindFirstChild("Slot" .. my)
                local mt = ms and ms:GetAttribute("SelectedPicture") == nil
                if mt then
                    local ms_1 = pcall(function()
                        if jM then
                            jM:FireServer(my, mq)
                        end
                    end)
                    if ms_1 then
                        mp += 1
                    end
                    task.wait(0.1)
                end
            end
            pcall(function()
                j4:Notify({ Title = "Canvas", Description = "Placed " .. mq .. " on " .. mp .. " empty slots.", Time = 3 })
            end)
        end
    })
end
CurrentCamera, kG, kD, connection, connection2, kP, jS, jJ, ka, ks, kA, kh, j6, kz = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
kO = kU.Player:AddRightGroupbox("Movement", "footprints")
kO:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
kO:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
kO:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
kO:AddToggle("NoClip", { Text = "NoClip", Default = false })
kO:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
kK = kU.Player:AddLeftGroupbox("Fly", "feather")
kK:AddToggle("Fly", { Text = "Fly", Default = false })
kK:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
jS = fn420
jJ = fn473
kM.Stepped:Connect(onStepped)
kp.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
kM.RenderStepped:Connect(onRenderStepped)
kl.Fly:OnChanged(fn502)
kl.WalkSpeedEnabled:OnChanged(fn330)
ka = function(dJ)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not dJ)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not dJ
        end
    end)
    if not dJ then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(kg, "GameplayPaused", false)
        else
            kg.GameplayPaused = false
        end
    end)
end
kl.AntiGameplayPause:OnChanged(fn703)
task.spawn(antiGameplayPauseLoop)
local MenuGroup = kU.Settings:AddLeftGroupbox("Menu", "wrench")
kG = tick()
kD = tick()
pcall(function()
    for i, v in ipairs(getconnections(kg.Idled)) do
        local nd = v
        pcall(function()
            nd:Disable()
        end)
    end
end)
ks = fn55
connection = kp.InputBegan:Connect(onInputBegan)
connection2 = kp.InputChanged:Connect(onInputChanged)
if (MenuGroup and not ks and (not MenuGroup or MenuGroup) and (not ks or not MenuGroup or (not MenuGroup or not ks)) or (not ks and ks or MenuGroup and not MenuGroup) and (not MenuGroup or MenuGroup or (ks or ks))) and not (MenuGroup and not ks and (not MenuGroup or MenuGroup) and (not ks or not MenuGroup or (not MenuGroup or not ks)) or (not ks and ks or MenuGroup and not MenuGroup) and (not MenuGroup or MenuGroup or (ks or ks))) then
    Options:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    task.spawn(antiAfkLoop)
    Options:AddButton("Unload", onUnload)
    Options:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", Text = "Menu keybind", NoUI = true })
    kU.ToggleKeybind = MenuGroup.MenuKeybind
    kP:SetLibrary(kU)
    kL:SetLibrary(kU)
    kL:IgnoreThemeSettings()
    kL:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    kP:SetFolder("TempoHub")
    kL:SetFolder("TempoHub/AnimeGirlPaintByNumbers")
    j4 = kL:BuildConfigSection(SaveManager.Settings)
else
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    task.spawn(antiAfkLoop)
    MenuGroup:AddButton("Unload", onUnload)
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    j4.ToggleKeybind = Options.MenuKeybind
    kL:SetLibrary(j4)
    SaveManager:SetLibrary(j4)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    kL:SetFolder("TempoHub")
    SaveManager:SetFolder("TempoHub/AnimeGirlPaintByNumbers")
    kP = SaveManager:BuildConfigSection(kU.Settings)
end
kL:ApplyToTab(kU.Settings)
kL:SaveDefault("Evil Hello Kitty")
kL:LoadDefault()
kA = fn779
kh = fn698
j6 = fn221
kz = function(eM)
    local nY
    nY = nil
    local nZ = type(eM) ~= "table" or type(eM.idx) ~= "string" or type(eM.type) ~= "string" or SaveManager.Ignore[eM.idx]
    if nZ then
        return false
    end
    nY = kA(eM.type, eM.idx)
    if not nY then
        return false
    end
    local nZ_1 = pcall(function()
        if eM.type == "Input" then
            if type(eM.text) ~= "string" then
                return
            end
            nY:SetValue(eM.text)
        elseif eM.type == "ColorPicker" then
            nY:SetValueRGB(Color3.fromHex(eM.value), eM.transparency)
        elseif eM.type == "KeyPicker" then
            nY:SetValue({ eM.key, eM.mode, eM.modifiers })
            if eM.mode == "Toggle" and eM.toggled ~= nil then
                nY.Toggled = eM.toggled
                nY:Update()
            end
        else
            nY:SetValue(eM.value)
        end
    end)
    return nZ_1
end
kP:AddDivider()
kP:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
kP:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
kP:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
pcall(fn305)
kV(function()
    local oR, oS, oT
    if not kl.AutoPaint.Value then
        pcall(function()
            Label:SetText("Status: Idle")
        end)
        task.wait(0.5)
        return
    end
    local Value = Options.AutoPaintInterval.Value
    local oW = Options.AutoPaintBatch and Options.AutoPaintBatch.Value
    local o_ = if oW then 1 else 0
    local oY = 1968 * o_ + 169 * (1 - o_)
    local oZ = 3916 * o_ + 3504 * (1 - o_)
    if not ((oY * 1986 + oZ * 1558 + oY * oZ) % 16777213 == 939051) then
        oW = 15
    end
    oR = oW
    local oW_1 = kl.AutoPaintSmartCycle and kl.AutoPaintSmartCycle.Value
    local o5 = if oW_1 then 1 else 0
    local o3 = 3029 * o5 + 2649 * (1 - o5)
    local o4 = 2783 * o5 + 645 * (1 - o5)
    if not ((o3 * 2060 + o4 * 3531 + o3 * o4) % 16777213 == 7719007) then
        oW_1 = false
    end
    oT = oW_1
    if not kr() then
        task.wait(Value)
        return
    end
    oS = false
    pcall(function()
        local ol, om
        local ov_2
        local op = not jQ
        local op_2
        local oq = not jO or op
        local oq_1, oq_7
        if oq then
            Label:SetText("Status: Remotes missing")
            return
        end
        local op_1 = jN
        ol = nil
        if op_1 then
            op_1 = jN.GetLoadedPicture
        end
        if op_1 then
            op_2, oq_1 = pcall(function()
                return jN.GetLoadedPicture(kb)
            end)
            if op_2 then
                ol = oq_1
            else
                ol = kb:GetAttribute("LoadedPicture")
            end
        else
            ol = kb:GetAttribute("LoadedPicture")
        end
        if not ol then
            Label:SetText("Status: No picture loaded")
            return
        end
        local op_3 = jP[ol]
        if not op_3 then
            Label:SetText("Status: Picture data missing")
            return
        end
        local oq_2 = jN.IsPictureBusy and jN.IsPictureBusy(kb)
        if oq_2 then
            Label:SetText("Status: Picture busy")
            return
        end
        local oq_3 = kx()
        if not oq_3 then
            Label:SetText("Status: Go to your plot")
            return
        end
        om = 0
        local ot = {}
        for i, child in ipairs(oq_3:GetChildren()) do
            local oq_4 = child:IsA("BasePart") and child:GetAttribute("D") ~= true
            if oq_4 then
                local attr = child:GetAttribute("N")
                if attr then
                    local ov_1 = ot[attr] or {}
                    ot[attr] = ov_1
                    table.insert(ot[attr], child)
                    om += 1
                end
            end
        end
        if om == 0 then
            Label:SetText("Status: Picture complete")
            return
        end
        local oq_6 = jN
        local ou_2 = nil
        if oq_6 then
            oq_6 = jN.GetSelectedColor
        end
        if oq_6 then
            oq_7, ov_2 = pcall(function()
                return jN.GetSelectedColor(kb)
            end)
            if oq_7 then
                ou_2 = ov_2
            end
        end
        if not ou_2 then
            ou_2 = kb:GetAttribute("SelectedColorNumber")
        end
        local oo
        if oT then
            if ou_2 and ot[ou_2] and #ot[ou_2] > 0 then
                oo = ou_2
            else
                if op_3 and op_3.PartData and op_3.PartData.SortedNumbers then
                    for i, v in ipairs(op_3.PartData.SortedNumbers) do
                        if ot[v] and #ot[v] > 0 then
                            oo = v
                            break
                        end
                    end
                end
                if oo then
                    local op_5 = pcall(function()
                        jQ:FireServer(oo)
                    end)
                    if not op_5 then
                        pcall(function()
                            jQ:FireServer(tonumber(oo))
                        end)
                    end
                    task.wait(0.15)
                end
            end
        else
            if not ou_2 or not ot[ou_2] then
                Label:SetText("Status: Selected color has no cells")
                return
            end
            oo = ou_2
        end
        if not oo then
            Label:SetText("Status: No target color")
            return
        end
        local oq_10 = ot[oo] or {}
        if #oq_10 == 0 then
            Label:SetText("Status: Cycling colors")
            return
        end
        local oq_11 = math.min(#oq_10, oR)
        pcall(function()
            Label:SetText("Status: Painting " .. tostring(ol) .. " (" .. om .. " left)")
        end)
        for i = 1, oq_11 do
            if not jI() then
                break
            elseif not kl.AutoPaint.Value then
                break
            else
                local on = oq_10[i]
                local ot_1 = on and on:GetAttribute("D") ~= true
                if ot_1 then
                    local ot_2 = pcall(function()
                        jO:FireServer(on.Name)
                    end)
                    if not ot_2 then
                        pcall(function()
                            jQ:FireServer(oo)
                            task.wait(0.05)
                            jO:FireServer(on.Name)
                        end)
                    else
                        oS = true
                    end
                    if i < oq_11 then
                        task.wait(0.03)
                    end
                end
            end
        end
    end)
    kk()
    task.wait(Value)
end)
kV(function()
    if not kl.AutoPlaceBest.Value then
        task.wait(1)
        return
    end
    local Value = Options.AutoPlaceInterval.Value
    if not kr() then
        task.wait(Value)
        return
    end
    pcall(function()
        local o7
        local o9_1
        local o8_1
        o7, o9_1, o8_1 = kc()
        if not o7 then
            Label:SetText("Status: No completed picture to place")
            return
        end
        local o8_2 = kq()
        if not o8_2 then
            Label:SetText("Status: Canvas slots not found")
            return
        end
        local o9_2 = {}
        local pi = 1
        while pi <= 16 do
            local pk = pi
            local pa = o8_2:FindFirstChild("Slot" .. pk)
            if pa then
                if pa:GetAttribute("SelectedPicture") == nil then
                    table.insert(o9_2, pk)
                end
            else
                local pa_1 = o8_2:FindFirstChild(tostring(pk)) or o8_2:FindFirstChild("Canvas" .. pk)
                local pb = pa_1
                if pa_1 then
                    pa_1 = pb:GetAttribute("SelectedPicture") == nil
                end
                if pa_1 then
                    table.insert(o9_2, pk)
                end
            end
            pi += 1
        end
        if #o9_2 == 0 then
            Label:SetText("Status: Canvas filled with " .. tostring(o7))
            return
        end
        Label:SetText("Status: Placing " .. tostring(o7) .. " on " .. #o9_2 .. " slots")
        for i, v in ipairs(o9_2) do
            local pq = v
            if not jI() then
                break
            elseif not kl.AutoPlaceBest.Value then
                break
            else
                pcall(function()
                    if jM then
                        jM:FireServer(pq, o7)
                    end
                end)
                task.wait(0.15)
            end
        end
    end)
    kk()
    task.wait(Value)
end)
pcall(fn555)
j4:OnUnload(fn563)
end)(...)

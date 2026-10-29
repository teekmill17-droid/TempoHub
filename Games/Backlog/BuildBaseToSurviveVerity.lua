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
getgenv().TempoHoodSubtitle = "BUILD BASE TO SURVIVE VERITY"
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
local je
local Library
local jA
local jh
local StartWave
local ActiveNPCs
local j1
local RequestRebirth
local LocalPlayer
local ja
local ClaimWaveResult
local Workspace
local jY
local jj
local j0
local jm
local Toggles
local jL
local jp
local js
local jO
local jR
local jv
local BlockInventoryConfig
local SkipIntermission
local jf
local ji
local Options
local j_
local jo
local ju
local jQ
local function fn8()
    if jY() then
        return
    end
    local m4 = jh()
    if m4 == "Idle" then
        pcall(function()
            StartWave:InvokeServer()
        end)
    elseif m4 == "Preparing" then
        pcall(function()
            SkipIntermission:InvokeServer()
        end)
    end
end
local function fn38()
    local mV = jh()
    if mV ~= "Active" and mV ~= "Spawning" then
        return
    end
    local mV_1 = tonumber(LocalPlayer:GetAttribute("WaveNumber")) or 0
    if mV_1 < (Options.EndWaveAt and Options.EndWaveAt.Value or 1) then
        return
    end
    local Character = LocalPlayer.Character
    local mW_2 = Character and Character:FindFirstChildOfClass("Humanoid")
    local mV_5 = mW_2
    if mW_2 then
        mW_2 = mV_5.Health > 0
    end
    if mW_2 then
        mV_5.Health = 0
    end
end
local function fn47()
    pcall(function()
        RequestRebirth:InvokeServer()
    end)
end
local function autoShootLoop()
    while not Library.Unloaded do
        if Toggles.AutoShoot and Toggles.AutoShoot.Value then
            pcall(jO)
            task.wait(0.05)
        else
            task.wait(0.2)
        end
    end
end
local function fn120()
    local lI_1
    local Character = LocalPlayer.Character
    local lG = Character and Character:FindFirstChild("HumanoidRootPart")
    if not lG then
        return nil
    end
    local lH = Options.SilentAimRange and Options.SilentAimRange.Value or 200
    local lH_1
    lI_1, lH_1 = nil, lH
    for i, child in ActiveNPCs:GetChildren() do
        if child:GetAttribute("IsDead") ~= true then
            local Humanoid = child:FindFirstChildOfClass("Humanoid")
            local lJ = child:FindFirstChild("GunHitbox") or child:FindFirstChild("HumanoidRootPart")
            if Humanoid and lJ and Humanoid.Health > 0 then
                local Magnitude = (lJ.Position - lG.Position).Magnitude
                if Magnitude < lH_1 then
                    lI_1 = lJ
                    lH_1 = Magnitude
                end
            end
        end
    end
    return lI_1
end
local function fn126()
    local l__1
    local lZ_1
    local Character = LocalPlayer.Character
    local lX = Character and Character:FindFirstChild("HumanoidRootPart")
    if not lX then
        return nil
    end
    local lY = Options.SilentAimRange and Options.SilentAimRange.Value or 200
    local lY_1
    l__1, lZ_1, lY_1 = nil, nil, lY
    for i, child in ActiveNPCs:GetChildren() do
        if child:GetAttribute("IsDead") ~= true then
            local Humanoid = child:FindFirstChildOfClass("Humanoid")
            local l0 = child:FindFirstChild("GunHitbox") or child:FindFirstChild("HumanoidRootPart")
            local l1 = Humanoid
            if l1 then
                l1 = l0
            end
            if l1 then
                l1 = Humanoid.Health > 0
            end
            if l1 then
                local Magnitude = (l0.Position - lX.Position).Magnitude
                if Magnitude < lY_1 then
                    l__1 = Humanoid
                    lZ_1 = l0
                    lY_1 = Magnitude
                end
            end
        end
    end
    return l__1, lZ_1
end
local function fn153(bP)
    local lo = BlockInventoryConfig.Items[bP]
    if type(lo) ~= "table" then
        return nil
    end
    local lp = tonumber(lo.Price)
    if not lp or lp < 0 then
        return nil
    end
    local lt = if not BlockInventoryConfig.IsPurchasable(bP) then 1 else 0
    if lt == 1 then
        return nil
    end
    return lp
end
local function fn191(Q, R)
    return string.format('<font color="%s">%s</font>', R, Q)
end
local function fn259(cK, ...)
    if Toggles.SilentAim and Toggles.SilentAim.Value then
        local md_1 = j0()
        local CurrentCamera = Workspace.CurrentCamera
        if md_1 and CurrentCamera then
            local CFrame2 = CurrentCamera.CFrame
            local mg = CFrame.lookAt(CFrame2.Position, md_1.Position)
            CurrentCamera.CFrame = mg
            local md_2 = table.pack(j1(cK, mg))
            CurrentCamera.CFrame = CFrame2
            return table.unpack(md_2, 1, md_2.n)
        end
        return j1(cK, ...)
    end
    return j1(cK, ...)
end
local function fn278(T, U, V)
    return string.format("<b>%s</b> %s %s", T, j_("-", "#5a6070"), j_(U, V))
end
local function fn287()
    local Character = LocalPlayer.Character
    if not Character then
        return nil
    end
    local PlayerVals = LocalPlayer:FindFirstChild("PlayerVals")
    local mk = PlayerVals and PlayerVals:FindFirstChild("EquippedGun")
    local mj_1 = mk
    if mk then
        mk = tostring(mj_1.Value)
    end
    local mj_2 = mk
    if mj_2 and mj_2 ~= "" then
        local mk_2 = Character:FindFirstChild(mj_2)
        local ml_1 = mk_2 and mk_2:IsA("Tool")
        if ml_1 then
            return mk_2
        end
        local Backpack = LocalPlayer:FindFirstChild("Backpack")
        local ml_2 = Backpack and Backpack:FindFirstChild(mj_2)
        local mk_4 = ml_2 and ml_2:IsA("Tool")
        if mk_4 then
            ml_2.Parent = Character
            return ml_2
        end
        for i, child in Character:GetChildren() do
            local mi_1 = child:IsA("Tool") and child.Name ~= "PlaceTool" and child.Name ~= "RemoveTool"
            if mi_1 then
                return child
            end
        end
        return nil
    end
    for i, child in Character:GetChildren() do
        local mi_2 = child:IsA("Tool") and child.Name ~= "PlaceTool" and child.Name ~= "RemoveTool"
        if mi_2 then
            return child
        end
    end
    return nil
end
local function fn301(bG)
    local lb = Options[bG]
    local lc = lb and lb.Value
    local lb_1 = {}
    if type(lc) ~= "table" then
        return lb_1
    end
    for k, v in lc do
        if v then
            lb_1[k] = true
        end
    end
    return lb_1
end
local function fn302()
    jp(false)
    if ju then
        ju:Disconnect()
    end
    if jm then
        jm:Disconnect()
    end
    local o4 = jv()
    if o4 then
        o4.PlatformStand = false
        o4.WalkSpeed = 16
    end
end
local function fn328(ae)
    local DiscordGroup = ae:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = jj })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = jj })
end
local function fn337()
    local attr = LocalPlayer:GetAttribute("WaveState")
    local k6 = type(attr) == "string" and attr
    return k6 or "Idle"
end
local function fn412()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local k0 = leaderstats and leaderstats:FindFirstChild("Cash")
    local k__1 = k0
    if k0 then
        k0 = tonumber(k__1.Value)
    end
    return k0 or 0
end
local function fn564()
    local mU = if not jY() then 1 else 0
    if mU == 1 then
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        local mQ = PlayerGui and PlayerGui:FindFirstChild("WaveResult")
        local mP_1 = mQ
        if mQ then
            mQ = mP_1:FindFirstChild("Frame")
        end
        local mP_2 = mQ
        if mQ then
            mQ = mP_2:FindFirstChild("WaveResult")
        end
        local mP_3 = mQ
        if mQ then
            mQ = mP_3.Visible
        end
        if not mQ then
            return
        end
    end
    pcall(function()
        ClaimWaveResult:InvokeServer("cashclaim")
    end)
end
local function fn577()
    jA(ji, "Copied Discord invite to clipboard")
end
local function autoEndWaveLoop()
    while not Library.Unloaded do
        if Toggles.AutoEndWave and Toggles.AutoEndWave.Value then
            pcall(jL)
        end
        if Toggles.AutoClaim and Toggles.AutoClaim.Value then
            pcall(jQ)
        end
        if Toggles.AutoStartWave and Toggles.AutoStartWave.Value then
            pcall(jR)
        end
        if Toggles.AutoRebirth and Toggles.AutoRebirth.Value then
            pcall(je)
        end
        if Toggles.AutoBuyBlocks and Toggles.AutoBuyBlocks.Value then
            pcall(jo, jf, "BlockList")
        end
        if Toggles.AutoBuyTrap and Toggles.AutoBuyTrap.Value then
            pcall(jo, ja, "TrapList")
        end
        if Toggles.AutoBuyGuns and Toggles.AutoBuyGuns.Value then
            pcall(js)
        end
        task.wait(0.35)
    end
end
local function fn760(J, K)
    if setclipboard then
        setclipboard(J)
    elseif toclipboard then
        toclipboard(J)
    end
    Library:Notify(K)
end
local function fn769()
    local PlayerVals = LocalPlayer:FindFirstChild("PlayerVals")
    local k9 = PlayerVals and PlayerVals:FindFirstChild("WaveResultReady")
    local k8_1 = k9
    if k9 then
        k9 = k8_1.Value == true
    end
    return k9
end
ja = nil
je = nil
jf = nil
jh = nil
ji = nil
jj = nil
ActiveNPCs = nil
jm = nil
jo = nil
jp = nil
js = nil
LocalPlayer = nil
ju = nil
jv = nil
Workspace = nil
BlockInventoryConfig = nil
jA = nil
Options = nil
Toggles = nil
RequestRebirth = nil
jL = nil
jO = nil
jQ = nil
jR = nil
ClaimWaveResult = nil
SkipIntermission = nil
Library = nil
local jb, jc, jd, jg, jl, jn, Shoot, jr, jx, CoreGui, PurchaseGunCrates, jC, GuiService, BuyBlockInventory, jG, HttpService, jK, VirtualUser, jN, SaveManager, UserInputService, RunService, jX
jY = nil
StartWave = nil
j_ = nil
j0 = nil
j1 = nil
RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, LocalPlayer, jn, ji, jc, StartWave, SkipIntermission, ClaimWaveResult, RequestRebirth, BuyBlockInventory, PurchaseGunCrates, BlockInventoryConfig, Shoot, ActiveNPCs, jf, ja, Library, SaveManager, Toggles, Options, jr, jl, jg, jb, jX, jA, jj, j_, jK = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
jn = "Build Base to Survive VERITY"
ji = "https://discord.gg/K7Qxnxkk46"
jc = "https://discord.gg/K7Qxnxkk46"
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
StartWave = Remotes:WaitForChild("StartWave")
SkipIntermission = Remotes:WaitForChild("SkipIntermission")
ClaimWaveResult = Remotes:WaitForChild("ClaimWaveResult")
RequestRebirth = Remotes:WaitForChild("RequestRebirth")
BuyBlockInventory = Remotes:WaitForChild("BuyBlockInventory")
PurchaseGunCrates = Remotes:WaitForChild("PurchaseGunCrates")
BlockInventoryConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BlockInventoryConfig"))
local j9 = require(ReplicatedStorage:WaitForChild("Blaster"):WaitForChild("Scripts"):WaitForChild("BlasterController"))
Shoot = ReplicatedStorage:WaitForChild("Blaster"):WaitForChild("Remotes"):WaitForChild("Shoot")
ActiveNPCs = Workspace:WaitForChild("ActiveNPCs")
jf = {
    "Plastic",
    "Dirt Block",
    "Sand",
    "Hay",
    "Grass Dirt",
    "Glass",
    "Pink Wool",
    "Tree Leaves",
    "Spruce Leaves",
    "Blossom Leaves",
    "Palm Leaves",
    "Wood",
    "Wood Plank",
    "Jungle Plank",
    "Spruce Plank",
    "Barrel",
    "Brick",
    "Cobblestone",
    "Sand Stone",
    "Stone Brick",
    "Glow Stone",
    "Quartz",
    "Magma",
    "Iron Block",
    "Gold Block",
    "Ruby",
    "Emerald Block",
    "Diamond Block",
    "Obsidian",
    "Crying Obsidian",
    "Ancient Debris",
    "Netherite Block"
}
ja = {
    "Bear Trap",
    "Spike Trap",
    "Landmine",
    "Subspace Tripmine",
    "Turret",
    "Minigun Turret",
    "Cannon",
    "Sniper Turret"
}
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
jA = fn760
jj = fn577
j_ = fn191
jK = fn278
jr = "#7fd47f"
jl = "#6ec1ff"
jg = "#e8a34d"
jb = "#8b93a3"
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = ji, Copyable = true }, "|", jn },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
jX = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "swords"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in jX do
    fn328(v)
end
j1, jG, jh, jY, jx, jN, jo, j0, jC = nil, nil, nil, nil, nil, nil, nil, nil, nil
local j3 = 13
repeat
    local j4_1 = (j3 * 3 + 0) % 4 + 1
    if j4_1 <= 2 then
        if j4_1 <= 1 then
            local pz = bit32.rrotate(bit32.bxor(bit32.lrotate(j3, 3), string.byte(tostring(jG))), 28)
            if bit32.bxor(bit32.lrotate(bit32.bxor(pz, 1976699710), 2), 3611831545) ~= bit32.lrotate(pz, 2) then
                jh = fn153
            else
                jN = fn153
            end
            j3 = (j3 + 19) % 32
        else
            local pD = bit32.rrotate(bit32.bxor(bit32.lrotate(j3, 5), string.byte(tostring(jG))), 4)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(pD, 2218704327), 4129170994), (bit32.bxor(bit32.band(pD, 2076262968), 1601279136))), 4129170994), 1601279136) == pD then
                jo = function(bV, bW)
                    local lu = jx(bW)
                    local lv = jG()
                    for k, v in bV do
                        local lE = v
                        if lu[lE] then
                            local lw = jN(lE)
                            if lw and lv >= lw then
                                local lw_2 = pcall(function()
                                    BuyBlockInventory:InvokeServer(lE)
                                end)
                                if lw_2 then
                                    return
                                end
                            end
                        end
                    end
                end
                j0 = fn120
            else
                j0 = function(bV, bW)
                    local lu = jx(bW)
                    local lv = jG()
                    for k, v in bV do
                        local lE = v
                        if lu[lE] then
                            local lw = jN(lE)
                            if lw and lv >= lw then
                                local lw_1 = pcall(function()
                                    BuyBlockInventory:InvokeServer(lE)
                                end)
                                if lw_1 then
                                    return
                                end
                            end
                        end
                    end
                end
                jo = fn120
            end
            j3 = (j3 + 19) % 32
        end
    elseif j4_1 <= 3 then
        local qb = bit32.rrotate(bit32.bxor(bit32.lrotate(j3, 31), string.byte(tostring(jx))), 28)
        if bit32.bxor(bit32.lrotate(bit32.bxor(qb, 30734430), 0), 30734430) ~= bit32.lrotate(qb, 0) then
            j1 = fn126
            j9 = jC.shoot
        else
            jC = fn126
            j1 = j9.shoot
        end
        j3 = (j3 + 3) % 32
    else
        local j4_2 = { "yvsoatkehx", "sesekz", "xqdfliheb", "niff", "zblsri", "eru", "sfcj", "abuixvoxbi", "domay" }
        local pi = j3
        local j5_1 = j4_2[pi % 9 + 1]
        if j5_1:len() <= j5_1:reverse():rep(pi % 3 + 2):len() then
            local function j2_1()
                local kP
                kP = nil
                local Label, kH, kI, kJ, kK, kL, kM, kN, kO, kQ
                local kX_2
                local kW_2
                local kV_2
                local kU_2
                kP = "Unknown"
                pcall(function()
                    local ks_2
                    local kr_3
                    if identifyexecutor then
                        ks_2, kr_3 = identifyexecutor()
                        local kt = ks_2 ~= ""
                        local kv = type(ks_2) == "string" and kt
                        if kv then
                            local kt_2 = type(kr_3) == "string" and kr_3 ~= "" and ks_2 .. " " .. kr_3
                            kP = kt_2 or ks_2
                        end
                    end
                end)
                local AccountGroup = jX.Info:AddLeftGroupbox("Account", "circle-user")
                local kR_13
                AccountGroup:AddLabel(jK("User", LocalPlayer.Name, jr), true)
                AccountGroup:AddLabel(jK("Status", "Keyless", jr), true)
                AccountGroup:AddLabel(jK("Executor", kP, jr), true)
                local GameInfoGroup = jX.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                GameInfoGroup:AddLabel(j_(jn .. " [" .. tostring(game.PlaceId) .. "]", jl), true)
                GameInfoGroup:AddLabel(jK("Place ID", tostring(game.PlaceId), jl), true)
                Label = GameInfoGroup:AddLabel(jK("Session time", "0s", jg), true)
                kN = tostring(game.JobId)
                local kS = #kN > 18 and string.sub(kN, 1, 18) .. "..."
                local kS_4
                local kT = kS or kN
                local kT_2
                GameInfoGroup:AddLabel(jK("Server", kT, jb), true)
                GameInfoGroup:AddButton({
                    Text = "Copy join script (Job ID)",
                    Func = function()
                        local kA = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, kN)
                        if setclipboard then
                            setclipboard(kA)
                        elseif toclipboard then
                            toclipboard(kA)
                        end
                        Library:Notify("Copied join script to clipboard")
                    end
                })
                kJ = os.clock()
                task.spawn(function()
                    local kD_2
                    while true do
                        task.wait(1)
                        if Library.Unloaded then
                            break
                        end
                        local kC = math.floor(os.clock() - kJ)
                        if kC < 60 then
                            kD_2 = kC .. "s"
                        elseif kC < 3600 then
                            kD_2 = string.format("%dm %ds", math.floor((kC) / (60)), kC % 60)
                        else
                            kD_2 = string.format("%dh %dm", math.floor((kC) / (3600)), math.floor((kC % 3600) / (60)))
                        end
                        Label:SetText(jK("Session time", kD_2, jg))
                    end
                end)
                local ScriptsGroup = jX.Info:AddRightGroupbox("Scripts", "package")
                ScriptsGroup:AddLabel(j_("Included in this hub", jb), true)
                ScriptsGroup:AddLabel(j_(jn, jl), true)
                local FeaturesGroup = jX.Info:AddRightGroupbox("Features", "list")
                FeaturesGroup:AddLabel(j_("Wave Automation", jl), true)
                FeaturesGroup:AddLabel(j_("Shop Automation", jg), true)
                FeaturesGroup:AddLabel(j_("Combat Utilities", jb), true)
                local SocialsGroup = jX.Info:AddRightGroupbox("Socials", "link")
                SocialsGroup:AddButton({ Text = "Discord", Func = jj })
                SocialsGroup:AddButton({
                    Text = "Rscripts",
                    Func = function()
                        if setclipboard then
                            setclipboard(jc)
                        elseif toclipboard then
                            toclipboard(jc)
                        end
                        Library:Notify("Copied Rscripts profile to clipboard")
                    end
                })
                local TempoHubGroup = jX.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
                TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
                TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
                TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
                TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = jj })
                kK = ""
                kH = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
                kM = ""
                kO = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
                kL = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                kQ = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
                kI = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                kR_13, kS_4, kT_2, kU_2, kV_2, kW_2, kX_2 = "#345d9d", "#f7931a", "#627eea", "#26a17b", "#14f195", "#0070ba", "#008cff"
                local DonationsGroup = jX.Info:AddRightGroupbox("Donations", "heart")
                DonationsGroup:AddLabel(j_("All donations are optional but appreciated.", jg), true)
                DonationsGroup:AddLabel(j_("If you donate you get a special role, just PING after you donate.", jr), true)
                DonationsGroup:AddDivider()
                DonationsGroup:AddLabel(j_("LTC / Litecoin", kR_13), true)
                DonationsGroup:AddButton({
                    Text = "Copy Litecoin Address",
                    Func = function()
                        jA(kH, "Copied Litecoin address")
                    end
                })
                DonationsGroup:AddLabel(j_("BTC / Bitcoin", kS_4), true)
                DonationsGroup:AddButton({
                    Text = "Copy Bitcoin Address",
                    Func = function()
                        jA(kO, "Copied Bitcoin address")
                    end
                })
                DonationsGroup:AddLabel(j_("ETH / Ethereum", kT_2), true)
                DonationsGroup:AddButton({
                    Text = "Copy Ethereum Address",
                    Func = function()
                        jA(kL, "Copied Ethereum address")
                    end
                })
                DonationsGroup:AddLabel(j_("USDT", kU_2), true)
                DonationsGroup:AddButton({
                    Text = "Copy USDT Address",
                    Func = function()
                        jA(kI, "Copied USDT address")
                    end
                })
                DonationsGroup:AddLabel(j_("Solana", kV_2), true)
                DonationsGroup:AddButton({
                    Text = "Copy Solana Address",
                    Func = function()
                        jA(kQ, "Copied Solana address")
                    end
                })
                DonationsGroup:AddLabel(j_("PayPal", kW_2), true)
                DonationsGroup:AddButton({
                    Text = "Copy PayPal Link",
                    Func = function()
                        jA(kM, "Copied PayPal link")
                    end
                })
                DonationsGroup:AddLabel(j_("Venmo", kX_2), true)
                DonationsGroup:AddButton({
                    Text = "Copy Venmo Link",
                    Func = function()
                        jA(kK, "Copied Venmo link")
                    end
                })
                DonationsGroup:AddDivider()
                DonationsGroup:AddLabel(j_("Don't have any of the listed currencies but still wanna donate?", jb), true)
                DonationsGroup:AddLabel(j_("DM me and we'll work something out.", jl), true)
                local FaqGroup = jX.Info:AddRightGroupbox("FAQ", "circle-help")
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
            j2_1()
            jG = fn412
            jh = fn337
            jY = fn769
            jx = fn301
        else
            jG = function()
                local kP
                kP = nil
                local Label, kH, kI, kJ, kK, kL, kM, kN, kO, kQ
                local kX_1
                local kW_1
                local kV_1
                local kU_1
                kP = "Unknown"
                pcall(function()
                    local ks_1
                    local kr_1
                    if identifyexecutor then
                        ks_1, kr_1 = identifyexecutor()
                        local kt = ks_1 ~= ""
                        local kv = type(ks_1) == "string" and kt
                        if kv then
                            local kt_1 = type(kr_1) == "string" and kr_1 ~= "" and ks_1 .. " " .. kr_1
                            kP = kt_1 or ks_1
                        end
                    end
                end)
                local AccountGroup = jX.Info:AddLeftGroupbox("Account", "circle-user")
                local kR_6
                AccountGroup:AddLabel(jK("User", LocalPlayer.Name, jr), true)
                AccountGroup:AddLabel(jK("Status", "Keyless", jr), true)
                AccountGroup:AddLabel(jK("Executor", kP, jr), true)
                local GameInfoGroup = jX.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                GameInfoGroup:AddLabel(j_(jn .. " [" .. tostring(game.PlaceId) .. "]", jl), true)
                GameInfoGroup:AddLabel(jK("Place ID", tostring(game.PlaceId), jl), true)
                Label = GameInfoGroup:AddLabel(jK("Session time", "0s", jg), true)
                kN = tostring(game.JobId)
                local kS = #kN > 18 and string.sub(kN, 1, 18) .. "..."
                local kS_2
                local kT = kS or kN
                local kT_1
                GameInfoGroup:AddLabel(jK("Server", kT, jb), true)
                GameInfoGroup:AddButton({
                    Text = "Copy join script (Job ID)",
                    Func = function()
                        local kA = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, kN)
                        if setclipboard then
                            setclipboard(kA)
                        elseif toclipboard then
                            toclipboard(kA)
                        end
                        Library:Notify("Copied join script to clipboard")
                    end
                })
                kJ = os.clock()
                task.spawn(function()
                    local kD_1
                    while true do
                        task.wait(1)
                        if Library.Unloaded then
                            break
                        end
                        local kC = math.floor(os.clock() - kJ)
                        if kC < 60 then
                            kD_1 = kC .. "s"
                        elseif kC < 3600 then
                            kD_1 = string.format("%dm %ds", math.floor((kC) / (60)), kC % 60)
                        else
                            kD_1 = string.format("%dh %dm", math.floor((kC) / (3600)), math.floor((kC % 3600) / (60)))
                        end
                        Label:SetText(jK("Session time", kD_1, jg))
                    end
                end)
                local ScriptsGroup = jX.Info:AddRightGroupbox("Scripts", "package")
                ScriptsGroup:AddLabel(j_("Included in this hub", jb), true)
                ScriptsGroup:AddLabel(j_(jn, jl), true)
                local FeaturesGroup = jX.Info:AddRightGroupbox("Features", "list")
                FeaturesGroup:AddLabel(j_("Wave Automation", jl), true)
                FeaturesGroup:AddLabel(j_("Shop Automation", jg), true)
                FeaturesGroup:AddLabel(j_("Combat Utilities", jb), true)
                local SocialsGroup = jX.Info:AddRightGroupbox("Socials", "link")
                SocialsGroup:AddButton({ Text = "Discord", Func = jj })
                SocialsGroup:AddButton({
                    Text = "Rscripts",
                    Func = function()
                        if setclipboard then
                            setclipboard(jc)
                        elseif toclipboard then
                            toclipboard(jc)
                        end
                        Library:Notify("Copied Rscripts profile to clipboard")
                    end
                })
                local TempoHubGroup = jX.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
                TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
                TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
                TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
                TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = jj })
                kK = ""
                kH = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
                kM = ""
                kO = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
                kL = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                kQ = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
                kI = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                kR_6, kS_2, kT_1, kU_1, kV_1, kW_1, kX_1 = "#345d9d", "#f7931a", "#627eea", "#26a17b", "#14f195", "#0070ba", "#008cff"
                local DonationsGroup = jX.Info:AddRightGroupbox("Donations", "heart")
                DonationsGroup:AddLabel(j_("All donations are optional but appreciated.", jg), true)
                DonationsGroup:AddLabel(j_("If you donate you get a special role, just PING after you donate.", jr), true)
                DonationsGroup:AddDivider()
                DonationsGroup:AddLabel(j_("LTC / Litecoin", kR_6), true)
                DonationsGroup:AddButton({
                    Text = "Copy Litecoin Address",
                    Func = function()
                        jA(kH, "Copied Litecoin address")
                    end
                })
                DonationsGroup:AddLabel(j_("BTC / Bitcoin", kS_2), true)
                DonationsGroup:AddButton({
                    Text = "Copy Bitcoin Address",
                    Func = function()
                        jA(kO, "Copied Bitcoin address")
                    end
                })
                DonationsGroup:AddLabel(j_("ETH / Ethereum", kT_1), true)
                DonationsGroup:AddButton({
                    Text = "Copy Ethereum Address",
                    Func = function()
                        jA(kL, "Copied Ethereum address")
                    end
                })
                DonationsGroup:AddLabel(j_("USDT", kU_1), true)
                DonationsGroup:AddButton({
                    Text = "Copy USDT Address",
                    Func = function()
                        jA(kI, "Copied USDT address")
                    end
                })
                DonationsGroup:AddLabel(j_("Solana", kV_1), true)
                DonationsGroup:AddButton({
                    Text = "Copy Solana Address",
                    Func = function()
                        jA(kQ, "Copied Solana address")
                    end
                })
                DonationsGroup:AddLabel(j_("PayPal", kW_1), true)
                DonationsGroup:AddButton({
                    Text = "Copy PayPal Link",
                    Func = function()
                        jA(kM, "Copied PayPal link")
                    end
                })
                DonationsGroup:AddLabel(j_("Venmo", kX_1), true)
                DonationsGroup:AddButton({
                    Text = "Copy Venmo Link",
                    Func = function()
                        jA(kK, "Copied Venmo link")
                    end
                })
                DonationsGroup:AddDivider()
                DonationsGroup:AddLabel(j_("Don't have any of the listed currencies but still wanna donate?", jb), true)
                DonationsGroup:AddLabel(j_("DM me and we'll work something out.", jl), true)
                local FaqGroup = jX.Info:AddRightGroupbox("FAQ", "circle-help")
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
            jG()
            jx = fn337
            jh = fn769
            jY = fn301
        end
        j3 = (j3 + 27) % 32
    end
until (j3 * 9 + 24) % 32 == 17
if type(hookfunction) == "function" then
    local j2_2 = 4
    repeat
        local j3_1 = (vector.create((j2_2 * 5 + 5) % 11 + 1, (j2_2 * 10 + 8) % 13 + 1, (j2_2 * 9 + 7) % 17 + 1))
        local j4_3 = (vector.create((j2_2 * 5 + 4) % 11 + 1, (j2_2 * 8 + 2) % 13 + 1, (j2_2 * 8 + 15) % 17 + 1))
        local j5_2 = (vector.create((j2_2 * 5 + 7) % 11 + 1, (j2_2 * 3 + 2) % 13 + 1, (j2_2 * 10 + 11) % 17 + 1))
        if vector.dot(vector.cross(j3_1, j4_3), j5_2) == vector.dot(vector.cross(j4_3, j5_2), j3_1) + 5 then
            j9 = hookfunction(j1.shoot, newcclosure(fn259))
        else
            j1 = hookfunction(j9.shoot, newcclosure(fn259))
        end
        j2_2 = (j2_2 + 2) % 8
    until (j2_2 * 1 + 3) % 8 == 1
end
jv, jp, ju, jm, jd, jO, js, jQ, jL, jR, je = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
jd = fn287
jO = function()
    local mz, mA, mB
    local Character = LocalPlayer.Character
    local mD = Character and Character:FindFirstChild("HumanoidRootPart")
    local mD_1
    mA = jd()
    mB, mD_1 = jC()
    if not mD or not mA or not mB or not mD_1 then
        return
    end
    mz = CFrame.lookAt(mD.Position + Vector3.new(0, 1.5, 0), mD_1.Position)
    pcall(function()
        Shoot:FireServer(Workspace:GetServerTimeNow(), mA, mz, { ["1"] = mB })
    end)
end
js = function()
    local mI
    mI = Options.GunCrate and Options.GunCrate.Value or "Normal"
    local mJ_1 = mI == ""
    local mK_1 = type(mI) ~= "string" or mJ_1
    if mK_1 then
        mI = "Normal"
    end
    pcall(function()
        PurchaseGunCrates:InvokeServer(mI, 1)
    end)
end
jQ = fn564
jL = fn38
jR = fn8
je = fn47
local WaveGroup = jX.Main:AddLeftGroupbox("Wave", "swords")
WaveGroup:AddToggle("AutoStartWave", { Text = "Auto Start Wave", Default = false })
WaveGroup:AddToggle("AutoEndWave", { Text = "Auto End Wave", Default = false })
WaveGroup:AddSlider("EndWaveAt", { Text = "End At Wave", Default = 1, Min = 1, Max = 100, Rounding = 0 })
WaveGroup:AddToggle("AutoClaim", { Text = "Auto Claim", Default = false })
WaveGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
local ShopGroup = jX.Main:AddRightGroupbox("Shop", "shopping-cart")
ShopGroup:AddToggle("AutoBuyBlocks", { Text = "Auto Buy Blocks", Default = false })
ShopGroup:AddDropdown("BlockList", { Text = "Blocks", Values = jf, Multi = true, Default = {} })
ShopGroup:AddToggle("AutoBuyTrap", { Text = "Auto Buy Trap", Default = false })
ShopGroup:AddDropdown("TrapList", { Text = "Traps", Values = ja, Multi = true, Default = {} })
ShopGroup:AddToggle("AutoBuyGuns", { Text = "Auto Buy Guns", Default = false })
ShopGroup:AddDropdown("GunCrate", { Text = "Gun Crate", Values = { "Normal", "Diamond" }, Default = "Normal" })
local CombatGroup = jX.Main:AddLeftGroupbox("Combat", "crosshair")
CombatGroup:AddToggle("SilentAim", { Text = "Silent Aim", Default = false })
CombatGroup:AddToggle("AutoShoot", { Text = "Auto Shoot", Default = false })
CombatGroup:AddSlider("SilentAimRange", { Text = "Silent Aim Range", Default = 200, Min = 50, Max = 500, Rounding = 0 })
task.spawn(autoEndWaveLoop)
task.spawn(autoShootLoop)
local function kd()
    local MovementGroup = jX.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    local FlyGroup = jX.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local function ev()
        local Character = LocalPlayer.Character
        local nb = Character and Character:FindFirstChildOfClass("Humanoid")
        return nb
    end
    local function eA()
        local Character = LocalPlayer.Character
        local ne = Character and Character:FindFirstChild("HumanoidRootPart")
        return ne
    end
    local function eE(eF)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not eF)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not eF
            end
        end)
        if not eF then
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
    RunService.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = LocalPlayer.Character
            if Character then
                for i, descendant in Character:GetDescendants() do
                    local nn_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if nn_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    UserInputService.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local nv_1 = ev()
            if nv_1 then
                nv_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    local CurrentCamera = Workspace.CurrentCamera
    RunService.RenderStepped:Connect(function(e9)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local nA_1 = ev()
            if nA_1 then
                nA_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local nA_3 = eA()
            local nB = ev()
            if nA_3 and nB then
                nB.PlatformStand = true
                local nB_1 = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    nB_1 += CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    nB_1 -= CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    nB_1 -= CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    nB_1 += CurrentCamera.CFrame.RightVector
                end
                local nG = if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
                if nG == 1 then
                    nB_1 += Vector3.new(0, 1, 0)
                end
                local nJ = if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then 1 else 0
                if nJ == 1 then
                    nB_1 -= Vector3.new(0, 1, 0)
                end
                nA_3.AssemblyLinearVelocity = Vector3.zero
                if nB_1.Magnitude > 0 then
                    nA_3.CFrame = nA_3.CFrame + nB_1.Unit * Options.FlySpeed.Value * e9
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local nK = ev()
            if nK then
                nK.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local nM = ev()
            if nM then
                nM.WalkSpeed = 16
            end
        end
    end)
    Toggles.AntiGameplayPause:OnChanged(function()
        eE(Toggles.AntiGameplayPause.Value)
    end)
    eE(true)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                eE(true)
            end
        end
    end)
    return ev, eE
end
jv, jp = kd()
local function j5_3(fC)
    local fD
    fD = tick()
    local fE = tick()
    pcall(function()
        for k, v in getconnections(LocalPlayer.Idled) do
            local nV = v
            pcall(function()
                nV:Disable()
            end)
        end
    end)
    local function fK()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then
            return
        end
        VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
        task.wait(0.1)
        VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
        fE = tick()
    end
    local connection2 = UserInputService.InputBegan:Connect(function()
        fD = tick()
    end)
    local connection = UserInputService.InputChanged:Connect(function(fU)
        local UserInputType = fU.UserInputType
        if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
            fD = tick()
        end
    end)
    fC:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            if Toggles.AntiAfk.Value then
                local n3 = tick() - fD
                local n4 = tick() - fE
                if n3 >= 300 and n4 >= 60 then
                    pcall(fK)
                else
                    if n3 < 300 and n4 >= 300 then
                        pcall(fK)
                    end
                end
            end
        end
    end)
    return connection2, connection
end
local MenuGroup = jX.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
ju, jm = j5_3(MenuGroup)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(jX.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/BuildBaseToSurviveVERITY")
local j4_4 = SaveManager:BuildConfigSection(jX.Settings)
SaveManager:LoadAutoloadConfig()
local function j3_2(ge)
    local function gf(gg, gh)
        local n8_1 = (gg == "Toggle" and Toggles or Options)[gh]
        local n7_2 = type(n8_1) == "table" and n8_1.Type == gg
        return n7_2 and n8_1 or nil
    end
    local function gp(gq, gr)
        local Type = gr.Type
        if Type == "Toggle" then
            return { idx = gq, type = "Toggle", value = gr.Value == true }
        elseif Type == "Slider" then
            return { idx = gq, type = "Slider", value = tostring(gr.Value) }
        elseif Type == "Dropdown" then
            return { idx = gq, type = "Dropdown", multi = gr.Multi == true, value = gr.Value }
        elseif Type == "Input" then
            local oc = gr.Value or ""
            return { idx = gq, type = "Input", text = tostring(oc) }
        elseif Type == "ColorPicker" then
            return { idx = gq, type = "ColorPicker", value = gr.Value:ToHex(), transparency = gr.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = gq,
                type = "KeyPicker",
                mode = gr.Mode,
                key = gr.Value,
                modifiers = gr.Modifiers,
                toggled = gr.Toggled
            }
        else
            return nil
        end
    end
    local function gt()
        local om = {}
        for k, v in { Toggles, Options } do
            for k, v in v do
                local on = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if on then
                    local on_1 = gp(k, v)
                    if on_1 then
                        om[#om + 1] = on_1
                    end
                end
            end
        end
        table.sort(om, function(gD, gE)
            if gD.type ~= gE.type then
                return gD.type < gE.type
            end
            return gD.idx < gE.idx
        end)
        return { objects = om }
    end
    local function gF(gG)
        local oI
        oI = nil
        local oJ = type(gG) ~= "table" or type(gG.idx) ~= "string" or type(gG.type) ~= "string" or SaveManager.Ignore[gG.idx]
        if oJ then
            return false
        end
        oI = gf(gG.type, gG.idx)
        if not oI then
            return false
        end
        local oJ_1 = pcall(function()
            if gG.type == "Input" then
                if type(gG.text) ~= "string" then
                    return
                end
                oI:SetValue(gG.text)
            elseif gG.type == "ColorPicker" then
                oI:SetValueRGB(Color3.fromHex(gG.value), gG.transparency)
            elseif gG.type == "KeyPicker" then
                oI:SetValue({ gG.key, gG.mode, gG.modifiers })
                if gG.mode == "Toggle" and gG.toggled ~= nil then
                    oI.Toggled = gG.toggled
                    oI:Update()
                end
            else
                oI:SetValue(gG.value)
            end
        end)
        return oJ_1
    end
    ge:AddDivider()
    ge:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    ge:AddButton("Export Config to Clipboard", function()
        local oP_1
        local oO_1
        oO_1, oP_1 = pcall(HttpService.JSONEncode, HttpService, gt())
        if not oO_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local oO_2 = setclipboard or toclipboard
        local oO_3 = type(oO_2) ~= "function" or not pcall(oO_2, oP_1)
        if oO_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    ge:AddButton("Import Config from Clipboard Text", function()
        local oU_1
        local oS = Options.SaveManager_ImportSource.Value or ""
        local oS_1
        local oT = tostring(oS):match("^%s*(.-)%s*$")
        if oT == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        oS_1, oU_1 = pcall(HttpService.JSONDecode, HttpService, oT)
        local oT_1 = not oS_1 or type(oU_1) ~= "table"
        local oY = if oT_1 then 1 else 0
        local oW = 214 * oY + 2282 * (1 - oY)
        local oX = 4024 * oY + 4037 * (1 - oY)
        if not ((oW * 2583 + oX * 1741 + oW * oX) % 16777213 == 8419682) then
            oT_1 = type(oU_1.objects) ~= "table"
        end
        if oT_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local oS_2 = 0
        for k, v in oU_1.objects do
            if gF(v) then
                oS_2 += 1
            end
        end
        if oS_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local oU_2 = oS_2 == 1 and ""
        local oY_1 = if oU_2 then 1 else 0
        local oW_1 = 2057 * oY_1 + 2303 * (1 - oY_1)
        local oX_1 = 2450 * oY_1 + 974 * (1 - oY_1)
        if not ((oW_1 * 3803 + oX_1 * 2874 + oW_1 * oX_1) % 16777213 == 3126508) then
            oU_2 = "s"
        end
        Library:Notify(("Imported %d setting%s"):format(oS_2, oU_2), 6)
    end)
end
j3_2(j4_4)
Library:OnUnload(fn302)
end)(...)

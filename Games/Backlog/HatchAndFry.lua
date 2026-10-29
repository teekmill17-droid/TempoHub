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
getgenv().TempoHoodSubtitle = "HATCH AND FRY!"
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
local En_1, En_5, En_6, En_7, En_8
local tw
local tC
local Eggs
local sI
local sp
local tO
local sO
local Library
local sv
local tc
local tB
local s_
local tH
local sH
local so
local s5
local tN
local sN
local tu
local tA
local sA
local sZ
local tn
local sn
local s4
local FarmPosition
local st
local Options
local sS
local tz
local sz
local tg
local sY
local tF
local sF
local tm
local sm
local s3
local Upgrade
local Workspace
local tR
local sR
local Configuration
local tf
local sE
local sl
local s2
local tr
local sr
local s8
local tQ
local sx
local Toggles
local sW
local tD
local sk
local CollectCash
local tq
local DataAggregation
local s7
local function fn20(fI)
    local yC, yD, CFrame, yG, yI, yJ, yL, yM, yN, yO, yQ, yR, yS, yT
    local yK = 8
    while true do
        local yK_1 = 10976 - yK
        do
            if yK_1 < 10966 then
                if yK_1 < 10964 then
                    if yK_1 < 10963 then
                        if yK_1 < 10962 then
                            if yK_1 < 9860 then
                                break
                            elseif yK_1 < 10763 then
                                break
                            elseif yK_1 < 10961 then
                                break
                            elseif yK_1 == 10961 then
                                yS += yR
                                yK = 11
                            else
                                yK = 10963
                                continue
                            end
                        else
                            return yG
                        end
                    else
                        yN += yM
                        yK = 10
                    end
                elseif yK_1 < 10965 then
                    if yK_1 == 10964 then
                        local yE_1 = CFrame:PointToWorldSpace(Vector3.new(yO, 0, yT))
                        yG = Vector3.new(yE_1.X, yC.groundY, yE_1.Z)
                        yK = if FarmPosition.IsValidEggPlacement(fI, yG, tQ, tN, 1, 1) then 14 else 7
                    else
                        yK = 10763
                        continue
                    end
                else
                    yK = if yR > 0 and yS <= yQ or yR <= 0 and yS >= yQ then 0 else 9
                end
            elseif yK_1 < 10974 then
                if yK_1 < 10970 then
                    if yK_1 < 10968 then
                        if yK_1 < 10967 then
                            if yK_1 == 10966 then
                                yK = if yM > 0 and yN <= yL or yM <= 0 and yN >= yL then 4 else 6
                            else
                                yK = 10962
                                continue
                            end
                        else
                            yK = 13
                        end
                    elseif yK_1 < 10969 then
                        yC = FarmPosition.GetFarmData(fI)
                        yK = if not yC then 5 else 2
                    elseif yK_1 == 10969 then
                        yK = 15
                    else
                        yK = 959
                        continue
                    end
                elseif yK_1 < 10972 then
                    if yK_1 < 10971 then
                        if yK_1 == 10970 then
                            return nil
                        end
                        yK = 10975
                        continue
                    elseif yK_1 == 10971 then
                        return nil
                    else
                        yK = 10974
                        continue
                    end
                elseif yK_1 < 10973 then
                    yO = yN
                    yK = 3
                else
                    yS = yI
                    yQ = yJ
                    yR = yD
                    yK = 11
                end
            elseif yK_1 < 10975 then
                if yK_1 == 10974 then
                    local mainPart = yC.mainPart
                    local Size = mainPart.Size
                    CFrame = mainPart.CFrame
                    yD = 6
                    yG = -Size.X / 2 + 5
                    local yH = Size.X / 2 - 5
                    yI = -Size.Z / 2 + 5
                    yJ = Size.Z / 2 - 5
                    yN = yG
                    yL = yH
                    yM = yD
                    yK = 10
                else
                    yK = 10971
                    continue
                end
            elseif yK_1 < 10976 then
                break
            else
                yT = yS
                yK = 12
            end
        end
    end
end
local function fn60(bG, bH)
    local u5 = bG and bG.Value
    if type(u5) ~= "table" then
        return false
    elseif u5[bH] == true then
        return true
    else
        for k, v in pairs(u5) do
            if v == bH then
                return true
            end
        end
        return false
    end
end
local function fn74(bX)
    if not bX then
        return nil
    end
    local Parent = bX.Parent
    local vn = Parent and Parent:IsA("BasePart")
    if vn then
        return Parent.Position
    end
    local vn_1 = Parent and Parent:IsA("Attachment")
    if vn_1 then
        return Parent.WorldPosition
    end
    local vn_2 = Parent and Parent:IsA("Model")
    if vn_2 then
        return Parent:GetPivot().Position
    end
    return nil
end
local function fn82(a7)
    tR[#tR + 1] = a7
    return a7
end
local function fn112(gJ)
    local zm = Eggs[gJ]
    local zm_1 = zm and zm.DisplayName or gJ
    return sR(Options.BuyEggFilter, zm_1)
end
local function fn139()
    local Character = s5.Character
    local uG = Character and Character:FindFirstChildOfClass("Humanoid")
    return uG
end
local function fn187(e0)
    local yl_1
    local yk_1
    local yj_1
    if not (Toggles.AutoServe and Toggles.AutoServe.Value) then
        return false
    end
    local yi_1 = tz(function(e3)
        return sE(e3, "PerfectlyCooked")
    end)[1] or tz(function(e7)
        return sE(e7, "Cooked")
    end)[1]
    if not yi_1 then
        return false
    end
    yj_1, yk_1, yl_1 = tH(e0)
    local yj_2 = not yk_1
    local yp = if yj_2 then 1 else 0
    local yn = 784 * yp + 61 * (1 - yp)
    local yo = 333 * yp + 3702 * (1 - yp)
    if not ((yn * 1024 + yo * 1761 + yn * yo) % 16777213 == 1650301) then
        yj_2 = not yl_1
    end
    if not yj_2 then
        yj_2 = yl_1.ActionText ~= "Serve Food"
    end
    if yj_2 then
        return false
    end
    local yj_3 = tr[yl_1] and tick() < tr[yl_1]
    if yj_3 then
        return false
    elseif not sr(yi_1) then
        return false
    else
        sW(yl_1)
        tr[yl_1] = tick() + 2
        local yi_2 = os.clock() + 1.25
        while os.clock() < yi_2 do
            if yl_1.ActionText == "Remove Food" then
                break
            end
            task.wait(0.05)
        end
        if yl_1.ActionText == "Serve Food" then
            tr[yl_1] = nil
            return false
        end
        return true
    end
end
local function fn247()
    local u_ = tg()
    local u__1 = u_ and u_.Currencies and u_.Currencies.Cash
    if type(u__1) == "number" then
        return u__1
    end
    return 0
end
local function fn269(dz)
    local ws = {}
    for k, v in sA(dz) do
        local wt = v.ActionText or ""
        if not string.find(wt, "Take out", 1, true) then
            ws[#ws + 1] = v
        end
    end
    return ws
end
local function fn279(hh)
    if not (Toggles.AutoRollEggs and Toggles.AutoRollEggs.Value) then
        return false
    end
    local zI = if tick() < tB then 1 else 0
    if zI == 1 then
        return false
    end
    local LeverMechanism = hh:FindFirstChild("LeverMechanism")
    local zB = LeverMechanism and tq(LeverMechanism, "SpinPrompt")
    if not zB or not zB.Enabled then
        return false
    end
    tB = tick() + tA
    sW(zB)
    return true
end
local function fn295(cv)
    local vE = cv:IsA("Tool") and cv:GetAttribute("ItemKind") == "Egg" and type(cv:GetAttribute("EggGuid")) == "string"
    return vE
end
local function fn313(ec)
    if not (Toggles.AutoPerfectCook and Toggles.AutoPerfectCook.Value) then
        return false
    end
    local PlacedCook = ec:FindFirstChild("PlacedCook")
    if not PlacedCook then
        return false
    end
    local xm = false
    for i, child in PlacedCook:GetChildren() do
        for k, v in tm(child) do
            local xl_2 = tz(function(el)
                return sE(el, "Raw")
            end)[1]
            if not xl_2 then
                return xm
            end
            if sr(xl_2) then
                sW(v)
                xm = true
                task.wait(0.25)
            end
        end
    end
    return xm
end
local function fn373(dm)
    local wd = {}
    for k, v in sx(dm, "PromptAttachment") do
        local ProximityPrompt = v:FindFirstChildOfClass("ProximityPrompt")
        if ProximityPrompt then
            wd[#wd + 1] = ProximityPrompt
        end
    end
    return wd
end
local function fn400()
    if not (Toggles.AutoUnlockRolls and Toggles.AutoUnlockRolls.Value) then
        return
    end
    local zR_1 = tg()
    local zS = zR_1 and zR_1.Stats and tonumber(zR_1.Stats.EggRollSlot)
    local zR_2 = zS or 1
    local zR_3 = tonumber(Configuration.MAX_EGG_ROLLS) or 3
    if zR_2 >= zR_3 then
        return
    end
    local ExtraEggRollsCosts = Configuration.ExtraEggRollsCosts
    local zT_1 = ExtraEggRollsCosts and tonumber(ExtraEggRollsCosts[zR_2 + 1])
    local zS_2 = not zT_1 or s4() < zT_1
    if zS_2 then
        return
    end
    pcall(function()
        Upgrade:FireServer("EggRolls")
    end)
end
local function fn473(ix, iy)
    local Af = sO()
    if ix == "CookTool" then
        local Ag_1 = Af and Af:FindFirstChild("PlacedCook")
        if Ag_1 then
            for i, child in Ag_1:GetChildren() do
                if child.Name == iy then
                    return true
                end
            end
        end
    else
        local Ag_2 = Af and Af:FindFirstChild("PlacedTable")
        if Ag_2 then
            for i, child in Ag_2:GetChildren() do
                if child.Name == iy then
                    return true
                end
            end
        end
    end
    local Af_2 = tg()
    local Ag_3 = Af_2 and Af_2.Inventory
    if Ag_3 then
        Ag_3 = ix == "CookTool" and Af_2.Inventory.CookingTools or Af_2.Inventory.ServingTables
    end
    local Af_3 = Ag_3
    if type(Af_3) == "table" then
        for k, v in Af_3 do
            local Af_4 = type(v) == "table" and v.Id == iy
            if Af_4 then
                return true
            end
        end
    end
    return false
end
local function fn510(am, an, ao)
    local up = {}
    local uq = {}
    local ur = {}
    for k, v in am do
        local us = an[v]
        local us_1 = us and us[ao] or v
        ur[#ur + 1] = us_1
        uq[us_1] = v
        up[us_1] = true
    end
    return ur, uq, up
end
local function fn527(h1)
    local z0 = tC()
    local z1 = z0 and z0.Data and z0.Data.PetShopState and z0.Data.PetShopState.Stock
    local z0_1 = z1
    if z1 then
        z1 = z0_1[h1]
    end
    local z0_2 = z1
    if type(z0_2) ~= "table" then
        return false
    end
    local z1_1 = z0_2.IsInStock == true
    if z1_1 then
        local z2 = tonumber(z0_2.StockAmount) or 0
        z1_1 = z2 > 0
    end
    return z1_1
end
local function fn544()
    return tn
end
local function worker()
    while not Library.Unloaded do
        pcall(function()
            local AU = sO()
            sF()
            sz()
            so()
            sH()
            tu()
            sn()
            tf()
            if AU then
                s_(AU)
                tD(AU)
                local AV = sm(AU)
                if not AV then
                    sv(AU)
                end
                s3(AU)
                sS(AU)
                sN(AU)
            end
        end)
        task.wait(0.18)
    end
end
local function fn582()
    local uX = sl()
    return uX and uX.Data
end
local function fn624(dv)
    local wm_1 = dv and dv.ActionText or ""
    return string.find(wm_1, "Perfect", 1, true) ~= nil
end
local function fn652()
    local uS_1
    local uR_1
    if not DataAggregation then
        return nil
    end
    uR_1, uS_1 = pcall(DataAggregation.GetReplica)
    if uR_1 then
        return uS_1
    end
    return nil
end
local function fn657(bS)
    local vg = s8()
    local vh = not vg or typeof(bS) ~= "Vector3"
    if vh then
        return false
    end
    vg.CFrame = CFrame.new(bS + Vector3.new(0, 3, 0))
    vg.AssemblyLinearVelocity = Vector3.zero
    return true
end
local function onOnClientEvent(cN)
    if type(cN) == "table" then
        tO = cN
    end
    tB = 0
end
local function fn777(cy, cz)
    local vJ = if not cy:IsA("Tool") then 1 else 0
    if vJ == 1 then
        return false
    elseif cy:GetAttribute("ItemKind") ~= "Food" then
        return false
    elseif cy:GetAttribute("ToolCategory") ~= "Meat" then
        return false
    elseif cz then
        return cy:GetAttribute("FoodState") == cz
    else
        return true
    end
end
local function fn816(b9, ca)
    local vr = {}
    if not b9 then
        return vr
    end
    local vs = b9:FindFirstChild(ca)
    local vt = vs and vs:IsA("Attachment")
    if vt then
        vr[1] = vs
    end
    local vs_1 = 1
    while true do
        local vt_1 = b9:FindFirstChild(ca .. vs_1)
        if not vt_1 then
            break
        end
        if vt_1:IsA("Attachment") then
            vr[#vr + 1] = vt_1
        end
        vs_1 += 1
    end
    return vr
end
local function fn837(eD)
    local xR = eD.PrimaryPart or eD:FindFirstChild("HumanoidRootPart") or eD:FindFirstChildWhichIsA("BasePart")
    return xR
end
local function fn926(eG)
    local CustomerNPCs = Workspace:FindFirstChild("CustomerNPCs")
    local xU = eG and eG:FindFirstChild("PlacedTable")
    if not CustomerNPCs or not xU then
        return nil
    end
    for i, child in CustomerNPCs:GetChildren() do
        if child:GetAttribute("OwnerPlayerName") == s5.Name then
            local xT_1 = sk(child)
            if xT_1 then
                for i, child2 in xU:GetChildren() do
                    for k, v in sY(child2) do
                        local sit = v.sit
                        local prompt = v.prompt
                        if sit and prompt and (prompt and prompt.ActionText or "") == "Serve Food" and (xT_1.Position - sit.WorldPosition).Magnitude <= 10 then
                            return child, child2, prompt
                        end
                    end
                end
            end
        end
    end
    return nil
end
local function fn929(aM, aN)
    if setclipboard then
        setclipboard(aM)
    elseif toclipboard then
        toclipboard(aM)
    end
    Library:Notify(aN)
end
local function fn933()
    local uV_1
    local uU_1
    if not DataAggregation then
        return nil
    end
    uU_1, uV_1 = pcall(DataAggregation.GetSessionReplica)
    if uU_1 then
        return uV_1
    end
    return nil
end
local function fn944(gq, gr)
    local EggDisplayPedestals = gq:FindFirstChild("EggDisplayPedestals")
    local zg = EggDisplayPedestals and EggDisplayPedestals:FindFirstChild("Pedestal" .. gr)
    if not zg then
        return nil
    end
    local DisplayEgg = zg:FindFirstChild("DisplayEgg")
    if not DisplayEgg then
        return nil
    end
    local ProximityPrompt = DisplayEgg:FindFirstChildWhichIsA("ProximityPrompt", true)
    local zh = ProximityPrompt and ProximityPrompt.ObjectText
    local zh_1 = type(zh) == "string" and st[zh]
    if zh_1 then
        return st[zh]
    end
    local NPCName = DisplayEgg:FindFirstChild("NPCName", true)
    local zg_2 = NPCName and NPCName.Text
    local zg_3 = type(zg_2) == "string" and st[zg_2]
    if zg_3 then
        return st[zg_2]
    end
    local zf_6 = tO[gr]
    local zg_4 = type(zf_6) == "table" and type(zf_6.Id) == "string"
    if zg_4 then
        return zf_6.Id
    end
    return nil
end
local function fn964()
    s7(sI, "Copied Discord invite to clipboard")
end
local function fn1044()
    local Map = Workspace:FindFirstChild("Map")
    local uJ = Map and Map:FindFirstChild("Plots")
    if not uJ then
        return nil
    end
    for i, child in uJ:GetChildren() do
        if child:GetAttribute("Owner") == s5.Name then
            return child
        end
    end
    return nil
end
local function fn1085(gg)
    if not (Toggles.AutoHatch and Toggles.AutoHatch.Value) then
        return false
    end
    local PlacedEgg = gg:FindFirstChild("PlacedEgg")
    if not PlacedEgg then
        return false
    end
    for i, child in PlacedEgg:GetChildren() do
        if child:GetAttribute("IsReady") == true then
            local y1_2 = tq(child, "HatchPrompt")
            if y1_2 then
                sW(y1_2)
                return true
            end
        end
    end
    return false
end
local function fn1090(b2, b3)
    local vp = tc(b2)
    if vp then
        tF(vp)
        if not b3 then
            task.wait(0.2)
        end
    end
    sp(b2)
end
local function fn1119(aT)
    local DiscordGroup = aT:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = sZ })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = sZ })
end
local function fn1125()
    DataAggregation = require(s5:WaitForChild("PlayerScripts"):WaitForChild("ClientLoader"):WaitForChild("Modules"):WaitForChild("DataAggregation"))
end
local function fn1132()
    if not (Toggles.AutoCollectCash and Toggles.AutoCollectCash.Value) then
        return
    end
    if tick() - tw < 0.35 then
        return
    end
    local vV_1 = tg()
    local vW = vV_1 and vV_1.Currencies
    if not vW then
        return
    end
    local vW_1 = tonumber(vW.UnclaimedCash) or 0
    if vW_1 > 0 then
        pcall(function()
            CollectCash:FireServer("FoodCash")
        end)
        tw = tick()
    end
    local vW_2 = tonumber(vW.UnclaimedAnimalCash) or 0
    local vX = vW_2 > 0
    if not vX then
        local vW_3 = tonumber(vW.OfflineAnimalCash) or 0
        vX = vW_3 > 0
    end
    if vX then
        pcall(function()
            CollectCash:FireServer("AnimalCash")
        end)
        tw = tick()
    end
    local vW_4 = tonumber(vW.Tips) or 0
    if vW_4 > 0 then
        pcall(function()
            CollectCash:FireServer("TipCash")
        end)
        tw = tick()
    end
end
local function fn1138(es)
    local xD = {}
    local xE = sx(es, "PromptAttachment")
    local xF = sx(es, "SitAttachment")
    local xG = math.max(#xE, #xF)
    local xL = 1
    while xL <= xG do
        local xM = xL
        local xG_1 = xE[xM]
        local xH = xG_1 and xG_1:FindFirstChildOfClass("ProximityPrompt")
        xD[#xD + 1] = { sit = xF[xM], prompt = xH }
        xL += 1
    end
    return xD
end
local function fn1154()
    local Character = s5.Character
    local uD = Character and Character:FindFirstChild("HumanoidRootPart")
    return uD
end
local function fn1170(cJ, cK)
    if not cJ then
        return nil
    end
    local vR = cJ:FindFirstChild(cK, true)
    local vS = vR and vR:IsA("ProximityPrompt")
    if vS then
        return vR
    end
    return nil
end
Eggs = nil
sk = nil
sl = nil
sm = nil
sn = nil
so = nil
sp = nil
DataAggregation = nil
sr = nil
Upgrade = nil
st = nil
sv = nil
sx = nil
sz = nil
sA = nil
sE = nil
sF = nil
sH = nil
sI = nil
CollectCash = nil
sN = nil
sO = nil
sR = nil
sS = nil
local sV
sW = nil
sY = nil
sZ = nil
s_ = nil
s2 = nil
s3 = nil
s4 = nil
local si, su, sw, BuyShopItem, sB, sC, BuyPetEgg, sG, sK, sL, sM, sP, sQ, PlaceEgg, sU, AcceptEgg, s0, s1
s5 = nil
s7 = nil
s8 = nil
Workspace = nil
Options = nil
tc = nil
Toggles = nil
tf = nil
tg = nil
tm = nil
tn = nil
tq = nil
tr = nil
FarmPosition = nil
tu = nil
Library = nil
tw = nil
Configuration = nil
tz = nil
tA = nil
tB = nil
tC = nil
tD = nil
tF = nil
tH = nil
tN = nil
tO = nil
tQ = nil
tR = nil
local s6, tb, td, th, tj, SaveManager, tl, tp, ts, tx, tE, tG, tI, tJ, tK, tL, tM, tP
s6 = nil
tb = nil
td = nil
th = nil
local ti
tj = nil
SaveManager = nil
tl = nil
local SharedUtils
tp = nil
ts = nil
tx = nil
tE = nil
tG = nil
tI = nil
tJ = nil
tK = nil
tL = nil
tM = nil
tP = nil
local t1, t2, t4, t7, t8, t9, DisplayEggRoll, uc, ud, ue
si, En_8, tL, tE, tx, ts, tn, th, tb, Workspace, s6, s5, s2 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local En_2 = 8
repeat
    En_6 = (En_2 * 3 + 3) % 5 + 1
    if En_6 <= 3 then
        if En_6 <= 2 then
            if En_6 <= 1 then
                local En_4_1 = {
                    "wxczazts",
                    "umhclprdzenm",
                    "vgpftw",
                    "rsyblw",
                    "lon",
                    "nblj",
                    "nzaf",
                    "fpvfituchs",
                    "smkjkowdya",
                    "hceg",
                    "fmtjbfnzmvcz",
                    "zoy",
                    "wzkoyp",
                    "myldu",
                    "ovyz"
                }
                if En_4_1[(En_2 * 17 + 70) % 15 + 1] < En_4_1[(En_2 * 17 + 70) % 15 + 1] then
                    s6 = game:GetService("GuiService")
                    th = game:GetService("TeleportService")
                    s5 = game:GetService("Workspace")
                    si = game:GetService("Lighting")
                    tb = Workspace.LocalPlayer
                else
                    th = game:GetService("GuiService")
                    tb = game:GetService("TeleportService")
                    Workspace = game:GetService("Workspace")
                    s6 = game:GetService("Lighting")
                    s5 = si.LocalPlayer
                end
                En_2 = (En_2 + 2) % 20
            else
                local En_4_2 = (vector.create((En_2 * 3 + 1) % 11 + 1, (En_2 * 11 + 1) % 13 + 1, (En_2 * 4 + 12) % 17 + 1))
                En_1 = (vector.create((En_2 * 1 + 4) % 11 + 1, (En_2 * 7 + 9) % 13 + 1, (En_2 * 6 + 7) % 17 + 1))
                local FJ = vector.cross(En_4_2, En_1)
                local FK = vector.dot(En_4_2, En_1)
                if vector.dot(FJ, FJ) + FK * FK == vector.dot(En_4_2, En_4_2) * vector.dot(En_1, En_1) then
                    s2 = fn544
                else
                    th = fn544
                end
                En_2 = (En_2 + 7) % 20
            end
        else
            if (En_2 * 3 + 8) * 17 % 4 == ((En_2 * 3 + 8) * 17 + 0) % 4 then
                si = game:GetService("Players")
            else
                s2 = game:GetService("Players")
            end
            En_2 = (En_2 + 12) % 20
        end
    elseif En_6 <= 4 then
        local FF = bit32.rrotate(bit32.bxor(bit32.lrotate(En_2, 27), string.byte(tostring(tn))), 6)
        if bit32.bxor(bit32.lrotate(bit32.bxor(FF, 3548827091), 30), 4108432244) ~= bit32.lrotate(FF, 30) then
            si = game:GetService("ReplicatedStorage")
        else
            En_8 = game:GetService("ReplicatedStorage")
        end
        En_2 = (En_2 + 12) % 20
    else
        En_6 = (vector.create((En_2 * 6 + 9) % 11 + 1, (En_2 * 1 + 4) % 13 + 1, (En_2 * 13 + 4) % 17 + 1))
        local En_4_3 = (vector.create((En_2 * 5 + 4) % 11 + 1, (En_2 * 5 + 5) % 13 + 1, (En_2 * 11 + 6) % 17 + 1))
        En_1 = (vector.create((En_2 * 5 + 6) % 11 + 1, (En_2 * 5 + 3) % 13 + 1, (En_2 * 8 + 9) % 17 + 1))
        if vector.dot(vector.cross(En_6, En_4_3), En_1) == vector.dot(vector.cross(En_4_3, En_1), En_6) + 4 then
            tn = game:GetService("RunService")
            tx = game:GetService("UserInputService")
            tL = game:GetService("VirtualUser")
            tE = game:GetService("HttpService")
            ts = game:GetService("CoreGui")
        else
            tL = game:GetService("RunService")
            tE = game:GetService("UserInputService")
            tx = game:GetService("VirtualUser")
            ts = game:GetService("HttpService")
            tn = game:GetService("CoreGui")
        end
        En_2 = (En_2 + 17) % 20
    end
until (En_2 * 7 + 15) % 20 == 1
if getgenv then
    sV, En_6 = nil, nil
    En_2 = 3
    repeat
        if (En_2 * 1 + 0) % 2 + 1 <= 1 then
            if En_2 * 108597479 + 4 + 2 >= En_2 * 108597479 + 4 + 2 + 4 then
                sV = En_6
            else
                En_6 = sV
            end
            En_2 = (En_2 + 15) % 16
        else
            if (En_2 * 3 + 5) * 9 % 4 == ((En_2 * 3 + 5) * 9 + 11) % 4 then
                getgenv().gethui = sV
                s2 = getgenv().__TempoHatchAndFryLib
            else
                getgenv().gethui = s2
                sV = getgenv().__TempoHatchAndFryLib
            end
            En_2 = (En_2 + 7) % 16
        end
    until (En_2 * 11 + 7) % 16 == 10
    if En_6 then
        En_6 = sV.Unload
    end
    if En_6 then
        pcall(function()
            sV:Unload()
        end)
    end
end
pcall(function()
    gethui = s2
end)
if setthreadidentity then
    setthreadidentity(8)
end
sL, sI, sC, sw, En_6, Eggs, tP, tM, tG, Configuration, FarmPosition, SharedUtils, t4, t1, En_5, En_7, AcceptEgg, PlaceEgg, DisplayEggRoll, sP, sM, CollectCash, BuyPetEgg, BuyShopItem, Upgrade, DataAggregation, tQ, tN, tI, tA, tp, tj, td, st, t8, t7, En_2, ud, uc, Library, SaveManager = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
sL = "Hatch And Fry"
sI = "https://discord.gg/K7Qxnxkk46"
sC = "https://discord.gg/K7Qxnxkk46"
sw = "https://tempohub.shop"
En_1 = En_8:WaitForChild("Shared")
local En_4_5 = En_1:WaitForChild("Registry")
if ((BuyPetEgg or not BuyPetEgg) and (BuyPetEgg or not BuyPetEgg) or (not Upgrade or Upgrade) and (not Upgrade and BuyPetEgg)) and ((Upgrade or not BuyPetEgg) and (not BuyPetEgg or not Upgrade) or not BuyPetEgg and Upgrade and (Upgrade and BuyPetEgg)) and ((not Upgrade or not BuyPetEgg) and (Upgrade and Upgrade) or (not Upgrade or not Upgrade) and (Upgrade or not Upgrade) or BuyPetEgg and BuyPetEgg and (not Upgrade and not Upgrade) and (not Upgrade or Upgrade or Upgrade and not Upgrade)) or not (((BuyPetEgg or not BuyPetEgg) and (BuyPetEgg or not BuyPetEgg) or (not Upgrade or Upgrade) and (not Upgrade and BuyPetEgg)) and ((Upgrade or not BuyPetEgg) and (not BuyPetEgg or not Upgrade) or not BuyPetEgg and Upgrade and (Upgrade and BuyPetEgg)) and ((not Upgrade or not BuyPetEgg) and (Upgrade and Upgrade) or (not Upgrade or not Upgrade) and (Upgrade or not Upgrade) or BuyPetEgg and BuyPetEgg and (not Upgrade and not Upgrade) and (not Upgrade or Upgrade or Upgrade and not Upgrade))) then
    En_6 = En_8:WaitForChild("Remotes")
else
    En_6:WaitForChild("Remotes")
end
if (not DisplayEggRoll and DisplayEggRoll and (not DisplayEggRoll) and (DisplayEggRoll and false or not DisplayEggRoll and 67) or (not DisplayEggRoll or not DisplayEggRoll and not DisplayEggRoll) and ((not DisplayEggRoll or DisplayEggRoll) and false)) and not (not DisplayEggRoll and DisplayEggRoll and (not DisplayEggRoll) and (DisplayEggRoll and false or not DisplayEggRoll and 67) or (not DisplayEggRoll or not DisplayEggRoll and not DisplayEggRoll) and ((not DisplayEggRoll or DisplayEggRoll) and false)) then
    En_4_5 = require(Eggs:WaitForChild("Eggs"))
else
    Eggs = require(En_4_5:WaitForChild("Eggs"))
end
tP = require(En_4_5:WaitForChild("PetEggs"))
tM = require(En_4_5:WaitForChild("CookingTools"))
tG = require(En_4_5:WaitForChild("ServingTables"))
Configuration = require(En_1:WaitForChild("Config"):WaitForChild("Configuration"))
FarmPosition = require(En_1:WaitForChild("FarmPosition"))
SharedUtils = require(En_1:WaitForChild("SharedUtils"))
if Eggs and Upgrade or (En_5 or t7) or En_6 and Upgrade and (not t7 or not En_6) or (En_6 or Upgrade or Eggs and not t7) and ((not t7 or not En_6) and (En_5 and t7)) or not (Eggs and Upgrade or (En_5 or t7) or En_6 and Upgrade and (not t7 or not En_6) or (En_6 or Upgrade or Eggs and not t7) and ((not t7 or not En_6) and (En_5 and t7))) then
    t4 = En_6:WaitForChild("Egg")
else
    En_6 = t4:WaitForChild("Egg")
end
local t3 = En_6:WaitForChild("Animal")
if (not ud or not ud or (ud or not En_5) or (not ud or ud) and (ud or ud)) and ((not ud or not ud or ud and not ud) and (not En_5 and not ud or (not ud or not En_5))) or not ((not ud or not ud or (ud or not En_5) or (not ud or ud) and (ud or ud)) and ((not ud or not ud or ud and not ud) and (not En_5 and not ud or (not ud or not En_5)))) then
    t1 = En_6:WaitForChild("Cook_Table")
else
    En_6 = t1:WaitForChild("Cook_Table")
end
local En_9 = En_6:WaitForChild("Plot")
local En_3 = En_6:WaitForChild("PetShop")
if (not uc or uc or (not uc or t8)) and (not t8 and not uc and (t8 or t8)) and (not uc or t8 or (not uc or uc) or (not t8 or t8 or uc and uc)) or ((not uc or uc) and (not uc and uc) and (not uc and not uc and (not uc and not uc)) or (not t8 and t8 or (not uc or not uc)) and (not t8 or not t8 or uc and uc)) or not ((not uc or uc or (not uc or t8)) and (not t8 and not uc and (t8 or t8)) and (not uc or t8 or (not uc or uc) or (not t8 or t8 or uc and uc)) or ((not uc or uc) and (not uc and uc) and (not uc and not uc and (not uc and not uc)) or (not t8 and t8 or (not uc or not uc)) and (not t8 or not t8 or uc and uc))) then
    En_5 = En_6:WaitForChild("ShopMain")
else
    En_6 = En_5:WaitForChild("ShopMain")
end
if ((not tP and not En_5 or (not En_5 or not tP)) and (not En_5 or En_5 or not tP and not tP) or En_5 and not En_5 and (not En_5 or En_5) and (not tP and not tP and (not En_5 and En_5))) and ((not tP or En_5 or tP and not tP) and (tP or En_5 or not tP and tP) and ((not En_5 and tP or not tP and not tP) and (not tP or tP or not En_5 and tP))) or not (((not tP and not En_5 or (not En_5 or not tP)) and (not En_5 or En_5 or not tP and not tP) or En_5 and not En_5 and (not En_5 or En_5) and (not tP and not tP and (not En_5 and En_5))) and ((not tP or En_5 or tP and not tP) and (tP or En_5 or not tP and tP) and ((not En_5 and tP or not tP and not tP) and (not tP or tP or not En_5 and tP)))) then
    En_7 = En_6:WaitForChild("UpgradeFold")
else
    En_7:WaitForChild("UpgradeFold")
end
if (not BuyPetEgg and not BuyPetEgg or not t4 and SharedUtils or (not BuyPetEgg or t3 or (not BuyPetEgg or not t4))) and not (not BuyPetEgg and not BuyPetEgg or not t4 and SharedUtils or (not BuyPetEgg or t3 or (not BuyPetEgg or not t4))) then
    AcceptEgg:WaitForChild("AcceptEgg")
    AcceptEgg:WaitForChild("PlaceEgg")
    AcceptEgg:WaitForChild("DisplayEggRoll")
    sM = PlaceEgg:WaitForChild("ProcessAnimal")
    sP = DisplayEggRoll:WaitForChild("RemoveMeat")
else
    AcceptEgg = t4:WaitForChild("AcceptEgg")
    PlaceEgg = t4:WaitForChild("PlaceEgg")
    DisplayEggRoll = t4:WaitForChild("DisplayEggRoll")
    sP = t3:WaitForChild("ProcessAnimal")
    sM = t1:WaitForChild("RemoveMeat")
end
CollectCash = En_9:WaitForChild("CollectCash")
BuyPetEgg = En_3:WaitForChild("BuyPetEgg")
BuyShopItem = En_5:WaitForChild("BuyShopItem")
Upgrade = En_7:WaitForChild("Upgrade")
pcall(fn1125)
tQ = Vector3.new(3.46, 4.24, 3.64)
tN = { "PlacedEgg", "PlacedPetEgg" }
tI = 0.6
tA = 1.6
local t5 = {
    "CommonEgg",
    "UncommonEgg",
    "RareEgg",
    "EpicEgg",
    "LegendaryEgg",
    "MythicEgg",
    "SecretEgg",
    "DinoEgg"
}
tp = {
    "HamsterEgg",
    "GuineaPigEgg",
    "LizardEgg",
    "ParrotEgg",
    "CapybaraEgg",
    "CatEgg",
    "DogEgg",
    "DireWolfEgg",
    "KitsuneEgg"
}
tj = {
    "StarterGrill",
    "BasicGrill",
    "AdvancedGrill",
    "ToasterOven",
    "PizzaOven",
    "IndustrialStove",
    "RadioactiveSmoker",
    "DinoGrill"
}
td = { "BasicTable", "TikiTable", "IndustrialCounter", "PicnicTable", "GlassTable" }
if (En_7 and En_7 or (not En_7) or (not En_7 or (not BuyShopItem))) and (not En_7 or 53) and (BuyShopItem or false or (En_7 or not En_7 or (BuyShopItem or 53)) or En_7 and (BuyShopItem or 53) and ((not En_7 or En_7) and (not BuyShopItem))) and not ((En_7 and En_7 or (not En_7) or (not En_7 or (not BuyShopItem))) and (not En_7 or 53) and (BuyShopItem or false or (En_7 or not En_7 or (BuyShopItem or 53)) or En_7 and (BuyShopItem or 53) and ((not En_7 or En_7) and (not BuyShopItem)))) then
    ue = fn510
    t2, tM, tp = ue(Eggs, tj, "DisplayName")
    t5, t9, tP = ue(td, t7, "DisplayName")
    tG = ue(st, En_2, "DisplayName")
    ud = ue(uc, t8, "DisplayName")
else
    t2 = fn510
    t9, st, t8 = t2(t5, Eggs, "DisplayName")
    t7, En_2, ue = t2(tp, tP, "DisplayName")
    ud = t2(tj, tM, "DisplayName")
    uc = t2(td, tG, "DisplayName")
end
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
if getgenv then
    getgenv().__TempoHatchAndFryLib = Library
end
Toggles, Options, su, tR, tO, tJ, tB, tw, tr, sG, s7, sZ, tl, s8, s0, sO, sl, tC, tg, s4, sR, sp, tF, tc, sW, sx, tz, sQ, sE, sr, tq, sF, tf, sA, tK, tm, s_, sv, sY, sk, tH, sm, sz, sK, s3, tD, s1, ti, sS, sN, tu, sn, sU, so, sB, sH = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Toggles = Library.Toggles
Options = Library.Options
s7 = fn929
sZ = fn964
En_9 = fn1119
local En_4_6 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = sI, Copyable = true }, "|", sL },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    SidebarCompacted = true,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
En_4_6:SetGlow(true, { Color = Color3.fromRGB(242, 154, 196), Radius = 24, Transparency = 0.3 })
su = {
    Info = En_4_6:AddTab("Info", "info"),
    Main = En_4_6:AddTab("Main", "egg"),
    Player = En_4_6:AddTab("Player", "person-standing"),
    Settings = En_4_6:AddTab("Settings", "settings")
}
En_6 = su.Main:AddSubTab("Eggs", "egg")
En_8 = su.Main:AddSubTab("Kitchen", "flame")
En_2 = su.Main:AddSubTab("Shop", "shopping-bag")
En_9(En_6)
En_9(En_8)
En_9(En_2)
En_9(su.Player)
En_9(su.Settings)
tR = {}
tO = {}
tJ = 0
tB = 0
tw = 0
tr = {}
tl = fn82
s8 = fn1154
s0 = fn139
sO = fn1044
sl = fn652
tC = fn933
tg = fn582
s4 = fn247
sR = fn60
sp = function(bN)
    local ve = not bN or not bN:IsA("ProximityPrompt")
    if ve then
        return
    end
    bN.HoldDuration = 0
    bN.RequiresLineOfSight = false
    if fireproximityprompt then
        pcall(fireproximityprompt, bN)
        return
    end
    if firesignal then
        pcall(firesignal, bN.Triggered, s5)
        return
    end
    pcall(function()
        bN:InputHoldBegin()
        bN:InputHoldEnd()
    end)
end
tF = fn657
tc = fn74
sW = fn1090
sx = fn816
tz = function(ci)
    local cj
    cj = {}
    local function ck(cl)
        if not cl then
            return
        end
        for i, child in cl:GetChildren() do
            local vv = (child:IsA("Tool"))
            if vv then
                local vw = not ci or ci(child)
                vv = vw
            end
            if vv then
                cj[#cj + 1] = child
            end
        end
    end
    ck(s5:FindFirstChild("Backpack"))
    ck(s5.Character)
    return cj
end
sQ = fn295
sE = fn777
sr = function(cB)
    local vK = s0()
    if not vK or not cB then
        return false
    elseif cB.Parent == s5.Character then
        return true
    else
        pcall(function()
            vK:EquipTool(cB)
        end)
        local vL_1 = os.clock() + 0.45
        while true do
            if not (os.clock() < vL_1) then
                return cB.Parent == s5.Character
            end
            if cB.Parent == s5.Character then
                break
            end
            task.wait()
        end
        return true
    end
end
tq = fn1170
tl(DisplayEggRoll.OnClientEvent:Connect(onOnClientEvent))
t3 = En_6:AddLeftGroupbox("Eggs", "egg")
t3:AddToggle("AutoRollEggs", { Text = "Auto Roll Eggs", Default = false })
t3:AddToggle("AutoBuyEggs", { Text = "Auto Buy Eggs", Default = false })
t3:AddDropdown("BuyEggFilter", { Text = "Eggs", Values = t9, Multi = true, Default = t8 })
t3:AddToggle("ClearLeftovers", { Text = "Buy Unselected Too", Default = false })
t2 = En_6:AddRightGroupbox("Hatch", "bird")
t2:AddToggle("AutoHatch", { Text = "Auto Hatch", Default = false })
t2:AddDivider("Upgrades")
t2:AddToggle("AutoUpgradeLuck", { Text = "Auto Upgrade Luck", Default = false })
t2:AddDropdown("LuckBuyCount", { Text = "Luck Amount", Values = { "1", "10" }, Default = 1 })
t2:AddToggle("AutoUnlockRolls", { Text = "Auto Unlock Rolls", Default = false })
t1 = En_8:AddLeftGroupbox("Cook", "flame")
t1:AddToggle("AutoPerfectCook", { Text = "Auto Perfect Cook", Default = false })
t1:AddToggle("AutoDiscardBurnt", { Text = "Auto Discard Burnt", Default = true })
t1:AddToggle("AutoServe", { Text = "Auto Serve", Default = false })
t1:AddToggle("AutoCollectCash", { Text = "Auto Collect Cash", Default = true })
En_3 = En_8:AddRightGroupbox("Animals", "beef")
En_3:AddToggle("AutoProcess", { Text = "Auto Process", Default = false })
En_3:AddDropdown("ProcessAge", { Text = "Age", Values = { "Adult", "Juvenile", "Baby" }, Default = 1 })
En_7 = En_2:AddLeftGroupbox("Pets", "paw-print")
En_7:AddToggle("AutoBuyPets", { Text = "Auto Buy Pets", Default = false })
En_7:AddDropdown("BuyPetFilter", { Text = "Pet Eggs", Values = t7, Multi = true, Default = ue })
En_1 = En_2:AddRightGroupbox("Items", "utensils")
En_1:AddToggle("AutoBuyGrills", { Text = "Auto Buy Grills", Default = false })
En_1:AddDropdown("BuyGrillFilter", { Text = "Grills", Values = ud, Multi = true, Default = {} })
En_1:AddToggle("AutoBuyTables", { Text = "Auto Buy Tables", Default = false })
En_1:AddDropdown("BuyTableFilter", { Text = "Tables", Values = uc, Multi = true, Default = {} })
sF = fn1132
tf = function()
    if not (Toggles.AutoDiscardBurnt and Toggles.AutoDiscardBurnt.Value) then
        return
    end
    for k, v in tz(function(dc)
        return sE(dc, "Burnt")
    end) do
        local attr = v:GetAttribute("FoodGuid")
        if type(attr) == "string" then
            pcall(function()
                sM:InvokeServer(attr)
            end)
            task.wait(0.15)
        end
    end
end
sA = fn373
tK = fn624
tm = fn269
s_ = function(dG)
    local PlacedCook
    if not (Toggles.AutoPerfectCook and Toggles.AutoPerfectCook.Value) then
        return false
    end
    PlacedCook = dG:FindFirstChild("PlacedCook")
    if not PlacedCook then
        return false
    end
    local function wR_1()
        local wC = false
        for i, child in PlacedCook:GetChildren() do
            for k, v in sA(child) do
                if tK(v) then
                    sW(v, true)
                    wC = true
                    task.wait(0.12)
                    tf()
                end
            end
        end
        return wC
    end
    local wZ = if wR_1() then 1 else 0
    if wZ == 1 then
        return true
    end
    local wS = false
    for i, child in PlacedCook:GetChildren() do
        for k, v in sA(child) do
            local find = string.find
            local wU_1 = v.ActionText or ""
            if find(wU_1, "(Cooked)", 1, true) then
                wS = true
                break
            end
        end
        if wS then
            break
        end
    end
    if not wS then
        return false
    end
    local wS_1 = os.clock() + 4
    while true do
        if not (os.clock() < wS_1) then
            return wR_1()
        end
        if wR_1() then
            break
        end
        local wT_2 = false
        for i, child in PlacedCook:GetChildren() do
            for k, v in sA(child) do
                local wU_2 = v.ActionText or ""
                local wU_3 = string.find(wU_2, "(Cooked)", 1, true) or string.find(wU_2, "Perfect", 1, true)
                if wU_3 then
                    wT_2 = true
                    break
                end
            end
            if wT_2 then
                break
            end
        end
        if not wT_2 then
            return wR_1()
        end
        task.wait()
    end
    return true
end
sv = fn313
sY = fn1138
sk = fn837
tH = fn926
sm = fn187
sG = { Baby = 1, Juvenile = 2, Adult = 3 }
sz = function()
    if not (Toggles.AutoProcess and Toggles.AutoProcess.Value) then
        return
    end
    local AnimalData = Workspace:FindFirstChild("AnimalData")
    local yr = AnimalData and AnimalData:FindFirstChild(s5.Name)
    if not yr then
        return
    end
    local ys_1 = sG[Options.ProcessAge and Options.ProcessAge.Value or "Adult"] or 3
    for i, child in yr:GetChildren() do
        local yB = child
        if yB:GetAttribute("OwnerUserId") == s5.UserId then
            local attr = yB:GetAttribute("GrowthStage")
            if (sG[attr] or 0) >= ys_1 then
                local yq_5 = true
                if ys_1 >= 3 then
                    local ys_3 = tonumber(yB:GetAttribute("CurrentKg")) or 0
                    local ys_4 = tonumber(yB:GetAttribute("IndividualMaxKg")) or 0
                    yq_5 = ys_4 > 0 and ys_3 + 0.01 >= ys_4
                end
                if yq_5 then
                    pcall(function()
                        sP:InvokeServer(yB.Name)
                    end)
                    task.wait(0.15)
                end
            end
        end
    end
end
sK = fn20
s3 = function(f_)
    local yV, attr
    if not (Toggles.AutoHatch and Toggles.AutoHatch.Value) then
        return false
    elseif tick() - tJ < tI then
        return false
    else
        local yX_1 = tz(sQ)[1]
        if not yX_1 then
            return false
        end
        attr = yX_1:GetAttribute("EggGuid")
        yV = sK(f_)
        if not yV then
            return false
        end
        sr(yX_1)
        tJ = tick()
        pcall(function()
            PlaceEgg:InvokeServer(attr, yV, 0)
        end)
        return true
    end
end
tD = fn1085
if ((not su or su) and (not En_1 or not sN) or En_8 and su and (su or not En_1)) and (tB or not su or su and su or (sN or En_1) and (su and not En_1)) or (not t1 and En_8 or (not t1 or not En_1) or (En_8 and En_1 or t1 and not En_1)) and (sN and not su and (sN and not t1) and (su and not En_1 and (not t1 or not t1))) or not (((not su or su) and (not En_1 or not sN) or En_8 and su and (su or not En_1)) and (tB or not su or su and su or (sN or En_1) and (su and not En_1)) or (not t1 and En_8 or (not t1 or not En_1) or (En_8 and En_1 or t1 and not En_1)) and (sN and not su and (sN and not t1) and (su and not En_1 and (not t1 or not t1)))) then
    s1 = fn944
    ti = fn112
    sS = function(gR)
        if not (Toggles.AutoBuyEggs and Toggles.AutoBuyEggs.Value) then
            return false
        elseif tick() < tB then
            return false
        else
            local zp_2 = s4()
            local zq = false
            for i = 1, 3 do
                local zz = i
                local zr = s1(gR, zz)
                local zr_6
                if zr then
                    local zs = Eggs[zr]
                    local zs_8
                    local zt = zs and tonumber(zs.Price)
                    local zt_3 = zt or math.huge
                    local zs_6 = ti(zr)
                    if (zs_6 or Toggles.ClearLeftovers and Toggles.ClearLeftovers.Value) and zp_2 >= zt_3 then
                        zr_6, zs_8 = pcall(function()
                            return AcceptEgg:InvokeServer(zz)
                        end)
                        zq = true
                        local zu_2 = zr_6 and type(zs_8) == "table" and zs_8.success ~= false
                        if zu_2 then
                            zp_2 -= zt_3
                            task.wait(0.12)
                        else
                            local zt_4 = zr_6 and type(zs_8) == "table" and zs_8.message == "NoCash"
                            if zt_4 then
                                break
                            end
                        end
                    end
                end
            end
            return zq
        end
    end
    sN = fn279
    tu = function()
        local zJ
        if not (Toggles.AutoUpgradeLuck and Toggles.AutoUpgradeLuck.Value) then
            return
        end
        local zK_6 = tg()
        local zL = zK_6 and zK_6.Stats and tonumber(zK_6.Stats.EggRollLuck)
        local zK_7 = zL or 1
        local zK_8 = Options.LuckBuyCount and Options.LuckBuyCount.Value == "10"
        zJ = 1
        if zK_8 then
            local zK_9 = SharedUtils.CalculateMultipleEggLuckUpgradeCost(zK_7, 10, s4())
            local zM_3 = tonumber(zK_9) or 0
            zJ = zM_3
            if zJ < 1 then
                return
            end
        else
            local zK_10 = SharedUtils.CalculateEggLuckUpgradeCost(zK_7)
            local zL_4 = s4()
            local zM_4 = tonumber(zK_10) or math.huge
            if zL_4 < zM_4 then
                return
            end
        end
        pcall(function()
            Upgrade:FireServer("EggLuck", zJ)
        end)
    end
else
    sN = fn944
    s1 = fn112
    tu = function(gR)
        if not (Toggles.AutoBuyEggs and Toggles.AutoBuyEggs.Value) then
            return false
        elseif tick() < tB then
            return false
        else
            local zp_1 = s4()
            local zq = false
            for i = 1, 3 do
                local zz = i
                local zr = s1(gR, zz)
                local zr_3
                if zr then
                    local zs = Eggs[zr]
                    local zs_4
                    local zt = zs and tonumber(zs.Price)
                    local zt_1 = zt or math.huge
                    local zs_2 = ti(zr)
                    if (zs_2 or Toggles.ClearLeftovers and Toggles.ClearLeftovers.Value) and zp_1 >= zt_1 then
                        zr_3, zs_4 = pcall(function()
                            return AcceptEgg:InvokeServer(zz)
                        end)
                        zq = true
                        local zu_1 = zr_3 and type(zs_4) == "table" and zs_4.success ~= false
                        if zu_1 then
                            zp_1 -= zt_1
                            task.wait(0.12)
                        else
                            local zt_2 = zr_3 and type(zs_4) == "table" and zs_4.message == "NoCash"
                            if zt_2 then
                                break
                            end
                        end
                    end
                end
            end
            return zq
        end
    end
    sS = fn279
    ti = function()
        local zJ
        if not (Toggles.AutoUpgradeLuck and Toggles.AutoUpgradeLuck.Value) then
            return
        end
        local zK_1 = tg()
        local zL = zK_1 and zK_1.Stats and tonumber(zK_1.Stats.EggRollLuck)
        local zK_2 = zL or 1
        local zK_3 = Options.LuckBuyCount and Options.LuckBuyCount.Value == "10"
        zJ = 1
        if zK_3 then
            local zK_4 = SharedUtils.CalculateMultipleEggLuckUpgradeCost(zK_2, 10, s4())
            local zM_1 = tonumber(zK_4) or 0
            zJ = zM_1
            if zJ < 1 then
                return
            end
        else
            local zK_5 = SharedUtils.CalculateEggLuckUpgradeCost(zK_2)
            local zL_2 = s4()
            local zM_2 = tonumber(zK_5) or math.huge
            if zL_2 < zM_2 then
                return
            end
        end
        pcall(function()
            Upgrade:FireServer("EggLuck", zJ)
        end)
    end
end
sn = fn400
sU = fn527
so = function()
    if not (Toggles.AutoBuyPets and Toggles.AutoBuyPets.Value) then
        return
    end
    local z4_1 = s4()
    for k, v in tp do
        local Ae = v
        local z5 = tP[Ae]
        local z7 = z5 and z5.DisplayName or Ae
        local z7_1 = sR(Options.BuyPetFilter, z7) and sU(Ae)
        if z7_1 then
            local z6_2 = z5 and tonumber(z5.Price)
            if z4_1 >= (z6_2 or math.huge) then
                pcall(function()
                    BuyPetEgg:InvokeServer(Ae)
                end)
                return
            end
        end
    end
end
sB = fn473
sH = function()
    local AD = s4()
    if Toggles.AutoBuyGrills and Toggles.AutoBuyGrills.Value then
        for k, v in tj do
            local AN = v
            local AE_1 = tM[AN]
            local AF_2 = AE_1 and AE_1.DisplayName or AN
            local AG_2 = sR(Options.BuyGrillFilter, AF_2) and not sB("CookTool", AN)
            if AG_2 then
                local AF_3 = AE_1 and tonumber(AE_1.Cost)
                if AD >= (AF_3 or math.huge) then
                    pcall(function()
                        BuyShopItem:FireServer("BuyCookTool", AN)
                    end)
                    return
                end
            end
        end
    end
    if Toggles.AutoBuyTables and Toggles.AutoBuyTables.Value then
        for k, v in td do
            local AT = v
            local AE_4 = tG[AT]
            local AF_6 = AE_4 and AE_4.DisplayName or AT
            local AG_4 = sR(Options.BuyTableFilter, AF_6) and not sB("ServingTable", AT)
            if AG_4 then
                local AF_7 = AE_4 and tonumber(AE_4.Cost)
                if AD >= (AF_7 or math.huge) then
                    pcall(function()
                        BuyShopItem:FireServer("BuyTable", AT)
                    end)
                    return
                end
            end
        end
    end
end
task.spawn(worker)
t5 = function()
    local BO
    local BM
    local BV
    local BP
    local BN
    local BU
    BM = nil
    BN = nil
    BO = nil
    BP = nil
    BU = nil
    BV = nil
    local BQ, BR, Label2, Label3, BW, Label
    BP = function(j_, j0)
        return string.format('<font color="%s">%s</font>', j0, j_)
    end
    BR = function(j2, j3, j4)
        return string.format("<b>%s</b> %s %s", j2, BP("-", "#5a6070"), BP(j3, j4))
    end
    BO = "#7fd47f"
    BU = "#e05a5a"
    local BY = "#8b93a3"
    BM = "#e8a34d"
    local function B_()
        local A0 = hookfunction ~= nil
        local A1 = hookmetamethod ~= nil
        local A2 = getrawmetatable ~= nil
        local A3 = setrawmetatable ~= nil
        local A4 = getgc ~= nil
        local A5 = getgenv ~= nil
        local A6 = getreg ~= nil
        local A7 = getconnections ~= nil
        local A8 = firesignal ~= nil
        local A9 = getcallbackvalue ~= nil
        local Ba = setclipboard ~= nil
        local Bb = getcustomasset ~= nil
        local Bc = getnamecallmethod ~= nil
        local Bd = isexecutorclosure ~= nil
        local Be = fireproximityprompt ~= nil
        local Bf = firetouchinterest ~= nil
        local Bg = WebSocket ~= nil
        local Bh = readfile ~= nil
        local Bi = writefile ~= nil
        local Bk = (request or http_request) ~= nil
        local Bm = (debug and debug.getupvalues) ~= nil
        local Bo = (debug and debug.setupvalue) ~= nil
        local Bp = 0
        local Bq = { A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, Ba, Bb, Bc, Bd, Be, Bf, Bg, Bh, Bi, Bk, Bm, Bo }
        for i, v in ipairs(Bq) do
            if v then
                Bp += 1
            end
        end
        local A0_1 = Bp / #Bq
        if A0_1 >= 0.9 then
            return BP("Full Support", BO)
        elseif A0_1 >= 0.6 then
            return BP("Half Support", BM)
        else
            return BP("Low Support", BU)
        end
    end
    BV = "Unknown"
    pcall(function()
        local Bz_1
        local By_1
        if identifyexecutor then
            Bz_1, By_1 = identifyexecutor()
            local BA = Bz_1 ~= ""
            local BB = type(Bz_1) == "string" and BA
            if BB then
                local BA_1 = type(By_1) == "string" and By_1 ~= "" and Bz_1 .. " " .. By_1
                BV = BA_1 or Bz_1
            end
        end
    end)
    local B0 = B_()
    BN = os.clock()
    BQ = function()
        local BG = math.floor(os.clock() - BN)
        if BG < 60 then
            return BG .. "s"
        elseif BG < 3600 then
            return string.format("%dm %ds", math.floor((BG) / (60)), BG % 60)
        else
            return string.format("%dh %dm", math.floor((BG) / (3600)), math.floor((BG % 3600) / (60)))
        end
    end
    local B__1 = su.Info:AddLeftGroupbox("User", "circle-user")
    B__1:AddPlayerInfo("InfoUserCard", { Player = s5, Title = "User", HeaderIcon = "user", Collapsible = false })
    B__1:AddLabel(BR("User", s5.DisplayName .. " @" .. s5.Name, BO), true)
    B__1:AddLabel(BR("UserId", tostring(s5.UserId), "#6ec1ff"), true)
    B__1:AddLabel(BR("Executor", BV .. "  " .. B0, BO), true)
    B__1:AddDivider()
    Label3 = B__1:AddLabel(BR("Session", BQ(), BM), true)
    B__1:AddDivider()
    B__1:AddButton({
        Text = "Copy Username",
        Func = function()
            s7(s5.Name, "Copied username")
        end
    })
    B__1:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            s7("https://www.roblox.com/users/" .. tostring(s5.UserId) .. "/profile", "Copied profile link")
        end
    })
    local B__2 = su.Info:AddRightGroupbox("Session", "signal")
    B__2:AddDivider("Server")
    B__2:AddLabel(BR("Game", sL, "#6ec1ff"), true)
    Label2 = B__2:AddLabel(BR("Players", "0/0", BO), true)
    BW = tostring(game.JobId)
    local BZ = #BW > 18 and string.sub(BW, 1, 18) .. "..."
    local B0_1 = BZ or BW
    B__2:AddLabel(BR("Job", B0_1, BY), true)
    Label = B__2:AddLabel(BR("Ping", "0 ms", BM), true)
    B__2:AddDivider()
    B__2:AddButton({
        Text = "Rejoin Server",
        Func = function()
            tb:Teleport(game.PlaceId, s5)
        end
    })
    B__2:AddButton({
        Text = "Copy Job ID",
        Func = function()
            s7(BW, "Copied Job ID")
        end
    })
    task.spawn(function()
        local BJ_1
        local BI_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(BR("Session", BQ(), BM))
            Label2:SetText(BR("Players", #si:GetPlayers() .. "/" .. tostring(si.MaxPlayers), BO))
            BI_1, BJ_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local BI_2 = BI_1 and BJ_1 .. " ms" or "n/a"
            Label:SetText(BR("Ping", BI_2, BM))
        end
    end)
    local SocialsGroup = su.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = sZ })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            s7(sC, "Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            s7(sw, "Copied website link")
        end
    })
end
En_5 = function()
    local connection
    local MovementGroup = su.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = su.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    tl(tL.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = s5.Character
            if Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    local B2_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if B2_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end))
    tl(tE.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local Ca_1 = s0()
            if Ca_1 then
                Ca_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end))
    local lE = Workspace.CurrentCamera
    tl(tL.RenderStepped:Connect(function(lF)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local Cf_1 = s0()
            if Cf_1 then
                Cf_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local Cf_3 = s8()
            local Cg = s0()
            if Cf_3 and Cg then
                Cg.PlatformStand = true
                local Cg_1 = Vector3.zero
                local Ch_1 = Workspace.CurrentCamera
                local Cl = if Ch_1 then 1 else 0
                local Cj = 1047 * Cl + 3950 * (1 - Cl)
                local Ck = 2591 * Cl + 2871 * (1 - Cl)
                if not ((Cj * 247 + Ck * 3825 + Cj * Ck) % 16777213 == 12881961) then
                    Ch_1 = lE
                end
                lE = Ch_1
                if tE:IsKeyDown(Enum.KeyCode.W) then
                    Cg_1 += lE.CFrame.LookVector
                end
                if tE:IsKeyDown(Enum.KeyCode.S) then
                    Cg_1 -= lE.CFrame.LookVector
                end
                if tE:IsKeyDown(Enum.KeyCode.A) then
                    Cg_1 -= lE.CFrame.RightVector
                end
                if tE:IsKeyDown(Enum.KeyCode.D) then
                    Cg_1 += lE.CFrame.RightVector
                end
                if tE:IsKeyDown(Enum.KeyCode.Space) then
                    Cg_1 += Vector3.new(0, 1, 0)
                end
                if tE:IsKeyDown(Enum.KeyCode.LeftControl) then
                    Cg_1 -= Vector3.new(0, 1, 0)
                end
                Cf_3.AssemblyLinearVelocity = Vector3.zero
                if Cg_1.Magnitude > 0 then
                    Cf_3.CFrame = Cf_3.CFrame + Cg_1.Unit * Options.FlySpeed.Value * lF
                end
            end
        end
    end))
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local Cp = s0()
            if Cp then
                Cp.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local Cr = s0()
            if Cr then
                Cr.WalkSpeed = 16
            end
        end
    end)
    local function l1(l2)
        if not l2:IsA("ProximityPrompt") then
            return
        end
        l2.HoldDuration = 0
        l2.MaxActivationDistance = 50
        l2.RequiresLineOfSight = false
    end
    connection = nil
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in ipairs(Workspace:GetDescendants()) do
                pcall(l1, descendant)
            end
            connection = Workspace.DescendantAdded:Connect(function(ma)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(l1, ma)
                end
            end)
            tl(connection)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    Library:OnUnload(function()
        if connection then
            connection:Disconnect()
        end
    end)
end
local function t6()
    local MenuGroup = su.Settings:AddLeftGroupbox("Menu", "logs")
    local mi = 0
    local mj = tick()
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = MenuGroup:AddLabel("AFK triggers: 0")
    local function ml()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then
            return
        end
        tx:CaptureController()
        tx:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        mi += 1
        mj = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. mi)
        end)
    end
    local connection2 = s5.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(ml)
        end
    end)
    tl(connection2)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local CG = Toggles.AntiAfk.Value and tick() - mj >= 60
            if CG then
                pcall(ml)
            end
        end
    end)
    MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
    MenuGroup:AddToggle("Disable3D", { Text = "Disable 3D Rendering", Default = false })
    MenuGroup:AddToggle("FpsBoost", { Text = "FPS Boost", Default = false })
    MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    local function mJ(mK)
        pcall(function()
            th:SetGameplayPausedNotificationEnabled(not mK)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = tn:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not mK
            end
        end)
        if not mK then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(s5, "GameplayPaused", false)
            else
                s5.GameplayPaused = false
            end
        end)
    end
    Toggles.AntiGameplayPause:OnChanged(function()
        mJ(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                mJ(true)
            end
        end
    end)
    local m0 = false
    local function m1()
        local JobId, PlaceId
        if m0 then
            return
        end
        m0 = true
        PlaceId, JobId = game.PlaceId, game.JobId
        local CS = pcall(function()
            tb:TeleportToPlaceInstance(PlaceId, JobId, s5)
        end)
        if not CS then
            pcall(function()
                tb:Teleport(PlaceId, s5)
            end)
        end
    end
    task.spawn(function()
        local RobloxPromptGui = tn:WaitForChild("RobloxPromptGui", 30)
        local CX = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
        if not CX then
            return
        end
        tl(CX.ChildAdded:Connect(function(nk)
            if Library.Unloaded then
                return
            end
            if Toggles.AutoReconnect.Value and nk.Name == "ErrorPrompt" then
                m1()
            end
        end))
    end)
    tl(tb.TeleportInitFailed:Connect(function()
        if Toggles.AutoReconnect.Value then
            m0 = false
            m1()
        end
    end))
    Toggles.Disable3D:OnChanged(function()
        pcall(function()
            tL:Set3dRenderingEnabled(not Toggles.Disable3D.Value)
        end)
    end)
    local nA = {
        ParticleEmitter = true,
        Trail = true,
        Smoke = true,
        Fire = true,
        Sparkles = true,
        Explosion = true,
        Beam = true
    }
    local function nB(nC)
        if nA[nC.ClassName] then
            pcall(function()
                nC.Enabled = false
            end)
        end
    end
    local connection
    Toggles.FpsBoost:OnChanged(function()
        if Toggles.FpsBoost.Value then
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            end)
            pcall(function()
                s6.GlobalShadows = false
            end)
            pcall(function()
                s6.FogEnd = 9000000000
            end)
            for i, descendant in ipairs(Workspace:GetDescendants()) do
                pcall(nB, descendant)
            end
            connection = Workspace.DescendantAdded:Connect(function(nR)
                if Toggles.FpsBoost.Value then
                    pcall(nB, nR)
                end
            end)
            tl(connection)
        else
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            end)
            pcall(function()
                s6.GlobalShadows = true
            end)
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end)
    local ScriptGroup = su.Settings:AddLeftGroupbox("Script", "terminal")
    ScriptGroup:AddButton({
        Text = "Unload Script",
        Func = function()
            Library:Unload()
        end
    })
    Library:OnUnload(function()
        if connection2 then
            connection2:Disconnect()
        end
        mJ(false)
        pcall(function()
            tL:Set3dRenderingEnabled(true)
        end)
        if connection then
            connection:Disconnect()
        end
        for k, v in tR do
            local Dr = v
            pcall(function()
                Dr:Disconnect()
            end)
        end
        table.clear(tR)
        local Dh = s8()
        if Dh then
            Dh.Anchored = false
        end
        local Dh_1 = s0()
        if Dh_1 then
            Dh_1.PlatformStand = false
            Dh_1.WalkSpeed = 16
        end
        if getgenv then
            getgenv().__TempoHatchAndFryLib = nil
        end
    end)
end
local function uf(od)
    local function oe(of, og)
        local Dt_1 = (of == "Toggle" and Toggles or Options)[og]
        local Ds_2 = type(Dt_1) == "table" and Dt_1.Type == of
        return Ds_2 and Dt_1 or nil
    end
    local function op(oq, ot)
        local Type = ot.Type
        if Type == "Toggle" then
            return { idx = oq, type = "Toggle", value = ot.Value == true }
        elseif Type == "Slider" then
            return { idx = oq, type = "Slider", value = tostring(ot.Value) }
        elseif Type == "Dropdown" then
            return { idx = oq, type = "Dropdown", multi = ot.Multi == true, value = ot.Value }
        elseif Type == "Input" then
            local Dx = ot.Value
            local DB = if Dx then 1 else 0
            local Dz = 499 * DB + 3690 * (1 - DB)
            local DA = 772 * DB + 3096 * (1 - DB)
            if not ((Dz * 28 + DA * 2239 + Dz * DA) % 16777213 == 2127708) then
                Dx = ""
            end
            return { idx = oq, type = "Input", text = tostring(Dx) }
        elseif Type == "ColorPicker" then
            return { idx = oq, type = "ColorPicker", value = ot.Value:ToHex(), transparency = ot.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = oq,
                type = "KeyPicker",
                mode = ot.Mode,
                key = ot.Value,
                modifiers = ot.Modifiers,
                toggled = ot.Toggled
            }
        else
            return nil
        end
    end
    local function ov()
        local DD = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local DE = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if DE then
                    local DE_1 = op(k, v)
                    if DE_1 then
                        DD[#DD + 1] = DE_1
                    end
                end
            end
        end
        table.sort(DD, function(oF, oG)
            if oF.type ~= oG.type then
                return oF.type < oG.type
            end
            return oF.idx < oG.idx
        end)
        return { objects = DD }
    end
    local function oH(oI)
        local DX
        DX = nil
        local DY = type(oI) ~= "table"
        local D1 = if DY then 1 else 0
        local D_ = 3947 * D1 + 2603 * (1 - D1)
        local D0 = 2 * D1 + 3798 * (1 - D1)
        if not ((D_ * 1171 + D0 * 2882 + D_ * D0) % 16777213 == 4635595) then
            DY = type(oI.idx) ~= "string"
        end
        if not DY then
            DY = type(oI.type) ~= "string"
        end
        if not DY then
            DY = SaveManager.Ignore[oI.idx]
        end
        if DY then
            return false
        end
        DX = oe(oI.type, oI.idx)
        if not DX then
            return false
        end
        local DY_1 = pcall(function()
            if oI.type == "Input" then
                if type(oI.text) ~= "string" then
                    return
                end
                DX:SetValue(oI.text)
            elseif oI.type == "ColorPicker" then
                DX:SetValueRGB(Color3.fromHex(oI.value), oI.transparency)
            elseif oI.type == "KeyPicker" then
                DX:SetValue({ oI.key, oI.mode, oI.modifiers })
                if oI.mode == "Toggle" and oI.toggled ~= nil then
                    DX.Toggled = oI.toggled
                    DX:Update()
                end
            else
                DX:SetValue(oI.value)
            end
        end)
        return DY_1
    end
    od:AddDivider()
    od:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    od:AddButton("Export Config to Clipboard", function()
        local D3_1
        local D2_1
        D2_1, D3_1 = pcall(ts.JSONEncode, ts, ov())
        if not D2_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local D2_2 = setclipboard or toclipboard
        local D2_3 = type(D2_2) ~= "function" or not pcall(D2_2, D3_1)
        if D2_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    od:AddButton("Import Config from Clipboard Text", function()
        local D8_1
        local D6 = Options.SaveManager_ImportSource.Value or ""
        local D6_1
        local D7 = tostring(D6):match("^%s*(.-)%s*$")
        if D7 == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        D6_1, D8_1 = pcall(ts.JSONDecode, ts, D7)
        local D7_1 = not D6_1 or type(D8_1) ~= "table"
        local Ec = if D7_1 then 1 else 0
        local Ea = 2867 * Ec + 932 * (1 - Ec)
        local Eb = 806 * Ec + 2558 * (1 - Ec)
        if not ((Ea * 1216 + Eb * 811 + Ea * Eb) % 16777213 == 6450740) then
            D7_1 = type(D8_1.objects) ~= "table"
        end
        if D7_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local D6_2 = 0
        for i, v in ipairs(D8_1.objects) do
            if oH(v) then
                D6_2 += 1
            end
        end
        if D6_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local D8_2 = D6_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(D6_2, D8_2), 6)
    end)
end
t5()
En_5()
t6()
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(su.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/HatchAndFry")
t4 = SaveManager:BuildConfigSection(su.Settings)
uf(t4)
SaveManager:LoadAutoloadConfig()
if Toggles.HideUiOnStart and Toggles.HideUiOnStart.Value then
    Library:Toggle(false)
end
end)(...)

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
getgenv().TempoHoodSubtitle = "+1 STAND POWER EVOLUTION"
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
local sF_2, sF_3
local Library
local lv
local UserInputService
local lc
local lU
local Rebirth
local mi
local l_
local k_
local ClaimPowerGain
local lo
local Rebirth2
local StopTrainingDummy
local lN
local lu
local mb
local lb
local lT
local lA
local mh
local lh
local lZ
local lG
local ln
local HttpService
local lM
local lS
local lz
local Auras
local lY
local lF
local Workspace
local k3
local lL
local ls
local Partners
local k9
local lR
local mf
local lf
local connection2
local CurrentCamera
local ll
local k2
local SaveManager
local lr
local l8
local k8
local lQ
local lx
local connection
local Label
local lD
local Trails
local l1
local GetAllData
local lq
local VirtualUser
local k7
local lP
local ld
local lV
local Options
local mj
local lj
local l0
local k0
local Toggles
local k6
local function worker2()
    while not Library.Unloaded do
        if lU("AutoClick") then
            k3()
            task.wait(0.35)
        else
            task.wait(0.2)
        end
    end
end
local function fn77()
    if not Toggles.WalkSpeedEnabled.Value then
        local r2 = ln()
        if r2 then
            r2.WalkSpeed = 16
        end
    end
end
local function fn101(ab, ac, ad)
    return string.format("<b>%s</b> %s %s", ab, lc("-", "#5a6070"), lc(ac, ad))
end
local function fn106(aC)
    local Character = lZ.Character
    if not Character then
        return
    end
    if Character.PrimaryPart then
        Character:PivotTo(aC)
    else
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = aC
        end
    end
end
local function fn119()
    local n1_1
    local n0 = lD("WinPlateChoice")
    if n0 == "Win" or n0 == "2xWins" or n0 == "10xWins" then
        n1_1 = n0
    else
        n1_1 = "Win"
    end
    local n0_1 = lr(n1_1)
    if #n0_1 == 0 then
        return nil
    end
    table.sort(n0_1, function(bC, bD)
        return bC.Value > bD.Value
    end)
    return n0_1[1]
end
local function fn125(ak)
    local m_ = Toggles[ak]
    return m_ ~= nil and m_.Value == true
end
local function fn135(d8, d9)
    local pX_1
    local pW_1
    if type(Partners.GetWinCost) == "function" then
        pW_1, pX_1 = pcall(Partners.GetWinCost, d8, d9)
        if pW_1 then
            return tonumber(pX_1)
        end
        return nil
    end
    return nil
end
local function fn169()
    local Character = lZ.Character
    local m6 = Character and Character:FindFirstChildOfClass("Humanoid")
    return m6
end
local function fn171(aJ)
    local ni_1
    local nh = not aJ
    local nh_1
    if nh ~= false then
        nh = l0
    end
    if nh then
        nh = os.clock() - lY < 0.75
    end
    if nh then
        return l0
    end
    nh_1, ni_1 = pcall(function()
        return GetAllData:InvokeServer()
    end)
    local nj = nh_1 and type(ni_1) == "table"
    if nj then
        l0 = ni_1
        lY = os.clock()
        return ni_1
    end
    return l0
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = lZ.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local r5_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if r5_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local sp = tick() - lu
            local sq = tick() - lq
            if sp >= 300 and sq >= 60 then
                pcall(k7)
            else
                if sp < 300 and sq >= 300 then
                    pcall(k7)
                end
            end
        end
    end
end
local function onInputChanged(g_)
    local UserInputType = g_.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        lu = tick()
    end
end
local function onRenderStepped(hz)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local sf_1 = ln()
        if sf_1 then
            sf_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local sf_3 = k8()
        local sg = ln()
        if sf_3 and sg then
            sg.PlatformStand = true
            local sg_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                sg_1 = sg_1 + CurrentCamera.CFrame.LookVector
            end
            local sl = if UserInputService:IsKeyDown(Enum.KeyCode.S) then 1 else 0
            if sl == 1 then
                sg_1 = sg_1 - CurrentCamera.CFrame.LookVector
            end
            local sl_1 = if UserInputService:IsKeyDown(Enum.KeyCode.A) then 1 else 0
            if sl_1 == 1 then
                sg_1 = sg_1 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                sg_1 = sg_1 + CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                sg_1 = sg_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                sg_1 = sg_1 - Vector3.new(0, 1, 0)
            end
            sf_3.Velocity = Vector3.zero
            if sg_1.Magnitude > 0 then
                sf_3.CFrame = sf_3.CFrame + sg_1.Unit * Options.FlySpeed.Value * hz
            end
        end
    end
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local sd_1 = ln()
        if sd_1 then
            sd_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn253(aY)
    for i, descendant in ipairs(aY:GetDescendants()) do
        if descendant:IsA("TextLabel") then
            local Text = descendant.Text
            local nq = type(Text) == "string" and Text ~= "" and not string.find(Text, "Double", 1, true)
            if nq then
                local nq_1 = lo(Text)
                if nq_1 then
                    return Text, nq_1
                end
            end
        end
    end
    return nil, nil
end
local function fn265()
    pcall(function()
        ClaimPowerGain:FireServer()
    end)
end
local function worker4()
    while not Library.Unloaded do
        if lU("AutoTrain") then
            ld()
            task.wait(1.5)
        else
            if lf then
                lv()
            end
            task.wait(0.35)
        end
    end
end
local function worker3()
    while not Library.Unloaded do
        if lU("AutoWinPlates") then
            ls()
        else
            task.wait(0.35)
        end
    end
end
local function fn329(fY, fZ)
    local qP = fY == "Toggle" and Toggles
    local qU = if qP then 1 else 0
    local qS = 2664 * qU + 1310 * (1 - qU)
    local qT = 919 * qU + 1901 * (1 - qU)
    if not ((qS * 2350 + qT * 3853 + qS * qT) % 16777213 == 12249523) then
        qP = Options
    end
    local qP_1 = qP[fZ]
    local qO_2 = type(qP_1) == "table" and qP_1.Type == fY
    return qO_2 and qP_1 or nil
end
local function fn332()
    local n6 = lQ()
    if not n6 then
        return
    end
    local n7 = k8()
    if not n7 then
        return
    end
    mh(CFrame.new(0, 200, 0))
    task.wait(0.35)
    mh(n6.Part.CFrame + Vector3.new(0, 4, 0))
    task.wait(1.1)
end
local function onImportConfigFromClipboardTex()
    local rr_1
    local rp = Options.SaveManager_ImportSource.Value or ""
    local rp_1
    local rq = tostring(rp):match("^%s*(.-)%s*$")
    if rq == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    rp_1, rr_1 = pcall(HttpService.JSONDecode, HttpService, rq)
    local rq_1 = not rp_1 or type(rr_1) ~= "table" or type(rr_1.objects) ~= "table"
    if rq_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local rp_2 = 0
    for i, v in ipairs(rr_1.objects) do
        if lG(v) then
            rp_2 += 1
        end
    end
    if rp_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local rr_2 = rp_2 == 1 and ""
    local rE = if rr_2 then 1 else 0
    local rC = 800 * rE + 2094 * (1 - rE)
    local rD = 312 * rE + 428 * (1 - rE)
    if not ((rC * 179 + rD * 2971 + rC * rD) % 16777213 == 1319752) then
        rr_2 = "s"
    end
    Library:Notify(("Imported %d setting%s"):format(rp_2, rr_2), 6)
end
local function fn373(bW, bX)
    local oe = bW and bW.Trails
    local oe_1 = type(oe) == "table" and oe[bX] == true
    return oe_1
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            lT(true)
        end
    end
end
local function fn411(c2)
    local pd = -1
    local Name
    for i, v in ipairs(Auras) do
        local pf = type(v) == "table" and type(v.Name) == "string" and lz(c2, v.Name)
        if pf then
            local pf_1 = tonumber(v.Multiplier) or 0
            if pf_1 > pd then
                pd = pf_1
                Name = v.Name
            end
        end
    end
    return Name
end
local function fn419(f5, f6)
    local Type = f6.Type
    if Type == "Toggle" then
        return { idx = f5, type = "Toggle", value = f6.Value == true }
    elseif Type == "Slider" then
        return { idx = f5, type = "Slider", value = tostring(f6.Value) }
    elseif Type == "Dropdown" then
        return { idx = f5, type = "Dropdown", multi = f6.Multi == true, value = f6.Value }
    elseif Type == "Input" then
        local qW = f6.Value or ""
        return { idx = f5, type = "Input", text = tostring(qW) }
    elseif Type == "ColorPicker" then
        return { idx = f5, type = "ColorPicker", value = f6.Value:ToHex(), transparency = f6.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = f5,
            type = "KeyPicker",
            mode = f6.Mode,
            key = f6.Value,
            modifiers = f6.Modifiers,
            toggled = f6.Toggled
        }
    else
        return nil
    end
end
local function worker5()
    while not Library.Unloaded do
        if lU("AutoRebirth") then
            mj()
        end
        task.wait(1)
    end
end
local function fn425()
    local nB = {}
    local Wins = Workspace:FindFirstChild("Wins")
    if Wins then
        nB[1] = Wins
    end
    local World2 = Workspace:FindFirstChild("World2")
    local nD = World2 and World2:FindFirstChild("Wins")
    if nD then
        nB[#nB + 1] = nD
    end
    return nB
end
local function fn431()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    lq = tick()
end
local function onUnload()
    Library:Unload()
end
local function fn467()
    local qE_1
    local qD_1
    if identifyexecutor then
        qE_1, qD_1 = identifyexecutor()
        local qF = qE_1 ~= ""
        local qG = type(qE_1) == "string" and qF
        if qG then
            local qF_1 = type(qD_1) == "string" and qD_1 ~= "" and qE_1 .. " " .. qD_1
            mi = qF_1 or qE_1
        end
    end
end
local function fn472()
    local p8 = {}
    local TrainingDummies = Workspace:FindFirstChild("TrainingDummies")
    if TrainingDummies then
        p8[1] = TrainingDummies
    end
    local World2 = Workspace:FindFirstChild("World2")
    local qa = World2 and World2:FindFirstChild("TrainingDummies")
    if qa then
        p8[#p8 + 1] = qa
    end
    return p8
end
local function onCopyJoinScript_JobID()
    local fz = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, lP)
    lA(fz, "Copied join script to clipboard")
end
local function fn531()
    if not Toggles.AutoTrain.Value then
        lv()
    end
end
local function fn537(fi)
    local DiscordGroup = fi:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = ll })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = ll })
end
local function onExportConfigToClipboard()
    local rm_1
    local rl_1
    rl_1, rm_1 = pcall(HttpService.JSONEncode, HttpService, k0())
    if not rl_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local rl_2 = setclipboard or toclipboard
    local rl_3 = type(rl_2) ~= "function" or not pcall(rl_2, rm_1)
    if rl_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function fn564(ap)
    local m2 = Options[ap]
    return m2 and m2.Value or nil
end
local function fn566()
    local n9 = lV(true)
    if not n9 then
        return
    end
    local oc = Rebirth2.Levels[(n9.Rebirth or 0) + 1]
    if not oc then
        return
    end
    if (n9.Level or 1) < (oc.Requirement or 0) then
        return
    end
    pcall(function()
        Rebirth:InvokeServer()
    end)
    l0 = nil
end
local function onInputBegan()
    lu = tick()
end
local function fn610(b1, b2)
    local oh = b1 and b1.Auras
    local oh_1 = type(oh) == "table" and oh[b2] == true
    return oh_1
end
local function fn617(R, S)
    if setclipboard then
        setclipboard(R)
    elseif toclipboard then
        toclipboard(R)
    end
    Library:Notify(S)
end
local function fn636()
    lv()
    lT(false)
    if connection then
        connection:Disconnect()
    end
    if connection2 then
        connection2:Disconnect()
    end
    select("#", "Unloaded!")
end
local function fn672(aT)
    local nm_1
    local nl_1
    if type(aT) ~= "string" then
        return nil
    end
    nl_1, nm_1 = string.match(aT, "^([%d%.]+)%s*([KMB]?)%s*Wins?$")
    if not nl_1 then
        return nil
    end
    local nn = tonumber(nl_1)
    if not nn then
        return nil
    end
    if nm_1 == "K" then
        nn = nn * 1000
    elseif nm_1 == "M" then
        nn = nn * 1000000
    elseif nm_1 == "B" then
        nn = nn * 1000000000
    end
    return nn
end
local function onRscripts()
    lA(lN, "Copied Rscripts profile to clipboard")
end
local function fn717()
    if not lf then
        return
    end
    lf = false
    lb = nil
    pcall(function()
        StopTrainingDummy:FireServer()
    end)
end
local function fn727(a5)
    local Baseplate = a5:FindFirstChild("Baseplate")
    local nz = Baseplate and Baseplate:IsA("BasePart")
    if nz then
        return Baseplate
    end
    return a5:FindFirstChildWhichIsA("BasePart", true)
end
local function fn738(eE)
    local qc = -1
    local qd
    for i, v in ipairs(k6()) do
        for i, descendant in ipairs(v:GetDescendants()) do
            local qe = descendant:IsA("Model") and descendant.Name == "Training Dummy" and descendant:GetAttribute("Gamepass") ~= true
            if qe then
                local attr = descendant:GetAttribute("Rebirth")
                local qf = typeof(attr) == "number" and attr <= eE and attr >= qc
                if qf then
                    qc = attr
                    qd = descendant
                end
            end
        end
    end
    return qd
end
local function fn741(cT)
    local o_ = -1
    local Name
    for i, v in ipairs(Trails) do
        local o1 = type(v) == "table" and type(v.Name) == "string" and lS(cT, v.Name)
        if o1 then
            local o1_1 = tonumber(v.Multiplier) or 0
            if o1_1 > o_ then
                o_ = o1_1
                Name = v.Name
            end
        end
    end
    return Name
end
local function fn742()
    if not Toggles.Fly.Value then
        local r0 = ln()
        if r0 then
            r0.PlatformStand = false
        end
    end
end
local function fn746(bg)
    local nK_2
    local nI = {}
    for i, v in ipairs(lM()) do
        for i, child in ipairs(v:GetChildren()) do
            local nJ = (child:IsA("Model"))
            local nJ_2
            if nJ then
                nJ = not bg or child.Name == bg
            end
            if nJ then
                if child.Name == "Win" or child.Name == "2xWins" or child.Name == "10xWins" then
                    nK_2, nJ_2 = k2(child)
                    local nL = l1(child)
                    if nK_2 and nJ_2 and nL then
                        nI[#nI + 1] = { Model = child, Part = nL, Name = child.Name, Label = nK_2, Value = nJ_2 }
                    end
                end
            end
        end
    end
    return nI
end
local function worker6()
    while not Library.Unloaded do
        if lU("AutoBuyTrails") then
            lL()
        end
        if lU("AutoBuyAura") then
            mf()
        end
        if lU("AutoEquipTrail") then
            lF()
        end
        if lU("AutoEquipAura") then
            k9()
        end
        if lU("AutoBuyStands") then
            mb()
        end
        if lU("AutoEquipStand") then
            lj()
        end
        if lU("AutoRollLuckyBlocks") then
            l8()
        end
        task.wait(1)
    end
end
local function fn770()
    local Character = lZ.Character
    local m9 = Character and Character:FindFirstChild("HumanoidRootPart")
    return m9
end
local function fn799()
    lA(lR, "Copied Discord invite to clipboard")
end
local function fn804()
    local qZ = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local q_ = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if q_ then
                local q__1 = lh(k, v)
                if q__1 then
                    qZ[#qZ + 1] = q__1
                end
            end
        end
    end
    table.sort(qZ, function(gj, gk)
        if gj.type ~= gk.type then
            return gj.type < gk.type
        end
        return gj.idx < gk.idx
    end)
    return { objects = qZ }
end
local function fn817(Y, Z)
    return string.format('<font color="%s">%s</font>', Z, Y)
end
local function fn831()
    lT(Toggles.AntiGameplayPause.Value)
end
local function worker()
    local qM_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local qL = math.floor(os.clock() - lx)
        if qL < 60 then
            qM_1 = qL .. "s"
        elseif qL < 3600 then
            qM_1 = string.format("%dm %ds", math.floor((qL) / (60)), qL % 60)
        else
            qM_1 = string.format("%dh %dm", math.floor((qL) / (3600)), math.floor((qL % 3600) / (60)))
        end
        Label:SetText(k_("Session time", qM_1, l_))
    end
end
k_ = nil
k0 = nil
GetAllData = nil
k2 = nil
k3 = nil
StopTrainingDummy = nil
k6 = nil
k7 = nil
k8 = nil
k9 = nil
lb = nil
lc = nil
ld = nil
lf = nil
lh = nil
lj = nil
ll = nil
ln = nil
lo = nil
lq = nil
lr = nil
ls = nil
lu = nil
lv = nil
lx = nil
lz = nil
lA = nil
Rebirth = nil
Options = nil
lD = nil
CurrentCamera = nil
lF = nil
lG = nil
ClaimPowerGain = nil
Toggles = nil
SaveManager = nil
lL = nil
local CloseLuckyBlockGui, k4, StartTrainingDummy, BuyLuckyBlockWithWins, lg, EquipStand, PurchaseStand, lm, EquipAura, EquipTrail, PurchaseAura, PurchaseTrail, lJ
lM = nil
lN = nil
Library = nil
lP = nil
lQ = nil
lR = nil
lS = nil
lT = nil
lU = nil
lV = nil
Label = nil
connection2 = nil
lY = nil
lZ = nil
l_ = nil
l0 = nil
l1 = nil
Workspace = nil
HttpService = nil
Rebirth2 = nil
VirtualUser = nil
l8 = nil
Partners = nil
mb = nil
UserInputService = nil
connection = nil
mf = nil
Auras = nil
mh = nil
mi = nil
mj = nil
Trails = nil
local l2, l6, ma, Stands, mx
l2 = nil
l6 = nil
ma = nil
Stands = nil
local mA, FarmGroup
UserInputService, VirtualUser, HttpService, Workspace, lZ, lR, lN, ClaimPowerGain, Rebirth, PurchaseTrail, PurchaseAura, EquipTrail, EquipAura, PurchaseStand, EquipStand, BuyLuckyBlockWithWins, StartTrainingDummy, StopTrainingDummy, GetAllData, CloseLuckyBlockGui, Trails, Auras, Stands, Partners, Rebirth2, Library, SaveManager, Toggles, Options, l_, l0, lY, lf, lb, lA, ll, lc, k_, lU, lD, ln, k8, mh, lV, lo, k2, l1, lM, lr, lQ, ls, k3, mj, lS, lz, lg, lL, mf, lm, ma, lF, k9, l2, lj, mb, k4, l8, k6, l6, lv, ld = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local mr = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
if (not lm and not EquipAura and (not lm and lF) and (not lm and false and (EquipAura or lm)) or ((lF or lF) and (EquipAura and EquipAura) or (lM or not k3) and (not k3 or not lM))) and not (not lm and not EquipAura and (not lm and lF) and (not lm and false and (EquipAura or lm)) or ((lF or lF) and (EquipAura and EquipAura) or (lM or not k3) and (not k3 or not lM))) then
    k6 = game:GetService("HttpService")
else
    HttpService = game:GetService("HttpService")
end
Workspace = game:GetService("Workspace")
lZ = Players.LocalPlayer
local mv = "+1 Stand Power Evolution"
lR = "https://discord.gg/K7Qxnxkk46"
lN = "https://discord.gg/K7Qxnxkk46"
local sF_5 = mr:WaitForChild("RemotesFolder")
local sF_8 = mr:WaitForChild("Configs")
ClaimPowerGain = sF_5:WaitForChild("ClaimPowerGain")
Rebirth = sF_5:WaitForChild("Rebirth")
PurchaseTrail = sF_5:WaitForChild("PurchaseTrail")
PurchaseAura = sF_5:WaitForChild("PurchaseAura")
EquipTrail = sF_5:WaitForChild("EquipTrail")
EquipAura = sF_5:WaitForChild("EquipAura")
PurchaseStand = sF_5:WaitForChild("PurchaseStand")
EquipStand = sF_5:WaitForChild("EquipStand")
BuyLuckyBlockWithWins = sF_5:WaitForChild("BuyLuckyBlockWithWins")
StartTrainingDummy = sF_5:WaitForChild("StartTrainingDummy")
StopTrainingDummy = sF_5:WaitForChild("StopTrainingDummy")
GetAllData = sF_5:WaitForChild("GetAllData")
CloseLuckyBlockGui = sF_5:FindFirstChild("CloseLuckyBlockGui")
Trails = require(sF_8:WaitForChild("Trails"))
Auras = require(sF_8:WaitForChild("Auras"))
Stands = require(sF_8:WaitForChild("Stands"))
Partners = require(sF_8:WaitForChild("Partners"))
Rebirth2 = require(sF_8:WaitForChild("Rebirth"))
local mz = { "Best", "Win", "2xWins", "10xWins" }
local my = { "Normal", "Exotic", "Ancient" }
local mw = { "1", "3", "6" }
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
lA = fn617
ll = fn799
lc = fn817
k_ = fn101
local mB = "#7fd47f"
if (lm or not lm or Workspace and k_ or (not lv or Workspace) and (not lm or lm) or (not lm or k_ or (k_ or lm) or (k_ or k_ or (k_ or lv)))) and ((not lm and Workspace or lv and not k_) and (not k_ or not lv or not Workspace and not lv) and (not lv and not lm and (k_ or not lm) and ((not Workspace or not k_) and (lv or not lm)))) or not ((lm or not lm or Workspace and k_ or (not lv or Workspace) and (not lm or lm) or (not lm or k_ or (k_ or lm) or (k_ or k_ or (k_ or lv)))) and ((not lm and Workspace or lv and not k_) and (not k_ or not lv or not Workspace and not lv) and (not lv and not lm and (k_ or not lm) and ((not Workspace or not k_) and (lv or not lm))))) then
    mA = "#6ec1ff"
    l_ = "#e8a34d"
    mx = "#8b93a3"
    lU = fn125
    lD = fn564
else
    l_ = "#6ec1ff"
    lD = "#e8a34d"
    lU = "#8b93a3"
    mx = fn125
    mA = fn564
end
ln = fn169
k8 = fn770
mh = fn106
l0 = nil
lY = 0
lV = fn171
lo = fn672
if (lU and not PurchaseStand and (lf or PurchaseStand) or (lf or PurchaseStand or (not lU or not lU))) and ((not lD or not lD or not lU and not lf) and (PurchaseStand and lU or (not lD or PurchaseStand))) or not ((lU and not PurchaseStand and (lf or PurchaseStand) or (lf or PurchaseStand or (not lU or not lU))) and ((not lD or not lD or not lU and not lf) and (PurchaseStand and lU or (not lD or PurchaseStand)))) then
    k2 = fn253
else
    mj = fn253
end
l1 = fn727
lM = fn425
lr = fn746
lQ = fn119
ls = fn332
k3 = fn265
if (k9 or k8 or (not PurchaseAura or not mr)) and (not PurchaseAura and not lr or k8 and not k8) or not ((k9 or k8 or (not PurchaseAura or not mr)) and (not PurchaseAura and not lr or k8 and not k8)) then
    mj = fn566
else
    lQ = fn566
end
lS = fn373
lz = fn610
lg = function(b7, b8)
    local ol = b7 and b7.StandsPurchased
    local ol_1
    local om_1
    if type(ol) == "table" then
        for i, v in ipairs(ol) do
            if v == b8 then
                return true
            end
        end
    end
    ol_1, om_1 = pcall(function()
        return Stands.GetByIndex(b8)
    end)
    local on = not ol_1 or type(om_1) ~= "table" or typeof(om_1.Gamepass) ~= "string"
    if on then
        return false
    end
    local on_1 = b7 and b7.Gamepasses
    local ol_3 = type(on_1) == "table" and on_1[om_1.Gamepass] == true
    return ol_3
end
lL = function()
    local oD_1
    local oA = lV()
    if not oA then
        return
    end
    local oB = tonumber(oA.Wins) or 0
    local oB_3
    local oC = oB
    for i, v in ipairs(Trails) do
        local oM = v
        local oB_1 = type(oM) == "table" and type(oM.Name) == "string" and type(oM.Wins) == "number"
        if oB_1 then
            local oB_2 = not lS(oA, oM.Name) and oC >= oM.Wins
            if oB_2 then
                oB_3, oD_1 = pcall(function()
                    return PurchaseTrail:InvokeServer(oM.Name)
                end)
                if oB_3 and oD_1 == "success" then
                    oC -= oM.Wins
                    l0 = nil
                    local oB_4 = lV(true) or oA
                    oA = oB_4
                end
            end
        end
    end
end
mf = function()
    local oQ_1
    local oN = lV()
    if not oN then
        return
    end
    local oO = tonumber(oN.Wins) or 0
    local oO_3
    local oP = oO
    for i, v in ipairs(Auras) do
        local oZ = v
        local oO_1 = type(oZ) == "table" and type(oZ.Name) == "string" and type(oZ.Wins) == "number"
        if oO_1 then
            local oO_2 = not lz(oN, oZ.Name) and oP >= oZ.Wins
            if oO_2 then
                oO_3, oQ_1 = pcall(function()
                    return PurchaseAura:InvokeServer(oZ.Name)
                end)
                if oO_3 and oQ_1 == "success" then
                    oP -= oZ.Wins
                    l0 = nil
                    local oO_4 = lV(true) or oN
                    oN = oO_4
                end
            end
        end
    end
end
lm = fn741
ma = fn411
lF = function()
    local po
    local pp = lV()
    if not pp then
        return
    end
    po = lm(pp)
    if not po then
        return
    end
    if pp.EquippedTrail == po then
        return
    end
    pcall(function()
        EquipTrail:InvokeServer(po)
    end)
    l0 = nil
end
k9 = function()
    local pr
    local ps = lV()
    if not ps then
        return
    end
    pr = ma(ps)
    if not pr then
        return
    end
    if ps.EquippedAura == pr then
        return
    end
    pcall(function()
        EquipAura:InvokeServer(pr)
    end)
    l0 = nil
end
l2 = function(ds)
    local pA_1
    local pz_1
    local px = -1
    local py
    for i = 1, 40 do
        local pG = i
        pz_1, pA_1 = pcall(function()
            return Stands.GetByIndex(pG)
        end)
        local pB = not pz_1 or type(pA_1) ~= "table"
        if pB then
            break
        elseif lg(ds, pG) then
            local pz_2 = tonumber(pA_1.Power) or 0
            if pz_2 > px then
                px = pz_2
                py = pG
            end
        end
    end
    return py
end
lj = function()
    local pH
    local pI = lV()
    if not pI then
        return
    end
    pH = l2(pI)
    if not pH then
        return
    end
    if pI.StandEquipped == pH then
        return
    end
    pcall(function()
        EquipStand:InvokeServer(pH)
    end)
    l0 = nil
end
mb = function()
    local pN_1
    local pK = lV()
    if not pK then
        return
    end
    local pL = tonumber(pK.Wins) or 0
    local pL_1, pL_4
    local pM = pL
    for i = 1, 40 do
        local pV = i
        pL_1, pN_1 = pcall(function()
            return Stands.GetByIndex(pV)
        end)
        local pO = not pL_1 or type(pN_1) ~= "table"
        local pO_1
        if pO then
            break
        elseif typeof(pN_1.Gamepass) ~= "string" then
            local pL_2 = tonumber(pN_1.Wins) or 0
            local pL_3 = not lg(pK, pV) and pM >= pL_2
            if pL_3 then
                pL_4, pO_1 = pcall(function()
                    return PurchaseStand:InvokeServer(pV)
                end)
                if pL_4 and pO_1 == true then
                    pM -= pL_2
                    l0 = nil
                    local pL_5 = lV(true) or pK
                    pK = pL_5
                end
            end
        end
    end
end
k4 = fn135
l8 = function()
    local pZ, p_
    p_ = lD("LuckyBlockType")
    local p0 = tonumber(lD("LuckyBlockAmount")) or 1
    pZ = p0
    local p0_1 = p_ == ""
    local p1 = type(p_) ~= "string" or p0_1
    if p1 then
        return
    end
    local p0_2 = lV()
    if not p0_2 then
        return
    end
    local p1_1 = k4(p_, pZ)
    local p2 = tonumber(p0_2.Wins) or 0
    if p1_1 and p2 < p1_1 then
        return
    end
    pcall(function()
        BuyLuckyBlockWithWins:FireServer(p_, pZ, true)
    end)
    if CloseLuckyBlockGui then
        pcall(function()
            CloseLuckyBlockGui:FireServer()
        end)
    end
    l0 = nil
end
lf = false
lb = nil
k6 = fn472
l6 = fn738
lv = fn717
ld = function()
    local qu
    local qv = lV()
    local qv_5
    if not qv then
        return
    end
    local qw = tonumber(qv.Rebirth) or 0
    local qw_4
    qu = l6(qw)
    if not qu then
        return
    end
    if lf and lb == qu then
        local qv_3 = k8()
        local qw_2 = qu:FindFirstChild("Torso", true) or qu:FindFirstChildWhichIsA("BasePart", true)
        local qx_1 = qv_3
        if qx_1 then
            qx_1 = qw_2
        end
        if qx_1 then
            qx_1 = (qv_3.Position - qw_2.Position).Magnitude > 18
        end
        if qx_1 then
            mh(qw_2.CFrame + Vector3.new(0, 4, 3))
        end
        return
    end
    if lf then
        lv()
        task.wait(0.2)
    end
    local qv_4 = (qu:FindFirstChild("Torso", true))
    local qC = if qv_4 then 1 else 0
    local qA = 1040 * qC + 392 * (1 - qC)
    local qB = 253 * qC + 976 * (1 - qC)
    if not ((qA * 1025 + qB * 76 + qA * qB) % 16777213 == 1348348) then
        qv_4 = qu:FindFirstChildWhichIsA("BasePart", true)
    end
    local qw_3 = qv_4
    if qw_3 then
        mh(qw_3.CFrame + Vector3.new(0, 4, 3))
        task.wait(0.25)
    end
    qv_5, qw_4 = pcall(function()
        return StartTrainingDummy:InvokeServer(qu)
    end)
    if qv_5 and qw_4 == true then
        lf = true
        lb = qu
    end
end
local sF_4 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = lR, Copyable = true }, "|", mv },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local mt = {
    Info = sF_4:AddTab("Info", "info"),
    Main = sF_4:AddTab("Main", "swords"),
    Player = sF_4:AddTab("Player", "person-standing"),
    Settings = sF_4:AddTab("Settings", "settings")
}
local ms = fn537
for k, v in mt do
    ms(v)
end
mi, sF_4, sF_8, Label, lP, sF_2 = nil, nil, nil, nil, nil, nil
local sF_6_1 = 1
repeat
    sF_5 = (sF_6_1 * 2 + 2) % 3 + 1
    if sF_5 <= 2 then
        if sF_5 <= 1 then
            sF_5 = {
                "ldavdda",
                "teyy",
                "kckxa",
                "twzasxrsg",
                "pjhfjcdbwb",
                "ncio",
                "ooogpowxie",
                "nqxwztdnx",
                "kaduhdutnx",
                "cyt",
                "blzzyesar",
                "xekep",
                "icvjg",
                "bsfqh"
            }
            if sF_5[(sF_6_1 * 87 + 42) % 14 + 1] <= sF_5[(sF_6_1 * 87 + 42) % 14 + 1] then
                sF_2 = #lP > 18
            else
                lP = #sF_2 > 18
            end
            sF_6_1 = (sF_6_1 + 5) % 12
        else
            if (sF_6_1 * 3 + 8) * 5 % 4 == ((sF_6_1 * 3 + 8) * 5 + 12) % 4 then
                mi = "Unknown"
                pcall(fn467)
                sF_4 = mt.Info:AddLeftGroupbox("Account", "circle-user")
                sF_4:AddLabel(k_("User", lZ.Name, mB), true)
                sF_4:AddLabel(k_("Status", "Keyless", mB), true)
                sF_4:AddLabel(k_("Executor", mi, mB), true)
                sF_8 = mt.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                sF_8:AddLabel(lc(mv .. " [" .. tostring(game.PlaceId) .. "]", mA), true)
                sF_8:AddLabel(k_("Place ID", tostring(game.PlaceId), mA), true)
                Label = sF_8:AddLabel(k_("Session time", "0s", l_), true)
            else
                mv = "Unknown"
                pcall(fn467)
                lZ = sF_8.Info:AddLeftGroupbox("Account", "circle-user")
                lZ:AddLabel(mi("User", mA.Name, lc), true)
                lZ:AddLabel(mi("Status", "Keyless", lc), true)
                lZ:AddLabel(mi("Executor", "Unknown", lc), true)
                k_ = sF_8.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                k_:AddLabel(mt(Label .. " [" .. tostring(game.PlaceId) .. "]", l_), true)
                k_:AddLabel(mi("Place ID", tostring(game.PlaceId), l_), true)
                mB = k_:AddLabel(mi("Session time", "0s", sF_4), true)
            end
            sF_6_1 = (sF_6_1 + 2) % 12
        end
    else
        if not mi and not sF_4 and (mi and not sF_4) and (mi and sF_4 or (mi or sF_4)) and ((not sF_4 or not mi) and (sF_4 or sF_4) or (sF_4 or not sF_4 or not mi and sF_4)) or (not sF_4 or not sF_4 or sF_4 and not mi) and (not mi or not mi or (sF_4 or not sF_4)) and (not mi or mi or sF_4 and not sF_4 or (sF_4 or sF_4 or not sF_4 and mi)) or not (not mi and not sF_4 and (mi and not sF_4) and (mi and sF_4 or (mi or sF_4)) and ((not sF_4 or not mi) and (sF_4 or sF_4) or (sF_4 or not sF_4 or not mi and sF_4)) or (not sF_4 or not sF_4 or sF_4 and not mi) and (not mi or not mi or (sF_4 or not sF_4)) and (not mi or mi or sF_4 and not sF_4 or (sF_4 or sF_4 or not sF_4 and mi))) then
            lP = tostring(game.JobId)
        else
            sF_8 = tostring(game.JobId)
        end
        sF_6_1 = (sF_6_1 + 5) % 12
    end
until (sF_6_1 * 5 + 10) % 12 == 3
if sF_2 then
    local sF_6_2 = 1
    repeat
        sF_4 = (vector.create((sF_6_2 * 4 + 2) % 11 + 1, (sF_6_2 * 2 + 8) % 13 + 1, (sF_6_2 * 8 + 15) % 17 + 1))
        sF_5 = (vector.create((sF_6_2 * 2 + 5) % 11 + 1, (sF_6_2 * 5 + 10) % 13 + 1, (sF_6_2 * 2 + 2) % 17 + 1))
        sF_3 = (vector.create((sF_6_2 * 5 + 3) % 11 + 1, (sF_6_2 * 9 + 1) % 13 + 1, (sF_6_2 * 7 + 17) % 17 + 1))
        if vector.dot(vector.cross(sF_4, sF_5), sF_3) == vector.dot(vector.cross(sF_5, sF_3), sF_4) then
            sF_2 = string.sub(lP, 1, 18) .. "..."
        else
            lP = string.sub(sF_2, 1, 18) .. "..."
        end
        sF_6_2 = (sF_6_2 + 2) % 8
    until (sF_6_2 * 7 + 5) % 8 == 2
end
local sF_6_3 = sF_2 or lP
lx, FarmGroup, lu, lq, connection, connection2, CurrentCamera, lJ, lh, k0, lG, k7, lT = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
sF_3 = sF_6_3
sF_8:AddLabel(k_("Server", sF_3, mx), true)
sF_8:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
lx = os.clock()
task.spawn(worker)
sF_2 = mt.Info:AddRightGroupbox("Scripts", "package")
sF_2:AddLabel(lc("Included in this hub", mx), true)
sF_2:AddLabel(lc(mv, mA), true)
sF_4 = mt.Info:AddRightGroupbox("Features", "list")
sF_4:AddLabel(lc("Auto Farm", mA), true)
sF_4:AddLabel(lc("Auto Shop", mB), true)
sF_4:AddLabel(lc("Auto Progress", l_), true)
sF_4:AddLabel(lc("Misc Utilities", mx), true)
local SocialsGroup = mt.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = ll })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = mt.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = ll })
local FaqGroup = mt.Info:AddRightGroupbox("FAQ", "circle-help")
if (not k0 or sF_4) and (sF_4 and sF_2) or (not TempoHubGroup or sF_3) and (not k0 and sF_3) or (not sF_2 and not sF_4 and (not k0 and not sF_3) or (not k0 or TempoHubGroup) and (sF_3 or not sF_3)) or not ((not k0 or sF_4) and (sF_4 and sF_2) or (not TempoHubGroup or sF_3) and (not k0 and sF_3) or (not sF_2 and not sF_4 and (not k0 and not sF_3) or (not k0 or TempoHubGroup) and (sF_3 or not sF_3))) then
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
    FarmGroup = mt.Main:AddLeftGroupbox("Farm", "swords")
else
    FarmGroup:AddLabel("Where do I get a good config?", true)
    FarmGroup:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
    FarmGroup:AddLabel("How do I import / export configs?", true)
    FarmGroup:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
    FarmGroup:AddLabel("How do I report bugs?", true)
    FarmGroup:AddLabel("Join the Discord and post it in the bugs channel.", true)
    FarmGroup:AddLabel("How do I make suggestions?", true)
    FarmGroup:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
    FarmGroup:AddLabel("How do I get help or updates?", true)
    FarmGroup:AddLabel("Join the Discord, updates and support are posted there first.", true)
    mt = FaqGroup.Main:AddLeftGroupbox("Farm", "swords")
end
FarmGroup:AddToggle("AutoWinPlates", { Text = "Auto Farm Win Plates", Default = false })
FarmGroup:AddDropdown("WinPlateChoice", { Text = "Win Plate", Values = mz, Default = "Best" })
FarmGroup:AddToggle("AutoClick", { Text = "Auto Click", Default = false })
FarmGroup:AddToggle("AutoTrain", { Text = "Auto Train", Default = false })
FarmGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
local ShopGroup = mt.Main:AddRightGroupbox("Shop", "shopping-bag")
ShopGroup:AddToggle("AutoBuyTrails", { Text = "Auto Buy Trails", Default = false })
ShopGroup:AddToggle("AutoBuyAura", { Text = "Auto Buy Aura", Default = false })
ShopGroup:AddToggle("AutoEquipTrail", { Text = "Auto Equip Trail", Default = false })
ShopGroup:AddToggle("AutoEquipAura", { Text = "Auto Equip Aura", Default = false })
ShopGroup:AddToggle("AutoBuyStands", { Text = "Auto Buy Stands", Default = false })
ShopGroup:AddToggle("AutoEquipStand", { Text = "Auto Equip Stand", Default = false })
ShopGroup:AddToggle("AutoRollLuckyBlocks", { Text = "Auto Roll Lucky Blocks", Default = false })
ShopGroup:AddDropdown("LuckyBlockType", { Text = "Lucky Block", Values = my, Default = "Normal" })
ShopGroup:AddDropdown("LuckyBlockAmount", { Text = "Lucky Block Amount", Values = mw, Default = "1" })
local MovementGroup = mt.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = mt.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
ms = mt.Settings:AddLeftGroupbox("Menu")
ms:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
ms:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
ms:AddButton("Unload", onUnload)
Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(mt.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/StandPowerEvolution")
mr = SaveManager:BuildConfigSection(mt.Settings)
lJ = fn329
lh = fn419
k0 = fn804
lG = function(gm)
    local ri
    ri = nil
    local rj = type(gm) ~= "table" or type(gm.idx) ~= "string" or type(gm.type) ~= "string" or SaveManager.Ignore[gm.idx]
    if rj then
        return false
    end
    ri = lJ(gm.type, gm.idx)
    if not ri then
        return false
    end
    local rj_1 = pcall(function()
        if gm.type == "Input" then
            if type(gm.text) ~= "string" then
                return
            end
            ri:SetValue(gm.text)
        elseif gm.type == "ColorPicker" then
            ri:SetValueRGB(Color3.fromHex(gm.value), gm.transparency)
        elseif gm.type == "KeyPicker" then
            ri:SetValue({ gm.key, gm.mode, gm.modifiers })
            if gm.mode == "Toggle" and gm.toggled ~= nil then
                ri.Toggled = gm.toggled
                ri:Update()
            end
        else
            ri:SetValue(gm.value)
        end
    end)
    return rj_1
end
mr:AddDivider()
mr:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
mr:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
mr:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
lu = tick()
lq = tick()
pcall(function()
    for i, v in ipairs(getconnections(lZ.Idled)) do
        local rL = v
        pcall(function()
            rL:Disable()
        end)
    end
end)
k7 = fn431
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
lT = function(g5)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not g5)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not g5
        end
    end)
    if not g5 then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(lZ, "GameplayPaused", false)
        else
            lZ.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fn831)
Toggles.Fly:OnChanged(fn742)
Toggles.WalkSpeedEnabled:OnChanged(fn77)
Toggles.AutoTrain:OnChanged(fn531)
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
task.spawn(antiAfkLoop)
task.spawn(antiGameplayPauseLoop)
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(worker6)
Library:OnUnload(fn636)
end)(...)

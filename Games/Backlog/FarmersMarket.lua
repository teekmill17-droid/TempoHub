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
getgenv().TempoHoodSubtitle = "FARMERS MARKET"
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
local mJ
local nq
local nP
local mP
local nw
local nd
local mV
local nC
local nj
local nI
local mI
local np
local m6
local nO
local nv
local nU
local mU
local nB
local ni
local m_
local Options
local nT
local Toggles
local nh
local CropConfig
local m4
local nM
local mM
local nS
local mS
local ng
local mY
local nF
local nm
local m3
local mL
local ns
local Library
local mR
local ny
local nf
local mX
local nE
local nl
local m2
local mK
local nr
local m8
local nQ
local nx
local ne
local mW
local nD
local m1
local nJ
local function fn3(aj, ak)
    if aj.group ~= ak.group then
        return aj.group < ak.group
    end
    return aj.order < ak.order
end
local function fn8()
    local Character = mX.Character
    local pl = Character and Character:FindFirstChildOfClass("Humanoid")
    return pl
end
local function fn26(e5)
    local Objects = e5:FindFirstChild("Objects")
    if not Objects then
        return false
    end
    local tx = false
    for i, child in Objects:GetChildren() do
        local attr = child:GetAttribute("Item")
        local ty = attr and nf.Items[attr]
        local tw_2 = ty
        if ty then
            ty = tw_2.Pen
        end
        local tw_3 = ty
        if tw_3 then
            local ty_1 = child:GetAttribute("Output") or 0
            if ty_1 > 0 then
                local Collect = child:FindFirstChild("Collect")
                if Collect then
                    mI(Collect.Position)
                end
                local ty_3 = math.min(CropConfig.ContributeBatch(tw_3.OutputMax), ty_1)
                mM:FireServer(child.Name, ty_3)
                tx = true
                task.wait(0.12)
            end
        end
    end
    return tx
end
local function fn60(aZ, a_)
    return string.format('<font color="%s">%s</font>', a_, aZ)
end
local function fn104(bd)
    local o8 = Toggles[bd]
    return o8 ~= nil and o8.Value == true
end
local function fn146(cx)
    local qC = {}
    local StoreFront = cx:FindFirstChild("StoreFront")
    local qE = StoreFront and StoreFront:FindFirstChild("SellSpots")
    if not qE then
        return qC
    end
    for i, child in qE:GetChildren() do
        qC[#qC + 1] = child.Name
    end
    table.sort(qC)
    return qC
end
local function fn178(cg)
    local Crops = cg:FindFirstChild("Crops")
    if not Crops then
        return false
    end
    local qo = false
    for i, child in Crops:GetChildren() do
        local attr3 = child:GetAttribute("Crop")
        local attr2 = child:GetAttribute("Stage")
        if not not (attr3 and attr2) then
            if not (attr2 < CropConfig.GetStageCount(attr3)) then
                local attr = child:GetAttribute("PlantedAt")
                local Name = child.Name
                local qq_1 = nB[Name]
                local qr = qq_1 and qq_1.PlantedAt == attr and tick() - qq_1.At < 2
                if not qr then
                    local Position = child:GetPivot().Position
                    if not not mI(Position) then
                        nB[Name] = { PlantedAt = attr, At = tick() }
                        m6:FireServer(child.Name)
                        qo = true
                        task.wait(0.15)
                    end
                end
            end
        end
    end
    return qo
end
local function fn232(cF)
    local qM = m1(cF)
    if #qM == 0 then
        return false
    end
    local qN = mJ()
    local qO = 1
    local qP = false
    for k, v in ny do
        local qQ = qN[v]
        local qR = type(qQ) == "number" and qQ > 0
        if qR then
            local qR_1 = qM[(qO - 1) % #qM + 1]
            local qS = math.min(CropConfig.ContributeBatch(qQ), qQ)
            if qS > 0 then
                mY:FireServer(qR_1, v, qS)
                qP = true
                qO += 1
                task.wait(0.12)
            end
        end
    end
    return qP
end
local function fn287(dR)
    local sa = CropConfig.Buildings[dR]
    if not (sa and sa.Repair) then
        return nil
    end
    local sb_1 = {}
    if sa.Repair.Cash and sa.Repair.Cash > 0 then
        sb_1.Cash = sa.Repair.Cash
    end
    local sd = sa.Repair.Items or {}
    for k, v in sd do
        sb_1[k] = v
    end
    return sb_1
end
local function fn291()
    local pt = nq:Get("Cash") or 0
    return pt
end
local function fn292(cW, cX, cY, cZ, c_, c0)
    local Crops = cW:FindFirstChild("Crops")
    if Crops then
        for i, child in Crops:GetChildren() do
            local q__1 = child:GetAttribute("CellX")
            local attr = child:GetAttribute("CellZ")
            local q1_1 = child:GetAttribute("Section") or "S1"
            if q1_1 == cX and q__1 and attr then
                if cY <= q__1 and q__1 <= cY + c_ - 1 and cZ <= attr and attr <= cZ + c0 - 1 then
                    return true
                end
            end
        end
    end
    for k, v in { "Objects", "PreSpawned" } do
        local q__2 = cW:FindFirstChild(v)
        if q__2 then
            for i, child in q__2:GetChildren() do
                local q__3 = child:GetAttribute("CellX")
                local attr = child:GetAttribute("CellZ")
                local q1_4 = child:GetAttribute("W") or 1
                local q1_5 = child:GetAttribute("D") or 1
                local q1_6 = child:GetAttribute("Section") == cX and q__3
                if q1_6 and attr then
                    if cY <= q__3 + q1_4 - 1 and q__3 <= cY + c_ - 1 and cZ <= attr + q1_5 - 1 and attr <= cZ + c0 - 1 then
                        return true
                    end
                end
            end
        end
    end
    return false
end
local function fn298(fF)
    local DiscordGroup = fF:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = np })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = np })
end
local function fn342()
    local Plots = m3:FindFirstChild("Plots")
    local pr = Plots and Plots:FindFirstChild(mX.Name)
    return pr
end
local function fn346(K)
    if cloneref then
        return cloneref(K)
    end
    return K
end
local function fn362(a1, a2, a3)
    return string.format("<b>%s</b> %s %s", a1, nm("-", "#5a6070"), nm(a2, a3))
end
local function fn372()
    local s5 = nS("ShopItems")
    if next(s5) == nil then
        return false
    end
    local s6 = mW()
    local s7 = false
    for k, v in nj do
        local s8 = s5[v] and not nd(v) and not mL(v)
        if s8 then
            local s8_1 = ng(v)
            local s9 = type(s8_1) == "number" and s8_1 <= s6
            if s9 then
                mR:FireServer(v)
                s6 -= s8_1
                s7 = true
                task.wait(0.12)
            end
        end
    end
    return s7
end
local function worker2()
    while not Library.Unloaded do
        local vA = nr()
        local vB = false
        if vA then
            local vC_1 = m8("AutoHarvest") and nv(vA)
            if vC_1 then
                vB = true
            end
            local vC_2 = m8("AutoCollectMilk") and ns(vA)
            if vC_2 then
                vB = true
            end
            local vC_3 = m8("AutoFeedAnimals") and mV(vA)
            if vC_3 then
                vB = true
            end
            local vC_4 = m8("AutoStock") and nw(vA)
            if vC_4 then
                vB = true
            end
            local vC_5 = m8("AutoPlace") and mU(vA)
            if vC_5 then
                vB = true
            end
            local vC_6 = m8("AutoBuildFarm") and mS(vA)
            if vC_6 then
                vB = true
            end
            local vA_1 = m8("AutoBuyShop") and nU()
            if vA_1 then
                vB = true
            end
            local vA_2 = m8("AutoUpgradeBarn") and m_()
            if vA_2 then
                vB = true
            end
        end
        local wait = task.wait
        local vB_1 = vB and 0.2 or 0.45
        wait(vB_1)
    end
end
local function fn386()
    local pz = {}
    local pA = nq:Get("Inventory") or pz
    return pA.Metas or {}
end
local function fn439(eS)
    local th = eS.Cash or 0
    if th > mW() then
        return false
    end
    local ti = eS.Items or {}
    for k, v in ti do
        if nC(k) < v then
            return false
        end
    end
    return true
end
local function fn457()
    return nl
end
local function fn469(cc)
    local ql = nQ()
    if not ql then
        return false
    end
    ql.CFrame = CFrame.new(cc + Vector3.new(0, 3, 0))
    return true
end
local function worker()
    while Library and not Library.Unloaded do
        m4()
        task.wait(1)
    end
end
local function fn490(bN)
    local pF = CropConfig.Crops[bN] or CropConfig.Animals[bN] or CropConfig.Machines[bN]
    if not pF then
        return nil
    end
    if CropConfig.Animals[bN] or CropConfig.Machines[bN] then
        local pF_2 = 0
        local pH = {}
        local pI = nq:Get("PlacedObjects") or pH
        for k, v in pI do
            if v.Item == bN then
                pF_2 += 1
            end
        end
        for k, v in nM() do
            if v[1] == bN then
                pF_2 += 1
            end
        end
        return CropConfig.CopyCost(pF, pF_2)
    end
    return pF.Cost
end
local function fn494()
    nP(nh, "Copied Discord invite to clipboard")
end
local function fn519(d_, d0)
    for k, v in d_ do
        local so = d0[k]
        local sA = if so then 1 else 0
        local sy = 449 * sA + 3988 * (1 - sA)
        local sz = 1980 * sA + 3184 * (1 - sA)
        if not ((sy * 859 + sz * 3163 + sy * sz) % 16777213 == 7537451) then
            so = 0
        end
        local sp = so
        local sp_1
        local so_1 = v - sp
        if so_1 > 0 then
            if k == "Cash" then
                sp_1 = mW()
            else
                sp_1 = nC(k)
            end
            local sq = sp_1
            if sq > 0 then
                return k, math.min(CropConfig.ContributeBatch(v), so_1, sq)
            end
        end
    end
    return nil
end
local function fn539(at, au)
    return at.order < au.order
end
local function fn552(ds, du)
    local ry_1
    local rx_1
    local Land = ds:FindFirstChild("Land")
    if not Land then
        return nil
    end
    ry_1, rx_1 = ne(du)
    local rz = {}
    for i, child in Land:GetChildren() do
        if child:GetAttribute("Owned") then
            rz[#rz + 1] = child.Name
        end
    end
    table.sort(rz)
    for k, v in rz do
        local rw_1 = CropConfig.GridCells - ry_1 + 1
        local rP = 1
        while rP <= rw_1 do
            local rQ = rP
            local rw_2 = CropConfig.GridCells - rx_1 + 1
            local rU = 1
            while rU <= rw_2 do
                local rV = rU
                if not m2(ds, v, rQ, rV, ry_1, rx_1) then
                    return v, rQ, rV
                end
                rU += 1
            end
            rP += 1
        end
    end
    return nil
end
local function fn560(d8)
    local sH_1
    local sG_1
    local sF_3
    local sE_3
    local sB = false
    local Expand = d8:FindFirstChild("Expand")
    if Expand then
        local sD_1 = {}
        local sE_1 = nq:Get("ExpandContributions") or sD_1
        for i, child in Expand:GetChildren() do
            local sC_1 = ni(child.Name)
            if sC_1 then
                local sF_1 = sE_1[child.Name] or {}
                sE_3, sG_1 = mP(sC_1, sF_1)
                if sE_3 and sG_1 then
                    mI(child.Position)
                    nI:FireServer(child.Name, sE_3, sG_1)
                    sB = true
                    task.wait(0.12)
                end
            end
        end
    end
    local PreSpawned = d8:FindFirstChild("PreSpawned")
    if PreSpawned then
        local sD_3 = {}
        local sE_4 = nq:Get("BuildContributions") or sD_3
        for i, child in PreSpawned:GetChildren() do
            local Repair = child:FindFirstChild("Repair")
            if Repair then
                local sE_5 = nJ(child.Name)
                if sE_5 then
                    local sG_2 = sE_4[child.Name] or {}
                    sF_3, sH_1 = mP(sE_5, sG_2)
                    if sF_3 and sH_1 then
                        mI(Repair.Position)
                        nF:FireServer(child.Name, sF_3, sH_1)
                        sB = true
                        task.wait(0.12)
                    end
                end
            end
        end
    end
    return sB
end
local function fn623(bK)
    local pD = mJ()[bK] or 0
    return pD
end
local function fn628(dJ)
    local rX = CropConfig.Land[dJ]
    if not rX then
        return nil
    end
    local rY = {}
    if rX.Cash and rX.Cash > 0 then
        rY.Cash = rX.Cash
    end
    local rZ_1 = {}
    local r_ = rX.Items
    local r3 = if r_ then 1 else 0
    local r1 = 2203 * r3 + 1089 * (1 - r3)
    local r2 = 138 * r3 + 3531 * (1 - r3)
    if not ((r1 * 1513 + r2 * 2863 + r1 * r2) % 16777213 == 4032247) then
        r_ = rZ_1
    end
    for k, v in r_ do
        rY[k] = v
    end
    return rY
end
local function fn668(bi)
    local pb = Options[bi]
    local pc = pb and pb.Value
    if type(pc) ~= "table" then
        return {}
    end
    local pc_1 = {}
    for k, v in pc do
        if v == true then
            pc_1[k] = true
        end
    end
    return pc_1
end
local function fn670(b2)
    if not (CropConfig.Animals[b2] or CropConfig.Machines[b2]) then
        return false
    end
    local p1_1 = nq:Get("BarnLevel") or 1
    local p1_2 = CropConfig.CopyCap(b2, p1_1)
    local p2_1 = 0
    local p3 = {}
    local p4 = (nq:Get("PlacedObjects"))
    local p8 = if p4 then 1 else 0
    local p6 = 2596 * p8 + 1054 * (1 - p8)
    local p7 = 3058 * p8 + 2755 * (1 - p8)
    if not ((p6 * 2062 + p7 * 3138 + p6 * p7) % 16777213 == 6110311) then
        p4 = p3
    end
    for k, v in p4 do
        if v.Item == b2 then
            p2_1 += 1
        end
    end
    for k, v in nM() do
        if v[1] == b2 then
            p2_1 += 1
        end
    end
    return p2_1 >= p1_2
end
local function fn674()
    local pv = {}
    local pw = nq:Get("Inventory") or pv
    return pw.Generic or {}
end
local function fn686()
    local Character = mX.Character
    local po = Character and Character:FindFirstChild("HumanoidRootPart")
    return po
end
local function fn715(eq)
    local sY_1
    local sX_2
    for k, v in nM() do
        local sV = v[1]
        local sW = sV
        local sW_1
        if sW then
            local sX_1 = CropConfig.Crops[sV] or CropConfig.BuildableDef(sV)
            sW = sX_1
        end
        if sW then
            sY_1, sW_1, sX_2 = nE(eq, sV)
            if sY_1 then
                nO:FireServer(tostring(k), sY_1, sW_1, sX_2, 0)
                task.wait(0.15)
                return true
            end
        end
    end
    return false
end
local function fn742()
    local tq = (nq:Get("BarnLevel"))
    local tv = if tq then 1 else 0
    local tt = 636 * tv + 1512 * (1 - tv)
    local tu = 3041 * tv + 3916 * (1 - tv)
    if not ((tt * 2142 + tu * 1641 + tt * tu) % 16777213 == 8286669) then
        tq = 1
    end
    local tr = tq
    if tr >= (CropConfig.BarnMaxLevel or 0) then
        return false
    end
    local tq_2 = CropConfig.BarnLevels[tr + 1]
    local tr_1 = not tq_2 or not nD(tq_2)
    if tr_1 then
        return false
    end
    nx:FireServer()
    task.wait(0.2)
    return true
end
local function fn747(b_)
    if not CropConfig.Buildings[b_] then
        return false
    end
    local pZ = {}
    local p_ = nq:Get("PreSpawnedBuilt") or pZ
    return p_[b_] ~= true
end
local function fn774(fk)
    local tH = nS("FeedAnimals")
    if next(tH) == nil then
        return false
    end
    local Objects = fk:FindFirstChild("Objects")
    if not Objects then
        return false
    end
    local tJ = false
    for i, child in Objects:GetChildren() do
        local attr = child:GetAttribute("Item")
        if tH[attr] then
            local tK = nf.Items[attr]
            local tI_2 = tK and tK.Pen
            if tI_2 then
                for i, v in ipairs(tI_2.Inputs) do
                    local tI_3 = child:GetAttribute("Input" .. i) or 0
                    local tI_4 = v.Max - tI_3
                    local tK_3 = nC(v.Item)
                    if tI_4 > 0 and tK_3 > 0 then
                        local Deposit = child:FindFirstChild("Deposit")
                        if Deposit then
                            mI(Deposit.Position)
                        end
                        local tL_2 = math.min(CropConfig.ContributeBatch(v.Max), tI_4, tK_3)
                        nT:FireServer(child.Name, v.Item, tL_2)
                        tJ = true
                        task.wait(0.12)
                        break
                    end
                end
            end
        end
    end
    return tJ
end
local function fn813(a6, a7)
    if setclipboard then
        setclipboard(a6)
    elseif toclipboard then
        toclipboard(a6)
    end
    Library:Notify(a7)
end
mI = nil
mJ = nil
mK = nil
mL = nil
mM = nil
mP = nil
mR = nil
mS = nil
mU = nil
mV = nil
mW = nil
mX = nil
mY = nil
m_ = nil
m1 = nil
m2 = nil
m3 = nil
m4 = nil
m6 = nil
m8 = nil
Library = nil
nd = nil
ne = nil
nf = nil
ng = nil
nh = nil
ni = nil
nj = nil
nl = nil
nm = nil
CropConfig = nil
np = nil
nq = nil
nr = nil
ns = nil
local mG, mH, mN, mO, PlayerGui, mT, mZ, m0, m5, m7, na, nb, nc, nk, no
Options = nil
nv = nil
nw = nil
nx = nil
ny = nil
Toggles = nil
nB = nil
nC = nil
nD = nil
nE = nil
nF = nil
nI = nil
nJ = nil
nM = nil
local nN
nO = nil
nP = nil
nQ = nil
nS = nil
nT = nil
nU = nil
local nt, nz, nG, SaveManager, nK, ThemeManager, nR, nZ, n_, n1, n3
local n0_1
local nX_3, nX_4
local nW_1
local nY_6
mG, nW_1, nK, nG, nz, nt, nl, nc, na, m3, mX, PlayerGui, mK = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local nV = 3
repeat
    local nX_1 = (nV * 2 + 1) % 5 + 1
    if nX_1 <= 3 then
        if nX_1 <= 2 then
            if nX_1 <= 1 then
                local nY_1 = (vector.create((nV * 7 + 1) % 11 + 1, (nV * 6 + 9) % 13 + 1, (nV * 1 + 10) % 17 + 1))
                nZ = (vector.create((nV * 6 + 2) % 11 + 1, (nV * 8 + 11) % 13 + 1, (nV * 10 + 9) % 17 + 1))
                n_ = (vector.create((nV * 1 + 2) % 5 + 1, (nV * 1 + 4) % 7 + 1, (nV * 3 + 7) % 9 + 1))
                if math.abs((vector.angle(nY_1, nZ, n_))) - math.abs((vector.angle(nZ, nY_1, n_))) == 0 then
                    mX = mG.LocalPlayer
                    PlayerGui = mX:WaitForChild("PlayerGui")
                else
                    mG = PlayerGui.LocalPlayer
                    mX = mG:WaitForChild("PlayerGui")
                end
                nV = (nV + 18) % 20
            else
                if (nV * 1 + 7) * 5 % 4 == ((nV * 1 + 7) * 5 + 1) % 4 then
                    m3 = fn457
                else
                    mK = fn457
                end
                nV = (nV + 8) % 20
            end
        else
            local xP = bit32.rrotate(bit32.bxor(bit32.lrotate(nV, 1), string.byte(tostring(mK))), 25)
            if bit32.bxor(bit32.lrotate(bit32.bxor(xP, 4030764813), 30), 2081433027) == bit32.lrotate(xP, 30) then
                mG = game:GetService("Players")
            else
                mX = game:GetService("Players")
            end
            nV = (nV + 18) % 20
        end
    elseif nX_1 <= 4 then
        local nX_2 = (vector.create((nV * 7 + 2) % 11 + 1, (nV * 4 + 13) % 13 + 1, (nV * 5 + 8) % 17 + 1))
        local nY_2 = (vector.create((nV * 4 + 4) % 11 + 1, (nV * 4 + 13) % 13 + 1, (nV * 14 + 7) % 17 + 1))
        local w9 = vector.cross(nX_2, nY_2)
        local xa = vector.dot(nX_2, nY_2)
        if vector.dot(w9, w9) + xa * xa == vector.dot(nX_2, nX_2) * vector.dot(nY_2, nY_2) then
            nW_1 = game:GetService("ReplicatedStorage")
            nK = game:GetService("RunService")
            nG = game:GetService("UserInputService")
            nz = game:GetService("VirtualUser")
            nt = game:GetService("HttpService")
        else
            nz = game:GetService("ReplicatedStorage")
            nW_1 = game:GetService("RunService")
            nt = game:GetService("UserInputService")
            nG = game:GetService("VirtualUser")
            nK = game:GetService("HttpService")
        end
        nV = (nV + 3) % 20
    else
        if (nV * 1 + 4) * 5 % 4 == ((nV * 1 + 4) * 5 + 5) % 4 then
            m3 = game:GetService("CoreGui")
            na = game:GetService("GuiService")
            nl = game:GetService("TeleportService")
            nc = game:GetService("Workspace")
        else
            nl = game:GetService("CoreGui")
            nc = game:GetService("GuiService")
            na = game:GetService("TeleportService")
            m3 = game:GetService("Workspace")
        end
        nV = (nV + 8) % 20
    end
until (nV * 9 + 5) % 20 == 7
if getgenv then
    nN, nX_3 = nil, nil
    local nV_1 = 4
    repeat
        if (nV_1 * 1 + 0) % 2 + 1 <= 1 then
            local nY_4 = {
                "vlhy",
                "msarw",
                "oxztpaadf",
                "moho",
                "ekrdw",
                "ognnywrndokx",
                "jfcldf",
                "etkqacuqpzi",
                "qpnwdwsxmwg"
            }
            if nY_4[(nV_1 * 17 + 26) % 9 + 1] < nY_4[(nV_1 * 17 + 26) % 9 + 1] then
                getgenv().gethui = nN
                mK = getgenv().__TempoFarmersMarketLib
            else
                getgenv().gethui = mK
                nN = getgenv().__TempoFarmersMarketLib
            end
            nV_1 = (nV_1 + 5) % 8
        else
            local nY_5 = (vector.create((nV_1 * 5 + 7) % 11 + 1, (nV_1 * 5 + 8) % 13 + 1, (nV_1 * 7 + 17) % 17 + 1))
            nZ = (vector.create((nV_1 * 1 + 5) % 11 + 1, (nV_1 * 6 + 8) % 13 + 1, (nV_1 * 15 + 16) % 17 + 1))
            n_ = (vector.create((nV_1 * 3 + 9) % 11 + 1, (nV_1 * 2 + 13) % 13 + 1, (nV_1 * 6 + 2) % 17 + 1))
            if vector.dot(vector.cross(nY_5, nZ), n_) == vector.dot(vector.cross(nZ, n_), nY_5) + 3 then
                nN = nX_3
            else
                nX_3 = nN
            end
            nV_1 = (nV_1 + 7) % 8
        end
    until (nV_1 * 5 + 6) % 8 == 6
    if nX_3 then
        nX_3 = nN.Unload
    end
    if nX_3 then
        pcall(function()
            nN:Unload()
        end)
    end
end
pcall(function()
    gethui = mK
end)
if setthreadidentity then
    setthreadidentity(8)
end
no, nh, nb, m7, m0, mT, mN, mH, nR, nZ, nY_6, CropConfig, nf, nX_4, m6, mY, mR, mM, nT, nO, nI, nF, nx, nq, nj, n0_1, n_ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local nV_2 = 15
repeat
    n1 = (nV_2 * 4 + 2) % 13 + 1
    if n1 <= 7 then
        if n1 <= 4 then
            if n1 <= 2 then
                if n1 <= 1 then
                    local w3 = bit32.rrotate(bit32.bxor(bit32.lrotate(nV_2, 28), string.byte(tostring(nI))), 16)
                    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(w3, 3656597455), 3425993870), (bit32.bxor(bit32.band(w3, 638369840), 2555881794))), 3425993870), 2555881794) ~= w3 then
                        nR = "#8b93a3"
                        mH = "#e05a5a"
                    else
                        mH = "#8b93a3"
                        nR = "#e05a5a"
                    end
                    nV_2 = (nV_2 + 10) % 52
                else
                    if nV_2 * 89741223 + 3 + 6 <= nV_2 * 89741223 + 3 + 6 + 1 then
                        n_ = fn346
                    else
                        m7 = fn346
                    end
                    nV_2 = (nV_2 + 10) % 52
                end
            elseif n1 <= 3 then
                local n2_1 = {
                    "vnvi",
                    "eyd",
                    "rrpoutemg",
                    "dasrr",
                    "usjc",
                    "nzuekmhjblvs",
                    "gvudf",
                    "fmoiqqdx",
                    "fsndkbws",
                    "vvc",
                    "myqlpcozjovd",
                    "hhhwmu",
                    "uddhmfki",
                    "lbrx",
                    "uhwsx"
                }
                if n2_1[(nV_2 * 48 + 66) % 15 + 1] <= n2_1[(nV_2 * 48 + 66) % 15 + 1] then
                    nZ = nW_1:WaitForChild("Shared")
                else
                    nW_1 = nZ:WaitForChild("Shared")
                end
                nV_2 = (nV_2 + 10) % 52
            else
                if (mH and not nf and (mH and nX_4) or (nR or nR or m0 and nR)) and not (mH and not nf and (mH and nX_4) or (nR or nR or m0 and nR)) then
                    nW_1 = nY_6:WaitForChild("Communication")
                else
                    nY_6 = nW_1:WaitForChild("Communication")
                end
                nV_2 = (nV_2 + 10) % 52
            end
        elseif n1 <= 6 then
            if n1 <= 5 then
                local n2_2 = {
                    "bqkzjnpr",
                    "jgpdpgtek",
                    "wbhvzinv",
                    "lrhafujkdcd",
                    "nmppj",
                    "tsfh",
                    "cwgy",
                    "pkifqfhvp",
                    "qrbeg",
                    "niyxq",
                    "khixglwsbnx",
                    "gymiryd",
                    "btpdvwv",
                    "srgwymdvtkpi",
                    "fbkezoi"
                }
                if n2_2[(nV_2 * 66 + 73) % 15 + 1] < n2_2[(nV_2 * 66 + 73) % 15 + 1] then
                    nf = require(CropConfig:WaitForChild("GS"):WaitForChild("CropConfig"))
                    nZ = require(CropConfig:WaitForChild("ItemData"))
                else
                    CropConfig = require(nZ:WaitForChild("GS"):WaitForChild("CropConfig"))
                    nf = require(nZ:WaitForChild("ItemData"))
                end
                nV_2 = (nV_2 + 49) % 52
            else
                if nV_2 * 103647979 + 8 + 2 >= nV_2 * 103647979 + 8 + 2 + 5 then
                    mX = require(nX_4:WaitForChild("PlayerScripts"):WaitForChild("Client"):WaitForChild("LocalDataStore"))
                else
                    nX_4 = require(mX:WaitForChild("PlayerScripts"):WaitForChild("Client"):WaitForChild("LocalDataStore"))
                end
                nV_2 = (nV_2 + 49) % 52
            end
        else
            local n2_3 = (vector.create((nV_2 * 3 + 1) % 11 + 1, (nV_2 * 9 + 9) % 13 + 1, (nV_2 * 10 + 16) % 17 + 1))
            n3 = (vector.create((nV_2 * 7 + 9) % 11 + 1, (nV_2 * 9 + 9) % 13 + 1, (nV_2 * 8 + 13) % 17 + 1))
            local n4_1 = (vector.create((nV_2 * 5 + 2) % 11 + 1, (nV_2 * 2 + 1) % 13 + 1, (nV_2 * 4 + 6) % 17 + 1))
            if vector.dot(vector.cross(n2_3, n3), n4_1) == vector.dot(vector.cross(n3, n4_1), n2_3) then
                m6 = n_(nY_6:WaitForChild("HarvestCrop"))
                mY = n_(nY_6:WaitForChild("SellSpotStock"))
            else
                mY = nY_6(n_:WaitForChild("HarvestCrop"))
                m6 = nY_6(n_:WaitForChild("SellSpotStock"))
            end
            nV_2 = (nV_2 + 49) % 52
        end
    elseif n1 <= 10 then
        if n1 <= 9 then
            if n1 <= 8 then
                if (nV_2 * 1 + 8) * 17 % 4 == ((nV_2 * 1 + 8) * 17 + 12) % 4 then
                    mR = n_(nY_6:WaitForChild("PlotShopBuy"))
                    mM = n_(nY_6:WaitForChild("PenCollect"))
                    nT = n_(nY_6:WaitForChild("PenDeposit"))
                    nO = n_(nY_6:WaitForChild("PlaceCrop"))
                else
                    nY_6 = mR(mM:WaitForChild("PlotShopBuy"))
                    nT = mR(mM:WaitForChild("PenCollect"))
                    nO = mR(mM:WaitForChild("PenDeposit"))
                    n_ = mR(mM:WaitForChild("PlaceCrop"))
                end
                nV_2 = (nV_2 + 10) % 52
            else
                local n2_4 = {
                    "qsrfmtecfen",
                    "ahfpnt",
                    "ycijwksfim",
                    "xazwf",
                    "wtswycuwo",
                    "ckcaqsvgyhz",
                    "sglmnqrsv",
                    "byrxizqe",
                    "llfmbzvbpi",
                    "zwbsn",
                    "fjtw"
                }
                local xi = nV_2
                n3 = n2_4[xi % 11 + 1]
                if n3:len() >= n3:reverse():rep(xi % 3 + 2):len() then
                    nx = nY_6(nI:WaitForChild("ExpandContribute"))
                    nq = nY_6(nI:WaitForChild("BuildContribute"))
                    nF = nY_6(nI:WaitForChild("BarnUpgrade"))
                    nX_4 = nj:Get()
                    n_ = {}
                else
                    nI = n_(nY_6:WaitForChild("ExpandContribute"))
                    nF = n_(nY_6:WaitForChild("BuildContribute"))
                    nx = n_(nY_6:WaitForChild("BarnUpgrade"))
                    nq = nX_4:Get()
                    nj = {}
                end
                nV_2 = (nV_2 + 23) % 52
            end
        else
            local n2_5 = { "htqgqrgi", "ndiou", "vdif", "dvdyecihehr", "wmjzf", "plwggu", "cvgybju", "lfcu", "ckdgurydtqb" }
            local xX = nV_2
            n3 = n2_5[xX % 9 + 1]
            if n3:len() >= n3:gsub("(.)", "%1%1", xX % 3 % 2 + 1):len() then
                nj = {}
            else
                n0_1 = {}
            end
            nV_2 = (nV_2 + 36) % 52
        end
    elseif n1 <= 12 then
        if n1 <= 11 then
            local xn = bit32.rrotate(bit32.bxor(bit32.lrotate(nV_2, 14), string.byte(tostring(mY))), 21)
            if bit32.bxor(bit32.lrotate(bit32.bxor(xn, 86511306), 22), 2994817539) ~= bit32.lrotate(xn, 22) then
                nh = "Farmers Market"
                no = "https://discord.gg/K7Qxnxkk46"
            else
                no = "Farmers Market"
                nh = "https://discord.gg/K7Qxnxkk46"
            end
            nV_2 = (nV_2 + 36) % 52
        else
            if (not nY_6 and m6 and (not nZ or not m6) and (nY_6 and CropConfig and (nZ or not CropConfig)) or ((not CropConfig or nR) and (not nR and not CropConfig) or not m6 and nR and (not nY_6 and CropConfig))) and not (not nY_6 and m6 and (not nZ or not m6) and (nY_6 and CropConfig and (nZ or not CropConfig)) or ((not CropConfig or nR) and (not nR and not CropConfig) or not m6 and nR and (not nY_6 and CropConfig))) then
                mT = "https://discord.gg/K7Qxnxkk46"
                nb = "https://tempohub.shop"
                m7 = "#7fd47f"
                m0 = "#6ec1ff"
            else
                nb = "https://discord.gg/K7Qxnxkk46"
                m7 = "https://tempohub.shop"
                m0 = "#7fd47f"
                mT = "#6ec1ff"
            end
            nV_2 = (nV_2 + 36) % 52
        end
    else
        n1 = (vector.create((nV_2 * 7 + 8) % 11 + 1, (nV_2 * 7 + 13) % 13 + 1, (nV_2 * 13 + 15) % 17 + 1))
        local n2_6 = (vector.create((nV_2 * 2 + 3) % 11 + 1, (nV_2 * 2 + 12) % 13 + 1, (nV_2 * 2 + 11) % 17 + 1))
        n3 = (vector.create((nV_2 * 2 + 6) % 11 + 1, (nV_2 * 4 + 1) % 13 + 1, (nV_2 * 5 + 11) % 17 + 1))
        local n4_2 = (vector.create((nV_2 * 1 + 5) % 11 + 1, (nV_2 * 10 + 5) % 13 + 1, (nV_2 * 10 + 11) % 17 + 1))
        if vector.dot(vector.cross(n1, n2_6), (vector.cross(n3, n4_2))) == vector.dot(n1, n3) * vector.dot(n2_6, n4_2) - vector.dot(n1, n4_2) * vector.dot(n2_6, n3) + 5 then
            nZ = "#e8a34d"
        else
            mN = "#e8a34d"
        end
        nV_2 = (nV_2 + 10) % 52
    end
until (nV_2 * 3 + 28) % 52 == 47
n1 = {}
for k, v in CropConfig.Crops do
    local nV_3 = #n1 + 1
    local nW_2 = v.Order or 0
    n1[nV_3] = { name = k, order = nW_2, group = 0 }
end
for k, v in CropConfig.Animals do
    local nV_4 = #n1 + 1
    local nW_3 = v.Order or 0
    n1[nV_4] = { name = k, order = nW_3, group = 1 }
end
for k, v in CropConfig.Machines do
    local nV_5 = #n1 + 1
    local nW_4 = v.Order or 0
    n1[nV_5] = { name = k, order = nW_4, group = 2 }
end
local nX_5 = 3
repeat
    local xN = bit32.rrotate(bit32.bxor(bit32.lrotate(nX_5, 20), string.byte(tostring(nX_5))), 13)
    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(xN, 2199933739), 3129362963), (bit32.bxor(bit32.band(xN, 2095033556), 1978313360))), 3129362963), 1978313360) == xN then
        table.sort(n1, fn3)
    else
        table.sort(n1, fn3)
    end
    nX_5 = (nX_5 + 2) % 8
until (nX_5 * 5 + 5) % 8 == 6
for k, v in n1 do
    nj[#nj + 1] = v.name
    local name = v.name
    local nW_5 = v.group == 0 and v.order <= 1
    n0_1[name] = nW_5
end
local nV_7 = {}
local nW_6 = {}
local nX_6 = {}
for k, v in CropConfig.Animals do
    local nY_7 = #nX_6 + 1
    nZ = v.Order or 0
    nX_6[nY_7] = { name = k, order = nZ }
end
table.sort(nX_6, fn539)
for k, v in nX_6 do
    nW_6[#nW_6 + 1] = v.name
    nV_7[v.name] = true
end
ny = {}
for k in CropConfig.Produce do
    ny[#ny + 1] = k
end
table.sort(ny)
nk, Library = nil, nil
nk = {}
Library = getgenv().Library
if getgenv then
    getgenv().__TempoFarmersMarketLib = Library
end
ThemeManager, SaveManager, Toggles, Options, nB, nZ, mO, m4, nm, m5, nP, np, m8, nS, mZ, nQ, nr, mW, mJ, nM, nC, ng, nd, mL, mI, nv, m1, nw, m2, ne, nE, ni, nJ, mP, mS, mU, nU, nD, m_, ns, mV, n_ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
m4 = function()
    local function oW(aE)
        local oU = not aE or not aE:IsA("ScreenGui")
        if oU then
            return
        end
        aE.ResetOnSpawn = false
        aE.IgnoreGuiInset = true
        aE.DisplayOrder = math.max(aE.DisplayOrder, 1000)
        pcall(function()
            aE.ClipToDeviceSafeArea = false
        end)
        pcall(function()
            aE.ScreenInsets = Enum.ScreenInsets.None
        end)
        if aE.Parent ~= nl then
            aE.Parent = nl
        end
    end
    oW(Library.ScreenGui)
    if Library.ActiveLoading and Library.ActiveLoading.ScreenGui then
        oW(Library.ActiveLoading.ScreenGui)
    end
    for i, v in ipairs({ "Obsidian", "ObsidianLoading" }) do
        local oX_1 = nl:FindFirstChild(v) or PlayerGui:FindFirstChild(v)
        if oX_1 then
            oW(oX_1)
        end
    end
end
m4()
task.spawn(worker)
ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
nm = fn60
m5 = fn362
nP = fn813
np = fn494
m8 = fn104
nS = fn668
mZ = fn8
nQ = fn686
nr = fn342
mW = fn291
mJ = fn674
nM = fn386
nC = fn623
ng = fn490
nd = fn747
mL = fn670
mI = fn469
nB = {}
nv = fn178
m1 = fn146
nw = fn232
m2 = fn292
ne = function(di)
    local rq_1
    local rp_1
    local ro_1
    ro_1, rp_1, rq_1 = pcall(function()
        return CropConfig.FootprintFor(di, 0)
    end)
    local rr = ro_1 and type(rp_1) == "number" and type(rq_1) == "number"
    if rr then
        return rp_1, rq_1
    end
    return 1, 1
end
nE = fn552
ni = fn628
nJ = fn287
if m2 and not m2 and (m2 and not m2) or (not n_ and not n_ or not n_ and not m2) or not (m2 and not m2 and (m2 and not m2) or (not n_ and not n_ or not n_ and not m2)) then
    mP = fn519
    mS = fn560
    mU = fn715
else
    mU = fn519
    mP = fn560
    mS = fn715
end
nU = fn372
nD = fn439
m_ = fn742
ns = fn26
mV = fn774
if (mO and mW and (mO or not mW) and (not mO and mO or (not mZ or not m5)) or (not mO or not mZ) and (mW and not mO) and (mZ and not m5 or (mZ or mW)) or ((not mO or not m5 or (mW or not mZ)) and ((not mO or m5) and (mO and not mW)) or (mZ and mO and (mW or not mZ) or mO and m5 and (mZ or mO)))) and not (mO and mW and (mO or not mW) and (not mO and mO or (not mZ or not m5)) or (not mO or not mZ) and (mW and not mO) and (mZ and not m5 or (mZ or mW)) or ((not mO or not m5 or (mW or not mZ)) and ((not mO or m5) and (mO and not mW)) or (mZ and mO and (mW or not mZ) or mO and m5 and (mZ or mO)))) then
    no = nh:CreateWindow({
        Icon = 78539693571783,
        ShowCustomCursor = false,
        Animations = { TabSwitch = true },
        Font = Enum.Font.BuilderSans,
        TabSwipeFrom = "bottom",
        Title = "Tempo",
        NotifySide = "Right",
        CornerRadius = 0,
        Footer = { Library, { Text = nZ, Copyable = true }, "|" }
    })
else
    nZ = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = nh, Copyable = true }, "|", no },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
end
mO = {
    Info = nZ:AddTab("Info", "info"),
    Main = nZ:AddTab("Main", "sprout"),
    Player = nZ:AddTab("Player", "person-standing"),
    Settings = nZ:AddTab("Settings", "settings")
}
n_ = fn298
for k, v in mO do
    if k ~= "Info" then
        n_(v)
    end
end
n1 = mO.Main:AddLeftGroupbox("Farm", "wheat")
n1:AddToggle("AutoHarvest", { Text = "Auto Harvest Crops", Default = false })
n1:AddToggle("AutoStock", { Text = "Auto Stock", Default = false })
n1:AddToggle("AutoPlace", { Text = "Auto Place", Default = false })
n1:AddToggle("AutoBuildFarm", { Text = "Auto Build Farm", Default = false })
nZ = mO.Main:AddLeftGroupbox("Shop", "store")
nZ:AddToggle("AutoBuyShop", { Text = "Auto Buy Shop", Default = false })
nZ:AddDropdown("ShopItems", {
    Text = "Shop Items",
    Values = nj,
    Default = n0_1,
    Multi = true,
    Expandable = true,
    ExpandColumns = 2
})
nZ:AddToggle("AutoUpgradeBarn", { Text = "Auto Upgrade Barn", Default = false })
local AnimalsGroup = mO.Main:AddRightGroupbox("Animals", "paw-print")
AnimalsGroup:AddToggle("AutoCollectMilk", { Text = "Auto Collect Milk", Default = false })
AnimalsGroup:AddToggle("AutoFeedAnimals", { Text = "Auto Feed Animals", Default = false })
AnimalsGroup:AddDropdown("FeedAnimals", {
    Text = "Animals",
    Values = nW_6,
    Default = nV_7,
    Multi = true,
    Expandable = true,
    ExpandColumns = 2
})
n_ = function()
    local uO
    local uN
    uN = nil
    uO = nil
    local Label, Label2, Label3, uS, uT
    local function uU()
        local tZ = hookfunction ~= nil
        local t_ = hookmetamethod ~= nil
        local t0 = getrawmetatable ~= nil
        local t1 = setrawmetatable ~= nil
        local t2 = getgc ~= nil
        local t3 = getgenv ~= nil
        local t4 = getreg ~= nil
        local t5 = getconnections ~= nil
        local t6 = firesignal ~= nil
        local t7 = getcallbackvalue ~= nil
        local t8 = setclipboard ~= nil
        local t9 = getcustomasset ~= nil
        local ua = getnamecallmethod ~= nil
        local ub = isexecutorclosure ~= nil
        local uc = fireproximityprompt ~= nil
        local ud = firetouchinterest ~= nil
        local ue = WebSocket ~= nil
        local uf = readfile ~= nil
        local ug = writefile ~= nil
        local ui = (request or http_request) ~= nil
        local uk = (debug and debug.getupvalues) ~= nil
        local um = (debug and debug.setupvalue) ~= nil
        local un = 0
        local uo = { tZ, t_, t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, ua, ub, uc, ud, ue, uf, ug, ui, uk, um }
        for i, v in ipairs(uo) do
            if v then
                un += 1
            end
        end
        local tZ_1 = un / #uo
        if tZ_1 >= 0.9 then
            return nm("Full Support", m0)
        elseif tZ_1 >= 0.6 then
            return nm("Half Support", mN)
        else
            return nm("Low Support", nR)
        end
    end
    uN = "Unknown"
    pcall(function()
        local uA_1
        local uz_1
        if identifyexecutor then
            uA_1, uz_1 = identifyexecutor()
            local uB = uA_1 ~= ""
            local uC = type(uA_1) == "string" and uB
            if uC then
                local uB_1 = type(uz_1) == "string" and uz_1 ~= "" and uA_1 .. " " .. uz_1
                uN = uB_1 or uA_1
            end
        end
    end)
    local uV = uU()
    uO = os.clock()
    uS = function()
        local uH = math.floor(os.clock() - uO)
        if uH < 60 then
            return uH .. "s"
        elseif uH < 3600 then
            return string.format("%dm %ds", math.floor((uH) / (60)), uH % 60)
        else
            return string.format("%dh %dm", math.floor((uH) / (3600)), math.floor((uH % 3600) / (60)))
        end
    end
    local UserGroup = mO.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = mX, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(m5("User", mX.DisplayName .. " @" .. mX.Name, m0), true)
    UserGroup:AddLabel(m5("UserId", tostring(mX.UserId), mT), true)
    UserGroup:AddLabel(m5("Executor", uN .. "  " .. uV, m0), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(m5("Session", uS(), mN), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            nP(mX.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            nP("https://www.roblox.com/users/" .. tostring(mX.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = mO.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(m5("Game", no, mT), true)
    Label2 = SessionGroup:AddLabel(m5("Players", "0/0", m0), true)
    uT = tostring(game.JobId)
    local uV_1 = #uT > 18 and string.sub(uT, 1, 18) .. "..."
    local uV_2 = uV_1 or uT
    SessionGroup:AddLabel(m5("Job", uV_2, mH), true)
    Label = SessionGroup:AddLabel(m5("Ping", "0 ms", mN), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            na:Teleport(game.PlaceId, mX)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            nP(uT, "Copied Job ID")
        end
    })
    task.spawn(function()
        local uK_1
        local uJ_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(m5("Session", uS(), mN))
            Label2:SetText(m5("Players", #mG:GetPlayers() .. "/" .. tostring(mG.MaxPlayers), m0))
            uJ_1, uK_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local uJ_2 = uJ_1 and uK_1 .. " ms" or "n/a"
            Label:SetText(m5("Ping", uJ_2, mN))
        end
    end)
    local SocialsGroup = mO.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = np })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            nP(nb, "Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            nP(m7, "Copied website link")
        end
    })
end
local function n2_7()
    local MovementGroup = mO.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = mO.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local CurrentCamera = m3.CurrentCamera
    local connection
    local function g4(g5)
        pcall(function()
            nc:SetGameplayPausedNotificationEnabled(not g5)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = nl:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not g5
            end
        end)
        if not g5 then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(mX, "GameplayPaused", false)
            else
                mX.GameplayPaused = false
            end
        end)
    end
    local function hi(hj)
        local u4 = if not hj:IsA("ProximityPrompt") then 1 else 0
        if u4 == 1 then
            return
        end
        hj.HoldDuration = 0
        hj.MaxActivationDistance = 50
        hj.RequiresLineOfSight = false
    end
    nK.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if m8("NoClip") then
            local Character = mX.Character
            if Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    local u5_1 = descendant:IsA("BasePart") and descendant.CanCollide
                    if u5_1 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    nG.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if m8("InfJump") then
            local vd = mZ()
            if vd then
                vd:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    nK.RenderStepped:Connect(function(hA)
        if Library.Unloaded then
            return
        end
        local vl = if m8("WalkSpeedEnabled") then 1 else 0
        if vl == 1 then
            local vf_1 = mZ()
            if vf_1 then
                vf_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if m8("Fly") then
            local vf_2 = nQ()
            local vg = mZ()
            if vf_2 and vg then
                vg.PlatformStand = true
                local vg_1 = Vector3.zero
                if nG:IsKeyDown(Enum.KeyCode.W) then
                    vg_1 += CurrentCamera.CFrame.LookVector
                end
                if nG:IsKeyDown(Enum.KeyCode.S) then
                    vg_1 -= CurrentCamera.CFrame.LookVector
                end
                if nG:IsKeyDown(Enum.KeyCode.A) then
                    vg_1 -= CurrentCamera.CFrame.RightVector
                end
                if nG:IsKeyDown(Enum.KeyCode.D) then
                    vg_1 += CurrentCamera.CFrame.RightVector
                end
                if nG:IsKeyDown(Enum.KeyCode.Space) then
                    vg_1 += Vector3.new(0, 1, 0)
                end
                if nG:IsKeyDown(Enum.KeyCode.LeftControl) then
                    vg_1 -= Vector3.new(0, 1, 0)
                end
                vf_2.Velocity = Vector3.zero
                if vg_1.Magnitude > 0 then
                    vf_2.CFrame = vf_2.CFrame + vg_1.Unit * Options.FlySpeed.Value * hA
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local vm = mZ()
            if vm then
                vm.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local vo = mZ()
            if vo then
                vo.WalkSpeed = 16
            end
        end
    end)
    Toggles.AntiGameplayPause:OnChanged(function()
        g4(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                g4(true)
            end
        end
    end)
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in ipairs(m3:GetDescendants()) do
                pcall(hi, descendant)
            end
            connection = m3.DescendantAdded:Connect(function(h5)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(hi, h5)
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    Library:OnUnload(function()
        g4(false)
        if connection then
            connection:Disconnect()
        end
    end)
end
n_()
n2_7()
task.spawn(worker2)
n3 = function()
    local MenuGroup = mO.Settings:AddLeftGroupbox("Menu")
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    local iz = 0
    local iA = tick()
    local Label
    local function iC()
        local CurrentCamera = m3.CurrentCamera
        if not CurrentCamera then
            return
        end
        nz:CaptureController()
        nz:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        iz += 1
        iA = tick()
        if Label then
            pcall(function()
                Label:SetText("AFK triggers: " .. iz)
            end)
        end
    end
    local connection = mX.Idled:Connect(function()
        if m8("AntiAfk") then
            pcall(iC)
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
            local vH = m8("AntiAfk") and tick() - iA >= 60
            if vH then
                pcall(iC)
            end
        end
    end)
    Library:OnUnload(function()
        if connection then
            connection:Disconnect()
        end
        for k, v in nk do
            local vP = v
            pcall(function()
                vP:Disconnect()
            end)
        end
        table.clear(nk)
        if getgenv then
            getgenv().__TempoFarmersMarketLib = nil
        end
    end)
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("TempoHub")
    ThemeManager:SaveDefault("Evil Hello Kitty")
    ThemeManager:ApplyToTab(mO.Settings)
    ThemeManager:LoadDefault()
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    SaveManager:SetFolder("TempoHub/FarmersMarket")
    local i3 = SaveManager:BuildConfigSection(mO.Settings)
    local function i4(i5, i6)
        local vR = i5 == "Toggle" and Toggles
        local vW = if vR then 1 else 0
        local vU = 3466 * vW + 1332 * (1 - vW)
        local vV = 2036 * vW + 1728 * (1 - vW)
        if not ((vU * 1677 + vV * 3035 + vU * vV) % 16777213 == 2271305) then
            vR = Options
        end
        local vR_1 = vR[i6]
        local vQ_2 = type(vR_1) == "table" and vR_1.Type == i5
        return vQ_2 and vR_1 or nil
    end
    local function jd(je, jf)
        local Type = jf.Type
        if Type == "Toggle" then
            return { idx = je, type = "Toggle", value = jf.Value == true }
        elseif Type == "Slider" then
            return { idx = je, type = "Slider", value = tostring(jf.Value) }
        elseif Type == "Dropdown" then
            return { idx = je, type = "Dropdown", multi = jf.Multi == true, value = jf.Value }
        elseif Type == "Input" then
            local vY = jf.Value or ""
            return { idx = je, type = "Input", text = tostring(vY) }
        elseif Type == "ColorPicker" then
            return { idx = je, type = "ColorPicker", value = jf.Value:ToHex(), transparency = jf.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = je,
                type = "KeyPicker",
                mode = jf.Mode,
                key = jf.Value,
                modifiers = jf.Modifiers,
                toggled = jf.Toggled
            }
        else
            return nil
        end
    end
    local function jh()
        local v0 = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local v1 = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if v1 then
                    local v1_1 = jd(k, v)
                    if v1_1 then
                        v0[#v0 + 1] = v1_1
                    end
                end
            end
        end
        table.sort(v0, function(jr, js)
            if jr.type ~= js.type then
                return jr.type < js.type
            end
            return jr.idx < js.idx
        end)
        return { objects = v0 }
    end
    local function jt(ju)
        local wk
        wk = nil
        local wl = type(ju) ~= "table"
        local wp = if wl then 1 else 0
        local wn = 2497 * wp + 3430 * (1 - wp)
        local wo = 3275 * wp + 986 * (1 - wp)
        if not ((wn * 1723 + wo * 602 + wn * wo) % 16777213 == 14451556) then
            wl = type(ju.idx) ~= "string"
        end
        if not wl then
            wl = type(ju.type) ~= "string"
        end
        if not wl then
            wl = SaveManager.Ignore[ju.idx]
        end
        if wl then
            return false
        end
        wk = i4(ju.type, ju.idx)
        if not wk then
            return false
        end
        local wl_1 = pcall(function()
            if ju.type == "Input" then
                if type(ju.text) ~= "string" then
                    return
                end
                wk:SetValue(ju.text)
            elseif ju.type == "ColorPicker" then
                wk:SetValueRGB(Color3.fromHex(ju.value), ju.transparency)
            elseif ju.type == "KeyPicker" then
                wk:SetValue({ ju.key, ju.mode, ju.modifiers })
                if ju.mode == "Toggle" and ju.toggled ~= nil then
                    wk.Toggled = ju.toggled
                    wk:Update()
                end
            else
                wk:SetValue(ju.value)
            end
        end)
        return wl_1
    end
    i3:AddDivider()
    i3:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    i3:AddButton({
        Text = "Export Config to Clipboard",
        Func = function()
            local wr_1
            local wq_1
            wq_1, wr_1 = pcall(nt.JSONEncode, nt, jh())
            if not wq_1 then
                Library:Notify("Failed to encode the config")
                return
            end
            local wq_2 = setclipboard or toclipboard
            local wq_3 = type(wq_2) ~= "function" or not pcall(wq_2, wr_1)
            if wq_3 then
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Config copied to clipboard", 6)
        end
    })
    i3:AddButton({
        Text = "Import Config from Clipboard Text",
        Func = function()
            local ww_1
            local wu = Options.SaveManager_ImportSource.Value or ""
            local wu_1
            local wv = tostring(wu):match("^%s*(.-)%s*$")
            if wv == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            wu_1, ww_1 = pcall(nt.JSONDecode, nt, wv)
            local wv_1 = not wu_1 or type(ww_1) ~= "table" or type(ww_1.objects) ~= "table"
            if wv_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            local wu_2 = 0
            for i, v in ipairs(ww_1.objects) do
                if jt(v) then
                    wu_2 += 1
                end
            end
            if wu_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local ww_2 = wu_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(wu_2, ww_2), 6)
        end
    })
    SaveManager:LoadAutoloadConfig()
end
n3()
end)(...)

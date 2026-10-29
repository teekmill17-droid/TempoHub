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
getgenv().TempoHoodSubtitle = "STEAL FISH EGGS"
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
local Library
local o4
local pM
local PlacedEggs
local pa
local pz
local pg
local pY
local oY
local pF
local pm
local p3
local o3
local pL
local o9
local SpawnedEggs
local pf
local HatchEgg
local pE
local pl
local p2
local o2
local pK
local o8
local Options
local px
local pW
local oW
local pD
local pk
local EquipBestFish
local o1
local CoreGui
local Bases
local o7
local pP
local Workspace
local ClaimFishIndex
local pj
local p0
local o0
local pI
local LocalPlayer
local o6
local pv
local pc
local pB
local SellRequest
local o_
local pH
local Biomes
local o5
local pu
local Toggles
local ph
local RunService
local PlaceEgg
local pn
local function autoSellLoop()
    while not Library.Unloaded do
        if Toggles.AutoSell and Toggles.AutoSell.Value then
            pcall(pI)
        end
        local wait = task.wait
        local u5 = Options.SellDelay and Options.SellDelay.Value or 1
        wait(u5)
    end
end
local function fn41()
    return CoreGui
end
local function fn44(a2, a3)
    if setclipboard then
        setclipboard(a2)
    elseif toclipboard then
        toclipboard(a2)
    end
    Library:Notify(a3)
end
local function fn77(cc)
    local sr = o3()
    if not sr then
        return false
    end
    o5(sr)
    sr.CFrame = cc
    sr.AssemblyLinearVelocity = Vector3.zero
    return true
end
local function fn126()
    local tm = o3()
    if not tm then
        return {}
    end
    local Position = tm.Position
    local tm_1 = {}
    local to = o1
    for i, child in SpawnedEggs:GetChildren() do
        local tp = child:IsA("Model") and child:GetAttribute("PromptBusy") ~= true and not o0(child)
        if tp then
            local tp_1 = pM(child)
            local tq = pv(child)
            local tr = tp_1 and tp_1.Enabled and tq and pc(child)
            if tr then
                local tr_1 = #tm_1 + 1
                local Magnitude2 = (tq.Position - Position).Magnitude
                local Magnitude = (tq.Position - to).Magnitude
                local tu = o6[child:GetAttribute("Rarity")] or 0
                tm_1[tr_1] = {
                    Egg = child,
                    Prompt = tp_1,
                    Part = tq,
                    Distance = Magnitude2,
                    SafeDistance = Magnitude,
                    RarityRank = tu,
                    Enabled = true,
                    Biome = child:GetAttribute("Biome")
                }
            end
        end
    end
    return tm_1
end
local function autoBuyTrailsLoop()
    while not Library.Unloaded do
        if Toggles.AutoBuyTrails and Toggles.AutoBuyTrails.Value then
            pcall(p3)
        end
        local wait = task.wait
        local vc = Options.TrailBuyDelay and Options.TrailBuyDelay.Value or 2
        wait(vc)
    end
end
local function fn138(db)
    if not next(o_) then
        p2()
    end
    local s1 = o_[db]
    if not s1 then
        return false
    end
    pF(s1, 2)
    pg(s1 + Vector3.new(0, 6, 0))
    task.wait(0.2)
    return true
end
local function fn174(dJ)
    local tk = o4[dJ]
    if not tk then
        return false
    elseif os.clock() >= tk then
        o4[dJ] = nil
        return false
    else
        return true
    end
end
local function fn191(cQ)
    local attr3 = cQ:GetAttribute("Biome")
    local attr2 = cQ:GetAttribute("Rarity")
    local attr = cQ:GetAttribute("DisplayName")
    if not (Toggles.AutoStealSelected and Toggles.AutoStealSelected.Value) then
        return true
    end
    local Value3 = Options.StealZoneFilter.Value
    local Value2 = Options.StealRarityFilter.Value
    local Value = Options.StealSpecificEggs.Value
    local sU = type(Value3) == "table" and next(Value3) and not Value3[attr3]
    if sU then
        return false
    end
    local sO_1 = type(Value2) == "table" and next(Value2) and not Value2[attr2]
    if sO_1 then
        return false
    end
    local sO_2 = type(Value) == "table" and next(Value) and not Value[attr]
    if sO_2 then
        return false
    end
    return true
end
local function fn241()
    local attr = LocalPlayer:GetAttribute("BaseName")
    local rd = attr ~= ""
    local re = type(attr) == "string" and rd
    if re then
        return Bases:FindFirstChild(attr)
    end
    for i, child in Bases:GetChildren() do
        if tonumber(child:GetAttribute("OwnerUserId")) == LocalPlayer.UserId then
            return child
        end
    end
    return nil
end
local function autoEquipBestLoop()
    while not Library.Unloaded do
        local u8 = Options.FishActionDelay and Options.FishActionDelay.Value or 1
        if Toggles.AutoEquipBest and Toggles.AutoEquipBest.Value then
            pcall(function()
                EquipBestFish:FireServer()
            end)
        end
        if Toggles.AutoClaimIndex and Toggles.AutoClaimIndex.Value then
            pcall(function()
                ClaimFishIndex:FireServer("ALL")
            end)
        end
        task.wait(u8)
    end
end
local function fn271()
    local Character = LocalPlayer.Character
    if not Character then
        return nil
    end
    for i, child in Character:GetChildren() do
        if pl(child) then
            return child
        end
    end
    return nil
end
local function fn321()
    local Value2 = Options.SellMode.Value
    if Value2 == "Inventory" then
        return SellRequest:InvokeServer("SellInventory")
    elseif Value2 == "Equipped" then
        return SellRequest:InvokeServer("SellEquipped")
    else
        local Value = Options.SellRarityFilter.Value
        local ur = p0()
        if not ur then
            return nil
        end
        local us = false
        for k, v in ph() do
            if Library.Unloaded then
                break
            else
                local attr = v:GetAttribute("Rarity")
                local ut_1
                local uu = type(Value) ~= "table" or not next(Value) or Value[attr]
                local uu_1
                if uu then
                    if v.Parent == LocalPlayer.Backpack then
                        ur:EquipTool(v)
                        task.wait(0.12)
                    end
                    ut_1, uu_1 = pcall(function()
                        return SellRequest:InvokeServer("SellEquipped")
                    end)
                    local uv = ut_1 and type(uu_1) == "table" and uu_1.Success
                    if uv then
                        us = true
                    end
                    task.wait(0.2)
                end
            end
        end
        return us
    end
end
local function fn325(bT)
    local se = not bT or not bT:IsA("ProximityPrompt")
    if se then
        return
    end
    if bT.HoldDuration < pH then
        bT.HoldDuration = pH
    end
    bT.RequiresLineOfSight = false
end
local function fn331(a9)
    local DiscordGroup = a9:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = pu })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = pu })
end
local function fn386(b6)
    for k, v in { "TreadPoolTrainingPosition", "TreadPoolTrainingOrientation" } do
        local si = b6:FindFirstChild(v)
        if si and si.Enabled then
            si.Enabled = false
        end
    end
end
local function fn416()
    local Character = LocalPlayer.Character
    local rL = Character and Character:FindFirstChildOfClass("Humanoid")
    return rL
end
local function fn430()
    pg(o1, 20)
    local sK = CFrame.new(o1)
    local sL = os.clock() + 6
    while true do
        if not (os.clock() < sL) then
            return not pK()
        end
        if not pK() then
            break
        end
        local sM = Library.Unloaded or not pW(sK)
        if sM then
            return false
        end
        RunService.Heartbeat:Wait()
    end
    return true
end
local function fn444()
    table.clear(o_)
    table.clear(oY)
    local rp = o1
    local rq = Workspace:FindFirstChild("Biomes") or Biomes
    if not rq then
        return
    end
    for i, child in rq:GetChildren() do
        local rq_1 = child:IsA("Folder") and not string.find(child.Name, "IGNORE", 1, true)
        if rq_1 then
            local rr_1 = nil
            local EggSpawns = child:FindFirstChild("EggSpawns")
            if EggSpawns then
                for i, child in EggSpawns:GetChildren() do
                    local rs
                    if child:IsA("BasePart") then
                        rs = child
                    elseif child:IsA("Model") then
                        local rq_3 = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                        rs = rq_3
                    end
                    if rs then
                        rr_1 = rs.Position
                        break
                    end
                end
            end
            if not rr_1 then
                local BasePart = child:FindFirstChildWhichIsA("BasePart", true)
                if BasePart then
                    rr_1 = BasePart.Position
                end
            end
            if rr_1 then
                o_[child.Name] = rr_1
                oY[#oY + 1] = { Name = child.Name, Position = rr_1, SafeDistance = (rr_1 - rp).Magnitude }
            end
        end
    end
    table.sort(oY, function(ar, as)
        return ar.SafeDistance > as.SafeDistance
    end)
end
local function fn507()
    local t2 = pa()
    local t3 = o3()
    local t4 = p0()
    if not t2 or not t3 or not t4 then
        return false
    end
    local t3_2 = ph()
    if #t3_2 == 0 then
        return false
    end
    local t5_2 = false
    for k, v in t3_2 do
        if Library.Unloaded then
            break
        end
        if v.Parent == LocalPlayer.Backpack then
            t4:EquipTool(v)
            task.wait(0.12)
        end
        if oW() then
            pg(t2.Position + Vector3.new(0, 5, 0))
            local t3_3 = t2.CFrame:PointToWorldSpace(Vector3.new(0, t2.Size.Y * 0.5, 0))
            PlaceEgg:FireServer(t3_3)
            t5_2 = true
            task.wait(0.35)
        end
    end
    return t5_2
end
local function fn570()
    local uh = false
    for i, child in PlacedEggs:GetChildren() do
        if Library.Unloaded then
            break
        else
            local ui = child:IsA("Model") and tonumber(child:GetAttribute("OwnerUserId")) == LocalPlayer.UserId and child:GetAttribute("HatchReady") == true
            if ui then
                HatchEgg:FireServer(child)
                uh = true
                task.wait(0.2)
            end
        end
    end
    return uh
end
local function fn633()
    return LocalPlayer:GetAttribute("CarryingEgg") == true
end
local function fn655(di)
    local s7_1
    local s6_1
    if not next(o_) then
        p2()
    end
    local s3 = Options.StealZoneFilter and Options.StealZoneFilter.Value
    local s3_1 = Toggles.AutoStealSelected and Toggles.AutoStealSelected.Value
    local s5 = o1
    if s3_1 then
        s3_1 = type(s3) == "table"
    end
    if s3_1 then
        s3_1 = next(s3)
    end
    if s3_1 then
        s7_1, s6_1 = nil, nil
        for k in s3 do
            local s3_2 = o_[k]
            if s3_2 then
                local Magnitude = (s3_2 - s5).Magnitude
                local s3_3 = not s6_1
                if not s3_3 then
                    s3_3 = di == "Furthest" and Magnitude > s6_1
                end
                if not s3_3 then
                    s3_3 = di ~= "Furthest" and Magnitude < s6_1
                end
                if s3_3 then
                    s7_1, s6_1 = k, Magnitude
                end
            end
        end
        if s7_1 then
            pj(s7_1)
        end
        return
    end
    if di == "Furthest" or di == "Further" then
        local s3_5 = oY[1]
        if s3_5 then
            pj(s3_5.Name)
        end
    end
end
local function fn663(by)
    local rY = by:IsA("Tool") and type(by:GetAttribute("EggType")) == "string" and by:GetAttribute("Scale") ~= nil and by:GetAttribute("Kg") ~= nil
    return rY
end
local function fn691()
    local Character = LocalPlayer.Character
    local rI = Character and Character:FindFirstChild("HumanoidRootPart")
    return rI
end
local function fn714(eh)
    local tU = not eh
    local Prompt
    local tV = not o3() or tU
    local Part
    if tV then
        return false
    elseif pK() then
        return pE()
    else
        Part, Prompt = eh.Part, eh.Prompt
        local tW = not Part
        local t1 = if tW then 1 else 0
        local t_ = 3458 * t1 + 271 * (1 - t1)
        local t0 = 1297 * t1 + 2069 * (1 - t1)
        if not ((t_ * 3746 + t0 * 2488 + t_ * t0) % 16777213 == 3888417) then
            tW = not Part.Parent
        end
        if not tW then
            tW = not Prompt
        end
        local t1_1 = if tW then 1 else 0
        local t__1 = 2179 * t1_1 + 2207 * (1 - t1_1)
        local t0_1 = 3160 * t1_1 + 3603 * (1 - t1_1)
        if not ((t__1 * 996 + t0_1 * 3444 + t__1 * t0_1) % 16777213 == 3161751) then
            tW = not Prompt.Parent
        end
        if tW then
            return false
        end
        pF(Part.Position, 1)
        pB(Prompt)
        local tW_1 = Part.CFrame + Vector3.new(0, 4, 0)
        if not pg(tW_1.Position) then
            o4[eh.Egg] = os.clock() + o8
            return false
        end
        pn(Prompt)
        local tX = os.clock() + pH + 3
        while os.clock() < tX do
            if pK() then
                break
            end
            local tY = Library.Unloaded
            local t1_2 = if tY then 1 else 0
            local t__2 = 4057 * t1_2 + 2227 * (1 - t1_2)
            local t0_2 = 672 * t1_2 + 2427 * (1 - t1_2)
            if not ((t__2 * 2479 + t0_2 * 2875 + t__2 * t0_2) % 16777213 == 14715607) then
                tY = not Part.Parent
            end
            if not tY then
                tY = not Prompt.Enabled
            end
            if not tY then
                tY = not pW(tW_1)
            end
            if tY then
                break
            end
            RunService.Heartbeat:Wait()
        end
        if not pK() then
            o4[eh.Egg] = os.clock() + o8
            return false
        end
        return pE()
    end
end
local function fn756(bv)
    local rT = bv.PrimaryPart
    local rX = if rT then 1 else 0
    local rV = 2123 * rX + 2775 * (1 - rX)
    local rW = 1967 * rX + 1584 * (1 - rX)
    if not ((rV * 1750 + rW * 2711 + rV * rW) % 16777213 == 13223728) then
        rT = bv:FindFirstChild("PrimaryPart")
    end
    if not rT then
        rT = bv:FindFirstChildWhichIsA("BasePart")
    end
    return rT
end
local function fn775(br)
    local EggPrompt = br:FindFirstChild("EggPrompt", true)
    local rR = EggPrompt and EggPrompt:IsA("ProximityPrompt")
    if rR then
        return EggPrompt
    end
    return nil
end
local function fn780()
    local TpWalkSpeed = Options.TpWalkSpeed
    local sx = TpWalkSpeed and tonumber(TpWalkSpeed.Value)
    local sw_1 = sx
    if sx then
        sx = math.max(sw_1, 1)
    end
    local sw_2 = sx
    local sB = if sw_2 then 1 else 0
    local sz = 2638 * sB + 665 * (1 - sB)
    local sA = 272 * sB + 876 * (1 - sB)
    if not ((sz * 1962 + sA * 2291 + sz * sA) % 16777213 == 6516444) then
        sw_2 = pD
    end
    return sw_2
end
local function autoPlaceEggsLoop()
    while not Library.Unloaded do
        if Toggles.AutoPlaceEggs and Toggles.AutoPlaceEggs.Value then
            pP()
        end
        if Toggles.AutoHatch and Toggles.AutoHatch.Value then
            o2()
        end
        local u__2 = task.wait
        local u1 = Options.EggActionDelay and Options.EggActionDelay.Value or 0.4
        u__2(u1)
    end
end
local function onDescendantAdded(f3)
    local uY = f3:IsA("ProximityPrompt") and f3.Name == "EggPrompt"
    if uY then
        pB(f3)
    end
end
local function fn968()
    local rm = pk()
    local rn = rm and rm:FindFirstChild("EggPlacementZone")
    return rn
end
local function autoStealAllLoop()
    while not Library.Unloaded do
        if Toggles.AutoStealAll and Toggles.AutoStealAll.Value or Toggles.AutoStealSelected and Toggles.AutoStealSelected.Value then
            if pK() then
                pE()
            else
                local uV_1 = Options.StealPriority and Options.StealPriority.Value or "Nearest"
                local uV_2 = pY()
                if #uV_2 == 0 then
                    o7(uV_1)
                    uV_2 = pY()
                end
                local uW_1 = o9(uV_2)
                if uW_1 then
                    px(uW_1)
                else
                    if uV_1 == "Furthest" or uV_1 == "Further" then
                        o7(uV_1)
                    end
                end
            end
        end
        local uV_4 = Options.StealDelay and Options.StealDelay.Value or 0.05
        if uV_4 > 0 then
            task.wait(uV_4)
        else
            task.wait()
        end
    end
end
local function fn1009()
    pL(pf, "Copied Discord invite to clipboard")
end
local function fn1023(cp, cq)
    if typeof(cp) ~= "Vector3" then
        return false
    end
    local sC = os.clock()
    local sE = sC + (cq or 15)
    while true do
        if not (os.clock() < sE) then
            return false
        end
        if Library.Unloaded then
            break
        end
        local sC_1 = o3()
        if not sC_1 then
            return false
        end
        o5(sC_1)
        local sD_1 = pz()
        local sF = math.max(2, sD_1 * 0.1)
        local sG = cp - sC_1.Position
        local Magnitude = sG.Magnitude
        if Magnitude <= sF then
            sC_1.CFrame = CFrame.new(cp)
            sC_1.AssemblyLinearVelocity = Vector3.zero
            return true
        end
        local sI = RunService.Heartbeat:Wait()
        sC_1.CFrame = CFrame.new(sC_1.Position + sG.Unit * math.min(sF, sD_1 * sI, Magnitude), cp)
        sC_1.AssemblyLinearVelocity = Vector3.zero
    end
    return false
end
oW = nil
HatchEgg = nil
oY = nil
PlaceEgg = nil
o_ = nil
o0 = nil
o1 = nil
o2 = nil
o3 = nil
o4 = nil
o5 = nil
o6 = nil
o7 = nil
o8 = nil
o9 = nil
pa = nil
pc = nil
pf = nil
pg = nil
ph = nil
pj = nil
pk = nil
pl = nil
pm = nil
pn = nil
Biomes = nil
LocalPlayer = nil
Bases = nil
PlacedEggs = nil
pu = nil
pv = nil
Workspace = nil
px = nil
SpawnedEggs = nil
pz = nil
pB = nil
pD = nil
pE = nil
pF = nil
pH = nil
local Players, pb, pd, pe, pi, pr, Lighting, TeleportService, TrailConfig, GuiService
pI = nil
CoreGui = nil
pK = nil
pL = nil
pM = nil
pP = nil
Options = nil
Toggles = nil
ClaimFishIndex = nil
pW = nil
pY = nil
RunService = nil
SellRequest = nil
p0 = nil
EquipBestFish = nil
p2 = nil
p3 = nil
Library = nil
local HttpService, GetTrailShopState, VirtualUser, BuyTrailCash, UserInputService, SaveManager
local EggRarityConfig
HttpService = nil
GetTrailShopState = nil
VirtualUser = nil
BuyTrailCash = nil
UserInputService = nil
SaveManager = nil
Players, RunService, UserInputService, VirtualUser, HttpService, CoreGui, GuiService, TeleportService, Workspace, Lighting, LocalPlayer, pm = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local yl_16_1
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
CoreGui = game:GetService("CoreGui")
GuiService = game:GetService("GuiService")
TeleportService = game:GetService("TeleportService")
Workspace = game:GetService("Workspace")
Lighting = game:GetService("Lighting")
LocalPlayer = Players.LocalPlayer
pm = fn41
if getgenv then
    getgenv().gethui = pm
end
pcall(function()
    gethui = pm
end)
if setthreadidentity then
    setthreadidentity(8)
end
pi, pf, pe, pb, PlaceEgg, HatchEgg, EquipBestFish, SellRequest, ClaimFishIndex, BuyTrailCash, GetTrailShopState, EggRarityConfig, TrailConfig, SpawnedEggs, PlacedEggs, Bases, Biomes, o1, o_, oY, o6, pk, pa, p2 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pi = "Steal Fish Eggs"
pf = "https://discord.gg/K7Qxnxkk46"
pe = "https://discord.gg/K7Qxnxkk46"
pb = "https://tempohub.shop"
local EggSystem = ReplicatedStorage:WaitForChild("EggSystem")
local FishSystem = ReplicatedStorage:WaitForChild("FishSystem")
local SellSystem = ReplicatedStorage:WaitForChild("SellSystem")
local yl_11_1
local FishIndexSystem = ReplicatedStorage:WaitForChild("FishIndexSystem")
local yl_5_1
local TrailSystem = ReplicatedStorage:WaitForChild("TrailSystem")
PlaceEgg = EggSystem:WaitForChild("PlaceEgg")
HatchEgg = EggSystem:WaitForChild("HatchEgg")
EquipBestFish = FishSystem:WaitForChild("EquipBestFish")
SellRequest = SellSystem:WaitForChild("SellRequest")
ClaimFishIndex = FishIndexSystem:WaitForChild("ClaimFishIndex")
BuyTrailCash = TrailSystem:WaitForChild("BuyTrailCash")
GetTrailShopState = TrailSystem:WaitForChild("GetTrailShopState")
local EggConfig = require(EggSystem:WaitForChild("EggConfig"))
if (ClaimFishIndex and EggSystem and (pf or FishIndexSystem) and (HatchEgg and pf and (FishIndexSystem and EggSystem)) and (HatchEgg and ClaimFishIndex and (HatchEgg and false) or (not ClaimFishIndex and ClaimFishIndex or not HatchEgg and not ClaimFishIndex)) or (not EggSystem or PlacedEggs) and (not HatchEgg or not EggSystem) and (not ClaimFishIndex or FishIndexSystem or false) and ((pf and not HatchEgg or (FishIndexSystem or FishIndexSystem)) and ((HatchEgg or ClaimFishIndex) and (HatchEgg or ClaimFishIndex)))) and not (ClaimFishIndex and EggSystem and (pf or FishIndexSystem) and (HatchEgg and pf and (FishIndexSystem and EggSystem)) and (HatchEgg and ClaimFishIndex and (HatchEgg and false) or (not ClaimFishIndex and ClaimFishIndex or not HatchEgg and not ClaimFishIndex)) or (not EggSystem or PlacedEggs) and (not HatchEgg or not EggSystem) and (not ClaimFishIndex or FishIndexSystem or false) and ((pf and not HatchEgg or (FishIndexSystem or FishIndexSystem)) and ((HatchEgg or ClaimFishIndex) and (HatchEgg or ClaimFishIndex)))) then
    require(EggRarityConfig:WaitForChild("EggRarityConfig"))
else
    EggRarityConfig = require(EggSystem:WaitForChild("EggRarityConfig"))
end
TrailConfig = require(TrailSystem:WaitForChild("TrailConfig"))
SpawnedEggs = Workspace:WaitForChild("SpawnedEggs")
PlacedEggs = Workspace:WaitForChild("PlacedEggs")
Bases = Workspace:WaitForChild("Bases")
Biomes = Workspace:FindFirstChild("Biomes")
pk = fn241
pa = fn968
o1 = Vector3.new(32, 119, -47)
o_ = {}
oY = {}
p2 = fn444
p2()
local RarityOrder = EggRarityConfig.RarityOrder
o6 = {}
for k, v in RarityOrder do
    o6[v] = k
end
yl_5_1, yl_11_1, yl_16_1 = nil, nil, nil
local yl_9_1 = 16
repeat
    local p9_1 = (yl_9_1 * 1 + 1) % 3 + 1
    if p9_1 <= 2 then
        if p9_1 <= 1 then
            if (yl_9_1 * 3 + 7) * 5 % 4 == ((yl_9_1 * 3 + 7) * 5 + 6) % 4 then
                yl_5_1 = {}
            else
                yl_11_1 = {}
            end
            yl_9_1 = (yl_9_1 + 1) % 24
        else
            if (yl_9_1 * 3 + 8) * 21 % 4 == ((yl_9_1 * 3 + 8) * 21 + 4) % 4 then
                yl_16_1 = {}
            else
                yl_5_1 = {}
            end
            yl_9_1 = (yl_9_1 + 19) % 24
        end
    else
        local z3 = bit32.rrotate(bit32.bxor(bit32.lrotate(yl_9_1, 13), string.byte(tostring(yl_5_1))), 18)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(z3, 4155759181), 2025821220), (bit32.bxor(bit32.band(z3, 139208114), 3157814951))), 2025821220), 3157814951) == z3 then
            yl_5_1 = {}
        else
            yl_16_1 = {}
        end
        yl_9_1 = (yl_9_1 + 1) % 24
    end
until (yl_9_1 * 19 + 12) % 24 == 19
local p9_2 = {}
for k, v in EggConfig.Biomes do
    yl_5_1[#yl_5_1 + 1] = k
    if type(v.Eggs) == "table" then
        for k2, v in v.Eggs do
            if type(v) == "table" then
                local yl_9_2 = v.DisplayName or v.ModelName
                local yl_9_3 = type(yl_9_2) == "string" and yl_9_2 ~= "" and not p9_2[yl_9_2]
                if yl_9_3 then
                    p9_2[yl_9_2] = true
                    yl_11_1[#yl_11_1 + 1] = yl_9_2
                    yl_16_1[yl_9_2] = { ModelName = v.ModelName, Rarity = v.Rarity, Biome = k, ToolName = v.ToolName, SaveId = v.SaveId }
                end
            end
        end
    end
end
local yl_9_4 = 0
repeat
    local yl_16_2 = {
        "rfgno",
        "ehyjlvt",
        "hdxbhxxdwf",
        "ksvrpfzoyrx",
        "rcukccxpht",
        "bywjojap",
        "myhms",
        "dqcq",
        "mffjzfgqh",
        "hyun"
    }
    if yl_16_2[(yl_9_4 * 94 + 46) % 10 + 1] <= yl_16_2[(yl_9_4 * 94 + 46) % 10 + 1] then
        table.sort(yl_5_1)
        table.sort(yl_11_1)
    else
        table.sort(yl_11_1)
        table.sort(yl_5_1)
    end
    yl_9_4 = (yl_9_4 + 2) % 4
until (yl_9_4 * 3 + 3) % 4 == 1
pr = {}
for k, v in TrailConfig.RarityOrder do
    pr[#pr + 1] = v
end
local qa_2 = { "Nearest", "Rarest", "Random", "Furthest" }
local p9_3 = { "Inventory", "Equipped", "Filtered Eggs" }
local yl_16_3 = {}
for k, v in RarityOrder do
    yl_16_3[v] = true
end
local yl_9_5 = {}
for k, v in yl_5_1 do
    yl_9_5[v] = true
end
local qb_2 = {}
for k, v in pr do
    qb_2[v] = true
end
Library, SaveManager, Toggles, Options, pd, pL, pu, o3, p0, pM, pv, pl, ph, oW = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
pL = fn44
pu = fn1009
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = pf, Copyable = true }, "|", pi },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    SidebarCompacted = true,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
local qf_1
pd = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "egg"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
local ql = pd.Main:AddSubTab("Steal", "swords")
local qk = pd.Main:AddSubTab("Eggs", "egg")
local qj = pd.Main:AddSubTab("Fish", "fish")
local qi = pd.Main:AddSubTab("Shop", "shopping-bag")
fn331(ql)
fn331(qk)
fn331(qj)
fn331(qi)
fn331(pd.Player)
fn331(pd.Settings)
o3 = fn691
p0 = fn416
pM = fn775
pv = fn756
pl = fn663
if (not Toggles or Library or Library and not Toggles) and (not Toggles or false or (Toggles or not Toggles)) or not ((not Toggles or Library or Library and not Toggles) and (not Toggles or false or (Toggles or not Toggles))) then
    ph = function()
        local bB = {}
        local function bC(bD)
            if not bD then
                return
            end
            for i, child in bD:GetChildren() do
                if pl(child) then
                    bB[#bB + 1] = child
                end
            end
        end
        bC(LocalPlayer:FindFirstChild("Backpack"))
        bC(LocalPlayer.Character)
        return bB
    end
else
    qk = function()
        local bB = {}
        local function bC(bD)
            if not bD then
                return
            end
            for i, child in bD:GetChildren() do
                if pl(child) then
                    bB[#bB + 1] = child
                end
            end
        end
        bC(LocalPlayer:FindFirstChild("Backpack"))
        bC(LocalPlayer.Character)
        return bB
    end
end
oW = fn271
local qc = EggConfig.Settings and EggConfig.Settings.PromptHoldDuration
local qd_1 = tonumber(qc) or 1
pH, pD, o8, o4, qf_1, pB, pn, o5, pW, pz, pg, pK, pE, pc, pF, pj, o7, o0, pY, o9, px, pP, o2, pI, p3 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pH = qd_1
pB = fn325
pn = function(bX)
    task.spawn(function()
        task.wait(0.25)
        if Library.Unloaded or not bX.Parent then
            return
        end
        pcall(function()
            bX:InputHoldBegin()
            task.wait(math.max(bX.HoldDuration, pH) + 0.35)
            bX:InputHoldEnd()
        end)
    end)
end
o5 = fn386
pW = fn77
pD = 150
pz = fn780
pg = fn1023
pK = fn633
pE = fn430
pc = fn191
pF = function(c4, c5)
    if typeof(c4) ~= "Vector3" then
        return
    end
    pcall(function()
        local sZ = c5 or 2
        LocalPlayer:RequestStreamAroundAsync(c4, sZ)
    end)
end
if (not pj and not o7 and (not pH and o7) or (false and pH or (pz or not o7))) and ((not pz or pF) and (not pH and pj) or (pj or pF or (pF or not qf_1))) and not ((not pj and not o7 and (not pH and o7) or (false and pH or (pz or not o7))) and ((not pz or pF) and (not pH and pj) or (pj or pF or (pF or not qf_1)))) then
    o7 = fn138
    o8 = fn655
    pj = 6
else
    pj = fn138
    o7 = fn655
    o8 = 6
end
if (not o5 or not px or not px and px or o5 and not o5 and (not o5 and o5)) and (not o5 and o5 and (not o5 and not px) or (not o5 or px) and (not px and not px)) and not ((not o5 or not px or not px and px or o5 and not o5 and (not o5 and o5)) and (not o5 and o5 and (not o5 and not px) or (not o5 or px) and (not px and not px))) then
    o0 = {}
    pY = fn174
    o4 = fn126
else
    o4 = {}
    o0 = fn174
    pY = fn126
end
o9 = function(d4)
    local Value
    Value = nil
    if #d4 == 0 then
        return nil
    end
    Value = Options.StealPriority.Value
    if Value == "Random" then
        return d4[math.random(1, #d4)]
    end
    if Value == "Furthest" or Value == "Further" then
        local tH_1 = d4[1]
        local tI_1 = #d4
        local tO = 2
        while tO <= tI_1 do
            local tI_2 = d4[tO]
            if tI_2.SafeDistance > tH_1.SafeDistance or tI_2.SafeDistance == tH_1.SafeDistance and tI_2.RarityRank > tH_1.RarityRank then
                tH_1 = tI_2
            end
            tO += 1
        end
        return tH_1
    end
    table.sort(d4, function(ed, ee)
        if Value == "Rarest" then
            if ed.RarityRank ~= ee.RarityRank then
                return ed.RarityRank > ee.RarityRank
            elseif ed.Enabled ~= ee.Enabled then
                return ed.Enabled
            else
                return ed.Distance < ee.Distance
            end
        elseif ed.Distance ~= ee.Distance then
            return ed.Distance < ee.Distance
        else
            return ed.RarityRank > ee.RarityRank
        end
    end)
    return d4[1]
end
px = fn714
pP = fn507
o2 = fn570
pI = fn321
p3 = function()
    local uH_1
    local uI_1
    local Value = Options.TrailBuyFilter.Value
    uH_1, uI_1 = pcall(function()
        return GetTrailShopState:InvokeServer()
    end)
    local uJ = uH_1 and type(uI_1) == "table" and uI_1.Owned
    local uI_2 = uJ or {}
    local uH_3 = 0
    local Stats = LocalPlayer:FindFirstChild("Stats")
    local uK = Stats and Stats:FindFirstChild("Cash")
    local uK_5
    if uK then
        local uK_1 = tonumber(uK.Value) or 0
        uH_3 = uK_1
    end
    for k, v in pr do
        local uT = v
        if Library.Unloaded then
            break
        else
            local uK_2 = type(Value) ~= "table" or not next(Value) or Value[uT]
            local uL = uK_2 and not uI_2[uT]
            local uL_3
            if uL then
                local uK_3 = TrailConfig.GetShopData(uT)
                local uL_1 = uK_3 and tonumber(uK_3.CashPrice)
                if uH_3 >= (uL_1 or math.huge) then
                    uK_5, uL_3 = pcall(function()
                        return BuyTrailCash:InvokeServer(uT)
                    end)
                    local uM = uK_5 and type(uL_3) == "table"
                    if uM then
                        if uK then
                            local uK_6 = tonumber(uK.Value) or uH_3
                            uH_3 = uK_6
                        end
                    end
                    task.wait(0.25)
                end
            end
        end
    end
end
local AutoStealGroup = ql:AddLeftGroupbox("Auto Steal", "swords")
local qp = AutoStealGroup:AddTabbox()
local Tab = qp:AddTab("", "globe")
Tab:AddToggle("AutoStealAll", { Text = "Auto Steal All", Default = false })
Tab:AddDropdown("StealPriority", { Text = "Priority", Values = qa_2, Default = 1 })
local Tab = qp:AddTab("", "list-filter")
Tab:AddToggle("AutoStealSelected", { Text = "Auto Steal Selected", Default = false })
Tab:AddDropdown("StealZoneFilter", { Text = "Zone Filter", Values = yl_5_1, Multi = true, Default = yl_9_5 })
Tab:AddDropdown("StealRarityFilter", { Text = "Rarity Filter", Values = RarityOrder, Multi = true, Default = yl_16_3 })
Tab:AddDropdown("StealSpecificEggs", { Text = "Specific Eggs", Values = yl_11_1, Multi = true, Default = {}, Searchable = true })
AutoStealGroup:AddSlider("TpWalkSpeed", { Text = "TP Walk Speed", Default = 150, Min = 16, Max = 500, Rounding = 0 })
AutoStealGroup:AddSlider("StealDelay", { Text = "Steal Delay", Default = 0.05, Min = 0, Max = 3, Rounding = 2 })
local EggsGroup = qk:AddLeftGroupbox("Eggs", "egg")
EggsGroup:AddToggle("AutoPlaceEggs", { Text = "Auto Place Eggs", Default = false })
EggsGroup:AddToggle("AutoHatch", { Text = "Auto Hatch", Default = false })
EggsGroup:AddSlider("EggActionDelay", { Text = "Action Delay", Default = 0.4, Min = 0.1, Max = 3, Rounding = 2 })
local SellGroup = qk:AddRightGroupbox("Sell", "badge-dollar-sign")
SellGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
SellGroup:AddDropdown("SellMode", { Text = "Sell Mode", Values = p9_3, Default = 1 })
SellGroup:AddDropdown("SellRarityFilter", { Text = "Sell Rarities", Values = RarityOrder, Multi = true, Default = yl_16_3 })
SellGroup:AddSlider("SellDelay", { Text = "Sell Delay", Default = 1, Min = 0.25, Max = 10, Rounding = 2 })
local FishGroup = qj:AddLeftGroupbox("Fish", "fish")
FishGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
FishGroup:AddToggle("AutoClaimIndex", { Text = "Auto Claim Index", Default = false })
FishGroup:AddSlider("FishActionDelay", { Text = "Action Delay", Default = 1, Min = 0.25, Max = 10, Rounding = 2 })
local TrailsGroup = qi:AddLeftGroupbox("Trails", "footprints")
TrailsGroup:AddToggle("AutoBuyTrails", { Text = "Auto Buy Trails", Default = false })
TrailsGroup:AddDropdown("TrailBuyFilter", { Text = "Trail Rarities", Values = pr, Multi = true, Default = qb_2 })
TrailsGroup:AddSlider("TrailBuyDelay", { Text = "Buy Delay", Default = 2, Min = 0.5, Max = 15, Rounding = 2 })
task.spawn(autoStealAllLoop)
for i, descendant in SpawnedEggs:GetDescendants() do
    local yl_9_6 = descendant:IsA("ProximityPrompt") and descendant.Name == "EggPrompt"
    if yl_9_6 then
        pB(descendant)
    end
end
SpawnedEggs.DescendantAdded:Connect(onDescendantAdded)
task.spawn(autoPlaceEggsLoop)
task.spawn(autoSellLoop)
task.spawn(autoEquipBestLoop)
task.spawn(autoBuyTrailsLoop)
local function yl_5_2()
    local v2
    local v0
    local vX
    local v3
    local v1
    local vY
    vX = nil
    vY = nil
    v0 = nil
    v1 = nil
    v2 = nil
    v3 = nil
    local vZ, Label, v4, v5, Label2, Label3
    v3 = function(gD, gE)
        return string.format('<font color="%s">%s</font>', gE, gD)
    end
    v5 = function(gG, gH, gI)
        return string.format("<b>%s</b> %s %s", gG, v3("-", "#5a6070"), v3(gH, gI))
    end
    v0 = "#e8a34d"
    local v8 = "#8b93a3"
    vX = "#e05a5a"
    v2 = "#7fd47f"
    local function wa()
        local ve = hookfunction ~= nil
        local vf = hookmetamethod ~= nil
        local vg = getrawmetatable ~= nil
        local vh = setrawmetatable ~= nil
        local vi = getgc ~= nil
        local vj = getgenv ~= nil
        local vk = getreg ~= nil
        local vl = getconnections ~= nil
        local vm = firesignal ~= nil
        local vn = getcallbackvalue ~= nil
        local vo = setclipboard ~= nil
        local vp = getcustomasset ~= nil
        local vq = getnamecallmethod ~= nil
        local vr = isexecutorclosure ~= nil
        local vs = fireproximityprompt ~= nil
        local vt = firetouchinterest ~= nil
        local vu = WebSocket ~= nil
        local vv = readfile ~= nil
        local vw = writefile ~= nil
        local vy = (request or http_request) ~= nil
        local vA = (debug and debug.getupvalues) ~= nil
        local vC = (debug and debug.setupvalue) ~= nil
        local vD = 0
        local vE = { ve, vf, vg, vh, vi, vj, vk, vl, vm, vn, vo, vp, vq, vr, vs, vt, vu, vv, vw, vy, vA, vC }
        for i, v in ipairs(vE) do
            if v then
                vD += 1
            end
        end
        local ve_1 = vD / #vE
        if ve_1 >= 0.9 then
            return v3("Full Support", v2)
        elseif ve_1 >= 0.6 then
            return v3("Half Support", v0)
        else
            return v3("Low Support", vX)
        end
    end
    vY = "Unknown"
    pcall(function()
        local vN_1
        local vM_1
        if identifyexecutor then
            vN_1, vM_1 = identifyexecutor()
            local vO = vN_1 ~= ""
            local vP = type(vN_1) == "string" and vO
            if vP then
                local vO_1 = type(vM_1) == "string" and vM_1 ~= "" and vN_1 .. " " .. vM_1
                vY = vO_1 or vN_1
            end
        end
    end)
    local wb = wa()
    v1 = os.clock()
    v4 = function()
        local vR = math.floor(os.clock() - v1)
        if vR < 60 then
            return vR .. "s"
        elseif vR < 3600 then
            return string.format("%dm %ds", math.floor((vR) / (60)), vR % 60)
        else
            return string.format("%dh %dm", math.floor((vR) / (3600)), math.floor((vR % 3600) / (60)))
        end
    end
    local UserGroup = pd.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(v5("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, v2), true)
    UserGroup:AddLabel(v5("UserId", tostring(LocalPlayer.UserId), "#6ec1ff"), true)
    UserGroup:AddLabel(v5("Executor", vY .. "  " .. wb, v2), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(v5("Session", v4(), v0), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            pL(LocalPlayer.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            pL("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = pd.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(v5("Game", pi, "#6ec1ff"), true)
    Label2 = SessionGroup:AddLabel(v5("Players", "0/0", v2), true)
    vZ = tostring(game.JobId)
    local v9 = #vZ > 18 and string.sub(vZ, 1, 18) .. "..."
    local wb_1 = v9 or vZ
    SessionGroup:AddLabel(v5("Job", wb_1, v8), true)
    Label = SessionGroup:AddLabel(v5("Ping", "0 ms", v0), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            pL(vZ, "Copied Job ID")
        end
    })
    task.spawn(function()
        local vU_1
        local vT_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(v5("Session", v4(), v0))
            Label2:SetText(v5("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), v2))
            vT_1, vU_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local vT_2 = vT_1 and vU_1 .. " ms" or "n/a"
            Label:SetText(v5("Ping", vT_2, v0))
        end
    end)
    local SocialsGroup = pd.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = pu })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            pL(pe, "Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            pL(pb, "Copied website link")
        end
    })
end
local function yl_9_7()
    local connection
    local MovementGroup = pd.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = pd.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    RunService.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = LocalPlayer.Character
            if Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    local wd_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if wd_2 then
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
            local wo_1 = p0()
            if wo_1 then
                wo_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    local CurrentCamera = Workspace.CurrentCamera
    RunService.RenderStepped:Connect(function(ih)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local wq_1 = p0()
            if wq_1 then
                wq_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local wq_3 = o3()
            local wr = p0()
            if wq_3 and wr then
                wr.PlatformStand = true
                local wr_1 = Vector3.zero
                local ww = if UserInputService:IsKeyDown(Enum.KeyCode.W) then 1 else 0
                if ww == 1 then
                    wr_1 += CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    wr_1 -= CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    wr_1 -= CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    wr_1 += CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    wr_1 += Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    wr_1 -= Vector3.new(0, 1, 0)
                end
                wq_3.AssemblyLinearVelocity = Vector3.zero
                if wr_1.Magnitude > 0 then
                    wq_3.CFrame = wq_3.CFrame + wr_1.Unit * Options.FlySpeed.Value * ih
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local wx = p0()
            if wx then
                wx.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local wz = p0()
            if wz then
                wz.WalkSpeed = 16
            end
        end
    end)
    local function iE(iF)
        if not iF:IsA("ProximityPrompt") then
            return
        end
        if iF.Name == "EggPrompt" then
            return
        end
        iF.HoldDuration = 0
        iF.MaxActivationDistance = 50
        iF.RequiresLineOfSight = false
    end
    connection = nil
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in ipairs(Workspace:GetDescendants()) do
                pcall(iE, descendant)
            end
            connection = Workspace.DescendantAdded:Connect(function(iN)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(iE, iN)
                end
            end)
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
local function qa_3()
    local MenuGroup = pd.Settings:AddLeftGroupbox("Menu", "logs")
    local iU = 0
    local iV = tick()
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = MenuGroup:AddLabel("AFK triggers: 0")
    local function iX()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then
            return
        end
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        iU += 1
        iV = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. iU)
        end)
    end
    local connection2 = LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(iX)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local wR = Toggles.AntiAfk.Value and tick() - iV >= 60
            if wR then
                pcall(iX)
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
    local function jj(jk)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not jk)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not jk
            end
        end)
        if not jk then
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
    Toggles.AntiGameplayPause:OnChanged(function()
        jj(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                jj(true)
            end
        end
    end)
    local jB = false
    local function jC()
        local PlaceId, JobId
        if jB then
            return
        end
        jB = true
        PlaceId, JobId = game.PlaceId, game.JobId
        local w2 = pcall(function()
            TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
        end)
        if not w2 then
            pcall(function()
                TeleportService:Teleport(PlaceId, LocalPlayer)
            end)
        end
    end
    task.spawn(function()
        local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
        local xa = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
        if not xa then
            return
        end
        xa.ChildAdded:Connect(function(jU)
            if Library.Unloaded then
                return
            end
            if Toggles.AutoReconnect.Value and jU.Name == "ErrorPrompt" then
                jC()
            end
        end)
    end)
    TeleportService.TeleportInitFailed:Connect(function()
        if Toggles.AutoReconnect.Value then
            jB = false
            jC()
        end
    end)
    Toggles.Disable3D:OnChanged(function()
        pcall(function()
            RunService:Set3dRenderingEnabled(not Toggles.Disable3D.Value)
        end)
    end)
    local j9 = {
        ParticleEmitter = true,
        Trail = true,
        Smoke = true,
        Fire = true,
        Sparkles = true,
        Explosion = true,
        Beam = true
    }
    local function ka(kb)
        if j9[kb.ClassName] then
            pcall(function()
                kb.Enabled = false
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
                Lighting.GlobalShadows = false
            end)
            pcall(function()
                Lighting.FogEnd = 9000000000
            end)
            for i, descendant in ipairs(Workspace:GetDescendants()) do
                pcall(ka, descendant)
            end
            connection = Workspace.DescendantAdded:Connect(function(kq)
                if Toggles.FpsBoost.Value then
                    pcall(ka, kq)
                end
            end)
        else
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            end)
            pcall(function()
                Lighting.GlobalShadows = true
            end)
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end)
    local ScriptGroup = pd.Settings:AddLeftGroupbox("Script", "terminal")
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
        jj(false)
        pcall(function()
            RunService:Set3dRenderingEnabled(true)
        end)
        if connection then
            connection:Disconnect()
        end
        local xm = o3()
        if xm then
            xm.Anchored = false
        end
        local xm_1 = p0()
        if xm_1 then
            xm_1.PlatformStand = false
            xm_1.WalkSpeed = 16
        end
    end)
end
local function yl_16_4(kI)
    local function kJ(kK, kL)
        local xs_1 = (kK == "Toggle" and Toggles or Options)[kL]
        local xr_2 = type(xs_1) == "table" and xs_1.Type == kK
        return xr_2 and xs_1 or nil
    end
    local function kT(kU, kV)
        local Type = kV.Type
        if Type == "Toggle" then
            return { idx = kU, type = "Toggle", value = kV.Value == true }
        elseif Type == "Slider" then
            return { idx = kU, type = "Slider", value = tostring(kV.Value) }
        elseif Type == "Dropdown" then
            return { idx = kU, type = "Dropdown", multi = kV.Multi == true, value = kV.Value }
        elseif Type == "Input" then
            local xC = kV.Value or ""
            return { idx = kU, type = "Input", text = tostring(xC) }
        elseif Type == "ColorPicker" then
            return { idx = kU, type = "ColorPicker", value = kV.Value:ToHex(), transparency = kV.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = kU,
                type = "KeyPicker",
                mode = kV.Mode,
                key = kV.Value,
                modifiers = kV.Modifiers,
                toggled = kV.Toggled
            }
        else
            return nil
        end
    end
    local function kX()
        local xF = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local xG = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if xG then
                    local xG_1 = kT(k, v)
                    if xG_1 then
                        xF[#xF + 1] = xG_1
                    end
                end
            end
        end
        table.sort(xF, function(k6, k7)
            if k6.type ~= k7.type then
                return k6.type < k7.type
            end
            return k6.idx < k7.idx
        end)
        return { objects = xF }
    end
    local function k8(k9)
        local xW
        xW = nil
        local xX = type(k9) ~= "table" or type(k9.idx) ~= "string" or type(k9.type) ~= "string" or SaveManager.Ignore[k9.idx]
        if xX then
            return false
        end
        xW = kJ(k9.type, k9.idx)
        if not xW then
            return false
        end
        local xX_1 = pcall(function()
            if k9.type == "Input" then
                if type(k9.text) ~= "string" then
                    return
                end
                xW:SetValue(k9.text)
            elseif k9.type == "ColorPicker" then
                xW:SetValueRGB(Color3.fromHex(k9.value), k9.transparency)
            elseif k9.type == "KeyPicker" then
                xW:SetValue({ k9.key, k9.mode, k9.modifiers })
                if k9.mode == "Toggle" and k9.toggled ~= nil then
                    xW.Toggled = k9.toggled
                    xW:Update()
                end
            else
                xW:SetValue(k9.value)
            end
        end)
        return xX_1
    end
    kI:AddDivider()
    kI:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    kI:AddButton("Export Config to Clipboard", function()
        local x__1
        local xZ_1
        xZ_1, x__1 = pcall(HttpService.JSONEncode, HttpService, kX())
        if not xZ_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local xZ_2 = setclipboard or toclipboard
        local xZ_3 = type(xZ_2) ~= "function"
        local x4 = if xZ_3 then 1 else 0
        local x2 = 537 * x4 + 1894 * (1 - x4)
        local x3 = 2169 * x4 + 3342 * (1 - x4)
        if not ((x2 * 67 + x3 * 3498 + x2 * x3) % 16777213 == 8787894) then
            xZ_3 = not pcall(xZ_2, x__1)
        end
        if xZ_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    kI:AddButton("Import Config from Clipboard Text", function()
        local x7_1
        local x5 = Options.SaveManager_ImportSource.Value or ""
        local x5_1
        local x6 = tostring(x5):match("^%s*(.-)%s*$")
        if x6 == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        x5_1, x7_1 = pcall(HttpService.JSONDecode, HttpService, x6)
        local x6_1 = not x5_1 or type(x7_1) ~= "table"
        local yb = if x6_1 then 1 else 0
        local x9 = 951 * yb + 1947 * (1 - yb)
        local ya = 1955 * yb + 3050 * (1 - yb)
        if not ((x9 * 2215 + ya * 2687 + x9 * ya) % 16777213 == 9218755) then
            x6_1 = type(x7_1.objects) ~= "table"
        end
        if x6_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local x5_2 = 0
        for i, v in ipairs(x7_1.objects) do
            if k8(v) then
                x5_2 += 1
            end
        end
        if x5_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local x7_2 = x5_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(x5_2, x7_2), 6)
    end)
end
yl_5_2()
yl_9_7()
qa_3()
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(pd.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/StealFishEggs")
local p9_4 = SaveManager:BuildConfigSection(pd.Settings)
yl_16_4(p9_4)
SaveManager:LoadAutoloadConfig()
if Toggles.HideUiOnStart.Value then
    Library:Toggle(false)
end
end)(...)

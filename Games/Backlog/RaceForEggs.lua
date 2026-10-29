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
getgenv().TempoHoodSubtitle = "RACE FOR EGGS"
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
local connection
local yQ
local yx
local ze
local yW
local xW
local zk
local yk
local y1
local x1
local yq
local y7
local x7
local yP
local yw
local yd
local yV
local yC
local zj
local connection2
local y0
local yI
local yp
local x6
local CollectionService
local yv
local zc
local yc
local CoreGui
local yB
local zi
local yi
local y_
local x_
local yH
local zo
local yo
local y5
local x5
local yN
local yu
local zb
local yb
local yT
local yA
local zh
local yh
local yZ
local xZ
local yG
local y4
local yM
local State
local ya
local yS
local yz
local xY
local yF
local zm
local ym
local x3
local yL
local ys
local LocalPlayer
local zf
local yf
local yX
local xX
local zl
local yl
local y2
local x2
local yK
local yr
local y8
function fns.fn1(i6)
    local Gx = tonumber(i6) or 10
    yF.interval = math.max(1, Gx)
end
function fns.fn7(jJ)
    ym.sellEggs = jJ == true
end
function fns.fn13()
    local B7 = y_()
    local B8 = B7 and tonumber(B7.Rebirth)
    return B8 or 0
end
function fns.fn15()
    return x1("MutationConfig")
end
function fns.fn18(hN)
    hN.stopped = true
    local Fy = hN.generation
    local FC = if Fy then 1 else 0
    local FA = 895 * FC + 190 * (1 - FC)
    local FB = 2308 * FC + 1270 * (1 - FC)
    if not ((FA * 3392 + FB * 2239 + FA * FB) % 16777213 == 10269112) then
        Fy = 0
    end
    hN.generation = Fy + 1
end
function fns.fn23()
    return x1("PlayerSkinConfig")
end
function fns.fn26(hV, hW)
    local FM = {}
    for k in pairs(zf(hV)) do
        local FN_1 = hW and hW[k] or k
        FM[FN_1] = true
    end
    return FM
end
function fns.fn31(i8)
    if i8 then
        yx(yN, xX)
    else
        zo(yN)
    end
end
function fns.fn40()
    return not yc.Unloaded
end
function fns.fn42(gg, gh, gi, gj, gk)
    local EF
    if type(gg) ~= "table" then
        return nil
    end
    for k, v in pairs(gg) do
        if type(v) == "table" then
            local EG = type(v.id) == "string" and v.id
            local EH = EG
            if not EH then
                local EG_1 = type(k) == "string" and k
                EH = EG_1 or nil
            end
            local EG_2 = EH
            local EH_1 = tonumber(v.cost)
            local EI_2 = type(v.name) == "string" and v.name
            local EJ = EI_2 or EG_2
            local EI_3 = EG_2
            if EI_3 then
                EI_3 = EH_1
            end
            if EI_3 then
                EI_3 = not (gh and gh[EG_2])
            end
            if EI_3 then
                local EI_4 = yi(gi) == 0 or gi[EJ] == true or gi[EG_2] == true
                if EI_4 then
                    EI_4 = gj <= 0 or EH_1 <= gj
                end
                if EI_4 then
                    EI_4 = EH_1 <= gk
                end
                if EI_4 then
                    if not EF or EH_1 < EF.cost then
                        EF = { id = EG_2, cost = EH_1, name = EJ }
                    end
                end
            end
        end
    end
    return EF
end
function fns.fn57()
    return zb("Cash")
end
function fns.fn65(cV)
    local BZ = y_()
    local B_ = BZ and BZ.Currencies
    if type(B_) == "table" then
        local B__1 = tonumber(B_[cV]) or 0
        return B__1
    end
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local B__2 = leaderstats and leaderstats:FindFirstChild(cV)
    local BZ_3 = B__2
    if B__2 then
        B__2 = tonumber(BZ_3.Value)
    end
    return B__2 or 0
end
function fns.fn98(i1)
    if i1 then
        yx(yF, yA)
    else
        zo(yF)
    end
end
function fns.fn117()
    return x1("PlaytimeRewardConfig")
end
function fns.fn118(iM)
    local Gl = tonumber(iM) or 5
    yT.interval = math.max(1, Gl)
end
function fns.fn192()
    local CI_1
    local CH_1
    local CG_1
    CG_1, CH_1, CI_1 = yv("TrainingService", "Train")
    if CG_1 and CH_1 then
        local format = string.format
        local CH_2 = tonumber(CI_1) or 0
        yK(format("Trained +%s speed", tostring(CH_2)))
    end
end
function fns.fn198()
    local Bl = yh()
    local Bm = {}
    local Bn = {}
    if Bl then
        for k, v in pairs(Bl) do
            local Bl_1 = type(v) == "table" and type(v.rarity) == "string" and not Bn[v.rarity]
            if Bl_1 then
                Bn[v.rarity] = true
                table.insert(Bm, v.rarity)
            end
        end
    end
    table.sort(Bm)
    return Bm
end
local function fn213(j1)
    local GS = tonumber(j1) or 5
    yV.interval = math.max(1, GS)
end
local function fn219()
    local CQ_1
    local CP_1
    CP_1, CQ_1 = yv("PlotService", "GetPlayerPlot")
    local CR = not CP_1 or typeof(CQ_1) ~= "Instance"
    if CR then
        return nil
    end
    local PlotSurface = CQ_1:FindFirstChild("PlotSurface")
    local CQ_2 = PlotSurface and PlotSurface:IsA("BasePart")
    if CQ_2 then
        return PlotSurface
    end
    return nil
end
local function fn250()
    local Fq = yv("PlotService", "TeleportToPlot")
    if Fq then
        y5("Teleported to your base")
    else
        y5("Could not reach the plot service")
    end
end
local function fn265()
    local B4 = y_()
    local B5 = B4 and tonumber(B4.Speed)
    if B5 then
        return tonumber(B4.Speed)
    end
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local B5_1 = leaderstats and leaderstats:FindFirstChild("Speed")
    local B4_2 = B5_1
    if B5_1 then
        B5_1 = tonumber(B4_2.Value)
    end
    return B5_1 or 0
end
local function fn282(j6)
    local GV = (tonumber(j6))
    local GZ = if GV then 1 else 0
    local GX = 105 * GZ + 3825 * (1 - GZ)
    local GY = 1093 * GZ + 3327 * (1 - GZ)
    if not ((GX * 3005 + GY * 3909 + GX * GY) % 16777213 == 4702827) then
        GV = 0
    end
    yV.maxCost = math.max(0, GV)
end
local function fn285(iy)
    if connection then
        connection:Disconnect()
        connection = nil
    end
    if iy then
        local Gf = x_("TrainingService", "RE", "SpawnBonus")
        if Gf then
            connection = Gf.OnClientEvent:Connect(function(...)
                local Gd = xZ() and not yT.stopped
                if Gd then
                    xY(...)
                end
            end)
        end
        yx(yT, function()
            xY()
        end)
    else
        zo(yT)
    end
end
local function fn286(kd)
    yw.includeVip = kd == true
end
local function fn289(iV)
    if iV then
        yx(yP, ya)
    else
        zo(yP)
    end
end
local function fn297(ee)
    local CW = {}
    local CX = math.max(0, ee.Size.X / 2 - 3)
    local CY = math.max(0, ee.Size.Z / 2 - 3)
    local CZ = ee.Position.Y + ee.Size.Y / 2 + 1
    local C_ = 6
    local C0 = -CX
    while C0 <= CX do
        local C1 = -CY
        while C1 <= CY do
            table.insert(CW, CFrame.new(ee.Position.X + C0, CZ, ee.Position.Z + C1))
            C1 += C_
        end
        C0 += C_
    end
    return CW
end
local function fn298(jX)
    if jX then
        yx(yV, yL)
    else
        zo(yV)
    end
end
local function fn305()
    local Aw = x1("TrainToolConfig")
    local Ax = Aw and Aw.TRAIN_TOOLS
    local Ax_1 = type(Ax) == "table" and Ax
    local Aw_2 = Ax_1
    local AB = if Aw_2 then 1 else 0
    local Az = 3166 * AB + 1118 * (1 - AB)
    local AA = 1560 * AB + 2611 * (1 - AB)
    if not ((Az * 975 + AA * 1995 + Az * AA) % 16777213 == 11138010) then
        Aw_2 = nil
    end
    return Aw_2
end
local function fn311()
    local Fn_1
    local Fl = yl("DailyReward")
    local Fm = Fl and tonumber(Fl.LastClaimedDay)
    local Fm_3
    local Fl_2 = (Fm or 0) + 1
    if Fl_2 > 7 or Fl_2 < 1 then
        Fl_2 = 1
    end
    Fm_3, Fn_1 = yv("DailyRewardService", "ClaimReward", Fl_2)
    if Fm_3 and Fn_1 then
        yK("Claimed daily reward " .. tostring(Fl_2))
    end
    if yw.includeVip then
        yv("DailyRewardService", "ClaimVIPReward", Fl_2)
    end
end
local function fn335(bF, bG)
    local AU = {}
    if type(bF) ~= "table" then
        return AU
    end
    for k, v in pairs(bF) do
        if type(v) == "table" then
            local AV = type(v.id) == "string" and v.id
            local AW = AV
            if not AW then
                local AV_1 = type(k) == "string" and k
                AW = AV_1 or nil
            end
            local AV_2 = AW
            if AV_2 then
                local AW_1 = bG and type(v.name) == "string" and v.name
                local AX_2 = AW_1 or AV_2
                table.insert(AU, AX_2)
            end
        end
    end
    table.sort(AU)
    return AU
end
local function fn357()
    local D0_1
    local D__1
    D__1, D0_1 = yv("AnimalService", "EquipBest")
    if D__1 and D0_1 then
        yK("Equipped your best pets")
    end
end
local function fn362(cu)
    local BE_1
    local BD_2
    local BC = xW[cu]
    if BC ~= nil then
        return BC ~= false and BC or nil
    end
    local BC_2 = zi()
    if not BC_2 then
        return nil
    end
    BD_2, BE_1 = pcall(BC_2.GetControllers)
    local BC_3 = not BD_2
    local BI = if BC_3 then 1 else 0
    local BG = 2847 * BI + 2123 * (1 - BI)
    local BH = 500 * BI + 51 * (1 - BI)
    if not ((BG * 3688 + BH * 3089 + BG * BH) % 16777213 == 13467736) then
        BC_3 = type(BE_1) ~= "table"
    end
    if BC_3 then
        return nil
    end
    local BC_4 = BE_1[cu]
    if type(BC_4) ~= "table" then
        return nil
    end
    xW[cu] = BC_4
    return BC_4
end
local function fn364()
    zo(y8)
    zo(y0)
    zo(yX)
    zo(yT)
    zo(yk)
    zo(yP)
    zo(yF)
    zo(yN)
    zo(yI)
    zo(yB)
    zo(ym)
    zo(yZ)
    zo(yV)
    zo(yw)
    if connection2 then
        connection2:Disconnect()
        connection2 = nil
    end
    if connection then
        connection:Disconnect()
        connection = nil
    end
end
local function fn380(io)
    local F4 = tonumber(io) or 0.2
    y0.interval = math.max(0.05, F4)
end
local function fn388()
    local E6 = yq()
    if not E6 then
        return
    end
    local E7 = {}
    local E8 = yl("OwnedSkins") or E7
    local E7_1 = E8
    local E8_1 = yS(E6, E7_1, yV.allowed, yV.maxCost, yp())
    if E8_1 then
        yv("SkinService", "BuySkin", E8_1.id)
        task.wait(0.4)
        local E9_1 = (yl("OwnedSkins"))
        local Fg = if E9_1 then 1 else 0
        local Fe = 2478 * Fg + 1616 * (1 - Fg)
        local Ff = 657 * Fg + 869 * (1 - Fg)
        if not ((Fe * 3189 + Ff * 3695 + Fe * Ff) % 16777213 == 11958003) then
            E9_1 = E7_1
        end
        E7_1 = E9_1
        local Fa_1 = E7_1[E8_1.id] and "Bought " .. E8_1.name or "Could not buy " .. E8_1.name
        yK(Fa_1)
    end
    local E8_2 = y_()
    local E9_3 = E8_2 and E8_2.EquippedPlayerSkin
    local E8_3 = nil
    for k in pairs(E7_1) do
        local E7_2 = E6[k]
        local E9_4 = type(E7_2) == "table" and tonumber(E7_2.luck)
        local Fb = E9_4 or nil
        local E9_5 = Fb
        if Fb then
            Fb = not E8_3 or E9_5 > E8_3.luck
        end
        if Fb then
            local Fb_1 = type(E7_2.name) == "string" and E7_2.name
            E8_3 = { id = k, luck = E9_5, name = Fb_1 or k }
        end
    end
    if E8_3 and E9_3 ~= E8_3.id then
        local E6_1 = yv("SkinService", "EquipSkin", E8_3.id)
        if E6_1 then
            yK("Equipped " .. E8_3.name)
        end
    end
end
local function fn396()
    local AL = x1("SeasonPassConfig")
    local AM = AL and AL.Pass
    local AM_1 = type(AM) == "table" and AM
    return AM_1 or nil
end
local function fn420()
    if zj then
        return zj
    end
    local A4 = yh()
    local A5 = {}
    if A4 then
        for k, v in pairs(A4) do
            if type(v) == "table" then
                local A4_1 = type(v.id) == "string" and v.id
                local A6 = A4_1
                if not A6 then
                    local A4_2 = type(k) == "string" and k
                    A6 = A4_2 or nil
                end
                local A4_3 = A6
                if A4_3 then
                    local A6_1 = type(v.name) == "string" and v.name
                    local A7_2 = A6_1 or A4_3
                    A5[A7_2] = A4_3
                end
            end
        end
    end
    zj = A5
    return A5
end
local function fn486(iv)
    local F8 = (tonumber(iv))
    local Gc = if F8 then 1 else 0
    local Ga = 2858 * Gc + 2223 * (1 - Gc)
    local Gb = 3167 * Gc + 618 * (1 - Gc)
    if not ((Ga * 1396 + Gb * 321 + Ga * Gb) % 16777213 == 14057661) then
        F8 = 0.3
    end
    yX.interval = math.max(0.1, F8)
end
local function fn507(jd)
    if jd then
        yx(yI, yd)
    else
        zo(yI)
    end
end
local function fn517(iq)
    if iq then
        yx(yX, yb)
    else
        zo(yX)
    end
end
local function fn543(ju)
    local GH = tonumber(ju) or 5
    ym.interval = math.max(1, GH)
end
local function fn556()
    local Bf = {}
    for k in pairs(zh()) do
        table.insert(Bf, k)
    end
    table.sort(Bf)
    return Bf
end
local function fn589(jD)
    ym.mutations = zf(jD)
end
local function fn606()
    x6("Egg", "EggService", "PlaceEgg", yk)
end
local function fn612(ji)
    if ji then
        yx(yB, yG)
    else
        zo(yB)
    end
end
local function fn616()
    return CoreGui
end
local function fn624()
    local EV = yM()
    if not EV then
        return
    end
    local EW = {}
    local EX = yl("OwnedTrainTools") or EW
    local EW_1 = EX
    local EX_1 = yS(EV, EW_1, yZ.allowed, yZ.maxCost, yp())
    if EX_1 then
        yv("TrainingService", "BuyTrainTool", EX_1.id)
        task.wait(0.4)
        local EY_1 = yl("OwnedTrainTools") or EW_1
        EW_1 = EY_1
        local EZ_1 = EW_1[EX_1.id] and "Bought " .. EX_1.name or "Could not buy " .. EX_1.name
        yK(EZ_1)
    end
    local EX_2 = y_()
    local EY_3 = EX_2 and EX_2.EquippedTrainTool
    local EX_3 = nil
    for k in pairs(EW_1) do
        local EW_2 = EV[k]
        local EY_4 = type(EW_2) == "table" and tonumber(EW_2.gainPerTrain)
        local E_ = EY_4 or nil
        local EY_5 = E_
        if E_ then
            E_ = not EX_3 or EY_5 > EX_3.gain
        end
        if E_ then
            local E__1 = type(EW_2.name) == "string" and EW_2.name
            EX_3 = { id = k, gain = EY_5, name = E__1 or k }
        end
    end
    if EX_3 and EY_3 ~= EX_3.id then
        local EV_1 = yv("TrainingService", "EquipTrainTool", EX_3.id)
        if EV_1 then
            yK("Equipped " .. EX_3.name)
        end
    end
end
local function fn630(jn)
    local GD = tonumber(jn) or 10
    yB.interval = math.max(1, GD)
end
local function fn637(aB, aC, aD)
    local Af = yu()
    local Ag = Af and Af:FindFirstChild(aB)
    local Af_1 = Ag
    if Ag then
        Ag = Af_1:FindFirstChild(aC)
    end
    local Af_2 = Ag
    if Ag then
        Ag = Af_2:FindFirstChild(aD)
    end
    local Af_3 = Ag
    if not Af_3 then
        return nil
    end
    local Ag_1 = aC == "RF" and Af_3:IsA("RemoteFunction")
    if Ag_1 then
        return Af_3
    end
    local Ag_2 = aC == "RE" and Af_3:IsA("RemoteEvent")
    if Ag_2 then
        return Af_3
    end
    return nil
end
local function fn649(jA)
    ym.rarities = zf(jA)
end
local function fn691()
    gethui = yr
end
local function fn692()
    local Du_3
    local Dt = yH()
    local Dt_3
    if Dt then
        local Du_1 = Dt[zm() + 1]
        local Dt_1 = type(Du_1) == "table" and type(Du_1.Cost) == "table" and tonumber(Du_1.Cost.Cash)
        local Du_2 = Dt_1 or nil
        local Dt_2 = Du_2
        if Du_2 then
            Du_2 = yp() < Dt_2
        end
        if Du_2 then
            yK(string.format("Need %s cash to rebirth", tostring(Dt_2)))
            return
        end
    end
    Dt_3, Du_3 = yv("RebirthService", "Rebirth")
    if Dt_3 and Du_3 then
        yK("Rebirthed")
    end
end
local function fn703(ai, aj)
    if not xZ() then
        return
    end
    local Notifications = State.Notifications
    local z6 = tostring(ai)
    local z7 = aj or 5
    table.insert(Notifications, { text = z6, time = z7 })
    if #State.Notifications > 12 then
        table.remove(State.Notifications, 1)
    end
end
local function fn748()
    local Bx_1
    local Bw_4
    if zk ~= nil then
        return zk ~= false and zk or nil
    end
    local Packages = zl:FindFirstChild("Packages")
    local Bw_2 = Packages and Packages:FindFirstChild("_Index")
    local Bv_3 = Bw_2
    if Bw_2 then
        Bw_2 = Bv_3:FindFirstChild(ze)
    end
    local Bv_4 = Bw_2
    if Bw_2 then
        Bw_2 = Bv_4:FindFirstChild("knit")
    end
    local Bv_5 = Bw_2
    if Bw_2 then
        Bw_2 = Bv_5:FindFirstChild("KnitClient")
    end
    local Bv_6 = Bw_2
    local Bw_3 = not Bv_6 or not Bv_6:IsA("ModuleScript")
    if Bw_3 then
        return nil
    end
    Bw_4, Bx_1 = pcall(require, Bv_6)
    local Bv_7 = not Bw_4 or type(Bx_1) ~= "table" or not x2(Bx_1.GetControllers)
    if Bv_7 then
        return nil
    end
    zk = Bx_1
    return Bx_1
end
local function fn779(iO)
    if iO then
        yx(yk, yf)
    else
        zo(yk)
    end
end
local function fn792(jp)
    if jp then
        yx(ym, yo)
    else
        zo(ym)
    end
end
local function fn849(aa)
    return type(aa) == "function"
end
local function fn890()
    local AC = x1("BrainrotsConfig")
    local AD = AC and AC.CONFIG
    local AD_1 = type(AD) == "table" and AD
    local AC_2 = AD_1
    local AH = if AC_2 then 1 else 0
    local AF = 1625 * AH + 631 * (1 - AH)
    local AG = 2074 * AH + 603 * (1 - AH)
    if not ((AF * 1755 + AG * 193 + AF * AG) % 16777213 == 6622407) then
        AC_2 = nil
    end
    return AC_2
end
local function fn920(j8)
    if j8 then
        yx(yw, ys)
    else
        zo(yw)
    end
end
local function fn946()
    local Dj_2
    local Dg = os.time()
    local Dh = 0
    for i, v in ipairs(CollectionService:GetTagged("PlacedEgg")) do
        if not xZ() then
            return
        end
        if v:GetAttribute("OwnerId") == LocalPlayer.UserId then
            local attr = v:GetAttribute("EggId")
            local Dj_1 = tonumber(v:GetAttribute("StartTime"))
            local Dk = tonumber(v:GetAttribute("Duration"))
            local Dk_1
            local Dl = type(attr) == "string" and Dj_1 and Dk and Dg >= Dj_1 + Dk
            if Dl then
                Dj_2, Dk_1 = yv("EggService", "HatchEgg", attr)
                if Dj_2 and Dk_1 then
                    Dh += 1
                    task.wait(0.2)
                end
            end
        end
    end
    if Dh > 0 then
        local format = string.format
        local Dj_3 = Dh == 1 and "" or "s"
        yK(format("Hatched %d egg%s", Dh, Dj_3))
    end
end
local function fn969()
    local AI = x1("SizeConfig")
    local AJ = AI and AI.SIZES
    local AJ_1 = type(AJ) == "table" and AJ
    return AJ_1 or nil
end
local function fn980()
    local DM = y1()
    local DM_2
    if not DM then
        return
    end
    local DN = yl("SeasonPass")
    local DO = type(DN) == "table" and type(DN.Free) == "table" and DN.Free
    local DQ = DO or {}
    local DQ_2
    local DP_1 = type(DN) == "table" and type(DN.Paid) == "table" and DN.Paid
    local DQ_1 = DP_1 or {}
    local DN_2 = 0
    for k, v in pairs(DM) do
        if not xZ() then
            return
        end
        local DM_1 = type(k) == "number" and type(v) == "table"
        if DM_1 then
            if not DQ[k] then
                DM_2, DQ_2 = yv("SeasonPassService", "ClaimPassReward", "Free", k)
                if DM_2 and DQ_2 ~= false then
                    DN_2 += 1
                    task.wait(0.15)
                end
            end
            if not DQ_1[k] then
                yv("SeasonPassService", "ClaimPassReward", "Paid", k)
                task.wait(0.15)
            end
        end
    end
    if DN_2 > 0 then
        yK("Claimed event pass rewards")
    end
end
local function fn1019(jG)
    ym.sizes = zf(jG)
end
local function fn1022(jw)
    ym.brainrots = yQ(jw, zh())
end
local function fn1025(iT)
    local Gp = tonumber(iT) or 2
    yk.interval = math.max(0.5, Gp)
end
local function fn1031()
    local Ej = {}
    local Ek = {}
    for i, v in ipairs(y7()) do
        if v.itemType == "Brainrot" then
            if x7(v.inner) then
                table.insert(Ek, v.id)
            end
        else
            if v.itemType == "Egg" and ym.sellEggs then
                table.insert(Ej, v.id)
            end
        end
    end
    if #Ek > 0 then
        local El_2 = yv("InventoryService", "SellBrainrots", Ek)
        if El_2 then
            local format = string.format
            local Em_1 = #Ek
            local Eo = #Ek == 1 and ""
            local Ey = if Eo then 1 else 0
            local Ew = 3795 * Ey + 3943 * (1 - Ey)
            local Ex = 3270 * Ey + 2277 * (1 - Ey)
            if not ((Ew * 2790 + Ex * 3094 + Ew * Ex) % 16777213 == 16337867) then
                Eo = "s"
            end
            yK(format("Sold %d brainrot%s", Em_1, Eo))
        end
    end
    for i, v in ipairs(Ej) do
        local Ek_1 = not xZ() or ym.stopped
        if Ek_1 then
            return
        end
        yv("InventoryService", "SellEgg", v)
        task.wait(0.15)
    end
    if #Ej > 0 then
        local format = string.format
        local El_4 = #Ej
        local En_2 = #Ej == 1 and "" or "s"
        yK(format("Sold %d egg%s", El_4, En_2))
    end
end
local function fn1055(dx)
    local Cn = y_()
    local Co = Cn and Cn[dx]
    local Co_1 = type(Co) == "table" and Co
    return Co_1 or nil
end
local function fn1063(i_)
    local Gt = tonumber(i_) or 3
    yP.interval = math.max(0.5, Gt)
end
local function fn1066(jQ)
    local GL = tonumber(jQ) or 5
    yZ.interval = math.max(1, GL)
end
local function fn1081(X)
    local z2 = typeof(cloneref) == "function" and typeof(X) == "Instance"
    if z2 then
        return cloneref(X)
    end
    return X
end
local function fn1087()
    local Packages = zl:FindFirstChild("Packages")
    local Aa = Packages and Packages:FindFirstChild("_Index")
    local z9_1 = Aa
    if Aa then
        Aa = z9_1:FindFirstChild(ze)
    end
    local z9_2 = Aa
    if Aa then
        Aa = z9_2:FindFirstChild("knit")
    end
    local z9_3 = Aa
    if Aa then
        Aa = z9_3:FindFirstChild("Services")
    end
    return Aa or nil
end
local function fn1092()
    local Ca = y_()
    local Cb = Ca and Ca.Inventory
    local Ca_1 = {}
    if type(Cb) ~= "table" then
        return Ca_1
    end
    for k, v in pairs(Cb) do
        local Cb_1 = type(v) == "table" and type(k) == "string"
        if Cb_1 then
            local insert = table.insert
            local Cc_1 = type(v.itemType) == "string" and v.itemType
            local Cd = Cc_1 or nil
            local Cc_2 = type(v.innerEntity) == "table" and v.innerEntity
            local Cf = Cc_2 or {}
            insert(Ca_1, { id = k, itemType = Cd, inner = Cf })
        end
    end
    return Ca_1
end
local function fn1141()
    local AO = x1("RebirthConfig")
    local AP = AO and AO.REBIRTH
    local AP_1 = type(AP) == "table" and AP
    local AO_2 = AP_1
    local AT = if AO_2 then 1 else 0
    local AR = 3711 * AT + 2217 * (1 - AT)
    local AS = 2148 * AT + 823 * (1 - AT)
    if not ((AR * 165 + AS * 1491 + AR * AS) % 16777213 == 11786211) then
        AO_2 = nil
    end
    return AO_2
end
local function fn1163(jV)
    local GO = tonumber(jV) or 0
    yZ.maxCost = math.max(0, GO)
end
local function fn1200(fG)
    local D6 = 0
    for k in pairs(fG) do
        D6 += 1
    end
    return D6
end
local function fn1205(hP)
    local FD = {}
    if type(hP) == "table" then
        for k, v in pairs(hP) do
            local FE = v == true and type(k) == "string"
            if FE then
                FD[k] = true
            elseif type(v) == "string" then
                FD[v] = true
            end
        end
    end
    return FD
end
local function fn1214()
    local DA = zc()
    local DA_3
    if not DA then
        return
    end
    local DB = y_()
    local DB_3
    local DC = DB and tonumber(DB.TimePlayed)
    local DB_1 = DC or 0
    local DC_1 = 0
    for k, v in pairs(DA) do
        if not xZ() then
            return
        end
        local DA_1 = type(k) == "number" and type(v) == "table"
        if DA_1 then
            local DA_2 = tonumber(v.time)
            if DA_2 and DB_1 >= DA_2 then
                DA_3, DB_3 = yv("PlaytimeRewardService", "ClaimGift", k)
                if DA_3 and DB_3 then
                    DC_1 += 1
                    task.wait(0.2)
                end
            end
        end
    end
    if DC_1 > 0 then
        local format = string.format
        local DD_1 = DC_1 == 1 and "" or "s"
        yK(format("Claimed %d playtime reward%s", DC_1, DD_1))
    end
end
local function fn1233(h2)
    if connection2 then
        connection2:Disconnect()
        connection2 = nil
    end
    if h2 then
        connection2 = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(3)
            local FU = xZ() and not y8.stopped
            if FU then
                x5()
            end
        end)
        yx(y8, x5)
    else
        zo(y8)
        y2()
        yK("Auto race off")
    end
end
local function fn1249(en, eo, ep, eq)
    local C3 = y4()
    if not C3 then
        yK("Waiting for your plot")
        return
    end
    local C4 = yz(C3)
    if #C4 == 0 then
        return
    end
    local C3_1 = 1
    for i, v in ipairs(y7()) do
        local C5 = not xZ() or eq.stopped
        if C5 then
            return
        end
        if v.itemType == en then
            local C5_1 = false
            while true do
                local C6 = not C5_1
                local C6_1
                local C7 = C3_1 <= #C4 and C6
                local C7_1
                if C7 then
                    C6_1, C7_1 = yv(eo, ep, v.id, C4[C3_1])
                    if C6_1 and C7_1 then
                        C5_1 = true
                        yK("Placed " .. string.lower(en))
                    else
                        C3_1 += 1
                    end
                    continue
                end
                break
            end
            if not C5_1 then
                yK("No free space left on your plot")
                return
            end
            task.wait(0.2)
        end
    end
end
local function fn1281(fK)
    local Ec = type(fK.brainrotType) == "string" and fK.brainrotType
    local Ed = Ec or nil
    local Ed_12, Ed_16
    if not Ed then
        return false
    end
    local Ed_1 = yi(ym.brainrots) > 0 and not ym.brainrots[Ed]
    if Ed_1 then
        return false
    elseif yi(ym.rarities) > 0 then
        local Ed_2 = yh()
        local Ec_2 = Ed_2 and Ed_2[Ed]
        local Ed_3 = type(Ec_2) == "table" and Ec_2.rarity
        local Ed_4 = Ed_3 or nil
        if not Ed_4 or not ym.rarities[Ed_4] then
            return false
        elseif yi(ym.mutations) > 0 then
            if Ed_12 then
                return false
            elseif yi(ym.sizes) > 0 then
                if Ed_16 then
                    return false
                end
                return true
            else
                return true
            end
        elseif yi(ym.sizes) > 0 then
            if Ed_16 then
                return false
            end
            return true
        else
            return true
        end
    elseif yi(ym.mutations) > 0 then
        local Ec_11 = type(fK.mutation) == "string" and fK.mutation
        local Ed_11 = Ec_11 or nil
        Ed_12 = not Ed_11 or not ym.mutations[Ed_11]
        if Ed_12 then
            return false
        elseif yi(ym.sizes) > 0 then
            if Ed_16 then
                return false
            end
            return true
        else
            return true
        end
    elseif yi(ym.sizes) > 0 then
        local Ec_15 = type(fK.size) == "string" and fK.size
        local Ed_15 = Ec_15 or nil
        Ed_16 = not Ed_15 or not ym.sizes[Ed_15]
        if Ed_16 then
            return false
        end
        return true
    else
        return true
    end
end
local function fn1313(jS)
    yZ.allowed = zf(jS)
end
local function fn1326(jL)
    if jL then
        yx(yZ, yW)
    else
        zo(yZ)
    end
end
local function fn1335(j3)
    yV.allowed = zf(j3)
end
local function fn1355(ii)
    if ii then
        yx(y0, yC)
    else
        zo(y0)
    end
end
local function fn1365(...)
    local CN_1
    local CM_1
    local CL = table.pack(...)
    if CL.n > 0 then
        CM_1, CN_1 = yv("TrainingService", "ClaimBonus", table.unpack(CL, 1, CL.n))
    else
        CM_1, CN_1 = yv("TrainingService", "ClaimBonus")
    end
    if CM_1 and CN_1 then
        yK("Claimed a 2x training bonus")
        return true
    end
    return false
end
local function fn1374(an)
    State.Status = tostring(an)
end
local function fn1399(aZ)
    local Ar_1
    local Aq_4
    local Ap = x3[aZ]
    if Ap ~= nil then
        return Ap ~= false and Ap or nil
    end
    local Configs = zl:FindFirstChild("Configs")
    local Aq_2 = Configs and Configs:FindFirstChild(aZ)
    local Aq_3 = not Aq_2 or not Aq_2:IsA("ModuleScript")
    if Aq_3 then
        x3[aZ] = false
        return nil
    end
    Aq_4, Ar_1 = pcall(require, Aq_2)
    local Ap_4 = not Aq_4 or type(Ar_1) ~= "table"
    if Ap_4 then
        x3[aZ] = false
        return nil
    end
    x3[aZ] = Ar_1
    return Ar_1
end
xW = nil
xX = nil
xY = nil
xZ = nil
x_ = nil
x1 = nil
x2 = nil
x3 = nil
x5 = nil
x6 = nil
x7 = nil
connection = nil
ya = nil
yb = nil
yc = nil
yd = nil
yf = nil
yh = nil
yi = nil
connection2 = nil
yk = nil
yl = nil
ym = nil
yo = nil
yp = nil
yq = nil
yr = nil
ys = nil
yu = nil
yv = nil
yw = nil
yx = nil
LocalPlayer = nil
yz = nil
yA = nil
yB = nil
yC = nil
yF = nil
yG = nil
yH = nil
local Players, x0, x4, x9, ye, yg, yn, yt, Workspace, yE
yI = nil
yK = nil
yL = nil
yM = nil
yN = nil
CollectionService = nil
yP = nil
yQ = nil
yS = nil
yT = nil
CoreGui = nil
yV = nil
yW = nil
yX = nil
yZ = nil
y_ = nil
y0 = nil
y1 = nil
y2 = nil
y4 = nil
y5 = nil
y7 = nil
y8 = nil
State = nil
zb = nil
zc = nil
ze = nil
zf = nil
zh = nil
zi = nil
zj = nil
zk = nil
zl = nil
zm = nil
zo = nil
local Lighting, TeleportService, GuiService, HttpService, y6, VirtualUser, UserInputService, RunService, zn, zp
if not game:IsLoaded() then
    game.Loaded:Wait()
end
Players, RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, TeleportService, CollectionService, Lighting, Workspace, LocalPlayer, yr = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
TeleportService = game:GetService("TeleportService")
CollectionService = game:GetService("CollectionService")
Lighting = game:GetService("Lighting")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local zq = "TempoRaceForEggs"
yr = fn616
if getgenv then
    getgenv().gethui = yr
end
yc, zl, ze, State, x3, zj, xW, zk, y6, yk, yF, ym, yZ, yV, yw, y8, y0, yX, yT, yP, yN, yI, yB, connection2, connection, yE, x2, xZ, y5, yK, yu, x_, yv, x1, yM, yq, yh, x4, x0, zc, y1, yH, yn, zh, yt, ye, zi, x9, y_, zb, yp, yg, zm, y7, yl, x5, y2, yC, yb, xY, y4, yz, x6, yf, ya, yA, xX, yd, yG, yi, x7, yo, yS, yW, yL, ys, zn, yx, zo, zf, yQ, zp = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pcall(fn691)
local function zu(u)
    local zV
    local zW
    local zU
    zU = nil
    zV = nil
    zW = nil
    local zX = u ~= ""
    local zY = type(u) == "string" and zX
    assert(zY, "A namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    zV = getgenv()
    assert(type(zV) == "table", "getgenv did not return a table")
    local zX_1 = zV[u]
    if zX_1 ~= nil then
        local zY_1 = type(zX_1) == "table" and type(zX_1.Unload) == "function"
        assert(zY_1, "Namespace is occupied")
        zX_1.Unload()
        assert(zV[u] == nil, "Previous instance did not release its namespace")
    end
    zW = {}
    zU = { State = {}, Unloaded = false }
    zU.Track = function(C)
        assert(type(C) == "function", "Cleanup must be callable")
        if zU.Unloaded then
            C()
        else
            table.insert(zW, C)
        end
        return C
    end
    zU.Unload = function()
        local zK_1
        local zJ_1
        if zU.Unloaded then
            return
        end
        zU.Unloaded = true
        local zH = {}
        local zO = #zW
        local zN = -1
        while false and zO <= 1 or true and zO >= 1 do
            local zP = zO
            local zI_1 = table.remove(zW, zP)
            zJ_1, zK_1 = pcall(zI_1)
            if not zJ_1 then
                table.insert(zH, tostring(zK_1))
            end
            zO += zN
        end
        table.clear(zU.State)
        if #zH > 0 then
            error("Cleanup incomplete: " .. table.concat(zH, "; "), 0)
        end
        if zV[u] == zU then
            zV[u] = nil
        end
    end
    zV[u] = zU
    return zU
end
yE = function(P, Q)
    local z0 = type(P) == "table" and type(P.Track) == "function"
    assert(z0, "FeatureAPI required")
    local z0_1 = type(Q) == "table" and type(Q.OnUnload) == "function"
    assert(z0_1, "UI library required")
    assert(type(Q.Unload) == "function", "UI unload required")
    P.Track(function()
        if not Q.Unloaded then
            Q:Unload()
        end
    end)
    Q:OnUnload(function()
        P.Unload()
    end)
end
yc = zu(zq)
x2 = fn849
xZ = fns.fn40
zl = fn1081(ReplicatedStorage)
fn1081(Workspace)
ze = "sleitnick_knit@1.7.0"
State = yc.State
State.Notifications = {}
State.Status = "Idle"
y5 = fn703
yK = fn1374
yu = fn1087
x_ = fn637
yv = function(aP, aQ, ...)
    local Al
    local Am
    Al = nil
    Am = nil
    Al = x_(aP, "RF", aQ)
    if not Al then
        return false
    end
    Am = table.pack(...)
    local An = table.pack(pcall(function()
        return Al:InvokeServer(table.unpack(Am, 1, Am.n))
    end))
    if not An[1] then
        return false
    end
    return true, table.unpack(An, 2, An.n)
end
x3 = {}
x1 = fn1399
yM = fn305
yq = fns.fn23
yh = fn890
x4 = fns.fn15
x0 = fn969
zc = fns.fn117
y1 = fn396
yH = fn1141
yn = fn335
zj = nil
zh = fn420
yt = fn556
ye = fns.fn198
xW = {}
zk = nil
zi = fn748
x9 = fn362
y6 = nil
y_ = function()
    local BS
    local BT = type(y6) == "table" and type(y6.Data) == "table"
    if BT then
        return y6.Data
    end
    y6 = nil
    local BT_1 = debug and debug.getupvalue
    if not x2(BT_1) then
        return nil
    end
    local ReplicaClient = zl:FindFirstChild("ReplicaClient")
    local BU = not ReplicaClient or not ReplicaClient:IsA("ModuleScript")
    local BU_1
    if BU then
        return nil
    end
    BU_1, BS = pcall(require, ReplicaClient)
    local BT_3 = not BU_1 or type(BS) ~= "table" or not x2(BS.FromId)
    if BT_3 then
        return nil
    end
    local BT_4 = pcall(function()
        local BJ = debug.getupvalue(BS.FromId, 1)
        if type(BJ) ~= "table" then
            return
        end
        for k, v in pairs(BJ) do
            local BJ_1 = type(v) == "table" and type(v.Data) == "table"
            if BJ_1 then
                local Tags = v.Tags
                local BK = type(Tags) == "table" and Tags.UserId == LocalPlayer.UserId
                if BK then
                    y6 = v
                    break
                end
            end
        end
    end)
    local BU_2 = not BT_4 or type(y6) ~= "table"
    if BU_2 then
        return nil
    end
    return y6.Data
end
zb = fns.fn65
yp = fns.fn57
yg = fn265
zm = fns.fn13
y7 = fn1092
yl = fn1055
x5 = function()
    local Ct
    Ct = nil
    Ct = x9("AutorunController")
    local Cu = not Ct or not x2(Ct.Start)
    if Cu then
        yK("Autorun controller unavailable")
        return
    end
    if LocalPlayer:GetAttribute("AutoRun") == true then
        local Cu_1 = LocalPlayer:GetAttribute("IsRacing") == true and "Racing"
        local Cv = Cu_1 or "Waiting for the next race"
        yK(Cv)
        return
    end
    local Cu_2 = pcall(function()
        Ct:Start()
    end)
    if Cu_2 then
        yK("Auto race armed")
    end
end
y2 = function()
    local Cx = x9("AutorunController")
    local Cy = Cx and x2(Cx.Stop)
    if Cy then
        pcall(function()
            Cx:Stop()
        end)
    end
end
yC = function()
    local CA
    CA = nil
    if LocalPlayer:GetAttribute("IsRacing") ~= true then
        return
    end
    CA = x9("RunningController")
    local CB = not CA
    local CF = if CB then 1 else 0
    local CD = 540 * CF + 173 * (1 - CF)
    local CE = 3688 * CF + 3199 * (1 - CF)
    if not ((CD * 416 + CE * 652 + CD * CE) % 16777213 == 4620736) then
        CB = not x2(CA.Tapped)
    end
    if CB then
        return
    end
    pcall(function()
        CA:Tapped()
    end)
end
yb = fns.fn192
xY = fn1365
y4 = fn219
yz = fn297
x6 = fn1249
yk = { interval = 2 }
yf = fn606
ya = fn946
yF = { interval = 10 }
yA = fn692
xX = fn1214
yd = fn980
yG = fn357
ym = { interval = 5, brainrots = {}, rarities = {}, mutations = {}, sizes = {}, sellEggs = false }
yi = fn1200
x7 = fn1281
yo = fn1031
yZ = { interval = 5, allowed = {}, maxCost = 0 }
yV = { interval = 5, allowed = {}, maxCost = 0 }
yS = fns.fn42
yW = fn624
yL = fn388
yw = { interval = 60, includeVip = false }
ys = fn311
zn = fn250
y8 = { interval = 5 }
y0 = { interval = 0.2 }
yX = { interval = 0.3 }
yT = { interval = 5 }
yP = { interval = 3 }
yN = { interval = 30 }
yI = { interval = 30 }
yB = { interval = 10 }
yx = function(hA, hB)
    local generation
    local Fw = hA.generation or 0
    hA.generation = Fw + 1
    hA.stopped = false
    generation = hA.generation
    task.spawn(function()
        local Ft_1
        while true do
            local Fs = xZ() and not hA.stopped and hA.generation == generation
            local Fs_1
            if Fs then
                Fs_1, Ft_1 = pcall(hB)
                if not Fs_1 then
                    warn("[Tempo] loop error: " .. tostring(Ft_1))
                end
                local Fs_2 = not xZ() or hA.stopped or hA.generation ~= generation
                if Fs_2 then
                    break
                end
                task.wait(hA.interval)
                continue
            end
            break
        end
    end)
end
zo = fns.fn18
zf = fn1205
yQ = fns.fn26
connection2 = nil
y8.SetEnabled = fn1233
y0.SetEnabled = fn1355
y0.SetDelay = fn380
yX.SetEnabled = fn517
yX.SetDelay = fn486
connection = nil
yT.SetEnabled = fn285
yT.SetDelay = fns.fn118
yk.SetEnabled = fn779
yk.SetDelay = fn1025
yP.SetEnabled = fn289
yP.SetDelay = fn1063
yF.SetEnabled = fns.fn98
yF.SetDelay = fns.fn1
yN.SetEnabled = fns.fn31
yI.SetEnabled = fn507
yB.SetEnabled = fn612
yB.SetDelay = fn630
ym.SetEnabled = fn792
ym.SetDelay = fn543
ym.SetBrainrots = fn1022
ym.SetRarities = fn649
ym.SetMutations = fn589
ym.SetSizes = fn1019
ym.SetSellEggs = fns.fn7
yZ.SetEnabled = fn1326
yZ.SetDelay = fn1066
yZ.SetAllowed = fn1313
yZ.SetMaxCost = fn1163
yV.SetEnabled = fn298
yV.SetDelay = fn213
yV.SetAllowed = fn1335
yV.SetMaxCost = fn282
yw.SetEnabled = fn920
yw.SetIncludeVip = fn286
yc.Track(fn364)
local function zs()
    local G9
    G9 = false
    task.spawn(function()
        pcall(yM)
        pcall(yq)
        pcall(yh)
        pcall(x4)
        pcall(x0)
        pcall(zc)
        pcall(y1)
        pcall(yH)
        pcall(zh)
        pcall(y_)
        local G1 = os.clock() + 6
        repeat
            local G2 = x9("AutorunController")
            local G3 = x9("RunningController")
            if G2 and G3 then
                break
            end
            task.wait(0.2)
        until os.clock() >= G1
        G9 = true
    end)
    local Ha = os.clock() + 8
    while true do
        local Hb = not G9 and os.clock() < Ha
        if Hb then
            task.wait(0.05)
            continue
        end
        break
    end
end
if ((false or zm) and (y0 and not yf) or yf and false and (ze and zm)) and not ((false or zm) and (y0 and not yf) or yf and false and (ze and zm)) then
    ye = function()
        local onDiscord
        local LJ
        local LF
        onDiscord = nil
        LF = nil
        LJ = nil
        local Ls, Lt, SaveManager, Lv, Lx, Ly, Lz, Library, LB, Toggles, LD, LE, ThemeManager, LH, Options
        Lv = "Race for Eggs"
        Lz = "https://discord.gg/K7Qxnxkk46"
        LE = "https://tempohub.shop"
        LJ = "https://discord.gg/K7Qxnxkk46"
        Library = getgenv().Library
        ThemeManager = getgenv().ThemeManager
        SaveManager = getgenv().SaveManager
        Toggles = Library.Toggles
        Options = Library.Options
        yE(yc, Library)
        Lx = yt()
        Ls = ye()
        Lt = yn(x4(), false)
        LH = yn(x0(), false)
        LD = yn(yM(), true)
        Ly = yn(yq(), true)
        LF = function(k8, k9)
            local Hg = x2(setclipboard) and setclipboard
            local Hh = Hg
            if not Hh then
                local Hg_3 = x2(toclipboard) and toclipboard
                Hh = Hg_3 or nil
            end
            local Hg_4 = Hh
            if not Hg_4 then
                Library:Notify("Clipboard is unavailable")
                return
            end
            local Hh_2 = pcall(Hg_4, k8)
            if Hh_2 then
                Library:Notify(k9)
            else
                Library:Notify("Failed to copy")
            end
        end
        onDiscord = function()
            LF(LJ, "Copied Discord invite to clipboard")
        end
        local Window = Library:CreateWindow({
            Title = "Tempo",
            Font = Enum.Font.BuilderSans,
            Footer = { { Text = LJ, Copyable = true }, "|", Lv, "|", "v0.1" },
            Icon = 78539693571783,
            NotifySide = "Right",
            ShowCustomCursor = false,
            CornerRadius = 0,
            SidebarCompacted = true,
            TabSwipeFrom = "bottom",
            Animations = { TabSwitch = true }
        })
        Window:SetGlow(false)
        LB = {
            Info = Window:AddTab("Info", "info"),
            Main = Window:AddTab("Main", "gamepad-2"),
            Player = Window:AddTab("Player", "person-standing"),
            Settings = Window:AddTab("Settings", "settings")
        }
        local function LK(lm)
            local DiscordGroup = lm:AddLeftGroupbox("Discord")
            DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
            DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
        end
        for k, v in LB do
            if k ~= "Info" then
                LK(v)
            end
        end
        local function LL_2()
            local nF
            local RacingGroup = LB.Main:AddLeftGroupbox("Racing", "flag")
            local Label = RacingGroup:AddLabel(State.Status, true)
            RacingGroup:AddDivider()
            RacingGroup:AddToggle("AutoRace", {
                Text = "Auto Race",
                Default = false,
                Tooltip = "Arms the game's own autorun so you join every race that opens. Races open on a server timer, so idle gaps are normal.",
                Callback = function(lx)
                    y8.SetEnabled(lx)
                end
            })
            RacingGroup:AddToggle("AutoTap", {
                Text = "Auto Tap",
                Default = false,
                Tooltip = "Taps for you while a race is running.",
                Callback = function(lB)
                    y0.SetEnabled(lB)
                end
            })
            RacingGroup:AddSlider("TapDelay", {
                Text = "Tap Delay",
                Default = 0.2,
                Min = 0.05,
                Max = 2,
                Rounding = 2,
                Suffix = "s",
                Callback = function(lF)
                    y0.SetDelay(lF)
                end
            })
            RacingGroup:AddDivider("Training")
            RacingGroup:AddToggle("AutoTrain", {
                Text = "Auto Train",
                Default = false,
                Tooltip = "Swings your dumbbell to raise Speed.",
                Callback = function(lH)
                    yX.SetEnabled(lH)
                end
            })
            RacingGroup:AddSlider("TrainDelay", {
                Text = "Train Delay",
                Default = 0.3,
                Min = 0.1,
                Max = 5,
                Rounding = 2,
                Suffix = "s",
                Callback = function(lL)
                    yX.SetDelay(lL)
                end
            })
            RacingGroup:AddToggle("AutoBonus", {
                Text = "Auto 2x Bonus",
                Default = false,
                Tooltip = "Claims the 2x training bonus the moment it spawns.",
                Callback = function(lN)
                    yT.SetEnabled(lN)
                end
            })
            RacingGroup:AddSlider("BonusDelay", {
                Text = "Bonus Check Delay",
                Default = 5,
                Min = 1,
                Max = 60,
                Rounding = 1,
                Suffix = "s",
                Callback = function(lR)
                    yT.SetDelay(lR)
                end
            })
            RacingGroup:AddDivider("Rebirth")
            RacingGroup:AddToggle("AutoRebirth", {
                Text = "Auto Rebirth",
                Default = false,
                Tooltip = "Rebirths as soon as you can pay the next tier's cash cost.",
                Callback = function(lT)
                    yF.SetEnabled(lT)
                end
            })
            RacingGroup:AddSlider("RebirthDelay", {
                Text = "Rebirth Delay",
                Default = 10,
                Min = 1,
                Max = 120,
                Rounding = 1,
                Suffix = "s",
                Callback = function(lX)
                    yF.SetDelay(lX)
                end
            })
            local PlotGroup = LB.Main:AddLeftGroupbox("Plot", "layout-grid")
            PlotGroup:AddToggle("AutoPlaceEggs", {
                Text = "Auto Place Eggs",
                Default = false,
                Tooltip = "Drops every egg in your inventory onto a free spot on your plot.",
                Callback = function(l_)
                    yk.SetEnabled(l_)
                end
            })
            PlotGroup:AddSlider("PlaceEggDelay", {
                Text = "Place Delay",
                Default = 2,
                Min = 0.5,
                Max = 30,
                Rounding = 1,
                Suffix = "s",
                Callback = function(l3)
                    yk.SetDelay(l3)
                end
            })
            PlotGroup:AddToggle("AutoHatchEggs", {
                Text = "Auto Hatch Eggs",
                Default = false,
                Tooltip = "Hatches your placed eggs the second their timer runs out.",
                Callback = function(l5)
                    yP.SetEnabled(l5)
                end
            })
            PlotGroup:AddSlider("HatchDelay", {
                Text = "Hatch Delay",
                Default = 3,
                Min = 0.5,
                Max = 30,
                Rounding = 1,
                Suffix = "s",
                Callback = function(l9)
                    yP.SetDelay(l9)
                end
            })
            PlotGroup:AddDivider("Pets")
            PlotGroup:AddToggle("AutoEquipBest", {
                Text = "Auto Equip Best Pet",
                Default = false,
                Tooltip = "Keeps your highest earning brainrots placed on the plot.",
                Callback = function(mb)
                    yB.SetEnabled(mb)
                end
            })
            PlotGroup:AddSlider("EquipBestDelay", {
                Text = "Equip Delay",
                Default = 10,
                Min = 1,
                Max = 120,
                Rounding = 1,
                Suffix = "s",
                Callback = function(mf)
                    yB.SetDelay(mf)
                end
            })
            local SellingGroup = LB.Main:AddRightGroupbox("Selling", "coins")
            SellingGroup:AddToggle("AutoSell", {
                Text = "Auto Sell",
                Default = false,
                Tooltip = "Sells the inventory brainrots that match the filters below. Placed brainrots are never touched.",
                Callback = function(mi)
                    ym.SetEnabled(mi)
                end
            })
            SellingGroup:AddDropdown("SellBrainrots", {
                Text = "Sell Brainrots",
                Values = Lx,
                Default = {},
                Multi = true,
                AllowNull = true,
                Tooltip = "Leave everything unticked to ignore this filter.",
                Callback = function(mn)
                    ym.SetBrainrots(mn)
                end
            })
            SellingGroup:AddDropdown("SellRarities", {
                Text = "Sell Rarities",
                Values = Ls,
                Default = {},
                Multi = true,
                AllowNull = true,
                Tooltip = "Leave everything unticked to ignore this filter.",
                Callback = function(mq)
                    ym.SetRarities(mq)
                end
            })
            SellingGroup:AddDropdown("SellMutations", {
                Text = "Sell Mutations",
                Values = Lt,
                Default = {},
                Multi = true,
                AllowNull = true,
                Tooltip = "Leave everything unticked to ignore this filter.",
                Callback = function(mt)
                    ym.SetMutations(mt)
                end
            })
            SellingGroup:AddDropdown("SellSizes", {
                Text = "Sell Sizes",
                Values = LH,
                Default = {},
                Multi = true,
                AllowNull = true,
                Tooltip = "Leave everything unticked to ignore this filter.",
                Callback = function(mw)
                    ym.SetSizes(mw)
                end
            })
            SellingGroup:AddToggle("SellEggsToo", {
                Text = "Sell Eggs Too",
                Default = false,
                Tooltip = "Also sells every egg sitting in your inventory.",
                Callback = function(my)
                    ym.SetSellEggs(my)
                end
            })
            SellingGroup:AddSlider("SellDelay", {
                Text = "Sell Delay",
                Default = 5,
                Min = 1,
                Max = 60,
                Rounding = 1,
                Suffix = "s",
                Callback = function(mA)
                    ym.SetDelay(mA)
                end
            })
            local ShopGroup = LB.Main:AddRightGroupbox("Shop", "shopping-cart")
            ShopGroup:AddToggle("AutoBuyWeights", {
                Text = "Auto Buy Weights",
                Default = false,
                Tooltip = "Buys the cheapest dumbbell you can afford, then equips the strongest one you own.",
                Callback = function(mD)
                    yZ.SetEnabled(mD)
                end
            })
            ShopGroup:AddDropdown("WeightList", {
                Text = "Weights",
                Values = LD,
                Default = {},
                Multi = true,
                AllowNull = true,
                Tooltip = "Leave everything unticked to buy any dumbbell.",
                Callback = function(mI)
                    yZ.SetAllowed(mI)
                end
            })
            ShopGroup:AddSlider("WeightMaxCost", {
                Text = "Max Weight Cost",
                Default = 0,
                Min = 0,
                Max = 1000000000,
                Rounding = 0,
                Tooltip = "Skips dumbbells above this price. 0 removes the limit.",
                Callback = function(mK)
                    yZ.SetMaxCost(mK)
                end
            })
            ShopGroup:AddSlider("WeightDelay", {
                Text = "Buy Weight Delay",
                Default = 5,
                Min = 1,
                Max = 60,
                Rounding = 1,
                Suffix = "s",
                Callback = function(mM)
                    yZ.SetDelay(mM)
                end
            })
            ShopGroup:AddDivider("Dice")
            ShopGroup:AddToggle("AutoBuyDice", {
                Text = "Auto Buy Dice",
                Default = false,
                Tooltip = "Buys the cheapest player skin you can afford, then equips the luckiest one you own.",
                Callback = function(mO)
                    yV.SetEnabled(mO)
                end
            })
            ShopGroup:AddDropdown("DiceList", {
                Text = "Dice",
                Values = Ly,
                Default = {},
                Multi = true,
                AllowNull = true,
                Tooltip = "Leave everything unticked to buy any skin.",
                Callback = function(mT)
                    yV.SetAllowed(mT)
                end
            })
            ShopGroup:AddSlider("DiceMaxCost", {
                Text = "Max Dice Cost",
                Default = 0,
                Min = 0,
                Max = 1000000000,
                Rounding = 0,
                Tooltip = "Skips skins above this price. 0 removes the limit.",
                Callback = function(mV)
                    yV.SetMaxCost(mV)
                end
            })
            ShopGroup:AddSlider("DiceDelay", {
                Text = "Buy Dice Delay",
                Default = 5,
                Min = 1,
                Max = 60,
                Rounding = 1,
                Suffix = "s",
                Callback = function(mX)
                    yV.SetDelay(mX)
                end
            })
            local RewardsGroup = LB.Main:AddRightGroupbox("Rewards", "gift")
            RewardsGroup:AddToggle("AutoPlaytime", {
                Text = "Auto Claim Playtime Rewards",
                Default = false,
                Callback = function(m_)
                    yN.SetEnabled(m_)
                end
            })
            RewardsGroup:AddToggle("AutoEventPass", {
                Text = "Auto Claim Event Pass",
                Default = false,
                Tooltip = "Claims every free season pass tier you have reached, and the paid tiers you own.",
                Callback = function(m3)
                    yI.SetEnabled(m3)
                end
            })
            RewardsGroup:AddToggle("AutoDaily", {
                Text = "Auto Claim Daily Rewards",
                Default = false,
                Callback = function(m7)
                    yw.SetEnabled(m7)
                end
            })
            RewardsGroup:AddToggle("DailyIncludeVip", {
                Text = "Include VIP Reward",
                Default = false,
                Tooltip = "Also tries the VIP half of the daily reward. It needs the matching gamepass.",
                Callback = function(nb)
                    yw.SetIncludeVip(nb)
                end
            })
            local TeleportGroup = LB.Main:AddRightGroupbox("Teleport", "map-pin")
            TeleportGroup:AddButton({ Text = "Teleport To Base", Func = zn })
            nF = task.spawn(function()
                while not Library.Unloaded do
                    pcall(function()
                        local Hk = #y7()
                        local Hl = LocalPlayer:GetAttribute("IsRacing") == true and "racing"
                        local Hm = Hl or "idle"
                        local Hm_2 = string.format("Cash %d  |  Speed %d  |  Rebirth %d  |  %s  |  Bag %d", math.floor(yp()), math.floor(yg()), zm(), Hm, Hk)
                        Label:SetText(Hm_2 .. "  |  " .. tostring(State.Status))
                    end)
                    local Hs = false
                    repeat
                        local Ho
                        if State.Notifications and #State.Notifications > 0 then
                            Ho = table.remove(State.Notifications, 1)
                            pcall(function()
                                Library:Notify(Ho.text, Ho.time)
                            end)
                        else
                            Hs = true
                        end
                    until Hs
                    task.wait(0.3)
                end
            end)
            yc.Track(function()
                if coroutine.status(nF) ~= "dead" then
                    pcall(task.cancel, nF)
                end
            end)
        end
        LL_2()
        local function LK_5()
            local HO
            local HP
            local HN
            local HS
            HN = nil
            HO = nil
            HP = nil
            HS = nil
            local HJ, HK, HL, Label, HQ, Label2, HT, HU, Label3
            HP = function(nK)
                return (tostring(nK):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
            end
            HS = function(nM, nN)
                return string.format('<font color="%s">%s</font>', nN, HP(nM))
            end
            HQ = function(nQ, nR, nS)
                return string.format("<b>%s</b> %s %s", nQ, HS("-", "#5a6070"), HS(nR, nS))
            end
            HL = "#e8a34d"
            HT = "#7fd47f"
            local HW = "#6ec1ff"
            local HX = {}
            local HY = "#8b93a3"
            if not yu() then
                table.insert(HX, "every server action")
            end
            if not x9("AutorunController") then
                table.insert(HX, "auto race")
            end
            if not x9("RunningController") then
                table.insert(HX, "auto tap")
            end
            local HZ = debug and debug.getupvalue
            local H_ = not x2(HZ) or not y_()
            if H_ then
                table.insert(HX, "cash, inventory and claim state")
            end
            if not yh() then
                table.insert(HX, "sell filters")
            end
            if not yM() then
                table.insert(HX, "buying weights")
            end
            local H3 = if not yq() then 1 else 0
            if H3 == 1 then
                table.insert(HX, "buying dice")
            end
            local HZ_5 = not x2(setclipboard) and not x2(toclipboard)
            if HZ_5 then
                table.insert(HX, "clipboard copies")
            end
            local HZ_6 = #HX == 0 and "ready"
            local H__2 = HZ_6 or "limited: " .. table.concat(HX, ", ")
            HJ = "Unknown"
            pcall(function()
                local Hv_2
                local Hu_3
                if x2(identifyexecutor) then
                    Hv_2, Hu_3 = identifyexecutor()
                    local Hw = Hv_2 ~= ""
                    local Hx = type(Hv_2) == "string" and Hw
                    if Hx then
                        local Hw_2 = type(Hu_3) == "string" and Hu_3 ~= "" and Hv_2 .. " " .. Hu_3
                        local Hu_4 = Hw_2
                        local HB = if Hu_4 then 1 else 0
                        local Hz = 4001 * HB + 3810 * (1 - HB)
                        local HA = 3250 * HB + 176 * (1 - HB)
                        if not ((Hz * 1906 + HA * 2561 + Hz * HA) % 16777213 == 12175193) then
                            Hu_4 = Hv_2
                        end
                        HJ = Hu_4
                    end
                end
            end)
            HO = os.clock()
            HU = function()
                local HC = math.floor(os.clock() - HO)
                if HC < 60 then
                    return HC .. "s"
                elseif HC < 3600 then
                    return string.format("%dm %ds", math.floor((HC) / (60)), HC % 60)
                else
                    return string.format("%dh %dm", math.floor((HC) / (3600)), math.floor((HC % 3600) / (60)))
                end
            end
            local UserGroup = LB.Info:AddLeftGroupbox("User", "circle-user")
            UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
            UserGroup:AddLabel(HQ("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, HT), true)
            UserGroup:AddLabel(HQ("UserId", tostring(LocalPlayer.UserId), HW), true)
            UserGroup:AddLabel(HQ("Executor", HJ .. "  " .. H__2, HT), true)
            UserGroup:AddDivider()
            Label3 = UserGroup:AddLabel(HQ("Session", HU(), HL), true)
            UserGroup:AddDivider()
            UserGroup:AddButton({
                Text = "Copy Username",
                Func = function()
                    LF(LocalPlayer.Name, "Copied username")
                end
            })
            UserGroup:AddButton({
                Text = "Copy Profile Link",
                Func = function()
                    LF("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
                end
            })
            local SessionGroup = LB.Info:AddRightGroupbox("Session", "signal")
            SessionGroup:AddLabel(HQ("Game", Lv, HW), true)
            Label2 = SessionGroup:AddLabel(HQ("Players", "0/0", HT), true)
            HK = tostring(game.JobId)
            local HW_4 = #HK > 18 and string.sub(HK, 1, 18) .. "..."
            local HZ_8 = HW_4 or HK
            SessionGroup:AddLabel(HQ("Job", HZ_8, HY), true)
            Label = SessionGroup:AddLabel(HQ("Ping", "0 ms", HL), true)
            SessionGroup:AddDivider()
            SessionGroup:AddButton({
                Text = "Rejoin Place",
                Func = function()
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end
            })
            SessionGroup:AddButton({
                Text = "Copy Job ID",
                Func = function()
                    LF(HK, "Copied Job ID")
                end
            })
            HN = task.spawn(function()
                local HF_2
                local HE_3
                while true do
                    task.wait(1)
                    if Library.Unloaded then
                        break
                    end
                    Label3:SetText(HQ("Session", HU(), HL))
                    Label2:SetText(HQ("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), HT))
                    HE_3, HF_2 = pcall(function()
                        return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                    end)
                    local HE_4 = HE_3 and HF_2 .. " ms" or "n/a"
                    Label:SetText(HQ("Ping", HE_4, HL))
                end
            end)
            yc.Track(function()
                if coroutine.status(HN) ~= "dead" then
                    task.cancel(HN)
                end
            end)
            local SocialsGroup = LB.Info:AddRightGroupbox("Socials", "link")
            SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
            SocialsGroup:AddButton({
                Text = "Rscripts",
                Func = function()
                    LF(Lz, "Copied Rscripts profile")
                end
            })
            SocialsGroup:AddButton({
                Text = "Website",
                Func = function()
                    LF(LE, "Copied website link")
                end
            })
        end
        LK_5()
        local function LK_6()
            local ph
            local pf
            local pg
            local pi
            local MovementGroup = LB.Player:AddLeftGroupbox("Movement", "footprints")
            MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
            MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
            MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
            MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
            MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
            local FlyGroup = LB.Player:AddRightGroupbox("Fly", "feather")
            FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
            FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
            pg = {}
            ph = {}
            pi = {}
            local pe = {}
            pf = {}
            local function pj()
                for k, v in pf do
                    if k.Parent then
                        k.CanCollide = v
                    end
                end
                table.clear(pf)
            end
            local function pn()
                for k, v in pg do
                    if k.Parent then
                        k.WalkSpeed = v
                    end
                end
                table.clear(pg)
            end
            local function pr()
                for k, v in ph do
                    if k.Parent then
                        k.PlatformStand = v
                    end
                end
                table.clear(ph)
            end
            local function pv(pw)
                local Is = if not pw:IsA("ProximityPrompt") then 1 else 0
                if Is == 1 then
                    return
                end
                if pi[pw] == nil then
                    pi[pw] = {
                        HoldDuration = pw.HoldDuration,
                        MaxActivationDistance = pw.MaxActivationDistance,
                        RequiresLineOfSight = pw.RequiresLineOfSight
                    }
                end
                pw.HoldDuration = 0
                pw.MaxActivationDistance = 50
                pw.RequiresLineOfSight = false
            end
            local function py()
                for k, v in pi do
                    if k.Parent then
                        k.HoldDuration = v.HoldDuration
                        k.MaxActivationDistance = v.MaxActivationDistance
                        k.RequiresLineOfSight = v.RequiresLineOfSight
                    end
                end
                table.clear(pi)
            end
            Toggles.Fly:OnChanged(function()
                if not Toggles.Fly.Value then
                    pr()
                end
            end)
            Toggles.WalkSpeedEnabled:OnChanged(function()
                if not Toggles.WalkSpeedEnabled.Value then
                    pn()
                end
            end)
            Toggles.NoClip:OnChanged(function()
                if not Toggles.NoClip.Value then
                    pj()
                end
            end)
            Toggles.InstantProximityPrompt:OnChanged(function()
                if Toggles.InstantProximityPrompt.Value then
                    for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                        pcall(pv, v)
                    end
                else
                    py()
                end
            end)
            table.insert(pe, Workspace.DescendantAdded:Connect(function(pR)
                if Toggles.InstantProximityPrompt.Value then
                    pv(pR)
                end
            end))
            table.insert(pe, RunService.Stepped:Connect(function()
                if Library.Unloaded then
                    return
                end
                local Character = LocalPlayer.Character
                if Toggles.NoClip.Value and Character then
                    for k, v in Character:QueryDescendants("BasePart") do
                        if pf[v] == nil then
                            pf[v] = v.CanCollide
                        end
                        v.CanCollide = false
                    end
                end
            end))
            table.insert(pe, UserInputService.JumpRequest:Connect(function()
                if Library.Unloaded then
                    return
                end
                local Character = LocalPlayer.Character
                local IV = Character and Character:FindFirstChildOfClass("Humanoid")
                if Toggles.InfJump.Value and IV then
                    IV:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end))
            table.insert(pe, RunService.RenderStepped:Connect(function(qc)
                if Library.Unloaded then
                    return
                end
                local Character = LocalPlayer.Character
                local IY = Character and Character:FindFirstChildOfClass("Humanoid")
                local IZ = Character
                if IZ then
                    IZ = Character:FindFirstChild("HumanoidRootPart")
                end
                local IX_2 = IZ
                local CurrentCamera = Workspace.CurrentCamera
                if Toggles.WalkSpeedEnabled.Value and IY then
                    if pg[IY] == nil then
                        pg[IY] = IY.WalkSpeed
                    end
                    IY.WalkSpeed = Options.WalkSpeed.Value
                end
                if Toggles.Fly.Value and IX_2 and IY and CurrentCamera then
                    if ph[IY] == nil then
                        ph[IY] = IY.PlatformStand
                    end
                    IY.PlatformStand = true
                    local IZ_8 = Vector3.zero
                    if not UserInputService:GetFocusedTextBox() then
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            IZ_8 += CurrentCamera.CFrame.LookVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            IZ_8 -= CurrentCamera.CFrame.LookVector
                        end
                        local I4 = if UserInputService:IsKeyDown(Enum.KeyCode.A) then 1 else 0
                        if I4 == 1 then
                            IZ_8 -= CurrentCamera.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                            IZ_8 += CurrentCamera.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            IZ_8 += Vector3.new(0, 1, 0)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                            IZ_8 -= Vector3.new(0, 1, 0)
                        end
                    end
                    IX_2.AssemblyLinearVelocity = Vector3.zero
                    if IZ_8.Magnitude > 0 then
                        IX_2.CFrame = IX_2.CFrame + IZ_8.Unit * Options.FlySpeed.Value * qc
                    end
                end
            end))
            yc.Track(function()
                for k, v in pe do
                    v:Disconnect()
                end
                pj()
                pn()
                pr()
                py()
            end)
        end
        LK_6()
        local function LK_7()
            local Kb, Kc, Kd, Ke, Kf, Kg, Kh, Ki, Kj, Kk, Label, Km, Kn, Ko
            Km = {}
            Kg = {}
            Kd = nil
            Ko = 0
            Ke = 0
            Ki = false
            Kj = os.clock()
            local MenuGroup = LB.Settings:AddLeftGroupbox("Menu", "logs")
            MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
            Label = MenuGroup:AddLabel("AFK triggers: 0")
            Kb = function()
                local CurrentCamera
                CurrentCamera = Workspace.CurrentCamera
                local Jd = not CurrentCamera or not x2(VirtualUser.CaptureController) or not x2(VirtualUser.ClickButton2)
                if Jd then
                    return false
                end
                local Jd_2 = pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
                end)
                if not Jd_2 then
                    return false
                end
                Ke += 1
                Kj = os.clock()
                pcall(function()
                    Label:SetText("AFK triggers: " .. Ke)
                end)
                return true
            end
            Kk = function(qW)
                pcall(function()
                    GuiService:SetGameplayPausedNotificationEnabled(not qW)
                end)
                pcall(function()
                    local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                    if RobloxNetworkPauseNotificati then
                        RobloxNetworkPauseNotificati.Enabled = not qW
                    end
                end)
                if not qW then
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
            Kh = function(rb)
                local Jm = rb.ClassName == "ParticleEmitter" or rb.ClassName == "Trail"
                local Jq = if Jm then 1 else 0
                local Jo = 3265 * Jq + 1343 * (1 - Jq)
                local Jp = 661 * Jq + 1064 * (1 - Jq)
                if not ((Jo * 3669 + Jp * 559 + Jo * Jp) % 16777213 == 14506949) then
                    Jm = rb.ClassName == "Smoke"
                end
                if not Jm then
                    Jm = rb.ClassName == "Fire"
                end
                if not Jm then
                    Jm = rb.ClassName == "Sparkles"
                end
                local Jt = if Jm then 1 else 0
                local Jr = 1011 * Jt + 786 * (1 - Jt)
                local Js = 4039 * Jt + 3443 * (1 - Jt)
                if not ((Jr * 1710 + Js * 3650 + Jr * Js) % 16777213 == 3777376) then
                    Jm = rb.ClassName == "Explosion"
                end
                local Jt_2 = if Jm then 1 else 0
                local Jr_2 = 456 * Jt_2 + 2564 * (1 - Jt_2)
                local Js_2 = 3940 * Jt_2 + 227 * (1 - Jt_2)
                if not ((Jr_2 * 4052 + Js_2 * 3211 + Jr_2 * Js_2) % 16777213 == 16295692) then
                    Jm = rb.ClassName == "Beam"
                end
                if Jm then
                    if Km[rb] == nil then
                        Km[rb] = rb.Enabled
                    end
                    pcall(function()
                        rb.Enabled = false
                    end)
                end
            end
            Kf = function()
                for k, v in Km do
                    local Jy = k
                    local JA = v
                    if Jy.Parent then
                        pcall(function()
                            Jy.Enabled = JA
                        end)
                    end
                end
                table.clear(Km)
                if Kd then
                    pcall(function()
                        settings().Rendering.QualityLevel = Kd.Quality
                    end)
                    Lighting.GlobalShadows = Kd.Shadows
                    Lighting.FogEnd = Kd.Fog
                    Kd = nil
                end
            end
            MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
            MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
            MenuGroup:AddToggle("Disable3D", {
                Text = "Disable 3D Rendering",
                Default = false,
                Callback = function(rq)
                    pcall(function()
                        RunService:Set3dRenderingEnabled(not rq)
                    end)
                end
            })
            MenuGroup:AddToggle("FpsBoost", {
                Text = "FPS Boost",
                Default = false,
                Callback = function(rv)
                    if rv then
                        if not Kd then
                            Kd = {
                                Quality = settings().Rendering.QualityLevel,
                                Shadows = Lighting.GlobalShadows,
                                Fog = Lighting.FogEnd
                            }
                        end
                        pcall(function()
                            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                        end)
                        Lighting.GlobalShadows = false
                        Lighting.FogEnd = 9000000000
                        for k, v in Workspace:QueryDescendants("ParticleEmitter,Trail,Smoke,Fire,Sparkles,Beam") do
                            pcall(Kh, v)
                        end
                    else
                        Kf()
                    end
                end
            })
            MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
            MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
            Library.ToggleKeybind = Options.MenuKeybind
            Kk(true)
            local ScriptGroup = LB.Settings:AddLeftGroupbox("Script", "terminal")
            ScriptGroup:AddButton({
                Text = "Unload Script",
                Func = function()
                    Library:Unload()
                end
            })
            Toggles.AntiGameplayPause:OnChanged(function()
                Kk(Toggles.AntiGameplayPause.Value)
            end)
            if Toggles.AntiGameplayPause.Value then
                Kk(true)
            end
            table.insert(Kg, LocalPlayer.Idled:Connect(function()
                if Toggles.AntiAfk.Value and not Library.Unloaded then
                    Kb()
                end
            end))
            table.insert(Kg, Workspace.DescendantAdded:Connect(function(rO)
                if Toggles.FpsBoost.Value then
                    Kh(rO)
                end
            end))
            Kc = function(rS)
                local JO = Ki or Library.Unloaded
                local JT = if JO then 1 else 0
                local JR = 1248 * JT + 2588 * (1 - JT)
                local JS = 3818 * JT + 1963 * (1 - JT)
                if not ((JR * 1400 + JS * 1931 + JR * JS) % 16777213 == 13884622) then
                    JO = not Toggles.AutoReconnect.Value
                end
                if JO then
                    return
                end
                Ki = true
                local JN = Ko
                local JO_3 = pcall(function()
                    if rS then
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    else
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                    end
                end)
                if not JO_3 then
                    Ki = false
                    if not rS and JN == Ko then
                        task.delay(1.5, function()
                            if JN == Ko then
                                Kc(true)
                            end
                        end)
                    end
                end
            end
            table.insert(Kg, TeleportService.TeleportInitFailed:Connect(function(r9)
                local JV
                if r9 == LocalPlayer and Ki then
                    Ki = false
                    JV = Ko
                    task.delay(3, function()
                        if JV == Ko then
                            Kc(true)
                        end
                    end)
                end
            end))
            task.spawn(function()
                local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
                local J_ = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
                if Library.Unloaded or not J_ then
                    return
                end
                table.insert(Kg, J_.ChildAdded:Connect(function(so)
                    if so.Name == "ErrorPrompt" then
                        Kc(false)
                    end
                end))
            end)
            Kn = task.spawn(function()
                while not Library.Unloaded do
                    if Toggles.AntiGameplayPause.Value then
                        Kk(true)
                    end
                    local J2 = Toggles.AntiAfk.Value and os.clock() - Kj >= 60
                    if J2 then
                        Kb()
                    end
                    task.wait(1)
                end
            end)
            yc.Track(function()
                Ko += 1
                for k, v in Kg do
                    v:Disconnect()
                end
                pcall(task.cancel, Kn)
                Kk(false)
                Kf()
                pcall(function()
                    RunService:Set3dRenderingEnabled(true)
                end)
            end)
        end
        LK_7()
        local function LK_8()
            local Lj, Lk, Ll, Lm
            ThemeManager:SetLibrary(Library)
            ThemeManager:SetFolder("TempoHub")
            ThemeManager:SaveDefault("Evil Hello Kitty")
            ThemeManager:ApplyToTab(LB.Settings)
            SaveManager:SetLibrary(Library)
            SaveManager:IgnoreThemeSettings()
            SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
            SaveManager:SetFolder("TempoHub/RaceForEggs")
            local Ln = SaveManager:BuildConfigSection(LB.Settings)
            Lm = function(sP, sQ)
                local Ks_2 = (sP == "Toggle" and Toggles or Options)[sQ]
                local Kr_5 = type(Ks_2) == "table" and Ks_2.Type == sP
                local Kr_6 = Kr_5 and Ks_2
                local Kx = if Kr_6 then 1 else 0
                local Kv = 1793 * Kx + 2963 * (1 - Kx)
                local Kw = 840 * Kx + 719 * (1 - Kx)
                if not ((Kv * 2927 + Kw * 3881 + Kv * Kw) % 16777213 == 10014271) then
                    Kr_6 = nil
                end
                return Kr_6
            end
            Lk = function(sZ, s_)
                local Type = s_.Type
                if Type == "Toggle" then
                    return { idx = sZ, type = "Toggle", value = s_.Value == true }
                elseif Type == "Slider" then
                    return { idx = sZ, type = "Slider", value = tostring(s_.Value) }
                elseif Type == "Dropdown" then
                    return { idx = sZ, type = "Dropdown", multi = s_.Multi == true, value = s_.Value }
                elseif Type == "Input" then
                    local Kz = s_.Value or ""
                    return { idx = sZ, type = "Input", text = tostring(Kz) }
                elseif Type == "ColorPicker" then
                    return { idx = sZ, type = "ColorPicker", value = s_.Value:ToHex(), transparency = s_.Transparency }
                elseif Type == "KeyPicker" then
                    return {
                        idx = sZ,
                        type = "KeyPicker",
                        mode = s_.Mode,
                        key = s_.Value,
                        modifiers = s_.Modifiers,
                        toggled = s_.Toggled
                    }
                else
                    return nil
                end
            end
            Lj = function()
                local KF = {}
                for i, v in ipairs({ Toggles, Options }) do
                    for k, v in pairs(v) do
                        local KG = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                        if KG then
                            local KG_2 = Lk(k, v)
                            if KG_2 then
                                KF[#KF + 1] = KG_2
                            end
                        end
                    end
                end
                table.sort(KF, function(s9, ta)
                    if s9.type ~= ta.type then
                        return s9.type < ta.type
                    end
                    return s9.idx < ta.idx
                end)
                return { objects = KF }
            end
            Ll = function(tc)
                local KZ
                KZ = nil
                local K_ = type(tc) ~= "table" or type(tc.idx) ~= "string" or type(tc.type) ~= "string" or SaveManager.Ignore[tc.idx]
                if K_ then
                    return false
                end
                KZ = Lm(tc.type, tc.idx)
                if not KZ then
                    return false
                end
                local K__2 = pcall(function()
                    if tc.type == "Input" then
                        if type(tc.text) ~= "string" then
                            return
                        end
                        KZ:SetValue(tc.text)
                    elseif tc.type == "ColorPicker" then
                        KZ:SetValueRGB(Color3.fromHex(tc.value), tc.transparency)
                    elseif tc.type == "KeyPicker" then
                        KZ:SetValue({ tc.key, tc.mode, tc.modifiers })
                        if tc.mode == "Toggle" and tc.toggled ~= nil then
                            KZ.Toggled = tc.toggled
                            KZ:Update()
                        end
                    else
                        KZ:SetValue(tc.value)
                    end
                end)
                return K__2
            end
            Ln:AddDivider()
            Ln:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
            Ln:AddButton("Export Config to Clipboard", function()
                local K2_2
                local K1_5
                K1_5, K2_2 = pcall(HttpService.JSONEncode, HttpService, Lj())
                if K1_5 then
                    local K1_6 = x2(setclipboard) and setclipboard
                    local K3 = K1_6
                    if not K3 then
                        local K1_7 = x2(toclipboard) and toclipboard
                        K3 = K1_7 or nil
                    end
                    local K1_8 = K3
                    local K3_2 = type(K1_8) == "function" and pcall(K1_8, K2_2)
                    if K3_2 then
                        Library:Notify("Config copied to clipboard", 6)
                        return
                    end
                    Library:Notify("Your executor does not support copying to the clipboard")
                    return
                end
                Library:Notify("Failed to encode the config")
            end)
            Ln:AddButton("Import Config from Clipboard Text", function()
                local K8_3
                local K6 = Options.SaveManager_ImportSource.Value
                local K6_3
                local Lc = if K6 then 1 else 0
                local La = 1194 * Lc + 3703 * (1 - Lc)
                local Lb = 1972 * Lc + 1048 * (1 - Lc)
                if not ((La * 2941 + Lb * 3277 + La * Lb) % 16777213 == 12328366) then
                    K6 = ""
                end
                local K7 = tostring(K6):match("^%s*(.-)%s*$")
                if K7 == "" then
                    Library:Notify("Paste an exported config into the box first")
                    return
                end
                if #K7 > 262144 then
                    Library:Notify("That config is too large")
                    return
                end
                K6_3, K8_3 = pcall(HttpService.JSONDecode, HttpService, K7)
                local K7_3 = not K6_3 or type(K8_3) ~= "table" or type(K8_3.objects) ~= "table"
                if K7_3 then
                    Library:Notify("That is not a valid exported config")
                    return
                end
                if #K8_3.objects > 2048 then
                    Library:Notify("That config has too many records")
                    return
                end
                local K6_4 = 0
                for i, v in ipairs(K8_3.objects) do
                    if Ll(v) then
                        K6_4 += 1
                    end
                end
                if K6_4 == 0 then
                    Library:Notify("No settings in that config matched this script")
                    return
                end
                Options.SaveManager_ImportSource:SetValue("")
                local K8_4 = K6_4 == 1 and ""
                local Lc_2 = if K8_4 then 1 else 0
                local La_2 = 4034 * Lc_2 + 1952 * (1 - Lc_2)
                local Lb_2 = 3098 * Lc_2 + 2050 * (1 - Lc_2)
                if not ((La_2 * 3290 + Lb_2 * 2098 + La_2 * Lb_2) % 16777213 == 15491583) then
                    K8_4 = "s"
                end
                Library:Notify(("Imported %d setting%s"):format(K6_4, K8_4), 6)
            end)
            ThemeManager:LoadDefault()
            SaveManager:LoadAutoloadConfig()
            if Options.TapDelay then
                y0.SetDelay(Options.TapDelay.Value)
            end
            if Options.TrainDelay then
                yX.SetDelay(Options.TrainDelay.Value)
            end
            if Options.BonusDelay then
                yT.SetDelay(Options.BonusDelay.Value)
            end
            if Options.PlaceEggDelay then
                yk.SetDelay(Options.PlaceEggDelay.Value)
            end
            if Options.HatchDelay then
                yP.SetDelay(Options.HatchDelay.Value)
            end
            if Options.RebirthDelay then
                yF.SetDelay(Options.RebirthDelay.Value)
            end
            if Options.EquipBestDelay then
                yB.SetDelay(Options.EquipBestDelay.Value)
            end
            if Options.SellDelay then
                ym.SetDelay(Options.SellDelay.Value)
            end
            if Options.SellBrainrots then
                ym.SetBrainrots(Options.SellBrainrots.Value)
            end
            if Options.SellRarities then
                ym.SetRarities(Options.SellRarities.Value)
            end
            if Options.SellMutations then
                ym.SetMutations(Options.SellMutations.Value)
            end
            if Options.SellSizes then
                ym.SetSizes(Options.SellSizes.Value)
            end
            if Toggles.SellEggsToo then
                ym.SetSellEggs(Toggles.SellEggsToo.Value)
            end
            if Options.WeightDelay then
                yZ.SetDelay(Options.WeightDelay.Value)
            end
            if Options.WeightList then
                yZ.SetAllowed(Options.WeightList.Value)
            end
            if Options.WeightMaxCost then
                yZ.SetMaxCost(Options.WeightMaxCost.Value)
            end
            if Options.DiceDelay then
                yV.SetDelay(Options.DiceDelay.Value)
            end
            if Options.DiceList then
                yV.SetAllowed(Options.DiceList.Value)
            end
            if Options.DiceMaxCost then
                yV.SetMaxCost(Options.DiceMaxCost.Value)
            end
            if Toggles.DailyIncludeVip then
                yw.SetIncludeVip(Toggles.DailyIncludeVip.Value)
            end
            if Toggles.AutoRace then
                y8.SetEnabled(Toggles.AutoRace.Value)
            end
            if Toggles.AutoTap then
                y0.SetEnabled(Toggles.AutoTap.Value)
            end
            if Toggles.AutoTrain then
                yX.SetEnabled(Toggles.AutoTrain.Value)
            end
            if Toggles.AutoBonus then
                yT.SetEnabled(Toggles.AutoBonus.Value)
            end
            if Toggles.AutoPlaceEggs then
                yk.SetEnabled(Toggles.AutoPlaceEggs.Value)
            end
            if Toggles.AutoHatchEggs then
                yP.SetEnabled(Toggles.AutoHatchEggs.Value)
            end
            if Toggles.AutoRebirth then
                yF.SetEnabled(Toggles.AutoRebirth.Value)
            end
            if Toggles.AutoEquipBest then
                yB.SetEnabled(Toggles.AutoEquipBest.Value)
            end
            if Toggles.AutoSell then
                ym.SetEnabled(Toggles.AutoSell.Value)
            end
            if Toggles.AutoBuyWeights then
                yZ.SetEnabled(Toggles.AutoBuyWeights.Value)
            end
            if Toggles.AutoBuyDice then
                yV.SetEnabled(Toggles.AutoBuyDice.Value)
            end
            if Toggles.AutoPlaytime then
                yN.SetEnabled(Toggles.AutoPlaytime.Value)
            end
            if Toggles.AutoEventPass then
                yI.SetEnabled(Toggles.AutoEventPass.Value)
            end
            if Toggles.AutoDaily then
                yw.SetEnabled(Toggles.AutoDaily.Value)
            end
            if Toggles.HideUiOnStart.Value then
                Library:Toggle(false)
            end
        end
        LK_8()
    end
else
    zp = function()
        local onDiscord
        local LJ
        local LF
        onDiscord = nil
        LF = nil
        LJ = nil
        local Ls, Lt, SaveManager, Lv, Lx, Ly, Lz, Library, LB, Toggles, LD, LE, ThemeManager, LH, Options
        Lv = "Race for Eggs"
        Lz = "https://discord.gg/K7Qxnxkk46"
        LE = "https://tempohub.shop"
        LJ = "https://discord.gg/K7Qxnxkk46"
        Library = getgenv().Library
        ThemeManager = getgenv().ThemeManager
        SaveManager = getgenv().SaveManager
        Toggles = Library.Toggles
        Options = Library.Options
        yE(yc, Library)
        Lx = yt()
        Ls = ye()
        Lt = yn(x4(), false)
        LH = yn(x0(), false)
        LD = yn(yM(), true)
        Ly = yn(yq(), true)
        LF = function(k8, k9)
            local Hg = x2(setclipboard) and setclipboard
            local Hh = Hg
            if not Hh then
                local Hg_1 = x2(toclipboard) and toclipboard
                Hh = Hg_1 or nil
            end
            local Hg_2 = Hh
            if not Hg_2 then
                Library:Notify("Clipboard is unavailable")
                return
            end
            local Hh_1 = pcall(Hg_2, k8)
            if Hh_1 then
                Library:Notify(k9)
            else
                Library:Notify("Failed to copy")
            end
        end
        onDiscord = function()
            LF(LJ, "Copied Discord invite to clipboard")
        end
        local Window = Library:CreateWindow({
            Title = "Tempo",
            Font = Enum.Font.BuilderSans,
            Footer = { { Text = LJ, Copyable = true }, "|", Lv, "|", "v0.1" },
            Icon = 78539693571783,
            NotifySide = "Right",
            ShowCustomCursor = false,
            CornerRadius = 0,
            SidebarCompacted = true,
            TabSwipeFrom = "bottom",
            Animations = { TabSwitch = true }
        })
        Window:SetGlow(false)
        LB = {
            Info = Window:AddTab("Info", "info"),
            Main = Window:AddTab("Main", "gamepad-2"),
            Player = Window:AddTab("Player", "person-standing"),
            Settings = Window:AddTab("Settings", "settings")
        }
        local function LK(lm)
            local DiscordGroup = lm:AddLeftGroupbox("Discord")
            DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
            DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
        end
        for k, v in LB do
            if k ~= "Info" then
                LK(v)
            end
        end
        local function LL_1()
            local nF
            local RacingGroup = LB.Main:AddLeftGroupbox("Racing", "flag")
            local Label = RacingGroup:AddLabel(State.Status, true)
            RacingGroup:AddDivider()
            RacingGroup:AddToggle("AutoRace", {
                Text = "Auto Race",
                Default = false,
                Tooltip = "Arms the game's own autorun so you join every race that opens. Races open on a server timer, so idle gaps are normal.",
                Callback = function(lx)
                    y8.SetEnabled(lx)
                end
            })
            RacingGroup:AddToggle("AutoTap", {
                Text = "Auto Tap",
                Default = false,
                Tooltip = "Taps for you while a race is running.",
                Callback = function(lB)
                    y0.SetEnabled(lB)
                end
            })
            RacingGroup:AddSlider("TapDelay", {
                Text = "Tap Delay",
                Default = 0.2,
                Min = 0.05,
                Max = 2,
                Rounding = 2,
                Suffix = "s",
                Callback = function(lF)
                    y0.SetDelay(lF)
                end
            })
            RacingGroup:AddDivider("Training")
            RacingGroup:AddToggle("AutoTrain", {
                Text = "Auto Train",
                Default = false,
                Tooltip = "Swings your dumbbell to raise Speed.",
                Callback = function(lH)
                    yX.SetEnabled(lH)
                end
            })
            RacingGroup:AddSlider("TrainDelay", {
                Text = "Train Delay",
                Default = 0.3,
                Min = 0.1,
                Max = 5,
                Rounding = 2,
                Suffix = "s",
                Callback = function(lL)
                    yX.SetDelay(lL)
                end
            })
            RacingGroup:AddToggle("AutoBonus", {
                Text = "Auto 2x Bonus",
                Default = false,
                Tooltip = "Claims the 2x training bonus the moment it spawns.",
                Callback = function(lN)
                    yT.SetEnabled(lN)
                end
            })
            RacingGroup:AddSlider("BonusDelay", {
                Text = "Bonus Check Delay",
                Default = 5,
                Min = 1,
                Max = 60,
                Rounding = 1,
                Suffix = "s",
                Callback = function(lR)
                    yT.SetDelay(lR)
                end
            })
            RacingGroup:AddDivider("Rebirth")
            RacingGroup:AddToggle("AutoRebirth", {
                Text = "Auto Rebirth",
                Default = false,
                Tooltip = "Rebirths as soon as you can pay the next tier's cash cost.",
                Callback = function(lT)
                    yF.SetEnabled(lT)
                end
            })
            RacingGroup:AddSlider("RebirthDelay", {
                Text = "Rebirth Delay",
                Default = 10,
                Min = 1,
                Max = 120,
                Rounding = 1,
                Suffix = "s",
                Callback = function(lX)
                    yF.SetDelay(lX)
                end
            })
            local PlotGroup = LB.Main:AddLeftGroupbox("Plot", "layout-grid")
            PlotGroup:AddToggle("AutoPlaceEggs", {
                Text = "Auto Place Eggs",
                Default = false,
                Tooltip = "Drops every egg in your inventory onto a free spot on your plot.",
                Callback = function(l_)
                    yk.SetEnabled(l_)
                end
            })
            PlotGroup:AddSlider("PlaceEggDelay", {
                Text = "Place Delay",
                Default = 2,
                Min = 0.5,
                Max = 30,
                Rounding = 1,
                Suffix = "s",
                Callback = function(l3)
                    yk.SetDelay(l3)
                end
            })
            PlotGroup:AddToggle("AutoHatchEggs", {
                Text = "Auto Hatch Eggs",
                Default = false,
                Tooltip = "Hatches your placed eggs the second their timer runs out.",
                Callback = function(l5)
                    yP.SetEnabled(l5)
                end
            })
            PlotGroup:AddSlider("HatchDelay", {
                Text = "Hatch Delay",
                Default = 3,
                Min = 0.5,
                Max = 30,
                Rounding = 1,
                Suffix = "s",
                Callback = function(l9)
                    yP.SetDelay(l9)
                end
            })
            PlotGroup:AddDivider("Pets")
            PlotGroup:AddToggle("AutoEquipBest", {
                Text = "Auto Equip Best Pet",
                Default = false,
                Tooltip = "Keeps your highest earning brainrots placed on the plot.",
                Callback = function(mb)
                    yB.SetEnabled(mb)
                end
            })
            PlotGroup:AddSlider("EquipBestDelay", {
                Text = "Equip Delay",
                Default = 10,
                Min = 1,
                Max = 120,
                Rounding = 1,
                Suffix = "s",
                Callback = function(mf)
                    yB.SetDelay(mf)
                end
            })
            local SellingGroup = LB.Main:AddRightGroupbox("Selling", "coins")
            SellingGroup:AddToggle("AutoSell", {
                Text = "Auto Sell",
                Default = false,
                Tooltip = "Sells the inventory brainrots that match the filters below. Placed brainrots are never touched.",
                Callback = function(mi)
                    ym.SetEnabled(mi)
                end
            })
            SellingGroup:AddDropdown("SellBrainrots", {
                Text = "Sell Brainrots",
                Values = Lx,
                Default = {},
                Multi = true,
                AllowNull = true,
                Tooltip = "Leave everything unticked to ignore this filter.",
                Callback = function(mn)
                    ym.SetBrainrots(mn)
                end
            })
            SellingGroup:AddDropdown("SellRarities", {
                Text = "Sell Rarities",
                Values = Ls,
                Default = {},
                Multi = true,
                AllowNull = true,
                Tooltip = "Leave everything unticked to ignore this filter.",
                Callback = function(mq)
                    ym.SetRarities(mq)
                end
            })
            SellingGroup:AddDropdown("SellMutations", {
                Text = "Sell Mutations",
                Values = Lt,
                Default = {},
                Multi = true,
                AllowNull = true,
                Tooltip = "Leave everything unticked to ignore this filter.",
                Callback = function(mt)
                    ym.SetMutations(mt)
                end
            })
            SellingGroup:AddDropdown("SellSizes", {
                Text = "Sell Sizes",
                Values = LH,
                Default = {},
                Multi = true,
                AllowNull = true,
                Tooltip = "Leave everything unticked to ignore this filter.",
                Callback = function(mw)
                    ym.SetSizes(mw)
                end
            })
            SellingGroup:AddToggle("SellEggsToo", {
                Text = "Sell Eggs Too",
                Default = false,
                Tooltip = "Also sells every egg sitting in your inventory.",
                Callback = function(my)
                    ym.SetSellEggs(my)
                end
            })
            SellingGroup:AddSlider("SellDelay", {
                Text = "Sell Delay",
                Default = 5,
                Min = 1,
                Max = 60,
                Rounding = 1,
                Suffix = "s",
                Callback = function(mA)
                    ym.SetDelay(mA)
                end
            })
            local ShopGroup = LB.Main:AddRightGroupbox("Shop", "shopping-cart")
            ShopGroup:AddToggle("AutoBuyWeights", {
                Text = "Auto Buy Weights",
                Default = false,
                Tooltip = "Buys the cheapest dumbbell you can afford, then equips the strongest one you own.",
                Callback = function(mD)
                    yZ.SetEnabled(mD)
                end
            })
            ShopGroup:AddDropdown("WeightList", {
                Text = "Weights",
                Values = LD,
                Default = {},
                Multi = true,
                AllowNull = true,
                Tooltip = "Leave everything unticked to buy any dumbbell.",
                Callback = function(mI)
                    yZ.SetAllowed(mI)
                end
            })
            ShopGroup:AddSlider("WeightMaxCost", {
                Text = "Max Weight Cost",
                Default = 0,
                Min = 0,
                Max = 1000000000,
                Rounding = 0,
                Tooltip = "Skips dumbbells above this price. 0 removes the limit.",
                Callback = function(mK)
                    yZ.SetMaxCost(mK)
                end
            })
            ShopGroup:AddSlider("WeightDelay", {
                Text = "Buy Weight Delay",
                Default = 5,
                Min = 1,
                Max = 60,
                Rounding = 1,
                Suffix = "s",
                Callback = function(mM)
                    yZ.SetDelay(mM)
                end
            })
            ShopGroup:AddDivider("Dice")
            ShopGroup:AddToggle("AutoBuyDice", {
                Text = "Auto Buy Dice",
                Default = false,
                Tooltip = "Buys the cheapest player skin you can afford, then equips the luckiest one you own.",
                Callback = function(mO)
                    yV.SetEnabled(mO)
                end
            })
            ShopGroup:AddDropdown("DiceList", {
                Text = "Dice",
                Values = Ly,
                Default = {},
                Multi = true,
                AllowNull = true,
                Tooltip = "Leave everything unticked to buy any skin.",
                Callback = function(mT)
                    yV.SetAllowed(mT)
                end
            })
            ShopGroup:AddSlider("DiceMaxCost", {
                Text = "Max Dice Cost",
                Default = 0,
                Min = 0,
                Max = 1000000000,
                Rounding = 0,
                Tooltip = "Skips skins above this price. 0 removes the limit.",
                Callback = function(mV)
                    yV.SetMaxCost(mV)
                end
            })
            ShopGroup:AddSlider("DiceDelay", {
                Text = "Buy Dice Delay",
                Default = 5,
                Min = 1,
                Max = 60,
                Rounding = 1,
                Suffix = "s",
                Callback = function(mX)
                    yV.SetDelay(mX)
                end
            })
            local RewardsGroup = LB.Main:AddRightGroupbox("Rewards", "gift")
            RewardsGroup:AddToggle("AutoPlaytime", {
                Text = "Auto Claim Playtime Rewards",
                Default = false,
                Callback = function(m_)
                    yN.SetEnabled(m_)
                end
            })
            RewardsGroup:AddToggle("AutoEventPass", {
                Text = "Auto Claim Event Pass",
                Default = false,
                Tooltip = "Claims every free season pass tier you have reached, and the paid tiers you own.",
                Callback = function(m3)
                    yI.SetEnabled(m3)
                end
            })
            RewardsGroup:AddToggle("AutoDaily", {
                Text = "Auto Claim Daily Rewards",
                Default = false,
                Callback = function(m7)
                    yw.SetEnabled(m7)
                end
            })
            RewardsGroup:AddToggle("DailyIncludeVip", {
                Text = "Include VIP Reward",
                Default = false,
                Tooltip = "Also tries the VIP half of the daily reward. It needs the matching gamepass.",
                Callback = function(nb)
                    yw.SetIncludeVip(nb)
                end
            })
            local TeleportGroup = LB.Main:AddRightGroupbox("Teleport", "map-pin")
            TeleportGroup:AddButton({ Text = "Teleport To Base", Func = zn })
            nF = task.spawn(function()
                while not Library.Unloaded do
                    pcall(function()
                        local Hk = #y7()
                        local Hl = LocalPlayer:GetAttribute("IsRacing") == true and "racing"
                        local Hm = Hl or "idle"
                        local Hm_1 = string.format("Cash %d  |  Speed %d  |  Rebirth %d  |  %s  |  Bag %d", math.floor(yp()), math.floor(yg()), zm(), Hm, Hk)
                        Label:SetText(Hm_1 .. "  |  " .. tostring(State.Status))
                    end)
                    local Hs = false
                    repeat
                        local Ho
                        if State.Notifications and #State.Notifications > 0 then
                            Ho = table.remove(State.Notifications, 1)
                            pcall(function()
                                Library:Notify(Ho.text, Ho.time)
                            end)
                        else
                            Hs = true
                        end
                    until Hs
                    task.wait(0.3)
                end
            end)
            yc.Track(function()
                if coroutine.status(nF) ~= "dead" then
                    pcall(task.cancel, nF)
                end
            end)
        end
        LL_1()
        local function LK_1()
            local HO
            local HP
            local HN
            local HS
            HN = nil
            HO = nil
            HP = nil
            HS = nil
            local HJ, HK, HL, Label, HQ, Label2, HT, HU, Label3
            HP = function(nK)
                return (tostring(nK):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
            end
            HS = function(nM, nN)
                return string.format('<font color="%s">%s</font>', nN, HP(nM))
            end
            HQ = function(nQ, nR, nS)
                return string.format("<b>%s</b> %s %s", nQ, HS("-", "#5a6070"), HS(nR, nS))
            end
            HL = "#e8a34d"
            HT = "#7fd47f"
            local HW = "#6ec1ff"
            local HX = {}
            local HY = "#8b93a3"
            if not yu() then
                table.insert(HX, "every server action")
            end
            if not x9("AutorunController") then
                table.insert(HX, "auto race")
            end
            if not x9("RunningController") then
                table.insert(HX, "auto tap")
            end
            local HZ = debug and debug.getupvalue
            local H_ = not x2(HZ) or not y_()
            if H_ then
                table.insert(HX, "cash, inventory and claim state")
            end
            if not yh() then
                table.insert(HX, "sell filters")
            end
            if not yM() then
                table.insert(HX, "buying weights")
            end
            local H3 = if not yq() then 1 else 0
            if H3 == 1 then
                table.insert(HX, "buying dice")
            end
            local HZ_1 = not x2(setclipboard) and not x2(toclipboard)
            if HZ_1 then
                table.insert(HX, "clipboard copies")
            end
            local HZ_2 = #HX == 0 and "ready"
            local H__1 = HZ_2 or "limited: " .. table.concat(HX, ", ")
            HJ = "Unknown"
            pcall(function()
                local Hv_1
                local Hu_1
                if x2(identifyexecutor) then
                    Hv_1, Hu_1 = identifyexecutor()
                    local Hw = Hv_1 ~= ""
                    local Hx = type(Hv_1) == "string" and Hw
                    if Hx then
                        local Hw_1 = type(Hu_1) == "string" and Hu_1 ~= "" and Hv_1 .. " " .. Hu_1
                        local Hu_2 = Hw_1
                        local HB = if Hu_2 then 1 else 0
                        local Hz = 4001 * HB + 3810 * (1 - HB)
                        local HA = 3250 * HB + 176 * (1 - HB)
                        if not ((Hz * 1906 + HA * 2561 + Hz * HA) % 16777213 == 12175193) then
                            Hu_2 = Hv_1
                        end
                        HJ = Hu_2
                    end
                end
            end)
            HO = os.clock()
            HU = function()
                local HC = math.floor(os.clock() - HO)
                if HC < 60 then
                    return HC .. "s"
                elseif HC < 3600 then
                    return string.format("%dm %ds", math.floor((HC) / (60)), HC % 60)
                else
                    return string.format("%dh %dm", math.floor((HC) / (3600)), math.floor((HC % 3600) / (60)))
                end
            end
            local UserGroup = LB.Info:AddLeftGroupbox("User", "circle-user")
            UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
            UserGroup:AddLabel(HQ("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, HT), true)
            UserGroup:AddLabel(HQ("UserId", tostring(LocalPlayer.UserId), HW), true)
            UserGroup:AddLabel(HQ("Executor", HJ .. "  " .. H__1, HT), true)
            UserGroup:AddDivider()
            Label3 = UserGroup:AddLabel(HQ("Session", HU(), HL), true)
            UserGroup:AddDivider()
            UserGroup:AddButton({
                Text = "Copy Username",
                Func = function()
                    LF(LocalPlayer.Name, "Copied username")
                end
            })
            UserGroup:AddButton({
                Text = "Copy Profile Link",
                Func = function()
                    LF("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
                end
            })
            local SessionGroup = LB.Info:AddRightGroupbox("Session", "signal")
            SessionGroup:AddLabel(HQ("Game", Lv, HW), true)
            Label2 = SessionGroup:AddLabel(HQ("Players", "0/0", HT), true)
            HK = tostring(game.JobId)
            local HW_1 = #HK > 18 and string.sub(HK, 1, 18) .. "..."
            local HZ_4 = HW_1 or HK
            SessionGroup:AddLabel(HQ("Job", HZ_4, HY), true)
            Label = SessionGroup:AddLabel(HQ("Ping", "0 ms", HL), true)
            SessionGroup:AddDivider()
            SessionGroup:AddButton({
                Text = "Rejoin Place",
                Func = function()
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end
            })
            SessionGroup:AddButton({
                Text = "Copy Job ID",
                Func = function()
                    LF(HK, "Copied Job ID")
                end
            })
            HN = task.spawn(function()
                local HF_1
                local HE_1
                while true do
                    task.wait(1)
                    if Library.Unloaded then
                        break
                    end
                    Label3:SetText(HQ("Session", HU(), HL))
                    Label2:SetText(HQ("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), HT))
                    HE_1, HF_1 = pcall(function()
                        return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                    end)
                    local HE_2 = HE_1 and HF_1 .. " ms" or "n/a"
                    Label:SetText(HQ("Ping", HE_2, HL))
                end
            end)
            yc.Track(function()
                if coroutine.status(HN) ~= "dead" then
                    task.cancel(HN)
                end
            end)
            local SocialsGroup = LB.Info:AddRightGroupbox("Socials", "link")
            SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
            SocialsGroup:AddButton({
                Text = "Rscripts",
                Func = function()
                    LF(Lz, "Copied Rscripts profile")
                end
            })
            SocialsGroup:AddButton({
                Text = "Website",
                Func = function()
                    LF(LE, "Copied website link")
                end
            })
        end
        LK_1()
        local function LK_2()
            local ph
            local pf
            local pg
            local pi
            local MovementGroup = LB.Player:AddLeftGroupbox("Movement", "footprints")
            MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
            MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
            MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
            MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
            MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
            local FlyGroup = LB.Player:AddRightGroupbox("Fly", "feather")
            FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
            FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
            pg = {}
            ph = {}
            pi = {}
            local pe = {}
            pf = {}
            local function pj()
                for k, v in pf do
                    if k.Parent then
                        k.CanCollide = v
                    end
                end
                table.clear(pf)
            end
            local function pn()
                for k, v in pg do
                    if k.Parent then
                        k.WalkSpeed = v
                    end
                end
                table.clear(pg)
            end
            local function pr()
                for k, v in ph do
                    if k.Parent then
                        k.PlatformStand = v
                    end
                end
                table.clear(ph)
            end
            local function pv(pw)
                local Is = if not pw:IsA("ProximityPrompt") then 1 else 0
                if Is == 1 then
                    return
                end
                if pi[pw] == nil then
                    pi[pw] = {
                        HoldDuration = pw.HoldDuration,
                        MaxActivationDistance = pw.MaxActivationDistance,
                        RequiresLineOfSight = pw.RequiresLineOfSight
                    }
                end
                pw.HoldDuration = 0
                pw.MaxActivationDistance = 50
                pw.RequiresLineOfSight = false
            end
            local function py()
                for k, v in pi do
                    if k.Parent then
                        k.HoldDuration = v.HoldDuration
                        k.MaxActivationDistance = v.MaxActivationDistance
                        k.RequiresLineOfSight = v.RequiresLineOfSight
                    end
                end
                table.clear(pi)
            end
            Toggles.Fly:OnChanged(function()
                if not Toggles.Fly.Value then
                    pr()
                end
            end)
            Toggles.WalkSpeedEnabled:OnChanged(function()
                if not Toggles.WalkSpeedEnabled.Value then
                    pn()
                end
            end)
            Toggles.NoClip:OnChanged(function()
                if not Toggles.NoClip.Value then
                    pj()
                end
            end)
            Toggles.InstantProximityPrompt:OnChanged(function()
                if Toggles.InstantProximityPrompt.Value then
                    for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                        pcall(pv, v)
                    end
                else
                    py()
                end
            end)
            table.insert(pe, Workspace.DescendantAdded:Connect(function(pR)
                if Toggles.InstantProximityPrompt.Value then
                    pv(pR)
                end
            end))
            table.insert(pe, RunService.Stepped:Connect(function()
                if Library.Unloaded then
                    return
                end
                local Character = LocalPlayer.Character
                if Toggles.NoClip.Value and Character then
                    for k, v in Character:QueryDescendants("BasePart") do
                        if pf[v] == nil then
                            pf[v] = v.CanCollide
                        end
                        v.CanCollide = false
                    end
                end
            end))
            table.insert(pe, UserInputService.JumpRequest:Connect(function()
                if Library.Unloaded then
                    return
                end
                local Character = LocalPlayer.Character
                local IV = Character and Character:FindFirstChildOfClass("Humanoid")
                if Toggles.InfJump.Value and IV then
                    IV:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end))
            table.insert(pe, RunService.RenderStepped:Connect(function(qc)
                if Library.Unloaded then
                    return
                end
                local Character = LocalPlayer.Character
                local IY = Character and Character:FindFirstChildOfClass("Humanoid")
                local IZ = Character
                if IZ then
                    IZ = Character:FindFirstChild("HumanoidRootPart")
                end
                local IX_1 = IZ
                local CurrentCamera = Workspace.CurrentCamera
                if Toggles.WalkSpeedEnabled.Value and IY then
                    if pg[IY] == nil then
                        pg[IY] = IY.WalkSpeed
                    end
                    IY.WalkSpeed = Options.WalkSpeed.Value
                end
                if Toggles.Fly.Value and IX_1 and IY and CurrentCamera then
                    if ph[IY] == nil then
                        ph[IY] = IY.PlatformStand
                    end
                    IY.PlatformStand = true
                    local IZ_4 = Vector3.zero
                    if not UserInputService:GetFocusedTextBox() then
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            IZ_4 += CurrentCamera.CFrame.LookVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            IZ_4 -= CurrentCamera.CFrame.LookVector
                        end
                        local I4 = if UserInputService:IsKeyDown(Enum.KeyCode.A) then 1 else 0
                        if I4 == 1 then
                            IZ_4 -= CurrentCamera.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                            IZ_4 += CurrentCamera.CFrame.RightVector
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            IZ_4 += Vector3.new(0, 1, 0)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                            IZ_4 -= Vector3.new(0, 1, 0)
                        end
                    end
                    IX_1.AssemblyLinearVelocity = Vector3.zero
                    if IZ_4.Magnitude > 0 then
                        IX_1.CFrame = IX_1.CFrame + IZ_4.Unit * Options.FlySpeed.Value * qc
                    end
                end
            end))
            yc.Track(function()
                for k, v in pe do
                    v:Disconnect()
                end
                pj()
                pn()
                pr()
                py()
            end)
        end
        LK_2()
        local function LK_3()
            local Kb, Kc, Kd, Ke, Kf, Kg, Kh, Ki, Kj, Kk, Label, Km, Kn, Ko
            Km = {}
            Kg = {}
            Kd = nil
            Ko = 0
            Ke = 0
            Ki = false
            Kj = os.clock()
            local MenuGroup = LB.Settings:AddLeftGroupbox("Menu", "logs")
            MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
            Label = MenuGroup:AddLabel("AFK triggers: 0")
            Kb = function()
                local CurrentCamera
                CurrentCamera = Workspace.CurrentCamera
                local Jd = not CurrentCamera or not x2(VirtualUser.CaptureController) or not x2(VirtualUser.ClickButton2)
                if Jd then
                    return false
                end
                local Jd_1 = pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
                end)
                if not Jd_1 then
                    return false
                end
                Ke += 1
                Kj = os.clock()
                pcall(function()
                    Label:SetText("AFK triggers: " .. Ke)
                end)
                return true
            end
            Kk = function(qW)
                pcall(function()
                    GuiService:SetGameplayPausedNotificationEnabled(not qW)
                end)
                pcall(function()
                    local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                    if RobloxNetworkPauseNotificati then
                        RobloxNetworkPauseNotificati.Enabled = not qW
                    end
                end)
                if not qW then
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
            Kh = function(rb)
                local Jm = rb.ClassName == "ParticleEmitter" or rb.ClassName == "Trail"
                local Jq = if Jm then 1 else 0
                local Jo = 3265 * Jq + 1343 * (1 - Jq)
                local Jp = 661 * Jq + 1064 * (1 - Jq)
                if not ((Jo * 3669 + Jp * 559 + Jo * Jp) % 16777213 == 14506949) then
                    Jm = rb.ClassName == "Smoke"
                end
                if not Jm then
                    Jm = rb.ClassName == "Fire"
                end
                if not Jm then
                    Jm = rb.ClassName == "Sparkles"
                end
                local Jt = if Jm then 1 else 0
                local Jr = 1011 * Jt + 786 * (1 - Jt)
                local Js = 4039 * Jt + 3443 * (1 - Jt)
                if not ((Jr * 1710 + Js * 3650 + Jr * Js) % 16777213 == 3777376) then
                    Jm = rb.ClassName == "Explosion"
                end
                local Jt_1 = if Jm then 1 else 0
                local Jr_1 = 456 * Jt_1 + 2564 * (1 - Jt_1)
                local Js_1 = 3940 * Jt_1 + 227 * (1 - Jt_1)
                if not ((Jr_1 * 4052 + Js_1 * 3211 + Jr_1 * Js_1) % 16777213 == 16295692) then
                    Jm = rb.ClassName == "Beam"
                end
                if Jm then
                    if Km[rb] == nil then
                        Km[rb] = rb.Enabled
                    end
                    pcall(function()
                        rb.Enabled = false
                    end)
                end
            end
            Kf = function()
                for k, v in Km do
                    local Jy = k
                    local JA = v
                    if Jy.Parent then
                        pcall(function()
                            Jy.Enabled = JA
                        end)
                    end
                end
                table.clear(Km)
                if Kd then
                    pcall(function()
                        settings().Rendering.QualityLevel = Kd.Quality
                    end)
                    Lighting.GlobalShadows = Kd.Shadows
                    Lighting.FogEnd = Kd.Fog
                    Kd = nil
                end
            end
            MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
            MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
            MenuGroup:AddToggle("Disable3D", {
                Text = "Disable 3D Rendering",
                Default = false,
                Callback = function(rq)
                    pcall(function()
                        RunService:Set3dRenderingEnabled(not rq)
                    end)
                end
            })
            MenuGroup:AddToggle("FpsBoost", {
                Text = "FPS Boost",
                Default = false,
                Callback = function(rv)
                    if rv then
                        if not Kd then
                            Kd = {
                                Quality = settings().Rendering.QualityLevel,
                                Shadows = Lighting.GlobalShadows,
                                Fog = Lighting.FogEnd
                            }
                        end
                        pcall(function()
                            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                        end)
                        Lighting.GlobalShadows = false
                        Lighting.FogEnd = 9000000000
                        for k, v in Workspace:QueryDescendants("ParticleEmitter,Trail,Smoke,Fire,Sparkles,Beam") do
                            pcall(Kh, v)
                        end
                    else
                        Kf()
                    end
                end
            })
            MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
            MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
            Library.ToggleKeybind = Options.MenuKeybind
            Kk(true)
            local ScriptGroup = LB.Settings:AddLeftGroupbox("Script", "terminal")
            ScriptGroup:AddButton({
                Text = "Unload Script",
                Func = function()
                    Library:Unload()
                end
            })
            Toggles.AntiGameplayPause:OnChanged(function()
                Kk(Toggles.AntiGameplayPause.Value)
            end)
            if Toggles.AntiGameplayPause.Value then
                Kk(true)
            end
            table.insert(Kg, LocalPlayer.Idled:Connect(function()
                if Toggles.AntiAfk.Value and not Library.Unloaded then
                    Kb()
                end
            end))
            table.insert(Kg, Workspace.DescendantAdded:Connect(function(rO)
                if Toggles.FpsBoost.Value then
                    Kh(rO)
                end
            end))
            Kc = function(rS)
                local JO = Ki or Library.Unloaded
                local JT = if JO then 1 else 0
                local JR = 1248 * JT + 2588 * (1 - JT)
                local JS = 3818 * JT + 1963 * (1 - JT)
                if not ((JR * 1400 + JS * 1931 + JR * JS) % 16777213 == 13884622) then
                    JO = not Toggles.AutoReconnect.Value
                end
                if JO then
                    return
                end
                Ki = true
                local JN = Ko
                local JO_1 = pcall(function()
                    if rS then
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    else
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                    end
                end)
                if not JO_1 then
                    Ki = false
                    if not rS and JN == Ko then
                        task.delay(1.5, function()
                            if JN == Ko then
                                Kc(true)
                            end
                        end)
                    end
                end
            end
            table.insert(Kg, TeleportService.TeleportInitFailed:Connect(function(r9)
                local JV
                if r9 == LocalPlayer and Ki then
                    Ki = false
                    JV = Ko
                    task.delay(3, function()
                        if JV == Ko then
                            Kc(true)
                        end
                    end)
                end
            end))
            task.spawn(function()
                local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
                local J_ = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
                if Library.Unloaded or not J_ then
                    return
                end
                table.insert(Kg, J_.ChildAdded:Connect(function(so)
                    if so.Name == "ErrorPrompt" then
                        Kc(false)
                    end
                end))
            end)
            Kn = task.spawn(function()
                while not Library.Unloaded do
                    if Toggles.AntiGameplayPause.Value then
                        Kk(true)
                    end
                    local J2 = Toggles.AntiAfk.Value and os.clock() - Kj >= 60
                    if J2 then
                        Kb()
                    end
                    task.wait(1)
                end
            end)
            yc.Track(function()
                Ko += 1
                for k, v in Kg do
                    v:Disconnect()
                end
                pcall(task.cancel, Kn)
                Kk(false)
                Kf()
                pcall(function()
                    RunService:Set3dRenderingEnabled(true)
                end)
            end)
        end
        LK_3()
        local function LK_4()
            local Lj, Lk, Ll, Lm
            ThemeManager:SetLibrary(Library)
            ThemeManager:SetFolder("TempoHub")
            ThemeManager:SaveDefault("Evil Hello Kitty")
            ThemeManager:ApplyToTab(LB.Settings)
            SaveManager:SetLibrary(Library)
            SaveManager:IgnoreThemeSettings()
            SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
            SaveManager:SetFolder("TempoHub/RaceForEggs")
            local Ln = SaveManager:BuildConfigSection(LB.Settings)
            Lm = function(sP, sQ)
                local Ks_1 = (sP == "Toggle" and Toggles or Options)[sQ]
                local Kr_2 = type(Ks_1) == "table" and Ks_1.Type == sP
                local Kr_3 = Kr_2 and Ks_1
                local Kx = if Kr_3 then 1 else 0
                local Kv = 1793 * Kx + 2963 * (1 - Kx)
                local Kw = 840 * Kx + 719 * (1 - Kx)
                if not ((Kv * 2927 + Kw * 3881 + Kv * Kw) % 16777213 == 10014271) then
                    Kr_3 = nil
                end
                return Kr_3
            end
            Lk = function(sZ, s_)
                local Type = s_.Type
                if Type == "Toggle" then
                    return { idx = sZ, type = "Toggle", value = s_.Value == true }
                elseif Type == "Slider" then
                    return { idx = sZ, type = "Slider", value = tostring(s_.Value) }
                elseif Type == "Dropdown" then
                    return { idx = sZ, type = "Dropdown", multi = s_.Multi == true, value = s_.Value }
                elseif Type == "Input" then
                    local Kz = s_.Value or ""
                    return { idx = sZ, type = "Input", text = tostring(Kz) }
                elseif Type == "ColorPicker" then
                    return { idx = sZ, type = "ColorPicker", value = s_.Value:ToHex(), transparency = s_.Transparency }
                elseif Type == "KeyPicker" then
                    return {
                        idx = sZ,
                        type = "KeyPicker",
                        mode = s_.Mode,
                        key = s_.Value,
                        modifiers = s_.Modifiers,
                        toggled = s_.Toggled
                    }
                else
                    return nil
                end
            end
            Lj = function()
                local KF = {}
                for i, v in ipairs({ Toggles, Options }) do
                    for k, v in pairs(v) do
                        local KG = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                        if KG then
                            local KG_1 = Lk(k, v)
                            if KG_1 then
                                KF[#KF + 1] = KG_1
                            end
                        end
                    end
                end
                table.sort(KF, function(s9, ta)
                    if s9.type ~= ta.type then
                        return s9.type < ta.type
                    end
                    return s9.idx < ta.idx
                end)
                return { objects = KF }
            end
            Ll = function(tc)
                local KZ
                KZ = nil
                local K_ = type(tc) ~= "table" or type(tc.idx) ~= "string" or type(tc.type) ~= "string" or SaveManager.Ignore[tc.idx]
                if K_ then
                    return false
                end
                KZ = Lm(tc.type, tc.idx)
                if not KZ then
                    return false
                end
                local K__1 = pcall(function()
                    if tc.type == "Input" then
                        if type(tc.text) ~= "string" then
                            return
                        end
                        KZ:SetValue(tc.text)
                    elseif tc.type == "ColorPicker" then
                        KZ:SetValueRGB(Color3.fromHex(tc.value), tc.transparency)
                    elseif tc.type == "KeyPicker" then
                        KZ:SetValue({ tc.key, tc.mode, tc.modifiers })
                        if tc.mode == "Toggle" and tc.toggled ~= nil then
                            KZ.Toggled = tc.toggled
                            KZ:Update()
                        end
                    else
                        KZ:SetValue(tc.value)
                    end
                end)
                return K__1
            end
            Ln:AddDivider()
            Ln:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
            Ln:AddButton("Export Config to Clipboard", function()
                local K2_1
                local K1_1
                K1_1, K2_1 = pcall(HttpService.JSONEncode, HttpService, Lj())
                if K1_1 then
                    local K1_2 = x2(setclipboard) and setclipboard
                    local K3 = K1_2
                    if not K3 then
                        local K1_3 = x2(toclipboard) and toclipboard
                        K3 = K1_3 or nil
                    end
                    local K1_4 = K3
                    local K3_1 = type(K1_4) == "function" and pcall(K1_4, K2_1)
                    if K3_1 then
                        Library:Notify("Config copied to clipboard", 6)
                        return
                    end
                    Library:Notify("Your executor does not support copying to the clipboard")
                    return
                end
                Library:Notify("Failed to encode the config")
            end)
            Ln:AddButton("Import Config from Clipboard Text", function()
                local K8_1
                local K6 = Options.SaveManager_ImportSource.Value
                local K6_1
                local Lc = if K6 then 1 else 0
                local La = 1194 * Lc + 3703 * (1 - Lc)
                local Lb = 1972 * Lc + 1048 * (1 - Lc)
                if not ((La * 2941 + Lb * 3277 + La * Lb) % 16777213 == 12328366) then
                    K6 = ""
                end
                local K7 = tostring(K6):match("^%s*(.-)%s*$")
                if K7 == "" then
                    Library:Notify("Paste an exported config into the box first")
                    return
                end
                if #K7 > 262144 then
                    Library:Notify("That config is too large")
                    return
                end
                K6_1, K8_1 = pcall(HttpService.JSONDecode, HttpService, K7)
                local K7_1 = not K6_1 or type(K8_1) ~= "table" or type(K8_1.objects) ~= "table"
                if K7_1 then
                    Library:Notify("That is not a valid exported config")
                    return
                end
                if #K8_1.objects > 2048 then
                    Library:Notify("That config has too many records")
                    return
                end
                local K6_2 = 0
                for i, v in ipairs(K8_1.objects) do
                    if Ll(v) then
                        K6_2 += 1
                    end
                end
                if K6_2 == 0 then
                    Library:Notify("No settings in that config matched this script")
                    return
                end
                Options.SaveManager_ImportSource:SetValue("")
                local K8_2 = K6_2 == 1 and ""
                local Lc_1 = if K8_2 then 1 else 0
                local La_1 = 4034 * Lc_1 + 1952 * (1 - Lc_1)
                local Lb_1 = 3098 * Lc_1 + 2050 * (1 - Lc_1)
                if not ((La_1 * 3290 + Lb_1 * 2098 + La_1 * Lb_1) % 16777213 == 15491583) then
                    K8_2 = "s"
                end
                Library:Notify(("Imported %d setting%s"):format(K6_2, K8_2), 6)
            end)
            ThemeManager:LoadDefault()
            SaveManager:LoadAutoloadConfig()
            if Options.TapDelay then
                y0.SetDelay(Options.TapDelay.Value)
            end
            if Options.TrainDelay then
                yX.SetDelay(Options.TrainDelay.Value)
            end
            if Options.BonusDelay then
                yT.SetDelay(Options.BonusDelay.Value)
            end
            if Options.PlaceEggDelay then
                yk.SetDelay(Options.PlaceEggDelay.Value)
            end
            if Options.HatchDelay then
                yP.SetDelay(Options.HatchDelay.Value)
            end
            if Options.RebirthDelay then
                yF.SetDelay(Options.RebirthDelay.Value)
            end
            if Options.EquipBestDelay then
                yB.SetDelay(Options.EquipBestDelay.Value)
            end
            if Options.SellDelay then
                ym.SetDelay(Options.SellDelay.Value)
            end
            if Options.SellBrainrots then
                ym.SetBrainrots(Options.SellBrainrots.Value)
            end
            if Options.SellRarities then
                ym.SetRarities(Options.SellRarities.Value)
            end
            if Options.SellMutations then
                ym.SetMutations(Options.SellMutations.Value)
            end
            if Options.SellSizes then
                ym.SetSizes(Options.SellSizes.Value)
            end
            if Toggles.SellEggsToo then
                ym.SetSellEggs(Toggles.SellEggsToo.Value)
            end
            if Options.WeightDelay then
                yZ.SetDelay(Options.WeightDelay.Value)
            end
            if Options.WeightList then
                yZ.SetAllowed(Options.WeightList.Value)
            end
            if Options.WeightMaxCost then
                yZ.SetMaxCost(Options.WeightMaxCost.Value)
            end
            if Options.DiceDelay then
                yV.SetDelay(Options.DiceDelay.Value)
            end
            if Options.DiceList then
                yV.SetAllowed(Options.DiceList.Value)
            end
            if Options.DiceMaxCost then
                yV.SetMaxCost(Options.DiceMaxCost.Value)
            end
            if Toggles.DailyIncludeVip then
                yw.SetIncludeVip(Toggles.DailyIncludeVip.Value)
            end
            if Toggles.AutoRace then
                y8.SetEnabled(Toggles.AutoRace.Value)
            end
            if Toggles.AutoTap then
                y0.SetEnabled(Toggles.AutoTap.Value)
            end
            if Toggles.AutoTrain then
                yX.SetEnabled(Toggles.AutoTrain.Value)
            end
            if Toggles.AutoBonus then
                yT.SetEnabled(Toggles.AutoBonus.Value)
            end
            if Toggles.AutoPlaceEggs then
                yk.SetEnabled(Toggles.AutoPlaceEggs.Value)
            end
            if Toggles.AutoHatchEggs then
                yP.SetEnabled(Toggles.AutoHatchEggs.Value)
            end
            if Toggles.AutoRebirth then
                yF.SetEnabled(Toggles.AutoRebirth.Value)
            end
            if Toggles.AutoEquipBest then
                yB.SetEnabled(Toggles.AutoEquipBest.Value)
            end
            if Toggles.AutoSell then
                ym.SetEnabled(Toggles.AutoSell.Value)
            end
            if Toggles.AutoBuyWeights then
                yZ.SetEnabled(Toggles.AutoBuyWeights.Value)
            end
            if Toggles.AutoBuyDice then
                yV.SetEnabled(Toggles.AutoBuyDice.Value)
            end
            if Toggles.AutoPlaytime then
                yN.SetEnabled(Toggles.AutoPlaytime.Value)
            end
            if Toggles.AutoEventPass then
                yI.SetEnabled(Toggles.AutoEventPass.Value)
            end
            if Toggles.AutoDaily then
                yw.SetEnabled(Toggles.AutoDaily.Value)
            end
            if Toggles.HideUiOnStart.Value then
                Library:Toggle(false)
            end
        end
        LK_4()
    end
end
zs()
zp()
end)(...)

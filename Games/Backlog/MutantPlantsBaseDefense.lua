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
getgenv().TempoHoodSubtitle = "MUTANT PLANTS BASE DEFENSE"
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
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local BusinessFolder = StarterPlayerScripts:WaitForChild("Business")
local OnClientGameEvent = require(ReplicatedStorage:WaitForChild("Business"):WaitForChild("OnClientGameEvent"))
local MainBusiness = require(ReplicatedStorage:WaitForChild("Business"):WaitForChild("MainBusiness"))
local C_Data = require(BusinessFolder:WaitForChild("C_Data"))
local BusinessBase = require(BusinessFolder:WaitForChild("BusinessBase"))
local PlayConfig = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("PlayConfig"))
local BigNumber = require(ReplicatedStorage:WaitForChild("Framework"):WaitForChild("X0000"):WaitForChild("BigNumber"))
local UNIT = "\229\141\149\228\189\141"
local STAT_UPGRADE = "\228\186\186\231\137\169\229\177\158\230\128\167\229\141\135\231\186\167"
local AUTOROLL = "\232\135\170\229\138\168\230\138\189\229\143\150\229\141\149\228\189\141_"
local AUTOROLL_OPEN = AUTOROLL .. "\230\152\175\229\144\166\229\188\128\229\144\175"
local AUTOROLL_BUY = AUTOROLL .. "\230\152\175\229\144\166\232\180\173\228\185\176"
local AUTOROLL_RARITY = AUTOROLL .. "\231\168\128\230\156\137\229\186\166"
local AUTOROLL_MUTATION = AUTOROLL .. "\230\157\144\232\180\168\231\168\128\230\156\137\229\186\166"
local EQUIP_BEST_UNIT = "\232\163\133\229\164\135\230\156\128\229\165\189_" .. UNIT
local MERGE_UNITS = "\229\144\136\230\136\144\229\141\149\228\189\141_\230\152\159\230\152\159\231\173\137\231\186\167"
local REBIRTH = "\233\135\141\231\148\159"
local PLACE_UNIT = "\230\148\190\231\189\174_" .. UNIT
local DAOJU = "\233\129\147\229\133\183"
local DAY_GIFT = "\230\175\143\230\151\165\229\165\150\229\138\177"
local DAY_BOX = "\230\175\143\230\151\165\229\174\157\231\174\177"
local START_CRAFT = "\229\188\128\229\167\139\229\136\182\228\189\156"
local CLAIM_CRAFT = "\233\162\134\229\143\150\229\136\182\228\189\156"
local USE_ITEM_TYPE = 2
local UNIVERSAL_CD = 0.35
local GAME_NAME = "Mutant Plants: Base Defense"
local DISCORD_INVITE = "https://discord.gg/K7Qxnxkk46"
local RSCRIPTS_LINK = "https://discord.gg/K7Qxnxkk46"
local repo = ""
local Library = getgenv().Library
pcall(function()
    Library.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end)
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
local Toggles = Library.Toggles
local Options = Library.Options
local function copyText(text, message)
    if setclipboard then
        setclipboard(text)
    elseif toclipboard then
        toclipboard(text)
    end
    Library:Notify(message)
end
local function copyDiscord()
    copyText(DISCORD_INVITE, "Copied Discord invite to clipboard")
end
local function colored(text, color)
    return string.format('<font color="%s">%s</font>', color, text)
end
local function field(key, value, color)
    return string.format("<b>%s</b> %s %s", key, colored("-", "#5a6070"), colored(value, color))
end
local GREEN = "#7fd47f"
local BLUE = "#6ec1ff"
local ORANGE = "#e8a34d"
local GREY = "#8b93a3"
local function isOn(name)
    if Library.Unloaded then
        return false
    end
    local toggle = Toggles[name]
    return type(toggle) == "table" and toggle.Value == true
end
local function getNumber(name, fallback)
    local option = Options[name]
    if type(option) ~= "table" then
        return fallback
    end
    return tonumber(option.Value) or fallback
end
local function getMulti(name)
    local option = Options[name]
    if type(option) ~= "table" then
        return {}
    end
    return option.Value or {}
end
local function hasAny(map)
    for _, enabled in pairs(map) do
        if enabled then
            return true
        end
    end
    return false
end
local function getData()
    local ok, data = pcall(C_Data.GetData)
    if ok then
        return data
    end
    return nil
end
local function getServerData()
    local data = getData()
    return data and data.serverData
end
local rarityNames = {}
local rarityIdByName = {}
for index, cfg in PlayConfig.allRarity do
    rarityNames[index] = cfg.name
    rarityIdByName[cfg.name] = cfg.id
end
local mutationNames = {}
local mutationIdByName = {}
for index, cfg in PlayConfig.allMaterialRarity do
    mutationNames[index] = cfg.name
    mutationIdByName[cfg.name] = cfg.id
end
local upgradeNames = {}
local upgradeIdByName = {}
for index, cfg in PlayConfig.allStatUpgrade do
    upgradeNames[index] = cfg.title
    upgradeIdByName[cfg.title] = cfg.id
end
local plantNames = {}
local plantIdByName = {}
local plantIndexByName = {}
for _, cfg in PlayConfig.allUnit do
    if cfg and cfg.name and (cfg.MaterialRarity == 1 or cfg.MaterialRarity == nil) and not plantIdByName[cfg.name] then
        plantNames[#plantNames + 1] = cfg.name
        plantIdByName[cfg.name] = cfg.id
        plantIndexByName[cfg.name] = cfg.index
    end
end
local fruitNames = {}
local fruitIdByName = {}
for _, cfg in PlayConfig.allUseItem do
    if cfg and cfg.name and cfg.useType == 1 then
        fruitNames[#fruitNames + 1] = cfg.name
        fruitIdByName[cfg.name] = cfg.id
    end
end
local craftNames = {}
local craftIdByName = {}
for _, cfg in PlayConfig.allProduction do
    local label = "Craft " .. tostring(cfg.id)
    if cfg.award then
        if cfg.award.itemEnum == UNIT then
            local unitCfg = PlayConfig.allUnit[cfg.award.value]
            if unitCfg and unitCfg.name then
                label = unitCfg.name
            end
        elseif cfg.award.itemEnum == DAOJU then
            local itemCfg = PlayConfig.allUseItem[cfg.award.value]
            if itemCfg and itemCfg.name then
                label = itemCfg.name
            end
        end
    end
    if craftIdByName[label] then
        label = label .. " #" .. tostring(cfg.id)
    end
    craftNames[#craftNames + 1] = label
    craftIdByName[label] = cfg.id
end
local plantCraftByUnitId = {}
for _, cfg in PlayConfig.allProduction do
    if cfg.award and cfg.award.itemEnum == UNIT then
        plantCraftByUnitId[cfg.award.value] = cfg.id
    end
end
local unitStarMax = PlayConfig.unitStarMax
local function selectedIdSet(optionName, idByName)
    local set = {}
    for name, enabled in pairs(getMulti(optionName)) do
        if enabled and idByName[name] then
            set[idByName[name]] = true
        end
    end
    return set
end
local function isSceneUnit(serverData, gid)
    for _, sceneGid in serverData.sceneUnit do
        if sceneGid == gid then
            return true
        end
    end
    return false
end
local function isEquippedUnit(serverData, gid)
    local hand = serverData.hand
    for index = 1, math.min(PlayConfig.handShowSize, #hand) do
        if hand[index] == gid then
            return true
        end
    end
    return false
end
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = DISCORD_INVITE .. " | " .. GAME_NAME,
    Icon = 18657887261,
    NotifySide = "Right",
    ShowCustomCursor = false,
})
local Tabs = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gamepad-2"),
    Progress = Window:AddTab("Progress", "trending-up"),
    Player = Window:AddTab("Player", "user"),
    Settings = Window:AddTab("Settings", "settings"),
}
Tabs.Roll = Tabs.Main:AddSubTab("Roll", "dices")
Tabs.Units = Tabs.Main:AddSubTab("Units", "sprout")
Tabs.Shop = Tabs.Main:AddSubTab("Shop", "shopping-bag")
Tabs.Match = Tabs.Main:AddSubTab("Match", "swords")
local function AddDiscordButton(Tab)
    local DiscordGroup = Tab:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({
        Text = "Join Discord to Make Money",
        Func = copyDiscord,
    })
    DiscordGroup:AddButton({
        Text = "Join Discord for Keyless Scripts",
        Func = copyDiscord,
    })
end
for _, Tab in Tabs do
    if Tab ~= Tabs.Main then
        AddDiscordButton(Tab)
    end
end
local executorName = "Unknown"
pcall(function()
    if identifyexecutor then
        local name, version = identifyexecutor()
        if type(name) == "string" and name ~= "" then
            executorName = type(version) == "string" and version ~= "" and (name .. " " .. version) or name
        end
    end
end)
local AccountGroup = Tabs.Info:AddLeftGroupbox("Account", "circle-user")
AccountGroup:AddLabel(field("User", LocalPlayer.Name, GREEN), true)
AccountGroup:AddLabel(field("Status", "Keyless", GREEN), true)
AccountGroup:AddLabel(field("Executor", executorName, GREEN), true)
local GameGroup = Tabs.Info:AddLeftGroupbox("Game Info", "gamepad-2")
GameGroup:AddLabel(colored(GAME_NAME .. " [" .. tostring(game.PlaceId) .. "]", BLUE), true)
GameGroup:AddLabel(field("Place ID", tostring(game.PlaceId), BLUE), true)
local SessionLabel = GameGroup:AddLabel(field("Session time", "0s", ORANGE), true)
local jobId = tostring(game.JobId)
local shortJobId = #jobId > 18 and (string.sub(jobId, 1, 18) .. "...") or jobId
GameGroup:AddLabel(field("Server", shortJobId, GREY), true)
GameGroup:AddButton({
    Text = "Copy join script (Job ID)",
    Func = function()
        local joinScript = string.format(
            'game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)',
            game.PlaceId,
            jobId
        )
        copyText(joinScript, "Copied join script to clipboard")
    end,
})
local sessionStart = os.clock()
task.spawn(function()
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local elapsed = math.floor(os.clock() - sessionStart)
        local text
        if elapsed < 60 then
            text = elapsed .. "s"
        elseif elapsed < 3600 then
            text = string.format("%dm %ds", math.floor((elapsed) / (60)), elapsed % 60)
        else
            text = string.format("%dh %dm", math.floor((elapsed) / (3600)), math.floor(((elapsed % 3600)) / (60)))
        end
        SessionLabel:SetText(field("Session time", text, ORANGE))
    end
end)
local ScriptsGroup = Tabs.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(colored("Included in this hub", GREY), true)
ScriptsGroup:AddLabel(colored(GAME_NAME, BLUE), true)
local FeaturesGroup = Tabs.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(colored("Auto Roll with Mutation Filters", BLUE), true)
FeaturesGroup:AddLabel(colored("Auto Lock by Rarity", GREEN), true)
FeaturesGroup:AddLabel(colored("Auto Sell by Rarity", ORANGE), true)
FeaturesGroup:AddLabel(colored("Auto Merge", BLUE), true)
FeaturesGroup:AddLabel(colored("Auto Equip Best", GREEN), true)
FeaturesGroup:AddLabel(colored("Auto Replace", BLUE), true)
FeaturesGroup:AddLabel(colored("Auto Buy / Delete Plants", GREEN), true)
FeaturesGroup:AddLabel(colored("Auto Buy / Use Fruit", ORANGE), true)
FeaturesGroup:AddLabel(colored("Auto Craft", BLUE), true)
FeaturesGroup:AddLabel(colored("Auto Claim Mission / Daily", GREEN), true)
FeaturesGroup:AddLabel(colored("Auto Get All Plants", ORANGE), true)
FeaturesGroup:AddLabel(colored("Auto Start / Stop at Wave", ORANGE), true)
FeaturesGroup:AddLabel(colored("Auto Rebirth", ORANGE), true)
FeaturesGroup:AddLabel(colored("Auto Upgrades", GREEN), true)
FeaturesGroup:AddLabel(colored("Player Movement", GREY), true)
local SocialsGroup = Tabs.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({
    Text = "Discord",
    Func = copyDiscord,
})
SocialsGroup:AddButton({
    Text = "Rscripts",
    Func = function()
        copyText(RSCRIPTS_LINK, "Copied Rscripts profile to clipboard")
    end,
})
local AdGroup = Tabs.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
AdGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
AdGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
AdGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
AdGroup:AddButton({
    Text = "Copy Discord Invite",
    Func = copyDiscord,
})
local FaqGroup = Tabs.Info:AddRightGroupbox("FAQ", "circle-help")
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
local RollGroup = Tabs.Roll:AddLeftGroupbox("Auto Roll", "dices")
RollGroup:AddToggle("AutoRoll", {
    Text = "Auto Roll",
    Default = false,
})
RollGroup:AddToggle("AutoRollBuy", {
    Text = "Auto Buy Rolls",
    Default = false,
})
local RollFilterGroup = Tabs.Roll:AddRightGroupbox("Keep Filters", "filter")
RollFilterGroup:AddDropdown("RollRarities", {
    Values = rarityNames,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Text = "Rarities",
    Default = {},
})
RollFilterGroup:AddDropdown("RollMutations", {
    Values = mutationNames,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Text = "Mutations",
    Default = {},
})
local LockGroup = Tabs.Units:AddLeftGroupbox("Auto Lock", "lock")
LockGroup:AddToggle("AutoLock", {
    Text = "Auto Lock",
    Default = false,
})
LockGroup:AddDropdown("LockRarities", {
    Values = rarityNames,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Text = "Rarities",
    Default = {},
})
LockGroup:AddDropdown("LockMutations", {
    Values = mutationNames,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Text = "Mutations",
    Default = {},
})
local SellGroup = Tabs.Units:AddLeftGroupbox("Auto Sell", "trash-2")
SellGroup:AddToggle("AutoSell", {
    Text = "Auto Sell",
    Default = false,
})
SellGroup:AddDropdown("SellRarities", {
    Values = rarityNames,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Text = "Rarities",
    Default = {},
})
SellGroup:AddDropdown("SellMutations", {
    Values = mutationNames,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Text = "Mutations",
    Default = {},
})
SellGroup:AddSlider("SellMaxStar", {
    Text = "Max Star",
    Default = unitStarMax,
    Min = 0,
    Max = unitStarMax,
    Rounding = 0,
})
local UnitGroup = Tabs.Units:AddRightGroupbox("Units", "sprout")
UnitGroup:AddToggle("AutoMerge", {
    Text = "Auto Merge",
    Default = false,
})
UnitGroup:AddToggle("AutoEquipBest", {
    Text = "Auto Equip Best",
    Default = false,
})
UnitGroup:AddToggle("AutoReplace", {
    Text = "Auto Replace",
    Default = false,
})
local BuyPlantGroup = Tabs.Shop:AddLeftGroupbox("Buy Plant", "sprout")
BuyPlantGroup:AddToggle("AutoBuyPlant", {
    Text = "Auto Buy Plant",
    Default = false,
})
BuyPlantGroup:AddDropdown("BuyPlants", {
    Values = plantNames,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Text = "Plants",
    Default = {},
})
local DeletePlantGroup = Tabs.Shop:AddLeftGroupbox("Delete Plant", "trash-2")
DeletePlantGroup:AddToggle("AutoDeletePlant", {
    Text = "Auto Delete Plant",
    Default = false,
})
DeletePlantGroup:AddDropdown("DeletePlants", {
    Values = plantNames,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Text = "Plants",
    Default = {},
})
local FruitGroup = Tabs.Shop:AddRightGroupbox("Fruit", "apple")
FruitGroup:AddToggle("AutoBuyFruit", {
    Text = "Auto Buy Fruit",
    Default = false,
})
FruitGroup:AddToggle("AutoUseFruit", {
    Text = "Auto Use Fruit",
    Default = false,
})
FruitGroup:AddDropdown("Fruits", {
    Values = fruitNames,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Text = "Fruits",
    Default = {},
})
local CraftGroup = Tabs.Shop:AddRightGroupbox("Craft", "hammer")
CraftGroup:AddToggle("AutoCraft", {
    Text = "Auto Craft",
    Default = false,
})
CraftGroup:AddDropdown("CraftRecipes", {
    Values = craftNames,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Text = "Recipes",
    Default = {},
})
CraftGroup:AddSlider("CraftSize", {
    Text = "Craft Size",
    Default = 1,
    Min = 1,
    Max = 20,
    Rounding = 0,
})
local MatchGroup = Tabs.Match:AddRightGroupbox("Match", "swords")
MatchGroup:AddToggle("AutoStart", {
    Text = "Auto Start",
    Default = false,
})
MatchGroup:AddToggle("AutoStopWave", {
    Text = "Auto Stop at Wave",
    Default = false,
})
MatchGroup:AddSlider("StopWave", {
    Text = "Stop Wave",
    Default = 25,
    Min = 1,
    Max = 200,
    Rounding = 0,
})
local RebirthGroup = Tabs.Progress:AddLeftGroupbox("Rebirth", "rotate-ccw")
RebirthGroup:AddToggle("AutoRebirth", {
    Text = "Auto Rebirth",
    Default = false,
})
local UpgradeGroup = Tabs.Progress:AddRightGroupbox("Upgrades", "arrow-big-up")
UpgradeGroup:AddToggle("AutoUpgrade", {
    Text = "Auto Upgrades",
    Default = false,
})
UpgradeGroup:AddDropdown("UpgradeTypes", {
    Values = upgradeNames,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Text = "Upgrades",
    Default = {},
})
local MissionGroup = Tabs.Progress:AddLeftGroupbox("Missions", "list-checks")
MissionGroup:AddToggle("AutoClaimMission", {
    Text = "Auto Claim Mission",
    Default = false,
})
MissionGroup:AddToggle("AutoGetAllPlant", {
    Text = "Auto Get All Plant",
    Default = false,
})
local DailyGroup = Tabs.Progress:AddRightGroupbox("Daily", "calendar")
DailyGroup:AddToggle("AutoClaimDaily", {
    Text = "Auto Claim Daily Rewards",
    Default = false,
})
local function syncRollFlag(key, current, desired)
    if current == desired then
        return false
    end
    OnClientGameEvent:Business(key)
    return true
end
local function syncRollList(key, stateList, wanted, count)
    for index = 1, count do
        if Library.Unloaded then
            return
        end
        local current = stateList[index] == true
        local desired = wanted[index] == true
        if current ~= desired then
            OnClientGameEvent:BusinessToId(key, index)
            task.wait(UNIVERSAL_CD)
        end
    end
end
task.spawn(function()
    while not Library.Unloaded do
        task.wait(1)
        if isOn("AutoRoll") then
            local serverData = getServerData()
            if serverData then
                local wantedRarities = selectedIdSet("RollRarities", rarityIdByName)
                local wantedMutations = selectedIdSet("RollMutations", mutationIdByName)
                syncRollList(AUTOROLL_RARITY, serverData.aotuRollUnitRarity, wantedRarities, #rarityNames)
                syncRollList(AUTOROLL_MUTATION, serverData.aotuRollUnitMaterialRarity, wantedMutations, #mutationNames)
                if syncRollFlag(AUTOROLL_BUY, serverData.aotuRollBuy == true, isOn("AutoRollBuy")) then
                    task.wait(UNIVERSAL_CD)
                end
                syncRollFlag(AUTOROLL_OPEN, serverData.aotuRollOpen == true, true)
            end
        end
    end
end)
Toggles.AutoRoll:OnChanged(function()
    if isOn("AutoRoll") then
        return
    end
    local serverData = getServerData()
    if serverData and serverData.aotuRollOpen then
        OnClientGameEvent:Business(AUTOROLL_OPEN)
    end
end)
local function readFilter(rarityOption, mutationOption)
    return {
        rarities = selectedIdSet(rarityOption, rarityIdByName),
        mutations = selectedIdSet(mutationOption, mutationIdByName),
        hasMutation = hasAny(getMulti(mutationOption)),
    }
end
local function filterMatches(filter, cfg)
    if not filter.rarities[cfg.rarity] then
        return false
    end
    if filter.hasMutation and not filter.mutations[cfg.MaterialRarity] then
        return false
    end
    return true
end
local function getUnit(data, gid)
    local card = data.playData.allCard[gid]
    if card == nil or card.typeId ~= 1 then
        return nil
    end
    return card, PlayConfig.allUnit[card.cfgId]
end
task.spawn(function()
    while not Library.Unloaded do
        task.wait(2)
        local lockFilter = nil
        if isOn("AutoLock") then
            local filter = readFilter("LockRarities", "LockMutations")
            if hasAny(filter.rarities) then
                lockFilter = filter
            end
        end
        if lockFilter then
            local data = getData()
            if data then
                for _, entry in data.serverData.allCard do
                    if Library.Unloaded or not isOn("AutoLock") then
                        break
                    end
                    local card, cfg = getUnit(data, entry.gid)
                    if card ~= nil and cfg ~= nil and not card.isLock and filterMatches(lockFilter, cfg) then
                        OnClientGameEvent:Lock_GidData_Item(UNIT, entry.gid)
                        task.wait(UNIVERSAL_CD)
                    end
                end
            end
        end
        if isOn("AutoSell") then
            local sellFilter = readFilter("SellRarities", "SellMutations")
            if hasAny(sellFilter.rarities) then
                local data = getData()
                if data then
                    local maxStar = getNumber("SellMaxStar", unitStarMax)
                    local gids = {}
                    for _, entry in data.serverData.allCard do
                        local gid = entry.gid
                        local card, cfg = getUnit(data, gid)
                        if card ~= nil and cfg ~= nil and not card.isLock and card.star <= maxStar then
                            local protected = lockFilter ~= nil and filterMatches(lockFilter, cfg)
                            if not protected and filterMatches(sellFilter, cfg) then
                                if not isSceneUnit(data.serverData, gid) and not isEquippedUnit(data.serverData, gid) then
                                    table.insert(gids, gid)
                                end
                            end
                        end
                    end
                    if #gids > 0 then
                        OnClientGameEvent:Destroy_GidData_Item(UNIT, gids)
                    end
                end
            end
        end
    end
end)
local function hasMergeableUnit(serverData)
    local data = getData()
    if not data then
        return false
    end
    local counts = {}
    for _, entry in serverData.allCard do
        local gid = entry.gid
        local card = data.playData.allCard[gid]
        if card ~= nil and card.typeId == 1 and not card.isLock and card.star < unitStarMax then
            if not isSceneUnit(serverData, gid) then
                local key = tostring(card.cfgId) .. "_" .. tostring(card.star)
                counts[key] = (counts[key] or 0) + 1
                if counts[key] >= 2 then
                    return true
                end
            end
        end
    end
    return false
end
task.spawn(function()
    while not Library.Unloaded do
        task.wait(3)
        if isOn("AutoMerge") then
            local serverData = getServerData()
            if serverData and hasMergeableUnit(serverData) then
                OnClientGameEvent:Business(MERGE_UNITS)
            end
        end
    end
end)
task.spawn(function()
    local lastCardCount = -1
    while not Library.Unloaded do
        task.wait(2)
        if isOn("AutoEquipBest") then
            local serverData = getServerData()
            if serverData then
                local count = #serverData.allCard
                if count ~= lastCardCount then
                    lastCardCount = count
                    OnClientGameEvent:Business(EQUIP_BEST_UNIT)
                end
            end
        else
            lastCardCount = -1
        end
    end
end)
local function isInMatch()
    local ok, state = pcall(function()
        local FrameworkLink = require(BusinessFolder:WaitForChild("FrameworkLink"))
        local upUI = FrameworkLink.UIManager:Find("\228\184\138UI")
        return upUI and upUI.isGpStart and upUI.isGpStart.nowState
    end)
    return ok and state == 2
end
local function currentWave()
    local data = getData()
    local wave = data and data.playData.wave
    return wave and wave.Value or 0
end
task.spawn(function()
    while not Library.Unloaded do
        task.wait(2)
        local inMatch = isInMatch()
        if isOn("AutoStopWave") and inMatch and currentWave() >= getNumber("StopWave", 25) then
            OnClientGameEvent:ExitGp()
            task.wait(3)
        elseif isOn("AutoStart") and not inMatch then
            OnClientGameEvent:StartGp()
            task.wait(3)
        end
    end
end)
local function unitDps(data, card)
    return MainBusiness.Get_UnitDps(data.playData.bestUnitAtk.Value, card, data.playData.AtkRep.Value, data.playData.atkSpeedRep.Value)
end
local function unitCard(data, gid)
    if gid == nil or gid <= 0 then
        return nil
    end
    local card = data.playData.allCard[gid]
    if card == nil or card.typeId ~= 1 then
        return nil
    end
    return card
end
local function findBetterHandSlot(data, chunkDps)
    local bestSlot, bestDps
    for slot = 1, PlayConfig.handShowSize do
        local gid = data.serverData.hand[slot]
        local card = unitCard(data, gid)
        if card ~= nil and not isSceneUnit(data.serverData, gid) then
            local dps = unitDps(data, card)
            if chunkDps == nil or BigNumber.BigCompareNoEqual(dps, chunkDps) then
                if bestDps == nil or BigNumber.BigCompareNoEqual(dps, bestDps) then
                    bestSlot, bestDps = slot, dps
                end
            end
        end
    end
    return bestSlot
end
task.spawn(function()
    while not Library.Unloaded do
        task.wait(2)
        if isOn("AutoReplace") then
            local data = getData()
            if data then
                for chunk = 1, #data.serverData.sceneUnit do
                    if Library.Unloaded or not isOn("AutoReplace") then
                        break
                    end
                    if data.serverData.sceneUnitChunkUnlock[chunk] == true then
                        local card = unitCard(data, data.serverData.sceneUnit[chunk])
                        local slot = findBetterHandSlot(data, card and unitDps(data, card) or nil)
                        if slot ~= nil then
                            OnClientGameEvent:SelectHandUnit(slot)
                            task.wait(UNIVERSAL_CD)
                            OnClientGameEvent:BusinessToId(PLACE_UNIT, chunk)
                            task.wait(UNIVERSAL_CD)
                        end
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        task.wait(5)
        if isOn("AutoRebirth") then
            local serverData = getServerData()
            if serverData then
                local cfg = PlayConfig.allRebirth[serverData.rebirth + 1]
                if cfg ~= nil then
                    local ok, ready = pcall(function()
                        return BusinessBase.Con(cfg.con, false) and BusinessBase.Con(cfg.cost, false)
                    end)
                    if ok and ready then
                        OnClientGameEvent:Business(REBIRTH)
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        task.wait(0.1)
        if isOn("AutoUpgrade") then
            local serverData = getServerData()
            if serverData then
                local wanted = selectedIdSet("UpgradeTypes", upgradeIdByName)
                for index, cfg in PlayConfig.allStatUpgrade do
                    if Library.Unloaded then
                        break
                    end
                    if wanted[cfg.id] then
                        local level = serverData.allStatUpgrade[index]
                        while level < cfg.size do
                            if Library.Unloaded or not isOn("AutoUpgrade") then
                                break
                            end
                            local cost = BigNumber.MulNumber(cfg.cost, cfg.costRep ^ level)
                            local ok, affordable = pcall(BusinessBase.Con, {
                                value = cost,
                                size = 1,
                                itemEnum = cfg.costItemEnum,
                            }, false)
                            if not (ok and affordable) then
                                break
                            end
                            OnClientGameEvent:Buy_Backpack_Item(STAT_UPGRADE, cfg.id)
                            local deadline = os.clock() + UNIVERSAL_CD
                            repeat
                                task.wait()
                            until serverData.allStatUpgrade[index] ~= level or os.clock() >= deadline
                            if serverData.allStatUpgrade[index] == level then
                                break
                            end
                            level = serverData.allStatUpgrade[index]
                        end
                    end
                end
            end
        end
    end
end)
local function selectedNameSet(optionName)
    local set = {}
    for name, enabled in pairs(getMulti(optionName)) do
        if enabled then
            set[name] = true
        end
    end
    return set
end
local function getUnixTime()
    local FrameworkLink = require(BusinessFolder:WaitForChild("FrameworkLink"))
    local ok, ms = pcall(function()
        return FrameworkLink.TimeSynch:Get_UnixTimestampMillis()
    end)
    if ok and type(ms) == "number" then
        return math.floor(ms / 1000)
    end
    return os.time()
end
local function canAfford(con)
    if type(con) ~= "table" then
        return true
    end
    local ok, ready = pcall(BusinessBase.Con, con, false)
    return ok and ready == true
end
local function craftAffordable(cfg)
    if type(cfg.data) ~= "table" then
        return true
    end
    for _, entry in pairs(cfg.data) do
        if type(entry) == "table" then
            local cost = entry.cost or entry
            if type(cost) == "table" and cost.itemEnum and not canAfford(cost) then
                return false
            end
        end
    end
    return true
end
local function productionReady(serverData)
    local productionId = serverData.productionId
    if productionId == nil or productionId == 0 then
        return false
    end
    local startTime = serverData.productionStartTime or 0
    local maxTime = serverData.productionMaxTime or 0
    return getUnixTime() >= (startTime + maxTime)
end
task.spawn(function()
    while not Library.Unloaded do
        task.wait(1)
        if isOn("AutoDeletePlant") then
            local wanted = selectedNameSet("DeletePlants")
            if hasAny(wanted) then
                local data = getData()
                if data then
                    local indexes = {}
                    for name in pairs(wanted) do
                        local index = plantIndexByName[name]
                        if index then
                            indexes[index] = true
                        end
                    end
                    local gids = {}
                    for _, entry in data.serverData.allCard do
                        local gid = entry.gid
                        local card, cfg = getUnit(data, gid)
                        if card ~= nil and cfg ~= nil and indexes[cfg.index] and not card.isLock then
                            if not isSceneUnit(data.serverData, gid) and not isEquippedUnit(data.serverData, gid) then
                                table.insert(gids, gid)
                            end
                        end
                    end
                    if #gids > 0 then
                        OnClientGameEvent:Destroy_GidData_Item(UNIT, gids)
                        task.wait(UNIVERSAL_CD)
                    end
                end
            end
        end
        if isOn("AutoBuyPlant") then
            local wanted = selectedNameSet("BuyPlants")
            if hasAny(wanted) then
                local serverData = getServerData()
                if serverData and (serverData.productionId == nil or serverData.productionId == 0) then
                    for name in pairs(wanted) do
                        if Library.Unloaded or not isOn("AutoBuyPlant") then
                            break
                        end
                        local unitId = plantIdByName[name]
                        if unitId then
                            local craftId = plantCraftByUnitId[unitId]
                            if craftId then
                                local cfg = PlayConfig.allProduction[craftId]
                                if cfg and craftAffordable(cfg) then
                                    OnClientGameEvent:BusinessToIdSize(START_CRAFT, craftId, 1)
                                    task.wait(UNIVERSAL_CD)
                                    break
                                end
                            else
                                if canAfford(PlayConfig.allUnit[unitId] and PlayConfig.allUnit[unitId].cost) then
                                    OnClientGameEvent:Buy_Backpack_Item(UNIT, unitId)
                                    task.wait(UNIVERSAL_CD)
                                end
                            end
                        end
                    end
                end
            end
        end
        if isOn("AutoBuyFruit") then
            local wanted = selectedNameSet("Fruits")
            if hasAny(wanted) then
                for name in pairs(wanted) do
                    if Library.Unloaded or not isOn("AutoBuyFruit") then
                        break
                    end
                    local fruitId = fruitIdByName[name]
                    local cfg = fruitId and PlayConfig.allUseItem[fruitId]
                    if cfg and canAfford(cfg.cost) then
                        OnClientGameEvent:Buy_Backpack_Item(DAOJU, cfg.id)
                        task.wait(UNIVERSAL_CD)
                    end
                end
            end
        end
        if isOn("AutoUseFruit") then
            local wanted = selectedNameSet("Fruits")
            if hasAny(wanted) then
                local serverData = getServerData()
                if serverData and serverData.allUseItemStoreSize then
                    for name in pairs(wanted) do
                        if Library.Unloaded or not isOn("AutoUseFruit") then
                            break
                        end
                        local fruitId = fruitIdByName[name]
                        if fruitId and (serverData.allUseItemStoreSize[fruitId] or 0) > 0 then
                            OnClientGameEvent:UseItem(fruitId, USE_ITEM_TYPE)
                            task.wait(UNIVERSAL_CD)
                        end
                    end
                end
            end
        end
        if isOn("AutoCraft") then
            local serverData = getServerData()
            if serverData then
                if productionReady(serverData) then
                    OnClientGameEvent:Business(CLAIM_CRAFT)
                    task.wait(UNIVERSAL_CD)
                elseif serverData.productionId == nil or serverData.productionId == 0 then
                    local wanted = selectedNameSet("CraftRecipes")
                    if hasAny(wanted) then
                        local size = math.max(1, math.floor(getNumber("CraftSize", 1)))
                        for name in pairs(wanted) do
                            if Library.Unloaded or not isOn("AutoCraft") then
                                break
                            end
                            local craftId = craftIdByName[name]
                            local cfg = craftId and PlayConfig.allProduction[craftId]
                            if cfg and craftAffordable(cfg) then
                                OnClientGameEvent:BusinessToIdSize(START_CRAFT, craftId, size)
                                task.wait(UNIVERSAL_CD)
                                break
                            end
                        end
                    end
                end
            end
        elseif isOn("AutoBuyPlant") then
            local serverData = getServerData()
            if serverData and productionReady(serverData) then
                OnClientGameEvent:Business(CLAIM_CRAFT)
                task.wait(UNIVERSAL_CD)
            end
        end
        if isOn("AutoClaimMission") then
            local serverData = getServerData()
            if serverData then
                for index, cfg in PlayConfig.allDayTask do
                    if Library.Unloaded or not isOn("AutoClaimMission") then
                        break
                    end
                    local need = cfg.con and cfg.con.size or 0
                    local progress = serverData.dayTaskSize and serverData.dayTaskSize[index] or 0
                    local claimed = serverData.dayTaskIsOk and serverData.dayTaskIsOk[index] == true
                    if need > 0 and progress >= need and not claimed and cfg.con and cfg.con.itemEnum then
                        OnClientGameEvent:BusinessToId(cfg.con.itemEnum, cfg.id)
                        task.wait(UNIVERSAL_CD)
                    end
                end
            end
        end
        if isOn("AutoClaimDaily") then
            local serverData = getServerData()
            if serverData then
                local nextDay = (serverData.dayGift or 0) + 1
                if PlayConfig.dayGift[nextDay] then
                    OnClientGameEvent:BusinessToId(DAY_GIFT, nextDay)
                    task.wait(UNIVERSAL_CD)
                end
                local boxTime = serverData.dailyBoxTime or 0
                if boxTime > 0 and getUnixTime() >= boxTime then
                    OnClientGameEvent:GetGift(DAY_BOX)
                    task.wait(UNIVERSAL_CD)
                end
            end
        end
        if isOn("AutoGetAllPlant") then
            local data = getData()
            if data then
                for chunk = 1, #data.serverData.sceneUnit do
                    if Library.Unloaded or not isOn("AutoGetAllPlant") then
                        break
                    end
                    if data.serverData.sceneUnitChunkUnlock[chunk] == true then
                        local sceneGid = data.serverData.sceneUnit[chunk]
                        if sceneGid == nil or sceneGid <= 0 then
                            local slot = findBetterHandSlot(data, nil)
                            if slot ~= nil then
                                OnClientGameEvent:SelectHandUnit(slot)
                                task.wait(UNIVERSAL_CD)
                                OnClientGameEvent:BusinessToId(PLACE_UNIT, chunk)
                                task.wait(UNIVERSAL_CD)
                            end
                        end
                    end
                end
            end
        end
    end
end)
local MovementGroup = Tabs.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", {
    Text = "WalkSpeed",
    Default = false,
})
MovementGroup:AddSlider("WalkSpeed", {
    Text = "WalkSpeed Amount",
    Default = 32,
    Min = 16,
    Max = 250,
    Rounding = 0,
})
MovementGroup:AddToggle("InfJump", {
    Text = "Infinite Jump",
    Default = false,
})
MovementGroup:AddToggle("NoClip", {
    Text = "NoClip",
    Default = false,
})
local FlyGroup = Tabs.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", {
    Text = "Fly",
    Default = false,
})
FlyGroup:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Default = 60,
    Min = 10,
    Max = 400,
    Rounding = 0,
})
local function getHumanoid()
    local character = LocalPlayer.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end
local function getRoot()
    local character = LocalPlayer.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end
local steppedConnection = RunService.Stepped:Connect(function()
    if Library.Unloaded then
        return
    end
    if isOn("NoClip") then
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)
local jumpConnection = UserInputService.JumpRequest:Connect(function()
    if Library.Unloaded then
        return
    end
    if isOn("InfJump") then
        local humanoid = getHumanoid()
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
local Camera = workspace.CurrentCamera
local renderConnection = RunService.RenderStepped:Connect(function(dt)
    if Library.Unloaded then
        return
    end
    if isOn("WalkSpeedEnabled") then
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = getNumber("WalkSpeed", 32)
        end
    end
    if isOn("Fly") then
        local root = getRoot()
        local humanoid = getHumanoid()
        if root and humanoid then
            humanoid.PlatformStand = true
            local direction = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                direction = direction - Vector3.new(0, 1, 0)
            end
            root.AssemblyLinearVelocity = Vector3.zero
            if direction.Magnitude > 0 then
                root.CFrame = root.CFrame + direction.Unit * getNumber("FlySpeed", 60) * dt
            end
        end
    end
end)
Toggles.Fly:OnChanged(function()
    if not isOn("Fly") then
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end)
Toggles.WalkSpeedEnabled:OnChanged(function()
    if not isOn("WalkSpeedEnabled") then
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end)
local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu", "menu")
local antiAfkLastInput = tick()
local antiAfkLastTap = tick()
pcall(function()
    for _, connection in ipairs(getconnections(LocalPlayer.Idled)) do
        pcall(function()
            connection:Disable()
        end)
    end
end)
local function antiAfkTap()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), camera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), camera.CFrame)
    antiAfkLastTap = tick()
end
local antiAfkBeganConnection = UserInputService.InputBegan:Connect(function()
    antiAfkLastInput = tick()
end)
local antiAfkChangedConnection = UserInputService.InputChanged:Connect(function(input)
    local inputType = input.UserInputType
    if inputType == Enum.UserInputType.MouseMovement or inputType == Enum.UserInputType.Gamepad1 then
        antiAfkLastInput = tick()
    end
end)
MenuGroup:AddToggle("AntiAfk", {
    Text = "Anti-AFK",
    Default = true,
})
task.spawn(function()
    while not Library.Unloaded do
        task.wait(2)
        if isOn("AntiAfk") then
            local idle = tick() - antiAfkLastInput
            local sinceTap = tick() - antiAfkLastTap
            if idle >= 300 and sinceTap >= 60 then
                pcall(antiAfkTap)
            elseif idle < 300 and sinceTap >= 300 then
                pcall(antiAfkTap)
            end
        end
    end
end)
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind",
})
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)
Library:OnUnload(function()
    steppedConnection:Disconnect()
    jumpConnection:Disconnect()
    renderConnection:Disconnect()
    antiAfkBeganConnection:Disconnect()
    antiAfkChangedConnection:Disconnect()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.PlatformStand = false
        humanoid.WalkSpeed = 16
    end
end)
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("TempoHub")
SaveManager:SetFolder("TempoHub/mutant-plants-base-defense")
ThemeManager:SaveDefault("Mint")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
ThemeManager:LoadDefault()
SaveManager:LoadAutoloadConfig()
end)(...)

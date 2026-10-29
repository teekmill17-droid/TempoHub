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
getgenv().TempoHoodSubtitle = "ZONE DEFENSE RNG"
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
local np
local nO
local ns
local nv
local nR
local nU
local ny
local nB
local ni
local nE
local nl
local nH
local nK
local LocalPlayer
local nr
local nu
local nx
local nT
local nA
local nh
local nD
local nZ
local nk
local n1
local nG
local nJ
local nq
local nM
local nt
local nP
local nw
local nV
local nC
local nF
local nj
local nm
local nI
local nL
local function fn16()
    local core = nj.core
    local ov = core and core.toolObjs
    local ou_1 = ov
    if ov then
        ov = ou_1.currentTool
    end
    local ou_2 = ov
    local ov_1 = typeof(ou_2) == "Instance" and ou_2.Parent
    if ov_1 then
        return ou_2
    end
    local Character = LocalPlayer.Character
    local ov_2 = Character and Character:FindFirstChildWhichIsA("Tool")
    return ov_2
end
local function worker2()
    while not n1.Unloaded do
        if n1.Flags.AutoEquipBest then
            n1.EquipBest()
            task.wait(2)
        else
            task.wait(0.4)
        end
    end
end
local function fn96()
    local op = nK.getReplica()
    return op and op.Data
end
local function fn110(F, G)
    local connection = F:Connect(G)
    table.insert(ni, connection)
    return connection
end
local function fn118()
    ns("luck")
end
local function fn164()
    if nj.auraMouse and nj.input then
        nj.input.isMouseDown = false
    end
    nj.auraMouse = false
end
local function fn166(an)
    if not an or nF[an] then
        return
    end
    local oG_1 = nP(an, "firerate")
    local oH = oG_1 and oG_1.Value
    nF[an] = { firerate = oH }
end
local function fn184()
    local qn = nZ()
    if not qn then
        return
    end
    local qo = nR.getInvLimitForPlayer(LocalPlayer)
    if qn.numOwnedExaltedWeapons >= qo then
        return
    end
    local qo_1 = nU.getNextRollCost(qn)
    local qp = type(qo_1) == "number" and qn.cash < qo_1
    if qp then
        return
    end
    pcall(function()
        nG.Roll:InvokeServer()
    end)
end
local function fn205(bu, bv)
    local py = if not nr(bu, bv) then 1 else 0
    if py == 1 then
        return false
    end
    local attr = bu:GetAttribute("simZombieId")
    local pu = type(attr) == "number" and nw[attr]
    local pt_1 = pu
    if pu then
        pu = os.clock() < pt_1
    end
    return not pu
end
local function fn240()
    if nO and nO.Parent then
        return nO
    end
    local folder = Instance.new("Folder")
    folder.Name = "TempoZDRNGEsp"
    folder.Parent = nV()
    nO = folder
    return folder
end
local function fn276()
    for k, v in nl do
        if v.gui then
            v.gui:Destroy()
        end
        if v.highlight then
            v.highlight:Destroy()
        end
        nl[k] = nil
    end
end
local function fn307()
    if n1.Unloaded then
        return
    end
    n1.Unloaded = true
    for k in n1.Flags do
        n1.Flags[k] = false
    end
    nh()
    for k in nF do
        nM(k)
    end
    table.clear(nF)
    table.clear(nB)
    table.clear(nw)
    nm()
    if nO then
        nO:Destroy()
        nO = nil
    end
    for k, v in ni do
        v:Disconnect()
    end
    table.clear(ni)
    if getgenv()[nJ] == n1 then
        getgenv()[nJ] = nil
    end
end
local function fn317()
    ns("damage")
end
local function fn335(bK, bL)
    local pH
    local pI = bL
    for k, v in nD:QueryDescendants("BasePart#HumanoidRootPart") do
        local Parent = v.Parent
        if nL(Parent, v) then
            local Magnitude = (v.Position - bK).Magnitude
            if Magnitude < pI then
                pI = Magnitude
                pH = v
            end
        end
    end
    return pH, pI
end
local function fn450(bn, bo)
    if not (bn and bo and bo.Parent) then
        return false
    elseif bo.Position.Magnitude >= nA then
        return false
    elseif nT(bn) then
        nu(bn)
        return false
    else
        return true
    end
end
local function worker3()
    while not n1.Unloaded do
        if n1.Flags.UpgradeLuck then
            n1.UpgradeLuck()
        end
        if n1.Flags.UpgradeDamage then
            n1.UpgradeDamage()
        end
        task.wait(0.35)
    end
end
local function fn492(bD)
    for k, v in nD:QueryDescendants("BasePart#HumanoidRootPart") do
        local Parent = v.Parent
        if nr(Parent, v) then
            bD(Parent, v)
        end
    end
end
local function worker()
    while not n1.Unloaded do
        if n1.Flags.AutoRoll then
            n1.Roll()
            task.wait(0.4)
        else
            task.wait(0.25)
        end
    end
end
local function worker5()
    while not n1.Unloaded do
        n1.UpdateEsp()
        task.wait(0.2)
    end
end
local function fn523(aY)
    if not aY then
        return
    end
    nq(aY)
    nC(aY)
    local o4 = nF[aY]
    local o5 = nP(aY, "firerate")
    local o6 = o5 and o4 and o4.firerate ~= nil
    local o6_1
    if o6 then
        if n1.Flags.RapidFire then
            o6_1 = nx
        else
            o6_1 = o4.firerate
        end
        o5.Value = o6_1
    end
    if n1.Flags.NoReload then
        nk(aY)
    end
end
local function fn533(dX, dY, dZ)
    local Name = dX:FindFirstChild("Name")
    local Dist = dX:FindFirstChild("Dist")
    if Name then
        Name.Text = dY.Name
    end
    if Dist then
        Dist.Text = string.format("%dm", math.floor(dZ + 0.5))
    end
end
local function fn619(bg)
    if bg:GetAttribute("dead") then
        return true
    end
    local attr = bg:GetAttribute("clientHealth")
    local pi = type(attr) ~= "number" or attr <= 0
    if pi then
        return true
    end
    local pi_1 = (bg:GetAttribute("pendingPredictedDmg"))
    local pn = if pi_1 then 1 else 0
    local pl = 2404 * pn + 3747 * (1 - pn)
    local pm = 1518 * pn + 2783 * (1 - pn)
    if not ((pl * 3529 + pm * 2856 + pl * pm) % 16777213 == 16468396) then
        pi_1 = 0
    end
    if attr - pi_1 <= 0 then
        return true
    end
    local Humanoid = bg:FindFirstChildOfClass("Humanoid")
    return Humanoid ~= nil and Humanoid.Health <= 0
end
local function fn734(ah, ai)
    local oA = ah and ah:FindFirstChild("config")
    local oB = oA
    if oA then
        oA = oB:FindFirstChild(ai)
    end
    return oA
end
local function fn751(aB)
    local oQ = nP(aB, "ammo")
    if not oQ then
        return
    end
    local MaxValue = oQ.MaxValue
    local oS = type(MaxValue) ~= "number" or oQ.Value >= MaxValue
    if oS then
        return
    end
    ny = true
    oQ.Value = MaxValue
    ny = false
    if nj.core then
        nj.core.isReloading = false
    end
end
local function fn763()
    local pZ_1
    local pY_1
    local pX = nZ()
    if not pX then
        return nil
    end
    pY_1, pZ_1 = nE(pX.maxWeaponDpsWeaponKey)
    local p_ = pY_1 and pX.exaltedWeapons and pX.exaltedWeapons[pY_1]
    if p_ then
        p_ = not pZ_1 or pX.exaltedWeapons[pY_1][pZ_1]
    end
    if p_ then
        return pY_1, pZ_1
    end
    local p__1 = nil
    local pY_2 = nil
    local pZ_2 = -1
    local p0_2 = -1
    local exaltedWeapons = pX.exaltedWeapons
    if type(exaltedWeapons) ~= "table" then
        return nil
    end
    for k, v in exaltedWeapons do
        if type(v) == "table" then
            for k2, v in v do
                local p1_1 = nt[v.rarity] or 0
                local pX_2 = tonumber(v.rollOneIn) or 0
                if p1_1 > p0_2 or p1_1 == p0_2 and pX_2 > pZ_2 then
                    p0_2 = p1_1
                    pZ_2 = pX_2
                    p__1 = k
                    pY_2 = k2
                end
            end
        end
    end
    return p__1, pY_2
end
local function fn841(n)
    local on = typeof(cloneref) == "function" and typeof(n) == "Instance"
    if on then
        return cloneref(n)
    end
    return n
end
local function fn854(au)
    local oJ = nF[au]
    if not oJ then
        return
    end
    local oK = nP(au, "firerate")
    if oK and oJ.firerate ~= nil then
        oK.Value = oJ.firerate
    end
end
local function worker4()
    while not n1.Unloaded do
        local rS = nH()
        if rS then
            nv(rS)
        end
        if n1.Flags.KillAura then
            n1.KillAura()
            local rT = rS and nP(rS, "firerate")
            local rS_1 = nx
            local rU = rT
            if not n1.Flags.RapidFire then
                if rT then
                    rT = rU.Value
                end
                rS_1 = rT or 0.1
            end
            task.wait(math.max(0.02, rS_1))
        else
            nh()
            task.wait(0.15)
        end
    end
end
local function fn866()
    if nj.core and nj.input then
        return true
    end
    local qP_1 = pcall(function()
        local Player_Logic = LocalPlayer.PlayerScripts:WaitForChild("Player Logic", 5)
        local qN = Player_Logic and Player_Logic:WaitForChild("toolSystem"):WaitForChild("modules")
        if not qN then
            return
        end
        nj.core = require(qN:WaitForChild("coreHandler"))
        nj.input = require(qN:WaitForChild("inputHandler"))
    end)
    return qP_1 and nj.core ~= nil and nj.input ~= nil
end
local function fn892()
    if typeof(gethui) == "function" then
        return gethui()
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end
local function fn918(d2, d3)
    local d5 = nI()
    local highlight = Instance.new("Highlight")
    highlight.Name = "Esp"
    highlight.Adornee = d2
    highlight.FillColor = Color3.fromRGB(255, 70, 70)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0.1
    highlight.Parent = d5
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "Esp"
    billboardGui.AlwaysOnTop = true
    billboardGui.Size = UDim2.fromOffset(160, 36)
    billboardGui.StudsOffset = Vector3.new(0, 3.2, 0)
    billboardGui.Adornee = d3
    billboardGui.Parent = d5
    local textLabel2 = Instance.new("TextLabel")
    textLabel2.Name = "Name"
    textLabel2.BackgroundTransparency = 1
    textLabel2.Size = UDim2.fromScale(1, 0.55)
    textLabel2.Font = Enum.Font.BuilderSans
    textLabel2.TextColor3 = Color3.fromRGB(255, 90, 90)
    textLabel2.TextStrokeTransparency = 0.4
    textLabel2.TextScaled = true
    textLabel2.Parent = billboardGui
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Dist"
    textLabel.BackgroundTransparency = 1
    textLabel.Position = UDim2.fromScale(0, 0.55)
    textLabel.Size = UDim2.fromScale(1, 0.45)
    textLabel.Font = Enum.Font.BuilderSans
    textLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    textLabel.TextStrokeTransparency = 0.4
    textLabel.TextScaled = true
    textLabel.Parent = billboardGui
    nl[d2] = { gui = billboardGui, highlight = highlight, root = d3 }
end
local function fn920(bV)
    local pR = bV == ""
    local pR_1
    local pS = type(bV) ~= "string" or pR
    local pS_1
    if pS then
        return nil
    end
    pS_1, pR_1 = string.match(bV, "^(.-):(%b{})$")
    if pS_1 then
        return pS_1, pR_1
    end
    return bV, nil
end
local function fn958(ba)
    local pb = ba and ba:GetAttribute("simZombieId")
    if type(pb) == "number" then
        nw[pb] = os.clock() + np
    end
end
nh = nil
ni = nil
nj = nil
nk = nil
nl = nil
nm = nil
np = nil
nq = nil
nr = nil
ns = nil
nt = nil
nu = nil
nv = nil
nw = nil
nx = nil
ny = nil
nA = nil
nB = nil
nC = nil
nD = nil
nE = nil
nF = nil
nG = nil
nH = nil
nI = nil
nJ = nil
nK = nil
nL = nil
nM = nil
LocalPlayer = nil
nO = nil
nP = nil
nR = nil
nT = nil
nU = nil
nV = nil
nZ = nil
n1 = nil
local Players, nn, no, nz, nQ, Workspace, RunService, nX, nY, n_, n0
local n2_1
local n7_1
local n8_1
Players, RunService, Workspace, LocalPlayer, nJ = nil, nil, nil, nil, nil
Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
nJ = "TempoZoneDefenseRNG"
local n4 = getgenv()[nJ]
if n4 and n4.Unload then
    n4.Unload()
end
n8_1, nY, nU, nR, nK, nG, nD, nA, nx, nt, n7_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if ((nx and not n8_1 or not nK and nK) and (not n8_1 and nx or not nK and not nx) or (not nx and not n8_1 or nK and not nx or (nx and nK or (nx or not nK)))) and ((nK and not n8_1 or (not nK or n8_1)) and (not n8_1 and not nK or (not nK or not n8_1)) and ((not nx or nx or nK and nK) and (nK or n8_1 or nx and not nx))) and not (((nx and not n8_1 or not nK and nK) and (not n8_1 and nx or not nK and not nx) or (not nx and not n8_1 or nK and not nx or (nx and nK or (nx or not nK)))) and ((nK and not n8_1 or (not nK or n8_1)) and (not n8_1 and not nK or (not nK or not n8_1)) and ((not nx or nx or nK and nK) and (nK or n8_1 or nx and not nx)))) then
    nx = fn841
else
    n7_1 = fn841
end
local n6 = n7_1(ReplicatedStorage)
local n3_1 = n7_1(n6:WaitForChild("events"))
local n8_2 = n7_1(n6:WaitForChild("modules"))
nY = require(n7_1(n8_2:WaitForChild("itemData")))
nU = require(n7_1(n8_2:WaitForChild("newProgressionData")))
nR = require(n7_1(n8_2:WaitForChild("utils")))
nK = require(n7_1(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("clientData")))
nG = {
    Roll = n7_1(n3_1:WaitForChild("rollWeapon")),
    TrackUpgrade = n7_1(n3_1:WaitForChild("purchaseTrackUpgrade")),
    Equip = n7_1(n3_1:WaitForChild("equipItem"))
}
nD = n7_1(Workspace:WaitForChild("ai"))
nA = 8000
nx = 0.03
nt = {}
for k, v in nU.rarityOrder do
    nt[v] = k
end
ni, nF, nB, ny, nw, np, nl, nj, n1, nO, n_, nZ, nH, nP, nq, nM, nk, nC, nv, nu, nT, nr, nL, n0, nz, nE, no, ns, nX, nh, nm, nV, nI, nn, nQ, n2_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
ni = {}
n_ = fn110
nF = {}
nB = {}
ny = false
nw = {}
np = 5
if (false or not nm or not nz and not nm) and (nz or nz or (nm or not nz)) or ((nz or not nm) and (false or not nm) or n2_1 and not nm and (false and nz)) or (not nm and nz and (nm and not nz) and (not nm and false and (not nz and not nz)) or not nm and n2_1 and (not nz or nm) and ((n2_1 or n2_1) and (n2_1 or n2_1))) or not ((false or not nm or not nz and not nm) and (nz or nz or (nm or not nz)) or ((nz or not nm) and (false or not nm) or n2_1 and not nm and (false and nz)) or (not nm and nz and (nm and not nz) and (not nm and false and (not nz and not nz)) or not nm and n2_1 and (not nz or nm) and ((n2_1 or n2_1) and (n2_1 or n2_1)))) then
    nl = {}
else
    nF = {}
end
nj = { core = nil, input = nil, auraMouse = false }
n1 = {
    Unloaded = false,
    Flags = {
        AutoRoll = false,
        AutoEquipBest = false,
        UpgradeLuck = false,
        UpgradeDamage = false,
        KillAura = false,
        NoReload = false,
        RapidFire = false,
        MobEsp = false
    }
}
nZ = fn96
nH = fn16
nP = fn734
nq = fn166
nM = fn854
nk = fn751
nC = function(aJ)
    local o1 = nP(aJ, "ammo")
    if not o1 or nB[aJ] then
        return
    end
    nB[aJ] = n_(o1:GetPropertyChangedSignal("Value"), function()
        local oX = ny
        local o0 = if oX then 1 else 0
        local oZ = 3767 * o0 + 1855 * (1 - o0)
        local o_ = 2879 * o0 + 2585 * (1 - o0)
        if not ((oZ * 3686 + o_ * 1767 + oZ * o_) % 16777213 == 13040335) then
            oX = n1.Unloaded
        end
        if not oX then
            oX = not n1.Flags.NoReload
        end
        if oX then
            return
        end
        nk(aJ)
    end)
end
nv = fn523
nu = fn958
nT = fn619
nr = fn450
nL = fn205
n0 = fn492
nz = fn335
nE = fn920
no = fn763
n1.Roll = fn184
n1.EquipBest = function()
    local qu, qv
    local qw = nZ()
    qv, qu = no()
    if not (qw and qv) then
        return
    end
    local qx_1 = nY[qv]
    local qy = qx_1 and qx_1.itemSubtype
    local qx_2 = qy
    if qy then
        qy = qw.equippedExaltedWeapons
    end
    if qy then
        qy = qw.equippedExaltedWeapons[qx_2]
    end
    local qw_1 = qy
    if qw_1 and qw_1.weaponName == qv and qw_1.exaltedWeaponId == qu then
        return
    end
    pcall(function()
        nG.Equip:InvokeServer(qv, qu)
    end)
end
ns = function(cI)
    local qD = nZ()
    if not qD then
        return
    end
    local qE = nU.upgradeTracks[cI]
    local qF = qD[cI .. "Level"]
    local qG = qE and type(qF) == "number"
    if not qG or qE.maxLevel <= qF then
        return
    end
    local qE_1 = nU.getUpgradePrice(cI, qF + 1, nU.isTutorialFree(qD, cI), LocalPlayer)
    local qF_1 = type(qE_1) ~= "number" or qD.cash < qE_1
    if qF_1 then
        return
    end
    pcall(function()
        nG.TrackUpgrade:InvokeServer(cI)
    end)
end
n1.UpgradeLuck = fn118
n1.UpgradeDamage = fn317
nX = fn866
nh = fn164
n1.KillAura = function()
    local qY
    if not nX() then
        return
    end
    local qZ = nH()
    local q_ = not qZ or not qZ:GetAttribute("ready")
    if q_ then
        nh()
        return
    end
    nv(qZ)
    local q__1 = LocalPlayer.Character
    local q0 = q__1 and q__1:FindFirstChild("HumanoidRootPart")
    local q1 = q__1
    if q1 then
        q1 = q__1:FindFirstChildOfClass("Humanoid")
    end
    local q__2 = q0
    local q0_1 = q1
    if q__2 then
        q__2 = q0_1
    end
    if q__2 then
        q__2 = q0_1.Health > 0
    end
    if not q__2 then
        return
    end
    local q__3 = nY[qZ.Name]
    if (q__3 and q__3.itemSubtype) == "melee" then
        if not nj.auraMouse then
            nj.auraMouse = true
            task.spawn(function()
                nj.input.isMouseDown = true
                pcall(nj.input.onMouseDown)
                if nj.auraMouse then
                    nj.input.isMouseDown = false
                    nj.auraMouse = false
                end
            end)
        end
        return
    end
    nh()
    local q__5 = nP(qZ, "ammo")
    if not n1.Flags.NoReload and q__5 and q__5.Value <= 0 then
        return
    end
    local q__6 = q0.Position
    local q0_4 = qZ:GetAttribute("range") or 250
    qY = nz(q__6, q0_4)
    if not qY then
        return
    end
    local q__7 = qY.Parent
    pcall(function()
        nj.input.fireBullet(n1.Flags.NoReload, nil, nil, nil, nil, CFrame.new(qY.Position))
    end)
    local q0_5 = q__7 and nT(q__7)
    if q0_5 then
        nu(q__7)
    end
    if n1.Flags.NoReload then
        nk(qZ)
    end
end
nm = fn276
nV = fn892
nI = fn240
nn = fn533
nQ = fn918
n1.UpdateEsp = function()
    local rr, rs
    if not n1.Flags.MobEsp then
        nm()
        return
    end
    local Character = LocalPlayer.Character
    local ru = Character and Character:FindFirstChild("HumanoidRootPart")
    rr = {}
    rs = ru
    n0(function(ej, ek)
        rr[ej] = true
        if not nl[ej] then
            nQ(ej, ek)
        end
        local rk = nl[ej]
        if rk then
            rk.root = ek
            if rk.highlight then
                rk.highlight.Adornee = ej
            end
            if rk.gui then
                rk.gui.Adornee = ek
                local rl_1 = rs and (ek.Position - rs.Position).Magnitude or 0
                nn(rk.gui, ej, rl_1)
            end
        end
    end)
    for k, v in nl do
        if not rr[k] then
            if v.gui then
                v.gui:Destroy()
            end
            if v.highlight then
                v.highlight:Destroy()
            end
            nl[k] = nil
        end
    end
end
n1.Unload = fn307
getgenv()[nJ] = n1
task.spawn(worker)
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
local function n2_2()
    local Unload
    local Library
    local e7 = "https://tempohub.shop"
    local e5 = "https://discord.gg/K7Qxnxkk46"
    local HttpService = game:GetService("HttpService")
    local e4 = "Zone Defense RNG"
    local e6 = "https://discord.gg/K7Qxnxkk46"
    local UserInputService = game:GetService("UserInputService")
    local TeleportService = game:GetService("TeleportService")
    Library = getgenv().Library
    local ThemeManager = getgenv().ThemeManager
    local SaveManager = getgenv().SaveManager
    local Toggles = Library.Toggles
    local Options = Library.Options
    Unload = n1.Unload
    n1.Unload = function()
        if not Library.Unloaded then
            Library:Unload()
        else
            Unload()
        end
    end
    Library:OnUnload(Unload)
    local function fi(fj, fk)
        if setclipboard then
            setclipboard(fj)
        elseif toclipboard then
            toclipboard(fj)
        end
        Library:Notify(fk)
    end
    local function onDiscord()
        fi(e5, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = e5, Copyable = true }, "|", e4 },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(true, { Color = Color3.fromRGB(242, 154, 196), Radius = 24, Transparency = 0.3 })
    local fr = {
        [1] = Window:AddTab("Info", "info"),
        [2] = Window:AddTab("Main", "gamepad-2"),
        [3] = Window:AddTab("Player", "person-standing"),
        [4] = Window:AddTab("Settings", "settings")
    }
    local fs = fr[2]:AddSubTab("Weapons", "swords")
    local ft = fr[2]:AddSubTab("Combat", "crosshair")
    local function fu(fv)
        local DiscordGroup = fv:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    fu(fs)
    fu(ft)
    fu(fr[3])
    fu(fr[4])
    local function fy(fz, fA)
        Toggles[fz]:OnChanged(function(fC)
            n1.Flags[fA] = fC == true
        end)
    end
    local RollingGroup = fs:AddLeftGroupbox("Rolling", "dices")
    RollingGroup:AddToggle("AutoRoll", { Text = "Auto Roll Weapon", Default = false })
    RollingGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best Weapon", Default = false })
    local UpgradesGroup = fs:AddRightGroupbox("Upgrades", "trending-up")
    UpgradesGroup:AddToggle("UpgradeLuck", { Text = "Upgrade Weapon Luck", Default = false })
    UpgradesGroup:AddToggle("UpgradeDamage", { Text = "Upgrade Weapon Damage", Default = false })
    local CombatGroup = ft:AddLeftGroupbox("Combat", "swords")
    CombatGroup:AddToggle("KillAura", { Text = "Kill Aura", Default = false })
    CombatGroup:AddToggle("NoReload", { Text = "No Reload", Default = false })
    CombatGroup:AddToggle("RapidFire", { Text = "Rapid Fire", Default = false })
    local VisualsGroup = ft:AddRightGroupbox("Visuals", "eye")
    VisualsGroup:AddToggle("MobEsp", { Text = "Mob ESP", Default = false })
    fy("AutoRoll", "AutoRoll")
    fy("AutoEquipBest", "AutoEquipBest")
    fy("UpgradeLuck", "UpgradeLuck")
    fy("UpgradeDamage", "UpgradeDamage")
    fy("NoReload", "NoReload")
    fy("RapidFire", "RapidFire")
    Toggles.MobEsp:OnChanged(function(fK)
        n1.Flags.MobEsp = fK == true
        if not fK then
            nm()
        end
    end)
    Toggles.KillAura:OnChanged(function(fO)
        n1.Flags.KillAura = fO == true
        if not fO then
            nh()
        end
    end)
    local function fS()
        local sX
        local sZ
        local sT
        local sP
        local sW
        local sS
        sP = nil
        sS = nil
        sT = nil
        sW = nil
        sX = nil
        sZ = nil
        local sQ, sR, Label3, Label2, sY, Label
        sP = function(fU, fV)
            return string.format('<font color="%s">%s</font>', fV, fU)
        end
        sR = function(fX, fY, fZ)
            return string.format("<b>%s</b> %s %s", fX, sP("-", "#5a6070"), sP(fY, fZ))
        end
        local s0 = "#8b93a3"
        sZ = "#7fd47f"
        sW = "#e8a34d"
        sS = "#e05a5a"
        local function s2()
            local r0 = hookfunction ~= nil
            local r1 = hookmetamethod ~= nil
            local r2 = getrawmetatable ~= nil
            local r3 = setrawmetatable ~= nil
            local r4 = getgc ~= nil
            local r5 = getgenv ~= nil
            local r6 = getreg ~= nil
            local r7 = getconnections ~= nil
            local r8 = firesignal ~= nil
            local r9 = getcallbackvalue ~= nil
            local sa = setclipboard ~= nil
            local sb = getcustomasset ~= nil
            local sc = getnamecallmethod ~= nil
            local sd = isexecutorclosure ~= nil
            local se = fireproximityprompt ~= nil
            local sf = firetouchinterest ~= nil
            local sg = WebSocket ~= nil
            local sh = readfile ~= nil
            local si = writefile ~= nil
            local sk = (request or http_request) ~= nil
            local sm = (debug and debug.getupvalues) ~= nil
            local so = (debug and debug.setupvalue) ~= nil
            local sp = 0
            local sq = { r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, sa, sb, sc, sd, se, sf, sg, sh, si, sk, sm, so }
            for i, v in ipairs(sq) do
                if v then
                    sp += 1
                end
            end
            local r0_1 = sp / #sq
            if r0_1 >= 0.9 then
                return sP("Full Support", sZ)
            elseif r0_1 >= 0.6 then
                return sP("Half Support", sW)
            else
                return sP("Low Support", sS)
            end
        end
        sT = "Unknown"
        pcall(function()
            local sC_1
            local sB_1
            if identifyexecutor then
                sC_1, sB_1 = identifyexecutor()
                local sD = sC_1 ~= ""
                local sE = type(sC_1) == "string" and sD
                if sE then
                    local sD_1 = type(sB_1) == "string" and sB_1 ~= "" and sC_1 .. " " .. sB_1
                    sT = sD_1 or sC_1
                end
            end
        end)
        local s3 = s2()
        sX = os.clock()
        sQ = function()
            local sJ = math.floor(os.clock() - sX)
            if sJ < 60 then
                return sJ .. "s"
            elseif sJ < 3600 then
                return string.format("%dm %ds", math.floor((sJ) / (60)), sJ % 60)
            else
                return string.format("%dh %dm", math.floor((sJ) / (3600)), math.floor((sJ % 3600) / (60)))
            end
        end
        local UserGroup = fr[1]:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(sR("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, sZ), true)
        UserGroup:AddLabel(sR("UserId", tostring(LocalPlayer.UserId), "#6ec1ff"), true)
        UserGroup:AddLabel(sR("Executor", sT .. "  " .. s3, sZ), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(sR("Session", sQ(), sW), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                fi(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                fi("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = fr[1]:AddRightGroupbox("Session", "signal")
        SessionGroup:AddDivider("Server")
        SessionGroup:AddLabel(sR("Game", e4, "#6ec1ff"), true)
        Label2 = SessionGroup:AddLabel(sR("Players", "0/0", sZ), true)
        sY = tostring(game.JobId)
        local s1 = #sY > 18 and string.sub(sY, 1, 18) .. "..."
        local s3_1 = s1 or sY
        SessionGroup:AddLabel(sR("Job", s3_1, s0), true)
        Label = SessionGroup:AddLabel(sR("Ping", "0 ms", sW), true)
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
                fi(sY, "Copied Job ID")
            end
        })
        task.spawn(function()
            local sM_1
            local sL_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(sR("Session", sQ(), sW))
                Label2:SetText(sR("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), sZ))
                sL_1, sM_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local sL_2 = sL_1 and sM_1 .. " ms" or "n/a"
                Label:SetText(sR("Ping", sL_2, sW))
            end
        end)
        local SocialsGroup = fr[1]:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                fi(e6, "Copied Rscripts profile to clipboard")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                fi(e7, "Copied website link")
            end
        })
    end
    fS()
    local function ha()
        local hc
        local hd
        local hb
        local he
        hb = {}
        hd = {}
        he = {}
        hc = {}
        local function hf()
            for k, v in hb do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(hb)
        end
        local function hj()
            for k, v in hc do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(hc)
        end
        local function hn()
            for k, v in hd do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(hd)
        end
        local function hr()
            for k, v in he do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(he)
        end
        local function hv(hw)
            if not hw:IsA("ProximityPrompt") then
                return
            end
            if he[hw] == nil then
                he[hw] = {
                    HoldDuration = hw.HoldDuration,
                    MaxActivationDistance = hw.MaxActivationDistance,
                    RequiresLineOfSight = hw.RequiresLineOfSight
                }
            end
            hw.HoldDuration = 0
            hw.MaxActivationDistance = 50
            hw.RequiresLineOfSight = false
        end
        local MovementGroup = fr[3]:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", {
            Text = "NoClip",
            Default = false,
            Callback = function(hA)
                if not hA then
                    hf()
                end
            end
        })
        MovementGroup:AddToggle("InstantProximityPrompt", {
            Text = "Instant ProximityPrompt",
            Default = false,
            Callback = function(hC)
                if hC then
                    for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                        hv(v)
                    end
                else
                    hr()
                end
            end
        })
        local FlyGroup = fr[3]:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        local function hL()
            local Character = LocalPlayer.Character
            local tN = Character and Character:FindFirstChildOfClass("Humanoid")
            return tN
        end
        n_(RunService.Stepped, function()
            if Library.Unloaded then
                return
            end
            if Toggles.NoClip.Value then
                local Character = LocalPlayer.Character
                if Character then
                    for i, descendant in Character:GetDescendants() do
                        local t1 = if descendant:IsA("BasePart") then 1 else 0
                        if t1 == 1 then
                            if hb[descendant] == nil then
                                hb[descendant] = descendant.CanCollide
                            end
                            descendant.CanCollide = false
                        end
                    end
                end
            end
        end)
        n_(UserInputService.JumpRequest, function()
            if Library.Unloaded or not Toggles.InfJump.Value then
                return
            end
            local t2_1 = hL()
            if t2_1 then
                t2_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        n_(Workspace.DescendantAdded, function(ic)
            if Toggles.InstantProximityPrompt.Value then
                hv(ic)
            end
        end)
        n_(RunService.RenderStepped, function(ih)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local t9 = Character and Character:FindFirstChildOfClass("Humanoid")
            local ua = Character
            if ua then
                ua = Character:FindFirstChild("HumanoidRootPart")
            end
            local t8_1 = ua
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and t9 then
                if hc[t9] == nil then
                    hc[t9] = t9.WalkSpeed
                end
                t9.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and t8_1 and t9 and CurrentCamera then
                if hd[t9] == nil then
                    hd[t9] = t9.PlatformStand
                end
                t9.PlatformStand = true
                local ua_4 = Vector3.zero
                if not UserInputService:GetFocusedTextBox() then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        ua_4 += CurrentCamera.CFrame.LookVector
                    end
                    local ug = if UserInputService:IsKeyDown(Enum.KeyCode.S) then 1 else 0
                    if ug == 1 then
                        ua_4 -= CurrentCamera.CFrame.LookVector
                    end
                    local ug_1 = if UserInputService:IsKeyDown(Enum.KeyCode.A) then 1 else 0
                    if ug_1 == 1 then
                        ua_4 -= CurrentCamera.CFrame.RightVector
                    end
                    local ug_2 = if UserInputService:IsKeyDown(Enum.KeyCode.D) then 1 else 0
                    if ug_2 == 1 then
                        ua_4 += CurrentCamera.CFrame.RightVector
                    end
                    local ug_3 = if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
                    if ug_3 == 1 then
                        ua_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        ua_4 -= Vector3.new(0, 1, 0)
                    end
                end
                t8_1.AssemblyLinearVelocity = Vector3.zero
                if ua_4.Magnitude > 0 then
                    t8_1.CFrame = t8_1.CFrame + ua_4.Unit * Options.FlySpeed.Value * ih
                end
            end
        end)
        Toggles.Fly:OnChanged(function(iz)
            if not iz then
                hn()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function(iB)
            if not iB then
                hj()
            end
        end)
        Library:OnUnload(function()
            hf()
            hj()
            hn()
            hr()
        end)
    end
    ha()
    local function iH()
        local jm
        local iM
        local GuiService = game:GetService("GuiService")
        local Lighting = game:GetService("Lighting")
        iM = {}
        local VirtualUser = game:GetService("VirtualUser")
        local CoreGui = game:GetService("CoreGui")
        local iN
        local iP = 0
        local iO = false
        local iQ = os.clock()
        local MenuGroup = fr[4]:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        local Label = MenuGroup:AddLabel("AFK triggers: 0")
        local function iU()
            local CurrentCamera = Workspace.CurrentCamera
            if not CurrentCamera then
                return
            end
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero, CurrentCamera.CFrame)
            iP += 1
            iQ = os.clock()
            Label:SetText("AFK triggers: " .. iP)
        end
        local function onAntiGameplayPause(i2)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not i2)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not i2
                end
            end)
            if i2 then
                pcall(function()
                    if sethiddenproperty then
                        sethiddenproperty(LocalPlayer, "GameplayPaused", false)
                    else
                        LocalPlayer.GameplayPaused = false
                    end
                end)
            end
        end
        local function jd()
            for k, v in iM do
                local ut = k
                local uv = v
                if ut.Parent then
                    pcall(function()
                        ut.Enabled = uv
                    end)
                end
            end
            table.clear(iM)
            if iN then
                pcall(function()
                    settings().Rendering.QualityLevel = iN.Quality
                end)
                Lighting.GlobalShadows = iN.Shadows
                Lighting.FogEnd = iN.Fog
                iN = nil
            end
        end
        jm = { ParticleEmitter = true, Trail = true, Smoke = true, Fire = true, Sparkles = true, Beam = true }
        local function jn(jo)
            if jm[jo.ClassName] then
                if iM[jo] == nil then
                    iM[jo] = jo.Enabled
                end
                jo.Enabled = false
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true, Callback = onAntiGameplayPause })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(jr)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not jr)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(jw)
                if jw then
                    if not iN then
                        iN = {
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
                    for i, descendant in Workspace:GetDescendants() do
                        pcall(jn, descendant)
                    end
                else
                    jd()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        local ScriptGroup = fr[4]:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        n_(LocalPlayer.Idled, function()
            if Toggles.AntiAfk.Value then
                pcall(iU)
            end
        end)
        n_(Workspace.DescendantAdded, function(jM)
            if Toggles.FpsBoost.Value then
                jn(jM)
            end
        end)
        local function jP(jQ)
            if iO or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            iO = true
            local uK_1 = pcall(function()
                if jQ then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not uK_1 then
                iO = false
                if not jQ then
                    jP(true)
                end
            end
        end
        n_(TeleportService.TeleportInitFailed, function(j2)
            if j2 == LocalPlayer and iO then
                iO = false
                task.delay(3, function()
                    jP(true)
                end)
            end
        end)
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local uQ = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            if Library.Unloaded or not uQ then
                return
            end
            n_(uQ.ChildAdded, function(kd)
                if kd.Name == "ErrorPrompt" then
                    jP(false)
                end
            end)
        end)
        task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    onAntiGameplayPause(true)
                end
                local uT = Toggles.AntiAfk.Value and os.clock() - iQ >= 60
                if uT then
                    pcall(iU)
                end
                task.wait(1)
            end
        end)
        Library:OnUnload(function()
            onAntiGameplayPause(false)
            jd()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    iH()
    local function kq()
        local vM, vN, vO, vP
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("TempoHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(fr[4])
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/ZoneDefenseRNG")
        local vQ = SaveManager:BuildConfigSection(fr[4])
        vN = function(ky, kz)
            local uW_1 = (ky == "Toggle" and Toggles or Options)[kz]
            local uV_2 = type(uW_1) == "table" and uW_1.Type == ky
            return uV_2 and uW_1 or nil
        end
        vP = function(kI, kJ)
            local Type = kJ.Type
            if Type == "Toggle" then
                return { idx = kI, type = "Toggle", value = kJ.Value == true }
            elseif Type == "Slider" then
                return { idx = kI, type = "Slider", value = tostring(kJ.Value) }
            elseif Type == "Dropdown" then
                return { idx = kI, type = "Dropdown", multi = kJ.Multi == true, value = kJ.Value }
            elseif Type == "Input" then
                local u2 = kJ.Value
                local u6 = if u2 then 1 else 0
                local u4 = 3064 * u6 + 3187 * (1 - u6)
                local u5 = 409 * u6 + 953 * (1 - u6)
                if not ((u4 * 2449 + u5 * 2313 + u4 * u5) % 16777213 == 9702929) then
                    u2 = ""
                end
                return { idx = kI, type = "Input", text = tostring(u2) }
            elseif Type == "ColorPicker" then
                return { idx = kI, type = "ColorPicker", value = kJ.Value:ToHex(), transparency = kJ.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = kI,
                    type = "KeyPicker",
                    mode = kJ.Mode,
                    key = kJ.Value,
                    modifiers = kJ.Modifiers,
                    toggled = kJ.Toggled
                }
            else
                return nil
            end
        end
        vO = function()
            local vb = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local vc = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if vc then
                        local vc_1 = vP(k, v)
                        if vc_1 then
                            vb[#vb + 1] = vc_1
                        end
                    end
                end
            end
            table.sort(vb, function(kT, kU)
                if kT.type ~= kU.type then
                    return kT.type < kU.type
                end
                return kT.idx < kU.idx
            end)
            return { objects = vb }
        end
        vM = function(kW)
            local vs
            vs = nil
            local vt = type(kW) ~= "table" or type(kW.idx) ~= "string" or type(kW.type) ~= "string" or SaveManager.Ignore[kW.idx]
            if vt then
                return false
            end
            vs = vN(kW.type, kW.idx)
            if not vs then
                return false
            end
            local vt_1 = pcall(function()
                if kW.type == "Input" then
                    if type(kW.text) ~= "string" then
                        return
                    end
                    vs:SetValue(kW.text)
                elseif kW.type == "ColorPicker" then
                    vs:SetValueRGB(Color3.fromHex(kW.value), kW.transparency)
                elseif kW.type == "KeyPicker" then
                    vs:SetValue({ kW.key, kW.mode, kW.modifiers })
                    if kW.mode == "Toggle" and kW.toggled ~= nil then
                        vs.Toggled = kW.toggled
                        vs:Update()
                    end
                else
                    vs:SetValue(kW.value)
                end
            end)
            return vt_1
        end
        vQ:AddDivider()
        vQ:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        vQ:AddButton("Export Config to Clipboard", function()
            local vw_1
            local vv_1
            vv_1, vw_1 = pcall(HttpService.JSONEncode, HttpService, vO())
            if not vv_1 then
                Library:Notify("Failed to encode the config")
                return
            end
            local vv_2 = setclipboard or toclipboard
            local vv_3 = type(vv_2) ~= "function" or not pcall(vv_2, vw_1)
            if vv_3 then
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Config copied to clipboard", 6)
        end)
        vQ:AddButton("Import Config from Clipboard Text", function()
            local vE_1
            local vC = Options.SaveManager_ImportSource.Value or ""
            local vC_1
            local vD = tostring(vC):match("^%s*(.-)%s*$")
            if vD == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            vC_1, vE_1 = pcall(HttpService.JSONDecode, HttpService, vD)
            local vD_1 = not vC_1 or type(vE_1) ~= "table" or type(vE_1.objects) ~= "table"
            if vD_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            local vC_2 = 0
            for i, v in ipairs(vE_1.objects) do
                if vM(v) then
                    vC_2 += 1
                end
            end
            if vC_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local vE_2 = vC_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(vC_2, vE_2), 6)
        end)
        ThemeManager:LoadDefault()
        SaveManager:LoadAutoloadConfig()
        n1.Flags.AutoRoll = Toggles.AutoRoll.Value
        n1.Flags.AutoEquipBest = Toggles.AutoEquipBest.Value
        n1.Flags.UpgradeLuck = Toggles.UpgradeLuck.Value
        n1.Flags.UpgradeDamage = Toggles.UpgradeDamage.Value
        n1.Flags.KillAura = Toggles.KillAura.Value
        n1.Flags.NoReload = Toggles.NoReload.Value
        n1.Flags.RapidFire = Toggles.RapidFire.Value
        n1.Flags.MobEsp = Toggles.MobEsp.Value
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    kq()
end
n2_2()
end)(...)

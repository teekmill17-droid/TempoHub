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
getgenv().TempoHoodSubtitle = "+1 JUMP CRUNCHY ASMR ESCAPE!"
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
local xi_9, DonationsGroup, FlyGroup, xi_25, RunService
local ov
local pc
local n9
local HttpService
local MonetizationConfig
local oB
local SaveManager
local of
local VirtualUser
local nX
local oH
local om
local o5
local InventoryRemote
local nK
local ou
local pb
local oT
local nQ
local oA
local ph
local oe
local oZ
local oG
local pn
local ol
local o4
local n1
local oM
local ot
local pa
local connection2
local oS
local nP
local LocalPlayer
local pg
local AuraRequest
local oY
local nV
local Label
local RebirthRequest
local o3
local n0
local oL
local oq
local Toggles
local nO
local oy
local pf
local oc
local oX
local AurasConfig
local pl
local oi
local Options
local n_
local Workspace
local op
local o8
local n5
local oQ
local Library
local ox
local pe
local ob
local oW
local nT
local oD
local pk
local oh
local o1
local nZ
local oJ
local oo
local o7
local n4
local oP
local nM
local ow
local pd
local oa
local oV
local nS
local oC
local pj
local og
local Config
local oI
local connection
local UserInputService
local n3
local oO
local nL
function fns.fn11()
    local s_ = tonumber(LocalPlayer:GetAttribute("JumpUpgradeUnlockedTier")) or tonumber(LocalPlayer:GetAttribute("JumpUpgradeTier"))
    local s0 = s_
    local s6 = if s0 then 1 else 0
    local s4 = 2636 * s6 + 3100 * (1 - s6)
    local s5 = 2099 * s6 + 3473 * (1 - s6)
    if not ((s4 * 3149 + s5 * 62 + s4 * s5) % 16777213 == 13963866) then
        s0 = 0
    end
    local s__1 = s0
    local s0_1 = oh()
    local s1 = s__1 + 1
    local s2 = #nL
    local s9 = s1
    while s9 <= s2 do
        local ta = s9
        local s1_1 = Library.Unloaded or not ot("AutoBuySteps")
        if s1_1 then
            return
        end
        local s1_2 = nL[ta]
        if type(s1_2) ~= "table" then
            break
        end
        local s2_1 = tonumber(s1_2.WinsRequired) or 0
        if s0_1 < s2_1 then
            break
        end
        nK(ta)
        task.wait(0.35)
        s0_1 = oh()
        local s1_4 = tonumber(LocalPlayer:GetAttribute("JumpUpgradeUnlockedTier")) or tonumber(LocalPlayer:GetAttribute("JumpUpgradeTier"))
        s9 += 1
    end
end
function fns.worker2()
    while not Library.Unloaded do
        if ot("AutoRebirth") then
            pcall(oo)
        end
        task.wait(nX("RebirthDelay", 1))
    end
end
function fns.fn42()
    local tc = (tonumber(LocalPlayer:GetAttribute("JumpUpgradeUnlockedTier")))
    local ti = if tc then 1 else 0
    local tg = 3570 * ti + 3080 * (1 - ti)
    local th = 1183 * ti + 1719 * (1 - ti)
    if not ((tg * 3507 + th * 1247 + tg * th) % 16777213 == 1441288) then
        tc = 0
    end
    local td = tc
    local tc_1 = tonumber(LocalPlayer:GetAttribute("JumpUpgradeTier")) or 0
    if td <= 0 then
        return
    end
    if tc_1 == td then
        return
    end
    nK(td)
end
function fns.onInputBegan()
    pe = tick()
end
function fns.fn61(ao, ap)
    return string.format('<font color="%s">%s</font>', ap, ao)
end
function fns.worker7()
    while not Library.Unloaded do
        if ot("AutoJump") then
            pcall(oQ)
        end
        task.wait(nX("JumpDelay", 0.2))
    end
end
function fns.worker()
    local va_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local u9 = math.floor(os.clock() - og)
        if u9 < 60 then
            va_1 = u9 .. "s"
        elseif u9 < 3600 then
            va_1 = string.format("%dm %ds", math.floor((u9) / (60)), u9 % 60)
        else
            va_1 = string.format("%dh %dm", math.floor((u9) / (3600)), math.floor((u9 % 3600) / (60)))
        end
        Label:SetText(ol("Session time", va_1, nZ))
    end
end
function fns.onCopyPayPalLink()
    oX(o4, "Copied PayPal link")
end
function fns.fn101()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    o5 = tick()
end
function fns.fn105(gx)
    local DiscordGroup = gx:AddLeftGroupbox("Discord", nil, true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = oG })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = oG })
end
function fns.fn117()
    local wo = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local wp = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if wp then
                local wp_1 = ow(k, v)
                if wp_1 then
                    wo[#wo + 1] = wp_1
                end
            end
        end
    end
    table.sort(wo, function(i4, i5)
        if i4.type ~= i5.type then
            return i4.type < i5.type
        end
        return i4.idx < i5.idx
    end)
    return { objects = wo }
end
function fns.fn123(aO)
    local qr = Toggles[aO]
    return qr ~= nil and qr.Value == true
end
function fns.onRenderStepped(hX)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local vG_1 = oZ()
        if vG_1 then
            vG_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local vG_3 = oH()
        local vH = oZ()
        oD = Workspace.CurrentCamera or oD
        if vG_3 and vH and oD then
            vH.PlatformStand = true
            local vH_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                vH_1 = vH_1 + oD.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                vH_1 = vH_1 - oD.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                vH_1 = vH_1 - oD.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                vH_1 = vH_1 + oD.CFrame.RightVector
            end
            local vQ = if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
            if vQ == 1 then
                vH_1 = vH_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                vH_1 = vH_1 - Vector3.new(0, 1, 0)
            end
            vG_3.Velocity = Vector3.zero
            if vH_1.Magnitude > 0 then
                vG_3.CFrame = vG_3.CFrame + vH_1.Unit * Options.FlySpeed.Value * hX
            end
        end
    end
end
function fns.fn147()
    local Character = LocalPlayer.Character
    local qE = Character and Character:FindFirstChild("HumanoidRootPart")
    return qE
end
function fns.fn160()
    local uS = tonumber(LocalPlayer:GetAttribute("RebirthLevelRequirement"))
    if uS then
        return uS
    end
    local uS_1 = oc()
    local uT = uS_1 + 1
    local uU = tonumber(LocalPlayer:GetAttribute("RebirthRequirementOffset")) or 0
    local uV = uT + uU
    local uT_1 = Config.RebirthLevelRequirements or {}
    if uT_1[uV] then
        return uT_1[uV]
    end
    local uU_1 = uT_1[#uT_1] or Config.FirstRebirthLevelRequirement or Config.RebirthBaseLevelRequirement
    local u_ = if uU_1 then 1 else 0
    local uY = 2762 * u_ + 2925 * (1 - u_)
    local uZ = 2743 * u_ + 2344 * (1 - u_)
    if not ((uY * 1811 + uZ * 2104 + uY * uZ) % 16777213 == 1572207) then
        uU_1 = 25
    end
    local uT_3 = uU_1
    local uW = Config.RebirthLevelRequirementStep or Config.RebirthBaseLevelRequirement
    local u__1 = if uW then 1 else 0
    local uY_1 = 3695 * u__1 + 3813 * (1 - u__1)
    local uZ_1 = 491 * u__1 + 815 * (1 - u__1)
    if not ((uY_1 * 353 + uZ_1 * 427 + uY_1 * uZ_1) % 16777213 == 3328237) then
        uW = 25
    end
    local uU_3 = uW
    return uT_3 + uU_3 * math.max(0, uV - math.max(#uT_1, 1))
end
function fns.fn170(iQ, iR)
    local Type = iR.Type
    if Type == "Toggle" then
        return { idx = iQ, type = "Toggle", value = iR.Value == true }
    elseif Type == "Slider" then
        return { idx = iQ, type = "Slider", value = tostring(iR.Value) }
    elseif Type == "Dropdown" then
        return { idx = iQ, type = "Dropdown", multi = iR.Multi == true, value = iR.Value }
    elseif Type == "Input" then
        local wf = iR.Value or ""
        return { idx = iQ, type = "Input", text = tostring(wf) }
    elseif Type == "ColorPicker" then
        return { idx = iQ, type = "ColorPicker", value = iR.Value:ToHex(), transparency = iR.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = iQ,
            type = "KeyPicker",
            mode = iR.Mode,
            key = iR.Value,
            modifiers = iR.Modifiers,
            toggled = iR.Toggled
        }
    else
        return nil
    end
end
function fns.fn212(dy)
    local sn = os.clock()
    local sp = sn + (dy or 3)
    while true do
        local sn_1 = LocalPlayer:GetAttribute("WinPadClaimLocked") == true and os.clock() < sp and not Library.Unloaded
        if sn_1 then
            task.wait(0.05)
            continue
        end
        break
    end
end
function fns.fn219(ez)
    if type(ez) ~= "string" then
        return nil
    end
    local ById = AurasConfig.ById
    local tk = type(ById) == "table" and type(ById[ez]) == "table"
    if tk then
        return ById[ez]
    end
    local tk_1 = AurasConfig.Auras or {}
    for k, v in pairs(tk_1) do
        local tj_2 = type(v) == "table" and v.Id == ez
        if tj_2 then
            return v
        end
    end
    return nil
end
function fns.onUnload()
    Library:Unload()
end
function fns.fn297()
    local Map = Workspace:FindFirstChild("Map")
    local rH = Map and Map:FindFirstChild("Trampolines")
    return rH
end
function fns.fn303(dE)
    local ss_1
    local sr_1
    oM(3)
    ss_1, sr_1 = nT(dE)
    if not ss_1 or not sr_1 then
        return false
    end
    local st_1 = oH()
    if not st_1 then
        return false
    end
    ob(sr_1.Position, 3)
    ou(CFrame.new(sr_1.Position + Vector3.new(0, 3, 0)))
    task.wait(0.05)
    nM(ss_1)
    task.wait(0.15)
    return true
end
function fns.worker6()
    while not Library.Unloaded do
        if ot("AutoWins") then
            pcall(pd)
        else
            task.wait(0.25)
        end
    end
end
function fns.fn367()
    local t9 = oa("BoxEgg")
    if t9 == "Best Affordable" or t9 == nil then
        local ua_1 = oh()
        local ub_1 = nil
        for i, v in ipairs(oO) do
            local uc = oT[v]
            if uc and ua_1 >= uc.Price then
                ub_1 = v
            end
        end
        return ub_1
    end
    for k, v in pairs(oT) do
        if v.Display == t9 or k == t9 then
            return k
        end
    end
    return nil
end
function fns.onCopyJoinScript_JobID()
    local gO = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, oA)
    oX(gO, "Copied join script to clipboard")
end
function fns.onCopyEthereumAddress()
    oX(pk, "Copied Ethereum address")
end
function fns.fn446()
    if not Toggles.Fly.Value then
        local vj = oZ()
        if vj then
            vj.PlatformStand = false
        end
    end
end
function fns.fn450(aT)
    local qu = Options[aT]
    return qu and qu.Value or nil
end
function fns.fn460()
    pc(Toggles.AntiGameplayPause.Value)
end
function fns.onCopyLitecoinAddress()
    oX(nS, "Copied Litecoin address")
end
function fns.fn485(bc)
    local Character = LocalPlayer.Character
    if not Character then
        return
    end
    if Character.PrimaryPart then
        Character:PivotTo(bc)
    else
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = bc
        end
    end
end
function fns.fn495()
    pcall(function()
        connection:Disconnect()
    end)
    pcall(function()
        connection2:Disconnect()
    end)
    pc(false)
    om(false)
    local v2 = oZ()
    if v2 then
        v2.PlatformStand = false
        v2.WalkSpeed = 16
    end
end
function fns.fn509()
    if n5() < pf() then
        return
    end
    pcall(function()
        RebirthRequest:FireServer("rebirth")
    end)
end
function fns.worker4()
    while not Library.Unloaded do
        if ot("AutoRollAuras") then
            pcall(o3)
        end
        task.wait(nX("AuraRollDelay", o1))
    end
end
function fns.onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local vB_1 = oZ()
        if vB_1 then
            vB_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
function fns.fn528(bx)
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local qQ = leaderstats and leaderstats:FindFirstChild(bx)
    local qP_1 = qQ
    if qQ then
        local qR = tonumber(qP_1.Value) or 0
        qQ = qR
    end
    local qP_2 = qQ
    local qV = if qP_2 then 1 else 0
    local qT = 3687 * qV + 2357 * (1 - qV)
    local qU = 800 * qV + 982 * (1 - qV)
    if not ((qT * 354 + qU * 1392 + qT * qU) % 16777213 == 5368398) then
        qP_2 = 0
    end
    return qP_2
end
function fns.fn531()
    local sE_1
    local sD = nP()
    local sD_2
    if sD then
        op(sD)
        task.wait(nX("WinDelay", 0.35))
        return
    end
    local sJ = n3
    local sI = -1
    while true do
        if false and sJ <= 1 or true and sJ >= 1 then
            local sK = sJ
            local sD_1 = Library.Unloaded or not ot("AutoWins")
            if sD_1 then
                break
            end
            sD_2, sE_1 = nT(sK)
            if sD_2 and sE_1 then
                op(sK)
                task.wait(nX("WinDelay", 0.35))
                return
            end
            sJ += sI
            continue
        end
        task.wait(0.5)
        return
    end
    return
end
function fns.fn536(ah, ai)
    if setclipboard then
        setclipboard(ah)
    elseif toclipboard then
        toclipboard(ah)
    end
    Library:Notify(ai)
end
function fns.fn565(cI)
    if not cI then
        return nil
    end
    local rJ = (cI:FindFirstChild("trampoline_Base", true))
    local rN = if rJ then 1 else 0
    local rL = 2048 * rN + 2755 * (1 - rN)
    local rM = 3738 * rN + 3116 * (1 - rN)
    if not ((rL * 3351 + rM * 3916 + rL * rM) % 16777213 == 12379067) then
        rJ = cI:FindFirstChildWhichIsA("BasePart", true)
    end
    return rJ
end
function fns.fn569()
    local sw = oa("WinPad")
    if sw == "Best" or sw == nil then
        return nil
    end
    return tonumber(string.match(tostring(sw), "%d+"))
end
function fns.onCopyVenmoLink()
    oX(oY, "Copied Venmo link")
end
function fns.fn619()
    local qW = tonumber(LocalPlayer:GetAttribute("Level")) or 0
    return qW
end
function fns.fn640()
    local Map = Workspace:FindFirstChild("Map")
    local sN = Map and Map:FindFirstChild("Lobby")
    local sM_1 = sN
    if sN then
        sN = sM_1:FindFirstChild("UpgradeButtons")
    end
    return sN
end
function fns.onInputChanged(it)
    local UserInputType = it.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        pe = tick()
    end
end
function fns.worker3()
    while not Library.Unloaded do
        if ot("AutoEquipBestSteps") then
            pcall(nV)
        end
        if ot("AutoEquipBestPets") then
            pcall(nQ)
        end
        local w9 = ot("AutoEquipBestAura") and not ot("AutoRollAuras")
        if w9 then
            pcall(oC)
        end
        task.wait(nX("EquipDelay", 1))
    end
end
function fns.fn687(eG)
    local tv = eG and eG.Unlocked
    if type(tv) ~= "table" then
        return nil
    end
    local tv_1 = nil
    local tx = -1
    local ty = -1
    for k, v in pairs(tv) do
        if v then
            local tw_1 = o8(tostring(k))
            local tz = tw_1 and tonumber(tw_1.JumpMultiplier)
            local tA = tz or 0
            local tz_1 = tw_1
            if tz_1 then
                tz_1 = tonumber(tw_1.WinMultiplier)
            end
            local tw_2 = tz_1 or 0
            local tw_3 = tA > ty
            if not tw_3 then
                tw_3 = tA == ty and tw_2 > tx
            end
            if tw_3 then
                ty = tA
                tx = tw_2
                tv_1 = tostring(k)
            end
        end
    end
    return tv_1
end
function fns.fn694()
    local rO = pa()
    if not rO then
        return nil, nil, 0
    end
    local rP = rO:FindFirstChild("trampoline")
    local rQ = pg
    local rR = {}
    local rS = MonetizationConfig.TrampolineGamepasses
    local rW = if rS then 1 else 0
    local rU = 2632 * rW + 1756 * (1 - rW)
    local rV = 685 * rW + 163 * (1 - rW)
    if not ((rU * 943 + rV * 2853 + rU * rV) % 16777213 == 6239201) then
        rS = rR
    end
    for k, v in pairs(rS) do
        local rR_1 = type(v) == "table" and type(v.TrampolineModel) == "string" and type(v.JumpMultiplier) == "number" and type(v.Id) == "number" and of(v.Id) and v.JumpMultiplier > rQ
        if rR_1 then
            local rR_2 = rO:FindFirstChild(v.TrampolineModel)
            if rR_2 then
                rP = rR_2
                rQ = v.JumpMultiplier
            end
        end
    end
    local playtime_trampoline = rO:FindFirstChild("playtime_trampoline")
    local rO_1 = playtime_trampoline
    if rO_1 then
        local rS_1 = tonumber(LocalPlayer:GetAttribute("PlaytimeJumpMultiplier")) or 1
        rO_1 = rS_1 > rQ
    end
    if rO_1 then
        rP = playtime_trampoline
        local rO_2 = tonumber(LocalPlayer:GetAttribute("PlaytimeJumpMultiplier")) or rQ
        rQ = rO_2
    end
    return rP, oP(rP), rQ
end
function fns.fn696()
    if not Toggles.WalkSpeedEnabled.Value then
        local vl = oZ()
        if vl then
            vl.WalkSpeed = 16
        end
    end
end
local function worker8()
    while not Library.Unloaded do
        local w3 = ot("GoBestTrampoline") and not ot("AutoJump")
        if w3 then
            pcall(pl)
        end
        task.wait(1)
    end
end
local function fn710(fj)
    local Map = Workspace:FindFirstChild("Map")
    local t7 = Map and Map:FindFirstChild("Eggs")
    local t6_1 = t7
    if t7 then
        t7 = t6_1:FindFirstChild(fj)
    end
    return t7
end
local function onImportConfigFromClipboardTex()
    local wO_1
    local wM = Options.SaveManager_ImportSource.Value
    local wM_1
    local wS = if wM then 1 else 0
    local wQ = 505 * wS + 3578 * (1 - wS)
    local wR = 1912 * wS + 1776 * (1 - wS)
    if not ((wQ * 2620 + wR * 641 + wQ * wR) % 16777213 == 3514252) then
        wM = ""
    end
    local wN = tostring(wM):match("^%s*(.-)%s*$")
    if wN == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    wM_1, wO_1 = pcall(HttpService.JSONDecode, HttpService, wN)
    local wN_1 = not wM_1
    local wS_1 = if wN_1 then 1 else 0
    local wQ_1 = 876 * wS_1 + 246 * (1 - wS_1)
    local wR_1 = 2512 * wS_1 + 1360 * (1 - wS_1)
    if not ((wQ_1 * 2748 + wR_1 * 3499 + wQ_1 * wR_1) % 16777213 == 13397248) then
        wN_1 = type(wO_1) ~= "table"
    end
    if not wN_1 then
        wN_1 = type(wO_1.objects) ~= "table"
    end
    if wN_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local wM_2 = 0
    for i, v in ipairs(wO_1.objects) do
        if oW(v) then
            wM_2 += 1
        end
    end
    if wM_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local wO_2 = wM_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(wM_2, wO_2), 6)
end
local function onExportConfigToClipboard()
    local wJ_1
    local wI_1
    wI_1, wJ_1 = pcall(HttpService.JSONEncode, HttpService, oe())
    if not wI_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local wI_2 = setclipboard or toclipboard
    local wI_3 = type(wI_2) ~= "function" or not pcall(wI_2, wJ_1)
    if wI_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function fn745()
    local q__1, q__2
    local qZ_1, qZ_2
    local qY_1, qY_2
    qZ_1, qY_1, q__1 = pcall(function()
        return AuraRequest:InvokeServer("State")
    end)
    local q0 = qZ_1 and type(q__1) == "table"
    if q0 then
        return q__1
    end
    local q0_1 = qZ_1 and qY_1 == true and type(q__1) == "table"
    if q0_1 then
        return q__1
    end
    qZ_2, qY_2, q__2 = pcall(function()
        return AuraRequest:InvokeServer("List")
    end)
    local qY_3 = qZ_2 and type(q__2) == "table"
    if qY_3 then
        return q__2
    end
    return nil
end
local function fn755()
    local Map = Workspace:FindFirstChild("Map")
    local se = Map and Map:FindFirstChild("WinPads")
    return se
end
local function onRscripts()
    oX(oq, "Copied Rscripts profile to clipboard")
end
local function fn826()
    local t_ = n0()
    if not t_ then
        return
    end
    local t0 = oy(t_)
    if not t0 then
        return
    end
    local t1 = t_.Equipped or LocalPlayer:GetAttribute("AuraEquipped")
    local t__1 = t1 or ""
    local t1_1 = tostring(t__1)
    if t1_1 == t0 then
        return
    end
    oS("Equip", t0)
end
local function fn827()
    local tR = tonumber(LocalPlayer:GetAttribute("AuraLuckLevel")) or 0
    if tR >= oV then
        return
    end
    local tR_1 = tonumber(LocalPlayer:GetAttribute("AuraLuckUpgradeCost"))
    if not tR_1 then
        local tT = n0()
        local tU = tT and tonumber(tT.LuckUpgradeCost)
        local tV = tU or tonumber(AurasConfig.LuckUpgradeBaseCost)
        tR_1 = tV or 1000
    end
    if oh() < tR_1 then
        return
    end
    oS("UpgradeLuck")
end
local function fn842(aY, aZ)
    local qx = Options[aY]
    local qy = qx and tonumber(qx.Value)
    if qy then
        return qy
    end
    return aZ
end
local function fn852()
    pcall(function()
        InventoryRemote:FireServer("EquipBest")
    end)
end
local function worker10()
    while not Library.Unloaded do
        task.wait(2)
        if ot("AntiAfk") then
            local wZ = tick() - pe
            local w_ = tick() - o5
            if wZ >= 300 and w_ >= 60 then
                pcall(oJ)
            else
                if wZ < 300 and w_ >= 300 then
                    pcall(oJ)
                end
            end
        end
    end
end
local function fn933(d3)
    local sP = oi()
    if not sP then
        return nil
    end
    return sP:FindFirstChild("button" .. d3)
end
local function onCopyBitcoinAddress()
    oX(nO, "Copied Bitcoin address")
end
local function fn952()
    local r3_1
    local r2_1
    r2_1, r3_1 = oB()
    if not r3_1 then
        return false
    end
    ob(r3_1.Position, 3)
    ou(r3_1.CFrame + Vector3.new(0, 3, 0))
    return true
end
local function worker9()
    while not Library.Unloaded do
        task.wait(1)
        if ot("AntiGameplayPause") then
            pc(true)
        end
    end
end
local function fn989(dn)
    local sg = n4()
    if not sg then
        return nil, nil
    end
    local sh = sg:FindFirstChild("Win pad" .. dn)
    if not sh then
        return nil, nil
    end
    local BasePart2 = sh:FindFirstChildWhichIsA("BasePart", true)
    if BasePart2 then
        n9[dn] = BasePart2.Position
        return sh, BasePart2
    end
    local si = n9[dn]
    if si then
        ob(si, 4)
        local BasePart = sh:FindFirstChildWhichIsA("BasePart", true)
        if BasePart then
            n9[dn] = BasePart.Position
            return sh, BasePart
        end
        return sh, nil
    end
    return sh, nil
end
local function onCopyUSDTAddress()
    oX(pj, "Copied USDT address")
end
local function fn1008()
    local tJ = o7
    local tJ_1
    local tK = n0()
    local tK_1
    local tL = tK and tonumber(tK.RollCost)
    if tL then
        tJ = tonumber(tK.RollCost)
    end
    if oh() < tJ then
        return
    end
    tJ_1, tK_1 = oS("Roll")
    local tL_1 = tJ_1 and type(tK_1) == "table" and ot("AutoEquipBestAura")
    if tL_1 then
        local tJ_2 = oy(tK_1)
        local tL_2 = tJ_2
        if tL_2 then
            local tM = tK_1.Equipped or LocalPlayer:GetAttribute("AuraEquipped")
            local tK_2 = tM or ""
            tL_2 = tJ_2 ~= tostring(tK_2)
        end
        if tL_2 then
            oS("Equip", tJ_2)
        end
    end
end
local function worker5()
    while not Library.Unloaded do
        if ot("AutoBuySteps") then
            pcall(oL)
        end
        if ot("AutoBuyBoxes") then
            pcall(pn)
        end
        if ot("AutoBuyLuck") then
            pcall(n_)
        end
        task.wait(nX("ShopDelay", 0.5))
    end
end
local function fn1037()
    local Character = LocalPlayer.Character
    local qB = Character and Character:FindFirstChildOfClass("Humanoid")
    return qB
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local vq_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if vq_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn1050(iI, iJ)
    local v8_1 = (iI == "Toggle" and Toggles or Options)[iJ]
    local v7_2 = type(v8_1) == "table" and v8_1.Type == iI
    local v7_3 = v7_2 and v8_1
    local wd = if v7_3 then 1 else 0
    local wb = 3042 * wd + 1524 * (1 - wd)
    local wc = 3377 * wd + 2372 * (1 - wd)
    if not ((wb * 1345 + wc * 2102 + wb * wc) % 16777213 == 4685565) then
        v7_3 = nil
    end
    return v7_3
end
local function fn1059()
    return oI("Rebirths")
end
local function fn1062()
    return oI("Wins")
end
local function fn1070(ar, as, at)
    return string.format("<b>%s</b> %s %s", ar, ox("-", "#5a6070"), ox(as, at))
end
local function fn1085()
    local u2_1
    local u1_1
    if identifyexecutor then
        u2_1, u1_1 = identifyexecutor()
        local u3 = u2_1 ~= ""
        local u4 = type(u2_1) == "string" and u3
        if u4 then
            local u3_1 = type(u1_1) == "string" and u1_1 ~= "" and u2_1 .. " " .. u1_1
            ph = u3_1 or u2_1
        end
    end
end
local function fn1104(d7)
    local sU = n1(d7)
    if not sU then
        return false
    end
    local BasePart = sU:FindFirstChildWhichIsA("BasePart", true)
    if not BasePart then
        return false
    end
    ob(BasePart.Position, 2)
    ou(BasePart.CFrame + Vector3.new(0, 3, 0))
    task.wait(0.05)
    return nM(sU)
end
local function onCopySolanaAddress()
    oX(pb, "Copied Solana address")
end
local function fn1119()
    oX(ov, "Copied Discord invite to clipboard")
end
nK = nil
nL = nil
nM = nil
Library = nil
nO = nil
nP = nil
nQ = nil
MonetizationConfig = nil
nS = nil
nT = nil
AurasConfig = nil
nV = nil
nX = nil
Config = nil
nZ = nil
n_ = nil
n0 = nil
n1 = nil
InventoryRemote = nil
n3 = nil
n4 = nil
n5 = nil
connection2 = nil
n9 = nil
oa = nil
ob = nil
oc = nil
AuraRequest = nil
oe = nil
of = nil
og = nil
oh = nil
oi = nil
RebirthRequest = nil
ol = nil
om = nil
connection = nil
oo = nil
op = nil
oq = nil
ot = nil
ou = nil
ov = nil
ow = nil
ox = nil
oy = nil
LocalPlayer = nil
local nW, n6, n8
oA = nil
oB = nil
oC = nil
oD = nil
Label = nil
oG = nil
oH = nil
oI = nil
oJ = nil
Workspace = nil
oL = nil
oM = nil
oO = nil
oP = nil
oQ = nil
oS = nil
oT = nil
HttpService = nil
oV = nil
oW = nil
oX = nil
oY = nil
oZ = nil
VirtualUser = nil
o1 = nil
Options = nil
o3 = nil
o4 = nil
o5 = nil
UserInputService = nil
o7 = nil
o8 = nil
Toggles = nil
pa = nil
pb = nil
pc = nil
pd = nil
pe = nil
pf = nil
pg = nil
ph = nil
SaveManager = nil
pj = nil
pk = nil
pl = nil
local MarketplaceService, CoreGui, GuiService, o0, pm
pn = nil
xi_9, RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, MarketplaceService, LocalPlayer, ov, oq, RebirthRequest, AuraRequest, xi_25, n6, InventoryRemote, Config, AurasConfig, MonetizationConfig = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if ((RunService or xi_25) and (not RunService and not xi_25) or (not RunService or LocalPlayer or (xi_25 or LocalPlayer)) or (not LocalPlayer or LocalPlayer or RunService and not RunService) and (RunService or not xi_25 or not LocalPlayer and LocalPlayer)) and ((not LocalPlayer or not RunService or (xi_25 or not RunService) or (xi_25 or LocalPlayer) and (xi_25 or RunService)) and ((RunService or LocalPlayer) and (not LocalPlayer or not RunService) or (not RunService and LocalPlayer or not RunService and LocalPlayer))) and not (((RunService or xi_25) and (not RunService and not xi_25) or (not RunService or LocalPlayer or (xi_25 or LocalPlayer)) or (not LocalPlayer or LocalPlayer or RunService and not RunService) and (RunService or not xi_25 or not LocalPlayer and LocalPlayer)) and ((not LocalPlayer or not RunService or (xi_25 or not RunService) or (xi_25 or LocalPlayer) and (xi_25 or RunService)) and ((RunService or LocalPlayer) and (not LocalPlayer or not RunService) or (not RunService and LocalPlayer or not RunService and LocalPlayer)))) then
    n6 = game:GetService("Players")
else
    xi_9 = game:GetService("Players")
end
local xi_27 = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
MarketplaceService = game:GetService("MarketplaceService")
LocalPlayer = xi_9.LocalPlayer
local xi_44 = "+1 Jump Crunchy ASMR Escape"
ov = "https://discord.gg/K7Qxnxkk46"
oq = "https://discord.gg/K7Qxnxkk46"
local xi_42 = xi_27:WaitForChild("Remotes")
RebirthRequest = xi_42:WaitForChild("RebirthRequest")
AuraRequest = xi_42:WaitForChild("AuraRequest")
local xi_11 = xi_27:WaitForChild("PetSystem")
xi_25 = xi_11:WaitForChild("Events")
n6 = xi_25:WaitForChild("OpenEgg")
InventoryRemote = xi_25:WaitForChild("InventoryRemote")
local xi_14 = xi_27:WaitForChild("Configs")
Config = require(xi_14:WaitForChild("Config"))
AurasConfig = require(xi_14:WaitForChild("AurasConfig"))
MonetizationConfig = require(xi_14:WaitForChild("MonetizationConfig"))
xi_9 = {}
local xi_40 = Config.JumpUpgrades or xi_9
nL = xi_40
xi_9 = {}
xi_40 = Config.WinPadAmounts or xi_9
xi_9 = xi_40
xi_40 = tonumber(Config.DefaultTrampolineJumpMultiplier) or 1.5
pg = xi_40
xi_40 = tonumber(AurasConfig.RollCost) or 100
o7 = xi_40
xi_40 = tonumber(AurasConfig.AutoRollDelay) or 4.25
o1 = xi_40
xi_40 = tonumber(AurasConfig.MaxLuckLevel) or 99
oV, oT, oO, xi_11 = nil, nil, nil, nil
xi_25 = 6
repeat
    xi_42 = (xi_25 * 1 + 1) % 3 + 1
    if xi_42 <= 2 then
        if xi_42 <= 1 then
            local x3 = bit32.rrotate(bit32.bxor(bit32.lrotate(xi_25, 27), string.byte(tostring(oT))), 4)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(x3, 1637192777), 753135572), (bit32.bxor(bit32.band(x3, 2657774518), 151209934))), 753135572), 151209934) == x3 then
                xi_11 = xi_14:WaitForChild("Eggs_Configs")
            else
                xi_14 = xi_11:WaitForChild("Eggs_Configs")
            end
            xi_25 = (xi_25 + 22) % 24
        else
            local yC = bit32.rrotate(bit32.bxor(bit32.lrotate(xi_25, 26), string.byte(tostring(xi_11))), 27)
            if bit32.bxor(bit32.lrotate(bit32.bxor(yC, 2848058031), 14), 2058087024) == bit32.lrotate(yC, 14) then
                oV = xi_40
                oT = {}
            else
                xi_40 = oT
                oV = {}
            end
            xi_25 = (xi_25 + 16) % 24
        end
    else
        local yb = bit32.rrotate(bit32.bxor(bit32.lrotate(xi_25, 25), string.byte(tostring(xi_11))), 18)
        if bit32.bxor(bit32.lrotate(bit32.bxor(yb, 1810269340), 0), 1810269340) ~= bit32.lrotate(yb, 0) then
            oV = { "Slime", "JellyBox", "Common" }
        else
            oO = { "Common", "Slime", "JellyBox" }
        end
        xi_25 = (xi_25 + 22) % 24
    end
until (xi_25 * 5 + 22) % 24 == 16
for i, v in ipairs(oO) do
    xi_40 = xi_11:FindFirstChild(v)
    xi_25 = xi_40 and xi_40:IsA("ModuleScript")
    if xi_25 then
        xi_25, xi_42 = pcall(require, xi_40)
        xi_40 = xi_25 and type(xi_42) == "table" and type(xi_42.Price) == "number"
        if xi_40 then
            xi_40 = xi_42.Price
            xi_25 = xi_42.DisplayName or v
            oT[v] = { Name = v, Price = xi_40, Display = xi_25 }
        end
    end
end
xi_40 = { "Best Affordable" }
for i, v in ipairs(oO) do
    if oT[v] then
        xi_40[#xi_40 + 1] = oT[v].Display
    end
end
xi_11, n3 = nil, nil
xi_25 = 5
repeat
    xi_42 = (xi_25 * 1 + 0) % 2 + 1
    if xi_42 <= 1 then
        xi_42 = (vector.create((xi_25 * 7 + 6) % 11 + 1, (xi_25 * 11 + 5) % 13 + 1, (xi_25 * 6 + 9) % 17 + 1))
        xi_27 = (vector.create((xi_25 * 5 + 4) % 11 + 1, (xi_25 * 8 + 10) % 13 + 1, (xi_25 * 9 + 2) % 17 + 1))
        xi_14 = (vector.create((xi_25 * 2 + 7) % 5 + 1, (xi_25 * 4 + 5) % 7 + 1, (xi_25 * 4 + 4) % 9 + 1))
        if math.abs((vector.angle(xi_42, xi_27, xi_14))) - math.abs((vector.angle(xi_27, xi_42, xi_14))) == 0 then
            n3 = math.max(#xi_9, 21)
        else
            xi_9 = math.max(#n3, 21)
        end
        xi_25 = (xi_25 + 11) % 16
    else
        xi_42 = {
            "tejlmlegc",
            "lev",
            "fvrqylonh",
            "ztmbvjzkgzx",
            "dnsjpmqwra",
            "zkjwytyh",
            "hazree",
            "ehbusdx",
            "pqiw"
        }
        if xi_42[(xi_25 * 33 + 55) % 9 + 1] < xi_42[(xi_25 * 33 + 55) % 9 + 1] then
            n3 = { "Best" }
        else
            xi_11 = { "Best" }
        end
        xi_25 = (xi_25 + 1) % 16
    end
until (xi_25 * 5 + 13) % 16 == 2
local qj = 1
local qh = n3
while qj <= qh do
    local qk = qj
    xi_25 = xi_9[qk]
    if xi_25 then
        xi_11[#xi_11 + 1] = "Win pad" .. qk
    end
    qj += 1
end
nW, Library, SaveManager, Toggles, Options, nZ, nS, nO, pk, pj, pb, o4, oY, n9, oX, oG, ox, ol, ot, oa, nX, oZ, oH, ou, ob, oI, oh, oc, n5, n0, oS, nM, of, pa, oP, oB, pl, oQ, n4, nT, oM, op, nP, pd, oi, n1, nK, oL, nV, o8, oy, o3, n_, oC, n8, pm, om, pn, nQ, pf, oo = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
nW = {}
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
oX = fns.fn536
oG = fn1119
ox = fns.fn61
ol = fn1070
local xi_4 = "#7fd47f"
local xi_32 = "#6ec1ff"
nZ = "#e8a34d"
local xi_2 = "#8b93a3"
nS = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
nO = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
pk = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
pj = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
pb = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
o4 = ""
oY = ""
local xi_38 = "#345d9d"
local xi_8 = "#f7931a"
local xi_22 = "#627eea"
local xi_37 = "#26a17b"
local xi_7 = "#14f195"
local xi_21 = "#0070ba"
local xi_35 = "#008cff"
ot = fns.fn123
oa = fns.fn450
nX = fn842
oZ = fn1037
oH = fns.fn147
ou = fns.fn485
ob = function(bh, bi)
    local qL
    if typeof(bh) ~= "Vector3" then
        return
    end
    if not Workspace.StreamingEnabled then
        return
    end
    qL = false
    task.spawn(function()
        pcall(function()
            local qJ = bi or 5
            LocalPlayer:RequestStreamAroundAsync(bh, qJ)
        end)
        qL = true
    end)
    local qM = os.clock()
    local qM_1 = qM + (bi or 5) + 0.25
    while true do
        local qN_1 = not qL and os.clock() < qM_1 and not Library.Unloaded
        if qN_1 then
            task.wait()
            continue
        end
        break
    end
end
oI = fns.fn528
oh = fn1062
oc = fn1059
n5 = fns.fn619
n0 = fn745
oS = function(bU, bV)
    local q7_1
    local q6_1
    local q5_1
    q5_1, q6_1, q7_1 = pcall(function()
        return AuraRequest:InvokeServer(bU, bV)
    end)
    if not q5_1 then
        return false, nil
    end
    return q6_1 == true, q7_1
end
nM = function(cc)
    local rf = oH()
    if not rf or not cc or not firetouchinterest then
        return false
    end
    local rg_1 = {}
    for i, descendant in ipairs(cc:GetDescendants()) do
        if descendant:IsA("BasePart") then
            rg_1[#rg_1 + 1] = descendant
        end
    end
    if #rg_1 == 0 then
        return false
    end
    for i, v in ipairs(rg_1) do
        local rt = v
        pcall(function()
            firetouchinterest(rf, rt, 0)
        end)
    end
    task.wait(0.05)
    for i, v in ipairs(rg_1) do
        local rx = v
        pcall(function()
            firetouchinterest(rf, rx, 1)
        end)
    end
    return true
end
of = function(cs)
    if type(cs) ~= "number" then
        return false
    end
    local ry = nW[cs]
    local ry_1
    local rz = ry ~= nil
    local rz_1
    if rz then
        local rA_1 = tick()
        rz = rA_1 - (ry.at or 0) < 60
    end
    if rz then
        return ry.owned == true
    end
    ry_1, rz_1 = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, cs)
    end)
    local rB_2 = ry_1 and rz_1 == true
    nW[cs] = { owned = rB_2, at = tick() }
    return ry_1 and rz_1 == true
end
pa = fns.fn297
oP = fns.fn565
do
    oB = fns.fn694
    pl = fn952
    oQ = function()
        local r5
        r5 = nil
        local r7_1
        local r6_1
        r5 = oZ()
        if not r5 then
            return
        end
        if ot("GoBestTrampoline") then
            r6_1, r7_1 = oB()
            local r6_2 = oH()
            if r7_1 and r6_2 and (r6_2.Position - r7_1.Position).Magnitude > 8 then
                pl()
                task.wait(0.1)
            end
        end
        pcall(function()
            r5:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
    n9 = {
        [1] = Vector3.new(-66, 34, 60),
        [2] = Vector3.new(-66, 72, 80),
        [3] = Vector3.new(-66, 157, 110),
        [4] = Vector3.new(-66, 296, 140),
        [5] = Vector3.new(-66, 427, 160),
        [6] = Vector3.new(-66, 661, 190),
        [7] = Vector3.new(-66, 842, 210),
        [8] = Vector3.new(-66, 1078, 230),
        [9] = Vector3.new(-66, 1228, 240),
        [10] = Vector3.new(-66, 1596, 260),
        [11] = Vector3.new(-66, 1800, 270),
        [12] = Vector3.new(-66, 2083, 280),
        [13] = Vector3.new(-66, 2400, 290),
        [14] = Vector3.new(-66, 2700, 300),
        [15] = Vector3.new(-66, 3019, 310),
        [16] = Vector3.new(-66, 3500, 320),
        [17] = Vector3.new(-66, 4000, 340),
        [18] = Vector3.new(-66, 4500, 350),
        [19] = Vector3.new(-66, 4800, 355),
        [20] = Vector3.new(-66, 5074, 360),
        [21] = Vector3.new(-66, 5600, 380)
    }
    n4 = fn755
end
nT = fn989
oM = fns.fn212
op = fns.fn303
nP = fns.fn569
pd = fns.fn531
oi = fns.fn640
n1 = fn933
nK = fn1104
oL = fns.fn11
nV = fns.fn42
o8 = fns.fn219
oy = fns.fn687
o3 = fn1008
n_ = fn827
oC = fn826
n8 = fn710
pm = fns.fn367
om = function(fD)
    local ut_1
    local us_1
    if not getconnections then
        return {}
    end
    local ur = {}
    us_1, ut_1 = pcall(getconnections, n6.OnClientEvent)
    local uu = not us_1 or type(ut_1) ~= "table"
    if uu then
        return ur
    end
    for i, v in ipairs(ut_1) do
        local uB = v
        if fD then
            if uB.Enabled then
                pcall(function()
                    uB:Disable()
                end)
                ur[#ur + 1] = uB
            end
        else
            pcall(function()
                uB:Enable()
            end)
        end
    end
    return ur
end
pn = function()
    local uC
    uC = pm()
    if not uC then
        return
    end
    local uD = oT[uC]
    local uE = not uD or oh() < uD.Price
    if uE then
        return
    end
    local uD_1 = n8(uC)
    local uE_1 = uD_1 and uD_1:FindFirstChildWhichIsA("BasePart", true)
    if uE_1 then
        ob(uE_1.Position, 3)
        ou(uE_1.CFrame + Vector3.new(0, 4, 0))
        task.wait(0.1)
    end
    local uD_3 = ot("HideBoxAnimation")
    local uE_2 = uD_3 and om(true)
    local uG = uE_2 or {}
    pcall(function()
        n6:FireServer({ Action = "Hatch", EggName = uC })
    end)
    local wait = task.wait
    local uH = uD_3 and 1.25 or 0.35
    wait(uH)
    if uD_3 then
        for i, v in ipairs(uG) do
            local uR = v
            pcall(function()
                uR:Enable()
            end)
        end
        _G.EggAnimationActive = false
    end
end
nQ = fn852
pf = fns.fn160
oo = fns.fn509
xi_27 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = ov, Copyable = true }, "|", xi_44 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local xi_19 = {
    Info = xi_27:AddTab("Info", "info"),
    Main = xi_27:AddTab("Main", "gamepad-2"),
    Player = xi_27:AddTab("Player", "person-standing"),
    Settings = xi_27:AddTab("Settings", "settings")
}
local xi_16 = fns.fn105
for k, v in xi_19 do
    xi_16(v)
end
ph, xi_25, xi_27, Label, oA, xi_42 = nil, nil, nil, nil, nil, nil
xi_9 = 19
repeat
    xi_14 = (xi_9 * 2 + 2) % 3 + 1
    if xi_14 <= 2 then
        if xi_14 <= 1 then
            local yD = bit32.rrotate(bit32.bxor(bit32.lrotate(xi_9, 2), string.byte(tostring(xi_42))), 11)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(yD, 1459065237), 130090505), (bit32.bxor(bit32.band(yD, 2835902058), 1243744128))), 130090505), 1243744128) == yD then
                xi_42 = #oA > 18
            else
                oA = #xi_42 > 18
            end
            xi_9 = (xi_9 + 5) % 24
        else
            xi_14 = {
                "pagibmfkvr",
                "wbi",
                "kazot",
                "mhf",
                "mpcsnj",
                "ovybkg",
                "qdwezel",
                "rkfxiwowgk",
                "hyryturfpdu",
                "ttbzdu",
                "kijrgxvzin"
            }
            local x5 = xi_9
            xi_16 = xi_14[x5 % 11 + 1]
            if xi_16:len() <= xi_16:reverse():rep(x5 % 3 + 2):len() then
                ph = "Unknown"
                pcall(fn1085)
                xi_25 = xi_19.Info:AddLeftGroupbox("Account", "circle-user")
                xi_25:AddLabel(ol("User", LocalPlayer.Name, xi_4), true)
                xi_25:AddLabel(ol("Status", "Keyless", xi_4), true)
                xi_25:AddLabel(ol("Executor", ph, xi_4), true)
                xi_27 = xi_19.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                xi_27:AddLabel(ox(xi_44 .. " [" .. tostring(game.PlaceId) .. "]", xi_32), true)
                xi_27:AddLabel(ol("Place ID", tostring(game.PlaceId), xi_32), true)
                Label = xi_27:AddLabel(ol("Session time", "0s", nZ), true)
            else
                ol = "Unknown"
                pcall(fn1085)
                ox = (nil):AddLeftGroupbox("Account", "circle-user")
                ox:AddLabel(xi_25("User", nil, xi_27), true)
                ox:AddLabel(xi_25("Status", "Keyless", xi_27), true)
                ox:AddLabel(xi_25("Executor", ol, xi_27), true)
                xi_44 = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
                xi_44:AddLabel(xi_19(xi_32 .. " [" .. tostring(game.PlaceId) .. "]", LocalPlayer), true)
                xi_44:AddLabel(xi_25("Place ID", tostring(game.PlaceId), LocalPlayer), true)
                ph = xi_44:AddLabel(xi_25("Session time", "0s", Label), true)
            end
            xi_9 = (xi_9 + 23) % 24
        end
    else
        if (not xi_25 and oA or (xi_25 or oA) or (not oA or xi_42 or not oA and xi_42) or ((oA or not xi_25) and (oA and not xi_42) or (oA or not xi_42 or (xi_42 or not xi_42)))) and (not oA and not xi_25 and (xi_42 and not oA) and (not xi_42 and not xi_42 and (xi_42 or oA)) or oA and oA and (oA or xi_42) and (xi_42 and not oA or (xi_42 or oA))) or not ((not xi_25 and oA or (xi_25 or oA) or (not oA or xi_42 or not oA and xi_42) or ((oA or not xi_25) and (oA and not xi_42) or (oA or not xi_42 or (xi_42 or not xi_42)))) and (not oA and not xi_25 and (xi_42 and not oA) and (not xi_42 and not xi_42 and (xi_42 or oA)) or oA and oA and (oA or xi_42) and (xi_42 and not oA or (xi_42 or oA)))) then
            oA = tostring(game.JobId)
        else
            xi_27 = tostring(game.JobId)
        end
        xi_9 = (xi_9 + 2) % 24
    end
until (xi_9 * 13 + 22) % 24 == 11
if xi_42 then
    xi_9 = 7
    repeat
        local x7 = bit32.rrotate(bit32.bxor(bit32.lrotate(xi_9, 29), string.byte(tostring(xi_9))), 13)
        if bit32.bxor(bit32.lrotate(bit32.bxor(x7, 2070956144), 20), 2265429764) == bit32.lrotate(x7, 20) then
            xi_42 = string.sub(oA, 1, 18) .. "..."
        else
            oA = string.sub(xi_42, 1, 18) .. "..."
        end
        xi_9 = (xi_9 + 4) % 8
    until (xi_9 * 5 + 5) % 8 == 4
end
xi_9 = xi_42
local p4 = if xi_9 then 1 else 0
local p2 = 3047 * p4 + 539 * (1 - p4)
local p3 = 2833 * p4 + 3984 * (1 - p4)
if not ((p2 * 1861 + p3 * 2595 + p2 * p3) % 16777213 == 4877040) then
    xi_9 = oA
end
og, xi_14, DonationsGroup, xi_16, xi_42, FlyGroup, oD, pe, o5, connection, connection2, pc, oJ, o0, ow, oe, oW = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if (not FlyGroup or not oe) and (not xi_14 and not connection) or (xi_16 and connection or xi_14 and not connection) or not ((not FlyGroup or not oe) and (not xi_14 and not connection) or (xi_16 and connection or xi_14 and not connection)) then
    local xi_43 = xi_9
    xi_27:AddLabel(ol("Server", xi_43, xi_2), true)
    xi_27:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
    og = os.clock()
else
    xi_27 = xi_2
    og:AddLabel(xi_9("Server", xi_27, ol), true)
    og:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
    os.clock()
end
task.spawn(fns.worker)
xi_14 = xi_19.Info:AddRightGroupbox("Scripts", "package")
xi_14:AddLabel(ox("Included in this hub", xi_2), true)
xi_14:AddLabel(ox(xi_44, xi_32), true)
xi_25 = xi_19.Info:AddRightGroupbox("Features", "list")
xi_25:AddLabel(ox("Auto Farm", xi_32), true)
xi_25:AddLabel(ox("Auto Shop", xi_4), true)
xi_25:AddLabel(ox("Auto Equip", nZ), true)
xi_25:AddLabel(ox("Misc Utilities", xi_2), true)
local SocialsGroup = xi_19.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = oG })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = xi_19.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
if (xi_25 and not xi_25 or TempoHubGroup and not xi_25 or (not xi_25 and TempoHubGroup or (xi_42 or xi_25))) and not (xi_25 and not xi_25 or TempoHubGroup and not xi_25 or (not xi_25 and TempoHubGroup or (xi_42 or xi_25))) then
    DonationsGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    DonationsGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    DonationsGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    DonationsGroup:AddButton({ Text = "Copy Discord Invite", Func = TempoHubGroup })
    xi_19 = oG.Info:AddRightGroupbox("Donations", "heart")
else
    TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = oG })
    DonationsGroup = xi_19.Info:AddRightGroupbox("Donations", "heart")
end
DonationsGroup:AddLabel(ox("All donations are optional but appreciated.", nZ), true)
DonationsGroup:AddLabel(ox("If you donate you get a special role, just PING after you donate.", xi_4), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(ox("LTC / Litecoin", xi_38), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = fns.onCopyLitecoinAddress })
DonationsGroup:AddLabel(ox("BTC / Bitcoin", xi_8), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(ox("ETH / Ethereum", xi_22), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = fns.onCopyEthereumAddress })
DonationsGroup:AddLabel(ox("USDT", xi_37), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(ox("Solana", xi_7), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(ox("PayPal", xi_21), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = fns.onCopyPayPalLink })
DonationsGroup:AddLabel(ox("Venmo", xi_35), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = fns.onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(ox("Don't have any of the listed currencies but still wanna donate?", xi_2), true)
DonationsGroup:AddLabel(ox("DM me and we'll work something out.", xi_32), true)
local FaqGroup = xi_19.Info:AddRightGroupbox("FAQ", "circle-help")
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
local FarmGroup = xi_19.Main:AddLeftGroupbox("Farm", "rabbit")
FarmGroup:AddToggle("AutoJump", { Text = "Auto Jump", Default = false })
FarmGroup:AddSlider("JumpDelay", { Text = "Jump delay", Default = 0.2, Min = 0.05, Max = 2, Rounding = 2, Suffix = "s" })
FarmGroup:AddToggle("GoBestTrampoline", { Text = "Go Best Trampoline", Default = false })
FarmGroup:AddToggle("AutoWins", { Text = "Auto Wins", Default = false })
FarmGroup:AddDropdown("WinPad", { Text = "Win pad", Values = xi_11, Default = "Best" })
FarmGroup:AddSlider("WinDelay", { Text = "Win delay", Default = 0.35, Min = 0.1, Max = 5, Rounding = 2, Suffix = "s" })
local ShopGroup = xi_19.Main:AddLeftGroupbox("Shop", "shopping-bag")
ShopGroup:AddToggle("AutoBuySteps", { Text = "Auto Buy Steps", Default = false })
ShopGroup:AddToggle("AutoBuyBoxes", { Text = "Auto Buy Boxes", Default = false })
ShopGroup:AddDropdown("BoxEgg", { Text = "Box", Values = xi_40, Default = "Best Affordable" })
ShopGroup:AddToggle("HideBoxAnimation", { Text = "Hide Box Animation", Default = true })
ShopGroup:AddToggle("AutoBuyLuck", { Text = "Auto Buy Luck", Default = false })
ShopGroup:AddSlider("ShopDelay", { Text = "Shop delay", Default = 0.5, Min = 0.2, Max = 10, Rounding = 2, Suffix = "s" })
local AurasGroup = xi_19.Main:AddRightGroupbox("Auras", "sparkles")
AurasGroup:AddToggle("AutoRollAuras", { Text = "Auto Roll Auras", Default = false })
AurasGroup:AddSlider("AuraRollDelay", { Text = "Aura roll delay", Default = o1, Min = 0.5, Max = 15, Rounding = 2, Suffix = "s" })
xi_16 = xi_19.Main:AddRightGroupbox("Auto Equip", "shirt")
xi_16:AddToggle("AutoEquipBestSteps", { Text = "Auto Equip Best Steps", Default = false })
xi_16:AddToggle("AutoEquipBestPets", { Text = "Auto Equip Best Pets", Default = false })
xi_16:AddToggle("AutoEquipBestAura", { Text = "Auto Equip Best Aura", Default = false })
xi_16:AddSlider("EquipDelay", { Text = "Equip delay", Default = 1, Min = 0.25, Max = 15, Rounding = 2, Suffix = "s" })
xi_42 = xi_19.Main:AddRightGroupbox("Progress", "rotate-ccw")
xi_42:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
xi_42:AddSlider("RebirthDelay", { Text = "Rebirth delay", Default = 1, Min = 0.5, Max = 30, Rounding = 1, Suffix = "s" })
local MovementGroup = xi_19.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
FlyGroup = xi_19.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
pc = function(hr)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not hr)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not hr
        end
    end)
    if not hr then
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
Toggles.AntiGameplayPause:OnChanged(fns.fn460)
Toggles.Fly:OnChanged(fns.fn446)
Toggles.WalkSpeedEnabled:OnChanged(fns.fn696)
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(fns.onJumpRequest)
oD = Workspace.CurrentCamera
RunService.RenderStepped:Connect(fns.onRenderStepped)
local MenuGroup = xi_19.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", fns.onUnload)
pe = tick()
o5 = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local vX = v
        pcall(function()
            vX:Disable()
        end)
    end
end)
oJ = fns.fn101
connection = UserInputService.InputBegan:Connect(fns.onInputBegan)
connection2 = UserInputService.InputChanged:Connect(fns.onInputChanged)
Library:OnUnload(fns.fn495)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(xi_19.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/JumpCrunchyASMREscape")
local xi_31 = SaveManager:BuildConfigSection(xi_19.Settings)
o0 = fn1050
ow = fns.fn170
oe = fns.fn117
if (connection2 or not MenuGroup or (not connection2 or not connection2)) and ((not connection2 or not connection2) and (connection2 or not connection2)) or not ((connection2 or not MenuGroup or (not connection2 or not connection2)) and ((not connection2 or not connection2) and (connection2 or not connection2))) then
    oW = function(i7)
        local wF
        wF = nil
        local wG = type(i7) ~= "table" or type(i7.idx) ~= "string" or type(i7.type) ~= "string" or SaveManager.Ignore[i7.idx]
        if wG then
            return false
        end
        wF = o0(i7.type, i7.idx)
        if not wF then
            return false
        end
        local wG_1 = pcall(function()
            if i7.type == "Input" then
                if type(i7.text) ~= "string" then
                    return
                end
                wF:SetValue(i7.text)
            elseif i7.type == "ColorPicker" then
                wF:SetValueRGB(Color3.fromHex(i7.value), i7.transparency)
            elseif i7.type == "KeyPicker" then
                wF:SetValue({ i7.key, i7.mode, i7.modifiers })
                if i7.mode == "Toggle" and i7.toggled ~= nil then
                    wF.Toggled = i7.toggled
                    wF:Update()
                end
            else
                wF:SetValue(i7.value)
            end
        end)
        return wG_1
    end
end
if not TempoHubGroup and not TempoHubGroup and (connection2 and connection2) and ((connection2 or TempoHubGroup) and (connection2 and not TempoHubGroup)) or not (not TempoHubGroup and not TempoHubGroup and (connection2 and connection2) and ((connection2 or TempoHubGroup) and (connection2 and not TempoHubGroup))) then
    xi_31:AddDivider()
    xi_31:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    xi_31:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    xi_31:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
    SaveManager:LoadAutoloadConfig()
    task.spawn(worker10)
    task.spawn(worker9)
    task.spawn(worker8)
    task.spawn(fns.worker7)
    task.spawn(fns.worker6)
    task.spawn(worker5)
    task.spawn(fns.worker4)
    task.spawn(fns.worker3)
    task.spawn(fns.worker2)
else
    SaveManager:AddDivider()
    SaveManager:AddInput("SaveManager_ImportSource", { AllowEmpty = true, Text = "Paste exported config here", Finished = true })
    SaveManager:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    SaveManager:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
    xi_31:LoadAutoloadConfig()
    task.spawn(worker10)
    task.spawn(worker9)
    task.spawn(worker8)
    task.spawn(fns.worker7)
    task.spawn(fns.worker6)
    task.spawn(worker5)
    task.spawn(fns.worker4)
    task.spawn(fns.worker3)
    task.spawn(fns.worker2)
end
end)(...)

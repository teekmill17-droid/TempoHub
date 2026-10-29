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
getgenv().TempoHoodSubtitle = "+1 MUSCLE EVOLUTION"
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
local oN_16
local jH
local i5
local Library
local iN
local ju
local jb
local iT
local VirtualUser
local connection2
local iZ
local jn
local i4
local onUnlockNow
local iM
local connection3
local iS
local jz
local iY
local UserInputService
local jm
local onUpgradeNow
local iL
local connection
local i9
local jR
local Options
local jf
local iX
local jE
local jl
local i2
local jK
local onOpenNow
local iQ
local jx
local je
local iW
local jD
local jk
local i1
local CollectionService
local onBuyNow
local connection5
local iP
local LocalPlayer
local jd
local connection4
local Toggles
local jj
local i0
local jp
local i6
local jO
local iO
local jv
local jc
local i_
local function fn17()
    if not Toggles.Fly.Value then
        local og = jf()
        if og then
            og.PlatformStand = false
        end
    end
end
local function worker5()
    while not Library.Unloaded do
        if jR("AutoBattleShop") then
            onBuyNow()
        end
        task.wait(jz("BattleShopDelay", 3))
    end
end
local function fn55()
    local Character = LocalPlayer.Character
    local lN = Character and Character:FindFirstChild("HumanoidRootPart")
    return lN
end
local function fn87(L)
    local k3 = {}
    if type(L) == "table" then
        for k in pairs(L) do
            k3[#k3 + 1] = tostring(k)
        end
        table.sort(k3)
    end
    return k3
end
local function fn103()
    local EndlessArenas = workspace:FindFirstChild("EndlessArenas")
    if not EndlessArenas then
        return nil
    end
    return EndlessArenas:FindFirstChild("Arena_1")
end
local function worker6()
    while not Library.Unloaded do
        if jR("AutoBattleUpgrades") then
            onUpgradeNow()
        end
        task.wait(jz("BattleUpgradeDelay", 3))
    end
end
local function fn178()
    if Toggles.WalkSpeedEnabled.Value then
        i_(jf())
    end
end
local function fn187(dc)
    local DiscordGroup = dc:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = jj })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = jj })
end
local function onInputBegan()
    iY = tick()
end
local function onJumpRequest()
    local nT = Library.Unloaded or not jR("InfJump")
    if nT then
        return
    end
    local nT_1 = jf()
    if nT_1 then
        nT_1:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end
local function fn269()
    local nk_1
    local nj_1
    if identifyexecutor then
        nk_1, nj_1 = identifyexecutor()
        local nl = nk_1 ~= ""
        local nm = type(nk_1) == "string" and nl
        if nm then
            local nl_1 = type(nj_1) == "string" and nj_1 ~= "" and nk_1 .. " " .. nj_1
            iX = nl_1 or nk_1
        end
    end
end
local function onCopyJoinScript_JobID()
    local dv = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, jE)
    ju(dv, "Copied join script to clipboard")
end
local function fn319()
    pcall(function()
        jx:Fire()
    end)
end
local function onUnload()
    Library:Unload()
end
local function fn356()
    local attr = LocalPlayer:GetAttribute("EndlessRunState")
    return attr == "WaveActive" or attr == "Intermission"
end
local function worker9()
    while not Library.Unloaded do
        if jR("AutoBuyAuras") then
            jm()
        end
        if jR("AutoBuyGloves") then
            i4()
        end
        if jR("AutoEquipBest") then
            iS()
        end
        task.wait(jz("ShopDelay", 3))
    end
end
local function worker()
    local np_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local no = math.floor(os.clock() - jk)
        if no < 60 then
            np_1 = no .. "s"
        elseif no < 3600 then
            np_1 = string.format("%dm %ds", math.floor((no) / (60)), no % 60)
        else
            np_1 = string.format("%dh %dm", math.floor((no) / (3600)), math.floor((no % 3600) / (60)))
        end
        jH:SetText(i6("Session time", np_1, iP))
    end
end
local function fn388(an, ao)
    return string.format('<font color="%s">%s</font>', ao, an)
end
local function worker3()
    while not Library.Unloaded do
        if jR("AutoDamage") then
            jO()
        end
        task.wait(jz("DamageDelay", 0.1))
    end
end
local function fn397()
    local l6 = jv()
    if l6 then
        iW(l6)
    end
end
local function fn410(aq, ar, as)
    return string.format("<b>%s</b> %s %s", aq, jd("-", "#5a6070"), jd(ar, as))
end
local function worker10()
    while not Library.Unloaded do
        if jR("AutoOpenEgg") then
            onOpenNow()
        end
        task.wait(jz("EggDelay", 1))
    end
end
local function onRscripts()
    ju(jn, "Copied Rscripts profile to clipboard")
end
local function onRenderStepped(eW)
    if Library.Unloaded then
        return
    end
    if jR("WalkSpeedEnabled") then
        i_(jf())
    end
    if jR("Noclip") then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in Character:GetDescendants() do
                local nV_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if nV_2 then
                    descendant.CanCollide = false
                    i1[descendant] = true
                end
            end
        end
    elseif next(i1) then
        for k in i1 do
            if k.Parent then
                k.CanCollide = true
            end
        end
        table.clear(i1)
    end
    local of = if jR("Fly") then 1 else 0
    if of == 1 then
        local nV_3 = i9()
        local nW = jf()
        if nV_3 and nW and workspace.CurrentCamera then
            nW.PlatformStand = true
            local nW_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                nW_1 = nW_1 + workspace.CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                nW_1 = nW_1 - workspace.CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                nW_1 = nW_1 - workspace.CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                nW_1 = nW_1 + workspace.CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                nW_1 = nW_1 + Vector3.yAxis
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                nW_1 = nW_1 - Vector3.yAxis
            end
            nV_3.AssemblyLinearVelocity = Vector3.zero
            if nW_1.Magnitude > 0 then
                nV_3.CFrame = nV_3.CFrame + nW_1.Unit * jz("FlySpeed", 80) * eW
            end
        end
    end
end
local function fn443(ev)
    if not ev then
        return
    end
    local nJ = jz("WalkSpeed", 50)
    if ev.WalkSpeed == nJ then
        return
    end
    i5 = true
    ev.WalkSpeed = nJ
    i5 = false
end
local function worker2()
    while not Library.Unloaded do
        task.wait(2)
        if jR("AntiAfk") then
            local ox = tick() - iY
            local oy = tick() - iT
            if ox >= 300 and oy >= 60 then
                pcall(jK)
            else
                if ox < 300 and oy >= 300 then
                    pcall(jK)
                end
            end
        end
    end
end
local function fn469(aP)
    local lt = Options[aP]
    return lt and lt.Value or nil
end
local function worker4()
    local oC = 0
    while not Library.Unloaded do
        if jR("AutoArena") then
            if je() then
                i0()
                task.wait(0.1)
            else
                if os.clock() - oC >= jz("ArenaDelay", 3) then
                    oC = os.clock()
                    jb()
                end
                task.wait(0.25)
            end
        else
            task.wait(0.5)
        end
    end
end
local function onInputChanged(ei)
    local UserInputType = ei.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        iY = tick()
    end
end
local function fn476()
    local Character = LocalPlayer.Character
    local nH = Character and Character:FindFirstChildOfClass("Humanoid")
    return nH
end
local function fn488()
    pcall(function()
        iN:Fire(nil)
    end)
end
local function fn491(o)
    local kZ_1
    local kY_1
    kY_1, kZ_1 = pcall(require, o)
    if kY_1 then
        return kZ_1
    end
    return nil
end
local function fn581()
    local l9_1
    local l8_1
    if not je() then
        jb()
        return
    end
    if LocalPlayer:GetAttribute("EndlessRunState") ~= "WaveActive" then
        return
    end
    l8_1, l9_1 = iZ()
    if not l8_1 then
        return
    end
    local ma = l8_1:FindFirstChild("HumanoidRootPart") or l8_1.PrimaryPart
    local l8_2 = ma
    if ma then
        ma = not l9_1 or l9_1 > 6
    end
    if ma then
        iW(CFrame.new(l8_2.Position + Vector3.new(0, 3, 0)))
    end
    jO()
end
local function fn595()
    pcall(function()
        iL:Fire()
    end)
end
local function fn602(aU)
    local Character = LocalPlayer.Character
    if not Character then
        return
    end
    if Character.PrimaryPart then
        Character:PivotTo(aU)
    else
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = aU
        end
    end
end
local function fn608(az)
    local ld = Toggles[az]
    return ld ~= nil and ld.Value == true
end
local function fn628()
    connection:Disconnect()
    connection2:Disconnect()
    connection3:Disconnect()
    connection4:Disconnect()
    connection5:Disconnect()
    if i2 then
        i2:Disconnect()
        i2 = nil
    end
    for k in i1 do
        if k.Parent then
            k.CanCollide = true
        end
    end
    table.clear(i1)
    local op = jf()
    if op then
        op.PlatformStand = false
    end
    pcall(function()
        jl:Fire(false)
    end)
end
local function fn639(aE, aF)
    local lj = Options[aE]
    local lk = lj and tonumber(lj.Value)
    return lk or aF
end
local function onCharacterAdded(eM)
    local Humanoid = eM:WaitForChild("Humanoid", 10)
    if Humanoid then
        iM(Humanoid)
    end
end
local function fn694()
    ju(jp, "Copied Discord invite to clipboard")
end
local function fn698(ag, ah)
    if setclipboard then
        setclipboard(ag)
    elseif toclipboard then
        toclipboard(ag)
    end
    Library:Notify(ah)
end
local function fn741()
    local lS = i9()
    if not lS then
        return nil
    end
    local attr3 = LocalPlayer:GetAttribute("EndlessRunId")
    local lU = math.huge
    local lV
    for i, v in ipairs(CollectionService:GetTagged("StageMob")) do
        if v and v.Parent then
            local attr2 = v:GetAttribute("EndlessRunId")
            local attr = v:GetAttribute("OwnerUserId")
            if attr3 and attr2 == attr3 or attr == LocalPlayer.UserId then
                local Humanoid = v:FindFirstChildOfClass("Humanoid")
                local lX_2 = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart
                local lY_1 = Humanoid
                if lY_1 then
                    lY_1 = Humanoid.Health > 0
                end
                if lY_1 and lX_2 then
                    local Magnitude = (lX_2.Position - lS.Position).Magnitude
                    if Magnitude < lU then
                        lV = v
                        lU = Magnitude
                    end
                end
            end
        end
    end
    return lV, lU
end
local function worker7()
    while not Library.Unloaded do
        if jR("AutoRebirth") then
            iO()
        end
        task.wait(jz("RebirthDelay", 5))
    end
end
local function worker11()
    while not Library.Unloaded do
        if jR("AutoDaily") then
            jc()
        end
        if jR("AutoFreeRewards") then
            iQ()
        end
        task.wait(jz("RewardsDelay", 30))
    end
end
local function fn767()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    iT = tick()
end
local function fn789()
    local lB = jD()
    if not lB then
        return nil
    end
    local PlayerSpawn = lB:FindFirstChild("PlayerSpawn")
    local lD = PlayerSpawn and PlayerSpawn:IsA("BasePart")
    if lD then
        return PlayerSpawn.CFrame + Vector3.new(0, 3, 0)
    end
    local ArenaZone = lB:FindFirstChild("ArenaZone")
    local lB_1 = ArenaZone and ArenaZone:IsA("BasePart")
    if lB_1 then
        return ArenaZone.CFrame + Vector3.new(0, 3, 0)
    end
    return nil
end
local function worker8()
    while not Library.Unloaded do
        if jR("AutoUnlock") then
            onUnlockNow()
        end
        task.wait(jz("UnlockDelay", 1))
    end
end
local function fn821()
    if Toggles.Noclip.Value then
        return
    end
    for k in i1 do
        if k.Parent then
            k.CanCollide = true
        end
    end
    table.clear(i1)
end
local function fn848(aK)
    local lp = Options[aK]
    return lp and lp.Value or {}
end
iL = nil
iM = nil
iN = nil
iO = nil
iP = nil
iQ = nil
iS = nil
iT = nil
connection4 = nil
iW = nil
iX = nil
iY = nil
iZ = nil
i_ = nil
i0 = nil
i1 = nil
i2 = nil
onUpgradeNow = nil
i4 = nil
i5 = nil
i6 = nil
connection5 = nil
i9 = nil
connection3 = nil
jb = nil
jc = nil
jd = nil
je = nil
jf = nil
connection2 = nil
jj = nil
jk = nil
jl = nil
jm = nil
jn = nil
jp = nil
onBuyNow = nil
connection = nil
ju = nil
jv = nil
LocalPlayer = nil
jx = nil
local iR, iU, i8, ClientData, ji, jo, jr, jt
Options = nil
jz = nil
VirtualUser = nil
Toggles = nil
jD = nil
jE = nil
UserInputService = nil
jH = nil
CollectionService = nil
jK = nil
onUnlockNow = nil
Library = nil
jO = nil
onOpenNow = nil
jR = nil
local jB, jG, jP
local ShopTimingGroup
jB = nil
jG = nil
local jI
local jL
jP = nil
CollectionService, UserInputService, VirtualUser, LocalPlayer, jp, jn, ClientData, iU, iR, iN, iL, jP, jL, jI, jG, jB, jx, jt, jr, jo, jl, oN_16 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local oN_9 = game:GetService("ReplicatedStorage")
CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
LocalPlayer = Players.LocalPlayer
local j6 = "Muscle Evolution"
jp = "https://discord.gg/K7Qxnxkk46"
jn = "https://discord.gg/K7Qxnxkk46"
local oN_13 = require(oN_9.Packages.Packet)
local oN_8 = require(oN_9.Shared.Utils.Functions)
ClientData = require(oN_9.Client.Controllers.ClientData)
local oN_2_2
local oN_12 = oN_9.Shared.Configs
local oN_7 = fn491(oN_12.Auras)
local j1 = fn491(oN_12.BattleShop)
local oN_5 = fn491(oN_12.BattleUpgrades)
local j2 = fn491(oN_12.Eggs)
iU = fn491(oN_12.DailyRewards)
iR = fn491(oN_12.PlaytimeRewards)
iN = oN_13("Click", oN_13.Any)
iL = oN_13("Rebirth")
jP = oN_13("OpenEgg", oN_13.Instance)
jL = oN_13("CollectDaily", oN_13.NumberU8)
jI = oN_13("CollectPlaytime", oN_13.NumberU8)
jG = oN_13("BuyAura", oN_13.String)
jB = oN_13("BuyBoxingGloves", oN_13.NumberU16)
jx = oN_13("EquipBestItems")
jt = oN_13("BattleShopRequest", oN_13.Any)
jr = oN_13("BattleShopBuy", oN_13.String)
jo = oN_13("BuyBattleUpgrade", oN_13.String)
jl = oN_8.GetSignal("SetAutoFightEnabled")
local j3 = fn87
local j5 = j3(oN_7)
local j4 = {}
if (jP or not jP or false and CollectionService or UserInputService and fn491 and (not jP or fn491) or (UserInputService or CollectionService or not UserInputService and false or (UserInputService or CollectionService) and (false or UserInputService))) and (((not jP or false) and (not jP or not CollectionService) or (jP and not jP or (CollectionService or not jP))) and (jP or not jP or (false or jP) or (UserInputService and not CollectionService or (CollectionService or jP)))) and not ((jP or not jP or false and CollectionService or UserInputService and fn491 and (not jP or fn491) or (UserInputService or CollectionService or not UserInputService and false or (UserInputService or CollectionService) and (false or UserInputService))) and (((not jP or false) and (not jP or not CollectionService) or (jP and not jP or (CollectionService or not jP))) and (jP or not jP or (false or jP) or (UserInputService and not CollectionService or (CollectionService or jP))))) then
    oN_5 = oN_16
else
    oN_16 = oN_5
end
if oN_16 then
    local oN_1_1 = 3
    repeat
        oN_7 = {
            "uagfuqtbaldc",
            "hyowhqdvsey",
            "bnraaac",
            "vkog",
            "adulythokty",
            "vtpplubn",
            "bdk",
            "sumdnpdalmeg",
            "pyjq",
            "kwvgdunm",
            "whqzvxure"
        }
        if oN_7[(oN_1_1 * 95 + 87) % 11 + 1] < oN_7[(oN_1_1 * 95 + 87) % 11 + 1] then
            oN_5 = type(oN_16.Upgrades) == "table"
        else
            oN_16 = type(oN_5.Upgrades) == "table"
        end
        oN_1_1 = (oN_1_1 + 1) % 4
    until (oN_1_1 * 3 + 0) % 4 == 0
end
if oN_16 then
    j4 = j3(oN_5.Upgrades)
end
local oN_1_2 = j1
oN_7 = {}
if oN_1_2 then
    oN_12 = 2
    repeat
        if (oN_12 * 3 + 9) * 9 % 4 == ((oN_12 * 3 + 9) * 9 + 9) % 4 then
            j1 = type(oN_1_2.Slots) == "table"
        else
            oN_1_2 = type(j1.Slots) == "table"
        end
        oN_12 = (oN_12 + 3) % 4
    until (oN_12 * 1 + 1) % 4 == 2
end
if oN_1_2 then
    for i, v in ipairs(j1.Slots) do
        local oN_1_3 = type(v) == "table" and type(v.Id) == "string"
        if oN_1_3 then
            oN_7[#oN_7 + 1] = v.Id
        end
    end
end
local oN_1_4 = {}
for i, v in ipairs(j3(j2)) do
    if v ~= "Template" then
        oN_1_4[#oN_1_4 + 1] = v
    end
end
Library, Toggles, Options, iP, j1, ju, jj, jd, i6, jR, jz, ji, i8, iW, jO, jD, jv, je, i9, iZ, jb, i0, onBuyNow, onUpgradeNow, iO, onUnlockNow, jm, i4, iS, onOpenNow, jc, iQ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
j3 = getgenv().ThemeManager
j2 = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
ju = fn698
jj = fn694
jd = fn388
i6 = fn410
oN_5 = "#7fd47f"
oN_16 = "#6ec1ff"
iP = "#e8a34d"
oN_9 = "#8b93a3"
if ((false or i0) and (false or not iQ) or (not iQ or iQ or (iQ or not iQ))) and (("#6ec1ff" or (not i0 or oN_16)) and ((i0 or not i0) and "#6ec1ff")) and ((i0 or not iQ or (iQ or iQ)) and (i0 and not iQ or i0 and not i0) and ((i0 or false) and (not i0 or i0) or false and (i0 or not iQ))) and not (((false or i0) and (false or not iQ) or (not iQ or iQ or (iQ or not iQ))) and (("#6ec1ff" or (not i0 or oN_16)) and ((i0 or not i0) and "#6ec1ff")) and ((i0 or not iQ or (iQ or iQ)) and (i0 and not iQ or i0 and not i0) and ((i0 or false) and (not i0 or i0) or false and (i0 or not iQ)))) then
    jz = fn608
    ji = fn639
    jR = fn848
else
    jR = fn608
    jz = fn639
    ji = fn848
end
i8 = fn469
iW = fn602
jO = fn488
jD = fn103
jv = fn789
if (not j2 or not ju or jb and ju) and ((ju or not j2) and (not jb or ju)) and ((jb and j2 or (not jb or not ju)) and (not j2 and not j2 or (ju or not ju))) or not ((not j2 or not ju or jb and ju) and ((ju or not j2) and (not jb or ju)) and ((jb and j2 or (not jb or not ju)) and (not j2 and not j2 or (ju or not ju)))) then
    je = fn356
    i9 = fn55
    iZ = fn741
    jb = fn397
else
    i9 = fn356
    je = fn55
    jb = fn741
    iZ = fn397
end
i0 = fn581
onBuyNow = function()
    pcall(function()
        jt:Fire({ TimezoneOffsetMinutes = 0 })
    end)
    for k, v in pairs(ji("BattleShopSlots")) do
        local mh = k
        if v then
            pcall(function()
                jr:Fire(mh)
            end)
            task.wait(0.1)
        end
    end
end
onUpgradeNow = function()
    for k, v in pairs(ji("BattleUpgradeKinds")) do
        local mo = k
        if v then
            pcall(function()
                jo:Fire(mo)
            end)
            task.wait(0.1)
        end
    end
end
iO = fn595
onUnlockNow = function()
    for i, v in ipairs(CollectionService:GetTagged("BodyStand")) do
        if not jR("AutoUnlock") then
            break
        elseif v and v.Parent then
            local ProximityPrompt = v:FindFirstChildWhichIsA("ProximityPrompt", true)
            if ProximityPrompt then
                pcall(function()
                    fireproximityprompt(ProximityPrompt)
                end)
            end
        end
    end
end
jm = function()
    for k, v in pairs(ji("AuraKinds")) do
        local mH = k
        if v then
            pcall(function()
                jG:Fire(mH)
            end)
            task.wait(0.1)
        end
    end
end
i4 = function()
    local cr = math.floor(jz("GlovesAmount", 1))
    pcall(function()
        jB:Fire(cr)
    end)
end
iS = fn319
onOpenNow = function()
    local mK = i8("EggChoice")
    for i, v in ipairs(CollectionService:GetTagged("Egg")) do
        local mV = v
        local mY = if not jR("AutoOpenEgg") then 1 else 0
        if mY == 1 then
            break
        else
            if mV and mV.Parent then
                local mL_1 = mV:GetAttribute("EggName") or mV.Name
                if not mK or mK == "" or mK == "Any" or mL_1 == mK then
                    pcall(function()
                        jP:Fire(mV)
                    end)
                    task.wait(0.1)
                end
            end
        end
    end
end
if (jz or jz) and (j1 or jb) and ((jz or j1) and (j1 and not jz)) or (i0 or not jb) and (not jz and not j1) and (not j1 and not j1 or jb and j1) or not ((jz or jz) and (j1 or jb) and ((jz or j1) and (j1 and not jz)) or (i0 or not jb) and (not jz and not j1) and (not j1 and not j1 or jb and j1)) then
    jc = function()
        local mZ
        local m_ = ClientData:GetProfile()
        if not (m_ and iU) then
            return
        end
        local max = math.max
        local m2 = tonumber(m_.DataAccessor:Get("DailyRewardStreak")) or 1
        mZ = max(math.floor(m2), 1)
        if #iU < mZ then
            return
        end
        local m0_5 = tonumber(m_.DataAccessor:Get("DailyRewardCollect")) or 0
        local m0_6 = m0_5 > 0 and DateTime.now().UnixTimestamp - m0_5 < 86400
        if m0_6 then
            return
        end
        pcall(function()
            jL:Fire(mZ)
        end)
    end
    iQ = function()
        local m7 = ClientData:GetProfile()
        if not (m7 and iR) then
            return
        end
        local m8_2 = tonumber(m7.GameAccessor:Get("SessionStart"))
        if not m8_2 or m8_2 <= 0 then
            return
        end
        local m9_2 = m7.GameAccessor:Get("PlaytimeCollected")
        if type(m9_2) ~= "table" then
            m9_2 = {}
        end
        local UnixTimestamp = DateTime.now().UnixTimestamp
        for i, v in ipairs(iR) do
            local ng = i
            if not m9_2[ng] then
                local na = tonumber(v.WaitTime) or 0
                if UnixTimestamp >= m8_2 + na then
                    pcall(function()
                        jI:Fire(ng)
                    end)
                end
            end
        end
    end
else
    iQ = function()
        local mZ
        local m_ = ClientData:GetProfile()
        if not (m_ and iU) then
            return
        end
        local max = math.max
        local m2 = tonumber(m_.DataAccessor:Get("DailyRewardStreak")) or 1
        mZ = max(math.floor(m2), 1)
        if #iU < mZ then
            return
        end
        local m0_2 = tonumber(m_.DataAccessor:Get("DailyRewardCollect")) or 0
        local m0_3 = m0_2 > 0 and DateTime.now().UnixTimestamp - m0_2 < 86400
        if m0_3 then
            return
        end
        pcall(function()
            jL:Fire(mZ)
        end)
    end
    jc = function()
        local m7 = ClientData:GetProfile()
        if not (m7 and iR) then
            return
        end
        local m8_1 = tonumber(m7.GameAccessor:Get("SessionStart"))
        if not m8_1 or m8_1 <= 0 then
            return
        end
        local m9_1 = m7.GameAccessor:Get("PlaytimeCollected")
        if type(m9_1) ~= "table" then
            m9_1 = {}
        end
        local UnixTimestamp = DateTime.now().UnixTimestamp
        for i, v in ipairs(iR) do
            local ng = i
            if not m9_1[ng] then
                local na = tonumber(v.WaitTime) or 0
                if UnixTimestamp >= m8_1 + na then
                    pcall(function()
                        jI:Fire(ng)
                    end)
                end
            end
        end
    end
end
local oN_2_1 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = jp, Copyable = true }, "|", j6 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
j1 = {}
j1.Info = oN_2_1:AddTab("Info", "info")
j1.Combat = oN_2_1:AddTab("Combat", "swords")
j1.Battle = oN_2_1:AddTab("Battle", "shield")
j1.Progress = oN_2_1:AddTab("Progress", "trending-up")
j1.Shop = oN_2_1:AddTab("Shop", "shopping-cart")
j1.Extras = oN_2_1:AddTab("Extras", "gift")
j1.Player = oN_2_1:AddTab("Player", "user")
j1.Settings = oN_2_1:AddTab("Settings", "settings")
oN_13 = { j1.Info, j1.Combat, j1.Battle, j1.Progress, j1.Shop, j1.Extras, j1.Player, j1.Settings }
for i, v in ipairs(oN_13) do
    fn187(v)
end
iX, oN_2_2, oN_13, jH, jE, oN_8 = nil, nil, nil, nil, nil, nil
oN_12 = 7
repeat
    local oN_4_1 = (oN_12 * 1 + 0) % 3 + 1
    if oN_4_1 <= 2 then
        if oN_4_1 <= 1 then
            local oN_4_2 = {
                "sqrrcwtu",
                "vzdivadm",
                "djbq",
                "sfnlvvrodzn",
                "cdvypchaiyh",
                "qftqcomxzwl",
                "bzbjp",
                "mkxpbl",
                "eqqqlrmoxxyf",
                "fwzdx"
            }
            if oN_4_2[(oN_12 * 17 + 27) % 10 + 1] < oN_4_2[(oN_12 * 17 + 27) % 10 + 1] then
                jE = #oN_8 > 18
            else
                oN_8 = #jE > 18
            end
            oN_12 = (oN_12 + 4) % 24
        else
            local oN_4_3 = {
                "qbvrlnxtnhfd",
                "xolommnl",
                "zzauxz",
                "pwuqmoxnfx",
                "rqgjgveluy",
                "lmkrfgumsgf",
                "fxlo",
                "hpt",
                "qtu",
                "pqldfcldn",
                "wxcczvqlk",
                "zgrqgzviiht",
                "tpj"
            }
            if oN_4_3[(oN_12 * 67 + 39) % 13 + 1] < oN_4_3[(oN_12 * 67 + 39) % 13 + 1] then
                oN_13 = "Unknown"
                pcall(fn269)
                iP = (nil):AddLeftGroupbox("Account", "circle-user")
                iP:AddLabel(oN_2_2("User", jH.Name, LocalPlayer), true)
                iP:AddLabel(oN_2_2("Status", "Keyless", LocalPlayer), true)
                iP:AddLabel(oN_2_2("Executor", "Unknown", LocalPlayer), true)
                j1 = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
                j1:AddLabel(oN_5(iX .. " [" .. tostring(game.PlaceId) .. "]", i6), true)
                j1:AddLabel(oN_2_2("Place ID", tostring(game.PlaceId), i6), true)
                jd = j1:AddLabel(oN_2_2("Session time", "0s", oN_16), true)
            else
                iX = "Unknown"
                pcall(fn269)
                oN_2_2 = j1.Info:AddLeftGroupbox("Account", "circle-user")
                oN_2_2:AddLabel(i6("User", LocalPlayer.Name, oN_5), true)
                oN_2_2:AddLabel(i6("Status", "Keyless", oN_5), true)
                oN_2_2:AddLabel(i6("Executor", iX, oN_5), true)
                oN_13 = j1.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                oN_13:AddLabel(jd(j6 .. " [" .. tostring(game.PlaceId) .. "]", oN_16), true)
                oN_13:AddLabel(i6("Place ID", tostring(game.PlaceId), oN_16), true)
                jH = oN_13:AddLabel(i6("Session time", "0s", iP), true)
            end
            oN_12 = (oN_12 + 1) % 24
        end
    else
        local oN_4_4 = (vector.create((oN_12 * 6 + 5) % 11 + 1, (oN_12 * 6 + 5) % 13 + 1, (oN_12 * 2 + 2) % 17 + 1))
        local j8 = (vector.create((oN_12 * 2 + 3) % 11 + 1, (oN_12 * 5 + 1) % 13 + 1, (oN_12 * 7 + 8) % 17 + 1))
        local po = vector.cross(oN_4_4, j8)
        local pp = vector.dot(oN_4_4, j8)
        if vector.dot(po, po) + pp * pp == vector.dot(oN_4_4, oN_4_4) * vector.dot(j8, j8) + 3 then
            jH = tostring(game.JobId)
        else
            jE = tostring(game.JobId)
        end
        oN_12 = (oN_12 + 7) % 24
    end
until (oN_12 * 11 + 22) % 24 == 15
if oN_8 then
    oN_12 = 7
    repeat
        local oN_2_3 = (vector.create((oN_12 * 7 + 4) % 11 + 1, (oN_12 * 6 + 12) % 13 + 1, (oN_12 * 10 + 3) % 17 + 1))
        local oN_4_5 = (vector.create((oN_12 * 7 + 1) % 11 + 1, (oN_12 * 10 + 5) % 13 + 1, (oN_12 * 4 + 11) % 17 + 1))
        local pU = vector.dot(oN_2_3, oN_4_5)
        if pU * pU >= vector.dot(oN_2_3, oN_2_3) * vector.dot(oN_4_5, oN_4_5) + 1 then
            jE = string.sub(oN_8, 1, 18) .. "..."
        else
            oN_8 = string.sub(jE, 1, 18) .. "..."
        end
        oN_12 = (oN_12 + 7) % 8
    until (oN_12 * 5 + 0) % 8 == 6
end
oN_12 = oN_8 or jE
jk, ShopTimingGroup, iY, iT, connection, connection2, i5, i2, i1, connection3, connection4, connection5, jK, jf, i_, iM = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local ko = oN_12
oN_13:AddLabel(i6("Server", ko, oN_9), true)
oN_13:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
jk = os.clock()
task.spawn(worker)
local ScriptsGroup = j1.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(jd("Included in this hub", oN_9), true)
ScriptsGroup:AddLabel(jd(j6, oN_16), true)
local FeaturesGroup = j1.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(jd("Auto Farm", oN_16), true)
FeaturesGroup:AddLabel(jd("Battle Shop & Upgrades", oN_5), true)
FeaturesGroup:AddLabel(jd("Progression", iP), true)
FeaturesGroup:AddLabel(jd("Shop & Eggs", oN_16), true)
FeaturesGroup:AddLabel(jd("Rewards", oN_9), true)
FeaturesGroup:AddLabel(jd("Player Movement", iP), true)
local oN_4_6 = j1.Info:AddRightGroupbox("Socials", "link")
oN_4_6:AddButton({ Text = "Discord", Func = jj })
oN_4_6:AddButton({ Text = "Rscripts", Func = onRscripts })
oN_8 = j1.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
oN_8:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
oN_8:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
oN_8:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
oN_8:AddButton({ Text = "Copy Discord Invite", Func = jj })
local oN_2_4 = j1.Info:AddRightGroupbox("FAQ", "circle-help")
oN_2_4:AddLabel("Where do I get a good config?", true)
oN_2_4:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
oN_2_4:AddLabel("How do I import / export configs?", true)
oN_2_4:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
oN_2_4:AddLabel("How do I report bugs?", true)
oN_2_4:AddLabel("Join the Discord and post it in the bugs channel.", true)
oN_2_4:AddLabel("How do I make suggestions?", true)
oN_2_4:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
oN_2_4:AddLabel("How do I get help or updates?", true)
oN_2_4:AddLabel("Join the Discord, updates and support are posted there first.", true)
local DamageGroup = j1.Combat:AddLeftGroupbox("Damage", "mouse-pointer-click")
DamageGroup:AddToggle("AutoDamage", { Text = "Auto Damage (Auto Left Click)", Default = false })
DamageGroup:AddSlider("DamageDelay", { Text = "Click delay", Default = 0.1, Min = 0.05, Max = 5, Rounding = 2, Suffix = "s" })
local FarmWinsGroup = j1.Combat:AddRightGroupbox("Farm Wins", "trophy")
FarmWinsGroup:AddToggle("AutoFarmWin", {
    Text = "Auto Farm Win",
    Default = false,
    Callback = function(dO)
        pcall(function()
            jl:Fire(dO)
        end)
    end
})
local ArenaGroup = j1.Combat:AddLeftGroupbox("Arena", "castle")
ArenaGroup:AddToggle("AutoArena", { Text = "Auto Arena", Default = false })
ArenaGroup:AddSlider("ArenaDelay", { Text = "Arena delay", Default = 3, Min = 0.5, Max = 30, Rounding = 1, Suffix = "s" })
ArenaGroup:AddButton({ Text = "Go To Arena", Func = jb })
local BattleShopGroup = j1.Battle:AddLeftGroupbox("Battle Shop", "store")
BattleShopGroup:AddDropdown("BattleShopSlots", { Text = "Battle Shop Items", Values = oN_7, Multi = true, AllowNull = true, Default = {} })
BattleShopGroup:AddToggle("AutoBattleShop", { Text = "Auto Battle Shop", Default = false })
BattleShopGroup:AddSlider("BattleShopDelay", { Text = "Battle Shop delay", Default = 3, Min = 0.5, Max = 60, Rounding = 1, Suffix = "s" })
BattleShopGroup:AddButton({ Text = "Buy Now", Func = onBuyNow })
local BattleUpgradesGroup = j1.Battle:AddRightGroupbox("Battle Upgrades", "arrow-big-up-dash")
BattleUpgradesGroup:AddDropdown("BattleUpgradeKinds", { Text = "Battle Upgrades", Values = j4, Multi = true, AllowNull = true, Default = {} })
BattleUpgradesGroup:AddToggle("AutoBattleUpgrades", { Text = "Auto Battle Upgrades", Default = false })
BattleUpgradesGroup:AddSlider("BattleUpgradeDelay", { Text = "Battle Upgrade delay", Default = 3, Min = 0.5, Max = 60, Rounding = 1, Suffix = "s" })
BattleUpgradesGroup:AddButton({ Text = "Upgrade Now", Func = onUpgradeNow })
local RebirthGroup = j1.Progress:AddLeftGroupbox("Rebirth", "rotate-ccw")
RebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
RebirthGroup:AddSlider("RebirthDelay", { Text = "Rebirth delay", Default = 5, Min = 0.5, Max = 120, Rounding = 1, Suffix = "s" })
RebirthGroup:AddButton({ Text = "Rebirth Now", Func = iO })
local UnlockGroup = j1.Progress:AddRightGroupbox("Unlock", "unlock")
UnlockGroup:AddToggle("AutoUnlock", { Text = "Auto Buy Skins", Default = false })
UnlockGroup:AddLabel(jd("if you time it right you can get OP skin, it's gonna be a prison suit, so don't think it's bugged i left it like this on purpose", oN_5), true)
UnlockGroup:AddSlider("UnlockDelay", { Text = "Unlock delay", Default = 1, Min = 0.2, Max = 30, Rounding = 1, Suffix = "s" })
UnlockGroup:AddButton({ Text = "Unlock Now", Func = onUnlockNow })
local AurasGroup = j1.Shop:AddLeftGroupbox("Auras", "sparkles")
AurasGroup:AddDropdown("AuraKinds", { Text = "Auras", Values = j5, Multi = true, AllowNull = true, Default = {} })
AurasGroup:AddToggle("AutoBuyAuras", { Text = "Auto Buy Auras", Default = false })
local GlovesGroup = j1.Shop:AddRightGroupbox("Gloves", "hand")
GlovesGroup:AddToggle("AutoBuyGloves", { Text = "Auto Buy Gloves", Default = false })
GlovesGroup:AddSlider("GlovesAmount", { Text = "Gloves amount", Default = 1, Min = 1, Max = 100, Rounding = 0 })
local ItemsGroup = j1.Shop:AddLeftGroupbox("Items", "shirt")
if (not connection2 and not FarmWinsGroup or (connection2 or ItemsGroup) or (ItemsGroup and not FarmWinsGroup or ItemsGroup and not DamageGroup)) and ((FarmWinsGroup or not DamageGroup) and (FarmWinsGroup or DamageGroup) or (not ItemsGroup or DamageGroup or connection2 and not DamageGroup)) and ((FarmWinsGroup and not ItemsGroup or (connection2 or not FarmWinsGroup)) and (not ItemsGroup and not DamageGroup and (not connection2 and DamageGroup)) or (connection2 or ItemsGroup) and (not FarmWinsGroup or ItemsGroup) and (not connection2 or DamageGroup or not connection2 and DamageGroup)) and not ((not connection2 and not FarmWinsGroup or (connection2 or ItemsGroup) or (ItemsGroup and not FarmWinsGroup or ItemsGroup and not DamageGroup)) and ((FarmWinsGroup or not DamageGroup) and (FarmWinsGroup or DamageGroup) or (not ItemsGroup or DamageGroup or connection2 and not DamageGroup)) and ((FarmWinsGroup and not ItemsGroup or (connection2 or not FarmWinsGroup)) and (not ItemsGroup and not DamageGroup and (not connection2 and DamageGroup)) or (connection2 or ItemsGroup) and (not FarmWinsGroup or ItemsGroup) and (not connection2 or DamageGroup or not connection2 and DamageGroup))) then
    ShopTimingGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best Items", Default = false })
    ShopTimingGroup:AddButton({ Text = "Equip Best Now", Func = ItemsGroup })
    j1 = iS.Shop:AddRightGroupbox("Shop Timing", "timer")
else
    ItemsGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best Items", Default = false })
    ItemsGroup:AddButton({ Text = "Equip Best Now", Func = iS })
    ShopTimingGroup = j1.Shop:AddRightGroupbox("Shop Timing", "timer")
end
ShopTimingGroup:AddSlider("ShopDelay", { Text = "Shop delay", Default = 3, Min = 0.5, Max = 60, Rounding = 1, Suffix = "s" })
local EggsGroup = j1.Extras:AddLeftGroupbox("Eggs", "egg")
EggsGroup:AddDropdown("EggChoice", { Text = "Egg", Values = oN_1_4, Multi = false, AllowNull = true, Default = nil })
EggsGroup:AddToggle("AutoOpenEgg", { Text = "Auto Open Egg", Default = false })
EggsGroup:AddSlider("EggDelay", { Text = "Egg delay", Default = 1, Min = 0.2, Max = 30, Rounding = 1, Suffix = "s" })
EggsGroup:AddButton({ Text = "Open Now", Func = onOpenNow })
local RewardsGroup = j1.Extras:AddRightGroupbox("Rewards", "gift")
RewardsGroup:AddToggle("AutoDaily", { Text = "Auto Claim Daily Rewards", Default = false })
RewardsGroup:AddToggle("AutoFreeRewards", { Text = "Auto Claim Free Rewards", Default = false })
RewardsGroup:AddSlider("RewardsDelay", { Text = "Rewards delay", Default = 30, Min = 5, Max = 300, Rounding = 0, Suffix = "s" })
local MovementGroup = j1.Player:AddLeftGroupbox("Movement", "person-standing")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "Walkspeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "Walkspeed", Default = 50, Min = 16, Max = 500, Rounding = 0 })
MovementGroup:AddToggle("Noclip", { Text = "Noclip", Default = false })
MovementGroup:AddToggle("InfJump", { Text = "Inf Jump", Default = false })
local FlyGroup = j1.Player:AddRightGroupbox("Fly", "plane")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 80, Min = 16, Max = 400, Rounding = 0 })
local MenuGroup = j1.Settings:AddLeftGroupbox("Menu", "menu")
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton({ Text = "Unload", Func = onUnload })
j3:SetLibrary(Library)
j3:SetFolder("TempoHub")
j3:SaveDefault("Monochrome")
j3:ApplyToTab(j1.Settings)
j3:LoadDefault()
j2:SetLibrary(Library)
j2:IgnoreThemeSettings()
j2:SetIgnoreIndexes({ "MenuKeybind" })
j2:SetFolder("TempoHub/muscle-evolution")
j2:BuildConfigSection(j1.Settings)
j2:LoadAutoloadConfig()
iY = tick()
iT = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local nx = v
        pcall(function()
            nx:Disable()
        end)
    end
end)
jK = fn767
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
jf = fn476
if ((oN_4_6 or jk) and (oN_8 or not ko) or (ko and not oN_4_6 or not ko and jk)) and not ((oN_4_6 or jk) and (oN_8 or not ko) or (ko and not oN_4_6 or not ko and jk)) then
    i_ = false
    i5 = nil
    i2 = {}
    i1 = fn443
else
    i5 = false
    i2 = nil
    i1 = {}
    i_ = fn443
end
iM = function(eA)
    if i2 then
        i2:Disconnect()
        i2 = nil
    end
    if not eA then
        return
    end
    i2 = eA:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        local nL = i5 or Library.Unloaded or not jR("WalkSpeedEnabled")
        if nL then
            return
        end
        i_(eA)
    end)
    if jR("WalkSpeedEnabled") then
        i_(eA)
    end
end
connection3 = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
iM(jf())
connection4 = UserInputService.JumpRequest:Connect(onJumpRequest)
connection5 = RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn17)
Toggles.WalkSpeedEnabled:OnChanged(fn178)
Toggles.Noclip:OnChanged(fn821)
Library:OnUnload(fn628)
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(worker6)
task.spawn(worker7)
task.spawn(worker8)
task.spawn(worker9)
task.spawn(worker10)
task.spawn(worker11)
Library:Notify("Muscle Evolution loaded")
end)(...)

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
	local control = g.__TeekHubControl
	if not (type(control) == "table" and control.keyRequired == false) then
		local key = g.__TempoKey or g.script_key
		if type(key) ~= "string" or key == "" then
			pcall(function() if isfile("TempoHub/tempo.key") then key = readfile("TempoHub/tempo.key") end end)
		end
		key = type(key) == "string" and key:gsub("%s+", "") or ""
		local ok, why = false, "no key"
		if key ~= "" then
			local src
			pcall(function() src = game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/Key.lua?t=" .. tostring(os.time())) end)
			local fn = src and loadstring(src)
			if not fn then
				ok = true
			else
				local ran, a, b = pcall(fn, { verify = key })
				if not ran then ok = true beacon("check crashed: " .. tostring(a))
				else
					ok, why = a == true, b
					if not ok and type(why) == "string" and (why:find("reach") or why:find("try again")) then ok = true end
				end
			end
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
getgenv().TempoHoodSubtitle = "JUMP TO STEAL SCP MONSTERS!"
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
local IO_7, IO_9, IO_12, IO_20, IO_22, IO_24, IO_32, IO_35, IO_36
local uc
local uU
local vB
local uB
local ui
local u_
local t_
local vH
local uH
local uo
local u5
local t5
local RarityTexts
local vb
local uT
local vA
local uA
local vh
local uh
local uZ
local tZ
local uG
local vG
local un
local u4
local t4
local ut
local va
local ua
local uS
local vz
local uz
local vg
local ug
local uF
local vm
local um
local Plots
local t3
local uL
local Shared
local us
local u9
local t9
local uR
local uy
local vf
local uX
local vE
local uE
local vl
local ul
local u2
local t2
local ShopStands
local ur
local Guardians
local t8
local uQ
local Options
local Slimes
local ue
local uW
local vD
local tW
local Toggles
local uk
local vJ
local vq
local u7
local uP
local UserInputService
local uw
local ud
local uC
local uj
local u0
local vI
local t0
local vp
local up
local t6
local Library
local Database
local uv
local vc
function fns.fn29()
    for i, child in Guardians:GetChildren() do
        uj(child)
    end
end
function fns.fn61(eq)
    if eq == nil then
        return false
    end
    for k, v in uw do
        if v == eq then
            return true
        end
    end
    return false
end
function fns.fn108(ga)
    if not ga or not ga.model or not ga.model.Parent then
        return false
    end
    local A3_1 = vJ()
    u4()
    ud()
    u9(ga.root.Position)
    uL(ga.root.CFrame)
    task.wait(0.12)
    if uP(A3_1, ga.model) then
        return true
    end
    local A4 = ga.prompt
    if not (A4 and A4.Parent and A4.Enabled) then
        A4 = select(1, vD(ga.model))
    end
    if not A4 then
        return uP(A3_1, ga.model)
    end
    local Ba = 1
    while true do
        if not (Ba <= 4) then
            return uP(A3_1, ga.model)
        end
        local A5_1 = Library.Unloaded or not uZ("AutoSteal")
        if A5_1 then
            return false
        end
        ud()
        local A5_2 = ga.model:FindFirstChild("RootPart") or ga.model.PrimaryPart
        if A5_2 then
            uL(A5_2.CFrame)
        end
        uh(A4)
        task.wait(0.12)
        if uP(A3_1, ga.model) then
            break
        end
        local A5_3 = select(1, vD(ga.model)) or A4
        A4 = A5_3
        Ba += 1
    end
    return true
end
function fns.fn123(gu)
    if not next(gu) then
        ui = ui % #uw + 1
        return uw[ui]
    end
    local Bd = ui
    local Be = #uw
    local Bj = 1
    while Bj <= Be do
        local Be_1 = (Bd + Bj - 1) % #uw + 1
        local Bf = uw[Be_1]
        if gu[Bf] then
            ui = Be_1
            return Bf
        end
        Bj += 1
    end
    return nil
end
function fns.fn140(f2, f3)
    local AZ = vp() > 0 or uW:GetAttribute("holdingSlime") == true
    if AZ then
        return true
    end
    local A2 = if vJ() > f2 then 1 else 0
    if A2 == 1 then
        return true
    end
    if not (f3 and f3.Parent) then
        return true
    end
    return false
end
function fns.fn146()
    local Character = uW.Character
    local wV = Character and Character:FindFirstChildOfClass("Humanoid")
    return wV
end
function fns.fn160()
    local zl = {}
    local Backpack = uW:FindFirstChild("Backpack")
    local Character = uW.Character
    for k, v in { Character, Backpack } do
        if v then
            for i, child in v:GetChildren() do
                local zm_1 = child:IsA("Tool") and child:GetAttribute("slimeUID")
                if zm_1 then
                    local zm_2 = child:GetAttribute("slimeID") or child:GetAttribute("slimeId")
                    local zn_1 = vm(zm_2)
                    if u2(zn_1) then
                        zl[#zl + 1] = child
                    end
                end
            end
        end
    end
    return zl
end
function fns.fn194(fO)
    local AI = vh()
    local AJ = not AI
    local AS = if AJ then 1 else 0
    local AQ = 234 * AS + 3708 * (1 - AS)
    local AR = 2014 * AS + 3577 * (1 - AS)
    if not ((AQ * 697 + AR * 3961 + AQ * AR) % 16777213 == 8611828) then
        AJ = #fO == 0
    end
    if AJ then
        return nil
    end
    local Position = AI.Position
    local AI_1 = -1
    local AK = math.huge
    local AL
    for k, v in fO do
        local Magnitude = (v.root.Position - Position).Magnitude
        if v.rank > AI_1 or v.rank == AI_1 and Magnitude < AK then
            AL = v
            AI_1 = v.rank
            AK = Magnitude
        end
    end
    return AL
end
function fns.fn225()
    local CG = ul()
    if not CG then
        return
    end
    local CJ = Database.Rebirths[(CG.Rebirth or 0) + 1]
    if not CJ then
        return
    end
    if (CG.Jump or 0) < (CJ.JumpRequirement or math.huge) then
        return
    end
    vb("Rebirth")
end
function fns.fn252(ir, is)
    local CL = ir and type(ir.Gears) == "table"
    if not CL then
        return false
    end
    local CL_1 = tostring(is)
    if table.find(ir.Gears, CL_1) then
        return true
    end
    for k, v in ir.Gears do
        if tostring(v) == CL_1 then
            return true
        end
    end
    return false
end
function fns.fn257()
    ud()
    if Toggles.Fly and Toggles.Fly.Value then
        return
    end
    local yV_1 = vh()
    local yW = uT()
    if not yV_1 or yV_1.Anchored then
        return
    end
    local yX_1 = yV_1.AssemblyLinearVelocity
    if yX_1.Magnitude >= 45 or yV_1.AssemblyAngularVelocity.Magnitude >= 20 then
        yV_1.AssemblyLinearVelocity = Vector3.zero
        yV_1.AssemblyAngularVelocity = Vector3.zero
        yX_1 = Vector3.zero
    end
    if u_(yV_1.Position) > 32 then
        return
    end
    yV_1.AssemblyAngularVelocity = Vector3.zero
    local yY_1 = UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.ButtonA)
    if yW and not yY_1 then
        yW.Jump = false
        local yY_3 = yW:GetState()
        if yY_3 == Enum.HumanoidStateType.Jumping then
            yW:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
    local yY_4 = yX_1.Y
    local y__1 = not yY_1
    if y__1 ~= false then
        y__1 = yY_4 > 3
    end
    if y__1 then
        yY_4 = 0
    end
    local yZ_1 = Vector3.zero
    if yW then
        yZ_1 = yW.MoveDirection * (yW.WalkSpeed + 6)
    end
    local yW_1 = Vector3.new(yX_1.X, 0, yX_1.Z)
    if yZ_1.Magnitude > 1 then
        local y__2 = yZ_1.Unit * math.max(0, yW_1:Dot(yZ_1.Unit))
        if y__2.Magnitude > yZ_1.Magnitude then
            y__2 = yZ_1
        end
        yV_1.AssemblyLinearVelocity = Vector3.new(y__2.X, yY_4, y__2.Z)
    elseif yW_1.Magnitude > 4 then
        yV_1.AssemblyLinearVelocity = Vector3.new(0, yY_4, 0)
    else
        yV_1.AssemblyLinearVelocity = Vector3.new(yX_1.X, yY_4, yX_1.Z)
    end
end
function fns.fn267()
    local Cr = uz("JumpBuyAmount", "+1 Jump")
    local Cs = vG[Cr] or 1
    local Cs_1 = ul()
    if not Cs_1 then
        return
    end
    local Ct = Database.SpeedUpgrades[Cs]
    if not Ct then
        return
    end
    local Cu = uF()
    local Cu_1 = Cu and Cu.Shared or Shared
    local Cu_2 = Ct.UpgradeAmount or 1
    local Cu_3 = Cu_1.getSpeedUpgradePrice and Cu_1.getSpeedUpgradePrice(Cs_1.Jump, Ct.PriceMulti)
    if not Cu_3 then
        return
    end
    local Cu_4 = math.round(Cu_3 * Cu_2)
    if Cu_4 > (Cs_1.Cash or 0) then
        return
    end
    vb("Buy Speed Upgrade", Cs)
end
function fns.fn280()
    return vl
end
function fns.fn288(dR)
    local y1 = dR or ul()
    dR = y1
    if y1 then
        y1 = type(dR.Inventory) == "table"
    end
    if y1 then
        return #dR.Inventory
    end
    return 0
end
function fns.fn312(cE)
    local xR = cE
    if xR then
        local xS_1 = cE:FindFirstChild("RootPart") or cE.PrimaryPart
        xR = xS_1
    end
    local xS_2 = xR
    if not xS_2 then
        return nil, nil
    elseif xS_2:FindFirstChild("STEALING") then
        return nil, xS_2
    else
        local StealPrompt = xS_2:FindFirstChild("StealPrompt")
        local xT = StealPrompt and StealPrompt:IsA("ProximityPrompt") and StealPrompt.Enabled
        if xT then
            return StealPrompt, xS_2
        end
        return nil, xS_2
    end
end
function fns.fn417()
    if os.clock() - uo < 1.5 then
        return
    end
    uo = os.clock()
    for i, child in Guardians:GetChildren() do
        for i, descendant in child:GetDescendants() do
            if descendant:IsA("BasePart") then
                descendant.CanTouch = false
            end
        end
    end
end
function fns.fn431()
    local DZ = ul()
    local D_ = not DZ or type(DZ.Inventory) ~= "table"
    if D_ then
        return
    end
    local D__1 = ua("SellRarity")
    local D0 = uZ("SellLuckyBlocks")
    local D1 = uZ("SellMonsters")
    local Sell = ShopStands:FindFirstChild("Sell")
    if Sell then
        uL(Sell:GetPivot())
        task.wait(0.1)
    end
    for i, v in ipairs(DZ.Inventory) do
        local DZ_1 = uH(v, D__1, D0, D1) and v.uid
        if DZ_1 then
            vb("Sell Slime From Inventory", v.uid)
            task.wait(0.08)
        end
    end
end
function fns.fn454(e3)
    local z7 = Vector3.zero
    local z8 = 0
    for i, child in Slimes:GetChildren() do
        local z9 = child:IsA("Model") and t8(child.Name) == e3
        if z9 then
            local z9_1 = child:FindFirstChild("RootPart") or child.PrimaryPart
            if z9_1 then
                z7 += z9_1.Position
                z8 += 1
            end
        end
    end
    if z8 > 0 then
        return CFrame.new(z7 / z8)
    end
    local z7_1 = uS:FindFirstChild(e3)
    if z7_1 then
        local BasePart = z7_1:FindFirstChildWhichIsA("BasePart", true)
        if BasePart then
            return BasePart.CFrame
        end
        local z7_2 = RarityTexts:FindFirstChild(e3)
        local z8_2 = z7_2 and z7_2:IsA("BasePart")
        if z8_2 then
            return z7_2.CFrame
        end
        return nil
    end
    local z7_3 = RarityTexts:FindFirstChild(e3)
    local z8_3 = z7_3 and z7_3:IsA("BasePart")
    if z8_3 then
        return z7_3.CFrame
    end
    return nil
end
function fns.fn486()
    local Character = uW.Character
    if not Character then
        return
    end
    local Ragdolled = Character:FindFirstChild("Ragdolled")
    local yT = Ragdolled and Ragdolled:IsA("BoolValue")
    if yT then
        Ragdolled.Value = false
    end
    if Character:GetAttribute("Ragdolled") == true then
        Character:SetAttribute("Ragdolled", false)
    end
    local yR_1 = uT()
    if not yR_1 then
        return
    end
    yR_1:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    yR_1:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    local yS_1 = yR_1:GetState()
    if yS_1 == Enum.HumanoidStateType.Physics or yS_1 == Enum.HumanoidStateType.Ragdoll or yS_1 == Enum.HumanoidStateType.FallingDown then
        yR_1:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end
function fns.fn502()
    local wY_1
    local wX_1
    wX_1, wY_1 = pcall(function()
        return getrenv()._G._Lib
    end)
    local wZ = wX_1 and type(wY_1) == "table"
    if wZ then
        return wY_1
    end
    return nil
end
function fns.worker2()
    while not Library.Unloaded do
        local GP = not ur
        local GQ = uZ("AutoPlace") and GP
        if GQ then
            pcall(vf)
        end
        if uZ("AutoHatch") then
            pcall(va)
        end
        if uZ("AutoCollect") then
            pcall(u5)
        end
        task.wait(0.45)
    end
end
function fns.fn532(fo, fp)
    if not next(fp) then
        return true
    end
    local An = uv(fo)
    local Ao = fp[An] == true
    local As = if Ao then 1 else 0
    local Aq = 1417 * As + 3620 * (1 - As)
    local Ar = 2175 * As + 1956 * (1 - As)
    if not ((Aq * 2567 + Ar * 126 + Aq * Ar) % 16777213 == 6993464) then
        Ao = fp[fo] == true
    end
    return Ao
end
function fns.fn574(aE, aF)
    return string.format('<font color="%s">%s</font>', aF, aE)
end
function fns.fn586(jm, jn, jo, jp)
    if type(jm) ~= "table" then
        return false
    end
    local DS = vm(jm.id)
    local DT = u2(DS, jm)
    if DT and not jo then
        return false
    end
    local DS_2 = not jp
    local DU_1 = not DT
    if DU_1 ~= false then
        DU_1 = DS_2
    end
    if DU_1 then
        return false
    end
    return t9(vg(jm), jn)
end
function fns.fn607(jf)
    local DM = jf and jf.id
    local DN = vm(DM)
    if DN and DN.Rarity then
        return DN.Rarity
    end
    return jf and jf.rarity
end
function fns.fn625(gP)
    local Bq = -1
    local Br
    local Bs
    for k, v in t5() do
        local Bt_1 = v:GetAttribute("slimeID") or v:GetAttribute("slimeId")
        local Bu_1 = vm(Bt_1)
        if t0(Bu_1, v) then
            local Bt_3 = Shared.RarityOrders[Bu_1 and Bu_1.Rarity] or 0
            if Bt_3 > Bq then
                Bq = Bt_3
                Bs = v:GetAttribute("slimeUID")
                Br = v
            end
        end
    end
    local Bt_4 = gP and type(gP.Inventory) == "table"
    if Bt_4 then
        for i, v in ipairs(gP.Inventory) do
            local Bt_5 = vm(v.id)
            local Bu_3 = t0(Bt_5) and v.uid
            if Bu_3 then
                local Bt_6 = Shared.RarityOrders[Bt_5 and Bt_5.Rarity] or 0
                if Bt_6 > Bq then
                    Bq = Bt_6
                    Bs = v.uid
                    Br = nil
                end
            end
        end
    end
    return Bs, Br
end
function fns.fn660()
    uc(um, "Copied Discord invite to clipboard")
end
function fns.fn665(hG)
    local Cd = tZ()
    local Ce = Cd and Cd:FindFirstChild("CollectPads")
    local Cd_1 = Ce
    if Ce then
        Ce = Cd_1:FindFirstChild(tostring(hG))
    end
    local Cd_2 = Ce
    if Ce then
        Ce = Cd_2:FindFirstChild("Top")
    end
    local Cd_3 = Ce
    if Ce then
        Ce = Cd_3:FindFirstChild("PadGui")
    end
    local Cd_4 = Ce
    if Ce then
        Ce = Cd_4.Enabled
    end
    if not Ce then
        return false
    end
    local Earnings = Cd_4:FindFirstChild("Earnings", true)
    local Cd_5 = Earnings and Earnings:IsA("TextLabel")
    if not Cd_5 then
        return true
    end
    local Cd_6 = Earnings.Text or ""
    local Ce_2 = tostring(Cd_6)
    return Ce_2 ~= "" and Ce_2 ~= "$0" and Ce_2 ~= "0" and Ce_2 ~= "$0.0"
end
function fns.fn682(fu, fv)
    local Ay_2
    local Ax_2
    local At = {}
    local Au = next(fu) ~= nil
    for i, child in Slimes:GetChildren() do
        if child:IsA("Model") then
            local Av = t8(child.Name)
            if not Au or fu[Av] then
                local Aw_1 = child:GetAttribute("rarity")
                if Aw_1 == nil then
                    local Ax_1 = vm(child:GetAttribute("slimeId"))
                    Aw_1 = Ax_1 and Ax_1.Rarity
                end
                if t9(Aw_1, fv) then
                    Ay_2, Ax_2 = vD(child)
                    if Ay_2 and Ax_2 then
                        local Az_1 = #At + 1
                        local AA = Shared.RarityOrders[Aw_1] or 0
                        At[Az_1] = { model = child, prompt = Ay_2, root = Ax_2, zone = Av, rank = AA }
                    end
                end
            end
        end
    end
    return At
end
function fns.fn690(cW)
    if not cW then
        return
    end
    for i, descendant in cW:GetDescendants() do
        uy(descendant)
    end
end
local function fn695(aH, aI, aJ)
    return string.format("<b>%s</b> %s %s", aH, vA("-", "#5a6070"), vA(aI, aJ))
end
local function fn697()
    local Character = uW.Character
    local wS = Character and Character:FindFirstChild("HumanoidRootPart")
    return wS
end
local function fn707()
    local Al = un()
    if not Al then
        return false
    end
    uL(Al)
    task.wait(0.15)
    uL(Al)
    return true
end
local function fn733()
    local Eq = uz("SellFrom", "Both")
    if Eq == "Inventory" or Eq == "Both" then
        vI()
    end
    local Er_1 = Eq == "Both"
    local Es_1 = Eq == "Stands"
    local Ew = if Es_1 then 1 else 0
    local Eu = 686 * Ew + 1719 * (1 - Ew)
    local Ev = 500 * Ew + 2429 * (1 - Ew)
    if not ((Eu * 2895 + Ev * 2163 + Eu * Ev) % 16777213 == 3410470) then
        Es_1 = Er_1
    end
    if Es_1 then
        ut()
    end
end
local function fn744()
    local Ci = ul()
    local Cj = not Ci or type(Ci.PlotSlimes) ~= "table"
    if Cj then
        return
    end
    for k, v in Ci.PlotSlimes do
        if type(v) == "table" then
            local Ci_1 = vm(v.id)
            if not u2(Ci_1, v) then
                local Ci_2 = tonumber(v.earnings) or 0
                local Ci_3 = Ci_2 > 0 or up(k)
                if Ci_3 then
                    vb("Collect Earnings", tostring(k))
                end
            end
        end
    end
end
local function worker3()
    while not Library.Unloaded do
        if uZ("AutoEquipBest") then
            pcall(u7)
        end
        if uZ("AutoBuyCoil") then
            pcall(t6)
        end
        if uZ("AutoUpgradeJump") then
            pcall(t4)
        end
        if uZ("AutoUpgradeCarry") then
            pcall(uA)
        end
        if uZ("AutoRebirth") then
            pcall(t_)
        end
        local GS = not ur
        local GT = uZ("AutoSell") and GS
        if GT then
            pcall(u0)
        end
        task.wait(1)
    end
end
local function fn761()
    local y6 = tonumber(uW:GetAttribute("holdingSlimeCount"))
    if y6 ~= nil then
        return y6
    end
    local za = if uW:GetAttribute("holdingSlime") == true then 1 else 0
    if za == 1 then
        return 1
    end
    return 0
end
local function fn808()
    local xz_1
    local xy_1
    xy_1, xz_1 = pcall(function()
        return getrenv()._G.MyPlot
    end)
    if xy_1 and xz_1 and xz_1.Parent then
        return xz_1
    end
    for i, child in Plots:GetChildren() do
        local owner = child:FindFirstChild("owner")
        if owner and owner.Value == uW.Name then
            return child
        end
    end
    return nil
end
local function fn840(iy)
    local CW = uF()
    local CX = CW and CW.Settings
    local CW_1 = CX
    if CX then
        CX = CW_1.InventoryLimits
    end
    if CX then
        CX = CW_1.InventoryLimits.Gears
    end
    local CW_2 = CX
    if not CW_2 then
        return false
    end
    local CX_1 = iy
    local CY = 0
    if CX_1 then
        CX_1 = type(iy.Gears) == "table"
    end
    if CX_1 then
        CY = #iy.Gears
    end
    return CY >= CW_2
end
local function fn856(dZ)
    local zc = dZ and dZ.CarryLevel
    local zd = tonumber(zc) or 1
    return math.max(1, zd)
end
local function fn886(kV)
    local DiscordGroup = kV:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = tW })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = tW })
end
local function fn922()
    local B4 = ul()
    local B5 = not B4 or type(B4.PlotSlimes) ~= "table"
    if B5 then
        return
    end
    for k, v in B4.PlotSlimes do
        if type(v) == "table" then
            local B4_1 = vm(v.id)
            if u2(B4_1, v) then
                vb("Open Lucky Block", tostring(k))
                task.wait(0.18)
            end
        end
    end
end
local function fn925(cr)
    local xJ = vh()
    local xK = not xJ
    local xO = if xK then 1 else 0
    local xM = 3497 * xO + 3460 * (1 - xO)
    local xN = 3354 * xO + 1884 * (1 - xO)
    if not ((xM * 1207 + xN * 1573 + xM * xN) % 16777213 == 4448446) then
        xK = typeof(cr) ~= "CFrame"
    end
    if xK then
        return false
    end
    u9(cr.Position)
    xJ.AssemblyLinearVelocity = Vector3.zero
    xJ.AssemblyAngularVelocity = Vector3.zero
    xJ.CFrame = cr + Vector3.new(0, 3, 0)
    return true
end
local function fn942()
    local CB = ul()
    if not CB then
        return
    end
    local CE = Database.CarryLevelPrices[CB.CarryLevel or 1]
    local CC_1 = not CE
    if not CC_1 then
        CC_1 = (CB.Cash or 0) < CE
    end
    if CC_1 then
        return
    end
    vb("Upgrade Carry Limit")
end
local function fn964()
    local EQ_1
    local EP_1
    if ur then
        return
    end
    ur = true
    EP_1, EQ_1 = pcall(function()
        if uE() then
            uk()
        end
        local EF = uU() or uE()
        if EF then
            return
        end
        local EF_1 = ua("StealZone")
        local EG = ua("StealRarity")
        local EH = vB(EF_1, EG)
        local EI = t3(EH)
        if not EI then
            local EJ = uG(EF_1)
            local EK = EJ and vH(EJ)
            if EK then
                u4()
                uL(EK)
                task.wait(0.35)
                local EH_1 = vB(EF_1, EG)
                EI = t3(EH_1)
            end
        end
        if EI then
            ue(EI)
        end
        if uE() then
            uk()
        end
    end)
    ur = false
    if not EP_1 then
        warn("[Auto Steal] " .. tostring(EQ_1))
    end
end
local function fn1009()
    local Ea = ul()
    local Eb = not Ea or type(Ea.PlotSlimes) ~= "table"
    if Eb then
        return
    end
    local Eb_1 = ua("SellRarity")
    local Ec = uZ("SellLuckyBlocks")
    local Ed = uZ("SellMonsters")
    local Ee = uZ("AutoHatch")
    for k, v in Ea.PlotSlimes do
        if type(v) == "table" then
            local Ea_1 = vm(v.id)
            local Ef = Ee and u2(Ea_1, v)
            if not Ef then
                local Ep = if uH(v, Eb_1, Ec, Ed) then 1 else 0
                if Ep == 1 then
                    vb("Sell Slime From Stand", tostring(k))
                    task.wait(0.12)
                end
            end
        end
    end
end
local function fn1041()
    if not uE() then
        return true
    elseif not us() then
        return false
    else
        local EC = os.clock() + 5
        while true do
            if not (os.clock() < EC) then
                return not uE()
            end
            local ED = Library.Unloaded or not uZ("AutoSteal")
            if ED then
                return false
            end
            if not uE() then
                break
            end
            us()
            task.wait(0.12)
        end
        return true
    end
end
local function fn1046()
    local Character = uW.Character
    if not Character then
        return nil
    end
    local Tool = Character:FindFirstChildWhichIsA("Tool")
    local zi_1 = Tool and Tool:GetAttribute("slimeUID")
    if zi_1 then
        return Tool
    end
    return nil
end
local function fn1050(gC, gD)
    local Bn_3
    if not u2(gC) then
        return false
    end
    local Bm = ua("PlaceZone")
    if next(Bm) then
        local Bn_1 = uB(gC, gD)
        if not Bm[Bn_1] then
            return false
        end
        local Bm_1 = ua("PlaceRarity")
        if Bn_3 then
            local Bo_1 = gC and gC.Rarity
            local Bn_2 = not t9(Bo_1, Bm_1)
        end
        if Bn_3 then
            return false
        end
        return true
    end
    local Bm_2 = ua("PlaceRarity")
    Bn_3 = (next(Bm_2))
    if Bn_3 then
        local Bo_2 = gC and gC.Rarity
        Bn_3 = not t9(Bo_2, Bm_2)
    end
    if Bn_3 then
        return false
    end
    return true
end
local function fn1051(iS)
    local Dc = iS.speed
    local Dh = if Dc then 1 else 0
    local Df = 425 * Dh + 179 * (1 - Dh)
    local Dg = 2221 * Dh + 144 * (1 - Dh)
    if not ((Df * 3778 + Dg * 749 + Df * Dg) % 16777213 == 4213104) then
        Dc = 0
    end
    local Dd = iS.jump
    local Dh_1 = if Dd then 1 else 0
    local Df_1 = 145 * Dh_1 + 1577 * (1 - Dh_1)
    local Dg_1 = 1515 * Dh_1 + 2552 * (1 - Dh_1)
    if not ((Df_1 * 1063 + Dg_1 * 3535 + Df_1 * Dg_1) % 16777213 == 5729335) then
        Dd = 0
    end
    return Dc + Dd * 2
end
local function fn1057()
    local C2 = ul()
    if not C2 then
        return
    end
    local C3 = C2.Cash or 0
    for k, v in vz do
        if not vq(C2, v.id) then
            if uQ(C2) then
                return
            end
            if C3 >= v.price then
                vb("Buy Gear", v.id, "Buy")
                return
            end
        end
    end
end
local function fn1072(aM)
    if Library.Unloaded then
        return false
    end
    local wx = Toggles[aM]
    return wx ~= nil and wx.Value == true
end
local function worker()
    while not Library.Unloaded do
        if uZ("AutoSteal") then
            pcall(vE)
            task.wait(0.18)
        else
            task.wait(0.35)
        end
    end
end
local function fn1106(al, am)
    return al.price < am.price
end
local function fn1141(eC, eD)
    local zK = not eC or not eC:FindFirstChild("Main")
    if zK then
        return false
    end
    local zK_1 = tonumber(eC.Name)
    if not zK_1 then
        return false
    elseif zK_1 <= 10 then
        return true
    else
        return zK_1 - 10 <= (eD or 0)
    end
end
local function fn1153()
    local z0 = tZ()
    local z0_2
    if z0 then
        local Base = z0:FindFirstChild("Base")
        local z2 = Base and Base:IsA("BasePart")
        if z2 then
            return Base.CFrame
        end
        local z6 = if z0:IsA("Model") then 1 else 0
        if z6 == 1 then
            return z0:GetPivot()
        end
        local z0_1 = uC and uC:IsA("BasePart")
        if z0_2 then
            return uC.CFrame
        end
        return nil
    end
    z0_2 = uC and uC:IsA("BasePart")
    if z0_2 then
        return uC.CFrame
    end
    return nil
end
local function fn1158(aS, aT)
    local wA = Options[aS]
    if wA == nil then
        return aT
    end
    return wA.Value
end
local function fn1174(bY, bZ)
    if bY and bY.Type == "Lucky Block" then
        return true
    end
    local xo_1 = type(bZ) == "table"
    if xo_1 then
        local xp = bZ.type == "Lucky Block"
        local xt = if xp then 1 else 0
        local xr = 630 * xt + 2103 * (1 - xt)
        local xs = 1832 * xt + 2268 * (1 - xt)
        if not ((xr * 3867 + xs * 3566 + xr * xs) % 16777213 == 10123282) then
            xp = bZ.production_is_lucky_block == true
        end
        xo_1 = xp
    end
    if xo_1 then
        return true
    end
    return false
end
local function fn1176(bU)
    if bU == nil then
        return nil
    end
    local xj = Database.Slimes[bU] or Database.Slimes[tostring(bU)]
    return xj
end
local function fn1189(ev, ew)
    local zI_3
    if ew then
        local zI_1 = t8(ew.Name)
        if uX(zI_1) then
            return zI_1
        elseif type(ev) == "table" then
            local zI_2 = t8(ev.Name)
            if uX(zI_3) then
                return zI_2
            elseif uX(ev.Rarity) then
                return ev.Rarity
            else
                return zI_2
            end
        else
            return nil
        end
    elseif type(ev) == "table" then
        zI_3 = t8(ev.Name)
        if uX(zI_3) then
            return zI_3
        elseif uX(ev.Rarity) then
            return ev.Rarity
        else
            return zI_3
        end
    else
        return nil
    end
end
local function fn1218(b9)
    local xw = b9 or ""
    return tostring(xw):gsub(" Lucky Block", "")
end
local function fn1236(b4)
    if b4 == nil then
        return nil
    end
    local xu = ug[b4] or Shared.RARITY_DISPLAY[b4] or tostring(b4)
    return xu
end
local function fn1239(cT)
    local ya = not cT or not cT:IsA("BasePart")
    if ya then
        return
    end
    cT.CanTouch = false
    cT.CanCollide = false
end
local function fn1269()
    local Ex = vp() > 0
    local EB = if Ex then 1 else 0
    local Ez = 2718 * EB + 2658 * (1 - EB)
    local EA = 1064 * EB + 221 * (1 - EB)
    if not ((Ez * 1934 + EA * 423 + Ez * EA) % 16777213 == 8598636) then
        Ex = uW:GetAttribute("holdingSlime") == true
    end
    return Ex
end
local function fn1270(ax, ay)
    if setclipboard then
        setclipboard(ax)
    elseif toclipboard then
        toclipboard(ax)
    end
    Library:Notify(ay)
end
local function fn1276(d1)
    local zf = vp()
    local zg = d1 or ul()
    return zf >= vc(zg)
end
local function fn1282(aX)
    local wF = uz(aX, {})
    if typeof(wF) ~= "table" then
        return {}
    end
    local wG = {}
    for k, v in wF do
        if v == true then
            wG[k] = true
        else
            local wF_1 = typeof(k) == "number" and typeof(v) == "string"
            if wF_1 then
                wG[v] = true
            end
        end
    end
    return wG
end
local function fn1291(eH)
    local zR = tZ()
    if not (zR and eH) then
        return nil
    end
    local Stands = zR:FindFirstChild("Stands")
    if not Stands then
        return nil
    end
    local PlotSlimes = eH.PlotSlimes
    if type(PlotSlimes) ~= "table" then
        return nil
    end
    local children = Stands:GetChildren()
    table.sort(children, function(eN, eO)
        local zO = tonumber(eN.Name) or math.huge
        local zP = tonumber(eO.Name) or math.huge
        return zO < zP
    end)
    for k, v in children do
        local zS_2 = v:IsA("Model") and t2(v, eH.BaseLevel)
        if zS_2 then
            local zS_3 = not PlotSlimes[v.Name]
            if zS_3 ~= false then
                zS_3 = not PlotSlimes[tostring(v.Name)]
            end
            if zS_3 then
                return v
            end
        end
    end
    return nil
end
tW = nil
tZ = nil
t_ = nil
t0 = nil
t2 = nil
t3 = nil
t4 = nil
t5 = nil
t6 = nil
t8 = nil
t9 = nil
ua = nil
uc = nil
ud = nil
ue = nil
ug = nil
uh = nil
ui = nil
uj = nil
uk = nil
ul = nil
um = nil
un = nil
uo = nil
up = nil
ur = nil
us = nil
ut = nil
uv = nil
uw = nil
Options = nil
uy = nil
uz = nil
uA = nil
uB = nil
uC = nil
Toggles = nil
uE = nil
uF = nil
uG = nil
local tU, tV, tX, tY, t1, t7, ub, uf, uq, uu
uH = nil
local uJ
ShopStands = nil
uL = nil
RarityTexts = nil
Library = nil
uP = nil
uQ = nil
uR = nil
uS = nil
uT = nil
uU = nil
uW = nil
uX = nil
uZ = nil
u_ = nil
u0 = nil
u2 = nil
Plots = nil
u4 = nil
u5 = nil
u7 = nil
Guardians = nil
u9 = nil
va = nil
vb = nil
vc = nil
Slimes = nil
vf = nil
vg = nil
vh = nil
vl = nil
vm = nil
vp = nil
vq = nil
Shared = nil
local SaveManager, ThemeManager, uV, uY, u1, u6, vd, vi, vj, vk, vn, vo, vr, vt
Database = nil
UserInputService = nil
vz = nil
vA = nil
vB = nil
vD = nil
vE = nil
vG = nil
vH = nil
vI = nil
vJ = nil
local vu, Remotes, vy, vC, vF
vu = nil
Remotes = nil
vy = nil
vC = nil
vF = nil
tU, IO_32, vC, UserInputService, vu, vr, vl, vj, vd, u6, u1, uW, uR = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local IO_5 = 30
repeat
    IO_20 = (IO_5 * 1 + 3) % 6 + 1
    if IO_20 <= 3 then
        if IO_20 <= 2 then
            if IO_20 <= 1 then
                if (IO_5 * 2 + 3) * 4 % 3 == ((IO_5 * 2 + 3) * 4 + 3) % 3 then
                    vu = game:GetService("VirtualUser")
                    vr = game:GetService("HttpService")
                else
                    vr = game:GetService("VirtualUser")
                    vu = game:GetService("HttpService")
                end
                IO_5 = (IO_5 + 31) % 48
            else
                if ((not u1 or vC or (not vu or vu)) and ((not u1 or vu) and (vC and u1)) or (not u1 or vC or (vu or not u1) or (vu and vu or vC and not vu))) and ((not u1 and u1 or vu and u1 or (vC and vu or not u1 and u1)) and ((vC or not vu) and (vu or vu) or not vu and u1 and (vC and u1))) and not (((not u1 or vC or (not vu or vu)) and ((not u1 or vu) and (vC and u1)) or (not u1 or vC or (vu or not u1) or (vu and vu or vC and not vu))) and ((not u1 and u1 or vu and u1 or (vC and vu or not u1 and u1)) and ((vC or not vu) and (vu or vu) or not vu and u1 and (vC and u1)))) then
                    vj = game:GetService("CoreGui")
                    vl = game:GetService("GuiService")
                else
                    vl = game:GetService("CoreGui")
                    vj = game:GetService("GuiService")
                end
                IO_5 = (IO_5 + 1) % 48
            end
        else
            local JD = bit32.rrotate(bit32.bxor(bit32.lrotate(IO_5, 4), string.byte(tostring(vd))), 8)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(JD, 1607499341), 1293660136), (bit32.bxor(bit32.band(JD, 2687467954), 1579211110))), 1293660136), 1579211110) == JD then
                vd = game:GetService("TeleportService")
                u6 = game:GetService("Lighting")
                u1 = game:GetService("Workspace")
                uW = tU.LocalPlayer
                uR = fns.fn280
            else
                uR = game:GetService("TeleportService")
                uW = game:GetService("Lighting")
                u6 = game:GetService("Workspace")
                vd = u1.LocalPlayer
                tU = fns.fn280
            end
            IO_5 = (IO_5 + 13) % 48
        end
    elseif IO_20 <= 5 then
        if IO_20 <= 4 then
            IO_20 = (vector.create((IO_5 * 3 + 2) % 11 + 1, (IO_5 * 1 + 13) % 13 + 1, (IO_5 * 12 + 14) % 17 + 1))
            IO_7 = (vector.create((IO_5 * 2 + 5) % 11 + 1, (IO_5 * 11 + 6) % 13 + 1, (IO_5 * 1 + 5) % 17 + 1))
            IO_35 = (vector.create((IO_5 * 3 + 9) % 11 + 1, (IO_5 * 11 + 9) % 13 + 1, (IO_5 * 6 + 2) % 17 + 1))
            IO_22 = (vector.create((IO_5 * 6 + 9) % 11 + 1, (IO_5 * 2 + 8) % 13 + 1, (IO_5 * 1 + 6) % 17 + 1))
            if vector.dot(vector.cross(IO_20, IO_7), (vector.cross(IO_35, IO_22))) == vector.dot(IO_20, IO_35) * vector.dot(IO_7, IO_22) - vector.dot(IO_20, IO_22) * vector.dot(IO_7, IO_35) + 5 then
                vj = game:GetService("Players")
            else
                tU = game:GetService("Players")
            end
            IO_5 = (IO_5 + 37) % 48
        else
            IO_20 = (vector.create((IO_5 * 2 + 3) % 11 + 1, (IO_5 * 9 + 4) % 13 + 1, (IO_5 * 10 + 11) % 17 + 1))
            IO_7 = (vector.create((IO_5 * 2 + 4) % 11 + 1, (IO_5 * 11 + 9) % 13 + 1, (IO_5 * 10 + 17) % 17 + 1))
            local Kh = vector.cross(IO_20, IO_7)
            local Ki = vector.dot(IO_20, IO_7)
            if vector.dot(Kh, Kh) + Ki * Ki == vector.dot(IO_20, IO_20) * vector.dot(IO_7, IO_7) + 1 then
                vC = game:GetService("ReplicatedStorage")
                IO_32 = game:GetService("RunService")
            else
                IO_32 = game:GetService("ReplicatedStorage")
                vC = game:GetService("RunService")
            end
            IO_5 = (IO_5 + 19) % 48
        end
    else
        if IO_5 * 104384749 + 10 + 3 >= IO_5 * 104384749 + 10 + 3 + 1 then
            vd = game:GetService("UserInputService")
        else
            UserInputService = game:GetService("UserInputService")
        end
        IO_5 = (IO_5 + 31) % 48
    end
until (IO_5 * 35 + 11) % 48 == 17
if getgenv then
    uJ, IO_20 = nil, nil
    IO_5 = 6
    repeat
        IO_7 = (IO_5 * 1 + 0) % 2 + 1
        if IO_7 <= 1 then
            if not uJ and uJ or uJ and not IO_20 or (uJ and not uJ or not IO_20 and IO_20) or not (not uJ and uJ or uJ and not IO_20 or (uJ and not uJ or not IO_20 and IO_20)) then
                getgenv().gethui = uR
                uJ = getgenv().__TempoJumpToStealSCPLib
            else
                getgenv().gethui = uJ
                uR = getgenv().__TempoJumpToStealSCPLib
            end
            IO_5 = (IO_5 + 5) % 16
        else
            IO_7 = {
                "qzerqfpsrvpe",
                "xpyy",
                "kymp",
                "dolgurrts",
                "pyunvppiv",
                "xhxj",
                "ptmnefwyhmy",
                "xfgmry",
                "daqjsfckpk",
                "sispnvua",
                "nmxyqnvccai"
            }
            if IO_7[(IO_5 * 94 + 7) % 11 + 1] <= IO_7[(IO_5 * 94 + 7) % 11 + 1] then
                IO_20 = uJ
            else
                uJ = IO_20
            end
            IO_5 = (IO_5 + 9) % 16
        end
    until (IO_5 * 11 + 9) % 16 == 5
    if IO_20 then
        IO_20 = uJ.Unload
    end
    if IO_20 then
        pcall(function()
            uJ:Unload()
        end)
    end
end
pcall(function()
    gethui = uR
end)
if setthreadidentity then
    setthreadidentity(8)
end
uq, um, uf, ub, t7, t1, tY, tV, vF, Remotes, Database, Shared, vn, Slimes, Guardians, Plots, IO_5, uS, RarityTexts, ShopStands, IO_22 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
uq = "Jump To Steal SCP Monsters"
um = "https://discord.gg/K7Qxnxkk46"
uf = "https://discord.gg/K7Qxnxkk46"
ub = "https://tempohub.shop"
t7 = "#7fd47f"
t1 = "#6ec1ff"
tY = "#e8a34d"
tV = "#8b93a3"
if not Plots or not Database or (IO_5 or not Plots) or Plots and IO_5 and (not Plots or Plots) or not (not Plots or not Database or (IO_5 or not Plots) or Plots and IO_5 and (not Plots or Plots)) then
    vF = "#e05a5a"
else
    uS = "#e05a5a"
end
IO_35 = IO_32:WaitForChild("SharedModules")
Remotes = IO_35:WaitForChild("Network"):WaitForChild("Remotes")
Database = require(IO_35:WaitForChild("Database"))
Shared = require(IO_35:WaitForChild("Shared"))
if ((not Remotes or not vn) and (Remotes and tV) or (false or not Remotes) and (Remotes and vn)) and (Remotes or false or (false or vn) or (false and not Remotes or vF and vn)) or "#e05a5a" and (false and not vn or "#8b93a3") and (vn and vF and (vF or not vn) or ("#e05a5a" or Remotes and tV)) or not (((not Remotes or not vn) and (Remotes and tV) or (false or not Remotes) and (Remotes and vn)) and (Remotes or false or (false or vn) or (false and not Remotes or vF and vn)) or "#e05a5a" and (false and not vn or "#8b93a3") and (vn and vF and (vF or not vn) or ("#e05a5a" or Remotes and tV))) then
    vn = require(IO_35:WaitForChild("DataService"))
    IO_7 = u1:WaitForChild("Live")
    Slimes = IO_7:WaitForChild("Slimes")
    Guardians = IO_7:WaitForChild("Guardians")
else
    require(Slimes:WaitForChild("DataService"))
    u1 = Guardians:WaitForChild("Live")
    u1:WaitForChild("Slimes")
    vn = u1:WaitForChild("Guardians")
end
Plots = u1:WaitForChild("Plots")
IO_5 = u1:WaitForChild("Map")
uS = IO_5:WaitForChild("SpawnParts")
RarityTexts = IO_5:WaitForChild("RarityTexts")
ShopStands = IO_5:WaitForChild("ShopStands")
if (false or Slimes and not Slimes and "https://tempohub.shop" or "https://tempohub.shop" and (false and Slimes) and (tY or not Slimes or false)) and not (false or Slimes and not Slimes and "https://tempohub.shop" or "https://tempohub.shop" and (false and Slimes) and (tY or not Slimes or false)) then
    u1 = (IO_22:FindFirstChild("Regions"))
else
    IO_22 = (u1:FindFirstChild("Regions"))
end
if IO_22 then
    IO_5 = 0
    repeat
        if IO_5 * 32880533 + 7 + 4 <= IO_5 * 32880533 + 7 + 4 + 1 then
            IO_22 = u1.Regions:FindFirstChild("SafeZone")
        else
            u1 = IO_22.Regions:FindFirstChild("SafeZone")
        end
        IO_5 = (IO_5 + 0) % 4
    until (IO_5 * 3 + 0) % 4 == 0
end
uC, uw, IO_7, ug = nil, nil, nil, nil
if (not uw or uw) and (uw and 23) or (not uw and not IO_7 or (uw or 23)) or not ((not uw or uw) and (uw and 23) or (not uw and not IO_7 or (uw or 23))) then
    uC = IO_22
    uw = {
        "Common",
        "Rare",
        "Epic",
        "Legendary",
        "Mythic",
        "Secret",
        "Slime God",
        "OG",
        "Champions",
        "Spain",
        "Icons",
        "Japan",
        "Water",
        "Volcanic",
        "Ghost",
        "67",
        "Rainbow",
        "Cosmic",
        "Poison",
        "US",
        "Prime",
        "Limited",
        "Nightmare",
        "Apocalypse",
        "Meltdown",
        "Oblivion"
    }
    IO_7 = {
        "Common",
        "Uncommon",
        "Rare",
        "Epic",
        "Legendary",
        "Secret",
        "Godly",
        "Celestial",
        "Prime",
        "Ultimate",
        "Nightmare",
        "Apocalypse",
        "Meltdown",
        "Oblivion",
        "Limited"
    }
else
    IO_7 = uC
    uw = {
        "Legendary",
        "Meltdown",
        "Uncommon",
        "Prime",
        "Ultimate",
        "Godly",
        "Celestial",
        "Common",
        "Apocalypse",
        "Epic",
        "Nightmare",
        "Oblivion",
        "Rare",
        "Secret",
        "Limited"
    }
end
IO_20 = {
    Common = "Common",
    Uncommon = "Rare",
    Rare = "Epic",
    Epic = "Legendary",
    Legendary = "Mythic",
    Secret = "Secret",
    Godly = "Slime God",
    Celestial = "Divine",
    Prime = "Exclusive",
    Ultimate = "OG",
    Nightmare = "Champions",
    Apocalypse = "Spain",
    Meltdown = "Icons",
    Oblivion = "Japan",
    Limited = "LIMITED"
}
ug = {}
for k, v in IO_20 do
    ug[v] = k
end
for k, v in Shared.RARITY_DISPLAY do
    ug[k] = v
end
IO_32, vG, IO_20, vz = nil, nil, nil, nil
IO_5 = 1
repeat
    IO_35 = (IO_5 * 1 + 0) % 2 + 1
    if IO_35 <= 1 then
        IO_35 = {
            "fhvea",
            "bxby",
            "mjawqwg",
            "yxtdex",
            "ihiyhimsf",
            "iqodf",
            "iriqfrrjmxy",
            "kpoipqs",
            "sjfhty",
            "ywjgkfjr"
        }
        local KJ = IO_5
        IO_22 = IO_35[KJ % 10 + 1]
        if IO_22:len() <= IO_22:reverse():rep(KJ % 3 + 2):len() then
            vG = { ["+1 Jump"] = 1, ["+5 Jump"] = 2, ["+10 Jump"] = 3 }
            IO_20 = { "Inventory", "Stands", "Both" }
            vz = {}
        else
            IO_20 = { ["+5 Jump"] = 2, ["+10 Jump"] = 3, ["+1 Jump"] = 1 }
            vz = { "Stands", "Both", "Inventory" }
            vG = {}
        end
        IO_5 = (IO_5 + 5) % 8
    else
        local KT = bit32.rrotate(bit32.bxor(bit32.lrotate(IO_5, 31), string.byte(tostring(vG))), 20)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(KT, 1125546155), 4017176470), (bit32.bxor(bit32.band(KT, 3169421140), 4163603513))), 4017176470), 4163603513) ~= KT then
            IO_20 = { "+10 Jump", "+1 Jump", "+5 Jump" }
        else
            IO_32 = { "+1 Jump", "+5 Jump", "+10 Jump" }
        end
        IO_5 = (IO_5 + 1) % 8
    end
until (IO_5 * 3 + 1) % 8 == 6
for k, v in Database.Gears do
    IO_5 = type(v) == "table" and v.Category == "Coil" and v.Price
    if IO_5 then
        IO_5 = v.Tool
        IO_35 = #vz + 1
        IO_22 = tostring(k)
        IO_9 = v.Name
        IO_36 = v.Price
        IO_24 = IO_5 and tonumber(IO_5:GetAttribute("speedBoost"))
        IO_12 = IO_24 or 0
        IO_24 = IO_5 and tonumber(IO_5:GetAttribute("jumpBoost"))
        IO_5 = IO_24
        local IO_6 = if IO_5 then 1 else 0
        local IO_31 = 2298 * IO_6 + 772 * (1 - IO_6)
        local IO_18 = 3133 * IO_6 + 1373 * (1 - IO_6)
        if not ((IO_31 * 531 + IO_18 * 1991 + IO_31 * IO_18) % 16777213 == 14657675) then
            IO_5 = 0
        end
        vz[IO_35] = { id = IO_22, name = IO_9, price = IO_36, speed = IO_12, jump = IO_5 }
    end
end
table.sort(vz, fn1106)
Library, ThemeManager, SaveManager = nil, nil, nil
Library = getgenv().Library
ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
if getgenv then
    getgenv().__TempoJumpToStealSCPLib = Library
end
Toggles, Options, ur, uo, ui, vi, uV, uc, tW, vA, vo, uZ, uz, ua, vh, uT, uF, ul, vb, vm, u2, uv, t8, tZ, u9, uL, uh, vD, u4, uy, uj, tX, u_, ud, vt, vJ, vp, vc, uU, uu, t5, uX, uB, t2, vy, un, vH, us, t9, vB, t3, uP, ue, uG, t0, uY, vf, va, up, u5, t4, uA, t_, vq, uQ, t6, vk, u7, vg, uH, vI, ut, u0, uE, uk, vE = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Toggles = Library.Toggles
Options = Library.Options
ur = false
uo = 0
ui = 1
uc = fn1270
if (uo and not uo and (vh and vh) or not uo and not vh and (vh or not vh)) and not (uo and not uo and (vh and vh) or not uo and not vh and (vh or not vh)) then
    vA = fns.fn660
    tW = fns.fn574
else
    tW = fns.fn660
    vA = fns.fn574
end
vo = fn695
uZ = fn1072
uz = fn1158
ua = fn1282
vh = fn697
uT = fns.fn146
uF = fns.fn502
ul = function()
    local w3_3
    local w2_1, w2_2, w2_3
    local w0 = uF()
    local w1 = w0 and w0.Data and w0.Data.Get
    local w1_1, w1_2, w1_3
    if w1 then
        w1_1, w2_1 = pcall(function()
            return w0.Data:Get()
        end)
        local w3_1 = w1_1 and type(w2_1) == "table"
        if w3_1 then
            return w2_1
        end
        w1_2, w2_2 = pcall(function()
            return vn.client:get()
        end)
        if w3_3 then
            return w2_2
        end
        return nil
    end
    w1_3, w2_3 = pcall(function()
        return vn.client:get()
    end)
    w3_3 = w1_3 and type(w2_3) == "table"
    if w3_3 then
        return w2_3
    end
    return nil
end
vi = {}
vb = function(bx, ...)
    local w9
    local xa
    local xc
    local xd_3, xd_8, xd_9, xd_10
    local w8 = { ... }
    local xb = vi[bx]
    if xb then
        local xd_1 = pcall(function()
            xb:Fire(table.unpack(w8))
        end)
        if xd_1 then
            return true
        end
        vi[bx] = nil
        w9 = uF()
        if xd_8 then
            xd_3, xc = pcall(function()
                return w9.Network.new(bx, "RemoteEvent")
            end)
            if xd_3 and xc then
                vi[bx] = xc
                pcall(function()
                    xc:Fire(table.unpack(w8))
                end)
                if xd_10 then
                    return true
                end
                xa = Remotes:FindFirstChild(bx)
                local xd_5 = xa and xa:IsA("RemoteEvent")
                if xd_5 then
                    return pcall(function()
                        xa:FireServer(table.unpack(w8))
                    end)
                end
                return false
            end
            xa = Remotes:FindFirstChild(bx)
            local xd_6 = xa and xa:IsA("RemoteEvent")
            if xd_6 then
                return pcall(function()
                    xa:FireServer(table.unpack(w8))
                end)
            end
            return false
        end
        xa = Remotes:FindFirstChild(bx)
        local xd_7 = xa and xa:IsA("RemoteEvent")
        if xd_7 then
            return pcall(function()
                xa:FireServer(table.unpack(w8))
            end)
        end
        return false
    end
    w9 = uF()
    xd_8 = w9 and w9.Network
    if xd_8 then
        xd_9, xc = pcall(function()
            return w9.Network.new(bx, "RemoteEvent")
        end)
        if xd_9 and xc then
            vi[bx] = xc
            xd_10 = pcall(function()
                xc:Fire(table.unpack(w8))
            end)
            if xd_10 then
                return true
            end
            xa = Remotes:FindFirstChild(bx)
            local xd_11 = xa and xa:IsA("RemoteEvent")
            if xd_11 then
                return pcall(function()
                    xa:FireServer(table.unpack(w8))
                end)
            end
            return false
        end
        xa = Remotes:FindFirstChild(bx)
        local xd_12 = xa and xa:IsA("RemoteEvent")
        if xd_12 then
            return pcall(function()
                xa:FireServer(table.unpack(w8))
            end)
        end
        return false
    end
    xa = Remotes:FindFirstChild(bx)
    local xd_13 = xa and xa:IsA("RemoteEvent")
    if xd_13 then
        return pcall(function()
            xa:FireServer(table.unpack(w8))
        end)
    end
    return false
end
vm = fn1176
u2 = fn1174
uv = fn1236
t8 = fn1218
tZ = fn808
u9 = function(cm)
    if typeof(cm) ~= "Vector3" then
        return
    end
    pcall(function()
        uW:RequestStreamAroundAsync(cm)
    end)
end
uL = fn925
uh = function(cx)
    local xP = not cx or not cx:IsA("ProximityPrompt")
    if xP then
        return false
    end
    pcall(function()
        cx.HoldDuration = 0
        cx.MaxActivationDistance = math.max(cx.MaxActivationDistance, 20)
        cx.RequiresLineOfSight = false
    end)
    if fireproximityprompt then
        local xP_1 = pcall(fireproximityprompt, cx) or pcall(fireproximityprompt, cx, 1)
        return xP_1 == true
    end
    local xP_2 = pcall(function()
        cx:InputHoldBegin()
        task.wait(0.05)
        cx:InputHoldEnd()
    end)
    return xP_2
end
vD = fns.fn312
u4 = fns.fn417
uy = fn1239
uj = fns.fn690
tX = fns.fn29
u_ = function(db)
    local yJ_1
    local yI_1
    local yH = math.huge
    for i, child in Guardians:GetChildren() do
        local yQ = child
        yI_1, yJ_1 = pcall(function()
            return yQ:GetPivot().Position
        end)
        if yI_1 then
            local Magnitude = (yJ_1 - db).Magnitude
            if Magnitude < yH then
                yH = Magnitude
            end
        end
    end
    return yH
end
ud = fns.fn486
vt = fns.fn257
vJ = fns.fn288
vp = fn761
vc = fn856
uU = fn1276
uu = fn1046
t5 = fns.fn160
uX = fns.fn61
uB = fn1189
t2 = fn1141
vy = fn1291
un = fn1153
vH = fns.fn454
us = fn707
t9 = fns.fn532
vB = fns.fn682
t3 = fns.fn194
uP = fns.fn140
ue = fns.fn108
uG = fns.fn123
t0 = fn1050
uY = fns.fn625
vf = function()
    local BJ
    local BK
    local BL, BM, BN, BO, BP, BT
    local BQ = 1
    while true do
        local BQ_1 = 4236 - BQ
        do
            if BQ_1 < 4215 then
                if BQ_1 < 4208 then
                    if BQ_1 < 4205 then
                        if BQ_1 < 4204 then
                            if BQ_1 < 4203 then
                                if BQ_1 == 4202 then
                                    BO = (ul())
                                    BQ = if BO then 33 else 5
                                else
                                    BQ = 4224
                                    continue
                                end
                            else
                                BL = BO
                                BM, BJ = uY(BL)
                                BQ = if not BM then 18 else 32
                            end
                        else
                            BO = BJ
                            BQ = if BO then 21 else 4
                        end
                    elseif BQ_1 < 4206 then
                        BQ = 24
                    elseif BQ_1 < 4207 then
                        if BQ_1 == 4206 then
                            BQ = 24
                        else
                            BQ = 4217
                            continue
                        end
                    elseif BQ_1 == 4207 then
                        BQ = if os.clock() < BO then 11 else 15
                    else
                        BQ = 4223
                        continue
                    end
                elseif BQ_1 < 4211 then
                    if BQ_1 < 4210 then
                        if BQ_1 < 4209 then
                            return false
                        elseif BQ_1 == 4209 then
                            BQ = 10
                        else
                            BQ = 7802
                            continue
                        end
                    elseif BQ_1 == 4210 then
                        return false
                    else
                        BQ = 4749
                        continue
                    end
                elseif BQ_1 < 4213 then
                    if BQ_1 < 4212 then
                        BO = Library.Unloaded
                        BQ = if BO then 13 else 12
                    elseif BQ_1 == 4212 then
                        return BN
                    else
                        BQ = 4236
                        continue
                    end
                elseif BQ_1 < 4214 then
                    if BQ_1 == 4213 then
                        BM, BJ = uY(BL)
                        BQ = if not BM then 28 else 7
                    else
                        BQ = 7802
                        continue
                    end
                else
                    break
                end
            elseif BQ_1 < 4223 then
                if BQ_1 < 4218 then
                    if BQ_1 < 4217 then
                        if BQ_1 < 4216 then
                            BO = BK
                            BQ = 4
                        elseif BQ_1 == 4216 then
                            task.wait(0.08)
                            BQ = 19
                        else
                            BQ = 4232
                            continue
                        end
                    elseif BQ_1 == 4217 then
                        BQ = 8
                    else
                        BQ = 4231
                        continue
                    end
                elseif BQ_1 < 4222 then
                    if BQ_1 < 4220 then
                        if BQ_1 < 4219 then
                            if BQ_1 == 4218 then
                                BQ = 24
                            else
                                BQ = 4225
                                continue
                            end
                        else
                            vb("Place Slime", tostring(BO.Name), BM)
                            BN = true
                            BO = os.clock() + 1.2
                            BQ = 8
                        end
                    elseif BQ_1 < 4221 then
                        if BQ_1 == 4220 then
                            BQ = 25
                        else
                            BQ = 4234
                            continue
                        end
                    elseif BQ_1 == 4221 then
                        BQ = 10
                    else
                        BQ = 11501
                        continue
                    end
                elseif BQ_1 == 4222 then
                    pcall(function()
                        BK:EquipTool(BJ)
                    end)
                    task.wait(0.08)
                    BQ = 6
                else
                    BQ = 4204
                    continue
                end
            elseif BQ_1 < 4229 then
                if BQ_1 < 4226 then
                    if BQ_1 < 4224 then
                        if BQ_1 == 4223 then
                            BQ = if BO then 30 else 34
                        else
                            BQ = 4215
                            continue
                        end
                    elseif BQ_1 < 4225 then
                        if BQ_1 == 4224 then
                            BO = not uZ("AutoPlace")
                            BQ = 13
                        else
                            BQ = 4210
                            continue
                        end
                    elseif BQ_1 == 4225 then
                        BP = false
                        for k, v in t5() do
                            if v:GetAttribute("slimeUID") == BM then
                                BP = true
                                break
                            end
                        end
                        BQ = if not BP then 27 else 20
                    else
                        BQ = 4230
                        continue
                    end
                elseif BQ_1 < 4227 then
                    task.wait(0.1)
                    BQ = 3
                elseif BQ_1 < 4228 then
                    if BQ_1 == 4227 then
                        BP = BO:FindFirstChildWhichIsA("BasePart", true)
                        local BY = if BP then 1 else 0
                        local BW = 2699 * BY + 3192 * (1 - BY)
                        local BX = 2437 * BY + 3786 * (1 - BY)
                        BQ = if (BW * 1163 + BX * 2055 + BW * BX) % 16777213 == 14724435 then 0 else 17
                    else
                        BQ = 4202
                        continue
                    end
                elseif BQ_1 == 4228 then
                    BQ = 29
                else
                    BQ = 4226
                    continue
                end
            elseif BQ_1 < 4233 then
                if BQ_1 < 4231 then
                    if BQ_1 < 4230 then
                        if BQ_1 == 4229 then
                            us()
                            BK = uT()
                            BN = false
                            BT = 1
                            BQ = 2
                        else
                            BQ = 4228
                            continue
                        end
                    elseif BQ_1 == 4230 then
                        BO = vy(BL)
                        BQ = if not BO then 31 else 9
                    else
                        BQ = 4226
                        continue
                    end
                elseif BQ_1 < 4232 then
                    BO = BL
                    BQ = 33
                else
                    BQ = if BO then 14 else 6
                end
            elseif BQ_1 < 4235 then
                if BQ_1 < 4234 then
                    if BQ_1 == 4233 then
                        BT += 1
                        BQ = 2
                    else
                        BQ = 4216
                        continue
                    end
                else
                    BQ = if BT <= 16 then 16 else 24
                end
            elseif BQ_1 < 4749 then
                if BQ_1 < 4236 then
                    BL = ul()
                    BQ = if not BL then 26 else 23
                elseif BQ_1 == 4236 then
                    uL(BP.CFrame)
                    task.wait(0.08)
                    BQ = 17
                else
                    break
                end
            else
                break
            end
        end
    end
end
va = fn922
up = fns.fn665
u5 = fn744
t4 = fns.fn267
uA = fn942
t_ = fns.fn225
vq = fns.fn252
uQ = fn840
t6 = fn1057
vk = fn1051
u7 = function()
    if uu() then
        return
    end
    local Dj = ul()
    if not Dj then
        return
    end
    local Di = uT()
    if not Di then
        return
    end
    local Dk = -1
    local id
    for k, v in vz do
        if vq(Dj, v.id) then
            local Dm = vk(v)
            if Dm > Dk then
                Dk = Dm
                id = v.id
            end
        end
    end
    if not id then
        return
    end
    local Backpack = uW:FindFirstChild("Backpack")
    local Character = uW.Character
    for k, v in { Character, Backpack } do
        if v then
            for i, child in v:GetChildren() do
                local DL = child
                local Dj_2 = DL:IsA("Tool") and tostring(DL:GetAttribute("gearId")) == id
                if Dj_2 then
                    if DL.Parent ~= Character then
                        pcall(function()
                            Di:EquipTool(DL)
                        end)
                    end
                    return
                end
            end
        end
    end
end
vg = fns.fn607
uH = fns.fn586
vI = fns.fn431
ut = fn1009
u0 = fn733
uE = fn1269
uk = fn1041
vE = fn964
IO_35 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = um, Copyable = true }, "|", uq },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    SidebarCompacted = true,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
IO_35:SetGlow(true, { Color = Color3.fromRGB(242, 154, 196), Radius = 24, Transparency = 0.3 })
uV = {
    Info = IO_35:AddTab("Info", "info"),
    Main = IO_35:AddTab("Main", "gamepad-2"),
    Player = IO_35:AddTab("Player", "person-standing"),
    Settings = IO_35:AddTab("Settings", "settings")
}
IO_36 = fn886
for k, v in uV do
    if k ~= "Info" then
        IO_36(v)
    end
end
local StealGroup = uV.Main:AddLeftGroupbox("Steal", "hand")
StealGroup:AddToggle("AutoSteal", { Text = "Auto Steal", Default = false })
StealGroup:AddDropdown("StealZone", {
    Text = "Zone",
    Values = uw,
    Default = { Common = true },
    Multi = true,
    AllowEmpty = true,
    Searchable = true,
    SelectAllButtons = true
})
StealGroup:AddDropdown("StealRarity", {
    Text = "Rarity",
    Values = IO_7,
    Default = { Common = true, Uncommon = true, Rare = true },
    Multi = true,
    AllowEmpty = true,
    Searchable = true,
    SelectAllButtons = true
})
local BaseGroup = uV.Main:AddLeftGroupbox("Base", "house")
BaseGroup:AddToggle("AutoPlace", { Text = "Auto Place Lucky Blocks", Default = false })
BaseGroup:AddDropdown("PlaceZone", {
    Text = "Zone",
    Values = uw,
    Default = {},
    Multi = true,
    AllowEmpty = true,
    Searchable = true,
    SelectAllButtons = true
})
BaseGroup:AddDropdown("PlaceRarity", {
    Text = "Rarity",
    Values = IO_7,
    Default = {},
    Multi = true,
    AllowEmpty = true,
    Searchable = true,
    SelectAllButtons = true
})
BaseGroup:AddDivider()
BaseGroup:AddToggle("AutoHatch", { Text = "Auto Hatch Lucky Blocks", Default = false })
BaseGroup:AddToggle("AutoCollect", { Text = "Auto Collect Money", Default = false })
local GearGroup = uV.Main:AddLeftGroupbox("Gear", "sparkles")
GearGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
GearGroup:AddToggle("AutoBuyCoil", { Text = "Auto Buy Coil", Default = false })
IO_12 = uV.Main:AddRightGroupbox("Protection", "shield")
IO_12:AddToggle("AntiTouch", { Text = "Anti Touch", Default = true })
IO_24 = uV.Main:AddRightGroupbox("Upgrades", "arrow-up")
IO_24:AddToggle("AutoUpgradeJump", { Text = "Auto Upgrade Jump", Default = false })
IO_24:AddDropdown("JumpBuyAmount", { Text = "Jump Amount", Values = IO_32, Default = "+1 Jump" })
IO_24:AddToggle("AutoUpgradeCarry", { Text = "Auto Upgrade Carry", Default = false })
IO_24:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
IO_22 = uV.Main:AddRightGroupbox("Sell", "tags")
IO_22:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
IO_22:AddDropdown("SellFrom", { Text = "Sell From", Values = IO_20, Default = "Both" })
IO_22:AddDropdown("SellRarity", {
    Text = "Rarity",
    Values = IO_7,
    Default = { Common = true, Uncommon = true, Rare = true },
    Multi = true,
    AllowEmpty = true,
    Searchable = true,
    SelectAllButtons = true
})
IO_22:AddToggle("SellLuckyBlocks", { Text = "Sell Lucky Blocks", Default = false })
IO_22:AddToggle("SellMonsters", { Text = "Sell Monsters", Default = true })
IO_35 = function()
    local FK
    local FL
    FK = nil
    FL = nil
    local FJ, Label, Label2, Label3, FP
    local function FQ()
        local EV = hookfunction ~= nil
        local EW = hookmetamethod ~= nil
        local EX = getrawmetatable ~= nil
        local EY = setrawmetatable ~= nil
        local EZ = getgc ~= nil
        local E_ = getgenv ~= nil
        local E0 = getreg ~= nil
        local E1 = getconnections ~= nil
        local E2 = firesignal ~= nil
        local E3 = getcallbackvalue ~= nil
        local E4 = setclipboard ~= nil
        local E5 = getcustomasset ~= nil
        local E6 = getnamecallmethod ~= nil
        local E7 = isexecutorclosure ~= nil
        local E8 = fireproximityprompt ~= nil
        local E9 = firetouchinterest ~= nil
        local Fa = WebSocket ~= nil
        local Fb = readfile ~= nil
        local Fc = writefile ~= nil
        local Fe = (request or http_request) ~= nil
        local Fg = (debug and debug.getupvalues) ~= nil
        local Fi = (debug and debug.setupvalue) ~= nil
        local Fj = 0
        local Fk = { EV, EW, EX, EY, EZ, E_, E0, E1, E2, E3, E4, E5, E6, E7, E8, E9, Fa, Fb, Fc, Fe, Fg, Fi }
        for i, v in ipairs(Fk) do
            if v then
                Fj += 1
            end
        end
        local EV_1 = Fj / #Fk
        if EV_1 >= 0.9 then
            return vA("Full Support", t7)
        elseif EV_1 >= 0.6 then
            return vA("Half Support", tY)
        else
            return vA("Low Support", vF)
        end
    end
    FK = "Unknown"
    pcall(function()
        local Fw_1
        local Fv_1
        if identifyexecutor then
            Fw_1, Fv_1 = identifyexecutor()
            local Fx = Fw_1 ~= ""
            local Fy = type(Fw_1) == "string" and Fx
            if Fy then
                local Fx_1 = type(Fv_1) == "string" and Fv_1 ~= "" and Fw_1 .. " " .. Fv_1
                FK = Fx_1 or Fw_1
            end
        end
    end)
    local FR = FQ()
    FL = os.clock()
    FP = function()
        local FA = math.floor(os.clock() - FL)
        if FA < 60 then
            return FA .. "s"
        elseif FA < 3600 then
            return string.format("%dm %ds", math.floor((FA) / (60)), FA % 60)
        else
            return string.format("%dh %dm", math.floor((FA) / (3600)), math.floor((FA % 3600) / (60)))
        end
    end
    local UserGroup = uV.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = uW, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(vo("User", uW.DisplayName .. " @" .. uW.Name, t7), true)
    UserGroup:AddLabel(vo("UserId", tostring(uW.UserId), t1), true)
    UserGroup:AddLabel(vo("Executor", FK .. "  " .. FR, t7), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(vo("Session", FP(), tY), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            uc(uW.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            uc("https://www.roblox.com/users/" .. tostring(uW.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = uV.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(vo("Game", uq, t1), true)
    Label2 = SessionGroup:AddLabel(vo("Players", "0/0", t7), true)
    FJ = tostring(game.JobId)
    local FR_1 = #FJ > 18 and string.sub(FJ, 1, 18) .. "..."
    local FR_2 = FR_1 or FJ
    SessionGroup:AddLabel(vo("Job", FR_2, tV), true)
    Label = SessionGroup:AddLabel(vo("Ping", "0 ms", tY), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            vd:Teleport(game.PlaceId, uW)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            uc(FJ, "Copied Job ID")
        end
    })
    task.spawn(function()
        local FG_1
        local FF_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(vo("Session", FP(), tY))
            Label2:SetText(vo("Players", #tU:GetPlayers() .. "/" .. tostring(tU.MaxPlayers), t7))
            FF_1, FG_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local FF_2 = FF_1 and FG_1 .. " ms" or "n/a"
            Label:SetText(vo("Ping", FF_2, tY))
        end
    end)
    local SocialsGroup = uV.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = tW })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            uc(uf, "Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            uc(ub, "Copied website link")
        end
    })
end
IO_9 = function()
    local connection
    local MovementGroup = uV.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = uV.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local function mk()
        local Character = uW.Character
        local FV = Character and Character:FindFirstChildOfClass("Humanoid")
        return FV
    end
    local function mp()
        local Character = uW.Character
        local FY = Character and Character:FindFirstChild("HumanoidRootPart")
        return FY
    end
    vC.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local F__1 = uW.Character
            if F__1 then
                for i, descendant in F__1:GetDescendants() do
                    local F__2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if F__2 then
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
            local F7_1 = mk()
            if F7_1 then
                F7_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    local CurrentCamera = u1.CurrentCamera
    vC.RenderStepped:Connect(function(mM)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local F9_1 = mk()
            if F9_1 then
                F9_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local F9_3 = mp()
            local Ga = mk()
            if F9_3 and Ga then
                Ga.PlatformStand = true
                local Ga_1 = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    Ga_1 += CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    Ga_1 -= CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    Ga_1 -= CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    Ga_1 += CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    Ga_1 += Vector3.new(0, 1, 0)
                end
                local Gf = if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then 1 else 0
                if Gf == 1 then
                    Ga_1 -= Vector3.new(0, 1, 0)
                end
                F9_3.AssemblyLinearVelocity = Vector3.zero
                if Ga_1.Magnitude > 0 then
                    F9_3.CFrame = F9_3.CFrame + Ga_1.Unit * Options.FlySpeed.Value * mM
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local Gg = mk()
            if Gg then
                Gg.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local Gi = mk()
            if Gi then
                Gi.WalkSpeed = 16
            end
        end
    end)
    local function m6(m7)
        if not m7:IsA("ProximityPrompt") then
            return
        end
        m7.HoldDuration = 0
        m7.MaxActivationDistance = 50
        m7.RequiresLineOfSight = false
    end
    connection = nil
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in u1:GetDescendants() do
                pcall(m6, descendant)
            end
            connection = u1.DescendantAdded:Connect(function(nf)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(m6, nf)
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
IO_35()
IO_9()
local function IO_1()
    local GK, GL, GM
    GL = {}
    GM = function()
        for k, v in GL do
            local GA = v
            pcall(function()
                GA:Disconnect()
            end)
        end
        table.clear(GL)
    end
    GK = function()
        GM()
        tX()
        GL[#GL + 1] = Guardians.ChildAdded:Connect(function(nx)
            task.defer(function()
                if uZ("AntiTouch") then
                    uj(nx)
                end
            end)
        end)
        GL[#GL + 1] = Guardians.DescendantAdded:Connect(function(nH)
            if uZ("AntiTouch") then
                uy(nH)
            end
        end)
        GL[#GL + 1] = vC.Heartbeat:Connect(function()
            local GD = Library.Unloaded
            local GH = if GD then 1 else 0
            local GF = 3780 * GH + 3858 * (1 - GH)
            local GG = 260 * GH + 588 * (1 - GH)
            if not ((GF * 2150 + GG * 3981 + GF * GG) % 16777213 == 10144860) then
                GD = not uZ("AntiTouch")
            end
            if GD then
                return
            end
            vt()
        end)
    end
    Toggles.AntiTouch:OnChanged(function()
        if Toggles.AntiTouch.Value then
            GK()
        else
            GM()
        end
    end)
    if Toggles.AntiTouch.Value then
        GK()
    end
    Library:OnUnload(GM)
    task.spawn(function()
        while not Library.Unloaded do
            if uZ("AntiTouch") then
                pcall(tX)
            end
            task.wait(0.2)
        end
    end)
end
IO_1()
task.spawn(worker)
task.spawn(fns.worker2)
task.spawn(worker3)
local function IO_28()
    local Iu, Iv, Iw, Ix, Iy, Iz, IA, IB, IC, connection2, connection, IF, Label, IH, II
    local MenuGroup = uV.Settings:AddLeftGroupbox("Menu", "logs")
    Iu = 0
    IA = tick()
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    Label = MenuGroup:AddLabel("AFK triggers: 0")
    Ix = function()
        local CurrentCamera = u1.CurrentCamera
        if not CurrentCamera then
            return
        end
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        Iu += 1
        IA = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. Iu)
        end)
    end
    connection2 = uW.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(Ix)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local GY = Toggles.AntiAfk.Value and tick() - IA >= 60
            if GY then
                pcall(Ix)
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
    IC = function(oI)
        pcall(function()
            vj:SetGameplayPausedNotificationEnabled(not oI)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = vl:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not oI
            end
        end)
        if not oI then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(uW, "GameplayPaused", false)
            else
                uW.GameplayPaused = false
            end
        end)
    end
    Toggles.AntiGameplayPause:OnChanged(function()
        IC(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                IC(true)
            end
        end
    end)
    Iv = false
    IB = function()
        local PlaceId, JobId
        if Iv then
            return
        end
        Iv = true
        PlaceId, JobId = game.PlaceId, game.JobId
        local Hc = pcall(function()
            vd:TeleportToPlaceInstance(PlaceId, JobId, uW)
        end)
        if not Hc then
            pcall(function()
                vd:Teleport(PlaceId, uW)
            end)
        end
    end
    task.spawn(function()
        local RobloxPromptGui = vl:WaitForChild("RobloxPromptGui", 30)
        local Hk = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
        if not Hk then
            return
        end
        Hk.ChildAdded:Connect(function(ph)
            if Library.Unloaded then
                return
            end
            if Toggles.AutoReconnect.Value and ph.Name == "ErrorPrompt" then
                IB()
            end
        end)
    end)
    vd.TeleportInitFailed:Connect(function()
        if Toggles.AutoReconnect.Value then
            Iv = false
            IB()
        end
    end)
    Toggles.Disable3D:OnChanged(function()
        pcall(function()
            vC:Set3dRenderingEnabled(not Toggles.Disable3D.Value)
        end)
    end)
    II = {
        ParticleEmitter = true,
        Trail = true,
        Smoke = true,
        Fire = true,
        Sparkles = true,
        Explosion = true,
        Beam = true
    }
    Iy = function(pz)
        if II[pz.ClassName] then
            pcall(function()
                pz.Enabled = false
            end)
        end
    end
    connection = nil
    Toggles.FpsBoost:OnChanged(function()
        if Toggles.FpsBoost.Value then
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            end)
            pcall(function()
                u6.GlobalShadows = false
            end)
            pcall(function()
                u6.FogEnd = 9000000000
            end)
            for i, descendant in u1:GetDescendants() do
                pcall(Iy, descendant)
            end
            connection = u1.DescendantAdded:Connect(function(pO)
                if Toggles.FpsBoost.Value then
                    pcall(Iy, pO)
                end
            end)
        else
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            end)
            pcall(function()
                u6.GlobalShadows = true
            end)
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end)
    local ScriptGroup = uV.Settings:AddLeftGroupbox("Script", "terminal")
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
        if connection then
            connection:Disconnect()
        end
        IC(false)
        pcall(function()
            vC:Set3dRenderingEnabled(true)
        end)
        if getgenv then
            getgenv().__TempoJumpToStealSCPLib = nil
        end
    end)
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("TempoHub")
    ThemeManager:SaveDefault("Evil Hello Kitty")
    ThemeManager:ApplyToTab(uV.Settings)
    ThemeManager:LoadDefault()
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    SaveManager:SetFolder("TempoHub/JumpToStealSCPMonsters")
    local IJ_2 = SaveManager:BuildConfigSection(uV.Settings)
    IH = function(p1, p2)
        local HB_1 = (p1 == "Toggle" and Toggles or Options)[p2]
        local HA_2 = type(HB_1) == "table" and HB_1.Type == p1
        return HA_2 and HB_1 or nil
    end
    IF = function(p9, qa)
        local Type = qa.Type
        if Type == "Toggle" then
            return { idx = p9, type = "Toggle", value = qa.Value == true }
        elseif Type == "Slider" then
            return { idx = p9, type = "Slider", value = tostring(qa.Value) }
        elseif Type == "Dropdown" then
            return { idx = p9, type = "Dropdown", multi = qa.Multi == true, value = qa.Value }
        elseif Type == "Input" then
            local HF = qa.Value or ""
            return { idx = p9, type = "Input", text = tostring(HF) }
        elseif Type == "ColorPicker" then
            return { idx = p9, type = "ColorPicker", value = qa.Value:ToHex(), transparency = qa.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = p9,
                type = "KeyPicker",
                mode = qa.Mode,
                key = qa.Value,
                modifiers = qa.Modifiers,
                toggled = qa.Toggled
            }
        else
            return nil
        end
    end
    Iw = function()
        local HL = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local HM = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if HM then
                    local HM_1 = IF(k, v)
                    if HM_1 then
                        HL[#HL + 1] = HM_1
                    end
                end
            end
        end
        table.sort(HL, function(ql, qm)
            if ql.type ~= qm.type then
                return ql.type < qm.type
            end
            return ql.idx < qm.idx
        end)
        return { objects = HL }
    end
    Iz = function(qo)
        local H7
        H7 = nil
        local H8 = type(qo) ~= "table" or type(qo.idx) ~= "string" or type(qo.type) ~= "string" or SaveManager.Ignore[qo.idx]
        if H8 then
            return false
        end
        H7 = IH(qo.type, qo.idx)
        if not H7 then
            return false
        end
        local H8_1 = pcall(function()
            if qo.type == "Input" then
                if type(qo.text) ~= "string" then
                    return
                end
                H7:SetValue(qo.text)
            elseif qo.type == "ColorPicker" then
                H7:SetValueRGB(Color3.fromHex(qo.value), qo.transparency)
            elseif qo.type == "KeyPicker" then
                H7:SetValue({ qo.key, qo.mode, qo.modifiers })
                if qo.mode == "Toggle" and qo.toggled ~= nil then
                    H7.Toggled = qo.toggled
                    H7:Update()
                end
            else
                H7:SetValue(qo.value)
            end
        end)
        return H8_1
    end
    IJ_2:AddDivider()
    IJ_2:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    IJ_2:AddButton({
        Text = "Export Config to Clipboard",
        Func = function()
            local Ib_1
            local Ia_1
            Ia_1, Ib_1 = pcall(vr.JSONEncode, vr, Iw())
            if not Ia_1 then
                Library:Notify("Failed to encode the config")
                return
            end
            local Ia_2 = setclipboard
            local Ig = if Ia_2 then 1 else 0
            local Ie = 2455 * Ig + 2475 * (1 - Ig)
            local If = 3154 * Ig + 2621 * (1 - Ig)
            if not ((Ie * 2165 + If * 780 + Ie * If) % 16777213 == 15518265) then
                Ia_2 = toclipboard
            end
            local Ic = Ia_2
            local Ia_3 = type(Ic) ~= "function" or not pcall(Ic, Ib_1)
            if Ia_3 then
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Config copied to clipboard", 6)
        end
    })
    IJ_2:AddButton({
        Text = "Import Config from Clipboard Text",
        Func = function()
            local Ij_1
            local Ih = Options.SaveManager_ImportSource.Value or ""
            local Ih_1
            local Ii = tostring(Ih):match("^%s*(.-)%s*$")
            if Ii == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            Ih_1, Ij_1 = pcall(vr.JSONDecode, vr, Ii)
            local Ii_1 = not Ih_1 or type(Ij_1) ~= "table"
            local In = if Ii_1 then 1 else 0
            local Il = 3957 * In + 3095 * (1 - In)
            local Im = 2944 * In + 25 * (1 - In)
            if not ((Il * 2307 + Im * 662 + Il * Im) % 16777213 == 5949922) then
                Ii_1 = type(Ij_1.objects) ~= "table"
            end
            if Ii_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            local Ih_2 = 0
            for i, v in ipairs(Ij_1.objects) do
                if Iz(v) then
                    Ih_2 += 1
                end
            end
            if Ih_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local Ij_2 = Ih_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(Ih_2, Ij_2), 6)
        end
    })
    SaveManager:LoadAutoloadConfig()
    if Toggles.HideUiOnStart.Value then
        Library:Toggle(false)
    end
end
IO_28()
end)(...)

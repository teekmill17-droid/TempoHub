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
getgenv().TempoHoodSubtitle = "ROLLER FOR ANIMALS!"
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
local wM
local vM
local wt
local vS
local CoreGui
local vz
local wg
local vY
local w3
local vL
local ws
local v9
local vR
local wy
local vy
local wf
local wX
local vX
local vE
local wl
local w2
local State
local vK
local wr
local vQ
local vx
local we
local vW
local wD
local vD
local LocalPlayer
local v1
local wJ
local v7
local wP
local vP
local wd
local wV
local vV
local vC
local wj
local v0
local wI
local vI
local v6
local wO
local wv
local wc
local vU
local wB
local vB
local wi
local wH
local wo
local wT
local wA
local vA
local wZ
local vG
local wn
local function fn4(dd)
    local zv = 0
    local zw = {}
    if type(dd) == "table" then
        for k, v in pairs(dd) do
            local zx = v == true and type(k) == "string"
            if zx then
                zw[k] = true
                zv += 1
            elseif type(v) == "string" then
                zw[v] = true
                zv += 1
            end
        end
    end
    return zw, zv
end
local function fn12()
    if not State.AutoUpgradeTreadmill or not w3 then
        return
    end
    local Db_1 = vy()
    if not Db_1 then
        return
    end
    local Dc_1 = tonumber(Db_1.TreadmillLevel) or 1
    local Dc_2 = w3.GetTreadmillMaxLevel and w3.GetTreadmillMaxLevel()
    if Dc_1 >= (Dc_2 or 36) then
        return
    end
    local Dc_4 = w3.GetTreadmillUpgradePrice and w3.GetTreadmillUpgradePrice(Dc_1)
    local Dc_5 = tonumber(Db_1.money) or 0
    local Dc_6 = type(Dc_4) == "number" and Dc_5 >= Dc_4
    if Dc_6 then
        wi("Upgrading treadmill")
        pcall(function()
            wM("Training_Upgrade")
        end)
    end
end
local function fn35(au)
    return type(au) == "function"
end
local function fn51(dy)
    local zU = wy[dy]
    local zV = zU ~= nil and os.clock() < zU
    return zV
end
local function fn54(dk)
    local zJ_3
    if State.StealZoneCount > 0 then
        local attr = dk:GetAttribute("Zone")
        local zJ_1 = type(attr) ~= "string"
        local zN_1 = if zJ_1 then 1 else 0
        local zL_1 = 1356 * zN_1 + 1555 * (1 - zN_1)
        local zM_1 = 815 * zN_1 + 1209 * (1 - zN_1)
        if not ((zL_1 * 1085 + zM_1 * 2019 + zL_1 * zM_1) % 16777213 == 4221885) then
            zJ_1 = not State.StealZones[attr]
        end
        if zJ_1 then
            return false
        elseif State.StealRarityCount > 0 then
            dk:GetAttribute("Rarity")
            if zJ_3 then
                return false
            end
            return true
        else
            return true
        end
    elseif State.StealRarityCount > 0 then
        local attr = dk:GetAttribute("Rarity")
        zJ_3 = type(attr) ~= "string"
        local zN_3 = if zJ_3 then 1 else 0
        local zL_3 = 982 * zN_3 + 1531 * (1 - zN_3)
        local zM_3 = 3414 * zN_3 + 3020 * (1 - zN_3)
        if not ((zL_3 * 3954 + zM_3 * 2425 + zL_3 * zM_3) % 16777213 == 15514326) then
            zJ_3 = not State.StealRarities[attr]
        end
        if zJ_3 then
            return false
        end
        return true
    else
        return true
    end
end
local function fn56(kH)
    if kH == "Rarest" or kH == "Biggest" or kH == "Nearest" then
        State.Priority = kH
    end
end
local function fn70()
    return table.clone(wI)
end
local function fn74()
    return LocalPlayer:GetAttribute(wA) == true
end
local function fn108(dI)
    local z_ = vB(dI)
    if z_ then
        local TakeEgg = z_:FindFirstChild("TakeEgg")
        local z__1 = TakeEgg and TakeEgg:IsA("ProximityPrompt")
        if z__1 then
            return TakeEgg
        end
        for i, descendant in ipairs(dI:GetDescendants()) do
            local z__2 = (descendant:IsA("ProximityPrompt"))
            if z__2 then
                local z0_2 = descendant.Name == "TakeEgg"
                local Ag_1 = if z0_2 then 1 else 0
                local Ae_1 = 2002 * Ag_1 + 1318 * (1 - Ag_1)
                local Af_1 = 585 * Ag_1 + 1312 * (1 - Ag_1)
                if not ((Ae_1 * 2187 + Af_1 * 3583 + Ae_1 * Af_1) % 16777213 == 7645599) then
                    z0_2 = descendant.ActionText == "Take"
                end
                z__2 = z0_2
            end
            if z__2 then
                return descendant
            end
        end
        return nil
    end
    for i, descendant in ipairs(dI:GetDescendants()) do
        local z__3 = (descendant:IsA("ProximityPrompt"))
        if z__3 then
            local z0_3 = descendant.Name == "TakeEgg"
            local Ag_2 = if z0_3 then 1 else 0
            local Ae_2 = 2002 * Ag_2 + 1318 * (1 - Ag_2)
            local Af_2 = 585 * Ag_2 + 1312 * (1 - Ag_2)
            if not ((Ae_2 * 2187 + Af_2 * 3583 + Ae_2 * Af_2) % 16777213 == 7645599) then
                z0_3 = descendant.ActionText == "Take"
            end
            z__3 = z0_3
        end
        if z__3 then
            return descendant
        end
    end
    return nil
end
local function fn161()
    local yr = tostring(State.Status)
    local ys = State.Stolen or 0
    local yt = State.Placed or 0
    local yu = State.Opened or 0
    local yv = State.Sold or 0
    return string.format("%s  |  stolen %d  |  placed %d  |  opened %d  |  sold %d", yr, ys, yt, yu, yv)
end
local function fn197(iX)
    local DA = iX or State.TeleportZone
    local DA_1 = wt(DA)
    if not DA_1 then
        wi("Zone not found")
        return false
    end
    wi("Teleport to " .. tostring(DA))
    State.TeleportZone = DA
    return vK(DA_1)
end
local function fn199(bU, ...)
    local yH = not wo
    local yL = if yH then 1 else 0
    local yJ = 1946 * yL + 2901 * (1 - yL)
    local yK = 402 * yL + 3606 * (1 - yL)
    if not ((yJ * 4070 + yK * 958 + yJ * yK) % 16777213 == 9087628) then
        yH = type(wo.InvokeServer) ~= "function"
    end
    if yH then
        return false, "Net unavailable"
    end
    local yH_1 = table.pack(pcall(wo.InvokeServer, wo, bU, ...))
    if not yH_1[1] then
        return false, tostring(yH_1[2])
    end
    return table.unpack(yH_1, 2, yH_1.n)
end
local function fn219()
    if not State.AutoClaimIndex then
        return
    end
    wi("Claiming index")
    pcall(function()
        wM("Index_ClaimAll")
    end)
end
local function fn237(kj)
    local EZ = kj and true or false
    State.AutoUpgradeTreadmill = EZ
    if State.AutoUpgradeTreadmill then
        vQ("Treadmill", vx, wT)
    else
        v6("Treadmill")
    end
end
local function fn249(kE)
    State.SellRarities, State.SellRarityCount = wd(kE)
end
local function fn333(ds)
    if State.EspRarityCount > 0 then
        local attr = ds:GetAttribute("Rarity")
        local zP = type(attr) ~= "string" or not State.EspRarities[attr]
        if zP then
            return false
        end
        return true
    end
    return true
end
local function fn342(b3)
    if wD[b3] then
        wD[b3] = nil
    end
end
local function fn348()
    local ze = {}
    local zf = { LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character }
    for i, v in ipairs(zf) do
        if v then
            for i, child in ipairs(v:GetChildren()) do
                if child:IsA("Tool") then
                    local attr = child:GetAttribute("EggId")
                    local zg = attr ~= ""
                    local zh = type(attr) == "string" and zg
                    if zh then
                        table.insert(ze, child)
                    end
                end
            end
        end
    end
    return ze
end
local function fn350()
    local Character = LocalPlayer.Character
    if not Character then
        return nil
    end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    return Character, HumanoidRootPart, Humanoid
end
local function fn368(dD, dE)
    local zX = os.clock()
    local zY = dE or wV
    wy[dD] = zX + zY
end
local function fn394(ky)
    State.StealRarities, State.StealRarityCount = wd(ky)
end
local function fn395(ki)
    local EW = ki and true or false
    State.AutoSell = EW
    if State.AutoSell then
        vQ("Sell", vz, wH)
    else
        v6("Sell")
    end
end
local function fn402(j_)
    local Ey = j_ and true or false
    State.AutoPlace = Ey
    if State.AutoPlace then
        vQ("Place", vP, wJ)
    else
        v6("Place")
    end
end
local function fn408(kB)
    State.EspRarities, State.EspRarityCount = wd(kB)
end
local function fn451(ji)
    local DT_1
    local DS = ws[ji]
    local DS_2
    if DS then
        return DS
    end
    local DS_1 = type(Drawing) ~= "table" or type(Drawing.new) ~= "function"
    if DS_1 then
        return nil
    end
    DS_2, DT_1 = pcall(Drawing.new, "Text")
    local DU = not DT_1
    local DV = not DS_2
    local DZ = if DV then 1 else 0
    local DX = 1348 * DZ + 2890 * (1 - DZ)
    local DY = 364 * DZ + 3959 * (1 - DZ)
    if not ((DX * 932 + DY * 2017 + DX * DY) % 16777213 == 2481196) then
        DV = DU
    end
    if DV then
        return nil
    end
    DT_1.Center = true
    DT_1.Outline = true
    DT_1.OutlineColor = Color3.new(0, 0, 0)
    DT_1.Size = 13
    DT_1.Font = 2
    DT_1.Visible = false
    ws[ji] = DT_1
    return DT_1
end
local function fn491()
    local Dy = we()
    if not Dy then
        wi("No plot assigned")
        return false
    end
    wi("Teleport to pen")
    return vK(Dy.Position)
end
local function fn497()
    local BM_1
    local BK = not wo
    local BK_1
    local BL = {}
    local BR = if BK then 1 else 0
    local BP = 3482 * BR + 1168 * (1 - BR)
    local BQ = 2163 * BR + 806 * (1 - BR)
    if not ((BP * 555 + BQ * 259 + BP * BQ) % 16777213 == 10024293) then
        BK = type(wo.InvokeServer) ~= "function"
    end
    if BK then
        return BL
    end
    BK_1, BM_1 = pcall(wo.InvokeServer, wo, "Egg_Sync")
    local BN = not BK_1 or type(BM_1) ~= "table"
    if BN then
        return BL
    end
    for k, v in pairs(BM_1) do
        local BK_2 = type(v) == "table" and v.OwnerUserId == LocalPlayer.UserId and type(v.Eggs) == "table"
        if BK_2 then
            for k, v in pairs(v.Eggs) do
                local BK_3 = type(v) == "table" and type(v.Id) == "string"
                if BK_3 then
                    table.insert(BL, v)
                end
            end
        end
    end
    return BL
end
local function fn515()
    return table.clone(vU)
end
local function fn549()
    local yB_1
    local yA = not wg or type(wg.GetData) ~= "function"
    local yA_1
    if yA then
        return nil
    end
    yA_1, yB_1 = pcall(wg.GetData)
    local yC = yA_1 and type(yB_1) == "table"
    if yC then
        return yB_1
    end
    return nil
end
local function fn590()
    local AL = we()
    if not AL then
        wi("No plot assigned")
        return false
    end
    wi("Returning to pen")
    vK(AL.Position)
    local AM = os.clock() + 6
    while true do
        local AN = vS() and os.clock() < AM
        if AN then
            if not vL() then
                return true
            end
            vK(AL.Position)
            task.wait(0.2)
            continue
        end
        break
    end
    return not vL()
end
local function fn607(kh)
    local ET = kh and true or false
    State.AutoClaimIndex = ET
    if State.AutoClaimIndex then
        vQ("Index", vD, w2)
    else
        v6("Index")
    end
end
local function fn631(kg)
    local EQ = kg and true or false
    State.AutoEquipBestTrail = EQ
    if State.AutoEquipBestTrail then
        vQ("TrailEquip", vE, wf)
    else
        v6("TrailEquip")
    end
end
local function fn687(d1, d2, d3)
    local An = not d1 or typeof(d2) ~= "Vector3"
    if An then
        return false
    end
    return (d1.Position - d2).Magnitude <= (d3 or wv)
end
local function fn726(d7, d8)
    local Aq = not d8
    local Ar = vL() and Aq
    if Ar then
        return true
    elseif not d7.Parent then
        return true
    else
        return false
    end
end
local function fn757()
    if not State.AutoUpgradePen or not vC then
        return
    end
    local Dm_1 = vy()
    if not Dm_1 then
        return
    end
    local Dn_1 = tonumber(Dm_1.PlotLevel) or 1
    local Dn_2 = vC.GetMaxPlotLevel and vC.GetMaxPlotLevel()
    if Dn_1 >= (Dn_2 or 8) then
        return
    end
    local Dn_4 = vC.GetPlotUpgradeCost and vC.GetPlotUpgradeCost(Dn_1)
    local Dn_5 = tonumber(Dm_1.money) or 0
    local Dn_6 = type(Dn_4) == "number" and Dn_5 >= Dn_4
    if Dn_6 then
        wi("Upgrading pen")
        pcall(function()
            wM("Pen_UpgradePlot")
        end)
    end
end
local function fn828()
    for k in pairs(wD) do
        v6(k)
    end
    v7()
    wl += 1
end
local function fn843(kJ)
    local Fj = kJ ~= ""
    local Fk = type(kJ) == "string" and Fj
    if Fk then
        State.TeleportZone = kJ
    end
end
local function fn855(kf)
    local EK = kf and true or false
    State.AutoBuyTrails = EK
    if State.AutoBuyTrails then
        vQ("Trails", vE, vA)
    else
        v6("Trails")
    end
end
local function fn879(c_)
    if not c_ then
        return nil
    end
    local EggRoot = c_:FindFirstChild("EggRoot")
    local y9 = EggRoot and EggRoot:IsA("BasePart")
    if y9 then
        return EggRoot
    end
    local y8_1 = c_.PrimaryPart
    local zd = if y8_1 then 1 else 0
    local zb = 31 * zd + 160 * (1 - zd)
    local zc = 550 * zd + 1330 * (1 - zd)
    if not ((zb * 3356 + zc * 2809 + zb * zc) % 16777213 == 1666036) then
        y8_1 = c_:FindFirstChildWhichIsA("BasePart", true)
    end
    return y8_1
end
local function fn883()
    gethui = wr
end
local function fn972()
    if not State.AutoEquipBest then
        return
    end
    wi("Equipping best pets")
    pcall(function()
        wM("Pen_PlaceBest")
    end)
end
local function fn973()
    return vG:FindFirstChild("WorldEggs")
end
local function fn985(bB)
    State.Status = bB
end
local function fn994(ar)
    local yh = typeof(cloneref) == "function" and typeof(ar) == "Instance"
    if yh then
        return cloneref(ar)
    end
    return ar
end
local function fn1003()
    local yx = not wo
    local yy = {}
    if not yx then
        yx = type(wo.InvokeServer) ~= "function"
    end
    if yx then
        table.insert(yy, "Net")
    end
    local yx_1 = not wg or type(wg.GetData) ~= "function"
    if yx_1 then
        table.insert(yy, "PlayerData")
    end
    if not v0(fireproximityprompt) then
        table.insert(yy, "fireproximityprompt")
    end
    local yx_2 = type(Drawing) ~= "table" or type(Drawing.new) ~= "function"
    if yx_2 then
        table.insert(yy, "Drawing")
    end
    return yy
end
local function fn1058(jT)
    local Es = jT and true or false
    State.AutoSteal = Es
    if State.AutoSteal then
        vQ("Steal", vW, wB)
    else
        v6("Steal")
        wi("Idle")
    end
end
local function fn1089(hi)
    local Cy_1
    local Cv = not vX
    local CC = if Cv then 1 else 0
    local CA = 2171 * CC + 816 * (1 - CC)
    local CB = 3254 * CC + 120 * (1 - CC)
    if not ((CA * 45 + CB * 1266 + CA * CB) % 16777213 == 11281693) then
        Cv = type(hi) ~= "table"
    end
    if Cv then
        return nil, nil
    end
    local Cv_1 = vX.GetOrder and vX.GetOrder()
    local Cw = {}
    local Cw_1
    local Cx = Cv_1 or Cw
    Cy_1, Cw_1 = nil, nil
    for i, v in ipairs(Cx) do
        local Cv_3 = vX.IsOwned and vX.IsOwned(hi, v)
        if Cv_3 then
            local Cv_4 = vX.GetSpeedMultiplier and vX.GetSpeedMultiplier(v)
            local Cx_2 = Cv_4
            if type(Cx_2) ~= "number" then
                Cx_2 = 0
            end
            if Cw_1 == nil or Cx_2 > Cw_1 then
                Cy_1, Cw_1 = v, Cx_2
            end
        end
    end
    return Cy_1, Cw_1
end
local function fn1100()
    return CoreGui
end
local function fn1143(kk)
    local E1 = kk and true or false
    State.AutoUpgradePen = E1
    if State.AutoUpgradePen then
        vQ("PenUpgrade", vx, vV)
    else
        v6("PenUpgrade")
    end
end
local function fn1149()
    return not wc.Unloaded
end
local function fn1196()
    local attr = LocalPlayer:GetAttribute("Plot")
    if type(attr) ~= "number" then
        return nil
    end
    local Map = vG:FindFirstChild("Map")
    local y2 = Map and Map:FindFirstChild("Plots")
    if not y2 then
        return nil
    end
    return y2:FindFirstChild(tostring(attr))
end
local function fn1205(kv)
    State.StealZones, State.StealZoneCount = wd(kv)
end
local function fn1208(kb)
    local EH = kb and true or false
    State.AutoEquipBest = EH
    if State.AutoEquipBest then
        vQ("Equip", vI, vR)
    else
        v6("Equip")
    end
end
local function fn1212(j5)
    local EE = j5 and true or false
    State.AutoOpen = EE
    if State.AutoOpen then
        vQ("Open", vM, wO)
    else
        v6("Open")
    end
end
local function fn1228(eF)
    local AS_1
    local AP = vB(eF)
    if not AP then
        return false
    end
    local AQ = eF:GetAttribute("Animal") or eF.Name
    local AR_2
    local AQ_1 = vL()
    wi("Stealing " .. tostring(AQ))
    local AY = 1
    local AW = wZ
    while true do
        if not (AY <= AW) then
            return vY(eF, AQ_1)
        end
        local AR_1 = not vS() or not State.AutoSteal
        if AR_1 then
            return false
        end
        if not eF.Parent then
            return true
        end
        if vY(eF, AQ_1) then
            break
        end
        AR_2, AS_1 = wn()
        if not AS_1 then
            return false
        end
        local Position = AP.Position
        vK(Position)
        task.wait(0.08)
        local AS_2 = select(2, wn())
        if not AS_2 then
            return false
        end
        if not wj(AS_2, Position, math.max(wv - 2, 8)) then
            vK(Position)
            task.wait(0.1)
            select(2, wn())
        end
        if not eF.Parent then
            return true
        end
        local AR_4 = v1(eF)
        if not AR_4 or AR_4.Enabled == false then
            task.wait(0.15)
            AR_4 = v1(eF)
        end
        if not AR_4 then
            return false
        end
        local AT_1 = tonumber(AR_4.MaxActivationDistance) or wv
        local AS_3 = select(2, wn())
        local AT_2 = AS_3 and not wj(AS_3, AP.Position, AT_1)
        if AT_2 then
            vK(AP.Position)
            task.wait(0.08)
        end
        wX(AR_4)
        local AR_5 = os.clock() + 0.7 + 0.35
        while true do
            local AS_4 = vS() and os.clock() < AR_5
            if AS_4 then
                if vY(eF, AQ_1) then
                    return true
                end
                task.wait(0.08)
                continue
            end
            break
        end
        AY += 1
    end
    return true
end
local function fn1241()
    local y4 = wP()
    if not y4 then
        return nil
    end
    local ToUpdate = y4:FindFirstChild("ToUpdate")
    local y6 = ToUpdate and ToUpdate:FindFirstChild("PetArea")
    local y5_1 = y6
    if y6 then
        y6 = y5_1:IsA("BasePart")
    end
    if y6 then
        return y5_1
    end
    return y4:FindFirstChild("CenterPoint")
end
local function fn1303(i5)
    local DE_1
    local DD = v9 and type(v9.GetColor) == "function"
    local DD_1
    if DD then
        DD_1, DE_1 = pcall(v9.GetColor, i5)
        local DF = DD_1 and typeof(DE_1) == "Color3"
        if DF then
            return DE_1
        end
        return Color3.fromRGB(255, 255, 255)
    end
    return Color3.fromRGB(255, 255, 255)
end
vx = nil
vy = nil
vz = nil
vA = nil
vB = nil
vC = nil
vD = nil
vE = nil
vG = nil
vI = nil
vK = nil
vL = nil
vM = nil
vP = nil
vQ = nil
vR = nil
vS = nil
vU = nil
vV = nil
vW = nil
vX = nil
vY = nil
v0 = nil
v1 = nil
v6 = nil
v7 = nil
v9 = nil
wc = nil
wd = nil
we = nil
wf = nil
wg = nil
wi = nil
local Players, vF, vH, vJ, vN, vO, vT, vZ, v_, v2, v3, v4, v5, v8, wa, wb, wh
wj = nil
LocalPlayer = nil
wl = nil
wn = nil
wo = nil
wr = nil
ws = nil
wt = nil
wv = nil
wy = nil
CoreGui = nil
wA = nil
wB = nil
wD = nil
wH = nil
wI = nil
wJ = nil
State = nil
wM = nil
wO = nil
wP = nil
wT = nil
wV = nil
wX = nil
wZ = nil
w2 = nil
w3 = nil
local Workspace, connection, Lighting, TeleportService, ww, wx, wC, GuiService, wF, wG, HttpService, wN, VirtualUser, wR, wS, UserInputService, wW, RunService, w_, w1
Workspace = nil
connection = nil
Lighting = nil
TeleportService = nil
ww = nil
wx = nil
wC = nil
GuiService = nil
wF = nil
wG = nil
HttpService = nil
wN = nil
VirtualUser = nil
wR = nil
wS = nil
UserInputService = nil
wW = nil
RunService = nil
w_ = nil
w1 = nil
if not game:IsLoaded() then
    game.Loaded:Wait()
end
Players, RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, TeleportService, Lighting, Workspace, LocalPlayer, wa, v8, v5, v3, vZ, vW, vP, vM, vI, vE, vD, vz, vx, wZ, wV, wR, wN, wF, wA, wv, wr = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local JJ_19 = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
TeleportService = game:GetService("TeleportService")
Lighting = game:GetService("Lighting")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local JJ_10 = "TempoRollerForAnimals"
wa = "Roller for Animals!"
v8 = "v0.4"
v5 = "https://discord.gg/K7Qxnxkk46"
v3 = "https://discord.gg/K7Qxnxkk46"
vZ = "https://tempohub.shop"
vW = 0.35
vP = 0.8
vM = 1.2
vI = 6
vE = 8
vD = 10
vz = 8
vx = 6
wZ = 4
wV = 2.5
wR = 6
wN = 4
wF = 3
wA = "CarryingEggs"
wv = 14
wr = fn1100
if getgenv then
    getgenv().gethui = wr
end
wc, vG, wG, v0, vS = nil, nil, nil, nil, nil
pcall(fn883)
local function JJ_21(Q)
    local x5
    local x6
    local x7
    x5 = nil
    x6 = nil
    x7 = nil
    local x8 = Q ~= ""
    local x9 = type(Q) == "string" and x8
    assert(x9, "Namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    x7 = getgenv()
    assert(type(x7) == "table", "getgenv did not return a table")
    local x8_1 = x7[Q]
    if x8_1 ~= nil then
        local x9_1 = type(x8_1) == "table" and type(x8_1.Unload) == "function"
        assert(x9_1, "Namespace is occupied")
        x8_1.Unload()
        assert(x7[Q] == nil, "Previous instance did not release its namespace")
    end
    x6 = {}
    x5 = { State = {}, Unloaded = false }
    x5.Track = function(W)
        assert(type(W) == "function", "Cleanup must be callable")
        if x5.Unloaded then
            W()
        else
            table.insert(x6, W)
        end
        return W
    end
    x5.Unload = function()
        local xZ_1
        local xY_1
        if x5.Unloaded then
            return
        end
        x5.Unloaded = true
        local xW = {}
        local x2 = #x6
        local x1 = -1
        while false and x2 <= 1 or true and x2 >= 1 do
            local x3 = x2
            local xX_1 = table.remove(x6, x3)
            xY_1, xZ_1 = pcall(xX_1)
            if not xY_1 then
                table.insert(xW, tostring(xZ_1))
            end
            x2 += x1
        end
        table.clear(x5.State)
        if #xW > 0 then
            error("Cleanup incomplete: " .. table.concat(xW, "; "), 0)
        end
        if x7[Q] == x5 then
            x7[Q] = nil
        end
    end
    x7[Q] = x5
    return x5
end
local JJ_21_3
wG = function(aj, ak)
    local yf = type(aj) == "table" and type(aj.Track) == "function"
    assert(yf, "FeatureAPI required")
    local yf_1 = type(ak) == "table" and type(ak.OnUnload) == "function"
    assert(yf_1, "UI library required")
    assert(type(ak.Unload) == "function", "UI unload required")
    aj.Track(function()
        if not ak.Unloaded then
            ak:Unload()
        end
    end)
    ak:OnUnload(function()
        aj.Unload()
    end)
end
wc = JJ_21(JJ_10)
local JJ_12 = fn994
v0 = fn35
vS = fn1149
local JJ_26 = JJ_12(JJ_19)
vG = JJ_12(Workspace)
local JJ_15 = JJ_26:WaitForChild("SharedModules", 20)
local ClientModules = JJ_26:WaitForChild("ClientModules", 20)
local JJ_6 = JJ_15
if JJ_6 then
    JJ_26 = 2
    repeat
        if JJ_26 * 19909383 + 3 + 2 <= JJ_26 * 19909383 + 3 + 2 + 1 then
            JJ_6 = JJ_15:WaitForChild("GameData", 20)
        else
            JJ_15 = JJ_6:WaitForChild("GameData", 20)
        end
        JJ_26 = (JJ_26 + 2) % 4
    until (JJ_26 * 1 + 3) % 4 == 3
end
JJ_10 = JJ_15
JJ_26 = JJ_6
if JJ_10 then
    JJ_19 = 1
    repeat
        local Mf = bit32.rrotate(bit32.bxor(bit32.lrotate(JJ_19, 19), string.byte(tostring(JJ_19))), 22)
        if bit32.bxor(bit32.lrotate(bit32.bxor(Mf, 1680105818), 0), 1680105818) == bit32.lrotate(Mf, 0) then
            JJ_10 = JJ_15:WaitForChild("Configs", 20)
        else
            JJ_15 = JJ_10:WaitForChild("Configs", 20)
        end
        JJ_19 = (JJ_19 + 2) % 4
    until (JJ_19 * 3 + 3) % 4 == 0
end
JJ_10 = function(aG)
    local yn_1
    local ym_1
    if typeof(aG) ~= "Instance" then
        return nil
    end
    ym_1, yn_1 = pcall(require, aG)
    local yo = ym_1 and type(yn_1) == "table"
    if yo then
        return yn_1
    end
    return nil
end
JJ_19 = JJ_15 and JJ_15:FindFirstChild("Net")
wo = JJ_10(JJ_19)
JJ_19 = ClientModules and ClientModules:FindFirstChild("PlayerData")
wg = JJ_10(JJ_19)
JJ_19 = JJ_26 and JJ_26:FindFirstChild("RarityData")
v9 = JJ_10(JJ_19)
JJ_19 = JJ_26 and JJ_26:FindFirstChild("AnimalsData")
JJ_10(JJ_19)
JJ_19 = JJ_26 and JJ_26:FindFirstChild("TrailsData")
vX = JJ_10(JJ_19)
JJ_19 = JJ_26 and JJ_26:FindFirstChild("SellData")
vN = JJ_10(JJ_19)
JJ_19 = JJ_26 and JJ_26:FindFirstChild("EggData")
local JJ_2 = JJ_10(JJ_19)
JJ_19 = JJ_26 and JJ_26:FindFirstChild("PenData")
vC = JJ_10(JJ_19)
JJ_19 = JJ_26 and JJ_26:FindFirstChild("ProgressionData")
w3 = JJ_10(JJ_19)
JJ_19 = JJ_26 and JJ_26:FindFirstChild("Data")
JJ_26 = JJ_10(JJ_19)
if JJ_2 then
    JJ_19 = nil
    JJ_10 = 3
    repeat
        JJ_12 = (vector.create((JJ_10 * 4 + 3) % 11 + 1, (JJ_10 * 10 + 7) % 13 + 1, (JJ_10 * 6 + 13) % 17 + 1))
        local JJ_21_1 = (vector.create((JJ_10 * 6 + 3) % 11 + 1, (JJ_10 * 5 + 12) % 13 + 1, (JJ_10 * 13 + 3) % 17 + 1))
        JJ_6 = (vector.create((JJ_10 * 4 + 4) % 11 + 1, (JJ_10 * 4 + 3) % 13 + 1, (JJ_10 * 13 + 5) % 17 + 1))
        JJ_15 = (vector.create((JJ_10 * 1 + 4) % 5 + 1, (JJ_10 * 5 + 5) % 7 + 1, (JJ_10 * 4 + 6) % 9 + 1))
        if vector.dot(vector.cross(JJ_12, (vector.cross(JJ_21_1, JJ_6))), JJ_15) == vector.dot(JJ_21_1 * vector.dot(JJ_12, JJ_6) - JJ_6 * vector.dot(JJ_12, JJ_21_1), JJ_15) + 4 then
            JJ_2 = type(JJ_19.CARRY_ATTRIBUTE) == "string"
        else
            JJ_19 = type(JJ_2.CARRY_ATTRIBUTE) == "string"
        end
        JJ_10 = (JJ_10 + 1) % 8
    until (JJ_10 * 7 + 2) % 8 == 6
    if JJ_19 then
        JJ_10 = 0
        repeat
            JJ_12 = { "ljwqgin", "tijd", "cfc", "wpeafvcjb", "qfnudg", "iezhqowxvfa", "awkgj", "mpgdvj", "kyh" }
            local Ll = JJ_10
            local JJ_21_2 = JJ_12[Ll % 9 + 1]
            if JJ_21_2:len() >= JJ_21_2:reverse():rep(Ll % 3 + 2):len() then
                JJ_2 = JJ_19.CARRY_ATTRIBUTE ~= ""
            else
                JJ_19 = JJ_2.CARRY_ATTRIBUTE ~= ""
            end
            JJ_10 = (JJ_10 + 4) % 8
        until (JJ_10 * 7 + 4) % 8 == 0
    end
    if JJ_19 then
        wA = JJ_2.CARRY_ATTRIBUTE
    end
    JJ_19 = nil
    JJ_10 = 0
    repeat
        local Lt = bit32.rrotate(bit32.bxor(bit32.lrotate(JJ_10, 21), string.byte(tostring(JJ_19))), 4)
        if bit32.bxor(bit32.lrotate(bit32.bxor(Lt, 457469952), 20), 111687) == bit32.lrotate(Lt, 20) then
            JJ_19 = type(JJ_2.PICKUP_DISTANCE) == "number"
        else
            JJ_2 = type(JJ_19.PICKUP_DISTANCE) == "number"
        end
        JJ_10 = (JJ_10 + 6) % 8
    until (JJ_10 * 3 + 6) % 8 == 0
    if JJ_19 then
        JJ_10 = 5
        repeat
            if (JJ_10 * 3 + 2) * 13 % 4 == ((JJ_10 * 3 + 2) * 13 + 6) % 4 then
                JJ_2 = JJ_19.PICKUP_DISTANCE > 0
            else
                JJ_19 = JJ_2.PICKUP_DISTANCE > 0
            end
            JJ_10 = (JJ_10 + 3) % 8
        until (JJ_10 * 1 + 1) % 8 == 1
    end
    if JJ_19 then
        wv = JJ_2.PICKUP_DISTANCE
    end
end
JJ_10 = v9
wI = {}
if JJ_10 then
    JJ_19 = 7
    repeat
        if (JJ_19 * 1 + 5) * 13 % 4 == ((JJ_19 * 1 + 5) * 13 + 15) % 4 then
            v9 = type(JJ_10.GetAll) == "function"
        else
            JJ_10 = type(v9.GetAll) == "function"
        end
        JJ_19 = (JJ_19 + 3) % 8
    until (JJ_19 * 7 + 5) % 8 == 3
end
if JJ_10 then
    JJ_2, JJ_21_3, JJ_12 = nil, nil, nil
    JJ_19 = 10
    repeat
        JJ_10 = (JJ_19 * 1 + 1) % 2 + 1
        if JJ_10 <= 1 then
            if JJ_19 * 14098587 + 9 + 4 >= JJ_19 * 14098587 + 9 + 4 + 2 then
                JJ_2 = JJ_12
            else
                JJ_12 = JJ_2
            end
            JJ_19 = (JJ_19 + 11) % 16
        else
            if (JJ_19 * 2 + 5) * 10 % 3 == ((JJ_19 * 2 + 5) * 10 + 2) % 3 then
                JJ_21_3, v9 = pcall(JJ_2.GetAll)
            else
                JJ_2, JJ_21_3 = pcall(v9.GetAll)
            end
            JJ_19 = (JJ_19 + 5) % 16
        end
    until (JJ_19 * 11 + 1) % 16 == 15
    if JJ_12 then
        JJ_10 = 0
        repeat
            local L9 = bit32.rrotate(bit32.bxor(bit32.lrotate(JJ_10, 19), string.byte(tostring(JJ_10))), 12)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(L9, 875253839), 2124289139), (bit32.bxor(bit32.band(L9, 3419713456), 701503772))), 2124289139), 701503772) == L9 then
                JJ_12 = type(JJ_21_3) == "table"
            else
                JJ_21_3 = type(JJ_12) == "table"
            end
            JJ_10 = (JJ_10 + 1) % 4
        until (JJ_10 * 3 + 3) % 4 == 2
    end
    if JJ_12 then
        for i, v in ipairs(JJ_21_3) do
            if type(v) == "string" then
                table.insert(wI, v)
            end
        end
    end
end
JJ_19 = nil
JJ_10 = 0
repeat
    local Mc = bit32.rrotate(bit32.bxor(bit32.lrotate(JJ_10, 17), string.byte(tostring(JJ_19))), 22)
    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(Mc, 178914745), 3584652378), (bit32.bxor(bit32.band(Mc, 4116052550), 1926242073))), 3584652378), 1926242073) ~= Mc then
        wI = #JJ_19 == 0
    else
        JJ_19 = #wI == 0
    end
    JJ_10 = (JJ_10 + 1) % 4
until (JJ_10 * 3 + 0) % 4 == 3
if JJ_19 then
    JJ_19 = v9
end
if JJ_19 then
    JJ_10 = 5
    repeat
        if (JJ_10 * 2 + 8) * 13 % 3 == ((JJ_10 * 2 + 8) * 13 + 8) % 3 then
            v9 = type(JJ_19.ORDER) == "table"
        else
            JJ_19 = type(v9.ORDER) == "table"
        end
        JJ_10 = (JJ_10 + 0) % 8
    until (JJ_10 * 3 + 1) % 8 == 0
end
if JJ_19 then
    for i, v in ipairs(v9.ORDER) do
        if type(v) == "string" then
            table.insert(wI, v)
        end
    end
end
if #wI == 0 then
    JJ_10 = 2
    repeat
        JJ_19 = {
            "bassp",
            "lidx",
            "jaza",
            "pmwjxrhgkbz",
            "liw",
            "dfywbztzs",
            "qepjl",
            "wvvyystv",
            "pfxzeur",
            "hhnn"
        }
        local Mk = JJ_10
        JJ_2 = JJ_19[Mk % 10 + 1]
        if JJ_2:len() <= JJ_2:gsub("(.)", "%1%1", Mk % 3 % 2 + 1):len() then
            wI = {
                "Common",
                "Uncommon",
                "Rare",
                "Epic",
                "Legendary",
                "Mythic",
                "Admin",
                "Celestial",
                "Eternal",
                "Ascended",
                "Exclusive"
            }
        else
            wI = {
                "Ascended",
                "Legendary",
                "Common",
                "Eternal",
                "Admin",
                "Celestial",
                "Mythic",
                "Uncommon",
                "Exclusive",
                "Epic",
                "Rare"
            }
        end
        JJ_10 = (JJ_10 + 0) % 4
    until (JJ_10 * 1 + 1) % 4 == 3
end
v4 = {}
for i, v in ipairs(wI) do
    v4[v] = i
end
JJ_10 = JJ_26
vU = {}
if JJ_10 then
    JJ_19 = 3
    repeat
        if (not JJ_19 and JJ_19 or not JJ_19 and not JJ_19) and (not JJ_19 and JJ_19 or (not JJ_19 or not JJ_19)) or (JJ_19 or not JJ_19) and (JJ_19 and not JJ_19) and ((not JJ_19 or not JJ_19) and (JJ_19 or JJ_19)) or not ((not JJ_19 and JJ_19 or not JJ_19 and not JJ_19) and (not JJ_19 and JJ_19 or (not JJ_19 or not JJ_19)) or (JJ_19 or not JJ_19) and (JJ_19 and not JJ_19) and ((not JJ_19 or not JJ_19) and (JJ_19 or JJ_19))) then
            JJ_10 = type(JJ_26.Zones) == "table"
        else
            JJ_26 = type(JJ_10.Zones) == "table"
        end
        JJ_19 = (JJ_19 + 0) % 8
    until (JJ_19 * 5 + 6) % 8 == 5
end
if JJ_10 then
    JJ_10 = {}
    for k, v in pairs(JJ_26.Zones) do
        JJ_26 = (tonumber(k))
        if not JJ_26 then
            JJ_19 = type(v) == "table" and tonumber(v.Index)
            JJ_26 = JJ_19
        end
        JJ_19 = JJ_26
        JJ_26 = type(v) == "table" and v.Name
        JJ_2 = JJ_26
        JJ_26 = type(JJ_2) == "string" and JJ_19
        if JJ_26 then
            JJ_10[JJ_19] = JJ_2
        end
    end
    local xS = 1
    while xS <= 32 do
        local xT = xS
        if JJ_10[xT] then
            table.insert(vU, JJ_10[xT])
        end
        xS += 1
    end
end
if #vU == 0 then
    JJ_26 = 2
    repeat
        JJ_10 = { "wfgxb", "xlkir", "kvohiratq", "mwc", "hmak", "jjzocpvof", "epfkfv", "wnbsbsup" }
        local LS = JJ_26
        JJ_19 = JJ_10[LS % 8 + 1]
        if JJ_19:len() >= JJ_19:reverse():rep(LS % 3 + 2):len() then
            vU = {
                "Jungle",
                "Meadow",
                "Winter",
                "Crystal Mines",
                "Desert",
                "Prehistoric",
                "Mystic Isles",
                "Coral Reef",
                "Celestial Heights"
            }
        else
            vU = {
                "Meadow",
                "Coral Reef",
                "Winter",
                "Desert",
                "Crystal Mines",
                "Jungle",
                "Mystic Isles",
                "Prehistoric",
                "Celestial Heights"
            }
        end
        JJ_26 = (JJ_26 + 1) % 4
    until (JJ_26 * 1 + 3) % 4 == 2
end
State, wD, wy, ws, connection, wl, wi, vy, wM, wn, v6, vQ, wb, vK, wP, we, vT, vL, vB, wS, wd, vO, w_, wC, wh, v1, wX, wj, vY, vH, v_, w1, wB, wx, wJ, v2, wO, vR, vA, vF, wf, w2, wH, wT, vV, wt, ww, v7, vJ, wW = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
State = wc.State
State.AutoSteal = false
State.AutoPlace = false
State.AutoOpen = false
State.AutoEquipBest = false
State.AutoBuyTrails = false
State.AutoEquipBestTrail = false
State.AutoClaimIndex = false
State.AutoSell = false
State.AutoUpgradeTreadmill = false
State.AutoUpgradePen = false
State.EggEsp = false
State.StealZones = {}
State.StealRarities = {}
State.EspRarities = {}
State.SellRarities = {}
State.StealZoneCount = 0
State.StealRarityCount = 0
State.EspRarityCount = 0
State.SellRarityCount = 0
State.Priority = "Nearest"
State.TeleportZone = vU[1]
State.Status = "Idle"
State.Stolen = 0
State.Placed = 0
State.Opened = 0
State.Sold = 0
wD = {}
wy = setmetatable({}, { __mode = "k" })
ws = {}
connection = nil
wl = 0
wi = fn985
wc.GetStatus = fn161
wc.RarityValues = fn70
wc.ZoneValues = fn515
wc.Support = fn1003
vy = fn549
wM = fn199
wn = fn350
v6 = fn342
vQ = function(b7, b8, b9)
    v6(b7)
    local cb = {}
    wD[b7] = cb
    task.spawn(function()
        local yT_1
        while true do
            local yS = vS() and wD[b7] == cb
            local yS_1
            if yS then
                yS_1, yT_1 = pcall(b9)
                if not yS_1 then
                    wi(tostring(yT_1))
                end
                task.wait(b8)
                continue
            end
            break
        end
    end)
end
wb = function(cq)
    wl += 1
    local cs = wl
    return cq(function()
        local yV = cs == wl
        local yW = vS() and yV
        return yW
    end)
end
vK = function(cy)
    local yY
    yY = nil
    local yZ_1
    yZ_1, yY = wn()
    local yZ_2 = not yY or typeof(cy) ~= "Vector3"
    if yZ_2 then
        return false
    end
    local yZ_3 = pcall(function()
        yY.AssemblyLinearVelocity = Vector3.zero
        yY.AssemblyAngularVelocity = Vector3.zero
        yY.CFrame = CFrame.new(cy + Vector3.new(0, 4, 0))
    end)
    return yZ_3
end
wP = fn1196
we = fn1241
vT = fn973
vL = fn74
vB = fn879
wS = fn348
wd = fn4
vO = fn54
w_ = fn333
wC = fn51
wh = fn368
v1 = fn108
wX = function(dT)
    local Ah = not dT or not dT.Parent
    local Ah_6
    if Ah then
        return false
    elseif v0(fireproximityprompt) then
        local Ah_1 = pcall(fireproximityprompt, dT)
        if Ah_1 then
            return true
        end
        local Ah_2 = pcall(fireproximityprompt, dT, 1)
        if Ah_2 then
            return true
        end
        local Ah_3 = tonumber(dT.HoldDuration) or 0
        pcall(function()
            dT:InputHoldBegin()
        end)
        if not Ah_6 then
            return false
        end
        task.wait(Ah_3 + 0.2)
        pcall(function()
            dT:InputHoldEnd()
        end)
        return true
    else
        local Ah_5 = tonumber(dT.HoldDuration) or 0
        Ah_6 = pcall(function()
            dT:InputHoldBegin()
        end)
        if not Ah_6 then
            return false
        end
        task.wait(Ah_5 + 0.2)
        pcall(function()
            dT:InputHoldEnd()
        end)
        return true
    end
end
wj = fn687
vY = fn726
vH = function(eb)
    local AA_1
    local Ay_1
    local Ax_1
    local Aw = vT()
    local Aw_3
    if not Aw then
        return nil
    end
    Ay_1, Ax_1 = nil, nil
    for i, child in ipairs(Aw:GetChildren()) do
        local AK = child
        local Aw_1 = AK:IsA("Model") and AK.Parent and not wC(AK) and vO(AK)
        if Aw_1 then
            local Aw_2 = v1(AK)
            local Az = Aw_2 and Aw_2.Enabled ~= false
            local Az_1
            if Az then
                Aw_3, Az_1 = pcall(function()
                    return AK:GetPivot().Position
                end)
                if Aw_3 then
                    if State.Priority == "Rarest" then
                        local Aw_4 = v4[AK:GetAttribute("Rarity")] or 0
                        AA_1 = -Aw_4
                    elseif State.Priority == "Biggest" then
                        local Aw_5 = tonumber(AK:GetAttribute("Size")) or 0
                        AA_1 = -Aw_5
                    else
                        AA_1 = (Az_1 - eb).Magnitude
                    end
                    local Aw_6 = Ax_1 == nil
                    local AE = if Aw_6 then 1 else 0
                    local AC = 3932 * AE + 3512 * (1 - AE)
                    local AD = 704 * AE + 3192 * (1 - AE)
                    if not ((AC * 3023 + AD * 931 + AC * AD) % 16777213 == 15309988) then
                        Aw_6 = AA_1 < Ax_1
                    end
                    if Aw_6 then
                        Ay_1, Ax_1 = AK, AA_1
                    end
                end
            end
        end
    end
    return Ay_1
end
v_ = fn590
w1 = fn1228
wB = function()
    local A2
    local A4_1
    local A3_1
    if not State.AutoSteal then
        return
    end
    A3_1, A4_1 = wn()
    if not A4_1 then
        return
    end
    if vL() then
        wb(function()
            v_()
        end)
        return
    end
    A2 = vH(A4_1.Position)
    if not A2 then
        wi("No matching eggs")
        return
    end
    wb(function()
        local A0 = w1(A2)
        if A0 then
            wh(A2, wR)
            State.Stolen = State.Stolen + 1
            if vL() then
                v_()
            end
        else
            wh(A2, wV)
            wi("Missed egg, retrying")
        end
    end)
end
wx = function(fv)
    local Ba_1
    local A6 = not fv or not fv:IsA("BasePart")
    if A6 then
        return nil
    end
    local A6_1 = fv.Size.X * 0.5 - wF
    local A7 = fv.Size.Z * 0.5 - wF
    if A6_1 <= 0 or A7 <= 0 then
        return fv.Position
    end
    local A8_1 = {}
    local PenEggs = vG:FindFirstChild("PenEggs")
    local A9_1
    if PenEggs then
        for i, child in ipairs(PenEggs:GetChildren()) do
            local Bl = child
            if Bl:IsA("Model") then
                A9_1, Ba_1 = pcall(function()
                    return Bl:GetPivot().Position
                end)
                if A9_1 then
                    local A9_2 = fv.CFrame:PointToObjectSpace(Ba_1)
                    table.insert(A8_1, Vector2.new(A9_2.X, A9_2.Z))
                end
            end
        end
    end
    local A9_3 = -A6_1
    while A9_3 <= A6_1 do
        local Ba_2 = -A7
        while Ba_2 <= A7 do
            local Bb = true
            for i, v in ipairs(A8_1) do
                if (v - Vector2.new(A9_3, Ba_2)).Magnitude < 3.4 then
                    Bb = false
                    break
                end
            end
            if Bb then
                local Bb_1 = fv.CFrame:PointToWorldSpace(Vector3.new(A9_3, fv.Size.Y * 0.5, Ba_2))
                return Bb_1
            end
            Ba_2 += wN
        end
        A9_3 += wN
    end
    return fv.Position
end
wJ = function()
    local BE, BF
    if not State.AutoPlace then
        return
    end
    BF = wS()
    if #BF == 0 then
        return
    end
    BE = we()
    if not BE then
        wi("No plot assigned")
        return
    end
    wb(function()
        local Bt
        local Bw_1
        local Bv_1
        vK(BE.Position)
        task.wait(0.15)
        Bw_1, Bv_1, Bt = wn()
        for i, v in ipairs(BF) do
            local BD = v
            local Bv_2 = not vS() or not State.AutoPlace
            if Bv_2 then
                break
            else
                local attr = BD:GetAttribute("EggId")
                local Bv_3 = attr ~= ""
                local Bw_2 = type(attr) == "string" and Bv_3
                if Bw_2 then
                    local Bu = wx(BE)
                    if not Bu then
                        wi("No free place spot")
                        break
                    end
                    if Bt then
                        pcall(function()
                            Bt:EquipTool(BD)
                        end)
                    end
                    task.wait(0.12)
                    wi("Placing egg")
                    local Bv_4 = pcall(function()
                        wM("Egg_Place", attr, Bu.X, Bu.Z)
                    end)
                    if Bv_4 then
                        State.Placed = State.Placed + 1
                    end
                    task.wait(0.25)
                end
            end
        end
    end)
end
v2 = fn497
wO = function()
    if not State.AutoOpen then
        return
    end
    for i, v in ipairs(v2()) do
        local Ce = v
        local B3 = not vS() or not State.AutoOpen
        if B3 then
            break
        end
        local B3_1 = tonumber(Ce.Remaining)
        if B3_1 ~= nil and B3_1 <= 0 then
            wi("Opening egg")
            local B3_2 = pcall(function()
                wM("Egg_Open", Ce.Id)
            end)
            if B3_2 then
                State.Opened = State.Opened + 1
            end
            task.wait(0.35)
        end
    end
end
vR = fn972
vA = function()
    if not State.AutoBuyTrails or not vX then
        return
    end
    local Cg_1 = vy()
    if not Cg_1 then
        return
    end
    local Ch_1 = tonumber(Cg_1.money) or 0
    local Ci = Ch_1
    local Ch_2 = vX.GetOrder and vX.GetOrder()
    local Ck = Ch_2 or {}
    for i, v in ipairs(Ck) do
        local Cu = v
        local Ch_4 = not vS() or not State.AutoBuyTrails
        if Ch_4 then
            break
        end
        local Ch_5 = vX.IsOwned and vX.IsOwned(Cg_1, Cu)
        local Ch_6 = vX.GetCashPrice and vX.GetCashPrice(Cu)
        local Ck_1 = not Ch_5
        if Ck_1 then
            Ck_1 = type(Ch_6) == "number"
        end
        if Ck_1 then
            Ck_1 = Ch_6 > 0
        end
        if Ck_1 then
            Ck_1 = Ci >= Ch_6
        end
        if Ck_1 then
            local Ch_7 = vX.GetDisplayName and vX.GetDisplayName(Cu)
            local Cj_3 = Ch_7 or Cu
            wi("Buying " .. tostring(Cj_3))
            local Ch_8 = pcall(function()
                wM("Trail_Buy", Cu)
            end)
            if Ch_8 then
                task.wait(0.4)
                local Ch_9 = vy() or Cg_1
                Cg_1 = Ch_9
                local Ch_10 = tonumber(Cg_1.money) or Ci
                Ci = Ch_10
            end
        end
    end
end
vF = fn1089
wf = function()
    local CM
    if not State.AutoEquipBestTrail or not vX then
        return
    end
    local CN_1 = vy()
    if not CN_1 then
        return
    end
    CM = vF(CN_1)
    local CO_1 = CM == ""
    local CP = type(CM) ~= "string" or CO_1
    if CP then
        return
    end
    local CO_2 = vX.GetEquipped and vX.GetEquipped(CN_1)
    if CO_2 == CM then
        return
    end
    local CN_3 = vX.GetDisplayName and vX.GetDisplayName(CM)
    local CO_3 = CN_3 or CM
    wi("Equipping " .. tostring(CO_3))
    pcall(function()
        wM("Trail_Equip", CM)
    end)
end
w2 = fn219
wH = function()
    local CV
    local CY_1
    local CW = not vN
    local CW_5
    local CX = not State.AutoSell
    local CX_2, CX_4
    local C1 = if CX then 1 else 0
    local C_ = 3021 * C1 + 1006 * (1 - C1)
    local C0 = 3069 * C1 + 879 * (1 - C1)
    if not ((C_ * 2152 + C0 * 147 + C_ * C0) % 16777213 == 16223784) then
        CX = CW
    end
    if CX then
        return
    end
    local CW_1 = vy()
    local CX_1 = not CW_1 or type(CW_1.Animals) ~= "table"
    if CX_1 then
        return
    end
    CY_1, CX_2 = vN.QuoteAll(CW_1)
    local CW_2 = type(CY_1) ~= "table" or #CY_1 == 0
    if CW_2 then
        return
    end
    CV = {}
    for i, v in ipairs(CY_1) do
        local CW_3 = type(v) == "table" and type(v.Id) == "string"
        if CW_3 then
            local Rarity = v.Rarity
            local CX_3 = State.SellRarityCount == 0
            if not CX_3 then
                local CY_2 = type(Rarity) == "string" and State.SellRarities[Rarity]
                CX_3 = CY_2
            end
            if CX_3 then
                table.insert(CV, v.Id)
            end
        end
    end
    if #CV == 0 then
        return
    end
    wi(string.format("Selling %d pets", #CV))
    CW_5, CX_4 = pcall(function()
        return wM("Sell_All", CV)
    end)
    if CW_5 and CX_4 then
        State.Sold = State.Sold + #CV
    end
end
wT = fn12
vV = fn757
wt = function(iH)
    local Map = vG:FindFirstChild("Map")
    local Dv_2
    local Dw = Map and Map:FindFirstChild("Spawns")
    local Dw_1
    local Dv_1 = Dw
    if Dw then
        Dw = Dv_1:FindFirstChild(iH)
    end
    local Du = Dw
    if not Du then
        return nil
    elseif Du:IsA("BasePart") then
        return Du.Position
    else
        Dv_2, Dw_1 = pcall(function()
            return Du:GetPivot().Position
        end)
        if Dv_2 then
            return Dw_1
        end
        local BasePart = Du:FindFirstChildWhichIsA("BasePart", true)
        return BasePart and BasePart.Position or nil
    end
end
wc.TeleportToPen = fn491
wc.TeleportToZone = fn197
ww = fn1303
v7 = function()
    for k, v in pairs(ws) do
        local DR = v
        pcall(function()
            if DR.Destroy then
                DR:Destroy()
            elseif DR.Remove then
                DR:Remove()
            else
                DR.Visible = false
            end
        end)
        ws[k] = nil
    end
    if connection then
        connection:Disconnect()
        connection = nil
    end
end
vJ = fn451
wW = function()
    local Ec_1
    local Eb_1
    local Ea_1, Ea_2
    if not State.EggEsp then
        return
    end
    local CurrentCamera = vG.CurrentCamera
    if not CurrentCamera then
        return
    end
    local D8 = vT()
    local D9 = {}
    if D8 then
        for i, child in ipairs(D8:GetChildren()) do
            local D6
            local Ek = child
            local D8_1 = Ek:IsA("Model") and w_(Ek)
            if D8_1 then
                D9[Ek] = true
                local D8_2 = vJ(Ek)
                if D8_2 then
                    D6 = vB(Ek)
                    Ea_1, Eb_1 = pcall(function()
                        local D_ = D6 and D6.Position
                        local D0 = D_ or Ek:GetPivot().Position
                        return D0
                    end)
                    if Ea_1 then
                        Ec_1, Ea_2 = CurrentCamera:WorldToViewportPoint(Eb_1)
                        if Ea_2 and Ec_1.Z > 0 then
                            local Ea_3 = Ek:GetAttribute("Rarity") or "?"
                            local Ea_4 = Ek:GetAttribute("Animal") or Ek.Name
                            D8_2.Text = string.format("%s · %s", tostring(Ea_4), tostring(Ea_3))
                            D8_2.Color = ww(Ea_3)
                            D8_2.Position = Vector2.new(Ec_1.X, Ec_1.Y - 18)
                            D8_2.Visible = true
                        else
                            D8_2.Visible = false
                        end
                    end
                end
            end
        end
    end
    for k, v in pairs(ws) do
        local Eq = v
        if not D9[k] or not k.Parent then
            pcall(function()
                if Eq.Destroy then
                    Eq:Destroy()
                elseif Eq.Remove then
                    Eq:Remove()
                else
                    Eq.Visible = false
                end
            end)
            ws[k] = nil
        end
    end
end
wc.SetAutoSteal = fn1058
wc.SetAutoPlace = fn402
wc.SetAutoOpen = fn1212
wc.SetAutoEquipBest = fn1208
wc.SetAutoBuyTrails = fn855
wc.SetAutoEquipBestTrail = fn631
wc.SetAutoClaimIndex = fn607
wc.SetAutoSell = fn395
wc.SetAutoUpgradeTreadmill = fn237
wc.SetAutoUpgradePen = fn1143
wc.SetEggEsp = function(kl)
    local E8
    local Fa = kl and true or false
    State.EggEsp = Fa
    if State.EggEsp then
        if not connection then
            E8 = 0
            connection = RunService.RenderStepped:Connect(function()
                local E3 = not vS()
                local E7 = if E3 then 1 else 0
                local E5 = 3264 * E7 + 3674 * (1 - E7)
                local E6 = 3659 * E7 + 1043 * (1 - E7)
                if not ((E5 * 2382 + E6 * 4069 + E5 * E6) % 16777213 == 1051869) then
                    E3 = not State.EggEsp
                end
                if E3 then
                    return
                end
                local E3_1 = os.clock()
                if E3_1 - E8 < 0.05 then
                    return
                end
                E8 = E3_1
                wW()
            end)
            wc.Track(function()
                v7()
            end)
        end
    else
        v7()
    end
end
wc.SetStealZones = fn1205
wc.SetStealRarities = fn394
wc.SetEspRarities = fn408
wc.SetSellRarities = fn249
wc.SetPriority = fn56
wc.SetTeleportZone = fn843
wc.Track(fn828)
JJ_10 = function()
    local onDiscord
    onDiscord = nil
    local ThemeManager, Options, Jm, Jn, SaveManager, Library, Toggles
    Library = getgenv().Library
    ThemeManager = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = Library.Toggles
    Options = Library.Options
    wG(wc, Library)
    Jn = function(k_, k0)
        local Fr = v0(setclipboard) and setclipboard
        local Fs = Fr
        if not Fs then
            local Fr_1 = v0(toclipboard) and toclipboard
            Fs = Fr_1 or nil
        end
        local Fr_2 = Fs
        if not Fr_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local Fs_1 = pcall(Fr_2, k_)
        if Fs_1 then
            Library:Notify(k0)
        else
            Library:Notify("Failed to copy")
        end
    end
    onDiscord = function()
        Jn(v5, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = v5, Copyable = true }, "|", wa, "|", v8 },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(false)
    Jm = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gamepad-2"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
    local function Js_1(lj)
        local DiscordGroup = lj:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    for k, v in Jm do
        if k ~= "Info" then
            Js_1(v)
        end
    end
    local function Jt()
        local mg
        local StealGroup = Jm.Main:AddRightGroupbox("Steal", "egg")
        local Label = StealGroup:AddLabel(wc.GetStatus(), true)
        StealGroup:AddDivider()
        StealGroup:AddToggle("AutoSteal", {
            Text = "Auto Steal Eggs",
            Default = false,
            Callback = function(lt)
                wc.SetAutoSteal(lt)
            end
        })
        StealGroup:AddDropdown("StealZones", {
            Text = "Zone Filter",
            Values = wc.ZoneValues(),
            Default = {},
            Multi = true,
            AllowNull = true,
            Expandable = true,
            Callback = function(lv)
                wc.SetStealZones(lv)
            end
        })
        StealGroup:AddDropdown("StealRarities", {
            Text = "Rarity Filter",
            Values = wc.RarityValues(),
            Default = {},
            Multi = true,
            AllowNull = true,
            Expandable = true,
            Callback = function(lx)
                wc.SetStealRarities(lx)
            end
        })
        StealGroup:AddDropdown("StealPriority", {
            Text = "Target Priority",
            Values = { "Nearest", "Rarest", "Biggest" },
            Default = "Nearest",
            Callback = function(lz)
                wc.SetPriority(lz)
            end
        })
        StealGroup:AddToggle("EggEsp", {
            Text = "Egg ESP",
            Default = false,
            Callback = function(lB)
                wc.SetEggEsp(lB)
            end
        })
        StealGroup:AddDropdown("EspRarities", {
            Text = "ESP Rarity Filter",
            Values = wc.RarityValues(),
            Default = {},
            Multi = true,
            AllowNull = true,
            Expandable = true,
            Callback = function(lD)
                wc.SetEspRarities(lD)
            end
        })
        local FarmGroup = Jm.Main:AddLeftGroupbox("Farm", "rabbit")
        FarmGroup:AddToggle("AutoPlaceEggs", {
            Text = "Auto Place Eggs",
            Default = false,
            Callback = function(lG)
                wc.SetAutoPlace(lG)
            end
        })
        FarmGroup:AddToggle("AutoOpenEggs", {
            Text = "Auto Open Eggs",
            Default = false,
            Callback = function(lI)
                wc.SetAutoOpen(lI)
            end
        })
        FarmGroup:AddToggle("AutoEquipBest", {
            Text = "Auto Equip Best Pets",
            Default = false,
            Callback = function(lK)
                wc.SetAutoEquipBest(lK)
            end
        })
        FarmGroup:AddToggle("AutoBuyTrails", {
            Text = "Auto Buy Trails",
            Default = false,
            Callback = function(lM)
                wc.SetAutoBuyTrails(lM)
            end
        })
        FarmGroup:AddToggle("AutoEquipBestTrail", {
            Text = "Auto Equip Best Trail",
            Default = false,
            Callback = function(lO)
                wc.SetAutoEquipBestTrail(lO)
            end
        })
        FarmGroup:AddToggle("AutoClaimIndex", {
            Text = "Auto Claim Index",
            Default = false,
            Callback = function(lQ)
                wc.SetAutoClaimIndex(lQ)
            end
        })
        local SellGroup = Jm.Main:AddLeftGroupbox("Sell", "hand-coins")
        SellGroup:AddToggle("AutoSell", {
            Text = "Auto Sell",
            Default = false,
            Callback = function(lT)
                wc.SetAutoSell(lT)
            end
        })
        SellGroup:AddDropdown("SellRarities", {
            Text = "Sell Rarities",
            Values = wc.RarityValues(),
            Default = {},
            Multi = true,
            AllowNull = true,
            Expandable = true,
            Callback = function(lV)
                wc.SetSellRarities(lV)
            end
        })
        local UpgradesGroup = Jm.Main:AddRightGroupbox("Upgrades", "arrow-up")
        UpgradesGroup:AddToggle("AutoUpgradeTreadmill", {
            Text = "Auto Upgrade Treadmill",
            Default = false,
            Callback = function(lY)
                wc.SetAutoUpgradeTreadmill(lY)
            end
        })
        UpgradesGroup:AddToggle("AutoUpgradePen", {
            Text = "Auto Upgrade Pen",
            Default = false,
            Callback = function(l_)
                wc.SetAutoUpgradePen(l_)
            end
        })
        local TravelGroup = Jm.Main:AddRightGroupbox("Travel", "map-pin")
        TravelGroup:AddButton({
            Text = "Teleport to Pen",
            Func = function()
                wc.TeleportToPen()
            end
        })
        TravelGroup:AddDropdown("TeleportZone", {
            Text = "Zone",
            Values = wc.ZoneValues(),
            Default = vU[1],
            Callback = function(l5)
                wc.SetTeleportZone(l5)
            end
        })
        TravelGroup:AddButton({
            Text = "Teleport to Zone",
            Func = function()
                wc.TeleportToZone(Options.TeleportZone.Value)
            end
        })
        mg = task.spawn(function()
            while true do
                task.wait(0.5)
                if Library.Unloaded then
                    break
                end
                pcall(function()
                    Label:SetText(wc.GetStatus())
                end)
            end
        end)
        wc.Track(function()
            if coroutine.status(mg) ~= "dead" then
                pcall(task.cancel, mg)
            end
        end)
    end
    Jt()
    local function Js_2()
        local FT
        local FP
        local FY
        local FU
        FP = nil
        FT = nil
        FU = nil
        FY = nil
        local FM, Label2, Label3, FQ, FR, Label, FV, FW, FX
        FY = function(mk)
            return (tostring(mk):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
        end
        FU = function(mm, mn)
            return string.format('<font color="%s">%s</font>', mn, FY(mm))
        end
        FM = function(mq, mr, ms)
            return string.format("<b>%s</b> %s %s", mq, FU("-", "#5a6070"), FU(mr, ms))
        end
        local FZ = "#8b93a3"
        FX = "#7fd47f"
        FR = "#e8a34d"
        local F_ = "#6ec1ff"
        local F0 = wc.Support()
        local F1 = #F0 == 0 and "ready"
        local F2 = F1 or "limited: " .. table.concat(F0, ", ")
        FW = "Unknown"
        pcall(function()
            local FB_1
            local FA_1
            if v0(identifyexecutor) then
                FB_1, FA_1 = identifyexecutor()
                local FC = FB_1 ~= ""
                local FD = type(FB_1) == "string" and FC
                if FD then
                    local FC_1 = type(FA_1) == "string" and FA_1 ~= "" and FB_1 .. " " .. FA_1
                    FW = FC_1 or FB_1
                end
            end
        end)
        FP = os.clock()
        FV = function()
            local FF = math.floor(os.clock() - FP)
            if FF < 60 then
                return FF .. "s"
            elseif FF < 3600 then
                return string.format("%dm %ds", math.floor((FF) / (60)), FF % 60)
            else
                return string.format("%dh %dm", math.floor((FF) / (3600)), math.floor((FF % 3600) / (60)))
            end
        end
        local UserGroup = Jm.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(FM("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, FX), true)
        UserGroup:AddLabel(FM("UserId", tostring(LocalPlayer.UserId), F_), true)
        UserGroup:AddLabel(FM("Executor", FW .. "  " .. F2, FX), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(FM("Session", FV(), FR), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                Jn(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                Jn("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = Jm.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(FM("Game", wa, F_), true)
        Label2 = SessionGroup:AddLabel(FM("Players", "0/0", FX), true)
        FQ = tostring(game.JobId)
        local F__1 = #FQ > 18 and string.sub(FQ, 1, 18) .. "..."
        local F1_2 = F__1 or FQ
        SessionGroup:AddLabel(FM("Job", F1_2, FZ), true)
        Label = SessionGroup:AddLabel(FM("Ping", "0 ms", FR), true)
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
                Jn(FQ, "Copied Job ID")
            end
        })
        FT = task.spawn(function()
            local FI_1
            local FH_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(FM("Session", FV(), FR))
                Label2:SetText(FM("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), FX))
                FH_1, FI_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local FH_2 = FH_1 and FI_1 .. " ms" or "n/a"
                Label:SetText(FM("Ping", FH_2, FR))
            end
        end)
        wc.Track(function()
            if coroutine.status(FT) ~= "dead" then
                pcall(task.cancel, FT)
            end
        end)
        local SocialsGroup = Jm.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                Jn(v3, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                Jn(vZ, "Copied website link")
            end
        })
    end
    Js_2()
    local function Js_3()
        local nH
        local nF
        local nI
        local nG
        local MovementGroup = Jm.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = Jm.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        nI = {}
        nG = {}
        nH = {}
        nF = {}
        local nE = {}
        local function nJ()
            for k, v in nF do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(nF)
        end
        local function nN()
            for k, v in nG do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(nG)
        end
        local function nR()
            for k, v in nH do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(nH)
        end
        local function nV(nW)
            if not nW:IsA("ProximityPrompt") then
                return
            end
            if nI[nW] == nil then
                nI[nW] = {
                    HoldDuration = nW.HoldDuration,
                    MaxActivationDistance = nW.MaxActivationDistance,
                    RequiresLineOfSight = nW.RequiresLineOfSight
                }
            end
            nW.HoldDuration = 0
            nW.MaxActivationDistance = 50
            nW.RequiresLineOfSight = false
        end
        local function nY()
            for k, v in nI do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(nI)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                nR()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                nN()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                nJ()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                    pcall(nV, v)
                end
            else
                nY()
            end
        end)
        table.insert(nE, Workspace.DescendantAdded:Connect(function(og)
            if Toggles.InstantProximityPrompt.Value then
                nV(og)
            end
        end))
        table.insert(nE, RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if nF[v] == nil then
                        nF[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(nE, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local GY = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and GY then
                GY:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(nE, RunService.RenderStepped:Connect(function(oF)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local G3 = Character and Character:FindFirstChildOfClass("Humanoid")
            local G4 = Character
            if G4 then
                G4 = Character:FindFirstChild("HumanoidRootPart")
            end
            local G2_1 = G4
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and G3 then
                if nG[G3] == nil then
                    nG[G3] = G3.WalkSpeed
                end
                G3.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and G2_1 and G3 and CurrentCamera then
                if nH[G3] == nil then
                    nH[G3] = G3.PlatformStand
                end
                G3.PlatformStand = true
                local G4_4 = Vector3.zero
                local Ha = if not UserInputService:GetFocusedTextBox() then 1 else 0
                if Ha == 1 then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        G4_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        G4_4 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        G4_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        G4_4 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        G4_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        G4_4 -= Vector3.new(0, 1, 0)
                    end
                end
                G2_1.AssemblyLinearVelocity = Vector3.zero
                if G4_4.Magnitude > 0 then
                    G2_1.CFrame = G2_1.CFrame + G4_4.Unit * Options.FlySpeed.Value * oF
                end
            end
        end))
        wc.Track(function()
            for k, v in nE do
                v:Disconnect()
            end
            nJ()
            nN()
            nR()
            nY()
        end)
    end
    Js_3()
    local function Js_4()
        local oX = {}
        local oW = {}
        local oY
        local o_ = 0
        local oZ = false
        local o0 = 0
        local o1 = os.clock()
        local MenuGroup = Jm.Settings:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        local Label = MenuGroup:AddLabel("AFK triggers: 0")
        local function o5()
            local CurrentCamera
            CurrentCamera = Workspace.CurrentCamera
            local Hj = not CurrentCamera or not v0(VirtualUser.CaptureController)
            local Hn = if Hj then 1 else 0
            local Hl = 1631 * Hn + 1861 * (1 - Hn)
            local Hm = 1905 * Hn + 969 * (1 - Hn)
            if not ((Hl * 2288 + Hm * 1058 + Hl * Hm) % 16777213 == 8854273) then
                Hj = not v0(VirtualUser.ClickButton2)
            end
            if Hj then
                return false
            end
            local Hj_1 = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            end)
            if not Hj_1 then
                return false
            end
            o0 += 1
            o1 = os.clock()
            pcall(function()
                Label:SetText("AFK triggers: " .. o0)
            end)
            return true
        end
        local function pn(po)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not po)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not po
                end
            end)
            if not po then
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
        local function pD(pE)
            if pE.ClassName == "ParticleEmitter" or pE.ClassName == "Trail" or pE.ClassName == "Smoke" or pE.ClassName == "Fire" or pE.ClassName == "Sparkles" or pE.ClassName == "Explosion" or pE.ClassName == "Beam" then
                if oX[pE] == nil then
                    oX[pE] = pE.Enabled
                end
                pcall(function()
                    pE.Enabled = false
                end)
            end
        end
        local function pI()
            for k, v in oX do
                local HE = k
                local HG = v
                if HE.Parent then
                    pcall(function()
                        HE.Enabled = HG
                    end)
                end
            end
            table.clear(oX)
            if oY then
                pcall(function()
                    settings().Rendering.QualityLevel = oY.Quality
                end)
                Lighting.GlobalShadows = oY.Shadows
                Lighting.FogEnd = oY.Fog
                oY = nil
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(pT)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not pT)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(pY)
                if pY then
                    if not oY then
                        oY = {
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
                    for k, v in Workspace:QueryDescendants("ParticleEmitter, Trail, Smoke, Fire, Sparkles, Beam") do
                        pD(v)
                    end
                else
                    pI()
                end
            end
        })
        MenuGroup:AddToggle("HideUIOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        table.insert(oW, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value then
                o5()
            end
        end))
        local qg = task.spawn(function()
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                local HS = Toggles.AntiAfk.Value and os.clock() - o1 >= 60
                if HS then
                    o5()
                end
                if Toggles.AntiGameplayPause.Value then
                    pn(true)
                end
            end
        end)
        Toggles.AntiGameplayPause:OnChanged(function(qh)
            pn(qh)
        end)
        pn(true)
        local function qj()
            local H3
            if oZ or not Toggles.AutoReconnect.Value then
                return
            end
            oZ = true
            o_ += 1
            H3 = o_
            task.spawn(function()
                for i = 1, 2 do
                    local H2 = i
                    if Library.Unloaded or not Toggles.AutoReconnect.Value or H3 ~= o_ then
                        break
                    end
                    local wait = task.wait
                    local HY_1 = H2 == 1 and 1 or 3
                    wait(HY_1)
                    if H3 ~= o_ then
                        break
                    end
                    pcall(function()
                        if H2 == 1 and game.JobId ~= "" then
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                        else
                            TeleportService:Teleport(game.PlaceId, LocalPlayer)
                        end
                    end)
                end
                oZ = false
            end)
        end
        table.insert(oW, GuiService.ErrorMessageChanged:Connect(function()
            if Toggles.AutoReconnect.Value then
                qj()
            end
        end))
        pcall(function()
            table.insert(oW, TeleportService.TeleportInitFailed:Connect(function(qK)
                if qK == LocalPlayer and Toggles.AutoReconnect.Value then
                    qj()
                end
            end))
        end)
        local ScriptGroup = Jm.Settings:AddLeftGroupbox("Script", "scroll-text")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        wc.Track(function()
            for k, v in oW do
                v:Disconnect()
            end
            local Ii = if coroutine.status(qg) ~= "dead" then 1 else 0
            if Ii == 1 then
                pcall(task.cancel, qg)
            end
            pI()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    Js_4()
    local function Js_5()
        local Je, Jf, Jg, Jh
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("MyScriptHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(Jm.Settings)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/RollerForAnimals")
        local Ji = SaveManager:BuildConfigSection(Jm.Settings)
        Jh = function(q8, q9)
            local Ik_1 = (q8 == "Toggle" and Toggles or Options)[q9]
            local Ij_2 = type(Ik_1) == "table" and Ik_1.Type == q8
            local Ij_3 = Ij_2 and Ik_1
            local Ip = if Ij_3 then 1 else 0
            local In = 1418 * Ip + 3550 * (1 - Ip)
            local Io = 1784 * Ip + 845 * (1 - Ip)
            if not ((In * 2066 + Io * 2351 + In * Io) % 16777213 == 9653484) then
                Ij_3 = nil
            end
            return Ij_3
        end
        Jf = function(ri, rj)
            local Type = rj.Type
            if Type == "Toggle" then
                return { idx = ri, type = "Toggle", value = rj.Value == true }
            elseif Type == "Slider" then
                return { idx = ri, type = "Slider", value = tostring(rj.Value) }
            elseif Type == "Dropdown" then
                return { idx = ri, type = "Dropdown", multi = rj.Multi == true, value = rj.Value }
            elseif Type == "Input" then
                local Ir = rj.Value or ""
                return { idx = ri, type = "Input", text = tostring(Ir) }
            elseif Type == "ColorPicker" then
                return { idx = ri, type = "ColorPicker", value = rj.Value:ToHex(), transparency = rj.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = ri,
                    type = "KeyPicker",
                    mode = rj.Mode,
                    key = rj.Value,
                    modifiers = rj.Modifiers,
                    toggled = rj.Toggled
                }
            else
                return nil
            end
        end
        Je = function()
            local Ix = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local Iy = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if Iy then
                        local Iy_1 = Jf(k, v)
                        if Iy_1 then
                            Ix[#Ix + 1] = Iy_1
                        end
                    end
                end
            end
            table.sort(Ix, function(rt, ru)
                if rt.type ~= ru.type then
                    return rt.type < ru.type
                end
                return rt.idx < ru.idx
            end)
            return { objects = Ix }
        end
        Jg = function(rw)
            local IR
            IR = nil
            local IS = type(rw) ~= "table" or type(rw.idx) ~= "string" or type(rw.type) ~= "string" or SaveManager.Ignore[rw.idx]
            if IS then
                return false
            end
            IR = Jh(rw.type, rw.idx)
            if not IR then
                return false
            end
            local IS_1 = pcall(function()
                if rw.type == "Input" then
                    if type(rw.text) ~= "string" then
                        return
                    end
                    IR:SetValue(rw.text)
                elseif rw.type == "ColorPicker" then
                    IR:SetValueRGB(Color3.fromHex(rw.value), rw.transparency)
                elseif rw.type == "KeyPicker" then
                    IR:SetValue({ rw.key, rw.mode, rw.modifiers })
                    if rw.mode == "Toggle" and rw.toggled ~= nil then
                        IR.Toggled = rw.toggled
                        IR:Update()
                    end
                else
                    IR:SetValue(rw.value)
                end
            end)
            return IS_1
        end
        Ji:AddDivider()
        Ji:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        Ji:AddButton("Export Config to Clipboard", function()
            local IV_1
            local IU_1
            IU_1, IV_1 = pcall(HttpService.JSONEncode, HttpService, Je())
            if IU_1 then
                local IU_2 = v0(setclipboard) and setclipboard
                local IW = IU_2
                if not IW then
                    local IU_3 = v0(toclipboard) and toclipboard
                    IW = IU_3 or nil
                end
                local IU_4 = IW
                local IW_1 = type(IU_4) == "function" and pcall(IU_4, IV_1)
                if IW_1 then
                    Library:Notify("Config copied to clipboard", 6)
                    return
                end
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Failed to encode the config")
        end)
        Ji:AddButton("Import Config from Clipboard Text", function()
            local I0_1
            local IZ = Options.SaveManager_ImportSource.Value
            local IZ_1
            local I4 = if IZ then 1 else 0
            local I2 = 2426 * I4 + 3400 * (1 - I4)
            local I3 = 2534 * I4 + 1840 * (1 - I4)
            if not ((I2 * 2854 + I3 * 3193 + I2 * I3) % 16777213 == 4385137) then
                IZ = ""
            end
            local I_ = tostring(IZ):match("^%s*(.-)%s*$")
            if I_ == "" then
                Library:Notify("Paste a config first")
                return
            end
            if #I_ > 262144 then
                Library:Notify("Config is too large")
                return
            end
            IZ_1, I0_1 = pcall(HttpService.JSONDecode, HttpService, I_)
            local I__1 = not IZ_1
            local I7 = if I__1 then 1 else 0
            local I5 = 3780 * I7 + 3681 * (1 - I7)
            local I6 = 3326 * I7 + 2440 * (1 - I7)
            if not ((I5 * 761 + I6 * 1387 + I5 * I6) % 16777213 == 3284809) then
                I__1 = type(I0_1) ~= "table"
            end
            if not I__1 then
                I__1 = type(I0_1.objects) ~= "table"
            end
            if I__1 then
                Library:Notify("Invalid config payload")
                return
            end
            if #I0_1.objects > 2048 then
                Library:Notify("Config has too many records")
                return
            end
            local IZ_2 = 0
            local I__2 = 0
            for i, v in ipairs(I0_1.objects) do
                if Jg(v) then
                    I__2 += 1
                else
                    IZ_2 += 1
                end
            end
            Options.SaveManager_ImportSource:SetValue("")
            Library:Notify(string.format("Imported %d settings (%d skipped)", I__2, IZ_2), 6)
        end)
        SaveManager:LoadAutoloadConfig()
        if Toggles.HideUIOnStart and Toggles.HideUIOnStart.Value then
            pcall(function()
                Library:Toggle(false)
            end)
        end
    end
    Js_5()
    if Toggles.AutoSteal then
        wc.SetAutoSteal(Toggles.AutoSteal.Value)
    end
    if Toggles.AutoPlaceEggs then
        wc.SetAutoPlace(Toggles.AutoPlaceEggs.Value)
    end
    if Toggles.AutoOpenEggs then
        wc.SetAutoOpen(Toggles.AutoOpenEggs.Value)
    end
    if Toggles.AutoEquipBest then
        wc.SetAutoEquipBest(Toggles.AutoEquipBest.Value)
    end
    if Toggles.AutoBuyTrails then
        wc.SetAutoBuyTrails(Toggles.AutoBuyTrails.Value)
    end
    if Toggles.AutoEquipBestTrail then
        wc.SetAutoEquipBestTrail(Toggles.AutoEquipBestTrail.Value)
    end
    if Toggles.AutoClaimIndex then
        wc.SetAutoClaimIndex(Toggles.AutoClaimIndex.Value)
    end
    if Toggles.AutoSell then
        wc.SetAutoSell(Toggles.AutoSell.Value)
    end
    if Toggles.AutoUpgradeTreadmill then
        wc.SetAutoUpgradeTreadmill(Toggles.AutoUpgradeTreadmill.Value)
    end
    if Toggles.AutoUpgradePen then
        wc.SetAutoUpgradePen(Toggles.AutoUpgradePen.Value)
    end
    if Toggles.EggEsp then
        wc.SetEggEsp(Toggles.EggEsp.Value)
    end
    if Options.StealZones then
        wc.SetStealZones(Options.StealZones.Value)
    end
    if Options.StealRarities then
        wc.SetStealRarities(Options.StealRarities.Value)
    end
    if Options.EspRarities then
        wc.SetEspRarities(Options.EspRarities.Value)
    end
    if Options.SellRarities then
        wc.SetSellRarities(Options.SellRarities.Value)
    end
    if Options.StealPriority then
        wc.SetPriority(Options.StealPriority.Value)
    end
    if Options.TeleportZone then
        wc.SetTeleportZone(Options.TeleportZone.Value)
    end
end
JJ_2, JJ_12 = pcall(JJ_10)
if not JJ_2 then
    JJ_26 = 2
    repeat
        local KH = bit32.rrotate(bit32.bxor(bit32.lrotate(JJ_26, 20), string.byte(tostring(JJ_26))), 27)
        if bit32.bxor(bit32.lrotate(bit32.bxor(KH, 2254750314), 6), 2570099361) == bit32.lrotate(KH, 6) then
            wc.Unload()
            error(JJ_12, 0)
        else
            JJ_12.Unload()
            error(wc, 0)
        end
        JJ_26 = (JJ_26 + 3) % 4
    until (JJ_26 * 3 + 3) % 4 == 2
end
end)(...)

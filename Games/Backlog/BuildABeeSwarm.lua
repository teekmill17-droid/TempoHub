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
getgenv().TempoHoodSubtitle = "BUILD A BEE SWARM"
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
local x4_10, x4_11, x4_20, x4_26, x4_28, x4_29
local x4_17_3, x4_17_4
local pj
local om
local o6
local oq
local BuyHiveSlot
local pv
local n5
local WaveAction
local py
local Library
local n8
local RebirthEvent
local oR
local oX
local oE
local oh
local Workspace
local po
local Toggles
local PlayerGui
local pr
local oH
local pu
local ox
local pe
local pA
local oT
local ph
local oa
local oD
local pk
local oA
local og
local o1
local oj
local pq
local o4
local oM
local oo
local oP
local ot
local ow
local pd
local n9
local oV
local oz
local oc
local oY
local Options
local oF
local pg
local function fn43(ao, ap)
    if ao.order ~= ap.order then
        return ao.order < ap.order
    end
    return ao.price < ap.price
end
local function fn45(cg)
    local rF = cg == ""
    local rG = type(cg) ~= "string" or rF
    if rG then
        return nil
    end
    local rF_1 = oH[cg] or oH[string.lower(cg)]
    return rF_1
end
local function fn47(c1)
    local Parent = c1.Parent
    if Parent then
        local attr = Parent:GetAttribute("HiveIndex")
        if type(attr) == "number" then
            return attr
        end
        return nil
    end
    return nil
end
local function fn66()
    local uW = if oP:GetAttribute("BattleActive") ~= true then 1 else 0
    if uW == 1 then
        oa = nil
        return
    end
    if not oa then
        oa = os.clock()
        return
    end
    local uR = tonumber(og("AutoEndFightSeconds", 60)) or 60
    if os.clock() - oa >= uR then
        pcall(function()
            WaveAction:FireServer("stop")
        end)
        oa = nil
    end
end
local function worker()
    while not Library.Unloaded do
        if ox("RemoveRollZoom") then
            ot(true)
        end
        if ox("AutoCollect") then
            pcall(ph)
        end
        if ox("AutoRoll") then
            local uY_1 = o6(oh())
            if #uY_1 == 0 then
                pcall(n8)
            end
        end
        if ox("AutoSell") then
            pcall(pr)
        end
        if ox("AutoRebirth") then
            pcall(oE)
        end
        if ox("AutoBuyUpgrades") then
            pcall(oj)
        end
        if ox("AutoExpandHive") then
            pcall(oV)
        end
        if ox("AutoBuySwords") then
            pcall(ow)
        end
        if ox("AutoStartFight") then
            pcall(n5)
        end
        if ox("AutoEndFight") then
            pcall(po)
        end
        local uY_2 = ox("AutoMaxBattleSpeed") and oP:GetAttribute("BattleActive") == true
        if uY_2 then
            pcall(pe)
        end
        task.wait(oF)
    end
end
local function fn128()
    oT.MaxPromptsVisible = 20
end
local function fn135()
    return PlayerGui
end
local function fn160()
    local tl = tonumber(oP:GetAttribute("NextHiveCost"))
    local tm = tl and oq() < tl
    if tm then
        return
    end
    pcall(function()
        BuyHiveSlot:FireServer()
    end)
end
local function fn217(c5)
    local sq_1
    local sp_1
    local sm = {}
    if not c5 then
        return sm
    end
    for i, descendant in c5:GetDescendants() do
        local sn = descendant:IsA("ProximityPrompt") and descendant.ActionText == "Collect"
        if sn then
            local Model = descendant:FindFirstAncestorOfClass("Model")
            local so = oA(Model, descendant.ObjectText)
            sp_1, sq_1 = o4(descendant.ObjectText)
            local sp_2 = #sm + 1
            local sr = sq_1
            if not sr then
                local sq_2 = Model and oM(Model)
                sr = sq_2
            end
            sm[sp_2] = { prompt = descendant, bee = Model, rarity = so, name = sr }
        end
    end
    return sm
end
local function fn283(cH)
    local r1 = cH:GetAttribute("OwnerUserId") == oP.UserId and cH:GetAttribute("Docked") == true
    return r1
end
local function fn294(ck)
    if type(ck) ~= "string" then
        return nil, nil
    end
    local rI = ck:match("^(.+) %- %$")
    local rJ = ck:match("%$([%d,]+)")
    local rK = rJ and tonumber((rJ:gsub(",", "")))
    local rJ_1 = rK
    if rK then
        rK = oD[rJ_1]
    end
    local rJ_2 = rK
    local rO = if rJ_2 then 1 else 0
    local rM = 2683 * rO + 449 * (1 - rO)
    local rN = 2085 * rO + 1 * (1 - rO)
    if not ((rM * 1894 + rN * 3887 + rM * rN) % 16777213 == 2002839) then
        rJ_2 = pk(rI)
    end
    local rK_1 = rJ_2
    return pu(rK_1), rI
end
local function fn312(gL)
    local DiscordGroup = gL:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = pd })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = pd })
end
local function fn322(aN, aO, aP)
    return string.format("<b>%s</b> %s %s", aN, o1("-", "#5a6070"), o1(aO, aP))
end
local function fn366()
    local tS = oP:GetAttribute("Owns3xSpeed") == true
    local tS_1 = tS and 3 or 2
    local tS_2 = tonumber(oP:GetAttribute("BattleSpeed")) or 1
    if tS_2 >= tS_1 then
        return
    end
    if os.clock() - pg < 0.35 then
        return
    end
    pg = os.clock()
    pcall(function()
        WaveAction:FireServer("speed")
    end)
end
local function fn373(cc)
    local rz = cc == ""
    local rA = type(cc) ~= "string" or rz
    if rA then
        return nil
    end
    return cc:sub(1, 1):upper() .. cc:sub(2):lower()
end
local function fn413(aA)
    if aA then
        oc[#oc + 1] = aA
    end
    return aA
end
local function fn434(cu)
    if not cu then
        return nil
    end
    local Lever = cu:FindFirstChild("Lever")
    local rQ = Lever and Lever:FindFirstChild("Lever Handle")
    local rP_1 = rQ
    if rQ then
        rQ = rP_1:FindFirstChild("PromptPart")
    end
    local rP_2 = rQ
    if rQ then
        rQ = rP_2:FindFirstChild("ProximityPrompt")
    end
    return rQ
end
local function fn463()
    for k, v in oY:GetTagged("WaveBee") do
        if v:GetAttribute("OwnerUserId") == oP.UserId then
            local HumanoidRootPart = v:FindFirstChild("HumanoidRootPart")
            if HumanoidRootPart then
                return HumanoidRootPart.Position
            end
        end
    end
    local tW_2 = oz()
    return tW_2 and tW_2.Position
end
local function fn491()
    if oP:GetAttribute("BattleActive") == true then
        oa = os.clock()
    else
        oa = nil
    end
end
local function fn492(bM)
    local re = bM == ""
    local re_1
    local rf = type(bM) ~= "string" or re
    local rf_1
    if rf then
        return {}
    end
    re_1, rf_1 = pcall(pj.JSONDecode, pj, bM)
    local rg = not re_1 or type(rf_1) ~= "table"
    if rg then
        return {}
    end
    local re_2 = {}
    for k, v in rf_1 do
        if type(v) == "string" then
            re_2[#re_2 + 1] = v
        end
    end
    return re_2
end
local function fn511()
    pv(om, "Copied Discord invite to clipboard")
end
local function fn514()
    local rr = {}
    for k, v in n9(oP:GetAttribute("OwnedSwords")) do
        rr[v] = true
    end
    return rr
end
local function fn518(aD, aE)
    if setclipboard then
        setclipboard(aD)
    elseif toclipboard then
        toclipboard(aD)
    end
    Library:Notify(aE)
end
local function fn648(a9)
    return next(a9) ~= nil
end
local function fn650(aS)
    local qD = Toggles[aS]
    return qD ~= nil and qD.Value == true
end
local function fn661(aX, aY)
    local qG = Options[aX]
    if qG == nil then
        return aY
    end
    local Value = qG.Value
    if Value == nil then
        return aY
    end
    return Value
end
local function fn663(aK, aL)
    return string.format('<font color="%s">%s</font>', aL, aK)
end
local function fn666()
    local sz = oh()
    local sA = oo(sz)
    if not sA then
        return
    end
    oR(sA)
end
local function fn671(bt)
    if not py(bt) then
        return false
    elseif fireproximityprompt then
        local q3_1 = pcall(fireproximityprompt, bt)
        if q3_1 then
            return true
        elseif firesignal then
            local q3_2 = pcall(firesignal, bt.Triggered, oP)
            return q3_2
        else
            return false
        end
    elseif firesignal then
        local q3_3 = pcall(firesignal, bt.Triggered, oP)
        return q3_3
    else
        return false
    end
end
local function fn765(ce)
    local rC = ce == ""
    local rD = type(ce) ~= "string" or rC
    if rD then
        return nil
    end
    return string.lower(ce)
end
local function fn782()
    local attr = oP:GetAttribute("Plot")
    if type(attr) ~= "string" then
        return nil
    end
    return Workspace:FindFirstChild(attr)
end
local function fn858()
    Library.ScreenGui.Parent = PlayerGui
end
local function fn860()
    local uQ = if oP:GetAttribute("BattleActive") == true then 1 else 0
    if uQ == 1 then
        return
    end
    if oP:GetAttribute("CutscenePlaying") == true then
        return
    end
    pcall(function()
        WaveAction:FireServer("start")
    end)
end
local function fn873(a2)
    local qJ = {}
    if type(a2) ~= "table" then
        return qJ
    end
    local Value = a2.Value
    if type(Value) ~= "table" then
        return qJ
    end
    for k, v in Value do
        if v == true then
            qJ[k] = true
        else
            local qK_1 = type(k) == "number" and type(v) == "string"
            if qK_1 then
                qJ[v] = true
            end
        end
    end
    return qJ
end
local function fn882(cO, cP)
    local sa = cO and cO:GetAttribute("BeeRarity")
    local sa_1
    local sb = pu(sa)
    local sb_1
    if sb then
        return sb
    end
    sa_1, sb_1 = o4(cP)
    if sa_1 then
        return sa_1
    end
    local sa_2 = sb_1
    local si = if sa_2 then 1 else 0
    local sg = 3069 * si + 3716 * (1 - si)
    local sh = 109 * si + 220 * (1 - si)
    if not ((sg * 1412 + sh * 3647 + sg * sh) % 16777213 == 5065472) then
        local sb_2 = cO and oM(cO)
        sa_2 = sb_2
    end
    return pk(sa_2)
end
local function fn885(cC)
    for k, v in oY:GetTagged("PadDisplayBee") do
        if v:IsA("Model") then
            cC(v)
        end
    end
end
local function fn944()
    local Character = oP.Character
    local qW = Character and Character:FindFirstChild("HumanoidRootPart")
    return qW
end
local function fn947(cL)
    local attr = cL:GetAttribute("BeeName")
    local r4 = attr ~= ""
    local r5 = type(attr) == "string" and r4
    if r5 then
        return attr
    end
    return cL.Name
end
local function fn977()
    local sC = oh()
    local sD = pq(Options.CollectRarities)
    local sE = oX(sD)
    local sF = o6(sC)
    if #sF == 0 then
        return false
    end
    local sC_1 = false
    local sG = false
    for k, v in sF do
        if v.prompt and v.prompt.Parent then
            local sF_2 = pA(v.rarity)
            if not sE or sF_2 ~= nil and sD[sF_2] == true then
                if oR(v.prompt) then
                    sG = true
                end
            else
                sC_1 = true
            end
        end
    end
    if sC_1 then
        n8()
    end
    return sG
end
local function fn999()
    local Character = oP.Character
    local qT = Character and Character:FindFirstChildOfClass("Humanoid")
    return qT
end
local function fn1001()
    local s5 = tonumber(oP:GetAttribute("RebirthCost"))
    local s6 = s5 and oq() < s5
    if s6 then
        return
    end
    pcall(function()
        RebirthEvent:FireServer("rebirth")
    end)
end
local function fn1012()
    local qY = tonumber(oP:GetAttribute("Cash")) or 0
    return qY
end
n5 = nil
n8 = nil
n9 = nil
oa = nil
oc = nil
Options = nil
og = nil
oh = nil
oj = nil
Toggles = nil
om = nil
oo = nil
oq = nil
ot = nil
ow = nil
ox = nil
Library = nil
oz = nil
oA = nil
local oC
oD = nil
oE = nil
oF = nil
oH = nil
PlayerGui = nil
oM = nil
oP = nil
oR = nil
oT = nil
RebirthEvent = nil
oV = nil
local n4, n6, n7, ob, od, oe, oi, op, ou, ov, oB, oG, oI, RollZoomEvent, SwordShop, oN, oO, DeleteBee, oS
oX = nil
oY = nil
o1 = nil
Workspace = nil
o4 = nil
o6 = nil
BuyHiveSlot = nil
WaveAction = nil
pd = nil
pe = nil
pg = nil
ph = nil
pj = nil
pk = nil
po = nil
pq = nil
pr = nil
pu = nil
pv = nil
py = nil
pA = nil
local oW, BuyStatUpgrade, o0, BuyBoardUpgrade, o5, o7, o8, pa, pb, pf, pi, pl, pm, pn, pp, ps, pt, RunService, px, pz
oW = nil
BuyStatUpgrade = nil
local o_
o0 = nil
BuyBoardUpgrade = nil
o5 = nil
o7 = nil
o8 = nil
pa = nil
pb = nil
pf = nil
pi = nil
pl = nil
pm = nil
pn = nil
pp = nil
ps = nil
pt = nil
RunService = nil
px = nil
pz = nil
n4, x4_26, RunService, ps, pn, pj, pf, pb, o7, Workspace, oY, oT, oP, PlayerGui = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local x4_7 = 17
repeat
    local x4_17_1 = (x4_7 * 5 + 5) % 7 + 1
    if x4_17_1 <= 4 then
        if x4_17_1 <= 2 then
            if x4_17_1 <= 1 then
                local yv = bit32.rrotate(bit32.bxor(bit32.lrotate(x4_7, 16), string.byte(tostring(PlayerGui))), 4)
                if bit32.bxor(bit32.lrotate(bit32.bxor(yv, 2051735253), 2), 3911973717) == bit32.lrotate(yv, 2) then
                    x4_26 = game:GetService("ReplicatedStorage")
                else
                    oP = game:GetService("ReplicatedStorage")
                end
                x4_7 = (x4_7 + 24) % 56
            else
                local ya = bit32.rrotate(bit32.bxor(bit32.lrotate(x4_7, 10), string.byte(tostring(pf))), 28)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(ya, 2154978017), 884617578), (bit32.bxor(bit32.band(ya, 2139989278), 2050338653))), 884617578), 2050338653) == ya then
                    RunService = game:GetService("RunService")
                else
                    pf = game:GetService("RunService")
                end
                x4_7 = (x4_7 + 31) % 56
            end
        elseif x4_17_1 <= 3 then
            if x4_7 * 82415217 + 1 + 5 >= x4_7 * 82415217 + 1 + 5 + 5 then
                pn = game:GetService("UserInputService")
                ps = game:GetService("VirtualUser")
            else
                ps = game:GetService("UserInputService")
                pn = game:GetService("VirtualUser")
            end
            x4_7 = (x4_7 + 52) % 56
        else
            x4_10 = {
                "ciubd",
                "wxuqqbkfl",
                "achogqro",
                "fjvwasrrmo",
                "xgztxmwkrcx",
                "vuwzqfrdjy",
                "jexoizo",
                "xtvamh",
                "xkca",
                "rruz",
                "qdqxxusk",
                "xpwxu",
                "jorpditk"
            }
            if x4_10[(x4_7 * 38 + 37) % 13 + 1] < x4_10[(x4_7 * 38 + 37) % 13 + 1] then
                o7 = game:GetService("HttpService")
                pj = game:GetService("GuiService")
                pf = game:GetService("TeleportService")
                pb = game:GetService("CoreGui")
            else
                pj = game:GetService("HttpService")
                pf = game:GetService("GuiService")
                pb = game:GetService("TeleportService")
                o7 = game:GetService("CoreGui")
            end
            x4_7 = (x4_7 + 10) % 56
        end
    elseif x4_17_1 <= 6 then
        if x4_17_1 <= 5 then
            if x4_7 * 23449571 + 5 + 5 >= x4_7 * 23449571 + 5 + 5 + 1 then
                n4 = game:GetService("Workspace")
            else
                Workspace = game:GetService("Workspace")
            end
            x4_7 = (x4_7 + 52) % 56
        else
            if (x4_7 * 2 + 1) * 13 % 3 == ((x4_7 * 2 + 1) * 13 + 4) % 3 then
                oT = game:GetService("CollectionService")
                oY = game:GetService("ProximityPromptService")
                n4 = PlayerGui.LocalPlayer
                oP = n4:WaitForChild("PlayerGui")
            else
                oY = game:GetService("CollectionService")
                oT = game:GetService("ProximityPromptService")
                oP = n4.LocalPlayer
                PlayerGui = oP:WaitForChild("PlayerGui")
            end
            x4_7 = (x4_7 + 52) % 56
        end
    else
        local x4_17_2 = {
            "ojn",
            "bxuzraypchnl",
            "xcqmql",
            "hmzf",
            "hmveaf",
            "zdyydo",
            "glgnftjq",
            "dsngknc",
            "gkeixzsphfy"
        }
        if x4_17_2[(x4_7 * 1 + 7) % 9 + 1] < x4_17_2[(x4_7 * 1 + 7) % 9 + 1] then
            oY = game:GetService("Players")
        else
            n4 = game:GetService("Players")
        end
        x4_7 = (x4_7 + 3) % 56
    end
until (x4_7 * 43 + 47) % 56 == 50
if getgenv then
    oC, x4_17_3 = nil, nil
    x4_7 = 5
    repeat
        x4_10 = (x4_7 * 1 + 1) % 2 + 1
        if x4_10 <= 1 then
            x4_10 = {
                "htrfzbbrcb",
                "gntaospxj",
                "wpjv",
                "xwwip",
                "evopgz",
                "iaobk",
                "ujyhv",
                "wyisq",
                "oamixsqsddo",
                "veifgbstinc"
            }
            local zw = x4_7
            x4_28 = x4_10[zw % 10 + 1]
            if x4_28:len() <= x4_28:gsub("(.)", "%1%1", zw % 3 % 2 + 1):len() then
                getgenv().gethui = fn135
                oC = getgenv().__TempoBuildABeeSwarmLib
            else
                getgenv().gethui = fn135
                x4_17_3 = getgenv().__TempoBuildABeeSwarmLib
            end
            x4_7 = (x4_7 + 9) % 16
        else
            x4_10 = (vector.create((x4_7 * 3 + 8) % 11 + 1, (x4_7 * 4 + 11) % 13 + 1, (x4_7 * 11 + 1) % 17 + 1))
            x4_28 = (vector.create((x4_7 * 6 + 1) % 11 + 1, (x4_7 * 11 + 1) % 13 + 1, (x4_7 * 6 + 2) % 17 + 1))
            x4_20 = (vector.create((x4_7 * 4 + 6) % 11 + 1, (x4_7 * 7 + 3) % 13 + 1, (x4_7 * 12 + 2) % 17 + 1))
            x4_11 = (vector.create((x4_7 * 4 + 3) % 5 + 1, (x4_7 * 2 + 3) % 7 + 1, (x4_7 * 5 + 3) % 9 + 1))
            if vector.dot(vector.cross(x4_10, (vector.cross(x4_28, x4_20))), x4_11) == vector.dot(x4_28 * vector.dot(x4_10, x4_20) - x4_20 * vector.dot(x4_10, x4_28), x4_11) + 1 then
                oC = x4_17_3
            else
                x4_17_3 = oC
            end
            x4_7 = (x4_7 + 1) % 16
        end
    until (x4_7 * 3 + 0) % 16 == 13
    if x4_17_3 then
        x4_17_3 = oC.Unload
    end
    if x4_17_3 then
        pcall(function()
            oC:Unload()
        end)
    end
end
pcall(function()
    gethui = function()
        return PlayerGui
    end
end)
if setthreadidentity then
    setthreadidentity(8)
end
ou, om, oi, oe, ob, n6, pz, px, pt, x4_17_4, WaveAction, BuyHiveSlot, BuyBoardUpgrade, BuyStatUpgrade, RebirthEvent, DeleteBee, SwordShop, RollZoomEvent = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
ou = "Build a Bee Swarm"
om = "https://discord.gg/K7Qxnxkk46"
oi = "https://discord.gg/K7Qxnxkk46"
oe = "https://tempohub.shop"
ob = "#7fd47f"
n6 = "#6ec1ff"
pz = "#e8a34d"
px = "#8b93a3"
if (not BuyStatUpgrade and not SwordShop or x4_17_4 and not SwordShop) and ((not BuyStatUpgrade or not SwordShop) and (not BuyStatUpgrade or BuyStatUpgrade)) or not ((not BuyStatUpgrade and not SwordShop or x4_17_4 and not SwordShop) and ((not BuyStatUpgrade or not SwordShop) and (not BuyStatUpgrade or BuyStatUpgrade))) then
    pt = "#e05a5a"
end
x4_28 = require(x4_26:WaitForChild("BalanceConfig"))
local x4_17_5 = require(x4_26:WaitForChild("BeeStatsConfig"))
x4_10 = require(x4_26:WaitForChild("SwordConfig"))
WaveAction = x4_26:WaitForChild("WaveAction")
BuyHiveSlot = x4_26:WaitForChild("BuyHiveSlot")
BuyBoardUpgrade = x4_26:WaitForChild("BuyBoardUpgrade")
BuyStatUpgrade = x4_26:WaitForChild("BuyStatUpgrade")
RebirthEvent = x4_26:WaitForChild("RebirthEvent")
DeleteBee = x4_26:WaitForChild("DeleteBee")
SwordShop = x4_26:WaitForChild("SwordShop")
RollZoomEvent = x4_26:WaitForChild("RollZoomEvent")
x4_7 = (tonumber(x4_28.AUTO_ROLL_DELAY))
local pQ = if x4_7 then 1 else 0
local pO = 3481 * pQ + 1953 * (1 - pQ)
local pP = 1036 * pQ + 3669 * (1 - pQ)
if not ((pO * 1327 + pP * 1125 + pO * pP) % 16777213 == 9391103) then
    x4_7 = 0.8
end
x4_20 = {}
oF = x4_7
x4_7 = x4_28.RARITY_ORDER
if type(x4_7) == "table" then
    for k, v in x4_7 do
        if type(v) == "string" then
            x4_20[#x4_20 + 1] = v
        end
    end
end
if #x4_20 == 0 then
    x4_7 = 3
    repeat
        x4_11 = {
            "lbrr",
            "tcvuuuhznzo",
            "nvxsfxzkky",
            "wqqyxkh",
            "nwep",
            "kcqlucyuay",
            "whjvdrutwif",
            "odaad",
            "ecqenrkwkr",
            "kwexlapr"
        }
        local y0 = x4_7
        x4_29 = x4_11[y0 % 10 + 1]
        if x4_29:len() >= x4_29:reverse():rep(y0 % 3 + 2):len() then
            x4_20 = { "rare", "mythic", "uncommon", "legendary", "secret", "epic", "common" }
        else
            x4_20 = { "common", "uncommon", "rare", "epic", "legendary", "mythic", "secret" }
        end
        x4_7 = (x4_7 + 0) % 4
    until (x4_7 * 3 + 2) % 4 == 3
end
x4_11 = {}
x4_7 = {}
for k, v in x4_20 do
    x4_20 = v:sub(1, 1):upper() .. v:sub(2)
    x4_7[#x4_7 + 1] = x4_20
    x4_11[x4_20] = v
end
x4_20 = {}
x4_11 = x4_17_5.Buffs
if type(x4_11) == "table" then
    for k in x4_11 do
        if type(k) == "string" then
            x4_20[#x4_20 + 1] = k
        end
    end
end
table.sort(x4_20)
x4_11, x4_29, pl = nil, nil, nil
if (x4_29 or 2) and ((not pl or x4_29) and x4_11) or not ((x4_29 or 2) and ((not pl or x4_29) and x4_11)) then
    x4_11 = {
        { label = "Luck", kind = "board", id = "luck" },
        { label = "Bee Rolls", kind = "board", id = "rollers" },
        { label = "Cash Multiplier", kind = "stat", id = "cash" },
        { label = "Damage Multiplier", kind = "stat", id = "damage" },
        { label = "Firerate Multiplier", kind = "stat", id = "firerate" }
    }
else
    pl = {
        { kind = "board", label = "Bee Rolls", id = "rollers" },
        { label = "Firerate Multiplier", id = "firerate", kind = "stat" },
        { kind = "stat", label = "Damage Multiplier", id = "damage" },
        { kind = "stat", label = "Cash Multiplier", id = "cash" },
        { id = "luck", kind = "board", label = "Luck" }
    }
end
x4_29 = {}
pl = {}
for k, v in x4_11 do
    x4_29[#x4_29 + 1] = v.label
    pl[v.label] = v
end
pa = {}
local x4_17_6 = x4_10.Swords
if type(x4_17_6) == "table" then
    for k, v in x4_17_6 do
        local x4_17_7 = type(k) == "string" and type(v) == "table"
        if x4_17_7 then
            local x4_17_8 = #pa + 1
            x4_10 = tonumber(v.price) or 0
            x4_11 = tonumber(v.order) or 0
            local x4_21 = tonumber(v.damagePct) or 0
            local x4_12 = type(v.displayName) == "string" and v.displayName
            local x4_3 = x4_12
            local pQ_1 = if x4_3 then 1 else 0
            local pO_1 = 4059 * pQ_1 + 2617 * (1 - pQ_1)
            local pP_1 = 2052 * pQ_1 + 3887 * (1 - pQ_1)
            if not ((pO_1 * 806 + pP_1 * 2101 + pO_1 * pP_1) % 16777213 == 15911874) then
                x4_3 = k
            end
            pa[x4_17_8] = { name = k, price = x4_10, order = x4_11, damagePct = x4_21, display = x4_3 }
        end
    end
end
table.sort(pa, fn43)
Library, x4_11, op, Toggles, Options = nil, nil, nil, nil, nil
local x4_17_9 = ""
Library = getgenv().Library
if (Library and op or (not Toggles or not Library) or (op or op or (not Toggles or not Toggles)) or (Library and false or not Toggles and op) and (x4_17_9 or Library or Toggles and false)) and not (Library and op or (not Toggles or not Library) or (op or op or (not Toggles or not Toggles)) or (Library and false or not Toggles and op) and (x4_17_9 or Library or Toggles and false)) then
    pcall(fn858)
    x4_17_9 = getgenv().ThemeManager
else
    pcall(fn858)
    x4_11 = getgenv().ThemeManager
end
op = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
if getgenv then
    getgenv().__TempoBuildABeeSwarmLib = Library
end
oc, oH, oD, n7, pv, pd, o1, oN, ox, og, pq, oX, oO, oz, oq, oh, py, pi, oR, n9, o8 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
oc = {}
n7 = fn413
pv = fn518
pd = fn511
o1 = fn663
oN = fn322
ox = fn650
og = fn661
pq = fn873
oX = fn648
oO = fn999
oz = fn944
oq = fn1012
oh = fn782
py = function(bp)
    local q1 = not bp or not bp:IsA("ProximityPrompt")
    if q1 then
        return false
    end
    pcall(function()
        bp.Enabled = true
        bp.HoldDuration = 0
        bp.MaxActivationDistance = 200
        bp.RequiresLineOfSight = false
    end)
    return true
end
pi = fn671
oR = function(bz)
    local ra
    local CFrame2
    ra = nil
    CFrame2 = nil
    if not bz or not bz.Parent then
        return false
    end
    ra = oz()
    if not ra then
        return pi(bz)
    end
    local q9 = bz.Parent
    if not q9:IsA("BasePart") then
        q9 = bz:FindFirstAncestorWhichIsA("BasePart")
    end
    CFrame2 = ra.CFrame
    if q9 then
        pcall(function()
            ra.CFrame = q9.CFrame * CFrame.new(0, 3, 0)
            ra.AssemblyLinearVelocity = Vector3.zero
        end)
        task.wait(0.08)
    end
    local rc_1 = pi(bz)
    task.wait(0.12)
    pcall(function()
        if ra.Parent then
            ra.CFrame = CFrame2
            ra.AssemblyLinearVelocity = Vector3.zero
        end
    end)
    return rc_1
end
if (false or o8) and (o8 or py) and (oH or oH or (not o8 or oH)) and not ((false or o8) and (o8 or py) and (oH or oH or (not o8 or oH))) then
    oD = fn492
    n9 = fn514
    o8 = {}
    oH = {}
else
    n9 = fn492
    o8 = fn514
    oH = {}
    oD = {}
end
local x4_17_10 = x4_26:FindFirstChild("Bees")
if x4_17_10 then
    for i, child in x4_17_10:GetChildren() do
        x4_26 = string.lower(child.Name)
        if x4_26 ~= "robux" then
            for i, child in child:GetChildren() do
                oH[child.Name] = x4_26
                oH[string.lower(child.Name)] = x4_26
            end
        end
    end
end
x4_26 = x4_28.BUY_COSTS
if type(x4_26) == "table" then
    for k, v in x4_26 do
        x4_26 = type(k) == "string" and tonumber(v)
        if x4_26 then
            oD[tonumber(v)] = string.lower(k)
        end
    end
end
pg, ov, oa, oI, pA, pu, pk, o4, oo, pp, o5, oM, oA, pm, o6, n8, ph, pr, oE, oj, oV, ow, o_, pe, oG, od, ot, oS, n5, po = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pA = fn373
pu = fn765
pk = fn45
o4 = fn294
oo = fn434
pp = fn885
o5 = fn283
oM = fn947
oA = fn882
pm = fn47
o6 = fn217
n8 = fn666
ph = fn977
pr = function()
    local sZ, s_, s0, s1
    s_ = pq(Options.SellRarities)
    s1 = pq(Options.SellBees)
    s0 = oX(s_)
    sZ = oX(s1)
    if not s0 and not sZ then
        return
    end
    pp(function(dY)
        if not o5(dY) then
            return
        end
        local sQ = pm(dY)
        if type(sQ) ~= "number" then
            return
        end
        local sR = pA(oA(dY))
        local sS = oM(dY)
        local sT = not s0
        if not sT then
            sT = sR ~= nil and s_[sR] == true
        end
        local sR_1 = not sZ
        local sU_2 = sT
        if not sR_1 then
            sR_1 = s1[sS] == true
        end
        if sU_2 and sR_1 then
            pcall(function()
                DeleteBee:FireServer(sQ)
            end)
        end
    end)
end
oE = fn1001
oj = function()
    local tc = pq(Options.UpgradeSelect)
    local tg = if not oX(tc) then 1 else 0
    if tg == 1 then
        return
    end
    for k in tc do
        local tb = pl[k]
        if tb then
            if tb.kind == "board" then
                pcall(function()
                    BuyBoardUpgrade:FireServer(tb.id)
                end)
            elseif tb.kind == "stat" then
                pcall(function()
                    BuyStatUpgrade:FireServer(tb.id)
                end)
            end
        end
    end
end
oV = fn160
ow = function()
    local tp = o8()
    local tq = oq()
    local to
    for k, v in pa do
        local ty = v
        if tp[ty.name] then
            if not to or ty.damagePct > to.damagePct then
                to = ty
            end
        elseif tq >= ty.price then
            pcall(function()
                SwordShop:FireServer("buy", ty.name)
            end)
            tp[ty.name] = true
            to = ty
            tq -= ty.price
        end
    end
    local tr_2 = to and oP:GetAttribute("EquippedSword") ~= to.name
    if tr_2 then
        pcall(function()
            SwordShop:FireServer("select", to.name)
        end)
    end
end
o_ = function()
    local tF = o8()
    local tE
    for k, v in pa do
        if tF[v.name] and (not tE or v.damagePct > tE.damagePct) then
            tE = v
        end
    end
    local tG_2 = tE and oP:GetAttribute("EquippedSword") ~= tE.name
    if tG_2 then
        pcall(function()
            SwordShop:FireServer("select", tE.name)
        end)
    end
    local Character = oP.Character
    local tF_1 = not tE
    local tG_3 = not Character
    local tR = if tG_3 then 1 else 0
    local tP = 3020 * tR + 1122 * (1 - tR)
    local tQ = 1980 * tR + 327 * (1 - tR)
    if not ((tP * 2047 + tQ * 1274 + tP * tQ) % 16777213 == 14684060) then
        tG_3 = tF_1
    end
    if tG_3 then
        return
    end
    local tF_2 = Character:FindFirstChild(tE.name) or oP.Backpack:FindFirstChild(tE.name)
    local tC = tF_2
    if tC and tC.Parent ~= Character then
        pcall(function()
            tC.Parent = Character
        end)
    end
end
pg = 0
pe = fn366
oG = fn463
if (false or (false or not ph)) and (ph or false or oj and oj) and (false and (oj and not ph) or (ph or oj or false and not ph)) and not ((false or (false or not ph)) and (ph or false or oj and oj) and (false and (oj and not ph) or (ph or oj or false and not ph))) then
    oS = function()
        if oP:GetAttribute("BattleActive") ~= true then
            return
        end
        o_()
        pe()
        if oP:GetAttribute("AutoWave") ~= true then
            pcall(function()
                WaveAction:FireServer("auto")
            end)
        end
        local Character = oP.Character
        local t8 = Character and Character:FindFirstChildOfClass("Tool")
        local t4 = t8
        local t6 = oG()
        for k, v in oY:GetTagged("Zombie") do
            local uf = v
            if uf:IsA("Model") then
                local t7_3 = uf:FindFirstChild("HumanoidRootPart") or uf:FindFirstChildWhichIsA("BasePart")
                local t5 = t7_3
                pcall(function()
                    uf:SetAttribute("HP", 0)
                    uf:SetAttribute("MaxHP", 0.01)
                end)
                if t6 and t5 then
                    pcall(function()
                        uf:SetAttribute("TP", t6)
                        t5.CFrame = CFrame.new(t6 + Vector3.new(math.random(-2, 2), 2, math.random(-2, 2)))
                    end)
                end
            end
        end
        if t4 then
            pcall(function()
                t4:Activate()
            end)
        end
    end
    od = {}
    ov = function(f2)
        local CurrentCamera
        local ui
        if f2 then
            table.clear(ov)
            if getconnections then
                for k, v in getconnections(RollZoomEvent.OnClientEvent) do
                    local up = v
                    pcall(function()
                        up:Disable()
                    end)
                    ov[#ov + 1] = up
                end
            end
            CurrentCamera = Workspace.CurrentCamera
            ui = oO()
            pcall(function()
                if CurrentCamera then
                    CurrentCamera.FieldOfView = 70
                end
                if ui then
                    ui.CameraOffset = Vector3.zero
                end
            end)
        else
            for k, v in ov do
                local uv = v
                pcall(function()
                    uv:Enable()
                end)
            end
            table.clear(ov)
        end
    end
    ot = function()
        local uK
        local uL = oz()
        if not uL then
            return
        end
        uK = uL.Position + Vector3.new(0, 2, 0)
        local function uL_2(gm)
            if not gm then
                return
            end
            for i, child in gm:GetChildren() do
                local uJ = child
                local uz = uJ.Name == "WaveCoin" and uJ:IsA("BasePart")
                if uz then
                    pcall(function()
                        uJ.Anchored = true
                        uJ.CanCollide = false
                        uJ.Position = uK
                    end)
                end
            end
        end
        uL_2(Workspace.CurrentCamera)
        uL_2(Workspace:FindFirstChild("Effects"))
        uL_2(Workspace:FindFirstChild("Coins"))
    end
else
    od = function()
        if oP:GetAttribute("BattleActive") ~= true then
            return
        end
        o_()
        pe()
        if oP:GetAttribute("AutoWave") ~= true then
            pcall(function()
                WaveAction:FireServer("auto")
            end)
        end
        local Character = oP.Character
        local t8 = Character and Character:FindFirstChildOfClass("Tool")
        local t4 = t8
        local t6 = oG()
        for k, v in oY:GetTagged("Zombie") do
            local uf = v
            if uf:IsA("Model") then
                local t7_1 = uf:FindFirstChild("HumanoidRootPart") or uf:FindFirstChildWhichIsA("BasePart")
                local t5 = t7_1
                pcall(function()
                    uf:SetAttribute("HP", 0)
                    uf:SetAttribute("MaxHP", 0.01)
                end)
                if t6 and t5 then
                    pcall(function()
                        uf:SetAttribute("TP", t6)
                        t5.CFrame = CFrame.new(t6 + Vector3.new(math.random(-2, 2), 2, math.random(-2, 2)))
                    end)
                end
            end
        end
        if t4 then
            pcall(function()
                t4:Activate()
            end)
        end
    end
    ov = {}
    ot = function(f2)
        local CurrentCamera
        local ui
        if f2 then
            table.clear(ov)
            if getconnections then
                for k, v in getconnections(RollZoomEvent.OnClientEvent) do
                    local up = v
                    pcall(function()
                        up:Disable()
                    end)
                    ov[#ov + 1] = up
                end
            end
            CurrentCamera = Workspace.CurrentCamera
            ui = oO()
            pcall(function()
                if CurrentCamera then
                    CurrentCamera.FieldOfView = 70
                end
                if ui then
                    ui.CameraOffset = Vector3.zero
                end
            end)
        else
            for k, v in ov do
                local uv = v
                pcall(function()
                    uv:Enable()
                end)
            end
            table.clear(ov)
        end
    end
    oS = function()
        local uK
        local uL = oz()
        if not uL then
            return
        end
        uK = uL.Position + Vector3.new(0, 2, 0)
        local function uL_1(gm)
            if not gm then
                return
            end
            for i, child in gm:GetChildren() do
                local uJ = child
                local uz = uJ.Name == "WaveCoin" and uJ:IsA("BasePart")
                if uz then
                    pcall(function()
                        uJ.Anchored = true
                        uJ.CanCollide = false
                        uJ.Position = uK
                    end)
                end
            end
        end
        uL_1(Workspace.CurrentCamera)
        uL_1(Workspace:FindFirstChild("Effects"))
        uL_1(Workspace:FindFirstChild("Coins"))
    end
end
oa = nil
n5 = fn860
po = fn66
n7(oP:GetAttributeChangedSignal("BattleActive"):Connect(fn491))
local x4_17_11 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = om, Copyable = true }, "|", ou },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
oI = {
    Info = x4_17_11:AddTab("Info", "info"),
    Main = x4_17_11:AddTab("Main", "bug"),
    Combat = x4_17_11:AddTab("Combat", "swords"),
    Player = x4_17_11:AddTab("Player", "person-standing"),
    Settings = x4_17_11:AddTab("Settings", "settings")
}
x4_10 = fn312
for k, v in oI do
    if k ~= "Info" then
        x4_10(v)
    end
end
local x4_17_12 = oI.Main:AddLeftGroupbox("Farm", "flower-2")
x4_17_12:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
x4_17_12:AddToggle("RemoveRollZoom", { Text = "Remove Roll Camera", Default = true })
x4_17_12:AddToggle("AutoCollect", { Text = "Auto Collect", Default = false })
x4_17_12:AddDropdown("CollectRarities", { Text = "Collect Rarities", Values = x4_7, Default = {}, Multi = true, AllowNull = true })
x4_17_12:AddDivider("Sell")
x4_17_12:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
x4_17_12:AddDropdown("SellRarities", { Text = "Sell Rarities", Values = x4_7, Default = {}, Multi = true, AllowNull = true })
x4_17_12:AddDropdown("SellBees", {
    Text = "Sell Bees",
    Values = x4_20,
    Default = {},
    Multi = true,
    AllowNull = true,
    Searchable = true
})
x4_17_12:AddToggle("MoneyMagnet", { Text = "Money Magnet", Default = false })
x4_26 = oI.Main:AddRightGroupbox("Upgrades", "sparkles")
x4_26:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
x4_26:AddToggle("AutoExpandHive", { Text = "Auto Expand Hive", Default = false })
x4_26:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
x4_26:AddDropdown("UpgradeSelect", { Text = "Upgrades", Values = x4_29, Default = {}, Multi = true, AllowNull = true })
x4_26:AddToggle("AutoBuySwords", { Text = "Auto Buy Swords", Default = false })
x4_10 = oI.Combat:AddLeftGroupbox("Combat", "swords")
x4_10:AddToggle("KillAura", { Text = "Kill Aura", Default = false })
x4_10:AddDivider("Waves")
x4_10:AddToggle("AutoStartFight", { Text = "Auto Start Fight", Default = false })
x4_10:AddToggle("AutoEndFight", { Text = "Auto End Fight", Default = false })
x4_10:AddSlider("AutoEndFightSeconds", { Text = "End Fight After", Default = 60, Min = 1, Max = 500, Rounding = 0, Suffix = "s" })
x4_10:AddToggle("AutoMaxBattleSpeed", { Text = "Max Battle Speed", Default = true })
if Toggles.RemoveRollZoom then
    Toggles.RemoveRollZoom:OnChanged(function()
        ot(Toggles.RemoveRollZoom.Value)
    end)
    if Toggles.RemoveRollZoom.Value then
        ot(true)
    end
end
o0, oW, oB = nil, nil, nil
task.spawn(worker)
n7(RunService.Heartbeat:Connect(function()
    local CurrentCamera
    local u2
    if Library.Unloaded then
        return
    end
    local u6 = if ox("KillAura") then 1 else 0
    if u6 == 1 then
        pcall(od)
    end
    if ox("MoneyMagnet") then
        pcall(oS)
    end
    if ox("RemoveRollZoom") then
        CurrentCamera = Workspace.CurrentCamera
        u2 = oO()
        pcall(function()
            if CurrentCamera and CurrentCamera.FieldOfView < 65 then
                CurrentCamera.FieldOfView = 70
            end
            if u2 and u2.CameraOffset.Magnitude > 0.05 then
                u2.CameraOffset = Vector3.zero
            end
        end)
    end
end))
x4_20 = function()
    local vX
    local vY
    vX = nil
    vY = nil
    local vW, Label, Label2, Label3, v1
    local function v2()
        local u7 = hookfunction ~= nil
        local u8 = hookmetamethod ~= nil
        local u9 = getrawmetatable ~= nil
        local va = setrawmetatable ~= nil
        local vb = getgc ~= nil
        local vc = getgenv ~= nil
        local vd = getreg ~= nil
        local ve = getconnections ~= nil
        local vf = firesignal ~= nil
        local vg = getcallbackvalue ~= nil
        local vh = setclipboard ~= nil
        local vi = getcustomasset ~= nil
        local vj = getnamecallmethod ~= nil
        local vk = isexecutorclosure ~= nil
        local vl = fireproximityprompt ~= nil
        local vm = firetouchinterest ~= nil
        local vn = WebSocket ~= nil
        local vo = readfile ~= nil
        local vp = writefile ~= nil
        local vq = request
        local vB = if vq then 1 else 0
        local vz = 1190 * vB + 2115 * (1 - vB)
        local vA = 2141 * vB + 3106 * (1 - vB)
        if not ((vz * 3195 + vA * 276 + vz * vA) % 16777213 == 6940756) then
            vq = http_request
        end
        local vr = vq ~= nil
        local vt = (debug and debug.getupvalues) ~= nil
        local vv = (debug and debug.setupvalue) ~= nil
        local vw = 0
        local vx = { u7, u8, u9, va, vb, vc, vd, ve, vf, vg, vh, vi, vj, vk, vl, vm, vn, vo, vp, vr, vt, vv }
        for i, v in ipairs(vx) do
            if v then
                vw += 1
            end
        end
        local u7_1 = vw / #vx
        if u7_1 >= 0.9 then
            return o1("Full Support", ob)
        elseif u7_1 >= 0.6 then
            return o1("Half Support", pz)
        else
            return o1("Low Support", pt)
        end
    end
    vX = "Unknown"
    pcall(function()
        local vJ_1
        local vI_1
        if identifyexecutor then
            vJ_1, vI_1 = identifyexecutor()
            local vK = vJ_1 ~= ""
            local vL = type(vJ_1) == "string" and vK
            if vL then
                local vK_1 = type(vI_1) == "string" and vI_1 ~= "" and vJ_1 .. " " .. vI_1
                local vI_2 = vK_1
                local vP = if vI_2 then 1 else 0
                local vN = 2690 * vP + 2788 * (1 - vP)
                local vO = 777 * vP + 2630 * (1 - vP)
                if not ((vN * 1724 + vO * 408 + vN * vO) % 16777213 == 7044706) then
                    vI_2 = vJ_1
                end
                vX = vI_2
            end
        end
    end)
    local v3 = v2()
    vY = os.clock()
    v1 = function()
        local vQ = math.floor(os.clock() - vY)
        if vQ < 60 then
            return vQ .. "s"
        elseif vQ < 3600 then
            return string.format("%dm %ds", math.floor((vQ) / (60)), vQ % 60)
        else
            return string.format("%dh %dm", math.floor((vQ) / (3600)), math.floor((vQ % 3600) / (60)))
        end
    end
    local UserGroup = oI.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = oP, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(oN("User", oP.DisplayName .. " @" .. oP.Name, ob), true)
    UserGroup:AddLabel(oN("UserId", tostring(oP.UserId), n6), true)
    UserGroup:AddLabel(oN("Executor", vX .. "  " .. v3, ob), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(oN("Session", v1(), pz), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            pv(oP.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            pv("https://www.roblox.com/users/" .. tostring(oP.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = oI.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(oN("Game", ou, n6), true)
    Label2 = SessionGroup:AddLabel(oN("Players", "0/0", ob), true)
    vW = tostring(game.JobId)
    local v3_1 = #vW > 18 and string.sub(vW, 1, 18) .. "..."
    local v3_2 = v3_1 or vW
    SessionGroup:AddLabel(oN("Job", v3_2, px), true)
    Label = SessionGroup:AddLabel(oN("Ping", "0 ms", pz), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            pb:Teleport(game.PlaceId, oP)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            pv(vW, "Copied Job ID")
        end
    })
    task.spawn(function()
        local vT_1
        local vS_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(oN("Session", v1(), pz))
            Label2:SetText(oN("Players", #n4:GetPlayers() .. "/" .. tostring(n4.MaxPlayers), ob))
            vS_1, vT_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local vS_2 = vS_1 and vT_1 .. " ms" or "n/a"
            Label:SetText(oN("Ping", vS_2, pz))
        end
    end)
    local SocialsGroup = oI.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = pd })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            pv(oi, "Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            pv(oe, "Copied website link")
        end
    })
end
x4_20()
x4_29 = function()
    local connection
    local MovementGroup = oI.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = oI.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local function iG(iH)
        pcall(function()
            pf:SetGameplayPausedNotificationEnabled(not iH)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = o7:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not iH
            end
        end)
        if not iH then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(oP, "GameplayPaused", false)
            else
                oP.GameplayPaused = false
            end
        end)
    end
    local function iU(iV)
        local wg = if not iV:IsA("ProximityPrompt") then 1 else 0
        if wg == 1 then
            return
        end
        iV.HoldDuration = 0
        iV.MaxActivationDistance = 50
        iV.RequiresLineOfSight = false
    end
    connection = nil
    n7(RunService.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = oP.Character
            if Character then
                for i, descendant in Character:GetDescendants() do
                    local wh_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if wh_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end))
    n7(ps.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local ws_1 = oO()
            if ws_1 then
                ws_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end))
    local CurrentCamera = Workspace.CurrentCamera
    n7(RunService.RenderStepped:Connect(function(jh)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local wu_1 = oO()
            if wu_1 then
                wu_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local wu_3 = oz()
            local wv = oO()
            if wu_3 and wv then
                wv.PlatformStand = true
                local wv_1 = Vector3.zero
                if ps:IsKeyDown(Enum.KeyCode.W) then
                    wv_1 += CurrentCamera.CFrame.LookVector
                end
                if ps:IsKeyDown(Enum.KeyCode.S) then
                    wv_1 -= CurrentCamera.CFrame.LookVector
                end
                local wA = if ps:IsKeyDown(Enum.KeyCode.A) then 1 else 0
                if wA == 1 then
                    wv_1 -= CurrentCamera.CFrame.RightVector
                end
                if ps:IsKeyDown(Enum.KeyCode.D) then
                    wv_1 += CurrentCamera.CFrame.RightVector
                end
                if ps:IsKeyDown(Enum.KeyCode.Space) then
                    wv_1 += Vector3.new(0, 1, 0)
                end
                local wD = if ps:IsKeyDown(Enum.KeyCode.LeftControl) then 1 else 0
                if wD == 1 then
                    wv_1 -= Vector3.new(0, 1, 0)
                end
                wu_3.AssemblyLinearVelocity = Vector3.zero
                if wv_1.Magnitude > 0 then
                    wu_3.CFrame = wu_3.CFrame + wv_1.Unit * Options.FlySpeed.Value * jh
                end
            end
        end
    end))
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local wE = oO()
            if wE then
                wE.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local wG = oO()
            if wG then
                wG.WalkSpeed = 16
            end
        end
    end)
    Toggles.AntiGameplayPause:OnChanged(function()
        iG(Toggles.AntiGameplayPause.Value)
    end)
    iG(true)
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in Workspace:GetDescendants() do
                pcall(iU, descendant)
            end
            connection = Workspace.DescendantAdded:Connect(function(jL)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(iU, jL)
                end
            end)
            n7(connection)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                iG(true)
            end
        end
    end)
    return iG, function()
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
end
o0, oW = x4_29()
x4_28 = function(jW)
    local jX = 0
    local jY = tick()
    jW:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = jW:AddLabel("AFK triggers: 0")
    local function j_()
        local CurrentCamera = Workspace.CurrentCamera
        if not CurrentCamera then
            return
        end
        pn:CaptureController()
        pn:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        jX += 1
        jY = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. jX)
        end)
    end
    local connection = oP.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(j_)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local wY = Toggles.AntiAfk.Value and tick() - jY >= 60
            if wY then
                pcall(j_)
            end
        end
    end)
    jW:AddButton({
        Text = "Unload UI",
        Func = function()
            Library:Unload()
        end
    })
    return connection
end
x4_10 = oI.Settings:AddLeftGroupbox("Menu")
x4_10:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
oB = x4_28(x4_10)
x4_11:SetLibrary(Library)
x4_11:SetFolder("TempoHub")
x4_11:SaveDefault("Evil Hello Kitty")
x4_11:ApplyToTab(oI.Settings)
x4_11:LoadDefault()
op:SetLibrary(Library)
op:IgnoreThemeSettings()
op:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
op:SetFolder("TempoHub/BuildABeeSwarm")
x4_26 = op:BuildConfigSection(oI.Settings)
op:LoadAutoloadConfig()
x4_7 = function(kq)
    local function kr(ks, kt)
        local w3_1 = (ks == "Toggle" and Toggles or Options)[kt]
        local w2_2 = type(w3_1) == "table" and w3_1.Type == ks
        return w2_2 and w3_1 or nil
    end
    local function kC(kD, kE)
        local Type = kE.Type
        if Type == "Toggle" then
            return { idx = kD, type = "Toggle", value = kE.Value == true }
        elseif Type == "Slider" then
            return { idx = kD, type = "Slider", value = tostring(kE.Value) }
        elseif Type == "Dropdown" then
            return { idx = kD, type = "Dropdown", multi = kE.Multi == true, value = kE.Value }
        elseif Type == "Input" then
            local w7 = kE.Value or ""
            return { idx = kD, type = "Input", text = tostring(w7) }
        elseif Type == "ColorPicker" then
            return { idx = kD, type = "ColorPicker", value = kE.Value:ToHex(), transparency = kE.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = kD,
                type = "KeyPicker",
                mode = kE.Mode,
                key = kE.Value,
                modifiers = kE.Modifiers,
                toggled = kE.Toggled
            }
        else
            return nil
        end
    end
    local function kG()
        local xd = {}
        for k, v in { Toggles, Options } do
            for k, v in v do
                local xe = type(v) == "table" and type(v.Type) == "string" and not op.Ignore[k]
                if xe then
                    local xe_1 = kC(k, v)
                    if xe_1 then
                        xd[#xd + 1] = xe_1
                    end
                end
            end
        end
        table.sort(xd, function(kO, kP)
            if kO.type ~= kP.type then
                return kO.type < kP.type
            end
            return kO.idx < kP.idx
        end)
        return { objects = xd }
    end
    local function kQ(kR)
        local xx
        xx = nil
        local xy = type(kR) ~= "table" or type(kR.idx) ~= "string" or type(kR.type) ~= "string" or op.Ignore[kR.idx]
        if xy then
            return false
        end
        xx = kr(kR.type, kR.idx)
        if not xx then
            return false
        end
        local xy_1 = pcall(function()
            if kR.type == "Input" then
                if type(kR.text) ~= "string" then
                    return
                end
                xx:SetValue(kR.text)
            elseif kR.type == "ColorPicker" then
                xx:SetValueRGB(Color3.fromHex(kR.value), kR.transparency)
            elseif kR.type == "KeyPicker" then
                xx:SetValue({ kR.key, kR.mode, kR.modifiers })
                if kR.mode == "Toggle" and kR.toggled ~= nil then
                    xx.Toggled = kR.toggled
                    xx:Update()
                end
            else
                xx:SetValue(kR.value)
            end
        end)
        return xy_1
    end
    kq:AddDivider()
    kq:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    kq:AddButton("Export Config to Clipboard", function()
        local xB_1
        local xA_1
        xA_1, xB_1 = pcall(pj.JSONEncode, pj, kG())
        if not xA_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local xA_2 = setclipboard or toclipboard
        local xA_3 = type(xA_2) ~= "function" or not pcall(xA_2, xB_1)
        if xA_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    kq:AddButton("Import Config from Clipboard Text", function()
        local xJ_1
        local xH = Options.SaveManager_ImportSource.Value or ""
        local xH_1
        local xI = tostring(xH):match("^%s*(.-)%s*$")
        if xI == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        xH_1, xJ_1 = pcall(pj.JSONDecode, pj, xI)
        local xI_1 = not xH_1 or type(xJ_1) ~= "table" or type(xJ_1.objects) ~= "table"
        if xI_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local xH_2 = 0
        for i, v in ipairs(xJ_1.objects) do
            if kQ(v) then
                xH_2 += 1
            end
        end
        if xH_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local xJ_2 = xH_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(xH_2, xJ_2), 6)
    end)
end
x4_7(x4_26)
Library:OnUnload(function()
    ot(false)
    for k, v in oc do
        local x_ = v
        pcall(function()
            x_:Disconnect()
        end)
    end
    table.clear(oc)
    if oB then
        pcall(function()
            oB:Disconnect()
        end)
    end
    if oW then
        pcall(oW)
    end
    if o0 then
        pcall(o0, false)
    end
    if getgenv then
        getgenv().__TempoBuildABeeSwarmLib = nil
    end
end)
pcall(fn128)
end)(...)

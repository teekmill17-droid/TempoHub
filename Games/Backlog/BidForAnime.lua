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
getgenv().TempoHoodSubtitle = "BID FOR ANIME!"
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
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
local Misc = ReplicatedStorage:WaitForChild("BrainrotsThings"):WaitForChild("Misc")
local BrainrotEconomy = require(Misc:WaitForChild("BrainrotEconomy"))
local PlayerRateDisplay = require(Misc:WaitForChild("PlayerRateDisplay"))
local BrainrotInfo = require(Misc:WaitForChild("BrainrotInfo"))
local InventoryConfig = require(Misc:WaitForChild("InventoryConfig"))
local Events = Misc:WaitForChild("Events")
local PlayerEvents = Events:WaitForChild("Player")
local TableEvents = Events:WaitForChild("Tables")
local QuickJoin = PlayerEvents:WaitForChild("QuickJoin")
local RequestInventory = PlayerEvents:WaitForChild("RequestInventory")
local InventoryUpdated = PlayerEvents:WaitForChild("InventoryUpdated")
local CollectCash = PlayerEvents:WaitForChild("CollectCash")
local ClaimOfflineEarnings = PlayerEvents:WaitForChild("ClaimOfflineEarnings")
local EquipBestBrainrots = PlayerEvents:WaitForChild("EquipBestBrainrots")
local ToggleFavourite = PlayerEvents:WaitForChild("ToggleFavourite")
local SellAll = PlayerEvents:WaitForChild("SellAll")
local SellItem = PlayerEvents:WaitForChild("SellItem")
local RebirthRequest = PlayerEvents:WaitForChild("RebirthRequest")
local PurchaseLuckUpgrade = PlayerEvents:WaitForChild("PurchaseLuckUpgrade")
local RequestIndex = PlayerEvents:WaitForChild("RequestIndex")
local IndexUpdated = PlayerEvents:WaitForChild("IndexUpdated")
local LuckBroadcast = PlayerEvents:WaitForChild("LuckBroadcast")
local MoneyBroadcast = PlayerEvents:WaitForChild("MoneyBroadcast")
local ChairShopUpdated = PlayerEvents:WaitForChild("ChairShopUpdated")
local PurchaseChair = PlayerEvents:WaitForChild("PurchaseChair")
local EquipChair = PlayerEvents:WaitForChild("EquipChair")
local AuctionStarted = TableEvents:WaitForChild("AuctionStarted")
local AuctionStateUpdated = TableEvents:WaitForChild("AuctionStateUpdated")
local AuctionEnded = TableEvents:WaitForChild("AuctionEnded")
local AuctionCancelled = TableEvents:WaitForChild("AuctionCancelled")
local AuctionPrompt = TableEvents:WaitForChild("AuctionPrompt")
local BidSubmitted = TableEvents:WaitForChild("BidSubmitted")
local BidRejected = TableEvents:WaitForChild("BidRejected")
local MatchResolved = TableEvents:WaitForChild("MatchResolved")
local PlayWithAIRequest = TableEvents:WaitForChild("PlayWithAIRequest")
local TableOptionRequest = TableEvents:WaitForChild("TableOptionRequest")
local GetTableOptionConfig = TableEvents:WaitForChild("GetTableOptionConfig")
local SpinWheelRemotes = ReplicatedStorage:WaitForChild("SpinWheelRemotes")
local SpinRequest = SpinWheelRemotes:WaitForChild("SpinRequest")
local SpinResult = SpinWheelRemotes:WaitForChild("SpinResult")
local RewardedAdSpinRequest = SpinWheelRemotes:WaitForChild("RewardedAdSpinRequest")
local GAME_NAME = "Bid for Anime!"
local DISCORD_INVITE = "https://discord.gg/K7Qxnxkk46"
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = getgenv().Library
pcall(function()
    Library.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end)
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
local Toggles = Library.Toggles
local Options = Library.Options
local function copyDiscord()
    if setclipboard then
        setclipboard(DISCORD_INVITE)
    elseif toclipboard then
        toclipboard(DISCORD_INVITE)
    end
    Library:Notify("Copied Discord invite to clipboard")
end
local RARITIES = {
    "Common",
    "Uncommon",
    "Rare",
    "Epic",
    "Legendary",
    "Mythic",
    "Cosmic",
    "Secret",
    "Celestial",
    "Divine",
    "Anime God",
    "Transcendent",
    "Omnipotent",
}
local SELLABLE_RARITIES = {
    "Common",
    "Uncommon",
    "Rare",
    "Epic",
    "Legendary",
    "Mythic",
    "Cosmic",
    "Secret",
    "Celestial",
}
local VARIANTS = {
    "Normal",
    "Golden",
    "Diamond",
    "Galaxy",
    "Lava",
    "Volcanic",
    "Rainbow",
    "Hacked",
    "Void",
}
local BID_TIERS = { "Small", "Medium", "High", "Extreme" }
local TABLE_OPTIONS = { "GuaranteedSecret", "GuaranteedDivine", "LuckyBlock" }
local inventory = {}
local favourites = {}
local indexEntries = {}
local playerLuck = {}
local playerMoney = {}
local chairShop = nil
local activeAuction = nil
local activePrompt = nil
local lastPromptId = nil
local spinning = false
local Tables = workspace:WaitForChild("Map"):WaitForChild("Tables")
local LeaveTableAction = LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("ConsoleActions"):WaitForChild("BidConsoleLeaveTable")
InventoryUpdated.OnClientEvent:Connect(function(items, _, favourited)
    inventory = type(items) == "table" and items or {}
    favourites = type(favourited) == "table" and favourited or {}
end)
IndexUpdated.OnClientEvent:Connect(function(mode, entries)
    if mode == "__FULL__" and type(entries) == "table" then
        indexEntries = entries
    end
end)
LuckBroadcast.OnClientEvent:Connect(function(userId, luck)
    playerLuck[userId] = tonumber(luck) or 0
end)
MoneyBroadcast.OnClientEvent:Connect(function(userId, money)
    playerMoney[userId] = tonumber(money) or 0
end)
ChairShopUpdated.OnClientEvent:Connect(function(payload)
    if type(payload) == "table" then
        chairShop = payload
    end
end)
local function setAuction(payload)
    if type(payload) == "table" then
        activeAuction = payload
    end
end
AuctionStarted.OnClientEvent:Connect(setAuction)
AuctionStateUpdated.OnClientEvent:Connect(setAuction)
local function clearAuction()
    activeAuction = nil
    activePrompt = nil
end
AuctionEnded.OnClientEvent:Connect(clearAuction)
AuctionCancelled.OnClientEvent:Connect(clearAuction)
SpinResult.OnClientEvent:Connect(function()
    spinning = false
end)
RequestInventory:FireServer()
local function isOn(name)
    local toggle = Toggles[name]
    return toggle ~= nil and toggle.Value == true
end
local function getNumber(name, fallback)
    local option = Options[name]
    return option and tonumber(option.Value) or fallback
end
local function getSelected(name)
    local option = Options[name]
    local value = option and option.Value
    return type(value) == "table" and value or {}
end
local function getMoney()
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    local money = stats and stats:FindFirstChild("Money")
    return money and money.Value or 0
end
local function cashPerSecond(item)
    if type(item) ~= "table" then
        return 0
    end
    local ok, value = pcall(function()
        local multiplier = PlayerRateDisplay.getEffectiveCashMultiplier()
        return BrainrotEconomy.getCashPerSecondForItem(item, multiplier, BrainrotEconomy.getBestNonNyanCps(inventory, multiplier))
    end)
    return ok and (tonumber(value) or 0) or 0
end
local function isFavourited(id)
    for _, favourite in favourites do
        if favourite == id then
            return true
        end
    end
    return false
end
local function isSeated()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local seat = humanoid and humanoid.SeatPart
    return seat ~= nil and seat:IsDescendantOf(Tables)
end
local function leaveTable()
    pcall(function()
        LeaveTableAction:Invoke()
    end)
    clearAuction()
end
local function currentBrainrot()
    if type(activeAuction) ~= "table" or type(activeAuction.brainrot) ~= "table" then
        return nil
    end
    return activeAuction.brainrot
end
local function isMissingFromIndex(brainrot)
    if not brainrot or not brainrot.sourceType or not brainrot.name or not brainrot.variant then
        return false
    end
    return indexEntries[brainrot.sourceType .. "|" .. brainrot.name .. "|" .. brainrot.variant] ~= true
end
local function matchesBidFilters(brainrot)
    local rarities = getSelected("BidRarities")
    local variants = getSelected("BidVariants")
    local hasRarity = next(rarities) ~= nil
    local hasVariant = next(variants) ~= nil
    if not hasRarity and not hasVariant then
        return true
    end
    if not brainrot then
        return true
    end
    return (hasRarity and rarities[brainrot.rarity] == true) or (hasVariant and variants[brainrot.variant] == true)
end
local function hasBadOpponent()
    local participants = type(activeAuction) == "table" and activeAuction.participants
    if type(participants) ~= "table" then
        return false
    end
    local minLuck = getNumber("MinOpponentLuck", 0)
    local minMoney = getNumber("MinOpponentMoney", 0)
    for _, participant in participants do
        local userId = type(participant) == "table" and participant.userId
        if userId and userId ~= LocalPlayer.UserId then
            local luck = playerLuck[userId] or 0
            local money = tonumber(participant.money) or playerMoney[userId] or 0
            if minLuck > 0 and luck < minLuck then
                return true
            end
            if minMoney > 0 and money < minMoney then
                return true
            end
        end
    end
    return false
end
local function isCheapAuction(brainrot)
    local floor = getNumber("PassUnder", 0)
    if floor <= 0 or not brainrot then
        return false
    end
    return cashPerSecond(brainrot) < floor
end
local function pickBidIndex(prompt, ignoreLimits)
    local cap = ignoreLimits and 0 or getNumber("MaxBid", 0)
    local strategy = ignoreLimits and "Highest Affordable"
        or (Options.BidStrategy and Options.BidStrategy.Value or "Highest Affordable")
    local options = type(prompt.options) == "table" and prompt.options or {}
    local function usable(index)
        local option = options[index]
        if not option or option.canAfford ~= true then
            return false
        end
        local amount = tonumber(option.amount) or 0
        return cap <= 0 or amount <= cap
    end
    for tier, name in BID_TIERS do
        if strategy == name then
            return usable(tier) and tier or nil
        end
    end
    if strategy == "Lowest" then
        for index = 1, #BID_TIERS do
            if usable(index) then
                return index
            end
        end
        return nil
    end
    for index = #BID_TIERS, 1, -1 do
        if usable(index) then
            return index
        end
    end
    return nil
end
local function respondToPrompt(prompt)
    local brainrot = currentBrainrot()
    local index = nil
    if isOn("IndexPriority") and isMissingFromIndex(brainrot) then
        index = pickBidIndex(prompt, true)
    elseif matchesBidFilters(brainrot) and not (isOn("AutoPassCheap") and isCheapAuction(brainrot)) then
        index = pickBidIndex(prompt, false)
    end
    if index then
        local option = prompt.options[index]
        BidSubmitted:FireServer({
            action = "bid",
            auctionId = prompt.auctionId,
            promptId = prompt.promptId,
            amount = option.amount,
        })
        return
    end
    if prompt.canPass == true then
        BidSubmitted:FireServer({
            action = "pass",
            auctionId = prompt.auctionId,
            promptId = prompt.promptId,
        })
    end
end
AuctionStarted.OnClientEvent:Connect(function()
    if Library.Unloaded or not isOn("AutoLeaveBad") then
        return
    end
    if hasBadOpponent() then
        leaveTable()
    end
end)
AuctionPrompt.OnClientEvent:Connect(function(prompt)
    if type(prompt) ~= "table" then
        return
    end
    activePrompt = prompt
    if not prompt.active or Library.Unloaded or not isOn("AutoBid") then
        return
    end
    lastPromptId = prompt.promptId
    task.delay(getNumber("BidDelay", 0.5), function()
        if Library.Unloaded or not isOn("AutoBid") or activePrompt ~= prompt then
            return
        end
        respondToPrompt(prompt)
    end)
end)
BidRejected.OnClientEvent:Connect(function(payload)
    if not isOn("AutoBid") or type(activePrompt) ~= "table" or not activePrompt.active then
        return
    end
    if type(payload) == "table" and payload.promptId and payload.promptId ~= lastPromptId then
        return
    end
    if activePrompt.canPass == true then
        BidSubmitted:FireServer({
            action = "pass",
            auctionId = activePrompt.auctionId,
            promptId = activePrompt.promptId,
        })
    end
end)
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
local function rarityOf(name)
    local info = type(name) == "string" and BrainrotInfo[name]
    local rarities = type(info) == "table" and info.Rarities
    return type(rarities) == "table" and rarities[1] or "Unknown"
end
local function rarityColour(rarity)
    local colour = InventoryConfig.RARITY_COLOURS[rarity]
    if typeof(colour) ~= "Color3" then
        return 3092790
    end
    return math.floor(colour.R * 255 + 0.5) * 65536
        + math.floor(colour.G * 255 + 0.5) * 256
        + math.floor(colour.B * 255 + 0.5)
end
local function formatMoney(value)
    local ok, text = pcall(PlayerRateDisplay.formatMoney, value)
    return ok and text or ("$" .. tostring(math.floor(tonumber(value) or 0)))
end
local function sendWebhook(payload)
    local url = Options.WebhookUrl and Options.WebhookUrl.Value or ""
    if not httpRequest or type(url) ~= "string" or not url:match("^https://") then
        return false
    end
    local ok = pcall(httpRequest, {
        Url = url,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(payload),
    })
    return ok
end
local function buildWinEmbed(name, variant, finalPrice)
    local rarity = rarityOf(name)
    local variantName = (type(variant) == "string" and variant ~= "" and variant) or "Normal"
    local title = variantName == "Normal" and name or (variantName .. " " .. name)
    local value = BrainrotEconomy.getRollValue(name, variantName, 0)
    local earn = cashPerSecond({ name = name, variant = variantName, rarity = rarity })
    return {
        author = {
            name = LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")",
            icon_url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=150&height=150&format=png",
        },
        title = "Auction Won",
        description = "**" .. title .. "**",
        color = rarityColour(rarity),
        fields = {
            { name = "Rarity", value = "`" .. rarity .. "`", inline = true },
            { name = "Variant", value = "`" .. variantName .. "`", inline = true },
            { name = "Multiplier", value = "`x" .. BrainrotEconomy.getVariantMultiplier(variantName) .. "`", inline = true },
            { name = "Cash / Second", value = "`" .. formatMoney(earn) .. "`", inline = true },
            { name = "Value", value = "`" .. formatMoney(value) .. "`", inline = true },
            { name = "Paid", value = "`" .. formatMoney(finalPrice or 0) .. "`", inline = true },
        },
        footer = { text = "Tempo Hub | " .. GAME_NAME },
        timestamp = DateTime.now():ToIsoDate(),
    }
end
local function sendWin(name, variant, finalPrice)
    return sendWebhook({
        username = "Tempo Hub",
        content = isOn("WebhookPing") and "@everyone" or nil,
        embeds = { buildWinEmbed(name, variant, finalPrice) },
    })
end
MatchResolved.OnClientEvent:Connect(function(_, _, _, outcome, name, variant, _, finalPrice)
    if Library.Unloaded or not isOn("WebhookWins") or outcome ~= "win" or type(name) ~= "string" then
        return
    end
    task.spawn(sendWin, name, variant, finalPrice)
end)
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = DISCORD_INVITE .. " | " .. GAME_NAME,
    Icon = 18657887261,
    NotifySide = "Right",
    ShowCustomCursor = false,
})
local Tabs = {
    Info = Window:AddTab("Info", "info"),
    Auction = Window:AddTab("Auction", "gavel"),
    Luck = Window:AddTab("Luck", "clover"),
    Economy = Window:AddTab("Economy", "coins"),
    Webhook = Window:AddTab("Webhook", "webhook"),
    Settings = Window:AddTab("Settings", "settings"),
}
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
AddDiscordButton(Tabs.Info)
AddDiscordButton(Tabs.Auction)
AddDiscordButton(Tabs.Luck)
AddDiscordButton(Tabs.Economy)
AddDiscordButton(Tabs.Webhook)
AddDiscordButton(Tabs.Settings)
local InfoGroup = Tabs.Info:AddLeftGroupbox("Basic Info", "circle-user")
local executorName = "Unknown"
pcall(function()
    if identifyexecutor then
        local name, version = identifyexecutor()
        if type(name) == "string" and name ~= "" then
            executorName = type(version) == "string" and version ~= "" and (name .. " " .. version) or name
        end
    end
end)
InfoGroup:AddLabel("Executor: " .. executorName, true)
InfoGroup:AddLabel("Game: " .. GAME_NAME, true)
InfoGroup:AddLabel("Player: " .. LocalPlayer.Name, true)
InfoGroup:AddLabel("Status: Keyless", true)
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
local JoinGroup = Tabs.Auction:AddLeftGroupbox("Auto Join", "door-open")
JoinGroup:AddToggle("AutoJoin", {
    Text = "Auto Join Auction",
    Default = false,
})
JoinGroup:AddToggle("AutoPlayAI", {
    Text = "Duel AI When Empty",
    Default = false,
})
JoinGroup:AddSlider("JoinDelay", {
    Text = "Join Delay",
    Default = 0.5,
    Min = 0.1,
    Max = 20,
    Rounding = 1,
})
local LeaveGroup = Tabs.Auction:AddLeftGroupbox("Auto Leave", "door-closed")
LeaveGroup:AddToggle("AutoLeaveBad", {
    Text = "Leave Bad Opponents",
    Default = false,
})
LeaveGroup:AddInput("MinOpponentLuck", {
    Text = "Min Opponent Luck",
    Default = "0",
    Numeric = true,
    Finished = true,
})
LeaveGroup:AddInput("MinOpponentMoney", {
    Text = "Min Opponent Money",
    Default = "0",
    Numeric = true,
    Finished = true,
})
local BidGroup = Tabs.Auction:AddRightGroupbox("Auto Bid", "gavel")
BidGroup:AddToggle("AutoBid", {
    Text = "Auto Bid",
    Default = false,
})
BidGroup:AddDropdown("BidStrategy", {
    Values = { "Highest Affordable", "Lowest", "Small", "Medium", "High", "Extreme" },
    Default = "Highest Affordable",
    Text = "Bid Strategy",
})
BidGroup:AddInput("MaxBid", {
    Text = "Max Bid",
    Default = "0",
    Numeric = true,
    Finished = true,
})
BidGroup:AddDropdown("BidRarities", {
    Values = RARITIES,
    Default = {},
    Multi = true,
    Text = "Only Bid Rarities",
})
BidGroup:AddDropdown("BidVariants", {
    Values = VARIANTS,
    Default = {},
    Multi = true,
    Text = "Only Bid Variants",
})
BidGroup:AddToggle("IndexPriority", {
    Text = "Always Bid For Index",
    Default = false,
})
BidGroup:AddToggle("AutoPassCheap", {
    Text = "Auto Pass Cheap Animes",
    Default = false,
})
BidGroup:AddInput("PassUnder", {
    Text = "Pass Under Cash Per Second",
    Default = "0",
    Numeric = true,
    Finished = true,
})
BidGroup:AddSlider("BidDelay", {
    Text = "Bid Delay",
    Default = 0.5,
    Min = 0,
    Max = 8,
    Rounding = 1,
})
local SpinGroup = Tabs.Luck:AddLeftGroupbox("Spin Wheel", "disc-3")
SpinGroup:AddToggle("AutoSpin", {
    Text = "Auto Spin",
    Default = false,
})
SpinGroup:AddSlider("SpinDelay", {
    Text = "Spin Delay",
    Default = 8,
    Min = 3,
    Max = 30,
    Rounding = 1,
})
SpinGroup:AddButton({
    Text = "Use Rewarded Ad Spin",
    Func = function()
        if (LocalPlayer:GetAttribute("RewardedAdSpinsRemaining") or 0) <= 0 then
            Library:Notify("No rewarded ad spins left today")
            return
        end
        RewardedAdSpinRequest:FireServer()
    end,
})
local LuckGroup = Tabs.Luck:AddRightGroupbox("Luck Upgrades", "trending-up")
LuckGroup:AddToggle("AutoLuck", {
    Text = "Auto Buy Luck",
    Default = false,
})
LuckGroup:AddDropdown("LuckAmount", {
    Values = { "10", "50", "100" },
    Default = "100",
    Text = "Luck Per Purchase",
})
LuckGroup:AddInput("LuckReserve", {
    Text = "Keep Money Reserve",
    Default = "0",
    Numeric = true,
    Finished = true,
})
LuckGroup:AddSlider("LuckDelay", {
    Text = "Loop Delay",
    Default = 2,
    Min = 0.5,
    Max = 30,
    Rounding = 1,
})
local ChairGroup = Tabs.Luck:AddRightGroupbox("Chairs", "armchair")
ChairGroup:AddToggle("AutoBuyChair", {
    Text = "Auto Buy Best Chair",
    Default = false,
})
ChairGroup:AddSlider("ChairDelay", {
    Text = "Loop Delay",
    Default = 5,
    Min = 1,
    Max = 60,
    Rounding = 1,
})
local BlockGroup = Tabs.Luck:AddLeftGroupbox("Lucky Blocks", "package-open")
BlockGroup:AddToggle("AutoTableOption", {
    Text = "Auto Use Tokens",
    Default = false,
})
BlockGroup:AddDropdown("TableOption", {
    Values = TABLE_OPTIONS,
    Default = "GuaranteedSecret",
    Text = "Token Type",
})
local CashGroup = Tabs.Economy:AddLeftGroupbox("Cash", "hand-coins")
CashGroup:AddToggle("AutoCollect", {
    Text = "Auto Collect Cash",
    Default = false,
})
CashGroup:AddToggle("AutoEquipBest", {
    Text = "Auto Equip Best",
    Default = false,
})
CashGroup:AddToggle("AutoRebirth", {
    Text = "Auto Rebirth",
    Default = false,
})
CashGroup:AddSlider("CashDelay", {
    Text = "Loop Delay",
    Default = 2,
    Min = 0.5,
    Max = 30,
    Rounding = 1,
})
CashGroup:AddButton({
    Text = "Claim Offline Earnings",
    Func = function()
        ClaimOfflineEarnings:FireServer()
    end,
})
local CollectionGroup = Tabs.Economy:AddRightGroupbox("Collection", "star")
CollectionGroup:AddToggle("AutoFavourite", {
    Text = "Auto Favorite",
    Default = false,
})
CollectionGroup:AddDropdown("FavouriteRarities", {
    Values = RARITIES,
    Default = {},
    Multi = true,
    Text = "Favorite Rarities",
})
CollectionGroup:AddDropdown("FavouriteVariants", {
    Values = VARIANTS,
    Default = {},
    Multi = true,
    Text = "Favorite Variants",
})
CollectionGroup:AddToggle("AutoUnfavourite", {
    Text = "Auto Unfavorite",
    Default = false,
})
CollectionGroup:AddDropdown("UnfavouriteRarities", {
    Values = RARITIES,
    Default = {},
    Multi = true,
    Text = "Unfavorite Rarities",
})
CollectionGroup:AddDropdown("UnfavouriteVariants", {
    Values = VARIANTS,
    Default = {},
    Multi = true,
    Text = "Unfavorite Variants",
})
CollectionGroup:AddButton({
    Text = "Unfavorite Everything",
    Func = function()
        local ids = table.clone(favourites)
        task.spawn(function()
            for _, id in ids do
                ToggleFavourite:FireServer(id)
                task.wait(0.15)
            end
            Library:Notify("Unfavorited " .. #ids .. " animes")
        end)
    end,
})
local SellGroup = Tabs.Economy:AddRightGroupbox("Auto Sell", "banknote")
SellGroup:AddToggle("AutoSell", {
    Text = "Auto Sell",
    Default = false,
})
SellGroup:AddDropdown("SellRarities", {
    Values = SELLABLE_RARITIES,
    Default = {},
    Multi = true,
    Text = "Sell Rarities",
})
SellGroup:AddToggle("AutoSellEarn", {
    Text = "Auto Sell By Earn",
    Default = false,
})
SellGroup:AddInput("SellUnderEarn", {
    Text = "Sell Under Cash Per Second",
    Default = "0",
    Numeric = true,
    Finished = true,
})
SellGroup:AddSlider("SellDelay", {
    Text = "Loop Delay",
    Default = 5,
    Min = 1,
    Max = 60,
    Rounding = 1,
})
local WebhookGroup = Tabs.Webhook:AddRightGroupbox("Discord Webhook", "webhook")
WebhookGroup:AddInput("WebhookUrl", {
    Text = "Webhook URL",
    Default = "",
    Placeholder = "https://discord.com/api/webhooks/...",
    Finished = true,
})
WebhookGroup:AddToggle("WebhookWins", {
    Text = "Send Auction Wins",
    Default = false,
})
WebhookGroup:AddToggle("WebhookPing", {
    Text = "Ping Everyone",
    Default = false,
})
WebhookGroup:AddButton({
    Text = "Send Test Webhook",
    Func = function()
        if not httpRequest then
            Library:Notify("Your executor does not support http requests")
            return
        end
        local sample = next(BrainrotInfo)
        if sendWin(sample, "Rainbow", 1000000) == false then
            Library:Notify("Webhook failed, check the URL")
        else
            Library:Notify("Test webhook sent")
        end
    end,
})
local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind",
})
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
MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)
Library.ToggleKeybind = Options.MenuKeybind
Library:OnUnload(function()
    antiAfkBeganConnection:Disconnect()
    antiAfkChangedConnection:Disconnect()
    select("#", "Bid for Anime unloaded")
end)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Mint")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/BidForAnime")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
ThemeManager:LoadDefault()
SaveManager:LoadAutoloadConfig()
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
task.spawn(function()
    local lastAIRequest = 0
    while not Library.Unloaded do
        if isOn("AutoJoin") and LocalPlayer:GetAttribute("ClientInDuel") ~= true then
            if not isSeated() then
                QuickJoin:FireServer()
            elseif isOn("AutoPlayAI") and not activeAuction and tick() - lastAIRequest >= 3 then
                lastAIRequest = tick()
                PlayWithAIRequest:FireServer()
            end
        end
        task.wait(getNumber("JoinDelay", 0.5))
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if isOn("AutoTableOption") and not activeAuction then
            local ok, config = pcall(function()
                return GetTableOptionConfig:InvokeServer()
            end)
            if ok and type(config) == "table" then
                local key = Options.TableOption and Options.TableOption.Value
                local entry = key and config[key]
                if entry and (tonumber(entry.tokenCount) or 0) > 0 and config._activeKey ~= key then
                    TableOptionRequest:FireServer(key)
                end
            end
        end
        task.wait(5)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if isOn("AutoSpin") and not spinning and (LocalPlayer:GetAttribute("SpinRounds") or 0) > 0 then
            spinning = true
            SpinRequest:FireServer()
            task.delay(getNumber("SpinDelay", 8) + 5, function()
                spinning = false
            end)
        end
        task.wait(getNumber("SpinDelay", 8))
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if isOn("AutoLuck") and getMoney() > getNumber("LuckReserve", 0) then
            PurchaseLuckUpgrade:FireServer(Options.LuckAmount and Options.LuckAmount.Value or "100")
        end
        task.wait(getNumber("LuckDelay", 2))
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if isOn("AutoCollect") then
            CollectCash:FireServer()
        end
        if isOn("AutoEquipBest") then
            EquipBestBrainrots:FireServer()
        end
        if isOn("AutoRebirth") then
            RebirthRequest:FireServer()
        end
        task.wait(getNumber("CashDelay", 2))
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if isOn("AutoFavourite") then
            local rarities = getSelected("FavouriteRarities")
            local variants = getSelected("FavouriteVariants")
            for _, item in inventory do
                if type(item) == "table" and item.id and not isFavourited(item.id) then
                    if rarities[item.rarity] or variants[item.variant] then
                        ToggleFavourite:FireServer(item.id)
                        task.wait(0.15)
                    end
                end
            end
        end
        if isOn("AutoUnfavourite") then
            local rarities = getSelected("UnfavouriteRarities")
            local variants = getSelected("UnfavouriteVariants")
            for _, item in inventory do
                if type(item) == "table" and item.id and isFavourited(item.id) then
                    if rarities[item.rarity] or variants[item.variant] then
                        ToggleFavourite:FireServer(item.id)
                        task.wait(0.15)
                    end
                end
            end
        end
        task.wait(1)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if isOn("AutoSell") then
            local rarities = getSelected("SellRarities")
            for _, rarity in SELLABLE_RARITIES do
                if rarities[rarity] then
                    SellAll:FireServer(rarity)
                    task.wait(0.3)
                end
            end
        end
        if isOn("AutoSellEarn") then
            local threshold = getNumber("SellUnderEarn", 0)
            if threshold > 0 then
                for _, item in inventory do
                    if type(item) == "table" and item.id and not isFavourited(item.id) then
                        if cashPerSecond(item) < threshold then
                            SellItem:FireServer(item.id)
                            task.wait(0.2)
                        end
                    end
                end
            end
        end
        task.wait(getNumber("SellDelay", 5))
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if isOn("AutoBuyChair") then
            if not chairShop then
                PurchaseChair:FireServer("DefaultChair")
            else
                local normal = type(chairShop.normal) == "table" and chairShop.normal or {}
                local money = getMoney()
                local target, targetLuck = nil, -1
                for name, chair in normal do
                    if type(chair) == "table" and chair.owned ~= true and (tonumber(chair.price) or math.huge) <= money then
                        local luck = tonumber(chair.luck) or 0
                        if luck > targetLuck then
                            target, targetLuck = name, luck
                        end
                    end
                end
                if target then
                    PurchaseChair:FireServer(target)
                else
                    local best, bestLuck = nil, -1
                    for _, group in { normal, type(chairShop.special) == "table" and chairShop.special or {} } do
                        for name, chair in group do
                            if type(chair) == "table" and chair.owned == true then
                                local luck = tonumber(chair.luck) or 0
                                if luck > bestLuck then
                                    best, bestLuck = name, luck
                                end
                            end
                        end
                    end
                    if best and chairShop.equippedChair ~= best then
                        EquipChair:FireServer(best)
                        chairShop.equippedChair = best
                    end
                end
            end
        end
        task.wait(getNumber("ChairDelay", 5))
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        RequestInventory:FireServer()
        RequestIndex:FireServer()
        task.wait(10)
    end
end)
end)(...)

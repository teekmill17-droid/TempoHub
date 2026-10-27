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
getgenv().TempoHoodSubtitle = "MY DEALERSHIP"
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
local vy_4, vy_5, vy_11
local vy_6_1, vy_6_2
local nm
local m1
local Toggles
local mJ
local ns
local nR
local mP
local ny
local nf
local ExpansionConfig
local LocalPlayer
local mC
local nK
local mI
local Net
local mO
local nx
local ne
local nW
local mU
local nD
local m_
local nJ
local mH
local nq
local nP
local mN
local nw
local nd
local Library
local mT
local nj
local RebirthConfig
local mG
local np
local nO
local mM
local nv
local connection
local nU
local mS
local nB
local mY
local nH
local mF
local no
local nN
local m9
local nT
local ClientRegistry
local nA
local nh
local Options
local mE
local nn
local m2
local mK
local mQ
local nz
local ng
local connection2
local nF
local function fn10()
    select("#", "Unloaded!")
end
local function fn13(al, am)
    if setclipboard then
        setclipboard(al)
    elseif toclipboard then
        toclipboard(al)
    end
    Library:Notify(am)
end
local function fn34(aU)
    local pg = Options[aU]
    return pg and pg.Value
end
local function fn63()
    local Character = LocalPlayer.Character
    local pN = Character and Character:FindFirstChild("HumanoidRootPart")
    return pN
end
local function fn64(cz, cA, cB)
    for i, v in ipairs(cB) do
        local qL = v.Size.X / 2
        local qM = math.abs(cz - v.Position.X) <= qL and math.abs(cA - v.Position.Z) <= qL
        if qM then
            return true
        end
    end
    return false
end
local function fn65()
    local uY_1
    local uX_1
    if identifyexecutor then
        uY_1, uX_1 = identifyexecutor()
        local uZ = uY_1 ~= ""
        local u_ = type(uY_1) == "string" and uZ
        if u_ then
            local uZ_1 = type(uX_1) == "string" and uX_1 ~= "" and uY_1 .. " " .. uX_1
            nh = uZ_1 or uY_1
        end
    end
end
local function worker2()
    while not Library.Unloaded do
        if mE("AutoBuyStands") then
            pcall(nK)
        end
        if mE("AutoBuyContainers") then
            pcall(mO)
        end
        if mE("AutoBuyDecor") then
            pcall(nd)
        end
        if mE("AutoBuyPlotSlot") then
            pcall(mN)
        end
        if mE("AutoHireEmployees") then
            pcall(m2)
        end
        task.wait(nH("ShopDelay", 0.5))
    end
end
local function fn110(cW)
    return string.format("%.0f:%.0f", cW.X, cW.Z)
end
local function fn115(as, at)
    return string.format('<font color="%s">%s</font>', at, as)
end
local function fn121()
    nB(ny, "Copied Discord invite to clipboard")
end
local function onRscripts()
    if setclipboard then
        setclipboard(nv)
    elseif toclipboard then
        toclipboard(nv)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function fn216()
    connection:Disconnect()
    connection2:Disconnect()
end
local function fn237(dF, dG, dH)
    local rH = Vector3.new(dF.X, 0, dF.Z)
    for k, v in dG do
        if (rH - Vector3.new(v.X, 0, v.Z)).Magnitude < dH then
            return true
        end
    end
    return false
end
local function onInputBegan()
    nR = tick()
end
local function fn259(cY, cZ, c_, c0, c1)
    local q1, q2, q3, q4, q5, rd, rf, rg, ri, rk, rl
    local q9 = 7
    while true do
        local q9_1 = 12288 - q9
        do
            if q9_1 < 12277 then
                if q9_1 < 12275 then
                    if q9_1 < 12273 then
                        if q9_1 < 7423 then
                            break
                        elseif q9_1 < 12271 then
                            break
                        elseif q9_1 < 12272 then
                            if q9_1 == 12271 then
                                rf += 1
                                q9 = 5
                            else
                                q9 = 12276
                                continue
                            end
                        else
                            q9 = 13
                        end
                    elseif q9_1 < 12274 then
                        q1 = math.rad
                        q2 = cZ
                        q9 = if q2 then 9 else 10
                    else
                        q9 = if rk <= ri then 12 else 1
                    end
                elseif q9_1 < 12276 then
                    if q9_1 == 12275 then
                        rk += 1
                        q9 = 14
                    else
                        q9 = 12283
                        continue
                    end
                elseif q9_1 == 12276 then
                    rl = rk
                    q9 = 6
                else
                    q9 = 13962
                    continue
                end
            elseif q9_1 < 12283 then
                if q9_1 < 12280 then
                    if q9_1 < 12278 then
                        if q9_1 == 12277 then
                            q5 = -c_ + c_ * 2 * (rg / q3)
                            rk = 0
                            ri = q4
                            q9 = 14
                        else
                            q9 = 1764
                            continue
                        end
                    elseif q9_1 < 12279 then
                        q2 = 0
                        q9 = 9
                    else
                        local q3_1 = q1(q2)
                        q1 = math.cos(q3_1)
                        q2 = math.sin(q3_1)
                        q3 = math.max(1, math.ceil(c_ * 2 / 2))
                        q4 = math.max(1, math.ceil(c0 * 2 / 2))
                        rf = 0
                        rd = q3
                        q9 = 5
                    end
                elseif q9_1 < 12281 then
                    return true
                elseif q9_1 < 12282 then
                    if q9_1 == 12281 then
                        local rc = if #c1 == 0 then 1 else 0
                        local ra = 2073 * rc + 1808 * (1 - rc)
                        local rb = 962 * rc + 3458 * (1 - rc)
                        q9 = if (ra * 2398 + rb * 3843 + ra * rb) % 16777213 == 10662246 then 3 else 15
                    else
                        q9 = 2436
                        continue
                    end
                elseif q9_1 == 12282 then
                    local q6 = -c0 + c0 * 2 * (rl / q4)
                    local q7 = cY.X + q5 * q1 + q6 * q2
                    local q8 = cY.Z - q5 * q2 + q6 * q1
                    q9 = if not mJ(q7, q8, c1) then 2 else 16
                else
                    q9 = 12272
                    continue
                end
            elseif q9_1 < 12287 then
                if q9_1 < 12285 then
                    if q9_1 < 12284 then
                        if q9_1 == 12283 then
                            q9 = if rf <= rd then 0 else 8
                        else
                            q9 = 12272
                            continue
                        end
                    else
                        break
                    end
                elseif q9_1 < 12286 then
                    if q9_1 == 12285 then
                        return false
                    end
                    q9 = 13237
                    continue
                elseif q9_1 == 12286 then
                    return false
                else
                    q9 = 12281
                    continue
                end
            elseif q9_1 < 13237 then
                if q9_1 < 12288 then
                    if q9_1 == 12287 then
                        q9 = 17
                    else
                        q9 = 13962
                        continue
                    end
                elseif q9_1 == 12288 then
                    rg = rf
                    q9 = 11
                else
                    break
                end
            else
                break
            end
        end
    end
end
local function fn269(R)
    return R.notForSale == true
end
local function fn277()
    local tM = nD()
    if not tM then
        return
    end
    local tN = tM.rebirths or 0
    if RebirthConfig.isMaxed(tN) then
        return
    end
    local tN_1 = RebirthConfig.requirement(tN)
    local tM_2 = typeof(tN_1) ~= "number"
    local tR = if tM_2 then 1 else 0
    local tP = 3768 * tR + 500 * (1 - tR)
    local tQ = 3432 * tR + 611 * (1 - tR)
    if not ((tP * 2304 + tQ * 321 + tP * tQ) % 16777213 == 5937707) then
        tM_2 = nx() < tN_1
    end
    if tM_2 then
        return
    end
    pcall(function()
        Net:InvokeServer("Rebirth_Do")
    end)
end
local function fn282(ib)
    local DiscordGroup = ib:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = ns })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = ns })
end
local function fn284(aJ, aK)
    local o9 = Options[aJ]
    local pa = o9 and tonumber(o9.Value)
    return pa or aK
end
local function fn300(bX)
    if bX == nil then
        return true
    end
    local pZ = tonumber(bX) or bX
    local p_ = nn[pZ]
    if p_ then
        local pZ_1 = tonumber(bX) or bX
        p_ = nn[pZ_1] > os.clock()
    end
    if p_ then
        return true
    end
    local pZ_2 = mY()
    if pZ_2 then
        local p__1 = pZ_2:FindFirstChild("_Crates")
        if p__1 then
            for i, child in p__1:GetChildren() do
                if nT(child:GetAttribute("StandUid"), bX) then
                    return true
                end
            end
        end
        local p__2 = pZ_2:FindFirstChild("_Placed")
        if p__2 then
            for i, child in p__2:GetChildren() do
                if nT(child:GetAttribute("StandUid"), bX) then
                    return true
                end
            end
        end
    end
    local pZ_3 = nD()
    if pZ_3 then
        if type(pZ_3.cratePlacements) == "table" then
            for k, v in pZ_3.cratePlacements do
                local p__3 = type(v) == "table" and nT(v.standUid, bX)
                if p__3 then
                    return true
                end
            end
        end
        if type(pZ_3.placements) == "table" then
            for k, v in pZ_3.placements do
                local pZ_4 = type(v) == "table" and nT(v.standUid, bX)
                if pZ_4 then
                    return true
                end
            end
        end
    end
    return false
end
local function fn302(eu)
    if not eu then
        return nil
    end
    local sn = eu.cost or eu.price
    local sn_1 = type(sn) == "table" and typeof(sn.cash) == "number"
    if sn_1 then
        return sn.cash
    elseif typeof(sn) == "number" then
        return sn
    else
        return nil
    end
end
local function fn306(V)
    return V.robux ~= nil or V.pass ~= nil or V.passId ~= nil
end
local function fn309()
    return mM.getMyPlot()
end
local function fn364()
    local tX = nD()
    if not tX then
        return nil
    end
    local tZ = tX.ownedZones or {}
    local tZ_1 = tX.rebirths or 0
    local tX_1 = nil
    local tZ_2 = ExpansionConfig.TotalZones or 9
    local t7 = 1
    while t7 <= tZ_2 do
        local t8 = t7
        local tZ_3 = tostring(t8)
        if tZ[tZ_3] ~= true then
            local t0 = ExpansionConfig.slotInfo(tZ_3)
            local t1 = t0
            if t1 then
                t1 = (t0.rebirths or 0) <= tZ_1
            end
            if t1 then
                local t1_1 = tonumber(t0.cost) or 0
                local t2_2 = not tX_1
                if not t2_2 then
                    t2_2 = t1_1 < tX_1.cost
                end
                if t2_2 then
                    tX_1 = { id = tZ_3, cost = t1_1, rebirths = t0.rebirths or 0 }
                end
            end
        end
        t7 += 1
    end
    return tX_1
end
local function fn409(a2, a3)
    local pq = nq(a2)
    if not mT(pq) then
        return true
    end
    return pq[a3] == true
end
local function worker3()
    while not Library.Unloaded do
        if mE("AutoPlaceStands") then
            pcall(nF)
        end
        if mE("AutoPlaceContainers") then
            pcall(ne)
        end
        if mE("AutoOpenContainers") then
            pcall(nf)
        end
        if mE("AutoAuction") then
            pcall(nW)
        end
        if mE("AutoRebirth") then
            pcall(nj)
        end
        if mE("AutoCollectMoney") then
            pcall(mH)
        end
        task.wait(nH("FarmDelay", 0.4))
    end
end
local function worker()
    local u7_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local u6 = math.floor(os.clock() - nP)
        if u6 < 60 then
            u7_1 = u6 .. "s"
        elseif u6 < 3600 then
            u7_1 = string.format("%dm %ds", math.floor((u6) / (60)), u6 % 60)
        else
            u7_1 = string.format("%dh %dm", math.floor((u6) / (3600)), math.floor((u6 % 3600) / (60)))
        end
        mU:SetText(m_("Session time", u7_1, mK))
    end
end
local function fn484(cH)
    local qU = no.get(cH)
    if not qU or not qU.model then
        return nil
    end
    return mG:FindFirstChild(qU.model)
end
local function fn485()
    local tS = nD()
    local tT = tS
    if tT then
        local tU_1 = tonumber(tS.pendingCollect) or 0
        tT = tU_1
    end
    local tU_2 = tT or 0
    local tT_1 = tS
    if tT_1 then
        local tU_3 = tonumber(tS.pendingOffline) or 0
        tT_1 = tU_3
    end
    local tS_1 = tT_1 or 0
    local tS_2 = nH("CollectMinAmount", 1)
    if tU_2 + tS_1 < tS_2 then
        return
    end
    pcall(function()
        Net:FireServer("CollectMoney")
    end)
end
local function fn537(I, J)
    local oQ = {}
    for k, v in I.Order do
        local oR = I.get(v)
        local oS = oR
        if oS then
            local oT = J and J(oR, v)
            oS = not oT
        end
        if oS then
            table.insert(oQ, v)
        end
    end
    return oQ
end
local function fn551(aZ)
    for k, v in pairs(aZ) do
        if v then
            return true
        end
    end
    return false
end
local function fn587(aE)
    local o6 = Toggles[aE]
    return o6 ~= nil and o6.Value == true
end
local function fn601(ci, cj)
    if ci == nil then
        return
    end
    local qo = tonumber(ci) or ci
    local qp = os.clock()
    local qq = cj or 2
    nn[qo] = qp + qq
end
local function fn607()
    return ClientRegistry.TryGet("DataController")
end
local function fn609(av, aw, ax)
    return string.format("<b>%s</b> %s %s", av, nm("-", "#5a6070"), nm(aw, ax))
end
local function fn630(aP)
    local pc = Options[aP]
    return pc and pc.Value or {}
end
local function onCopyJoinScript_JobID()
    local u4 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, mQ)
    if setclipboard then
        setclipboard(u4)
    elseif toclipboard then
        toclipboard(u4)
    end
    Library:Notify("Copied join script to clipboard")
end
local function fn664(bS, bT)
    local pU = bT == nil
    local pU_1
    local pV = bS == nil or pU
    local pV_1
    if pV then
        return false
    elseif bS == bT then
        return true
    else
        pV_1, pU_1 = tonumber(bS), tonumber(bT)
        return pV_1 ~= nil and pV_1 == pU_1
    end
end
local function onInputChanged(i8)
    local UserInputType = i8.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        nR = tick()
    end
end
local function worker4()
    while not Library.Unloaded do
        task.wait(2)
        if mE("AntiAfk") then
            local vm = tick() - nR
            local vn = tick() - nO
            if vm >= 300 and vn >= 60 then
                pcall(nw)
            else
                if vm < 300 and vn >= 300 then
                    pcall(nw)
                end
            end
        end
    end
end
local function fn746()
    local CurrentCamera = nJ.CurrentCamera
    if not CurrentCamera then
        return
    end
    nN:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    nN:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    nO = tick()
end
local function onUnload()
    Library:Unload()
end
local function fn769()
    local qs = mY()
    local qt = qs and qs:FindFirstChild("Zones")
    if not qt then
        return {}
    end
    local qt_1 = nD()
    local qv = qt_1 and qt_1.ownedZones or {}
    local qt_3 = false
    for k, v in qv do
        if v then
            qt_3 = true
            break
        end
    end
    local qv_1 = {}
    for i, child in qt:GetChildren() do
        if child:IsA("BasePart") then
            local qs_2 = qv[child.Name] == true
            local qw = not qt_3
            local qx = not qs_2
            if qx ~= false then
                qx = qw
            end
            if qx then
                qs_2 = child.Name == tostring(ExpansionConfig.DefaultSlot)
            end
            if qs_2 then
                table.insert(qv_1, child)
            end
        end
    end
    return qv_1
end
local function fn771()
    local ru = mY()
    local rv = ru and ru:FindFirstChild("_Stands")
    local ru_1 = {}
    if not rv then
        return ru_1
    end
    for i, child in rv:GetChildren() do
        if child:IsA("Model") then
            table.insert(ru_1, child:GetPivot().Position)
        end
    end
    return ru_1
end
local function fn817()
    local sJ_1
    local sH = nD()
    local sI = not sH or type(sH.ownedContainers) ~= "table"
    local sI_1
    if sI then
        return nil
    end
    sJ_1, sI_1 = nil, -1
    for i, v in ipairs(m9) do
        if mF("PlaceContainerItems", v) then
            local sK = sH.ownedContainers[v]
            local sL = typeof(sK) == "number" and sK > 0 and i > sI_1
            if sL then
                sJ_1 = v
                sI_1 = i
            end
        end
    end
    return sJ_1
end
local function fn819(fV)
    local tq = not fV
    local ty = if tq then 1 else 0
    local tw = 2165 * ty + 2931 * (1 - ty)
    local tx = 1415 * ty + 1948 * (1 - ty)
    if not ((tw * 2029 + tx * 237 + tw * tx) % 16777213 == 7791615) then
        tq = fV:GetAttribute("Auctioning") == true
    end
    if tq then
        return false
    elseif fV:GetAttribute("OwnerUserId") ~= LocalPlayer.UserId then
        return false
    else
        local attr2 = fV:GetAttribute("VehicleUid")
        if attr2 == nil then
            return false
        end
        local attr = fV:GetAttribute("Rarity")
        local ts = fV:GetAttribute("Mutation") or "Main"
        local ts_1 = fV:GetAttribute("Value") or 0
        if not mF("AuctionRarities", tostring(attr)) then
            return false
        elseif not mF("AuctionMutations", tostring(ts)) then
            return false
        else
            local tr_1 = typeof(ts_1) == "number" and ts_1 < nH("AuctionMinValue", 0)
            if tr_1 then
                return false
            end
            return true, attr2
        end
    end
end
local function fn823()
    local sd = mY()
    local se = sd and sd:FindFirstChild("_Stands")
    local sd_1 = {}
    if not se then
        return sd_1
    end
    for i, child in se:GetChildren() do
        if child:IsA("Model") then
            local attr = child:GetAttribute("StandUid")
            local sf_1 = attr ~= nil and not nz(attr)
            if sf_1 then
                table.insert(sd_1, child)
            end
        end
    end
    return sd_1
end
local function fn839(dM)
    local rS_1
    local rR_1
    local rP = nA()
    if #rP == 0 then
        return nil
    end
    local rQ = ng()
    rR_1, rS_1 = np(dM)
    local rT = math.max(rR_1, rS_1) + 2
    local rR_2 = math.max(math.ceil(rT), math.floor(nH("StandSpacing", 16)))
    local rS_2 = nU
    for i, v in ipairs(rP) do
        local rP_1 = v.Size.X * 0.5 - rT
        local rU = v.Size.Z * 0.5 - rT
        if rP_1 >= 0 and rU >= 0 then
            local r5 = -rP_1
            while rR_2 > 0 and r5 <= rP_1 or rR_2 <= 0 and r5 >= rP_1 do
                local r6 = r5
                local sa = -rU
                while rR_2 > 0 and sa <= rU or rR_2 <= 0 and sa >= rU do
                    local sb = sa
                    local rP_3 = Vector3.new(v.Position.X + r6, mI.getCanvasTopY() + 2, v.Position.Z + sb)
                    local rV_2 = mI.snapToCanvasGrid(rP_3, 4)
                    local rP_4 = mS(rV_2)
                    local rW = not mC[rP_4] and not mP(rV_2, rQ, rR_2 - 1) and m1(dM, rV_2, rS_2)
                    if rW then
                        return mI.serverCFrame(rV_2, rS_2), rP_4
                    end
                    sa += rR_2
                end
                r5 += rR_2
            end
        end
    end
    return nil
end
mC = nil
mE = nil
mF = nil
mG = nil
mH = nil
mI = nil
mJ = nil
mK = nil
mM = nil
mN = nil
mO = nil
mP = nil
mQ = nil
ClientRegistry = nil
mS = nil
mT = nil
mU = nil
ExpansionConfig = nil
connection2 = nil
mY = nil
RebirthConfig = nil
m_ = nil
m1 = nil
m2 = nil
m9 = nil
connection = nil
nd = nil
ne = nil
nf = nil
ng = nil
nh = nil
nj = nil
nm = nil
nn = nil
no = nil
np = nil
nq = nil
local mD, mL, mX, m0, m3, m4, m5, m6, m7, m8, ni, nk, nl
Net = nil
ns = nil
nv = nil
nw = nil
nx = nil
ny = nil
nz = nil
nA = nil
nB = nil
nD = nil
LocalPlayer = nil
nF = nil
Options = nil
nH = nil
nJ = nil
nK = nil
Toggles = nil
nN = nil
nO = nil
nP = nil
nR = nil
nT = nil
nU = nil
Library = nil
nW = nil
local nt, nu, nC, nI, nM, nQ, nS, n1, n2, n3, n4, n5, n6, n7, n8, n9, ob, oc, od
nt = nil
nu = nil
nC = nil
nI = nil
nM = nil
nQ = nil
nS = nil
local oe
vy_4, n2, n8, nN, nJ, LocalPlayer, n7, ny, nv, vy_6_1, Net, vy_5, no, nk, m7, m3, RebirthConfig, n4, n3, ExpansionConfig, ClientRegistry, mM, mI, mG, mC, nU, nl, m9, m4, n6, n5, n1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local vy_10 = 47
repeat
    n9 = (vy_10 * 5 + 2) % 21 + 1
    if n9 <= 11 then
        if n9 <= 6 then
            if n9 <= 3 then
                if n9 <= 2 then
                    if n9 <= 1 then
                        local oa_1 = (vector.create((vy_10 * 3 + 4) % 11 + 1, (vy_10 * 5 + 8) % 13 + 1, (vy_10 * 4 + 10) % 17 + 1))
                        ob = (vector.create((vy_10 * 1 + 8) % 11 + 1, (vy_10 * 3 + 4) % 13 + 1, (vy_10 * 3 + 3) % 17 + 1))
                        oc = (vector.create((vy_10 * 1 + 1) % 11 + 1, (vy_10 * 3 + 5) % 13 + 1, (vy_10 * 2 + 12) % 17 + 1))
                        od = (vector.create((vy_10 * 2 + 1) % 11 + 1, (vy_10 * 1 + 1) % 13 + 1, (vy_10 * 2 + 6) % 17 + 1))
                        if vector.dot(vector.cross(oa_1, ob), (vector.cross(oc, od))) == vector.dot(oa_1, oc) * vector.dot(ob, od) - vector.dot(oa_1, od) * vector.dot(ob, oc) + 2 then
                            vy_5 = require(n3:WaitForChild("RarityConfig"))
                        else
                            n3 = require(vy_5:WaitForChild("RarityConfig"))
                        end
                        vy_10 = (vy_10 + 101) % 168
                    else
                        local oa_2 = (vector.create((vy_10 * 6 + 6) % 11 + 1, (vy_10 * 9 + 2) % 13 + 1, (vy_10 * 10 + 15) % 17 + 1))
                        ob = (vector.create((vy_10 * 6 + 6) % 11 + 1, (vy_10 * 10 + 2) % 13 + 1, (vy_10 * 14 + 8) % 17 + 1))
                        oc = (vector.create((vy_10 * 1 + 7) % 11 + 1, (vy_10 * 4 + 8) % 13 + 1, (vy_10 * 11 + 8) % 17 + 1))
                        od = (vector.create((vy_10 * 6 + 7) % 11 + 1, (vy_10 * 2 + 9) % 13 + 1, (vy_10 * 7 + 1) % 17 + 1))
                        if vector.dot(vector.cross(oa_2, ob), (vector.cross(oc, od))) == vector.dot(oa_2, oc) * vector.dot(ob, od) - vector.dot(oa_2, od) * vector.dot(ob, oc) then
                            ExpansionConfig = require(vy_5:WaitForChild("ExpansionConfig"))
                        else
                            vy_5 = require(ExpansionConfig:WaitForChild("ExpansionConfig"))
                        end
                        vy_10 = (vy_10 + 122) % 168
                    end
                else
                    local v1 = bit32.rrotate(bit32.bxor(bit32.lrotate(vy_10, 3), string.byte(tostring(m3))), 21)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(v1, 1540304222), 12), 4074104252) ~= bit32.lrotate(v1, 12) then
                        n2 = ClientRegistry:WaitForChild("PlayerScripts"):WaitForChild("Client"):WaitForChild("Lib")
                        mI = require(n2:WaitForChild("ClientRegistry"))
                        require(n2:WaitForChild("PlotUtil"))
                        mG = require(n2:WaitForChild("BuildMode"))
                        mM = LocalPlayer:WaitForChild("Assets"):WaitForChild("Stands")
                    else
                        vy_11 = LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Client"):WaitForChild("Lib")
                        ClientRegistry = require(vy_11:WaitForChild("ClientRegistry"))
                        mM = require(vy_11:WaitForChild("PlotUtil"))
                        mI = require(vy_11:WaitForChild("BuildMode"))
                        mG = n2:WaitForChild("Assets"):WaitForChild("Stands")
                    end
                    vy_10 = (vy_10 + 38) % 168
                end
            elseif n9 <= 5 then
                if n9 <= 4 then
                    local oa_3 = {
                        "abhypullmbut",
                        "fecqqepgu",
                        "ypmcjhq",
                        "nnfy",
                        "kwnbgjthfm",
                        "syjxhl",
                        "cfwmsncovwia",
                        "lfayg",
                        "mvxhtpjw",
                        "ggrvgus"
                    }
                    if oa_3[(vy_10 * 33 + 42) % 10 + 1] < oa_3[(vy_10 * 33 + 42) % 10 + 1] then
                        nU = {}
                        mC = 90
                    else
                        mC = {}
                        nU = 90
                    end
                    vy_10 = (vy_10 + 143) % 168
                else
                    local wn = bit32.rrotate(bit32.bxor(bit32.lrotate(vy_10, 12), string.byte(tostring(nN))), 4)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(wn, 194309554), 24), 2987103469) == bit32.lrotate(wn, 24) then
                        n1 = fn537
                        nl = n1(no, fn269)
                        m9 = n1(nk)
                        m4 = n1(m7)
                        n6 = n1(m3, fn306)
                    else
                        nk = fn537
                        m3 = nk(n6, fn269)
                        no = nk(n1)
                        m7 = nk(nl)
                        m4 = nk(m9, fn306)
                    end
                    vy_10 = (vy_10 + 101) % 168
                end
            else
                if (not Net and not nl or not Net and not vy_6_1 or (not nl or vy_6_1) and (n3 and n2)) and (n1 and not vy_6_1 and (not nl or not n2) and (n1 and not nl or (not n3 or not n1))) and ((not nl and not Net or (Net or n2)) and (n1 and not n3 and (nl and not nl)) or (not n3 and not n3 and (not Net or not n1) or vy_6_1 and not n2 and (vy_6_1 and not vy_6_1))) and not ((not Net and not nl or not Net and not vy_6_1 or (not nl or vy_6_1) and (n3 and n2)) and (n1 and not vy_6_1 and (not nl or not n2) and (n1 and not nl or (not n3 or not n1))) and ((not nl and not Net or (Net or n2)) and (n1 and not n3 and (nl and not nl)) or (not n3 and not n3 and (not Net or not n1) or vy_6_1 and not n2 and (vy_6_1 and not vy_6_1)))) then
                    mG = {}
                else
                    n5 = {}
                end
                vy_10 = (vy_10 + 38) % 168
            end
        elseif n9 <= 9 then
            if n9 <= 8 then
                if n9 <= 7 then
                    if vy_10 * 53967435 + 11 + 6 >= vy_10 * 53967435 + 11 + 6 + 6 then
                        n5 = game:GetService("Players")
                    else
                        vy_4 = game:GetService("Players")
                    end
                    vy_10 = (vy_10 + 17) % 168
                else
                    if (vy_10 * 3 + 4) * 9 % 4 == ((vy_10 * 3 + 4) * 9 + 12) % 4 then
                        n2 = game:GetService("ReplicatedStorage")
                    else
                        vy_4 = game:GetService("ReplicatedStorage")
                    end
                    vy_10 = (vy_10 + 80) % 168
                end
            else
                local wk = bit32.rrotate(bit32.bxor(bit32.lrotate(vy_10, 19), string.byte(tostring(n7))), 3)
                if bit32.bxor(bit32.lrotate(bit32.bxor(wk, 3053199336), 28), 2338308606) ~= bit32.lrotate(wk, 28) then
                    nJ = game:GetService("UserInputService")
                    n8 = game:GetService("VirtualUser")
                    nN = game:GetService("Workspace")
                else
                    n8 = game:GetService("UserInputService")
                    nN = game:GetService("VirtualUser")
                    nJ = game:GetService("Workspace")
                end
                vy_10 = (vy_10 + 59) % 168
            end
        elseif n9 <= 10 then
            local oa_4 = {
                "mwdfcqsz",
                "njtdyhb",
                "kehmqmove",
                "mbktfgr",
                "gzouss",
                "rgpvtt",
                "mpnnzf",
                "emfng",
                "viorwjmm",
                "svsjt",
                "grdhcsdma",
                "jmoacmkays"
            }
            if oa_4[(vy_10 * 33 + 113) % 12 + 1] < oa_4[(vy_10 * 33 + 113) % 12 + 1] then
                vy_4 = LocalPlayer.LocalPlayer
            else
                LocalPlayer = vy_4.LocalPlayer
            end
            vy_10 = (vy_10 + 80) % 168
        else
            local oa_5 = { "cmup", "mvu", "zemi", "qcvtuhjpuejo", "fiorqif", "zshjpnskog", "jswpw", "vyhwfsofuf" }
            if oa_5[(vy_10 * 54 + 50) % 8 + 1] <= oa_5[(vy_10 * 54 + 50) % 8 + 1] then
                n7 = "My Dealership"
                ny = "https://discord.gg/K7Qxnxkk46"
            else
                ny = "My Dealership"
                n7 = "https://discord.gg/K7Qxnxkk46"
            end
            vy_10 = (vy_10 + 59) % 168
        end
    elseif n9 <= 16 then
        if n9 <= 14 then
            if n9 <= 13 then
                if n9 <= 12 then
                    if (vy_6_1 and not ExpansionConfig and (m4 and not Net) or (not ExpansionConfig or ExpansionConfig) and (not m4 and vy_6_1)) and ((not Net and m4 or (not vy_6_1 or not vy_6_1)) and (not m4 and not m4 or no and not ExpansionConfig)) or not ((vy_6_1 and not ExpansionConfig and (m4 and not Net) or (not ExpansionConfig or ExpansionConfig) and (not m4 and vy_6_1)) and ((not Net and m4 or (not vy_6_1 or not vy_6_1)) and (not m4 and not m4 or no and not ExpansionConfig))) then
                        nv = "https://discord.gg/K7Qxnxkk46"
                    else
                        m7 = "https://discord.gg/K7Qxnxkk46"
                    end
                    vy_10 = (vy_10 + 164) % 168
                else
                    local wL = bit32.rrotate(bit32.bxor(bit32.lrotate(vy_10, 23), string.byte(tostring(no))), 20)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(wL, 2706988550), 0), 2706988550) == bit32.lrotate(wL, 0) then
                        vy_6_1 = n2:WaitForChild("Shared")
                    else
                        n2 = vy_6_1:WaitForChild("Shared")
                    end
                    vy_10 = (vy_10 + 80) % 168
                end
            else
                local oa_6 = (vector.create((vy_10 * 7 + 3) % 11 + 1, (vy_10 * 2 + 11) % 13 + 1, (vy_10 * 7 + 9) % 17 + 1))
                ob = (vector.create((vy_10 * 2 + 3) % 11 + 1, (vy_10 * 5 + 12) % 13 + 1, (vy_10 * 14 + 14) % 17 + 1))
                oc = (vector.create((vy_10 * 6 + 1) % 11 + 1, (vy_10 * 11 + 5) % 13 + 1, (vy_10 * 1 + 17) % 17 + 1))
                if vector.dot(vector.cross(oa_6, ob), oc) == vector.dot(vector.cross(ob, oc), oa_6) then
                    Net = require(vy_6_1:WaitForChild("Net"))
                else
                    vy_6_1 = require(Net:WaitForChild("Net"))
                end
                vy_10 = (vy_10 + 101) % 168
            end
        elseif n9 <= 15 then
            local oa_7 = (vector.create((vy_10 * 1 + 2) % 11 + 1, (vy_10 * 7 + 2) % 13 + 1, (vy_10 * 8 + 16) % 17 + 1))
            ob = (vector.create((vy_10 * 6 + 5) % 11 + 1, (vy_10 * 11 + 9) % 13 + 1, (vy_10 * 8 + 6) % 17 + 1))
            oc = (vector.create((vy_10 * 3 + 4) % 11 + 1, (vy_10 * 9 + 10) % 13 + 1, (vy_10 * 14 + 16) % 17 + 1))
            if vector.dot(vector.cross(oa_7, ob), oc) == vector.dot(vector.cross(ob, oc), oa_7) then
                vy_5 = vy_6_1:WaitForChild("Configs")
            else
                vy_6_1 = vy_5:WaitForChild("Configs")
            end
            vy_10 = (vy_10 + 122) % 168
        else
            local vW = bit32.rrotate(bit32.bxor(bit32.lrotate(vy_10, 5), string.byte(tostring(nJ))), 15)
            if bit32.bxor(bit32.lrotate(bit32.bxor(vW, 2062929790), 30), 2663216095) == bit32.lrotate(vW, 30) then
                no = require(vy_5:WaitForChild("StandConfig"))
            else
                vy_5 = require(no:WaitForChild("StandConfig"))
            end
            vy_10 = (vy_10 + 38) % 168
        end
    elseif n9 <= 19 then
        if n9 <= 18 then
            if n9 <= 17 then
                local oa_8 = (vector.create((vy_10 * 4 + 8) % 11 + 1, (vy_10 * 2 + 5) % 13 + 1, (vy_10 * 9 + 16) % 17 + 1))
                ob = (vector.create((vy_10 * 4 + 4) % 11 + 1, (vy_10 * 10 + 8) % 13 + 1, (vy_10 * 11 + 10) % 17 + 1))
                local wf = vector.cross(oa_8, ob)
                local wg = vector.dot(oa_8, ob)
                if vector.dot(wf, wf) + wg * wg == vector.dot(oa_8, oa_8) * vector.dot(ob, ob) + 1 then
                    vy_5 = require(nk:WaitForChild("ContainerConfig"))
                else
                    nk = require(vy_5:WaitForChild("ContainerConfig"))
                end
                vy_10 = (vy_10 + 164) % 168
            else
                if (mM and RebirthConfig or RebirthConfig and not RebirthConfig) and (not mM or not mM or (not mM or RebirthConfig)) and not ((mM and RebirthConfig or RebirthConfig and not RebirthConfig) and (not mM or not mM or (not mM or RebirthConfig))) then
                    vy_5 = require(m7:WaitForChild("DecorationConfig"))
                else
                    m7 = require(vy_5:WaitForChild("DecorationConfig"))
                end
                vy_10 = (vy_10 + 17) % 168
            end
        else
            local oa_9 = (vector.create((vy_10 * 6 + 7) % 11 + 1, (vy_10 * 3 + 9) % 13 + 1, (vy_10 * 4 + 12) % 17 + 1))
            local wP = vector.floor(oa_9) + vector.ceil(oa_9 * -1)
            if vector.dot(wP, wP) == 0 then
                m3 = require(vy_5:WaitForChild("ManagerConfig"))
            else
                vy_5 = require(m3:WaitForChild("ManagerConfig"))
            end
            vy_10 = (vy_10 + 17) % 168
        end
    elseif n9 <= 20 then
        n9 = {
            "yyebhd",
            "xvchvejfrl",
            "mld",
            "jruk",
            "wqxfv",
            "thlzroydtqp",
            "onvwllahyg",
            "okeghljnbdb",
            "ftx",
            "lbgdhqh",
            "qklszmqktu"
        }
        local wv = vy_10
        local oa_10 = n9[wv % 11 + 1]
        if oa_10:len() <= oa_10:gsub("(.)", "%1%1", wv % 3 % 2 + 1):len() then
            RebirthConfig = require(vy_5:WaitForChild("RebirthConfig"))
        else
            vy_5 = require(RebirthConfig:WaitForChild("RebirthConfig"))
        end
        vy_10 = (vy_10 + 122) % 168
    else
        if (vy_10 * 3 + 5) * 9 % 4 == ((vy_10 * 3 + 5) * 9 + 13) % 4 then
            vy_5 = require(n4:WaitForChild("MutationConfig"))
        else
            n4 = require(vy_5:WaitForChild("MutationConfig"))
        end
        vy_10 = (vy_10 + 17) % 168
    end
until (vy_10 * 143 + 75) % 168 == 76
if type(n3.Order) == "table" then
    for k, v in n3.Order do
        table.insert(n5, v)
    end
else
    vy_4 = 2
    repeat
        vy_11 = {
            "vdazkviajz",
            "tjblrjuuknc",
            "drcmczl",
            "nazfdycrk",
            "zgnmjldisfd",
            "sczdceoikt",
            "zzrcyvgjhd",
            "cdclggbe"
        }
        local vX = vy_4
        vy_10 = vy_11[vX % 8 + 1]
        if vy_10:len() >= vy_10:gsub("(.)", "%1%1", vX % 3 % 2 + 1):len() then
            n5 = { "Epic", "Mythic", "Common", "Legendary", "Rare", "Prototype", "Uncommon" }
        else
            n5 = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Prototype" }
        end
        vy_4 = (vy_4 + 5) % 8
    until (vy_4 * 3 + 2) % 8 == 7
end
vy_11 = {}
if type(n4.Order) == "table" then
    for k, v in n4.Order do
        table.insert(vy_11, v)
    end
else
    vy_4 = 1
    repeat
        if (vy_4 * 2 + 3) * 10 % 3 == ((vy_4 * 2 + 3) * 10 + 6) % 3 then
            vy_11 = { "Main", "Gold", "Emerald", "Ruby", "Diamond", "Celestial" }
        else
            vy_11 = { "Main", "Ruby", "Celestial", "Emerald", "Gold", "Diamond" }
        end
        vy_4 = (vy_4 + 1) % 8
    until (vy_4 * 1 + 6) % 8 == 0
end
Library, Toggles, Options, mK, nn, ni, nB, ns, nm, m_, mE, nH, nq, m0, mT, mF, nD, nx, mY, mX, nI, nu, m6, nT, nz, nQ, nA, mJ, nC, np, mS, mL, m1, ng, mP, nM, m8, mD, nF, nS, ne, nf, m5, nW, nj, mH, nt, mN, nK, mO, nd, m2 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
od = getgenv().ThemeManager
oc = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
nB = fn13
ns = fn121
nm = fn115
m_ = fn609
n4 = "#7fd47f"
local oa_11 = "#6ec1ff"
mK = "#e8a34d"
n9 = "#8b93a3"
mE = fn587
nH = fn284
nq = fn630
m0 = fn34
mT = fn551
mF = fn409
nD = fn607
nx = function()
    local pu_1
    local ps = nD()
    local pt = ps and typeof(ps.cash) == "number"
    local pt_2
    if pt then
        return ps.cash
    end
    local pt_1 = ps and type(ps.GetCash) == "function"
    if pt_1 then
        pt_2, pu_1 = pcall(function()
            return ps:GetCash()
        end)
        local pv = pt_2 and typeof(pu_1) == "number"
        if pv then
            return pu_1
        end
        return 0
    end
    return 0
end
mY = fn309
mX = function(bl, bm)
    local pG
    pG = nil
    local pI_1
    pG = ClientRegistry.TryGet("StockController")
    local pH = not pG or type(pG.CanBuy) ~= "function"
    local pH_1
    if pH then
        return true
    end
    pH_1, pI_1 = pcall(function()
        return pG:CanBuy(bl, bm)
    end)
    return pH_1 and pI_1 == true
end
nI = fn63
nu = function(bA)
    if not bA then
        return false
    elseif fireproximityprompt then
        return pcall(function()
            fireproximityprompt(bA)
        end)
    else
        return pcall(function()
            bA:InputHoldBegin()
            task.wait(math.max(0.05, bA.HoldDuration))
            bA:InputHoldEnd()
        end)
    end
end
nn = {}
ni = false
m6 = function()
    if ni then
        return
    end
    ni = true
    pcall(function()
        Net:OnClient("Crate_OpenFX", function(bJ)
            local pQ
            local pR = type(bJ) == "table" and bJ.crateUid
            pQ = pR
            if pQ == nil then
                return
            end
            task.defer(function()
                pcall(function()
                    Net:FireServer("Crate_OpenDone", pQ, 0)
                end)
            end)
        end)
    end)
end
nT = fn664
nz = fn300
nQ = fn601
nA = fn769
mJ = fn64
nC = fn484
np = function(cN)
    local qX
    qX = nil
    local q__1
    local qZ_1
    local qY_1
    qX = nC(cN)
    if not qX then
        return 16, 16
    end
    qZ_1, qY_1, q__1 = pcall(function()
        return qX:GetBoundingBox()
    end)
    local qY_2 = qZ_1 and typeof(q__1) == "Vector3"
    if qY_2 then
        return q__1.X * 0.5, q__1.Z * 0.5
    end
    return 16, 16
end
mS = fn110
mL = fn259
m1 = function(df, dg, dh)
    local rn
    rn = nil
    local rs_1
    local rr_1, rr_2
    local ro = nA()
    if #ro == 0 then
        return false
    end
    local rp = nC(df)
    if not rp then
        return false
    end
    rn = ClientRegistry.TryGet("HotbarController")
    local rq = rn and type(rn._isFootprintPlaceable) == "function"
    local rq_1
    if not rq then
        rq_1, rr_1 = np(df)
        return mL(dg, dh, rq_1, rr_1, ro)
    end
    local clone = rp:Clone()
    clone.Name = "_OuroPlaceProbe"
    mI.makeGhost(clone, nil)
    clone.Parent = nJ
    mI.placeAt(clone, dg, dh)
    local _ghost = rn._ghost
    local _placing = rn._placing
    rn._ghost = clone
    rn._placing = { kind = "stand", standId = df }
    rr_2, rs_1 = pcall(function()
        return rn:_isFootprintPlaceable()
    end)
    rn._ghost = _ghost
    rn._placing = _placing
    clone:Destroy()
    return rr_2 and rs_1 == true
end
ng = fn771
mP = fn237
nM = fn839
m8 = fn823
mD = fn302
nF = function()
    local sy_1
    local sx_1
    local su = nD()
    local sv = not su or type(su.ownedStands) ~= "table"
    local sv_2
    if sv then
        return
    end
    for i, v in ipairs(nl) do
        local st
        local sG = v
        if mF("PlaceStandItems", sG) then
            local sv_1 = su.ownedStands[sG]
            local sw = typeof(sv_1) == "number" and sv_1 > 0
            local sw_1
            if sw then
                st, sv_2 = nM(sG)
                if not st then
                    return
                end
                sw_1, sx_1, sy_1 = pcall(function()
                    return Net:InvokeServer("Stand_Place", sG, st)
                end)
                if sw_1 and sx_1 then
                    if sv_2 then
                        mC[sv_2] = nil
                    end
                    task.wait(0.2)
                    return
                end
                if sv_2 then
                    mC[sv_2] = true
                end
                local sv_3 = type(sy_1) == "string" and string.find(string.lower(sy_1), "lot", 1, true)
                if sv_3 then
                    return
                end
            end
        end
    end
end
nS = fn817
ne = function()
    local sY_1
    local sT = nS()
    if not sT then
        return
    end
    local sV = m8()
    if #sV == 0 then
        return
    end
    for i, v in ipairs(sV) do
        local s8 = v
        local attr = s8:GetAttribute("StandUid")
        local sV_1 = attr ~= nil and not nz(attr)
        if sV_1 then
            local sV_2 = 0
            local sW = mY()
            local sX = sW and sW:FindFirstChild("_Crates")
            local sX_1
            if sX then
                sV_2 = #sX:GetChildren()
            end
            sX_1, sY_1 = pcall(function()
                return Net:InvokeServer("Crate_Place", sT, s8:GetPivot(), attr)
            end)
            if sX_1 and sY_1 then
                nQ(attr, 1.5)
                task.wait(0.25)
                return
            end
            nQ(attr, 3)
            local sX_2 = sX and #sX:GetChildren()
            if (sX_2 or 0) <= sV_2 then
                task.wait(0.15)
            end
        end
    end
end
nf = function()
    local te_1
    m6()
    local s9 = nI()
    if not s9 then
        return
    end
    local ta = mY()
    local tb = ta and ta:FindFirstChild("_Crates")
    if not tb then
        return
    end
    local tb_1 = nJ:GetServerTimeNow()
    for i, child in tb:GetChildren() do
        local tp = child
        local ta_2 = tp:IsA("Model") and tp:GetAttribute("CrateUid") ~= nil
        if ta_2 then
            local attr2 = tp:GetAttribute("LockedUntil")
            local tc = typeof(attr2) == "number" and tb_1 < attr2
            local OpenPrompt = tp:FindFirstChild("OpenPrompt", true)
            local td = not tc
            local td_1
            if td ~= false then
                td = OpenPrompt
            end
            if td then
                td = OpenPrompt:IsA("ProximityPrompt")
            end
            if td then
                td = OpenPrompt.Enabled
            end
            if td then
                local attr = tp:GetAttribute("StandUid")
                td_1, te_1 = pcall(function()
                    return tp:GetPivot()
                end)
                if td_1 and te_1 then
                    s9.CFrame = te_1 + Vector3.new(0, 5, 0)
                    task.wait(0.15)
                end
                nu(OpenPrompt)
                local tc_2 = os.clock() + 5
                while true do
                    if not (os.clock() < tc_2) then
                        nQ(attr, 1.5)
                        return
                    end
                    if Library.Unloaded then
                        break
                    end
                    if not tp.Parent then
                        nQ(attr, 1.5)
                        return
                    end
                    task.wait(0.1)
                end
                return
            end
        end
    end
end
m5 = fn819
nW = function()
    local tA = mY()
    local tA_2
    local tB = tA and tA:FindFirstChild("_Placed")
    if not tB then
        return
    end
    for i, child in tB:GetChildren() do
        local tz
        tA_2, tz = m5(child)
        if tA_2 then
            pcall(function()
                Net:FireServer("Auction_Start", tz)
            end)
            task.wait(0.35)
            return
        end
    end
end
nj = fn277
mH = fn485
nt = fn364
mN = function()
    local ud
    ud = nt()
    if not ud then
        return
    end
    if nx() < ud.cost then
        return
    end
    pcall(function()
        Net:InvokeServer("Expansion_BuyZone", ud.id)
    end)
end
nK = function()
    local ui_1
    local uf = nx()
    for i, v in ipairs(nl) do
        local uq = v
        if mF("BuyStandItems", uq) then
            local ug = no.get(uq)
            local ug_2
            local uh = mD(ug)
            local ug_1 = uh and uf >= uh and mX("stand", uq)
            if ug_1 then
                ug_2, ui_1 = pcall(function()
                    return Net:InvokeServer("Stand_Buy", uq)
                end)
                if ug_2 and ui_1 then
                    task.wait(0.15)
                    return
                end
            end
        end
    end
end
mO = function()
    local ur = nx()
    for i, v in ipairs(m9) do
        local uA = v
        if mF("BuyContainerItems", uA) then
            local us = nk.get(uA)
            local ut = mD(us)
            local us_1 = ut and ur >= ut and mX("container", uA)
            if us_1 then
                local us_2 = pcall(function()
                    Net:FireServer("Container_Buy", uA)
                end)
                if us_2 then
                    task.wait(0.15)
                    return
                end
            end
        end
    end
end
nd = function()
    local uB = nD()
    local uC = nx()
    for i, v in ipairs(m4) do
        local uO = v
        if mF("BuyDecorItems", uO) then
            local uD = m7.get(uO)
            local uD_3
            local uE = mD(uD)
            local uF = uB and uB.ownedDecor and uB.ownedDecor[uO]
            local uF_4
            local uG = uF or 0
            local uF_1 = uD
            if uF_1 then
                uF_1 = uD.maxOwned
            end
            local uD_1 = uF_1
            local uF_2 = uD_1 == nil
            if not uF_2 then
                local uG_1 = typeof(uG) == "number" and uG < uD_1
                uF_2 = uG_1
            end
            local uD_2 = uE
            local uG_2 = uF_2
            if uD_2 then
                uD_2 = uC >= uE
            end
            if uD_2 and uG_2 then
                uD_3, uF_4 = pcall(function()
                    return Net:InvokeServer("Decoration_Buy", uO)
                end)
                if uD_3 and uF_4 then
                    task.wait(0.15)
                    return
                end
            end
        end
    end
end
m2 = function()
    local uS
    uS = m0("HireManagerItem")
    local uT = nD()
    if not uS or uS == "" then
        return
    end
    if uT and uT.manager == uS then
        return
    end
    local uT_1 = m3.get(uS)
    local uU_2 = mD(uT_1)
    local uT_2 = uU_2 and nx() < uU_2
    if uT_2 then
        return
    end
    pcall(function()
        Net:InvokeServer("Manager_Hire", uS)
    end)
end
n2 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = ny, Copyable = true }, "|", n7 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
ob = {
    Info = n2:AddTab("Info", "info"),
    Main = n2:AddTab("Main", "car"),
    Settings = n2:AddTab("Settings", "settings")
}
ob.Farm = ob.Main:AddSubTab("Farm", "bot")
ob.Shop = ob.Main:AddSubTab("Shop", "shopping-cart")
n3 = fn282
for k, v in ob do
    if v ~= ob.Main then
        n3(v)
    end
end
nh, vy_4, vy_6_2, mU, mQ, vy_5 = nil, nil, nil, nil, nil, nil
vy_10 = 8
repeat
    n1 = (vy_10 * 1 + 1) % 3 + 1
    if n1 <= 2 then
        if n1 <= 1 then
            n1 = {
                "glpwvt",
                "ebpv",
                "ssutrqsrcgck",
                "etbdwe",
                "ckrqzmjdawyz",
                "xrx",
                "kbeqllpzf",
                "xapiqmubfd",
                "izvd",
                "kri"
            }
            if n1[(vy_10 * 31 + 55) % 10 + 1] <= n1[(vy_10 * 31 + 55) % 10 + 1] then
                nh = "Unknown"
                pcall(fn65)
                vy_4 = ob.Info:AddLeftGroupbox("Account", "circle-user")
                vy_4:AddLabel(m_("User", LocalPlayer.Name, n4), true)
                vy_4:AddLabel(m_("Status", "Keyless", n4), true)
                vy_4:AddLabel(m_("Executor", nh, n4), true)
                vy_6_2 = ob.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                vy_6_2:AddLabel(nm(n7 .. " [" .. tostring(game.PlaceId) .. "]", oa_11), true)
                vy_6_2:AddLabel(m_("Place ID", tostring(game.PlaceId), oa_11), true)
                mU = vy_6_2:AddLabel(m_("Session time", "0s", mK), true)
            else
                vy_6_2 = "Unknown"
                pcall(fn65)
                ob = (nil):AddLeftGroupbox("Account", "circle-user")
                ob:AddLabel(nh("User", vy_4.Name, LocalPlayer), true)
                ob:AddLabel(nh("Status", "Keyless", LocalPlayer), true)
                ob:AddLabel(nh("Executor", "Unknown", LocalPlayer), true)
                mU = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
                mU:AddLabel(n7(nm .. " [" .. tostring(game.PlaceId) .. "]", n4), true)
                mU:AddLabel(nh("Place ID", tostring(game.PlaceId), n4), true)
                m_ = mU:AddLabel(nh("Session time", "0s", oa_11), true)
            end
            vy_10 = (vy_10 + 22) % 24
        else
            n1 = (vector.create((vy_10 * 7 + 2) % 11 + 1, (vy_10 * 4 + 4) % 13 + 1, (vy_10 * 9 + 8) % 17 + 1))
            n2 = (vector.create((vy_10 * 1 + 8) % 11 + 1, (vy_10 * 10 + 8) % 13 + 1, (vy_10 * 4 + 10) % 17 + 1))
            n3 = (vector.create((vy_10 * 5 + 3) % 11 + 1, (vy_10 * 11 + 13) % 13 + 1, (vy_10 * 8 + 5) % 17 + 1))
            oe = (vector.create((vy_10 * 5 + 1) % 5 + 1, (vy_10 * 2 + 3) % 7 + 1, (vy_10 * 3 + 6) % 9 + 1))
            if vector.dot(vector.cross(n1, (vector.cross(n2, n3))), oe) == vector.dot(n2 * vector.dot(n1, n3) - n3 * vector.dot(n1, n2), oe) then
                mQ = tostring(game.JobId)
            else
                vy_6_2 = tostring(game.JobId)
            end
            vy_10 = (vy_10 + 1) % 24
        end
    else
        if (vy_10 * 2 + 1) * 16 % 3 == ((vy_10 * 2 + 1) * 16 + 5) % 3 then
            mQ = #vy_5 > 18
        else
            vy_5 = #mQ > 18
        end
        vy_10 = (vy_10 + 10) % 24
    end
until (vy_10 * 19 + 7) % 24 == 18
if vy_5 then
    vy_4 = 3
    repeat
        vy_10 = (vector.create((vy_4 * 5 + 2) % 11 + 1, (vy_4 * 2 + 3) % 13 + 1, (vy_4 * 11 + 14) % 17 + 1))
        n1 = (vector.create((vy_4 * 1 + 5) % 11 + 1, (vy_4 * 4 + 3) % 13 + 1, (vy_4 * 1 + 6) % 17 + 1))
        n2 = (vector.create((vy_4 * 3 + 5) % 11 + 1, (vy_4 * 5 + 5) % 13 + 1, (vy_4 * 8 + 2) % 17 + 1))
        n3 = (vector.create((vy_4 * 5 + 4) % 11 + 1, (vy_4 * 1 + 1) % 13 + 1, (vy_4 * 5 + 3) % 17 + 1))
        if vector.dot(vector.cross(vy_10, n1), (vector.cross(n2, n3))) == vector.dot(vy_10, n2) * vector.dot(n1, n3) - vector.dot(vy_10, n3) * vector.dot(n1, n2) + 3 then
            mQ = string.sub(vy_5, 1, 18) .. "..."
        else
            vy_5 = string.sub(mQ, 1, 18) .. "..."
        end
        vy_4 = (vy_4 + 1) % 4
    until (vy_4 * 1 + 3) % 4 == 3
end
vy_4 = vy_5 or mQ
nP, nR, nO, connection, connection2, nw = nil, nil, nil, nil, nil, nil
n1 = vy_4
vy_6_2:AddLabel(m_("Server", n1, n9), true)
vy_6_2:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
nP = os.clock()
task.spawn(worker)
local ScriptsGroup = ob.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(nm("Included in this hub", n9), true)
ScriptsGroup:AddLabel(nm(n7, oa_11), true)
local FeaturesGroup = ob.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(nm("Auto Farm", oa_11), true)
FeaturesGroup:AddLabel(nm("Auto Shop", mK), true)
FeaturesGroup:AddLabel(nm("Plot Expansion", n9), true)
local SocialsGroup = ob.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = ns })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = ob.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = ns })
local FaqGroup = ob.Info:AddRightGroupbox("FAQ", "circle-help")
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
local PlacementGroup = ob.Farm:AddLeftGroupbox("Placement", "hammer")
PlacementGroup:AddToggle("AutoPlaceStands", { Text = "Auto Place Stands", Default = false })
PlacementGroup:AddDropdown("PlaceStandItems", { Text = "Stands", Values = nl, Multi = true, AllowNull = true, Default = {} })
PlacementGroup:AddSlider("StandSpacing", { Text = "Stand spacing", Default = 16, Min = 12, Max = 32, Rounding = 0 })
PlacementGroup:AddToggle("AutoPlaceContainers", { Text = "Auto Place Containers", Default = false })
PlacementGroup:AddDropdown("PlaceContainerItems", { Text = "Containers", Values = m9, Multi = true, AllowNull = true, Default = {} })
PlacementGroup:AddToggle("AutoOpenContainers", { Text = "Auto Open Containers", Default = false })
local AuctionGroup = ob.Farm:AddRightGroupbox("Auction", "gavel")
AuctionGroup:AddToggle("AutoAuction", { Text = "Auto Auction Cars", Default = false })
AuctionGroup:AddDropdown("AuctionRarities", { Text = "Rarities", Values = n5, Multi = true, AllowNull = true, Default = {} })
AuctionGroup:AddDropdown("AuctionMutations", { Text = "Mutations", Values = vy_11, Multi = true, AllowNull = true, Default = {} })
AuctionGroup:AddSlider("AuctionMinValue", { Text = "Min value", Default = 0, Min = 0, Max = 1000000000, Rounding = 0 })
local RebirthGroup = ob.Farm:AddRightGroupbox("Rebirth", "refresh-cw")
RebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
oe = ob.Farm:AddRightGroupbox("Collect", "banknote")
oe:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
oe:AddSlider("CollectMinAmount", { Text = "Min amount", Default = 1, Min = 1, Max = 1000000000, Rounding = 0 })
n4 = ob.Farm:AddLeftGroupbox("Timing", "timer")
n4:AddSlider("FarmDelay", { Text = "Farm delay", Default = 0.4, Min = 0.1, Max = 3, Rounding = 2, Suffix = "s" })
n3 = ob.Shop:AddLeftGroupbox("Buy", "shopping-bag")
n3:AddToggle("AutoBuyStands", { Text = "Auto Buy Stands", Default = false })
n3:AddDropdown("BuyStandItems", { Text = "Stands", Values = nl, Multi = true, AllowNull = true, Default = {} })
n3:AddToggle("AutoBuyContainers", { Text = "Auto Buy Containers", Default = false })
n3:AddDropdown("BuyContainerItems", { Text = "Containers", Values = m9, Multi = true, AllowNull = true, Default = {} })
n3:AddToggle("AutoBuyDecor", { Text = "Auto Buy Decor", Default = false })
n3:AddDropdown("BuyDecorItems", { Text = "Decor", Values = m4, Multi = true, AllowNull = true, Default = {} })
n3:AddToggle("AutoBuyPlotSlot", { Text = "Auto Buy Plot Slot", Default = false })
n2 = ob.Shop:AddRightGroupbox("Employees", "users")
n2:AddToggle("AutoHireEmployees", { Text = "Auto Hire Employees", Default = false })
n2:AddDropdown("HireManagerItem", { Text = "Employee", Values = n6, Default = n6[1] })
vy_5 = ob.Shop:AddRightGroupbox("Timing", "timer")
vy_5:AddSlider("ShopDelay", { Text = "Shop delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 2, Suffix = "s" })
vy_10 = ob.Settings:AddLeftGroupbox("Menu", "settings")
vy_10:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
vy_10:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
vy_10:AddButton("Unload", onUnload)
Library:OnUnload(fn10)
od:SetLibrary(Library)
od:SetFolder("TempoHub")
od:SaveDefault("Monochrome")
od:ApplyToTab(ob.Settings)
od:LoadDefault()
oc:SetLibrary(Library)
oc:IgnoreThemeSettings()
oc:SetIgnoreIndexes({ "MenuKeybind" })
oc:SetFolder("TempoHub/MyDealership")
oc:BuildConfigSection(ob.Settings)
oc:LoadAutoloadConfig()
nR = tick()
nO = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local vg = v
        pcall(function()
            vg:Disable()
        end)
    end
end)
nw = fn746
connection = n8.InputBegan:Connect(onInputBegan)
connection2 = n8.InputChanged:Connect(onInputChanged)
do
    Library:OnUnload(fn216)
    task.spawn(worker4)
    task.spawn(worker3)
    task.spawn(worker2)
    Library:Notify("My Dealership loaded")
end
end)(...)

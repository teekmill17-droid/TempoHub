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
getgenv().TempoHoodSubtitle = "+1 BANANA MONKEY DESTRUCTION"
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
local gY
local gF
local g0
local gm
local g3
local UpgradesConfig
local g6
local gI
local ProgressionConfig
local LocalPlayer
local Toggles
local Upgrade_Buy
local onDescendantAdded
local gU
local gB
local gX
local gE
local g_
local gH
local g2
local gK
local go
local g5
local gN
local gr
local gQ
local Label
local gT
local connection
local gA
local Progression_Rebirth
local gD
local gG
local Lighting
local gn
local gJ
local gq
local gM
local DestructionConfig
local gt
local gP
local gw
local VirtualUser
local gz
local Destruction_Punch
local function fn24(bw)
    table.clear(g6)
    table.clear(g3)
    for i, child in bw:GetChildren() do
        gB(child)
    end
    gY = 0
end
local function autoRebirthLoop()
    while true do
        task.wait(2)
        if gF.Unloaded then
            break
        end
        if Toggles.AutoRebirth.Value then
            local Data = gM.Data
            if not ProgressionConfig.IsMaxRebirths(Data.Rebirths) then
                local j8 = ProgressionConfig.GetRebirthLevelRequired(Data.Rebirths)
                local j9 = ProgressionConfig.GetLevelInfo(Data.Bananas, ProgressionConfig.GetMaxLevel(Data.Rebirths))
                if j9 >= j8 then
                    Progression_Rebirth:FireServer()
                end
            end
        end
    end
end
local function fn43(bf)
    local il = bf ~= nil and bf:IsA("BasePart") and bf.CanQuery
    return il
end
local function autoPunchAuraLoop()
    while true do
        local jA = math.max(DestructionConfig.PunchCooldown, gr.PunchAuraDelay.Value)
        local wait = task.wait
        local jA_1 = Toggles.AutoPunchAura.Value and jA or 0.25
        wait(jA_1)
        if gF.Unloaded then
            break
        end
        if Toggles.AutoPunchAura.Value then
            local Character = LocalPlayer.Character
            local jB_1 = Character and Character:FindFirstChild("HumanoidRootPart")
            local jC_1 = Character
            if jC_1 then
                jC_1 = Character:FindFirstChildOfClass("Humanoid")
            end
            local jA_3 = jB_1
            local jB_2 = jC_1
            if jA_3 then
                jA_3 = jB_2
            end
            if jA_3 then
                jA_3 = jB_2.Health > 0
            end
            if jA_3 then
                jA_3 = ProgressionConfig.IsInMap(jB_1)
            end
            if jA_3 then
                Destruction_Punch:FireServer(DestructionConfig.PunchType.Ground, jB_1.Position)
            end
        end
    end
end
local function onRscripts()
    if setclipboard then
        setclipboard(gE)
    elseif toclipboard then
        toclipboard(gE)
    end
    gF:Notify("Copied Rscripts profile to clipboard")
end
local function fn121()
    if setclipboard then
        setclipboard(gH)
    elseif toclipboard then
        toclipboard(gH)
    end
    gF:Notify("Copied Discord invite to clipboard")
end
local function fn130(bM)
    local iJ = #g6
    while iJ > 0 do
        gY = gY % #g6 + 1
        local iK = g6[gY]
        local iL = iK and iK:IsDescendantOf(bM) and gK(iK)
        if iL then
            return iK
        end
        g0(iK)
        iJ -= 1
    end
    return nil
end
local function fn139(bo)
    local iq = g3[bo]
    if not iq then
        return
    end
    local ir = #g6
    local is = g6[ir]
    g6[iq] = is
    g6[ir] = nil
    g3[bo] = nil
    if is and is ~= bo then
        g3[is] = iq
    end
    if gY > #g6 then
        gY = 0
    end
end
local function fn141()
    local hT_1
    local hS_1
    if identifyexecutor then
        hT_1, hS_1 = identifyexecutor()
        local hU = hT_1 ~= ""
        local hV = type(hT_1) == "string" and hU
        if hV then
            local hU_1 = type(hS_1) == "string" and hS_1 ~= "" and hT_1 .. " " .. hS_1
            gU = hU_1 or hT_1
        end
    end
end
local function fn148(J, K, L)
    return string.format("<b>%s</b> %s %s", J, gJ("-", "#5a6070"), gJ(K, L))
end
local function fn159(bE)
    if gT then
        gT:Disconnect()
        gT = nil
    end
    if gQ then
        gQ:Disconnect()
        gQ = nil
    end
    gn = bE
    gw(bE)
    gT = bE.ChildAdded:Connect(gB)
    gQ = bE.ChildRemoved:Connect(g0)
end
local function antiAfkLoop()
    while true do
        task.wait(2)
        if gF.Unloaded then
            break
        end
        if Toggles.AntiAfk.Value then
            local jt = tick() - gm
            local ju = tick() - g5
            if jt >= 300 and ju >= 60 then
                pcall(gI)
            else
                if jt < 300 and ju >= 300 then
                    pcall(gI)
                end
            end
        end
    end
end
local function onUnload()
    gF:Unload()
end
local function fn215()
    gt:Disconnect()
    connection:Disconnect()
    select("#", "+1 Banana Monkey Destruction unloaded")
end
local function fn221(G, H)
    return string.format('<font color="%s">%s</font>', H, G)
end
local function onInputBegan()
    gm = tick()
end
local function worker()
    local h2_1
    while true do
        task.wait(1)
        if gF.Unloaded then
            break
        end
        local h1 = math.floor(os.clock() - gP)
        if h1 < 60 then
            h2_1 = h1 .. "s"
        elseif h1 < 3600 then
            h2_1 = string.format("%dm %ds", math.floor((h1) / (60)), h1 % 60)
        else
            h2_1 = string.format("%dh %dm", math.floor((h1) / (3600)), math.floor((h1 % 3600) / (60)))
        end
        Label:SetText(gA("Session time", h2_1, gX))
    end
end
local function fn345()
    local Character = LocalPlayer.Character
    local ij = Character and Character:FindFirstChild("HumanoidRootPart")
    return ij
end
local function autoBuyUpgradesLoop()
    while true do
        task.wait(1)
        if gF.Unloaded then
            break
        end
        if Toggles.AutoBuyUpgrades.Value then
            local Data = gM.Data
            local jU = g2[gr.UpgradePriority.Value]
            local jV = false
            if jU then
                local jW = Data.Upgrades[jU]
                local jX = Data.Rebirths >= UpgradesConfig[jU].RebirthsRequired and jW < UpgradesConfig.GetLevelCap(jU)
                if jX then
                    local jX_1 = UpgradesConfig.GetCost(jU, jW)
                    jV = jX_1 ~= math.huge
                    if jV and Data.Cash >= jX_1 then
                        Upgrade_Buy:FireServer(jU)
                    end
                end
            end
            if not jV then
                for k, v in UpgradesConfig.Order do
                    local jU_1 = Data.Upgrades[v]
                    local jV_1 = Data.Rebirths >= UpgradesConfig[v].RebirthsRequired and jU_1 < UpgradesConfig.GetLevelCap(v)
                    if jV_1 then
                        local jV_2 = UpgradesConfig.GetCost(v, jU_1)
                        if jV_2 ~= math.huge and Data.Cash >= jV_2 then
                            Upgrade_Buy:FireServer(v)
                        end
                    end
                end
            end
        end
    end
end
local function fn500()
    g_()
    if gT then
        gT:Disconnect()
    end
    if gQ then
        gQ:Disconnect()
    end
end
local function fn542(X)
    local DiscordGroup = X:AddLeftGroupbox("Discord", nil, true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = gN })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = gN })
end
local function onInputChanged(aW)
    local UserInputType = aW.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        gm = tick()
    end
end
local function fn565()
    go(Toggles.FpsBoost.Value)
end
local function fn566(cy)
    g_()
    if not cy then
        return
    end
    local Rendering = settings().Rendering
    gz(Rendering, "QualityLevel", Enum.QualityLevel.Level01)
    gz(Lighting, "GlobalShadows", false)
    gz(Lighting, "EnvironmentDiffuseScale", 0)
    gz(Lighting, "EnvironmentSpecularScale", 0)
    local Terrain = workspace.Terrain
    gz(Terrain, "Decoration", false)
    gz(Terrain, "WaterWaveSize", 0)
    gz(Terrain, "WaterWaveSpeed", 0)
    gz(Terrain, "WaterReflectance", 0)
    for i, descendant in workspace:GetDescendants() do
        onDescendantAdded(descendant)
    end
    for i, descendant in Lighting:GetDescendants() do
        onDescendantAdded(descendant)
    end
    gG = game.DescendantAdded:Connect(onDescendantAdded)
end
local function fn569(bi)
    local io = g3[bi] or not gK(bi)
    if io then
        return
    end
    table.insert(g6, bi)
    g3[bi] = #g6
end
local function fn572(bV, bW, bX)
    local iN = bX.Size * 0.5
    local CFrame2 = bX.CFrame
    local iP = math.abs(CFrame2.RightVector.Y) * iN.X + math.abs(CFrame2.UpVector.Y) * iN.Y + math.abs(CFrame2.LookVector.Y) * iN.Z
    local iN_1 = bW.HipHeight + bV.Size.Y * 0.5 + 0.5
    local iO_1 = Vector3.new(bX.Position.X, bX.Position.Y + iP + iN_1, bX.Position.Z)
    local iN_2 = Vector3.new(bV.CFrame.LookVector.X, 0, bV.CFrame.LookVector.Z)
    if iN_2.Magnitude < 0.001 then
        return CFrame.new(iO_1)
    end
    return CFrame.lookAt(iO_1, iO_1 + iN_2.Unit)
end
local function fn575()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    g5 = tick()
end
local function fn595(cj)
    if cj:IsA("BasePart") then
        gz(cj, "CastShadow", false)
        gz(cj, "Reflectance", 0)
    else
        local iY = (cj:IsA("Decal"))
        local i1 = if iY then 1 else 0
        local i_ = 1009 * i1 + 2167 * (1 - i1)
        local i0 = 2339 * i1 + 2111 * (1 - i1)
        if not ((i_ * 1270 + i0 * 1513 + i_ * i0) % 16777213 == 7180388) then
            iY = cj:IsA("Texture")
        end
        if iY then
            gz(cj, "Transparency", 1)
        else
            local iY_1 = (cj:IsA("ParticleEmitter"))
            local i1_1 = if iY_1 then 1 else 0
            local i__1 = 386 * i1_1 + 1338 * (1 - i1_1)
            local i0_1 = 423 * i1_1 + 606 * (1 - i1_1)
            if not ((i__1 * 3436 + i0_1 * 2900 + i__1 * i0_1) % 16777213 == 2716274) then
                iY_1 = cj:IsA("Trail")
            end
            if not iY_1 then
                iY_1 = cj:IsA("Beam")
            end
            if not iY_1 then
                iY_1 = cj:IsA("Smoke")
            end
            if not iY_1 then
                iY_1 = cj:IsA("Fire")
            end
            if not iY_1 then
                iY_1 = cj:IsA("Sparkles")
            end
            if not iY_1 then
                iY_1 = cj:IsA("PostEffect")
            end
            if iY_1 then
                gz(cj, "Enabled", false)
            elseif cj:IsA("Atmosphere") then
                gz(cj, "Density", 0)
            end
        end
    end
end
local function autoGoMapLoop()
    while true do
        task.wait(1)
        if gF.Unloaded then
            break
        end
        if Toggles.AutoGoMap.Value then
            local jx = gD()
            local jy = jx and not ProgressionConfig.IsInMap(jx)
            if jy then
                jx.CFrame = CFrame.new(0, 10, 0)
            end
        end
    end
end
local function onCopyJoinScript_JobID()
    local h_ = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, gq)
    if setclipboard then
        setclipboard(h_)
    elseif toclipboard then
        toclipboard(h_)
    end
    gF:Notify("Copied join script to clipboard")
end
gm = nil
gn = nil
go = nil
UpgradesConfig = nil
gq = nil
gr = nil
ProgressionConfig = nil
gt = nil
Label = nil
Toggles = nil
gw = nil
onDescendantAdded = nil
gz = nil
gA = nil
gB = nil
gD = nil
gE = nil
gF = nil
gG = nil
gH = nil
gI = nil
gJ = nil
gK = nil
gM = nil
gN = nil
LocalPlayer = nil
gP = nil
gQ = nil
Upgrade_Buy = nil
VirtualUser = nil
gT = nil
gU = nil
Destruction_Punch = nil
connection = nil
gX = nil
gY = nil
Progression_Rebirth = nil
g_ = nil
g0 = nil
Lighting = nil
g2 = nil
g3 = nil
g5 = nil
g6 = nil
DestructionConfig = nil
local gx, gC, gL, g4
local ScriptsGroup
local FeaturesGroup
local SocialsGroup
local TempoHubGroup
local FaqGroup
local AutoGoMapGroup
local AutoPunchAuraGroup
local hm_1
local hb_1, hb_6
local Modules, MenuGroup
Lighting, VirtualUser, LocalPlayer, gH, gE, Modules, ProgressionConfig, UpgradesConfig, DestructionConfig, Progression_Rebirth, Destruction_Punch, Upgrade_Buy, gM, hb_1, gF, Toggles, gr, g2 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local he = game:GetService("ReplicatedStorage")
Lighting = game:GetService("Lighting")
local hj = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
LocalPlayer = Players.LocalPlayer
local hi = "+1 Banana Monkey Destruction"
gH = "https://discord.gg/K7Qxnxkk46"
gE = "https://discord.gg/K7Qxnxkk46"
local Events = he:WaitForChild("Shared"):WaitForChild("Events")
local ha_1
if (gr or hb_1 or hb_1 and gr) and (not UpgradesConfig or not UpgradesConfig or not hb_1 and gr) and (UpgradesConfig and hb_1 and (hb_1 or UpgradesConfig) or (Toggles or not gr or (not hb_1 or not gr))) or not ((gr or hb_1 or hb_1 and gr) and (not UpgradesConfig or not UpgradesConfig or not hb_1 and gr) and (UpgradesConfig and hb_1 and (hb_1 or UpgradesConfig) or (Toggles or not gr or (not hb_1 or not gr)))) then
    Modules = he.Shared.Modules
else
    he = Modules.Shared.Modules
end
ProgressionConfig = require(Modules.Config.ProgressionConfig)
UpgradesConfig = require(Modules.Config.UpgradesConfig)
DestructionConfig = require(Modules.Config.DestructionConfig)
local DataController = require(he.Client.Modules.Main.DataController)
Progression_Rebirth = Events:WaitForChild("Progression_Rebirth")
Destruction_Punch = Events:WaitForChild("Destruction_Punch")
Upgrade_Buy = Events:WaitForChild("Upgrade_Buy")
gM = DataController.GetReplica()
gF = getgenv().Library
local hh = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = gF.Toggles
gr = gF.Options
local hf = "Game Order"
local hk = { "Game Order" }
g2 = {}
for k, v in UpgradesConfig.Order do
    local g8_1 = v:gsub("(%l)(%u)", "%1 %2")
    table.insert(hk, g8_1)
    g2[g8_1] = v
end
gX, gJ, gA, gN = nil, nil, nil, nil
gJ = fn221
gA = fn148
local hc = "#7fd47f"
local AutoBuyUpgradesGroup
local hl = "#6ec1ff"
gX = "#e8a34d"
local he_1 = "#8b93a3"
gN = fn121
local Window = gF:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = gH, Copyable = true }, "|", hi },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local hd_1 = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "target"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in hd_1 do
    fn542(v)
end
gU, hm_1, Label, gq, ha_1 = nil, nil, nil, nil, nil
local g8_2 = 11
repeat
    local hb_3 = (g8_2 * 2 + 0) % 3 + 1
    if hb_3 <= 2 then
        if hb_3 <= 1 then
            if g8_2 * 75296743 + 8 + 2 >= g8_2 * 75296743 + 8 + 2 + 6 then
                gq = #ha_1 > 18
            else
                ha_1 = #gq > 18
            end
            g8_2 = (g8_2 + 11) % 24
        else
            if (g8_2 * 3 + 3) * 17 % 4 == ((g8_2 * 3 + 3) * 17 + 4) % 4 then
                gU = "Unknown"
                pcall(fn141)
                local AccountGroup = hd_1.Info:AddLeftGroupbox("Account", "circle-user")
                AccountGroup:AddLabel(gA("User", LocalPlayer.Name, hc), true)
                AccountGroup:AddLabel(gA("Status", "Keyless", hc), true)
                AccountGroup:AddLabel(gA("Executor", gU, hc), true)
                hm_1 = hd_1.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                hm_1:AddLabel(gJ(hi .. " [" .. tostring(game.PlaceId) .. "]", hl), true)
                hm_1:AddLabel(gA("Place ID", tostring(game.PlaceId), hl), true)
                Label = hm_1:AddLabel(gA("Session time", "0s", gX), true)
            else
                pcall(fn141)
                hd_1 = (nil):AddLeftGroupbox("Account", "circle-user")
                hd_1:AddLabel(LocalPlayer("User", gA.Name, gJ), true)
                hd_1:AddLabel(LocalPlayer("Status", "Keyless", gJ), true)
                hd_1:AddLabel(LocalPlayer("Executor", "Unknown", gJ), true)
                gX = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
                gX:AddLabel(hl(gU .. " [" .. tostring(game.PlaceId) .. "]", Label), true)
                gX:AddLabel(LocalPlayer("Place ID", tostring(game.PlaceId), Label), true)
                hm_1 = gX:AddLabel(LocalPlayer("Session time", "0s", hc), true)
            end
            g8_2 = (g8_2 + 8) % 24
        end
    else
        local hb_4 = { "zxkbjyv", "huprtztyfvz", "qdfpgnqwbal", "inijzfofb", "tdt", "seajx", "mumhx" }
        local kB = g8_2
        local hn_1 = hb_4[kB % 7 + 1]
        if hn_1:len() <= hn_1:gsub("(.)", "%1%1", kB % 3 % 2 + 1):len() then
            gq = tostring(game.JobId)
        else
            hm_1 = tostring(game.JobId)
        end
        g8_2 = (g8_2 + 23) % 24
    end
until (g8_2 * 7 + 19) % 24 == 6
if ha_1 then
    local g8_3 = 2
    repeat
        local g9_4 = (vector.create((g8_3 * 1 + 3) % 11 + 1, (g8_3 * 2 + 13) % 13 + 1, (g8_3 * 10 + 12) % 17 + 1))
        local hb_5 = (vector.create((g8_3 * 3 + 3) % 11 + 1, (g8_3 * 1 + 13) % 13 + 1, (g8_3 * 6 + 1) % 17 + 1))
        local hc_1 = (vector.create((g8_3 * 2 + 3) % 11 + 1, (g8_3 * 3 + 7) % 13 + 1, (g8_3 * 2 + 12) % 17 + 1))
        local hn_2 = (vector.create((g8_3 * 3 + 2) % 5 + 1, (g8_3 * 4 + 3) % 7 + 1, (g8_3 * 4 + 3) % 9 + 1))
        if vector.dot(vector.cross(g9_4, (vector.cross(hb_5, hc_1))), hn_2) == vector.dot(hb_5 * vector.dot(g9_4, hc_1) - hc_1 * vector.dot(g9_4, hb_5), hn_2) then
            ha_1 = string.sub(gq, 1, 18) .. "..."
        else
            gq = string.sub(ha_1, 1, 18) .. "..."
        end
        g8_3 = (g8_3 + 5) % 8
    until (g8_3 * 7 + 3) % 8 == 4
end
local g8_4 = ha_1 or gq
gP, ScriptsGroup, FeaturesGroup, SocialsGroup, TempoHubGroup, FaqGroup, AutoGoMapGroup, AutoPunchAuraGroup, AutoBuyUpgradesGroup, hb_6, MenuGroup, gm, g5, gt, connection, gn, g6, g3, gY, gT, gQ, gG, gC, gI, gD, gK, gB, g0, gw, gL, g4, gx, gz, onDescendantAdded, g_, go = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local ha_2 = 134
repeat
    local hw = (ha_2 * 3 + 11) % 20 + 1
    if hw <= 10 then
        if hw <= 5 then
            if hw <= 3 then
                if hw <= 2 then
                    if hw <= 1 then
                        local hx_1 = (vector.create((ha_2 * 5 + 4) % 11 + 1, (ha_2 * 6 + 13) % 13 + 1, (ha_2 * 4 + 13) % 17 + 1))
                        local hy_1 = (vector.create((ha_2 * 1 + 4) % 11 + 1, (ha_2 * 8 + 7) % 13 + 1, (ha_2 * 14 + 1) % 17 + 1))
                        local hz_1 = (vector.create((ha_2 * 4 + 4) % 11 + 1, (ha_2 * 9 + 3) % 13 + 1, (ha_2 * 2 + 1) % 17 + 1))
                        if vector.dot(vector.cross(hx_1, hy_1), hz_1) == vector.dot(vector.cross(hy_1, hz_1), hx_1) + 4 then
                            AutoPunchAuraGroup:AddToggle("AutoGoMap", { Text = "Auto Go Map", Default = false })
                            hd_1 = AutoGoMapGroup.Main:AddLeftGroupbox("Auto Punch Aura", "hand")
                        else
                            AutoGoMapGroup:AddToggle("AutoGoMap", { Text = "Auto Go Map", Default = false })
                            AutoPunchAuraGroup = hd_1.Main:AddLeftGroupbox("Auto Punch Aura", "hand")
                        end
                        ha_2 = (ha_2 + 47) % 160
                    else
                        local hx_2 = (vector.create((ha_2 * 6 + 6) % 11 + 1, (ha_2 * 8 + 4) % 13 + 1, (ha_2 * 13 + 10) % 17 + 1))
                        local hy_2 = (vector.create((ha_2 * 6 + 8) % 11 + 1, (ha_2 * 7 + 13) % 13 + 1, (ha_2 * 6 + 15) % 17 + 1))
                        local ky = vector.cross(hx_2, hy_2)
                        local kz = vector.dot(hx_2, hy_2)
                        if vector.dot(ky, ky) + kz * kz == vector.dot(hx_2, hx_2) * vector.dot(hy_2, hy_2) then
                            AutoPunchAuraGroup:AddToggle("AutoPunchAura", { Text = "Auto Punch Aura", Default = false })
                            AutoPunchAuraGroup:AddSlider("PunchAuraDelay", { Text = "Punch Delay", Default = 0.01, Min = 0.01, Max = 1, Rounding = 2 })
                            AutoPunchAuraGroup:AddToggle("AutoGoPunchable", { Text = "Auto Go to Punchable Areas", Default = false })
                            AutoPunchAuraGroup:AddSlider("PunchableTeleportDelay", { Text = "Teleport Delay", Default = 0.06, Min = 0.03, Max = 0.5, Rounding = 2 })
                            AutoBuyUpgradesGroup = hd_1.Main:AddRightGroupbox("Auto Buy Upgrades", "arrow-up-circle")
                        else
                            AutoBuyUpgradesGroup:AddToggle("AutoPunchAura", { Text = "Auto Punch Aura", Default = false })
                            AutoBuyUpgradesGroup:AddSlider("PunchAuraDelay", { Text = "Punch Delay", Min = 0.01, Max = 1, Rounding = 2, Default = 0.01 })
                            AutoBuyUpgradesGroup:AddToggle("AutoGoPunchable", { Text = "Auto Go to Punchable Areas", Default = false })
                            AutoBuyUpgradesGroup:AddSlider("PunchableTeleportDelay", { Max = 0.5, Rounding = 2, Min = 0.03, Default = 0.06, Text = "Teleport Delay" })
                            hd_1 = AutoPunchAuraGroup.Main:AddRightGroupbox("Auto Buy Upgrades", "arrow-up-circle")
                        end
                        ha_2 = (ha_2 + 127) % 160
                    end
                else
                    local hx_3 = {
                        "ghsyggj",
                        "jijfyzerp",
                        "kyjrm",
                        "addpnynhwnf",
                        "xybqx",
                        "zrsga",
                        "qwt",
                        "pdmnjg",
                        "ncbfdbagijj",
                        "tlxgjyeuv",
                        "emsdiqrz",
                        "hvvfgl"
                    }
                    local kI = ha_2
                    local hy_3 = hx_3[kI % 12 + 1]
                    if hy_3:len() >= hy_3:gsub("(.)", "%1%1", kI % 3 % 2 + 1):len() then
                        hb_6:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
                        hb_6:AddDropdown("UpgradePriority", { Default = hk, Text = "Upgrade Priority", Values = AutoBuyUpgradesGroup })
                        hd_1 = (nil):AddRightGroupbox("Auto Rebirth", "rotate-ccw")
                    else
                        AutoBuyUpgradesGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
                        AutoBuyUpgradesGroup:AddDropdown("UpgradePriority", { Text = "Upgrade Priority", Values = hk, Default = hf })
                        hb_6 = hd_1.Main:AddRightGroupbox("Auto Rebirth", "rotate-ccw")
                    end
                    ha_2 = (ha_2 + 107) % 160
                end
            elseif hw <= 4 then
                local hx_4 = (vector.create((ha_2 * 3 + 2) % 11 + 1, (ha_2 * 2 + 7) % 13 + 1, (ha_2 * 4 + 10) % 17 + 1))
                local hy_4 = (vector.create((ha_2 * 6 + 6) % 11 + 1, (ha_2 * 2 + 13) % 13 + 1, (ha_2 * 8 + 15) % 17 + 1))
                local hz_2 = (vector.create((ha_2 * 7 + 2) % 11 + 1, (ha_2 * 2 + 11) % 13 + 1, (ha_2 * 13 + 2) % 17 + 1))
                local hA_1 = (vector.create((ha_2 * 2 + 8) % 11 + 1, (ha_2 * 7 + 4) % 13 + 1, (ha_2 * 13 + 2) % 17 + 1))
                if vector.dot(vector.cross(hx_4, hy_4), (vector.cross(hz_2, hA_1))) == vector.dot(hx_4, hz_2) * vector.dot(hy_4, hA_1) - vector.dot(hx_4, hA_1) * vector.dot(hy_4, hz_2) + 1 then
                    hd_1:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
                    hb_6 = MenuGroup.Settings:AddLeftGroupbox("Menu")
                else
                    hb_6:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
                    MenuGroup = hd_1.Settings:AddLeftGroupbox("Menu")
                end
                ha_2 = (ha_2 + 87) % 160
            else
                local kx = bit32.rrotate(bit32.bxor(bit32.lrotate(ha_2, 27), string.byte(tostring(gT))), 16)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(kx, 1273591959), 1306036670), (bit32.bxor(bit32.band(kx, 3021375336), 4288302498))), 1306036670), 4288302498) == kx then
                    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
                    gF.ToggleKeybind = gr.MenuKeybind
                    gm = tick()
                    g5 = tick()
                    pcall(function()
                        for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
                            local ib = v
                            pcall(function()
                                ib:Disable()
                            end)
                        end
                    end)
                    gI = fn575
                    gt = hj.InputBegan:Connect(onInputBegan)
                    connection = hj.InputChanged:Connect(onInputChanged)
                else
                    gm:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { NoUI = true, Default = "RightShift", Text = "Menu keybind" })
                    connection.ToggleKeybind = g5.MenuKeybind
                    hj = tick()
                    gt = tick()
                    pcall(function()
                        for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
                            local ib = v
                            pcall(function()
                                ib:Disable()
                            end)
                        end
                    end)
                    gr = fn575
                    gI = MenuGroup.InputBegan:Connect(onInputBegan)
                    gF = MenuGroup.InputChanged:Connect(onInputChanged)
                end
                ha_2 = (ha_2 + 27) % 160
            end
        elseif hw <= 8 then
            if hw <= 7 then
                if hw <= 6 then
                    local hx_5 = { "qzwr", "ftpxnn", "wawbzrcfzg", "hxj", "kygpluphhjx", "ibwx", "kxdbvaf" }
                    local kF = ha_2
                    local hy_5 = hx_5[kF % 7 + 1]
                    if hy_5:len() >= hy_5:gsub("(.)", "%1%1", kF % 3 % 2 + 1):len() then
                        SaveManager:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
                        hh = gF.Settings:AddRightGroupbox("Performance", "gauge")
                        hh:AddToggle("FpsBoost", { Text = "FPS Boost", Default = false })
                        SaveManager:AddButton("Unload", onUnload)
                        MenuGroup:SetLibrary(gD)
                        MenuGroup:SetFolder("TempoHub")
                        MenuGroup:SaveDefault("Monochrome")
                        hd_1:SetLibrary(gD)
                        hd_1:IgnoreThemeSettings()
                        hd_1:SetIgnoreIndexes({ "MenuKeybind" })
                        hd_1:SetFolder("TempoHub/BananaMonkeyDestruction")
                        hd_1:BuildConfigSection(gF.Settings)
                        MenuGroup:ApplyToTab(gF.Settings)
                        MenuGroup:LoadDefault()
                        hd_1:LoadAutoloadConfig()
                        gD:OnUnload(fn215)
                    else
                        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
                        local PerformanceGroup = hd_1.Settings:AddRightGroupbox("Performance", "gauge")
                        PerformanceGroup:AddToggle("FpsBoost", { Text = "FPS Boost", Default = false })
                        MenuGroup:AddButton("Unload", onUnload)
                        hh:SetLibrary(gF)
                        hh:SetFolder("TempoHub")
                        hh:SaveDefault("Monochrome")
                        SaveManager:SetLibrary(gF)
                        SaveManager:IgnoreThemeSettings()
                        SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
                        SaveManager:SetFolder("TempoHub/BananaMonkeyDestruction")
                        SaveManager:BuildConfigSection(hd_1.Settings)
                        hh:ApplyToTab(hd_1.Settings)
                        hh:LoadDefault()
                        SaveManager:LoadAutoloadConfig()
                        gF:OnUnload(fn215)
                        gD = fn345
                    end
                    ha_2 = (ha_2 + 7) % 160
                else
                    local hx_6 = {
                        "bzg",
                        "agwyyl",
                        "bflugehhdv",
                        "sglmijbo",
                        "wqrwsnoop",
                        "uea",
                        "fhgubwrr",
                        "tdhtlxoijm",
                        "way",
                        "ptimrjg",
                        "xhihohif",
                        "ynfptvx",
                        "ruzgkrdblbtu",
                        "zcikuhy",
                        "uihwi"
                    }
                    if hx_6[(ha_2 * 1 + 44) % 15 + 1] <= hx_6[(ha_2 * 1 + 44) % 15 + 1] then
                        gn = nil
                        g6 = {}
                        g3 = {}
                        gY = 0
                        gT = nil
                    else
                        gY = nil
                        gn = {}
                        gT = {}
                        g3 = 0
                        g6 = nil
                    end
                    ha_2 = (ha_2 + 7) % 160
                end
            else
                if ha_2 * 105568791 + 4 + 2 <= ha_2 * 105568791 + 4 + 2 + 1 then
                    gQ = nil
                    gK = fn43
                    gB = fn569
                    g0 = fn139
                    gw = fn24
                else
                    g0 = nil
                    gw = fn43
                    gK = fn569
                    gQ = fn139
                    gB = fn24
                end
                ha_2 = (ha_2 + 67) % 160
            end
        elseif hw <= 9 then
            local hx_7 = {
                "rxszspz",
                "jcxtvwomtx",
                "ivcvzqevjn",
                "xynbazvr",
                "etocuib",
                "uukcaomfw",
                "mnrjus",
                "argf",
                "bzpda",
                "dxghrhyc",
                "mruexmja"
            }
            local kP = ha_2
            local hy_6 = hx_7[kP % 11 + 1]
            if hy_6:len() <= hy_6:gsub("(.)", "%1%1", kP % 3 % 2 + 1):len() then
                gL = fn159
                g4 = fn130
                gx = fn572
            else
                gx = fn159
                gL = fn130
                g4 = fn572
            end
            ha_2 = (ha_2 + 27) % 160
        else
            local hx_8 = (vector.create((ha_2 * 1 + 4) % 11 + 1, (ha_2 * 5 + 3) % 13 + 1, (ha_2 * 13 + 2) % 17 + 1))
            local hy_7 = (vector.create((ha_2 * 4 + 2) % 11 + 1, (ha_2 * 7 + 13) % 13 + 1, (ha_2 * 10 + 4) % 17 + 1))
            local hz_3 = (vector.create((ha_2 * 2 + 3) % 11 + 1, (ha_2 * 1 + 10) % 13 + 1, (ha_2 * 3 + 11) % 17 + 1))
            local hA_2 = (vector.create((ha_2 * 1 + 2) % 11 + 1, (ha_2 * 6 + 8) % 13 + 1, (ha_2 * 11 + 4) % 17 + 1))
            if vector.dot(vector.cross(hx_8, hy_7), (vector.cross(hz_3, hA_2))) == vector.dot(hx_8, hz_3) * vector.dot(hy_7, hA_2) - vector.dot(hx_8, hA_2) * vector.dot(hy_7, hz_3) then
                gG = nil
                gC = setmetatable({}, { __mode = "k" })
                gz = function(b6, b7, b8)
                    local iT_2
                    local iS_2
                    local iR = gC[b6]
                    if not iR then
                        iR = {}
                        gC[b6] = iR
                    end
                    if iR[b7] == nil then
                        iS_2, iT_2 = pcall(function()
                            return b6[b7]
                        end)
                        if not iS_2 then
                            return
                        end
                        iR[b7] = iT_2
                    end
                    pcall(function()
                        b6[b7] = b8
                    end)
                end
                onDescendantAdded = fn595
            else
                gz = nil
                gG = setmetatable({}, { __mode = "k" })
                onDescendantAdded = function(b6, b7, b8)
                    local iT_1
                    local iS_1
                    local iR = gC[b6]
                    if not iR then
                        iR = {}
                        gC[b6] = iR
                    end
                    if iR[b7] == nil then
                        iS_1, iT_1 = pcall(function()
                            return b6[b7]
                        end)
                        if not iS_1 then
                            return
                        end
                        iR[b7] = iT_1
                    end
                    pcall(function()
                        b6[b7] = b8
                    end)
                end
                gC = fn595
            end
            ha_2 = (ha_2 + 7) % 160
        end
    elseif hw <= 15 then
        if hw <= 13 then
            if hw <= 12 then
                if hw <= 11 then
                    if (ha_2 * 3 + 3) * 5 % 4 == ((ha_2 * 3 + 3) * 5 + 11) % 4 then
                        gw = function()
                            if gG then
                                gG:Disconnect()
                                gG = nil
                            end
                            for k, v in gC do
                                local i6 = k
                                for k, v in v do
                                    local jc = k
                                    local je = v
                                    pcall(function()
                                        i6[jc] = je
                                    end)
                                end
                            end
                            table.clear(gC)
                        end
                    else
                        g_ = function()
                            if gG then
                                gG:Disconnect()
                                gG = nil
                            end
                            for k, v in gC do
                                local i6 = k
                                for k, v in v do
                                    local jc = k
                                    local je = v
                                    pcall(function()
                                        i6[jc] = je
                                    end)
                                end
                            end
                            table.clear(gC)
                        end
                    end
                    ha_2 = (ha_2 + 47) % 160
                else
                    local kR = bit32.rrotate(bit32.bxor(bit32.lrotate(ha_2, 3), string.byte(tostring(gC))), 17)
                    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(kR, 405072783), 113481678), (bit32.bxor(bit32.band(kR, 3889894512), 1598101293))), 113481678), 1598101293) ~= kR then
                        gw = fn566
                    else
                        go = fn566
                    end
                    ha_2 = (ha_2 + 7) % 160
                end
            else
                local hx_9 = {
                    "mptazcrtdrg",
                    "vkscbi",
                    "ipugiitqpvsk",
                    "sipkijfqeoks",
                    "wqwnoyy",
                    "nqnzaap",
                    "rxvupzm",
                    "myjeun",
                    "nsc",
                    "ncdppa",
                    "trbfivfq",
                    "ysmgqvrhlzur",
                    "vwavwy",
                    "szeuzungy"
                }
                if hx_9[(ha_2 * 58 + 11) % 14 + 1] <= hx_9[(ha_2 * 58 + 11) % 14 + 1] then
                    Toggles.FpsBoost:OnChanged(fn565)
                else
                    Toggles.FpsBoost:OnChanged(fn565)
                end
                ha_2 = (ha_2 + 7) % 160
            end
        elseif hw <= 14 then
            if (ha_2 * 2 + 7) * 10 % 3 == ((ha_2 * 2 + 7) * 10 + 5) % 3 then
                gP = hm_1
                he_1:AddLabel(g8_4("Server", gP, gA), true)
                he_1:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
                os.clock()
            else
                hm_1:AddLabel(gA("Server", g8_4, he_1), true)
                hm_1:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
                gP = os.clock()
            end
            ha_2 = (ha_2 + 47) % 160
        else
            if ha_2 * 23261707 + 2 + 7 <= ha_2 * 23261707 + 2 + 7 + 1 then
                task.spawn(worker)
                ScriptsGroup = hd_1.Info:AddRightGroupbox("Scripts", "package")
            else
                task.spawn(worker)
                hd_1 = ScriptsGroup.Info:AddRightGroupbox("Scripts", "package")
            end
            ha_2 = (ha_2 + 87) % 160
        end
    elseif hw <= 18 then
        if hw <= 17 then
            if hw <= 16 then
                local hx_10 = { "evycqqksxq", "ffrlubddmjc", "aaihio", "zlbe", "voifl", "jxvjv", "lsbunkkw", "uyqp" }
                local kK = ha_2
                local hy_8 = hx_10[kK % 8 + 1]
                if hy_8:len() <= hy_8:reverse():rep(kK % 3 + 2):len() then
                    ScriptsGroup:AddLabel(gJ("Included in this hub", he_1), true)
                    ScriptsGroup:AddLabel(gJ(hi, hl), true)
                    FeaturesGroup = hd_1.Info:AddRightGroupbox("Features", "list")
                else
                    he_1:AddLabel(FeaturesGroup("Included in this hub", ScriptsGroup), true)
                    he_1:AddLabel(FeaturesGroup(hl, hi), true)
                    hd_1 = gJ.Info:AddRightGroupbox("Features", "list")
                end
                ha_2 = (ha_2 + 27) % 160
            else
                local hx_11 = (vector.create((ha_2 * 1 + 7) % 11 + 1, (ha_2 * 3 + 7) % 13 + 1, (ha_2 * 5 + 2) % 17 + 1))
                local hy_9 = (vector.create((ha_2 * 3 + 1) % 11 + 1, (ha_2 * 4 + 8) % 13 + 1, (ha_2 * 15 + 5) % 17 + 1))
                local hz_4 = (vector.create((ha_2 * 1 + 8) % 11 + 1, (ha_2 * 2 + 10) % 13 + 1, (ha_2 * 15 + 12) % 17 + 1))
                if vector.dot(vector.cross(hx_11, hy_9), hz_4) == vector.dot(vector.cross(hy_9, hz_4), hx_11) then
                    FeaturesGroup:AddLabel(gJ("Auto Go Map", hl), true)
                    FeaturesGroup:AddLabel(gJ("Auto Go to Punchable Areas", hl), true)
                    FeaturesGroup:AddLabel(gJ("Auto Punch Aura", gX), true)
                    FeaturesGroup:AddLabel(gJ("Auto Buy Upgrades", hl), true)
                    FeaturesGroup:AddLabel(gJ("Auto Rebirth", gX), true)
                    SocialsGroup = hd_1.Info:AddRightGroupbox("Socials", "link")
                else
                    gX:AddLabel(FeaturesGroup("Auto Go Map", SocialsGroup), true)
                    gX:AddLabel(FeaturesGroup("Auto Go to Punchable Areas", SocialsGroup), true)
                    gX:AddLabel(FeaturesGroup("Auto Punch Aura", hl), true)
                    gX:AddLabel(FeaturesGroup("Auto Buy Upgrades", SocialsGroup), true)
                    gX:AddLabel(FeaturesGroup("Auto Rebirth", hl), true)
                    hd_1 = gJ.Info:AddRightGroupbox("Socials", "link")
                end
                ha_2 = (ha_2 + 67) % 160
            end
        else
            if ha_2 * 76137029 + 6 + 2 <= ha_2 * 76137029 + 6 + 2 + 5 then
                SocialsGroup:AddButton({ Text = "Discord", Func = gN })
                SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
                TempoHubGroup = hd_1.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
            else
                TempoHubGroup:AddButton({ Text = "Discord", Func = SocialsGroup })
                TempoHubGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
                hd_1 = gN.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
            end
            ha_2 = (ha_2 + 7) % 160
        end
    elseif hw <= 19 then
        local hw_1 = {
            "mfojamdzm",
            "rhrenr",
            "lvm",
            "nzopzhxqj",
            "wbdeibawq",
            "fdad",
            "fqcbrmjqi",
            "bzcy",
            "fqjsrl",
            "puakkddcic",
            "snvimsylnwr",
            "hgecdhnztj"
        }
        local kL = ha_2
        local hx_12 = hw_1[kL % 12 + 1]
        if hx_12:len() <= hx_12:reverse():rep(kL % 3 + 2):len() then
            TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
            TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
            TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
            TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = gN })
            FaqGroup = hd_1.Info:AddRightGroupbox("FAQ", "circle-help")
        else
            gN:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
            gN:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
            gN:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
            gN:AddButton({ Text = "Copy Discord Invite", Func = TempoHubGroup })
            hd_1 = FaqGroup.Info:AddRightGroupbox("FAQ", "circle-help")
        end
        ha_2 = (ha_2 + 27) % 160
    else
        local hw_2 = (vector.create((ha_2 * 6 + 2) % 11 + 1, (ha_2 * 11 + 9) % 13 + 1, (ha_2 * 9 + 4) % 17 + 1))
        local hx_13 = (vector.create((ha_2 * 4 + 7) % 11 + 1, (ha_2 * 9 + 7) % 13 + 1, (ha_2 * 6 + 17) % 17 + 1))
        local hy_10 = (vector.create((ha_2 * 6 + 4) % 11 + 1, (ha_2 * 3 + 1) % 13 + 1, (ha_2 * 3 + 9) % 17 + 1))
        if vector.dot(vector.cross(hw_2, hx_13), hy_10) == vector.dot(vector.cross(hx_13, hy_10), hw_2) + 1 then
            AutoGoMapGroup:AddLabel("Where do I get a good config?", true)
            AutoGoMapGroup:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
            AutoGoMapGroup:AddLabel("How do I import / export configs?", true)
            AutoGoMapGroup:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
            AutoGoMapGroup:AddLabel("How do I report bugs?", true)
            AutoGoMapGroup:AddLabel("Join the Discord and post it in the bugs channel.", true)
            AutoGoMapGroup:AddLabel("How do I make suggestions?", true)
            AutoGoMapGroup:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
            AutoGoMapGroup:AddLabel("How do I get help or updates?", true)
            AutoGoMapGroup:AddLabel("Join the Discord, updates and support are posted there first.", true)
            hd_1 = FaqGroup.Main:AddLeftGroupbox("Auto Go Map", "map")
        else
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
            AutoGoMapGroup = hd_1.Main:AddLeftGroupbox("Auto Go Map", "map")
        end
        ha_2 = (ha_2 + 147) % 160
    end
until (ha_2 * 121 + 123) % 160 == 37
if Toggles.FpsBoost.Value then
    go(true)
end
local g8_5 = 3
repeat
    local g9_6 = { "ctxlbxxhp", "ozoixugdpjv", "medqanm", "esmhb", "ajega", "zkwfzpbpv", "zvvqaun", "gwri" }
    local kY = g8_5
    local ha_3 = g9_6[kY % 8 + 1]
    if ha_3:len() <= ha_3:reverse():rep(kY % 3 + 2):len() then
        task.spawn(antiAfkLoop)
        task.spawn(autoGoMapLoop)
        task.spawn(autoPunchAuraLoop)
        task.spawn(function()
            local jO = false
            repeat
                local jI = math.clamp(gr.PunchableTeleportDelay.Value, 0.03, 0.5)
                local wait = task.wait
                local jJ_6
                local jK = Toggles.AutoGoPunchable.Value and jI
                local jK_6
                local jL = jK or 0.25
                local jL_6
                wait(jL)
                if gF.Unloaded then
                    jO = true
                elseif Toggles.AutoGoPunchable.Value then
                    local Character = LocalPlayer.Character
                    local jK_4 = Character and Character:FindFirstChild("HumanoidRootPart")
                    local jL_4 = Character
                    local jH = jK_4
                    if jL_4 then
                        jL_4 = Character:FindFirstChildOfClass("Humanoid")
                    end
                    local jF = jL_4
                    local Map = workspace:FindFirstChild("Map")
                    if jH and jF and jF.Health > 0 and Map then
                        if Map ~= gn then
                            gL(Map)
                        end
                        if not ProgressionConfig.IsInMap(jH) then
                            jH.AssemblyLinearVelocity = Vector3.zero
                            jH.AssemblyAngularVelocity = Vector3.zero
                            jH.CFrame = CFrame.new(0, 10, 0)
                        else
                            local jG = g4(Map)
                            if jG then
                                jJ_6, jL_6, jK_6 = pcall(function()
                                    return jG.Position, gx(jH, jF, jG)
                                end)
                                if jJ_6 then
                                    jH.AssemblyLinearVelocity = Vector3.zero
                                    jH.AssemblyAngularVelocity = Vector3.zero
                                    jH.CFrame = jK_6
                                    Destruction_Punch:FireServer(DestructionConfig.PunchType.Ground, jL_6)
                                    if Toggles.AutoPunchAura.Value then
                                        task.wait(math.min(0.03, jI * 0.5))
                                        local jI_2 = jH.Parent and ProgressionConfig.IsInMap(jH)
                                        if jI_2 then
                                            Destruction_Punch:FireServer(DestructionConfig.PunchType.Ground, jH.Position)
                                        end
                                    end
                                else
                                    g0(jG)
                                end
                            end
                        end
                    end
                end
            until jO
        end)
        gF:OnUnload(fn500)
        task.spawn(autoBuyUpgradesLoop)
        task.spawn(autoRebirthLoop)
    else
        task.spawn(antiAfkLoop)
        task.spawn(autoGoMapLoop)
        task.spawn(autoPunchAuraLoop)
        task.spawn(function()
            local jO = false
            repeat
                local jI = math.clamp(gr.PunchableTeleportDelay.Value, 0.03, 0.5)
                local wait = task.wait
                local jJ_3
                local jK = Toggles.AutoGoPunchable.Value and jI
                local jK_3
                local jL = jK or 0.25
                local jL_3
                wait(jL)
                if gF.Unloaded then
                    jO = true
                elseif Toggles.AutoGoPunchable.Value then
                    local Character = LocalPlayer.Character
                    local jK_1 = Character and Character:FindFirstChild("HumanoidRootPart")
                    local jL_1 = Character
                    local jH = jK_1
                    if jL_1 then
                        jL_1 = Character:FindFirstChildOfClass("Humanoid")
                    end
                    local jF = jL_1
                    local Map = workspace:FindFirstChild("Map")
                    if jH and jF and jF.Health > 0 and Map then
                        if Map ~= gn then
                            gL(Map)
                        end
                        if not ProgressionConfig.IsInMap(jH) then
                            jH.AssemblyLinearVelocity = Vector3.zero
                            jH.AssemblyAngularVelocity = Vector3.zero
                            jH.CFrame = CFrame.new(0, 10, 0)
                        else
                            local jG = g4(Map)
                            if jG then
                                jJ_3, jL_3, jK_3 = pcall(function()
                                    return jG.Position, gx(jH, jF, jG)
                                end)
                                if jJ_3 then
                                    jH.AssemblyLinearVelocity = Vector3.zero
                                    jH.AssemblyAngularVelocity = Vector3.zero
                                    jH.CFrame = jK_3
                                    Destruction_Punch:FireServer(DestructionConfig.PunchType.Ground, jL_3)
                                    if Toggles.AutoPunchAura.Value then
                                        task.wait(math.min(0.03, jI * 0.5))
                                        local jI_1 = jH.Parent and ProgressionConfig.IsInMap(jH)
                                        if jI_1 then
                                            Destruction_Punch:FireServer(DestructionConfig.PunchType.Ground, jH.Position)
                                        end
                                    end
                                else
                                    g0(jG)
                                end
                            end
                        end
                    end
                end
            until jO
        end)
        gF:OnUnload(fn500)
        task.spawn(autoBuyUpgradesLoop)
        task.spawn(autoRebirthLoop)
    end
    g8_5 = (g8_5 + 3) % 4
until (g8_5 * 1 + 1) % 4 == 3
end)(...)

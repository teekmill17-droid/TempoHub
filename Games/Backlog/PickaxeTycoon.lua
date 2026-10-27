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
getgenv().TempoHoodSubtitle = "PICKAXE TYCOON"
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
local Library
local imageButton
local onIdled
local hR
local hy
local VirtualUser
local Options
local hX
local TweenService
local screenGui2
local hH_1
local h2
local h5
local hK
local h8
local hN
local hu
local hQ
local hx
local hT
local frame5
local hW
local hD
local hZ
local hG
local imageLabel2
local hJ
local ReplicatedStorage
local Position
local uIStroke2
local LocalPlayer
local HelperModule
local Position2
local Window
local hz
local textLabel3
local hY
local hC
local h0
local hI
local h3
local function onAutoOpenChests(c5)
    hW = c5
end
local function worker()
    while true do
        local kc = hW and LocalPlayer:GetAttribute("holdingChest")
        if kc then
            local kc_1 = hy()
            if kc_1 == true then
                pcall(function()
                    ReplicatedStorage.RemoteEvents.UnlockChest:FireServer()
                end)
                task.wait(0.6)
            elseif kc_1 == false and hR then
                pcall(function()
                    ReplicatedStorage.RemoteEvents.DiscardChest:FireServer()
                end)
                task.wait(0.3)
            else
                task.wait(0.4)
            end
        else
            task.wait(0.4)
        end
    end
end
local function onAutoUpgrade(c3)
    hY = c3
end
local function onInputChanged(ed)
    if hX and (ed.UserInputType == Enum.UserInputType.MouseMovement or ed.UserInputType == Enum.UserInputType.Touch) then
        local k3_1 = ed.Position - Position2
        if k3_1.Magnitude > 4 then
            hI = true
        end
        imageButton.Position = UDim2.new(Position.X.Scale, Position.X.Offset + k3_1.X, Position.Y.Scale, Position.Y.Offset + k3_1.Y)
    end
end
local function onAutoPickup(cW)
    hu = cW
end
local function fn122(aF)
    aF:AddButton({
        Text = "Join Discord for Dupes/Keyless Scripts",
        Func = function()
            if setclipboard then
                setclipboard(hK)
            end
            h3("Tempo Discord copied to clipboard!")
        end
    })
end
local function onRenderStepped()
    local lr = hD()
    if lr and Library.Toggled and lr.Visible then
        frame5.Visible = true
        frame5.Position = UDim2.fromOffset(lr.AbsolutePosition.X + lr.AbsoluteSize.X + 15, lr.AbsolutePosition.Y)
    else
        frame5.Visible = false
    end
end
local function onAutoCollect(c_)
    h2 = c_
end
local function onMouseButton1Click()
    if hI then
        return
    end
    pcall(function()
        Window:Toggle()
    end)
end
local function worker2()
    while true do
        if hu then
            pcall(hN)
        end
        task.wait(0.05)
    end
end
local function onAutoDismissChest(c7)
    hR = c7
end
local function onInputBegan(d6)
    if d6.UserInputType == Enum.UserInputType.MouseButton1 or d6.UserInputType == Enum.UserInputType.Touch then
        hX, hI = true, false
        Position2 = d6.Position
        Position = imageButton.Position
    end
end
local function onAutoMerge(c1)
    h0 = c1
end
local function worker4()
    while true do
        if h2 then
            local kj = h5()
            if kj then
                local Sell = kj:FindFirstChild("Sell")
                local kl = Sell and Sell:FindFirstChild("CollectButton")
                local kk_1 = kl
                if kl then
                    kl = kk_1:FindFirstChild("Button")
                end
                local kk_2 = kl
                if kk_2 then
                    hC(kk_2)
                end
                local OfflineIncome = kj:FindFirstChild("OfflineIncome")
                local kj_1 = OfflineIncome and OfflineIncome:FindFirstChild("Part1")
                if kj_1 then
                    hC(kj_1)
                end
            end
        end
        task.wait(0.3)
    end
end
local function fn381()
    local Character = LocalPlayer.Character
    if not Character then
        return nil
    end
    return Character:FindFirstChild("HumanoidRootPart")
end
local function onMouseButton1Click2()
    task.spawn(function()
        TweenService:Create(imageLabel2, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(34, 34), Position = UDim2.new(0, 18, 0, 18) }):Play()
        task.wait(0.1)
        TweenService:Create(imageLabel2, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(40, 40), Position = UDim2.new(0, 15, 0, 15) }):Play()
    end)
    pcall(function()
        setclipboard(hK)
    end)
    h3("Marketplace Discord copied to clipboard!")
end
local function fn408()
    local ScreenGui = Library.ScreenGui
    local lm = not ScreenGui
    local lq = if lm then 1 else 0
    local lo = 3398 * lq + 678 * (1 - lq)
    local lp = 184 * lq + 766 * (1 - lq)
    if not ((lo * 241 + lp * 2853 + lo * lp) % 16777213 == 1969102) then
        lm = not ScreenGui.Parent
    end
    if lm then
        return nil
    end
    local Main = ScreenGui:FindFirstChild("Main")
    local ll_1 = Main and Main:IsA("GuiObject")
    if ll_1 then
        return Main
    end
    return nil
end
local function onMouseEnter()
    TweenService:Create(frame5, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(30, 30, 35) }):Play()
    TweenService:Create(uIStroke2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Color = Color3.fromRGB(100, 100, 115) }):Play()
    TweenService:Create(textLabel3, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(230, 230, 230) }):Play()
end
local function fn450()
    local jB_1
    local jA_1
    local jx = hQ()
    if not jx then
        return
    end
    local jx_1 = h5()
    if not jx_1 then
        return
    end
    local jy = OverlapParams.new()
    jy.CollisionGroup = "Loot"
    local jz = OverlapParams.new()
    jz.CollisionGroup = "Chests"
    jA_1, jB_1 = jx_1:GetBoundingBox()
    local jx_2 = {}
    for i, v in ipairs(workspace:GetPartBoundsInBox(jA_1, jB_1, jy)) do
        jx_2[v] = true
    end
    for i, v in ipairs(workspace:GetPartBoundsInBox(jA_1, jB_1, jz)) do
        jx_2[v] = true
    end
    local jy_1 = nil
    local jz_1 = {}
    for k in pairs(jx_2) do
        local attr2 = k:GetAttribute("LootTier")
        if attr2 then
            table.insert(jz_1, attr2)
            local jx_4 = k.Parent:IsA("Model") and k.Parent
            local jA_2 = jx_4 or k
            jA_2:Destroy()
        elseif not hT then
            local attr = k:GetAttribute("ChestTier")
            if attr and not jy_1 then
                local jA_4 = false
                local Character = LocalPlayer.Character
                if Character then
                    for i, child in ipairs(Character:GetChildren()) do
                        if child:IsA("Tool") then
                            jA_4 = true
                            break
                        end
                    end
                end
                if not jA_4 then
                    jy_1 = "Chest" .. attr
                    local jx_7 = k.Parent:IsA("Model") and k.Parent
                    local jA_5 = jx_7 or k
                    jA_5:Destroy()
                end
            end
        end
    end
    if #jz_1 > 0 then
        ReplicatedStorage.RemoteEvents.LootPickup:FireServer(jz_1)
    end
    if jy_1 then
        ReplicatedStorage.RemoteEvents.ChestPickup:FireServer(jy_1)
        hT = true
        task.delay(0.9, function()
            hT = false
        end)
    end
end
local function worker7()
    while true do
        if hY then
            local kB = h5()
            if kB then
                local Sell = kB:FindFirstChild("Sell")
                local kB_1 = Sell and Sell:FindFirstChild("UpgradeButton")
                local kC_1 = kB_1
                if kB_1 then
                    kB_1 = kC_1:FindFirstChild("Button")
                end
                local kC_2 = kB_1
                if kC_2 then
                    hC(kC_2)
                end
            end
        end
        task.wait(0.4)
    end
end
local function onAutoDeposit(cY)
    h8 = cY
end
local function fn482()
    local ChestGui = LocalPlayer.PlayerGui:FindFirstChild("ChestGui")
    local j7 = ChestGui and ChestGui:FindFirstChild("ChestInfo")
    local j6_1 = j7
    if j7 then
        j7 = j6_1:FindFirstChild("UnlockMenu")
    end
    local j6_2 = j7
    if j7 then
        j7 = j6_2:FindFirstChild("UnlockButton")
    end
    local j6_3 = j7
    if j7 then
        j7 = j6_3:FindFirstChild("ForceOpenFrame")
    end
    local j6_4 = j7
    if not j6_4 then
        return nil
    end
    return not j6_4.Visible
end
local function worker6()
    while true do
        local kq = h5()
        if kq then
            local Buttons = kq:FindFirstChild("Buttons")
            if Buttons then
                for k, v in pairs(hZ) do
                    if v then
                        local kq_1 = Buttons:FindFirstChild("ButtonBuy" .. k)
                        local ks = kq_1 and kq_1:FindFirstChild("Button")
                        if ks then
                            hC(ks)
                        end
                    end
                end
            end
        end
        task.wait(0.4)
    end
end
local function fn507()
    Library:SetWatermarkVisibility(false)
end
local function worker5()
    while true do
        if h0 then
            local kn = h5()
            if kn then
                local Buttons = kn:FindFirstChild("Buttons")
                local kn_1 = Buttons and Buttons:FindFirstChild("ButtonMerge")
                local ko_1 = kn_1
                if kn_1 then
                    kn_1 = ko_1:FindFirstChild("Button")
                end
                local ko_2 = kn_1
                if ko_2 then
                    hC(ko_2)
                end
            end
        end
        task.wait(0.4)
    end
end
local function fn536()
    local jq_1
    local jp_1
    jp_1, jq_1 = pcall(HelperModule.findPlayersPlot, LocalPlayer)
    if jp_1 then
        return jq_1
    end
    return nil
end
local function fn545(ag)
    local jf_1, jf_2
    local je_1
    for i, v in ipairs(ag) do
        je_1, jf_1 = pcall(game.HttpGet, game, v)
        local jg = je_1 and type(jf_1) == "string" and #jf_1 > 200
        local jg_1
        if jg then
            local je_2 = loadstring(jf_1)
            if je_2 then
                jf_2, jg_1 = pcall(je_2)
                local je_3 = jf_2 and type(jg_1) == "table"
                if je_3 then
                    return jg_1
                end
            end
        end
    end
    return nil
end
local function onMouseLeave()
    TweenService:Create(frame5, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(25, 25, 30) }):Play()
    TweenService:Create(uIStroke2, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Color = Color3.fromRGB(80, 80, 95) }):Play()
    TweenService:Create(textLabel3, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(190, 190, 190) }):Play()
end
local function fn629()
    return { 1, 5, 25, 100 }
end
local function onInputEnded(en)
    if en.UserInputType == Enum.UserInputType.MouseButton1 or en.UserInputType == Enum.UserInputType.Touch then
        hX = false
    end
end
local function worker3()
    while true do
        if h8 then
            local kg = h5()
            if kg then
                local Sell = kg:FindFirstChild("Sell")
                local kg_1 = Sell and Sell:FindFirstChild("DepositButton")
                local kh_1 = kg_1
                if kg_1 then
                    kg_1 = kh_1:FindFirstChild("Button")
                end
                local kh_2 = kg_1
                if kh_2 then
                    hC(kh_2)
                end
            end
        end
        task.wait(0.25)
    end
end
HelperModule = nil
hu = nil
onIdled = nil
Window = nil
hx = nil
hy = nil
hz = nil
frame5 = nil
Options = nil
hC = nil
hD = nil
screenGui2 = nil
local hF
hG = nil
hI = nil
hJ = nil
hK = nil
Position = nil
hN = nil
Library = nil
LocalPlayer = nil
hQ = nil
hR = nil
Position2 = nil
hT = nil
VirtualUser = nil
textLabel3 = nil
hW = nil
hX = nil
hY = nil
hZ = nil
TweenService = nil
h0 = nil
imageLabel2 = nil
h2 = nil
h3 = nil
ReplicatedStorage = nil
h5 = nil
uIStroke2 = nil
h8 = nil
imageButton = nil
local hs, h6
local ic_1
local io_1
local ip_1
local il_1
local ij_1
ReplicatedStorage, TweenService, VirtualUser, LocalPlayer, hK, hG, Library = nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
VirtualUser = game:GetService("VirtualUser")
LocalPlayer = Players.LocalPlayer
hK = "https://discord.gg/K7Qxnxkk46"
hG = "rbxassetid://91400086538074"
local id = 91400086538074
local function ib()
    local iN
    local iP
    local frame3
    local iQ
    local iO
    local textButton
    iN = nil
    iO = nil
    iP = nil
    iQ = nil
    textButton = nil
    frame3 = nil
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TempoLoader"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 2147483647
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local iU = gethui and gethui()
    local iV = iU
    local i1 = if iV then 1 else 0
    local i_ = 1789 * i1 + 2946 * (1 - i1)
    local i0 = 3676 * i1 + 774 * (1 - i1)
    if not ((i_ * 75 + i0 * 2405 + i_ * i0) % 16777213 == 15551319) then
        iV = game:GetService("CoreGui")
    end
    screenGui.Parent = iV
    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Size = 0
    blurEffect.Parent = game:GetService("Lighting")
    local frame4 = Instance.new("Frame")
    frame4.Size = UDim2.fromScale(1, 1)
    frame4.BackgroundTransparency = 1
    frame4.Parent = screenGui
    frame3 = Instance.new("Frame")
    frame3.AnchorPoint = Vector2.new(0.5, 0.5)
    frame3.Position = UDim2.fromScale(0.5, 0.5)
    frame3.Size = UDim2.fromOffset(460, 0)
    frame3.AutomaticSize = Enum.AutomaticSize.Y
    frame3.BackgroundTransparency = 1
    frame3.Parent = frame4
    local uIListLayout = Instance.new("UIListLayout")
    uIListLayout.FillDirection = Enum.FillDirection.Vertical
    uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uIListLayout.Padding = UDim.new(0, 8)
    uIListLayout.Parent = frame3
    iP = function(t)
        local uIStroke = Instance.new("UIStroke")
        uIStroke.Color = Color3.fromRGB(0, 0, 0)
        uIStroke.Thickness = 2
        uIStroke.Transparency = 0.1
        uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        uIStroke.Parent = t
        return uIStroke
    end
    local function iV_3(w, x, y, z, A)
        local textLabel = Instance.new("TextLabel")
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.fromOffset(460, x + 6)
        textLabel.Font = y
        textLabel.Text = w
        textLabel.TextSize = x
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextTransparency = z
        textLabel.LayoutOrder = A
        iP(textLabel)
        textLabel.Parent = frame3
        return textLabel
    end
    iN = hK
    iV_3("Made Tempo Marketplace && MM", 26, Enum.Font.GothamBold, 0, 1)
    textButton = Instance.new("TextButton")
    textButton.BackgroundTransparency = 1
    textButton.AutoButtonColor = false
    textButton.Size = UDim2.fromOffset(460, 24)
    textButton.Font = Enum.Font.GothamSemibold
    textButton.RichText = true
    textButton.Text = "<u>" .. iN .. "</u>  (click to copy)"
    textButton.TextSize = 16
    textButton.TextColor3 = Color3.fromRGB(120, 160, 255)
    textButton.LayoutOrder = 2
    iP(textButton)
    textButton.Parent = frame3
    textButton.MouseEnter:Connect(function()
        textButton.TextColor3 = Color3.fromRGB(170, 200, 255)
    end)
    textButton.MouseLeave:Connect(function()
        textButton.TextColor3 = Color3.fromRGB(120, 160, 255)
    end)
    textButton.Activated:Connect(function()
        if setclipboard then
            setclipboard(iN)
        end
        textButton.Text = "<u>" .. iN .. "</u>  (copied!)"
        task.delay(1.5, function()
            textButton.Text = "<u>" .. iN .. "</u>  (click to copy)"
        end)
    end)
    local iW = iV_3("Join for Dupes and Keyless Scripts. Dupes will always be announced and never gatekept in Tempo.", 13, Enum.Font.GothamMedium, 0.2, 3)
    iW.TextWrapped = true
    iW.Size = UDim2.fromOffset(420, 34)
    iQ = iV_3("Tempo Bypassing", 14, Enum.Font.GothamMedium, 0.05, 4)
    iQ.Size = UDim2.fromOffset(460, 18)
    local frame2 = Instance.new("Frame")
    frame2.LayoutOrder = 5
    frame2.Size = UDim2.fromOffset(300, 6)
    frame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame2.BackgroundTransparency = 0.85
    frame2.BorderSizePixel = 0
    frame2.Parent = frame3
    local uICorner2 = Instance.new("UICorner")
    uICorner2.CornerRadius = UDim.new(1, 0)
    uICorner2.Parent = frame2
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(0, 1)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BorderSizePixel = 0
    frame.Parent = frame2
    local uICorner = Instance.new("UICorner")
    uICorner.CornerRadius = UDim.new(1, 0)
    uICorner.Parent = frame
    iO = true
    task.spawn(function()
        local iL = 0
        while iO do
            iL = iL % 3 + 1
            iQ.Text = "Tempo Bypassing" .. string.rep(".", iL)
            task.wait(0.35)
        end
    end)
    TweenService:Create(blurEffect, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = 18 }):Play()
    local iX_1 = { 0.35, 0.55, 0.72, 0.9, 1 }
    for i, v in ipairs(iX_1) do
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromScale(v, 1) }):Play()
        task.wait(0.55)
    end
    iO = false
    task.wait(0.25)
    local iX_2 = TweenInfo.new(0.4, Enum.EasingStyle.Quad)
    for i, descendant in ipairs(frame3:GetDescendants()) do
        local iY = descendant:IsA("TextLabel") or descendant:IsA("TextButton")
        if iY then
            TweenService:Create(descendant, iX_2, { TextTransparency = 1 }):Play()
        elseif descendant:IsA("UIStroke") then
            TweenService:Create(descendant, iX_2, { Transparency = 1 }):Play()
        end
    end
    TweenService:Create(frame2, iX_2, { BackgroundTransparency = 1 }):Play()
    TweenService:Create(frame, iX_2, { BackgroundTransparency = 1 }):Play()
    TweenService:Create(blurEffect, iX_2, { Size = 0 }):Play()
    task.wait(0.45)
    blurEffect:Destroy()
    screenGui:Destroy()
end
ib()
local ie = fn545
local ig = "https://raw.githubusercontent.com/uhfork/Obsidian/main/"
if (LocalPlayer or not Players or not Players and Players) and (Players or LocalPlayer or LocalPlayer and not Players) and (not LocalPlayer and LocalPlayer and (not Players and Players) or (not Players or not LocalPlayer or (Players or not LocalPlayer))) and not ((LocalPlayer or not Players or not Players and Players) and (Players or LocalPlayer or LocalPlayer and not Players) and (not LocalPlayer and LocalPlayer and (not Players and Players) or (not Players or not LocalPlayer or (Players or not LocalPlayer)))) then
    ig = Library({ ie .. "Library.lua" })
else
    Library = getgenv().Library
end
if not Library then
    return
end
io_1, hF, Options, Window, ip_1, HelperModule, hZ, hT, hu, h8, h2, h0, hY, hW, hR, ic_1, hs, h6, il_1, h3, h5, hQ, hC, hN, hH_1, ij_1, hy = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if (not il_1 and HelperModule and (HelperModule and HelperModule) or (not il_1 or ic_1 or ic_1 and not HelperModule)) and not (not il_1 and HelperModule and (HelperModule and HelperModule) or (not il_1 or ic_1 or ic_1 and not HelperModule)) then
    ie = ig({ io_1 .. "addons/ThemeManager.lua" })
else
    io_1 = ie({ ig .. "addons/ThemeManager.lua" })
end
hF = ie({ ig .. "addons/SaveManager.lua" })
Options = Library.Options
if not hN or hT or (ip_1 or ip_1) or (ic_1 or ip_1) and (not hN and not ip_1) or ((not ip_1 or not hN) and (hT and hN) or hF and not ic_1 and (hN and ip_1)) or (ip_1 or hF) and (not hT and not ip_1) and (ip_1 and ip_1 and (ip_1 and not ip_1)) and (hT and ip_1 and (hN or hT) or not hT and not ip_1 and (not ic_1 and not hN)) or not (not hN or hT or (ip_1 or ip_1) or (ic_1 or ip_1) and (not hN and not ip_1) or ((not ip_1 or not hN) and (hT and hN) or hF and not ic_1 and (hN and ip_1)) or (ip_1 or hF) and (not hT and not ip_1) and (ip_1 and ip_1 and (ip_1 and not ip_1)) and (hT and ip_1 and (hN or hT) or not hT and not ip_1 and (not ic_1 and not hN))) then
    Window = Library:CreateWindow({
        Title = "Pickaxe Tycoon",
        Footer = "Tempo Hub",
        Icon = id,
        NotifySide = "Right",
        ShowCustomCursor = false,
        Center = true,
        AutoShow = true,
        Resizable = true,
        Size = UDim2.fromOffset(660, 640)
    })
else
    Window:CreateWindow({
        Title = "Pickaxe Tycoon",
        ShowCustomCursor = false,
        AutoShow = true,
        Center = true,
        Size = UDim2.fromOffset(660, 640),
        NotifySide = "Right",
        Resizable = true,
        Icon = Library,
        Footer = "Tempo Hub"
    })
end
pcall(fn507)
local ip_2 = { Main = Window:AddTab("Automation", "pickaxe"), Settings = Window:AddTab("Settings", "settings") }
h3 = function(aA)
    pcall(function()
        Library:Notify({ Title = "Tempo Hub", Description = aA, Time = 4 })
    end)
end
HelperModule = require(ReplicatedStorage:WaitForChild("HelperModule"))
h5 = fn536
hQ = fn381
hC = function(aU)
    local ju
    ju = nil
    ju = hQ()
    local jv = not ju or not aU or not aU:IsDescendantOf(workspace)
    if jv then
        return
    end
    pcall(function()
        firetouchinterest(ju, aU, 0)
        firetouchinterest(ju, aU, 1)
    end)
end
hZ = {}
hT = false
hN = fn450
if ((not hH_1 and hH_1 or (hy or hH_1) or hH_1 and not hH_1 and (hy and hy)) and (not hy and hy and (not hy or hy) or hy and hH_1 and (hy and hH_1)) or (not hH_1 and hy or (hH_1 or not hy)) and (hy and hy or (not hy or hy)) and ((not hy or hy or (not hH_1 or not hy)) and (hy or hy or hH_1 and not hH_1))) and not ((not hH_1 and hH_1 or (hy or hH_1) or hH_1 and not hH_1 and (hy and hy)) and (not hy and hy and (not hy or hy) or hy and hH_1 and (hy and hH_1)) or (not hH_1 and hy or (hH_1 or not hy)) and (hy and hy or (not hy or hy)) and ((not hy or hy or (not hH_1 or not hy)) and (hy or hy or hH_1 and not hH_1))) then
    h0 = false
    hu = false
    h8 = false
    h2 = false
else
    hu = false
    h8 = false
    h2 = false
    h0 = false
end
if (hR or not ij_1) and (hR and not hZ) and (hR and not hR or not ij_1 and hs) and not ((hR or not ij_1) and (hR and not hZ) and (hR and not hR or not ij_1 and hs)) then
    hy = false
else
    hY = false
end
hW = false
hR = false
hy = fn482
task.spawn(worker)
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(worker6)
task.spawn(worker7)
local AutomationGroup = ip_2.Main:AddLeftGroupbox("Automation", "zap")
fn122(AutomationGroup)
AutomationGroup:AddToggle("AutoPickup", { Text = "Auto Pickup Loot", Default = false, Callback = onAutoPickup })
AutomationGroup:AddToggle("AutoDeposit", { Text = "Auto Deposit", Default = false, Callback = onAutoDeposit })
AutomationGroup:AddToggle("AutoCollect", { Text = "Auto Collect Money", Default = false, Callback = onAutoCollect })
AutomationGroup:AddToggle("AutoMerge", { Text = "Auto Merge", Default = false, Callback = onAutoMerge })
AutomationGroup:AddToggle("AutoUpgrade", { Text = "Auto Upgrade", Default = false, Callback = onAutoUpgrade })
AutomationGroup:AddToggle("AutoOpenChests", { Text = "Auto Open Chests", Default = false, Callback = onAutoOpenChests })
AutomationGroup:AddToggle("AutoDismissChest", { Text = "Auto Dismiss Unaffordable Chest", Default = false, Callback = onAutoDismissChest })
hs = { "PurchasePromptApp", "RobloxPromptGui" }
h6 = {}
AutomationGroup:AddToggle("DisableRobloxPrompts", {
    Text = "Disable Roblox Prompt UI",
    Default = false,
    Callback = function(db)
        local CoreGui = game:GetService("CoreGui")
        if db then
            for i, v in ipairs(hs) do
                local kF = CoreGui:FindFirstChild(v)
                if kF then
                    kF.Enabled = false
                    if not h6[v] then
                        h6[v] = kF:GetPropertyChangedSignal("Enabled"):Connect(function()
                            if kF.Enabled then
                                kF.Enabled = false
                            end
                        end)
                    end
                end
            end
        else
            for k, v in pairs(h6) do
                v:Disconnect()
                h6[k] = nil
            end
            for i, v in ipairs(hs) do
                local kH = CoreGui:FindFirstChild(v)
                if kH then
                    kH.Enabled = true
                end
            end
        end
    end
})
local AutoBuyGroup = ip_2.Main:AddRightGroupbox("Auto Buy", "shopping-cart")
for i, v in ipairs(fn629()) do
    local iA = v
    AutoBuyGroup:AddToggle("AutoBuy" .. iA, {
        Text = "Auto Buy " .. iA,
        Default = false,
        Callback = function(ds)
            hZ[iA] = ds
        end
    })
end
local MenuGroup = ip_2.Settings:AddLeftGroupbox("Menu", "wrench")
fn122(MenuGroup)
hz = false
hx = nil
onIdled = function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end
task.spawn(function()
    while true do
        if hz then
            onIdled()
        end
        task.wait(60)
    end
end)
MenuGroup:AddToggle("AntiAfk", {
    Text = "Anti-AFK",
    Default = true,
    Callback = function(dD)
        hz = dD
        if dD then
            if not hx then
                hx = LocalPlayer.Idled:Connect(onIdled)
            end
        elseif hx then
            hx:Disconnect()
            hx = nil
        end
    end
})
hz = true
hx = LocalPlayer.Idled:Connect(onIdled)
MenuGroup:AddDivider()
MenuGroup:AddToggle("KeybindMenuOpen", {
    Text = "Open Keybind Menu",
    Default = false,
    Callback = function(dI)
        if Library.KeybindFrame then
            Library.KeybindFrame.Visible = dI
        end
    end
})
MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = false,
    Callback = function(dK)
        Library.ShowCustomCursor = dK
    end
})
MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Notification Side",
    Callback = function(dM)
        Library:SetNotifySide(dM)
    end
})
MenuGroup:AddDropdown("DPIScale", {
    Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "100%",
    Text = "UI Scale",
    Callback = function(dO)
        dO = dO:gsub("%%", "")
        Library:SetDPIScale(tonumber(dO))
    end
})
MenuGroup:AddSlider("UICornerSlider", {
    Text = "Corner Radius",
    Default = Library.CornerRadius,
    Min = 0,
    Max = 20,
    Rounding = 0,
    Callback = function(dQ)
        Window:SetCornerRadius(dQ)
    end
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton({
    Text = "Unload",
    Func = function()
        Library:Unload()
    end
})
pcall(function()
    Library.ToggleKeybind = Options.MenuKeybind
end)
if io_1 then
    io_1:SetLibrary(Library)
end
if hF then
    local ia_2 = 2
    repeat
        local mh = bit32.rrotate(bit32.bxor(bit32.lrotate(ia_2, 22), string.byte(tostring(ia_2))), 26)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(mh, 4273989277), 1578449942), (bit32.bxor(bit32.band(mh, 20978018), 2638981373))), 1578449942), 2638981373) == mh then
            hF:SetLibrary(Library)
            hF:IgnoreThemeSettings()
            hF:SetIgnoreIndexes({ "MenuKeybind" })
            hF:SetFolder("TempoHub/PickaxeTycoon")
        else
            Library:SetLibrary(hF)
            Library:IgnoreThemeSettings()
            Library:SetIgnoreIndexes({ "MenuKeybind" })
            Library:SetFolder("TempoHub/PickaxeTycoon")
        end
        ia_2 = (ia_2 + 5) % 8
    until (ia_2 * 3 + 2) % 8 == 7
end
if io_1 then
    io_1:SetFolder("TempoHub")
end
if hF then
    hF:BuildConfigSection(ip_2.Settings)
end
if io_1 then
    io_1:AddThemeOptions(ip_2.Settings)
end
if hF then
    pcall(function()
        hF:LoadAutoloadConfig()
    end)
end
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TempoToggle"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local ia_3 = gethui and gethui()
local ic_3 = ia_3 or game:GetService("CoreGui")
imageButton, hX, Position2, Position, hI = nil, nil, nil, nil, nil
screenGui.Parent = ic_3
imageButton = Instance.new("ImageButton")
imageButton.Size = UDim2.fromOffset(52, 52)
imageButton.Position = UDim2.fromScale(0.5, 0.04)
imageButton.AnchorPoint = Vector2.new(0.5, 0)
imageButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
imageButton.BackgroundTransparency = 0.1
imageButton.Image = hG
imageButton.ScaleType = Enum.ScaleType.Fit
imageButton.AutoButtonColor = true
imageButton.Parent = screenGui
local uICorner = Instance.new("UICorner")
uICorner.CornerRadius = UDim.new(0, 12)
uICorner.Parent = imageButton
local uIStroke = Instance.new("UIStroke")
uIStroke.Color = Color3.fromRGB(80, 80, 95)
uIStroke.Thickness = 1
uIStroke.Transparency = 0.3
uIStroke.Parent = imageButton
local uIPadding = Instance.new("UIPadding")
uIPadding.PaddingTop = UDim.new(0, 6)
uIPadding.PaddingBottom = UDim.new(0, 6)
uIPadding.PaddingLeft = UDim.new(0, 6)
uIPadding.PaddingRight = UDim.new(0, 6)
uIPadding.Parent = imageButton
hX, Position2, Position, hI = false, nil, nil, false
imageButton.InputBegan:Connect(onInputBegan)
UserInputService.InputChanged:Connect(onInputChanged)
UserInputService.InputEnded:Connect(onInputEnded)
imageButton.MouseButton1Click:Connect(onMouseButton1Click)
local ij_2 = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
hJ, screenGui2 = nil, nil
hJ = ij_2
screenGui2 = Instance.new("ScreenGui")
if (screenGui2 or false or (screenGui2 or not hJ)) and (screenGui2 or not hJ and false) or not ((screenGui2 or false or (screenGui2 or not hJ)) and (screenGui2 or not hJ and false)) then
    screenGui2.Name = "TempoPromo"
    screenGui2.ResetOnSpawn = false
    screenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
else
    screenGui2.Name = "TempoPromo"
    screenGui2.ResetOnSpawn = false
    screenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
end
local ia_5 = gethui and gethui()
local ib_2 = ia_5 or game:GetService("CoreGui")
screenGui2.Parent = ib_2
local function ia_6(ez, eA)
    local textButton = Instance.new("TextButton")
    local ld = hJ and UDim2.fromOffset(150, 40)
    local le = ld or UDim2.fromOffset(240, 60)
    textButton.Size = le
    textButton.Position = ez
    textButton.AnchorPoint = eA
    textButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    textButton.BackgroundTransparency = 0
    textButton.Text = ""
    textButton.AutoButtonColor = true
    textButton.Parent = screenGui2
    local uICorner = Instance.new("UICorner")
    uICorner.CornerRadius = UDim.new(0, 8)
    uICorner.Parent = textButton
    local uIStroke = Instance.new("UIStroke")
    uIStroke.Color = Color3.fromRGB(80, 80, 95)
    uIStroke.Thickness = 1
    uIStroke.Transparency = 0.3
    uIStroke.Parent = textButton
    local le_1 = hJ and 24
    local lk = if le_1 then 1 else 0
    local li = 416 * lk + 1084 * (1 - lk)
    local lj = 2612 * lk + 1094 * (1 - lk)
    if not ((li * 1370 + lj * 368 + li * lj) % 16777213 == 2617728) then
        le_1 = 36
    end
    local ld_4 = le_1
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Size = UDim2.fromOffset(ld_4, ld_4)
    local new = UDim2.new
    local lg = hJ and 8 or 12
    imageLabel.Position = new(0, lg, 0.5, 0)
    imageLabel.AnchorPoint = Vector2.new(0, 0.5)
    imageLabel.BackgroundTransparency = 1
    imageLabel.Image = hG
    imageLabel.ScaleType = Enum.ScaleType.Fit
    imageLabel.Parent = textButton
    local le_3 = hJ and 40
    local lk_1 = if le_3 then 1 else 0
    local li_1 = 3717 * lk_1 + 1176 * (1 - lk_1)
    local lj_1 = 221 * lk_1 + 2264 * (1 - lk_1)
    if not ((li_1 * 2744 + lj_1 * 2329 + li_1 * lj_1) % 16777213 == 11535614) then
        le_3 = 60
    end
    local ld_7 = le_3
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -ld_7, 1, 0)
    textLabel.Position = UDim2.new(0, ld_7, 0, 0)
    textLabel.BackgroundTransparency = 1
    local lf_1 = hJ and "Join Tempo\n[Copy Discord]" or "Join Tempo\nFree Keyless & Dupe Scripts\n[Click to Copy Discord]"
    textLabel.Text = lf_1
    textLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    local lf_2 = hJ and 10 or 12
    textLabel.TextSize = lf_2
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = textButton
    textButton.MouseButton1Click:Connect(function()
        pcall(function()
            setclipboard(hK)
        end)
        h3("Tempo Discord copied to clipboard!")
    end)
end
if hJ then
    local ib_3 = 2
    repeat
        if ib_3 * 59228055 + 4 + 3 >= ib_3 * 59228055 + 4 + 3 + 2 then
            ia_6(UDim2.new(0, 12, 0.55, 0), Vector2.new(0, 0.5))
        else
            ia_6(UDim2.new(0, 12, 0.55, 0), Vector2.new(0, 0.5))
        end
        ib_3 = (ib_3 + 2) % 4
    until (ib_3 * 3 + 3) % 4 == 3
else
    local ic_4 = 3
    repeat
        if (ic_4 * 3 + 7) * 9 % 4 == ((ic_4 * 3 + 7) * 9 + 12) % 4 then
            ia_6(UDim2.new(0, 18, 0.86, 0), Vector2.new(0, 0.5))
            ia_6(UDim2.new(1, -18, 0.86, 0), Vector2.new(1, 0.5))
        else
            ia_6(UDim2.new(0, 18, 0.86, 0), Vector2.new(0, 0.5))
            ia_6(UDim2.new(1, -18, 0.86, 0), Vector2.new(1, 0.5))
        end
        ic_4 = (ic_4 + 0) % 8
    until (ic_4 * 5 + 0) % 8 == 7
end
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TempoMarketplace"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local ia_7 = gethui and gethui()
local ib_4 = ia_7 or game:GetService("CoreGui")
frame5 = nil
screenGui.Parent = ib_4
frame5 = Instance.new("Frame")
local ia_8 = hJ
if ia_8 then
    local ib_5 = 1
    repeat
        local ic_5 = {
            "uegn",
            "ipoahhbe",
            "ddq",
            "las",
            "mpxqkfhbq",
            "oqochzrtk",
            "xwbynongi",
            "bjfwrpdows",
            "vzblohogl",
            "rvpisozrw",
            "qnir",
            "ybc",
            "murkqeson",
            "sflzohxpkok",
            "rrfylzp"
        }
        if ic_5[(ib_5 * 16 + 60) % 15 + 1] < ic_5[(ib_5 * 16 + 60) % 15 + 1] then
            ia_8 = UDim2.fromOffset(170, 100)
        else
            ia_8 = UDim2.fromOffset(170, 100)
        end
        ib_5 = (ib_5 + 6) % 8
    until (ib_5 * 3 + 2) % 8 == 7
end
local ic_6 = ia_8
if not ic_6 then
    local ia_9 = 1
    repeat
        local ib_6 = {
            "xrdekjwd",
            "jhtvretyrp",
            "xncwsojuonhp",
            "udpcj",
            "ehfipu",
            "kbjxturfy",
            "xvvpm",
            "pitl",
            "arna",
            "wom",
            "gsrtuawam",
            "jwgwhlcn",
            "ximtup",
            "yzmy",
            "hxl",
            "xrctmbnmd"
        }
        if ib_6[(ia_9 * 74 + 109) % 16 + 1] <= ib_6[(ia_9 * 74 + 109) % 16 + 1] then
            ic_6 = UDim2.fromOffset(240, 140)
        else
            ic_6 = UDim2.fromOffset(240, 140)
        end
        ia_9 = (ia_9 + 0) % 8
    until (ia_9 * 3 + 4) % 8 == 7
end
uIStroke2, imageLabel2, textLabel3, hD = nil, nil, nil, nil
frame5.Size = ic_6
frame5.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame5.BackgroundTransparency = 0
frame5.Visible = false
frame5.Parent = screenGui
local uICorner = Instance.new("UICorner")
uICorner.CornerRadius = UDim.new(0, 8)
uICorner.Parent = frame5
uIStroke2 = Instance.new("UIStroke")
uIStroke2.Color = Color3.fromRGB(80, 80, 95)
uIStroke2.Thickness = 1
uIStroke2.Transparency = 0.3
uIStroke2.Parent = frame5
imageLabel2 = Instance.new("ImageLabel")
imageLabel2.Size = UDim2.fromOffset(40, 40)
imageLabel2.Position = UDim2.new(0, 15, 0, 15)
imageLabel2.BackgroundTransparency = 1
imageLabel2.Image = hG
imageLabel2.ScaleType = Enum.ScaleType.Fit
imageLabel2.Parent = frame5
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, -70, 0, 20)
textLabel.Position = UDim2.new(0, 65, 0, 15)
textLabel.BackgroundTransparency = 1
textLabel.Text = "Tempo Market"
textLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
textLabel.TextSize = 14
textLabel.Font = Enum.Font.GothamBold
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.Parent = frame5
local textLabel2 = Instance.new("TextLabel")
textLabel2.Size = UDim2.new(1, -70, 0, 15)
textLabel2.Position = UDim2.new(0, 65, 0, 35)
textLabel2.BackgroundTransparency = 1
textLabel2.Text = "Trade. Sell. Profit."
textLabel2.TextColor3 = Color3.fromRGB(150, 150, 150)
textLabel2.TextSize = 11
textLabel2.Font = Enum.Font.GothamMedium
textLabel2.TextXAlignment = Enum.TextXAlignment.Left
textLabel2.Parent = frame5
textLabel3 = Instance.new("TextLabel")
textLabel3.Size = UDim2.new(1, -30, 0, 60)
textLabel3.Position = UDim2.new(0, 15, 0, 65)
textLabel3.BackgroundTransparency = 1
textLabel3.Text = "Got spare items piling up? Turn your grind into actual profit.\n\nClick to join the biggest trading community around!"
textLabel3.TextColor3 = Color3.fromRGB(190, 190, 190)
textLabel3.TextSize = 11
textLabel3.Font = Enum.Font.Gotham
textLabel3.TextXAlignment = Enum.TextXAlignment.Left
textLabel3.TextYAlignment = Enum.TextYAlignment.Top
textLabel3.TextWrapped = true
textLabel3.Parent = frame5
local textButton = Instance.new("TextButton")
textButton.Size = UDim2.new(1, 0, 1, 0)
textButton.BackgroundTransparency = 1
textButton.Text = ""
textButton.Parent = frame5
textButton.MouseEnter:Connect(onMouseEnter)
textButton.MouseLeave:Connect(onMouseLeave)
textButton.MouseButton1Click:Connect(onMouseButton1Click2)
hD = fn408
if (not textLabel or textLabel or textLabel and textLabel) and (textLabel or textLabel or not textButton and not textButton) or not ((not textLabel or textLabel or textLabel and textLabel) and (textLabel or textLabel or not textButton and not textButton)) then
    RunService.RenderStepped:Connect(onRenderStepped)
else
    RunService.RenderStepped:Connect(onRenderStepped)
end
end)(...)

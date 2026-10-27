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
getgenv().TempoHoodSubtitle = "ROLL FOR CHIIKAWA !"
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
local rN_13
local km
local k4
local j3
local Workspace
local k7
local Label
local kP
local kw
local j9
local kS
local kc
local kf
local kC
local VirtualUser
local k0
local k3
local kI
local Toggles
local Options
local kL
local kr
local j5
local k9
local TirarRuleta
local j8
local kb
local kU
local ke
local HttpService
local ChiikawaData
local kh
local UserInputService
local kk
local k2
local connection2
local LocalPlayer
local kn
local j4
local k5
local k8
local SaveManager
local connection
local kt
local ka
local ShinyUtil
local j1
local worker
local kT
local kg
local kZ
local kD
local kj
local k1
local function fn10()
    local qM = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local qN = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if qN then
                local qN_1 = kc(k, v)
                if qN_1 then
                    qM[#qM + 1] = qN_1
                end
            end
        end
    end
    table.sort(qM, function(gm, gn)
        if gm.type ~= gn.type then
            return gm.type < gn.type
        end
        return gm.idx < gn.idx
    end)
    return { objects = qM }
end
local function onCopySolanaAddress()
    k1(j3, "Copied Solana address")
end
local function placeBestDelayLoop()
    while not ke.Unloaded do
        if kP("AutoPlaceBest") then
            pcall(worker)
        end
        local rB = Options.PlaceBestDelay.Value or 1
        task.wait(math.max(rB, 0.1))
    end
end
local function fn40(aM)
    local mp = Options[aM]
    local mq = mp and mp.Value
    if typeof(mq) ~= "table" then
        return {}
    end
    local mq_1 = true
    local mr = {}
    for k in mq do
        if type(k) ~= "number" then
            mq_1 = false
            break
        end
    end
    if mq_1 then
        for i, v in ipairs(mq) do
            if type(v) == "string" then
                mr[v] = true
            end
        end
        return mr
    end
    return mq
end
local function onCopyJoinScript_JobID()
    local pB = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, j1)
    if setclipboard then
        setclipboard(pB)
    elseif toclipboard then
        toclipboard(pB)
    end
    ke:Notify("Copied join script to clipboard")
end
local function antiGameplayPauseLoop()
    while not ke.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            kn(true)
        end
    end
end
local function fn175(dY)
    local DiscordGroup = dY:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = kT })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = kT })
end
local function onStepped()
    if ke.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local pW_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if pW_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function onRscripts()
    if setclipboard then
        setclipboard(kC)
    elseif toclipboard then
        toclipboard(kC)
    end
    ke:Notify("Copied Rscripts profile to clipboard")
end
local function fn213()
    kn(Toggles.AntiGameplayPause.Value)
end
local function fn217()
    local na = {}
    local ChiikawasObtenidos = LocalPlayer:FindFirstChild("ChiikawasObtenidos")
    if ChiikawasObtenidos then
        for i, child in ipairs(ChiikawasObtenidos:GetChildren()) do
            local nb_1 = k3[child.Name]
            if nb_1 then
                na[child.Name] = nb_1
            end
        end
    end
    for i, v in ipairs(kU) do
        local nb_2 = LocalPlayer:FindFirstChild(v.carpeta)
        if nb_2 then
            for i, child in ipairs(nb_2:GetChildren()) do
                local nb_3 = k3[child.Name]
                if nb_3 then
                    local nc = ShinyUtil.ValorVariante(child.Name, v.clave)
                    na[nc] = nb_3 * v.mult
                end
            end
        end
    end
    return na
end
local function onCopyEthereumAddress()
    k1(j9, "Copied Ethereum address")
end
local function worker3()
    while not ke.Unloaded do
        if kP("AutoCraft") then
            pcall(kt)
        end
        task.wait(0.6)
    end
end
local function onImportConfigFromClipboardTex()
    local re_1
    local rc = Options.SaveManager_ImportSource.Value
    local rc_1
    local ri = if rc then 1 else 0
    local rg = 2899 * ri + 2465 * (1 - ri)
    local rh = 2364 * ri + 1095 * (1 - ri)
    if not ((rg * 1327 + rh * 1817 + rg * rh) % 16777213 == 14995597) then
        rc = ""
    end
    local rd = tostring(rc):match("^%s*(.-)%s*$")
    if rd == "" then
        ke:Notify("Paste an exported config into the box first")
        return
    end
    rc_1, re_1 = pcall(HttpService.JSONDecode, HttpService, rd)
    local rd_1 = not rc_1 or type(re_1) ~= "table" or type(re_1.objects) ~= "table"
    if rd_1 then
        ke:Notify("That is not a valid exported config")
        return
    end
    local rc_2 = 0
    for i, v in ipairs(re_1.objects) do
        if kw(v) then
            rc_2 += 1
        end
    end
    if rc_2 == 0 then
        ke:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local re_2 = rc_2 == 1 and "" or "s"
    ke:Notify(("Imported %d setting%s"):format(rc_2, re_2), 6)
end
local function fn323()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local mT = leaderstats and leaderstats:FindFirstChild("Rebirths")
    local mS_1 = mT
    if mT then
        mT = mS_1.Value
    end
    return mT or 0
end
local function fn330()
    local Map = Workspace:FindFirstChild("Map")
    local mW = Map and Map:FindFirstChild("BASES")
    if not mW then
        return nil
    end
    for i, child in ipairs(mW:GetChildren()) do
        if tostring(child:GetAttribute("DuenoUserId")) == tostring(LocalPlayer.UserId) then
            return child
        end
    end
    return nil
end
local function fn336()
    local m4_1
    local m3_1
    m3_1, m4_1 = pcall(function()
        return TirarRuleta:InvokeServer()
    end)
    local m5 = m3_1 and type(m4_1) == "table" and m4_1.noDinero
    if m5 then
        return "nodinero"
    end
    return "ok"
end
local function onJumpRequest()
    if ke.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local p9_1 = kb()
        if p9_1 then
            p9_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function onExportConfigToClipboard()
    local q9_1
    local q8_1
    q8_1, q9_1 = pcall(HttpService.JSONEncode, HttpService, k5())
    if not q8_1 then
        ke:Notify("Failed to encode the config")
        return
    end
    local q8_2 = setclipboard or toclipboard
    local q8_3 = type(q8_2) ~= "function" or not pcall(q8_2, q9_1)
    if q8_3 then
        ke:Notify("Your executor does not support copying to the clipboard")
        return
    end
    ke:Notify("Config copied to clipboard", 6)
end
local function rebirthSavesLoop()
    while not ke.Unloaded do
        if kP("AutoRebirth") then
            local rw = Options.RebirthSaves.Value or 2
            pcall(kZ, rw)
        end
        if kP("AutoUpgrade") then
            pcall(k8)
        end
        if kP("AutoUnlockSlots") then
            pcall(j4)
        end
        task.wait(0.5)
    end
end
local function fn441()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    kh = tick()
end
local function onCopyPayPalLink()
    k1(k7, "Copied PayPal link")
end
local function fn500(ci)
    local ChiikawasObtenidos = LocalPlayer:FindFirstChild("ChiikawasObtenidos")
    if not ChiikawasObtenidos then
        return nil
    end
    local ChiikawasConPadlock = LocalPlayer:FindFirstChild("ChiikawasConPadlock")
    local oa = ChiikawaData.RarezasPermanentes or {}
    local n9_1 = {}
    for i, child in ipairs(ChiikawasObtenidos:GetChildren()) do
        local n7_1 = ka[child.Name]
        local oa_1 = ChiikawasConPadlock and ChiikawasConPadlock:FindFirstChild(child.Name) ~= nil
        local oc = n7_1
        if oc then
            oc = not oa[n7_1]
        end
        if oc and not oa_1 then
            n9_1[#n9_1 + 1] = child.Name
        end
    end
    table.sort(n9_1, function(cw, cx)
        return (kj[ka[cw]] or 0) > (kj[ka[cx]] or 0)
    end)
    if #n9_1 < 2 then
        return nil
    end
    local n7_3 = {}
    local n8_1 = math.min(ci, #n9_1)
    local ot = 1
    while ot <= n8_1 do
        local ou = ot
        n7_3[ou] = n9_1[ou]
        ot += 1
    end
    return n7_3
end
local function fn525(f0, f1)
    local qC_1 = (f0 == "Toggle" and Toggles or Options)[f1]
    local qB_2 = type(qC_1) == "table" and qC_1.Type == f0
    return qB_2 and qC_1 or nil
end
local function onInputChanged(fT)
    local UserInputType = fT.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        kk = tick()
    end
end
local function fn541()
    if not Toggles.Fly.Value then
        local pO = kb()
        if pO then
            pO.PlatformStand = false
        end
    end
end
local function onCopyLitecoinAddress()
    k1(kg, "Copied Litecoin address")
end
local function worker2()
    local pH_1
    while true do
        task.wait(1)
        if ke.Unloaded then
            break
        end
        local pG = math.floor(os.clock() - kS)
        if pG < 60 then
            pH_1 = pG .. "s"
        elseif pG < 3600 then
            pH_1 = string.format("%dm %ds", math.floor((pG) / (60)), pG % 60)
        else
            pH_1 = string.format("%dh %dm", math.floor((pG) / (3600)), math.floor((pG % 3600) / (60)))
        end
        Label:SetText(kD("Session time", pH_1, km))
    end
end
local function onInputBegan()
    kk = tick()
end
local function fn563()
    if Toggles.AutoPlaceBest.Value then
        task.spawn(worker)
    end
end
local function onCopyVenmoLink()
    k1(k2, "Copied Venmo link")
end
local function onRenderStepped(fq)
    if ke.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local qe_1 = kb()
        if qe_1 then
            qe_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local qe_3 = k4()
        local qf = kb()
        k0 = Workspace.CurrentCamera or k0
        if qe_3 and qf and k0 then
            qf.PlatformStand = true
            local qf_1 = Vector3.zero
            local ql = if UserInputService:IsKeyDown(Enum.KeyCode.W) then 1 else 0
            if ql == 1 then
                qf_1 = qf_1 + k0.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                qf_1 = qf_1 - k0.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                qf_1 = qf_1 - k0.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                qf_1 = qf_1 + k0.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                qf_1 = qf_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                qf_1 = qf_1 - Vector3.new(0, 1, 0)
            end
            qe_3.Velocity = Vector3.zero
            if qf_1.Magnitude > 0 then
                qe_3.CFrame = qe_3.CFrame + qf_1.Unit * Options.FlySpeed.Value * fq
            end
        end
    end
end
local function fn658(aI)
    local mj = Toggles[aI]
    return mj ~= nil and mj.Value == true
end
local function fn685(cS)
    local oD_1
    local oC_1
    oC_1, oD_1 = cS:match("([%d%.]+)%s*([KMBT]?)%)")
    local oE = oC_1 and tonumber(oC_1)
    if not oE then
        return nil
    end
    local oE_1 = ({ K = 1000, M = 1000000, B = 1000000000, T = 1000000000000 })[oD_1]
    local oL = if oE_1 then 1 else 0
    local oJ = 1502 * oL + 256 * (1 - oL)
    local oK = 1776 * oL + 3826 * (1 - oL)
    if not ((oJ * 1936 + oK * 740 + oJ * oK) % 16777213 == 6889664) then
        oE_1 = 1
    end
    return oE * oE_1
end
local function worker4()
    while not ke.Unloaded do
        task.wait(2)
        if kP("AntiAfk") then
            local rE = tick() - kk
            local rF = tick() - kh
            if rE >= 300 and rF >= 60 then
                pcall(k9)
            else
                if rE < 300 and rF >= 300 then
                    pcall(k9)
                end
            end
        end
    end
end
local function fn695()
    local pu_1
    local pt_1
    if identifyexecutor then
        pu_1, pt_1 = identifyexecutor()
        local pv = pu_1 ~= ""
        local pw = type(pu_1) == "string" and pv
        if pw then
            local pv_1 = type(pt_1) == "string" and pt_1 ~= "" and pu_1 .. " " .. pt_1
            kr = pv_1 or pu_1
        end
    end
end
local function fn726()
    local Character = LocalPlayer.Character
    local mH = Character and Character:FindFirstChildOfClass("Humanoid")
    return mH
end
local function fn740()
    if not Toggles.WalkSpeedEnabled.Value then
        local pQ = kb()
        if pQ then
            pQ.WalkSpeed = 16
        end
    end
end
local function fn741(M, N)
    return string.format('<font color="%s">%s</font>', N, M)
end
local function fn760()
    local Character = LocalPlayer.Character
    local mK = Character and Character:FindFirstChild("HumanoidRootPart")
    return mK
end
local function fn771()
    k1(kI, "Copied Discord invite to clipboard")
end
local function fn774(F, G)
    if setclipboard then
        setclipboard(F)
    elseif toclipboard then
        toclipboard(F)
    end
    ke:Notify(G)
end
local function onCopyUSDTAddress()
    k1(j8, "Copied USDT address")
end
local function rollDelayLoop()
    while not ke.Unloaded do
        if kP("AutoRoll") then
            local rp = j5()
            if rp == "nodinero" then
                task.wait(0.5)
            else
                local wait = task.wait
                local rr = Options.RollDelay.Value or 0
                wait(math.max(rr, 0.05))
            end
        else
            task.wait(0.25)
        end
    end
end
local function fn830(f8, f9)
    local Type = f9.Type
    if Type == "Toggle" then
        return { idx = f8, type = "Toggle", value = f9.Value == true }
    elseif Type == "Slider" then
        return { idx = f8, type = "Slider", value = tostring(f9.Value) }
    elseif Type == "Dropdown" then
        return { idx = f8, type = "Dropdown", multi = f9.Multi == true, value = f9.Value }
    elseif Type == "Input" then
        local qG = f9.Value or ""
        return { idx = f8, type = "Input", text = tostring(qG) }
    elseif Type == "ColorPicker" then
        return { idx = f8, type = "ColorPicker", value = f9.Value:ToHex(), transparency = f9.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = f8,
            type = "KeyPicker",
            mode = f9.Mode,
            key = f9.Value,
            modifiers = f9.Modifiers,
            toggled = f9.Toggled
        }
    else
        return nil
    end
end
local function onCopyBitcoinAddress()
    k1(kf, "Copied Bitcoin address")
end
local function fn841(P, Q, R)
    return string.format("<b>%s</b> %s %s", P, kL("-", "#5a6070"), kL(Q, R))
end
local function onUnload()
    ke:Unload()
end
local function fn882()
    connection:Disconnect()
    connection2:Disconnect()
    kn(false)
    local rI = kb()
    if rI then
        rI.PlatformStand = false
        rI.WalkSpeed = 16
    end
end
local function fn885()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local mQ = leaderstats and leaderstats:FindFirstChild("Money")
    local mP_1 = mQ
    if mQ then
        mQ = mP_1.Value
    end
    return mQ or 0
end
j1 = nil
Toggles = nil
j3 = nil
j4 = nil
j5 = nil
Label = nil
SaveManager = nil
j8 = nil
j9 = nil
ka = nil
kb = nil
kc = nil
worker = nil
ke = nil
kf = nil
kg = nil
kh = nil
kj = nil
kk = nil
km = nil
kn = nil
kr = nil
kt = nil
TirarRuleta = nil
kw = nil
ShinyUtil = nil
ChiikawaData = nil
kC = nil
kD = nil
connection2 = nil
kI = nil
LocalPlayer = nil
kL = nil
Workspace = nil
kP = nil
local Craftear, EquiparChiikawa, ComprarMejora, kp, kq, HacerRebirth, ky, RebirthConfig, kA, kE, kF, kG, kJ, CoreGui, kO
connection = nil
kS = nil
kT = nil
kU = nil
HttpService = nil
VirtualUser = nil
kZ = nil
UserInputService = nil
k0 = nil
k1 = nil
k2 = nil
k3 = nil
k4 = nil
k5 = nil
Options = nil
k7 = nil
k8 = nil
k9 = nil
local GuiService, kV, kW, li, lj, ll, lm, ln, lv, lw, lx
GuiService = nil
kV = nil
kW = nil
local UpgradesGroup
UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, LocalPlayer, kI, kC, ChiikawaData, RebirthConfig, ShinyUtil, TirarRuleta, HacerRebirth, ComprarMejora, EquiparChiikawa, Craftear, ke, SaveManager, Toggles, Options, km, kg, kf, j9, j8, j3, k7, k2, kJ, kE, kA, k1, kT, kL, kD = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local rN_9 = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ld_2
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
LocalPlayer = rN_9.LocalPlayer
local lk = "Roll for Chiikawa"
kI = "https://discord.gg/K7Qxnxkk46"
kC = "https://discord.gg/K7Qxnxkk46"
ChiikawaData = require(ReplicatedStorage:WaitForChild("ChiikawaData"))
RebirthConfig = require(ReplicatedStorage:WaitForChild("RebirthConfig"))
ShinyUtil = require(ReplicatedStorage:WaitForChild("ShinyUtil"))
TirarRuleta = ReplicatedStorage:WaitForChild("TirarRuleta")
HacerRebirth = ReplicatedStorage:WaitForChild("HacerRebirth")
ComprarMejora = ReplicatedStorage:WaitForChild("ComprarMejora")
EquiparChiikawa = ReplicatedStorage:WaitForChild("EquiparChiikawa")
Craftear = ReplicatedStorage:WaitForChild("Craftear")
ke = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = ke.Toggles
Options = ke.Options
k1 = fn774
kT = fn771
kL = fn741
kD = fn841
local lh = "#7fd47f"
local lg = "#6ec1ff"
km = "#e8a34d"
local lf = "#8b93a3"
kg = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
kf = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
j9 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
j8 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
j3 = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
k7 = ""
k2 = ""
local lr = "#345d9d"
local lq = "#f7931a"
local lp = "#627eea"
local lo = "#26a17b"
if (not TirarRuleta or false) or not (not TirarRuleta or false) then
    ln = "#14f195"
    lm = "#0070ba"
    ll = "#008cff"
else
    ll = "#14f195"
    ln = "#0070ba"
    lm = "#008cff"
end
if (UserInputService or VirtualUser) and false and (not UserInputService or lk or not CoreGui and CoreGui) or not ((UserInputService or VirtualUser) and false and (not UserInputService or lk or not CoreGui and CoreGui)) then
    kJ = { Luck = "Suerte", Speed = "Velocidad", Rolls = "Rolls" }
    lj = { "Luck", "Speed", "Rolls" }
    kE = { Suerte = 15, Velocidad = 15, Rolls = 2 }
    li = {}
else
    lj = { Speed = "Velocidad", Rolls = "Rolls", Luck = "Suerte" }
    kJ = { "Rolls", "Luck", "Speed" }
    li = { Rolls = 2, Suerte = 15, Velocidad = 15 }
    kE = {}
end
if (not UserInputService and false and (Options or UserInputService) and (Options or not CoreGui or (false or CoreGui)) or (false and not rN_9 or Options and j3) and (not CoreGui or rN_9 or (j3 or UserInputService))) and ((false or UserInputService and CoreGui) and (rN_9 or not rN_9 or (false or Options)) or (false and (j3 or not Options) or j3 and rN_9 and (not CoreGui and not UserInputService))) and not ((not UserInputService and false and (Options or UserInputService) and (Options or not CoreGui or (false or CoreGui)) or (false and not rN_9 or Options and j3) and (not CoreGui or rN_9 or (j3 or UserInputService))) and ((false or UserInputService and CoreGui) and (rN_9 or not rN_9 or (false or Options)) or (false and (j3 or not Options) or j3 and rN_9 and (not CoreGui and not UserInputService)))) then
    ke = {}
else
    kA = {}
end
rN_9 = require(ReplicatedStorage:WaitForChild("CrafteoConfig"))
for i, v in ipairs(rN_9.Cadena) do
    rN_9 = v.De .. " -> " .. v.A
    li[#li + 1] = rN_9
    kA[rN_9] = i
end
rN_13, kj = nil, nil
local rN_4 = 1
repeat
    rN_9 = {
        "orlcpqh",
        "vympq",
        "wnmcmhuu",
        "jnzaexzqs",
        "tasxnblnlau",
        "qima",
        "zsodsj",
        "lmfg",
        "kovqsk",
        "jxnughh",
        "zamkyauca"
    }
    local sC = rN_4
    local ld_1 = rN_9[sC % 11 + 1]
    if ld_1:len() >= ld_1:gsub("(.)", "%1%1", sC % 3 % 2 + 1):len() then
        kj = { "Glitch", "Void", "Shiny", "Gold", "Normal" }
        rN_13 = {}
    else
        rN_13 = { "Normal", "Shiny", "Gold", "Void", "Glitch" }
        kj = {}
    end
    rN_4 = (rN_4 + 1) % 4
until (rN_4 * 1 + 1) % 4 == 3
rN_9 = {}
local rN_4_1 = ChiikawaData.OrdenRarezas or rN_9
for i, v in ipairs(rN_4_1) do
    kj[v] = i
end
ka = {}
rN_9 = {}
local rN_4_2 = ChiikawaData.Chiikawas or rN_9
for i, v in ipairs(rN_4_2) do
    rN_9 = type(v) == "table" and v.Nombre
    if rN_9 then
        ka[v.Nombre] = v.Rareza
    end
end
k3 = {}
rN_9 = {}
local rN_4_3 = ChiikawaData.Chiikawas
local lR = if rN_4_3 then 1 else 0
local lP = 2102 * lR + 3973 * (1 - lR)
local lQ = 3840 * lR + 1322 * (1 - lR)
if not ((lP * 1530 + lQ * 954 + lP * lQ) % 16777213 == 14951100) then
    rN_4_3 = rN_9
end
for i, v in ipairs(rN_4_3) do
    rN_9 = type(v) == "table" and v.Nombre
    if rN_9 then
        rN_9 = v.Nombre
        local rN_4_4 = v.Genera or 0
        k3[rN_9] = rN_4_4
    end
end
kU, lv, kP, kF, kb, k4, kV, kG, kq, j5, kW, worker, kO, kZ, kp, j4, k8, kt = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
kU = {
    { clave = "Shiny", carpeta = "ChiikawasShinyObtenidos", mult = 2 },
    { clave = "Gold", carpeta = "ChiikawasGoldObtenidos", mult = 3 },
    { clave = "Void", carpeta = "ChiikawasVoidObtenidos", mult = 5 },
    { clave = "Glitch", carpeta = "ChiikawasGlitchObtenidos", mult = 10 }
}
kP = fn658
kF = fn40
kb = fn726
k4 = fn760
kV = fn885
kG = fn323
kq = fn330
if ((not lv or not lv) and (lv and not k8) or (kO or not lv or (kO or k8))) and ((not k8 and not lv or (not kO or lv)) and (not lv and not k8 and (kO or not k8))) and ((kO or k8 or not kO and kO) and ((not lv or not lv) and (kO or not lv)) or kO and not kO and (not kO or kO) and (not lv or k8 or kO and k8)) and not (((not lv or not lv) and (lv and not k8) or (kO or not lv or (kO or k8))) and ((not k8 and not lv or (not kO or lv)) and (not lv and not k8 and (kO or not k8))) and ((kO or k8 or not kO and kO) and ((not lv or not lv) and (kO or not lv)) or kO and not kO and (not kO or kO) and (not lv or k8 or kO and k8))) then
    kP = fn336
else
    j5 = fn336
end
kW = fn217
worker = function()
    local nE_1
    local Slots = LocalPlayer:FindFirstChild("Slots")
    if not Slots then
        return
    end
    if LocalPlayer:GetAttribute("EquipBestOn") == true then
        return
    end
    local nA = kW()
    local nB = {}
    local nC = {}
    for i, child in ipairs(Slots:GetChildren()) do
        if child:IsA("StringValue") then
            nC[#nC + 1] = child
            if child.Value ~= "" then
                nB[child.Value] = true
            end
        end
    end
    local nz_1 = {}
    for k, v in pairs(nA) do
        if not nB[k] then
            nz_1[#nz_1 + 1] = { valor = k, genera = v }
        end
    end
    table.sort(nz_1, function(bV, bW)
        return bV.genera > bW.genera
    end)
    local nD = 1
    for i, v in ipairs(nC) do
        local nw
        local nY = v
        if nD > #nz_1 then
            break
        elseif nY.Value == "" then
            nw = nz_1[nD]
            pcall(function()
                EquiparChiikawa:FireServer(nY.Name, nw.valor)
            end)
            task.wait(0.08)
            if nY.Value == nw.valor then
                nB[nw.valor] = true
                nD += 1
            end
        end
    end
    local nQ = false
    repeat
        local nx
        if nD <= #nz_1 then
            local ny = nz_1[nD]
            nx, nE_1 = nil, nil
            for i, v in ipairs(nC) do
                if v.Value ~= "" then
                    local nF = nA[v.Value] or 0
                    if nF < ny.genera and (not nE_1 or nF < nE_1) then
                        nx = v
                        nE_1 = nF
                    end
                end
            end
            if not nx then
                nQ = true
            else
                local Value = nx.Value
                pcall(function()
                    EquiparChiikawa:FireServer(nx.Name, ny.valor)
                end)
                task.wait(0.08)
                if nx.Value == ny.valor then
                    nB[Value] = nil
                    nB[ny.valor] = true
                end
                nD += 1
            end
        else
            nQ = true
        end
    until nQ
end
kO = fn500
kZ = function(cE)
    local ow, ox
    ow = 0
    pcall(function()
        ow = RebirthConfig.precio(kG())
    end)
    local oB = if kV() < ow then 1 else 0
    if oB == 1 then
        return
    end
    ox = kO(cE)
    if not ox then
        return
    end
    pcall(function()
        HacerRebirth:InvokeServer(ox)
    end)
end
if (not kb or not k4) and (not k4 or kb) or (k4 or kb) and (k4 and not kb) or k4 and not kb and (k4 and k4) and (not kb and not k4 and (not k4 or not k4)) or not ((not kb or not k4) and (not k4 or kb) or (k4 or kb) and (k4 and not kb) or k4 and not kb and (k4 and k4) and (not kb and not k4 and (not k4 or not k4))) then
    kp = fn685
end
if (kW and 5 or (kW or 5) or (not kW or 5) or 5) and ((kW and (kW or false) or (kW or not kW) and false) and ((kW or not kW) and 5)) and not ((kW and 5 or (kW or 5) or (not kW or 5) or 5) and ((kW and (kW or false) or (kW or not kW) and false) and ((kW or not kW) and 5))) then
    k8 = function()
        local oN
        local CFrame
        CFrame = nil
        oN = nil
        if type(fireproximityprompt) ~= "function" then
            return
        end
        local oO = kq()
        if not oO then
            return
        end
        oN = k4()
        if not oN then
            return
        end
        local oP = kV()
        local oQ = {}
        for i, descendant in ipairs(oO:GetDescendants()) do
            local oO_5 = descendant:IsA("ProximityPrompt") and descendant.Enabled
            if oO_5 then
                local oO_6 = tostring(descendant.ActionText)
                local oR = string.find(oO_6, "Unlock", 1, true) and not string.find(oO_6, "Robux", 1, true)
                if oR then
                    local Parent = descendant.Parent
                    local oS = kp(oO_6)
                    local oO_7 = Parent and Parent:IsA("BasePart") and oS and oP >= oS
                    if oO_7 then
                        oQ[#oQ + 1] = { prompt = descendant, part = Parent }
                    end
                end
            end
        end
        if #oQ == 0 then
            return
        end
        CFrame = oN.CFrame
        for i, v in ipairs(oQ) do
            local o7 = v
            local oO_8 = ke.Unloaded or not kP("AutoUnlockSlots")
            if oO_8 then
                break
            end
            oN.CFrame = o7.part.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.1)
            pcall(function()
                fireproximityprompt(o7.prompt)
            end)
            task.wait(0.15)
        end
        pcall(function()
            oN.CFrame = CFrame
        end)
    end
    j4 = function()
        local Mejoras = LocalPlayer:FindFirstChild("Mejoras")
        if not Mejoras then
            return
        end
        local pa = kF("UpgradeChoice")
        for k, v in pa do
            if v then
                local o8 = kJ[k]
                local pa_3 = o8 and Mejoras:FindFirstChild(o8)
                if pa_3 then
                    if pa_3.Value < (kE[o8] or 15) then
                        pcall(function()
                            ComprarMejora:FireServer(o8)
                        end)
                    end
                end
            end
        end
    end
else
    j4 = function()
        local oN
        local CFrame
        CFrame = nil
        oN = nil
        if type(fireproximityprompt) ~= "function" then
            return
        end
        local oO = kq()
        if not oO then
            return
        end
        oN = k4()
        if not oN then
            return
        end
        local oP = kV()
        local oQ = {}
        for i, descendant in ipairs(oO:GetDescendants()) do
            local oO_1 = descendant:IsA("ProximityPrompt") and descendant.Enabled
            if oO_1 then
                local oO_2 = tostring(descendant.ActionText)
                local oR = string.find(oO_2, "Unlock", 1, true) and not string.find(oO_2, "Robux", 1, true)
                if oR then
                    local Parent = descendant.Parent
                    local oS = kp(oO_2)
                    local oO_3 = Parent and Parent:IsA("BasePart") and oS and oP >= oS
                    if oO_3 then
                        oQ[#oQ + 1] = { prompt = descendant, part = Parent }
                    end
                end
            end
        end
        if #oQ == 0 then
            return
        end
        CFrame = oN.CFrame
        for i, v in ipairs(oQ) do
            local o7 = v
            local oO_4 = ke.Unloaded or not kP("AutoUnlockSlots")
            if oO_4 then
                break
            end
            oN.CFrame = o7.part.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.1)
            pcall(function()
                fireproximityprompt(o7.prompt)
            end)
            task.wait(0.15)
        end
        pcall(function()
            oN.CFrame = CFrame
        end)
    end
    k8 = function()
        local Mejoras = LocalPlayer:FindFirstChild("Mejoras")
        if not Mejoras then
            return
        end
        local pa = kF("UpgradeChoice")
        for k, v in pa do
            if v then
                local o8 = kJ[k]
                local pa_1 = o8 and Mejoras:FindFirstChild(o8)
                if pa_1 then
                    if pa_1.Value < (kE[o8] or 15) then
                        pcall(function()
                            ComprarMejora:FireServer(o8)
                        end)
                    end
                end
            end
        end
    end
end
kt = function()
    local pk, pl
    local CraftRecipe = Options.CraftRecipe
    local pm_3
    local pn = CraftRecipe and CraftRecipe.Value
    local pn_3
    local pn_1 = type(pn) == "string" and kA[pn]
    pk = pn_1
    if not pk then
        return
    end
    local CraftVariant = Options.CraftVariant
    pl = CraftVariant and CraftVariant.Value
    if type(pl) ~= "string" then
        pl = "Normal"
    end
    pm_3, pn_3 = pcall(function()
        return Craftear:InvokeServer(pk, pl)
    end)
    local po = pm_3 and type(pn_3) == "table" and pn_3.error == "cooldown"
    if po then
        task.wait(0.4)
    end
end
local lt = ke:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = kI, Copyable = true }, "|", lk },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
if (not k8 or not kq) and (kq or not k8) and (k8 or kq or not k8 and kW) or not ((not k8 or not kq) and (kq or not k8) and (k8 or kq or not k8 and kW)) then
    lv = {
        Info = lt:AddTab("Info", "info"),
        Main = lt:AddTab("Main", "gamepad-2"),
        Player = lt:AddTab("Player", "person-standing"),
        Settings = lt:AddTab("Settings", "settings")
    }
else
    lt = {
        Main = lv:AddTab("Main", "gamepad-2"),
        Info = lv:AddTab("Info", "info"),
        Settings = lv:AddTab("Settings", "settings"),
        Player = lv:AddTab("Player", "person-standing")
    }
end
lv.Rolling = lv.Main:AddSubTab("Rolling", "dices")
lv.Progress = lv.Main:AddSubTab("Progress", "trending-up")
lv.Crafting = lv.Main:AddSubTab("Crafting", "hammer")
local lu = fn175
for k, v in lv do
    if v ~= lv.Main then
        lu(v)
    end
end
kr, rN_9, lt, Label, j1, ld_2 = nil, nil, nil, nil, nil, nil
local rN_4_5 = 6
repeat
    lu = (rN_4_5 * 1 + 1) % 3 + 1
    if lu <= 2 then
        if lu <= 1 then
            if rN_4_5 * 123547841 + 1 + 1 <= rN_4_5 * 123547841 + 1 + 1 + 4 then
                ld_2 = #j1 > 18
            else
                j1 = #ld_2 > 18
            end
            rN_4_5 = (rN_4_5 + 7) % 24
        else
            if j1 or rN_4_5 or not j1 and j1 or (rN_4_5 and not j1 or not j1 and j1) or (j1 and not j1 or (rN_4_5 or j1)) and ((rN_4_5 or j1) and (j1 and not j1)) or not (j1 or rN_4_5 or not j1 and j1 or (rN_4_5 and not j1 or not j1 and j1) or (j1 and not j1 or (rN_4_5 or j1)) and ((rN_4_5 or j1) and (j1 and not j1))) then
                kr = "Unknown"
                pcall(fn695)
                rN_9 = lv.Info:AddLeftGroupbox("Account", "circle-user")
                rN_9:AddLabel(kD("User", LocalPlayer.Name, lh), true)
                rN_9:AddLabel(kD("Status", "Keyless", lh), true)
                rN_9:AddLabel(kD("Executor", kr, lh), true)
                lt = lv.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                lt:AddLabel(kL(lk .. " [" .. tostring(game.PlaceId) .. "]", lg), true)
                lt:AddLabel(kD("Place ID", tostring(game.PlaceId), lg), true)
                Label = lt:AddLabel(kD("Session time", "0s", km), true)
            else
                km = "Unknown"
                pcall(fn695)
                lv = kr.Info:AddLeftGroupbox("Account", "circle-user")
                lv:AddLabel(rN_9("User", Label.Name, LocalPlayer), true)
                lv:AddLabel(rN_9("Status", "Keyless", LocalPlayer), true)
                lv:AddLabel(rN_9("Executor", km, LocalPlayer), true)
                lk = kr.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                lk:AddLabel(kD(kL .. " [" .. tostring(game.PlaceId) .. "]", lt), true)
                lk:AddLabel(rN_9("Place ID", tostring(game.PlaceId), lt), true)
                lh = lk:AddLabel(rN_9("Session time", "0s", lg), true)
            end
            rN_4_5 = (rN_4_5 + 1) % 24
        end
    else
        local sc = bit32.rrotate(bit32.bxor(bit32.lrotate(rN_4_5, 19), string.byte(tostring(ld_2))), 15)
        if bit32.bxor(bit32.lrotate(bit32.bxor(sc, 1540006242), 14), 2824378098) == bit32.lrotate(sc, 14) then
            j1 = tostring(game.JobId)
        else
            lt = tostring(game.JobId)
        end
        rN_4_5 = (rN_4_5 + 1) % 24
    end
until (rN_4_5 * 7 + 21) % 24 == 6
if ld_2 then
    rN_9 = 0
    repeat
        local rN_4_6 = (vector.create((rN_9 * 7 + 7) % 11 + 1, (rN_9 * 5 + 12) % 13 + 1, (rN_9 * 1 + 13) % 17 + 1))
        lu = (vector.create((rN_9 * 5 + 2) % 11 + 1, (rN_9 * 5 + 5) % 13 + 1, (rN_9 * 7 + 1) % 17 + 1))
        lw = (vector.create((rN_9 * 3 + 8) % 11 + 1, (rN_9 * 1 + 2) % 13 + 1, (rN_9 * 11 + 14) % 17 + 1))
        lx = (vector.create((rN_9 * 2 + 5) % 5 + 1, (rN_9 * 3 + 6) % 7 + 1, (rN_9 * 4 + 3) % 9 + 1))
        if vector.dot(vector.cross(rN_4_6, (vector.cross(lu, lw))), lx) == vector.dot(lu * vector.dot(rN_4_6, lw) - lw * vector.dot(rN_4_6, lu), lx) + 1 then
            j1 = string.sub(ld_2, 1, 18) .. "..."
        else
            ld_2 = string.sub(j1, 1, 18) .. "..."
        end
        rN_9 = (rN_9 + 0) % 4
    until (rN_9 * 1 + 3) % 4 == 3
end
rN_9 = ld_2 or j1
kS, UpgradesGroup, k0, kk, kh, connection, connection2, kn, k9, ky, kc, k5, kw = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local lK = rN_9
lt:AddLabel(kD("Server", lK, lf), true)
lt:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
kS = os.clock()
task.spawn(worker2)
local ScriptsGroup = lv.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(kL("Included in this hub", lf), true)
ScriptsGroup:AddLabel(kL(lk, lg), true)
local FeaturesGroup = lv.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(kL("Auto Roll", lg), true)
FeaturesGroup:AddLabel(kL("Auto Rebirth", km), true)
FeaturesGroup:AddLabel(kL("Auto Upgrade / Unlock Slots", lh), true)
FeaturesGroup:AddLabel(kL("Auto Craft", lg), true)
FeaturesGroup:AddLabel(kL("Misc Utilities", lf), true)
local SocialsGroup = lv.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = kT })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = lv.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = kT })
local rN_4_7 = lv.Info:AddRightGroupbox("Donations", "heart")
rN_4_7:AddLabel(kL("All donations are optional but appreciated.", km), true)
rN_4_7:AddLabel(kL("If you donate you get a special role, just PING after you donate.", lh), true)
rN_4_7:AddDivider()
rN_4_7:AddLabel(kL("LTC / Litecoin", lr), true)
rN_4_7:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
rN_4_7:AddLabel(kL("BTC / Bitcoin", lq), true)
rN_4_7:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
rN_4_7:AddLabel(kL("ETH / Ethereum", lp), true)
rN_4_7:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
rN_4_7:AddLabel(kL("USDT", lo), true)
rN_4_7:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
rN_4_7:AddLabel(kL("Solana", ln), true)
rN_4_7:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
rN_4_7:AddLabel(kL("PayPal", lm), true)
rN_4_7:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
rN_4_7:AddLabel(kL("Venmo", ll), true)
rN_4_7:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
rN_4_7:AddDivider()
rN_4_7:AddLabel(kL("Don't have any of the listed currencies but still wanna donate?", lf), true)
rN_4_7:AddLabel(kL("DM me and we'll work something out.", lg), true)
local FaqGroup = lv.Info:AddRightGroupbox("FAQ", "circle-help")
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
local RouletteGroup = lv.Rolling:AddLeftGroupbox("Roulette", "dices")
RouletteGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
RouletteGroup:AddSlider("RollDelay", { Text = "Roll Delay", Default = 0.3, Min = 0, Max = 3, Rounding = 2 })
local EquipGroup = lv.Rolling:AddRightGroupbox("Equip", "star")
EquipGroup:AddToggle("AutoPlaceBest", { Text = "Auto Place Best", Default = false })
EquipGroup:AddSlider("PlaceBestDelay", { Text = "Place Best Delay", Default = 1, Min = 0.1, Max = 10, Rounding = 1 })
local RebirthGroup = lv.Progress:AddLeftGroupbox("Rebirth", "rotate-ccw")
if ScriptsGroup and not UpgradesGroup and (not ScriptsGroup or not UpgradesGroup) or UpgradesGroup and ScriptsGroup and (not UpgradesGroup and not ScriptsGroup) or not (ScriptsGroup and not UpgradesGroup and (not ScriptsGroup or not UpgradesGroup) or UpgradesGroup and ScriptsGroup and (not UpgradesGroup and not ScriptsGroup)) then
    RebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
    RebirthGroup:AddSlider("RebirthSaves", { Text = "Chiikawas To Save", Default = 2, Min = 2, Max = 3, Rounding = 0 })
    UpgradesGroup = lv.Progress:AddRightGroupbox("Upgrades", "arrow-big-up")
else
    UpgradesGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
    UpgradesGroup:AddSlider("RebirthSaves", { Text = "Chiikawas To Save", Default = 2, Rounding = 0, Max = 3, Min = 2 })
    lv = RebirthGroup.Progress:AddRightGroupbox("Upgrades", "arrow-big-up")
end
UpgradesGroup:AddToggle("AutoUpgrade", { Text = "Auto Upgrade", Default = false })
UpgradesGroup:AddDropdown("UpgradeChoice", { Text = "Upgrades To Buy", Values = lj, Default = {}, Multi = true, AllowNull = true })
local BaseGroup = lv.Progress:AddLeftGroupbox("Base", "grid-2x2")
BaseGroup:AddToggle("AutoUnlockSlots", { Text = "Auto Unlock Slots", Default = false })
local CraftGroup = lv.Crafting:AddLeftGroupbox("Craft", "hammer")
CraftGroup:AddToggle("AutoCraft", { Text = "Auto Craft", Default = false })
CraftGroup:AddDropdown("CraftRecipe", { Text = "Recipe", Values = li, Default = li[1] })
CraftGroup:AddDropdown("CraftVariant", { Text = "Variant", Values = rN_13, Default = "Normal" })
lx = lv.Player:AddLeftGroupbox("Movement", "footprints")
lx:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
lx:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
lx:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
lx:AddToggle("NoClip", { Text = "NoClip", Default = false })
lx:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
lw = lv.Player:AddRightGroupbox("Fly", "feather")
lw:AddToggle("Fly", { Text = "Fly", Default = false })
lw:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
kn = function(eT)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not eT)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not eT
        end
    end)
    if not eT then
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
Toggles.AntiGameplayPause:OnChanged(fn213)
Toggles.Fly:OnChanged(fn541)
Toggles.WalkSpeedEnabled:OnChanged(fn740)
Toggles.AutoPlaceBest:OnChanged(fn563)
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
k0 = Workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
lu = lv.Settings:AddLeftGroupbox("Menu")
lu:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
ke.ToggleKeybind = Options.MenuKeybind
kk = tick()
kh = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local qs = v
        pcall(function()
            qs:Disable()
        end)
    end
end)
k9 = fn441
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
lu:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
lu:AddButton({ Text = "Unload", Func = onUnload })
ThemeManager:SetLibrary(ke)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Linoria")
SaveManager:SetLibrary(ke)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/roll-for-chiikawa")
local lE = SaveManager:BuildConfigSection(lv.Settings)
if (FaqGroup and not ScriptsGroup or k9 and FaqGroup or k0 and lE and (kh or not kh)) and not (FaqGroup and not ScriptsGroup or k9 and FaqGroup or k0 and lE and (kh or not kh)) then
    kc = fn525
else
    ky = fn525
end
kc = fn830
k5 = fn10
kw = function(gp)
    local q2
    q2 = nil
    local q3 = type(gp) ~= "table" or type(gp.idx) ~= "string" or type(gp.type) ~= "string"
    local q7 = if q3 then 1 else 0
    local q5 = 1831 * q7 + 2415 * (1 - q7)
    local q6 = 3586 * q7 + 2082 * (1 - q7)
    if not ((q5 * 1806 + q6 * 13 + q5 * q6) % 16777213 == 9919370) then
        q3 = SaveManager.Ignore[gp.idx]
    end
    if q3 then
        return false
    end
    q2 = ky(gp.type, gp.idx)
    if not q2 then
        return false
    end
    local q3_1 = pcall(function()
        if gp.type == "Input" then
            if type(gp.text) ~= "string" then
                return
            end
            q2:SetValue(gp.text)
        elseif gp.type == "ColorPicker" then
            q2:SetValueRGB(Color3.fromHex(gp.value), gp.transparency)
        elseif gp.type == "KeyPicker" then
            q2:SetValue({ gp.key, gp.mode, gp.modifiers })
            if gp.mode == "Toggle" and gp.toggled ~= nil then
                q2.Toggled = gp.toggled
                q2:Update()
            end
        else
            q2:SetValue(gp.value)
        end
    end)
    return q3_1
end
lE:AddDivider()
lE:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
lE:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
lE:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
ThemeManager:ApplyToTab(lv.Settings)
ThemeManager:LoadDefault()
SaveManager:LoadAutoloadConfig()
task.spawn(rollDelayLoop)
task.spawn(rebirthSavesLoop)
task.spawn(worker3)
task.spawn(placeBestDelayLoop)
task.spawn(antiGameplayPauseLoop)
task.spawn(worker4)
ke:OnUnload(fn882)
ke:Notify(lk .. " loaded")
end)(...)

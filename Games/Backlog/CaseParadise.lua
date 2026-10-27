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
getgenv().TempoHoodSubtitle = "CASE PARADISE"
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
local jW
local Options
local CurrentCamera
local jh
local jG
local jJ
local jn
local jq
local connection
local jt
local jP
local jw
local jS
local jz
local SaveManager
local jj
local Library
local jm
local LocalPlayer
local jp
local HttpService
local jO
local jR
local jv
local Toggles
local jf
local jB
local ji
local connection2
local jl
local jH
local jK
local jr
local VirtualUser
local ju
local UserInputService
local i8
local jx
local jb
local je
local function onRscripts()
    if setclipboard then
        setclipboard(ju)
    elseif toclipboard then
        toclipboard(ju)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function fn50(ab)
    for i, v in ipairs(jO) do
        if v == ab then
            return i
        end
    end
    return 0
end
local function fn59(fv, fw)
    local Type = fw.Type
    if Type == "Toggle" then
        return { idx = fv, type = "Toggle", value = fw.Value == true }
    elseif Type == "Slider" then
        return { idx = fv, type = "Slider", value = tostring(fw.Value) }
    elseif Type == "Dropdown" then
        return { idx = fv, type = "Dropdown", multi = fw.Multi == true, value = fw.Value }
    elseif Type == "Input" then
        local n_ = fw.Value
        local n3 = if n_ then 1 else 0
        local n1 = 2881 * n3 + 2754 * (1 - n3)
        local n2 = 1098 * n3 + 221 * (1 - n3)
        if not ((n1 * 1326 + n2 * 3426 + n1 * n2) % 16777213 == 10745292) then
            n_ = ""
        end
        return { idx = fv, type = "Input", text = tostring(n_) }
    elseif Type == "ColorPicker" then
        return { idx = fv, type = "ColorPicker", value = fw.Value:ToHex(), transparency = fw.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = fv,
            type = "KeyPicker",
            mode = fw.Mode,
            key = fw.Value,
            modifiers = fw.Modifiers,
            toggled = fw.Toggled
        }
    else
        return nil
    end
end
local function fn100()
    local lc = jx()
    local ld = lc and lc:FindFirstChild("HumanoidRootPart")
    return ld
end
local function fn114(ag, ah)
    if setclipboard then
        setclipboard(ag)
    elseif toclipboard then
        toclipboard(ag)
    end
    Library:Notify(ah)
end
local function fn170()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    jl = tick()
end
local function onRenderStepped(el)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local nj_1 = jt()
        if nj_1 then
            nj_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local nj_3 = jm()
        local nk = jt()
        if nj_3 and nk then
            nk.PlatformStand = true
            local nk_1 = Vector3.zero
            local np = if UserInputService:IsKeyDown(Enum.KeyCode.W) then 1 else 0
            if np == 1 then
                nk_1 = nk_1 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                nk_1 = nk_1 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                nk_1 = nk_1 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                nk_1 = nk_1 + CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                nk_1 = nk_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                nk_1 = nk_1 - Vector3.new(0, 1, 0)
            end
            nj_3.Velocity = Vector3.zero
            if nk_1.Magnitude > 0 then
                nj_3.CFrame = nj_3.CFrame + nk_1.Unit * Options.FlySpeed.Value * el
            end
        end
    end
end
local function onInputChanged(e3)
    local UserInputType = e3.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        jp = tick()
    end
end
local function fn196(T, U)
    return T.price > U.price
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local nh_1 = jt()
        if nh_1 then
            nh_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn278()
    return LocalPlayer.Character
end
local function onCopyEthereumAddress()
    jR(jn, "Copied Ethereum address")
end
local function fn325()
    if not Toggles.WalkSpeedEnabled.Value then
        local ns = jt()
        if ns then
            ns.WalkSpeed = 16
        end
    end
end
local function onCopyBitcoinAddress()
    jR(jq, "Copied Bitcoin address")
end
local function fn331()
    local lg_1
    local lf_1
    if identifyexecutor then
        lg_1, lf_1 = identifyexecutor()
        local lh = lg_1 ~= ""
        local li = type(lg_1) == "string" and lh
        if li then
            local lh_1 = type(lf_1) == "string" and lf_1 ~= "" and lg_1 .. " " .. lf_1
            local lf_2 = lh_1
            local lm = if lf_2 then 1 else 0
            local lk = 1513 * lm + 3076 * (1 - lm)
            local ll = 693 * lm + 2517 * (1 - lm)
            if not ((lk * 1273 + ll * 2479 + lk * ll) % 16777213 == 4692505) then
                lf_2 = lg_1
            end
            jv = lf_2
        end
    end
end
local function fn398(aF, aG)
    return string.format('<font color="%s">%s</font>', aG, aF)
end
local function onCopyUSDTAddress()
    jR(jj, "Copied USDT address")
end
local function fn423()
    jJ(Toggles.AntiGameplayPause.Value)
end
local function worker()
    local lq_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local lp = math.floor(os.clock() - jP)
        if lp < 60 then
            lq_1 = lp .. "s"
        elseif lp < 3600 then
            lq_1 = string.format("%dm %ds", math.floor((lp) / (60)), lp % 60)
        else
            lq_1 = string.format("%dh %dm", math.floor((lp) / (3600)), math.floor((lp % 3600) / (60)))
        end
        jh:SetText(jK("Session time", lq_1, jz))
    end
end
local function onExportConfigToClipboard()
    local oz_1
    local oy_1
    oy_1, oz_1 = pcall(HttpService.JSONEncode, HttpService, jB())
    if not oy_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local oy_2 = setclipboard or toclipboard
    local oy_3 = type(oy_2) ~= "function" or not pcall(oy_2, oz_1)
    if oy_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local nR = tick() - jp
            local nS = tick() - jl
            if nR >= 300 and nS >= 60 then
                pcall(i8)
            else
                if nR < 300 and nS >= 300 then
                    pcall(i8)
                end
            end
        end
    end
end
local function onImportConfigFromClipboardTex()
    local oH_1
    local oF = Options.SaveManager_ImportSource.Value or ""
    local oF_1
    local oG = tostring(oF):match("^%s*(.-)%s*$")
    if oG == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    oF_1, oH_1 = pcall(HttpService.JSONDecode, HttpService, oG)
    local oG_1 = not oF_1 or type(oH_1) ~= "table" or type(oH_1.objects) ~= "table"
    if oG_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local oF_2 = 0
    for i, v in ipairs(oH_1.objects) do
        if jW(v) then
            oF_2 += 1
        end
    end
    if oF_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local oH_2 = oF_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(oF_2, oH_2), 6)
end
local function fn510()
    local k6 = jx()
    local k7 = k6 and k6:FindFirstChildOfClass("Humanoid")
    return k7
end
local function onCopyLitecoinAddress()
    jR(jr, "Copied Litecoin address")
end
local function onInputBegan()
    jp = tick()
end
local function onCopySolanaAddress()
    jR(ji, "Copied Solana address")
end
local function fn551(an)
    local DiscordGroup = an:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = jH })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = jH })
end
local function onUnload()
    Library:Unload()
end
local function fn579()
    if not Toggles.Fly.Value then
        local nq = jt()
        if nq then
            nq.PlatformStand = false
        end
    end
end
local function fn653()
    connection:Disconnect()
    connection2:Disconnect()
    jJ(false)
    select("#", "Unloaded!")
end
local function onCopyJoinScript_JobID()
    local ln = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, je)
    if setclipboard then
        setclipboard(ln)
    elseif toclipboard then
        toclipboard(ln)
    end
    Library:Notify("Copied join script to clipboard")
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            jJ(true)
        end
    end
end
local function fn675()
    jR(jw, "Copied Discord invite to clipboard")
end
local function fn719()
    local n8 = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local n9 = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if n9 then
                local n9_1 = jG(k, v)
                if n9_1 then
                    n8[#n8 + 1] = n9_1
                end
            end
        end
    end
    table.sort(n8, function(fI, fJ)
        if fI.type ~= fJ.type then
            return fI.type < fJ.type
        end
        return fI.idx < fJ.idx
    end)
    return { objects = n8 }
end
local function fn725(aI, aJ, aK)
    return string.format("<b>%s</b> %s %s", aI, jS("-", "#5a6070"), jS(aJ, aK))
end
local function onCopyPayPalLink()
    jR(jf, "Copied PayPal link")
end
local function fn791(fn, fo)
    local nW_1 = (fn == "Toggle" and Toggles or Options)[fo]
    local nV_2 = type(nW_1) == "table" and nW_1.Type == fn
    return nV_2 and nW_1 or nil
end
local function onCopyVenmoLink()
    jR(jb, "Copied Venmo link")
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local m6_1 = jx()
        if m6_1 then
            for i, descendant in ipairs(m6_1:GetDescendants()) do
                local m6_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if m6_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
i8 = nil
jb = nil
je = nil
jf = nil
jh = nil
ji = nil
jj = nil
jl = nil
jm = nil
jn = nil
jp = nil
jq = nil
jr = nil
jt = nil
ju = nil
jv = nil
jw = nil
jx = nil
Toggles = nil
jz = nil
Options = nil
jB = nil
SaveManager = nil
CurrentCamera = nil
connection2 = nil
Library = nil
jG = nil
jH = nil
LocalPlayer = nil
jJ = nil
jK = nil
HttpService = nil
connection = nil
VirtualUser = nil
jO = nil
jP = nil
UserInputService = nil
jR = nil
jS = nil
local ToggleBankTransfer, i9, Upgrade, Sell, jd, OpenCase, Upgrader, jo, Items, UpdateRewards, ReplicatedStorage
jW = nil
local ClaimCategoryIndex, j8, MenuGroup, ks
local j2_1, j2_2
local j9_7
ReplicatedStorage, UserInputService, VirtualUser, HttpService, LocalPlayer, Library, SaveManager, Options, Toggles, jw, ju, Items, Upgrader, OpenCase, Sell, Upgrade, ToggleBankTransfer, ClaimCategoryIndex, UpdateRewards, j2_1, jO = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
LocalPlayer = Players.LocalPlayer
local j6 = "Case Paradise"
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Options = Library.Options
Toggles = Library.Toggles
jw = "https://discord.gg/K7Qxnxkk46"
ju = "https://discord.gg/K7Qxnxkk46"
local Modules = ReplicatedStorage:WaitForChild("Modules")
local jZ_4
Items = require(Modules:WaitForChild("Items"))
local j4 = require(Modules:WaitForChild("Cases"))
local Rarities = require(Modules:WaitForChild("Rarities"))
local j1_2
Upgrader = require(Modules:WaitForChild("Upgrader"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AccountGroup
OpenCase = Remotes:WaitForChild("OpenCase")
Sell = Remotes:WaitForChild("Sell")
Upgrade = Remotes:WaitForChild("Upgrade")
ToggleBankTransfer = Remotes:WaitForChild("ToggleBankTransfer")
ClaimCategoryIndex = Remotes:WaitForChild("ClaimCategoryIndex")
UpdateRewards = Remotes:WaitForChild("UpdateRewards")
if (OpenCase or jO) and (jO and jO) and (not OpenCase and OpenCase and (jO or OpenCase)) or (OpenCase and jO or jO and jO or (OpenCase or not jO) and (not jO and jO)) or not ((OpenCase or jO) and (jO and jO) and (not OpenCase and OpenCase and (jO or OpenCase)) or (OpenCase and jO or jO and jO or (OpenCase or not jO) and (not jO and jO))) then
    j2_1 = {
        "Consumer Grade",
        "Industrial Grade",
        "Mil-Spec",
        "Restricted",
        "Classified",
        "Covert",
        "Extraordinary",
        "Contraband",
        "Special",
        "Money",
        "Machinegun"
    }
else
    jw = {
        "Covert",
        "Money",
        "Special",
        "Industrial Grade",
        "Consumer Grade",
        "Classified",
        "Machinegun",
        "Contraband",
        "Mil-Spec",
        "Extraordinary",
        "Restricted"
    }
end
jO = {}
local j3 = {}
for k in pairs(Rarities) do
    j3[k] = true
end
for i, v in ipairs(j2_1) do
    if j3[v] then
        table.insert(jO, v)
        j3[v] = nil
    end
end
for k in pairs(j3) do
    table.insert(jO, k)
end
if #jO == 0 then
    local jX_1 = 3
    repeat
        local jY_1 = {
            "tpsavjzzy",
            "nahjhztpckn",
            "pqywuqq",
            "qwb",
            "ujigx",
            "jskfzon",
            "dibzh",
            "icwvstn",
            "dyfvd",
            "lbh",
            "kimip"
        }
        local pY = jX_1
        local jZ_1 = jY_1[pY % 11 + 1]
        if jZ_1:len() <= jZ_1:gsub("(.)", "%1%1", pY % 3 % 2 + 1):len() then
            jO = {
                "Consumer Grade",
                "Industrial Grade",
                "Mil-Spec",
                "Restricted",
                "Classified",
                "Covert",
                "Extraordinary",
                "Contraband",
                "Special"
            }
        else
            jO = {
                "Mil-Spec",
                "Consumer Grade",
                "Covert",
                "Restricted",
                "Special",
                "Industrial Grade",
                "Contraband",
                "Classified",
                "Extraordinary"
            }
        end
        jX_1 = (jX_1 + 2) % 4
    until (jX_1 * 3 + 0) % 4 == 3
end
local jY_2 = {}
for k, v in pairs(j4) do
    local jZ_2 = v.Price or v.Cost or 0
    local insert = table.insert
    local j__1 = v.Name or "Case " .. tostring(k)
    insert(jY_2, { id = k, name = j__1, price = jZ_2 })
end
jo = nil
local j0 = 0
repeat
    local jX_4 = {
        "irnqf",
        "ayx",
        "oyehxlehd",
        "zcebuqcroyum",
        "xbsclhkuv",
        "pyk",
        "fkmncvj",
        "jgakbweuvzvk",
        "bpgntec",
        "qwtxlfxblba"
    }
    if jX_4[(j0 * 43 + 112) % 10 + 1] < jX_4[(j0 * 43 + 112) % 10 + 1] then
        table.sort(jo, fn196)
        jY_2 = {}
        j1_2 = {}
    else
        table.sort(jY_2, fn196)
        j1_2 = {}
        jo = {}
    end
    j0 = (j0 + 7) % 8
until (j0 * 7 + 5) % 8 == 6
for i, v in ipairs(jY_2) do
    local jX_5 = v.name .. " ($" .. tostring(v.price) .. ")"
    table.insert(j1_2, jX_5)
    jo[jX_5] = v.id
end
jd, jR, jH, jx, jt, jm = nil, nil, nil, nil, nil, nil
jd = fn50
jR = fn114
jH = fn675
jx = fn278
jt = fn510
jm = fn100
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = jw, Copyable = true }, "|", j6 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
j0 = {
    Info = Window:AddTab("Info", "info"),
    Farming = Window:AddTab("Farming", "download"),
    Inventory = Window:AddTab("Inventory", "package"),
    Upgrader = Window:AddTab("Upgrader", "arrow-up-circle"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
j0.Roll = j0.Farming:AddSubTab("Case Rolling", "repeat")
j0.Quests = j0.Farming:AddSubTab("Daily Quests", "gift")
j0.Sell = j0.Inventory:AddSubTab("Sell", "trash-2")
j0.Bank = j0.Inventory:AddSubTab("Bank", "archive")
for i, v in ipairs({ j0.Roll, j0.Quests, j0.Sell, j0.Bank, j0.Upgrader, j0.Player, j0.Settings }) do
    fn551(v)
end
j8, j4, jz, j3, jv, AccountGroup, j2_2, jh, je, jZ_4, jS, jK = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local jX_6 = 2
repeat
    local j__3 = (jX_6 * 1 + 3) % 8 + 1
    if j__3 <= 4 then
        if j__3 <= 2 then
            if j__3 <= 1 then
                local ph = bit32.rrotate(bit32.bxor(bit32.lrotate(jX_6, 20), string.byte(tostring(AccountGroup))), 29)
                if bit32.bxor(bit32.lrotate(bit32.bxor(ph, 2902059182), 18), 2730144743) ~= bit32.lrotate(ph, 18) then
                    jS = "#6ec1ff"
                else
                    j4 = "#6ec1ff"
                end
                jX_6 = (jX_6 + 17) % 32
            else
                local j9_1 = {
                    "dkwupuyjkg",
                    "uywrggwatvsq",
                    "wfh",
                    "zpyawy",
                    "rcfxqsrkcp",
                    "nzjewmaszm",
                    "xrxdrbbzl",
                    "avhyehozu",
                    "xxixwji",
                    "tbophhij"
                }
                if j9_1[(jX_6 * 39 + 6) % 10 + 1] <= j9_1[(jX_6 * 39 + 6) % 10 + 1] then
                    jz = "#e8a34d"
                else
                    jh = "#e8a34d"
                end
                jX_6 = (jX_6 + 9) % 32
            end
        elseif j__3 <= 3 then
            local qa = bit32.rrotate(bit32.bxor(bit32.lrotate(jX_6, 24), string.byte(tostring(jh))), 6)
            if bit32.bxor(bit32.lrotate(bit32.bxor(qa, 2511381910), 20), 1500076810) ~= bit32.lrotate(qa, 20) then
                jK = "#8b93a3"
                j8 = "Unknown"
                pcall(fn331)
                j0 = LocalPlayer.Info:AddLeftGroupbox("Account", "circle-user")
                j0:AddLabel(j3("User", jh.Name, j2_2), true)
                j0:AddLabel(j3("Status", "Keyless", j2_2), true)
                j0:AddLabel(j3("Executor", "Unknown", j2_2), true)
                j6 = LocalPlayer.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                j6:AddLabel(AccountGroup(jv .. " [" .. tostring(game.PlaceId) .. "]", jz), true)
                j6:AddLabel(j3("Place ID", tostring(game.PlaceId), jz), true)
                j4 = j6:AddLabel(j3("Session time", "0s", jS), true)
            else
                j3 = "#8b93a3"
                jv = "Unknown"
                pcall(fn331)
                AccountGroup = j0.Info:AddLeftGroupbox("Account", "circle-user")
                AccountGroup:AddLabel(jK("User", LocalPlayer.Name, j8), true)
                AccountGroup:AddLabel(jK("Status", "Keyless", j8), true)
                AccountGroup:AddLabel(jK("Executor", jv, j8), true)
                j2_2 = j0.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                j2_2:AddLabel(jS(j6 .. " [" .. tostring(game.PlaceId) .. "]", j4), true)
                j2_2:AddLabel(jK("Place ID", tostring(game.PlaceId), j4), true)
                jh = j2_2:AddLabel(jK("Session time", "0s", jz), true)
            end
            jX_6 = (jX_6 + 9) % 32
        else
            if jX_6 * 74973081 + 7 + 5 <= jX_6 * 74973081 + 7 + 5 + 5 then
                je = tostring(game.JobId)
            else
                j2_2 = tostring(game.JobId)
            end
            jX_6 = (jX_6 + 25) % 32
        end
    elseif j__3 <= 6 then
        if j__3 <= 5 then
            local j9_2 = (vector.create((jX_6 * 1 + 6) % 11 + 1, (jX_6 * 11 + 7) % 13 + 1, (jX_6 * 8 + 6) % 17 + 1))
            local ka_1 = (vector.create((jX_6 * 1 + 2) % 11 + 1, (jX_6 * 11 + 2) % 13 + 1, (jX_6 * 2 + 12) % 17 + 1))
            local qi = vector.cross(j9_2, ka_1)
            local qj = vector.dot(j9_2, ka_1)
            if vector.dot(qi, qi) + qj * qj == vector.dot(j9_2, j9_2) * vector.dot(ka_1, ka_1) + 4 then
                je = #jZ_4 > 18
            else
                jZ_4 = #je > 18
            end
            jX_6 = (jX_6 + 1) % 32
        else
            local j9_3 = {
                "hpncvqsxr",
                "vedscfoxkiw",
                "qbjtgavkekda",
                "qkdn",
                "yljb",
                "bdqyamfqtcj",
                "sqjfxefnnksh",
                "mcjoommnsct",
                "aymvz",
                "gdsmtbuzm",
                "cwaudqhkz",
                "ydvkemge",
                "kqxv"
            }
            if j9_3[(jX_6 * 1 + 77) % 13 + 1] < j9_3[(jX_6 * 1 + 77) % 13 + 1] then
                j3 = fn398
            else
                jS = fn398
            end
            jX_6 = (jX_6 + 25) % 32
        end
    elseif j__3 <= 7 then
        local j__4 = (vector.create((jX_6 * 4 + 2) % 11 + 1, (jX_6 * 1 + 10) % 13 + 1, (jX_6 * 14 + 9) % 17 + 1))
        local j9_4 = (vector.create((jX_6 * 2 + 8) % 11 + 1, (jX_6 * 2 + 9) % 13 + 1, (jX_6 * 2 + 14) % 17 + 1))
        local ka_2 = (vector.create((jX_6 * 5 + 1) % 11 + 1, (jX_6 * 1 + 5) % 13 + 1, (jX_6 * 10 + 3) % 17 + 1))
        local kb_1 = (vector.create((jX_6 * 1 + 2) % 5 + 1, (jX_6 * 1 + 2) % 7 + 1, (jX_6 * 1 + 6) % 9 + 1))
        if vector.dot(vector.cross(j__4, (vector.cross(j9_4, ka_2))), kb_1) == vector.dot(j9_4 * vector.dot(j__4, ka_2) - ka_2 * vector.dot(j__4, j9_4), kb_1) then
            jK = fn725
        else
            jv = fn725
        end
        jX_6 = (jX_6 + 25) % 32
    else
        local j__5 = (vector.create((jX_6 * 6 + 2) % 11 + 1, (jX_6 * 9 + 9) % 13 + 1, (jX_6 * 1 + 10) % 17 + 1))
        local j9_5 = (vector.create((jX_6 * 7 + 3) % 11 + 1, (jX_6 * 8 + 13) % 13 + 1, (jX_6 * 7 + 1) % 17 + 1))
        local ka_3 = (vector.create((jX_6 * 5 + 9) % 11 + 1, (jX_6 * 5 + 1) % 13 + 1, (jX_6 * 8 + 15) % 17 + 1))
        local kb_2 = (vector.create((jX_6 * 2 + 7) % 5 + 1, (jX_6 * 3 + 1) % 7 + 1, (jX_6 * 3 + 3) % 9 + 1))
        if vector.dot(vector.cross(j__5, (vector.cross(j9_5, ka_3))), kb_2) == vector.dot(j9_5 * vector.dot(j__5, ka_3) - ka_3 * vector.dot(j__5, j9_5), kb_2) + 1 then
            jS = "#7fd47f"
        else
            j8 = "#7fd47f"
        end
        jX_6 = (jX_6 + 9) % 32
    end
until (jX_6 * 19 + 1) % 32 == 15
if jZ_4 then
    local jX_7 = 4
    repeat
        local jY_5 = (vector.create((jX_7 * 7 + 4) % 11 + 1, (jX_7 * 5 + 2) % 13 + 1, (jX_7 * 14 + 5) % 17 + 1))
        local j__6 = (vector.create((jX_7 * 6 + 8) % 11 + 1, (jX_7 * 3 + 3) % 13 + 1, (jX_7 * 13 + 4) % 17 + 1))
        local j9_6 = (vector.create((jX_7 * 7 + 8) % 11 + 1, (jX_7 * 3 + 9) % 13 + 1, (jX_7 * 13 + 9) % 17 + 1))
        local ka_4 = (vector.create((jX_7 * 2 + 7) % 5 + 1, (jX_7 * 4 + 5) % 7 + 1, (jX_7 * 2 + 4) % 9 + 1))
        if vector.dot(vector.cross(jY_5, (vector.cross(j__6, j9_6))), ka_4) == vector.dot(j__6 * vector.dot(jY_5, j9_6) - j9_6 * vector.dot(jY_5, j__6), ka_4) + 2 then
            je = string.sub(jZ_4, 1, 18) .. "..."
        else
            jZ_4 = string.sub(je, 1, 18) .. "..."
        end
        jX_7 = (jX_7 + 6) % 8
    until (jX_7 * 5 + 4) % 8 == 6
end
local jX_8 = jZ_4 or je
jP, jr, jq, jn, jj, ji, jf, jb, ks, j9_7, CurrentCamera, MenuGroup, jp, jl, connection, connection2, jJ, i8, i9, jG, jB, jW = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
j2_2:AddLabel(jK("Server", jX_8, j3), true)
j2_2:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
jP = os.clock()
task.spawn(worker)
local ScriptsGroup = j0.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(jS("Included in this hub", j3), true)
ScriptsGroup:AddLabel(jS(j6, j4), true)
local FeaturesGroup = j0.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(jS("Auto Roll Cases", j4), true)
FeaturesGroup:AddLabel(jS("Daily Quests", j8), true)
FeaturesGroup:AddLabel(jS("Auto Sell & Bank", jz), true)
FeaturesGroup:AddLabel(jS("Auto Upgrade", j3), true)
local SocialsGroup = j0.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = jH })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = j0.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = jH })
jr = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
jq = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
jn = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
jj = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
ji = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
jf = ""
jb = ""
local jZ_5 = "#345d9d"
local kt = "#f7931a"
if ((false or not j9_7) and (j9_7 or not j9_7) and (not j9_7 and jn and false) or (jn or not j9_7 or false) and (not j9_7 or j9_7 or false)) and (j9_7 and jn and (j9_7 or jn) and (not j9_7 and false or (jn or j9_7)) and ((false and j9_7 or "0xaE95A405D007a6F858E5d35714111B075fEFb40a") and (j9_7 and j9_7 or (not j9_7 or not j9_7)))) or not (((false or not j9_7) and (j9_7 or not j9_7) and (not j9_7 and jn and false) or (jn or not j9_7 or false) and (not j9_7 or j9_7 or false)) and (j9_7 and jn and (j9_7 or jn) and (not j9_7 and false or (jn or j9_7)) and ((false and j9_7 or "0xaE95A405D007a6F858E5d35714111B075fEFb40a") and (j9_7 and j9_7 or (not j9_7 or not j9_7))))) then
    ks = "#627eea"
else
    kt = "#627eea"
end
local kr = "#26a17b"
local kq = "#14f195"
local ko = "#0070ba"
local kn = "#008cff"
local DonationsGroup = j0.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(jS("All donations are optional but appreciated.", jz), true)
DonationsGroup:AddLabel(jS("If you donate you get a special role, just PING after you donate.", j8), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(jS("LTC / Litecoin", jZ_5), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(jS("BTC / Bitcoin", kt), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(jS("ETH / Ethereum", ks), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(jS("USDT", kr), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(jS("Solana", kq), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(jS("PayPal", ko), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(jS("Venmo", kn), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(jS("Don't have any of the listed currencies but still wanna donate?", j3), true)
DonationsGroup:AddLabel(jS("DM me and we'll work something out.", j4), true)
local FaqGroup = j0.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutoRollCasesGroup = j0.Roll:AddLeftGroupbox("Auto Roll Cases", "repeat")
AutoRollCasesGroup:AddToggle("AutoRoll", { Text = "Auto Roll Cases", Default = false })
AutoRollCasesGroup:AddDropdown("SelectedCases", {
    Values = j1_2,
    Default = 1,
    Text = "Select Cases",
    Multi = true,
    Searchable = true,
    Expandable = true,
    ExpandColumns = 2,
    SelectAllButtons = true
})
AutoRollCasesGroup:AddSlider("RollInterval", { Text = "Roll Interval", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
AutoRollCasesGroup:AddSlider("RollQuantity", { Text = "Cases Per Roll", Default = 1, Min = 1, Max = 5, Rounding = 0, Suffix = "x" })
Toggles.AutoRoll:OnChanged(function()
    if not Toggles.AutoRoll.Value then
        return
    end
    task.spawn(function()
        while true do
            if Toggles.AutoRoll.Value and not Library.Unloaded then
                local Value = Options.SelectedCases.Value
                local lu = {}
                for k, v in pairs(Value) do
                    if v then
                        local lt_2 = jo[k]
                        if lt_2 then
                            table.insert(lu, lt_2)
                        end
                    end
                end
                if #lu == 0 then
                    task.wait(1)
                else
                    for i, v in ipairs(lu) do
                        local lH = v
                        if not Toggles.AutoRoll.Value or Library.Unloaded then
                            break
                        end
                        pcall(function()
                            OpenCase:InvokeServer(lH, Options.RollQuantity.Value, true, nil)
                        end)
                        task.wait(Options.RollInterval.Value)
                    end
                end
                continue
            end
            break
        end
    end)
end)
local ClaimRewardsGroup = j0.Quests:AddLeftGroupbox("Claim Rewards", "gift")
ClaimRewardsGroup:AddToggle("AutoClaimRewards", { Text = "Auto Claim Rewards", Default = false })
ClaimRewardsGroup:AddToggle("AutoClaimIndex", { Text = "Auto Claim Index", Default = false })
task.spawn(function()
    while not Library.Unloaded do
        task.wait(10)
        if Toggles.AutoClaimRewards.Value then
            pcall(function()
                local Gifts = ReplicatedStorage:WaitForChild("Gifts")
                local result = UpdateRewards:InvokeServer()
                local ClaimedGifts = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Windows"):WaitForChild("Rewards"):FindFirstChild("ClaimedGifts")
                for i, child in ipairs(Gifts:GetChildren()) do
                    local lU = child
                    if lU.Value - result <= 0 then
                        local lJ_2 = false
                        if ClaimedGifts then
                            local lM_1 = ClaimedGifts:FindFirstChild(lU.Name)
                            if lM_1 and lM_1.Value == true then
                                lJ_2 = true
                            end
                        end
                        if not lJ_2 then
                            local lJ_3 = pcall(function()
                                return UpdateRewards:InvokeServer(lU.Name)
                            end)
                            if lJ_3 and ClaimedGifts then
                                local lJ_4 = ClaimedGifts:FindFirstChild(lU.Name)
                                if lJ_4 then
                                    lJ_4.Value = true
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        task.wait(10)
        if Toggles.AutoClaimIndex.Value then
            pcall(function()
                local PlayerData = LocalPlayer:FindFirstChild("PlayerData")
                if PlayerData then
                    local Index = PlayerData:FindFirstChild("Index")
                    if Index then
                        for i, child in ipairs(Index:GetChildren()) do
                            local l3 = child
                            pcall(function()
                                ClaimCategoryIndex:FireServer(l3.Name)
                            end)
                        end
                    end
                end
            end)
        end
    end
end)
local AutoSellGroup = j0.Sell:AddLeftGroupbox("Auto Sell", "trash-2")
AutoSellGroup:AddToggle("AutoSell", { Text = "Auto Sell Weapons", Default = false })
AutoSellGroup:AddDropdown("SellRarity", { Values = jO, Default = 1, Text = "Sell Below Rarity", Multi = false, Searchable = true })
AutoSellGroup:AddSlider("SellInterval", { Text = "Sell Interval", Default = 2, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
Toggles.AutoSell:OnChanged(function()
    if not Toggles.AutoSell.Value then
        return
    end
    task.spawn(function()
        while true do
            if Toggles.AutoSell.Value and not Library.Unloaded then
                local Inventory = LocalPlayer:WaitForChild("PlayerData"):WaitForChild("Inventory")
                local l7 = jd(Options.SellRarity.Value)
                local l8 = {}
                for i, child in ipairs(Inventory:GetChildren()) do
                    local l6_2 = tostring(child)
                    local l9 = Items[l6_2]
                    if l9 then
                        local attr2 = child:GetAttribute("Locked")
                        local mb = not attr2
                        if mb ~= false then
                            mb = jd(l9.Rarity) <= l7
                        end
                        if mb then
                            local attr = child:GetAttribute("UUID")
                            if attr then
                                local insert = table.insert
                                local mb_1 = child:GetAttribute("Wear") or "FN"
                                local mc = child:GetAttribute("Stattrak") or false
                                local md = child:GetAttribute("TimeObtained") or 0
                                insert(l8, { Name = l6_2, Wear = mb_1, Stattrak = mc, Age = md, UUID = attr })
                            end
                        end
                    end
                end
                if #l8 > 0 then
                    local l6_3 = #l8
                    for i = 1, l6_3, 50 do
                        local l5
                        l5 = {}
                        local l6_4 = math.min(i + 49, #l8)
                        local mr = i
                        while mr <= l6_4 do
                            local ms = mr
                            table.insert(l5, l8[ms])
                            mr += 1
                        end
                        pcall(function()
                            Sell:InvokeServer(l5)
                        end)
                        task.wait(0.2)
                    end
                end
                task.wait(Options.SellInterval.Value)
                continue
            end
            break
        end
    end)
end)
local AutoBankGroup = j0.Bank:AddLeftGroupbox("Auto Bank", "archive")
AutoBankGroup:AddToggle("AutoBank", { Text = "Auto Bank Items", Default = false })
AutoBankGroup:AddDropdown("BankRarity", { Values = jO, Default = 5, Text = "Bank Above Rarity", Multi = false, Searchable = true })
AutoBankGroup:AddSlider("BankInterval", { Text = "Bank Interval", Default = 3, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
Toggles.AutoBank:OnChanged(function()
    if not Toggles.AutoBank.Value then
        return
    end
    task.spawn(function()
        local mC = false
        repeat
            if Toggles.AutoBank.Value and not Library.Unloaded then
                local Inventory = LocalPlayer:WaitForChild("PlayerData"):WaitForChild("Inventory")
                local mx = jd(Options.BankRarity.Value)
                local mv = {}
                for i, child in ipairs(Inventory:GetChildren()) do
                    local mw_2 = tostring(child)
                    local my = Items[mw_2]
                    if my then
                        local attr2 = child:GetAttribute("Locked")
                        local mz = not attr2
                        if mz ~= false then
                            mz = jd(my.Rarity) >= mx
                        end
                        if mz then
                            local attr = child:GetAttribute("UUID")
                            if attr then
                                table.insert(mv, attr)
                            end
                        end
                    end
                end
                if #mv > 0 then
                    pcall(function()
                        ToggleBankTransfer:FireServer(mv)
                    end)
                end
                task.wait(Options.BankInterval.Value)
            else
                mC = true
            end
        until mC
    end)
end)
local AutoUpgradeGroup = j0.Upgrader:AddLeftGroupbox("Auto Upgrade", "arrow-up-circle")
AutoUpgradeGroup:AddToggle("AutoUpgrade", { Text = "Auto Upgrade Items", Default = false })
AutoUpgradeGroup:AddSlider("UpgradeMinMultiplier", { Text = "Min Multiplier", Default = 2, Min = 1, Max = 10, Rounding = 1, Suffix = "x" })
AutoUpgradeGroup:AddSlider("UpgradeMaxCost", { Text = "Max Cost", Default = 1000, Min = 100, Max = 100000, Rounding = 0, Suffix = "$" })
AutoUpgradeGroup:AddSlider("UpgradeInterval", { Text = "Upgrade Interval", Default = 2, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
Toggles.AutoUpgrade:OnChanged(function()
    if not Toggles.AutoUpgrade.Value then
        return
    end
    task.spawn(function()
        local mZ = false
        repeat
            if Toggles.AutoUpgrade.Value and not Library.Unloaded then
                local Inventory = LocalPlayer:WaitForChild("PlayerData"):WaitForChild("Inventory")
                local Value2 = Options.UpgradeMinMultiplier.Value
                local Value = Options.UpgradeMaxCost.Value
                local mS = {}
                for i, child in ipairs(Inventory:GetChildren()) do
                    local mP_2 = tostring(child)
                    if Items[mP_2] and Upgrader[mP_2] then
                        local attr = child:GetAttribute("UUID")
                        if attr then
                            local mV = child:GetAttribute("Wear") or "FN"
                            local mW = child:GetAttribute("Stattrak") or false
                            table.insert(mS, { Id = mP_2, UUID = attr, Wear = mV, Stattrak = mW })
                        end
                    end
                end
                if #mS > 0 then
                    local mN = mS[1]
                    local mO = Upgrader[mN.Id]
                    if mO then
                        if (mO.Cost or 0) <= Value and (mO.Multiplier or 1) >= Value2 then
                            pcall(function()
                                local mK = { mN }
                                local mL = mO.Choice or 1
                                Upgrade:FireServer(mK, mL)
                            end)
                        end
                    end
                end
                task.wait(Options.UpgradeInterval.Value)
            else
                mZ = true
            end
        until mZ
    end)
end)
local MovementGroup = j0.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = j0.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn579)
Toggles.WalkSpeedEnabled:OnChanged(fn325)
jJ = function(eG)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not eG)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not eG
        end
    end)
    if not eG then
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
if ((jr or not jG or jG and jG) and (jG and jr and "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99") or (not CurrentCamera and jq or "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w" or (jG or not CurrentCamera) and (false and TempoHubGroup))) and ("LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w" and (false or jG) and (TempoHubGroup or jq or (TempoHubGroup or false)) or (false and (jq and CurrentCamera) or (not jG or not jG) and (TempoHubGroup or jG))) or not (((jr or not jG or jG and jG) and (jG and jr and "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99") or (not CurrentCamera and jq or "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w" or (jG or not CurrentCamera) and (false and TempoHubGroup))) and ("LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w" and (false or jG) and (TempoHubGroup or jq or (TempoHubGroup or false)) or (false and (jq and CurrentCamera) or (not jG or not jG) and (TempoHubGroup or jG)))) then
    Toggles.AntiGameplayPause:OnChanged(fn423)
    task.spawn(antiGameplayPauseLoop)
    MenuGroup = j0.Settings:AddLeftGroupbox("Menu", "menu")
else
    MenuGroup.AntiGameplayPause:OnChanged(fn423)
    task.spawn(antiGameplayPauseLoop)
    j0 = Toggles.Settings:AddLeftGroupbox("Menu", "menu")
end
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
jp = tick()
jl = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local nL = v
        pcall(function()
            nL:Disable()
        end)
    end
end)
i8 = fn170
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
task.spawn(antiAfkLoop)
Library:OnUnload(fn653)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Linoria")
ThemeManager:ApplyToTab(j0.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/CaseParadise")
local j__7 = SaveManager:BuildConfigSection(j0.Settings)
i9 = fn791
jG = fn59
jB = fn719
jW = function(fL)
    local ov
    ov = nil
    local ow = type(fL) ~= "table" or type(fL.idx) ~= "string" or type(fL.type) ~= "string" or SaveManager.Ignore[fL.idx]
    if ow then
        return false
    end
    ov = i9(fL.type, fL.idx)
    if not ov then
        return false
    end
    local ow_1 = pcall(function()
        if fL.type == "Input" then
            if type(fL.text) ~= "string" then
                return
            end
            ov:SetValue(fL.text)
        elseif fL.type == "ColorPicker" then
            ov:SetValueRGB(Color3.fromHex(fL.value), fL.transparency)
        elseif fL.type == "KeyPicker" then
            ov:SetValue({ fL.key, fL.mode, fL.modifiers })
            if fL.mode == "Toggle" and fL.toggled ~= nil then
                ov.Toggled = fL.toggled
                ov:Update()
            end
        else
            ov:SetValue(fL.value)
        end
    end)
    return ow_1
end
j__7:AddDivider()
j__7:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
j__7:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
j__7:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
end)(...)

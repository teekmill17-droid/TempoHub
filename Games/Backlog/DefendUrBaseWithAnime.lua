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
getgenv().TempoHoodSubtitle = "DEFEND UR BASE WITH ANIME"
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
local pC
local oC
local bodyVelocity
local o0
local Window
local oI
local LocalPlayer
local o6
local oO
local VirtualUser
local pc
local oU
local pB
local oB
local CloneCharactersDropdown
local o_
local pH
local oH
local BeerusSpin
local o5
local oN
local ClaimWish
local pb
local oT
local ph
local oZ
local RunService
local oG
local TraitCharactersDropdown
local pM
local oM
local pt
local connection2
local oS
local UserInputService
local oz
local bodyGyro
local pF
local oF
local pm
local o3
local Library
local oL
local connection4
local o9
local connection5
local connection
local oX
local pE
local Position
local connection3
local o2
local pK
local oK
local onDescendantAdded
local o8
local oQ
local px
local pe
local oW
local oD
local pJ
local connection6
local onIdled
local o7
local oP
local pw
local pd
local oV
local function onSuggestionInput(kr)
    oW = kr
end
local function fn48()
    local Character = LocalPlayer.Character
    local rD = Character and Character:FindFirstChild("HumanoidRootPart")
    return rD
end
local function fn65(bB, bC)
    for i, v in ipairs(bB) do
        if v == bC then
            return true
        end
    end
    return false
end
local function onMouseButton1Click()
    if oC then
        return
    end
    oH = not oH
    Window:Toggle(not oH)
end
local function fn244()
    local ru = ph and ph.Parent and ph:GetAttribute("Owner") == LocalPlayer.Name
    if ru then
        return ph
    end
    local Plots = workspace:FindFirstChild("Plots")
    if not Plots then
        return nil
    end
    for i, child in ipairs(Plots:GetChildren()) do
        if child:GetAttribute("Owner") == LocalPlayer.Name then
            ph = child
            return child
        end
    end
    return nil
end
local function fn253(aH, aI, aJ)
    Library:Notify({ Title = aH, Description = aI, Time = aJ })
end
local function fn286(a6)
    if a6 == nil or a6 == "" then
        return "None"
    end
    return tostring(a6)
end
local function fn306(bi)
    local rF = oS()
    if rF then
        rF.CFrame = bi
    end
end
local function fn323(q)
    table.insert(o_, q)
end
local function fn406(bG, bH, bI)
    local rO = bG.enabled and oU(bG.set, bG.value)
    if rO then
        return true
    end
    local rO_1 = false
    if bH.enabled then
        local rO_2 = true
        if not oU(bH.set, bH.value) then
            return false
        elseif bI.enabled then
            local rO_3 = true
            local rS_1 = if not oU(bI.set, bI.value) then 1 else 0
            if rS_1 == 1 then
                return false
            end
            return rO_3
        else
            return rO_2
        end
    elseif bI.enabled then
        local rO_4 = true
        local rS_2 = if not oU(bI.set, bI.value) then 1 else 0
        if rS_2 == 1 then
            return false
        end
        return rO_4
    else
        return rO_1
    end
end
local function fn587(aM)
    local rl_1, rl_2, rl_3
    local rk_1, rk_2, rk_3
    local rm = getrenv and getrenv().require
    if rm then
        rk_1, rl_1 = pcall(getrenv().require, aM)
        if rk_1 and rl_1 then
            return rl_1
        end
        rk_2, rl_2 = pcall(require, aM)
        if rk_2 and rl_2 then
            return rl_2
        end
        return nil
    end
    rk_3, rl_3 = pcall(require, aM)
    if rk_3 and rl_3 then
        return rl_3
    end
    return nil
end
local function onInputChanged(lx)
    if oI and (lx.UserInputType == Enum.UserInputType.MouseMovement or lx.UserInputType == Enum.UserInputType.Touch) then
        local xN_1 = lx.Position - oG
        if xN_1.Magnitude > 4 then
            oC = true
        end
        oQ.Position = UDim2.new(Position.X.Scale, Position.X.Offset + xN_1.X, Position.Y.Scale, Position.Y.Offset + xN_1.Y)
    end
end
local function fn656()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    if pH then
        pH:Disconnect()
        pH = nil
    end
    if connection4 then
        connection4:Disconnect()
        connection4 = nil
    end
    if connection2 then
        connection2:Disconnect()
        connection2 = nil
    end
    oM()
    connection5:Disconnect()
    connection6:Disconnect()
    pcall(function()
        oV:Destroy()
    end)
    pcall(function()
        Library:Unload()
    end)
end
local function onInputBegan(lq)
    if lq.UserInputType == Enum.UserInputType.MouseButton1 or lq.UserInputType == Enum.UserInputType.Touch then
        oI, oC = true, false
        oG = lq.Position
        Position = oQ.Position
    end
end
local function fn728()
    o3 = false
    local qD = #o_
    local qC = -1
    while false and qD <= 1 or true and qD >= 1 do
        local qE = qD
        pcall(o_[qE])
        qD += qC
    end
    table.clear(o_)
end
local function fn801(ar)
    local rb_1, rb_2
    local ra_1
    for i, v in ipairs(ar) do
        ra_1, rb_1 = pcall(game.HttpGet, game, v)
        local rc = ra_1 and type(rb_1) == "string" and #rb_1 > 200
        local rc_1
        if rc then
            local ra_2 = loadstring(rb_1)
            if ra_2 then
                rb_2, rc_1 = pcall(ra_2)
                local ra_3 = rb_2 and type(rc_1) == "table"
                if ra_3 then
                    return rc_1
                end
            end
        end
    end
    return nil
end
local function fn920()
    return game:GetService("VirtualInputManager")
end
local function onInputEnded(lI)
    if lI.UserInputType == Enum.UserInputType.MouseButton1 or lI.UserInputType == Enum.UserInputType.Touch then
        oI = false
    end
end
oz = nil
oB = nil
oC = nil
oD = nil
Position = nil
oF = nil
oG = nil
oH = nil
oI = nil
connection6 = nil
oK = nil
oL = nil
oM = nil
oN = nil
oO = nil
oP = nil
oQ = nil
connection5 = nil
oS = nil
oT = nil
oU = nil
oV = nil
oW = nil
oX = nil
oZ = nil
o_ = nil
o0 = nil
o2 = nil
o3 = nil
TraitCharactersDropdown = nil
o5 = nil
o6 = nil
o7 = nil
o8 = nil
o9 = nil
connection2 = nil
pb = nil
pc = nil
pd = nil
pe = nil
connection = nil
bodyGyro = nil
ph = nil
CloneCharactersDropdown = nil
bodyVelocity = nil
connection3 = nil
local oA, oY, o1
pm = nil
BeerusSpin = nil
LocalPlayer = nil
onIdled = nil
onDescendantAdded = nil
connection4 = nil
pt = nil
ClaimWish = nil
VirtualUser = nil
pw = nil
px = nil
UserInputService = nil
pB = nil
pC = nil
pE = nil
pF = nil
RunService = nil
pH = nil
Window = nil
pJ = nil
pK = nil
Library = nil
pM = nil
local py, pA, TweenService, pT, pZ
local pO_1
RunService, TweenService, UserInputService, VirtualUser, LocalPlayer = nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local pN_11, pN_17
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local pQ_1, pQ_2, pQ_3
RunService = game:GetService("RunService")
TweenService = game:GetService("TweenService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
LocalPlayer = Players.LocalPlayer
local pP = getgenv and getgenv()
local pP_10
local pN_1 = pP or _G
pd = nil
pd = pN_1
local pP_1 = rawget(pd, "TempoDefendBaseCleanup")
if type(pP_1) == "function" then
    pcall(pP_1)
end
o3, o_, Library, oY = nil, nil, nil, nil
o3 = true
o_ = {}
oY = fn323
pd.TempoDefendBaseCleanup = fn728
local function pN_2()
    local qM
    local qK
    local qL
    local textButton
    local frame3
    local qO
    frame3 = nil
    qK = nil
    qL = nil
    qM = nil
    textButton = nil
    qO = nil
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TempoLoader"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 2147483647
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local qQ = gethui and gethui()
    local qR = qQ
    local qY = if qR then 1 else 0
    local qW = 2843 * qY + 3880 * (1 - qY)
    local qX = 118 * qY + 2560 * (1 - qY)
    if not ((qW * 3879 + qX * 3296 + qW * qX) % 16777213 == 11752399) then
        qR = game:GetService("CoreGui")
    end
    screenGui.Parent = qR
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
    qO = function(F)
        local uIStroke = Instance.new("UIStroke")
        uIStroke.Color = Color3.fromRGB(0, 0, 0)
        uIStroke.Thickness = 2
        uIStroke.Transparency = 0.1
        uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        uIStroke.Parent = F
        return uIStroke
    end
    local function qR_3(I, J, K, L, M)
        local textLabel = Instance.new("TextLabel")
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.fromOffset(460, J + 6)
        textLabel.Font = K
        textLabel.Text = I
        textLabel.TextSize = J
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextTransparency = L
        textLabel.LayoutOrder = M
        qO(textLabel)
        textLabel.Parent = frame3
        return textLabel
    end
    qK = "https://discord.gg/K7Qxnxkk46"
    qR_3("Made By Tempo Marketplace && MM", 26, Enum.Font.GothamBold, 0, 1)
    textButton = Instance.new("TextButton")
    textButton.BackgroundTransparency = 1
    textButton.AutoButtonColor = false
    textButton.Size = UDim2.fromOffset(460, 24)
    textButton.Font = Enum.Font.GothamSemibold
    textButton.RichText = true
    textButton.Text = "<u>" .. qK .. "</u>  (click to copy)"
    textButton.TextSize = 16
    textButton.TextColor3 = Color3.fromRGB(120, 160, 255)
    textButton.TextTransparency = 0
    textButton.LayoutOrder = 2
    qO(textButton)
    textButton.Parent = frame3
    textButton.MouseEnter:Connect(function()
        textButton.TextColor3 = Color3.fromRGB(170, 200, 255)
    end)
    textButton.MouseLeave:Connect(function()
        textButton.TextColor3 = Color3.fromRGB(120, 160, 255)
    end)
    textButton.Activated:Connect(function()
        if setclipboard then
            setclipboard(qK)
        end
        textButton.Text = "<u>" .. qK .. "</u>  (copied!)"
        task.delay(1.5, function()
            textButton.Text = "<u>" .. qK .. "</u>  (click to copy)"
        end)
    end)
    local qS = qR_3("Join for Dupes and Keyless Scripts. Dupes will always be announced and never gatekept in Tempo.", 13, Enum.Font.GothamMedium, 0.2, 3)
    qS.TextWrapped = true
    qS.Size = UDim2.fromOffset(420, 34)
    qM = qR_3("Tempo Bypassing", 14, Enum.Font.GothamMedium, 0.05, 4)
    qM.Size = UDim2.fromOffset(460, 18)
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
    qL = true
    task.spawn(function()
        local qH = 0
        while qL do
            qH = qH % 3 + 1
            qM.Text = "Tempo Bypassing" .. string.rep(".", qH)
            task.wait(0.35)
        end
    end)
    TweenService:Create(blurEffect, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = 18 }):Play()
    local qT_1 = { 0.35, 0.55, 0.72, 0.9, 1 }
    for i, v in ipairs(qT_1) do
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromScale(v, 1) }):Play()
        task.wait(0.55)
    end
    qL = false
    task.wait(0.25)
    local qT_2 = TweenInfo.new(0.4, Enum.EasingStyle.Quad)
    for i, descendant in ipairs(frame3:GetDescendants()) do
        local qU = descendant:IsA("TextLabel") or descendant:IsA("TextButton")
        if qU then
            TweenService:Create(descendant, qT_2, { TextTransparency = 1 }):Play()
        elseif descendant:IsA("UIStroke") then
            TweenService:Create(descendant, qT_2, { Transparency = 1 }):Play()
        end
    end
    TweenService:Create(frame2, qT_2, { BackgroundTransparency = 1 }):Play()
    TweenService:Create(frame, qT_2, { BackgroundTransparency = 1 }):Play()
    TweenService:Create(blurEffect, qT_2, { Size = 0 }):Play()
    task.wait(0.45)
    blurEffect:Destroy()
    screenGui:Destroy()
end
local pR = fn801
pN_2()
Library = getgenv().Library
if not Library then
    error("Tempo Hub: failed to load the Obsidian library.")
end
pC, oP, pO_1, pt, pT = nil, nil, nil, nil, nil
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
pC = "https://discord.gg/K7Qxnxkk46"
local pY = "rbxassetid://91400086538074"
pt = fn253
if (ThemeManager and ThemeManager or (not oP or not SaveManager)) and (false and not oP or (not SaveManager or pC)) and not ((ThemeManager and ThemeManager or (not oP or not SaveManager)) and (false and not oP or (not SaveManager or pC))) then
    pt = fn587
else
    pT = fn587
end
local pP_2 = pT(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("CharactersInfo"))
local pS = pT(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("MutationInfo"))
oP = {}
local pU = {}
local pV = {}
if (oP and false and (SaveManager and not pP_2) and (false or pP_2 or not oP and pC) or (pP_2 or not SaveManager or false) and (not oP or pP_2 or (pC or oP))) and not (oP and false and (SaveManager and not pP_2) and (false or pP_2 or not oP and pC) or (pP_2 or not SaveManager or false) and (not oP or pP_2 or (pC or oP))) then
    pP_2 = pO_1
else
    pO_1 = pP_2
end
if pO_1 then
    pO_1 = pP_2.Characters
end
if pO_1 then
    for k, v in pairs(pP_2.Characters) do
        table.insert(pU, k)
        for k2 in pairs(v) do
            oP[k2] = k
            table.insert(pV, k2)
        end
    end
end
oA = nil
table.sort(pU)
table.sort(pV)
oA = { "None" }
if pS and pS.Mutations then
    for k in pairs(pS.Mutations) do
        table.insert(oA, k)
    end
end
local pP_3 = pT(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Trait"):WaitForChild("TraitInfo"))
pR = {}
if pP_3 and pP_3.Traits then
    for k in pairs(pP_3.Traits) do
        table.insert(pR, k)
    end
end
ph, oB, pm, pb, oS, oL = nil, nil, nil, nil, nil, nil
table.sort(pR)
pm = fn286
ph = nil
pb = fn244
oS = fn48
oL = fn306
oB = {}
local Assets = ReplicatedStorage:FindFirstChild("Assets")
local pO_4 = Assets and Assets:FindFirstChild("StarMeteors")
if pO_4 then
    for i, child in ipairs(pO_4:GetChildren()) do
        oB[child.Name:lower()] = true
    end
end
ClaimWish, BeerusSpin = nil, nil
pS = ReplicatedStorage:WaitForChild("Remotes")
ClaimWish = pS:WaitForChild("SuperShenronEvent"):WaitForChild("ClaimWish")
BeerusSpin = pS:WaitForChild("SpinWheel"):WaitForChild("BeerusSpin")
local pO_5 = pT(ReplicatedStorage:WaitForChild("Data"):WaitForChild("DataService"))
local pP_6 = pO_5 and pO_5.client
pc, o7, o2, pQ_1, oX, oU, oN = nil, nil, nil, nil, nil, nil, nil
local pN_3 = 11
repeat
    local pO_6 = (pN_3 * 3 + 1) % 4 + 1
    if pO_6 <= 2 then
        if pO_6 <= 1 then
            pT = (vector.create((pN_3 * 1 + 1) % 11 + 1, (pN_3 * 1 + 9) % 13 + 1, (pN_3 * 15 + 15) % 17 + 1))
            pZ = (vector.create((pN_3 * 7 + 3) % 11 + 1, (pN_3 * 5 + 2) % 13 + 1, (pN_3 * 7 + 14) % 17 + 1))
            local p_ = (vector.create((pN_3 * 3 + 5) % 5 + 1, (pN_3 * 3 + 5) % 7 + 1, (pN_3 * 4 + 6) % 9 + 1))
            if math.abs((vector.angle(pT, pZ, p_))) - math.abs((vector.angle(pZ, pT, p_))) == 0 then
                oX = {
                    AutoRoll = false,
                    RarityFilterEnabled = false,
                    MutationFilterEnabled = false,
                    CharacterFilterEnabled = false,
                    RarityFilter = {},
                    MutationFilter = {},
                    CharacterFilter = {},
                    AutoBuy = false,
                    BuyRarityFilterEnabled = false,
                    BuyMutationFilterEnabled = false,
                    BuyCharacterFilterEnabled = false,
                    BuyRarityFilter = {},
                    BuyMutationFilter = {},
                    BuyCharacterFilter = {},
                    BuyDelay = 0.5,
                    AutoCollectBalls = false,
                    AutoCollectMeteors = false,
                    CollectDelay = 0,
                    AutoWish = false,
                    WishChoice = nil,
                    AutoBeerusChallenge = false,
                    AutoBeerusSpin = false,
                    PerfNoEffects = false,
                    PerfLowQuality = false,
                    PerfStripDecor = false,
                    AutoTrait = false,
                    TraitTargets = {},
                    TraitCharacters = {},
                    TraitRollDelay = 0.15,
                    AutoClone = false,
                    CloneDelay = 0.5,
                    AutoClaimClone = false,
                    CloneCharacters = {},
                    CloneRarityFilterEnabled = false,
                    CloneMutationFilterEnabled = false,
                    CloneCharacterFilterEnabled = false,
                    CloneRarityFilter = {},
                    CloneMutationFilter = {},
                    CloneCharacterFilter = {},
                    InfiniteJump = false,
                    WalkSpeed = 16,
                    Fly = false,
                    FlySpeed = 50,
                    FpsCap = 60
                }
            else
                o2 = {
                    TraitTargets = {},
                    InfiniteJump = false,
                    CharacterFilterEnabled = false,
                    WalkSpeed = 16,
                    BuyCharacterFilter = {},
                    AutoWish = false,
                    AutoTrait = false,
                    BuyRarityFilter = {},
                    CollectDelay = 0,
                    TraitCharacters = {},
                    TraitRollDelay = 0.15,
                    AutoBuy = false,
                    RarityFilterEnabled = false,
                    CloneCharacterFilterEnabled = false,
                    WishChoice = nil,
                    MutationFilterEnabled = false,
                    AutoClaimClone = false,
                    AutoBeerusSpin = false,
                    CloneMutationFilter = {},
                    BuyMutationFilterEnabled = false,
                    BuyCharacterFilterEnabled = false,
                    CharacterFilter = {},
                    FpsCap = 60,
                    MutationFilter = {},
                    AutoCollectBalls = false,
                    AutoCollectMeteors = false,
                    PerfStripDecor = false,
                    BuyRarityFilterEnabled = false,
                    CloneDelay = 0.5,
                    CloneMutationFilterEnabled = false,
                    CloneCharacters = {},
                    CloneRarityFilter = {},
                    BuyDelay = 0.5,
                    BuyMutationFilter = {},
                    AutoBeerusChallenge = false,
                    PerfNoEffects = false,
                    AutoRoll = false,
                    AutoClone = false,
                    CloneCharacterFilter = {},
                    FlySpeed = 50,
                    RarityFilter = {},
                    CloneRarityFilterEnabled = false,
                    Fly = false,
                    PerfLowQuality = false
                }
            end
            pN_3 = (pN_3 + 7) % 16
        else
            pT = (vector.create((pN_3 * 7 + 2) % 11 + 1, (pN_3 * 6 + 4) % 13 + 1, (pN_3 * 7 + 1) % 17 + 1))
            pZ = (vector.create((pN_3 * 6 + 4) % 11 + 1, (pN_3 * 5 + 10) % 13 + 1, (pN_3 * 11 + 16) % 17 + 1))
            local zm = vector.dot(pT, pZ)
            if zm * zm >= vector.dot(pT, pT) * vector.dot(pZ, pZ) + 1 then
                oN = fn65
                oU = fn406
            else
                oU = fn65
                oN = fn406
            end
            pN_3 = (pN_3 + 15) % 16
        end
    elseif pO_6 <= 3 then
        if not o2 and o7 and (not pc or o7) and (not oU and pc or o2 and not pc) or not (not o2 and o7 and (not pc or o7) and (not oU and pc or o2 and not pc)) then
            pc = pP_6
            o7 = pS:WaitForChild("Trait"):WaitForChild("Request")
            o2 = pS:WaitForChild("Clone"):WaitForChild("Request")
        else
            o7 = o2
            pS = pc:WaitForChild("Trait"):WaitForChild("Request")
            pP_6 = pc:WaitForChild("Clone"):WaitForChild("Request")
        end
        pN_3 = (pN_3 + 3) % 16
    else
        if (o7 or oU) and (not oX and o7) and ((o7 or not o7) and (not oU or o7)) and ((not oX or not o7) and (oU and not oX) and (not oU or oX or (o2 or o7))) or not ((o7 or oU) and (not oX and o7) and ((o7 or not o7) and (not oU or o7)) and ((not oX or not o7) and (oU and not oX) and (not oU or oX or (o2 or o7)))) then
            pQ_1 = {
                "MillionDollars",
                "MeteorRain",
                "SkipCloningMachine",
                "ManyFragments",
                "SkipCraftingMachine",
                "LuckBoost",
                "CashBoost",
                "UniqueTrait"
            }
        else
            oX = {
                "SkipCraftingMachine",
                "ManyFragments",
                "MeteorRain",
                "CashBoost",
                "LuckBoost",
                "UniqueTrait",
                "SkipCloningMachine",
                "MillionDollars"
            }
        end
        pN_3 = (pN_3 + 7) % 16
    end
until (pN_3 * 1 + 1) % 16 == 12
if ThemeManager then
    local pN_4 = 1
    repeat
        if (pN_4 * 1 + 4) * 5 % 4 == ((pN_4 * 1 + 4) * 5 + 11) % 4 then
            Library:SetLibrary(ThemeManager)
            Library.DefaultTheme = "Mint"
        else
            ThemeManager:SetLibrary(Library)
            ThemeManager.DefaultTheme = "Mint"
        end
        pN_4 = (pN_4 + 5) % 8
    until (pN_4 * 7 + 1) % 8 == 3
end
Window, pE, pA = nil, nil, nil
Window = Library:CreateWindow({
    Title = "DUBWA",
    Footer = "Tempo Hub",
    Icon = pY,
    Size = UDim2.fromOffset(880, 600),
    AutoShow = true,
    Center = true,
    Resizable = true,
    CornerRadius = 0,
    NotifySide = "Right",
    ShowCustomCursor = false,
    ToggleKeybind = Enum.KeyCode.RightControl,
    ShowMobileButtons = true,
    MobileButtonsSide = "Left",
    EnableSidebarResize = true,
    EnableCompacting = true,
    SidebarCompacted = false
})
pS = {
    Roll = Window:AddTab("Auto Roll", "dices"),
    Buy = Window:AddTab("Auto Buy", "shopping-cart"),
    Trait = Window:AddTab("Auto Trait", "star"),
    Clone = Window:AddTab("Auto Clone", "copy"),
    Events = Window:AddTab("Events", "sparkles"),
    Performance = Window:AddTab("Player", "user"),
    Suggestions = Window:AddTab("Suggestions", "message-square"),
    Settings = Window:AddTab("Settings", "settings")
}
pE = {}
pA = function(bQ)
    local AddDropdown
    local AddSlider
    local AddToggle
    local AddInput
    local AddButton
    AddToggle = bQ.AddToggle
    AddButton = bQ.AddButton
    AddSlider = bQ.AddSlider
    AddInput = bQ.AddInput
    AddDropdown = bQ.AddDropdown
    bQ.AddToggle = function(bX, bY, bZ)
        local rT = bZ.Text or bZ.Title
        bZ.Text = rT
        bZ.Title = nil
        bZ.Description = nil
        return AddToggle(bX, bY, bZ)
    end
    bQ.AddButton = function(b1, b2, b3)
        if type(b2) == "table" then
            local rV = b2.Text or b2.Title
            b2.Text = rV
            local rV_1 = b2.Func or b2.Callback
            b2.Func = rV_1
            b2.Title = nil
            b2.Description = nil
            b2.Callback = nil
        end
        return AddButton(b1, b2, b3)
    end
    bQ.AddSlider = function(b7, b8, b9)
        local rX = b9.Text or b9.Title
        b9.Text = rX
        b9.Title = nil
        b9.Description = nil
        return AddSlider(b7, b8, b9)
    end
    bQ.AddInput = function(cc, cd, ce)
        local rZ = ce.Text or ce.Title
        ce.Text = rZ
        ce.Title = nil
        ce.Description = nil
        return AddInput(cc, cd, ce)
    end
    bQ.AddDropdown = function(ch, ci, cj)
        local r0 = cj.Text or cj.Title
        cj.Text = r0
        cj.Title = nil
        cj.Description = nil
        cj.Searchable = true
        cj.SearchPlaceholder = nil
        return AddDropdown(ch, ci, cj)
    end
    return bQ
end
local function pP_7(cn)
    local AddLeftGroupbox = cn.AddLeftGroupbox
    local AddRightGroupbox = cn.AddRightGroupbox
    cn.AddLeftGroupbox = function(cq, ...)
        return pA(AddLeftGroupbox(cq, ...))
    end
    cn.AddRightGroupbox = function(cu, ...)
        return pA(AddRightGroupbox(cu, ...))
    end
end
for k, v in pairs(pS) do
    pP_7(v)
end
pK = function(cA, cB, cC)
    local r2 = not pE[cA]
    pE[cA] = r2
    if r2 then
        return cA:AddLeftGroupbox(cB, cC)
    end
    return cA:AddRightGroupbox(cB, cC)
end
local function pN_5(cG)
    local cI = pK(cG, "Discord", "send")
    cI:AddButton({
        Text = "Join Discord for Dupes/Keyless Scripts",
        Tooltip = "Copies the invite link to your clipboard.",
        Func = function()
            setclipboard(pC)
        end
    })
end
pN_5(pS.Roll)
pN_5(pS.Buy)
pN_5(pS.Trait)
pN_5(pS.Clone)
pN_5(pS.Events)
pN_5(pS.Performance)
pN_5(pS.Suggestions)
pN_5(pS.Settings)
oZ = function(cM)
    local cO = oP[cM.Name]
    local cQ = pm(cM:GetAttribute("Mutation"))
    return oN({ enabled = oX.CharacterFilterEnabled, set = oX.CharacterFilter, value = cM.Name }, { enabled = oX.RarityFilterEnabled, set = oX.RarityFilter, value = cO }, { enabled = oX.MutationFilterEnabled, set = oX.MutationFilter, value = cQ }), cO, cQ
end
oK = function(cU)
    for i, child in ipairs(cU:GetChildren()) do
        local r4 = child:FindFirstChild("HumanoidRootPart") and oZ(child)
        if r4 then
            return child
        end
    end
    return nil
end
task.spawn(function()
    local sc, sd, se, sf, sg, sh, si, sj
    local sh_1
    local sk = 14
    while true do
        local sk_1 = 439 - sk
        do
            if sk_1 < 421 then
                if sk_1 < 415 then
                    if sk_1 < 407 then
                        if sk_1 < 405 then
                            if sk_1 < 401 then
                                if sk_1 < 397 then
                                    if sk_1 < 395 then
                                        if sk_1 < 394 then
                                            if sk_1 == 393 then
                                                se = sd:FindFirstChild("Characters")
                                                sk = 44
                                            else
                                                sk = 417
                                                continue
                                            end
                                        elseif sk_1 == 394 then
                                            sh = si .. " "
                                            sk = 0
                                        else
                                            sk = 2149
                                            continue
                                        end
                                    elseif sk_1 < 396 then
                                        if sk_1 == 395 then
                                            sf = sd
                                            sg = se
                                            sk = if sf then 11 else 38
                                        else
                                            sk = 418
                                            continue
                                        end
                                    elseif sk_1 == 396 then
                                        sk = if se then 40 else 3
                                    else
                                        sk = 411
                                        continue
                                    end
                                elseif sk_1 < 399 then
                                    if sk_1 < 398 then
                                        sk = if not sc then 5 else 10
                                    else
                                        sk = if oX.AutoRoll then 31 else 18
                                    end
                                elseif sk_1 < 400 then
                                    if sk_1 == 399 then
                                        se = oS()
                                        sk = 3
                                    else
                                        sk = 428
                                        continue
                                    end
                                else
                                    sf = false
                                    for i, child in ipairs(sg:GetChildren()) do
                                        if not se[child] then
                                            sf = true
                                            break
                                        end
                                    end
                                    sk = if sf then 33 else 13
                                end
                            elseif sk_1 < 403 then
                                if sk_1 < 402 then
                                    if sk_1 == 401 then
                                        sd = sf
                                        se = sd
                                        sk = if se then 17 else 21
                                    else
                                        sk = 405
                                        continue
                                    end
                                elseif sk_1 == 402 then
                                    sk = 7
                                else
                                    sk = 431
                                    continue
                                end
                            elseif sk_1 < 404 then
                                if sk_1 == 403 then
                                    task.wait(0.35)
                                    sk = 9
                                else
                                    sk = 402
                                    continue
                                end
                            else
                                sk = 36
                            end
                        elseif sk_1 < 406 then
                            sk = 12
                        elseif sk_1 == 406 then
                            sk = 36
                        else
                            sk = 436
                            continue
                        end
                    elseif sk_1 < 413 then
                        if sk_1 < 411 then
                            if sk_1 < 409 then
                                if sk_1 < 408 then
                                    if sk_1 == 407 then
                                        se = sg
                                        sk = 43
                                    else
                                        sk = 1040
                                        continue
                                    end
                                elseif sk_1 == 408 then
                                    sd = pb()
                                    se = sd
                                    sk = if se then 46 else 44
                                else
                                    sk = 433
                                    continue
                                end
                            elseif sk_1 < 410 then
                                sd = se
                                sk = if se then 23 else 20
                            else
                                sf = os.clock() - sd < 6
                                sk = 27
                            end
                        elseif sk_1 < 412 then
                            task.wait(0.3)
                            sk = 26
                        else
                            sk = if sf then 39 else 35
                        end
                    elseif sk_1 < 414 then
                        sk = 37
                    elseif sk_1 == 414 then
                        sk = 34
                    else
                        sk = 429
                        continue
                    end
                elseif sk_1 < 418 then
                    if sk_1 < 417 then
                        if sk_1 < 416 then
                            se = oK(sg)
                            sk = if se then 42 else 1
                        elseif sk_1 == 416 then
                            se = sd:FindFirstChild("RollPrompt")
                            sk = 20
                        else
                            sk = 2567
                            continue
                        end
                    else
                        se = sd:FindFirstChild("Button")
                        sk = 30
                    end
                elseif sk_1 < 419 then
                    if sk_1 == 418 then
                        sd = se
                        sk = if se then 22 else 30
                    else
                        sk = 397
                        continue
                    end
                elseif sk_1 < 420 then
                    sf = se
                    sk = if se then 32 else 43
                else
                    sk = 8
                end
            elseif sk_1 < 438 then
                if sk_1 < 429 then
                    if sk_1 < 427 then
                        if sk_1 < 424 then
                            if sk_1 < 423 then
                                if sk_1 < 422 then
                                    if sk_1 == 421 then
                                        sc = false
                                        task.wait(0.2)
                                        sk = 37
                                    else
                                        sk = 439
                                        continue
                                    end
                                else
                                    se = sd:FindFirstChild("RollButton")
                                    sk = 21
                                end
                            elseif sk_1 == 423 then
                                sh = si .. tostring(se.Name) .. " [" .. tostring(sj) .. "]"
                                pt("Auto Stop", "Paused on " .. sh, 4)
                                sk = 10
                            else
                                sk = 438
                                continue
                            end
                        elseif sk_1 < 425 then
                            if sk_1 == 424 then
                                sk = 19
                            else
                                sk = 404
                                continue
                            end
                        elseif sk_1 < 426 then
                            if sk_1 == 425 then
                                sc = false
                                sk = 6
                            else
                                sk = 420
                                continue
                            end
                        elseif sk_1 == 426 then
                            task.wait(0.15)
                            sk = 25
                        else
                            sk = 408
                            continue
                        end
                    elseif sk_1 < 428 then
                        if sk_1 == 427 then
                            sf = oX.AutoRoll
                            sk = if sf then 29 else 27
                        else
                            sk = 421
                            continue
                        end
                    else
                        sf = sd:FindFirstChild("Roll")
                        sk = 38
                    end
                elseif sk_1 < 433 then
                    if sk_1 < 432 then
                        if sk_1 < 430 then
                            task.wait(0.3)
                            sk = 9
                        elseif sk_1 < 431 then
                            if sk_1 == 430 then
                                sk = 26
                            else
                                sk = 406
                                continue
                            end
                        else
                            break
                        end
                    elseif sk_1 == 432 then
                        sk = 6
                    else
                        sk = 14601
                        continue
                    end
                elseif sk_1 < 435 then
                    if sk_1 < 434 then
                        if sk_1 == 433 then
                            sk = 2
                        else
                            sk = 11571
                            continue
                        end
                    elseif sk_1 == 434 then
                        sc = true
                        sh_1, sj, si = oZ(se)
                        sh = si ~= "None"
                        sk = if sh then 45 else 0
                    else
                        sk = 409
                        continue
                    end
                elseif sk_1 < 436 then
                    si = ""
                    sk = 16
                elseif sk_1 < 437 then
                    sk = if se then 24 else 28
                else
                    sk = if o3 then 41 else 15
                end
            elseif sk_1 < 1040 then
                if sk_1 < 439 then
                    if sk_1 == 438 then
                        sc = false
                        se = {}
                        for i, child in ipairs(sg:GetChildren()) do
                            se[child] = true
                        end
                        oL(sd.CFrame * CFrame.new(0, 3, 0))
                        fireproximityprompt(sf)
                        sd = os.clock()
                        sk = 34
                    else
                        sk = 399
                        continue
                    end
                elseif sk_1 == 439 then
                    si = sh
                    sk = if si then 16 else 4
                else
                    sk = 415
                    continue
                end
            else
                break
            end
        end
    end
end)
task.spawn(function()
    while o3 do
        if oX.AutoBuy then
            local sx = pb()
            local sy = sx and sx:FindFirstChild("Characters")
            if sy then
                for i, child in ipairs(sy:GetChildren()) do
                    if not oX.AutoBuy then
                        break
                    else
                        local HumanoidRootPart = child:FindFirstChild("HumanoidRootPart")
                        local sy_1 = HumanoidRootPart and HumanoidRootPart:FindFirstChild("ProximityPrompt")
                        local sz = sy_1
                        if sy_1 then
                            sy_1 = sz.Enabled
                        end
                        if sy_1 then
                            local sy_2 = oP[child.Name]
                            local sA = pm(child:GetAttribute("Mutation"))
                            if oN({ enabled = oX.BuyCharacterFilterEnabled, set = oX.BuyCharacterFilter, value = child.Name }, { enabled = oX.BuyRarityFilterEnabled, set = oX.BuyRarityFilter, value = sy_2 }, { enabled = oX.BuyMutationFilterEnabled, set = oX.BuyMutationFilter, value = sA }) then
                                if oS() then
                                    oL(HumanoidRootPart.CFrame * CFrame.new(0, 0, 4))
                                    task.wait(0.15)
                                    if sz.Parent and sz.Enabled then
                                        fireproximityprompt(sz)
                                        local sx_4 = os.clock()
                                        while true do
                                            local sy_3 = oX.AutoBuy and sz.Parent and sz.Enabled and os.clock() - sx_4 < 1
                                            if sy_3 then
                                                task.wait(0.05)
                                                continue
                                            end
                                            break
                                        end
                                    end
                                    task.wait(oX.BuyDelay)
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)
task.spawn(function()
    while o3 do
        if oX.AutoCollectBalls then
            local MutationStuffs = workspace:FindFirstChild("MutationStuffs")
            local sM = MutationStuffs and oS()
            if sM then
                for i, child in ipairs(MutationStuffs:GetChildren()) do
                    if not oX.AutoCollectBalls then
                        break
                    elseif child.Name:match("^Ball") then
                        local ProximityPrompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if ProximityPrompt then
                            local Parent = ProximityPrompt.Parent
                            local sN = Parent and Parent:IsA("BasePart")
                            if sN then
                                oL(Parent.CFrame * CFrame.new(0, 0, 6))
                            elseif child:IsA("BasePart") then
                                oL(child.CFrame * CFrame.new(0, 0, 6))
                            end
                            task.wait(0.15)
                            ProximityPrompt.Enabled = true
                            fireproximityprompt(ProximityPrompt)
                            task.wait(math.max(0.1, ProximityPrompt.HoldDuration + 0.05))
                            task.wait(oX.CollectDelay)
                        end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)
task.spawn(function()
    while o3 do
        local sV = oX.AutoCollectMeteors and oS()
        if sV then
            local MutationStuffs = workspace:FindFirstChild("MutationStuffs")
            if MutationStuffs then
                for i, child in ipairs(MutationStuffs:GetChildren()) do
                    if not oX.AutoCollectMeteors then
                        break
                    elseif oB[child.Name:lower()] then
                        local ProximityPrompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if ProximityPrompt then
                            local Parent = ProximityPrompt.Parent
                            local sX = Parent and Parent:IsA("BasePart")
                            if sX then
                                oL(Parent.CFrame * CFrame.new(0, 0, 6))
                            end
                            task.wait(0.15)
                            ProximityPrompt.Enabled = true
                            fireproximityprompt(ProximityPrompt)
                            task.wait(math.max(0.1, ProximityPrompt.HoldDuration + 0.05))
                            task.wait(oX.CollectDelay)
                        end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)
task.spawn(function()
    while o3 do
        if oX.AutoWish and oX.WishChoice then
            local MutationStuffs = workspace:FindFirstChild("MutationStuffs")
            local s5 = MutationStuffs and MutationStuffs:FindFirstChild("SuperShenron")
            if s5 then
                ClaimWish:FireServer(oX.WishChoice)
                task.wait(2)
            end
        end
        task.wait(0.5)
    end
end)
task.spawn(function()
    while o3 do
        if oX.AutoBeerusChallenge and pc then
            local Machines = workspace:FindFirstChild("Machines")
            local s8 = Machines and Machines:FindFirstChild("Door")
            local s7_2 = s8
            if s8 then
                s8 = s7_2:FindFirstChild("Door")
            end
            local s7_3 = s8
            if s8 then
                s8 = s7_3:FindFirstChild("ProximityPrompt")
            end
            local s9 = s8
            local s8_1 = pc:get("LastBeerusBossChallenge")
            local ta = s9 and s8_1 and s8_1 < math.floor((os.time()) / (86400)) and oS()
            if ta then
                oL(s7_3.CFrame * CFrame.new(0, 0, 6))
                fireproximityprompt(s9)
                task.wait(2)
            end
        end
        task.wait(1)
    end
end)
task.spawn(function()
    while o3 do
        if oX.AutoBeerusSpin and pc then
            local tc_1 = tonumber(pc:get("BeerusSpin")) or 0
            if tc_1 > 0 then
                BeerusSpin:FireServer("Spin")
                task.wait(7)
            end
        end
        task.wait(1)
    end
end)
py = function(ev, ew)
    local tt
    local screenGui
    tt = nil
    screenGui = nil
    tt = {}
    local function tw()
        local ti = {}
        for k, v in pairs(tt) do
            if v then
                table.insert(ti, k)
            end
        end
        oX[ew] = ti
    end
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TempoMutation_" .. ew
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 2147483647
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Enabled = false
    local ty = gethui and gethui()
    local tz = ty or game:GetService("CoreGui")
    screenGui.Parent = tz
    oY(function()
        screenGui:Destroy()
    end)
    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.Size = UDim2.fromOffset(260, 320)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    local uICorner3 = Instance.new("UICorner")
    uICorner3.CornerRadius = UDim.new(0, 8)
    uICorner3.Parent = frame
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, -40, 0, 32)
    textLabel.Position = UDim2.fromOffset(12, 6)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Text = "Mutations"
    textLabel.TextSize = 16
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Parent = frame
    local textButton2 = Instance.new("TextButton")
    textButton2.AnchorPoint = Vector2.new(1, 0)
    textButton2.Position = UDim2.new(1, -8, 0, 8)
    textButton2.Size = UDim2.fromOffset(28, 28)
    textButton2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    textButton2.Font = Enum.Font.GothamBold
    textButton2.Text = "X"
    textButton2.TextSize = 14
    textButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
    textButton2.Parent = frame
    local uICorner2 = Instance.new("UICorner")
    uICorner2.CornerRadius = UDim.new(0, 6)
    uICorner2.Parent = textButton2
    textButton2.Activated:Connect(function()
        screenGui.Enabled = false
    end)
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Position = UDim2.fromOffset(8, 44)
    scrollingFrame.Size = UDim2.new(1, -16, 1, -52)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.ScrollBarThickness = 4
    scrollingFrame.CanvasSize = UDim2.new()
    scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollingFrame.Parent = frame
    local uIListLayout = Instance.new("UIListLayout")
    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uIListLayout.Padding = UDim.new(0, 4)
    uIListLayout.Parent = scrollingFrame
    local function tu(eT)
        local tq = tt[eT] and Color3.fromRGB(60, 90, 150)
        local tr = tq or Color3.fromRGB(45, 45, 45)
        return tr
    end
    for i, v in ipairs(oA) do
        local textButton
        local tH = v
        textButton = Instance.new("TextButton")
        textButton.Size = UDim2.new(1, 0, 0, 30)
        textButton.BackgroundColor3 = tu(tH)
        textButton.Font = Enum.Font.GothamMedium
        textButton.Text = tH
        textButton.TextSize = 14
        textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        textButton.AutoButtonColor = false
        textButton.Parent = scrollingFrame
        local uICorner = Instance.new("UICorner")
        uICorner.CornerRadius = UDim.new(0, 6)
        uICorner.Parent = textButton
        textButton.Activated:Connect(function()
            tt[tH] = not tt[tH]
            textButton.BackgroundColor3 = tu(tH)
            tw()
        end)
    end
    ev:AddButton({
        Title = "Mutations",
        Callback = function()
            screenGui.Enabled = not screenGui.Enabled
        end
    })
end
local function pN_6(e8, e9, fa)
    local tQ = pcall(function()
        e8:AddDropdown(e9, {
            Title = "Mutations",
            Values = oA,
            Multi = true,
            Default = {},
            Callback = function(ff)
                local tI = {}
                for k, v in pairs(ff) do
                    if v then
                        table.insert(tI, k)
                    end
                end
                oX[fa] = tI
            end
        })
    end)
    if not tQ then
        py(e8, fa)
    end
end
local pO_7 = pK(pS.Roll, "Rolling", "dices")
pO_7:AddToggle("AutoRoll", {
    Title = "Auto Roll",
    Description = "Teleports to the roll button and fires the prompt.",
    Default = false,
    Callback = function(fs)
        oX.AutoRoll = fs
    end
})
local pO_8 = pK(pS.Roll, "Auto Stop", "circle-stop")
pO_8:AddToggle("RarityFilterEnabled", {
    Title = "Stop by Rarity",
    Default = false,
    Callback = function(fv)
        oX.RarityFilterEnabled = fv
    end
})
pO_8:AddDropdown("RarityFilter", {
    Title = "Rarities",
    Values = pU,
    Multi = true,
    Default = {},
    Callback = function(fx)
        local tS = {}
        for k, v in pairs(fx) do
            if v then
                table.insert(tS, k)
            end
        end
        oX.RarityFilter = tS
    end
})
pO_8:AddToggle("MutationFilterEnabled", {
    Title = "Stop by Mutation",
    Default = false,
    Callback = function(fC)
        oX.MutationFilterEnabled = fC
    end
})
pN_6(pO_8, "MutationFilter", "MutationFilter")
pO_8:AddToggle("CharacterFilterEnabled", {
    Title = "Stop by Character",
    Default = false,
    Callback = function(fE)
        oX.CharacterFilterEnabled = fE
    end
})
pO_8:AddDropdown("CharacterFilter", {
    Title = "Characters",
    Values = pV,
    Multi = true,
    Searchable = true,
    SearchPlaceholder = "Search characters...",
    Default = {},
    Callback = function(fG)
        local t_ = {}
        for k, v in pairs(fG) do
            if v then
                table.insert(t_, k)
            end
        end
        oX.CharacterFilter = t_
    end
})
local pO_9 = pK(pS.Buy, "Buying", "shopping-cart")
pO_9:AddToggle("AutoBuy", {
    Title = "Auto Buy",
    Description = "Buys characters on your plot slots that match the filters.",
    Default = false,
    Callback = function(fM)
        oX.AutoBuy = fM
    end
})
pO_9:AddSlider("BuyDelay", {
    Title = "Buy Delay",
    Description = "Delay after buying a character (fixes skipping).",
    Default = 0.5,
    Min = 0,
    Max = 3,
    Rounding = 1,
    Callback = function(fO)
        oX.BuyDelay = fO
    end
})
local pO_10 = pK(pS.Buy, "Filters", "filter")
pO_10:AddToggle("BuyRarityFilterEnabled", {
    Title = "Filter by Rarity",
    Default = false,
    Callback = function(fR)
        oX.BuyRarityFilterEnabled = fR
    end
})
pO_10:AddDropdown("BuyRarityFilter", {
    Title = "Rarities",
    Values = pU,
    Multi = true,
    Default = {},
    Callback = function(fT)
        local t7 = {}
        for k, v in pairs(fT) do
            if v then
                table.insert(t7, k)
            end
        end
        oX.BuyRarityFilter = t7
    end
})
pO_10:AddToggle("BuyMutationFilterEnabled", {
    Title = "Filter by Mutation",
    Default = false,
    Callback = function(fY)
        oX.BuyMutationFilterEnabled = fY
    end
})
pN_6(pO_10, "BuyMutationFilter", "BuyMutationFilter")
pO_10:AddToggle("BuyCharacterFilterEnabled", {
    Title = "Filter by Character",
    Default = false,
    Callback = function(f_)
        oX.BuyCharacterFilterEnabled = f_
    end
})
pO_10:AddDropdown("BuyCharacterFilter", {
    Title = "Characters",
    Values = pV,
    Multi = true,
    Searchable = true,
    SearchPlaceholder = "Search characters...",
    Default = {},
    Callback = function(f1)
        local uf = {}
        for k, v in pairs(f1) do
            if v then
                table.insert(uf, k)
            end
        end
        oX.BuyCharacterFilter = uf
    end
})
local pO_11 = pK(pS.Events, "Super Shenron", "sparkles")
pO_11:AddToggle("AutoCollectBalls", {
    Title = "Auto Collect Dragon Balls",
    Default = false,
    Callback = function(f7)
        oX.AutoCollectBalls = f7
    end
})
pO_11:AddToggle("AutoCollectMeteors", {
    Title = "Auto Collect Meteor",
    Default = false,
    Callback = function(f9)
        oX.AutoCollectMeteors = f9
    end
})
pO_11:AddSlider("CollectDelay", {
    Title = "Collect Delay",
    Default = 0,
    Min = 0,
    Max = 10,
    Rounding = 2,
    Callback = function(gb)
        oX.CollectDelay = gb
    end
})
pO_11:AddToggle("AutoWish", {
    Title = "Auto Wish",
    Default = false,
    Callback = function(gd)
        oX.AutoWish = gd
    end
})
pO_11:AddDropdown("WishChoice", {
    Title = "Wish",
    Values = pQ_1,
    Multi = false,
    Default = pQ_1[1],
    Callback = function(gf)
        oX.WishChoice = gf
    end
})
oX.WishChoice = pQ_1[1]
local pO_12 = pK(pS.Events, "Beerus", "sun")
pO_12:AddToggle("AutoBeerusChallenge", {
    Title = "Auto Beerus Challenge",
    Default = false,
    Callback = function(gi)
        oX.AutoBeerusChallenge = gi
    end
})
pO_12:AddToggle("AutoBeerusSpin", {
    Title = "Auto Beerus Spin",
    Default = false,
    Callback = function(gk)
        oX.AutoBeerusSpin = gk
    end
})
oF = function(gn)
    if not pc then
        return 0
    end
    local un = pc:get("Items")
    if type(un) ~= "table" then
        return 0
    end
    for k, v in pairs(un) do
        local un_1 = type(v) == "table" and v.Name == gn
        if un_1 then
            local un_2 = tonumber(v.Quantity) or 0
            return un_2
        end
    end
    return 0
end
pB = function(gu)
    if not pc then
        return nil
    end
    local uv = pc:get("Traits")
    if type(uv) == "table" then
        local uw = uv[gu]
        if uw == nil or uw == "" then
            return "None"
        end
        return tostring(uw)
    end
    return nil
end
pe = {}
o8 = function()
    local uz = {}
    table.clear(pe)
    if not pc then
        return uz
    end
    local uA = {}
    local uB = {}
    for i, v in ipairs({ "Equipped", "Inventory", "Hotbar" }) do
        local uC = pc:get(v)
        if type(uC) == "table" then
            for k, v in pairs(uC) do
                local uC_1 = type(v) == "table" and v.CharacterId and not uB[v.CharacterId]
                if uC_1 then
                    uB[v.CharacterId] = true
                    local uC_2 = v.Name or "Unknown"
                    local uD = tostring(uC_2)
                    local uC_3 = uA[uD] or 0
                    uA[uD] = uC_3 + 1
                    local uC_4 = uD
                    if uA[uD] > 1 then
                        uC_4 = uD .. " #" .. uA[uD]
                    end
                    pe[uC_4] = v.CharacterId
                    table.insert(uz, uC_4)
                end
            end
        end
    end
    table.sort(uz)
    return uz
end
local pO_13 = pK(pS.Trait, "Auto Trait", "star")
pO_13:AddToggle("AutoTrait", {
    Title = "Auto Trait",
    Description = "Rerolls traits on the selected characters until they match a target trait.",
    Default = false,
    Callback = function(gO)
        oX.AutoTrait = gO
    end
})
pO_13:AddSlider("TraitRollDelay", {
    Title = "Roll Delay",
    Default = 0.15,
    Min = 0.05,
    Max = 2,
    Rounding = 2,
    Callback = function(gQ)
        oX.TraitRollDelay = gQ
    end
})
TraitCharactersDropdown = pO_13:AddDropdown("TraitCharacters", {
    Title = "Characters",
    Values = o8(),
    Multi = true,
    Searchable = true,
    SearchPlaceholder = "Search characters...",
    Default = {},
    Callback = function(gS)
        local uR = {}
        for k, v in pairs(gS) do
            if v and pe[k] then
                table.insert(uR, pe[k])
            end
        end
        oX.TraitCharacters = uR
    end
})
pO_13:AddButton({
    Title = "Refresh Characters",
    Callback = function()
        pcall(function()
            TraitCharactersDropdown:SetValues(o8())
        end)
    end
})
pO_13:AddDropdown("TraitTargetFilter", {
    Title = "Target Traits",
    Values = pR,
    Multi = true,
    Searchable = true,
    SearchPlaceholder = "Search traits...",
    Default = {},
    Callback = function(g3)
        local u_ = {}
        for k, v in pairs(g3) do
            if v then
                table.insert(u_, k)
            end
        end
        oX.TraitTargets = u_
    end
})
task.spawn(function()
    local u7 = false
    while o3 do
        if oX.AutoTrait and pc and #oX.TraitCharacters > 0 and #oX.TraitTargets > 0 then
            if oF("Trait Shard") <= 0 then
                if not u7 then
                    u7 = true
                    pt("Auto Trait", "Out of Trait Shards.", 4)
                end
                task.wait(1)
            else
                u7 = false
                local u8_1 = false
                for i, v in ipairs(oX.TraitCharacters) do
                    if not oX.AutoTrait then
                        break
                    else
                        local u9 = pB(v)
                        local va = u9 and oU(oX.TraitTargets, u9)
                        if not va then
                            if oF("Trait Shard") <= 0 then
                                break
                            end
                            o7:FireServer("Roll", { CharacterId = v })
                            u8_1 = true
                            task.wait(oX.TraitRollDelay)
                        end
                    end
                end
                if not u8_1 then
                    task.wait(0.5)
                end
            end
        else
            task.wait(0.3)
        end
    end
end)
o6 = {}
o0 = function()
    local vi = {}
    table.clear(o6)
    if not pc then
        return vi
    end
    local vj = {}
    local vk = pc:get("Inventory")
    if type(vk) == "table" then
        for k, v in pairs(vk) do
            local vk_1 = type(v) == "table" and v.CharacterId
            if vk_1 then
                local vk_2 = v.Name or "Unknown"
                local vl = tostring(vk_2)
                local vk_3 = pm(v.Mutation)
                local vm = vj[vl] or 0
                vj[vl] = vm + 1
                local vm_2 = (vk_3 ~= "None" and vk_3 .. " " or "") .. vl
                if vj[vl] > 1 then
                    vm_2 = vm_2 .. " #" .. vj[vl]
                end
                o6[vm_2] = v.CharacterId
                table.insert(vi, vm_2)
            end
        end
    end
    table.sort(vi)
    return vi
end
pM = function()
    local vu = 0
    local vv = {}
    if not pc then
        return vu, vv
    end
    local vw = {}
    local vx = (pc:get("Cloning"))
    local vB = if vx then 1 else 0
    local vz = 2524 * vB + 3168 * (1 - vB)
    local vA = 542 * vB + 133 * (1 - vB)
    if not ((vz * 1538 + vA * 3162 + vz * vA) % 16777213 == 6963724) then
        vx = vw
    end
    for i, v in ipairs(vx) do
        local vw_1 = type(v) == "table" and v.CharacterId and v.CharacterId ~= ""
        if vw_1 then
            vv[tostring(v.CharacterId)] = v
            vu += 1
        end
    end
    return vu, vv
end
task.spawn(function()
    local vJ_1
    while o3 do
        local vI = oX.AutoClone and pc
        local vI_1
        if vI then
            vI_1, vJ_1 = pM()
            local vI_2 = pc:get("Inventory")
            if type(vI_2) == "table" then
                for k, v in pairs(vI_2) do
                    if not oX.AutoClone then
                        break
                    end
                    local vI_3 = type(v) == "table" and v.CharacterId and not vJ_1[tostring(v.CharacterId)]
                    if vI_3 then
                        local vI_4 = tostring(v.Name)
                        local vK = oP[vI_4]
                        local vK_1
                        local vL = pm(v.Mutation)
                        local vL_2
                        local vM = oU(oX.CloneCharacters, v.CharacterId) or oN({ enabled = oX.CloneCharacterFilterEnabled, set = oX.CloneCharacterFilter, value = vI_4 }, { enabled = oX.CloneRarityFilterEnabled, set = oX.CloneRarityFilter, value = vK }, { enabled = oX.CloneMutationFilterEnabled, set = oX.CloneMutationFilter, value = vL })
                        if vM and vK then
                            local vI_6 = pM()
                            o2:FireServer("Start", { Rarity = vK, CharacterId = v.CharacterId })
                            task.wait(oX.CloneDelay)
                            vL_2, vK_1 = pM()
                            vJ_1 = vK_1
                            if vL_2 <= vI_6 then
                                break
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)
task.spawn(function()
    while o3 do
        if oX.AutoClaimClone and pc then
            local vU_1 = {}
            local vV = pc:get("Cloning") or vU_1
            for i, v in ipairs(vV) do
                if not oX.AutoClaimClone then
                    break
                end
                local vU_2 = type(v) == "table" and v.CharacterId and v.CharacterId ~= ""
                if vU_2 then
                    local vU_3 = tonumber(v.EndsAt)
                    local vV_1 = tonumber(v.TimeLeft)
                    local vW = vU_3 and os.time() >= vU_3
                    local vX = vW
                    if not vX then
                        vX = vU_3 == nil and vV_1 ~= nil and vV_1 <= 0
                    end
                    if vX then
                        o2:FireServer("Claim", { CharacterId = v.CharacterId })
                        task.wait(0.3)
                    end
                end
            end
        end
        task.wait(1)
    end
end)
local pO_14 = pK(pS.Clone, "Cloning", "copy")
pO_14:AddToggle("AutoClone", {
    Title = "Auto Clone",
    Description = "Puts matching owned characters into the Clone Machine.",
    Default = false,
    Callback = function(h7)
        oX.AutoClone = h7
    end
})
pO_14:AddToggle("AutoClaimClone", {
    Title = "Auto Claim When Done",
    Default = false,
    Callback = function(h9)
        oX.AutoClaimClone = h9
    end
})
pO_14:AddSlider("CloneDelay", {
    Title = "Clone Delay",
    Default = 0.5,
    Min = 0,
    Max = 3,
    Rounding = 1,
    Callback = function(ib)
        oX.CloneDelay = ib
    end
})
CloneCharactersDropdown = pO_14:AddDropdown("CloneCharacters", {
    Title = "Characters",
    Values = o0(),
    Multi = true,
    Searchable = true,
    SearchPlaceholder = "Search characters...",
    Default = {},
    Callback = function(id)
        local v7 = {}
        for k, v in pairs(id) do
            if v and o6[k] then
                table.insert(v7, o6[k])
            end
        end
        oX.CloneCharacters = v7
    end
})
pO_14:AddButton({
    Title = "Refresh Characters",
    Callback = function()
        pcall(function()
            CloneCharactersDropdown:SetValues(o0())
        end)
    end
})
local pO_15 = pK(pS.Clone, "Filters", "filter")
pO_15:AddToggle("CloneRarityFilterEnabled", {
    Title = "Filter by Rarity",
    Default = false,
    Callback = function(is)
        oX.CloneRarityFilterEnabled = is
    end
})
pO_15:AddDropdown("CloneRarityFilter", {
    Title = "Rarities",
    Values = pU,
    Multi = true,
    Default = {},
    Callback = function(iu)
        local wg = {}
        for k, v in pairs(iu) do
            if v then
                table.insert(wg, k)
            end
        end
        oX.CloneRarityFilter = wg
    end
})
pO_15:AddToggle("CloneMutationFilterEnabled", {
    Title = "Filter by Mutation",
    Default = false,
    Callback = function(iz)
        oX.CloneMutationFilterEnabled = iz
    end
})
pN_6(pO_15, "CloneMutationFilter", "CloneMutationFilter")
pO_15:AddToggle("CloneCharacterFilterEnabled", {
    Title = "Filter by Character",
    Default = false,
    Callback = function(iB)
        oX.CloneCharacterFilterEnabled = iB
    end
})
pO_15:AddDropdown("CloneCharacterFilter", {
    Title = "Characters",
    Values = pV,
    Multi = true,
    Searchable = true,
    SearchPlaceholder = "Search characters...",
    Default = {},
    Callback = function(iD)
        local wr = {}
        for k, v in pairs(iD) do
            if v then
                table.insert(wr, k)
            end
        end
        oX.CloneCharacterFilter = wr
    end
})
px = { ParticleEmitter = true, Trail = true, Smoke = true, Fire = true, Sparkles = true, Beam = true }
onDescendantAdded = function(iK)
    if px[iK.ClassName] then
        iK.Enabled = false
    end
end
connection = nil
o9 = function(iO)
    if iO then
        for i, descendant in ipairs(workspace:GetDescendants()) do
            onDescendantAdded(descendant)
        end
        for i, descendant in ipairs(game:GetService("Lighting"):GetDescendants()) do
            if descendant:IsA("PostEffect") then
                descendant.Enabled = false
            end
        end
        if not connection then
            connection = workspace.DescendantAdded:Connect(onDescendantAdded)
        end
    elseif connection then
        connection:Disconnect()
        connection = nil
    end
end
oO = function()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
    local Lighting = game:GetService("Lighting")
    Lighting.GlobalShadows = false
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    if Terrain then
        pcall(function()
            Terrain.Decoration = false
        end)
        pcall(function()
            Terrain.WaterWaveSize = 0
        end)
        pcall(function()
            Terrain.WaterWaveSpeed = 0
        end)
        pcall(function()
            Terrain.WaterReflectance = 0
        end)
    end
end
oz = { "Leaderboards", "CutsceneRoom", "NewTraitCutsceneRoom" }
pJ = function()
    for i, v in ipairs(oz) do
        local wQ = workspace:FindFirstChild(v)
        if wQ then
            wQ:Destroy()
        end
    end
end
connection4 = nil
connection3 = nil
bodyVelocity = nil
bodyGyro = nil
connection2 = nil
o5 = function()
    local Character = LocalPlayer.Character
    local wZ = Character and Character:FindFirstChildOfClass("Humanoid")
    return wZ
end
oT = function()
    local w0 = o5()
    if w0 then
        w0.WalkSpeed = oX.WalkSpeed
    end
end
connection2 = LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    oT()
end)
oM = function()
    if connection3 then
        connection3:Disconnect()
        connection3 = nil
    end
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
end
oD = function()
    oM()
    local xa = oS()
    if not xa then
        return
    end
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new()
    bodyVelocity.Parent = xa
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.CFrame = xa.CFrame
    bodyGyro.Parent = xa
    connection3 = RunService.RenderStepped:Connect(function()
        if not oX.Fly then
            oM()
            return
        end
        local w3 = oS()
        if not w3 then
            oM()
            return
        end
        if bodyVelocity.Parent ~= w3 or bodyGyro.Parent ~= w3 then
            oD()
            return
        end
        local CurrentCamera = workspace.CurrentCamera
        local w4_1 = Vector3.new()
        local w9 = if UserInputService:IsKeyDown(Enum.KeyCode.W) then 1 else 0
        if w9 == 1 then
            w4_1 += CurrentCamera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            w4_1 -= CurrentCamera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            w4_1 -= CurrentCamera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            w4_1 += CurrentCamera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            w4_1 += Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            w4_1 -= Vector3.new(0, 1, 0)
        end
        local w5 = w4_1.Magnitude > 0 and w4_1.Unit * oX.FlySpeed
        local w4_2 = w5 or Vector3.new()
        bodyVelocity.Velocity = w4_2
        bodyGyro.CFrame = CurrentCamera.CFrame
    end)
end
local pN_7 = pK(pS.Performance, "Movement", "person-standing")
pN_7:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(jN)
        oX.InfiniteJump = jN
        if jN then
            if not connection4 then
                connection4 = UserInputService.JumpRequest:Connect(function()
                    local xc = o5()
                    if xc then
                        xc:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            end
        elseif connection4 then
            connection4:Disconnect()
            connection4 = nil
        end
    end
})
pN_7:AddSlider("WalkSpeed", {
    Title = "WalkSpeed",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(jU)
        oX.WalkSpeed = jU
        oT()
    end
})
pN_7:AddToggle("Fly", {
    Title = "Fly",
    Default = false,
    Callback = function(jX)
        oX.Fly = jX
        if jX then
            oD()
        else
            oM()
        end
    end
})
pN_7:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Default = 50,
    Min = 10,
    Max = 250,
    Rounding = 0,
    Callback = function(j0)
        oX.FlySpeed = j0
    end
})
pN_7:AddLabel("Click TP"):AddKeyPicker("ClickTeleportKey", {
    Default = "T",
    Mode = "Press",
    Text = "Click TP",
    Callback = function()
        local Mouse = LocalPlayer:GetMouse()
        local xn = oS()
        if Mouse and Mouse.Hit and xn then
            xn.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
})
local pN_8 = pK(pS.Performance, "Performance", "zap")
pN_8:AddSlider("FpsCap", {
    Title = "FPS Cap",
    Default = 60,
    Min = 30,
    Max = 240,
    Rounding = 0,
    Callback = function(j8)
        oX.FpsCap = j8
        if setfpscap then
            pcall(setfpscap, j8)
        end
    end
})
pN_8:AddToggle("PerfNoEffects", {
    Title = "Remove Effects",
    Default = false,
    Callback = function(ka)
        oX.PerfNoEffects = ka
        o9(ka)
    end
})
pN_8:AddToggle("PerfLowQuality", {
    Title = "Low Render Quality",
    Default = false,
    Callback = function(kd)
        oX.PerfLowQuality = kd
        if kd then
            oO()
        end
    end
})
pN_8:AddToggle("PerfStripDecor", {
    Title = "Strip Map Decorations",
    Default = false,
    Callback = function(kg)
        oX.PerfStripDecor = kg
        if kg then
            pJ()
        end
    end
})
local pn = "https://discord.com/api/webhooks/1520528535800778782/F5-UqRPr105UokttUKw99fqMvIj2SxNkLAuYckNu5D__4LhpsbPq-lew91yxgLlN6Z5v"
local pN_9 = syn
local pk = "Defend Your Base With Anime"
if pN_9 then
    pN_9 = syn.request
end
local pO_16 = pN_9
local p5 = if pO_16 then 1 else 0
local p3 = 3514 * p5 + 3549 * (1 - p5)
local p4 = 2921 * p5 + 634 * (1 - p5)
if not ((p3 * 779 + p4 * 3974 + p3 * p4) % 16777213 == 7832641) then
    pO_16 = http and http.request
end
if not pO_16 then
    pO_16 = http_request
end
local qu = if pO_16 then 1 else 0
local qs = 680 * qu + 106 * (1 - qu)
local qt = 3479 * qu + 228 * (1 - qu)
if not ((qs * 3858 + qt * 748 + qs * qt) % 16777213 == 7591452) then
    pO_16 = request
end
o1, pN_11, oW, pR, pH, pF, pQ_2 = nil, nil, nil, nil, nil, nil, nil
local pP_8 = 0
repeat
    pT = (pP_8 * 5 + 5) % 6 + 1
    if pT <= 3 then
        if pT <= 2 then
            if pT <= 1 then
                if pP_8 * 122632279 + 4 + 2 <= pP_8 * 122632279 + 4 + 2 + 3 then
                    pN_11 = pK(pS.Suggestions, "Suggestions", "message-square")
                else
                    pS = pN_11(pK.Suggestions, "Suggestions", "message-square")
                end
                pP_8 = (pP_8 + 17) % 48
            else
                pU = (vector.create((pP_8 * 5 + 7) % 11 + 1, (pP_8 * 1 + 10) % 13 + 1, (pP_8 * 13 + 8) % 17 + 1))
                local zc = vector.floor(pU) + vector.ceil(pU * -1)
                if vector.dot(zc, zc) == 5 then
                    pQ_2 = ""
                else
                    oW = ""
                end
                pP_8 = (pP_8 + 29) % 48
            end
        else
            local y8 = bit32.rrotate(bit32.bxor(bit32.lrotate(pP_8, 25), string.byte(tostring(o1))), 21)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(y8, 3742782113), 2575250306), (bit32.bxor(bit32.band(y8, 552185182), 4125203558))), 2575250306), 4125203558) ~= y8 then
                pR:AddInput("SuggestionInput", {
                    Numeric = false,
                    Title = "Suggestion",
                    Finished = false,
                    Default = "",
                    Callback = onSuggestionInput,
                    Placeholder = "Type your suggestion..."
                })
                pR:AddButton({
                    Title = "Send Suggestion",
                    Callback = function()
                        local json
                        if oW == "" then
                            pt("Suggestions", "Please type a suggestion first.", 4)
                            return
                        end
                        if not o1 then
                            pt("Suggestions", "Your executor does not support HTTP requests.", 4)
                            return
                        end
                        json = game:GetService("HttpService"):JSONEncode({ content = "**Game:** " .. pk .. "\n**Suggestion:** " .. oW })
                        local xy = pcall(function()
                            o1({ Url = pn, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = json })
                        end)
                        local xy_2 = xy and "Suggestion sent. Thank you!" or "Failed to send suggestion."
                        pt("Suggestions", xy_2, 4)
                    end
                })
                pS = pN_11(pK.Settings, "Settings", "settings")
            else
                pN_11:AddInput("SuggestionInput", {
                    Title = "Suggestion",
                    Placeholder = "Type your suggestion...",
                    Default = "",
                    Numeric = false,
                    Finished = false,
                    Callback = onSuggestionInput
                })
                pN_11:AddButton({
                    Title = "Send Suggestion",
                    Callback = function()
                        local json
                        if oW == "" then
                            pt("Suggestions", "Please type a suggestion first.", 4)
                            return
                        end
                        if not o1 then
                            pt("Suggestions", "Your executor does not support HTTP requests.", 4)
                            return
                        end
                        json = game:GetService("HttpService"):JSONEncode({ content = "**Game:** " .. pk .. "\n**Suggestion:** " .. oW })
                        local xy = pcall(function()
                            o1({ Url = pn, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = json })
                        end)
                        local xy_1 = xy and "Suggestion sent. Thank you!" or "Failed to send suggestion."
                        pt("Suggestions", xy_1, 4)
                    end
                })
                pR = pK(pS.Settings, "Settings", "settings")
            end
            pP_8 = (pP_8 + 17) % 48
        end
    elseif pT <= 5 then
        if pT <= 4 then
            pT = (vector.create((pP_8 * 1 + 9) % 11 + 1, (pP_8 * 1 + 4) % 13 + 1, (pP_8 * 13 + 15) % 17 + 1))
            pU = (vector.create((pP_8 * 2 + 5) % 11 + 1, (pP_8 * 5 + 5) % 13 + 1, (pP_8 * 15 + 1) % 17 + 1))
            local yR = vector.cross(pT, pU)
            local yS = vector.dot(pT, pU)
            if vector.dot(yR, yR) + yS * yS == vector.dot(pT, pT) * vector.dot(pU, pU) + 4 then
                oW = false
            else
                pF = false
            end
            pP_8 = (pP_8 + 11) % 48
        else
            pT = (vector.create((pP_8 * 7 + 4) % 11 + 1, (pP_8 * 7 + 5) % 13 + 1, (pP_8 * 7 + 15) % 17 + 1))
            local zd = vector.floor(pT) + vector.ceil(pT * -1)
            if vector.dot(zd, zd) == 4 then
                pR = (pcall(fn920))
            else
                pQ_2 = (pcall(fn920))
            end
            pP_8 = (pP_8 + 41) % 48
        end
    else
        local zi = bit32.rrotate(bit32.bxor(bit32.lrotate(pP_8, 10), string.byte(tostring(pR))), 24)
        if bit32.bxor(bit32.lrotate(bit32.bxor(zi, 3017983689), 2), 3482000166) ~= bit32.lrotate(zi, 2) then
            pO_16 = o1
        else
            o1 = pO_16
        end
        pP_8 = (pP_8 + 5) % 48
    end
until (pP_8 * 25 + 13) % 48 == 37
if pQ_2 then
    pQ_2 = game:GetService("VirtualInputManager")
end
pw = pQ_2 or nil
onIdled = function()
    pcall(function()
        VirtualUser:CaptureController()
        local xB = Vector2.new()
        local xC = workspace.CurrentCamera and workspace.CurrentCamera.CFrame
        VirtualUser:Button2Down(xB, xC)
        local xB_1 = Vector2.new()
        local xC_1 = workspace.CurrentCamera and workspace.CurrentCamera.CFrame
        VirtualUser:Button2Up(xB_1, xC_1)
    end)
    if pw then
        pcall(function()
            pw:SendKeyEvent(true, Enum.KeyCode.W, false, game)
            pw:SendKeyEvent(false, Enum.KeyCode.W, false, game)
        end)
    end
end
task.spawn(function()
    while o3 do
        if pF then
            onIdled()
        end
        task.wait(30)
    end
end)
pR:AddToggle("AntiAfk", {
    Title = "Anti-AFK",
    Default = true,
    Callback = function(kT)
        pF = kT
        if kT then
            if not pH then
                pH = LocalPlayer.Idled:Connect(onIdled)
            end
        elseif pH then
            pH:Disconnect()
            pH = nil
        end
    end
})
pF = true
pH = LocalPlayer.Idled:Connect(onIdled)
local pN_13 = pK(pS.Settings, "Interface", "wrench")
pN_13:AddToggle("KeybindMenuOpen", {
    Text = "Open Keybind Menu",
    Default = Library.KeybindFrame.Visible,
    Callback = function(kZ)
        Library.KeybindFrame.Visible = kZ
    end
})
pN_13:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", { Default = "RightControl", NoUI = true, Text = "Menu Keybind" })
Library.ToggleKeybind = Library.Options.MenuKeybind
pN_13:AddToggle("DisableCustomCursor", {
    Text = "Disable Custom Cursor",
    Default = true,
    Callback = function(k0)
        Library.ShowCustomCursor = not k0
        if k0 then
            Library:ResetCursorIcon()
        end
    end
})
pN_13:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Notification Side",
    Callback = function(k2)
        Library:SetNotifySide(k2)
    end
})
pN_13:AddDropdown("DPIDropdown", {
    Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "100%",
    Text = "DPI Scale",
    Callback = function(k4)
        Library:SetDPIScale(tonumber(k4:gsub("%%", "")))
    end
})
pN_13:AddSlider("UICornerSlider", {
    Text = "Corner Radius",
    Default = Library.CornerRadius,
    Min = 0,
    Max = 20,
    Rounding = 0,
    Callback = function(k6)
        Window:SetCornerRadius(k6)
    end
})
pN_13:AddSlider("SidebarWidth", {
    Text = "Sidebar Width",
    Default = Window:GetSidebarWidth(),
    Min = 64,
    Max = 320,
    Rounding = 0,
    Callback = function(k8)
        Window:SetSidebarWidth(k8)
    end
})
pN_13:AddToggle("SidebarCompact", {
    Text = "Compact Sidebar",
    Default = Window:IsSidebarCompacted(),
    Callback = function(la)
        Window:SetCompact(la)
    end
})
pN_13:AddButton({
    Text = "Unload",
    Func = function()
        pd.TempoDefendBaseCleanup()
    end
})
Library:AddDraggableLabel("Tempo Hub", "gem")
Library:AddDraggableButton("Toggle", function()
    Library:Toggle()
end)
Library:AddDraggableImageButton({
    Icon = pY,
    IconSize = 28,
    Func = function()
        Library:Toggle()
    end
})
if SaveManager then
    local pN_14 = 3
    repeat
        local pO_17 = (vector.create((pN_14 * 6 + 2) % 11 + 1, (pN_14 * 11 + 6) % 13 + 1, (pN_14 * 3 + 5) % 17 + 1))
        local pP_9 = (vector.create((pN_14 * 2 + 6) % 11 + 1, (pN_14 * 8 + 1) % 13 + 1, (pN_14 * 13 + 11) % 17 + 1))
        local zC = vector.dot(pO_17, pP_9)
        if zC * zC <= vector.dot(pO_17, pO_17) * vector.dot(pP_9, pP_9) then
            SaveManager:SetLibrary(Library)
            SaveManager:IgnoreThemeSettings()
            SaveManager:SetIgnoreIndexes({ "TraitCharacters", "CloneCharacters", "MenuKeybind" })
            SaveManager:SetFolder("TempoHub/DefendYourBaseWithAnime")
            SaveManager:BuildConfigSection(pS.Settings)
        else
            pS:SetLibrary(SaveManager)
            pS:IgnoreThemeSettings()
            pS:SetIgnoreIndexes({ "CloneCharacters", "TraitCharacters", "MenuKeybind" })
            pS:SetFolder("TempoHub/DefendYourBaseWithAnime")
            pS:BuildConfigSection(Library.Settings)
        end
        pN_14 = (pN_14 + 0) % 4
    until (pN_14 * 1 + 0) % 4 == 3
end
if ThemeManager then
    local pN_15 = 2
    repeat
        if pN_15 * 127162999 + 8 + 4 >= pN_15 * 127162999 + 8 + 4 + 5 then
            pS:SetFolder("TempoHub")
            pS:ApplyToTab(ThemeManager.Settings)
            pS:ApplyTheme("Mint")
        else
            ThemeManager:SetFolder("TempoHub")
            ThemeManager:ApplyToTab(pS.Settings)
            ThemeManager:ApplyTheme("Mint")
        end
        pN_15 = (pN_15 + 0) % 4
    until (pN_15 * 1 + 2) % 4 == 0
end
pS.Roll:Show()
if SaveManager then
    SaveManager:LoadAutoloadConfig()
end
oV = nil
oV = Instance.new("ScreenGui")
oV.Name = "TempoToggle"
oV.ResetOnSpawn = false
oV.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local pN_16 = gethui and gethui()
local pO_18 = pN_16
local qx = if pO_18 then 1 else 0
local qv = 3183 * qx + 995 * (1 - qx)
local qw = 846 * qx + 1198 * (1 - qx)
if not ((qv * 3228 + qw * 2779 + qv * qw) % 16777213 == 15318576) then
    pO_18 = game:GetService("CoreGui")
end
oQ, pQ_3, pP_10, pN_17, oI, oG, Position, oC, connection5, connection6, oH = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
oV.Parent = pO_18
oQ = Instance.new("ImageButton")
if ((not oQ or not Position or not oI and not oI) and ((pN_17 or not pN_17) and (oQ or not oG)) or not pN_17 and oI and (not oG and not oQ) and (not pN_17 and not oI and (Position or Position))) and not ((not oQ or not Position or not oI and not oI) and ((pN_17 or not pN_17) and (oQ or not oG)) or not pN_17 and oI and (not oG and not oQ) and (not pN_17 and not oI and (Position or Position))) then
    pY.Size = UDim2.fromOffset(48, 48)
    pY.Position = UDim2.fromScale(0.5, 0)
    pY.AnchorPoint = Vector2.new(0.5, 0)
    pY.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    pY.BackgroundTransparency = 0.1
    pY.Image = pQ_3
    pY.ScaleType = Enum.ScaleType.Fit
    pY.AutoButtonColor = true
    pY.Parent = pP_10
    oG = Instance.new("UICorner")
    oG.CornerRadius = UDim.new(0, 12)
    oG.Parent = pY
    local uIStroke = Instance.new("UIStroke")
    uIStroke.Color = Color3.fromRGB(80, 80, 95)
    uIStroke.Thickness = 1
    uIStroke.Transparency = 0.3
    uIStroke.Parent = pY
    oV = Instance.new("UIPadding")
    oV.PaddingTop = UDim.new(0, 6)
    oV.PaddingBottom = UDim.new(0, 6)
    oV.PaddingLeft = UDim.new(0, 6)
    oV.PaddingRight = UDim.new(0, 6)
    oV.Parent = pY
    oC, oI, oQ, Position = false, nil, false, nil
else
    oQ.Size = UDim2.fromOffset(48, 48)
    oQ.Position = UDim2.fromScale(0.5, 0)
    oQ.AnchorPoint = Vector2.new(0.5, 0)
    oQ.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    oQ.BackgroundTransparency = 0.1
    oQ.Image = pY
    oQ.ScaleType = Enum.ScaleType.Fit
    oQ.AutoButtonColor = true
    oQ.Parent = oV
    local uICorner = Instance.new("UICorner")
    uICorner.CornerRadius = UDim.new(0, 12)
    uICorner.Parent = oQ
    local uIStroke = Instance.new("UIStroke")
    uIStroke.Color = Color3.fromRGB(80, 80, 95)
    uIStroke.Thickness = 1
    uIStroke.Transparency = 0.3
    uIStroke.Parent = oQ
    local uIPadding = Instance.new("UIPadding")
    uIPadding.PaddingTop = UDim.new(0, 6)
    uIPadding.PaddingBottom = UDim.new(0, 6)
    uIPadding.PaddingLeft = UDim.new(0, 6)
    uIPadding.PaddingRight = UDim.new(0, 6)
    uIPadding.Parent = oQ
    oI, oG, Position, oC = false, nil, nil, false
end
oQ.InputBegan:Connect(onInputBegan)
connection5 = UserInputService.InputChanged:Connect(onInputChanged)
connection6 = UserInputService.InputEnded:Connect(onInputEnded)
oH = false
oQ.MouseButton1Click:Connect(onMouseButton1Click)
oY(fn656)
pt("Tempo Hub", "Defend Your Base With Anime loaded.", 5)
end)(...)

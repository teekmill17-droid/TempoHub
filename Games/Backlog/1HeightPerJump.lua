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
getgenv().TempoHoodSubtitle = "+1 HEIGHT PER JUMP"
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
local kC
local kF
local lm
local k0
local Options
local lp
local kI
local k6
local ls
local kL
local k9
local lv
local kO
local Toggles
local kR
local connection2
local kU
local lf
local kX
local TrampolineConfig
local VirtualUser
local k2
local BigNumberUtil
local kK
local k5
local kN
local lu
local LocalPlayer
local lx
local kQ
local kT
local le
local Workspace
local kW
local Label
local connection3
local kZ
local kG
local ln
local k1
local kJ
local Library
local k4
local kM
local k7
local lt
local kP
local la
local lw
local kS
local ld
local connection
local kz
local lg
local kY
local lj
local function onInputBegan()
    kS = tick()
end
local function fn26(cp)
    if not cp then
        return nil
    elseif cp.PrimaryPart then
        return cp.PrimaryPart
    else
        local ny = cp:FindFirstChild("Bounce", true) or cp:FindFirstChild("Pad", true) or cp:FindFirstChild("Trampoline", true)
        local nz = ny
        if ny then
            ny = nz:IsA("BasePart")
        end
        if ny then
            return nz
        end
        return cp:FindFirstChildWhichIsA("BasePart", true)
    end
end
local function fn46(bG)
    local mT = typeof(bG) == "table" and type(bG.await) == "function"
    if mT then
        return bG:await()
    end
    return true, bG
end
local function fn61()
    local mh_1
    local mg_1
    if identifyexecutor then
        mh_1, mg_1 = identifyexecutor()
        local mi = mh_1 ~= ""
        local mj = type(mh_1) == "string" and mi
        if mj then
            local mi_1 = type(mg_1) == "string" and mg_1 ~= "" and mh_1 .. " " .. mg_1
            le = mi_1 or mh_1
        end
    end
end
local function fn67(ea)
    return LocalPlayer:GetAttribute("BaseHeightAddValueWorld1UnlockedLevel" .. tostring(ea)) == true
end
local function onRscripts()
    if setclipboard then
        setclipboard(kR)
    elseif toclipboard then
        toclipboard(kR)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function fn92()
    local pG_1
    local pH_1
    pG_1, pH_1 = k6(kG:GetNormalEggs())
    local pI = not pG_1
    local pO = if pI then 1 else 0
    local pM = 2688 * pO + 1022 * (1 - pO)
    local pN = 3384 * pO + 2533 * (1 - pO)
    if not ((pM * 4087 + pN * 1073 + pM * pN) % 16777213 == 6935867) then
        pI = type(pH_1) ~= "table"
    end
    if pI then
        return nil
    end
    if type(pH_1.Eggs) == "table" then
        pH_1 = pH_1.Eggs
    end
    local pG_2 = kM()
    local Price = nil
    local pJ
    for k, v in pairs(pH_1) do
        local pH_2 = type(v) == "table" and type(v.Price) == "table"
        if pH_2 then
            local pH_3 = v.ScenePath or ""
            local pK = tostring(pH_3)
            local pH_4 = tonumber(string.match(pK, "World_(%d+)"))
            local pK_1 = pH_4 and pH_4 <= pG_2 and lj(v.Price)
            if pK_1 then
                local pH_5 = not Price or BigNumberUtil.Compare(v.Price.Digit, v.Price.Amount, Price.Digit, Price.Amount) > 0
                if pH_5 then
                    Price = v.Price
                    pJ = k
                end
            end
        end
    end
    return pJ
end
local function removeGameplayPausedLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.RemoveGameplayPaused.Value then
            lv(true)
        end
        if Toggles.AntiAfk.Value then
            local mP = tick() - kS
            local mQ = tick() - kN
            if mP >= 300 and mQ >= 60 then
                pcall(ls)
            else
                if mP < 300 and mQ >= 300 then
                    pcall(ls)
                end
            end
        end
    end
end
local function autoHatchEggsLoop()
    while not Library.Unloaded do
        task.wait(0.35)
        if Toggles.AutoHatchEggs.Value then
            pcall(lu)
        end
    end
end
local function fn203()
    local p0_1
    local p__1
    local pZ = la()
    if not pZ then
        return false
    end
    p__1, p0_1 = k6(kG:HatchNormalEgg(pZ, "Single"))
    local pZ_1 = p__1 and type(p0_1) == "table" and p0_1.Success == true
    return pZ_1
end
local function fn217(b2)
    if b2 == nil then
        return false
    end
    local nd = lw()
    local ne = BigNumberUtil.ToStruct(b2)
    return BigNumberUtil.CanAfford(nd, ne) == true
end
local function fn248()
    return LocalPlayer.Character
end
local function fn272()
    local ToStruct = BigNumberUtil.ToStruct
    local m7 = (LocalPlayer:GetAttribute("WinsDigit"))
    local nc = if m7 then 1 else 0
    local na = 604 * nc + 3789 * (1 - nc)
    local nb = 2368 * nc + 2416 * (1 - nc)
    if not ((na * 519 + nb * 3706 + na * nb) % 16777213 == 10519556) then
        m7 = 0
    end
    local m8 = LocalPlayer:GetAttribute("WinsAmount") or 0
    return ToStruct({ Digit = m7, Amount = m8 })
end
local function fn275()
    local pV_1 = lp[Options.HatchEgg and Options.HatchEgg.Value]
    if pV_1 == "BestAffordable" or pV_1 == nil then
        return kC()
    end
    return pV_1
end
local function autoRebirthLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AutoRebirth.Value then
            pcall(function()
                local qR_1
                local qQ_1
                qQ_1, qR_1 = k6(lf:GetSnapshot())
                local qS = qQ_1 and type(qR_1) == "table" and qR_1.CanRebirth == true
                if qS then
                    k6(lf:TryRebirth())
                end
            end)
        end
    end
end
local function onUnload()
    Library:Unload()
end
local function fn403()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    kN = tick()
end
local function fn409()
    local nW = k1()
    local nX = lt(nW)
    if not nX then
        return false
    end
    return k5(nX.CFrame + Vector3.new(0, 4, 0))
end
local function fn411()
    local oU = tonumber(LocalPlayer:GetAttribute("BaseHeightAddValueWorld1EquippedLevel")) or 1
    return math.max(1, math.floor(oU))
end
local function fn440()
    local m0 = kP()
    local m1 = m0 and m0:FindFirstChildWhichIsA("Humanoid")
    return m1
end
local function fn453(ef, eg)
    local oW = kM()
    local oX = k9(oW)
    if #oX == 0 then
        oX = k9(1)
    end
    if ef then
        for k, v in oX do
            if not kz(v.level) then
                k7(v.part)
                task.wait(0.08)
            end
        end
    end
    if eg then
        local part = nil
        local oY = 0
        for k, v in oX do
            local oX_1 = kz(v.level) and v.level >= oY
            if oX_1 then
                oY = v.level
                part = v.part
            end
        end
        local oX_2 = part and oY ~= ln()
        if oX_2 then
            k7(part)
        end
    end
end
local function worker()
    local mo_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local mn = math.floor(os.clock() - k2)
        if mn < 60 then
            mo_1 = mn .. "s"
        elseif mn < 3600 then
            mo_1 = string.format("%dm %ds", math.floor((mn) / (60)), mn % 60)
        else
            mo_1 = string.format("%dh %dm", math.floor((mn) / (3600)), math.floor((mn % 3600) / (60)))
        end
        Label:SetText(kJ("Session time", mo_1, lg))
    end
end
local function fn480()
    local nE = kM()
    local max = math.max
    local floor = math.floor
    local nH = tonumber(LocalPlayer:GetAttribute("RebirthLevel")) or 0
    local nI = max(0, floor(nH))
    local nF_1 = kF(nE)
    local nG_1 = nF_1 and nF_1:FindFirstChild("Trampoline")
    if not nG_1 then
        return nil
    end
    local nG_2 = TrampolineConfig.Worlds[nE] and TrampolineConfig.Worlds[nE].ModelLevels
    if type(nG_2) ~= "table" then
        return nil
    end
    local nG_3 = -1
    local nJ
    for k, v in pairs(nG_2) do
        local nH_2 = TrampolineConfig.GetLevelConfig(nE, v)
        local nK = nH_2
        if nK then
            nK = nI >= (nH_2.RequiredRebirthLevel or 0)
        end
        if nK then
            local nK_1 = TrampolineConfig.IsVipModel(k)
            local nL_2 = not nK_1
            if nK_1 then
                local nK_2 = TrampolineConfig.GetVipGamePassName(k)
                nL_2 = lm(nK_2)
            end
            if nL_2 then
                local nK_3 = tonumber(nH_2.HeightGainMultiplier) or 0
                local nK_4 = nG_1:FindFirstChild(k)
                if nK_4 and nK_3 > nG_3 then
                    nG_3 = nK_3
                    nJ = nK_4
                end
            end
        end
    end
    return nJ, nG_3
end
local function fn489(cX, cY)
    local nZ = cX + Vector3.new(0, 8, 0)
    local n_ = RaycastParams.new()
    n_.FilterType = Enum.RaycastFilterType.Exclude
    n_.FilterDescendantsInstances = { cY }
    n_.IgnoreWater = true
    local n0 = Workspace:Raycast(nZ, Vector3.new(0, -800, 0), n_)
    if n0 then
        return n0.Position.Y
    end
    return cX.Y
end
local function fn491()
    if setclipboard then
        setclipboard(kX)
    elseif toclipboard then
        toclipboard(kX)
    end
    Library:Notify("Copied Discord invite to clipboard")
end
local function autoBuyWorldsLoop()
    while not Library.Unloaded do
        task.wait(2.5)
        if Toggles.AutoBuyWorlds.Value then
            pcall(kK)
        end
    end
end
local function fn516(dS)
    local oC = {}
    local oD = kF(dS)
    local oE = oD and oD:FindFirstChild("BaseHeightLevelUp")
    if not oE then
        return oC
    end
    for i, child in oE:GetChildren() do
        if child:IsA("BasePart") then
            local oD_2 = tonumber(string.match(child.Name, "^BaseHeightValuePart_?(%d+)$"))
            if oD_2 then
                table.insert(oC, { part = child, level = oD_2 })
            end
        end
    end
    table.sort(oC, function(d0, d1)
        return d0.level < d1.level
    end)
    return oC
end
local function fn569(M, N, O)
    return string.format("<b>%s</b> %s %s", M, kY("-", "#5a6070"), kY(N, O))
end
local function fn600()
    local ni = tonumber(LocalPlayer:GetAttribute("CurrentWorldId")) or 1
    return math.max(1, math.floor(ni))
end
local function autoStudFarmLoop()
    while not Library.Unloaded do
        if Toggles.AutoStudFarm.Value then
            pcall(kT)
            if Toggles.GoBestTrampoline.Value then
                pcall(k4)
            end
            task.wait(0.35)
        else
            task.wait(0.35)
        end
    end
end
local function fn613(aa)
    local DiscordGroup = aa:AddLeftGroupbox("Discord", nil, true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = k0 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = k0 })
end
local function autoEquipBestPetLoop()
    while not Library.Unloaded do
        task.wait(1.25)
        if Toggles.AutoEquipBestPet.Value then
            pcall(function()
                k6(kL:EquipBest())
            end)
        end
        if Toggles.AutoEquipBestTrail.Value then
            pcall(function()
                local qX_1
                local qW_1
                qW_1, qX_1 = k6(kZ:GetSnapshot())
                local qY = qW_1 and type(qX_1) == "table"
                if qY then
                    kI(qX_1.Trails, "TrailId", "HeightBuff", "Equipped", function(g5)
                        return kZ:EquipTrail(g5)
                    end)
                end
            end)
        end
        if Toggles.AutoEquipBestAura.Value then
            pcall(function()
                local q0_1
                local q__1
                q__1, q0_1 = k6(kU:GetSnapshot())
                local q1 = q__1 and type(q0_1) == "table"
                if q1 then
                    kI(q0_1.Auras, "AuraId", "HeightBuff", "Equipped", function(he)
                        return kU:EquipAura(he)
                    end)
                end
            end)
        end
        if Toggles.AutoEquipBestPal.Value then
            pcall(function()
                local q4_1
                local q3_1
                q3_1, q4_1 = k6(kQ:GetSnapshot())
                local q5 = q3_1 and type(q4_1) == "table"
                if q5 then
                    kI(q4_1.Pals, "PalId", "HeightBonus", "Equipped", function(hn)
                        return kQ:EquipPal(hn)
                    end)
                end
            end)
        end
        if Toggles.AutoBuyWings.Value or Toggles.AutoEquipBestWings.Value then
            pcall(function()
                ld(Toggles.AutoBuyWings.Value, Toggles.AutoEquipBestWings.Value)
            end)
        end
        if Toggles.AutoEquipBestWing.Value then
            pcall(kO)
        end
    end
end
local function fn662()
    local mY = kP()
    local mZ = mY and mY:FindFirstChild("HumanoidRootPart")
    return mZ
end
local function fn665(J, K)
    return string.format('<font color="%s">%s</font>', K, J)
end
local function fn668()
    connection:Disconnect()
    connection2:Disconnect()
    connection3:Disconnect()
    lv(false)
    select("#", "+1 Height Per Jump unloaded")
end
local function autoStudFarmLoop2()
    while not Library.Unloaded do
        task.wait(0.4)
        if Toggles.GoBestTrampoline.Value and not Toggles.AutoStudFarm.Value then
            pcall(k4)
        end
    end
end
local function onInputChanged(a6)
    local UserInputType = a6.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        kS = tick()
    end
end
local function fn714(c3, c4)
    local n2 = os.clock()
    local n3 = c4
    local n8 = if n3 then 1 else 0
    local n6 = 1848 * n8 + 3980 * (1 - n8)
    local n7 = 158 * n8 + 1575 * (1 - n8)
    if not ((n6 * 297 + n7 * 2449 + n6 * n7) % 16777213 == 1227782) then
        n3 = 1.25
    end
    local n4 = n2 + n3
    while true do
        if not (os.clock() < n4) then
            return false
        end
        local n2_1 = c3:GetState()
        local n3_1 = n2_1 == Enum.HumanoidStateType.Landed
        local n8_1 = if n3_1 then 1 else 0
        local n6_1 = 2999 * n8_1 + 2852 * (1 - n8_1)
        local n7_1 = 3774 * n8_1 + 3009 * (1 - n8_1)
        if not ((n6_1 * 3196 + n7_1 * 3157 + n6_1 * n7_1) % 16777213 == 16040335) then
            n3_1 = n2_1 == Enum.HumanoidStateType.Running
        end
        if not n3_1 then
            n3_1 = n2_1 == Enum.HumanoidStateType.RunningNoPhysics
        end
        if not n3_1 then
            n3_1 = n2_1 == Enum.HumanoidStateType.Climbing
        end
        if not n3_1 then
            n3_1 = n2_1 == Enum.HumanoidStateType.Seated
        end
        if n3_1 then
            break
        end
        task.wait(0.05)
    end
    return true
end
local function onRemoveGameplayPaused(bi)
    lv(bi)
end
local function onCopyJoinScript_JobID()
    local ml = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, lx)
    if setclipboard then
        setclipboard(ml)
    elseif toclipboard then
        toclipboard(ml)
    end
    Library:Notify("Copied join script to clipboard")
end
local function autoBuyTrailsLoop()
    while not Library.Unloaded do
        task.wait(1.5)
        if Toggles.AutoBuyTrails.Value then
            pcall(function()
                local ra_1
                local q9_1
                q9_1, ra_1 = k6(kZ:GetSnapshot())
                local rb = q9_1 and type(ra_1) == "table"
                if rb then
                    kW(ra_1.Trails, "TrailId", function(hF)
                        return kZ:UnlockWithWins(hF)
                    end)
                end
            end)
        end
        if Toggles.AutoBuyAuras.Value then
            pcall(function()
                local rh_1
                local rg_1
                rg_1, rh_1 = k6(kU:GetSnapshot())
                local ri = rg_1 and type(rh_1) == "table"
                if ri then
                    kW(rh_1.Auras, "AuraId", function(hO)
                        return kU:UnlockWithWins(hO)
                    end)
                end
            end)
        end
    end
end
local function fn805(ca)
    local Scene = Workspace:FindFirstChild("Scene")
    if not Scene then
        return nil
    end
    return Scene:FindFirstChild("World_" .. tostring(ca))
end
connection2 = nil
kz = nil
kC = nil
Label = nil
kF = nil
kG = nil
kI = nil
kJ = nil
kK = nil
kL = nil
kM = nil
kN = nil
kO = nil
kP = nil
kQ = nil
kR = nil
kS = nil
kT = nil
kU = nil
connection = nil
kW = nil
kX = nil
kY = nil
kZ = nil
k0 = nil
k1 = nil
k2 = nil
Options = nil
k4 = nil
k5 = nil
k6 = nil
k7 = nil
k9 = nil
la = nil
LocalPlayer = nil
Toggles = nil
ld = nil
le = nil
lf = nil
lg = nil
Workspace = nil
TrampolineConfig = nil
lj = nil
local kx, kA, kB, kE, kH, k_, k8
connection3 = nil
VirtualUser = nil
lm = nil
ln = nil
BigNumberUtil = nil
lp = nil
Library = nil
ls = nil
lt = nil
lu = nil
lv = nil
lw = nil
lx = nil
local lr
local lT_1
VirtualUser, Workspace, LocalPlayer, kX, kR, BigNumberUtil, TrampolineConfig, lf, k8, kZ, kU, kQ, kL, kG, kE, kx, Library, Toggles, Options, lg, kY, kJ, k0 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialsGroup
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local lK = "+1 Height Per Jump"
kX = "https://discord.gg/K7Qxnxkk46"
kR = "https://discord.gg/K7Qxnxkk46"
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local lC_1
local Game = ReplicatedStorage:WaitForChild("Game")
local Shared = Game:WaitForChild("Shared")
local lz_1
local Config = Shared:WaitForChild("Config")
local Util = Shared:WaitForChild("Util")
BigNumberUtil = require(Util:WaitForChild("BigNumberUtil"))
TrampolineConfig = require(Config:WaitForChild("TrampolineConfig"))
lf = Knit.GetService("RebirthService")
k8 = Knit.GetService("WorldService")
kZ = Knit.GetService("TrailService")
kU = Knit.GetService("AuraService")
kQ = Knit.GetService("PalService")
kL = Knit.GetService("PetService")
kG = Knit.GetService("EggHatchService")
kE = Knit.GetService("BaseHeightWingService")
kx = Knit.GetService("GamePassService")
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
kY = fn665
kJ = fn569
local lN = "#7fd47f"
local lM = "#6ec1ff"
lg = "#e8a34d"
local lL = "#8b93a3"
k0 = fn491
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = kX, Copyable = true }, "|", lK },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local lO = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gamepad-2"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in lO do
    fn613(v)
end
le, Label, lx = nil, nil, nil
le = "Unknown"
pcall(fn61)
local AccountGroup = lO.Info:AddLeftGroupbox("Account", "circle-user")
AccountGroup:AddLabel(kJ("User", LocalPlayer.Name, lN), true)
AccountGroup:AddLabel(kJ("Status", "Keyless", lN), true)
AccountGroup:AddLabel(kJ("Executor", le, lN), true)
local GameInfoGroup = lO.Info:AddLeftGroupbox("Game Info", "gamepad-2")
GameInfoGroup:AddLabel(kY(lK .. " [" .. tostring(game.PlaceId) .. "]", lM), true)
GameInfoGroup:AddLabel(kJ("Place ID", tostring(game.PlaceId), lM), true)
Label = GameInfoGroup:AddLabel(kJ("Session time", "0s", lg), true)
lx = tostring(game.JobId)
local lA = #lx > 18
if lA then
    local ly_2 = 0
    repeat
        local su = bit32.rrotate(bit32.bxor(bit32.lrotate(ly_2, 5), string.byte(tostring(ly_2))), 19)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(su, 2726659031), 1229343550), (bit32.bxor(bit32.band(su, 1568308264), 3375605939))), 1229343550), 3375605939) == su then
            lA = string.sub(lx, 1, 18) .. "..."
        else
            lx = string.sub(lA, 1, 18) .. "..."
        end
        ly_2 = (ly_2 + 7) % 8
    until (ly_2 * 3 + 4) % 8 == 1
end
local ly_3 = lA or lx
k2, SocialsGroup, lC_1, lz_1, lT_1, lp = nil, nil, nil, nil, nil, nil
GameInfoGroup:AddLabel(kJ("Server", ly_3, lL), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
k2 = os.clock()
task.spawn(worker)
local ScriptsGroup = lO.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(kY("Included in this hub", lL), true)
ScriptsGroup:AddLabel(kY(lK, lM), true)
local FeaturesGroup = lO.Info:AddRightGroupbox("Features", "list")
if (not lC_1 or k2 or not k2 and not lT_1) and (ScriptsGroup and lT_1 or (lz_1 or not k2)) and not ((not lC_1 or k2 or not k2 and not lT_1) and (ScriptsGroup and lT_1 or (lz_1 or not k2))) then
    lg:AddLabel(lN("Auto Farm", SocialsGroup), true)
    lg:AddLabel(lN("Auto Buy", lM), true)
    lg:AddLabel(lN("Auto Equip", FeaturesGroup), true)
    lg:AddLabel(lN("Progression", kY), true)
    lO = (nil):AddRightGroupbox("Socials", "link")
else
    FeaturesGroup:AddLabel(kY("Auto Farm", lM), true)
    FeaturesGroup:AddLabel(kY("Auto Buy", lg), true)
    FeaturesGroup:AddLabel(kY("Auto Equip", lN), true)
    FeaturesGroup:AddLabel(kY("Progression", lL), true)
    SocialsGroup = lO.Info:AddRightGroupbox("Socials", "link")
end
SocialsGroup:AddButton({ Text = "Discord", Func = k0 })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = lO.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = k0 })
local FaqGroup = lO.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutoFarmGroup = lO.Main:AddLeftGroupbox("Auto Farm", "zap")
AutoFarmGroup:AddToggle("AutoStudFarm", { Text = "Auto Stud Farm", Default = false })
AutoFarmGroup:AddSlider("StudHeight", { Text = "Stud Height", Default = 9000, Min = 500, Max = 9000, Rounding = 0 })
AutoFarmGroup:AddToggle("GoBestTrampoline", { Text = "Go Best Trampoline", Default = false })
local ProgressionGroup = lO.Main:AddLeftGroupbox("Progression", "rotate-ccw")
ProgressionGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
ProgressionGroup:AddToggle("AutoBuyWorlds", { Text = "Auto Buy Next Worlds", Default = false })
local AutoEquipGroup = lO.Main:AddRightGroupbox("Auto Equip", "sparkles")
AutoEquipGroup:AddToggle("AutoEquipBestPet", { Text = "Auto Equip Best Pet", Default = false })
AutoEquipGroup:AddToggle("AutoEquipBestTrail", { Text = "Auto Equip Best Trail", Default = false })
AutoEquipGroup:AddToggle("AutoEquipBestAura", { Text = "Auto Equip Best Aura", Default = false })
AutoEquipGroup:AddToggle("AutoEquipBestPal", { Text = "Auto Equip Best Pal", Default = false })
AutoEquipGroup:AddToggle("AutoEquipBestWings", { Text = "Auto Equip Best Wings", Default = false })
AutoEquipGroup:AddToggle("AutoEquipBestWing", { Text = "Auto Equip Best Wing", Default = false })
local AutoBuyGroup = lO.Main:AddRightGroupbox("Auto Buy", "shopping-cart")
AutoBuyGroup:AddToggle("AutoBuyWings", { Text = "Auto Buy Wings", Default = false })
AutoBuyGroup:AddToggle("AutoBuyTrails", { Text = "Auto Buy Trails", Default = false })
AutoBuyGroup:AddToggle("AutoBuyAuras", { Text = "Auto Buy Auras", Default = false })
AutoBuyGroup:AddToggle("AutoHatchEggs", { Text = "Auto Hatch Eggs", Default = false })
local lS = {
    "Egg_W1_1",
    "Egg_W1_2",
    "Egg_W1_3",
    "Egg_W2_1",
    "Egg_W2_2",
    "Egg_W3_1",
    "Egg_W3_2",
    "Egg_W4_1",
    "Egg_W4_2",
    "Egg_W5_1",
    "Egg_W5_2"
}
local lT_2 = {
    Egg_W1_1 = "FeatherEgg",
    Egg_W1_2 = "OceanEgg",
    Egg_W1_3 = "BugEgg",
    Egg_W2_1 = "AnimalEgg",
    Egg_W2_2 = "WingEgg",
    Egg_W3_1 = "CocoonEgg",
    Egg_W3_2 = "FlutterEgg",
    Egg_W4_1 = "FarmEgg",
    Egg_W4_2 = "SafariEgg",
    Egg_W5_1 = "RanchEgg",
    Egg_W5_2 = "ForestEgg"
}
lp = { ["Best Affordable"] = "BestAffordable" }
local lV = { "Best Affordable" }
for i, v in ipairs(lS) do
    local ly_4 = lT_2[v]
    table.insert(lV, ly_4)
    lp[ly_4] = v
end
kS, kN, connection, connection2, connection3, ls, lv, k6, kP, kH, lr, k5, lw, lj, kM, kF, lm, lt, k1, k4, kB, k_, kA, kT, k9, k7, kz, ln, ld, kI, kW, kC, la, lu, kO, kK = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
AutoBuyGroup:AddDropdown("HatchEgg", { Values = lV, Default = "Best Affordable", Text = "Egg", Searchable = true })
local MenuGroup = lO.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
kS = tick()
kN = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local mx = v
        pcall(function()
            mx:Disable()
        end)
    end
end)
ls = fn403
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
lv = function(bc)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not bc)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not bc
        end
    end)
    if not bc then
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
MenuGroup:AddToggle("RemoveGameplayPaused", { Text = "Remove Gameplay Paused", Default = true, Callback = onRemoveGameplayPaused })
MenuGroup:AddButton("Unload", onUnload)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/HeightPerJump")
SaveManager:BuildConfigSection(lO.Settings)
ThemeManager:ApplyToTab(lO.Settings)
ThemeManager:LoadDefault()
SaveManager:LoadAutoloadConfig()
connection3 = game:GetService("CoreGui").ChildAdded:Connect(function(bl)
    local mK = Library.Unloaded
    local mO = if mK then 1 else 0
    local mM = 2186 * mO + 2014 * (1 - mO)
    local mN = 850 * mO + 2279 * (1 - mO)
    if not ((mM * 779 + mN * 195 + mM * mN) % 16777213 == 3726744) then
        mK = not Toggles.RemoveGameplayPaused.Value
    end
    if mK then
        return
    end
    if bl.Name == "RobloxNetworkPauseNotification" then
        pcall(function()
            bl.Enabled = false
        end)
    end
end)
Library:OnUnload(fn668)
lv(Toggles.RemoveGameplayPaused.Value)
task.spawn(removeGameplayPausedLoop)
k6 = fn46
kP = fn248
kH = fn662
if (not ld and not kH and (kH and k4) or (kH or ld) and (not lt or lt)) and (not kH or not ld or (k4 or ld) or not k4 and not kH and (lt and not ld)) or not ((not ld and not kH and (kH and k4) or (kH or ld) and (not lt or lt)) and (not kH or not ld or (k4 or ld) or not k4 and not kH and (lt and not ld))) then
    lr = fn440
else
    lt = fn440
end
k5 = function(bT)
    local m3
    m3 = nil
    m3 = kP()
    if not m3 then
        return false
    end
    local m4 = pcall(function()
        m3:PivotTo(bT)
    end)
    return m4
end
lw = fn272
lj = fn217
kM = fn600
kF = fn805
lm = function(ce)
    local nr
    local ns = ce == ""
    local nt = type(ce) ~= "string"
    local nx = if nt then 1 else 0
    local nv = 2978 * nx + 3156 * (1 - nx)
    local nw = 595 * nx + 1862 * (1 - nx)
    if not ((nv * 2752 + nw * 1166 + nv * nw) % 16777213 == 10661136) then
        nt = ns
    end
    if nt then
        return false
    end
    nr = false
    pcall(function()
        local nn_1
        local nm_1
        nm_1, nn_1 = k6(kx:PlayerOwnsGamePass(ce))
        nr = nm_1 and nn_1 == true
    end)
    return nr
end
lt = fn26
if (not connection2 and connection2 or false) and (not lt or not connection2 or k5 and lw) or (ls or lt or not lt and not connection2) and (kH and connection2 and (connection2 and not kH)) or not ((not connection2 and connection2 or false) and (not lt or not connection2 or k5 and lw) or (ls or lt or not lt and not connection2) and (kH and connection2 and (connection2 and not kH))) then
    k1 = fn480
    k4 = fn409
    kB = fn489
    k_ = fn714
else
    k4 = fn480
    k1 = fn409
    k_ = fn489
    kB = fn714
end
kA = function(c9)
    local n9
    n9 = nil
    local oa = kH()
    n9 = lr()
    if not (oa and n9) then
        return false
    end
    oa.AssemblyLinearVelocity = Vector3.zero
    oa.AssemblyAngularVelocity = Vector3.zero
    oa.CFrame = CFrame.new(c9)
    oa.Anchored = true
    task.wait(0.22)
    oa.Anchored = false
    pcall(function()
        n9:ChangeState(Enum.HumanoidStateType.Landed)
    end)
    k_(n9, 1.1)
    oa.AssemblyLinearVelocity = Vector3.zero
    return true
end
kT = function()
    local od
    od = nil
    local oe = kP()
    local of = kH()
    od = lr()
    if not (oe and of and od) or od.Health <= 0 then
        return false
    end
    local og_2 = math.clamp(Options.StudHeight.Value, 500, 9000)
    local oh_1 = select(1, k1())
    local oi = lt(oh_1)
    local oh_3 = oi and oi.Position or of.Position
    local oi_2 = kB(oh_3, oe)
    local oe_1 = Vector3.new(oh_3.X, oi_2 + 3.25, oh_3.Z)
    local oj = Vector3.new(oh_3.X, oi_2 + og_2, oh_3.Z)
    local ol = math.min(og_2 - 25, 8975)
    of.Anchored = false
    of.AssemblyLinearVelocity = Vector3.zero
    of.AssemblyAngularVelocity = Vector3.zero
    of.CFrame = CFrame.new(oe_1)
    task.wait(0.12)
    pcall(function()
        od:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
    task.wait(0.12)
    pcall(function()
        od:ChangeState(Enum.HumanoidStateType.Freefall)
    end)
    of.AssemblyLinearVelocity = Vector3.zero
    of.CFrame = CFrame.new(oj)
    local om = 0
    local on = os.clock() + 1.35
    while os.clock() < on do
        if Library.Unloaded or not Toggles.AutoStudFarm.Value then
            break
        end
        local max = math.max
        local op = tonumber(LocalPlayer:GetAttribute("HeightProgressStuds")) or 0
        om = max(om, op)
        if om >= ol then
            break
        end
        of.CFrame = CFrame.new(oj)
        of.AssemblyLinearVelocity = Vector3.zero
        task.wait(0.05)
    end
    local oj_1 = { math.max(og_2 * 0.35, 1200), math.max(og_2 * 0.12, 450), 140, 55 }
    for i, v in ipairs(oj_1) do
        if Library.Unloaded or not Toggles.AutoStudFarm.Value then
            break
        end
        local og_4 = oi_2 + v
        of.CFrame = CFrame.new(oh_3.X, og_4, oh_3.Z)
        of.AssemblyLinearVelocity = Vector3.new(0, -math.clamp(v * 0.45, 80, 280), 0)
        task.wait(0.16)
    end
    kA(oe_1)
    task.wait(0.65)
    return true
end
k9 = fn516
k7 = function(d3)
    local oP = kH()
    if not (oP and d3) then
        return false
    elseif firetouchinterest then
        pcall(function()
            firetouchinterest(oP, d3, 0)
            task.wait(0.12)
            firetouchinterest(oP, d3, 1)
        end)
        return true
    else
        return k5(d3.CFrame + Vector3.new(0, 3, 0))
    end
end
kz = fn67
ln = fn411
ld = fn453
kI = function(ex, ey, ez, eA, eB)
    if type(ex) ~= "table" then
        return false
    end
    local pb
    local pc = -math.huge
    local pd = false
    for k, v in ex do
        local pe_1 = type(v) == "table" and v.Owned == true
        if pe_1 then
            local pe_2 = tonumber(v[ez]) or tonumber(v.HeightBuff) or tonumber(v.HeightBonus) or tonumber(v.HeightMultiplier) or v.Level
            local pf = pe_2 or 0
            local pf_1 = v[ey]
            if pf_1 and pf >= pc then
                pc = pf
                pb = pf_1
                pd = v.Equipped == true or v[eA] == true
            end
        end
    end
    if pb and not pd then
        local pc_2 = pcall(function()
            k6(eB(pb))
        end)
        return pc_2
    end
    return false
end
kW = function(eT, eU, eV)
    if type(eT) ~= "table" then
        return
    end
    local pr = {}
    for k, v in eT do
        local ps = type(v) == "table" and v.Owned ~= true and v.CanPurchase ~= false
        if ps then
            table.insert(pr, v)
        end
    end
    table.sort(pr, function(e_, e0)
        local po = tonumber(e_.Level) or 0
        local pp = tonumber(e0.Level) or 0
        return po < pp
    end)
    for k, v in pr do
        local pF = v
        if lj(pF.Price) then
            pcall(function()
                k6(eV(pF[eU]))
            end)
            task.wait(0.15)
        end
    end
end
kC = fn92
la = fn275
lu = fn203
kO = function()
    local p6_1, p6_3
    local p5_1, p5_5
    local p2
    local p3 = -math.huge
    local p4
    p5_1, p6_1 = k6(kE:GetPaidWingSnapshot())
    local p7 = p5_1 and type(p6_1) == "table" and type(p6_1.Wings) == "table"
    if p7 then
        for k, v in p6_1.Wings do
            local p5_2 = type(v) == "table" and v.Owned == true
            if p5_2 then
                local p5_3 = tonumber(v.HeightMultiplier) or 0
                if p5_3 >= p3 then
                    p3 = p5_3
                    p2 = v.PaidWingId or k
                    p4 = "Paid"
                end
            end
        end
    end
    p5_5, p6_3 = k6(kE:GetSeasonWingSnapshot())
    local p7_1 = p5_5 and type(p6_3) == "table" and type(p6_3.Wings) == "table"
    if p7_1 then
        for k, v in p6_3.Wings do
            local p5_6 = type(v) == "table" and v.Owned == true
            if p5_6 then
                local p5_7 = tonumber(v.HeightMultiplier) or 0
                if p5_7 >= p3 then
                    p3 = p5_7
                    p2 = v.SeasonWingId or k
                    p4 = "Season"
                end
            end
        end
    end
    if not p2 then
        return false
    end
    if p4 == "Paid" then
        pcall(function()
            k6(kE:EquipPaidWing(p2))
        end)
    else
        pcall(function()
            k6(kE:EquipSeasonWing(p2))
        end)
    end
    return true
end
kK = function()
    local qs_1, qs_2
    local qr_1, qr_5
    qr_1, qs_1 = k6(k8:GetSnapshot())
    local qt = not qr_1
    local qx = if qt then 1 else 0
    local qv = 289 * qx + 1144 * (1 - qx)
    local qw = 1387 * qx + 2820 * (1 - qx)
    if not ((qv * 3108 + qw * 2535 + qv * qw) % 16777213 == 4815100) then
        qt = type(qs_1) ~= "table"
    end
    if not qt then
        qt = type(qs_1.Worlds) ~= "table"
    end
    if qt then
        return
    end
    for i, v in ipairs(qs_1.Worlds) do
        if type(v) == "table" then
            local qq = tonumber(v.WorldId)
            if qq then
                if v.Unlocked ~= true then
                    local qp = tonumber(v.RequiredMasterTalkWorldId)
                    if qp and v.MasterTalkRequirementMet ~= true then
                        pcall(function()
                            k6(k8:RecordMasterTalk(qp))
                        end)
                        task.wait(0.2)
                    end
                    if v.CanUnlock == true or v.MasterTalkRequirementMet == true then
                        pcall(function()
                            k6(k8:UnlockWorld(qq))
                        end)
                        task.wait(0.25)
                    end
                else
                    local qr_4 = v.Current ~= true
                    if qr_4 then
                        local qt_1 = tonumber(qs_1.NextUnlockWorldId) or qq
                        qr_4 = qq == qt_1
                    end
                    if qr_4 then
                        pcall(function()
                            k6(k8:TeleportToWorld(qq))
                        end)
                    end
                end
            end
        end
    end
    qr_5, qs_2 = k6(k8:GetSnapshot())
    local qt_2 = qr_5 and type(qs_2) == "table" and type(qs_2.Worlds) == "table"
    if qt_2 then
        local qo = 1
        for i, v in ipairs(qs_2.Worlds) do
            local qr_6 = type(v) == "table" and v.Unlocked == true
            if qr_6 then
                local qr_7 = tonumber(v.WorldId) or 1
                if qr_7 > qo then
                    qo = qr_7
                end
            end
        end
        if qo ~= kM() then
            pcall(function()
                k6(k8:TeleportToWorld(qo))
            end)
        end
    end
end
task.spawn(autoStudFarmLoop)
task.spawn(autoStudFarmLoop2)
task.spawn(autoRebirthLoop)
task.spawn(autoBuyWorldsLoop)
task.spawn(autoEquipBestPetLoop)
task.spawn(autoBuyTrailsLoop)
task.spawn(autoHatchEggsLoop)
end)(...)

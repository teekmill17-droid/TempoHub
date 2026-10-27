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
getgenv().TempoHoodSubtitle = "+1 FOOTBALL FOR BRAINROTS"
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
local l3
local k3
local lL
local ls
local RebirthConfigs
local k9
local Library
local GameHandler
local onJoinDiscordForKeylessScripts
local lf
local lX
local RaritiesInfo
local ReplicatedNodeHandler
local Options
local l2
local LuckyBlocksInfo
local lK
local l8
local connection2
local lQ
local lx
local me
local le
local lW
local lD
local Workspace
local l1
local k1
local lJ
local lq
local l7
local BrainrotsInfo
local lw
local md
local ld
local UserInputService
local SaveManager
local lj
local UpgradeConfigs
local k0
local connection
local LocalReward
local l6
local k6
local VirtualUser
local mc
local lc
local lU
local mi
local l_
local k_
local HttpService
local lo
local k5
local lN
local lu
local mb
local lb
local BigNum
local lA
local mh
local lh
local Utils
local lG
local ln
local l4
local k4
local PlayerDataHandler
local Toggles
local WeightsInfo
local lS
local lz
local mg
local lg
local kY
local lF
local function onRscripts()
    lf(k_, "Copied Rscripts profile to clipboard")
end
local function fn20()
    if not Toggles.WalkSpeedEnabled.Value then
        local qA = md()
        if qA then
            qA.WalkSpeed = 16
        end
    end
end
local function onCopyPayPalLink()
    lf(ln, "Copied PayPal link")
end
local function fn54()
    if mi then
        pcall(function()
            mi:Disconnect()
        end)
    end
    connection:Disconnect()
    connection2:Disconnect()
    mh(false)
    local sJ = md()
    if sJ then
        sJ.PlatformStand = false
        sJ.WalkSpeed = 16
    end
end
local function worker7()
    while not Library.Unloaded do
        local r2 = lN("AutoKick") and not le:GetAttribute("isInKickSession")
        if r2 then
            pcall(k1)
            task.wait(0.35)
        else
            task.wait(0.25)
        end
    end
end
local function fn61(g1, g2)
    local Type = g2.Type
    if Type == "Toggle" then
        return { idx = g1, type = "Toggle", value = g2.Value == true }
    elseif Type == "Slider" then
        return { idx = g1, type = "Slider", value = tostring(g2.Value) }
    elseif Type == "Dropdown" then
        return { idx = g1, type = "Dropdown", multi = g2.Multi == true, value = g2.Value }
    elseif Type == "Input" then
        local q4 = g2.Value or ""
        return { idx = g1, type = "Input", text = tostring(q4) }
    elseif Type == "ColorPicker" then
        return { idx = g1, type = "ColorPicker", value = g2.Value:ToHex(), transparency = g2.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = g1,
            type = "KeyPicker",
            mode = g2.Mode,
            key = g2.Value,
            modifiers = g2.Modifiers,
            toggled = g2.Toggled
        }
    else
        return nil
    end
end
local function fn76()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    lx = tick()
end
local function onCopyLitecoinAddress()
    lf(lX, "Copied Litecoin address")
end
local function onCopySolanaAddress()
    lf(lu, "Copied Solana address")
end
local function worker6()
    while not Library.Unloaded do
        local r7 = lN("AutoCollect") and le:GetAttribute("isInKickSession")
        if r7 then
            pcall(k9)
            task.wait(0.35)
        else
            task.wait(0.25)
        end
    end
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local qK_1 = md()
        if qK_1 then
            qK_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn231()
    local qe_1
    local qd_1
    if identifyexecutor then
        qe_1, qd_1 = identifyexecutor()
        local qf = qe_1 ~= ""
        local qg = type(qe_1) == "string" and qf
        if qg then
            local qf_1 = type(qd_1) == "string" and qd_1 ~= "" and qe_1 .. " " .. qd_1
            l6 = qf_1 or qe_1
        end
    end
end
local function onCopyEthereumAddress()
    lf(lK, "Copied Ethereum address")
end
local function onUnload()
    Library:Unload()
end
local function onCopyVenmoLink()
    lf(lh, "Copied Venmo link")
end
local function onExportConfigToClipboard()
    local rB_1
    local rA_1
    rA_1, rB_1 = pcall(HttpService.JSONEncode, HttpService, mg())
    if not rA_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local rA_2 = setclipboard or toclipboard
    local rA_3 = type(rA_2) ~= "function" or not pcall(rA_2, rB_1)
    if rA_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            mh(true)
        end
    end
end
local function fn434()
    if not Toggles.Fly.Value then
        local qy = md()
        if qy then
            qy.PlatformStand = false
        end
    end
end
local function onInputChanged(hX)
    local UserInputType = hX.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        lF = tick()
    end
end
local function worker()
    local qm_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local ql = math.floor(os.clock() - lW)
        if ql < 60 then
            qm_1 = ql .. "s"
        elseif ql < 3600 then
            qm_1 = string.format("%dm %ds", math.floor((ql) / (60)), ql % 60)
        else
            qm_1 = string.format("%dh %dm", math.floor((ql) / (3600)), math.floor((ql % 3600) / (60)))
        end
        lj:SetText(lz("Session time", qm_1, mc))
    end
end
local function fn526()
    mh(Toggles.AntiGameplayPause.Value)
end
local function onInputBegan()
    lF = tick()
end
local function onImportConfigFromClipboardTex()
    local rG_1
    local rE = Options.SaveManager_ImportSource.Value or ""
    local rE_1
    local rF = tostring(rE):match("^%s*(.-)%s*$")
    if rF == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    rE_1, rG_1 = pcall(HttpService.JSONDecode, HttpService, rF)
    local rF_1 = not rE_1 or type(rG_1) ~= "table"
    local rK = if rF_1 then 1 else 0
    local rI = 529 * rK + 1777 * (1 - rK)
    local rJ = 3083 * rK + 854 * (1 - rK)
    if not ((rI * 1195 + rJ * 1826 + rI * rJ) % 16777213 == 7892620) then
        rF_1 = type(rG_1.objects) ~= "table"
    end
    if rF_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local rE_2 = 0
    for i, v in ipairs(rG_1.objects) do
        if l4(v) then
            rE_2 += 1
        end
    end
    if rE_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local rG_2 = rE_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(rE_2, rG_2), 6)
end
local function fn573()
    local ra = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local rb = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if rb then
                local rb_1 = lg(k, v)
                if rb_1 then
                    ra[#ra + 1] = rb_1
                end
            end
        end
    end
    table.sort(ra, function(hf, hg)
        if hf.type ~= hg.type then
            return hf.type < hg.type
        end
        return hf.idx < hg.idx
    end)
    return { objects = ra }
end
local function onCopyUSDTAddress()
    lf(lD, "Copied USDT address")
end
local function worker5()
    while not Library.Unloaded do
        if lN("AutoCollectCash") then
            pcall(l2)
            task.wait(0.75)
        else
            task.wait(0.4)
        end
    end
end
local function fn616(gU, gV)
    local qY_1 = (gU == "Toggle" and Toggles or Options)[gV]
    local qX_2 = type(qY_1) == "table" and qY_1.Type == gU
    return qX_2 and qY_1 or nil
end
local function onCopyBitcoinAddress()
    lf(lS, "Copied Bitcoin address")
end
local function worker2()
    while not Library.Unloaded do
        task.wait(2)
        if lN("AntiAfk") then
            local sC = tick() - lF
            local sD = tick() - lx
            if sC >= 300 and sD >= 60 then
                pcall(k3)
            else
                if sC < 300 and sD >= 300 then
                    pcall(k3)
                end
            end
        end
    end
end
local function onRenderStepped(gB)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local qP_1 = md()
        if qP_1 then
            qP_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local qP_3 = ld()
        local qQ = md()
        ls = Workspace.CurrentCamera or ls
        if qP_3 and qQ and ls then
            qQ.PlatformStand = true
            local qQ_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                qQ_1 = qQ_1 + ls.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                qQ_1 = qQ_1 - ls.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                qQ_1 = qQ_1 - ls.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                qQ_1 = qQ_1 + ls.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                qQ_1 = qQ_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                qQ_1 = qQ_1 - Vector3.new(0, 1, 0)
            end
            qP_3.Velocity = Vector3.zero
            if qQ_1.Magnitude > 0 then
                qP_3.CFrame = qP_3.CFrame + qQ_1.Unit * Options.FlySpeed.Value * gB
            end
        end
    end
end
local function worker3()
    while not Library.Unloaded do
        if lN("AutoRebirth") then
            pcall(lc)
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end
local function worker4()
    while not Library.Unloaded do
        local sk = lN("AutoEquipWeights") or lN("Auto2x")
        if sk then
            pcall(l7)
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = le.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local qC_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if qC_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function onCopyJoinScript_JobID()
    local fu = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, lb)
    lf(fu, "Copied join script to clipboard")
end
RaritiesInfo = nil
kY = nil
k_ = nil
k0 = nil
k1 = nil
LuckyBlocksInfo = nil
k3 = nil
k4 = nil
k5 = nil
k6 = nil
BrainrotsInfo = nil
connection2 = nil
k9 = nil
WeightsInfo = nil
lb = nil
lc = nil
ld = nil
le = nil
lf = nil
lg = nil
lh = nil
lj = nil
Workspace = nil
Options = nil
ln = nil
lo = nil
LocalReward = nil
lq = nil
ls = nil
Toggles = nil
lu = nil
lw = nil
lx = nil
GameHandler = nil
lz = nil
lA = nil
SaveManager = nil
lD = nil
ReplicatedNodeHandler = nil
lF = nil
lG = nil
HttpService = nil
connection = nil
lJ = nil
local kZ, TrainingFrenzy, CoreGui, lv, GuiService
lK = nil
lL = nil
PlayerDataHandler = nil
lN = nil
VirtualUser = nil
lQ = nil
Library = nil
lS = nil
BigNum = nil
lU = nil
UserInputService = nil
lW = nil
lX = nil
Utils = nil
l_ = nil
UpgradeConfigs = nil
l1 = nil
l2 = nil
l3 = nil
l4 = nil
l6 = nil
l7 = nil
l8 = nil
RebirthConfigs = nil
mb = nil
mc = nil
md = nil
me = nil
onJoinDiscordForKeylessScripts = nil
mg = nil
mh = nil
mi = nil
local lP, ma
lP = nil
ma = nil
local DonationsGroup
local GameInfoGroup
local mF_1
local mA_1
local AccountGroup, my_3
local ReplicatedStorage = game:GetService("ReplicatedStorage")
Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
VirtualUser = game:GetService("VirtualUser")
GuiService = game:GetService("GuiService")
UserInputService = game:GetService("UserInputService")
HttpService = game:GetService("HttpService")
CoreGui = game:GetService("CoreGui")
le = Players.LocalPlayer
k_ = "https://discord.gg/K7Qxnxkk46"
k5 = "https://discord.gg/K7Qxnxkk46"
local sR_8_1 = "+1 Football for Brainrots"
local Source = ReplicatedStorage:WaitForChild("Source")
local sR_12_1 = Source:WaitForChild("PlaywooEngine")
Utils = require(sR_12_1:WaitForChild("Utils"))
BigNum = Utils.BigNum
PlayerDataHandler = require(sR_12_1.BaseHandlers.PlayerDataHandler)
ReplicatedNodeHandler = require(sR_12_1.BaseHandlers.ReplicatedNodeHandler)
GameHandler = require(Source.GameHandlers.GameHandler)
LocalReward = require(Source.GameModules.Kick.LocalReward)
TrainingFrenzy = require(Source.GameModules.TrainingFrenzy)
WeightsInfo = require(Source.Info.WeightsInfo)
BrainrotsInfo = require(Source.Info.BrainrotsInfo)
LuckyBlocksInfo = require(Source.Info.LuckyBlocksInfo)
RaritiesInfo = require(Source.Info.RaritiesInfo)
RebirthConfigs = require(Source.Configs.RebirthConfigs)
UpgradeConfigs = require(Source.Configs.UpgradeConfigs)
Library = getgenv().Library
local sR_1_1 = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
lf = function(M, N)
    if setclipboard then
        setclipboard(M)
    elseif toclipboard then
        toclipboard(M)
    end
    Library:Notify(N)
end
onJoinDiscordForKeylessScripts = function()
    lf(k5, "Copied Discord invite to clipboard")
end
lU = function(T, U)
    return string.format('<font color="%s">%s</font>', U, T)
end
lz = function(W, X, Y)
    return string.format("<b>%s</b> %s %s", W, '<font color="#5a6070">-</font>', lU(X, Y))
end
local sR_12_2 = "#8b93a3"
local sR_11 = "#7fd47f"
lS = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
local sR_7 = "#6ec1ff"
lu = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
mc = "#e8a34d"
ln = ""
lK = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
lX = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
lh = ""
lD = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
lN = function(at)
    local m6 = Toggles[at]
    return m6 and m6.Value == true
end
ld = function()
    local Character = le.Character
    local na = Character and Character:FindFirstChild("HumanoidRootPart")
    return na
end
md = function()
    local Character = le.Character
    local nd = Character and Character:FindFirstChildOfClass("Humanoid")
    return nd
end
lL = function()
    local nf = {}
    local ng = PlayerDataHandler.GetKeyValue("stats") or nf
    return ng
end
lw = function()
    local ni = PlayerDataHandler.GetKeyValue("currencies")
    return ni and ni.cash
end
k6 = function()
    local nl = {}
    local nm = PlayerDataHandler.GetKeyValue("ownedWeights") or nl
    return nm
end
kY = function()
    return PlayerDataHandler.GetKeyValue("weightEquipped")
end
l1 = function()
    return ReplicatedNodeHandler.GetPathValue("footballKicks", { tostring(le.UserId) })
end
lJ = function()
    local attr = le:GetAttribute("baseNumber")
    if type(attr) ~= "number" then
        return nil
    end
    local np = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("PlayerBases")
    local nq = np
    if np then
        np = nq:FindFirstChild(tostring(attr))
    end
    return np
end
k0 = function()
    local ns = lJ()
    if not ns then
        return nil
    end
    local PlayArea = ns:FindFirstChild("PlayArea")
    local ns_1 = PlayArea and PlayArea:FindFirstChild("AreaTriggers")
    local nt_1 = ns_1
    if ns_1 then
        ns_1 = nt_1:FindFirstChild("ThrowZone")
    end
    return ns_1
end
lA = function(a6)
    local nv = ld()
    if not (nv and a6) then
        return false
    end
    local nw_1 = a6:IsA("BasePart") and a6.Position
    local nx = nw_1 or a6:GetPivot().Position
    nv.CFrame = CFrame.new(nx + Vector3.new(0, 3, 0))
    return true
end
mb = function()
    if le:GetAttribute("isInThrowZone") then
        return true
    end
    local nC = k0()
    if not nC then
        return false
    end
    lA(nC)
    local nC_1 = os.clock() + 2
    while true do
        if not (os.clock() < nC_1) then
            return le:GetAttribute("isInThrowZone") == true
        end
        if Library.Unloaded then
            break
        end
        if le:GetAttribute("isInThrowZone") then
            return true
        end
        task.wait(0.1)
    end
    return false
end
lo = function(bk)
    if type(bk) ~= "table" then
        return 0
    end
    local nE
    if bk.type == "luckyBlock" then
        local nF_1 = LuckyBlocksInfo.byKey[bk.key]
        nE = nF_1 and nF_1.rarity
        local nF_2 = not nE
        if nF_2 ~= false then
            nF_2 = type(bk.key) == "string"
        end
        if nF_2 then
            nE = string.lower(bk.key:gsub("^OP_", ""))
        end
    elseif bk.type == "brainrot" then
        local nF_3 = BrainrotsInfo.byKey[bk.key]
        nE = nF_3 and nF_3.rarity
    end
    if nE and RaritiesInfo.byKey[nE] then
        return RaritiesInfo.byKey[nE].rarityIndex or 0
    end
    return 0
end
lq = function(bw, bx)
    local nO_1
    if not bx then
        return true
    elseif not bw then
        return false
    else
        local nL = lo(bw)
        local nM = lo(bx)
        if nL ~= nM then
            return nL > nM
        end
        local nL_1 = tonumber(bw.tier) or 0
        local nL_2 = tonumber(bx.tier) or 0
        local nN_3
        if nL_1 ~= nL_2 then
            return nL_1 > nL_2
        end
        local nL_3 = tonumber(bw.level) or 0
        local nL_4 = (tonumber(bx.level))
        local nS = if nL_4 then 1 else 0
        local nQ = 2956 * nS + 2086 * (1 - nS)
        local nQ_2
        local nR = 3455 * nS + 2657 * (1 - nS)
        local nR_2
        if not ((nQ * 1316 + nR * 1570 + nQ * nR) % 16777213 == 2750213) then
            nL_4 = 0
        end
        local nN_1 = nL_4
        if nL_3 ~= nN_1 then
            return nL_3 > nN_1
        end
        local revenuePerSecond2 = bw.revenuePerSecond
        local revenuePerSecond = bx.revenuePerSecond
        local nN_2 = type(revenuePerSecond2) == "table" and type(revenuePerSecond) == "table"
        if nN_2 then
            nN_3, nO_1 = pcall(BigNum.Compare, revenuePerSecond2, revenuePerSecond)
            local nL_6 = nN_3 and type(nO_1) == "number"
            if nL_6 then
                return nO_1 > 0
            end
            local nM_4 = bw.type == "luckyBlock" and 1 or 0
            local nN_4 = bx.type == "luckyBlock" and 1
            if not ((nQ_2 * 1890 + nR_2 * 1238 + nQ_2 * nR_2) % 16777213 == 9667077) then
                nN_4 = 0
            end
            return nM_4 > nN_4
        end
        local nM_7 = bw.type == "luckyBlock" and 1 or 0
        local nN_5 = bx.type == "luckyBlock" and 1
        local nS_2 = if nN_5 then 1 else 0
        nQ_2 = 3803 * nS_2 + 984 * (1 - nS_2)
        nR_2 = 3820 * nS_2 + 1740 * (1 - nS_2)
        if not ((nQ_2 * 1890 + nR_2 * 1238 + nQ_2 * nR_2) % 16777213 == 9667077) then
            nN_5 = 0
        end
        return nM_7 > nN_5
    end
end
l_ = false
l8 = {}
Utils.Signals.Connect("LocalKickLanded", function()
    l_ = true
end)
lP = function(bR)
    local nT = l1()
    local nU = type(nT) ~= "table" or type(nT.rewards) ~= "table"
    if nU then
        return nil
    end
    local nU_1 = {}
    for k in pairs(nT.rewards) do
        if not l8[k] then
            nU_1[#nU_1 + 1] = k
        end
    end
    if #nU_1 == 0 then
        return nil
    elseif bR == "Random" then
        return nU_1[math.random(1, #nU_1)]
    else
        local nV = nU_1[1]
        local nW = nT.rewards[nV]
        local nX = #nU_1
        local n8 = 2
        while n8 <= nX do
            local nX_1 = nU_1[n8]
            local nY = nT.rewards[nX_1]
            if lq(nY, nW) then
                nV = nX_1
                nW = nY
            end
            n8 += 1
        end
        return nV
    end
end
lG = function(b4)
    local ob = os.clock()
    local od = ob + (b4 or 20)
    while true do
        if not (os.clock() < od) then
            return false
        end
        if Library.Unloaded then
            break
        end
        if not le:GetAttribute("isInKickSession") then
            return false
        end
        local ob_1 = l1()
        local oc_1 = type(ob_1) == "table" and ob_1.status == "claiming" and type(ob_1.rewards) == "table" and next(ob_1.rewards) ~= nil
        if oc_1 and l_ then
            return true
        end
        task.wait(0.1)
    end
    return false
end
l3 = function()
    local of
    if not le:GetAttribute("isInKickSession") then
        return false
    end
    local og = l1()
    if type(og) ~= "table" then
        return false
    end
    local oh = type(og.claimsLeft) == "number" and og.claimsLeft <= 0
    if oh then
        return false
    end
    local oi = Options.CollectPriority and Options.CollectPriority.Value or "Best"
    local oh_2 = tostring(oi)
    of = lP(oh_2)
    if not of then
        return false
    end
    local oh_3 = tonumber(og.claimsLeft)
    local oi_1 = LocalReward.GetCarriedCount()
    pcall(function()
        LocalReward.Claim(of)
    end)
    task.wait(0.45)
    local og_1 = l1()
    local oj = og_1 and tonumber(og_1.claimsLeft)
    local oj_1 = LocalReward.GetCarriedCount()
    if oh_3 and oj and oj < oh_3 or oj_1 > oi_1 then
        l8[of] = true
        return true
    end
    return false
end
k4 = function()
    local oy = if not lG(20) then 1 else 0
    if oy == 1 then
        return false
    end
    task.wait(0.5)
    local oq = false
    local oB = 1
    while oB <= 5 do
        local ot = Library.Unloaded or not le:GetAttribute("isInKickSession")
        if ot then
            break
        end
        local ot_1 = l1()
        if type(ot_1) ~= "table" then
            break
        end
        local ou = type(ot_1.claimsLeft) == "number" and ot_1.claimsLeft <= 0
        if ou then
            break
        elseif l3() then
            oq = true
            task.wait(0.3)
            oB += 1
        else
            task.wait(0.25)
            if not l3() then
                break
            end
            oq = true
            oB += 1
        end
    end
    if LocalReward.GetCarriedCount() > 0 then
        pcall(function()
            LocalReward.DropCarried()
        end)
        task.wait(0.35)
    end
    return oq
end
k1 = function()
    if le:GetAttribute("isInKickSession") then
        return false
    elseif not mb() then
        return false
    else
        table.clear(l8)
        l_ = false
        pcall(function()
            Utils.Signals.Fire("CancelKickMinigame")
        end)
        task.wait(0.1)
        Utils.Signals.Fire("StartKickMinigame")
        task.wait(0.15)
        local oE = false
        local oE_2
        local oF = os.clock() + 2.5
        while true do
            if not (os.clock() < oF) then
                if not oE then
                    pcall(function()
                        GameHandler.SubmitKickAlpha(1)
                    end)
                    task.wait(0.2)
                    oE = le:GetAttribute("isInKickSession") == true
                end
                if not oE then
                    pcall(function()
                        Utils.Signals.Fire("CancelKickMinigame")
                    end)
                    return false
                end
                local oE_1 = os.clock() + 20
                while true do
                    if not (os.clock() < oE_2) then
                        return l_
                    end
                    if Library.Unloaded then
                        break
                    end
                    if not le:GetAttribute("isInKickSession") then
                        return false
                    end
                    if l_ then
                        return true
                    end
                    task.wait(0.1)
                end
                return false
            end
            if Library.Unloaded then
                break
            end
            Utils.Signals.Fire("ConfirmKickAlpha", 1)
            if le:GetAttribute("isInKickSession") then
                oE_2 = os.clock() + 20
                while true do
                    if not (os.clock() < oE_2) then
                        return l_
                    end
                    if Library.Unloaded then
                        break
                    end
                    if not le:GetAttribute("isInKickSession") then
                        return false
                    end
                    if l_ then
                        return true
                    end
                    task.wait(0.1)
                end
                return false
            end
            task.wait(0.1)
        end
        return false
    end
end
me = function()
    if not le:GetAttribute("isInKickSession") then
        return
    end
    if LocalReward.GetCarriedCount() > 0 then
        pcall(function()
            LocalReward.DropCarried()
        end)
        task.wait(0.25)
    end
    pcall(GameHandler.ReturnFromKick)
    local oH = os.clock() + 5
    while os.clock() < oH do
        if Library.Unloaded then
            return
        end
        if not le:GetAttribute("isInKickSession") then
            table.clear(l8)
            l_ = false
            return
        end
        task.wait(0.1)
    end
    table.clear(l8)
    l_ = false
end
k9 = function()
    if not le:GetAttribute("isInKickSession") then
        return false
    elseif not lG(20) then
        return false
    else
        k4()
        if le:GetAttribute("isInKickSession") then
            me()
        end
        return true
    end
end
l2 = function()
    local oM = lJ()
    if not oM then
        return false
    end
    local PlayArea = oM:FindFirstChild("PlayArea")
    local oN_3
    local oM_1 = PlayArea and PlayArea:FindFirstChild("Base")
    local oN_1 = oM_1
    if oM_1 then
        oM_1 = oN_1:FindFirstChild("BrainrotSlots")
    end
    local oN_2 = oM_1
    if not oN_2 then
        return false
    end
    local oM_2 = false
    for i, child in ipairs(oN_2:GetChildren()) do
        local oL, oK
        local oY = child
        if oY:GetAttribute("hasBrainrot") == true then
            oN_3, oL = pcall(function()
                return GameHandler.ClaimEarnings(oY.Name)
            end)
            if oN_3 then
                oM_2 = true
                local oN_4 = type(oL) == "table" and oL.await
                if oN_4 then
                    pcall(function()
                        oL:await()
                    end)
                else
                    local oN_5 = type(oL) == "table" and oL.andThen
                    if oN_5 then
                        oK = false
                        pcall(function()
                            oL:andThen(function()
                                oK = true
                            end)
                        end)
                        local oN_6 = os.clock() + 1
                        while true do
                            local oO = not oK and os.clock() < oN_6
                            if oO then
                                task.wait(0.05)
                                continue
                            end
                            break
                        end
                    end
                end
            end
        end
    end
    return oM_2
end
local function l5()
    local oZ = lw()
    if not oZ then
        return false
    end
    local o_ = k6()
    for i, v in ipairs(WeightsInfo.keys) do
        if not o_[v] then
            local o0 = WeightsInfo.byKey[v]
            local o1 = o0 and o0.price and BigNum.GtZero(o0.price) and BigNum.Gte(oZ, o0.price)
            if o1 then
                GameHandler.PurchaseWeight(v)
                return true
            end
        end
    end
    return false
end
l7 = function()
    local o9 = k6()
    local pa
    local pb = -1
    for i, v in ipairs(WeightsInfo.keys) do
        if o9[v] then
            local pc_1 = WeightsInfo.byKey[v]
            local pc_2 = pc_1 and pc_1.tier or 0
            if pc_2 > pb then
                pb = pc_2
                pa = v
            end
        end
    end
    local pc_3 = pa and kY() ~= pa
    if pc_3 then
        GameHandler.EquipWeight(pa)
        return true
    end
    return false
end
local function lY()
    local pl = lL()
    local pm = (tonumber(pl.speed))
    local ps = if pm then 1 else 0
    local pq = 1694 * ps + 1141 * (1 - ps)
    local pr = 532 * ps + 2467 * (1 - ps)
    if not ((pq * 2039 + pr * 2225 + pq * pr) % 16777213 == 5538974) then
        pm = 0
    end
    local pl_1 = pm
    if UpgradeConfigs.IsMaxSpeedReached(pl_1) then
        return false
    end
    local pm_1 = lw()
    if not pm_1 then
        return false
    end
    local pn = 1
    for i, v in ipairs({ 10, 5, 1 }) do
        local po_1 = UpgradeConfigs.GetUpgradeCost("speed", pl_1, v)
        if BigNum.Gte(pm_1, po_1) then
            pn = v
            break
        end
    end
    local po_2 = UpgradeConfigs.GetUpgradeCost("speed", pl_1, pn)
    local pB = if not BigNum.Gte(pm_1, po_2) then 1 else 0
    if pB == 1 then
        return false
    end
    GameHandler.UpgradeSpeed(pn)
    return true
end
lQ = function()
    local pF_4, pF_6
    local pC = lL()
    local pD = tonumber(pC.rebirths) or 0
    local pE_16, pE_22
    local pD_1 = RebirthConfigs.GetRequirements(pD + 1)
    if not pD_1 then
        return false
    end
    local pE_1 = tonumber(pC.power) or 0
    local pE_2 = type(pD_1.power) == "number" and pE_1 < pD_1.power
    if pE_2 then
        return false
    elseif pD_1.genPerSecond then
        local pC_2 = PlayerDataHandler.GetKeyValue("statistics")
        local pE_3 = pC_2 and pC_2.genPerSecond
        local pE_4 = not pE_3 or BigNum.Lt(pE_3, pD_1.genPerSecond)
        if pE_4 then
            return false
        elseif pD_1.rarityKeyToDiscover then
            local pC_4 = {}
            local pE_5 = PlayerDataHandler.GetKeyValue("raritiesDiscovered") or pC_4
            if pE_16 < pF_4 then
                return false
            elseif pD_1.tierKeyToDiscover then
                local pE_8 = (PlayerDataHandler.GetKeyValue("tiersDiscovered"))
                if pE_22 < pF_6 then
                    return false
                end
                return true
            else
                return true
            end
        elseif pD_1.tierKeyToDiscover then
            local pE_11 = (PlayerDataHandler.GetKeyValue("tiersDiscovered"))
            if pE_22 < pF_6 then
                return false
            end
            return true
        else
            return true
        end
    elseif pD_1.rarityKeyToDiscover then
        local pC_10 = {}
        local pE_14 = PlayerDataHandler.GetKeyValue("raritiesDiscovered") or pC_10
        local pE_15 = tonumber(pD_1.rarityKeyToDiscoverAmount) or 1
        pF_4 = pE_15
        pE_16 = pE_14[pD_1.rarityKeyToDiscover] or 0
        if pE_16 < pF_4 then
            return false
        elseif pD_1.tierKeyToDiscover then
            local pE_17 = (PlayerDataHandler.GetKeyValue("tiersDiscovered"))
            if pE_22 < pF_6 then
                return false
            end
            return true
        else
            return true
        end
    elseif pD_1.tierKeyToDiscover then
        local pC_14 = {}
        local pE_20 = (PlayerDataHandler.GetKeyValue("tiersDiscovered"))
        local pP_4 = if pE_20 then 1 else 0
        local pN_4 = 624 * pP_4 + 2201 * (1 - pP_4)
        local pO_4 = 3527 * pP_4 + 4087 * (1 - pP_4)
        if not ((pN_4 * 2291 + pO_4 * 2753 + pN_4 * pO_4) % 16777213 == 13340263) then
            pE_20 = pC_14
        end
        local pC_15 = pE_20
        local pE_21 = tonumber(pD_1.tierKeyToDiscoverAmount) or 1
        pF_6 = pE_21
        pE_22 = pC_15[pD_1.tierKeyToDiscover] or 0
        if pE_22 < pF_6 then
            return false
        end
        return true
    else
        return true
    end
end
lc = function()
    if not lQ() then
        return false
    end
    GameHandler.Rebirth()
    return true
end
kZ = function(ew)
    if type(ew) ~= "string" then
        return nil
    end
    local pR = ew:gsub("%$", ""):gsub(",", ""):gsub("%s+", "")
    local pS = pR == "???"
    local pS_1
    local pT = pR == "" or pS
    local pT_1
    if pT then
        return nil
    end
    pS_1, pT_1 = pR:match("^([%d%.]+)([%a]*)$")
    local pR_1 = tonumber(pS_1)
    if not pR_1 then
        return nil
    end
    local pS_2 = ({ K = 1000, M = 1000000, B = 1000000000, T = 1000000000000, Qa = 1000000000000000, Qi = 1e+18 })[pT_1] or 1
    return BigNum.fromNumber(pR_1 * pS_2)
end
local function lm()
    local pW = lJ()
    if not pW then
        return false
    end
    local PlayArea = pW:FindFirstChild("PlayArea")
    local pW_1 = PlayArea and PlayArea:FindFirstChild("UpgradeTower")
    if not pW_1 then
        return false
    end
    local pW_2 = lw()
    if not pW_2 then
        return false
    end
    local pY = {}
    for i, child in ipairs(pW_1:GetChildren()) do
        local pX_2 = tonumber((child.Name:match("Upgrade(%d+)")))
        if pX_2 then
            local TowerUpgradePrompt = child:FindFirstChild("TowerUpgradePrompt", true)
            local p_ = TowerUpgradePrompt and TowerUpgradePrompt:IsA("ProximityPrompt") and TowerUpgradePrompt.Enabled
            if p_ then
                local p__1 = kZ(TowerUpgradePrompt.ObjectText)
                local p0 = p__1 and BigNum.Gte(pW_2, p__1)
                if p0 then
                    local p__2 = #pY + 1
                    local p0_1 = child:FindFirstChildWhichIsA("BasePart", true) or child
                    pY[p__2] = { amount = pX_2, prompt = TowerUpgradePrompt, part = p0_1 }
                end
            end
        end
    end
    if #pY == 0 then
        return false
    end
    table.sort(pY, function(eT, eU)
        return eT.amount > eU.amount
    end)
    local pV = pY[1]
    lA(pV.part)
    task.wait(0.15)
    if fireproximityprompt then
        fireproximityprompt(pV.prompt)
    else
        pcall(function()
            pV.prompt:InputHoldBegin()
        end)
        task.wait(math.max(pV.prompt.HoldDuration, 0.05) + 0.05)
        pcall(function()
            pV.prompt:InputHoldEnd()
        end)
    end
    return true
end
lv = function(e_)
    local qb = if not lN("Auto2x") then 1 else 0
    if qb == 1 then
        return
    end
    pcall(function()
        TrainingFrenzy.OnCircleClicked(e_, 1)
    end)
end
mi = nil
mi = Utils.Signals.Connect("TrainingFrenzyCircleSpawned", function(e5)
    if Library.Unloaded then
        return
    end
    task.defer(function()
        lv(e5)
    end)
end)
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = k5, Copyable = true }, "|", "+1 Football for Brainrots" },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
local mx = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "target"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
local function mw_1(fd)
    local DiscordGroup = fd:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onJoinDiscordForKeylessScripts })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onJoinDiscordForKeylessScripts })
end
for k, v in mx do
    mw_1(v)
end
l6, AccountGroup, GameInfoGroup, lj, lb, mA_1 = nil, nil, nil, nil, nil, nil
local mz = 11
repeat
    local mw_2 = (mz * 2 + 1) % 3 + 1
    if mw_2 <= 2 then
        if mw_2 <= 1 then
            local tz = bit32.rrotate(bit32.bxor(bit32.lrotate(mz, 4), string.byte(tostring(lb))), 2)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(tz, 2829618645), 3099598207), (bit32.bxor(bit32.band(tz, 1465348650), 1606765306))), 3099598207), 1606765306) ~= tz then
                l6 = tostring(game.JobId)
            else
                lb = tostring(game.JobId)
            end
            mz = (mz + 2) % 24
        else
            if (l6 and l6 and (not AccountGroup or not lj) or (mz or not l6 or not lb and AccountGroup)) and not (l6 and l6 and (not AccountGroup or not lj) or (mz or not l6 or not lb and AccountGroup)) then
                lb = #mA_1 > 18
            else
                mA_1 = #lb > 18
            end
            mz = (mz + 20) % 24
        end
    else
        if (mz * 2 + 7) * 4 % 3 == ((mz * 2 + 7) * 4 + 3) % 3 then
            l6 = "Unknown"
            pcall(fn231)
            AccountGroup = mx.Info:AddLeftGroupbox("Account", "circle-user")
            AccountGroup:AddLabel(lz("User", le.Name, sR_11), true)
            AccountGroup:AddLabel(lz("Status", "Keyless", sR_11), true)
            AccountGroup:AddLabel(lz("Executor", l6, sR_11), true)
            GameInfoGroup = mx.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            GameInfoGroup:AddLabel(lU(sR_8_1 .. " [" .. tostring(game.PlaceId) .. "]", sR_7), true)
            GameInfoGroup:AddLabel(lz("Place ID", tostring(game.PlaceId), sR_7), true)
            lj = GameInfoGroup:AddLabel(lz("Session time", "0s", mc), true)
        else
            le = "Unknown"
            pcall(fn231)
            l6 = (nil):AddLeftGroupbox("Account", "circle-user")
            l6:AddLabel(AccountGroup("User", nil, sR_7), true)
            l6:AddLabel(AccountGroup("Status", "Keyless", sR_7), true)
            l6:AddLabel(AccountGroup("Executor", le, sR_7), true)
            lj = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
            lj:AddLabel(GameInfoGroup(sR_11 .. " [" .. tostring(game.PlaceId) .. "]", lU), true)
            lj:AddLabel(AccountGroup("Place ID", tostring(game.PlaceId), lU), true)
            lz = lj:AddLabel(AccountGroup("Session time", "0s", mx), true)
        end
        mz = (mz + 14) % 24
    end
until (mz * 23 + 3) % 24 == 4
if mA_1 then
    local mw_3 = 7
    repeat
        local my_2 = (vector.create((mw_3 * 7 + 5) % 11 + 1, (mw_3 * 11 + 1) % 13 + 1, (mw_3 * 11 + 15) % 17 + 1))
        local mz_1 = (vector.create((mw_3 * 5 + 9) % 11 + 1, (mw_3 * 9 + 12) % 13 + 1, (mw_3 * 14 + 14) % 17 + 1))
        local mC_1 = (vector.create((mw_3 * 4 + 8) % 11 + 1, (mw_3 * 11 + 7) % 13 + 1, (mw_3 * 12 + 11) % 17 + 1))
        local mD_1 = (vector.create((mw_3 * 5 + 4) % 11 + 1, (mw_3 * 11 + 13) % 13 + 1, (mw_3 * 3 + 17) % 17 + 1))
        if vector.dot(vector.cross(my_2, mz_1), (vector.cross(mC_1, mD_1))) == vector.dot(my_2, mC_1) * vector.dot(mz_1, mD_1) - vector.dot(my_2, mD_1) * vector.dot(mz_1, mC_1) then
            mA_1 = string.sub(lb, 1, 18) .. "..."
        else
            lb = string.sub(mA_1, 1, 18) .. "..."
        end
        mw_3 = (mw_3 + 6) % 8
    until (mw_3 * 5 + 5) % 8 == 6
end
local mw_4 = mA_1 or lb
lW, DonationsGroup, ls, mF_1, my_3, lF, lx, connection, connection2, mh, ma, lg, mg, l4, k3 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
GameInfoGroup:AddLabel(lz("Server", mw_4, sR_12_2), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
lW = os.clock()
task.spawn(worker)
local ScriptsGroup = mx.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel('<font color="#8b93a3">Included in this hub</font>', true)
ScriptsGroup:AddLabel('<font color="#6ec1ff">+1 Football for Brainrots</font>', true)
local FeaturesGroup = mx.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel('<font color="#6ec1ff">Auto Kick</font>', true)
FeaturesGroup:AddLabel('<font color="#7fd47f">Auto Collect</font>', true)
FeaturesGroup:AddLabel('<font color="#e8a34d">Auto Shop</font>', true)
FeaturesGroup:AddLabel('<font color="#8b93a3">Misc Utilities</font>', true)
local SocialsGroup = mx.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = onJoinDiscordForKeylessScripts })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = mx.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
if (mF_1 or not mF_1) and (my_3 or mg) or my_3 and not lW and (my_3 and mF_1) or not ((mF_1 or not mF_1) and (my_3 or mg) or my_3 and not lW and (my_3 and mF_1)) then
    TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = onJoinDiscordForKeylessScripts })
    DonationsGroup = mx.Info:AddRightGroupbox("Donations", "heart")
else
    DonationsGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
    DonationsGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
    DonationsGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
    DonationsGroup:AddButton({ Text = "Copy Discord Invite", Func = TempoHubGroup })
    mx = onJoinDiscordForKeylessScripts.Info:AddRightGroupbox("Donations", "heart")
end
DonationsGroup:AddLabel('<font color="#e8a34d">All donations are optional but appreciated.</font>', true)
DonationsGroup:AddLabel('<font color="#7fd47f">If you donate you get a special role, just PING after you donate.</font>', true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel('<font color="#345d9d">LTC / Litecoin</font>', true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel('<font color="#f7931a">BTC / Bitcoin</font>', true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel('<font color="#627eea">ETH / Ethereum</font>', true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel('<font color="#26a17b">USDT</font>', true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel('<font color="#14f195">Solana</font>', true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel('<font color="#0070ba">PayPal</font>', true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel('<font color="#008cff">Venmo</font>', true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel('<font color="#8b93a3">Don\'t have any of the listed currencies but still wanna donate?</font>', true)
DonationsGroup:AddLabel('<font color="#6ec1ff">DM me and we\'ll work something out.</font>', true)
local FaqGroup = mx.Info:AddRightGroupbox("FAQ", "circle-help")
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
local KickGroup = mx.Main:AddLeftGroupbox("Kick", "target")
KickGroup:AddToggle("AutoKick", { Text = "Auto Kick", Default = false })
KickGroup:AddToggle("AutoCollect", { Text = "Auto Collect", Default = false })
KickGroup:AddDropdown("CollectPriority", { Text = "Collect Priority", Values = { "Best", "Random" }, Default = "Best" })
local FarmGroup = mx.Main:AddLeftGroupbox("Farm", "coins")
FarmGroup:AddToggle("AutoCollectCash", { Text = "Auto Collect Cash", Default = false })
FarmGroup:AddToggle("AutoUpgradeTower", { Text = "Auto Upgrade Tower Floors", Default = false })
FarmGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
local ShopGroup = mx.Main:AddRightGroupbox("Shop", "shopping-cart")
ShopGroup:AddToggle("AutoBuyWeights", { Text = "Auto Buy Weights", Default = false })
ShopGroup:AddToggle("AutoEquipWeights", { Text = "Auto Equip Weights", Default = false })
ShopGroup:AddToggle("Auto2x", { Text = "Auto 2x", Default = false })
ShopGroup:AddToggle("AutoBuySpeed", { Text = "Auto Buy Speed", Default = false })
local MovementGroup = mx.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = mx.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
mh = function(f5)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not f5)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not f5
        end
    end)
    if not f5 then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(le, "GameplayPaused", false)
        else
            le.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fn526)
Toggles.Fly:OnChanged(fn434)
Toggles.WalkSpeedEnabled:OnChanged(fn20)
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
ls = Workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
local MenuGroup = mx.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
sR_1_1:SetLibrary(Library)
sR_1_1:SetFolder("TempoHub")
sR_1_1:SaveDefault("Evil Hello Kitty")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/FootballForBrainrots")
local my_4 = SaveManager:BuildConfigSection(mx.Settings)
ma = fn616
lg = fn61
mg = fn573
l4 = function(hi)
    local ru
    ru = nil
    local rv = type(hi) ~= "table" or type(hi.idx) ~= "string"
    local rz = if rv then 1 else 0
    local rx = 1574 * rz + 465 * (1 - rz)
    local ry = 297 * rz + 3326 * (1 - rz)
    if not ((rx * 2547 + ry * 778 + rx * ry) % 16777213 == 4707522) then
        rv = type(hi.type) ~= "string"
    end
    if not rv then
        rv = SaveManager.Ignore[hi.idx]
    end
    if rv then
        return false
    end
    ru = ma(hi.type, hi.idx)
    if not ru then
        return false
    end
    local rv_1 = pcall(function()
        if hi.type == "Input" then
            if type(hi.text) ~= "string" then
                return
            end
            ru:SetValue(hi.text)
        elseif hi.type == "ColorPicker" then
            ru:SetValueRGB(Color3.fromHex(hi.value), hi.transparency)
        elseif hi.type == "KeyPicker" then
            ru:SetValue({ hi.key, hi.mode, hi.modifiers })
            if hi.mode == "Toggle" and hi.toggled ~= nil then
                ru.Toggled = hi.toggled
                ru:Update()
            end
        else
            ru:SetValue(hi.value)
        end
    end)
    return rv_1
end
my_4:AddDivider()
my_4:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
my_4:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
my_4:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
sR_1_1:ApplyToTab(mx.Settings)
sR_1_1:LoadDefault()
SaveManager:LoadAutoloadConfig()
lF = tick()
lx = tick()
pcall(function()
    for i, v in ipairs(getconnections(le.Idled)) do
        local rX = v
        pcall(function()
            rX:Disable()
        end)
    end
end)
k3 = fn76
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
do
    mh(Toggles.AntiGameplayPause.Value)
    task.spawn(worker7)
    task.spawn(worker6)
    task.spawn(worker5)
    task.spawn(function()
        local sg = false
        repeat
            local sa
            if not Library.Unloaded then
                local sj = if lN("AutoBuyWeights") then 1 else 0
                if sj == 1 then
                    sa = false
                    pcall(function()
                        sa = l5()
                    end)
                    local sd = sa and 0.75 or 0.5
                    task.wait(sd)
                else
                    task.wait(0.4)
                end
            else
                sg = true
            end
        until sg
    end)
    task.spawn(worker4)
    task.spawn(function()
        local ss = false
        repeat
            local sm
            if not Library.Unloaded then
                if lN("AutoBuySpeed") then
                    sm = false
                    pcall(function()
                        sm = lY()
                    end)
                    local sp = sm and 0.6 or 0.5
                    task.wait(sp)
                else
                    task.wait(0.4)
                end
            else
                ss = true
            end
        until ss
    end)
    task.spawn(worker3)
    task.spawn(function()
        local sA = false
        repeat
            local su
            if not Library.Unloaded then
                if lN("AutoUpgradeTower") then
                    su = false
                    pcall(function()
                        su = lm()
                    end)
                    local sx = su and 0.8 or 0.6
                    task.wait(sx)
                else
                    task.wait(0.5)
                end
            else
                sA = true
            end
        until sA
    end)
    task.spawn(antiGameplayPauseLoop)
    task.spawn(worker2)
    Library:OnUnload(fn54)
end
end)(...)

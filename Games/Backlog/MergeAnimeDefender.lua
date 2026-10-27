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
getgenv().TempoHoodSubtitle = "MERGE ANIME DEFENDER"
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
local gt
local ga
local gS
local EnumType
local onBuySelectedNow
local Options
local connection2
local gC
local RemoteFunction
local gj
local BuildCofig
local f0
local gI
local HomeConfig
local f3
local gL
local gp
local f6
local gO
local f9
local clientRequestServer
local gc
local VirtualUser
local gf
local onUpgradeNow
local gi
local connection
local Library
local Toggles
local f2
local LocalPlayer
local gK
local gr
local gN
local f5
local gu
local gQ
local onCollectFloorNow
local gb
local ge
local gA
local gh
local gD
local gk
local gG
local BuildManager
local gn
local gJ
local f4
local UnitConfig
local ReplicatedStorage
local function fn47(ap, aq)
    if setclipboard then
        setclipboard(ap)
    elseif toclipboard then
        toclipboard(ap)
    end
    Library:Notify(aq)
end
local function fn55()
    gu(gh, "Copied Discord invite to clipboard")
end
local function fn94(aN, aO)
    local hP = Options[aN]
    local hQ = hP and tonumber(hP.Value)
    return hQ or aO
end
local function fn109()
    for k, v in pairs(UnitConfig.getList()) do
        if v.id and v.id >= 10000 then
            local hC_1 = v.showName or v.name
            local hD = tostring(hC_1)
            gQ[hD] = v.id
            table.insert(gJ, hD)
        end
    end
    table.sort(gJ)
end
local function fn116()
    local iR_1
    local iQ_1
    if identifyexecutor then
        iR_1, iQ_1 = identifyexecutor()
        local iS = iR_1 ~= ""
        local iT = type(iR_1) == "string" and iS
        if iT then
            local iS_1 = type(iQ_1) == "string" and iQ_1 ~= "" and iR_1 .. " " .. iQ_1
            gD = iS_1 or iR_1
        end
    end
end
local function fn123(aw, ax)
    return string.format('<font color="%s">%s</font>', ax, aw)
end
local function onInputBegan()
    gr = tick()
end
local function fn136()
    pcall(function()
        clientRequestServer:InvokeServer(ga, nil)
    end)
    pcall(function()
        clientRequestServer:InvokeServer(f3, nil)
    end)
end
local function worker7()
    while not Library.Unloaded do
        if f4("AutoUpgrade") then
            onUpgradeNow()
        end
        task.wait(gA("UpgradeDelay", 2))
    end
end
local function worker4()
    while not Library.Unloaded do
        if f4("AutoCollect") then
            gK()
        end
        task.wait(gA("CollectDelay", 3))
    end
end
local function fn194(cH)
    local DiscordGroup = cH:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = ge })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = ge })
end
local function onCopyJoinScript_JobID()
    local cY = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, f2)
    gu(cY, "Copied join script to clipboard")
end
local function worker9()
    while not Library.Unloaded do
        if f4("AutoEquipBest") then
            gj()
        end
        task.wait(gA("EquipDelay", 5))
    end
end
local function worker10()
    while not Library.Unloaded do
        if f4("AutoRebirth") then
            f9()
        end
        task.wait(gA("RebirthDelay", 10))
    end
end
local function fn292()
    pcall(function()
        clientRequestServer:InvokeServer(gS, { gG })
    end)
end
local function fn294()
    BuildCofig = require(BuildManager:WaitForChild("BuildCofig"))
end
local function fn307()
    EnumType = require(ReplicatedStorage:WaitForChild("DataSource"):WaitForChild("EnumType"))
end
local function onRscripts()
    gu(gf, "Copied Rscripts profile to clipboard")
end
local function worker5()
    while not Library.Unloaded do
        if f4("AutoCollectFloor") then
            onCollectFloorNow()
        end
        task.wait(gA("FloorDelay", 1))
    end
end
local function worker()
    local i4_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local i3 = math.floor(os.clock() - gt)
        if i3 < 60 then
            i4_1 = i3 .. "s"
        elseif i3 < 3600 then
            i4_1 = string.format("%dm %ds", math.floor((i3) / (60)), i3 % 60)
        else
            i4_1 = string.format("%dh %dm", math.floor((i3) / (3600)), math.floor((i3 % 3600) / (60)))
        end
        f6:SetText(gL("Session time", i4_1, gb))
    end
end
local function fn421()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    gn = tick()
end
local function fn430(az, aA, aB)
    return string.format("<b>%s</b> %s %s", az, f0("-", "#5a6070"), f0(aA, aB))
end
local function worker8()
    while not Library.Unloaded do
        if f4("AutoFuse") then
            gN()
        end
        task.wait(gA("FuseDelay", 1))
    end
end
local function worker3()
    while not Library.Unloaded do
        if f4("AutoBuy") then
            gI()
        end
        task.wait(gA("BuyDelay", 1))
    end
end
local function fn467()
    local PlayerInfo = ReplicatedStorage.DataSource:WaitForChild("PlayerInfo")
    UnitConfig = require(PlayerInfo:WaitForChild("UnitConfig"))
    HomeConfig = require(PlayerInfo:WaitForChild("HomeConfig"))
end
local function fn468()
    local hZ = LocalPlayer:GetAttribute("money") or 0
    return hZ
end
local function fn487()
    pcall(function()
        RemoteFunction:InvokeServer(gp, nil)
    end)
end
local function onInputChanged(dB)
    local UserInputType = dB.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        gr = tick()
    end
end
local function fn503()
    pcall(function()
        clientRequestServer:InvokeServer(gi, { gG })
    end)
end
local function fn506(aY)
    local hW = Options[aY]
    return hW and hW.Value or nil
end
local function onUnload()
    Library:Unload()
end
local function worker2()
    while not Library.Unloaded do
        task.wait(2)
        if f4("AntiAfk") then
            local ji = tick() - gr
            local jj = tick() - gn
            if ji >= 300 and jj >= 60 then
                pcall(f5)
            else
                if ji < 300 and jj >= 300 then
                    pcall(f5)
                end
            end
        end
    end
end
local function fn541(aT)
    local hS = Options[aT]
    return hS and hS.Value or {}
end
local function fn560()
    connection:Disconnect()
    connection2:Disconnect()
end
local function fn565(aI)
    local hM = Toggles[aI]
    return hM ~= nil and hM.Value == true
end
local function fn589()
    if gO("BuyMode") == "Only while affordable" then
        local h0 = gc()
        local h1 = h0 and gk() < h0
        if h1 then
            return
        end
    end
    pcall(function()
        RemoteFunction:InvokeServer(gC, nil)
    end)
end
local function worker6()
    while not Library.Unloaded do
        if f4("AutoTowerShop") then
            onBuySelectedNow()
        end
        task.wait(gA("TowerShopDelay", 3))
    end
end
RemoteFunction = nil
Library = nil
f0 = nil
BuildManager = nil
f2 = nil
f3 = nil
f4 = nil
f5 = nil
f6 = nil
f9 = nil
ga = nil
gb = nil
gc = nil
onBuySelectedNow = nil
ge = nil
gf = nil
connection2 = nil
gh = nil
gi = nil
gj = nil
gk = nil
HomeConfig = nil
gn = nil
LocalPlayer = nil
gp = nil
UnitConfig = nil
gr = nil
gt = nil
gu = nil
EnumType = nil
onCollectFloorNow = nil
VirtualUser = nil
Options = nil
gA = nil
onUpgradeNow = nil
gC = nil
gD = nil
connection = nil
BuildCofig = nil
gG = nil
Toggles = nil
gI = nil
gJ = nil
gK = nil
local fZ, RemoteFunction_shop, f8, gl, gs, HttpService
gL = nil
gN = nil
gO = nil
ReplicatedStorage = nil
gQ = nil
clientRequestServer = nil
gS = nil
local RemoteEvent_Notice
local g5_1
local SaveManager
local g2_1
local GameInfoGroup
local gV_1, gV_3
ReplicatedStorage, VirtualUser, HttpService, LocalPlayer, gh, gf, RemoteFunction_shop, BuildManager, RemoteFunction, clientRequestServer, RemoteEvent_Notice, BuildCofig, EnumType, UnitConfig, HomeConfig = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local AccountGroup
ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
LocalPlayer = Players.LocalPlayer
local gX = "Merge Anime Defender"
gh = "https://discord.gg/K7Qxnxkk46"
gf = "https://discord.gg/K7Qxnxkk46"
local events = ReplicatedStorage:WaitForChild("events")
RemoteFunction_shop = events:WaitForChild("RemoteFunction_shop")
BuildManager = ReplicatedStorage:WaitForChild("BuildManager")
RemoteFunction = BuildManager:WaitForChild("RemoteFunction")
clientRequestServer = ReplicatedStorage:WaitForChild("RemoteFunction"):WaitForChild("clientRequestServer")
RemoteEvent_Notice = ReplicatedStorage:WaitForChild("RemoteEvent"):WaitForChild("RemoteEvent_Notice")
pcall(fn294)
pcall(fn307)
pcall(fn467)
local gW = BuildCofig and BuildCofig.clientRemoteFunction.SpawnUnit
local gW_1
local gT_1 = gW or 5
local gU_1 = BuildCofig
gC = gT_1
if gU_1 then
    gU_1 = BuildCofig.clientRemoteFunction.AutoFuseUnit
end
local gT_2 = gU_1 or 9
local gU_2 = EnumType
gp = gT_2
if gU_2 then
    gU_2 = EnumType.clientRemoteFunction.Upgrade
end
local gT_3 = gU_2
local hp = if gT_3 then 1 else 0
local hn = 18 * hp + 2057 * (1 - hp)
local ho = 316 * hp + 1179 * (1 - hp)
if not ((hn * 668 + ho * 3233 + hn * ho) % 16777213 == 1039340) then
    gT_3 = 1000000106
end
local gU_3 = EnumType
gi = gT_3
if gU_3 then
    gU_3 = EnumType.clientRemoteFunction.EquipBest
end
local gT_4 = gU_3 or 1000000109
local gU_4 = EnumType
ga = gT_4
if gU_4 then
    gU_4 = EnumType.clientRemoteFunction.EquipBestHero
end
local gT_5 = gU_4 or 1000000108
local gU_5 = EnumType
f3 = gT_5
if gU_5 then
    gU_5 = EnumType.clientRemoteFunction.AutoCollect
end
local gT_6 = gU_5 or 1000000107
local gU_6 = EnumType
gS = gT_6
if gU_6 then
    gU_6 = EnumType.HomeUpgrade.Rebirth
end
local gT_7 = gU_6 or "Rebirth"
local gU_7 = EnumType
gG = gT_7
if gU_7 then
    gU_7 = EnumType.clientRemoteEvent.MAGNETDROP
end
local gT_8 = gU_7 or 6060
gs, gV_1, gl, gW_1 = nil, nil, nil, nil
local gU_8 = 4
repeat
    local gZ_1 = (gU_8 * 1 + 2) % 3 + 1
    if gZ_1 <= 2 then
        if gZ_1 <= 1 then
            if (gU_8 * 2 + 1) * 4 % 3 == ((gU_8 * 2 + 1) * 4 + 2) % 3 then
                gT_8 = gs
            else
                gs = gT_8
            end
            gU_8 = (gU_8 + 13) % 24
        else
            local gZ_2 = { "llvrwpvws", "tvvkt", "frfqz", "ykbkutp", "ekabvp", "qgh", "bjsbew", "xruoeey" }
            local j5 = gU_8
            local g__1 = gZ_2[j5 % 8 + 1]
            if g__1:len() >= g__1:reverse():rep(j5 % 3 + 2):len() then
                gl = {
                    { kind = "AttackSpeed", label = "Attack Speed" },
                    { kind = "Coins", label = "Coin Value" },
                    { kind = "Damage", label = "Damage" },
                    { kind = "Spawnlevel", label = "Spawn Level" },
                    { kind = "CriticalChance", label = "Critical Chance" },
                    { kind = "CriticalDanamge", label = "Critical Damage" },
                    { kind = "AttackRange", label = "Attack Range" },
                    { kind = "ActiveSlots", label = "Active Slots" },
                    { kind = "Gems", label = "Gem Chance" },
                    { kind = "PickupRange", label = "Pickup Radius" },
                    { kind = "BaseHp", label = "Base HP" }
                }
            else
                gV_1 = {
                    { kind = "Coins", label = "Coin Value" },
                    { kind = "Damage", label = "Damage" },
                    { kind = "AttackSpeed", label = "Attack Speed" },
                    { kind = "AttackRange", label = "Attack Range" },
                    { kind = "BaseHp", label = "Base HP" },
                    { kind = "CriticalChance", label = "Critical Chance" },
                    { kind = "CriticalDanamge", label = "Critical Damage" },
                    { kind = "Gems", label = "Gem Chance" },
                    { kind = "PickupRange", label = "Pickup Radius" },
                    { kind = "Spawnlevel", label = "Spawn Level" },
                    { kind = "ActiveSlots", label = "Active Slots" }
                }
            end
            gU_8 = (gU_8 + 10) % 24
        end
    else
        local gZ_3 = {
            "pxidltxbai",
            "pzhsawtz",
            "psduxpf",
            "yuscueakx",
            "rplthxwjqkr",
            "xumvbvatha",
            "cudsvklvie",
            "lioy",
            "qvdbnuj"
        }
        local kk = gU_8
        local g__2 = gZ_3[kk % 9 + 1]
        if g__2:len() >= g__2:gsub("(.)", "%1%1", kk % 3 % 2 + 1):len() then
            gW_1 = {}
            gl = {}
        else
            gl = {}
            gW_1 = {}
        end
        gU_8 = (gU_8 + 22) % 24
    end
until (gU_8 * 19 + 14) % 24 == 9
for i, v in ipairs(gV_1) do
    local gU_9 = EnumType and EnumType.HomeUpgrade[v.kind] or v.kind
    gl[v.label] = gU_9
    table.insert(gW_1, v.label)
end
gQ, gJ, Library, SaveManager, Toggles, Options, g2_1, gb, gu, ge, f0, gL, f4, gA, f8, gO, gk, gc, gI, fZ, onBuySelectedNow, onUpgradeNow, gN, gj, gK, f9, onCollectFloorNow = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
gQ = {}
gJ = {}
pcall(fn109)
Library = getgenv().Library
if ("#e8a34d" or (false or not gj) or (not gk or false) and (fZ or not g2_1)) and (not gN and fZ and (not g2_1 or g2_1) and (not gk and false or "#e8a34d")) and not (("#e8a34d" or (false or not gj) or (not gk or false) and (fZ or not g2_1)) and (not gN and fZ and (not g2_1 or g2_1) and (not gk and false or "#e8a34d"))) then
    local _ = getgenv().SaveManager
    g5_1 = getgenv().SaveManager
else
    g5_1 = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
end
Toggles = Library.Toggles
Options = Library.Options
gu = fn47
ge = fn55
f0 = fn123
gL = fn430
local g3 = "#7fd47f"
local g2_2 = "#6ec1ff"
gb = "#e8a34d"
local g0 = "#8b93a3"
f4 = fn565
gA = fn94
f8 = fn541
gO = fn506
gk = fn468
gc = function()
    local a4
    pcall(function()
        local TextLabel = LocalPlayer.PlayerGui.SpawnSurfaceGui.Frame.Unitbuy.cost.TextLabel
        a4 = tonumber((TextLabel.Text:gsub("%D", "")))
    end)
    return a4
end
gI = fn589
fZ = function()
    local bk = {}
    pcall(function()
        local ScrollingFrame = LocalPlayer.PlayerGui.MainGui.Unitshop.content.ScrollingFrame
        for i, child in ipairs(ScrollingFrame:GetChildren()) do
            local attr = child:GetAttribute("id")
            if attr then
                local h4 = child:GetAttribute("num") or 0
                local h5 = (child:GetAttribute("price"))
                local ih = if h5 then 1 else 0
                local ie = 3272 * ih + 4084 * (1 - ih)
                local ig = 639 * ih + 2211 * (1 - ih)
                if not ((ie * 4060 + ig * 1381 + ie * ig) % 16777213 == 16257587) then
                    h5 = 0
                end
                bk[attr] = { num = h4, price = h5 }
            end
        end
    end)
    return bk
end
onBuySelectedNow = function()
    local ij = fZ()
    local ik = gk()
    local il = f4("TowerShopAffordable")
    for k, v in pairs(f8("TowerShopUnits")) do
        if v then
            local ii = gQ[k]
            local im = ii and ij[ii]
            local io = im
            if im then
                im = io.num > 0
            end
            if im then
                im = not il or ik >= io.price
            end
            if im then
                pcall(function()
                    RemoteFunction_shop:InvokeServer("buyYingyangye", { id = ii })
                end)
                task.wait(0.2)
            end
        end
    end
end
onUpgradeNow = function()
    for k, v in pairs(f8("UpgradeKinds")) do
        if v then
            local ix = gl[k]
            if ix then
                pcall(function()
                    clientRequestServer:InvokeServer(gi, { ix })
                end)
                task.wait(0.15)
            end
        end
    end
end
gN = fn487
gj = fn136
gK = fn292
f9 = fn503
onCollectFloorNow = function()
    local DropItem = workspace:FindFirstChild("DropItem")
    local iH_1
    if not DropItem then
        return
    end
    for i, child in ipairs(DropItem:GetChildren()) do
        local iG
        local iP = child
        if iP:IsA("Attachment") then
            local attr = iP:GetAttribute("RewardData")
            if attr then
                iH_1, iG = pcall(function()
                    return HttpService:JSONDecode(attr)
                end)
                if iH_1 and iG then
                    pcall(function()
                        RemoteEvent_Notice:FireServer(gs, { iG })
                    end)
                end
            end
            pcall(function()
                iP:Destroy()
            end)
        end
    end
end
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = gh, Copyable = true }, "|", gX },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local g1 = {}
g1.Info = Window:AddTab("Info", "info")
local MainTab = Window:AddTab("Main", "gamepad-2")
g1.Settings = Window:AddTab("Settings", "settings")
MainTab:SetSubTabAlignment("Center")
g1.Economy = MainTab:AddSubTab("Economy", "coins")
g1.Combat = MainTab:AddSubTab("Combat", "swords")
for k, v in g1 do
    fn194(v)
end
gD, AccountGroup, GameInfoGroup, f6, f2, gV_3 = nil, nil, nil, nil, nil, nil
local gU_11 = 7
repeat
    local g__4 = (gU_11 * 1 + 1) % 3 + 1
    if g__4 <= 2 then
        if g__4 <= 1 then
            if (AccountGroup or not gV_3) and (AccountGroup or GameInfoGroup) or (not GameInfoGroup and GameInfoGroup or (AccountGroup or not GameInfoGroup)) or not ((AccountGroup or not gV_3) and (AccountGroup or GameInfoGroup) or (not GameInfoGroup and GameInfoGroup or (AccountGroup or not GameInfoGroup))) then
                f2 = tostring(game.JobId)
            else
                f6 = tostring(game.JobId)
            end
            gU_11 = (gU_11 + 10) % 12
        else
            local kc = bit32.rrotate(bit32.bxor(bit32.lrotate(gU_11, 21), string.byte(tostring(f2))), 29)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(kc, 625242191), 2530575725), (bit32.bxor(bit32.band(kc, 3669725104), 1606477971))), 2530575725), 1606477971) == kc then
                gV_3 = #f2 > 18
            else
                f2 = #gV_3 > 18
            end
            gU_11 = (gU_11 + 7) % 12
        end
    else
        local j_ = bit32.rrotate(bit32.bxor(bit32.lrotate(gU_11, 30), string.byte(tostring(gD))), 23)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(j_, 4193156493), 4035937105), (bit32.bxor(bit32.band(j_, 101810802), 1226182949))), 4035937105), 1226182949) == j_ then
            gD = "Unknown"
            pcall(fn116)
            AccountGroup = g1.Info:AddLeftGroupbox("Account", "circle-user")
            AccountGroup:AddLabel(gL("User", LocalPlayer.Name, g3), true)
            AccountGroup:AddLabel(gL("Status", "Keyless", g3), true)
            AccountGroup:AddLabel(gL("Executor", gD, g3), true)
            GameInfoGroup = g1.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            GameInfoGroup:AddLabel(f0(gX .. " [" .. tostring(game.PlaceId) .. "]", g2_2), true)
            GameInfoGroup:AddLabel(gL("Place ID", tostring(game.PlaceId), g2_2), true)
            f6 = GameInfoGroup:AddLabel(gL("Session time", "0s", gb), true)
        else
            gL = "Unknown"
            pcall(fn116)
            g2_2 = LocalPlayer.Info:AddLeftGroupbox("Account", "circle-user")
            g2_2:AddLabel(gb("User", GameInfoGroup.Name, f0), true)
            g2_2:AddLabel(gb("Status", "Keyless", f0), true)
            g2_2:AddLabel(gb("Executor", gL, f0), true)
            g1 = LocalPlayer.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            g1:AddLabel(AccountGroup(gD .. " [" .. tostring(game.PlaceId) .. "]", f6), true)
            g1:AddLabel(gb("Place ID", tostring(game.PlaceId), f6), true)
            gX = g1:AddLabel(gb("Session time", "0s", g3), true)
        end
        gU_11 = (gU_11 + 10) % 12
    end
until (gU_11 * 5 + 10) % 12 == 0
if gV_3 then
    local gT_12 = 2
    repeat
        local gU_12 = (vector.create((gT_12 * 4 + 4) % 11 + 1, (gT_12 * 3 + 12) % 13 + 1, (gT_12 * 13 + 2) % 17 + 1))
        local jT = vector.floor(gU_12) + vector.ceil(gU_12 * -1)
        if vector.dot(jT, jT) == 3 then
            f2 = string.sub(gV_3, 1, 18) .. "..."
        else
            gV_3 = string.sub(f2, 1, 18) .. "..."
        end
        gT_12 = (gT_12 + 3) % 4
    until (gT_12 * 3 + 3) % 4 == 2
end
local gT_13 = gV_3
local hp_1 = if gT_13 then 1 else 0
local hn_1 = 209 * hp_1 + 1809 * (1 - hp_1)
ho = 352 * hp_1 + 1587 * (1 - hp_1)
if not ((hn_1 * 3908 + ho * 2012 + hn_1 * ho) % 16777213 == 1598564) then
    gT_13 = f2
end
gt, gr, gn, connection, connection2, f5 = nil, nil, nil, nil, nil, nil
local hh = gT_13
GameInfoGroup:AddLabel(gL("Server", hh, g0), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
gt = os.clock()
task.spawn(worker)
local ScriptsGroup = g1.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(f0("Included in this hub", g0), true)
ScriptsGroup:AddLabel(f0(gX, g2_2), true)
local FeaturesGroup = g1.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(f0("Auto Buy Units", g2_2), true)
FeaturesGroup:AddLabel(f0("Auto Collect", g3), true)
FeaturesGroup:AddLabel(f0("Auto Collect Floor", g3), true)
FeaturesGroup:AddLabel(f0("Auto Tower Shop", gb), true)
FeaturesGroup:AddLabel(f0("Auto Upgrades", g3), true)
FeaturesGroup:AddLabel(f0("Auto Fuse All", g2_2), true)
FeaturesGroup:AddLabel(f0("Auto Equip Best", gb), true)
FeaturesGroup:AddLabel(f0("Auto Rebirth", g2_2), true)
local SocialsGroup = g1.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = ge })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = g1.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = ge })
local FaqGroup = g1.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutoBuyUnitsGroup = g1.Economy:AddLeftGroupbox("Auto Buy Units", "shopping-cart")
AutoBuyUnitsGroup:AddToggle("AutoBuy", { Text = "Auto Buy Units", Default = false })
AutoBuyUnitsGroup:AddDropdown("BuyMode", {
    Text = "Buy mode",
    Values = { "Continuous", "Only while affordable" },
    Default = "Only while affordable"
})
AutoBuyUnitsGroup:AddSlider("BuyDelay", { Text = "Buy delay", Default = 1, Min = 0.1, Max = 30, Rounding = 1, Suffix = "s" })
AutoBuyUnitsGroup:AddButton({ Text = "Buy Now", Func = gI })
local AutoCollectGroup = g1.Economy:AddLeftGroupbox("Auto Collect", "hand-coins")
AutoCollectGroup:AddToggle("AutoCollect", { Text = "Auto Collect Coins & Diamonds", Default = false })
AutoCollectGroup:AddSlider("CollectDelay", { Text = "Collect delay", Default = 3, Min = 0.5, Max = 60, Rounding = 1, Suffix = "s" })
AutoCollectGroup:AddButton({ Text = "Collect Now", Func = gK })
local AutoCollectFloorGroup = g1.Economy:AddLeftGroupbox("Auto Collect Floor", "magnet")
AutoCollectFloorGroup:AddToggle("AutoCollectFloor", { Text = "Auto Collect Floor Drops", Default = false })
AutoCollectFloorGroup:AddSlider("FloorDelay", { Text = "Floor collect delay", Default = 1, Min = 0.1, Max = 30, Rounding = 1, Suffix = "s" })
AutoCollectFloorGroup:AddButton({ Text = "Collect Floor Now", Func = onCollectFloorNow })
local AutoTowerShopGroup = g1.Economy:AddRightGroupbox("Auto Tower Shop", "store")
AutoTowerShopGroup:AddToggle("AutoTowerShop", { Text = "Auto Tower Shop", Default = false })
AutoTowerShopGroup:AddDropdown("TowerShopUnits", { Text = "Units to buy", Values = gJ, Multi = true, AllowNull = true, Default = {} })
AutoTowerShopGroup:AddToggle("TowerShopAffordable", { Text = "Only if affordable", Default = true })
AutoTowerShopGroup:AddSlider("TowerShopDelay", { Text = "Tower shop delay", Default = 3, Min = 0.5, Max = 60, Rounding = 1, Suffix = "s" })
AutoTowerShopGroup:AddButton({ Text = "Buy Selected Now", Func = onBuySelectedNow })
local AutoUpgradesGroup = g1.Combat:AddLeftGroupbox("Auto Upgrades", "arrow-big-up-dash")
AutoUpgradesGroup:AddToggle("AutoUpgrade", { Text = "Auto Upgrades", Default = false })
AutoUpgradesGroup:AddDropdown("UpgradeKinds", { Text = "Upgrades", Values = gW_1, Multi = true, AllowNull = true, Default = {} })
AutoUpgradesGroup:AddSlider("UpgradeDelay", { Text = "Upgrade delay", Default = 2, Min = 0.2, Max = 60, Rounding = 1, Suffix = "s" })
AutoUpgradesGroup:AddButton({ Text = "Upgrade Now", Func = onUpgradeNow })
local AutoFuseGroup = g1.Combat:AddRightGroupbox("Auto Fuse", "combine")
AutoFuseGroup:AddToggle("AutoFuse", { Text = "Auto Fuse All", Default = false })
AutoFuseGroup:AddSlider("FuseDelay", { Text = "Fuse delay", Default = 1, Min = 0.1, Max = 30, Rounding = 1, Suffix = "s" })
AutoFuseGroup:AddButton({ Text = "Fuse Now", Func = gN })
local AutoEquipGroup = g1.Combat:AddRightGroupbox("Auto Equip", "shield")
AutoEquipGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
AutoEquipGroup:AddSlider("EquipDelay", { Text = "Equip delay", Default = 5, Min = 0.5, Max = 60, Rounding = 1, Suffix = "s" })
AutoEquipGroup:AddButton({ Text = "Equip Best Now", Func = gj })
local AutoRebirthGroup = g1.Combat:AddLeftGroupbox("Auto Rebirth", "rotate-ccw")
AutoRebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
AutoRebirthGroup:AddSlider("RebirthDelay", { Text = "Rebirth delay", Default = 10, Min = 1, Max = 120, Rounding = 1, Suffix = "s" })
AutoRebirthGroup:AddButton({ Text = "Rebirth Now", Func = f9 })
local MenuGroup = g1.Settings:AddLeftGroupbox("Menu", "menu")
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton({ Text = "Unload", Func = onUnload })
g5_1:SetLibrary(Library)
g5_1:SetFolder("TempoHub")
g5_1:SaveDefault("Monochrome")
g5_1:ApplyToTab(g1.Settings)
g5_1:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/merge-anime-defender")
SaveManager:BuildConfigSection(g1.Settings)
SaveManager:LoadAutoloadConfig()
gr = tick()
gn = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local jc = v
        pcall(function()
            jc:Disable()
        end)
    end
end)
f5 = fn421
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
Library:OnUnload(fn560)
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(worker6)
task.spawn(worker7)
task.spawn(worker8)
task.spawn(worker9)
task.spawn(worker10)
Library:Notify("Merge Anime Defender loaded")
end)(...)

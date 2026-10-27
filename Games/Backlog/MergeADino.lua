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
getgenv().TempoHoodSubtitle = "MERGE A DINO"
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
local p7
local qt
local pP
local qw
local qa
local qz
local qd
local qg
local qC
local qj
local pF
local p0
local qm
local pI
local qp
local p6
local pL
local qv
local p9
local pR
local qc
local qy
local pU
local qf
local qB
local pX
local qi
local pE
local ql
local CoreGui
local LocalPlayer
local pN
local pQ
local qx
local qb
local qe
local qA
local qD
local pD
local State
local qn
local p1
local pJ
local p4
local qq
local function fn76()
    local targets = qt.targets
    local uS_1
    local uT = next(targets) == nil
    local uT_1
    local uU = pX()
    local uV
    for i, v in ipairs(qf()) do
        if uT or targets[qv[v]] then
            local uW_2 = pP(v)
            if uW_2 and uW_2.price <= uU then
                if not uV or uW_2.price < uV.price then
                    uV = uW_2
                end
            end
        end
    end
    if not uV then
        pQ("No upgrade is affordable yet")
        return
    end
    uS_1, uT_1 = p0("UpgradeRequest", uV.key)
    if uS_1 and uT_1 ~= false then
        pQ("Bought " .. qv[uV.key] .. " level " .. tostring(uV.level + 1))
    else
        pQ(qv[uV.key] .. " purchase was refused")
    end
end
local function fn110(aK, aL, aM)
    local Remotes = pF:FindFirstChild("Remotes")
    local rz = Remotes and Remotes:FindFirstChild(aK)
    local ry_1 = rz
    if rz then
        rz = ry_1:FindFirstChild(aL)
    end
    local ry_2 = rz
    if rz then
        rz = ry_2:IsA(aM)
    end
    if rz then
        return ry_2
    end
    return nil
end
local function fn111(U)
    local rg = typeof(cloneref) == "function" and typeof(U) == "Instance"
    if rg then
        return cloneref(U)
    end
    return U
end
local function fn112(ft)
    if ft then
        qj(qt, pU)
    else
        qe(qt)
    end
end
local function fn158()
    return qw({ "Data" })
end
local function fn163(fB)
    if fB then
        qj(qp, qi)
    else
        qe(qp)
    end
end
local function fn196(b3)
    local RootPart = b3:FindFirstChild("RootPart")
    local sy = RootPart and RootPart:IsA("BasePart")
    if sy then
        return RootPart
    end
    return b3:FindFirstChildWhichIsA("BasePart", true)
end
local function fn238(fy)
    qt.targets = p4(fy)
end
local function fn246()
    local rY = qb()
    if not rY then
        return 0
    end
    local rZ = (tonumber(pI(rY.Cash)))
    local r2 = if rZ then 1 else 0
    local r0 = 3408 * r2 + 1838 * (1 - r2)
    local r1 = 2175 * r2 + 3000 * (1 - r2)
    if not ((r0 * 1603 + r1 * 175 + r0 * r1) % 16777213 == 13256049) then
        rZ = 0
    end
    return rZ
end
local function fn248()
    local rV = p1()
    return rV and rV.client or nil
end
local function fn258(fl)
    local vb = fl and true or false
    pD.restore = vb
end
local function fn273(c5, c6)
    local tr = os.clock()
    local tt = tr + (c6 or 3)
    while true do
        local tr_1 = pL() and os.clock() < tt
        if not tr_1 then
            return c5.Parent == nil
        end
        if c5.Parent == nil then
            break
        end
        task.wait(0.1)
    end
    return true
end
local function fn278()
    local Map = qz:FindFirstChild("Map")
    local sa = Map ~= nil and Map:GetAttribute("LockSystemEnabled") == true
    return sa
end
local function fn289()
    return not qg.Unloaded
end
local function fn297(al)
    State.Status = tostring(al)
end
local function fn312(bO)
    local sl = bO or qc()
    bO = sl
    if sl then
        sl = bO:FindFirstChild("ActiveDinos")
    end
    local sm = sl
    if not sm then
        return {}
    end
    local sl_1 = {}
    for i, child in ipairs(sm:GetChildren()) do
        if child:IsA("Model") then
            table.insert(sl_1, child)
        end
    end
    return sl_1
end
local function fn334(cx)
    local sZ_2
    local sX = p7()
    local sX_1
    local sY = {}
    for i, v in ipairs(qx(cx)) do
        if qn(v, sX) then
            local sZ_1 = sY[v.Name]
            if not sZ_1 then
                sZ_1 = {}
                sY[v.Name] = sZ_1
            end
            table.insert(sZ_1, v)
        end
    end
    sZ_2, sX_1 = nil, nil
    for k, v in pairs(sY) do
        if #v >= 2 then
            local s_ = pN(v[1])
            if sX_1 == nil or s_ < sX_1 then
                sZ_2, sX_1 = k, s_
            end
        end
    end
    if not sZ_2 then
        return nil, nil
    end
    local sX_2 = sY[sZ_2]
    return sX_2[1], sX_2[2]
end
local function fn353()
    local Map = qz:FindFirstChild("Map")
    local sd = Map and Map:FindFirstChild("Plots")
    if not sd then
        return nil
    end
    for i, child in ipairs(sd:GetChildren()) do
        local sc_2 = child:IsA("Model") and child:GetAttribute("Owner") == LocalPlayer.UserId
        if sc_2 then
            return child
        end
    end
    return nil
end
local function fn357(cZ, c_)
    local tn = os.clock()
    local tp = tn + (c_ or 2)
    while true do
        local tn_1 = pL() and os.clock() < tp
        if not tn_1 then
            local tn_2 = cZ.Parent ~= nil and cZ:GetAttribute("Held") == true
            return tn_2
        end
        if cZ.Parent == nil then
            break
        end
        if cZ:GetAttribute("Held") == true then
            return true
        end
        task.wait(0.1)
    end
    return false
end
local function fn362()
    local r7 = tonumber(LocalPlayer:GetAttribute("Rebirths")) or 0
    return r7
end
local function fn415()
    return CoreGui
end
local function fn425(ds)
    local tG = {}
    if type(ds) == "table" then
        for k, v in pairs(ds) do
            local tH = v == true and type(k) == "string"
            if tH then
                tG[k] = true
            elseif type(v) == "string" then
                tG[v] = true
            end
        end
    end
    return tG
end
local function fn461()
    qe(pD)
    qe(qy)
    qe(qt)
    qe(qp)
end
local function fn525()
    if not qA() then
        pQ("Base locking is disabled on this map")
        return
    end
    local u4 = qc()
    local u4_2
    if not u4 then
        pQ("Waiting for your plot")
        return
    end
    if u4:GetAttribute("UnderAttack") == true then
        pQ("Cannot lock while under attack")
        return
    end
    local u4_1 = p7()
    local u5 = tonumber(LocalPlayer:GetAttribute("LockEndsAt")) or 0
    local u5_2
    local u5_1 = tonumber(LocalPlayer:GetAttribute("LockCooldownEndsAt")) or 0
    if u5 > u4_1 then
        pQ(("Base locked for %ds"):format(math.floor(u5 - u4_1)))
        return
    end
    if u5_1 > u4_1 then
        pQ(("Lock cooldown %ds"):format(math.floor(u5_1 - u4_1)))
        return
    end
    u4_2, u5_2 = p0("LockBaseRequest")
    if u4_2 and u5_2 ~= false then
        pQ("Locked the base")
    else
        pQ("Lock request was refused")
    end
end
local function fn544()
    local t0 = 0
    for i, v in ipairs(qx()) do
        t0 = math.max(t0, pN(v))
    end
    return t0
end
local function fn565(eI)
    local uM = qm()
    local uN = uM and uM[eI]
    if not uN then
        return nil
    end
    local uN_1 = qC(eI)
    if not uN_1 then
        return nil
    end
    local uO = uN[uN_1]
    local uP = uN[uN_1 + 1]
    if not uO or not uP then
        return nil
    end
    local uM_3 = pJ()
    local uQ_1 = tonumber(uP.RebirthsRequired) or 0
    if uM_3 < uQ_1 then
        return nil
    end
    local uM_4 = tonumber(uO.Price)
    if not uM_4 then
        return nil
    end
    return { key = eI, level = uN_1, price = uM_4 }
end
local function fn593()
    local uo = {}
    for i, v in ipairs(qq) do
        local up = v ~= "LockBase" or qA()
        if up then
            table.insert(uo, v)
        end
    end
    return uo
end
local function fn685(X)
    return type(X) == "function"
end
local function fn690()
    return qw({ "Constants", "Upgrades" })
end
local function fn692(cr, cs)
    local sR = cr:GetAttribute("Held") == true or cr:GetAttribute("Merging") == true
    if sR then
        return false
    end
    local sW = if cr:GetAttribute("Attacking") == true then 1 else 0
    if sW == 1 then
        return false
    end
    local sR_1 = (tonumber(cr:GetAttribute("PickupReadyAt")))
    local sW_1 = if sR_1 then 1 else 0
    local sU = 2764 * sW_1 + 3375 * (1 - sW_1)
    local sV = 450 * sW_1 + 1573 * (1 - sW_1)
    if not ((sU * 3120 + sV * 1574 + sU * sV) % 16777213 == 10575780) then
        sR_1 = 0
    end
    if sR_1 > cs then
        return false
    end
    return qd(cr) ~= nil
end
local function fn718(ag, ah)
    if not pL() then
        return
    end
    local Notifications = State.Notifications
    local rk = tostring(ag)
    local rl = ah or 5
    table.insert(Notifications, { text = rk, time = rl })
    if #State.Notifications > 12 then
        table.remove(State.Notifications, 1)
    end
end
local function fn729()
    return qw({ "Constants", "DinoStats" })
end
local function fn734(ap)
    local rq_1
    local rn = table.concat(ap, ".")
    local ro = qD[rn]
    local ro_4
    if ro ~= nil then
        return ro
    end
    local Modules = pF:FindFirstChild("Modules")
    if not Modules then
        return nil
    end
    local rp = Modules
    for i, v in ipairs(ap) do
        local ro_2 = rp and rp:FindFirstChild(v)
        rp = ro_2
    end
    local ro_3 = not rp or not rp:IsA("ModuleScript")
    if ro_3 then
        return nil
    end
    ro_4, rq_1 = pcall(require, rp)
    local rp_1 = not ro_4 or type(rq_1) ~= "table"
    if rp_1 then
        return nil
    end
    qD[rn] = rq_1
    return rq_1
end
local function fn752(ck)
    for i, v in ipairs(qx(ck)) do
        local sJ = v:GetAttribute("Held") == true and v:GetAttribute("OwnerUserId") == LocalPlayer.UserId
        if sJ then
            return v
        end
    end
    return nil
end
local function fn765()
    local ul_1
    local uk_1
    local uj = pR()
    if not uj then
        pQ("Rebirth requirement unavailable")
        return
    end
    if ql() < uj then
        pQ("Rebirth needs a higher tier dino")
        return
    end
    local uj_1 = pJ()
    uk_1, ul_1 = p0("RebirthRequest")
    if uk_1 and ul_1 then
        State.Rebirths = State.Rebirths + 1
        qa("Rebirthed (" .. tostring(uj_1 + 1) .. ")")
        pQ("Rebirthed")
    else
        pQ("Rebirth was refused")
    end
end
local function fn796(bX)
    local su = p6()
    local sv = su and su[bX.Name]
    local su_1 = sv
    if sv then
        sv = tonumber(su_1.Tier)
    end
    return sv or 0
end
local function fn802(dq)
    dq.stopped = true
    local tE = dq.generation or 0
    dq.generation = tE + 1
end
local function fn804()
    local rK_1
    local rJ_1
    rJ_1, rK_1 = pcall(function()
        return qz:GetServerTimeNow()
    end)
    local rL = rJ_1 and rK_1
    local rJ_2 = rL or os.time()
    return rJ_2
end
local function fn812(fo)
    if fo then
        qj(qy, p9)
    else
        qe(qy)
    end
end
local function fn817()
    local ux = {}
    for i, v in ipairs(qf()) do
        table.insert(ux, qv[v])
    end
    return ux
end
local function fn823(cP, cQ)
    local te = p7()
    for i, v in ipairs(qx(cP)) do
        local tf = v ~= cQ and v.Name == cQ.Name and qn(v, te)
        if tf then
            return v
        end
    end
    return nil
end
local function fn851()
    local Character = LocalPlayer.Character
    local sB = Character and Character:FindFirstChild("HumanoidRootPart")
    local sA_1 = sB
    if sB then
        sB = sA_1:IsA("BasePart")
    end
    if sB then
        return sA_1
    end
    return nil
end
local function fn854()
    local t8 = p6()
    if not t8 then
        return nil
    end
    local t9 = pJ()
    local ua = 0
    for k, v in pairs(t8) do
        local t8_1 = tonumber(v.RebirthsRequired) or 0
        if t8_1 <= t9 then
            local max = math.max
            local ub = tonumber(v.Tier) or 0
            ua = max(ua, ub)
        end
    end
    if ua > 0 then
        return ua
    end
    return nil
end
local function fn879()
    gethui = qB
end
local function fn890(fg)
    if fg then
        qj(pD, pE)
    else
        qe(pD)
    end
end
pD = nil
pE = nil
pF = nil
pI = nil
pJ = nil
LocalPlayer = nil
pL = nil
pN = nil
pP = nil
pQ = nil
pR = nil
pU = nil
pX = nil
p0 = nil
p1 = nil
CoreGui = nil
p4 = nil
p6 = nil
p7 = nil
p9 = nil
qa = nil
qb = nil
qc = nil
qd = nil
qe = nil
qf = nil
qg = nil
qi = nil
qj = nil
State = nil
ql = nil
qm = nil
qn = nil
local Players, pG, pH, Workspace, pO, pS, pT, Lighting, pW, pY, pZ, TeleportService, p3, GuiService, HttpService, VirtualUser, UserInputService
qp = nil
qq = nil
qt = nil
qv = nil
qw = nil
qx = nil
qy = nil
qz = nil
qA = nil
qB = nil
qC = nil
qD = nil
local qr, RunService, qu
if not game:IsLoaded() then
    game.Loaded:Wait()
end
Players, RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, TeleportService, Lighting, Workspace, LocalPlayer, qB = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local qG = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
TeleportService = game:GetService("TeleportService")
Lighting = game:GetService("Lighting")
if (not VirtualUser or TeleportService) and (VirtualUser or TeleportService) and (not VirtualUser and VirtualUser or TeleportService and not Players) and (not VirtualUser or Players or not Players and not TeleportService or (not TeleportService and TeleportService or (not TeleportService or not VirtualUser))) or (TeleportService or TeleportService or (TeleportService or not TeleportService)) and ((not TeleportService or Players) and (not Players or Players)) and ((TeleportService or not VirtualUser) and (TeleportService or TeleportService) or (not Players and VirtualUser or Players and not TeleportService)) or not ((not VirtualUser or TeleportService) and (VirtualUser or TeleportService) and (not VirtualUser and VirtualUser or TeleportService and not Players) and (not VirtualUser or Players or not Players and not TeleportService or (not TeleportService and TeleportService or (not TeleportService or not VirtualUser))) or (TeleportService or TeleportService or (TeleportService or not TeleportService)) and ((not TeleportService or Players) and (not Players or Players)) and ((TeleportService or not VirtualUser) and (TeleportService or TeleportService) or (not Players and VirtualUser or Players and not TeleportService))) then
    Workspace = game:GetService("Workspace")
else
    qG = game:GetService("Workspace")
end
LocalPlayer = Players.LocalPlayer
local qF = "TempoMergeADino"
qB = fn415
if getgenv then
    getgenv().gethui = qB
end
qg, pF, qz, qv, qq, State, qD, pD, qy, qt, qp, pO, pZ, pL, qa, pQ, qw, qm, p6, p1, pS, p0, p7, pI, qb, pX, qC, pJ, qA, qc, qx, pN, qd, pY, qu, pW, qn, pT, qr, pG, p3, qj, qe, p4, pE, ql, pR, p9, qf, pH, pP, pU, qi = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pcall(fn879)
local function qK(t)
    local q6
    local q4
    local q5
    q4 = nil
    q5 = nil
    q6 = nil
    local q7 = t ~= ""
    local q8 = type(t) == "string" and q7
    assert(q8, "A namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    q4 = getgenv()
    assert(type(q4) == "table", "getgenv did not return a table")
    local q7_1 = q4[t]
    if q7_1 ~= nil then
        local q8_1 = type(q7_1) == "table" and type(q7_1.Unload) == "function"
        assert(q8_1, "Namespace is occupied")
        q7_1.Unload()
        assert(q4[t] == nil, "Previous instance did not release its namespace")
    end
    q5 = {}
    q6 = { State = {}, Unloaded = false }
    q6.Track = function(z)
        assert(type(z) == "function", "Cleanup must be callable")
        if q6.Unloaded then
            z()
        else
            table.insert(q5, z)
        end
        return z
    end
    q6.Unload = function()
        local qY_1
        local qX_1
        if q6.Unloaded then
            return
        end
        q6.Unloaded = true
        local qV = {}
        local q1 = #q5
        local q0 = -1
        while false and q1 <= 1 or true and q1 >= 1 do
            local q2 = q1
            local qW_1 = table.remove(q5, q2)
            qX_1, qY_1 = pcall(qW_1)
            if not qX_1 then
                table.insert(qV, tostring(qY_1))
            end
            q1 += q0
        end
        table.clear(q6.State)
        if #qV > 0 then
            error("Cleanup incomplete: " .. table.concat(qV, "; "), 0)
        end
        if q4[t] == q6 then
            q4[t] = nil
        end
    end
    q4[t] = q6
    return q6
end
pO = function(M, N)
    local re = type(M) == "table" and type(M.Track) == "function"
    assert(re, "FeatureAPI required")
    local re_1 = type(N) == "table" and type(N.OnUnload) == "function"
    assert(re_1, "UI library required")
    assert(type(N.Unload) == "function", "UI unload required")
    M.Track(function()
        if not N.Unloaded then
            N:Unload()
        end
    end)
    N:OnUnload(function()
        M.Unload()
    end)
end
qg = qK(qF)
pZ = fn685
pL = fn289
pF = fn111(qG)
qz = fn111(Workspace)
qv = { SpawnTier = "Spawn Tier", MaxSpawn = "Base Capacity", LockBase = "Lock Time" }
qq = { "SpawnTier", "MaxSpawn", "LockBase" }
State = qg.State
State.Notifications = {}
State.Status = "Idle"
State.Merges = 0
State.Rebirths = 0
qa = fn718
pQ = fn297
qD = {}
qw = fn734
qm = fn690
p6 = fn729
p1 = fn158
pS = fn110
p0 = function(aV, ...)
    local rF
    local rE
    rE = nil
    rF = nil
    local rH_1
    local rG_1
    rF = pS("Functions", aV, "RemoteFunction")
    if not rF then
        pQ("Missing remote: " .. aV)
        return false, nil
    end
    rE = table.pack(...)
    rG_1, rH_1 = pcall(function()
        return rF:InvokeServer(table.unpack(rE, 1, rE.n))
    end)
    if not rG_1 then
        warn("[Tempo] " .. aV .. " failed: " .. tostring(rH_1))
        return false, nil
    end
    return true, rH_1
end
p7 = fn804
pI = function(ba)
    local rQ = type(ba)
    local rQ_1
    local rR = rQ ~= "table"
    local rR_2
    if rQ ~= "function" and rR and rQ ~= "userdata" then
        return nil
    end
    rQ_1, rR_2 = pcall(function()
        return ba()
    end)
    if not rQ_1 then
        return nil
    end
    return rR_2
end
qb = fn248
pX = fn246
qC = function(bo)
    local r3
    r3 = nil
    local r4 = qb()
    local r4_1
    local r5 = r4 and r4.Upgrades
    local r5_1
    r3 = r5
    if not r3 then
        return nil
    end
    r4_1, r5_1 = pcall(function()
        return r3[bo]
    end)
    if not r4_1 then
        return nil
    end
    return tonumber(pI(r5_1))
end
pJ = fn362
qA = fn278
qc = fn353
qx = fn312
pN = fn796
qd = fn196
if ((qf or not ql) and (not ql and qr) or (pQ and not ql or not pQ and not qf)) and ((qr or pQ) and (not qr or not pN) and (pQ and qr or (qf or not qf))) and not (((qf or not ql) and (not ql and qr) or (pQ and not ql or not pQ and not qf)) and ((qr or pQ) and (not qr or not pN) and (pQ and qr or (qf or not qf)))) then
    qu = fn851
    pY = function(cd)
        local sG
        sG = nil
        sG = pY()
        if not sG then
            return false
        end
        local sH = pcall(function()
            sG.CFrame = CFrame.new(cd + Vector3.new(0, 3, 0))
        end)
        return sH
    end
    qn = fn752
    pW = fn692
else
    pY = fn851
    qu = function(cd)
        local sG
        sG = nil
        sG = pY()
        if not sG then
            return false
        end
        local sH = pcall(function()
            sG.CFrame = CFrame.new(cd + Vector3.new(0, 3, 0))
        end)
        return sH
    end
    pW = fn752
    qn = fn692
end
pT = fn334
qr = fn823
pG = fn357
p3 = fn273
pD = { interval = 0.6, restore = true }
qy = { interval = 5 }
qt = { interval = 3, targets = {} }
qp = { interval = 5 }
qj = function(df, dg)
    local generation
    local tC = df.generation or 0
    df.generation = tC + 1
    df.stopped = false
    generation = df.generation
    task.spawn(function()
        local tw_1
        while true do
            local tv = pL() and not df.stopped and df.generation == generation
            local tv_1
            if tv then
                tv_1, tw_1 = pcall(dg)
                if not tv_1 then
                    warn("[Tempo] loop error: " .. tostring(tw_1))
                end
                local tv_2 = not pL() or df.stopped
                local tA = if tv_2 then 1 else 0
                local ty = 1218 * tA + 817 * (1 - tA)
                local tz = 2339 * tA + 2772 * (1 - tA)
                if not ((ty * 2565 + tz * 2415 + ty * tz) % 16777213 == 11621757) then
                    tv_2 = df.generation ~= generation
                end
                if tv_2 then
                    break
                end
                task.wait(df.interval)
                continue
            end
            break
        end
    end)
end
qe = fn802
p4 = fn425
pE = function()
    local tW_1
    local tU_1
    local tV_1
    local tS = qc()
    if not tS then
        pQ("Waiting for your plot")
        return
    end
    local tP = pY()
    if not tP then
        pQ("Waiting for your character")
        return
    end
    local CFrame = tP.CFrame
    local tT = pW(tS)
    if tT then
        tU_1 = qr(tS, tT)
        if not tU_1 then
            pQ("Holding " .. tT.Name .. " with no match on the plot")
            return
        end
    else
        tW_1, tV_1 = pT(tS)
        if not tW_1 then
            pQ("No matching pair to merge")
            return
        end
        tT, tU_1 = tW_1, tV_1
        local tS_1 = qd(tT)
        local tV_2 = not tS_1 or not qu(tS_1.Position)
        if tV_2 then
            return
        end
        if not pG(tT, 2) then
            pQ("Could not pick up " .. tT.Name)
            if pD.restore then
                pcall(function()
                    tP.CFrame = CFrame
                end)
            end
            return
        end
    end
    local tS_2 = qd(tU_1)
    if not tS_2 then
        return
    end
    qu(tS_2.Position)
    local tS_3 = p3(tT, 3)
    if tS_3 then
        State.Merges = State.Merges + 1
        pQ("Merged two " .. tU_1.Name)
    else
        pQ("Merge did not complete")
    end
    if pD.restore then
        task.wait(0.15)
        local tQ = pY()
        if tQ then
            pcall(function()
                tQ.CFrame = CFrame
            end)
        end
    end
end
ql = fn544
pR = fn854
p9 = fn765
qf = fn593
pH = fn817
pP = fn565
pU = fn76
qi = fn525
pD.SetEnabled = fn890
pD.SetRestore = fn258
qy.SetEnabled = fn812
qt.SetEnabled = fn112
qt.SetTargets = fn238
qp.SetEnabled = fn163
qg.Track(fn461)
local function qH()
    local onDiscord
    local zP
    local zO
    zO = nil
    zP = nil
    onDiscord = nil
    local ThemeManager, zM, Options, SaveManager, zR, zS, Library, Toggles, zW
    zS = "https://discord.gg/K7Qxnxkk46"
    zR = "Merge a Dino"
    zW = "https://tempohub.shop"
    zO = "https://discord.gg/K7Qxnxkk46"
    Library = getgenv().Library
    ThemeManager = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = Library.Toggles
    Options = Library.Options
    pO(qg, Library)
    zP = function(f_, f0)
        local vg = pZ(setclipboard) and setclipboard
        local vh = vg
        if not vh then
            local vg_1 = pZ(toclipboard) and toclipboard
            vh = vg_1 or nil
        end
        local vg_2 = vh
        if not vg_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local vh_1 = pcall(vg_2, f_)
        if vh_1 then
            Library:Notify(f0)
        else
            Library:Notify("Failed to copy")
        end
    end
    onDiscord = function()
        zP(zO, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = zO, Copyable = true }, "|", zR, "|", "v0.1" },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(false)
    zM = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gamepad-2"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
    local function zX_1(gd)
        local DiscordGroup = gd:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    for k, v in zM do
        if k ~= "Info" then
            zX_1(v)
        end
    end
    local function zY()
        local hc
        local DinosGroup = zM.Main:AddLeftGroupbox("Dinos", "shuffle")
        local Label = DinosGroup:AddLabel(State.Status, true)
        DinosGroup:AddDivider()
        DinosGroup:AddToggle("AutoMerge", {
            Text = "Auto Merge",
            Default = false,
            Tooltip = "Carries the lowest matching dino into its twin so the pair merges.",
            Callback = function(go)
                pD.SetEnabled(go)
            end
        })
        DinosGroup:AddToggle("MergeRestore", {
            Text = "Return To Your Spot",
            Default = true,
            Tooltip = "Walks you back to where you were standing after every merge.",
            Callback = function(gs)
                pD.SetRestore(gs)
            end
        })
        DinosGroup:AddSlider("MergeInterval", {
            Text = "Merge Delay",
            Default = 0.6,
            Min = 0.2,
            Max = 5,
            Rounding = 1,
            Suffix = "s",
            Callback = function(gu)
                pD.interval = gu
            end
        })
        local RebirthGroup = zM.Main:AddLeftGroupbox("Rebirth", "rotate-ccw")
        RebirthGroup:AddToggle("AutoRebirth", {
            Text = "Auto Rebirth",
            Default = false,
            Tooltip = "Rebirths as soon as your plot holds a dino of the required tier.",
            Callback = function(gx)
                qy.SetEnabled(gx)
            end
        })
        local UpgradesGroup = zM.Main:AddRightGroupbox("Upgrades", "arrow-big-up-dash")
        UpgradesGroup:AddToggle("AutoUpgrades", {
            Text = "Auto Buy Upgrades",
            Default = false,
            Tooltip = "Buys the cheapest affordable upgrade you have selected.",
            Callback = function(gC)
                qt.SetEnabled(gC)
            end
        })
        UpgradesGroup:AddDropdown("UpgradeTargets", {
            Text = "Upgrades",
            Values = pH(),
            Default = {},
            Multi = true,
            AllowNull = true,
            Tooltip = "Leave everything unticked to buy every upgrade you can afford.",
            Callback = function(gI)
                qt.SetTargets(gI)
            end
        })
        local DefenseGroup = zM.Main:AddRightGroupbox("Defense", "lock")
        DefenseGroup:AddToggle("AutoLock", {
            Text = "Auto Lock Base",
            Default = false,
            Tooltip = "Raises the fences again the moment the lock and its cooldown expire.",
            Callback = function(gL)
                qp.SetEnabled(gL)
            end
        })
        hc = task.spawn(function()
            while not Library.Unloaded do
                pcall(function()
                    local vn = qx()
                    local vp = #vn
                    local vq = math.floor(pX())
                    local vr = pJ()
                    local vs = State.Merges or 0
                    local vt = string.format("Dinos %d  |  Cash %d  |  Rebirths %d  |  Merges %d", vp, vq, vr, vs)
                    Label:SetText(vt .. "  |  " .. tostring(State.Status))
                end)
                local vz = false
                repeat
                    local vv
                    if State.Notifications and #State.Notifications > 0 then
                        vv = table.remove(State.Notifications, 1)
                        pcall(function()
                            Library:Notify(vv.text, vv.time)
                        end)
                    else
                        vz = true
                    end
                until vz
                task.wait(0.3)
            end
        end)
        qg.Track(function()
            if coroutine.status(hc) ~= "dead" then
                pcall(task.cancel, hc)
            end
        end)
    end
    zY()
    local function zX_2()
        local vU
        local v0
        local vX
        local v3
        vU = nil
        vX = nil
        v0 = nil
        v3 = nil
        local vT, vV, Label, vY, vZ, v_, Label2, v2, Label3
        vU = function(hh)
            return (tostring(hh):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
        end
        v0 = function(hj, hk)
            return string.format('<font color="%s">%s</font>', hk, vU(hj))
        end
        vT = function(hn, ho, hp)
            return string.format("<b>%s</b> %s %s", hn, v0("-", "#5a6070"), v0(ho, hp))
        end
        local v5 = "#8b93a3"
        v2 = "#7fd47f"
        local v6 = "#6ec1ff"
        local v7 = {}
        v_ = "#e8a34d"
        local wd = if not qc() then 1 else 0
        if wd == 1 then
            table.insert(v7, "plot")
        end
        if not pS("Functions", "UpgradeRequest", "RemoteFunction") then
            table.insert(v7, "upgrades")
        end
        local wg = if not pS("Functions", "RebirthRequest", "RemoteFunction") then 1 else 0
        if wg == 1 then
            table.insert(v7, "rebirth")
        end
        if not pS("Functions", "LockBaseRequest", "RemoteFunction") then
            table.insert(v7, "base lock")
        end
        local v8 = not p6() or not qm() or not p1()
        if v8 then
            table.insert(v7, "game data")
        end
        local v9 = #v7 == 0 and "ready"
        local wg_1 = if v9 then 1 else 0
        local we = 1089 * wg_1 + 61 * (1 - wg_1)
        local wf = 1540 * wg_1 + 4082 * (1 - wg_1)
        if not ((we * 3174 + wf * 2902 + we * wf) % 16777213 == 9602626) then
            v9 = "limited: " .. table.concat(v7, ", ")
        end
        vY = "Unknown"
        local v7_1 = v9
        pcall(function()
            local vC_1
            local vB_1
            if pZ(identifyexecutor) then
                vC_1, vB_1 = identifyexecutor()
                local vD = vC_1 ~= ""
                local vE = type(vC_1) == "string" and vD
                if vE then
                    local vD_1 = type(vB_1) == "string" and vB_1 ~= "" and vC_1 .. " " .. vB_1
                    vY = vD_1 or vC_1
                end
            end
        end)
        v3 = os.clock()
        vZ = function()
            local vJ = math.floor(os.clock() - v3)
            if vJ < 60 then
                return vJ .. "s"
            elseif vJ < 3600 then
                return string.format("%dm %ds", math.floor((vJ) / (60)), vJ % 60)
            else
                return string.format("%dh %dm", math.floor((vJ) / (3600)), math.floor((vJ % 3600) / (60)))
            end
        end
        local UserGroup = zM.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(vT("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, v2), true)
        UserGroup:AddLabel(vT("UserId", tostring(LocalPlayer.UserId), v6), true)
        UserGroup:AddLabel(vT("Executor", vY .. "  " .. v7_1, v2), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(vT("Session", vZ(), v_), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                zP(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                zP("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = zM.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(vT("Game", zR, v6), true)
        Label2 = SessionGroup:AddLabel(vT("Players", "0/0", v2), true)
        vV = tostring(game.JobId)
        local v6_1 = #vV > 18 and string.sub(vV, 1, 18) .. "..."
        local v8_3 = v6_1 or vV
        SessionGroup:AddLabel(vT("Job", v8_3, v5), true)
        Label = SessionGroup:AddLabel(vT("Ping", "0 ms", v_), true)
        SessionGroup:AddDivider()
        SessionGroup:AddButton({
            Text = "Rejoin Place",
            Func = function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        })
        SessionGroup:AddButton({
            Text = "Copy Job ID",
            Func = function()
                zP(vV, "Copied Job ID")
            end
        })
        vX = task.spawn(function()
            local vP_1
            local vO_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(vT("Session", vZ(), v_))
                Label2:SetText(vT("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), v2))
                vO_1, vP_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local vO_2 = vO_1 and vP_1 .. " ms" or "n/a"
                Label:SetText(vT("Ping", vO_2, v_))
            end
        end)
        qg.Track(function()
            if coroutine.status(vX) ~= "dead" then
                task.cancel(vX)
            end
        end)
        local SocialsGroup = zM.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                zP(zS, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                zP(zW, "Copied website link")
            end
        })
    end
    zX_2()
    local function zX_3()
        local iN
        local iL
        local iM
        local iO
        local MovementGroup = zM.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = zM.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        iM = {}
        iN = {}
        iL = {}
        iO = {}
        local iK = {}
        local function iP()
            for k, v in iL do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(iL)
        end
        local function iT()
            for k, v in iM do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(iM)
        end
        local function iX()
            for k, v in iN do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(iN)
        end
        local function i0(i1)
            if not i1:IsA("ProximityPrompt") then
                return
            end
            if iO[i1] == nil then
                iO[i1] = {
                    HoldDuration = i1.HoldDuration,
                    MaxActivationDistance = i1.MaxActivationDistance,
                    RequiresLineOfSight = i1.RequiresLineOfSight
                }
            end
            i1.HoldDuration = 0
            i1.MaxActivationDistance = 50
            i1.RequiresLineOfSight = false
        end
        local function i3()
            for k, v in iO do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(iO)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                iX()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                iT()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                iP()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                    pcall(i0, v)
                end
            else
                i3()
            end
        end)
        table.insert(iK, Workspace.DescendantAdded:Connect(function(jm)
            if Toggles.InstantProximityPrompt.Value then
                i0(jm)
            end
        end))
        table.insert(iK, RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if iL[v] == nil then
                        iL[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(iK, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local xa = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and xa then
                xa:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(iK, RunService.RenderStepped:Connect(function(jI)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local xd = Character and Character:FindFirstChildOfClass("Humanoid")
            local xe = Character
            if xe then
                xe = Character:FindFirstChild("HumanoidRootPart")
            end
            local xc_1 = xe
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and xd then
                if iM[xd] == nil then
                    iM[xd] = xd.WalkSpeed
                end
                xd.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and xc_1 and xd and CurrentCamera then
                if iN[xd] == nil then
                    iN[xd] = xd.PlatformStand
                end
                xd.PlatformStand = true
                local xe_4 = Vector3.zero
                if not UserInputService:GetFocusedTextBox() then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        xe_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        xe_4 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        xe_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        xe_4 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        xe_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        xe_4 -= Vector3.new(0, 1, 0)
                    end
                end
                xc_1.AssemblyLinearVelocity = Vector3.zero
                if xe_4.Magnitude > 0 then
                    xc_1.CFrame = xc_1.CFrame + xe_4.Unit * Options.FlySpeed.Value * jI
                end
            end
        end))
        qg.Track(function()
            for k, v in iK do
                v:Disconnect()
            end
            iP()
            iT()
            iX()
            i3()
        end)
    end
    zX_3()
    local function zX_4()
        local yx, yy, yz, yA, yB, yC, yD, yE, yF, yG, Label, yI, yJ, yK
        yI = {}
        yC = {}
        yz = nil
        yK = 0
        yE = false
        yA = 0
        yF = os.clock()
        local MenuGroup = zM.Settings:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        yx = function()
            local CurrentCamera
            CurrentCamera = Workspace.CurrentCamera
            local xw = not CurrentCamera or not pZ(VirtualUser.CaptureController) or not pZ(VirtualUser.ClickButton2)
            if xw then
                return false
            end
            local xw_1 = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            end)
            if not xw_1 then
                return false
            end
            yA += 1
            yF = os.clock()
            pcall(function()
                Label:SetText("AFK triggers: " .. yA)
            end)
            return true
        end
        yG = function(kr)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not kr)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not kr
                end
            end)
            if not kr then
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
        yD = function(kI)
            local xF = kI.ClassName == "ParticleEmitter" or kI.ClassName == "Trail" or kI.ClassName == "Smoke" or kI.ClassName == "Fire" or kI.ClassName == "Sparkles"
            local xJ = if xF then 1 else 0
            local xH = 678 * xJ + 2808 * (1 - xJ)
            local xI = 326 * xJ + 3716 * (1 - xJ)
            if not ((xH * 1323 + xI * 217 + xH * xI) % 16777213 == 1188764) then
                xF = kI.ClassName == "Explosion"
            end
            if not xF then
                xF = kI.ClassName == "Beam"
            end
            if xF then
                if yI[kI] == nil then
                    yI[kI] = kI.Enabled
                end
                pcall(function()
                    kI.Enabled = false
                end)
            end
        end
        yB = function()
            for k, v in yI do
                local xO = k
                local xQ = v
                if xO.Parent then
                    pcall(function()
                        xO.Enabled = xQ
                    end)
                end
            end
            table.clear(yI)
            if yz then
                pcall(function()
                    settings().Rendering.QualityLevel = yz.Quality
                end)
                Lighting.GlobalShadows = yz.Shadows
                Lighting.FogEnd = yz.Fog
                yz = nil
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(kX)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not kX)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(k1)
                if k1 then
                    if not yz then
                        yz = {
                            Quality = settings().Rendering.QualityLevel,
                            Shadows = Lighting.GlobalShadows,
                            Fog = Lighting.FogEnd
                        }
                    end
                    pcall(function()
                        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                    end)
                    Lighting.GlobalShadows = false
                    Lighting.FogEnd = 9000000000
                    for k, v in Workspace:QueryDescendants("ParticleEmitter,Trail,Smoke,Fire,Sparkles,Beam") do
                        pcall(yD, v)
                    end
                else
                    yB()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        yG(true)
        local ScriptGroup = zM.Settings:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiGameplayPause:OnChanged(function()
            yG(Toggles.AntiGameplayPause.Value)
        end)
        if Toggles.AntiGameplayPause.Value then
            yG(true)
        end
        table.insert(yC, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                yx()
            end
        end))
        table.insert(yC, Workspace.DescendantAdded:Connect(function(lk)
            if Toggles.FpsBoost.Value then
                yD(lk)
            end
        end))
        yy = function(lo)
            local x9 = yE
            local ye = if x9 then 1 else 0
            local yc = 2119 * ye + 2044 * (1 - ye)
            local yd = 1968 * ye + 2150 * (1 - ye)
            if not ((yc * 3548 + yd * 1942 + yc * yd) % 16777213 == 15510260) then
                x9 = Library.Unloaded
            end
            if not x9 then
                x9 = not Toggles.AutoReconnect.Value
            end
            if x9 then
                return
            end
            yE = true
            local x8 = yK
            local x9_1 = pcall(function()
                if lo then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not x9_1 then
                yE = false
                if not lo and x8 == yK then
                    task.delay(1.5, function()
                        if x8 == yK then
                            yy(true)
                        end
                    end)
                end
            end
        end
        table.insert(yC, TeleportService.TeleportInitFailed:Connect(function(lG)
            local yg
            if lG == LocalPlayer and yE then
                yE = false
                yg = yK
                task.delay(3, function()
                    if yg == yK then
                        yy(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local yl = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            if Library.Unloaded or not yl then
                return
            end
            table.insert(yC, yl.ChildAdded:Connect(function(lV)
                if lV.Name == "ErrorPrompt" then
                    yy(false)
                end
            end))
        end)
        yJ = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    yG(true)
                end
                local yo = Toggles.AntiAfk.Value and os.clock() - yF >= 60
                if yo then
                    yx()
                end
                task.wait(1)
            end
        end)
        qg.Track(function()
            yK += 1
            for k, v in yC do
                v:Disconnect()
            end
            pcall(task.cancel, yJ)
            yG(false)
            yB()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    zX_4()
    local function zX_5()
        local zF, zG, zH, zI
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("TempoHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(zM.Settings)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/MergeADino")
        local zJ = SaveManager:BuildConfigSection(zM.Settings)
        zI = function(ml, mm)
            local yO_1 = (ml == "Toggle" and Toggles or Options)[mm]
            local yN_2 = type(yO_1) == "table" and yO_1.Type == ml
            return yN_2 and yO_1 or nil
        end
        zG = function(mv, mw)
            local Type = mw.Type
            if Type == "Toggle" then
                return { idx = mv, type = "Toggle", value = mw.Value == true }
            elseif Type == "Slider" then
                return { idx = mv, type = "Slider", value = tostring(mw.Value) }
            elseif Type == "Dropdown" then
                return { idx = mv, type = "Dropdown", multi = mw.Multi == true, value = mw.Value }
            elseif Type == "Input" then
                local yV = mw.Value or ""
                return { idx = mv, type = "Input", text = tostring(yV) }
            elseif Type == "ColorPicker" then
                return { idx = mv, type = "ColorPicker", value = mw.Value:ToHex(), transparency = mw.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = mv,
                    type = "KeyPicker",
                    mode = mw.Mode,
                    key = mw.Value,
                    modifiers = mw.Modifiers,
                    toggled = mw.Toggled
                }
            else
                return nil
            end
        end
        zF = function()
            local y0 = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local y1 = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if y1 then
                        local y1_1 = zG(k, v)
                        if y1_1 then
                            y0[#y0 + 1] = y1_1
                        end
                    end
                end
            end
            table.sort(y0, function(mG, mH)
                if mG.type ~= mH.type then
                    return mG.type < mH.type
                end
                return mG.idx < mH.idx
            end)
            return { objects = y0 }
        end
        zH = function(mJ)
            local zh
            zh = nil
            local zi = type(mJ) ~= "table" or type(mJ.idx) ~= "string" or type(mJ.type) ~= "string" or SaveManager.Ignore[mJ.idx]
            if zi then
                return false
            end
            zh = zI(mJ.type, mJ.idx)
            if not zh then
                return false
            end
            local zi_1 = pcall(function()
                if mJ.type == "Input" then
                    if type(mJ.text) ~= "string" then
                        return
                    end
                    zh:SetValue(mJ.text)
                elseif mJ.type == "ColorPicker" then
                    zh:SetValueRGB(Color3.fromHex(mJ.value), mJ.transparency)
                elseif mJ.type == "KeyPicker" then
                    zh:SetValue({ mJ.key, mJ.mode, mJ.modifiers })
                    if mJ.mode == "Toggle" and mJ.toggled ~= nil then
                        zh.Toggled = mJ.toggled
                        zh:Update()
                    end
                else
                    zh:SetValue(mJ.value)
                end
            end)
            return zi_1
        end
        zJ:AddDivider()
        zJ:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        zJ:AddButton("Export Config to Clipboard", function()
            local zl_1
            local zk_1
            zk_1, zl_1 = pcall(HttpService.JSONEncode, HttpService, zF())
            if zk_1 then
                local zk_2 = pZ(setclipboard) and setclipboard
                local zm = zk_2
                if not zm then
                    local zk_3 = pZ(toclipboard) and toclipboard
                    zm = zk_3 or nil
                end
                local zk_4 = zm
                local zm_1 = type(zk_4) == "function" and pcall(zk_4, zl_1)
                if zm_1 then
                    Library:Notify("Config copied to clipboard", 6)
                    return
                end
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Failed to encode the config")
        end)
        zJ:AddButton("Import Config from Clipboard Text", function()
            local zu_1
            local zs = Options.SaveManager_ImportSource.Value or ""
            local zs_1
            local zt = tostring(zs):match("^%s*(.-)%s*$")
            if zt == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            if #zt > 262144 then
                Library:Notify("That config is too large")
                return
            end
            zs_1, zu_1 = pcall(HttpService.JSONDecode, HttpService, zt)
            local zt_1 = not zs_1 or type(zu_1) ~= "table" or type(zu_1.objects) ~= "table"
            if zt_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            if #zu_1.objects > 2048 then
                Library:Notify("That config has too many records")
                return
            end
            local zs_2 = 0
            for i, v in ipairs(zu_1.objects) do
                if zH(v) then
                    zs_2 += 1
                end
            end
            if zs_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local zu_2 = zs_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(zs_2, zu_2), 6)
        end)
        ThemeManager:LoadDefault()
        SaveManager:LoadAutoloadConfig()
        if Options.MergeInterval then
            pD.interval = Options.MergeInterval.Value
        end
        if Toggles.MergeRestore then
            pD.SetRestore(Toggles.MergeRestore.Value)
        end
        if Options.UpgradeTargets then
            qt.SetTargets(Options.UpgradeTargets.Value)
        end
        if Toggles.AutoMerge then
            pD.SetEnabled(Toggles.AutoMerge.Value)
        end
        if Toggles.AutoRebirth then
            qy.SetEnabled(Toggles.AutoRebirth.Value)
        end
        if Toggles.AutoUpgrades then
            qt.SetEnabled(Toggles.AutoUpgrades.Value)
        end
        if Toggles.AutoLock then
            qp.SetEnabled(Toggles.AutoLock.Value)
        end
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    zX_5()
end
qH()
end)(...)

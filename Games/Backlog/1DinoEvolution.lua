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
getgenv().TempoHoodSubtitle = "+1 DINO EVOLUTION"
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
local sm
local r3
local ss
local r9
local Workspace
local sy
local sf
local sX
local rX
local State
local sl
local r2
local sK
local r8
local sx
local se
local rW
local sD
local sk
local s1
local r1
local sq
local r7
local sP
local sw
local sd
local sV
local sC
local sj
local s0
local r0
local sI
local r6
local sO
local sU
local sB
local si
local r_
local so
local r5
local sN
local su
local sb
local sA
local sh
local sZ
local rZ
local sG
local sn
local r4
local LocalPlayer
local st
local sa
local sS
local sz
local sg
local sY
local rY
local function fn41(O)
    return type(O) == "function"
end
local function fn69()
    local uU = tonumber(sX.TAPS_PER_SECOND) or 4
    local uU_1 = tonumber(sX.BURST_ALLOWANCE) or 3
    local uU_2 = os.clock()
    State.TapTokens = math.min(uU + uU_1, State.TapTokens + (uU_2 - State.LastTap) * uU)
    State.LastTap = uU_2
    if State.TapTokens < 1 then
        return false
    end
    State.TapTokens = State.TapTokens - 1
    r6.Tap:FireServer()
    return true
end
local function worker6()
    while not sD.Unloaded do
        if State.Enabled.BestPets then
            pcall(function()
                r6.RequestPetAction:InvokeServer("EquipBest", nil)
            end)
        end
        if State.Enabled.BestItems then
            pcall(function()
                r6.RequestItemAction:InvokeServer("EquipBest", nil)
            end)
        end
        if State.Enabled.BestPets or State.Enabled.BestItems then
            task.wait(2)
        else
            task.wait(0.5)
        end
    end
end
local function fn76()
    local xa = r5()
    local max = math.max
    local floor = math.floor
    local xd = (tonumber(xa.Wins))
    local xn = if xd then 1 else 0
    local xl = 3819 * xn + 627 * (1 - xn)
    local xm = 449 * xn + 1386 * (1 - xn)
    if not ((xl * 2098 + xm * 875 + xl * xm) % 16777213 == 10119868) then
        xd = 0
    end
    local xe = max(0, floor(xd))
    local xb_1 = type(xa.OwnedAuras) == "table" and xa.OwnedAuras
    local xd_1 = xb_1 or {}
    local EquippedAura = xa.EquippedAura
    local Id2 = nil
    local xa_1 = -1
    local Id
    local xg = -1
    for k, v in sP.GetOrdered() do
        local xh = type(v) == "table" and v.Hidden ~= true and type(v.Id) == "string"
        if xh then
            local xh_1 = tonumber(v.Cost) or 0
            local xh_2 = tonumber(v.Multiplier) or 1
            if xd_1[v.Id] == true then
                if xh_2 > xa_1 then
                    xa_1 = xh_2
                    Id2 = v.Id
                end
            else
                if xh_1 > 0 and xe >= xh_1 and xh_2 > xg then
                    xg = xh_2
                    Id = v.Id
                end
            end
        end
    end
    if Id then
        return Id
    end
    if Id2 and Id2 ~= EquippedAura then
        return Id2
    end
end
local function fn91(c0)
    local vw = c0:FindFirstChild("HumanoidRootPart") or c0.PrimaryPart or sf(c0)
    return vw
end
local function fn127()
    return State.Enabled.Farm == true and not sD.Unloaded
end
local function fn153()
    local wT = r5()
    local max = math.max
    local floor = math.floor
    local wW = tonumber(wT.Wins) or 0
    local wX = max(0, floor(wW))
    local wU_1 = type(wT.OwnedDinos) == "table" and wT.OwnedDinos
    local wW_1 = wU_1 or {}
    local Dino = wT.Dino
    local Name2 = nil
    local wT_1 = -1
    local Name
    for k, v in r7() do
        if wW_1[v.Name] == true then
            if v.Gain > wT_1 then
                wT_1 = v.Gain
                Name2 = v.Name
            end
        else
            local wZ = not Name
            if wZ ~= false then
                wZ = v.Cost <= wX
            end
            if wZ then
                Name = v.Name
            end
        end
    end
    if Name then
        return Name
    end
    if Name2 and Name2 ~= Dino then
        return Name2
    end
end
local function fn186(c4)
    local vy = os.clock()
    local vz = false
    sq(c4)
    while true do
        local vA = not sD.Unloaded and sG() and os.clock() - vy < 45
        if not vA then
            local vA_1 = vz and sI(c4) and #r0(c4) == 0
            return vA_1
        end
        sq(c4)
        local vA_2 = r0(c4)
        if #vA_2 > 0 then
            vz = true
            for k, v in vA_2 do
                local vA_3 = sD.Unloaded or not sG()
                if vA_3 then
                    return false
                end
                local vA_4 = sY(v)
                if vA_4 then
                    r2(vA_4)
                end
                sN()
            end
            task.wait(0.12)
            continue
        end
        local vA_5 = vz and sI(c4)
        if vA_5 then
            break
        end
        sw(c4)
        local vA_6 = not vz
        local vB = os.clock() - vy > 10 and vA_6
        if vB then
            return false
        end
        sN()
        task.wait(0.2)
    end
    return true
end
local function fn189(ht)
    if sC[ht] then
        State.EggLabel = ht
    end
end
local function fn207(cP)
    local vs = r9(cP)
    local vt = vs and vs.Model
    if not vt then
        return
    end
    local vt_1 = sS.Owns(LocalPlayer, sS.WINS_KEY) and "WinPadRobux"
    local vu = vt_1 or "WinPad"
    local vu_1 = vt:FindFirstChild(vu) or vt:FindFirstChild("WinPad") or vt:FindFirstChild("WinPadRobux")
    return vu_1, sf(vu_1)
end
local function fn208(dq)
    local vM = not sI(dq) or #r0(dq) > 0
    if vM then
        return false
    end
    local vM_1 = r5()
    local max2 = math.max
    local floor2 = math.floor
    local vO_4
    local vP = tonumber(vM_1.Wins) or 0
    local vP_2
    local vM_2 = max2(0, floor2(vP))
    local vN_1 = os.clock() + 6
    while true do
        local vO_1 = not sD.Unloaded and sG() and os.clock() < vN_1
        if not vO_1 then
            local max = math.max
            local floor = math.floor
            local vP_1 = tonumber(r5().Wins) or 0
            return max(0, floor(vP_1)) > vM_2
        end
        local vO_3 = not sI(dq) or #r0(dq) > 0
        if vO_3 then
            return false
        end
        vO_4, vP_2 = sl(dq)
        if vP_2 then
            r2(vP_2)
        end
        local max = math.max
        local floor = math.floor
        local vQ = tonumber(r5().Wins) or 0
        local vR = max(0, floor(vQ))
        if vR > vM_2 then
            break
        end
        task.wait(0.2)
    end
    return true
end
local function fn249()
    local Character = LocalPlayer.Character
    local uh = Character and Character:FindFirstChildOfClass("Humanoid")
    local ui = Character
    if ui then
        ui = Character:FindFirstChild("HumanoidRootPart")
    end
    local uh_1 = Character
    local uk = ui
    if uh_1 then
        uh_1 = uh
    end
    if uh_1 then
        uh_1 = uk
    end
    if uh_1 then
        uh_1 = uh.Health > 0
    end
    if uh_1 then
        return Character, uh, uk
    end
end
local function fn255(aP, aQ)
    if aP.Order ~= aQ.Order then
        return aP.Order < aQ.Order
    end
    return aP.Name < aQ.Name
end
local function fn298(b4)
    return s0.CheckpointByStage(b4)
end
local function fn349(cx)
    local vg = {}
    local Enemies = Workspace:FindFirstChild("Enemies")
    if not Enemies then
        return vg
    end
    for i, child in Enemies:GetChildren() do
        local vh_1 = child:IsA("Model") and child:GetAttribute("Owner") == LocalPlayer.UserId and child:GetAttribute("Zone") == cx and child:GetAttribute("State") ~= "Dead"
        if vh_1 then
            table.insert(vg, child)
        end
    end
    return vg
end
local function fn378(bZ)
    local u0 = os.clock()
    if State.LastFightTarget == bZ and u0 - State.LastFightAt < 0.5 then
        return
    end
    State.LastFightTarget = bZ
    State.LastFightAt = u0
    r6.AutoFightTarget:FireServer(bZ)
end
local function fn380()
    local wk = {}
    for k, v in rY.Dinos do
        local wl = type(k) == "string" and type(v) == "table" and v.Cost ~= nil and v.Product == nil
        if wl then
            local insert = table.insert
            local wm = tonumber(v.Order) or 999
            insert(wk, { Name = k, Order = wm, Gain = sn(k, r5()), Cost = sd(k) })
        end
    end
    table.sort(wk, function(eQ, eR)
        if eQ.Gain ~= eR.Gain then
            return eQ.Gain > eR.Gain
        end
        return eQ.Order > eR.Order
    end)
    return wk
end
local function fn390(cr)
    local ve = sO(cr)
    if ve then
        sV(ve)
        sz(ve)
    end
end
local function fn399(eF)
    local wh = tonumber(sX.GetDinoCost(eF)) or 0
    return wh
end
local function fn406()
    return { Stages = sx, Train = rZ, Eggs = sy, HatchAmounts = r8 }
end
local function fn409(d8)
    if not d8 then
        return
    end
    local v4 = r_(d8.Name)
    if not v4 then
        return
    end
    local PracticeDummy = v4:FindFirstChild("PracticeDummy")
    if PracticeDummy then
        local v6 = (sf(PracticeDummy))
        local wa = if v6 then 1 else 0
        local v8 = 55 * wa + 164 * (1 - wa)
        local v9 = 2457 * wa + 684 * (1 - wa)
        if not ((v8 * 2925 + v9 * 2017 + v8 * v9) % 16777213 == 5251779) then
            v6 = sf(v4)
        end
        return v6
    end
    return sf(v4)
end
local function fn421(eT)
    local wv_1
    local wu_1
    wu_1, wv_1 = pcall(s0.Containers, "Stands")
    local ww = not wu_1 or type(wv_1) ~= "table"
    if ww then
        return
    end
    for k, v in wv_1 do
        if typeof(v) == "Instance" then
            for i, child in v:GetChildren() do
                if child:GetAttribute("Dino") == eT then
                    local Pad = child:FindFirstChild("Pad")
                    local wv_2 = Pad and Pad:IsA("BasePart")
                    if wv_2 then
                        return Pad, Pad:FindFirstChildWhichIsA("ProximityPrompt")
                    end
                end
            end
        end
    end
end
local function fn432(hj)
    local yi = su[hj] or tonumber(string.match(tostring(hj), "%d+"))
    local yj = yi
    if yi then
        yi = yj >= 1
    end
    if yi then
        yi = yj <= sB
    end
    if yi then
        State.Stage = yj
    end
end
local function worker()
    while not sD.Unloaded do
        local vX = State.Enabled.Click or sG()
        if vX then
            sN()
            task.wait(0.08)
        else
            task.wait(0.2)
        end
    end
end
local function fn477()
    local ue = r4.get()
    if type(ue) == "table" then
        return ue
    end
    return {}
end
local function fn479()
    for k, v in { st, ss, so, sm, sk, sh, se, sa } do
        pcall(task.cancel, v)
    end
end
local function fn482(bE)
    if not bE then
        return nil
    elseif bE:IsA("BasePart") then
        return bE
    else
        local uN = bE:FindFirstChild("TouchPart") or bE:FindFirstChild("Touch") or bE:FindFirstChild("HitPart") or bE:FindFirstChild("Pad")
        local uO = uN
        if uN then
            uN = uO:IsA("BasePart")
        end
        if uN then
            return uO
        end
        return bE:FindFirstChildWhichIsA("BasePart", true)
    end
end
local function fn487(dX)
    local TrainingArea = Workspace:FindFirstChild("TrainingArea")
    local v1 = TrainingArea and TrainingArea:FindFirstChild(dX)
    if v1 then
        return v1
    end
    local World2 = Workspace:FindFirstChild("World2")
    local v1_1 = World2
    if v1_1 then
        local v2 = World2:FindFirstChild("TrainingAreas") or World2:FindFirstChild("TrainingArea")
        v1_1 = v2
    end
    local v0_3 = v1_1
    if v1_1 then
        v1_1 = v0_3:FindFirstChild(dX)
    end
    return v1_1
end
local function fn505(eB, eC)
    local wf = tonumber(sX.GetDinoGain(eB, eC)) or 0
    return wf
end
local function fn521(hw)
    local yq = tonumber(hw)
    if yq and yq >= 1 then
        State.HatchAmount = math.floor(yq)
    end
end
local function fn562()
    while not sD.Unloaded do
        local wb = State.Enabled.Train and not sG()
        if wb then
            local wb_1 = r1[State.TrainLabel]
            if si(wb_1) then
                local wc_1 = sA(wb_1)
                if wc_1 then
                    r2(wc_1)
                    sN()
                end
            end
            local wait = task.wait
            local wc_2 = sX.TRAINING_INTERVAL or 0.3
            wait(wc_2)
        else
            task.wait(0.3)
        end
    end
end
local function fn572(cl)
    local vc = r3(cl)
    if not vc then
        return false
    end
    sV(vc)
    return sz(vc)
end
local function worker3()
    while not sD.Unloaded do
        if State.Enabled.Rebirth then
            if sX.CanRebirth(r5(), sU.LevelScale(LocalPlayer)) then
                pcall(function()
                    r6.RequestRebirth:InvokeServer()
                end)
                task.wait(1.4)
            else
                task.wait(0.5)
            end
        else
            task.wait(0.4)
        end
    end
end
local function fn639(gc)
    local xN_1
    local xJ_1
    local xL_1, xL_2
    local xK_1, xK_3
    xJ_1, xK_1, xL_1 = rX()
    local xK_2 = xL_1 and xL_1.Position or Vector3.zero
    xK_3, xL_2 = pcall(s0.Containers, "Eggs")
    local xM = not xK_3 or type(xL_2) ~= "table"
    if xM then
        return
    end
    local xK_4 = nil
    local xM_1 = math.huge
    for k, v in xL_2 do
        if typeof(v) == "Instance" then
            local xL_3 = v:FindFirstChild(gc)
            local xO = xL_3 and xL_3:IsA("BasePart")
            local BasePart
            if xO then
                xN_1 = xL_3
            else
                if xL_3 then
                    BasePart = xL_3:FindFirstChildWhichIsA("BasePart", true)
                else
                    BasePart = nil
                end
                xN_1 = BasePart
            end
            local xL_4 = xN_1
            if xL_4 then
                local Magnitude = (xL_4.Position - xK_2).Magnitude
                if Magnitude < xM_1 then
                    xM_1 = Magnitude
                    xK_4 = xL_4
                end
            end
        end
    end
    return xK_4
end
local function fn655(cg)
    local va = rW.GetPreviousGate(cg)
    if va then
        return Vector3.new(va.X, va.Y + 4, va.Z)
    end
    return r3(cg)
end
local function fn681(aC, aD)
    if aC.Order ~= aD.Order then
        return aC.Order < aD.Order
    end
    return aC.Name < aD.Name
end
local function worker2()
    while not sD.Unloaded do
        if not sG() then
            if State.LastFightTarget ~= nil then
                sq(nil)
            end
            task.wait(0.3)
            continue
        end
        local vT = State.Stage
        if vT < 1 then
            vT = 1
        end
        if vT > sB then
            vT = sB
        end
        sw(vT)
        local vU = sD.Unloaded or not sG()
        if vU then
            continue
        end
        local vU_1 = sK(vT)
        local vV = sD.Unloaded or not sG()
        if vV then
            continue
        end
        if vU_1 then
            sZ(vT)
        end
        local vU_2 = sD.Unloaded or not sG()
        if vU_2 then
            continue
        end
        sg(vT)
        task.wait(0.45)
    end
end
local function fn712(a9)
    local uu = {}
    if type(a9) == "table" then
        for k, v in a9 do
            local uv = tonumber(v)
            if uv then
                uu[uv] = true
            end
        end
    end
    return uu
end
local function fn771(hq)
    if r1[hq] then
        State.TrainLabel = hq
    end
end
local function fn807(cG)
    if State.Opened[cG] == true or State.Cleared[cG] == true then
        return true
    end
    local vp_1 = r9(cG)
    local vq = vp_1 and vp_1.Block
    local vp_2 = vq
    if vq then
        vq = vp_2:IsA("BasePart")
    end
    if vq then
        vq = vp_2.CanCollide == false
    end
    if vq then
        return true
    end
    return false
end
local function fn853(hf, hg)
    State.Enabled[hf] = hg == true
    if hf == "Farm" and hg ~= true then
        sq(nil)
    end
end
local function fn895(b7)
    local u3 = rW.GetPreviousGate(b7)
    local u4 = rW.GetGatePosition(b7)
    if u3 and u4 then
        local u5_1 = u3:Lerp(u4, 0.5)
        return Vector3.new(u5_1.X, u5_1.Y + 4, u5_1.Z)
    end
    local u3_1 = r9(b7)
    if u3_1 and u3_1.Position then
        return Vector3.new(u3_1.Position.X, u3_1.Position.Y - 10, u3_1.Position.Z)
    end
end
local function fn907()
    while not sD.Unloaded do
        local w6 = State.Enabled.BuyDino and not sG()
        if w6 then
            local w6_1 = s1()
            if w6_1 then
                sb(w6_1)
                task.wait(0.8)
            else
                task.wait(0.8)
            end
        else
            task.wait(0.4)
        end
    end
end
local function fn909(dQ)
    if not dQ then
        return false
    end
    local vZ = false
    if type(dQ.Pass) == "string" then
        vZ = sS.Owns(LocalPlayer, dQ.Pass) == true
    end
    return sX.CanUseTraining(r5(), dQ.Name, vZ) == true
end
local function fn1014(L)
    local ua = typeof(cloneref) == "function" and typeof(L) == "Instance"
    if ua then
        return cloneref(L)
    end
    return L
end
local function fn1031(bJ)
    local uS_1
    local uR_1
    local uQ_1
    uR_1, uQ_1, uS_1 = rX()
    local uQ_2 = uS_1 and bJ and bJ:IsA("BasePart")
    if not uQ_2 then
        return false
    end
    sz(bJ.Position + Vector3.new(0, 3, 0))
    if sj then
        pcall(sj, bJ, uS_1, 1)
        pcall(sj, bJ, uS_1, 0)
    end
    return true
end
local function fn1039(bx)
    local uL_1
    local uK_1
    local uJ_1
    uJ_1, uL_1, uK_1 = rX()
    local uJ_2 = uK_1 and typeof(bx) == "Vector3"
    if not uJ_2 then
        return false
    end
    uK_1.CFrame = CFrame.new(bx)
    uK_1.AssemblyLinearVelocity = Vector3.zero
    if uL_1 then
        uL_1:ChangeState(Enum.HumanoidStateType.Running)
    end
    return true
end
local function fn1071(f5)
    local xy = type(f5.OwnedPets) == "table" and f5.OwnedPets
    local xA = xy or {}
    local xy_1 = 0
    for k, v in xA do
        local max = math.max
        local floor = math.floor
        local xB = tonumber(v) or 0
        xy_1 += max(0, floor(xB))
    end
    return xy_1
end
rW = nil
rX = nil
rY = nil
rZ = nil
r_ = nil
r0 = nil
r1 = nil
r2 = nil
r3 = nil
r4 = nil
r5 = nil
r6 = nil
r7 = nil
r8 = nil
r9 = nil
sa = nil
sb = nil
sd = nil
se = nil
sf = nil
sg = nil
sh = nil
si = nil
sj = nil
sk = nil
sl = nil
sm = nil
sn = nil
so = nil
sq = nil
ss = nil
st = nil
su = nil
sw = nil
sx = nil
sy = nil
sz = nil
sA = nil
sB = nil
sC = nil
sD = nil
State = nil
sG = nil
local Players, sc, sp, sr, sv, sF, sH
sI = nil
sK = nil
LocalPlayer = nil
sN = nil
sO = nil
sP = nil
Workspace = nil
sS = nil
sU = nil
sV = nil
sX = nil
sY = nil
sZ = nil
s0 = nil
s1 = nil
local sJ, sL, sQ, HttpService, RunService, s_
local s5_1, s5_5
Players, RunService, HttpService, Workspace, LocalPlayer, sD, s5_1, s_, sr = nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local s7 = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
HttpService = game:GetService("HttpService")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local function s3(k)
    local t3
    local t1
    local t2
    t1 = nil
    t2 = nil
    t3 = nil
    local t4 = k ~= ""
    local t5 = type(k) == "string" and t4
    assert(t5, "A namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    t1 = getgenv()
    assert(type(t1) == "table", "getgenv did not return a table")
    local t4_1 = t1[k]
    if t4_1 ~= nil then
        local t5_1 = type(t4_1) == "table" and type(t4_1.Unload) == "function"
        assert(t5_1, "Namespace is occupied")
        t4_1.Unload()
        assert(t1[k] == nil, "Previous instance did not release its namespace")
    end
    t2 = {}
    t3 = { State = {}, Unloaded = false }
    t3.Track = function(q)
        assert(type(q) == "function", "Cleanup must be callable")
        if t3.Unloaded then
            q()
        else
            table.insert(t2, q)
        end
        return q
    end
    t3.Unload = function()
        local tS_1
        local tR_1
        if t3.Unloaded then
            return
        end
        t3.Unloaded = true
        local tP = {}
        local tZ = #t2
        local tY = -1
        while false and tZ <= 1 or true and tZ >= 1 do
            local t_ = tZ
            local tQ_1 = table.remove(t2, t_)
            tR_1, tS_1 = pcall(tQ_1)
            if not tR_1 then
                table.insert(tP, tostring(tS_1))
            end
            tZ += tY
        end
        table.clear(t3.State)
        if #tP > 0 then
            error("Cleanup incomplete: " .. table.concat(tP, "; "), 0)
        end
        if t1[k] == t3 then
            t1[k] = nil
        end
    end
    t1[k] = t3
    return t3
end
s_ = function(D, E)
    local t8 = type(D) == "table" and type(D.Track) == "function"
    assert(t8, "FeatureAPI required")
    local t8_1 = type(E) == "table" and type(E.OnUnload) == "function"
    assert(t8_1, "UI library required")
    assert(type(E.Unload) == "function", "UI unload required")
    D.Track(function()
        if not E.Unloaded then
            E:Unload()
        end
    end)
    E:OnUnload(function()
        D.Unload()
    end)
end
sD = s3("TempoDinoEvolution")
local s6 = fn1014
sr = fn41
if ((not LocalPlayer or s7) and (not s7 and LocalPlayer) or (LocalPlayer and s7)) and ((s7 or not LocalPlayer and 7) and 7) or not (((not LocalPlayer or s7) and (not s7 and LocalPlayer) or (LocalPlayer and s7)) and ((s7 or not LocalPlayer and 7) and 7)) then
    s5_1 = (sr(firetouchinterest))
else
    sr = (s5_1(firetouchinterest))
end
if s5_1 then
    s5_1 = firetouchinterest
end
local s2 = s5_1
local tk = if s2 then 1 else 0
local ti = 3252 * tk + 2046 * (1 - tk)
local tj = 3172 * tk + 3201 * (1 - tk)
if not ((ti * 1702 + tj * 364 + ti * tj) % 16777213 == 227643) then
    s2 = nil
end
sj = nil
sj = s2
local worker4 = sr(fireproximityprompt) and fireproximityprompt
local s2_1 = worker4 or nil
sc, r6, r4, rY, rW, s0, sX, sU, sS, sP, sH, sF, State = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
sc = s2_1
local s5_2 = s6(s7)
worker4 = s6(s5_2:WaitForChild("Events"))
r6 = require(s6(worker4:WaitForChild("Remotes")))
r4 = require(s6(s5_2:WaitForChild("Client"):WaitForChild("PlayerData")))
local s3_1 = s6(s5_2:WaitForChild("DataModules"))
rY = require(s6(s3_1:WaitForChild("DinoConfig")))
local worker5 = require(s6(s3_1:WaitForChild("StageConfig")))
rW = require(s6(s3_1:WaitForChild("LevelConfig")))
s0 = require(s6(s3_1:WaitForChild("WorldConfig")))
sX = require(s6(s3_1:WaitForChild("DamageProgression")))
sU = require(s6(s3_1:WaitForChild("ConfigFlags")))
sS = require(s6(s3_1:WaitForChild("GamePassConfig")))
sP = require(s6(s3_1:WaitForChild("Auras")))
sH = require(s6(s3_1:WaitForChild("PetConfig")))
sF = require(s6(s5_2:WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("EggShowcase")))
State = sD.State
State.Enabled = {
    Click = false,
    Farm = false,
    Rebirth = false,
    Train = false,
    BuyDino = false,
    BuyAura = false,
    Hatch = false,
    BestPets = false,
    BestItems = false
}
State.Stage = 1
State.TrainLabel = nil
State.EggLabel = nil
State.HatchAmount = 1
State.LastStream = 0
local s2_2 = sX.TAPS_PER_SECOND or 4
local s3_2 = 0
repeat
    worker4 = {
        "itpor",
        "sbkegrweqw",
        "aoxpqc",
        "opvognxvncx",
        "cewcju",
        "lyuaetsi",
        "kuz",
        "chlsacono",
        "wgvnxmz",
        "jftfvv",
        "hqxtgkene",
        "bsyqt",
        "kgimzudm",
        "jwirbv",
        "qbnxfwjhjuh",
        "zbcpykieink"
    }
    if worker4[(s3_2 * 76 + 68) % 16 + 1] <= worker4[(s3_2 * 76 + 68) % 16 + 1] then
        State.TapTokens = s2_2
        State.LastTap = os.clock()
        State.LastFightTarget = nil
        State.LastFightAt = 0
        State.Opened = {}
        State.Cleared = {}
    else
        State.TapTokens = State
        s2_2.LastTap = os.clock()
        s2_2.LastFightTarget = nil
        s2_2.LastFightAt = 0
        s2_2.Opened = {}
        s2_2.Cleared = {}
    end
    s3_2 = (s3_2 + 1) % 8
until (s3_2 * 5 + 6) % 8 == 3
local s2_3 = tonumber(s0.LastStage()) or 1
sB, sx, su = nil, nil, nil
local s3_3 = 4
repeat
    worker4 = (vector.create((s3_3 * 2 + 9) % 11 + 1, (s3_3 * 9 + 11) % 13 + 1, (s3_3 * 2 + 11) % 17 + 1))
    local s5_3 = (vector.create((s3_3 * 1 + 5) % 11 + 1, (s3_3 * 7 + 7) % 13 + 1, (s3_3 * 1 + 12) % 17 + 1))
    local Di = vector.dot(worker4, s5_3)
    if Di * Di >= vector.dot(worker4, worker4) * vector.dot(s5_3, s5_3) + 1 then
        sx = su
        sB = {}
        s2_3 = {}
    else
        sB = s2_3
        sx = {}
        su = {}
    end
    s3_3 = (s3_3 + 3) % 8
until (s3_3 * 1 + 2) % 8 == 1
worker4 = {}
for k, v in worker5.Stages do
    local s2_4 = type(v) == "table" and type(v.Stage) == "number"
    if s2_4 then
        worker4[v.Stage] = v.Theme
    end
end
local tt = 1
local tr = sB
while tt <= tr do
    local tu = tt
    local s2_5 = worker4[tu]
    local s3_4 = s2_5 and tostring(tu) .. " " .. tostring(s2_5)
    local s2_6 = s3_4 or "Stage " .. tostring(tu)
    table.insert(sx, s2_6)
    su[s2_6] = tu
    tt += 1
end
r1, rZ = nil, nil
local s2_7 = 3
repeat
    local s3_6 = {
        "gljnopx",
        "duxrujdclbb",
        "milsbccii",
        "joia",
        "ohptvalr",
        "hejofpyx",
        "lrka",
        "kxstguhwiat",
        "hyegemaveyj"
    }
    local EN = s2_7
    worker4 = s3_6[EN % 9 + 1]
    if worker4:len() >= worker4:reverse():rep(EN % 3 + 2):len() then
        rZ = {}
        s5_5 = {}
        r1 = {}
    else
        s5_5 = {}
        r1 = {}
        rZ = {}
    end
    s2_7 = (s2_7 + 0) % 4
until (s2_7 * 3 + 0) % 4 == 1
local s3_7 = {}
for k, v in sX.TRAINING_AREAS do
    local s2_8 = type(k) == "string" and type(v) == "table"
    worker4 = k ~= "Admin"
    s6 = s2_8 and worker4
    if s6 then
        local insert = table.insert
        worker4 = tonumber(v.Order) or 999
        s6 = tonumber(v.Multiplier) or 1
        s7 = tonumber(v.Rebirths) or 0
        insert(s3_7, { Name = k, Order = worker4, Multiplier = s6, Rebirths = s7, Product = v.Product, Pass = v.Pass })
    end
end
table.sort(s3_7, fn681)
for k, v in s3_7 do
    local s2_10 = v.Name .. " x" .. tostring(v.Multiplier)
    v.Label = s2_10
    table.insert(s5_5, v)
    r1[s2_10] = v
    table.insert(rZ, s2_10)
end
local s3_8 = 0
repeat
    local s2_11 = {
        "sjqyfjvymqte",
        "drsmzoyvq",
        "lacdolz",
        "pktqorhaee",
        "pwdfi",
        "yrermyfpb",
        "ofngpdpeefu",
        "axie",
        "zlamuw"
    }
    if s2_11[(s3_8 * 25 + 31) % 9 + 1] < s2_11[(s3_8 * 25 + 31) % 9 + 1] then
        rZ.TrainLabel = State[1]
    else
        State.TrainLabel = rZ[1]
    end
    s3_8 = (s3_8 + 3) % 4
until (s3_8 * 1 + 3) % 4 == 2
worker4, sC, sy = nil, nil, nil
local s2_12 = 5
repeat
    if (s2_12 * 1 + 0) % 2 + 1 <= 1 then
        local s3_10 = {
            "jqxzw",
            "wjxmzafnxp",
            "dxsyxymnizuw",
            "vfmmevxy",
            "smw",
            "qhhb",
            "gjxvcahof",
            "lnfk",
            "umnuizf",
            "llub",
            "tvleylxn",
            "fwvagmlw",
            "lftzzwtwnpdv",
            "wnjyvtg",
            "dhowpirly",
            "mzctfaj"
        }
        if s3_10[(s2_12 * 51 + 53) % 16 + 1] <= s3_10[(s2_12 * 51 + 53) % 16 + 1] then
            sy = {}
        else
            sC = {}
        end
        s2_12 = (s2_12 + 5) % 16
    else
        local Ed = bit32.rrotate(bit32.bxor(bit32.lrotate(s2_12, 3), string.byte(tostring(worker4))), 22)
        if bit32.bxor(bit32.lrotate(bit32.bxor(Ed, 1606584797), 10), 170358143) ~= bit32.lrotate(Ed, 10) then
            sC = {}
            worker4 = {}
        else
            worker4 = {}
            sC = {}
        end
        s2_12 = (s2_12 + 9) % 16
    end
until (s2_12 * 13 + 14) % 16 == 5
local s3_11 = {}
for k, v in sH.Eggs do
    local s2_13 = type(k) == "string" and type(v) == "table" and v.Product == nil and tonumber(v.Cost) ~= nil
    s6 = s2_13 and k ~= "Admin"
    if s6 then
        local insert = table.insert
        local s5_7 = tonumber(v.Order) or 999
        s6 = type(v.DisplayName) == "string" and v.DisplayName
        s7 = s6 or k
        s6 = tonumber(v.Cost) or 0
        insert(s3_11, { Name = k, Order = s5_7, Display = s7, Cost = s6 })
    end
end
table.sort(s3_11, fn255)
for k, v in s3_11 do
    table.insert(worker4, v)
    sC[v.Display] = v
    table.insert(sy, v.Display)
end
local s2_15 = 1
repeat
    local Dj = bit32.rrotate(bit32.bxor(bit32.lrotate(s2_15, 18), string.byte(tostring(s2_15))), 30)
    if bit32.bxor(bit32.lrotate(bit32.bxor(Dj, 3345661975), 12), 2885778550) ~= bit32.lrotate(Dj, 12) then
        sy.EggLabel = State[1]
    else
        State.EggLabel = sy[1]
    end
    s2_15 = (s2_15 + 3) % 8
until (s2_15 * 5 + 2) % 8 == 6
r8, st, ss, so, sm, sk, sh, se, sa, r5, rX, sG, sv, sV, sz, sf, r2, sN, sq, r9, r3, sO, sw, sg, r0, sI, sl, sY, sK, sZ, si, r_, sA, s6, sn, sd, r7, sJ, sb, s1, sQ, sL, sp, worker5 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
r8 = { "1", "3", "8", "16" }
r5 = fn477
rX = fn249
sG = fn127
sv = fn712
sD.Track(function()
    local connection
    connection = r6.GateState.OnClientEvent:Connect(function(bf, bg)
        if sD.Unloaded then
            return
        end
        State.Opened = sv(bf)
        State.Cleared = sv(bg)
    end)
    return function()
        connection:Disconnect()
    end
end)
sV = function(bq)
    if typeof(bq) ~= "Vector3" then
        return
    end
    local uE = os.clock()
    if uE - State.LastStream < 0.45 then
        return
    end
    State.LastStream = uE
    pcall(function()
        LocalPlayer:RequestStreamAroundAsync(bq)
    end)
end
sz = fn1039
sf = fn482
r2 = fn1031
sN = fn69
sq = fn378
r9 = fn298
r3 = fn895
sO = fn655
sw = fn572
sg = fn390
r0 = fn349
sI = fn807
sl = fn207
sY = fn91
if ((sQ and sQ or sg and not sN) and ((r_ or not r_) and (sQ or r_)) or (not r0 and sN and (r_ and r0) or (not sN or not sN or (sQ or not sg)))) and not ((sQ and sQ or sg and not sN) and ((r_ or not r_) and (sQ or r_)) or (not r0 and sN and (r_ and r0) or (not sN or not sN or (sQ or not sg)))) then
    sq = fn186
else
    sK = fn186
end
sZ = fn208
si = fn909
r_ = fn487
sA = fn409
if (not sO and sJ or (not sJ or sZ)) and (sO or sJ or (sZ or not sJ)) or not ((not sO and sJ or (not sJ or sZ)) and (sO or sJ or (sZ or not sJ))) then
    s6 = fn562
end
sn = fn505
sd = fn399
r7 = fn380
sJ = fn421
sb = function(e4)
    local wN
    local wO_1
    wO_1, wN = sJ(e4)
    if not wO_1 then
        return false
    end
    r2(wO_1)
    if wN and sc then
        pcall(sc, wN)
    elseif wN then
        pcall(function()
            wN:InputHoldBegin()
            wN:InputHoldEnd()
        end)
    end
    return true
end
s1 = fn153
s7 = fn907
sQ = fn76
worker4 = function()
    local xx = false
    repeat
        if not sD.Unloaded then
            if State.Enabled.BuyAura then
                local xu = sQ()
                if xu then
                    pcall(function()
                        r6.RequestAuraEquip:InvokeServer(xu)
                    end)
                    task.wait(0.8)
                else
                    task.wait(0.8)
                end
            else
                task.wait(0.4)
            end
        else
            xx = true
        end
    until xx
end
sL = fn1071
sp = fn639
if ((r7 or false or si and not si) and (sI and false and (not si and false)) or (sI or not r7 or (sI or worker3)) and ((not sK or false) and (sK and 7)) or ((si and sI or (worker3 or r7)) and (not sI and not sI or not r7 and not sI) or (not sI or sK) and (worker3 and not r7) and ((sK or worker3) and (worker3 or not r7)))) and not ((r7 or false or si and not si) and (sI and false and (not si and false)) or (sI or not r7 or (sI or worker3)) and ((not sK or false) and (sK and 7)) or ((si and sI or (worker3 or r7)) and (not sI and not sI or not r7 and not sI) or (not sI or sK) and (worker3 and not r7) and ((sK or worker3) and (worker3 or not r7)))) then
    sO = function()
        local x4 = false
        repeat
            if not sD.Unloaded then
                local xY = State.Enabled.Hatch and not sG()
                if xY then
                    local xX = sC[State.EggLabel]
                    local max = math.max
                    local floor2 = math.floor
                    local x_ = tonumber(State.HatchAmount) or 1
                    local xW = max(1, floor2(x_))
                    local xY_7 = r5()
                    local xZ_4 = xX
                    if xZ_4 then
                        local x__3 = sL(xY_7)
                        local x0_3 = tonumber(sH.MaxInventory) or 100
                        xZ_4 = x__3 < x0_3
                    end
                    if xZ_4 then
                        local xZ_5 = xX.Cost * xW
                        local x__4 = math.max
                        local floor = math.floor
                        local x1 = tonumber(xY_7.Wins) or 0
                        local xY_8 = x__4(0, floor(x1))
                        if xY_8 >= xZ_5 then
                            local xY_9 = sp(xX.Name)
                            if xY_9 then
                                sV(xY_9.Position)
                                r2(xY_9)
                                local xY_10 = type(sF.IsBusy) == "function" and sF.IsBusy()
                                if not xY_10 then
                                    pcall(function()
                                        r6.RequestHatch:InvokeServer(xX.Name, xW)
                                    end)
                                end
                            end
                            task.wait(0.45)
                        else
                            task.wait(0.6)
                        end
                    else
                        task.wait(0.6)
                    end
                else
                    task.wait(0.4)
                end
            else
                x4 = true
            end
        until x4
    end
else
    worker5 = function()
        local x4 = false
        repeat
            if not sD.Unloaded then
                local xY = State.Enabled.Hatch and not sG()
                if xY then
                    local xX = sC[State.EggLabel]
                    local max = math.max
                    local floor2 = math.floor
                    local x_ = tonumber(State.HatchAmount) or 1
                    local xW = max(1, floor2(x_))
                    local xY_2 = r5()
                    local xZ_1 = xX
                    if xZ_1 then
                        local x__1 = sL(xY_2)
                        local x0_1 = tonumber(sH.MaxInventory) or 100
                        xZ_1 = x__1 < x0_1
                    end
                    if xZ_1 then
                        local xZ_2 = xX.Cost * xW
                        local x__2 = math.max
                        local floor = math.floor
                        local x1 = tonumber(xY_2.Wins) or 0
                        local xY_3 = x__2(0, floor(x1))
                        if xY_3 >= xZ_2 then
                            local xY_4 = sp(xX.Name)
                            if xY_4 then
                                sV(xY_4.Position)
                                r2(xY_4)
                                local xY_5 = type(sF.IsBusy) == "function" and sF.IsBusy()
                                if not xY_5 then
                                    pcall(function()
                                        r6.RequestHatch:InvokeServer(xX.Name, xW)
                                    end)
                                end
                            end
                            task.wait(0.45)
                        else
                            task.wait(0.6)
                        end
                    else
                        task.wait(0.6)
                    end
                else
                    task.wait(0.4)
                end
            else
                x4 = true
            end
        until x4
    end
end
st = task.spawn(worker)
ss = task.spawn(worker2)
so = task.spawn(s6)
sm = task.spawn(worker3)
sk = task.spawn(s7)
sh = task.spawn(worker4)
se = task.spawn(worker5)
sa = task.spawn(worker6)
sD.Track(fn479)
sD.SetEnabled = fn853
sD.SetStage = fn432
sD.SetTrain = fn771
sD.SetEgg = fn189
sD.SetHatchAmount = fn521
sD.Options = fn406
local function tc()
    local Ch
    local Cg
    local onDiscord
    Cg = nil
    Ch = nil
    onDiscord = nil
    local Cb, ThemeManager, Cd, UserInputService, Options, SaveManager, TeleportService, Ck, Library, Toggles, Co
    Cb = "https://tempohub.shop"
    Cg = "https://discord.gg/K7Qxnxkk46"
    TeleportService = game:GetService("TeleportService")
    Ck = "https://discord.gg/K7Qxnxkk46"
    UserInputService = game:GetService("UserInputService")
    Co = "+1 Dino Evolution"
    Library = getgenv().Library
    ThemeManager = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = Library.Toggles
    Options = Library.Options
    s_(sD, Library)
    Ch = function(hU, hV)
        local yt = sr(setclipboard) and setclipboard
        local yu = yt
        local yz = if yu then 1 else 0
        local yx = 2701 * yz + 105 * (1 - yz)
        local yy = 1505 * yz + 3850 * (1 - yz)
        if not ((yx * 2909 + yy * 2838 + yx * yy) % 16777213 == 16193404) then
            local yt_1 = sr(toclipboard) and toclipboard
            yu = yt_1 or nil
        end
        local yt_2 = yu
        if not yt_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local yu_1 = pcall(yt_2, hU)
        if yu_1 then
            Library:Notify(hV)
        else
            Library:Notify("Failed to copy")
        end
    end
    onDiscord = function()
        Ch(Cg, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = Cg, Copyable = true }, "|", Co },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(true, { Color = Color3.fromRGB(242, 154, 196), Radius = 24, Transparency = 0.3 })
    Cd = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gamepad-2"),
        Shop = Window:AddTab("Shop", "shopping-cart"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
    local function Cp_1(h7)
        local DiscordGroup = h7:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    for k, v in Cd do
        if k ~= "Info" then
            Cp_1(v)
        end
    end
    local Cp_2 = sD.Options()
    local FarmGroup = Cd.Main:AddLeftGroupbox("Farm", "trophy")
    FarmGroup:AddToggle("AutoFarm", {
        Text = "Auto Farm",
        Default = false,
        Callback = function(ig)
            sD.SetEnabled("Farm", ig)
        end
    })
    FarmGroup:AddDropdown("FarmStage", {
        Text = "Stage",
        Values = Cp_2.Stages,
        Default = 1,
        Callback = function(ii)
            sD.SetStage(ii)
        end
    })
    FarmGroup:AddToggle("AutoClick", {
        Text = "Auto Click",
        Default = false,
        Callback = function(ik)
            sD.SetEnabled("Click", ik)
        end
    })
    FarmGroup:AddToggle("AutoRebirth", {
        Text = "Auto Rebirth",
        Default = false,
        Callback = function(im)
            sD.SetEnabled("Rebirth", im)
        end
    })
    local TrainGroup = Cd.Main:AddRightGroupbox("Train", "target")
    TrainGroup:AddToggle("AutoTrain", {
        Text = "Auto Train",
        Default = false,
        Callback = function(iq)
            sD.SetEnabled("Train", iq)
        end
    })
    TrainGroup:AddDropdown("TrainPad", {
        Text = "Training Area",
        Values = Cp_2.Train,
        Default = 1,
        Callback = function(is)
            sD.SetTrain(is)
        end
    })
    local BuyGroup = Cd.Shop:AddLeftGroupbox("Buy", "shopping-bag")
    BuyGroup:AddToggle("AutoBuyDino", {
        Text = "Auto Buy Best Dino",
        Default = false,
        Callback = function(iv)
            sD.SetEnabled("BuyDino", iv)
        end
    })
    BuyGroup:AddToggle("AutoBuyAura", {
        Text = "Auto Buy Aura",
        Default = false,
        Callback = function(ix)
            sD.SetEnabled("BuyAura", ix)
        end
    })
    local EquipGroup = Cd.Shop:AddRightGroupbox("Equip", "backpack")
    EquipGroup:AddToggle("AutoBestPets", {
        Text = "Auto Equip Best Pet",
        Default = false,
        Callback = function(iA)
            sD.SetEnabled("BestPets", iA)
        end
    })
    EquipGroup:AddToggle("AutoBestItems", {
        Text = "Auto Equip Best Item",
        Default = false,
        Callback = function(iC)
            sD.SetEnabled("BestItems", iC)
        end
    })
    local HatchGroup = Cd.Shop:AddLeftGroupbox("Hatch", "egg")
    HatchGroup:AddToggle("AutoHatch", {
        Text = "Auto Hatch",
        Default = false,
        Callback = function(iF)
            sD.SetEnabled("Hatch", iF)
        end
    })
    HatchGroup:AddDropdown("HatchEgg", {
        Text = "Egg",
        Values = Cp_2.Eggs,
        Default = 1,
        Callback = function(iH)
            sD.SetEgg(iH)
        end
    })
    HatchGroup:AddDropdown("HatchAmount", {
        Text = "Amount",
        Values = Cp_2.HatchAmounts,
        Default = 1,
        Callback = function(iJ)
            sD.SetHatchAmount(iJ)
        end
    })
    local function Cp_3()
        local yS
        local yQ
        local yV
        local y_
        yQ = nil
        yS = nil
        yV = nil
        y_ = nil
        local Label2, Label3, yT, yU, Label, yX, yY, yZ, y0
        y_ = function(iN)
            return (tostring(iN):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
        end
        yV = function(iP, iQ)
            return string.format('<font color="%s">%s</font>', iQ, y_(iP))
        end
        y0 = function(iT, iU, iV)
            return string.format("<b>%s</b> %s %s", iT, yV("-", "#5a6070"), yV(iU, iV))
        end
        local y1 = {}
        local y2 = "#8b93a3"
        yZ = "#7fd47f"
        yT = "#e8a34d"
        local y3 = "#6ec1ff"
        if not sj then
            table.insert(y1, "firetouchinterest")
        end
        if not sc then
            table.insert(y1, "fireproximityprompt")
        end
        local y4 = #y1 == 0 and "ready"
        local y5 = y4 or "limited: " .. table.concat(y1, ", ")
        yY = "Unknown"
        pcall(function()
            local yB_1
            local yA_1
            if sr(identifyexecutor) then
                yB_1, yA_1 = identifyexecutor()
                local yC = yB_1 ~= ""
                local yD = type(yB_1) == "string" and yC
                if yD then
                    local yC_1 = type(yA_1) == "string" and yA_1 ~= "" and yB_1 .. " " .. yA_1
                    yY = yC_1 or yB_1
                end
            end
        end)
        yQ = os.clock()
        yX = function()
            local yF = math.floor(os.clock() - yQ)
            if yF < 60 then
                return yF .. "s"
            elseif yF < 3600 then
                return string.format("%dm %ds", math.floor((yF) / (60)), yF % 60)
            else
                return string.format("%dh %dm", math.floor((yF) / (3600)), math.floor((yF % 3600) / (60)))
            end
        end
        local UserGroup = Cd.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(y0("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, yZ), true)
        UserGroup:AddLabel(y0("UserId", tostring(LocalPlayer.UserId), y3), true)
        UserGroup:AddLabel(y0("Executor", yY .. "  " .. y5, yZ), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(y0("Session", yX(), yT), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                Ch(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                Ch("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = Cd.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(y0("Game", Co, y3), true)
        Label2 = SessionGroup:AddLabel(y0("Players", "0/0", yZ), true)
        yU = tostring(game.JobId)
        local y3_1 = #yU > 18 and string.sub(yU, 1, 18) .. "..."
        local y4_2 = y3_1 or yU
        SessionGroup:AddLabel(y0("Job", y4_2, y2), true)
        Label = SessionGroup:AddLabel(y0("Ping", "0 ms", yT), true)
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
                Ch(yU, "Copied Job ID")
            end
        })
        yS = task.spawn(function()
            local yI_1
            local yH_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(y0("Session", yX(), yT))
                Label2:SetText(y0("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), yZ))
                yH_1, yI_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local yH_2 = yH_1 and yI_1 .. " ms" or "n/a"
                Label:SetText(y0("Ping", yH_2, yT))
            end
        end)
        sD.Track(function()
            if coroutine.status(yS) ~= "dead" then
                task.cancel(yS)
            end
        end)
        local SocialsGroup = Cd.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                Ch(Ck, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                Ch(Cb, "Copied website link")
            end
        })
    end
    Cp_3()
    local function Cp_4()
        local ka
        local j8
        local j9
        local kb
        local MovementGroup = Cd.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = Cd.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        j9 = {}
        local j7 = {}
        ka = {}
        j8 = {}
        kb = {}
        local function kc()
            for k, v in j8 do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(j8)
        end
        local function kg()
            for k, v in j9 do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(j9)
        end
        local function kk()
            for k, v in ka do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(ka)
        end
        local function ko(kp)
            if not kp:IsA("ProximityPrompt") then
                return
            end
            if kb[kp] == nil then
                kb[kp] = {
                    HoldDuration = kp.HoldDuration,
                    MaxActivationDistance = kp.MaxActivationDistance,
                    RequiresLineOfSight = kp.RequiresLineOfSight
                }
            end
            kp.HoldDuration = 0
            kp.MaxActivationDistance = 50
            kp.RequiresLineOfSight = false
        end
        local function kr()
            for k, v in kb do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(kb)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                kk()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                kg()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                kc()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for k, v in Workspace:QueryDescendants("ProximityPrompt") do
                    pcall(ko, v)
                end
            else
                kr()
            end
        end)
        table.insert(j7, Workspace.DescendantAdded:Connect(function(kL)
            if Toggles.InstantProximityPrompt.Value then
                ko(kL)
            end
        end))
        table.insert(j7, RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if j8[v] == nil then
                        j8[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(j7, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local zY = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and zY then
                zY:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(j7, RunService.RenderStepped:Connect(function(k5)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local z0 = Character and Character:FindFirstChildOfClass("Humanoid")
            local z1 = Character
            if z1 then
                z1 = Character:FindFirstChild("HumanoidRootPart")
            end
            local z__1 = z1
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and z0 then
                if j9[z0] == nil then
                    j9[z0] = z0.WalkSpeed
                end
                z0.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and z__1 and z0 and CurrentCamera then
                if ka[z0] == nil then
                    ka[z0] = z0.PlatformStand
                end
                z0.PlatformStand = true
                local z1_4 = Vector3.zero
                if not UserInputService:GetFocusedTextBox() then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        z1_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        z1_4 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        z1_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        z1_4 += CurrentCamera.CFrame.RightVector
                    end
                    local z7 = if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
                    if z7 == 1 then
                        z1_4 += Vector3.new(0, 1, 0)
                    end
                    local z7_1 = if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then 1 else 0
                    if z7_1 == 1 then
                        z1_4 -= Vector3.new(0, 1, 0)
                    end
                end
                z__1.AssemblyLinearVelocity = Vector3.zero
                if z1_4.Magnitude > 0 then
                    z__1.CFrame = z__1.CFrame + z1_4.Unit * Options.FlySpeed.Value * k5
                end
            end
        end))
        sD.Track(function()
            for k, v in j7 do
                v:Disconnect()
            end
            kc()
            kg()
            kk()
            kr()
        end)
    end
    Cp_4()
    local function Cp_5()
        local lr
        local l8
        local Lighting = game:GetService("Lighting")
        lr = {}
        local GuiService = game:GetService("GuiService")
        local lq = {}
        local CoreGui = game:GetService("CoreGui")
        local VirtualUser = game:GetService("VirtualUser")
        local ls
        local lv = 0
        local lt = false
        local lu = 0
        local lw = os.clock()
        local MenuGroup = Cd.Settings:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        local Label = MenuGroup:AddLabel("AFK triggers: 0")
        local function lA()
            local CurrentCamera
            CurrentCamera = Workspace.CurrentCamera
            if not CurrentCamera then
                return
            end
            local Ag = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.zero, CurrentCamera.CFrame)
            end)
            if not Ag then
                return
            end
            lv += 1
            lw = os.clock()
            Label:SetText("AFK triggers: " .. lv)
        end
        local function onAntiGameplayPause(lM)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not lM)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not lM
                end
            end)
            if lM then
                pcall(function()
                    if sr(sethiddenproperty) then
                        sethiddenproperty(LocalPlayer, "GameplayPaused", false)
                    else
                        LocalPlayer.GameplayPaused = false
                    end
                end)
            end
        end
        local function l_()
            for k, v in lr do
                local Aq = k
                local As = v
                if Aq.Parent then
                    pcall(function()
                        Aq.Enabled = As
                    end)
                end
            end
            table.clear(lr)
            if ls then
                pcall(function()
                    settings().Rendering.QualityLevel = ls.Quality
                end)
                Lighting.GlobalShadows = ls.Shadows
                Lighting.FogEnd = ls.Fog
                ls = nil
            end
        end
        l8 = { ParticleEmitter = true, Trail = true, Smoke = true, Fire = true, Sparkles = true, Beam = true }
        local function l9(ma)
            if l8[ma.ClassName] then
                if lr[ma] == nil then
                    lr[ma] = ma.Enabled
                end
                ma.Enabled = false
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true, Callback = onAntiGameplayPause })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(md)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not md)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(mi)
                if mi then
                    if not ls then
                        ls = {
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
                        pcall(l9, v)
                    end
                else
                    l_()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        local ScriptGroup = Cd.Settings:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        table.insert(lq, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                lA()
            end
        end))
        table.insert(lq, Workspace.DescendantAdded:Connect(function(mz)
            if Toggles.FpsBoost.Value then
                l9(mz)
            end
        end))
        local function mC(mD)
            if lt or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            lt = true
            local AG = lu
            local AH_1 = pcall(function()
                if mD then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not AH_1 then
                lt = false
                if not mD and AG == lu then
                    task.delay(1.5, function()
                        if AG == lu then
                            mC(true)
                        end
                    end)
                end
            end
        end
        table.insert(lq, TeleportService.TeleportInitFailed:Connect(function(mV)
            local AO
            if mV == LocalPlayer and lt then
                lt = false
                AO = lu
                task.delay(3, function()
                    if AO == lu then
                        mC(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local AT = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            if Library.Unloaded or not AT then
                return
            end
            table.insert(lq, AT.ChildAdded:Connect(function(m9)
                if m9.Name == "ErrorPrompt" then
                    mC(false)
                end
            end))
        end)
        local ni = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    onAntiGameplayPause(true)
                end
                local AZ = Toggles.AntiAfk.Value and os.clock() - lw >= 60
                if AZ then
                    lA()
                end
                task.wait(1)
            end
        end)
        sD.Track(function()
            lu += 1
            for k, v in lq do
                v:Disconnect()
            end
            pcall(task.cancel, ni)
            onAntiGameplayPause(false)
            l_()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    Cp_5()
    local function Cp_6()
        local B5, B6, B7, B8
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("TempoHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(Cd.Settings)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/DinoEvolution")
        local B9 = SaveManager:BuildConfigSection(Cd.Settings)
        B7 = function(nA, nB)
            local A8_1 = (nA == "Toggle" and Toggles or Options)[nB]
            local A7_2 = type(A8_1) == "table" and A8_1.Type == nA
            return A7_2 and A8_1 or nil
        end
        B5 = function(nK, nL)
            local Type = nL.Type
            if Type == "Toggle" then
                return { idx = nK, type = "Toggle", value = nL.Value == true }
            elseif Type == "Slider" then
                return { idx = nK, type = "Slider", value = tostring(nL.Value) }
            elseif Type == "Dropdown" then
                return { idx = nK, type = "Dropdown", multi = nL.Multi == true, value = nL.Value }
            elseif Type == "Input" then
                local Bf = nL.Value or ""
                return { idx = nK, type = "Input", text = tostring(Bf) }
            elseif Type == "ColorPicker" then
                return { idx = nK, type = "ColorPicker", value = nL.Value:ToHex(), transparency = nL.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = nK,
                    type = "KeyPicker",
                    mode = nL.Mode,
                    key = nL.Value,
                    modifiers = nL.Modifiers,
                    toggled = nL.Toggled
                }
            else
                return nil
            end
        end
        B8 = function()
            local Bo = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local Bp = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if Bp then
                        local Bp_1 = B5(k, v)
                        if Bp_1 then
                            Bo[#Bo + 1] = Bp_1
                        end
                    end
                end
            end
            table.sort(Bo, function(nV, nW)
                if nV.type ~= nW.type then
                    return nV.type < nW.type
                end
                return nV.idx < nW.idx
            end)
            return { objects = Bo }
        end
        B6 = function(nY)
            local BI
            BI = nil
            local BJ = type(nY) ~= "table" or type(nY.idx) ~= "string"
            local BN = if BJ then 1 else 0
            local BL = 1587 * BN + 1480 * (1 - BN)
            local BM = 608 * BN + 2030 * (1 - BN)
            if not ((BL * 3249 + BM * 177 + BL * BM) % 16777213 == 6228675) then
                BJ = type(nY.type) ~= "string"
            end
            if not BJ then
                BJ = SaveManager.Ignore[nY.idx]
            end
            if BJ then
                return false
            end
            BI = B7(nY.type, nY.idx)
            if not BI then
                return false
            end
            local BJ_1 = pcall(function()
                if nY.type == "Input" then
                    if type(nY.text) ~= "string" then
                        return
                    end
                    BI:SetValue(nY.text)
                elseif nY.type == "ColorPicker" then
                    BI:SetValueRGB(Color3.fromHex(nY.value), nY.transparency)
                elseif nY.type == "KeyPicker" then
                    BI:SetValue({ nY.key, nY.mode, nY.modifiers })
                    if nY.mode == "Toggle" and nY.toggled ~= nil then
                        BI.Toggled = nY.toggled
                        BI:Update()
                    end
                else
                    BI:SetValue(nY.value)
                end
            end)
            return BJ_1
        end
        B9:AddDivider()
        B9:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        B9:AddButton("Export Config to Clipboard", function()
            local BP_1
            local BO_1
            BO_1, BP_1 = pcall(HttpService.JSONEncode, HttpService, B8())
            if not BO_1 then
                Library:Notify("Failed to encode the config")
                return
            end
            local BO_2 = sr(setclipboard) and setclipboard
            local BQ = BO_2
            if not BQ then
                local BO_3 = sr(toclipboard) and toclipboard
                BQ = BO_3 or nil
            end
            local BO_4 = BQ
            local BQ_1 = type(BO_4) ~= "function" or not pcall(BO_4, BP_1)
            if BQ_1 then
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Config copied to clipboard", 6)
        end)
        B9:AddButton("Import Config from Clipboard Text", function()
            local BV_1
            local BT = Options.SaveManager_ImportSource.Value or ""
            local BT_1
            local BU = tostring(BT):match("^%s*(.-)%s*$")
            if BU == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            if #BU > 262144 then
                Library:Notify("That config is too large")
                return
            end
            BT_1, BV_1 = pcall(HttpService.JSONDecode, HttpService, BU)
            local BU_1 = not BT_1 or type(BV_1) ~= "table" or type(BV_1.objects) ~= "table"
            if BU_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            if #BV_1.objects > 2048 then
                Library:Notify("That config has too many records")
                return
            end
            local BT_2 = 0
            for i, v in ipairs(BV_1.objects) do
                if B6(v) then
                    BT_2 += 1
                end
            end
            if BT_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local BV_2 = BT_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(BT_2, BV_2), 6)
        end)
        SaveManager:LoadAutoloadConfig()
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    Cp_6()
end
tc()
end)(...)

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
getgenv().TempoHoodSubtitle = "STEAL ANIME EGGS & FIGHT!"
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
local fns = {}
local uX
local vE
local vl
local v2
local u2
local uK
local vr
local v8
local u8
local uQ
local vx
local we
local ve
local vW
local vk
local v1
local u1
local vJ
local uJ
local vq
local v7
local CoreGui
local uP
local vw
local vV
local uV
local vj
local State
local uI
local vp
local v6
local u6
local vO
local uO
local worker
local wc
local vU
local uU
local vB
local wi
local v_
local u_
local vH
local uH
local vo
local u5
local vN
local LocalPlayer
local uT
local vA
local wh
local vZ
local uZ
local uG
local vn
local u4
local vM
local uM
local vt
local wa
local uS
local wg
local uY
local vF
local vm
local v3
local u3
local vs
local v9
local u9
local vR
local uR
local CollectionService
local wf
local vf
function fns.fn7(jl)
    State.StealZones, State.StealZoneCount = vm(jl, uV)
end
function fns.fn13(jp)
    State.StealRarities, State.StealRarityCount = vm(jp, nil)
end
function fns.fn24(eo)
    for i, descendant in ipairs(eo:GetDescendants()) do
        local zR = descendant:IsA("ProximityPrompt") and descendant.Name == vs
        if zR then
            return descendant
        end
    end
    return nil
end
function fns.fn27()
    task.spawn(worker)
end
function fns.fn115(bX)
    for i, v in ipairs(wi) do
        if v == bX then
            return i
        end
    end
    return 0
end
local function fn119(cj, ck)
    local yI_1
    local yH_1
    yI_1, yH_1 = {}, 0
    if type(cj) == "table" then
        for k, v in pairs(cj) do
            local yJ
            local yK = v == true and type(k) == "string"
            if yK then
                yJ = k
            elseif type(v) == "string" then
                yJ = v
            end
            if yJ then
                local yJ_1 = ck and ck[yJ] or yJ
                if yI_1[yJ_1] == nil then
                    yI_1[yJ_1] = true
                    yH_1 += 1
                end
            end
        end
    end
    return yI_1, yH_1
end
local function fn125(cP, cQ)
    local y7_1, y7_2
    local y6_1, y6_2
    y6_1, y7_1 = uG()
    if not y7_1 then
        return false
    end
    y7_1.AssemblyLinearVelocity = Vector3.zero
    y7_1.CFrame = CFrame.new(cP)
    task.wait(v7)
    y6_2, y7_2 = uG()
    if not y7_2 then
        return false
    end
    return (y7_2.Position - cP).Magnitude <= (cQ or 6)
end
local function fn130()
    local xy = uZ ~= nil
    local xz = vo("placeEgg") ~= nil and xy
    return xz and uI ~= nil
end
local function fn154(ay)
    State.Status = ay
end
local function fn183()
    return vo("equipBestPets") ~= nil
end
local function fn185(jQ)
    local DC = jQ and true or false
    State.AutoBuyTrail = DC
    if State.AutoBuyTrail then
        if not vJ() then
            State.AutoBuyTrail = false
            return
        end
        vN("Trail", vj, uU)
    else
        v9("Trail")
    end
end
local function fn190()
    return vo("hatchAll") ~= nil
end
local function fn257()
    local xF = vO ~= nil
    local xG = vo("playtimeClaim") ~= nil and xF
    return xG
end
local function fn272(be)
    local xl = u4 and uT(u4[be]) and u4[be]
    return xl or nil
end
local function fn273()
    local zh_1
    local zg_1
    local zf = not uI or not uT(uI.get)
    if zf then
        return nil
    end
    local zf_1 = vB()
    if zf_1 <= 0 then
        return nil
    end
    zg_1, zh_1 = pcall(uI.get, zf_1)
    local zf_2 = zg_1 and type(zh_1) == "table" and typeof(zh_1.Surface) == "Instance"
    if zf_2 then
        return zh_1
    end
    return nil
end
local function fn290(dY)
    if State.StealZoneCount > 0 then
        local attr2 = dY:GetAttribute("BiomeId")
        local zx_1 = type(attr2) ~= "string"
        local zB = if zx_1 then 1 else 0
        local zz = 205 * zB + 80 * (1 - zB)
        local zA = 72 * zB + 1271 * (1 - zB)
        if not ((zz * 228 + zA * 1474 + zz * zA) % 16777213 == 167628) then
            zx_1 = not State.StealZones[attr2]
        end
        if zx_1 then
            return false
        elseif State.StealRarityCount > 0 then
            local attr = dY:GetAttribute("Rarity")
            local zx_2 = type(attr) ~= "string" or not State.StealRarities[attr]
            if zx_2 then
                return false
            end
            return true
        else
            return true
        end
    elseif State.StealRarityCount > 0 then
        local attr = dY:GetAttribute("Rarity")
        local zx_3 = type(attr) ~= "string" or not State.StealRarities[attr]
        if zx_3 then
            return false
        end
        return true
    else
        return true
    end
end
local function fn319()
    task.spawn(function()
        if v6() then
            pcall(vo("equipBestPets"))
        end
    end)
end
local function fn326(ju)
    local Dh = ju and true or false
    State.AutoSteal = Dh
    if State.AutoSteal then
        if not u5() then
            State.AutoSteal = false
            uX("Steal is unavailable")
            return
        end
        uX("Auto steal running")
        vN("Steal", vE, uM)
    else
        v9("Steal")
        uX("Idle")
    end
end
local function fn349()
    task.spawn(function()
        if wg() then
            pcall(vo("hatchAll"))
        end
    end)
end
local function fn398(jS)
    local DL = jS and true or false
    State.AutoUpgradeTreadmill = DL
    if State.AutoUpgradeTreadmill then
        if not vk() then
            State.AutoUpgradeTreadmill = false
            return
        end
        vN("Treadmill", ve, uO)
    else
        v9("Treadmill")
    end
end
local function fn399()
    local zc = uP and uP.attributes and uP.attributes.playerPlotId or "PlotId"
    local floor = math.floor
    local zd = tonumber(LocalPlayer:GetAttribute(zc)) or 0
    return floor(zd)
end
local function fn410()
    local xO = vV ~= nil
    local xP = vo("treadmillUpgrade") ~= nil and xO
    return xP
end
local function fn421(dk)
    local zj = we[dk]
    we[dk] = nil
    local zk = zj and coroutine.status(zj) ~= "dead"
    if zk then
        pcall(task.cancel, zj)
    end
end
local function fn437()
    return not u6.Unloaded
end
local function fn441()
    local xU_1
    local xT_1
    xT_1, xU_1 = {}, {}
    for i, v in ipairs(wi) do
        local xV_1 = not uZ or type(uZ.rarities) ~= "table" or uZ.rarities[v]
        if xV_1 then
            xT_1[v] = true
            table.insert(xU_1, v)
        end
    end
    local xV_2 = uZ and type(uZ.rarities) == "table"
    if xV_2 then
        local xV_3 = {}
        for k in pairs(uZ.rarities) do
            local xW = type(k) == "string" and not xT_1[k]
            if xW then
                table.insert(xV_3, k)
            end
        end
        table.sort(xV_3)
        for i, v in ipairs(xV_3) do
            table.insert(xU_1, v)
        end
    end
    return xU_1
end
local function fn450(X)
    local wZ = typeof(cloneref) == "function" and typeof(X) == "Instance"
    if wZ then
        return cloneref(X)
    end
    return X
end
local function fn485()
    local AV = uZ and uZ.plot and uZ.plot.toolUidAttribute or "EggUid"
    local AU_1 = uZ
    if AU_1 then
        AU_1 = uZ.plot
    end
    if AU_1 then
        AU_1 = uZ.plot.toolAttribute
    end
    local AV_1 = AU_1 or "BankedEggTool"
    local AU_2 = {}
    local AV_2 = { LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character }
    for i, v in ipairs(AV_2) do
        if v then
            for i, child in ipairs(v:GetChildren()) do
                local AV_3 = child:IsA("Tool") and child:GetAttribute(AV_1) == true and type(child:GetAttribute(AV)) == "string"
                if AV_3 then
                    table.insert(AU_2, child)
                end
            end
        end
    end
    return AU_2
end
local function fn498()
    local CK_1
    local CG = not State.AutoBuyTrail or not vJ()
    if CG then
        return
    end
    local CG_1 = tonumber(LocalPlayer:GetAttribute("OwnedTrailsMask")) or 0
    local CH = CG_1
    local CG_2 = tonumber(LocalPlayer:GetAttribute("Cash")) or 0
    local CI = CG_2
    local CG_3 = vo("trailAction")
    for i, v in ipairs(vp()) do
        local CJ = not uK() or not State.AutoBuyTrail
        local CJ_3
        if CJ then
            return
        end
        local CJ_1 = not bit32.btest(CH, bit32.lshift(1, v.Index - 1))
        if CJ_1 ~= false then
            CJ_1 = CI >= v.CashPrice
        end
        if CJ_1 then
            local CJ_2 = v.DisplayName or v.Id
            uX("Buying " .. tostring(CJ_2))
            CJ_3, CK_1 = pcall(CG_3, wf.action.Buy, v.Index)
            if not CJ_3 or CK_1 ~= wf.status.Bought then
                return
            end
            local CJ_4 = tonumber(LocalPlayer:GetAttribute("OwnedTrailsMask")) or CH
            CH = CJ_4
            local CJ_5 = tonumber(LocalPlayer:GetAttribute("Cash")) or CI
            CI = CJ_5
            task.wait(0.4)
        end
    end
end
local function fn553()
    local BX = not State.AutoHatchEgg or not wg()
    if BX then
        return
    end
    local BX_1 = false
    for i, v in ipairs(CollectionService:GetTagged(vF)) do
        local BY = v:GetAttribute("OwnerUserId") == LocalPlayer.UserId and v:GetAttribute("Ready") == true and v:GetAttribute("Hatching") ~= true
        if BY then
            BX_1 = true
            break
        end
    end
    if not BX_1 then
        return
    end
    uX("Hatching eggs")
    pcall(vo("hatchAll"))
end
local function fn555(aM)
    local xi_1
    local xh_1
    if typeof(aM) ~= "Instance" then
        return nil
    end
    xh_1, xi_1 = pcall(require, aM)
    local xj = xh_1 and type(xi_1) == "table"
    if xj then
        return xi_1
    end
    return nil
end
local function fn558(eR)
    local z5 = uZ and type(uZ.biomes) == "table"
    if z5 then
        for k, v in pairs(uZ.biomes) do
            local z5_1 = type(v) == "table" and tonumber(v.Stage) == eR
            if z5_1 then
                return v.Id
            end
        end
    end
    return nil
end
local function fn618(jC)
    local Dn = jC and true or false
    State.AutoPlaceEgg = Dn
    if State.AutoPlaceEgg then
        if not uQ() then
            State.AutoPlaceEgg = false
            return
        end
        vN("Place", vA, worker)
    else
        v9("Place")
    end
end
local function fn619()
    local Cl_1
    local Ck_1, Ck_3
    local Cg = not State.AutoPlaytime
    local Cq = if Cg then 1 else 0
    local Co = 2780 * Cq + 1719 * (1 - Cq)
    local Cp = 2 * Cq + 1297 * (1 - Cq)
    if not ((Co * 3451 + Cp * 1745 + Co * Cp) % 16777213 == 9602830) then
        Cg = not vW()
    end
    if Cg then
        return
    end
    local Cg_1 = tonumber(LocalPlayer:GetAttribute(vO.attributes.seconds)) or 0
    local Cg_2 = tonumber(LocalPlayer:GetAttribute(vO.attributes.claimedMask)) or 0
    local Ci = Cg_2
    local Cg_3 = vo("playtimeClaim")
    for i, v in ipairs(vO.rewards) do
        local Cj = not uK() or not State.AutoPlaytime
        local Cj_2
        if Cj then
            return
        end
        local Cj_1 = false
        Ck_1, Cl_1 = pcall(vO.isClaimed, Ci, i)
        if Ck_1 then
            Cj_1 = Cl_1 == true
        end
        local Ck_2 = tonumber(v.UnlockSeconds) or 0
        if Cg_1 >= Ck_2 and not Cj_1 then
            uX("Claiming playtime reward " .. i)
            Cj_2, Ck_3 = pcall(Cg_3, i)
            if Cj_2 and Ck_3 == vO.status.Claimed then
                State.Claimed = State.Claimed + 1
            end
            local wait = task.wait
            local Ck_4 = vO.requestInterval or 0.5
            wait(Ck_4)
            local Cj_4 = tonumber(LocalPlayer:GetAttribute(vO.attributes.claimedMask)) or Ci
            Ci = Cj_4
        end
    end
end
local function fn630()
    local Character = LocalPlayer.Character
    if not Character then
        return nil
    end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local yZ = not HumanoidRootPart or not Humanoid
    local y2 = if yZ then 1 else 0
    local y0 = 443 * y2 + 17 * (1 - y2)
    local y1 = 941 * y2 + 3243 * (1 - y2)
    if not ((y0 * 770 + y1 * 423 + y0 * y1) % 16777213 == 1156016) then
        yZ = Humanoid.Health <= 0
    end
    if yZ then
        return nil
    end
    return Character, HumanoidRootPart, Humanoid
end
local function fn637(jR)
    local DI = jR and true or false
    State.AutoUpgradePlot = DI
    if State.AutoUpgradePlot then
        if not vx() then
            State.AutoUpgradePlot = false
            return
        end
        vN("PlotUpgrade", ve, wh)
    else
        v9("PlotUpgrade")
    end
end
local function fn638()
    return CoreGui
end
local function fn644()
    local attr = LocalPlayer:GetAttribute("CarryingEggId")
    local zt = attr ~= ""
    local zu = type(attr) == "string" and zt
    if zu then
        return attr
    end
    return nil
end
local function fn684()
    return wc()
end
local function fn701()
    local z1 = vf()
    if not z1 then
        uX("No plot assigned")
        return false
    end
    local z2 = uJ(z1.Surface) + Vector3.new(0, 5, 0)
    uX("Banking egg")
    uY(z2, 8)
    v_(z2)
    local z1_1 = os.clock() + vM
    while true do
        local z3 = uK() and os.clock() < z1_1
        if z3 then
            if not vt() then
                return true
            end
            uY(z2, 6)
            task.wait(0.15)
            continue
        end
        break
    end
    return vt() == nil
end
local function fn762()
    gethui = vl
end
local function fn777()
    table.clear(uV)
    local yo = uZ
    local yp = {}
    if yo then
        yo = type(uZ.biomes) == "table"
    end
    if yo then
        for k, v in pairs(uZ.biomes) do
            local yo_1 = type(v) == "table" and type(v.Id) == "string"
            if yo_1 then
                table.insert(yp, v)
            end
        end
    end
    table.sort(yp, function(b9, ca)
        local yi = (tonumber(b9.Stage))
        local yn = if yi then 1 else 0
        local yl = 1146 * yn + 1919 * (1 - yn)
        local ym = 2978 * yn + 2898 * (1 - yn)
        if not ((yl * 3077 + ym * 790 + yl * ym) % 16777213 == 9291650) then
            yi = 0
        end
        local yj = tonumber(ca.Stage) or 0
        return yi < yj
    end)
    local yo_2 = {}
    for i, v in ipairs(yp) do
        local format = string.format
        local yq = v.DisplayName or v.Id
        local yr = tostring(yq)
        local ys = v.Stage or "?"
        local yt = format("%s (Stage %s)", yr, tostring(ys))
        uV[yt] = v.Id
        table.insert(yo_2, yt)
    end
    return yo_2
end
local function fn780()
    return uS()
end
local function fn814(dh)
    return dh.CFrame:PointToWorldSpace(Vector3.new(0, dh.Size.Y * 0.5, 0))
end
local function fn817()
    return os.clock() < vU
end
local function fn820(jP)
    local Dw = jP and true
    local DA = if Dw then 1 else 0
    local Dy = 3497 * DA + 775 * (1 - DA)
    local Dz = 65 * DA + 1683 * (1 - DA)
    if not ((Dy * 134 + Dz * 1655 + Dy * Dz) % 16777213 == 803478) then
        Dw = false
    end
    State.AutoPlaytime = Dw
    if State.AutoPlaytime then
        local DA_1 = if not vW() then 1 else 0
        if DA_1 == 1 then
            State.AutoPlaytime = false
            return
        end
        vN("Playtime", vn, u9)
    else
        v9("Playtime")
    end
end
local function fn855(dM)
    local zp = wa[dM]
    local zq = zp ~= nil and os.clock() < zp
    return zq
end
local function fn864()
    return uZ ~= nil and uI ~= nil and uP ~= nil
end
local function fn868(dR)
    wa[dR] = os.clock() + vH
end
local function fn894()
    local xL = v3 ~= nil
    local xM = vo("plotUpgrade") ~= nil and xL
    return xM
end
local function fn912()
    local Cx = {}
    for i, v in ipairs(wf.all) do
        local Cy = type(v) == "table" and tonumber(v.CashPrice) and tonumber(v.Index)
        if Cy then
            table.insert(Cx, v)
        end
    end
    table.sort(Cx, function(h5, h6)
        return h5.CashPrice < h6.CashPrice
    end)
    return Cx
end
local function fn960(cD)
    local y4_2
    local y3 = os.clock() + v2
    local y3_2
    while true do
        local y4_1 = vR() and uK() and os.clock() < y3
        if y4_1 then
            task.wait(0.1)
            continue
        end
        break
    end
    local y3_1 = vR() or not uK()
    if y3_1 then
        return false
    end
    vU = os.clock() + vZ
    y3_2, y4_2 = pcall(cD)
    vU = 0
    if not y3_2 then
        return false
    end
    return y4_2
end
local function fn961(aa)
    return type(aa) == "function"
end
local function fn980()
    local AA_3
    local Az_5
    local Ax = v8()
    if #Ax == 0 then
        uX("Map is still loading")
        return false
    end
    local Ay = #Ax
    local AE = 1
    local AC = Ay
    while true do
        if not (AE <= AC) then
            uX("No nest matches the zone filter")
            return false
        end
        u_ = u_ % #Ax + 1
        Ay = Ax[u_]
        local Az_1 = u2[u_]
        local AA_1 = Az_1 == nil or os.clock() >= Az_1
        local Az_2 = AA_1 and u1(Ay)
        if Az_2 then
            break
        end
        AE += 1
    end
    local format = string.format
    local AA_2 = Ay.Biome or "Stage " .. Ay.Stage
    uX(format("Scouting %s", tostring(AA_2)))
    uY(Ay.Position + Vector3.new(0, 4, 0), 14)
    v_(Ay.Position)
    local Ay_1 = os.clock() + u8
    while true do
        local Az_4 = uK() and os.clock() < Ay_1
        local AJ = if Az_4 then 1 else 0
        local AH = 3586 * AJ + 2172 * (1 - AJ)
        local AI = 2010 * AJ + 3668 * (1 - AJ)
        if not ((AH * 3738 + AI * 1292 + AH * AI) % 16777213 == 6432035) then
            u2[u_] = os.clock() + u3
            return false
        end
        Az_5, AA_3 = uG()
        local Az_6 = AA_3 and uR(AA_3.Position)
        if Az_6 then
            break
        end
        task.wait(0.15)
    end
    return true
end
local function fn982(jO)
    local Dt = jO and true or false
    State.AutoEquipBest = Dt
    if State.AutoEquipBest then
        if not v6() then
            State.AutoEquipBest = false
            return
        end
        vN("Equip", vq, vr)
    else
        v9("Equip")
    end
end
local function fn990(jJ)
    local Dq = jJ and true or false
    State.AutoHatchEgg = Dq
    if State.AutoHatchEgg then
        if not wg() then
            State.AutoHatchEgg = false
            return
        end
        vN("Hatch", vw, uH)
    else
        v9("Hatch")
    end
end
local function fn1018(js)
    local Dd = type(js) == "string" and js
    local De = Dd or "Nearest"
    State.Priority = De
end
local function fn1033()
    local Cb = not State.AutoEquipBest or not v6()
    if Cb then
        return
    end
    pcall(vo("equipBestPets"))
end
local function fn1074()
    local xI = wf ~= nil
    local xJ = vo("trailAction") ~= nil and xI
    return xJ
end
local function fn1104(fe)
    if State.StealZoneCount == 0 then
        return true
    end
    return fe.Biome ~= nil and State.StealZones[fe.Biome] == true
end
local function fn1108(gL, gM)
    local Surface = gL.Surface
    local Bo = uZ.plot.surfacePadding or 3
    local Bo_1 = uZ.plot.minimumSpacing or 5
    local Bo_2 = uZ.plot.placeRange or 55
    local Bs = uZ.plot.autoPlace and uZ.plot.autoPlace.gridStep or 2.5
    local Bs_1 = Surface.Size.X * 0.5 - Bo
    local Bt = Surface.Size.Z * 0.5 - Bo
    if Bs_1 <= 0 or Bt <= 0 then
        return nil
    end
    local Bp_2 = v1(gL)
    local Bu = Surface.Size.Y * 0.5
    local Bv = -Bs_1
    while Bv <= Bs_1 do
        local Bw = -Bt
        while Bw <= Bt do
            local Bx = Surface.CFrame:PointToWorldSpace(Vector3.new(Bv, Bu, Bw))
            if (Bx - gM).Magnitude <= Bo_2 then
                local By = true
                for i, v in ipairs(Bp_2) do
                    if Vector2.new(v.X - Bv, v.Z - Bw).Magnitude < Bo_1 then
                        By = false
                        break
                    end
                end
                if By then
                    return Bx
                end
            end
            Bw += Bs
        end
        Bv += Bs
    end
    return nil
end
local function fn1117()
    local w4 = tostring(State.Status)
    local w5 = State.Stolen or 0
    local w6 = State.Placed or 0
    local w7 = State.Claimed or 0
    return string.format("%s  |  stolen %d  |  placed %d  |  claimed %d", w4, w5, w6, w7)
end
local function fn1132()
    local xR = {}
    if not u5() then
        table.insert(xR, "steal")
    end
    if not uQ() then
        table.insert(xR, "placing")
    end
    if not wg() then
        table.insert(xR, "hatching")
    end
    if not v6() then
        table.insert(xR, "equip best")
    end
    if not vW() then
        table.insert(xR, "playtime")
    end
    if not vJ() then
        table.insert(xR, "trails")
    end
    if not vx() then
        table.insert(xR, "plot upgrade")
    end
    if not vk() then
        table.insert(xR, "treadmill")
    end
    return xR
end
uG = nil
uH = nil
uI = nil
uJ = nil
uK = nil
uM = nil
uO = nil
uP = nil
uQ = nil
uR = nil
uS = nil
uT = nil
uU = nil
uV = nil
uX = nil
uY = nil
uZ = nil
u_ = nil
State = nil
u1 = nil
u2 = nil
u3 = nil
u4 = nil
u5 = nil
u6 = nil
u8 = nil
u9 = nil
ve = nil
vf = nil
vj = nil
vk = nil
vl = nil
vm = nil
vn = nil
vo = nil
vp = nil
vq = nil
vr = nil
local Players, uL, uN, uW, u7, va, vb, vc, vd, vg, vh, vi
vs = nil
vt = nil
LocalPlayer = nil
worker = nil
vw = nil
vx = nil
CollectionService = nil
vA = nil
vB = nil
vE = nil
vF = nil
vH = nil
vJ = nil
vM = nil
vN = nil
vO = nil
CoreGui = nil
vR = nil
vU = nil
vV = nil
vW = nil
vZ = nil
v_ = nil
v1 = nil
v2 = nil
v3 = nil
v6 = nil
v7 = nil
v8 = nil
v9 = nil
wa = nil
wc = nil
we = nil
local vz, vC, vD, Lighting, vI, vK, TeleportService, vQ, GuiService, vT, HttpService, vY, VirtualUser, v4, UserInputService, RunService, wd
wf = nil
wg = nil
wh = nil
wi = nil
local wn, ws
if not game:IsLoaded() then
    game.Loaded:Wait()
end
Players, RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, TeleportService, Lighting, vD, CollectionService, LocalPlayer, vl = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local wl = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
TeleportService = game:GetService("TeleportService")
Lighting = game:GetService("Lighting")
vD = game:GetService("Workspace")
CollectionService = game:GetService("CollectionService")
LocalPlayer = Players.LocalPlayer
local wk = "TempoStealAnAnimeEgg"
vl = fn638
if getgenv then
    getgenv().gethui = vl
end
u6, wd, v7, v2, vZ, vT, vQ, vM, vH, vE, vA, vw, vq, vn, vj, ve, vc, u8, u3, State, ws, wn, vz, uT, uK, uX = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if false and ((ws or vE) and (false and not ws)) or (6 and (false and ws) or (false or vq and not ws)) or not (false and ((ws or vE) and (false and not ws)) or (6 and (false and ws) or (false or vq and not ws))) then
    pcall(fn762)
    wn = function(u)
        local wR
        local wS
        local wQ
        wQ = nil
        wR = nil
        wS = nil
        local wT = u ~= ""
        local wU = type(u) == "string" and wT
        assert(wU, "A namespace is required")
        assert(type(getgenv) == "function", "getgenv is unavailable")
        wR = getgenv()
        assert(type(wR) == "table", "getgenv did not return a table")
        local wT_2 = wR[u]
        if wT_2 ~= nil then
            local wU_2 = type(wT_2) == "table" and type(wT_2.Unload) == "function"
            assert(wU_2, "Namespace is occupied")
            wT_2.Unload()
            assert(wR[u] == nil, "Previous instance did not release its namespace")
        end
        wS = {}
        wQ = { State = {}, Unloaded = false }
        wQ.Track = function(C)
            assert(type(C) == "function", "Cleanup must be callable")
            if wQ.Unloaded then
                C()
            else
                table.insert(wS, C)
            end
            return C
        end
        wQ.Unload = function()
            local wG_2
            local wF_2
            if wQ.Unloaded then
                return
            end
            wQ.Unloaded = true
            local wD = {}
            local wK = #wS
            local wJ = -1
            while false and wK <= 1 or true and wK >= 1 do
                local wL = wK
                local wE_2 = table.remove(wS, wL)
                wF_2, wG_2 = pcall(wE_2)
                if not wF_2 then
                    table.insert(wD, tostring(wG_2))
                end
                wK += wJ
            end
            table.clear(wQ.State)
            if #wD > 0 then
                error("Cleanup incomplete: " .. table.concat(wD, "; "), 0)
            end
            if wR[u] == wQ then
                wR[u] = nil
            end
        end
        wR[u] = wQ
        return wQ
    end
else
    pcall(fn762)
    vM = function(u)
        local wR
        local wS
        local wQ
        wQ = nil
        wR = nil
        wS = nil
        local wT = u ~= ""
        local wU = type(u) == "string" and wT
        assert(wU, "A namespace is required")
        assert(type(getgenv) == "function", "getgenv is unavailable")
        wR = getgenv()
        assert(type(wR) == "table", "getgenv did not return a table")
        local wT_1 = wR[u]
        if wT_1 ~= nil then
            local wU_1 = type(wT_1) == "table" and type(wT_1.Unload) == "function"
            assert(wU_1, "Namespace is occupied")
            wT_1.Unload()
            assert(wR[u] == nil, "Previous instance did not release its namespace")
        end
        wS = {}
        wQ = { State = {}, Unloaded = false }
        wQ.Track = function(C)
            assert(type(C) == "function", "Cleanup must be callable")
            if wQ.Unloaded then
                C()
            else
                table.insert(wS, C)
            end
            return C
        end
        wQ.Unload = function()
            local wG_1
            local wF_1
            if wQ.Unloaded then
                return
            end
            wQ.Unloaded = true
            local wD = {}
            local wK = #wS
            local wJ = -1
            while false and wK <= 1 or true and wK >= 1 do
                local wL = wK
                local wE_1 = table.remove(wS, wL)
                wF_1, wG_1 = pcall(wE_1)
                if not wF_1 then
                    table.insert(wD, tostring(wG_1))
                end
                wK += wJ
            end
            table.clear(wQ.State)
            if #wD > 0 then
                error("Cleanup incomplete: " .. table.concat(wD, "; "), 0)
            end
            if wR[u] == wQ then
                wR[u] = nil
            end
        end
        wR[u] = wQ
        return wQ
    end
end
vz = function(P, Q)
    local wX = type(P) == "table" and type(P.Track) == "function"
    assert(wX, "FeatureAPI required")
    local wX_1 = type(Q) == "table" and type(Q.OnUnload) == "function"
    assert(wX_1, "UI library required")
    assert(type(Q.Unload) == "function", "UI unload required")
    P.Track(function()
        if not Q.Unloaded then
            Q:Unload()
        end
    end)
    Q:OnUnload(function()
        P.Unload()
    end)
end
u6 = wn(wk)
uT = fn961
uK = fn437
local wq = fn450(wl)
if (v2 or uX) and 20 and (not uX and v2 or (uX or v2)) and (uX and uX and (uX or not uX) or false and (uX or false)) and not ((v2 or uX) and 20 and (not uX and v2 or (uX or v2)) and (uX and uX and (uX or not uX) or false and (uX or false))) then
    v7(wd)
    vD = 0.15
else
    wd = fn450(vD)
    v7 = 0.15
end
if (false and vT or (not vT or uT)) and (not uT or vT or (false or not uT)) and not ((false and vT or (not vT or uT)) and (not uT or vT or (false or not uT))) then
    vT = 20
else
    v2 = 20
end
vZ = 25
vT = 7
vQ = 1.6
vM = 8
vH = 12
vE = 0.4
vA = 4
vw = 3
vq = 8
vn = 10
vj = 8
ve = 6
vc = 12
u8 = 3
u3 = 20
State = u6.State
State.AutoSteal = false
State.AutoEquipBest = false
State.AutoPlaceEgg = false
State.AutoHatchEgg = false
State.AutoPlaytime = false
State.AutoBuyTrail = false
State.AutoUpgradePlot = false
State.AutoUpgradeTreadmill = false
State.StealZones = {}
State.StealRarities = {}
State.StealZoneCount = 0
State.StealRarityCount = 0
State.Priority = "Nearest"
State.Status = "Idle"
State.Stolen = 0
State.Placed = 0
State.Claimed = 0
uX = fn154
u6.GetStatus = fn1117
local function wj(aC, aD, aE)
    local xc_1
    if typeof(aC) ~= "Instance" then
        return nil
    end
    local xb = aC:FindFirstChild(aD)
    local xb_1
    if xb then
        return xb
    end
    xb_1, xc_1 = pcall(function()
        local w9 = aE or 10
        return aC:WaitForChild(aD, w9)
    end)
    if xb_1 then
        return xc_1
    end
    return nil
end
ws = wj(wq, "Modules", 20)
local wo = wj(LocalPlayer, "PlayerScripts", 20)
local wr = wj(wo, "Client", 20)
wj = wr and wr:FindFirstChild("Net")
u4 = fn555(wj)
wj = ws and ws:FindFirstChild("EggConfig")
uZ = fn555(wj)
wj = ws and ws:FindFirstChild("PlotConfig")
uP = fn555(wj)
wj = ws and ws:FindFirstChild("PlotMap")
uI = fn555(wj)
wj = ws and ws:FindFirstChild("TrailConfig")
wf = fn555(wj)
wj = ws and ws:FindFirstChild("PlotUpgradeConfig")
v3 = fn555(wj)
wj = ws and ws:FindFirstChild("TreadmillConfig")
vV = fn555(wj)
wj = ws and ws:FindFirstChild("PlaytimeRewardsConfig")
vO = fn555(wj)
wj = uZ and uZ.plot and uZ.plot.tag
wk = wj or "BankedAnimeEgg"
vF, vC = nil, nil
vF = wk
vC = "AnimeEgg"
wl = uZ and uZ.steal and uZ.steal.promptName
wj = wl or "Steal Egg"
vs, wi, uV, vU, we, wa, u7, u2, u_, vo, u5, uQ, wg, v6, vW, vJ, vx, vk, wc, vd, uS, vm, uG, vR, vI, uY, v_, vB, vf, uJ, v9, vN, v4, vK, vt, vg, uR, vb, uN, vY, uW, v8, u1, uL, uM, vh, v1, vi, worker, uH, vr, u9, vp, uU, va, wh, uO = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
vs = wj
vo = fn272
u5 = fn864
uQ = fn130
wg = fn190
v6 = fn183
vW = fn257
vJ = fn1074
vx = fn894
vk = fn410
u6.Support = fn1132
wi = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Legacy" }
wc = fn441
vd = fns.fn115
uV = {}
if (not vo and not vR or (vo or vR)) and (vo and v4 or (v4 or vo)) and (uQ or vR or (not vR or vR) or (not v4 and not vo or vR and v4)) or not ((not vo and not vR or (vo or vR)) and (vo and v4 or (v4 or vo)) and (uQ or vR or (not vR or vR) or (not v4 and not vo or vR and v4))) then
    uS = fn777
    u6.RarityValues = fn684
    u6.ZoneValues = fn780
    vm = fn119
else
    vm = fn777
    uS.RarityValues = fn684
    uS.ZoneValues = fn780
    u6 = fn119
end
uG = fn630
vU = 0
vR = fn817
vI = fn960
uY = fn125
v_ = function(cY)
    if not uT(LocalPlayer.RequestStreamAroundAsync) then
        return
    end
    pcall(function()
        LocalPlayer:RequestStreamAroundAsync(cY)
    end)
end
vB = fn399
vf = fn273
uJ = fn814
we = {}
v9 = fn421
vN = function(dq, dr, ds)
    v9(dq)
    local dv
    dv = task.spawn(function()
        local zn_1
        while true do
            local zm = uK() and we[dq] == dv
            local zm_1
            if zm then
                zm_1, zn_1 = pcall(ds)
                if not zm_1 then
                    warn("[Tempo] " .. dq .. ": " .. tostring(zn_1))
                end
                task.wait(dr)
                continue
            end
            break
        end
    end)
    we[dq] = dv
    u6.Track(function()
        v9(dq)
    end)
end
wa = {}
v4 = fn855
vK = fn868
vt = fn644
vg = fn290
if (wa and vW and (not vs and false) or (not vW or not vs) and (wa and not vs) or (va and not vs or (not wa or vW) or (vW and vW or false))) and not (wa and vW and (not vs and false) or (not vW or not vs) and (wa and not vs) or (va and not vs or (not wa or vW) or (vW and vW or false))) then
    vb = function(d4)
        local zJ_2
        local zG_2
        local zF_2
        local zI_3
        zG_2, zF_2 = nil, nil
        for i, v in ipairs(CollectionService:GetTagged(vC)) do
            local zQ = v
            local zH = zQ:IsA("Model") and zQ.Parent and not v4(zQ)
            local zH_6
            if zH then
                local zH_5 = zQ:GetAttribute("SpawnActive") == true and zQ:GetAttribute("Dropped") ~= true and vg(zQ)
                if zH_5 then
                    zH_6, zI_3 = pcall(function()
                        return zQ:GetPivot().Position
                    end)
                    if zH_6 then
                        local Magnitude = (zI_3 - d4).Magnitude
                        if State.Priority == "Highest Income" then
                            local zI_4 = tonumber(zQ:GetAttribute("IncomePerSecond")) or 0
                            zJ_2 = -zI_4
                        elseif State.Priority == "Rarest" then
                            zJ_2 = -vd(zQ:GetAttribute("Rarity"))
                        else
                            zJ_2 = Magnitude
                        end
                        if zF_2 == nil or zJ_2 < zF_2 then
                            zG_2, zF_2 = zQ, zJ_2
                        end
                    end
                end
            end
        end
        return zG_2
    end
    vY = fns.fn24
    uR = function(eu)
        local zZ_9
        if uT(fireproximityprompt) then
            local zZ_6 = pcall(fireproximityprompt, eu, 1)
            if zZ_6 then
                return true
            end
            pcall(function()
                eu:InputHoldBegin()
            end)
            if not zZ_9 then
                return false
            end
            local wait = task.wait
            local z__3 = eu.HoldDuration or 0
            wait(z__3 + 0.15)
            pcall(function()
                eu:InputHoldEnd()
            end)
            return true
        end
        zZ_9 = pcall(function()
            eu:InputHoldBegin()
        end)
        if not zZ_9 then
            return false
        end
        local wait = task.wait
        local z__4 = eu.HoldDuration or 0
        wait(z__4 + 0.15)
        pcall(function()
            eu:InputHoldEnd()
        end)
        return true
    end
    uN = fn701
else
    uR = function(d4)
        local zJ_1
        local zG_1
        local zF_1
        local zI_1
        zG_1, zF_1 = nil, nil
        for i, v in ipairs(CollectionService:GetTagged(vC)) do
            local zQ = v
            local zH = zQ:IsA("Model") and zQ.Parent and not v4(zQ)
            local zH_2
            if zH then
                local zH_1 = zQ:GetAttribute("SpawnActive") == true and zQ:GetAttribute("Dropped") ~= true and vg(zQ)
                if zH_1 then
                    zH_2, zI_1 = pcall(function()
                        return zQ:GetPivot().Position
                    end)
                    if zH_2 then
                        local Magnitude = (zI_1 - d4).Magnitude
                        if State.Priority == "Highest Income" then
                            local zI_2 = tonumber(zQ:GetAttribute("IncomePerSecond")) or 0
                            zJ_1 = -zI_2
                        elseif State.Priority == "Rarest" then
                            zJ_1 = -vd(zQ:GetAttribute("Rarity"))
                        else
                            zJ_1 = Magnitude
                        end
                        if zF_1 == nil or zJ_1 < zF_1 then
                            zG_1, zF_1 = zQ, zJ_1
                        end
                    end
                end
            end
        end
        return zG_1
    end
    vb = fns.fn24
    uN = function(eu)
        local zZ_4
        if uT(fireproximityprompt) then
            local zZ_1 = pcall(fireproximityprompt, eu, 1)
            if zZ_1 then
                return true
            end
            pcall(function()
                eu:InputHoldBegin()
            end)
            if not zZ_4 then
                return false
            end
            local wait = task.wait
            local z__1 = eu.HoldDuration or 0
            wait(z__1 + 0.15)
            pcall(function()
                eu:InputHoldEnd()
            end)
            return true
        end
        zZ_4 = pcall(function()
            eu:InputHoldBegin()
        end)
        if not zZ_4 then
            return false
        end
        local wait = task.wait
        local z__2 = eu.HoldDuration or 0
        wait(z__2 + 0.15)
        pcall(function()
            eu:InputHoldEnd()
        end)
        return true
    end
    vY = fn701
end
u7 = nil
u2 = {}
u_ = 0
uW = fn558
v8 = function()
    local Ah_1
    if u7 then
        return u7
    end
    local Main_Map = wd:FindFirstChild("Main Map")
    if not Main_Map then
        return {}
    end
    local Ae = {}
    for i, child in ipairs(Main_Map:GetChildren()) do
        local Ad_1 = tonumber(string.match(child.Name, "^Stage (%d+)$"))
        local Af = Ad_1 and child:FindFirstChild("Nest Spawns")
        local Af_2
        local Ag = Af or nil
        if Ag then
            local Ag_1 = uW(Ad_1)
            for i, child in ipairs(Ag:GetChildren()) do
                local Au = child
                Af_2, Ah_1 = pcall(function()
                    return Au:GetPivot().Position
                end)
                if Af_2 then
                    table.insert(Ae, { Position = Ah_1, Stage = Ad_1, Biome = Ag_1 })
                end
            end
        end
    end
    if #Ae > 0 then
        u7 = Ae
    end
    return Ae
end
u1 = fn1104
uL = fn980
uM = function()
    local AN
    local AP_1
    local AO = not State.AutoSteal
    local AO_1
    local AT = if AO then 1 else 0
    local AR = 1054 * AT + 3243 * (1 - AT)
    local AS = 241 * AT + 261 * (1 - AT)
    if not ((AR * 3015 + AS * 1758 + AR * AS) % 16777213 == 3855502) then
        AO = not u5()
    end
    if AO then
        return
    end
    AO_1, AP_1 = uG()
    if not AP_1 then
        return
    end
    if vt() then
        vI(vY)
        return
    end
    AN = uR(AP_1.Position)
    if not AN then
        vI(uL)
        return
    end
    vI(function()
        local AL_1
        local AK_1
        AK_1, AL_1 = pcall(function()
            return AN:GetPivot().Position
        end)
        if not AK_1 then
            vK(AN)
            return false
        end
        local AK_2 = AN:GetAttribute("DisplayName") or AN.Name
        uX("Stealing " .. tostring(AK_2))
        if not uY(AL_1 + Vector3.new(0, 3, 0), vT) then
            vK(AN)
            return false
        end
        v_(AL_1)
        if not AN.Parent then
            vK(AN)
            return false
        end
        local AK_3 = vb(AN)
        if not AK_3 then
            vK(AN)
            return false
        end
        uN(AK_3)
        local AK_4 = os.clock() + vQ
        while true do
            local AL_2 = uK() and os.clock() < AK_4 and not vt()
            if AL_2 then
                task.wait(0.1)
                continue
            end
            break
        end
        vK(AN)
        if not vt() then
            return false
        end
        State.Stolen = State.Stolen + 1
        return vY()
    end)
end
vh = fn485
v1 = function(gA)
    local Bf_1
    local Bd = {}
    for i, v in ipairs(CollectionService:GetTagged(vF)) do
        local Bm = v
        local Be = Bm:IsA("Model") and Bm:IsDescendantOf(gA.Root)
        local Be_1
        if Be then
            Be_1, Bf_1 = pcall(function()
                return Bm:GetPivot().Position
            end)
            if Be_1 then
                table.insert(Bd, gA.Surface.CFrame:PointToObjectSpace(Bf_1))
            end
        end
    end
    return Bd
end
vi = fn1108
worker = function()
    local BU
    local BV = not State.AutoPlaceEgg or not uQ()
    if BV then
        return
    end
    if #vh() == 0 then
        return
    end
    BU = vf()
    if not BU then
        return
    end
    vI(function()
        local BM_1
        if not uY(uJ(BU.Surface) + Vector3.new(0, 5, 0), 8) then
            return false
        end
        local BK = vo("placeEgg")
        for i, v in ipairs(vh()) do
            local BJ
            local BT = v
            local BL = not uK() or not State.AutoPlaceEgg
            local BL_1
            if BL then
                break
            end
            BL_1, BM_1, BJ = uG()
            if not BM_1 then
                break
            end
            local BL_2 = vi(BU, BM_1.Position)
            if not BL_2 then
                uX("Plot has no free spot")
                break
            end
            pcall(function()
                BJ:EquipTool(BT)
            end)
            task.wait(0.15)
            uX("Placing egg")
            local BM_2 = pcall(BK, BT:GetAttribute(uZ.plot.toolUidAttribute), BL_2)
            if BM_2 then
                State.Placed = State.Placed + 1
            end
            local wait = task.wait
            local BM_3 = uZ.plot.requestCooldown or 0.25
            wait(BM_3)
        end
        return true
    end)
end
uH = fn553
vr = fn1033
u9 = fn619
vp = fn912
uU = fn498
va = function(iw)
    local CT
    CT = nil
    local CU = vf()
    local CU_1
    local CV = not CU or typeof(CU.Root) ~= "Instance"
    local CV_1
    if CV then
        return nil
    end
    CT = CU.Root:FindFirstChild(iw, true)
    if not CT then
        return nil
    end
    CU_1, CV_1 = pcall(function()
        return CT:GetPivot().Position
    end)
    if not CU_1 then
        return nil
    end
    return CV_1
end
wh = function()
    local CY, CZ
    local C_ = not State.AutoUpgradePlot or not vx()
    if C_ then
        return
    end
    local C__1 = v3.clampLevel
    local C0 = tonumber(LocalPlayer:GetAttribute("BaseLevel")) or 1
    CZ = C__1(C0)
    local C__2 = v3.cost(CZ)
    local C0_1 = not C__2
    if not C0_1 then
        local C1 = (tonumber(LocalPlayer:GetAttribute("Cash")))
        local C5 = if C1 then 1 else 0
        local C3 = 3347 * C5 + 3851 * (1 - C5)
        local C4 = 2489 * C5 + 1614 * (1 - C5)
        if not ((C3 * 3155 + C4 * 2107 + C3 * C4) % 16777213 == 7357578) then
            C1 = 0
        end
        C0_1 = C1 < C__2
    end
    if C0_1 then
        return
    end
    CY = va(v3.signModel)
    if not CY then
        return
    end
    vI(function()
        uX("Upgrading plot")
        if not uY(CY + Vector3.new(0, 4, 0), vc) then
            return false
        end
        pcall(vo("plotUpgrade"), CZ)
        return true
    end)
end
if (not uV and false or not uV and uV) and (uN and uN or false) and (false or va or (false or uV) or (uV and va or (uV or false))) and not ((not uV and false or not uV and uV) and (uN and uN or false) and (false or va or (false or uV) or (uV and va or (uV or false)))) then
    vg = function()
        local C7, C8
        local C9 = not State.AutoUpgradeTreadmill or not vk()
        if C9 then
            return
        end
        local clampLevel = vV.clampLevel
        local Da = tonumber(LocalPlayer:GetAttribute("TreadmillLevel")) or 1
        C8 = clampLevel(Da)
        local C9_4 = vV.cost(C8)
        local Da_2 = not C9_4
        if not Da_2 then
            local Db = tonumber(LocalPlayer:GetAttribute("Cash")) or 0
            Da_2 = Db < C9_4
        end
        if Da_2 then
            return
        end
        C7 = va(vV.signModel)
        if not C7 then
            return
        end
        vI(function()
            uX("Upgrading treadmill")
            if not uY(C7 + Vector3.new(0, 4, 0), vc) then
                return false
            end
            pcall(vo("treadmillUpgrade"), C8)
            return true
        end)
    end
else
    uO = function()
        local C7, C8
        local C9 = not State.AutoUpgradeTreadmill or not vk()
        if C9 then
            return
        end
        local clampLevel = vV.clampLevel
        local Da = tonumber(LocalPlayer:GetAttribute("TreadmillLevel")) or 1
        C8 = clampLevel(Da)
        local C9_2 = vV.cost(C8)
        local Da_1 = not C9_2
        if not Da_1 then
            local Db = tonumber(LocalPlayer:GetAttribute("Cash")) or 0
            Da_1 = Db < C9_2
        end
        if Da_1 then
            return
        end
        C7 = va(vV.signModel)
        if not C7 then
            return
        end
        vI(function()
            uX("Upgrading treadmill")
            if not uY(C7 + Vector3.new(0, 4, 0), vc) then
                return false
            end
            pcall(vo("treadmillUpgrade"), C8)
            return true
        end)
    end
end
u6.SetStealZones = fns.fn7
u6.SetStealRarities = fns.fn13
u6.SetPriority = fn1018
u6.SetAutoSteal = fn326
u6.SetAutoPlaceEgg = fn618
u6.SetAutoHatchEgg = fn990
u6.SetAutoEquipBest = fn982
u6.SetAutoPlaytime = fn820
u6.SetAutoBuyTrail = fn185
u6.SetAutoUpgradePlot = fn637
u6.SetAutoUpgradeTreadmill = fn398
u6.PlaceNow = fns.fn27
u6.HatchNow = fn349
u6.EquipBestNow = fn319
wk = function()
    local Ic
    local Ib
    local onDiscord
    onDiscord = nil
    Ib = nil
    Ic = nil
    local SaveManager, H2, H3, Library, Toggles, H7, H8, ThemeManager, Options
    H2 = "Steal An Anime Egg"
    Ib = "https://discord.gg/K7Qxnxkk46"
    H3 = "https://discord.gg/K7Qxnxkk46"
    H7 = "https://tempohub.shop"
    Library = getgenv().Library
    ThemeManager = getgenv().ThemeManager
    SaveManager = getgenv().SaveManager
    Toggles = Library.Toggles
    Options = Library.Options
    vz(u6, Library)
    Ic = function(kk, kl)
        local DS = uT(setclipboard) and setclipboard
        local DT = DS
        if not DT then
            local DS_1 = uT(toclipboard) and toclipboard
            DT = DS_1 or nil
        end
        local DS_2 = DT
        if not DS_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local DT_1 = pcall(DS_2, kk)
        if DT_1 then
            Library:Notify(kl)
        else
            Library:Notify("Failed to copy")
        end
    end
    onDiscord = function()
        Ic(Ib, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = Ib, Copyable = true }, "|", H2, "|", "v0.4" },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(false)
    H8 = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "gamepad-2"),
        Player = Window:AddTab("Player", "person-standing"),
        Settings = Window:AddTab("Settings", "settings")
    }
    local function Id(kz)
        local DiscordGroup = kz:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    for k, v in H8 do
        if k ~= "Info" then
            Id(v)
        end
    end
    local function Ie_1()
        local lf
        local StealGroup = H8.Main:AddRightGroupbox("Steal", "egg")
        local Label = StealGroup:AddLabel(u6.GetStatus(), true)
        StealGroup:AddDivider()
        StealGroup:AddToggle("AutoSteal", {
            Text = "Auto Steal",
            Default = false,
            Tooltip = "Teleports to matching eggs, steals them and banks them at your plot.",
            Callback = function(kJ)
                u6.SetAutoSteal(kJ)
            end
        })
        StealGroup:AddDropdown("StealZones", {
            Text = "Zone Filter",
            Values = u6.ZoneValues(),
            Default = {},
            Multi = true,
            AllowNull = true,
            Expandable = true,
            Tooltip = "Only steal from these biomes. Leave empty to allow every biome.",
            Callback = function(kL)
                u6.SetStealZones(kL)
            end
        })
        StealGroup:AddDropdown("StealRarities", {
            Text = "Rarity Filter",
            Values = u6.RarityValues(),
            Default = {},
            Multi = true,
            AllowNull = true,
            Expandable = true,
            Tooltip = "Only steal these rarities. Leave empty to allow every rarity.",
            Callback = function(kN)
                u6.SetStealRarities(kN)
            end
        })
        StealGroup:AddDropdown("StealPriority", {
            Text = "Target Priority",
            Values = { "Nearest", "Highest Income", "Rarest" },
            Default = "Nearest",
            Tooltip = "Which matching egg to go for first.",
            Callback = function(kP)
                u6.SetPriority(kP)
            end
        })
        local PlotGroup = H8.Main:AddLeftGroupbox("Plot", "house")
        PlotGroup:AddToggle("AutoPlaceEgg", {
            Text = "Auto Place Egg",
            Default = false,
            Tooltip = "Places banked egg tools from your backpack onto a free spot of your plot.",
            Callback = function(kS)
                u6.SetAutoPlaceEgg(kS)
            end
        })
        PlotGroup:AddToggle("AutoHatchEgg", {
            Text = "Auto Hatch Egg",
            Default = false,
            Tooltip = "Hatches every placed egg as soon as it finishes growing.",
            Callback = function(kU)
                u6.SetAutoHatchEgg(kU)
            end
        })
        PlotGroup:AddToggle("AutoEquipBest", {
            Text = "Auto Equip Best",
            Default = false,
            Tooltip = "Keeps your strongest animes equipped.",
            Callback = function(kW)
                u6.SetAutoEquipBest(kW)
            end
        })
        PlotGroup:AddDivider()
        PlotGroup:AddToggle("AutoUpgradePlot", {
            Text = "Auto Upgrade Plot",
            Default = false,
            Tooltip = "Teleports to the plot sign and buys the next capacity upgrade once you can afford it.",
            Callback = function(kY)
                u6.SetAutoUpgradePlot(kY)
            end
        })
        PlotGroup:AddToggle("AutoUpgradeTreadmill", {
            Text = "Auto Upgrade Treadmill",
            Default = false,
            Tooltip = "Teleports to the treadmill sign and buys the next tier once you can afford it.",
            Callback = function(k_)
                u6.SetAutoUpgradeTreadmill(k_)
            end
        })
        PlotGroup:AddDivider()
        PlotGroup:AddButton({
            Text = "Place Eggs Now",
            Func = function()
                u6.PlaceNow()
            end
        })
        PlotGroup:AddButton({
            Text = "Hatch Now",
            Func = function()
                u6.HatchNow()
            end
        })
        PlotGroup:AddButton({
            Text = "Equip Best Now",
            Func = function()
                u6.EquipBestNow()
            end
        })
        local RewardsGroup = H8.Main:AddLeftGroupbox("Rewards", "gift")
        RewardsGroup:AddToggle("AutoPlaytime", {
            Text = "Auto Claim Playtime Rewards",
            Default = false,
            Tooltip = "Claims every playtime reward as soon as its timer unlocks.",
            Callback = function(k5)
                u6.SetAutoPlaytime(k5)
            end
        })
        RewardsGroup:AddToggle("AutoBuyTrail", {
            Text = "Auto Buy Trails",
            Default = false,
            Tooltip = "Buys every cash trail you can afford, cheapest first.",
            Callback = function(k7)
                u6.SetAutoBuyTrail(k7)
            end
        })
        lf = task.spawn(function()
            while not Library.Unloaded do
                pcall(function()
                    Label:SetText(u6.GetStatus())
                end)
                task.wait(0.25)
            end
        end)
        u6.Track(function()
            if coroutine.status(lf) ~= "dead" then
                pcall(task.cancel, lf)
            end
        end)
    end
    Ie_1()
    local function Id_1()
        local Ek
        local En
        local Eh
        local Ed
        Ed = nil
        Eh = nil
        Ek = nil
        En = nil
        local Label, Ee, Ef, Eg, Ei, Label2, Label3, Em, Eo
        Eh = function(lj)
            return (tostring(lj):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;"))
        end
        En = function(ll, lm)
            return string.format('<font color="%s">%s</font>', lm, Eh(ll))
        end
        Ei = function(lp, lq, lr)
            return string.format("<b>%s</b> %s %s", lp, En("-", "#5a6070"), En(lq, lr))
        end
        Eg = "#7fd47f"
        local Ep = "#8b93a3"
        local Eq = "#6ec1ff"
        Eo = "#e8a34d"
        local Er = u6.Support()
        local Es = #Er == 0 and "ready"
        local Et = Es or "limited: " .. table.concat(Er, ", ")
        Ef = "Unknown"
        pcall(function()
            local DZ_1
            local DY_1
            if uT(identifyexecutor) then
                DZ_1, DY_1 = identifyexecutor()
                local D_ = DZ_1 ~= ""
                local D0 = type(DZ_1) == "string" and D_
                if D0 then
                    local D__1 = type(DY_1) == "string" and DY_1 ~= "" and DZ_1 .. " " .. DY_1
                    Ef = D__1 or DZ_1
                end
            end
        end)
        Ek = os.clock()
        Ee = function()
            local D5 = math.floor(os.clock() - Ek)
            if D5 < 60 then
                return D5 .. "s"
            elseif D5 < 3600 then
                return string.format("%dm %ds", math.floor((D5) / (60)), D5 % 60)
            else
                return string.format("%dh %dm", math.floor((D5) / (3600)), math.floor((D5 % 3600) / (60)))
            end
        end
        local UserGroup = H8.Info:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(Ei("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, Eg), true)
        UserGroup:AddLabel(Ei("UserId", tostring(LocalPlayer.UserId), Eq), true)
        UserGroup:AddLabel(Ei("Executor", Ef .. "  " .. Et, Eg), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(Ei("Session", Ee(), Eo), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                Ic(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                Ic("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = H8.Info:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(Ei("Game", H2, Eq), true)
        Label2 = SessionGroup:AddLabel(Ei("Players", "0/0", Eg), true)
        Em = tostring(game.JobId)
        local Eq_1 = #Em > 18 and string.sub(Em, 1, 18) .. "..."
        local Es_2 = Eq_1 or Em
        SessionGroup:AddLabel(Ei("Job", Es_2, Ep), true)
        Label = SessionGroup:AddLabel(Ei("Ping", "0 ms", Eo), true)
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
                Ic(Em, "Copied Job ID")
            end
        })
        Ed = task.spawn(function()
            local D8_1
            local D7_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(Ei("Session", Ee(), Eo))
                Label2:SetText(Ei("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), Eg))
                D7_1, D8_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local D7_2 = D7_1 and D8_1 .. " ms" or "n/a"
                Label:SetText(Ei("Ping", D7_2, Eo))
            end
        end)
        u6.Track(function()
            if coroutine.status(Ed) ~= "dead" then
                pcall(task.cancel, Ed)
            end
        end)
        local SocialsGroup = H8.Info:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                Ic(H3, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                Ic(H7, "Copied website link")
            end
        })
    end
    Id_1()
    local function Id_2()
        local mF
        local mD
        local mE
        local mC
        local MovementGroup = H8.Player:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = H8.Player:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        mE = {}
        local mB = {}
        mF = {}
        mD = {}
        mC = {}
        local function mG()
            for k, v in mC do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(mC)
        end
        local function mK()
            for k, v in mD do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(mD)
        end
        local function mO()
            for k, v in mE do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(mE)
        end
        local function mS(mT)
            if not mT:IsA("ProximityPrompt") then
                return
            end
            if mF[mT] == nil then
                mF[mT] = {
                    HoldDuration = mT.HoldDuration,
                    MaxActivationDistance = mT.MaxActivationDistance,
                    RequiresLineOfSight = mT.RequiresLineOfSight
                }
            end
            mT.HoldDuration = 0
            mT.MaxActivationDistance = 50
            mT.RequiresLineOfSight = false
        end
        local function mV()
            for k, v in mF do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(mF)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                mO()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                mK()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                mG()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for k, v in vD:QueryDescendants("ProximityPrompt") do
                    pcall(mS, v)
                end
            else
                mV()
            end
        end)
        table.insert(mB, vD.DescendantAdded:Connect(function(nd)
            if Toggles.InstantProximityPrompt.Value then
                mS(nd)
            end
        end))
        table.insert(mB, RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for k, v in Character:QueryDescendants("BasePart") do
                    if mC[v] == nil then
                        mC[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end))
        table.insert(mB, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local Fl = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and Fl then
                Fl:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(mB, RunService.RenderStepped:Connect(function(nz)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local Fr = Character and Character:FindFirstChildOfClass("Humanoid")
            local Fs = Character
            if Fs then
                Fs = Character:FindFirstChild("HumanoidRootPart")
            end
            local Fq_1 = Fs
            local CurrentCamera = vD.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and Fr then
                if mD[Fr] == nil then
                    mD[Fr] = Fr.WalkSpeed
                end
                Fr.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and Fq_1 and Fr and CurrentCamera then
                if mE[Fr] == nil then
                    mE[Fr] = Fr.PlatformStand
                end
                Fr.PlatformStand = true
                local Fs_4 = Vector3.zero
                if not UserInputService:GetFocusedTextBox() then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        Fs_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        Fs_4 -= CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        Fs_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        Fs_4 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        Fs_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        Fs_4 -= Vector3.new(0, 1, 0)
                    end
                end
                Fq_1.AssemblyLinearVelocity = Vector3.zero
                if Fs_4.Magnitude > 0 then
                    Fq_1.CFrame = Fq_1.CFrame + Fs_4.Unit * Options.FlySpeed.Value * nz
                end
            end
        end))
        u6.Track(function()
            for k, v in mB do
                v:Disconnect()
            end
            mG()
            mK()
            mO()
            mV()
        end)
    end
    Id_2()
    local function Id_3()
        local Label, GM, GN, GO, GP, GQ, GR, GS, GT, GU, GV, GW, GX, GY
        GM = {}
        GU = {}
        GR = nil
        GS = 0
        GW = false
        GO = 0
        GX = os.clock()
        local MenuGroup = H8.Settings:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        GP = function()
            local CurrentCamera
            CurrentCamera = vD.CurrentCamera
            local FK = not CurrentCamera or not uT(VirtualUser.CaptureController)
            local FO = if FK then 1 else 0
            local FM = 1174 * FO + 1959 * (1 - FO)
            local FN = 1935 * FO + 486 * (1 - FO)
            if not ((FM * 456 + FN * 409 + FM * FN) % 16777213 == 3598449) then
                FK = not uT(VirtualUser.ClickButton2)
            end
            if FK then
                return false
            end
            local FK_1 = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            end)
            if not FK_1 then
                return false
            end
            GS += 1
            GX = os.clock()
            pcall(function()
                Label:SetText("AFK triggers: " .. GS)
            end)
            return true
        end
        GY = function(oi)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not oi)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not oi
                end
            end)
            if not oi then
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
        GV = function(oB)
            local FT = oB.ClassName == "ParticleEmitter" or oB.ClassName == "Trail"
            local FX = if FT then 1 else 0
            local FV = 1655 * FX + 3655 * (1 - FX)
            local FW = 3182 * FX + 2769 * (1 - FX)
            if not ((FV * 3372 + FW * 3179 + FV * FW) % 16777213 == 4185235) then
                FT = oB.ClassName == "Smoke"
            end
            if not FT then
                FT = oB.ClassName == "Fire"
            end
            if not FT then
                FT = oB.ClassName == "Sparkles"
            end
            if not FT then
                FT = oB.ClassName == "Explosion"
            end
            if not FT then
                FT = oB.ClassName == "Beam"
            end
            if FT then
                if GM[oB] == nil then
                    GM[oB] = oB.Enabled
                end
                pcall(function()
                    oB.Enabled = false
                end)
            end
        end
        GT = function()
            for k, v in GM do
                local F1 = k
                local F3 = v
                if F1.Parent then
                    pcall(function()
                        F1.Enabled = F3
                    end)
                end
            end
            table.clear(GM)
            if GR then
                pcall(function()
                    settings().Rendering.QualityLevel = GR.Quality
                end)
                Lighting.GlobalShadows = GR.Shadows
                Lighting.FogEnd = GR.Fog
                GR = nil
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(oQ)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not oQ)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(oV)
                if oV then
                    if not GR then
                        GR = {
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
                    for k, v in vD:QueryDescendants("ParticleEmitter,Trail,Smoke,Fire,Sparkles,Beam") do
                        pcall(GV, v)
                    end
                else
                    GT()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        GY(true)
        local ScriptGroup = H8.Settings:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiGameplayPause:OnChanged(function()
            GY(Toggles.AntiGameplayPause.Value)
        end)
        if Toggles.AntiGameplayPause.Value then
            GY(true)
        end
        table.insert(GU, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                GP()
            end
        end))
        table.insert(GU, vD.DescendantAdded:Connect(function(pd)
            if Toggles.FpsBoost.Value then
                GV(pd)
            end
        end))
        GQ = function(ph)
            if GW or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            GW = true
            local Gm = GO
            local Gn_1 = pcall(function()
                if ph then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not Gn_1 then
                GW = false
                if not ph and Gm == GO then
                    task.delay(1.5, function()
                        if Gm == GO then
                            GQ(true)
                        end
                    end)
                end
            end
        end
        table.insert(GU, TeleportService.TeleportInitFailed:Connect(function(pz)
            local Gr
            if pz == LocalPlayer and GW then
                GW = false
                Gr = GO
                task.delay(3, function()
                    if Gr == GO then
                        GQ(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local Gw = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            local Gw_1 = not Gw
            local Gx = Library.Unloaded
            local GB = if Gx then 1 else 0
            local Gz = 3939 * GB + 726 * (1 - GB)
            local GA = 799 * GB + 478 * (1 - GB)
            if not ((Gz * 863 + GA * 2412 + Gz * GA) % 16777213 == 8473806) then
                Gx = Gw_1
            end
            if Gx then
                return
            end
            table.insert(GU, Gw.ChildAdded:Connect(function(pO)
                if pO.Name == "ErrorPrompt" then
                    GQ(false)
                end
            end))
        end)
        GN = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    GY(true)
                end
                local GC = Toggles.AntiAfk.Value and os.clock() - GX >= 60
                if GC then
                    GP()
                end
                task.wait(1)
            end
        end)
        u6.Track(function()
            GO += 1
            for k, v in GU do
                v:Disconnect()
            end
            pcall(task.cancel, GN)
            GY(false)
            GT()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    Id_3()
    local function Id_4()
        local HT, HU, HV, HW
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("MyScriptHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(H8.Settings)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/StealAnAnimeEgg")
        local HX = SaveManager:BuildConfigSection(H8.Settings)
        HV = function(qe, qf)
            local G4_1 = (qe == "Toggle" and Toggles or Options)[qf]
            local G3_2 = type(G4_1) == "table" and G4_1.Type == qe
            return G3_2 and G4_1 or nil
        end
        HT = function(qo, qp)
            local Type = qp.Type
            if Type == "Toggle" then
                return { idx = qo, type = "Toggle", value = qp.Value == true }
            elseif Type == "Slider" then
                return { idx = qo, type = "Slider", value = tostring(qp.Value) }
            elseif Type == "Dropdown" then
                return { idx = qo, type = "Dropdown", multi = qp.Multi == true, value = qp.Value }
            elseif Type == "Input" then
                local G8 = qp.Value or ""
                return { idx = qo, type = "Input", text = tostring(G8) }
            elseif Type == "ColorPicker" then
                return { idx = qo, type = "ColorPicker", value = qp.Value:ToHex(), transparency = qp.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = qo,
                    type = "KeyPicker",
                    mode = qp.Mode,
                    key = qp.Value,
                    modifiers = qp.Modifiers,
                    toggled = qp.Toggled
                }
            else
                return nil
            end
        end
        HW = function()
            local He = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local Hf = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if Hf then
                        local Hf_1 = HT(k, v)
                        if Hf_1 then
                            He[#He + 1] = Hf_1
                        end
                    end
                end
            end
            table.sort(He, function(qz, qA)
                if qz.type ~= qA.type then
                    return qz.type < qA.type
                end
                return qz.idx < qA.idx
            end)
            return { objects = He }
        end
        HU = function(qC)
            local Hv
            Hv = nil
            local Hw = type(qC) ~= "table" or type(qC.idx) ~= "string" or type(qC.type) ~= "string" or SaveManager.Ignore[qC.idx]
            if Hw then
                return false
            end
            Hv = HV(qC.type, qC.idx)
            if not Hv then
                return false
            end
            local Hw_1 = pcall(function()
                if qC.type == "Input" then
                    if type(qC.text) ~= "string" then
                        return
                    end
                    Hv:SetValue(qC.text)
                elseif qC.type == "ColorPicker" then
                    Hv:SetValueRGB(Color3.fromHex(qC.value), qC.transparency)
                elseif qC.type == "KeyPicker" then
                    Hv:SetValue({ qC.key, qC.mode, qC.modifiers })
                    if qC.mode == "Toggle" and qC.toggled ~= nil then
                        Hv.Toggled = qC.toggled
                        Hv:Update()
                    end
                else
                    Hv:SetValue(qC.value)
                end
            end)
            return Hw_1
        end
        HX:AddDivider()
        HX:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        HX:AddButton("Export Config to Clipboard", function()
            local Hz_1
            local Hy_1
            Hy_1, Hz_1 = pcall(HttpService.JSONEncode, HttpService, HW())
            if Hy_1 then
                local Hy_2 = uT(setclipboard) and setclipboard
                local HA = Hy_2
                if not HA then
                    local Hy_3 = uT(toclipboard) and toclipboard
                    HA = Hy_3 or nil
                end
                local Hy_4 = HA
                local HA_1 = type(Hy_4) == "function" and pcall(Hy_4, Hz_1)
                if HA_1 then
                    Library:Notify("Config copied to clipboard", 6)
                    return
                end
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Failed to encode the config")
        end)
        HX:AddButton("Import Config from Clipboard Text", function()
            local HI_1
            local HG = Options.SaveManager_ImportSource.Value or ""
            local HG_1
            local HH = tostring(HG):match("^%s*(.-)%s*$")
            if HH == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            if #HH > 262144 then
                Library:Notify("That config is too large")
                return
            end
            HG_1, HI_1 = pcall(HttpService.JSONDecode, HttpService, HH)
            local HH_1 = not HG_1 or type(HI_1) ~= "table" or type(HI_1.objects) ~= "table"
            if HH_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            if #HI_1.objects > 2048 then
                Library:Notify("That config has too many records")
                return
            end
            local HG_2 = 0
            for i, v in ipairs(HI_1.objects) do
                if HU(v) then
                    HG_2 += 1
                end
            end
            if HG_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local HI_2 = HG_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(HG_2, HI_2), 6)
        end)
        ThemeManager:LoadDefault()
        SaveManager:LoadAutoloadConfig()
        if Options.StealZones then
            u6.SetStealZones(Options.StealZones.Value)
        end
        if Options.StealRarities then
            u6.SetStealRarities(Options.StealRarities.Value)
        end
        if Options.StealPriority then
            u6.SetPriority(Options.StealPriority.Value)
        end
        if Toggles.AutoPlaceEgg then
            u6.SetAutoPlaceEgg(Toggles.AutoPlaceEgg.Value)
        end
        if Toggles.AutoHatchEgg then
            u6.SetAutoHatchEgg(Toggles.AutoHatchEgg.Value)
        end
        if Toggles.AutoEquipBest then
            u6.SetAutoEquipBest(Toggles.AutoEquipBest.Value)
        end
        if Toggles.AutoUpgradePlot then
            u6.SetAutoUpgradePlot(Toggles.AutoUpgradePlot.Value)
        end
        if Toggles.AutoUpgradeTreadmill then
            u6.SetAutoUpgradeTreadmill(Toggles.AutoUpgradeTreadmill.Value)
        end
        if Toggles.AutoPlaytime then
            u6.SetAutoPlaytime(Toggles.AutoPlaytime.Value)
        end
        if Toggles.AutoBuyTrail then
            u6.SetAutoBuyTrail(Toggles.AutoBuyTrail.Value)
        end
        if Toggles.AutoSteal then
            u6.SetAutoSteal(Toggles.AutoSteal.Value)
        end
        if Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    Id_4()
end
wk()
end)(...)

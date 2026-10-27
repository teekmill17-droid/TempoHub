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
getgenv().TempoHoodSubtitle = "SAVE ANIMALS!"
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
local i7
local iP
local iw
local jd
local iV
local VirtualUser
local Entities
local iI
local jp
local i6
local Bases2
local jv
local iv
local jc
local iU
local connection
local DataService
local iH
local i5
local iN
local ju
local iu
local CollectionService
local Rarities
local iA
local jh
local iZ
local iG
local RemoteBank
local LocalPlayer
local iM
local jt
local it
local ja
local iS
local iz
local jg
local iY
local iF
local connection2
local i3
local iL
local js
local is
local SharedFunctions
local iR
local iy
local jf
local Bases
local iE
local jl
local jr
local ir
local i8
local iQ
local Label
local je
local iW
local Library
local jk
local i1
local iJ
local Toggles
local function fn2(aH, aI)
    return string.format('<font color="%s">%s</font>', aI, aH)
end
local function onSellInterval(e3)
    iZ = e3
end
local function fn17()
    iQ = false
end
local function fn18(bA)
    local lj = Bases2:FindFirstChild(tostring(bA))
    local lk = lj and lj:FindFirstChild("Zone")
    return lk
end
local function onAutoRebirth(fh)
    iM = fh
end
local function fn31()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    ju = tick()
end
local function fn36()
    local ms = {}
    local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local Character = LocalPlayer.Character
    for i, v in ipairs({ Backpack, Character }) do
        if v then
            for i, child in ipairs(v:GetChildren()) do
                if child:IsA("Tool") then
                    ms[child] = true
                end
            end
        end
    end
    return ms
end
local function onRscripts()
    if setclipboard then
        setclipboard(iU)
    elseif toclipboard then
        toclipboard(iU)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function fn66()
    setclipboard(iY)
    Library:Notify("Copied Discord invite to clipboard")
end
local function onCopyJoinScript_JobID()
    local kW = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, ir)
    if setclipboard then
        setclipboard(kW)
    elseif toclipboard then
        toclipboard(kW)
    end
    Library:Notify("Copied join script to clipboard")
end
local function onCollectInterval(eb)
    je = eb
end
local function worker5()
    while not Library.Unloaded do
        local nH = iM and iG()
        if nH then
            pcall(function()
                RemoteBank.Rebirth:InvokeServer()
            end)
            task.wait(1)
        end
        task.wait(2)
    end
end
local function fn160()
    local k4 = {}
    local la = 1
    while la <= 11 do
        local lc = la
        local k5 = Bases[lc]
        local k6 = k5 and k5.BaseName and Bases2:FindFirstChild(tostring(lc))
        if k6 then
            k4[#k4 + 1] = lc .. " - " .. k5.BaseName
        end
        la += 1
    end
    return k4
end
local function fn173()
    iF = false
    autoReturnEnabled = false
    jl = false
    iM = false
    iE = false
    if connection then
        connection:Disconnect()
    end
    if connection2 then
        connection2:Disconnect()
    end
end
local function fn202(cb)
    local lU = os.clock()
    local lW = lU + (cb or 5)
    while true do
        local lU_1 = ja() and os.clock() < lW and not Library.Unloaded
        if lU_1 then
            task.wait(0.1)
            continue
        end
        break
    end
end
local function worker2()
    while not Library.Unloaded do
        if iF then
            if ja() then
                iL()
                pcall(iu)
                iz(5)
                jv()
            else
                local l5 = iN()
                local l6 = l5[1]
                if l6 then
                    iL()
                    jg(l6)
                    jv()
                else
                    task.wait(1)
                end
            end
        else
            task.wait(0.5)
        end
    end
end
local function onCollectPriority(d9)
    jh = d9
end
local function onSellFromRanch(eZ)
    iV = eZ
end
local function onAutoCollectCash(d7)
    jl = d7
end
local function fn226()
    local kK = jf()
    local kL = kK and kK:FindFirstChild("TeleportPart")
    local kL_1 = iH()
    if kL and kL_1 then
        kL_1.CFrame = kL.CFrame + Vector3.new(0, 3, 0)
    end
end
local function worker3()
    while not Library.Unloaded do
        if jl then
            pcall(iI)
        end
        task.wait(je)
    end
end
local function onSaveBaseSelect(cF)
    iv = iW(cF)
end
local function fn266()
    for i, v in ipairs(i8()) do
        if not jl or Library.Unloaded then
            break
        end
        iL()
        i6(v.standId)
        jv()
        task.wait(0.05)
    end
end
local function fn273(cQ)
    local l8 = iA(cQ)
    local l9 = l8 and Rarities[l8]
    local l8_1 = l9
    if l9 then
        l9 = l8_1.Weight
    end
    return l9 or 0
end
local function fn275(bx)
    local lg = tonumber(string.match(tostring(bx), "^(%d+)"))
    return lg or 1
end
local function onInputBegan()
    it = tick()
end
local function onMaxUpgradeLevel(fH)
    iw = fH
end
local function fn330(cY)
    local mb = cY:GetAttribute("RanchCashBase") or 0
    local mb_1 = cY:GetAttribute("RanchEarningsPerSecond") or 0
    local mb_2 = cY:GetAttribute("RanchCashStartedAt") or workspace:GetServerTimeNow()
    local mb_3 = cY:GetAttribute("RanchOfflineEarnings") or 0
    return mb + mb_3 + mb_1 * math.floor(math.max(workspace:GetServerTimeNow() - mb_2, 0))
end
local function fn339(ab)
    local kA = Entities[ab]
    return kA and kA.Rarity
end
local function fn344(bF, bG)
    local lm = bF.CFrame:PointToObjectSpace(bG)
    local ln = bF.Size / 2
    local lo = math.abs(lm.X) <= ln.X and math.abs(lm.Y) <= ln.Y and math.abs(lm.Z) <= ln.Z
    return lo
end
local function onSellRarityFilter(e0)
    i5 = js(e0)
end
local function fn375()
    local kE_1
    local kD = jk and jk.Parent
    local kD_1
    if kD then
        return jk
    end
    kD_1, kE_1 = pcall(function()
        return RemoteBank.GetPlot:InvokeServer()
    end)
    local kF = kD_1 and typeof(kE_1) == "Instance"
    if kF then
        jk = kE_1
    end
    return jk
end
local function fn419()
    local mh = {}
    for i, v in ipairs(CollectionService:GetTagged("RanchEntity")) do
        if v:GetAttribute("RanchOwnerUserId") == LocalPlayer.UserId then
            local attr2 = v:GetAttribute("RanchSlotNumber")
            local attr = v:GetAttribute("EntityName")
            if attr2 and attr then
                mh[#mh + 1] = { standId = attr2, cash = iJ(v), rarity = jr(attr) }
            end
        end
    end
    if jh == "Lowest Money" then
        table.sort(mh, function(df, dg)
            return df.cash < dg.cash
        end)
    elseif jh == "Best Rarity Pet" then
        table.sort(mh, function(dd, de)
            return dd.rarity > de.rarity
        end)
    else
        table.sort(mh, function(da, db)
            return da.cash > db.cash
        end)
    end
    return mh
end
local function fn425(aB)
    local DiscordGroup = aB:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = iP })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = iP })
end
local function onAutoUpgradePets(fF)
    iE = fF
end
local function onInputChanged(fW)
    local UserInputType = fW.UserInputType
    local n4 = UserInputType == Enum.UserInputType.MouseMovement
    local n8 = if n4 then 1 else 0
    local n6 = 2966 * n8 + 2089 * (1 - n8)
    local n7 = 3496 * n8 + 3416 * (1 - n8)
    if not ((n6 * 958 + n7 * 2651 + n6 * n7) % 16777213 == 5701247) then
        n4 = UserInputType == Enum.UserInputType.Gamepad1
    end
    if n4 then
        it = tick()
    end
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local n9 = tick() - it
            local oa = tick() - ju
            if n9 >= 300 and oa >= 60 then
                pcall(i3)
            else
                if n9 < 300 and oa >= 300 then
                    pcall(i3)
                end
            end
        end
    end
end
local function onSaveRarityFilter(cI)
    iy = js(cI)
end
local function fn479()
    local nA = (DataService.client:get("rebirth"))
    local nG = if nA then 1 else 0
    local nE = 472 * nG + 446 * (1 - nG)
    local nF = 2896 * nG + 3395 * (1 - nG)
    if not ((nE * 2767 + nF * 3656 + nE * nF) % 16777213 == 13260712) then
        nA = 0
    end
    local nB = nA
    local nA_1 = DataService.client:get("cash") or 0
    return nA_1 >= SharedFunctions.GetRebirthGoalFromCount(nB)
end
local function worker6()
    while not Library.Unloaded do
        if iE then
            pcall(is)
        end
        task.wait(2)
    end
end
local function fn498()
    local Character = LocalPlayer.Character
    local ka = Character and Character:FindFirstChild("HumanoidRootPart")
    return ka
end
local function onUnload()
    Library:Unload()
end
local function fn539()
    local EntitiesFolder = workspace:FindFirstChild("EntitiesFolder")
    if not EntitiesFolder then
        return nil
    end
    for i, child in ipairs(EntitiesFolder:GetChildren()) do
        local lM_1 = child:IsA("Model") and child:GetAttribute("CarriedByUserId") == LocalPlayer.UserId
        if lM_1 then
            return child
        end
    end
    return nil
end
local function onAutoSellAnimals(eX)
    jd = eX
end
local function fn561()
    local kP_1
    local kO_1
    if identifyexecutor then
        kP_1, kO_1 = identifyexecutor()
        local kQ = kP_1 ~= ""
        local kR = type(kP_1) == "string" and kQ
        if kR then
            local kQ_1 = type(kO_1) == "string" and kO_1 ~= "" and kP_1 .. " " .. kO_1
            local kO_2 = kQ_1
            local kV = if kO_2 then 1 else 0
            local kT = 1796 * kV + 2472 * (1 - kV)
            local kU = 1203 * kV + 2411 * (1 - kV)
            if not ((kT * 3505 + kU * 2620 + kT * kU) % 16777213 == 11607428) then
                kO_2 = kP_1
            end
            jc = kO_2
        end
    end
end
local function fn580(K)
    return next(K) == nil
end
local function worker()
    local k1_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local k0 = math.floor(os.clock() - i1)
        if k0 < 60 then
            k1_1 = k0 .. "s"
        elseif k0 < 3600 then
            k1_1 = string.format("%dm %ds", math.floor((k0) / (60)), k0 % 60)
        else
            k1_1 = string.format("%dh %dm", math.floor((k0) / (3600)), math.floor((k0 % 3600) / (60)))
        end
        Label:SetText(iS("Session time", k1_1, jp))
    end
end
local function onAutoSaveAnimals(cD)
    iF = cD
end
local function fn597()
    local km = {}
    for k, v in pairs(Entities) do
        local kn_1 = type(v) == "table" and v.Rarity
        if kn_1 then
            km[v.Rarity] = true
        end
    end
    local kn_2 = {}
    for k in pairs(km) do
        kn_2[#kn_2 + 1] = k
    end
    table.sort(kn_2)
    return kn_2
end
local function fn635(ds)
    local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local Character = LocalPlayer.Character
    for i, v in ipairs({ Backpack, Character }) do
        if v then
            for i, child in ipairs(v:GetChildren()) do
                local mI_1 = child:IsA("Tool") and not ds[child]
                if mI_1 then
                    return child
                end
            end
        end
    end
    return nil
end
local function fn639()
    while iQ and not Library.Unloaded do
        task.wait()
    end
    iQ = true
end
local function worker4()
    while not Library.Unloaded do
        if jd then
            pcall(iR)
            if iV then
                pcall(jt)
            end
        end
        task.wait(1)
    end
end
local function fn657(aK, aL, aM)
    return string.format("<b>%s</b> %s %s", aK, i7("-", "#5a6070"), i7(aL, aM))
end
local function fn663(F)
    local kc = {}
    if type(F) == "table" then
        for k, v in pairs(F) do
            if v == true then
                kc[k] = true
            elseif type(v) == "string" then
                kc[v] = true
            end
        end
    end
    return kc
end
ir = nil
is = nil
it = nil
iu = nil
iv = nil
iw = nil
Label = nil
iy = nil
iz = nil
iA = nil
connection = nil
Library = nil
iE = nil
iF = nil
iG = nil
iH = nil
iI = nil
iJ = nil
iL = nil
iM = nil
iN = nil
Bases2 = nil
iP = nil
iQ = nil
iR = nil
iS = nil
Rarities = nil
iU = nil
iV = nil
iW = nil
Bases = nil
iY = nil
iZ = nil
Entities = nil
i1 = nil
i3 = nil
LocalPlayer = nil
i5 = nil
i6 = nil
i7 = nil
i8 = nil
SharedFunctions = nil
ja = nil
CollectionService = nil
jc = nil
jd = nil
local iC, iK, i_, i2
je = nil
jf = nil
jg = nil
jh = nil
DataService = nil
VirtualUser = nil
jk = nil
jl = nil
connection2 = nil
RemoteBank = nil
jp = nil
Toggles = nil
jr = nil
js = nil
jt = nil
ju = nil
jv = nil
local jo
local jK_1
local jF_1
local jA_1
local jC_1
local jy_1
VirtualUser, CollectionService, LocalPlayer, iY, iU, jA_1, Library = nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local jz_1
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
CollectionService = game:GetService("CollectionService")
LocalPlayer = Players.LocalPlayer
iY = "https://discord.gg/K7Qxnxkk46"
iU = "https://discord.gg/K7Qxnxkk46"
if ("Save Animals!" and (false or Library) or (not Library or false) and (UserInputService or 15)) and (UserInputService and not UserInputService or (UserInputService or jA_1) or ("Save Animals!" or jA_1 and UserInputService)) or not (("Save Animals!" and (false or Library) or (not Library or false) and (UserInputService or 15)) and (UserInputService and not UserInputService or (UserInputService or jA_1) or ("Save Animals!" or jA_1 and UserInputService))) then
    jA_1 = "Save Animals!"
end
Library = getgenv().Library
if not Library then
    return
end
Toggles, RemoteBank, DataService, SharedFunctions, Entities, Bases, Rarities, Bases2, iQ, jk, jF_1, iH, js, i_, iL, jv, iA, jf, iu, iP = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
local Options = Library.Options
Toggles = Library.Toggles
RemoteBank = require(ReplicatedStorage.RemoteBank)
DataService = require(ReplicatedStorage.Utilities.DataService)
SharedFunctions = require(ReplicatedStorage.DataModules.SharedFunctions)
Entities = require(ReplicatedStorage.DataModules.Entities)
Bases = require(ReplicatedStorage.DataModules.Bases)
Rarities = require(ReplicatedStorage.DataModules.Rarities)
Bases2 = workspace:WaitForChild("Map"):WaitForChild("Bases")
iH = fn498
js = fn663
i_ = fn580
iQ = false
iL = fn639
jv = fn17
iA = fn339
jf = fn375
iu = fn226
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = iY, Copyable = true }, "|", jA_1 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
if ((SharedFunctions or SharedFunctions) and (jk or jk) or (SharedFunctions and not jk or not iH and not SharedFunctions) or (not SharedFunctions or not jk) and (jk and SharedFunctions) and ((not jk or SharedFunctions) and (SharedFunctions or SharedFunctions))) and not ((SharedFunctions or SharedFunctions) and (jk or jk) or (SharedFunctions and not jk or not iH and not SharedFunctions) or (not SharedFunctions or not jk) and (jk and SharedFunctions) and ((not jk or SharedFunctions) and (SharedFunctions or SharedFunctions))) then
    local jx_1 = {
        Info = jF_1:AddTab("Info", "info"),
        Settings = jF_1:AddTab("Settings", "settings"),
        Main = jF_1:AddTab("Main", "paw-print")
    }
else
    jF_1 = {
        Info = Window:AddTab("Info", "info"),
        Main = Window:AddTab("Main", "paw-print"),
        Settings = Window:AddTab("Settings", "settings")
    }
end
if ((iH and false) or iP and Bases and (iH and not iH)) and not ((iH and false) or iP and Bases and (iH and not iH)) then
    iP.Saving = iP.Main:AddSubTab("Saving", "heart-handshake")
    iP.Ranch = iP.Main:AddSubTab("Ranch", "coins")
    jC_1 = fn66
    jF_1 = fn425
else
    jF_1.Saving = jF_1.Main:AddSubTab("Saving", "heart-handshake")
    jF_1.Ranch = jF_1.Main:AddSubTab("Ranch", "coins")
    iP = fn66
    jC_1 = fn425
end
for k, v in { jF_1.Saving, jF_1.Ranch, jF_1.Settings } do
    jC_1(v)
end
jK_1, jp, jc, jy_1, Label, ir, jz_1, i7, iS = nil, nil, nil, nil, nil, nil, nil, nil, nil
i7 = fn2
if false and not jy_1 or (jy_1 or false) or (jp or jy_1) and (not jy_1 and jy_1) or not (false and not jy_1 or (jy_1 or false) or (jp or jy_1) and (not jy_1 and jy_1)) then
    iS = fn657
end
local jw_1 = "#7fd47f"
if ((jy_1 or not Label) and (jy_1 and jy_1) or (jy_1 or Label) and (jy_1 or Label)) and (not Label and not jy_1 or Label and not Label or (not Label and jy_1 or jy_1 and not jy_1)) or ((not Label and Label or not jy_1 and jy_1) and (not jy_1 or not Label or (not jy_1 or not jy_1)) or (jy_1 or Label) and (not Label or not jy_1) and (jy_1 or not jy_1 or (not jy_1 or jy_1))) or not (((jy_1 or not Label) and (jy_1 and jy_1) or (jy_1 or Label) and (jy_1 or Label)) and (not Label and not jy_1 or Label and not Label or (not Label and jy_1 or jy_1 and not jy_1)) or ((not Label and Label or not jy_1 and jy_1) and (not jy_1 or not Label or (not jy_1 or not jy_1)) or (jy_1 or Label) and (not Label or not jy_1) and (jy_1 or not jy_1 or (not jy_1 or jy_1)))) then
    jK_1 = "#6ec1ff"
else
    i7 = "#6ec1ff"
end
jp = "#e8a34d"
local jJ = "#8b93a3"
jc = "Unknown"
pcall(fn561)
local AccountGroup = jF_1.Info:AddLeftGroupbox("Account", "circle-user")
AccountGroup:AddLabel(iS("User", LocalPlayer.Name, jw_1), true)
AccountGroup:AddLabel(iS("Status", "Keyless", jw_1), true)
AccountGroup:AddLabel(iS("Executor", jc, jw_1), true)
local GameInfoGroup = jF_1.Info:AddLeftGroupbox("Game Info", "gamepad-2")
GameInfoGroup:AddLabel(i7(jA_1 .. " [" .. tostring(game.PlaceId) .. "]", jK_1), true)
GameInfoGroup:AddLabel(iS("Place ID", tostring(game.PlaceId), jK_1), true)
Label = GameInfoGroup:AddLabel(iS("Session time", "0s", jp), true)
ir = tostring(game.JobId)
if (not i7 or i7 or not GameInfoGroup and not ir) and (GameInfoGroup or ir or GameInfoGroup and not GameInfoGroup) and ((not ir and not GameInfoGroup or i7 and ir) and (i7 and not ir or (GameInfoGroup or GameInfoGroup))) or ((not ir or ir) and (not i7 and i7) and (GameInfoGroup and i7 or (GameInfoGroup or GameInfoGroup)) or ((not i7 or ir) and (GameInfoGroup and not ir) or (ir or i7 or not GameInfoGroup and i7))) or not ((not i7 or i7 or not GameInfoGroup and not ir) and (GameInfoGroup or ir or GameInfoGroup and not GameInfoGroup) and ((not ir and not GameInfoGroup or i7 and ir) and (i7 and not ir or (GameInfoGroup or GameInfoGroup))) or ((not ir or ir) and (not i7 and i7) and (GameInfoGroup and i7 or (GameInfoGroup or GameInfoGroup)) or ((not i7 or ir) and (GameInfoGroup and not ir) or (ir or i7 or not GameInfoGroup and i7)))) then
    jz_1 = #ir > 18
else
    ir = #jz_1 > 18
end
if jz_1 then
    local jw_2 = 2
    repeat
        if (jw_2 * 2 + 9) * 4 % 3 == ((jw_2 * 2 + 9) * 4 + 4) % 3 then
            ir = string.sub(jz_1, 1, 18) .. "..."
        else
            jz_1 = string.sub(ir, 1, 18) .. "..."
        end
        jw_2 = (jw_2 + 7) % 8
    until (jw_2 * 5 + 0) % 8 == 5
end
local jw_3 = jz_1
local j2 = if jw_3 then 1 else 0
local j0 = 1297 * j2 + 2315 * (1 - j2)
local j1 = 2792 * j2 + 521 * (1 - j2)
if not ((j0 * 3268 + j1 * 1364 + j0 * j1) % 16777213 == 11668108) then
    jw_3 = ir
end
i1, iF, iy, iv, jh, jl, je, jd, i5, iZ, iV, iM, iE, iw, it, ju, connection, connection2, iW, iC, jo, iN, ja, iz, jg, jr, iJ, i8, iK, i2, i6, iI, iR, jt, iG, is, i3 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local jS = jw_3
GameInfoGroup:AddLabel(iS("Server", jS, jJ), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
i1 = os.clock()
task.spawn(worker)
local ScriptsGroup = jF_1.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(i7("Included in this hub", jJ), true)
ScriptsGroup:AddLabel(i7(jA_1, jK_1), true)
local FeaturesGroup = jF_1.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(i7("Auto Save Animals", jK_1), true)
FeaturesGroup:AddLabel(i7("Auto Collect Money from Pets", jp), true)
FeaturesGroup:AddLabel(i7("Auto Sell Animals", jp), true)
FeaturesGroup:AddLabel(i7("Auto Rebirth", jp), true)
FeaturesGroup:AddLabel(i7("Auto Upgrade Pets", jp), true)
FeaturesGroup:AddLabel(i7("Misc Utilities", jJ), true)
local SocialsGroup = jF_1.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = iP })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = jF_1.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = iP })
local FaqGroup = jF_1.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutoSaveAnimalsGroup = jF_1.Saving:AddLeftGroupbox("Auto Save Animals")
local FiltersGroup = jF_1.Saving:AddRightGroupbox("Filters")
iF = false
iy = {}
iv = 1
iW = fn275
iC = fn18
jo = fn344
iN = function()
    local lu_1
    local lq = {}
    local lr = iC(iv)
    if not lr then
        return lq
    end
    local EntitiesFolder = workspace:FindFirstChild("EntitiesFolder")
    if not EntitiesFolder then
        return lq
    end
    for i, child in ipairs(EntitiesFolder:GetChildren()) do
        local ls_1 = i_(iy) or iy[iA(child.Name)]
        if ls_1 then
            for i, child in ipairs(child:GetChildren()) do
                local lI = child
                local ProximityPrompt = lI:FindFirstChild("ProximityPrompt")
                local lt = ProximityPrompt and ProximityPrompt.Enabled and string.find(ProximityPrompt.ActionText, "Steal", 1, true)
                local lt_1
                if lt then
                    lt_1, lu_1 = pcall(function()
                        return lI:GetPivot()
                    end)
                    local lv = lt_1 and jo(lr, lu_1.Position)
                    if lv then
                        lq[#lq + 1] = { model = lI, prompt = ProximityPrompt }
                    end
                end
            end
        end
    end
    return lq
end
if (not TempoHubGroup and fn160 and (not TempoHubGroup and not TempoHubGroup) or (fn160 or iR) and (not TempoHubGroup and not iR)) and (not TempoHubGroup or iR or (false or not TempoHubGroup) or (TempoHubGroup or not iR or (iR or fn160))) or not ((not TempoHubGroup and fn160 and (not TempoHubGroup and not TempoHubGroup) or (fn160 or iR) and (not TempoHubGroup and not iR)) and (not TempoHubGroup or iR or (false or not TempoHubGroup) or (TempoHubGroup or not iR or (iR or fn160)))) then
    ja = fn539
    iz = fn202
    jg = function(ch)
        local lZ_2
        local lY = ch.model.Parent and ch.prompt.Parent and ch.prompt.Enabled
        local lY_3
        if not lY then
            return
        end
        lY_3, lZ_2 = pcall(function()
            return ch.model:GetPivot()
        end)
        local l_ = iH()
        if not (lY_3 and l_) then
            return
        end
        l_.CFrame = lZ_2 + Vector3.new(0, 3, 0)
        task.wait(0.1)
        if ch.prompt.Parent and ch.prompt.Enabled then
            pcall(function()
                fireproximityprompt(ch.prompt)
            end)
            task.wait(math.max(ch.prompt.HoldDuration + 0.05, 0.1))
            pcall(iu)
            iz(5)
        end
    end
else
    jg = fn539
    ja = fn202
    iz = function(ch)
        local lZ_1
        local lY = ch.model.Parent and ch.prompt.Parent and ch.prompt.Enabled
        local lY_1
        if not lY then
            return
        end
        lY_1, lZ_1 = pcall(function()
            return ch.model:GetPivot()
        end)
        local l_ = iH()
        if not (lY_1 and l_) then
            return
        end
        l_.CFrame = lZ_1 + Vector3.new(0, 3, 0)
        task.wait(0.1)
        if ch.prompt.Parent and ch.prompt.Enabled then
            pcall(function()
                fireproximityprompt(ch.prompt)
            end)
            task.wait(math.max(ch.prompt.HoldDuration + 0.05, 0.1))
            pcall(iu)
            iz(5)
        end
    end
end
task.spawn(worker2)
AutoSaveAnimalsGroup:AddToggle("AutoSaveAnimals", { Text = "Auto Save Animals", Default = false, Callback = onAutoSaveAnimals })
AutoSaveAnimalsGroup:AddDropdown("SaveBaseSelect", {
    Text = "Base to Steal From",
    Values = fn160(),
    Multi = false,
    Default = 1,
    Searchable = true,
    Callback = onSaveBaseSelect
})
FiltersGroup:AddDropdown("SaveRarityFilter", {
    Text = "Rarity Filter",
    Values = fn597(),
    Multi = true,
    Default = {},
    Searchable = true,
    Callback = onSaveRarityFilter
})
local AutoCollectMoneyFromPetsGroup = jF_1.Ranch:AddLeftGroupbox("Auto Collect Money from Pets")
local AutoSellAnimalsGroup = jF_1.Ranch:AddLeftGroupbox("Auto Sell Animals")
local AutoRebirthGroup = jF_1.Ranch:AddRightGroupbox("Auto Rebirth")
local AutoUpgradePetsGroup = jF_1.Ranch:AddRightGroupbox("Auto Upgrade Pets")
jr = fn273
iJ = fn330
jh = "Most Money"
i8 = fn419
iK = fn36
i2 = fn635
jl = false
je = 5
i6 = function(dE)
    local mZ = iK()
    pcall(function()
        RemoteBank.PickupStand:InvokeServer(dE)
    end)
    local mX
    local m2 = 1
    while m2 <= 20 do
        task.wait(0.05)
        mX = i2(mZ)
        if mX then
            break
        end
        m2 += 1
    end
    if not mX then
        return
    end
    local mZ_1 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local mY = mZ_1
    if mY then
        pcall(function()
            mY:EquipTool(mX)
        end)
        task.wait(0.1)
    end
    pcall(function()
        RemoteBank.PlaceStand:InvokeServer(dE)
    end)
end
iI = fn266
task.spawn(worker3)
AutoCollectMoneyFromPetsGroup:AddToggle("AutoCollectCash", { Text = "Auto Collect Money from Pets", Default = false, Callback = onAutoCollectCash })
AutoCollectMoneyFromPetsGroup:AddDropdown("CollectPriority", {
    Text = "Collect Priority",
    Values = { "Most Money", "Lowest Money", "Best Rarity Pet" },
    Multi = false,
    Default = "Most Money",
    Callback = onCollectPriority
})
AutoCollectMoneyFromPetsGroup:AddSlider("CollectInterval", {
    Text = "Collect Interval (s)",
    Default = 5,
    Min = 1,
    Max = 30,
    Rounding = 0,
    Callback = onCollectInterval
})
jd = false
i5 = {}
if ((not jt or connection) and (not jt or not connection) and ((jt or not connection) and (connection and jt)) or (not connection or connection or jt and connection) and (not jt and connection or (connection or not jt)) or (not connection and not jt and (jt or not jt) or (jt or not jt) and (jt and connection)) and (not connection or jt or (connection or connection) or (not connection or connection or not connection and not connection))) and not ((not jt or connection) and (not jt or not connection) and ((jt or not connection) and (connection and jt)) or (not connection or connection or jt and connection) and (not jt and connection or (connection or not jt)) or (not connection and not jt and (jt or not jt) or (jt or not jt) and (jt and connection)) and (not connection or jt or (connection or connection) or (not connection or connection or not connection and not connection))) then
    jt = 0.5
    iZ = false
    iV = function()
        local nh = DataService.client:get("inventory")
        if type(nh) ~= "table" then
            return
        end
        for k, v in pairs(nh) do
            local nn = k
            if not jd or Library.Unloaded then
                break
            end
            local nh_5 = type(v) == "table" and v.tag == "Entity" and type(v.informations) == "table"
            if nh_5 then
                local name = v.informations.name
                local ni = i_(i5) or i5[iA(name)]
                if ni then
                    pcall(function()
                        RemoteBank.SellRemote:InvokeServer("Sell", nn)
                    end)
                    task.wait(iZ)
                end
            end
        end
    end
    iR = function()
        local nq = DataService.client:get("stands")
        if type(nq) ~= "table" then
            return
        end
        for k, v in pairs(nq) do
            local nw = k
            if not jd or Library.Unloaded then
                break
            else
                local nq_5 = v and v.entity
                local nr = nq_5
                if nq_5 then
                    nq_5 = nr.name
                end
                if nq_5 then
                    local nq_6 = i_(i5) or i5[iA(nr.name)]
                    if nq_6 then
                        pcall(function()
                            RemoteBank.SellRemote:InvokeServer("Sell", "Ranch:" .. tostring(nw))
                        end)
                        task.wait(iZ)
                    end
                end
            end
        end
    end
else
    iZ = 0.5
    iV = false
    iR = function()
        local nh = DataService.client:get("inventory")
        if type(nh) ~= "table" then
            return
        end
        for k, v in pairs(nh) do
            local nn = k
            if not jd or Library.Unloaded then
                break
            end
            local nh_2 = type(v) == "table" and v.tag == "Entity" and type(v.informations) == "table"
            if nh_2 then
                local name = v.informations.name
                local ni = i_(i5) or i5[iA(name)]
                if ni then
                    pcall(function()
                        RemoteBank.SellRemote:InvokeServer("Sell", nn)
                    end)
                    task.wait(iZ)
                end
            end
        end
    end
    jt = function()
        local nq = DataService.client:get("stands")
        if type(nq) ~= "table" then
            return
        end
        for k, v in pairs(nq) do
            local nw = k
            if not jd or Library.Unloaded then
                break
            else
                local nq_2 = v and v.entity
                local nr = nq_2
                if nq_2 then
                    nq_2 = nr.name
                end
                if nq_2 then
                    local nq_3 = i_(i5) or i5[iA(nr.name)]
                    if nq_3 then
                        pcall(function()
                            RemoteBank.SellRemote:InvokeServer("Sell", "Ranch:" .. tostring(nw))
                        end)
                        task.wait(iZ)
                    end
                end
            end
        end
    end
end
task.spawn(worker4)
AutoSellAnimalsGroup:AddToggle("AutoSellAnimals", { Text = "Auto Sell Animals", Default = false, Callback = onAutoSellAnimals })
AutoSellAnimalsGroup:AddToggle("SellFromRanch", { Text = "Also Sell Ranch-Placed Animals", Default = false, Callback = onSellFromRanch })
AutoSellAnimalsGroup:AddDropdown("SellRarityFilter", {
    Text = "Rarity Filter (empty = all)",
    Values = fn597(),
    Multi = true,
    Default = {},
    Searchable = true,
    Callback = onSellRarityFilter
})
AutoSellAnimalsGroup:AddSlider("SellInterval", {
    Text = "Sell Interval (s)",
    Default = 0.5,
    Min = 0.1,
    Max = 3,
    Rounding = 1,
    Callback = onSellInterval
})
iM = false
iG = fn479
task.spawn(worker5)
AutoRebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false, Callback = onAutoRebirth })
iE = false
iw = 50
is = function()
    local nJ = DataService.client:get("stands")
    if type(nJ) ~= "table" then
        return
    end
    local nK = DataService.client:get("cash") or 0
    local nL = nK
    for k, v in pairs(nJ) do
        local nR = k
        local nJ_1 = v and v.entity
        local nK_1 = nJ_1
        if nJ_1 then
            nJ_1 = nK_1.name
        end
        if nJ_1 then
            local nJ_2 = nK_1.upgradeLevel or 0
            if nJ_2 < iw then
                local nJ_3 = SharedFunctions.GetUpgradeCost(nK_1.name, nJ_2 + 1)
                if nJ_3 and nL >= nJ_3 then
                    pcall(function()
                        RemoteBank.UpgradeStand:FireServer(nR)
                    end)
                    nL = nL - nJ_3
                    task.wait(0.15)
                end
            end
        end
    end
end
task.spawn(worker6)
AutoUpgradePetsGroup:AddToggle("AutoUpgradePets", { Text = "Auto Upgrade Pets", Default = false, Callback = onAutoUpgradePets })
AutoUpgradePetsGroup:AddSlider("MaxUpgradeLevel", {
    Text = "Max Upgrade Level",
    Default = 50,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = onMaxUpgradeLevel
})
local MenuGroup = jF_1.Settings:AddLeftGroupbox("Menu", "settings-2")
it = tick()
ju = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local n0 = v
        pcall(function()
            n0:Disable()
        end)
    end
end)
i3 = fn31
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(antiAfkLoop)
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddButton("Unload", onUnload)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(jF_1.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/SaveAnimals")
SaveManager:BuildConfigSection(jF_1.Settings)
SaveManager:LoadAutoloadConfig()
Library:OnUnload(fn173)
end)(...)

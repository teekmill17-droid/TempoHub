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
getgenv().TempoHoodSubtitle = "DRILL BLOCKS FOR BRAINROTS"
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
local xS_27
local oA
local od
local RequestCollectCash
local Rebirth
local oG
local pn
local oj
local connection2
local n0
local oM
local pt
local RebirthsConfigurations
local pa
local n6
local IncrementCarry
local UserInputService
local oz
local pg
local oc
local oY
local pF
local oF
local SellItem
local GameConfigurations
local o3
local n_
local oL
local SellAll
local oq
local Workspace
local n5
local oR
local py
local oy
local pf
local ob
local PlayerGui
local Level2
local oE
local HttpService
local oh
local o2
local ItemsConfigurations
local VirtualUser
local ShovelsConfigurations
local o8
local n4
local IncrementSpeed
local px
local UpgradesConfigurations
local pe
local Label
local oW
local pD
local oD
local pk
local Toggles
local o1
local oJ
local pq
local oo
local o7
local n3
local oP
local pw
local ow
local pd
local n9
local oV
local pC
local Library
local BuyShovel
local of
local o0
local MutationsConfigurations
local pp
local o6
local n2
local oO
local connection
local ov
local EquipShovel
local n8
local oU
local pB
local ItemsHelper
local pi
local oe
local o_
local CurrentCamera2
local po
local SaveManager
local o5
local n1
local oN
local pu
local ou
local n7
local IncrementStrength
local Inventory
function fns.worker7()
    while not Library.Unloaded do
        task.wait(0.45)
        if ov("AutoCollectMoney") then
            pcall(oY)
        end
    end
end
function fns.onCopyLitecoinAddress()
    o_(pw, "Copied Litecoin address")
end
function fns.worker6()
    while not Library.Unloaded do
        task.wait(2)
        if ov("AutoSell") then
            pcall(oO)
        end
    end
end
function fns.fn103()
    local Bases = Workspace:FindFirstChild("Bases")
    if not Bases then
        return nil
    end
    for i, child in ipairs(Bases:GetChildren()) do
        local Player = child:FindFirstChild("Player")
        local rB = Player and Player:FindFirstChild("HomeGui")
        local rA_2 = rB
        if rB then
            rB = rA_2.Enabled
        end
        if rB then
            return child
        end
    end
    return nil
end
function fns.fn105()
    local vM = oj()
    if not vM then
        return
    end
    local Level = vM:FindFirstChild("Level")
    local vM_1 = Level and Level:FindFirstChild("BaseLevelGui")
    local vN_1 = vM_1
    if vM_1 then
        vM_1 = vN_1.Enabled
    end
    if not vM_1 then
        return
    end
    local attr = vN_1:GetAttribute("UpgradeId")
    if not attr then
        return
    end
    oR(Level2, attr)
end
function fns.onExportConfigToClipboard()
    local xv_1
    local xu_1
    xu_1, xv_1 = pcall(HttpService.JSONEncode, HttpService, pd())
    if not xu_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local xu_2 = setclipboard or toclipboard
    local xu_3 = type(xu_2) ~= "function" or not pcall(xu_2, xv_1)
    if xu_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
function fns.fn159()
    local uW = ob("SellRarities", {})
    local uX = {}
    if type(uW) == "table" then
        for k, v in pairs(uW) do
            if v then
                uX[k] = true
            end
        end
    end
    return uX
end
function fns.onCopyBitcoinAddress()
    o_(po, "Copied Bitcoin address")
end
function fns.fn190()
    local Gui = PlayerGui:FindFirstChild("Gui")
    local q6 = Gui and Gui:FindFirstChild("Hud") and Gui.Hud:FindFirstChild("Counters") and Gui.Hud.Counters:FindFirstChild("Cash") and Gui.Hud.Counters.Cash:FindFirstChild("Amount")
    local q5_1 = q6
    if q6 then
        q6 = q5_1:IsA("TextLabel")
    end
    if q6 then
        py.money = ow(q5_1.Text)
    end
end
function fns.onCopySolanaAddress()
    o_(pa, "Copied Solana address")
end
function fns.fn237(co)
    local rN = o8()
    if not (rN and co) then
        return false
    end
    rN.CFrame = co
    rN.AssemblyLinearVelocity = Vector3.zero
    rN.AssemblyAngularVelocity = Vector3.zero
    return true
end
function fns.fn245(at, au)
    return string.format('<font color="%s">%s</font>', au, at)
end
function fns.fn257(dH)
    if not dH then
        return nil
    end
    local Slots = dH:FindFirstChild("Slots")
    if not Slots then
        return nil
    end
    for i, child in ipairs(Slots:GetChildren()) do
        if child:IsA("Model") then
            local Money = child:FindFirstChild("Money")
            local sT = Money and Money:FindFirstChild("MoneyGui")
            local sS_1 = sT
            if sT then
                sT = sS_1.Enabled == true
            end
            local sS_2 = sT
            local sT_1 = oV(child, "Place")
            if sT_1 and not sS_2 then
                return child, sT_1
            end
        end
    end
    for i, child in ipairs(Slots:GetChildren()) do
        if child:IsA("Model") then
            local sR_1 = oV(child, "Place")
            if sR_1 then
                return child, sR_1
            end
        end
    end
    return nil
end
function fns.onRscripts()
    o_(n1, "Copied Rscripts profile to clipboard")
end
function fns.fn280()
    local sc = {}
    local Items = Workspace:FindFirstChild("Items")
    if not Items then
        return sc
    end
    for i, child in ipairs(Items:GetChildren()) do
        local sd_1 = child:IsA("Model") and n2(child)
        if sd_1 then
            sc[#sc + 1] = child
        end
    end
    return sc
end
function fns.fn287(ec, ed)
    local tr = py[string.lower(ec)] or 0
    if ec == "Carry" then
        local Carry1 = UpgradesConfigurations.Carry1
        local tt_1 = Carry1 and Carry1.Costs
        if type(tt_1) ~= "table" then
            return nil
        end
        local tt_2 = 0
        local tu_1 = ed - 1
        local tC = 0
        while true do
            if not (tC <= tu_1) then
                return tt_2
            end
            local tD = tC
            local tu_2 = tt_1[tr + tD] or tt_1[tostring(tr + tD)]
            if not tu_2 then
                break
            end
            local tu_3 = tonumber(tu_2) or 0
            tt_2 += tu_3
            tC += 1
        end
        return nil
    end
    local tt_4 = UpgradesConfigurations[ec == "Strength" and "Strength1" or "Speed1"]
    if not (tt_4 and tt_4.Money and tt_4.IncrementMultiplier) then
        return nil
    end
    local tr_6 = 0
    local tu_4 = ed - 1
    local tK = 0
    while tK <= tu_4 do
        local tL = tK
        tr_6 += math.round(tt_4.Money * tt_4.IncrementMultiplier ^ (tr + tL))
        tK += 1
    end
    return tr_6
end
function fns.fn292()
    connection:Disconnect()
    connection2:Disconnect()
    n0(false)
    local xL = pp()
    if xL then
        xL.PlatformStand = false
        xL.WalkSpeed = 16
    end
end
function fns.fn300()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    ou = tick()
end
function fns.antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local wT = tick() - oy
            local wU = tick() - ou
            if wT >= 300 and wU >= 60 then
                pcall(n8)
            else
                if wT < 300 and wU >= 300 then
                    pcall(n8)
                end
            end
        end
    end
end
function fns.onCopyJoinScript_JobID()
    local g8 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, n5)
    o_(g8, "Copied join script to clipboard")
end
function fns.onCopyUSDTAddress()
    o_(pe, "Copied USDT address")
end
function fns.onRenderStepped(ik)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local wl_1 = pp()
        if wl_1 then
            wl_1.WalkSpeed = od.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local wl_3 = o8()
        local wm = pp()
        if wl_3 and wm then
            wm.PlatformStand = true
            local wm_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                wm_1 += CurrentCamera2.CFrame.LookVector
            end
            local wr = if UserInputService:IsKeyDown(Enum.KeyCode.S) then 1 else 0
            if wr == 1 then
                wm_1 -= CurrentCamera2.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                wm_1 -= CurrentCamera2.CFrame.RightVector
            end
            local wu = if UserInputService:IsKeyDown(Enum.KeyCode.D) then 1 else 0
            if wu == 1 then
                wm_1 += CurrentCamera2.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                wm_1 += Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                wm_1 -= Vector3.new(0, 1, 0)
            end
            wl_3.AssemblyLinearVelocity = Vector3.zero
            if wm_1.Magnitude > 0 then
                wl_3.CFrame = wl_3.CFrame + wm_1.Unit * od.FlySpeed.Value * ik
            end
        end
    end
end
function fns.fn329()
    n0(Toggles.AntiGameplayPause.Value)
end
function fns.fn338()
    if ov("SellGrabPads") then
        oc()
    end
    oR(Inventory)
    task.wait(0.35)
    local inventory = py.inventory
    local vk = type(inventory) ~= "table" or #inventory == 0
    if vk then
        return
    end
    local vk_1 = ob("SellMode", "All")
    if vk_1 == "All" then
        oR(SellAll)
        return
    end
    local vl = {}
    local vm = -1
    local vn = 1
    for i, v in ipairs(inventory) do
        local vj_1 = { Name = v.Name, Mutation = v.Mutation, Level = v.Level, _index = i, _value = oq(v) }
        vl[#vl + 1] = vj_1
        if vj_1._value > vm then
            vm = vj_1._value
            vn = i
        end
    end
    local vx = #vl
    local vw = -1
    while false and vx <= 1 or true and vx >= 1 do
        local vj_3 = vl[vx]
        if oG(vj_3, vk_1, vn) then
            oR(SellItem, vj_3._index)
            task.wait(0.08)
        end
        vx += vw
    end
end
function fns.fn352()
    local rJ = oj()
    if not rJ then
        return nil
    end
    local Spawn = rJ:FindFirstChild("Spawn")
    local rL = Spawn and Spawn:IsA("BasePart")
    if rL then
        return Spawn.CFrame + Vector3.new(0, 4, 0)
    end
    local Player = rJ:FindFirstChild("Player")
    local rJ_1 = Player and Player:IsA("BasePart")
    if rJ_1 then
        return Player.CFrame + Vector3.new(0, 4, 0)
    end
    return nil
end
function fns.fn360(fu)
    local uM = type(fu) ~= "table" or type(fu.Name) ~= "string"
    if uM then
        return 0
    end
    local uM_1 = ItemsConfigurations[fu.Name]
    if not uM_1 then
        return 0
    end
    local uN = fu.Mutation or "Normal"
    local uN_1 = tonumber(fu.Level) or 1
    local uN_2 = pu(uN)
    local round = math.round
    local GetSell = ItemsHelper.GetSell
    local uR = uM_1.BaseSell or 0
    return round(GetSell(uR, uN_1) * uN_2)
end
function fns.fn362(eX)
    return py.ownedShovels[eX] == true
end
function fns.worker4()
    while not Library.Unloaded do
        task.wait(1)
        if ov("AutoRebirth") then
            pcall(n3)
        end
    end
end
function fns.onInputChanged(i9)
    local UserInputType = i9.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        oy = tick()
    end
end
function fns.fn384(aY, aZ)
    local qI = od[aY]
    if qI == nil then
        return aZ
    end
    return qI.Value
end
function fns.fn386(jp, jq)
    local wY_1 = (jp == "Toggle" and Toggles or od)[jq]
    local wX_2 = type(wY_1) == "table" and wY_1.Type == jp
    return wX_2 and wY_1 or nil
end
function fns.fn410()
    local qN = pD()
    local qO = qN and qN:FindFirstChild("HumanoidRootPart")
    return qO
end
function fns.worker8()
    while not Library.Unloaded do
        task.wait(1.2)
        if ov("AutoUpgradeBase") then
            pcall(n7)
        end
    end
end
function fns.onImportConfigFromClipboardTex()
    local xA_1
    local xy = od.SaveManager_ImportSource.Value or ""
    local xy_1
    local xz = tostring(xy):match("^%s*(.-)%s*$")
    if xz == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    xy_1, xA_1 = pcall(HttpService.JSONDecode, HttpService, xz)
    local xz_1 = not xy_1 or type(xA_1) ~= "table" or type(xA_1.objects) ~= "table"
    if xz_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local xy_2 = 0
    for i, v in ipairs(xA_1.objects) do
        if oh(v) then
            xy_2 += 1
        end
    end
    if xy_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    od.SaveManager_ImportSource:SetValue("")
    local xA_2 = xy_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(xy_2, xA_2), 6)
end
function fns.worker5()
    while not Library.Unloaded do
        task.wait(1.2)
        local v7 = if ov("AutoBuyDrills") then 1 else 0
        if v7 == 1 then
            pcall(oe)
        end
    end
end
function fns.fn492(dd)
    if #dd == 0 then
        return nil
    end
    return dd[math.random(1, #dd)]
end
function fns.fn500(eu)
    local tN_1
    if eu == "Strength" then
        tN_1 = IncrementStrength
    elseif eu == "Carry" then
        tN_1 = IncrementCarry
    else
        tN_1 = IncrementSpeed
    end
    local tO = 1
    local tP = pi(eu, 1)
    if not tP or py.money < tP then
        return false
    end
    local tQ_1 = GameConfigurations.Maximums and GameConfigurations.Maximums[eu]
    local tP_2 = py[string.lower(eu)] or 0
    local tP_3 = typeof(tQ_1) == "number" and tQ_1 ~= math.huge and tP_2 + tO > tQ_1
    if tP_3 then
        return false
    end
    oR(tN_1, tO)
    return true
end
function fns.worker2()
    while not Library.Unloaded do
        if ov("AutoCollectBrainrot") then
            pcall(n6)
            task.wait(0.05)
        else
            task.wait(0.25)
        end
    end
end
function fns.fn517()
    return o3.Character
end
function fns.onInputBegan()
    oy = tick()
end
function fns.fn603(am, an)
    if setclipboard then
        setclipboard(am)
    elseif toclipboard then
        toclipboard(am)
    end
    Library:Notify(an)
end
function fns.fn624(cG)
    local r4 = MutationsConfigurations[cG or "Normal"]
    local r3_1 = r4 and tonumber(r4.Multiplier)
    return r3_1 or 1
end
function fns.fn631()
    local v_ = not Toggles.AutoCollectBrainrot.Value and oP()
    if v_ then
        task.spawn(function()
            pcall(pg)
        end)
    end
end
function fns.fn647(c6)
    if #c6 == 0 then
        return nil
    end
    local sl = c6[1]
    local sm = o6(sl)
    local sn = #c6
    local sr = 2
    while sr <= sn do
        local ss = sr
        local sn_1 = o6(c6[ss])
        if sn_1 > sm then
            sl = c6[ss]
            sm = sn_1
        end
        sr += 1
    end
    return sl
end
function fns.fn653()
    if not Toggles.Fly.Value then
        local wv = pp()
        if wv then
            wv.PlatformStand = false
        end
    end
end
function fns.fn667(jx, jy)
    local Type = jy.Type
    if Type == "Toggle" then
        return { idx = jx, type = "Toggle", value = jy.Value == true }
    elseif Type == "Slider" then
        return { idx = jx, type = "Slider", value = tostring(jy.Value) }
    elseif Type == "Dropdown" then
        return { idx = jx, type = "Dropdown", multi = jy.Multi == true, value = jy.Value }
    elseif Type == "Input" then
        local w1 = jy.Value or ""
        return { idx = jx, type = "Input", text = tostring(w1) }
    elseif Type == "ColorPicker" then
        return { idx = jx, type = "ColorPicker", value = jy.Value:ToHex(), transparency = jy.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = jx,
            type = "KeyPicker",
            mode = jy.Mode,
            key = jy.Value,
            modifiers = jy.Modifiers,
            toggled = jy.Toggled
        }
    else
        return nil
    end
end
function fns.fn722()
    local td_1
    local tb = oj()
    if not tb then
        return false
    end
    local tc = pt()
    local tc_1
    if tc then
        oU(tc)
        task.wait(0.15)
    end
    tc_1, td_1 = oA(tb)
    local tb_1 = not td_1
    local te = not tc_1
    local ti = if te then 1 else 0
    local tg = 2281 * ti + 732 * (1 - ti)
    local th = 3006 * ti + 1088 * (1 - ti)
    if not ((tg * 1284 + th * 824 + tg * th) % 16777213 == 12262434) then
        te = tb_1
    end
    if te then
        return false
    end
    local Spawn = tc_1:FindFirstChild("Spawn")
    local tc_2 = Spawn and Spawn:IsA("BasePart")
    if tc_2 then
        oU(Spawn.CFrame + Vector3.new(0, 3, 0))
    end
    task.wait(0.1)
    local tl = 1
    while true do
        if not (tl <= 8) then
            return not oP()
        end
        if not oP() then
            return true
        end
        local tb_3 = not ov("AutoCollectBrainrot") or Library.Unloaded
        if tb_3 then
            break
        end
        td_1.Enabled = true
        oJ(td_1)
        task.wait(0.35)
        tl += 1
    end
    return not oP()
end
function fns.onCopyVenmoLink()
    o_(o1, "Copied Venmo link")
end
function fns.fn756()
    Library.ScreenGui.Parent = o3:WaitForChild("PlayerGui")
end
function fns.fn758(ah, ai)
    return (pB[ah] or 0) < (pB[ai] or 0)
end
function fns.fn761()
    o_(n9, "Copied Discord invite to clipboard")
end
function fns.fn768(fB)
    local uT = fB and ItemsConfigurations[fB.Name]
    local uU = uT
    if uT then
        uT = uU.Area
    end
    return uT or "Common"
end
function fns.onOnClientEvent3(bN)
    local ri = tonumber(bN) or py.carry
    py.carry = ri
end
function fns.fn777(cB)
    if not cB then
        return nil
    end
    for i, descendant in ipairs(cB:GetDescendants()) do
        local rW = descendant:IsA("ProximityPrompt") and descendant.ActionText == "Carry" and descendant.Enabled
        if rW then
            return descendant
        end
    end
    return nil
end
function fns.fn800(gS)
    local DiscordGroup = gS:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = oL })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = oL })
end
function fns.fn806()
    local ui = {}
    for k, v in pairs(ShovelsConfigurations) do
        local uj = not v.HideInShop
        if uj ~= false then
            uj = not v.RobuxOnly
        end
        if uj then
            uj = not v.DailyReward
        end
        if uj then
            ui[#ui + 1] = { Name = k, Config = v }
        end
    end
    table.sort(ui, function(e5, e6)
        return (e5.Config.Order or 0) < (e6.Config.Order or 0)
    end)
    return ui
end
function fns.fn815()
    local u6 = oj()
    if not u6 then
        return
    end
    local Slots = u6:FindFirstChild("Slots")
    if not Slots then
        return
    end
    for i, child in ipairs(Slots:GetChildren()) do
        local u6_1 = Library.Unloaded or not ov("AutoSell")
        if u6_1 then
            return
        end
        local u6_2 = oV(child, "Grab")
        if u6_2 and u6_2.Enabled then
            local Spawn = child:FindFirstChild("Spawn")
            local u8 = Spawn and Spawn:IsA("BasePart")
            if u8 then
                oU(Spawn.CFrame + Vector3.new(0, 3, 0))
            end
            task.wait(0.08)
            oJ(u6_2)
            task.wait(0.25)
        end
    end
end
function fns.fn817(fL, fM, fN)
    if fM == "All" then
        return true
    elseif fM == "Keep Best" then
        return fL._index ~= fN
    elseif fM == "Selected Rarities" then
        local u4 = o2()
        if next(u4) == nil then
            return false
        end
        return u4[px(fL)] == true
    else
        return false
    end
end
local function onUnload()
    Library:Unload()
end
local function onOnClientEvent5(bT)
    py.carrying = bT == true
end
local function fn837()
    local qK = pD()
    local qL = qK and qK:FindFirstChildOfClass("Humanoid")
    return qL
end
local function fn844()
    oW()
    local ur = pq()
    local us = -math.huge
    local Name
    for i, v in ipairs(oM()) do
        if o0(v.Name) then
            local uu_1 = v.Config.Order or 0
            if uu_1 >= us then
                us = uu_1
                Name = v.Name
            end
        end
    end
    for i, v in ipairs(oM()) do
        local Config = v.Config
        if not o0(v.Name) then
            local uu_2 = tonumber(Config.Rebirths) or 0
            local uu_3 = tonumber(Config.Money)
            if ur >= uu_2 and uu_3 and uu_3 > 0 and py.money >= uu_3 then
                oR(BuyShovel, v.Name)
                task.wait(0.15)
                oR(EquipShovel, v.Name)
                return
            end
        end
    end
    if Name and py.equippedShovel ~= Name then
        oR(EquipShovel, Name)
    end
end
local function fn847(dl)
    if not dl or not dl.Parent then
        return false
    end
    local sx_1 = n2(dl)
    if not sx_1 then
        return false
    end
    local Parent = sx_1.Parent
    local sz = Parent and Parent:IsA("BasePart")
    if sz then
        oU(Parent.CFrame + Vector3.new(0, 3, 0))
    end
    task.wait(0.1)
    local sG = 1
    while sG <= 8 do
        local sy_1 = not ov("AutoCollectBrainrot") or Library.Unloaded
        if sy_1 then
            return oP()
        end
        if not dl.Parent then
            return oP()
        end
        oJ(sx_1)
        task.wait(0.35)
        if oP() then
            return true
        end
        sG += 1
    end
    return oP()
end
local function onCopyEthereumAddress()
    o_(pk, "Copied Ethereum address")
end
local function fn870()
    local leaderstats = o3:FindFirstChild("leaderstats")
    local q3 = leaderstats and leaderstats:FindFirstChild("Rebirths")
    local q2_1 = q3
    if q3 then
        q3 = q2_1.Value
    end
    local q2_2 = tonumber(q3) or 0
    return q2_2
end
local function fn872()
    local t7 = pq()
    local t8 = RebirthsConfigurations[t7 + 1]
    local ue = if t8 then 1 else 0
    local uc = 1286 * ue + 2332 * (1 - ue)
    local ud = 2671 * ue + 2570 * (1 - ue)
    if not ((uc * 4018 + ud * 1706 + uc * ud) % 16777213 == 13158780) then
        t8 = RebirthsConfigurations[tostring(t7 + 1)]
    end
    local t7_1 = t8
    if not t7_1 then
        return
    end
    local t8_1 = tonumber(t7_1.Strength) or 0
    if py.strength * (py.strengthMult or 1) >= t8_1 then
        oR(Rebirth)
    end
end
local function fn874()
    local vQ_1
    local vP_1
    if identifyexecutor then
        vQ_1, vP_1 = identifyexecutor()
        local vR = vQ_1 ~= ""
        local vS = type(vQ_1) == "string" and vR
        if vS then
            local vR_1 = type(vP_1) == "string" and vP_1 ~= "" and vQ_1 .. " " .. vP_1
            local vP_2 = vR_1
            local vW = if vP_2 then 1 else 0
            local vU = 3080 * vW + 922 * (1 - vW)
            local vV = 356 * vW + 1996 * (1 - vW)
            if not ((vU * 3654 + vV * 2520 + vU * vV) % 16777213 == 13247920) then
                vP_2 = vQ_1
            end
            oE = vP_2
        end
    end
end
local function fn883(aT)
    local qF = Toggles[aT]
    return qF ~= nil and qF.Value == true
end
local function worker()
    local vY_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local vX = math.floor(os.clock() - pn)
        if vX < 60 then
            vY_1 = vX .. "s"
        elseif vX < 3600 then
            vY_1 = string.format("%dm %ds", math.floor((vX) / (60)), vX % 60)
        else
            vY_1 = string.format("%dh %dm", math.floor((vX) / (3600)), math.floor((vX % 3600) / (60)))
        end
        Label:SetText(oo("Session time", vY_1, pF))
    end
end
local function fn920()
    if py.carrying then
        return true
    end
    local Gui = PlayerGui:FindFirstChild("Gui")
    local ry = Gui and Gui:FindFirstChild("Frames") and Gui.Frames:FindFirstChild("CarryButtons")
    return ry ~= nil and ry.Visible == true
end
local function onCopyPayPalLink()
    o_(o7, "Copied PayPal link")
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = o3.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local wb_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if wb_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function worker3()
    while not Library.Unloaded do
        task.wait(0.6)
        if ov("AutoBuyUpgrades") then
            pcall(oD)
        end
    end
end
local function onOnClientEvent(bG)
    local rb = tonumber(bG) or py.money
    py.money = rb
end
local function fn973()
    local tX_1
    oW()
    local tW = ob("UpgradeType", "All")
    if tW == "All" then
        tX_1 = { "Strength", "Carry", "Speed" }
    else
        tX_1 = { tW }
    end
    for i, v in ipairs(tX_1) do
        n_(v)
    end
end
local function fn979()
    if not Toggles.WalkSpeedEnabled.Value then
        local wx = pp()
        if wx then
            wx.WalkSpeed = 16
        end
    end
end
local function fn1000(dB, dC)
    for i, descendant in ipairs(dB:GetDescendants()) do
        local sJ = descendant:IsA("ProximityPrompt") and descendant.ActionText == dC
        if sJ then
            return descendant
        end
    end
    return nil
end
local function fn1007()
    local w7 = {}
    for i, v in ipairs({ Toggles, od }) do
        for k, v in pairs(v) do
            local w8 = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if w8 then
                local w8_1 = pC(k, v)
                if w8_1 then
                    w7[#w7 + 1] = w8_1
                end
            end
        end
    end
    table.sort(w7, function(jM, jN)
        if jM.type ~= jN.type then
            return jM.type < jN.type
        end
        return jM.idx < jN.idx
    end)
    return { objects = w7 }
end
local function onOnClientEvent4(bQ)
    local rk = tonumber(bQ) or py.speed
    py.speed = rk
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            n0(true)
        end
    end
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local wj_1 = pp()
        if wj_1 then
            wj_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function onOnClientEvent6(bV)
    local rm = type(bV) == "table" and bV
    local rn = {}
    local ro = rm
    local rs = if ro then 1 else 0
    local rq = 1567 * rs + 1338 * (1 - rs)
    local rr = 781 * rs + 3964 * (1 - rs)
    if not ((rq * 614 + rr * 1995 + rq * rr) % 16777213 == 3744060) then
        ro = rn
    end
    py.inventory = ro
end
local function fn1049(aw, ax, ay)
    return string.format("<b>%s</b> %s %s", aw, oz("-", "#5a6070"), oz(ax, ay))
end
local function fn1053(cL)
    local r6 = ItemsConfigurations[cL.Name]
    local r7 = r6 and tonumber(r6.BaseMoney)
    local r8 = r7 or 0
    local r7_1 = r6
    if r7_1 then
        r7_1 = tonumber(r6.BaseSell)
    end
    local r8_1 = r7_1 or 0
    local r7_2 = r6
    if r7_2 then
        r7_2 = r6.Area
    end
    local r6_1 = r7_2 or "Common"
    local r6_2 = cL:GetAttribute("Mutation") or "Normal"
    local r6_3 = pu(r6_2)
    return (pB[r6_1] or 0) * 1e+24 + r8 * r6_3 * 1000000 + r8_1 * r6_3
end
local function onOnClientEvent7(bX, bY)
    local rt = type(bX) == "table" and bX
    local rv = rt or {}
    py.ownedShovels = rv
    local rt_1 = bY or ""
    py.equippedShovel = tostring(rt_1)
end
local function fn1058(bh)
    local qS_1
    local qR_1
    if type(bh) == "number" then
        return bh
    elseif type(bh) ~= "string" then
        return 0
    else
        local qQ = bh:gsub("%$", ""):gsub(",", ""):gsub("%s", "")
        qR_1, qS_1 = qQ:match("^([%d%.]+)(%a*)$")
        local qQ_1 = tonumber(qR_1)
        if not qQ_1 then
            return 0
        end
        local qR_2 = qS_1 or ""
        for i, v in ipairs(o5) do
            if v:lower() == qR_2:lower() then
                return qQ_1 * 1000 ^ (i - 1)
            end
        end
        return qQ_1
    end
end
local function onOnClientEvent2(bJ, bK)
    local rd = (tonumber(bJ))
    local rh = if rd then 1 else 0
    local rf = 2101 * rh + 2695 * (1 - rh)
    local rg = 1228 * rh + 803 * (1 - rh)
    if not ((rf * 3078 + rg * 3576 + rf * rg) % 16777213 == 13438234) then
        rd = py.strength
    end
    py.strength = rd
    if type(bK) == "number" then
        py.strengthMult = bK
    end
end
local function fn1064()
    if oP() then
        pg()
        return
    end
    local to = ob("GrabPriority", "Best")
    local tp = oF(to)
    if not tp then
        task.wait(0.35)
        return
    end
    if of(tp) then
        pg()
    end
end
local function fn1074()
    local vA = oj()
    if not vA then
        return
    end
    local Slots = vA:FindFirstChild("Slots")
    if not Slots then
        return
    end
    for i, child in ipairs(Slots:GetChildren()) do
        local vA_1 = Library.Unloaded or not ov("AutoCollectMoney")
        if vA_1 then
            return
        end
        local Money = child:FindFirstChild("Money")
        local vB_1 = Money and Money:IsA("BasePart")
        if vB_1 then
            oR(RequestCollectCash, Money)
            task.wait(0.15)
        end
    end
end
local function fn1107(df)
    local sv = n4()
    if df == "Random" then
        return oN(sv)
    end
    return pf(sv)
end
n_ = nil
n0 = nil
n1 = nil
n2 = nil
n3 = nil
n4 = nil
n5 = nil
n6 = nil
n7 = nil
n8 = nil
n9 = nil
Label = nil
ob = nil
oc = nil
od = nil
oe = nil
of = nil
Toggles = nil
oh = nil
GameConfigurations = nil
oj = nil
SaveManager = nil
oo = nil
ShovelsConfigurations = nil
oq = nil
RebirthsConfigurations = nil
ou = nil
ov = nil
ow = nil
UpgradesConfigurations = nil
oy = nil
oz = nil
oA = nil
ItemsHelper = nil
Library = nil
oD = nil
oE = nil
oF = nil
oG = nil
CurrentCamera2 = nil
MutationsConfigurations = nil
oJ = nil
ItemsConfigurations = nil
oL = nil
oM = nil
oN = nil
oO = nil
oP = nil
IncrementSpeed = nil
local om
oR = nil
IncrementCarry = nil
IncrementStrength = nil
oU = nil
oV = nil
oW = nil
PlayerGui = nil
oY = nil
RequestCollectCash = nil
o_ = nil
o0 = nil
o1 = nil
o2 = nil
o3 = nil
connection2 = nil
o5 = nil
o6 = nil
o7 = nil
o8 = nil
Workspace = nil
pa = nil
EquipShovel = nil
pd = nil
pe = nil
pf = nil
pg = nil
pi = nil
BuyShovel = nil
pk = nil
HttpService = nil
SellItem = nil
pn = nil
po = nil
pp = nil
pq = nil
VirtualUser = nil
SellAll = nil
pt = nil
pu = nil
connection = nil
pw = nil
px = nil
py = nil
UserInputService = nil
Inventory = nil
pB = nil
pC = nil
pD = nil
local CoreGui, GuiService
Level2 = nil
pF = nil
Rebirth = nil
UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, o3, PlayerGui = nil, nil, nil, nil, nil, nil, nil, nil
local xS_29 = game:GetService("Players")
local xS_4 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
o3 = xS_29.LocalPlayer
PlayerGui = o3:WaitForChild("PlayerGui")
if getgenv then
    getgenv().gethui = function()
        return o3:WaitForChild("PlayerGui")
    end
end
if setthreadidentity then
    setthreadidentity(8)
end
ItemsConfigurations, MutationsConfigurations, ItemsHelper, UpgradesConfigurations, RebirthsConfigurations, ShovelsConfigurations, GameConfigurations, Rebirth, Level2, Inventory, SellAll, SellItem, BuyShovel, EquipShovel, RequestCollectCash, IncrementStrength, IncrementCarry, IncrementSpeed, Library, SaveManager, Toggles, od, n9, n1, pB, xS_27 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local xS_41 = "Drill Blocks for Brainrots"
local xS_6 = xS_4:WaitForChild("Configurations"):WaitForChild("Modules")
ItemsConfigurations = require(xS_6:WaitForChild("ItemsConfigurations"))
MutationsConfigurations = require(xS_6:WaitForChild("MutationsConfigurations"))
ItemsHelper = require(xS_6:WaitForChild("ItemsHelper"))
UpgradesConfigurations = require(xS_6:WaitForChild("UpgradesConfigurations"))
RebirthsConfigurations = require(xS_6:WaitForChild("RebirthsConfigurations"))
ShovelsConfigurations = require(xS_6:WaitForChild("ShovelsConfigurations"))
GameConfigurations = require(xS_6:WaitForChild("GameConfigurations"))
xS_29 = xS_4:WaitForChild("Network"):WaitForChild("RemoteEvents")
local xS_36 = xS_29:WaitForChild("Money")
local xS_8 = xS_29:WaitForChild("Strength")
local xS_20 = xS_29:WaitForChild("Carry")
local xS_34 = xS_29:WaitForChild("Drop")
Rebirth = xS_29:WaitForChild("Rebirth")
Level2 = xS_29:WaitForChild("Level")
Inventory = xS_29:WaitForChild("Inventory")
SellAll = xS_29:WaitForChild("SellAll")
SellItem = xS_29:WaitForChild("SellItem")
BuyShovel = xS_29:WaitForChild("BuyShovel")
EquipShovel = xS_29:WaitForChild("EquipShovel")
local xS_38 = xS_29:WaitForChild("ShovelData")
local xS_10 = xS_29:WaitForChild("RequestShovelData")
RequestCollectCash = xS_29:WaitForChild("RequestCollectCash")
IncrementStrength = xS_29:WaitForChild("IncrementStrength")
IncrementCarry = xS_29:WaitForChild("IncrementCarry")
IncrementSpeed = xS_29:WaitForChild("IncrementSpeed")
local xS_22 = xS_29:WaitForChild("Speed")
Library = getgenv().Library
pcall(fns.fn756)
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
od = Library.Options
n9 = "https://discord.gg/K7Qxnxkk46"
n1 = "https://discord.gg/K7Qxnxkk46"
local xS_25 = { "Best", "Random" }
local xS_2 = { "All", "Strength", "Carry", "Speed" }
local xS_14 = { "All", "Keep Best", "Selected Rarities" }
pB = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Mythic = 6,
    Secret = 7,
    Divine = 8,
    Celestial = 9,
    OG = 10,
    Ancient = 11,
    Immortal = 12,
    Eternal = 13,
    Transcendent = 14,
    Limited = 15,
    Admin = 16
}
if (Level2 and false and (not Level2 and n1) or (false and not Level2 or "https://discord.gg/K7Qxnxkk46") or false and (n1 and not Level2) and (Level2 and n1 or (not Level2 or n1))) and not (Level2 and false and (not Level2 and n1) or (false and not Level2 or "https://discord.gg/K7Qxnxkk46") or false and (n1 and not Level2) and (Level2 and n1 or (not Level2 or n1))) then
    od = {}
else
    xS_27 = {}
end
for k in pairs(pB) do
    xS_27[#xS_27 + 1] = k
end
o5, pF, pw, po, pk, pe, pa, o7, o1, o_, oL, oz, oo, ov, ob, pD, pp, o8, oR, ow = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
table.sort(xS_27, fns.fn758)
o5 = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }
o_ = fns.fn603
oL = fns.fn761
oz = fns.fn245
oo = fn1049
local xS_17 = "#7fd47f"
local xS_5 = "#6ec1ff"
pF = "#e8a34d"
local xS_16 = "#8b93a3"
pw = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
po = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
pk = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
pe = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
pa = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
o7 = ""
o1 = ""
local xS_30 = "#345d9d"
local xS_3 = "#f7931a"
local xS_15 = "#627eea"
local xS_28 = "#26a17b"
xS_6 = "#14f195"
local xS_18 = "#0070ba"
xS_4 = "#008cff"
ov = fn883
ob = fns.fn384
pD = fns.fn517
pp = fn837
o8 = fns.fn410
oR = function(bc, ...)
    local bd
    bd = { ... }
    pcall(function()
        bc:FireServer(table.unpack(bd))
    end)
end
ow = fn1058
xS_29 = GameConfigurations.Defaults and GameConfigurations.Defaults.Carry
local xS_33 = xS_29 or 1
xS_29 = GameConfigurations.Defaults and GameConfigurations.Defaults.Speed
local xS_19 = xS_29 or 0
py, pq, oW, oP, oj, pt, oU, oJ, n2, pu, o6, n4, pf, oN, oF, of, oV, oA, pg, n6, pi, n_, oD, n3, o0, oM, oe, oq, px, o2, oG, oc, oO, oY, n7 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
py = {
    money = 0,
    strength = 0,
    strengthMult = 1,
    carry = xS_33,
    speed = xS_19,
    carrying = false,
    inventory = {},
    ownedShovels = {},
    equippedShovel = ""
}
pq = fn870
oW = fns.fn190
xS_36.OnClientEvent:Connect(onOnClientEvent)
xS_8.OnClientEvent:Connect(onOnClientEvent2)
xS_20.OnClientEvent:Connect(fns.onOnClientEvent3)
xS_22.OnClientEvent:Connect(onOnClientEvent4)
xS_34.OnClientEvent:Connect(onOnClientEvent5)
Inventory.OnClientEvent:Connect(onOnClientEvent6)
xS_38.OnClientEvent:Connect(onOnClientEvent7)
oR(xS_8)
oR(xS_20)
oR(xS_22)
oR(xS_10)
oR(Inventory)
oW()
oP = fn920
if (not oq or oV or not pg and not pg or (oq or oe or oV and not oe)) and ((not oV and oe or (not oq or pq)) and ((not o0 or not oe) and (pq or oe))) and (pg and not oe and (not pq or not pg) or (not oV or not pg or not oe and oe) or (not oq and not o0 or (not pg or not pq)) and ((o0 or not oV) and (not oe and oq))) or not ((not oq or oV or not pg and not pg or (oq or oe or oV and not oe)) and ((not oV and oe or (not oq or pq)) and ((not o0 or not oe) and (pq or oe))) and (pg and not oe and (not pq or not pg) or (not oV or not pg or not oe and oe) or (not oq and not o0 or (not pg or not pq)) and ((o0 or not oV) and (not oe and oq)))) then
    oj = fns.fn103
    pt = fns.fn352
    oU = fns.fn237
    oJ = function(cs)
        local rQ
        if not cs or not cs.Parent then
            return false
        elseif fireproximityprompt then
            local rR_4 = pcall(fireproximityprompt, cs)
            if rR_4 then
                return true
            end
            pcall(fireproximityprompt, cs, cs.HoldDuration)
            rQ = cs.HoldDuration
            local rR_5 = pcall(function()
                cs.HoldDuration = 0
                cs:InputHoldBegin()
                task.wait(0.05)
                cs:InputHoldEnd()
            end)
            pcall(function()
                cs.HoldDuration = rQ
            end)
            return rR_5
        else
            rQ = cs.HoldDuration
            local rR_6 = pcall(function()
                cs.HoldDuration = 0
                cs:InputHoldBegin()
                task.wait(0.05)
                cs:InputHoldEnd()
            end)
            pcall(function()
                cs.HoldDuration = rQ
            end)
            return rR_6
        end
    end
else
    pt = fns.fn103
    oJ = fns.fn352
    oj = fns.fn237
    oU = function(cs)
        local rQ
        if not cs or not cs.Parent then
            return false
        elseif fireproximityprompt then
            local rR_1 = pcall(fireproximityprompt, cs)
            if rR_1 then
                return true
            end
            pcall(fireproximityprompt, cs, cs.HoldDuration)
            rQ = cs.HoldDuration
            local rR_2 = pcall(function()
                cs.HoldDuration = 0
                cs:InputHoldBegin()
                task.wait(0.05)
                cs:InputHoldEnd()
            end)
            pcall(function()
                cs.HoldDuration = rQ
            end)
            return rR_2
        else
            rQ = cs.HoldDuration
            local rR_3 = pcall(function()
                cs.HoldDuration = 0
                cs:InputHoldBegin()
                task.wait(0.05)
                cs:InputHoldEnd()
            end)
            pcall(function()
                cs.HoldDuration = rQ
            end)
            return rR_3
        end
    end
end
n2 = fns.fn777
pu = fns.fn624
o6 = fn1053
n4 = fns.fn280
pf = fns.fn647
oN = fns.fn492
oF = fn1107
of = fn847
oV = fn1000
oA = fns.fn257
pg = fns.fn722
n6 = fn1064
pi = fns.fn287
n_ = fns.fn500
oD = fn973
n3 = fn872
o0 = fns.fn362
oM = fns.fn806
oe = fn844
oq = fns.fn360
px = fns.fn768
o2 = fns.fn159
oG = fns.fn817
oc = fns.fn815
oO = fns.fn338
oY = fn1074
n7 = fns.fn105
xS_29 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = n9, Copyable = true }, "|", xS_41 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
local xS_21 = {
    Info = xS_29:AddTab("Info", "info"),
    Main = xS_29:AddTab("Main", "package"),
    Player = xS_29:AddTab("Player", "person-standing"),
    Settings = xS_29:AddTab("Settings", "settings")
}
local xS_35 = fns.fn800
for k, v in { xS_21.Main, xS_21.Player, xS_21.Settings } do
    xS_35(v)
end
oE, xS_34, xS_8, Label, n5, xS_20 = nil, nil, nil, nil, nil, nil
xS_29 = 10
repeat
    xS_36 = (xS_29 * 1 + 0) % 3 + 1
    if xS_36 <= 2 then
        if xS_36 <= 1 then
            if (xS_29 * 2 + 7) * 16 % 3 == ((xS_29 * 2 + 7) * 16 + 3) % 3 then
                xS_20 = #n5 > 18
            else
                n5 = #xS_20 > 18
            end
            xS_29 = (xS_29 + 7) % 24
        else
            if (xS_29 * 1 + 2) * 21 % 4 == ((xS_29 * 1 + 2) * 21 + 4) % 4 then
                oE = "Unknown"
                pcall(fn874)
                xS_34 = xS_21.Info:AddLeftGroupbox("Account", "circle-user")
                xS_34:AddLabel(oo("User", o3.Name, xS_17), true)
                xS_34:AddLabel(oo("Status", "Keyless", xS_17), true)
                xS_34:AddLabel(oo("Executor", oE, xS_17), true)
                xS_8 = xS_21.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                xS_8:AddLabel(oz(xS_41 .. " [" .. tostring(game.PlaceId) .. "]", xS_5), true)
                xS_8:AddLabel(oo("Place ID", tostring(game.PlaceId), xS_5), true)
                Label = xS_8:AddLabel(oo("Session time", "0s", pF), true)
            else
                oo = "Unknown"
                pcall(fn874)
                pF = oE.Info:AddLeftGroupbox("Account", "circle-user")
                pF:AddLabel(xS_21("User", oz.Name, Label), true)
                pF:AddLabel(xS_21("Status", "Keyless", Label), true)
                pF:AddLabel(xS_21("Executor", oo, Label), true)
                xS_41 = oE.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                xS_41:AddLabel(xS_8(xS_5 .. " [" .. tostring(game.PlaceId) .. "]", xS_34), true)
                xS_41:AddLabel(xS_21("Place ID", tostring(game.PlaceId), xS_34), true)
                o3 = xS_41:AddLabel(xS_21("Session time", "0s", xS_17), true)
            end
            xS_29 = (xS_29 + 7) % 24
        end
    else
        xS_36 = {
            "rqnbnwfxss",
            "dyeduqcvooq",
            "rqllzteai",
            "qtaaruiyfwg",
            "battofwf",
            "odzetdzqti",
            "isndypcikje",
            "gsymca",
            "gjtm",
            "wfdi",
            "yeeehd"
        }
        local ze = xS_29
        xS_22 = xS_36[ze % 11 + 1]
        if xS_22:len() <= xS_22:gsub("(.)", "%1%1", ze % 3 % 2 + 1):len() then
            n5 = tostring(game.JobId)
        else
            oE = tostring(game.JobId)
        end
        xS_29 = (xS_29 + 19) % 24
    end
until (xS_29 * 23 + 6) % 24 == 11
if xS_20 then
    xS_29 = 0
    repeat
        if (xS_29 * 3 + 1) * 21 % 4 == ((xS_29 * 3 + 1) * 21 + 14) % 4 then
            n5 = string.sub(xS_20, 1, 18) .. "..."
        else
            xS_20 = string.sub(n5, 1, 18) .. "..."
        end
        xS_29 = (xS_29 + 1) % 4
    until (xS_29 * 3 + 1) % 4 == 0
end
xS_29 = xS_20 or n5
pn, CurrentCamera2, oy, ou, connection, connection2, n0, n8, om, pC, pd, oh = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local xS_40 = xS_29
xS_8:AddLabel(oo("Server", xS_40, xS_16), true)
xS_8:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
pn = os.clock()
task.spawn(worker)
local ScriptsGroup = xS_21.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(oz("Included in this hub", xS_16), true)
ScriptsGroup:AddLabel(oz(xS_41, xS_5), true)
xS_33 = xS_21.Info:AddRightGroupbox("Features", "list")
xS_33:AddLabel(oz("Auto Collect", xS_5), true)
xS_33:AddLabel(oz("Auto Sell", pF), true)
xS_33:AddLabel(oz("Auto Upgrades", xS_17), true)
xS_33:AddLabel(oz("Misc Utilities", xS_16), true)
xS_10 = xS_21.Info:AddRightGroupbox("Socials", "link")
xS_10:AddButton({ Text = "Discord", Func = oL })
xS_10:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
xS_36 = xS_21.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
xS_36:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
xS_36:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
xS_36:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
xS_36:AddButton({ Text = "Copy Discord Invite", Func = oL })
xS_20 = xS_21.Info:AddRightGroupbox("Donations", "heart")
xS_20:AddLabel(oz("All donations are optional but appreciated.", pF), true)
xS_20:AddLabel(oz("If you donate you get a special role, just PING after you donate.", xS_17), true)
xS_20:AddDivider()
xS_20:AddLabel(oz("LTC / Litecoin", xS_30), true)
xS_20:AddButton({ Text = "Copy Litecoin Address", Func = fns.onCopyLitecoinAddress })
xS_20:AddLabel(oz("BTC / Bitcoin", xS_3), true)
xS_20:AddButton({ Text = "Copy Bitcoin Address", Func = fns.onCopyBitcoinAddress })
xS_20:AddLabel(oz("ETH / Ethereum", xS_15), true)
xS_20:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
xS_20:AddLabel(oz("USDT", xS_28), true)
xS_20:AddButton({ Text = "Copy USDT Address", Func = fns.onCopyUSDTAddress })
xS_20:AddLabel(oz("Solana", xS_6), true)
xS_20:AddButton({ Text = "Copy Solana Address", Func = fns.onCopySolanaAddress })
xS_20:AddLabel(oz("PayPal", xS_18), true)
xS_20:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
xS_20:AddLabel(oz("Venmo", xS_4), true)
xS_20:AddButton({ Text = "Copy Venmo Link", Func = fns.onCopyVenmoLink })
xS_20:AddDivider()
xS_20:AddLabel(oz("Don't have any of the listed currencies but still wanna donate?", xS_16), true)
xS_20:AddLabel(oz("DM me and we'll work something out.", xS_5), true)
local FaqGroup = xS_21.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutomationGroup = xS_21.Main:AddLeftGroupbox("Automation", "bot")
AutomationGroup:AddToggle("AutoCollectBrainrot", { Text = "Auto Collect Brainrot", Default = false })
AutomationGroup:AddDropdown("GrabPriority", { Text = "Grab Priority", Values = xS_25, Default = "Best" })
AutomationGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
AutomationGroup:AddDropdown("UpgradeType", { Text = "Upgrade Type", Values = xS_2, Default = "All" })
AutomationGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
AutomationGroup:AddToggle("AutoBuyDrills", { Text = "Auto Buy Drills", Default = false })
local SellGroup = xS_21.Main:AddRightGroupbox("Sell", "circle-dollar-sign")
SellGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
SellGroup:AddDropdown("SellMode", { Text = "Sell Mode", Values = xS_14, Default = "All" })
SellGroup:AddDropdown("SellRarities", { Text = "Sell Rarities", Values = xS_27, Multi = true, Default = {} })
SellGroup:AddToggle("SellGrabPads", { Text = "Grab Pads Before Sell", Default = true })
xS_35 = xS_21.Main:AddRightGroupbox("Base", "house")
xS_35:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false })
xS_35:AddToggle("AutoUpgradeBase", { Text = "Auto Upgrade Base", Default = false })
Toggles.AutoCollectBrainrot:OnChanged(fns.fn631)
task.spawn(fns.worker2)
task.spawn(worker3)
task.spawn(fns.worker4)
task.spawn(fns.worker5)
task.spawn(fns.worker6)
task.spawn(fns.worker7)
task.spawn(fns.worker8)
xS_19 = xS_21.Player:AddLeftGroupbox("Movement", "footprints")
xS_19:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
xS_19:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
xS_19:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
xS_19:AddToggle("NoClip", { Text = "NoClip", Default = false })
xS_19:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
xS_38 = xS_21.Player:AddRightGroupbox("Fly", "feather")
xS_38:AddToggle("Fly", { Text = "Fly", Default = false })
xS_38:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
CurrentCamera2 = Workspace.CurrentCamera
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
RunService.RenderStepped:Connect(fns.onRenderStepped)
Toggles.Fly:OnChanged(fns.fn653)
Toggles.WalkSpeedEnabled:OnChanged(fn979)
n0 = function(iG)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not iG)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not iG
        end
    end)
    if not iG then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(o3, "GameplayPaused", false)
        else
            o3.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fns.fn329)
task.spawn(antiGameplayPauseLoop)
xS_22 = xS_21.Settings:AddLeftGroupbox("Menu")
xS_22:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = od.MenuKeybind
xS_22:AddButton("Unload", onUnload)
oy = tick()
ou = tick()
pcall(function()
    for i, v in ipairs(getconnections(o3.Idled)) do
        local wN = v
        pcall(function()
            wN:Disable()
        end)
    end
end)
n8 = fns.fn300
connection = UserInputService.InputBegan:Connect(fns.onInputBegan)
connection2 = UserInputService.InputChanged:Connect(fns.onInputChanged)
xS_22:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(fns.antiAfkLoop)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(xS_21.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/DrillBlocksForBrainrots")
xS_34 = SaveManager:BuildConfigSection(xS_21.Settings)
om = fns.fn386
pC = fns.fn667
pd = fn1007
oh = function(jP)
    local xr
    xr = nil
    local xs = type(jP) ~= "table" or type(jP.idx) ~= "string" or type(jP.type) ~= "string" or SaveManager.Ignore[jP.idx]
    if xs then
        return false
    end
    xr = om(jP.type, jP.idx)
    if not xr then
        return false
    end
    local xs_1 = pcall(function()
        if jP.type == "Input" then
            if type(jP.text) ~= "string" then
                return
            end
            xr:SetValue(jP.text)
        elseif jP.type == "ColorPicker" then
            xr:SetValueRGB(Color3.fromHex(jP.value), jP.transparency)
        elseif jP.type == "KeyPicker" then
            xr:SetValue({ jP.key, jP.mode, jP.modifiers })
            if jP.mode == "Toggle" and jP.toggled ~= nil then
                xr.Toggled = jP.toggled
                xr:Update()
            end
        else
            xr:SetValue(jP.value)
        end
    end)
    return xs_1
end
xS_34:AddDivider()
xS_34:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
xS_34:AddButton("Export Config to Clipboard", fns.onExportConfigToClipboard)
xS_34:AddButton("Import Config from Clipboard Text", fns.onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
Library:OnUnload(fns.fn292)
Library:Notify(xS_41 .. " loaded")
end)(...)

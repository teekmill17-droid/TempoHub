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
getgenv().TempoHoodSubtitle = "+1 ANIME LOOT UPGRADE"
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
local kn
local UserInputService
local jM
local kt
local ka
local jS
local jz
local kg
local jY
local jF
local km
local j3
local jL
local ks
local AutoTrainConfig
local jR
local kz
local Label
local kf
local jX
local jE
local kl
local j2
local j8
local jQ
local ky
local jx
local ke
local connection2
local jD
local Toggles
local j1
local jJ
local connection
local jP
local kx
local jw
local kd
local CurrentCamera
local jC
local VirtualUser
local kp
local j6
local jO
local jU
local jB
local Options
local HttpService
local jH
local SaveManager
local j5
local Library
local kb
local jT
local jZ
local jG
local function autoTrainLoop()
    while true do
        task.wait(0.35)
        if Library.Unloaded then
            break
        end
        if Toggles.AutoTrain and Toggles.AutoTrain.Value then
            continue
        end
        local l7_1 = Toggles.AutoFarmDungeons and Toggles.AutoFarmDungeons.Value
        local l7_2 = Toggles.AutoFarmSelected and Toggles.AutoFarmSelected.Value
        if not (l7_1 or l7_2) then
            j5 = 1
            j1 = nil
            continue
        end
        local l7_4 = j6
        if l7_2 then
            local l8_1 = tonumber(Options.SelectedStage.Value) or 1
            l7_4 = l8_1
        end
        local l8_2 = jR(jO)
        if not l8_2 then
            continue
        end
        local l9_1 = l8_2.ClearedStage or 0
        local l9_2 = math.min(j5, l7_4, l9_1 + 1)
        if l9_2 < 1 then
            l9_2 = 1
        end
        j5 = l9_2
        kn(l9_2, j1 ~= l9_2)
        j1 = l9_2
        local ma_1 = l8_2.EnteredStage == l9_2
        if ma_1 then
            ma_1 = (l8_2.AliveEnemies or 0) == 0
        end
        if ma_1 then
            ma_1 = (l8_2.ClearedStage or 0) >= l9_2
        end
        if ma_1 then
            local l8_4 = Toggles.AutoOpenChest and Toggles.AutoOpenChest.Value and kp()
            if l8_4 then
                continue
            end
            if j5 < l7_4 then
                j5 += 1
                j1 = nil
            else
                local l7_5 = ka()
                local Level = workspace:FindFirstChild("Level")
                local ma_2 = Level and Level:FindFirstChild(tostring(l9_2))
                local l8_6 = ma_2
                if ma_2 then
                    ma_2 = l8_6:FindFirstChild("Start")
                end
                local l8_7 = ma_2
                if l7_5 and l8_7 then
                    l7_5.CFrame = l8_7.CFrame + Vector3.new(0, 4, 0)
                    task.wait(0.4)
                    kn(l9_2, true)
                end
            end
        end
    end
end
local function fn67()
    if not Toggles.WalkSpeedEnabled.Value then
        local n5 = jZ()
        if n5 then
            n5.WalkSpeed = 16
        end
    end
end
local function fn89()
    j2(jT, "Copied Discord invite to clipboard")
end
local function fn114()
    if not Toggles.Fly.Value then
        local n3 = jZ()
        if n3 then
            n3.PlatformStand = false
        end
    end
end
local function onCopyJoinScript_JobID()
    local lw = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, kx)
    if setclipboard then
        setclipboard(lw)
    elseif toclipboard then
        toclipboard(lw)
    end
    Library:Notify("Copied join script to clipboard")
end
local function fn170(ab, ac, ad)
    return string.format("<b>%s</b> %s %s", ab, jL("-", "#5a6070"), jL(ac, ad))
end
local function onInputBegan()
    jF = tick()
end
local function fn206(fV, fW)
    local Type = fW.Type
    if Type == "Toggle" then
        return { idx = fV, type = "Toggle", value = fW.Value == true }
    elseif Type == "Slider" then
        return { idx = fV, type = "Slider", value = tostring(fW.Value) }
    elseif Type == "Dropdown" then
        return { idx = fV, type = "Dropdown", multi = fW.Multi == true, value = fW.Value }
    elseif Type == "Input" then
        local oJ = fW.Value or ""
        return { idx = fV, type = "Input", text = tostring(oJ) }
    elseif Type == "ColorPicker" then
        return { idx = fV, type = "ColorPicker", value = fW.Value:ToHex(), transparency = fW.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = fV,
            type = "KeyPicker",
            mode = fW.Mode,
            key = fW.Value,
            modifiers = fW.Modifiers,
            toggled = fW.Toggled
        }
    else
        return nil
    end
end
local function fn253()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    jC = tick()
end
local function onCopyPayPalLink()
    j2(kz, "Copied PayPal link")
end
local function worker()
    local lz_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local ly = math.floor(os.clock() - kd)
        if ly < 60 then
            lz_1 = ly .. "s"
        elseif ly < 3600 then
            lz_1 = string.format("%dm %ds", math.floor((ly) / (60)), ly % 60)
        else
            lz_1 = string.format("%dh %dm", math.floor((ly) / (3600)), math.floor((ly % 3600) / (60)))
        end
        Label:SetText(jB("Session time", lz_1, kg))
    end
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            j3(true)
        end
    end
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local nS_1 = jZ()
        if nS_1 then
            nS_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function onRscripts()
    if setclipboard then
        setclipboard(jS)
    elseif toclipboard then
        toclipboard(jS)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function fn365()
    j3(false)
    connection:Disconnect()
    connection2:Disconnect()
    pcall(function()
        kf:FireServer("Off")
    end)
    select("#", "Unloaded!")
end
local function autoClickLoop()
    while true do
        task.wait(3)
        if Library.Unloaded then
            break
        end
        if not (Toggles.AutoClick and Toggles.AutoClick.Value) then
            continue
        end
        local no_1 = jR(jx)
        if no_1 and no_1.Mode == "Off" then
            j8()
        end
    end
end
local function fn382(fN, fO)
    local oF_1 = (fN == "Toggle" and Toggles or Options)[fO]
    local oE_2 = type(oF_1) == "table" and oF_1.Type == fN
    return oE_2 and oF_1 or nil
end
local function onCopyEthereumAddress()
    j2(jG, "Copied Ethereum address")
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = jY.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local nH_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if nH_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function onExportConfigToClipboard()
    local pc_1
    local pb_1
    pb_1, pc_1 = pcall(HttpService.JSONEncode, HttpService, jQ())
    if not pb_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local pb_2 = setclipboard
    local ph = if pb_2 then 1 else 0
    local pf = 3333 * ph + 1986 * (1 - ph)
    local pg = 694 * ph + 3508 * (1 - ph)
    if not ((pf * 2069 + pg * 375 + pf * pg) % 16777213 == 9469329) then
        pb_2 = toclipboard
    end
    local pd = pb_2
    local pb_3 = type(pd) ~= "function" or not pcall(pd, pc_1)
    if pb_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function fn473(bs, bt)
    local lF = ka()
    local Level = workspace:FindFirstChild("Level")
    local lH = Level and Level:FindFirstChild(tostring(bs))
    local lG_1 = lH
    if lH then
        lH = lG_1:FindFirstChild("Zone")
    end
    local lG_2 = lH
    if not (lF and lG_2) then
        return
    end
    local lH_2 = lG_2.CFrame + Vector3.new(0, 4, 0)
    if bt or (lF.Position - lH_2.Position).Magnitude > 8 then
        lF.CFrame = lH_2
    end
end
local function fn484()
    pcall(function()
        kf:FireServer(kt())
    end)
end
local function onRenderStepped(eJ)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local nX_1 = jZ()
        if nX_1 then
            nX_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local nX_3 = ka()
        local nY = jZ()
        if nX_3 and nY then
            nY.PlatformStand = true
            local nY_1 = Vector3.zero
            local n2 = if UserInputService:IsKeyDown(Enum.KeyCode.W) then 1 else 0
            if n2 == 1 then
                nY_1 = nY_1 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                nY_1 = nY_1 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                nY_1 = nY_1 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                nY_1 = nY_1 + CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                nY_1 = nY_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                nY_1 = nY_1 - Vector3.new(0, 1, 0)
            end
            nX_3.Velocity = Vector3.zero
            if nY_1.Magnitude > 0 then
                nX_3.CFrame = nX_3.CFrame + nY_1.Unit * Options.FlySpeed.Value * eJ
            end
        end
    end
end
local function fn511()
    if not (Toggles.AutoClick and Toggles.AutoClick.Value) then
        return "Off"
    end
    local ni_1 = jR(jx)
    if ni_1 and ni_1.OwnsOP then
        return "OP"
    end
    return "Free"
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local oA = tick() - jF
            local oB = tick() - jC
            if oA >= 300 and oB >= 60 then
                pcall(km)
            else
                if oA < 300 and oB >= 300 then
                    pcall(km)
                end
            end
        end
    end
end
local function fn525()
    local lp_1
    local lo_1
    if identifyexecutor then
        lp_1, lo_1 = identifyexecutor()
        local lq = lp_1 ~= ""
        local lr = type(lp_1) == "string" and lq
        if lr then
            local lq_1 = type(lo_1) == "string" and lo_1 ~= "" and lp_1 .. " " .. lo_1
            jP = lq_1 or lp_1
        end
    end
end
local function onCopyLitecoinAddress()
    j2(jM, "Copied Litecoin address")
end
local function onCopySolanaAddress()
    j2(jz, "Copied Solana address")
end
local function fn580()
    j3(Toggles.AntiGameplayPause.Value)
end
local function fn621(d7)
    local nr = 1
    for i, v in ipairs(AutoTrainConfig.EQUIPMENT) do
        local nt = v.Requirement or {}
        if nt.Type == "Free" then
            nr = math.max(nr, v.EquipmentId)
        else
            if nt.Type == "Rebirth" and d7 >= (nt.Amount or math.huge) then
                nr = math.max(nr, v.EquipmentId)
            end
        end
    end
    return nr
end
local function fn631()
    local Character = jY.Character
    local lm = Character and Character:FindFirstChildOfClass("Humanoid")
    return lm
end
local function fn633(U)
    local DiscordGroup = U:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = jU })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = jU })
end
local function onUnload()
    Library:Unload()
end
local function fn690(Y, Z)
    return string.format('<font color="%s">%s</font>', Z, Y)
end
local function fn699()
    local oP = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local oQ = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if oQ then
                local oQ_1 = jX(k, v)
                if oQ_1 then
                    oP[#oP + 1] = oQ_1
                end
            end
        end
    end
    table.sort(oP, function(f7, f8)
        if f7.type ~= f8.type then
            return f7.type < f8.type
        end
        return f7.idx < f8.idx
    end)
    return { objects = oP }
end
local function onOnClientEvent(bO)
    if type(bO) == "number" then
        jw[bO] = true
    end
end
local function fn729()
    local Character = jY.Character
    local lj = Character and Character:FindFirstChild("HumanoidRootPart")
    return lj
end
local function autoTrainLoop2()
    while true do
        task.wait(0.5)
        if Library.Unloaded then
            break
        end
        if not (Toggles.AutoTrain and Toggles.AutoTrain.Value) then
            kb = nil
            continue
        end
        local nC_1 = jR(jE)
        local nD_1 = nC_1 and nC_1.Rebirths or 0
        local nC_3 = jH(nD_1)
        if nC_3 ~= kb then
            local AFK_Area = workspace:FindFirstChild("AFK Area")
            local nE = AFK_Area and AFK_Area:FindFirstChild(tostring(nC_3))
            local nE_1 = ka()
            if nE and nE_1 then
                nE_1.CFrame = nE.CFrame + Vector3.new(0, 4, 0)
                kb = nC_3
            end
        end
    end
end
local function fn774()
    if next(jw) ~= nil then
        return true
    end
    local LocalChestEffects = workspace:FindFirstChild("LocalChestEffects")
    if LocalChestEffects then
        for i, descendant in ipairs(LocalChestEffects:GetDescendants()) do
            local lX_1 = descendant:IsA("ProximityPrompt") and descendant.ActionText == "Open"
            if lX_1 then
                return true
            end
        end
    end
    return false
end
local function onCopyBitcoinAddress()
    j2(jJ, "Copied Bitcoin address")
end
local function autoRebirthLoop()
    while true do
        task.wait(0.7)
        if Library.Unloaded then
            break
        end
        if not (Toggles.AutoRebirth and Toggles.AutoRebirth.Value) then
            continue
        end
        local nf_1 = jR(jE)
        if nf_1 and nf_1.CanRebirth and not nf_1.IsMax then
            pcall(function()
                kl:FireServer()
            end)
        end
    end
end
local function fn806(N, O)
    if setclipboard then
        setclipboard(N)
    elseif toclipboard then
        toclipboard(N)
    end
    Library:Notify(O)
end
local function fn813(cY)
    local mG = ky[cY.Quality] or 0
    local mJ = (cY.HealthBonus or 0) + (cY.Defense or 0) * 1000
    local mK = cY.AttackBonus
    local mQ = if mK then 1 else 0
    local mO = 252 * mQ + 1837 * (1 - mQ)
    local mP = 4026 * mQ + 1630 * (1 - mQ)
    if not ((mO * 3321 + mP * 2961 + mO * mP) % 16777213 == 13772430) then
        mK = 0
    end
    return mG * 1000000 + (mJ + mK * 1000 + (cY.CritRate or 0) * 1000)
end
local function onCopyUSDTAddress()
    j2(jD, "Copied USDT address")
end
local function onInputChanged(fr)
    local UserInputType = fr.UserInputType
    local ov = UserInputType == Enum.UserInputType.MouseMovement
    local oz = if ov then 1 else 0
    local ox = 285 * oz + 846 * (1 - oz)
    local oy = 3422 * oz + 2763 * (1 - oz)
    if not ((ox * 3054 + oy * 3349 + ox * oy) % 16777213 == 13305938) then
        ov = UserInputType == Enum.UserInputType.Gamepad1
    end
    if ov then
        jF = tick()
    end
end
local function onCopyVenmoLink()
    j2(ks, "Copied Venmo link")
end
local function onImportConfigFromClipboardTex()
    local pk_1
    local pi = Options.SaveManager_ImportSource.Value or ""
    local pi_1
    local pj = tostring(pi):match("^%s*(.-)%s*$")
    if pj == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    pi_1, pk_1 = pcall(HttpService.JSONDecode, HttpService, pj)
    local pj_1 = not pi_1 or type(pk_1) ~= "table" or type(pk_1.objects) ~= "table"
    if pj_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local pi_2 = 0
    for i, v in ipairs(pk_1.objects) do
        if ke(v) then
            pi_2 += 1
        end
    end
    if pi_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local pk_2 = pi_2 == 1 and ""
    local pu = if pk_2 then 1 else 0
    local ps = 3760 * pu + 2377 * (1 - pu)
    local pt = 75 * pu + 1120 * (1 - pu)
    if not ((ps * 2272 + pt * 1477 + ps * pt) % 16777213 == 8935495) then
        pk_2 = "s"
    end
    Library:Notify(("Imported %d setting%s"):format(pi_2, pk_2), 6)
end
jw = nil
jx = nil
Label = nil
jz = nil
jB = nil
jC = nil
jD = nil
jE = nil
jF = nil
jG = nil
jH = nil
jJ = nil
jL = nil
jM = nil
jO = nil
jP = nil
jQ = nil
jR = nil
jS = nil
jT = nil
jU = nil
CurrentCamera = nil
connection2 = nil
jX = nil
jY = nil
jZ = nil
HttpService = nil
VirtualUser = nil
j1 = nil
j2 = nil
j3 = nil
UserInputService = nil
j5 = nil
j6 = nil
connection = nil
j8 = nil
AutoTrainConfig = nil
ka = nil
kb = nil
kd = nil
ke = nil
kf = nil
kg = nil
Options = nil
local jA, jI, jK, jN, WeaponConfig, kh
Toggles = nil
kl = nil
km = nil
kn = nil
SaveManager = nil
kp = nil
ks = nil
kt = nil
Library = nil
kx = nil
ky = nil
kz = nil
local kj, kq, kr, kw, kY
local kX_1
local kJ_1
local Window, kG_2
Library, SaveManager, Toggles, Options, UserInputService, VirtualUser, HttpService, jY, jT, jS, jO, jN, jK, jI, jE, jA, jx, kw, kq, kl, kj, kf, WeaponConfig, AutoTrainConfig, j6, kg, Window, jP, Label, kx, kJ_1, j2, jU, jL, jB, ka, jZ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
jY = Players.LocalPlayer
local kL = "+1 Anime Loot Upgrade"
jT = "https://discord.gg/K7Qxnxkk46"
if (ka or ka or (kJ_1 or not ka)) and ((not Window or not ka) and (ka or not Options)) or not ((ka or ka or (kJ_1 or not ka)) and ((not Window or not ka) and (ka or not Options))) then
    jS = "https://discord.gg/K7Qxnxkk46"
else
    jY = "https://discord.gg/K7Qxnxkk46"
end
local Remote = ReplicatedStorage.Remote
local Event = Remote.Event
local Function = Remote.Function
jO = Function.Stage["[C-S]GetStageState"]
jN = Function.Weapon["[C-S]GetWeaponState"]
jK = Function.Equipment["[C-S]GetEquipmentState"]
jI = Function.Currency["[C-S]GetCurrencyData"]
jE = Function.Rebirth["[C-S]GetState"]
jA = Function.Talent["[C-S]GetState"]
jx = Function.AutoClick["[C-S]GetState"]
kw = Function.Equipment["[C-S]EquipItem"]
kq = Event.Chest["[C-S]RequestOpen"]
local kS = Event.Chest["[S-C]ChestSpawned"]
kl = Event.Rebirth["[C-S]TryRebirth"]
kj = Event.Talent["[C-S]Allocate"]
kf = Event.AutoClick["[C-S]SetMode"]
WeaponConfig = require(ReplicatedStorage.Config.WeaponConfig)
AutoTrainConfig = require(ReplicatedStorage.Config.AutoTrainConfig)
j6 = 14
j2 = fn806
jU = fn89
jL = fn690
jB = fn170
local kO = "#7fd47f"
local kN = "#6ec1ff"
kg = "#e8a34d"
local kM = "#8b93a3"
ka = fn729
jZ = fn631
if (not kq and not jx and (not jx and RunService) or kq and not j2 and (RunService or not RunService)) and ((RunService or RunService) and (jx and not j2) or (not RunService or jT or kq and jT)) or not ((not kq and not jx and (not jx and RunService) or kq and not j2 and (RunService or not RunService)) and ((RunService or RunService) and (jx and not j2) or (not RunService or jT or kq and jT))) then
    Window = Library:CreateWindow({
        Title = "Tempo Hub",
        Footer = { { Text = jT, Copyable = true }, "|", kL },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0
    })
else
    kL = Window:CreateWindow({
        Title = "Tempo Hub",
        Icon = 78539693571783,
        ShowCustomCursor = false,
        NotifySide = "Right",
        CornerRadius = 0,
        Footer = { "|", jT, { Text = Library, Copyable = true } }
    })
end
local kQ = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gamepad-2"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
kQ.Farm = kQ.Main:AddSubTab("Farm", "swords")
kQ.Progress = kQ.Main:AddSubTab("Progress", "trending-up")
jP = "Unknown"
pcall(fn525)
local AccountGroup = kQ.Info:AddLeftGroupbox("Account", "circle-user")
AccountGroup:AddLabel(jB("User", jY.Name, kO), true)
AccountGroup:AddLabel(jB("Status", "Keyless", kO), true)
AccountGroup:AddLabel(jB("Executor", jP, kO), true)
local kK = kQ.Info:AddLeftGroupbox("Game Info", "gamepad-2")
kK:AddLabel(jL(kL .. " [" .. tostring(game.PlaceId) .. "]", kN), true)
kK:AddLabel(jB("Place ID", tostring(game.PlaceId), kN), true)
Label = kK:AddLabel(jB("Session time", "0s", kg), true)
kx = tostring(game.JobId)
local kJ_2 = #kx > 18
if kJ_2 then
    local kA_1 = 1
    repeat
        if (kA_1 * 2 + 5) * 4 % 3 == ((kA_1 * 2 + 5) * 4 + 6) % 3 then
            kJ_2 = string.sub(kx, 1, 18) .. "..."
        else
            kx = string.sub(kJ_2, 1, 18) .. "..."
        end
        kA_1 = (kA_1 + 2) % 4
    until (kA_1 * 3 + 0) % 4 == 1
end
local kA_2 = kJ_2
local k5 = if kA_2 then 1 else 0
local k3 = 1382 * k5 + 3631 * (1 - k5)
local k4 = 2460 * k5 + 1531 * (1 - k5)
if not ((k3 * 866 + k4 * 2116 + k3 * k4) % 16777213 == 9801892) then
    kA_2 = kx
end
kY, kd, kG_2, jM, jJ, jG, jD, jz, kz, ks, kX_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if ((kG_2 and kG_2 or "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w") and (false and not kG_2 or false) and ("#26a17b" or (not kG_2 or not kG_2) or (kG_2 or false) and false) or ("#26a17b" and (kG_2 and jz or not kG_2 and false) or "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w" and (kG_2 or kG_2) and ((not kG_2 or false) and "#26a17b"))) and not ((kG_2 and kG_2 or "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w") and (false and not kG_2 or false) and ("#26a17b" or (not kG_2 or not kG_2) or (kG_2 or false) and false) or ("#26a17b" and (kG_2 and jz or not kG_2 and false) or "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w" and (kG_2 or kG_2) and ((not kG_2 or false) and "#26a17b"))) then
    local kA_3 = kd
    kY:AddLabel(kM("Server", kA_3, jB), true)
    kY:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
    os.clock()
else
    kY = kA_2
    kK:AddLabel(jB("Server", kY, kM), true)
    kK:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
    kd = os.clock()
end
task.spawn(worker)
local ScriptsGroup = kQ.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(jL("Included in this hub", kM), true)
ScriptsGroup:AddLabel(jL(kL, kN), true)
local FeaturesGroup = kQ.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(jL("Auto Farm Dungeons", kN), true)
FeaturesGroup:AddLabel(jL("Auto Open Chest", kg), true)
FeaturesGroup:AddLabel(jL("Auto Equip / Buy / Attribute", kO), true)
FeaturesGroup:AddLabel(jL("Auto Rebirth / Train / Click", kM), true)
local SocialsGroup = kQ.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = jU })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = kQ.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = jU })
jM = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
jJ = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
jG = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
jD = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
jz = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
kz = ""
ks = ""
local kZ = "#345d9d"
if (not kY and false or "" or "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99") and not (not kY and false or "" or "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99") then
else
    kX_1 = "#f7931a"
end
local kW = "#627eea"
local kV = "#26a17b"
local kU = "#14f195"
local kJ_3 = "#0070ba"
local kI_1 = "#008cff"
local DonationsGroup = kQ.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(jL("All donations are optional but appreciated.", kg), true)
DonationsGroup:AddLabel(jL("If you donate you get a special role, just PING after you donate.", kO), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(jL("LTC / Litecoin", kZ), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(jL("BTC / Bitcoin", kX_1), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(jL("ETH / Ethereum", kW), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(jL("USDT", kV), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(jL("Solana", kU), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(jL("PayPal", kJ_3), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(jL("Venmo", kI_1), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(jL("Don't have any of the listed currencies but still wanna donate?", kM), true)
DonationsGroup:AddLabel(jL("DM me and we'll work something out.", kN), true)
local FaqGroup = kQ.Info:AddRightGroupbox("FAQ", "circle-help")
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
for k, v in kQ do
    if v ~= kQ.Main and v ~= kQ.Info then
        fn633(v)
    end
end
kn, jR = nil, nil
kn = fn473
jR = function(bE)
    local lK_1
    local lJ_1
    lJ_1, lK_1 = pcall(function()
        return bE:InvokeServer()
    end)
    local lL = lJ_1 and type(lK_1) == "table"
    if lL then
        return lK_1
    end
    return nil
end
local DungeonFarmGroup = kQ.Farm:AddLeftGroupbox("Dungeon Farm", "swords")
DungeonFarmGroup:AddToggle("AutoFarmDungeons", { Text = "Auto Farm Dungeons", Default = false })
DungeonFarmGroup:AddToggle("AutoFarmSelected", { Text = "Auto Farm Selected Dungeon", Default = false })
local kB_2 = {}
local le = 1
local lc = j6
while le <= lc do
    local lf = le
    kB_2[lf] = tostring(lf)
    le += 1
end
jw, j5, j1, ky, kb, CurrentCamera, jF, jC, connection, connection2, kp, kr, kt, j8, jH, j3, km, kh, jX, jQ, ke = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
DungeonFarmGroup:AddDropdown("SelectedStage", { Values = kB_2, Default = "1", Multi = false })
local ChestsGroup = kQ.Farm:AddRightGroupbox("Chests", "gift")
ChestsGroup:AddToggle("AutoOpenChest", { Text = "Auto Open Chest", Default = false })
jw = {}
kS.OnClientEvent:Connect(onOnClientEvent)
kp = fn774
j5 = 1
j1 = nil
task.spawn(autoTrainLoop)
task.spawn(function()
    while true do
        task.wait(0.25)
        if Library.Unloaded then
            break
        end
        if not (Toggles.AutoOpenChest and Toggles.AutoOpenChest.Value) then
            continue
        end
        for k in pairs(jw) do
            local mj = k
            pcall(function()
                kq:FireServer(mj)
            end)
            jw[mj] = nil
        end
        for i, descendant in ipairs(workspace:GetDescendants()) do
            local mp = descendant
            local me_1 = mp:IsA("ProximityPrompt") and mp.ActionText == "Open"
            if me_1 then
                pcall(function()
                    if fireproximityprompt then
                        fireproximityprompt(mp)
                    end
                end)
            end
        end
    end
end)
kL = kQ.Progress:AddLeftGroupbox("Weapons", "sword")
kL:AddToggle("AutoBuyWeapons", { Text = "Auto Buy Weapons", Default = false })
task.spawn(function()
    local mz = false
    repeat
        task.wait(0.6)
        if Library.Unloaded then
            mz = true
        else
            if not not (Toggles.AutoBuyWeapons and Toggles.AutoBuyWeapons.Value) then
                local ms_1 = jR(jN)
                local mt = jR(jI)
                if not (not ms_1 or not mt) then
                    local mu_1 = mt.Trophies or 0
                    local mv_1 = ms_1.Unlocked or {}
                    local WeaponArea = workspace:FindFirstChild("WeaponArea")
                    local mq = ka()
                    if not (not WeaponArea or not mq) then
                        for i, v in ipairs(WeaponConfig.WEAPONS) do
                            local mv_3 = v.UnlockType == "Trophies" and not mv_1[tostring(i)]
                            if mv_3 then
                                if mu_1 >= (v.UnlockCost or math.huge) then
                                    local mr = WeaponArea:FindFirstChild(tostring(i))
                                    if mr and firetouchinterest then
                                        pcall(function()
                                            firetouchinterest(mq, mr, 0)
                                            task.wait(0.1)
                                            firetouchinterest(mq, mr, 1)
                                        end)
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    until mz
end)
local EquipmentGroup = kQ.Progress:AddRightGroupbox("Equipment", "shirt")
EquipmentGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best Equipment", Default = false })
ky = { Common = 1, UnCommon = 2, Rare = 3, Epic = 4, Legendary = 5, Mythical = 6, Exclusive = 7 }
kr = fn813
task.spawn(function()
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        if not (Toggles.AutoEquipBest and Toggles.AutoEquipBest.Value) then
            continue
        end
        local mR_1 = jR(jK)
        local mS = not mR_1 or type(mR_1.Items) ~= "table"
        if mS then
            continue
        end
        local mS_1 = {}
        for i, v in ipairs(mR_1.Items) do
            local Slot = v.Slot
            if Slot then
                local mU_1 = mS_1[Slot]
                local mV = not mU_1 or kr(v) > kr(mU_1)
                if mV then
                    mS_1[Slot] = v
                end
            end
        end
        local mU_2 = mR_1.Equipped or {}
        for k, v in pairs(mS_1) do
            local m7 = v
            if mU_2[k] ~= m7.Uid then
                pcall(function()
                    kw:InvokeServer(m7.Uid)
                end)
            end
        end
    end
end)
kM = kQ.Progress:AddLeftGroupbox("Attributes", "star")
kM:AddToggle("AutoAttribute", { Text = "Auto Attribute", Default = false })
kM:AddDropdown("AttributeStat", { Values = { "Attack", "Defense", "Health" }, Default = "Attack", Multi = false })
task.spawn(function()
    local ne = false
    repeat
        local Value
        task.wait(0.5)
        if Library.Unloaded then
            ne = true
        else
            if not not (Toggles.AutoAttribute and Toggles.AutoAttribute.Value) then
                local na_1 = jR(jA)
                if not not na_1 then
                    local m9 = na_1.AvailablePoints or 0
                    if m9 > 0 then
                        Value = Options.AttributeStat.Value
                        pcall(function()
                            kj:FireServer(Value, m9)
                        end)
                    end
                end
            end
        end
    until ne
end)
local RebirthGroup = kQ.Progress:AddRightGroupbox("Rebirth", "rotate-ccw")
RebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
task.spawn(autoRebirthLoop)
kN = kQ.Progress:AddRightGroupbox("Auto Click", "mouse-pointer-click")
kN:AddToggle("AutoClick", { Text = "Auto Click", Default = false })
kt = fn511
j8 = fn484
Toggles.AutoClick:OnChanged(j8)
task.spawn(autoClickLoop)
local AutoTrainGroup = kQ.Progress:AddLeftGroupbox("Auto Train", "dumbbell")
AutoTrainGroup:AddToggle("AutoTrain", { Text = "Auto Train", Default = false })
jH = fn621
kb = nil
task.spawn(autoTrainLoop2)
local MovementGroup = kQ.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = kQ.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn114)
Toggles.WalkSpeedEnabled:OnChanged(fn67)
j3 = function(e3)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not e3)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not e3
        end
    end)
    if not e3 then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(jY, "GameplayPaused", false)
        else
            jY.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fn580)
task.spawn(antiGameplayPauseLoop)
local MenuGroup = kQ.Settings:AddLeftGroupbox("Menu", "settings")
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
jF = tick()
jC = tick()
pcall(function()
    for i, v in ipairs(getconnections(jY.Idled)) do
        local op = v
        pcall(function()
            op:Disable()
        end)
    end
end)
km = fn253
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(antiAfkLoop)
MenuGroup:AddButton("Unload", onUnload)
Library:OnUnload(fn365)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Linoria")
ThemeManager:ApplyToTab(kQ.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/AnimeLootUpgrade")
kK = SaveManager:BuildConfigSection(kQ.Settings)
kh = fn382
jX = fn206
jQ = fn699
if not jw or kM or not jw and not j1 or (not jw or not jw) and (not kM and not kM) or (kM or not jw) and (not jw or j1) and (not jw or not jw or (j1 or not jw)) or not (not jw or kM or not jw and not j1 or (not jw or not jw) and (not kM and not kM) or (kM or not jw) and (not jw or j1) and (not jw or not jw or (j1 or not jw))) then
    ke = function(ga)
        local o8
        o8 = nil
        local o9 = type(ga) ~= "table" or type(ga.idx) ~= "string" or type(ga.type) ~= "string" or SaveManager.Ignore[ga.idx]
        if o9 then
            return false
        end
        o8 = kh(ga.type, ga.idx)
        if not o8 then
            return false
        end
        local o9_1 = pcall(function()
            if ga.type == "Input" then
                if type(ga.text) ~= "string" then
                    return
                end
                o8:SetValue(ga.text)
            elseif ga.type == "ColorPicker" then
                o8:SetValueRGB(Color3.fromHex(ga.value), ga.transparency)
            elseif ga.type == "KeyPicker" then
                o8:SetValue({ ga.key, ga.mode, ga.modifiers })
                if ga.mode == "Toggle" and ga.toggled ~= nil then
                    o8.Toggled = ga.toggled
                    o8:Update()
                end
            else
                o8:SetValue(ga.value)
            end
        end)
        return o9_1
    end
end
kK:AddDivider()
kK:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
kK:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
kK:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
end)(...)

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
getgenv().TempoHoodSubtitle = "MERGE A MOB!"
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
local f1
local gn
local f4
local f7
local gt
local ga
local gw
local RequestRebirth
local connection2
local fY
local gj
local gp
local f6
local connection
local Label
local gc
local gy
local gf
local gB
local gi
local f_
local gl
local Toggles
local gr
local gu
local enchants
local Workspace
local gA
local gh
local fZ
local gk
local function fn11(aq)
    if aq:IsA("Model") then
        return aq.PrimaryPart
    elseif aq:IsA("BasePart") then
        return aq
    else
        return nil
    end
end
local function onMergeWalkSpeed(bM)
    gu = bM
end
local function autoRebirthLoop()
    while not gf.Unloaded do
        task.wait(2)
        if Toggles.AutoRebirth.Value and fZ and fZ.rebirth then
            local rebirth = fZ.rebirth
            local jp = rebirth.level < rebirth.maxLevel and rebirth.cap <= f7()
            if jp then
                pcall(function()
                    RequestRebirth:FireServer()
                end)
            end
        end
    end
end
local function autoEnchantLoop()
    while not gf.Unloaded do
        task.wait(1)
        if Toggles.AutoEnchant.Value then
            local jB = gk:GetAttribute("Crystals") or 0
            if jB >= enchants.COST_CRYSTALS then
                pcall(function()
                    gh:FireServer()
                end)
            end
        end
    end
end
local function fn91()
    local ih_1
    local ig_1
    if identifyexecutor then
        ih_1, ig_1 = identifyexecutor()
        local ii = ih_1 ~= ""
        local ij = type(ih_1) == "string" and ii
        if ij then
            local ii_1 = type(ig_1) == "string" and ig_1 ~= "" and ih_1 .. " " .. ig_1
            gc = ii_1 or ih_1
        end
    end
end
local function onOnClientEvent(T)
    gB = T
end
local function fn109(aJ)
    local hQ = {}
    for i, child in ipairs(aJ:GetChildren()) do
        if f_(child) then
            local attr = child:GetAttribute("Tier")
            if attr then
                local hS_1 = hQ[attr] or 0
                hQ[attr] = hS_1 + 1
            end
        end
    end
    local hR_2 = nil
    for k, v in pairs(hQ) do
        local hQ_1 = v >= 2
        if hQ_1 then
            hQ_1 = not hR_2 or k < hR_2
        end
        if hQ_1 then
            hR_2 = k
        end
    end
    return hR_2
end
local function onRscripts()
    if setclipboard then
        setclipboard(gA)
    elseif toclipboard then
        toclipboard(gA)
    end
    gf:Notify("Copied Rscripts profile to clipboard")
end
local function fn202(as, at, au, av)
    local hE_1
    local hD_1
    hE_1, hD_1 = nil, nil
    for i, child in ipairs(as:GetChildren()) do
        local hF = child ~= av and child:GetAttribute("Tier") == at and f_(child)
        if hF then
            local hF_1 = gw(child)
            if hF_1 then
                local hG = hF_1.Position.X - au.X
                local hH = hF_1.Position.Z - au.Z
                local hI = math.sqrt(hG * hG + hH * hH)
                if not hD_1 or hI < hD_1 then
                    hE_1, hD_1 = hF_1, hI
                end
            end
        end
    end
    return hE_1
end
local function onInputBegan()
    gl = tick()
end
local function onOnClientEvent2(R)
    fZ = R
end
local function onUnload()
    gf:Unload()
end
local function antiAfkLoop()
    while not gf.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local i1 = tick() - gl
            local i2 = tick() - gj
            if i1 >= 300 and i2 >= 60 then
                pcall(f4)
            else
                if i1 < 300 and i2 >= 300 then
                    pcall(f4)
                end
            end
        end
    end
end
local function onUpgradeSelection(bP)
    local iB = {}
    local iC = { Tier = "TIER", ["Lock Base"] = "LOCKBASE", Max = "MAX" }
    if type(bP) == "table" then
        for k, v in pairs(bP) do
            local iE = v == true and k
            if not iE then
                local iD_1 = type(v) == "string" and v
                iE = iD_1 or nil
            end
            local iD_2 = iE
            if iE then
                iE = iC[iD_2]
            end
            local iD_3 = iE
            if iD_3 then
                iB[#iB + 1] = iD_3
            end
        end
    end
    gy = iB
end
local function fn335()
    local Character = gk.Character
    local hf = Character and Character:FindFirstChild("HumanoidRootPart")
    return hf
end
local function fn355()
    local Bases = Workspace:FindFirstChild("Bases")
    if not Bases then
        return nil
    end
    for i, child in ipairs(Bases:GetChildren()) do
        local Nukes = child:FindFirstChild("Nukes")
        if Nukes then
            for i, child in ipairs(Nukes:GetChildren()) do
                if child:GetAttribute("OwnerUserId") == gk.UserId then
                    return Nukes
                end
            end
        end
    end
    return nil
end
local function fn365(a7, a8)
    return string.format('<font color="%s">%s</font>', a8, a7)
end
local function fn383()
    setclipboard(fY)
    gf:Notify("Copied Discord invite to clipboard")
end
local function fn397()
    local Character = gk.Character
    local hi = Character and Character:FindFirstChildOfClass("Humanoid")
    return hi
end
local function onCopyJoinScript_JobID()
    local ip = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, gp)
    if setclipboard then
        setclipboard(ip)
    elseif toclipboard then
        toclipboard(ip)
    end
    gf:Notify("Copied join script to clipboard")
end
local function fn430()
    if not workspace.CurrentCamera then
        return
    end
    gn:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    gn:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    gj = tick()
end
local function fn454(ba, bb, bc)
    return string.format("<b>%s</b> %s %s", ba, ga("-", "#5a6070"), ga(bb, bc))
end
local function fn461(an)
    local attr = an:GetAttribute("State")
    return attr == "floor" or attr == "based"
end
local function fn470()
    connection:Disconnect()
    connection2:Disconnect()
end
local function onInputChanged(ce)
    local UserInputType = ce.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        gl = tick()
    end
end
local function fn534(u)
    local DiscordGroup = u:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = gt })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = gt })
end
local function fn535()
    local h5 = gr()
    if not h5 then
        return 0
    end
    local h6 = 0
    for i, child in ipairs(h5:GetChildren()) do
        local attr = child:GetAttribute("Tier")
        local h7 = type(attr) == "number" and attr > h6
        if h7 then
            h6 = attr
        end
    end
    return h6
end
local function worker()
    local iv_1
    while true do
        task.wait(1)
        if gf.Unloaded then
            break
        end
        local iu = math.floor(os.clock() - f6)
        if iu < 60 then
            iv_1 = iu .. "s"
        elseif iu < 3600 then
            iv_1 = string.format("%dm %ds", math.floor((iu) / (60)), iu % 60)
        else
            iv_1 = string.format("%dh %dm", math.floor((iu) / (3600)), math.floor((iu % 3600) / (60)))
        end
        Label:SetText(f1("Session time", iv_1, gi))
    end
end
fY = nil
fZ = nil
f_ = nil
f1 = nil
f4 = nil
Toggles = nil
f6 = nil
f7 = nil
enchants = nil
ga = nil
gc = nil
connection2 = nil
gf = nil
gh = nil
gi = nil
gj = nil
gk = nil
gl = nil
gn = nil
gp = nil
gr = nil
connection = nil
gt = nil
gu = nil
Label = nil
gw = nil
Workspace = nil
gy = nil
RequestRebirth = nil
gA = nil
gB = nil
local fX, Drop, f2, HeldNuke, f9, gb, ge, gg, gm, SwordShopRequest, gq
local gI_1, gI_2
local gH_1, gH_2
local gG_1, gG_2
local gF_1, gF_2
local gE_2
local gD_1, gD_2
local Players
local Options, gO, gP, gQ, gR, gS, gX
local gM_1
local gL_1
local gK_1
Players, gL_1, Workspace, gR, gn, gk, gG_1, gf, gP, gO, Toggles, Options, fY, gA, gS, gF_1, gD_1, Drop, fX, RequestRebirth, gK_1, gq, SwordShopRequest, gH_1, gh, gg, gb, enchants, HeldNuke, fZ, gB, gy, gu, gI_1, gQ, gt, gM_1, ge, f2, gr, f_, gw, gm, f9, f7 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local gJ = 26
repeat
    local gT_1 = (gJ * 19 + 21) % 28 + 1
    if gT_1 <= 14 then
        if gT_1 <= 7 then
            if gT_1 <= 4 then
                if gT_1 <= 2 then
                    if gT_1 <= 1 then
                        local gU_1 = {
                            "gon",
                            "klypgy",
                            "qsuadfq",
                            "hftdleblgjr",
                            "ctn",
                            "sqnlbsvf",
                            "uquoca",
                            "xezeln",
                            "kyqyhuw",
                            "kpkyyzdjerz",
                            "fgl",
                            "pwpdyyj"
                        }
                        local kl = gJ
                        local gV_1 = gU_1[kl % 12 + 1]
                        if gV_1:len() <= gV_1:gsub("(.)", "%1%1", kl % 3 % 2 + 1):len() then
                            fX = gF_1:WaitForChild("PurchaseUpgrade")
                            RequestRebirth = gF_1:WaitForChild("RequestRebirth")
                        else
                            gF_1 = RequestRebirth:WaitForChild("PurchaseUpgrade")
                            fX = RequestRebirth:WaitForChild("RequestRebirth")
                        end
                        gJ = (gJ + 87) % 112
                    else
                        local gU_2 = (vector.create((gJ * 2 + 2) % 11 + 1, (gJ * 11 + 7) % 13 + 1, (gJ * 12 + 8) % 17 + 1))
                        local gV_2 = (vector.create((gJ * 1 + 9) % 11 + 1, (gJ * 11 + 8) % 13 + 1, (gJ * 15 + 11) % 17 + 1))
                        local kw = vector.cross(gU_2, gV_2)
                        local kx = vector.dot(gU_2, gV_2)
                        if vector.dot(kw, kw) + kx * kx == vector.dot(gU_2, gU_2) * vector.dot(gV_2, gV_2) + 4 then
                            gF_1 = gK_1:WaitForChild("StateUpdate")
                        else
                            gK_1 = gF_1:WaitForChild("StateUpdate")
                        end
                        gJ = (gJ + 87) % 112
                    end
                elseif gT_1 <= 3 then
                    if (gJ * 1 + 6) * 17 % 4 == ((gJ * 1 + 6) * 17 + 8) % 4 then
                        gq = gF_1:WaitForChild("SwordBuy")
                        SwordShopRequest = gF_1:WaitForChild("SwordShopRequest")
                    else
                        gF_1 = SwordShopRequest:WaitForChild("SwordBuy")
                        gq = SwordShopRequest:WaitForChild("SwordShopRequest")
                    end
                    gJ = (gJ + 3) % 112
                else
                    local gU_3 = (vector.create((gJ * 5 + 8) % 11 + 1, (gJ * 3 + 13) % 13 + 1, (gJ * 6 + 9) % 17 + 1))
                    local gV_3 = (vector.create((gJ * 2 + 6) % 11 + 1, (gJ * 2 + 12) % 13 + 1, (gJ * 10 + 1) % 17 + 1))
                    local gW_1 = (vector.create((gJ * 3 + 8) % 11 + 1, (gJ * 7 + 2) % 13 + 1, (gJ * 13 + 5) % 17 + 1))
                    gX = (vector.create((gJ * 5 + 3) % 5 + 1, (gJ * 2 + 1) % 7 + 1, (gJ * 3 + 1) % 9 + 1))
                    if vector.dot(vector.cross(gU_3, (vector.cross(gV_3, gW_1))), gX) == vector.dot(gV_3 * vector.dot(gU_3, gW_1) - gW_1 * vector.dot(gU_3, gV_3), gX) then
                        gH_1 = gF_1:WaitForChild("SwordShopState")
                    else
                        gF_1 = gH_1:WaitForChild("SwordShopState")
                    end
                    gJ = (gJ + 59) % 112
                end
            elseif gT_1 <= 6 then
                if gT_1 <= 5 then
                    local gU_4 = (vector.create((gJ * 4 + 7) % 11 + 1, (gJ * 7 + 7) % 13 + 1, (gJ * 3 + 13) % 17 + 1))
                    local j_ = vector.floor(gU_4) + vector.ceil(gU_4 * -1)
                    if vector.dot(j_, j_) == 0 then
                        gh = gF_1:WaitForChild("EnchantRoll")
                        gg = require(gD_1:WaitForChild("BigNum"))
                        gb = require(gD_1:WaitForChild("SwordConfig"))
                    else
                        gF_1 = gD_1:WaitForChild("EnchantRoll")
                        gb = require(gh:WaitForChild("BigNum"))
                        gg = require(gh:WaitForChild("SwordConfig"))
                    end
                    gJ = (gJ + 31) % 112
                else
                    if (gJ * 3 + 4) * 21 % 4 == ((gJ * 3 + 4) * 21 + 8) % 4 then
                        enchants = require(gD_1:WaitForChild("enchants"))
                        local NukeClientModules = gk:WaitForChild("PlayerScripts"):WaitForChild("NukeClientModules")
                        HeldNuke = require(NukeClientModules:WaitForChild("HeldNuke"))
                    else
                        require(HeldNuke:WaitForChild("enchants"))
                        gD_1 = enchants:WaitForChild("PlayerScripts"):WaitForChild("NukeClientModules")
                        gk = require(gD_1:WaitForChild("HeldNuke"))
                    end
                    gJ = (gJ + 87) % 112
                end
            else
                local km = bit32.rrotate(bit32.bxor(bit32.lrotate(gJ, 27), string.byte(tostring(enchants))), 15)
                if bit32.bxor(bit32.lrotate(bit32.bxor(km, 1451273504), 30), 362818376) ~= bit32.lrotate(km, 30) then
                    gy = nil
                    gu = nil
                    gB = {}
                    fZ = 22
                else
                    fZ = nil
                    gB = nil
                    gy = {}
                    gu = 22
                end
                gJ = (gJ + 87) % 112
            end
        elseif gT_1 <= 11 then
            if gT_1 <= 9 then
                if gT_1 <= 8 then
                    if (gJ * 2 + 8) * 10 % 3 == ((gJ * 2 + 8) * 10 + 2) % 3 then
                        gw.OnClientEvent:Connect(onOnClientEvent2)
                        ge.OnClientEvent:Connect(onOnClientEvent)
                        gH_1 = fn335
                        gr = fn397
                        f_ = fn355
                        gK_1 = fn461
                        f2 = fn11
                    else
                        gK_1.OnClientEvent:Connect(onOnClientEvent2)
                        gH_1.OnClientEvent:Connect(onOnClientEvent)
                        ge = fn335
                        f2 = fn397
                        gr = fn355
                        f_ = fn461
                        gw = fn11
                    end
                    gJ = (gJ + 3) % 112
                else
                    local gU_5 = (vector.create((gJ * 1 + 6) % 11 + 1, (gJ * 8 + 8) % 13 + 1, (gJ * 1 + 8) % 17 + 1))
                    local gV_4 = (vector.create((gJ * 1 + 3) % 11 + 1, (gJ * 2 + 3) % 13 + 1, (gJ * 12 + 17) % 17 + 1))
                    local gW_2 = (vector.create((gJ * 1 + 2) % 5 + 1, (gJ * 1 + 2) % 7 + 1, (gJ * 1 + 5) % 9 + 1))
                    if math.abs((vector.angle(gU_5, gV_4, gW_2))) - math.abs((vector.angle(gV_4, gU_5, gW_2))) == 1 then
                        f7 = fn202
                        gm = fn109
                        f9 = fn535
                    else
                        gm = fn202
                        f9 = fn109
                        f7 = fn535
                    end
                    gJ = (gJ + 31) % 112
                end
            elseif gT_1 <= 10 then
                if (gJ and not gJ and (not Players or Toggles) or (not Players or Toggles or gJ and Players)) and ((Toggles or not gJ) and (gJ or not Toggles) or not gJ and Toggles and (not gJ and gJ)) or (not Players and gJ or (gJ or not Players) or Toggles and gJ and (not Toggles and gJ) or ((gJ or not Toggles) and (not gJ or not Players) or (gJ or gJ or not Toggles and not gJ))) or not ((gJ and not gJ and (not Players or Toggles) or (not Players or Toggles or gJ and Players)) and ((Toggles or not gJ) and (gJ or not Toggles) or not gJ and Toggles and (not gJ and gJ)) or (not Players and gJ or (gJ or not Players) or Toggles and gJ and (not Toggles and gJ) or ((gJ or not Toggles) and (not gJ or not Players) or (gJ or gJ or not Toggles and not gJ)))) then
                    gI_1 = gf:CreateWindow({
                        Title = "Tempo Hub",
                        Footer = { { Text = fY, Copyable = true }, "|", gS },
                        Icon = 12645376577,
                        NotifySide = "Right",
                        ShowCustomCursor = false,
                        CornerRadius = 10
                    })
                else
                    gS = fY:CreateWindow({
                        NotifySide = "Right",
                        Footer = { "|", { Text = gf, Copyable = true }, gI_1 },
                        Icon = 12645376577,
                        ShowCustomCursor = false,
                        Title = "Tempo Hub",
                        CornerRadius = 10
                    })
                end
                gJ = (gJ + 59) % 112
            else
                if (gJ * 2 + 9) * 4 % 3 == ((gJ * 2 + 9) * 4 + 4) % 3 then
                    gI_1 = {
                        Settings = gQ:AddTab("Settings", "settings"),
                        Info = gQ:AddTab("Info", "info"),
                        Main = gQ:AddTab("Main", "swords")
                    }
                else
                    gQ = {
                        Info = gI_1:AddTab("Info", "info"),
                        Main = gI_1:AddTab("Main", "swords"),
                        Settings = gI_1:AddTab("Settings", "settings")
                    }
                end
                gJ = (gJ + 31) % 112
            end
        elseif gT_1 <= 13 then
            if gT_1 <= 12 then
                local gU_6 = (vector.create((gJ * 3 + 3) % 11 + 1, (gJ * 5 + 8) % 13 + 1, (gJ * 8 + 11) % 17 + 1))
                local gV_5 = (vector.create((gJ * 2 + 6) % 11 + 1, (gJ * 10 + 8) % 13 + 1, (gJ * 12 + 9) % 17 + 1))
                local j3 = vector.dot(gU_6, gV_5)
                if j3 * j3 <= vector.dot(gU_6, gU_6) * vector.dot(gV_5, gV_5) then
                    Players = game:GetService("Players")
                else
                    gS = game:GetService("Players")
                end
                gJ = (gJ + 59) % 112
            else
                local gU_7 = (vector.create((gJ * 7 + 6) % 11 + 1, (gJ * 11 + 9) % 13 + 1, (gJ * 15 + 5) % 17 + 1))
                local gV_6 = (vector.create((gJ * 7 + 5) % 11 + 1, (gJ * 8 + 5) % 13 + 1, (gJ * 13 + 4) % 17 + 1))
                local gW_3 = (vector.create((gJ * 2 + 8) % 11 + 1, (gJ * 3 + 11) % 13 + 1, (gJ * 10 + 11) % 17 + 1))
                if vector.dot(vector.cross(gU_7, gV_6), gW_3) == vector.dot(vector.cross(gV_6, gW_3), gU_7) then
                    gL_1 = game:GetService("ReplicatedStorage")
                else
                    ge = game:GetService("ReplicatedStorage")
                end
                gJ = (gJ + 87) % 112
            end
        else
            local gU_8 = (vector.create((gJ * 1 + 4) % 11 + 1, (gJ * 8 + 13) % 13 + 1, (gJ * 15 + 2) % 17 + 1))
            local gV_7 = (vector.create((gJ * 3 + 1) % 11 + 1, (gJ * 4 + 8) % 13 + 1, (gJ * 13 + 9) % 17 + 1))
            local gW_4 = (vector.create((gJ * 4 + 4) % 11 + 1, (gJ * 6 + 2) % 13 + 1, (gJ * 4 + 2) % 17 + 1))
            gX = (vector.create((gJ * 4 + 9) % 11 + 1, (gJ * 5 + 9) % 13 + 1, (gJ * 15 + 1) % 17 + 1))
            if vector.dot(vector.cross(gU_8, gV_7), (vector.cross(gW_4, gX))) == vector.dot(gU_8, gW_4) * vector.dot(gV_7, gX) - vector.dot(gU_8, gX) * vector.dot(gV_7, gW_4) then
                Workspace = game:GetService("Workspace")
            else
                gb = game:GetService("Workspace")
            end
            gJ = (gJ + 59) % 112
        end
    elseif gT_1 <= 21 then
        if gT_1 <= 18 then
            if gT_1 <= 16 then
                if gT_1 <= 15 then
                    if gJ * 23762109 + 12 + 1 <= gJ * 23762109 + 12 + 1 + 6 then
                        gR = game:GetService("UserInputService")
                        gn = game:GetService("VirtualUser")
                    else
                        gn = game:GetService("UserInputService")
                        gR = game:GetService("VirtualUser")
                    end
                    gJ = (gJ + 31) % 112
                else
                    gk = Players.LocalPlayer
                    gJ = (gJ + 59) % 112
                end
            elseif gT_1 <= 17 then
                local gU_9 = {
                    "vnlosniczsl",
                    "zwg",
                    "ufrlrazm",
                    "ajius",
                    "jxzytoevjd",
                    "ayb",
                    "anbjnysum",
                    "qwxnxknqf",
                    "tgfo",
                    "uhfc",
                    "wbvgyv",
                    "qbp"
                }
                local kk = gJ
                local gV_8 = gU_9[kk % 12 + 1]
                if gV_8:len() <= gV_8:reverse():rep(kk % 3 + 2):len() then
                    gG_1 = ""
                else
                    gy = ""
                end
                gJ = (gJ + 3) % 112
            else
                if (gJ * 2 + 3) * 13 % 3 == ((gJ * 2 + 3) * 13 + 8) % 3 then
                    gG_1 = getgenv().Library
                else
                    gf = getgenv().Library
                end
                gJ = (gJ + 87) % 112
            end
        elseif gT_1 <= 20 then
            if gT_1 <= 19 then
                local ko = bit32.rrotate(bit32.bxor(bit32.lrotate(gJ, 4), string.byte(tostring(fZ))), 9)
                if bit32.bxor(bit32.lrotate(bit32.bxor(ko, 3256288192), 10), 1544487688) ~= bit32.lrotate(ko, 10) then
                    gG_1 = getgenv().ThemeManager
                    gP = getgenv().SaveManager
                else
                    gP = getgenv().ThemeManager
                    gO = getgenv().SaveManager
                end
                gJ = (gJ + 59) % 112
            else
                local gU_10 = {
                    "wtq",
                    "vpzytdwwe",
                    "ivotnia",
                    "pqihffixsjp",
                    "moviw",
                    "kmsjzdihdbe",
                    "sqafywhkljw",
                    "xzkiz",
                    "khxj",
                    "hfk",
                    "mtprg"
                }
                local ka = gJ
                local gV_9 = gU_10[ka % 11 + 1]
                if gV_9:len() <= gV_9:reverse():rep(ka % 3 + 2):len() then
                    Toggles = gf.Toggles
                else
                    gf = Toggles.Toggles
                end
                gJ = (gJ + 59) % 112
            end
        else
            if (gM_1 or not gM_1 or (gK_1 or not f_) or not gy and not gS and (f_ and not gS)) and ((f_ and not gy or (gM_1 or gM_1)) and (not gK_1 and gS or (not f_ or not f_))) and not ((gM_1 or not gM_1 or (gK_1 or not f_) or not gy and not gS and (f_ and not gS)) and ((f_ and not gy or (gM_1 or gM_1)) and (not gK_1 and gS or (not f_ or not f_)))) then
                gf = Options.Options
            else
                Options = gf.Options
            end
            gJ = (gJ + 87) % 112
        end
    elseif gT_1 <= 25 then
        if gT_1 <= 23 then
            if gT_1 <= 22 then
                if gw and ge and (ge and gS) and (gS and gD_1 or (Drop or gu)) or not (gw and ge and (ge and gS) and (gS and gD_1 or (Drop or gu))) then
                    fY = "https://discord.gg/K7Qxnxkk46"
                else
                    gh = "https://discord.gg/K7Qxnxkk46"
                end
                gJ = (gJ + 3) % 112
            else
                local kr = bit32.rrotate(bit32.bxor(bit32.lrotate(gJ, 11), string.byte(tostring(gQ))), 6)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(kr, 2094295005), 2411794519), (bit32.bxor(bit32.band(kr, 2200672290), 3500465261))), 2411794519), 3500465261) == kr then
                    gA = "https://discord.gg/K7Qxnxkk46"
                else
                    gS = "https://discord.gg/K7Qxnxkk46"
                end
                gJ = (gJ + 31) % 112
            end
        elseif gT_1 <= 24 then
            if gJ * 124732039 + 4 + 7 <= gJ * 124732039 + 4 + 7 + 1 then
                gS = "Merge a Mob!"
            else
                gR = "Merge a Mob!"
            end
            gJ = (gJ + 59) % 112
        else
            if (gJ * 2 + 2) * 4 % 3 == ((gJ * 2 + 2) * 4 + 0) % 3 then
                gt = fn383
                gM_1 = fn534
            else
                gM_1 = fn383
                gt = fn534
            end
            gJ = (gJ + 87) % 112
        end
    elseif gT_1 <= 27 then
        if gT_1 <= 26 then
            local gT_2 = (vector.create((gJ * 1 + 7) % 11 + 1, (gJ * 3 + 5) % 13 + 1, (gJ * 12 + 9) % 17 + 1))
            local kq = vector.floor(gT_2) + vector.ceil(gT_2 * -1)
            if vector.dot(kq, kq) == 0 then
                gF_1 = gL_1:WaitForChild("NukeRemotes")
            else
                gL_1 = gF_1:WaitForChild("NukeRemotes")
            end
            gJ = (gJ + 3) % 112
        else
            local gT_3 = (vector.create((gJ * 7 + 8) % 11 + 1, (gJ * 5 + 13) % 13 + 1, (gJ * 10 + 16) % 17 + 1))
            local gU_11 = (vector.create((gJ * 1 + 7) % 11 + 1, (gJ * 1 + 5) % 13 + 1, (gJ * 2 + 3) % 17 + 1))
            local gV_10 = (vector.create((gJ * 2 + 2) % 11 + 1, (gJ * 1 + 9) % 13 + 1, (gJ * 15 + 16) % 17 + 1))
            local gW_5 = (vector.create((gJ * 6 + 4) % 11 + 1, (gJ * 1 + 1) % 13 + 1, (gJ * 2 + 10) % 17 + 1))
            if vector.dot(vector.cross(gT_3, gU_11), (vector.cross(gV_10, gW_5))) == vector.dot(gT_3, gV_10) * vector.dot(gU_11, gW_5) - vector.dot(gT_3, gW_5) * vector.dot(gU_11, gV_10) + 2 then
                gL_1 = gD_1:WaitForChild("NukeShared")
            else
                gD_1 = gL_1:WaitForChild("NukeShared")
            end
            gJ = (gJ + 59) % 112
        end
    else
        local gT_4 = (vector.create((gJ * 7 + 5) % 11 + 1, (gJ * 9 + 8) % 13 + 1, (gJ * 5 + 16) % 17 + 1))
        local gU_12 = (vector.create((gJ * 5 + 6) % 11 + 1, (gJ * 9 + 3) % 13 + 1, (gJ * 11 + 1) % 17 + 1))
        local gV_11 = (vector.create((gJ * 1 + 7) % 11 + 1, (gJ * 10 + 3) % 13 + 1, (gJ * 10 + 17) % 17 + 1))
        local gW_6 = (vector.create((gJ * 3 + 3) % 5 + 1, (gJ * 2 + 6) % 7 + 1, (gJ * 2 + 4) % 9 + 1))
        if vector.dot(vector.cross(gT_4, (vector.cross(gU_12, gV_11))), gW_6) == vector.dot(gU_12 * vector.dot(gT_4, gV_11) - gV_11 * vector.dot(gT_4, gU_12), gW_6) then
            Drop = gF_1:WaitForChild("Drop")
        else
            gF_1 = Drop:WaitForChild("Drop")
        end
        gJ = (gJ + 31) % 112
    end
until (gJ * 71 + 2) % 112 == 84
for i, v in ipairs({ gQ.Main, gQ.Settings }) do
    gM_1(v)
end
gH_2, gG_2, gi, gF_2, gc, gD_2, gI_2, Label, gp, gE_2, ga, f1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local gC_2 = 2
repeat
    local gJ_1 = (gC_2 * 5 + 6) % 8 + 1
    if gJ_1 <= 4 then
        if gJ_1 <= 2 then
            if gJ_1 <= 1 then
                local kv = bit32.rrotate(bit32.bxor(bit32.lrotate(gC_2, 5), string.byte(tostring(Label))), 11)
                if bit32.bxor(bit32.lrotate(bit32.bxor(kv, 414733820), 4), 2340773825) == bit32.lrotate(kv, 4) then
                    ga = fn365
                else
                    gG_2 = fn365
                end
                gC_2 = (gC_2 + 5) % 32
            else
                local gK_2 = {
                    "jcblsm",
                    "iidjds",
                    "hhakbqivswir",
                    "selgwopwmxtj",
                    "slquzhflnxfk",
                    "ngym",
                    "ydwupibow",
                    "ofeh",
                    "mrsiqlof",
                    "uqgsnykqmxwb",
                    "efhplvgnwz",
                    "aydlfalwsh",
                    "ifdjjctge",
                    "peclwle"
                }
                if gK_2[(gC_2 * 87 + 4) % 14 + 1] < gK_2[(gC_2 * 87 + 4) % 14 + 1] then
                    gH_2 = fn454
                else
                    f1 = fn454
                end
                gC_2 = (gC_2 + 21) % 32
            end
        elseif gJ_1 <= 3 then
            local gK_3 = (vector.create((gC_2 * 5 + 8) % 11 + 1, (gC_2 * 10 + 13) % 13 + 1, (gC_2 * 1 + 2) % 17 + 1))
            local gL_2 = (vector.create((gC_2 * 6 + 5) % 11 + 1, (gC_2 * 9 + 6) % 13 + 1, (gC_2 * 2 + 2) % 17 + 1))
            local gM_2 = (vector.create((gC_2 * 4 + 4) % 5 + 1, (gC_2 * 3 + 4) % 7 + 1, (gC_2 * 5 + 3) % 9 + 1))
            if math.abs((vector.angle(gK_3, gL_2, gM_2))) - math.abs((vector.angle(gL_2, gK_3, gM_2))) == 1 then
                gi = "#7fd47f"
            else
                gH_2 = "#7fd47f"
            end
            gC_2 = (gC_2 + 29) % 32
        else
            local kc = bit32.rrotate(bit32.bxor(bit32.lrotate(gC_2, 11), string.byte(tostring(gF_2))), 5)
            if bit32.bxor(bit32.lrotate(bit32.bxor(kc, 678840426), 14), 2451212829) ~= bit32.lrotate(kc, 14) then
                gp = "#6ec1ff"
            else
                gG_2 = "#6ec1ff"
            end
            gC_2 = (gC_2 + 13) % 32
        end
    elseif gJ_1 <= 6 then
        if gJ_1 <= 5 then
            local gK_4 = {
                "nhccedr",
                "oxajg",
                "ije",
                "qukrjdayjc",
                "lre",
                "lxp",
                "ghrz",
                "zzlljcy",
                "mwet",
                "ifghghdiiim",
                "kqnwd",
                "sdidhaynoc",
                "qte",
                "wjv",
                "rxpqadfyd"
            }
            if gK_4[(gC_2 * 10 + 84) % 15 + 1] < gK_4[(gC_2 * 10 + 84) % 15 + 1] then
                gD_2 = "#e8a34d"
            else
                gi = "#e8a34d"
            end
            gC_2 = (gC_2 + 29) % 32
        else
            local gK_5 = {
                "pfexfytrhiv",
                "dcjioxgfclt",
                "grweqpchcz",
                "cujydrfsna",
                "pzpjd",
                "zestlbcubz",
                "pddmggz",
                "zbhtdsksrkk"
            }
            local j1 = gC_2
            local gL_3 = gK_5[j1 % 8 + 1]
            if gL_3:len() <= gL_3:gsub("(.)", "%1%1", j1 % 3 % 2 + 1):len() then
                gF_2 = "#8b93a3"
                gc = "Unknown"
                pcall(fn91)
                gD_2 = gQ.Info:AddLeftGroupbox("Account", "circle-user")
                gD_2:AddLabel(f1("User", gk.Name, gH_2), true)
                gD_2:AddLabel(f1("Status", "Keyless", gH_2), true)
                gD_2:AddLabel(f1("Executor", gc, gH_2), true)
                gI_2 = gQ.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                gI_2:AddLabel(ga(gS .. " [" .. tostring(game.PlaceId) .. "]", gG_2), true)
                gI_2:AddLabel(f1("Place ID", tostring(game.PlaceId), gG_2), true)
                Label = gI_2:AddLabel(f1("Session time", "0s", gi), true)
            else
                gI_2 = "#8b93a3"
                gQ = "Unknown"
                pcall(fn91)
                ga = gc.Info:AddLeftGroupbox("Account", "circle-user")
                ga:AddLabel(gS("User", f1.Name, gF_2), true)
                ga:AddLabel(gS("Status", "Keyless", gF_2), true)
                ga:AddLabel(gS("Executor", "Unknown", gF_2), true)
                gi = gc.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                gi:AddLabel(gD_2(gH_2 .. " [" .. tostring(game.PlaceId) .. "]", Label), true)
                gi:AddLabel(gS("Place ID", tostring(game.PlaceId), Label), true)
                gk = gi:AddLabel(gS("Session time", "0s", gG_2), true)
            end
            gC_2 = (gC_2 + 21) % 32
        end
    elseif gJ_1 <= 7 then
        local gJ_2 = {
            "eofgyuhfkzz",
            "wkv",
            "myvcdwh",
            "deor",
            "zkr",
            "wfmmcsdgjc",
            "uti",
            "wovnvtmt",
            "dlmtzerobx",
            "evnzdekrgu",
            "wfnyrproii",
            "rebzfecus",
            "jiek",
            "awi"
        }
        if gJ_2[(gC_2 * 52 + 18) % 14 + 1] < gJ_2[(gC_2 * 52 + 18) % 14 + 1] then
            gc = tostring(game.JobId)
        else
            gp = tostring(game.JobId)
        end
        gC_2 = (gC_2 + 21) % 32
    else
        local gJ_3 = {
            "apwteqdm",
            "rxpwf",
            "icmmuj",
            "lvk",
            "neuxanh",
            "tqo",
            "numqs",
            "aopmygkdzd",
            "mcdowkej",
            "mujaoxxp"
        }
        local j2 = gC_2
        local gK_6 = gJ_3[j2 % 10 + 1]
        if gK_6:len() <= gK_6:gsub("(.)", "%1%1", j2 % 3 % 2 + 1):len() then
            gE_2 = #gp > 18
        else
            gp = #gE_2 > 18
        end
        gC_2 = (gC_2 + 21) % 32
    end
until (gC_2 * 9 + 13) % 32 == 31
if gE_2 then
    local gC_3 = 0
    repeat
        if (gC_3 * 3 + 8) * 5 % 4 == ((gC_3 * 3 + 8) * 5 + 9) % 4 then
            gp = string.sub(gE_2, 1, 18) .. "..."
        else
            gE_2 = string.sub(gp, 1, 18) .. "..."
        end
        gC_3 = (gC_3 + 2) % 4
    until (gC_3 * 3 + 1) % 4 == 3
end
local gC_4 = gE_2 or gp
f6, gl, gj, connection, connection2, f4 = nil, nil, nil, nil, nil, nil
gI_2:AddLabel(f1("Server", gC_4, gF_2), true)
gI_2:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
f6 = os.clock()
task.spawn(worker)
local ScriptsGroup = gQ.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(ga("Included in this hub", gF_2), true)
ScriptsGroup:AddLabel(ga(gS, gG_2), true)
local FeaturesGroup = gQ.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(ga("Auto Merge", gG_2), true)
FeaturesGroup:AddLabel(ga("Auto Buy Upgrades", gi), true)
FeaturesGroup:AddLabel(ga("Auto Rebirth", gH_2), true)
FeaturesGroup:AddLabel(ga("Auto Buy Swords", gG_2), true)
FeaturesGroup:AddLabel(ga("Auto Enchant", gi), true)
FeaturesGroup:AddLabel(ga("Misc Utilities", gF_2), true)
local SocialsGroup = gQ.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = gt })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = gQ.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = gt })
local FaqGroup = gQ.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutoMergeGroup = gQ.Main:AddLeftGroupbox("Auto Merge", "combine")
AutoMergeGroup:AddToggle("AutoMerge", { Text = "Auto Merge", Default = false })
AutoMergeGroup:AddSlider("MergeWalkSpeed", {
    Text = "Walk Speed",
    Default = 22,
    Min = 16,
    Max = 32,
    Rounding = 0,
    Suffix = " sps",
    Callback = onMergeWalkSpeed
})
local AutoBuyUpgradesGroup = gQ.Main:AddRightGroupbox("Auto Buy Upgrades", "trending-up")
AutoBuyUpgradesGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
AutoBuyUpgradesGroup:AddDropdown("UpgradeSelection", {
    Text = "Upgrades",
    Values = { "Tier", "Lock Base", "Max" },
    Default = {},
    Multi = true,
    Callback = onUpgradeSelection
})
local AutoRebirthGroup = gQ.Main:AddLeftGroupbox("Auto Rebirth", "refresh-cw")
AutoRebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
local AutoBuySwordsGroup = gQ.Main:AddRightGroupbox("Auto Buy Swords", "sword")
AutoBuySwordsGroup:AddToggle("AutoBuySwords", { Text = "Auto Buy Swords", Default = false })
local AutoEnchantGroup = gQ.Main:AddLeftGroupbox("Auto Enchant", "sparkles")
AutoEnchantGroup:AddToggle("AutoEnchant", { Text = "Auto Enchant", Default = false })
local MenuGroup = gQ.Settings:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
gf.ToggleKeybind = Options.MenuKeybind
gl = tick()
gj = tick()
pcall(function()
    for i, v in ipairs(getconnections(gk.Idled)) do
        local iT = v
        pcall(function()
            iT:Disable()
        end)
    end
end)
f4 = fn430
connection = gR.InputBegan:Connect(onInputBegan)
connection2 = gR.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(antiAfkLoop)
MenuGroup:AddButton("Unload", onUnload)
gf:OnUnload(fn470)
gP:SetLibrary(gf)
gP:SetFolder("TempoHub")
gP:SaveDefault("Monochrome")
gO:SetLibrary(gf)
gO:IgnoreThemeSettings()
gO:SetIgnoreIndexes({ "MenuKeybind" })
gO:SetFolder("TempoHub/MergeAMob")
gO:BuildConfigSection(gQ.Settings)
gP:ApplyToTab(gQ.Settings)
gP:LoadDefault()
gO:LoadAutoloadConfig()
task.spawn(function()
    local jd = false
    repeat
        if not gf.Unloaded then
            task.wait(0.2)
            if Toggles.AutoMerge.Value then
                local i5 = ge()
                local i6 = f2()
                local i7 = gr()
                if i5 and i6 and i7 then
                    if i6.WalkSpeed ~= gu then
                        i6.WalkSpeed = gu
                    end
                    local i8_1 = HeldNuke.GetTier()
                    if i8_1 then
                        local i9_1 = HeldNuke.GetPart()
                        local ja = gm(i7, i8_1, i5.Position, i9_1)
                        if ja then
                            i6:MoveTo(ja.Position)
                        else
                            pcall(function()
                                Drop:FireServer(i5.CFrame)
                            end)
                        end
                    else
                        local i8_2 = f9(i7)
                        if i8_2 then
                            local i9_2 = gm(i7, i8_2, i5.Position)
                            if i9_2 then
                                i6:MoveTo(i9_2.Position)
                            end
                        end
                    end
                end
            end
        else
            jd = true
        end
    until jd
end)
task.spawn(function()
    while not gf.Unloaded do
        task.wait(1)
        if Toggles.AutoBuyUpgrades.Value and fZ and fZ.cash and fZ.upgrades then
            local je_1 = gg.deserialize(fZ.cash)
            for i, v in ipairs(gy) do
                local jn = v
                local jf = fZ.upgrades[jn]
                if jf and not jf.maxed then
                    local jg_1 = gg.deserialize(jf.cost)
                    if gg.gte(je_1, jg_1) then
                        pcall(function()
                            fX:FireServer(jn)
                        end)
                    end
                end
            end
        end
    end
end)
task.spawn(autoRebirthLoop)
task.spawn(function()
    while not gf.Unloaded do
        task.wait(2)
        if Toggles.AutoBuySwords.Value then
            pcall(function()
                SwordShopRequest:FireServer()
            end)
            task.wait(0.3)
            if gB and gB.cash then
                local jr_1 = gg.deserialize(gB.cash)
                for i, v in ipairs(gb.GetOrdered()) do
                    local jA = v
                    if not (gB.owned and gB.owned[jA.id]) then
                        local js_1 = gg.new(jA.price)
                        if gg.gte(jr_1, js_1) then
                            pcall(function()
                                gq:FireServer(jA.id)
                            end)
                        end
                    end
                end
            end
        end
    end
end)
task.spawn(autoEnchantLoop)
end)(...)

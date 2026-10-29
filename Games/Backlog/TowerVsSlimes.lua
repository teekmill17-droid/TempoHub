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
	local keyless = false
	pcall(function()
		local c = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/control.json?t=" .. tostring(os.time())))
		keyless = c.keyRequired == false
	end)
	if not keyless then
		local key = g.__TempoKey or g.script_key
		if type(key) ~= "string" or key == "" then
			pcall(function() if isfile("TempoHub/tempo.key") then key = readfile("TempoHub/tempo.key") end end)
		end
		key = type(key) == "string" and key:gsub("%s+", "") or ""
		local ok, why = false, "no key"
		for try = 1, (key ~= "" and 2 or 0) do
			local src
			pcall(function() src = game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/Key.lua?t=" .. tostring(os.time())) end)
			local fn = src and loadstring(src)
			if not fn then
				why = "couldn't check your key, try again in a minute"
			else
				local ran, a, b = pcall(fn, { verify = key })
				if not ran then why = "key check failed, try again in a minute" beacon("check crashed: " .. tostring(a))
				else ok, why = a == true, b end
			end
			if ok or not (type(why) == "string" and (why:find("reach") or why:find("try again"))) then break end
			task.wait(3)
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
getgenv().TempoHoodSubtitle = "TOWER VS SLIMES"
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
local Options
local LocalPlayer
local VirtualUser
local gl
local Toggles
local f2
local fV
local WaveController
local gd
local f8
local gm
local fT
local ge
local gh
local f9
local fR
local Plot
local f4
local fU
local function fn13()
    if not Toggles.AutoPlace.Value then
        return false
    end
    local hI = f4(Options.PlaceBuildingList.Value)
    for k, v in fR.Data.Inventory do
        local hJ = not v.IsPlaced
        if hJ ~= false then
            local hK = fV(hI) or hI[v.Name]
            hJ = hK
        end
        if hJ then
            return true
        end
    end
    return false
end
local function fn107()
    select("#", "Build a Slime Defense unloaded")
end
local function fn126(aG)
    aG:AddLeftGroupbox("Discord"):AddButton({
        Text = "Join Discord For Dupe",
        Func = function()
            setclipboard(gm)
            f2:Notify("Copied Discord invite to clipboard")
        end
    })
end
local function fn203(aq)
    return next(aq) == nil
end
local function autoUpgradeTownHallLoop()
    while true do
        local j6 = Options.TownHallDelay and Options.TownHallDelay.Value or 0.5
        if task.wait(j6) then
            if f2.Unloaded then
                break
            end
            if Toggles.AutoUpgradeTownHall.Value then
                if fR.Data.KingLevel < ge then
                    pcall(function()
                        f9:InvokeServer()
                    end)
                end
            end
            continue
        end
        break
    end
end
local function fn341()
    if gh and gh.Parent then
        return gh
    end
    local result = Plot.GetPlot:InvokeServer()
    if typeof(result) == "Instance" then
        gh = result
        return result
    end
    return nil
end
local function fn361(ai)
    return math.floor(ai.Size.X / gl), math.floor(ai.Size.Z / gl)
end
local function fn373()
    local he = gd()
    if not he then
        return nil
    end
    local Main = he:FindFirstChild("Main")
    local he_1 = Main and Main:FindFirstChild("Plot")
    local hf_1 = he_1
    if he_1 then
        he_1 = hf_1:FindFirstChild("BuildPlate")
    end
    return he_1
end
local function fn416()
    if not Toggles.AutoStopWave.Value then
        return false
    end
    local hF = tonumber(Options.StopAtWave.Value)
    return hF ~= nil and fU.Current >= hF
end
local function fn461(as, at)
    if typeof(as) == "table" then
        for k, v in as do
            if v then
                return k
            end
        end
    end
    return at
end
local function onOnClientEvent(R, S)
    if R == "NEW_WAVE" then
        fU.Current = S
    elseif R == "ACTIVE" then
        fU.Active = true
    elseif R == "INACTIVE" then
        fU.Active = false
        fU.Current = 0
    end
end
local function onUnload()
    f2:Unload()
end
local function onIdled()
    if f2.Unloaded then
        return
    end
    if not Toggles.AntiAFK.Value then
        return
    end
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end
local function fn530(al)
    local hh = {}
    if typeof(al) == "table" then
        for k, v in al do
            if v then
                hh[k] = true
            end
        end
    end
    return hh
end
local function fn571()
    local Character = LocalPlayer.Character
    if Character then
        local Tool = Character:FindFirstChildOfClass("Tool")
        if Tool then
            local attr = Tool:GetAttribute("WeaponName")
            if attr then
                return attr
            end
            return fR.Data.EquippedWeapon
        end
        return fR.Data.EquippedWeapon
    end
    return fR.Data.EquippedWeapon
end
local function autoStartLoop()
    while task.wait(0.25) do
        if f2.Unloaded then
            break
        end
        if f8() then
            if fU.Active then
                pcall(function()
                    WaveController:InvokeServer("Stop")
                end)
            end
        else
            local hS = Toggles.AutoStart.Value and not fU.Active and not fT()
            if hS then
                pcall(function()
                    WaveController:InvokeServer("Start")
                end)
            end
        end
    end
end
fR = nil
Toggles = nil
fT = nil
fU = nil
fV = nil
Options = nil
f2 = nil
f4 = nil
WaveController = nil
LocalPlayer = nil
f8 = nil
f9 = nil
VirtualUser = nil
gd = nil
ge = nil
gh = nil
gl = nil
gm = nil
Plot = nil
local Crates, BuildingShop2, Gold, f_, result, Weapons, f3, f6, gb, Building, gf, CrateShop, CollectionService, gj, BuildingShop, go
local gw_1
local gt_1
CollectionService, VirtualUser, LocalPlayer, gt_1, f2, gw_1, Options, Toggles, Plot, BuildingShop, CrateShop, Building, f9, WaveController, Weapons, Gold, BuildingShop2, Crates, fR, gl, gj, ge, gb = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
local gu = game:GetService("ReplicatedStorage")
CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
VirtualUser = game:GetService("VirtualUser")
LocalPlayer = Players.LocalPlayer
if ((gl or not f9) and (gw_1 and false) or LocalPlayer and not CrateShop and (CrateShop and not LocalPlayer) or (not f9 or not LocalPlayer or (not f9 or LocalPlayer) or (not gw_1 and not gw_1 or gw_1 and LocalPlayer))) and ((LocalPlayer and gw_1 and (false or not gw_1) or (f9 or f9 or (not gw_1 or not CrateShop))) and ((LocalPlayer or gl) and (not gw_1 or gw_1) and (LocalPlayer or gl or (not f9 or not f9)))) and not (((gl or not f9) and (gw_1 and false) or LocalPlayer and not CrateShop and (CrateShop and not LocalPlayer) or (not f9 or not LocalPlayer or (not f9 or LocalPlayer) or (not gw_1 and not gw_1 or gw_1 and LocalPlayer))) and ((LocalPlayer and gw_1 and (false or not gw_1) or (f9 or f9 or (not gw_1 or not CrateShop))) and ((LocalPlayer or gl) and (not gw_1 or gw_1) and (LocalPlayer or gl or (not f9 or not f9))))) then
    f9 = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
else
    gt_1 = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
end
f2 = getgenv().Library
local gx = getgenv().ThemeManager
local gw_2 = getgenv().SaveManager
Options = f2.Options
Toggles = f2.Toggles
local Remotes = gu.Remotes
Plot = Remotes.Plot
BuildingShop = Remotes.BuildingShop
CrateShop = Remotes.CrateShop
Building = Plot.Building
f9 = Plot.UpgradeKing
WaveController = Plot.WaveController
local GameState = Plot.GameState
Weapons = Remotes.Weapons
Gold = Remotes.Gold
if (not gw_2 and not BuildingShop or not Options and gw_2 or Remotes and BuildingShop and (not BuildingShop and Remotes) or (Remotes or not gw_2) and (not gw_2 or Crates) and ((not Options or not BuildingShop) and (not Options or Remotes))) and not (not gw_2 and not BuildingShop or not Options and gw_2 or Remotes and BuildingShop and (not BuildingShop and Remotes) or (Remotes or not gw_2) and (not gw_2 or Crates) and ((not Options or not BuildingShop) and (not Options or Remotes))) then
    gu = require(BuildingShop2.Shared.Registry.BuildingShop)
else
    BuildingShop2 = require(gu.Shared.Registry.BuildingShop)
end
Crates = require(gu.Shared.Registry.Crates)
local DataAggregation = require(LocalPlayer.PlayerScripts.Client.Modules.DataAggregation)
fR = DataAggregation.WaitForReplica()
gl = 4
gj = 11
ge = 12
gb = { ["7,17"] = true, ["7,18"] = true, ["8,17"] = true, ["8,18"] = true }
local gy = {}
for k, v in BuildingShop2.ItemList do
    table.insert(gy, v.Name)
end
local gp_1 = {}
for k, v in Crates.CrateList do
    table.insert(gp_1, v.Name)
end
fU, gh, gm, gd, f_, gf, f4, fV, go, f6 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
fU = { Current = 0, Active = false }
GameState.OnClientEvent:Connect(onOnClientEvent)
gh = nil
gd = fn341
f_ = fn373
gf = fn361
f4 = fn530
fV = fn203
go = fn461
f6 = fn571
local Window = f2:CreateWindow({
    Title = "Tempo",
    Footer = "Build a Slime Defense",
    Icon = 18657887261,
    ShowCustomCursor = false,
    NotifySide = "Right",
    Size = UDim2.fromOffset(690, 640)
})
local gt_2 = { Main = Window:AddTab("Main", "gamepad-2"), Settings = Window:AddTab("Settings", "settings") }
gm = "https://discord.gg/K7Qxnxkk46"
for k, v in gt_2 do
    fn126(v)
end
f3, result, f8, fT = nil, nil, nil, nil
local WavesGroup = gt_2.Main:AddLeftGroupbox("Waves")
WavesGroup:AddToggle("AutoStart", { Text = "Auto Start Waves", Default = false })
WavesGroup:AddToggle("AutoStopWave", { Text = "Auto Stop At Wave", Default = false })
WavesGroup:AddInput("StopAtWave", { Text = "Stop at wave", Default = "10", Numeric = true, Finished = true })
local AutoBuyBuildingsGroup = gt_2.Main:AddLeftGroupbox("Auto Buy Buildings")
AutoBuyBuildingsGroup:AddToggle("AutoBuyBuildings", { Text = "Auto Buy Buildings", Default = false })
AutoBuyBuildingsGroup:AddDropdown("BuyBuildingList", { Text = "Buildings", Values = gy, Default = {}, Multi = true, AllowNull = true, Searchable = true })
AutoBuyBuildingsGroup:AddToggle("BuyBuildingsRespectTH", { Text = "Only if Town Hall unlocks it", Default = true })
AutoBuyBuildingsGroup:AddSlider("BuyBuildingsDelay", { Text = "Delay", Default = 0.3, Min = 0.05, Max = 2, Rounding = 2 })
local AutoBuyWeaponCratesGroup = gt_2.Main:AddLeftGroupbox("Auto Buy Weapon Crates")
AutoBuyWeaponCratesGroup:AddToggle("AutoBuyCrates", { Text = "Auto Buy Crates", Default = false })
AutoBuyWeaponCratesGroup:AddDropdown("BuyCrateList", { Text = "Crates", Values = gp_1, Default = {}, Multi = true, AllowNull = true, Searchable = true })
AutoBuyWeaponCratesGroup:AddSlider("BuyCratesDelay", { Text = "Delay", Default = 0.4, Min = 0.05, Max = 5, Rounding = 2 })
AutoBuyWeaponCratesGroup:AddToggle("AutoOpenCrates", { Text = "Auto Open Ready Crates", Default = false })
AutoBuyWeaponCratesGroup:AddSlider("OpenCratesDelay", { Text = "Open delay", Default = 0.5, Min = 0.1, Max = 3, Rounding = 2 })
local AutoPlaceBuildingsGroup = gt_2.Main:AddLeftGroupbox("Auto Place Buildings")
AutoPlaceBuildingsGroup:AddToggle("AutoPlace", { Text = "Auto Place Buildings", Default = false })
AutoPlaceBuildingsGroup:AddDropdown("PlaceBuildingList", { Text = "Buildings", Values = gy, Default = {}, Multi = true, AllowNull = true, Searchable = true })
AutoPlaceBuildingsGroup:AddDropdown("PlacePattern", {
    Text = "Fill pattern",
    Values = { "Front to Back", "Back to Front", "Edges First", "Around Town Hall", "Random" },
    Default = { "Front to Back" },
    Multi = true,
    AllowNull = true,
    Searchable = true
})
AutoPlaceBuildingsGroup:AddSlider("PlaceDelay", { Text = "Delay", Default = 0.15, Min = 0.05, Max = 2, Rounding = 2 })
local AutoFarmGroup = gt_2.Main:AddRightGroupbox("Auto Farm")
AutoFarmGroup:AddToggle("AutoFarm", { Text = "Auto Farm", Default = false })
AutoFarmGroup:AddSlider("AutoFarmDelay", { Text = "Attack interval", Default = 0.1, Min = 0, Max = 1, Rounding = 2 })
local AutoCollectPickupsGroup = gt_2.Main:AddRightGroupbox("Auto Collect Pickups")
AutoCollectPickupsGroup:AddToggle("AutoCollect", { Text = "Auto Collect Coins", Default = false })
AutoCollectPickupsGroup:AddSlider("CollectDelay", { Text = "Delay", Default = 0.1, Min = 0.05, Max = 1, Rounding = 2 })
local AutoUpgradeBuildingsGroup = gt_2.Main:AddRightGroupbox("Auto Upgrade Buildings")
AutoUpgradeBuildingsGroup:AddToggle("AutoUpgrade", { Text = "Auto Upgrade Buildings", Default = false })
AutoUpgradeBuildingsGroup:AddDropdown("UpgradeBuildingList", { Text = "Buildings", Values = gy, Default = {}, Multi = true, AllowNull = true, Searchable = true })
AutoUpgradeBuildingsGroup:AddSlider("UpgradeMaxLevel", { Text = "Max level", Default = gj, Min = 2, Max = gj, Rounding = 0 })
AutoUpgradeBuildingsGroup:AddSlider("UpgradeDelay", { Text = "Delay", Default = 0.2, Min = 0.05, Max = 2, Rounding = 2 })
local AutoUpgradeTownHallGroup = gt_2.Main:AddRightGroupbox("Auto Upgrade Town Hall")
AutoUpgradeTownHallGroup:AddToggle("AutoUpgradeTownHall", { Text = "Auto Upgrade Town Hall", Default = false })
AutoUpgradeTownHallGroup:AddSlider("TownHallDelay", { Text = "Delay", Default = 0.5, Min = 0.1, Max = 3, Rounding = 2 })
f8 = fn416
fT = fn13
task.spawn(autoStartLoop)
f3 = 0
result = nil
RunService.Heartbeat:Connect(function(bn)
    if f2.Unloaded then
        return
    end
    if not Toggles.AutoFarm.Value then
        return
    end
    f3 += bn
    if f3 < Options.AutoFarmDelay.Value then
        return
    end
    f3 = 0
    local hU = f6()
    if not hU then
        return
    end
    if not result then
        pcall(function()
            result = Plot.GetPlot:InvokeServer()
        end)
    end
    if not Toggles.AutoFarm.Value then
        return
    end
    if not result then
        return
    end
    local Character = LocalPlayer.Character
    if not Character or not Character.PrimaryPart then
        return
    end
    local CFrame = Character.PrimaryPart.CFrame
    local hY = false
    for k, v in CollectionService:GetTagged("WaveNpc") do
        local hV
        if not Toggles.AutoFarm.Value then
            break
        end
        local hZ_1 = v:IsA("Model") and v.Parent and v.PrimaryPart and v:IsDescendantOf(result)
        if hZ_1 then
            local attr = v:GetAttribute("Health")
            if attr == nil or attr > 0 then
                hV = {}
                local ic = 1
                while ic <= 100 do
                    table.insert(hV, v)
                    ic += 1
                end
                Character:PivotTo(v.PrimaryPart.CFrame)
                hY = true
                pcall(function()
                    Weapons:InvokeServer("Attack", hU, hV)
                end)
            end
        end
    end
    if hY and Character and Character.PrimaryPart then
        Character:PivotTo(CFrame)
    end
end)
task.spawn(function()
    while true do
        local wait = task.wait
        local il = Options.BuyBuildingsDelay and Options.BuyBuildingsDelay.Value or 0.3
        if wait(il) then
            if f2.Unloaded then
                break
            end
            if Toggles.AutoBuyBuildings.Value then
                local ij_1 = f4(Options.BuyBuildingList.Value)
                local KingLevel = fR.Data.KingLevel
                for k, v in BuildingShop2.ItemList do
                    local iy = v
                    if f2.Unloaded then
                        break
                    end
                    local il_1 = fV(ij_1) or ij_1[iy.Name]
                    if il_1 then
                        local il_2 = true
                        if Toggles.BuyBuildingsRespectTH.Value then
                            local im = iy.Stock[KingLevel]
                            il_2 = im ~= nil and im > 0
                        end
                        if il_2 then
                            pcall(function()
                                BuildingShop:InvokeServer("Buy", iy.Name)
                            end)
                            task.wait(Options.BuyBuildingsDelay.Value)
                        end
                    end
                end
            end
            continue
        end
        break
    end
end)
task.spawn(function()
    while true do
        local wait = task.wait
        local iB = Options.BuyCratesDelay and Options.BuyCratesDelay.Value or 0.4
        if wait(iB) then
            if f2.Unloaded then
                break
            end
            if Toggles.AutoBuyCrates.Value then
                local iz_1 = f4(Options.BuyCrateList.Value)
                for k, v in Crates.CrateList do
                    local iI = v
                    if f2.Unloaded then
                        break
                    end
                    local iA_1 = fV(iz_1) or iz_1[iI.Name]
                    if iA_1 then
                        pcall(function()
                            CrateShop:InvokeServer("Buy", iI.Name)
                        end)
                        task.wait(Options.BuyCratesDelay.Value)
                    end
                end
            end
            continue
        end
        break
    end
end)
task.spawn(function()
    while true do
        local wait = task.wait
        local iP = Options.OpenCratesDelay and Options.OpenCratesDelay.Value or 0.5
        if wait(iP) then
            if f2.Unloaded then
                break
            end
            if Toggles.AutoOpenCrates.Value then
                local iN_1 = gd()
                local iO_1 = iN_1 and iN_1:FindFirstChild("Crates")
                if iO_1 then
                    for i, child in iO_1:GetChildren() do
                        if f2.Unloaded then
                            break
                        else
                            local attr2 = child:GetAttribute("Index")
                            local attr = child:GetAttribute("UnlockedAt")
                            local iO_2 = attr2 ~= nil and attr ~= nil and attr - os.time() <= 0
                            if iO_2 then
                                pcall(function()
                                    CrateShop:InvokeServer("Open", attr2)
                                end)
                                task.wait(Options.OpenCratesDelay.Value)
                            end
                        end
                    end
                end
            end
            continue
        end
        break
    end
end)
task.spawn(function()
    local jc = false
    repeat
        local i3, i4
        local wait = task.wait
        local i7 = Options.PlaceDelay and Options.PlaceDelay.Value
        local jf = if i7 then 1 else 0
        local jd = 3220 * jf + 2492 * (1 - jf)
        local je = 2665 * jf + 2962 * (1 - jf)
        if not ((jd * 1850 + je * 3368 + jd * je) % 16777213 == 6736807) then
            i7 = 0.15
        end
        if wait(i7) then
            if f2.Unloaded then
                jc = true
            elseif Toggles.AutoPlace.Value then
                local i5_1 = f_()
                if i5_1 then
                    i3, i4 = gf(i5_1)
                    local i5_2 = {}
                    for k, v in fR.Data.Inventory do
                        if v.IsPlaced and v.Cell then
                            i5_2[v.Cell[1] .. "," .. v.Cell[2]] = true
                        end
                    end
                    local i6_2 = {}
                    local jo = 1
                    while jo <= i3 do
                        local jp = jo
                        local jt = 1
                        while jt <= i4 do
                            local ju = jt
                            local i7_1 = jp .. "," .. ju
                            local i8_1 = not i5_2[i7_1]
                            if i8_1 ~= false then
                                i8_1 = not gb[i7_1]
                            end
                            if i8_1 then
                                table.insert(i6_2, { X = jp, Z = ju })
                            end
                            jt += 1
                        end
                        jo += 1
                    end
                    local i5_3 = go(Options.PlacePattern.Value, "Front to Back")
                    if i5_3 == "Back to Front" then
                        table.sort(i6_2, function(dd, de)
                            if dd.Z ~= de.Z then
                                return dd.Z > de.Z
                            end
                            return dd.X < de.X
                        end)
                    elseif i5_3 == "Around Town Hall" then
                        table.sort(i6_2, function(c7, c8)
                            local c9 = math.abs(c7.X - 7.5) + math.abs(c7.Z - 17.5)
                            local dc = math.abs(c8.X - 7.5) + math.abs(c8.Z - 17.5)
                            return c9 < dc
                        end)
                    elseif i5_3 == "Edges First" then
                        table.sort(i6_2, function(c1, c2)
                            local c5 = math.min(c1.X - 1, i3 - c1.X, c1.Z - 1, i4 - c1.Z)
                            local c6 = math.min(c2.X - 1, i3 - c2.X, c2.Z - 1, i4 - c2.Z)
                            return c5 < c6
                        end)
                    elseif i5_3 == "Random" then
                        local jy = #i6_2
                        local jx = -1
                        while jy >= 2 do
                            local jz = jy
                            local i5_5 = math.random(jz)
                            i6_2[jz], i6_2[i5_5] = i6_2[i5_5], i6_2[jz]
                            jy += jx
                        end
                    else
                        table.sort(i6_2, function(cY, cZ)
                            if cY.Z ~= cZ.Z then
                                return cY.Z < cZ.Z
                            end
                            return cY.X < cZ.X
                        end)
                    end
                    local i5_6 = f4(Options.PlaceBuildingList.Value)
                    local i7_2 = 1
                    for k, v in fR.Data.Inventory do
                        local jG = v
                        if f2.Unloaded then
                            break
                        end
                        local i8_2 = not jG.IsPlaced
                        if i8_2 then
                            local i9 = fV(i5_6) or i5_6[jG.Name]
                            i8_2 = i9
                        end
                        if i8_2 then
                            local jI = false
                            repeat
                                local i1, i2
                                if i7_2 <= #i6_2 then
                                    i1 = i6_2[i7_2]
                                    i7_2 += 1
                                    i2 = false
                                    pcall(function()
                                        i2 = Building:InvokeServer("Place", jG.Name, i1.X, i1.Z) == true
                                    end)
                                    if i2 then
                                        task.wait(Options.PlaceDelay.Value)
                                        jI = true
                                    end
                                else
                                    jI = true
                                end
                            until jI
                        end
                    end
                end
            end
        else
            jc = true
        end
    until jc
end)
task.spawn(function()
    while true do
        local wait = task.wait
        local jL = Options.CollectDelay and Options.CollectDelay.Value or 0.1
        if wait(jL) then
            if f2.Unloaded then
                break
            end
            if Toggles.AutoCollect.Value then
                local Terrain = workspace:FindFirstChild("Terrain")
                local jK_1 = Terrain and Terrain:FindFirstChild("CoinFolder")
                if jK_1 then
                    for i, child in jK_1:GetChildren() do
                        local jS = child
                        if jS:IsA("Attachment") then
                            pcall(function()
                                Gold:FireServer("Collect", jS.Name)
                            end)
                        end
                    end
                end
            end
            continue
        end
        break
    end
end)
task.spawn(function()
    while true do
        local wait = task.wait
        local jW = Options.UpgradeDelay and Options.UpgradeDelay.Value or 0.2
        if wait(jW) then
            if f2.Unloaded then
                break
            end
            if Toggles.AutoUpgrade.Value then
                local jU_1 = f4(Options.UpgradeBuildingList.Value)
                local jV_1 = math.min(Options.UpgradeMaxLevel.Value, gj)
                for k, v in fR.Data.Inventory do
                    local jT
                    local j1 = k
                    if f2.Unloaded then
                        break
                    end
                    local jW_1 = v.IsPlaced and v.Level < jV_1
                    if jW_1 then
                        local jX = fV(jU_1) or jU_1[v.Name]
                        jW_1 = jX
                    end
                    if jW_1 then
                        jT = false
                        pcall(function()
                            jT = Building:InvokeServer("UpgradeStructure", j1)
                        end)
                        if jT then
                            task.wait(Options.UpgradeDelay.Value)
                        end
                    end
                end
            end
            continue
        end
        break
    end
end)
task.spawn(autoUpgradeTownHallLoop)
gt_2.Settings:AddLeftGroupbox("Anti-AFK"):AddToggle("AntiAFK", { Text = "Anti-AFK", Default = true })
LocalPlayer.Idled:Connect(onIdled)
local MenuGroup = gt_2.Settings:AddRightGroupbox("Menu")
MenuGroup:AddButton("Unload", onUnload)
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
f2.ToggleKeybind = Options.MenuKeybind
f2:OnUnload(fn107)
gx:SetLibrary(f2)
gw_2:SetLibrary(f2)
gx:SetFolder("TempoHub")
gw_2:SetFolder("TempoHub/BuildASlimeDefense")
gw_2:IgnoreThemeSettings()
gw_2:SetIgnoreIndexes({ "MenuKeybind" })
gx:SaveDefault("Mint")
gx:ApplyToTab(gt_2.Settings)
gx:LoadDefault()
gw_2:BuildConfigSection(gt_2.Settings)
gw_2:LoadAutoloadConfig()
end)(...)
